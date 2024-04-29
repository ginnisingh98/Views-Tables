--------------------------------------------------------
--  DDL for Package IEX_REPOSSESSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_REPOSSESSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: iextrpss.pls 120.1 2007/10/30 20:26:49 ehuh ship $ */
-- Start of Comments
-- Package name     : IEX_REPOSSESSIONS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_REPOSSESSION_ID   IN OUT NOCOPY NUMBER
         ,p_DELINQUENCY_ID    NUMBER
         ,p_PARTY_ID    NUMBER
         ,p_CUST_ACCOUNT_ID    NUMBER
         ,p_UNPAID_REASON_CODE    VARCHAR2
         ,p_REMARKET_FLAG    VARCHAR2
         ,p_REPOSSESSION_DATE    DATE
         ,p_ASSET_ID    NUMBER
         ,p_ASSET_VALUE    NUMBER
         ,p_ASSET_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CREDIT_HOLD_REQUEST_FLAG    VARCHAR2
         ,p_CREDIT_HOLD_APPROVED_FLAG   VARCHAR2
         ,p_SERVICE_HOLD_REQUEST_FLAG   VARCHAR2
         ,p_SERVICE_HOLD_APPROVED_FLAG  VARCHAR2
         ,p_SUGGESTION_APPROVED_FLAG    VARCHAR2
         ,p_DISPOSITION_CODE            VARCHAR2
         ,p_CUSTOMER_SITE_USE_ID        NUMBER
         ,p_ORG_ID                      NUMBER
         ,p_CONTRACT_ID                 NUMBER
         ,p_CONTRACT_NUMBER             VARCHAR2
         );

PROCEDURE Update_Row(
          p_REPOSSESSION_ID    NUMBER
         ,p_DELINQUENCY_ID    NUMBER
         ,p_PARTY_ID    NUMBER
         ,p_CUST_ACCOUNT_ID    NUMBER
         ,p_UNPAID_REASON_CODE    VARCHAR2
         ,p_REMARKET_FLAG    VARCHAR2
         ,p_REPOSSESSION_DATE    DATE
         ,p_ASSET_ID    NUMBER
         ,p_ASSET_VALUE    NUMBER
         ,p_ASSET_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CREDIT_HOLD_REQUEST_FLAG    VARCHAR2
         ,p_CREDIT_HOLD_APPROVED_FLAG    VARCHAR2
         ,p_SERVICE_HOLD_REQUEST_FLAG    VARCHAR2
         ,p_SERVICE_HOLD_APPROVED_FLAG    VARCHAR2
         ,p_SUGGESTION_APPROVED_FLAG    VARCHAR2
         ,p_DISPOSITION_CODE            VARCHAR2
         ,p_CUSTOMER_SITE_USE_ID        NUMBER
         ,p_ORG_ID                      NUMBER
         ,p_CONTRACT_ID                 NUMBER
         ,p_CONTRACT_NUMBER             VARCHAR2
         );

PROCEDURE Lock_Row(
          p_REPOSSESSION_ID    NUMBER
         ,p_DELINQUENCY_ID    NUMBER
         ,p_PARTY_ID    NUMBER
         ,p_CUST_ACCOUNT_ID    NUMBER
         ,p_UNPAID_REASON_CODE    VARCHAR2
         ,p_REMARKET_FLAG    VARCHAR2
         ,p_REPOSSESSION_DATE    DATE
         ,p_ASSET_ID    NUMBER
         ,p_ASSET_VALUE    NUMBER
         ,p_ASSET_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CREDIT_HOLD_REQUEST_FLAG    VARCHAR2
         ,p_CREDIT_HOLD_APPROVED_FLAG    VARCHAR2
         ,p_SERVICE_HOLD_REQUEST_FLAG    VARCHAR2
         ,p_SERVICE_HOLD_APPROVED_FLAG    VARCHAR2
         ,p_SUGGESTION_APPROVED_FLAG    VARCHAR2
         ,p_DISPOSITION_CODE            VARCHAR2
         ,p_CUSTOMER_SITE_USE_ID        NUMBER
         ,p_ORG_ID                      NUMBER
         ,p_CONTRACT_ID                 NUMBER
         ,p_CONTRACT_NUMBER             VARCHAR2
         );

PROCEDURE Delete_Row(
    p_REPOSSESSION_ID  NUMBER);
End IEX_REPOSSESSIONS_PKG;

/
