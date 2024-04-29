--------------------------------------------------------
--  DDL for Package JTF_AUTH_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AUTH_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: JTFSEASS.pls 120.2 2005/10/25 05:01:37 psanyal ship $ */

/*   	API name	:	CHECK_PERMISSION
 *	Type		: 	Public
 *	Function	:	Checks if the user has the given permission or not
 *                              This API is NOT to be used for access control, i.e.,
 *				you should not use this API to determine if the "current
 *				user" has a permission to access a form for example.
 *				Instead this should ONLY be used if "another user" is
 *				assigned a permission or not. You should rely on function
 * 				security for access control. If you rely on this API to
 *				control access for a "current user", you will get erroneous
 *				results in maintenance mode. See bug # 2117260 for details.
 *
 *	Parameters	:
 *
 *      OUT 	        :
 *
 *      X_RETURN_STATUS :
 *	holds the status of the procedure call, its value is
 *	FND_API.G_RET_STS_SUCCESS when the API completes successfully.
 *      FND_API.G_RET_STS_UNEXP_ERROR when the API encounters an unexpected
 *	error, in which case X_FLAG is undefined.
 *
 *      X_FLAG		:
 *      1 if the user has the permission, 0 otherwise
 *
 *	IN		:
 *
 *	USER_NAME	:
 *	user name (case insensitive, lower case is converted to upper case)
 *
 *	DOMAIN_NAME	:
 *	domain name (case insensitive, lower case is converted to upper case.
 *	Defaults to "CRM_DOMAIN")
 *
 * 	PERMISSION_NAME	:
 *	permission name (case sensitive)
 */

PROCEDURE check_permission (
  x_flag OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_user_name IN VARCHAR2,
  p_domain_name IN VARCHAR2 DEFAULT 'CRM_DOMAIN',
  p_permission_name IN VARCHAR2
);



/* assign_perm: assigns an existing permission to an existing role
 *
 *	ROLE_NAME	role name (case insensitive, lower case is converted
 *				to upper case)
 *	PERM_NAME	permission name (case sensitive)
 *      APP_ID application id
*/

procedure assign_perm (
  ROLE_NAME in VARCHAR2,
  PERM_NAME in VARCHAR2,
  APP_ID in NUMBER
);


END jtf_auth_security_pkg;

 

/
