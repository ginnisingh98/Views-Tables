--------------------------------------------------------
--  DDL for Package Body MRP_SCHEDULE_DESIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SCHEDULE_DESIG_PKG" AS
/* $Header: MRSDESIB.pls 115.0 99/07/16 12:44:42 porting ship $ */


PROCEDURE Check_Unique(X_organization_id NUMBER,
		       X_schedule_designator VARCHAR2) IS

   	dummy NUMBER;
BEGIN

  SELECT 1
    INTO dummy
    FROM dual
   WHERE NOT EXISTS (SELECT 1
                      FROM mrp_schedule_designators
                     WHERE schedule_designator = X_schedule_designator
                       AND organization_id = X_organization_id
                     );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('MRP','GEN-duplicate name');
        FND_MESSAGE.SET_TOKEN('ENTITY','E_SCHEDULE', TRUE);
        APP_EXCEPTION.RAISE_EXCEPTION;

END Check_Unique;



PROCEDURE Update_Plans(X_organization_id NUMBER,
		       X_schedule_designator VARCHAR2) IS

BEGIN

  UPDATE mrp_plans
  SET    explosion_start_date      = NULL,
         explosion_completion_date = NULL,
         data_start_date           = NULL,
         data_completion_date      = NULL,
         plan_start_date           = NULL,
         plan_completion_date      = NULL
   WHERE schedule_designator       = X_schedule_designator
   AND   organization_id           = X_organization_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	null;

END Update_Plans;



FUNCTION Check_References(X_organization_id NUMBER,
    			  X_schedule_designator VARCHAR2)
    	RETURN BOOLEAN IS

 	entity	     NUMBER;
 	dummy        NUMBER;

 BEGIN
  --  Check mrp_forecast_designators table
  entity := 1;

  SELECT 1
    INTO dummy
    FROM dual
   WHERE NOT EXISTS (SELECT 1
                      FROM mrp_forecast_designators
                     WHERE forecast_designator = X_schedule_designator
                       AND organization_id = X_organization_id);

  --  Check mrp_designators table
  entity := 2;

  SELECT 1
    INTO dummy
    FROM dual
   WHERE NOT EXISTS (SELECT 1
                      FROM mrp_designators
                     WHERE compile_designator = X_schedule_designator
                       AND organization_id = X_organization_id);

  RETURN(TRUE);

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('MRP','GEN-duplicate name');
        if (entity = 1) then
	   FND_MESSAGE.SET_TOKEN('ENTITY','E_FORECAST', TRUE);
	else
	   FND_MESSAGE.SET_TOKEN('ENTITY','E_PLAN', TRUE);
 	end if;
  	APP_EXCEPTION.RAISE_EXCEPTION;
        RETURN(FALSE);

END Check_References;



FUNCTION Plans_Exist(X_organization_id NUMBER,
    	             X_schedule_designator VARCHAR2)
    	RETURN BOOLEAN IS

 	dummy        NUMBER;

 BEGIN

  SELECT 1
    INTO dummy
    FROM mrp_plans
   WHERE explosion_completion_date >= explosion_start_date
     AND data_start_date           >= explosion_completion_date
     AND data_completion_date      >= data_start_date
     AND plan_start_date           >= data_completion_date
     AND plan_completion_date      >= plan_start_date
     AND schedule_designator        = X_schedule_designator
     AND organization_id            = X_organization_id;


  RETURN(TRUE);

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
 	FND_MESSAGE.SET_NAME('MRP', 'No Plans exist');
        RETURN(FALSE);

END Plans_Exist;


END MRP_SCHEDULE_DESIG_PKG;

/
