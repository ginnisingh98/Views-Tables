--------------------------------------------------------
--  DDL for Package BSC_AW_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_MANAGEMENT" AUTHID CURRENT_USER AS
/*$Header: BSCAWMGS.pls 120.8 2006/03/31 13:28 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_attached boolean;--is the aw workspace attached or not
g_attached_mode varchar2(80);/*RO,RW,Multi */
g_locked_objects dbms_sql.varchar2_table;--used to update, release and commit (10g)
--
type current_sessions_r is record(
sid number,
serial number,
attach_mode varchar2(40)
);
type current_sessions_tb is table of current_sessions_r index by pls_integer;
--
type lock_sets_r is record(
lock_set varchar2(100),
locked_objects dbms_sql.varchar2_table
);
type lock_sets_tv is table of lock_sets_r index by varchar2(100);
g_lock_set lock_sets_tv;
--procedures-------------------------------------------------------
procedure get_workspace_lock(p_objects dbms_sql.varchar2_table,p_options varchar2);
procedure get_workspace_lock(p_mode varchar2,p_options varchar2);
procedure get_lock(p_mode varchar2,p_options varchar2);
procedure get_lock(p_name varchar2,p_mode varchar2,p_locked_objects dbms_sql.varchar2_table);
procedure get_lock(p_locked_objects dbms_sql.varchar2_table,p_options varchar2);
function get_aw_workspace_name return varchar2;
procedure detach_workspace;
procedure detach_workspace(p_workspace varchar2);
procedure commit_aw;
procedure commit_aw(p_options varchar2);
procedure create_workspace(p_options varchar2);
procedure create_workspace(p_name varchar2,p_options varchar2);
procedure drop_workspace(p_options varchar2);
procedure drop_workspace(p_name varchar2,p_options varchar2);
procedure exec_workspace_settings;
procedure release_lock(p_object varchar2) ;
procedure commit_aw_multi;
procedure commit_aw_multi(p_locked_objects dbms_sql.varchar2_table);
procedure commit_aw(p_locked_objects dbms_sql.varchar2_table);
procedure commit_aw(p_locked_objects dbms_sql.varchar2_table,p_options varchar2);
procedure release_lock(p_objects dbms_sql.varchar2_table) ;
procedure get_lock_object(p_object varchar2,p_resync varchar2,p_wait varchar2);
procedure create_default_elements;
procedure set_hash_partition_dim;
procedure attach_workspace(p_name varchar2,p_mode varchar2);
procedure save_lock_set(p_set_name varchar2);
procedure lock_lock_set(p_set_name varchar2,p_options varchar2);
procedure commit_lock_set(p_set_name varchar2,p_options varchar2);
procedure detach_aw_workspace(p_workspace varchar2);
procedure update_aw;
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_MANAGEMENT;

 

/
