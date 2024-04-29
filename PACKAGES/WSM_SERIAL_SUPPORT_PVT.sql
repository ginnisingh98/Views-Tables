--------------------------------------------------------
--  DDL for Package WSM_SERIAL_SUPPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_SERIAL_SUPPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: WSMVSERS.pls 120.4 2006/04/11 23:43 sthangad noship $ */

TYPE t_serial_intf_tbl_type is table of WSM_SERIAL_TXN_INTERFACE%ROWTYPE index by binary_integer;
TYPE t_serial_temp_tbl_type is table of WSM_SERIAL_TXN_TEMP%ROWTYPE index by binary_integer;
TYPE t_serial_number_tbl_type is table of MTL_SERIAL_NUMBERS%ROWTYPE index by binary_integer;
TYPE t_number is table of NUMBER index by binary_integer;
type t_varchar2 is table of varchar2(100) index by binary_integer;
TYPE t_wip_intf_tbl_type is table of WIP_SERIAL_MOVE_INTERFACE%ROWTYPE index by binary_integer;

WSM_ADD_SERIAL_NUM      CONSTANT NUMBER := 1;
WSM_DELINK_SERIAL_NUM   CONSTANT NUMBER := 2;
WSM_UPDATE_SERIAL_NUM   CONSTANT NUMBER := 3;
WSM_GASSOC_SERIAL_NUM   CONSTANT NUMBER := 4;


procedure update_serial( p_serial_number                IN              VARCHAR2,
                         p_inventory_item_id            IN              NUMBER,
                         -- p_new_inventory_item_id     IN              NUMBER,
                         p_organization_id              IN              NUMBER,
                         p_wip_entity_id                IN              NUMBER,
                         p_operation_seq_num            IN              NUMBER,
                         p_intraoperation_step_type     IN              NUMBER,
                         x_return_status                OUT NOCOPY      VARCHAR2,
                         x_error_msg                    OUT NOCOPY      VARCHAR2,
                         x_error_count                  OUT NOCOPY      NUMBER
                        );


PROCEDURE update_serial_attr( p_job_serial_number     IN   VARCHAR2,
                              p_inventory_item_id     IN   NUMBER,
                              p_organization_id       IN   NUMBER,
                              p_serial_desc_attr_tbl  IN   inv_serial_number_attr.char_table,
                              p_attribute_category    IN   VARCHAR2,
                              p_update_serial_attr    IN   NUMBER DEFAULT NULL,
                              p_update_desc_attr      IN   NUMBER,
                              p_serial_attributes_tbl IN   inv_lot_sel_attr.lot_sel_attributes_tbl_type,
                              x_return_status         OUT  NOCOPY  VARCHAR2,
                              x_error_count           OUT  NOCOPY NUMBER,
                              x_error_msg             OUT  NOCOPY VARCHAR2
                            );

PROCEDURE validate_qty  ( p_primary_item_id           IN        NUMBER,
                          p_organization_id           IN        NUMBER,
                          p_primary_qty               IN        NUMBER,
                          p_net_qty                   IN        NUMBER,
                          p_primary_uom               IN        VARCHAR2,
                          p_transaction_qty           IN        NUMBER  DEFAULT NULL,
                          p_transaction_uom           IN        VARCHAR2 DEFAULT NULL,
                          x_return_status             OUT NOCOPY VARCHAR2,
                          x_error_count               OUT NOCOPY NUMBER,
                          x_error_msg                 OUT NOCOPY VARCHAR2
                        );


Procedure add_assoc_serial_number(p_wip_entity_id               IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_inventory_item_id           IN              NUMBER,
                                  -- will be null in case (Generation..)
                                  p_serial_number               IN  OUT NOCOPY  VARCHAR2,
                                  -- pass 1 if the calling program knows that it is a new serial number
                                  p_new_serial_number           IN              NUMBER DEFAULT NULL,
                                  p_operation_seq_num           IN              NUMBER          DEFAULT NULL,
                                  p_intraoperation_step         IN              NUMBER          DEFAULT NULL,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                 );
Procedure LBJ_serial_intf_proc( p_header_id             IN         NUMBER,
                                p_wip_entity_id         IN         NUMBER,
                                p_organization_id       IN         NUMBER,
                                p_inventory_item_id     IN         NUMBER,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_error_count           OUT NOCOPY NUMBER,
                                x_error_msg             OUT NOCOPY VARCHAR2
                               ) ;

-- The addition/deletion of serial numbers will be handled by this procedure...
-- Then it will invoke the main processor whose activities will be common...
-- When there is data in p_wsm_serial_nums_tbl, p_header_id will be ignored and no data will be fetched from the interface
Procedure Move_serial_intf_proc(p_header_id                     IN              NUMBER,
                                p_wsm_serial_nums_tbl           IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                p_move_txn_type                 IN              NUMBER,
                                p_wip_entity_id                 IN              NUMBER,
                                p_organization_id               IN              NUMBER,
                                p_inventory_item_id             IN              NUMBER,
                                p_move_qty                      IN              NUMBER,
                                p_scrap_qty                     IN              NUMBER,
                                p_available_qty                 IN              NUMBER,
                                p_curr_job_op_seq_num           IN              NUMBER,
                                p_curr_job_intraop_step         IN              NUMBER,
                                p_from_rtg_op_seq_num           IN              NUMBER,
                                p_to_rtg_op_seq_num             IN              NUMBER,
                                p_to_intraoperation_step        IN              NUMBER,
                                p_user_serial_tracking          IN              NUMBER,
                                p_move_txn_id                   IN              NUMBER,
                                p_scrap_txn_id                  IN              NUMBER,
                                p_old_move_txn_id               IN              NUMBER,
                                p_old_scrap_txn_id              IN              NUMBER,
                                p_jump_flag                     IN              VARCHAR2   DEFAULT  NULL,
                                p_scrap_at_operation            IN              NUMBER     DEFAULT  NULL,
                                -- ST : Fix for bug 5140761 Addded the above parameter --
                                x_serial_track_flag             OUT NOCOPY      NUMBER,
                                x_return_status                 OUT NOCOPY      VARCHAR2,
                                x_error_msg                     OUT NOCOPY      VARCHAR2,
                                x_error_count                   OUT NOCOPY      NUMBER
                               );

Procedure Update_attr_move ( p_group_id          IN         NUMBER      DEFAULT NULL,  -- for interface...
                             p_internal_group_id IN         NUMBER      DEFAULT NULL,
                             p_move_txn_id       IN         NUMBER      DEFAULT NULL,  -- for forms...
                             p_scrap_txn_id      IN         NUMBER      DEFAULT NULL,  -- for forms...
                             p_organization_id   IN         NUMBER                  ,
                             x_return_status     OUT NOCOPY VARCHAR2                ,
                             x_error_count       OUT NOCOPY NUMBER                  ,
                             x_error_msg         OUT NOCOPY VARCHAR2
                           );

Procedure Insert_move_attr ( p_group_id         IN         NUMBER       DEFAULT NULL,
                             p_move_txn_id      IN         NUMBER       DEFAULT NULL,
                             p_scrap_txn_id     IN         NUMBER       DEFAULT NULL,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_error_count      OUT NOCOPY NUMBER,
                             x_error_msg        OUT NOCOPY VARCHAR2
                           );

Procedure Move_forms_serial_proc( p_move_txn_type               IN              NUMBER,
                                  p_wip_entity_id               IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_inventory_item_id           IN              NUMBER,
                                  p_move_qty                    IN              NUMBER,
                                  p_scrap_qty                   IN              NUMBER,
                                  p_available_qty               IN              NUMBER,
                                  p_curr_job_op_seq_num         IN              NUMBER,
                                  p_curr_job_intraop_step       IN              NUMBER,
                                  p_from_rtg_op_seq_num         IN              NUMBER,
                                  p_to_rtg_op_seq_num           IN              NUMBER,
                                  p_to_intraoperation_step      IN              NUMBER,
                                  p_user_serial_tracking        IN              NUMBER,
                                  p_move_txn_id                 IN              NUMBER,
                                  p_scrap_txn_id                IN              NUMBER,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                );

Procedure WLT_serial_intf_proc ( p_header_id            IN              NUMBER,
                                 p_wip_entity_id        IN              NUMBER,
                                 p_wip_entity_name      IN              VARCHAR2,
                                 p_wlt_txn_type         IN              NUMBER,
                                 p_organization_id      IN              NUMBER,
                                 x_serial_num_tbl       OUT NOCOPY      WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                 x_return_status        OUT NOCOPY      VARCHAR2,
                                 x_error_msg            OUT NOCOPY      VARCHAR2,
                                 x_error_count          OUT NOCOPY      NUMBER
                               );


Procedure WLT_serial_processor  ( p_calling_mode                IN              NUMBER,
                                  p_wlt_txn_type                IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_txn_id                      IN              NUMBER,
                                  p_starting_jobs_tbl           IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                  p_resulting_jobs_tbl          IN              WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                  p_serial_num_tbl              IN OUT NOCOPY   WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                );

Procedure find_undo_ret_serials ( p_header_id            IN                     NUMBER,  -- passed value will be :parameter.move_txn_id
                                  p_wip_entity_id        IN                     NUMBER,
                                  p_move_txn_type        IN                     NUMBER,
                                  p_organization_id      IN                     NUMBER,
                                  p_inventory_item_id    IN                     NUMBER,
                                  p_move_qty             IN                     NUMBER,
                                  p_scrap_qty            IN                     NUMBER,
                                  x_return_status        OUT NOCOPY             VARCHAR2,
                                  x_error_msg            OUT NOCOPY             VARCHAR2,
                                  x_error_count          OUT NOCOPY             NUMBER
                                );
END WSM_Serial_support_PVT;

 

/
