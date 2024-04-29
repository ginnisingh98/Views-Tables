--------------------------------------------------------
--  DDL for Package PSP_TEMPLATE_DETAILS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_TEMPLATE_DETAILS_BK1" AUTHID CURRENT_USER as
/* $Header: PSPRDAIS.pls 120.0 2005/06/02 15:56:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------- Create_TEMPLATE_DETAILS_b -------------------------|
-- ----------------------------------------------------------------------------
--
procedure Create_TEMPLATE_DETAILS_b
    ( P_TEMPLATE_ID                     in        NUMBER
	, P_CRITERIA_LOOKUP_TYPE            in        VARCHAR2
	, P_CRITERIA_LOOKUP_CODE            in        VARCHAR2
	, P_INCLUDE_EXCLUDE_FLAG            in        VARCHAR2
	, P_CRITERIA_VALUE1                 in        VARCHAR2
	, P_CRITERIA_VALUE2                 in        VARCHAR2
	,  P_CRITERIA_VALUE3                 in        VARCHAR2
    , P_TEMPLATE_DETAIL_ID		    in	     NUMBER
   );
-- ----------------------------------------------------------------------------
-- |------------------------- Create_TEMPLATE_DETAILS_a -------------------------|
-- ----------------------------------------------------------------------------
--
procedure Create_TEMPLATE_DETAILS_a
   (  P_TEMPLATE_ID                     in        NUMBER
	, P_CRITERIA_LOOKUP_TYPE            in        VARCHAR2
	, P_CRITERIA_LOOKUP_CODE            in        VARCHAR2
	, P_INCLUDE_EXCLUDE_FLAG            in        VARCHAR2
	, P_CRITERIA_VALUE1                 in        VARCHAR2
	, P_CRITERIA_VALUE2                 in        VARCHAR2
	,  P_CRITERIA_VALUE3                in        VARCHAR2
    , P_TEMPLATE_DETAIL_ID              in        NUMBER
    , P_OBJECT_VERSION_NUMBER         in        number
    , P_WARNING                       in        boolean
    , P_RETURN_STATUS                 in        boolean
  );
end PSP_TEMPLATE_DETAILS_BK1;

 

/
