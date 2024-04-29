--------------------------------------------------------
--  DDL for Package IRC_VACANCY_CONSIDERATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VACANCY_CONSIDERATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: irivcapi.pkh 120.2.12010000.1 2008/07/28 12:46:49 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_VACANCY_CONSIDERATION_B >---------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_VACANCY_CONSIDERATION_B
  (p_vacancy_consideration_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_VACANCY_CONSIDERATION_A >---------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_VACANCY_CONSIDERATION_A
  (p_vacancy_consideration_id      in     number
  ,p_object_version_number         in     number
  );
--
end IRC_VACANCY_CONSIDERATIONS_BK3;

/
