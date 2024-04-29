--------------------------------------------------------
--  DDL for Package Body ONT_D2_ACCOUNTING_RULE_DURA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D2_ACCOUNTING_RULE_DURA" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_ACCOUNTING_RULE_DURA
--  
--  DESCRIPTION
--  
--      Body of package ONT_D2_ACCOUNTING_RULE_DURA
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D2_ACCOUNTING_RULE_DURA';
 
 
FUNCTION Get_Default_Value(p_line_rec IN  OE_AK_ORDER_LINES_V%ROWTYPE 
  ) RETURN NUMBER IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    IF (p_line_rec.LINE_CATEGORY_CODE = 'ORDER'
        ) THEN
    l_rule_id := 495;
    l_return_value := OE_DEFAULT_PVT.Get_Accounting_Rule_Duration
                       (p_database_object_name => null
                       ,p_attribute_code => null);
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'ACCOUNTING_RULE_DURATION'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D2_ACCOUNTING_RULE_DURA;

/
