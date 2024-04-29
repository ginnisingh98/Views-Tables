--------------------------------------------------------
--  DDL for Package ISC_DBI_BSA_OBJECTS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_BSA_OBJECTS_C" AUTHID CURRENT_USER as
/* $Header: ISCSCFAS.pls 120.0 2005/08/30 14:13:07 scheung noship $ */

  procedure load_fact(errbuf      		in out nocopy varchar2,
                      retcode     		in out nocopy varchar2);

  procedure update_fact(errbuf      		in out nocopy varchar2,
                      retcode     		in out nocopy varchar2);

end isc_dbi_bsa_objects_c;

 

/
