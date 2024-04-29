--------------------------------------------------------
--  DDL for Package HZ_WORD_REPLACEMENTS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORD_REPLACEMENTS1_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQWRS.pls 120.6 2006/01/16 05:12:17 rchanamo noship $ */

PROCEDURE Insert_Row(
                  x_Rowid               IN OUT NOCOPY    VARCHAR2,
                  x_word_list_id           NUMBER,
                  x_ORIGINAL_WORD          VARCHAR2,
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
                  x_ATTRIBUTE15                   VARCHAR2,
                  x_object_version_number         in out NOCOPY NUMBER,
		  x_condition_id                  NUMBER DEFAULT NULL,
		  x_user_spec_cond_value          VARCHAR2 DEFAULT NULL);

PROCEDURE Insert_Row(
                  x_Rowid               IN OUT NOCOPY    VARCHAR2,
                  x_word_list_id           NUMBER,
                  x_ORIGINAL_WORD          VARCHAR2,
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
                  x_ATTRIBUTE15                   VARCHAR2,
                  x_object_version_number         in out NOCOPY NUMBER,
                  x_msg_count                     in out NOCOPY NUMBER,
		  x_condition_id                  NUMBER DEFAULT NULL,
		  x_user_spec_cond_value         VARCHAR2 DEFAULT NULL);


PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_word_list_id                  NUMBER,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_object_version_number         NUMBER);

PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_word_list_id                  NUMBER,
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
                  x_ATTRIBUTE15                   VARCHAR2,
                  x_object_version_number IN OUT NOCOPY  NUMBER,
		  x_condition_id                  NUMBER DEFAULT NULL,
		  x_user_spec_cond_value          VARCHAR2 DEFAULT NULL);

PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_word_list_id                  NUMBER,
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
                  x_ATTRIBUTE15                   VARCHAR2,
                  x_object_version_number IN OUT NOCOPY  NUMBER,
                  x_msg_count                     in out NOCOPY NUMBER,
		  x_condition_id                  NUMBER DEFAULT NULL,
		  x_user_spec_cond_value         VARCHAR2 DEFAULT NULL);


PROCEDURE Delete_Row(x_word_list_id in number , x_original_word in varchar2,x_condition_id IN NUMBER,x_user_spec_cond_value IN  VARCHAR2);

PROCEDURE Delete_Row(X_WORD_LIST_ID IN  NUMBER);

END HZ_WORD_REPLACEMENTS1_PKG;

 

/
