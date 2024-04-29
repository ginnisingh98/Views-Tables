--------------------------------------------------------
--  DDL for Package IRC_INO_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_INO_RKI" AUTHID CURRENT_USER as
/*$Header: irinorhi.pkh 120.0 2005/09/27 06:29:00 mmillmor noship $*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_note_id                      in number
  ,p_offer_status_history_id      in number
  ,p_note_text                    in varchar2
  ,p_object_version_number        in number
  );
end irc_ino_rki;

 

/
