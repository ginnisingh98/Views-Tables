--------------------------------------------------------
--  DDL for Package IRC_LCV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LCV_RKD" AUTHID CURRENT_USER as
/* $Header: irlcvrhi.pkh 120.0 2005/10/03 14:58:16 rbanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_location_criteria_value_id   in number
  ,p_search_criteria_id_o         in number
  ,p_derived_locale_o             in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_lcv_rkd;

 

/
