--------------------------------------------------------
--  DDL for Package PQH_DE_VLDDEF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDDEF_API" AUTHID CURRENT_USER as
/* $Header: pqdefapi.pkh 120.0 2005/05/29 01:46:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_VLDDEF_API> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API Creates the the Validation Definition for the Workplace Validation Proess
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
procedure Insert_Vldtn_Defn
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_VALIDATION_NAME               In  Varchar2
  ,p_EMPLOYMENT_TYPE               In  Varchar2
  ,p_REMUNERATION_REGULATION       In  Varchar2
  ,p_WRKPLC_VLDTN_ID               out nocopy number
  ,p_object_version_number         out nocopy number);

procedure Update_Vldtn_Defn
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number   Default hr_api.g_Number
  ,p_VALIDATION_NAME               In     Varchar2 Default hr_api.g_Varchar2
  ,p_EMPLOYMENT_TYPE               In     Varchar2 Default hr_api.g_Varchar2
  ,p_REMUNERATION_REGULATION       In     Varchar2 Default hr_api.g_Varchar2
  ,p_WRKPLC_VLDTN_ID               in     number
  ,p_object_version_number         In out nocopy number);

Procedure Delete_Vldtn_Defn
  (p_validate                      in     boolean  default false
  ,p_WRKPLC_VLDTN_ID               In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_VLDDEF_API;

 

/
