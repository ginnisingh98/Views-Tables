--------------------------------------------------------
--  DDL for Package HXC_RECURRING_PERIODS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RECURRING_PERIODS_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchrpapi.pkh 120.1 2005/10/02 02:06:51 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_recurring_periods_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_recurring_periods_b
  (p_recurring_period_id           in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_period_type                   in     varchar2
  ,p_duration_in_days              in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_recurring_periods_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_recurring_periods_a
  (p_recurring_period_id           in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_period_type                   in     varchar2
  ,p_duration_in_days              in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_recurring_periods_b > ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_recurring_periods_b
  (p_recurring_period_id           in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_period_type                   in     varchar2
  ,p_duration_in_days              in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_recurring_periods_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_recurring_periods_a
  (p_recurring_period_id           in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_period_type                   in     varchar2
  ,p_duration_in_days              in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_recurring_periods_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_recurring_periods_b
  (p_recurring_period_id            in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_recurring_periods_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_recurring_periods_a
  (p_recurring_period_id            in  number
  ,p_object_version_number          in  number
  );
--
end hxc_recurring_periods_bk_1;

 

/
