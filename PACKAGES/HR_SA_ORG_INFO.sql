--------------------------------------------------------
--  DDL for Package HR_SA_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SA_ORG_INFO" AUTHID CURRENT_USER AS
/* $Header: pesaorgi.pkh 115.2 2004/01/14 07:09:14 abppradh noship $ */

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


Procedure chk_for_org_in_hierarchy(p_org_id in hr_organization_units.organization_id%TYPE,
                                   p_exists out nocopy varchar2);

PROCEDURE get_employer_name (p_org_id in hr_organization_units.organization_id%TYPE,
                             p_employer_name out nocopy varchar2,
			     p_business_group_id hr_organization_units.organization_id%TYPE);


PROCEDURE get_employer_name (p_org_id in hr_organization_units.organization_id%TYPE,
                             p_employer_name out nocopy varchar2,
			     p_business_group_id hr_organization_units.organization_id%TYPE,
                             p_structure_version_id number);

FUNCTION get_employer_name (p_org_id in hr_organization_units.organization_id%TYPE,
			     p_business_group_id hr_organization_units.organization_id%TYPE,
                             p_structure_version_id number default null) RETURN VARCHAR2;

END HR_SA_ORG_INFO;

 

/
