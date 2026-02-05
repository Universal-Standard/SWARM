/**
 * Production-ready logging utility
 * Provides structured logging with different levels
 */

export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

interface LogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  context?: Record<string, any>;
  error?: Error;
}

class Logger {
  private isDevelopment = process.env.NODE_ENV === 'development';
  private minLevel: LogLevel = this.isDevelopment ? 'debug' : 'info';

  private levelPriority: Record<LogLevel, number> = {
    debug: 0,
    info: 1,
    warn: 2,
    error: 3,
  };

  private shouldLog(level: LogLevel): boolean {
    return this.levelPriority[level] >= this.levelPriority[this.minLevel];
  }

  private formatLog(entry: LogEntry): string {
    const { timestamp, level, message, context, error } = entry;
    
    if (this.isDevelopment) {
      // Development: Human-readable format with colors
      const levelColors = {
        debug: '\x1b[36m', // Cyan
        info: '\x1b[32m',  // Green
        warn: '\x1b[33m',  // Yellow
        error: '\x1b[31m', // Red
      };
      const reset = '\x1b[0m';
      const color = levelColors[level];
      
      let output = `${color}[${level.toUpperCase()}]${reset} ${message}`;
      
      if (context && Object.keys(context).length > 0) {
        output += ` ${JSON.stringify(context, null, 2)}`;
      }
      
      if (error) {
        output += `\n${error.stack || error.message}`;
      }
      
      return output;
    } else {
      // Production: JSON format for log aggregation
      return JSON.stringify({
        timestamp,
        level,
        message,
        ...context,
        ...(error && {
          error: {
            message: error.message,
            stack: error.stack,
            name: error.name,
          }
        }),
      });
    }
  }

  private log(level: LogLevel, message: string, context?: Record<string, any>, error?: Error) {
    if (!this.shouldLog(level)) return;

    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      context,
      error,
    };

    const formatted = this.formatLog(entry);

    switch (level) {
      case 'error':
        console.error(formatted);
        break;
      case 'warn':
        console.warn(formatted);
        break;
      case 'info':
        console.info(formatted);
        break;
      case 'debug':
        console.log(formatted);
        break;
    }
  }

  debug(message: string, context?: Record<string, any>) {
    this.log('debug', message, context);
  }

  info(message: string, context?: Record<string, any>) {
    this.log('info', message, context);
  }

  warn(message: string, context?: Record<string, any>) {
    this.log('warn', message, context);
  }

  error(message: string, contextOrError?: Record<string, any> | Error, error?: Error) {
    if (contextOrError instanceof Error) {
      this.log('error', message, undefined, contextOrError);
    } else {
      this.log('error', message, contextOrError, error);
    }
  }

  /**
   * Log request/response for API endpoints
   */
  http(method: string, path: string, statusCode: number, duration: number, context?: Record<string, any>) {
    this.info(`${method} ${path} ${statusCode} in ${duration}ms`, context);
  }

  /**
   * Log workflow execution
   */
  workflow(workflowId: string, action: string, context?: Record<string, any>) {
    this.info(`Workflow ${action}`, { workflowId, ...context });
  }

  /**
   * Log AI provider calls
   */
  ai(provider: string, model: string, action: string, context?: Record<string, any>) {
    this.debug(`AI ${action}`, { provider, model, ...context });
  }
}

// Export singleton instance
export const logger = new Logger();
