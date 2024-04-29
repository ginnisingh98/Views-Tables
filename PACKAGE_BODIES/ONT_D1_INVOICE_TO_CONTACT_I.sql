--------------------------------------------------------
--  DDL for Package Body ONT_D1_INVOICE_TO_CONTACT_I
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D1_INVOICE_TO_CONTACT_I" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1_INVOICE_TO_CONTACT_I
--  
--  DESCRIPTION
--  
--      Body of package ONT_D1_INVOICE_TO_CONTACT_I
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D1_INVOICE_TO_CONTACT_I';
 
 
FUNCTION Get_Default_Value(p_header_rec IN  OE_AK_ORDER_HEADERS_V%ROWTYPE 
  ) RETURN NUMBER IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    l_rule_id := 21;
    IF ONT_AGREEMENT_Def_Util.Sync_AGREEMENT_Cache
    (p_AGREEMENT_ID => p_header_rec.AGREEMENT_ID
    ) = 1 THEN
    l_return_value := ONT_AGREEMENT_Def_Util.g_cached_record.INVOICE_TO_CONTACT_ID;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 22;
    IF ONT_INV_ORG_Def_Util.Sync_INV_ORG_Cache
    (p_ORGANIZATION_ID => p_header_rec.INVOICE_TO_ORG_ID
    ) = 1 THEN
    l_return_value := ONT_INV_ORG_Def_Util.g_cached_record.CONTACT_ID;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'INVOICE_TO_CONTACT_ID'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D1_INVOICE_TO_CONTACT_I;

/
