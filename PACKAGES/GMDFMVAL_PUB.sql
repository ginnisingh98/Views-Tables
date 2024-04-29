--------------------------------------------------------
--  DDL for Package GMDFMVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDFMVAL_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPFMVS.pls 120.2.12010000.1 2008/07/24 09:56:33 appldev ship $ */

/* Type Definition */
/* =============== */
TYPE formula_info_in IS RECORD
(
        formula_no      fm_form_mst.formula_no%TYPE     ,
        formula_vers    fm_form_mst.formula_vers%TYPE   ,
        formula_id      fm_form_mst.formula_id%TYPE	,
	recipe_no	gmd_recipes.recipe_no%TYPE	,
	recipe_version	gmd_recipes.recipe_version%TYPE	,
	recipe_id	gmd_recipes.recipe_id%TYPE	,
	user_name	fnd_user.user_name%TYPE		,
	item_no		mtl_system_items_kfv.concatenated_segments%TYPE
);

TYPE formula_info_out IS RECORD
(
        formula_no      fm_form_mst.formula_no%TYPE     ,
        formula_vers    fm_form_mst.formula_vers%TYPE   ,
        formula_id      fm_form_mst.formula_id%TYPE	,
		formulaline_id	fm_matl_dtl.formulaline_id%TYPE ,
		recipe_id	gmd_recipes.recipe_id%TYPE,
		user_id		fnd_user.user_id%TYPE
);


TYPE formula_table_out IS TABLE OF formula_info_out
        INDEX BY BINARY_INTEGER;


TYPE formula_detail_tbl IS TABLE OF fm_matl_dtl%rowTYPE
		INDEX BY BINARY_INTEGER;


/* Constants */
/* ========= */
ss_debug CONSTANT INTEGER           := 0;

p_called_from_forms	VARCHAR2(10) := 'YES';

/* Error Return Code Constants: */
/* =========================== */
FMVAL_FORMID_ERR           CONSTANT INTEGER := -92200;
FMVAL_ITEMID_ERR           CONSTANT INTEGER := -92201;
FMVAL_ITEMINACTIVE_ERR     CONSTANT INTEGER := -92202;
FMVAL_ITEMEXPERIMENTAL_ERR CONSTANT INTEGER := -92203;
FMVAL_ROUTEID_ERR          CONSTANT INTEGER := -92204;
FMVAL_CUSTID_ERR           CONSTANT INTEGER := -92205;
FMVAL_CLASS_ERR            CONSTANT INTEGER := -92206;
FMVAL_ERRINSERT_ERR        CONSTANT INTEGER := -92207;
FMVAL_TYPE_ERR             CONSTANT INTEGER := -92208;
FMVAL_COSTALLOC_ERR        CONSTANT INTEGER := -92209;
FMVAL_COSTPCT_ERR          CONSTANT INTEGER := -92210;
FMVAL_PRODUCT_FIND_ERR     CONSTANT INTEGER := -92211;
FMVAL_PRODUCT_INVUOM_ERR   CONSTANT INTEGER := -92212;
FMVAL_LOCKED_EFF           CONSTANT INTEGER := -92213;
FMVAL_FORMLINEID_ERR       CONSTANT INTEGER := -92214;
FMVAL_FORMEFFID_ERR        CONSTANT INTEGER := -92215;
FMVAL_DETAILLINE_ERR       CONSTANT INTEGER := -92216;

/* Functions and Procedures */
/* ======================== */
PROCEDURE validate_insert_record (P_formula_dtl IN  GMD_FORMULA_COMMON_PUB.formula_insert_rec_type,
  			          X_formula_dtl OUT NOCOPY GMD_FORMULA_COMMON_PUB.formula_insert_rec_type,
                                  xReturn OUT NOCOPY VARCHAR2);

  PROCEDURE validate_update_record(P_formula_dtl  IN  GMD_FORMULA_COMMON_PUB.formula_update_rec_type,
  			           X_formula_dtl OUT NOCOPY GMD_FORMULA_COMMON_PUB.formula_update_rec_type,
                                   xReturn OUT NOCOPY VARCHAR2);

PROCEDURE get_element(	pElement_name	IN  VARCHAR2,
		     	pRecord_in 	IN  formula_info_in,
		     	xTable_out	OUT NOCOPY formula_table_out,
		     	xReturn		OUT NOCOPY VARCHAR2);

PROCEDURE get_element(	pElement_name		IN  VARCHAR2,
		      	pRecord_in		IN  formula_info_in,
                        pDate                   IN  DATE DEFAULT Null, --Bug 4479101
		      	xFormulaHeader_rec	OUT NOCOPY fm_form_mst%ROWTYPE,
		      	xFormulaDetail_tbl	OUT NOCOPY formula_detail_tbl,
		      	xReturn			OUT NOCOPY VARCHAR2);
/** Added the following 4 procedures for Item Substitution, bug 4479101 */
PROCEDURE get_substitute_items(pFormula_id         in NUMBER,
                               pDate               in DATE Default Null,
                               xFormulaDetail_tbl  OUT NOCOPY formula_detail_tbl);

PROCEDURE get_substitute_line_item(pFormulaline_id    in NUMBER,
                                   pItem_id            in Number Default Null,
                                   pQty                in Number Default Null,
                                   pUom                in Varchar2 Default Null,
                                   pScale_multiple     in NUMBER Default Null,
                                   pDate               in DATE,
                                   xFormulaDetail_tbl  Out NOCOPY formula_detail_tbl);

PROCEDURE Copy_Formula_Substitution_list(pOldFormula_id NUMBER
                                        ,pNewFormula_id NUMBER
                                        ,xReturn_Status OUT NOCOPY VARCHAR2
                                        , p_create_new_version VARCHAR2 DEFAULT 'N');

FUNCTION get_line_qty (P_line_item_id      in NUMBER
                      ,P_organization_id   in NUMBER
                      ,P_formula_qty       in NUMBER
                      ,P_formula_uom       in Varchar2
                      ,P_replacement_Item  in NUMBER
                      ,P_original_item_qty in NUMBER
                      ,P_original_item_uom in Varchar2
                      ,P_replace_unit_qty  in NUMBER
                      ,P_replace_unit_uom  in Varchar2
                      ,P_replacement_uom       in Varchar2) RETURN Number;



PROCEDURE check_rework_type(pType_value  IN 	VARCHAR2,
                            xReturn      IN OUT NOCOPY VARCHAR2);

PROCEDURE get_formula_id(pformula_no  IN  VARCHAR2,
                         pversion     IN  NUMBER,
                         xvalue       OUT NOCOPY NUMBER,
                         xreturn_code OUT NOCOPY NUMBER);

PROCEDURE get_formulaline_id(pformulaline_id 	IN  NUMBER,
			     xreturn_code 	OUT NOCOPY NUMBER);

PROCEDURE get_item_id(pitem_no     	     IN  VARCHAR2,
                      pinventory_item_id     IN  NUMBER,
   		      porganization_id       IN  NUMBER,
                      xitem_id     	     OUT NOCOPY NUMBER,
                      xitem_um     	     OUT NOCOPY VARCHAR2,
                      xreturn_code 	     OUT NOCOPY NUMBER);

PROCEDURE determine_product(pformula_id  IN  NUMBER,
                            xitem_id     OUT NOCOPY NUMBER,
                            xitem_um     OUT NOCOPY VARCHAR2,
                            xreturn_code OUT NOCOPY NUMBER);

FUNCTION formula_class_val(pform_class  VARCHAR2) RETURN NUMBER;

--Begin Bug#3090630 P.Raghu
--Changed datatype of pvalue parameter to VARCHAR2 from NUMBER.
FUNCTION type_val(ptype_name VARCHAR2,
                  pvalue     VARCHAR2) RETURN NUMBER;
--End Bug#3090630

FUNCTION cost_alloc_val(pcost_alloc NUMBER,
                        pline_type  NUMBER) RETURN NUMBER;

FUNCTION locked_effectivity_val(pformula_id NUMBER) RETURN NUMBER;

FUNCTION GMD_EFFECTIVITY_LOCKED_STATUS(pfmeff_id NUMBER) RETURN VARCHAR2;

FUNCTION convertuom_val(pitem_id NUMBER,
                        pfrom_uom VARCHAR2,
                        pto_uom   VARCHAR2) RETURN NUMBER;

FUNCTION detail_line_val(pformula_id 	NUMBER,
			 pline_no	NUMBER,
			 pline_type	NUMBER) RETURN NUMBER;

/*Functions added as part of Default Status Build (Bug 3408799)*/

FUNCTION check_expr_items (V_formula_id IN NUMBER) RETURN BOOLEAN;
FUNCTION output_qty_zero  (V_formula_id IN NUMBER) RETURN BOOLEAN;
FUNCTION inactive_items   (V_formula_id IN NUMBER) RETURN BOOLEAN;
END GMDFMVAL_PUB;


/
