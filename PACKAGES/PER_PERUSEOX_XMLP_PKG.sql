--------------------------------------------------------
--  DDL for Package PER_PERUSEOX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERUSEOX_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERUSEOXS.pls 120.0 2007/12/28 06:59:32 srikrish noship $ */
	P_HIERARCHY_VERSION_ID	number;
	P_PAYROLL_PERIOD_DATE_START	varchar2(32767);
	P_PAYROLL_PERIOD_DATE_START_1 DATE;
	P_BUSINESS_GROUP_ID	number;
	P_HIERARCHY_ID	number;
	P_REPORT_YEAR	varchar2(4);
	P_PAYROLL_PERIOD_DATE_END	varchar2(32767);
	P_PAYROLL_PERIOD_DATE_END_1 DATE;
	P_PAYROLL_PERIOD_DATE	varchar2(32767);
	P_CONC_REQUEST_ID	number;
	P_AUDIT_REPORT	varchar2(1);
	CP_no_rows	number := 0 ;
	CP_Emp_Name	varchar2(150);
	CP_Emp_Num	varchar2(150);
	CP_Gender	varchar2(150);
	CP_Location	varchar2(500);
	CP_Job_Cat	varchar2(150);
	CP_Ethnic	varchar2(150);
	CP_Emp_Cat	varchar2(150);
	CP_ass_type	varchar2(60);
	CP_Reason	varchar2(500);
	CP_display	number ;
	c_business_group_name	varchar2(60);
	c_hierarchy_name	varchar2(40);
	c_hierarchy_version_num	number;
	c_parent_org_id	number;
	c_parent_node_id	number;
	c_ass_loc	number := 0 ;
	c_report_date	date;
	c_report_year	varchar2(4);
	function BeforeReport return boolean  ;
	function P_REPORT_YEARValidTrigger return boolean  ;
	function AfterReport return boolean  ;
	--function cf_set_detailsformula(person_id in number, report_date_end in date) return number  ;
	function cf_set_detailsformula(person_id1 in number, report_date_end in date, ASS_LOC in number, location_id in number, address1 in varchar2) return number;
	Function CP_no_rows_p return number;
	Function CP_Emp_Name_p return varchar2;
	Function CP_Emp_Num_p return varchar2;
	Function CP_Gender_p return varchar2;
	Function CP_Location_p return varchar2;
	Function CP_Job_Cat_p return varchar2;
	Function CP_Ethnic_p return varchar2;
	Function CP_Emp_Cat_p return varchar2;
	Function CP_ass_type_p return varchar2;
	Function CP_Reason_p return varchar2;
	Function CP_display_p return number;
	Function c_business_group_name_p return varchar2;
	Function c_hierarchy_name_p return varchar2;
	Function c_hierarchy_version_num_p return number;
	Function c_parent_org_id_p return number;
	Function c_parent_node_id_p return number;
	Function c_ass_loc_p return number;
	Function c_report_date_p return date;
	Function c_report_year_p return varchar2;
END PER_PERUSEOX_XMLP_PKG;

/
