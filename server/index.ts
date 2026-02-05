import express, { type Request, Response, NextFunction } from "express";
import { registerRoutes } from "./routes";
import { setupVite, serveStatic } from "./vite";
import { scheduler as basicScheduler } from "./scheduler";
import { errorHandler } from "./middleware/error-handler";
import { wsManager } from "./websocket";
import { createServer } from "http";
import { logger } from "./lib/logger";

/**
 * Validate required environment variables on startup
 */
function validateEnvironment() {
  const required = ['DATABASE_URL', 'SESSION_SECRET'];
  const missing = required.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}\nPlease check .env.example for setup instructions.`);
  }
  
  // In production, require encryption keys
  if (process.env.NODE_ENV === 'production') {
    const productionRequired = ['ENCRYPTION_KEY', 'ENCRYPTION_SALT'];
    const productionMissing = productionRequired.filter(key => !process.env[key]);
    
    if (productionMissing.length > 0) {
      throw new Error(`Missing required production environment variables: ${productionMissing.join(', ')}\nGenerate with: openssl rand -hex 32`);
    }
  }
  
  log('✓ Environment validation passed');
}

function log(message: string) {
  logger.info(message);
}

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use((req, res, next) => {
  const start = Date.now();
  const path = req.path;
  let capturedJsonResponse: Record<string, any> | undefined = undefined;

  const originalResJson = res.json;
  res.json = function (bodyJson, ...args) {
    capturedJsonResponse = bodyJson;
    return originalResJson.apply(res, [bodyJson, ...args]);
  };

  res.on("finish", () => {
    const duration = Date.now() - start;
    if (path.startsWith("/api")) {
      let logLine = `${req.method} ${path} ${res.statusCode} in ${duration}ms`;
      if (capturedJsonResponse) {
        logLine += ` :: ${JSON.stringify(capturedJsonResponse)}`;
      }

      if (logLine.length > 80) {
        logLine = logLine.slice(0, 79) + "…";
      }

      log(logLine);
    }
  });

  next();
});

(async () => {
  try {
    // Validate environment before starting
    validateEnvironment();
    
    // Verify database connection
    try {
      const { db } = await import("./db");
      await db.execute('SELECT 1');
      log('✓ Database connection verified');
    } catch (error) {
      throw new Error(`Failed to connect to database: ${error instanceof Error ? error.message : 'Unknown error'}\nPlease check DATABASE_URL in your .env file.`);
    }
    
    await registerRoutes(app);

    // Start basic workflow scheduler
    await basicScheduler.start();
    log('✓ Basic workflow scheduler started');
    
    // Initialize Phase 3A features (advanced scheduler and cost tracker)
    const { scheduler: advancedScheduler } = await import("./lib/scheduler");
    const { costTracker } = await import("./lib/cost-tracker");
    
    await advancedScheduler.initialize();
    await costTracker.initializePricing();
    log('✓ Advanced features initialized');
  
    // Graceful shutdown
    process.on("SIGTERM", async () => {
      log("SIGTERM signal received: closing HTTP server");
      try {
        await basicScheduler.stop();
        const { scheduler: advancedScheduler } = await import("./lib/scheduler");
        // Advanced scheduler doesn't have stop method yet
      } catch (error) {
        log(`Warning: Error during shutdown: ${error instanceof Error ? error.message : 'Unknown error'}`);
      }
      process.exit(0);
    });

  app.use((err: any, _req: Request, res: Response, _next: NextFunction) => {
    const status = err.status || err.statusCode || 500;
    const message = err.message || "Internal Server Error";

    res.status(status).json({ message });
    throw err;
  });
  // Use enhanced error handler
  app.use(errorHandler);

    // ALWAYS serve the app on the port specified in the environment variable PORT
  // Other ports are firewalled. Default to 5000 if not specified.
  // this serves both the API and the client.
  // It is the only port that is not firewalled.
  const port = parseInt(process.env.PORT || '5000', 10);
  
  // Create HTTP server and initialize WebSocket
  const server = createServer(app);
  wsManager.initialize(server);

  // importantly only setup vite in development and after
  // setting up all the other routes so the catch-all route
  // doesn't interfere with the other routes
  if (app.get("env") === "development") {
    await setupVite(app, server);
  } else {
    serveStatic(app);
  }
  
    server.listen(port, "0.0.0.0", () => {
      log(`✓ Server running on port ${port}`);
      log(`✓ Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    logger.error('Failed to start server', error instanceof Error ? error : new Error(String(error)));
    process.exit(1);
  }
})();
