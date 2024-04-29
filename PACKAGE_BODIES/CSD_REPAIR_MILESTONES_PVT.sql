--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_MILESTONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_MILESTONES_PVT" as
/* $Header: csdvromb.pls 120.0 2005/07/14 18:57:26 vkjain noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_REPAIR_MILESTONES_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvromb.pls';

/*--------------------------------------------------*/
/* procedure name: Create_Repair_Milestone          */
/* description   : procedure used to create         */
/*                 repair milestone                 */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Repair_Milestone
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_repair_milestone_rec      IN  REPAIR_MILESTONE_REC_TYPE,
  x_repair_milestone_id 	OUT NOCOPY NUMBER
) IS

-- CONSTANTS --
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIR_MILESTONES_PVT.create_repair_milestone';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Create_Repair_Milestone';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	              VARCHAR2(1) := null;
 l_obj_ver_num		  NUMBER := 1;
 l_rowid		        ROWID;


BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Create_Repair_Milestone;

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call (lc_api_version,
                                           p_api_version,
                                           lc_api_name   ,
                                           G_PKG_NAME    )
       THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
       END IF;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered Create_Repair_Milestone');
       END IF;

/*
       -- log parameters
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   csd_gen_utility_pvt.dump_repair_milestone_rec
           ( p_repair_milestone_rec => p_repair_milestone_rec);
       END IF;
*/
       -- Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Api body starts

       -- Check the required parameters
       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Checking required parameters');
       end if;

       -- Check the required parameters
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_milestone_rec.repair_line_id,
         p_param_name	  => 'REPAIR_LINE_ID',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_milestone_rec.milestone_code,
         p_param_name	  => 'MILESTONE_CODE',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_milestone_rec.milestone_date,
         p_param_name	  => 'MILESTONE_DATE',
         p_api_name	  => lc_api_name);

       -- Insert row
       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling Insert_Row table handler');
       end if;

       Begin

         -- Insert the new flow status transition milestone
         CSD_REPAIR_MILESTONES_PKG.Insert_Row
         (
          px_repair_milestone_id      => x_repair_milestone_id,
          p_repair_line_id            => p_repair_milestone_rec.repair_line_id,
          p_milestone_code            => p_repair_milestone_rec.milestone_code,
          p_milestone_date            => p_repair_milestone_rec.milestone_date,
          p_object_version_number     => l_obj_ver_num,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID
 	   );


       EXCEPTION
          WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name,
                              'Others exception in CSD_REPAIR_MILESTONES_PKG.Insert_Row Call :' ||
                              SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Returned from Insert_Row table handler');
       end if;

      -- Api body ends here

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.END',
                       'Leaving Create_Repair_Milestone');
      END IF;

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Repair_Milestone;
          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Repair_Milestone;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              end if;
              FND_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Create_Repair_Milestone;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              end if;
              FND_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              -- create a seeded message
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'SQL Message['||sqlerrm||']' );
          END IF;

END Create_Repair_Milestone;

/*--------------------------------------------------*/
/* procedure name: Update_Repair_Milestone          */
/* description   : procedure used to update         */
/*                 repair milestone                 */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Repair_Milestone
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_repair_milestone_rec      IN  REPAIR_MILESTONE_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
) IS

-- CONSTANTS --
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIR_MILESTONES_PVT.update_repair_milestone';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Update_Repair_Milestone';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	              VARCHAR2(1) := null;
 l_obj_ver_num		  NUMBER;
 l_rowid		        ROWID;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Update_Repair_Milestone;

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call (lc_api_version,
                                           p_api_version,
                                           lc_api_name   ,
                                           G_PKG_NAME    )
       THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
       END IF;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered Update_Repair_Milestone');
       END IF;

/*
       -- log parameters
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   csd_gen_utility_pvt.dump_repair_milestone_rec
           ( p_repair_milestone_rec => p_repair_milestone_rec);
       END IF;
*/

       -- Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Api body starts

      -- Check the required parameters
       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Checking required parameters');
       end if;

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_milestone_rec.repair_milestone_id,
         p_param_name	  => 'REPAIR_MILESTONE_ID',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_milestone_rec.repair_line_id,
         p_param_name	  => 'REPAIR_LINE_ID',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_milestone_rec.milestone_code,
         p_param_name	  => 'MILESTONE_CODE',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_milestone_rec.milestone_date,
         p_param_name	  => 'MILESTONE_DATE',
         p_api_name	  => lc_api_name);

       -- Update row
       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                        'Calling Update_Row table handler');
       end if;

       Begin

         -- Update the FS transition milestone
         CSD_REPAIR_MILESTONES_PKG.Update_Row
         (
          p_repair_milestone_id       => p_repair_milestone_rec.repair_milestone_id,
          p_repair_line_id            => p_repair_milestone_rec.repair_line_id,
          p_milestone_code            => p_repair_milestone_rec.milestone_code,
          p_milestone_date            => p_repair_milestone_rec.milestone_date,
          p_object_version_number     => p_repair_milestone_rec.object_version_number,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID
 	 );

        x_obj_ver_number := p_repair_milestone_rec.object_version_number + 1;

       EXCEPTION
          WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name,
               'Others exception in CSD_REPAIR_MILESTONES_PKG.Update_Row Call :' ||
               SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Returned from Update_Row table handler');
       end if;

      -- Api body ends here

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.END',
                       'Leaving Update_Repair_Milestone');
      END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Repair_Milestone;
          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

         -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Repair_Milestone;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              end if;
              FND_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Update_Repair_Milestone;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           -- save message in fnd stack
           IF  FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
               if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                  'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
               end if;
               FND_MSG_PUB.Add_Exc_Msg
               (G_PKG_NAME ,
                lc_api_name  );
           END IF;

           FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );

           -- save message in debug log
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               -- create a seeded message
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                              'SQL Message['||sqlerrm||']' );
          END IF;

END Update_Repair_Milestone;

/*--------------------------------------------------*/
/* procedure name: Delete_Repair_Milestone          */
/* description   : procedure used to delete         */
/*                 repair milestone                 */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_Repair_Milestone
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_repair_milestone_id	 	IN  NUMBER
) IS

-- CONSTANTS --
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIR_MILESTONES_PVT.Delete_Repair_Milestone';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Delete_Repair_Milestone';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Delete_Repair_Milestone;

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call (lc_api_version,
                                           p_api_version,
                                           lc_api_name   ,
                                           G_PKG_NAME    )
       THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
       END IF;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
                'Entered Delete_Repair_Milestone');
       END IF;

       -- Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Api body starts

       -- Check the required parameters
       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Checking required parameter');
       end if;

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_milestone_id,
         p_param_name	  => 'REPAIR_MILESTONE_ID',
         p_api_name	  => lc_api_name);

        -- Delete row
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                        'Calling Delete_Row table handler');
       end if;

       BEGIN

         -- Delete the FS transition milestone
         CSD_REPAIR_MILESTONES_PKG.Delete_Row
         (  p_repair_milestone_id => p_repair_milestone_id);

       EXCEPTION
         WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name,
               'Others exception in CSD_REPAIR_MILESTONES_PKG.Delete_Row Call :' ||
               SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Returned from Delete_Row table handler');
       end if;

      -- Api body ends here

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.END',
                       'Leaving Delete_Repair_Milestone');
      END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Delete_Repair_Milestone;

          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

         -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Delete_Repair_Milestone;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              end if;
              FND_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Delete_Repair_Milestone;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           -- save message in fnd stack
           IF  FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
               if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                  'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
               end if;
               FND_MSG_PUB.Add_Exc_Msg
               (G_PKG_NAME ,
                lc_api_name  );
           END IF;

           FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );

           -- save message in debug log
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               -- create a seeded message
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                              'SQL Message['||sqlerrm||']' );
          END IF;

END Delete_Repair_Milestone;

/*--------------------------------------------------*/
/* procedure name: Lock_Repair_Milestone            */
/* description   : procedure used to lock           */
/*                 repair milestone                 */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Repair_Milestone
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_repair_milestone_rec      IN  REPAIR_MILESTONE_REC_TYPE
) IS

-- CONSTANTS --
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIR_MILESTONES_PVT.lock_repair_milestone';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Lock_Repair_Milestone';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_rowid	              ROWID;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Lock_Repair_Milestone;

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call (lc_api_version,
                                           p_api_version,
                                           lc_api_name   ,
                                           G_PKG_NAME    )
       THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
       END IF;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered Lock_Repair_Milestone');
       END IF;

       -- Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Api body starts

        -- Check the required parameters
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                        'Checking required parameters');
        end if;

        -- Check the required parameters
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_milestone_rec.repair_milestone_id,
         p_param_name	  => 'REPAIR_MILESTONE_ID',
         p_api_name	  => lc_api_name);

        CSD_PROCESS_UTIL.Check_Reqd_Param
        ( p_param_value	  => p_repair_milestone_rec.object_version_number,
          p_param_name	  => 'OBJECT_VERSION_NUMBER',
          p_api_name	  => lc_api_name);

        -- Lock row
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                        'Calling Lock_Row table handler');
       end if;

       Begin

         -- Lock the record
         CSD_REPAIR_MILESTONES_PKG.Lock_Row
         (
          p_repair_milestone_id       => p_repair_milestone_rec.repair_milestone_id,
          p_object_version_number     => p_repair_milestone_rec.object_version_number
         );

       EXCEPTION
          WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name,
               'Others exception in CSD_REPAIR_MILESTONES_PKG.Lock_Row Call :' ||
               SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Returned from Lock_Row table handler');
       end if;

      -- Api body ends here

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.END',
                       'Leaving Lock_Repair_Milestone');
      END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Lock_Repair_Milestone;
          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

         -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Lock_Repair_Milestone;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              end if;
              FND_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Lock_Repair_Milestone;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           -- save message in fnd stack
           IF  FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
               if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                  'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
               end if;
               FND_MSG_PUB.Add_Exc_Msg
               (G_PKG_NAME ,
                lc_api_name  );
           END IF;

           FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );

           -- save message in debug log
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               -- create a seeded message
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                              'SQL Message['||sqlerrm||']' );
          END IF;

END Lock_Repair_Milestone;

End CSD_REPAIR_MILESTONES_PVT;

/
