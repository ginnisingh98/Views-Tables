--------------------------------------------------------
--  DDL for Package EDW_SEC_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SEC_POLICY" AUTHID CURRENT_USER as
/* $Header: EDWSPLCS.pls 120.0 2005/06/01 15:52:57 appldev noship $*/
procedure attach_policy(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2, fact_table_name varchar2);
procedure detach_policy(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2,fact_table_name varchar2);
procedure attach_default_policy(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2, fact_table_name varchar2);
procedure detach_default_policy(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2,fact_table_name varchar2);
--code added for bug 3871867.. we can use fnd_installaton api to get apps schema name
CURSOR cApps IS
    SELECT ORACLE_USERNAME from fnd_oracle_userid where oracle_id=900;
END edw_sec_policy;

 

/
