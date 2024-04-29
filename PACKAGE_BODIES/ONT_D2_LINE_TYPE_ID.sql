--------------------------------------------------------
--  DDL for Package Body ONT_D2_LINE_TYPE_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D2_LINE_TYPE_ID" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_LINE_TYPE_ID
--  
--  DESCRIPTION
--  
--      Body of package ONT_D2_LINE_TYPE_ID
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D2_LINE_TYPE_ID';
 
 
FUNCTION Get_Default_Value(p_line_rec IN  OE_AK_ORDER_LINES_V%ROWTYPE 
  ) RETURN NUMBER IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    IF (p_line_rec.LINE_CATEGORY_CODE = 'RETURN'
        ) THEN
    l_rule_id := 94;
    IF ONT_HEADER_Def_Util.Sync_HEADER_Cache
    (p_HEADER_ID => p_line_rec.HEADER_ID
    ) = 1 THEN
    l_return_value := ONT_HEADER_Def_Util.g_cached_record.DEFAULT_INBOUND_LINE_TYPE_ID;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
  END IF;
 
    IF (p_line_rec.LINE_CATEGORY_CODE = 'ORDER'
        ) THEN
    l_rule_id := 95;
    IF ONT_HEADER_Def_Util.Sync_HEADER_Cache
    (p_HEADER_ID => p_line_rec.HEADER_ID
    ) = 1 THEN
    l_return_value := ONT_HEADER_Def_Util.g_cached_record.DEFAULT_OUTBOUND_LINE_TYPE_ID;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'LINE_TYPE_ID'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D2_LINE_TYPE_ID;

/
