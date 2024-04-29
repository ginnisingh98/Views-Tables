--------------------------------------------------------
--  DDL for Package BIV_DBI_COLLECTION_INC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DBI_COLLECTION_INC" AUTHID CURRENT_USER as
/* $Header: bivsrvcincs.pls 115.1 2003/10/19 21:25:05 kreardon noship $ */

procedure incremental_load
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2 );

procedure incremental_log
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2);

end biv_dbi_collection_inc;

 

/
