--------------------------------------------------------
--  DDL for Package Body GMPMPACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMPMPACT" AS
/* $Header: GMPMPACB.pls 120.5.12010000.4 2009/11/19 13:20:03 vpedarla ship $ */

--Package Declarations

Procedure insert_header_data;

--Procedure set_where_clause;


Procedure rips1usr_unbucket_report;

--Procedure ps_whse_list(V_item_id NUMBER) ;

Procedure ps_data_retrieval (V_item_id IN NUMBER, V_organization_id IN NUMBER);

Procedure  pscommon_safety_stock (V_item_id IN NUMBER, V_organization_id IN NUMBER);

Procedure cleanup_details;

Procedure get_onhand_qty(V_item_id IN NUMBER, V_organization_id IN NUMBER);


	G_matl_rep_id             NUMBER := 0;
        G_orgnanization_id        NUMBER;
--        G_schedule                VARCHAR2(16);
        G_schedule_id             NUMBER(10);
        G_structure_id            NUMBER;
        G_category_set_id         NUMBER;
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
        G_ftrans_date             DATE;
        G_ttrans_date             DATE;
        G_critical_indicator      NUMBER := 0;
	G_start_balance           NUMBER;
	G_log_text                VARCHAR2(1000);
        G_doc_id                  NUMBER;
        G_doc_type                VARCHAR2(4);
        G_tranline_id             NUMBER;
        G_c_ind                   VARCHAR2(5);
        G_cust_vend               VARCHAR2(32);
        G_template                VARCHAR2(100);
        G_template_locale         VARCHAR2(6);

	TYPE item_rec_typ  IS RECORD
        (
           inventory_item_id    NUMBER,
           organization_id      NUMBER,
           category_id          NUMBER
        );
	TYPE item_tab_typ  IS TABLE OF item_rec_typ INDEX BY BINARY_INTEGER;
 	G_item_tab         item_tab_typ;


	TYPE doc_typ  is RECORD( trans_date  Date,
	                         doc_type    VARCHAR2(4),
                                 doc_id      NUMBER(10),
                                 trans_qty   NUMBER,
                                 trans_qty2  NUMBER,
			         line_id     NUMBER,
                                 org_code   VARCHAR2(3)
                                );

	TYPE doc_tab_typ  IS TABLE OF doc_typ INDEX BY BINARY_INTEGER;
 	G_doc_tab         doc_tab_typ;

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	print_mps_activity                                    |
|                                                                             |
| DESCRIPTION		Procedure to submit the request for report            |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    05/03/04     Rameshwar  Bug#3543259                                      |
|                  Moved the code from form to Package for performance        |
|                  issues.                                                    |
+============================================================================*/

PROCEDURE print_mps_activity
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY  VARCHAR2,
 V_organization_id   IN NUMBER,
 V_schedule          IN NUMBER,
-- V_schedule_id       IN NUMBER,
 V_Category_Set_id   IN NUMBER,
 V_Structure_Id      IN NUMBER,
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
 V_ftrans_date       IN VARCHAR2,
 V_ttrans_date       IN VARCHAR2,
 /* V_ftrans_date       IN DATE,
 V_ttrans_date       IN DATE,  */
 V_critical_indicator IN  NUMBER,
 V_template          IN VARCHAR2,
 V_template_locale   IN VARCHAR2
 ) IS

 --local Variable declaration
  X_status         BOOLEAN;
  X_conc_id        NUMBER;
  X_fBuyer_Plnr	   VARCHAR2(100);
  X_tBuyer_Plnr	   VARCHAR2(100);
  X_Buyer_plnr	   VARCHAR2(100);
  X_no_of_reports  NUMBER;
  X_ri_where       VARCHAR2(1000);

BEGIN

   retcode := 0;
   G_orgnanization_id :=       V_organization_id;
--   G_schedule :=               V_schedule;
   G_schedule_id :=            V_schedule;
   G_category_set_id :=        V_Category_Set_id;
   G_structure_id :=           V_Structure_Id;
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
   G_ftrans_date :=            TO_DATE(V_ftrans_date, 'YYYY/MM/DD HH24:MI:SS') ; -- B9094377 ;
   G_ttrans_date :=            TO_DATE(V_ttrans_date, 'YYYY/MM/DD HH24:MI:SS') ; -- B9094377;
   G_critical_indicator :=     V_critical_indicator;
   G_template :=               V_template;
   G_template_locale :=        V_template_locale;

   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Calling gmp_print_mps with values ');
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_orgnanization_id '||to_char(G_orgnanization_id));
--   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_schedule '||to_char(G_schedule));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_schedule_id '||to_char(G_schedule_id));
--   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_category_set '||G_category_set);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_structure_id '||to_char(G_structure_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_category_set_id '||to_char(G_category_set_id));
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
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_ftrans_date '||TO_CHAR(G_ftrans_date,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_ttrans_date '||TO_CHAR(G_ttrans_date,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_critical_indicator '||G_critical_indicator);

   --Insert data in PS_MATL_HDR.
   insert_header_data;

   IF G_item_tab.count > 0 then
      rips1usr_unbucket_report;

     DELETE
     FROM   ps_matl_hdr pmh
     WHERE  pmh.matl_rep_id = G_matl_rep_id
        AND
        ((pmh.inventory_item_id NOT IN (SELECT pud1.inventory_item_id
                               FROM   ps_ubkt_dtl pud1
                               WHERE  pud1.matl_rep_id = G_matl_rep_id))
        OR
        (pmh.organization_id NOT IN (SELECT organization_id
                                FROM ps_ubkt_dtl pud2
                                WHERE pud2.inventory_item_id = pmh.inventory_item_id
                                AND   pud2.matl_rep_id = G_matl_rep_id)));
    END IF;

    ps_generate_xml;

/*
       -- Invoke the concurrent manager from here
         IF V_number_of_copies > 0 THEN
            X_status := FND_REQUEST.SET_PRINT_OPTIONS(V_printer,
                                                      UPPER(V_user_print_style),
                                                      V_number_of_copies, TRUE, 'N');
         END IF;
         -- request is submitted to the concurrent manager
         FND_FILE.PUT_LINE ( FND_FILE.LOG,' Submitting the Req '||sqlerrm);

         -- B3679023 niyadav changed  'TO_CHAR(G_user_id)' to 'TO_CHAR(G_Buyer_plnr_id)' .
	   X_conc_id := FND_REQUEST.SUBMIT_REQUEST('GMP','RIPS1USR','',
                     TO_CHAR(V_run_date,'YYYY/MM/DD HH24:MI:SS'),
                     FALSE, TO_CHAR(G_matl_rep_id),
                     TO_CHAR(G_Buyer_plnr_id), X_ri_where,
                     G_fwhse_code||','||G_twhse_code,'','','','','','',
		     '','','','','','','','','','',
		     '','','','','','','','','','',
		     '','','','','','','','','','',
		     '','','','','','','','','','',
		     '','','','','','','','','','',
		     '','','','','','','','','','',
		     '','','','','','','','','','',
		     '','','','','','','','','','',
		     '','','','','','','','','','');

          FND_FILE.PUT_LINE ( FND_FILE.LOG,' Submitted the Req '||sqlerrm);

         IF X_conc_id = 0 THEN
           G_log_text := FND_MESSAGE.GET;
           FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);
           retcode:=2;
           exit;
         ELSE
           COMMIT ;
         END IF;

     END IF;
   END IF;
     END LOOP;

     CLOSE Cur_buyer_plnr;
*/
  EXCEPTION
   WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in Print mps Activity'||sqlerrm);

END print_mps_activity;

/*************** END  OF PROCEDURE  **********************************/


/*============================================================================+
|                                                                             |
| PROCEDURE NAME	INSERT_HEADER_DATA                                    |
|                                                                             |
| DESCRIPTION		Procedure to insert data into ps_matl_hdr             |
|                       This Procedure fetches data for the Header Table by   |
|                       building the Where condition based on the User and the|
|                       Planning Classes and then inserts into the Header     |
|                       Table by creating a record group                      |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   05/04/04    Rameshwar   -----	created                                   |
|                                                                             |
+============================================================================*/

Procedure insert_header_data IS

 x_select               VARCHAR2(2000);
 cur_item               NUMBER;
 X_item_id              NUMBER;
 X_i                    NUMBER;
 X_org_id               NUMBER;
 X_category_id          NUMBER;
 X_rep_id               NUMBER;
 X_row_count            NUMBER;

BEGIN
    -- Building of the Where clause.

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

  dbms_sql.bind_variable(cur_item, ':category_set_id', G_category_set_id);
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
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error writing to Header'||sqlerrm);
      /* b3668927 nsinghi : Closing cursors in exception block. */
      IF dbms_sql.is_open (cur_item) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION cur_item is Open');
        dbms_sql.close_cursor (cur_item);
      END IF;
END insert_header_data;

/*************** END  OF PROCEDURE  **********************************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	RIPS1USR_UNBUCKET_REPORT                              |
|                                                                             |
| DESCRIPTION		Procedure to call mps_unbucket_details for items.     |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    05/04/04    Rameshwar   -----	created                               |
|                                                                             |
+============================================================================*/

Procedure  rips1usr_unbucket_report IS

CURSOR Cur_check_dtl IS
   SELECT 1
   FROM   FND_DUAL
   WHERE  EXISTS (SELECT matl_rep_id
                  FROM   ps_ubkt_dtl
                  WHERE  matl_rep_id = G_matl_rep_id) ;

X_ret   NUMBER;
X_i     NUMBER := 0;
X_planning_class        VARCHAR2(8);
X_item_id               NUMBER;
BEGIN

   IF G_item_tab.COUNT > 0 THEN
      FOR cnt IN G_item_tab.FIRST..G_item_tab.LAST
      LOOP
         ps_data_retrieval(G_item_tab(cnt).inventory_item_id,
                G_item_tab(cnt).organization_id);
      END LOOP;
   END IF;

    OPEN Cur_check_dtl;
    FETCH Cur_check_dtl INTO X_ret;
    CLOSE Cur_check_dtl;

     IF (X_ret = 0) THEN
        FND_MESSAGE.SET_NAME('GMP','PS_NO_TRANS');
        G_log_text := FND_MESSAGE.GET;
  	FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);
        ROLLBACK;
     END IF;

 EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, sqlerrm);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error writing to Unbucket'||sqlerrm);
    /* b3668927 nsinghi : Closing cursors in exception block. */
    IF Cur_check_dtl%ISOPEN THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_check_dtl Is Open');
        CLOSE Cur_check_dtl;
     END IF;

End rips1usr_unbucket_report;



/*******************End  Of Procedure rips1usr_unbucket_report ******************************/


/*============================================================================+
|                                                                             |
| PROCEDURE NAME	PS_DATA_RETRIEVAL                                     |
|                                                                             |
| DESCRIPTION		Procedure to call mps_unbucket_details for items.     |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    05/04/04    Rameshwar   -----	created                               |
|    09/15/04    Teresa Wong B3865101 Added code to support profile to        |
|			     exclude Internal Sales Orders.		      |
|                                                                             |
+============================================================================*/


Procedure ps_data_retrieval (V_item_id IN NUMBER, V_organization_id IN NUMBER) IS

   CURSOR get_order_ind_cur IS
      SELECT order_ind
      FROM  ps_schd_hdr
      WHERE schedule_id = G_schedule_id;

   CURSOR Cur_fpo_doc_no IS
      SELECT batch_no
      FROM   gme_batch_header
      WHERE  batch_type = 10
      AND batch_id = G_doc_id
      AND organization_id = V_organization_id
      AND delete_mark = 0;

   CURSOR Cur_prod_doc_no IS
      SELECT batch_no
      FROM   gme_batch_header
      WHERE  batch_type = 0
      AND batch_id = G_doc_id
      AND organization_id = V_organization_id
      AND delete_mark = 0;

/* nsinghi MPSCONV Start */
/* OPSO txns will no longer supported. So commenting the code. */
/*

  CURSOR Cur_opso_doc_no IS
      SELECT order_no
      FROM   op_ordr_hdr
      WHERE  order_id = G_doc_id
      AND  orgn_code =  G_orgn_code;
*/
/* nsinghi MPSCONV End */

/*B4905079 - Changed the cursor to improve the performance*/
 CURSOR Cur_omso_doc_no IS
	SELECT DISTINCT oh.order_number
	 FROM   oe_order_headers_all oh,
	        oe_order_lines_all ol
	 WHERE  oh.header_id = ol.header_id
	 AND    inv_salesorder.get_salesorder_for_oeheader(ol.header_id) =  G_doc_id
         AND    ol.open_flag =  'Y'
	 AND    ol.visible_demand_flag = 'Y' /*B4905079 - Flag to ensure that available_to_mrp = 1 */
         AND    decode(ol.source_document_type_id, 10, 8, decode(ol.line_category_code, 'ORDER',2,12)) IN (2,8);

   -- TKW B3865101 9/15/04 Added cursor for the case where Exclude
   -- Internal Sales Orders profile was set to Y.
/*B4905079 - Changed the cursor to improve the performance*/
   CURSOR Cur_excl_internal_omso_doc_no IS
	SELECT DISTINCT oh.order_number
	 FROM   oe_order_headers_all oh,
	        oe_order_lines_all ol
	 WHERE  oh.header_id = ol.header_id
	 AND    inv_salesorder.get_salesorder_for_oeheader(ol.header_id) =  G_doc_id
         AND    ol.open_flag =  'Y'
	 AND    ol.visible_demand_flag = 'Y' /*B4905079 - Flag to ensure that available_to_mrp = 1 */
         AND    decode(ol.source_document_type_id, 10, 8, decode(ol.line_category_code, 'ORDER',2,12)) IN (2,8)
         AND    nvl(ol.source_document_type_id, 0) <> 10 ;

   CURSOR Cur_po_doc_no IS
      SELECT po.po_number
      FROM  MTL_PARAMETERS mtl,
            MTL_SYSTEM_ITEMS mitem,
--            IC_ITEM_MST ic,
            PO_PO_SUPPLY_VIEW po
      WHERE po.item_id = mitem.inventory_item_id
      AND   po.to_organization_id = mitem.organization_id
--      AND   mitem.segment1 = ic.item_no
      AND   mtl.organization_id = po.to_organization_id
      AND   mtl.process_enabled_flag = 'Y'
      AND   mitem.inventory_item_flag = 'Y'
--      AND   ic.noninv_ind = 0
--      AND   ic.experimental_ind = 0
--      AND   ic.delete_mark = 0
      AND NOT EXISTS
              ( SELECT  1  FROM  oe_drop_ship_sources odss
                WHERE   po.PO_HEADER_ID = odss.PO_HEADER_ID
                AND     po.PO_LINE_ID = odss.PO_LINE_ID )
     AND po.po_header_id = G_doc_id ;


   CURSOR Cur_requisition_details IS
      SELECT po.requisition_number
      FROM  MTL_PARAMETERS mtl,
            MTL_SYSTEM_ITEMS mitem,
--            IC_ITEM_MST ic,
            PO_REQ_SUPPLY_VIEW po
      WHERE po.item_id = mitem.inventory_item_id
      AND   po.to_organization_id = mitem.organization_id
--      AND   mitem.segment1 = ic.item_no
      AND   mtl.organization_id = po.to_organization_id
      AND   mtl.process_enabled_flag = 'Y'
      AND   mitem.inventory_item_flag = 'Y'
--      AND   ic.noninv_ind = 0
--      AND   ic.experimental_ind = 0
--      AND   ic.delete_mark = 0
      AND NOT EXISTS
               ( SELECT  1  FROM  oe_drop_ship_sources odss
                 WHERE  po.REQUISITION_HEADER_ID = odss.REQUISITION_HEADER_ID
                 AND    po.REQ_LINE_ID = odss.REQUISITION_LINE_ID )
      AND   po.requisition_header_id = G_doc_id ;

      CURSOR Cur_receiving_details IS
        SELECT  ph.segment1
        FROM  MTL_PARAMETERS mtl,
              MTL_SYSTEM_ITEMS mitem,
--              IC_ITEM_MST ic,
              PO_HEADERS_ALL ph,
              PO_RCV_SUPPLY_VIEW po
        WHERE po.item_id = mitem.inventory_item_id
        AND po.to_organization_id = mitem.organization_id
--        AND mitem.segment1 = ic.item_no
        AND mtl.organization_id = po.to_organization_id
        AND mtl.process_enabled_flag = 'Y'
        AND mitem.inventory_item_flag = 'Y'
--        AND ic.noninv_ind = 0
--        AND ic.experimental_ind = 0
--        AND ic.delete_mark = 0
        AND po.po_header_id = ph.po_header_id
        AND NOT EXISTS
               ( SELECT  1  FROM  oe_drop_ship_sources odss
                 WHERE po.PO_HEADER_ID = odss.PO_HEADER_ID
                   AND po.PO_LINE_ID = odss.PO_LINE_ID )
        AND po.po_header_id = G_doc_id
        AND G_doc_type = 'PRCV'
        UNION ALL
        SELECT rsh.receipt_num
        FROM  MTL_PARAMETERS mtl,
              MTL_SYSTEM_ITEMS mitem,
  --            IC_ITEM_MST ic,
              RCV_SHIPMENT_HEADERS rsh,
              PO_SHIP_RCV_SUPPLY_VIEW po
        WHERE po.item_id = mitem.inventory_item_id
        AND po.shipment_header_id  = rsh.shipment_header_id
        AND po.to_organization_id = mitem.organization_id
--        AND mitem.segment1 = ic.item_no
        AND mtl.organization_id = po.to_organization_id
        AND mtl.process_enabled_flag = 'Y'
        AND mitem.inventory_item_flag = 'Y'
--        AND ic.noninv_ind = 0
--        AND ic.experimental_ind = 0
--        AND ic.delete_mark = 0
        AND po.shipment_header_id = G_doc_id ;

      CURSOR Cur_shipment_details IS
        SELECT  rsh.receipt_num
        FROM  MTL_PARAMETERS mtl,
              MTL_SYSTEM_ITEMS mitem,
--              IC_ITEM_MST ic,
              RCV_SHIPMENT_HEADERS rsh,
              PO_SHIP_SUPPLY_VIEW po
        WHERE po.item_id = mitem.inventory_item_id
        AND   po.shipment_header_id  = rsh.shipment_header_id
        AND   po.to_organization_id = mitem.organization_id
--        AND   mitem.segment1 = ic.item_no
        AND   mtl.organization_id = po.to_organization_id
        AND   mtl.process_enabled_flag = 'Y'
        AND mitem.inventory_item_flag = 'Y'
--        AND   ic.noninv_ind = 0
--        AND   ic.experimental_ind = 0
--        AND ic.delete_mark = 0
        AND po.shipment_header_id = G_doc_id ;

/* nsinghi MPSCONV Start */
/* Since the transfer txns will no longer exist, so commenting the code. */
/*
     CURSOR Cur_transfer_doc_no IS
       SELECT transfer_no
       FROM   ic_xfer_mst
       WHERE  transfer_id = G_doc_id ;
*/
/* nsinghi MPSCONV End */


 X_row_count    NUMBER;
 X_row_count1   NUMBER;
 X_select1      VARCHAR2(4000);
 X_select       VARCHAR2(25000);
 gs_temp        VARCHAR2(3000);
 X_status       NUMBER(5);
 X_first_flag   NUMBER(5);
 X_doc1         NUMBER;
 X_doc          NUMBER;
 X_doc_type     VARCHAR2(4);
 X_trans_date   DATE;
 X_orgn_code    VARCHAR2(4);
 X_doc_id       NUMBER(10);
 X_line_id      NUMBER;
 X_qty          NUMBER;
 X_trans_qty    NUMBER;
 X_trans_qty2   NUMBER;
 X_cust_vend    Varchar2(32);
 X_line_no      NUMBER(10);
 X_org_code    VARCHAR2(3);
 X_i	          NUMBER(5) := 0 ;
 X_date         DATE;
 X_pastdue      CHAR(1);
 X_ret          NUMBER;
 X_on_hand1     NUMBER;
 X_on_hand2     NUMBER;
 Balance1       NUMBER;
 Balance2       NUMBER;
 Start_balance  NUMBER;
 l_ord_ind      NUMBER;
 X_doc_line     NUMBER;
 x_doc_no       VARCHAR2(32);
 X_qty_i        NUMBER;
 X_qty2_i       NUMBER;
 X_qty_k        NUMBER;
 X_j            NUMBER;
 x_whse_list    VARCHAR2(40);
 exclude_internal_omso       NUMBER := 0; -- TKW Added for B3865101

 BEGIN

    X_pastdue      := ' ' ;

   --Retrieve the value whether or not the sales order has been included
    OPEN  get_order_ind_cur;
    FETCH get_order_ind_cur INTO l_ord_ind;
    CLOSE get_order_ind_cur;

    exclude_internal_omso := TO_NUMBER(FND_PROFILE.VALUE('GMP_EXCLUDE_INTERNAL_OMSO')); /* B3865101 */

    get_onhand_qty(V_item_id, V_organization_id);

--         G_start_balance := balance1;
    balance1 := G_on_hand1;
    balance2 := G_on_hand2;

    --Get safety stock values.

    pscommon_safety_stock(v_item_id, V_organization_id);

        x_select := x_select || ' SELECT  gmd.material_requirement_date trans_date, '||
                                '    DECODE(gbh.batch_type, 10,'||''''||'FPO'||''''||','||''''||'PROD'||''''||') doc_type, gbh.batch_id doc_id,'||
                                '    DECODE(gmd.line_type, -1,-1,1) * '||
                                '       DECODE(gmd.dtl_um, '||
                                '	   msi.primary_uom_code, '||
                                '	   NVL((NVL(gmd.wip_plan_qty, gmd.plan_qty) - gmd.actual_qty), 0), '||
                                '	   inv_convert.inv_um_convert(gmd.inventory_item_id, '||
                                '	      NULL, '||
                                '	      gmd.organization_id, '||
                                '	      NULL, '||
                                '             NVL((NVL(gmd.wip_plan_qty, gmd.plan_qty) - gmd.actual_qty), 0), '||
                                '             gmd.dtl_um, '||
                                '             msi.primary_uom_code, '||
                                '             NULL, '||
                                '             NULL '||
                                '          )) trans_qty, '||
                                '    DECODE(msi.dual_uom_control,0,0, '||
                                '	DECODE(gmd.line_type, -1,-1,1) *  DECODE(gmd.dtl_um, '||
                                '	   msi.secondary_uom_code, '||
                                '	   NVL((NVL(gmd.wip_plan_qty, gmd.plan_qty) - gmd.actual_qty), 0), '||
                                '	   inv_convert.inv_um_convert(gmd.inventory_item_id, '||
                                '	      NULL, '||
                                '	      gmd.organization_id, '||
                                '	      NULL, '||
                                '	      NVL((NVL(gmd.wip_plan_qty, gmd.plan_qty) - gmd.actual_qty), 0), '||
                                '	      gmd.dtl_um, '||
                                '	      msi.secondary_uom_code, '||
                                '	      NULL, '||
                                '	      NULL '||
                                '	   ))) trans_qty2, '||
                                '	  gmd.material_detail_id line_id, mp.organization_code inv_org_code'||
                                ' FROM '||
                                '	gme_batch_header gbh, '||
                                '	gme_material_details gmd, '||
                                '	mtl_parameters mp, '||
                                '	hr_organization_units hou, '||
                                '	mtl_system_items msi '||
                                ' WHERE '||
                                '	Gbh.batch_id = gmd.batch_id '||
                                '	AND msi.inventory_item_id = gmd.inventory_item_id '||
                                '	AND msi.organization_id = gmd.organization_id '||
                                '	AND gmd.organization_id = mp.organization_id '||
                                '	AND mp.process_enabled_flag =  '||''''||'Y'||''''||
                                '	AND gbh.batch_status IN (1,2) '||
                                '	AND gmd.actual_qty < NVL(gmd.wip_plan_qty, gmd.plan_qty) '||
                                '	AND msi.inventory_item_id = TO_CHAR(:item_id) '||
                                '	AND hou.organization_id = mp.organization_id '||
                                '	AND nvl(hou.date_to,SYSDATE) >= SYSDATE '||
                                '	AND gmd.material_requirement_date >= nvl(:start_date, gmd.material_requirement_date - 1) '||
                                '	AND gmd.material_requirement_date <= nvl(:end_date, gmd.material_requirement_date + 1) '||
				'       AND gbh.organization_id = TO_CHAR(:organization_id) ';
	IF l_ord_ind = 1 THEN
                               x_select := x_select ||
                               ' UNION ALL '||
			       ' SELECT ' ||
			       	      ' mtl.requirement_date trans_date, ' ||
			              ''''||'OMSO'||''''||' doc_type, mtl.demand_source_header_id doc_id, '||
                                ' mtl.primary_uom_quantity * (-1) trans_qty, '||
                                ' DECODE(items.dual_uom_control,0,0, '||
                                '    (-1) * inv_convert.inv_um_convert(mtl.inventory_item_id, '||
                                '              NULL, '||
                                '              org.organization_id, '||
                                '              NULL, '||
                                '              mtl.primary_uom_quantity , '||
                                '              items.primary_uom_code, '||
                                '              items.secondary_uom_code, '||
                                '              NULL, '||
                                '              NULL '||
                                '            )) trans_qty2,  '||
                                ' dtl.line_id line_id, org.organization_code inv_org_code '||
			        'FROM '||
			              ' mtl_demand_omoe mtl, '||
			              ' mtl_system_items items, '||
			              ' oe_order_headers_all hdr, '||
			              ' oe_order_lines_all dtl, '||
                                      '	hr_organization_units hou, '||
			              ' mtl_parameters org '||
			        ' WHERE '||
                                      ' mtl.inventory_item_id = TO_CHAR(:item_id) '||
                                      '	AND hou.organization_id = org.organization_id '||
                                      '	AND nvl(hou.date_to,SYSDATE) >= SYSDATE '||
				      ' AND mtl.organization_id = TO_CHAR(:organization_id) '||
   				      ' and items.organization_id   = mtl.organization_id '||
 				      ' and items.inventory_item_id = mtl.inventory_item_id '||
				      ' and NVL(mtl.completed_quantity,0) = 0 '||
				      ' and mtl.open_flag =  '||''''||'Y'||''''||
				      ' and mtl.available_to_mrp = 1 '||
				      ' and mtl.parent_demand_id is NULL'||
				      ' and mtl.demand_source_type IN (2,8)'||
				      ' and mtl.demand_id = dtl.line_id '||
				      ' and dtl.header_id = hdr.header_id '||
				      ' and dtl.ship_from_org_id = org.organization_id '||
				      ' AND mtl.requirement_date >= nvl(:start_date, mtl.requirement_date - 1) '||
				      ' AND mtl.requirement_date <= nvl(:end_date, mtl.requirement_date + 1) '||
				      ' and org.process_enabled_flag =   '||''''||'Y'||''''||
                                      ' and ((TO_NUMBER(FND_PROFILE.VALUE('||''''||'GMP_EXCLUDE_INTERNAL_OMSO'||''''||')) = 1 ' ||
                                      '	 and nvl(dtl.source_document_type_id, 0) <> 10 ' ||
                                      '       ) ' ||
                                      '     or TO_NUMBER(FND_PROFILE.VALUE('||''''||'GMP_EXCLUDE_INTERNAL_OMSO'||''''||')) = 0 ' ||
                                      '     ) ' ||
				      ' and NOT EXISTS '||
			              ' (SELECT 1 '||
			              ' FROM so_lines_all sl, '||
			               	     ' so_lines_all slp, '||
			                     ' mtl_demand_omoe dem'||
			              ' WHERE '||
				             ' slp.line_id(+) = nvl(sl.parent_line_id,sl.line_id)'||
				             ' and to_number(dem.demand_source_line) = sl.line_id(+) '||
				             ' and dem.demand_source_type in (2,8)'||
				             ' and sl.end_item_unit_number IS NULL'||
				             ' and slp.end_item_unit_number IS NULL'||
				             ' and dem.demand_id = mtl.demand_id '||
					     ' and items.effectivity_control = 2) ';
        END IF ;
	x_select := x_select ||' UNION ALL '||
                                      ' SELECT '||
                                      '    dtl.forecast_date trans_date,  '||
                                      '    '||''''||'FCST'||''''||' doc_type,  NULL doc_id, '||
                                      '    (-1) * dtl.current_forecast_quantity trans_qty,  '||
                                      '    DECODE(msi.dual_uom_control,0,0,  '||
                                      '       (-1) * inv_convert.inv_um_convert(dtl.inventory_item_id,  '||
                                      ' 	 NULL,  '||
                                      ' 	 dtl.organization_id,  '||
                                      ' 	 NULL,  '||
                                      ' 	 dtl.current_forecast_quantity,  '||
                                      ' 	 msi.primary_uom_code,  '||
                                      ' 	 msi.secondary_uom_code,  '||
                                      ' 	 NULL,  '||
                                      ' 	 NULL  '||
                                      ' 	 )) trans_qty2,    '||
                                      '    0 line_id, mp.organization_code inv_org_code '||
                                      ' FROM  '||
                                      '    ps_schd_for psf,  '||
                                      '    mrp_forecast_designators mff,  '||
                                      '    mrp_forecast_dates dtl,  '||
                                      '    mtl_system_items msi,  '||
                                      '	   hr_organization_units hou, '||
                                      '    mtl_parameters mp  '||
                                      ' WHERE dtl.inventory_item_id = TO_CHAR(:item_id) '||
                                      '    AND psf.schedule_id = TO_CHAR(:schedule_id)  '||
				      '    AND psf.organization_id = TO_CHAR(:organization_id) '||
                                      '	   AND hou.organization_id = mp.organization_id '||
                                      '	   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '||
                                      '    AND psf.organization_id = mp.organization_id  '||
                                      '	   AND mp.process_enabled_flag = '||''''||'Y'||''''||
                                      '    AND psf.organization_id = msi.organization_id  '||
                                      '    AND dtl.inventory_item_id = msi.inventory_item_id  '||
                                      '    AND psf.organization_id = mff.organization_id  '||
                                      '    AND psf.forecast_designator = mff.forecast_set  '||
                                      '    AND mff.forecast_designator = dtl.forecast_designator  '||
                                      '    AND mff.organization_id = dtl.organization_id  '||
                                      '    AND dtl.forecast_date >= nvl(:start_date, dtl.forecast_date - 1) '||
                                      '    AND dtl.forecast_date <= nvl(:end_date, dtl.forecast_date + 1) '||
                                      '    AND dtl.forecast_date >= fnd_date.canonical_to_date(fnd_date.date_to_canonical(sysdate)) '||
                               ' UNION ALL '||
                               ' SELECT  po.expected_delivery_date trans_date, '||''''||'PORD'||''''||' doc_type, '||
                               ' po.po_header_id doc_id, '||
                               '    po.to_org_primary_quantity trans_qty,'||
                               '    DECODE(mitem.dual_uom_control,0,0, '||
                               '       inv_convert.inv_um_convert(mitem.inventory_item_id, '||
                               '	  NULL, '||
                               '	  mitem.organization_id, '||
                               '	  NULL, '||
                               '	  po.to_org_primary_quantity, '||
                               '	  mitem.primary_uom_code, '||
                               '	  mitem.secondary_uom_code, '||
                               '	  NULL, '||
                               '	  NULL)) trans_qty2, '||
                               ' po.po_line_location_id line_id, mtl.organization_code inv_org_code '||
                               ' FROM  MTL_PARAMETERS mtl, '||
                               '       hr_organization_units hou, '||
                               '       po_po_supply_view po, mtl_system_items mitem '||
                              ' WHERE po.item_id = TO_CHAR(:item_id) '||
                              ' AND po.item_id = mitem.inventory_item_id '||
                              ' AND po.to_organization_id = mitem.organization_id '||
                              ' AND mtl.organization_id = po.to_organization_id '||
                              ' AND mtl.process_enabled_flag = ' ||''''||'Y'||''''||
			      ' AND po.to_organization_id = TO_CHAR(:organization_id) '||
                              '	AND hou.organization_id = mtl.organization_id '||
                              '	AND nvl(hou.date_to,SYSDATE) >= SYSDATE '||
                              '	AND po.expected_delivery_date >= nvl(:start_date, po.expected_delivery_date - 1) '||
                              '	AND po.expected_delivery_date <= nvl(:end_date, po.expected_delivery_date + 1) '||
                              ' AND NOT EXISTS '||
                              ' ( SELECT  1  FROM  oe_drop_ship_sources odss '||
                              '   WHERE po.po_header_id = odss.po_header_id '||
                              '   AND po.po_line_id = odss.po_line_id ) '||
                            ' UNION ALL '||
                              ' SELECT  po.expected_delivery_date, '||''''||'PREQ'||''''||' , '||
                              ' po.requisition_header_id, '||
                                       ' po.to_org_primary_quantity,'||
                              '    DECODE(mitem.dual_uom_control,0,0, '||
                              '	   inv_convert.inv_um_convert(mitem.inventory_item_id, '||
                              '	      NULL, '||
                              '	      mitem.organization_id, '||
                              '	      NULL, '||
                              '	      po.to_org_primary_quantity, '||
                              '	      mitem.primary_uom_code, '||
                              '       mitem.secondary_uom_code, '||
                              '	      NULL, '||
                              '	      NULL )) trans_qty2, '||
                              '    po.req_line_id, mtl.organization_code '||
                               ' FROM  MTL_PARAMETERS mtl, '||
                               '       hr_organization_units hou, '||
                               '       po_req_supply_view po, mtl_system_items mitem '||
                              ' WHERE po.item_id = TO_CHAR(:item_id) '||
                              ' AND po.item_id = mitem.inventory_item_id '||
                              ' AND po.to_organization_id = mitem.organization_id '||
                              ' AND mtl.organization_id = po.to_organization_id '||
                              ' AND mtl.process_enabled_flag = ' ||''''||'Y'||''''||
			      ' AND po.to_organization_id = TO_CHAR(:organization_id) '||
                              '	AND hou.organization_id = mtl.organization_id '||
                              '	AND po.expected_delivery_date >= nvl(:start_date, po.expected_delivery_date - 1) '||
                              '	AND po.expected_delivery_date <= nvl(:end_date, po.expected_delivery_date + 1) '||
                              '	AND nvl(hou.date_to,SYSDATE) >= SYSDATE '||
                              ' AND NOT EXISTS '||
                              ' ( SELECT  1  FROM  oe_drop_ship_sources odss '||
                              '   WHERE po.REQUISITION_HEADER_ID = odss.REQUISITION_HEADER_ID '||
                              '   AND po.REQ_LINE_ID = odss.REQUISITION_LINE_ID ) '||
                              ' UNION ALL'||
                              ' SELECT  po.expected_delivery_date trans_date, '||''''||'PRCV'||''''||' doc_type, '||
                              ' po.po_header_id doc_id, '||
                              '    po.to_org_primary_quantity trans_qty,'||
                              '    DECODE(mitem.dual_uom_control,0,0, '||
                              '	      inv_convert.inv_um_convert(mitem.inventory_item_id, '||
                              '   	 NULL, '||
                              '		 mitem.organization_id, '||
                              '	 	 NULL, '||
                              '		 po.to_org_primary_quantity, '||
                              '		 mitem.primary_uom_code, '||
                              '		 mitem.secondary_uom_code, '||
                              '		 NULL, '||
                              '		 NULL)) trans_qty2,  '||
                              '   po.po_line_id line_id, mtl.organization_code inv_org_code '||
                              '  FROM  MTL_PARAMETERS mtl, '||
                              '        hr_organization_units hou, '||
                              '        po_rcv_supply_view po, mtl_system_items mitem '||
                              ' WHERE po.item_id = TO_CHAR(:item_id) '||
                              ' AND po.item_id = mitem.inventory_item_id '||
                              ' AND po.to_organization_id = mitem.organization_id '||
                              ' AND mtl.organization_id = po.to_organization_id '||
                              ' AND mtl.process_enabled_flag = ' ||''''||'Y'||''''||
			      ' AND po.to_organization_id = TO_CHAR(:organization_id) '||
                              '	AND hou.organization_id = mtl.organization_id '||
                              '	AND po.expected_delivery_date >= nvl(:start_date, po.expected_delivery_date - 1) '||
                              '	AND po.expected_delivery_date <= nvl(:end_date, po.expected_delivery_date + 1) '||
                              '	AND nvl(hou.date_to,SYSDATE) >= SYSDATE '||
                              ' AND NOT EXISTS '||
                              ' ( SELECT  1  FROM  oe_drop_ship_sources odss '||
                              '   WHERE po.po_header_id = odss.po_header_id '||
                              '   AND po.po_line_id = odss.po_line_id ) '||
                              ' UNION ALL'||
                              ' SELECT  po.expected_delivery_date trans_date, '||''''||'PRCV'||''''||' doc_type ,'||
                              '    po.shipment_header_id doc_id, '||
                              '    po.to_org_primary_quantity trans_qty,'||
                              '    DECODE(mitem.dual_uom_control,0,0, '||
                              '	      inv_convert.inv_um_convert(mitem.inventory_item_id, '||
                              '   	 NULL, '||
                              '		 mitem.organization_id, '||
                              '	 	 NULL, '||
                              '		 po.to_org_primary_quantity, '||
                              '		 mitem.primary_uom_code, '||
                              '		 mitem.secondary_uom_code, '||
                              '		 NULL, '||
                              '		 NULL)) trans_qty2,  '||
                              '    po.shipment_line_id line_id, mtl.organization_code inv_org_code '||
                              ' FROM  MTL_PARAMETERS mtl, '||
                              '       hr_organization_units hou, '||
                              '       po_ship_rcv_supply_view po, mtl_system_items mitem '||
                              ' WHERE po.item_id = TO_CHAR(:item_id) '||
                              ' AND po.item_id = mitem.inventory_item_id '||
                              ' AND po.to_organization_id = mitem.organization_id '||
                              ' AND mtl.organization_id = po.to_organization_id '||
                              ' AND mtl.process_enabled_flag = ' ||''''||'Y'||''''||
			      ' AND po.to_organization_id = TO_CHAR(:organization_id) '||
                              '	AND hou.organization_id = mtl.organization_id '||
                              '	AND po.expected_delivery_date >= nvl(:start_date, po.expected_delivery_date - 1) '||
                              '	AND po.expected_delivery_date <= nvl(:end_date, po.expected_delivery_date + 1) '||
                              '	AND nvl(hou.date_to,SYSDATE) >= SYSDATE '||
                              ' UNION ALL'||
                              ' SELECT  po.expected_delivery_date trans_date, '||''''||'SHMT'||''''||' doc_type,'||
                              '    po.shipment_header_id doc_id, '||
                              '    po.to_org_primary_quantity trans_qty,'||
                              '    DECODE(mitem.dual_uom_control,0,0, '||
                              '	      inv_convert.inv_um_convert(mitem.inventory_item_id, '||
                              '   	 NULL, '||
                              '		 mitem.organization_id, '||
                              '	 	 NULL, '||
                              '		 po.to_org_primary_quantity, '||
                              '		 mitem.primary_uom_code, '||
                              '		 mitem.secondary_uom_code, '||
                              '		 NULL, '||
                              '		 NULL)) trans_qty2,  '||
                              '    po.shipment_line_id line_id, mtl.organization_code inv_org_code '||
                              ' FROM  MTL_PARAMETERS mtl, '||
                              '       hr_organization_units hou, '||
                              '       po_ship_supply_view po, mtl_system_items mitem '||
                              ' WHERE po.item_id = TO_CHAR(:item_id) '||
                              ' AND po.item_id = mitem.inventory_item_id '||
                              ' AND po.to_organization_id = mitem.organization_id '||
                              ' AND mtl.organization_id = po.to_organization_id '||
                              ' AND mtl.process_enabled_flag = ' ||''''||'Y'||''''||
			      ' AND mtl.organization_id = TO_CHAR(:organization_id) '||
                              '	AND hou.organization_id = mtl.organization_id '||
                              '	AND po.expected_delivery_date >= nvl(:start_date, po.expected_delivery_date - 1) '||
                              '	AND po.expected_delivery_date <= nvl(:end_date, po.expected_delivery_date + 1) '||
                              '	AND nvl(hou.date_to,SYSDATE) >= SYSDATE '||
                ' ORDER BY 1 ASC, 4  DESC';

                 X_doc := dbms_sql.open_cursor;

                 dbms_sql.parse(X_doc,X_select,dbms_sql.NATIVE);

                 dbms_sql.bind_variable(X_doc,':item_id',V_item_id);
                 dbms_sql.bind_variable(X_doc,':schedule_id',G_schedule_id);
                 dbms_sql.bind_variable(X_doc,':organization_id',V_organization_id);
                 dbms_sql.bind_variable(X_doc,':start_date',G_ftrans_date);
                 dbms_sql.bind_variable(X_doc,':end_date',G_ttrans_date);

                dbms_sql.define_column(X_doc, 1, X_trans_date);
                dbms_sql.define_column(X_doc, 2, X_doc_type, 4);
                dbms_sql.define_column(X_doc, 3, X_doc_id);
                dbms_sql.define_column(X_doc, 4, X_trans_qty);
                dbms_sql.define_column(X_doc, 5, X_trans_qty2);
	        dbms_sql.define_column(X_doc, 6, X_line_id);
                dbms_sql.define_column(X_doc, 7, X_org_code,3);

                X_row_count := dbms_sql.EXECUTE(X_doc);

           LOOP

              X_row_count := dbms_sql.fetch_rows (X_doc);
		IF X_row_count = 0 THEN
                  EXIT;
                END IF;

                X_i := X_i + 1;
                dbms_sql.column_value(X_doc, 1, X_trans_date);
                dbms_sql.column_value(X_doc, 2, X_doc_type);
                dbms_sql.column_value(X_doc, 3, X_doc_id);
                dbms_sql.column_value(X_doc, 4, X_trans_qty);
                dbms_sql.column_value(X_doc, 5, X_trans_qty2);
	        dbms_sql.column_value(X_doc, 6, X_line_id);
                dbms_sql.column_value(X_doc, 7, X_org_code);

                G_doc_tab(X_i).trans_date := X_trans_date;
                G_doc_tab(X_i).doc_type := X_doc_type;
                G_doc_tab(X_i).doc_id := X_doc_id;
                G_doc_tab(X_i).trans_qty := X_trans_qty;
                G_doc_tab(X_i).trans_qty2 := X_trans_qty2;
                G_doc_tab(X_i).line_id :=  X_line_id;
                G_doc_tab(X_i).org_code := X_org_code;


           END LOOP;
              x_row_count1 := X_i;

           FOR X_i IN 1..X_row_count1
             LOOP
               G_doc_type := G_doc_tab(X_i).doc_type;
               G_doc_id := G_doc_tab(X_i).doc_id;
	         G_tranline_id := G_doc_tab(X_i).line_id;
--	         G_orgn_code   := G_doc_tab(X_i).orgn_code;

               IF G_doc_tab(X_i).doc_type = 'FPO' THEN
                   OPEN Cur_fpo_doc_no;
                   FETCH Cur_fpo_doc_no INTO x_doc_no;
                   CLOSE Cur_fpo_doc_no;
               ELSIF G_doc_tab(X_i).doc_type =  'PROD' THEN
                     OPEN Cur_prod_doc_no;
                     FETCH Cur_prod_doc_no INTO x_doc_no;
                     CLOSE Cur_prod_doc_no;
               ELSIF G_doc_tab(X_i).doc_type =  'PREQ' THEN
          	     OPEN Cur_requisition_details;
                     FETCH Cur_requisition_details INTO x_doc_no;
                     CLOSE Cur_requisition_details;
               ELSIF G_doc_tab(X_i).doc_type = 'PRCV' THEN
                     OPEN Cur_receiving_details;
                     FETCH Cur_receiving_details INTO x_doc_no;
                     CLOSE Cur_receiving_details;
               ELSIF G_doc_tab(X_i).doc_type = 'SHMT' THEN
                      OPEN Cur_shipment_details;
                      FETCH Cur_shipment_details INTO x_doc_no;
                      CLOSE Cur_shipment_details;
               ELSIF G_doc_tab(X_i).doc_type = 'PORD' THEN
                     OPEN Cur_po_doc_no;
                     FETCH Cur_po_doc_no INTO x_doc_no;
                     CLOSE Cur_po_doc_no;
/* nsinghi MPSCONV Start */
/* OPSO txns will no longer supported. So commenting the code. */
/*
               ELSIF G_doc_tab(X_i).doc_type = 'OPSO' THEN
                     OPEN Cur_opso_doc_no;
                     FETCH Cur_opso_doc_no INTO x_doc_no;
                     CLOSE Cur_opso_doc_no;
*/
/* nsinghi MPSCONV End */
               ELSIF G_doc_tab(X_i).doc_type = 'OMSO' THEN
		     -- TKW B3865101 Check profile value before getting doc no
		     IF (exclude_internal_omso = 0) THEN
			OPEN Cur_omso_doc_no;
			FETCH Cur_omso_doc_no INTO x_doc_no;
			CLOSE Cur_omso_doc_no;
		     ELSE
			OPEN Cur_excl_internal_omso_doc_no;
			FETCH Cur_excl_internal_omso_doc_no INTO x_doc_no;
			CLOSE Cur_excl_internal_omso_doc_no;
		     END IF;

/* nsinghi MPSCONV Start */
/* Since the transfer txns will no longer exist, so commenting the code. */
/*
               ELSIF G_doc_tab(X_i).doc_type= 'XFER' THEN
                     OPEN Cur_transfer_doc_no;
                     FETCH Cur_transfer_doc_no INTO x_doc_no;
                     CLOSE Cur_transfer_doc_no;
*/
/* nsinghi MPSCONV End */
               END IF;



               balance1 := balance1 + G_doc_tab(X_i).trans_qty ;

              --If balance is less than the safety stock then set critical indicator accordingly.
                IF (nvl(balance1,0) < nvl(G_total_ss,0)) THEN
		           G_c_ind := '**';
                   cleanup_details;
                   SELECT SYSDATE INTO X_date FROM dual;
                   X_ret :=  G_doc_tab(X_i).trans_date - X_date;
                   IF (X_ret < 0) THEN
                       X_pastdue := '*';
                   ELSE
                       X_pastdue := NULL;
                   END IF;
                   --Insert the record into the detail table.

                    INSERT INTO ps_ubkt_dtl(matl_rep_id,
--                                            item_id,
                                            inventory_item_id,
--                                            planning_class,
--                                            whse_code,
                                            organization_id,
                                            start_balance,
                                            past_due,
                                            trans_date,
                                            doc_type,
--                                            orgn_code,
                                            doc_no,
                                            line_id,
                                            trans_qty,
                                            balance,
                                            critical_ind,
                                            cust_vend)
                                    Values( G_matl_rep_id,
			                    V_item_id,
--			                    V_planning_class,
--			                    G_doc_tab(X_i).whse_code,
                                            V_organization_id,
			                    G_start_balance,
			                    X_pastdue,
			                    G_doc_tab(X_i).trans_date,
			                    G_doc_type,
--			                    G_doc_tab(X_i).orgn_code,
			                    X_doc_no,
			                    G_doc_tab(X_i).line_id,
			                    G_doc_tab(X_i).trans_qty,
			                    balance1,
			                    G_c_ind,
			                    G_cust_vend);

			                G_start_balance := 0.00;
		  ELSIF G_critical_indicator = 2    THEN

		    cleanup_details;


		   SELECT SYSDATE INTO X_date FROM dual;
                   X_ret :=  G_doc_tab(X_i).trans_date - X_date;
                   IF (X_ret < 0) THEN
                       X_pastdue := '*';
                   ELSE
                       X_pastdue := NULL;
                   END IF;


                     INSERT INTO ps_ubkt_dtl(matl_rep_id,
--                                            item_id,
                                            inventory_item_id,
--                                            planning_class,
--                                            whse_code,
                                            organization_id,
                                            start_balance,
                                            past_due,
                                            trans_date,
                                            doc_type,
---                                            orgn_code,
                                            doc_no,
                                            line_id,
                                            trans_qty,
                                            balance,
                                            critical_ind,
                                            cust_vend)
                                    Values( G_matl_rep_id,
			                    V_item_id,
--			                    V_planning_class,
--			                    G_doc_tab(X_i).whse_code,
                                            V_organization_id,
			                    G_start_balance,
			                    X_pastdue,
			                    G_doc_tab(X_i).trans_date,
			                    G_doc_type,
--			                    G_doc_tab(X_i).orgn_code,
			                    X_doc_no,
			                    G_doc_tab(X_i).line_id,
			                    G_doc_tab(X_i).trans_qty,
			                    balance1,
			                    G_c_ind,
			                    G_cust_vend);

           		     G_start_balance := 0.00;

              END IF;

              G_c_ind := '';
           END LOOP;
            G_doc_tab.delete;
           dbms_sql.close_cursor(X_doc);

    IF X_i = 0 THEN

         DELETE FROM ps_matl_hdr
         WHERE inventory_item_id = V_item_id
         AND matl_rep_id = G_matl_rep_id;
      END IF;

--  END IF; /* End if for G_whse_list NOT NULL */

    EXCEPTION
        WHEN OTHERS THEN
--		X_WHSE_LIST:=SQLERRM;
	   FND_FILE.PUT_LINE(FND_FILE.LOG,'Error writing to ps_ubkt_dtl'||sqlerrm);

           /* b3668927 nsinghi : Closing cursors in exception block. */
           IF dbms_sql.is_open(X_doc) THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'cur_select Is Open');
              dbms_sql.close_cursor(X_doc);
           END IF;
           IF dbms_sql.is_open(X_doc1) THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'X_doc1 Is Open');
              dbms_sql.close_cursor(X_doc1);
           END IF;
           IF Cur_fpo_doc_no%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_fpo_doc_no Is Open');
              CLOSE Cur_fpo_doc_no;
           END IF;
           IF Cur_prod_doc_no%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_prod_doc_no Is Open');
              CLOSE Cur_prod_doc_no;
           END IF;
           IF Cur_requisition_details%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_requisition_details Is Open');
              CLOSE Cur_requisition_details;
           END IF;
           IF Cur_receiving_details%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_receiving_details Is Open');
              CLOSE Cur_receiving_details;
           END IF;
           IF Cur_shipment_details%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_shipment_details Is Open');
              CLOSE Cur_shipment_details;
           END IF;
           IF Cur_po_doc_no%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_po_doc_no Is Open');
              CLOSE Cur_po_doc_no;
           END IF;
/*
           IF Cur_opso_doc_no%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_opso_doc_no Is Open');
              CLOSE Cur_opso_doc_no;
           END IF;
*/
           IF Cur_omso_doc_no%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_omso_doc_no Is Open');
              CLOSE Cur_omso_doc_no;
           END IF;
/*           IF Cur_transfer_doc_no%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cur_transfer_doc_no Is Open');
              CLOSE Cur_transfer_doc_no;
           END IF; */
           IF get_order_ind_cur%ISOPEN THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'get_order_ind_cur Is Open');
              CLOSE get_order_ind_cur;
           END IF;

 END   ps_data_retrieval;


 /*******************End  Of Procedure ps_data_retrieval ****************************/

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
| PROCEDURE NAME	 PSCOMMON_SAFETY_STOCK                                |
|                                                                             |
| DESCRIPTION		Procedure used to retrieve safety stock information   |
|                       for item     for the Bucketed Activity.               |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    05/04/04    Rameshwar   -----	created                               |
|                                                                             |
+============================================================================*/
 PROCEDURE pscommon_safety_stock (V_item_id NUMBER, V_organization_id NUMBER) IS

      X_tot_ss	NUMBER DEFAULT 0 ;
      X_safety_stock NUMBER DEFAULT 0 ;
      X_no_safety_stock NUMBER DEFAULT 0 ;

    X_unit_ss	NUMBER DEFAULT 0;
    X_whse_cnt	NUMBER ;
    X_select1	VARCHAR2(2000);
    X_status	NUMBER(5);
    X_doc         NUMBER;
    X_row_count   NUMBER;


  BEGIN

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

         X_doc := dbms_sql.open_cursor;
         dbms_sql.parse(X_doc, X_select1,dbms_sql.NATIVE);
	 dbms_sql.bind_variable(X_doc,':item_id',V_item_id);
         dbms_sql.bind_variable(X_doc,':org_id',V_organization_id);

         dbms_sql.define_column(X_doc, 1, X_tot_ss);
--         dbms_sql.define_column(X_doc, 2, X_no_safety_stock);

         X_row_count := dbms_sql.execute(X_doc);


          IF dbms_sql.fetch_rows (X_DOC)>0 THEN
             dbms_sql.column_value(X_doc, 1, X_tot_ss);
--             dbms_sql.column_value(X_doc, 2, X_no_safety_stock);
             G_total_ss := X_tot_ss;
--             G_no_safety_stock:= X_no_safety_stock;
         ELSE
            G_total_ss := 0;
--            G_no_safety_stock:= 0;
         END IF;
         dbms_sql.close_cursor (x_doc);

EXCEPTION
WHEN OTHERS THEN
  FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm||'pscommon_safety_stock');
  IF dbms_sql.is_open(X_doc) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'cur_select Is Open');
      dbms_sql.close_cursor(X_doc);
   END IF;

END  pscommon_safety_stock;

      /******** End of Procedure pscommon_safety_stock   ********************/





/*============================================================================+
|                                                                             |
| PROCEDURE NAME	CLEANUP_DETAILS                                       |
|                                                                             |
| DESCRIPTION		This procedure cleans up details, such as customer    |
|                       vendor information.                                   |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|    05/10/04    Rameshwar   -----	created                               |
|    09/15/04    Teresa Wong B3865101 Added code to support profile to        |
|			     exclude Internal Sales Orders.		      |
+============================================================================*/
PROCEDURE cleanup_details  IS

/* nsinghi MPSCONV Start */
/* OPSO txns will no longer supported. So commenting the code. */
/*
   CURSOR Cur_order_details IS
      SELECT  distinct cs.cust_no
      FROM   op_ordr_hdr op, op_ordr_dtl od, op_cust_mst cs
      WHERE  op.order_id = G_doc_id
      AND    op.order_id = od.order_id
      AND    od.line_id = G_tranline_id
      AND    od.shipcust_id = cs.cust_id;
*/
/* nsinghi MPSCONV End */

    CURSOR Cur_purchase_details IS
      SELECT UNIQUE pv.segment1
      FROM  MTL_PARAMETERS mtl,
            PO_VENDORS pv,
            MTL_SYSTEM_ITEMS mitem,
--            IC_ITEM_MST ic,
            PO_PO_SUPPLY_VIEW po
        WHERE po.item_id = mitem.inventory_item_id
        AND pv.vendor_id = po.vendor_id
        AND po.to_organization_id = mitem.organization_id
--        AND mitem.segment1 = ic.item_no
        AND mtl.organization_id = po.to_organization_id
        AND mtl.process_enabled_flag = 'Y'
        AND mitem.inventory_item_flag = 'Y'
--        AND ic.noninv_ind = 0
--        AND ic.experimental_ind = 0
--        AND ic.delete_mark = 0
        AND NOT EXISTS
               ( SELECT  1  FROM  oe_drop_ship_sources odss
                 WHERE po.PO_HEADER_ID = odss.PO_HEADER_ID
                   AND po.PO_LINE_ID = odss.PO_LINE_ID )
        AND po.po_line_id = G_tranline_id ;

    CURSOR Cur_receiving_details IS
        SELECT UNIQUE pv.segment1
        FROM  MTL_PARAMETERS mtl,
              PO_VENDORS pv,
              MTL_SYSTEM_ITEMS mitem,
--              IC_ITEM_MST ic,
              PO_RCV_SUPPLY_VIEW po
        WHERE po.item_id = mitem.inventory_item_id
        AND pv.vendor_id = po.vendor_id
        AND po.to_organization_id = mitem.organization_id
--        AND mitem.segment1 = ic.item_no
        AND mtl.organization_id = po.to_organization_id
        AND mtl.process_enabled_flag = 'Y'
        AND mitem.inventory_item_flag = 'Y'
--        AND ic.noninv_ind = 0
--        AND ic.experimental_ind = 0
--        AND ic.delete_mark = 0
        AND NOT EXISTS
               ( SELECT  1  FROM  oe_drop_ship_sources odss
                 WHERE po.PO_HEADER_ID = odss.PO_HEADER_ID
                   AND po.PO_LINE_ID = odss.PO_LINE_ID )
        AND po.po_line_id = G_tranline_id
        AND G_doc_type = 'PRCV'
        UNION ALL
        SELECT UNIQUE pv.segment1
        FROM  MTL_PARAMETERS mtl,
              PO_VENDORS pv,
              MTL_SYSTEM_ITEMS mitem,
--              IC_ITEM_MST ic,
              RCV_SHIPMENT_HEADERS rsh,
              PO_SHIP_RCV_SUPPLY_VIEW po
        WHERE po.item_id = mitem.inventory_item_id
        AND pv.vendor_id  = rsh.vendor_id
        AND po.shipment_header_id  = rsh.shipment_header_id
        AND po.to_organization_id = mitem.organization_id
--        AND mitem.segment1 = ic.item_no
        AND mtl.organization_id = po.to_organization_id
        AND mtl.process_enabled_flag = 'Y'
        AND mitem.inventory_item_flag = 'Y'
--        AND ic.noninv_ind = 0
--        AND ic.experimental_ind = 0
--        AND ic.delete_mark = 0
        AND po.shipment_line_id = G_tranline_id ;

     CURSOR Cur_shipment_details IS
        SELECT UNIQUE pv.segment1
        FROM  MTL_PARAMETERS mtl,
              MTL_SYSTEM_ITEMS mitem,
--              IC_ITEM_MST ic,
              PO_VENDORS pv,
              RCV_SHIPMENT_HEADERS rsh,
              PO_SHIP_SUPPLY_VIEW po
        WHERE po.item_id = mitem.inventory_item_id
        AND pv.vendor_id(+)  = rsh.vendor_id
        AND po.shipment_header_id  = rsh.shipment_header_id
        AND po.to_organization_id = mitem.organization_id
--        AND mitem.segment1 = ic.item_no
        AND mtl.organization_id = po.to_organization_id
        AND mtl.process_enabled_flag = 'Y'
        AND mitem.inventory_item_flag = 'Y'
--        AND ic.noninv_ind = 0
--        AND ic.experimental_ind = 0
--        AND ic.delete_mark = 0
        AND po.shipment_line_id = G_tranline_id ;


     CURSOR Cur_requisition_details IS
        SELECT SUBSTRB(prl.suggested_vendor_name,1,40)
        FROM  MTL_PARAMETERS mtl,
              MTL_SYSTEM_ITEMS mitem,
--              IC_ITEM_MST ic,
--              IC_WHSE_MST iwm,
              PO_REQUISITION_LINES_ALL prl,
              PO_REQ_SUPPLY_VIEW po
        WHERE po.item_id = mitem.inventory_item_id
        AND po.req_line_id  = prl.requisition_line_id
        AND po.to_organization_id = mitem.organization_id
--        AND mitem.segment1 = ic.item_no
--        AND po.to_organization_id = iwm.mtl_organization_id
        AND mtl.organization_id = po.to_organization_id
        AND mtl.process_enabled_flag = 'Y'
        AND mitem.inventory_item_flag = 'Y'
--        AND iwm.delete_mark = 0
--        AND ic.noninv_ind = 0
--        AND ic.experimental_ind = 0
--        AND ic.delete_mark = 0
--        AND iwm.orgn_code = G_orgn_code
        AND NOT EXISTS
               ( SELECT  1  FROM  oe_drop_ship_sources odss
                 WHERE po.REQUISITION_HEADER_ID = odss.REQUISITION_HEADER_ID
                   AND po.REQ_LINE_ID = odss.REQUISITION_LINE_ID )
        AND po.req_line_id = G_tranline_id ;

    CURSOR Cur_om_order_details IS
      SELECT DISTINCT sold_to_org.customer_number
      FROM   oe_order_headers_all oh,
             oe_order_lines_all ol,
             oe_sold_to_orgs_v sold_to_org,
             mtl_demand_omoe mtl
      WHERE  oh.header_id = ol.header_id
        AND  ol.line_id = mtl.demand_id
        AND  oh.sold_to_org_id = sold_to_org.organization_id(+)
        AND  mtl.demand_source_header_id = G_doc_id
	  AND  mtl.open_flag =  'Y'
	  AND  mtl.available_to_mrp = 1
	  AND  mtl.parent_demand_id is NULL
        AND  mtl.demand_source_type IN (2,8)  ;

    -- TKW B3865101 9/15/04 Added cursor for the case where Exclude
    -- Internal Sales Orders profile was set to Y.
    CURSOR Cur_excl_internal_omso_dtl IS
      SELECT DISTINCT sold_to_org.customer_number
      FROM   oe_order_headers_all oh,
             oe_order_lines_all ol,
             oe_sold_to_orgs_v sold_to_org,
             mtl_demand_omoe mtl
      WHERE  oh.header_id = ol.header_id
        AND  ol.line_id = mtl.demand_id
        AND  oh.sold_to_org_id = sold_to_org.organization_id(+)
        AND  mtl.demand_source_header_id = G_doc_id
	AND  mtl.open_flag =  'Y'
	AND  mtl.available_to_mrp = 1
	AND  mtl.parent_demand_id is NULL
        AND  mtl.demand_source_type IN (2,8)
        AND  nvl(ol.source_document_type_id, 0) <> 10 ;

 X_workfield3	VARCHAR2(40);
 exclude_internal_omso       NUMBER := 0; -- TKW Added for B3865101

  BEGIN
    exclude_internal_omso := TO_NUMBER(FND_PROFILE.VALUE('GMP_EXCLUDE_INTERNAL_OMSO')); /* B3865101 */

    --Retrieve sales order details.
/* nsinghi MPSCONV Start */
/* OPSO txns will no longer supported. So commenting the code. */
/*
    IF (G_doc_type = 'OPSO') THEN
      OPEN Cur_order_details;
      FETCH Cur_order_details INTO  X_workfield3;
      CLOSE Cur_order_details;
    --Retrieve OM sales order details.
*/
/* nsinghi MPSCONV End */

    IF (G_doc_type = 'OMSO') THEN
      -- TKW B3865101 Check profile before getting the details.
      IF (exclude_internal_omso = 0) THEN
	OPEN Cur_om_order_details;
	FETCH Cur_om_order_details INTO  X_workfield3;
	CLOSE Cur_om_order_details;
      ELSE
	OPEN Cur_excl_internal_omso_dtl;
	FETCH Cur_excl_internal_omso_dtl INTO  X_workfield3;
	CLOSE Cur_excl_internal_omso_dtl;
      END IF;

    --Retrieve purchase order details.
    ELSIF (G_doc_type = 'PORD') THEN
      OPEN Cur_purchase_details;
      FETCH Cur_purchase_details INTO  X_workfield3;
      CLOSE Cur_purchase_details;
    ELSIF (G_doc_type = 'PRCV') THEN
      OPEN Cur_receiving_details;
      FETCH Cur_receiving_details INTO X_workfield3;
      CLOSE Cur_receiving_details;
    --Retrieve PO/REQ shipment details.
    ELSIF (G_doc_type = 'SHMT') THEN
      OPEN Cur_shipment_details;
      FETCH Cur_shipment_details INTO X_workfield3;
      CLOSE Cur_shipment_details;
    --Retrieve requisition details.
    ELSIF (G_doc_type = 'PREQ') THEN
      OPEN Cur_requisition_details;
      FETCH Cur_requisition_details INTO X_workfield3;
      CLOSE Cur_requisition_details;
    --Retrieve production details.
    ELSIF (G_doc_type = 'PROD' OR G_doc_type = 'FPO') THEN
      X_workfield3 := NULL;
    END IF;
     G_cust_vend := X_workfield3;

  EXCEPTION
       WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in Cleanup details '||sqlerrm);
      /* b3668927 nsinghi : Closing cursors in exception block. */
/*      IF Cur_order_details%ISOPEN THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Cursor Cur_order_details Is Open');
         CLOSE Cur_order_details;
      END IF;
*/
      IF Cur_om_order_details%ISOPEN THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Cursor Cur_om_order_details Is Open');
         CLOSE Cur_om_order_details;
      END IF;
      IF Cur_purchase_details%ISOPEN THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Cursor Cur_purchase_details Is Open');
         CLOSE Cur_purchase_details;
      END IF;
      IF Cur_receiving_details%ISOPEN THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Cursor Cur_receiving_details Is Open');
         CLOSE Cur_receiving_details;
      END IF;
      IF Cur_shipment_details%ISOPEN THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Cursor Cur_shipment_details Is Open');
         CLOSE Cur_shipment_details;
      END IF;
      IF Cur_requisition_details%ISOPEN THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Cursor Cur_requisition_details Is Open');
         CLOSE Cur_requisition_details;
      END IF;

  END cleanup_details;

 /******** End of Cleanup_details  ********************/

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
    ' gmpmpact.organization_code( '||G_orgnanization_id||') master_org, ' ||
    ' gmpmpact.schedule( '||G_schedule_id||') schedule, ' ||
    ' gmpmpact.category_set( '||G_category_set_id||') category_set, ' ||
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
    ''''||G_ftrans_date||''''||' fdate, ' ||
    ''''||G_ttrans_date||''''||' tdate, ' ||
    ' CURSOR( ' ||
       ' SELECT  ' ||
          ' gmpmpact.item_name(pmh.inventory_item_id, pmh.organization_id) item_name,  ' ||
          ' gmpmpact.organization_code (pmh.organization_id) organization_code, ' ||
          ' gmpmpact.planner_code (pmh.inventory_item_id, pmh.organization_id) planner_code, ' ||
          ' gmpmpact.buyer_name (pmh.inventory_item_id, pmh.organization_id) buyer_name, ' ||
          ' gmpmpact.onhand_qty (pmh.inventory_item_id, pmh.organization_id) onhand_qty, ' ||
          ' gmpmpact.unit_of_measure(pmh.inventory_item_id, pmh.organization_id) primary_uom_code, ' ||
          ' gmpmpact.category(pmh.category_id) category, ' ||
          ' CURSOR(  ' ||
             ' SELECT pud.line_id line_id, ' ||
             ' pud.matl_rep_id matl_rep_id, ' ||
             ' pud.doc_type doc_type, ' ||
             ' pud.doc_no doc_no, ' ||
             ' pud.start_balance start_balance, ' ||
             ' pud.past_due past_due, ' ||
             ' pud.trans_date trans_date, ' ||
             ' pud.trans_qty trans_qty, ' ||
             ' pud.balance balance, ' ||
             ' pud.critical_ind critical_ind, ' ||
             ' pud.cust_vend cust_vend, ' ||
             ' pud.inventory_item_id inventory_item_id, ' ||
             ' gmpmpact.organization_code (pud.organization_id) organization_code ' ||
             ' FROM ps_ubkt_dtl pud ' ||
             ' WHERE pud.inventory_item_id = pmh.inventory_item_id ' ||
             ' AND pud.organization_id = pmh.organization_id ' ||
             ' AND pud.matl_rep_id = pmh.matl_rep_id ' ||
             ' ORDER BY pud.inventory_item_id, pud.organization_id, pud.trans_date, pud.doc_type  ' ||
          ' ) DETAIL ' ||
       ' FROM ps_matl_hdr pmh ' ||
       ' WHERE pmh.matl_rep_id = ' ||G_matl_rep_id||
       ' ORDER BY pmh.inventory_item_id, pmh.organization_id ' ||
    ' ) HEADER ' ||
' FROM DUAL ';

     -- DELETE FROM GMP_UNBUCKETED_XML_GTMP;
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

     INSERT INTO gmp_unbucketed_xml_temp(ubckt_matl_xml_id, xml_file) VALUES(x_seq_num, result);
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
*     Namit   31Mar05 - Initial Version
*************************************************************** */

FUNCTION buyer_name (p_inventory_item_id NUMBER, p_organization_id NUMBER)
RETURN VARCHAR2 IS
   v_buyer_name VARCHAR2(240);
BEGIN

   SELECT he.full_name INTO v_buyer_name
   FROM mtl_system_items msi, hr_employees he
   WHERE inventory_item_id = p_inventory_item_id
   AND organization_id = p_organization_id
   AND msi.buyer_id = he.employee_id;

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

  l_conc_id := FND_REQUEST.SUBMIT_REQUEST('GMP','GMPUBCKT','', '',FALSE,
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

      DELETE FROM gmp_unbucketed_xml_temp WHERE ubckt_matl_xml_id = p_sequence_num;

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
*     Bug 9094869 Vpedarla Increased size of file_varchar2 to 1000.
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
   FROM gmp_unbucketed_xml_temp
   WHERE ubckt_matl_xml_id = p_sequence_num;
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
END;

 END GMPMPACT;

/
