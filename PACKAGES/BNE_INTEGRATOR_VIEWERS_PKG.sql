--------------------------------------------------------
--  DDL for Package BNE_INTEGRATOR_VIEWERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_INTEGRATOR_VIEWERS_PKG" AUTHID CURRENT_USER as
/* $Header: bneintviewers.pls 120.0 2005/08/18 07:09:52 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_VIEWER_APP_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_VIEWER_APP_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_VIEWER_APP_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_VIEWER_APP_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW(
  x_integrator_asn              in VARCHAR2,
  x_integrator_code             in VARCHAR2,
  x_viewer_asn                  in VARCHAR2,
  x_viewer_code                 in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
);

end BNE_INTEGRATOR_VIEWERS_PKG;

 

/
