--------------------------------------------------------
--  DDL for Package GHR_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_HISTORY_API" AUTHID CURRENT_USER as
/* $Header: ghpahapi.pkh 120.1.12010000.1 2008/07/28 10:34:39 appldev ship $ */
	-- Constants
	g_peop_table		constant varchar2(30):='PER_PEOPLE_F';
	g_asgn_table		constant varchar2(30):='PER_ASSIGNMENTS_F';
	g_peopei_table		constant varchar2(30):='PER_PEOPLE_EXTRA_INFO';
	g_asgnei_table		constant varchar2(30):='PER_ASSIGNMENT_EXTRA_INFO';
	g_eleent_table		constant varchar2(30):='PAY_ELEMENT_ENTRIES_F';
	g_eleevl_table		constant varchar2(30):='PAY_ELEMENT_ENTRY_VALUES_F';
	g_posnei_table		constant varchar2(30):='PER_POSITION_EXTRA_INFO';
	g_addres_table		constant varchar2(30):='PER_ADDRESSES';
	g_perana_table		constant varchar2(30):='PER_PERSON_ANALYSES';
	g_posn_table		constant varchar2(30):='HR_ALL_POSITIONS_F';
	g_hist_date_format	constant varchar2(30):='yyyy/mm/dd hh24:mi:ss';

	g_ins_operation		constant varchar2(1):='I';
	g_upd_operation		constant varchar2(1):='U';
	g_del_operation		constant varchar2(1):='D';

	g_cancel			constant ghr_pa_requests.first_noa_cancel_or_Correct%type:='CANCEL';
	g_correct			constant ghr_pa_requests.first_noa_cancel_or_Correct%type:='CORRECT';

	Type operation_info_type is record
	(table_name		ghr_pa_history.table_name%type,
	 table_pk_id	ghr_pa_history.information1%type,
	 operation		varchar2(10),
	 row_id		rowid
	);

	Type table_operation_info_type is table of operation_info_type
	index by binary_integer;

	Type History_header_type is record
	(pa_history_id                   number(15),
	 pa_request_id              	   number(15),
	 process_date                    date,
	 effective_date                  date,
	 table_name                      varchar2(30),
	 table_pk_id                     number(15),
	 nature_of_action_id             number(15),
	 person_id                       per_people_f.person_id%type,
	 assignment_id                   per_assignments_f.assignment_id%type,
	 dml_operation	               varchar2(1)
	);

	Type pa_history_type is table of ghr_pa_history%rowtype
	index by binary_integer;

	Type g_session_var_type is record
	(pa_request_id				number,
	 noa_id   			  		number,
	 person_id					number(9),
       assignment_id				number(9),
	 position_id				number(15),
	 element_entry_id				number(15),
	 altered_pa_request_id			number,
	 noa_id_correct   			number,
	 pa_history_id				number,
	 date_effective				date,
	 program_name				varchar2(30),
	 fire_trigger				varchar2(1)
	);

-- End local procedure declaration

	Procedure get_g_session_var(
		p_pa_request_id 		 out nocopy number,
		p_noa_id 			 out nocopy number,
		p_altered_pa_request_id  out nocopy number,
		p_noa_id_correct 		 out nocopy number,
		p_person_id 		 out nocopy number,
		p_assignment_id 		 out nocopy number,
		p_date_effective		 out nocopy date);

	Procedure set_g_session_var( p_session_var in  g_session_var_type);
	Procedure get_g_session_var( p_session_var out nocopy g_session_var_type);

	Procedure set_g_session_var(
		p_pa_request_id 			in number	default null,
		p_noa_id 				in number	default null,
		p_altered_pa_request_id 	in number	default null,
		p_noa_id_correct 			in number	default null,
		p_person_id 			in number	default null,
		p_assignment_id 			in number	default null,
		p_date_effective			in date	default null);

	Procedure reinit_g_session_var;

	Procedure set_operation_info(
		p_program_name		in  varchar2				,
            p_date_effective 		in  date					,
		p_table_name 		in  ghr_pa_history.table_name%type  ,
		p_table_pk_id		in  ghr_pa_history.information1%type ,
		p_operation			in  varchar2,
		p_old_record_data       in  ghr_pa_history%rowtype,
		p_row_id			in  rowid
           );


	Function row_already_touched(p_row_id		in 	rowid) return boolean;

	Function add_row_operation_info_rg (
		p_table_name 		in ghr_pa_history.table_name%type,
		p_table_pk_id		in ghr_pa_history.information1%type,
		p_operation			in varchar2,
		p_row_id			in rowid)
	return binary_integer;

      -- Following procedure will hold the :old values
	Procedure add_row_pre_update_record_rg (
		p_pre_update_rg 		in ghr_pa_history%rowtype,
		p_ind				in binary_integer);

	Procedure post_update_process;

Procedure display_g_session_var;

Procedure fetch_history_info(
	p_table_name				in	varchar2	default null,
	p_table_pk_id				in	varchar2	default null,
	p_row_id					in	rowid		default null,
	p_person_id					in	number	default null,
	p_date_effective				in	date		default null,
	p_altered_pa_request_id			in	number	default null,
	p_noa_id_corrected			in	number	default null,
	p_pa_history_id				in	number	default null,
	p_hist_data 			  in out nocopy ghr_pa_history%rowtype,
	p_result_code			 out nocopy varchar2);

Procedure Post_forms_commit_process( p_eff_date in date);
Procedure New_form_instance_process;
Procedure get_session_date ( p_sess_date out nocopy     date);

End GHR_HISTORY_API;

/
