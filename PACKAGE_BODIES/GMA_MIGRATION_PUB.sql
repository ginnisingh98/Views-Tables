--------------------------------------------------------
--  DDL for Package Body GMA_MIGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_MIGRATION_PUB" AS
/* $Header: GMAPMIGB.pls 120.1 2006/04/10 12:53:48 txdaniel noship $ */

/*====================================================================
--  PROCEDURE:
--    Check_Organization_Dependents
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to set the active indicator for the
--    organization based on its usage.
--
--  PARAMETERS:
--    P_orgn_code       Organization Code
--    P_update          Update sy_orgn_mst - 'Y' - Yes, 'N' - No
--    X_active_ind      Out variable for active indicator,
--                         0 - If organization is not active
--                         1 - If the organization is active
--  SYNOPSIS:
--    Check_Organization_Dependents (p_orgn_code => l_orgn_code,
--                                   p_update => 'Y',
--                                   x_active_ind => l_active_ind);
--
--  HISTORY
--====================================================================*/
PROCEDURE Check_Organization_Dependents (P_orgn_code VARCHAR2,
                                         P_update VARCHAR2,
                                         X_active_ind OUT NOCOPY NUMBER) IS
  CURSOR Cur_check_formula IS
    SELECT 1
    FROM   sys.dual
    WHERE  EXISTS (SELECT 1
                   FROM   fm_form_mst_b
                   WHERE  orgn_code = P_orgn_code);

  CURSOR Cur_check_recipe IS
    SELECT 1
    FROM   sys.dual
    WHERE  EXISTS (SELECT 1
                   FROM   gmd_recipes_b
                   WHERE  owner_orgn_code = P_orgn_code);

  CURSOR Cur_check_validity IS
    SELECT 1
    FROM   sys.dual
    WHERE  EXISTS (SELECT 1
                   FROM   gmd_recipe_validity_rules
                   WHERE  orgn_code = P_orgn_code);

  CURSOR Cur_check_tech_param IS
    SELECT 1
    FROM   sys.dual
    WHERE  EXISTS (SELECT 1
                   FROM   lm_tech_hdr
                   WHERE  orgn_code = P_orgn_code);

  CURSOR Cur_check_batch IS
    SELECT 1
    FROM   sys.dual
    WHERE  EXISTS (SELECT 1
                   FROM   pm_btch_hdr
                   WHERE  plant_code = P_orgn_code);

  CURSOR Cur_check_item_cost IS
    SELECT 1
    FROM   sys.dual
    WHERE  EXISTS (SELECT 1
                   FROM   gl_item_cst
                   WHERE  orgn_code = P_orgn_code);

  l_exists NUMBER(5);
  ORG_EXISTS	EXCEPTION;
BEGIN
  OPEN Cur_check_formula;
  FETCH Cur_check_formula INTO l_exists;
  IF Cur_check_formula%FOUND THEN
    CLOSE Cur_check_formula;
    RAISE ORG_EXISTS;
  END IF;
  CLOSE Cur_check_formula;

  OPEN Cur_check_recipe;
  FETCH Cur_check_recipe INTO l_exists;
  IF Cur_check_recipe%FOUND THEN
    CLOSE Cur_check_recipe;
    RAISE ORG_EXISTS;
  END IF;
  CLOSE Cur_check_recipe;

  OPEN Cur_check_validity;
  FETCH Cur_check_validity INTO l_exists;
  IF Cur_check_validity%FOUND THEN
    CLOSE Cur_check_validity;
    RAISE ORG_EXISTS;
  END IF;
  CLOSE Cur_check_validity;

  OPEN Cur_check_tech_param;
  FETCH Cur_check_tech_param INTO l_exists;
  IF Cur_check_tech_param%FOUND THEN
    CLOSE Cur_check_tech_param;
    RAISE ORG_EXISTS;
  END IF;
  CLOSE Cur_check_tech_param;

  OPEN Cur_check_batch;
  FETCH Cur_check_batch INTO l_exists;
  IF Cur_check_batch%FOUND THEN
    CLOSE Cur_check_batch;
    RAISE ORG_EXISTS;
  END IF;
  CLOSE Cur_check_batch;

  OPEN Cur_check_item_cost;
  FETCH Cur_check_item_cost INTO l_exists;
  IF Cur_check_item_cost%FOUND THEN
    CLOSE Cur_check_item_cost;
    RAISE ORG_EXISTS;
  END IF;
  CLOSE Cur_check_item_cost;

  IF P_update = 'Y' THEN
    UPDATE sy_orgn_mst
    SET    active_ind = 0
    WHERE  orgn_code = P_orgn_code;
  END IF;
  X_active_ind := 1;
EXCEPTION
  WHEN ORG_EXISTS THEN
    IF P_update = 'Y' THEN
      UPDATE sy_orgn_mst
      SET    active_ind = 1
      WHERE  orgn_code = P_orgn_code;
    END IF;
    X_active_ind := 1;
END check_organization_dependents;

/*====================================================================
--  PROCEDURE:
--    populate_lot_migration
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to creates data in ic_lots_mst_mig table.
--
--
--  PARAMETERS:
--
--  SYNOPSIS:
--    populate_lot_migration;
--
--  HISTORY
--====================================================================*/

procedure populate_lot_migration is
BEGIN

--  Remove any rows that no longer exist in the ic_loct_inv table.
--  This can happen if the user fixes the issue by changing the lot status to
--  the same value for all warehouse locations.

DELETE FROM ic_lots_mst_mig
WHERE
	migrated_ind = 0 AND
	(item_id, lot_id, whse_mapping_code) NOT IN ( 	-- No deletion if any single location
					 		-- in the inventory org is migrated
		SELECT item_id, lot_id, whse_mapping_code
		FROM ic_lots_mst_mig
		WHERE migrated_ind = 1) AND
	(item_id, lot_id, whse_mapping_code) IN (	-- All whse and locations for the inv org
						-- if any location's status was changed
		SELECT item_id, lot_id, whse_mapping_code
		FROM ic_lots_mst_mig
		WHERE
			migrated_ind = 0 AND
			-- If the lot status or warehouse mapping changed since last
			(item_id, lot_id, whse_mapping_code, whse_code, location, status) NOT IN (
				SELECT inv.item_id, inv.lot_id,
					DECODE(w.subinventory_ind_flag, 'Y', w.orgn_code, w.whse_code),
					inv.whse_code, inv.location, inv.lot_status  -- lot with diff status
				FROM ic_loct_inv inv, ic_item_mst_b i, ic_whse_mst w
				WHERE
					inv.item_id = i.item_id AND
					inv.whse_code = w.whse_code AND
					i.lot_ctl = 1 AND
					inv.loct_onhand <> 0 AND
					EXISTS (
						SELECT 1
						FROM ic_loct_inv inv2, ic_whse_mst w2
						WHERE
							inv2.whse_code = w2.whse_code AND
							inv.item_id = inv2.item_id AND
							inv.lot_id = inv2.lot_id AND
								-- Compare the balances within the mapped org
							DECODE(w.subinventory_ind_flag, 'Y', w.orgn_code, w.whse_code) =
							DECODE(w2.subinventory_ind_flag, 'Y', w2.orgn_code, w2.whse_code) AND
								-- Same locations for whse mapped as subinventory will be created as diff locators.
							inv.whse_code||inv.location <> inv2.whse_code||inv2.location AND
							inv.lot_status <> inv2.lot_status AND
							inv2.loct_onhand <> 0))) AND
	(item_id, lot_id, organization_id, whse_code, location) NOT IN ( -- Except for the ones which have been updated
									-- by the user AND ARE STILL VALID
		SELECT item_id, lot_id, whse_mapping_code, whse_code, location
		FROM ic_lots_mst_mig
		WHERE
			user_updated_ind = 1 AND
			(item_id, lot_id, whse_mapping_code, whse_code, location, status) in (
				SELECT inv.item_id, inv.lot_id,
					DECODE(w.subinventory_ind_flag, 'Y', w.orgn_code, w.whse_code),
					inv.whse_code, inv.location, inv.lot_status
				FROM ic_loct_inv inv, ic_item_mst_b i, ic_whse_mst w
				WHERE
					inv.item_id = i.item_id AND
					inv.whse_code = w.whse_code AND
					i.lot_ctl = 1 AND
					inv.loct_onhand <> 0 AND
					EXISTS (
						SELECT 1
						FROM ic_loct_inv inv2, ic_whse_mst w2
						WHERE
							inv2.whse_code = w2.whse_code AND
							inv.item_id = inv2.item_id AND
							inv.lot_id = inv2.lot_id AND
								-- Compare the balances within the mapped org
							DECODE(w.subinventory_ind_flag, 'Y', w.orgn_code, w.whse_code) =
							DECODE(w2.subinventory_ind_flag, 'Y', w2.orgn_code, w2.whse_code) AND
								-- Same locations for whse mapped as subinventory will be created as diff locators.
							inv.whse_code||inv.location <> inv2.whse_code||inv2.location AND
							inv.lot_status <> inv2.lot_status AND
							inv2.loct_onhand <> 0)));


--	Insert any new records that have been created in the ic_loct_inv table and
--  may be candidate for multiple lot status case. This can happen if User
--  created new inventory for a lot in a warehouse location or changed the
--  lot status of the existing lot in a warehouse location.

INSERT INTO ic_lots_mst_mig (
	 ITEM_ID,
	 LOT_ID,
	 ORGANIZATION_ID,
	 WHSE_MAPPING_CODE,
	 WHSE_CODE,
	 LOCATION,
	 STATUS,
	 PARENT_LOT_NUMBER,
	 LOT_NUMBER,
	 MIGRATED_IND,
	 ADDITIONAL_STATUS_LOT,
	 USER_UPDATED_IND,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN)
SELECT item_id, lot_id, NULL, whse_mapping_code, whse_code, location, lot_status, parent_lot,
	lot_no ||
	DECODE (sublot_no, NULL, NULL,
		  (SELECT lot_sublot_delimiter FROM gmi_migration_parameters)) ||
	sublot_no ||
	DECODE (lot_status, nvl(mig_status, first_status), NULL, '-' || lot_status) lot_number,
	0 MIGRATED_IND,
	DECODE (lot_status, first_status, 0, 1) ADDITIONAL_STATUS_LOT,
	0 USER_UPDATED_IND ,
	sysdate, 0, sysdate, 0, NULL
FROM (
SELECT i.item_id, l.lot_id, l.lot_no, l.sublot_no, w.organization_id,
	DECODE(w.subinventory_ind_flag, 'Y', w.orgn_code, w.whse_code) whse_mapping_code,
	inv.whse_code, inv.location, inv.lot_status,
	first_value(inv.lot_status) OVER -- Status of lot with the most balance
		(PARTITION BY i.item_no, l.lot_no, l.sublot_no,
			DECODE(w.subinventory_ind_flag, 'Y', w.orgn_code, w.whse_code)
		ORDER BY inv.loct_onhand desc) first_status,
	(SELECT status FROM ic_lots_mst_mig
		WHERE item_id = inv.item_id AND lot_id = inv.lot_id AND
			whse_code = inv.whse_code AND additional_status_lot = 0 AND
			rownum = 1) mig_status,
	DECODE(i.sublot_ctl, 1, DECODE(l.sublot_no, NULL, NULL, l.lot_no)) parent_lot
FROM ic_loct_inv inv, ic_item_mst_b i, ic_lots_mst l, ic_whse_mst w
WHERE
    inv.whse_code = w.whse_code AND
    inv.item_id = i.item_id AND
    i.lot_ctl = 1 AND
    inv.item_id = l.item_id AND
    inv.lot_id = l.lot_id AND
    inv.loct_onhand <> 0 AND
    EXISTS (
	SELECT 1
	FROM ic_loct_inv inv2, ic_whse_mst w2
	WHERE
	    inv2.whse_code = w2.whse_code AND
	    inv.item_id = inv2.item_id AND
	    inv.lot_id = inv2.lot_id AND
			-- Compare the balances within the mapped org
		DECODE(w.subinventory_ind_flag, 'Y', w.orgn_code, w.whse_code) =
		DECODE(w2.subinventory_ind_flag, 'Y', w2.orgn_code, w2.whse_code) AND
			-- Same locations for whse mapped as subinventory will be created as diff locators.
		inv.whse_code||inv.location <> inv2.whse_code||inv2.location AND
	    inv.lot_status <> inv2.lot_status AND
	    inv2.loct_onhand <> 0))
WHERE -- Check if row already exists in the mig table
    (item_id, lot_id, whse_code, location, lot_status) NOT IN (
	SELECT item_id, lot_id, whse_code, location, status FROM ic_lots_mst_mig);

   EXCEPTION
      WHEN OTHERS THEN
        RAISE;
   COMMIT;
end populate_lot_migration;


/*====================================================================
--  PROCEDURE:
--    get_item_no
--
--  DESCRIPTION:
--    This procedure returns the item no for the passed in item id
--
--  PARAMETERS:
--
--
--  HISTORY
--      Thomas Daniel - Created - 04/10/06
--====================================================================*/
FUNCTION get_item_no(p_item_id NUMBER) RETURN VARCHAR2 IS
  l_item_no VARCHAR2(80);
BEGIN
  SELECT item_no INTO l_item_no
	 FROM   ic_item_mst
	 WHERE  item_id = p_item_id;
	 RETURN (l_item_no);
END get_item_no;

/*====================================================================
--  PROCEDURE:
--    get_lot_no
--
--  DESCRIPTION:
--    This procedure returns the lot and sublot no for the passed in lot id
--
--  PARAMETERS:
--
--
--  HISTORY
--      Thomas Daniel - Created - 04/10/06
--====================================================================*/

FUNCTION get_lot_no(p_lot_id NUMBER) RETURN VARCHAR2 IS
  l_lot_no VARCHAR2(100);
BEGIN
  SELECT lot_no||'-'||sublot_no INTO l_lot_no
	 FROM   ic_lots_mst
	 WHERE  lot_id = p_lot_id;
	 RETURN (l_lot_no);
END get_lot_no;

/*====================================================================
--  PROCEDURE:
--    get_orgn_code
--
--  DESCRIPTION:
--    This procedure returns the organization for the passed in warehouse
--
--  PARAMETERS:
--
--
--  HISTORY
--      Thomas Daniel - Created - 04/10/06
--====================================================================*/

FUNCTION get_orgn_code (p_whse_code VARCHAR2) RETURN VARCHAR2 IS
  l_orgn_code VARCHAR2(4);
	 l_subinventory_ind VARCHAR2(1);
	 l_mtl_organization_id NUMBER(15);
	 l_organization_code VARCHAR2(10);
BEGIN
  SELECT subinventory_ind_flag, orgn_code, mtl_organization_id
	 INTO   l_subinventory_ind, l_orgn_code, l_mtl_organization_id
	 FROM   ic_whse_mst
	 WHERE  whse_code = p_whse_code;
	 IF NVL(l_subinventory_ind, 'N') = 'N' THEN
	   SELECT organization_code INTO l_organization_code
		FROM mtl_parameters
		WHERE organization_id = l_mtl_organization_id;
  ELSE
	   l_organization_code := l_orgn_code;
	 END IF;
	 RETURN (l_organization_code);
END get_orgn_code;


END;

/
