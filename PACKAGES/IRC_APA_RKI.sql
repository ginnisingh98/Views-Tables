--------------------------------------------------------
--  DDL for Package IRC_APA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APA_RKI" AUTHID CURRENT_USER as
/* $Header: iraparhi.pkh 120.0.12000000.1 2007/03/23 12:12:07 vboggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_apl_profile_access_id        in number
  ,p_person_id                    in number
  ,p_object_version_number        in number
  );
end irc_apa_rki;

 

/
