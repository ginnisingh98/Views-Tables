--------------------------------------------------------
--  DDL for Package PER_ZA_EE_DIFFERENTIAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ZA_EE_DIFFERENTIAL_PKG" AUTHID CURRENT_USER as
/* $Header: perzaeid.pkh 120.0.12010000.1 2009/12/08 06:30:25 rbabla noship $ */
/*
==============================================================================

MODIFICATION HISTORY
Name           Date        Version Bug     Text
-------------- ----------- ------- ------- -----------------------------
R Babla        24-Nov-2009   115.0 9112237  Initial Version
==============================================================================
*/
P_BUSINESS_GROUP_ID number;
P_REPORT_DATE  date;
P_LEGAL_ENTITY_ID number;
P_SUBMISSION_DATE date;
P_SALARY_METHOD   varchar2(50);

function BEFOREREPORT return boolean;
function AFTERREPORT return boolean;

function get_seta_classification
(
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type default null
) return varchar2;



FUNCTION get_total(p_employment_type IN VARCHAR2
                  ,p_emp_type varchar2
                  ,p_report_id varchar2
                  ,p_legal_entity_id NUMBER) RETURN NUMBER;

FUNCTION get_row_total(p_employment_type IN VARCHAR2
                      ,p_inc_num varchar2
		      ,p_legal_entity_id NUMBER) RETURN NUMBER;

end per_za_ee_differential_pkg;

/
