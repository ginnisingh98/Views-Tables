--------------------------------------------------------
--  DDL for Package PN_VAR_ABAT_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_ABAT_DEFAULTS_PKG" AUTHID CURRENT_USER as
/* $Header: PNVRABDS.pls 120.0 2007/10/03 14:27:30 rthumma noship $ */

procedure INSERT_ROW (
  X_ROWID                  in out NOCOPY VARCHAR2
 ,X_ABATEMENT_ID           in out NOCOPY NUMBER
 ,X_VAR_RENT_ID            in NUMBER
 ,X_START_DATE             in DATE
 ,X_END_DATE               in DATE
 ,X_TYPE_CODE              in VARCHAR2
 ,X_AMOUNT                 in NUMBER
 ,X_DESCRIPTION            in VARCHAR2
 ,X_LAST_UPDATE_DATE       in DATE
 ,X_LAST_UPDATED_BY        in NUMBER
 ,X_CREATION_DATE          in DATE
 ,X_CREATED_BY             in NUMBER
 ,X_LAST_UPDATE_LOGIN      in NUMBER
 ,X_COMMENTS               in VARCHAR2
 ,X_ATTRIBUTE_CATEGORY     in VARCHAR2
 ,X_ATTRIBUTE1             in VARCHAR2
 ,X_ATTRIBUTE2             in VARCHAR2
 ,X_ATTRIBUTE3             in VARCHAR2
 ,X_ATTRIBUTE4             in VARCHAR2
 ,X_ATTRIBUTE5             in VARCHAR2
 ,X_ATTRIBUTE6             in VARCHAR2
 ,X_ATTRIBUTE7             in VARCHAR2
 ,X_ATTRIBUTE8             in VARCHAR2
 ,X_ATTRIBUTE9             in VARCHAR2
 ,X_ATTRIBUTE10            in VARCHAR2
 ,X_ATTRIBUTE11            in VARCHAR2
 ,X_ATTRIBUTE12            in VARCHAR2
 ,X_ATTRIBUTE13            in VARCHAR2
 ,X_ATTRIBUTE14            in VARCHAR2
 ,X_ATTRIBUTE15            in VARCHAR2
 ,X_ORG_ID                 in NUMBER);


procedure LOCK_ROW (
  X_ABATEMENT_ID           in NUMBER
 ,X_VAR_RENT_ID            in NUMBER
 ,X_START_DATE             in DATE
 ,X_END_DATE               in DATE
 ,X_TYPE_CODE              in VARCHAR2
 ,X_AMOUNT                 in NUMBER
 ,X_DESCRIPTION            in VARCHAR2
 ,X_LAST_UPDATE_DATE       in DATE
 ,X_LAST_UPDATED_BY        in NUMBER
 ,X_CREATION_DATE          in DATE
 ,X_CREATED_BY             in NUMBER
 ,X_LAST_UPDATE_LOGIN      in NUMBER
 ,X_COMMENTS               in VARCHAR2
 ,X_ATTRIBUTE_CATEGORY     in VARCHAR2
 ,X_ATTRIBUTE1             in VARCHAR2
 ,X_ATTRIBUTE2             in VARCHAR2
 ,X_ATTRIBUTE3             in VARCHAR2
 ,X_ATTRIBUTE4             in VARCHAR2
 ,X_ATTRIBUTE5             in VARCHAR2
 ,X_ATTRIBUTE6             in VARCHAR2
 ,X_ATTRIBUTE7             in VARCHAR2
 ,X_ATTRIBUTE8             in VARCHAR2
 ,X_ATTRIBUTE9             in VARCHAR2
 ,X_ATTRIBUTE10            in VARCHAR2
 ,X_ATTRIBUTE11            in VARCHAR2
 ,X_ATTRIBUTE12            in VARCHAR2
 ,X_ATTRIBUTE13            in VARCHAR2
 ,X_ATTRIBUTE14            in VARCHAR2
 ,X_ATTRIBUTE15            in VARCHAR2
 ,X_ORG_ID                 in NUMBER);

procedure UPDATE_ROW (
  X_ABATEMENT_ID           in NUMBER
 ,X_VAR_RENT_ID            in NUMBER
 ,X_START_DATE             in DATE
 ,X_END_DATE               in DATE
 ,X_TYPE_CODE              in VARCHAR2
 ,X_AMOUNT                 in NUMBER
 ,X_DESCRIPTION            in VARCHAR2
 ,X_LAST_UPDATE_DATE       in DATE
 ,X_LAST_UPDATED_BY        in NUMBER
 ,X_CREATION_DATE          in DATE
 ,X_CREATED_BY             in NUMBER
 ,X_LAST_UPDATE_LOGIN      in NUMBER
 ,X_COMMENTS               in VARCHAR2
 ,X_ATTRIBUTE_CATEGORY     in VARCHAR2
 ,X_ATTRIBUTE1             in VARCHAR2
 ,X_ATTRIBUTE2             in VARCHAR2
 ,X_ATTRIBUTE3             in VARCHAR2
 ,X_ATTRIBUTE4             in VARCHAR2
 ,X_ATTRIBUTE5             in VARCHAR2
 ,X_ATTRIBUTE6             in VARCHAR2
 ,X_ATTRIBUTE7             in VARCHAR2
 ,X_ATTRIBUTE8             in VARCHAR2
 ,X_ATTRIBUTE9             in VARCHAR2
 ,X_ATTRIBUTE10            in VARCHAR2
 ,X_ATTRIBUTE11            in VARCHAR2
 ,X_ATTRIBUTE12            in VARCHAR2
 ,X_ATTRIBUTE13            in VARCHAR2
 ,X_ATTRIBUTE14            in VARCHAR2
 ,X_ATTRIBUTE15            in VARCHAR2
 ,X_ORG_ID                 in NUMBER);

procedure DELETE_ROW (
  X_ABATEMENT_ID      in NUMBER
);

end PN_VAR_ABAT_DEFAULTS_PKG;

/