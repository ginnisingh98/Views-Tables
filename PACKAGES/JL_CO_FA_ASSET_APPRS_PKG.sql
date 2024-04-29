--------------------------------------------------------
--  DDL for Package JL_CO_FA_ASSET_APPRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_FA_ASSET_APPRS_PKG" AUTHID CURRENT_USER as
/* $Header: jlcoftas.pls 115.2 2002/11/21 02:01:08 vsidhart ship $ */

  PROCEDURE Insert_Row(
			  X_rowid                   IN OUT NOCOPY VARCHAR2,
                          X_appraisal_id                    NUMBER,
                          X_asset_number                    VARCHAR2,
                          X_appraisal_value                 NUMBER,
                          X_status                          VARCHAR2,
                          X_LAST_UPDATE_DATE                DATE,
                          X_LAST_UPDATED_BY                 NUMBER,
                          X_CREATION_DATE                   DATE,
                          X_CREATED_BY                      NUMBER,
                          X_LAST_UPDATE_LOGIN               NUMBER,
                          X_ATTRIBUTE_CATEGORY              VARCHAR2,
                          X_ATTRIBUTE1                      VARCHAR2,
                          X_ATTRIBUTE2                      VARCHAR2,
                          X_ATTRIBUTE3                      VARCHAR2,
                          X_ATTRIBUTE4                      VARCHAR2,
                          X_ATTRIBUTE5                      VARCHAR2,
                          X_ATTRIBUTE6                      VARCHAR2,
                          X_ATTRIBUTE7                      VARCHAR2,
                          X_ATTRIBUTE8                      VARCHAR2,
                          X_ATTRIBUTE9                      VARCHAR2,
                          X_ATTRIBUTE10                     VARCHAR2,
                          X_ATTRIBUTE11                     VARCHAR2,
                          X_ATTRIBUTE12                     VARCHAR2,
                          X_ATTRIBUTE13                     VARCHAR2,
                          X_ATTRIBUTE14                     VARCHAR2,
                          X_ATTRIBUTE15                     VARCHAR2,
                          X_calling_sequence        IN  VARCHAR2
  );

  PROCEDURE Lock_Row(
			  X_rowid                   VARCHAR2,
                          X_appraisal_id                    NUMBER,
                          X_asset_number                    VARCHAR2,
                          X_appraisal_value                 NUMBER,
                          X_status                          VARCHAR2,
                          X_LAST_UPDATE_DATE                DATE,
                          X_LAST_UPDATED_BY                 NUMBER,
                          X_CREATION_DATE                   DATE,
                          X_CREATED_BY                      NUMBER,
                          X_LAST_UPDATE_LOGIN               NUMBER,
                          X_ATTRIBUTE_CATEGORY              VARCHAR2,
                          X_ATTRIBUTE1                      VARCHAR2,
                          X_ATTRIBUTE2                      VARCHAR2,
                          X_ATTRIBUTE3                      VARCHAR2,
                          X_ATTRIBUTE4                      VARCHAR2,
                          X_ATTRIBUTE5                      VARCHAR2,
                          X_ATTRIBUTE6                      VARCHAR2,
                          X_ATTRIBUTE7                      VARCHAR2,
                          X_ATTRIBUTE8                      VARCHAR2,
                          X_ATTRIBUTE9                      VARCHAR2,
                          X_ATTRIBUTE10                     VARCHAR2,
                          X_ATTRIBUTE11                     VARCHAR2,
                          X_ATTRIBUTE12                     VARCHAR2,
                          X_ATTRIBUTE13                     VARCHAR2,
                          X_ATTRIBUTE14                     VARCHAR2,
                          X_ATTRIBUTE15                     VARCHAR2,
                          X_calling_sequence        IN    VARCHAR2
  );

  PROCEDURE Update_Row(
			  X_rowid                   VARCHAR2,
                          X_appraisal_id                    NUMBER,
                          X_asset_number                    VARCHAR2,
                          X_appraisal_value                 NUMBER,
                          X_status                          VARCHAR2,
                          X_LAST_UPDATE_DATE                DATE,
                          X_LAST_UPDATED_BY                 NUMBER,
                          X_CREATION_DATE                   DATE,
                          X_CREATED_BY                      NUMBER,
                          X_LAST_UPDATE_LOGIN               NUMBER,
                          X_ATTRIBUTE_CATEGORY              VARCHAR2,
                          X_ATTRIBUTE1                      VARCHAR2,
                          X_ATTRIBUTE2                      VARCHAR2,
                          X_ATTRIBUTE3                      VARCHAR2,
                          X_ATTRIBUTE4                      VARCHAR2,
                          X_ATTRIBUTE5                      VARCHAR2,
                          X_ATTRIBUTE6                      VARCHAR2,
                          X_ATTRIBUTE7                      VARCHAR2,
                          X_ATTRIBUTE8                      VARCHAR2,
                          X_ATTRIBUTE9                      VARCHAR2,
                          X_ATTRIBUTE10                     VARCHAR2,
                          X_ATTRIBUTE11                     VARCHAR2,
                          X_ATTRIBUTE12                     VARCHAR2,
                          X_ATTRIBUTE13                     VARCHAR2,
                          X_ATTRIBUTE14                     VARCHAR2,
                          X_ATTRIBUTE15                     VARCHAR2,
                          X_calling_sequence        IN    VARCHAR2
  );

  PROCEDURE Delete_Row(
			  X_rowid                   VARCHAR2
  );
END JL_CO_FA_ASSET_APPRS_PKG;

 

/
