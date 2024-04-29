--------------------------------------------------------
--  DDL for Package WIP_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_TRANSACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: WIPPTXNS.pls 120.0.12010000.2 2010/03/10 09:47:59 hliew ship $ */

--  Wiptransaction record type

TYPE Wiptransaction_Rec_Type IS RECORD
(   dummy                         VARCHAR2(1)
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   action                        VARCHAR2(30)
);

TYPE Wiptransaction_Tbl_Type IS TABLE OF Wiptransaction_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Wiptransaction value record type

TYPE Wiptransaction_Val_Rec_Type IS RECORD
(   null_element NUMBER := NULL
);

TYPE Wiptransaction_Val_Tbl_Type IS TABLE OF Wiptransaction_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_WIPTRANSACTION_REC     Wiptransaction_Rec_Type;
G_MISS_WIPTRANSACTION_VAL_REC Wiptransaction_Val_Rec_Type;
G_MISS_WIPTRANSACTION_TBL     Wiptransaction_Tbl_Type;
G_MISS_WIPTRANSACTION_VAL_TBL Wiptransaction_Val_Tbl_Type;


--  Resource record type ;  also used for OSP

TYPE Res_Rec_Type IS RECORD
(   acct_period_id                NUMBER
,   activity_id                   NUMBER
,   activity_name                 VARCHAR2(10)
,   actual_resource_rate          NUMBER
,   attribute1                    VARCHAR2(150)
,   attribute10                   VARCHAR2(150)
,   attribute11                   VARCHAR2(150)
,   attribute12                   VARCHAR2(150)
,   attribute13                   VARCHAR2(150)
,   attribute14                   VARCHAR2(150)
,   attribute15                   VARCHAR2(150)
,   attribute2                    VARCHAR2(150)
,   attribute3                    VARCHAR2(150)
,   attribute4                    VARCHAR2(150)
,   attribute5                    VARCHAR2(150)
,   attribute6                    VARCHAR2(150)
,   attribute7                    VARCHAR2(150)
,   attribute8                    VARCHAR2(150)
,   attribute9                    VARCHAR2(150)
,   attribute_category            VARCHAR2(30)
,   autocharge_type               NUMBER
,   basis_type                    NUMBER
,   completion_transaction_id     NUMBER
,   created_by                    NUMBER
,   created_by_name               VARCHAR2(100)
,   creation_date                 DATE
,   currency_actual_rsc_rate      NUMBER
,   currency_code                 VARCHAR2(15)
,   currency_conversion_date      DATE
,   currency_conversion_rate      NUMBER
,   currency_conversion_type      VARCHAR2(10)
,   department_code               VARCHAR2(10)
,   department_id                 NUMBER
,   employee_id                   NUMBER
,   employee_num                  VARCHAR2(30)
,   entity_type                   NUMBER
,   group_id                      NUMBER
,   last_updated_by               NUMBER
,   last_updated_by_name          VARCHAR2(100)
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_code                     VARCHAR2(10)
,   line_id                       NUMBER
,   move_transaction_id           NUMBER
,   operation_seq_num             NUMBER
,   organization_code             VARCHAR2(3)
,   organization_id               NUMBER
,   po_header_id                  NUMBER
,   po_line_id                    NUMBER
,   primary_item_id               NUMBER
,   primary_quantity              NUMBER
,   primary_uom                   VARCHAR2(3)
,   primary_uom_class             VARCHAR2(10)
,   process_phase                 NUMBER
,   process_status                NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   project_id                    NUMBER
,   rcv_transaction_id            NUMBER
,   reason_id                     NUMBER
,   reason_name                   VARCHAR2(30)
,   receiving_account_id          NUMBER
,   reference                     VARCHAR2(240)
,   repetitive_schedule_id        NUMBER
,   request_id                    NUMBER
,   resource_code                 VARCHAR2(10)
,   resource_id                   NUMBER
,   resource_seq_num              NUMBER
,   resource_type                 NUMBER
,   source_code                   VARCHAR2(30)
,   source_line_id                NUMBER
,   standard_rate_flag            NUMBER
,   task_id                       NUMBER
,   transaction_date              DATE
,   transaction_id                NUMBER
,   transaction_quantity          NUMBER
,   transaction_type              NUMBER
,   transaction_uom               VARCHAR2(3)
,   usage_rate_or_amount          NUMBER
,   wip_entity_id                 NUMBER
,   wip_entity_name               VARCHAR2(240)
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   action                        VARCHAR2(30)
,   WIPTransaction_index          NUMBER
,   encumbrance_type_id           NUMBER  --Fix bug 9356683, for costing encumbrance project
,   encumbrance_amount            NUMBER  --Fix bug 9356683
,   encumbrance_quantity          NUMBER  --Fix bug 9356683
,   encumbrance_ccid              NUMBER  --Fix bug 9356683
);


--Possible OSP actions. These are "in addition to" or "entity specific modification of" the actions in WIP_Globals package.

G_ACT_OSP_RECEIVE                  CONSTANT VARCHAR2(50) :=  'RECEIVE';

-- the following 4 constants are the transaction followed by the parent transaction
G_ACT_OSP_RET_TO_RCV               CONSTANT VARCHAR2(50) :=  'RETURN TO RECEIVINGDELIVER';
G_ACT_OSP_RET_TO_VEND              CONSTANT VARCHAR2(50) :=  'RETURN TO VENDORDELIVER';
G_ACT_OSP_CORRECT_TO_VEND          CONSTANT VARCHAR2(50) :=  'CORRECTRETURN TO VENDOR';
G_ACT_OSP_CORRECT_TO_RCV           CONSTANT VARCHAR2(50) :=  'CORRECTRETURN TO RECEIVING';
G_ACT_OSP_CORRECT_RECEIVE          CONSTANT VARCHAR2(50) :=  'CORRECTRECEIVE';
G_ACT_OSP_DELIVER                  CONSTANT VARCHAR2(50) :=  'DELIVER';

TYPE Res_Tbl_Type IS TABLE OF Res_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Res value record type

TYPE Res_Val_Rec_Type IS RECORD
(   acct_period                   VARCHAR2(240)
,   activity                      VARCHAR2(240)
,   completion_transaction        VARCHAR2(240)
,   currency                      VARCHAR2(240)
,   department                    VARCHAR2(240)
,   employee                      VARCHAR2(240)
,   group_name                    VARCHAR2(240)
,   line                          VARCHAR2(240)
,   move_transaction              VARCHAR2(240)
,   organization                  VARCHAR2(240)
,   po_header                     VARCHAR2(240)
,   po_line                       VARCHAR2(240)
,   primary_item                  VARCHAR2(240)
,   project                       VARCHAR2(240)
,   rcv_transaction               VARCHAR2(240)
,   reason                        VARCHAR2(240)
,   receiving_account             VARCHAR2(240)
,   repetitive_schedule           VARCHAR2(240)
,   resource_name                 VARCHAR2(240)
,   source                        VARCHAR2(240)
,   source_line                   VARCHAR2(240)
,   standard_rate                 VARCHAR2(240)
,   task                          VARCHAR2(240)
,   transaction                   VARCHAR2(240)
,   wip_entity                    VARCHAR2(240)
);

TYPE Res_Val_Tbl_Type IS TABLE OF Res_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_RES_REC                Res_Rec_Type;
G_MISS_RES_VAL_REC            Res_Val_Rec_Type;
G_MISS_RES_TBL                Res_Tbl_Type;
G_MISS_RES_VAL_TBL            Res_Val_Tbl_Type;


--  Shopfloormove record type

TYPE Shopfloormove_Rec_Type IS RECORD
(   acct_period_id                NUMBER
,   attribute1                    VARCHAR2(150)
,   attribute10                   VARCHAR2(150)
,   attribute11                   VARCHAR2(150)
,   attribute12                   VARCHAR2(150)
,   attribute13                   VARCHAR2(150)
,   attribute14                   VARCHAR2(150)
,   attribute15                   VARCHAR2(150)
,   attribute2                    VARCHAR2(150)
,   attribute3                    VARCHAR2(150)
,   attribute4                    VARCHAR2(150)
,   attribute5                    VARCHAR2(150)
,   attribute6                    VARCHAR2(150)
,   attribute7                    VARCHAR2(150)
,   attribute8                    VARCHAR2(150)
,   attribute9                    VARCHAR2(150)
,   attribute_category            VARCHAR2(30)
,   created_by                    NUMBER
,   created_by_name               VARCHAR2(100)
,   creation_date                 DATE
,   entity_type                   NUMBER
,   fm_department_code            VARCHAR2(10)
,   fm_department_id              NUMBER
,   fm_intraop_step_type          NUMBER
,   fm_operation_code             VARCHAR2(4)
,   fm_operation_seq_num          NUMBER
,   group_id                      NUMBER
,   kanban_card_id                NUMBER
,   last_updated_by               NUMBER
,   last_updated_by_name          VARCHAR2(100)
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_code                     VARCHAR2(10)
,   line_id                       NUMBER
,   organization_code             VARCHAR2(3)
,   organization_id               NUMBER
,   overcpl_primary_qty           NUMBER
,   overcpl_transaction_id        NUMBER
,   overcpl_transaction_qty       NUMBER
,   primary_item_id               NUMBER
,   primary_quantity              NUMBER
,   primary_uom                   VARCHAR2(3)
,   process_phase                 NUMBER
,   process_status                NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   qa_collection_id              NUMBER
,   reason_id                     NUMBER
,   reason_name                   VARCHAR2(30)
,   reference                     VARCHAR2(240)
,   repetitive_schedule_id        NUMBER
,   request_id                    NUMBER
,   scrap_account_id              NUMBER
,   source_code                   VARCHAR2(30)
,   source_line_id                NUMBER
,   to_department_code            VARCHAR2(10)
,   to_department_id              NUMBER
,   to_intraop_step_type          NUMBER
,   to_operation_code             VARCHAR2(4)
,   to_operation_seq_num          NUMBER
,   transaction_date              DATE
,   transaction_id                NUMBER
,   transaction_quantity          NUMBER
,   transaction_type              NUMBER
,   transaction_uom               VARCHAR2(3)
,   wip_entity_id                 NUMBER
,   wip_entity_name               VARCHAR2(240)
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   action                        VARCHAR2(30)
,   WIPTransaction_index          NUMBER
);

TYPE Shopfloormove_Tbl_Type IS TABLE OF Shopfloormove_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Shopfloormove value record type

TYPE Shopfloormove_Val_Rec_Type IS RECORD
(   acct_period                   VARCHAR2(240)
,   fm_department                 VARCHAR2(240)
,   fm_operation                  VARCHAR2(240)
,   group_name                    VARCHAR2(240)
,   kanban_card                   VARCHAR2(240)
,   kanban                        VARCHAR2(240)
,   line                          VARCHAR2(240)
,   organization                  VARCHAR2(240)
,   overcompletion                VARCHAR2(240)
,   overcpl_transaction           VARCHAR2(240)
,   primary_item                  VARCHAR2(240)
,   qa_collection                 VARCHAR2(240)
,   reason                        VARCHAR2(240)
,   repetitive_schedule           VARCHAR2(240)
,   scrap_account                 VARCHAR2(240)
,   source                        VARCHAR2(240)
,   source_line                   VARCHAR2(240)
,   to_department                 VARCHAR2(240)
,   to_operation                  VARCHAR2(240)
,   transaction                   VARCHAR2(240)
,   transaction_link              VARCHAR2(240)
,   wip_entity                    VARCHAR2(240)
);

TYPE Shopfloormove_Val_Tbl_Type IS TABLE OF Shopfloormove_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_SHOPFLOORMOVE_REC      Shopfloormove_Rec_Type;
G_MISS_SHOPFLOORMOVE_VAL_REC  Shopfloormove_Val_Rec_Type;
G_MISS_SHOPFLOORMOVE_TBL      Shopfloormove_Tbl_Type;
G_MISS_SHOPFLOORMOVE_VAL_TBL  Shopfloormove_Val_Tbl_Type;

-- The following records are used for defaulting procedures
TYPE Rcv_Txn_Type Is RECORD
(
    comments                   VARCHAR2(240)
,   creation_date              DATE
,   created_by                 NUMBER
,   currency_code              VARCHAR2(15)
,   currency_conversion_date   DATE
,   currency_conversion_rate   NUMBER
,   currency_conversion_type   VARCHAR2(10)
,   item_id		       NUMBER
,   last_update_date           DATE
,   last_update_login          NUMBER
,   last_updated_by            NUMBER
,   organization_id            NUMBER
,   primary_unit_of_measure    VARCHAR2(25)
,   po_header_id               NUMBER
,   po_line_id                 NUMBER
,   po_unit_price              NUMBER
,   quantity 	               NUMBER
,   unit_of_measure	       VARCHAR2(25)
,   reason_id                  NUMBER
,   source_doc_quantity	       NUMBER
,   source_doc_unit_of_measure VARCHAR2(25)
,   transaction_date           DATE
,   wip_line_id                NUMBER
,   wip_entity_id              NUMBER
,   wip_operation_seq_num      NUMBER
,   wip_repetitive_schedule_id NUMBER
,   wip_resource_seq_num       NUMBER
);

TYPE WIP_Op_Res_Type Is RECORD
(   activity_id             NUMBER
,   autocharge_type         NUMBER
,   basis_type              NUMBER
,   resource_id             NUMBER
,   std_rate_flag           NUMBER
,   usage_rate_or_amount    NUMBER
,   uom_code                VARCHAR2(3)
);

TYPE PO_Dist_Type Is RECORD
(  project_id 		NUMBER
,  task_id 		NUMBER
,  nonrecoverable_tax	NUMBER
,  primary_quantity_ordered	NUMBER
);

TYPE BOM_Resource_Type Is RECORD
(  resource_code 	VARCHAR2(10)
,  resource_type 	NUMBER
);

TYPE OSP_Move_Details_Type IS RECORD
(
  transaction_type	NUMBER
, primary_quantity	NUMBER
, transaction_quantity	NUMBER
, fm_operation_seq_num	NUMBER
, fm_intraop_step_type	NUMBER
, fm_department_id	NUMBER
, to_operation_seq_num	NUMBER
, to_intraop_step_type	NUMBER
, to_department_id	NUMBER
, move_direction	NUMBER
);

G_MISS_RCV_TXN_REC      Rcv_Txn_Type;
G_MISS_WIP_OP_RES_REC   WIP_Op_Res_Type;
G_MISS_PO_DIST_REC      PO_Dist_Type;
G_MISS_BOM_RES_REC      BOM_Resource_Type;
G_MISS_OSP_MOVE_DET_REC OSP_Move_Details_Type;


--  Start of Comments
--  API name    Get_Transaction
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Transaction
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := NULL
,   p_return_values                 IN  VARCHAR2 := NULL
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_dummy                         IN  VARCHAR2
,   x_WIPTransaction_tbl            OUT NOCOPY Wiptransaction_Tbl_Type
,   x_WIPTransaction_val_tbl        OUT NOCOPY Wiptransaction_Val_Tbl_Type
,   x_Res_tbl                       OUT NOCOPY Res_Tbl_Type
,   x_Res_val_tbl                   OUT NOCOPY Res_Val_Tbl_Type
,   x_ShopFloorMove_tbl             OUT NOCOPY Shopfloormove_Tbl_Type
,   x_ShopFloorMove_val_tbl         OUT NOCOPY Shopfloormove_Val_Tbl_Type
);

END WIP_Transaction_PUB;

/
