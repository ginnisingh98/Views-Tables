--------------------------------------------------------
--  DDL for Package HR_US_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_REPORTS" AUTHID CURRENT_USER AS
/* $Header: pyuslrep.pkh 120.0.12010000.2 2008/08/06 08:33:31 ubhat ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ******************************************************************
 Name        : hr_us_reports (HEADER)
 File        : pyuslrep.pkh
 Description : This package declares functions and procedures which are used
               to return values for the srw2 US Payroll r10 reports.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 40.0    13-SEP-93 AKelly               Date Created
 40.1    12-NOV-93 AKelly               Added get_legislation_code
 40.2    22-NOV-93 AKelly               Added get_defined_balance_id
 40.3    22-NOV-93 AKelly               Added get_startup_defined_balance
 40.4    11-DEC-93 MSwanson             Added 'get_payment_type_name'.
                                        Added 'get_element_type_name'.
 40.5    17-FEB-94 GPayton-McDowall     added get_ben_class_name
 40.6    01-MAR-94 GPayton-McDowall     added get_cobra_qualifying_event
                                              get_cobra_status
 40.7    23-Mar-94 MSwanson             Added get_org_name, get_est_tax_unit and
                                        get_org_hierarchy_name for EEO reporting.
 40.8    25-Mar-94 MSwanson             Added get_county_address for eeo and tax reps.
                                        Added get_activity for eeo reps.
 40.9    03-Jul-94 A Roussel            Tidy up for 10G install
 40.10   12-Oct-94 MSwanson             Add get_defined_balance_by_type.
                                        Add get_employee_address.
					Add get_person_name.
 40.	 20-apr-95 MSwanson		Add get_career_path_name.
 40.7    19-oct-95 MSwanson             Add get_state_name.
 40.8    20-Oct-95 MSwanson		Add get_new_hire_contact.
 40.9    25-Oct-95 MSwanson		Add get_salary.
 40.10   21-May-96 nlee                 Bug 366087 Add new procedure
                                        get_address_31.
                                        Add function get_location_code.
 40.11	  3-Jul-96 S Desai/G Perry	Moved get_address_31 and
					get_location_code to the bottom of
					the header file.  This innocuous
					change was required because Oracle Reports
					stored the function sequence instead of the
					name.  Therefore, checkwriter would execute
					the wrong function.
 40.19  05-NOV-1996 hekim               Added function get_address_3lines
 40.20  18-NOV-1996 hekim               Added effective_date to get_address_3lines
 40.26  17-APR-2000  mcpham              Added function fnc_get_payee for report PAYRPTPP a
nd bug 1063477


115.2   25-FEB-2002 vbanner             Added function get_hr_est_tax_unit.
                                        Bug 2722353.
115.3   25-FEB-2002 vbanner             Added dbdrv command etc for GSCC
115.4   22-OCT-2003 ynegoro             Added nocopy for GSCC
115.5   23-OCT-2003 ynegoro   3182433   Added get_top_org_id function
115.6   05-MAY-2005 ynegoro   4346783   Added verify_state function
115.7   12-MAR-2008 psugumar  6774707   Added get_employee_address40
 =================================================================
*/
FUNCTION get_salary     (p_business_group_id	NUMBER,
			 p_assignment_id 	NUMBER,
			 p_report_date 		DATE
			) return number;
--
--
procedure get_new_hire_contact(	p_person_id 		in number,
				p_business_group_id 	in number,
				p_report_date		in date,
				p_contact_name		out nocopy varchar2,
				p_contact_title		out nocopy varchar2,
				p_contact_phone		out nocopy varchar2
			      );
--
--
procedure get_address(p_location_id in number, p_address out nocopy varchar2);
--
--
procedure get_employee_address(p_person_id in number, p_address out nocopy varchar2);
--
--
procedure get_county_address(p_location_id in number, p_address out nocopy varchar2);
--
--
procedure get_activity(p_establishment_id in number, p_activity out nocopy varchar2);
--
--
FUNCTION fnc_get_payee
  ( IN_payee_id IN NUMBER,
    IN_payee_type IN VARCHAR2,
    IN_payment_date IN DATE,
    IN_business_group_id IN NUMBER)
  RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (fnc_get_payee, WNDS);
--
--
FUNCTION get_consolidation_set(p_consolidation_set_id number)
 return varchar2;
--
--
FUNCTION get_payment_type_name(p_payment_type_id number)
 return varchar2;
--
--
FUNCTION get_element_type_name(p_element_type_id number)
 return varchar2;
--
--
FUNCTION get_tax_unit(p_tax_unit_id number)
 return varchar2;
--
--
FUNCTION get_person_name(p_person_id number)
 return varchar2;
--
--
FUNCTION get_payroll_action(p_payroll_action_id number)
 return varchar2;
--
--
FUNCTION get_legislation_code(p_business_group_id number)
 return varchar2;
--
--
FUNCTION get_defined_balance_id(p_balance_name VARCHAR2,
                                p_dimension_suffix VARCHAR2,
                                p_business_group_id NUMBER)
 return number;
--
--
FUNCTION get_startup_defined_balance(p_reporting_name VARCHAR2,
                                     p_dimension_suffix VARCHAR2)
 return number;
--
--
--
FUNCTION get_defined_balance_by_type(p_box_num          VARCHAR2,
                                     p_dimension_suffix VARCHAR2)
 return number;
--
FUNCTION get_ben_class_name
(p_session_date DATE,
 p_benefit_classification_id NUMBER) return VARCHAR2;
--
--
FUNCTION get_cobra_qualifying_event
( p_qualifying_event VARCHAR2 ) return VARCHAR2;
--
--
FUNCTION get_cobra_status
( p_cobra_status VARCHAR2 ) return VARCHAR2;
--
--
--
function get_est_tax_unit (p_starting_org_id          number,
                           p_org_structure_version_id number
                          ) RETURN number;
--
function get_hr_est_tax_unit (p_starting_org_id          number,
                              p_org_structure_version_id number
                             ) RETURN number;
--
function get_org_hierarchy_name (p_org_structure_version_id number
                                ) RETURN varchar2;
--
function get_state_name (p_state_code varchar2
                      ) RETURN varchar2;
--
function get_org_name (p_organization_id number, p_business_group_id number
                      ) RETURN varchar2;
--
FUNCTION get_career_path_name (p_career_path_id number,
                               p_business_group_id number
                      ) RETURN varchar2;
--
FUNCTION get_aap_org_id (p_aap_name varchar2, p_business_group_id number
                      ) RETURN number;
--
procedure get_address_31(p_location_id in number, p_address out nocopy varchar2);
--
--
FUNCTION get_location_code (p_location_id number) RETURN varchar2;
--
procedure get_address_3lines(p_person_id in number,
                             p_effective_date  in date,
                             p_addr_line1 out nocopy varchar2,
                             p_addr_line2 out nocopy varchar2,
                             p_city_state_zip out nocopy varchar2);
--
-- BUG3182433
--
FUNCTION get_top_org_id
  (p_business_group_id        number
  ,p_org_structure_version_id number) RETURN number;

--
-- BUG4346783
-- For VETS-100 Consolidated Report
-- This function is called from Q_2_STATE query
--
FUNCTION verify_state
  (p_date_start                   in date
  ,p_date_end                     in date
  ,p_business_group_id            in number
  ,p_hierarchy_version_id         in number
  ,p_state                        in varchar2
  ) return number;
--
-- end of hr_us_reports
--
  procedure get_employee_address40(p_person_id in number,p_address   out nocopy varchar2);
end hr_us_reports;

/
