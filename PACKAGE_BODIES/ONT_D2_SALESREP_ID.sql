--------------------------------------------------------
--  DDL for Package Body ONT_D2_SALESREP_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D2_SALESREP_ID" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_SALESREP_ID
--  
--  DESCRIPTION
--  
--      Body of package ONT_D2_SALESREP_ID
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D2_SALESREP_ID';
 
 
FUNCTION Get_Default_Value(p_line_rec IN  OE_AK_ORDER_LINES_V%ROWTYPE 
  ) RETURN NUMBER IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    l_rule_id := 1025;
    IF ONT_BLANKET_LINE_Def_Util.Sync_BLANKET_LINE_Cache
    (p_ORDER_NUMBER => p_line_rec.BLANKET_NUMBER
    ,p_LINE_NUMBER => p_line_rec.BLANKET_LINE_NUMBER
    ) = 1 THEN
    l_return_value := ONT_BLANKET_LINE_Def_Util.g_cached_record.SALESREP_ID;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'SALESREP_ID'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D2_SALESREP_ID;

/
