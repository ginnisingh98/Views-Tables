--------------------------------------------------------
--  DDL for Package PAY_BALANCE_FEEDS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_FEEDS_BK3" AUTHID CURRENT_USER as
/* $Header: pypbfapi.pkh 120.0.12010000.1 2008/07/27 23:20:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_balance_feed_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_feed_b
  (p_effective_date                  in     date
  ,p_datetrack_delete_mode           in     varchar2
  ,p_balance_feed_id                 in     number
  ,p_object_version_number           in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_balance_feed_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_feed_a
  (p_effective_date                  in     date
  ,p_datetrack_delete_mode           in     varchar2
  ,p_balance_feed_id                 in     number
  ,p_object_version_number           in     number
  ,p_effective_start_date            in     date
  ,p_effective_end_date              in     date
  ,p_exist_run_result_warning	     in     boolean
  );
--
end PAY_BALANCE_FEEDS_BK3;

/
