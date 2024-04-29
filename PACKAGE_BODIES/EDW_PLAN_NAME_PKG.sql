--------------------------------------------------------
--  DDL for Package Body EDW_PLAN_NAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_PLAN_NAME_PKG" AS

	FUNCTION get_plan_name_fk (
		p_compile_designator IN VARCHAR2,
		p_organization_id IN NUMBER,
		p_instance_code in VARCHAR2 := NULL) RETURN VARCHAR2 IS
    	l_plan_fk VARCHAR2(240) := 'NA_EDW';
   	l_instance VARCHAR2(30) := NULL;

	BEGIN
		IF ((p_compile_designator IS null) OR (p_organization_id IS null))THEN
			return 'NA_EDW';
		END IF;

		IF (p_instance_code is NOT NULL) then
			l_instance := p_instance_code;
		ELSE
			select instance_code into l_instance
			from edw_local_instance;
		END IF;

		l_plan_fk := p_compile_designator || '-' || p_organization_id || '-' || l_instance;

		RETURN(l_plan_fk);

	EXCEPTION WHEN others THEN
		return 'NA_EDW';
	END get_plan_name_fk;
END;

/
