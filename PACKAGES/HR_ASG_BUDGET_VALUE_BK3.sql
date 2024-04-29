--------------------------------------------------------
--  DDL for Package HR_ASG_BUDGET_VALUE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASG_BUDGET_VALUE_BK3" AUTHID CURRENT_USER as
/* $Header: peabvapi.pkh 120.1 2005/10/02 02:09:07 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< DELETE_ASG_BUDGET_VALUE_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ASG_BUDGET_VALUE_b
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_assignment_budget_value_id    in     number
  ,p_object_version_number         in     number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------< DELETE_ASG_BUDGET_VALUE_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ASG_BUDGET_VALUE_a
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_assignment_budget_value_id    in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_object_version_number         in     number
  );
--
end hr_asg_budget_value_bk3;

 

/
