--------------------------------------------------------
--  DDL for Package Body AS_LEADS_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LEADS_LOG_PKG" as
/* $Header: asxtllgb.pls 115.10 2004/01/13 10:08:40 gbatra ship $ */
-- Start of Comments
-- Package name     : AS_LEADS_LOG_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_LEADS_LOG_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxtllgb.pls';

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
	  p_TRIGGER_MODE 	   VARCHAR2)
 IS
   CURSOR C2 IS SELECT AS_LEAD_LOG_S.nextval FROM sys.dual;
BEGIN
   --dbms_output.put_line('In The insert Row 1');
   If (px_LOG_ID IS NULL) OR (px_LOG_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_LOG_ID;
       CLOSE C2;
   End If;
   --dbms_output.put_line('In The insert Row 2');
   INSERT INTO AS_LEADS_LOG(
           LOG_ID,
           LEAD_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           STATUS_CODE,
           SALES_STAGE_ID,
           WIN_PROBABILITY,
           DECISION_DATE,
           ADDRESS_ID,
           CHANNEL_CODE,
           CURRENCY_CODE,
           TOTAL_AMOUNT,
	   SECURITY_GROUP_ID,
	   LOG_MODE,
	   CUSTOMER_ID,
	   DESCRIPTION ,
	   SOURCE_PROMOTION_ID,
	   OFFER_ID,
	   CLOSE_COMPETITOR_ID,
	   VEHICLE_RESPONSE_CODE,
	   SALES_METHODOLOGY_ID,
	   OWNER_SALESFORCE_ID,
	   OWNER_SALES_GROUP_ID,
  	   LOG_START_DATE,
	   LOG_END_DATE,
	   LOG_ACTIVE_DAYS,
	   ENDDAY_LOG_FLAG,
	   CURRENT_LOG,
	   ORG_ID
          ) VALUES (
           px_LOG_ID,
           decode( p_LEAD_ID, FND_API.G_MISS_NUM, NULL, p_LEAD_ID),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_STATUS_CODE),
           decode( p_SALES_STAGE_ID, FND_API.G_MISS_NUM, NULL, p_SALES_STAGE_ID),
           decode( p_WIN_PROBABILITY, FND_API.G_MISS_NUM, NULL, p_WIN_PROBABILITY),
           decode( p_DECISION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_DECISION_DATE),
           decode( p_ADDRESS_ID, FND_API.G_MISS_NUM, NULL, p_ADDRESS_ID),
           decode( p_CHANNEL_CODE, FND_API.G_MISS_CHAR, NULL, p_CHANNEL_CODE),
           decode( p_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_CURRENCY_CODE),
           decode( p_TOTAL_AMOUNT, FND_API.G_MISS_NUM, NULL, p_TOTAL_AMOUNT),
	   decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID),
	   p_TRIGGER_MODE,
           decode( p_CUSTOMER_ID, FND_API.G_MISS_NUM, NULL, p_CUSTOMER_ID),
           decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION),
           decode( p_SOURCE_PROMOTION_ID, FND_API.G_MISS_NUM, NULL, p_SOURCE_PROMOTION_ID),
           decode( p_OFFER_ID, FND_API.G_MISS_NUM, NULL, p_OFFER_ID),
           decode( p_CLOSE_COMPETITOR_ID, FND_API.G_MISS_NUM, NULL, p_CLOSE_COMPETITOR_ID),
           decode( p_VEHICLE_RESPONSE_CODE, FND_API.G_MISS_CHAR, NULL, p_VEHICLE_RESPONSE_CODE),
           decode( p_SALES_METHODOLOGY_ID, FND_API.G_MISS_NUM, NULL, p_SALES_METHODOLOGY_ID),
           decode( p_OWNER_SALESFORCE_ID, FND_API.G_MISS_NUM, NULL, p_OWNER_SALESFORCE_ID),
           decode( p_OWNER_SALES_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_OWNER_SALES_GROUP_ID),

           decode( p_LOG_START_DATE, FND_API.G_MISS_DATE, NULL, p_LOG_START_DATE),
           decode( p_LOG_END_DATE, FND_API.G_MISS_DATE, NULL, p_LOG_END_DATE),
           decode( p_LOG_ACTIVE_DAYS, FND_API.G_MISS_NUM, NULL, p_LOG_ACTIVE_DAYS),
           decode( p_ENDDAY_LOG_FLAG, FND_API.G_MISS_CHAR, NULL, p_ENDDAY_LOG_FLAG),
           decode( p_CURRENT_LOG, FND_API.G_MISS_NUM, NULL, p_CURRENT_LOG),
           decode( p_ORG_ID, FND_API.G_MISS_NUM, NULL, p_ORG_ID));
EXCEPTION
WHEN OTHERS THEN
	 NULL;
	 --dbms_output.put_line('Error in Insert Row');
	 --dbms_output.put_line('Error Number:'||SQLCODE);
	  --dbms_output.put_line('Error Message:'|| SUBSTR(SQLERRM, 1, 200));
End Insert_Row;
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
	  p_ORG_ID                 NUMBER ,
	  p_TRIGGER_MODE	   VARCHAR2)
 IS
 BEGIN
    --dbms_output.put_line('In The Update Row');
    Update AS_LEADS_LOG
    SET object_version_number =  nvl(object_version_number,0) + 1,
              LEAD_ID = decode( p_LEAD_ID, FND_API.G_MISS_NUM, LEAD_ID, p_LEAD_ID),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              STATUS_CODE = decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, p_STATUS_CODE),
              SALES_STAGE_ID = decode( p_SALES_STAGE_ID, FND_API.G_MISS_NUM, SALES_STAGE_ID, p_SALES_STAGE_ID),
              WIN_PROBABILITY = decode( p_WIN_PROBABILITY, FND_API.G_MISS_NUM, WIN_PROBABILITY, p_WIN_PROBABILITY),
              DECISION_DATE = decode( p_DECISION_DATE, FND_API.G_MISS_DATE, DECISION_DATE, p_DECISION_DATE),
              ADDRESS_ID = decode( p_ADDRESS_ID, FND_API.G_MISS_NUM, ADDRESS_ID, p_ADDRESS_ID),
              CHANNEL_CODE = decode( p_CHANNEL_CODE, FND_API.G_MISS_CHAR, CHANNEL_CODE, p_CHANNEL_CODE),
              CURRENCY_CODE = decode( p_CURRENCY_CODE, FND_API.G_MISS_CHAR, CURRENCY_CODE, p_CURRENCY_CODE),
              TOTAL_AMOUNT = decode( p_TOTAL_AMOUNT, FND_API.G_MISS_NUM, TOTAL_AMOUNT, p_TOTAL_AMOUNT),
	      SECURITY_GROUP_ID = decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID),
              LOG_MODE = p_TRIGGER_MODE,
              CUSTOMER_ID = decode( p_CUSTOMER_ID, FND_API.G_MISS_NUM, NULL, p_CUSTOMER_ID),
              DESCRIPTION = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION),
              SOURCE_PROMOTION_ID = decode( p_SOURCE_PROMOTION_ID, FND_API.G_MISS_NUM, NULL, p_SOURCE_PROMOTION_ID),
              OFFER_ID = decode( p_OFFER_ID, FND_API.G_MISS_NUM, NULL, p_OFFER_ID),
              CLOSE_COMPETITOR_ID = decode( p_CLOSE_COMPETITOR_ID, FND_API.G_MISS_NUM, NULL, p_CLOSE_COMPETITOR_ID),
              VEHICLE_RESPONSE_CODE = decode( p_VEHICLE_RESPONSE_CODE, FND_API.G_MISS_CHAR, NULL, p_VEHICLE_RESPONSE_CODE),
              SALES_METHODOLOGY_ID = decode( p_SALES_METHODOLOGY_ID, FND_API.G_MISS_NUM, NULL, p_SALES_METHODOLOGY_ID),
              OWNER_SALESFORCE_ID = decode( p_OWNER_SALESFORCE_ID, FND_API.G_MISS_NUM, NULL, p_OWNER_SALESFORCE_ID),
              OWNER_SALES_GROUP_ID = decode( p_OWNER_SALES_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_OWNER_SALES_GROUP_ID),
              LOG_START_DATE = decode( p_LOG_START_DATE, FND_API.G_MISS_DATE, LOG_START_DATE, p_LOG_START_DATE),
              LOG_END_DATE = decode( p_LOG_END_DATE, FND_API.G_MISS_DATE, LOG_END_DATE, p_LOG_END_DATE),
              LOG_ACTIVE_DAYS = decode( p_LOG_ACTIVE_DAYS, FND_API.G_MISS_NUM, LOG_ACTIVE_DAYS, p_LOG_ACTIVE_DAYS),
              ENDDAY_LOG_FLAG = decode( p_ENDDAY_LOG_FLAG, FND_API.G_MISS_CHAR, ENDDAY_LOG_FLAG, p_ENDDAY_LOG_FLAG),
              CURRENT_LOG = decode( p_CURRENT_LOG, FND_API.G_MISS_NUM, CURRENT_LOG, p_CURRENT_LOG),
              ORG_ID = decode( p_ORG_ID, FND_API.G_MISS_NUM, NULL, p_ORG_ID)
    where     LOG_ID = (SELECT max(log_id)
                	  from AS_LEADS_LOG
            		  where lead_id = p_OLD_LEAD_ID);

    If (SQL%NOTFOUND) then
	--dbms_output.put_line('In AS_LEADS_LOG_PKG after Update statement : Data No found seems');
	 --dbms_output.put_line('Error Number:'||SQLCODE);
	 --dbms_output.put_line('Error Message:'|| SUBSTR(SQLERRM, 1, 200));
        RAISE NO_DATA_FOUND;

    End If;
END Update_Row;


PROCEDURE Delete_Row(
    p_LOG_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AS_LEADS_LOG
    WHERE LOG_ID = p_LOG_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

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
          p_TOTAL_AMOUNT    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AS_LEADS_LOG
        WHERE LOG_ID =  p_LOG_ID
        FOR UPDATE of LOG_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.LOG_ID = p_LOG_ID)
       AND (    ( Recinfo.LEAD_ID = p_LEAD_ID)
            OR (    ( Recinfo.LEAD_ID IS NULL )
                AND (  p_LEAD_ID IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.SALES_STAGE_ID = p_SALES_STAGE_ID)
            OR (    ( Recinfo.SALES_STAGE_ID IS NULL )
                AND (  p_SALES_STAGE_ID IS NULL )))
       AND (    ( Recinfo.WIN_PROBABILITY = p_WIN_PROBABILITY)
            OR (    ( Recinfo.WIN_PROBABILITY IS NULL )
                AND (  p_WIN_PROBABILITY IS NULL )))
       AND (    ( Recinfo.DECISION_DATE = p_DECISION_DATE)
            OR (    ( Recinfo.DECISION_DATE IS NULL )
                AND (  p_DECISION_DATE IS NULL )))
       AND (    ( Recinfo.ADDRESS_ID = p_ADDRESS_ID)
            OR (    ( Recinfo.ADDRESS_ID IS NULL )
                AND (  p_ADDRESS_ID IS NULL )))
       AND (    ( Recinfo.CHANNEL_CODE = p_CHANNEL_CODE)
            OR (    ( Recinfo.CHANNEL_CODE IS NULL )
                AND (  p_CHANNEL_CODE IS NULL )))
       AND (    ( Recinfo.CURRENCY_CODE = p_CURRENCY_CODE)
            OR (    ( Recinfo.CURRENCY_CODE IS NULL )
                AND (  p_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.TOTAL_AMOUNT = p_TOTAL_AMOUNT)
            OR (    ( Recinfo.TOTAL_AMOUNT IS NULL )
                AND (  p_TOTAL_AMOUNT IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End AS_LEADS_LOG_PKG;

/
