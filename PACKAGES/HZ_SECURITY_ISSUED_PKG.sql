--------------------------------------------------------
--  DDL for Package HZ_SECURITY_ISSUED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_SECURITY_ISSUED_PKG" AUTHID CURRENT_USER as
/* $Header: ARHOSITS.pls 115.2 2002/11/21 19:19:46 sponnamb ship $ */


PROCEDURE Insert_Row(
                  x_Rowid           IN OUT NOCOPY        VARCHAR2,
                  x_SECURITY_ISSUED_ID            NUMBER,
                  x_ESTIMATED_TOTAL_AMOUNT        NUMBER,
                  x_PARTY_ID                      NUMBER,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_SECURITY_ISSUED_CLASS         VARCHAR2,
                  x_SECURITY_ISSUED_NAME          VARCHAR2,
                  x_TOTAL_AMOUNT_IN_A_CURRENCY    VARCHAR2,
                  x_STOCK_TICKER_SYMBOL           VARCHAR2,
                  x_SECURITY_CURRENCY_CODE        VARCHAR2,
                  x_BEGIN_DATE                    DATE,
                  x_END_DATE                      DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
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
                  x_SECURITY_ISSUED_ID            NUMBER,
                  x_ESTIMATED_TOTAL_AMOUNT        NUMBER,
                  x_PARTY_ID                      NUMBER,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_SECURITY_ISSUED_CLASS         VARCHAR2,
                  x_SECURITY_ISSUED_NAME          VARCHAR2,
                  x_TOTAL_AMOUNT_IN_A_CURRENCY    VARCHAR2,
                  x_STOCK_TICKER_SYMBOL           VARCHAR2,
                  x_SECURITY_CURRENCY_CODE        VARCHAR2,
                  x_BEGIN_DATE                    DATE,
                  x_END_DATE                      DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                x_STATUS                       VARCHAR2);



PROCEDURE Update_Row(
                  x_Rowid         IN OUT NOCOPY          VARCHAR2,
                  x_SECURITY_ISSUED_ID            NUMBER,
                  x_ESTIMATED_TOTAL_AMOUNT        NUMBER,
                  x_PARTY_ID                      NUMBER,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_SECURITY_ISSUED_CLASS         VARCHAR2,
                  x_SECURITY_ISSUED_NAME          VARCHAR2,
                  x_TOTAL_AMOUNT_IN_A_CURRENCY    VARCHAR2,
                  x_STOCK_TICKER_SYMBOL           VARCHAR2,
                  x_SECURITY_CURRENCY_CODE        VARCHAR2,
                  x_BEGIN_DATE                    DATE,
                  x_END_DATE                      DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_STATUS                        VARCHAR2);



PROCEDURE Delete_Row(                  x_SECURITY_ISSUED_ID            NUMBER);

END HZ_SECURITY_ISSUED_PKG;

 

/
