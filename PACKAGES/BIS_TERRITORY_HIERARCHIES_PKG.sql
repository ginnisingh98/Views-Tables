--------------------------------------------------------
--  DDL for Package BIS_TERRITORY_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_TERRITORY_HIERARCHIES_PKG" AUTHID CURRENT_USER AS
/* $Header: BISTERHS.pls 115.1 99/07/17 16:10:59 porting shi $ */
/*=======================================================================+
 |  Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 | DESCRIPTION
 |   PL/SQL spec for package:  BIS_TERRITORY_HIERARCHIES_PKG
 *=======================================================================*/

procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_PARENT_TERRITORY_CODE in VARCHAR2,
  X_PARENT_TERRITORY_TYPE in VARCHAR2,
  X_CHILD_TERRITORY_CODE in VARCHAR2,
  X_CHILD_TERRITORY_TYPE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_PARENT_TERRITORY_CODE in VARCHAR2,
  X_PARENT_TERRITORY_TYPE in VARCHAR2,
  X_CHILD_TERRITORY_CODE in VARCHAR2,
  X_CHILD_TERRITORY_TYPE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE
);
procedure UPDATE_ROW (
  X_PARENT_TERRITORY_CODE in VARCHAR2,
  X_PARENT_TERRITORY_TYPE in VARCHAR2,
  X_CHILD_TERRITORY_CODE in VARCHAR2,
  X_CHILD_TERRITORY_TYPE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_PARENT_TERRITORY_CODE in VARCHAR2,
  X_PARENT_TERRITORY_TYPE in VARCHAR2,
  X_CHILD_TERRITORY_CODE in VARCHAR2,
  X_CHILD_TERRITORY_TYPE in VARCHAR2
);
end BIS_TERRITORY_HIERARCHIES_PKG;

 

/
