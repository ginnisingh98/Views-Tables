--------------------------------------------------------
--  DDL for Package Body CSD_FLWSTS_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_FLWSTS_TRANS_PVT" as
/* $Header: csdvfltb.pls 120.1 2005/07/29 16:37:14 vkjain noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_FLWSTS_TRANS_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvfltb.pls';

/*--------------------------------------------------*/
/* procedure name: Create_Flwsts_Tran               */
/* description   : procedure used to create         */
/*                 Flow Status transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Flwsts_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_rec           IN  FLWSTS_TRAN_REC_TYPE,
  x_flwsts_tran_id 		OUT NOCOPY NUMBER
) IS

-- CONSTANTS --
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_FLWSTS_TRANS_PVT.create_flwsts_tran';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Create_Flwsts_Tran';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	              VARCHAR2(1) := null;
 l_obj_ver_num		  NUMBER := 1;
 l_rowid		        ROWID;

-- EXCEPTIONS --
UNIQUE_CONSTRAINT_VIOLATED Exception;

-- This will trap all exceptions that have
-- SQLCODE = -00001 and name it as 'UNIQUE_CONSTRAINT_VIOLATED'.
PRAGMA EXCEPTION_INIT( UNIQUE_CONSTRAINT_VIOLATED, -00001 );

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Create_Flwsts_Tran;

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
              'Entered Create_Flwsts_Tran');
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
       ( p_param_value	  => p_flwsts_tran_rec.repair_type_id,
         p_param_name	  => 'REPAIR_TYPE_ID',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_flwsts_tran_rec.from_flow_status_id,
         p_param_name	  => 'FROM_FLOW_STATUS_ID',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_flwsts_tran_rec.to_flow_status_id,
         p_param_name	  => 'TO_FLOW_STATUS_ID',
         p_api_name	  => lc_api_name);

       -- Insert row
       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Calling Insert_Row table handler');
       end if;

       Begin

         -- Insert the new diagnostic code
         CSD_FLWSTS_TRANS_PKG.Insert_Row
         (
          px_flwsts_tran_id           => x_flwsts_tran_id,
          p_repair_type_id            => p_flwsts_tran_rec.repair_type_id,
          p_from_flow_status_id       => p_flwsts_tran_rec.from_flow_status_id,
          p_to_flow_status_id         => p_flwsts_tran_rec.to_flow_status_id,
          p_wf_item_type              => p_flwsts_tran_rec.wf_item_type,
          p_wf_process_name           => p_flwsts_tran_rec.wf_process_name,
          p_reason_required_flag      => p_flwsts_tran_rec.reason_required_flag,
          p_capture_activity_flag     => p_flwsts_tran_rec.capture_activity_flag,
          p_allow_all_resp_flag       => p_flwsts_tran_rec.allow_all_resp_flag,
          p_description               => p_flwsts_tran_rec.description,
          p_object_version_number     => l_obj_ver_num,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID
 	   );
       END;

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
                       'Leaving Create_Flwsts_Tran');
      END IF;

  EXCEPTION
     WHEN UNIQUE_CONSTRAINT_VIOLATED THEN
          ROLLBACK TO Create_Flwsts_Tran;
          x_return_status := FND_API.G_RET_STS_ERROR;

          -- The definition already exists. No duplicates are allowed.
          FND_MESSAGE.set_name('CSD', 'CSD_FLEX_DEFN_EXISTS');
          FND_MSG_PUB.add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Flwsts_Tran;
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
          ROLLBACK TO Create_Flwsts_Tran;
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
          ROLLBACK TO Create_Flwsts_Tran;
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

END Create_Flwsts_Tran;

/*--------------------------------------------------*/
/* procedure name: Update_Flwsts_Tran               */
/* description   : procedure used to update         */
/*                 Flow Status transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Flwsts_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_rec           IN  FLWSTS_TRAN_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
) IS

-- CONSTANTS --
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_FLWSTS_TRANS_PVT.update_flwsts_tran';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Update_Flwsts_Tran';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	              VARCHAR2(1) := null;
 l_obj_ver_num		      NUMBER;
 l_rowid		          ROWID;

-- EXCEPTIONS --
UNIQUE_CONSTRAINT_VIOLATED Exception;

-- This will trap all exceptions that have
-- SQLCODE = -00001 and name it as 'UNIQUE_CONSTRAINT_VIOLATED'.
PRAGMA EXCEPTION_INIT( UNIQUE_CONSTRAINT_VIOLATED, -00001 );

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Update_Flwsts_Tran;

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
              'Entered Update_Flwsts_Tran');
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
       ( p_param_value	  => p_flwsts_tran_rec.flwsts_tran_id,
         p_param_name	  => 'FLWSTS_TRAN_ID',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_flwsts_tran_rec.repair_type_id,
         p_param_name	  => 'REPAIR_TYPE_ID',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_flwsts_tran_rec.from_flow_status_id,
         p_param_name	  => 'FROM_FLOW_STATUS_ID',
         p_api_name	  => lc_api_name);

       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_flwsts_tran_rec.to_flow_status_id,
         p_param_name	  => 'TO_FLOW_STATUS_ID',
         p_api_name	  => lc_api_name);

        -- Update row
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                        'Calling Update_Row table handler');
        end if;

       Begin

         -- Update the diagnostic code
         CSD_FLWSTS_TRANS_PKG.Update_Row
         (p_flwsts_tran_id            => p_flwsts_tran_rec.flwsts_tran_id,
          p_repair_type_id            => p_flwsts_tran_rec.repair_type_id,
          p_from_flow_status_id       => p_flwsts_tran_rec.from_flow_status_id,
          p_to_flow_status_id         => p_flwsts_tran_rec.to_flow_status_id,
          p_wf_item_type              => p_flwsts_tran_rec.wf_item_type,
          p_wf_process_name           => p_flwsts_tran_rec.wf_process_name,
          p_reason_required_flag      => p_flwsts_tran_rec.reason_required_flag,
          p_capture_activity_flag     => p_flwsts_tran_rec.capture_activity_flag,
          p_allow_all_resp_flag       => p_flwsts_tran_rec.allow_all_resp_flag,
          p_description               => p_flwsts_tran_rec.description,
          p_object_version_number     => p_flwsts_tran_rec.object_version_number,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID
 	     );

         x_obj_ver_number := p_flwsts_tran_rec.object_version_number + 1;

       END;

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
                       'Leaving Update_Flwsts_Tran');
      END IF;

  EXCEPTION
       WHEN UNIQUE_CONSTRAINT_VIOLATED THEN
          ROLLBACK TO Update_Flwsts_Tran;
          x_return_status := FND_API.G_RET_STS_ERROR;

          -- The definition already exists. No duplicates are allowed.
          FND_MESSAGE.set_name('CSD', 'CSD_FLEX_DEFN_EXISTS');
          FND_MSG_PUB.add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Flwsts_Tran;
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
          ROLLBACK TO Update_Flwsts_Tran;
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
          ROLLBACK TO Update_Flwsts_Tran;
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

END Update_Flwsts_Tran;

/*--------------------------------------------------*/
/* procedure name: Delete_Flwsts_Tran               */
/* description   : procedure used to delete         */
/*                 Flow Status transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_Flwsts_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_id	 	IN  NUMBER
) IS

-- CONSTANTS --
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_FLWSTS_TRANS_PVT.Delete_Flwsts_Tran';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Delete_Flwsts_Tran';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Delete_Flwsts_Tran;

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
                'Entered Delete_Flwsts_Tran');
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
       ( p_param_value	  => p_flwsts_tran_id,
         p_param_name	  => 'FLWSTS_TRAN_ID',
         p_api_name	  => lc_api_name);

        -- Delete row
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                        'Calling Delete_Row table handler');
       end if;

       BEGIN

         -- Delete the diagnostic code domain
         CSD_FLWSTS_TRANS_PKG.Delete_Row
         (  p_flwsts_tran_id => p_flwsts_tran_id);

       END;

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
                       'Leaving Delete_Flwsts_Tran');
      END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Delete_Flwsts_Tran;

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
          ROLLBACK TO Delete_Flwsts_Tran;

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
          ROLLBACK TO Delete_Flwsts_Tran;

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

END Delete_Flwsts_Tran;

/*--------------------------------------------------*/
/* procedure name: Lock_Flwsts_Tran                 */
/* description   : procedure used to lock           */
/*                 Flow Status transition 	    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Flwsts_Tran
(
  p_api_version        		IN  NUMBER,
  p_commit	   		      IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_flwsts_tran_rec           IN  FLWSTS_TRAN_REC_TYPE
) IS

-- CONSTANTS --
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_FLWSTS_TRANS_PVT.lock_flwsts_tran';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Lock_Flwsts_Tran';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_rowid	              ROWID;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Lock_Flwsts_Tran;

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
              'Entered Lock_Flwsts_Tran');
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
       ( p_param_value	  => p_flwsts_tran_rec.flwsts_tran_id,
         p_param_name	  => 'FLWSTS_TRAN_ID',
         p_api_name	  => lc_api_name);

        CSD_PROCESS_UTIL.Check_Reqd_Param
        ( p_param_value	  => p_flwsts_tran_rec.object_version_number,
          p_param_name	  => 'OBJECT_VERSION_NUMBER',
          p_api_name	  => lc_api_name);

        -- Lock row
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                        'Calling Lock_Row table handler');
       end if;

       Begin

         -- Lock the diagnostic code
         CSD_FLWSTS_TRANS_PKG.Lock_Row
         (
          p_flwsts_tran_id            => p_flwsts_tran_rec.flwsts_tran_id,
          p_object_version_number     => p_flwsts_tran_rec.object_version_number
         );

       END;

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
                       'Leaving Lock_Flwsts_Tran');
      END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Lock_Flwsts_Tran;
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
          ROLLBACK TO Lock_Flwsts_Tran;
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
          ROLLBACK TO Lock_Flwsts_Tran;
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

END Lock_Flwsts_Tran;

End CSD_FLWSTS_TRANS_PVT;

/