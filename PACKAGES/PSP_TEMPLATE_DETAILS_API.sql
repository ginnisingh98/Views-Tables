--------------------------------------------------------
--  DDL for Package PSP_TEMPLATE_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_TEMPLATE_DETAILS_API" AUTHID CURRENT_USER as
/* $Header: PSPRDAIS.pls 120.0 2005/06/02 15:56:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------- Create_TEMPLATE_DETAILS --------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_TEMPLATE_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Create_TEMPLATE_DETAILS
  (   P_VALIDATE                      in     boolean  default false
	, P_TEMPLATE_ID                     in        NUMBER
	, P_CRITERIA_LOOKUP_TYPE            in        VARCHAR2
	, P_CRITERIA_LOOKUP_CODE            in        VARCHAR2
	, P_INCLUDE_EXCLUDE_FLAG            in        VARCHAR2
	, P_CRITERIA_VALUE1                 in        VARCHAR2
	, P_CRITERIA_VALUE2                 in        VARCHAR2
	, P_CRITERIA_VALUE3                 in        VARCHAR2
    , P_TEMPLATE_DETAIL_ID		    in	     NUMBER
    , P_OBJECT_VERSION_NUMBER       out nocopy      NUMBER
    , P_WARNING                     out nocopy      boolean
    , P_RETURN_STATUS               out nocopy      boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_TEMPLATE_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_TEMPLATE_DETAILS
  (P_VALIDATE                      in     boolean  default false
	, P_TEMPLATE_ID                     in        NUMBER
	, P_CRITERIA_LOOKUP_TYPE            in        VARCHAR2
	, P_CRITERIA_LOOKUP_CODE            in        VARCHAR2
	, P_INCLUDE_EXCLUDE_FLAG            in        VARCHAR2
	, P_CRITERIA_VALUE1                 in        VARCHAR2
	, P_CRITERIA_VALUE2                 in        VARCHAR2
	, P_CRITERIA_VALUE3                 in        VARCHAR2
    , P_TEMPLATE_DETAIL_ID            in out nocopy      NUMBER
   , P_OBJECT_VERSION_NUMBER       in out nocopy      NUMBER
   , P_WARNING                     out nocopy      boolean
   , P_RETURN_STATUS               out nocopy      boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_TEMPLATE_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_TEMPLATE_DETAILS
  (P_VALIDATE                       in     BOOLEAN default false
  , P_TEMPLATE_DETAIL_ID            in    NUMBER
  ,P_OBJECT_VERSION_NUMBER          in out nocopy number
  ,P_WARNING                       out nocopy varchar2
  );
end PSP_TEMPLATE_DETAILS_API;

 

/
