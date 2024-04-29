--------------------------------------------------------
--  DDL for Package Body XDP_SERVICE_PKG_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_SERVICE_PKG_DET_PKG" as
/* $Header: XDPSPKDB.pls 120.1 2005/06/16 02:34:07 appldev  $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_PACKAGE_ID in NUMBER,
  X_SERVICE_ID in NUMBER,
  X_PROV_REQUIRED_FLAG in VARCHAR2,
  X_ACTIVATION_SEQUENCE in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  null;
end INSERT_ROW;

procedure LOCK_ROW (
  X_PACKAGE_ID in NUMBER,
  X_SERVICE_ID in NUMBER,
  X_PROV_REQUIRED_FLAG in VARCHAR2,
  X_ACTIVATION_SEQUENCE in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
begin
  null;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_PACKAGE_ID in NUMBER,
  X_SERVICE_ID in NUMBER,
  X_PROV_REQUIRED_FLAG in VARCHAR2,
  X_ACTIVATION_SEQUENCE in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  null;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PACKAGE_ID in NUMBER,
  X_SERVICE_ID in NUMBER
) is
begin
  null;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  null;
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_PACKAGE_ID in NUMBER,
  X_SERVICE_ID in NUMBER,
  X_PROV_REQUIRED_FLAG in VARCHAR2,
  X_ACTIVATION_SEQUENCE in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin
  null;
end LOAD_ROW;

procedure TRANSLATE_ROW (
   X_PACKAGE_ID in NUMBER,
   X_SERVICE_ID in NUMBER,
   X_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2) IS
begin
  null;
end TRANSLATE_ROW;

end XDP_SERVICE_PKG_DET_PKG;

/
