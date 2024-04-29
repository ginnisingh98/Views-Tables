--------------------------------------------------------
--  DDL for Package PN_VAR_DEDUCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_DEDUCTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: PNVRDEDS.pls 115.4 2002/11/12 23:17:57 stripath noship $ */

procedure INSERT_ROW (
  X_ROWID               in out NOCOPY VARCHAR2,
  X_DEDUCTION_ID        in out NOCOPY NUMBER,
  X_DEDUCTION_NUM       in out NOCOPY NUMBER,
  X_EXPORTED_CODE       in VARCHAR2,
  X_LINE_ITEM_ID        in NUMBER,
  X_PERIOD_ID           in NUMBER,
  X_START_DATE          in DATE,
  X_END_DATE            in DATE,
  X_GRP_DATE_ID         in NUMBER,
  X_GROUP_DATE          in DATE,
  X_INVOICING_DATE      in DATE,
  X_GL_ACCOUNT_ID       in NUMBER,
  X_DEDUCTION_TYPE_CODE in VARCHAR2,
  X_DEDUCTION_AMOUNT    in NUMBER,
  X_COMMENTS            in VARCHAR2,
  X_ATTRIBUTE_CATEGORY  in VARCHAR2,
  X_ATTRIBUTE1          in VARCHAR2,
  X_ATTRIBUTE2          in VARCHAR2,
  X_ATTRIBUTE3          in VARCHAR2,
  X_ATTRIBUTE4          in VARCHAR2,
  X_ATTRIBUTE5          in VARCHAR2,
  X_ATTRIBUTE6          in VARCHAR2,
  X_ATTRIBUTE7          in VARCHAR2,
  X_ATTRIBUTE8          in VARCHAR2,
  X_ATTRIBUTE9          in VARCHAR2,
  X_ATTRIBUTE10         in VARCHAR2,
  X_ATTRIBUTE11         in VARCHAR2,
  X_ATTRIBUTE12         in VARCHAR2,
  X_ATTRIBUTE13         in VARCHAR2,
  X_ATTRIBUTE14         in VARCHAR2,
  X_ATTRIBUTE15         in VARCHAR2,
  X_ORG_ID              in NUMBER default NULL,
  X_CREATION_DATE       in DATE,
  X_CREATED_BY          in NUMBER,
  X_LAST_UPDATE_DATE    in DATE,
  X_LAST_UPDATED_BY     in NUMBER,
  X_LAST_UPDATE_LOGIN   in NUMBER);


procedure LOCK_ROW (
  X_DEDUCTION_ID        in NUMBER,
  X_DEDUCTION_NUM       in NUMBER,
  X_EXPORTED_CODE       in VARCHAR2,
  X_LINE_ITEM_ID        in NUMBER,
  X_PERIOD_ID           in NUMBER,
  X_START_DATE          in DATE,
  X_END_DATE            in DATE,
  X_GRP_DATE_ID         in NUMBER,
  X_GROUP_DATE          in DATE,
  X_INVOICING_DATE      in DATE,
  X_GL_ACCOUNT_ID       in NUMBER,
  X_DEDUCTION_TYPE_CODE in VARCHAR2,
  X_DEDUCTION_AMOUNT    in NUMBER,
  X_COMMENTS            in VARCHAR2,
  X_ATTRIBUTE_CATEGORY  in VARCHAR2,
  X_ATTRIBUTE1          in VARCHAR2,
  X_ATTRIBUTE2          in VARCHAR2,
  X_ATTRIBUTE3          in VARCHAR2,
  X_ATTRIBUTE4          in VARCHAR2,
  X_ATTRIBUTE5          in VARCHAR2,
  X_ATTRIBUTE6          in VARCHAR2,
  X_ATTRIBUTE7          in VARCHAR2,
  X_ATTRIBUTE8          in VARCHAR2,
  X_ATTRIBUTE9          in VARCHAR2,
  X_ATTRIBUTE10         in VARCHAR2,
  X_ATTRIBUTE11         in VARCHAR2,
  X_ATTRIBUTE12         in VARCHAR2,
  X_ATTRIBUTE13         in VARCHAR2,
  X_ATTRIBUTE14         in VARCHAR2,
  X_ATTRIBUTE15         in VARCHAR2
);


procedure UPDATE_ROW (
  X_DEDUCTION_ID        in NUMBER,
  X_DEDUCTION_NUM       in NUMBER,
  X_EXPORTED_CODE       in VARCHAR2,
  X_LINE_ITEM_ID        in NUMBER,
  X_PERIOD_ID           in NUMBER,
  X_START_DATE          in DATE,
  X_END_DATE            in DATE,
  X_GRP_DATE_ID         in NUMBER,
  X_GROUP_DATE          in DATE,
  X_INVOICING_DATE      in DATE,
  X_GL_ACCOUNT_ID       in NUMBER,
  X_DEDUCTION_TYPE_CODE in VARCHAR2,
  X_DEDUCTION_AMOUNT    in NUMBER,
  X_COMMENTS            in VARCHAR2,
  X_ATTRIBUTE_CATEGORY  in VARCHAR2,
  X_ATTRIBUTE1          in VARCHAR2,
  X_ATTRIBUTE2          in VARCHAR2,
  X_ATTRIBUTE3          in VARCHAR2,
  X_ATTRIBUTE4          in VARCHAR2,
  X_ATTRIBUTE5          in VARCHAR2,
  X_ATTRIBUTE6          in VARCHAR2,
  X_ATTRIBUTE7          in VARCHAR2,
  X_ATTRIBUTE8          in VARCHAR2,
  X_ATTRIBUTE9          in VARCHAR2,
  X_ATTRIBUTE10         in VARCHAR2,
  X_ATTRIBUTE11         in VARCHAR2,
  X_ATTRIBUTE12         in VARCHAR2,
  X_ATTRIBUTE13         in VARCHAR2,
  X_ATTRIBUTE14         in VARCHAR2,
  X_ATTRIBUTE15         in VARCHAR2,
  X_LAST_UPDATE_DATE    in DATE,
  X_LAST_UPDATED_BY     in NUMBER,
  X_LAST_UPDATE_LOGIN   in NUMBER
  );


procedure DELETE_ROW (
  X_DEDUCTION_ID        in NUMBER
);


end PN_VAR_DEDUCTIONS_PKG;


 

/
