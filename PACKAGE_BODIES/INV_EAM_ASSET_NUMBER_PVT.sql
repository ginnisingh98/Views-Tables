--------------------------------------------------------
--  DDL for Package Body INV_EAM_ASSET_NUMBER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EAM_ASSET_NUMBER_PVT" as
/* $Header: INVEANDB.pls 115.14 2003/10/10 19:45:16 hkarmach ship $ */
 -- Start of comments
 -- API name    : INV_EAM_ASSET_NUMBER_PVT
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_API_VERSION                 IN NUMBER       REQUIRED
 --          P_INIT_MSG_LIST               IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_COMMIT                      IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_VALIDATION_LEVEL            IN NUMBER       OPTIONAL
 --             DEFAULT = FND_API.G_VALID_LEVEL_FULL
 --          P_ROWID                       IN OUT VARCHAR2 REQUIRED
 --          P_INVENTORY_ITEM_ID           IN  NUMBER
 --          P_SERIAL_NUMBER               IN  VARCHAR2
 --          P_START_DATE_ACTIVE           IN  DATE
 --          P_DESCRIPTIVE_TEXT            IN  VARCHAR2
 --          P_ORGANIZATION_ID             IN  NUMBER
 --          P_CATEGORY_ID                 IN  NUMBER
 --          P_PN_LOCATION_ID              IN  NUMBER
 --          P_EAM_LOCATION_ID             IN  NUMBER
 --          P_FA_ASSET_ID                 IN  NUMBER
 --          P_ASSET_STATUS_CODE           IN  VARCHAR2
 --          P_ASSET_CRITICALITY_CODE      IN  VARCHAR2
 --          P_WIP_ACCOUNTING_CLASS_CODE   IN  VARCHAR2
 --          P_MAINTAINABLE_FLAG           IN  VARCHAR2
 --          P_NETWORK_ASSET_FLAG          IN  VARCHAR2
 --          P_OWNING_DEPARTMENT_ID        IN  NUMBER
 --          P_ATTRIBUTE_CATEGORY          IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE1                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE2                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE3                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE4                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE5                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE6                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE7                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE8                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE9                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE10                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE11                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE12                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE13                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE14                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE15                 IN  VARCHAR2    OPTIONAL
 --          P_LAST_UPDATE_DATE            IN  DATE        REQUIRED
 --          P_LAST_UPDATED_BY             IN  NUMBER      REQUIRED
 --          P_CREATION_DATE               IN  DATE        REQUIRED
 --          P_CREATED_BY                  IN  NUMBER      REQUIRED
 --          P_LAST_UPDATE_LOGIN           IN  NUMBER      REQUIRED
 --          P_REQUEST_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_APPLICATION_ID      IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_UPDATE_DATE         IN  DATE DEFAULT NULL
 -- OUT      X_OBJECT_ID                   OUT NUMBER
 --          X_RETURN_STATUS               OUT VARCHAR2(1)
 --          X_MSG_COUNT                   OUT NUMBER
 --          X_MSG_DATA                    OUT VARCHAR2(2000)
 --
 -- Version  Current version 115.0
 --
 -- Notes    : Note text
 --
 -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'inv_eam_asset_number_pvt';


PROCEDURE SERIAL_CHECK
( p_api_version                IN    NUMBER,
  p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit                     IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level           IN    NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT NOCOPY   VARCHAR2,
  x_msg_count                  OUT NOCOPY   NUMBER,
  x_msg_data                   OUT NOCOPY   VARCHAR2,
  x_errorcode                  OUT NOCOPY   NUMBER,
  x_ser_num_in_item_id		OUT NOCOPY boolean,
  p_INVENTORY_ITEM_ID		IN NUMBER,
  p_SERIAL_NUMBER              IN    VARCHAR2,
  p_ORGANIZATION_ID            IN    NUMBER
) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'serial_check';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
    l_serial_number_type number;
    l_count number;
BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT serial_check;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- API body

   -- added to fix bug 2446341
   -- get serial_number_type and pass it to mtl_serial_check.SNUniqueCheck

   x_ser_num_in_item_id := FALSE;
   select serial_number_type
   into l_serial_number_type
   from mtl_parameters
   where organization_id = p_organization_id;

    mtl_serial_check.SNUniqueCheck(
      p_api_version         =>  0.9,
      x_return_status       =>  x_return_status,
      x_errorcode           =>  x_errorcode,
      x_msg_count           =>  x_msg_count,
      x_msg_data            =>  x_msg_data,
      p_org_id              =>  p_organization_id,
      p_serial_number_type  =>  l_serial_number_type,
      p_serial_number       =>  p_Serial_number);


    /*IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR ;
    END IF;
    */

    -- check if serial number exists within asset group
    select count(1) into l_count
    from mtl_serial_numbers
    where inventory_item_id = p_inventory_item_id
    and serial_number = p_serial_number;

    if l_count > 0 then
    	x_return_status := FND_API.G_RET_STS_ERROR;
    	x_ser_num_in_item_id := TRUE;
    else
        x_ser_num_in_item_id := FALSE;
    end if;



      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);


   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO serial_check;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO serial_check;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO serial_check;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);

END SERIAL_CHECK;


PROCEDURE INSERT_ROW(
  P_API_VERSION                IN NUMBER,
  P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                  IN OUT NOCOPY VARCHAR2,
  P_INVENTORY_ITEM_ID             NUMBER,
  P_SERIAL_NUMBER                 VARCHAR2,
  P_INITIALIZATION_DATE           DATE,
  P_DESCRIPTIVE_TEXT              VARCHAR2,
  P_ORGANIZATION_ID               NUMBER,
  P_CATEGORY_ID                   NUMBER,
  P_PROD_ORGANIZATION_ID          NUMBER,
  P_EQUIPMENT_ITEM_ID             NUMBER,
  P_EQP_SERIAL_NUMBER             VARCHAR2,
  P_PN_LOCATION_ID                NUMBER,
  P_EAM_LOCATION_ID               NUMBER,
  P_FA_ASSET_ID                   NUMBER,
  P_ASSET_CRITICALITY_CODE        VARCHAR2,
  P_WIP_ACCOUNTING_CLASS_CODE     VARCHAR2,
  P_MAINTAINABLE_FLAG             VARCHAR2,
  P_NETWORK_ASSET_FLAG            VARCHAR2,
  P_OWNING_DEPARTMENT_ID          NUMBER,
  P_CURRENT_STATUS                NUMBER,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2,
  P_ATTRIBUTE2                    VARCHAR2,
  P_ATTRIBUTE3                    VARCHAR2,
  P_ATTRIBUTE4                    VARCHAR2,
  P_ATTRIBUTE5                    VARCHAR2,
  P_ATTRIBUTE6                    VARCHAR2,
  P_ATTRIBUTE7                    VARCHAR2,
  P_ATTRIBUTE8                    VARCHAR2,
  P_ATTRIBUTE9                    VARCHAR2,
  P_ATTRIBUTE10                   VARCHAR2,
  P_ATTRIBUTE11                   VARCHAR2,
  P_ATTRIBUTE12                   VARCHAR2,
  P_ATTRIBUTE13                   VARCHAR2,
  P_ATTRIBUTE14                   VARCHAR2,
  P_ATTRIBUTE15                   VARCHAR2,
  P_COMPLETION_DATE               DATE     DEFAULT NULL,
  P_SHIP_DATE                     DATE     DEFAULT NULL,
  P_REVISION                      VARCHAR2 DEFAULT NULL,
  P_LOT_NUMBER                    VARCHAR2 DEFAULT NULL,
  P_FIXED_ASSET_TAG               VARCHAR2 DEFAULT NULL,
  P_RESERVED_ORDER_ID             NUMBER   DEFAULT NULL,
  P_PARENT_ITEM_ID                NUMBER   DEFAULT NULL,
  P_PARENT_SERIAL_NUMBER          VARCHAR2 DEFAULT NULL,
  P_ORIGINAL_WIP_ENTITY_ID        NUMBER   DEFAULT NULL,
  P_ORIGINAL_UNIT_VENDOR_ID       NUMBER   DEFAULT NULL,
  P_VENDOR_SERIAL_NUMBER          VARCHAR2 DEFAULT NULL,
  P_VENDOR_LOT_NUMBER             VARCHAR2 DEFAULT NULL,
  P_LAST_TXN_SOURCE_TYPE_ID       NUMBER   DEFAULT NULL,
  P_LAST_TRANSACTION_ID           NUMBER   DEFAULT NULL,
  P_LAST_RECEIPT_ISSUE_TYPE       NUMBER   DEFAULT NULL,
  P_LAST_TXN_SOURCE_NAME          VARCHAR2 DEFAULT NULL,
  P_LAST_TXN_SOURCE_ID            NUMBER   DEFAULT NULL,
  P_CURRENT_SUBINVENTORY_CODE     VARCHAR2 DEFAULT NULL,
  P_CURRENT_LOCATOR_ID            NUMBER   DEFAULT NULL,
  P_GROUP_MARK_ID                 NUMBER   DEFAULT NULL,
  P_LINE_MARK_ID                  NUMBER   DEFAULT NULL,
  P_LOT_LINE_MARK_ID              NUMBER   DEFAULT NULL,
  P_END_ITEM_UNIT_NUMBER          VARCHAR2 DEFAULT NULL,
  P_SERIAL_ATTRIBUTE_CATEGORY     VARCHAR2 DEFAULT NULL,
  P_ORIGINATION_DATE              DATE     DEFAULT NULL,
  P_C_ATTRIBUTE1                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE2                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE3                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE4                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE5                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE6                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE7                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE8                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE9                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE10                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE11                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE12                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE13                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE14                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE15                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE16                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE17                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE18                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE19                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE20                 VARCHAR2 DEFAULT NULL,
  P_D_ATTRIBUTE1                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE2                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE3                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE4                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE5                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE6                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE7                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE8                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE9                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE10                 DATE     DEFAULT NULL,
  P_N_ATTRIBUTE1                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE2                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE3                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE4                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE5                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE6                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE7                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE8                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE9                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE10                 NUMBER   DEFAULT NULL,
  P_STATUS_ID                     NUMBER   DEFAULT NULL,
  P_TERRITORY_CODE                VARCHAR2 DEFAULT NULL,
  P_COST_GROUP_ID                 NUMBER   DEFAULT NULL,
  P_TIME_SINCE_NEW                NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_NEW              NUMBER   DEFAULT NULL,
  P_TIME_SINCE_OVERHAUL           NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_OVERHAUL         NUMBER   DEFAULT NULL,
  P_TIME_SINCE_REPAIR             NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_REPAIR           NUMBER   DEFAULT NULL,
  P_TIME_SINCE_VISIT              NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_VISIT            NUMBER   DEFAULT NULL,
  P_TIME_SINCE_MARK               NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_MARK             NUMBER   DEFAULT NULL,
  P_LPN_ID                        NUMBER   DEFAULT NULL,
  P_INSPECTION_STATUS             NUMBER   DEFAULT NULL,
  P_PREVIOUS_STATUS               NUMBER   DEFAULT NULL,
  P_LPN_TXN_ERROR_FLAG            VARCHAR2 DEFAULT NULL,
  P_REQUEST_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_CREATION_DATE                 DATE,
  P_CREATED_BY                    NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  P_OWNING_ORGANIZATION_ID  	  NUMBER,
  P_OWNING_ORGANIZATION_TYPE  	  NUMBER,
  P_PLANNING_ORGANIZATION_ID  	  NUMBER,
  P_PLANNING_ORGANIZATION_TYPE    NUMBER,
  X_OBJECT_ID                 OUT NOCOPY NUMBER,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2,
  P_WIP_ENTITY_ID                 NUMBER,  --added as a part of 'Serial Tracking in WIP project
  P_OPERATION_SEQ_NUM             NUMBER,  --added as a part of 'Serial Tracking in WIP project
  P_INTRAOPERATION_STEP_TYPE      NUMBER --added as a part of 'Serial Tracking in WIP project

  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

    CURSOR C IS SELECT rowid FROM MTL_SERIAL_NUMBERS
                 WHERE inventory_item_id = P_INVENTORY_ITEM_ID
                   AND serial_number = P_SERIAL_NUMBER
                   AND current_organization_id = P_ORGANIZATION_ID;

   BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT insert_row;

   -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

   -- API body

  --'Serial Tracking in WIP' project- insert WIP_ENTITY_ID, OPERATION_SEQ_NUM, INTRAOPERATION_STEP_TYPE
  -- INTO MSN.
INSERT INTO MTL_SERIAL_NUMBERS(
       INVENTORY_ITEM_ID,
       SERIAL_NUMBER,
       INITIALIZATION_DATE,
       DESCRIPTIVE_TEXT,
       CURRENT_ORGANIZATION_ID,
       GEN_OBJECT_ID,
       CATEGORY_ID,
       PROD_ORGANIZATION_ID,
       EQUIPMENT_ITEM_ID,
       EQP_SERIAL_NUMBER,
       PN_LOCATION_ID,
       EAM_LOCATION_ID,
       FA_ASSET_ID,
       ASSET_CRITICALITY_CODE,
       WIP_ACCOUNTING_CLASS_CODE,
       MAINTAINABLE_FLAG,
       NETWORK_ASSET_FLAG,
       OWNING_DEPARTMENT_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       CURRENT_STATUS,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       COMPLETION_DATE,
       SHIP_DATE,
       REVISION,
       LOT_NUMBER,
       FIXED_ASSET_TAG,
       RESERVED_ORDER_ID,
       PARENT_ITEM_ID,
       PARENT_SERIAL_NUMBER,
       ORIGINAL_WIP_ENTITY_ID,
       ORIGINAL_UNIT_VENDOR_ID,
       VENDOR_SERIAL_NUMBER,
       VENDOR_LOT_NUMBER,
       LAST_TXN_SOURCE_TYPE_ID,
       LAST_TRANSACTION_ID,
       LAST_RECEIPT_ISSUE_TYPE,
       LAST_TXN_SOURCE_NAME,
       LAST_TXN_SOURCE_ID,
       CURRENT_SUBINVENTORY_CODE,
       CURRENT_LOCATOR_ID,
       GROUP_MARK_ID,
       LINE_MARK_ID,
       LOT_LINE_MARK_ID,
       END_ITEM_UNIT_NUMBER,
       SERIAL_ATTRIBUTE_CATEGORY,
       ORIGINATION_DATE,
       C_ATTRIBUTE1,
       C_ATTRIBUTE2,
       C_ATTRIBUTE3,
       C_ATTRIBUTE4,
       C_ATTRIBUTE5,
       C_ATTRIBUTE6,
       C_ATTRIBUTE7,
       C_ATTRIBUTE8,
       C_ATTRIBUTE9,
       C_ATTRIBUTE10,
       C_ATTRIBUTE11,
       C_ATTRIBUTE12,
       C_ATTRIBUTE13,
       C_ATTRIBUTE14,
       C_ATTRIBUTE15,
       C_ATTRIBUTE16,
       C_ATTRIBUTE17,
       C_ATTRIBUTE18,
       C_ATTRIBUTE19,
       C_ATTRIBUTE20,
       D_ATTRIBUTE1,
       D_ATTRIBUTE2,
       D_ATTRIBUTE3,
       D_ATTRIBUTE4,
       D_ATTRIBUTE5,
       D_ATTRIBUTE6,
       D_ATTRIBUTE7,
       D_ATTRIBUTE8,
       D_ATTRIBUTE9,
       D_ATTRIBUTE10,
       N_ATTRIBUTE1,
       N_ATTRIBUTE2,
       N_ATTRIBUTE3,
       N_ATTRIBUTE4,
       N_ATTRIBUTE5,
       N_ATTRIBUTE6,
       N_ATTRIBUTE7,
       N_ATTRIBUTE8,
       N_ATTRIBUTE9,
       N_ATTRIBUTE10,
       STATUS_ID,
       TERRITORY_CODE,
       COST_GROUP_ID,
       TIME_SINCE_NEW,
       CYCLES_SINCE_NEW,
       TIME_SINCE_OVERHAUL,
       CYCLES_SINCE_OVERHAUL,
       TIME_SINCE_REPAIR,
       CYCLES_SINCE_REPAIR,
       TIME_SINCE_VISIT,
       CYCLES_SINCE_VISIT,
       TIME_SINCE_MARK,
       CYCLES_SINCE_MARK,
       LPN_ID,
       INSPECTION_STATUS,
       PREVIOUS_STATUS,
       LPN_TXN_ERROR_FLAG,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       OWNING_ORGANIZATION_ID,
       OWNING_TP_TYPE,
       PLANNING_ORGANIZATION_ID,
       PLANNING_TP_TYPE,
       WIP_ENTITY_ID,
       OPERATION_SEQ_NUM,
       INTRAOPERATION_STEP_TYPE
       ) values (
       P_INVENTORY_ITEM_ID,
       P_SERIAL_NUMBER,
       P_INITIALIZATION_DATE,
       P_DESCRIPTIVE_TEXT,
       P_ORGANIZATION_ID,
       mtl_gen_object_id_s.nextval,
       P_CATEGORY_ID,
       P_PROD_ORGANIZATION_ID,
       P_EQUIPMENT_ITEM_ID,
       P_EQP_SERIAL_NUMBER,
       P_PN_LOCATION_ID,
       P_EAM_LOCATION_ID,
       P_FA_ASSET_ID,
       P_ASSET_CRITICALITY_CODE,
       P_WIP_ACCOUNTING_CLASS_CODE,
       P_MAINTAINABLE_FLAG,
       P_NETWORK_ASSET_FLAG,
       P_OWNING_DEPARTMENT_ID,
       P_LAST_UPDATE_DATE,
       P_LAST_UPDATED_BY,
       P_CREATION_DATE,
       P_CREATED_BY,
       P_LAST_UPDATE_LOGIN,
       P_CURRENT_STATUS,
       P_ATTRIBUTE_CATEGORY,
       P_ATTRIBUTE1,
       P_ATTRIBUTE2,
       P_ATTRIBUTE3,
       P_ATTRIBUTE4,
       P_ATTRIBUTE5,
       P_ATTRIBUTE6,
       P_ATTRIBUTE7,
       P_ATTRIBUTE8,
       P_ATTRIBUTE9,
       P_ATTRIBUTE10,
       P_ATTRIBUTE11,
       P_ATTRIBUTE12,
       P_ATTRIBUTE13,
       P_ATTRIBUTE14,
       P_ATTRIBUTE15,
       P_COMPLETION_DATE,
       P_SHIP_DATE,
       P_REVISION,
       P_LOT_NUMBER,
       P_FIXED_ASSET_TAG,
       P_RESERVED_ORDER_ID,
       P_PARENT_ITEM_ID,
       P_PARENT_SERIAL_NUMBER,
       P_ORIGINAL_WIP_ENTITY_ID,
       P_ORIGINAL_UNIT_VENDOR_ID,
       P_VENDOR_SERIAL_NUMBER,
       P_VENDOR_LOT_NUMBER,
       P_LAST_TXN_SOURCE_TYPE_ID,
       P_LAST_TRANSACTION_ID,
       P_LAST_RECEIPT_ISSUE_TYPE,
       P_LAST_TXN_SOURCE_NAME,
       P_LAST_TXN_SOURCE_ID,
       P_CURRENT_SUBINVENTORY_CODE,
       P_CURRENT_LOCATOR_ID,
       P_GROUP_MARK_ID,
       P_LINE_MARK_ID,
       P_LOT_LINE_MARK_ID,
       P_END_ITEM_UNIT_NUMBER,
       P_SERIAL_ATTRIBUTE_CATEGORY,
       P_ORIGINATION_DATE,
       P_C_ATTRIBUTE1,
       P_C_ATTRIBUTE2,
       P_C_ATTRIBUTE3,
       P_C_ATTRIBUTE4,
       P_C_ATTRIBUTE5,
       P_C_ATTRIBUTE6,
       P_C_ATTRIBUTE7,
       P_C_ATTRIBUTE8,
       P_C_ATTRIBUTE9,
       P_C_ATTRIBUTE10,
       P_C_ATTRIBUTE11,
       P_C_ATTRIBUTE12,
       P_C_ATTRIBUTE13,
       P_C_ATTRIBUTE14,
       P_C_ATTRIBUTE15,
       P_C_ATTRIBUTE16,
       P_C_ATTRIBUTE17,
       P_C_ATTRIBUTE18,
       P_C_ATTRIBUTE19,
       P_C_ATTRIBUTE20,
       P_D_ATTRIBUTE1,
       P_D_ATTRIBUTE2,
       P_D_ATTRIBUTE3,
       P_D_ATTRIBUTE4,
       P_D_ATTRIBUTE5,
       P_D_ATTRIBUTE6,
       P_D_ATTRIBUTE7,
       P_D_ATTRIBUTE8,
       P_D_ATTRIBUTE9,
       P_D_ATTRIBUTE10,
       P_N_ATTRIBUTE1,
       P_N_ATTRIBUTE2,
       P_N_ATTRIBUTE3,
       P_N_ATTRIBUTE4,
       P_N_ATTRIBUTE5,
       P_N_ATTRIBUTE6,
       P_N_ATTRIBUTE7,
       P_N_ATTRIBUTE8,
       P_N_ATTRIBUTE9,
       P_N_ATTRIBUTE10,
       P_STATUS_ID,
       P_TERRITORY_CODE,
       P_COST_GROUP_ID,
       P_TIME_SINCE_NEW,
       P_CYCLES_SINCE_NEW,
       P_TIME_SINCE_OVERHAUL,
       P_CYCLES_SINCE_OVERHAUL,
       P_TIME_SINCE_REPAIR,
       P_CYCLES_SINCE_REPAIR,
       P_TIME_SINCE_VISIT,
       P_CYCLES_SINCE_VISIT,
       P_TIME_SINCE_MARK,
       P_CYCLES_SINCE_MARK,
       P_LPN_ID,
       P_INSPECTION_STATUS,
       P_PREVIOUS_STATUS,
       P_LPN_TXN_ERROR_FLAG,
       P_REQUEST_ID,
       P_PROGRAM_APPLICATION_ID,
       P_PROGRAM_ID,
       P_PROGRAM_UPDATE_DATE,
       P_OWNING_ORGANIZATION_ID,
       P_OWNING_ORGANIZATION_TYPE,
       P_PLANNING_ORGANIZATION_ID,
       P_PLANNING_ORGANIZATION_TYPE,
       P_WIP_ENTITY_ID,
       P_OPERATION_SEQ_NUM,
       P_INTRAOPERATION_STEP_TYPE
       ) returning gen_object_id, rowid into x_object_id, p_rowid;

    OPEN C;
    FETCH C INTO P_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO insert_row;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO insert_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO insert_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END Insert_Row;




PROCEDURE UPDATE_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                         VARCHAR2,
  P_DESCRIPTIVE_TEXT              VARCHAR2,
  P_CATEGORY_ID                   NUMBER,
  P_PROD_ORGANIZATION_ID          NUMBER,
  P_EQUIPMENT_ITEM_ID             NUMBER,
  P_EQP_SERIAL_NUMBER             VARCHAR2,
  P_PN_LOCATION_ID                NUMBER,
  P_EAM_LOCATION_ID               NUMBER,
  P_FA_ASSET_ID                   NUMBER,
  P_ASSET_CRITICALITY_CODE        VARCHAR2,
  P_WIP_ACCOUNTING_CLASS_CODE     VARCHAR2,
  P_MAINTAINABLE_FLAG             VARCHAR2,
  P_NETWORK_ASSET_FLAG            VARCHAR2,
  P_OWNING_DEPARTMENT_ID          NUMBER,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2,
  P_ATTRIBUTE2                    VARCHAR2,
  P_ATTRIBUTE3                    VARCHAR2,
  P_ATTRIBUTE4                    VARCHAR2,
  P_ATTRIBUTE5                    VARCHAR2,
  P_ATTRIBUTE6                    VARCHAR2,
  P_ATTRIBUTE7                    VARCHAR2,
  P_ATTRIBUTE8                    VARCHAR2,
  P_ATTRIBUTE9                    VARCHAR2,
  P_ATTRIBUTE10                   VARCHAR2,
  P_ATTRIBUTE11                   VARCHAR2,
  P_ATTRIBUTE12                   VARCHAR2,
  P_ATTRIBUTE13                   VARCHAR2,
  P_ATTRIBUTE14                   VARCHAR2,
  P_ATTRIBUTE15                   VARCHAR2,
  P_CURRENT_STATUS                NUMBER   DEFAULT NULL,
  P_INITIALIZATION_DATE           DATE     DEFAULT NULL,
  P_COMPLETION_DATE               DATE     DEFAULT NULL,
  P_SHIP_DATE                     DATE     DEFAULT NULL,
  P_REVISION                      VARCHAR2 DEFAULT NULL,
  P_LOT_NUMBER                    VARCHAR2 DEFAULT NULL,
  P_FIXED_ASSET_TAG               VARCHAR2 DEFAULT NULL,
  P_RESERVED_ORDER_ID             NUMBER   DEFAULT NULL,
  P_PARENT_ITEM_ID                NUMBER   DEFAULT NULL,
  P_PARENT_SERIAL_NUMBER          VARCHAR2 DEFAULT NULL,
  P_ORIGINAL_WIP_ENTITY_ID        NUMBER   DEFAULT NULL,
  P_ORIGINAL_UNIT_VENDOR_ID       NUMBER   DEFAULT NULL,
  P_VENDOR_SERIAL_NUMBER          VARCHAR2 DEFAULT NULL,
  P_VENDOR_LOT_NUMBER             VARCHAR2 DEFAULT NULL,
  P_LAST_TXN_SOURCE_TYPE_ID       NUMBER   DEFAULT NULL,
  P_LAST_TRANSACTION_ID           NUMBER   DEFAULT NULL,
  P_LAST_RECEIPT_ISSUE_TYPE       NUMBER   DEFAULT NULL,
  P_LAST_TXN_SOURCE_NAME          VARCHAR2 DEFAULT NULL,
  P_LAST_TXN_SOURCE_ID            NUMBER   DEFAULT NULL,
  P_CURRENT_SUBINVENTORY_CODE     VARCHAR2 DEFAULT NULL,
  P_CURRENT_LOCATOR_ID            NUMBER   DEFAULT NULL,
  P_GROUP_MARK_ID                 NUMBER   DEFAULT NULL,
  P_LINE_MARK_ID                  NUMBER   DEFAULT NULL,
  P_LOT_LINE_MARK_ID              NUMBER   DEFAULT NULL,
  P_END_ITEM_UNIT_NUMBER          VARCHAR2 DEFAULT NULL,
  P_SERIAL_ATTRIBUTE_CATEGORY     VARCHAR2 DEFAULT NULL,
  P_ORIGINATION_DATE              DATE     DEFAULT NULL,
  P_C_ATTRIBUTE1                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE2                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE3                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE4                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE5                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE6                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE7                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE8                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE9                  VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE10                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE11                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE12                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE13                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE14                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE15                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE16                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE17                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE18                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE19                 VARCHAR2 DEFAULT NULL,
  P_C_ATTRIBUTE20                 VARCHAR2 DEFAULT NULL,
  P_D_ATTRIBUTE1                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE2                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE3                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE4                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE5                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE6                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE7                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE8                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE9                  DATE     DEFAULT NULL,
  P_D_ATTRIBUTE10                 DATE     DEFAULT NULL,
  P_N_ATTRIBUTE1                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE2                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE3                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE4                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE5                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE6                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE7                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE8                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE9                  NUMBER   DEFAULT NULL,
  P_N_ATTRIBUTE10                 NUMBER   DEFAULT NULL,
  P_STATUS_ID                     NUMBER   DEFAULT NULL,
  P_TERRITORY_CODE                VARCHAR2 DEFAULT NULL,
  P_COST_GROUP_ID                 NUMBER   DEFAULT NULL,
  P_TIME_SINCE_NEW                NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_NEW              NUMBER   DEFAULT NULL,
  P_TIME_SINCE_OVERHAUL           NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_OVERHAUL         NUMBER   DEFAULT NULL,
  P_TIME_SINCE_REPAIR             NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_REPAIR           NUMBER   DEFAULT NULL,
  P_TIME_SINCE_VISIT              NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_VISIT            NUMBER   DEFAULT NULL,
  P_TIME_SINCE_MARK               NUMBER   DEFAULT NULL,
  P_CYCLES_SINCE_MARK             NUMBER   DEFAULT NULL,
  P_LPN_ID                        NUMBER   DEFAULT NULL,
  P_INSPECTION_STATUS             NUMBER   DEFAULT NULL,
  P_PREVIOUS_STATUS               NUMBER   DEFAULT NULL,
  P_LPN_TXN_ERROR_FLAG            VARCHAR2 DEFAULT NULL,
  P_REQUEST_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  P_FROM_PUBLIC_API		  VARCHAR2 DEFAULT 'Y',
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2,
  P_WIP_ENTITY_ID                 NUMBER DEFAULT NULL,
  P_OPERATION_SEQ_NUM             NUMBER DEFAULT NULL,
  P_INTRAOPERATION_STEP_TYPE      NUMBER DEFAULT NULL

  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT update_row;

   -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

   -- API body


UPDATE MTL_SERIAL_NUMBERS
    SET
     DESCRIPTIVE_TEXT                =     decode(P_FROM_PUBLIC_API, 'N', P_DESCRIPTIVE_TEXT, decode(P_DESCRIPTIVE_TEXT, fnd_api.g_miss_char, null, decode(P_DESCRIPTIVE_TEXT, NULL, DESCRIPTIVE_TEXT, P_DESCRIPTIVE_TEXT))),
     CATEGORY_ID                     =     decode(P_FROM_PUBLIC_API, 'N', P_CATEGORY_ID, decode(P_CATEGORY_ID, fnd_api.g_miss_num, null, decode(P_CATEGORY_ID, NULL, CATEGORY_ID, P_CATEGORY_ID))),
     PROD_ORGANIZATION_ID            =     decode(P_FROM_PUBLIC_API, 'N', P_PROD_ORGANIZATION_ID, decode(P_PROD_ORGANIZATION_ID, fnd_api.g_miss_num, null, decode(P_PROD_ORGANIZATION_ID, NULL, PROD_ORGANIZATION_ID, P_PROD_ORGANIZATION_ID))),
     EQUIPMENT_ITEM_ID               =     decode(P_FROM_PUBLIC_API, 'N', P_EQUIPMENT_ITEM_ID, decode(P_EQUIPMENT_ITEM_ID, fnd_api.g_miss_num, null, decode(P_EQUIPMENT_ITEM_ID, NULL, EQUIPMENT_ITEM_ID, P_EQUIPMENT_ITEM_ID))),
     EQP_SERIAL_NUMBER               =     decode(P_FROM_PUBLIC_API, 'N', P_EQP_SERIAL_NUMBER, decode(P_EQP_SERIAL_NUMBER, fnd_api.g_miss_char, null, decode(P_EQP_SERIAL_NUMBER, NULL, EQP_SERIAL_NUMBER, P_EQP_SERIAL_NUMBER))),
     PN_LOCATION_ID                  =     decode(P_FROM_PUBLIC_API, 'N', P_PN_LOCATION_ID, decode(P_PN_LOCATION_ID, fnd_api.g_miss_num, null, decode(P_PN_LOCATION_ID, NULL, PN_LOCATION_ID, P_PN_LOCATION_ID))),
     EAM_LOCATION_ID                 =     decode(P_FROM_PUBLIC_API, 'N', P_EAM_LOCATION_ID, decode(P_EAM_LOCATION_ID, fnd_api.g_miss_num, null, decode(P_EAM_LOCATION_ID, NULL, EAM_LOCATION_ID, P_EAM_LOCATION_ID))),
     FA_ASSET_ID                     =     decode(P_FROM_PUBLIC_API, 'N', P_FA_ASSET_ID, decode(P_FA_ASSET_ID, fnd_api.g_miss_num, null, decode(P_FA_ASSET_ID, NULL, FA_ASSET_ID, P_FA_ASSET_ID))),
     ASSET_CRITICALITY_CODE          =     decode(P_FROM_PUBLIC_API, 'N', P_ASSET_CRITICALITY_CODE, decode(P_ASSET_CRITICALITY_CODE, fnd_api.g_miss_char, null, decode(P_ASSET_CRITICALITY_CODE, NULL, ASSET_CRITICALITY_CODE, P_ASSET_CRITICALITY_CODE))),
     WIP_ACCOUNTING_CLASS_CODE       =     decode(P_FROM_PUBLIC_API, 'N',
P_WIP_ACCOUNTING_CLASS_CODE, decode(P_WIP_ACCOUNTING_CLASS_CODE, fnd_api.g_miss_char, null,
decode(P_WIP_ACCOUNTING_CLASS_CODE, NULL, WIP_ACCOUNTING_CLASS_CODE, P_WIP_ACCOUNTING_CLASS_CODE))),
     NETWORK_ASSET_FLAG              =     decode(P_FROM_PUBLIC_API, 'N', P_NETWORK_ASSET_FLAG, decode(P_NETWORK_ASSET_FLAG, fnd_api.g_miss_char, null, decode(P_NETWORK_ASSET_FLAG, NULL, NETWORK_ASSET_FLAG, P_NETWORK_ASSET_FLAG))),
     MAINTAINABLE_FLAG               =     decode(P_FROM_PUBLIC_API, 'N', P_MAINTAINABLE_FLAG, decode(P_MAINTAINABLE_FLAG, fnd_api.g_miss_char, null, decode(P_MAINTAINABLE_FLAG, NULL, MAINTAINABLE_FLAG, P_MAINTAINABLE_FLAG))),
     OWNING_DEPARTMENT_ID            =     decode(P_FROM_PUBLIC_API, 'N', P_OWNING_DEPARTMENT_ID, decode(P_OWNING_DEPARTMENT_ID, fnd_api.g_miss_num, null, decode(P_OWNING_DEPARTMENT_ID, NULL, OWNING_DEPARTMENT_ID, P_OWNING_DEPARTMENT_ID))),
     LAST_UPDATE_DATE                =     decode(P_FROM_PUBLIC_API, 'N', P_LAST_UPDATE_DATE, decode(P_LAST_UPDATE_DATE, fnd_api.g_miss_date, null, decode(P_LAST_UPDATE_DATE, NULL, LAST_UPDATE_DATE, P_LAST_UPDATE_DATE))),
     LAST_UPDATED_BY                 =     decode(P_FROM_PUBLIC_API, 'N', P_LAST_UPDATED_BY, decode(P_LAST_UPDATED_BY, fnd_api.g_miss_num, null, decode(P_LAST_UPDATED_BY, NULL, LAST_UPDATED_BY, P_LAST_UPDATED_BY))),
     LAST_UPDATE_LOGIN               =     decode(P_FROM_PUBLIC_API, 'N', P_LAST_UPDATE_LOGIN, decode(P_LAST_UPDATE_LOGIN, fnd_api.g_miss_num, null, decode(P_LAST_UPDATE_LOGIN, NULL, LAST_UPDATE_LOGIN, P_LAST_UPDATE_LOGIN))),
     ATTRIBUTE_CATEGORY              =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE_CATEGORY, decode(P_ATTRIBUTE_CATEGORY, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE_CATEGORY, NULL, ATTRIBUTE_CATEGORY, P_ATTRIBUTE_CATEGORY))),
     ATTRIBUTE1                      =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE1, decode(P_ATTRIBUTE1, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE1, NULL, ATTRIBUTE1, P_ATTRIBUTE1))),
     ATTRIBUTE2                      =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE2, decode(P_ATTRIBUTE2, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE2, NULL, ATTRIBUTE2, P_ATTRIBUTE2))),
     ATTRIBUTE3                      =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE3, decode(P_ATTRIBUTE3, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE3, NULL, ATTRIBUTE3, P_ATTRIBUTE3))),
     ATTRIBUTE4                      =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE4, decode(P_ATTRIBUTE4, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE4, NULL, ATTRIBUTE4, P_ATTRIBUTE4))),
     ATTRIBUTE5                      =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE5, decode(P_ATTRIBUTE5, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE5, NULL, ATTRIBUTE5, P_ATTRIBUTE5))),
     ATTRIBUTE6                      =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE6, decode(P_ATTRIBUTE6, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE6, NULL, ATTRIBUTE6, P_ATTRIBUTE6))),
     ATTRIBUTE7                      =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE7, decode(P_ATTRIBUTE7, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE7, NULL, ATTRIBUTE7, P_ATTRIBUTE7))),
     ATTRIBUTE8                      =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE8, decode(P_ATTRIBUTE8, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE8, NULL, ATTRIBUTE8, P_ATTRIBUTE8))),
     ATTRIBUTE9                      =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE9, decode(P_ATTRIBUTE9, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE9, NULL, ATTRIBUTE9, P_ATTRIBUTE9))),
     ATTRIBUTE10                     =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE10, decode(P_ATTRIBUTE10, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE10, NULL, ATTRIBUTE10, P_ATTRIBUTE10))),
     ATTRIBUTE11                     =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE11, decode(P_ATTRIBUTE11, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE11, NULL, ATTRIBUTE11, P_ATTRIBUTE11))),
     ATTRIBUTE12                     =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE12, decode(P_ATTRIBUTE12, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE12, NULL, ATTRIBUTE12, P_ATTRIBUTE12))),
     ATTRIBUTE13                     =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE13, decode(P_ATTRIBUTE13, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE13, NULL, ATTRIBUTE13, P_ATTRIBUTE13))),
     ATTRIBUTE14                     =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE14, decode(P_ATTRIBUTE14, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE14, NULL, ATTRIBUTE14, P_ATTRIBUTE14))),
     ATTRIBUTE15                     =     decode(P_FROM_PUBLIC_API, 'N', P_ATTRIBUTE15, decode(P_ATTRIBUTE15, fnd_api.g_miss_char, null, decode(P_ATTRIBUTE15, NULL, ATTRIBUTE15, P_ATTRIBUTE15))),
     CURRENT_STATUS                  =     decode(P_FROM_PUBLIC_API, 'N', P_CURRENT_STATUS, decode(P_CURRENT_STATUS, fnd_api.g_miss_num, null, decode(P_CURRENT_STATUS, NULL, CURRENT_STATUS, P_CURRENT_STATUS))),
     INITIALIZATION_DATE             =     decode(P_FROM_PUBLIC_API, 'N', P_INITIALIZATION_DATE, decode(P_INITIALIZATION_DATE, fnd_api.g_miss_date, null, decode(P_INITIALIZATION_DATE, NULL, INITIALIZATION_DATE, P_INITIALIZATION_DATE))),
     COMPLETION_DATE                 =     decode(P_FROM_PUBLIC_API, 'N', P_COMPLETION_DATE, decode(P_COMPLETION_DATE, fnd_api.g_miss_date, null, decode(P_COMPLETION_DATE, NULL, COMPLETION_DATE, P_COMPLETION_DATE))),
     SHIP_DATE                       =     decode(P_FROM_PUBLIC_API, 'N', P_SHIP_DATE, decode(P_SHIP_DATE, fnd_api.g_miss_date, null, decode(P_SHIP_DATE, NULL, SHIP_DATE, P_SHIP_DATE))),
     REVISION                        =     decode(P_FROM_PUBLIC_API, 'N', P_REVISION, decode(P_REVISION, fnd_api.g_miss_char, null, decode(P_REVISION, NULL, REVISION, P_REVISION))),

     LOT_NUMBER                      =     decode(P_FROM_PUBLIC_API, 'N', P_LOT_NUMBER, decode(P_LOT_NUMBER, fnd_api.g_miss_char, null, decode(P_LOT_NUMBER, NULL, LOT_NUMBER, P_LOT_NUMBER))),
     FIXED_ASSET_TAG                 =     decode(P_FROM_PUBLIC_API, 'N', P_FIXED_ASSET_TAG, decode(P_FIXED_ASSET_TAG, fnd_api.g_miss_char, null, decode(P_FIXED_ASSET_TAG, NULL, FIXED_ASSET_TAG, P_FIXED_ASSET_TAG))),
     RESERVED_ORDER_ID               =     decode(P_FROM_PUBLIC_API, 'N', P_RESERVED_ORDER_ID, decode(P_RESERVED_ORDER_ID, fnd_api.g_miss_num, null, decode(P_RESERVED_ORDER_ID, NULL, RESERVED_ORDER_ID, P_RESERVED_ORDER_ID))),
     PARENT_ITEM_ID                  =     decode(P_FROM_PUBLIC_API, 'N', P_PARENT_ITEM_ID, decode(P_PARENT_ITEM_ID, fnd_api.g_miss_num, null, decode(P_PARENT_ITEM_ID, NULL, PARENT_ITEM_ID, P_PARENT_ITEM_ID))),
     PARENT_SERIAL_NUMBER            =     decode(P_FROM_PUBLIC_API, 'N', P_PARENT_SERIAL_NUMBER, decode(P_PARENT_SERIAL_NUMBER, fnd_api.g_miss_char, null, decode(P_PARENT_SERIAL_NUMBER, NULL, PARENT_SERIAL_NUMBER, P_PARENT_SERIAL_NUMBER))),
     ORIGINAL_WIP_ENTITY_ID          =     decode(P_FROM_PUBLIC_API, 'N', P_ORIGINAL_WIP_ENTITY_ID,
decode(P_ORIGINAL_WIP_ENTITY_ID, fnd_api.g_miss_num, null, decode(P_ORIGINAL_WIP_ENTITY_ID, NULL, ORIGINAL_WIP_ENTITY_ID, P_ORIGINAL_WIP_ENTITY_ID))),
     ORIGINAL_UNIT_VENDOR_ID         =     decode(P_FROM_PUBLIC_API, 'N', P_ORIGINAL_UNIT_VENDOR_ID,
decode(P_ORIGINAL_UNIT_VENDOR_ID, fnd_api.g_miss_num, null, decode(P_ORIGINAL_UNIT_VENDOR_ID, NULL, ORIGINAL_UNIT_VENDOR_ID, P_ORIGINAL_UNIT_VENDOR_ID))),
     VENDOR_SERIAL_NUMBER            =     decode(P_FROM_PUBLIC_API, 'N', P_VENDOR_SERIAL_NUMBER, decode(P_VENDOR_SERIAL_NUMBER, fnd_api.g_miss_char, null, decode(P_VENDOR_SERIAL_NUMBER, NULL, VENDOR_SERIAL_NUMBER, P_VENDOR_SERIAL_NUMBER))),
     VENDOR_LOT_NUMBER               =     decode(P_FROM_PUBLIC_API, 'N', P_VENDOR_LOT_NUMBER, decode(P_VENDOR_LOT_NUMBER, fnd_api.g_miss_char, null, decode(P_VENDOR_LOT_NUMBER, NULL, VENDOR_LOT_NUMBER, P_VENDOR_LOT_NUMBER))),
     LAST_TXN_SOURCE_TYPE_ID         =     decode(P_FROM_PUBLIC_API, 'N', P_LAST_TXN_SOURCE_TYPE_ID, decode(P_LAST_TXN_SOURCE_TYPE_ID, fnd_api.g_miss_num, null,
decode(P_LAST_TXN_SOURCE_TYPE_ID, NULL, LAST_TXN_SOURCE_TYPE_ID, P_LAST_TXN_SOURCE_TYPE_ID))),
     LAST_TRANSACTION_ID             =     decode(P_FROM_PUBLIC_API, 'N', P_LAST_TRANSACTION_ID, decode(P_LAST_TRANSACTION_ID, fnd_api.g_miss_num, null, decode(P_LAST_TRANSACTION_ID, NULL, LAST_TRANSACTION_ID, P_LAST_TRANSACTION_ID))),
     LAST_RECEIPT_ISSUE_TYPE         =     decode(P_FROM_PUBLIC_API, 'N', P_LAST_RECEIPT_ISSUE_TYPE, decode(P_LAST_RECEIPT_ISSUE_TYPE, fnd_api.g_miss_num, null,
decode(P_LAST_RECEIPT_ISSUE_TYPE, NULL, LAST_RECEIPT_ISSUE_TYPE, P_LAST_RECEIPT_ISSUE_TYPE))),
     LAST_TXN_SOURCE_NAME            =     decode(P_FROM_PUBLIC_API, 'N', P_LAST_TXN_SOURCE_NAME, decode(P_LAST_TXN_SOURCE_NAME, fnd_api.g_miss_char, null, decode(P_LAST_TXN_SOURCE_NAME, NULL, LAST_TXN_SOURCE_NAME, P_LAST_TXN_SOURCE_NAME))),
     LAST_TXN_SOURCE_ID              =     decode(P_FROM_PUBLIC_API, 'N', P_LAST_TXN_SOURCE_ID, decode(P_LAST_TXN_SOURCE_ID, fnd_api.g_miss_num, null, decode(P_LAST_TXN_SOURCE_ID, NULL, LAST_TXN_SOURCE_ID, P_LAST_TXN_SOURCE_ID))),
     CURRENT_SUBINVENTORY_CODE       =     decode(P_FROM_PUBLIC_API, 'N', P_CURRENT_SUBINVENTORY_CODE, decode(P_CURRENT_SUBINVENTORY_CODE, fnd_api.g_miss_char, null,
decode(P_CURRENT_SUBINVENTORY_CODE, NULL, CURRENT_SUBINVENTORY_CODE, P_CURRENT_SUBINVENTORY_CODE))),
     CURRENT_LOCATOR_ID              =     decode(P_FROM_PUBLIC_API, 'N', P_CURRENT_LOCATOR_ID, decode(P_CURRENT_LOCATOR_ID, fnd_api.g_miss_num, null, decode(P_CURRENT_LOCATOR_ID, NULL, CURRENT_LOCATOR_ID, P_CURRENT_LOCATOR_ID))),
     GROUP_MARK_ID                   =     decode(P_FROM_PUBLIC_API, 'N', P_GROUP_MARK_ID, decode(P_GROUP_MARK_ID, fnd_api.g_miss_num, null, decode(P_GROUP_MARK_ID, NULL, GROUP_MARK_ID, P_GROUP_MARK_ID))),
     LINE_MARK_ID                    =     decode(P_FROM_PUBLIC_API, 'N', P_LINE_MARK_ID, decode(P_LINE_MARK_ID, fnd_api.g_miss_num, null, decode(P_LINE_MARK_ID, NULL, LINE_MARK_ID, P_LINE_MARK_ID))),
     LOT_LINE_MARK_ID                =     decode(P_FROM_PUBLIC_API, 'N', P_LOT_LINE_MARK_ID, decode(P_LOT_LINE_MARK_ID, fnd_api.g_miss_num, null, decode(P_LOT_LINE_MARK_ID, NULL, LOT_LINE_MARK_ID, P_LOT_LINE_MARK_ID))),
     END_ITEM_UNIT_NUMBER            =     decode(P_FROM_PUBLIC_API, 'N', P_END_ITEM_UNIT_NUMBER, decode(P_END_ITEM_UNIT_NUMBER, fnd_api.g_miss_char, null, decode(P_END_ITEM_UNIT_NUMBER, NULL, END_ITEM_UNIT_NUMBER, P_END_ITEM_UNIT_NUMBER))),
     SERIAL_ATTRIBUTE_CATEGORY       =     decode(P_FROM_PUBLIC_API, 'N', P_SERIAL_ATTRIBUTE_CATEGORY, decode(P_SERIAL_ATTRIBUTE_CATEGORY, fnd_api.g_miss_char, null,
decode(P_SERIAL_ATTRIBUTE_CATEGORY, NULL, SERIAL_ATTRIBUTE_CATEGORY, P_SERIAL_ATTRIBUTE_CATEGORY))),
     ORIGINATION_DATE                =     decode(P_FROM_PUBLIC_API, 'N', P_ORIGINATION_DATE, decode(P_ORIGINATION_DATE, fnd_api.g_miss_date, null, decode(P_ORIGINATION_DATE, NULL, ORIGINATION_DATE, P_ORIGINATION_DATE))),

     C_ATTRIBUTE1                    =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE1, decode(P_C_ATTRIBUTE1, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE1, NULL, C_ATTRIBUTE1, P_C_ATTRIBUTE1))),
     C_ATTRIBUTE2                    =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE2, decode(P_C_ATTRIBUTE2, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE2, NULL, C_ATTRIBUTE2, P_C_ATTRIBUTE2))),
     C_ATTRIBUTE3                    =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE3, decode(P_C_ATTRIBUTE3, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE3, NULL, C_ATTRIBUTE3, P_C_ATTRIBUTE3))),
     C_ATTRIBUTE4                    =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE4, decode(P_C_ATTRIBUTE4, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE4, NULL, C_ATTRIBUTE4, P_C_ATTRIBUTE4))),
     C_ATTRIBUTE5                    =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE5, decode(P_C_ATTRIBUTE5, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE5, NULL, C_ATTRIBUTE5, P_C_ATTRIBUTE5))),
     C_ATTRIBUTE6                    =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE6, decode(P_C_ATTRIBUTE6, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE6, NULL, C_ATTRIBUTE6, P_C_ATTRIBUTE6))),
     C_ATTRIBUTE7                    =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE7, decode(P_C_ATTRIBUTE7, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE7, NULL, C_ATTRIBUTE7, P_C_ATTRIBUTE7))),
     C_ATTRIBUTE8                    =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE8, decode(P_C_ATTRIBUTE8, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE8, NULL, C_ATTRIBUTE8, P_C_ATTRIBUTE8))),
     C_ATTRIBUTE9                    =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE9, decode(P_C_ATTRIBUTE9, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE9, NULL, C_ATTRIBUTE9, P_C_ATTRIBUTE9))),
     C_ATTRIBUTE10                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE10, decode(P_C_ATTRIBUTE10, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE10, NULL, C_ATTRIBUTE10, P_C_ATTRIBUTE10))),
     C_ATTRIBUTE11                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE11, decode(P_C_ATTRIBUTE11, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE11, NULL, C_ATTRIBUTE11, P_C_ATTRIBUTE11))),
     C_ATTRIBUTE12                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE12, decode(P_C_ATTRIBUTE12, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE12, NULL, C_ATTRIBUTE12, P_C_ATTRIBUTE12))),
     C_ATTRIBUTE13                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE13, decode(P_C_ATTRIBUTE13, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE13, NULL, C_ATTRIBUTE13, P_C_ATTRIBUTE13))),
     C_ATTRIBUTE14                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE14, decode(P_C_ATTRIBUTE14, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE14, NULL, C_ATTRIBUTE14, P_C_ATTRIBUTE14))),
     C_ATTRIBUTE15                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE15, decode(P_C_ATTRIBUTE15, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE15, NULL, C_ATTRIBUTE15, P_C_ATTRIBUTE15))),
     C_ATTRIBUTE16                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE16, decode(P_C_ATTRIBUTE16, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE16, NULL, C_ATTRIBUTE16, P_C_ATTRIBUTE16))),
     C_ATTRIBUTE17                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE17, decode(P_C_ATTRIBUTE17, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE17, NULL, C_ATTRIBUTE17, P_C_ATTRIBUTE17))),
     C_ATTRIBUTE18                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE18, decode(P_C_ATTRIBUTE18, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE18, NULL, C_ATTRIBUTE18, P_C_ATTRIBUTE18))),
     C_ATTRIBUTE19                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE19, decode(P_C_ATTRIBUTE19, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE19, NULL, C_ATTRIBUTE19, P_C_ATTRIBUTE19))),
     C_ATTRIBUTE20                   =     decode(P_FROM_PUBLIC_API, 'N', P_C_ATTRIBUTE20, decode(P_C_ATTRIBUTE20, fnd_api.g_miss_char, null, decode(P_C_ATTRIBUTE20, NULL, C_ATTRIBUTE20, P_C_ATTRIBUTE20))),
     D_ATTRIBUTE1                    =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE1, decode(P_D_ATTRIBUTE1, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE1, NULL, D_ATTRIBUTE1, P_D_ATTRIBUTE1))),
     D_ATTRIBUTE2                    =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE2, decode(P_D_ATTRIBUTE2, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE2, NULL, D_ATTRIBUTE2, P_D_ATTRIBUTE2))),
     D_ATTRIBUTE3                    =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE3, decode(P_D_ATTRIBUTE3, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE3, NULL, D_ATTRIBUTE3, P_D_ATTRIBUTE3))),
     D_ATTRIBUTE4                    =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE4, decode(P_D_ATTRIBUTE4, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE4, NULL, D_ATTRIBUTE4, P_D_ATTRIBUTE4))),
     D_ATTRIBUTE5                    =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE5, decode(P_D_ATTRIBUTE5, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE5, NULL, D_ATTRIBUTE5, P_D_ATTRIBUTE5))),
     D_ATTRIBUTE6                    =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE6, decode(P_D_ATTRIBUTE6, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE6, NULL, D_ATTRIBUTE6, P_D_ATTRIBUTE6))),
     D_ATTRIBUTE7                    =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE7, decode(P_D_ATTRIBUTE7, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE7, NULL, D_ATTRIBUTE7, P_D_ATTRIBUTE7))),
     D_ATTRIBUTE8                    =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE8, decode(P_D_ATTRIBUTE8, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE8, NULL, D_ATTRIBUTE8, P_D_ATTRIBUTE8))),
     D_ATTRIBUTE9                    =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE9, decode(P_D_ATTRIBUTE9, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE9, NULL, D_ATTRIBUTE9, P_D_ATTRIBUTE9))),
     D_ATTRIBUTE10                   =     decode(P_FROM_PUBLIC_API, 'N', P_D_ATTRIBUTE10, decode(P_D_ATTRIBUTE10, fnd_api.g_miss_date, null, decode(P_D_ATTRIBUTE10, NULL, D_ATTRIBUTE10, P_D_ATTRIBUTE10))),
     N_ATTRIBUTE1                    =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE1, decode(P_N_ATTRIBUTE1, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE1, NULL, N_ATTRIBUTE1, P_N_ATTRIBUTE1))),
     N_ATTRIBUTE2                    =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE2, decode(P_N_ATTRIBUTE2, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE2, NULL, N_ATTRIBUTE2, P_N_ATTRIBUTE2))),
     N_ATTRIBUTE3                    =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE3, decode(P_N_ATTRIBUTE3, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE3, NULL, N_ATTRIBUTE3, P_N_ATTRIBUTE3))),
     N_ATTRIBUTE4                    =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE4, decode(P_N_ATTRIBUTE4, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE4, NULL, N_ATTRIBUTE4, P_N_ATTRIBUTE4))),
     N_ATTRIBUTE5                    =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE5, decode(P_N_ATTRIBUTE5, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE5, NULL, N_ATTRIBUTE5, P_N_ATTRIBUTE5))),
     N_ATTRIBUTE6                    =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE6, decode(P_N_ATTRIBUTE6, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE6, NULL, N_ATTRIBUTE6, P_N_ATTRIBUTE6))),
     N_ATTRIBUTE7                    =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE7, decode(P_N_ATTRIBUTE7, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE7, NULL, N_ATTRIBUTE7, P_N_ATTRIBUTE7))),
     N_ATTRIBUTE8                    =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE8, decode(P_N_ATTRIBUTE8, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE8, NULL, N_ATTRIBUTE8, P_N_ATTRIBUTE8))),
     N_ATTRIBUTE9                    =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE9, decode(P_N_ATTRIBUTE9, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE9, NULL, N_ATTRIBUTE9, P_N_ATTRIBUTE9))),
     N_ATTRIBUTE10                   =     decode(P_FROM_PUBLIC_API, 'N', P_N_ATTRIBUTE10, decode(P_N_ATTRIBUTE10, fnd_api.g_miss_num, null, decode(P_N_ATTRIBUTE10, NULL, N_ATTRIBUTE10, P_N_ATTRIBUTE10))),
     STATUS_ID                       =     decode(P_FROM_PUBLIC_API, 'N', P_STATUS_ID, decode(P_STATUS_ID, fnd_api.g_miss_num, null, decode(P_STATUS_ID, NULL, STATUS_ID, STATUS_ID))),
     TERRITORY_CODE                  =     decode(P_FROM_PUBLIC_API, 'N', P_TERRITORY_CODE, decode(P_TERRITORY_CODE, fnd_api.g_miss_char, null, decode(P_TERRITORY_CODE, NULL, TERRITORY_CODE, P_TERRITORY_CODE))),
     COST_GROUP_ID                   =     decode(P_FROM_PUBLIC_API, 'N', P_COST_GROUP_ID, decode(P_COST_GROUP_ID, fnd_api.g_miss_num, null, decode(P_COST_GROUP_ID, NULL, COST_GROUP_ID, P_COST_GROUP_ID))),
     TIME_SINCE_NEW                  =     decode(P_FROM_PUBLIC_API, 'N', P_TIME_SINCE_NEW, decode(P_TIME_SINCE_NEW, fnd_api.g_miss_num, null, decode(P_TIME_SINCE_NEW, NULL, TIME_SINCE_NEW, P_TIME_SINCE_NEW))),
     CYCLES_SINCE_NEW                =     decode(P_FROM_PUBLIC_API, 'N', P_CYCLES_SINCE_NEW, decode(P_CYCLES_SINCE_NEW, fnd_api.g_miss_num, null, decode(P_CYCLES_SINCE_NEW, NULL, CYCLES_SINCE_NEW, P_CYCLES_SINCE_NEW))),
     TIME_SINCE_OVERHAUL             =     decode(P_FROM_PUBLIC_API, 'N', P_TIME_SINCE_OVERHAUL, decode(P_TIME_SINCE_OVERHAUL, fnd_api.g_miss_num, null, decode(P_TIME_SINCE_OVERHAUL, NULL, TIME_SINCE_OVERHAUL, P_TIME_SINCE_OVERHAUL))),
     CYCLES_SINCE_OVERHAUL           =     decode(P_FROM_PUBLIC_API, 'N', P_CYCLES_SINCE_OVERHAUL, decode(P_CYCLES_SINCE_OVERHAUL, fnd_api.g_miss_num, null, decode(P_CYCLES_SINCE_OVERHAUL, NULL, CYCLES_SINCE_OVERHAUL, P_CYCLES_SINCE_OVERHAUL))),
     TIME_SINCE_REPAIR               =     decode(P_FROM_PUBLIC_API, 'N', P_TIME_SINCE_REPAIR, decode(P_TIME_SINCE_REPAIR, fnd_api.g_miss_num, null, decode(P_TIME_SINCE_REPAIR, NULL, TIME_SINCE_REPAIR, P_TIME_SINCE_REPAIR))),
     CYCLES_SINCE_REPAIR             =     decode(P_FROM_PUBLIC_API, 'N', P_CYCLES_SINCE_REPAIR, decode(P_CYCLES_SINCE_REPAIR, fnd_api.g_miss_num, null, decode(P_CYCLES_SINCE_REPAIR, NULL, CYCLES_SINCE_REPAIR, P_CYCLES_SINCE_REPAIR))),
     TIME_SINCE_VISIT                =     decode(P_FROM_PUBLIC_API, 'N', P_TIME_SINCE_VISIT, decode(P_TIME_SINCE_VISIT, fnd_api.g_miss_num, null, decode(P_TIME_SINCE_VISIT, NULL, TIME_SINCE_VISIT, P_TIME_SINCE_VISIT))),
     CYCLES_SINCE_VISIT              =     decode(P_FROM_PUBLIC_API, 'N', P_CYCLES_SINCE_VISIT, decode(P_CYCLES_SINCE_VISIT, fnd_api.g_miss_num, null, decode(P_CYCLES_SINCE_VISIT, NULL, CYCLES_SINCE_VISIT, P_CYCLES_SINCE_VISIT))),
     TIME_SINCE_MARK                 =     decode(P_FROM_PUBLIC_API, 'N', P_TIME_SINCE_MARK, decode(P_TIME_SINCE_MARK, fnd_api.g_miss_num, null, decode(P_TIME_SINCE_MARK, NULL, TIME_SINCE_MARK, P_TIME_SINCE_MARK))),
     CYCLES_SINCE_MARK               =     decode(P_FROM_PUBLIC_API, 'N', P_CYCLES_SINCE_MARK, decode(P_CYCLES_SINCE_MARK, fnd_api.g_miss_num, null, decode(P_CYCLES_SINCE_MARK, NULL, CYCLES_SINCE_MARK, P_CYCLES_SINCE_MARK))),
     LPN_ID                          =     decode(P_FROM_PUBLIC_API, 'N', P_LPN_ID, decode(P_LPN_ID, fnd_api.g_miss_num, null, decode(P_LPN_ID, NULL, LPN_ID, P_LPN_ID))),
     INSPECTION_STATUS               =     decode(P_FROM_PUBLIC_API, 'N', P_INSPECTION_STATUS, decode(P_INSPECTION_STATUS, fnd_api.g_miss_num, null, decode(P_INSPECTION_STATUS, NULL, INSPECTION_STATUS, P_INSPECTION_STATUS))),
     PREVIOUS_STATUS                 =     decode(P_FROM_PUBLIC_API, 'N', P_PREVIOUS_STATUS, decode(P_PREVIOUS_STATUS, fnd_api.g_miss_num, null, decode(P_PREVIOUS_STATUS, NULL, PREVIOUS_STATUS, P_PREVIOUS_STATUS))),
     LPN_TXN_ERROR_FLAG              =     decode(P_FROM_PUBLIC_API, 'N', P_LPN_TXN_ERROR_FLAG, decode(P_LPN_TXN_ERROR_FLAG, fnd_api.g_miss_char, null, decode(P_LPN_TXN_ERROR_FLAG, NULL, LPN_TXN_ERROR_FLAG, P_LPN_TXN_ERROR_FLAG))),
     REQUEST_ID                      =     decode(P_FROM_PUBLIC_API, 'N', P_REQUEST_ID, decode(P_REQUEST_ID, fnd_api.g_miss_num, null, decode(P_REQUEST_ID, NULL, REQUEST_ID, P_REQUEST_ID))),
     PROGRAM_APPLICATION_ID          =     decode(P_FROM_PUBLIC_API, 'N', P_PROGRAM_APPLICATION_ID, decode(P_PROGRAM_APPLICATION_ID, fnd_api.g_miss_num, null, decode(P_PROGRAM_APPLICATION_ID, NULL, PROGRAM_APPLICATION_ID, P_PROGRAM_APPLICATION_ID))),
     PROGRAM_ID                      =     decode(P_FROM_PUBLIC_API, 'N', P_PROGRAM_ID, decode(P_PROGRAM_ID, fnd_api.g_miss_num, null, decode(P_PROGRAM_ID, NULL, PROGRAM_ID, P_PROGRAM_ID))),

     PROGRAM_UPDATE_DATE             =     decode(P_FROM_PUBLIC_API, 'N', P_PROGRAM_UPDATE_DATE, decode(P_PROGRAM_UPDATE_DATE, fnd_api.g_miss_date, null, decode(P_PROGRAM_UPDATE_DATE, NULL, PROGRAM_UPDATE_DATE, P_PROGRAM_UPDATE_DATE))),

    --'Serial Tracking in WIP' project- update WIP_ENTITY_ID, OPERATION_SEQ_NUM, INTRAOPERATION_STEP_TYPE also
     -- IN MSN.
     WIP_ENTITY_ID                   =     decode(P_FROM_PUBLIC_API, 'N', P_WIP_ENTITY_ID, NULL, decode(P_WIP_ENTITY_ID,fnd_api.g_miss_num, NULL, decode(P_WIP_ENTITY_ID, NULL, WIP_ENTITY_ID,P_WIP_ENTITY_ID))),

     OPERATION_SEQ_NUM               =     decode(P_FROM_PUBLIC_API, 'N', P_OPERATION_SEQ_NUM,
decode(P_OPERATION_SEQ_NUM, fnd_api.g_miss_num, NULL, decode(P_OPERATION_SEQ_NUM, NULL, OPERATION_SEQ_NUM, P_OPERATION_SEQ_NUM))),

     INTRAOPERATION_STEP_TYPE        =     decode(P_FROM_PUBLIC_API, 'N', P_INTRAOPERATION_STEP_TYPE,
decode(P_INTRAOPERATION_STEP_TYPE, fnd_api.g_miss_num, NULL, decode(P_INTRAOPERATION_STEP_TYPE, NULL, INTRAOPERATION_STEP_TYPE, P_INTRAOPERATION_STEP_TYPE)))
    WHERE ROWID = P_ROWID;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO update_row;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO update_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO update_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END Update_Row;


PROCEDURE LOCK_ROW(
  P_API_VERSION                IN NUMBER,
  P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                         VARCHAR2,
  P_INVENTORY_ITEM_ID             NUMBER,
  P_SERIAL_NUMBER                 VARCHAR2,
  P_START_DATE_ACTIVE             DATE,
  P_DESCRIPTIVE_TEXT              VARCHAR2,
  P_ORGANIZATION_ID               NUMBER,
  P_CATEGORY_ID                   NUMBER,
  P_PROD_ORGANIZATION_ID          NUMBER,
  P_EQUIPMENT_ITEM_ID             NUMBER,
  P_EQP_SERIAL_NUMBER             VARCHAR2,
  P_PN_LOCATION_ID                NUMBER,
  P_EAM_LOCATION_ID               NUMBER,
  P_FA_ASSET_ID                   NUMBER,
  P_ASSET_CRITICALITY_CODE        VARCHAR2,
  P_WIP_ACCOUNTING_CLASS_CODE     VARCHAR2,
  P_MAINTAINABLE_FLAG             VARCHAR2,
  P_NETWORK_ASSET_FLAG            VARCHAR2,
  P_OWNING_DEPARTMENT_ID          NUMBER,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2,
  P_ATTRIBUTE2                    VARCHAR2,
  P_ATTRIBUTE3                    VARCHAR2,
  P_ATTRIBUTE4                    VARCHAR2,
  P_ATTRIBUTE5                    VARCHAR2,
  P_ATTRIBUTE6                    VARCHAR2,
  P_ATTRIBUTE7                    VARCHAR2,
  P_ATTRIBUTE8                    VARCHAR2,
  P_ATTRIBUTE9                    VARCHAR2,
  P_ATTRIBUTE10                   VARCHAR2,
  P_ATTRIBUTE11                   VARCHAR2,
  P_ATTRIBUTE12                   VARCHAR2,
  P_ATTRIBUTE13                   VARCHAR2,
  P_ATTRIBUTE14                   VARCHAR2,
  P_ATTRIBUTE15                   VARCHAR2,
  P_REQUEST_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2,
  P_WIP_ENTITY_ID                 NUMBER,
  P_OPERATION_SEQ_NUM             NUMBER,
  P_INTRAOPERATION_STEP_TYPE      NUMBER
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

    CURSOR C IS
        SELECT *
        FROM   MTL_SERIAL_NUMBERS
        WHERE  rowid = P_Rowid
        FOR UPDATE of SERIAL_NUMBER NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT lock_row;

   -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

   -- API body

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (
       (Recinfo.INVENTORY_ITEM_ID =  P_INVENTORY_ITEM_ID)
       AND (Recinfo.CURRENT_ORGANIZATION_ID =  P_ORGANIZATION_ID)
       AND (Recinfo.SERIAL_NUMBER =  P_SERIAL_NUMBER)
       AND (   (Recinfo.DESCRIPTIVE_TEXT =  P_DESCRIPTIVE_TEXT)
            OR (    (Recinfo.DESCRIPTIVE_TEXT IS NULL)
                AND (P_DESCRIPTIVE_TEXT IS NULL)))
       AND (   (Recinfo.CATEGORY_ID =  P_CATEGORY_ID)
            OR (    (Recinfo.CATEGORY_ID IS NULL)
                AND (P_CATEGORY_ID IS NULL)))
       AND (   (Recinfo.PROD_ORGANIZATION_ID =  P_PROD_ORGANIZATION_ID)
            OR (    (Recinfo.PROD_ORGANIZATION_ID IS NULL)
                AND (P_PROD_ORGANIZATION_ID IS NULL)))
       AND (   (Recinfo.EQUIPMENT_ITEM_ID =  P_EQUIPMENT_ITEM_ID)
            OR (    (Recinfo.EQUIPMENT_ITEM_ID IS NULL)
                AND (P_EQUIPMENT_ITEM_ID IS NULL)))
       AND (   (Recinfo.EQP_SERIAL_NUMBER =  P_EQP_SERIAL_NUMBER)
            OR (    (Recinfo.EQP_SERIAL_NUMBER IS NULL)
                AND (P_EQP_SERIAL_NUMBER IS NULL)))
       AND (   (Recinfo.PN_LOCATION_ID =  P_PN_LOCATION_ID)
            OR (    (Recinfo.PN_LOCATION_ID IS NULL)
                AND (P_PN_LOCATION_ID IS NULL)))
       AND (   (Recinfo.EAM_LOCATION_ID =  P_EAM_LOCATION_ID)
            OR (    (Recinfo.EAM_LOCATION_ID IS NULL)
                AND (P_EAM_LOCATION_ID IS NULL)))
       AND (   (Recinfo.FA_ASSET_ID =  P_FA_ASSET_ID)
            OR (    (Recinfo.FA_ASSET_ID IS NULL)
                AND (P_FA_ASSET_ID IS NULL)))
       AND (   (Recinfo.ASSET_CRITICALITY_CODE =  P_ASSET_CRITICALITY_CODE)
            OR (    (Recinfo.ASSET_CRITICALITY_CODE IS NULL)
                AND (P_ASSET_CRITICALITY_CODE IS NULL)))
       AND (   (Recinfo.WIP_ACCOUNTING_CLASS_CODE =  P_WIP_ACCOUNTING_CLASS_CODE)
            OR (    (Recinfo.WIP_ACCOUNTING_CLASS_CODE IS NULL)
                AND (P_WIP_ACCOUNTING_CLASS_CODE IS NULL)))
       AND (   (Recinfo.MAINTAINABLE_FLAG =  P_MAINTAINABLE_FLAG)
            OR (    (Recinfo.MAINTAINABLE_FLAG IS NULL)
                AND (P_MAINTAINABLE_FLAG IS NULL)))
       AND (   (Recinfo.NETWORK_ASSET_FLAG =  P_NETWORK_ASSET_FLAG)
            OR (    (Recinfo.NETWORK_ASSET_FLAG IS NULL)
                AND (P_NETWORK_ASSET_FLAG IS NULL)))
       AND (   (Recinfo.OWNING_DEPARTMENT_ID =  P_OWNING_DEPARTMENT_ID)
            OR (    (Recinfo.OWNING_DEPARTMENT_ID IS NULL)
                AND (P_OWNING_DEPARTMENT_ID IS NULL)))
       AND (   (Recinfo.attribute_category =  P_Attribute_Category)
            OR (    (Recinfo.attribute_category IS NULL)
                AND (P_Attribute_Category IS NULL)))
       AND (   (Recinfo.attribute1 =  P_Attribute1)
            OR (    (Recinfo.attribute1 IS NULL)
                AND (P_Attribute1 IS NULL)))
       AND (   (Recinfo.attribute2 =  P_Attribute2)
            OR (    (Recinfo.attribute2 IS NULL)
                AND (P_Attribute2 IS NULL)))
       AND (   (Recinfo.attribute3 =  P_Attribute3)
            OR (    (Recinfo.attribute3 IS NULL)
                AND (P_Attribute3 IS NULL)))
       AND (   (Recinfo.attribute4 =  P_Attribute4)
            OR (    (Recinfo.attribute4 IS NULL)
                AND (P_Attribute4 IS NULL)))
       AND (   (Recinfo.attribute5 =  P_Attribute5)
            OR (    (Recinfo.attribute5 IS NULL)
                AND (P_Attribute5 IS NULL)))
       AND (   (Recinfo.attribute6 =  P_Attribute6)
            OR (    (Recinfo.attribute6 IS NULL)
                AND (P_Attribute6 IS NULL)))
       AND (   (Recinfo.attribute7 =  P_Attribute7)
            OR (    (Recinfo.attribute7 IS NULL)
                AND (P_Attribute7 IS NULL)))
       AND (   (Recinfo.attribute8 =  P_Attribute8)
            OR (    (Recinfo.attribute8 IS NULL)
                AND (P_Attribute8 IS NULL)))
       AND (   (Recinfo.attribute9 =  P_Attribute9)
            OR (    (Recinfo.attribute9 IS NULL)
                AND (P_Attribute9 IS NULL)))
       AND (   (Recinfo.attribute10 =  P_Attribute10)
            OR (    (Recinfo.attribute10 IS NULL)
                AND (P_Attribute10 IS NULL)))
       AND (   (Recinfo.attribute11 =  P_Attribute11)
            OR (    (Recinfo.attribute11 IS NULL)
                AND (P_Attribute11 IS NULL)))
       AND (   (Recinfo.attribute12 =  P_Attribute12)
            OR (    (Recinfo.attribute12 IS NULL)
                AND (P_Attribute12 IS NULL)))
       AND (   (Recinfo.attribute13 =  P_Attribute13)
            OR (    (Recinfo.attribute13 IS NULL)
                AND (P_Attribute13 IS NULL)))
       AND (   (Recinfo.attribute14 =  P_Attribute14)
            OR (    (Recinfo.attribute14 IS NULL)
                AND (P_Attribute14 IS NULL)))
       AND (   (Recinfo.attribute15 =  P_Attribute15)
            OR (    (Recinfo.attribute15 IS NULL)
                AND (P_Attribute15 IS NULL)))
       AND (   (Recinfo.REQUEST_ID = P_REQUEST_ID)
            OR (    (Recinfo.REQUEST_ID IS NULL)
                AND (P_REQUEST_ID IS NULL)))
       AND (   (Recinfo.PROGRAM_APPLICATION_ID = P_PROGRAM_APPLICATION_ID)
            OR (    (Recinfo.PROGRAM_APPLICATION_ID IS NULL)
                AND (P_PROGRAM_APPLICATION_ID IS NULL)))
       AND (   (Recinfo.PROGRAM_ID = P_PROGRAM_ID)
            OR (    (Recinfo.PROGRAM_ID IS NULL)
                AND (P_PROGRAM_ID IS NULL)))
       AND (   (Recinfo.PROGRAM_UPDATE_DATE = P_PROGRAM_UPDATE_DATE)
            OR (    (Recinfo.PROGRAM_UPDATE_DATE IS NULL)
                AND (P_PROGRAM_UPDATE_DATE IS NULL)))
    --'Serial Tracking in WIP' project- lock the row in MSN by including  WIP_ENTITY_ID, OPERATION_SEQ_NUM
    -- , INTRAOPERATION_STEP_TYPE also.
       AND ( (Recinfo.WIP_ENTITY_ID = P_WIP_ENTITY_ID)
		      OR( (Recinfo.WIP_ENTITY_ID is NULL)
			       AND (P_WIP_ENTITY_ID is NULL)))
	    AND ( (Recinfo.OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM)
	         OR( (Recinfo.OPERATION_SEQ_NUM is NULL)
			       AND (P_OPERATION_SEQ_NUM is NULL)))
       AND ( (Recinfo.INTRAOPERATION_STEP_TYPE = P_INTRAOPERATION_STEP_TYPE)
	         OR( (Recinfo. INTRAOPERATION_STEP_TYPE is NULL)
		          AND (P_INTRAOPERATION_STEP_TYPE is NULL)))
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO lock_row;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO lock_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO lock_row;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END Lock_Row;



END INV_EAM_ASSET_NUMBER_PVT;

/
