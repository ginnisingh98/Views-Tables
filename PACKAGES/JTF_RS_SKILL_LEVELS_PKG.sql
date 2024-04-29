--------------------------------------------------------
--  DDL for Package JTF_RS_SKILL_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_SKILL_LEVELS_PKG" AUTHID CURRENT_USER as
/* $Header: jtfrshss.pls 120.0 2005/05/11 08:20:11 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SKILL_LEVEL_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_SKILL_LEVEL in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_LEVEL_NAME in VARCHAR2,
  X_LEVEL_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_SKILL_LEVEL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_SKILL_LEVEL_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_SKILL_LEVEL in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_LEVEL_NAME in VARCHAR2,
  X_LEVEL_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_SKILL_LEVEL_ID in NUMBER
);
procedure ADD_LANGUAGE;

Procedure TRANSLATE_ROW
(x_skill_level_id in number,
 x_level_name in varchar2,
 x_level_desc in varchar2,
 x_last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number);

procedure LOAD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SKILL_LEVEL_ID in NUMBER,
  X_SKILL_LEVEL in NUMBER,
  X_LEVEL_NAME in VARCHAR2,
  X_LEVEL_DESC in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OWNER in VARCHAR2
);
end JTF_RS_SKILL_LEVELS_PKG;

 

/
