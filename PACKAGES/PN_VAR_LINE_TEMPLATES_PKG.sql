--------------------------------------------------------
--  DDL for Package PN_VAR_LINE_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_LINE_TEMPLATES_PKG" AUTHID CURRENT_USER as
/* $Header: PNVRLITS.pls 120.3 2006/09/14 04:07:41 pikhar noship $*/

procedure INSERT_ROW (
  X_ROWID                    in out NOCOPY VARCHAR2,
  X_LINE_TEMPLATE_ID         in out NOCOPY NUMBER,
  X_LINE_DETAIL_NUM          in out NOCOPY NUMBER,
  X_AGREEMENT_TEMPLATE_ID    in NUMBER,
  X_SALES_TYPE_CODE          in VARCHAR2,
  X_ITEM_CATEGORY_CODE       in VARCHAR2,
  X_ORG_ID                   in NUMBER default NULL,
  X_CREATION_DATE            in DATE,
  X_CREATED_BY               in NUMBER,
  X_LAST_UPDATE_DATE         in DATE,
  X_LAST_UPDATED_BY          in NUMBER,
  X_LAST_UPDATE_LOGIN        in NUMBER,
  X_ATTRIBUTE_CATEGORY       in VARCHAR2,
  X_ATTRIBUTE1               in VARCHAR2,
  X_ATTRIBUTE2               in VARCHAR2,
  X_ATTRIBUTE3               in VARCHAR2,
  X_ATTRIBUTE4               in VARCHAR2,
  X_ATTRIBUTE5               in VARCHAR2,
  X_ATTRIBUTE6               in VARCHAR2,
  X_ATTRIBUTE7               in VARCHAR2,
  X_ATTRIBUTE8               in VARCHAR2,
  X_ATTRIBUTE9               in VARCHAR2,
  X_ATTRIBUTE10              in VARCHAR2,
  X_ATTRIBUTE11              in VARCHAR2,
  X_ATTRIBUTE12              in VARCHAR2,
  X_ATTRIBUTE13              in VARCHAR2,
  X_ATTRIBUTE14              in VARCHAR2,
  X_ATTRIBUTE15              in VARCHAR2
  );

procedure LOCK_ROW (
  X_LINE_TEMPLATE_ID         in NUMBER,
  X_LINE_DETAIL_NUM          in NUMBER,
  X_AGREEMENT_TEMPLATE_ID    in NUMBER,
  X_SALES_TYPE_CODE          in VARCHAR2,
  X_ITEM_CATEGORY_CODE       in VARCHAR2,
  X_ATTRIBUTE_CATEGORY       in VARCHAR2,
  X_ATTRIBUTE1               in VARCHAR2,
  X_ATTRIBUTE2               in VARCHAR2,
  X_ATTRIBUTE3               in VARCHAR2,
  X_ATTRIBUTE4               in VARCHAR2,
  X_ATTRIBUTE5               in VARCHAR2,
  X_ATTRIBUTE6               in VARCHAR2,
  X_ATTRIBUTE7               in VARCHAR2,
  X_ATTRIBUTE8               in VARCHAR2,
  X_ATTRIBUTE9               in VARCHAR2,
  X_ATTRIBUTE10              in VARCHAR2,
  X_ATTRIBUTE11              in VARCHAR2,
  X_ATTRIBUTE12              in VARCHAR2,
  X_ATTRIBUTE13              in VARCHAR2,
  X_ATTRIBUTE14              in VARCHAR2,
  X_ATTRIBUTE15              in VARCHAR2
  );

procedure UPDATE_ROW (
  X_LINE_TEMPLATE_ID         in NUMBER,
  X_LINE_DETAIL_NUM          in NUMBER,
  X_AGREEMENT_TEMPLATE_ID    in NUMBER,
  X_SALES_TYPE_CODE          in VARCHAR2,
  X_ITEM_CATEGORY_CODE       in VARCHAR2,
  X_LAST_UPDATE_DATE         in DATE,
  X_LAST_UPDATED_BY          in NUMBER,
  X_LAST_UPDATE_LOGIN        in NUMBER,
  X_ATTRIBUTE_CATEGORY       in VARCHAR2,
  X_ATTRIBUTE1               in VARCHAR2,
  X_ATTRIBUTE2               in VARCHAR2,
  X_ATTRIBUTE3               in VARCHAR2,
  X_ATTRIBUTE4               in VARCHAR2,
  X_ATTRIBUTE5               in VARCHAR2,
  X_ATTRIBUTE6               in VARCHAR2,
  X_ATTRIBUTE7               in VARCHAR2,
  X_ATTRIBUTE8               in VARCHAR2,
  X_ATTRIBUTE9               in VARCHAR2,
  X_ATTRIBUTE10              in VARCHAR2,
  X_ATTRIBUTE11              in VARCHAR2,
  X_ATTRIBUTE12              in VARCHAR2,
  X_ATTRIBUTE13              in VARCHAR2,
  X_ATTRIBUTE14              in VARCHAR2,
  X_ATTRIBUTE15              in VARCHAR2
  );

procedure DELETE_ROW (
  X_LINE_TEMPLATE_ID        in NUMBER
  );

end PN_VAR_LINE_TEMPLATES_PKG;

/
