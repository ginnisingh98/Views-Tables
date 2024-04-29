--------------------------------------------------------
--  DDL for Package Body CSD_RO_SERVICE_CODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RO_SERVICE_CODES_PVT" as
/* $Header: csdvrscb.pls 120.2 2006/09/27 00:29:49 rfieldma noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_RO_SERVICE_CODES_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvrscb.pls';

/*--------------------------------------------------*/
/* procedure name: Create_RO_Service_Code           */
/* description   : procedure used to create         */
/*                 ro service code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_RO_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_service_code_rec	 	IN  RO_SERVICE_CODE_REC_TYPE,
  x_ro_service_code_id 		OUT NOCOPY NUMBER
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_ro_service_codes_pvt.create_ro_service_code';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Create_RO_Service_Code';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	          VARCHAR2(1)		  :=null;
 l_obj_ver_num		  NUMBER		  := 1;

-- EXCEPTIONS --
-- CSD_RSC_ASSOCIATION_EXISTS		EXCEPTION;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Create_RO_Service_Code;

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
              'Entered Create_RO_Service_Code');
       END IF;

       -- log parameters
       IF (lc_stat_level >= lc_debug_level) THEN
	   csd_gen_utility_pvt.dump_ro_service_code_rec
           ( p_ro_service_code_rec => p_ro_service_code_rec);
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
       ( p_param_value	  => p_ro_service_code_rec.repair_line_id,
         p_param_name	  => 'REPAIR_LINE_ID',
         p_api_name	  => lc_api_name);

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_ro_service_code_rec.service_code_id,
         p_param_name	  => 'SERVICE_CODE_ID',
         p_api_name	  => lc_api_name);

       -- Check the required parameter, rfieldma 4666403
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_ro_service_code_rec.service_item_id,
         p_param_name	  => 'SERVICE_ITEM_ID',
         p_api_name	  => lc_api_name);

	  -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_ro_service_code_rec.source_type_code,
         p_param_name	  => 'SOURCE_TYPE_CODE',
         p_api_name	  => lc_api_name);

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_ro_service_code_rec.applicable_flag,
         p_param_name	  => 'APPLICABLE_FLAG',
         p_api_name	  => lc_api_name);

       -- Validate the repair line ID
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate repair line id');
       end if;

       -- Validate the repair line ID
       IF NOT( CSD_PROCESS_UTIL.Validate_rep_line_id
                 ( p_repair_line_id  => p_ro_service_code_rec.repair_line_id )) THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       /*
       -- Validate the ro association for service code
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate if the ro association for service code exists');
       end if;

       -- Validate the ro association for service code
       Begin
         l_dummy := null;

         select 'X'
         into l_dummy
         from csd_ro_service_codes
	 where repair_line_id = p_ro_service_code_rec.repair_line_id
         and   service_code_id = p_ro_service_code_rec.service_code_id;

       Exception

    	WHEN no_data_found THEN
	  null;

        WHEN others THEN
          l_dummy := 'X';

       End;

       -- If association exists, throw an error
       IF (l_dummy = 'X') then
           RAISE CSD_RSC_ASSOCIATION_EXISTS;
        ELSE
           if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'RO service code association already exists');
           end if;
       END IF;
       */

       -- Insert row
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling Insert_Row table handler');
       end if;

       BEGIN

         -- Insert the new ro service code association
         CSD_RO_SERVICE_CODES_PKG.Insert_Row
         (px_ro_service_code_id       => x_ro_service_code_id,
          p_object_version_number     => l_obj_ver_num,
          p_repair_line_id            => p_ro_service_code_rec.repair_line_id,
          p_service_code_id           => p_ro_service_code_rec.service_code_id,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID,
          p_source_type_code          => p_ro_service_code_rec.source_type_code,
          p_source_solution_id        => p_ro_service_code_rec.source_solution_id,
          p_applicable_flag  	      => p_ro_service_code_rec.applicable_flag,
          p_applied_to_est_flag       => 'N',
          p_applied_to_work_flag      => 'N',
          p_attribute_category        => p_ro_service_code_rec.attribute_category,
          p_attribute1                => p_ro_service_code_rec.attribute1,
          p_attribute2                => p_ro_service_code_rec.attribute2,
          p_attribute3                => p_ro_service_code_rec.attribute3,
          p_attribute4                => p_ro_service_code_rec.attribute4,
          p_attribute5                => p_ro_service_code_rec.attribute5,
          p_attribute6                => p_ro_service_code_rec.attribute6,
          p_attribute7                => p_ro_service_code_rec.attribute7,
          p_attribute8                => p_ro_service_code_rec.attribute8,
          p_attribute9                => p_ro_service_code_rec.attribute9,
          p_attribute10               => p_ro_service_code_rec.attribute10,
          p_attribute11               => p_ro_service_code_rec.attribute11,
          p_attribute12               => p_ro_service_code_rec.attribute12,
          p_attribute13               => p_ro_service_code_rec.attribute13,
          p_attribute14               => p_ro_service_code_rec.attribute14,
          p_attribute15               => p_ro_service_code_rec.attribute15,
		p_service_item_id		   => p_ro_service_code_rec.service_item_id --rfieldma, 4666403
 	);

       EXCEPTION
          WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_RO_SERVICE_CODES_PKG.Insert_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Create_RO_Service_Code');
      END IF;

EXCEPTION
     /*
     WHEN CSD_RSC_ASSOCIATION_EXISTS THEN
          ROLLBACK TO Create_RO_Service_Code;

            -- RO service code already exists
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_ASSOCIATION_EXISTS to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_RSC_ASSOCIATION_EXISTS');
	    FND_MESSAGE.SET_TOKEN('SERVICE_CODE_ID',p_ro_service_code_rec.service_code_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'RO service code already exists');
            END IF;
    */

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_RO_Service_Code;

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
          ROLLBACK TO Create_RO_Service_Code;

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
          ROLLBACK TO Create_RO_Service_Code;

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

END Create_RO_Service_Code;

/*--------------------------------------------------*/
/* procedure name: Update_RO_Service_Code           */
/* description   : procedure used to update         */
/*                 ro service code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_RO_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_service_code_rec	 	IN  RO_SERVICE_CODE_REC_TYPE,
  x_obj_ver_number 		OUT NOCOPY NUMBER
)IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_ro_service_codes_pvt.update_ro_service_code';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Update_RO_Service_Code';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	          VARCHAR2(1)		  :=null;
 l_obj_ver_num		  NUMBER		  := 1;
 l_applied_to_est_flag	  VARCHAR2(1)		  :=null;
 l_applied_to_work_flag	  VARCHAR2(1)		  :=null;

-- EXCEPTIONS --
CSD_RSC_RO_ID_MISSING		EXCEPTION;
CSD_RSC_SC_ID_MISSING		EXCEPTION;
CSD_RSC_SOURCE_TYPE_MISSING	EXCEPTION;
CSD_RSC_APPL_FLAG_MISSING	EXCEPTION;
CSD_RSC_APPL_EST_FLAG_MISSING	EXCEPTION;
CSD_RSC_APPL_WORK_FLAG_MISSING	EXCEPTION;
CSD_RSC_INVALID_ID		EXCEPTION;
CSD_RSC_GET_OVN_ERROR		EXCEPTION;
CSD_RSC_OVN_MISMATCH		EXCEPTION;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Update_RO_Service_Code;

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
              'Entered Update_RO_Service_Code');
       END IF;

       -- log parameters
       IF (lc_stat_level >= lc_debug_level) THEN
	   csd_gen_utility_pvt.dump_ro_service_code_rec
           ( p_ro_service_code_rec => p_ro_service_code_rec);
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
       ( p_param_value	  => p_ro_service_code_rec.ro_service_code_id,
         p_param_name	  => 'RO_SERVICE_CODE_ID',
         p_api_name	  => lc_api_name);


	  -- Check if required parameters are passed in as G_MISS
       IF (p_ro_service_code_rec.repair_line_id = FND_API.G_MISS_NUM) THEN
	RAISE CSD_RSC_RO_ID_MISSING;
       END IF;

       IF (p_ro_service_code_rec.service_code_id = FND_API.G_MISS_NUM) THEN
	RAISE CSD_RSC_SC_ID_MISSING;
       END IF;

       IF (p_ro_service_code_rec.source_type_code = FND_API.G_MISS_CHAR) THEN
	RAISE CSD_RSC_SOURCE_TYPE_MISSING;
       END IF;

       IF (p_ro_service_code_rec.applicable_flag = FND_API.G_MISS_CHAR) THEN
	RAISE CSD_RSC_APPL_FLAG_MISSING;
       END IF;

       IF (p_ro_service_code_rec.applied_to_est_flag = FND_API.G_MISS_CHAR) THEN
	RAISE CSD_RSC_APPL_EST_FLAG_MISSING;
       END IF;

       IF (p_ro_service_code_rec.applied_to_work_flag = FND_API.G_MISS_CHAR) THEN
	RAISE CSD_RSC_APPL_WORK_FLAG_MISSING;
       END IF;

       -- Validate the ro service code association
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the id for ro service code');
       end if;

       -- Validate the ro service code association
       Begin
          l_dummy := null;

          select 'X'
          into l_dummy
          from csd_ro_service_codes
 	  where ro_service_code_id = p_ro_service_code_rec.ro_service_code_id;

       Exception

         WHEN others THEN
           null;

       End;

       -- If ro service code association does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_RSC_INVALID_ID;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'RO service code association is valid');
          end if;
       END IF;

       -- Get the object version number for ro service code association
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Get object version number for ro service code association');
       end if;

       -- Get object version number for ro service code association
        Begin
          select object_version_number
          into l_obj_ver_num
          from csd_ro_service_codes
 	  where ro_service_code_id = p_ro_service_code_rec.ro_service_code_id;

       Exception

         WHEN others THEN
    	   l_obj_ver_num := null;

       End;

       -- If no object version number, throw an error
       IF (l_obj_ver_num is null) then
          RAISE CSD_RSC_GET_OVN_ERROR;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Retrieved object version number');
          end if;
       END IF;

       -- Validate the object version number for ro service code association
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Validate object version number for ro service code association');
       end if;

       -- Validate if object version number for ro service code association is same as the one passed in
       IF NVL(p_ro_service_code_rec.object_version_number,FND_API.G_MISS_NUM) <> l_obj_ver_num  THEN
          RAISE CSD_RSC_OVN_MISMATCH;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Object version number is valid');
          end if;
       END IF;

       -- Validate the repair line id if it is passed in
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate repair line id if it is passed in');
       end if;

       -- Validate the repair line ID
       IF (p_ro_service_code_rec.repair_line_id IS NOT NULL) THEN
         IF NOT( CSD_PROCESS_UTIL.Validate_rep_line_id
               ( p_repair_line_id  => p_ro_service_code_rec.repair_line_id )) THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;

       -- Update row
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling Update_Row table handler');
       end if;

       BEGIN

         CSD_RO_SERVICE_CODES_PKG.Update_Row
         (p_ro_service_code_id        => p_ro_service_code_rec.ro_service_code_id,
          p_object_version_number     => l_obj_ver_num + 1,
          p_repair_line_id            => p_ro_service_code_rec.repair_line_id,
          p_service_code_id           => p_ro_service_code_rec.service_code_id,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID,
          p_source_type_code          => p_ro_service_code_rec.source_type_code,
          p_source_solution_id        => p_ro_service_code_rec.source_solution_id,
          p_applicable_flag  	      => p_ro_service_code_rec.applicable_flag,
          p_applied_to_est_flag       => p_ro_service_code_rec.applied_to_est_flag,
          p_applied_to_work_flag      => p_ro_service_code_rec.applied_to_work_flag,
          p_attribute_category        => p_ro_service_code_rec.attribute_category,
          p_attribute1                => p_ro_service_code_rec.attribute1,
          p_attribute2                => p_ro_service_code_rec.attribute2,
          p_attribute3                => p_ro_service_code_rec.attribute3,
          p_attribute4                => p_ro_service_code_rec.attribute4,
          p_attribute5                => p_ro_service_code_rec.attribute5,
          p_attribute6                => p_ro_service_code_rec.attribute6,
          p_attribute7                => p_ro_service_code_rec.attribute7,
          p_attribute8                => p_ro_service_code_rec.attribute8,
          p_attribute9                => p_ro_service_code_rec.attribute9,
          p_attribute10               => p_ro_service_code_rec.attribute10,
          p_attribute11               => p_ro_service_code_rec.attribute11,
          p_attribute12               => p_ro_service_code_rec.attribute12,
          p_attribute13               => p_ro_service_code_rec.attribute13,
          p_attribute14               => p_ro_service_code_rec.attribute14,
          p_attribute15               => p_ro_service_code_rec.attribute15,
		p_service_item_id		   => p_ro_service_code_rec.service_item_id -- rfieldma, 4666403
 	 );

         x_obj_ver_number := l_obj_ver_num + 1;

       EXCEPTION
          WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_RO_SERVICE_CODES_PKG.Update_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Update_RO_Service_Code');
      END IF;

EXCEPTION
     WHEN CSD_RSC_RO_ID_MISSING THEN
          ROLLBACK TO Update_RO_Service_Code;
            -- Repair line id is missing
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_RO_ID_MISSING to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	    FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	    FND_MESSAGE.SET_TOKEN('MISSING_PARAM','REPAIR_LINE_ID');
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Repair line id is missing');
            END IF;

     WHEN CSD_RSC_SC_ID_MISSING THEN
          ROLLBACK TO Update_RO_Service_Code;
            -- Service code id is missing
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_SC_ID_MISSING to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	    FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	    FND_MESSAGE.SET_TOKEN('MISSING_PARAM','SERVICE_CODE_ID');
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code id is missing');
            END IF;

   WHEN CSD_RSC_SOURCE_TYPE_MISSING THEN
          ROLLBACK TO Update_RO_Service_Code;

          -- RO service code source type is missing
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_SOURCE_TYPE_MISSING to FND_MSG stack');
          end if;
    	  FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	  FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	  FND_MESSAGE.SET_TOKEN('MISSING_PARAM','SOURCE_TYPE_CODE');
	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'RO service code source type is missing');
          END IF;

   WHEN CSD_RSC_APPL_FLAG_MISSING THEN
          ROLLBACK TO Update_RO_Service_Code;

          -- RO service code applicable flag is missing
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_APPL_FLAG_MISSING to FND_MSG stack');
          end if;
    	  FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	  FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	  FND_MESSAGE.SET_TOKEN('MISSING_PARAM','APPLICABLE_FLAG');
	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'RO service code applicable flag is missing');
          END IF;

   WHEN CSD_RSC_APPL_EST_FLAG_MISSING THEN
          ROLLBACK TO Update_RO_Service_Code;

          -- RO service code applied to estimate flag is missing
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_APP_EST_FLAG_MISSING to FND_MSG stack');
          end if;
    	  FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	  FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	  FND_MESSAGE.SET_TOKEN('MISSING_PARAM','APPLIED_TO_EST_FLAG');
	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'RO service code applied to estimate flag is missing');
          END IF;

   WHEN CSD_RSC_APPL_WORK_FLAG_MISSING THEN
          ROLLBACK TO Update_RO_Service_Code;

          -- RO service code applied to work flag is missing
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_APP_WORK_FLAG_MISSING to FND_MSG stack');
          end if;
    	  FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	  FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	  FND_MESSAGE.SET_TOKEN('MISSING_PARAM','APPLIED_TO_WORK_FLAG');
	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'RO service code applied to work flag is missing');
          END IF;

     WHEN CSD_RSC_INVALID_ID THEN
          ROLLBACK TO Update_RO_Service_Code;

          -- RO service code id is invalid
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_INVALID_ID to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_RSC_INVALID_ID');
     	  FND_MESSAGE.SET_TOKEN('RO_SERVICE_CODE_ID',p_ro_service_code_rec.ro_service_code_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'RO service code id is invalid');
          END IF;

     WHEN CSD_RSC_GET_OVN_ERROR THEN
          ROLLBACK TO Update_RO_Service_Code;

          -- RO service code get object version number error
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_GET_OVN_ERROR to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_RSC_GET_OVN_ERROR');
     	  FND_MESSAGE.SET_TOKEN('RO_SERVICE_CODE_ID',p_ro_service_code_rec.ro_service_code_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'RO service code get object version number error');
          END IF;

     WHEN CSD_RSC_OVN_MISMATCH THEN
          ROLLBACK TO Update_RO_Service_Code;

          -- RO service code object version number mismatch
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_RSC_OVN_MISMATCH to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_RSC_OVN_MISMATCH');
     	  FND_MESSAGE.SET_TOKEN('RO_SERVICE_CODE_ID',p_ro_service_code_rec.ro_service_code_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'RO service code object version number mismatch');
          END IF;

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_RO_Service_Code;

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
          ROLLBACK TO Update_RO_Service_Code;

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
          ROLLBACK TO Update_RO_Service_Code;

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

END Update_RO_Service_Code;


/*--------------------------------------------------*/
/* procedure name: Delete_RO_Service_Code           */
/* description   : procedure used to delete         */
/*                 ro service code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_RO_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_service_code_id	 	IN  NUMBER
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_ro_service_codes_pvt.delete_ro_service_code';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Delete_RO_Service_Code';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Delete_RO_Service_Code;

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
              'Entered Delete_RO_Service_Code');
       END IF;

       -- Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Api body starts

       -- Check the required parameters
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Checking required parameter');
       end if;

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_ro_service_code_id,
         p_param_name	  => 'RO_SERVICE_CODE_ID',
         p_api_name	  => lc_api_name);

       -- Delete row
       if (lc_proc_level >= lc_debug_level) then
            FND_LOG.STRING(lc_proc_level, lc_mod_name,
                         'Calling Delete_Row table handler');
       end if;

       BEGIN

         CSD_RO_SERVICE_CODES_PKG.Delete_Row
         (p_ro_service_code_id       => p_ro_service_code_id);

       EXCEPTION
         WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_RO_SERVICE_CODES_PKG.Delete_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
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

      IF (lc_proc_level >= lc_debug_level) THEN
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving Delete_RO_Service_Code');
      END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Delete_RO_Service_Code;

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
          ROLLBACK TO Delete_RO_Service_Code;

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
          ROLLBACK TO Delete_RO_Service_Code;

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

END Delete_RO_Service_Code;

/*--------------------------------------------------*/
/* procedure name: Lock_RO_Service_Code             */
/* description   : procedure used to lock           */
/*                 ro service code	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_RO_Service_Code
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_ro_service_code_rec		IN  RO_SERVICE_CODE_REC_TYPE
)IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_ro_service_codes_pvt.lock_ro_service_code';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Lock_RO_Service_Code';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Lock_RO_Service_Code;

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
                'Entered Lock_RO_Service_Code');
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
       ( p_param_value	  => p_ro_service_code_rec.ro_service_code_id,
         p_param_name	  => 'RO_SERVICE_CODE_ID',
         p_api_name	  => lc_api_name);

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_ro_service_code_rec.object_version_number,
         p_param_name	  => 'OBJECT_VERSION_NUMBER',
         p_api_name	  => lc_api_name);

       -- Lock row
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling Lock_Row table handler');
       end if;

       BEGIN

         CSD_RO_SERVICE_CODES_PKG.Lock_Row
         (p_ro_service_code_id       => p_ro_service_code_rec.ro_service_code_id,
          p_object_version_number     => p_ro_service_code_rec.object_version_number

          --commented out the rest of the record
          /*,
          p_repair_line_id            => p_ro_service_code_rec.repair_line_id,
          p_service_code_id           => p_ro_service_code_rec.service_code_id,
          p_created_by                => null,
          p_creation_date             => null,
          p_last_updated_by           => null,
          p_last_update_date          => null,
          p_last_update_login         => null,
          p_source_type_code          => p_ro_service_code_rec.source_type_code,
          p_source_solution_id        => p_ro_service_code_rec.source_solution_id,
          p_applicable_flag  	      => p_ro_service_code_rec.applicable_flag,
          p_applied_to_est_flag       => null,
          p_applied_to_work_flag      => null,
          p_attribute_category        => p_ro_service_code_rec.attribute_category,
          p_attribute1                => p_ro_service_code_rec.attribute1,
          p_attribute2                => p_ro_service_code_rec.attribute2,
          p_attribute3                => p_ro_service_code_rec.attribute3,
          p_attribute4                => p_ro_service_code_rec.attribute4,
          p_attribute5                => p_ro_service_code_rec.attribute5,
          p_attribute6                => p_ro_service_code_rec.attribute6,
          p_attribute7                => p_ro_service_code_rec.attribute7,
          p_attribute8                => p_ro_service_code_rec.attribute8,
          p_attribute9                => p_ro_service_code_rec.attribute9,
          p_attribute10               => p_ro_service_code_rec.attribute10,
          p_attribute11               => p_ro_service_code_rec.attribute11,
          p_attribute12               => p_ro_service_code_rec.attribute12,
          p_attribute13               => p_ro_service_code_rec.attribute13,
          p_attribute14               => p_ro_service_code_rec.attribute14,
          p_attribute15               => p_ro_service_code_rec.attribute15
          */
          --
 	);

       EXCEPTION
          WHEN OTHERS THEN
             IF ( lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_RO_SERVICE_CODES_PKG.Lock_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Lock_RO_Service_Code');
      END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Lock_RO_Service_Code;

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
          ROLLBACK TO Lock_RO_Service_Code;

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
          ROLLBACK TO Lock_RO_Service_Code;

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

END Lock_RO_Service_Code;

End CSD_RO_SERVICE_CODES_PVT;

/
