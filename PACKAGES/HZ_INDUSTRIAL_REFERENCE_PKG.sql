--------------------------------------------------------
--  DDL for Package HZ_INDUSTRIAL_REFERENCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_INDUSTRIAL_REFERENCE_PKG" AUTHID CURRENT_USER as
/* $Header: ARHORITS.pls 115.2 2002/11/21 19:21:38 sponnamb ship $ */


PROCEDURE Insert_Row(
                  x_Rowid           IN  OUT NOCOPY       VARCHAR2,
                  x_INDUSTRY_REFERENCE_ID         NUMBER,
                  x_INDUSTRY_REFERENCE            VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_NAME_OF_REFERENCE             VARCHAR2,
                  x_RECOGNIZED_AS_OF_DATE         DATE,
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
                x_PARTY_ID                      NUMBER,
                  x_STATUS                        VARCHAR2);



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_INDUSTRY_REFERENCE_ID         NUMBER,
                  x_INDUSTRY_REFERENCE            VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_NAME_OF_REFERENCE             VARCHAR2,
                  x_RECOGNIZED_AS_OF_DATE         DATE,
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
                  x_PARTY_ID                      NUMBER,
                  x_STATUS                        VARCHAR2);



PROCEDURE Update_Row(
                  x_Rowid          IN  OUT NOCOPY        VARCHAR2,
                  x_INDUSTRY_REFERENCE_ID         NUMBER,
                  x_INDUSTRY_REFERENCE            VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_NAME_OF_REFERENCE             VARCHAR2,
                  x_RECOGNIZED_AS_OF_DATE         DATE,
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
                 x_PARTY_ID                      NUMBER,
                  x_STATUS                        VARCHAR2);



PROCEDURE Delete_Row(                  x_INDUSTRY_REFERENCE_ID         NUMBER);

END HZ_INDUSTRIAL_REFERENCE_PKG;

 

/
