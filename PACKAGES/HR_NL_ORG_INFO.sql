--------------------------------------------------------
--  DDL for Package HR_NL_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_ORG_INFO" AUTHID CURRENT_USER AS
/* $Header: penlorgi.pkh 120.0.12000000.1 2007/01/22 00:24:44 appldev ship $ */
--
--
-- Service function to return the current named hierarchy.
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
--
--
-- Function checks to see if organization region is same as the passed region
-- and returns Organization ID if it is found else returns NULL
-- It checks the Named Org Hierarchy to check if belongs to the same region from the Org Hierarchy
--
FUNCTION check_org_in_region (p_org_id in hr_organization_units.organization_id%TYPE,
                             p_region in varchar2) RETURN hr_organization_units.organization_id%TYPE;
--
--The following procedure checks if the Organization passed in exists in the Primary Hierarchy.
--
PROCEDURE chk_for_org_in_hierarchy(p_org_id in hr_organization_units.organization_id%TYPE,
                                   p_exists out nocopy varchar2);
--
--
-- Procedure returns the Region and Org. Number for the Named Org Hierarchy
--
PROCEDURE get_org_data_items(p_org_id in number,
			     p_region  out nocopy varchar2,
			     p_organization_number out nocopy varchar2) ;

-- Service function which returns the organization information id for which Social
-- Insurance Information is entered in the Org Heirarchy
--
FUNCTION Get_SI_Org_Id
(p_organization_id NUMBER,p_si_type VARCHAR2,p_assignment_id NUMBER) RETURN NUMBER;


-- Service function which returns the SI Provider information for the given organization.
-- It performs tree walk if SI information is not defined for the given organization.
--
FUNCTION Get_SI_Provider_Info
(p_organization_id NUMBER,p_si_type VARCHAR2,p_assignment_id NUMBER) RETURN NUMBER;
--
-- Service function to see if uwv organization is assigned to
-- any hr organization in the hierarchy.
--
-- Service function which returns the SI Provider information for the given assignment.
-- It performs tree walk if SI information is not defined for the given organization.
--
FUNCTION Get_SI_Provider_Info
(p_assignment_id NUMBER,p_si_type VARCHAR2) RETURN NUMBER;
--
-- Service function to see if uwv organization is assigned to
-- any hr organization in the hierarchy.
--
FUNCTION check_uwv_org_in_hierarchy
(p_uwv_org_id NUMBER,p_organization_id NUMBER) RETURN VARCHAR2;
--
-- Service function to return the Info Id from the Assignment Extra Information
-- to support AMI Enhancement
-- Returns the ID for the Specified SI type defined,if not defined looks for a AMI
-- record and returns it.
FUNCTION Get_Asg_SII_Info_ID
(p_assignment_id NUMBER,p_si_type VARCHAR2) RETURN NUMBER;
--
-- Service function to return the Average_Days_Per_Month defined at the Hr Org
-- from the EIT Context - NL_ORG_INFORMATON
-- Traversing the Named Org Hierarchy

FUNCTION Get_Avg_Days_Per_Month(p_assignment_id NUMBER) RETURN number;
--
--  Function which returns tax organization for the given organization by traversing the org hierarchy
--
Function Get_Tax_Org_Id(p_org_structure_version_id NUMBER,p_organization_id NUMBER) RETURN NUMBER;
--
FUNCTION Get_Working_hours_Per_Week(p_org_id NUMBER) RETURN number;

-- Function which returns part time percentage method for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_Part_Time_Perc_Method(p_assignment_id NUMBER) RETURN NUMBER;

-- Function which returns lunar 5-week month wage method for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_Lunar_5_Week_Method(p_assignment_id NUMBER) RETURN NUMBER;

-- NL_Proration Function which returns Proration_Tax_Table for the given organization
-- If the value is not specified for the given organization it performs the tree walk.

FUNCTION Get_Proration_Tax_Table(p_assignment_id NUMBER) RETURN Varchar2;

-- Service function which returns the SI Provider information for the given organization.
-- It performs tree walk if SI information is not defined for the given organization.
--
FUNCTION Get_ER_SI_Prov_HR_Org_ID
(p_organization_id NUMBER,p_si_type VARCHAR2,p_assignment_id NUMBER) RETURN NUMBER;

-- To get all the employers for given Org Struct Version ID
function Get_Employers_List(p_Org_Struct_Version_Id in number,
                            p_top_org_id in number,
                            p_sub_emp in varchar2)
return varchar2 ;

-- Function which returns parental leave wage percentage for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_Parental_Leave_Wage_Perc(p_assignment_id NUMBER) RETURN NUMBER;
-- Function which returns the customer number for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_customer_number
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2;
-- Function which returns Reporting Frequency for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_Reporting_Frequency
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2;
-- Function which returns Public Sector Org for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_Public_Sector_Org
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2;
-- Function which returns company unit for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_company_unit
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2;
-- Function which returns Full Sickness Wage Paid Indicator for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_Full_Sickness_Wage_Paid
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2;
-- Function which returns IZA Weekly Full Time Hours for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_IZA_Weekly_Full_Hours
        (p_assignment_id in NUMBER ) RETURN Varchar2;
-- Function which returns IZA Monthly Full Time Hours for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_IZA_Monthly_Full_Hours
       (p_assignment_id in NUMBER ) RETURN Varchar2;

FUNCTION Get_IZA_Org_Id(p_org_structure_version_id NUMBER,p_organization_id NUMBER) RETURN NUMBER;

END;


 

/
