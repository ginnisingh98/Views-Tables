--------------------------------------------------------
--  DDL for Package Body JTF_AE_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AE_METADATA" as
/* $Header: JTFAEMDB.pls 115.5 2002/10/03 22:27:04 kkapur ship $ */
procedure INSERT_ROW (
  X_PROFILE_METADATA_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_SUBSCRIBED_PROFILES_ID in NUMBER,
  X_PROFILEPROPERTIES_ID in NUMBER,
  X_PROFILE_RULES_ID in NUMBER,
  X_DISABLED_FLAG_CODE in VARCHAR2,
  X_MANDATORY_FLAG_CODE in VARCHAR2,
  X_JAVA_DATATYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DEFAULT_VALUE in VARCHAR2,
  X_SQL_VALIDATION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
NULL;
end INSERT_ROW;

procedure LOCK_ROW (
  X_PROFILE_METADATA_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_SUBSCRIBED_PROFILES_ID in NUMBER,
  X_PROFILEPROPERTIES_ID in NUMBER,
  X_PROFILE_RULES_ID in NUMBER,
  X_DISABLED_FLAG_CODE in VARCHAR2,
  X_MANDATORY_FLAG_CODE in VARCHAR2,
  X_JAVA_DATATYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DEFAULT_VALUE in VARCHAR2,
  X_SQL_VALIDATION in VARCHAR2
) is
begin
NULL;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_PROFILE_METADATA_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_SUBSCRIBED_PROFILES_ID in NUMBER,
  X_PROFILEPROPERTIES_ID in NUMBER,
  X_PROFILE_RULES_ID in NUMBER,
  X_DISABLED_FLAG_CODE in VARCHAR2,
  X_MANDATORY_FLAG_CODE in VARCHAR2,
  X_JAVA_DATATYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER ,
  X_DEFAULT_VALUE in VARCHAR2,
  X_SQL_VALIDATION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
NULL;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PROFILE_METADATA_ID in NUMBER
) is
begin
NULL;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
NULL;
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_PROFILE_METADATA_ID in NUMBER,
  X_DEFAULT_VALUE in VARCHAR2,
  X_OWNER in VARCHAR2
)is

begin
NULL;
end TRANSLATE_ROW;

procedure LOAD_ROW(
  X_PROFILE_METADATA_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_SUBSCRIBED_PROFILES_ID in NUMBER,
  X_PROFILEPROPERTIES_ID in NUMBER,
  X_PROFILE_RULES_ID in NUMBER,
  X_DISABLED_FLAG_CODE in VARCHAR2,
  X_MANDATORY_FLAG_CODE in VARCHAR2,
  X_JAVA_DATATYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SQL_VALIDATION in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin
NULL;
end LOAD_ROW;

end JTF_AE_METADATA;

/