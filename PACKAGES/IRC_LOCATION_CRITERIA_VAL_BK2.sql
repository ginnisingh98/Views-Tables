--------------------------------------------------------
--  DDL for Package IRC_LOCATION_CRITERIA_VAL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LOCATION_CRITERIA_VAL_BK2" AUTHID CURRENT_USER as
/* $Header: irlcvapi.pkh 120.4 2008/02/21 14:32:49 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< DELETE_LOCATION_CRITERIA_B >---------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_LOCATION_CRITERIA_B
  (p_location_criteria_value_id    in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< DELETE_LOCATION_CRITERIA_A >---------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_LOCATION_CRITERIA_A
  (p_location_criteria_value_id    in     number
  ,p_object_version_number         in     number
  );
--
end IRC_LOCATION_CRITERIA_VAL_BK2;



/
