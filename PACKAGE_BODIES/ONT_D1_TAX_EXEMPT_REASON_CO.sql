--------------------------------------------------------
--  DDL for Package Body ONT_D1_TAX_EXEMPT_REASON_CO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D1_TAX_EXEMPT_REASON_CO" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1_TAX_EXEMPT_REASON_CO
--  
--  DESCRIPTION
--  
--      Body of package ONT_D1_TAX_EXEMPT_REASON_CO
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D1_TAX_EXEMPT_REASON_CO';
 
 
FUNCTION Get_Default_Value(p_header_rec IN  OE_AK_ORDER_HEADERS_V%ROWTYPE 
  ) RETURN VARCHAR2 IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    NULL;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'TAX_EXEMPT_REASON_CODE'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D1_TAX_EXEMPT_REASON_CO;

/
