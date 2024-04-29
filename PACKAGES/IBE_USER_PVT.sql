--------------------------------------------------------
--  DDL for Package IBE_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_USER_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVUSRS.pls 120.3 2005/08/29 09:26:24 appldev ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_USER_PVT';

null_char varchar2(8) := '*NULL*';
null_date date := to_date('2', 'J');
null_number number := -999;


/*+====================================================================
| PROCEDURE NAME
|    Create_User
|
| DESCRIPTION
|    This API is called by Create_Person,
|                          Create_Organization
| USAGE
|    -   Creates FND USer
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -    FND_USER_PKG.Create_User
+======================================================================*/
Procedure Create_User(
        p_user_name		IN	VARCHAR2,
        p_password		IN	VARCHAR2,
        p_start_date        	IN  DATE,
        p_end_date          	IN  DATE,
        p_password_date     	IN  DATE,
        p_email_address     	IN  VARCHAR2,
        p_customer_id       	IN  NUMBER,
        x_user_id           	OUT NOCOPY  NUMBER );


/*+====================================================================
| PROCEDURE NAME
|    Update_User
|
| DESCRIPTION
|    This API is called by User Management to map a new Contact to the User Name
|
| USAGE
|    -   Updates FND User - Contact Mapping
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -    FND_USER_PKG.UpdateUser
+======================================================================*/

Procedure Update_User(
    p_user_name		IN	VARCHAR2,
    p_password		IN	VARCHAR2,
    p_start_date  IN  DATE,
    p_end_date    IN  DATE,
    p_old_password IN  VARCHAR2,
    p_party_id		IN	NUMBER
);


/*+====================================================================
| PROCEDURE NAME
|    Create_User
|
| DESCRIPTION
|    This API is called by while revoking sites from user in User Management
|
| USAGE
|    - This API calls FND_USER_RESP_GROUPS_API and end dates the responsibility
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -     FND_USER_RESP_GROUPS_API.update_assignmets
+======================================================================*/
Procedure Update_Assignment(
	   p_user_id               IN  NUMBER,
	   p_responsibility_id     IN  NUMBER,
	   p_resp_application_id   IN  NUMBER,
	   p_security_group_id     IN  NUMBER default null,
	   p_start_date            IN  DATE default null,
	   p_end_date              IN  DATE,
	   p_description           IN  VARCHAR2 default null);


/*+====================================================================
| FUNCTION NAME
|    TestUserName
|
| DESCRIPTION
|    This api test whether a username exists in FND and/or in OID.
|
| USAGE
|    - This API is called for validating the username ion Registration
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -     FND_USER_PKG.TestUserName
+======================================================================*/


function TestUserName(p_user_name in varchar2) return pls_integer;

end ibe_user_pvt;

 

/
