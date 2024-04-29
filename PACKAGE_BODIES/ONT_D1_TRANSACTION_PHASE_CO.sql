--------------------------------------------------------
--  DDL for Package Body ONT_D1_TRANSACTION_PHASE_CO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D1_TRANSACTION_PHASE_CO" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1_TRANSACTION_PHASE_CO
--  
--  DESCRIPTION
--  
--      Body of package ONT_D1_TRANSACTION_PHASE_CO
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D1_TRANSACTION_PHASE_CO';
 
 
FUNCTION Get_Default_Value(p_header_rec IN  OE_AK_ORDER_HEADERS_V%ROWTYPE 
  ) RETURN VARCHAR2 IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    l_rule_id := 504;
    l_return_value := FND_PROFILE.VALUE('ONT_DEFAULT_TRANSACTION_PHASE');
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 505;
    IF ONT_ORDER_TYPE_Def_Util.Sync_ORDER_TYPE_Cache
    (p_ORDER_TYPE_ID => p_header_rec.ORDER_TYPE_ID
    ) = 1 THEN
    l_return_value := ONT_ORDER_TYPE_Def_Util.g_cached_record.DEF_TRANSACTION_PHASE_CODE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'TRANSACTION_PHASE_CODE'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D1_TRANSACTION_PHASE_CO;

/
