--------------------------------------------------------
--  DDL for Package HZ_INDUSTRIAL_CLASS_APP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_INDUSTRIAL_CLASS_APP_PKG" AUTHID CURRENT_USER as
/* $Header: ARHOCATS.pls 115.3 2002/11/21 19:01:49 sponnamb ship $ */


PROCEDURE Insert_Row(
                  x_Rowid        IN OUT NOCOPY           VARCHAR2,
                  x_CODE_APPLIED_ID               NUMBER,
                  x_BEGIN_DATE                    DATE,
                  x_PARTY_ID                      NUMBER,
                  x_END_DATE                      DATE,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
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
                  x_CONTENT_SOURCE_TYPE           VARCHAR2,
                  x_IMPORTANCE_RANKING            VARCHAR2);



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_CODE_APPLIED_ID               NUMBER,
                  x_BEGIN_DATE                    DATE,
                  x_PARTY_ID                      NUMBER,
                  x_END_DATE                      DATE,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
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
                  x_CONTENT_SOURCE_TYPE           VARCHAR2,
                  x_IMPORTANCE_RANKING            VARCHAR2);



PROCEDURE Update_Row(
                  x_Rowid        IN OUT NOCOPY           VARCHAR2,
                  x_CODE_APPLIED_ID               NUMBER,
                  x_BEGIN_DATE                    DATE,
                  x_PARTY_ID                      NUMBER,
                  x_END_DATE                      DATE,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
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
                  x_CONTENT_SOURCE_TYPE           VARCHAR2,
                  x_IMPORTANCE_RANKING            VARCHAR2);



PROCEDURE Delete_Row(                  x_CODE_APPLIED_ID               NUMBER);

END HZ_INDUSTRIAL_CLASS_APP_PKG;

 

/
