--------------------------------------------------------
--  DDL for Package BEN_BENLESUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENLESUM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENLESUMS.pls 120.1 2007/12/10 08:36:52 vjaganat noship $ */
--Display elements added
	T_RUN_DATE	varchar2(40);
	T_COMP_PERD_STRT_DT	varchar2(40);
	T_COMP_PERD_END_DT	varchar2(40);
	T_REPT_PERD_STRT_DT	varchar2(40);
	T_REPT_PERD_END_DT	varchar2(40);
	T_CONC_REQUEST_ID	number;
	P_BUSINESS_GROUP_ID	number;
	P_REPT_PERD_STRT_DT	date;
	P_REPT_PERD_END_DT	date;
	P_PERSON_ID	number;
	P_BENEFIT_GROUP_ID	number;
	P_RUN_DATE	date;
	P_LER_ID	number;
	P_LER_TYPE	varchar2(40);
	P_LOCATION_ID	number;
	P_ASSIGNMENT_TYPE	varchar2(10);
	P_ORGANIZATION_ID	number;
	P_COMP_PERD_STRT_DT	date;
	P_COMP_PERD_END_DT	date;
	P_REPORTING_GROUP_ID	number;
	P_PL_ID	number;
	P_REPORT_MODULE_CD	varchar2(40);
	p_sort	varchar2(2000);
	p_sort1	varchar2(2000); --Added during DT Fixes
	P_SORT_order_1	varchar2(100);
	P_sort_order_2	varchar2(100);
	P_sort_order_3	varchar2(100);
	P_sort_order_4	varchar2(100);
	P_NAT_IDENT	varchar2(100);
	P_ERROR	varchar2(2000);
	P_RUN_REPORT	varchar2(1) := 'Y';
	P_DATE_mask	varchar2(50);
	P_conc_request_id	number;
	P_user_sort	varchar2(200);
	P_disp_flex_fields_flag	varchar2(1);
	P_RPTG_GRP_ID	varchar2(40);
	P_sort_DFF	varchar2(200);
	P_sort_DFF2	varchar2(200); --Added during DT Fixes
	P_sort_DFF3	varchar2(200); --Added during DT Fixes
	CP_detected_name_potnl_rep	number;
	CP_unprocessed_name_potnl_rep	number;
	CP_processed_name_potnl_rep	number;
	CP_total_name_potnl_rep	number;
	CP_voided_name_potnl_rep	number;
	CP_settomanual_name_potnl_rep	number;
	CP_manover_name_potnl_rep	number;
	CP_detected_name_potnl_comp	number;
	CP_unprocessed_name_potnl_comp	number;
	CP_processed_name_potnl_comp	number;
	CP_total_name_potnl_comp	number;
	CP_voided_name_potnl_comp	number;
	CP_settomanual_name_potnl_comp	number;
	CP_manover_name_potnl_comp	number;
	CP_started_name_proc_rep	number;
	CP_processed_name_proc_rep	number;
	CP_backedout_name_proc_rep	number;
	CP_voided_name_proc_rep	number;
	CP_total_name_proc_rep	number;
	CP_started_name_proc_comp	number;
	CP_processed_name_proc_comp	number;
	CP_backedout_name_proc_comp	number;
	CP_voided_name_proc_comp	number;
	CP_total_name_proc_comp	number;
	CP_report_module_name	varchar2(300);
	CP_asg_type	varchar2(300);
	CP_ler_type	varchar2(300);
	CP_business_group_name	varchar2(300);
	CP_location_name	varchar2(300);
	CP_organization_name	varchar2(300);
	CP_reporting_group_name	varchar2(300);
	CP_benefit_group_name	varchar2(300);
	CP_pln_name	varchar2(300);
	CP_ler_name	varchar2(300);
	CP_person_name	varchar2(300);
	CP_nat_ident	varchar2(100);
	CP_displ_flex	varchar2(30);
	CP_rept_strt_end_dt	varchar2(40);
	CP_comp_strt_end_dt	varchar2(40);
	function cf_transfer_valuesformula(CS_detected_name_potnl_rep in number,
	CS_unprocessed_name_potnl_rep in number, CS_processed_name_potnl_rep in number,
	CS_voided_name_potnl_rep in number, CS_settoman_name_potnl_rep in number,
	CS_manover_name_potnl_rep in number, CS_total_name_potnl_rep in number,
CS_detected_name_potnl_comp in number, CS_unprocessed_name_potnl_comp in number,
CS_processed_name_potnl_comp in number, CS_voided_name_potnl_comp in number,
CS_settoman_name_potnl_comp in number, CS_manover_name_potnl_comp in number,
CS_total_name_potnl_comp in number, CS_started_name_processed_rep in number,
CS_proc_name_processed_rep in number, CS_backedout_name_proc_rep in number,
CS_voided_name_proc_rep in number, CS_total_name_proc_rep in number,
CS_started_name_processed_comp in number, CS_proc_name_processed_comp in number,
CS_backedout_name_proc_comp in number, CS_voided_name_proc_comp in number, CS_total_name_proc_comp in number) return number  ;
	function AfterPForm return boolean ;
	PROCEDURE append_order_by(colname varchar2)  ;
	FUNCTION FIND_COL(col_name varchar2) RETURN varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function CP_detected_name_potnl_rep_p return number;
	Function CP_unprocessed_name_potnl_rep1 return number;
	Function CP_processed_name_potnl_rep_p return number;
	Function CP_total_name_potnl_rep_p return number;
	Function CP_voided_name_potnl_rep_p return number;
	Function CP_settomanual_name_potnl_rep1 return number;
	Function CP_manover_name_potnl_rep_p return number;
	Function CP_detected_name_potnl_comp_p return number;
	Function CP_unprocessed_name_potnl_com return number;
	Function CP_processed_name_potnl_comp_p return number;
	Function CP_total_name_potnl_comp_p return number;
	Function CP_voided_name_potnl_comp_p return number;
	Function CP_settomanual_name_potnl_com return number;
	Function CP_manover_name_potnl_comp_p return number;
	Function CP_started_name_proc_rep_p return number;
	Function CP_processed_name_proc_rep_p return number;
	Function CP_backedout_name_proc_rep_p return number;
	Function CP_voided_name_proc_rep_p return number;
	Function CP_total_name_proc_rep_p return number;
	Function CP_started_name_proc_comp_p return number;
	Function CP_processed_name_proc_comp_p return number;
	Function CP_backedout_name_proc_comp_p return number;
	Function CP_voided_name_proc_comp_p return number;
	Function CP_total_name_proc_comp_p return number;
	Function CP_report_module_name_p return varchar2;
	Function CP_asg_type_p return varchar2;
	Function CP_ler_type_p return varchar2;
	Function CP_business_group_name_p return varchar2;
	Function CP_location_name_p return varchar2;
	Function CP_organization_name_p return varchar2;
	Function CP_reporting_group_name_p return varchar2;
	Function CP_benefit_group_name_p return varchar2;
	Function CP_pln_name_p return varchar2;
	Function CP_ler_name_p return varchar2;
	Function CP_person_name_p return varchar2;
	Function CP_nat_ident_p return varchar2;
	Function CP_displ_flex_p return varchar2;
	Function CP_rept_strt_end_dt_p return varchar2;
	Function CP_comp_strt_end_dt_p return varchar2;
END BEN_BENLESUM_XMLP_PKG;

/
