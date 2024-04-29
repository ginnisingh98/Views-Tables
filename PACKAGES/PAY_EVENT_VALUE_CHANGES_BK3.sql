--------------------------------------------------------
--  DDL for Package PAY_EVENT_VALUE_CHANGES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_VALUE_CHANGES_BK3" AUTHID CURRENT_USER as
/* $Header: pyevcapi.pkh 120.1 2005/10/02 02:31:07 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_event_value_change_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_event_value_change_b
  (p_effective_date                in     date
  ,p_datetrack_mode         in     varchar2
  ,p_event_value_change_id         in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_event_value_change_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_event_value_change_a
  (p_effective_date                in     date
  ,p_datetrack_mode         in     varchar2
  ,p_event_value_change_id         in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_event_value_changes_bk3;

 

/
