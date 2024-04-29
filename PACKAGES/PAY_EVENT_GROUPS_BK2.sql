--------------------------------------------------------
--  DDL for Package PAY_EVENT_GROUPS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_GROUPS_BK2" AUTHID CURRENT_USER as
/* $Header: pyevgapi.pkh 120.3 2005/10/24 01:00:46 adkumar noship $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< update_event_group_b  >------------------|
-- ---------------------------------------------------------------------
--
procedure update_event_group_b
 ( p_effective_date               in     date
  ,p_event_group_id               in     number
  ,p_object_version_number        in     number
  ,p_event_group_name             in     varchar2
  ,p_event_group_type             in     varchar2
  ,p_proration_type               in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_time_definition_id           in     number
);
--
-- ----------------------------------------------------------------------
-- |---------------------< update_event_group_a >------------------|
-- ---------------------------------------------------------------------
--
procedure update_event_group_a
 ( p_effective_date               in     date
  ,p_event_group_id               in     number
  ,p_object_version_number        in     number
  ,p_event_group_name             in     varchar2
  ,p_event_group_type             in     varchar2
  ,p_proration_type               in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_time_definition_id           in     number
);
--
end pay_event_groups_bk2;

 

/
