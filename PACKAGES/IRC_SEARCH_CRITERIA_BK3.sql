--------------------------------------------------------
--  DDL for Package IRC_SEARCH_CRITERIA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SEARCH_CRITERIA_BK3" AUTHID CURRENT_USER as
/* $Header: iriscapi.pkh 120.2 2008/02/21 14:24:29 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_SAVED_SEARCH_B >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_SAVED_SEARCH_B
  (p_search_criteria_id            in     number
  ,p_object_version_number         in     number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_SAVED_SEARCH_A >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_SAVED_SEARCH_A
  (p_search_criteria_id            in     number
  ,p_object_version_number         in     number
);
--
end IRC_SEARCH_CRITERIA_BK3;

/
