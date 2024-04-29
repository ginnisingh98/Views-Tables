--------------------------------------------------------
--  DDL for Package IRC_SAVED_SEARCH_CRITERIA_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SAVED_SEARCH_CRITERIA_BK2" AUTHID CURRENT_USER as
/* $Header: irissapi.pkh 120.1 2008/02/21 14:26:50 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_search_criteria_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_search_criteria_b
  (p_vacancy_id				in     number
  ,p_saved_search_criteria_id           in     number
  ,p_object_version_number		in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_search_criteria_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_search_criteria_a
  (p_vacancy_id				in     number
  ,p_saved_search_criteria_id           in     number
  ,p_object_version_number		in     number
  );
--
end irc_saved_search_criteria_bk2;

/
