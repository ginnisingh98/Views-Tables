--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_GROUPS_PVT" AS
/* $Header: csdvrpgb.pls 115.12 2002/11/15 22:43:46 swai noship $ */


G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_REPAIR_GROUPS_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvrpgb.pls';
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;

----------------------------------------------------
-- procedure name: create_repair_groups
-- description   : procedure used to create
--                 group repair orders
--
----------------------------------------------------
PROCEDURE CREATE_REPAIR_GROUPS(
  p_api_version               IN     NUMBER,
  p_commit                    IN     VARCHAR2,
  p_init_msg_list             IN     VARCHAR2,
  p_validation_level          IN     NUMBER,
  x_repair_order_group_rec    IN OUT NOCOPY CSD_REPAIR_GROUPS_PVT.REPAIR_ORDER_GROUP_REC,
  x_repair_group_id           OUT NOCOPY    NUMBER,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2
)
IS

  l_api_name      CONSTANT VARCHAR2(30) := 'Create_Repair_Groups';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(100);
  l_msg_index              NUMBER;
  l_repair_group_id        NUMBER;
  l_repair_group_number    VARCHAR2(30);
  l_count                  NUMBER;

  CURSOR C1 IS
  SELECT CSD_REPAIR_ORDER_GROUPS_S1.NEXTVAL
  FROM sys.dual;


BEGIN
-----------------------------------
--Standard Start of API savepoint
-----------------------------------
  SAVEPOINT  create_repair_order_group;

-----------------------------------------------------
-- Standard call to check for call compatibility.
-----------------------------------------------------
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
---------------------------------------------------------------
-- Initialize message list if p_init_msg_list is set to TRUE.
---------------------------------------------------------------
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

--------------------------------------------
-- Initialize API return status to success
--------------------------------------------
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--------------------
-- Api body starts
--------------------
if (g_debug > 0) then
  csd_gen_utility_pvt.dump_api_info
  ( p_pkg_name  => G_PKG_NAME,
    p_api_name  => l_api_name );
end if;
------------------------------------------
-- Dump the in parameters in the log file
------------------------------------------
  --IF fnd_profile.value('CSD_DEBUG_LEVEL') > 5 THEN
 if (g_debug > 5) then
    csd_gen_utility_pvt.dump_repair_order_group_rec
      ( p_repair_order_group_rec => x_repair_order_group_rec);
  END IF;

-----------------------------------
-- Check for required parameters
-----------------------------------

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Check reqd parameter : Incident Id');
END IF;


  CSD_REPAIRS_UTIL.check_reqd_param
  (p_param_value => x_repair_order_group_rec.incident_id,
   p_param_name  => 'INCIDENT_ID',
   p_api_name    => l_api_name
  );

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Check reqd parameter : Inventory Item Id');
END IF;


  CSD_REPAIRS_UTIL.check_reqd_param
  (p_param_value => x_repair_order_group_rec.inventory_item_id,
   p_param_name  => 'INVENTORY_ITEM_ID',
   p_api_name    => l_api_name
  );

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Check reqd parameter : Unit of Measure');
END IF;


  CSD_REPAIRS_UTIL.check_reqd_param
  (p_param_value => x_repair_order_group_rec.unit_of_measure,
   p_param_name  => 'UNIT_OF_MEASURE',
   p_api_name    => l_api_name
  );

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Check reqd parameter : Repair Type Id');
END IF;


  CSD_REPAIRS_UTIL.check_reqd_param
  (p_param_value => x_repair_order_group_rec.repair_type_id,
   p_param_name  => 'REPAIR_TYPE_ID',
   p_api_name    => l_api_name
  );

---------------------------------
-- Validate the incident ID
---------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Validate Incident id');
END IF;


  IF NOT( CSD_PROCESS_UTIL.Validate_incident_id
        ( p_incident_id  => x_repair_order_group_rec.incident_id )) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;

---------------------------------
-- Validate the repair type ID
---------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Validate repair type id');
END IF;


  IF NOT( CSD_PROCESS_UTIL.Validate_repair_type_id
        ( p_repair_type_id  => x_repair_order_group_rec.repair_type_id )) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;

-----------------------------------
-- Validate the Inventory Item ID
-----------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Validate Inventory item id');
END IF;


  IF NOT( CSD_PROCESS_UTIL.Validate_inventory_item_id
        ( p_inventory_item_id  => x_repair_order_group_rec.inventory_item_id )) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;


---------------------------------
-- Validate the UOM Code
---------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Unit of Measure');
END IF;


  IF NOT( CSD_PROCESS_UTIL.Validate_unit_of_measure
        ( p_unit_of_measure  => x_repair_order_group_rec.unit_of_measure )) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;

---------------------------------
-- Validate Wip Entity Id
---------------------------------
  IF(x_repair_order_group_rec.wip_entity_id is not null and
    x_repair_order_group_rec.wip_entity_id <> FND_API.G_MISS_NUM) then

    IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.ADD('Wip Entity Id');
    END IF;


    IF NOT( CSD_PROCESS_UTIL.Validate_wip_entity_id
          ( p_wip_entity_id  => x_repair_order_group_rec.wip_entity_id )) THEN
           RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
--------------------------------------------
-- Assigning the group id and  group number
--------------------------------------------
  OPEN C1;
  FETCH C1 INTO l_repair_group_id;
  CLOSE C1;

  l_repair_group_number := to_char(l_repair_group_id);

---------------------------------------
-- Validate group id and group number
---------------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Validate the Group ID and Number');
END IF;


  if(l_repair_group_id is null) then
    FND_MESSAGE.Set_Name('CSD', 'CSD_API_REPAIR_GROUP_ID');
    FND_MESSAGE.Set_Token('REPAIR_GROUP_ID',l_repair_group_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;
-----------------------
-- insert into table
-----------------------

  x_repair_order_group_rec.object_version_number := 1;

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Calling : CSD_REPAIR_ORDER_GROUPS_PKG.Insert_Row');
END IF;


  CSD_REPAIR_ORDER_GROUPS_PKG.Insert_Row
  (px_REPAIR_GROUP_ID          =>  l_repair_group_id,
   p_INCIDENT_ID               =>  x_repair_order_group_rec.incident_id,
   p_REPAIR_GROUP_NUMBER       =>  l_repair_group_number,
   p_REPAIR_TYPE_ID            =>  x_repair_order_group_rec.repair_type_id,
   p_WIP_ENTITY_ID             =>  x_repair_order_group_rec.wip_entity_id,
   p_INVENTORY_ITEM_ID         =>  x_repair_order_group_rec.inventory_item_id,
   p_UNIT_OF_MEASURE           =>  x_repair_order_group_rec.unit_of_measure,
   p_GROUP_QUANTITY            =>  x_repair_order_group_rec.group_quantity,
   p_REPAIR_ORDER_QUANTITY     =>  x_repair_order_group_rec.repair_order_quantity,
   p_RMA_QUANTITY              =>  x_repair_order_group_rec.rma_quantity,
   p_RECEIVED_QUANTITY         =>  x_repair_order_group_rec.received_quantity,
   p_APPROVED_QUANTITY         =>  x_repair_order_group_rec.approved_quantity,
   p_SUBMITTED_QUANTITY        =>  x_repair_order_group_rec.submitted_quantity,
   p_COMPLETED_QUANTITY        =>  x_repair_order_group_rec.completed_quantity,
   p_RELEASED_QUANTITY         =>  x_repair_order_group_rec.released_quantity,
   p_SHIPPED_QUANTITY          =>  x_repair_order_group_rec.shipped_quantity,
   p_CREATED_BY                =>  FND_GLOBAL.USER_ID,
   p_CREATION_DATE             =>  SYSDATE,
   p_LAST_UPDATED_BY           =>  FND_GLOBAL.USER_ID,
   p_LAST_UPDATE_DATE          =>  SYSDATE,
   p_LAST_UPDATE_LOGIN         =>  FND_GLOBAL.LOGIN_ID,
   p_CONTEXT                   =>  x_repair_order_group_rec.context,
   p_ATTRIBUTE1                =>  x_repair_order_group_rec.attribute1,
   p_ATTRIBUTE2                =>  x_repair_order_group_rec.attribute2,
   p_ATTRIBUTE3                =>  x_repair_order_group_rec.attribute3,
   p_ATTRIBUTE4                =>  x_repair_order_group_rec.attribute4,
   p_ATTRIBUTE5                =>  x_repair_order_group_rec.attribute5,
   p_ATTRIBUTE6                =>  x_repair_order_group_rec.attribute6,
   p_ATTRIBUTE7                =>  x_repair_order_group_rec.attribute7,
   p_ATTRIBUTE8                =>  x_repair_order_group_rec.attribute8,
   p_ATTRIBUTE9                =>  x_repair_order_group_rec.attribute9,
   p_ATTRIBUTE10               =>  x_repair_order_group_rec.attribute10,
   p_ATTRIBUTE11               =>  x_repair_order_group_rec.attribute11,
   p_ATTRIBUTE12               =>  x_repair_order_group_rec.attribute12,
   p_ATTRIBUTE13               =>  x_repair_order_group_rec.attribute13,
   p_ATTRIBUTE14               =>  x_repair_order_group_rec.attribute14,
   p_ATTRIBUTE15               =>  x_repair_order_group_rec.attribute15,
   p_OBJECT_VERSION_NUMBER     =>  1,
   p_GROUP_TXN_STATUS          =>  x_repair_order_group_rec.group_txn_status,
   p_GROUP_APPROVAL_STATUS     =>  x_repair_order_group_rec.group_approval_status,
   p_REPAIR_MODE               =>  x_repair_order_group_rec.repair_mode);

   x_repair_order_group_rec.repair_group_id     := l_repair_group_id;
   x_repair_order_group_rec.repair_group_number := l_repair_group_number;
   x_repair_group_id := l_repair_group_number;

-------------
-- API Ends
-------------

--------------------------------
-- Standard check for p_commit
--------------------------------

   IF FND_API.to_Boolean(p_commit)
   THEN
      COMMIT;
   END IF;

--------------------------------------------------------------------------
-- Standard call to get message count and if count is 1, get message info.
--------------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO create_repair_order_group;
        FND_MSG_PUB.Count_And_Get
            (p_count  =>  x_msg_count,
             p_data   =>  x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO create_repair_order_group;
        FND_MSG_PUB.Count_And_Get
              ( p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO create_repair_order_group;
            IF  FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME ,
                 l_api_name  );
            END IF;
                FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

END CREATE_REPAIR_GROUPS;

----------------------------------------------------
-- procedure name: update_repair_groups
-- description   : procedure used to update
--                 group repair orders
--
----------------------------------------------------

PROCEDURE UPDATE_REPAIR_GROUPS
( p_api_version              IN     NUMBER,
  p_commit                   IN     VARCHAR2,
  p_init_msg_list            IN     VARCHAR2,
  p_validation_level         IN     NUMBER,
  x_repair_order_group_rec   IN OUT NOCOPY CSD_REPAIR_GROUPS_PVT.REPAIR_ORDER_GROUP_REC,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2
)
IS

  l_api_name               CONSTANT VARCHAR2(30) := 'Update_Repair_Groups';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(100);
  l_msg_index              NUMBER;
  l_obj_ver_num            NUMBER;
  l_repair_group_id        NUMBER;
  l_dummy                  VARCHAR2(30);
  l_count                  NUMBER;
  l_repair_type_id         NUMBER;
  l_inventory_item_id      NUMBER;
  l_unit_of_measure        VARCHAR2(3);
  l_group_quantity         NUMBER;

  CURSOR repair_order_group(p_repair_group_id IN NUMBER) IS
  SELECT
     repair_group_id,
     object_version_number
  FROM  csd_repair_order_groups
  WHERE repair_group_id = p_repair_group_id;

BEGIN

-----------------------------------
-- Standard Start of API savepoint
-----------------------------------
   SAVEPOINT  update_repair_order_group;

--------------------------------------------------
-- Standard call to check for call compatibility.
--------------------------------------------------
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

--------------------------------------------------------------
-- Initialize message list if p_init_msg_list is set to TRUE.
--------------------------------------------------------------
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

--------------------------------------------
-- Initialize API return status to success
--------------------------------------------
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--------------------
-- Api body starts
--------------------
if (g_debug > 0) then

  csd_gen_utility_pvt.dump_api_info
  ( p_pkg_name  => G_PKG_NAME,
  p_api_name    => l_api_name );
end if;
------------------------------------------
-- Dump the in parameters in the log file
------------------------------------------
  --IF fnd_profile.value('CSD_DEBUG_LEVEL') > 5 THEN
  if (g_debug > 5) then
   csd_gen_utility_pvt.dump_repair_order_group_rec
    ( p_repair_order_group_rec => x_repair_order_group_rec);
  END IF;


---------------------------------
-- Check the required parameter
---------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Check reqd parameter : Repair Group Id');
END IF;


  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value  => x_repair_order_group_rec.repair_group_id,
    p_param_name   => 'REPAIR_GROUP_ID',
    p_api_name     => l_api_name);

---------------------------------
-- Validate Repair Group Id
---------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Repair Group Id');
END IF;


  IF NOT( CSD_PROCESS_UTIL.Validate_repair_group_id
        ( p_repair_group_id  => x_repair_order_group_rec.repair_group_id )) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;

---------------------------------------
-- Fetch the Group info
---------------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Fetch the Group Id for Update');
END IF;


  IF NVL(x_repair_order_group_rec.repair_group_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

    OPEN  repair_order_group(x_repair_order_group_rec.repair_group_id);
    FETCH repair_order_group
    INTO l_repair_group_id,
    l_obj_ver_num;

    IF repair_order_group%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_API_RO_GROUP_MISSING');
      FND_MESSAGE.SET_TOKEN('REPAIR_GROUP_ID',l_repair_group_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF repair_order_group%ISOPEN THEN
      CLOSE repair_order_group;
     END IF;

  END IF;

--------------------------------
-- Validate Obj Version Number
--------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Validate the Object Version Number');
END IF;


  IF NVL(x_repair_order_group_rec.object_version_number,FND_API.G_MISS_NUM) <>l_obj_ver_num  THEN

    IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.ADD('object version number does not match');
    END IF;


    FND_MESSAGE.SET_NAME('CSD','CSD_GRP_OBJ_VER_MISMATCH');
    FND_MESSAGE.SET_TOKEN('REPAIR_GROUP_ID',l_repair_group_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;

  END IF;

-----------------------------
-- Validate if any RO have
-- been created
-----------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Validate if any RO have been created');
END IF;


  l_count := 0;

  BEGIN
    SELECT
      count(*)
    INTO l_count
    FROM csd_repairs
    WHERE repair_group_id = x_repair_order_group_rec.repair_group_id;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
  WHEN OTHERS THEN
    null;
  END;

  IF ( l_count > 0 ) then

    BEGIN
      Select
       inventory_item_id,
       repair_type_id,
       unit_of_measure,
       group_quantity
      into
       l_inventory_item_id,
       l_repair_type_id,
       l_unit_of_measure,
       l_group_quantity
      from csd_repair_order_groups
      where repair_group_id = x_repair_order_group_rec.repair_group_id;
    END;
------------------------------------------------
-- Update of item id, repair type,uom,grp qty
-- not allowed once repair orders are created
------------------------------------------------
    IF((x_repair_order_group_rec.inventory_item_id IS NOT NULL)  OR
      (x_repair_order_group_rec.repair_type_id    IS NOT NULL)  OR
      (x_repair_order_group_rec.unit_of_measure   IS NOT NULL) OR
      (x_repair_order_group_rec.group_quantity    IS NOT NULL)) THEN

      IF( (l_inventory_item_id  <> x_repair_order_group_rec.inventory_item_id) OR
       (l_repair_type_id  <> x_repair_order_group_rec.repair_type_id ) OR
       (l_unit_of_measure <> x_repair_order_group_rec.unit_of_measure) OR
       (l_group_quantity  <> x_repair_order_group_rec.group_quantity)) THEN

        FND_MESSAGE.SET_NAME('CSD','CSD_API_UPDATE_NOT_ALLOWED');
        FND_MESSAGE.SET_TOKEN('REPAIR_GROUP_ID',x_repair_order_group_rec.repair_group_id);
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_ERROR;

      END IF;
    END IF;
  END IF;

-------------------
-- Update Call
-------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Calling : CSD_REPAIR_ORDER_GROUPS_PKG.Update_Row');
END IF;


  CSD_REPAIR_ORDER_GROUPS_PKG.Update_Row(
    p_REPAIR_GROUP_ID         =>  x_repair_order_group_rec.repair_group_id,
    p_INCIDENT_ID             =>  x_repair_order_group_rec.incident_id,
    p_REPAIR_GROUP_NUMBER     =>  x_repair_order_group_rec.repair_group_number,
    p_REPAIR_TYPE_ID          =>  x_repair_order_group_rec.repair_type_id,
    p_WIP_ENTITY_ID           =>  x_repair_order_group_rec.wip_entity_id,
    p_INVENTORY_ITEM_ID       =>  x_repair_order_group_rec.inventory_item_id,
    p_UNIT_OF_MEASURE         =>  x_repair_order_group_rec.unit_of_measure,
    p_GROUP_QUANTITY          =>  x_repair_order_group_rec.group_quantity,
    p_REPAIR_ORDER_QUANTITY   =>  x_repair_order_group_rec.repair_order_quantity,
    p_RMA_QUANTITY            =>  x_repair_order_group_rec.rma_quantity,
    p_RECEIVED_QUANTITY       =>  x_repair_order_group_rec.received_quantity,
    p_APPROVED_QUANTITY       =>  x_repair_order_group_rec.approved_quantity,
    p_SUBMITTED_QUANTITY      =>  x_repair_order_group_rec.submitted_quantity,
    p_COMPLETED_QUANTITY      =>  x_repair_order_group_rec.completed_quantity,
    p_RELEASED_QUANTITY       =>  x_repair_order_group_rec.released_quantity,
    p_SHIPPED_QUANTITY        =>  x_repair_order_group_rec.shipped_quantity,
    p_CREATED_BY              =>  FND_GLOBAL.USER_ID,
    p_CREATION_DATE           =>  SYSDATE,
    p_LAST_UPDATED_BY         =>  FND_GLOBAL.USER_ID,
    p_LAST_UPDATE_DATE        =>  SYSDATE,
    p_LAST_UPDATE_LOGIN       =>  FND_GLOBAL.LOGIN_ID,
    p_CONTEXT                 =>  x_repair_order_group_rec.context,
    p_ATTRIBUTE1              =>  x_repair_order_group_rec.attribute1,
    p_ATTRIBUTE2              =>  x_repair_order_group_rec.attribute2,
    p_ATTRIBUTE3              =>  x_repair_order_group_rec.attribute3,
    p_ATTRIBUTE4              =>  x_repair_order_group_rec.attribute4,
    p_ATTRIBUTE5              =>  x_repair_order_group_rec.attribute5,
    p_ATTRIBUTE6              =>  x_repair_order_group_rec.attribute6,
    p_ATTRIBUTE7              =>  x_repair_order_group_rec.attribute7,
    p_ATTRIBUTE8              =>  x_repair_order_group_rec.attribute8,
    p_ATTRIBUTE9              =>  x_repair_order_group_rec.attribute9,
    p_ATTRIBUTE10             =>  x_repair_order_group_rec.attribute10,
    p_ATTRIBUTE11             =>  x_repair_order_group_rec.attribute11,
    p_ATTRIBUTE12             =>  x_repair_order_group_rec.attribute12,
    p_ATTRIBUTE13             =>  x_repair_order_group_rec.attribute13,
    p_ATTRIBUTE14             =>  x_repair_order_group_rec.attribute14,
    p_ATTRIBUTE15             =>  x_repair_order_group_rec.attribute15,
    p_OBJECT_VERSION_NUMBER   =>  l_obj_ver_num + 1,
    p_GROUP_TXN_STATUS        =>  x_repair_order_group_rec.group_txn_status,
    p_GROUP_APPROVAL_STATUS     =>  x_repair_order_group_rec.group_approval_status,
    p_REPAIR_MODE               =>  x_repair_order_group_rec.repair_mode);

    x_repair_order_group_rec.object_version_number := l_obj_ver_num + 1;


--------------------------------
-- Standard check for p_commit
--------------------------------
  IF FND_API.to_Boolean(p_commit)
  THEN
    COMMIT;
  END IF;

--------------------------------------------------------------------------
-- Standard call to get message count and if count is 1, get message info.
--------------------------------------------------------------------------
  FND_MSG_PUB.Count_And_Get
  (p_count          =>   x_msg_count,
   p_data           =>   x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO update_group_repair_order;
        FND_MSG_PUB.Count_And_Get
            (p_count  =>  x_msg_count,
             p_data   =>  x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO update_group_repair_order;
        FND_MSG_PUB.Count_And_Get
              ( p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO update_group_repair_order;
            IF  FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME ,
                 l_api_name  );
            END IF;
                FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

END UPDATE_REPAIR_GROUPS;


----------------------------------------------------
-- procedure name: delete_repair_groups
-- description   : procedure used to delete
--                 group repair orders
--
----------------------------------------------------

PROCEDURE DELETE_REPAIR_GROUPS
( p_api_version              IN     NUMBER,
  p_commit                   IN     VARCHAR2,
  p_init_msg_list            IN     VARCHAR2,
  p_validation_level         IN     NUMBER,
  p_repair_group_id          IN     NUMBER,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2
)
IS

  l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Repair_Groups';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(100);
  l_msg_index              NUMBER;
  l_dummy                  VARCHAR2(30);
  l_count                  NUMBER;

BEGIN

------------------------------------
-- Standard Start of API savepoint
------------------------------------
   SAVEPOINT  delete_repair_order_group;

-------------------------------------------------
-- Standard call to check for call compatibility.
-------------------------------------------------
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

--------------------------------------------------------------
-- Initialize message list if p_init_msg_list is set to TRUE.
--------------------------------------------------------------
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

--------------------------------------------
-- Initialize API return status to success
--------------------------------------------
  x_return_status := FND_API.G_RET_STS_SUCCESS;

---------------------------------
-- Check the required parameter
---------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Check reqd parameter: Repair Group Id ');
END IF;


  CSD_PROCESS_UTIL.Check_Reqd_Param
    ( p_param_value => p_repair_group_id,
      p_param_name  => 'REPAIR_GROUP_ID',
      p_api_name    => l_api_name);

----------------------------------
-- Validate the Repair Group  Id
----------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Repair Group Id');
END IF;


  IF NOT( CSD_PROCESS_UTIL.Validate_repair_group_id
        ( p_repair_group_id  => p_repair_group_id )) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;


--------------------------------
-- check if there are any Ro
-- for the Group
--------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Validate if any RO have been created');
END IF;


  l_count := 0;

  BEGIN
    SELECT
      count(*)
    INTO l_count
    FROM csd_repairs
    WHERE repair_group_id = p_repair_group_id;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
  WHEN OTHERS THEN
    null;
  END;

  IF ( l_count > 0 ) then
    FND_MESSAGE.SET_NAME('CSD','CSD_API_REPAIR_ORDER_EXISTS');
    FND_MESSAGE.SET_TOKEN('REPAIR_GROUP_ID',p_repair_group_id);
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_ERROR;
  END IF;
-----------------------------
-- Calling the Delete api
-----------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Calling : CSD_REPAIR_ORDER_GROUPS_PKG.Delete_Row');
END IF;


  CSD_REPAIR_ORDER_GROUPS_PKG.Delete_Row
    ( p_REPAIR_GROUP_ID  => p_repair_group_id);

-------------------------------
-- Standard check for p_commit
-------------------------------
   IF FND_API.to_Boolean(p_commit)
   THEN
      COMMIT;
   END IF;

---------------------------------------------------------------------------
-- Standard call to get message count and if count is 1, get message info.
---------------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO delete_repair_order_group;
        FND_MSG_PUB.Count_And_Get
            (p_count  =>  x_msg_count,
             p_data   =>  x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO delete_repair_order_group;
        FND_MSG_PUB.Count_And_Get
              ( p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO delete_repair_order_group;
            IF  FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME ,
                 l_api_name  );
            END IF;
                FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

END DELETE_REPAIR_GROUPS;


----------------------------------------------------
-- procedure name: lock_repair_groups
-- description   : procedure used to lock
--                 group repair orders
--
----------------------------------------------------

PROCEDURE LOCK_REPAIR_GROUPS
( p_api_version              IN     NUMBER,
  p_commit                   IN     VARCHAR2,
  p_init_msg_list            IN     VARCHAR2,
  p_validation_level         IN     NUMBER,
  p_repair_order_group_rec   IN     REPAIR_ORDER_GROUP_REC,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2
)
IS

  l_api_name               CONSTANT VARCHAR2(30) := 'Lock_Repair_Groups';
  l_api_version            CONSTANT NUMBER        := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(100);
  l_msg_index              NUMBER;

BEGIN

-----------------------------------
-- Standard Start of API savepoint
-----------------------------------
   SAVEPOINT  lock_repair_order_group;

-------------------------------------------------
-- Standard call to check for call compatibility.
-------------------------------------------------
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

--------------------------------------------------------------
-- Initialize message list if p_init_msg_list is set to TRUE.
--------------------------------------------------------------
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

-------------------------------------------
-- Initialize API return status to success
-------------------------------------------
  x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------------
-- Calling Lock Row
----------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Calling : CSD_REPAIR_ORDER_GROUPS_PKG.Lock_Row ');
END IF;


  CSD_REPAIR_ORDER_GROUPS_PKG.Lock_Row(
   p_REPAIR_GROUP_ID        =>  p_repair_order_group_rec.repair_group_id,
   p_OBJECT_VERSION_NUMBER  =>  p_repair_order_group_rec.object_version_number);

--------------------------------
-- Standard check for p_commit
--------------------------------
   IF FND_API.to_Boolean(p_commit)
   THEN
      COMMIT;
   END IF;

--------------------------------------------------------------------------
-- Standard call to get message count and if count is 1, get message info.
--------------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO lock_repair_order_group;
        FND_MSG_PUB.Count_And_Get
            (p_count  =>  x_msg_count,
             p_data   =>  x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO lock_repair_order_group;
        FND_MSG_PUB.Count_And_Get
              ( p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO lock_repair_order_group;
            IF  FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME ,
                 l_api_name  );
            END IF;
                FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

END LOCK_REPAIR_GROUPS;

-----------------------------------------------------------
-- procedure name: apply_to_group
-- description   : procedure used to update promise_date
--                 approval_req_flag,resource for all the
--                 repair orders of the group.
-----------------------------------------------------------

PROCEDURE  APPLY_TO_GROUP
( p_api_version             IN     NUMBER,
  p_commit                  IN     VARCHAR2,
  p_init_msg_list           IN     VARCHAR2,
  p_validation_level        IN     NUMBER,
  p_repair_group_id         IN     NUMBER,
  p_promise_date            IN     DATE,
  p_resource_id             IN     NUMBER,
  p_approval_required_flag  IN     VARCHAR2,
  x_object_version_number   OUT NOCOPY    NUMBER,
  x_return_status           OUT NOCOPY    VARCHAR2,
  x_msg_count               OUT NOCOPY    NUMBER,
  x_msg_data                OUT NOCOPY    VARCHAR2
)

IS

  l_api_name                     CONSTANT VARCHAR2(30) := 'Apply_to_Group';
  l_api_version                  CONSTANT NUMBER        := 1.0;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(100);
  l_msg_index                    NUMBER;
  l_dummy                        VARCHAR2(10);
  l_ro_rec                       csd_repairs_pub.repln_rec_type := csd_process_util.repair_order_rec;
  l_object_version_number        NUMBER;
  l_group_object_version_number  NUMBER;
  l_group_ro_rec                 csd_repair_groups_pvt.repair_order_group_rec;
  l_return_status                Varchar2(10);
  l_group_quantity               NUMBER;
  l_count                        NUMBER;
  l_tot_approved                 NUMBER;
  l_tot_rejected                 NUMBER;
  l_tot_no_approval              NUMBER;


  Cursor Repair_Orders(p_repair_order_group in Number)
  IS
  SELECT repair_line_id,repair_number from csd_repairs
  WHERE repair_group_id = p_repair_order_group
  FOR UPDATE NOWAIT;

BEGIN

-----------------------------------
-- Standard Start of API savepoint
-----------------------------------
   SAVEPOINT  apply_to_group;

-------------------------------------------------
-- Standard call to check for call compatibility.
-------------------------------------------------
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

--------------------------------------------------------------
-- Initialize message list if p_init_msg_list is set to TRUE.
--------------------------------------------------------------
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

-------------------------------------------
-- Initialize API return status to success
-------------------------------------------
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------
-- API Starts
-----------------
if (g_debug > 0) then

  csd_gen_utility_pvt.dump_api_info
  ( p_pkg_name    => G_PKG_NAME,
    p_api_name    => l_api_name );
end if;
------------------------------------------
-- Dump the in parameters in the log file
------------------------------------------
IF (g_debug > 5 ) THEN
    csd_gen_utility_pvt.ADD('Repair Group Id        '||to_char(p_repair_group_id));

    csd_gen_utility_pvt.ADD('Promise Date           '||p_promise_date);

    csd_gen_utility_pvt.ADD('Resource Id            '||p_resource_id);

    csd_gen_utility_pvt.ADD('Approval Required Flag '||p_approval_required_flag);

  END IF;

---------------------------------
-- Check the required parameter
---------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Check reqd parameter : Repair Group Id');
END IF;


  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value  => p_repair_group_id,
    p_param_name   => 'REPAIR_GROUP_ID',
    p_api_name      => l_api_name);

---------------------------------
-- Validate Repair Group Id
---------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Validate Repair Group Id');
END IF;


  IF NOT( CSD_PROCESS_UTIL.Validate_repair_group_id
        ( p_repair_group_id  => p_repair_group_id )) THEN
         RAISE FND_API.G_EXC_ERROR;
  END IF;

-----------------------------
-- Validate the Resource Id
-----------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Validate Resource Id');
END IF;


  IF(nvl(p_resource_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)THEN

    BEGIN
      SELECT
        'x'
      INTO l_dummy
      FROM jtf_rs_resource_extns
      WHERE resource_id = p_resource_id;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_API_INVALID_RESOURCE');
      FND_MESSAGE.SET_TOKEN('RESOURCE_ID',p_resource_id);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      null;
    END;
  END IF;
-------------------------------
-- Update the Repair Orders
-------------------------------
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.ADD('Update the Repair Orders');
END IF;


  l_ro_rec.promise_date           := nvl(p_promise_date,FND_API.G_MISS_DATE);
  l_ro_rec.resource_id            := nvl(p_resource_id,FND_API.G_MISS_NUM);
  l_ro_rec.approval_required_flag := nvl(p_approval_required_flag,FND_API.G_MISS_CHAR);

  FOR RO_record IN Repair_Orders(p_repair_group_id)
  LOOP

    Begin

      l_object_version_number := 0;

      select object_version_number
      into l_object_version_number
      from csd_repairs
      where repair_line_id = RO_record.repair_line_id;

    Exception
    when others then
      null;
    End;

    l_ro_rec.object_version_number := l_object_version_number;

    CSD_REPAIRS_PVT.Update_Repair_Order
      (P_Api_Version_Number    => 1.0,
       P_Init_Msg_List         => 'T',
       P_Commit                => 'F',
       p_validation_level      => 0,
       p_REPAIR_LINE_ID        => RO_record.repair_line_id,
       P_REPLN_Rec             => l_ro_rec,
       X_Return_Status         => l_return_status,
       X_Msg_Count             => l_msg_count,
       X_Msg_Data              => l_msg_data
     );

     If ( l_return_status <> 'S') then
       FND_MESSAGE.SET_NAME('CSD','CSD_API_RO_ORDER_UPD_FAIL');
       FND_MSG_PUB.ADD;

       RAISE FND_API.G_EXC_ERROR;

     End if;
  END LOOP;


---------------------------------
-- Update the Group Repair Order
---------------------------------
  IF (p_repair_group_id IS NOT NULL) THEN

    l_group_ro_rec.repair_group_id := p_repair_group_id;

    Begin

      l_group_object_version_number := 0;

      select object_version_number,
           group_quantity
      into l_group_object_version_number,
         l_group_quantity
      from csd_repair_order_groups_v
      where repair_group_id = p_repair_group_id;

    Exception
    when others then
      null;
    End;

    l_group_ro_rec.object_version_number := l_group_object_version_number;


    l_count            := 0;
    l_tot_approved     := 0;
    l_tot_rejected     := 0;
    l_tot_no_approval  := 0;

    BEGIN
      SELECT COUNT(*)
        INTO l_tot_approved
        FROM csd_repairs
       WHERE repair_group_id = p_repair_group_id
         AND approval_status = 'A'
         AND approval_required_flag = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
        IF (g_debug > 0 ) THEN
                csd_gen_utility_pvt.ADD(' OTHERS l_tot_approved ='||l_tot_approved);
        END IF;

    END;


    BEGIN
      SELECT COUNT(*)
        INTO l_tot_rejected
        FROM csd_repairs
      WHERE repair_group_id = p_repair_group_id
      AND approval_status = 'R'
      AND approval_required_flag = 'Y';
    EXCEPTION
    WHEN OTHERS THEN
        IF (g_debug > 0 ) THEN
              csd_gen_utility_pvt.ADD(' OTHERS l_tot_rejected ='||l_tot_rejected);
        END IF;

    END;

    BEGIN
      SELECT COUNT(*)
        INTO l_tot_no_approval
      FROM csd_repairs
      WHERE repair_group_id = p_repair_group_id
           AND approval_required_flag = 'N';
      EXCEPTION
        WHEN OTHERS THEN
        IF (g_debug > 0 ) THEN
                  csd_gen_utility_pvt.ADD(' OTHERS l_tot_no_approval ='||l_tot_no_approval);
        END IF;

      END;

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD('l_tot_approved    ='||l_tot_approved);
    csd_gen_utility_pvt.ADD('l_tot_rejected    ='||l_tot_rejected);
    csd_gen_utility_pvt.ADD('l_tot_no_approval ='||l_tot_no_approval);
END IF;


--------------------------------------------------------------------------------------------
-- Total of approved/rejected repairs with approval required = Y and approval required = N
-- Assumption no approval are not allowed to be rejected
--------------------------------------------------------------------------------------------
       l_count  := NVL(l_tot_approved,0) + NVL(l_tot_rejected,0) + NVL(l_tot_no_approval,0);

-----------------------------------------------------
-- check if all group qty have been approved/rejected
-----------------------------------------------------
    IF (NVL(l_group_quantity,0) = NVL(l_tot_no_approval,0)) THEN
        IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.ADD('EST_NOT_REQD ');
        END IF;

       l_group_ro_rec.group_approval_status := 'EST_NOT_REQD';
       l_group_ro_rec.approved_quantity     := NVL(l_tot_no_approval,0) ;
    ELSIF (l_group_quantity > l_count and l_count <> 0 ) THEN
        IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.ADD('PARTIAL_APPRD ');
        END IF;

       l_group_ro_rec.group_approval_status := 'PARTIAL_APPRD';
       l_group_ro_rec.approved_quantity     := NVL(l_tot_approved,0) + NVL(l_tot_no_approval,0);
    ELSIF (l_group_quantity = NVL(l_tot_approved,0)+ NVL(l_tot_no_approval,0)) THEN
        IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.ADD('APPROVED ');
        END IF;

       l_group_ro_rec.group_approval_status := 'APPROVED';
       l_group_ro_rec.approved_quantity     := NVL(l_tot_approved,0)+ NVL(l_tot_no_approval,0);
    ELSIF (l_group_quantity = NVL(l_tot_rejected,0)) THEN
        IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.ADD('REJECTED ');
        END IF;

       l_group_ro_rec.group_approval_status := 'REJECTED';
       l_group_ro_rec.approved_quantity     := 0 ;
    ELSE
       l_group_ro_rec.group_approval_status := 'EST_REQD';
       l_group_ro_rec.approved_quantity     := 0 ;
    END IF;

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD('CSD_REPAIR_ESTIMATE_PVT.UPDATE_RO_GROUP_ESTIMATE Update Group RO call');
END IF;


-----------------
-- call the api
-----------------

    CSD_REPAIR_GROUPS_PVT.UPDATE_REPAIR_GROUPS
    ( p_api_version             => 1.0,
      p_commit                  => 'F',
      p_init_msg_list           => 'T',
      p_validation_level        => fnd_api.g_valid_level_full,
      x_repair_order_group_rec  => l_group_ro_rec,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data  );

    IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.ADD('CSD_REPAIR_ESTIMATE_PVT.UPDATE_RO_GROUP_ESTIMATE UPDATE_REPAIR_GROUPS :'||x_return_status);
    END IF;


     IF l_return_status <> 'S' THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MESSAGE.SET_NAME('CSD','CSD_API_RO_GROUP_EST_FAIL');
       FND_MSG_PUB.ADD;
     ELSIF l_return_status = 'S' THEN
       x_object_version_number := l_group_ro_rec.object_version_number;
     END IF;

  END IF;

--------------------------------
-- Standard check for p_commit
--------------------------------
   IF FND_API.to_Boolean(p_commit)
   THEN
      COMMIT;
   END IF;

--------------------------------------------------------------------------
-- Standard call to get message count and if count is 1, get message info.
--------------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO apply_to_group;
        FND_MSG_PUB.Count_And_Get
            (p_count  =>  x_msg_count,
             p_data   =>  x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO apply_to_group;
        FND_MSG_PUB.Count_And_Get
              ( p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO apply_to_group;
            IF  FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME ,
                 l_api_name  );
            END IF;
                FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

END APPLY_TO_GROUP;

END CSD_REPAIR_GROUPS_PVT;

/
