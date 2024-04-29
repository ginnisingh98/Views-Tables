--------------------------------------------------------
--  DDL for Package BNE_CACHE_DIRECTIVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_CACHE_DIRECTIVES_PKG" AUTHID CURRENT_USER as
/* $Header: bnecads.pls 120.3 2005/06/29 03:39:42 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY  VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DIRECTIVE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MAX_AGE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_MAX_HITS in NUMBER,
  X_DISCRIMINATOR_TYPE in VARCHAR2,
  X_DISCRIMINATOR_VALUE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DIRECTIVE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MAX_AGE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_MAX_HITS in NUMBER,
  X_DISCRIMINATOR_TYPE in VARCHAR2,
  X_DISCRIMINATOR_VALUE in VARCHAR2,
  X_USER_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DIRECTIVE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MAX_AGE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_MAX_HITS in NUMBER,
  X_DISCRIMINATOR_TYPE in VARCHAR2,
  X_DISCRIMINATOR_VALUE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DIRECTIVE_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  x_directive_asn         in VARCHAR2,
  x_directive_code        in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
);
procedure LOAD_ROW(
  x_directive_asn               in VARCHAR2,
  x_directive_code              in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_max_age                     in VARCHAR2,
  x_max_size                    in NUMBER,
  x_max_hits                    in NUMBER,
  x_discriminator_type          in VARCHAR2,
  x_discriminator_value         in VARCHAR2,
  x_user_name                   in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
);

end BNE_CACHE_DIRECTIVES_PKG;

 

/
