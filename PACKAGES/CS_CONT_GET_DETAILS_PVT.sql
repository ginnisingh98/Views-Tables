--------------------------------------------------------
--  DDL for Package CS_CONT_GET_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONT_GET_DETAILS_PVT" AUTHID CURRENT_USER AS
/* $Header: csvscgds.pls 120.0.12010000.3 2010/04/14 06:21:57 bkanimoz ship $ */

/****************************************************************************
  --  GLOBAL VARIABLES
****************************************************************************/

  G_PKG_NAME   	CONSTANT    VARCHAR2(200) := 'CS_CONT_GET_DETAILS_PVT';
  G_APP_NAME   	CONSTANT    VARCHAR2(3)   := 'CS';
  G_API_VERSION	CONSTANT    NUMBER     	  := 1;

/****************************************************************************
  --  DATA STRUCTURES
*****************************************************************************/
--  SUBTYPE Ent_contract_tab IS OKS_ENTITLEMENTS_PUB.ENT_CONT_TBL;
  SUBTYPE Ent_contract_tab IS OKS_ENTITLEMENTS_PUB.GET_CONTOP_TBL;
  SUBTYPE Ent_contact_tab IS OKS_ENTITLEMENTS_PUB.ENT_CONTACT_TBL;

  TYPE inc_contact_rec IS RECORD
           (contact_id              Number,
            valid_contact           Varchar2(1));
  TYPE inc_contact_tab IS TABLE OF inc_contact_rec INDEX BY BINARY_INTEGER;

/*****************************************************************************/

PROCEDURE GET_CONTRACT_LINES( P_API_VERSION            IN      NUMBER ,
            		      P_INIT_MSG_LIST          IN      VARCHAR2,
                              P_CONTRACT_NUMBER        IN      OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE,
                              P_SERVICE_LINE_ID        IN      NUMBER,
                              P_CUSTOMER_ID            IN      NUMBER,
                              P_SITE_ID                IN      NUMBER,
                              P_CUSTOMER_ACCOUNT_ID    IN      NUMBER,
                              P_SYSTEM_ID              IN      NUMBER,
                              P_INVENTORY_ITEM_ID      IN      NUMBER,
                              P_CUSTOMER_PRODUCT_ID    IN      NUMBER,
                              P_REQUEST_DATE           IN      DATE,
			      P_BUSINESS_PROCESS_ID    IN      NUMBER DEFAULT NULL,
			      P_SEVERITY_ID	       IN      NUMBER DEFAULT NULL,
			      P_TIME_ZONE_ID	       IN      NUMBER DEFAULT NULL,
			      P_CALC_RESPTIME_FLAG     IN      VARCHAR2 DEFAULT NULL,
			      P_VALIDATE_FLAG          IN      VARCHAR2,
                              P_DATES_IN_INPUT_TZ      IN      VARCHAR2 DEFAULT 'N',
                              P_INCIDENT_DATE          IN      DATE DEFAULT NULL,
			      P_CUST_SITE_ID           IN      NUMBER DEFAULT NULL,--added for Access Hour project
			      P_CUST_LOC_ID	       IN      NUMBER DEFAULT NULL,--added for Access Hour project
                              X_ENT_CONTRACTS          OUT     NOCOPY ENT_CONTRACT_TAB,
                              X_RETURN_STATUS          OUT     NOCOPY VARCHAR2,
                              X_MSG_COUNT              OUT     NOCOPY NUMBER,
                              X_MSG_DATA               OUT     NOCOPY VARCHAR2);



PROCEDURE GET_REACTION_TIME( P_API_VERSION             IN      NUMBER ,
		             P_INIT_MSG_LIST           IN      VARCHAR2,
			     P_START_TZ_ID             IN      NUMBER,
                             P_SR_SEVERITY             IN      NUMBER,
                             P_BUSINESS_PROCESS_ID     IN      NUMBER,
                             P_REQUEST_DATE            IN      DATE,
                             P_DATES_IN_INPUT_TZ       IN      VARCHAR2 DEFAULT 'N',
                             P_SERVICE_LINE_ID         IN      NUMBER,
			     P_CUST_ID		       IN      NUMBER,
			     P_CUST_SITE_ID            IN      NUMBER,
			     P_CUST_LOC_ID             IN      NUMBER,
                             X_REACT_BY_DATE           OUT     NOCOPY DATE,
                             X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
                             X_MSG_COUNT               OUT     NOCOPY NUMBER,
                             X_MSG_DATA                OUT     NOCOPY VARCHAR2);


PROCEDURE VALIDATE_CONTACT(  P_API_VERSION             IN    NUMBER,
                             P_INIT_MSG_LIST           IN    VARCHAR2,
                             P_CONTACT_ID              IN    NUMBER,
                             P_CONTRACT_ID             IN    NUMBER,
                             P_SERVICE_LINE_ID         IN    NUMBER,
                             X_RETURN_STATUS           OUT   NOCOPY VARCHAR2,
                             X_MSG_COUNT               OUT   NOCOPY NUMBER,
                             X_MSG_DATA                OUT   NOCOPY VARCHAR2,
                             X_VALID_CONTACT           OUT   NOCOPY VARCHAR2);

PROCEDURE VALIDATE_CONTACT ( P_API_VERSION             IN      NUMBER,
                             P_INIT_MSG_LIST           IN      VARCHAR2,
                             P_CONTACT_TAB             IN OUT  NOCOPY INC_CONTACT_TAB,
                             P_CONTRACT_ID             IN      NUMBER,
                             P_SERVICE_LINE_ID         IN      NUMBER,
                             X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
                             X_MSG_COUNT               OUT     NOCOPY NUMBER,
                             X_MSG_DATA                OUT     NOCOPY VARCHAR2);


END CS_CONT_GET_DETAILS_PVT;

/
