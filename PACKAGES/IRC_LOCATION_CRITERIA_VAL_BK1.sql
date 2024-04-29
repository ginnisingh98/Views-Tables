--------------------------------------------------------
--  DDL for Package IRC_LOCATION_CRITERIA_VAL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LOCATION_CRITERIA_VAL_BK1" AUTHID CURRENT_USER as
/* $Header: irlcvapi.pkh 120.4 2008/02/21 14:32:49 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< CREATE_LOCATION_CRITERIA_B >---------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_LOCATION_CRITERIA_B
  (p_search_criteria_id            in     number
  ,p_derived_locale                in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< CREATE_LOCATION_CRITERIA_A >---------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_LOCATION_CRITERIA_A
  (p_location_criteria_value_id    in     number
  ,p_search_criteria_id            in     number
  ,p_derived_locale                in     varchar2
  ,p_object_version_number         in     number
  );
--
end IRC_LOCATION_CRITERIA_VAL_BK1;

/
