--------------------------------------------------------
--  DDL for Package AMV_I_PERSPECTIVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_I_PERSPECTIVES_PKG" AUTHID CURRENT_USER as
/* $Header: amvvpshs.pls 120.1 2005/06/30 13:06:13 appldev ship $ */
procedure Load_Row(
  x_perspective_id   in  varchar2,
  x_object_version_number in varchar2,
  x_perspective_name in  varchar2,
  x_description      in  varchar2,
  x_owner            in  varchar2
);
--
procedure Translate_row (
  x_perspective_id   in  number,
  x_perspective_name in  varchar2,
  x_description      in  varchar2,
  x_owner            in  varchar2
);
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSPECTIVE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSPECTIVE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_PERSPECTIVE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSPECTIVE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_PERSPECTIVE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSPECTIVE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_PERSPECTIVE_ID in NUMBER
);
procedure ADD_LANGUAGE;
end AMV_I_PERSPECTIVES_PKG;

 

/
