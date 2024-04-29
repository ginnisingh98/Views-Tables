--------------------------------------------------------
--  DDL for Package Body PKG_GMP_BUCKET_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PKG_GMP_BUCKET_DATA" as
        /* $Header: GMPBCKTB.pls 120.1 2005/06/21 22:48:52 appldev ship $ */

         FUNCTION mr_bucket_data (V_schedule NUMBER,
                                  V_mrp_id  NUMBER,
                                  V_item_id NUMBER,
                                  V_whse_list VARCHAR2,    /* List with seperat  */
                                  V_on_hand NUMBER,
                                  V_total_ss NUMBER,
                                  V_matl_rep_id NUMBER) RETURN NUMBER IS
          TYPE trans_date_type IS TABLE OF mr_tran_tbl.trans_date%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE document_type IS TABLE OF sy_docs_mst.doc_type%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE trans_qty_type IS TABLE OF mr_tran_tbl.trans_qty%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE orgn_code_type IS TABLE OF sy_orgn_mst.orgn_code%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE period_start_date_type IS TABLE OF ps_matl_dtl.perd_end_date%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE period_end_date_type IS TABLE OF ps_matl_dtl.perd_end_date%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE period_name_type IS TABLE OF ps_matl_dtl.perd_name%TYPE
               INDEX BY BINARY_INTEGER;
          trans_date_tab	TRANS_DATE_TYPE;
          doc_type_tab          DOCUMENT_TYPE;
          trans_qty_tab         TRANS_QTY_TYPE;
          orgn_code_tab         ORGN_CODE_TYPE;
          period_start_date_tab PERIOD_START_DATE_TYPE;
          period_end_date_tab   PERIOD_END_DATE_TYPE;
          period_name_tab       PERIOD_NAME_TYPE;

          CURSOR Cur_trans_dtl IS
            SELECT doc_type,trans_date,orgn_code,trans_qty
            FROM   mr_tran_tbl
            WHERE mrp_id =V_mrp_id
                AND item_id =V_item_id
                AND INSTR(V_whse_list, whse_code) <> 0
            ORDER BY trans_date asc, trans_qty desc;
          CURSOR Cur_schedule IS
            SELECT no_days, no_weeks, no_4weeks, no_13weeks
            FROM   ps_schd_hdr
            WHERE  schedule_id = V_schedule
                   AND delete_mark = 0;
          CURSOR Cur_check_hdr IS
            SELECT matl_rep_id
            FROM   ps_matl_hdr
            WHERE  matl_rep_id = V_matl_rep_id;
          CURSOR Cur_matl_rep_id IS
            SELECT gem5_matl_rep_id_s.NEXTVAL
            FROM   dual;
          X_rows	      	NUMBER DEFAULT 0;
          prior_to_one 		NUMBER DEFAULT 0;
          X_trans_date    	DATE;
          X_qty	      		NUMBER DEFAULT 0;
          X_whse_code     	VARCHAR2(4);
          X_retvar	      	NUMBER(5);
          X_workdate1     	DATE;
          X_workdate2     	DATE;
          X_period	      	VARCHAR2(40);
          X_no_days       	NUMBER(5);
          X_no_weeks      	NUMBER(5);
          X_no_4weeks     	NUMBER(5);
          X_no_13weeks    	NUMBER(5);
          X_date1	      	DATE;
          X_date2	      	DATE;
          X_day1	      	VARCHAR2(30);
          X_n	            	NUMBER(5);
          X_i	            	NUMBER(5);
          X_j	            	NUMBER(5);
          X_dcount        	NUMBER;
          X_wcount        	NUMBER;
          X_mcount        	NUMBER;
          X_qcount        	NUMBER;
          X_matl_rep_id   	NUMBER;
          X_tot_periods   	NUMBER(5);
          X_sales_orders	NUMBER DEFAULT 0;
          X_forecast		NUMBER DEFAULT 0;
          X_dep_demand		NUMBER DEFAULT 0;
          X_plnd_ingred		NUMBER DEFAULT 0;
          X_po_receipts		NUMBER DEFAULT 0;
          X_sched_prod		NUMBER DEFAULT 0;
          X_plnd_prod		NUMBER DEFAULT 0;
          X_total_demand	NUMBER DEFAULT 0;
          X_total_supply	NUMBER DEFAULT 0;
          X_net_ss_reqmt	NUMBER DEFAULT 0;
          X_ending_bal		NUMBER DEFAULT 0;
          X_prev_balance	NUMBER DEFAULT 0;
        /* B1159495 Inventory Transfers  */
          X_plnd_transfer_out   NUMBER DEFAULT 0;
          X_plnd_transfer_in    NUMBER DEFAULT 0;
        /* B1781498 */
          X_sched_transfer_out   NUMBER DEFAULT 0;
          X_sched_transfer_in    NUMBER DEFAULT 0;
          X_planned_purch	 NUMBER DEFAULT 0;
          X_preq_supply  	 NUMBER DEFAULT 0;
          X_prcv_supply  	 NUMBER DEFAULT 0;
          X_shmt_supply  	 NUMBER DEFAULT 0;
          X_other_demand	NUMBER DEFAULT 0;
          period_name            VARCHAR2(40); /*B3021669 -  Sowmya */

          trans_rec			Cur_trans_dtl%ROWTYPE;
        BEGIN
          OPEN Cur_trans_dtl;
          LOOP
            FETCH Cur_trans_dtl INTO trans_rec;
            EXIT WHEN Cur_trans_dtl%NOTFOUND;
            X_rows := X_rows + 1;
            doc_type_tab(X_rows)   := trans_rec.doc_type;
            trans_date_tab(X_rows) := trans_rec.trans_date;
            orgn_code_tab(X_rows)  := trans_rec.orgn_code;
            trans_qty_tab(X_rows)  := trans_rec.trans_qty;
          END LOOP;
          CLOSE Cur_trans_dtl;

          -- TKW B3034938 The changes made in bugs 2348778 and 2626977 were commented
          -- since the date returned was null.  The min date was set as a constant
          -- date in gma_global_grp.
          /*
          --BEGIN BUG#2348778 RajaSekhar
          X_workdate1 := FND_DATE.string_to_date(GMA_CORE_PKG.get_date_constant('SY$MIN_DATE'), 'YYYY/MM/DD HH24:MI:SS');
        -- Bug #2626977 (JKB) Removed reference to date profile above.
          --END BUG#2348778
          */

          X_workdate1 := GMA_GLOBAL_GRP.SY$MIN_DATE;

          X_workdate2 := TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
          FND_MESSAGE.SET_NAME('GMP','PS_PASTDUE');
          X_period := FND_MESSAGE.GET;
          IF (X_rows = 0) THEN
            RETURN(X_rows);
          END IF;

          OPEN Cur_schedule;
          FETCH Cur_schedule INTO X_no_days, X_no_weeks, X_no_4weeks, X_no_13weeks;
          CLOSE Cur_schedule;
          X_date1       := SYSDATE;
          X_date2       := X_date1 - 1;
          X_date1       := X_date2 + X_no_days;
          X_day1        := INITCAP(TO_CHAR(X_date1,'DAY')); /* Day */
          X_n	        := TO_CHAR(X_date1,'D');   /* Whay Day of a week */
          X_no_days     := X_no_days + 7 - X_n + 1;
          X_tot_periods := X_no_days + X_no_weeks + X_no_4weeks + X_no_13weeks;
          period_start_date_tab(1) := X_workdate1;
          period_end_date_tab(1)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');    /* yesterday  */
          FND_MESSAGE.SET_NAME('GMP','PS_PASTDUE');
          period_name_tab(1) := FND_MESSAGE.GET;

          -- TKW 12/26/2003 B3337215 - Port B3306526 to 11.5.10L.
          -- Modified following condition for the case X_no_days = 1 to work
          IF (X_no_days > 1) THEN
          -- IF (X_no_days <> 0) THEN
            FOR X_i IN 2..X_no_days
            LOOP
              X_j                        := X_i - 1;
              X_dcount                   := X_i + 1;
              X_date1                    := period_end_date_tab(X_j);
              period_start_date_tab(X_i) := X_date1;
              X_date2                    := period_start_date_tab(X_i) + 1;
              period_end_date_tab(X_i)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
              /*period_name_tab(X_i)       := INITCAP(TO_CHAR(X_date2,'DAY'));*/

              /*B3732658 - Added a new parameter 'NLS_DATE_LANGUAGE=ENGLISH' to the period name below, so that whatever might be the
              language to which the database is set to the period name is fetched in ENGLISH. This period name is used further for
              fetching the days from the message dictionary*/
              period_name                := trim(UPPER(TO_CHAR(X_date2,'DAY','NLS_DATE_LANGUAGE=ENGLISH'))); /*B3732658*/

              /*B3021669 - Sowmya - GMP:GMP:DAYS OF THE WEEK UNTRANSLATED IN MPS MATERIAL ACTIVITY INQUIRY*/
              /* Based on the period name the day will be picked from the message dictionary.
              This change has been done to facilitate the translation of messages*/
              IF ( period_name = 'SUNDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_SUNDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'MONDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_MONDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'TUESDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_TUESDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'WEDNESDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_WEDNESDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'THURSDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_THURSDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'FRIDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_FRIDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'SATURDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_SATURDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              END IF;

            END LOOP;
          ELSE
            X_dcount := 2;
          END IF;
          IF (X_no_weeks <> 0) THEN
            FOR X_i IN X_dcount..(X_no_days + X_no_weeks)
            LOOP
              X_j                        := X_i - 1;
              X_wcount                   := X_i + 1;
              X_date1                    := period_end_date_tab(X_j);
              period_start_date_tab(X_i) := X_date1;
              X_date2                    := period_start_date_tab(X_i) + 7;
              period_end_date_tab(X_i)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
              FND_MESSAGE.SET_NAME('GMP','PS_WEEK');
              period_name_tab(X_i) := FND_MESSAGE.GET||' '||TO_CHAR(X_date2,'WW');
            END LOOP;
          ELSE
            IF (X_no_days = 0) THEN
              X_wcount := 2;
            ELSE
              X_wcount := X_dcount;
            END IF;
          END IF;

          IF (X_no_4weeks <> 0) THEN
            FOR X_i IN X_wcount..(X_no_days + X_no_weeks + X_no_4weeks)
            LOOP
              X_j                        := X_i - 1;
              X_mcount                   := X_i + 1;
              X_date1                    := period_end_date_tab(X_j);
              period_start_date_tab(X_i) := X_date1;
              X_date2                    := period_start_date_tab(X_i) + 28;
              period_end_date_tab(X_i)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
              FND_MESSAGE.SET_NAME('GMP','PS_WEEK');
              period_name_tab(X_i) := FND_MESSAGE.GET||' '||LPAD(TO_CHAR(TO_NUMBER(TO_CHAR(X_date1,'WW'))+1),2,'0')||'-'||TO_CHAR(X_date2,'WW');
            END LOOP;
          ELSE
            IF (X_no_days = 0 AND X_no_weeks = 0) THEN
              X_mcount := 2;
            ELSIF (X_no_weeks = 0) THEN
              X_mcount := X_dcount;
            ELSE
              X_mcount := X_wcount;
            END IF;
          END IF;

          IF (X_no_13weeks <> 0) THEN
            FOR X_i IN X_mcount..(X_no_days + X_no_weeks + X_no_4weeks + X_no_13weeks)
            LOOP
              X_j                        := X_i - 1;
              X_qcount                   := X_i + 1;
              X_date1                    := period_end_date_tab(X_j);
              period_start_date_tab(X_i) := X_date1;
              X_date2                    := period_start_date_tab(X_i) + 91;
              period_end_date_tab(X_i)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
              FND_MESSAGE.SET_NAME('GMP','PS_WEEK');
              period_name_tab(X_i) := FND_MESSAGE.GET||' '||LPAD(TO_CHAR(TO_NUMBER(TO_CHAR(X_date1,'WW'))+1),2,'0')||'-'||TO_CHAR(X_date2,'WW');
            END LOOP;
          END IF;

          OPEN Cur_check_hdr;
          FETCH Cur_check_hdr INTO X_matl_rep_id;
          IF (Cur_check_hdr%NOTFOUND) THEN
            OPEN Cur_matl_rep_id;
            FETCH Cur_matl_rep_id INTO X_matl_rep_id;
            CLOSE Cur_matl_rep_id;
            INSERT INTO ps_matl_hdr (matl_rep_id, item_id)
            VALUES      (X_matl_rep_id, V_item_id);
          ELSE
            X_matl_rep_id := V_matl_rep_id;
          END IF;
          CLOSE Cur_check_hdr;

          IF (V_matl_rep_id IS NOT NULL) THEN
            DELETE
            FROM  ps_matl_dtl
            WHERE matl_rep_id = V_matl_rep_id
                  AND item_id = V_item_id;
          END IF;

          IF (INSTR(V_whse_list,',') <> 0) THEN
            X_whse_code := FND_PROFILE.VALUE('SY$ALL');
          ELSE
            X_whse_code := REPLACE(V_whse_list, '''', '');
          END IF;

          prior_to_one := 1 ;
          FOR X_j IN 1..X_tot_periods
          LOOP
            X_sales_orders   := 0;
            X_forecast       := 0;
            X_dep_demand     := 0;
            X_plnd_ingred    := 0;
            X_total_demand   := 0;
            X_total_supply   := 0;
            X_po_receipts    := 0;
            X_sched_prod     := 0;
            X_plnd_prod      := 0;
            X_planned_purch  := 0;
            X_ending_bal     := 0;
            X_net_ss_reqmt   := 0;
            /* B1159495 Inventory Transfers  */
            X_plnd_transfer_out   := 0;
            X_plnd_transfer_in    := 0;
            /* B1781498 */
            X_sched_transfer_out   := 0;
            X_sched_transfer_in    := 0;
            X_planned_purch	 := 0;
            X_preq_supply  	 := 0;
            X_prcv_supply  	 := 0;
            X_shmt_supply  	 := 0;
            X_other_demand  	 := 0;


        --    FOR X_i IN 1..X_rows   /* transaction table */
            FOR X_i IN prior_to_one..X_rows   /* transaction table */
            LOOP
            /* 22-Jan-04 Namit Singhi B3340572.  Removed equality condition for period start date as
                Sales Orders appeared twice in MPS Bucketed Material Inquiry Screen*/
               IF (trans_date_tab(X_i) > period_start_date_tab(X_j)) AND (trans_date_tab(X_i) <= period_end_date_tab(X_j)) THEN
                  /* RDP 08/24/2000 Bug 1371700 addition of OMSO */
                IF (doc_type_tab(X_i) = 'OPSO' OR  doc_type_tab(X_i) = 'OMSO') THEN
                  X_sales_orders := X_sales_orders + trans_qty_tab(X_i);
                ELSIF (doc_type_tab(X_i) = 'FCST') THEN
                  X_forecast := X_forecast + trans_qty_tab(X_i);
                ELSIF (doc_type_tab(X_i) = 'PROD' OR doc_type_tab(X_i) = 'FPO') THEN
                  IF (trans_qty_tab(X_i) < 0) THEN
                    X_dep_demand := X_dep_demand + trans_qty_tab(X_i);
                  ELSE
                    X_sched_prod := X_sched_prod + trans_qty_tab(X_i);
                  END IF;
                ELSIF (doc_type_tab(X_i) = 'PPRD') THEN
                  IF (trans_qty_tab(X_i) < 0) THEN
                    X_plnd_ingred := X_plnd_ingred + trans_qty_tab(X_i);
                  ELSE
                    X_plnd_prod := X_plnd_prod + trans_qty_tab(X_i);
                  END IF;
                    /* B1159495 Inventory Transfers  */
                ELSIF (doc_type_tab(X_i) = 'XFER') THEN
                    IF (trans_qty_tab(X_i) < 0) THEN
                      X_sched_transfer_out := X_sched_transfer_out + NVL(trans_qty_tab(X_i),0);
                    ELSE
                      X_sched_transfer_in  := X_sched_transfer_in + NVL(trans_qty_tab(X_i), 0);
                    END IF;
                ELSIF (doc_type_tab(X_i) = 'PTRN') THEN
                    IF (trans_qty_tab(X_i) < 0) THEN
                      X_plnd_transfer_out := X_plnd_transfer_out + NVL(trans_qty_tab(X_i),0);
                    ELSE
                      X_plnd_transfer_in := X_plnd_transfer_in + NVL(trans_qty_tab(X_i), 0);
                    END IF;

                   /* B1553919, RDP */
                   /* 28-Aug-01 RDP B1781498  For PREQ,PROD,PORD,PRCV,SHMT    */
                ELSIF (doc_type_tab(X_i) = 'PORD' OR doc_type_tab(X_i) = 'PBPO') THEN
                  X_po_receipts := X_po_receipts + trans_qty_tab(X_i);
                ELSIF (doc_type_tab(X_i) = 'PRCV' ) THEN
                  X_prcv_supply   := X_prcv_supply   + trans_qty_tab(X_i);
                ELSIF (doc_type_tab(X_i) = 'SHMT' ) THEN
                  X_shmt_supply   := X_shmt_supply   + trans_qty_tab(X_i);
                ELSIF (doc_type_tab(X_i) = 'PREQ') THEN
                  X_preq_supply   := X_preq_supply   + trans_qty_tab(X_i);
                ELSIF (doc_type_tab(X_i) = 'PPUR' OR doc_type_tab(X_i) = 'PBPR') THEN
                  X_planned_purch := X_planned_purch + trans_qty_tab(X_i);
                ELSIF (doc_type_tab(X_i) = 'LEXP') THEN
                  X_other_demand := X_other_demand + trans_qty_tab(X_i);
                END IF;
              END IF;
                       prior_to_one := X_i ;
                       EXIT WHEN trans_date_tab(X_i) > period_end_date_tab(X_j) ;
         /* if trans_date > period_end_date then break ; */
            END LOOP;
            X_sales_orders    := ROUND((-1) * X_sales_orders,9);
            X_forecast        := ROUND((-1) * X_forecast,9);
            X_dep_demand      := ROUND((-1) * X_dep_demand,9);
            X_plnd_ingred     := ROUND((-1) * X_plnd_ingred,9);
            X_other_demand    := ROUND((-1) * X_other_demand,9);

            X_po_receipts     := ROUND(X_po_receipts,9);
            X_preq_supply     := ROUND(X_preq_supply,9);
            X_prcv_supply     := ROUND(X_prcv_supply,9);
            X_shmt_supply     := ROUND(X_shmt_supply,9);
            X_sched_prod      := ROUND(X_sched_prod,9);
            X_planned_purch   := ROUND(X_planned_purch,9);
            X_plnd_prod       := ROUND(X_plnd_prod,9);

           /* B1159495 Inventory Transfers  */
            X_sched_transfer_in   := ROUND(X_sched_transfer_in,9);
            X_sched_transfer_out  := ROUND((-1) * X_sched_transfer_out,9);

           /* B1159495 Inventory Transfers  */
            X_plnd_transfer_in   := ROUND(X_plnd_transfer_in,9);
            X_plnd_transfer_out  := ROUND((-1) * X_plnd_transfer_out,9);

            X_total_demand    := ROUND(X_sales_orders + X_dep_demand + X_plnd_ingred
                              + X_forecast + X_sched_transfer_out + X_plnd_transfer_out
                                +X_other_demand,9);

            X_total_supply    := ROUND(X_po_receipts + X_preq_supply
                              + X_prcv_supply + X_shmt_supply
                              + X_sched_prod + X_planned_purch + X_plnd_prod
                              + X_sched_transfer_in + X_plnd_transfer_in,9);

            IF (X_j = 1) THEN
              X_ending_bal := ROUND(V_on_hand - X_total_demand + X_total_supply,9);
            ELSE
              X_ending_bal := ROUND(X_prev_balance - X_total_demand + X_total_supply,9);
            END IF;
            IF (X_ending_bal <= NVL(V_total_ss,0)) THEN
              X_net_ss_reqmt := ROUND(NVL(V_total_ss,0) - X_ending_bal,9);
            END IF;
            X_prev_balance := X_ending_bal;

            INSERT INTO ps_matl_dtl
            (MATL_REP_ID,
            ITEM_ID,
            WHSE_CODE,
            QTY_ON_HAND,
            PERD_NAME,
            PERD_END_DATE,
            SALES_ORDERS,
            FORE_CAST,
            PLND_INGRED,
            OTHER_DEMAND,
            TOTAL_DEMAND,
            PO_RECEIPTS,
            PREQ_SUPPLY,
            PRCV_SUPPLY,
            SHMT_SUPPLY,
            SCHED_PROD,
            SCHED_INGRED,
            PLND_PURCHASE,
            PLND_PROD,
            ENDING_BAL,
            NET_SS_REQMT,
            SCHED_TRANSFER_OUT,
            SCHED_TRANSFER_IN,
            PLND_TRANSFER_OUT,
            PLND_TRANSFER_IN)
            VALUES
            (X_matl_rep_id,
            V_item_id,
            X_whse_code,
            V_on_hand,
            period_name_tab(X_j),
            period_end_date_tab(X_j),
            X_sales_orders,
            X_forecast,
            X_plnd_ingred,
            X_other_demand,
            X_total_demand,
            X_po_receipts,
            X_preq_supply  ,
            X_prcv_supply  ,
            X_shmt_supply  ,
            X_sched_prod,
            X_dep_demand,
            X_planned_purch,
            X_plnd_prod,
            X_ending_bal,
            X_net_ss_reqmt,
            X_sched_transfer_out,
            X_sched_transfer_in,
            X_plnd_transfer_out,
            X_plnd_transfer_in);

          END LOOP;
          RETURN(X_matl_rep_id);

        END MR_BUCKET_DATA;

        /* =========== PS_BUCKET_DATA ==================== */

         FUNCTION ps_bucket_data (V_schedule NUMBER,
                                    V_item_id NUMBER,
                                    V_org_list VARCHAR2, -- akaruppa previously V_whse_list VARCHAR2
--                                    V_fcst_list VARCHAR2,
                                    V_on_hand NUMBER,
                                    V_total_ss NUMBER,
                                    V_uom VARCHAR2,
--                                    V_um_ind NUMBER,
                                    V_matl_rep_id NUMBER) RETURN NUMBER IS
          TYPE trans_date_type IS TABLE OF ic_tran_pnd.trans_date%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE document_type IS TABLE OF sy_docs_mst.doc_type%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE trans_qty_type IS TABLE OF ic_tran_pnd.trans_qty%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE trans_qty2_type IS TABLE OF ic_tran_pnd.trans_qty2%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE whse_code_type IS TABLE OF ic_whse_mst.whse_code%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE organization_id_type IS TABLE OF hr_organization_units.organization_id%TYPE -- akaruppa added **
               INDEX BY BINARY_INTEGER;
	  TYPE period_start_date_type IS TABLE OF ps_matl_dtl.perd_end_date%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE period_end_date_type IS TABLE OF ps_matl_dtl.perd_end_date%TYPE
               INDEX BY BINARY_INTEGER;
          TYPE period_name_type IS TABLE OF ps_matl_dtl.perd_name%TYPE
               INDEX BY BINARY_INTEGER;
          trans_date_tab	      TRANS_DATE_TYPE;
          doc_type_tab          DOCUMENT_TYPE;
          trans_qty_tab         TRANS_QTY_TYPE;
          trans_qty2_tab        TRANS_QTY2_TYPE;
          whse_code_tab         WHSE_CODE_TYPE;
          organization_id_tab   ORGANIZATION_ID_TYPE; -- akaruppa added **
          period_start_date_tab PERIOD_START_DATE_TYPE;
          period_end_date_tab   PERIOD_END_DATE_TYPE;
          period_name_tab       PERIOD_NAME_TYPE;
          period_name            VARCHAR2(40);   /*B3021669 -  Sowmya */

           /* 29-Jan-04 - B3394924 - Sowmya - Record definition for the transaction information */
           TYPE trans_typ IS RECORD(
                trans_date		DATE,
                doc_type		VARCHAR2(4),
                trans_qty		NUMBER,
--                trans_qty2		NUMBER,
                whse_code		VARCHAR2(4)
                );

          trans_rec   trans_typ;

          /* 29-Jan-04 - B3394924 - Sowmya - The cursor for fetching the details of all the document types has been made dynamic*/
          TYPE gmp_fet_cursor_typ IS REF CURSOR;
          Cur_trans_dtl  gmp_fet_cursor_typ;

          /* 29-Jan-04 - B3394924 - Sowmya - SALES ORDERS BEING SEEN ON MPS INQUIRY SCREEN EVEN WHEN EXCLUDED IN SCHEDULE */
          CURSOR Get_ord_ind_cur IS
            SELECT order_ind
            FROM ps_schd_hdr
            WHERE schedule_id = V_schedule;
/*  akaruppa changed the cursor to obtain the UOM from MTL_SYSTEM_ITEMS
	  CURSOR Cur_item_um IS
            SELECT item_um, item_um2
            FROM   ic_item_mst
            WHERE  item_id = V_item_id; */

	  CURSOR Cur_item_um IS
	    SELECT DISTINCT primary_uom_code,secondary_uom_code
	      FROM mtl_system_items
	     WHERE inventory_item_id = V_item_id;

          CURSOR Cur_schedule IS
            SELECT no_days, no_weeks, no_4weeks, no_13weeks
            FROM   ps_schd_hdr
            WHERE  schedule_id = V_schedule
                   AND delete_mark = 0;
          CURSOR Cur_check_hdr IS
            SELECT matl_rep_id
            FROM   ps_matl_hdr
            WHERE  matl_rep_id = V_matl_rep_id;
          CURSOR Cur_matl_rep_id IS
            SELECT gem5_matl_rep_id_s.NEXTVAL
            FROM   dual;
          X_rows	      	NUMBER DEFAULT 0;
          X_trans_date    	DATE;
          X_qty	      		NUMBER DEFAULT 0;
          X_qty2	      	NUMBER DEFAULT 0;
--          X_whse_code     	VARCHAR2(10);
          X_organization_id     NUMBER;
          X_item_uom	      	VARCHAR2(3); -- akaruppa previously X_item_um
          X_item_uom2      	VARCHAR2(3); -- akaruppa previously X_item_um2
          X_trans_qty2    	NUMBER;
          X_retvar	      	NUMBER(5);
          X_workdate1     	DATE;
          X_workdate2     	DATE;
          X_period	      	VARCHAR2(40);
          X_no_days       	NUMBER(5);
          X_no_weeks      	NUMBER(5);
          X_no_4weeks     	NUMBER(5);
          X_no_13weeks    	NUMBER(5);
          X_date1	      	DATE;
          X_date2	      	DATE;
          X_day1	      	VARCHAR2(30);
          X_n	            	NUMBER(5);
          X_i	            	NUMBER(5);
          X_j	            	NUMBER(5);
          X_k	            	NUMBER(5);
          X_l	            	NUMBER(5);
          X_m			NUMBER(5);
          X_dcount        	NUMBER;
          X_wcount        	NUMBER;
          X_mcount        	NUMBER;
          X_qcount        	NUMBER;
          X_matl_rep_id   	NUMBER;
          X_tot_periods   	NUMBER(5);
          X_sales_orders	NUMBER DEFAULT 0;
          X_forecast		NUMBER DEFAULT 0;
          X_sched_ingred	NUMBER DEFAULT 0;
          X_firm_ingred		NUMBER DEFAULT 0;
          X_po_receipts		NUMBER DEFAULT 0;
          X_sched_prod		NUMBER DEFAULT 0;
          X_firm_prod		NUMBER DEFAULT 0;
          X_total_demand	NUMBER DEFAULT 0;
          X_total_supply	NUMBER DEFAULT 0;
          X_net_ss_reqmt	NUMBER DEFAULT 0;
          X_ending_bal		NUMBER DEFAULT 0;
          X_prev_balance	NUMBER DEFAULT 0;
        /* B1159495 Inventory Transfers  */
          X_plnd_transfer_out   NUMBER DEFAULT 0;
          X_plnd_transfer_in    NUMBER DEFAULT 0;
        /* B1781498 */
--          X_sched_transfer_out   NUMBER DEFAULT 0;
--          X_sched_transfer_in    NUMBER DEFAULT 0;
          X_planned_purch	 NUMBER DEFAULT 0;
          X_preq_supply  	 NUMBER DEFAULT 0;
          X_prcv_supply  	 NUMBER DEFAULT 0;
          X_shmt_supply  	 NUMBER DEFAULT 0;
          l_order_ind            NUMBER := 1 ;/* B3394924 sowmya */
          x_select               VARCHAR2(32600);/* B3394924 sowmya */

        BEGIN
           -- Retrive the order_ind   /* B3394924 sowmya */
           OPEN Get_ord_ind_cur ;
           FETCH Get_ord_ind_cur INTO l_order_ind ;
           CLOSE Get_ord_ind_cur;

           /*B3394924 - sowmya - The cursor for fetching the document type made dynamic */
           /*   28-Aug-01    Rajesh Patangya  B1781498  For PREQ,PORD,PRCV,SHMT    */
-- akaruppa changed query to fetch data from gme_material_details for production data
	   x_select := 	' SELECT  gmd.material_requirement_date trans_date, '||
			'	  DECODE(gbh.batch_type, 10,''FPO'',''PROD'') doc_type, '||
			'	  DECODE(gmd.line_type, -1,-1,1) * DECODE(gmd.dtl_um, '||
			'            :p1, '||
			'            NVL((NVL(gmd.wip_plan_qty, gmd.plan_qty) - gmd.actual_qty), 0), '||
			'            inv_convert.inv_um_convert(gmd.inventory_item_id, '||
			'            NULL, '||
			'            gmd.organization_id, '||
			'            NULL, '||
			'            NVL((NVL(gmd.wip_plan_qty, gmd.plan_qty) - gmd.actual_qty), 0), '||
			'            gmd.dtl_um, '||
			'            :p2, '||
			'            NULL, '||
			'            NULL '||
			'            ) '||
			'         ) trans_qty, '||
/*			'	  DECODE(msi.dual_uom_control,0,0, '||
			'	     DECODE(gmd.line_type, -1,-1,1) *  DECODE(gmd.dtl_um, '||
			'            msi.secondary_uom_code, '||
			'            (gmd.wip_plan_qty - gmd.actual_qty), '||
			'            inv_convert.inv_um_convert(gmd.inventory_item_id, '||
			'               NULL, '||
			'               gmd.organization_id, '||
			'               38, '||
			'               (gmd.wip_plan_qty-gmd.actual_qty), '||
			'               gmd.dtl_um, '||
			'               msi.secondary_uom_code, '||
			'               NULL, '||
			'               NULL '||
			'               ) '||
			'         ) '||
			'         ) trans_qty2, '||
*/
			'	  mp.organization_code '||
			' FROM '||
			'	gme_batch_header gbh, '||
			'	gme_material_details gmd, '||
			'	mtl_parameters mp, '||
			'	mtl_system_items msi '||
			' WHERE '||
			'	Gbh.batch_id = gmd.batch_id '||
			'	AND msi.inventory_item_id = gmd.inventory_item_id '||
			'	AND msi.organization_id = gmd.organization_id '||
			'	AND gmd.organization_id = mp.organization_id '||
			'	AND mp.process_enabled_flag =  '|| '''Y''' ||
			'	AND gbh.batch_status IN (1,2) '||
			'	AND gmd.actual_qty < NVL(gmd.wip_plan_qty, gmd.plan_qty) '||
	                '	AND msi.inventory_item_id = :p3 '||
		        '	AND INSTR(:p4, TO_CHAR(gbh.organization_id)) <> 0' ;

           IF l_order_ind = 1 THEN  /* B3394924 - Fetch sales order data only when included in the schedule*/
                x_select := x_select ||' UNION ALL ' ||
			' SELECT '||
                        ' mtl.requirement_date, '||
                        ' '''||'OMSO'||''''||', '||
--                        ' mtl.primary_uom_quantity * (-1) , '||
			' DECODE(items.primary_uom_code,:p5,mtl.primary_uom_quantity * (-1), '|| -- akaruppa added
			'    (-1) * inv_convert.inv_um_convert(mtl.inventory_item_id, '||
			'       NULL, '||
			'       org.organization_id, '||
			'       NULL, '||
			'       mtl.primary_uom_quantity , '||
			'       items.primary_uom_code, '||
			'       :p6, '||
			'       NULL, '||
			'       NULL '||
			'       ) '||
			'    ) trans_qty, '||
                        ' org.organization_code '|| -- akaruppa previously iwm.whse_code
                ' FROM '||
                        ' mtl_demand_omoe mtl,'||
                        ' mtl_system_items items,'||
                        ' oe_order_headers_all hdr, '||
                        ' oe_order_lines_all dtl, '||
                        ' mtl_parameters org '||
                 ' WHERE '||
                 ' mtl.inventory_item_id = :p7 '|| -- akaruppa previously im.item_id
                 ' AND INSTR(:p8, TO_CHAR(mtl.organization_id)) <> 0'|| -- akaruppa previously iwm.whse_code
                 ' and items.organization_id   = mtl.organization_id '||
                 ' and items.inventory_item_id = mtl.inventory_item_id '||
                 ' and NVL(mtl.completed_quantity,0) = 0 '||
                 ' and mtl.open_flag =  ' || '''Y''' ||
                 ' and mtl.available_to_mrp = 1 '||
                 ' and mtl.parent_demand_id is NULL '||
                 ' and mtl.demand_source_type IN (2,8) '||
                 ' and mtl.demand_id = dtl.line_id '||
                 ' and dtl.header_id = hdr.header_id '||
                 ' and dtl.ship_from_org_id = org.organization_id '||
                 ' and org.process_enabled_flag =  '|| '''Y''' ||
/*		 ' and ((TO_NUMBER(FND_PROFILE.VALUE(''GMP_EXCLUDE_INTERNAL_OMSO'')) = 1 ' ||
		 '	 and nvl(dtl.source_document_type_id, 0) <> 10 ' ||
		 '       ) ' ||
 		 '     or TO_NUMBER(FND_PROFILE.VALUE(''GMP_EXCLUDE_INTERNAL_OMSO'')) = 0 ' ||
		 '     ) ' ||
*/
                 ' and NOT EXISTS '||
                     ' (SELECT 1 '||
                        ' FROM so_lines_all sl, '||
                        ' so_lines_all slp, '||
                        ' mtl_demand_omoe dem '||
                      ' WHERE '||
                   ' slp.line_id(+) = nvl(sl.parent_line_id,sl.line_id) '||
                        ' and to_number(dem.demand_source_line) = sl.line_id(+) '||
                        ' and dem.demand_source_type in (2,8) '||
                        ' and sl.end_item_unit_number IS NULL '||
                        ' and slp.end_item_unit_number IS NULL '||
                        ' and dem.demand_id = mtl.demand_id '||
                 ' and items.effectivity_control = 2) ' ;
         END IF;
         x_select := x_select ||' UNION ALL ' ||
-- akaruppa changed query to obtain forecast data from Oracle Forecast
		' SELECT '||
		' 	dtl.forecast_date,  '||
		' 	'''||'FCST'||''''||',  '||
--		' 	dtl.current_forecast_quantity trans_qty,  '||
		' 	DECODE(msi.primary_uom_code,:p9, (-1) * dtl.current_forecast_quantity,  '||
		' 	   (-1) * inv_convert.inv_um_convert(dtl.inventory_item_id,  '||
		'             NULL,  '||
		'             dtl.organization_id,  '||
		'             NULL,  '||
		'             dtl.current_forecast_quantity,  '||
		'             msi.primary_uom_code,  '||
		'             :p10,  '||
		'             NULL,  '||
		'             NULL  '||
		'             )  '||
		'       ) trans_qty,  '||
		' 	mp.organization_code  '||
		' FROM  '||
		' 	ps_schd_for psf,  '||
		' 	mrp_forecast_designators mff,  '||
		' 	mrp_forecast_dates dtl,  '||
		' 	mtl_system_items msi,  '||
		' 	mtl_parameters mp  '||
		' WHERE dtl.inventory_item_id = :p11  '||
		' 	AND psf.schedule_id = :p12  '||
		'	AND INSTR(:p13, TO_CHAR(psf.organization_id)) <> 0 '||
		' 	AND psf.organization_id = mp.organization_id  '||
		'	AND mp.process_enabled_flag = '|| '''Y''' ||
		' 	AND psf.organization_id = msi.organization_id  '||
		'       AND dtl.inventory_item_id = msi.inventory_item_id  '||
		' 	AND psf.organization_id = mff.organization_id  '||
		' 	AND psf.forecast_designator = mff.forecast_set  '||
		' 	AND mff.forecast_designator = dtl.forecast_designator  '||
		' 	AND mff.organization_id = dtl.organization_id  '||
		' 	AND dtl.forecast_date >= fnd_date.canonical_to_date(fnd_date.date_to_canonical(sysdate)) '||
                ' UNION ALL ' ||
                ' SELECT  po.expected_delivery_date, '||
                        ' '''||'PORD'||''''||', '||
--                        ' po.to_org_primary_quantity, '||
			' DECODE(mitem.primary_uom_code,:p14,po.to_org_primary_quantity, '|| -- akaruppa added
			'    inv_convert.inv_um_convert(mitem.inventory_item_id, '||
			'       NULL, '||
			'       mitem.organization_id, '||
			'       NULL, '||
			'       po.to_org_primary_quantity, '||
			'       mitem.primary_uom_code, '||
		        '       :p15, '||
			'       NULL, '||
			'       NULL '||
			'       ) '||
			'    ) trans_qty, '||
                        ' mtl.organization_code '|| -- akaruppa previously iwm.whse_code
                ' FROM  MTL_PARAMETERS mtl, '||
                        ' PO_PO_SUPPLY_VIEW po, '||
                        ' MTL_SYSTEM_ITEMS mitem '||
                ' WHERE po.item_id = :p16 '|| -- akaruppa previously ic.item_id
                ' AND po.item_id = mitem.inventory_item_id '||
                ' AND po.to_organization_id = mitem.organization_id '||
                    ' AND mtl.organization_id = po.to_organization_id '||
                    ' AND mtl.process_enabled_flag = '|| '''Y''' ||
                    ' AND NOT EXISTS '||
                        ' ( SELECT  1  FROM  oe_drop_ship_sources odss '||
                        ' WHERE po.po_header_id = odss.po_header_id '||
                        ' AND po.po_line_id = odss.po_line_id ) '||
                    ' AND INSTR(:p17, TO_CHAR(po.to_organization_id)) <> 0 '|| -- akaruppa previously iwm.whse_code
                ' UNION ALL ' ||
                ' SELECT  po.expected_delivery_date, '||
                        ' '''||'PREQ'||''''||', '||
--                        ' po.to_org_primary_quantity,'||
			' DECODE(mitem.primary_uom_code,:p18,po.to_org_primary_quantity, '|| -- akaruppa added
			'    inv_convert.inv_um_convert(mitem.inventory_item_id, '||
			'       NULL, '||
			'       mitem.organization_id, '||
			'       NULL, '||
			'       po.to_org_primary_quantity, '||
			'       mitem.primary_uom_code, '||
		        '       :p19, '||
			'       NULL, '||
			'       NULL '||
			'       ) '||
			'    ) trans_qty, '||
                        ' mtl.organization_code '|| -- akaruppa previously iwm.whse_code
                ' FROM  MTL_PARAMETERS mtl,'||
                  ' PO_REQ_SUPPLY_VIEW po,'||
                  ' MTL_SYSTEM_ITEMS mitem '||
                ' WHERE po.item_id = :p20'|| -- akaruppa previously ic.item_id
                ' AND po.item_id = mitem.inventory_item_id '||
                ' AND po.to_organization_id = mitem.organization_id '||
                ' AND mtl.organization_id = po.to_organization_id '||
                ' AND mtl.process_enabled_flag = '|| '''Y''' ||
                ' AND NOT EXISTS '||
                         ' ( SELECT  1  FROM  oe_drop_ship_sources odss '||
                         ' WHERE po.requisition_header_id = odss.requisition_header_id '||
                         ' AND po.req_line_id = odss.requisition_line_id ) '||
                ' AND INSTR(:p21, TO_CHAR(po.to_organization_id)) <> 0 ' ; -- akaruppa previously iwm.whse_code

             x_select := x_select || ' UNION ALL '||
            ' SELECT  po.expected_delivery_date,'||
                    ' '''||'PRCV'||''''||', '||
--                    ' po.to_org_primary_quantity,'||
   		    ' DECODE(mitem.primary_uom_code,:p22,po.to_org_primary_quantity, '|| -- akaruppa added
		    '    inv_convert.inv_um_convert(mitem.inventory_item_id, '||
		    '       NULL, '||
	    	    '       mitem.organization_id, '||
		    '       NULL, '||
		    '       po.to_org_primary_quantity, '||
		    '       mitem.primary_uom_code, '||
		    '       :p23, '||
		    '       NULL, '||
		    '       NULL '||
		    '       ) '||
		    '    ) trans_qty, '||
                    ' mtl.organization_code '|| -- akaruppa previously iwm.whse_code
            ' FROM  MTL_PARAMETERS mtl,'||
                  ' PO_RCV_SUPPLY_VIEW po,'||
                  ' MTL_SYSTEM_ITEMS mitem '||
            ' WHERE po.item_id = :p24'|| -- akaruppa previously ic.item_id
            ' AND po.item_id = mitem.inventory_item_id '||
            ' AND po.to_organization_id = mitem.organization_id '||
            ' AND mtl.organization_id = po.to_organization_id '||
            ' AND mtl.process_enabled_flag = ' || '''Y''' || --||''''||'Y'||''' '||
            ' AND NOT EXISTS '||
                         ' ( SELECT  1  FROM  oe_drop_ship_sources odss '||
                         ' WHERE po.po_header_id = odss.po_header_id '||
                         ' AND po.po_line_id = odss.po_line_id ) '||
            ' AND INSTR(:p25, TO_CHAR(po.to_organization_id)) <> 0' || -- akaruppa previously iwm.whse_code
            ' UNION ALL '||
            ' SELECT  po.expected_delivery_date,'||
                    ' '''||'PRCV'||''''||', '||
--                    ' po.to_org_primary_quantity,'||
   		    ' DECODE(mitem.primary_uom_code,:p26,po.to_org_primary_quantity, '|| -- akaruppa added
		    '    inv_convert.inv_um_convert(mitem.inventory_item_id, '||
		    '       NULL, '||
	    	    '       mitem.organization_id, '||
		    '       NULL, '||
		    '       po.to_org_primary_quantity, '||
		    '       mitem.primary_uom_code, '||
		    '       :p27, '||
		    '       NULL, '||
		    '       NULL '||
		    '       ) '||
		    '    ) trans_qty, '||
                    ' mtl.organization_code '|| -- akaruppa previously iwm.whse_code
            ' FROM  MTL_PARAMETERS mtl,'||
                  ' PO_SHIP_RCV_SUPPLY_VIEW po, '||
                  ' MTL_SYSTEM_ITEMS mitem '||
            ' WHERE po.item_id = :p28'|| -- akaruppa previously ic.item_id
            ' AND po.item_id = mitem.inventory_item_id '||
            ' AND po.to_organization_id = mitem.organization_id '||
            ' AND mtl.organization_id = po.to_organization_id '||
            ' AND mtl.process_enabled_flag = '|| '''Y''' ||
            ' AND INSTR(:p29, TO_CHAR(po.to_organization_id)) <> 0'; -- akaruppa previously iwm.whse_code

             /* BUG#3404056 - Port Bug 3264766 to 11.5.10L
             D. Sailaja  - Added ordered clause and commented the
              existing order of the FROM clause to incorporate the new order */

           x_select := x_select || ' UNION ALL '||
            ' SELECT  '|| /* + ordered */
                    ' po.expected_delivery_date, '||
                    ' '''||'SHMT'||''''||', '||
--                    ' po.to_org_primary_quantity,'||
   		    ' DECODE(mitem.primary_uom_code,:p30,po.to_org_primary_quantity, '|| -- akaruppa added
		    '    inv_convert.inv_um_convert(mitem.inventory_item_id, '||
		    '       NULL, '||
	    	    '       mitem.organization_id, '||
		    '       NULL, '||
		    '       po.to_org_primary_quantity, '||
		    '       mitem.primary_uom_code, '||
		    '       :p31, '||
		    '       NULL, '||
		    '       NULL '||
		    '       ) '||
		    '    ) trans_qty, '||
                    ' mtl.organization_code '|| -- akaruppa previously iwm.whse_code
              ' FROM  MTL_SYSTEM_ITEMS mitem,'||
                  ' PO_SHIP_SUPPLY_VIEW po,'||
                  ' MTL_PARAMETERS mtl '||
            ' WHERE po.item_id = :p32'|| -- akaruppa previously ic.item_id
            ' AND po.item_id = mitem.inventory_item_id '||
            ' AND po.to_organization_id = mitem.organization_id '||
            ' AND mtl.organization_id = po.to_organization_id '||
            ' AND mtl.process_enabled_flag = '|| '''Y''' ||
            ' AND INSTR(:p33, TO_CHAR(mtl.organization_id)) <> 0 ' || -- akaruppa previously iwm.whse_code
            ' ORDER BY 1 asc, 3 desc ';

        /*Open the cursor and pass the item_id , warehouse_id and the forecast list*/

        /* B3394924 - Sowmya - Added to handle the bind variables passed to the cursor when
        sales order are included and excluded from the schedule*/
-- akaruppa changed the bind variables based on the query
       IF l_order_ind = 1 THEN

                OPEN Cur_trans_dtl FOR x_select USING
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id, V_schedule,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list;


        ELSE
                OPEN Cur_trans_dtl FOR x_select USING
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_schedule,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list,
                                V_uom, V_uom, V_item_id,V_org_list;
        END IF;


         LOOP
            FETCH Cur_trans_dtl INTO trans_rec;
            EXIT WHEN Cur_trans_dtl%NOTFOUND;
            X_rows := X_rows + 1;

/* nsinghi MPSCONV Start */
/* Following code was written mainly for forecast transactions that did not have
the secondary UOM qty. Now the secondary qty for all txns are being retrieved in the
query itself. So commented following code. */
/*
            OPEN Cur_item_um;
            FETCH Cur_item_um INTO X_item_uom, X_item_uom2;
            CLOSE Cur_item_um;
            X_trans_qty2 := trans_rec.trans_qty2;
            IF (X_item_uom2 IS NOT NULL) THEN
              IF (NVL(trans_rec.trans_qty2,0) = 0) AND (trans_rec.trans_qty <> 0) THEN
                gmicuom.icuomcv(V_item_id,0,trans_rec.trans_qty,X_item_uom,X_item_uom2,X_trans_qty2); -- akaruppa TO DO Change GMICUOM to Inv_Convert
              END IF;
            END IF;
*/
/* nsinghi MPSCONV End */

            trans_date_tab(X_rows) := trans_rec.trans_date;
            doc_type_tab(X_rows)   := trans_rec.doc_type;
            trans_qty_tab(X_rows)  := NVL(trans_rec.trans_qty,0);
--            trans_qty2_tab(X_rows) := NVL(X_trans_qty2,0);
            whse_code_tab(X_rows)  := trans_rec.whse_code;
          END LOOP;
          CLOSE Cur_trans_dtl;

/* nsinghi MPSCONV Start */
/* Following code was written mainly for forecast consumption.
Now the consumption will be done in Discrete forcasting module.
So commented following code. */
/*

          FOR X_k IN 1..X_rows LOOP
            IF (doc_type_tab(X_k) = 'FCST') THEN
              X_l := X_k + 1;
              FOR X_m IN X_l..X_rows LOOP

                  IF (doc_type_tab(X_m) = 'OPSO' OR
                      doc_type_tab(X_m) = 'OMSO') THEN
                  IF (whse_code_tab(X_m) = whse_code_tab(X_k)) THEN
                        trans_qty_tab(X_k)  := trans_qty_tab(X_k)  - trans_qty_tab(X_m);
                        trans_qty2_tab(X_k) := trans_qty2_tab(X_k) - trans_qty2_tab(X_m);
                    IF (trans_qty_tab(X_k) > 0) THEN
                          trans_qty_tab(X_k) := 0;
                    END IF;
                    IF (trans_qty2_tab(X_k) > 0) THEN
                          trans_qty2_tab(X_k) := 0;
                    END IF;
                  END IF;
                  ELSIF (doc_type_tab(X_m) = 'FCST') THEN
                  EXIT;
                END IF;
              END LOOP;
            END IF;
          END LOOP;
*/
/* nsinghi MPSCONV End */

          -- TKW B3034938 The changes made in bugs 2348778 and 2626977 were commented
          -- since the date returned was null.  The min date was set as a constant
          -- date in gma_global_grp.
          /*
          --BEGIN BUG#2348778 RajaSekhar
          X_workdate1 := FND_DATE.string_to_date(GMA_CORE_PKG.get_date_constant('SY$MIN_DATE'), 'YYYY/MM/DD HH24:MI:SS');
        -- Bug #2626977 (JKB) Removed reference to date profile above.
          --END BUG#2348778
          */

          X_workdate1 := GMA_GLOBAL_GRP.SY$MIN_DATE;

          X_workdate2 := TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
          FND_MESSAGE.SET_NAME('GMP','PS_PASTDUE');
          X_period := FND_MESSAGE.GET;
          IF (X_rows = 0) THEN
            RETURN(X_rows);
          END IF;

          OPEN Cur_schedule;
          FETCH Cur_schedule INTO X_no_days, X_no_weeks, X_no_4weeks, X_no_13weeks;
          CLOSE Cur_schedule;

          X_date1       := SYSDATE;
          X_date2       := X_date1 - 1;
          X_date1       := X_date2 + X_no_days;
          X_day1        := INITCAP(TO_CHAR(X_date1,'DAY'));
          X_n	          := TO_CHAR(X_date1,'D');
          X_no_days     := X_no_days + 7 - X_n + 1;
          X_tot_periods := X_no_days + X_no_weeks + X_no_4weeks + X_no_13weeks;
          period_start_date_tab(1) := X_workdate1;
          period_end_date_tab(1)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
          FND_MESSAGE.SET_NAME('GMP','PS_PASTDUE');
          period_name_tab(1) := FND_MESSAGE.GET;

          -- TKW 12/26/2003 B3337215 - Port B3306526 to 11.5.10L.
          -- Modified following condition for the case X_no_days = 1 to work
          IF (X_no_days > 1) THEN
          -- IF (X_no_days <> 0) THEN
            FOR X_i IN 2..X_no_days
            LOOP
              X_j                        := X_i - 1;
              X_dcount                   := X_i + 1;
              X_date1                    := period_end_date_tab(X_j);
              period_start_date_tab(X_i) := X_date1;
              X_date2                    := period_start_date_tab(X_i) + 1;
              period_end_date_tab(X_i)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
              /*period_name_tab(X_i)       := INITCAP(TO_CHAR(X_date2,'DAY'));*/

              /*B3732658 - Added a new parameter 'NLS_DATE_LANGUAGE=ENGLISH' to the period name below, so that whatever might be the
                language to which the database is set to the period name is fetched in ENGLISH. This period name is used further for
                fetching the days from the message dictionary*/
              period_name                := trim(UPPER(TO_CHAR(X_date2,'DAY','NLS_DATE_LANGUAGE=ENGLISH'))); /*B3732658*/

              /*B3021669 - Sowmya - GMP:GMP:DAYS OF THE WEEK UNTRANSLATED IN MPS MATERIAL ACTIVITY INQUIRY*/
              /* Based on the period name the day will be picked from the message dictionary.
              This change has been done to facilitate the translation of messages*/

              IF ( period_name = 'SUNDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_SUNDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'MONDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_MONDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'TUESDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_TUESDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'WEDNESDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_WEDNESDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'THURSDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_THURSDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'FRIDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_FRIDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              ELSIF ( period_name = 'SATURDAY') THEN
                FND_MESSAGE.SET_NAME('GMP','PS_SATURDAY');
                period_name_tab(X_i) := FND_MESSAGE.GET;
              END IF;

            END LOOP;
          ELSE
            X_dcount := 2;
          END IF;
          IF (X_no_weeks <> 0) THEN
            FOR X_i IN X_dcount..(X_no_days + X_no_weeks)
            LOOP
              X_j                        := X_i - 1;
              X_wcount                   := X_i + 1;
              X_date1                    := period_end_date_tab(X_j);
              period_start_date_tab(X_i) := X_date1;
              X_date2                    := period_start_date_tab(X_i) + 7;
              period_end_date_tab(X_i)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
              FND_MESSAGE.SET_NAME('GMP','PS_WEEK');
              period_name_tab(X_i) := FND_MESSAGE.GET||' '||TO_CHAR(X_date2,'WW');
            END LOOP;
          ELSE
            IF (X_no_days = 0) THEN
              X_wcount := 2;
            ELSE
              X_wcount := X_dcount;
            END IF;
          END IF;

          IF (X_no_4weeks <> 0) THEN
            FOR X_i IN X_wcount..(X_no_days + X_no_weeks + X_no_4weeks)
            LOOP
              X_j                        := X_i - 1;
              X_mcount                   := X_i + 1;
              X_date1                    := period_end_date_tab(X_j);
              period_start_date_tab(X_i) := X_date1;
              X_date2                    := period_start_date_tab(X_i) + 28;
              period_end_date_tab(X_i)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
              FND_MESSAGE.SET_NAME('GMP','PS_WEEK');
              period_name_tab(X_i) := FND_MESSAGE.GET||' '||LPAD(TO_CHAR(TO_NUMBER(TO_CHAR(X_date1,'WW'))+1),2,'0')||'-'||TO_CHAR(X_date2,'WW');
            END LOOP;
          ELSE
            IF (X_no_days = 0 AND X_no_weeks = 0) THEN
              X_mcount := 2;
            ELSIF (X_no_weeks = 0) THEN
              X_mcount := X_dcount;
            ELSE
              X_mcount := X_wcount;
            END IF;
          END IF;

          IF (X_no_13weeks <> 0) THEN
            FOR X_i IN X_mcount..(X_no_days + X_no_weeks + X_no_4weeks + X_no_13weeks)
            LOOP
              X_j                        := X_i - 1;
              X_qcount                   := X_i + 1;
              X_date1                    := period_end_date_tab(X_j);
              period_start_date_tab(X_i) := X_date1;
              X_date2                    := period_start_date_tab(X_i) + 91;
              period_end_date_tab(X_i)   := TO_DATE(TO_CHAR(X_date2,'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');
              FND_MESSAGE.SET_NAME('GMP','PS_WEEK');
              period_name_tab(X_i) := FND_MESSAGE.GET||' '||LPAD(TO_CHAR(TO_NUMBER(TO_CHAR(X_date1,'WW'))+1),2,'0')||'-'||TO_CHAR(X_date2,'WW');
            END LOOP;
          END IF;

          OPEN Cur_check_hdr;
          FETCH Cur_check_hdr INTO X_matl_rep_id;
          IF (Cur_check_hdr%NOTFOUND) THEN
            OPEN Cur_matl_rep_id;
            FETCH Cur_matl_rep_id INTO X_matl_rep_id;
            CLOSE Cur_matl_rep_id;

/* nsinghi MPSCONV Start */
/* ToDo : Need to ensure if we need to insert organization_id too?
V_matl_rep_id will be null when call to this procedure is made from
Bucketed Material Form and NOT Report. I think this part of code
will require to be removed. */
/* nsinghi MPSCONV End */
/*
            INSERT INTO ps_matl_hdr (matl_rep_id, inventory_item_id)
            VALUES      (X_matl_rep_id, V_item_id);
*/
          ELSE
            X_matl_rep_id := V_matl_rep_id;
          END IF;
          CLOSE Cur_check_hdr;

          IF (V_matl_rep_id IS NOT NULL) THEN
            DELETE
            FROM  ps_matl_dtl
            WHERE matl_rep_id = V_matl_rep_id
                  AND item_id = V_item_id;
          END IF;
          IF (INSTR(V_org_list,',') <> 0) THEN
--            X_whse_code := FND_PROFILE.VALUE('SY$ALL');
            X_organization_id := NULL;
          ELSE /* For reports the V_org_list will be single org */
            X_organization_id := TO_NUMBER(V_org_list);
--            X_whse_code := REPLACE(V_org_list, '''', '');
          END IF;
          FOR X_j IN 1..X_tot_periods
          LOOP
            X_sales_orders := 0;
            X_forecast     := 0;
            X_sched_ingred := 0;
            X_firm_ingred  := 0;
            X_total_demand := 0;
            X_total_supply := 0;
            X_po_receipts  := 0;
            X_sched_prod   := 0;
            X_firm_prod    := 0;
            X_ending_bal   := 0;
            X_net_ss_reqmt := 0;
            /* B1159495 Inventory Transfers  */
            X_plnd_transfer_out   := 0;
            X_plnd_transfer_in    := 0;
            /* B1781498 */
--            X_sched_transfer_out   := 0;
--            X_sched_transfer_in    := 0;
            X_preq_supply  	 := 0;
            X_prcv_supply  	 := 0;
            X_shmt_supply  	 := 0;

            FOR X_i IN 1..X_rows
            LOOP
            /* 22-Jan-04 Namit Singhi B3340572.  Removed equality condition for period start date as
                Sales Orders appeared twice in MPS Bucketed Material Inquiry Screen*/
              IF (trans_date_tab(X_i) > period_start_date_tab(X_j)) AND (trans_date_tab(X_i) <= period_end_date_tab(X_j)) THEN
--                IF (V_um_ind = 1) THEN
                  /* RDP 08/24/2000 Bug 1371700 addition of OMSO */
                  IF (doc_type_tab(X_i) = 'OPSO' OR doc_type_tab(X_i) = 'SHIP' OR
                      doc_type_tab(X_i) = 'OMSO' ) THEN
                    X_sales_orders := X_sales_orders + NVL(trans_qty_tab(X_i),0);
                  ELSIF (doc_type_tab(X_i) = 'PROD') THEN
                    IF (trans_qty_tab(X_i) < 0) THEN
                      X_sched_ingred := X_sched_ingred + NVL(trans_qty_tab(X_i),0);
                    ELSE
                      X_sched_prod := X_sched_prod + NVL(trans_qty_tab(X_i),0);
                    END IF;
                  ELSIF (doc_type_tab(X_i) = 'FPO') THEN
                    IF (trans_qty_tab(X_i) < 0) THEN
                      X_firm_ingred := X_firm_ingred + NVL(trans_qty_tab(X_i),0);
                    ELSE
                      X_firm_prod := X_firm_prod + NVL(trans_qty_tab(X_i),0);
                    END IF;

                    /* B1159495 Inventory Transfers  */
/* nsinghi MPSCONV Start */
/* ToDo: This code will be commented as we cannot have schedule transfers. */
/*                  ELSIF (doc_type_tab(X_i) = 'XFER') THEN
                    IF (trans_qty_tab(X_i) < 0) THEN
                      X_sched_transfer_out := X_sched_transfer_out + NVL(trans_qty_tab(X_i),0);
                    ELSE
                      X_sched_transfer_in := X_sched_transfer_in + NVL(trans_qty_tab(X_i), 0);
                    END IF;
*/
/* nsinghi MPSCONV Start */

                  ELSIF (doc_type_tab(X_i) = 'PORD') THEN
                    X_po_receipts := X_po_receipts + NVL(trans_qty_tab(X_i),0);
           /*   28-Aug-01    Rajesh Patangya  B1781498  For PREQ,PORD,PRCV,SHMT    */
                  ELSIF (doc_type_tab(X_i) = 'PREQ') THEN
                    X_preq_supply   := X_preq_supply + NVL(trans_qty_tab(X_i),0);
                  ELSIF (doc_type_tab(X_i) = 'PRCV') THEN
                    X_prcv_supply   := X_prcv_supply + NVL(trans_qty_tab(X_i),0);
                  ELSIF (doc_type_tab(X_i) = 'SHMT') THEN
                    X_shmt_supply   := X_shmt_supply + NVL(trans_qty_tab(X_i),0);
                  ELSIF (doc_type_tab(X_i) = 'FCST') THEN
                    X_forecast := X_forecast + NVL(trans_qty_tab(X_i),0);
                  END IF;
--                ELSIF (V_um_ind = 2) THEN
/*                  IF (doc_type_tab(X_i) = 'OPSO' OR doc_type_tab(X_i) = 'SHIP' OR
                      doc_type_tab(X_i) = 'OMSO' ) THEN
                    X_sales_orders := X_sales_orders + NVL(trans_qty2_tab(X_i),0);
                  ELSIF (doc_type_tab(X_i) = 'PROD') THEN
                    IF (trans_qty2_tab(X_i) < 0) THEN
                      X_sched_ingred := X_sched_ingred + NVL(trans_qty2_tab(X_i),0);
                    ELSE
                      X_sched_prod := X_sched_prod + NVL(trans_qty2_tab(X_i),0);
                    END IF;
                  ELSIF (doc_type_tab(X_i) = 'FPO') THEN
                    IF (trans_qty2_tab(X_i) < 0) THEN
                      X_firm_ingred := X_firm_ingred + NVL(trans_qty2_tab(X_i),0);
                    ELSE
                      X_firm_prod := X_firm_prod + NVL(trans_qty2_tab(X_i),0);
                    END IF;
                  ELSIF (doc_type_tab(X_i) = 'PORD') THEN
                    X_po_receipts := X_po_receipts + NVL(trans_qty2_tab(X_i),0);
                  ELSIF (doc_type_tab(X_i) = 'PREQ') THEN
                    X_preq_supply   := X_preq_supply + NVL(trans_qty2_tab(X_i),0);
                  ELSIF (doc_type_tab(X_i) = 'PRCV') THEN
                    X_prcv_supply   := X_prcv_supply + NVL(trans_qty2_tab(X_i),0);
                  ELSIF (doc_type_tab(X_i) = 'SHMT') THEN
                    X_shmt_supply   := X_shmt_supply + NVL(trans_qty2_tab(X_i),0);
                  ELSIF (doc_type_tab(X_i) = 'FCST') THEN
                    X_forecast := X_forecast + NVL(trans_qty2_tab(X_i),0);
                  END IF;
                END IF;
*/
              END IF;
            END LOOP;
            X_sales_orders := ROUND((-1) * X_sales_orders,9);
            X_forecast     := ROUND((-1) * X_forecast,9);
            X_sched_ingred := ROUND((-1) * X_sched_ingred,9);
            X_firm_ingred  := ROUND((-1) * X_firm_ingred,9);

/* nsinghi MPSCONV Start */
/* ToDo: This code will be commented as we cannot have schedule transfers. */
/*            X_sched_transfer_out  := ROUND((-1) * X_sched_transfer_out,9);

            X_total_demand := ROUND(X_sales_orders + X_sched_ingred + X_firm_ingred +
                                    X_forecast+X_sched_transfer_out,9);

            X_total_supply := ROUND(X_po_receipts + X_preq_supply + X_shmt_supply +
                                    X_prcv_supply + X_sched_prod +
                                    X_firm_prod + X_sched_transfer_in,9);
*/
/* nsinghi MPSCONV End */

            X_total_demand := ROUND(X_sales_orders + X_sched_ingred + X_firm_ingred +
                                    X_forecast,9);

            X_total_supply := ROUND(X_po_receipts + X_preq_supply + X_shmt_supply +
                                    X_prcv_supply + X_sched_prod +
                                    X_firm_prod ,9);

            X_po_receipts  := ROUND(X_po_receipts,9);
            X_sched_prod   := ROUND(X_sched_prod,9);
            X_firm_prod    := ROUND(X_firm_prod,9);

            X_preq_supply  := ROUND(X_preq_supply,9);
            X_prcv_supply  := ROUND(X_prcv_supply,9);
            X_shmt_supply  := ROUND(X_shmt_supply,9);

--            X_sched_transfer_in    := ROUND(X_sched_transfer_in,9);

            IF (X_j = 1) THEN
              X_ending_bal := ROUND(V_on_hand - X_total_demand + X_total_supply,9);
            ELSE
              X_ending_bal := ROUND(X_prev_balance - X_total_demand + X_total_supply,9);
            END IF;
            IF (X_ending_bal <= NVL(V_total_ss,0)) THEN
              X_net_ss_reqmt := ROUND(NVL(V_total_ss,0) - X_ending_bal,9);
            END IF;
            X_prev_balance := X_ending_bal;

            INSERT INTO ps_matl_dtl
            (MATL_REP_ID,
/* nsinghi MPSCONV Start */
--            ITEM_ID,
            INVENTORY_ITEM_ID,
--            WHSE_CODE,
            ORGANIZATION_ID,
/* nsinghi MPSCONV End */
            QTY_ON_HAND,
            PERD_NAME,
            PERD_END_DATE,
            SALES_ORDERS,
            FORE_CAST,
            SCHED_INGRED,
            FIRM_INGRED,
            TOTAL_DEMAND,
            PO_RECEIPTS,
            PREQ_SUPPLY,
            PRCV_SUPPLY,
            SHMT_SUPPLY,
            SCHED_PROD,
            FIRM_PROD,
            ENDING_BAL,
            NET_SS_REQMT)
/*            SCHED_TRANSFER_OUT,
            SCHED_TRANSFER_IN ) */
            VALUES
            (X_matl_rep_id,
            V_item_id,
/* nsinghi MPSCONV Start */
--            X_whse_code,
            X_organization_id,
/* nsinghi MPSCONV End */
            V_on_hand,
            period_name_tab(X_j),
            period_end_date_tab(X_j),
            X_sales_orders,
            X_forecast,
            X_sched_ingred,
            X_firm_ingred,
            X_total_demand,
            X_po_receipts,
            X_preq_supply  ,
            X_prcv_supply  ,
            X_shmt_supply  ,
            X_sched_prod,
            X_firm_prod,
            X_ending_bal,
            X_net_ss_reqmt);
/*            X_sched_transfer_out,
            X_sched_transfer_in  ); */

          END LOOP;
          RETURN(X_matl_rep_id);

        END PS_BUCKET_DATA ;

END PKG_GMP_BUCKET_DATA;

/
