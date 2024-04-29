--------------------------------------------------------
--  DDL for Package PQH_DE_ENT_MINUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_ENT_MINUTES_API" AUTHID CURRENT_USER as
/* $Header: pqetmapi.pkh 120.0 2005/05/29 01:52:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_ENT_MINUTES_API> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API Creates the the master definition of Case Group details
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


procedure Insert_ENT_MINUTES
 (p_validate                            in  boolean  default false
  ,p_effective_date                      in  date
  ,p_TARIFF_Group_CD                     In  Varchar2
  ,p_ent_minutes_CD                      In  Varchar2
  ,P_DESCRIPTION                         In  Varchar2
  ,p_business_group_id                   in  number
  ,P_ENT_MINUTES_ID                      out nocopy Number
  ,p_object_version_number               out nocopy number) ;



 Procedure Update_ENT_MINUTES
 (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_ENT_MINUTES_ID                 in     number
  ,p_object_version_number          in     out nocopy number
  ,p_TARIFF_Group_CD                in     varchar2  default hr_api.g_varchar2
  ,p_ent_minutes_CD                 In      Varchar2     default hr_api.g_varchar2
  ,p_description                    in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in     number    default hr_api.g_number
  );


procedure delete_ENT_MINUTES
  (p_validate                      in     boolean  default false
  ,P_ENT_MINUTES_ID                In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_ENT_MINUTES_API;

 

/
