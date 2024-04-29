--------------------------------------------------------
--  DDL for Package Body ONT_D2_SHIPPING_METHOD_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D2_SHIPPING_METHOD_CODE" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_SHIPPING_METHOD_CODE
--  
--  DESCRIPTION
--  
--      Body of package ONT_D2_SHIPPING_METHOD_CODE
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D2_SHIPPING_METHOD_CODE';
 
 
FUNCTION Get_Default_Value(p_line_rec IN  OE_AK_ORDER_LINES_V%ROWTYPE 
  ) RETURN VARCHAR2 IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    l_rule_id := 517;
    IF ONT_SHIP_TO_ORG_Def_Util.Sync_SHIP_TO_ORG_Cache
    (p_ORGANIZATION_ID => p_line_rec.SHIP_TO_ORG_ID
    ) = 1 THEN
    l_return_value := ONT_SHIP_TO_ORG_Def_Util.g_cached_record.SHIPPING_METHOD_CODE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 518;
    IF ONT_INV_ORG_Def_Util.Sync_INV_ORG_Cache
    (p_ORGANIZATION_ID => p_line_rec.INVOICE_TO_ORG_ID
    ) = 1 THEN
    l_return_value := ONT_INV_ORG_Def_Util.g_cached_record.SHIPPING_METHOD_CODE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 519;
    IF ONT_SOLD_TO_ORG_Def_Util.Sync_SOLD_TO_ORG_Cache
    (p_ORGANIZATION_ID => p_line_rec.SOLD_TO_ORG_ID
    ,p_ORG_ID => p_line_rec.ORG_ID
    ) = 1 THEN
    l_return_value := ONT_SOLD_TO_ORG_Def_Util.g_cached_record.SHIPPING_METHOD_CODE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 520;
    IF ONT_LINE_TYPE_Def_Util.Sync_LINE_TYPE_Cache
    (p_LINE_TYPE_ID => p_line_rec.LINE_TYPE_ID
    ) = 1 THEN
    l_return_value := ONT_LINE_TYPE_Def_Util.g_cached_record.SHIPPING_METHOD_CODE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 521;
    IF ONT_PRICE_LIST_Def_Util.Sync_PRICE_LIST_Cache
    (p_PRICE_LIST_ID => p_line_rec.PRICE_LIST_ID
    ) = 1 THEN
    l_return_value := ONT_PRICE_LIST_Def_Util.g_cached_record.SHIP_METHOD_CODE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 522;
    IF ONT_HEADER_Def_Util.Sync_HEADER_Cache
    (p_HEADER_ID => p_line_rec.HEADER_ID
    ) = 1 THEN
    l_return_value := ONT_HEADER_Def_Util.g_cached_record.SHIPPING_METHOD_CODE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'SHIPPING_METHOD_CODE'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D2_SHIPPING_METHOD_CODE;

/
