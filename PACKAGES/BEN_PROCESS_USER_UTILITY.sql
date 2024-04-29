--------------------------------------------------------
--  DDL for Package BEN_PROCESS_USER_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROCESS_USER_UTILITY" AUTHID CURRENT_USER AS
/* $Header: benusrgb.pkh 115.1 2002/02/13 06:40:55 pkm ship        $ */
--
-- Public Global Variables
--
g_package  varchar2(33) := 'ben_process_user_utility.';
--
-- ----------------------------------------------------------------------------
-- NOTE: This package specification contains global variables only.  It does
--       not have any functions or procedures. The purpose of this specification
--       is to allow user hooks to communicate output information to the caller
--       api.
-- ----------------------------------------------------------------------------
-- USAGE NOTES FOR CREATING A USER NAME:
--     user_name - required, cannot be more than 100 characters.
--
--     password - optional.  If entered, the length cannot be more than the
--                length in SIGNON_PASSWORD_LENGTH profile option.  If null
--                value, a randomly generated 8-byte alphanumeric string will be
--                generated.
--
--     start_date - optional.  If null value, Today's Date will be
--                used.
--
--     end_date - optional.  If entered, it must be greater than start_date.
--
--     last_logon_date - optional. The date the user last signed on. Suggestion: Take Default.
--
--     password_date - optional. The date the current password was set. Suggestion: Take Default(Should never pass null).
--
--     password_accesses_left - optional. The number of accesses left for the password.Suggestion: Take Default.
--
--     password_lifespan_accesses - optional. No. of Accesses allowed for the password. Suggestion: Take Default.
--
--     p_password_lifespan_days - optional. Lifespan of the password. Suggestion: Take Default.
--
--     email_address - optional. If entered, cannot be more than 240 characters.
--
--     fax - optional. If entered, cannot be more than 80 characters.
--
--     description - optional.  If entered, cannot be more than 240 characters.
--
--     employee_id - optional.  If the user name is to associate to an employee,
--                then this field must contain a valid person_id in
--                per_all_people_f table.
--
--     customer_id - optional.  No validation is done on this field.  This field
--                is used by non Oracle Human Resources Application and this
--                program is intended for HR Application use only.
--
--     supplier_id - optional.  No validation is done on this field.  This field
--                is used by non Oracle Human Resources Application and this
--                program is intended for HR Application use only.
-----------------------------------------------------------------------------------
--
--RECORD STRUCTURE FOR FND_USERS
-- ==============================
   TYPE fnd_user_record IS RECORD
     (user_name                   fnd_user.user_name%type
     ,password                    varchar2(30)
     ,start_date                  fnd_user.start_date%type
     ,end_date                    fnd_user.end_date%type
     ,last_logon_date             fnd_user.last_logon_date%type
     ,password_date               fnd_user.password_date%type
     ,password_accesses_left      fnd_user.password_accesses_left%type
     ,password_lifespan_accesses  fnd_user.password_lifespan_accesses%type
     ,password_lifespan_days      fnd_user.password_lifespan_days%type
     ,email_address               fnd_user.email_address%type
     ,fax                         fnd_user.fax%type
     ,description                 fnd_user.description%type
     ,employee_id                 fnd_user.employee_id%type
     ,customer_id                 fnd_user.customer_id%type
     ,supplier_id                 fnd_user.supplier_id%type
     );
--
   g_fnd_user_record            fnd_user_record;
--
--
-- ----------------------------------------------------------------------------
-- USAGE NOTES FOR CREATING/UPDATING A RESPONSIBILTY, ASSOCIATING A
-- RESPONSIBILITY, SECURITY GROUP TO A USERNAME:
--
--  ***************************************************************************
--  If the profile option 'ENABLE_SECURITY_GROUPS' for the Application is 'Y',
--  then you'll need to populate the sec_group_id, sec_profile_id fields at the
--  end of this record structure.  The system will insert a row into
--  per_sec_profile_assignments as well as to fnd_user_resp_groups.
--
--  If the profile option 'ENABLE_SECURITY_GROUPS' for the Application is 'N',
--  that means you remain to use the R11 way of responsibility and security profile
--  set up.  There is no need to fill in the values of sec_group_id and
--  sec_profile_id fields.  The system will insert a row into fnd_user_resp_groups
--  only.
--***************************************************************************
--
--  responsibility_id - should never exceed length of
--                     fnd_responsibility.responsibility_id value(which is 15).
--
-- respons_application_id - cannot exceed the length of
--                     fnd_responsibility.application_id, which is a number type
--                     with a size of 15.
--
-- security_group_id -optional for 'ENABLE_SECURITY_GROUPS' profile option =
--                     'Y'. Length cannot exceed
--                     per_sec_profile_assignments.security_group_id, which is
--                     a number data type.  It must be a valid value in
--                     fnd_security_groups.security_group_id.
--                     If this field is null or sec_profile_id is null,
--                     then the view-all security profile for the employee's
--                     business group will be used.  No row will be inserted
--                     into per_security_profile_assignments.  Only 1 row will
--                     be inserted into fnd_user_resp_groups table.
--                     If 'ENABLE_SECURITY_GROUPS' profile option = 'N', leave
--                     this field null.
--
--  sec_profile_id - optional for 'ENABLE_SECURITY_GROUPS' profile option
--                     = 'Y'.  Length cannot exceed
--                     per_sec_profile_assignments.security_profile_id, which is
--                     a number data type.  It must be a valid value in
--                     per_security_profiles.security_profile_id.
--                     If this field is null or sec_profile_id is null,
--                     then the view-all security profile for the employee's
--                     business group will be used.  No row will be inserted
--                     into per_security_profile_assignments.  Only 1 row will
--                     be inserted into fnd_user_resp_groups table.
--                     If 'ENABLE_SECURITY_GROUPS' profile option = 'N', leave
--                     this field null.
--
----------------------------------------------------------------------------
--RECORD STRUCTURE FOR FND_RESPONSIBILITIES
-- =========================================
   TYPE fnd_resp_record IS RECORD
     (responsibility_id            fnd_responsibility.responsibility_id%type
     ,respons_application_id       fnd_responsibility.application_id%type
     ,security_group_id            fnd_security_groups.security_group_id%type
     ,security_profile_id          per_sec_profile_assignments.security_profile_id%type
     );
   g_fnd_resp_record            fnd_resp_record;
--
end ben_process_user_utility;

 

/
