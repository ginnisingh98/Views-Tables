--------------------------------------------------------
--  DDL for Package IRC_INO_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_INO_RKU" AUTHID CURRENT_USER as
/*$Header: irinorhi.pkh 120.0 2005/09/27 06:29:00 mmillmor noship $*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_note_id                      in number
  ,p_offer_status_history_id      in number
  ,p_note_text                    in varchar2
  ,p_object_version_number        in number
  ,p_offer_status_history_id_o    in number
  ,p_note_text_o                  in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_ino_rku;

 

/
