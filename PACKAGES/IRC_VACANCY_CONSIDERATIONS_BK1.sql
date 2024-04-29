--------------------------------------------------------
--  DDL for Package IRC_VACANCY_CONSIDERATIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VACANCY_CONSIDERATIONS_BK1" AUTHID CURRENT_USER as
/* $Header: irivcapi.pkh 120.2.12010000.1 2008/07/28 12:46:49 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_VACANCY_CONSIDERATION_B >---------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_VACANCY_CONSIDERATION_B
  (
   p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_consideration_status          in     varchar2
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_VACANCY_CONSIDERATION_A >---------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_VACANCY_CONSIDERATION_A
  (
   p_vacancy_consideration_id      in     number
  ,p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_consideration_status          in     varchar2
  ,p_object_version_number         in     number
  ,p_effective_date                in     date
  );
--
end IRC_VACANCY_CONSIDERATIONS_BK1;

/
