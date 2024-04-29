--------------------------------------------------------
--  DDL for Package GMI_OM_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_OM_UTILITIES_PKG" AUTHID CURRENT_USER AS
/*  $Header: GMIUTOMS.pls 120.0 2005/05/25 15:49:32 appldev noship $
 ===========================================================================
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMIUTOMS.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Spec of package GMI_Move_order_line_Util                           |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 | 17-NOV-04 parkumar Added Functionality for BackOrder and Delete         |
 |                    Allocations for a Move Order Line                    |
 |             - Delete_Alloc_BackOrder_MO_Line                            |
 ===========================================================================


*/


FUNCTION  Delete_Alloc_BackOrder_MO_Line(
         p_txn_source_line_id        IN     NUMBER,
         p_line_id                   IN     NUMBER,
         p_mode                      IN     VARCHAR2)
 RETURN  BOOLEAN;   -- Bug 3874270

END GMI_OM_UTILITIES_PKG;

 

/
