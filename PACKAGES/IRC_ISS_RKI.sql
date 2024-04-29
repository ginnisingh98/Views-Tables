--------------------------------------------------------
--  DDL for Package IRC_ISS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ISS_RKI" AUTHID CURRENT_USER as
/* $Header: irissrhi.pkh 120.0.12000000.1 2007/03/23 11:38:34 vboggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_saved_search_criteria_id     in number
  ,p_vacancy_id                   in number
  ,p_object_version_number        in number
  );
end irc_iss_rki;

 

/
