--------------------------------------------------------
--  DDL for Package Body CCT_CUSTOM_LOOKUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_CUSTOM_LOOKUP_PUB" as
/* $Header: cctcuslb.pls 120.0 2005/06/02 09:53:17 appldev noship $ */

FUNCTION	 GetData(
     x_key_value_varr  IN OUT NOCOPY cct_keyvalue_varr
 ) return varchar2 IS

   x_oper_succeeded varchar2(1) := cct_collection_util_pub.G_FALSE;
   l_key_value_varr cct_keyvalue_varr;
   l_value varchar2(32767) ;
   i BINARY_INTEGER;
 begin
	l_value := cct_collection_util_pub.Get(x_key_value_varr,'occtCustomLookup',								 x_oper_succeeded);
    return  cct_collection_util_pub.G_TRUE;
    EXCEPTION
     WHEN OTHERS THEN
      return x_oper_succeeded ;
END GetData;

END CCT_CUSTOM_LOOKUP_PUB;


/
