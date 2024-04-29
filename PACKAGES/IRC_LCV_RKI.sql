--------------------------------------------------------
--  DDL for Package IRC_LCV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LCV_RKI" AUTHID CURRENT_USER as
/* $Header: irlcvrhi.pkh 120.0 2005/10/03 14:58:16 rbanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_location_criteria_value_id   in number
  ,p_search_criteria_id           in number
  ,p_derived_locale               in varchar2
  ,p_object_version_number        in number
  );
end irc_lcv_rki;

 

/
