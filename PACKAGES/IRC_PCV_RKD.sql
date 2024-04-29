--------------------------------------------------------
--  DDL for Package IRC_PCV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PCV_RKD" AUTHID CURRENT_USER as
/* $Header: irpcvrhi.pkh 120.0 2005/10/03 14:59:20 rbanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_prof_area_criteria_value_id  in number
  ,p_search_criteria_id_o         in number
  ,p_professional_area_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_pcv_rkd;

 

/
