--------------------------------------------------------
--  DDL for Package GHR_MTO_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MTO_INT" AUTHID CURRENT_USER AS
/* $Header: ghmtoint.pkh 115.7 2003/08/04 07:33:18 ajose ship $ */

	g_package       constant varchar2(33) := '  ghr_mto_int.';
	g_log_enabled	 boolean := TRUE;

	-- when true some debugging goes through dbms_output, when false all
	-- goes through hr_utility.set_location
	g_dbms_output	 boolean := FALSE;

	procedure get_transfer_parameters(
					p_mass_transfer_id 	in  number,
					p_transfer_name		out nocopy varchar2,
					p_effective_date 		out nocopy date,
					p_inter_bg_transfer	out nocopy varchar2
	);

	procedure set_log_program_name(
					p_log_program_name		in varchar2
	);

	procedure log_message(
					p_procedure	in varchar2,
				   p_message	in varchar2
	);

	procedure mass_transfer_out(
					p_errbuf 		 out nocopy varchar2,
				   p_retcode 		 out nocopy number,
				   p_transfer_id   in  number,
				   p_person_id     in  per_all_people_f.person_id%type
	);

	procedure insert_people_f(
					p_transfer_name		varchar2,
					p_inter_bg_transfer	varchar2,
					p_effective_date		date,
					ppf 						per_all_people_f%rowtype
	);

	procedure insert_people_ei(
					p_transfer_name 	varchar2,
				   p_effective_date 	date,
				   pp_ei 				per_people_extra_info%rowtype
	);

	procedure insert_special_info(
					p_transfer_name	varchar2,
					p_effective_date	date,
					p_person_id			number,
					p_flex_name			varchar2,
					p_si					ghr_api.special_information_type
	);

	/*
	 * The parameters, p_contact_name, and p_contact_type should contain values
	 * when the address inserted is that of the contact, and be null otherwise
	 */
	procedure insert_address(
					p_transfer_name		in varchar2,
					p_effective_date		in date,
					p_a						in per_addresses%rowtype,
					p_contact_name			in varchar2	default null,
					p_contact_type			in varchar2	default null
	);

	procedure insert_assignment_f(
					p_transfer_name 		varchar2,
					p_effective_date		date,
					p_a						per_all_assignments_f%rowtype
	);

	procedure insert_assignment_ei(
					p_transfer_name 			varchar2,
				   p_person_id					number,
				   p_effective_date			date,
				   p_a_ei						per_assignment_extra_info%rowtype
	);

	procedure insert_position(
					p_transfer_name  varchar2,
				   p_person_id		  number,
					p_effective_date date,
					p_pos				  hr_all_positions_f%rowtype
	);

	procedure insert_position_ei(
					p_transfer_name		varchar2,
				   p_person_id				number,
				   p_effective_date		date,
				   p_pos_ei					per_position_extra_info%rowtype
	);

	procedure insert_position_defs(
					p_transfer_name		varchar2,
				   p_effective_date		date,
					p_person_id				number,
					p_flex_name				varchar2,
					p_pos_defs 				per_position_definitions%rowtype
	);

	procedure insert_element_entries(
				   p_transfer_name		varchar2,
					p_person_id				number,
					p_effective_date		date,
					p_element				in out nocopy ghr_mt_element_entries_v%rowtype
	);

	procedure  insert_misc(
					p_transfer_name		varchar2,
					p_person_id				number,
					p_effective_date		date,
					p_misc					ghr_mt_misc_v%rowtype
	);

	procedure update_people_f(
					p_transfer_name		varchar2,
				 	p_inter_bg_transfer	varchar2,
					p_effective_date		date,
					ppf 						per_all_people_f%rowtype
	);

	procedure update_people_ei(
				  p_transfer_name varchar2,
				  p_effective_date date,
				  pp_ei per_people_extra_info%rowtype
	);

	procedure update_special_info(
					p_transfer_name	varchar2,
					p_effective_date	date,
					p_person_id			number,
					p_flex_name			varchar2,
					p_si					ghr_api.special_information_type
	);

	procedure update_address(
					p_transfer_name		in varchar2,
					p_effective_date		in date,
					p_a						in per_addresses%rowtype,
					p_contact_name			in varchar2	default null,
					p_contact_type			in varchar2	default null
	);

	procedure update_assignment_f(
					p_transfer_name 		varchar2,
					p_effective_date		date,
					p_a						per_all_assignments_f%rowtype
	);

	procedure update_assignment_ei(
					p_transfer_name 			varchar2,
				   p_person_id					number,
				   p_effective_date			date,
				   p_a_ei	per_assignment_extra_info%rowtype
	);

	procedure  update_position(
					p_transfer_name  varchar2,
				   p_person_id		  number,
					p_effective_date date,
					p_pos				  hr_all_positions_f%rowtype
	);

	procedure update_position_ei(
					p_transfer_name		varchar2,
				   p_person_id			number,
					p_effective_date		date,
					p_pos_ei		per_position_extra_info%rowtype
	);

	procedure update_position_defs(
					p_transfer_name		varchar2,
				   p_effective_date		date,
					p_person_id			number,
					p_flex_name			varchar2,
					p_pos_defs per_position_definitions%rowtype
	);

	procedure update_element_entries(
					 p_transfer_name		varchar2,
					 p_person_id			number,
					 p_effective_date		date,
					 p_element				in out nocopy ghr_mt_element_entries_v%rowtype
	);

	procedure  update_misc(
					p_transfer_name		varchar2,
					p_person_id				number,
					p_effective_date		date,
					p_misc					ghr_mt_misc_v%rowtype
	);

	procedure put(
					p_message				varchar2
	);

	procedure put_line(
					p_message				varchar2 default null
	);

end ghr_mto_int;

 

/
