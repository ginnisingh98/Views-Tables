--------------------------------------------------------
--  DDL for Package IRC_IDO_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IDO_RKD" AUTHID CURRENT_USER as
/* $Header: iridorhi.pkh 120.2.12010000.2 2008/08/05 10:48:35 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_document_id                  in number
  ,p_party_id_o                   in number
  ,p_person_id_o                  in number
  ,p_assignment_id_o              in number
  ,p_file_name_o                  in varchar2
  ,p_file_format_o                in varchar2
  ,p_mime_type_o                  in varchar2
  ,p_description_o                in varchar2
  ,p_type_o                       in varchar2
  ,p_object_version_number_o      in number
  ,p_end_date_o			  in Date
  );
--
end irc_ido_rkd;

/
