--------------------------------------------------------
--  DDL for Package FND_FLEX_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_HIERARCHIES_PKG" AUTHID CURRENT_USER as
/* $Header: AFFFHIRS.pls 120.2.12010000.1 2008/07/25 14:14:02 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_HIERARCHY_ID in NUMBER,
  X_HIERARCHY_CODE in VARCHAR2,
  X_HIERARCHY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_HIERARCHY_ID in NUMBER,
  X_HIERARCHY_CODE in VARCHAR2,
  X_HIERARCHY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_HIERARCHY_ID in NUMBER,
  X_HIERARCHY_CODE in VARCHAR2,
  X_HIERARCHY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_HIERARCHY_ID in NUMBER
);
procedure ADD_LANGUAGE;

PROCEDURE load_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_hierarchy_code               IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_hierarchy_name               IN VARCHAR2,
   x_description                  IN VARCHAR2);

PROCEDURE translate_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_hierarchy_code               IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_hierarchy_name               IN VARCHAR2,
   x_description                  IN VARCHAR2);

end FND_FLEX_HIERARCHIES_PKG;

/
