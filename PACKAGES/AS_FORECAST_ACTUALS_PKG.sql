--------------------------------------------------------
--  DDL for Package AS_FORECAST_ACTUALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_FORECAST_ACTUALS_PKG" AUTHID CURRENT_USER as
/* $Header: asxtfacs.pls 115.3 2002/11/06 00:52:52 appldev ship $ */
-- Start of Comments
-- Package name     : AS_FORECAST_ACTUALS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_FORECAST_ACTUAL_ID   IN OUT NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALESFORCE_ID    NUMBER,
          p_SALES_GROUP_ID    NUMBER,
          p_PERIOD_NAME    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT    NUMBER,
          p_ACTUAL_REVENUE_AMOUNT    NUMBER);

PROCEDURE Update_Row(
          p_FORECAST_ACTUAL_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALESFORCE_ID    NUMBER,
          p_SALES_GROUP_ID    NUMBER,
          p_PERIOD_NAME    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT    NUMBER,
          p_ACTUAL_REVENUE_AMOUNT    NUMBER);

PROCEDURE Lock_Row(
          p_FORECAST_ACTUAL_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALESFORCE_ID    NUMBER,
          p_SALES_GROUP_ID    NUMBER,
          p_PERIOD_NAME    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT    NUMBER,
          p_ACTUAL_REVENUE_AMOUNT    NUMBER);

PROCEDURE Delete_Row(
    p_FORECAST_ACTUAL_ID  NUMBER);
End AS_FORECAST_ACTUALS_PKG;

 

/
