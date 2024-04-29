--------------------------------------------------------
--  DDL for Package HR_CALENDAR_ENTRY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_ENTRY_BK1" AUTHID CURRENT_USER as
/* $Header: peentapi.pkh 120.0 2005/05/31 08:08:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_calendar_entry_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_calendar_entry_b
  (p_effective_date                in     date
  ,p_name                          in     varchar2
  ,p_type                          in     varchar2
  ,p_start_date                    in     date
  ,p_start_hour                    in     varchar2
  ,p_start_min                     in     varchar2
  ,p_end_date                      in     date
  ,p_end_hour                      in     varchar2
  ,p_end_min                       in     varchar2
  ,p_business_group_id             in     number
  ,p_description                   in     varchar2
  ,p_hierarchy_id                  in     number
  ,p_value_set_id                  in     number
  ,p_organization_structure_id     in     number
  ,p_org_structure_version_id      in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_calendar_entry_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_calendar_entry_a
  (p_effective_date                in     date
  ,p_name                          in     varchar2
  ,p_type                          in     varchar2
  ,p_start_date                    in     date
  ,p_start_hour                    in     varchar2
  ,p_start_min                     in     varchar2
  ,p_end_date                      in     date
  ,p_end_hour                      in     varchar2
  ,p_end_min                       in     varchar2
  ,p_business_group_id             in     number
  ,p_description                   in     varchar2
  ,p_hierarchy_id                  in     number
  ,p_value_set_id                  in     number
  ,p_organization_structure_id     in     number
  ,p_org_structure_version_id      in     number
  ,p_calendar_entry_id             in     number
  ,p_object_version_number         in     number
  );
--
end HR_CALENDAR_ENTRY_BK1;

 

/