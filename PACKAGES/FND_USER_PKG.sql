--------------------------------------------------------
--  DDL for Package FND_USER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_USER_PKG" AUTHID CURRENT_USER as
/* $Header: AFSCUSRS.pls 120.16.12010000.13 2016/10/24 10:02:52 absandhw ship $ */
/*#
* Table Handler to insert or update data in FND_USER table.
* @rep:scope public
* @rep:product FND
* @rep:displayname User
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_USER
* @rep:ihelp FND/@o_funcsec#o_funcsec See the related online help
*/

null_char varchar2(8) := '*NULL*';
null_date date := to_date('2', 'J');
null_number number := -999;
null_raw raw(16) := '9999999999999999';

/* bug 4318754, 4352995 SSO related changes */
USER_OK_CREATE                 constant pls_integer := 0;
USER_INVALID_NAME              constant pls_integer := 1;
USER_EXISTS_IN_FND             constant pls_integer := 2;
USER_SYNCHED                   constant pls_integer := 3;
USER_EXISTS_NO_LINK_ALLOWED    constant pls_integer := 4;

/* bug 5027812 */
CHANGE_SOURCE_OID              constant pls_integer := 1;

/* bug 19357286 API TO VALIDATE EBS USERS WITHOUT KNOWING THEIR PASSWORDS */
ACT_SSO_EXIST	 constant number :=  0; /* Active EBS user exists in SSO */
ACT_LOC_VALID	 constant number :=  1; /* Active local EBS user, with usuable password */

INV_NON_USER	 constant number := 10; /* Non-Active EBS user, user id does not exist */
INV_PEND_USER	 constant number := 11; /* Non-Active EBS user, user status is pending */
INV_LOCK_USER	 constant number := 12; /* Non-Active EBS user, user status is locked */
INV_ENDD_USER	 constant number := 13; /* Non-Active EBS user, user status is end-dated */

INV_EXPIRE_PW	 constant number := 20; /* Active EBS user, expired password */
INV_CHANGE_PW	 constant number := 21; /* Active EBS user, must change password on next login */

INV_SSO_FAIL	 constant number := 30; /* Active EBS user, Not existing in SSO */
INV_EXT_FAIL     constant number := 31; /* Active EBS user, cannot login with NULL guid and EXTERNAL pwd */

--
-- LOAD_ROW (PRIVATE)
-- Overloaded version for backward compatibility only.
-- Use version below.
--
procedure LOAD_ROW (
  X_USER_NAME        in  VARCHAR2,
  X_OWNER                             in  VARCHAR2,
  X_ENCRYPTED_USER_PASSWORD     in  VARCHAR2,
  X_SESSION_NUMBER        in  VARCHAR2,
  X_START_DATE        in  VARCHAR2,
  X_END_DATE        in  VARCHAR2,
  X_LAST_LOGON_DATE      in  VARCHAR2,
  X_DESCRIPTION              in  VARCHAR2,
  X_PASSWORD_DATE      in  VARCHAR2,
  X_PASSWORD_ACCESSES_LEFT     in  VARCHAR2,
  X_PASSWORD_LIFESPAN_ACCESSES    in  VARCHAR2,
  X_PASSWORD_LIFESPAN_DAYS     in  VARCHAR2,
  X_EMAIL_ADDRESS      in  VARCHAR2,
  X_FAX                 in  VARCHAR2 );

----------------------------------------------------------------------
--
-- LOAD_ROW (PRIVATE)
--   Insert/update a new row of data.
--   Only for use by FNDLOAD, other apis should use LoadUser below.
--
    /*#
     * Creates or updates Application's User data as appropriate.
     * @param x_user_name User Name
     * @param x_owner Owner Name
     * @param x_encrypted_user_password Encrypted Password for Authentication
     * @param x_session_number Session ID
     * @param x_start_date User Effective Start Date
     * @param x_end_date User Effective End Date
     * @param x_last_logon_date User Last Login Date
     * @param x_description User Description
     * @param x_password_date Password Creation Date
     * @param x_password_accesses_left Number of Login Accesses left (From Current Day) for Password Expiry
     * @param x_password_lifespan_accesses Number of Login Accesses (From Password Creation Day) after which Password Expires
     * @param x_password_lifespan_days Number of days after which Password Expires
     * @param x_email_address User Email Address
     * @param x_fax Fax Number
     * @param x_custom_mode Custom Mode
     * @param x_last_update_date Insert/Update Date
     * @param x_person_party_name Person Party Name
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update User
     * @rep:compatibility S
     * @rep:ihelp FND/@dev_p_funcworks#dev_p_funcworks See the related online help
     */
procedure LOAD_ROW (
  X_USER_NAME        in  VARCHAR2,
  X_OWNER                             in  VARCHAR2,
  X_ENCRYPTED_USER_PASSWORD     in  VARCHAR2,
  X_SESSION_NUMBER        in  VARCHAR2,
  X_START_DATE        in  VARCHAR2,
  X_END_DATE        in  VARCHAR2,
  X_LAST_LOGON_DATE      in  VARCHAR2,
  X_DESCRIPTION              in  VARCHAR2,
  X_PASSWORD_DATE      in  VARCHAR2,
  X_PASSWORD_ACCESSES_LEFT     in  VARCHAR2,
  X_PASSWORD_LIFESPAN_ACCESSES    in  VARCHAR2,
  X_PASSWORD_LIFESPAN_DAYS     in  VARCHAR2,
  X_EMAIL_ADDRESS      in  VARCHAR2,
  X_FAX                 in  VARCHAR2,
  X_CUSTOM_MODE        in  VARCHAR2,
  X_LAST_UPDATE_DATE      in  VARCHAR2,
  X_PERSON_PARTY_NAME                   in      VARCHAR2 default NULL,
  X_ENCRYPTED_FOUNDATION_PWD            in      VARCHAR2 default NULL
  );

----------------------------------------------------------------------
--
-- CreateUserId (PUBLIC)
--   Insert new user record into FND_USER table.
--   If that user exists already, exception raised with the error message.
--   There are three input arguments must be provided. All the other columns
--   in FND_USER table can take the default value.
--
--   *** NOTE: This version accepts the old customer_id/employee_id
--   keys foreign keys to the "person".  Use CreateUserIdParty to create
--   a user with the new person_party_id key.
--
-- Input (Mandatory)
--  x_user_name:            The name of the new user
--  x_owner:                'SEED' or 'CUST'(customer)
--  x_unencrypted_password: The password for this new user
-- Returns
--   User_id of created user
--
function CreateUserId (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default 0,
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_employee_id                 in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_customer_id                 in number default null,
  x_supplier_id                 in number default null)
return number;

----------------------------------------------------------------------
--
-- CreateUserIdParty (PUBLIC)
--   Insert new user record into FND_USER table.
--   If that user exists already, exception raised with the error message.
--   There are three input arguments must be provided. All the other columns
--   in FND_USER table can take the default value.
--
--   *** NOTE: This version accepts the new person_party_id foreign key
--   to the "person".  Use CreateUserId to create a user with the old
--   customer_id/employee_id keys.
--
-- Input (Mandatory)
--  x_user_name:            The name of the new user
--  x_owner:                'SEED' or 'CUST'(customer)
--  x_unencrypted_password: The password for this new user
-- Returns
--   User_id of created user
--
function CreateUserIdParty (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default 0,
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_person_party_id            in number default null)
return number;

----------------------------------------------------------------------
--
-- CreateUser (PUBLIC)
--   Insert new user record into FND_USER table.
--   If that user exists already, exception raised with the error message.
--   There are three input arguments must be provided. All the other columns
--   in FND_USER table can take the default value.
--
--   *** NOTE: This version accepts the old customer_id/employee_id
--   keys foreign keys to the "person".  Use CreateUserParty to create
--   a user with the new person_party_id key.
--
-- Input (Mandatory)
--  x_user_name:            The name of the new user
--  x_owner:                'SEED' or 'CUST'(customer)
--  x_unencrypted_password: The password for this new user
--
procedure CreateUser (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default 0,
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_employee_id                 in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_customer_id                 in number default null,
  x_supplier_id                 in number default null);

----------------------------------------------------------------------
--
-- CreateUserParty (PUBLIC)
--   Insert new user record into FND_USER table.
--   If that user exists already, exception raised with the error message.
--   There are three input arguments must be provided. All the other columns
--   in FND_USER table can take the default value.
--
--   *** NOTE: This version accepts the new person_party_id foreign key
--   to the "person".  Use CreateUser to create a user with the old
--   customer_id/employee_id keys.
--
-- Input (Mandatory)
--  x_user_name:            The name of the new user
--  x_owner:                'SEED' or 'CUST'(customer)
--  x_unencrypted_password: The password for this new user
--
procedure CreateUserParty (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default 0,
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_person_party_id            in number default null);

----------------------------------------------------------------------
--
-- UpdateUser (Public)
--   Update any column for a particular user record. If that user does
--   not exist, exception raised with error message.
--   You can use this procedure to update a user's password for example.
--
--   *** NOTE: This version accepts the old customer_id/employee_id
--   keys foreign keys to the "person".  Use UpdateUserParty to update
--   a user with the new person_party_id key.
--
-- Usage Example in pl/sql
--   begin fnd_user_pkg.updateuser('SCOTT', 'SEED', 'DRAGON'); end;
--
-- Mandatory Input Arguments
--   x_user_name: An existing user name
--   x_owner:     'SEED' or 'CUST'(customer)
--
procedure UpdateUser (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default null,
  x_start_date                 in date default null,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_employee_id                 in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_customer_id                 in number default null,
  x_supplier_id                 in number default null,
  x_old_password               in varchar2 default null);

----------------------------------------------------------------------
--
-- UpdateUserParty (Public)
--   Update any column for a particular user record. If that user does
--   not exist, exception raised with error message.
--   You can use this procedure to update a user's password for example.
--
--   *** NOTE: This version accepts the new person_party_id foreign key
--   to the "person".  Use UpdateUser to update a user with the old
--   customer_id/employee_id keys.
--
-- Usage Example in pl/sql
--   begin fnd_user_pkg.updateuser('SCOTT', 'SEED', 'DRAGON'); end;
--
-- Mandatory Input Arguments
--   x_user_name: An existing user name
--   x_owner:     'SEED' or 'CUST'(customer)
--
procedure UpdateUserParty (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default null,
  x_start_date                 in date default null,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_person_party_id            in number default null,
  x_old_password               in varchar2 default null);

----------------------------------------------------------------------------
--
-- LoadUser (Public)
--   Create or Update user, as appropriate.
--
--   *** NOTE: This version accepts the old customer_id/employee_id
--   keys foreign keys to the "person".  Use LoadUserParty to load
--   a user with the new person_party_id key.
--
procedure LoadUser(
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default null,
  x_start_date                 in date default null,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_employee_id                 in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_customer_id                 in number default null,
  x_supplier_id                 in number default null);

----------------------------------------------------------------------------
--
-- LoadUserParty (Public)
--   Create or Update user, as appropriate.
--
--   *** NOTE: This version accepts the new person_party_id foreign key
--   to the "person".  Use LoadUser to load a user with the old
--   customer_id/employee_id keys.
--
procedure LoadUserParty(
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default null,
  x_start_date                 in date default null,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_person_party_id            in number default null);

----------------------------------------------------------------------------
--
-- DisableUser (PUBLIC)
--   Sets end_date to sysdate for a given user. This is to terminate that user.
--   You longer can log in as this user anymore. If username is not valid,
--   exception raised with error message.
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.disableuser('SCOTT'); end;
--
-- Input (Mandatory)
--  username:       User Name
--
procedure DisableUser(username varchar2,
		      x_owner in varchar2 default null);
----------------------------------------------------------------------------
--
-- ValidateLogin (PUBLIC)
--   Test if password is good for this given user.
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.validatelogin('SCOTT', 'TIGER'); end;
--
-- Input (Mandatory)
--  username:       User Name
--  password:       User Password
--
function ValidateLogin(username   varchar2,
                       password   varchar2) return boolean;
----------------------------------------------------------------------------
--
-- ValidateSSOLogin (RESTRICTED)
-- Validates the given username/password against SSO
-- This routine is restricted and can ONLY be used with the explicit permission
-- from ATG/AOL management.
-- Any other use will NOT be supported by AOLJ/SSO development team!!!!!!!
--
-- This api is introduced to enable the clients which can NOT perform HTTP
-- authentication against SSO (NON-UI business logic).

-- Use the api for SSO user authentication.   It is assumed that EBS is already
-- configured with SSO.
-- In all other cases use FND_USER_PKG.ValidateLogin.
-- Product teams who are currently using this api:
-- Oracle Mobile Field Service  (FND_APPLICATION.APPLICATION_SHORT_NAME=CSM)
-- (bug#14057306)
function ValidateSSOLogin(username   varchar2,
                       password   varchar2) return boolean;
----------------------------------------------------------------------------
--
-- ChangePassword (PUBLIC)
--   Set new password for a given user without having to provide
--   the old password.
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.changepassword('SCOTT', 'WELCOME'); end;
--
-- Input (Mandatory)
--  username:       User Name
--  newpassword     New Password
--
function ChangePassword(username      varchar2,
                        newpassword   varchar2) return boolean;
----------------------------------------------------------------------------
--
-- ChangePassword (PUBLIC)
--   Set new password for a given user if the existing password needed to be
--   validated before changing to the new password.
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.changepassword('SCOTT', 'TIGER', 'WELCOME'); end;
--
-- Input (Mandatory)
--  username:       User Name
--  oldpassword     Old Password
--  newpassword     New Password
--
function ChangePassword(username      varchar2,
                        oldpassword   varchar2,
                        newpassword   varchar2) return boolean;
----------------------------------------------------------------------------
--
-- GetReEncryptedPassword (PUBLIC)
--   Return user password encrypted with new key. This just returns the
--   newly encrypted password. It does not set the password in FND_USER table.
--
-- Usage example in pl/sql
--   declare
--     newpass varchar2(100);
--   begin
--     newpass := fnd_user_pkg.getreencryptedpassword('SCOTT', 'NEWKEY'); end;
--   end;
--
-- Input (Mandatory)
--   username:  User Name
--   newkey     New Key
--
function GetReEncryptedPassword(username varchar2,
                                newkey   varchar2) return varchar2;

----------------------------------------------------------------------------
-- SetReEncryptedPassword (PUBLIC)
--   Set user password from value returned from GetReEncryptedPassword.
--   This is to update column ENCRYPTED_USER_PASSWORD in table FND_USER
--
-- Usage example in pl/sql
--   declare
--     newpass varchar2(100);
--   begin
--     newpass := fnd_user_pkg.getreencryptedpassword('SCOTT', 'NEWKEY'); end;
--     fnd_user_pkg.setreencryptedpassword('SCOTT', newpass, 'NEWKEY'); end;
--   end;
--
-- Input (Mandatory)
--  username:       User Name
--  reencpwd:       Reencrypted Password
--  newkey          New Key
--
function SetReEncryptedPassword(username varchar2,
                              reencpwd varchar2,
                              newkey   varchar2) return boolean;

------------------------------------------------------------------------
----
-- MergeCustomer (PUBLIC)
--   This is the procedure being called during the Party Merge.
--   FND_USER.MergeCustomer() has been registered in Party Merge Data Dict.
--   The input/output arguments format matches the document PartyMergeDD.doc.
--   The goal is to fix the customer id in fnd_user table to point to the
--   same party when two similar parties are begin merged.
--
-- Usage example in pl/sql
--   This procedure should only be called from the PartyMerge utility.
--
procedure MergeCustomer(p_entity_name in varchar2,
                        p_from_id in number,
                        p_to_id in out nocopy number,
                        p_from_fk_id in number,
                        p_to_fk_id in number,
                        p_parent_entity_name in varchar2,
                        p_batch_id in number,
                        p_batch_party_id in number,
                        p_return_status in out nocopy varchar2);
--------------------------------------------------------------------------
/*
** user_change - The rule function for FND's subscription on the
**               oracle.apps.wf.entmgr.user.change event.  This function
**               retrieves the user's information and updates the
**               corresponding fnd_user as needed, if the user exists.
*/
FUNCTION user_change(p_subscription_guid in            raw,
                     p_event             in out nocopy wf_event_t)
return varchar2;
--------------------------------------------------------------------------
/*
** user_create_rf - The rule function for FND's 2nd subscription on the
**               oracle.apps.wf.entmgr.user.change event.  This function
**               retrieves the user's information and creates the
**               corresponding fnd_user if the user does not already exist.
*/
FUNCTION user_create_rf(p_subscription_guid in            raw,
                        p_event             in out nocopy wf_event_t)
         return varchar2;
--------------------------------------------------------------------------
/*
** user_synch - The centralized routine for communicating user changes
**             with wf and entity mgr.
*/
PROCEDURE user_synch(p_user_name in varchar2);

--------------------------------------------------------------------------
--
-- DelResp (PUBLIC)
--   Detach a responsibility which is currently attached to this given user.
--   If any of the username or application short name or responsibility key or
--   security group is not valid, exception raised with error message.
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.delresp('SCOTT', 'FND', 'APPLICATION_DEVELOPER',
--                              'STANDARD'); end;
-- Input (Mandatory)
--  username:       User Name
--  resp_app:       Application Short Name
--  resp_key:       Responsibility Key
--  security_group: Security Group Key
--
procedure DelResp(username       varchar2,
                  resp_app       varchar2,
                  resp_key       varchar2,
                  security_group varchar2);
--------------------------------------------------------------------------
--
-- AddResp (PUBLIC)
--   For a given user, attach a valid responsibility.
--   If user name or application short name or responsbility key name
--   or security group key is not valid, exception raised with error message.
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.addresp('SCOTT', 'FND', 'APPLICATION_DEVELOPER',
--                              'STANDARD', 'DESCRIPTION', sysdate, null); end;
-- Input (Mandatory)
--  username:       User Name
--  resp_app:       Application Short Name
--  resp_key:       Responsibility Key
--  security_group: Security Group Key
--  description:    Description
--  start_date:     Start Date
--  end_date:       End Date
--
procedure AddResp(username       varchar2,
                  resp_app       varchar2,
                  resp_key       varchar2,
                  security_group varchar2,
                  description    varchar2,
                  start_date     date,
                  end_date       date);

-------------------------------------------------------------------
-- Name:        isPasswordChangeable
-- Description: Checks if user us externally authenticatied
----------------------------------------------------------------------
 Function isPasswordChangeable (p_user_name in varchar2)
                                return boolean;

-------------------------------------------------------------------
-- Name:        UpdatePassword_WF
-- Description: Calls FND_USER_PKG.UpdateUser
-------------------------------------------------------------------
 Procedure UpdatePassword_WF(itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout in out nocopy varchar2);
----------------------------------------------------------------------------

--
-- DERIVE_PERSON_PARTY_ID
--   Derive the person_party_id, given a customer_id and employee_id
-- IN
--   customer_id
--   employee_id
-- RETURNS
--   person_party_id
--
/*#
 * This is called by user form and other packages. This function
 * validates the person party and returns the person party id
 * attached to the user.
 * @param user_name in varchar2 Username
 * @param customer_id in number Customer Id
 * @param employee_id in number Employee Id
 * @param log_exception in varchar2 Parameter which controls whether exception needs to be raised or not. When passed 'Y', the function exits by raising an exception. When passed 'N', the function exits quitely returning null.
 * @return person party id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Derive Person Party Id
 * @rep:compatibility S
 */
Function DERIVE_PERSON_PARTY_ID(
  user_name in varchar2,
  customer_id in number,
  employee_id in number,
  log_exception in varchar2 default 'Y')
return number;

--
-- DERIVE_CUSTOMER_EMPLOYEE_ID
--   Update customer and employee ids if person_party_id is changed
-- IN
--   person_party_id
-- OUT
--   customer_id
--   employee_id
--
Procedure DERIVE_CUSTOMER_EMPLOYEE_ID(
  user_name in varchar2,
  person_party_id in number,
  customer_id out nocopy number,
  employee_id out nocopy number);

----------------------------------------------------------------------------
--
-- EnableUser (PUBLIC)
--   Sets the start_date and end_date as requested. By default, the
--   start_date will be set to sysdate and end_date to null.
--   This is to enable that user.
--   You can log in as this user from now.
--   If username is not valid, exception raised with error message.
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.enableuser('SCOTT'); end;
--   begin fnd_user_pkg.enableuser('SCOTT', sysdate+1, sysdate+30); end;
--
-- Input (Mandatory)
--  username:       User Name
-- Input (Non-Mandatory)
--  start_date:     Start Date
--  end_date:       End Date
--  x_owner:        Owner (Introduced per ER16794771)
--
procedure EnableUser(username varchar2,
                     start_date date default sysdate,
                     end_date date default fnd_user_pkg.null_date,
                     x_owner in varchar2 default null);

----------------------------------------------------------------------------
--
-- CreatePendingUser (PUBLIC)
--   Create a user whose start_date and end_date = FND_API.G_MISS_DATE as
--   a pending user.
--   Pending user is created when a user registers a user account through
--   UMX with an aproval process.
--   USER_ID is returned.
--
--
-- Usage example in pl/sql
--   begin uid := fnd_user_pkg.creatependinguser('SCOTT', 'SEED', 'welcome');
--   end;
--   begin uid := fnd_user_pkg.creatependinguser('SCOTT', 'SEED'); end;
--
-- Input (Mandatory)
--  x_user_name:             User Name
--  x_owner:                 'SEED' or 'CUST'(customer)
-- Output
--   user_id
--
function CreatePendingUser(
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default 0,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_email_address              in varchar2 default null,
  x_fax                        in varchar2 default null,
  x_person_party_id            in number default null) return number;

----------------------------------------------------------------------------
--
-- RemovePendingUser (PUBLIC)
--   Delete this user from fnd_user table only if this is a pending user.
--   If this is not a valid username or is not a pending user, raise error.
--   Pending user is created when a user registers a user account through
--   UMX with an aproval process.
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.removependinguser('SCOTT'); end;
--
-- Input (Mandatory)
--  username:       User Name
--
procedure RemovePendingUser(username varchar2);

----------------------------------------------------------------------------
--
-- AssignPartyToUser (PUBLIC)
--   Assign a TCA party to a given user
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.assignpartytouser('SCOTT', 1001); end;
--
-- Input (Mandatory)
--  x_user_name:       User Name
--  x_party_id:        Party Name Id
--
procedure AssignPartyToUser(
  x_user_name                  in varchar2,
  x_party_id                   in number);

-- begin bug 2504562

----------------------------------------------------------------------------
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.change_user_name('SOCTT', 'SCOTT'); end;
--
-- Input (Mandantory)
--   x_old_user_name:     Old User Name
--   x_new_user_name:     New User Name
--   x_change_source:     Change Source
--      null means we need to synch change to oid
--      CHANGE_SOURCE_OID means we don't need to synch back to oid anymore
--      X_CHANGE_SOURCE is private argument only used by ldap routine.
--
/*#
 *   This api changes username, deals with encryption changes and
 *   update foreign keysthat were using the old username.
 *   PLEASE NOTE THAT x_change_source IS PRIVATE ARGUMENT ONLY USED BY SSO!!!
 * @param x_old_user_name in varchar2 The Old user name
 * @param x_new_user_name in varchar2 The New user name
 * @param x_change_source in number (default null).
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Change User Name
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
procedure change_user_name(
  x_old_user_name            in varchar2,
  x_new_user_name            in varchar2,
  x_change_source            in number default null);


----------------------------------------------------------------------------
--
-- set_old_user_name (PUBLIC)
--   This function is called from Forms to set the global variable,
--   fnd_user_pkg/g_old_user_name since this cannot be set directly from Forms.
--   This function returns a number which can be used to check for success
--   from Forms.
--
-- Usage example in pl/sql
--   declare
--     retval number := null;
--   begin retval := fnd_user_pkg.set_old_user_name('SOCTT'); end;
--
-- Input (Mandantory)
--   x_old_user_name:     Old User Name
--
function set_old_user_name(x_old_user_name in varchar2) return number;

-- end bug 2504562

----------------------------------------------------------------------------
-- MergePartyId (PUBLIC)
--   This is the procedure being called during the Party Merge.
--   FND_USER.MergePartyId() has been registered in Party Merge Data Dict.
--   The input/output arguments format matches the document PartyMergeDD.doc.
--   The goal is to fix the party id in fnd_user table to point to the
--   same party when two similar parties are begin merged.
--
-- Usage example in pl/sql
--   This procedure should only be called from the PartyMerge utility.
--
procedure MergePartyId(p_entity_name in varchar2,
                       p_from_id in number,
                       p_to_id in out nocopy number,
                       p_from_fk_id in number,
                       p_to_fk_id in number,
                       p_parent_entity_name in varchar2,
                       p_batch_id in number,
                       p_batch_party_id in number,
                       p_return_status in out nocopy varchar2);

-- Validate_User_Name (PUBLIC)
-- Make sure that input argument x_user_name doesn't contain invalid character.
-- For now: We only care about '/' and ':' because they are known problem.
-- 01/19/05: we now have more invalid characters info from bug 4116239, so
--           I am adding more characters.
-- Rewrite later: checking for any non-printable character.
--                make sure multibyte character is ok.
/*#
 * This is called by user form and the fnd_user_pkg. In both places
 * we need to validate whether an username is in a valid format.
 * @param x_user_name in varchar2 Username
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate User Name
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
procedure validate_user_name(x_user_name in varchar2);

----------------------------------------------------------------------
--
-- CreateUser (PUBLIC)
--
--   Bug#3904339 - SSO: Add user_guid parameter in fnd_user_pkg apis
--   Overloaded procedure to create user
--   Accepts  User GUID as a parameter in addition to the other parameters
--
procedure CreateUser (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default 0,
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_employee_id                 in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_customer_id                 in number default null,
  x_supplier_id                 in number default null,
  x_user_guid                  in raw,
  x_change_source              in number default null);

----------------------------------------------------------------------
--
-- CreateUserId (PUBLIC)
--
--   Bug#3904339 - SSO: Add user_guid parameter in fnd_user_pkg apis
--   Overloaded function to create user
--   Accepts  User GUID as a parameter in addition to the other parameters
-- Returns
--   User_id of created user
--
function CreateUserId (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default 0,
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_employee_id                 in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_customer_id                 in number default null,
  x_supplier_id                 in number default null,
  x_user_guid                  in raw,
  x_change_source              in number default null)
return number;

----------------------------------------------------------------------
--
-- UpdateUser (Public)
--
--   Bug#3904339 - SSO: Add user_guid parameter in fnd_user_pkg apis
--   Overloaded procedure to update user
--   Accepts User GUID in addition to the other parameters
--

procedure UpdateUser (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2 default null,
  x_session_number             in number default null,
  x_start_date                 in date default null,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_employee_id                 in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_customer_id                 in number default null,
  x_supplier_id                 in number default null,
  x_old_password               in varchar2 default null,
  x_user_guid                  in raw,
  x_change_source              in number default null);

----------------------------------------------------------------------
-- userExists (Public)
--
-- This function checks if the user exists and returns 'True' or 'False'
-- Input (Mandatory)
--  username: User Name

function userExists (x_user_name in varchar2) return boolean;

----------------------------------------------------------------------------
--
-- TestUserName (PUBLIC)
--   This api test whether a username exists in FND and/or in OID.
--
-- Usage example in pl/sql
--   declare ret number;
--   begin ret := fnd_user_pkg.testusername('SOCTT'); end;
--
-- Input (Mandantory)
--   x_user_name:     User Name that you want to test
--
-- Output
--   USER_OK_CREATE : User does not exist in either FND or OID
--   USER_INVALID_NAME : User name is not valid
--   USER_EXISTS_IN_FND : User exists in FND
--   USER_SYNCHED : User exists in OID and next time when this user gets
--                  created in FND, the two will be synched together.
--   USER_EXISTS_NO_LINK_ALLOWED: User exists in OID and no synching allowed.
--
/*#
 * Check a user name exists in FND and (or) in OID.
 * @param x_user_name The username to be tested
 * @return The User Existence Status Code
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Test User Name
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
function TestUserName(x_user_name in varchar2) return pls_integer;

/* bug 19357286 API TO VALIDATE EBS USERS WITHOUT KNOWING THEIR PASSWORDS */
----------------------------------------------------------------------------
--
-- Overloaded procedure to IsUserActive
-- using single input parameter username
--
-- IsUserActive (PUBLIC)
--   Verify EBS users without having to provide their passwords:
--     User is active
--     User is not locked
--     User has a valid, non-expired password
--     User is not required to change password on login
--     User with external password is active in OID
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.IsUserActive('SCOTT'); end;
--
-- Input (Mandatory)
--  p_username:    User Name
--
-- Returns
--   True : User is active with usable password
--
--   False: User is not active or unusable password
--
/*#
 * Overloaded procedure to IsUserActive
 * using single input parameter username
 * PreValidate an EBS user without providing password
 *     User is active
 *     User is not locked
 *     User has a valid, non-expired password
 *     User is not required to change password on login
 *     User with external password is active in OID
 * @param p_username user name
 * @paraminfo {@rep:required}
 * @return TRUE if EBS User is active with usable password, Otherwise FALSE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Pre-validate EBS user
 */
function IsUserActive(p_username in varchar2) return boolean;

----------------------------------------------------------------------------
--
--
-- IsUserActive (PUBLIC)
--   Verify EBS users without having to provide their passwords:
--     User is active
--     User is not locked
--     User has a valid, non-expired password
--     User is not required to change password on login
--     User with external password is active in OID
--
--   Outputs status of pre validation
--
-- Usage example in pl/sql
--   declare
--     status number;
--   begin
--     fnd_user_pkg.IsUserActive('SCOTT', status);
--   end;
--
-- Input (Mandatory)
--  p_username:    User Name
--
-- Output
--  x_status:
--    ACT_SSO_EXIST - Active EBS user exists in SSO
--    ACT_LOC_VALID - Active local EBS user, with usuable password
--
--    INV_NON_USER  - Non-Active EBS user, user id does not exist
--    INV_PEND_USER - Non-Active EBS user, user status is pending
--    INV_LOCK_USER - Non-Active EBS user, user status is locked
--    INV_ENDD_USER - Non-Active EBS user, user status is end-dated
--
--    INV_EXPIRE_PW - Active EBS user, expired password
--    INV_CHANGE_PW - Active EBS user, must change password on next login
--
--    INV_SSO_FAIL  - Active EBS user, Not existing in SSO
--
-- Returns
--   True : User is active with usable password
--
--   False: User is not active or unusable password
/*#
 * PreValidate an EBS user without providing password
 *     User is active
 *     User is not locked
 *     User has a valid, non-expired password
 *     User is not required to change password on login
 *     User with external password is active in OID
 * @param p_username user name
 * @paraminfo {@rep:required}
 * @param x_status Return Status Codes
 * @return TRUE if EBS User is active with usable password, Otherwise FALSE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Pre-validate EBS user
 */
function IsUserActive(p_username in varchar2, x_status out nocopy number) return boolean;

----------------------------------------------------------------------------
--
-- set_old_person_party_id (PUBLIC)
--   This function is called from Forms to set the global variable,
--   g_old_person_party_id since this cannot be set directly from Forms.
--   This function returns a number which can be used to check for success
--   from Forms.
--
-- Usage example in pl/sql
--   declare
--     retval number := null;
--   begin retval := fnd_user_pkg.set_old_person_party_id(12345); end;
--
-- Input (Mandantory)
--   x_old_person_party_id:     Old Person Party Id
--
/*#
 * This function is called from Forms and other serverside code to set
 * the global variable g_old_person_party_id.
 * Even this is a public function but is for INTERNAL usage.
 * @param x_old_person_party_id The old person party id for a FND user
 * @return 1: Success or 0: Failure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Old Person Party Id
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
function set_old_person_party_id(x_old_person_party_id in varchar2)
return number;

----------------------------------------------------------------------------
--
-- set_old_user_guid (PUBLIC)
--   This function sets the global variable g_old_user_guid.
--   This function returns a number which can be used to check for success
--   from Forms.
--
-- Usage example in pl/sql
--   declare
--     retval number := null;
--     guid raw(16);
--   begin
--     guid := 'F9374D4B80AB1A86E034080020B2612C';
--     retval := fnd_user_pkg.set_old_user_guid(guid); end;
--
-- Input (Mandantory)
--   x_old_user_guid:     Old USER GUID
--
/*#
 * This function sets the global variable g_old_user_guid.
 * Even this is a public function but is for INTERNAL usage.
 * @param x_old_user_guid The old user guid for a FND user
 * @return 1: Success or 0: Failure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Old User GUID
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
function set_old_user_guid(x_old_user_guid in raw) return number;


----------------------------------------------------------------------------
--
-- ldap_wrapper_update_user (PUBLIC)
--   This is called by the fnd_user_pkg and fnd_web_sec.
--   It serves as a helper routine to call fnd_ldap_wrapper.update_user
--   when we need to synch the user update to OID.
-- Note
--   Please note that even this is public procedure, it does not mean for
--   other public usage. This is mainly created as a helper routine to
--   service the user form and the user package.
/*#
 * This is called by the fnd_user_pkg and fnd_web_sec.
 * It serves as a helper routine to call fnd_ldap_wrapper.update_user
 * when we need to synch the user update to OID.
 * Please note that even this is public procedure, it does not mean for
 * other public usage. This is mainly created as a helper routine to
 * service the user form and the user package.
 * @param x_user_name in varchar2 The user name
 * @param x_unencrypted_password in varchar2 The unencrypted user password
 * @param x_start_date in date Start date
 * @param x_end_date in date End date
 * @param x_description in varchar2 Description
 * @param x_email_address in varchar2 Email address
 * @param x_fax in varchar2 Fax
 * @param x_expire_pwd in boolean Inform LDAP/OID whether to expire the pwd
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname LDAP Wrapper Update User
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
procedure ldap_wrapper_update_user(x_user_name in varchar2,
                                   x_unencrypted_password in varchar2,
                                   x_start_date in date,
                                   x_end_date in date,
                                   x_description in varchar2,
                                   x_email_address in varchar2,
                                   x_fax in varchar2,
                                   x_expire_pwd in pls_integer default 0);

----------------------------------------------------------------------------
--
-- ldap_wrapper_create_user (PUBLIC)
--   This is called by user form and the fnd_user_pkg.
--   It serves as a helper routine to call fnd_ldap_wrapper.create_user
--   when we need to synch that new FND user to OID.
--   It also takes care of updating fnd_user with the user_guid and oid_pwd
--   coming back from ldap_wrapper layer.
-- Note
--   Please note that even this is public procedure, it does not mean for
--   other public usage. This is mainly created as a helper routine to
--   service the user form and the user package.
/*#
 * This is called by user form and the fnd_user_pkg. It serves as helper
 * routine to call fnd_ldap_wrapper.create_user when we need to synch that
 * new FND user to OID.
 * Please note that even this is public procedure, it does not mean for
 * other public usage. This is mainly created as a helper routine to
 * service the user form and the user package.
 * @param x_user_name in varchar2 The user name
 * @param x_unencrypted_password in varchar2 The unencrypted user password
 * @param x_start_date in date Start date
 * @param x_end_date in date End date
 * @param x_description in varchar2 Description
 * @param x_email_address in varchar2 Email address
 * @param x_fax in varchar2 Fax
 * @param x_expire_pwd in pls_integer Whether to expire user password
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname LDAP Wrapper Create User
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
-- ldap_wrapper_create_user
procedure ldap_wrapper_create_user(x_user_name in varchar2,
                                   x_unencrypted_password in varchar2,
                                   x_start_date in date,
                                   x_end_date in date,
                                   x_description in varchar2,
                                   x_email_address in varchar2,
                                   x_fax in varchar2,
                                   x_expire_pwd in pls_integer default 0);

-- end bug 4318754
----------------------------------------------------------------------------
--
-- ldap_wrapper_change_user_name (PUBLIC)
--   This is called by user form. When there is user name changed inside
--   User form, we need to synch with ldap.
--
-- Note
--   Please note that even this is public procedure, it does not mean for
--   other public usage. This is mainly created as a helper routine to
--   service the user form and the user package.
/*#
 * This is called by user form when a user name changed, we need to
 * synch up with ldap with the new name.
 * Please note that even this is public procedure, it does not mean for
 * other public usage. This is mainly created as a helper routine to
 * service the user form and the user package.
 * @param x_old_user_name  The Old User Name
 * @param x_new_user_name  The New User Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname LDAP Wrapper Change User Name
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
-- ldap_wrapper_create_user
procedure ldap_wrapper_change_user_name(x_old_user_name in varchar2,
                                        x_new_user_name in varchar2);

----------------------------------------------------------------------------
--
-- form_ldap_wrapper_update_user (PUBLIC)
--   This is called by user form.
--   It serves as a helper routine to call fnd_ldap_wrapper.update_user
--   when we need to synch the user update to OID.
-- Note
--   Please note that even this is public procedure, it does not mean for
--   other public usage. This is mainly created as a helper routine to
--   service the user form and the user package.
/*#
 * This is called by user form.
 * It serves as a helper routine to call fnd_ldap_wrapper.update_user
 * when we need to synch the user update to OID.
 * Please note that even this is public procedure, it does not mean for
 * other public usage. This is mainly created as a helper routine to
 * service the user form and the user package.
 * @param x_user_name in varchar2 The user name
 * @param x_unencrypted_password in varchar2 The unencrypted user password
 * @param x_start_date in date Start date
 * @param x_end_date in date End date
 * @param x_description in varchar2 Description
 * @param x_email_address in varchar2 Email address
 * @param x_fax in varchar2 Fax
 * @param x_out_pwd in out varchar2 output password from ldap/oid
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname User Form LDAP Wrapper Update User
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
procedure form_ldap_wrapper_update_user(x_user_name in varchar2,
                                        x_unencrypted_password in varchar2,
                                        x_start_date in date,
                                        x_end_date in date,
                                        x_description in varchar2,
                                        x_email_address in varchar2,
                                        x_fax in varchar2,
                                        x_out_pwd in out nocopy varchar2);


----------------------------------------------------------------------------
--
-- ldap_wrp_update_user_loader (PUBLIC)
--   This is called by the fnd_user_pkg and fnd_web_sec.
--   It serves as a helper routine to call fnd_ldap_wrapper.update_user
--   when we need to synch the user update to OID.
-- Note
--   Please note that even this is public procedure, it does not mean for
--   other public usage. This is mainly created as a helper routine to
--   service the user form and the user package.
/*#
 * This is called by the fnd_user_pkg and fnd_web_sec.
 * It serves as a helper routine to call fnd_ldap_wrapper.update_user
 * when we need to synch the user update to OID.
 * Please note that even this is public procedure, it does not mean for
 * other public usage. This is mainly created as a helper routine to
 * service the user form and the user package.
 * @param x_user_name in varchar2 The user name
 * @param x_hashed_password in varchar2 The hashed user password
 * @param x_start_date in date Start date
 * @param x_end_date in date End date
 * @param x_description in varchar2 Description
 * @param x_email_address in varchar2 Email address
 * @param x_fax in varchar2 Fax
 * @param x_expire_pwd in boolean Inform LDAP/OID whether to expire the pwd
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname LDAP Wrapper Update User
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
procedure ldap_wrp_update_user_loader(x_user_name in varchar2,
                                   x_hashed_password in varchar2,
                                   x_start_date in date,
                                   x_end_date in date,
                                   x_description in varchar2,
                                   x_email_address in varchar2,
                                   x_fax in varchar2,
                                   x_expire_pwd in pls_integer default 1);

----------------------------------------------------------------------------
--
-- RemoveSecurityAttrs (PUBLIC)
--   This API is used to remove AK Security Attributes that are added to a user
--   when associating an employee, customer or supplier id
-- Note
--   Please note that removing AK Security Attributes can adversely affect Product
--   functionality and should only be called by System Administrators that understand
--   the complete impact of their removal.
procedure RemoveSecurityAttrs(x_user_name in varchar2);

PIISUCC   CONSTANT number :=  0; /* Everything completed successfully */
PIINOUSR  CONSTANT number := -1; /* The USER didn't exist on FND_USER */
PIIWFPED  CONSTANT number := -2; /* The USER has pending information on
                                 -- the workflow tables, unable to remove PII
                                 -- information */
PIIWFPROP CONSTANT number := -3; /* Error at wf_local_synch.propagate_user */
PIIUERR   CONSTANT number := -4; /* Unexpected Error */

----------------------------------------------------------------------------
--
-- remove_pii_user (PUBLIC)
--   This function will remove as much as possible of
--   the FND-PII ( personal identifiable information ) for a given
--   username and it will free that username for reuse. Also note
--   that the USER_ID will not be reusable, it remains unique and un-reusable
--   WARNING: Be aware that this process is irreversible and historic data
--            that is linked using the USERNAME from the FND_USER table
--            will become unrecoverable, which is the purpose of this API.
-- Note
--   Even though this is a public declared function, it does not mean
--   for general public usage. This is mainly created as a helper routine
--   to comply with the specific need of reuse a username by iRecruitment.
--   Remember that the caller(DEV application group) is responsible for
--   verifying that their DATA remains consistance after call this function,
--   the database "commit" of the transaction is also controlled by the caller.
--   This process is intended for ONE-AT-TIME user updates and is not
--   a replacement for the MASKING-project or intended for BULK-process users.
--
-- Return codes:
--    0: Success(PIISUCC),     -1: No user(PIINOUSR),
--   -2: WF pending(PIIWFPED), -3: Error at wf_local_synch.propagate_user(PIIWFPROP)
--   -4: Unknown Error(PIIUERR)
-- Note about PIIWFPED :
--   Please have the user or sysadmin clear all pending notifications
--   or product specific flows for this user, before you attempt to call
--   remove_pii_user again.
/*#
 * This function will remove as much as possible of
 * the FND-PII ( personal identifiable information ) for a given
 * username and it will free that username for reuse. Also note
 * that the USER_ID will not be reusable, it remains unique and un-reusable
 * Even though this is a public declared function, it does not mean
 * for general public usage. This is mainly created as a helper routine
 * to comply with the specific need of reuse a username by iRecruitment.
 * Remember that the caller(DEV application group) is responsible for
 * verifying that their DATA remains consistance after call this function,
 * the database "commit" of the transaction is also controlled by the caller.
 * @param x_user_name in varchar2 The user name
 * @return 0: Success(PIISUCC), -1: No user(PIINOUSR), -2: WF pending(PIIWFPED), -3: Error at wf_local_synch.propagate_user(PIIWFPROP), -4: Unknown Error(PIIUERR)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Remove PII user information
 * @rep:compatibility S
 * @rep:ihelp FND/@mesgdict#mesgdict See the related online help
 */
  function remove_pii_user(x_user_name VARCHAR2) return number;

----------------------------------------------------------------------------
-- getEFPassword (AOL INTERNAL LOADER ONLY)
--   Set user password from value returned from FND_WEB_SEC.get_efp_loader
--   This is to update column ENCRYPTED_FOUNDATION_PASSWORD in table FND_USER
--
-- Input (Mandatory)
--  username:       User Name
--
-- Output
--  new-Encrypted-foundation value to be use in the .ldt file
--
function getEFPassword(username varchar2 ) return varchar2;


----------------------------------------------------------------------
--
-- CreateLocalUser (PUBLIC)
--   Insert new user record into FND_USER table.
--   If that user exists already, exception raised with the error message.
--   There are three input arguments must be provided. All the other columns
--   in FND_USER table can take the default value.
--
--   *** NOTE: This version accepts the old customer_id/employee_id
--   keys foreign keys to the "person".
--
-- Input (Mandatory)
--  x_user_name:            The name of the new user
--  x_owner:                'SEED' or 'CUST'(customer)
--  x_unencrypted_password: The password for this new user
--
procedure CreateLocalUser (
  x_user_name                  in varchar2,
  x_owner                      in varchar2,
  x_unencrypted_password       in varchar2,
  x_session_number             in number default 0,
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null,
  x_last_logon_date            in date default null,
  x_description                in varchar2 default null,
  x_password_date              in date default null,
  x_password_accesses_left     in number default null,
  x_password_lifespan_accesses in number default null,
  x_password_lifespan_days     in number default null,
  x_employee_id                in number default null,
  x_email_address              in varchar2 default null,
  x_fax                         in varchar2 default null,
  x_customer_id                 in number default null,
  x_supplier_id                 in number default null,
  x_person_party_id             in number default null);

----------------------------------------------------------------------------
--
-- ChangePassword (PUBLIC)
--   Set new password for user after validating the existing password
--   within the number of tries allowed by profile SIGNON_PASSWORD_FAILURE_LIMIT.
--   If profile is not set then a default value of 5 is used.
--
-- Usage example in pl/sql
--   begin fnd_user_pkg.changepassword('SCOTT', 'TIGER', 'WELCOME', 'WELCOME'); end;
--
-- Input (Mandatory)
--  username:       User Name
--  oldpassword     Old Password
--  newpassword1    New Password
--  newpassword2    New Password verify
--
function ChangePassword(username      in varchar2,
                        oldpassword   in varchar2,
                        newpassword1   in varchar2,
                        newpassword2   in varchar2) return varchar2;
end FND_USER_PKG;

/
