--------------------------------------------------------
--  DDL for Package IRC_PROF_AREA_CRITERIA_VAL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PROF_AREA_CRITERIA_VAL_BK2" AUTHID CURRENT_USER as
/* $Header: irpcvapi.pkh 120.4 2008/02/21 14:34:22 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< DELETE_PROF_AREA_CRITERIA_B >--------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_PROF_AREA_CRITERIA_B
  (p_prof_area_criteria_value_id   in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< DELETE_PROF_AREA_CRITERIA_A >--------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_PROF_AREA_CRITERIA_A
  (p_prof_area_criteria_value_id   in     number
  ,p_object_version_number         in     number
  );
--
end IRC_PROF_AREA_CRITERIA_VAL_BK2;



/
