--------------------------------------------------------
--  DDL for Package HR_CAL_ENTRY_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAL_ENTRY_VALUE_API" AUTHID CURRENT_USER as
/* $Header: peenvapi.pkh 120.0 2005/05/31 08:10:16 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_entry_value >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates a calendar entry value.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the calendar entry value is created.
--   p_effective_date               Yes  date     Application effective date.
--   p_calendar_entry_id            Yes  number   The FK of the parent calendar entry.
--   p_usage_flag                   Yes  varchar2 Flag value indicating the type of record to be created.
--                                                (i.e. entry value, entry value exception, entry value override)
--   p_hierarchy_node_id                 number   The FK of the parent generic hierarchy record.
--                                                (Only populated when the value is obtained from
--                                                a generic hierarchy record, otherwise null).
--   p_value                             varchar2 The idvalue of the entry (corresponds to the id of the
--                                                selected valueset value, for a stand-alone entry coverage).
--                                                (Only populated if parent calendar entry uses a value set)
--   p_org_structure_element_id          number   The FK to parent Org Structure Element link record
--                                                (Only populated if parent entry uses Org Hierarchy coverage).
--   p_organization_id                   number   The id of the organization within the Org Structure Element link.
--   p_override_name                     varchar2 The name overriding the parent entry name for this record.
--   p_override_type                     varchar2 The type overriding the parent entry type for this record.
--   p_parent_entry_value_id             number   The id of the parent entry value record (indicates that
--                                                this entry value is an exception to the identified parent
--                                                entry value).
--   p_identifier_key                    varchar2 Seed data identifier - Internal Development Use Only.

--
-- Post Success:
--   The calendar entry record is created and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_cal_entry_value_id           number   If p_validate is false, uniquely
--                                           identifies the  calendar entry value created.
--                                           If p_validate is true, set to
--                                           null.
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this calendar entry value.
--                                           If p_validate is true, set to null.
--
-- Post Failure:
--   The API does not create the calendar entry value record and raises an error.
--
-- Access Status:
--   Public
--
-- {End Of Comments}
--

procedure create_entry_value
  (p_validate                      in     boolean      default false
  ,p_effective_date                in     date
  ,p_calendar_entry_id             in     number
  ,p_usage_flag                    in     varchar2
  ,p_hierarchy_node_id             in     number       default null
  ,p_value                         in     varchar2     default null
  ,p_org_structure_element_id      in     number       default null
  ,p_organization_id               in     number       default null
  ,p_override_name                 in     varchar2     default null
  ,p_override_type                 in     varchar2     default null
  ,p_parent_entry_value_id         in     number       default null
  ,p_identifier_key                in     varchar2     default null
  ,p_cal_entry_value_id               out nocopy number
  ,p_object_version_number            out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |------------------------< update_entry_value >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates a calendar entry value as identified by p_cal_entry_value_id.
--
-- Prerequisites:
--   The calendar entry record value identified by p_cal_entry_value_id and
--   p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the calendar entry value is updated.
--   p_effective_date               Yes  date     Application effective date.
--   p_cal_entry_value_id           Yes  number   Surrogate id of the calendar entry value record.
--   p_object_version_number        Yes  number   Version number of the calendar entry value record.
--   p_override_name                     varchar2 The name overriding entry name for this record.
--   p_override_type                     varchar2 The type overriding entry type for this record.
--   p_parent_entry_value_id             number   The id of the parent entry value record (indicates that
--                                                this entry value is an exception to the identified parent
--                                                entry value).
--   p_usage_flag                        varchar2 Flag value indicating the type of record to be created.
--                                                (i.e. entry value, entry value exception, entry value override)
--
-- Post Success:
--   The calendar entry value record is updated and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of this
--                                           calendar entry value.
--                                           If p_validate is true, set to
--                                           null same value passed in.
--
-- Post Failure:
--   The API does not update the calendar entry value and raises an error.
--
-- Access Status:
--   Public
--
-- {End Of Comments}
--
procedure update_entry_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cal_entry_value_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_override_name                 in     varchar2     default hr_api.g_varchar2
  ,p_override_type                 in     varchar2     default hr_api.g_varchar2
  ,p_parent_entry_value_id         in     number       default hr_api.g_number
  ,p_usage_flag                    in     varchar2     default hr_api.g_varchar2
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_entry_value >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes a calendar entry value record as identified by the in parameter
--   p_cal_entry_value_id and p_object_version_number.
--
-- Prerequisites:
--   The calendar entry value as identified by the in parameter p_cal_entry_value_id and the
--   in parameter p_object_version_number must already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the calendar entry is deleted.
--   p_cal_entry_value_id           Yes  number   Primary key of the calendar entry value.
--   p_object_version_number        Yes  number   Current version of the
--                                                calendar entry value record.
--
-- Post Success:
--   The calendar entry is deleted.
--
-- Post Failure:
--   The API does not delete the calendar entry value and raises an error.
--
-- Access Status:
--   Public
--
--
-- {End Of Comments}
--
procedure delete_entry_value
  (p_validate                      in     boolean  default false
  ,p_cal_entry_value_id            in     number
  ,p_object_version_number         in     number
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_display_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns a decoded value from the valueset specified by either the
--   the combination of p_entity_id and p_node_type (gen hier node VS) or
--   p_calendar_entry_id and p_vs_value_id (stand-alone valueset). It is used by the
--   view PER_CAL_ENTRY_VALUES_V to populate display_value field.
--
-- Access Status:
--   Private - Internal development use only.
--
-- {End Of Comments}
--
FUNCTION get_display_value(p_entity_id IN varchar2,
                           p_node_type IN varchar2,
                           p_calendar_entry_id IN NUMBER,
                           p_vs_value_id IN VARCHAR2) RETURN VARCHAR2;

--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_g_current_entry_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the value of the current calendar entry id
--   as stored in the package global g_current_entry_id.
--   The current entry id is used by per_cal_entry_values_v view
--   and is set from HRMS Calendar module prior to querying the view.
--
-- Access Status:
--   Private - Internal Development use only.
--
-- {End Of Comments}
--
FUNCTION get_g_current_entry_id RETURN NUMBER;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_g_current_entry_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function sets the value of the current calendar entry id
--   in the package global g_current_entry_id.
--   The current entry id is used by per_cal_entry_values_v view
--   and is set from HRMS Calendar module prior to querying the view.
--
-- Access Status:
--   Private - Internal Development use only.
--
-- {End Of Comments}
--
PROCEDURE set_g_current_entry_id (p_entry_id NUMBER);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_g_current_osv_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the value of the current calendar OSV id
--   as stored in the package global g_current_osv_id.
--   The current OSV id is used to restrict the PER_CAL_ORG_HIER_VALUES_V view
--   to a particular Org Structure Version (and therefore its elements) and is
--   set from HRMS Calendar module prior to querying the view (along with
--   entry_id).
--
-- Access Status:
--   Private - Internal Development use only.
--
-- {End Of Comments}
--
FUNCTION get_g_current_osv_id RETURN NUMBER;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_g_current_osv_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function sets the value of the current calendar OSV id
--   in the package global g_current_osv_id.
--   The current OSV id is used to restrict the PER_CAL_ORG_HIER_VALUES_V view
--   to a particular Org Structure Version (and therefore its elements) and is
--   set from HRMS Calendar module prior to querying the view (along with
--   entry_id).
--
-- Access Status:
--   Private - Internal Development use only.
--
-- {End Of Comments}
--
PROCEDURE set_g_current_osv_id (p_osv_id NUMBER);
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_node_level >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function gets the arbitrary level of the supplied hierarchy node id
--   within the generic hierarchy of nodes. It also returns the path of the
--   node as the second part of the . delimited varchar return value.
--
--   e.g 3.10010.11188 - 3rd level, having nodes 10010 and 11188 as
--   grandparent and parent respectively.
--
-- Access Status:
--   Private - Internal Development use only.
--
-- {End Of Comments}
Function get_node_level (P_HIERARCHY_NODE_ID in NUMBER
                        ,P_HIERARCHY_VERSION_ID in NUMBER) RETURN VARCHAR2;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_ele_level >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function gets the arbitrary level of the supplied org link (element)
--   within the org hierarchy structure version. It also returns the path of the
--   link as the second part of the . delimited varchar return value.
--
--   e.g 3.10010.11188 - 3rd level, having links 10010 and 11188 as
--   grandparent and parent respectively.
--
-- Access Status:
--   Private - Internal Development use only.
--
-- {End Of Comments}
Function get_ele_level (P_ORG_STRUCTURE_ELEMENT_ID in NUMBER
                       ,P_ORG_STRUCTURE_VERSION_ID in NUMBER) RETURN VARCHAR2;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_sql_from_vset_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- Returns the sql from the valueset id supplied (assuming it is a sql VS)
--
--  Access Status:
--   Private - Internal Development use only.
--
FUNCTION get_sql_from_vset_id(p_vset_id IN NUMBER) RETURN VARCHAR2;

end  HR_CAL_ENTRY_VALUE_API;

 

/
