--------------------------------------------------------
--  DDL for Package BIV_DBI_COLLECTION_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DBI_COLLECTION_INIT" AUTHID CURRENT_USER as
/* $Header: bivsrvcints.pls 120.0 2005/05/24 18:03:08 appldev noship $ */

procedure setup
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2
, p_load_to in varchar2 default fnd_date.date_to_canonical(sysdate)
, p_force in varchar2 default 'N' );

procedure load_activity
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2);

procedure load_closed
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2);

procedure load_backlog
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2);

procedure load_resolved
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2);

procedure wrapup
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2);

end biv_dbi_collection_init;

 

/
