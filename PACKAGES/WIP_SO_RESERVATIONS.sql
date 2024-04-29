--------------------------------------------------------
--  DDL for Package WIP_SO_RESERVATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SO_RESERVATIONS" AUTHID CURRENT_USER AS
/* $Header: wipsorvs.pls 120.2.12000000.2 2007/02/23 22:27:33 kboonyap ship $ */


  g_package_name CONSTANT VARCHAR2(30) := 'WIP_SO_RESERVATIONS';
  g_need_to_rollback_exception EXCEPTION;

  /* ER 4378835: Increased length of lot_number from 30 to 80 to support OPM Lot-model changes */
  TYPE transaction_temp_rec_type is RECORD (
        demand_source_header_id                 NUMBER,
        demand_source_line_id                   VARCHAR2(30),
        organization_id                         NUMBER,
        inventory_item_id                       NUMBER,
        revision                                VARCHAR2(3),
        subinventory_code                       VARCHAR2(10),
        locator_id                              NUMBER,
        lot_control_code                        NUMBER,
        lot_number                              VARCHAR2(80),
        wip_entity_id                           NUMBER,
        transaction_uom                         VARCHAR2(3),
        transaction_date                        DATE,
        primary_quantity                        NUMBER,
        transaction_quantity                    NUMBER,
        demand_class_code                       VARCHAR2(30),
        lot_expiration_date                     DATE,
        transaction_temp_id                     NUMBER,
        lpn_id                                  NUMBER
  );

  TYPE transaction_temp_tbl_type is TABLE OF transaction_temp_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE demand_temp_rec_type is RECORD (
        source_header_id                        NUMBER,
        source_line_id                          NUMBER,
        source_delivery                         NUMBER,
        primary_quantity                        NUMBER,
        requirement_date                        VARCHAR2(20),
        uom_code                                VARCHAR2(3),
        subinventory_code                       VARCHAR(10),
        conversion_rate                         NUMBER
  );

  TYPE demand_temp_tbl_type is TABLE of demand_temp_rec_type
        INDEX BY BINARY_INTEGER;

  mmtt_count  NUMBER := 0;
  reservation_count NUMBER := 0;

  TYPE move_transaction_intf_rec_type is RECORD (
        wip_entity_id                           NUMBER,
        transaction_id                          NUMBER,
        transaction_type                        NUMBER,
        organization_id                         NUMBER,
        primary_item_id                         NUMBER,
        fm_operation_seq_num                    NUMBER,
        fm_intraoperation_step_type             NUMBER,
        to_operation_seq_num                    NUMBER,
        to_intraoperation_step_type             NUMBER,
        primary_quantity                        NUMBER,
        primary_uom                             VARCHAR2(3),
        entity_type                             NUMBER,
        repetitive_schedule_id                  NUMBER,
        transaction_date                        DATE
  );

  TYPE move_transaction_intf_tbl_type is TABLE OF move_transaction_intf_rec_type
        INDEX BY BINARY_INTEGER;

  PROCEDURE get_transaction_lines (
        p_transaction_header_id IN  NUMBER,
        p_transaction_type      IN  NUMBER,
        p_txn_temp_id           IN  NUMBER := NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_transaction_tbl       OUT NOCOPY transaction_temp_tbl_type);

  --for use in lpn completions
  PROCEDURE get_transaction_lines (
        p_header_id             IN  NUMBER,
        p_transaction_type      IN  NUMBER,
        p_transaction_action_id IN  NUMBER,
        p_primary_quantity      IN  NUMBER, --lpn passed to inv's transfer_reservation
        p_lpn_id                IN  NUMBER, --override quantity in table.
        p_lot_number            IN VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_transaction_tbl       OUT NOCOPY transaction_temp_tbl_type);

  FUNCTION validate_txn_line_against_rsv(
        p_transaction_rec       IN  transaction_temp_rec_type,
        p_reservation_rec       IN  inv_reservation_global.mtl_reservation_rec_type,
        p_transaction_type      IN  NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_query_reservation     OUT NOCOPY VARCHAR2)
                                RETURN BOOLEAN;

  PROCEDURE transfer_reservation(
        p_transaction_rec       IN  transaction_temp_rec_type,
        p_reservation_rec       IN  inv_reservation_global.mtl_reservation_rec_type,
        p_transaction_type      IN  NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2);

  /*Bug 5676680: Added one extra parameter p_transaction_temp_id*/
  PROCEDURE complete_flow_sched_to_so (
        p_transaction_header_id IN  NUMBER,
        p_transaction_temp_id   IN  NUMBER DEFAULT NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);


  --for use in lpn completions
  PROCEDURE complete_flow_sched_to_so (p_header_id             IN  NUMBER,
                                       p_lpn_id                IN  NUMBER,
                                       p_primary_quantity      IN  NUMBER, --lpn passed to inv's transfer_reservation
                                       p_lot_number            IN  VARCHAR2,
                                       x_return_status         OUT NOCOPY VARCHAR2,
                                       x_msg_count             OUT NOCOPY NUMBER,
                                       x_msg_data              OUT NOCOPY VARCHAR2);
  PROCEDURE allocate_completion_to_so (
        p_organization_id       IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_inventory_item_id     IN  NUMBER,
        p_transaction_header_id IN  NUMBER,
        p_table_type            IN  VARCHAR2,--either 'MMTT' or 'WLC'
        p_primary_quantity      IN  NUMBER, --lpn passed to inv's transfer_reservation
        p_lpn_id                IN  NUMBER, --override quantity in table.
        p_lot_number            IN  VARCHAR2,
        p_txn_temp_id           IN  NUMBER := NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);

  --calls above allocate_completion_to_so with table_type = 'MMTT'
  PROCEDURE allocate_completion_to_so (
        p_organization_id       IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_inventory_item_id     IN  NUMBER,
        p_transaction_header_id IN  NUMBER,
        p_txn_temp_id           IN  NUMBER := NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);


  PROCEDURE return_reservation_to_wip (
        p_organization_id       IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_inventory_item_id     IN  NUMBER,
        p_transaction_header_id IN  NUMBER,
        p_txn_temp_id           IN  NUMBER := NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);


  PROCEDURE split_order_line(
        p_old_demand_source_line_id     IN  NUMBER,
        p_new_demand_source_line_id     IN  NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2);


  PROCEDURE make_callback_to_workflow (
        p_organization_id       IN      NUMBER,
        p_inventory_item_id     IN      NUMBER,
        p_order_line_id         IN      NUMBER,
        p_type                  IN      VARCHAR2,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2);


  PROCEDURE respond_to_change_order (
        p_org_id                IN      NUMBER,
        p_header_id             IN      NUMBER,
        p_line_id               IN      NUMBER,
        x_status                OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2);

  PROCEDURE get_move_transaction_lines (
        p_group_id              IN         NUMBER,
        p_wip_entity_id         IN         NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_move_transaction_tbl  OUT NOCOPY move_transaction_intf_tbl_type);

  PROCEDURE scrap_txn_relieve_rsv ( p_group_id      IN         NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count     OUT NOCOPY NUMBER,
                                    x_msg_data      OUT NOCOPY VARCHAR2);

  PROCEDURE Relieve_wip_reservation(
        p_wip_entity_id     IN  Number,
        p_organization_id   IN  Number,
        p_inventory_item_id IN  Number,
        p_primary_quantity  IN  Number,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2);

 -- Fixed bug 5471890. Need to create PL/SQL wrapper when calling inventory
 -- reservation API since some environment failed to compile if we try to
 -- reference PL/SQL object from form directly.
  PROCEDURE update_row(p_item_revision           IN VARCHAR2,
                       p_reservation_id          IN NUMBER,
                       p_requirement_date        IN DATE,
                       p_demand_source_header_id IN NUMBER,
                       p_demand_source_line_id   IN NUMBER,
                       p_primary_quantity        IN NUMBER,
                       p_wip_entity_id           IN NUMBER,
                       x_return_status           OUT NOCOPY VARCHAR2);

  PROCEDURE lock_row(p_reservation_id               IN NUMBER,
                     x_reservation_id               OUT NOCOPY NUMBER,
                     x_supply_source_header_id      OUT NOCOPY NUMBER,
                     x_organization_id              OUT NOCOPY NUMBER,
                     x_demand_source_header_id      OUT NOCOPY NUMBER,
                     x_primary_reservation_quantity OUT NOCOPY NUMBER,
                     x_demand_source_line_id        OUT NOCOPY NUMBER,
                     x_size                         OUT NOCOPY NUMBER,
                     x_return_status                OUT NOCOPY VARCHAR2);

  -- End fix of bug 5471890.


END WIP_SO_RESERVATIONS;

 

/
