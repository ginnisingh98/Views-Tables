--------------------------------------------------------
--  DDL for Package HZ_INDUSTRIAL_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_INDUSTRIAL_CLASSES_PKG" AUTHID CURRENT_USER as
/* $Header: ARHOICTS.pls 115.1 2002/11/21 19:03:36 sponnamb ship $ */


PROCEDURE Insert_Row(
                  x_Rowid          IN OUT NOCOPY         VARCHAR2,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
                  x_INDUSTRIAL_CODE_NAME          VARCHAR2,
                  x_CODE_PRIMARY_SEGMENT          VARCHAR2,
                  x_INDUSTRIAL_CLASS_SOURCE       VARCHAR2,
                  x_CODE_DESCRIPTION              VARCHAR2,
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
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
                  x_INDUSTRIAL_CODE_NAME          VARCHAR2,
                  x_CODE_PRIMARY_SEGMENT          VARCHAR2,
                  x_INDUSTRIAL_CLASS_SOURCE       VARCHAR2,
                  x_CODE_DESCRIPTION              VARCHAR2,
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
                  x_Rowid       IN OUT NOCOPY            VARCHAR2,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
                  x_INDUSTRIAL_CODE_NAME          VARCHAR2,
                  x_CODE_PRIMARY_SEGMENT          VARCHAR2,
                  x_INDUSTRIAL_CLASS_SOURCE       VARCHAR2,
                  x_CODE_DESCRIPTION              VARCHAR2,
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



PROCEDURE Delete_Row(                  x_INDUSTRIAL_CLASS_ID           NUMBER);

END HZ_INDUSTRIAL_CLASSES_PKG;

 

/
