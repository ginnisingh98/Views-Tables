--------------------------------------------------------
--  DDL for Package Body PMI_COST_ANALZ_PACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMI_COST_ANALZ_PACK" as
/* $Header: PMICTANB.pls 120.0 2005/05/24 16:58:01 appldev noship $ */

	FUNCTION gmca_get_cost(
		item_id_vi		IN ic_item_mst.item_id%TYPE,
		inv_whse_code_vi	IN cm_cmpt_dtl.whse_code%TYPE,
		cost_mthd_code_vi	IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		cost_date_vi		IN DATE)
	RETURN NUMBER
	IS
		cost_v			NUMBER := 0;
		cost_whse_v		cm_whse_asc.cost_whse_code%TYPE := NULL;
		cost_calendar_v		cm_cldr_dtl.calendar_code%TYPE := NULL;
		cost_period_v		cm_cldr_dtl.period_code%TYPE := NULL;

		CURSOR get_cal_per_cur(
			cost_whse_v		IN cm_whse_asc.cost_whse_code%TYPE,
			cost_mthd_code_v	IN cm_cldr_hdr.cost_mthd_code%TYPE,
			cost_date_v		IN DATE)
		IS
			SELECT d.calendar_code, d.period_code
			FROM	cm_cldr_dtl d,
				cm_cldr_hdr h,
				sy_orgn_mst o,
				ic_whse_mst w
			WHERE
				w.whse_code	= cost_whse_v
			AND	w.orgn_code	= o.orgn_code
			AND	o.co_code	= h.co_code
			AND	h.cost_mthd_code	= cost_mthd_code_v
			AND	h.calendar_code	= d.calendar_code
			AND	d.start_date	<= cost_date_v
			AND	d.end_date	>= cost_date_v
			AND	h.delete_mark	= 0
			AND	d.delete_mark	= 0;

		CURSOR get_cost_cur(
			item_id_v		IN ic_item_mst.item_id%TYPE,
			cost_whse_code_v	IN cm_cmpt_dtl.whse_code%TYPE,
			calendar_code_v		IN cm_cmpt_dtl.calendar_code%TYPE,
			period_code_v		IN cm_cmpt_dtl.period_code%TYPE,
			cost_mthd_code_v	IN cm_cmpt_dtl.cost_mthd_code%TYPE)
		IS
			SELECT sum(cmpnt_cost)
			FROM	cm_cmpt_dtl
			WHERE
				item_id		= item_id_v
			AND	whse_code	= cost_whse_code_v
			AND	calendar_code	= calendar_code_v
			AND	period_code	= period_code_v
			AND	cost_mthd_code	= cost_mthd_code_v
			AND	delete_mark	= 0
			GROUP BY
				item_id, whse_code, calendar_code, period_code,
				cost_mthd_code;
	BEGIN
		 cost_whse_v := gmca_cost_whse(inv_whse_code_vi, cost_date_vi);

		IF NOT get_cal_per_cur%ISOPEN THEN
			OPEN get_cal_per_cur(cost_whse_v, cost_mthd_code_vi,
				cost_date_vi);
		END IF;
		FETCH get_cal_per_cur INTO cost_calendar_v, cost_period_v;
		IF get_cal_per_cur%NOTFOUND THEN
			cost_calendar_v := NULL;
		END IF;
		IF get_cal_per_cur%ISOPEN THEN
			CLOSE get_cal_per_cur;
		END IF;

		IF cost_calendar_v IS NULL THEN
			RETURN NULL;
		END IF;

		IF NOT get_cost_cur%ISOPEN THEN
			OPEN get_cost_cur(item_id_vi,
				cost_whse_v, cost_calendar_v, cost_period_v, cost_mthd_code_vi);
		END IF;

		FETCH get_cost_cur INTO cost_v;

		IF get_cost_cur%NOTFOUND THEN
			cost_v := 0;
		END IF;

		IF get_cost_cur%ISOPEN THEN
			CLOSE get_cost_cur;
		END IF;

		IF cost_v IS NOT NULL THEN
			RETURN cost_v;
		ELSE
			RETURN 0;
		END IF;

	EXCEPTION
		WHEN others THEN
			IF get_cost_cur%ISOPEN THEN
				CLOSE get_cost_cur;
			END IF;

			IF get_cal_per_cur%ISOPEN THEN
				CLOSE get_cal_per_cur;
			END IF;
			RETURN NULL;
	END gmca_get_cost;

	FUNCTION gmca_get_perbal(
		tr_date_vi IN DATE,
                co_code_vi IN sy_orgn_mst.co_code%TYPE,
		whse_code_vi IN ic_perd_bal.whse_code%TYPE,
		item_id_vi IN ic_perd_bal.item_id%TYPE)
	RETURN NUMBER
	IS
		period_balance_v NUMBER;
		CURSOR get_perbal_cur(
		        tr_date_vi IN DATE,
                        co_code_vi IN sy_orgn_mst.co_code%TYPE,
                 	whse_code_vi IN ic_perd_bal.whse_code%TYPE,
			item_id_vi IN ic_perd_bal.item_id%TYPE)
		IS

			SELECT sum(loct_onhand)
			FROM
				ic_perd_bal perbal,
                                pmi_inv_calendar_v precal
			WHERE   (tr_date_vi-1) between precal.start_date and precal.end_date
				and       co_code_vi = precal.orgn_code
				and       precal.fiscal_year = perbal.fiscal_year
				and       precal.period = perbal.period
				and       perbal.item_id =item_id_vi
				and       perbal.whse_code=whse_code_vi
			GROUP BY
				perbal.fiscal_year, perbal.period, perbal.whse_code, perbal.item_id;
	BEGIN
		OPEN get_perbal_cur(tr_date_vi, co_code_vi, whse_code_vi,item_id_vi);
		FETCH get_perbal_cur INTO period_balance_v;

		IF get_perbal_cur%NOTFOUND THEN
	           RETURN 0;
	        ELSE
                   RETURN period_balance_v;
		END IF;
		CLOSE get_perbal_cur;
	END gmca_get_perbal;

FUNCTION gmca_get_meaning(p_lookup_typ  IN gem_lookups.lookup_type%TYPE,
                          p_lookup_cd   IN gem_lookups.lookup_code%TYPE )  RETURN VARCHAR2 IS
CURSOR get_meaning_cur IS
  SELECT Meaning
  FROM gem_lookups
  WHERE
    lookup_type = p_lookup_typ   AND
    lookup_code = p_lookup_cd    AND
    enabled_flag= 'Y'          AND
    start_date_active <= sysdate AND
    (end_date_active IS NULL OR end_date_active >= sysdate);
  l_meaning gem_lookups.meaning%TYPE;
BEGIN
  OPEN get_meaning_cur;
  FETCH get_meaning_cur INTO l_meaning; --get the value from gem lookups
  CLOSE get_meaning_cur;
  return l_meaning;
END gmca_get_meaning;


FUNCTION gmca_get_onhandqty(p_whse_code IN ic_loct_inv.whse_code%TYPE,
                            p_item_id   IN ic_loct_inv.item_id%TYPE,
                            P_Location  IN ic_loct_inv.location%TYPE,
                            p_lot_id    IN ic_loct_inv.lot_id%TYPE )  RETURN NUMBER IS
CURSOR get_onhand_cur IS
  SELECT       item_id,
               sum(loct_onhand)
  FROM ic_loct_inv
  WHERE p_item_id = item_id AND
        (p_whse_code IS NULL OR (p_whse_code is not null and p_whse_code = whse_code)) AND
        (p_location IS NULL OR (p_location is not null and p_location = location)) AND
        (p_lot_id IS NULL OR (p_lot_id is not null and p_lot_id = lot_id))
 group by item_id;
l_item_id    ic_loct_inv.item_id%TYPE;
l_qty        NUMBER;
BEGIN
    OPEN get_onhand_cur;
    FETCH get_onhand_cur INTO l_item_id,l_qty; --get the value from gem lookups
    CLOSE get_onhand_cur;
    return l_qty;
END gmca_get_onhandqty;




/* Function to get type of the item i.e. PRODUCT, INGREDIENT,CO-PRODUCT,BY-PRODUCT */


       FUNCTION gmca_get_line_type(
		item_id_vi IN ic_perd_bal.item_id%TYPE)
       RETURN NUMBER
       IS
         CURSOR line_type_cur IS
           SELECT distinct line_type from fm_matl_dtl
           WHERE  item_id = item_id_vi
         order by line_type desc;
         l_line_type fm_matl_dtl.line_type%type;
         l_line_type1 fm_matl_dtl.line_type%type := null;
       BEGIN
         open line_type_cur;
         LOOP
           FETCH line_type_cur into l_line_type;
           EXIT WHEN line_type_cur%NOTFOUND;
           IF l_line_type = 1 THEN
              EXIT;
           ELSIF l_line_type = -1 THEN
             IF l_line_type1 IS NOT NULL THEN
                l_line_type := l_line_type1;
             END IF;
           END IF;
           l_line_type1 := l_line_type;
          END LOOP;
          RETURN l_line_type;
	  END;

	FUNCTION gmca_inv_perend(
		orgn_code_vi IN ic_cldr_dtl.orgn_code%TYPE,
		fiscal_year_vi IN ic_cldr_dtl.fiscal_year%TYPE,
		period_vi IN ic_cldr_dtl.period%TYPE)
	RETURN DATE
	IS
		period_end_date_v DATE := null;

	BEGIN
		IF period_vi >= 1 THEN
               SELECT (period_end_date + 1 - 1/(24 * 60 * 60)) INTO period_end_date_v
			FROM
				ic_cldr_dtl
			WHERE
				orgn_code = orgn_code_vi
				AND fiscal_year = fiscal_year_vi
				AND period = period_vi;
		ELSE
			RETURN null;
		END IF;

		RETURN period_end_date_v;

	EXCEPTION
		WHEN others THEN
			RETURN null;
	END gmca_inv_perend;


	FUNCTION gmca_variance(
	batch_id_vi		IN gme_batch_header.batch_id%TYPE,
	formula_id_vi		IN fm_form_mst.formula_id%TYPE,
	batch_line_id_vi	IN gme_material_details.material_detail_id%TYPE,
	cost_mthd_vi		IN cm_cmpt_dtl.cost_mthd_code%TYPE,
        plan_qty_vi             IN gme_material_details.plan_qty%TYPE,
        item_um_vi              IN gme_material_details.item_um%TYPE,
        line_type_vi            IN gme_material_details.line_type%TYPE,
        line_no_vi              IN gme_material_details.line_no%TYPE,
        batch_status_vi         IN gme_batch_header.batch_status%TYPE,
        actual_cmplt_date_vi    IN gme_batch_header.actual_cmplt_date%TYPE,
        batch_close_date_vi     IN gme_batch_header.batch_close_date%TYPE,
        wip_whse_code_vi        IN gme_batch_header.wip_whse_code%TYPE,
        item_id_vi              IN gme_material_details.item_id%TYPE,
        formulaline_id_vi       IN gme_material_details.formulaline_id%TYPE,
        actual_qty_vi           IN gme_material_details.actual_qty%TYPE
                                 )
         RETURN NUMBER
       IS
	/* Declare and Initialize variables */
	primary_product_v	ic_item_mst.item_id%TYPE := 0;
	fm_qty_v		fm_matl_dtl.qty%TYPE := 0;
	fm_qty_um_v		sy_uoms_mst.um_code%TYPE := ' ';
	pm_qty_v		gme_material_details.plan_qty%TYPE := 0;
	pm_qty_um_v		sy_uoms_mst.um_code%TYPE := ' ';
	pri_prod_um_v		sy_uoms_mst.um_code%TYPE := ' ';
	batch_item_id_v		gme_material_details.item_id%TYPE := 0;
	batch_formulaline_id_v	gme_material_details.formulaline_id%TYPE := 0;
	batch_item_qty_v	gme_material_details.actual_qty%TYPE := 0;
	scale_factor_v		NUMBER := 1; /* Primary Scaling Factor */
	scaling_error_v		NUMBER := 0;
	variance_v		NUMBER := 0;

	/* batch values for cost formula retrieval */
	batch_status_v		gme_batch_header.batch_status%TYPE;
	batch_completion_dt_v	gme_batch_header.actual_cmplt_date%TYPE;
	batch_close_dt_v	gme_batch_header.batch_close_date%TYPE;
	wip_whse_v		gme_batch_header.wip_whse_code%TYPE;

	cost_whse_v		cm_whse_asc.cost_whse_code%TYPE;
	cost_date_v		DATE := NULL;
	cost_calendar_v		cm_cldr_dtl.calendar_code%TYPE;
	cost_period_v		cm_cldr_dtl.period_code%TYPE;
	cost_fmeff_id_v		fm_form_eff.fmeff_id%TYPE;
	cost_formula_id_v	fm_form_mst.formula_id%TYPE;

	all_linear		BOOLEAN := TRUE;
	b			NUMBER := 0; /* Secondary Scaling Factor */

	fm_line_type_v		NUMBER := 1; /* product by default ?? */
	fm_scale_type_v		NUMBER := 1; /* linear by default */

	/* Need a cursor to select primary product from formula since
	there can be blank lines? */
	CURSOR primary_product_cur(formula_id_p fm_form_mst.formula_id%TYPE)
	IS
	SELECT item_id
	FROM
		fm_matl_dtl
	WHERE
		formula_id = formula_id_p
		AND line_type = 1
	ORDER BY
		line_no;

	/* Select fm_qty and fm_qty_um from costing formula */
	CURSOR costing_pri_product_cur(formula_id_p fm_form_mst.formula_id%TYPE,
			item_id_p ic_item_mst.item_id%TYPE)
	IS
	SELECT qty, item_um
	FROM
		fm_matl_dtl
	WHERE
		formula_id = formula_id_p
		AND line_type = 1
		AND item_id = item_id_p
	ORDER BY
		line_no;
	n_scale NUMBER := 0;

BEGIN
       IF  Pkg_var_Batch_id <> batch_id_vi THEN
            pkg_var_batch_id := batch_id_vi;
             pkg_var_scale_factor_v:=1;
             Pkg_var_b:=0;
             Pkg_var_fm_qty_v:=0;
	     Pkg_var_fm_qty_um_v:=' ';
	     Pkg_var_pm_qty_v:=0;
	     Pkg_var_pm_qty_um_v:=' ';
             Pkg_var_all_linear:=TRUE;
        ELSE
            Scale_factor_v:=pkg_var_scale_factor_v;
                         b:=Pkg_var_b;
                  fm_qty_v:=Pkg_var_fm_qty_v;
	       fm_qty_um_v:=Pkg_var_fm_qty_um_v;
	          pm_qty_v:=Pkg_var_pm_qty_v;
	       pm_qty_um_v:=Pkg_var_pm_qty_um_v;
                all_linear:=pkg_var_all_linear;
           GOTO post_scaling;
        END IF;

	/* Select primary product from fm_matl_dtl for the formula_id */
	OPEN primary_product_cur(formula_id_vi);
	FETCH primary_product_cur INTO primary_product_v;
	CLOSE primary_product_cur;

        IF line_type_vi =1 and Line_no_vi =1 THEN
           pm_qty_v :=plan_qty_vi;
           pm_qty_um_v:= item_um_vi;
        ELSE
           SELECT plan_qty,item_um into pm_qty_v,pm_qty_um_v
             FROM gme_material_details
            WHERE batch_id = batch_id_vi
              AND line_type =1
              AND item_id = primary_product_v;
        END IF;

	/* Retrieve the batch parameters needed for determining the
	costing formula */

        batch_status_v:=batch_status_vi;
        wip_whse_v:=wip_whse_code_vi;

		IF batch_status_v = 3 THEN
			cost_date_v := actual_cmplt_date_vi;
		ELSIF batch_status_v = 4 THEN
			cost_date_v := batch_close_date_vi;
		END IF;

		/* Determine the Cost Whse */
		cost_whse_v := gmca_cost_whse(wip_whse_v, cost_date_v);
        BEGIN
		/* Determine the appropriate cost calendar/period */
		SELECT d.calendar_code, d.period_code
		INTO cost_calendar_v, cost_period_v
		FROM    cm_cldr_dtl d,
			cm_cldr_hdr h,
			sy_orgn_mst o,
			ic_whse_mst w
		WHERE
			w.whse_code      = cost_whse_v
		AND     w.orgn_code      = o.orgn_code
		AND     o.co_code        = h.co_code
		AND     h.cost_mthd_code = cost_mthd_vi
		AND     h.calendar_code = d.calendar_code
		AND     d.start_date    <= cost_date_v
		AND     d.end_date      >= cost_date_v
		AND     h.delete_mark   = 0
		AND     d.delete_mark   = 0;

		/* Now select the fmeff_id if available */
		SELECT max(fmeff_id) INTO cost_fmeff_id_v
		FROM cm_cmpt_dtl
		WHERE item_id		= primary_product_v
		AND whse_code		= cost_whse_v
		AND calendar_code	= cost_calendar_v
		AND period_code		= cost_period_v
		AND cost_mthd_code	= cost_mthd_vi
		AND delete_mark		= 0;

		SELECT formula_id
		INTO cost_formula_id_v
		FROM fm_form_eff
		WHERE fmeff_id = cost_fmeff_id_v;
	EXCEPTION
		WHEN others THEN
			cost_formula_id_v := 0;
	END;
	/* end of block to retrieve costing formula */
	IF cost_formula_id_v <= 0 THEN
		scaling_error_v := 1;
		GOTO post_scaling;
	END IF;

	/* The costing formula is known.  Get the fm_qty and fm_qty_um from the costing
	formula for the primary product */
	/*SKARIMIS Fixed a bug. Instead of Costing formula id, regular formula id is being passed. fixed the issue) */
        OPEN costing_pri_product_cur(cost_formula_id_v, primary_product_v);
	FETCH costing_pri_product_cur INTO fm_qty_v, fm_qty_um_v;
	CLOSE costing_pri_product_cur;


	/* The fm_qty and pm_qty can be in different uoms.  do uom conversion
	to the item's primary uom */
	/* get the prim product's uom */
	SELECT item_um INTO pri_prod_um_v
	FROM ic_item_mst
	WHERE
		item_id = primary_product_v;

	/* for now pass 0 as lot id (default lot?) */
	IF fm_qty_um_v <> pri_prod_um_v THEN
		/* do uom conversion */
		fm_qty_v := gmca_uomcv(primary_product_v, 0, fm_qty_um_v,
			fm_qty_v, pri_prod_um_v);
	END IF;
 /*SKARIMIS*/
               Pkg_var_fm_qty_v:=fm_qty_v;
	       Pkg_var_fm_qty_um_v:=fm_qty_um_v;

	IF pm_qty_um_v <> pri_prod_um_v THEN
		/* do uom conversion */
		pm_qty_v := gmca_uomcv(primary_product_v, 0, pm_qty_um_v,
			pm_qty_v, pri_prod_um_v);
	END IF;
/*skarimis*/
               Pkg_var_pm_qty_v:=pm_qty_v;
	       Pkg_var_pm_qty_um_v:=pm_qty_um_v;

	/* Now compute the scale factor */
	IF fm_qty_v <> 0 THEN
		scale_factor_v := pm_qty_v / fm_qty_v;
                pkg_var_scale_factor_v:=scale_factor_v;
	ELSE
		scaling_error_v := 1;
		GOTO post_scaling;
	END IF;

	/* now scale factor is known.  scale the formula. */
	/* begin of nested block for scaling */
	/* refer to OPM scaling routines for detailed info */
	DECLARE
		/* Initialize all variables otherwise null is implicitly used
		if they are used without assignment!! */
		num_fixed_items_v	NUMBER := 0;
		num_primaries		NUMBER := 0;
		num_secondaries		NUMBER := 0;
		denominator		NUMBER := 0;
		numerator		NUMBER := 0;
		k			NUMBER := 0;
		P0 NUMBER := 0; P1 NUMBER := 0; S0 NUMBER := 0; S2 NUMBER := 0;

		fm_yield_type_v		sy_uoms_typ.um_type%TYPE := ' ';
		fm_yield_type_um_v	sy_uoms_mst.um_code%TYPE := ' ';
		tmp_qty_v		NUMBER := 0;

		/* products are primary items per scaling routine */

		CURSOR prod_cur(formula_id_p fm_form_mst.formula_id%TYPE) IS
			SELECT formulaline_id, item_id, qty, 0 as scaled_qty, scale_type, item_um
			FROM fm_matl_dtl
			WHERE formula_id = formula_id_p
			AND line_type in (1,2)
			ORDER BY line_type;

		CURSOR ing_cur(formula_id_p fm_form_mst.formula_id%TYPE) IS
			SELECT formulaline_id, item_id, qty, 0 as scaled_qty, scale_type, item_um
			FROM fm_matl_dtl
			WHERE formula_id = formula_id_p
			AND line_type = -1;

	BEGIN

		/* If all items in formula are linearly scaled, we dont need any
		uom conversions.  simply multiply the qty with the scale factor.
		If atleast one item is fixed qty scale type then we need uom
		conversions to fm_yield_type */

		SELECT count(*) INTO num_fixed_items_v
		FROM
			fm_matl_dtl
		WHERE
			formula_id	= cost_formula_id_v
			AND scale_type	= 0;

		IF num_fixed_items_v <= 0 THEN
			all_linear := TRUE;
 /*skarimis*/     pkg_var_all_linear:=all_linear;
			GOTO scaling_ok;
		END IF;

		/* Now at least one item of fixed scale type exists.  So do
		necessary uom conversions */
		/* Get the um_type of fm_yield_type */

		/* 01/12/1999 RS - using profile values instead of sy_cont_tbl */
/* skarimis replaced FND_PROFILE.VALUE_WNPS with FND_PROFILE.VALUE */
		SELECT	FND_PROFILE.VALUE('FM_YIELD_TYPE')
		INTO	fm_yield_type_v
		FROM	dual;

		/* RS end changes for rel 11 */

		/* now get the std uom of fm_yield_type */
		SELECT std_um INTO fm_yield_type_um_v
		FROM
			sy_uoms_typ
		WHERE
			um_type = fm_yield_type_v;

		/* if there is no fm_yield_type_um then exit scaling with error */
		IF ((fm_yield_type_v is null) or (fm_yield_type_v = ' ')) THEN
			scaling_error_v := 1;
			GOTO scaling_end;
		END IF;

		/* Convert qtys into fm_yield_type_um_v */
		FOR scale_rec_tmp IN prod_cur(cost_formula_id_v) LOOP
			n_scale := n_scale + 1;
			num_primaries := num_primaries + 1;

			/* scale primaries and compute total */
			tmp_qty_v := 0;
			tmp_qty_v := gmca_uomcv(scale_rec_tmp.item_id, 0, scale_rec_tmp.item_um,
				scale_rec_tmp.qty, fm_yield_type_um_v);
			P0 := P0 + tmp_qty_v;
			IF scale_rec_tmp.scale_type <> 0 THEN
				P1 := P1 + tmp_qty_v * scale_factor_v;
			ELSE
				P1 := P1 + tmp_qty_v;
				all_linear := FALSE;
               /*skarimis*/     pkg_var_all_linear:=all_linear;
			END IF;

		END LOOP;

		FOR scale_rec_tmp IN ing_cur(cost_formula_id_v) LOOP
			n_scale := n_scale + 1;
			num_secondaries := num_secondaries + 1;

			/* sum secondaries */
			tmp_qty_v := 0;
			tmp_qty_v := gmca_uomcv(scale_rec_tmp.item_id, 0, scale_rec_tmp.item_um,
				scale_rec_tmp.qty, fm_yield_type_um_v);
			IF scale_rec_tmp.scale_type <> 0 THEN
				/* sum non_fixed secondaries */
				denominator := denominator + tmp_qty_v;
			ELSE
				S2 := S2 + tmp_qty_v;
				all_linear := FALSE;
              /*skarimis*/     pkg_var_all_linear:=all_linear;
			END IF;

		END LOOP;

		IF denominator = 0 THEN
			/* No non-fixed secondaries, return error */
			/* return 0 */
			scaling_error_v := 1;
			GOTO scaling_end;
		END IF;

		S0 := denominator + S2;

		/* now n_scale holds the total num of records, but recs start at 0 */
		IF all_linear THEN
			null;
		ELSE
			null;
		END IF;

		IF all_linear THEN
		/* all items are linearly scaled, hence all are scaled with the
		same scale factor irrespective of UOM */
			/* return */
			null;
			GOTO scaling_ok;
		END IF;

		/* some items are fixed scaling type */
		/* do UOM conversions to FM_YIELD_TYPE : Yet to be Done */


		IF (P0 = 0) OR (S0 = 0) THEN
			/* return error */
			scaling_error_v := 1;
			GOTO scaling_end;
		END IF;

		k := P0 / S0;
		numerator := (P1 / k) - S2;
		b := numerator / denominator;
                pkg_var_b:=b;
		<<scaling_ok>>
		/* all ok, return success */
		scaling_error_v := 0;

		<<scaling_end>>
		null;
	EXCEPTION
		WHEN others THEN
			scaling_error_v := 1;
	END;
	/* End of nested block for scaling */

	<<post_scaling>>
	/* Now we know the primary scaling factor, a (input) and the
	secondary scaling factor, b (calculated).
	Note: fm_qty_v, fm_qty_um_v, pm_qty_v, pm_qty_um_v are reused */

             batch_item_id_v:=item_id_vi;
             batch_formulaline_id_v:=formulaline_id_vi;
             batch_item_qty_v:=actual_qty_vi;
		pm_qty_um_v := item_um_vi;

	fm_qty_v := 0;
	pm_qty_v := batch_item_qty_v;

	IF scaling_error_v = 1 THEN
		/* error during scaling, return null */
		variance_v := 0;
		RETURN NULL;
	ELSE
		/* Select the fm_qty from the fm_matl_dtl table if the batch
		formulaline_id is non-zero, otherwise fm_qty is 0 */
		IF batch_formulaline_id_v <> 0 THEN
			BEGIN
				/* Should fetch only one row */
				SELECT qty, line_type, scale_type, item_um
				INTO fm_qty_v, fm_line_type_v, fm_scale_type_v,
					fm_qty_um_v
				FROM fm_matl_dtl
				WHERE formula_id = formula_id_vi
				AND item_id = batch_item_id_v
				AND formulaline_id = batch_formulaline_id_v;

				/* Now multiply by the appropriate factor */
				IF all_linear THEN
					fm_qty_v := fm_qty_v * scale_factor_v;
				ELSE
					/* some items are fixed scaled */
					/* If fixed do nothing, if linear multiply
					by either a or b */
					IF fm_scale_type_v <> 0 THEN
						IF fm_line_type_v = -1 THEN
							/* Ingredient */
							fm_qty_v := fm_qty_v * b;
						ELSE
							/* Prod or By-Prod */
							fm_qty_v := fm_qty_v * scale_factor_v;
						END IF;
					END IF;
				END IF; /* end if all_linear */

			EXCEPTION
				WHEN others THEN
					fm_qty_v := 0;
			END; /* end of block for getting formula qty */
		ELSE
			fm_qty_v := 0;
		END IF; /* end if batch_formulaline_id */

		/* yield or usage or sub = batch_item_qty - scaled fm_qty */
		variance_v := pm_qty_v - fm_qty_v;
	END IF; /* end if scaling_error */

	/* Return the fm_qty since any errors would be easier to detect */
	/* Convert the fm_qty to the item_uom */
	fm_qty_v := gmca_iuomcv(batch_item_id_v, 0, fm_qty_um_v, fm_qty_v);
        RETURN fm_qty_v;

EXCEPTION
	WHEN others THEN
		RETURN NULL;
END gmca_variance;



	FUNCTION gmca_iuomcv(item_id_vi Number ,
			lot_id_vi Number ,
			from_uom_vi Varchar2,
			from_qty_vi number)
	RETURN NUMBER IS

	-- Variable declaration
	prim_um_v 	VARCHAR2(4) ;
	to_qty_v	NUMBER;

	BEGIN

	-- Init vars.:
	prim_um_v := ' ';
	to_qty_v := 0;

	-- Get the primary UOM for the item
	BEGIN
		SELECT im.item_um
		INTO   prim_um_v
		FROM ic_item_mst im
		WHERE im.item_id = item_id_vi;

		to_qty_v := gmca_uomcv(item_id_vi, lot_id_vi,
			from_uom_vi, from_qty_vi, prim_um_v);

		RETURN to_qty_v;

	EXCEPTION
		WHEN no_data_found THEN
		RETURN 0 ;
	END;

	END gmca_iuomcv ; -- End of Function

	FUNCTION gmca_uomcv(item_id_vi Number ,
			lot_id_vi Number ,
			from_uom_vi Varchar2,
			from_qty_vi number,
			to_uom_vi varchar2 )
	RETURN NUMBER IS

	-- Variable declaration
	prim_um 		varchar2(4) ;
	prim_um_type 		varchar2(4) ;
	prim_std_um		varchar2(4) ;
	prim_stnd_factor	Number;

	from_um_type 		varchar2(4)  ;
	from_stnd_um 		varchar2(4) ;
	from_stnd_factor 	Number  ;

	to_um_type		varchar2(4) ;
	to_stnd_um 		varchar2(4) ;
	to_stnd_factor 		Number  ;
	to_qty 			Number  ;

	type_cnv_factor_from 	Number ;
	type_cnv_factor_to 	Number ;

	error_code NUMBER;
	error_msg VARCHAR2(241);

	BEGIN

	-- Init vars.:
	error_code := 0 ;
	error_msg  := '' ;
	to_qty := 0;

	-- If from to to UOMs are same , no need to convert
	IF from_uom_vi = to_uom_vi THEN
		to_qty := from_qty_vi ;
		-- (not used) error_code := -3110 ;
		-- (not used) error_msg := 'Do Not Need To Convert !!';
		RETURN to_qty ;
	END IF ;

	-- Get the primary UOM for the item
	BEGIN
		SELECT im.item_um,
			um.um_type,
			ut.std_um,
			um.std_factor
		INTO   prim_um,
			prim_um_type,
			prim_std_um,
			prim_stnd_factor
		FROM sy_uoms_typ ut,sy_uoms_mst um, ic_item_mst im
		WHERE im.item_id = item_id_vi
			AND um.um_code = im.item_um
			AND um.um_type = ut.um_type ;
		EXCEPTION WHEN NO_DATA_FOUND  THEN
			-- The item is invalid
			error_code := -3111 ;
			RETURN to_qty ;
	END;

	-- Get the standard UOM and the conversion factor for the from_UOM
	BEGIN
		SELECT  um.um_type ,
			ut.std_um ,
			um.std_factor
		INTO
			from_um_type,
			from_stnd_um,
			from_stnd_factor
		FROM sy_uoms_typ ut,sy_uoms_mst um
		WHERE um.um_type = ut.um_type
			and um.um_code = from_uom_vi ;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			-- Invalid from_UOM provided for conversion
			error_code := -3112 ;
			RETURN 0;
	END;

	-- Get the standard UOM and the conversion factor for the to_UOM
	BEGIN
		SELECT um.um_type ,
			ut.std_um ,
			um.std_factor
		INTO
			to_um_type,
			to_stnd_um,
			to_stnd_factor
		FROM sy_uoms_typ ut,sy_uoms_mst um
		WHERE um.um_type = ut.um_type
			and um.um_code = to_uom_vi ;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			-- Invalid to_UOM provided for converion
			error_code:= -3113 ;
			RETURN 0 ;
	END;

	-- Compare the from and to UOM types and decide which processing is required

	IF from_um_type = to_um_type THEN
		type_cnv_factor_from := 1 ;
		type_cnv_factor_to := 1 ;
	ELSE
		-- If the types do not match, use ic_item_cnv to convert to primary unit

		-- (Case 1): if to uom is same as primary unit
		IF (to_um_type = prim_um_type) THEN
		  BEGIN
			SELECT type_factor
			INTO type_cnv_factor_from
			FROM ic_item_cnv
			WHERE item_id = item_id_vi
			and lot_id = lot_id_vi
			and um_type = from_um_type
			;
			type_cnv_factor_to := 1 ;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				-- No conversion data for from_UOM available
				error_code :=  -3114 ;
				error_msg := 'CONVERSION DATA NOT AVAILABLE !!';
	 			RETURN 0;
		  END ;

		-- (Case 2): if from uom is same as primary unit
		ELSIF from_um_type = prim_um_type THEN
		   BEGIN
			SELECT type_factor
			INTO type_cnv_factor_to
			FROM ic_item_cnv
			WHERE item_id = item_id_vi
				and lot_id = lot_id_vi
				and um_type = to_um_type
			;
			type_cnv_factor_from := 1 ;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				-- No conversion data for from_UOM available
				error_code :=  -3114 ;
				error_msg := 'CONVERSION DATA NOT AVAILABLE !!';
				RETURN 0;
		   END ;
		ELSE
		-- (Case 3): if neither from_uom_vi nor to_uom_vi is a primary unit
		-- first convert to primary um type
		-- then to std uom in the primary um
		  BEGIN
			SELECT type_factor
			INTO type_cnv_factor_from
			FROM ic_item_cnv
			WHERE item_id = item_id_vi
				and lot_id = lot_id_vi
				and um_type = from_um_type
			;

			SELECT type_factor
			INTO type_cnv_factor_to
			FROM ic_item_cnv
			WHERE item_id = item_id_vi
				and lot_id = lot_id_vi
				and um_type = to_um_type
			;

			EXCEPTION
                        WHEN NO_DATA_FOUND THEN
				-- No conversion data for to_UOM available
				error_code :=  -3114 ;
				error_msg := 'CONVERSION DATA NOT AVAILABLE !!';
				RETURN 0 ;
		   END ;
		END IF;

		-- The conversion formula

	END IF ;
	/*SKARIMIS*/
         to_qty := from_qty_vi * (from_stnd_factor * type_cnv_factor_from) / (to_stnd_factor * type_cnv_factor_to) ;

	RETURN to_qty;

	END gmca_uomcv ; -- End of Function

	FUNCTION gmca_cost_whse(
		inv_whse_vi		IN cm_whse_asc.whse_code%TYPE,
		asc_date_vi		IN DATE)
	RETURN VARCHAR
	IS
		cost_whse_v	cm_whse_asc.cost_whse_code%TYPE := NULL;
		CURSOR cost_whse_cur(
			inv_whse_v cm_whse_asc.whse_code%TYPE,
			asc_date_v DATE)
		IS
			SELECT cost_whse_code
			FROM	cm_whse_asc
			WHERE	whse_code = inv_whse_v
			AND	eff_start_date <= asc_date_v
			AND	eff_end_date >= asc_date_v
			AND	delete_mark = 0;
	BEGIN
		IF NOT cost_whse_cur%ISOPEN THEN
			OPEN cost_whse_cur(inv_whse_vi, asc_date_vi);
		END IF;

		FETCH cost_whse_cur INTO cost_whse_v;

		IF cost_whse_cur%NOTFOUND THEN
			cost_whse_v := NULL;
		END IF;

		IF cost_whse_cur%ISOPEN THEN
			CLOSE cost_whse_cur;
		END IF;

		IF cost_whse_v IS NOT NULL THEN
			RETURN cost_whse_v;
		ELSE
			RETURN inv_whse_vi;
		END IF;

	EXCEPTION
		WHEN others THEN
			IF cost_whse_cur%ISOPEN THEN
				CLOSE cost_whse_cur;
			END IF;

			RETURN inv_whse_vi;

	END gmca_cost_whse;

	FUNCTION gmca_whse_currency(
		whse_code_vi IN ic_whse_mst.whse_code%TYPE)
	RETURN VARCHAR2
	IS
		currency_v gl_plcy_mst.base_currency_code%TYPE := null;
		CURSOR whse_currency_cur(
			whse_code_vi IN ic_whse_mst.whse_code%TYPE)
		IS
			SELECT base_currency_code
			FROM
				gl_plcy_mst p,
				sy_orgn_mst o,
				ic_whse_mst w
			WHERE
				w.whse_code = whse_code_vi
				AND w.orgn_code = o.orgn_code
				AND o.co_code = p.co_code ;
	BEGIN
		IF NOT whse_currency_cur%ISOPEN THEN
			OPEN whse_currency_cur(whse_code_vi);
		END IF;

		FETCH whse_currency_cur INTO currency_v;

		IF whse_currency_cur%ISOPEN THEN
			CLOSE whse_currency_cur;
		END IF;

		IF currency_v IS NOT NULL THEN
			RETURN currency_v;
		ELSE
			RETURN null;
		END IF;

	EXCEPTION
		WHEN others THEN
			IF whse_currency_cur%ISOPEN THEN
				CLOSE whse_currency_cur;
			END IF;

			RETURN null;
	END gmca_whse_currency;
END pmi_cost_analz_pack ;

/
