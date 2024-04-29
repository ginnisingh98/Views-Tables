--------------------------------------------------------
--  DDL for Package HR_ASG_BUDGET_VALUE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASG_BUDGET_VALUE_BK2" AUTHID CURRENT_USER as
/* $Header: peabvapi.pkh 120.1 2005/10/02 02:09:07 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< UPDATE_ASG_BUDGET_VALUE_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_ASG_BUDGET_VALUE_b
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_business_group_id             in     number
  ,p_unit                          in     varchar2
  ,p_value                         in     number
  ,p_request_id                    in     number
  ,p_program_application_id        in     number
  ,p_program_id                    in     number
  ,p_program_update_date           in     date
  ,p_last_update_date              in     date
  ,p_last_updated_by               in     number
  ,p_last_update_login             in     number
  ,p_created_by                    in     number
  ,p_creation_date                 in     date
  ,p_assignment_budget_value_id    in     number
  ,p_object_version_number         in     number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------< UPDATE_ASG_BUDGET_VALUE_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_ASG_BUDGET_VALUE_a
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_business_group_id             in     number
  ,p_unit                          in     varchar2
  ,p_value                         in     number
  ,p_request_id                    in     number
  ,p_program_application_id        in     number
  ,p_program_id                    in     number
  ,p_program_update_date           in     date
  ,p_last_update_date              in     date
  ,p_last_updated_by               in     number
  ,p_last_update_login             in     number
  ,p_created_by                    in     number
  ,p_creation_date                 in     date
  ,p_assignment_budget_value_id    in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_object_version_number         in     number
  );
--
end hr_asg_budget_value_bk2;

 

/
