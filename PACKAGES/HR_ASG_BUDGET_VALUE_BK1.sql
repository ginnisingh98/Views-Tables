--------------------------------------------------------
--  DDL for Package HR_ASG_BUDGET_VALUE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASG_BUDGET_VALUE_BK1" AUTHID CURRENT_USER as
/* $Header: peabvapi.pkh 120.1 2005/10/02 02:09:07 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< CREATE_ASG_BUDGET_VALUE_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_ASG_BUDGET_VALUE_b
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
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
 );
--
-- ----------------------------------------------------------------------------
-- |------------------< CREATE_ASG_BUDGET_VALUE_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_ASG_BUDGET_VALUE_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
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
end hr_asg_budget_value_bk1;

 

/
