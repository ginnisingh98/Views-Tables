--------------------------------------------------------
--  DDL for Package CS_SR_CONTACTS_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_CONTACTS_EXT_PKG" AUTHID CURRENT_USER as
/* $Header: csextaps.pls 120.0 2008/02/01 20:16:27 rtripath noship $ */
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
  X_LAST_UPDATE_LOGIN in NUMBER);
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
);
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
);
procedure DELETE_ROW (
  X_EXTENSION_ID in NUMBER
);
procedure ADD_LANGUAGE;
end CS_SR_CONTACTS_EXT_PKG;

/