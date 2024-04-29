--------------------------------------------------------
--  DDL for Package Body RCV_INTRANSIT_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_INTRANSIT_SV" as
/* $Header: RCVSHINB.pls 120.1 2006/06/19 07:38:00 rahujain noship $ */

/*========================= RCV_INTRANSIT_SV   =============================*/
/*===========================================================================

  FUNCTION NAME:	get_expected_shipped_date

===========================================================================*/
FUNCTION get_expected_shipped_date (
X_from_organization_id    IN NUMBER,
X_to_organization_id      IN NUMBER,
X_need_by_date            IN DATE,
X_req_line_id             IN NUMBER)
RETURN DATE IS

X_intransit_time          NUMBER;
X_expected_shipped_date   DATE;
X_progress 	          VARCHAR2(4) := '000';

BEGIN

   /*
   ** Get the mtl_interorg_ship_methods row for the from and to org id
   ** combination.  This will provide you with the intransit lead time
   */

   BEGIN

		/* Bug 1246475 - GMudgal - 23-MAR-00
		** Added condition for default_flag.
		** Default_flag :1, Yes, 2, No.
		** If there is more than one shipping method defined between
		** two orgs, then the following query used to fail with no
		** data found and the intransit time wouldn't be subtracted
		** from the need by date.
		**
		** Not sure if Inventory makes it mandatory to select one and
		** only one method as the default when creating the ship methods.
		*/

        SELECT MSM.INTRANSIT_TIME
        INTO   X_INTRANSIT_TIME
        FROM   MTL_INTERORG_SHIP_METHODS MSM
        WHERE  MSM.FROM_ORGANIZATION_ID = X_from_organization_id
        AND    MSM.TO_ORGANIZATION_ID	= X_to_organization_id
        AND    MSM.DEFAULT_FLAG=1;


        /*
        ** Calculate the expected shipped date based on ship to org
        ** work calendar
        */
        /* Cannot do this based on the pragma requirements
        ** Will have to check with MRP to change their function pragmas
        */
        /*
        X_expected_shipped_date :=
	   MRP_CALENDAR.DATE_OFFSET(X_TO_ORGANIZATION_ID,
                       1,
                       X_need_by_date,
                       X_INTRANSIT_TIME);
        */
        X_expected_shipped_date := X_need_by_date - X_INTRANSIT_TIME;

    EXCEPTION

    /*Bug# 1881765
    ** If more than one row exists for the MTL_INTERORG_SHIP_METHODS then
       take the first shipment Method from the set of defined methods
       Else If no row exists for the MTL_INTERORG_SHIP_METHODS then just
       set the expected shipped date to the need by date.
    */

    WHEN NO_DATA_FOUND THEN

    BEGIN

        SELECT MSM.INTRANSIT_TIME
        INTO   X_INTRANSIT_TIME
        FROM   MTL_INTERORG_SHIP_METHODS MSM
        WHERE  MSM.FROM_ORGANIZATION_ID = X_from_organization_id
        AND    MSM.TO_ORGANIZATION_ID   = X_to_organization_id
        AND    ROWNUM=1;

        X_expected_shipped_date := X_need_by_date - X_INTRANSIT_TIME;

     EXCEPTION

     WHEN NO_DATA_FOUND THEN

        X_expected_shipped_date := X_need_by_date;

    END;

   WHEN OTHERS THEN

       X_expected_shipped_date := X_need_by_date;
   END;

    RETURN (X_expected_shipped_date);

END get_expected_shipped_date;

/*===========================================================================

  FUNCTION NAME:	rcv_get_org_name

===========================================================================*/

FUNCTION rcv_get_org_name  (
  p_source_code IN VARCHAR2,
  p_vendor_id   IN NUMBER,
  p_org_id      IN NUMBER)
  RETURN VARCHAR2 IS
-- v_Result VARCHAR(80);
/** <UTF8 FPI> **/
/** tpoon 9/27/2002 **/
/** Changed v_Result to use %TYPE **/
 v_Result hr_all_organization_units.name%TYPE;
BEGIN

  BEGIN

     IF (p_source_code = 'VENDOR') THEN

       SELECT MAX(NVL(VENDOR_NAME, NULL))
         INTO v_Result
         FROM PO_VENDORS
        WHERE vendor_id = p_vendor_id;

     ELSE
       --Bug 5217526. Fetch Org Name from HR_ORGANIZATION_UNITS
       SELECT MAX(NVL(NAME, NULL))
         INTO v_Result
         FROM HR_ORGANIZATION_UNITS
        WHERE ORGANIZATION_ID = p_org_id;
     END IF;


  EXCEPTION

  WHEN OTHERS THEN
      v_Result :=  'RCV_GET_ORG_NAME-> ' || to_char(p_vendor_id) || ' ' || to_char(p_org_id);

  END;

  RETURN v_Result;

END RCV_GET_ORG_NAME;

END RCV_INTRANSIT_SV;

/
