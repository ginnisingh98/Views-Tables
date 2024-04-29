--------------------------------------------------------
--  DDL for Package ONT_D2_SHIP_TOLERANCE_ABOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_D2_SHIP_TOLERANCE_ABOVE" AUTHID CURRENT_USER AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_SHIP_TOLERANCE_ABOVE
--  
--  DESCRIPTION
--  
--      Spec of package ONT_D2_SHIP_TOLERANCE_ABOVE
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
  FUNCTION Get_Default_Value(p_line_rec IN OE_AK_ORDER_LINES_V %ROWTYPE 
  ) RETURN NUMBER;
 
END ONT_D2_SHIP_TOLERANCE_ABOVE;

/
