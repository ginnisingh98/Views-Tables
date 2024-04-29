--------------------------------------------------------
--  DDL for Package Body GMPMRRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMPMRRP" AS
/* $Header: GMPMRRPB.pls 120.0 2005/05/26 14:32:16 appldev noship $ */

   --Package Declarations

	PROCEDURE mr_insert_header ;

	PROCEDURE mr_bucket_report ;

	FUNCTION mr_bucket_details
				(V_item_id          IN   NUMBER,
 				 V_planning_class   IN   VARCHAR2) RETURN NUMBER;

	PROCEDURE mr_whse_list(V_item_id NUMBER) ;

	PROCEDURE mr_get_balance(V_item_id NUMBER) ;

	PROCEDURE mr_get_safety_stock(V_item_id NUMBER) ;


	G_no_of_reports         NUMBER := 0;
	G_matl_rep_id           NUMBER;
	G_Buyer_plnr_id         NUMBER;
	G_Buyer_plnr            VARCHAR2(100);
	G_whse_list             VARCHAR2(2000);
	G_num_whses	        NUMBER;
	G_schedule_id           NUMBER;
	G_mrp_id                NUMBER;
	G_fwhse_code            VARCHAR2(4);
	G_twhse_code            VARCHAR2(4);
	G_forgn_code            VARCHAR2(4);
	G_torgn_code            VARCHAR2(4);
	G_whse_security         VARCHAR2(1);
	G_on_hand1              NUMBER;
	G_total_ss	        NUMBER;
	G_no_safetystock        NUMBER;
	G_unit_ss               NUMBER;
	G_fplanning_class       VARCHAR2(8);
	G_tplanning_class       VARCHAR2(8);
	G_fitem_no              VARCHAR2(32);
	G_titem_no              VARCHAR2(32);
	G_log_text              VARCHAR2(1000);

	TYPE planning_rec_typ  is RECORD(planning_class VARCHAR2(8),
                                         item_id NUMBER);
	TYPE planning_tab_typ  IS TABLE OF planning_rec_typ
                                  INDEX BY BINARY_INTEGER;
 	G_planning_tab         planning_tab_typ;


/*============================================================================+
|                                                                             |
| PROCEDURE NAME	gmp_print_mrp                                         |
|                                                                             |
| DESCRIPTION		Procedure to submit the request for report            |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                               |
|                                                                             |
|  14-MAR-03  BUG#2740325  V. Ajay Kumar  --  Replaced the TO_CHAR            |
|             function with FND_DATE.DATE_TO_CANONICAL function.              |
|   03-SEP-03  BUG#3125285  V. Ajay Kumar  --  Changed the datatype of        |
|              V_run_date and V_run_date1 parameters from Date to             |
|              Varchar2 such that the date conversion takes place             |
|              properly across MLS environments in the procedure              |
|              gmp_print_mrp. Reverted the usage of the function              |
|              function FND_DATE.DATE_TO_CANONICAL for the V_run_date1        |
|              and V_run_date parameters, in the gmp_print_mrp procedure.     |
+============================================================================*/

PROCEDURE gmp_print_mrp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 V_schedule_id      IN NUMBER,
 V_mrp_id           IN NUMBER,
 V_fplanning_class  IN VARCHAR2,
 V_tplanning_class  IN VARCHAR2,
 V_fwhse_code       IN VARCHAR2,
 V_twhse_code       IN VARCHAR2,
 V_forgn_code       IN VARCHAR2,
 V_torgn_code       IN VARCHAR2,
 V_fitem_no         IN VARCHAR2,
 V_titem_no         IN VARCHAR2,
 V_fBuyer_Plnr      IN VARCHAR2,
 V_tBuyer_Plnr      IN VARCHAR2,
 V_whse_security    IN VARCHAR2,
 V_printer          IN VARCHAR2,
 V_number_of_copies IN NUMBER,
 V_user_print_style IN VARCHAR2,
 V_run_date         IN VARCHAR2,  --VAK Changed Datatype from DATE to VARCHAR2.
 V_run_date1        IN VARCHAR2,  --VAK Changed Datatype from DATE to VARCHAR2.
 V_schedule         IN VARCHAR2,
 V_usr_orgn_code    IN VARCHAR2  ) IS

 X_conc_id      NUMBER;
 X_status       BOOLEAN;
 X_ri_where     VARCHAR2(3000);    /* Changed to 3000 instead of 1000 - B3351464 */
 X_fBuyer_Plnr  VARCHAR2(100);
 X_tBuyer_Plnr  VARCHAR2(100);

 -- B2502197 Rajesh Patangya Splited queries into 2 parts
 CURSOR Cur_Buyer_plnr(C_fBuyer_Plnr VARCHAR2 , C_tBuyer_Plnr VARCHAR2)IS
   SELECT user_name
   FROM   fnd_user
   WHERE  user_name BETWEEN C_fBuyer_Plnr AND C_tBuyer_Plnr;

 CURSOR Cur_Buyer_plnr_id(C_Buyer_Plnr VARCHAR2)IS
   SELECT user_id
   FROM   fnd_user
   WHERE  user_name = C_Buyer_Plnr ;

 BEGIN
   retcode := 0;
   G_fwhse_code        :=     V_fwhse_code;
   G_twhse_code        :=     V_twhse_code;
   G_forgn_code        :=     V_forgn_code;
   G_torgn_code        :=     V_torgn_code;
   G_whse_security     :=     V_whse_security;
   G_mrp_id            :=     V_mrp_id;
   G_schedule_id       :=     V_schedule_id;
   G_fplanning_class   :=     V_fplanning_class;
   G_tplanning_class   :=     V_tplanning_class;
   G_fitem_no          :=     V_fitem_no;
   G_titem_no          :=     V_titem_no;

   IF V_fBuyer_Plnr IS NULL THEN
         select min(user_name) INTO X_fBuyer_Plnr from fnd_user;
   ELSE
         X_fBuyer_Plnr := V_fBuyer_plnr;
   END IF;
   IF V_tBuyer_plnr IS NULL THEN
         select max(user_name) INTO X_tBuyer_Plnr from fnd_user;
   ELSE
         X_tBuyer_Plnr := V_tBuyer_plnr;
   END IF;

	OPEN Cur_Buyer_plnr(X_fBuyer_Plnr, X_tBuyer_Plnr );
     LOOP
       FETCH Cur_Buyer_plnr INTO G_Buyer_plnr;
       IF Cur_Buyer_plnr%NOTFOUND THEN
         EXIT;
       END IF;

      -- B2502197 Rajesh Patangya Splited queries into 2 parts
       OPEN Cur_Buyer_plnr_id(G_Buyer_Plnr);
       FETCH Cur_Buyer_plnr_id INTO G_Buyer_plnr_id;
       IF Cur_Buyer_plnr_id%NOTFOUND THEN
          G_Buyer_plnr_id := -1;
       END IF;
       CLOSE Cur_Buyer_plnr_id;

       IF G_Buyer_plnr_id > 0 THEN   /* B2861091 - Added IF condition */

          G_planning_tab.delete;
          mr_insert_header;

          IF G_planning_tab.count > 0 then
             G_no_of_reports := to_char(to_number(G_no_of_reports) + 1);
             mr_bucket_report;
             -- Invoke the concurrent manager from here
             IF V_number_of_copies > 0 THEN
                X_status := FND_REQUEST.SET_PRINT_OPTIONS(V_printer,
                                              UPPER(V_user_print_style),
  		                              V_number_of_copies, TRUE, 'N');
             END IF;
             -- request is submitted to the concurrent manager
             --BEGIN BUG#3125285 V. Ajay Kumar
             --BEGIN BUG#2740325  V. Ajay Kumar
             X_conc_id := FND_REQUEST.SUBMIT_REQUEST('GMP','RIMR2USR','',
                          V_run_date1, FALSE,
                          TO_CHAR(G_matl_rep_id),TO_CHAR(G_Buyer_plnr_id),
                          X_ri_where,
                          V_run_date,
		          V_schedule, V_usr_orgn_code,chr(0),'','','',
		          '','','','','','','','','','',
		          '','','','','','','','','','',
		          '','','','','','','','','','',
		          '','','','','','','','','','',
		          '','','','','','','','','','',
		          '','','','','','','','','','',
		          '','','','','','','','','','',
		          '','','','','','','','','','',
		          '','','','','','','','','','');

                --END BUG#2740325
                --END BUG#3125285

              IF X_conc_id = 0 THEN
                 G_log_text := FND_MESSAGE.GET;
                 FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);
                 retcode:=2;
                 exit;
              ELSE
                 COMMIT ;
              END IF;
          END IF; /* End if for G_planning_tab.COUNT */
       END IF ; /* END IF for G_Buyer_plnr_id - B2861091*/
     END LOOP;

     CLOSE Cur_Buyer_plnr;  /* Bug# 2794837 - Cursor Already Open Error */

     --	Print into the log file the information about the Reports are submitted
     IF G_no_of_reports = 0 THEN
       FND_MESSAGE.SET_NAME('GMP','PS_NO_TRANS');
		 G_log_text := FND_MESSAGE.GET;
  	    FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);
       /* Setting the Concurrent Status to Warning instead of giving Error */
       IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
          NULL;
       END IF;
       retcode :=3;
     ELSIF G_no_of_reports = 1 THEN
       FND_MESSAGE.SET_NAME('GMP','GMP_REPORT_SUBMITTED');
		 G_log_text := FND_MESSAGE.GET;
  	    FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);

     ELSE
       FND_MESSAGE.SET_NAME('GMP','GMP_MULTIPLE_REPORTS_SUBMITTED');
		 G_log_text := FND_MESSAGE.GET;
  	    FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);

     END IF;

 EXCEPTION    /* B2861091 - Added Exception Handler */
   WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in Print MRP Bucket '||sqlerrm);

END gmp_print_mrp;  /***** END PROCEDURE ***************************/


/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_insert_header                                            |
|                                                                             |
| DESCRIPTION		Procedure to insert data into ps_matl_hdr                   |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                                |
|                                                                             |
+============================================================================*/

PROCEDURE mr_insert_header IS

 X_where	     VARCHAR2(4000) := NULL;
 X_select1     	     VARCHAR2(4000) := NULL;
 X_row_count	     NUMBER;
 X_rep_id	     NUMBER;
 X_i                 NUMBER;
 X_planning_class    VARCHAR2(8) := NULL;
 X_item_id           NUMBER;
 cur_planning        NUMBER;
  BEGIN
    -- Building of the Where clause.
    X_where :=  'SELECT  i.planning_class,i.item_id '
                ||' FROM  ps_oper_pcl c, ps_plng_cls p, ic_item_mst i, '
                ||' fnd_user f '
                ||' WHERE c.delete_mark=0 ' ;

    X_where := X_where
               ||' AND f.user_id = :1 '
               ||' AND f.user_id = c.user_id '
               ||' AND c.planning_class=i.planning_class '
               ||' AND i.planning_class=p.planning_class ';

    IF (G_fplanning_class IS NOT NULL) THEN
      X_where := X_where||' AND c.planning_class >= :2 ' ;
    END IF;
    IF (G_tplanning_class IS NOT NULL) THEN
      X_where := X_where||' AND c.planning_class <= :3 ' ;
    END IF;
    IF (G_fitem_no IS NOT NULL) THEN
      X_where := X_where||' AND i.item_no >= :4 ' ;
    END IF;
    IF (G_titem_no IS NOT NULL) THEN
      X_where := X_where||' AND i.item_no <= :5 ' ;
    END IF;
    IF (G_mrp_id IS NOT NULL) THEN
      X_where:= X_where||' AND i.item_id in (select distinct item_id '
                ||' FROM mr_tran_tbl  WHERE mrp_id= to_char(:6) )' ;
    END IF;

    cur_planning := dbms_sql.open_cursor;
    dbms_sql.parse (cur_planning, X_where,dbms_sql.NATIVE);

    dbms_sql.bind_variable(cur_planning, ':1', G_Buyer_plnr_id);

    IF (G_fplanning_class IS NOT NULL) THEN
        dbms_sql.bind_variable(cur_planning, ':2', G_fplanning_class);
    END IF;
    IF (G_tplanning_class IS NOT NULL) THEN
        dbms_sql.bind_variable(cur_planning, ':3', G_tplanning_class);
    END IF;
    IF (G_fitem_no IS NOT NULL) THEN
        dbms_sql.bind_variable(cur_planning, ':4', G_fitem_no);
    END IF;
    IF (G_titem_no IS NOT NULL) THEN
        dbms_sql.bind_variable(cur_planning, ':5', G_titem_no);
    END IF;
    IF (G_mrp_id IS NOT NULL) THEN
        dbms_sql.bind_variable(cur_planning, ':6', G_mrp_id);
    END IF;

    dbms_sql.define_column (cur_planning, 1, X_planning_class, 8);
    dbms_sql.define_column (cur_planning, 2, X_item_id);
    X_row_count := dbms_sql.execute_and_fetch (cur_planning);
    IF X_row_count > 0 THEN
      SELECT gem5_matl_rep_id_s.nextval INTO   X_rep_id FROM dual;
      G_matl_rep_id := X_rep_id;
      X_i := 0;
	   LOOP
           dbms_sql.column_value (cur_planning, 1, X_Planning_class);
           dbms_sql.column_value (cur_planning, 2, X_Item_id);
           X_i  := X_i + 1;
           G_planning_tab(X_i).planning_class := X_planning_class;
           G_planning_tab(X_i).item_id        := X_item_id;
           -- Inserts the data into Header table.
              INSERT INTO ps_matl_hdr (matl_rep_id,planning_class,item_id)
                VALUES(X_rep_id,X_planning_class,X_item_id);
              IF dbms_sql.fetch_rows (cur_planning) <= 0 then
                 EXIT;
              END IF;
          END LOOP;

    END IF;
    dbms_sql.close_cursor (cur_planning);
    EXCEPTION
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE ( FND_FILE.LOG,'Error in mr insert header'|| sqlerrm);


END mr_insert_header;  /***** END PROCEDURE********************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_bucket_report                                            |
|                                                                             |
| DESCRIPTION		Procedure to call mr_bucket_details for items.              |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                                |
|                                                                             |
+============================================================================*/

PROCEDURE mr_bucket_report IS

X_ret   NUMBER;
X_i     NUMBER := 0;
X_planning_class        VARCHAR2(8);
X_item_id               NUMBER;

BEGIN

  IF G_planning_tab.count > 0 then
    LOOP
      X_i := X_i + 1;
      EXIT WHEN X_i > G_planning_tab.count;
      X_planning_class := G_planning_tab(X_i).planning_class;
      X_item_id        := G_planning_tab(X_i).item_id;
      IF X_item_id IS NOT NULL THEN
        X_ret := mr_bucket_details(X_item_id, X_planning_class);
      END IF;
    END LOOP;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm);

END mr_bucket_report;  /***** END PROCEDURE ********************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_bucket_details                                           |
|                                                                             |
| DESCRIPTION		Procedure to make a call to the stored procedure            |
|                 to populate ps_matl_dtl table                               |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                                |
|                                                                             |
+============================================================================*/

FUNCTION mr_bucket_details
(V_item_id 	     IN   NUMBER,
 V_planning_class    IN   VARCHAR2) RETURN NUMBER IS
 X_row_count NUMBER := 0;
 BEGIN
   -- to get warehouse list.
   mr_whse_list(V_item_id) ;

   IF G_whse_list IS NULL THEN
     RETURN(-1);
   END IF;
   -- to get balance
   mr_get_balance(V_item_id) ;
   -- to get safety_stock
   mr_get_safety_stock(V_item_id) ;
--
/*
   FND_FILE.PUT_LINE ( FND_FILE.LOG,'After Get Safety stock ');
   FND_FILE.PUT_LINE ( FND_FILE.LOG,'Schedule id '||G_schedule_id);
   FND_FILE.PUT_LINE ( FND_FILE.LOG,'mrp id '||G_mrp_id);
   FND_FILE.PUT_LINE ( FND_FILE.LOG,'Item id '||V_item_id);
   FND_FILE.PUT_LINE ( FND_FILE.LOG,'Whse List '||G_whse_list);
   FND_FILE.PUT_LINE ( FND_FILE.LOG,' On hand '||G_on_hand1);
   FND_FILE.PUT_LINE ( FND_FILE.LOG,' total ss '||G_total_ss);
   FND_FILE.PUT_LINE ( FND_FILE.LOG,' Matl rep id '||G_matl_rep_id);
*/
--
   X_row_count := pkg_gmp_bucket_data.mr_bucket_data(G_schedule_id,
 	                                 G_mrp_id,
                                    V_item_id,
                                    G_whse_list,
                                    nvl(G_on_hand1,0),
                                    nvl(G_total_ss,0),
                                    G_matl_rep_id);

   -- if there are no transactions then that item row is deleted from header table.
   IF X_row_count = 0 THEN
     DELETE FROM ps_matl_hdr
     WHERE item_id = V_item_id
     AND matl_rep_id = G_matl_rep_id;
     RETURN(-1);
   END IF;
   RETURN(0);
--
  EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error in Bucket details '|| sqlerrm);
    RETURN(0);
--
 END mr_bucket_details; /***** END FUNCTION ********************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_whse_list                                          |
|                                                                             |
| DESCRIPTION		Procedure to create the list of valid warehouses      |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created
|   04/05/04     M. Anil Kumar  Bug#3519744                                   |
|                Assigned variable X_count with zero so that the warehouse    |
|                list is created properly with the commasin between.          |
+============================================================================*/

PROCEDURE mr_whse_list(V_item_id NUMBER) IS

    TYPE ref_cursor_typ is REF CURSOR;
    Cur_matl_act ref_cursor_typ;

    --Bug 3168907 Kalyani Manda  Added the cursor.
    Cursor Cur_get_whse_item_id ( V_item_id NUMBER) IS
        SELECT whse_item_id
        FROM   ic_item_mst
        WHERE  item_id = V_item_id;

    X_sel_whse_list       VARCHAR2(2000) := '';
    X_matl_whse 	  VARCHAR2(4);
    old_matl_whse 	  VARCHAR2(4);
    X_count 	  	  NUMBER(5) :=0;  --Bug#3519744
    X_forgn_code	  VARCHAR2(4);
    X_torgn_code	  VARCHAR2(4);
    X_fwhse_code          VARCHAR2(4);
    X_twhse_code          VARCHAR2(4);
    --Bug 3168907 Added the variables
    X_whse_item_id	  NUMBER;
    X_whse_eff_item_id	  NUMBER;


    CURSOR Cur_min_max_orgn(p_schedule_id NUMBER) IS
      SELECT min(orgn_code), max(orgn_code)
      FROM   ps_schd_dtl
      WHERE  schedule_id = p_schedule_id;
  BEGIN
    IF G_fwhse_code IS NULL THEN
      SELECT MIN(whse_code) INTO X_fwhse_code  FROM ic_whse_mst;
    ELSE
      X_fwhse_code := G_fwhse_code;
    END IF;
    IF G_twhse_code IS NULL THEN
      SELECT MAX(whse_code) INTO X_twhse_code FROM ic_whse_mst;
    ELSE
      X_twhse_code := G_twhse_code;
    END IF;
    IF G_mrp_id IS NOT NULL AND G_schedule_id IS NOT NULL THEN

      --Bug 3168907 Fetch the whse_item_id for the item.
      OPEN Cur_get_whse_item_id(V_item_id);
      FETCH Cur_get_whse_item_id INTO X_whse_item_id;
      CLOSE Cur_get_whse_item_id;

      OPEN Cur_min_max_orgn(G_schedule_id);
      FETCH Cur_min_max_orgn INTO X_forgn_code, X_torgn_code;
      CLOSE Cur_min_max_orgn;
    IF G_forgn_code IS NOT NULL THEN
       X_forgn_code := G_forgn_code;
    END IF;
    IF G_torgn_code IS NOT NULL THEN
       X_torgn_code := G_torgn_code;
    END IF;

    IF nvl(G_whse_security,'N') = 'N' THEN
      OPEN Cur_matl_act for
          SELECT distinct trn.whse_code, whs.whse_item_id
          FROM mr_tran_tbl trn, ps_whse_eff whs
             WHERE  mrp_id = G_mrp_id
             AND item_id =   V_item_id
             AND trn.whse_code >=  X_fwhse_code
             AND trn.whse_code <=  X_twhse_code
             AND trn.whse_code = whs.whse_code
             AND whs.plant_code in (select orgn_code from ps_schd_dtl
                 where schedule_id = G_schedule_id
             AND orgn_code between X_forgn_code and X_torgn_code )
         ORDER BY 1;
    ELSE
      OPEN Cur_matl_act for
         SELECT distinct trn.whse_code, whs.whse_item_id      --Bug 3168907 Added ps.whse_item_id
         FROM   mr_tran_tbl trn, ps_whse_eff whs, sy_orgn_usr org
            WHERE  mrp_id =G_mrp_id
            AND item_id = V_item_id
            AND trn.whse_code >=  X_fwhse_code
            AND trn.whse_code <=  X_twhse_code
            AND trn.whse_code = whs.whse_code
            AND whs.plant_code in (select orgn_code from ps_schd_dtl
                where schedule_id = G_schedule_id
                AND orgn_code between X_forgn_code and X_torgn_code )
            and whs.plant_code = org.orgn_code
            and org.user_id = G_Buyer_plnr_id
        ORDER BY 1;
    END IF;
      FETCH Cur_matl_act INTO X_matl_whse, X_whse_eff_item_id;  --Bug 3168907 Added X_whse_eff_item_id
        IF Cur_matl_act%NOTFOUND THEN
	       X_count:=0;
        ELSE
         LOOP
            --Begin Bug 3168907
            IF X_whse_eff_item_id IS NULL OR X_whse_item_id = X_whse_eff_item_id THEN

              IF ( X_count > 0 ) AND ( nvl(X_matl_whse,'*') <> nvl(old_matl_whse,'*')) Then
                 X_sel_whse_list := X_sel_whse_list||',';
              END IF;
              /*B3659238 - Sowmya- MRP AND MPS BUCKETED REPORT SHOW ALL WAREHOUSES, MRP BUCKETED SHOWS 0 QTY
               Donot allow to Append if the Whse is same*/

              /* B3351464 - Donot allow to Append if the Whse is same */
              IF nvl(X_matl_whse,'*') <> nvl(old_matl_whse,'*')
              THEN
                  X_sel_whse_list    := X_sel_whse_list||''''||X_matl_whse||'''';
                  old_matl_whse := X_matl_whse;
                  X_count := X_count + 1;
              END IF;
              /* End of changes B3351464 */
            END IF;
            FETCH Cur_matl_act INTO X_matl_whse, X_whse_eff_item_id;
	    IF Cur_matl_act%NOTFOUND THEN
	      EXIT;
            END IF;
            --End Bug 3168907
          END LOOP;
        END IF;
      CLOSE Cur_matl_act;
      G_num_whses  := X_count;
      G_whse_list :=  X_sel_whse_list;

    END IF;
--
  EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error in Whse List '|| sqlerrm);
--
  END  mr_whse_list;  /******** END PROCEDURE*************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_get_balance                                              |
|                                                                             |
| DESCRIPTION		Procedure to get the on hand quantity                       |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                                |
|                                                                             |
+============================================================================*/

PROCEDURE mr_get_balance(V_item_id NUMBER) IS

 X_select1      VARCHAR2(4000) := NULL;
 cur_balance    NUMBER;
 X_row_count    NUMBER(5);
  BEGIN
    X_select1   :='SELECT sum(trans_qty) total'||
                ' FROM mr_tran_tbl mr'||
                ' WHERE mrp_id= to_char(:1) AND item_id = to_char(:2) ' ||
                ' AND whse_code in ( ' || G_whse_list || ' ) ' ||
                ' and doc_type='||''''||'BAL'||''''||
                ' group by mr.doc_type';

   /* G_whse_list is a list of warehouses, which are already validated
      and hence not used as a bind variable    */

    cur_balance := dbms_sql.open_cursor;
    dbms_sql.parse (cur_balance, X_select1,dbms_sql.NATIVE);

    dbms_sql.bind_variable(cur_balance,':1',G_mrp_id);
    dbms_sql.bind_variable(cur_balance,':2',V_item_id);

    dbms_sql.define_column (cur_balance, 1, G_on_hand1);
    X_row_count := dbms_sql.execute(cur_balance);
    IF dbms_sql.fetch_rows (cur_balance) > 0 then
       dbms_sql.column_value (cur_balance, 1, G_on_hand1);
    END IF;
    dbms_sql.close_cursor (cur_balance);
    EXCEPTION
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE ( FND_FILE.LOG,'Error in mr get balance '|| sqlerrm);
      IF dbms_sql.is_open (cur_balance) then
	     dbms_sql.close_cursor (cur_balance);
      END IF;

  END mr_get_balance;   /******** END PROCEDURE*************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_get_safety_stock                                         |
|                                                                             |
| DESCRIPTION		Procedure to get the safety stock details                   |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   07/14/01     Praveen Reddy   -----	created                                |
|                                                                             |
+============================================================================*/

PROCEDURE mr_get_safety_stock(V_item_id NUMBER) IS

    CURSOR Cur_unit_safety_stock(C_item_id NUMBER) IS
      SELECT safety_stock
      FROM   ic_whse_inv
      WHERE  item_id= C_item_id
      AND whse_code is NULL and delete_mark=0;


    X_whse_cnt          NUMBER(5);
    X_select1           VARCHAR2(4000) := NULL ;
    X_row_count         NUMBER(5);
    cur_sstock          NUMBER;
BEGIN

    X_select1 :='SELECT sum(safety_stock) total_ss,count(*) no_ss'||
                ' FROM ic_whse_inv'||
                ' WHERE item_id = to_char(:1) ' ||
                ' AND whse_code in ( ' || G_whse_list || ' ) ' ||
                ' AND delete_mark=0 ';

    IF G_whse_list IS NOT NULL THEN
    cur_sstock := dbms_sql.open_cursor;
    dbms_sql.parse (cur_sstock, X_select1,dbms_sql.NATIVE);

    dbms_sql.bind_variable(cur_sstock,':1',V_item_id);

    dbms_sql.define_column (cur_sstock, 1, G_total_ss);
    dbms_sql.define_column (cur_sstock, 2, G_no_safetystock);
    X_row_count := dbms_sql.execute	 (cur_sstock);
    IF dbms_sql.fetch_rows (cur_sstock) > 0 then
      dbms_sql.column_value (cur_sstock, 1, G_total_ss);
      dbms_sql.column_value (cur_sstock, 2, G_no_safetystock);
    END IF;
    ELSE
      G_total_ss       :=0;
      G_no_safetystock :=0;
    END IF;
    dbms_sql.close_cursor (cur_sstock);

    IF ((NVL(G_no_safetystock,0) < NVL(G_num_whses,0))) THEN
      G_unit_ss := 0;
      OPEN Cur_unit_safety_stock(V_item_id);
      FETCH Cur_unit_safety_stock INTO G_unit_ss;
      CLOSE Cur_unit_safety_stock;
      X_whse_cnt := G_num_whses;
      G_total_ss := NVL(G_total_ss,0) + (X_whse_cnt - NVL(G_no_safetystock,0)) * G_unit_ss;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE ( FND_FILE.LOG,'Error in get Safety ctock'|| sqlerrm);
        IF dbms_sql.is_open (cur_sstock) then
	       dbms_sql.close_cursor (cur_sstock);
        END IF;

END mr_get_safety_stock; /******** END PROCEDURE*************/


END GMPMRRP; /***** END PACKAGE BODY ***************************/

/
