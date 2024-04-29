--------------------------------------------------------
--  DDL for Package BEN_DM_CREATE_CONTROL_FILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_CREATE_CONTROL_FILES" AUTHID CURRENT_USER AS
/* $Header: benfdmmctl.pkh 120.1 2006/05/04 07:03:37 nkkrishn noship $ */

procedure get_no_of_inp_files
(p_dir_name             in   varchar2,
 p_data_file            in   varchar2,
 p_no_of_files          out  nocopy number);

procedure main
(
 p_dir_name             in   varchar2,
 p_no_of_threads        in   number,
 p_transfer_file        in   varchar2 default null,
 p_data_file             in   varchar2 default null
);

procedure rebuild_indexes;

function set_dm_flag(p_person_id number)
return number;

procedure touch_files
(
 p_dir_name             in   varchar2,
 p_no_of_threads        in   number,
 p_data_file            in   varchar2,
 p_file_type            in   varchar2 default 'out');

end ben_dm_create_control_files;

 

/
