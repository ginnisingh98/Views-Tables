--------------------------------------------------------
--  DDL for Package FND_USER_PKG_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_USER_PKG_WRP" AUTHID CURRENT_USER as
/* $Header: AFSCUSWS.pls 120.2.12010000.2 2015/03/13 15:42:31 emiranda ship $ */

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- user_synch
--   Wrapper for fnd_user_pkg.user_synch()
-- IN
--   p_user_name
--
procedure user_synch (p_user_name  in  varchar2);

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- derive_person_party_id
--   Wrapper for fnd_user_pkg.derive_person_party_id()
-- IN
--   p_user_name
--   p_customer_id
--   p_employee_id
--   p_log_exception
--
function derive_person_party_id (p_user_name  in  varchar2,
                                  p_customer_id in number,
                                  p_employee_id in number,
                                  p_log_exception in varchar2 default 'Y')
return number;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- set_old_user_name
--   Wrapper for fnd_user_pkg.set_old_user_name()
-- IN
--   p_old_user_name
--
function set_old_user_name (p_old_user_name  in  varchar2) return number;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- validate_user_name
--   Wrapper for fnd_user_pkg.validate_user_name()
-- IN
--   p_user_name
--
procedure validate_user_name (p_user_name  in  varchar2);

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- isPasswordChangable
--   Wrapper for fnd_user_pkg.isPasswordChangable()
-- IN
--   p_user_name
-- OUT
--   TRUE/FALSE
--
function isPasswordChangeable (p_user_name  in  varchar2) return boolean;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- ldap_wrapper_create_user
--   Wrapper for fnd_user_pkg.ldap_wrapper_create_user()
procedure ldap_wrapper_create_user (p_user_name  in  varchar2,
                                    p_unencrypted_password in varchar2,
                                    p_start_date in date,
                                    p_end_date in date,
                                    p_description in varchar2,
                                    p_email_address in varchar2,
                                    p_fax in varchar2);

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- ldap_wrapper_update_user
--   Wrapper for fnd_user_pkg.ldap_wrapper_update_user()
--
procedure ldap_wrapper_update_user (p_user_name  in  varchar2,
                                    p_unencrypted_password in varchar2,
                                    p_start_date in date,
                                    p_end_date in date,
                                    p_description in varchar2,
                                    p_email_address in varchar2,
                                    p_fax in varchar2,
                                    p_out_pwd in out nocopy varchar2);


-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- ldap_wrapper_change_user_name
--   Wrapper for fnd_user_pkg.ldap_wrapper_change_user_name()
-- IN
--   p_old_user_name
--   p_new_user_name
--
procedure ldap_wrapper_change_user_name (p_old_user_name in varchar2,
                                         p_new_user_name in varchar2);

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- forms_validate_password
--   Wrapper for fnd_web_sec.validate_password()
-- IN
--   p_username
--   p_new_password
--
function forms_validate_password (p_username in varchar2,
                                  p_new_password in varchar2)
return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- forms_change_user_pwd
--   This function figures out what should be stored in the
--   fnd_user encrypted_user_password and encrypted_foundation_password
--   columns and passes this back to forms so forms can do the commit.
-- IN
--   p_userid - user_id
--   p_username - user name
--   p_new_password - new user password
-- OUT
--   p_enc_user_pwd - encrypted user password/hash
--   p_enc_fnd_pwd -  encrypted fnd password or password metadata
-- RETURNS
--   'Y' or 'N' for success or failure
--   On failure message is on message dictionary stack.
--
function forms_change_user_pwd(p_userid in NUMBER,
                               p_username in VARCHAR2,
                               p_new_password in VARCHAR2,
                               p_enc_user_pwd out nocopy VARCHAR2,
                               p_enc_fnd_pwd out nocopy VARCHAR2)
return VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- forms_oracleuser_pwd
--   This function is created as a WRAPPER for a FORMS call
--   of the function FND_WEB_SEC.int_cpass_ora that will update
--   fnd_oracle_userid encrypted_oracle_password
--   and also execute the DML "alter USER XXXX identified by PASSNEW "
-- IN
--   p_username     - user name
--   p_new_password - new user password
-- OUT
--   p_enc_oracle_pwd - encrypted oracle password/hash
-- RETURNS
--   'Y' or 'N' for success or failure
--   On failure message is on message dictionary stack.
--
function forms_oracleuser_pwd(p_username       in VARCHAR2,
                              p_new_password   in VARCHAR2,
                              p_enc_oracle_pwd out nocopy VARCHAR2)
return VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- forms_chg_system_pwd
--   This function is created as a WRAPPER for a FORMS call
--   of the function FND_WEB_SEC.int_cpass_sys that will update
--   the table fnd_oracle_userid encrypted_oracle_password
--   and also execute the DML "alter USER XXXX identified by PASSNEW "
--   synchronizing the users-passwords for APPS, APPLSYS and APPL_NE
-- IN
--   p_old_password - new user password
--   p_new_password - new user password
-- OUT
--   p_msg_result   - Summary of the changes on FND_USER table
-- RETURNS
--   'Y' or 'N' for success or failure
--   On failure message is on message stack.
--
FUNCTION forms_chg_system_pwd(p_old_password IN VARCHAR2,
                              p_new_password IN VARCHAR2,
                              p_msg_result  OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

END FND_USER_PKG_WRP;

/
