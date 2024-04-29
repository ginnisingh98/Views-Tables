--------------------------------------------------------
--  DDL for Package PAY_BALANCE_FEEDS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_FEEDS_BK2" AUTHID CURRENT_USER as
/* $Header: pypbfapi.pkh 120.0.12010000.1 2008/07/27 23:20:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_balance_feed_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_balance_feed_b
  (p_effective_date		   in     date
  ,p_datetrack_update_mode	   in     varchar2
  ,p_balance_feed_id		   in     number
  ,p_scale			   in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_balance_feed_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_balance_feed_a
  (p_effective_date		   in     date
  ,p_datetrack_update_mode	   in     varchar2
  ,p_balance_feed_id		   in     number
  ,p_scale			   in     number
  ,p_effective_start_date	   in     date
  ,p_effective_end_date		   in     date
  ,p_object_version_number	   in     number
  ,p_exist_run_result_warning      in     boolean
  );
--
end PAY_BALANCE_FEEDS_BK2;

/
