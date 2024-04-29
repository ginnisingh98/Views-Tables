--------------------------------------------------------
--  DDL for Package GME_INCREMENTAL_BACKFLUSH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_INCREMENTAL_BACKFLUSH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVIBFS.pls 120.3 2005/12/22 05:44:17 svgonugu noship $ */

  PROCEDURE incremental_backflush
    (p_batch_header_rec           IN GME_BATCH_HEADER%ROWTYPE
    ,p_material_detail_rec        IN GME_MATERIAL_DETAILS%ROWTYPE
    ,p_qty                        IN NUMBER
    ,p_qty_type                   IN NUMBER
    ,p_trans_date                 IN DATE
    ,p_backflush_rsrc_usg_ind     IN NUMBER
    ,x_exception_material_tbl     IN OUT NOCOPY gme_common_pvt.exceptions_tab
    ,x_return_status              OUT NOCOPY VARCHAR2);

  PROCEDURE derive_factor
    (p_material_detail_rec   IN  gme_material_details%ROWTYPE
    ,p_qty                   IN  NUMBER
    ,p_qty_type              IN  NUMBER
    --FPBug#4667093
    ,p_gme_ib_factor         IN  NUMBER DEFAULT 0
    ,x_pct_plan              OUT NOCOPY NUMBER
    ,x_pct_plan_res          OUT NOCOPY NUMBER
    ,x_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE update_dependent_steps(p_batchstep_id     IN  NUMBER
                                  ,p_backflush_factor IN  NUMBER
                                  ,x_return_status    OUT NOCOPY VARCHAR2);

  PROCEDURE revert_material_partial
    (p_material_detail_rec        IN gme_material_details%ROWTYPE
    ,p_qty                        IN NUMBER
    ,p_lot_control_code           IN NUMBER  -- 1 = not lot control; 2 = lot control
    ,p_create_resv_pend_lots      IN NUMBER
    ,p_lot_divisible_flag         IN VARCHAR2
    ,x_actual_qty                 OUT NOCOPY NUMBER
    ,x_exception_material_tbl     IN OUT NOCOPY gme_common_pvt.exceptions_tab
    ,x_return_status              OUT NOCOPY VARCHAR2);

  PROCEDURE validate_material_for_IB(p_material_detail_rec IN gme_material_details%ROWTYPE
                                    ,p_batch_header_rec    IN gme_batch_header%ROWTYPE
                                    ,p_adjust_cmplt        IN VARCHAR2
                                    ,x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE validate_qty_for_IB (p_qty_type   IN NUMBER
                                ,p_qty        IN NUMBER
                                ,p_actual_qty IN NUMBER
                                ,x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE get_converted_qty (
      p_org_id                    IN NUMBER
     ,p_item_id                   IN NUMBER
     ,p_lot_number                IN VARCHAR2 DEFAULT NULL
     ,p_qty                       IN NUMBER
     ,p_from_um                   IN VARCHAR2
     ,p_to_um                     IN VARCHAR2
     ,x_conv_qty                  OUT NOCOPY NUMBER
     ,x_return_status             OUT NOCOPY VARCHAR2);

END gme_incremental_backflush_pvt;

 

/
