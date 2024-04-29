--------------------------------------------------------
--  DDL for Package IRC_APA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APA_RKD" AUTHID CURRENT_USER as
/* $Header: iraparhi.pkh 120.0.12000000.1 2007/03/23 12:12:07 vboggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_apl_profile_access_id        in number
  ,p_person_id_o                  in number
  ,p_object_version_number_o      in number
  );
--
end irc_apa_rkd;

 

/
