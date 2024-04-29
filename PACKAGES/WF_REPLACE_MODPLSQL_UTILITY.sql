--------------------------------------------------------
--  DDL for Package WF_REPLACE_MODPLSQL_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_REPLACE_MODPLSQL_UTILITY" AUTHID CURRENT_USER as
/* $Header: WFMPLRMS.pls 120.2 2005/10/17 12:03:02 sramani noship $: */

TYPE rowid_varray is VARRAY(2000) of ROWID;

TYPE t_matches is record(
    id   rowid_varray,
    url  dbms_sql.varchar2_table
  );

procedure update_item_attr_vals(p_matches t_matches);

procedure update_ntf_attrs(p_matches t_matches);

procedure update_wf_attrs
(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY varchar2
);

end;

 

/
