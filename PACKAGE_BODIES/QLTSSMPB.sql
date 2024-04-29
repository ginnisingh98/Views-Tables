--------------------------------------------------------
--  DDL for Package Body QLTSSMPB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTSSMPB" as
/* $Header: qltssmpb.plb 115.6 2003/10/03 19:26:47 anagarwa ship $ */


--  This is a wrapper for ss plan/element mapping.
--  It is needed for the concurrent manager to run
--  This is called from SRS


PROCEDURE wrapper (ERRBUF OUT NOCOPY VARCHAR2,
		   RETCODE OUT NOCOPY NUMBER,
		   ARGUMENT1 IN VARCHAR2,
		   ARGUMENT2 IN NUMBER) IS

    CURSOR c (p_plan_name VARCHAR2) IS
	SELECT plan_id
	FROM qa_plans
	WHERE name = p_plan_name;

    CURSOR c2 (p_org_id NUMBER) IS
	SELECT plan_id
	FROM qa_plans
	WHERE organization_id = p_org_id;

    l_plan_id NUMBER;

BEGIN

    -- ARGUMENT1 --> Plan Name
    -- ARGUMENT2 --> Org ID

    IF	(ARGUMENT1 IS NOT NULL) THEN
        OPEN c (ARGUMENT1);
        FETCH c INTO l_plan_id;
        CLOSE c;
    	qa_jrad_pkg.map_plan(l_plan_id, null);
    	qa_ssqr_jrad_pkg.map_plan(l_plan_id);

    ELSE

	OPEN c2 (ARGUMENT2);
        LOOP
             FETCH c2 INTO l_plan_id;
             EXIT WHEN c2%NOTFOUND;

       	     qa_jrad_pkg.map_plan(l_plan_id, null);
       	     qa_ssqr_jrad_pkg.map_plan(l_plan_id);

    	END LOOP;
    	CLOSE c2;

    END IF;

    RETCODE := 0;
    ERRBUF := '';

END WRAPPER;


END qltssmpb;


/
