--------------------------------------------------------
--  DDL for Package FND_SSO_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SSO_UTIL" AUTHID CURRENT_USER as
/* $Header: AFSCOSTS.pls 120.0.12010000.4 2018/04/12 20:27:01 ctilley noship $ */

/*****************************************************************************/

G_ENABLED             constant varchar2(10) := 'ENABLED';
G_DISABLED            constant varchar2(10) := 'DISABLED';
OIDUSER_NOTFOUND_GUID_MARK      constant raw(16) := hextoraw('F0');
CORRUPTEDSUB_GUID_MARK      constant raw(16) := hextoraw('F1');
UNKNOWN_FAILURE_GUID_MARK      constant raw(16) := hextoraw('F2');


/** Future use **/
/*  Public procedure to enable LDAP integration.  This does not register the instance.
 */
procedure  enableLDAPIntegration ;

/*  Public procedure to disable LDAP integration.  The instance will not be deregistered
 *  but can be used to temporarily disable the LDAP integration.
 */
procedure disableLDAPIntegration ;

/*  Public procedure to remove LDAP integration preference.  The instance will not be deregistered
 *
 */
procedure deleteLDAPIntegration;

/*  Public procedure to set a user or group of user's password to be externally
 * managed.  Local user's will not be changed.
 */
procedure setPasswordExternal(p_user_name_patt in varchar2, p_upd_local_user in varchar2 default 'N');


/*  Public procedure to set a user or group of user's APPS_SSO_LOCAL_LOGIN
 * profile to the specified value:
 *
 * SSO - Access given through SSO login only
 * Both - Access given trhough both Local and SSO login
 * Local - Access only given through Local login; password must exist unless linked
 * Null - Other levels will take affect
 */
procedure setUserLocalLoginProfile(p_user_name_patt in varchar2, p_profile_value in varchar2);


/*  Public procedure to set a user or group of user's APPS_SSO_LDAP_SYNC
 * profile to the specified value:
 *
 * Enable/Disable User LDAP Sync Profile at the user level
 * Both - Access given trhough both Local and SSO login
 * Local - Access only given through Local login; password must exist unless linked
 * Null - Other levels will take affect
 */
procedure setUserLDAPSyncProfile(p_user_name_patt in varchar2, p_profile_value in varchar2);


/*  Public procedure to unlink a user or group of user's
 *
 */
procedure unlink_user(p_user_name_patt in varchar2);


/**
* link_batch: will link, following AUtolink rules, the first 'batch_size' with
* their user_guid null.
* On success the user will either have a valid value. On failure, the user_guid
* will be populated with fail_guid_mark.
* it will commit the connection.
*
*/

  TYPE userCursor IS REF CURSOR RETURN fnd_user%rowtype;
procedure link_batch( cuser in userCursor );
/**

declare
 c fnd_sso_util.userCursor;
begin
  open c for select * from fnd_user where user_guid is null and rownum < 10;
  fnd_sso_util.link_batch(c);
  close c;
end;



**/

/*
rest_failure: reset failure guid marks.
It will commit the connection.
*/
procedure reset_failures;

/**
 Procedure provided for DRT
**/
procedure remove_pii(p_user_id IN NUMBER);

end fnd_sso_util;

/
