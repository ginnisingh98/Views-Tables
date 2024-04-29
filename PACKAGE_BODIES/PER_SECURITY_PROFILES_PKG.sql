--------------------------------------------------------
--  DDL for Package Body PER_SECURITY_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SECURITY_PROFILES_PKG" as
/* $Header: peser01t.pkb 120.1.12000000.1 2007/01/22 04:21:43 appldev noship $ */


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Security_Profile_Id           IN OUT NOCOPY NUMBER,
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
                     X_Program_Update_Date                  DATE
 ) IS
   CURSOR C IS SELECT rowid FROM per_security_profiles
             WHERE security_profile_id = X_Security_Profile_Id;
--
    CURSOR C2 IS SELECT per_security_profiles_s.nextval FROM sys.dual;
BEGIN

   if (X_Security_Profile_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Security_Profile_Id;
     CLOSE C2;
   end if;
  INSERT INTO per_security_profiles(
          security_profile_id,
          business_group_id,
          position_id,
          organization_id,
          position_structure_id,
          organization_structure_id,
          include_top_organization_flag,
          include_top_position_flag,
          security_profile_name,
          view_all_applicants_flag,
          view_all_employees_flag,
          view_all_flag,
          view_all_organizations_flag,
          view_all_payrolls_flag,
          view_all_positions_flag,
          view_all_cwk_flag,
          view_all_contacts_flag,
          view_all_candidates_flag,
          include_exclude_payroll_flag,
          reporting_oracle_username,
          allow_granted_users_flag,
          restrict_by_supervisor_flag,
          supervisor_levels,
          exclude_secondary_asgs_flag,
          exclude_person_flag,
          named_person_id,
          custom_restriction_flag,
          restriction_text,
          exclude_business_groups_flag,
          org_security_mode,
          restrict_on_individual_asg,
          top_organization_method,
          top_position_method,
          request_id,
          program_application_id,
          program_id,
          program_update_date
         ) VALUES (
          X_Security_Profile_Id,
          X_Business_Group_Id,
          X_Position_Id,
          X_Organization_Id,
          X_Position_Structure_Id,
          X_Organization_Structure_Id,
          X_Include_Top_Org_Flag,
          X_Include_Top_Position_Flag,
          X_Security_Profile_Name,
          X_View_All_Applicants_Flag,
          X_View_All_Employees_Flag,
          X_View_All_Flag,
          X_View_All_Organizations_Flag,
          X_View_All_Payrolls_Flag,
          X_View_All_Positions_Flag,
          X_View_All_Cwk_Flag,
          X_View_All_Contacts_Flag,
          X_View_All_Candidates_Flag,
          X_Include_Exclude_Payroll_Flag,
          X_Reporting_Oracle_Username,
          X_Allow_Granted_Users_Flag,
          X_Restrict_By_Supervisor_Flag,
          X_Supervisor_Levels,
          X_Exclude_Secondary_Asgs_Flag,
          X_Exclude_Person_Flag,
          X_Named_Person_Id,
          X_Custom_Restriction_Flag,
          X_Restriction_Text,
          X_Exclude_Business_Groups_Flag,
          X_Org_Security_Mode,
          X_Restrict_On_Individual_Asg,
          X_Top_Organization_Method,
          X_Top_Position_Method,
          X_Request_Id,
          X_Program_Application_Id,
          X_Program_Id,
          X_Program_Update_Date
 );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801, 'HR_6153_APPL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PER_SECURITY_PROFILES_V_PKG');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
END Insert_Row;
----------------------------------------------------------------------------
PROCEDURE Lock_Row  (X_Rowid                                VARCHAR2,
                     X_Security_Profile_Id                  NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Organization_Id                      NUMBER,
                     X_Position_Structure_Id                NUMBER,
                     X_Organization_Structure_Id            NUMBER,
                     X_Include_Top_Org_Flag         	    VARCHAR2,
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
) IS
  CURSOR C IS
      SELECT *
      FROM   per_security_profiles
      WHERE  rowid = X_Rowid
      FOR UPDATE of Security_Profile_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801, 'HR_6153_APPL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PER_SECURITY_PROFILES_V_PKG');
    hr_utility.set_message_token('STEP','2');
    hr_utility.raise_error;
  end if;
  CLOSE C;


recinfo.include_top_organization_flag := rtrim(recinfo.include_top_organization_flag);
recinfo.include_top_position_flag := rtrim(recinfo.include_top_position_flag);
recinfo.security_profile_name := rtrim(recinfo.security_profile_name);
recinfo.view_all_applicants_flag := rtrim(recinfo.view_all_applicants_flag);
recinfo.view_all_employees_flag := rtrim(recinfo.view_all_employees_flag);
recinfo.view_all_flag := rtrim(recinfo.view_all_flag);
recinfo.view_all_organizations_flag := rtrim(recinfo.view_all_organizations_flag);
recinfo.view_all_payrolls_flag := rtrim(recinfo.view_all_payrolls_flag);
recinfo.view_all_positions_flag := rtrim(recinfo.view_all_positions_flag);
recinfo.view_all_cwk_flag := rtrim(recinfo.view_all_cwk_flag);
recinfo.view_all_contacts_flag := rtrim(recinfo.view_all_contacts_flag);
recinfo.view_all_candidates_flag := rtrim(recinfo.view_all_candidates_flag);
recinfo.include_exclude_payroll_flag := rtrim(recinfo.include_exclude_payroll_flag);
recinfo.reporting_oracle_username := rtrim(recinfo.reporting_oracle_username);
recinfo.allow_granted_users_flag := rtrim(recinfo.allow_granted_users_flag);
recinfo.restrict_by_supervisor_flag := rtrim(recinfo.restrict_by_supervisor_flag);
recinfo.exclude_secondary_asgs_flag:=rtrim(recinfo.exclude_secondary_asgs_flag);
recinfo.exclude_person_flag:=rtrim(recinfo.exclude_person_flag);
recinfo.custom_restriction_flag:=rtrim(recinfo.custom_restriction_flag);
recinfo.restriction_text:=rtrim(recinfo.restriction_text);
recinfo.exclude_business_groups_flag:=rtrim(recinfo.exclude_business_groups_flag);
recinfo.org_security_mode:=rtrim(recinfo.org_security_mode);
recinfo.restrict_on_individual_asg:=rtrim(recinfo.restrict_on_individual_asg);
recinfo.top_organization_method:=rtrim(recinfo.top_organization_method);
recinfo.top_position_method:=rtrim(recinfo.top_position_method);

if (
          (   (Recinfo.security_profile_id = X_Security_Profile_Id)
           OR (    (Recinfo.security_profile_id IS NULL)
               AND (X_Security_Profile_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.position_id = X_Position_Id)
           OR (    (Recinfo.position_id IS NULL)
               AND (X_Position_Id IS NULL)))
      AND (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.position_structure_id = X_Position_Structure_Id)
           OR (    (Recinfo.position_structure_id IS NULL)
               AND (X_Position_Structure_Id IS NULL)))
      AND (   (Recinfo.organization_structure_id = X_Organization_Structure_Id)
           OR (    (Recinfo.organization_structure_id IS NULL)
               AND (X_Organization_Structure_Id IS NULL)))
      AND (   (Recinfo.include_top_organization_flag =
      X_Include_Top_Org_Flag)
           OR (    (Recinfo.include_top_organization_flag IS NULL)
               AND (X_Include_Top_Org_Flag IS NULL)))
      AND (   (Recinfo.include_top_position_flag = X_Include_Top_Position_Flag)
           OR (    (Recinfo.include_top_position_flag IS NULL)
               AND (X_Include_Top_Position_Flag IS NULL)))
      AND (   (Recinfo.security_profile_name = X_Security_Profile_Name)
           OR (    (Recinfo.security_profile_name IS NULL)
               AND (X_Security_Profile_Name IS NULL)))
      AND (   (Recinfo.view_all_applicants_flag = X_View_All_Applicants_Flag)
           OR (    (Recinfo.view_all_applicants_flag IS NULL)
               AND (X_View_All_Applicants_Flag IS NULL)))
      AND (   (Recinfo.view_all_employees_flag = X_View_All_Employees_Flag)
           OR (    (Recinfo.view_all_employees_flag IS NULL)
               AND (X_View_All_Employees_Flag IS NULL)))
      AND (   (Recinfo.view_all_flag = X_View_All_Flag)
           OR (    (Recinfo.view_all_flag IS NULL)
               AND (X_View_All_Flag IS NULL)))
      AND (   (Recinfo.view_all_organizations_flag = X_View_All_Organizations_Flag)
           OR (    (Recinfo.view_all_organizations_flag IS NULL)
               AND (X_View_All_Organizations_Flag IS NULL)))
      AND (   (Recinfo.view_all_payrolls_flag = X_View_All_Payrolls_Flag)
           OR (    (Recinfo.view_all_payrolls_flag IS NULL)
               AND (X_View_All_Payrolls_Flag IS NULL)))
      AND (   (Recinfo.view_all_positions_flag = X_View_All_Positions_Flag)
           OR (    (Recinfo.view_all_positions_flag IS NULL)
               AND (X_View_All_Positions_Flag IS NULL )))
      AND (   (Recinfo.view_all_cwk_flag = X_View_All_Cwk_flag)
           OR (    (Recinfo.view_all_cwk_flag IS NULL)
               AND (X_View_All_cwk_Flag IS NULL)))
      AND (   (Recinfo.view_all_contacts_flag = X_View_All_Contacts_flag)
           OR (    (Recinfo.view_all_contacts_flag IS NULL)
               AND (X_View_All_contacts_Flag IS NULL)))
      AND (   (Recinfo.view_all_candidates_flag = X_View_All_Candidates_flag)
           OR (    (Recinfo.view_all_candidates_flag IS NULL)
               AND (X_View_All_candidates_Flag IS NULL)))
      AND (   (Recinfo.include_exclude_payroll_flag = X_Include_Exclude_Payroll_Flag)
           OR (    (Recinfo.include_exclude_payroll_flag IS NULL)
               AND (X_Include_Exclude_Payroll_Flag IS NULL)))
      AND (   (Recinfo.reporting_oracle_username = X_Reporting_Oracle_Username)
           OR (    (Recinfo.reporting_oracle_username IS NULL)
               AND (X_Reporting_Oracle_Username IS NULL)))
      AND (   (Recinfo.allow_granted_users_flag = X_Allow_Granted_Users_Flag)
           OR (    (Recinfo.allow_granted_users_flag IS NULL)
               AND (X_Allow_Granted_Users_Flag IS NULL)))
      AND (   (Recinfo.restrict_by_supervisor_flag = X_Restrict_By_Supervisor_Flag)
           OR (    (Recinfo.restrict_by_supervisor_flag IS NULL)
               AND (X_Restrict_By_Supervisor_Flag IS NULL)))
      AND (   (Recinfo.supervisor_levels = X_Supervisor_Levels)
           OR (    (Recinfo.supervisor_levels IS NULL)
               AND (X_Supervisor_Levels IS NULL)))
      AND (   (Recinfo.exclude_secondary_asgs_flag = X_Exclude_Secondary_Asgs_Flag)
           OR (    (Recinfo.exclude_secondary_asgs_flag IS NULL)
               AND (X_Exclude_Secondary_Asgs_Flag IS NULL)))
      AND (   (Recinfo.exclude_person_flag = X_Exclude_Person_Flag)
           OR (    (Recinfo.exclude_person_flag IS NULL)
               AND (X_Exclude_Person_Flag IS NULL)))
      AND (   (Recinfo.named_person_id = X_Named_Person_Id)
           OR (    (Recinfo.named_person_id IS NULL)
               AND (X_Named_Person_Id IS NULL)))
      AND (   (Recinfo.custom_restriction_flag = X_Custom_Restriction_Flag)
           OR (    (Recinfo.custom_restriction_flag IS NULL)
               AND (X_Custom_Restriction_Flag IS NULL)))
      AND (   (Recinfo.restriction_text = X_Restriction_Text)
           OR (    (Recinfo.restriction_text IS NULL)
               AND (X_Restriction_Text IS NULL)))
      AND (   (Recinfo.exclude_business_groups_flag = X_Exclude_Business_Groups_Flag)
           OR (    (Recinfo.exclude_business_groups_flag IS NULL)
               AND (X_Exclude_Business_Groups_Flag IS NULL)))
      AND (   (Recinfo.org_security_mode = X_Org_Security_Mode)
           OR (    (Recinfo.org_security_mode IS NULL)
               AND (X_Org_Security_Mode IS NULL)))
      AND (   (Recinfo.restrict_on_individual_asg = X_Restrict_On_Individual_Asg)
           OR (    (Recinfo.restrict_on_individual_asg IS NULL)
               AND (X_Restrict_On_Individual_Asg IS NULL)))
      AND (   (Recinfo.top_organization_method = X_Top_Organization_Method)
           OR (    (Recinfo.top_organization_method IS NULL)
               AND (X_Top_Organization_Method IS NULL)))
      AND (   (Recinfo.top_position_method = X_Top_Position_Method)
           OR (    (Recinfo.top_position_method IS NULL)
               AND (X_Top_Position_Method IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;
-----------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                                VARCHAR2,
                     X_Security_Profile_Id                  NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Organization_Id                      NUMBER,
                     X_Position_Structure_Id                NUMBER,
                     X_Organization_Structure_Id            NUMBER,
                     X_Include_Top_Org_Flag       	    VARCHAR2,
                     X_Include_Top_Position_Flag            VARCHAR2,
                     X_Security_Profile_Name                VARCHAR2,
                     X_View_All_Applicants_Flag             VARCHAR2,
                     X_View_All_Employees_Flag              VARCHAR2,
                     X_View_All_Flag                        VARCHAR2,
                     X_View_All_Organizations_Flag          VARCHAR2,
                     X_View_All_Payrolls_Flag               VARCHAR2,
                     X_View_All_Positions_Flag              VARCHAR2,
                     X_View_All_Cwk_flag                    VARCHAR2,
                     X_View_All_Contacts_flag               VARCHAR2,
                     X_View_All_Candidates_flag             VARCHAR2,
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
) IS
BEGIN
  UPDATE per_security_profiles
  SET
    security_profile_id                       =    X_Security_Profile_Id,
    business_group_id                         =    X_Business_Group_Id,
    position_id                               =    X_Position_Id,
    organization_id                           =    X_Organization_Id,
    position_structure_id                     =    X_Position_Structure_Id,
    organization_structure_id                 =    X_Organization_Structure_Id,
    include_top_organization_flag             =    X_Include_Top_Org_Flag,
    include_top_position_flag                 =    X_Include_Top_Position_Flag,
    security_profile_name                     =    X_Security_Profile_Name,
    view_all_applicants_flag                  =    X_View_All_Applicants_Flag,
    view_all_employees_flag                   =    X_View_All_Employees_Flag,
    view_all_flag                             =    X_View_All_Flag,
    view_all_organizations_flag               =    X_View_All_Organizations_Flag,
    view_all_payrolls_flag                    =    X_View_All_Payrolls_Flag,
    view_all_positions_flag                   =    X_View_All_Positions_Flag,
    view_all_cwk_flag                         =    X_View_All_Cwk_Flag,
    view_all_contacts_flag                    =    X_View_All_Contacts_flag,
    view_all_candidates_flag                  =    X_View_All_Candidates_flag,
    include_exclude_payroll_flag              =    X_Include_Exclude_Payroll_Flag,
    reporting_oracle_username                 =    X_Reporting_Oracle_Username,
    allow_granted_users_flag                  =    X_Allow_Granted_Users_Flag,
    restrict_by_supervisor_flag               =    X_Restrict_By_Supervisor_Flag,
    supervisor_levels                         =    X_Supervisor_Levels,
    exclude_secondary_asgs_flag               =    X_Exclude_Secondary_Asgs_Flag,
    exclude_person_flag                       =    X_Exclude_Person_Flag,
    named_person_id                           =    X_Named_Person_Id,
    custom_restriction_flag                   =    X_Custom_Restriction_Flag,
    restriction_text                          =    X_Restriction_Text,
    exclude_business_groups_flag              =    X_Exclude_Business_Groups_Flag,
    org_security_mode                         =    X_Org_Security_Mode,
    restrict_on_individual_asg                =    X_Restrict_On_Individual_Asg,
    top_organization_method                   =    X_Top_Organization_Method,
    top_position_method                       =    X_Top_Position_Method,
    request_id                                =    X_Request_Id,
    program_application_id                    =    X_Program_Application_Id,
    program_id                                =    X_Program_Id,
    program_update_date                       =    X_Program_Update_Date
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801, 'HR_6153_APPL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PER_SECURITY_PROFILES_V_PKG');
    hr_utility.set_message_token('STEP','3');
    hr_utility.raise_error;
  end if;

END Update_Row;
------------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM per_security_profiles
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801, 'HR_6153_APPL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PER_SECURITY_PROFILES_V_PKG');
    hr_utility.set_message_token('STEP','4');
    hr_utility.raise_error;
  end if;
END Delete_Row;
------------------------------------------------------------------------------
procedure check_uniqueness(
	p_security_profile_name	varchar2,
	p_row_id		varchar2) is
	l_dummy			number;
--
cursor c1 is
	select	1
	from	per_security_profiles
	where	upper(security_profile_name) = upper(P_SECURITY_PROFILE_NAME)
	and	(rowid <> P_ROW_ID or P_ROW_ID is null);
begin
	open c1;
	fetch c1 into l_dummy;
	--
	if c1%found then
		close c1;
		fnd_message.set_name('PAY', 'PER_7062_DEF_SECPROF_EXISTS');
		fnd_message.raise_error;
	end if;
	close c1;
	--
end check_uniqueness;
------------------------------------------------------------------------------
procedure chk_reporting_username_unique(
	p_reporting_oracle_username	varchar2,
	p_row_id			varchar2,
	p_is_base_user			IN OUT NOCOPY varchar2) is
	l_dummy				number;
--
-- Uniqueness check on reporting username as well as returning whether this
-- user is the base user. This info will be used to ensure that View All = Y.
--
cursor c1 is
	select	1
	from	per_security_profiles
	where	reporting_oracle_username	= P_REPORTING_ORACLE_USERNAME
	and	(rowid <> P_ROW_ID or P_ROW_ID is null);
--
cursor c2 is
	select	1
	from	all_tables
	where	owner		= P_REPORTING_ORACLE_USERNAME
	and	table_name	= 'PER_ALL_PEOPLE_F';
--
begin
	open c1;
	fetch c1 into l_dummy;
	if c1%found then
		close c1;
		fnd_message.set_name('PAY', 'PER_7063_DEF_SECPROF_USERNAME');
		fnd_message.raise_error;
	end if;
	close c1;
	--
	open c2;
	fetch c2 into l_dummy;
	if c2%found then
		p_is_base_user	:= 'Y';
	else
		p_is_base_user	:= 'N';
	end if;
	close c2;
	--
end chk_reporting_username_unique;
------------------------------------------------------------------------------
procedure pre_delete_validation(
	p_security_profile_id		number,
	p_view_all_flag			varchar2,
	p_secgen_warn			IN OUT NOCOPY varchar2) is
        l_dummy                         number;
--
-- Return p_secgen_warn = Y if there are people in the person_list for this
-- security profile (where client-side should act on warning).
--
cursor ppl is
	select	1
	from	per_person_list
	where	security_profile_id	= P_SECURITY_PROFILE_ID;
begin
--
-- Checks for business groups using this profile (where profiles are
-- created on creation of business group).
--
	p_secgen_warn := 'N';
	if p_view_all_flag = 'N' then
		open ppl;
		fetch ppl into l_dummy;
		if ppl%found then
			p_secgen_warn := 'Y';
		end if;
		close ppl;
	end if;
	--
end pre_delete_validation;
------------------------------------------------------------------------------
function check_sql_fragment(p_restriction_text VARCHAR2)
return boolean is
  l_sql_statement varchar2(20000);
  l_cursor INTEGER;
begin
--
  l_sql_statement:='select PERSON.person_id
from per_all_people_f PERSON
,    per_all_assignments_f ASSIGNMENT
where PERSON.person_id=ASSIGNMENT.person_id
and '||p_restriction_text;

  -- Bug 3648079
  -- This procedure was executing the SQL statement and affecting the
  -- performance of 'Verify' custom SQL function in the Define Security
  -- Profile form. The procedure is changed to parse the sql statement
  -- instead of executing it.
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor,l_sql_statement,dbms_sql.NATIVE);
  return TRUE;

EXCEPTION
  when others then
    --
    -- There was an error whilst trying to verify the
    -- custom restriction.  Wrap the SQL error in a message
    -- and raise it back to the user.
    --
    fnd_message.set_name('PER','HR_289835_PSP_CUSTOM_ERR');
    fnd_message.set_token('SQLERRM',SQLERRM);
    fnd_message.raise_error;
end check_sql_fragment;

-- Bug #2809163
procedure check_assigned_sec_profile(p_security_profile_id number)is
--
l_exists varchar2(1);
--
/*cursor sec_profile is
       select 'x'
       from fnd_profile_option_values fpv
       where fpv.profile_option_value = to_char(p_security_profile_id);
       */

-- Modified the cursor as follows  for bug 5006762
--
cursor sec_profile is
       select 'x'
       from fnd_profile_option_values fpv ,
        fnd_profile_options fp
       where fpv.profile_option_value = to_char(p_security_profile_id)
       -- added the following
       and fp.application_id = fpv.application_id
	  and fp.profile_option_id = fpv.profile_option_id
	  and fp.PROFILE_OPTION_NAME = 'PER_SECURITY_PROFILE_ID';

-- end of bug 5006762
--
begin
--
-- Checks that the security profile is already assigned to any responsibility
-- If assigned, then user is not supposed to delete the profile
open sec_profile;
fetch sec_profile into l_exists;
IF sec_profile%found THEN
  hr_utility.set_message(800, 'PER_289480_SEC_PROFILE_VALUE');
  close sec_profile;
  hr_utility.raise_error;
END IF;
--
close sec_profile;
--
end check_assigned_sec_profile;
--

END PER_SECURITY_PROFILES_PKG;

/
