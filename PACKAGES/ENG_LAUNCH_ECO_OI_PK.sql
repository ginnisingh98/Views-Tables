--------------------------------------------------------
--  DDL for Package ENG_LAUNCH_ECO_OI_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_LAUNCH_ECO_OI_PK" AUTHID CURRENT_USER AS
/*  $Header: ENCOINS.pls 120.1.12010000.3 2010/02/12 08:56:20 rvalsan ship $ */

G_ROWS_TO_COMMIT	        CONSTANT NUMBER := 500;
G_SUCCESS                       CONSTANT NUMBER := 0;
G_WARNING                       CONSTANT NUMBER := 1;
G_ERROR                         CONSTANT NUMBER := 2;
G_CREATE			CONSTANT VARCHAR2(10) := 'CREATE';
G_UPDATE			CONSTANT VARCHAR2(10) := 'UPDATE';
G_DELETE			CONSTANT VARCHAR2(10) := 'DELETE';
G_CANCEL			CONSTANT VARCHAR2(10) := 'CANCEL';

-- Process Flag Values
G_PF_PENDING        CONSTANT NUMBER := 1;
G_PF_ERROR          CONSTANT NUMBER := 3;
G_PF_SUCCESS        CONSTANT NUMBER := 7;

-- PLM Changemanagement Upload Revised Items
G_PLM_OR_ERP  	    VARCHAR2(100) := 'ERP';

--  Eco record type

TYPE Encoin_Eco_Rec_Type IS RECORD
(   change_notice                 VARCHAR2(10)   --:= NULL --FND_API.G_MISS_NUM
,   organization_code             VARCHAR2(3)    --:= NULL --FND_API.G_MISS_CHAR
,   request_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_application_id        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_update_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   approval_status_type          NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   approval_date                 DATE           --:= NULL --FND_API.G_MISS_DATE
,   approval_list_id              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   change_order_type_id          NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   responsible_org_id            NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   approval_request_date         DATE           --:= NULL --FND_API.G_MISS_DATE
,   last_update_date              DATE           --:= NULL --FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   creation_date                 DATE           --:= NULL --FND_API.G_MISS_DATE
,   created_by                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   last_update_login             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   description                   VARCHAR2(2000) --:= NULL --FND_API.G_MISS_CHAR
,   status_type                   NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   initiation_date               DATE           --:= NULL --FND_API.G_MISS_DATE
,   implementation_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   cancellation_date             DATE           --:= NULL --FND_API.G_MISS_DATE
,   cancellation_comments         VARCHAR2(240)  --:= NULL --FND_API.G_MISS_CHAR
,   priority_code                 VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   reason_code                   VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   estimated_eng_cost            NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   estimated_mfg_cost            NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   requestor_id                  NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   attribute_category            VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  --:= NULL FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  --:= NULL FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  --:= NULL  --FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   process_flag                  NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   transaction_id                NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   approval_list_name            VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   change_order_type             VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   responsible_org_code          VARCHAR2(3)    --:= NULL --FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_changes_ifce_key	      VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
);

TYPE Encoin_Eco_Tbl_Type IS TABLE OF Encoin_Eco_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Eco_Revision record type

TYPE Encoin_Eco_Revision_Rec_Type IS RECORD
(   attribute11                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_update_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   request_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   revision_id                   NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   change_notice                 VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   organization_id               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   rev                           VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   last_update_date              DATE           --:= NULL --FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   creation_date                 DATE           --:= NULL --FND_API.G_MISS_DATE
,   created_by                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   last_update_login             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   comments                      VARCHAR2(240)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute_category            VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   new_revision                  VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   organization_code		      VARCHAR2(3)	 --:= NULL --FND_API.G_MISS_CHAR
,   process_flag                  NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   transaction_id                NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_changes_ifce_key          VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_eco_revisions_ifce_key	  VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
);

TYPE Encoin_Eco_Revision_Tbl_Type IS TABLE OF Encoin_Eco_Revision_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Revised_Item record type

TYPE Encoin_Revised_Item_Rec_Type IS RECORD
(
/*   using_assembly_id             NUMBER         := NULL --FND_API.G_MISS_NUM
,*/
    change_notice                 VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   organization_id               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   revised_item_id               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   last_update_date              DATE           --:= NULL --FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   creation_date                 DATE           --:= NULL --FND_API.G_MISS_DATE
,   created_by                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   last_update_login             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   implementation_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   cancellation_date             DATE           --:= NULL --FND_API.G_MISS_DATE
,   cancel_comments               VARCHAR2(240)  --:= NULL --FND_API.G_MISS_CHAR
,   disposition_type              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   new_item_revision             VARCHAR2(3)    --:= NULL --FND_API.G_MISS_CHAR
,   early_schedule_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   attribute_category            VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   status_type                   NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   scheduled_date                DATE           --:= NULL --FND_API.G_MISS_DATE
,   bill_sequence_id              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   mrp_active                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   request_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_application_id        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_update_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   update_wip                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   use_up                        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   use_up_item_id                NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   revised_item_sequence_id      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   use_up_plan_name              VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   descriptive_text              VARCHAR2(240)  --:= NULL --FND_API.G_MISS_CHAR
,   auto_implement_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   attribute1                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   requestor_id                  NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   comments                      VARCHAR2(240)  --:= NULL --FND_API.G_MISS_CHAR
,   process_flag                  NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   transaction_id                NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   organization_code             VARCHAR2(3)    --:= NULL --FND_API.G_MISS_CHAR
,   revised_item_number		      VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   new_rtg_revision		      VARCHAR2(3)    --:= NULL --FND_API.G_MISS_CHAR
,   use_up_item_number		      VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   alternate_bom_designator	  VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_changes_ifce_key          VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_revised_items_ifce_key    VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
--11.5.10
, parent_revised_item_name          VARCHAR2(240)
, parent_alternate_name             VARCHAR2(240)
, updated_item_revision		    VARCHAR2(3)		-- Bug 3432944
, New_scheduled_date		    DATE		-- Bug 3432944
, From_Item_Revision                VARCHAR2(3)         -- 11.5.10E
, New_Revision_Label                VARCHAR2(80)
, New_Revised_Item_Rev_Desc         VARCHAR2(240)
, New_Revision_Reason               VARCHAR2(80)
--, basis_type        NUMBER         --:= NULL             --ENH
,   from_end_item_unit_number     VARCHAR2(30) /*Bug 6377841*/
);

TYPE Encoin_Revised_Item_Tbl_Type IS TABLE OF Encoin_Revised_Item_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Rev_Component record type

TYPE Encoin_Rev_Component_Rec_Type IS RECORD
(   supply_subinventory           VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   op_lead_time_percent          NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   revised_item_sequence_id      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   cost_factor                   NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   required_for_revenue          NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   high_quantity                 NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   component_sequence_id         NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_application_id        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   wip_supply_type               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   supply_locator_id             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   bom_item_type                 NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   operation_seq_num             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   component_item_id             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   last_update_date              DATE           --:= NULL --FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   creation_date                 DATE           --:= NULL --FND_API.G_MISS_DATE
,   created_by                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   last_update_login             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   item_num                      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   component_quantity            NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   component_yield_factor        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   component_remarks             VARCHAR2(240)  --:= NULL --FND_API.G_MISS_CHAR
,   revised_item_number           VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   effectivity_date              DATE           --:= NULL --FND_API.G_MISS_DATE
,   change_notice                 VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   implementation_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   disable_date                  DATE           --:= NULL --FND_API.G_MISS_DATE
,   attribute_category            VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   planning_factor               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   quantity_related              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   so_basis                      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   optional                      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   mutually_exclusive_opt        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   include_in_cost_rollup        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   check_atp                     NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   shipping_allowed              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   required_to_ship              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   include_on_ship_docs          NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   include_on_bill_docs          NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   low_quantity                  NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   acd_type                      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   old_component_sequence_id     NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   bill_sequence_id              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   request_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_update_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   pick_components               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   assembly_type                 NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   interface_entity_type         VARCHAR2(4)    --:= NULL --FND_API.G_MISS_CHAR
,   reference_designator          VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   new_effectivity_date          DATE           --:= NULL --FND_API.G_MISS_DATE
,   old_effectivity_date          DATE           --:= NULL --FND_API.G_MISS_DATE
,   substitute_comp_id            NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   new_operation_seq_num         NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   old_operation_seq_num         NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   substitute_comp_number        VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   organization_code		      VARCHAR2(3)    --:= NULL --FND_API.G_MISS_CHAR
,   assembly_item_number	      VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   component_item_number         VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   location_name		          VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   organization_id		          NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   assembly_item_id 		      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   alternate_bom_designator      VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   process_flag                  NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   transaction_id                NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_changes_ifce_key          VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_revised_items_ifce_key    VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   bom_inventory_comps_ifce_key  VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   revised_item_tbl_index        NUMBER         --:= NULL --FND_API.G_MISS_NUM
-- Bug 3396529
,   New_revised_Item_Revision     VARCHAR2(3)
,   basis_type        NUMBER         --:= NULL             --ENH
,   from_end_item_unit_number     VARCHAR2(30)   /*Bug 6377841*/
,   to_end_item_unit_number       VARCHAR2(30)   /*Bug 6377841*/
/*,   old_from_end_item_unit_number       VARCHAR2(30)  BUG 9374069 revert 8414408*/
);

TYPE Encoin_Rev_Component_Tbl_Type IS TABLE OF Encoin_Rev_Component_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Ref_Designator record type

TYPE Encoin_Ref_Designator_Rec_Type IS RECORD
(   ref_designator                VARCHAR2(15)   --:= NULL --FND_API.G_MISS_CHAR
,   last_update_date              DATE           --:= NULL --FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   creation_date                 DATE           --:= NULL --FND_API.G_MISS_DATE
,   created_by                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   last_update_login             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   ref_designator_comment        VARCHAR2(240)  --:= NULL --FND_API.G_MISS_CHAR
,   change_notice                 VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   component_sequence_id         NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   acd_type                      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   request_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_application_id        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_update_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   attribute_category            VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   new_designator                VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   process_flag                  NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   transaction_id                NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   assembly_item_number          VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   component_item_number         VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   organization_code             VARCHAR2(3)    --:= NULL --FND_API.G_MISS_CHAR
,   organization_id               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   assembly_item_id              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   alternate_bom_designator      VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   component_item_id             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   bill_sequence_id              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   operation_seq_num             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   effectivity_date              DATE           --:= NULL --FND_API.G_MISS_DATE
,   interface_entity_type         VARCHAR2(4)    --:= NULL --FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_changes_ifce_key          VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_revised_items_ifce_key    VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   bom_inventory_comps_ifce_key  VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   bom_ref_desgs_ifce_key	      VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   revised_item_tbl_index        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   revised_comp_tbl_index        NUMBER         --:= NULL --FND_API.G_MISS_NUM
-- Bug 3396529
,   New_revised_Item_Revision     VARCHAR2(3)

);

TYPE Encoin_Ref_Designator_Tbl_Type IS TABLE OF Encoin_Ref_Designator_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Sub_Component record type

TYPE Encoin_Sub_Component_Rec_Type IS RECORD
(   substitute_component_id       NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   last_update_date              DATE           --:= NULL --FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   creation_date                 DATE           --:= NULL --FND_API.G_MISS_DATE
,   created_by                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   last_update_login             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   substitute_item_quantity      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   component_sequence_id         NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   acd_type                      NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   change_notice                 VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   request_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_application_id        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   program_update_date           DATE           --:= NULL --FND_API.G_MISS_DATE
,   attribute_category            VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   program_id                    NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   attribute3                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  --:= NULL --FND_API.G_MISS_CHAR
,   new_sub_comp_id               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   process_flag                  NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   transaction_id                NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   new_sub_comp_number		      VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   assembly_item_number          VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   component_item_number         VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   substitute_comp_number	      VARCHAR2(81)   --:= NULL --FND_API.G_MISS_CHAR
,   organization_code             VARCHAR2(3)    --:= NULL --FND_API.G_MISS_CHAR
,   organization_id               NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   assembly_item_id              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   alternate_bom_designator      VARCHAR2(10)   --:= NULL --FND_API.G_MISS_CHAR
,   component_item_id             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   bill_sequence_id              NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   operation_seq_num             NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   effectivity_date              DATE           --:= NULL --FND_API.G_MISS_DATE
,   interface_entity_type         VARCHAR2(4)    --:= NULL --FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    --:= NULL --FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_changes_ifce_key          VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   eng_revised_items_ifce_key    VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   bom_inventory_comps_ifce_key  VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   bom_sub_comps_ifce_key	      VARCHAR2(30)   --:= NULL --FND_API.G_MISS_CHAR
,   revised_item_tbl_index        NUMBER         --:= NULL --FND_API.G_MISS_NUM
,   revised_comp_tbl_index        NUMBER         --:= NULL --FND_API.G_MISS_NUM
-- Bug 3396529
,   New_revised_Item_Revision     VARCHAR2(3)

);

TYPE Encoin_Sub_Component_Tbl_Type IS TABLE OF Encoin_Sub_Component_Rec_Type
    INDEX BY BINARY_INTEGER;

PROCEDURE Eng_Launch_Import (
    ERRBUF          OUT NOCOPY VARCHAR2,
    RETCODE         OUT NOCOPY NUMBER,
    p_org_id		NUMBER,
    p_all_org		NUMBER		:= 1,
    p_del_rec_flag	NUMBER		:= 1);

PROCEDURE Eng_Launch_RevisedItems_Import (
    ERRBUF          OUT NOCOPY VARCHAR2,
    RETCODE         OUT NOCOPY NUMBER,
    p_org_id		NUMBER,
    p_all_org		NUMBER		:= 1,
    p_del_rec_flag	NUMBER		:= 1);

END ENG_LAUNCH_ECO_OI_PK;

/
