--------------------------------------------------------
--  DDL for Package BNE_DUP_INTERFACE_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_DUP_INTERFACE_PROFILES_PKG" AUTHID CURRENT_USER as
/* $Header: bnedupintprofs.pls 120.2 2005/06/29 03:39:52 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_DUP_PROFILE_APP_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DUP_HANDLING_CODE in VARCHAR2,
  X_DEFAULT_RESOLVER_CLASSNAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_DUP_PROFILE_APP_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DUP_HANDLING_CODE in VARCHAR2,
  X_DEFAULT_RESOLVER_CLASSNAME in VARCHAR2
);

procedure UPDATE_ROW (
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_DUP_PROFILE_APP_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DUP_HANDLING_CODE in VARCHAR2,
  X_DEFAULT_RESOLVER_CLASSNAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_DUP_PROFILE_APP_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW(
  x_interface_asn               in VARCHAR2,
  x_interface_code              in VARCHAR2,
  x_dup_profile_asn             in VARCHAR2,
  x_dup_profile_code            in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_dup_handling_code           in VARCHAR2,
  x_default_resolver_classname  in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
);

end BNE_DUP_INTERFACE_PROFILES_PKG;

 

/
