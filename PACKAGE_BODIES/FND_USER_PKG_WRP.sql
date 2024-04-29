--------------------------------------------------------
--  DDL for Package Body FND_USER_PKG_WRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_USER_PKG_WRP" as
/* $Header: AFSCUSWB.pls 120.3.12010000.2 2015/03/13 15:48:52 emiranda ship $ */

  Dplsql_pwd_ora VARCHAR2(1500) :=
     'BEGIN '
||     ':r := fnd_web_sec.int_cpass_ora( :a , :b ); '
||     ':m := fnd_message.get; '
||   'exception '
||    'when others then '
||     ':r := ''N''; '
||     ':m := fnd_message.get; '
||   'end; ';

  Dplsql_pwd_sys VARCHAR2(1500) :=
     'BEGIN '
||     ':r := fnd_web_sec.int_cpass_sys( :a , :b ); '
||     ':m := fnd_message.get; '
||   'exception '
||    'when others then '
||     ':r := ''N''; '
||     ':m := fnd_message.get; '
||   'end; ';

--
-- user_synch
--   Wrapper for fnd_user_pkg.user_synch()
-- IN
--   p_user_name
--
procedure user_synch (p_user_name  in  varchar2)
is
begin
  fnd_user_pkg.user_synch(p_user_name);
end;

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
return number is
  ret number;
begin
  ret := fnd_user_pkg.derive_person_party_id(p_user_name, p_customer_id,
                                      p_employee_id, p_log_exception);
  return(ret);
end;

--
-- set_old_user_name
--   Wrapper for fnd_user_pkg.set_old_user_name()
-- IN
--   p_old_user_name
--
function set_old_user_name (p_old_user_name  in  varchar2) return number
is
  ret number;
begin
  ret := fnd_user_pkg.set_old_user_name(p_old_user_name);
  return(ret);
end;

--
-- validate_user_name
--   Wrapper for fnd_user_pkg.validate_user_name()
-- IN
--   p_user_name
--
procedure validate_user_name (p_user_name  in  varchar2)
is
begin
  fnd_user_pkg.validate_user_name(p_user_name);
end;

--
-- isPasswordChangable
--   Wrapper for fnd_user_pkg.isPasswordChangable()
-- IN
--   p_user_name
-- OUT
--   TRUE/FALSE
--
function isPasswordChangeable (p_user_name  in  varchar2) return boolean
is
  ret boolean;
begin
  ret := fnd_user_pkg.isPasswordChangeable(p_user_name);
  return (ret);
end;

--
-- ldap_wrapper_create_user
--   Wrapper for fnd_user_pkg.ldap_wrapper_create_user()
procedure ldap_wrapper_create_user (p_user_name  in  varchar2,
                                    p_unencrypted_password in varchar2,
                                    p_start_date in date,
                                    p_end_date in date,
                                    p_description in varchar2,
                                    p_email_address in varchar2,
                                    p_fax in varchar2) is
begin
  fnd_user_pkg.ldap_wrapper_create_user(p_user_name,p_unencrypted_password,
            p_start_date, p_end_date, p_description, p_email_address, p_fax, 1);
end;



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
                                    p_out_pwd in out nocopy varchar2)
is
begin
  fnd_user_pkg.form_ldap_wrapper_update_user(p_user_name,
            p_unencrypted_password, p_start_date, p_end_date,
            p_description, p_email_address, p_fax, p_out_pwd);
end;


--
-- ldap_wrapper_change_user_name
--   Wrapper for fnd_user_pkg.ldap_wrapper_change_user_name()
-- IN
--   p_old_user_name
--   p_new_user_name
--
procedure ldap_wrapper_change_user_name (p_old_user_name in varchar2,
                                         p_new_user_name in varchar2)
is
begin
  fnd_user_pkg.ldap_wrapper_change_user_name(p_old_user_name, p_new_user_name);
end;


--Bug 5892249
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
return VARCHAR2 is
begin
  return fnd_web_sec.validate_password(p_username,p_new_password);
end;


-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- forms_change_user_pwd
--   This function figures out what should be stored in the
--   fnd_user encrypted_user_password and encrypted_foundation_password
--   columns and passes this back to forms so forms can do the commit.
-- IN
--   p_username - user name
--   p_new_password - new user password
-- OUT
--   p_enc_user_pwd - encrypted user password/hash
--   p_enc_fnd_pwd - encrypted fnd password or password metadata
-- RETURNS
--   'Y' or 'N' for success or failure
--   On failure message is on message stack.
--
function forms_change_user_pwd(p_userid in NUMBER,
                               p_username in VARCHAR2,
                               p_new_password in VARCHAR2,
                               p_enc_user_pwd out nocopy VARCHAR2,
                               p_enc_fnd_pwd out nocopy VARCHAR2)
return VARCHAR2 is
begin
  if (fnd_user_pkg.userExists(p_username)) then
    if (fnd_web_sec.update_no_reuse_function(p_username,p_new_password)='N')then
       --  update_no_reuse_function will load message stack
       return 'N';
    end if;
  end if;

  if ( p_userid is not null ) then
    return fnd_web_sec.get_encrypted_passwords( p_username, p_userid,
                         p_new_password, p_enc_fnd_pwd, p_enc_user_pwd );
  else
    fnd_message.set_name( 'FND','SECURITY_APPL_USERID_INVALID' );
    return 'N';
  end if;

end;

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
--   On failure message is on message stack.
--
FUNCTION forms_oracleuser_pwd(p_username       IN VARCHAR2,
                              p_new_password   IN VARCHAR2,
                              p_enc_oracle_pwd OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 IS
  l_rtn VARCHAR2(10) := NULL;
  l_enc_ora fnd_oracle_userid.encrypted_oracle_password%type;
  l_msg_result varchar2(2000);
BEGIN
  l_enc_ora := null;
  IF (p_username IS NOT NULL) THEN
    --
    -- Eliminates hardcode dependencies with fnd_web_sec.int_cpass_ora
    -- by executiong a PLSQL dynamic code.
    l_rtn := fnd_dsql.Function_exec_4binds( Dplsql_pwd_ora,
                                            p_username,
                                            p_new_password,
                                            l_msg_result);
    IF l_rtn = 'Y' THEN
      BEGIN
        SELECT fo.encrypted_oracle_password
          INTO l_enc_ora
          FROM FND_ORACLE_USERID fo
         WHERE fo.oracle_username = upper(p_username);
      EXCEPTION
        WHEN OTHERS THEN
          -- If fails returns N and clean the record
          l_rtn     := 'N';
      END;
    END IF;
    p_enc_oracle_pwd := l_enc_ora;
    RETURN l_rtn;
  ELSE
    fnd_message.set_name('FND', 'SECURITY_APPL_USERID_INVALID');
    p_enc_oracle_pwd := l_enc_ora;
    RETURN 'N';
  END IF;

END forms_oracleuser_pwd;


-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
-- forms_chg_system_pwd
--   This function is created as a WRAPPER for a FORMS call
--   of the function FND_WEB_SEC.int_cpass_sys that will update
--   the table fnd_oracle_userid encrypted_oracle_password
--   and also execute the DML "alter USER XXXX identified by PASSNEW "
--   synchronizing the users-passwords for APPS, APPLSYS and APPL_NE
-- IN
--   p_old_password - old Apps password
--   p_new_password - new Apps password
-- OUT
--   p_msg_result   - Summary of the changes on FND_USER table
-- RETURNS
--   'Y' or 'N' for success or failure
--   On failure message is on message stack.
--
FUNCTION forms_chg_system_pwd(p_old_password IN VARCHAR2,
                              p_new_password IN VARCHAR2,
                              p_msg_result  OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 IS
  l_rtn VARCHAR2(10) := NULL;

BEGIN
  IF ( (p_old_password IS NOT NULL) and
       (p_new_password IS NOT NULL) )
    THEN
    --
    -- Eliminates hardcode dependencies with fnd_web_sec.int_cpass_sys
    -- by executiong a PLSQL dynamic code.
    l_rtn := fnd_dsql.Function_exec_4binds( Dplsql_pwd_sys,
                                            p_old_password,
                                            p_new_password,
                                            p_msg_result);
    RETURN l_rtn;
  ELSE
    RETURN 'N';
  END IF;

END forms_chg_system_pwd;

end FND_USER_PKG_WRP;

/
