--------------------------------------------------------
--  DDL for Package BNE_LAYOUTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_LAYOUTS_PKG" AUTHID CURRENT_USER as
/* $Header: bnelays.pls 120.2 2005/06/29 03:40:19 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_STYLESHEET_APP_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_STYLE_CLASS in VARCHAR2,
  X_REPORTING_FLAG in VARCHAR2,
  X_REPORTING_INTERFACE_APP_ID in NUMBER,
  X_REPORTING_INTERFACE_CODE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATE_DOC_LIST_APP_ID in NUMBER DEFAULT NULL,
  X_CREATE_DOC_LIST_CODE in VARCHAR2 DEFAULT NULL);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_STYLESHEET_APP_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_STYLE_CLASS in VARCHAR2,
  X_REPORTING_FLAG in VARCHAR2,
  X_REPORTING_INTERFACE_APP_ID in NUMBER,
  X_REPORTING_INTERFACE_CODE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATE_DOC_LIST_APP_ID in NUMBER DEFAULT NULL,
  X_CREATE_DOC_LIST_CODE in VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_STYLESHEET_APP_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_STYLE_CLASS in VARCHAR2,
  X_REPORTING_FLAG in VARCHAR2,
  X_REPORTING_INTERFACE_APP_ID in NUMBER,
  X_REPORTING_INTERFACE_CODE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATE_DOC_LIST_APP_ID in NUMBER DEFAULT NULL,
  X_CREATE_DOC_LIST_CODE in VARCHAR2 DEFAULT NULL
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW(
  x_layout_asn            in VARCHAR2,
  x_layout_code           in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
);

procedure LOAD_ROW(
  x_layout_asn                  in VARCHAR2,
  x_layout_code                 in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_stylesheet_asn              in VARCHAR2,
  x_stylesheet_code             in VARCHAR2,
  x_integrator_asn              in VARCHAR2,
  x_integrator_code             in VARCHAR2,
  x_style                       in VARCHAR2,
  x_style_class                 in VARCHAR2,
  x_reporting_flag              in VARCHAR2,
  x_reporting_interface_asn     in VARCHAR2,
  x_report_interface_code       in VARCHAR2,
  x_user_name                   in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2,
  x_create_doc_list_asn         in VARCHAR2 DEFAULT NULL,
  x_create_doc_list_code        in VARCHAR2 DEFAULT NULL
);

end BNE_LAYOUTS_PKG;

 

/
