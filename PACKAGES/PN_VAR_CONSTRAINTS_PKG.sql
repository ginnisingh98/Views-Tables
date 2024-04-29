--------------------------------------------------------
--  DDL for Package PN_VAR_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_CONSTRAINTS_PKG" AUTHID CURRENT_USER as
/* $Header: PNVRCONS.pls 120.2 2006/12/20 09:26:35 pseeram noship $ */

procedure INSERT_ROW (
  X_ROWID                 in out NOCOPY VARCHAR2,
  X_CONSTRAINT_ID         in out NOCOPY NUMBER,
  X_CONSTRAINT_NUM        in out NOCOPY NUMBER,
  X_PERIOD_ID             in NUMBER,
  X_CONSTR_CAT_CODE       in VARCHAR2,
  X_TYPE_CODE             in VARCHAR2,
  X_AMOUNT                in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_CONSTR_TEMPLATE_ID    in NUMBER,
  X_CONSTR_DEFAULT_ID     in NUMBER,
  X_COMMENTS              in VARCHAR2,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  X_ATTRIBUTE1            in VARCHAR2,
  X_ATTRIBUTE2            in VARCHAR2,
  X_ATTRIBUTE3            in VARCHAR2,
  X_ATTRIBUTE4            in VARCHAR2,
  X_ATTRIBUTE5            in VARCHAR2,
  X_ATTRIBUTE6            in VARCHAR2,
  X_ATTRIBUTE7            in VARCHAR2,
  X_ATTRIBUTE8            in VARCHAR2,
  X_ATTRIBUTE9            in VARCHAR2,
  X_ATTRIBUTE10           in VARCHAR2,
  X_ATTRIBUTE11           in VARCHAR2,
  X_ATTRIBUTE12           in VARCHAR2,
  X_ATTRIBUTE13           in VARCHAR2,
  X_ATTRIBUTE14           in VARCHAR2,
  X_ATTRIBUTE15           in VARCHAR2,
  X_ORG_ID                in NUMBER default NULL,
  X_CREATION_DATE         in DATE,
  X_CREATED_BY            in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_CONSTR_START_DATE     in DATE,
  X_CONSTR_END_DATE       in DATE);


procedure LOCK_ROW (
  X_CONSTRAINT_ID         in NUMBER,
  X_CONSTRAINT_NUM        in NUMBER,
  X_PERIOD_ID             in NUMBER,
  X_CONSTR_CAT_CODE       in VARCHAR2,
  X_TYPE_CODE             in VARCHAR2,
  X_AMOUNT                in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_CONSTR_TEMPLATE_ID    in NUMBER,
  X_CONSTR_DEFAULT_ID     in NUMBER,
  X_COMMENTS              in VARCHAR2,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  X_ATTRIBUTE1            in VARCHAR2,
  X_ATTRIBUTE2            in VARCHAR2,
  X_ATTRIBUTE3            in VARCHAR2,
  X_ATTRIBUTE4            in VARCHAR2,
  X_ATTRIBUTE5            in VARCHAR2,
  X_ATTRIBUTE6            in VARCHAR2,
  X_ATTRIBUTE7            in VARCHAR2,
  X_ATTRIBUTE8            in VARCHAR2,
  X_ATTRIBUTE9            in VARCHAR2,
  X_ATTRIBUTE10           in VARCHAR2,
  X_ATTRIBUTE11           in VARCHAR2,
  X_ATTRIBUTE12           in VARCHAR2,
  X_ATTRIBUTE13           in VARCHAR2,
  X_ATTRIBUTE14           in VARCHAR2,
  X_ATTRIBUTE15           in VARCHAR2,
  X_CONSTR_START_DATE     in DATE,
  X_CONSTR_END_DATE       in DATE
);


procedure UPDATE_ROW (
  X_CONSTRAINT_ID         in NUMBER,
  X_CONSTRAINT_NUM        in NUMBER,
  X_PERIOD_ID             in NUMBER,
  X_CONSTR_CAT_CODE       in VARCHAR2,
  X_TYPE_CODE             in VARCHAR2,
  X_AMOUNT                in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_CONSTR_TEMPLATE_ID    in NUMBER,
  X_CONSTR_DEFAULT_ID     in NUMBER,
  X_COMMENTS              in VARCHAR2,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  X_ATTRIBUTE1            in VARCHAR2,
  X_ATTRIBUTE2            in VARCHAR2,
  X_ATTRIBUTE3            in VARCHAR2,
  X_ATTRIBUTE4            in VARCHAR2,
  X_ATTRIBUTE5            in VARCHAR2,
  X_ATTRIBUTE6            in VARCHAR2,
  X_ATTRIBUTE7            in VARCHAR2,
  X_ATTRIBUTE8            in VARCHAR2,
  X_ATTRIBUTE9            in VARCHAR2,
  X_ATTRIBUTE10           in VARCHAR2,
  X_ATTRIBUTE11           in VARCHAR2,
  X_ATTRIBUTE12           in VARCHAR2,
  X_ATTRIBUTE13           in VARCHAR2,
  X_ATTRIBUTE14           in VARCHAR2,
  X_ATTRIBUTE15           in VARCHAR2,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_CONSTR_START_DATE     in DATE,
  X_CONSTR_END_DATE       in DATE
);


procedure DELETE_ROW (
  X_CONSTRAINT_ID in NUMBER
);

PROCEDURE CHECK_MAX_CONSTR
        (
            x_return_status     in out NOCOPY  varchar2,
            x_period_id         in      number,
            x_constraint_id     in      number,
            x_constr_cat_code   in      varchar2,
            x_type_code         in      varchar2,
            x_amount            in      number
        );

END PN_VAR_CONSTRAINTS_PKG;


/
