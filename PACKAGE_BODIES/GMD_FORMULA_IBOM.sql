--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_IBOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_IBOM" AS
/* $Header: GMDFORMB.pls 120.2.12010000.2 2009/07/21 07:14:21 kannavar ship $ */

  PROCEDURE get_formula(V_item_id                       NUMBER,
                        l_type                          VARCHAR2,
       			eff_type                        IN VARCHAR2,
   			eff_date                        IN VARCHAR2,
      			pformula_id                     OUT NOCOPY PLS_INTEGER,
       			pformula_std_qty                OUT NOCOPY NUMBER,
       			pformula_std_qty_uom            OUT NOCOPY VARCHAR2,
                        inact_status                    VARCHAR2,
			pvalidity_organization_type     NUMBER,
			porganization_id                NUMBER,
                        presp_id                        IN NUMBER) IS

    -- BEGIN BUG#1252454 Sastry
    -- Added where clause related to orgn to select formulas which have effectivities that are either
    -- local to user orgn or global. Also added order by clause to sort them in ascending order.
    -- Also modified the date format from DD-MON-RRRR to DD-MM-RRRR for GSCC complaint.
    --BEGIN BUG#1856823 Rameshwar
    --Modified the inact_ind to inact_status in the query.
    -- BEGIN BUG#3616788
    CURSOR IBOM_CUR IS
    	SELECT fm.formula_id, fm.formula_no, fm.formula_vers,fe.min_qty, fe.max_qty,
             	fe.std_qty, fe.detail_uom, fe.preference,fe.last_update_date
	FROM   gmd_recipe_validity_rules fe, fm_form_mst fm, gmd_recipes_b r, fm_matl_dtl fdtl
      	WHERE  fe.inventory_item_id = V_item_id
        AND 	fe.recipe_use =  eff_type
         AND fdtl.formula_id = fm.formula_id /* Added in Bug No.8639969 */
        AND fdtl.line_type = 1 /* Added in Bug No.8639969 */
        AND fdtl.inventory_item_id = fe.inventory_item_id    /* Added in Bug No.8639969 */
        AND fe.validity_rule_status = 700  /* Added in Bug No.8639969 */
        AND 	fm.formula_status LIKE NVL(inact_status,'%')
        AND 	TRUNC(fe.start_date) <= TRUNC(TO_DATE(eff_date,'DD-MM-RRRR'))
        AND 	(
                      TRUNC(fe.end_date) >= TRUNC(TO_DATE(eff_date,'DD-MM-RRRR'))
		OR    fe.end_date IS NULL
		)
        AND 	fe.delete_mark = 0
	AND	r.formula_id = fm.formula_id
	AND     fe.recipe_id = r.recipe_id
        AND 	fm.delete_mark = 0
	AND 	(pvalidity_organization_type = 2
                OR fe.organization_id IS NULL
                OR (pvalidity_organization_type = 0 AND fe.organization_id = porganization_id )
                OR (pvalidity_organization_type = 1 AND fe.organization_id IN ( SELECT organization_id
                                        				   FROM org_access_view
                                        				   WHERE responsibility_id = presp_id)))
      -- Bug 4777885  KSHUKLA : Start

  	ORDER BY fe.orgn_code asc, 8, fe.start_date desc;

     -- Bug 4777885 : End
    --END BUG#3616788
    --END BUG#1252454
     Cur_rec IBOM_CUR%ROWTYPE;
   BEGIN
     OPEN  IBOM_CUR;
     FETCH IBOM_CUR INTO Cur_rec;
     IF (IBOM_CUR%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
     END IF;
     CLOSE IBOM_CUR;
       pformula_id          := cur_rec.formula_id;
       pformula_std_qty     := cur_rec.std_qty;
       pformula_std_qty_uom := cur_rec.detail_uom;
       gmd_debug.put_line('formula id is'|| pformula_id ||'std qty is '|| pformula_std_qty||'qty _uom is '||pformula_std_qty_uom);
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       gmd_Debug.put_line('no data found');
       pformula_id := -1;
  END get_formula;
END GMD_FORMULA_IBOM;

/
