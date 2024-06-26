--------------------------------------------------------
--  DDL for Package PAY_RUN_TYPE_USAGE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_TYPE_USAGE_BK1" AUTHID CURRENT_USER as
/* $Header: pyrtuapi.pkh 120.1 2005/10/02 02:34:14 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_run_type_usage_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_run_type_usage_b
  (p_effective_date                in     date
  ,p_parent_run_type_id            in     number
  ,p_child_run_type_id             in     number
  ,p_sequence                      in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_run_type_usage_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_run_type_usage_a
  (p_effective_date                in     date
  ,p_parent_run_type_id            in     number
  ,p_child_run_type_id             in     number
  ,p_sequence                      in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_run_type_usage_id             in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_object_version_number         in     number
  );
--
end pay_run_type_usage_bk1;

 

/
