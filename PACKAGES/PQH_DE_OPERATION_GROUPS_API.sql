--------------------------------------------------------
--  DDL for Package PQH_DE_OPERATION_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPERATION_GROUPS_API" AUTHID CURRENT_USER as
/* $Header: pqopgapi.pkh 120.0 2005/05/29 02:13:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< <PQH_DE_OPERATION_GROUPS_API> >------------------------|
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


procedure Insert_OPERATION_GROUPS
  (p_validate                            in  boolean  default false
  ,p_effective_date                      in  date
  ,p_operation_Group_CODE                In  Varchar2
  ,P_DESCRIPTION                         In  Varchar2
  ,p_business_group_id                   in  number
  ,p_operation_GROUP_ID                  out nocopy Number
  ,p_object_version_number               out nocopy number) ;



Procedure Update_OPERATION_GROUPS
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_operation_GROUP_ID           in     number
  ,p_object_version_number        in out nocopy number
  ,p_operation_Group_CODE         in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  );


procedure delete_OPERATION_GROUPS
  (p_validate                      in     boolean  default false
  ,p_operation_GROUP_ID            In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_OPERATION_GROUPS_API;

 

/
