--------------------------------------------------------
--  DDL for Package IRC_SEARCH_CRITERIA_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SEARCH_CRITERIA_BK6" AUTHID CURRENT_USER as
/* $Header: iriscapi.pkh 120.2 2008/02/21 14:24:29 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_VACANCY_CRITERIA_B >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_VACANCY_CRITERIA_B
  (p_search_criteria_id            in     number
  ,p_object_version_number         in     number
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_VACANCY_CRITERIA_A >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_VACANCY_CRITERIA_A
  (p_search_criteria_id            in     number
  ,p_object_version_number         in     number
);
--
end IRC_SEARCH_CRITERIA_BK6;

/
