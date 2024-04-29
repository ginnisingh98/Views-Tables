--------------------------------------------------------
--  DDL for Package IEC_O_ALG_OP_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_O_ALG_OP_DEFS_PKG" AUTHID CURRENT_USER as
/* $Header: IECHOPDS.pls 120.1 2005/07/20 13:04:48 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_IS_UNARY_FLAG in VARCHAR2,
  X_SQL_OPERATOR in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure LOCK_ROW (
  X_OPERATOR_CODE in VARCHAR2,
  X_IS_UNARY_FLAG in VARCHAR2,
  X_SQL_OPERATOR in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2
);

procedure UPDATE_ROW (
  X_OPERATOR_CODE in VARCHAR2,
  X_IS_UNARY_FLAG in VARCHAR2,
  X_SQL_OPERATOR in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_OPERATOR_CODE in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  X_OPERATOR_CODE in VARCHAR2,
  X_IS_UNARY_FLAG in VARCHAR2,
  X_SQL_OPERATOR in VARCHAR2,
  X_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
);

procedure LOAD_SEED_ROW (
  X_upload_mode	in VARCHAR2,
  X_OPERATOR_CODE in VARCHAR2,
  X_IS_UNARY_FLAG in VARCHAR2,
  X_SQL_OPERATOR in VARCHAR2,
  X_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_OPERATOR_CODE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
);

end IEC_O_ALG_OP_DEFS_PKG;

 

/