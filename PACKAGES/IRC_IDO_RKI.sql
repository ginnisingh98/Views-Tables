--------------------------------------------------------
--  DDL for Package IRC_IDO_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IDO_RKI" AUTHID CURRENT_USER as
/* $Header: iridorhi.pkh 120.2.12010000.2 2008/08/05 10:48:35 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_document_id                  in number
  ,p_party_id                     in number
  ,p_person_id                    in number
  ,p_assignment_id                in number
  ,p_file_name                    in varchar2
  ,p_file_format                  in varchar2
  ,p_mime_type                    in varchar2
  ,p_description                  in varchar2
  ,p_type                         in varchar2
  ,p_object_version_number        in number
  ,p_end_date			  in Date
  );
end irc_ido_rki;

/
