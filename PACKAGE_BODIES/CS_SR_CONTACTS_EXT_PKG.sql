--------------------------------------------------------
--  DDL for Package Body CS_SR_CONTACTS_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_CONTACTS_EXT_PKG" as
/* $Header: csextapb.pls 120.0 2008/02/01 20:17:43 rtripath noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_EXTENSION_ID in NUMBER,
  X_D_EXT_ATTR10 in DATE,
  X_D_EXT_ATTR11 in DATE,
  X_D_EXT_ATTR12 in DATE,
  X_D_EXT_ATTR13 in DATE,
  X_D_EXT_ATTR14 in DATE,
  X_D_EXT_ATTR15 in DATE,
  X_D_EXT_ATTR16 in DATE,
  X_D_EXT_ATTR17 in DATE,
  X_D_EXT_ATTR18 in DATE,
  X_D_EXT_ATTR19 in DATE,
  X_D_EXT_ATTR20 in DATE,
  X_D_EXT_ATTR21 in DATE,
  X_D_EXT_ATTR22 in DATE,
  X_D_EXT_ATTR23 in DATE,
  X_D_EXT_ATTR24 in DATE,
  X_D_EXT_ATTR25 in DATE,
  X_UOM_EXT_ATTR1 in VARCHAR2,
  X_UOM_EXT_ATTR2 in VARCHAR2,
  X_UOM_EXT_ATTR3 in VARCHAR2,
  X_UOM_EXT_ATTR4 in VARCHAR2,
  X_UOM_EXT_ATTR5 in VARCHAR2,
  X_UOM_EXT_ATTR6 in VARCHAR2,
  X_UOM_EXT_ATTR7 in VARCHAR2,
  X_UOM_EXT_ATTR8 in VARCHAR2,
  X_UOM_EXT_ATTR9 in VARCHAR2,
  X_UOM_EXT_ATTR10 in VARCHAR2,
  X_UOM_EXT_ATTR11 in VARCHAR2,
  X_UOM_EXT_ATTR12 in VARCHAR2,
  X_UOM_EXT_ATTR13 in VARCHAR2,
  X_UOM_EXT_ATTR14 in VARCHAR2,
  X_UOM_EXT_ATTR15 in VARCHAR2,
  X_UOM_EXT_ATTR16 in VARCHAR2,
  X_UOM_EXT_ATTR17 in VARCHAR2,
  X_UOM_EXT_ATTR18 in VARCHAR2,
  X_UOM_EXT_ATTR19 in VARCHAR2,
  X_UOM_EXT_ATTR20 in VARCHAR2,
  X_UOM_EXT_ATTR21 in VARCHAR2,
  X_UOM_EXT_ATTR22 in VARCHAR2,
  X_UOM_EXT_ATTR23 in VARCHAR2,
  X_UOM_EXT_ATTR24 in VARCHAR2,
  X_UOM_EXT_ATTR25 in VARCHAR2,
  X_PARTY_ID in NUMBER,
  X_CONTACT_TYPE in VARCHAR2,
  X_PARTY_ROLE_CODE in VARCHAR2,
  X_C_EXT_ATTR5 in VARCHAR2,
  X_C_EXT_ATTR6 in VARCHAR2,
  X_C_EXT_ATTR7 in VARCHAR2,
  X_C_EXT_ATTR8 in VARCHAR2,
  X_C_EXT_ATTR9 in VARCHAR2,
  X_C_EXT_ATTR10 in VARCHAR2,
  X_C_EXT_ATTR11 in VARCHAR2,
  X_C_EXT_ATTR12 in VARCHAR2,
  X_C_EXT_ATTR13 in VARCHAR2,
  X_C_EXT_ATTR14 in VARCHAR2,
  X_C_EXT_ATTR15 in VARCHAR2,
  X_C_EXT_ATTR16 in VARCHAR2,
  X_C_EXT_ATTR17 in VARCHAR2,
  X_C_EXT_ATTR18 in VARCHAR2,
  X_C_EXT_ATTR19 in VARCHAR2,
  X_C_EXT_ATTR20 in VARCHAR2,
  X_C_EXT_ATTR21 in VARCHAR2,
  X_C_EXT_ATTR22 in VARCHAR2,
  X_C_EXT_ATTR23 in VARCHAR2,
  X_C_EXT_ATTR24 in VARCHAR2,
  X_C_EXT_ATTR25 in VARCHAR2,
  X_C_EXT_ATTR26 in VARCHAR2,
  X_C_EXT_ATTR27 in VARCHAR2,
  X_C_EXT_ATTR28 in VARCHAR2,
  X_C_EXT_ATTR29 in VARCHAR2,
  X_C_EXT_ATTR30 in VARCHAR2,
  X_C_EXT_ATTR31 in VARCHAR2,
  X_C_EXT_ATTR32 in VARCHAR2,
  X_C_EXT_ATTR33 in VARCHAR2,
  X_C_EXT_ATTR34 in VARCHAR2,
  X_C_EXT_ATTR35 in VARCHAR2,
  X_C_EXT_ATTR36 in VARCHAR2,
  X_C_EXT_ATTR37 in VARCHAR2,
  X_C_EXT_ATTR38 in VARCHAR2,
  X_C_EXT_ATTR39 in VARCHAR2,
  X_C_EXT_ATTR40 in VARCHAR2,
  X_C_EXT_ATTR41 in VARCHAR2,
  X_C_EXT_ATTR42 in VARCHAR2,
  X_C_EXT_ATTR43 in VARCHAR2,
  X_C_EXT_ATTR44 in VARCHAR2,
  X_C_EXT_ATTR45 in VARCHAR2,
  X_C_EXT_ATTR46 in VARCHAR2,
  X_C_EXT_ATTR47 in VARCHAR2,
  X_C_EXT_ATTR48 in VARCHAR2,
  X_C_EXT_ATTR49 in VARCHAR2,
  X_C_EXT_ATTR50 in VARCHAR2,
  X_N_EXT_ATTR1 in NUMBER,
  X_N_EXT_ATTR2 in NUMBER,
  X_N_EXT_ATTR3 in NUMBER,
  X_N_EXT_ATTR4 in NUMBER,
  X_N_EXT_ATTR5 in NUMBER,
  X_N_EXT_ATTR6 in NUMBER,
  X_N_EXT_ATTR7 in NUMBER,
  X_N_EXT_ATTR8 in NUMBER,
  X_N_EXT_ATTR9 in NUMBER,
  X_N_EXT_ATTR10 in NUMBER,
  X_N_EXT_ATTR11 in NUMBER,
  X_N_EXT_ATTR12 in NUMBER,
  X_N_EXT_ATTR13 in NUMBER,
  X_N_EXT_ATTR14 in NUMBER,
  X_N_EXT_ATTR15 in NUMBER,
  X_N_EXT_ATTR16 in NUMBER,
  X_N_EXT_ATTR17 in NUMBER,
  X_N_EXT_ATTR18 in NUMBER,
  X_N_EXT_ATTR19 in NUMBER,
  X_N_EXT_ATTR20 in NUMBER,
  X_N_EXT_ATTR21 in NUMBER,
  X_N_EXT_ATTR22 in NUMBER,
  X_N_EXT_ATTR23 in NUMBER,
  X_N_EXT_ATTR24 in NUMBER,
  X_N_EXT_ATTR25 in NUMBER,
  X_D_EXT_ATTR1 in DATE,
  X_D_EXT_ATTR2 in DATE,
  X_D_EXT_ATTR3 in DATE,
  X_D_EXT_ATTR4 in DATE,
  X_D_EXT_ATTR5 in DATE,
  X_D_EXT_ATTR6 in DATE,
  X_D_EXT_ATTR7 in DATE,
  X_D_EXT_ATTR8 in DATE,
  X_D_EXT_ATTR9 in DATE,
  X_INCIDENT_ID in NUMBER,
  X_CONTEXT in VARCHAR2,
  X_ATTR_GROUP_ID in NUMBER,
  X_C_EXT_ATTR1 in VARCHAR2,
  X_C_EXT_ATTR2 in VARCHAR2,
  X_C_EXT_ATTR3 in VARCHAR2,
  X_C_EXT_ATTR4 in VARCHAR2,
  X_TL_EXT_ATTR1 in VARCHAR2,
  X_TL_EXT_ATTR2 in VARCHAR2,
  X_TL_EXT_ATTR3 in VARCHAR2,
  X_TL_EXT_ATTR4 in VARCHAR2,
  X_TL_EXT_ATTR5 in VARCHAR2,
  X_TL_EXT_ATTR6 in VARCHAR2,
  X_TL_EXT_ATTR7 in VARCHAR2,
  X_TL_EXT_ATTR8 in VARCHAR2,
  X_TL_EXT_ATTR9 in VARCHAR2,
  X_TL_EXT_ATTR10 in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_SR_CONTACTS_EXT_B
    where EXTENSION_ID = X_EXTENSION_ID
    ;
begin
  insert into CS_SR_CONTACTS_EXT_B (
    D_EXT_ATTR10,
    D_EXT_ATTR11,
    D_EXT_ATTR12,
    D_EXT_ATTR13,
    D_EXT_ATTR14,
    D_EXT_ATTR15,
    D_EXT_ATTR16,
    D_EXT_ATTR17,
    D_EXT_ATTR18,
    D_EXT_ATTR19,
    D_EXT_ATTR20,
    D_EXT_ATTR21,
    D_EXT_ATTR22,
    D_EXT_ATTR23,
    D_EXT_ATTR24,
    D_EXT_ATTR25,
    UOM_EXT_ATTR1,
    UOM_EXT_ATTR2,
    UOM_EXT_ATTR3,
    UOM_EXT_ATTR4,
    UOM_EXT_ATTR5,
    UOM_EXT_ATTR6,
    UOM_EXT_ATTR7,
    UOM_EXT_ATTR8,
    UOM_EXT_ATTR9,
    UOM_EXT_ATTR10,
    UOM_EXT_ATTR11,
    UOM_EXT_ATTR12,
    UOM_EXT_ATTR13,
    UOM_EXT_ATTR14,
    UOM_EXT_ATTR15,
    UOM_EXT_ATTR16,
    UOM_EXT_ATTR17,
    UOM_EXT_ATTR18,
    UOM_EXT_ATTR19,
    UOM_EXT_ATTR20,
    UOM_EXT_ATTR21,
    UOM_EXT_ATTR22,
    UOM_EXT_ATTR23,
    UOM_EXT_ATTR24,
    UOM_EXT_ATTR25,
    PARTY_ID,
    CONTACT_TYPE,
    PARTY_ROLE_CODE,
    C_EXT_ATTR5,
    C_EXT_ATTR6,
    C_EXT_ATTR7,
    C_EXT_ATTR8,
    C_EXT_ATTR9,
    C_EXT_ATTR10,
    C_EXT_ATTR11,
    C_EXT_ATTR12,
    C_EXT_ATTR13,
    C_EXT_ATTR14,
    C_EXT_ATTR15,
    C_EXT_ATTR16,
    C_EXT_ATTR17,
    C_EXT_ATTR18,
    C_EXT_ATTR19,
    C_EXT_ATTR20,
    C_EXT_ATTR21,
    C_EXT_ATTR22,
    C_EXT_ATTR23,
    C_EXT_ATTR24,
    C_EXT_ATTR25,
    C_EXT_ATTR26,
    C_EXT_ATTR27,
    C_EXT_ATTR28,
    C_EXT_ATTR29,
    C_EXT_ATTR30,
    C_EXT_ATTR31,
    C_EXT_ATTR32,
    C_EXT_ATTR33,
    C_EXT_ATTR34,
    C_EXT_ATTR35,
    C_EXT_ATTR36,
    C_EXT_ATTR37,
    C_EXT_ATTR38,
    C_EXT_ATTR39,
    C_EXT_ATTR40,
    C_EXT_ATTR41,
    C_EXT_ATTR42,
    C_EXT_ATTR43,
    C_EXT_ATTR44,
    C_EXT_ATTR45,
    C_EXT_ATTR46,
    C_EXT_ATTR47,
    C_EXT_ATTR48,
    C_EXT_ATTR49,
    C_EXT_ATTR50,
    N_EXT_ATTR1,
    N_EXT_ATTR2,
    N_EXT_ATTR3,
    N_EXT_ATTR4,
    N_EXT_ATTR5,
    N_EXT_ATTR6,
    N_EXT_ATTR7,
    N_EXT_ATTR8,
    N_EXT_ATTR9,
    N_EXT_ATTR10,
    N_EXT_ATTR11,
    N_EXT_ATTR12,
    N_EXT_ATTR13,
    N_EXT_ATTR14,
    N_EXT_ATTR15,
    N_EXT_ATTR16,
    N_EXT_ATTR17,
    N_EXT_ATTR18,
    N_EXT_ATTR19,
    N_EXT_ATTR20,
    N_EXT_ATTR21,
    N_EXT_ATTR22,
    N_EXT_ATTR23,
    N_EXT_ATTR24,
    N_EXT_ATTR25,
    D_EXT_ATTR1,
    D_EXT_ATTR2,
    D_EXT_ATTR3,
    D_EXT_ATTR4,
    D_EXT_ATTR5,
    D_EXT_ATTR6,
    D_EXT_ATTR7,
    D_EXT_ATTR8,
    D_EXT_ATTR9,
    EXTENSION_ID,
    INCIDENT_ID,
    CONTEXT,
    ATTR_GROUP_ID,
    C_EXT_ATTR1,
    C_EXT_ATTR2,
    C_EXT_ATTR3,
    C_EXT_ATTR4,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_D_EXT_ATTR10,
    X_D_EXT_ATTR11,
    X_D_EXT_ATTR12,
    X_D_EXT_ATTR13,
    X_D_EXT_ATTR14,
    X_D_EXT_ATTR15,
    X_D_EXT_ATTR16,
    X_D_EXT_ATTR17,
    X_D_EXT_ATTR18,
    X_D_EXT_ATTR19,
    X_D_EXT_ATTR20,
    X_D_EXT_ATTR21,
    X_D_EXT_ATTR22,
    X_D_EXT_ATTR23,
    X_D_EXT_ATTR24,
    X_D_EXT_ATTR25,
    X_UOM_EXT_ATTR1,
    X_UOM_EXT_ATTR2,
    X_UOM_EXT_ATTR3,
    X_UOM_EXT_ATTR4,
    X_UOM_EXT_ATTR5,
    X_UOM_EXT_ATTR6,
    X_UOM_EXT_ATTR7,
    X_UOM_EXT_ATTR8,
    X_UOM_EXT_ATTR9,
    X_UOM_EXT_ATTR10,
    X_UOM_EXT_ATTR11,
    X_UOM_EXT_ATTR12,
    X_UOM_EXT_ATTR13,
    X_UOM_EXT_ATTR14,
    X_UOM_EXT_ATTR15,
    X_UOM_EXT_ATTR16,
    X_UOM_EXT_ATTR17,
    X_UOM_EXT_ATTR18,
    X_UOM_EXT_ATTR19,
    X_UOM_EXT_ATTR20,
    X_UOM_EXT_ATTR21,
    X_UOM_EXT_ATTR22,
    X_UOM_EXT_ATTR23,
    X_UOM_EXT_ATTR24,
    X_UOM_EXT_ATTR25,
    X_PARTY_ID,
    X_CONTACT_TYPE,
    X_PARTY_ROLE_CODE,
    X_C_EXT_ATTR5,
    X_C_EXT_ATTR6,
    X_C_EXT_ATTR7,
    X_C_EXT_ATTR8,
    X_C_EXT_ATTR9,
    X_C_EXT_ATTR10,
    X_C_EXT_ATTR11,
    X_C_EXT_ATTR12,
    X_C_EXT_ATTR13,
    X_C_EXT_ATTR14,
    X_C_EXT_ATTR15,
    X_C_EXT_ATTR16,
    X_C_EXT_ATTR17,
    X_C_EXT_ATTR18,
    X_C_EXT_ATTR19,
    X_C_EXT_ATTR20,
    X_C_EXT_ATTR21,
    X_C_EXT_ATTR22,
    X_C_EXT_ATTR23,
    X_C_EXT_ATTR24,
    X_C_EXT_ATTR25,
    X_C_EXT_ATTR26,
    X_C_EXT_ATTR27,
    X_C_EXT_ATTR28,
    X_C_EXT_ATTR29,
    X_C_EXT_ATTR30,
    X_C_EXT_ATTR31,
    X_C_EXT_ATTR32,
    X_C_EXT_ATTR33,
    X_C_EXT_ATTR34,
    X_C_EXT_ATTR35,
    X_C_EXT_ATTR36,
    X_C_EXT_ATTR37,
    X_C_EXT_ATTR38,
    X_C_EXT_ATTR39,
    X_C_EXT_ATTR40,
    X_C_EXT_ATTR41,
    X_C_EXT_ATTR42,
    X_C_EXT_ATTR43,
    X_C_EXT_ATTR44,
    X_C_EXT_ATTR45,
    X_C_EXT_ATTR46,
    X_C_EXT_ATTR47,
    X_C_EXT_ATTR48,
    X_C_EXT_ATTR49,
    X_C_EXT_ATTR50,
    X_N_EXT_ATTR1,
    X_N_EXT_ATTR2,
    X_N_EXT_ATTR3,
    X_N_EXT_ATTR4,
    X_N_EXT_ATTR5,
    X_N_EXT_ATTR6,
    X_N_EXT_ATTR7,
    X_N_EXT_ATTR8,
    X_N_EXT_ATTR9,
    X_N_EXT_ATTR10,
    X_N_EXT_ATTR11,
    X_N_EXT_ATTR12,
    X_N_EXT_ATTR13,
    X_N_EXT_ATTR14,
    X_N_EXT_ATTR15,
    X_N_EXT_ATTR16,
    X_N_EXT_ATTR17,
    X_N_EXT_ATTR18,
    X_N_EXT_ATTR19,
    X_N_EXT_ATTR20,
    X_N_EXT_ATTR21,
    X_N_EXT_ATTR22,
    X_N_EXT_ATTR23,
    X_N_EXT_ATTR24,
    X_N_EXT_ATTR25,
    X_D_EXT_ATTR1,
    X_D_EXT_ATTR2,
    X_D_EXT_ATTR3,
    X_D_EXT_ATTR4,
    X_D_EXT_ATTR5,
    X_D_EXT_ATTR6,
    X_D_EXT_ATTR7,
    X_D_EXT_ATTR8,
    X_D_EXT_ATTR9,
    X_EXTENSION_ID,
    X_INCIDENT_ID,
    X_CONTEXT,
    X_ATTR_GROUP_ID,
    X_C_EXT_ATTR1,
    X_C_EXT_ATTR2,
    X_C_EXT_ATTR3,
    X_C_EXT_ATTR4,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CS_SR_CONTACTS_EXT_TL (
    PARTY_ROLE_CODE,
    CONTACT_TYPE,
    PARTY_ID,
    EXTENSION_ID,
    INCIDENT_ID,
    CONTEXT,
    ATTR_GROUP_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    TL_EXT_ATTR1,
    TL_EXT_ATTR2,
    TL_EXT_ATTR3,
    TL_EXT_ATTR4,
    TL_EXT_ATTR5,
    TL_EXT_ATTR6,
    TL_EXT_ATTR7,
    TL_EXT_ATTR8,
    TL_EXT_ATTR9,
    TL_EXT_ATTR10,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PARTY_ROLE_CODE,
    X_CONTACT_TYPE,
    X_PARTY_ID,
    X_EXTENSION_ID,
    X_INCIDENT_ID,
    X_CONTEXT,
    X_ATTR_GROUP_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_TL_EXT_ATTR1,
    X_TL_EXT_ATTR2,
    X_TL_EXT_ATTR3,
    X_TL_EXT_ATTR4,
    X_TL_EXT_ATTR5,
    X_TL_EXT_ATTR6,
    X_TL_EXT_ATTR7,
    X_TL_EXT_ATTR8,
    X_TL_EXT_ATTR9,
    X_TL_EXT_ATTR10,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_SR_CONTACTS_EXT_TL T
    where T.EXTENSION_ID = X_EXTENSION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_EXTENSION_ID in NUMBER,
  X_D_EXT_ATTR10 in DATE,
  X_D_EXT_ATTR11 in DATE,
  X_D_EXT_ATTR12 in DATE,
  X_D_EXT_ATTR13 in DATE,
  X_D_EXT_ATTR14 in DATE,
  X_D_EXT_ATTR15 in DATE,
  X_D_EXT_ATTR16 in DATE,
  X_D_EXT_ATTR17 in DATE,
  X_D_EXT_ATTR18 in DATE,
  X_D_EXT_ATTR19 in DATE,
  X_D_EXT_ATTR20 in DATE,
  X_D_EXT_ATTR21 in DATE,
  X_D_EXT_ATTR22 in DATE,
  X_D_EXT_ATTR23 in DATE,
  X_D_EXT_ATTR24 in DATE,
  X_D_EXT_ATTR25 in DATE,
  X_UOM_EXT_ATTR1 in VARCHAR2,
  X_UOM_EXT_ATTR2 in VARCHAR2,
  X_UOM_EXT_ATTR3 in VARCHAR2,
  X_UOM_EXT_ATTR4 in VARCHAR2,
  X_UOM_EXT_ATTR5 in VARCHAR2,
  X_UOM_EXT_ATTR6 in VARCHAR2,
  X_UOM_EXT_ATTR7 in VARCHAR2,
  X_UOM_EXT_ATTR8 in VARCHAR2,
  X_UOM_EXT_ATTR9 in VARCHAR2,
  X_UOM_EXT_ATTR10 in VARCHAR2,
  X_UOM_EXT_ATTR11 in VARCHAR2,
  X_UOM_EXT_ATTR12 in VARCHAR2,
  X_UOM_EXT_ATTR13 in VARCHAR2,
  X_UOM_EXT_ATTR14 in VARCHAR2,
  X_UOM_EXT_ATTR15 in VARCHAR2,
  X_UOM_EXT_ATTR16 in VARCHAR2,
  X_UOM_EXT_ATTR17 in VARCHAR2,
  X_UOM_EXT_ATTR18 in VARCHAR2,
  X_UOM_EXT_ATTR19 in VARCHAR2,
  X_UOM_EXT_ATTR20 in VARCHAR2,
  X_UOM_EXT_ATTR21 in VARCHAR2,
  X_UOM_EXT_ATTR22 in VARCHAR2,
  X_UOM_EXT_ATTR23 in VARCHAR2,
  X_UOM_EXT_ATTR24 in VARCHAR2,
  X_UOM_EXT_ATTR25 in VARCHAR2,
  X_PARTY_ID in NUMBER,
  X_CONTACT_TYPE in VARCHAR2,
  X_PARTY_ROLE_CODE in VARCHAR2,
  X_C_EXT_ATTR5 in VARCHAR2,
  X_C_EXT_ATTR6 in VARCHAR2,
  X_C_EXT_ATTR7 in VARCHAR2,
  X_C_EXT_ATTR8 in VARCHAR2,
  X_C_EXT_ATTR9 in VARCHAR2,
  X_C_EXT_ATTR10 in VARCHAR2,
  X_C_EXT_ATTR11 in VARCHAR2,
  X_C_EXT_ATTR12 in VARCHAR2,
  X_C_EXT_ATTR13 in VARCHAR2,
  X_C_EXT_ATTR14 in VARCHAR2,
  X_C_EXT_ATTR15 in VARCHAR2,
  X_C_EXT_ATTR16 in VARCHAR2,
  X_C_EXT_ATTR17 in VARCHAR2,
  X_C_EXT_ATTR18 in VARCHAR2,
  X_C_EXT_ATTR19 in VARCHAR2,
  X_C_EXT_ATTR20 in VARCHAR2,
  X_C_EXT_ATTR21 in VARCHAR2,
  X_C_EXT_ATTR22 in VARCHAR2,
  X_C_EXT_ATTR23 in VARCHAR2,
  X_C_EXT_ATTR24 in VARCHAR2,
  X_C_EXT_ATTR25 in VARCHAR2,
  X_C_EXT_ATTR26 in VARCHAR2,
  X_C_EXT_ATTR27 in VARCHAR2,
  X_C_EXT_ATTR28 in VARCHAR2,
  X_C_EXT_ATTR29 in VARCHAR2,
  X_C_EXT_ATTR30 in VARCHAR2,
  X_C_EXT_ATTR31 in VARCHAR2,
  X_C_EXT_ATTR32 in VARCHAR2,
  X_C_EXT_ATTR33 in VARCHAR2,
  X_C_EXT_ATTR34 in VARCHAR2,
  X_C_EXT_ATTR35 in VARCHAR2,
  X_C_EXT_ATTR36 in VARCHAR2,
  X_C_EXT_ATTR37 in VARCHAR2,
  X_C_EXT_ATTR38 in VARCHAR2,
  X_C_EXT_ATTR39 in VARCHAR2,
  X_C_EXT_ATTR40 in VARCHAR2,
  X_C_EXT_ATTR41 in VARCHAR2,
  X_C_EXT_ATTR42 in VARCHAR2,
  X_C_EXT_ATTR43 in VARCHAR2,
  X_C_EXT_ATTR44 in VARCHAR2,
  X_C_EXT_ATTR45 in VARCHAR2,
  X_C_EXT_ATTR46 in VARCHAR2,
  X_C_EXT_ATTR47 in VARCHAR2,
  X_C_EXT_ATTR48 in VARCHAR2,
  X_C_EXT_ATTR49 in VARCHAR2,
  X_C_EXT_ATTR50 in VARCHAR2,
  X_N_EXT_ATTR1 in NUMBER,
  X_N_EXT_ATTR2 in NUMBER,
  X_N_EXT_ATTR3 in NUMBER,
  X_N_EXT_ATTR4 in NUMBER,
  X_N_EXT_ATTR5 in NUMBER,
  X_N_EXT_ATTR6 in NUMBER,
  X_N_EXT_ATTR7 in NUMBER,
  X_N_EXT_ATTR8 in NUMBER,
  X_N_EXT_ATTR9 in NUMBER,
  X_N_EXT_ATTR10 in NUMBER,
  X_N_EXT_ATTR11 in NUMBER,
  X_N_EXT_ATTR12 in NUMBER,
  X_N_EXT_ATTR13 in NUMBER,
  X_N_EXT_ATTR14 in NUMBER,
  X_N_EXT_ATTR15 in NUMBER,
  X_N_EXT_ATTR16 in NUMBER,
  X_N_EXT_ATTR17 in NUMBER,
  X_N_EXT_ATTR18 in NUMBER,
  X_N_EXT_ATTR19 in NUMBER,
  X_N_EXT_ATTR20 in NUMBER,
  X_N_EXT_ATTR21 in NUMBER,
  X_N_EXT_ATTR22 in NUMBER,
  X_N_EXT_ATTR23 in NUMBER,
  X_N_EXT_ATTR24 in NUMBER,
  X_N_EXT_ATTR25 in NUMBER,
  X_D_EXT_ATTR1 in DATE,
  X_D_EXT_ATTR2 in DATE,
  X_D_EXT_ATTR3 in DATE,
  X_D_EXT_ATTR4 in DATE,
  X_D_EXT_ATTR5 in DATE,
  X_D_EXT_ATTR6 in DATE,
  X_D_EXT_ATTR7 in DATE,
  X_D_EXT_ATTR8 in DATE,
  X_D_EXT_ATTR9 in DATE,
  X_INCIDENT_ID in NUMBER,
  X_CONTEXT in VARCHAR2,
  X_ATTR_GROUP_ID in NUMBER,
  X_C_EXT_ATTR1 in VARCHAR2,
  X_C_EXT_ATTR2 in VARCHAR2,
  X_C_EXT_ATTR3 in VARCHAR2,
  X_C_EXT_ATTR4 in VARCHAR2,
  X_TL_EXT_ATTR1 in VARCHAR2,
  X_TL_EXT_ATTR2 in VARCHAR2,
  X_TL_EXT_ATTR3 in VARCHAR2,
  X_TL_EXT_ATTR4 in VARCHAR2,
  X_TL_EXT_ATTR5 in VARCHAR2,
  X_TL_EXT_ATTR6 in VARCHAR2,
  X_TL_EXT_ATTR7 in VARCHAR2,
  X_TL_EXT_ATTR8 in VARCHAR2,
  X_TL_EXT_ATTR9 in VARCHAR2,
  X_TL_EXT_ATTR10 in VARCHAR2
) is
  cursor c is select
      D_EXT_ATTR10,
      D_EXT_ATTR11,
      D_EXT_ATTR12,
      D_EXT_ATTR13,
      D_EXT_ATTR14,
      D_EXT_ATTR15,
      D_EXT_ATTR16,
      D_EXT_ATTR17,
      D_EXT_ATTR18,
      D_EXT_ATTR19,
      D_EXT_ATTR20,
      D_EXT_ATTR21,
      D_EXT_ATTR22,
      D_EXT_ATTR23,
      D_EXT_ATTR24,
      D_EXT_ATTR25,
      UOM_EXT_ATTR1,
      UOM_EXT_ATTR2,
      UOM_EXT_ATTR3,
      UOM_EXT_ATTR4,
      UOM_EXT_ATTR5,
      UOM_EXT_ATTR6,
      UOM_EXT_ATTR7,
      UOM_EXT_ATTR8,
      UOM_EXT_ATTR9,
      UOM_EXT_ATTR10,
      UOM_EXT_ATTR11,
      UOM_EXT_ATTR12,
      UOM_EXT_ATTR13,
      UOM_EXT_ATTR14,
      UOM_EXT_ATTR15,
      UOM_EXT_ATTR16,
      UOM_EXT_ATTR17,
      UOM_EXT_ATTR18,
      UOM_EXT_ATTR19,
      UOM_EXT_ATTR20,
      UOM_EXT_ATTR21,
      UOM_EXT_ATTR22,
      UOM_EXT_ATTR23,
      UOM_EXT_ATTR24,
      UOM_EXT_ATTR25,
      PARTY_ID,
      CONTACT_TYPE,
      PARTY_ROLE_CODE,
      C_EXT_ATTR5,
      C_EXT_ATTR6,
      C_EXT_ATTR7,
      C_EXT_ATTR8,
      C_EXT_ATTR9,
      C_EXT_ATTR10,
      C_EXT_ATTR11,
      C_EXT_ATTR12,
      C_EXT_ATTR13,
      C_EXT_ATTR14,
      C_EXT_ATTR15,
      C_EXT_ATTR16,
      C_EXT_ATTR17,
      C_EXT_ATTR18,
      C_EXT_ATTR19,
      C_EXT_ATTR20,
      C_EXT_ATTR21,
      C_EXT_ATTR22,
      C_EXT_ATTR23,
      C_EXT_ATTR24,
      C_EXT_ATTR25,
      C_EXT_ATTR26,
      C_EXT_ATTR27,
      C_EXT_ATTR28,
      C_EXT_ATTR29,
      C_EXT_ATTR30,
      C_EXT_ATTR31,
      C_EXT_ATTR32,
      C_EXT_ATTR33,
      C_EXT_ATTR34,
      C_EXT_ATTR35,
      C_EXT_ATTR36,
      C_EXT_ATTR37,
      C_EXT_ATTR38,
      C_EXT_ATTR39,
      C_EXT_ATTR40,
      C_EXT_ATTR41,
      C_EXT_ATTR42,
      C_EXT_ATTR43,
      C_EXT_ATTR44,
      C_EXT_ATTR45,
      C_EXT_ATTR46,
      C_EXT_ATTR47,
      C_EXT_ATTR48,
      C_EXT_ATTR49,
      C_EXT_ATTR50,
      N_EXT_ATTR1,
      N_EXT_ATTR2,
      N_EXT_ATTR3,
      N_EXT_ATTR4,
      N_EXT_ATTR5,
      N_EXT_ATTR6,
      N_EXT_ATTR7,
      N_EXT_ATTR8,
      N_EXT_ATTR9,
      N_EXT_ATTR10,
      N_EXT_ATTR11,
      N_EXT_ATTR12,
      N_EXT_ATTR13,
      N_EXT_ATTR14,
      N_EXT_ATTR15,
      N_EXT_ATTR16,
      N_EXT_ATTR17,
      N_EXT_ATTR18,
      N_EXT_ATTR19,
      N_EXT_ATTR20,
      N_EXT_ATTR21,
      N_EXT_ATTR22,
      N_EXT_ATTR23,
      N_EXT_ATTR24,
      N_EXT_ATTR25,
      D_EXT_ATTR1,
      D_EXT_ATTR2,
      D_EXT_ATTR3,
      D_EXT_ATTR4,
      D_EXT_ATTR5,
      D_EXT_ATTR6,
      D_EXT_ATTR7,
      D_EXT_ATTR8,
      D_EXT_ATTR9,
      INCIDENT_ID,
      CONTEXT,
      ATTR_GROUP_ID,
      C_EXT_ATTR1,
      C_EXT_ATTR2,
      C_EXT_ATTR3,
      C_EXT_ATTR4
    from CS_SR_CONTACTS_EXT_B
    where EXTENSION_ID = X_EXTENSION_ID
    for update of EXTENSION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TL_EXT_ATTR1,
      TL_EXT_ATTR2,
      TL_EXT_ATTR3,
      TL_EXT_ATTR4,
      TL_EXT_ATTR5,
      TL_EXT_ATTR6,
      TL_EXT_ATTR7,
      TL_EXT_ATTR8,
      TL_EXT_ATTR9,
      TL_EXT_ATTR10,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_SR_CONTACTS_EXT_TL
    where EXTENSION_ID = X_EXTENSION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of EXTENSION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.D_EXT_ATTR10 = X_D_EXT_ATTR10)
           OR ((recinfo.D_EXT_ATTR10 is null) AND (X_D_EXT_ATTR10 is null)))
      AND ((recinfo.D_EXT_ATTR11 = X_D_EXT_ATTR11)
           OR ((recinfo.D_EXT_ATTR11 is null) AND (X_D_EXT_ATTR11 is null)))
      AND ((recinfo.D_EXT_ATTR12 = X_D_EXT_ATTR12)
           OR ((recinfo.D_EXT_ATTR12 is null) AND (X_D_EXT_ATTR12 is null)))
      AND ((recinfo.D_EXT_ATTR13 = X_D_EXT_ATTR13)
           OR ((recinfo.D_EXT_ATTR13 is null) AND (X_D_EXT_ATTR13 is null)))
      AND ((recinfo.D_EXT_ATTR14 = X_D_EXT_ATTR14)
           OR ((recinfo.D_EXT_ATTR14 is null) AND (X_D_EXT_ATTR14 is null)))
      AND ((recinfo.D_EXT_ATTR15 = X_D_EXT_ATTR15)
           OR ((recinfo.D_EXT_ATTR15 is null) AND (X_D_EXT_ATTR15 is null)))
      AND ((recinfo.D_EXT_ATTR16 = X_D_EXT_ATTR16)
           OR ((recinfo.D_EXT_ATTR16 is null) AND (X_D_EXT_ATTR16 is null)))
      AND ((recinfo.D_EXT_ATTR17 = X_D_EXT_ATTR17)
           OR ((recinfo.D_EXT_ATTR17 is null) AND (X_D_EXT_ATTR17 is null)))
      AND ((recinfo.D_EXT_ATTR18 = X_D_EXT_ATTR18)
           OR ((recinfo.D_EXT_ATTR18 is null) AND (X_D_EXT_ATTR18 is null)))
      AND ((recinfo.D_EXT_ATTR19 = X_D_EXT_ATTR19)
           OR ((recinfo.D_EXT_ATTR19 is null) AND (X_D_EXT_ATTR19 is null)))
      AND ((recinfo.D_EXT_ATTR20 = X_D_EXT_ATTR20)
           OR ((recinfo.D_EXT_ATTR20 is null) AND (X_D_EXT_ATTR20 is null)))
      AND ((recinfo.D_EXT_ATTR21 = X_D_EXT_ATTR21)
           OR ((recinfo.D_EXT_ATTR21 is null) AND (X_D_EXT_ATTR21 is null)))
      AND ((recinfo.D_EXT_ATTR22 = X_D_EXT_ATTR22)
           OR ((recinfo.D_EXT_ATTR22 is null) AND (X_D_EXT_ATTR22 is null)))
      AND ((recinfo.D_EXT_ATTR23 = X_D_EXT_ATTR23)
           OR ((recinfo.D_EXT_ATTR23 is null) AND (X_D_EXT_ATTR23 is null)))
      AND ((recinfo.D_EXT_ATTR24 = X_D_EXT_ATTR24)
           OR ((recinfo.D_EXT_ATTR24 is null) AND (X_D_EXT_ATTR24 is null)))
      AND ((recinfo.D_EXT_ATTR25 = X_D_EXT_ATTR25)
           OR ((recinfo.D_EXT_ATTR25 is null) AND (X_D_EXT_ATTR25 is null)))
      AND ((recinfo.UOM_EXT_ATTR1 = X_UOM_EXT_ATTR1)
           OR ((recinfo.UOM_EXT_ATTR1 is null) AND (X_UOM_EXT_ATTR1 is null)))
      AND ((recinfo.UOM_EXT_ATTR2 = X_UOM_EXT_ATTR2)
           OR ((recinfo.UOM_EXT_ATTR2 is null) AND (X_UOM_EXT_ATTR2 is null)))
      AND ((recinfo.UOM_EXT_ATTR3 = X_UOM_EXT_ATTR3)
           OR ((recinfo.UOM_EXT_ATTR3 is null) AND (X_UOM_EXT_ATTR3 is null)))
      AND ((recinfo.UOM_EXT_ATTR4 = X_UOM_EXT_ATTR4)
           OR ((recinfo.UOM_EXT_ATTR4 is null) AND (X_UOM_EXT_ATTR4 is null)))
      AND ((recinfo.UOM_EXT_ATTR5 = X_UOM_EXT_ATTR5)
           OR ((recinfo.UOM_EXT_ATTR5 is null) AND (X_UOM_EXT_ATTR5 is null)))
      AND ((recinfo.UOM_EXT_ATTR6 = X_UOM_EXT_ATTR6)
           OR ((recinfo.UOM_EXT_ATTR6 is null) AND (X_UOM_EXT_ATTR6 is null)))
      AND ((recinfo.UOM_EXT_ATTR7 = X_UOM_EXT_ATTR7)
           OR ((recinfo.UOM_EXT_ATTR7 is null) AND (X_UOM_EXT_ATTR7 is null)))
      AND ((recinfo.UOM_EXT_ATTR8 = X_UOM_EXT_ATTR8)
           OR ((recinfo.UOM_EXT_ATTR8 is null) AND (X_UOM_EXT_ATTR8 is null)))
      AND ((recinfo.UOM_EXT_ATTR9 = X_UOM_EXT_ATTR9)
           OR ((recinfo.UOM_EXT_ATTR9 is null) AND (X_UOM_EXT_ATTR9 is null)))
      AND ((recinfo.UOM_EXT_ATTR10 = X_UOM_EXT_ATTR10)
           OR ((recinfo.UOM_EXT_ATTR10 is null) AND (X_UOM_EXT_ATTR10 is null)))
      AND ((recinfo.UOM_EXT_ATTR11 = X_UOM_EXT_ATTR11)
           OR ((recinfo.UOM_EXT_ATTR11 is null) AND (X_UOM_EXT_ATTR11 is null)))
      AND ((recinfo.UOM_EXT_ATTR12 = X_UOM_EXT_ATTR12)
           OR ((recinfo.UOM_EXT_ATTR12 is null) AND (X_UOM_EXT_ATTR12 is null)))
      AND ((recinfo.UOM_EXT_ATTR13 = X_UOM_EXT_ATTR13)
           OR ((recinfo.UOM_EXT_ATTR13 is null) AND (X_UOM_EXT_ATTR13 is null)))
      AND ((recinfo.UOM_EXT_ATTR14 = X_UOM_EXT_ATTR14)
           OR ((recinfo.UOM_EXT_ATTR14 is null) AND (X_UOM_EXT_ATTR14 is null)))
      AND ((recinfo.UOM_EXT_ATTR15 = X_UOM_EXT_ATTR15)
           OR ((recinfo.UOM_EXT_ATTR15 is null) AND (X_UOM_EXT_ATTR15 is null)))
      AND ((recinfo.UOM_EXT_ATTR16 = X_UOM_EXT_ATTR16)
           OR ((recinfo.UOM_EXT_ATTR16 is null) AND (X_UOM_EXT_ATTR16 is null)))
      AND ((recinfo.UOM_EXT_ATTR17 = X_UOM_EXT_ATTR17)
           OR ((recinfo.UOM_EXT_ATTR17 is null) AND (X_UOM_EXT_ATTR17 is null)))
      AND ((recinfo.UOM_EXT_ATTR18 = X_UOM_EXT_ATTR18)
           OR ((recinfo.UOM_EXT_ATTR18 is null) AND (X_UOM_EXT_ATTR18 is null)))
      AND ((recinfo.UOM_EXT_ATTR19 = X_UOM_EXT_ATTR19)
           OR ((recinfo.UOM_EXT_ATTR19 is null) AND (X_UOM_EXT_ATTR19 is null)))
      AND ((recinfo.UOM_EXT_ATTR20 = X_UOM_EXT_ATTR20)
           OR ((recinfo.UOM_EXT_ATTR20 is null) AND (X_UOM_EXT_ATTR20 is null)))
      AND ((recinfo.UOM_EXT_ATTR21 = X_UOM_EXT_ATTR21)
           OR ((recinfo.UOM_EXT_ATTR21 is null) AND (X_UOM_EXT_ATTR21 is null)))
      AND ((recinfo.UOM_EXT_ATTR22 = X_UOM_EXT_ATTR22)
           OR ((recinfo.UOM_EXT_ATTR22 is null) AND (X_UOM_EXT_ATTR22 is null)))
      AND ((recinfo.UOM_EXT_ATTR23 = X_UOM_EXT_ATTR23)
           OR ((recinfo.UOM_EXT_ATTR23 is null) AND (X_UOM_EXT_ATTR23 is null)))
      AND ((recinfo.UOM_EXT_ATTR24 = X_UOM_EXT_ATTR24)
           OR ((recinfo.UOM_EXT_ATTR24 is null) AND (X_UOM_EXT_ATTR24 is null)))
      AND ((recinfo.UOM_EXT_ATTR25 = X_UOM_EXT_ATTR25)
           OR ((recinfo.UOM_EXT_ATTR25 is null) AND (X_UOM_EXT_ATTR25 is null)))
      AND (recinfo.PARTY_ID = X_PARTY_ID)
      AND (recinfo.CONTACT_TYPE = X_CONTACT_TYPE)
      AND (recinfo.PARTY_ROLE_CODE = X_PARTY_ROLE_CODE)
      AND ((recinfo.C_EXT_ATTR5 = X_C_EXT_ATTR5)
           OR ((recinfo.C_EXT_ATTR5 is null) AND (X_C_EXT_ATTR5 is null)))
      AND ((recinfo.C_EXT_ATTR6 = X_C_EXT_ATTR6)
           OR ((recinfo.C_EXT_ATTR6 is null) AND (X_C_EXT_ATTR6 is null)))
      AND ((recinfo.C_EXT_ATTR7 = X_C_EXT_ATTR7)
           OR ((recinfo.C_EXT_ATTR7 is null) AND (X_C_EXT_ATTR7 is null)))
      AND ((recinfo.C_EXT_ATTR8 = X_C_EXT_ATTR8)
           OR ((recinfo.C_EXT_ATTR8 is null) AND (X_C_EXT_ATTR8 is null)))
      AND ((recinfo.C_EXT_ATTR9 = X_C_EXT_ATTR9)
           OR ((recinfo.C_EXT_ATTR9 is null) AND (X_C_EXT_ATTR9 is null)))
      AND ((recinfo.C_EXT_ATTR10 = X_C_EXT_ATTR10)
           OR ((recinfo.C_EXT_ATTR10 is null) AND (X_C_EXT_ATTR10 is null)))
      AND ((recinfo.C_EXT_ATTR11 = X_C_EXT_ATTR11)
           OR ((recinfo.C_EXT_ATTR11 is null) AND (X_C_EXT_ATTR11 is null)))
      AND ((recinfo.C_EXT_ATTR12 = X_C_EXT_ATTR12)
           OR ((recinfo.C_EXT_ATTR12 is null) AND (X_C_EXT_ATTR12 is null)))
      AND ((recinfo.C_EXT_ATTR13 = X_C_EXT_ATTR13)
           OR ((recinfo.C_EXT_ATTR13 is null) AND (X_C_EXT_ATTR13 is null)))
      AND ((recinfo.C_EXT_ATTR14 = X_C_EXT_ATTR14)
           OR ((recinfo.C_EXT_ATTR14 is null) AND (X_C_EXT_ATTR14 is null)))
      AND ((recinfo.C_EXT_ATTR15 = X_C_EXT_ATTR15)
           OR ((recinfo.C_EXT_ATTR15 is null) AND (X_C_EXT_ATTR15 is null)))
      AND ((recinfo.C_EXT_ATTR16 = X_C_EXT_ATTR16)
           OR ((recinfo.C_EXT_ATTR16 is null) AND (X_C_EXT_ATTR16 is null)))
      AND ((recinfo.C_EXT_ATTR17 = X_C_EXT_ATTR17)
           OR ((recinfo.C_EXT_ATTR17 is null) AND (X_C_EXT_ATTR17 is null)))
      AND ((recinfo.C_EXT_ATTR18 = X_C_EXT_ATTR18)
           OR ((recinfo.C_EXT_ATTR18 is null) AND (X_C_EXT_ATTR18 is null)))
      AND ((recinfo.C_EXT_ATTR19 = X_C_EXT_ATTR19)
           OR ((recinfo.C_EXT_ATTR19 is null) AND (X_C_EXT_ATTR19 is null)))
      AND ((recinfo.C_EXT_ATTR20 = X_C_EXT_ATTR20)
           OR ((recinfo.C_EXT_ATTR20 is null) AND (X_C_EXT_ATTR20 is null)))
      AND ((recinfo.C_EXT_ATTR21 = X_C_EXT_ATTR21)
           OR ((recinfo.C_EXT_ATTR21 is null) AND (X_C_EXT_ATTR21 is null)))
      AND ((recinfo.C_EXT_ATTR22 = X_C_EXT_ATTR22)
           OR ((recinfo.C_EXT_ATTR22 is null) AND (X_C_EXT_ATTR22 is null)))
      AND ((recinfo.C_EXT_ATTR23 = X_C_EXT_ATTR23)
           OR ((recinfo.C_EXT_ATTR23 is null) AND (X_C_EXT_ATTR23 is null)))
      AND ((recinfo.C_EXT_ATTR24 = X_C_EXT_ATTR24)
           OR ((recinfo.C_EXT_ATTR24 is null) AND (X_C_EXT_ATTR24 is null)))
      AND ((recinfo.C_EXT_ATTR25 = X_C_EXT_ATTR25)
           OR ((recinfo.C_EXT_ATTR25 is null) AND (X_C_EXT_ATTR25 is null)))
      AND ((recinfo.C_EXT_ATTR26 = X_C_EXT_ATTR26)
           OR ((recinfo.C_EXT_ATTR26 is null) AND (X_C_EXT_ATTR26 is null)))
      AND ((recinfo.C_EXT_ATTR27 = X_C_EXT_ATTR27)
           OR ((recinfo.C_EXT_ATTR27 is null) AND (X_C_EXT_ATTR27 is null)))
      AND ((recinfo.C_EXT_ATTR28 = X_C_EXT_ATTR28)
           OR ((recinfo.C_EXT_ATTR28 is null) AND (X_C_EXT_ATTR28 is null)))
      AND ((recinfo.C_EXT_ATTR29 = X_C_EXT_ATTR29)
           OR ((recinfo.C_EXT_ATTR29 is null) AND (X_C_EXT_ATTR29 is null)))
      AND ((recinfo.C_EXT_ATTR30 = X_C_EXT_ATTR30)
           OR ((recinfo.C_EXT_ATTR30 is null) AND (X_C_EXT_ATTR30 is null)))
      AND ((recinfo.C_EXT_ATTR31 = X_C_EXT_ATTR31)
           OR ((recinfo.C_EXT_ATTR31 is null) AND (X_C_EXT_ATTR31 is null)))
      AND ((recinfo.C_EXT_ATTR32 = X_C_EXT_ATTR32)
           OR ((recinfo.C_EXT_ATTR32 is null) AND (X_C_EXT_ATTR32 is null)))
      AND ((recinfo.C_EXT_ATTR33 = X_C_EXT_ATTR33)
           OR ((recinfo.C_EXT_ATTR33 is null) AND (X_C_EXT_ATTR33 is null)))
      AND ((recinfo.C_EXT_ATTR34 = X_C_EXT_ATTR34)
           OR ((recinfo.C_EXT_ATTR34 is null) AND (X_C_EXT_ATTR34 is null)))
      AND ((recinfo.C_EXT_ATTR35 = X_C_EXT_ATTR35)
           OR ((recinfo.C_EXT_ATTR35 is null) AND (X_C_EXT_ATTR35 is null)))
      AND ((recinfo.C_EXT_ATTR36 = X_C_EXT_ATTR36)
           OR ((recinfo.C_EXT_ATTR36 is null) AND (X_C_EXT_ATTR36 is null)))
      AND ((recinfo.C_EXT_ATTR37 = X_C_EXT_ATTR37)
           OR ((recinfo.C_EXT_ATTR37 is null) AND (X_C_EXT_ATTR37 is null)))
      AND ((recinfo.C_EXT_ATTR38 = X_C_EXT_ATTR38)
           OR ((recinfo.C_EXT_ATTR38 is null) AND (X_C_EXT_ATTR38 is null)))
      AND ((recinfo.C_EXT_ATTR39 = X_C_EXT_ATTR39)
           OR ((recinfo.C_EXT_ATTR39 is null) AND (X_C_EXT_ATTR39 is null)))
      AND ((recinfo.C_EXT_ATTR40 = X_C_EXT_ATTR40)
           OR ((recinfo.C_EXT_ATTR40 is null) AND (X_C_EXT_ATTR40 is null)))
      AND ((recinfo.C_EXT_ATTR41 = X_C_EXT_ATTR41)
           OR ((recinfo.C_EXT_ATTR41 is null) AND (X_C_EXT_ATTR41 is null)))
      AND ((recinfo.C_EXT_ATTR42 = X_C_EXT_ATTR42)
           OR ((recinfo.C_EXT_ATTR42 is null) AND (X_C_EXT_ATTR42 is null)))
      AND ((recinfo.C_EXT_ATTR43 = X_C_EXT_ATTR43)
           OR ((recinfo.C_EXT_ATTR43 is null) AND (X_C_EXT_ATTR43 is null)))
      AND ((recinfo.C_EXT_ATTR44 = X_C_EXT_ATTR44)
           OR ((recinfo.C_EXT_ATTR44 is null) AND (X_C_EXT_ATTR44 is null)))
      AND ((recinfo.C_EXT_ATTR45 = X_C_EXT_ATTR45)
           OR ((recinfo.C_EXT_ATTR45 is null) AND (X_C_EXT_ATTR45 is null)))
      AND ((recinfo.C_EXT_ATTR46 = X_C_EXT_ATTR46)
           OR ((recinfo.C_EXT_ATTR46 is null) AND (X_C_EXT_ATTR46 is null)))
      AND ((recinfo.C_EXT_ATTR47 = X_C_EXT_ATTR47)
           OR ((recinfo.C_EXT_ATTR47 is null) AND (X_C_EXT_ATTR47 is null)))
      AND ((recinfo.C_EXT_ATTR48 = X_C_EXT_ATTR48)
           OR ((recinfo.C_EXT_ATTR48 is null) AND (X_C_EXT_ATTR48 is null)))
      AND ((recinfo.C_EXT_ATTR49 = X_C_EXT_ATTR49)
           OR ((recinfo.C_EXT_ATTR49 is null) AND (X_C_EXT_ATTR49 is null)))
      AND ((recinfo.C_EXT_ATTR50 = X_C_EXT_ATTR50)
           OR ((recinfo.C_EXT_ATTR50 is null) AND (X_C_EXT_ATTR50 is null)))
      AND ((recinfo.N_EXT_ATTR1 = X_N_EXT_ATTR1)
           OR ((recinfo.N_EXT_ATTR1 is null) AND (X_N_EXT_ATTR1 is null)))
      AND ((recinfo.N_EXT_ATTR2 = X_N_EXT_ATTR2)
           OR ((recinfo.N_EXT_ATTR2 is null) AND (X_N_EXT_ATTR2 is null)))
      AND ((recinfo.N_EXT_ATTR3 = X_N_EXT_ATTR3)
           OR ((recinfo.N_EXT_ATTR3 is null) AND (X_N_EXT_ATTR3 is null)))
      AND ((recinfo.N_EXT_ATTR4 = X_N_EXT_ATTR4)
           OR ((recinfo.N_EXT_ATTR4 is null) AND (X_N_EXT_ATTR4 is null)))
      AND ((recinfo.N_EXT_ATTR5 = X_N_EXT_ATTR5)
           OR ((recinfo.N_EXT_ATTR5 is null) AND (X_N_EXT_ATTR5 is null)))
      AND ((recinfo.N_EXT_ATTR6 = X_N_EXT_ATTR6)
           OR ((recinfo.N_EXT_ATTR6 is null) AND (X_N_EXT_ATTR6 is null)))
      AND ((recinfo.N_EXT_ATTR7 = X_N_EXT_ATTR7)
           OR ((recinfo.N_EXT_ATTR7 is null) AND (X_N_EXT_ATTR7 is null)))
      AND ((recinfo.N_EXT_ATTR8 = X_N_EXT_ATTR8)
           OR ((recinfo.N_EXT_ATTR8 is null) AND (X_N_EXT_ATTR8 is null)))
      AND ((recinfo.N_EXT_ATTR9 = X_N_EXT_ATTR9)
           OR ((recinfo.N_EXT_ATTR9 is null) AND (X_N_EXT_ATTR9 is null)))
      AND ((recinfo.N_EXT_ATTR10 = X_N_EXT_ATTR10)
           OR ((recinfo.N_EXT_ATTR10 is null) AND (X_N_EXT_ATTR10 is null)))
      AND ((recinfo.N_EXT_ATTR11 = X_N_EXT_ATTR11)
           OR ((recinfo.N_EXT_ATTR11 is null) AND (X_N_EXT_ATTR11 is null)))
      AND ((recinfo.N_EXT_ATTR12 = X_N_EXT_ATTR12)
           OR ((recinfo.N_EXT_ATTR12 is null) AND (X_N_EXT_ATTR12 is null)))
      AND ((recinfo.N_EXT_ATTR13 = X_N_EXT_ATTR13)
           OR ((recinfo.N_EXT_ATTR13 is null) AND (X_N_EXT_ATTR13 is null)))
      AND ((recinfo.N_EXT_ATTR14 = X_N_EXT_ATTR14)
           OR ((recinfo.N_EXT_ATTR14 is null) AND (X_N_EXT_ATTR14 is null)))
      AND ((recinfo.N_EXT_ATTR15 = X_N_EXT_ATTR15)
           OR ((recinfo.N_EXT_ATTR15 is null) AND (X_N_EXT_ATTR15 is null)))
      AND ((recinfo.N_EXT_ATTR16 = X_N_EXT_ATTR16)
           OR ((recinfo.N_EXT_ATTR16 is null) AND (X_N_EXT_ATTR16 is null)))
      AND ((recinfo.N_EXT_ATTR17 = X_N_EXT_ATTR17)
           OR ((recinfo.N_EXT_ATTR17 is null) AND (X_N_EXT_ATTR17 is null)))
      AND ((recinfo.N_EXT_ATTR18 = X_N_EXT_ATTR18)
           OR ((recinfo.N_EXT_ATTR18 is null) AND (X_N_EXT_ATTR18 is null)))
      AND ((recinfo.N_EXT_ATTR19 = X_N_EXT_ATTR19)
           OR ((recinfo.N_EXT_ATTR19 is null) AND (X_N_EXT_ATTR19 is null)))
      AND ((recinfo.N_EXT_ATTR20 = X_N_EXT_ATTR20)
           OR ((recinfo.N_EXT_ATTR20 is null) AND (X_N_EXT_ATTR20 is null)))
      AND ((recinfo.N_EXT_ATTR21 = X_N_EXT_ATTR21)
           OR ((recinfo.N_EXT_ATTR21 is null) AND (X_N_EXT_ATTR21 is null)))
      AND ((recinfo.N_EXT_ATTR22 = X_N_EXT_ATTR22)
           OR ((recinfo.N_EXT_ATTR22 is null) AND (X_N_EXT_ATTR22 is null)))
      AND ((recinfo.N_EXT_ATTR23 = X_N_EXT_ATTR23)
           OR ((recinfo.N_EXT_ATTR23 is null) AND (X_N_EXT_ATTR23 is null)))
      AND ((recinfo.N_EXT_ATTR24 = X_N_EXT_ATTR24)
           OR ((recinfo.N_EXT_ATTR24 is null) AND (X_N_EXT_ATTR24 is null)))
      AND ((recinfo.N_EXT_ATTR25 = X_N_EXT_ATTR25)
           OR ((recinfo.N_EXT_ATTR25 is null) AND (X_N_EXT_ATTR25 is null)))
      AND ((recinfo.D_EXT_ATTR1 = X_D_EXT_ATTR1)
           OR ((recinfo.D_EXT_ATTR1 is null) AND (X_D_EXT_ATTR1 is null)))
      AND ((recinfo.D_EXT_ATTR2 = X_D_EXT_ATTR2)
           OR ((recinfo.D_EXT_ATTR2 is null) AND (X_D_EXT_ATTR2 is null)))
      AND ((recinfo.D_EXT_ATTR3 = X_D_EXT_ATTR3)
           OR ((recinfo.D_EXT_ATTR3 is null) AND (X_D_EXT_ATTR3 is null)))
      AND ((recinfo.D_EXT_ATTR4 = X_D_EXT_ATTR4)
           OR ((recinfo.D_EXT_ATTR4 is null) AND (X_D_EXT_ATTR4 is null)))
      AND ((recinfo.D_EXT_ATTR5 = X_D_EXT_ATTR5)
           OR ((recinfo.D_EXT_ATTR5 is null) AND (X_D_EXT_ATTR5 is null)))
      AND ((recinfo.D_EXT_ATTR6 = X_D_EXT_ATTR6)
           OR ((recinfo.D_EXT_ATTR6 is null) AND (X_D_EXT_ATTR6 is null)))
      AND ((recinfo.D_EXT_ATTR7 = X_D_EXT_ATTR7)
           OR ((recinfo.D_EXT_ATTR7 is null) AND (X_D_EXT_ATTR7 is null)))
      AND ((recinfo.D_EXT_ATTR8 = X_D_EXT_ATTR8)
           OR ((recinfo.D_EXT_ATTR8 is null) AND (X_D_EXT_ATTR8 is null)))
      AND ((recinfo.D_EXT_ATTR9 = X_D_EXT_ATTR9)
           OR ((recinfo.D_EXT_ATTR9 is null) AND (X_D_EXT_ATTR9 is null)))
      AND (recinfo.INCIDENT_ID = X_INCIDENT_ID)
      AND (recinfo.CONTEXT = X_CONTEXT)
      AND (recinfo.ATTR_GROUP_ID = X_ATTR_GROUP_ID)
      AND ((recinfo.C_EXT_ATTR1 = X_C_EXT_ATTR1)
           OR ((recinfo.C_EXT_ATTR1 is null) AND (X_C_EXT_ATTR1 is null)))
      AND ((recinfo.C_EXT_ATTR2 = X_C_EXT_ATTR2)
           OR ((recinfo.C_EXT_ATTR2 is null) AND (X_C_EXT_ATTR2 is null)))
      AND ((recinfo.C_EXT_ATTR3 = X_C_EXT_ATTR3)
           OR ((recinfo.C_EXT_ATTR3 is null) AND (X_C_EXT_ATTR3 is null)))
      AND ((recinfo.C_EXT_ATTR4 = X_C_EXT_ATTR4)
           OR ((recinfo.C_EXT_ATTR4 is null) AND (X_C_EXT_ATTR4 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TL_EXT_ATTR1 = X_TL_EXT_ATTR1)
               OR ((tlinfo.TL_EXT_ATTR1 is null) AND (X_TL_EXT_ATTR1 is null)))
          AND ((tlinfo.TL_EXT_ATTR2 = X_TL_EXT_ATTR2)
               OR ((tlinfo.TL_EXT_ATTR2 is null) AND (X_TL_EXT_ATTR2 is null)))
          AND ((tlinfo.TL_EXT_ATTR3 = X_TL_EXT_ATTR3)
               OR ((tlinfo.TL_EXT_ATTR3 is null) AND (X_TL_EXT_ATTR3 is null)))
          AND ((tlinfo.TL_EXT_ATTR4 = X_TL_EXT_ATTR4)
               OR ((tlinfo.TL_EXT_ATTR4 is null) AND (X_TL_EXT_ATTR4 is null)))
          AND ((tlinfo.TL_EXT_ATTR5 = X_TL_EXT_ATTR5)
               OR ((tlinfo.TL_EXT_ATTR5 is null) AND (X_TL_EXT_ATTR5 is null)))
          AND ((tlinfo.TL_EXT_ATTR6 = X_TL_EXT_ATTR6)
               OR ((tlinfo.TL_EXT_ATTR6 is null) AND (X_TL_EXT_ATTR6 is null)))
          AND ((tlinfo.TL_EXT_ATTR7 = X_TL_EXT_ATTR7)
               OR ((tlinfo.TL_EXT_ATTR7 is null) AND (X_TL_EXT_ATTR7 is null)))
          AND ((tlinfo.TL_EXT_ATTR8 = X_TL_EXT_ATTR8)
               OR ((tlinfo.TL_EXT_ATTR8 is null) AND (X_TL_EXT_ATTR8 is null)))
          AND ((tlinfo.TL_EXT_ATTR9 = X_TL_EXT_ATTR9)
               OR ((tlinfo.TL_EXT_ATTR9 is null) AND (X_TL_EXT_ATTR9 is null)))
          AND ((tlinfo.TL_EXT_ATTR10 = X_TL_EXT_ATTR10)
               OR ((tlinfo.TL_EXT_ATTR10 is null) AND (X_TL_EXT_ATTR10 is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_EXTENSION_ID in NUMBER,
  X_D_EXT_ATTR10 in DATE,
  X_D_EXT_ATTR11 in DATE,
  X_D_EXT_ATTR12 in DATE,
  X_D_EXT_ATTR13 in DATE,
  X_D_EXT_ATTR14 in DATE,
  X_D_EXT_ATTR15 in DATE,
  X_D_EXT_ATTR16 in DATE,
  X_D_EXT_ATTR17 in DATE,
  X_D_EXT_ATTR18 in DATE,
  X_D_EXT_ATTR19 in DATE,
  X_D_EXT_ATTR20 in DATE,
  X_D_EXT_ATTR21 in DATE,
  X_D_EXT_ATTR22 in DATE,
  X_D_EXT_ATTR23 in DATE,
  X_D_EXT_ATTR24 in DATE,
  X_D_EXT_ATTR25 in DATE,
  X_UOM_EXT_ATTR1 in VARCHAR2,
  X_UOM_EXT_ATTR2 in VARCHAR2,
  X_UOM_EXT_ATTR3 in VARCHAR2,
  X_UOM_EXT_ATTR4 in VARCHAR2,
  X_UOM_EXT_ATTR5 in VARCHAR2,
  X_UOM_EXT_ATTR6 in VARCHAR2,
  X_UOM_EXT_ATTR7 in VARCHAR2,
  X_UOM_EXT_ATTR8 in VARCHAR2,
  X_UOM_EXT_ATTR9 in VARCHAR2,
  X_UOM_EXT_ATTR10 in VARCHAR2,
  X_UOM_EXT_ATTR11 in VARCHAR2,
  X_UOM_EXT_ATTR12 in VARCHAR2,
  X_UOM_EXT_ATTR13 in VARCHAR2,
  X_UOM_EXT_ATTR14 in VARCHAR2,
  X_UOM_EXT_ATTR15 in VARCHAR2,
  X_UOM_EXT_ATTR16 in VARCHAR2,
  X_UOM_EXT_ATTR17 in VARCHAR2,
  X_UOM_EXT_ATTR18 in VARCHAR2,
  X_UOM_EXT_ATTR19 in VARCHAR2,
  X_UOM_EXT_ATTR20 in VARCHAR2,
  X_UOM_EXT_ATTR21 in VARCHAR2,
  X_UOM_EXT_ATTR22 in VARCHAR2,
  X_UOM_EXT_ATTR23 in VARCHAR2,
  X_UOM_EXT_ATTR24 in VARCHAR2,
  X_UOM_EXT_ATTR25 in VARCHAR2,
  X_PARTY_ID in NUMBER,
  X_CONTACT_TYPE in VARCHAR2,
  X_PARTY_ROLE_CODE in VARCHAR2,
  X_C_EXT_ATTR5 in VARCHAR2,
  X_C_EXT_ATTR6 in VARCHAR2,
  X_C_EXT_ATTR7 in VARCHAR2,
  X_C_EXT_ATTR8 in VARCHAR2,
  X_C_EXT_ATTR9 in VARCHAR2,
  X_C_EXT_ATTR10 in VARCHAR2,
  X_C_EXT_ATTR11 in VARCHAR2,
  X_C_EXT_ATTR12 in VARCHAR2,
  X_C_EXT_ATTR13 in VARCHAR2,
  X_C_EXT_ATTR14 in VARCHAR2,
  X_C_EXT_ATTR15 in VARCHAR2,
  X_C_EXT_ATTR16 in VARCHAR2,
  X_C_EXT_ATTR17 in VARCHAR2,
  X_C_EXT_ATTR18 in VARCHAR2,
  X_C_EXT_ATTR19 in VARCHAR2,
  X_C_EXT_ATTR20 in VARCHAR2,
  X_C_EXT_ATTR21 in VARCHAR2,
  X_C_EXT_ATTR22 in VARCHAR2,
  X_C_EXT_ATTR23 in VARCHAR2,
  X_C_EXT_ATTR24 in VARCHAR2,
  X_C_EXT_ATTR25 in VARCHAR2,
  X_C_EXT_ATTR26 in VARCHAR2,
  X_C_EXT_ATTR27 in VARCHAR2,
  X_C_EXT_ATTR28 in VARCHAR2,
  X_C_EXT_ATTR29 in VARCHAR2,
  X_C_EXT_ATTR30 in VARCHAR2,
  X_C_EXT_ATTR31 in VARCHAR2,
  X_C_EXT_ATTR32 in VARCHAR2,
  X_C_EXT_ATTR33 in VARCHAR2,
  X_C_EXT_ATTR34 in VARCHAR2,
  X_C_EXT_ATTR35 in VARCHAR2,
  X_C_EXT_ATTR36 in VARCHAR2,
  X_C_EXT_ATTR37 in VARCHAR2,
  X_C_EXT_ATTR38 in VARCHAR2,
  X_C_EXT_ATTR39 in VARCHAR2,
  X_C_EXT_ATTR40 in VARCHAR2,
  X_C_EXT_ATTR41 in VARCHAR2,
  X_C_EXT_ATTR42 in VARCHAR2,
  X_C_EXT_ATTR43 in VARCHAR2,
  X_C_EXT_ATTR44 in VARCHAR2,
  X_C_EXT_ATTR45 in VARCHAR2,
  X_C_EXT_ATTR46 in VARCHAR2,
  X_C_EXT_ATTR47 in VARCHAR2,
  X_C_EXT_ATTR48 in VARCHAR2,
  X_C_EXT_ATTR49 in VARCHAR2,
  X_C_EXT_ATTR50 in VARCHAR2,
  X_N_EXT_ATTR1 in NUMBER,
  X_N_EXT_ATTR2 in NUMBER,
  X_N_EXT_ATTR3 in NUMBER,
  X_N_EXT_ATTR4 in NUMBER,
  X_N_EXT_ATTR5 in NUMBER,
  X_N_EXT_ATTR6 in NUMBER,
  X_N_EXT_ATTR7 in NUMBER,
  X_N_EXT_ATTR8 in NUMBER,
  X_N_EXT_ATTR9 in NUMBER,
  X_N_EXT_ATTR10 in NUMBER,
  X_N_EXT_ATTR11 in NUMBER,
  X_N_EXT_ATTR12 in NUMBER,
  X_N_EXT_ATTR13 in NUMBER,
  X_N_EXT_ATTR14 in NUMBER,
  X_N_EXT_ATTR15 in NUMBER,
  X_N_EXT_ATTR16 in NUMBER,
  X_N_EXT_ATTR17 in NUMBER,
  X_N_EXT_ATTR18 in NUMBER,
  X_N_EXT_ATTR19 in NUMBER,
  X_N_EXT_ATTR20 in NUMBER,
  X_N_EXT_ATTR21 in NUMBER,
  X_N_EXT_ATTR22 in NUMBER,
  X_N_EXT_ATTR23 in NUMBER,
  X_N_EXT_ATTR24 in NUMBER,
  X_N_EXT_ATTR25 in NUMBER,
  X_D_EXT_ATTR1 in DATE,
  X_D_EXT_ATTR2 in DATE,
  X_D_EXT_ATTR3 in DATE,
  X_D_EXT_ATTR4 in DATE,
  X_D_EXT_ATTR5 in DATE,
  X_D_EXT_ATTR6 in DATE,
  X_D_EXT_ATTR7 in DATE,
  X_D_EXT_ATTR8 in DATE,
  X_D_EXT_ATTR9 in DATE,
  X_INCIDENT_ID in NUMBER,
  X_CONTEXT in VARCHAR2,
  X_ATTR_GROUP_ID in NUMBER,
  X_C_EXT_ATTR1 in VARCHAR2,
  X_C_EXT_ATTR2 in VARCHAR2,
  X_C_EXT_ATTR3 in VARCHAR2,
  X_C_EXT_ATTR4 in VARCHAR2,
  X_TL_EXT_ATTR1 in VARCHAR2,
  X_TL_EXT_ATTR2 in VARCHAR2,
  X_TL_EXT_ATTR3 in VARCHAR2,
  X_TL_EXT_ATTR4 in VARCHAR2,
  X_TL_EXT_ATTR5 in VARCHAR2,
  X_TL_EXT_ATTR6 in VARCHAR2,
  X_TL_EXT_ATTR7 in VARCHAR2,
  X_TL_EXT_ATTR8 in VARCHAR2,
  X_TL_EXT_ATTR9 in VARCHAR2,
  X_TL_EXT_ATTR10 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_SR_CONTACTS_EXT_B set
    D_EXT_ATTR10 = X_D_EXT_ATTR10,
    D_EXT_ATTR11 = X_D_EXT_ATTR11,
    D_EXT_ATTR12 = X_D_EXT_ATTR12,
    D_EXT_ATTR13 = X_D_EXT_ATTR13,
    D_EXT_ATTR14 = X_D_EXT_ATTR14,
    D_EXT_ATTR15 = X_D_EXT_ATTR15,
    D_EXT_ATTR16 = X_D_EXT_ATTR16,
    D_EXT_ATTR17 = X_D_EXT_ATTR17,
    D_EXT_ATTR18 = X_D_EXT_ATTR18,
    D_EXT_ATTR19 = X_D_EXT_ATTR19,
    D_EXT_ATTR20 = X_D_EXT_ATTR20,
    D_EXT_ATTR21 = X_D_EXT_ATTR21,
    D_EXT_ATTR22 = X_D_EXT_ATTR22,
    D_EXT_ATTR23 = X_D_EXT_ATTR23,
    D_EXT_ATTR24 = X_D_EXT_ATTR24,
    D_EXT_ATTR25 = X_D_EXT_ATTR25,
    UOM_EXT_ATTR1 = X_UOM_EXT_ATTR1,
    UOM_EXT_ATTR2 = X_UOM_EXT_ATTR2,
    UOM_EXT_ATTR3 = X_UOM_EXT_ATTR3,
    UOM_EXT_ATTR4 = X_UOM_EXT_ATTR4,
    UOM_EXT_ATTR5 = X_UOM_EXT_ATTR5,
    UOM_EXT_ATTR6 = X_UOM_EXT_ATTR6,
    UOM_EXT_ATTR7 = X_UOM_EXT_ATTR7,
    UOM_EXT_ATTR8 = X_UOM_EXT_ATTR8,
    UOM_EXT_ATTR9 = X_UOM_EXT_ATTR9,
    UOM_EXT_ATTR10 = X_UOM_EXT_ATTR10,
    UOM_EXT_ATTR11 = X_UOM_EXT_ATTR11,
    UOM_EXT_ATTR12 = X_UOM_EXT_ATTR12,
    UOM_EXT_ATTR13 = X_UOM_EXT_ATTR13,
    UOM_EXT_ATTR14 = X_UOM_EXT_ATTR14,
    UOM_EXT_ATTR15 = X_UOM_EXT_ATTR15,
    UOM_EXT_ATTR16 = X_UOM_EXT_ATTR16,
    UOM_EXT_ATTR17 = X_UOM_EXT_ATTR17,
    UOM_EXT_ATTR18 = X_UOM_EXT_ATTR18,
    UOM_EXT_ATTR19 = X_UOM_EXT_ATTR19,
    UOM_EXT_ATTR20 = X_UOM_EXT_ATTR20,
    UOM_EXT_ATTR21 = X_UOM_EXT_ATTR21,
    UOM_EXT_ATTR22 = X_UOM_EXT_ATTR22,
    UOM_EXT_ATTR23 = X_UOM_EXT_ATTR23,
    UOM_EXT_ATTR24 = X_UOM_EXT_ATTR24,
    UOM_EXT_ATTR25 = X_UOM_EXT_ATTR25,
    PARTY_ID = X_PARTY_ID,
    CONTACT_TYPE = X_CONTACT_TYPE,
    PARTY_ROLE_CODE = X_PARTY_ROLE_CODE,
    C_EXT_ATTR5 = X_C_EXT_ATTR5,
    C_EXT_ATTR6 = X_C_EXT_ATTR6,
    C_EXT_ATTR7 = X_C_EXT_ATTR7,
    C_EXT_ATTR8 = X_C_EXT_ATTR8,
    C_EXT_ATTR9 = X_C_EXT_ATTR9,
    C_EXT_ATTR10 = X_C_EXT_ATTR10,
    C_EXT_ATTR11 = X_C_EXT_ATTR11,
    C_EXT_ATTR12 = X_C_EXT_ATTR12,
    C_EXT_ATTR13 = X_C_EXT_ATTR13,
    C_EXT_ATTR14 = X_C_EXT_ATTR14,
    C_EXT_ATTR15 = X_C_EXT_ATTR15,
    C_EXT_ATTR16 = X_C_EXT_ATTR16,
    C_EXT_ATTR17 = X_C_EXT_ATTR17,
    C_EXT_ATTR18 = X_C_EXT_ATTR18,
    C_EXT_ATTR19 = X_C_EXT_ATTR19,
    C_EXT_ATTR20 = X_C_EXT_ATTR20,
    C_EXT_ATTR21 = X_C_EXT_ATTR21,
    C_EXT_ATTR22 = X_C_EXT_ATTR22,
    C_EXT_ATTR23 = X_C_EXT_ATTR23,
    C_EXT_ATTR24 = X_C_EXT_ATTR24,
    C_EXT_ATTR25 = X_C_EXT_ATTR25,
    C_EXT_ATTR26 = X_C_EXT_ATTR26,
    C_EXT_ATTR27 = X_C_EXT_ATTR27,
    C_EXT_ATTR28 = X_C_EXT_ATTR28,
    C_EXT_ATTR29 = X_C_EXT_ATTR29,
    C_EXT_ATTR30 = X_C_EXT_ATTR30,
    C_EXT_ATTR31 = X_C_EXT_ATTR31,
    C_EXT_ATTR32 = X_C_EXT_ATTR32,
    C_EXT_ATTR33 = X_C_EXT_ATTR33,
    C_EXT_ATTR34 = X_C_EXT_ATTR34,
    C_EXT_ATTR35 = X_C_EXT_ATTR35,
    C_EXT_ATTR36 = X_C_EXT_ATTR36,
    C_EXT_ATTR37 = X_C_EXT_ATTR37,
    C_EXT_ATTR38 = X_C_EXT_ATTR38,
    C_EXT_ATTR39 = X_C_EXT_ATTR39,
    C_EXT_ATTR40 = X_C_EXT_ATTR40,
    C_EXT_ATTR41 = X_C_EXT_ATTR41,
    C_EXT_ATTR42 = X_C_EXT_ATTR42,
    C_EXT_ATTR43 = X_C_EXT_ATTR43,
    C_EXT_ATTR44 = X_C_EXT_ATTR44,
    C_EXT_ATTR45 = X_C_EXT_ATTR45,
    C_EXT_ATTR46 = X_C_EXT_ATTR46,
    C_EXT_ATTR47 = X_C_EXT_ATTR47,
    C_EXT_ATTR48 = X_C_EXT_ATTR48,
    C_EXT_ATTR49 = X_C_EXT_ATTR49,
    C_EXT_ATTR50 = X_C_EXT_ATTR50,
    N_EXT_ATTR1 = X_N_EXT_ATTR1,
    N_EXT_ATTR2 = X_N_EXT_ATTR2,
    N_EXT_ATTR3 = X_N_EXT_ATTR3,
    N_EXT_ATTR4 = X_N_EXT_ATTR4,
    N_EXT_ATTR5 = X_N_EXT_ATTR5,
    N_EXT_ATTR6 = X_N_EXT_ATTR6,
    N_EXT_ATTR7 = X_N_EXT_ATTR7,
    N_EXT_ATTR8 = X_N_EXT_ATTR8,
    N_EXT_ATTR9 = X_N_EXT_ATTR9,
    N_EXT_ATTR10 = X_N_EXT_ATTR10,
    N_EXT_ATTR11 = X_N_EXT_ATTR11,
    N_EXT_ATTR12 = X_N_EXT_ATTR12,
    N_EXT_ATTR13 = X_N_EXT_ATTR13,
    N_EXT_ATTR14 = X_N_EXT_ATTR14,
    N_EXT_ATTR15 = X_N_EXT_ATTR15,
    N_EXT_ATTR16 = X_N_EXT_ATTR16,
    N_EXT_ATTR17 = X_N_EXT_ATTR17,
    N_EXT_ATTR18 = X_N_EXT_ATTR18,
    N_EXT_ATTR19 = X_N_EXT_ATTR19,
    N_EXT_ATTR20 = X_N_EXT_ATTR20,
    N_EXT_ATTR21 = X_N_EXT_ATTR21,
    N_EXT_ATTR22 = X_N_EXT_ATTR22,
    N_EXT_ATTR23 = X_N_EXT_ATTR23,
    N_EXT_ATTR24 = X_N_EXT_ATTR24,
    N_EXT_ATTR25 = X_N_EXT_ATTR25,
    D_EXT_ATTR1 = X_D_EXT_ATTR1,
    D_EXT_ATTR2 = X_D_EXT_ATTR2,
    D_EXT_ATTR3 = X_D_EXT_ATTR3,
    D_EXT_ATTR4 = X_D_EXT_ATTR4,
    D_EXT_ATTR5 = X_D_EXT_ATTR5,
    D_EXT_ATTR6 = X_D_EXT_ATTR6,
    D_EXT_ATTR7 = X_D_EXT_ATTR7,
    D_EXT_ATTR8 = X_D_EXT_ATTR8,
    D_EXT_ATTR9 = X_D_EXT_ATTR9,
    INCIDENT_ID = X_INCIDENT_ID,
    CONTEXT = X_CONTEXT,
    ATTR_GROUP_ID = X_ATTR_GROUP_ID,
    C_EXT_ATTR1 = X_C_EXT_ATTR1,
    C_EXT_ATTR2 = X_C_EXT_ATTR2,
    C_EXT_ATTR3 = X_C_EXT_ATTR3,
    C_EXT_ATTR4 = X_C_EXT_ATTR4,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where EXTENSION_ID = X_EXTENSION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_SR_CONTACTS_EXT_TL set
    TL_EXT_ATTR1 = X_TL_EXT_ATTR1,
    TL_EXT_ATTR2 = X_TL_EXT_ATTR2,
    TL_EXT_ATTR3 = X_TL_EXT_ATTR3,
    TL_EXT_ATTR4 = X_TL_EXT_ATTR4,
    TL_EXT_ATTR5 = X_TL_EXT_ATTR5,
    TL_EXT_ATTR6 = X_TL_EXT_ATTR6,
    TL_EXT_ATTR7 = X_TL_EXT_ATTR7,
    TL_EXT_ATTR8 = X_TL_EXT_ATTR8,
    TL_EXT_ATTR9 = X_TL_EXT_ATTR9,
    TL_EXT_ATTR10 = X_TL_EXT_ATTR10,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where EXTENSION_ID = X_EXTENSION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_EXTENSION_ID in NUMBER
) is
begin
  delete from CS_SR_CONTACTS_EXT_TL
  where EXTENSION_ID = X_EXTENSION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_SR_CONTACTS_EXT_B
  where EXTENSION_ID = X_EXTENSION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_SR_CONTACTS_EXT_TL T
  where not exists
    (select NULL
    from CS_SR_CONTACTS_EXT_B B
    where B.EXTENSION_ID = T.EXTENSION_ID
    );

  update CS_SR_CONTACTS_EXT_TL T set (
      TL_EXT_ATTR1,
      TL_EXT_ATTR2,
      TL_EXT_ATTR3,
      TL_EXT_ATTR4,
      TL_EXT_ATTR5,
      TL_EXT_ATTR6,
      TL_EXT_ATTR7,
      TL_EXT_ATTR8,
      TL_EXT_ATTR9,
      TL_EXT_ATTR10
    ) = (select
      B.TL_EXT_ATTR1,
      B.TL_EXT_ATTR2,
      B.TL_EXT_ATTR3,
      B.TL_EXT_ATTR4,
      B.TL_EXT_ATTR5,
      B.TL_EXT_ATTR6,
      B.TL_EXT_ATTR7,
      B.TL_EXT_ATTR8,
      B.TL_EXT_ATTR9,
      B.TL_EXT_ATTR10
    from CS_SR_CONTACTS_EXT_TL B
    where B.EXTENSION_ID = T.EXTENSION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXTENSION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXTENSION_ID,
      SUBT.LANGUAGE
    from CS_SR_CONTACTS_EXT_TL SUBB, CS_SR_CONTACTS_EXT_TL SUBT
    where SUBB.EXTENSION_ID = SUBT.EXTENSION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TL_EXT_ATTR1 <> SUBT.TL_EXT_ATTR1
      or (SUBB.TL_EXT_ATTR1 is null and SUBT.TL_EXT_ATTR1 is not null)
      or (SUBB.TL_EXT_ATTR1 is not null and SUBT.TL_EXT_ATTR1 is null)
      or SUBB.TL_EXT_ATTR2 <> SUBT.TL_EXT_ATTR2
      or (SUBB.TL_EXT_ATTR2 is null and SUBT.TL_EXT_ATTR2 is not null)
      or (SUBB.TL_EXT_ATTR2 is not null and SUBT.TL_EXT_ATTR2 is null)
      or SUBB.TL_EXT_ATTR3 <> SUBT.TL_EXT_ATTR3
      or (SUBB.TL_EXT_ATTR3 is null and SUBT.TL_EXT_ATTR3 is not null)
      or (SUBB.TL_EXT_ATTR3 is not null and SUBT.TL_EXT_ATTR3 is null)
      or SUBB.TL_EXT_ATTR4 <> SUBT.TL_EXT_ATTR4
      or (SUBB.TL_EXT_ATTR4 is null and SUBT.TL_EXT_ATTR4 is not null)
      or (SUBB.TL_EXT_ATTR4 is not null and SUBT.TL_EXT_ATTR4 is null)
      or SUBB.TL_EXT_ATTR5 <> SUBT.TL_EXT_ATTR5
      or (SUBB.TL_EXT_ATTR5 is null and SUBT.TL_EXT_ATTR5 is not null)
      or (SUBB.TL_EXT_ATTR5 is not null and SUBT.TL_EXT_ATTR5 is null)
      or SUBB.TL_EXT_ATTR6 <> SUBT.TL_EXT_ATTR6
      or (SUBB.TL_EXT_ATTR6 is null and SUBT.TL_EXT_ATTR6 is not null)
      or (SUBB.TL_EXT_ATTR6 is not null and SUBT.TL_EXT_ATTR6 is null)
      or SUBB.TL_EXT_ATTR7 <> SUBT.TL_EXT_ATTR7
      or (SUBB.TL_EXT_ATTR7 is null and SUBT.TL_EXT_ATTR7 is not null)
      or (SUBB.TL_EXT_ATTR7 is not null and SUBT.TL_EXT_ATTR7 is null)
      or SUBB.TL_EXT_ATTR8 <> SUBT.TL_EXT_ATTR8
      or (SUBB.TL_EXT_ATTR8 is null and SUBT.TL_EXT_ATTR8 is not null)
      or (SUBB.TL_EXT_ATTR8 is not null and SUBT.TL_EXT_ATTR8 is null)
      or SUBB.TL_EXT_ATTR9 <> SUBT.TL_EXT_ATTR9
      or (SUBB.TL_EXT_ATTR9 is null and SUBT.TL_EXT_ATTR9 is not null)
      or (SUBB.TL_EXT_ATTR9 is not null and SUBT.TL_EXT_ATTR9 is null)
      or SUBB.TL_EXT_ATTR10 <> SUBT.TL_EXT_ATTR10
      or (SUBB.TL_EXT_ATTR10 is null and SUBT.TL_EXT_ATTR10 is not null)
      or (SUBB.TL_EXT_ATTR10 is not null and SUBT.TL_EXT_ATTR10 is null)
  ));

  insert into CS_SR_CONTACTS_EXT_TL (
    PARTY_ROLE_CODE,
    CONTACT_TYPE,
    PARTY_ID,
    EXTENSION_ID,
    INCIDENT_ID,
    CONTEXT,
    ATTR_GROUP_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    TL_EXT_ATTR1,
    TL_EXT_ATTR2,
    TL_EXT_ATTR3,
    TL_EXT_ATTR4,
    TL_EXT_ATTR5,
    TL_EXT_ATTR6,
    TL_EXT_ATTR7,
    TL_EXT_ATTR8,
    TL_EXT_ATTR9,
    TL_EXT_ATTR10,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PARTY_ROLE_CODE,
    B.CONTACT_TYPE,
    B.PARTY_ID,
    B.EXTENSION_ID,
    B.INCIDENT_ID,
    B.CONTEXT,
    B.ATTR_GROUP_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.TL_EXT_ATTR1,
    B.TL_EXT_ATTR2,
    B.TL_EXT_ATTR3,
    B.TL_EXT_ATTR4,
    B.TL_EXT_ATTR5,
    B.TL_EXT_ATTR6,
    B.TL_EXT_ATTR7,
    B.TL_EXT_ATTR8,
    B.TL_EXT_ATTR9,
    B.TL_EXT_ATTR10,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_SR_CONTACTS_EXT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_SR_CONTACTS_EXT_TL T
    where T.EXTENSION_ID = B.EXTENSION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CS_SR_CONTACTS_EXT_PKG;

/
