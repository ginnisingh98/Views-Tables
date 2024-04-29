--------------------------------------------------------
--  DDL for Package AZ_STRUCTURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZ_STRUCTURES_PKG" AUTHID CURRENT_USER as
/* $Header: aztstrcts.pls 120.2 2006/01/13 07:40:13 sbandi noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STRUCTURE_CODE in VARCHAR2,
  X_HIERARCHICAL_FLAG in VARCHAR2,
  X_ACTIVE in VARCHAR2,
  X_STRUCTURE_NAME in VARCHAR2,
  X_STRUCTURE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure LOCK_ROW (
  X_STRUCTURE_CODE in VARCHAR2,
  X_HIERARCHICAL_FLAG in VARCHAR2,
  X_STRUCTURE_NAME in VARCHAR2,
  X_STRUCTURE_DESC in VARCHAR2
);

procedure UPDATE_ROW (
  X_STRUCTURE_CODE in VARCHAR2,
  X_HIERARCHICAL_FLAG in VARCHAR2,
  X_ACTIVE in VARCHAR2,
  X_STRUCTURE_NAME in VARCHAR2,
  X_STRUCTURE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_STRUCTURE_CODE in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
        X_STRUCTURE_CODE        in   VARCHAR2,
        X_STRUCTURE_NAME        in   VARCHAR2,
        X_OWNER                 in   VARCHAR2,
        X_STRUCTURE_DESC        in   VARCHAR2
);

procedure LOAD_ROW (
	X_STRUCTURE_CODE        in   VARCHAR2,
        X_OWNER                 in   VARCHAR2,
        X_HIERARCHICAL_FLAG     in   VARCHAR2,
	X_ACTIVE		in   VARCHAR2,
        X_STRUCTURE_NAME        in   VARCHAR2,
        X_STRUCTURE_DESC        in   VARCHAR2
);


end AZ_STRUCTURES_PKG;

 

/