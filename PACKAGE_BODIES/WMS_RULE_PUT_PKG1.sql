--------------------------------------------------------
--  DDL for Package Body WMS_RULE_PUT_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_PUT_PKG1" AS

 ---- For Opening the Putaway  CURSOR ----
 ----
PROCEDURE EXECUTE_OPEN_RULE(
          p_cursor                     IN OUT NOCOPY WMS_RULE_PVT.cv_put_type,
          p_rule_id                    IN NUMBER,
          p_organization_id            IN NUMBER,
          p_inventory_item_id          IN NUMBER,
          p_transaction_type_id        IN NUMBER,
          p_subinventory_code          IN VARCHAR2,
          p_locator_id                 IN NUMBER,
          p_pp_transaction_temp_id     IN NUMBER,
          p_restrict_subs_code         IN NUMBER,
          p_restrict_locs_code         IN NUMBER,
          p_project_id                 IN NUMBER,
          p_task_id                    IN NUMBER,
          x_result                     OUT NOCOPY NUMBER) is

  BEGIN
     IF    p_rule_id = 7 THEN
         WMS_RULE_7.open_curs(
         p_cursor,
         p_organization_id,
         p_inventory_item_id,
         p_transaction_type_id,
         p_subinventory_code,
         p_locator_id,
         p_pp_transaction_temp_id,
         p_restrict_subs_code,
         p_restrict_locs_code,
         p_project_id,
         p_task_id,
         x_result );
     ELSIF    p_rule_id = 8 THEN
         WMS_RULE_8.open_curs(
         p_cursor,
         p_organization_id,
         p_inventory_item_id,
         p_transaction_type_id,
         p_subinventory_code,
         p_locator_id,
         p_pp_transaction_temp_id,
         p_restrict_subs_code,
         p_restrict_locs_code,
         p_project_id,
         p_task_id,
         x_result );
     ELSIF    p_rule_id = 9 THEN
         WMS_RULE_9.open_curs(
         p_cursor,
         p_organization_id,
         p_inventory_item_id,
         p_transaction_type_id,
         p_subinventory_code,
         p_locator_id,
         p_pp_transaction_temp_id,
         p_restrict_subs_code,
         p_restrict_locs_code,
         p_project_id,
         p_task_id,
         x_result );
     ELSIF    p_rule_id = 10 THEN
         WMS_RULE_10.open_curs(
         p_cursor,
         p_organization_id,
         p_inventory_item_id,
         p_transaction_type_id,
         p_subinventory_code,
         p_locator_id,
         p_pp_transaction_temp_id,
         p_restrict_subs_code,
         p_restrict_locs_code,
         p_project_id,
         p_task_id,
         x_result );
     ELSIF    p_rule_id = 11 THEN
         WMS_RULE_11.open_curs(
         p_cursor,
         p_organization_id,
         p_inventory_item_id,
         p_transaction_type_id,
         p_subinventory_code,
         p_locator_id,
         p_pp_transaction_temp_id,
         p_restrict_subs_code,
         p_restrict_locs_code,
         p_project_id,
         p_task_id,
         x_result );
     ELSIF    p_rule_id = 13 THEN
         WMS_RULE_13.open_curs(
         p_cursor,
         p_organization_id,
         p_inventory_item_id,
         p_transaction_type_id,
         p_subinventory_code,
         p_locator_id,
         p_pp_transaction_temp_id,
         p_restrict_subs_code,
         p_restrict_locs_code,
         p_project_id,
         p_task_id,
         x_result );
 
     END IF;
END EXECUTE_OPEN_RULE;

PROCEDURE EXECUTE_FETCH_RULE (
          p_cursor               IN WMS_RULE_PVT.cv_put_type,
          p_rule_id              IN NUMBER,
          x_subinventory_code    OUT NOCOPY VARCHAR2,
          x_locator_id           OUT NOCOPY NUMBER,
          x_project_id           OUT NOCOPY NUMBER,
          x_task_id              OUT NOCOPY NUMBER,
          x_return_status        OUT NOCOPY NUMBER) is

 BEGIN
     IF    p_rule_id = 7 THEN
         WMS_RULE_7.fetch_one_row(
         p_cursor,
         x_subinventory_code,
         x_locator_id,
         x_project_id,
         x_task_id,
         x_return_status );
     ELSIF    p_rule_id = 8 THEN
         WMS_RULE_8.fetch_one_row(
         p_cursor,
         x_subinventory_code,
         x_locator_id,
         x_project_id,
         x_task_id,
         x_return_status );
     ELSIF    p_rule_id = 9 THEN
         WMS_RULE_9.fetch_one_row(
         p_cursor,
         x_subinventory_code,
         x_locator_id,
         x_project_id,
         x_task_id,
         x_return_status );
     ELSIF    p_rule_id = 10 THEN
         WMS_RULE_10.fetch_one_row(
         p_cursor,
         x_subinventory_code,
         x_locator_id,
         x_project_id,
         x_task_id,
         x_return_status );
     ELSIF    p_rule_id = 11 THEN
         WMS_RULE_11.fetch_one_row(
         p_cursor,
         x_subinventory_code,
         x_locator_id,
         x_project_id,
         x_task_id,
         x_return_status );
     ELSIF    p_rule_id = 13 THEN
         WMS_RULE_13.fetch_one_row(
         p_cursor,
         x_subinventory_code,
         x_locator_id,
         x_project_id,
         x_task_id,
         x_return_status );
 
     END IF;

END EXECUTE_FETCH_RULE;

 PROCEDURE EXECUTE_CLOSE_RULE (p_rule_id IN NUMBER,
                               p_cursor  IN WMS_RULE_PVT.cv_put_type) is
   BEGIN
     IF    p_rule_id = 7 THEN
          WMS_RULE_7.close_curs(p_cursor);
     ELSIF    p_rule_id = 8 THEN
          WMS_RULE_8.close_curs(p_cursor);
     ELSIF    p_rule_id = 9 THEN
          WMS_RULE_9.close_curs(p_cursor);
     ELSIF    p_rule_id = 10 THEN
          WMS_RULE_10.close_curs(p_cursor);
     ELSIF    p_rule_id = 11 THEN
          WMS_RULE_11.close_curs(p_cursor);
     ELSIF    p_rule_id = 13 THEN
          WMS_RULE_13.close_curs(p_cursor);
 
     END IF;
 END EXECUTE_CLOSE_RULE;
END WMS_RULE_PUT_PKG1;
--COMMIT;
--EXIT;

/
