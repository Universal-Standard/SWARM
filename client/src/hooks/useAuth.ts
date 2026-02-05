import { useQuery } from "@tanstack/react-query";

export interface User {
  id: string;
  email?: string;
  firstName?: string;
  lastName?: string;
  profileImageUrl?: string;
  createdAt: Date;
  updatedAt?: Date;
  githubAccessToken?: string;
  githubRefreshToken?: string;
  githubTokenExpiry?: Date;
  openaiApiKey?: string;
  anthropicApiKey?: string;
  geminiApiKey?: string;
  defaultProvider?: string;
  defaultModel?: string;
  theme?: string;
  emailNotifications?: boolean;
  inAppNotifications?: boolean;
  executionTimeout?: number;
  autoSaveInterval?: number;
  replitId?: string;
  username?: string;
  avatarUrl?: string;
}

export function useAuth() {
  const { data: user, isLoading } = useQuery<User | undefined>({
    queryKey: ["/api/auth/user"],
    retry: false,
  });

  return {
    user,
    isLoading,
    isAuthenticated: !!user,
  };
}
