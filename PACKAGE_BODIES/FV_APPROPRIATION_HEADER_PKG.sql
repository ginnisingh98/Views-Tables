--------------------------------------------------------
--  DDL for Package Body FV_APPROPRIATION_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_APPROPRIATION_HEADER_PKG" as
/* $Header: FVBEAPRB.pls 120.5 2002/11/25 16:06:57 akonatha ship $ */

PROCEDURE Insert_Row(   X_ROWID 	                    IN OUT NOCOPY VARCHAR2,
		        X_APPROPRIATION_ID                         NUMBER,
			X_SET_OF_BOOKS_ID                          NUMBER,
			X_BU_USER_ID                               NUMBER,
			X_BU_GROUP_ID                              NUMBER,
			X_LAST_UPDATE_DATE                         DATE,
			X_LAST_UPDATED_BY                          NUMBER,
			X_CREATION_DATE                            DATE,
			X_CREATED_BY                               NUMBER,
			X_LAST_UPDATE_LOGIN                        NUMBER,
			X_TOT_APPROPRIATION_AMOUNT                 NUMBER,
			X_TOT_WARRANT_AMOUNT                       NUMBER,
			X_TOT_RESCISSION_AMOUNT                    NUMBER,
			X_TOT_DEFERRAL_AMOUNT                      NUMBER,
			X_DOCUMENT_NO                              VARCHAR2,
			X_REVISION_NO                              NUMBER,
			X_ATTRIBUTE1                               VARCHAR2,
			X_ATTRIBUTE2                               VARCHAR2,
			X_ATTRIBUTE3                               VARCHAR2,
			X_ATTRIBUTE4                               VARCHAR2,
			X_ATTRIBUTE5                               VARCHAR2,
			X_ATTRIBUTE6                               VARCHAR2,
			X_ATTRIBUTE7                               VARCHAR2,
			X_ATTRIBUTE8                               VARCHAR2,
			X_ATTRIBUTE9                               VARCHAR2,
			X_ATTRIBUTE10                              VARCHAR2,
			X_ATTRIBUTE11                              VARCHAR2,
			X_ATTRIBUTE12                              VARCHAR2,
			X_ATTRIBUTE13                              VARCHAR2,
			X_ATTRIBUTE14                              VARCHAR2,
			X_ATTRIBUTE15                              VARCHAR2,
			X_ATTRIBUTE_CATEGORY                       VARCHAR2,
			--X_ORG_ID                                   NUMBER,
			X_TREASURY_SYMBOL_ID                       NUMBER
		    ) IS
BEGIN
    NULL;
END Insert_Row;

PROCEDURE Update_Row(   X_ROWID 	                           VARCHAR2,
		        X_APPROPRIATION_ID                         NUMBER,
			X_SET_OF_BOOKS_ID                          NUMBER,
			X_BU_USER_ID                               NUMBER,
			X_BU_GROUP_ID                              NUMBER,
			X_LAST_UPDATE_DATE                         DATE,
			X_LAST_UPDATED_BY                          NUMBER,
			X_CREATION_DATE                            DATE,
			X_CREATED_BY                               NUMBER,
			X_LAST_UPDATE_LOGIN                        NUMBER,
			X_TOT_APPROPRIATION_AMOUNT                 NUMBER,
			X_TOT_WARRANT_AMOUNT                       NUMBER,
			X_TOT_RESCISSION_AMOUNT                    NUMBER,
			X_TOT_DEFERRAL_AMOUNT                      NUMBER,
			X_DOCUMENT_NO                              VARCHAR2,
			X_REVISION_NO                              NUMBER,
			X_ATTRIBUTE1                               VARCHAR2,
			X_ATTRIBUTE2                               VARCHAR2,
			X_ATTRIBUTE3                               VARCHAR2,
			X_ATTRIBUTE4                               VARCHAR2,
			X_ATTRIBUTE5                               VARCHAR2,
			X_ATTRIBUTE6                               VARCHAR2,
			X_ATTRIBUTE7                               VARCHAR2,
			X_ATTRIBUTE8                               VARCHAR2,
			X_ATTRIBUTE9                               VARCHAR2,
			X_ATTRIBUTE10                              VARCHAR2,
			X_ATTRIBUTE11                              VARCHAR2,
			X_ATTRIBUTE12                              VARCHAR2,
			X_ATTRIBUTE13                              VARCHAR2,
			X_ATTRIBUTE14                              VARCHAR2,
			X_ATTRIBUTE15                              VARCHAR2,
			X_ATTRIBUTE_CATEGORY                       VARCHAR2,
			--X_ORG_ID                                   NUMBER,
			X_TREASURY_SYMBOL_ID                       NUMBER
		    ) IS
BEGIN
  NULL;
 END Update_Row;


PROCEDURE Lock_Row(     X_ROWID                            VARCHAR2,
              		X_APPROPRIATION_ID                 NUMBER,
			X_SET_OF_BOOKS_ID                  NUMBER,
			X_BU_USER_ID                       NUMBER,
			X_BU_GROUP_ID                      NUMBER,
 			X_ATTRIBUTE_CATEGORY               VARCHAR2,
 			--X_ORG_ID                           NUMBER,
 			X_TREASURY_SYMBOL_ID               NUMBER,
 			X_DOCUMENT_NO                      VARCHAR2,
 			X_REVISION_NO                      NUMBER
		  ) IS

 BEGIN
    NULL;
 END Lock_Row;



PROCEDURE Delete_Row(X_ROWID VARCHAR2) IS

BEGIN
  NULL;
END DELETE_ROW;

END FV_APPROPRIATION_HEADER_PKG;

/
