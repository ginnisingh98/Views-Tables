--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATION" AS
/* $Header: peorganz.pkb 120.1 2008/02/06 12:01:45 pchowdav ship $ */
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
 ==================================================================

 Name        : hr_organization  (BODY)

 Description : Contains the definition of organization procedures
               as declared in the hr_organization package header

 Uses        : hr_utility

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    17-NOV-92 SZWILLIA             Date Created
 70.1    17-NOV-92 SZWILLIA             Corrected Message Calls.
 70.2    17-NOV-92 SZWILLIA             Corrected Message Names.
 70.3    02-DEC-92 SZWILLIA             Added Procedure to insert
                                        Business Group Details
                                        from hr_org_info_ari.
 70.4    12-JAN-93 SZWILLIA             Removed insert into status
                                        types from insert bg details.
 70.6    20-JAN-93 SZWILLIA             Corrected error handling.
 70.7    26-JAN-93 SZWILLIA             Changed INSERT into
                                         PER_SECURITY_PROFILES.
 70.9    01-MAR-93 TMATHERS             Added Procedure to execute
                                        pre-delete checks(org_predel_check).
 70.10   01-MAR-93 TMATHERS             Allowed user to delete a business group
                                        if the only organization it contained
                                        was itself.
 70.11   04-MAR-93 SZWILLIA             Changed parameters to DATE
 70.12   11-MAR-93 NKHAn		Added 'exit' to the end
 70.13   17-MAR-93 SZWILLIA             Changed insert into security_profiles
 70.14   31-MAR-93 TMATHERS             Removed org_predel_check to seperate
                                        package.
 70.15   01-APR-93 TMATHERS             Added shared organization predelete
                                        checks procedure for CBB.
 70.16   01-APR-93 TMATHERS             Corrected mistake made by previous
                                        Change.
 70.17   05-APR-93 TMATHERS             Took out Jobs and Positions references
                                        and placed in a separate procedure.
                                        In order that the applications who
                                        choose not to use J and P's when
                                        they have the Org CBB, can still have
                                        pre-delete validation.
 70.18   05-APR-93 TMATHERS             Didn't like the ampersand in above
                                        comment changed to and.
 70.19   22-APR-93 TMATHERS             Added hr_weak_bg_chk, fixed
                                        unique_name to include checks
                                        for business groups.
 70.20   30-APR-93 TMATHERS             Added exists clause to
                                        unique name check to stop
                                        TOO_MANY_ROWS exception firing.
                                        When a BG and an org in the current
                                        BG have the same name.
 70.21   04-MAY-93 TMATHERS             changed HR_ORGANIZATION_UNITS
                                        to HR_ALL_ORGANIZATION_UNITS in
                                        unique name check
 70.22   06-MAY-93 SZWILLIA             Changed above back as security does
                                        not apply in packages.(Always created
                                        in the base user).
                                        Changed insert_bus_grp_details to
                                        insert 'user' if running in install
                                        mode (ie no rows in
                                        FND_PRODUCT_INSTALLATIONS.
-------------------------------------------------------------------------------
 70.25   04-AUG-93 TMATHERS             removed reference to
                                        product_security_type in
                                        per_security_profiles.
 70.26   02-JUN-94 TMathers             Added get_flex_msg as a result of
                                        using FND PLSQL in PERORDOR.
 70.29   23-NOV-94 Rfine                Suppressed index on business_group_id
 70.30   15-DEC-94 Rfine                Added code to insert a row into
					pay_consolidation_sets for the new
					business group.
 70.31   17-Apr-95 SDesai/JThuringer	Added ins_si_type procedure and code
					for enabling ADA flex structures for
					US business groups.
 70.32	 25-Apr-95 SDesai		Code to enable OSHA flex structure;
					use p_org_information9 to check if
					it is a US business group.
 70.33   25-JUL-95 AForte		Changed tokenised message
					PAY_6361_USER_TABLE_UNIQUE
					to hard coded message
					PAY_7682_USER_ORG_TABLE_UNIQUE
 70.34   02-AUG-95 JThuringer           Change the way in which View All
                                        security profiles are created.
                                        If running against 10.5, set the
                                        secure_oracle_username to the HR Oracle
                                        ID. If running against 10.6 or later use
                                        the APPS Oracle ID.
 70.35   11-Sep-95 SDesai		Check that the organization is not a
					beneficiary (org_predel_check).
 110.1   05-aug-97 mstewart             Removed reference to now obsolete
					secure_oracle_username column
 110.2   19-AUG-97 DKerr                Check hr_all_organization_units rather
					than view when inserting sec. profile.
 110.3   19-SEP-97 DKerr                Ensure that the security profile id
                                        for the setup business group is 0.
                                        Removed obsolete code from earlier
                                        releases.
 110.4   25-JAN-98 GPerry               Added in benefits installation check
                                        in order to seed life events for
                                        a business_group. This consisted of
                                        alterations to insert_bus_grp_details.
                                        Written in dynamic PLSQL as benefits
                                        is still BETA.
 110.5   16-JUN-98 GPerry               Changed name of benefits special
                                        procedure for use when seeding all
                                        benefits data. Written in dynamic
                                        PLSQL as product is BETA. Procedure
                                        seed_life_events =>
                                        becomes seed_benefit_data.
                                        Added call to seed person types.
 110.6   16-JUN-98 GPerry               Didn't dual maintain first time.
 110.7   28-OCT-98 STee                 Added call to seed action types
                                        and communication types.
 115.3   10-DEC-98 VTreiger             MLS modications for New Business Group.
 115.4   11-DEC-98 MStewart             Added code in insert_bus_grp_details
                                        to create a security group and
                                        populate the org_information14 column.
 115.5   29-DEC-98 VTreiger             Modified per_person_types table population,
                                        because we support only one table
                                        per_startup_person_types_tl.

 115.6   13-JAN-99 MStewart             Removed code to create security group
                                        and populate the org_info14 column
                                        since this is now done elsewhere.
 115.7   20-JAN-99 VTreiger             Modified per_person_types table population,
                                        because the latest version of translated table
                                        PER_STARTUP_PERSON_TYPES_TL now has column
                                        DEFAULT_FLAG.
 115.11  11-JUN-99 MElori-M             Added cursor get_usr_rows and code to
                                        insert rows into pay_user_column_instances_f
                                        whenever a new business group is created.
                                        Added commit statement at the end of package
                                        script.
 115.12  03-NOV-99 STee                 Added call to seed regulations.
 115.15  14-Dec-99 Tmathers             Moved seed benefits data
                                        out of US only code.
 115.16  05-Jun-00 CCarter              Added parameter p_org_information6
								to insert_bus_grp_details in order to
								perform an insert to PER_JOB_GROUPS to
								create a Job Group everytime a Business
								Group is created.
 115.17  30-Oct-00 VTreiger             Added check for api_dml call to provide
                                        processing when using Org APIs.
 115.18  06-jun-01 Tmathers             Changed check for ben install
                                        prod 805 to prod 800 HR so OSB users
                                        automatically get seed data created on
                                        Busines group creation. DOes nothing
                                        if HR is in shared mode( as no benefits
                                        Advanced, Standard or Basic exist then.)
                                        WWBUG 1771423.
 115.19  07-Dec-01 DCasemor             Bug 2140866.
                                        Passsed org_security_mode to the insert
                                        of the default security profile for a
                                        new Business Group.
 115.20  11-Dec-01 DCasemor             Fixed GSCC compliance errors.

 115.21  170Apr-02 ACowan               Added view_all_cwk column to
                                        default security profile insert

                   ACowan               Added insert to per_number_generation
                                        _controls for CWK type.
  115.24 09-JUN-02 ACowan		Added view_all_contacts column to
					default security profile insert.
  115.25 18-Jun-02 M Bocutt  2407927    Use first 60 characters for the name
                                        of the default consolidation set created
					when BG info is saved. Cope with
					duplicates by not creating the set
					although this should never happen.
  115.28 09-DEC-03 S Nukala  3303179    Used l_row_count instead of using
                                        SQL%ROWCOUNT multiple times.
  115.29 09-DEC-03 S Nukala  3303179    Corrected another scenario along
                                        with the 2 places mentioned above.
  115.30 10-FEB-04 D Casemore 3346940   Included the 3 columns added to
                                        the security profiles table as
                                        part of the Assignment and User
                                        security enhancements.
  115.31 21-JUN-04  adudekul  3648765   Performance fixes.
  115.32 24-NOV-04  kjagadee  4029500   Modified proc insert_bus_grp_details
                                        to include the new column
                                        view_all_candidates_flag as part of
                                        Candidate Security enhancements.
  115.33 06-FEB-08  pchowdav  6792619   Modified procedure insert_bus_grp_details.
 =================================================================
*/

---------------------- ins_si_type -------------------------
procedure ins_si_type ( p_business_group_id     NUMBER,
                        p_creation_date         DATE,
                        p_created_by            NUMBER,
                        p_last_update_date      DATE,
                        p_last_updated_by       NUMBER,
                        p_last_update_login     NUMBER,
                        p_flex_num              NUMBER,
			p_flex_category		VARCHAR2 ) is
/*
  NAME:
    ins_si_type
  DESCRIPTION
    Enable ADA Special Information Types for a US business group.
  PARAMETERS
*/
--
l_special_info_type_id number;
begin
--
hr_utility.set_location('hr_organization.ins_si_type', 1);
select per_special_info_types_s.nextval
into   l_special_info_type_id
from   dual;
--
insert into per_special_info_types
        (special_information_type_id,
        business_group_id,
        id_flex_num,
        enabled_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
values (l_special_info_type_id,
        p_business_group_id,
        p_flex_num,
        'Y',
        p_creation_date,
        p_created_by,
        p_last_update_date,
        p_last_updated_by,
        p_last_update_login);
--
insert into per_special_info_type_usages
	(special_info_category,
	 special_information_type_id,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 created_by,
	 creation_date)
values
	(p_flex_category,
	 l_special_info_type_id,
	 p_last_update_date,
         p_last_updated_by,
	 p_last_update_login,
	 p_created_by,
	 p_creation_date);
--
--
end ins_si_type;
--
procedure seed_benefit_data(p_business_group_id in number) is
  --
  l_cursor_handle     integer;
  l_dbms_sql_feedback integer;
  --
begin
  --
  hr_utility.set_location('Entering hr_organization.seed_benefit_data',1);
  --
  -- Seed benefit life events
  --
  l_cursor_handle := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor_handle,
                 'begin ben_seed_life_events.seed_life_events(:business_group_id); end;',
                  dbms_sql.v7);
  dbms_sql.bind_variable(l_cursor_handle,':business_group_id',p_business_group_id);
  l_dbms_sql_feedback := dbms_sql.execute(l_cursor_handle);
  dbms_sql.close_cursor(l_cursor_handle);
  --
  -- Seed benefit person types
  --
/*
  l_cursor_handle := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor_handle,
                 'begin ben_seed_person_types.seed_person_types(:business_group_id); end;',
                  dbms_sql.v7);
  dbms_sql.bind_variable(l_cursor_handle,':business_group_id',p_business_group_id);
  l_dbms_sql_feedback := dbms_sql.execute(l_cursor_handle);
  dbms_sql.close_cursor(l_cursor_handle);
*/
  --
  -- Seed enrollment action item types.
  --
  l_cursor_handle := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor_handle,
                 'begin ben_seed_action_item_types.seed_action_item_types(:business_group_id); end;',
                  dbms_sql.v7);
  dbms_sql.bind_variable(l_cursor_handle,':business_group_id',p_business_group_id);
  l_dbms_sql_feedback := dbms_sql.execute(l_cursor_handle);
  dbms_sql.close_cursor(l_cursor_handle);
  --
  -- Seed communication types.
  --
  l_cursor_handle := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor_handle,
                 'begin ben_seed_communication_types.seed_communication_types(:business_group_id); end;',
                  dbms_sql.v7);
  dbms_sql.bind_variable(l_cursor_handle,':business_group_id',p_business_group_id);
  l_dbms_sql_feedback := dbms_sql.execute(l_cursor_handle);
  dbms_sql.close_cursor(l_cursor_handle);
  --
  -- Seed regulations.
  --
  l_cursor_handle := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor_handle,
                 'begin ben_seed_regulations.seed_regulations(:business_group_id); end;',
                  dbms_sql.v7);
  dbms_sql.bind_variable(l_cursor_handle,':business_group_id',p_business_group_id);
  l_dbms_sql_feedback := dbms_sql.execute(l_cursor_handle);
  dbms_sql.close_cursor(l_cursor_handle);
  --
  hr_utility.set_location('Leaving hr_organization.seed_benefit_data',1);
  --
end seed_benefit_data;
----------------------- insert_bus_grp_details -------------------
--  Called by hr_org_info_ari
--
PROCEDURE insert_bus_grp_details (p_organization_id   NUMBER
                                 ,p_org_information9  VARCHAR2
                                 ,p_org_information6  VARCHAR2
                                 ,p_last_update_date  DATE
                                 ,p_last_updated_by   NUMBER
                                 ,p_last_update_login NUMBER
                                 ,p_created_by        NUMBER
                                 ,p_creation_date     DATE)
IS
--
  cursor chk_ada_enabled is
         select 'Y'
  	 from   fnd_id_flex_structures
	 where  enabled_flag = 'Y'
	 and    id_flex_num in (50129, 50130)
	 and    id_flex_code = 'PEA';
--
  cursor chk_osha_enabled is
	 select 'Y'
	 from   fnd_id_flex_structures
         where  enabled_flag = 'Y'
         and    id_flex_num  = 50131
	 and    id_flex_code = 'PEA';
--
  cursor chk_hr_installed is
         select null
         from   fnd_product_installations
         where  application_id = 800
         and    status = 'I';
--
  cursor sel_id_flex_num (p_flex_type varchar2) is
         select to_number(rule_mode)
         from   pay_legislation_rules
         where  legislation_code = 'US'
         and    rule_type        = p_flex_type;
--
  cursor sel_startup_per_types is
         select system_person_type,user_person_type
           ,default_flag
         from   per_startup_person_types_tl
         where  userenv('LANG') = language
         order by system_person_type,user_person_type;
--
  cursor get_usr_rows is

         select distinct
           ur.user_row_id, uc.user_column_id
         from
           pay_user_columns uc,
           pay_user_tables ut,
           pay_user_rows_f ur
         where
           ut.user_table_name = 'EXCHANGE_RATE_TYPES'
         and
           ur.user_table_id = ut.user_table_id
         and
           uc.user_table_id = ur.user_table_id
         and ut.user_table_id = uc.user_table_id -- Added for bug 3648765
         and
           uc.user_column_name = 'Conversion Rate Type';
--
  l_apps_account		VARCHAR2(1) := null;
  l_install_mode 		VARCHAR2(1) := 'N';
  l_ada_enabled      		VARCHAR2(1) := 'N';
  l_osha_enabled		VARCHAR2(1) := 'N';
  l_dummy       		VARCHAR2(1);
  l_disability_id_flex_num	NUMBER;
  l_disability_acc_id_flex_num  NUMBER;
  l_osha_id_flex_num		NUMBER;
  l_security_group_name         hr_all_organization_units.name%TYPE;
  l_security_group_id           NUMBER;
--
  l_system_person_type          VARCHAR2(30);
  l_system_person_type_old      VARCHAR2(30) := ' ';
  l_user_person_type            VARCHAR2(80);
  l_default_flag                VARCHAR2(30);
  l_row_count                   NUMBER := 0;
  l_person_type_id              NUMBER;
--
  l_usr_row_id                  NUMBER(9);
  l_usr_col_id                  NUMBER(9);
--
  c_consolidation_set_name_len  NUMBER(9) := 60;
begin
--
--
  hr_utility.set_location('hr_organization.insert_bus_grp_details',1);
-- MLS modification
-- we have only one table per_startup_person_types_tl !!!!
  INSERT INTO per_person_types
  (seeded_person_type_key
  ,person_type_id
  ,active_flag
  ,business_group_id
  ,default_flag
  ,system_person_type
  ,user_person_type
  )
  SELECT
   seeded_person_type_key
  ,per_person_types_s.nextval
  ,'Y'
  ,p_organization_id
  ,psp.default_flag
  ,psp.system_person_type
  ,psp.user_person_type
  FROM   per_startup_person_types_tl psp
  WHERE  psp.language = userenv('LANG');
--
-- Bug Number: 3303179: Used l_ow_count instead of using SQL%ROWCOUNT multiple times.
--
l_row_count := SQL%ROWCOUNT ;
hr_utility.set_location('rows : '||to_number(l_row_count),99);
--
  if l_row_count = 0 then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'hr_organization.insert_bus_grp_details');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
--
l_row_count := 0;
--
--  MLS
--
  hr_utility.set_location('hr_organization.insert_bus_grp_details',101);
  INSERT INTO per_person_types_tl
  (person_type_id
  ,user_person_type
  ,language
  ,source_lang
  )
  SELECT
   ppt.person_type_id
  ,pptl.user_person_type
  ,pptl.language
  ,pptl.source_lang
  FROM PER_PERSON_TYPES ppt,
       PER_STARTUP_PERSON_TYPES_TL pptl
  WHERE ppt.business_group_id = p_organization_id
    AND ppt.seeded_person_type_key = pptl.seeded_person_type_key;
--
-- Bug Number: 3303179: Used l_ow_count instead of using SQL%ROWCOUNT multiple times.
--
l_row_count := SQL%ROWCOUNT;
hr_utility.set_location('rows : '||to_number(l_row_count),100);
--
  if l_row_count = 0 then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'hr_organization.insert_bus_grp_details');
    hr_utility.set_message_token('STEP','101');
    hr_utility.raise_error;
  end if;
--
l_row_count := 0;
--
-- MLS end
--
  hr_utility.set_location('hr_organization.insert_bus_grp_details',2);
  INSERT INTO per_number_generation_controls
  (business_group_id
  ,type
  ,next_value)
  VALUES
  (p_organization_id
  ,'EMP'
  ,1);
--
--
  hr_utility.set_location('hr_organization.insert_bus_grp_details',3);
  INSERT INTO per_number_generation_controls
  (business_group_id
  ,type
  ,next_value)
  values
  (p_organization_id
  ,'APL'
  ,1);
--
--
  hr_utility.set_location('hr_organization.insert_bus_grp_details',4);
  INSERT INTO per_number_generation_controls
  (business_group_id
  ,type
  ,next_value)
  values
  (p_organization_id
  ,'CWK'
  ,1);
--
  begin
  hr_utility.set_location('hr_organization.insert_bus_grp_details',5);
  SELECT 'Y'
  INTO   l_install_mode
  FROM   sys.dual
  WHERE NOT EXISTS (SELECT null
                    FROM   fnd_product_installations
                    WHERE  application_id = 800
                    AND    status         IN ('I','S'));
  --
  exception when NO_DATA_FOUND then null;
  end;
--
--  If AOL product version is 6.0.27 then we have a 10.5 install and the APPS
--  account does not exist.
--  If AOL product version is not 6.0.27 we have an install of 10.6 or higher,
--  and the APPS account will exist.
--
  begin
  hr_utility.set_location('hr_organization.insert_bus_grp_details',6);
  SELECT 'N'
  INTO   l_apps_account
  FROM   fnd_product_installations
  WHERE  application_id = 0
  AND    product_version = '6.0.27';
--
  exception when NO_DATA_FOUND then l_apps_account := 'Y' ;
  end;
--

  if ( l_apps_account = 'Y' ) then

--   We are running 10.6 or later and the APPS account exists
--
--   if l_install_mode = 'Y' we have no way of accessing the APPS oracle ID.
--   So we have to create the View All security profile by running a script
--   that takes, as a parameter, the AOL username. We can derive the APPS
--   Oracle ID if we know the AOL username.
--
     if l_install_mode = 'N'  then
--
--   Set the secure_oracle_username for the View All security profile to the
--   Oracle ID for the APPS account. This can be derived by looking in
--   fnd_oracle_userid f1r an oracle_username with oracle_id = 900
--
     hr_utility.set_location('hr_organization.insert_bus_grp_details',8);
     INSERT INTO per_security_profiles
     (security_profile_id
     ,business_group_id
     ,include_top_organization_flag
     ,include_top_position_flag
     ,security_profile_name
     ,view_all_flag
     ,view_all_organizations_flag
     ,view_all_payrolls_flag
     ,view_all_positions_flag
     ,view_all_applicants_flag
     ,view_all_employees_flag
     ,view_all_cwk_flag
     ,view_all_contacts_flag
     ,view_all_candidates_flag
     ,reporting_oracle_username
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,created_by
     ,creation_date
     ,org_security_mode
     ,restrict_on_individual_asg
     ,top_organization_method
     ,top_position_method)
     SELECT decode(p_organization_id,0,0,per_security_profiles_s.nextval)
     ,p_organization_id
     ,'Y'
     ,'Y'
     ,hou.name
     ,'Y'
     ,'Y'
     ,'Y'
     ,'Y'
     ,'Y'
     ,'Y'
     ,'Y'
     ,'Y'
     ,'Y'
     ,null
     ,p_last_update_date
     ,p_last_updated_by
     ,p_last_update_login
     ,p_created_by
     ,p_creation_date
     ,'NONE'
     ,'N'
     ,'S'
     ,'S'
     FROM   hr_all_organization_units  hou,
            fnd_oracle_userid          o
     WHERE  hou.organization_id = p_organization_id
       AND  o.oracle_id = 900;
--
     if SQL%ROWCOUNT = 0 then
        hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE',
                                 'hr_organization.insert_bus_grp_details');
        hr_utility.set_message_token('STEP','8');
        hr_utility.raise_error;
     end if;
--
     end if;
--
  end if;
--
insert into PER_JOB_GROUPS
(job_group_id
,business_group_id
,legislation_code
,internal_name
,displayed_name
,id_flex_num
,master_flag
,object_version_number
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login)
 values (per_job_groups_s.nextval
,p_organization_id
,null
,'HR_'||to_char(p_organization_id)
,'HR_'||to_char(p_organization_id)
,p_org_information6
,'N'
,1
,p_creation_date
,p_created_by
,p_last_update_date
,p_last_updated_by
,p_last_update_login);
--
  hr_utility.set_location('hr_organization.insert_bus_grp_details',9);
  begin
    INSERT INTO pay_consolidation_sets
    (consolidation_set_id
    ,business_group_id
    ,consolidation_set_name
    ,comments
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date)
    SELECT pay_consolidation_sets_s.nextval
    ,p_organization_id
    ,substr(hou.name,1,c_consolidation_set_name_len)
    ,null
    ,p_last_update_date
    ,p_last_updated_by
    ,p_last_update_login
    ,p_created_by
    ,p_creation_date
    FROM   hr_all_organization_units      hou
    WHERE  hou.organization_id = p_organization_id;
--
--
-- Bug Number: 3303179: Used l_ow_count instead of using SQL%ROWCOUNT after the hr_utility call.
--
   l_row_count := SQL%ROWCOUNT;
--
    hr_utility.set_location('hr_organization.insert_bus_grp_details',91);

    if l_row_count = 0 then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'hr_organization.insert_bus_grp_details');
      hr_utility.set_message_token('STEP','9');
      hr_utility.raise_error;
    end if;
  exception
    when no_data_found then
       hr_utility.set_location('hr_organization.insert_bus_grp_details',92);
       null;
    when others then
      hr_utility.set_location('hr_organization.insert_bus_grp_details',93);
      raise;
  end;
--
   l_row_count := 0;
--
  open get_usr_rows;
  loop
--
    fetch get_usr_rows into l_usr_row_id, l_usr_col_id;
    exit when get_usr_rows%NOTFOUND;
--
  hr_utility.set_location('hr_organization.insert_bus_grp_details',10);
-- VT added condition for Org API call
IF NOT hr_ori_shd.return_api_dml_status THEN
  INSERT INTO pay_user_column_instances_f
  (user_column_instance_id
  ,effective_start_date
  ,effective_end_date
  ,user_row_id
  ,user_column_id
  ,business_group_id
  ,legislation_code
  ,legislation_subgroup
  ,value
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  SELECT
  pay_user_column_instances_s.nextval
  ,fnd_sessions.effective_date
  ,hr_general.end_of_time
  ,l_usr_row_id
  ,l_usr_col_id
  ,p_organization_id
  ,null
  ,null
  ,'Corporate'
  ,p_last_update_date
  ,p_last_updated_by
  ,p_last_update_login
  ,p_created_by
  ,p_creation_date
  FROM fnd_sessions
  WHERE session_id = userenv('sessionid');
ELSE
  INSERT INTO pay_user_column_instances_f
  (user_column_instance_id
  ,effective_start_date
  ,effective_end_date
  ,user_row_id
  ,user_column_id
  ,business_group_id
  ,legislation_code
  ,legislation_subgroup
  ,value
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  SELECT
  pay_user_column_instances_s.nextval
  ,hr_general.start_of_time
  ,hr_general.end_of_time
  ,l_usr_row_id
  ,l_usr_col_id
  ,p_organization_id
  ,null
  ,null
  ,'Corporate'
  ,p_last_update_date
  ,p_last_updated_by
  ,p_last_update_login
  ,p_created_by
  ,p_creation_date
  FROM sys.dual;
END IF;
--
--fix for bug 6792619.
    l_row_count := SQL%ROWCOUNT;
--
    hr_utility.set_location('hr_organization.insert_bus_grp_details',101);

    if l_row_count = 0 then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'hr_organization.insert_bus_grp_details');
    hr_utility.set_message_token('STEP','9');
    hr_utility.raise_error;
    end if;
    hr_utility.set_location('hr_organization.insert_bus_grp_details',102);

   end loop;
  close get_usr_rows;
--
--
-- Enable ADA flex structures for US business groups.
--
-- NOTE:  This procedure assumes that 2 special info type key flex structures
--        (id_flex_code = 'PEA') have been seeded :
--
--        ID_FLEX_STRUCTURE_NAME          ID_FLEX_NUM
--        ----------------------          -----------
--        ADA Disabilities                50129
--        ADA Disability Accomodations    50130
--
--        This procedure cannot rely on the id_flex_nums being present in
--        pay_legislation_rules because pay_legislation_rules might
--        not been seeded with data at the time that this procedure is run.
--        pay_legislation_rules is seeded as a post-install step as part of
--        US startup data delivery.  This procedure is run by Autoinstall
--        during creation of the Setup Business Group.
--
--
  hr_utility.set_location('hr_organization.insert_bus_grp_details', 8);
--
-- Ideally we would create ADA special info type rows if business group being
-- inserted is a US business group. But cannot check legislation_code on
-- per_business_groups due to mutating table error.
-- Hence checking to see if ADA key flex structures enabled for PEA key flex.
--
--
--
if p_org_information9 = 'US' then
--
  open  chk_ada_enabled;
  fetch chk_ada_enabled into l_ada_enabled;
  close chk_ada_enabled;
--
   if l_ada_enabled = 'Y' then
--
     l_disability_id_flex_num     := 50129;
     l_disability_acc_id_flex_num := 50130;
--
     open  sel_id_flex_num('ADA_DIS');
     fetch sel_id_flex_num into l_disability_id_flex_num;
     close sel_id_flex_num;
--
     open  sel_id_flex_num('ADA_DIS_ACC');
     fetch sel_id_flex_num into l_disability_acc_id_flex_num;
     close sel_id_flex_num;
--
     ins_si_type (p_business_group_id => p_organization_id,
                  p_creation_date     => p_creation_date,
                  p_created_by        => p_created_by,
                  p_last_update_date  => p_last_update_date,
                  p_last_updated_by   => p_last_updated_by,
                  p_last_update_login => p_last_update_login,
                  p_flex_num          => l_disability_id_flex_num,
		  p_flex_category     => 'ADA');
--
     ins_si_type (p_business_group_id => p_organization_id,
                  p_creation_date     => p_creation_date,
                  p_created_by        => p_created_by,
                  p_last_update_date  => p_last_update_date,
                  p_last_updated_by   => p_last_updated_by,
                  p_last_update_login => p_last_update_login,
                  p_flex_num          => l_disability_acc_id_flex_num,
		  p_flex_category     => 'ADA');
--
  end if;
--
--
-- Enable OSHA flex structure  for US business groups.
--
-- NOTE: This procedure assumes that 1 special info type key flex structures
--        (id_flex_code = 'PEA') has been seeded :
--
--	  ID_FLEX_STRUCTURE_NAME          ID_FLEX_NUM
--        ----------------------          -----------
--	  OSHA-reportable Incident	  50131
--
--
  open chk_osha_enabled;
  fetch chk_osha_enabled into l_osha_enabled;
  close chk_osha_enabled;
--
  if l_osha_enabled = 'Y' then
--
     l_osha_id_flex_num	:= 50131;
--
     open sel_id_flex_num('OSHA');
     fetch sel_id_flex_num into l_osha_id_flex_num;
     close sel_id_flex_num;
--
     ins_si_type (p_business_group_id => p_organization_id,
                  p_creation_date     => p_creation_date,
                  p_created_by        => p_created_by,
                  p_last_update_date  => p_last_update_date,
                  p_last_updated_by   => p_last_updated_by,
                  p_last_update_login => p_last_update_login,
                  p_flex_num          => l_osha_id_flex_num,
                  p_flex_category     => 'OSHA');
--
  end if;
  --
  -- For US OSHA, Default case numbers have to be populated
  -- Added the following code for US OSHA specific changes
    --
    for x in 1900 .. 2200 loop
    --
      insert into per_us_osha_numbers(
                      case_year,
                      business_group_id,
                      next_value,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      created_by,
                      creation_date)
              values (x,
                      p_organization_id,
                      1,
                      p_last_update_date,
                      p_last_updated_by,
                      p_last_update_login,
                      p_created_by,
                      p_creation_date
                      );
    --
    end loop;
    --
--
end if;  -- enabling US specific flex structures.
--
-- Check if HR fully installed if not dont create ben data.
-- used to be a check for BEN fully but OSB requires the data also.
-- tm 06/12/01
-- 1771423.
--
   open chk_hr_installed;
--
   fetch chk_hr_installed into l_dummy;
   if chk_hr_installed%found then
   --
      seed_benefit_data(p_business_group_id => p_organization_id);
   --
   end if;
   --
   close chk_hr_installed;
--

end insert_bus_grp_details;
--
--
--
PROCEDURE  unique_name
  (p_business_group_id NUMBER,
   p_organization_id NUMBER,
   p_organization_name VARCHAR2)
--
IS
--
  org_check VARCHAR2(1);
--
begin
--
--
  hr_utility.set_location('hr_organization.unique_name',1);
  SELECT 'Y'
  INTO   org_check
  FROM   sys.dual
  WHERE  exists
     (
     SELECT 'Name Already Exists'
     FROM   hr_organization_units org
     WHERE (org.organization_id <> p_organization_id
	OR  p_organization_id IS NULL)
     AND    p_organization_name   = org.name
     AND    (org.business_group_id + 0 = p_business_group_id
	   or p_organization_id + 0 = p_business_group_id)
     );
--
  if org_check = 'Y' then
   hr_utility.set_message(801,'PAY_7682_USER_ORG_TABLE_UNIQUE');
   hr_utility.raise_error;
  end if;
--
  exception
   when NO_DATA_FOUND then null ;
--
end unique_name;
--
--
--
PROCEDURE date_range
  (p_date_from DATE,
   p_date_to   DATE)
--
IS
--
  l_eot DATE := to_date('31/12/4712','DD/MM/YYYY');
--
begin
--
  hr_utility.set_location('hr_organization.date_range',1);
--
  if p_date_from is null then
   hr_utility.set_message(801,'HR_6021_ALL_START_END_DATE');
   hr_utility.raise_error;
  elsif p_date_from > nvl(p_date_to, l_eot) then
     hr_utility.set_message(801,'HR_6021_ALL_START_END_DATE');
     hr_utility.raise_error;
  end if;
--
--
end date_range;
--
--
--------------------- BEGIN: org_predel_check --------------------------------
procedure org_predel_check(p_organization_id INTEGER
                          ,p_business_group_id INTEGER) is
/*
  NAME
    org_predel_check
  DESCRIPTION
    Battery of tests to see if an organization may be deleted.
  PARAMETERS
    p_organization_id  : Organization Id of Organization to be deleted.
    p_business_group_id   : Business Group id of rganization to be deleted.
*/
--
-- Storage Variable.
--
l_test_func varchar2(60);
--
begin
-- If the organization id equals the business group id then
-- it is a business group and so do all relavant checks for Business group.
if p_organization_id = p_business_group_id then
	begin
		begin
		-- Do Any rows Exist in PER_PEOPLE_F.
		hr_utility.set_location('hr_organization.org_predel_check',1);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from PER_PEOPLE_F x
		where x.business_group_id = p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6130_ORG_PEOPLE_EXIST');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
		--
		begin
		-- Do Any rows Exist in HR_ORGANIZATION_UNITS.
		hr_utility.set_location('hr_organization.org_predel_check',2);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from HR_ORGANIZATION_UNITS x
		where x.business_group_id = p_business_group_id
	        and   x.organization_id  <> p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6571_ORG_ORG_EXIST');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
		--
		--
		begin
		-- Do Any rows Exist in PER_ORG_STRUCTURE_ELEMENTS.
		hr_utility.set_location('hr_organization.org_predel_check',3);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from PER_ORG_STRUCTURE_ELEMENTS x
		where x.business_group_id = p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6569_ORG_IN_HIERARCHY');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
	end;
end if;
--
-- Now do all Organization specific checks.
--
begin
-- Do Any rows Exist in PER_ORG_STRUCTURE_ELEMENTS.
hr_utility.set_location('hr_organization.org_predel_check',4);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ORG_STRUCTURE_ELEMENTS x
where x.organization_id_child = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6569_ORG_IN_HIERARCHY');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Do Any rows Exist in PER_ORG_STRUCTURE_ELEMENTS.
hr_utility.set_location('hr_organization.org_predel_check',5);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ORG_STRUCTURE_ELEMENTS x
where x.organization_id_parent = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6569_ORG_IN_HIERARCHY');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Do any rows exist in BEN_BENEFICIARIES_F
hr_utility.set_location('hr_organization.org_predel_check', 6);
select '1'
into l_test_func
from sys.dual
where exists (select 1
from BEN_BENEFICIARIES_F x
where x.source_id = p_organization_id
and   x.source_type = 'O');
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_7994_ORG_BENEFICIARY_EXISTS');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
end org_predel_check;
--------------------- END: org_predel_check -----------------------------------
--
------------------- BEGIN: hr_weak_bg_chk -----------------------------------
procedure hr_weak_bg_chk(p_organization_id INTEGER) is
/*
  NAME
   hr_weak_bg_chk
  DESCRIPTION
   Tests to see whether a business group may be created from an existing
   organization.
  PARAMETERS
   p_organization_id : Identifier of the organization.
*/
--
-- Local Storage Variable.
l_test_func varchar2(60);
--
begin
--
begin
-- Doing check on PER_ASSIGNMENTS_F.
hr_utility.set_location('hr_organization.hr_weak_bg_chk',1);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ASSIGNMENTS_F x
where x.SOURCE_ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6718_BG_ASS_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_ASSIGNMENTS_F.
hr_utility.set_location('hr_organization.hr_weak_bg_chk',2);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ASSIGNMENTS_F x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6718_BG_ASS_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_ORG_STRUCTURE_ELEMENTS.
hr_utility.set_location('hr_organization.hr_weak_bg_chk',3);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ORG_STRUCTURE_ELEMENTS x
where x.ORGANIZATION_ID_PARENT = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6722_BG_ORG_HIER');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_ORG_STRUCTURE_ELEMENTS.
hr_utility.set_location('hr_organization.hr_weak_bg_chk',4);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ORG_STRUCTURE_ELEMENTS x
where x.ORGANIZATION_ID_CHILD = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6722_BG_ORG_HIER');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
--
begin
-- Doing check on PER_SECURITY_PROFILES.
hr_utility.set_location('hr_organization.hr_weak_bg_chk',5);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_SECURITY_PROFILES x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6724_BG_SEC_PROF_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
end hr_weak_bg_chk;
--------------------- END: hr_weak_bg_chk -----------------------------------
--
-- Procedure required due to FND PLSQL not being able to handle hr_message
--
procedure get_flex_msg is
begin
  hr_utility.set_message(801,'HR_FLEX_DISPLAY_MSG');
  hr_utility.raise_error;
end;
----------------------------------- End of get_flex_msg ----------------------

END hr_organization;

/
