--------------------------------------------------------
--  DDL for Package GMD_SAMPLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SAMPLES_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGSMPS.pls 120.9.12010000.2 2009/03/18 21:00:41 plowe ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGSMPS.pls                                        |
--| Package Name       : GMD_Samples_GRP                                     |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Entity       |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	26-Jul-2002	Created.                             |
--|    RLNAGARA  20-Dec-2005 Bug# 4880152  Added the revision variable in the sample_disp_rec
--|    Joe DiIorio   01/25/2006 Added grade_code to sample_display_rec.
--|    M. Grosser 02/28/2006: BUG 5016617 -Added supplier_name to            |
--|               sample_display_rec.                                        |
--+==========================================================================+
-- End of comments



-- Bug 2952823: changes for manual spec matching including new spec_vr_id parameter
FUNCTION sampling_event_exist
(
  p_sample            IN         gmd_samples%ROWTYPE
, x_sampling_event_id OUT NOCOPY NUMBER
, p_spec_vr_id        IN         NUMBER DEFAULT NULL
)
RETURN BOOLEAN;


FUNCTION sampling_event_exist_wo_spec
(
  p_sample            IN         gmd_samples%ROWTYPE
, x_sampling_event_id OUT NOCOPY NUMBER
)
RETURN BOOLEAN;

FUNCTION sample_exist
(
  p_organization_id  NUMBER
, p_sample_no        VARCHAR2
)
RETURN BOOLEAN;

PROCEDURE validate_sample
(
  p_sample        IN         GMD_SAMPLES%ROWTYPE
, p_called_from   IN         VARCHAR2 DEFAULT 'API'
, p_operation     IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
);


TYPE update_disp_rec IS RECORD
(
   sample_id               NUMBER
  ,composite_spec_disp_id  NUMBER
  ,event_spec_disp_id      NUMBER
  ,no_of_samples_for_event NUMBER
  ,called_from_results     VARCHAR2(1)
  ,sampling_event_id	   NUMBER
  ,curr_disposition	   VARCHAR2(3)
);


TYPE update_change_disp_rec IS RECORD
(
   CHANGE_DISP_ID         NUMBER
  ,ORGANIZATION_ID        NUMBER
  ,INVENTORY_ITEM_ID      NUMBER
  ,SAMPLE_ID              NUMBER
  ,SAMPLING_EVENT_ID      NUMBER
  ,CREATION_DATE          DATE
  ,CREATED_BY             NUMBER(15)
  ,LAST_UPDATED_BY        NUMBER(15)
  ,LAST_UPDATE_DATE       DATE
  ,LAST_UPDATE_LOGIN      NUMBER(15)
  ,DISPOSITION_FROM       VARCHAR2(3)
  ,DISPOSITION_TO         VARCHAR2(3)
  ,PARENT_LOT_NUMBER      VARCHAR2(80)
  ,LOT_NUMBER             VARCHAR2(80)
  ,TO_LOT_STATUS_ID       NUMBER
  ,FROM_LOT_STATUS_ID     NUMBER
  ,TO_GRADE_CODE          VARCHAR2(150)
  ,FROM_GRADE_CODE        VARCHAR2(150)
  ,REASON_ID              NUMBER
  ,HOLD_DATE              DATE
);

PROCEDURE update_change_disp_table
(
  p_update_change_disp_rec      IN         UPDATE_CHANGE_DISP_REC
, x_return_status               OUT NOCOPY VARCHAR2
, x_message_data                OUT NOCOPY VARCHAR2
) ;

PROCEDURE update_sample_comp_disp
(
  p_update_disp_rec           	IN         UPDATE_DISP_REC
, p_to_disposition		IN         VARCHAR2
, x_return_status 		OUT NOCOPY VARCHAR2
, x_message_data		OUT NOCOPY VARCHAR2
);


PROCEDURE update_lot_grade_batch
(
  p_sample_id			IN         NUMBER DEFAULT NULL
, p_composite_spec_disp_id  	IN         NUMBER DEFAULT NULL
, p_to_lot_status_id	  	IN         NUMBER
, p_from_lot_status_id	  	IN         NUMBER
, p_to_grade_code		IN         VARCHAR2
, p_from_grade_code		IN         VARCHAR2 DEFAULT NULL
, p_to_qc_status		IN         NUMBER
, p_reason_id			IN         NUMBER
, p_hold_date                   IN         DATE DEFAULT SYSDATE
, x_return_status 		OUT NOCOPY VARCHAR2
, x_message_data		OUT NOCOPY VARCHAR2
);


PROCEDURE check_for_null_and_fks_in_smpl
(
  p_sample        IN         GMD_SAMPLES%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);


PROCEDURE create_inv_txn
( p_sample        IN         GMD_SAMPLES%ROWTYPE
, p_user_name     IN         NUMBER
, x_return_status OUT NOCOPY VARCHAR2
, x_message_count OUT NOCOPY NUMBER
, x_message_data  OUT NOCOPY VARCHAR2
);


PROCEDURE create_wip_txn
( p_sample        IN         GMD_SAMPLES%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
, x_message_count OUT NOCOPY NUMBER
, x_message_data  OUT NOCOPY VARCHAR2
);


PROCEDURE post_wip_txn
( p_batch_id      IN         NUMBER
, x_return_status OUT NOCOPY VARCHAR2
);


  -- Bug 2752102: added this procedure
PROCEDURE get_max_test_method_duration
( p_spec_id       IN  NUMBER
, x_test_dur      OUT NOCOPY NUMBER
, x_test_code     OUT NOCOPY VARCHAR2
);

  -- Bug 3088216: added this procedure
PROCEDURE update_remaining_qty
( p_result_id     IN  NUMBER,
  p_sample_id     IN  NUMBER default 0,
  qty             IN  NUMBER,
  x_return_status OUT NOCOPY VARCHAR2
);

  -- Bug 4165704: added these procedures for inventory convergence
--    M. Grosser 02/28/2006: BUG 5016617 -Added supplier_name to
--               sample_display_rec.
--
TYPE sample_display_rec IS RECORD
(
         Inventory_item_id              NUMBER
        ,Organization_id                NUMBER
        ,Sample_req_cnt                 NUMBER             -- Sampling event fields
        ,Sample_taken_cnt               NUMBER
        ,Archived_taken                 NUMBER
        ,Reserved_taken                 NUMBER
        ,Sample_active_cnt              NUMBER
        ,Sample_disposition             VARCHAR2(3)
        ,Sample_disposition_desc        VARCHAR2(80)
        ,locator_type                   NUMBER             -- Subinventory fields
        ,item_number                    VARCHAR2(2000)     -- Item fields
        ,item_description               VARCHAR2(240)
        ,revision                       VARCHAR2(3)  --RLNAGARA Bug# 4880152
        ,restrict_subinventories_code   NUMBER
        ,restict_locators_code          NUMBER
        ,revision_qty_control_code      NUMBER
        ,lot_control_code               NUMBER
        ,lot_status_enabled             VARCHAR2(1)
        ,lot_number                     VARCHAR2(80)
        ,parent_lot_number              VARCHAR2(80)
        ,grade_control_flag             VARCHAR2(1)
        ,location_control_code          NUMBER
        ,primary_uom_code               VARCHAR2(3)
        ,dual_uom_control               NUMBER
        ,eng_item_flag                  VARCHAR2(1)
        ,child_lot_flag                 VARCHAR2(1)
        ,indivisible_flag               VARCHAR2(1)
        ,serial_number_control_code     NUMBER
        ,Locator                        VARCHAR2(2000)     -- Inventory fields
        ,subinventory_desc              VARCHAR2(50)
        ,restrict_locators_code         NUMBER
        ,supplier_no                    VARCHAR2(80)        -- Supplier fields
        ,supplier_name                  VARCHAR2(360)
        ,sup_operating_unit_name        VARCHAR2(240)
        ,supplier_site                  VARCHAR2(40)
        ,po_number                      VARCHAR2(80)
        ,po_line_no                     NUMBER
        ,receipt                        VARCHAR2(32)
        ,receipt_line                   NUMBER
        ,sup_restrict_locators_code     NUMBER
        ,cust_name                      VARCHAR2(360)      -- Customer fields
        ,Operating_unit_name            VARCHAR2(240)
        ,Ship_to_name                   VARCHAR2(40)
        ,Order_number                   NUMBER
        ,Order_type                     VARCHAR2(30)
        ,Order_line_no                  VARCHAR2(80)
        ,Batch_no                       VARCHAR2(32)       -- WIP fields
        ,Batch_status                   NUMBER
        ,Recipe_no                      VARCHAR2(32)
        ,Recipe_version                 NUMBER
        ,Formula_no                     VARCHAR2(32)
        ,Formula_vers                   NUMBER
        ,Formula_type                   VARCHAR2(80)
        ,Formula_line                   NUMBER
        ,Routing_no                     VARCHAR2(32)
        ,Routing_vers                   NUMBER
        ,Step_no                        NUMBER
        ,Oprn_no                        VARCHAR2(32)
        ,Oprn_vers                      NUMBER
        ,Source_locator                 VARCHAR2(2000)
        ,Source_locator_id              NUMBER
        ,Source_subinventory            VARCHAR2(10)
        ,Ss_organization_code           VARCHAR2(3)    -- Stability Study fields
        ,Ss_no                          VARCHAR2(30)
        ,Variant_no                     NUMBER
        ,Storage_organization_code      VARCHAR2(3)
        ,Storage_locator                VARCHAR2(2000)
        ,Storage_locator_id             NUMBER
        ,Storage_subinventory           VARCHAR2(10)
        ,Variant_resource               VARCHAR2(30)
        ,Variant_instance               NUMBER
        ,Time_point_name                VARCHAR2(80)
        ,Scheduled_date                 DATE
        ,Instance_number                NUMBER           -- Resource field
        ,Resources                      VARCHAR2(16)
        ,Sampler                        VARCHAR2(100)
        ,Sampler_name                   VARCHAR2(240)
        ,Creation_date                  DATE
        ,Lab_organization_code          VARCHAR2(3)     -- Lab organization code
        ,sample_no                      VARCHAR2(80)
        ,sampling_event_id              NUMBER
        ,retain_as                      VARCHAR2(3)
        ,sample_type                    VARCHAR2(2)
        ,source                         VARCHAR2(1)
        ,subinventory                   VARCHAR2(10)
        ,po_header_id                   NUMBER
        ,grade_code                     VARCHAR2(150)
	,lpn                            VARCHAR2(32)     --RLNAGARA LPN ME 7027149
);

PROCEDURE Sample_source_display  (
  p_id               IN        NUMBER
, p_type             IN        VARCHAR2
, x_display          OUT NOCOPY       sample_display_rec
, x_return_status    OUT NOCOPY       VARCHAR2);

PROCEDURE Inventory_source (
 p_locator_id        IN        NUMBER
,p_subinventory      IN        VARCHAR2
,p_organization_id   IN        NUMBER
, x_display          IN OUT NOCOPY    sample_display_rec);

PROCEDURE Supplier_source (
 p_supplier_id       IN        NUMBER
,p_po_header_id      IN        NUMBER
,p_po_line_id        IN        NUMBER
,p_receipt_id        IN        NUMBER
,p_receipt_line_id   IN        NUMBER
,p_supplier_site_id  IN        NUMBER
,p_org_id            IN        NUMBER
,p_organization_id   IN        NUMBER
,p_subinventory      IN        VARCHAR2
, x_display          IN OUT NOCOPY    sample_display_rec);

PROCEDURE Customer_source (
  p_ship_to_site_id IN NUMBER
, p_org_id          IN NUMBER
, p_order_id        IN NUMBER
, p_order_line_id   IN NUMBER
, p_cust_id         IN NUMBER
, x_display         IN OUT NOCOPY    sample_display_rec);

PROCEDURE Stability_study_source (
 p_variant_id          IN        NUMBER
,p_time_point_id       IN        NUMBER
, x_display            IN OUT NOCOPY    sample_display_rec);

PROCEDURE Physical_location_source (
 p_locator_id          IN        NUMBER
,p_subinventory        IN        VARCHAR2
,p_organization_id     IN        NUMBER
, x_display            IN OUT NOCOPY    sample_display_rec);

PROCEDURE Resource_source (
p_instance_id          IN        NUMBER
, x_display            IN OUT NOCOPY    sample_display_rec);

PROCEDURE Wip_source (
  p_batch_id          IN NUMBER
, p_step_id           IN NUMBER
, p_recipe_id         IN NUMBER
, p_formula_id        IN NUMBER
, p_formulaline_id    IN NUMBER
, p_material_detail_id IN NUMBER
, p_routing_id        IN NUMBER
, p_oprn_id           IN NUMBER
, p_inventory_item_id IN NUMBER
, p_organization_id   IN NUMBER
, x_display           IN OUT NOCOPY    sample_display_rec);

PROCEDURE Get_item_values (p_sample_display IN OUT NOCOPY sample_display_rec);

TYPE sample_source_rec IS RECORD
(
     disposition             VARCHAR2(3)
    ,sample_id               NUMBER
    ,sample_disposition_desc VARCHAR2(80)
    ,sample_source_desc      VARCHAR2(80)
) ;

PROCEDURE get_sample_spec_disposition (
        p_sample        IN  OUT NOCOPY SAMPLE_SOURCE_REC
       ,x_return_status OUT NOCOPY VARCHAR2
);


END GMD_SAMPLES_GRP;


/
