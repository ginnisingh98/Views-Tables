--------------------------------------------------------
--  DDL for Package IEX_CASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CASES_PKG" AUTHID CURRENT_USER as
/* $Header: iextcass.pls 120.0 2004/01/24 03:21:17 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_CASES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

procedure INSERT_ROW (
 X_ROWID                   in out NOCOPY VARCHAR2,
 X_CAS_ID                  in  NUMBER,
 X_CASE_NUMBER             in VARCHAR2,
 X_ACTIVE_FLAG             in VARCHAR2,
 X_PARTY_ID                in NUMBER,
 X_OBJECT_VERSION_NUMBER   in NUMBER,
 X_CASE_ESTABLISHED_DATE   in DATE,
 X_CASE_CLOSING_DATE       in DATE,
 X_ORIG_CAS_ID             in  NUMBER,
 X_CASE_STATE              in VARCHAR2,
 X_STATUS_CODE             in VARCHAR2,
 X_CLOSE_REASON             in VARCHAR2,
 X_ORG_ID                  in  NUMBER,
 X_OWNER_RESOURCE_ID       in  NUMBER,
 X_ACCESS_RESOURCE_ID      in  NUMBER,
 X_COMMENTS                in VARCHAR2,
X_PREDICTED_RECOVERY_AMOUNT in NUMBER,
X_PREDICTED_CHANCE          in NUMBER,
 X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2,
 X_CREATION_DATE           in DATE,
 X_CREATED_BY              in NUMBER,
 X_LAST_UPDATE_DATE        in DATE,
 X_LAST_UPDATED_BY         in NUMBER,
 X_LAST_UPDATE_LOGIN       in NUMBER);

/*procedure LOCK_ROW (
 X_CAS_ID                  in NUMBER,
 X_CASE_NUMBER             in VARCHAR2,
 X_ACTIVE_FLAG             in VARCHAR2,
 X_PARTY_ID                in NUMBER,
 X_OBJECT_VERSION_NUMBER   in NUMBER,
 X_CASE_ESTABLISHED_DATE   in DATE,
 X_CASE_CLOSING_DATE       in DATE,
 X_STATUS_CODE             in VARCHAR2,
 X_CLOSE_REASON             in VARCHAR2,
 X_ORG_ID                  in  NUMBER,
 X_OWNER_RESOURCE_ID       in  NUMBER,
 X_ACCESS_RESOURCE_ID      in  NUMBER,
 X_COMMENTS                in VARCHAR2,
X_PREDICTED_RECOVERY_AMOUNT in NUMBER,
X_PREDICTED_CHANCE          in NUMBER,
 X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2
);
*/
procedure LOCK_ROW (
  X_CAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);

procedure UPDATE_ROW (
 X_CAS_ID                  in NUMBER,
 X_CASE_NUMBER             in VARCHAR2,
 X_ACTIVE_FLAG             in VARCHAR2,
 X_PARTY_ID                in NUMBER,
 X_OBJECT_VERSION_NUMBER   in NUMBER,
 X_CASE_ESTABLISHED_DATE   in DATE,
 X_CASE_CLOSING_DATE       in DATE,
 X_ORIG_CAS_ID             in  NUMBER,
 X_CASE_STATE              in VARCHAR2,
 X_STATUS_CODE             in VARCHAR2,
 X_CLOSE_REASON             in VARCHAR2,
 X_ORG_ID                  in  NUMBER,
 X_OWNER_RESOURCE_ID       in  NUMBER,
 X_ACCESS_RESOURCE_ID      in  NUMBER,
 X_COMMENTS                in VARCHAR2,
X_PREDICTED_RECOVERY_AMOUNT in NUMBER,
X_PREDICTED_CHANCE          in NUMBER,
 X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2,
 X_LAST_UPDATE_DATE        in DATE,
 X_LAST_UPDATED_BY         in NUMBER,
 X_LAST_UPDATE_LOGIN       in NUMBER);
procedure DELETE_ROW (
 X_CAS_ID in NUMBER
);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW (
  X_CAS_ID                in NUMBER,
  X_COMMENTS              in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER                 in VARCHAR2
);
end IEX_CASES_PKG;

 

/
