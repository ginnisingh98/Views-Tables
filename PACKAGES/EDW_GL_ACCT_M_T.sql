--------------------------------------------------------
--  DDL for Package EDW_GL_ACCT_M_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_GL_ACCT_M_T" AUTHID CURRENT_USER AS
/* $Header: EDWVBHCS.pls 120.0 2005/05/31 18:21:31 appldev noship $ */

g_status boolean;
g_conc_program_id number:=0;
g_conc_program_name varchar2(200);
g_execute_flag boolean;
G_COMPLETION_STATUS integer;
g_dimension_name VARCHAR2(255);
g_vbh_temp_table_name  VARCHAR2(30);
g_global_temp_table varchar2(30);

type t_acct_type_root_rec is record (
name  edw_vbh_temp1.parent%type,
type  edw_segment_classes.type%type);

type t_acct_type_root_table is table of t_acct_type_root_rec
index by binary_integer;

g_acct_type_root1 t_acct_type_root_table;
g_acct_type_root2 t_acct_type_root_table;



Procedure Collect(Errbuf         out NOCOPY Varchar2,
                  Retcode        out NOCOPY Varchar2,
                  p_dimension_name   in Varchar2);

-- added for bug 4124723
Procedure create_dim_levels_mv (p_dim_no IN varchar2);

End EDW_GL_ACCT_M_T;

 

/
