--------------------------------------------------------
--  DDL for Package IRC_PROF_AREA_CRITERIA_VAL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PROF_AREA_CRITERIA_VAL_BK1" AUTHID CURRENT_USER as
/* $Header: irpcvapi.pkh 120.4 2008/02/21 14:34:22 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< CREATE_PROF_AREA_CRITERIA_B >--------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_PROF_AREA_CRITERIA_B
  (p_effective_date                in     date
  ,p_search_criteria_id            in     number
  ,p_professional_area             in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< CREATE_PROF_AREA_CRITERIA_A >--------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_PROF_AREA_CRITERIA_A
  (p_effective_date                in     date
  ,p_prof_area_criteria_value_id   in     number
  ,p_search_criteria_id            in     number
  ,p_professional_area             in     varchar2
  ,p_object_version_number         in     number
  );
--
end IRC_PROF_AREA_CRITERIA_VAL_BK1;

/
