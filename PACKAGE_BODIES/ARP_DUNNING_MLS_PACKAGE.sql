--------------------------------------------------------
--  DDL for Package Body ARP_DUNNING_MLS_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DUNNING_MLS_PACKAGE" as
/* $Header: ARDUNMLB.pls 115.1 99/07/16 23:57:48 porting s $ */

FUNCTION ARP_DUNNING_MLS_FUNCTION return varchar2
as
base_language varchar2(4);

begin

    select language_code
    into   base_language
    from   fnd_languages
    where  installed_flag = 'B';

return base_language;

end ARP_DUNNING_MLS_FUNCTION;

end ARP_DUNNING_MLS_PACKAGE;

/
