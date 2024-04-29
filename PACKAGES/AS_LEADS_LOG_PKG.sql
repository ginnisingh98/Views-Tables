--------------------------------------------------------
--  DDL for Package AS_LEADS_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LEADS_LOG_PKG" AUTHID CURRENT_USER as
/* $Header: asxtllgs.pls 115.6 2003/07/04 12:02:53 gbatra ship $ */
-- Start of Comments
-- Package name     : AS_LEADS_LOG_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_LOG_ID   IN OUT NOCOPY NUMBER,
          p_LEAD_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_SALES_STAGE_ID    NUMBER,
          p_WIN_PROBABILITY    NUMBER,
          p_DECISION_DATE    DATE,
          p_ADDRESS_ID    NUMBER,
          p_CHANNEL_CODE    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_TOTAL_AMOUNT    NUMBER,
	  p_SECURITY_GROUP_ID      NUMBER,
	  p_CUSTOMER_ID            NUMBER,
 	  p_DESCRIPTION            VARCHAR2,
	  p_SOURCE_PROMOTION_ID    NUMBER,
	  p_OFFER_ID               NUMBER,
   	  p_CLOSE_COMPETITOR_ID    VARCHAR2,
	  p_VEHICLE_RESPONSE_CODE  VARCHAR2,
 	  p_SALES_METHODOLOGY_ID   NUMBER,
	  p_OWNER_SALESFORCE_ID    NUMBER,
	  p_OWNER_SALES_GROUP_ID   NUMBER,
	  p_LOG_START_DATE	   DATE,
	  p_LOG_END_DATE	   DATE,
	  p_LOG_ACTIVE_DAYS	   NUMBER,
	  p_ENDDAY_LOG_FLAG	   VARCHAR2,
	  p_CURRENT_LOG		   NUMBER,
	  p_ORG_ID                 NUMBER,
	  p_TRIGGER_MODE 	   VARCHAR2);

PROCEDURE Update_Row(
          p_LOG_ID    IN OUT NOCOPY NUMBER,
          p_LEAD_ID    NUMBER,
	  p_OLD_LEAD_ID NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
	  p_OLD_LAST_UPDATE_DATE DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_SALES_STAGE_ID    NUMBER,
          p_WIN_PROBABILITY    NUMBER,
          p_DECISION_DATE    DATE,
          p_ADDRESS_ID    NUMBER,
          p_CHANNEL_CODE    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_TOTAL_AMOUNT    NUMBER,
	  p_SECURITY_GROUP_ID      NUMBER,
	  p_CUSTOMER_ID            NUMBER,
 	  p_DESCRIPTION            VARCHAR2,
	  p_SOURCE_PROMOTION_ID    NUMBER,
	  p_OFFER_ID               NUMBER,
   	  p_CLOSE_COMPETITOR_ID    VARCHAR2,
	  p_VEHICLE_RESPONSE_CODE  VARCHAR2,
 	  p_SALES_METHODOLOGY_ID   NUMBER,
	  p_OWNER_SALESFORCE_ID    NUMBER,
	  p_OWNER_SALES_GROUP_ID   NUMBER,
	  p_LOG_START_DATE	   DATE,
	  p_LOG_END_DATE	   DATE,
	  p_LOG_ACTIVE_DAYS	   NUMBER,
	  p_ENDDAY_LOG_FLAG	   VARCHAR2,
	  p_CURRENT_LOG		   NUMBER,
	  p_ORG_ID                 NUMBER,
	  p_TRIGGER_MODE 	   VARCHAR2);

PROCEDURE Lock_Row(
          p_LOG_ID    NUMBER,
          p_LEAD_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_SALES_STAGE_ID    NUMBER,
          p_WIN_PROBABILITY    NUMBER,
          p_DECISION_DATE    DATE,
          p_ADDRESS_ID    NUMBER,
          p_CHANNEL_CODE    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_TOTAL_AMOUNT    NUMBER);

PROCEDURE Delete_Row(
    p_LOG_ID  NUMBER);
End AS_LEADS_LOG_PKG;

 

/
