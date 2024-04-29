--------------------------------------------------------
--  DDL for Package Body EDW_FORECAST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_FORECAST_PKG" AS

	FUNCTION get_forecast_fk (
		p_forecast_designator IN VARCHAR2,
		p_organization_id IN NUMBER,
		p_instance_code in VARCHAR2 := NULL) RETURN VARCHAR2 IS
	l_forecast_fk	VARCHAR2(240) := 'NA_EDW';
	l_instance VARCHAR2(30) := NULL;

	BEGIN
		IF ((p_forecast_designator IS null)  OR (p_organization_id IS null))THEN
			return 'NA_EDW';
		END IF;

		IF (p_instance_code is NOT NULL) then
			l_instance := p_instance_code;
		ELSE
			select instance_code into l_instance
			from edw_local_instance;
		END IF;

		l_forecast_fk := p_forecast_designator || '-' || p_organization_id || '-' || l_instance;

		RETURN(l_forecast_fk);

	EXCEPTION WHEN others THEN
		return 'NA_EDW';
	END get_forecast_fk;
END;

/
