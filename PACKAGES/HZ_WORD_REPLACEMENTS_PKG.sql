--------------------------------------------------------
--  DDL for Package HZ_WORD_REPLACEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORD_REPLACEMENTS_PKG" AUTHID CURRENT_USER as
/*$Header: ARHWRSTS.pls 120.2 2005/06/16 21:16:42 jhuang ship $ */


PROCEDURE Insert_Row(
                  x_Rowid               IN OUT NOCOPY    VARCHAR2,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2);


PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2);


PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2);


PROCEDURE Delete_Row(
                  x_TYPE                          VARCHAR2,
                  x_ORIGINAL_WORD                 VARCHAR2);

END HZ_WORD_REPLACEMENTS_PKG;

 

/
