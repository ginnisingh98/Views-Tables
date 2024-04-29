--------------------------------------------------------
--  DDL for Package HZ_STOCK_MARKETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_STOCK_MARKETS_PKG" AUTHID CURRENT_USER as
/* $Header: ARHOSMTS.pls 115.1 2002/11/21 19:06:10 sponnamb ship $ */


PROCEDURE Insert_Row(
                  x_Rowid          IN OUT NOCOPY         VARCHAR2,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_COUNTRY_OF_RESIDENCE          VARCHAR2,
                  x_STOCK_EXCHANGE_CODE           VARCHAR2,
                  x_STOCK_EXCHANGE_NAME           VARCHAR2,
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
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_COUNTRY_OF_RESIDENCE          VARCHAR2,
                  x_STOCK_EXCHANGE_CODE           VARCHAR2,
                  x_STOCK_EXCHANGE_NAME           VARCHAR2,
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
                  x_Rowid           IN OUT NOCOPY        VARCHAR2,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_COUNTRY_OF_RESIDENCE          VARCHAR2,
                  x_STOCK_EXCHANGE_CODE           VARCHAR2,
                  x_STOCK_EXCHANGE_NAME           VARCHAR2,
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



PROCEDURE Delete_Row(                  x_STOCK_EXCHANGE_ID             NUMBER);

END HZ_STOCK_MARKETS_PKG;

 

/
