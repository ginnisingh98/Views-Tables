--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: asxtslls.pls 115.5 2003/09/18 22:22:47 ckapoor ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_LINES_PKG
-- Purpose          : Sales lead lines table handlers
-- NOTE             :
-- History          : 04/09/2001 FFANG   Created
--
-- End of Comments



PROCEDURE Sales_Lead_Line_Insert_Row(
          px_SALES_LEAD_LINE_ID  IN OUT NOCOPY   NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALES_LEAD_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,

          -- 11.5.10 Rivendell product category changes

          --p_INTEREST_TYPE_ID    NUMBER,
          --p_PRIMARY_INTEREST_CODE_ID    NUMBER,
          --p_SECONDARY_INTEREST_CODE_ID    NUMBER,

          p_CATEGORY_ID	NUMBER,
          p_CATEGORY_SET_ID  NUMBER,

          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_QUANTITY    NUMBER,
          p_BUDGET_AMOUNT    NUMBER,
          p_SOURCE_PROMOTION_ID    NUMBER,
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
          p_OFFER_ID    NUMBER);
--        p_SECURITY_GROUP_ID              NUMBER);


PROCEDURE Sales_Lead_Line_Update_Row(
          p_SALES_LEAD_LINE_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALES_LEAD_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,

          -- 11.5.10 rivendell product category changes

          --p_INTEREST_TYPE_ID    NUMBER,
          --p_PRIMARY_INTEREST_CODE_ID    NUMBER,
          --p_SECONDARY_INTEREST_CODE_ID    NUMBER,

          p_CATEGORY_ID NUMBER,
          p_CATEGORY_SET_ID  NUMBER,


          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_QUANTITY    NUMBER,
          p_BUDGET_AMOUNT    NUMBER,
          p_SOURCE_PROMOTION_ID    NUMBER,
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
          p_OFFER_ID    NUMBER);
--        p_SECURITY_GROUP_ID              NUMBER);


PROCEDURE Sales_Lead_Line_Delete_Row( p_sales_lead_line_id  NUMBER);


PROCEDURE Sales_Lead_Line_Lock_Row(
          p_SALES_LEAD_LINE_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALES_LEAD_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,

          -- 11.5.10 rivendell product category changes

          --p_INTEREST_TYPE_ID    NUMBER,
          --p_PRIMARY_INTEREST_CODE_ID    NUMBER,
          --p_SECONDARY_INTEREST_CODE_ID    NUMBER,

          p_CATEGORY_ID  NUMBER,
          p_CATEGORY_SET_ID  NUMBER,

          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_QUANTITY    NUMBER,
          p_BUDGET_AMOUNT    NUMBER,
          p_SOURCE_PROMOTION_ID    NUMBER,
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
          p_OFFER_ID    NUMBER);
--        p_SECURITY_GROUP_ID  NUMBER);



End AS_SALES_LEAD_LINES_PKG;

 

/
