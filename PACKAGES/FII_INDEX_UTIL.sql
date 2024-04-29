--------------------------------------------------------
--  DDL for Package FII_INDEX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_INDEX_UTIL" AUTHID CURRENT_USER as
/* $Header: FIIIDUTS.pls 115.3 2004/08/10 23:49:26 phu noship $*/

-- materialized view name defaulted to fii_gl_summary_mv

g_tab_name varchar2(100);
g_owner    varchar2(100);
g_debug_msg varchar2(500):=NULL;

procedure drop_index (p_table_name VARCHAR2, p_owner VARCHAR2,
                      p_retcode  in out NOCOPY Varchar2);

procedure create_index (p_table_name VARCHAR2, p_owner VARCHAR2,
                        p_retcode  in out NOCOPY Varchar2);

end fii_index_util;

 

/
