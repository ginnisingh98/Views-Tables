--------------------------------------------------------
--  DDL for Package ONT_D1_ORDERED_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_D1_ORDERED_DATE" AUTHID CURRENT_USER AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1_ORDERED_DATE
--  
--  DESCRIPTION
--  
--      Spec of package ONT_D1_ORDERED_DATE
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
  FUNCTION Get_Default_Value(p_header_rec IN OE_AK_ORDER_HEADERS_V %ROWTYPE 
  ) RETURN DATE;
 
END ONT_D1_ORDERED_DATE;

/
