--------------------------------------------------------
--  DDL for Package CCT_COLLECTION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_COLLECTION_UTIL_PUB" AUTHID CURRENT_USER as
/* $Header: cctcolls.pls 115.4 2003/02/19 02:31:51 svinamda noship $ */
NULL_POINTER_EXCEPTION EXCEPTION;
G_TRUE Varchar2(1) := 'Y';
G_FALSE Varchar2(1) := 'N';

FUNCTION	 Get(
     p_key_value_varr  IN cct_keyvalue_varr
    ,p_key             IN VARCHAR2
    ,x_key_exists Out NOCOPY VARCHAR2
 )return varchar2;

FUNCTION	 Put(
     p_key_value_varr  IN OUT NOCOPY cct_keyvalue_varr
    ,p_key             IN VARCHAR2
    ,p_value             IN VARCHAR2
 ) return varchar2;

FUNCTION	 GetKeys(
     p_key_value_varr  IN cct_keyvalue_varr
 ) return cct_key_varr ;

FUNCTION	 NumOfKeys(
     p_key_value_varr  IN cct_keyvalue_varr
 )return NUMBER;


FUNCTION	 CCT_KeyValue_Varr_ToString(
     p_key_value_varr  IN cct_keyvalue_varr
 )return VARCHAR2;



END CCT_COLLECTION_UTIL_PUB;


 

/
