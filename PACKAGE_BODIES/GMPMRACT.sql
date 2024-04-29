--------------------------------------------------------
--  DDL for Package Body GMPMRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMPMRACT" AS
/* $Header: GMPMRACB.pls 115.10 2004/04/05 07:55:55 mkalyani noship $ */

   --Package Declarations

	PROCEDURE mr_insert_header ;

        PROCEDURE set_where_clause;

	PROCEDURE mr_unbucket_report ;

	PROCEDURE mr_data_retrieval
				(V_item_id        IN   NUMBER,
 				 V_planning_class IN   VARCHAR2) ;

        PROCEDURE mr_cleanup_details;

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
	G_whse_code             VARCHAR2(4);
	G_fwhse_code            VARCHAR2(4);
	G_twhse_code            VARCHAR2(4);
        G_ftrans_date           DATE;
        G_ttrans_date           DATE;
	G_whse_security         VARCHAR2(1);
	G_on_hand1              NUMBER;
	G_total_ss	        NUMBER;
	G_no_safetystock        NUMBER;
	G_unit_ss               NUMBER;
	G_fplanning_class       VARCHAR2(8);
	G_tplanning_class       VARCHAR2(8);
	G_fitem_no              VARCHAR2(32);
	G_titem_no              VARCHAR2(32);
	G_balance               NUMBER(25);
	G_balance1              NUMBER(25);
	G_balance2              NUMBER(25);
	G_start_balance         NUMBER(19);
	G_c_ind                 VARCHAR2(2);
	G_critical_indicator    VARCHAR2(1);
	G_log_text              VARCHAR2(1000);
	G_sy_all                VARCHAR2(1000);
        G_cust_vend             VARCHAR2(32);
        G_doc_id                NUMBER(10);
        G_doc_no                VARCHAR2(32);
        G_orgn_code             VARCHAR2(4);
        G_line_no               NUMBER(10);
        G_doc_type              VARCHAR2(4);
        G_where                 VARCHAR2(2000);
--
TYPE planning_rec_typ  is RECORD(planning_class VARCHAR2(8),item_id NUMBER);

TYPE planning_tab_typ  IS TABLE OF planning_rec_typ INDEX BY BINARY_INTEGER;

G_planning_tab         planning_tab_typ;

--
	TYPE doc_typ  is RECORD( doc_type    Varchar2(4),
                                 trans_date  Date,
                                 orgn_code   Varchar2(4),
                                 doc_id      NUMBER(10),
                                 trans_qty   NUMBER,
                                 cust_vend   Varchar2(32),
                                 line_no     NUMBER(10),
                                 whse_code   VARCHAR2(4)
                                );
--
	TYPE doc_tab_typ  IS TABLE OF doc_typ INDEX BY BINARY_INTEGER;
 	G_doc_tab         doc_tab_typ;


/*============================================================================+
|                                                                             |
| PROCEDURE NAME	print_mrp_activity                                    |
|                                                                             |
| DESCRIPTION		Procedure to submit the request for report            |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   12/31/02     Sridhar Gidugu  -----	created                               |
|   04/22/03     Sastry  BUG#2889706 Moved the call to set_where_clause before|
|                        loop as where clause should be built only once.      |
+============================================================================*/

PROCEDURE print_mrp_activity
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 V_schedule_id      IN NUMBER,
 V_mrp_id           IN NUMBER,
 V_fplanning_class  IN VARCHAR2,
 V_tplanning_class  IN VARCHAR2,
 V_fwhse_code       IN VARCHAR2,
 V_twhse_code       IN VARCHAR2,
 V_fitem_no         IN VARCHAR2,
 V_titem_no         IN VARCHAR2,
 V_fBuyer_Plnr      IN VARCHAR2,
 V_tBuyer_Plnr      IN VARCHAR2,
 V_ftrans_date      IN DATE,
 V_ttrans_date      IN DATE,
 V_whse_security    IN VARCHAR2,
 V_critical_indicator  IN NUMBER,
 V_printer          IN VARCHAR2,
 V_number_of_copies IN NUMBER,
 V_user_print_style IN VARCHAR2,
 V_run_date         IN DATE,
 V_run_date1        IN DATE,
 V_schedule         IN VARCHAR2,
 V_usr_orgn_code    IN VARCHAR2  ) IS

 X_conc_id  NUMBER;
 X_status   BOOLEAN;
 X_ri_where VARCHAR2(1000);
 X_fBuyer_Plnr  VARCHAR2(100);
 X_tBuyer_Plnr  VARCHAR2(100);

 CURSOR Cur_Buyer_plnr(C_fBuyer_Plnr VARCHAR2 , C_tBuyer_Plnr VARCHAR2)IS
   SELECT user_name
   FROM   fnd_user
   WHERE  (C_fBuyer_Plnr is NULL OR user_name >= C_fBuyer_Plnr)
   AND    (C_tBuyer_Plnr is NULL OR user_name <= C_tBuyer_Plnr);

 CURSOR Cur_Buyer_plnr_id(C_Buyer_Plnr VARCHAR2)IS
   SELECT user_id
   FROM   fnd_user
   WHERE  user_name = C_Buyer_Plnr ;

 BEGIN
     retcode := 0;
     G_fwhse_code        :=     V_fwhse_code;
     G_twhse_code        :=     V_twhse_code;
     G_whse_security     :=     V_whse_security;
     G_mrp_id            :=     V_mrp_id;
     G_schedule_id       :=     V_schedule_id;
     G_fplanning_class   :=     V_fplanning_class;
     G_tplanning_class   :=     V_tplanning_class;
     G_ftrans_date       :=     V_ftrans_date;
     G_ttrans_date       :=     V_ttrans_date;
     G_fitem_no          :=     V_fitem_no;
     G_titem_no          :=     V_titem_no;
     G_critical_indicator :=    V_critical_indicator;

   IF V_fBuyer_plnr IS NULL THEN
         select min(user_name) INTO X_fBuyer_Plnr from fnd_user;
   ELSE
         X_fBuyer_Plnr := V_fBuyer_plnr;
   END IF;

   IF V_tBuyer_plnr IS NULL THEN
         select max(user_name) INTO X_tBuyer_Plnr from fnd_user;
   ELSE
         X_tBuyer_Plnr := V_tBuyer_plnr;
   END IF;

   --BEGIN BUG#2889706 Sastry
   --Moved the following call from below.
   set_where_clause;
   --END BUG#2889706
   OPEN Cur_Buyer_plnr(X_fBuyer_Plnr, X_tBuyer_Plnr );
   LOOP
       FETCH Cur_Buyer_plnr INTO G_Buyer_plnr;
       IF Cur_Buyer_plnr%NOTFOUND THEN
--         CLOSE Cur_Buyer_plnr;
         EXIT;
       END IF;

       OPEN Cur_Buyer_plnr_id(G_Buyer_Plnr);
       FETCH Cur_Buyer_plnr_id INTO G_Buyer_plnr_id;
       IF Cur_Buyer_plnr_id%NOTFOUND THEN
         FND_FILE.PUT_LINE ( FND_FILE.LOG,'Bad User Code '||G_Buyer_plnr_id);
         G_Buyer_plnr_id := -1;
       END IF;
       CLOSE Cur_Buyer_plnr_id;

   IF G_Buyer_plnr_id > 0 THEN

       G_planning_tab.delete;
       mr_insert_header;

       IF G_planning_tab.count > 0 then
         G_no_of_reports := to_char(to_number(G_no_of_reports) + 1);
         --BEGIN BUG#2889706 Sastry
         --Commented the following call as it is moved above.
         --set_where_clause;
         --END BUG#2889706
         X_ri_where := G_where;
         mr_unbucket_report;
         -- Invoke the concurrent manager from here
         IF V_number_of_copies > 0 THEN
            X_status := FND_REQUEST.SET_PRINT_OPTIONS(V_printer,
                                                      UPPER(V_user_print_style),
                                                 V_number_of_copies, TRUE, 'N');
         END IF;
         -- request is submitted to the concurrent manager
         FND_FILE.PUT_LINE ( FND_FILE.LOG,' Submitting the Req '||sqlerrm);

        X_conc_id := FND_REQUEST.SUBMIT_REQUEST('GMP','RIMR1USR','',
                     TO_CHAR(V_run_date1,'YYYY/MM/DD HH24:MI:SS'),
                     FALSE, TO_CHAR(G_matl_rep_id),
                     TO_CHAR(G_Buyer_plnr_id), X_ri_where,
                     TO_CHAR(V_run_date,'YYYY/MM/DD HH24:MI:SS'),
                     V_schedule,V_usr_orgn_code,CHR(0),'','','',
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
--
         IF X_conc_id = 0 THEN
           G_log_text := FND_MESSAGE.GET;
           FND_FILE.PUT_LINE ( FND_FILE.LOG,G_log_text);
           retcode:=2;
           exit;
         ELSE
           COMMIT ;
         END IF;

       END IF;  /* End if Planning Tab Count */
   END IF;  /* END IF for G_Buyer_plnr_id */
     END LOOP;
--
     CLOSE Cur_buyer_plnr;
--
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
  EXCEPTION
   WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in Print mrp Activity'||sqlerrm);



END print_mrp_activity;  /***** END PROCEDURE ***************************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_insert_header                                      |
|                                                                             |
| DESCRIPTION		Procedure to insert data into ps_matl_hdr             |
|                       This Procedure fetches data for the Header Table by   |
|                       building the Where condition based on the User and the|
|                       Planning Classes and then inserts into the Header     |
|                       Table by creating a record group                      |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   12/31/02     Sridhar Gidugu  -----	created                               |
|                                                                             |
+============================================================================*/

PROCEDURE mr_insert_header IS

 X_where             VARCHAR2(5000) := NULL ;
 X_row_count         NUMBER;
 X_rep_id            NUMBER;
 X_i                 NUMBER;
 X_planning_class    VARCHAR2(8) := NULL ;
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
           /* this information is used for Report Header Purposes */

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
       FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error writing to Header'||sqlerrm);

END mr_insert_header;  /***** END PROCEDURE********************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	set_where_clause                                      |
|                                                                             |
| DESCRIPTION		Procedure to set the Where Clause for the given from  |
|                       warehouse and to warehouse and from trans date and to |
|                          trans date parameters                              |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   12/31/02     Sridhar Gidugu  -----	created                               |
|   04/22/03     Sastry  BUG#2889706 Modified the G_where by replacing to_char|
|                        with fnd_date.date_to_canonical.                     |
+============================================================================*/
PROCEDURE set_where_clause IS
BEGIN
    IF G_fwhse_code IS NOT NULL THEN
      G_where := G_where||' and whse_code >= '||''''||G_fwhse_code||'''';
    END IF;
--
    IF G_twhse_code IS NOT NULL THEN
      G_where := G_where||' and whse_code <= '||''''||G_twhse_code||'''';
    END IF;
    IF G_ftrans_date IS NOT NULL THEN
      --BEGIN BUG#2889706 Sastry
      --Modified the G_where by replacing to_char with fnd_date.date_to_canonical
      G_where := G_where||' and trans_date >= fnd_date.canonical_to_date('''||
                                fnd_date.date_to_canonical(G_ftrans_date)||''')';
    END IF;
    IF G_ttrans_date IS NOT NULL THEN
      G_where := G_where||' and trans_date <= fnd_date.canonical_to_date('''||
                                fnd_date.date_to_canonical(G_ttrans_date)||''')';
      --END BUG#2889706
    END IF;
END set_where_clause; /* End of Procedure set where Clause */
/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_unbucket_report                                    |
|                                                                             |
| DESCRIPTION		Procedure to call mr_unbucket_details for items.      |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   12/31/02     Sridhar Gidugu -----	created                               |
|                                                                             |
+============================================================================*/

PROCEDURE mr_unbucket_report IS

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
        G_doc_tab.delete;
        mr_data_retrieval(X_item_id, X_planning_class);
      END IF;
    END LOOP;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, sqlerrm);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error writing to Unbucket'||sqlerrm);

END mr_unbucket_report;  /***** END PROCEDURE ********************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_data_retrieval                                     |
|                                                                             |
| DESCRIPTION		Procedure to Retrieve the Data for Unbucketed material|
|                       activity and for each item from mr_tran_tbl based on  |
|                       mrp_id and warehouse list                             |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   12/31/02     Sridhar Gidugu  -----	created                               |
|                                                                             |
+============================================================================*/

PROCEDURE mr_data_retrieval(V_item_id  IN   NUMBER,
                            V_planning_class IN   VARCHAR2) IS
 X_row_count   NUMBER;
 X_select      VARCHAR2(3000);
 gs_temp      VARCHAR2(3000);
 X_status      NUMBER(5);
 X_first_flag  NUMBER(5);
 X_doc         NUMBER;
 X_doc_type    Varchar2(4);
 X_trans_date  Date;
 X_orgn_code   Varchar2(4);
 X_doc_id      NUMBER(10);
 X_trans_qty   NUMBER;
 X_cust_vend   Varchar2(32);
 X_line_no     NUMBER(10);
 X_whse_code   VARCHAR2(4);
 X_i		NUMBER(5) := 0;
 X_date        DATE;
 X_pastdue           CHAR(1) := '';
 X_ret         Number;

 BEGIN
   -- to get warehouse list.
   IF V_item_id is NOT NULL
   THEN
       mr_whse_list(V_item_id) ;    /* Procedure to create list valid Whses */
   END IF;

   -- to get balance
   IF G_whse_list IS NOT NULL THEN
      mr_get_balance(V_item_id) ;  /* Procedure to get the On Hand Qty */
      -- to get safety_stock from ic_whse_inv
      mr_get_safety_stock(V_item_id) ;  /* Get Safety Stock Details */
--      mr_schedule_parms;

   -- Added LEXP for Lot expiry project B3219257 Rajesh Patangya 10/28/2003

      X_select := ' SELECT mr.doc_type doc_type,mr.trans_date trans_date, '||
	 	' mr.orgn_code orgn_code,mr.doc_id doc_id, '||
		' mr.trans_qty trans_qty, '||
                ' null cust_vend, mr.line_no line_no, mr.whse_code whse_code'||
		' FROM  mr_tran_tbl mr'||
                ' WHERE mrp_id = TO_CHAR(:1) ' ||
                ' AND mr.item_id = TO_CHAR(:2) ' ||
		' AND mr.whse_code in ('|| G_whse_list ||')'||
	' AND mr.doc_type in ('||''''||'PROD'||''''||','||''''||'FPO'||''''||',
                      '||''''||'PORD'||''''||','||''''||'PREQ'||''''||',
                      '||''''||'OMSO'||''''||','||''''||'OPSO'||''''||',
                      '||''''||'PPUR'||''''||','||''''||'PPRD'||''''||',
                      '||''''||'FCST'||''''||','||''''||'PTRN'||''''||',
  '||''''||'LEXP'||''''||','||''''||'PRCV'||''''||','||''''||'SHMT'||''''||',
       '||''''||'PBPR'||''''||','||''''||'XFER'||''''||','||''''||'PBPO'||''''||')'||
		' ORDER BY 2 ASC, 5 DESC';

       X_doc := dbms_sql.open_cursor;
       dbms_sql.parse(X_doc, X_select,dbms_sql.NATIVE);

        dbms_sql.bind_variable(X_doc,':1',G_mrp_id);
        dbms_sql.bind_variable(X_doc,':2',V_item_id);

       dbms_sql.define_column(X_doc, 1, X_doc_type,4);
       dbms_sql.define_column(X_doc, 2, X_trans_date);
       dbms_sql.define_column(X_doc, 3, X_orgn_code,4);
       dbms_sql.define_column(X_doc, 4, X_doc_id);
       dbms_sql.define_column(X_doc, 5, X_trans_qty);
       dbms_sql.define_column(X_doc, 6, X_cust_vend,32);
       dbms_sql.define_column(X_doc, 7, X_line_no);
       dbms_sql.define_column(X_doc, 8, X_whse_code,4);


       X_row_count := dbms_sql.execute(X_doc);

       X_first_flag := 1;

       --IF X_row_count > 0
       --THEN
           LOOP
              X_row_count := dbms_sql.fetch_rows (X_doc);
              IF X_row_count = 0 THEN
                EXIT;
              END IF;
              X_i := X_i + 1;
              dbms_sql.column_value(X_doc, 1, X_doc_type);
              dbms_sql.column_value(X_doc, 2, X_trans_date);
              dbms_sql.column_value(X_doc, 3, X_orgn_code);
              dbms_sql.column_value(X_doc, 4, X_doc_id);
              dbms_sql.column_value(X_doc, 5, X_trans_qty);
              dbms_sql.column_value(X_doc, 6, X_cust_vend);
              dbms_sql.column_value(X_doc, 7, X_line_no);
              dbms_sql.column_value(X_doc, 8, X_whse_code);
--
              G_doc_tab(X_i).doc_type := X_doc_type;
              G_doc_type := G_doc_tab(X_i).doc_type;
              G_doc_tab(X_i).trans_date  := X_trans_date;
              G_doc_tab(X_i).orgn_code   := X_orgn_code;

           -- Assigning the orgn code values for OMSO doc type
           -- B2992073 10/28/2003 Rajesh Patangya

              G_orgn_code := X_orgn_code;

              G_doc_tab(X_i).doc_id      := X_doc_id;
              G_doc_id := G_doc_tab(X_i).doc_id;
              G_doc_tab(X_i).trans_qty   := X_trans_qty;
              G_doc_tab(X_i).cust_vend   := X_cust_vend; /* NULL  */
              G_doc_tab(X_i).line_no     := X_line_no;
              G_line_no := G_doc_tab(X_i).line_no;
              G_doc_tab(X_i).whse_code   := X_whse_code;
--
/*
              dbms_output.put_line(' Doc Type '||G_doc_tab(X_i).doc_type);
              dbms_output.put_line(' Trans Date '||G_doc_tab(X_i).trans_date);
              dbms_output.put_line(' Orgn Code '||G_doc_tab(X_i).orgn_code);
              dbms_output.put_line(' Doc Id '||G_doc_tab(X_i).doc_id);
              dbms_output.put_line(' Trans Qty '||G_doc_tab(X_i).trans_qty);
              dbms_output.put_line(' Line No '||G_doc_tab(X_i).line_no);
              dbms_output.put_line(' Whse Code '||G_doc_tab(X_i).whse_code);
*/
--
              G_balance1 := G_balance1 + G_doc_tab(X_i).trans_qty;
              IF X_first_flag = 1
              THEN
                 G_balance := G_balance1 - G_doc_tab(X_i).trans_qty;
              END IF;
--
              X_first_flag := 0;

              IF (nvl(G_balance1,0) < nvl(G_total_ss,0))
              THEN
                 G_c_ind := '**';
--                 mr_insert_details(V_item_id,V_planning_class);
                   mr_cleanup_details;
                   SELECT sysdate into X_date from dual;
                   X_ret :=  G_doc_tab(X_i).trans_date - X_date;
                   IF (X_ret < 0) THEN
                       X_pastdue := '*';
                   ELSE
                       X_pastdue := NULL;
                   END IF;
                   /* Insert the Transaction Data into mr_ubkt_dtl table
                      for Report to Process and show the data on the screen */
                   INSERT INTO mr_ubkt_dtl(matl_rep_id,
                                           item_id,
                                           planning_class,
                                           whse_code,
                                           start_balance,
                                           past_due,
                                           trans_date,
                                           doc_type,
                                           orgn_code,
                                           doc_id,
                                           doc_no,
                                           trans_qty,
                                           balance,
                                           critical_ind,
                                           cust_vend
                                         )
                               VALUES(G_matl_rep_id,
                                      V_item_id,
                                      V_planning_class,
                                      G_doc_tab(X_i).whse_code,
                                      G_start_balance,
                                      X_pastdue,
                                      G_doc_tab(X_i).trans_date,
                                      G_doc_tab(X_i).doc_type,
                                      G_doc_tab(X_i).orgn_code,
--                         nvl(G_doc_tab(i).doc_id,0),
                                      nvl(G_doc_id,0),
                                      G_doc_no,
                                      G_doc_tab(X_i).trans_qty,
                                      G_balance1,
                                      G_c_ind,
                                      --Begin Bug#2131275 P.Raghu
                                      --G_cust_vend value is inserted instead of NULL.
                                      --G_doc_tab(X_i).cust_vend
                                      G_cust_vend
                                      --End Bug#2131275
                                    );
                       /* Insert data complete */
                       G_start_balance := 0.00;

              ELSIF G_critical_indicator = 0
              THEN
--                 mr_insert_details(V_item_id,V_planning_class);

                   mr_cleanup_details;
                   SELECT sysdate into X_date from dual;
                   X_ret :=  G_doc_tab(X_i).trans_date - X_date;
                   IF (X_ret < 0) THEN
                       X_pastdue := '*';
                   ELSE
                       X_pastdue := NULL;
                   END IF;
                   /* Insert the Transaction Data into mr_ubkt_dtl table
                      for Report to Process and show the data on the screen */
                   INSERT INTO mr_ubkt_dtl(matl_rep_id,
                                           item_id,
                                           planning_class,
                                           whse_code,
                                           start_balance,
                                           past_due,
                                           trans_date,
                                           doc_type,
                                           orgn_code,
                                           doc_id,
                                           doc_no,
                                           trans_qty,
                                           balance,
                                           critical_ind,
                                           cust_vend
                                         )
                               VALUES(G_matl_rep_id,
                                      V_item_id,
                                      V_planning_class,
                                      G_doc_tab(X_i).whse_code,
                                      G_start_balance,
                                      X_pastdue,
                                      G_doc_tab(X_i).trans_date,
                                      G_doc_tab(X_i).doc_type,
                                      G_doc_tab(X_i).orgn_code,
--                         nvl(G_doc_tab(i).doc_id,0),
                                      nvl(G_doc_id,0),
                                      G_doc_no,
                                      G_doc_tab(X_i).trans_qty,
                                      G_balance1,
                                      G_c_ind,
                                      --Begin Bug#2131275 P.Raghu
                                      --G_cust_vend value is inserted instead of NULL.
                                      --G_doc_tab(X_i).cust_vend
                                      G_cust_vend
                                      --End Bug#2131275
                                    );
                       /* Insert data complete */
                       G_start_balance := 0.00;
--
              END IF;

              G_c_ind := '';
           END LOOP;
           G_doc_tab.delete;
           dbms_sql.close_cursor(X_doc);
       --END IF;
--
      /* if there are no transactions then that item row is deleted from
         header table. */
      IF X_i = 0 THEN
         DELETE FROM ps_matl_hdr
         WHERE item_id = V_item_id
         AND matl_rep_id = G_matl_rep_id;
      END IF;
--

   END IF; /* End if for G_whse_list NOT NULL */

    EXCEPTION
        WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error writing to mr_ubkt_dtl'||sqlerrm);
 END mr_data_retrieval; /***** END FUNCTION ********************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_whse_list                                          |
|                                                                             |
| DESCRIPTION		Procedure to create the list of valid warehouses      |
|                       for the given Schedule and Item, and build warehouses |
|                       list depending on number of warehouses the item is    |
|                       present                                               |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   01/01/03     Sridhar Gidugu   -----	created                               |
|   12/19/03     Kalyani Manda   Bug3168907                                   |
|                                Modified code to look for PS_WHSE_EFF |
|                                for item/whse_item_id combination for |
|                                considering the material activity     |

+============================================================================*/

PROCEDURE mr_whse_list(V_item_id NUMBER) IS

    TYPE ref_cursor_typ is REF CURSOR;
    Cur_matl_act ref_cursor_typ;

    --Bug 3168907 Kalyani Manda  Added the cursor.
    Cursor Cur_get_whse_item_id ( V_item_id NUMBER) IS
        SELECT whse_item_id
        FROM   ic_item_mst
        WHERE  item_id = V_item_id;


    X_sel_whse_list VARCHAR2(2000);
    X_matl_whse 	  VARCHAR2(4);
    X_count 	  	  NUMBER(5) := 0;   --3168907 assigned the default value.
    X_fwhse_code     VARCHAR2(4);
    X_twhse_code     VARCHAR2(4);
    --Bug 3168907 Added the variables
    X_whse           VARCHAR2(4);
    X_whse_item_id	NUMBER;
    X_whse_eff_item_id	NUMBER;

  BEGIN
    G_sy_all := fnd_profile.value('SY$ALL');

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
--
    IF G_mrp_id IS NOT NULL AND G_schedule_id IS NOT NULL THEN

       --Bug 3168907 Fetch the whse_item_id for the item.
       OPEN Cur_get_whse_item_id(V_item_id);
       FETCH Cur_get_whse_item_id INTO X_whse_item_id;
       CLOSE Cur_get_whse_item_id;

       /* Define Cursor per whse security to select the whse code */
       IF nvl(G_whse_security,'N') = 'N' THEN
          --Bug 3168907 Added ps_whse_eff whs to fetch whse_item_id
          OPEN Cur_matl_act for
          SELECT distinct trn.whse_code, whs.whse_item_id
          FROM   mr_tran_tbl trn,  ps_schd_dtl sch, ps_whse_eff whs
          WHERE  sch.schedule_id = G_schedule_id
          AND trn.mrp_id = G_mrp_id
          AND item_id = V_item_id
          AND whs.whse_code = trn.whse_code
          AND whs.plant_code = sch.orgn_code
          AND (whs.whse_code >= X_fwhse_code
               OR X_fwhse_code IS NULL)
          AND (whs.whse_code <= X_twhse_code
               OR X_twhse_code IS NULL)
          ORDER BY 1;

       ELSE
          --Bug 3168907 Added ps_whse_eff whs to fetch whse_item_id
          OPEN Cur_matl_act for
          SELECT distinct trn.whse_code, whs.whse_item_id
          FROM   mr_tran_tbl trn, ps_schd_dtl sch, sy_orgn_usr org, ps_whse_eff whs
          WHERE sch.orgn_code = org.orgn_code
          and sch.schedule_id = G_schedule_id
          and mrp_id = G_mrp_id
          and item_id = V_item_id
          and org.user_id = G_Buyer_plnr_id
          and whs.plant_code = sch.orgn_code
          and whs.whse_code = trn.whse_code
          and (whs.whse_code >= X_fwhse_code
               or X_fwhse_code IS NULL)
          and (whs.whse_code <= X_twhse_code
               or X_twhse_code IS NULL)
          ORDER BY 1 ;
       END IF;
--
       FETCH Cur_matl_act INTO X_matl_whse, X_whse_eff_item_id;  --Bug 3168907 Added X_whse_eff_item_id
       IF Cur_matl_act%NOTFOUND THEN
	  X_count:=0;
       ELSE
         LOOP
            --Begin Bug 3168907
            IF X_whse_eff_item_id IS NULL OR X_whse_item_id = x_whse_eff_item_id THEN
              IF X_count > 0 Then
                 X_sel_whse_list := X_sel_whse_list||',';
              END IF;
              X_sel_whse_list 	:= X_sel_whse_list||''''||X_matl_whse||'''';
              X_whse  := X_matl_whse;
              X_count := X_count + 1;
            END IF;
            FETCH Cur_matl_act INTO X_matl_whse, X_whse_eff_item_id;
	    IF Cur_matl_act%NOTFOUND THEN
	      EXIT;
            END IF;
            --End Bug 3168907
          END LOOP;
       END IF;
       CLOSE Cur_matl_act;
--
            IF X_count = 1
            THEN
               G_whse_code := X_whse;   --3168907 Modified assignment from x_matl_whse to X_whse.
            ELSIF X_count > 1
            THEN
                IF G_sy_all = 'SY$ALL'
                THEN
                   G_whse_code := NULL;
                ELSE
                   G_whse_code := G_sy_all;
                END IF;
            END IF;
--
            G_num_whses :=  X_count;
            G_whse_list :=  X_sel_whse_list;

    END IF;
    EXCEPTION
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm||'mr_whse_list');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error writing to Whse List'||sqlerrm);
END  mr_whse_list;  /******** END PROCEDURE*************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_get_balance                                        |
|                                                                             |
| DESCRIPTION		Procedure to get the Initial balance from mr_tran_tbl |
|                       for that particular Item                              |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   01/01/03     Sridhar Gidugu   -----	created                               |
|                                                                             |
+============================================================================*/

PROCEDURE mr_get_balance(V_item_id NUMBER) IS

 X_select1      VARCHAR2(2000) := NULL;
 cur_balance    NUMBER;
 X_row_count    NUMBER(5);
  BEGIN
    X_select1   :='SELECT sum(trans_qty) total'||
                ' FROM mr_tran_tbl mr'||
                ' WHERE mrp_id= to_char(:1) AND item_id = to_char(:2) ' ||
                ' AND whse_code in (' || G_whse_list || ') ' ||
                ' AND doc_type='||''''||'BAL'||''''||
                ' group by mr.doc_type';

    cur_balance := dbms_sql.open_cursor;
    dbms_sql.parse (cur_balance, X_select1,dbms_sql.NATIVE);

    dbms_sql.bind_variable(cur_balance,':1',G_mrp_id);
    dbms_sql.bind_variable(cur_balance,':2',V_item_id);

    dbms_sql.define_column (cur_balance, 1, G_on_hand1);
    X_row_count := dbms_sql.execute(cur_balance);
    IF dbms_sql.fetch_rows (cur_balance) > 0 then
       dbms_sql.column_value (cur_balance, 1, G_on_hand1);
    ELSE
       G_on_hand1 := 0;
    END IF;
    dbms_sql.close_cursor (cur_balance);
--
    G_balance1 := G_on_hand1;
    G_start_balance := G_balance1;

    EXCEPTION
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error Get Balance '||sqlerrm);
      IF dbms_sql.is_open (cur_balance) then
	     dbms_sql.close_cursor (cur_balance);
      END IF;

  END mr_get_balance;   /******** END PROCEDURE*************/

/*============================================================================+
|                                                                             |
| PROCEDURE NAME	mr_get_safety_stock                                   |
|                                                                             |
| DESCRIPTION		Procedure to get the safety stock Information for the |
|                       Item                                                  |
|                                                                             |
| MODIFICATION HISTORY                                                        |
|   12/31/02     Sridhar Gidugu   -----	created                               |
|                                                                             |
+============================================================================*/

PROCEDURE mr_get_safety_stock(V_item_id NUMBER) IS

    CURSOR Cur_unit_safety_stock(C_item_id NUMBER) IS
      SELECT safety_stock
      FROM   ic_whse_inv
      WHERE  item_id= C_item_id
      AND whse_code is NULL and delete_mark=0;

    X_whse_cnt 		NUMBER(5);
    X_select1 		VARCHAR2(2000) := NULL ;
    X_row_count		NUMBER(5);
    cur_sstock          NUMBER;
  BEGIN

    X_select1 :='SELECT sum(safety_stock) total_ss,count(*) no_ss'||
    	      	' FROM ic_whse_inv'||
        	' WHERE item_id= to_char(:1) ' ||
    		' AND whse_code in ('|| G_whse_list ||') and delete_mark=0';

    IF G_whse_list IS NOT NULL THEN
       cur_sstock := dbms_sql.open_cursor;
       dbms_sql.parse (cur_sstock, X_select1,dbms_sql.NATIVE);

       dbms_sql.bind_variable(cur_sstock,':1',V_item_id);

       dbms_sql.define_column (cur_sstock, 1, G_total_ss);
       dbms_sql.define_column (cur_sstock, 2, G_no_safetystock);
       X_row_count := dbms_sql.execute(cur_sstock);
       IF dbms_sql.fetch_rows (cur_sstock) > 0 then
          dbms_sql.column_value (cur_sstock, 1, G_total_ss);
          dbms_sql.column_value (cur_sstock, 2, G_no_safetystock);
       ELSE
          G_total_ss       := 0;
          G_no_safetystock := 0;
       END IF;
          dbms_sql.close_cursor (cur_sstock);
    END IF;

    IF ((NVL(G_no_safetystock,0) < NVL(G_num_whses,0))) THEN
      G_unit_ss := 0;
      OPEN Cur_unit_safety_stock(V_item_id);
      FETCH Cur_unit_safety_stock INTO G_unit_ss;
      CLOSE Cur_unit_safety_stock;
      X_whse_cnt := G_num_whses;

      IF (G_whse_code <> G_sy_all)
      THEN
         X_whse_cnt := 1;
      END IF;

      G_total_ss := NVL(G_total_ss,0) +
                     (X_whse_cnt - NVL(G_no_safetystock,0)) * G_unit_ss;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error Get Safety Stock '||sqlerrm);
        IF dbms_sql.is_open (cur_sstock) then
	       dbms_sql.close_cursor (cur_sstock);
        END IF;

END mr_get_safety_stock; /******** END PROCEDURE*************/




  /*############################################################################
  # NAME
  #    mr_cleanup_details
  # SYNOPSIS
  #    Proc mr_cleanup_details
  # DESCRIPTION
  #    This procedure adds details such as orgn_code,doc_no,cust_vend which are
  #    retrieved from the corresponding master tables based on the
  #    doc_type,to the item transaction rows before they are displayed
  #    to the end user.If the transaction doc id is not order id then
  #    the following code extracts the bol id and displays it against
  #    the transaction for material activity inquiry. For distinguishing
  #    the order id from bol id, the doc type will be displayed as 'OPSP'
  #    instead of transaction doc type of 'OPSO'. Since there can be
  #    multiple sales orders in one shipment, the customer no in such cases
  #    will be displayed as 'MULTIPLE'.
  #
  #    Sridhar Gidugu 02/01/2003  - Created
  #    P.Raghu  12/26/03 - B2131275 - Modified Cur_vend_dtl and Cur_req_dtl cursors
  #             to select vendor_name and suggested_vendor_name instead of
  #             segment1 value for Customer/Vendor respectively.
  #    Sastry 04/01/2004 - B3482123 - Replaced po_headers_all table with
  #             po_po_supply_view so that releases are shown for 'PORD' doc_type.
  #############################################################################*/
  PROCEDURE mr_cleanup_details  IS
    CURSOR Cur_custno IS
      SELECT  cs.cust_no cust_no
      FROM    op_cust_mst cs, op_ordr_dtl dt
      WHERE   dt.bol_id = G_doc_id
        AND   dt.shipcust_id = cs.cust_id;

    --Bug#2131275  P.Raghu
    --Selecting pv.vendor_name instead of pv.segment1 value for Customer/Vendor.
    --BUG#3482123 Sastry Replaced po_headers_all table with po_po_supply_view.
    CURSOR Cur_vend_dtl IS
      SELECT  unique mtt.orgn_code, po.po_number, SUBSTRB(vn.vendor_name,1,32)
      FROM   po_po_supply_view po,
     	     po_vendors vn,
     	     mr_tran_tbl mtt
      WHERE  po.po_line_location_id = mtt.doc_id
      AND    mtt.mrp_id = G_mrp_id
      AND    mtt.doc_id = G_doc_id
      AND    mtt.line_no = G_line_no
      AND    mtt.doc_type = 'PORD'
      AND    vn.vendor_id (+) = po.vendor_id ;

    -- PRCV, SHMT
    --Bug#2131275  P.Raghu
    --Selecting pv.vendor_name instead of pv.segment1 value for Customer/Vendor.
    CURSOR Cur_prcv_dtl IS
      SELECT unique mtt.orgn_code, prh.receipt_num, SUBSTRB(vn.vendor_name,1,32)
      FROM   rcv_shipment_headers prh,
     	     po_vendors vn,
     	     mr_tran_tbl mtt
      WHERE  prh.shipment_header_id = G_doc_id
      AND    mtt.mrp_id = G_mrp_id
      AND    mtt.line_no = G_line_no
      AND    mtt.doc_id = G_doc_id
      AND    mtt.doc_type in ('PRCV','SHMT')
      AND    vn.vendor_id (+) = prh.vendor_id
      UNION ALL
      SELECT unique mtt.orgn_code, prh.segment1, SUBSTRB(vn.vendor_name,1,32)
      FROM   po_headers_all prh,
     	     po_vendors vn,
     	     mr_tran_tbl mtt
      WHERE  prh.po_header_id = G_doc_id
      AND    mtt.mrp_id = G_mrp_id
      AND    mtt.line_no = G_line_no
      AND    mtt.doc_id = G_doc_id
      AND    mtt.doc_type = 'PRCV'
      AND    vn.vendor_id (+) = prh.vendor_id  ;

    CURSOR Cur_cust_dtl IS
      SELECT op.orgn_code, op.order_no,cs.cust_no
      FROM   op_ordr_hdr op,  op_cust_mst cs
      WHERE  op.order_id = G_doc_id
      	     AND   op.shipcust_id = cs.cust_id;

    CURSOR Cur_order_dtl IS
      SELECT op.orgn_code, op.bol_no
      FROM   op_bill_lad  op
      WHERE  op.bol_id = G_doc_id;

    CURSOR Cur_batch_dtl is
      SELECT gbh.plant_code, gbh.batch_no
      FROM   gme_batch_header gbh
      WHERE  gbh.batch_id = G_doc_id
        AND  gbh.delete_mark = 0;

    -- B1159495 Rajesh Patangya
     CURSOR Cur_transfer_dtl is
       SELECT ic.orgn_code,ic.transfer_no
       FROM   ic_xfer_mst ic
       WHERE  ic.transfer_id = G_doc_id;

    --  Added OMSO doc type
    -- B2992073 10/28/2003 Rajesh Patangya
    CURSOR Cur_om_order_details IS
      SELECT oh.order_number, sold_to_org.customer_number
      FROM   oe_order_headers_all oh,
             oe_sold_to_orgs_v sold_to_org
      WHERE  oh.header_id = G_doc_id
        AND  oh.sold_to_org_id =   sold_to_org.organization_id(+) ;

    CURSOR Cur_purchase_dtl IS
      SELECT bh.orgn_code, bh.bpo_no,bd.line_no
      FROM   po_bpos_dtl bd, po_bpos_hdr bh
      WHERE  bd.line_id = G_doc_id
      	     AND    bd.bpo_id = bh.bpo_id;

    --Bug#2131275  P.Raghu
    --Selecting prl.Suggested_vendor_name instead of pv.segment1 value for Customer/Vendor.
    CURSOR Cur_req_dtl IS
      SELECT  unique mtt.orgn_code, prh.segment1, SUBSTRB(prl.suggested_vendor_name,1,32)
      FROM   po_requisition_headers prh,
             po_requisition_lines prl,
     	     po_vendors vn,
     	     mr_tran_tbl mtt
      WHERE  prl.requisition_header_id = G_doc_id
      AND    prh.requisition_header_id = prl.requisition_header_id
      AND    mtt.mrp_id = G_mrp_id
      AND    mtt.line_no = G_line_no
      AND    mtt.doc_id = G_doc_id
      AND    mtt.doc_type = 'PREQ'
      AND    vn.vendor_id (+) = prl.vendor_id  ;


    X_custno      	VARCHAR2(32);
    X_orgn_code 	VARCHAR2(4);
    X_doc_no 		VARCHAR2(32);
    X_cust_vend		VARCHAR2(32);
    NO_MATCH_DOC  	EXCEPTION;

  BEGIN
    X_orgn_code:=NULL;
    X_doc_no:=NULL;
    X_cust_vend:=NULL;

    IF G_doc_type= 'PORD' THEN
      OPEN Cur_vend_dtl;
      FETCH Cur_vend_dtl INTO X_orgn_code,X_doc_no,X_cust_vend;
      CLOSE Cur_vend_dtl;
    ELSIF G_doc_type in ('PRCV','SHMT') THEN
      OPEN Cur_prcv_dtl;
      FETCH Cur_prcv_dtl INTO X_orgn_code,X_doc_no,X_cust_vend;
      CLOSE Cur_prcv_dtl;
    ELSIF G_doc_type= 'XFER' THEN
       OPEN Cur_transfer_dtl;
       FETCH Cur_transfer_dtl INTO X_orgn_code,X_doc_no;
       CLOSE Cur_transfer_dtl;
    ELSIF G_doc_type='OPSO' THEN
      OPEN Cur_cust_dtl;
      FETCH Cur_cust_dtl INTO X_orgn_code,X_doc_no,X_cust_vend;
      IF Cur_cust_dtl%NOTFOUND THEN
	CLOSE Cur_cust_dtl;

	OPEN Cur_order_dtl;
	FETCH Cur_order_dtl INTO X_orgn_code,X_doc_no;
	CLOSE Cur_order_dtl;
--
	OPEN Cur_custno;
	FETCH Cur_custno INTO X_custno;
	CLOSE Cur_custno;
--
	IF Cur_order_dtl%ROWCOUNT > 1 THEN
          X_cust_vend := 'MULTIPLE';
        ELSE
          X_cust_vend := X_custno;
        END IF;
--
	G_doc_type := 'OPSP';
      END IF;

      CLOSE Cur_cust_dtl;

    -- B2992073 10/28/2003 Rajesh Patangya
    ELSIF (G_doc_type = 'OMSO') THEN
      OPEN Cur_om_order_details;
      FETCH Cur_om_order_details INTO X_doc_no, X_cust_vend;
      CLOSE Cur_om_order_details;
    ELSIF G_doc_type= 'PROD' OR G_doc_type = 'FPO' THEN
      OPEN Cur_batch_dtl;
      FETCH Cur_batch_dtl INTO X_orgn_code,X_doc_no;
      CLOSE Cur_batch_dtl;
    ELSIF G_doc_type = 'PBPR' OR G_doc_type = 'PBPO' THEN
      OPEN Cur_purchase_dtl;
      FETCH Cur_purchase_dtl INTO X_orgn_code,X_doc_no,X_cust_vend;
      CLOSE Cur_purchase_dtl;
    ELSIF G_doc_type = 'PREQ' THEN
      OPEN Cur_req_dtl;
      FETCH Cur_req_dtl INTO X_orgn_code,X_doc_no, X_cust_vend;
      CLOSE Cur_req_dtl;
    ELSE
      G_doc_no:= NULL;
      G_cust_vend:=NULL;
      select gem5_mrp_doc_id_s.nextval into G_doc_id
             from dual;
      Raise NO_MATCH_DOC;
    END IF;

    IF G_doc_type <> 'OMSO' THEN
       G_orgn_code:= X_orgn_code;
    END IF;

    G_doc_no:= X_doc_no;
    G_cust_vend:= X_cust_vend;
  EXCEPTION
    WHEN NO_MATCH_DOC THEN
      Null;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in Cleanup details '||sqlerrm);
  END mr_cleanup_details;


END GMPMRACT; /***** END PACKAGE BODY ***************************/

/
