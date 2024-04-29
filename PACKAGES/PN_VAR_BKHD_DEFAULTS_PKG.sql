--------------------------------------------------------
--  DDL for Package PN_VAR_BKHD_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_BKHD_DEFAULTS_PKG" AUTHID CURRENT_USER AS
/* $Header: PNVRBHDS.pls 120.0 2007/10/03 14:28:09 rthumma noship $ */

procedure INSERT_ROW (
  X_ROWID                 in out NOCOPY VARCHAR2,
  X_BKHD_DEFAULT_ID       in out NOCOPY NUMBER,
  X_BKHD_DETAIL_NUM       in out NOCOPY NUMBER,
  X_LINE_DEFAULT_ID       in NUMBER,
  X_BKPT_HEAD_TEMPLATE_ID in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_BKHD_START_DATE       in DATE,
  X_BKHD_END_DATE         in DATE,
  X_BREAK_TYPE            in VARCHAR2,
  X_BASE_RENT_TYPE        in VARCHAR2,
  X_NATURAL_BREAK_RATE    in NUMBER,
  X_BASE_RENT             in NUMBER,
  X_BREAKPOINT_TYPE       in VARCHAR2,
  X_BREAKPOINT_LEVEL      in VARCHAR2,
  X_PROCESSED_FLAG        in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_CREATION_DATE         in DATE,
  X_CREATED_BY            in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_ORG_ID                in NUMBER,
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
  X_ATTRIBUTE15           in VARCHAR2
);

procedure LOCK_ROW (
  X_BKHD_DEFAULT_ID       in NUMBER,
  X_BKHD_DETAIL_NUM       in NUMBER,
  X_LINE_DEFAULT_ID       in NUMBER,
  X_BKPT_HEAD_TEMPLATE_ID in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_BKHD_START_DATE       in DATE,
  X_BKHD_END_DATE         in DATE,
  X_BREAK_TYPE            in VARCHAR2,
  X_BASE_RENT_TYPE        in VARCHAR2,
  X_NATURAL_BREAK_RATE    in NUMBER,
  X_BASE_RENT             in NUMBER,
  X_BREAKPOINT_TYPE       in VARCHAR2,
  X_BREAKPOINT_LEVEL      in VARCHAR2,
  X_VAR_RENT_ID           in NUMBER,
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
  X_ATTRIBUTE15           in VARCHAR2
);

procedure UPDATE_ROW (
  X_BKHD_DEFAULT_ID       in NUMBER,
  X_BKHD_DETAIL_NUM       in NUMBER,
  X_LINE_DEFAULT_ID       in NUMBER,
  X_BKPT_HEAD_TEMPLATE_ID in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_BKHD_START_DATE       in DATE,
  X_BKHD_END_DATE         in DATE,
  X_BREAK_TYPE            in VARCHAR2,
  X_BASE_RENT_TYPE        in VARCHAR2,
  X_NATURAL_BREAK_RATE    in NUMBER,
  X_BASE_RENT             in NUMBER,
  X_BREAKPOINT_TYPE       in VARCHAR2,
  X_BREAKPOINT_LEVEL      in VARCHAR2,
  X_PROCESSED_FLAG        in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
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
  X_ATTRIBUTE15           in VARCHAR2
);

procedure DELETE_ROW (
  X_BKHD_DEFAULT_ID in NUMBER
);

procedure MODIFY_ROW (
  X_BKHD_DEFAULT_ID       in NUMBER,
  X_BKHD_DETAIL_NUM       in NUMBER   DEFAULT NULL,
  X_LINE_DEFAULT_ID       in NUMBER   DEFAULT NULL,
  X_BKPT_HEAD_TEMPLATE_ID in NUMBER   DEFAULT NULL,
  X_AGREEMENT_TEMPLATE_ID in NUMBER   DEFAULT NULL,
  X_BKHD_START_DATE       in DATE     DEFAULT NULL,
  X_BKHD_END_DATE         in DATE     DEFAULT NULL,
  X_BREAK_TYPE            in VARCHAR2 DEFAULT NULL,
  X_BASE_RENT_TYPE        in VARCHAR2 DEFAULT NULL,
  X_NATURAL_BREAK_RATE    in NUMBER   DEFAULT NULL,
  X_BASE_RENT             in NUMBER   DEFAULT NULL,
  X_BREAKPOINT_TYPE       in VARCHAR2 DEFAULT NULL,
  X_BREAKPOINT_LEVEL      in VARCHAR2 DEFAULT NULL,
  X_PROCESSED_FLAG        in NUMBER   DEFAULT NULL,
  X_VAR_RENT_ID           in NUMBER   DEFAULT NULL,
  X_LAST_UPDATE_DATE      in DATE     DEFAULT NULL,
  X_LAST_UPDATED_BY       in NUMBER   DEFAULT NULL,
  X_LAST_UPDATE_LOGIN     in NUMBER   DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1            in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2            in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3            in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4            in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5            in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6            in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7            in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8            in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9            in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10           in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11           in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12           in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13           in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14           in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15           in VARCHAR2 DEFAULT NULL
);

end PN_VAR_BKHD_DEFAULTS_PKG;

/
