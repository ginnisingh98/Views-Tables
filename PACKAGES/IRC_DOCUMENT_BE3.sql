--------------------------------------------------------
--  DDL for Package IRC_DOCUMENT_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DOCUMENT_BE3" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:52
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_document_a (
p_effective_date               date,
p_document_id                  number,
p_object_version_number        number,
p_person_id                    number,
p_party_id                     number,
p_end_date                     date,
p_type                         varchar2,
p_purge                        varchar2);
end irc_document_be3;

/
