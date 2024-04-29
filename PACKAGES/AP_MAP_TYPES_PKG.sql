--------------------------------------------------------
--  DDL for Package AP_MAP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_MAP_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: apmaptps.pls 115.2 2004/01/29 23:30:50 kmizuta noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT nocopy VARCHAR2,
  X_MAP_TYPE_CODE in VARCHAR2,
  X_FROM_APPLICATION_ID in NUMBER,
  X_FROM_LOOKUP_TYPE in VARCHAR2,
  X_TO_APPLICATION_ID in NUMBER,
  X_TO_LOOKUP_TYPE in VARCHAR2,
  X_DEFAULT_LOOKUP_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_MAP_TYPE_CODE in VARCHAR2,
  X_FROM_APPLICATION_ID in NUMBER,
  X_FROM_LOOKUP_TYPE in VARCHAR2,
  X_TO_APPLICATION_ID in NUMBER,
  X_TO_LOOKUP_TYPE in VARCHAR2,
  X_DEFAULT_LOOKUP_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_MAP_TYPE_CODE in VARCHAR2,
  X_FROM_APPLICATION_ID in NUMBER,
  X_FROM_LOOKUP_TYPE in VARCHAR2,
  X_TO_APPLICATION_ID in NUMBER,
  X_TO_LOOKUP_TYPE in VARCHAR2,
  X_DEFAULT_LOOKUP_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_MAP_TYPE_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;

--
-- Function to return the destination lookup code
-- for a given source lookup code.
-- If no mapping is found, then the default is returned.
function GET_MAP_TO_CODE(x_map_type_code IN VARCHAR2, x_map_from_code IN VARCHAR2)
    return VARCHAR2;

PROCEDURE CLEAR_DISABLED_CODES(x_map_type_code IN VARCHAR2);

end AP_MAP_TYPES_PKG;

 

/