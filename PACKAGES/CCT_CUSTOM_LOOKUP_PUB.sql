--------------------------------------------------------
--  DDL for Package CCT_CUSTOM_LOOKUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_CUSTOM_LOOKUP_PUB" AUTHID CURRENT_USER as
/* $Header: cctcusls.pls 120.0 2005/06/02 09:55:40 appldev noship $ */
FUNCTION GetData(
     x_key_value_varr IN OUT NOCOPY cct_keyvalue_varr
 ) return varchar2;

END CCT_CUSTOM_LOOKUP_PUB;

 

/
