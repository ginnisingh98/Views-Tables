--------------------------------------------------------
--  DDL for Package Body ONT_D2_FOB_POINT_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D2_FOB_POINT_CODE" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_FOB_POINT_CODE
--  
--  DESCRIPTION
--  
--      Body of package ONT_D2_FOB_POINT_CODE
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D2_FOB_POINT_CODE';
 
 
FUNCTION Get_Default_Value(p_line_rec IN  OE_AK_ORDER_LINES_V%ROWTYPE 
  ) RETURN VARCHAR2 IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    l_rule_id := 70;
    IF ONT_HEADER_Def_Util.Sync_HEADER_Cache
    (p_HEADER_ID => p_line_rec.HEADER_ID
    ) = 1 THEN
    l_return_value := ONT_HEADER_Def_Util.g_cached_record.FOB_POINT_CODE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'FOB_POINT_CODE'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D2_FOB_POINT_CODE;

/
