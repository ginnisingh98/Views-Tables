--------------------------------------------------------
--  DDL for Package IRC_APS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APS_RKD" AUTHID CURRENT_USER as
/* $Header: irapsrhi.pkh 120.0.12000000.1 2007/03/23 12:02:09 vboggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_profile_snapshot_id          in number
  ,p_person_id_o                  in number
  ,p_object_version_number_o      in number
  );
--
end irc_aps_rkd;

 

/
