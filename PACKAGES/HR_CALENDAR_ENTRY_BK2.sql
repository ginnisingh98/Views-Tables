--------------------------------------------------------
--  DDL for Package HR_CALENDAR_ENTRY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_ENTRY_BK2" AUTHID CURRENT_USER as
/* $Header: peentapi.pkh 120.0 2005/05/31 08:08:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_calendar_entry_b >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_calendar_entry_b
  (p_effective_date                in     date
  ,p_calendar_entry_id             in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_type                          in     varchar2
  ,p_start_date                    in     date
  ,p_start_hour                    in     varchar2
  ,p_start_min                     in     varchar2
  ,p_end_date                      in     date
  ,p_end_hour                      in     varchar2
  ,p_end_min                       in     varchar2
  ,p_description                   in     varchar2
  ,p_hierarchy_id                  in     number
  ,p_value_set_id                  in     number
  ,p_organization_structure_id     in     number
  ,p_org_structure_version_id      in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< update_calendar_entry_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_calendar_entry_a
  (p_effective_date                in     date
  ,p_calendar_entry_id             in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_type                          in     varchar2
  ,p_start_date                    in     date
  ,p_start_hour                    in     varchar2
  ,p_start_min                     in     varchar2
  ,p_end_date                      in     date
  ,p_end_hour                      in     varchar2
  ,p_end_min                       in     varchar2
  ,p_description                   in     varchar2
  ,p_hierarchy_id                  in     number
  ,p_value_set_id                  in     number
  ,p_organization_structure_id     in     number
  ,p_org_structure_version_id      in     number
  );
--
end HR_CALENDAR_ENTRY_BK2;

 

/
