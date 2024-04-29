--------------------------------------------------------
--  DDL for Package EDW_FORECAST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_FORECAST_PKG" AUTHID CURRENT_USER AS

	FUNCTION get_forecast_fk (
		p_forecast_designator IN VARCHAR2,
		p_organization_id IN NUMBER,
		p_instance_code in VARCHAR2 := NULL) RETURN VARCHAR2;

	PRAGMA RESTRICT_REFERENCES (get_forecast_fk, WNDS, WNPS, RNPS);

END edw_forecast_pkg;


 

/
