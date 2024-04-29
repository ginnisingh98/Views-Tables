--------------------------------------------------------
--  DDL for Package IRC_APS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APS_RKI" AUTHID CURRENT_USER as
/* $Header: irapsrhi.pkh 120.0.12000000.1 2007/03/23 12:02:09 vboggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_profile_snapshot_id          in number
  ,p_person_id                    in number
  ,p_object_version_number        in number
  );
end irc_aps_rki;

 

/
