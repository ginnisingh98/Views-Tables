--------------------------------------------------------
--  DDL for Package GMI_AUTO_ALLOCATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_AUTO_ALLOCATE_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMIPALLS.pls 120.0 2005/05/25 15:49:39 appldev noship $
 +=========================================================================+
 |                Copyright (c) 1998 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIPALLS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures controling auto-allocation  |
 |     of OPM inventory against order/shipment lines.                      |
 |                                                                         |
 | HISTORY                                                                 |
 |     15-DEC-1999  K.Y.Hunt                                               |
 +=========================================================================+
  API Name  : GMI_AUTO_ALLOCATE_PUB
  Type      : Public
  Function  : This package contains public procedures controling auto-
              allocation of OPM inventory against order/shipment lines.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes

  API specific parameters to be presented in SQL RECORD format
*/


TYPE gmi_allocation_rec is RECORD
( doc_id            IC_TRAN_PND.DOC_ID%TYPE
, line_id           IC_TRAN_PND.LINE_ID%TYPE
, doc_line          IC_TRAN_PND.DOC_LINE%TYPE
, line_detail_id    IC_TRAN_PND.LINE_DETAIL_ID%TYPE
, item_no           IC_ITEM_MST.ITEM_NO%TYPE
, whse_code         IC_WHSE_MST.WHSE_CODE%TYPE
, co_code           OP_CUST_MST.CO_CODE%TYPE
, cust_no           OP_CUST_MST.CUST_NO%TYPE
, prefqc_grade      OP_ORDR_DTL.QC_GRADE_WANTED%TYPE
, order_qty1        OP_ORDR_DTL.ORDER_QTY1%TYPE
, order_qty2        OP_ORDR_DTL.ORDER_QTY2%TYPE
, order_um1         OP_ORDR_DTL.ORDER_UM1%TYPE
, order_um2         OP_ORDR_DTL.ORDER_UM2%TYPE
, ship_to_org_id    oe_order_lines_all.SHIP_TO_ORG_ID%TYPE
, of_cust_id        oe_order_lines_all.sold_to_org_id%TYPE
, org_id            oe_order_lines_all.org_id%TYPE
, trans_date        IC_TRAN_PND.TRANS_DATE%TYPE
, user_id           FND_USER.USER_ID%TYPE
, user_name         FND_USER.USER_NAME%TYPE
);



PROCEDURE ALLOCATE_INVENTORY
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_allocation_rec     IN  gmi_allocation_rec
, x_reservation_id     OUT NOCOPY NUMBER
, x_allocated_qty1     OUT NOCOPY NUMBER
, x_allocated_qty2     OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);


END GMI_AUTO_ALLOCATE_PUB;

 

/
