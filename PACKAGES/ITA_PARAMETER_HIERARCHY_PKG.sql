--------------------------------------------------------
--  DDL for Package ITA_PARAMETER_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITA_PARAMETER_HIERARCHY_PKG" AUTHID CURRENT_USER as
/* $Header: itatovrs.pls 120.1 2005/08/17 17:52 anmalhot noship $ */


procedure INSERT_ROW (
  x_parameter_code IN VARCHAR2,
  x_override_parameter_code IN VARCHAR2,
  x_override_level IN NUMBER,
  x_creation_date IN DATE,
  x_created_by IN NUMBER,
  x_last_update_date IN DATE,
  x_last_updated_by IN NUMBER,
  x_last_update_login IN NUMBER
);

procedure LOCK_ROW (
  x_parameter_code IN VARCHAR2,
  x_override_parameter_code IN VARCHAR2,
  x_override_level IN NUMBER,
  x_creation_date IN DATE,
  x_created_by IN NUMBER,
  x_last_update_date IN DATE,
  x_last_updated_by IN NUMBER,
  x_last_update_login IN NUMBER
);

procedure UPDATE_ROW (
  x_parameter_code IN VARCHAR2,
  x_override_parameter_code IN VARCHAR2,
  x_override_level IN NUMBER,
  x_last_update_date IN DATE,
  x_last_updated_by IN NUMBER,
  x_last_update_login IN NUMBER
);


procedure DELETE_ROW (
  x_parameter_code IN VARCHAR2,
  x_override_parameter_code IN VARCHAR2
);

procedure LOAD_ROW(
            x_parameter_code in VARCHAR2,
            x_override_parameter_code in VARCHAR2,
		x_override_level in NUMBER,
		x_last_update_date in VARCHAR2,
		x_owner in VARCHAR2,
		x_custom_mode in VARCHAR2
) ;

end ITA_PARAMETER_HIERARCHY_PKG;

 

/
