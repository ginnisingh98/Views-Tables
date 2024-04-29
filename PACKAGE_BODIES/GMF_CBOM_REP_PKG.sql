--------------------------------------------------------
--  DDL for Package Body GMF_CBOM_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_CBOM_REP_PKG" AS
/* $Header: GMFIBOMB.pls 120.4 2007/12/17 10:25:02 pmarada noship $ */

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    Get_Quantity                                                         |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the formula product quantity and ingradient    |
REM|    quantity in item's primary UOM                                       |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Rajesh Patangya     (OPM Development)            |
REM|    07-NOV-2007 WilliamJohn Harris
REM|    14-Dec-2007 WilliamJohn Harris -- added text to error returns
REM|                                                                         |
REM+=========================================================================+
*/

FUNCTION Get_Quantity (
 p_invy_item_id        IN NUMBER,
 p_prod_invy_item_id   IN NUMBER,
 p_prod_ingr_ind       IN VARCHAR2,  -- values 'P', 'I', or 'B'
 p_organization_id     IN NUMBER ,
 p_cost_type_id        IN NUMBER ,
 p_period_id           IN NUMBER
) RETURN VARCHAR2 IS

/*  Local variables */
l_ret_val       VARCHAR2(200)  := ' ' ;
l_quantity      NUMBER  := 0 ;
l_qty_conv      NUMBER  := 0 ;
l_uom           VARCHAR2(3)  := ' ' ;
item_primary_uom VARCHAR2(3)  := ' ' ;


BEGIN

-- FUNCTION Get_Quantity () -- gets quantity and Uom
-- 02-Nov-07 : if item-uom different from formula uom, scale the
--		item quantity to item-uom according to the uom conversion

	SELECT primary_uom_code into item_primary_uom
	 FROM mtl_system_items_b
	 WHERE inventory_item_id = p_invy_item_id
	  AND organization_id = p_organization_id ;

	IF (p_prod_ingr_ind = 'P') THEN
               --SELECT std_qty, form_prod_uom into l_quantity, l_uom
               SELECT product_qty, form_prod_uom into l_quantity, l_uom
                FROM cm_scst_led
                WHERE std_qty > 0
                  AND rownum < 2
                  AND cmpntcost_id in (SELECT cmpntcost_id
                                       FROM cm_cmpt_dtl
                                       WHERE inventory_item_id = p_prod_invy_item_id
                                         AND period_id = p_period_id
                                         AND cost_type_id = p_cost_type_id
                                         AND organization_id = p_organization_id
                                       ) ;

	ELSIF ((p_prod_ingr_ind = 'I')  OR  (p_prod_ingr_ind = 'B')) THEN
               SELECT item_fmqty, item_fmqty_uom INTO l_quantity, l_uom
                FROM cm_scst_led
                WHERE inventory_item_id = p_invy_item_id
                  AND rownum < 2
                  AND (line_type = -1  OR  line_type = 2)
                  AND cmpntcost_id in (select cmpntcost_id from cm_cmpt_dtl
                                       WHERE inventory_item_id = p_prod_invy_item_id
                                         AND period_id = p_period_id
                                         AND cost_type_id = p_cost_type_id
                                         AND organization_id = p_organization_id
                                       ) ;
      	ELSE
             --RETURN -1 ;
	     l_ret_val       := 'Error -1' ;
	     RETURN l_ret_val ;
      	END IF ;

	IF (item_primary_uom <> l_uom) THEN
	--	convert l_quantity to primary uom
		l_qty_conv := inv_convert.inv_um_convert(p_invy_item_id, NULL, p_organization_id, 5, l_quantity, l_uom, item_primary_uom, NULL, NULL) ;
		IF (l_qty_conv < 0) THEN
			RETURN l_qty_conv ;
		ELSE
			l_quantity := l_qty_conv ;
		END IF ;
	END IF ;

      	l_ret_val       := l_quantity || ' / ' || item_primary_uom ;
      	RETURN l_ret_val ;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
       --RETURN -2 ;
      	l_ret_val       := 'Error -2' ;
      	RETURN l_ret_val ;
     WHEN OTHERS THEN
       --RETURN -3 ;
      	l_ret_val       := 'Error -3' ;
      	RETURN l_ret_val ;
END Get_Quantity ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    get_le_name                                                          |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the Legal entity Name                          |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Prasad Marada       (OPM Development)            |
REM|                                                                         |
REM+=========================================================================+
*/

FUNCTION get_le_name(p_le_id IN NUMBER) RETURN VARCHAR2 IS

  l_le_name gmf_legal_entities.legal_entity_name%TYPE :='';

BEGIN
    -- get Legal entity name
    SELECT legal_entity_name INTO l_le_name FROM gmf_legal_entities
    WHERE legal_entity_id = p_le_id;

     RETURN l_le_name;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN l_le_name;
   WHEN OTHERS THEN
     RETURN l_le_name;

END get_le_name;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    get_currency                                                         |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the currency used by legal enity               |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Rajesh Patangya                                  |
REM|                                                                         |
REM+=========================================================================+
*/
FUNCTION get_currency(p_le_id IN NUMBER) RETURN VARCHAR2 IS

  l_currency  gmf_legal_entities.base_currency_code%TYPE :='';

BEGIN
    SELECT base_currency_code INTO l_currency FROM gmf_legal_entities
    WHERE legal_entity_id = p_le_id;

     RETURN l_currency;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN l_currency;
   WHEN OTHERS THEN
     RETURN l_currency;

END get_currency;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    get_cost_type                                                        |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the cost type based on cost_type_id            |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Rajesh Patangya                                  |
REM|                                                                         |
REM+=========================================================================+
*/
FUNCTION get_cost_type(p_ct_id IN NUMBER) RETURN VARCHAR2 IS

    l_cost_type cm_mthd_mst.cost_mthd_code%TYPE :='';

BEGIN
   -- get Cost type name,
     SELECT cost_mthd_code INTO l_cost_type FROM cm_mthd_mst
     WHERE cost_type_id = p_ct_id;

     RETURN l_cost_type;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN l_cost_type;
   WHEN OTHERS THEN
     RETURN l_cost_type;

END get_cost_type;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    get_OrderBy                                                          |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the Order By cluase used by Query              |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Rajesh Patangya                                  |
REM|                                                                         |
REM+=========================================================================+
*/
FUNCTION get_OrderBy (p_sort_by IN NUMBER) RETURN VARCHAR2 IS

   l_org_where VARCHAR2(1000) := '';
BEGIN
  -- Build the order by clause
   IF NVL(p_sort_by,1)  = 1 THEN
      l_org_where := 'ORDER BY mp.organization_code, msi.CONCATENATED_SEGMENTS ' ;
   ELSE
      l_org_where := 'ORDER BY msi.CONCATENATED_SEGMENTS, mp.organization_code ' ;
   END IF;
        RETURN l_org_where;

END get_OrderBy;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    BeforeReportTrigger                                                  |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the Where cluase to support Queries            |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Rajesh Patangya                                  |
REM|                                                                         |
REM+=========================================================================+
*/
FUNCTION BeforeReportTrigger RETURN BOOLEAN IS
    l_where_clause  VARCHAR2(2000);
BEGIN
   l_where_clause := '1=1';
   p_where_clause := l_where_clause;
   RETURN TRUE;
END BeforeReportTrigger ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    get_Period_Code                                                      |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the Period code based on period_id             |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Rajesh Patangya                                  |
REM| 13-Dec-07 pmarada bug 6676681 changed the funtion to return period id   |
REM|                                                                         |
REM+=========================================================================+
*/
FUNCTION get_Period_Id(p_legal_entity_id IN NUMBER, p_calendar_code IN VARCHAR2,
                       p_period_code IN VARCHAR2, p_cost_type_id IN NUMBER) RETURN NUMBER IS

   l_period_id gmf_period_statuses.period_id%TYPE := -1;
BEGIN
    SELECT period_id INTO l_period_id FROM gmf_period_statuses
    WHERE legal_entity_id = p_legal_entity_id
      AND calendar_code   = p_calendar_code
      AND period_code     = p_period_code
      AND cost_type_id    = p_cost_type_id;
    RETURN l_period_id ;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN l_period_id ;
    WHEN OTHERS THEN
       RETURN l_period_id ;

END get_Period_Id;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    get_item_name                                                        |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the item name                                  |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Rajesh Patangya                                  |
REM|                                                                         |
REM+=========================================================================+
*/
FUNCTION get_item_name(v_item_id IN NUMBER) RETURN VARCHAR2 IS
   l_item mtl_system_items_b_kfv.CONCATENATED_SEGMENTS%TYPE := '';
BEGIN
    SELECT unique CONCATENATED_SEGMENTS INTO l_item
    FROM mtl_system_items_b_kfv where inventory_item_id = v_item_id;
    RETURN l_item ;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN l_item  ;
    WHEN OTHERS THEN
       RETURN l_item  ;

END get_item_name;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    get_category_name                                                    |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the category name                              |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Rajesh Patangya                                  |
REM|                                                                         |
REM+=========================================================================+
*/
FUNCTION get_category_name(v_cat_id IN NUMBER) RETURN VARCHAR2 IS

   l_category mtl_categories_kfv.CONCATENATED_SEGMENTS%TYPE := '';

BEGIN

   SELECT mc.concatenated_segments INTO l_category
   FROM mtl_default_category_sets mdc,
        mtl_category_sets mcs,
        mtl_categories_kfv mc
   WHERE mdc.functional_area_id = 19
     AND mdc.category_set_id = mcs.category_set_id
     AND mcs.structure_id = mc.structure_id
     AND mc.category_id = v_cat_id ;

   RETURN l_category ;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN l_category  ;
   WHEN OTHERS THEN
     RETURN l_category  ;

END get_category_name;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    get_OrderBy                                                          |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This function returns the Order By cluase used by Query              |
REM| HISTORY                                                                 |
REM|    Created 01-NOV-2007 Rajesh Patangya                                  |
REM|                                                                         |
REM+=========================================================================+
*/
FUNCTION get_Category (p_from_cat IN VARCHAR2,p_to_cat IN VARCHAR2) RETURN VARCHAR2 IS

   l_cat_where VARCHAR2(5000) := '';
BEGIN
  -- Build the order by clause
   IF p_from_cat IS NOT NULL OR p_to_cat IS NOT NULL THEN
     l_cat_where := ' AND EXISTS (SELECT mc.concatenated_segments ' ;
     l_cat_where := l_cat_where || ' FROM mtl_default_category_sets mdc, mtl_category_sets mcs, mtl_item_categories mic, ' ;
     l_cat_where := l_cat_where || ' mtl_categories_kfv mc WHERE mdc.functional_area_id = 19 ' ;
     l_cat_where := l_cat_where || ' AND mdc.category_set_id = mcs.category_set_id AND mcs.category_set_id = mic.category_set_id ' ;
     l_cat_where := l_cat_where || ' AND mcs.structure_id = mc.structure_id AND mic.inventory_item_id = ccd.inventory_item_id ' ;
     l_cat_where := l_cat_where || ' AND mic.organization_id = ccd.organization_id AND mic.category_id = mc.category_id ' ;
    l_cat_where := l_cat_where || ' AND mc.concatenated_segments >= NVL(:P_FROM_COST_CATEGORY,mc.concatenated_segments) ' ;
     l_cat_where := l_cat_where || ' AND mc.concatenated_segments <=  NVL(:P_TO_COST_CATEGORY, mc.concatenated_segments) )' ;
   ELSE
      l_cat_where := ' AND 1=1';
   END IF;
        RETURN l_cat_where;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN l_cat_where  ;
   WHEN OTHERS THEN
     RETURN l_cat_where  ;
END get_Category;

END gmf_cbom_rep_pkg ;

/
