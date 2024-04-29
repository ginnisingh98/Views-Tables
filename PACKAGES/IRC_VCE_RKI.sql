--------------------------------------------------------
--  DDL for Package IRC_VCE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VCE_RKI" AUTHID CURRENT_USER as
/* $Header: irvcerhi.pkh 120.0 2005/07/26 15:19:36 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_vacancy_id                   in number
  ,p_variable_comp_lookup         in varchar2
  ,p_object_version_number        in number
  );
end irc_vce_rki;

 

/
