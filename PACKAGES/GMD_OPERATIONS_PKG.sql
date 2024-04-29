--------------------------------------------------------
--  DDL for Package GMD_OPERATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OPERATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: GMDOPRMS.pls 120.0 2005/05/25 18:55:15 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY  VARCHAR2,
  X_OPRN_ID in NUMBER,
  X_ATTRIBUTE30 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_OPRN_NO in VARCHAR2,
  X_OPRN_VERS in NUMBER,
  X_PROCESS_QTY_UOM in VARCHAR2,
  X_MINIMUM_TRANSFER_QTY in NUMBER DEFAULT NULL,
  X_OPRN_CLASS in VARCHAR2,
  X_INACTIVE_IND in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_OPERATION_STATUS in VARCHAR2,
  X_OWNER_ORGANIZATION_ID in NUMBER,
  X_OPRN_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_OPRN_ID in NUMBER,
  X_ATTRIBUTE30 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_OPRN_NO in VARCHAR2,
  X_OPRN_VERS in NUMBER,
  X_PROCESS_QTY_UOM in VARCHAR2,
  X_MINIMUM_TRANSFER_QTY in NUMBER DEFAULT NULL,
  X_OPRN_CLASS in VARCHAR2,
  X_INACTIVE_IND in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_OPERATION_STATUS in VARCHAR2,
  X_OWNER_ORGANIZATION_ID in NUMBER,
  X_OPRN_DESC in VARCHAR2
);

procedure UPDATE_ROW (
  X_OPRN_ID in NUMBER,
  X_ATTRIBUTE30 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_OPRN_NO in VARCHAR2,
  X_OPRN_VERS in NUMBER,
  X_PROCESS_QTY_UOM in VARCHAR2,
  X_MINIMUM_TRANSFER_QTY in NUMBER  DEFAULT NULL,
  X_OPRN_CLASS in VARCHAR2,
  X_INACTIVE_IND in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_OPERATION_STATUS in VARCHAR2,
  X_OWNER_ORGANIZATION_ID in NUMBER,
  X_OPRN_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_OPRN_ID in NUMBER
);
procedure ADD_LANGUAGE;
end GMD_OPERATIONS_PKG;

 

/