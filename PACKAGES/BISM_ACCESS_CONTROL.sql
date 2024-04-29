--------------------------------------------------------
--  DDL for Package BISM_ACCESS_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISM_ACCESS_CONTROL" AUTHID CURRENT_USER AS
/* $Header: bibacls.pls 115.5 2004/02/13 00:34:11 gkellner noship $ */
function check_list_access(fid raw,myid raw) return varchar2;
function check_ins_access(fid raw,myid raw) return varchar2;
function check_upd_access(oid raw,fid raw,is_record_a_folder varchar2,curr_user_id raw) return varchar2;
function check_read_access(oid raw,fid raw,current_selection_is_folder varchar2,curr_user_id raw) return varchar2;
function check_del_access(oid raw,fid raw,is_folder varchar2,name varchar2,curr_user_id raw) return varchar2;
function check_fullcontrol_access(oid raw,myid raw) return varchar2;
function check_show_entries_access(oid raw,myid raw) return varchar2;
function dummy_op(oid raw,myid raw) return varchar2;
function dummy_op2(oid raw,fid raw,current_selection_is_folder varchar2,myid raw) return varchar2;
END bism_access_control ;

 

/
