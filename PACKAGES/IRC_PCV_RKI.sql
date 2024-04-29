--------------------------------------------------------
--  DDL for Package IRC_PCV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PCV_RKI" AUTHID CURRENT_USER as
/* $Header: irpcvrhi.pkh 120.0 2005/10/03 14:59:20 rbanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_prof_area_criteria_value_id  in number
  ,p_search_criteria_id           in number
  ,p_professional_area            in varchar2
  ,p_object_version_number        in number
  );
end irc_pcv_rki;

 

/
