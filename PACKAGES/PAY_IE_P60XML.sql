--------------------------------------------------------
--  DDL for Package PAY_IE_P60XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_P60XML" AUTHID CURRENT_USER as
/* $Header: pyiep60p.pkh 120.0.12010000.1 2008/07/27 22:50:44 appldev ship $ */

TYPE XMLRec IS RECORD(
xmlstring VARCHAR2(32000));
TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;

	procedure get_p60_details(p_53_indicator in varchar2,
					  cp_start_date in date,
					  cp_effective_date in date,
					  cp_end_date in date,
					  p_business_group_id in number,
					  p_assignment_set_id in number,
					  p_payroll_id in number,
					  p_consolidation_set_id in number,
				  p_sort_order in varchar2);

	procedure populate_p60_details(P_53_INDICATOR IN VARCHAR2 DEFAULT NULL
				      ,P_START_DATE IN VARCHAR2 DEFAULT NULL
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

	Procedure  clob_to_blob(p_clob clob
			,p_blob IN OUT NOCOPY blob);

	Procedure fetch_rtf_blob (p_template_id number
			 ,p_rtf_blob OUT NOCOPY blob);
end pay_ie_p60xml;

/
