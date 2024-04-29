--------------------------------------------------------
--  DDL for Package PAY_US_GEO_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_GEO_UPD_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusgeou.pkh 120.1.12010000.1 2008/07/27 23:51:54 appldev ship $ */


/* DESCRIPTION OF THE LOCAL PROCEDURES:
	write_message 		=>  inserts rows into PAY_US_GEO_UPDATE for each iteration
	upgrade_geocodes 	=> driving procedure calls all the local procedures
	balance_batch_lines 	=> updates pay balance batch lines
	city_tax_records    	=> updates city tax records
	run_results	    	=> updates run results
	archive_item_contexts  	=> updates archive items
	element_entries		=> updates element entries
	balance_contexts	=> updates balance contexts for person and assignment level
	duplicate_vertex_ee	=> deletes duplicate element entries and adds percentages togethor
	insert_ele_entries	=> creates element entries for assignments that have new geocodes
	check_time		=> checks the percent time for element entries
	update_taxability_rules	=> updates the taxability rules
        update_org_info         => updates org_information1 column
                                   in hr_organization_information
        pay_run_balances        => updates jurisdiction code and jurisdiction comp3
                                   (jurisdiction comp3 is new city code)
        pay_action_contexts    =>  updates context_value
*/

PROCEDURE range_cursor(pactid in  number
                        ,sqlstr out nocopy varchar2);



PROCEDURE action_creation (pactid    in number
                           ,stperson  in number
                           ,endperson in number
                           ,chunk     in number);

PROCEDURE sort_action(payactid in            varchar2
                       ,sqlstr   in out nocopy varchar2
                       ,len         out nocopy number);

PROCEDURE archive_code (p_xfr_action_id in number
                        , p_effective_date  in date);

PROCEDURE archive_deinit(p_payroll_action_id in number);


FUNCTION get_parameter(name in varchar2,
                       parameter_list varchar2) RETURN VARCHAR2;

PROCEDURE upgrade_geocodes(
			  p_assign_start IN NUMBER,
			  p_assign_end   IN NUMBER,
			  p_geo_phase_id IN NUMBER,
			  p_mode	 IN VARCHAR2,
                          p_patch_name   IN VARCHAR2,
			  p_city_name    IN VARCHAR2 DEFAULT NULL,
			  p_api_mode     IN VARCHAR2 DEFAULT 'N');


PROCEDURE  upgrade_geo_api(P_ASSIGN_ID NUMBER,
                           P_PATCH_NAME VARCHAR2,
                           P_MODE VARCHAR2,
                           P_CITY_NAME VARCHAR2);


g_geo_phase_id number;

g_mode varchar2(10);

g_process_type varchar2(2);


PROCEDURE update_taxability_rules(P_GEO_PHASE_ID IN NUMBER,
                                  P_MODE         IN VARCHAR2,
                                  P_PATCH_NAME   IN VARCHAR2);

PROCEDURE update_org_info(P_GEO_PHASE_ID IN NUMBER,
                          P_MODE         IN VARCHAR2,
                          P_PATCH_NAME   IN VARCHAR2);

Function IS_US_OR_CA_LEGISLATION
   (p_input_value_id in pay_input_values_f.input_value_id%TYPE)
   Return pay_input_values_f.input_value_id%TYPE;

PROCEDURE update_ca_emp_info(P_GEO_PHASE_ID IN NUMBER,
                             P_MODE         IN VARCHAR2,
                             P_PATCH_NAME   IN VARCHAR2);


PROCEDURE  group_level_balance (P_START_PAYROLL_ACTION  IN NUMBER,
                                P_END_PAYROLL_ACTION    IN NUMBER,
                                P_GEO_PHASE_ID          IN NUMBER,
                                P_MODE                  IN VARCHAR2,
                                P_PATCH_NAME            IN VARCHAR2) ;



end pay_us_geo_upd_pkg;

/
