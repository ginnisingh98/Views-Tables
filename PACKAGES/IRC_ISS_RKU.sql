--------------------------------------------------------
--  DDL for Package IRC_ISS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ISS_RKU" AUTHID CURRENT_USER as
/* $Header: irissrhi.pkh 120.0.12000000.1 2007/03/23 11:38:34 vboggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_saved_search_criteria_id     in number
  ,p_vacancy_id                   in number
  ,p_object_version_number        in number
  ,p_vacancy_id_o                 in number
  ,p_object_version_number_o      in number
  );
--
end irc_iss_rku;

 

/
