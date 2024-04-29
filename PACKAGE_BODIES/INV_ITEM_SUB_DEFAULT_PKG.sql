--------------------------------------------------------
--  DDL for Package Body INV_ITEM_SUB_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_SUB_DEFAULT_PKG" AS
/* $Header: INVISDPB.pls 120.1 2006/04/23 22:32:43 anmurali noship $ */
 PROCEDURE INSERT_UPD_ITEM_SUB_DEFAULTS (
     x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_organization_id       IN  NUMBER
   , p_inventory_item_id     IN  NUMBER
   , p_subinventory_code     IN  VARCHAR2
   , p_default_type          IN  NUMBER
   , p_creation_date         IN  DATE
   , p_created_by            IN  NUMBER
   , p_last_update_date      IN  DATE
   , p_last_updated_by       IN  NUMBER
   , p_process_code          IN  VARCHAR2
   , p_commit                IN  VARCHAR2 ) IS

   l_chk_rec_exists NUMBER;
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_subinv_code VARCHAR2(1);
   l_msg_count NUMBER := 0;
   BEGIN
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.TRACE('Beginning of the program .The input parameters are :','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_organization_id :'||p_organization_id,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_inventory_item_id :'||p_inventory_item_id,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_subinventory_code :'||p_subinventory_code,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_default_type :'||p_default_type,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_creation_date :'||p_creation_date,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_created_by :'||p_created_by,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_last_update_date :'||p_last_update_date,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_last_updated_by :'||p_last_updated_by,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_process_code :'||p_process_code,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         INV_TRX_UTIL_PUB.TRACE('p_commit :'||p_commit,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
      END IF;
      SAVEPOINT ins_upd_item_sub_dft;
      x_return_status := fnd_api.g_ret_sts_success;

      /*Check if all the input parameters are passed */
      IF (p_organization_id IS NULL OR
         p_inventory_item_id IS NULL OR
         /*p_subinventory_code IS NULL OR Bug4013041--Now deleting default sub information when it is nulled.*/
         p_default_type IS NULL OR
         p_creation_date IS NULL OR
         p_created_by IS NULL OR
         p_last_update_date IS NULL OR
         p_process_code IS NULL OR
         p_last_updated_by IS NULL )
         THEN
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.TRACE('One or more input parameter/s is/are  null :','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         END IF;
         FND_MESSAGE.SET_NAME('WMS','WMS_NULL_INPUT_PARAMETER');
	 l_msg_count := l_msg_count + 1;
         /* One of more input parameters provided are null */
         RAISE fnd_api.g_exc_error;
      END IF;

      /*Check if the default is in 1,2,3. If not one among them, throw an exception */
      IF p_default_type NOT IN (1,2,3) THEN
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.TRACE('p_default_type is not in 1, 2,3 ','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         END IF;
         FND_MESSAGE.SET_NAME('WMS','WMS_INVALID_DEFAULT_TYPE');
	 l_msg_count := l_msg_count + 1;
         /*Invalid value for the Default_Type.The value should be either 1 or 2 or 3*/
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_process_code NOT IN ('INSERT','UPDATE','SYNC') THEN
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.TRACE('Invalid value for p_process_code','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
      END IF;
      FND_MESSAGE.SET_NAME('WMS','WMS_INVALID_PROCESS_CODE');
      l_msg_count := l_msg_count + 1;
      RAISE fnd_api.g_exc_error;
         /*Invalid value for the PROCESS CODE.The value should be either insert update or sync*/
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
       BEGIN
	 SELECT 'X' INTO l_subinv_code
	   FROM mtl_secondary_inventories
	  WHERE secondary_inventory_name = p_subinventory_code
	    AND nvl(disable_date,sysdate+1) > sysdate
	    AND organization_id = p_organization_id;
       EXCEPTION
          WHEN no_data_found THEN
	    FND_MESSAGE.SET_NAME('WMS','WMS_INVALID_SUBINVENTORY_CODE');
	    l_msg_count := l_msg_count + 1;
            RAISE fnd_api.g_exc_error;
       END;
      END IF;

      IF  UPPER(p_process_code) = 'INSERT' THEN
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.TRACE('p_process_code IS Insert ','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         END IF;
            INSERT
            INTO mtl_item_sub_defaults (INVENTORY_ITEM_ID
                                        ,ORGANIZATION_ID
                                        ,SUBINVENTORY_CODE
                                        ,DEFAULT_TYPE
                                        ,LAST_UPDATE_DATE
                                        ,LAST_UPDATED_BY
                                        ,CREATION_DATE
                                        ,CREATED_BY
                                        )
            VALUES (p_inventory_item_id
                    ,p_organization_id
                    ,p_subinventory_code
                    ,p_default_type
                    ,p_last_update_date
                    ,p_last_updated_by
                    ,p_creation_date
                    ,p_created_by
                    );
            IF SQL%found THEN
               IF (l_debug = 1) THEN
                  INV_TRX_UTIL_PUB.TRACE('Record inserted successfully ','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
               END IF;
            END IF;
      ELSIF UPPER(p_process_code) = 'UPDATE' THEN
            IF (l_debug = 1) THEN
               INV_TRX_UTIL_PUB.TRACE('p_process_code IS Update ','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
            END IF;

      /*Bug4013041--Now deleting default sub information when it is nulled.*/
       IF (p_subinventory_code IS NULL) THEN
         delete from mtl_item_sub_defaults
	 where inventory_item_id = p_inventory_item_id
	 and organization_id = p_organization_id
	 and default_type = p_default_type;
       ELSE
            UPDATE mtl_item_sub_defaults
            SET  subinventory_code = p_subinventory_code
               , LAST_UPDATE_DATE  = p_last_update_date
               , LAST_UPDATED_BY   = p_last_updated_by
               , CREATION_DATE     = p_creation_date
               , CREATED_BY        = p_created_by
            WHERE inventory_item_id = p_inventory_item_id
             AND organization_id = p_organization_id
             AND default_type    = p_default_type;
         IF SQL%FOUND THEN
          IF (l_debug = 1) THEN
             INV_TRX_UTIL_PUB.TRACE('Record Updated successfully','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
          END IF;
         END IF;
       END IF; --p_subinventory_code IS NULL
      ELSIF UPPER(p_process_code) = 'SYNC' THEN
            /*
        Check if the record exists in MTL_ITEM_SUB_DEFAULTS for the combination
        Inventory_item_id,Organization_id,Default_type.If it exists, Update the
        record with the new info provided. If the record does not exists, insert
        a new record into MTL_ITEM_SUB_DEFAULTS
       */
           IF (l_debug = 1) THEN
              INV_TRX_UTIL_PUB.TRACE('p_process_code IS Sync ','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
           END IF;
            BEGIN
                 SELECT 1
                 INTO  l_chk_rec_exists
                 FROM mtl_item_sub_defaults
                 WHERE inventory_item_id = p_inventory_item_id
                 AND organization_id = p_organization_id
                 AND default_type    = p_default_type;

      /*Bug4013041--Now deleting default sub information when it is nulled.*/
      IF (p_subinventory_code IS NULL and l_chk_rec_exists = 1) THEN
         delete from mtl_item_sub_defaults
	 where inventory_item_id = p_inventory_item_id
	 and organization_id = p_organization_id
	 and default_type = p_default_type;
      ELSE
                 UPDATE mtl_item_sub_defaults
                    SET  subinventory_code = p_subinventory_code
                    , LAST_UPDATE_DATE  = p_last_update_date
                    , LAST_UPDATED_BY   = p_last_updated_by
                    , CREATION_DATE     = p_creation_date
                    , CREATED_BY        = p_created_by
                 WHERE inventory_item_id = p_inventory_item_id
                    AND organization_id = p_organization_id
                    AND default_type    = p_default_type;
                 IF SQL%FOUND THEN
                    IF (l_debug = 1) THEN
                       INV_TRX_UTIL_PUB.TRACE('Record Updated successfully','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
                    END IF;
                 END IF;
      END IF;--p_subinventory_code IS NULL and l_chk_rec_exists = 1

            EXCEPTION
               WHEN no_data_found THEN
                  IF (l_debug = 1) THEN
                     INV_TRX_UTIL_PUB.TRACE('In no data found. Record does not exists in mtl_item_sub_defaults.Insert record.','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
                  END IF;
                  INSERT INTO mtl_item_sub_defaults (INVENTORY_ITEM_ID
                                        ,ORGANIZATION_ID
                                        ,SUBINVENTORY_CODE
                                        ,DEFAULT_TYPE
                                        ,LAST_UPDATE_DATE
                                        ,LAST_UPDATED_BY
                                        ,CREATION_DATE
                                        ,CREATED_BY
                                        )
                  VALUES (p_inventory_item_id
                    ,p_organization_id
                    ,p_subinventory_code
                    ,p_default_type
                    ,p_last_update_date
                    ,p_last_updated_by
                    ,p_creation_date
                    ,p_created_by
                    );
                  IF SQL%found THEN
                     IF (l_debug = 1) THEN
                        INV_TRX_UTIL_PUB.TRACE('Record inserted successfully ','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
                     END IF;
                  END IF;
            END;
      END IF;

      IF p_commit =fnd_api.g_true THEN
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.TRACE('p_commit is true. Hence commiting the transaction ','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         END IF;
         COMMIT;
      END IF;
      IF (l_debug = 1) THEN
         INV_TRX_UTIL_PUB.TRACE('Program completed successfully','INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.TRACE('In fnd_api.g_exc_error :'||SQLERRM,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         END IF;
         ROLLBACK TO ins_upd_item_sub_dft;
         x_msg_data := FND_MESSAGE.GET;
	 x_msg_count := l_msg_count;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error ;
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.TRACE('In FND_API.G_EXC_UNEXPECTED_ERROR :'||SQLERRM,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         END IF;
         ROLLBACK TO ins_upd_item_sub_dft;
         x_msg_data := FND_MESSAGE.GET;
	 x_msg_count := l_msg_count;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error ;
         IF (l_debug = 1) THEN
            INV_TRX_UTIL_PUB.TRACE('In when others :'||SQLERRM,'INSERT_UPDATE_ITEM_SUB_DEFAULTS',9);
         END IF;
         ROLLBACK TO ins_upd_item_sub_dft;
         x_msg_data := FND_MESSAGE.GET;
	 x_msg_count := l_msg_count;
   END INSERT_UPD_ITEM_SUB_DEFAULTS;
END INV_ITEM_SUB_DEFAULT_PKG;

/
