import { BaseRepository } from './BaseRepository';
import { Achievement } from '../models';
import relationalStore from '@ohos.data.relationalStore';

/**
 * Achievement Repository
 * 成就数据访问层
 */
export class AchievementRepository extends BaseRepository {
  private readonly TABLE_NAME = 'achievements';

  /**
   * Get all achievements
   */
  async getAll(): Promise<Achievement[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    
    try {
      const resultSet = await store.query(predicates);
      const achievements = this.mapResultSetToAchievements(resultSet);
      resultSet.close();
      return achievements;
    } catch (error) {
      console.error('Failed to get all achievements:', error);
      throw new Error(`Failed to get all achievements: ${error}`);
    }
  }

  /**
   * Update achievement status
   */
  async updateAchievement(id: string, unlocked: boolean, progress: number): Promise<void> {
    const store = this.getStore();
    
    const valueBucket: relationalStore.ValuesBucket = {
      unlocked: unlocked ? 1 : 0,
      progress: progress
    };

    // If unlocking, set the unlocked_at timestamp
    if (unlocked) {
      valueBucket.unlocked_at = Date.now();
    }

    try {
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', id);
      
      await store.update(valueBucket, predicates);
    } catch (error) {
      console.error('Failed to update achievement:', error);
      throw new Error(`Failed to update achievement: ${error}`);
    }
  }

  /**
   * Get unlocked achievements
   */
  async getUnlocked(): Promise<Achievement[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    predicates.equalTo('unlocked', 1);
    
    try {
      const resultSet = await store.query(predicates);
      const achievements = this.mapResultSetToAchievements(resultSet);
      resultSet.close();
      return achievements;
    } catch (error) {
      console.error('Failed to get unlocked achievements:', error);
      throw new Error(`Failed to get unlocked achievements: ${error}`);
    }
  }

  /**
   * Map ResultSet to Achievement array
   */
  private mapResultSetToAchievements(resultSet: relationalStore.ResultSet): Achievement[] {
    const achievements: Achievement[] = [];
    
    if (resultSet.goToFirstRow()) {
      do {
        achievements.push(this.mapResultSetToAchievement(resultSet));
      } while (resultSet.goToNextRow());
    }
    
    return achievements;
  }

  /**
   * Map single row from ResultSet to Achievement
   */
  private mapResultSetToAchievement(resultSet: relationalStore.ResultSet): Achievement {
    const idIndex = resultSet.getColumnIndex('id');
    const nameIndex = resultSet.getColumnIndex('name');
    const descriptionIndex = resultSet.getColumnIndex('description');
    const iconIndex = resultSet.getColumnIndex('icon');
    const unlockedIndex = resultSet.getColumnIndex('unlocked');
    const unlockedAtIndex = resultSet.getColumnIndex('unlocked_at');
    const progressIndex = resultSet.getColumnIndex('progress');
    const targetIndex = resultSet.getColumnIndex('target');

    const unlockedValue = resultSet.getLong(unlockedIndex);
    const unlockedAtValue = resultSet.getLong(unlockedAtIndex);

    return {
      id: resultSet.getString(idIndex),
      name: resultSet.getString(nameIndex),
      description: resultSet.getString(descriptionIndex),
      icon: resultSet.getString(iconIndex),
      unlocked: unlockedValue === 1,
      unlockedAt: unlockedAtValue > 0 ? unlockedAtValue : undefined,
      progress: resultSet.getDouble(progressIndex),
      target: resultSet.getDouble(targetIndex)
    };
  }
}
