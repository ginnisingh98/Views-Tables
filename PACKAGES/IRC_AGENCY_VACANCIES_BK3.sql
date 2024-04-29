--------------------------------------------------------
--  DDL for Package IRC_AGENCY_VACANCIES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_AGENCY_VACANCIES_BK3" AUTHID CURRENT_USER as
/* $Header: iriavapi.pkh 120.2 2008/02/21 14:08:33 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <BUS_PROCESS_NAME>_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_AGENCY_VACANCY_b
      (p_agency_vacancy_id         number
      ,p_object_version_number     number
      );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <BUS_PROCESS_NAME>_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_AGENCY_VACANCY_a
      (p_agency_vacancy_id          number
      ,p_object_version_number      number
      );
--
end IRC_AGENCY_VACANCIES_BK3;



/
