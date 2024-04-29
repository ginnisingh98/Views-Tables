--------------------------------------------------------
--  DDL for Package AMV_I_CONTENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_I_CONTENT_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: amvvcths.pls 120.1 2005/06/22 17:33:39 appldev ship $ */
procedure Load_Row(
  x_content_type_id   in  VARCHAR2,
  x_object_version_number in VARCHAR2,
  x_content_type_name in  VARCHAR2,
  x_description       in  VARCHAR2,
  x_owner             in  varchar2
);
procedure Translate_row (
  x_content_type_id   in  NUMBER,
  x_content_type_name in  VARCHAR2,
  x_description       in  VARCHAR2,
  x_owner             in  varchar2
);

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY  VARCHAR2,
  X_CONTENT_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CONTENT_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_CONTENT_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CONTENT_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_CONTENT_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CONTENT_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_CONTENT_TYPE_ID in NUMBER
);
procedure ADD_LANGUAGE;
end AMV_I_CONTENT_TYPES_PKG;

 

/
