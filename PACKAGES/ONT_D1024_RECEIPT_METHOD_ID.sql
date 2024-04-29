--------------------------------------------------------
--  DDL for Package ONT_D1024_RECEIPT_METHOD_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_D1024_RECEIPT_METHOD_ID" AUTHID CURRENT_USER AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1024_RECEIPT_METHOD_ID
--  
--  DESCRIPTION
--  
--      Spec of package ONT_D1024_RECEIPT_METHOD_ID
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
  FUNCTION Get_Default_Value(p_header_payment_rec IN OE_AK_HEADER_PAYMENTS_V %ROWTYPE 
  ) RETURN NUMBER;
 
END ONT_D1024_RECEIPT_METHOD_ID;

/
