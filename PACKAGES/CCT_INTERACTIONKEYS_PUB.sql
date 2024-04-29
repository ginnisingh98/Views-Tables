--------------------------------------------------------
--  DDL for Package CCT_INTERACTIONKEYS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_INTERACTIONKEYS_PUB" AUTHID CURRENT_USER as
/* $Header: cctinkys.pls 115.8 2003/08/23 01:19:53 gvasvani noship $ */

/* Global CCT Object Type Keys */

KEY_CUSTOMER_ID       	VARCHAR2(64) 	:='PARTY_ID';
KEY_CUSTOMER_NAME 		VARCHAR2(64)	:='CustomerName';
KEY_MEDIA_ITEM_ID 	VARCHAR2(64)	:='occtMediaItemID';
KEY_ANI 			VARCHAR2(64) 	:='occtANI';
KEY_DNIS			VARCHAR2(64)	:='occtDNIS';
KEY_PARTY_NUMBER	VARCHAR2(64)	:='CustomerNum';
KEY_QUOTE_NUMBER	VARCHAR2(64)	:='QuoteNum';
KEY_ORDER_NUMBER	VARCHAR2(64)	:='OrderNum';
KEY_COLLATERAL_REQUEST_NUMBER VARCHAR2(64) := 'CollateralReq';
KEY_ACCOUNT_NUMBER	VARCHAR2(64) 	:='AccountCode';
KEY_EVENT_REGISTRATION_CODE	VARCHAR2(64):='EventCode';
KEY_MARKETING_PIN	VARCHAR2(64)	:='MarketingPIN';
KEY_SERVICE_KEY		VARCHAR2(64)	:='ServiceKey';
KEY_SERVICE_REQUEST_NUMBER VARCHAR2(64) :='ServiceRequestNum';
KEY_CONTRACT_NUMBER VARCHAR2(64) :='ContractNum';
KEY_SOURCE_CODE	VARCHAR2(64) 	:='SourceCode';
KEY_CONTRACT_NUMBER_MODIFIER	VARCHAR2(64) 	:='ContractNumModifier';


/* The following keys should not be seeded in CCT_INTERACTION_KEYS table
   These keys are used internally by applications for  Warm Transfer/Conference
   and other functional processing common to E-Business Suite
*/
KEY_SUBJECT_ID VARCHAR2(64) :='SubjectID'; /* Party ID of Contact Party */
KEY_OBJECT_ID VARCHAR2(64)  :='ObjectID'; /* Party ID of Customer Party */
KEY_CONTACT_POINT_ID VARCHAR2(64):='ContactPointID'; /* Contact Point ID of Primary Phone */
KEY_PRIMARY_EMAIL_ID VARCHAR2(64)  :='PrimaryEmailID'; /* Contact Point ID of Primary Email */
KEY_CUSTOMER_ACCOUNT_ID VARCHAR2(64)  :='CustomerAccountID'; /* Account ID of Customer Party */
KEY_LOCATION_ID VARCHAR2(64)  :='LocationID'; /* Location ID of Primary Address */
KEY_INTERACTION_ID VARCHAR2(64)  :='InteractionID'; /* Interaction ID for an interaction */
KEY_ACTION_ID VARCHAR2(64)  :='ActionID'; /* Action ID for the Interaction */

END CCT_INTERACTIONKEYS_PUB;

 

/
