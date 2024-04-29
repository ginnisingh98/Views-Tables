--------------------------------------------------------
--  DDL for Package WMS_RULE_6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_6" AS
                   procedure open_curs (
                   p_cursor            IN OUT NOCOPY WMS_RULE_PVT.cv_pick_type,
                   p_organization_id            IN NUMBER,
                   p_inventory_item_id          IN NUMBER,
                   p_transaction_type_id        IN NUMBER,
                   p_revision                   IN VARCHAR2,
                   p_lot_number                 IN VARCHAR2,
                   p_subinventory_code          IN VARCHAR2,
                   p_locator_id                 IN NUMBER,
                   p_cost_group_id          IN NUMBER,
                   p_pp_transaction_temp_id     IN NUMBER,
                   p_serial_controlled    IN NUMBER,
                   p_detail_serial    IN NUMBER,
                   p_detail_any_serial    IN NUMBER,
                   p_from_serial_number   IN VARCHAR2,
                   p_to_serial_number   IN VARCHAR2,
                   p_unit_number    IN VARCHAR2,
                   p_lpn_id     IN NUMBER,
                   p_project_id     IN NUMBER,
                   p_task_id      IN NUMBER,
                   x_result                     OUT NOCOPY NUMBER);

                   PROCEDURE fetch_one_row  (
                      p_cursor                 IN WMS_RULE_PVT.cv_pick_type,
                      x_revision               OUT NOCOPY VARCHAR2,
                      x_lot_number             OUT NOCOPY VARCHAR2,
                      x_lot_expiration_date    OUT NOCOPY DATE,
                      x_subinventory_code      OUT NOCOPY VARCHAR2,
                      x_locator_id             OUT NOCOPY NUMBER,
                      x_cost_group_id          OUT NOCOPY NUMBER,
                      x_uom_code               OUT NOCOPY VARCHAR2,
                      x_lpn_id                 OUT NOCOPY NUMBER,
                      x_serial_number          OUT NOCOPY VARCHAR2,
                      x_possible_quantity      OUT NOCOPY NUMBER,
                      x_sec_possible_quantity  OUT NOCOPY NUMBER,
                      x_grade_code             OUT NOCOPY VARCHAR2,
                      x_consist_string         OUT NOCOPY VARCHAR2,
                      x_order_by_string        OUT NOCOPY VARCHAR2,
                      x_return_status          OUT NOCOPY NUMBER);

            PROCEDURE close_curs( p_cursor  IN WMS_RULE_PVT.cv_pick_type);

            PROCEDURE fetch_available_rows  (
                      p_cursor              IN WMS_RULE_PVT.cv_pick_type,
                      x_return_status       OUT NOCOPY NUMBER);



    end WMS_RULE_6;

/
