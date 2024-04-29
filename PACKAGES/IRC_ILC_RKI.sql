--------------------------------------------------------
--  DDL for Package IRC_ILC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ILC_RKI" AUTHID CURRENT_USER as
/* $Header: irilcrhi.pkh 120.0.12010000.1 2010/03/17 14:11:58 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date         in date
  ,p_link_id                in number
  ,p_target_party_id        in number
  ,p_duplicate_set_id       in number
  ,p_status                 in varchar2
  ,p_party_id               in number
  ,p_object_version_number  in number
  );
end irc_ilc_rki;

/
