--------------------------------------------------------
--  DDL for Package HZ_BILLING_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BILLING_PREFERENCES_PKG" AUTHID CURRENT_USER as
/* $Header: ARHABFTS.pls 115.1 2002/11/21 19:13:05 sponnamb ship $: */


PROCEDURE Insert_Row(
                  x_Rowid             IN OUT NOCOPY      VARCHAR2,
                  x_BILLING_PREFERENCES_ID        NUMBER,
                  x_BILL_LANGUAGE                 VARCHAR2,
                  x_BILL_ROUND_NUMBER             VARCHAR2,
                  x_BILL_TYPE                     VARCHAR2,
                  x_MEDIA_FORMAT                  VARCHAR2,
                  x_SITE_USE_ID                   NUMBER,
                  x_MEDIA_TYPE                    VARCHAR2,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_NUMBER_OF_COPIES              NUMBER,
                  x_CURRENCY_CODE                 VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE);



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_BILLING_PREFERENCES_ID        NUMBER,
                  x_BILL_LANGUAGE                 VARCHAR2,
                  x_BILL_ROUND_NUMBER             VARCHAR2,
                  x_BILL_TYPE                     VARCHAR2,
                  x_MEDIA_FORMAT                  VARCHAR2,
                  x_SITE_USE_ID                   NUMBER,
                  x_MEDIA_TYPE                    VARCHAR2,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_NUMBER_OF_COPIES              NUMBER,
                  x_CURRENCY_CODE                 VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE);



PROCEDURE Update_Row(
                  x_Rowid              IN OUT NOCOPY     VARCHAR2,
                  x_BILLING_PREFERENCES_ID        NUMBER,
                  x_BILL_LANGUAGE                 VARCHAR2,
                  x_BILL_ROUND_NUMBER             VARCHAR2,
                  x_BILL_TYPE                     VARCHAR2,
                  x_MEDIA_FORMAT                  VARCHAR2,
                  x_SITE_USE_ID                   NUMBER,
                  x_MEDIA_TYPE                    VARCHAR2,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_NUMBER_OF_COPIES              NUMBER,
                  x_CURRENCY_CODE                 VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE);



PROCEDURE Delete_Row(                  x_BILLING_PREFERENCES_ID        NUMBER);

END HZ_BILLING_PREFERENCES_PKG;

 

/
