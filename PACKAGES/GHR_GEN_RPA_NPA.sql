--------------------------------------------------------
--  DDL for Package GHR_GEN_RPA_NPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_GEN_RPA_NPA" AUTHID CURRENT_USER AS
/* $Header: ghgenpa.pkh 120.0.12010000.1 2008/07/28 10:31:14 appldev ship $ */
-- ============================================================================
--                        << Procedure: execute_mt >>
--  Description:
--  	This procedure is called from concurrent program. This procedure will
--  determine the batch size and call sub programs.
-- ============================================================================
	TYPE t_rpa_misc_fields IS RECORD
	(
	action_requested GHR_FAMILIES.NAME%TYPE,
	additional_info_name VARCHAR2(200),
	requested_by VARCHAR2(200),
	authorized_by VARCHAR2(200),
	employee_name VARCHAR2(200),
	appropriation_code varchar2(100),
	from_position_org_lines VARCHAR2(1000),
	to_position_org_lines VARCHAR2(1000),
	agency_code_use VARCHAR2(250),
	agency_data40 VARCHAR2(250),
	agency_data41 VARCHAR2(250),
	agency_data42 VARCHAR2(250),
	agency_data43 VARCHAR2(250),
	agency_data44 VARCHAR2(250),
	veterance_preference_for_rif_y VARCHAR2(1),
	veterance_preference_for_rif_n VARCHAR2(1),
	requesting_office_rem_flag_y VARCHAR2(1),
	requesting_office_rem_flag_n VARCHAR2(1),
	forwarding_city VARCHAR2(1000),
	remarks_concat VARCHAR2(1000),
	from_tot_sal_or_awd VARCHAR2(50),
	to_tot_sal_or_awd VARCHAR2(50)
	);

	TYPE t_remarks IS RECORD
	(
	remarks_desc ghr_pa_remarks.description%type,
	remark_code ghr_remarks.code%type);

	-- Type for RPA/NPA Tags
	TYPE t_report_tags IS RECORD
	(
	tag_name VARCHAR2(50),
	par_field_value VARCHAR2(1000));

	TYPE t_signatures IS RECORD
	(
	office_function varchar2(100),
	office_signature varchar2(100),
	office_date varchar2(100));

/**************************************For Populating RPA **************************************/
	TYPE t_rpa_misc_fields_rec IS TABLE OF t_rpa_misc_fields INDEX BY BINARY_INTEGER;
	TYPE t_report_tags_rec IS TABLE OF t_report_tags INDEX BY BINARY_INTEGER;
	TYPE t_signature_rec IS TABLE OF t_signatures INDEX BY BINARY_INTEGER;
	TYPE t_remarks_rec IS TABLE OF t_remarks INDEX BY BINARY_INTEGER;

	PROCEDURE Generate_RPA(p_pa_request_id  ghr_pa_requests.pa_request_id%type,  p_view_type VARCHAR2, p_xml_string OUT NOCOPY CLOB);
	PROCEDURE Populate_RPAtags(p_pa_request_rec IN ghr_pa_requests%ROWTYPE,
								p_rpa_misc_fields t_rpa_misc_fields_rec,
								p_signature_rec t_signature_rec);
	PROCEDURE CondPrinting_RPA(p_pa_request_rec_in IN ghr_pa_requests%rowtype,
                       p_pa_request_rec_out OUT NOCOPY ghr_pa_requests%rowtype);
	PROCEDURE WritetoXML(p_report_name IN VARCHAR2,
					  p_xml_string	OUT NOCOPY CLOB);

/**************************************For Populating NPA **************************************/
	TYPE t_npa_misc_fields IS RECORD
	(
	appropriation_code varchar2(100),
	from_position_org_lines VARCHAR2(1000),
	sf50_approval_date VARCHAR2(15),
	approval_date VARCHAR2(15),
	employee_name VARCHAR2(200),
	to_position_org_lines VARCHAR2(1000),
	veterance_preference_for_rif_y VARCHAR2(1),
	veterance_preference_for_rif_n VARCHAR2(1),
	remarks_concat VARCHAR2(1000),
	agency_code_use VARCHAR2(250),
	agency_data40 VARCHAR2(250),
	agency_data41 VARCHAR2(250),
	agency_data42 VARCHAR2(250),
	agency_data43 VARCHAR2(250),
	agency_data44 VARCHAR2(250),
	emp_dept_or_agency VARCHAR2(250),
	from_tot_sal_or_awd VARCHAR2(50),
	to_tot_sal_or_awd VARCHAR2(50)
	);

	TYPE t_npa_misc_fields_rec IS TABLE OF t_npa_misc_fields INDEX BY BINARY_INTEGER;

	PROCEDURE Generate_NPA(p_pa_request_id  ghr_pa_requests.pa_request_id%type,  p_view_type VARCHAR2, p_xml_string OUT NOCOPY CLOB);
	PROCEDURE Populate_NPAtags(p_pa_request_rec IN ghr_pa_requests%ROWTYPE,
								p_npa_misc_fields t_npa_misc_fields_rec);
	PROCEDURE CondPrinting_NPA(p_pa_request_rec_in IN ghr_pa_requests%rowtype,
                       p_pa_request_rec_out OUT NOCOPY ghr_pa_requests%rowtype);
	PROCEDURE Get_Template(p_program_name fnd_lobs.program_name%type, p_template OUT NOCOPY BLOB);
	PROCEDURE Debug(p_id NUMBER, p_statement VARCHAR2);

END GHR_GEN_RPA_NPA;

/
