--------------------------------------------------------
--  DDL for Package GML_MLT_CNTR_RCPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_MLT_CNTR_RCPT" AUTHID CURRENT_USER AS
/* $Header: GMLMTCRS.pls 115.1 2003/08/11 19:02:35 pbamb noship $*/

 /*+========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMLMTCRS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GML_MLT_CNTR_RCPT                                                     |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package procedure is use to create new lots depending on the     |
 |    parameters passed and returns the new lots in the plsql table back to |
 |    RCVGMLCR.pld which then populates the LOT ENTRY screen with all the   |
 |    lots.
 |                                                                          |
 | CONTENTS                                                                 |
 |    Create_Lots                                                           |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Preetam Bamb 07/28/2003                                     |
 |                                                                          |
 +==========================================================================+
  Body end of comments*/

TYPE lotrec IS RECORD (
      lot_id         NUMBER,
      lot_no         VARCHAR2(32),
      sublot_no      VARCHAR2(32),
      expire_date    DATE);

TYPE lot_table IS TABLE OF lotrec
 index by BINARY_INTEGER;


FUNCTION  Create_Lots
( p_item_id          IN NUMBER
, p_lot_no           IN VARCHAR2
, p_no_of_lots       IN NUMBER
, p_no_of_sublots    IN NUMBER
, p_expire_date      IN DATE
, p_lot_spec_conv    IN VARCHAR2
, p_primary_uom      IN VARCHAR2
, p_primary_qty      IN VARCHAR2
, p_secondary_uom    IN VARCHAR2
, p_secondary_qty    IN VARCHAR2
, p_shipvend_id	     IN NUMBER
, p_vendor_lot_no    IN VARCHAR2
, x_lot_table        IN OUT NOCOPY lot_table
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;

--Function used to create a warapper to the qty_rec_typ to use for
--GMI_MOVE_DIFF_STAT profile option enhancements for value 2
FUNCTION GMIGAPI_QTY_FORMAT RETURN GMIGAPI.qty_rec_typ;

END GML_MLT_CNTR_RCPT;

 

/
