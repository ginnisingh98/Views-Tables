--------------------------------------------------------
--  DDL for Package GMI_MOVE_ORDER_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_MOVE_ORDER_GLOBAL" AUTHID CURRENT_USER AS
/*  $Header: GMIGMOVS.pls 120.0 2005/05/25 15:49:54 appldev noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIGMOVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains All public record definitions for             |
 |     Process_Move_Order_Header                                           |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     02-MAY-2000  hverddin        Created                                |
 |   			                         			   |
 |     HW 09/2002      added ship_set_id BUG#:2296620                      |
 +=========================================================================+
  API Name  : GMI_Move_Order_Global
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0



  Record types for move order header and move order lines

   Trohdr record type
   Record type to hold a move order header record
*/

-- HW BUG#:2643440 - Removed G_MISS_XXX from MO_HDR_Rec
TYPE MO_HDR_Rec IS RECORD
(   attribute1                    VARCHAR2(150)
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
,   creation_date                 DATE
,   date_required                 DATE
,   description                   VARCHAR2(240)
,   from_subinventory_code        VARCHAR2(10)
,   header_id                     NUMBER
,   header_status                 NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   organization_id               NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   request_id                    NUMBER
,   request_number                VARCHAR2(30)
,   status_date                   DATE
,   to_account_id                 NUMBER
,   to_subinventory_code          VARCHAR2(10)
,   move_order_type	          NUMBER
,   transaction_type_id		  NUMBER
,   grouping_rule_id		  NUMBER
,   ship_to_location_id           NUMBER
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
);


TYPE MO_HDR_TBL IS TABLE OF MO_HDR_Rec
    INDEX BY BINARY_INTEGER;

TYPE MO_LINE_Rec IS RECORD
(   attribute1                    VARCHAR2(150)
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
,   creation_date                 DATE
,   date_required                 DATE
,   from_locator_id               NUMBER
,   from_subinventory_code        VARCHAR2(10)
,   from_subinventory_id          NUMBER
,   header_id                     NUMBER
,   inventory_item_id             NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   line_number                   NUMBER
,   line_status                   NUMBER
,   organization_id               NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   quantity                      NUMBER
,   quantity_delivered            NUMBER
,   quantity_detailed             NUMBER
,   reason_id                     NUMBER
,   reference                     VARCHAR2(240)
,   reference_id                  NUMBER
,   reference_type_code           NUMBER
,   request_id                    NUMBER
,   status_date                   DATE
,   to_account_id                 NUMBER
,   to_locator_id                 NUMBER
,   to_subinventory_code          VARCHAR2(10)
,   to_subinventory_id            NUMBER
,   transaction_header_id         NUMBER
,   transaction_type_id		  NUMBER
,   txn_source_id		  NUMBER
,   txn_source_line_id		  NUMBER
,   txn_source_line_detail_id	  NUMBER
,   transaction_source_type_id	  NUMBER
,   primary_quantity		  NUMBER
,   to_organization_id		  NUMBER
,   pick_strategy_id		  NUMBER
,   put_away_strategy_id	  NUMBER
,   uom_code                      VARCHAR2(3)
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   secondary_quantity            NUMBER
,   secondary_quantity_delivered  NUMBER
,   secondary_quantity_detailed   NUMBER
,   lot_no                        VARCHAR2(32)
,   sublot_no                     VARCHAR2(32)
,   qc_grade                      VARCHAR2(4)
,   secondary_uom_code            VARCHAR2(4)
,   unit_number                 VARCHAR2(30)
,   grouping_rule_id		  NUMBER
,   request_number                VARCHAR2(30)
,   move_order_type	          NUMBER
-- HW added ship_set_id BUG#:2296620
,   ship_set_id			NUMBER :=NULL
);

TYPE MO_LINE_Tbl IS TABLE OF MO_LINE_Rec
    INDEX BY BINARY_INTEGER;


TYPE MO_LINE_TXN_REC is RECORD
( trans_id       IC_TRAN_PND.TRANS_ID%TYPE
 ,trans_qty      IC_TRAN_PND.TRANS_QTY%TYPE
 ,trans_qty2     IC_TRAN_PND.TRANS_QTY2%TYPE
 ,qc_grade       IC_TRAN_PND.QC_GRADE%TYPE
 ,lot_no         IC_LOTS_MST.LOT_NO%TYPE
 ,sublot_no      IC_LOTS_MST.SUBLOT_NO%TYPE
 ,locator_id     IC_LOCT_MST.INVENTORY_LOCATION_ID%TYPE
);

END GMI_Move_Order_Global;

 

/
