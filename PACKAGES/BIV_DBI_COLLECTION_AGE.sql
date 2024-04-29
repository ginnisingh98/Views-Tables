--------------------------------------------------------
--  DDL for Package BIV_DBI_COLLECTION_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DBI_COLLECTION_AGE" AUTHID CURRENT_USER as
/* $Header: bivsrvcages.pls 115.0 2004/02/24 00:35:52 kreardon noship $ */

procedure load_backlog_aging
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2);

end biv_dbi_collection_age;

 

/
