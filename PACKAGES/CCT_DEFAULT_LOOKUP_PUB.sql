--------------------------------------------------------
--  DDL for Package CCT_DEFAULT_LOOKUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_DEFAULT_LOOKUP_PUB" AUTHID CURRENT_USER as
/* $Header: cctdefcs.pls 120.0 2005/06/02 09:28:52 appldev noship $ */
/*------------------------------------------------------------------------
REM  Group : Customer Initialization Phase
REM  Get Customer/PartyID from any one of the following Objects if available
REM  ANI
REM  PARTY_NUMBER
REM  QUOTE_NUMBER
REM  ORDER_NUMBER
REM  COLLATERAL_REQUEST
REM  ACCOUNT_NUMBER
REM  EVENT_REGISTRATION_CODE
REM  MARKETING_PIN
REM  SERVICE_KEY
REM  SERVICE_REQUEST_NUMBER
REM
REM  using a Telesales provided api
REM
REM-----------------------------------------------------------------------*/

Function GetData(
     x_key_value_varr IN OUT NOCOPY cct_keyvalue_varr
	) Return Varchar2;

END CCT_Default_Lookup_PUB;

 

/
