--------------------------------------------------------
--  DDL for Package WMS_RULE_PUT_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_PUT_PKG3" AS


 ---- For Opening the Putaway CURSOR ----
 ----
PROCEDURE EXECUTE_OPEN_RULE(
          p_cursor                  IN OUT NOCOPY WMS_RULE_PVT.cv_put_type,
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
          x_result                     OUT NOCOPY NUMBER);

PROCEDURE EXECUTE_FETCH_RULE (
          p_cursor               IN WMS_RULE_PVT.cv_put_type,
          p_rule_id              IN NUMBER,
          x_subinventory_code   OUT NOCOPY VARCHAR2,
          x_locator_id          OUT NOCOPY NUMBER,
          x_project_id          OUT NOCOPY NUMBER,
          x_task_id             OUT NOCOPY NUMBER,
          x_return_status       OUT NOCOPY NUMBER);

PROCEDURE EXECUTE_CLOSE_RULE (p_rule_id IN NUMBER,
                              p_cursor  IN  WMS_RULE_PVT.cv_put_type) ;

END WMS_RULE_PUT_PKG3;
--COMMIT;
--EXIT;



/
