--------------------------------------------------------
--  DDL for Package BNE_IMPORT_PROGRAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_IMPORT_PROGRAMS_PKG" AUTHID CURRENT_USER as
/* $Header: bneimpprogs.pls 120.2 2005/06/29 03:40:00 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARENT_SEQ_NUM in NUMBER,
  X_IMPORT_TYPE in NUMBER,
  X_IMPORT_PARAM_LIST_APP_ID in NUMBER,
  X_IMPORT_PARAM_LIST_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARENT_SEQ_NUM in NUMBER,
  X_IMPORT_TYPE in NUMBER,
  X_IMPORT_PARAM_LIST_APP_ID in NUMBER,
  X_IMPORT_PARAM_LIST_CODE in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARENT_SEQ_NUM in NUMBER,
  X_IMPORT_TYPE in NUMBER,
  X_IMPORT_PARAM_LIST_APP_ID in NUMBER,
  X_IMPORT_PARAM_LIST_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
);
procedure ADD_LANGUAGE;

procedure LOAD_ROW(
  x_integrator_asn              in VARCHAR2,
  x_integrator_code             in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_parent_seq_num              in VARCHAR2,
  x_import_type                 in VARCHAR2,
  x_import_param_list_asn       in VARCHAR2,
  x_import_param_code           in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
);

end BNE_IMPORT_PROGRAMS_PKG;

 

/