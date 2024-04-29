--------------------------------------------------------
--  DDL for Package Body WMS_API_LOC_PACKAGE_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_API_LOC_PACKAGE_2" as
-- Procedure for Module Hook ID 100-- 

Procedure  GET_LOC(
            x_return_status                  OUT  NOCOPY  VARCHAR2,
            x_msg_count                      OUT  NOCOPY  NUMBER,
            x_msg_data                       OUT  NOCOPY  VARCHAR2,
            x_locator_id                     OUT  NOCOPY  NUMBER,
            x_zone_id                        OUT  NOCOPY  NUMBER,
            x_subinventory_code              OUT  NOCOPY  VARCHAR2,
            x_loc_valid                      OUT  NOCOPY  VARCHAR2,
            p_mode                           IN  NUMBER,
            p_task_id                        IN  NUMBER,
            p_activity_type_id               IN  NUMBER,
            p_locator_id                     IN  NUMBER,
            p_item_id                        IN  NUMBER,
            p_api_version                    IN  NUMBER,
            p_init_msg_list                  IN  VARCHAR2,
            p_commit                         IN  VARCHAR2,
            p_hook_call_id                   IN  NUMBER
            ) is
begin  
If p_hook_call_id = 1  then
    WMS_GET_DEST_LOC_LPN.WMS_DEST_LOC_W_ITEM(
            x_return_status                  =>  x_return_status,
            x_msg_count                      =>  x_msg_count,
            x_msg_data                       =>  x_msg_data,
            x_locator_id                     =>  x_locator_id,
            x_zone_id                        =>  x_zone_id,
            x_subinventory_code              =>  x_subinventory_code,
            x_loc_valid                      =>  x_loc_valid,
            p_mode                           =>  p_mode,
            p_task_id                        =>  p_task_id,
            p_activity_type_id               =>  p_activity_type_id,
            p_locator_id                     =>  p_locator_id,
            p_item_id                        =>  p_item_id,
            p_api_version                    =>  p_api_version,
            p_init_msg_list                  =>  p_init_msg_list,
            p_commit                         =>  p_commit
            );
elsif p_hook_call_id = 2  then
    WMS_GET_DEST_LOC_LPN.WMS_DEST_LOC_WO_ITEM(
            x_return_status                  =>  x_return_status,
            x_msg_count                      =>  x_msg_count,
            x_msg_data                       =>  x_msg_data,
            x_locator_id                     =>  x_locator_id,
            x_zone_id                        =>  x_zone_id,
            x_subinventory_code              =>  x_subinventory_code,
            x_loc_valid                      =>  x_loc_valid,
            p_mode                           =>  p_mode,
            p_task_id                        =>  p_task_id,
            p_activity_type_id               =>  p_activity_type_id,
            p_locator_id                     =>  p_locator_id,
            p_item_id                        =>  p_item_id,
            p_api_version                    =>  p_api_version,
            p_init_msg_list                  =>  p_init_msg_list,
            p_commit                         =>  p_commit
            );
end if; 
end; 

end WMS_API_LOC_PACKAGE_2;

/
