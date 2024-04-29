--------------------------------------------------------
--  DDL for Package WMS_API_LPN_PACKAGE_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_API_LPN_PACKAGE_1" as
-- Procedure for Module Hook ID 200-- 

Procedure  GET_LPN(
            x_return_status                  OUT  NOCOPY  VARCHAR2,
            x_msg_count                      OUT  NOCOPY  NUMBER,
            x_msg_data                       OUT  NOCOPY  VARCHAR2,
            x_lpn_id                         OUT  NOCOPY  NUMBER,
            x_lpn_valid                      OUT  NOCOPY  VARCHAR2,
            p_mode                           IN  NUMBER,
            p_task_id                        IN  NUMBER,
            p_activity_type_id               IN  NUMBER,
            p_lpn_id                         IN  NUMBER,
            p_item_id                        IN  NUMBER,
            p_subinventory_code              IN  VARCHAR2,
            p_locator_id                     IN  NUMBER,
            p_api_version                    IN  NUMBER,
            p_init_msg_list                  IN  VARCHAR2,
            p_commit                         IN  VARCHAR2,
            p_hook_call_id                   IN  NUMBER
            );
end WMS_API_LPN_PACKAGE_1;

 

/
