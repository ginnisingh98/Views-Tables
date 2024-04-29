--------------------------------------------------------
--  DDL for Package Body CSD_DC_DOMAINS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_DC_DOMAINS_PVT" as
/* $Header: csdvdcdb.pls 115.5 2004/02/16 03:20:48 gilam noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_DC_DOMAINS_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvdcdb.pls';

/*--------------------------------------------------*/
/* procedure name: Create_DC_Domain                 */
/* description   : procedure used to create         */
/*                 dc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Create_DC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_dc_domain_rec	 	IN  DC_DOMAIN_REC_TYPE,
  x_dc_domain_id 		OUT NOCOPY NUMBER
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_diagnostic_codes_pvt.create_dc_domain';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Create_DC_Domain';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(32767);
 l_msg_index              NUMBER;
 l_obj_ver_num		  NUMBER		  := 1;
 l_dummy	          VARCHAR2(1)		  := null;
 l_valid_cat_flag	  VARCHAR2(1)		  := null;
 l_inventory_item_id	  NUMBER		  := null;
 l_category_id		  NUMBER		  := null;
 l_category_set_id	  NUMBER		  := null;

-- EXCEPTIONS --
 CSD_DCD_ITEM_MISSING	  	EXCEPTION;
 CSD_DCD_CATEGORY_SET_MISSING	EXCEPTION;
 CSD_DCD_CATEGORY_MISSING	EXCEPTION;
 CSD_DCD_DOMAIN_EXISTS	  	EXCEPTION;
 CSD_DCD_INVALID_ITEM	  	EXCEPTION;
 CSD_DCD_INVALID_CAT_SET  	EXCEPTION;
 CSD_DCD_INVALID_CATSET_FLAG 	EXCEPTION;
 CSD_DCD_INVALID_CATEGORY	EXCEPTION;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Create_DC_Domain;

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
              'Entered Create_DC_Domain');
       END IF;

       -- log parameters
       IF (lc_stat_level >= lc_debug_level) THEN
	   csd_gen_utility_pvt.dump_dc_domain_rec
           ( p_dc_domain_rec => p_dc_domain_rec);
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
       ( p_param_value	  => p_dc_domain_rec.diagnostic_code_id,
         p_param_name	  => 'DIAGNOSTIC_CODE_ID',
         p_api_name	  => lc_api_name);

       -- Check the required parameter
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_dc_domain_rec.domain_type_code,
         p_param_name	  => 'DOMAIN_TYPE_CODE',
         p_api_name	  => lc_api_name);

       -- Check if required parameter is passed in as G_MISS
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Checking if required parameters are passed in as G_MISS');
       end if;

       -- Check if required parameter is passed in as G_MISS
       IF (p_dc_domain_rec.domain_type_code = 'ITEM'
       and (p_dc_domain_rec.inventory_item_id = FND_API.G_MISS_NUM
       or   p_dc_domain_rec.inventory_item_id is null)) THEN
	RAISE CSD_DCD_ITEM_MISSING;
       END IF;

       -- Check if required parameter is passed in as G_MISS
       IF (p_dc_domain_rec.domain_type_code = 'CAT') THEN
          IF (p_dc_domain_rec.category_set_id = FND_API.G_MISS_NUM
           or p_dc_domain_rec.category_set_id is null) THEN
	    RAISE CSD_DCD_CATEGORY_SET_MISSING;
          END IF;
          IF (p_dc_domain_rec.category_id = FND_API.G_MISS_NUM
           or p_dc_domain_rec.category_id is null) THEN
	    RAISE CSD_DCD_CATEGORY_MISSING;
          END IF;
       END IF;

       -- Validate the domain for diagnostic code
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate if the diagnostic code domain already exists');
       end if;

       Begin
         l_dummy := null;

         /* gilam: bug 3445684 - changed query to include service code id in the each or condition
         select 'X'
         into l_dummy
         from csd_dc_domains
	 where diagnostic_code_id = p_dc_domain_rec.diagnostic_code_id
	 and (domain_type_code = p_dc_domain_rec.domain_type_code
	 and inventory_item_id = p_dc_domain_rec.inventory_item_id)
         or (domain_type_code = p_dc_domain_rec.domain_type_code
         and category_set_id = p_dc_domain_rec.category_set_id
         and category_id = p_dc_domain_rec.category_id);
         */
         select 'X'
         into l_dummy
         from csd_dc_domains
	 where (diagnostic_code_id = p_dc_domain_rec.diagnostic_code_id
	 and domain_type_code = p_dc_domain_rec.domain_type_code
	 and inventory_item_id = p_dc_domain_rec.inventory_item_id)
         or (diagnostic_code_id = p_dc_domain_rec.diagnostic_code_id
         and domain_type_code = p_dc_domain_rec.domain_type_code
         and category_set_id = p_dc_domain_rec.category_set_id
         and category_id = p_dc_domain_rec.category_id);
         -- gilam: end bug fix 3445684

       Exception

    	WHEN no_data_found THEN
	  null;

        WHEN others THEN
          l_dummy := 'X';

       End;

       -- If domain already exists, throw an error
       IF (l_dummy = 'X') then
          RAISE CSD_DCD_DOMAIN_EXISTS;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Diagnostic code domain does not exist');
          end if;
       END IF;


       -- Validate the inventory item id if domain is ITEM
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the inventory item id if domain is ITEM');
       end if;

       IF (p_dc_domain_rec.domain_type_code = 'ITEM') then
         Begin
           l_dummy := null;

           select 'X'
           into l_dummy
           from mtl_system_items_kfv
           where organization_id = cs_std.get_item_valdn_orgzn_id
           and inventory_item_id = p_dc_domain_rec.inventory_item_id;

         Exception

           WHEN others THEN
             null;

         End;

         -- If item does not exist, throw an error
         IF (l_dummy <> 'X') then
           RAISE CSD_DCD_INVALID_ITEM;
         ELSE
           if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Item for diagnostic code domain is valid');
           end if;
         END IF;
       END IF;  -- if domain type is ITEM

       -- Validate the category set id and category id if domain is CATEGORY

       -- If domain is CATEGORY
       IF (p_dc_domain_rec.domain_type_code = 'CAT' ) THEN

         -- Validate the category set id if domain is CAT
         if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the category set id if domain is CATEGORY');
         end if;

         Begin
           l_dummy := null;

           select 'X'
           into l_dummy
           from mtl_category_sets_vl
           where category_set_id = p_dc_domain_rec.category_set_id;

         Exception

           WHEN others THEN
             null;

         End;

         -- If category set does not exist, throw an error
         IF (l_dummy <> 'X') then
           RAISE CSD_DCD_INVALID_CAT_SET;
         ELSE
           if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Category set for diagnostic code domain is valid');
           end if;
         END IF;

         -- Get the validate flag for the category set
         if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Get the validate flag for the category set');
         end if;

         Begin
           select validate_flag
           into l_valid_cat_flag
           from mtl_category_sets_vl
           where category_set_id = p_dc_domain_rec.category_set_id;

         Exception

           WHEN others THEN
             null;

         End;

         -- If category set does not exist, throw an error
         IF (l_valid_cat_flag is null) then
           RAISE CSD_DCD_INVALID_CATSET_FLAG;
         ELSE
           if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Retrieved validate flag for category set');
           end if;
         END IF;

         -- If validate flag is Yes, validate category id from the list of
         -- valid categories for the category set
         -- If validate flag is No, validate category id within the same
         -- structure as the category set

         Begin
           l_dummy := null;

           if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate category for the category set');
           end if;

           IF (l_valid_cat_flag = 'Y') then

             if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Category set validate flag is Yes');
             end if;

             select 'X'
             into l_dummy
	     from mtl_category_set_valid_cats_v
             where category_set_id = p_dc_domain_rec.category_set_id
             and category_id = p_dc_domain_rec.category_id;

           ELSIF (l_valid_cat_flag = 'N') then
             if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Category set validate flag is No');
             end if;

             select 'X'
             into l_dummy
	     from mtl_category_sets_vl mcs, mtl_categories_v mc
             where mcs.category_set_id = p_dc_domain_rec.category_set_id
             and mcs.structure_id = mc.structure_id
             and mc.category_id = p_dc_domain_rec.category_id;
           END IF;

         Exception

           WHEN others THEN
             null;

         End;

         -- If category set does not exist, throw an error
         IF (l_dummy <>'X') then
           RAISE CSD_DCD_INVALID_CATEGORY;
         ELSE
           if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Category is valid');
           end if;
         END IF;

       END IF; -- domain is CATEGORY

       -- Set G_MISS parameters according to domain type
       IF (p_dc_domain_rec.domain_type_code = 'CAT') then

         if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Domain type is CATEGORY, setting item id to G_MISS_NUM');
         end if;

         l_inventory_item_id := FND_API.G_MISS_NUM;
         l_category_id := p_dc_domain_rec.category_id;
         l_category_set_id := p_dc_domain_rec.category_set_id;

       ELSIF (p_dc_domain_rec.domain_type_code = 'ITEM') then

         if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Domain type is ITEM, setting category set and category ids to G_MISS_NUM');
         end if;

         l_category_id := FND_API.G_MISS_NUM;
         l_category_set_id := FND_API.G_MISS_NUM;
         l_inventory_item_id := p_dc_domain_rec.inventory_item_id;
       END IF;

       -- Insert row
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling Insert_Row table handler');
       end if;

       BEGIN
         -- Insert the new domain
         CSD_DC_DOMAINS_PKG.Insert_Row
         (px_dc_domain_id 	      => x_dc_domain_id,
          p_object_version_number     => l_obj_ver_num,
          p_diagnostic_code_id        => p_dc_domain_rec.diagnostic_code_id,
          p_inventory_item_id         => l_inventory_item_id,
          p_category_id  	      => l_category_id,
          p_category_set_id  	      => l_category_set_id,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID,
          p_domain_type_code          => p_dc_domain_rec.domain_type_code,
          p_attribute_category        => p_dc_domain_rec.attribute_category,
          p_attribute1                => p_dc_domain_rec.attribute1,
          p_attribute2                => p_dc_domain_rec.attribute2,
          p_attribute3                => p_dc_domain_rec.attribute3,
          p_attribute4                => p_dc_domain_rec.attribute4,
          p_attribute5                => p_dc_domain_rec.attribute5,
          p_attribute6                => p_dc_domain_rec.attribute6,
          p_attribute7                => p_dc_domain_rec.attribute7,
          p_attribute8                => p_dc_domain_rec.attribute8,
          p_attribute9                => p_dc_domain_rec.attribute9,
          p_attribute10               => p_dc_domain_rec.attribute10,
          p_attribute11               => p_dc_domain_rec.attribute11,
          p_attribute12               => p_dc_domain_rec.attribute12,
          p_attribute13               => p_dc_domain_rec.attribute13,
          p_attribute14               => p_dc_domain_rec.attribute14,
          p_attribute15               => p_dc_domain_rec.attribute15
 	 );

       EXCEPTION
          WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_DC_DOMAINS_PKG.Insert_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Create_DC_Domain');
      END IF;

  EXCEPTION

     WHEN CSD_DCD_ITEM_MISSING THEN
          ROLLBACK TO Create_DC_Domain;

            -- Diagnostic code domain item is missing
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_ITEM_MISSING to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	    FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	    FND_MESSAGE.SET_TOKEN('MISSING_PARAM','INVENTORY_ITEM_ID');
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain item is missing');
            END IF;

     WHEN CSD_DCD_CATEGORY_SET_MISSING THEN
          ROLLBACK TO Create_DC_Domain;

            -- Diagnostic code domain category set is missing
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_CATEGORY_SET_MISSING to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	    FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	    FND_MESSAGE.SET_TOKEN('MISSING_PARAM','CATEGORY_SET_ID');
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain category set is missing');
            END IF;

     WHEN CSD_DCD_CATEGORY_MISSING THEN
          ROLLBACK TO Create_DC_Domain;

            -- Diagnostic code domain category is missing
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_CATEGORY_MISSING to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	    FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	    FND_MESSAGE.SET_TOKEN('MISSING_PARAM','CATEGORY_ID');
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain category is missing');
            END IF;

     WHEN CSD_DCD_DOMAIN_EXISTS THEN
          ROLLBACK TO Create_DC_Domain;

            -- Diagnostic code domain already exists
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_DOMAIN_EXISTS to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_DCD_DOMAIN_EXISTS');
	    FND_MESSAGE.SET_TOKEN('DIAGNOSTIC_CODE_ID',p_dc_domain_rec.diagnostic_code_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain already exists');
            END IF;

     WHEN CSD_DCD_INVALID_ITEM THEN
          ROLLBACK TO Create_DC_Domain;

            -- Diagnostic code domain item is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_INVALID_ITEM to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_DCD_INVALID_ITEM');
	    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_dc_domain_rec.inventory_item_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain item is invalid');
            END IF;

     WHEN CSD_DCD_INVALID_CAT_SET THEN
          ROLLBACK TO Create_DC_Domain;

            -- Diagnostic code domain category set is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_INVALID_CAT_SET to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_DCD_INVALID_CAT_SET');
	    FND_MESSAGE.SET_TOKEN('CATEGORY_SET_ID',p_dc_domain_rec.category_set_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain category set is invalid');
            END IF;

     WHEN CSD_DCD_INVALID_CATSET_FLAG THEN
          ROLLBACK TO Create_DC_Domain;

            -- Diagnostic code domain category set validate flag is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_INVALID_CATSET_FLAG to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_DCD_INVALID_CATSET_FLAG');
	    FND_MESSAGE.SET_TOKEN('CATEGORY_SET_ID',p_dc_domain_rec.category_set_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain category set validate flag is invalid');
            END IF;

     WHEN CSD_DCD_INVALID_CATEGORY THEN
          ROLLBACK TO Create_DC_Domain;

            -- Diagnostic code domain category is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_INVALID_CATEGORY to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_DCD_INVALID_CATEGORY');
	    FND_MESSAGE.SET_TOKEN('CATEGORY_ID',p_dc_domain_rec.category_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain category is invalid');
            END IF;

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_DC_Domain;

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
          ROLLBACK TO Create_DC_Domain;

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
          ROLLBACK TO Create_DC_Domain;

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

END Create_DC_Domain;


/*--------------------------------------------------*/
/* procedure name: Update_DC_Domain                 */
/* description   : procedure used to update         */
/*                 dc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_DC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_dc_domain_rec	 	IN  DC_DOMAIN_REC_TYPE,
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
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_diagnostic_codes_pvt.update_dc_domain';
 lc_api_name               CONSTANT VARCHAR2(30)   := 'Update_DC_Domain';
 lc_api_version            CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(32767);
 l_msg_index              NUMBER;
 l_obj_ver_num		  NUMBER;
 l_dummy	          VARCHAR2(1)		  := null;
 l_valid_cat_flag	  VARCHAR2(1)		  := null;
 l_inventory_item_id	  NUMBER		  := null;
 l_category_id		  NUMBER		  := null;
 l_category_set_id	  NUMBER		  := null;

-- EXCEPTIONS --
 CSD_DCD_DC_ID_MISSING		EXCEPTION;
 CSD_DCD_DOMAIN_TYPE_MISSING	EXCEPTION;
 CSD_DCD_ITEM_MISSING	  	EXCEPTION;
 CSD_DCD_CATEGORY_SET_MISSING	EXCEPTION;
 CSD_DCD_CATEGORY_MISSING	EXCEPTION;
 CSD_DCD_INVALID_ID		EXCEPTION;
 CSD_DCD_GET_OVN_ERROR		EXCEPTION;
 CSD_DCD_OVN_MISMATCH		EXCEPTION;
 CSD_DCD_DOMAIN_EXISTS	  	EXCEPTION;
 CSD_DCD_GET_ITEM_ERROR	  	EXCEPTION;
 CSD_DCD_INVALID_ITEM	  	EXCEPTION;
 CSD_DCD_GET_CAT_SET_ERROR  	EXCEPTION;
 CSD_DCD_INVALID_CAT_SET  	EXCEPTION;
 CSD_DCD_GET_CATSET_FLAG_ERROR 	EXCEPTION;
 CSD_DCD_GET_CATEGORY_ERROR  	EXCEPTION;
 CSD_DCD_INVALID_CATEGORY	EXCEPTION;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Update_DC_Domain;

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
               'Entered Update_DC_Domain');
       END IF;

       -- log parameters
       IF (lc_stat_level >= lc_debug_level) THEN
	   csd_gen_utility_pvt.dump_dc_domain_rec
           ( p_dc_domain_rec => p_dc_domain_rec);
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
       ( p_param_value	  => p_dc_domain_rec.dc_domain_id,
         p_param_name	  => 'DC_DOMAIN_ID',
         p_api_name	  => lc_api_name);

       -- Check if required parameter is passed in as G_MISS
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Checking if required parameters are passed in as G_MISS');
       end if;

       -- Check if required parameter is passed in as G_MISS
       IF (p_dc_domain_rec.diagnostic_code_id = FND_API.G_MISS_NUM) THEN
	RAISE CSD_DCD_DC_ID_MISSING;
       END IF;

       -- Check if required parameter is passed in as G_MISS
       IF (p_dc_domain_rec.domain_type_code = FND_API.G_MISS_CHAR) THEN
	RAISE CSD_DCD_DOMAIN_TYPE_MISSING;
       END IF;

       -- Check if required parameter is passed in as G_MISS
       IF (p_dc_domain_rec.domain_type_code = 'ITEM'
       and p_dc_domain_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN
	RAISE CSD_DCD_ITEM_MISSING;
       END IF;

       -- Check if required parameter is passed in as G_MISS
       IF (p_dc_domain_rec.domain_type_code = 'CAT') THEN
          IF (p_dc_domain_rec.category_set_id = FND_API.G_MISS_NUM) THEN
	    RAISE CSD_DCD_CATEGORY_SET_MISSING;
          END IF;

          IF (p_dc_domain_rec.category_id = FND_API.G_MISS_NUM) THEN
	    RAISE CSD_DCD_CATEGORY_MISSING;
          END IF;
       END IF;

       -- Validate the domain for diagnostic code
       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the diagnostic code domain id');
       end if;

       -- Validate the diagnostic code domain id
       Begin
         select 'X'
         into l_dummy
         from csd_dc_domains
 	 where dc_domain_id = p_dc_domain_rec.dc_domain_id;

       Exception

         WHEN others THEN
           null;

       End;

       -- If domain id is invalid, throw an error
       IF (l_dummy <> 'X') then
          RAISE CSD_DCD_INVALID_ID;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Diagnostic code domain id is valid');
          end if;
       END IF;

       -- Get the object version number for diagnostic code
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Get object version number for diagnostic code domain');
       end if;

       -- Get object version number for diagnostic code domain
       Begin
          select object_version_number
          into l_obj_ver_num
          from csd_dc_domains
 	  where dc_domain_id = p_dc_domain_rec.dc_domain_id;

       Exception

         WHEN others THEN
    	   l_obj_ver_num := null;

       End;

       -- If no object version number, throw an error
       IF (l_obj_ver_num is null) then
          RAISE CSD_DCD_GET_OVN_ERROR;
       ELSE
          if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
	               'Retrieved object version number');
          end if;
       END IF;

       -- Validate if object version number for diagnostic code domain is same as the one passed in
       IF NVL(p_dc_domain_rec.object_version_number,FND_API.G_MISS_NUM) <> l_obj_ver_num  THEN
          RAISE CSD_DCD_OVN_MISMATCH;
       END IF;

       -- Validate the code for diagnostic code
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Validate if the diagnostic code domain already exists ');
       end if;

       -- Validate the domain for diagnostic code
       Begin
         l_dummy := null;

         /* gilam: bug 3445684 - changed query to include service code id in the each or condition
         select 'X'
         into l_dummy
         from csd_dc_domains
	 where dc_domain_id <> p_dc_domain_rec.dc_domain_id
 	 and diagnostic_code_id = p_dc_domain_rec.diagnostic_code_id
	 and domain_type_code = p_dc_domain_rec.domain_type_code
	 and inventory_item_id = p_dc_domain_rec.inventory_item_id
         and category_set_id = p_dc_domain_rec.category_set_id
         and category_id = p_dc_domain_rec.category_id;
         */
         select 'X'
         into l_dummy
         from csd_dc_domains
	 where dc_domain_id <> p_dc_domain_rec.dc_domain_id
 	 and (diagnostic_code_id = p_dc_domain_rec.diagnostic_code_id
	 and domain_type_code = p_dc_domain_rec.domain_type_code
	 and inventory_item_id = p_dc_domain_rec.inventory_item_id)
	 or  (diagnostic_code_id = p_dc_domain_rec.diagnostic_code_id
	 and domain_type_code = p_dc_domain_rec.domain_type_code
	 and category_set_id = p_dc_domain_rec.category_set_id
         and category_id = p_dc_domain_rec.category_id);
        -- gilam: end bug fix 3445684

       Exception

    	WHEN no_data_found THEN
 	   null;

        WHEN others THEN
           l_dummy := 'X';

        End;

        -- If domain already exists, throw an error
        IF (l_dummy = 'X') then
           RAISE CSD_DCD_DOMAIN_EXISTS;
        ELSE
           if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Diagnostic code domain does not exist');
           end if;
       END IF;

       -- If domain is ITEM
       IF (p_dc_domain_rec.domain_type_code = 'ITEM') then

         -- Validate the inventory item id if domain is ITEM
         if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Domain type is ITEM, perform validations');
         end if;

         IF (p_dc_domain_rec.inventory_item_id is null) THEN

         -- inventory item id is null, get the existing one
         if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Retrieve existing inventory item id since nothing is passed in');
         end if;

          Begin
           select inventory_item_id
           into l_inventory_item_id
           from csd_dc_domains_v
           where dc_domain_id = p_dc_domain_rec.dc_domain_id
           and domain_type_code = p_dc_domain_rec.domain_type_code;

          Exception

           WHEN others THEN
             l_inventory_item_id := null;
          End;

          -- If item is not retrieved, throw an error
          IF (l_inventory_item_id is null) then
            RAISE CSD_DCD_GET_ITEM_ERROR;
          ELSE
            if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Item for diagnostic code domain is retrieved');
            end if;
          END IF;

        ELSE  -- if inventory item id is passed in

         -- Validate the inventory item id
         if (lc_proc_level >= lc_debug_level) then
            FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the inventory item id passed in');
         end if;

         Begin
           select inventory_item_id
           into l_inventory_item_id
           from mtl_system_items_kfv
           where organization_id = cs_std.get_item_valdn_orgzn_id
           and inventory_item_id = p_dc_domain_rec.inventory_item_id;

         Exception

           WHEN others THEN
             l_inventory_item_id := null;
         End;

         -- If item is invalid, throw an error
         IF (l_inventory_item_id is null) then
            RAISE CSD_DCD_INVALID_ITEM;
         ELSE
            if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Item for diagnostic code domain is valid');
            end if;
         END IF;
       END IF;  -- inventory item id is null

     END IF;-- domain is ITEM

     -- Validate the category set id and category id if domain is CATEGORY

     -- If domain is CATEGORY
     IF (p_dc_domain_rec.domain_type_code = 'CAT' ) THEN

         -- Validate the category set id if domain is CAT
         if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Domain type is CATEGORY, perform validations');
         end if;

         -- Validate the category set id if it is passed in
         IF (p_dc_domain_rec.category_set_id is null) THEN

          -- If category set is null, get the existing category set id
          if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Get the existing category set id since nothing is passed in');
          end if;

          Begin
           select category_set_id
           into l_category_set_id
           from csd_dc_domains_v
           where dc_domain_id = p_dc_domain_rec.dc_domain_id
           and domain_type_code = p_dc_domain_rec.domain_type_code;

          Exception

       	   WHEN others THEN
       	     l_category_set_id := null;

          End;

          -- If category set does not exist, throw an error
          IF (l_category_set_id is null) then
            RAISE CSD_DCD_GET_CAT_SET_ERROR;
          ELSE
            if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Error retrieving existing category set for diagnostic code domain');
            end if;
          END IF;

         ELSE

          -- Validate the category set id passed in
          if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Validate the category set id passed in');
          end if;

          Begin
           select category_set_id
           into l_category_set_id
           from mtl_category_sets_vl
           where category_set_id = p_dc_domain_rec.category_set_id;

          Exception

       	   WHEN others THEN
       	     l_category_set_id := null;

          End;

          -- If category set does not exist, throw an error
          IF (l_category_set_id is null) then
            RAISE CSD_DCD_INVALID_CAT_SET;
          ELSE
            if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Category set for diagnostic code domain is valid');
            end if;
          END IF;


         END IF;

         -- Get the validate flag for the category set
         if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Get the validate flag for the category set');
         end if;

         -- Get the validate flag for the category set
         Begin
           select validate_flag
           into l_valid_cat_flag
           from mtl_category_sets_vl
           where category_set_id = l_category_set_id;

         Exception

            WHEN others THEN
              null;

          End;

          -- If category set does not exist, throw an error
          IF (l_valid_cat_flag is null) then
            RAISE CSD_DCD_GET_CATSET_FLAG_ERROR;
          ELSE
            if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
  	               'Retrieved validate flag for category set');
            end if;
         END IF;

          -- If category id is null, get the existing one
          IF (p_dc_domain_rec.category_id is null) THEN

           if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
  	               'Retrieved existing category id since nothing is passed in');
            end if;

            Begin
             select category_id
             into l_category_id
             from csd_dc_domains_v
             where dc_domain_id = p_dc_domain_rec.dc_domain_id
             and domain_type_code = p_dc_domain_rec.domain_type_code;

            Exception

       	     WHEN others THEN
     	       l_category_id := null;

            End;

            -- If category is not retrieved, throw an error
            IF (l_category_id is null) then
              RAISE CSD_DCD_GET_CATEGORY_ERROR;
            ELSE
              if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
 	               'Retrieved category for diagnostic code domain');
              end if;
            END IF;

         ELSE -- category id is passed in

          l_category_id := p_dc_domain_rec.category_id;

         END IF;

         -- If validate flag is Yes, validate category id from the list of
         -- valid categories for the category set
         -- If validate flag is No, validate category id within the same
         -- structure as the category set

         Begin
           l_dummy := null;

           if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Validate category for the category set');
           end if;

           IF (l_valid_cat_flag = 'Y') then

             if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Category set validate flag is Yes');
             end if;

             select 'X'
             into l_dummy
	     from mtl_category_set_valid_cats_v
             where category_set_id = l_category_set_id
             and category_id = l_category_id;

           ELSIF (l_valid_cat_flag = 'N') then
             if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Category set validate flag is No');
             end if;

             select 'X'
             into l_dummy
	     from mtl_category_sets_vl mcs, mtl_categories_v mc
             where mcs.category_set_id = l_category_set_id
             and mcs.structure_id = mc.structure_id
             and mc.category_id = l_category_id;
           END IF;

         Exception

            WHEN others THEN
              null;

          End;

          -- If category set does not exist, throw an error
          IF (l_dummy <>'X') then
            RAISE CSD_DCD_INVALID_CATEGORY;
          ELSE
            if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
  	               'Category is valid');
            end if;
          END IF;

       END IF; -- domain is CATEGORY

       -- Set G_MISS parameters according to domain type
       IF (p_dc_domain_rec.domain_type_code = 'CAT') then

         if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Domain type is CATEGORY, setting item id to G_MISS_NUM');
         end if;

         l_inventory_item_id := FND_API.G_MISS_NUM;

       ELSIF (p_dc_domain_rec.domain_type_code = 'ITEM') then

        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Domain type is ITEM, setting category set and category ids to G_MISS_NUM');
         end if;

         l_category_id := FND_API.G_MISS_NUM;
         l_category_set_id := FND_API.G_MISS_NUM;
       END IF;

        -- Update row
        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling Update_Row table handler');
       end if;

       BEGIN
         -- Update the diagnostic code domain
         CSD_DC_DOMAINS_PKG.Update_Row
         (p_dc_domain_id 	      => p_dc_domain_rec.dc_domain_id,
          p_object_version_number     => l_obj_ver_num + 1,
          p_diagnostic_code_id        => p_dc_domain_rec.diagnostic_code_id,
          p_inventory_item_id         => l_inventory_item_id,
          p_category_id  	      => l_category_id,
          p_category_set_id  	      => l_category_set_id,
          p_created_by                => FND_GLOBAL.USER_ID,
          p_creation_date             => SYSDATE,
          p_last_updated_by           => FND_GLOBAL.USER_ID,
          p_last_update_date          => SYSDATE,
          p_last_update_login         => FND_GLOBAL.LOGIN_ID,
          p_domain_type_code          => p_dc_domain_rec.domain_type_code,
          p_attribute_category        => p_dc_domain_rec.attribute_category,
          p_attribute1                => p_dc_domain_rec.attribute1,
          p_attribute2                => p_dc_domain_rec.attribute2,
          p_attribute3                => p_dc_domain_rec.attribute3,
          p_attribute4                => p_dc_domain_rec.attribute4,
          p_attribute5                => p_dc_domain_rec.attribute5,
          p_attribute6                => p_dc_domain_rec.attribute6,
          p_attribute7                => p_dc_domain_rec.attribute7,
          p_attribute8                => p_dc_domain_rec.attribute8,
          p_attribute9                => p_dc_domain_rec.attribute9,
          p_attribute10               => p_dc_domain_rec.attribute10,
          p_attribute11               => p_dc_domain_rec.attribute11,
          p_attribute12               => p_dc_domain_rec.attribute12,
          p_attribute13               => p_dc_domain_rec.attribute13,
          p_attribute14               => p_dc_domain_rec.attribute14,
          p_attribute15               => p_dc_domain_rec.attribute15
         );

         x_obj_ver_number := l_obj_ver_num + 1;

       EXCEPTION
          WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_DC_DOMAINS_PKG.Insert_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Update_DC_Domain');
      END IF;

  EXCEPTION
     WHEN CSD_DCD_DC_ID_MISSING THEN
          ROLLBACK TO Update_DC_Domain;
            -- Diagnostic code domain id is missing
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_DC_ID_MISSING to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	    FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	    FND_MESSAGE.SET_TOKEN('MISSING_PARAM','DC_DOMAIN_ID');
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain id is missing');
            END IF;

     WHEN CSD_DCD_DOMAIN_TYPE_MISSING THEN
          ROLLBACK TO Update_DC_Domain;

          -- Diagnostic code domain type is missing
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_DOMAIN_TYPE_MISSING to FND_MSG stack');
          end if;
    	  FND_MESSAGE.SET_NAME('CSD','CSD_API_MISSING_PARAM');
	  FND_MESSAGE.SET_TOKEN('API_NAME',lc_api_name);
	  FND_MESSAGE.SET_TOKEN('MISSING_PARAM','DOMAIN_TYPE_CODE');
	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain type is missing');
          END IF;

     WHEN CSD_DCD_INVALID_ID THEN
          ROLLBACK TO Update_DC_Domain;

          -- Diagnostic code domain id is invalid
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_INVALID_ID to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_DCD_INVALID_ID');
     	  FND_MESSAGE.SET_TOKEN('DC_DOMAIN_ID',p_dc_domain_rec.dc_domain_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain id is invalid');
          END IF;

     WHEN CSD_DCD_GET_OVN_ERROR THEN
          ROLLBACK TO Update_DC_Domain;

          -- Diagnostic code domain get object version number error
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_GET_OVN_ERROR to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_DCD_GET_OVN_ERROR');
     	  FND_MESSAGE.SET_TOKEN('DC_DOMAIN_ID',p_dc_domain_rec.dc_domain_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain get object version number error');
          END IF;

     WHEN CSD_DCD_OVN_MISMATCH THEN
          ROLLBACK TO Update_DC_Domain;

          -- Diagnostic code domain object version number mismatch
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_OVN_MISMATCH to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_DCD_OVN_MISMATCH');
     	  FND_MESSAGE.SET_TOKEN('DC_DOMAIN_ID',p_dc_domain_rec.dc_domain_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain object version number mismatch');
          END IF;

     WHEN CSD_DCD_DOMAIN_EXISTS THEN
          ROLLBACK TO Update_DC_Domain;

          -- Diagnostic code domain already exists
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_DOMAIN_EXISTS to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_DCD_DOMAIN_EXISTS');
     	  FND_MESSAGE.SET_TOKEN('DIAGNOSTIC_CODE_ID',p_dc_domain_rec.diagnostic_code_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain already exists');
          END IF;

     WHEN CSD_DCD_GET_ITEM_ERROR THEN
          ROLLBACK TO Update_DC_Domain;

          -- Diagnostic code domain get item error
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_GET_ITEM_ERROR to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_DCD_GET_ITEM_ERROR');
     	  FND_MESSAGE.SET_TOKEN('DC_DOMAIN_ID',p_dc_domain_rec.dc_domain_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain get item error');
          END IF;

     WHEN CSD_DCD_INVALID_ITEM THEN
          ROLLBACK TO Update_DC_Domain;

          -- Diagnostic code domain item is invalid
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_INVALID_ITEM to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_DCD_INVALID_ITEM');
     	  FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_dc_domain_rec.inventory_item_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain item is invalid');
          END IF;

     WHEN CSD_DCD_GET_CAT_SET_ERROR THEN
          ROLLBACK TO Update_DC_Domain;

          -- Diagnostic code domain get category set error
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_GET_CAT_SET_ERROR to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_DCD_GET_CAT_SET_ERROR');
     	  FND_MESSAGE.SET_TOKEN('DC_DOMAIN_ID',p_dc_domain_rec.dc_domain_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain get category set error');
          END IF;

     WHEN CSD_DCD_INVALID_CAT_SET THEN
          ROLLBACK TO Update_DC_Domain;

            -- Diagnostic code domain category set is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_INVALID_CAT_SET to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_DCD_INVALID_CAT_SET');
	    FND_MESSAGE.SET_TOKEN('CATEGORY_SET_ID',p_dc_domain_rec.category_set_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain category set is invalid');
            END IF;

     WHEN CSD_DCD_GET_CATSET_FLAG_ERROR THEN
          ROLLBACK TO Update_DC_Domain;

            -- Diagnostic code domain category set validate flag is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_GET_CATSET_FLAG_ERROR to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_DCD_GET_CATSET_FLAG_ERROR');
	    FND_MESSAGE.SET_TOKEN('CATEGORY_SET_ID',p_dc_domain_rec.category_set_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain category set validate flag is invalid');
            END IF;

     WHEN CSD_DCD_GET_CATEGORY_ERROR THEN
          ROLLBACK TO Update_DC_Domain;

          -- Diagnostic code domain get category error
          x_return_status := FND_API.G_RET_STS_ERROR ;

          -- save message in fnd stack
          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_GET_CATEGORY_ERROR to FND_MSG stack');
          end if;
     	  FND_MESSAGE.SET_NAME('CSD','CSD_DCD_GET_CATEGORY_ERROR');
     	  FND_MESSAGE.SET_TOKEN('DC_DOMAIN_ID',p_dc_domain_rec.dc_domain_id);
     	  FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (lc_excep_level >= lc_debug_level) THEN
              FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain get category error');
          END IF;

     WHEN CSD_DCD_INVALID_CATEGORY THEN
          ROLLBACK TO Update_DC_Domain;

            -- Diagnostic code domain category is invalid
            x_return_status := FND_API.G_RET_STS_ERROR ;

            -- save message in fnd stack
            if (lc_stat_level >= lc_debug_level) then
                FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'Adding message CSD_DCD_INVALID_CATEGORY to FND_MSG stack');
            end if;
    	    FND_MESSAGE.SET_NAME('CSD','CSD_DCD_INVALID_CATEGORY');
	    FND_MESSAGE.SET_TOKEN('CATEGORY_ID',p_dc_domain_rec.category_id);
	    FND_MSG_PUB.Add;

            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

            -- save message in debug log
            IF (lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level, lc_mod_name,
                               'Diagnostic code domain category is invalid');
            END IF;

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_DC_Domain;

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
          ROLLBACK TO Update_DC_Domain;

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
          ROLLBACK TO Update_DC_Domain;

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

END Update_DC_Domain;

/*--------------------------------------------------*/
/* procedure name: Delete_DC_Domain                 */
/* description   : procedure used to delete         */
/*                 dc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Delete_DC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_dc_domain_id	 	IN  NUMBER
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_diagnostic_codes_pvt.create_dc_domain';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Delete_DC_Domain';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Delete_DC_Domain;

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
                'Entered Delete_DC_Domain');
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
       ( p_param_value	  => p_dc_domain_id,
         p_param_name	  => 'DC_DOMAIN_ID',
         p_api_name	  => lc_api_name);

        -- Delete row
        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling Delete_Row table handler');
       end if;

       BEGIN

         -- Delete the diagnostic code domain
         CSD_DC_DOMAINS_PKG.Delete_Row
         (  p_dc_domain_id 	      => p_dc_domain_id	);

       EXCEPTION
         WHEN OTHERS THEN
            IF ( lc_excep_level >= lc_debug_level) THEN
               FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_DC_DOMAINS_PKG.Delete_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Delete_DC_Domain');
      END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Delete_DC_Domain;

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
          ROLLBACK TO Delete_DC_Domain;

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
          ROLLBACK TO Delete_DC_Domain;

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

END Delete_DC_Domain;

/*--------------------------------------------------*/
/* procedure name: Lock_DC_Domain                   */
/* description   : procedure used to lock           */
/*                 dc domain	                    */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Lock_DC_Domain
(
  p_api_version        		IN  NUMBER,
  p_commit	   		IN  VARCHAR2,
  p_init_msg_list      		IN  VARCHAR2,
  p_validation_level   		IN  NUMBER,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2,
  p_dc_domain_rec		IN  DC_DOMAIN_REC_TYPE
) IS

-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_diagnostic_codes_pvt.create_dc_domain';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Lock_DC_Domain';
 lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Lock_DC_Domain;

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
                'Entered Lock_DC_Domain');
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
        ( p_param_value	  => p_dc_domain_rec.dc_domain_id,
          p_param_name	  => 'DC_DOMAIN_ID',
         p_api_name	  => lc_api_name);

        -- Check the required parameter
        CSD_PROCESS_UTIL.Check_Reqd_Param
        ( p_param_value	  => p_dc_domain_rec.object_version_number,
          p_param_name	  => 'OBJECT_VERSION_NUMBER',
          p_api_name	  => lc_api_name);

       -- Lock row
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling Lock_Row table handler');
       end if;

       BEGIN

         -- Lock the dc domain
         CSD_DC_DOMAINS_PKG.Lock_Row
         (p_dc_domain_id 	      => p_dc_domain_rec.dc_domain_id,
          p_object_version_number     => p_dc_domain_rec.object_version_number

          --commented out the rest of the record
          /*,
          p_diagnostic_code_id        => p_dc_domain_rec.diagnostic_code_id,
          p_inventory_item_id         => p_dc_domain_rec.inventory_item_id,
          p_category_id  	      => p_dc_domain_rec.category_id,
          p_category_set_id  	      => p_dc_domain_rec.category_set_id,
          p_created_by                => null,
          p_creation_date             => null,
          p_last_updated_by           => null,
          p_last_update_date          => null,
          p_last_update_login         => null,
          p_domain_type_code          => p_dc_domain_rec.domain_type_code,
          p_attribute_category        => p_dc_domain_rec.attribute_category,
          p_attribute1                => p_dc_domain_rec.attribute1,
          p_attribute2                => p_dc_domain_rec.attribute2,
          p_attribute3                => p_dc_domain_rec.attribute3,
          p_attribute4                => p_dc_domain_rec.attribute4,
          p_attribute5                => p_dc_domain_rec.attribute5,
          p_attribute6                => p_dc_domain_rec.attribute6,
          p_attribute7                => p_dc_domain_rec.attribute7,
          p_attribute8                => p_dc_domain_rec.attribute8,
          p_attribute9                => p_dc_domain_rec.attribute9,
          p_attribute10               => p_dc_domain_rec.attribute10,
          p_attribute11               => p_dc_domain_rec.attribute11,
          p_attribute12               => p_dc_domain_rec.attribute12,
          p_attribute13               => p_dc_domain_rec.attribute13,
          p_attribute14               => p_dc_domain_rec.attribute14,
          p_attribute15               => p_dc_domain_rec.attribute15
          */
          --
 	 );

       EXCEPTION
          WHEN OTHERS THEN
             IF ( lc_excep_level >= lc_debug_level) THEN
                FND_LOG.STRING(lc_excep_level,lc_mod_name,'Others exception in CSD_DC_DOMAINS_PKG.Delete_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
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
                       'Leaving Lock_DC_Domain');
      END IF;

  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Lock_DC_Domain;

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
          ROLLBACK TO Lock_DC_Domain;

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
          ROLLBACK TO Lock_DC_Domain;

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


END Lock_DC_Domain;

End CSD_DC_DOMAINS_PVT;


/
