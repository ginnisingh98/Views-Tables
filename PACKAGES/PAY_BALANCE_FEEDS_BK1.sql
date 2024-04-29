--------------------------------------------------------
--  DDL for Package PAY_BALANCE_FEEDS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_FEEDS_BK1" AUTHID CURRENT_USER as
/* $Header: pypbfapi.pkh 120.0.12010000.1 2008/07/27 23:20:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_balance_feed_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_feed_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_legislation_code		   in     varchar2
  ,p_balance_type_id		   in     number
  ,p_input_value_id		   in     number
  ,p_scale			   in     number
  ,p_legislation_subgroup	   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_balance_feed_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_feed_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_legislation_code		   in     varchar2
  ,p_balance_type_id		   in     number
  ,p_input_value_id		   in     number
  ,p_scale			   in     number
  ,p_legislation_subgroup	   in     varchar2
  ,p_balance_feed_id               in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_object_version_number         in     number
  ,p_exist_run_result_warning      in     boolean
  );
--
end PAY_BALANCE_FEEDS_BK1;

/
