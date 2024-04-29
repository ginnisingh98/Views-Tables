--------------------------------------------------------
--  DDL for Package Body CSD_SC_WORK_ENTITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_SC_WORK_ENTITIES_PVT" as
/* $Header: csdvscwb.pls 115.6 2004/02/07 02:36:21 gilam noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_SC_WORK_ENTITIES_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvscwb.pls';

g_bom_type    CONSTANT VARCHAR2(30)   := 'BOM';
g_task_type   CONSTANT VARCHAR2(30)   := 'TASK';

/*--------------------------------------------------*/
/* procedure name: Create_SC_Work_Entity            */
/* description   : procedure used to create         */
/*                 sc work entity	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_SC_Work_Entity
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_work_entity_rec	 	IN  SC_WORK_ENTITY_REC_TYPE,
  x_sc_work_entity_id 		OUT NOCOPY NUMBER
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_sc_work_entities_pvt.create_sc_work_entity';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Create_SC_Work_Entity';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	          VARCHAR2(1)		  := null;
 l_obj_ver_num		  NUMBER		  := 1;

-- EXCEPTIONS --
 CSD_SCW_ENTITY_EXISTS			EXCEPTION;
 CSD_SCW_INVALID_ORGANIZATION		EXCEPTION;
 CSD_SCW_INVALID_BILL_SEQUENCE		EXCEPTION;
 CSD_SCW_INVALID_ROUTE_SEQUENCE		EXCEPTION;
 CSD_SCW_INVALID_TASK_TEMP_GRP		EXCEPTION;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Create_SC_Work_Entity;

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
              'Entered Create_SC_Work_Entity');
       END IF;

       -- log parameters
       IF (lc_stat_level >= lc_debug_level) THEN
	   csd_gen_utility_pvt.dump_sc_work_entity_rec
           ( p_sc_work_entity_rec => p_sc_work_entity_rec);
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
       ( p_param_value	  => p_sc_work_entity_rec.service_code_id,
         p_param_name	  => 'SERVICE_CODE_ID',
         p_api_name	  => lc_api_name);

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_sc_work_entity_rec.work_entity_type_code,
         p_param_name	  => 'WORK_ENTITY_TYPE_CODE',
         p_api_name	  => lc_api_name);

       -- Validate the work entity for service code
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate if the service code work entity already exists');
       end if;

       -- Validate the work entity for service code
       Begin
         l_dummy := null;

         select 'X'
         into l_dummy
         from csd_sc_work_entities
	 where service_code_id = p_sc_work_entity_rec.service_code_id
	 and (work_entity_type_code = p_sc_work_entity_rec.work_entity_type_code
	 and  nvl(work_entity_id1, -999) = nvl(p_sc_work_entity_rec.work_entity_id1, -999)
	 and  nvl(work_entity_id2, -999) = nvl(p_sc_work_entity_rec.work_entity_id2, -999)
	 and  nvl(work_entity_id3, -999) = nvl(p_sc_work_entity_rec.work_entity_id3, -999));

       Exception

    	WHEN no_data_found THEN
	  null;

        WHEN others THEN
          l_dummy := 'X';

       End;

       -- If entity exists, throw an error
       IF (l_dummy = 'X') then
           RAISE CSD_SCW_ENTITY_EXISTS;
        ELSE
           if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Service code work entity does not exist');
           end if;
       END IF;

       -- Validate the organization id
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the organization id');
       end if;

       -- Validate the organization id
       Begin

        l_dummy := null;

        If (p_sc_work_entity_rec.work_entity_type_code = g_bom_type
        and p_sc_work_entity_rec.work_entity_id3 is not null) then
         select 'X'
         into l_dummy
         from org_organization_definitions
	 where organization_id = p_sc_work_entity_rec.work_entity_id3;
	End if;

       Exception

         WHEN others THEN
           null;

       End;

       -- If organization does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_SCW_INVALID_ORGANIZATION;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Org for service code work entity is valid');
          end if;
       END IF;

       -- Validate the bill sequence id
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the bill sequence id');
       end if;

       -- Validate the bill sequence id
       Begin

        l_dummy := null;

        If (p_sc_work_entity_rec.work_entity_type_code = g_bom_type
        and p_sc_work_entity_rec.work_entity_id1 is not null) then
         select 'X'
         into l_dummy
         from bom_bill_of_materials
	 where bill_sequence_id = p_sc_work_entity_rec.work_entity_id1;
	End if;

       Exception

         WHEN others THEN
           null;

       End;

       -- If bill sequence does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_SCW_INVALID_BILL_SEQUENCE;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Bill reference for service code work entity is valid');
          end if;
       END IF;

       -- Validate the routing sequence id
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the routing sequence id');
       end if;

       -- Validate the routing sequence id
       Begin

        l_dummy := null;

        If (p_sc_work_entity_rec.work_entity_type_code = g_bom_type
        and p_sc_work_entity_rec.work_entity_id2 is not null) then
         select 'X'
         into l_dummy
         from bom_operational_routings
	 where routing_sequence_id = p_sc_work_entity_rec.work_entity_id2;
	End if;

       Exception

         WHEN others THEN
           null;

       End;

       -- If bill sequence does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_SCW_INVALID_ROUTE_SEQUENCE;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Routing reference for service code work entity is valid');
          end if;
       END IF;

       -- Validate the task template group id
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the task template group id');
       end if;

       -- Validate the task template group id
       Begin

        l_dummy := null;

        If (p_sc_work_entity_rec.work_entity_type_code = g_task_type
        and p_sc_work_entity_rec.work_entity_id1 is not null) then
         select 'X'
         into l_dummy
         from jtf_task_temp_groups_vl
	 where task_template_group_id = p_sc_work_entity_rec.work_entity_id1;
	End if;

       Exception

         WHEN others THEN
           null;

       End;

       -- If task template group does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_SCW_INVALID_TASK_TEMP_GRP;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Task template group for service code work entity is valid');
          end if;
       END IF;

       -- Insert row
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling Insert_Row table handler');
       end if;

       BEGIN

         -- Insert the new work entity
         CSD_SC_WORK_ENTITIES_PKG.Insert_Row
         (px_sc_work_entity_id 	      => x_sc_work_entity_id,
          p_object_version_number     => l_obj_ver_num,
          p_service_code_id           => p_sc_work_entity_rec.service_code_id,
          p_work_entity_id1           => p_sc_work_entity_rec.work_entity_id1,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID,
          p_work_entity_type_code     => p_sc_work_entity_rec.work_entity_type_code,
          p_work_entity_id2  	      => p_sc_work_entity_rec.work_entity_id2,
          p_work_entity_id3  	      => p_sc_work_entity_rec.work_entity_id3,
          p_attribute_category        => p_sc_work_entity_rec.attribute_category,
          p_attribute1                => p_sc_work_entity_rec.attribute1,
          p_attribute2                => p_sc_work_entity_rec.attribute2,
          p_attribute3                => p_sc_work_entity_rec.attribute3,
          p_attribute4                => p_sc_work_entity_rec.attribute4,
          p_attribute5                => p_sc_work_entity_rec.attribute5,
          p_attribute6                => p_sc_work_entity_rec.attribute6,
          p_attribute7                => p_sc_work_entity_rec.attribute7,
          p_attribute8                => p_sc_work_entity_rec.attribute8,
          p_attribute9                => p_sc_work_entity_rec.attribute9,
          p_attribute10               => p_sc_work_entity_rec.attribute10,
          p_attribute11               => p_sc_work_entity_rec.attribute11,
          p_attribute12               => p_sc_work_entity_rec.attribute12,
          p_attribute13               => p_sc_work_entity_rec.attribute13,
          p_attribute14               => p_sc_work_entity_rec.attribute14,
          p_attribute15               => p_sc_work_entity_rec.attribute15
 	);

       EXCEPTION
          WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_SC_WORK_ENTITIES_PKG.Insert_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Create_SC_Work_Entity');
      END IF;

EXCEPTION
     WHEN CSD_SCW_ENTITY_EXISTS THEN
          ROLLBACK TO Create_SC_Work_Entity;

            -- Service code work entity already exists
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_ENTITY_EXISTS to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_ENTITY_EXISTS');
	    FND_MESSAGE.SET_TOKEN('SERVICE_CODE_ID',p_sc_work_entity_rec.service_code_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity already exists');
            END IF;

     WHEN CSD_SCW_INVALID_ORGANIZATION THEN
          ROLLBACK TO Create_SC_Work_Entity;

            -- Service code work entity organization is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_INVALID_ORGANIZATION to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_INVALID_ORGANIZATION');
	    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_sc_work_entity_rec.work_entity_id3);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity organization is invalid');
            END IF;

     WHEN CSD_SCW_INVALID_BILL_SEQUENCE THEN
          ROLLBACK TO Create_SC_Work_Entity;

            -- Service code work entity bill reference is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_INVALID_BILL_SEQUENCE to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_INVALID_BILL_SEQUENCE');
	    FND_MESSAGE.SET_TOKEN('BILL_SEQUENCE_ID',p_sc_work_entity_rec.work_entity_id1);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity bill reference is invalid');
            END IF;

     WHEN CSD_SCW_INVALID_ROUTE_SEQUENCE THEN
          ROLLBACK TO Create_SC_Work_Entity;

            -- Service code work entity routing reference is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_INVALID_ROUTE_SEQUENCE to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_INVALID_ROUTE_SEQUENCE');
	    FND_MESSAGE.SET_TOKEN('ROUTING_SEQUENCE_ID',p_sc_work_entity_rec.work_entity_id2);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity routing reference is invalid');
            END IF;

     WHEN CSD_SCW_INVALID_TASK_TEMP_GRP THEN
          ROLLBACK TO Create_SC_Work_Entity;

            -- Service code work entity task template group is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_INVALID_TASK_TEMP_GRP to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_INVALID_TASK_TEMP_GRP');
	    FND_MESSAGE.SET_TOKEN('TASK_TEMP_GROUP_ID',p_sc_work_entity_rec.work_entity_id1);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity task template group is invalid');
            END IF;

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_SC_Work_Entity;

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
          ROLLBACK TO Create_SC_Work_Entity;

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
          ROLLBACK TO Create_SC_Work_Entity;

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

END Create_SC_Work_Entity;


/*--------------------------------------------------*/
/* procedure name: Update_SC_Work_Entity            */
/* description   : procedure used to update         */
/*                 sc work entity	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_SC_Work_Entity
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_work_entity_rec	 	IN  SC_WORK_ENTITY_REC_TYPE,
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
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_sc_work_entities_pvt.update_sc_work_entity';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Update_SC_Work_Entity';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	          VARCHAR2(1)		  := null;
 l_obj_ver_num		  NUMBER		  := 1;

-- EXCEPTIONS --
 CSD_SCW_SC_ID_MISSING			EXCEPTION;
 CSD_SCW_ENTITY_TYPE_MISSING		EXCEPTION;
 CSD_SCW_INVALID_ID			EXCEPTION;
 CSD_SCW_GET_OVN_ERROR			EXCEPTION;
 CSD_SCW_OVN_MISMATCH			EXCEPTION;
 CSD_SCW_ENTITY_EXISTS			EXCEPTION;
 CSD_SCW_INVALID_ORGANIZATION		EXCEPTION;
 CSD_SCW_INVALID_BILL_SEQUENCE		EXCEPTION;
 CSD_SCW_INVALID_ROUTE_SEQUENCE		EXCEPTION;
 CSD_SCW_INVALID_TASK_TEMP_GRP		EXCEPTION;

BEGIN

       -- Standard Start of API savepoint
       SAVEPOINT  Update_SC_Work_Entity;

       -- Standard call to check for call compatibility.
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
              'Entered Update_SC_Work_Entity');
       END IF;

       -- log parameters
       IF (lc_stat_level >= lc_debug_level) THEN
	   csd_gen_utility_pvt.dump_sc_work_entity_rec
           ( p_sc_work_entity_rec => p_sc_work_entity_rec);
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
       ( p_param_value	  => p_sc_work_entity_rec.sc_work_entity_id,
         p_param_name	  => 'SC_WORK_ENTITY_ID',
         p_api_name	  => lc_api_name);

       -- Check if required parameter is passed in as G_MISS
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Checking if required parameters are passed in as G_MISS');
       end if;

       -- Check if required parameter is passed in as G_MISS
       IF (p_sc_work_entity_rec.service_code_id = FND_API.G_MISS_NUM) THEN
	RAISE CSD_SCW_SC_ID_MISSING;
       END IF;

       -- Check if required parameter is passed in as G_MISS
       IF (p_sc_work_entity_rec.work_entity_type_code = FND_API.G_MISS_CHAR) THEN
	RAISE CSD_SCW_ENTITY_TYPE_MISSING;
       END IF;

       -- Validate the work entity for service code
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the id for service code work entity');
       end if;

       -- Validate the id for service code work entity
       Begin
          l_dummy := null;

          select 'X'
          into l_dummy
          from csd_sc_work_entities
 	  where sc_work_entity_id = p_sc_work_entity_rec.sc_work_entity_id;

       Exception

         WHEN others THEN
           null;

       End;

       -- If service code work entity does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_SCW_INVALID_ID;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Service code work entity is valid');
          end if;
       END IF;

       -- Get the object version number for service code
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Get object version number for service code work entity');
       end if;

       -- Get object version number for service code work_entity
       Begin
          select object_version_number
          into l_obj_ver_num
          from csd_sc_work_entities
          where sc_work_entity_id = p_sc_work_entity_rec.sc_work_entity_id;

       Exception

         WHEN others THEN
    	   l_obj_ver_num := null;

       End;

       -- If no object version number, throw an error
       IF (l_obj_ver_num is null) then
          RAISE CSD_SCW_GET_OVN_ERROR;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Retrieved object version number');
          end if;
       END IF;

       -- Validate the object version number for service code work entity
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Validate object version number for service code work entity');
       end if;

       -- Validate if object version number for service code work_entity is same as the one passed in
       IF NVL(p_sc_work_entity_rec.object_version_number,FND_API.G_MISS_NUM) <> l_obj_ver_num  THEN
          RAISE CSD_SCW_OVN_MISMATCH;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Object version number is valid');
          end if;
       END IF;

       -- Validate the work entity for service code
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate if the service code work entity already exists');
       end if;

       -- Validate the work entity for service code
       Begin

         l_dummy := null;

         select 'X'
         into l_dummy
         from csd_sc_work_entities
	 where sc_work_entity_id <> p_sc_work_entity_rec.sc_work_entity_id
	 and service_code_id = p_sc_work_entity_rec.service_code_id
	 and (work_entity_type_code = p_sc_work_entity_rec.work_entity_type_code
	 and  nvl(work_entity_id1, -999) = nvl(p_sc_work_entity_rec.work_entity_id1, -999)
	 and  nvl(work_entity_id2, -999) = nvl(p_sc_work_entity_rec.work_entity_id2, -999)
	 and  nvl(work_entity_id3, -999) = nvl(p_sc_work_entity_rec.work_entity_id3, -999));

       Exception

    	WHEN no_data_found THEN
	  null;

        WHEN others THEN
          l_dummy := 'X';

       End;

       -- If entity exists, throw an error
       IF (l_dummy = 'X') then
           RAISE CSD_SCW_ENTITY_EXISTS;
        ELSE
           if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Service code work entity does not exist');
           end if;
       END IF;

       -- Validate the organization id
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the organization id');
       end if;

       -- Validate the organization id
       Begin

        l_dummy := null;

        If (p_sc_work_entity_rec.work_entity_type_code = g_bom_type
        and p_sc_work_entity_rec.work_entity_id3 is not null) then
         select 'X'
         into l_dummy
         from org_organization_definitions
	 where organization_id = p_sc_work_entity_rec.work_entity_id3;
	End if;

       Exception

         WHEN others THEN
           null;

       End;

       -- If organization does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_SCW_INVALID_ORGANIZATION;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Org for service code work entity is valid');
          end if;
       END IF;

       -- Validate the bill sequence id
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the bill sequence id');
       end if;

       -- Validate the bill sequence id
       Begin

        l_dummy := null;

        If (p_sc_work_entity_rec.work_entity_type_code = g_bom_type
        and p_sc_work_entity_rec.work_entity_id1 is not null) then
         select 'X'
         into l_dummy
         from bom_bill_of_materials
	 where bill_sequence_id = p_sc_work_entity_rec.work_entity_id1;
	End if;

       Exception

         WHEN others THEN
           null;

       End;

       -- If bill sequence does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_SCW_INVALID_BILL_SEQUENCE;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Bill reference for service code work entity is valid');
          end if;
       END IF;

       -- Validate the routing sequence id
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the routing sequence id');
       end if;

       -- Validate the routing sequence id
       Begin

        l_dummy := null;

        If (p_sc_work_entity_rec.work_entity_type_code = g_bom_type
        and p_sc_work_entity_rec.work_entity_id2 is not null) then
         select 'X'
         into l_dummy
         from bom_operational_routings
	 where routing_sequence_id = p_sc_work_entity_rec.work_entity_id2;
	End if;

       Exception

         WHEN others THEN
           null;

       End;

       -- If bill sequence does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_SCW_INVALID_ROUTE_SEQUENCE;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Routing reference for service code work entity is valid');
          end if;
       END IF;

       -- Validate the task template group id
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the task template group id');
       end if;

       -- Validate the task template group id
       Begin

        l_dummy := null;

        If (p_sc_work_entity_rec.work_entity_type_code = g_task_type
        and p_sc_work_entity_rec.work_entity_id1 is not null) then
         select 'X'
         into l_dummy
         from jtf_task_temp_groups_vl
	 where task_template_group_id = p_sc_work_entity_rec.work_entity_id1;
	End if;

       Exception

         WHEN others THEN
           null;

       End;

       -- If task template group does not exist, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_SCW_INVALID_TASK_TEMP_GRP;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Task template group for service code work entity is valid');
          end if;
       END IF;

        -- Update row
        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling Update_Row table handler');
       end if;

       BEGIN

         -- Update the sc work entity
         CSD_SC_WORK_ENTITIES_PKG.Update_Row
         (p_sc_work_entity_id 	      => p_sc_work_entity_rec.sc_work_entity_id,
          p_object_version_number     => l_obj_ver_num + 1,
          p_service_code_id           => p_sc_work_entity_rec.service_code_id,
          p_work_entity_id1           => p_sc_work_entity_rec.work_entity_id1,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID,
          p_work_entity_type_code     => p_sc_work_entity_rec.work_entity_type_code,
          p_work_entity_id2  	      => p_sc_work_entity_rec.work_entity_id2,
          p_work_entity_id3  	      => p_sc_work_entity_rec.work_entity_id3,
          p_attribute_category        => p_sc_work_entity_rec.attribute_category,
          p_attribute1                => p_sc_work_entity_rec.attribute1,
          p_attribute2                => p_sc_work_entity_rec.attribute2,
          p_attribute3                => p_sc_work_entity_rec.attribute3,
          p_attribute4                => p_sc_work_entity_rec.attribute4,
          p_attribute5                => p_sc_work_entity_rec.attribute5,
          p_attribute6                => p_sc_work_entity_rec.attribute6,
          p_attribute7                => p_sc_work_entity_rec.attribute7,
          p_attribute8                => p_sc_work_entity_rec.attribute8,
          p_attribute9                => p_sc_work_entity_rec.attribute9,
          p_attribute10               => p_sc_work_entity_rec.attribute10,
          p_attribute11               => p_sc_work_entity_rec.attribute11,
          p_attribute12               => p_sc_work_entity_rec.attribute12,
          p_attribute13               => p_sc_work_entity_rec.attribute13,
          p_attribute14               => p_sc_work_entity_rec.attribute14,
          p_attribute15               => p_sc_work_entity_rec.attribute15
 	 );

         x_obj_ver_number := l_obj_ver_num + 1;

       EXCEPTION
          WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_SC_WORK_ENTITIES_PKG.Update_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Update_SC_Work_Entity');
      END IF;

EXCEPTION

     WHEN CSD_SCW_SC_ID_MISSING THEN
          ROLLBACK TO Update_SC_Work_Entity;
            -- Service code id is missing
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_SC_ID_MISSING to FND_MSG stack');
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

   WHEN CSD_SCW_ENTITY_TYPE_MISSING THEN
          ROLLBACK TO Update_SC_Work_Entity;

          -- Service code work entity type is missing
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_ENTITY_TYPE_MISSING to FND_MSG stack');
          end if;
    	  FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	  FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	  FND_MESSAGE.SET_TOKEN('MISSING_PARAM','WORK_ENTITY_TYPE_CODE');
	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity type is missing');
          END IF;

     WHEN CSD_SCW_INVALID_ID THEN
          ROLLBACK TO Update_SC_Work_Entity;

          -- Service code work entity id is invalid
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_INVALID_ID to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_SCW_INVALID_ID');
     	  FND_MESSAGE.SET_TOKEN('SC_WORK_ENTITY_ID',p_sc_work_entity_rec.sc_work_entity_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity id is invalid');
          END IF;

     WHEN CSD_SCW_GET_OVN_ERROR THEN
          ROLLBACK TO Update_SC_Work_Entity;

          -- Service code work entity get object version number error
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_GET_OVN_ERROR to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_SCW_GET_OVN_ERROR');
     	  FND_MESSAGE.SET_TOKEN('SC_WORK_ENTITY_ID',p_sc_work_entity_rec.sc_work_entity_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity get object version number error');
          END IF;

     WHEN CSD_SCW_OVN_MISMATCH THEN
          ROLLBACK TO Update_SC_Work_Entity;

          -- Service code work entity object version number mismatch
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_OVN_MISMATCH to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_SCW_OVN_MISMATCH');
     	  FND_MESSAGE.SET_TOKEN('SC_WORK_ENTITY_ID',p_sc_work_entity_rec.sc_work_entity_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity object version number mismatch');
          END IF;

     WHEN CSD_SCW_ENTITY_EXISTS THEN
          ROLLBACK TO Update_SC_Work_Entity;

            -- Service code work entity already exists
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_ENTITY_EXISTS to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_ENTITY_EXISTS');
	    FND_MESSAGE.SET_TOKEN('SERVICE_CODE_ID',p_sc_work_entity_rec.service_code_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity already exists');
            END IF;

     WHEN CSD_SCW_INVALID_ORGANIZATION THEN
          ROLLBACK TO Update_SC_Work_Entity;

            -- Service code work entity organization is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_INVALID_ORGANIZATION to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_INVALID_ORGANIZATION');
	    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_sc_work_entity_rec.work_entity_id3);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity organization is invalid');
            END IF;

     WHEN CSD_SCW_INVALID_BILL_SEQUENCE THEN
          ROLLBACK TO Update_SC_Work_Entity;

            -- Service code work entity bill reference is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_INVALID_BILL_SEQUENCE to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_INVALID_BILL_SEQUENCE');
	    FND_MESSAGE.SET_TOKEN('BILL_SEQUENCE_ID',p_sc_work_entity_rec.work_entity_id1);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity bill reference is invalid');
            END IF;

     WHEN CSD_SCW_INVALID_ROUTE_SEQUENCE THEN
          ROLLBACK TO Update_SC_Work_Entity;

            -- Service code work entity routing reference is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_INVALID_ROUTE_SEQUENCE to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_INVALID_ROUTE_SEQUENCE');
	    FND_MESSAGE.SET_TOKEN('ROUTING_SEQUENCE_ID',p_sc_work_entity_rec.work_entity_id2);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity routing reference is invalid');
            END IF;

     WHEN CSD_SCW_INVALID_TASK_TEMP_GRP THEN
          ROLLBACK TO Update_SC_Work_Entity;

            -- Service code work entity task template group is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_SCW_INVALID_TASK_TEMP_GRP to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_SCW_INVALID_TASK_TEMP_GRP');
	    FND_MESSAGE.SET_TOKEN('TASK_TEMP_GROUP_ID',p_sc_work_entity_rec.work_entity_id1);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Service code work entity task template group is invalid');
            END IF;

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_SC_Work_Entity;

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
          ROLLBACK TO Update_SC_Work_Entity;

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
          ROLLBACK TO Update_SC_Work_Entity;

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

END Update_SC_Work_Entity;

/*--------------------------------------------------*/
/* procedure name: Delete_SC_Work_Entity            */
/* description   : procedure used to delete         */
/*                 sc work entity	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_SC_Work_Entity
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_work_entity_id	 	IN  NUMBER
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_sc_work_entities_pvt.delete_sc_work_entity';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Delete_SC_Work_Entity';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Delete_SC_Work_Entity;

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
                'Entered Delete_SC_Work_Entity');
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
       ( p_param_value	  => p_sc_work_entity_id,
         p_param_name	  => 'SC_WORK_ENTITY_ID',
         p_api_name	  => lc_api_name);

       -- Delete row
       if (lc_proc_level >= lc_debug_level) then
            FND_LOG.STRING(lc_proc_level, lc_mod_name,
                         'Calling Delete_Row table handler');
       end if;

       BEGIN

         -- Delete the work entity
         CSD_SC_WORK_ENTITIES_PKG.Delete_Row
         (p_sc_work_entity_id 	      => p_sc_work_entity_id	);

       EXCEPTION
         WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_SC_WORK_ENTITIES_PKG.Delete_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Delete_SC_Work_Entity');
      END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Delete_SC_Work_Entity;

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
          ROLLBACK TO Delete_SC_Work_Entity;

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
          ROLLBACK TO Delete_SC_Work_Entity;

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

END Delete_SC_Work_Entity;

/*--------------------------------------------------*/
/* procedure name: Lock_SC_Work_Entity              */
/* description   : procedure used to lock           */
/*                 sc work entity	            */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_SC_Work_Entity
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_sc_work_entity_rec		IN  SC_WORK_ENTITY_REC_TYPE
)IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_sc_work_entities_pvt.lock_sc_work_entity';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Lock_SC_Work_Entity';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Lock_SC_Work_Entity;

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
                'Entered Lock_SC_Work_Entity');
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
       ( p_param_value	  => p_sc_work_entity_rec.sc_work_entity_id,
         p_param_name	  => 'SC_WORK_ENTITY_ID',
         p_api_name	  => lc_api_name);

        -- Check the required parameter
        CSD_PROCESS_UTIL.Check_Reqd_Param
        ( p_param_value	  => p_sc_work_entity_rec.object_version_number,
          p_param_name	  => 'OBJECT_VERSION_NUMBER',
          p_api_name	  => lc_api_name);

       -- Lock row
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling Lock_Row table handler');
       end if;

       BEGIN

         -- Lock the work entity
         CSD_SC_WORK_ENTITIES_PKG.Lock_Row
         (p_sc_work_entity_id 	      => p_sc_work_entity_rec.sc_work_entity_id,
          p_object_version_number     => p_sc_work_entity_rec.object_version_number

          --commented out the rest of the record
          /*,
          p_service_code_id           => p_sc_work_entity_rec.service_code_id,
          p_work_entity_id1           => p_sc_work_entity_rec.work_entity_id1,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID,
          p_work_entity_type_code     => p_sc_work_entity_rec.work_entity_type_code,
          p_work_entity_id2  	      => p_sc_work_entity_rec.work_entity_id2,
          p_work_entity_id3  	      => p_sc_work_entity_rec.work_entity_id3,
          p_attribute_category        => p_sc_work_entity_rec.attribute_category,
          p_attribute1                => p_sc_work_entity_rec.attribute1,
          p_attribute2                => p_sc_work_entity_rec.attribute2,
          p_attribute3                => p_sc_work_entity_rec.attribute3,
          p_attribute4                => p_sc_work_entity_rec.attribute4,
          p_attribute5                => p_sc_work_entity_rec.attribute5,
          p_attribute6                => p_sc_work_entity_rec.attribute6,
          p_attribute7                => p_sc_work_entity_rec.attribute7,
          p_attribute8                => p_sc_work_entity_rec.attribute8,
          p_attribute9                => p_sc_work_entity_rec.attribute9,
          p_attribute10               => p_sc_work_entity_rec.attribute10,
          p_attribute11               => p_sc_work_entity_rec.attribute11,
          p_attribute12               => p_sc_work_entity_rec.attribute12,
          p_attribute13               => p_sc_work_entity_rec.attribute13,
          p_attribute14               => p_sc_work_entity_rec.attribute14,
          p_attribute15               => p_sc_work_entity_rec.attribute15
          */
          --
 	 );

       EXCEPTION
          WHEN OTHERS THEN
             IF ( lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_SC_WORK_ENTITIES_PKG.Lock_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Lock_SC_Domain');
      END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Lock_SC_Work_Entity;

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
          ROLLBACK TO Lock_SC_Work_Entity;

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
          ROLLBACK TO Lock_SC_Work_Entity;

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

END Lock_SC_Work_Entity;

End CSD_SC_WORK_ENTITIES_PVT;


/
