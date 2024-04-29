--------------------------------------------------------
--  DDL for Package IRC_DOCUMENT_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DOCUMENT_BE2" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:52
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_document_a (
p_effective_date               date,
p_document_id                  number,
p_type                         varchar2,
p_mime_type                    varchar2,
p_file_name                    varchar2,
p_description                  varchar2,
p_object_version_number        number);
end irc_document_be2;

/
