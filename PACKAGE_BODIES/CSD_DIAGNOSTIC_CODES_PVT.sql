--------------------------------------------------------
--  DDL for Package Body CSD_DIAGNOSTIC_CODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_DIAGNOSTIC_CODES_PVT" as
/* $Header: csdvcdcb.pls 115.6 2004/02/10 03:13:45 gilam noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_DIAGNOSTIC_CODES_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvcdcb.pls';

/*--------------------------------------------------*/
/* procedure name: Create_Diagnostic_Code           */
/* description   : procedure used to create         */
/*                 diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_diagnostic_code_rec	    	IN  DIAGNOSTIC_CODE_REC_TYPE,
  x_diagnostic_code_id 		OUT NOCOPY NUMBER
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_diagnostic_codes_pvt.create_diagnostic_code';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Create_Diagnostic_Code';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	          VARCHAR2(1)		  := null;
 l_obj_ver_num		  NUMBER		  := 1;
 l_rowid		  VARCHAR2(32767);

-- EXCEPTIONS --
CSD_DC_CODE_EXISTS	  EXCEPTION;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Create_Diagnostic_Code;

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

       IF (lc_proc_level >= lc_debug_level) THEN
          FND_LOG.STRING(lc_proc_level, lc_mod_name || '.BEGIN',
              'Entered Create_Diagnostic_Code');
       END IF;

       -- log parameters
       IF (lc_stat_level >= lc_debug_level) THEN
	   csd_gen_utility_pvt.dump_diagnostic_code_rec
           ( p_diagnostic_code_rec => p_diagnostic_code_rec);
       END IF;

       -- Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Api body starts

       -- Check the required parameters
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Checking required parameters');
       end if;

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_diagnostic_code_rec.diagnostic_code,
         p_param_name	  => 'DIAGNOSTIC_CODE',
         p_api_name	  => lc_api_name);

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_diagnostic_code_rec.name,
         p_param_name	  => 'NAME',
         p_api_name	  => lc_api_name);

       -- Validate the code for diagnostic code
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate if the code of diagnostic code already exists');
       end if;

       Begin
         select 'X'
         into l_dummy
         from csd_diagnostic_codes_b
	 where diagnostic_code = UPPER(p_diagnostic_code_rec.diagnostic_code);

       Exception

    	WHEN no_data_found THEN
	  l_dummy := null;

        WHEN others THEN
          l_dummy := 'X';

       End;

       -- If code already exists, throw an error
       IF (l_dummy = 'X') then
          RAISE CSD_DC_CODE_EXISTS;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Diagnostic code does not exist');
          end if;
       END IF;

       -- Insert row
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling Insert_Row table handler');
       end if;

       Begin

         -- Insert the new diagnostic code
         CSD_DIAGNOSTIC_CODES_PKG.Insert_Row
         (px_rowid 		      => l_rowid,
          px_diagnostic_code_id        => x_diagnostic_code_id,
          p_object_version_number     => l_obj_ver_num,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID,
          p_diagnostic_code           => p_diagnostic_code_rec.diagnostic_code,
          p_name	              => p_diagnostic_code_rec.name,
          p_description	              => p_diagnostic_code_rec.description,
          p_active_from	              => p_diagnostic_code_rec.active_from,
          p_active_to	              => p_diagnostic_code_rec.active_to,
          p_attribute_category        => p_diagnostic_code_rec.attribute_category,
          p_attribute1                => p_diagnostic_code_rec.attribute1,
          p_attribute2                => p_diagnostic_code_rec.attribute2,
          p_attribute3                => p_diagnostic_code_rec.attribute3,
          p_attribute4                => p_diagnostic_code_rec.attribute4,
          p_attribute5                => p_diagnostic_code_rec.attribute5,
          p_attribute6                => p_diagnostic_code_rec.attribute6,
          p_attribute7                => p_diagnostic_code_rec.attribute7,
          p_attribute8                => p_diagnostic_code_rec.attribute8,
          p_attribute9                => p_diagnostic_code_rec.attribute9,
          p_attribute10               => p_diagnostic_code_rec.attribute10,
          p_attribute11               => p_diagnostic_code_rec.attribute11,
          p_attribute12               => p_diagnostic_code_rec.attribute12,
          p_attribute13               => p_diagnostic_code_rec.attribute13,
          p_attribute14               => p_diagnostic_code_rec.attribute14,
          p_attribute15               => p_diagnostic_code_rec.attribute15
 	 );

       EXCEPTION
          WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_DIAGNOSTIC_CODES_PKG.Insert_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
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

      IF (lc_proc_level >= lc_debug_level) THEN
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving Create_Diagnostic_Code');
      END IF;

  EXCEPTION
     WHEN CSD_DC_CODE_EXISTS THEN
          ROLLBACK TO Create_Diagnostic_Code;
            -- Diagnostic code already exists
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DC_CODE_EXISTS to FND_MSG stack');
            end if;
            FND_MESSAGE.SET_NAME('CSD','CSD_DC_CODE_EXISTS');
            FND_MESSAGE.SET_TOKEN('DIAGNOSTIC_CODE',p_diagnostic_code_rec.diagnostic_code);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code already exists');
          END IF;

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Diagnostic_Code;
          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Diagnostic_Code;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
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
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Create_Diagnostic_Code;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
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
          IF (lc_excep_level >= lc_debug_level) THEN
              -- create a seeded message
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                             'SQL Message['||sqlerrm||']' );
          END IF;

END Create_Diagnostic_Code;


/*--------------------------------------------------*/
/* procedure name: Update_Diagnostic_Code           */
/* description   : procedure used to update         */
/*                 diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_diagnostic_code_rec	    	IN  DIAGNOSTIC_CODE_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_diagnostic_codes_pvt.update_diagnostic_code';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Update_Diagnostic_Code';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	          VARCHAR2(1)		  := null;
 l_obj_ver_num		  NUMBER;
 l_rowid		  VARCHAR2(32767);

-- EXCEPTIONS --
CSD_DC_CODE_MISSING	  EXCEPTION;
CSD_DC_NAME_MISSING	  EXCEPTION;
CSD_DC_ID_INVALID	  EXCEPTION;
CSD_DC_GET_OVN_ERROR	  EXCEPTION;
CSD_DC_OVN_MISMATCH	  EXCEPTION;
CSD_DC_CODE_EXISTS	  EXCEPTION;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Update_Diagnostic_Code;

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

       IF (lc_proc_level >= lc_debug_level) THEN
          FND_LOG.STRING(lc_proc_level, lc_mod_name || '.BEGIN',
              'Entered Update_Diagnostic_Code');
       END IF;

       -- log parameters
       IF (lc_stat_level >= lc_debug_level) THEN
	   csd_gen_utility_pvt.dump_diagnostic_code_rec
           ( p_diagnostic_code_rec => p_diagnostic_code_rec);
       END IF;

       -- Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Api body starts

      -- Check the required parameters
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Checking required parameters');
       end if;

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_diagnostic_code_rec.diagnostic_code_id,
         p_param_name	  => 'DIAGNOSTIC_CODE_ID',
         p_api_name	  => lc_api_name);

       -- Check if required parameter is passed in as G_MISS
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Checking if required parameters are passed in as G_MISS');
       end if;

       IF (p_diagnostic_code_rec.diagnostic_code = FND_API.G_MISS_CHAR) THEN
  	 RAISE CSD_DC_CODE_MISSING;
       END IF;

       -- Check if required parameter is passed in as G_MISS
       IF (p_diagnostic_code_rec.name = FND_API.G_MISS_CHAR) THEN
     	 RAISE CSD_DC_NAME_MISSING;
       END IF;

       -- Validate the id for diagnostic code
        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Validate the ID for diagnostic code');
       end if;

       -- Validate the diagnostic code id
       Begin
          select 'X'
          into l_dummy
          from csd_diagnostic_codes_b
 	  where diagnostic_code_id = p_diagnostic_code_rec.diagnostic_code_id;

        Exception

         WHEN others THEN
           l_dummy := null;

       End;

       -- If invalid id, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_DC_ID_INVALID;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Diagnostic code id is valid');
          end if;
       END IF;

       -- Get the object version number for diagnostic code
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Get object version number for diagnostic code');
       end if;

       Begin
          select object_version_number
          into l_obj_ver_num
          from csd_diagnostic_codes_b
 	  where diagnostic_code_id = p_diagnostic_code_rec.diagnostic_code_id;

       Exception

        WHEN others THEN
	  l_obj_ver_num := null;

       End;

       -- If no object version number, throw an error
       IF (l_obj_ver_num is null) then
          RAISE CSD_DC_GET_OVN_ERROR;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Retrieved object version number');
          end if;
       END IF;

       -- Validate if object version number for diagnostic code is same as the one passed in
       IF NVL(p_diagnostic_code_rec.object_version_number,FND_API.G_MISS_NUM) <> l_obj_ver_num  THEN
          RAISE CSD_DC_OVN_MISMATCH;
       END IF;

       -- Validate the code for diagnostic code
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Validate if the code of the diagnostic code already exists ');
       end if;

       Begin

         l_dummy := null;

         select 'X'
         into l_dummy
         from csd_diagnostic_codes_b
	 where diagnostic_code = UPPER(p_diagnostic_code_rec.diagnostic_code)
	 and diagnostic_code_id <> p_diagnostic_code_rec.diagnostic_code_id;

       Exception

    	WHEN no_data_found THEN
 	  l_dummy := null;

        WHEN others THEN
          l_dummy := 'X';

        End;

        -- If code already exists, throw an error
        IF (l_dummy = 'X') then
           RAISE CSD_DC_CODE_EXISTS;
        ELSE
           if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Diagnostic code does not exist');
           end if;
       END IF;

        -- Update row
        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling Update_Row table handler');
       end if;

       Begin

         -- Update the diagnostic code
         CSD_DIAGNOSTIC_CODES_PKG.Update_Row
         (p_diagnostic_code_id        => p_diagnostic_code_rec.diagnostic_code_id,
          p_object_version_number     => l_obj_ver_num + 1,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID,
          p_diagnostic_code           => p_diagnostic_code_rec.diagnostic_code,
          p_name	              => p_diagnostic_code_rec.name,
          p_description	              => p_diagnostic_code_rec.description,
          p_active_from	              => p_diagnostic_code_rec.active_from,
          p_active_to	              => p_diagnostic_code_rec.active_to,
          p_attribute_category        => p_diagnostic_code_rec.attribute_category,
          p_attribute1                => p_diagnostic_code_rec.attribute1,
          p_attribute2                => p_diagnostic_code_rec.attribute2,
          p_attribute3                => p_diagnostic_code_rec.attribute3,
          p_attribute4                => p_diagnostic_code_rec.attribute4,
          p_attribute5                => p_diagnostic_code_rec.attribute5,
          p_attribute6                => p_diagnostic_code_rec.attribute6,
          p_attribute7                => p_diagnostic_code_rec.attribute7,
          p_attribute8                => p_diagnostic_code_rec.attribute8,
          p_attribute9                => p_diagnostic_code_rec.attribute9,
          p_attribute10               => p_diagnostic_code_rec.attribute10,
          p_attribute11               => p_diagnostic_code_rec.attribute11,
          p_attribute12               => p_diagnostic_code_rec.attribute12,
          p_attribute13               => p_diagnostic_code_rec.attribute13,
          p_attribute14               => p_diagnostic_code_rec.attribute14,
          p_attribute15               => p_diagnostic_code_rec.attribute15
 	 );

        x_obj_ver_number := l_obj_ver_num + 1;

       EXCEPTION
          WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_DIAGNOSTIC_CODES_PKG.Update_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
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

      IF (lc_proc_level >= lc_debug_level) THEN
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving Update_Diagnostic_Code');
      END IF;

  EXCEPTION

      WHEN CSD_DC_CODE_MISSING THEN
            ROLLBACK TO Update_Diagnostic_Code;
              -- Diagnostic code already exists
              x_return_status := FND_API.G_RET_STS_ERROR ;

              -- save message in fnd stack
              if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
                                 'Adding message CSD_DC_CODE_MISSING to FND_MSG stack');
              end if;
   	      FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	      FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	      FND_MESSAGE.SET_TOKEN('MISSING_PARAM','DIAGNOSTIC_CODE');
              FND_MSG_PUB.ADD;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

              -- save message in debug log
              if (lc_proc_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Required parameter Diagnostic Code is passed in as G_MISS_CHAR');
              end if;

      WHEN CSD_DC_NAME_MISSING THEN
            ROLLBACK TO Update_Diagnostic_Code;
              -- Diagnostic code name already exists
              x_return_status := FND_API.G_RET_STS_ERROR ;

              -- save message in fnd stack
              if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
                                 'Adding message CSD_DC_CODE_MISSING to FND_MSG stack');
              end if;
   	      FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	      FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	      FND_MESSAGE.SET_TOKEN('MISSING_PARAM','NAME');
              FND_MSG_PUB.ADD;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

              -- save message in debug log
              if (lc_proc_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Required parameter Name is passed in as G_MISS_CHAR');
              end if;

      WHEN CSD_DC_ID_INVALID THEN
            ROLLBACK TO Update_Diagnostic_Code;
              -- Diagnostic code name already exists
              x_return_status := FND_API.G_RET_STS_ERROR ;

              -- save message in fnd stack
              if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
                                 'Adding message CSD_DC_ID_INVALID to FND_MSG stack');
              end if;
   	      FND_MESSAGE.SET_NAME('CSD','CSD_DC_ID_INVALID');
	      FND_MESSAGE.SET_TOKEN('DIAGNOSTIC_CODE',p_diagnostic_code_rec.diagnostic_code);
              FND_MSG_PUB.ADD;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

              -- save message in debug log
              if (lc_proc_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Diagnostic code id is invalid');
              end if;

      WHEN CSD_DC_GET_OVN_ERROR THEN
            ROLLBACK TO Update_Diagnostic_Code;
              -- Diagnostic code name already exists
              x_return_status := FND_API.G_RET_STS_ERROR ;

              -- save message in fnd stack
              if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
                                 'Adding message CSD_DC_GET_OVN_ERROR to FND_MSG stack');
              end if;
   	      FND_MESSAGE.SET_NAME('CSD','CSD_DC_GET_OVN_ERROR');
	      FND_MESSAGE.SET_TOKEN('DIAGNOSTIC_CODE',p_diagnostic_code_rec.diagnostic_code);
              FND_MSG_PUB.ADD;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

              -- save message in debug log
              if (lc_proc_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Error retrieving object version number');
              end if;

      WHEN CSD_DC_OVN_MISMATCH THEN
            ROLLBACK TO Update_Diagnostic_Code;
              -- Diagnostic code name already exists
              x_return_status := FND_API.G_RET_STS_ERROR ;

              -- save message in fnd stack
              if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
                                 'Adding message CSD_DC_OVN_MISMATCH to FND_MSG stack');
              end if;
   	      FND_MESSAGE.SET_NAME('CSD','CSD_DC_OVN_MISMATCH');
	      FND_MESSAGE.SET_TOKEN('DIAGNOSTIC_CODE',p_diagnostic_code_rec.diagnostic_code);
              FND_MSG_PUB.ADD;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

              -- save message in debug log
              if (lc_proc_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Object version number passed in does not match the existing one');
              end if;

    WHEN CSD_DC_CODE_EXISTS THEN
          ROLLBACK TO Update_Diagnostic_Code;
            -- Diagnostic code already exists
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DC_CODE_EXISTS to FND_MSG stack');
            end if;
            FND_MESSAGE.SET_NAME('CSD','CSD_DC_CODE_EXISTS');
            FND_MESSAGE.SET_TOKEN('DIAGNOSTIC_CODE',p_diagnostic_code_rec.diagnostic_code);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code already exists');
          END IF;

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Diagnostic_Code;
          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

         -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Diagnostic_Code;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
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
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Update_Diagnostic_Code;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           -- save message in fnd stack
           IF  FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
               if (lc_stat_level >= lc_debug_level) then
                   FND_LOG.STRING(lc_stat_level, lc_mod_name,
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
           IF (lc_excep_level >= lc_debug_level) THEN
               -- create a seeded message
               FND_LOG.STRING(lc_excep_level, lc_mod_name,
                              'SQL Message['||sqlerrm||']' );
          END IF;

END Update_Diagnostic_Code;

/*--------------------------------------------------*/
/* procedure name: Lock_Diagnostic_Code             */
/* description   : procedure used to lock           */
/*                 diagnostic code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_Diagnostic_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_diagnostic_code_rec	    	IN  DIAGNOSTIC_CODE_REC_TYPE
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_diagnostic_codes_pvt.lock_diagnostic_code';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Lock_Diagnostic_Code';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_rowid		  VARCHAR2(32767);

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Lock_Diagnostic_Code;

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

       IF (lc_proc_level >= lc_debug_level) THEN
          FND_LOG.STRING(lc_proc_level, lc_mod_name || '.BEGIN',
              'Entered Lock_Diagnostic_Code');
       END IF;

       -- Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Api body starts

        -- Check the required parameters
        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Checking required parameters');
        end if;

        -- Check the required parameter
        CSD_PROCESS_UTIL.Check_Reqd_Param
        ( p_param_value	  => p_diagnostic_code_rec.diagnostic_code_id,
          p_param_name	  => 'DIAGNOSTIC_CODE_ID',
          p_api_name	  => lc_api_name);

        -- Check the required parameter
        CSD_PROCESS_UTIL.Check_Reqd_Param
        ( p_param_value	  => p_diagnostic_code_rec.object_version_number,
          p_param_name	  => 'OBJECT_VERSION_NUMBER',
          p_api_name	  => lc_api_name);

        -- Lock row
        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling Lock_Row table handler');
       end if;

       Begin

         -- Lock the diagnostic code
         CSD_DIAGNOSTIC_CODES_PKG.Lock_Row
         (px_rowid 		      => l_rowid,
          p_diagnostic_code_id        => p_diagnostic_code_rec.diagnostic_code_id,
          p_object_version_number     => p_diagnostic_code_rec.object_version_number

          --commented out the rest of the record
          /*,
          p_diagnostic_code           => p_diagnostic_code_rec.diagnostic_code,
          p_name	              => p_diagnostic_code_rec.name,
          p_description	              => p_diagnostic_code_rec.description,
          p_active_from	              => p_diagnostic_code_rec.active_from,
          p_active_to	              => p_diagnostic_code_rec.active_to,
          p_attribute_category        => p_diagnostic_code_rec.attribute_category,
          p_attribute1                => p_diagnostic_code_rec.attribute1,
          p_attribute2                => p_diagnostic_code_rec.attribute2,
          p_attribute3                => p_diagnostic_code_rec.attribute3,
          p_attribute4                => p_diagnostic_code_rec.attribute4,
          p_attribute5                => p_diagnostic_code_rec.attribute5,
          p_attribute6                => p_diagnostic_code_rec.attribute6,
          p_attribute7                => p_diagnostic_code_rec.attribute7,
          p_attribute8                => p_diagnostic_code_rec.attribute8,
          p_attribute9                => p_diagnostic_code_rec.attribute9,
          p_attribute10               => p_diagnostic_code_rec.attribute10,
          p_attribute11               => p_diagnostic_code_rec.attribute11,
          p_attribute12               => p_diagnostic_code_rec.attribute12,
          p_attribute13               => p_diagnostic_code_rec.attribute13,
          p_attribute14               => p_diagnostic_code_rec.attribute14,
          p_attribute15               => p_diagnostic_code_rec.attribute15
          */
          --
 	 );

       EXCEPTION
          WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_DIAGNOSTIC_CODES_PKG.Lock_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
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

      IF (lc_proc_level >= lc_debug_level) THEN
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving Lock_Diagnostic_Code');
      END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Lock_Diagnostic_Code;
          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

         -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Lock_Diagnostic_Code;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
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
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Lock_Diagnostic_Code;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           -- save message in fnd stack
           IF  FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
               if (lc_stat_level >= lc_debug_level) then
                   FND_LOG.STRING(lc_stat_level, lc_mod_name,
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
           IF (lc_excep_level >= lc_debug_level) THEN
               -- create a seeded message
               FND_LOG.STRING(lc_excep_level, lc_mod_name,
                              'SQL Message['||sqlerrm||']' );
          END IF;

END Lock_Diagnostic_Code;

End CSD_DIAGNOSTIC_CODES_PVT;


/
