--------------------------------------------------------
--  DDL for Package HR_DE_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_ORG_INFO" AUTHID CURRENT_USER AS
/* $Header: pedeorgi.pkh 115.11 2002/11/26 16:32:37 jahobbs noship $ */

TYPE Insurance_providers_rec is RECORD (
     status              varchar2(150),
     child_org_id        varchar2(150),
     class_of_risk       varchar2(150),
     Membership_Number   varchar2(150),
     Name                varchar2(240));

TYPE Insurance_providers_table is TABLE OF Insurance_providers_rec index by binary_integer;
--
--
-- Service function to return the current named hioerarchy.
--
FUNCTION named_hierarchy
(p_organization_id NUMBER) RETURN NUMBER;
--
--
-- Service function to return the current version of the named hioerarchy.
--
FUNCTION latest_named_hierarchy_vers
(p_organization_id NUMBER) RETURN NUMBER;
--
--
-- Service function to see if organization belongs to the current primary hioerarchy.
--
FUNCTION org_exists_in_hierarchy
(p_organization_id NUMBER) RETURN VARCHAR2;


Procedure get_org_data_items(p_chamber_contribution_out out nocopy varchar2,
                        p_employer_Betriebsnummer  out nocopy varchar2,
                        p_payroll_Betriebsnummer   out nocopy varchar2,
                        p_org_id in number);

Procedure get_insurance_providers (p_org_id in hr_organization_units.organization_id%TYPE
                                 ,p_Insurance_providers_Table out nocopy Insurance_providers_table);

Procedure chk_for_org_in_hierarchy(p_org_id in hr_organization_units.organization_id%TYPE,
                                   p_exists out nocopy varchar2);

-- Functions used in the view HR_DE_WORK_INCIDENTS_REPORT
Function  get_liab_prov_details(p_assignment_id in per_assignments_f.assignment_id%TYPE,
                                p_incident_date in date)
          Return varchar2;
	Function  get_liab_prov_name(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;
	Function  get_liab_prov_membership_no(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;

Function  get_location(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;
	Function  get_addr_line1(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;
	Function  get_addr_line2(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;
	Function  get_addr_line3(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;
	Function  get_town(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;
	Function  get_country(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;
	Function  get_postal_code(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;

Function  get_liab_prov_details2(p_assignment_id in per_assignments_f.assignment_id%TYPE,
                                 p_incident_date in date)
          Return varchar2;

Function get_supervising_off(p_assignment_id in per_assignments_f.assignment_id%TYPE,
                             p_incident_date in date)
          Return varchar2;
	Function  get_supervising_off_name(p_assignment_id in per_assignments_f.assignment_id%TYPE)
          Return varchar2;
--

END;

 

/
