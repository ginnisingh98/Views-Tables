--------------------------------------------------------
--  DDL for Package ONT_D1025_CREDIT_CARD_EXPIRATI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_D1025_CREDIT_CARD_EXPIRATI" AUTHID CURRENT_USER AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1025_CREDIT_CARD_EXPIRATI
--  
--  DESCRIPTION
--  
--      Spec of package ONT_D1025_CREDIT_CARD_EXPIRATI
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
  FUNCTION Get_Default_Value(p_line_payment_rec IN OE_AK_LINE_PAYMENTS_V %ROWTYPE 
  ) RETURN DATE;
 
END ONT_D1025_CREDIT_CARD_EXPIRATI;

/
