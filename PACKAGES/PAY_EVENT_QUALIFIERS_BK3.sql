--------------------------------------------------------
--  DDL for Package PAY_EVENT_QUALIFIERS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_QUALIFIERS_BK3" AUTHID CURRENT_USER as
/* $Header: pyevqapi.pkh 120.1 2005/10/02 02:31:23 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_event_qualifier_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_event_qualifier_b
  (p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_event_qualifier_id            in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_event_qualifier_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_event_qualifier_a
  (p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_event_qualifier_id            in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_event_qualifiers_bk3;

 

/
