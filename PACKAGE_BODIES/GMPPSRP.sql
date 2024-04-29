--------------------------------------------------------
--  DDL for Package Body GMPPSRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMPPSRP" as
/* $Header: GMPPSRPB.pls 120.4.12010000.3 2009/11/19 13:17:18 vpedarla ship $ */

   --Package Declarations

	PROCEDURE ps_insert_header ;

	PROCEDURE ps_bucket_report ;

	FUNCTION ps_bucket_details (V_item_id  IN   NUMBER, V_organization_id IN   NUMBER) RETURN NUMBER;

	PROCEDURE ps_get_safety_stock(V_item_id NUMBER, V_organization_id NUMBER) ;

        PROCEDURE get_onhand_qty(V_item_id NUMBER, V_organization_id NUMBER) ;

	G_matl_rep_id             NUMBER := 0;
        G_orgnanization_id        NUMBER;
--        G_schedule                VARCHAR2(16);
        G_schedule_id             NUMBER(10);
        G_category_set            NUMBER(30);
        G_structure_id            NUMBER;
--        G_category_set_id         NUMBER;
        G_fcategory               VARCHAR2(240);
        G_tcategory               VARCHAR2(240);
        G_fbuyer                  VARCHAR2(240);
        G_tbuyer                  VARCHAR2(240);
        G_fplanner                VARCHAR2(10);
        G_tplanner                VARCHAR2(10);
        G_forg                    VARCHAR2(3);
        G_torg                    VARCHAR2(3);
        G_fitem                   VARCHAR2(240);
        G_titem                   VARCHAR2(240);
	G_on_hand1                NUMBER := 0;   /* B3009969 */
	G_on_hand2                NUMBER := 0;   /* B3009969 */
	G_total_ss		  NUMBER := 0;
        G_nonnet_ind              NUMBER := 0;
	G_log_text                VARCHAR2(1000);
        G_template                VARCHAR2(100);
        G_template_locale         VARCHAR2(6);


	TYPE planning_rec_typ  IS RECORD(planning_class VARCHAR2(8),item_id NUMBER);
	TYPE planning_tab_typ  IS TABLE OF planning_rec_typ INDEX BY BINARY_INTEGER;
 	G_planning_tab         planning_tab_typ;

	TYPE item_rec_typ  IS RECORD
        (
           inventory_item_id    NUMBER,
           organization_id      NUMBER,
           category_id          NUMBER
        );
	TYPE item_tab_typ  IS TABLE OF item_rec_typ INDEX BY BINARY_INTEGER;
 	G_item_tab         item_tab_typ;

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	gmp_print_mps                                         |
|                                                                             |
| DESCRIPTION		Procedure to submit the request for report            |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                               |
|                                                                             |
+============================================================================*/

PROCEDURE gmp_print_mps
			 (	errbuf              OUT NOCOPY VARCHAR2,
 				retcode             OUT NOCOPY VARCHAR2,
                                V_organization_id   IN NUMBER,
                                V_schedule          IN NUMBER,
-- 				V_schedule_id  	    IN NUMBER,
                                V_Category_Set      IN NUMBER,
                                V_Structure_Id      IN NUMBER,
--                                V_Category_set_id   IN NUMBER,
                                V_fcategory         IN VARCHAR2,
                                V_tcategory         IN VARCHAR2,
                                V_fbuyer            IN VARCHAR2,
                                V_tbuyer            IN VARCHAR2,
                                V_fplanner          IN VARCHAR2,
                                V_tplanner          IN VARCHAR2,
                                V_forg              IN VARCHAR2,
                                V_torg              IN VARCHAR2,
                                V_fitem             IN VARCHAR2,
                                V_titem             IN VARCHAR2,
                                V_template          IN VARCHAR2,
                                V_template_locale   IN VARCHAR2
 				)IS

 X_conc_id  NUMBER;
 X_status   BOOLEAN;
 X_ri_where VARCHAR2(1000);

 BEGIN

   retcode := 0;
   G_orgnanization_id :=       V_organization_id;
--   G_schedule :=               V_schedule;
   G_schedule_id :=            V_schedule;
   G_category_set :=           V_Category_Set;
   G_structure_id :=           V_Structure_Id;
--   G_category_set_id :=        V_category_set_id;
   G_fcategory :=              V_fcategory;
   G_tcategory :=              V_tcategory;
   G_fbuyer :=                 V_fbuyer;
   G_tbuyer :=                 V_tbuyer;
   G_fplanner :=               V_fplanner;
   G_tplanner :=               V_tplanner;
   G_forg :=                   V_forg;
   G_torg :=                   V_torg;
   G_fitem :=                  V_fitem;
   G_titem :=                  V_titem;
   G_template :=               V_template;
   G_template_locale :=        V_template_locale;

   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Calling Modified gmp_print_mps with values ');
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_orgnanization_id '||to_char(G_orgnanization_id));
--   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_schedule '||to_char(G_schedule));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_schedule_id '||to_char(G_schedule_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_category_set '||G_category_set);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_structure_id '||to_char(G_structure_id));
--   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_category_set_id '||to_char(G_category_set_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_fcategory '||G_fcategory);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_tcategory '||G_tcategory);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_fbuyer '||G_fbuyer);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_tbuyer '||G_tbuyer);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_fplanner '||G_fplanner);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_tplanner '||G_tplanner);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_forg '||G_forg);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_torg '||G_torg);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_fitem '||G_fitem);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_titem '||G_titem);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_template '||G_template);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_template_locale '||G_template_locale);

   ps_insert_header;
   IF G_item_tab.COUNT > 0 THEN
      ps_bucket_report;
   END IF;
--   G_no_of_reports := to_char(to_number(G_no_of_reports) + 1);
   IF (G_matl_rep_id IS NOT NULL) THEN NULL;
     DELETE
     FROM   ps_matl_hdr pmh
     WHERE  pmh.matl_rep_id = G_matl_rep_id
        AND
        ((pmh.inventory_item_id NOT IN (SELECT pmd1.inventory_item_id
                               FROM   ps_matl_dtl pmd1
                               WHERE  pmd1.matl_rep_id = G_matl_rep_id))
        OR
        (pmh.organization_id NOT IN (SELECT organization_id
                                FROM ps_matl_dtl pmd2
                                WHERE pmd2.inventory_item_id = pmh.inventory_item_id
                                AND   pmd2.matl_rep_id = G_matl_rep_id)));
   END IF;

   ps_generate_xml;

         -- Invoke the concurrent manager from here
/*
         IF V_number_of_copies > 0 THEN
           X_status := FND_REQUEST.SET_PRINT_OPTIONS(V_printer, UPPER(V_user_print_style),
		                 V_number_of_copies, TRUE, 'N');
         END IF;
*/
         -- request is submitted to the concurrent manager
/*
   X_conc_id := FND_REQUEST.SUBMIT_REQUEST('GMP','RIPS2USR','',
      TO_CHAR(V_run_date,'YYYY/MM/DD HH24:MI:SS'), FALSE, TO_CHAR(G_matl_rep_id),
      TO_CHAR(G_Buyer_plnr_id), X_ri_where,chr(0),'',
                '', '','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','');
   IF X_conc_id = 0 THEN
      G_log_text := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);
      retcode:=2;
      EXIT;
   ELSE
      COMMIT ;
   END IF;
*/

END gmp_print_mps;  /***** END PROCEDURE ***************************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	ps_insert_header                                            |
|                                                                             |
| DESCRIPTION		Procedure to insert data into ps_matl_hdr                   |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                                |
|                                                                             |
+============================================================================*/

PROCEDURE ps_insert_header IS

 x_select               VARCHAR2(2000);
 cur_item               NUMBER;
 X_item_id              NUMBER;
 X_i                    NUMBER;
 X_org_id               NUMBER;
 X_category_id          NUMBER;
 X_rep_id               NUMBER;
 X_row_count            NUMBER;

  BEGIN

  x_select := ' SELECT DISTINCT '||
               ' msi.inventory_item_id, '||
               ' msi.organization_id, ';

  IF G_fcategory IS NOT NULL OR G_tcategory IS NOT NULL THEN
     x_select := x_select || ' mca.category_id category_id';
  ELSE
     x_select := x_select || ' -999 category_id ';
  END IF;
     x_select := x_select || ' FROM ';
--               ' po_agents pag, '||
--               ' ps_schd_dtl psd, '||

  IF G_fplanner IS NOT NULL OR G_tplanner IS NOT NULL THEN
     x_select := x_select || ' mtl_planners mpl, ';
  END IF;
  IF G_fbuyer IS NOT NULL OR G_tbuyer IS NOT NULL THEN
     x_select := x_select || ' hr_employees hem, ';
  END IF;
  IF G_forg IS NOT NULL OR G_torg IS NOT NULL THEN
     x_select := x_select || ' mtl_parameters mpa, ';
  END IF;
  IF G_fcategory IS NOT NULL OR G_tcategory IS NOT NULL THEN
     x_select := x_select || ' mtl_categories_kfv mca, ';
  END IF;

  x_select := x_select ||
               ' mtl_system_items_kfv msi, '||
               ' mtl_item_categories mic, '||
               ' ps_schd_dtl psd, '||
               ' mtl_category_sets mcs '||
            ' WHERE '||
               ' mcs.category_set_id = to_char(:category_set_id) '||
               ' AND mcs.structure_id = to_char(:structure_id) '||
               ' AND mic.category_set_id = mcs.category_set_id  '||
               ' AND psd.schedule_id = to_char(:schedule_id) '||
               ' AND psd.organization_id = msi.organization_id '||
               ' AND mic.inventory_item_id = msi.inventory_item_id '||
               ' AND mic.organization_id = msi.organization_id ';

  IF G_fcategory IS NOT NULL OR G_tcategory IS NOT NULL THEN
       x_select := x_select || ' AND mcs.structure_id = mca.structure_id '||
               ' AND mic.category_id = mca.category_id ';
     IF G_fcategory IS NOT NULL THEN
       x_select := x_select || ' AND mca.concatenated_segments >= :f_category ';
     END IF;
     IF G_tcategory IS NOT NULL THEN
       x_select := x_select || ' AND mca.concatenated_segments <= :t_category ';
     END IF;
  END IF;

  IF G_fplanner IS NOT NULL OR G_tplanner IS NOT NULL THEN
       x_select := x_select || ' AND mpl.planner_code = msi.planner_code  '||
               ' AND mpl.organization_id = msi.organization_id ';
     IF G_fplanner IS NOT NULL THEN
       x_select := x_select || ' AND msi.planner_code  >= :f_planner ';
     END IF;
     IF G_tplanner IS NOT NULL THEN
       x_select := x_select || ' AND msi.planner_code  <= :t_planner ';
     END IF;
  END IF;

  IF G_fbuyer IS NOT NULL OR G_tbuyer IS NOT NULL THEN
       x_select := x_select || ' AND hem.employee_id = msi.buyer_id ';
     IF G_fbuyer IS NOT NULL THEN
       x_select := x_select || ' AND hem.full_name >= :f_buyer ';
     END IF;
     IF G_tbuyer IS NOT NULL THEN
       x_select := x_select || ' AND hem.full_name <= :t_buyer ';
     END IF;
  END IF;

  IF G_forg IS NOT NULL OR G_torg IS NOT NULL THEN
       x_select := x_select || ' AND mpa.organization_id = msi.organization_id ';
     IF G_forg IS NOT NULL THEN
       x_select := x_select || ' AND mpa.organization_code >= :f_org ';
     END IF;
     IF G_torg IS NOT NULL THEN
       x_select := x_select || ' AND mpa.organization_code <= :t_org ';
     END IF;
  END IF;

  IF G_fitem IS NOT NULL THEN
    x_select := x_select || ' AND msi.concatenated_segments >= :f_item ';
  END IF;
  IF G_titem IS NOT NULL THEN
    x_select := x_select || ' AND msi.concatenated_segments <= :t_item ';
  END IF;

  cur_item := dbms_sql.open_cursor;
  dbms_sql.parse (cur_item, x_select,dbms_sql.NATIVE);

  dbms_sql.bind_variable(cur_item, ':category_set_id', G_category_set);
  dbms_sql.bind_variable(cur_item, ':structure_id', G_structure_id);
  dbms_sql.bind_variable(cur_item, ':schedule_id', G_schedule_id);

  IF G_fcategory IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':f_category', G_fcategory);
  END IF;
  IF G_tcategory IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':t_category', G_tcategory);
  END IF;

  IF G_fplanner IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':f_planner', G_fplanner);
  END IF;
  IF G_tplanner IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':t_planner', G_tplanner);
  END IF;

  IF G_fbuyer IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':f_buyer', G_fbuyer);
  END IF;
  IF G_tbuyer IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':t_buyer', G_tbuyer);
  END IF;

  IF G_forg IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':f_org', G_forg);
  END IF;
  IF G_torg IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':t_org', G_torg);
  END IF;

  IF G_fitem IS NOT NULL THEN
      dbms_sql.bind_variable(cur_item, ':f_item', G_fitem);
  END IF;
  IF G_titem IS NOT NULL THEN
      dbms_sql.bind_variable(cur_item, ':t_item', G_titem);
  END IF;

  dbms_sql.define_column (cur_item, 1, X_item_id);
  dbms_sql.define_column (cur_item, 2, X_org_id);
  dbms_sql.define_column (cur_item, 3, X_category_id);

  X_row_count := dbms_sql.execute_and_fetch (cur_item);
  IF X_row_count > 0 THEN
     SELECT gmp_matl_rep_id_s.NEXTVAL INTO X_rep_id FROM dual;
     G_matl_rep_id := X_rep_id;
     X_i := 0;
     LOOP
        dbms_sql.column_value (cur_item, 1, X_item_id);
        dbms_sql.column_value (cur_item, 2, X_org_id);
        dbms_sql.column_value (cur_item, 3, X_category_id);
        X_i  := X_i + 1;
        G_item_tab(X_i).inventory_item_id := X_item_id;
        G_item_tab(X_i).organization_id   := X_org_id;
        G_item_tab(X_i).category_id       := X_category_id;
        -- Inserts the data into Header table.
        INSERT INTO ps_matl_hdr (matl_rep_id,inventory_item_id,organization_id,category_id)
             VALUES(X_rep_id,X_item_id,X_org_id,X_category_id);
        IF dbms_sql.fetch_rows (cur_item) <= 0 THEN
           EXIT;
        END IF;
     END LOOP;
  END IF;
  dbms_sql.close_cursor (cur_item);

  EXCEPTION
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm);

END ps_insert_header;  /***** END PROCEDURE********************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	ps_bucket_report                                      |
|                                                                             |
| DESCRIPTION		Procedure to call ps_bucket_details for items.        |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                               |
|                                                                             |
+============================================================================*/

PROCEDURE ps_bucket_report IS

X_ret   NUMBER;
/*
X_i     NUMBER := 0;
X_planning_class        VARCHAR2(8);
X_item_id               NUMBER;
*/

BEGIN
   IF G_item_tab.COUNT > 0 THEN
      FOR cnt IN G_item_tab.FIRST..G_item_tab.LAST
      LOOP
         X_ret := ps_bucket_details(G_item_tab(cnt).inventory_item_id,
                G_item_tab(cnt).organization_id);
      END LOOP;
   END IF;

/*  X_ret := ps_fcst_list;
  IF G_planning_tab.count > 0 then
    LOOP
      X_i := X_i + 1;
      EXIT WHEN X_i > G_planning_tab.count;
      X_planning_class := G_planning_tab(X_i).planning_class;
      X_item_id        := G_planning_tab(X_i).item_id;
      IF X_item_id IS NOT NULL THEN
        X_ret := ps_bucket_details(X_item_id, X_planning_class);
      END IF;
    END LOOP;
  END IF;
*/
  EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm);

END ps_bucket_report;  /***** END PROCEDURE ********************/

/*============================================================================+
|                                                                             |
| FUNCTION NAME	ps_bucket_details                                           |
|                                                                             |
| DESCRIPTION		Function  to make a call to the stored procedure            |
|                 to populate ps_matl_dtl table                               |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                                |
|                                                                             |
+============================================================================*/

FUNCTION ps_bucket_details
(V_item_id IN   NUMBER,
 V_organization_id IN NUMBER) RETURN NUMBER IS

 X_row_count NUMBER;
 X_uom_code VARCHAR2(3);

 CURSOR cur_get_item_uom IS
    SELECT primary_uom_code FROM mtl_system_items
    WHERE inventory_item_id =  V_item_id
       AND organization_id = V_organization_id;

 BEGIN
   -- to get warehouse list.
/* Call to this procedure will not be required as the item cursor itself will
return the valid items and organizations. */
/*
   ps_whse_list(V_item_id) ;

    IF G_whse_list IS NULL THEN
      RETURN(-1);
    END IF;
*/
    -- to get balance
--    ps_get_balance(V_item_id) ;
    get_onhand_qty(V_item_id, V_organization_id);

    -- to get safety_stock
    ps_get_safety_stock(V_item_id, V_organization_id) ;

    OPEN cur_get_item_uom;
    FETCH cur_get_item_uom INTO X_uom_code;
    CLOSE cur_get_item_uom;

    X_row_count := pkg_gmp_bucket_data.ps_bucket_data(G_schedule_id,
                                    V_item_id,
                                    to_char(V_organization_id),
--                                    G_fcst_list,
                                    G_on_hand1,
                                    G_total_ss,
                                    X_uom_code,
--                                    1,
                                    G_matl_rep_id);

    -- if there are no transactions then that item row is deleted from header table.
    IF X_row_count = 0 THEN
      DELETE FROM ps_matl_hdr
      WHERE       inventory_item_id = V_item_id
      AND         organization_id = V_organization_id
      AND         matl_rep_id = G_matl_rep_id;
      RETURN(-1);
    END IF;
    RETURN(0);
 END ps_bucket_details; /***** END FUNCTION ********************/

 /* Added this new procedure to get the primary and secondary onhand
qty when a list of organization_ids are mentioned. */

  /****************************************************************
  * NAME
  *	get_onhand_qty
  * SYNOPSIS
  *	proc get_onhand_qty
  * PARAMETERS
  *     V_item_id - Inventory_Item_Id of Item
  *     V_organization_id - Organization_id
  * DESCRIPTION
  *     Procedure used to Retrieve onhand qtys
  * HISTORY
  *     Namit   01Mar05 - Initial Version
  ****************************************************************/

PROCEDURE get_onhand_qty(
        V_item_id NUMBER,
        V_organization_id NUMBER
        ) IS

   l_onhand1    NUMBER;
   l_onhand2    NUMBER;
   l_non_nettable NUMBER;

   Cursor Cur_nettable_ind ( V_schedule_id NUMBER) IS
        SELECT NVL(nonnet_ind,0)
        FROM   ps_schd_hdr
        WHERE  schedule_id = V_schedule_id;

BEGIN

   OPEN Cur_nettable_ind(G_schedule_id);
   FETCH Cur_nettable_ind INTO l_non_nettable;
   CLOSE Cur_nettable_ind;

   IF l_non_nettable = 0 THEN
      l_non_nettable := 2;
   END IF;

   G_nonnet_ind := l_non_nettable;

   inv_consigned_validations.get_planning_quantity(
     P_INCLUDE_NONNET    => l_non_nettable
     , P_LEVEL           => 1
     , P_ORG_ID          => V_organization_id
     , P_SUBINV          => NULL
     , P_ITEM_ID         => V_item_id
     , P_GRADE_CODE      => NULL
     , X_QOH             => l_onhand1
     , X_SQOH            => l_onhand2);

   IF l_onhand1 IS NOT NULL THEN
      G_on_hand1              := l_onhand1;
   END IF;
   IF l_onhand2 IS NOT NULL THEN
      G_on_hand2              := l_onhand2;
   END IF;

END get_onhand_qty;

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	ps_get_safety_stock                                         |
|                                                                             |
| DESCRIPTION		Procedure to get the safety stock details                   |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                                |
|                                                                             |
+============================================================================*/

PROCEDURE ps_get_safety_stock(V_item_id NUMBER, V_organization_id NUMBER) IS

/*
    CURSOR Cur_unit_safety_stock(C_item_id NUMBER) IS
      SELECT safety_stock
      FROM   ic_whse_inv
      WHERE  item_id= C_item_id
      AND whse_code is NULL and delete_mark=0;
*/
    X_whse_cnt 		NUMBER(5);
    X_select1 		VARCHAR2(2000) := NULL;
    X_row_count		NUMBER(5);
    cur_sstock          NUMBER;
  BEGIN
/*
    X_select1 :='SELECT sum(safety_stock) total_ss,count(*) no_ss'||
                ' FROM ic_whse_inv'||
                ' WHERE item_id = to_char(:1) ' ||
                ' AND whse_code in ( ' || G_whse_list || ' ) ' ||
                ' AND delete_mark=0 '||
		' GROUP BY item_id';
*/
    X_select1 :=
       ' SELECT NVL(SUM(s1.safety_stock_quantity), 0) total_ss'||
       ' FROM mtl_safety_stocks s1 '||
       ' WHERE s1.organization_id = to_char(:org_id)'||
       '    AND s1.inventory_item_id = to_char(:item_id)'||
       '    AND (s1.effectivity_date <= SYSDATE  '||
       '    AND s1.effectivity_date >= ( '||
       '       SELECT NVL(MAX(s2.effectivity_date), SYSDATE) '||
       '       FROM mtl_safety_stocks s2 '||
       '       WHERE s2.organization_id = s1.organization_id'||
       '       AND s2.inventory_item_id = to_char(:item_id)'||
       '       AND s2.effectivity_date <= SYSDATE)) ';


--    IF G_whse_list IS NOT NULL THEN
    cur_sstock := dbms_sql.open_cursor;
    dbms_sql.parse (cur_sstock, X_select1,dbms_sql.NATIVE);

    dbms_sql.bind_variable(cur_sstock,':item_id',V_item_id);
    dbms_sql.bind_variable(cur_sstock,':org_id',V_organization_id);

    dbms_sql.define_column (cur_sstock, 1, G_total_ss);
--    dbms_sql.define_column (cur_sstock, 2, G_no_safetystock);
    X_row_count := dbms_sql.EXECUTE(cur_sstock);
    IF dbms_sql.fetch_rows (cur_sstock) > 0 THEN
       dbms_sql.column_value (cur_sstock, 1, G_total_ss);
--       dbms_sql.column_value (cur_sstock, 2, G_no_safetystock);
    END IF;

    dbms_sql.close_cursor (cur_sstock);
    EXCEPTION
     WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm);
      IF dbms_sql.is_open (cur_sstock) then
	     dbms_sql.close_cursor (cur_sstock);
      END IF;

  END ps_get_safety_stock; /******** END PROCEDURE*************/

/* ***************************************************************
* NAME
*	FUNCTION - ps_generate_xml
* PARAMETERS
*
* DESCRIPTION
*     Procedure used to Generate XML for Bucketed Data.
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

PROCEDURE ps_generate_xml IS

   qryCtx                 DBMS_XMLGEN.ctxHandle;
   result                 CLOB;
   x_stmt                 VARCHAR2(25000);
   seq_stmt               VARCHAR2(200);
   x_seq_num              NUMBER;
   l_encoding             VARCHAR2(20);  /* B7481907 */
   l_xml_header           VARCHAR2(100); /* B7481907 */
   l_offset               PLS_INTEGER;   /* B7481907 */
   temp_clob              CLOB;          /* B7481907 */
   len                    PLS_INTEGER;   /* B7481907 */

BEGIN

    -- B7481907 Rajesh Patangya starts
    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
        l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
        FND_FILE.PUT_LINE ( FND_FILE.LOG,'l_xml_header - '||l_xml_header);
    -- B7481907 Rajesh Patangya starts

seq_stmt := NULL;
x_seq_num := 0;

x_stmt := ' SELECT ' ||
    ' gmppsrp.organization_code( '||G_orgnanization_id||') master_org, ' ||
    ' gmppsrp.schedule( '||G_schedule_id||') schedule, ' ||
    ' gmppsrp.category_set( '||G_category_set||') category_set, ' ||
    ''''||G_fcategory||''''||' fcategory, ' ||
    ''''||G_tcategory||''''||' tcategory, ' ||
    ''''||G_fbuyer||''''||' fbuyer, ' ||
    ''''||G_tbuyer||''''||' tbuyer, ' ||
    ''''||G_fplanner||''''||' fplanner, ' ||
    ''''||G_tplanner||''''||' tplanner, ' ||
    ''''||G_forg||''''||' forg, ' ||
    ''''||G_torg||''''||' torg, ' ||
    ''''||G_fitem||''''||' fitem, ' ||
    ''''||G_titem||''''||' titem, ' ||
    ' CURSOR( ' ||
       ' SELECT  ' ||
          ' gmppsrp.item_name(pmh.inventory_item_id, pmh.organization_id) item_name,  ' ||
          ' gmppsrp.organization_code (pmh.organization_id) organization_code, ' ||
          ' gmppsrp.planner_code (pmh.inventory_item_id, pmh.organization_id) planner_code, ' ||
          ' gmppsrp.buyer_name (pmh.inventory_item_id, pmh.organization_id) buyer_name, ' ||
          ' gmppsrp.onhand_qty (pmh.inventory_item_id, pmh.organization_id) onhand_qty, ' ||
          ' gmppsrp.unit_of_measure(pmh.inventory_item_id, pmh.organization_id) primary_uom_code, ' ||
          ' gmppsrp.category(pmh.category_id) category, ' ||
          ' CURSOR(  ' ||
             ' SELECT pmd.* ' ||
             ' FROM ps_matl_dtl pmd ' ||
             ' WHERE pmd.inventory_item_id = pmh.inventory_item_id ' ||
             ' AND pmd.organization_id = pmh.organization_id ' ||
             ' AND pmd.matl_rep_id = pmh.matl_rep_id ' ||
             ' ORDER BY pmd.inventory_item_id, pmd.organization_id, pmd.perd_end_date ' ||
          ' ) DETAIL ' ||
       ' FROM ps_matl_hdr pmh ' ||
       ' WHERE pmh.matl_rep_id = ' ||G_matl_rep_id||
       ' ORDER BY pmh.inventory_item_id, pmh.organization_id ' ||
    ' ) HEADER ' ||
' FROM DUAL ';

     -- DELETE FROM GMP_BUCKETED_XML_GTMP;
     -- FND_FILE.PUT_LINE ( FND_FILE.LOG, x_stmt);

     -- B7481907 Rajesh Patangya starts
         DBMS_LOB.createtemporary(temp_clob, TRUE);
         DBMS_LOB.createtemporary(result, TRUE);

         qryctx := dbms_xmlgen.newcontext(x_stmt);

     -- generate XML data
         DBMS_XMLGEN.getXML (qryctx, temp_clob, DBMS_XMLGEN.none);
         l_offset := DBMS_LOB.INSTR (lob_loc => temp_clob,
                                     pattern => '>',
                                     offset  => 1,
                                     nth     => 1);
        FND_FILE.PUT_LINE ( FND_FILE.LOG,'l_offset  - '||l_offset);

    -- Remove the header
        DBMS_LOB.erase (temp_clob, l_offset,1);

    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        DBMS_LOB.writeappend (result, length(l_xml_header), l_xml_header);

    -- Append the rest to xml output
        DBMS_LOB.append (result, temp_clob);

    -- close context and free memory
        DBMS_XMLGEN.closeContext(qryctx);
        DBMS_LOB.FREETEMPORARY (temp_clob);
     -- B7481907 Rajesh Patangya Ends

     seq_stmt := 'select gmp_matl_rep_id_s.nextval from dual ';
     EXECUTE IMMEDIATE seq_stmt INTO x_seq_num ;
     INSERT INTO gmp_bucketed_xml_temp(bckt_matl_xml_id, xml_file) VALUES(x_seq_num, result);
     ps_generate_output(x_seq_num);

EXCEPTION
WHEN OTHERS THEN
   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Exception in procedure ps_generate_xml :'||SQLERRM);

END ps_generate_xml;

/* ***************************************************************
* NAME
*	FUNCTION - schedule
* PARAMETERS
*     p_schedule_id - Schedule Id
* DESCRIPTION
*     Function used to Schedule Name
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

FUNCTION schedule (p_schedule_id NUMBER)
RETURN VARCHAR2 IS
   v_schedule_name VARCHAR2(16);
BEGIN

   SELECT schedule INTO v_schedule_name
   FROM ps_schd_hdr
   WHERE schedule_id = p_schedule_id;

   RETURN v_schedule_name;

EXCEPTION
WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error in function schedule '||SQLERRM);
END schedule;

/* ***************************************************************
* NAME
*	FUNCTION - category_set
* PARAMETERS
*     p_category_set_id - Category Set Id
* DESCRIPTION
*     Function used to Retrieve Category Name
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

FUNCTION category_set (p_category_set_id NUMBER)
RETURN VARCHAR2 IS
   v_category_set_name VARCHAR2(30);
BEGIN

   SELECT category_set_name INTO v_category_set_name
   FROM mtl_category_sets
   WHERE category_set_id = p_category_set_id;

   RETURN v_category_set_name;

EXCEPTION
WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error in function category_set '||SQLERRM);
END category_set;

/* ***************************************************************
* NAME
*	FUNCTION - item_name
* PARAMETERS
*     V_item_id - Inventory_Item_Id of Item
*     V_organization_id - Organization_id
* DESCRIPTION
*     Function used to Retrieve Item Name
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

FUNCTION item_name (p_inventory_item_id NUMBER, p_organization_id NUMBER)
RETURN VARCHAR2 IS
   v_item_name VARCHAR2(240);
BEGIN

   SELECT concatenated_segments INTO v_item_name
   FROM mtl_system_items_kfv
   WHERE inventory_item_id = p_inventory_item_id
   AND organization_id = p_organization_id;

   RETURN v_item_name;

EXCEPTION
WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error in function item_name '||SQLERRM);
END item_name;

/* ***************************************************************
* NAME
*	FUNCTION - organization_code
* PARAMETERS
*     V_organization_id - Organization_id
* DESCRIPTION
*     Function used to Retrieve Organization Code
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

FUNCTION organization_code (p_organization_id NUMBER)
RETURN VARCHAR2 IS
   v_org_code VARCHAR2(3);
BEGIN

   SELECT organization_code INTO v_org_code
   FROM mtl_parameters
   WHERE organization_id = p_organization_id;

   RETURN v_org_code;

EXCEPTION
WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error in function organization_code '||SQLERRM);
END organization_code;

/* ***************************************************************
* NAME
*	FUNCTION - planner_code
* PARAMETERS
*     V_item_id - Inventory_Item_Id of Item
*     V_organization_id - Organization_id
* DESCRIPTION
*     Function used to Retrieve Planner Code
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

FUNCTION planner_code (p_inventory_item_id NUMBER, p_organization_id NUMBER)
RETURN VARCHAR2 IS
   v_planner_code VARCHAR2(10);
BEGIN

   SELECT planner_code INTO v_planner_code
   FROM mtl_system_items
   WHERE inventory_item_id = p_inventory_item_id
   AND organization_id = p_organization_id;

   RETURN v_planner_code;

EXCEPTION
WHEN NO_DATA_FOUND THEN RETURN NULL;
WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error in function planner_code '||SQLERRM);
END planner_code;

/* ***************************************************************
* NAME
*	FUNCTION - buyer_name
* PARAMETERS
*     V_item_id - Inventory_Item_Id of Item
*     V_organization_id - Organization_id
* DESCRIPTION
*     Function used to Retrieve Item Buyer Name
* HISTORY
*     Rajesh Patangya - Modified the SELECT B4905328
*************************************************************** */

FUNCTION buyer_name (p_inventory_item_id NUMBER, p_organization_id NUMBER)
RETURN VARCHAR2 IS
   v_buyer_name VARCHAR2(240);
BEGIN

   SELECT he.full_name INTO v_buyer_name
     FROM mtl_system_items_b msi, per_people_f he
    WHERE msi.organization_id = p_organization_id
      AND msi.inventory_item_id = p_inventory_item_id
      AND msi.buyer_id = he.person_id  ;

   RETURN v_buyer_name;

EXCEPTION
WHEN NO_DATA_FOUND THEN RETURN NULL;
WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error in function buyer_name '||SQLERRM);
END buyer_name;

/* ***************************************************************
* NAME
*	FUNCTION - onhand_qty
* PARAMETERS
*     V_item_id - Inventory_Item_Id of Item
*     V_organization_id - Organization_id
* DESCRIPTION
*     Function used to Retrieve Item onhand qty in Primary UOM
* HISTORY
*     Namit   31Mar05 - Initial Version
***************************************************************  */

FUNCTION onhand_qty (p_inventory_item_id NUMBER, p_organization_id NUMBER)
RETURN NUMBER IS
   v_onhand_qty NUMBER := 0;
   l_onhand1    NUMBER;
   l_onhand2    NUMBER;

BEGIN

   inv_consigned_validations.get_planning_quantity(
     P_INCLUDE_NONNET    => G_nonnet_ind
     , P_LEVEL           => 1
     , P_ORG_ID          => p_organization_id
     , P_SUBINV          => NULL
     , P_ITEM_ID         => p_inventory_item_id
     , P_GRADE_CODE      => NULL
     , X_QOH             => l_onhand1
     , X_SQOH            => l_onhand2);

     IF l_onhand1 IS NOT NULL THEN
        v_onhand_qty := l_onhand1;
     END IF;

   RETURN v_onhand_qty;

EXCEPTION
WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error in function onhand_qty '||SQLERRM);
END onhand_qty;

/* ***************************************************************
* NAME
*	FUNCTION - unit_of_measure
* PARAMETERS
*     V_item_id - Inventory_Item_Id of Item
*     V_organization_id - Organization_id
* DESCRIPTION
*     Function used to Retrieve Primary UOM Code.
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

FUNCTION unit_of_measure (p_inventory_item_id NUMBER, p_organization_id NUMBER)
RETURN VARCHAR2 IS
   v_uom_code VARCHAR2(3);
BEGIN

   SELECT primary_uom_code INTO v_uom_code
   FROM mtl_system_items
   WHERE inventory_item_id = p_inventory_item_id
   AND organization_id = p_organization_id;

   RETURN v_uom_code;

EXCEPTION
WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error in function unit_of_measure '||SQLERRM);
END unit_of_measure;

/* ***************************************************************
* NAME
*	FUNCTION - category
* PARAMETERS
*     p_category_id - Category Id
* DESCRIPTION
*     Function used to Retrieve Category Name
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

FUNCTION category (p_category_id NUMBER)
RETURN VARCHAR2 IS
   v_category VARCHAR2(240);
BEGIN

   SELECT concatenated_segments INTO v_category
   FROM mtl_categories_kfv
   WHERE category_id = p_category_id;

   RETURN v_category;

EXCEPTION
WHEN NO_DATA_FOUND THEN RETURN NULL;
WHEN OTHERS THEN
      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error in function category '||SQLERRM);
END category;

/* ***************************************************************
* NAME
*	PROCEDURE - ps_generate_output
* PARAMETERS
* DESCRIPTION
*     Procedure used generate the final output.
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

PROCEDURE ps_generate_output (
   p_sequence_num    IN    NUMBER
)
IS

l_conc_id               NUMBER;
l_req_id                NUMBER;
l_phase			VARCHAR2(20);
l_status_code		VARCHAR2(20);
l_dev_phase		VARCHAR2(20);
l_dev_status		VARCHAR2(20);
l_message		VARCHAR2(20);
l_status		BOOLEAN;


BEGIN

  l_conc_id := FND_REQUEST.SUBMIT_REQUEST('GMP','GMPBCKT','', '',FALSE,
        	    p_sequence_num, chr(0),'','','','','','','','','','','',
		    '','','','','','','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','');

   IF l_conc_id = 0 THEN
      G_log_text := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);
   ELSE
      COMMIT ;
   END IF;

   IF l_conc_id <> 0 THEN

      l_status := fnd_concurrent.WAIT_FOR_REQUEST
            (
                REQUEST_ID    =>  l_conc_id,
                INTERVAL      =>  30,
                MAX_WAIT      =>  900,
                PHASE         =>  l_phase,
                STATUS        =>  l_status_code,
                DEV_PHASE     =>  l_dev_phase,
                DEV_STATUS    =>  l_dev_status,
                MESSAGE       =>  l_message
            );

      DELETE FROM gmp_bucketed_xml_temp WHERE bckt_matl_xml_id = p_sequence_num;

     /* Bug: 6609251 Vpedarla added a NULL parameters for the submition of the FND request for XDOREPPB */
      l_req_id := FND_REQUEST.SUBMIT_REQUEST('XDO','XDOREPPB','', '',FALSE,'',
        	    l_conc_id,554,G_template,
		    G_template_locale,'N','','','','','','','','',
		    '','','','','','','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','');
   END IF;


EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Exception in procedure ps_generate_output '||SQLERRM);
END ps_generate_output;

/* ***************************************************************
* NAME
*	PROCEDURE - xml_transfer
* PARAMETERS
* DESCRIPTION
*     Procedure used provide the XML as output of the concurrent program.
* HISTORY
*     Namit   31Mar05 - Initial Version
*   Bug 9094869 Vpedarla Increased size of file_varchar2 to 1000.
*************************************************************** */

PROCEDURE xml_transfer (
errbuf              OUT NOCOPY VARCHAR2,
retcode             OUT NOCOPY VARCHAR2,
p_sequence_num      IN  NUMBER
)IS

l_file CLOB;
file_varchar2 VARCHAR2(1000);
l_len NUMBER;
l_limit NUMBER;

BEGIN

   SELECT xml_file INTO l_file
   FROM gmp_bucketed_xml_temp
   WHERE bckt_matl_xml_id = p_sequence_num;
   l_limit:= 1;

   l_len := DBMS_LOB.GETLENGTH (l_file);
   LOOP
      IF l_len > l_limit THEN
         file_varchar2 := DBMS_LOB.SUBSTR (l_file,10,l_limit);
         FND_FILE.PUT(FND_FILE.OUTPUT,file_varchar2);
         FND_FILE.PUT(FND_FILE.LOG, file_varchar2);
         file_varchar2 := NULL;
         l_limit:= l_limit + 10;
      ELSE
         file_varchar2 := DBMS_LOB.SUBSTR (l_file,10,l_limit);
         FND_FILE.PUT(FND_FILE.OUTPUT, file_varchar2);
         FND_FILE.PUT(FND_FILE.LOG,file_varchar2);
         file_varchar2 := NULL;
         EXIT;
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Exception in procedure xml_transfer '||SQLERRM);
END xml_transfer;

END GMPPSRP; /***** END PACKAGE BODY ***************************/

/
