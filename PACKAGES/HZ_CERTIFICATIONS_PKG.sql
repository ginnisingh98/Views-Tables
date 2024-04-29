--------------------------------------------------------
--  DDL for Package HZ_CERTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CERTIFICATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: ARHOCETS.pls 115.2 2002/11/21 19:16:34 sponnamb ship $ */


PROCEDURE Insert_Row(
                  x_Rowid        IN OUT NOCOPY           VARCHAR2,
                  x_CERTIFICATION_ID              NUMBER,
                  x_CERTIFICATION_NAME            VARCHAR2,
                  x_CURRENT_STATUS                VARCHAR2,
                  x_PARTY_ID                      NUMBER,
                  x_EXPIRES_ON_DATE               DATE,
                  x_GRADE                         VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_ISSUED_ON_DATE                DATE,
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



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_CERTIFICATION_ID              NUMBER,
                  x_CERTIFICATION_NAME            VARCHAR2,
                  x_CURRENT_STATUS                VARCHAR2,
                  x_PARTY_ID                      NUMBER,
                  x_EXPIRES_ON_DATE               DATE,
                  x_GRADE                         VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_ISSUED_ON_DATE                DATE,
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



PROCEDURE Update_Row(
                  x_Rowid       IN OUT NOCOPY            VARCHAR2,
                  x_CERTIFICATION_ID              NUMBER,
                  x_CERTIFICATION_NAME            VARCHAR2,
                  x_CURRENT_STATUS                VARCHAR2,
                  x_PARTY_ID                      NUMBER,
                  x_EXPIRES_ON_DATE               DATE,
                  x_GRADE                         VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_ISSUED_ON_DATE                DATE,
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



PROCEDURE Delete_Row(                  x_CERTIFICATION_ID              NUMBER);

END HZ_CERTIFICATIONS_PKG;

 

/
