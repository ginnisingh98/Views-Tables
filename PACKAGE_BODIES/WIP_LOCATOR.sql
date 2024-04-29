--------------------------------------------------------
--  DDL for Package Body WIP_LOCATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_LOCATOR" AS
/* $Header: wiplocvb.pls 120.2 2006/09/06 07:07:19 sisankar noship $ */

PROCEDURE Validate(P_Organization_Id IN NUMBER DEFAULT NULL,
		   P_Item_Id IN NUMBER DEFAULT NULL,
		   P_Subinventory_Code IN VARCHAR2 DEFAULT NULL,
		   P_Org_Loc_Control IN NUMBER DEFAULT NULL,
		   P_Sub_Loc_Control IN NUMBER DEFAULT NULL,
		   P_Item_Loc_Control IN NUMBER DEFAULT NULL,
		   P_Restrict_Flag IN NUMBER DEFAULT NULL,
		   P_Neg_Flag IN NUMBER DEFAULT NULL,
		   P_Action IN NUMBER DEFAULT NULL,
		   P_Project_Id IN NUMBER DEFAULT NULL,
		   P_Task_Id IN NUMBER DEFAULT NULL,
		   P_Locator_Id IN OUT NOCOPY NUMBER,
		   P_Locator_Segments IN OUT NOCOPY VARCHAR2,
		   P_Success_Flag OUT NOCOPY BOOLEAN) IS

x_loc_control NUMBER;
x_flex_flag VARCHAR2(100);
x_where_clause VARCHAR2(2000);
x_count NUMBER;

BEGIN

    x_loc_control := QLTINVCB.Control(
			    ORG_CONTROL=>P_Org_Loc_Control,
			    SUB_CONTROL=>P_Sub_Loc_Control,
			    ITEM_CONTROL=>P_Item_Loc_Control,
			    RESTRICT_FLAG=>P_Restrict_Flag,
			    NEG_FLAG=>P_Neg_Flag,
			    ACTION=>P_Action);


    /* No Locator Control */

    /* Bug 5446216 (FP Bug 5504790): For Subinventory we should look for new possible value fnd_api.g_miss_char.
       If it is null do validation of locator */
    IF (x_loc_control = WIP_CONSTANTS.NO_CONTROL OR
        P_Subinventory_Code = fnd_api.g_miss_char ) THEN

    /* Bug 5446216 (FP Bug 5504790): Modified locator validation to also check for new possible
       value fnd_api.g_miss_num */
    IF x_loc_control = WIP_CONSTANTS.NO_CONTROL AND
       (P_Locator_Id IS NOT NULL OR P_Locator_Segments IS NOT NULL OR P_Locator_Id <> fnd_api.g_miss_num) THEN
        P_Success_Flag := FALSE;
        return;
    END IF;

	P_Locator_ID := NULL;
	P_Locator_Segments := NULL;
	P_Success_Flag := TRUE;

	return;

    /* Pre-specified Control */
    ELSIF x_loc_control = WIP_CONSTANTS.PRESPECIFIED THEN

	x_flex_flag := 'CHECK_COMBINATION';

    IF P_Restrict_Flag = WIP_CONSTANTS.YES THEN
    /*     x_where_clause :=
              '(DISABLE_DATE > SYSDATE OR ' ||
                  'DISABLE_DATE IS NULL) AND SUBINVENTORY_CODE = ' ||
                   P_Subinventory_Code
                  || ' AND INVENTORY_LOCATION_ID IN ' ||
                  '(SELECT SECONDARY_LOCATOR FROM MTL_SECONDARY_LOCATORS ' ||
                  'WHERE INVENTORY_ITEM_ID = ' ||
                  TO_CHAR(P_Item_Id) ||
                  ' AND ORGANIZATION_ID = ' || to_char(P_Organization_Id)
                  || ' AND SUBINVENTORY_CODE = ' || P_Subinventory_Code || ')'; */

           -- Modified for bug 4899770 to avoid literals when query is binded on runtime. Also see bug 5171858.

       x_where_clause :=
              '(DISABLE_DATE > SYSDATE OR ' ||
                  'DISABLE_DATE IS NULL) AND SUBINVENTORY_CODE = ''' ||
                   P_Subinventory_Code ||''''
                  || ' AND INVENTORY_LOCATION_ID IN ' ||
                  '(SELECT SECONDARY_LOCATOR FROM MTL_SECONDARY_LOCATORS ' ||
                  'WHERE INVENTORY_ITEM_ID = ''' ||
                  TO_NUMBER(P_Item_Id) ||'''' ||
                  ' AND ORGANIZATION_ID = ''' || to_number(P_Organization_Id)||''''
                  || ' AND SUBINVENTORY_CODE = ''' || P_Subinventory_Code||'''' || ')';

        ELSE

          x_where_clause :=
                '(DISABLE_DATE > SYSDATE OR ' ||
               'DISABLE_DATE IS NULL) AND (NVL(SUBINVENTORY_CODE, ''Z'')) ' ||
               '= NVL(''' || P_Subinventory_Code || ''',''Z'') ';

       END IF;


    ELSIF x_loc_control = WIP_CONSTANTS.DYNAMIC THEN

	x_flex_flag := 'CREATE_COMBINATION';

       	x_where_clause :=
               '(DISABLE_DATE > SYSDATE OR ' ||
               'DISABLE_DATE IS NULL) AND (NVL(SUBINVENTORY_CODE, ''Z'')) ' ||
               '= NVL(''' || P_Subinventory_Code || ''',''Z'') ';

    END IF;

    IF x_loc_control <> WIP_CONSTANTS.NO_CONTROL THEN

    /* Bug 5446216 (FP Bug 5504790): Modifieded locator validation to also check for new possible
       value fnd_api.g_miss_num */
    IF ((P_Locator_Id IS NULL AND P_Locator_Segments IS NULL) OR P_Locator_Id = fnd_api.g_miss_num)
        AND P_Subinventory_Code IS NOT NULL THEN
        P_Success_Flag := FALSE;
        return;
    ELSIF P_Locator_Id IS NOT NULL THEN

	    IF P_Restrict_Flag = WIP_CONSTANTS.YES
		AND x_loc_control = WIP_CONSTANTS.PRESPECIFIED THEN

		SELECT COUNT(*)
		INTO   x_count
		FROM   MTL_ITEM_LOCATIONS
		WHERE  (DISABLE_DATE > SYSDATE or
			DISABLE_DATE IS NULL)
		AND SUBINVENTORY_CODE = P_Subinventory_Code
		AND INVENTORY_LOCATION_ID = P_Locator_Id
		AND INVENTORY_LOCATION_ID IN
		    (SELECT SECONDARY_LOCATOR
		     FROM   MTL_SECONDARY_LOCATORS
		     WHERE  INVENTORY_ITEM_ID = P_Item_Id
		     AND    ORGANIZATION_ID = P_Organization_Id
		     AND    SUBINVENTORY_CODE = P_Subinventory_Code);

	    ELSE

		SELECT COUNT(*)
		INTO   x_count
		FROM   MTL_ITEM_LOCATIONS
		WHERE  (DISABLE_DATE > SYSDATE or
			DISABLE_DATE IS NULL)
		AND INVENTORY_LOCATION_ID = P_Locator_Id
		AND NVL(SUBINVENTORY_CODE,'Z')
		  = NVL(P_Subinventory_Code,'Z');

	    END IF;

	    IF x_count <> 1 THEN
		p_success_flag := FALSE;
	    ELSE
		p_success_flag := TRUE;
	    END IF;

	ELSE
	    fnd_profile.put('MFG_ORGANIZATION_ID',to_char(P_Organization_Id));
	    P_Success_Flag :=
	      FND_FLEX_KEYVAL.VALIDATE_SEGS(x_flex_flag, 'INV', 'MTLL',
	      101, P_Locator_Segments, 'V', NULL, 'ALL',
	      P_Organization_Id, NULL, x_where_clause);

	    If P_Success_Flag THEN

		P_Locator_Id :=  FND_FLEX_KEYVAL.COMBINATION_ID;

		IF x_loc_control = WIP_CONSTANTS.DYNAMIC THEN
		    UPDATE MTL_ITEM_LOCATIONS
		    SET    SUBINVENTORY_CODE = P_Subinventory_Code
		    WHERE  INVENTORY_LOCATION_ID = P_Locator_Id
		    AND    ORGANIZATION_ID = P_Organization_Id;
		END IF;

	    END IF;

	END IF;

    END IF;
/* Fixed for Bug#3060266
Project and task would be validated against Locator ID
only if Project ID is entered.
*/
   if P_Project_Id is NOT NULL then


    /* After All Validations are complete call the Locator Validation API
	** to validate project and task against the Locator ID.
	*/

	if not(INV_ProjectLocator_PUB.Check_Project_References(
			   P_Organization_id,
			   P_Locator_Id,
			   'SPECIFIC',
			   'Y',
			   P_Project_Id,
			   P_Task_Id)) then

                 p_success_flag := FALSE;
        else
		 p_success_flag := TRUE;
        end if;
   end if;
    return;

    exception
	when others then
        P_Success_Flag := FALSE;
	return;
END Validate;

END WIP_LOCATOR;

/
