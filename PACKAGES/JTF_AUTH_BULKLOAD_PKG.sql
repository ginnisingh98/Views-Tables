--------------------------------------------------------
--  DDL for Package JTF_AUTH_BULKLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AUTH_BULKLOAD_PKG" AUTHID CURRENT_USER as
/* $Header: JTFSEABS.pls 120.1 2005/07/02 02:10:07 appldev ship $ */
/* ASSIGN_ROLE: assigns an existing role to an existing user in the 'CRM_DOMAIN'
 *	USER_NAME	userid (case insensitive, lower case is converted to
 *				upper case)
 *	ROLE_NAME	role name (case insensitive, lower case is converted
 *				to upper case)
 */
procedure ASSIGN_ROLE (
  USER_NAME in VARCHAR2,
  ROLE_NAME in VARCHAR2
);

/* ASSIGN_ROLE: assigns an existing role to an existing user in the 'CRM_DOMAIN' with source table name and source table key
 *	USER_NAME	userid (case insensitive, lower case is converted to
 *				upper case)
 *	ROLE_NAME	role name (case insensitive, lower case is converted
 *				to upper case)
 *      OWNERTABLE_NAME owner table name, must be in FND_LOOKUPS (case insensit *                   ive, lower case is converted to upper case)
 *      OWNERTABLE_KEY owner table key
 */
procedure ASSIGN_ROLE (
  USER_NAME in VARCHAR2,
  ROLE_NAME in VARCHAR2,
  OWNERTABLE_NAME in VARCHAR2,
  OWNERTABLE_KEY in VARCHAR2
);

/* ASSIGN_ROLE: assigns an existing role to an existing user in the 'CRM_DOMAIN'
 *	USER_NAME	userid (case insensitive, lower case is converted to
 *				upper case)
 *	ROLE_NAME	role name (case insensitive, lower case is converted
 *				to upper case)
 *      APP_ID application id
*/
procedure ASSIGN_ROLE (
  USER_NAME in VARCHAR2,
  ROLE_NAME in VARCHAR2,
  APP_ID in NUMBER
);

/* ASSIGN_ROLE: assigns an existing role to an existing user in the 'CRM_DOMAIN' with source table name and source table key
 *	USER_NAME	userid (case insensitive, lower case is converted to
 *				upper case)
 *	ROLE_NAME	role name (case insensitive, lower case is converted
 *				to upper case)
 *      OWNERTABLE_NAME owner table name, must be in FND_LOOKUPS (case insensit *                   ive, lower case is converted to upper case)
 *      OWNERTABLE_KEY owner table key
 *      APP_ID application id
 */
procedure ASSIGN_ROLE (
  USER_NAME in VARCHAR2,
  ROLE_NAME in VARCHAR2,
  OWNERTABLE_NAME in VARCHAR2,
  OWNERTABLE_KEY in VARCHAR2,
  APP_ID in NUMBER
);

end JTF_AUTH_BULKLOAD_PKG;

 

/
