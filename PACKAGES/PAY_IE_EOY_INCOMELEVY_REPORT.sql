--------------------------------------------------------
--  DDL for Package PAY_IE_EOY_INCOMELEVY_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_EOY_INCOMELEVY_REPORT" AUTHID CURRENT_USER as
/* $Header: pyieeoyc.pkh 120.0.12010000.1 2009/10/01 09:38:24 knadhan noship $ */

TYPE XMLRec IS RECORD(
xmlstring VARCHAR2(32000));
TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;

	procedure get_eoy_income_details( cp_start_date in date,
					  cp_effective_date in date,
					  cp_end_date in date,
					  p_business_group_id in number,
					  p_assignment_set_id in number,
					  p_payroll_id in number,
					  p_consolidation_set_id in number,
				  p_sort_order in varchar2);

	procedure populate_eoy_income_details(P_START_DATE IN VARCHAR2 DEFAULT NULL
				      ,CP_EFFECTIVE_DATE IN VARCHAR2 DEFAULT NULL
				      ,P_END_DATE IN VARCHAR2 DEFAULT NULL
				      ,P_BUSINESS_GROUP_ID IN VARCHAR2 DEFAULT NULL
				      ,P_ASSIGNMENT_SET_ID IN VARCHAR2 DEFAULT NULL
				      ,P_PAYROLL_ID IN VARCHAR2 DEFAULT NULL
				      ,P_CONSOLIDATION_SET_ID IN VARCHAR2 DEFAULT NULL
				      ,P_SORT_ORDER IN VARCHAR2 DEFAULT NULL
				      ,P_TEMPLATE_NAME IN VARCHAR2
				      ,P_XML OUT NOCOPY CLOB
				      ) ;

	PROCEDURE WritetoCLOB (p_xml out nocopy clob);




end pay_ie_eoy_incomelevy_report;

/
