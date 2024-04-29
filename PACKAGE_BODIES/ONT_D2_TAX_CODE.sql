--------------------------------------------------------
--  DDL for Package Body ONT_D2_TAX_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D2_TAX_CODE" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_TAX_CODE
--  
--  DESCRIPTION
--  
--      Body of package ONT_D2_TAX_CODE
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D2_TAX_CODE';
 
 
FUNCTION Get_Default_Value(p_line_rec IN  OE_AK_ORDER_LINES_V%ROWTYPE 
  ) RETURN VARCHAR2 IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    l_rule_id := 124;
    l_return_value := OE_DEFAULT_PVT.GET_TAX_CODE
                       (p_database_object_name => null
                       ,p_attribute_code => null);
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'TAX_CODE'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D2_TAX_CODE;

/
