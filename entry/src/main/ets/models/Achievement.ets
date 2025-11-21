/**
 * Achievement Model
 * 成就模型
 */
export interface Achievement {
  id: string;
  name: string;
  description: string;
  icon: string;
  unlocked: boolean;
  unlockedAt?: number;
  progress: number;              // 0-100
  target: number;
}
