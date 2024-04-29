--------------------------------------------------------
--  DDL for Package WMS_RULE_8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_8" AS
                   procedure open_curs (
                   p_cursor                     IN OUT NOCOPY WMS_RULE_PVT.CV_PUT_TYPE,
                   p_organization_id            IN NUMBER,
                   p_inventory_item_id          IN NUMBER,
       p_transaction_type_id        IN NUMBER,
                   p_subinventory_code          IN VARCHAR2,
                   p_locator_id                 IN NUMBER,
                   p_pp_transaction_temp_id     IN NUMBER,
       p_restrict_subs_code   IN NUMBER,
       p_restrict_locs_code   IN NUMBER,
       p_project_id     IN NUMBER,
       p_task_id      IN NUMBER,
                   x_result                     OUT NOCOPY NUMBER);

                   PROCEDURE fetch_one_row  (
                      p_cursor              IN  WMS_RULE_PVT.CV_PUT_TYPE,
                      x_subinventory_code   OUT NOCOPY VARCHAR2,
                      x_locator_id          OUT NOCOPY NUMBER,
                      x_project_id          OUT NOCOPY NUMBER,
                      x_task_id             OUT NOCOPY NUMBER,
                      x_return_status       OUT NOCOPY NUMBER);

                   PROCEDURE close_curs(p_cursor IN  WMS_RULE_PVT.CV_PUT_TYPE );

    end WMS_RULE_8;

/
