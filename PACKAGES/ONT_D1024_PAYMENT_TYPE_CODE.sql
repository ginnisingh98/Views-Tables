--------------------------------------------------------
--  DDL for Package ONT_D1024_PAYMENT_TYPE_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_D1024_PAYMENT_TYPE_CODE" AUTHID CURRENT_USER AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1024_PAYMENT_TYPE_CODE
--  
--  DESCRIPTION
--  
--      Spec of package ONT_D1024_PAYMENT_TYPE_CODE
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
  FUNCTION Get_Default_Value(p_header_payment_rec IN OE_AK_HEADER_PAYMENTS_V %ROWTYPE 
  ) RETURN VARCHAR2;
 
END ONT_D1024_PAYMENT_TYPE_CODE;

/
