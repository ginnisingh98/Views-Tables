--------------------------------------------------------
--  DDL for Package Body CCT_CUSTOMER_LOOKUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_CUSTOMER_LOOKUP_PUB" as
/* $Header: cctctmrb.pls 120.3 2005/09/23 15:06:24 appldev noship $ */


FUNCTION   ProcessCall(
     x_key_value_varr  IN OUT NOCOPY cct_keyvalue_varr
 ) return varchar2 IS

   x_oper_succeeded varchar2(1) := cct_collection_util_pub.G_FALSE;
   l_key_value_varr cct_keyvalue_varr;
   l_value varchar2(32767) ;
   l_return_value varchar2(1);
   l_is_event_raised varchar2(1);
   i BINARY_INTEGER;
 begin
  l_value := cct_collection_util_pub.Get(x_key_value_varr,'occtCustomerLookup', x_oper_succeeded);
  l_return_value := 'S';

    IF (Upper(l_value) = 'SALES') THEN
       l_return_value := cct_default_lookup_pub.GetData(x_key_value_varr);
    ELSIF (Upper(l_value) = 'SERVICE') THEN
       CSC_ROUTING_UTL.CSC_CUSTOMER_LOOKUP(x_key_value_varr);
    ELSIF (Upper(l_value) = 'CUSTOM') THEN
       l_return_value := cct_custom_lookup_pub.GetData(x_key_value_varr);
    END IF ;

  return l_return_value;
  EXCEPTION
     WHEN OTHERS THEN
      return x_oper_succeeded ;
-- end ;
END ProcessCall;

END CCT_CUSTOMER_LOOKUP_PUB;


/
