--------------------------------------------------------
--  DDL for Package CCT_CUSTOMER_LOOKUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_CUSTOMER_LOOKUP_PUB" AUTHID CURRENT_USER as
/* $Header: cctctmrs.pls 120.0 2005/06/02 09:44:52 appldev noship $ */

FUNCTION ProcessCall(
     x_key_value_varr IN OUT NOCOPY cct_keyvalue_varr
 ) return varchar2;

END CCT_CUSTOMER_LOOKUP_PUB;

 

/
