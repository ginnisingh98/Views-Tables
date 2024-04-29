--------------------------------------------------------
--  DDL for Package PQH_DE_CASE_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_CASE_GROUPS_API" AUTHID CURRENT_USER as
/* $Header: pqcgnapi.pkh 120.0 2005/05/29 01:42:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_CASE_GROUPS_API> >--------------------------|
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


procedure Insert_CASE_GROUPS
  (p_validate                            in  boolean  default false
  ,p_effective_date                     in  date
  ,p_Case_Group_NUMBER                  In  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,p_Advanced_Pay_Grade		        IN  Number
  ,p_Entries_in_Minute		        In  Varchar2
  ,p_Period_Of_Prob_Advmnt              IN  Number
  ,p_Period_Of_Time_Advmnt	        IN  Number
  ,p_Advancement_To			IN  Number
  ,p_Advancement_Additional_pyt 	IN  Number
  ,p_time_advanced_pay_grade            in  number
  ,p_time_advancement_to                in  number
  ,p_business_group_id                  in  number
  ,p_time_advn_units                    in  varchar2
  ,p_prob_advn_units                    in  varchar2
  ,p_sub_csgrp_description              In  Varchar2
  ,P_CASE_GROUP_ID                      out nocopy Number
  ,p_object_version_number              out nocopy number) ;



Procedure Update_CASE_GROUPS
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_case_group_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_case_group_number            in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_advanced_pay_grade           in     number    default hr_api.g_number
  ,p_entries_in_minute            in     varchar2  default hr_api.g_varchar2
  ,p_period_of_prob_advmnt        in     number    default hr_api.g_number
  ,p_period_of_time_advmnt        in     number    default hr_api.g_number
  ,p_advancement_to               in     number    default hr_api.g_number
  ,p_advancement_additional_pyt   in     number    default hr_api.g_number
  ,p_time_advanced_pay_grade      in     number    default hr_api.g_number
  ,p_time_advancement_to          in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_time_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_prob_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_sub_csgrp_description        In     Varchar2  default hr_api.g_varchar2
  );


procedure delete_CASE_GROUPS
  (p_validate                      in     boolean  default false
  ,p_CASE_GROUP_ID                 In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_CASE_GROUPS_API;

 

/
