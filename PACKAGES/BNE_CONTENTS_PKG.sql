--------------------------------------------------------
--  DDL for Package BNE_CONTENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_CONTENTS_PKG" AUTHID CURRENT_USER as
/* $Header: bnecnts.pls 120.2 2005/06/29 03:39:45 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_PARAM_LIST_APP_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_CONTENT_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ONCE_ONLY_DOWNLOAD_FLAG in VARCHAR2 DEFAULT 'N'
);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_PARAM_LIST_APP_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_CONTENT_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_ONCE_ONLY_DOWNLOAD_FLAG in VARCHAR2 DEFAULT 'N'
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_PARAM_LIST_APP_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_CONTENT_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ONCE_ONLY_DOWNLOAD_FLAG in VARCHAR2 DEFAULT 'N'
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW(
  x_content_asn           in VARCHAR2,
  x_content_code          in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
);
procedure LOAD_ROW(
  x_content_asn             in VARCHAR2,
  x_content_code            in VARCHAR2,
  x_object_version_number   in VARCHAR2,
  x_integrator_asn          in VARCHAR2,
  x_integrator_code         in VARCHAR2,
  x_param_list_asn          in VARCHAR2,
  x_param_list_code         in VARCHAR2,
  x_content_class           in VARCHAR2,
  x_user_name               in VARCHAR2,
  x_owner                   in VARCHAR2,
  x_last_update_date        in VARCHAR2,
  x_custom_mode             in VARCHAR2,
  x_once_only_download_flag in VARCHAR2 DEFAULT 'N'
);

end BNE_CONTENTS_PKG;

 

/
