--------------------------------------------------------
--  DDL for Package IRC_LCV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LCV_RKU" AUTHID CURRENT_USER as
/* $Header: irlcvrhi.pkh 120.0 2005/10/03 14:58:16 rbanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_location_criteria_value_id   in number
  ,p_search_criteria_id           in number
  ,p_derived_locale               in varchar2
  ,p_object_version_number        in number
  ,p_search_criteria_id_o         in number
  ,p_derived_locale_o             in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_lcv_rku;

 

/
