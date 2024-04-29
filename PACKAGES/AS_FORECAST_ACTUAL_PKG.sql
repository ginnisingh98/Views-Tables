--------------------------------------------------------
--  DDL for Package AS_FORECAST_ACTUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_FORECAST_ACTUAL_PKG" AUTHID CURRENT_USER as
/* $Header: asxtfas.pls 115.16 2003/01/13 22:10:56 geliu ship $ */
PROCEDURE Insert_Row(
          p_SALESFORCE_ID in  NUMBER,
          p_SALES_GROUP_ID in NUMBER,
          p_PERIOD_NAME  in  VARCHAR2,
          p_CURRENCY_CODE in VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT in NUMBER,
          p_ACTUAL_REVENUE_AMOUNT in  NUMBER,
          p_CREATED_BY in NUMBER,
          p_CREATION_DATE in  DATE,
          p_LAST_UPDATED_BY in NUMBER,
          p_LAST_UPDATE_DATE  in DATE,
          p_LAST_UPDATE_LOGIN in NUMBER,
          p_REQUEST_ID in   NUMBER,
          p_PROGRAM_APPLICATION_ID in NUMBER,
          p_PROGRAM_ID in  NUMBER,
          p_PROGRAM_UPDATE_DATE in  DATE,
          p_SECURITY_GROUP_ID in NUMBER,
          p_forecast_category_id    IN NUMBER,
          p_credit_type_id          IN NUMBER
          );

PROCEDURE Update_Row(
          p_FORECAST_ACTUAL_ID in   NUMBER,
          p_CURRENCY_CODE in VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT in NUMBER,
          p_ACTUAL_REVENUE_AMOUNT in  NUMBER,
          p_LAST_UPDATED_BY in NUMBER,
          p_LAST_UPDATE_DATE  in DATE,
          p_LAST_UPDATE_LOGIN in NUMBER,
          p_REQUEST_ID in   NUMBER,
          p_PROGRAM_APPLICATION_ID in NUMBER,
          p_PROGRAM_ID in  NUMBER,
          p_PROGRAM_UPDATE_DATE in  DATE,
          p_SECURITY_GROUP_ID in NUMBER
          );

PROCEDURE Lock_Row(
          p_FORECAST_ACTUAL_ID in   NUMBER,
          p_SALESFORCE_ID in  NUMBER,
          p_SALES_GROUP_ID in NUMBER,
          p_PERIOD_NAME  in  VARCHAR2,
          p_CURRENCY_CODE in VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT in NUMBER,
          p_ACTUAL_REVENUE_AMOUNT in  NUMBER,
          p_CREATED_BY in NUMBER,
          p_CREATION_DATE in  DATE,
          p_LAST_UPDATED_BY in NUMBER,
          p_LAST_UPDATE_DATE  in DATE,
          p_LAST_UPDATE_LOGIN in NUMBER,
          p_REQUEST_ID in   NUMBER,
          p_PROGRAM_APPLICATION_ID in NUMBER,
          p_PROGRAM_ID in  NUMBER,
          p_PROGRAM_UPDATE_DATE in  DATE,
          p_SECURITY_GROUP_ID in NUMBER);

PROCEDURE Delete_Row(
    p_FORECAST_ACTUAL_ID in  NUMBER);

PROCEDURE Upload_Data(
          p_period_set_name         IN VARCHAR2,
          p_line_number             IN NUMBER,
          p_SALESFORCE_NUMBER       IN NUMBER,
          p_SALES_GROUP_NUMBER      IN NUMBER,
          p_PERIOD_NAME             IN VARCHAR2,
          p_CURRENCY_CODE           IN VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT IN NUMBER,
          p_ACTUAL_REVENUE_AMOUNT   IN NUMBER,
          p_CREATED_BY              IN NUMBER,
          p_CREATION_DATE           IN DATE,
          p_LAST_UPDATED_BY         IN NUMBER,
          p_LAST_UPDATE_DATE        IN DATE,
          p_LAST_UPDATE_LOGIN       IN NUMBER,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID  IN NUMBER,
          p_PROGRAM_ID              IN NUMBER,
          p_PROGRAM_UPDATE_DATE     IN DATE,
          p_SECURITY_GROUP_ID       IN NUMBER,
          p_filehandle              IN UTL_FILE.FILE_TYPE,
          p_forecast_category_name  IN VARCHAR2,
          p_credit_type_name        IN VARCHAR2
          );

FUNCTION Get_LogDir(p_data_file IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_LogFileName(p_data_file IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE Chk_Valid_PeriodName (
       p_period_name IN VARCHAR2
     , p_period_set_name IN VARCHAR2
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , x_period_flag OUT NOCOPY BOOLEAN
     , x_start_date  OUT NOCOPY DATE
     , x_end_date    OUT NOCOPY DATE );

PROCEDURE Chk_Valid_Currency (
       p_currency_code IN VARCHAR2
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , x_currency_flag OUT NOCOPY BOOLEAN );

PROCEDURE Get_CreditTypeId (
       p_name IN VARCHAR2
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , x_credit_type_id   OUT NOCOPY NUMBER ) ;

PROCEDURE Get_ForecastCategoryId (
       p_name IN VARCHAR2
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , p_start_date IN DATE
     , p_end_date   IN DATE
     , x_forecast_category_id   OUT NOCOPY NUMBER );

PROCEDURE Get_SalesGroupId (
       p_sales_group_number IN NUMBER
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , p_start_date IN DATE
     , p_end_date   IN DATE
     , x_sales_group_id    OUT NOCOPY NUMBER );

PROCEDURE Get_SalesForceId (
       p_salesforce_number IN NUMBER
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , p_start_date IN DATE
     , p_end_date   IN DATE
     , p_sales_group_id   IN NUMBER
     , x_salesforce_id    OUT NOCOPY NUMBER );

Procedure Read_Lob(  p_file_id                 IN NUMBER
                         , p_CREATED_BY              IN NUMBER
                         , p_LAST_UPDATED_BY         IN NUMBER
                         , p_LAST_UPDATE_LOGIN       IN NUMBER
                         , p_PROGRAM_APPLICATION_ID  IN NUMBER);

PROCEDURE Delete_lob(p_file_id IN NUMBER
         , p_filehandle IN UTL_FILE.FILE_TYPE) ;

PROCEDURE Create_Loglob( p_log_string IN VARCHAR2
                        ,p_file_id    IN NUMBER
                        ,p_op_type    IN VARCHAR2
                        ,p_exists      IN BOOLEAN);

End AS_FORECAST_ACTUAL_PKG;

 

/
