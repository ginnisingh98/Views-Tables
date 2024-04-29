--------------------------------------------------------
--  DDL for Package Body WSH_CONTAINER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CONTAINER_GRP" AS
/* $Header: WSHCOGPB.pls 120.6.12010000.2 2008/08/04 12:29:32 suppal ship $ */

  -- standard global constants
  G_PKG_NAME CONSTANT VARCHAR2(30)    := 'WSH_CONTAINER_GRP';
  p_message_type  CONSTANT VARCHAR2(1)  := 'E';


------------------------------------------------------------------------------
-- Procedure: Create_Containers
--
-- Parameters:  1) container_item_id (key flex id)
--    2) container_item_name (concatinated name for container item)
--    3) container_item_seg (flex field seg array for item name)
--    4) organization_id - organization id for container
--    5) organization_code - organization code for container
--    6) name_prefix - container name prefix
--    7) name_suffix - container name suffix
--    8) base_number - starting number for numeric portion of name
--    9) num_digits - precision for number of digits
--    10) quantity - number of containers
--    11) container_name - container name if creating 1 container
--    12) table of container ids - out table of ids
--    13) other standard parameters
--
-- Description: This procedure takes in a container item id or container item
-- name and other necessary parameters to create one or more containers and
-- creates the required containers. It returns a table of container instance
-- ids (delivery detail ids) along with the standard out parameters.
--
-- THIS PROCEDURE SHOULD NOT BE USED ANYMORE, IT IS USED ONLY FOR BACKWARD
-- COMPATIBILITY.
--
------------------------------------------------------------------------------

PROCEDURE Create_Containers (
  -- Standard parameters
  p_api_version   IN  NUMBER,
  p_init_msg_list   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_validation_level  IN  NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data    OUT NOCOPY  VARCHAR2,

  -- program specific parameters
  p_container_item_id IN  NUMBER,
  p_container_item_name   IN  VARCHAR2,
  p_container_item_seg  IN  FND_FLEX_EXT.SegmentArray,
  p_organization_id IN  NUMBER,
  p_organization_code IN  VARCHAR2,
  p_name_prefix   IN  VARCHAR2,
  p_name_suffix   IN  VARCHAR2,
  p_base_number   IN  NUMBER,
  p_num_digits    IN  NUMBER,
  p_quantity    IN  NUMBER,
  p_container_name  IN  VARCHAR2,
        p_lpn_ids               IN      WSH_UTIL_CORE.ID_TAB_TYPE,

  -- program specific out parameters
  x_container_ids   OUT NOCOPY  WSH_UTIL_CORE.ID_TAB_TYPE,
        p_caller                IN  VARCHAR2  -- Has default 'WMS' in spec
) IS


-- Standard call to check for call compatibility
l_api_version   CONSTANT  NUMBER    := 1.0;
l_api_name    CONSTANT  VARCHAR2(30):= 'Create_Containers';

l_return_status   VARCHAR2(30)  := NULL;
l_cont_item_id    NUMBER    := NULL;
l_cont_item_seg   FND_FLEX_EXT.SegmentArray;
l_cont_item_name  VARCHAR2(30)  := NULL;
l_cont_name   VARCHAR2(30)  := NULL;

l_cont_inst_tab   WSH_UTIL_CORE.ID_TAB_TYPE;
l_msg_summary     VARCHAR2(2000)  := NULL;
l_msg_details     VARCHAR2(4000)  := NULL;

l_organization_id NUMBER    := NULL;
l_organization_code VARCHAR2(240) := NULL;

-- Bug fix 2657429
l_verify_org_level     NUMBER;
l_verify_cont_item     NUMBER;
-- Bug fix 2657429

/*  wms changes begin   */
wms_return_status       VARCHAR2(10);
wms_msg_count           NUMBER;
wms_msg_data            VARCHAR2(2000);
wms_organization_id     NUMBER;
wms_enabled             BOOLEAN;
/* -- wms changes end  */

--lpn conv
l_detail_info_tab       WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type;
l_IN_rec                WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
l_OUT_rec               WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;

l_msg_count           NUMBER;
l_msg_data            VARCHAR2(2000);

WSH_NO_INV_ITEM     EXCEPTION;
WSH_INVALID_QTY     EXCEPTION;
WSH_FAIL_CONT_CREATION    EXCEPTION;
WSH_LPN_COUNT_INVALID           EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_CONTAINERS';
--
BEGIN

  -- Standard begin of API savepoint
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_ITEM_ID',P_CONTAINER_ITEM_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_ITEM_NAME',P_CONTAINER_ITEM_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_CODE',P_ORGANIZATION_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_NAME_PREFIX',P_NAME_PREFIX);
      WSH_DEBUG_SV.log(l_module_name,'P_NAME_SUFFIX',P_NAME_SUFFIX);
      WSH_DEBUG_SV.log(l_module_name,'P_BASE_NUMBER',P_BASE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_NUM_DIGITS',P_NUM_DIGITS);
      WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY',P_QUANTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_NAME',P_CONTAINER_NAME);
  END IF;
  --
  SAVEPOINT Create_Containers_SP_GRP;

  IF NOT FND_API.compatible_api_call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --lpn conv
   -- validate quantity
  IF NVL(p_quantity,0) <> 1  THEN
        RAISE WSH_INVALID_QTY;
  END IF;

  IF p_caller NOT LIKE 'WMS%' THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Invalid caller',p_caller);
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_lpn_ids.COUNT = 0 THEN
     IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name,'lpn_id cannot be null');
     END IF;
     FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
     FND_MESSAGE.SET_TOKEN('FIELD_NAME','LPN_ID');
     WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
     RAISE FND_API.G_EXC_ERROR;
  ELSIF p_lpn_ids(1) = NULL THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
     FND_MESSAGE.SET_TOKEN('FIELD_NAME','LPN_ID');
     WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
     RAISE FND_API.G_EXC_ERROR;
  END IF;

   -- Bug fix 2657429
   IF p_validation_level <> C_DELIVERY_DETAIL_CALL THEN
      WSH_ACTIONS_LEVELS.set_validation_level (
                                  p_entity   =>  'DLVB',
                                  p_caller   =>  p_caller,
                                  p_phase    =>  1,
                                  p_action   => 'CREATE',
                                  x_return_status => l_return_status);

   END IF;

      l_verify_org_level := WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CONTAINER_ORG_LVL);
      l_verify_cont_item := WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CONT_ITEM_LVL);
   -- Bug fix 2657429
  -- validate the organization id and organization code

  l_organization_id := p_organization_id;
  l_organization_code := p_organization_code;

      IF l_verify_org_level = 1 THEN
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_ORG',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_UTIL_VALIDATE.Validate_Org (l_organization_id,
             l_organization_code,
             x_return_status);
           IF x_return_status <> wsh_util_core.g_ret_sts_success THEN
              fnd_message.set_name('WSH', 'WSH_OI_INVALID_ORG');
              wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
              raise fnd_api.g_exc_error;
           END IF;

      END IF;

  -- validate the key flex valaues (item id and item name)

  l_cont_item_id := p_container_item_id;
  l_cont_item_seg := p_container_item_seg;
  l_cont_item_name := p_container_item_name;
     --
    IF l_verify_cont_item = 1 THEN
     /*  wms change:  Validate Item check is to be skipped if the Org. is WMS enabled */

     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_INSTALL.CHECK_INSTALL',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

       wms_enabled := WMS_INSTALL.check_install(
                           wms_return_status,
                           wms_msg_count,
                           wms_msg_data,
                           l_organization_id);

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'wms enabled', wms_enabled);
     END IF;

     IF (wms_enabled = FALSE) THEN
          IF (l_cont_item_id IS NULL
             AND l_cont_item_name IS NULL
             AND l_cont_item_seg.count = 0) then
    fnd_message.set_name('WSH', 'WSH_CONT_INVALID_ITEM');
    WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
            RAISE WSH_NO_INV_ITEM;
          ELSE
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_ITEM',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
           WSH_UTIL_VALIDATE.Validate_Item
              (p_inventory_item_id => l_cont_item_id,
               p_inventory_item   => l_cont_item_name,
               p_organization_id   => l_organization_id,
               p_seg_array      => l_cont_item_seg,
               x_return_status     => x_return_status,
               p_item_type      => 'CONT_ITEM');

            IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    fnd_message.set_name('WSH', 'WSH_CONT_INVALID_ITEM');
    WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error, l_module_name);
              RAISE WSH_NO_INV_ITEM;
            END IF;
          END IF;
      ELSE
          fnd_message.set_name('WSH', 'WSH_INCORRECT_ORG');
          fnd_message.set_token('ORG_CODE', l_organization_code);
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
          RAISE FND_API.G_EXC_ERROR;
     END IF;  -- wms_enabled
   END IF;


      l_IN_rec.caller := p_caller;
      l_IN_rec.action_code := 'CREATE';
      l_IN_rec.quantity := 1;
      l_detail_info_tab(1).organization_id := l_organization_id;
      l_detail_info_tab(1).inventory_item_id := l_cont_item_id;
      l_detail_info_tab(1).container_name  := p_container_name;
      l_detail_info_tab(1).lpn_id  := p_lpn_ids(1);

      WSH_WMS_LPN_GRP.create_update_containers
        ( p_api_version            => p_api_version,
          p_init_msg_list          => p_init_msg_list,
          p_commit                 => p_commit,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data,
          p_detail_info_tab        => l_detail_info_tab,
          p_IN_rec                 => l_IN_rec,
          x_OUT_rec                => l_OUT_rec
        );
  IF l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)
  THEN
    RAISE WSH_FAIL_CONT_CREATION;
  END IF;

  x_return_status := l_return_status;

  x_container_ids := l_OUT_rec.detail_ids;



  IF FND_API.TO_BOOLEAN(p_commit) THEN
    -- dbms_output.put_line('commit');
    COMMIT;
  END IF;

        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );


     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
--
 EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Create_Containers_SP_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
                  );
                  --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
              END IF;

  WHEN WSH_NO_INV_ITEM then
                rollback to Create_Containers_SP_GRP;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );


               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_INV_ITEM exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_INV_ITEM');
              END IF;
--
  WHEN WSH_INVALID_QTY then
    rollback to Create_Containers_SP_GRP;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_CONT_INVALID_QTY');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );

              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_QTY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_QTY');
             END IF;
--
  WHEN WSH_FAIL_CONT_CREATION then
                rollback to Create_Containers_SP_GRP;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_CONT_CREATE_ERROR');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FAIL_CONT_CREATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FAIL_CONT_CREATION');
              END IF;
--
  WHEN WSH_LPN_COUNT_INVALID then
    rollback to Create_Containers_SP_GRP;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    fnd_message.set_name('WSH', 'WSH_LPN_COUNT_INVALID');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_LPN_COUNT_INVALID exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_LPN_COUNT_INVALID');
    END IF;
    --
  WHEN OTHERS then
    rollback to Create_Containers_SP_GRP;
    wsh_util_core.default_handler('WSH_CONTAINER_GRP.Create_Containers');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
END Create_Containers;


------------------------------------------------------------------------------
-- Procedure: Update_Container
--
-- Parameters:  1) container_rec - container record of type
--    wsh_interface.changedattributerectype
--    2) other standard parameters
--
-- Description: This procedure takes in a record of container attributes that
-- contains the name and delivery detail id of container to update the
-- container record in WSH_DELIVERY_DETAILS with the attributes input in the
-- container rec type. The API validates the container name and detail id and
-- calls the wsh_delivery_details_grp.update_shipping_attributes public API.

-- THIS PROCEDURE SHOULD NOT BE USED ANYMORE, IT IS USED ONLY FOR BACKWARD
-- COMPATIBILITY.
------------------------------------------------------------------------------

PROCEDURE Update_Container (
  -- Standard parameters
  p_api_version   IN  NUMBER,
  p_init_msg_list   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_validation_level  IN  NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data    OUT NOCOPY  VARCHAR2,

  -- program specific parameters
  p_container_rec   IN  WSH_CONTAINER_GRP.CHANGEDATTRIBUTETABTYPE

) IS

 -- Standard call to check for call compatibility
 l_api_version    CONSTANT  NUMBER  := 1.0;
 l_api_name   CONSTANT  VARCHAR2(30):= 'Update_Containers';

 l_return_status  VARCHAR2(30)  := NULL;

 l_cont_name    VARCHAR2(30)  := NULL;
 l_cont_flag    VARCHAR2(1);
 l_cont_instance_id NUMBER;

 l_old_cont_name  VARCHAR2(30);
 l_old_cont_instance_id NUMBER;
 l_old_lpn_id           NUMBER;
 l_old_rel_status       VARCHAR2(1);


 l_cont_tab   WSH_INTERFACE.CHANGEDATTRIBUTETABTYPE;

 l_msg_summary    VARCHAR2(2000)  := NULL;
 l_msg_details    VARCHAR2(4000)  := NULL;

 l_delivery_id    NUMBER;
 l_del_status   VARCHAR2(10);
 l_detail_info_tab       WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type;
 l_IN_rec                WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
 l_OUT_rec               WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;

 l_msg_count           NUMBER;
 l_msg_data            VARCHAR2(2000);

 WSH_INVALID_CONT     EXCEPTION;
 WSH_INVALID_CONT_UPDATE    EXCEPTION;
 WSH_FAIL_CONT_UPDATE     EXCEPTION;

--lpn conv
 CURSOR Check_Cont (v_cont_id NUMBER ) IS
 SELECT container_flag, delivery_detail_id, lpn_id, released_status
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = v_cont_id
 AND nvl(LINE_DIRECTION , 'O') IN ('O', 'IO');

 CURSOR Check_Cont_Name (v_cont_name VARCHAR2) IS
 SELECT delivery_detail_id, container_name
 FROM WSH_DELIVERY_DETAILS
 WHERE container_name = v_cont_name
 AND nvl(LINE_DIRECTION , 'O') IN ('O', 'IO');

 CURSOR c_get_lpn (l_delivery_detail_id NUMBER) IS
 SELECT lpn_id
 FROM wsh_delivery_details
 WHERE delivery_detail_id = l_delivery_detail_id;


  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CONTAINER';
  --
BEGIN

  -- Standard begin of API savepoint
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
  END IF;
  --
  SAVEPOINT Update_Containers_SP_Grp;

  IF NOT FND_API.compatible_api_call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

/*
  IF p_caller NOT LIKE 'WMS%' THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Invalid caller',p_caller);
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
p_caller does not exist
*/

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- check to make sure that the container record being input for update
  -- does not have null delivery detail ids or container name or the
  -- container flag is null or 'N'
  IF p_container_rec(1).delivery_detail_id IS NULL OR p_container_rec(1).container_name IS NULL OR nvl(p_container_rec(1).container_flag,'N') = 'N' THEN
    RAISE WSH_INVALID_CONT_UPDATE;
  END IF;

  -- Now check for valid container based on the information in the
  -- container rec.


  IF p_container_rec(1).delivery_detail_id IS NOT NULL AND p_container_rec(1).container_name IS NOT NULL THEN

    l_cont_instance_id := p_container_rec(1).delivery_detail_id;
    l_cont_name := p_container_rec(1).container_name;

    OPEN Check_Cont (l_cont_instance_id );

    FETCH Check_Cont INTO
      l_cont_flag,
      l_old_cont_instance_id,
                        l_old_lpn_id,
                        l_old_rel_status;

    IF Check_Cont%NOTFOUND OR Check_Cont%ROWCOUNT > 1 THEN
      CLOSE Check_Cont;
      RAISE WSH_INVALID_CONT;
    END IF;

    IF Check_Cont%ISOPEN THEN
      CLOSE Check_Cont;
    END IF;

    -- if the input container instance id does not match the
    -- delivery detail id in the database (for the given container
    -- name) then error out..

    IF l_old_cont_instance_id <> l_cont_instance_id OR l_cont_flag <> 'Y' THEN
      RAISE WSH_INVALID_CONT;
    END IF;
                -- Bug 2657803/2911387, Let WMS update container name and null out LPN ID if container has been shipped,
                -- and LPN id is not null.
                -- If not, validate delivery status and container name
                IF l_old_lpn_id IS NULL or l_old_rel_status <> 'C' or p_container_rec(1).lpn_id is NOT NULL THEN


/* lpn conv
                  OPEN Check_Cont_Name (l_cont_name);

                  FETCH Check_Cont_Name INTO
                        l_old_cont_instance_id,
                        l_old_cont_name;

                  IF Check_Cont_Name%FOUND AND l_old_cont_instance_id <> l_cont_instance_id THEN
                        CLOSE Check_Cont_Name;
                        RAISE WSH_INVALID_CONT_UPDATE;
                  END IF;

                  IF Check_Cont_Name%ISOPEN THEN
                        CLOSE Check_Cont_Name;
                  END IF;
*/

                  WSH_CONTAINER_UTILITIES.Get_Delivery_Status (
                                                l_old_cont_instance_id,
                                                l_delivery_id,
                                                l_del_status,
                                                x_return_status);

                  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        RAISE WSH_FAIL_CONT_UPDATE;
                  END IF;

                -- Bug: 1577876.
                -- 1. Update is allowed even if Container is not assigned to a Delivery.
          -- 2. if Assigned then Updateable only if Delivery Status not in 'IT', 'CL', 'CO'
                  IF (l_delivery_id <> -99  AND l_del_status in ('IT', 'CL', 'CO', 'SR', 'SC') ) THEN
                        RAISE WSH_FAIL_CONT_UPDATE;
                  END IF;


                END IF;


    -- call update delivery details public API to update entire
    -- container record with all validations..


    --l_cont_tab(1) := p_container_rec(1);

    --
    l_IN_rec.caller := WSH_GLBL_VAR_STRCT_GRP.c_skip_miss_info;
    l_IN_rec.action_code := 'UPDATE';
    l_detail_info_tab(1).delivery_detail_id  := p_container_rec(1).delivery_detail_id  ;
    l_detail_info_tab(1).source_code  := p_container_rec(1).source_code  ;
    l_detail_info_tab(1).source_header_id  := p_container_rec(1).source_header_id  ;
    l_detail_info_tab(1).source_line_id  := p_container_rec(1).source_line_id  ;
    l_detail_info_tab(1).customer_id  := p_container_rec(1).customer_id  ;
    l_detail_info_tab(1).sold_to_contact_id  := p_container_rec(1).sold_to_contact_id  ;
    l_detail_info_tab(1).inventory_item_id  := p_container_rec(1).inventory_item_id  ;
    l_detail_info_tab(1).item_description  := p_container_rec(1).item_description  ;
    l_detail_info_tab(1).hazard_class_id  := p_container_rec(1).hazard_class_id  ;
    l_detail_info_tab(1).country_of_origin  := p_container_rec(1).country_of_origin  ;
    l_detail_info_tab(1).classification  := p_container_rec(1).classification  ;
    l_detail_info_tab(1).ship_to_contact_id  := p_container_rec(1).ship_to_contact_id  ;
    l_detail_info_tab(1).ship_to_site_use_id  := p_container_rec(1).ship_to_site_use_id  ;
    l_detail_info_tab(1).deliver_to_contact_id  := p_container_rec(1).deliver_to_contact_id  ;
    l_detail_info_tab(1).intmed_ship_to_contact_id  := p_container_rec(1).intmed_ship_to_contact_id  ;
    l_detail_info_tab(1).hold_code  := p_container_rec(1).hold_code  ;
    l_detail_info_tab(1).ship_tolerance_above  := p_container_rec(1).ship_tolerance_above  ;
    l_detail_info_tab(1).ship_tolerance_below  := p_container_rec(1).ship_tolerance_below  ;
    l_detail_info_tab(1).shipped_quantity  := p_container_rec(1).shipped_quantity  ;
    l_detail_info_tab(1).delivered_quantity  := p_container_rec(1).delivered_quantity  ;
    l_detail_info_tab(1).subinventory  := p_container_rec(1).subinventory  ;
    l_detail_info_tab(1).revision  := p_container_rec(1).revision  ;
    l_detail_info_tab(1).lot_number  := p_container_rec(1).lot_number  ;
    l_detail_info_tab(1).customer_requested_lot_flag  := p_container_rec(1).customer_requested_lot_flag  ;
    l_detail_info_tab(1).serial_number  := p_container_rec(1).serial_number  ;
    l_detail_info_tab(1).locator_id  := p_container_rec(1).locator_id  ;
    l_detail_info_tab(1).date_requested  := p_container_rec(1).date_requested  ;
    l_detail_info_tab(1).date_scheduled  := p_container_rec(1).date_scheduled  ;
    l_detail_info_tab(1).master_container_item_id  := p_container_rec(1).master_container_item_id  ;
    l_detail_info_tab(1).detail_container_item_id  := p_container_rec(1).detail_container_item_id  ;
    l_detail_info_tab(1).load_seq_number  := p_container_rec(1).load_seq_number  ;
    l_detail_info_tab(1).carrier_id  := p_container_rec(1).carrier_id  ;
    l_detail_info_tab(1).freight_terms_code  := p_container_rec(1).freight_terms_code  ;
    l_detail_info_tab(1).shipment_priority_code  := p_container_rec(1).shipment_priority_code  ;
    l_detail_info_tab(1).fob_code  := p_container_rec(1).fob_code  ;
    l_detail_info_tab(1).customer_item_id  := p_container_rec(1).customer_item_id  ;
    l_detail_info_tab(1).dep_plan_required_flag  := p_container_rec(1).dep_plan_required_flag  ;
    l_detail_info_tab(1).customer_prod_seq  := p_container_rec(1).customer_prod_seq  ;
    l_detail_info_tab(1).customer_dock_code  := p_container_rec(1).customer_dock_code  ;
    l_detail_info_tab(1).cust_model_serial_number  := p_container_rec(1).cust_model_serial_number  ;
    l_detail_info_tab(1).customer_job   := p_container_rec(1).customer_job   ;
    l_detail_info_tab(1).customer_production_line  := p_container_rec(1).customer_production_line  ;
    l_detail_info_tab(1).net_weight  := p_container_rec(1).net_weight  ;
    l_detail_info_tab(1).weight_uom_code  := p_container_rec(1).weight_uom_code  ;
    l_detail_info_tab(1).volume  := p_container_rec(1).volume  ;
    l_detail_info_tab(1).volume_uom_code  := p_container_rec(1).volume_uom_code  ;
    l_detail_info_tab(1).tp_attribute_category  := p_container_rec(1).tp_attribute_category  ;
    l_detail_info_tab(1).tp_attribute1  := p_container_rec(1).tp_attribute1  ;
    l_detail_info_tab(1).tp_attribute2  := p_container_rec(1).tp_attribute2  ;
    l_detail_info_tab(1).tp_attribute3  := p_container_rec(1).tp_attribute3  ;
    l_detail_info_tab(1).tp_attribute4  := p_container_rec(1).tp_attribute4  ;
    l_detail_info_tab(1).tp_attribute5  := p_container_rec(1).tp_attribute5  ;
    l_detail_info_tab(1).tp_attribute6  := p_container_rec(1).tp_attribute6  ;
    l_detail_info_tab(1).tp_attribute7  := p_container_rec(1).tp_attribute7  ;
    l_detail_info_tab(1).tp_attribute8  := p_container_rec(1).tp_attribute8  ;
    l_detail_info_tab(1).tp_attribute9  := p_container_rec(1).tp_attribute9  ;
    l_detail_info_tab(1).tp_attribute10  := p_container_rec(1).tp_attribute10  ;
    l_detail_info_tab(1).tp_attribute11  := p_container_rec(1).tp_attribute11  ;
    l_detail_info_tab(1).tp_attribute12  := p_container_rec(1).tp_attribute12  ;
    l_detail_info_tab(1).tp_attribute13  := p_container_rec(1).tp_attribute13  ;
    l_detail_info_tab(1).tp_attribute14  := p_container_rec(1).tp_attribute14  ;
    l_detail_info_tab(1).tp_attribute15  := p_container_rec(1).tp_attribute15  ;
    l_detail_info_tab(1).attribute_category  := p_container_rec(1).attribute_category  ;
    l_detail_info_tab(1).attribute1  := p_container_rec(1).attribute1  ;
    l_detail_info_tab(1).attribute2  := p_container_rec(1).attribute2  ;
    l_detail_info_tab(1).attribute3  := p_container_rec(1).attribute3  ;
    l_detail_info_tab(1).attribute4  := p_container_rec(1).attribute4  ;
    l_detail_info_tab(1).attribute5  := p_container_rec(1).attribute5  ;
    l_detail_info_tab(1).attribute6  := p_container_rec(1).attribute6  ;
    l_detail_info_tab(1).attribute7  := p_container_rec(1).attribute7  ;
    l_detail_info_tab(1).attribute8  := p_container_rec(1).attribute8  ;
    l_detail_info_tab(1).attribute9  := p_container_rec(1).attribute9  ;
    l_detail_info_tab(1).attribute10  := p_container_rec(1).attribute10  ;
    l_detail_info_tab(1).attribute11  := p_container_rec(1).attribute11  ;
    l_detail_info_tab(1).attribute12  := p_container_rec(1).attribute12  ;
    l_detail_info_tab(1).attribute13  := p_container_rec(1).attribute13  ;
    l_detail_info_tab(1).attribute14  := p_container_rec(1).attribute14  ;
    l_detail_info_tab(1).attribute15  := p_container_rec(1).attribute15  ;
    l_detail_info_tab(1).request_id  := p_container_rec(1).request_id  ;
    l_detail_info_tab(1).mvt_stat_status  := p_container_rec(1).mvt_stat_status  ;
    l_detail_info_tab(1).organization_id  := p_container_rec(1).organization_id  ;
    l_detail_info_tab(1).transaction_temp_id  := p_container_rec(1).transaction_temp_id  ;
    l_detail_info_tab(1).ship_set_id  := p_container_rec(1).ship_set_id  ;
    l_detail_info_tab(1).arrival_set_id  := p_container_rec(1).arrival_set_id  ;
    l_detail_info_tab(1).ship_model_complete_flag  := p_container_rec(1).ship_model_complete_flag  ;
    l_detail_info_tab(1).top_model_line_id  := p_container_rec(1).top_model_line_id  ;
    l_detail_info_tab(1).source_header_number  := p_container_rec(1).source_header_number  ;
    l_detail_info_tab(1).source_header_type_id  := p_container_rec(1).source_header_type_id  ;
    l_detail_info_tab(1).source_header_type_name  := p_container_rec(1).source_header_type_name  ;
    l_detail_info_tab(1).cust_po_number  := p_container_rec(1).cust_po_number  ;
    l_detail_info_tab(1).ato_line_id  := p_container_rec(1).ato_line_id  ;
    l_detail_info_tab(1).src_requested_quantity  := p_container_rec(1).src_requested_quantity  ;
    l_detail_info_tab(1).src_requested_quantity_uom  := p_container_rec(1).src_requested_quantity_uom  ;
    l_detail_info_tab(1).move_order_line_id  := p_container_rec(1).move_order_line_id  ;
    l_detail_info_tab(1).cancelled_quantity  := p_container_rec(1).cancelled_quantity  ;
    l_detail_info_tab(1).quality_control_quantity  := p_container_rec(1).quality_control_quantity  ;
    l_detail_info_tab(1).cycle_count_quantity  := p_container_rec(1).cycle_count_quantity  ;
    l_detail_info_tab(1).tracking_number  := p_container_rec(1).tracking_number  ;
    l_detail_info_tab(1).movement_id  := p_container_rec(1).movement_id  ;
    l_detail_info_tab(1).shipping_instructions  := p_container_rec(1).shipping_instructions  ;
    l_detail_info_tab(1).packing_instructions  := p_container_rec(1).packing_instructions  ;
    l_detail_info_tab(1).project_id  := p_container_rec(1).project_id  ;
    l_detail_info_tab(1).task_id  := p_container_rec(1).task_id  ;
    l_detail_info_tab(1).org_id  := p_container_rec(1).org_id  ;
    l_detail_info_tab(1).oe_interfaced_flag  := p_container_rec(1).oe_interfaced_flag  ;
    l_detail_info_tab(1).inv_interfaced_flag  := p_container_rec(1).inv_interfaced_flag  ;
    l_detail_info_tab(1).inspection_flag  := p_container_rec(1).inspection_flag  ;
    l_detail_info_tab(1).released_status  := p_container_rec(1).released_status  ;
    l_detail_info_tab(1).container_flag  := p_container_rec(1).container_flag  ;
    l_detail_info_tab(1).container_type_code  := p_container_rec(1).container_type_code  ;
    l_detail_info_tab(1).container_name  := p_container_rec(1).container_name  ;
    l_detail_info_tab(1).fill_percent  := p_container_rec(1).fill_percent  ;
    l_detail_info_tab(1).gross_weight  := p_container_rec(1).gross_weight  ;
    l_detail_info_tab(1).master_serial_number  := p_container_rec(1).master_serial_number  ;
    l_detail_info_tab(1).maximum_load_weight  := p_container_rec(1).maximum_load_weight  ;
    l_detail_info_tab(1).maximum_volume  := p_container_rec(1).maximum_volume  ;
    l_detail_info_tab(1).minimum_fill_percent  := p_container_rec(1).minimum_fill_percent  ;
    l_detail_info_tab(1).seal_code  := p_container_rec(1).seal_code  ;
    l_detail_info_tab(1).unit_number  := p_container_rec(1).unit_number  ;
    l_detail_info_tab(1).unit_price  := p_container_rec(1).unit_price  ;
    l_detail_info_tab(1).currency_code  := p_container_rec(1).currency_code  ;
    l_detail_info_tab(1).freight_class_cat_id  := p_container_rec(1).freight_class_cat_id  ;
    l_detail_info_tab(1).commodity_code_cat_id  := p_container_rec(1).commodity_code_cat_id  ;
    l_detail_info_tab(1).preferred_grade       := p_container_rec(1).preferred_grade       ;
    l_detail_info_tab(1).shipped_quantity2         := p_container_rec(1).shipped_quantity2         ;
    l_detail_info_tab(1).delivered_quantity2  := p_container_rec(1).delivered_quantity2  ;
    l_detail_info_tab(1).cancelled_quantity2  := p_container_rec(1).cancelled_quantity2  ;
    l_detail_info_tab(1).quality_control_quantity2  := p_container_rec(1).quality_control_quantity2  ;
    l_detail_info_tab(1).cycle_count_quantity2  := p_container_rec(1).cycle_count_quantity2  ;

    l_detail_info_tab(1).lpn_id  := p_container_rec(1).lpn_id  ;

    IF( p_container_rec(1).lpn_id IS NULL )  OR
                        (p_container_rec(1).lpn_id = FND_API.G_MISS_NUM)
    THEN
       IF p_container_rec(1).lpn_id IS NULL THEN
          l_IN_rec.action_code := 'UPDATE_NULL';
       END IF;
       OPEN c_get_lpn(p_container_rec(1).delivery_detail_id);
       FETCH c_get_lpn INTO l_detail_info_tab(1).lpn_id;
       CLOSE c_get_lpn;
    END IF;

    l_detail_info_tab(1).pickable_flag  := p_container_rec(1).pickable_flag  ;
    l_detail_info_tab(1).original_subinventory  := p_container_rec(1).original_subinventory  ;
    l_detail_info_tab(1).to_serial_number    := p_container_rec(1).to_serial_number    ;
    l_detail_info_tab(1).picked_quantity  := p_container_rec(1).picked_quantity  ;
    l_detail_info_tab(1).picked_quantity2  := p_container_rec(1).picked_quantity2  ;
    l_detail_info_tab(1).received_quantity  := p_container_rec(1).received_quantity  ;
    l_detail_info_tab(1).received_quantity2  := p_container_rec(1).received_quantity2  ;
    l_detail_info_tab(1).source_line_set_id  := p_container_rec(1).source_line_set_id  ;
    l_detail_info_tab(1).ship_from_location_id  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).ship_to_location_id  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).deliver_to_location_id  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).deliver_to_site_use_id  := p_container_rec(1).deliver_to_org_id;
    l_detail_info_tab(1).intmed_ship_to_location_id  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).requested_quantity  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).requested_quantity_uom  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).ship_method_code  := p_container_rec(1).shipping_method_code;
    l_detail_info_tab(1).created_by  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).creation_date  := FND_API.G_MISS_DATE;
    l_detail_info_tab(1).last_update_date  := FND_API.G_MISS_DATE;
    l_detail_info_tab(1).last_update_login  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).last_updated_by  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).program_application_id  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).program_id  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).program_update_date  := FND_API.G_MISS_DATE;
    l_detail_info_tab(1).released_flag  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).split_from_detail_id  := p_container_rec(1).split_from_delivery_detail_id;
    l_detail_info_tab(1).source_line_number  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).src_requested_quantity2  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).src_requested_quantity_uom2  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).requested_quantity2  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).requested_quantity_uom2  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).batch_id  := FND_API.G_MISS_NUM;
    --l_detail_info_tab(1).ROWID  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).transaction_id  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).VENDOR_ID  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).SHIP_FROM_SITE_ID  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).LINE_DIRECTION  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).PARTY_ID  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).ROUTING_REQ_ID  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).SHIPPING_CONTROL  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).SOURCE_BLANKET_REFERENCE_ID  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).SOURCE_BLANKET_REFERENCE_NUM  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).PO_SHIPMENT_LINE_ID  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).PO_SHIPMENT_LINE_NUMBER  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).RETURNED_QUANTITY  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).RETURNED_QUANTITY2  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).RCV_SHIPMENT_LINE_ID  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).SOURCE_LINE_TYPE_CODE  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).SUPPLIER_ITEM_NUMBER  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).IGNORE_FOR_PLANNING  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).EARLIEST_PICKUP_DATE  := FND_API.G_MISS_DATE;
    l_detail_info_tab(1).LATEST_PICKUP_DATE  := FND_API.G_MISS_DATE;
    l_detail_info_tab(1).EARLIEST_DROPOFF_DATE  := FND_API.G_MISS_DATE;
    l_detail_info_tab(1).LATEST_DROPOFF_DATE  := FND_API.G_MISS_DATE;
    l_detail_info_tab(1).REQUEST_DATE_TYPE_CODE  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).tp_delivery_detail_id  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).source_document_type_id  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).unit_weight  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).unit_volume  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).filled_volume  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).wv_frozen_flag  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).mode_of_transport  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).service_level  := FND_API.G_MISS_CHAR;
    l_detail_info_tab(1).po_revision_number  := FND_API.G_MISS_NUM;
    l_detail_info_tab(1).release_revision_number  := FND_API.G_MISS_NUM;

    WSH_WMS_LPN_GRP.create_update_containers
      ( p_api_version            => p_api_version,
        p_init_msg_list          => p_init_msg_list,
        p_commit                 => p_commit,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        p_detail_info_tab        => l_detail_info_tab,
        p_IN_rec                 => l_IN_rec,
        x_OUT_rec                => l_OUT_rec
      );


    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      RAISE WSH_FAIL_CONT_UPDATE;
    END IF;

  END IF; -- if p_container_rec is not null


  IF FND_API.TO_BOOLEAN(p_commit) THEN
    -- dbms_output.put_line('commit');
    COMMIT;
  END IF;

        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );


  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN WSH_INVALID_CONT_UPDATE then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    rollback to Update_Containers_SP_Grp;
    fnd_message.set_name('WSH', 'WSH_CONT_INVALID_UPDATE');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*
                WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
*/
                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CONT_UPDATE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CONT_UPDATE');
END IF;
--
  WHEN WSH_INVALID_CONT then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    rollback to Update_Containers_SP_Grp;
    fnd_message.set_name('WSH', 'WSH_CONT_INVALID_NAME');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*
                WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
*/
                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CONT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CONT');
END IF;
--
  WHEN WSH_FAIL_CONT_UPDATE then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    rollback to Update_Containers_SP_Grp;
    fnd_message.set_name('WSH', 'WSH_CONT_UPDATE_ERROR');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    /*
                WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
               */
                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FAIL_CONT_UPDATE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FAIL_CONT_UPDATE');
END IF;
--
  WHEN OTHERS then
    wsh_util_core.default_handler('WSH_CONTAINER_GRP.Update_Container');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    rollback to Update_Containers_SP_Grp;
/*

    WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
      end if;

*/
                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Container;


------------------------------------------------------------------------------
-- Procedure: Auto_Pack
--
-- Parameters:  1) entity_tab - table of ids of either lines or containers or
--      deliveries that need to be autopacked
--    2) entity_type - type of entity id contained in the entity_tab
--      that needs to be autopacked ('L' - lines,
--      'C' - containers OR 'D' - deliveries)
--    3) group_id_tab - table of ids (numbers that determine
--      the grouping of lines for packing into containers)
--    4) container_instance_tab - table of delivery detail ids of
--      containers that are created during the autopacking
--    5) pack cont flag - a 'Y' or 'N' value to determine whether to
--      to autopack the detail containers that are created into
--      parent containers.
--    6) other standard parameters
--
-- Description: This procedure takes in a table of ids of either delivery lines
-- or container or deliveries and autopacks the lines/containers/deliveries
-- into detail containers. The grouping id table is used only if the input
-- table of entities are lines or containers only. The packing of lines and
-- containers into parent containers is determined by the grouping id for each
-- line/container. If the grouping id table is not input, the API determines
-- the grouping ids for the lines/containers based on the grouping attributes
-- of the lines/containers. The lines/containers are then autopacked into
-- detail containers and the detail containers are packed into parent/master
-- containers based on whether the pack cont flag is set to 'Y' or 'N'. The
-- API returns a table of container instance ids created during the autopacking
-- operation. If the detail containers are packed into parent containers, the
-- output table of ids will contain both the detail and parent containers'
-- delivery detail ids.
------------------------------------------------------------------------------

PROCEDURE Auto_Pack (
  -- Standard parameters
  p_api_version   IN  NUMBER,
  p_init_msg_list   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_validation_level  IN  NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data    OUT NOCOPY  VARCHAR2,

  -- program specific parameters
  p_entity_tab    IN  WSH_UTIL_CORE.ID_TAB_TYPE,
  p_entity_type   IN  VARCHAR2,
  p_group_id_tab    IN  WSH_UTIL_CORE.ID_TAB_TYPE,
  p_pack_cont_flag  IN  VARCHAR2,

  -- program specific out parameters
  x_cont_inst_tab   OUT NOCOPY    WSH_UTIL_CORE.ID_TAB_TYPE

) IS

 -- Standard call to check for call compatibility
 l_api_version    CONSTANT  NUMBER  := 1.0;
 l_api_name   CONSTANT  VARCHAR2(30):= 'Update_Containers';

 l_return_status  VARCHAR2(30)  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 l_det_tab    WSH_UTIL_CORE.ID_TAB_TYPE;
 l_cont_tab   WSH_UTIL_CORE.ID_TAB_TYPE;
 l_del_tab    WSH_UTIL_CORE.ID_TAB_TYPE;

 l_delivery_detail_id NUMBER;
 l_delivery_id    NUMBER;
 l_del_status   VARCHAR2(10);
 l_delivery_name  VARCHAR2(30);

 l_cont_name    VARCHAR2(30)  := NULL;
 l_cont_flag    VARCHAR2(1);
 l_cont_instance_id NUMBER;

 l_old_cont_name  VARCHAR2(30);
 l_old_cont_instance_id NUMBER;

 l_det_cnt    NUMBER := 0;
 l_cont_cnt   NUMBER := 0;
 l_del_cnt    NUMBER := 0;

 l_msg_summary    VARCHAR2(2000)  := NULL;
 l_msg_details    VARCHAR2(4000)  := NULL;
 l_ret_status           VARCHAR2(30)  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



 WSH_INVALID_CONT     EXCEPTION;
 WSH_INVALID_DETAIL     EXCEPTION;
 WSH_INVALID_DELIVERY     EXCEPTION;
 WSH_INVALID_ENTITY_TYPE    EXCEPTION;
 WSH_FAIL_AUTOPACK      EXCEPTION;

 CURSOR Check_Detail (v_detail_id NUMBER) IS
 SELECT delivery_detail_id, container_flag
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = v_detail_id
 AND nvl(line_direction,'O') in ('O','IO');   -- J-IB-NPARIKH;

 CURSOR Check_Delivery (v_del_id NUMBER) IS
 SELECT delivery_id, name, status_code
 FROM WSH_NEW_DELIVERIES
 WHERE delivery_id = v_del_id
 AND nvl(shipment_direction,'O') in ('O','IO');   -- J-IB-NPARIKH;;


 -- K LPN CONV. rv
 l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
 l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
 l_msg_count NUMBER;
 l_msg_data VARCHAR2(32767);
 -- K LPN CONV. rv

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTO_PACK';
--
--Bugfix 4070732
l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
l_reset_flags BOOLEAN;
l_num_warnings NUMBER;
l_num_errors   NUMBER;

BEGIN
  --Bugfix 4070732

  l_num_warnings := 0;
  l_num_errors   := 0;

  IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN
    WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
    WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
  END IF;

  -- Standard begin of API savepoint
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',P_ENTITY_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_PACK_CONT_FLAG',P_PACK_CONT_FLAG);
  END IF;
  --
  SAVEPOINT Autopack_SP_Grp;

  IF NOT FND_API.compatible_api_call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- first decide which entity it is by checking entity type..
  -- based on entity type validate all the entity ids..

  IF p_entity_type = 'L' OR p_entity_type = 'C' THEN

    FOR i IN 1..p_entity_tab.count LOOP

      IF p_entity_tab(i) IS NOT NULL THEN

        OPEN Check_Detail(p_entity_tab(i));

        FETCH Check_Detail INTO
          l_delivery_detail_id,
          l_cont_flag;

        IF Check_Detail%NOTFOUND THEN
          CLOSE Check_Detail;
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        END IF;

        IF Check_Detail%ISOPEN THEN
          CLOSE Check_Detail;
        END IF;

        l_det_cnt := l_det_cnt + 1;
        l_det_tab(l_det_cnt) := p_entity_tab(i);

      ELSE
        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      END IF;
    END LOOP;

    IF l_det_tab.count > 0 THEN

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.AUTO_PACK_LINES',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_DLVB_COMMON_ACTIONS.Auto_Pack_Lines (
          p_group_id_tab => p_group_id_tab,
          p_detail_tab => l_det_tab,
          p_pack_cont_flag => p_pack_cont_flag,
                                        p_group_api_flag => 'Y',
          x_cont_inst_tab => x_cont_inst_tab,
          x_return_status => l_ret_status);

      IF l_ret_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_ret_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          -- Bug#4280365 Start
          If p_pack_cont_flag = 'Y' then
             fnd_message.set_name('WSH', 'WSH_AUTO_PACK_MASTER_MSG');
          -- Bug#4280365 End
          Else
             fnd_message.set_name('WSH', 'WSH_AUTOPACK_ERROR');
          End If;
          WSH_UTIL_CORE.ADD_MESSAGE(l_return_status);
          RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        ELSE
          RAISE WSH_FAIL_AUTOPACK;
        END IF;
      ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TP_RELEASE.CALCULATE_CONT_DEL_TPDATES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        WSH_TP_RELEASE.calculate_cont_del_tpdates(
            p_entity => 'DLVB',
            p_entity_ids =>x_cont_inst_tab,
            x_return_status => x_return_status);
      END IF;
    ELSE
      RAISE WSH_INVALID_DETAIL;
    END IF;



  ELSIF p_entity_type = 'D' THEN

    FOR i IN 1..p_entity_tab.count LOOP

      IF p_entity_tab(i) IS NOT NULL THEN

        OPEN Check_Delivery(p_entity_tab(i));

        FETCH Check_Delivery INTO
          l_delivery_id,
          l_delivery_name,
          l_del_status;

        IF Check_Delivery%NOTFOUND THEN
          CLOSE Check_Delivery;
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        END IF;

        IF Check_Delivery%ISOPEN THEN
          CLOSE Check_Delivery;
        END IF;

        IF nvl(l_del_status,'OP') IN ('OP', 'SA') THEN
          l_del_cnt := l_del_cnt + 1;
          l_del_tab(l_del_cnt) := p_entity_tab(i);
        ELSE
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          END IF;
        END IF;

      ELSE
        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
      END IF;

    END LOOP;

    IF l_del_tab.count > 0 THEN

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.AUTO_PACK_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_CONTAINER_ACTIONS.Auto_Pack_Delivery (
          l_del_tab,
          p_pack_cont_flag,
          x_cont_inst_tab,
          x_return_status);

      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          -- Bug#4280365 Start
          If p_pack_cont_flag = 'Y' then
             fnd_message.set_name('WSH', 'WSH_AUTO_PACK_MASTER_MSG');
          -- Bug#4280365 End
          Else
             fnd_message.set_name('WSH', 'WSH_AUTOPACK_ERROR');
          End If;
          WSH_UTIL_CORE.ADD_MESSAGE(l_return_status);
          RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        ELSE
          RAISE WSH_FAIL_AUTOPACK;
        END IF;
      ELSE
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TP_RELEASE.CALCULATE_CONT_DEL_TPDATES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        WSH_TP_RELEASE.calculate_cont_del_tpdates(
            p_entity => 'DLVY',
            p_entity_ids =>l_del_tab,
            x_return_status => x_return_status);

      END IF;

    ELSE
      RAISE WSH_INVALID_DELIVERY;
    END IF;

  ELSE
    RAISE WSH_INVALID_ENTITY_TYPE;
  END IF;

  --
  -- K LPN CONV. rv
  --
  IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
  THEN
  --{
      WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
        (
          p_in_rec             => l_lpn_in_sync_comm_rec,
          x_return_status      => l_return_status,
          x_out_rec            => l_lpn_out_sync_comm_rec
        );
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
      END IF;
      --
      --
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
          RAISE WSH_FAIL_AUTOPACK;
        ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
  --}
  END IF;
  --
  -- K LPN CONV. rv
  --
  --Bugfix 4070732 {
  IF FND_API.TO_BOOLEAN(p_commit) THEN

    l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    -- dbms_output.put_line('commit');
    IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN --{
       WSH_UTIL_CORE.Process_stops_for_load_tender(
                                    p_reset_flags   => FALSE,
                                    x_return_status => l_return_status);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
       END IF;
    END IF; --}
    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
     OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN --{

       COMMIT;

    END IF; --}

    wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                 x_num_warnings     =>l_num_warnings,
                                 x_num_errors       =>l_num_errors);
  END IF;
  --Bugfix 4070732 }

/*

  WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
  if x_msg_count > 1 then
    x_msg_data := l_msg_summary || l_msg_details;
  else
    x_msg_data := l_msg_summary;
  end if;
*/
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --Bugfix 4070732 {
  IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN --{
    IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN

     IF FND_API.TO_BOOLEAN(p_commit) THEN

       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_UTIL_CORE.reset_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);
     ELSE

       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_UTIL_CORE.Process_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);
     END IF;

       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
       END IF;

              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                IF NOT(FND_API.TO_BOOLEAN(p_commit)) THEN
                   rollback to Autopack_SP_Grp;
	        end if;
              END IF;

       --x_return_status is set to success before the call to fte load tender
       -- setting the return status to l_return_status
       x_return_status := l_return_status;

    END IF;
  END IF; --}

  --}
  --End of bug 4070732

        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN WSH_INVALID_DETAIL then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    rollback to Autopack_SP_Grp;
    fnd_message.set_name('WSH', 'WSH_DET_INVALID_DETAIL');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*

    WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
*/
   --Bugfix 4070732 {
   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         END IF;
      END IF;
   END IF;
   --}
   --End of bug 4070732


                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DETAIL');
END IF;
--

  WHEN FND_API.G_EXC_ERROR then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    rollback to Autopack_SP_Grp;

   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         END IF;
      END IF;
   END IF;
   --}
   --End of bug 4070732

                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );
   --Bugfix 4070732 {

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:G_EXC_ERROR');
END IF;
--
  WHEN WSH_INVALID_CONT then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    rollback to Autopack_SP_Grp;
    fnd_message.set_name('WSH', 'WSH_CONT_INVALID_NAME');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*

    WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
*/
   --Bugfix 4070732 {
   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         END IF;

      END IF;
   END IF;
   --}
   --End of bug 4070732


                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CONT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CONT');
END IF;
--
  WHEN WSH_INVALID_DELIVERY then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    rollback to Autopack_SP_Grp;
    fnd_message.set_name('WSH', 'WSH_DET_INVALID_DEL');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*

    WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
*/

   --Bugfix 4070732 {
   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         END IF;

      END IF;
   END IF;
   --}
   --End of bug 4070732


                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DELIVERY');
END IF;
--
  WHEN WSH_UTIL_CORE.G_EXC_WARNING then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
    -- K LPN CONV. rv
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
          (
            p_in_rec             => l_lpn_in_sync_comm_rec,
            x_return_status      => l_return_status,
            x_out_rec            => l_lpn_out_sync_comm_rec
          );
        --
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
        END IF;
        --
        --
        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
          x_return_status := l_return_status;
        END IF;
        --
    --}
    END IF;
    --
    -- K LPN CONV. rv
    --

   --Bugfix 4070732 {
   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                     x_return_status => l_return_status);

         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
          OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            rollback to Autopack_SP_Grp;
            X_return_status := l_return_status;
         END IF;

      END IF;
   END IF;
   --}
   -- End of bug 4070732


                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'G_RET_STS_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:G_RET_STS_WARNING');
                END IF;
                --
  WHEN WSH_FAIL_AUTOPACK then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    rollback to Autopack_SP_Grp;
    fnd_message.set_name('WSH', 'WSH_AUTOPACK_ERROR');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    --Bugfix 4070732 {
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            X_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         END IF;
      END IF;
   END IF;
   --}
   --End of bug 4070732

		FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FAIL_AUTOPACK exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FAIL_AUTOPACK');
                END IF;
                --
  WHEN WSH_INVALID_ENTITY_TYPE then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    rollback to Autopack_SP_Grp;
    fnd_message.set_name('WSH', 'WSH_PUB_CONT_TYPE_ERR');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*

    WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
*/
   --Bugfix 4070732 {
   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            X_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         END IF;

      END IF;
   END IF;
   --}
   --End of bug 4070732


                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_ENTITY_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_ENTITY_TYPE');
END IF;
--
  WHEN OTHERS then
    wsh_util_core.default_handler('WSH_CONTAINER_PUB.Auto_Pack');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    rollback to Autopack_SP_Grp;

/*

    WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
      end if;

*/
   --Bugfix 4070732 {
   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;

      END IF;
   END IF;
   --}
   --End of bug 4070732


                FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count
                , p_data  => x_msg_data
                , p_encoded => FND_API.G_FALSE
                );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Auto_Pack;


------------------------------------------------------------------------------
-- Procedure: Container_Actions
--
-- Parameters:  1) detail_tab - input table of delivery detail ids
--    2) container_instance_id - delivery detail id of parent
--      container that is being packed.
--    3) container_name - container name if id is not known
--    4) container_flag - 'Y' or 'N' depending on whether to unpack
--      or not. ('Y' is unpack)
--    5) delivery_flag - 'Y' or 'N' if container needs to be
--      unassigned from delivery. ('Y' if unassign from del)
--    6) delivery_id - delivery id to assign container to.
--    7) delivery_name - name of delivery that container is being
--      assigned to.
--    8) action_code - action code 'Pack', 'Assign', 'Unpack' or
--      'Unassign' to specify what action to perform.
--    9) other standard parameters
--
-- Description: This procedure takes in a table of delivery detail ids and
-- name and/or delivery detail id of container to pack. If the action code is
-- is assign then delivery id and delivery name must be specified. The API
-- determines what action to perform based on the action code and then calls
-- appropriate private pack/assign/unpack/unassign API.
-- The input table of ids could be lines or containers. The delivery lines and
-- containers are separated from the input table and validated before the
-- appropriate private APIs are called
-- THIS PROCEDURE IS ONLY TO BE CALLED FROM
-- WSH_DELIVERY_DETAIL_GRP.Delivery_Detail_Action

------------------------------------------------------------------------------




PROCEDURE Container_Actions (
  -- Standard parameters
  p_api_version   IN  NUMBER,
  p_init_msg_list   IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_validation_level  IN  NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data    OUT NOCOPY  VARCHAR2,
  -- program specific parameters
  p_detail_tab    IN  WSH_UTIL_CORE.ID_TAB_TYPE,
  p_container_name  IN  VARCHAR2 DEFAULT NULL,
  p_cont_instance_id  IN  NUMBER DEFAULT NULL,
  p_container_flag  IN  VARCHAR2  DEFAULT 'N',
  p_delivery_flag   IN  VARCHAR2  DEFAULT 'N',
  p_delivery_id   IN  NUMBER DEFAULT NULL,
  p_delivery_name   IN  VARCHAR2 DEFAULT NULL,
  p_action_code   IN  VARCHAR2 ,
        p_caller                IN      VARCHAR2 DEFAULT 'WMS'

) IS
 -- Standard call to check for call compatibility
 l_api_version    CONSTANT  NUMBER  := 1.0;
 l_api_name   CONSTANT  VARCHAR2(30):= 'Update_Containers';

 l_detail_tab   WSH_UTIL_CORE.ID_TAB_TYPE;
 l_cont_tab   WSH_UTIL_CORE.ID_TAB_TYPE;

 l_delivery_detail_id NUMBER;
 l_delivery_id    NUMBER;
 l_del_sts    VARCHAR2(10);
 l_delivery_name  VARCHAR2(30);

 l_cont_name    VARCHAR2(30)  := NULL;
 l_cont_flag    VARCHAR2(1);
 l_cont_instance_id NUMBER;

 l_old_cont_name  VARCHAR2(30);
 l_old_cont_instance_id NUMBER;

 l_det_cnt    NUMBER := 0;
 l_cont_cnt   NUMBER := 0;
 l_del_cnt    NUMBER := 0;

 i      NUMBER;

 l_msg_summary    VARCHAR2(32000) := NULL;
 l_msg_details    VARCHAR2(32000) := NULL;

 l_pack_status    VARCHAR2(30);
 l_group_api_flag       VARCHAR2(1);
 l_verify_status_lvl    NUMBER ;
 l_verify_org           NUMBER ;
 l_verify_dlvy          NUMBER ;
 l_wms_enabled_flag     VARCHAR2(10);
 l_dlvy_status_code     wsh_new_deliveries.status_code%TYPE;
 l_cont_org_id          NUMBER;
 l_cont_released_status wsh_delivery_details.released_status%TYPE;
 l_return_status  VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 l_num_warning          NUMBER := 0;
 l_num_errors           NUMBER := 0;
 l_next                 NUMBER ;

 WSH_INVALID_CONT     EXCEPTION;
 WSH_INVALID_DETAIL     EXCEPTION;
 WSH_INVALID_DELIVERY     EXCEPTION;
 WSH_INVALID_ACTION     EXCEPTION;
 WSH_FAIL_CONT_ACTION     EXCEPTION;
 WSH_INVALID_ENTITY_TYPE    EXCEPTION;

 --Bug 4329611. Perf Fix .
 CURSOR Get_Detail_Id (v_cont_name VARCHAR2) IS
 SELECT delivery_detail_id, container_flag
 FROM WSH_DELIVERY_DETAILS
 WHERE container_name = v_cont_name
 --LPN reuse project
 AND released_status = 'X'
 AND container_flag = 'Y';

 CURSOR Check_Detail (v_detail_id NUMBER) IS
 SELECT wdd.delivery_detail_id, wdd.container_flag,wdd.released_status,
        wdd.organization_id ,wda.delivery_id
 FROM WSH_DELIVERY_DETAILS wdd, wsh_delivery_assignments_v wda
 WHERE wdd.delivery_detail_id = v_detail_id
       AND wdd.delivery_detail_id = wda.delivery_detail_id
       AND nvl(wdd.line_direction,'O') in ('O','IO');   -- J-IB-NPARIKH

 CURSOR Check_Delivery_by_id (v_del_id NUMBER) IS
 SELECT delivery_id, name, status_code
 FROM WSH_NEW_DELIVERIES
 WHERE delivery_id = v_del_id;

 CURSOR Check_Delivery_by_Name ( v_del_name VARCHAR2) IS
 SELECT delivery_id, name, status_code
 FROM WSH_NEW_DELIVERIES
 WHERE  name = v_del_name;

 CURSOR c_dlvy(l_delivery_id number) IS
   SELECT status_code
   FROM wsh_new_deliveries
   WHERE delivery_id = l_delivery_id;

 -- K LPN CONV. rv
 l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
 l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
 l_msg_count NUMBER;
 l_msg_data VARCHAR2(32767);
 -- K LPN CONV. rv

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONTAINER_ACTIONS';
--
--Bugfix 4070732
l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
l_reset_flags BOOLEAN;

BEGIN
   --
   --Bugfix 4070732
   IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN
    WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
    WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
   END IF;
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   SAVEPOINT Container_Action_SP_Grp;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_NAME',P_CONTAINER_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_CONT_INSTANCE_ID',P_CONT_INSTANCE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_FLAG',P_CONTAINER_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_FLAG',P_DELIVERY_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_NAME',P_DELIVERY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ACTION_CODE',P_ACTION_CODE);
      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
   END IF;
   --
   -- Check p_init_msg_list
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_caller LIKE 'WMS%' THEN
      l_group_api_flag := 'Y';
   END IF;



   IF nvl(p_detail_tab.COUNT,0) <= 0 THEN
      RAISE WSH_INVALID_DETAIL;
   END IF;

   IF p_validation_level <> C_DELIVERY_DETAIL_CALL THEN
      WSH_ACTIONS_LEVELS.set_validation_level (
                                  p_entity   =>  'DLVB',
                                  p_caller   =>  p_caller,
                                  p_phase    =>  1,
                                  p_action   =>p_action_code ,
                                  x_return_status => l_return_status);

      wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                 x_num_warnings     =>l_num_warning,
                                 x_num_errors       =>l_num_errors);
   END IF;

   l_verify_status_lvl := WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CONTAINER_STATUS_LVL);
 l_verify_org  := WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CONTAINER_ORG_LVL);
 l_verify_dlvy  := WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CONT_DLVY_LVL);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_verify_status_lvl'
                                                  ,l_verify_status_lvl);
      WSH_DEBUG_SV.log(l_module_name,'l_verify_org',l_verify_org);
      WSH_DEBUG_SV.log(l_module_name,'l_verify_dlvy',l_verify_dlvy);
   END IF;

   l_next := p_detail_tab.first;
   WHILE l_next IS NOT NULL LOOP

      OPEN Check_Detail (p_detail_tab(l_next));
      Fetch Check_Detail INTO
        l_delivery_detail_id,
        l_cont_flag,
        l_cont_released_status,
        l_cont_org_id,
        l_delivery_id;
        IF Check_Detail%NOTFOUND THEN
          CLOSE Check_Detail;
          FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
          l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
        ELSE
           l_det_cnt := l_det_cnt + 1;
           l_detail_tab(l_det_cnt) := l_delivery_detail_id;

        END IF;

        IF Check_Detail%ISOPEN THEN
            CLOSE Check_Detail;
        END IF;

        l_next := p_detail_tab.NEXT(l_next);

   END LOOP;


   IF UPPER(p_action_code) = 'ASSIGN' THEN
      IF p_delivery_id IS NULL THEN --{
         IF p_delivery_name IS NULL THEN
            RAISE WSH_INVALID_DELIVERY;
         END IF;
         OPEN Check_Delivery_by_Name ( p_delivery_name);
         FETCH Check_Delivery_by_Name INTO
            l_delivery_id,
            l_delivery_name,
            l_del_sts;

            IF Check_Delivery_by_Name%NOTFOUND OR SQL%ROWCOUNT > 1 OR (nvl(l_del_sts,'OP') NOT IN ('OP', 'SA')) THEN
               CLOSE Check_Delivery_by_Name;
               RAISE WSH_INVALID_DELIVERY;
            END IF;

            IF Check_Delivery_by_Name%ISOPEN THEN
               CLOSE Check_Delivery_by_Name;
            END IF;
      ELSE --}{
         OPEN Check_Delivery_by_id (p_delivery_id);

         Fetch Check_Delivery_by_id INTO
            l_delivery_id,
            l_delivery_name,
            l_del_sts;

            IF Check_Delivery_by_id%NOTFOUND OR SQL%ROWCOUNT > 1 OR (nvl(l_del_sts,'OP') NOT IN  ('OP', 'SA') )THEN
               CLOSE Check_Delivery_by_id;
               RAISE WSH_INVALID_DELIVERY;
            END IF;
         -- close the cursor
            IF Check_Delivery_by_id%ISOPEN THEN
               CLOSE Check_Delivery_by_id;
            END IF;
      END IF; --}

   END IF;
   IF UPPER(p_action_code) in ('PACK','UNPACK') THEN
      IF l_verify_org=1 THEN
         l_wms_enabled_flag := WSH_UTIL_VALIDATE.check_wms_org(l_cont_org_id);
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_wms_enabled_flag'
                                               ,l_wms_enabled_flag);
         END IF;

         IF NVL(l_wms_enabled_flag,'N') = 'Y' THEN
            RAISE WSH_INVALID_CONT;
         END IF;
      END IF;
   END IF;

   IF UPPER(p_action_code) = 'PACK' THEN

      IF p_cont_instance_id IS NULL THEN

         OPEN Get_Detail_Id (p_container_name);

         FETCH Get_Detail_Id INTO
            l_cont_instance_id,
            l_cont_flag;

            IF Get_Detail_Id%NOTFOUND OR SQL%ROWCOUNT > 1 OR (nvl(l_cont_flag,'N') = 'N') THEN
               CLOSE Get_Detail_Id;
               RAISE WSH_INVALID_CONT;

            ELSE
               CLOSE Get_Detail_Id;
            END IF;
      ELSE l_cont_instance_id := p_cont_instance_id;
      END IF;
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_verify_status_lvl'
                                                        ,l_verify_status_lvl);
            WSH_DEBUG_SV.log(l_module_name,'l_verify_org',l_verify_org);
            WSH_DEBUG_SV.log(l_module_name,'l_verify_dlvy',l_verify_dlvy);
            WSH_DEBUG_SV.log(l_module_name,'l_cont_instance_id'
                                                         ,l_cont_instance_id);
         END IF;
         IF l_verify_status_lvl =1 OR l_verify_org=1 OR l_verify_dlvy=1 THEN

            OPEN Check_Detail (l_cont_instance_id);
            Fetch Check_Detail INTO
               l_cont_instance_id,
               l_cont_flag,
               l_cont_released_status,
               l_cont_org_id,
               l_delivery_id;

               IF Check_Detail%NOTFOUND THEN
                  CLOSE Check_Detail;
                  RAISE WSH_INVALID_CONT;
               ELSE
                  CLOSE Check_Detail;
               END IF;
               IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_cont_instance_id'
                                                        ,l_cont_instance_id);
                 WSH_DEBUG_SV.log(l_module_name,'l_cont_flag',l_cont_flag);
                 WSH_DEBUG_SV.log(l_module_name,'l_cont_released_status'
                                                      ,l_cont_released_status);
                 WSH_DEBUG_SV.log(l_module_name,'l_cont_org_id',l_cont_org_id);
                 WSH_DEBUG_SV.log(l_module_name,'l_delivery_id',l_delivery_id);
               END IF;

               IF l_verify_status_lvl=1 THEN
                  IF (nvl(l_cont_flag,'N') = 'N')
                    OR (NVL(l_cont_released_status,'Z') <> 'X')  THEN
                    RAISE WSH_INVALID_CONT;
                  END IF;
               END IF;
               IF (l_verify_dlvy =1) AND (l_delivery_id IS NOT NULL )THEN
                  OPEN c_dlvy(l_delivery_id);
                  FETCH c_dlvy INTO l_dlvy_status_code;
                  IF c_dlvy%NOTFOUND THEN
                     CLOSE c_dlvy;
                     RAISE WSH_INVALID_DELIVERY;
                  ELSE
                     CLOSE c_dlvy;
                  END IF;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_dlvy_status_code'
                                                        ,l_dlvy_status_code);
                  END IF;
                  IF l_dlvy_status_code <> 'OP' THEN
                     RAISE WSH_INVALID_DELIVERY ;
                  END IF;
               END IF;
         END IF;
         -- verified call the private APIs to pack..
    END IF;

    IF UPPER(p_action_code) = 'UNPACK' THEN
      IF nvl(p_container_flag,'N') = 'N' THEN
         RAISE WSH_INVALID_ACTION;
      END IF;
   ELSIF UPPER(p_action_code) = 'UNASSIGN' THEN
      IF nvl(p_delivery_flag,'N') = 'N' THEN
         RAISE WSH_INVALID_ACTION;
      END IF;
   END IF;
   -- call the private APIs to assign/unassign..

   IF (UPPER(p_action_code) = 'PACK') OR (UPPER(p_action_code) = 'ASSIGN') THEN
      IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.ASSIGN_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_DLVB_COMMON_ACTIONS.Assign_Details (
               p_detail_tab => l_detail_tab,
               p_parent_detail_id => l_cont_instance_id,
               p_delivery_id => l_delivery_id,
               p_group_api_flag => l_group_api_flag,
               x_pack_status => l_pack_status,
               x_return_status => x_return_status);

      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            RAISE WSH_UTIL_CORE.G_EXC_WARNING;
         ELSE
            RAISE WSH_FAIL_CONT_ACTION;
         END IF;
      ELSE
       --Start of fix for bug 5234326/5282496
        IF ( l_cont_instance_id IS NOT NULL ) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TP_RELEASE.CALCULATE_CONT_DEL_TPDATES for entity LPN',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          l_cont_tab(1) := l_cont_instance_id;
          WSH_TP_RELEASE.calculate_cont_del_tpdates(
              p_entity => 'LPN',
              p_entity_ids =>l_cont_tab,
              x_return_status => x_return_status);
        ELSE
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TP_RELEASE.CALCULATE_CONT_DEL_TPDATES for entity DLVB',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          WSH_TP_RELEASE.calculate_cont_del_tpdates(
              p_entity => 'DLVB',
              p_entity_ids =>l_detail_tab,
              x_return_status => x_return_status);
        END IF;
        --End of fix for bug 5234326/5282496

      END IF;
   ELSIF (UPPER(p_action_code) = 'UNPACK') OR (UPPER(p_action_code) = 'UNASSIGN') THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.UNASSIGN_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WSH_DLVB_COMMON_ACTIONS.Unassign_Details (
               p_detail_tab => l_detail_tab,
               p_parent_detail_flag => p_container_flag,
               p_delivery_flag => p_delivery_flag,
               p_group_api_flag => l_group_api_flag,
               x_return_status => x_return_status);

      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            RAISE WSH_UTIL_CORE.G_EXC_WARNING;
         ELSE
            RAISE WSH_FAIL_CONT_ACTION;
         END IF;
      END IF;
   ELSE
      RAISE WSH_INVALID_ACTION;
   END IF;

   --
   -- K LPN CONV. rv
   --
   IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
   THEN
   --{
       WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
         (
           p_in_rec             => l_lpn_in_sync_comm_rec,
           x_return_status      => l_return_status,
           x_out_rec            => l_lpn_out_sync_comm_rec
         );
       --
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
         WSH_DEBUG_SV.log(l_module_name,'Msg Count after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_msg_count);
       END IF;
       --
       --
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           RAISE WSH_UTIL_CORE.G_EXC_WARNING;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
           RAISE WSH_FAIL_CONT_ACTION;
         ELSE
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF;
   --}
   END IF;
   --
   -- K LPN CONV. rv
   --


   --Bugfix 4070732 {
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         WSH_UTIL_CORE.Process_stops_for_load_tender(
                                    p_reset_flags   => FALSE,
                                    x_return_status => l_return_status);
      END IF;
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
       OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN --{

         COMMIT;

      END IF; --}

      wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                 x_num_warnings     =>l_num_warning,
                                 x_num_errors       =>l_num_errors);
   END IF;
   --Bugfix 4070732 }

/*
   WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
   if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
   else
      x_msg_data := l_msg_summary;
   end if;
*/

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --Bugfix 4070732 {
  IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  <> upper(l_api_session_name)
  THEN --{
    IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
     IF FND_API.TO_BOOLEAN(p_commit) THEN

       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_UTIL_CORE.reset_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);

     ELSE


       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_UTIL_CORE.Process_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);
     END IF;

       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
       END IF;

              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                IF NOT(FND_API.TO_BOOLEAN(p_commit)) THEN
                   rollback to Container_Action_SP_Grp;
	        end if;
              END IF;
       --x_return_status is set to success before the call to fte load tender
       -- setting the return status to l_return_status
       x_return_status := l_return_status;

    END IF;
  END IF; --}

  --}
  --End of bug 4070732


   FND_MSG_PUB.Count_And_Get
   ( p_count => x_msg_count
   , p_data  => x_msg_data
   , p_encoded => FND_API.G_FALSE
   );
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION

  WHEN WSH_UTIL_CORE.G_EXC_WARNING then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
    -- K LPN CONV. rv
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
          (
            p_in_rec             => l_lpn_in_sync_comm_rec,
            x_return_status      => l_return_status,
            x_out_rec            => l_lpn_out_sync_comm_rec
          );
        --
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
          WSH_DEBUG_SV.log(l_module_name,'Msg Count after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_msg_count);
        END IF;
        --
        --
        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
          x_return_status := l_return_status;
        END IF;
        --
    --}
    END IF;
    --
    -- K LPN CONV. rv
    --

    --Bugfix 4070732 {
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                     x_return_status => l_return_status);

         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;

         IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
           OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
           rollback to Container_Action_SP_Grp;
           x_return_status := l_return_status;
         END IF;
      END IF;
    END IF;
    --}

    FND_MSG_PUB.Count_And_Get
           ( p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => FND_API.G_FALSE
           );
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'G_RET_STS_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:G_RET_STS_WARNING');
    END IF;

   WHEN WSH_INVALID_DETAIL then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      rollback to Container_Action_SP_Grp;
      fnd_message.set_name('WSH', 'WSH_DET_INVALID_DETAIL');
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*
      WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
      if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
      else
         x_msg_data := l_msg_summary;
      end if;
*/

     --Bugfix 4070732 {
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                     x_return_status => l_return_status);


           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;

           IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
           END IF;

        END IF;
     END IF;
     --}
     --End of bug 4070732

      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DETAIL');
      END IF;

   WHEN WSH_INVALID_CONT then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      rollback to Container_Action_SP_Grp;
      fnd_message.set_name('WSH', 'WSH_CONT_INVALID_NAME');
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*
      WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
      if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
      else
         x_msg_data := l_msg_summary;
      end if;
*/

     --Bugfix 4070732 {
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                     x_return_status => l_return_status);


           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;

           IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
           END IF;
        END IF;
     END IF;
     --}
     --End of bug 4070732

      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CONT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CONT');
      END IF;
      --
   WHEN WSH_INVALID_DELIVERY then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      rollback to Container_Action_SP_Grp;
      fnd_message.set_name('WSH', 'WSH_DET_INVALID_DEL');
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*
      WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
      if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
      else
         x_msg_data := l_msg_summary;
      end if;
*/

     --Bugfix 4070732 {
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                     x_return_status => l_return_status);


           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;

           IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
           END IF;
        END IF;
     END IF;
     --}
     --End of bug 4070732

      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DELIVERY');
      END IF;
      --
   WHEN WSH_FAIL_CONT_ACTION then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      rollback to Container_Action_SP_Grp;
      fnd_message.set_name('WSH', 'WSH_CONT_ACTION_ERROR');
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*
      WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
      if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
      else
         x_msg_data := l_msg_summary;
      end if;
*/

     --Bugfix 4070732 {
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                     x_return_status => l_return_status);


           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;

           IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
           END IF;
        END IF;
     END IF;
     --}
     --End of bug 4070732

      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FAIL_CONT_ACTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FAIL_CONT_ACTION');
      END IF;
      --
   WHEN WSH_INVALID_ENTITY_TYPE then
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      rollback to Container_Action_SP_Grp;
      fnd_message.set_name('WSH', 'WSH_PUB_CONT_TYPE_ERR');
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
/*
      WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
      if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
      else
         x_msg_data := l_msg_summary;
      end if;
*/
     --Bugfix 4070732 {
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                     x_return_status => l_return_status);


           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;

           IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
           END IF;
        END IF;
     END IF;
     --}
     --End of bug 4070732

      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_ENTITY_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_ENTITY_TYPE');
      END IF;
      --
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      rollback to Container_Action_SP_Grp;
     --Bugfix 4070732 {
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;
           IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           END IF;

        END IF;
     END IF;
     --}
     --End of bug 4070732

      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      rollback to Container_Action_SP_Grp;
     --Bugfix 4070732 {
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;

        END IF;
     END IF;
     --}
     --End of bug 4070732

      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN OTHERS then
      wsh_util_core.default_handler('WSH_CONTAINER_GRP.Container_Actions');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      rollback to Container_Action_SP_Grp;
/*
      WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
      if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
      else
         x_msg_data := l_msg_summary;
      end if;
*/
     --Bugfix 4070732 {
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);


           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;

        END IF;
     END IF;
     --}
     --End of bug 4070732

      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Container_Actions;


END WSH_CONTAINER_GRP;

/
