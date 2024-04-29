--------------------------------------------------------
--  DDL for Package WMS_PICK_DROP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PICK_DROP_PVT" AUTHID CURRENT_USER AS
  /* $Header: WMSPKDPS.pls 120.1.12010000.2 2011/09/21 03:29:50 abasheer ship $ */

  g_pkg_spec_ver  CONSTANT VARCHAR2(100) := '$Header: WMSPKDPS.pls 120.1.12010000.2 2011/09/21 03:29:50 abasheer ship $';
  g_pkg_name      CONSTANT VARCHAR2(30)  := 'WMS_PICK_DROP_PVT';

  TYPE t_genref IS REF CURSOR;


  PROCEDURE chk_if_deconsolidate
  ( x_multiple_drops   OUT NOCOPY   VARCHAR2
  , x_drop_type        OUT NOCOPY   VARCHAR2
  , x_bulk_pick        OUT NOCOPY   VARCHAR2
  , x_drop_lpn_option  OUT NOCOPY   NUMBER
  , x_delivery_id      OUT NOCOPY   NUMBER
  , x_first_temp_id    OUT NOCOPY   NUMBER
  , x_task_type        OUT NOCOPY   NUMBER
  , x_txn_type_id      OUT NOCOPY   NUMBER
  , x_return_status    OUT NOCOPY   VARCHAR2
  , p_organization_id  IN           NUMBER
  , p_transfer_lpn_id  IN           NUMBER
  , p_suggestion_drop  IN           VARCHAR2 -- Added for bug 12853197
  );



  PROCEDURE fetch_next_drop
  ( x_drop_type        OUT NOCOPY   VARCHAR2
  , x_bulk_pick        OUT NOCOPY   VARCHAR2
  , x_drop_lpn_option  OUT NOCOPY   NUMBER
  , x_delivery_id      OUT NOCOPY   NUMBER
  , x_tasks            OUT NOCOPY   t_genref
  , x_lpn_done         OUT NOCOPY   VARCHAR2
  , x_first_temp_id    OUT NOCOPY   NUMBER
  , x_total_qty        OUT NOCOPY   NUMBER -- Added for bug 12853197
  , x_task_type        OUT NOCOPY   NUMBER
  , x_txn_type_id      OUT NOCOPY   NUMBER
  , x_return_status    OUT NOCOPY   VARCHAR2
  , p_organization_id  IN           NUMBER
  , p_transfer_lpn_id  IN           NUMBER
  );



  PROCEDURE get_wip_job_info
  ( x_entity_type        OUT NOCOPY NUMBER
  , x_job                OUT NOCOPY VARCHAR2
  , x_line               OUT NOCOPY VARCHAR2
  , x_dept               OUT NOCOPY VARCHAR2
  , x_operation_seq_num  OUT NOCOPY NUMBER
  , x_start_date         OUT NOCOPY DATE
  , x_schedule           OUT NOCOPY VARCHAR2
  , x_assembly           OUT NOCOPY VARCHAR2
  , x_return_status      OUT NOCOPY VARCHAR2
  , p_organization_id    IN         NUMBER
  , p_transfer_lpn_id    IN         NUMBER
  );



  PROCEDURE get_sub_xfer_dest_info
    (x_to_sub           OUT NOCOPY  VARCHAR2,
     x_to_loc           OUT NOCOPY  VARCHAR2,
     x_to_loc_id        OUT NOCOPY  NUMBER,
     x_project_num      OUT NOCOPY  VARCHAR2,
     x_prj_id           OUT NOCOPY  VARCHAR2,
     x_task_num         OUT NOCOPY  VARCHAR2,
     x_tsk_id           OUT NOCOPY  VARCHAR2,
     x_return_status    OUT NOCOPY  VARCHAR2,
     p_organization_id  IN          NUMBER,
     p_transfer_lpn_id  IN          NUMBER,
     x_transfer_lpn_id  OUT nocopy  NUMBER,
     x_transfer_lpn     OUT nocopy  VARCHAR2);


  PROCEDURE get_default_drop_lpn
  ( x_drop_lpn_num     OUT NOCOPY  VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_delivery_id      IN          NUMBER
  , p_to_sub           IN          VARCHAR2
  , p_to_loc           IN          NUMBER
  );



  PROCEDURE get_lot_lov
  ( x_lot_lov        OUT NOCOPY  t_genref
  , p_item_id        IN          NUMBER
  , p_revision       IN          VARCHAR2
  , p_inner_lpn      IN          VARCHAR2
  , p_conf_uom_code  IN          VARCHAR2
  , p_lot_num        IN          VARCHAR2
  );



  PROCEDURE get_serial_lov
  ( x_serial_lov  OUT NOCOPY  t_genref
  , p_item_id     IN          NUMBER
  , p_revision    IN          VARCHAR2
  , p_inner_lpn   IN          VARCHAR2
  , p_lot_num     IN          VARCHAR2
  , p_serial      IN          VARCHAR2
  );



  PROCEDURE process_inner_lpn
  ( x_ret_code          OUT NOCOPY  NUMBER
  , x_remaining_qty     OUT NOCOPY  NUMBER
  , x_inner_lpn_exists  OUT NOCOPY  VARCHAR2
  , x_return_status     OUT NOCOPY  VARCHAR2
  , p_lpn               IN          VARCHAR2
  , p_group_number      IN          NUMBER
  , p_item_id           IN          NUMBER
  , p_revision          IN          VARCHAR2
  , p_qty               IN          NUMBER
  , p_primary_uom       IN          VARCHAR2
  , p_serial_control    IN          VARCHAR2
  );



  PROCEDURE process_loose_qty
  ( x_loose_qty_exists  OUT NOCOPY  VARCHAR2
  , x_return_status     OUT NOCOPY  VARCHAR2
  , p_group_number      IN          NUMBER
  , p_item_id           IN          NUMBER
  , p_revision          IN          VARCHAR2
  , p_qty               IN          NUMBER
  , p_primary_uom       IN          VARCHAR2
  );



  PROCEDURE cancel_task
  ( x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  );



  PROCEDURE validate_xfer_to_lpn
  ( x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_group_number     IN          NUMBER
  , p_outer_lpn_done   IN          VARCHAR2
  , p_xfer_to_lpn      IN          VARCHAR2
  , p_dest_sub         IN          VARCHAR2
  , p_dest_loc_id      IN          NUMBER
  , p_delivery_id      IN          NUMBER
  );



  PROCEDURE pick_drop
  ( x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_emp_id           IN          NUMBER
  , p_drop_lpn         IN          VARCHAR2
  , p_orig_subinv      IN          VARCHAR2
  , p_subinventory     IN          VARCHAR2
  , p_orig_locid       IN          VARCHAR2
  , p_loc_id           IN          NUMBER
  , p_reason_id        IN          NUMBER
  , p_task_type        IN          NUMBER
  , p_outer_lpn_done   IN          VARCHAR2
  , p_bulk_drop        IN          VARCHAR2
  );



  PROCEDURE create_temp_id_list
  ( x_temp_id_list     OUT NOCOPY  VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  );



  PROCEDURE process_serial
  ( x_loose_qty_exists  OUT NOCOPY  VARCHAR2
  , x_return_status     OUT NOCOPY  VARCHAR2
  , p_organization_id   IN          NUMBER
  , p_transfer_lpn_id   IN          NUMBER
  , p_lpn               IN          VARCHAR2
  , p_item_id           IN          NUMBER
  , p_revision          IN          VARCHAR2
  , p_lot_number        IN          VARCHAR2
  , p_serial_number     IN          VARCHAR2
  , p_group_number      IN          NUMBER
  );



  PROCEDURE get_delivery_info
  ( x_delivery_name    OUT NOCOPY  VARCHAR2
  , x_order_number     OUT NOCOPY  VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_delivery_id      IN          NUMBER
  );



  PROCEDURE process_conf_item
  ( x_is_xref          OUT NOCOPY  VARCHAR2
  , x_item_segs        OUT NOCOPY  VARCHAR2
  , x_revision         OUT NOCOPY  VARCHAR2
  , x_uom_code         OUT NOCOPY  VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_conf_item        IN          VARCHAR2
  );



  PROCEDURE validate_pick_drop_lpn
  ( x_return_status    OUT NOCOPY  VARCHAR2
  , p_organization_id  IN          NUMBER
  , p_transfer_lpn_id  IN          NUMBER
  , p_outer_lpn_done   IN          VARCHAR2
  , p_drop_lpn         IN          VARCHAR2
  , p_drop_sub         IN          VARCHAR2
  , p_drop_loc_id      IN          NUMBER
  , p_delivery_id      IN          NUMBER
  );

END wms_pick_drop_pvt;

/
