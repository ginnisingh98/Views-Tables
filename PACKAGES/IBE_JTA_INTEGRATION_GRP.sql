--------------------------------------------------------
--  DDL for Package IBE_JTA_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_JTA_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: IBEVUREJS.pls 120.0.12010000.1 2008/07/28 11:39:48 appldev ship $ */


	G_USERTYPEREG_ID 	CONSTANT	VARCHAR2(30):= 'USERTYPEREG_ID';
	G_USERTYPE_KEY 		CONSTANT	VARCHAR2(30):= 'USER_TYPE_KEY';
	G_USERTYPE_APPID	CONSTANT	VARCHAR2(30):= 'APPID';
	G_USER_CUSTOMER_ID	CONSTANT	VARCHAR2(30):= 'CUSTOMER_ID';
	G_USER_PERSON_PARTY_ID	CONSTANT	VARCHAR2(30):= 'PERSON_PARTY_ID';


/*+====================================================================
| FUNCTION NAME
|    postRejection
|
| DESCRIPTION
|    This function is seeded as a subscription to the rejection event
|
| USAGE
|    -   Inactivates the contact associated with the rejected username.
|
|  REFERENCED APIS
|     This API calls the following APIs
|    		-  ibe_party_v2pvt.Update_Party_Status
|	  	-  PRM_USER_PVT.INACTIVATEPARTNERUSER
+======================================================================*/

FUNCTION postRejection(
		       p_subscription_guid      IN RAW,
		       p_event                  IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2;


/*+====================================================================
| FUNCTION NAME
|    getIsUserCompanyToBeExpired
|
| DESCRIPTION
|    This API is called by postRejection
|
| USAGE
|    -   To determine if Company details are also to be inactivated?
|
|  REFERENCED APIS
+======================================================================*/

FUNCTION getIsUserCompanyToBeExpired(
		p_contact_party_id IN NUMBER)
RETURN VARCHAR2;


/*+====================================================================
| FUNCTION NAME
|    getIsPartialRegistrationUser
|
| DESCRIPTION
|    This API is called by postRejection
|
| USAGE
|    -   Determines whether the user under rejection had registered
|	 using one of the partial registration usertypes
|
|  REFERENCED APIS
+======================================================================*/

FUNCTION getIsPartialRegistrationUser(
		p_user_reg_id IN NUMBER)
RETURN VARCHAR2;


/*+====================================================================
| FUNCTION NAME
|    getIsPartnerUser
|
| DESCRIPTION
|    This API is called by postRejection
|
| USAGE
|    -   Determines whether the user under rejection had registered
|	 using one of the partner registration usertypes
|
|  REFERENCED APIS
+======================================================================*/

FUNCTION getIsPartnerUser(
		p_user_reg_id IN NUMBER)
RETURN VARCHAR2;

END IBE_JTA_INTEGRATION_GRP;

/
