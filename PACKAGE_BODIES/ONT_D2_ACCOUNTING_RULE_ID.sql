--------------------------------------------------------
--  DDL for Package Body ONT_D2_ACCOUNTING_RULE_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D2_ACCOUNTING_RULE_ID" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_ACCOUNTING_RULE_ID
--  
--  DESCRIPTION
--  
--      Body of package ONT_D2_ACCOUNTING_RULE_ID
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D2_ACCOUNTING_RULE_ID';
 
 
FUNCTION Get_Default_Value(p_line_rec IN  OE_AK_ORDER_LINES_V%ROWTYPE 
  ) RETURN NUMBER IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    l_rule_id := 118;
    IF ONT_AGREEMENT_Def_Util.Sync_AGREEMENT_Cache
    (p_AGREEMENT_ID => p_line_rec.AGREEMENT_ID
    ) = 1 THEN
    l_return_value := ONT_AGREEMENT_Def_Util.g_cached_record.ACCOUNTING_RULE_ID;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 120;
    IF ONT_LINE_TYPE_Def_Util.Sync_LINE_TYPE_Cache
    (p_LINE_TYPE_ID => p_line_rec.LINE_TYPE_ID
    ) = 1 THEN
    l_return_value := ONT_LINE_TYPE_Def_Util.g_cached_record.ACCOUNTING_RULE_ID;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 79;
    IF ONT_ITEM_Def_Util.Sync_ITEM_Cache
    (p_INVENTORY_ITEM_ID => p_line_rec.INVENTORY_ITEM_ID
    ,p_ORGANIZATION_ID => REPLACE(nvl(p_line_rec.SHIP_FROM_ORG_ID,FND_API.G_MISS_NUM),FND_API.G_MISS_NUM,OE_SYS_Parameters.Value('MASTER_ORGANIZATION_ID'))
    ) = 1 THEN
    l_return_value := ONT_ITEM_Def_Util.g_cached_record.ACCOUNTING_RULE_ID;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 67;
    IF ONT_HEADER_Def_Util.Sync_HEADER_Cache
    (p_HEADER_ID => p_line_rec.HEADER_ID
    ) = 1 THEN
    l_return_value := ONT_HEADER_Def_Util.g_cached_record.ACCOUNTING_RULE_ID;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'ACCOUNTING_RULE_ID'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D2_ACCOUNTING_RULE_ID;

/
