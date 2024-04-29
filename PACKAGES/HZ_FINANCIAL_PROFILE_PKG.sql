--------------------------------------------------------
--  DDL for Package HZ_FINANCIAL_PROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_FINANCIAL_PROFILE_PKG" AUTHID CURRENT_USER as
/* $Header: ARHPFPTS.pls 115.2 2002/11/21 19:31:21 sponnamb ship $ */


PROCEDURE Insert_Row(
                  x_Rowid              IN OUT NOCOPY     VARCHAR2,
                  x_FINANCIAL_PROFILE_ID          NUMBER,
                  x_ACCESS_AUTHORITY_DATE         DATE,
                  x_ACCESS_AUTHORITY_GRANTED      VARCHAR2,
                  x_BALANCE_AMOUNT                NUMBER,
                  x_BALANCE_VERIFIED_ON_DATE      DATE,
                  x_FINANCIAL_ACCOUNT_NUMBER      VARCHAR2,
                  x_FINANCIAL_ACCOUNT_TYPE        VARCHAR2,
                  x_FINANCIAL_ORG_TYPE            VARCHAR2,
                  x_FINANCIAL_ORGANIZATION_NAME   VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_PARTY_ID                      NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                    x_STATUS                      VARCHAR2);



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_FINANCIAL_PROFILE_ID          NUMBER,
                  x_ACCESS_AUTHORITY_DATE         DATE,
                  x_ACCESS_AUTHORITY_GRANTED      VARCHAR2,
                  x_BALANCE_AMOUNT                NUMBER,
                  x_BALANCE_VERIFIED_ON_DATE      DATE,
                  x_FINANCIAL_ACCOUNT_NUMBER      VARCHAR2,
                  x_FINANCIAL_ACCOUNT_TYPE        VARCHAR2,
                  x_FINANCIAL_ORG_TYPE            VARCHAR2,
                  x_FINANCIAL_ORGANIZATION_NAME   VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_PARTY_ID                      NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_STATUS                        VARCHAR2);



PROCEDURE Update_Row(
                  x_Rowid               IN OUT NOCOPY    VARCHAR2,
                  x_FINANCIAL_PROFILE_ID          NUMBER,
                  x_ACCESS_AUTHORITY_DATE         DATE,
                  x_ACCESS_AUTHORITY_GRANTED      VARCHAR2,
                  x_BALANCE_AMOUNT                NUMBER,
                  x_BALANCE_VERIFIED_ON_DATE      DATE,
                  x_FINANCIAL_ACCOUNT_NUMBER      VARCHAR2,
                  x_FINANCIAL_ACCOUNT_TYPE        VARCHAR2,
                  x_FINANCIAL_ORG_TYPE            VARCHAR2,
                  x_FINANCIAL_ORGANIZATION_NAME   VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_PARTY_ID                      NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_STATUS                       VARCHAR2);



PROCEDURE Delete_Row(                  x_FINANCIAL_PROFILE_ID          NUMBER);

END HZ_FINANCIAL_PROFILE_PKG;

 

/
