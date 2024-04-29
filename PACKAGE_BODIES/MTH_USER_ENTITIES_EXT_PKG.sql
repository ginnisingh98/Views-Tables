--------------------------------------------------------
--  DDL for Package Body MTH_USER_ENTITIES_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTH_USER_ENTITIES_EXT_PKG" as
/* $Header: mthuuetlb.pls 120.0.12010000.2 2010/03/04 21:50:52 lvenkatr noship $ */
/*
===========We do not need these procedures for this release==========
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_EXTENSION_ID in NUMBER,
  X_ATTR_GROUP_ID in NUMBER,
  X_SEGMENT_PK_KEY in NUMBER,
  X_C_EXT_ATTR1 in VARCHAR2,
  X_C_EXT_ATTR2 in VARCHAR2,
  X_C_EXT_ATTR3 in VARCHAR2,
  X_C_EXT_ATTR4 in VARCHAR2,
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
  X_D_EXT_ATTR1 in DATE,
  X_D_EXT_ATTR2 in DATE,
  X_D_EXT_ATTR3 in DATE,
  X_D_EXT_ATTR4 in DATE,
  X_D_EXT_ATTR5 in DATE,
  X_D_EXT_ATTR6 in DATE,
  X_D_EXT_ATTR7 in DATE,
  X_D_EXT_ATTR8 in DATE,
  X_D_EXT_ATTR9 in DATE,
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
  X_WORKORDER_FK_KEY in NUMBER,
  X_ITEM_FK_KEY in NUMBER,
  X_TRANSIENT in VARCHAR2,
  X_READ_TIME in DATE,
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
  X_TL_EXT_ATTR11 in VARCHAR2,
  X_TL_EXT_ATTR12 in VARCHAR2,
  X_TL_EXT_ATTR13 in VARCHAR2,
  X_TL_EXT_ATTR14 in VARCHAR2,
  X_TL_EXT_ATTR15 in VARCHAR2,
  X_TL_EXT_ATTR16 in VARCHAR2,
  X_TL_EXT_ATTR17 in VARCHAR2,
  X_TL_EXT_ATTR18 in VARCHAR2,
  X_TL_EXT_ATTR19 in VARCHAR2,
  X_TL_EXT_ATTR20 in VARCHAR2,
  X_TL_EXT_ATTR21 in VARCHAR2,
  X_TL_EXT_ATTR22 in VARCHAR2,
  X_TL_EXT_ATTR23 in VARCHAR2,
  X_TL_EXT_ATTR24 in VARCHAR2,
  X_TL_EXT_ATTR25 in VARCHAR2,
  X_TL_EXT_ATTR26 in VARCHAR2,
  X_TL_EXT_ATTR27 in VARCHAR2,
  X_TL_EXT_ATTR28 in VARCHAR2,
  X_TL_EXT_ATTR29 in VARCHAR2,
  X_TL_EXT_ATTR30 in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from MTH_PRODUCTION_SEGMENTS_EXT_B
    where EXTENSION_ID = X_EXTENSION_ID
    ;
begin
  insert into MTH_PRODUCTION_SEGMENTS_EXT_B (
    EXTENSION_ID,
    ATTR_GROUP_ID,
    SEGMENT_PK_KEY,
    C_EXT_ATTR1,
    C_EXT_ATTR2,
    C_EXT_ATTR3,
    C_EXT_ATTR4,
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
    D_EXT_ATTR1,
    D_EXT_ATTR2,
    D_EXT_ATTR3,
    D_EXT_ATTR4,
    D_EXT_ATTR5,
    D_EXT_ATTR6,
    D_EXT_ATTR7,
    D_EXT_ATTR8,
    D_EXT_ATTR9,
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
    WORKORDER_FK_KEY,
    ITEM_FK_KEY,
    TRANSIENT,
    READ_TIME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_EXTENSION_ID,
    X_ATTR_GROUP_ID,
    X_SEGMENT_PK_KEY,
    X_C_EXT_ATTR1,
    X_C_EXT_ATTR2,
    X_C_EXT_ATTR3,
    X_C_EXT_ATTR4,
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
    X_D_EXT_ATTR1,
    X_D_EXT_ATTR2,
    X_D_EXT_ATTR3,
    X_D_EXT_ATTR4,
    X_D_EXT_ATTR5,
    X_D_EXT_ATTR6,
    X_D_EXT_ATTR7,
    X_D_EXT_ATTR8,
    X_D_EXT_ATTR9,
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
    X_WORKORDER_FK_KEY,
    X_ITEM_FK_KEY,
    X_TRANSIENT,
    X_READ_TIME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into MTH_PRODUCTION_SEGMENTS_EXT_TL (
    EXTENSION_ID,
    ATTR_GROUP_ID,
    SEGMENT_PK_KEY,
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
    TL_EXT_ATTR11,
    TL_EXT_ATTR12,
    TL_EXT_ATTR13,
    TL_EXT_ATTR14,
    TL_EXT_ATTR15,
    TL_EXT_ATTR16,
    TL_EXT_ATTR17,
    TL_EXT_ATTR18,
    TL_EXT_ATTR19,
    TL_EXT_ATTR20,
    TL_EXT_ATTR21,
    TL_EXT_ATTR22,
    TL_EXT_ATTR23,
    TL_EXT_ATTR24,
    TL_EXT_ATTR25,
    TL_EXT_ATTR26,
    TL_EXT_ATTR27,
    TL_EXT_ATTR28,
    TL_EXT_ATTR29,
    TL_EXT_ATTR30,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_EXTENSION_ID,
    X_ATTR_GROUP_ID,
    X_SEGMENT_PK_KEY,
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
    X_TL_EXT_ATTR11,
    X_TL_EXT_ATTR12,
    X_TL_EXT_ATTR13,
    X_TL_EXT_ATTR14,
    X_TL_EXT_ATTR15,
    X_TL_EXT_ATTR16,
    X_TL_EXT_ATTR17,
    X_TL_EXT_ATTR18,
    X_TL_EXT_ATTR19,
    X_TL_EXT_ATTR20,
    X_TL_EXT_ATTR21,
    X_TL_EXT_ATTR22,
    X_TL_EXT_ATTR23,
    X_TL_EXT_ATTR24,
    X_TL_EXT_ATTR25,
    X_TL_EXT_ATTR26,
    X_TL_EXT_ATTR27,
    X_TL_EXT_ATTR28,
    X_TL_EXT_ATTR29,
    X_TL_EXT_ATTR30,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from MTH_PRODUCTION_SEGMENTS_EXT_TL T
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
  X_ATTR_GROUP_ID in NUMBER,
  X_SEGMENT_PK_KEY in NUMBER,
  X_C_EXT_ATTR1 in VARCHAR2,
  X_C_EXT_ATTR2 in VARCHAR2,
  X_C_EXT_ATTR3 in VARCHAR2,
  X_C_EXT_ATTR4 in VARCHAR2,
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
  X_D_EXT_ATTR1 in DATE,
  X_D_EXT_ATTR2 in DATE,
  X_D_EXT_ATTR3 in DATE,
  X_D_EXT_ATTR4 in DATE,
  X_D_EXT_ATTR5 in DATE,
  X_D_EXT_ATTR6 in DATE,
  X_D_EXT_ATTR7 in DATE,
  X_D_EXT_ATTR8 in DATE,
  X_D_EXT_ATTR9 in DATE,
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
  X_WORKORDER_FK_KEY in NUMBER,
  X_ITEM_FK_KEY in NUMBER,
  X_TRANSIENT in VARCHAR2,
  X_READ_TIME in DATE,
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
  X_TL_EXT_ATTR11 in VARCHAR2,
  X_TL_EXT_ATTR12 in VARCHAR2,
  X_TL_EXT_ATTR13 in VARCHAR2,
  X_TL_EXT_ATTR14 in VARCHAR2,
  X_TL_EXT_ATTR15 in VARCHAR2,
  X_TL_EXT_ATTR16 in VARCHAR2,
  X_TL_EXT_ATTR17 in VARCHAR2,
  X_TL_EXT_ATTR18 in VARCHAR2,
  X_TL_EXT_ATTR19 in VARCHAR2,
  X_TL_EXT_ATTR20 in VARCHAR2,
  X_TL_EXT_ATTR21 in VARCHAR2,
  X_TL_EXT_ATTR22 in VARCHAR2,
  X_TL_EXT_ATTR23 in VARCHAR2,
  X_TL_EXT_ATTR24 in VARCHAR2,
  X_TL_EXT_ATTR25 in VARCHAR2,
  X_TL_EXT_ATTR26 in VARCHAR2,
  X_TL_EXT_ATTR27 in VARCHAR2,
  X_TL_EXT_ATTR28 in VARCHAR2,
  X_TL_EXT_ATTR29 in VARCHAR2,
  X_TL_EXT_ATTR30 in VARCHAR2
) is
  cursor c is select
      ATTR_GROUP_ID,
      SEGMENT_PK_KEY,
      C_EXT_ATTR1,
      C_EXT_ATTR2,
      C_EXT_ATTR3,
      C_EXT_ATTR4,
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
      D_EXT_ATTR1,
      D_EXT_ATTR2,
      D_EXT_ATTR3,
      D_EXT_ATTR4,
      D_EXT_ATTR5,
      D_EXT_ATTR6,
      D_EXT_ATTR7,
      D_EXT_ATTR8,
      D_EXT_ATTR9,
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
      WORKORDER_FK_KEY,
      ITEM_FK_KEY,
      TRANSIENT,
      READ_TIME
    from MTH_PRODUCTION_SEGMENTS_EXT_B
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
      TL_EXT_ATTR11,
      TL_EXT_ATTR12,
      TL_EXT_ATTR13,
      TL_EXT_ATTR14,
      TL_EXT_ATTR15,
      TL_EXT_ATTR16,
      TL_EXT_ATTR17,
      TL_EXT_ATTR18,
      TL_EXT_ATTR19,
      TL_EXT_ATTR20,
      TL_EXT_ATTR21,
      TL_EXT_ATTR22,
      TL_EXT_ATTR23,
      TL_EXT_ATTR24,
      TL_EXT_ATTR25,
      TL_EXT_ATTR26,
      TL_EXT_ATTR27,
      TL_EXT_ATTR28,
      TL_EXT_ATTR29,
      TL_EXT_ATTR30,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from MTH_PRODUCTION_SEGMENTS_EXT_TL
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
  if (    ((recinfo.ATTR_GROUP_ID = X_ATTR_GROUP_ID)
           OR ((recinfo.ATTR_GROUP_ID is null) AND (X_ATTR_GROUP_ID is null)))
      AND ((recinfo.SEGMENT_PK_KEY = X_SEGMENT_PK_KEY)
           OR ((recinfo.SEGMENT_PK_KEY is null) AND (X_SEGMENT_PK_KEY is null)))
      AND ((recinfo.C_EXT_ATTR1 = X_C_EXT_ATTR1)
           OR ((recinfo.C_EXT_ATTR1 is null) AND (X_C_EXT_ATTR1 is null)))
      AND ((recinfo.C_EXT_ATTR2 = X_C_EXT_ATTR2)
           OR ((recinfo.C_EXT_ATTR2 is null) AND (X_C_EXT_ATTR2 is null)))
      AND ((recinfo.C_EXT_ATTR3 = X_C_EXT_ATTR3)
           OR ((recinfo.C_EXT_ATTR3 is null) AND (X_C_EXT_ATTR3 is null)))
      AND ((recinfo.C_EXT_ATTR4 = X_C_EXT_ATTR4)
           OR ((recinfo.C_EXT_ATTR4 is null) AND (X_C_EXT_ATTR4 is null)))
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
      AND ((recinfo.D_EXT_ATTR10 = X_D_EXT_ATTR10)
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
      AND ((recinfo.WORKORDER_FK_KEY = X_WORKORDER_FK_KEY)
           OR ((recinfo.WORKORDER_FK_KEY is null) AND (X_WORKORDER_FK_KEY is null)))
      AND ((recinfo.ITEM_FK_KEY = X_ITEM_FK_KEY)
           OR ((recinfo.ITEM_FK_KEY is null) AND (X_ITEM_FK_KEY is null)))
      AND ((recinfo.TRANSIENT = X_TRANSIENT)
           OR ((recinfo.TRANSIENT is null) AND (X_TRANSIENT is null)))
      AND ((recinfo.READ_TIME = X_READ_TIME)
           OR ((recinfo.READ_TIME is null) AND (X_READ_TIME is null)))
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
          AND ((tlinfo.TL_EXT_ATTR11 = X_TL_EXT_ATTR11)
               OR ((tlinfo.TL_EXT_ATTR11 is null) AND (X_TL_EXT_ATTR11 is null)))
          AND ((tlinfo.TL_EXT_ATTR12 = X_TL_EXT_ATTR12)
               OR ((tlinfo.TL_EXT_ATTR12 is null) AND (X_TL_EXT_ATTR12 is null)))
          AND ((tlinfo.TL_EXT_ATTR13 = X_TL_EXT_ATTR13)
               OR ((tlinfo.TL_EXT_ATTR13 is null) AND (X_TL_EXT_ATTR13 is null)))
          AND ((tlinfo.TL_EXT_ATTR14 = X_TL_EXT_ATTR14)
               OR ((tlinfo.TL_EXT_ATTR14 is null) AND (X_TL_EXT_ATTR14 is null)))
          AND ((tlinfo.TL_EXT_ATTR15 = X_TL_EXT_ATTR15)
               OR ((tlinfo.TL_EXT_ATTR15 is null) AND (X_TL_EXT_ATTR15 is null)))
          AND ((tlinfo.TL_EXT_ATTR16 = X_TL_EXT_ATTR16)
               OR ((tlinfo.TL_EXT_ATTR16 is null) AND (X_TL_EXT_ATTR16 is null)))
          AND ((tlinfo.TL_EXT_ATTR17 = X_TL_EXT_ATTR17)
               OR ((tlinfo.TL_EXT_ATTR17 is null) AND (X_TL_EXT_ATTR17 is null)))
          AND ((tlinfo.TL_EXT_ATTR18 = X_TL_EXT_ATTR18)
               OR ((tlinfo.TL_EXT_ATTR18 is null) AND (X_TL_EXT_ATTR18 is null)))
          AND ((tlinfo.TL_EXT_ATTR19 = X_TL_EXT_ATTR19)
               OR ((tlinfo.TL_EXT_ATTR19 is null) AND (X_TL_EXT_ATTR19 is null)))
          AND ((tlinfo.TL_EXT_ATTR20 = X_TL_EXT_ATTR20)
               OR ((tlinfo.TL_EXT_ATTR20 is null) AND (X_TL_EXT_ATTR20 is null)))
          AND ((tlinfo.TL_EXT_ATTR21 = X_TL_EXT_ATTR21)
               OR ((tlinfo.TL_EXT_ATTR21 is null) AND (X_TL_EXT_ATTR21 is null)))
          AND ((tlinfo.TL_EXT_ATTR22 = X_TL_EXT_ATTR22)
               OR ((tlinfo.TL_EXT_ATTR22 is null) AND (X_TL_EXT_ATTR22 is null)))
          AND ((tlinfo.TL_EXT_ATTR23 = X_TL_EXT_ATTR23)
               OR ((tlinfo.TL_EXT_ATTR23 is null) AND (X_TL_EXT_ATTR23 is null)))
          AND ((tlinfo.TL_EXT_ATTR24 = X_TL_EXT_ATTR24)
               OR ((tlinfo.TL_EXT_ATTR24 is null) AND (X_TL_EXT_ATTR24 is null)))
          AND ((tlinfo.TL_EXT_ATTR25 = X_TL_EXT_ATTR25)
               OR ((tlinfo.TL_EXT_ATTR25 is null) AND (X_TL_EXT_ATTR25 is null)))
          AND ((tlinfo.TL_EXT_ATTR26 = X_TL_EXT_ATTR26)
               OR ((tlinfo.TL_EXT_ATTR26 is null) AND (X_TL_EXT_ATTR26 is null)))
          AND ((tlinfo.TL_EXT_ATTR27 = X_TL_EXT_ATTR27)
               OR ((tlinfo.TL_EXT_ATTR27 is null) AND (X_TL_EXT_ATTR27 is null)))
          AND ((tlinfo.TL_EXT_ATTR28 = X_TL_EXT_ATTR28)
               OR ((tlinfo.TL_EXT_ATTR28 is null) AND (X_TL_EXT_ATTR28 is null)))
          AND ((tlinfo.TL_EXT_ATTR29 = X_TL_EXT_ATTR29)
               OR ((tlinfo.TL_EXT_ATTR29 is null) AND (X_TL_EXT_ATTR29 is null)))
          AND ((tlinfo.TL_EXT_ATTR30 = X_TL_EXT_ATTR30)
               OR ((tlinfo.TL_EXT_ATTR30 is null) AND (X_TL_EXT_ATTR30 is null)))
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
  X_ATTR_GROUP_ID in NUMBER,
  X_SEGMENT_PK_KEY in NUMBER,
  X_C_EXT_ATTR1 in VARCHAR2,
  X_C_EXT_ATTR2 in VARCHAR2,
  X_C_EXT_ATTR3 in VARCHAR2,
  X_C_EXT_ATTR4 in VARCHAR2,
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
  X_D_EXT_ATTR1 in DATE,
  X_D_EXT_ATTR2 in DATE,
  X_D_EXT_ATTR3 in DATE,
  X_D_EXT_ATTR4 in DATE,
  X_D_EXT_ATTR5 in DATE,
  X_D_EXT_ATTR6 in DATE,
  X_D_EXT_ATTR7 in DATE,
  X_D_EXT_ATTR8 in DATE,
  X_D_EXT_ATTR9 in DATE,
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
  X_WORKORDER_FK_KEY in NUMBER,
  X_ITEM_FK_KEY in NUMBER,
  X_TRANSIENT in VARCHAR2,
  X_READ_TIME in DATE,
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
  X_TL_EXT_ATTR11 in VARCHAR2,
  X_TL_EXT_ATTR12 in VARCHAR2,
  X_TL_EXT_ATTR13 in VARCHAR2,
  X_TL_EXT_ATTR14 in VARCHAR2,
  X_TL_EXT_ATTR15 in VARCHAR2,
  X_TL_EXT_ATTR16 in VARCHAR2,
  X_TL_EXT_ATTR17 in VARCHAR2,
  X_TL_EXT_ATTR18 in VARCHAR2,
  X_TL_EXT_ATTR19 in VARCHAR2,
  X_TL_EXT_ATTR20 in VARCHAR2,
  X_TL_EXT_ATTR21 in VARCHAR2,
  X_TL_EXT_ATTR22 in VARCHAR2,
  X_TL_EXT_ATTR23 in VARCHAR2,
  X_TL_EXT_ATTR24 in VARCHAR2,
  X_TL_EXT_ATTR25 in VARCHAR2,
  X_TL_EXT_ATTR26 in VARCHAR2,
  X_TL_EXT_ATTR27 in VARCHAR2,
  X_TL_EXT_ATTR28 in VARCHAR2,
  X_TL_EXT_ATTR29 in VARCHAR2,
  X_TL_EXT_ATTR30 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update MTH_PRODUCTION_SEGMENTS_EXT_B set
    ATTR_GROUP_ID = X_ATTR_GROUP_ID,
    SEGMENT_PK_KEY = X_SEGMENT_PK_KEY,
    C_EXT_ATTR1 = X_C_EXT_ATTR1,
    C_EXT_ATTR2 = X_C_EXT_ATTR2,
    C_EXT_ATTR3 = X_C_EXT_ATTR3,
    C_EXT_ATTR4 = X_C_EXT_ATTR4,
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
    D_EXT_ATTR1 = X_D_EXT_ATTR1,
    D_EXT_ATTR2 = X_D_EXT_ATTR2,
    D_EXT_ATTR3 = X_D_EXT_ATTR3,
    D_EXT_ATTR4 = X_D_EXT_ATTR4,
    D_EXT_ATTR5 = X_D_EXT_ATTR5,
    D_EXT_ATTR6 = X_D_EXT_ATTR6,
    D_EXT_ATTR7 = X_D_EXT_ATTR7,
    D_EXT_ATTR8 = X_D_EXT_ATTR8,
    D_EXT_ATTR9 = X_D_EXT_ATTR9,
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
    WORKORDER_FK_KEY = X_WORKORDER_FK_KEY,
    ITEM_FK_KEY = X_ITEM_FK_KEY,
    TRANSIENT = X_TRANSIENT,
    READ_TIME = X_READ_TIME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where EXTENSION_ID = X_EXTENSION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update MTH_PRODUCTION_SEGMENTS_EXT_TL set
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
    TL_EXT_ATTR11 = X_TL_EXT_ATTR11,
    TL_EXT_ATTR12 = X_TL_EXT_ATTR12,
    TL_EXT_ATTR13 = X_TL_EXT_ATTR13,
    TL_EXT_ATTR14 = X_TL_EXT_ATTR14,
    TL_EXT_ATTR15 = X_TL_EXT_ATTR15,
    TL_EXT_ATTR16 = X_TL_EXT_ATTR16,
    TL_EXT_ATTR17 = X_TL_EXT_ATTR17,
    TL_EXT_ATTR18 = X_TL_EXT_ATTR18,
    TL_EXT_ATTR19 = X_TL_EXT_ATTR19,
    TL_EXT_ATTR20 = X_TL_EXT_ATTR20,
    TL_EXT_ATTR21 = X_TL_EXT_ATTR21,
    TL_EXT_ATTR22 = X_TL_EXT_ATTR22,
    TL_EXT_ATTR23 = X_TL_EXT_ATTR23,
    TL_EXT_ATTR24 = X_TL_EXT_ATTR24,
    TL_EXT_ATTR25 = X_TL_EXT_ATTR25,
    TL_EXT_ATTR26 = X_TL_EXT_ATTR26,
    TL_EXT_ATTR27 = X_TL_EXT_ATTR27,
    TL_EXT_ATTR28 = X_TL_EXT_ATTR28,
    TL_EXT_ATTR29 = X_TL_EXT_ATTR29,
    TL_EXT_ATTR30 = X_TL_EXT_ATTR30,
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
  delete from MTH_PRODUCTION_SEGMENTS_EXT_TL
  where EXTENSION_ID = X_EXTENSION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from MTH_PRODUCTION_SEGMENTS_EXT_B
  where EXTENSION_ID = X_EXTENSION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
 =========We do not need the procedures commented above for this release ============
*/

procedure ADD_LANGUAGE
is
begin
  delete from MTH_USER_ENTITIES_EXT_TL T
  where not exists
    (select NULL
    from MTH_USER_ENTITIES_EXT_TL B
    where B.EXTENSION_ID = T.EXTENSION_ID
    );

  update MTH_USER_ENTITIES_EXT_TL T set (
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
      TL_EXT_ATTR11,
      TL_EXT_ATTR12,
      TL_EXT_ATTR13,
      TL_EXT_ATTR14,
      TL_EXT_ATTR15,
      TL_EXT_ATTR16,
      TL_EXT_ATTR17,
      TL_EXT_ATTR18,
      TL_EXT_ATTR19,
      TL_EXT_ATTR20,
      TL_EXT_ATTR21,
      TL_EXT_ATTR22,
      TL_EXT_ATTR23,
      TL_EXT_ATTR24,
      TL_EXT_ATTR25,
      TL_EXT_ATTR26,
      TL_EXT_ATTR27,
      TL_EXT_ATTR28,
      TL_EXT_ATTR29,
      TL_EXT_ATTR30
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
      B.TL_EXT_ATTR10,
      B.TL_EXT_ATTR11,
      B.TL_EXT_ATTR12,
      B.TL_EXT_ATTR13,
      B.TL_EXT_ATTR14,
      B.TL_EXT_ATTR15,
      B.TL_EXT_ATTR16,
      B.TL_EXT_ATTR17,
      B.TL_EXT_ATTR18,
      B.TL_EXT_ATTR19,
      B.TL_EXT_ATTR20,
      B.TL_EXT_ATTR21,
      B.TL_EXT_ATTR22,
      B.TL_EXT_ATTR23,
      B.TL_EXT_ATTR24,
      B.TL_EXT_ATTR25,
      B.TL_EXT_ATTR26,
      B.TL_EXT_ATTR27,
      B.TL_EXT_ATTR28,
      B.TL_EXT_ATTR29,
      B.TL_EXT_ATTR30
    from MTH_USER_ENTITIES_EXT_TL B
    where B.EXTENSION_ID = T.EXTENSION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXTENSION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXTENSION_ID,
      SUBT.LANGUAGE
    from MTH_USER_ENTITIES_EXT_TL SUBB, MTH_USER_ENTITIES_EXT_TL SUBT
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
      or SUBB.TL_EXT_ATTR11 <> SUBT.TL_EXT_ATTR11
      or (SUBB.TL_EXT_ATTR11 is null and SUBT.TL_EXT_ATTR11 is not null)
      or (SUBB.TL_EXT_ATTR11 is not null and SUBT.TL_EXT_ATTR11 is null)
      or SUBB.TL_EXT_ATTR12 <> SUBT.TL_EXT_ATTR12
      or (SUBB.TL_EXT_ATTR12 is null and SUBT.TL_EXT_ATTR12 is not null)
      or (SUBB.TL_EXT_ATTR12 is not null and SUBT.TL_EXT_ATTR12 is null)
      or SUBB.TL_EXT_ATTR13 <> SUBT.TL_EXT_ATTR13
      or (SUBB.TL_EXT_ATTR13 is null and SUBT.TL_EXT_ATTR13 is not null)
      or (SUBB.TL_EXT_ATTR13 is not null and SUBT.TL_EXT_ATTR13 is null)
      or SUBB.TL_EXT_ATTR14 <> SUBT.TL_EXT_ATTR14
      or (SUBB.TL_EXT_ATTR14 is null and SUBT.TL_EXT_ATTR14 is not null)
      or (SUBB.TL_EXT_ATTR14 is not null and SUBT.TL_EXT_ATTR14 is null)
      or SUBB.TL_EXT_ATTR15 <> SUBT.TL_EXT_ATTR15
      or (SUBB.TL_EXT_ATTR15 is null and SUBT.TL_EXT_ATTR15 is not null)
      or (SUBB.TL_EXT_ATTR15 is not null and SUBT.TL_EXT_ATTR15 is null)
      or SUBB.TL_EXT_ATTR16 <> SUBT.TL_EXT_ATTR16
      or (SUBB.TL_EXT_ATTR16 is null and SUBT.TL_EXT_ATTR16 is not null)
      or (SUBB.TL_EXT_ATTR16 is not null and SUBT.TL_EXT_ATTR16 is null)
      or SUBB.TL_EXT_ATTR17 <> SUBT.TL_EXT_ATTR17
      or (SUBB.TL_EXT_ATTR17 is null and SUBT.TL_EXT_ATTR17 is not null)
      or (SUBB.TL_EXT_ATTR17 is not null and SUBT.TL_EXT_ATTR17 is null)
      or SUBB.TL_EXT_ATTR18 <> SUBT.TL_EXT_ATTR18
      or (SUBB.TL_EXT_ATTR18 is null and SUBT.TL_EXT_ATTR18 is not null)
      or (SUBB.TL_EXT_ATTR18 is not null and SUBT.TL_EXT_ATTR18 is null)
      or SUBB.TL_EXT_ATTR19 <> SUBT.TL_EXT_ATTR19
      or (SUBB.TL_EXT_ATTR19 is null and SUBT.TL_EXT_ATTR19 is not null)
      or (SUBB.TL_EXT_ATTR19 is not null and SUBT.TL_EXT_ATTR19 is null)
      or SUBB.TL_EXT_ATTR20 <> SUBT.TL_EXT_ATTR20
      or (SUBB.TL_EXT_ATTR20 is null and SUBT.TL_EXT_ATTR20 is not null)
      or (SUBB.TL_EXT_ATTR20 is not null and SUBT.TL_EXT_ATTR20 is null)
      or SUBB.TL_EXT_ATTR21 <> SUBT.TL_EXT_ATTR21
      or (SUBB.TL_EXT_ATTR21 is null and SUBT.TL_EXT_ATTR21 is not null)
      or (SUBB.TL_EXT_ATTR21 is not null and SUBT.TL_EXT_ATTR21 is null)
      or SUBB.TL_EXT_ATTR22 <> SUBT.TL_EXT_ATTR22
      or (SUBB.TL_EXT_ATTR22 is null and SUBT.TL_EXT_ATTR22 is not null)
      or (SUBB.TL_EXT_ATTR22 is not null and SUBT.TL_EXT_ATTR22 is null)
      or SUBB.TL_EXT_ATTR23 <> SUBT.TL_EXT_ATTR23
      or (SUBB.TL_EXT_ATTR23 is null and SUBT.TL_EXT_ATTR23 is not null)
      or (SUBB.TL_EXT_ATTR23 is not null and SUBT.TL_EXT_ATTR23 is null)
      or SUBB.TL_EXT_ATTR24 <> SUBT.TL_EXT_ATTR24
      or (SUBB.TL_EXT_ATTR24 is null and SUBT.TL_EXT_ATTR24 is not null)
      or (SUBB.TL_EXT_ATTR24 is not null and SUBT.TL_EXT_ATTR24 is null)
      or SUBB.TL_EXT_ATTR25 <> SUBT.TL_EXT_ATTR25
      or (SUBB.TL_EXT_ATTR25 is null and SUBT.TL_EXT_ATTR25 is not null)
      or (SUBB.TL_EXT_ATTR25 is not null and SUBT.TL_EXT_ATTR25 is null)
      or SUBB.TL_EXT_ATTR26 <> SUBT.TL_EXT_ATTR26
      or (SUBB.TL_EXT_ATTR26 is null and SUBT.TL_EXT_ATTR26 is not null)
      or (SUBB.TL_EXT_ATTR26 is not null and SUBT.TL_EXT_ATTR26 is null)
      or SUBB.TL_EXT_ATTR27 <> SUBT.TL_EXT_ATTR27
      or (SUBB.TL_EXT_ATTR27 is null and SUBT.TL_EXT_ATTR27 is not null)
      or (SUBB.TL_EXT_ATTR27 is not null and SUBT.TL_EXT_ATTR27 is null)
      or SUBB.TL_EXT_ATTR28 <> SUBT.TL_EXT_ATTR28
      or (SUBB.TL_EXT_ATTR28 is null and SUBT.TL_EXT_ATTR28 is not null)
      or (SUBB.TL_EXT_ATTR28 is not null and SUBT.TL_EXT_ATTR28 is null)
      or SUBB.TL_EXT_ATTR29 <> SUBT.TL_EXT_ATTR29
      or (SUBB.TL_EXT_ATTR29 is null and SUBT.TL_EXT_ATTR29 is not null)
      or (SUBB.TL_EXT_ATTR29 is not null and SUBT.TL_EXT_ATTR29 is null)
      or SUBB.TL_EXT_ATTR30 <> SUBT.TL_EXT_ATTR30
      or (SUBB.TL_EXT_ATTR30 is null and SUBT.TL_EXT_ATTR30 is not null)
      or (SUBB.TL_EXT_ATTR30 is not null and SUBT.TL_EXT_ATTR30 is null)
  ));

  insert into MTH_USER_ENTITIES_EXT_TL (
    EXTENSION_ID,
    ATTR_GROUP_ID,
    ENTITY_PK_KEY,
    ENTITY_TYPE,
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
    TL_EXT_ATTR11,
    TL_EXT_ATTR12,
    TL_EXT_ATTR13,
    TL_EXT_ATTR14,
    TL_EXT_ATTR15,
    TL_EXT_ATTR16,
    TL_EXT_ATTR17,
    TL_EXT_ATTR18,
    TL_EXT_ATTR19,
    TL_EXT_ATTR20,
    TL_EXT_ATTR21,
    TL_EXT_ATTR22,
    TL_EXT_ATTR23,
    TL_EXT_ATTR24,
    TL_EXT_ATTR25,
    TL_EXT_ATTR26,
    TL_EXT_ATTR27,
    TL_EXT_ATTR28,
    TL_EXT_ATTR29,
    TL_EXT_ATTR30,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.EXTENSION_ID,
    B.ATTR_GROUP_ID,
    B.ENTITY_PK_KEY,
    B.ENTITY_TYPE,
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
    B.TL_EXT_ATTR11,
    B.TL_EXT_ATTR12,
    B.TL_EXT_ATTR13,
    B.TL_EXT_ATTR14,
    B.TL_EXT_ATTR15,
    B.TL_EXT_ATTR16,
    B.TL_EXT_ATTR17,
    B.TL_EXT_ATTR18,
    B.TL_EXT_ATTR19,
    B.TL_EXT_ATTR20,
    B.TL_EXT_ATTR21,
    B.TL_EXT_ATTR22,
    B.TL_EXT_ATTR23,
    B.TL_EXT_ATTR24,
    B.TL_EXT_ATTR25,
    B.TL_EXT_ATTR26,
    B.TL_EXT_ATTR27,
    B.TL_EXT_ATTR28,
    B.TL_EXT_ATTR29,
    B.TL_EXT_ATTR30,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from MTH_USER_ENTITIES_EXT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from MTH_USER_ENTITIES_EXT_TL T
    where T.EXTENSION_ID = B.EXTENSION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end MTH_USER_ENTITIES_EXT_PKG;

/
