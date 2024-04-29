--------------------------------------------------------
--  DDL for Package FND_WEB_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WEB_SEC" AUTHID CURRENT_USER AS
/* $Header: AFSCJAVS.pls 120.11.12010000.15 2017/01/17 21:49:18 emiranda ship $ */
/*#
* Security Related Function and APIs.
* @rep:scope public
* @rep:product FND
* @rep:displayname User
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_USER
* @rep:ihelp FND/@o_funcsec#o_funcsec See the related online help
*/

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
-- Please call the fnd_user_pkg.validatelogin wrapper to protect
-- against undocumented underlying FND changes.
/*
 * Validate_login
 *   Test a username and password without updating audit tables.
 *   Only use this api to authenticate a user password when you do not
 *   expect that user to login or create a session.
 *
 *   NOTE: This api only works for LOCAL users (i.e., for users who are
 *   not SSO enabled.)
 * IN
 *   p_user - username
 *   p_password - password
 * RETURNS
 *   'Y' if user/password is valid, 'N' if not
 * RAISES
 *   Never raises exceptions, returns 'N' with a message on the
 *   message stack if an error is encountered.
 */

   C_MG_CURSESSION  CONSTANT NUMBER := 1;
   C_MG_BCKSESSION  CONSTANT NUMBER := 2;

   C_MG_SHA256    CONSTANT NUMBER := 1;
   C_MG_SHA384    CONSTANT NUMBER := 2;
   C_MG_SHA512    CONSTANT NUMBER := 3;

/*#
 * This API tests a username and password without updating audit tables.
 * @param p_user in varchar2 username
 * @param p_pwd in varchar2 password
 * @return 'Y' if the username/password is valid, 'N' if not
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Login
 * @rep:compatibility S
 */
FUNCTION validate_login(p_user IN VARCHAR2,
                        p_pwd  IN VARCHAR2)
    return VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
/*
 * Validate_login
 *   Validate a username and password, and update audit tables with
 *   results. Use this api if the user is expected to login.
 *
 *   NOTE: This api only works for LOCAL users (i.e., for users who are
 *   not SSO enabled.)
 * IN
 *   p_user - username
 *   p_password - password
 *   p_loginfrom - flag indicating a login UI was used for access
 * OUT
 *   p_loginID - Login ID of audit record (if successful)
 *   p_expired - Expiration flag to check whether user's password has expired.
 * RETURNS
 *   'Y' if user/password is valid, 'N' if not
 * RAISES
 *   Never raises exceptions, returns 'N' with a message on the
 *   message stack if an error is encountered.
 */
FUNCTION validate_login(p_user       IN VARCHAR2,
                        p_pwd        IN VARCHAR2,
                        p_loginID   OUT nocopy NUMBER,
                        p_expired   OUT nocopy VARCHAR2,
                        p_loginfrom  IN VARCHAR2 default null)
    return VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
PROCEDURE unsuccessful_login(userID IN NUMBER);

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
FUNCTION create_user(p_user IN VARCHAR2,
                     p_pwd IN VARCHAR2,
                     p_user_id OUT nocopy NUMBER)
  RETURN VARCHAR2;


-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
-- Please call the fnd_user_pkg.changepassword wrapper to protect
-- against undocumented underlying FND changes.
--
-- Changes the password of an applications user after verifying
-- the existing pasword.  Returns 'Y' on success and 'N' on failure.

-- Fix bug 5087728. Added fifth argument to specify whether autonomous
-- transaction is needed during set_password. Default is TRUE to maintain
-- backward compatibility
FUNCTION change_password(p_user IN VARCHAR2,
                         p_old_pwd IN VARCHAR2,
                         p_new_pwd1 IN VARCHAR2,
                         p_new_pwd2 IN VARCHAR2,
                         p_autonomous IN BOOLEAN DEFAULT TRUE)
  RETURN VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
-- Please call the fnd_user_pkg.changepassword wrapper to protect
-- against undocumented underlying FND changes.
--
-- Changes the password of an applications user without verifying
-- the existing pasword.  Returns 'Y' on success and 'N' on failure.
--
-- Bug 4625235: Added the third parameter p_autonomous with default = TRUE
-- So that any existing code calling change_password without the
-- third argument, it will function as before.
FUNCTION change_password(p_user IN VARCHAR2,
                         p_new_pwd IN VARCHAR2,
                         p_autonomous IN BOOLEAN DEFAULT TRUE)

  RETURN VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
FUNCTION upgrade_web_password(p_user IN VARCHAR2,
                              p_enc_web_pwd IN VARCHAR2,
                              p_new_pwd IN VARCHAR2)
  RETURN VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function validate_password(username in varchar2, password in varchar2)
  return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
procedure update_no_reuse(username in varchar2, password in varchar2);

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
-- Please call the fnd_user_pkg.getreencryptedpassword wrapper to protect
-- against undocumented underlying FND changes.
function get_reencrypted_password(username in varchar2,
                                  new_key  in varchar2,
                                  p_mode   in varchar2 default null)
  return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
-- Bug 16448842: This should only be called from fnd_user_pkg.change_user_name and LOADER
function set_reencrypted_password(username in varchar2, reencpwd varchar2,
                                  new_key in varchar2)
  return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function get_op_value(username in varchar2, applsyspwd in varchar2)
  return varchar2;


-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
FUNCTION create_oracle_user(p_user IN VARCHAR2,
                     p_pwd IN VARCHAR2,
                     p_newkey IN VARCHAR2,
                     p_user_id OUT nocopy NUMBER)
  RETURN VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function get_reencrypted_oracle_pwd(username in varchar2,
                                    new_key in varchar2)
  return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function cvt_reencrypted_oracle_pwd(pwd in varchar2, cur_key in varchar2)
  return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function encrypt(key in varchar2, value in varchar2,
                 userid in number default null)
  return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function URLEncrypt(key in varchar2, value in varchar2)
  return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
FUNCTION change_guest_password(p_new_pwd IN VARCHAR2, p_key IN VARCHAR2 default NULL)
  RETURN VARCHAR2;

-- bug 4047740 used by loader when creating a new user
INVALID_PWD   CONSTANT VARCHAR2(25) := '**FND_INVALID_PASSWORD**';

--bug 4148165 used when creating an SSO User
EXTERNAL_PWD  CONSTANT VARCHAR2(25) := '**FND_EXTERNAL_PASSWORD**';

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function encrypt(key in varchar2, value in varchar2,
profilePasswordCaseOption in varchar2)
  return varchar2;

--  Bug 5892249 fskinner begin
SHA_MODE CONSTANT VARCHAR2(4) := 'SHA';
MD4_MODE CONSTANT VARCHAR2(4) := 'MD4';
MD5_MODE CONSTANT VARCHAR2(4) := 'MD5';

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function update_no_reuse_function(username in varchar2, password in varchar2)
return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function get_encrypted_passwords(p_user in varchar2, userID in number, p_pwd in varchar2,
  p_enc_fnd_pwd out nocopy varchar2, p_enc_user_pwd out nocopy varchar2)
return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
FUNCTION get_efp_loader(p_user  IN VARCHAR2)  RETURN VARCHAR2;


-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function get_pwd_enc_mode
return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function start_user_migrate
return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function finish_user_migrate
return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function user_pwd_hash(pwd in varchar2)
  return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function encrypt_user_hash( pwdHash in varchar2, userID in number, CaseOpt in varchar2 )
  return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function decrypt_user_hash( encUserPwd in varchar2, userID in number, fnd_schema_pwd in varchar2 )
        return varchar2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
procedure put_apps_schema_pwd(oldpwd in varchar2, newpwd in varchar2);

/*
 * get_guest_username_pwd
 * RETURNS
 *   GUEST user's credentials in username/pwd format
 *   If GUEST credentials are defined in VAULT then it fetches from VAULT.
 *   Else, IF the release is less than 12.1, then reads from Profile
 *         ELSE return NULL(in 12.1 and above, profile option value is
 *              desupported)
 */
function get_guest_username_pwd return varchar2;

/*
 * verify_guest_user_pwd
 * RETURNS
 *   TRUE or FALSE
 *   If the GUEST credentials in profile/vault are matching with credentials in
 *   FND_USER, then return TRUE
 *   Else, return FALSE
 */
function verify_guest_user_pwd return boolean;


--  Bug 5892249 fskinner end

-- bug 6767084
/*
 * This function calls the dbms_utility package to retrieve the value
 * of the sec_case_sensitive_logon parameter from the init.ora.
 * sec_case_sensitive_logon was introduced in 11g to enable database password
 * case sensitivity.  This api returns 'Y' if case sensitive database passwords
 * are enabled and 'N' if not, or 'U' if undefined.
 * We check for this parameter in order to know how to handle the
 * case of the database password during comparison and encryption.
 */
-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
function db_case_sensitive return varchar2;


-- This routine is for ATG INTERNAL USE ONLY !!!!!!!
-- created for use by RI-team prod_id 166
FUNCTION int_cpass_ora( p_user VARCHAR2,
                        p_new_pwd VARCHAR2) RETURN VARCHAR2;

-- This routine is for ATG INTERNAL USE ONLY !!!!!!!
-- created for use by RI-team prod_id 166
FUNCTION int_cpass_sys( p_apps_pwd VARCHAR2,
                        p_new_pwd  VARCHAR2) RETURN varchar2;

-- This routine is for ATG INTERNAL USE ONLY !!!!!!!
FUNCTION chk_advhash_on RETURN VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
/*
 * CheckHash
 *   Validate a username and password, and update audit tables with
 *   results. Use this api if the user is expected to login.
 *   This function only applies to advanced encryption modes.
 *
 *   NOTE: This api only works for LOCAL users (i.e., for users who are
 *   not SSO enabled.)
 * IN
 *   p_username - Username
 *   p_pwd_hash - Input hashed password with SHA1 value
 * RETURNS
 *   'Y' if user/password is valid and advanced encryption mode is active
 *   'N' if not
 * RAISES
 *   Never raises exceptions, returns 'N' with a message on the
 *   message stack if an error is encountered.
 */
  FUNCTION CheckHash(p_username VARCHAR2, p_pwd_hash VARCHAR2)
    RETURN VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--  create for FNDLOAD and afscursp.lct file
-- FUNCTION get_efp_loader(p_user  IN VARCHAR2) RETURN VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
-- Final signature for Cpmgr_hash_advance
-- Concurrent-program definition for migration option in BACKGROUND
PROCEDURE cpmgr_advhash(errbuf       OUT NOCOPY VARCHAR2,
                        retcode      OUT NOCOPY VARCHAR2,
                        pv_sha_mode  IN VARCHAR2,
                        pv_sec_sleep IN VARCHAR2,
                        pv_count_int IN VARCHAR2);

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
-- Final signature for activate_mgr_adhash
FUNCTION mgr_advhash(p_hashmode VARCHAR2, p_typemgr VARCHAR2)
    RETURN VARCHAR2;

 -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
 PROCEDURE mgr_run_jobs( p_session      VARCHAR2,
                         p_partition_id NUMBER,
                         p_hashmode     VARCHAR2
                        );

  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
  FUNCTION SecER1226(p_mode NUMBER DEFAULT fnd_web_sec.C_MG_SHA512)
    RETURN VARCHAR2 ;

  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
  FUNCTION Complete_PartMigration( p_mode number default fnd_web_sec.C_MG_CURSESSION )
    RETURN VARCHAR2;

END FND_WEB_SEC;

/

  GRANT EXECUTE ON "APPS"."FND_WEB_SEC" TO "EM_OAM_MONITOR_ROLE";
