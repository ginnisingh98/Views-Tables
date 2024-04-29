--------------------------------------------------------
--  DDL for Package PMI_COST_ANALZ_PACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PMI_COST_ANALZ_PACK" AUTHID CURRENT_USER as
/* $Header: PMICTANS.pls 120.0 2005/05/24 16:55:19 appldev noship $ */
        Pkg_var_Batch_id gme_batch_header.batch_id%TYPE:=0;
        Pkg_var_Scale_factor_v NUMBER;
        Pkg_var_b NUMBER;
        Pkg_var_fm_qty_v		fm_matl_dtl.qty%TYPE := 0;
	Pkg_var_fm_qty_um_v		sy_uoms_mst.um_code%TYPE := ' ';
	Pkg_var_pm_qty_v		gme_material_details.plan_qty%TYPE := 0;
	pkg_var_pm_qty_um_v		sy_uoms_mst.um_code%TYPE := ' ';
	Pkg_var_all_linear              boolean;


	FUNCTION gmca_get_cost( item_id_vi		IN ic_item_mst.item_id%TYPE,
		inv_whse_code_vi	IN cm_cmpt_dtl.whse_code%TYPE,
		cost_mthd_code_vi	IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		cost_date_vi		IN DATE)
	RETURN NUMBER;

	FUNCTION gmca_get_perbal(
		tr_date_vi IN DATE,
            co_code_vi IN sy_orgn_mst.co_code%TYPE,
		whse_code_vi IN ic_perd_bal.whse_code%TYPE,
		item_id_vi IN ic_perd_bal.item_id%TYPE)
	RETURN NUMBER;

	FUNCTION gmca_get_line_type(
		item_id_vi IN ic_perd_bal.item_id%TYPE)
	RETURN NUMBER;

	FUNCTION gmca_inv_perend(
		orgn_code_vi IN ic_cldr_dtl.orgn_code%TYPE,
		fiscal_year_vi IN ic_cldr_dtl.fiscal_year%TYPE,
		period_vi IN ic_cldr_dtl.period%TYPE)
	RETURN DATE;

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
        actual_qty_vi           IN gme_material_details.actual_qty%TYPE)
	RETURN NUMBER;


	FUNCTION gmca_get_onhandqty(p_whse_code IN ic_loct_inv.whse_code%TYPE,
                            p_item_id   IN ic_loct_inv.item_id%TYPE,
                            P_Location  IN ic_loct_inv.location%TYPE,
                            p_lot_id    IN ic_loct_inv.lot_id%TYPE )  RETURN NUMBER;

      FUNCTION gmca_get_meaning(p_lookup_typ  IN gem_lookups.lookup_type%TYPE,
                          p_lookup_cd   IN gem_lookups.lookup_code%TYPE )  RETURN VARCHAR2;

	FUNCTION gmca_iuomcv(item_id_vi Number ,
			lot_id_vi Number ,
			from_uom_vi Varchar2,
			from_qty_vi number)
	RETURN NUMBER ;

	FUNCTION gmca_uomcv(item_id_vi Number ,
			lot_id_vi Number ,
			from_uom_vi Varchar2,
			from_qty_vi number,
			to_uom_vi varchar2 )
	RETURN NUMBER;

	FUNCTION gmca_cost_whse(
		inv_whse_vi		IN cm_whse_asc.whse_code%TYPE,
		asc_date_vi		IN DATE)
	RETURN VARCHAR;

	FUNCTION gmca_whse_currency(
		whse_code_vi IN ic_whse_mst.whse_code%TYPE)
	RETURN VARCHAR2;

END;

 

/
