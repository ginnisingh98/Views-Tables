--------------------------------------------------------
--  DDL for Package IRC_PARTY_PERSON_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PARTY_PERSON_UTL" AUTHID CURRENT_USER as
/* $Header: irptpeul.pkh 120.0 2005/07/26 15:16:06 mbocutt noship $ */
procedure update_party_records(p_mode varchar2 default 'BASIC');
--
procedure update_party_conc(errbuf  out nocopy varchar2
                           ,retcode out nocopy varchar2);
end irc_party_person_utl;

 

/
