--------------------------------------------------------
--  DDL for Package CS_TZ_GET_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_TZ_GET_DETAILS_PVT" AUTHID CURRENT_USER AS
/* $Header: csvtzgds.pls 120.1 2005/07/21 11:03:19 appldev ship $ */


/****************************************************************************
  --  GLOBAL VARIABLES
****************************************************************************/

  G_PKG_NAME   	CONSTANT    VARCHAR2(200) := 'CS_TZ_GET_DETAILS_PVT';
  G_APP_NAME   	CONSTANT    VARCHAR2(3)   := 'CS';
  G_API_VERSION	CONSTANT    NUMBER     	  := 1.0;

/****************************************************************************
  --  DATA STRUCTURES
*****************************************************************************/


/*****************************************************************************
  --  Procedures and Functions
*****************************************************************************/

PROCEDURE GET_GMT_DEVIATION(P_API_VERSION    IN         NUMBER,
                            P_INIT_MSG_LIST  IN         VARCHAR2,
                            P_START_TZ_ID    IN         NUMBER,
                            P_END_TZ_ID      IN         NUMBER,
                            P_TIME_LAG       IN         NUMBER,
                            X_GMT_DEV        OUT NOCOPY NUMBER,
                            X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                            X_MSG_COUNT      OUT NOCOPY NUMBER,
                            X_MSG_DATA       OUT NOCOPY VARCHAR2);


PROCEDURE GET_LEADTIME(P_API_VERSION    IN  NUMBER,
                       P_INIT_MSG_LIST  IN  VARCHAR2,
                       P_START_TZ_ID    IN  NUMBER,
                       P_END_TZ_ID      IN  NUMBER,
                       X_LEADTIME       OUT NOCOPY NUMBER,
                       X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                       X_MSG_COUNT      OUT NOCOPY NUMBER,
                       X_MSG_DATA       OUT NOCOPY VARCHAR2);

PROCEDURE  GET_LEADTIME (P_API_VERSION   IN      NUMBER,
                         P_INIT_MSG_LIST IN      VARCHAR2,
                         P_START_TZ_ID   IN      NUMBER,
		 	 P_END_ZIP_CODE  IN      VARCHAR2,
                         P_END_CITY      IN      VARCHAR2,
                         P_END_STATE     IN      VARCHAR2,
                         P_END_COUNTRY   IN      VARCHAR2,
                         X_LEADTIME      OUT   NOCOPY   NUMBER,
                         X_RETURN_STATUS OUT   NOCOPY   VARCHAR2,
                         X_MSG_COUNT     OUT   NOCOPY   NUMBER,
                         X_MSG_DATA      OUT   NOCOPY   VARCHAR2);

PROCEDURE CUSTOMER_PREFERRED_TIME_ZONE
( p_incident_id            IN  NUMBER
, p_task_id                IN  NUMBER
, p_resource_id            IN  NUMBER
, p_cont_pref_time_zone_id IN  NUMBER   DEFAULT NULL
, p_incident_location_id   IN  NUMBER   DEFAULT NULL
, p_incident_location_type IN  VARCHAR2 DEFAULT NULL
, p_contact_party_id       IN  NUMBER   DEFAULT NULL
, p_contact_phone_id       IN  NUMBER   DEFAULT NULL
, p_contact_address_id     IN  NUMBER   DEFAULT NULL
, p_customer_id            IN  NUMBER   DEFAULT NULL
, p_customer_phone_id      IN  NUMBER   DEFAULT NULL
, p_customer_address_id    IN  NUMBER   DEFAULT NULL
, x_timezone_id            OUT NOCOPY   NUMBER
, x_timezone_name          OUT NOCOPY   VARCHAR2
) ;

END CS_TZ_GET_DETAILS_PVT;

 

/
