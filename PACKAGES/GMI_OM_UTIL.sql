--------------------------------------------------------
--  DDL for Package GMI_OM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_OM_UTIL" AUTHID CURRENT_USER AS
/*  $Header: GMIOMUTS.pls 115.2 2003/06/20 18:34:44 pkanetka noship $ */
/*
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIOMUTS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains generic utilities relating to OPM and OM.     |
 |                                                                         |
 |                                                                         |
 +=========================================================================+
*/

PROCEDURE GMI_GET_RMA_LOTS_QTY
   ( p_original_line_rec                  IN  OE_Order_PUB.Line_Rec_Type
   , p_reference_line_rec                 IN  OE_Order_PUB.Line_Rec_Type
   , p_x_lot_serial_tbl                   IN  OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
   , x_return_status                      OUT NOCOPY VARCHAR2
   );

FUNCTION GMI_GET_SECONDARY_QTY
   (
      p_delivery_detail_id  IN NUMBER,
      p_primary_quantity   IN NUMBER
   ) RETURN NUMBER;

END GMI_OM_UTIL;

 

/
