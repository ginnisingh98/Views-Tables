--------------------------------------------------------
--  DDL for Package AS_SALES_CREDITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_CREDITS_PKG" AUTHID CURRENT_USER as
/* $Header: asxtlscs.pls 120.0 2005/06/02 17:21:46 appldev noship $ */
-- Start of Comments
-- Package name     : AS_SALES_CREDITS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_SALES_CREDIT_ID   IN OUT NOCOPY NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_LEAD_ID    NUMBER,
          p_LEAD_LINE_ID    NUMBER,
          p_SALESFORCE_ID    NUMBER,
          p_PERSON_ID    NUMBER,
          p_SALESGROUP_ID    NUMBER,
          p_PARTNER_CUSTOMER_ID    NUMBER,
          p_PARTNER_ADDRESS_ID    NUMBER,
          p_REVENUE_AMOUNT    NUMBER,
          p_REVENUE_PERCENT    NUMBER,
          p_QUOTA_CREDIT_AMOUNT    NUMBER,
          p_QUOTA_CREDIT_PERCENT    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_MANAGER_REVIEW_FLAG    VARCHAR2,
          p_MANAGER_REVIEW_DATE    DATE,
          p_ORIGINAL_SALES_CREDIT_ID    NUMBER,
          -- p_CREDIT_TYPE    VARCHAR2,
          p_CREDIT_PERCENT    NUMBER,
          p_CREDIT_AMOUNT    NUMBER,
          --p_SECURITY_GROUP_ID    NUMBER,
          p_CREDIT_TYPE_ID    NUMBER,
          p_OPP_WORST_FORECAST_AMOUNT NUMBER DEFAULT NULL,
          p_OPP_FORECAST_AMOUNT NUMBER DEFAULT NULL,
          p_OPP_BEST_FORECAST_AMOUNT NUMBER DEFAULT NULL,
          P_DEFAULTED_FROM_OWNER_FLAG VARCHAR2 DEFAULT NULL); -- Added for ASNB

PROCEDURE Update_Row(
          p_SALES_CREDIT_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_LEAD_ID    NUMBER,
          p_LEAD_LINE_ID    NUMBER,
          p_SALESFORCE_ID    NUMBER,
          p_PERSON_ID    NUMBER,
          p_SALESGROUP_ID    NUMBER,
          p_PARTNER_CUSTOMER_ID    NUMBER,
          p_PARTNER_ADDRESS_ID    NUMBER,
          p_REVENUE_AMOUNT    NUMBER,
          p_REVENUE_PERCENT    NUMBER,
          p_QUOTA_CREDIT_AMOUNT    NUMBER,
          p_QUOTA_CREDIT_PERCENT    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_MANAGER_REVIEW_FLAG    VARCHAR2,
          p_MANAGER_REVIEW_DATE    DATE,
          p_ORIGINAL_SALES_CREDIT_ID    NUMBER,
          -- p_CREDIT_TYPE    VARCHAR2,
          p_CREDIT_PERCENT    NUMBER,
          p_CREDIT_AMOUNT    NUMBER,
          -- p_SECURITY_GROUP_ID    NUMBER,
          p_CREDIT_TYPE_ID    NUMBER,
          p_OPP_WORST_FORECAST_AMOUNT NUMBER DEFAULT NULL,
          p_OPP_FORECAST_AMOUNT NUMBER DEFAULT NULL,
          p_OPP_BEST_FORECAST_AMOUNT NUMBER DEFAULT NULL,
          P_DEFAULTED_FROM_OWNER_FLAG VARCHAR2 DEFAULT NULL); -- Added for ASNB

PROCEDURE Lock_Row(
          p_SALES_CREDIT_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_LEAD_ID    NUMBER,
          p_LEAD_LINE_ID    NUMBER,
          p_SALESFORCE_ID    NUMBER,
          p_PERSON_ID    NUMBER,
          p_SALESGROUP_ID    NUMBER,
          p_PARTNER_CUSTOMER_ID    NUMBER,
          p_PARTNER_ADDRESS_ID    NUMBER,
          p_REVENUE_AMOUNT    NUMBER,
          p_REVENUE_PERCENT    NUMBER,
          p_QUOTA_CREDIT_AMOUNT    NUMBER,
          p_QUOTA_CREDIT_PERCENT    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_MANAGER_REVIEW_FLAG    VARCHAR2,
          p_MANAGER_REVIEW_DATE    DATE,
          p_ORIGINAL_SALES_CREDIT_ID    NUMBER,
          -- p_CREDIT_TYPE    VARCHAR2,
          p_CREDIT_PERCENT    NUMBER,
          p_CREDIT_AMOUNT    NUMBER,
          -- p_SECURITY_GROUP_ID    NUMBER,
          p_CREDIT_TYPE_ID    NUMBER);

PROCEDURE Delete_Row(
    p_SALES_CREDIT_ID  NUMBER);
End AS_SALES_CREDITS_PKG;

 

/