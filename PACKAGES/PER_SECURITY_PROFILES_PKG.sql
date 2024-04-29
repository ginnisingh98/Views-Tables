--------------------------------------------------------
--  DDL for Package PER_SECURITY_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SECURITY_PROFILES_PKG" AUTHID CURRENT_USER as
/* $Header: peser01t.pkh 120.0.12000000.1 2007/01/22 04:22:53 appldev noship $ */

PROCEDURE Insert_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                     X_Security_Profile_Id                  IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Organization_Id                      NUMBER,
                     X_Position_Structure_Id                NUMBER,
                     X_Organization_Structure_Id            NUMBER,
                     X_Include_Top_Org_Flag                 VARCHAR2,
                     X_Include_Top_Position_Flag            VARCHAR2,
                     X_Security_Profile_Name                VARCHAR2,
                     X_View_All_Applicants_Flag             VARCHAR2,
                     X_View_All_Employees_Flag              VARCHAR2,
                     X_View_All_Flag                        VARCHAR2,
                     X_View_All_Organizations_Flag          VARCHAR2,
                     X_View_All_Payrolls_Flag               VARCHAR2,
                     X_View_All_Positions_Flag              VARCHAR2,
                     X_View_All_Cwk_Flag                    VARCHAR2,
                     X_View_All_Contacts_Flag               VARCHAR2,
                     X_View_All_Candidates_Flag             VARCHAR2,
                     X_Include_Exclude_Payroll_Flag         VARCHAR2,
                     X_Reporting_Oracle_Username            VARCHAR2,
                     X_Allow_Granted_Users_Flag             VARCHAR2,
                     X_Restrict_By_Supervisor_Flag          VARCHAR2,
                     X_Supervisor_Levels                    NUMBER,
                     X_Exclude_Secondary_Asgs_Flag          VARCHAR2,
                     X_Exclude_Person_Flag                  VARCHAR2,
                     X_Named_Person_Id                      NUMBER,
                     X_Custom_Restriction_Flag              VARCHAR2,
                     X_Restriction_Text                     VARCHAR2,
                     X_Exclude_Business_Groups_Flag         VARCHAR2,
                     X_Org_Security_Mode                    VARCHAR2,
                     X_Restrict_On_Individual_Asg           VARCHAR2,
                     X_Top_Organization_Method              VARCHAR2,
                     X_Top_Position_Method                  VARCHAR2,
                     X_Request_Id                           NUMBER,
                     X_Program_Application_Id               NUMBER,
                     X_Program_Id                           NUMBER,
                     X_Program_Update_date                  DATE
                     );

PROCEDURE Lock_Row  (X_Rowid                                VARCHAR2,
                     X_Security_Profile_Id                  NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Organization_Id                      NUMBER,
                     X_Position_Structure_Id                NUMBER,
                     X_Organization_Structure_Id            NUMBER,
                     X_Include_Top_Org_Flag          	    VARCHAR2,
                     X_Include_Top_Position_Flag            VARCHAR2,
                     X_Security_Profile_Name                VARCHAR2,
                     X_View_All_Applicants_Flag             VARCHAR2,
                     X_View_All_Employees_Flag              VARCHAR2,
                     X_View_All_Flag                        VARCHAR2,
                     X_View_All_Organizations_Flag          VARCHAR2,
                     X_View_All_Payrolls_Flag               VARCHAR2,
                     X_View_All_Positions_Flag              VARCHAR2,
                     X_View_All_Cwk_Flag                    VARCHAR2,
                     X_View_All_Contacts_Flag               VARCHAR2,
                     X_View_All_Candidates_Flag             VARCHAR2,
                     X_Include_Exclude_Payroll_Flag         VARCHAR2,
                     X_Reporting_Oracle_Username            VARCHAR2,
                     X_Allow_Granted_Users_Flag             VARCHAR2,
                     X_Restrict_By_Supervisor_Flag          VARCHAR2,
                     X_Supervisor_Levels                    NUMBER,
                     X_Exclude_Secondary_Asgs_Flag          VARCHAR2,
                     X_Exclude_Person_Flag                  VARCHAR2,
                     X_Named_Person_Id                      NUMBER,
                     X_Custom_Restriction_Flag              VARCHAR2,
                     X_Restriction_Text                     VARCHAR2,
                     X_Exclude_Business_Groups_Flag         VARCHAR2,
                     X_Org_Security_Mode                    VARCHAR2,
                     X_Restrict_On_Individual_Asg           VARCHAR2,
                     X_Top_Organization_Method              VARCHAR2,
                     X_Top_Position_Method                  VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                                VARCHAR2,
                     X_Security_Profile_Id                  NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Organization_Id                      NUMBER,
                     X_Position_Structure_Id                NUMBER,
                     X_Organization_Structure_Id            NUMBER,
                     X_Include_Top_Org_Flag  	 	    VARCHAR2,
                     X_Include_Top_Position_Flag            VARCHAR2,
                     X_Security_Profile_Name                VARCHAR2,
                     X_View_All_Applicants_Flag             VARCHAR2,
                     X_View_All_Employees_Flag              VARCHAR2,
                     X_View_All_Flag                        VARCHAR2,
                     X_View_All_Organizations_Flag          VARCHAR2,
                     X_View_All_Payrolls_Flag               VARCHAR2,
                     X_View_All_Positions_Flag              VARCHAR2,
                     X_View_All_Cwk_Flag                    VARCHAR2,
                     X_View_All_Contacts_Flag               VARCHAR2,
                     X_View_All_Candidates_Flag             VARCHAR2,
                     X_Include_Exclude_Payroll_Flag         VARCHAR2,
                     X_Reporting_Oracle_Username            VARCHAR2,
                     X_Allow_Granted_Users_Flag             VARCHAR2,
                     X_Restrict_By_Supervisor_Flag          VARCHAR2,
                     X_Supervisor_Levels                    NUMBER,
                     X_Exclude_Secondary_Asgs_Flag          VARCHAR2,
                     X_Exclude_Person_Flag                  VARCHAR2,
                     X_Named_Person_Id                      NUMBER,
                     X_Custom_Restriction_Flag              VARCHAR2,
                     X_Restriction_Text                     VARCHAR2,
                     X_Exclude_Business_Groups_Flag         VARCHAR2,
                     X_Org_Security_Mode                    VARCHAR2,
                     X_Restrict_On_Individual_Asg           VARCHAR2,
                     X_Top_Organization_Method              VARCHAR2,
                     X_Top_Position_Method                  VARCHAR2,
                     X_Request_Id                           NUMBER,
                     X_Program_Application_Id               NUMBER,
                     X_Program_Id                           NUMBER,
                     X_Program_Update_Date                  DATE
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

procedure check_uniqueness(
        p_security_profile_name varchar2,
        p_row_id                varchar2);

procedure chk_reporting_username_unique(
	p_reporting_oracle_username	varchar2,
        p_row_id                	varchar2,
	p_is_base_user			IN OUT NOCOPY varchar2);

procedure pre_delete_validation(
        p_security_profile_id           number,
        p_view_all_flag                 varchar2,
        p_secgen_warn                   IN OUT NOCOPY varchar2);

function check_sql_fragment(p_restriction_text VARCHAR2)
return boolean;

-- Bug fix 2809163
-- ----------------------------------------------------------------------------
-- |-------------------< check_assigned_sec_profile >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure will check that, the given security profile id is
--  already assigned as any system profile value
--
-- Prerequisites:
--   A valid security profile should be existing
--
-- In Parameters:
--   Name                          Reqd  Type          Description
--   p_security_profile_id         yes   number        Security profile id to
--                                                     be deleted
-- Post Success:
--   User will be stopped from deleting the security profile which is
--   already used as system profile value
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal developement use.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure check_assigned_sec_profile(p_security_profile_id number);
--

END PER_SECURITY_PROFILES_PKG;

 

/
