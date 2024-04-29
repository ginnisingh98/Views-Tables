--------------------------------------------------------
--  DDL for Package FND_SSO_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SSO_MANAGER" AUTHID CURRENT_USER as
/* $Header: fndssos.pls 120.3 2005/09/23 21:35:05 scheruku noship $ */
/*# This package provides APIs for central Login/Logout Management
* features. It provides an abstraction for Apps/SSO management of the above
* features.
* @rep:scope public
* @rep:product FND
* @rep:displayname SSO Manager
* @rep:category BUSINESS_ENTITY FND_SSO_MANAGER
*/

 userNotFound EXCEPTION;

/*#
* This procedure takes a fnd_user.user_name as input and retrieves the user
* information from Oracle Internet Directory (OID). It checks if a TCA
* person party exists for the fnd_user. If it does not exist a new TCA
* person party is created. If one already exists the existing person party
* is updated with the details from OID.
* <p>
* This procedure assumes that the information in OID is the source of truth.
* <p>
*
* @param p_user_name  The fnd_user.user_name for whom the TCA person party
*                  information needs to be synchronized from OID
* <p>
*@rep:displayname Synchronize the LDAP user attributes into TCA with username
*
*/
procedure synch_user_from_LDAP(p_user_name in fnd_user.user_name%type);
--
---------------------------------------------------------------------------------------
/*#
* This function should be used by applications with delegated user
* administration. In certain deployments, Oracle E-Business Suite may
* not be the desired source to create or update users. These may be Single
* Sign-On (SSO) and Oracle Internet Directory (OID) integrated deployments,
* or, just native Oracle E-Business Suite deployments. Regardless of the
* type of deployment, applications should be capable of turning off user
* creation and updation. The central user provisioning APIs will throw an
* exception if applications try to create or update users when the
* deployment has disabled them.
* <p>
* This function returns <code>true</code> if the users can be created
* or updated in Oracle E-Business Suite or a <code>false</code> otherwise.
* <p>
* The function currently relies on the profile option Applications SSO User
* Creation and Updation Allowed (APPS_SSO_USER_CREATE_UPDATE). In future
* releases it may also look at the synchronization profile registered in
* OID, if available.
* <p>
* @return <code>true<code> if APPS_SSO_USER_CREATE_UPDATE is DISABLED
* @rep:displayname Is User Create and Update Allowed
*
*/
function isUserCreateUpdateAllowed return boolean;
--
---------------------------------------------------------------------------------------
/*# API return the login URL with requestUrl and cancelUrl as URL parameters
*
* This function returns the URL to the central login servlet. You will need to
* redirect to the URL to see the login page. You may be redirected to the
* either the local login page or the SSO server. The redirection decision
* is based on factors like:<ul>
*   <li>the deployment (whether SSO or local authentication)
*   <li>whether the user has previously logged into the system
*   <li>the previous login page
*   <li>the session state, if one exists
*   </ul>
* <p>
* The parameters are appended to the URL in the form of name-value pairs.
* The parameter values are encoded with the correct character set. The
* langCode parameter is appended only if it is not null.
* <p>
*
* @param requestURL  A fully qualified URL that you want to redirect to
*                    after a successful authentication
* @param cancelURL   A fully qualified URL that you want to redirect to
*                    when user clicks on Cancel button in Login page
* @param langCode    The Oracle language code (not the HTTP Language code)
*                    that is installed in Oracle E-Business Suite
* <p>
*
* @return            A fully qualified URL with the parameters
* <p>
*
* @rep:displayname Get Login URL
*
*/
function getLoginUrl(requestUrl    in      varchar2 default NULL,
                     cancelUrl     in      varchar2 default NULL,
                     langCode in varchar2 default NULL)
return varchar2;

--
---------------------------------------------------------------------------------------
/*#
* This function returns the URL to the central logout servlet. You will need
* to redirect to the URL to logout of Oracle E-Business Suite. You may be
* redirected to the either the local logout routine or the SSO server to do
* a global logout. The redirection decision is based on factors like:<ul>
*   <li>the deployment (whether SSO or local authentication)
*   <li>the login page you used to access the system
*   <li>the session state, if one exists
*   </ul>
* <p>
* The parameters are appended to the URL in the form of name-value pairs.
* The parameter values are encoded with the correct character set.
* <p>
*
* @param returnURL   A fully qualified URL that you want to redirect to
*                    after logging out of Oracle E-Business Suite
* <p>
*
* @return            A fully qualified logout URL with the parameter
* <p>
*
* @rep:displayname   Get Logout URL with returnURL
*/
function getLogoutUrl(returnUrl	in	varchar2 default NULL)
return varchar2;
--
---------------------------------------------------------------------------------------
/*#
* This function returns the value of the nickname attribute of the OID user
* to which the input fnd username is linked to.
*
* @param p_user_name   FND_USER user_name
*
* @return            The nickname attribute of the OID user linked to the input
*                    FND_USER. It returns null if the user is not linked or if the
*                    deployment is not sso enabled. The return is a varchar2 of size 4000
* <p>
*
* @rep:displayname   Get nickname attribute of OID user.
*/
function get_ldap_user_name(p_user_name in fnd_user.user_name%type)
return varchar2;
--
---------------------------------------------------------------------------------------
function modplsql_currentUrl
return varchar2;
--
---------------------------------------------------------------------------------------
/*#
* This function tells if the password for the given user is changeable
* from within Oracle E-Business Suite. This method should be used by
* applications to check if Oracle E-Business Suite is allowed to change
* user passwords. In certain SSO deployments, user passwords may be
* externally managed in Oracle Internet Directory (OID) or similar LDAP
* directories. The passwords may not even be stored within Oracle
* E-Business Suite. In these deployments the password change should be
* redirected to the externally managed change password user interfaces.
* <p>
*
* @param username  The fnd_user.user_name whose password needs to be changed
* <p>
*
* @return          <code>true</code> if the password is changeable,
*                  <code>false</code> otherwise
* <p>
*
* <p>
*
* @rep:displayname   Is Password Changeable
*/
function isPasswordChangeable(username in varchar2) return boolean;
--
---------------------------------------------------------------------------------------
end FND_SSO_MANAGER;

 

/
