--------------------------------------------------------
--  DDL for Package JTF_UM_USERTYPE_CREDENTIALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_USERTYPE_CREDENTIALS" AUTHID CURRENT_USER as
/* $Header: JTFUMUCS.pls 115.7 2002/11/21 22:58:04 kching ship $ */

PROCEDURE ASSIGN_USERTYPE_CREDENTIALS
          (
	   X_USER_NAME VARCHAR2,
	   X_USER_ID   NUMBER,
	   X_USERTYPE_ID NUMBER
	   );

PROCEDURE ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_ID NUMBER,
	   X_APPLICATION_ID    NUMBER
	  );

PROCEDURE ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID            NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2,
	   X_APPLICATION_ID     NUMBER
	  );
PROCEDURE ASSIGN_DEFAULT_RESPONSIBILITY
          (
	   X_USER_ID            NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2,
	   X_APPLICATION_ID     NUMBER
	  );

PROCEDURE REVOKE_RESPONSIBILITY
          (
	   X_USER_ID            NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2,
	   X_APPLICATION_ID     NUMBER
	  );

PROCEDURE REVOKE_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_ID NUMBER,
	   X_APPLICATION_ID    NUMBER
	  );

PROCEDURE ASSIGN_ACCOUNT
          (
	   P_PARTY_ID          NUMBER,
	   P_USERTYPE_KEY      VARCHAR2,
	   P_ORG_PARTY_ID      NUMBER:=FND_API.G_MISS_NUM
	  );

PROCEDURE REJECT_DELETED_PEND_USER (P_USERNAME     in  VARCHAR2,
	                            X_PENDING_USER out NOCOPY VARCHAR2);

PROCEDURE ASSIGN_DEF_RESP(P_USERNAME     in  VARCHAR2,
	                  P_ACCOUNT_TYPE in VARCHAR2);

PROCEDURE ASSIGN_DEF_ROLES(P_USERNAME     in  VARCHAR2,
	                   P_ACCOUNT_TYPE in VARCHAR2);


/**
  * Procedure   :  get_usertype_resp
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine the responsibility attached to the usertype
  * Parameters  :
  * input parameters
  * @param     p_usertype_id
  *     description:  The usertyp_id
  *     required   :  Y
  *     validation :  Must be a valid usertype_id
  *  output parameters
  *     x_resp_id
  *     description: The responsibility_id associated to the responsibility
  *                  associated to the usertype
  *     x_app_id
  *     description: The app_id associated to the responsibility
  *                  associated to the usertype
**/
procedure get_usertype_resp(
                       p_usertype_id         in number,
                       p_resp_id             out NOCOPY number,
                       p_app_id              out NOCOPY number
                            );

/**
 * Procedure   :  grant_roles
 * Type        :  Private
 * Pre_reqs    :  None
 * Description :  Will grant roles to users
 * Parameters  :
 * input parameters
 *   p_user_name:
 *     description:  The user_name of the user
 *     required   :  Y
 *     validation :  Must be a valid user_name
 *   p_role_id
 *     description: The value of the JTF_AUTH_PRINCIPAL_ID
 *     required   :  Y
 *     validation :  Must exist as a JTF_AUTH_PRONCIPAL_ID
 *                   in the table JTF_AUTH_PRINCIPALS_B
 *   p_source_name
 *     description: The value of the name of the source
 *     required   :  Y
 *     validation :  Must be "USERTYPE" or "ENROLLMENT"
 *   p_source_id
 *     description: The value of the id associated with the source
 *     required   :  Y
 *     validation :  Must be a usertype_id or a subscription_id
 * output parameters
 * None
 */
procedure grant_roles (
                       p_user_name          in varchar2,
                       p_role_id            in number,
                       p_source_name         in varchar2,
                       p_source_id         in varchar2
                     );


/**
  * Procedure   :  set_default_login_resp
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will set the default responsibility of a user
  * Parameters  :
  * input parameters
  * @param     p_user_id
  *     description:  The user_id of a user
  *     validation :  Must be a valid user_id
  * @param     p_resp_id
  *     description: The responsibility_id associated to the default logon
  *                  responsibility of a  user
  *     required   :  Y
  *     validation :  Must be a valid responsibility_id
  * @param     p_app_id
  *     description: The app_id associated to the default logon
  *                  responsibility of a user
  *     required   : Y
  *     validation: Must be a valid application_id
  *  output parameters
  *  None
**/

procedure set_default_login_resp(
                       p_user_id             in number,
                       p_resp_id             in number,
                       p_app_id              in number
                                           );

/**
  * Procedure   :  set_default_login_resp
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will set the default responsibility of a user
  * Parameters  :
  * input parameters
  * @param     p_user_name
  *     description:  The user_name of a user
  *     validation :  Must be a valid user_name
  * @param     p_resp_id
  *     description: The responsibility_id associated to the default logon
  *                  responsibility of a  user
  *     required   :  Y
  *     validation :  Must be a valid responsibility_id
  * @param     p_app_id
  *     description: The app_id associated to the default logon
  *                  responsibility of a user
  *     required   : Y
  *     validation: Must be a valid application_id
  *  output parameters
  *  None
**/

procedure set_default_login_resp(
                       p_user_name           in varchar2,
                       p_resp_id             in number,
                       p_app_id              in number
                                           );


/**
  * Procedure   :  get_default_login_resp
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will set the default responsibility of a user
  * Parameters  :
  * input parameters
  * @param     p_user_id
  *     description:  The user_name of a user
  *     validation :  Must be a valid user_id
  * output parameters
  * @param     x_resp_id
  *     description: The responsibility_id associated to the default logon
  *                  responsibility of a  user
  * @param     x_app_id
  *     description: The app_id associated to the default logon
  *                  responsibility of a user
  * @param x_resp_key
  *     description: The responsibility_key associated to the default logon
  *                  responsibility of a user
  * @param x_resp_name
  *     description: The responsibility_name associated to the default logon
  *                  responsibility of a user
  *
  *  None
**/

procedure get_default_login_resp(
                       p_user_id             in number,
                       x_resp_id             out NOCOPY number,
                       x_app_id              out NOCOPY number,
                       x_resp_key            out NOCOPY varchar2,
                       x_resp_name           out NOCOPY varchar2
                                           );

/**
  * Procedure   :  get_default_login_resp
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will set the default responsibility of a user
  * Parameters  :
  * input parameters
  * @param     p_user_name
  *     description:  The user_name of a user
  *     validation :  Must be a valid user_name
  * output parameters
  * @param     x_resp_id
  *     description: The responsibility_id associated to the default logon
  *                  responsibility of a  user
  * @param     x_app_id
  *     description: The app_id associated to the default logon
  *                  responsibility of a user
  * @param x_resp_key
  *     description: The responsibility_key associated to the default logon
  *                  responsibility of a user
  * @param x_resp_name
  *     description: The responsibility_name associated to the default logon
  *                  responsibility of a user
  *
  *  None
**/

procedure get_default_login_resp(
                       p_user_name           in varchar2,
                       x_resp_id             out NOCOPY number,
                       x_app_id              out NOCOPY number,
                       x_resp_key            out NOCOPY varchar2,
                       x_resp_name           out NOCOPY varchar2
                                );

/**
  * Procedure   :  UPGRADE_PRIMARY_USER
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Concurrent program to upgrade primary users
  * Parameters  :
  * OUT parameters
  * As required by concurrent program standards
**/
PROCEDURE UPGRADE_PRIMARY_USER(ERRBUF  out NOCOPY VARCHAR2,
                               RETCODE out NOCOPY VARCHAR2
                               );

END JTF_UM_USERTYPE_CREDENTIALS;

 

/
