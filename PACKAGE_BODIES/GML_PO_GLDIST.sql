--------------------------------------------------------
--  DDL for Package Body GML_PO_GLDIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_GLDIST" AS
/* $Header: GMLDISTB.pls 120.1 2005/08/15 09:25:12 rakulkar noship $ */


v_lang  VARCHAR2(10) := 'ENG';


  /*##########################################################################
  # PROC
  #  poglded2_calc_dist_amount_aqui
  #
  # GLOBAL VARIABLES
  #
  # RETURNS
  #  1 = success
  # -1 = failure
  #
  # DESCRIPTION
  #  calculate amount_trans using indicators in gl_event_plc and po_cost_dtl
  #  before inserting into po_dist_dtl table
  # HISTORY
  #  2/17/99 T.Ricci increment var GML_PO_GLDIST.P_tot_amount_aap_aqui
  #                  when calculating an AAP account (was only doing it for AAC)
  #                  Bug820997
  ##########################################################################*/

  FUNCTION  calc_dist_amount_aqui  RETURN NUMBER AS

    /* Cursor for getting orgn. for a particular whse_code.*/
    CURSOR  Cur_orgn_for_whse IS
      SELECT  orgn_code
         FROM  ic_whse_mst
       WHERE whse_code = GML_PO_GLDIST.P_to_whse;

    /* Cursor for getting std_act_ind, exp_booked_ind and aqui_cost_ind*/
    /* for a particular event code and source_code.*/
    CURSOR Cur_get_ind_set  IS
      SELECT   std_actual_ind , exp_booked_ind  ,
                        acquis_cost_ind
         FROM    gl_evnt_plc e, gl_srce_mst s, gl_evnt_mst m
       WHERE   e.co_code = GML_PO_GLDIST.P_co_code and
                        e.trans_source_type = s.trans_source_type and e.event_type = m.event_type
                        and e.trans_source_type = m.trans_source_type
                        and s.trans_source_code = 'PO' and m.event_code = 'RCPT'
                        and e.delete_mark = 0;

    /* Cursor for getting the cmpnt_cls_id and analysis_code for a specific aqui_cost_id.*/
    CURSOR Cur_po_cost_mst  IS
      SELECT   cmpntcls_id , analysis_code
         FROM   po_cost_mst
       WHERE  aqui_cost_id = GML_PO_GLDIST.P_aqui_cost_id;

    /* Cursor for getting the cost_amount and incl_ind for a particular po_id, line_id and doc_type.*/
    CURSOR  Cur_po_cost_dtl  IS
       SELECT  incl_ind,cost_amount
          FROM  po_cost_dtl
       WHERE  doc_type = GML_PO_GLDIST.P_doc_type and
                        pos_id = GML_PO_GLDIST.P_pos_id and
                        line_id = GML_PO_GLDIST.P_line_id and
                        aqui_cost_id = GML_PO_GLDIST.P_aqui_cost_id;

   X_std_actual_ind              NUMBER;
   X_exp_booked_ind              NUMBER;
   X_aqui_cost_ind               NUMBER;
   X_cost_cmpntcls_id            NUMBER;
   X_cost_analysis_code          VARCHAR2(20);
   X_incl_ind                    NUMBER;
   X_total_cost                  NUMBER;
   workfloat1                    NUMBER;
   X_orgn_code                   VARCHAR2(5);
   X_retvar                      NUMBER DEFAULT 0;
   X_row_count                   NUMBER;
   X_cost_mthd                   VARCHAR2(10);
   X_cost_amount                 NUMBER;
   x_cmpntcls_id                 NUMBER;
   x_analysis_code               VARCHAR2(70);
   x_cost                        NUMBER;
   x_status                      NUMBER;

  BEGIN
    OPEN    Cur_orgn_for_whse;
    FETCH Cur_orgn_for_whse  INTO  X_orgn_code;
    IF Cur_orgn_for_whse%NOTFOUND  THEN
      X_orgn_code  :=   FND_PROFILE.VALUE ('GEMMS_DEFAULT_ORGN');
    END IF;

    /* cmpntcls_id and analysis code comes for each row from the poglded2_process_trans. Hence, commented.*/
    OPEN    Cur_po_cost_mst ;
    FETCH   Cur_po_cost_mst INTO GML_PO_GLDIST.P_cost_cmpntcls_id, GML_PO_GLDIST.P_cost_analysis_code ;
    CLOSE   Cur_po_cost_mst;

    OPEN  Cur_po_cost_dtl;
    FETCH  Cur_po_cost_dtl  INTO  X_incl_ind, X_cost_amount;
    CLOSE Cur_po_cost_dtl;

    IF X_incl_ind = 1 THEN
      X_retvar := gmf_cmcommon.cmcommon_get_cost  ( GML_PO_GLDIST.P_gl_item_id, GML_PO_GLDIST.P_to_whse,
                                                X_orgn_code , GML_PO_GLDIST.P_po_date,
       		 			        X_cost_mthd , GML_PO_GLDIST.P_cost_cmpntcls_id,
                                                GML_PO_GLDIST.P_cost_analysis_code, 3,
                                                X_total_cost, X_row_count );
      IF (x_row_count IS NULL) THEN
        x_row_count := 0;
      END IF;

      IF  X_retvar < 1  THEN
        GML_PO_GLDIST.P_po_cost := 0;
      END IF;
      FOR i IN 1..x_row_count LOOP
        /* This routine below returns the total cost in a loop,as cmcommon_get_cost routine */
        /* returns only the row count.*/
        gmf_cmcommon.get_multiple_cmpts_cost(i,x_cmpntcls_id,x_analysis_code,x_total_cost,3,x_status);
        x_cost := nvl(x_cost,0) + nvl (x_total_cost,0)  ;
      END LOOP;
      IF  X_retvar < 1  THEN
        GML_PO_GLDIST.P_po_cost   := 0 ;
      ELSE
        GML_PO_GLDIST.P_po_cost   :=  X_cost; /* Returned cost for the particular pair.*/
      END IF;
    ELSE
      GML_PO_GLDIST.P_po_cost := X_cost_amount  ;
    END IF;

    GML_PO_GLDIST.P_tmp_po_cost  :=  GML_PO_GLDIST.P_po_cost / GML_PO_GLDIST.P_exchange_rate ;

    OPEN   Cur_get_ind_set;
    FETCH  Cur_get_ind_set  INTO  X_std_actual_ind, X_exp_booked_ind, X_aqui_cost_ind;
    CLOSE  Cur_get_ind_set;

    IF  GML_PO_GLDIST.P_acct_ttl_num = GML_PO_GLDIST.GL$AT_INV  THEN
      IF  X_std_actual_ind = 1  THEN
        GML_PO_GLDIST.P_amount_trans_aqui := X_cost_amount * GML_PO_GLDIST.P_order_qty1;
      ELSE
        GML_PO_GLDIST.P_amount_trans_aqui := GML_PO_GLDIST.P_order_qty1 * GML_PO_GLDIST.P_tmp_po_cost;
      END IF;
      GML_PO_GLDIST.P_tot_amount_inv_aqui := nvl(GML_PO_GLDIST.P_tot_amount_inv_aqui, 0) + nvl (GML_PO_GLDIST.P_amount_trans_aqui,0);
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num = GML_PO_GLDIST.GL$AT_AAP AND  X_aqui_cost_ind = 0  THEN
      GML_PO_GLDIST.P_amount_trans_aqui :=  X_cost_amount * GML_PO_GLDIST.P_order_qty1;
      GML_PO_GLDIST.P_amount_base_aqui  :=   GML_PO_GLDIST.P_amount_trans_aqui * GML_PO_GLDIST.P_exchange_rate;
      GML_PO_GLDIST.P_amount_base_aqui := ROUND (GML_PO_GLDIST.P_amount_base_aqui, GML_PO_GLDIST.P_precision);
      GML_PO_GLDIST.P_amount_trans_aqui := ROUND (GML_PO_GLDIST.P_amount_trans_aqui, GML_PO_GLDIST.P_precision);
      GML_PO_GLDIST.P_tot_amount_aap_aqui := GML_PO_GLDIST.P_amount_trans_aqui;
      RETURN 0;
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num =  GML_PO_GLDIST.GL$AT_AAP  THEN
      GML_PO_GLDIST.P_amount_trans_aqui :=  -(X_cost_amount * (GML_PO_GLDIST.P_order_qty1)) ;
      GML_PO_GLDIST.P_tot_amount_aap_aqui := GML_PO_GLDIST.P_amount_trans_aqui;

    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num = GML_PO_GLDIST.GL$AT_PPV THEN
      IF  X_std_actual_ind =  1  THEN
        GML_PO_GLDIST.P_amount_trans_aqui  := 0;
      ELSE
        GML_PO_GLDIST.P_extended_price     := ROUND (GML_PO_GLDIST.P_extended_price, GML_PO_GLDIST.P_precision);
        GML_PO_GLDIST.P_tmp_amt            := (GML_PO_GLDIST.P_order_qty1 * GML_PO_GLDIST.P_tmp_po_cost);
        GML_PO_GLDIST.P_tmp_amt            := ROUND (GML_PO_GLDIST.P_tmp_amt, GML_PO_GLDIST.P_precision);
        GML_PO_GLDIST.P_amount_trans_aqui  := -(GML_PO_GLDIST.P_tot_amount_inv_aqui +  GML_PO_GLDIST.P_tot_amount_aap_aqui );
      END IF;
      /* B908529 clear for PPV calc with multiple lines */
      P_tot_amount_inv_aqui	:= 0;
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num = GML_PO_GLDIST.GL$AT_EXP THEN
      IF  X_incl_ind = 0 THEN
        /* po_amount_trans already is amount of aquisition on PO*/
        GML_PO_GLDIST.P_amount_trans_aqui := X_cost_amount * GML_PO_GLDIST.P_order_qty1;
      ELSE
        GML_PO_GLDIST.P_amount_trans_aqui  := 0;
      END IF;
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num  = GML_PO_GLDIST.GL$AT_AAC  THEN
      IF  X_aqui_cost_ind = 1 THEN
        GML_PO_GLDIST.P_amount_trans_aqui :=  (X_cost_amount * GML_PO_GLDIST.P_order_qty1) * (-1);
      ELSE
        GML_PO_GLDIST.P_amount_trans_aqui  := 0;
      END IF;
      GML_PO_GLDIST.P_tot_amount_aap_aqui := GML_PO_GLDIST.P_amount_trans_aqui;
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num = GML_PO_GLDIST.GL$AT_ACV  THEN
      IF  X_incl_ind = 1  THEN
        GML_PO_GLDIST.P_tmp_amt  := X_cost_amount * GML_PO_GLDIST.P_order_qty1;
        GML_PO_GLDIST.P_tmp_amt := ROUND (GML_PO_GLDIST.P_tmp_amt, GML_PO_GLDIST.P_precision);
        GML_PO_GLDIST.P_tmp_amt2 := (GML_PO_GLDIST.P_order_qty1 * GML_PO_GLDIST.P_tmp_po_cost);
        GML_PO_GLDIST.P_tmp_amt2 := ROUND (GML_PO_GLDIST.P_tmp_amt2, GML_PO_GLDIST.P_precision);
        /*Sandeep. Bug Fixed for wrong totalling of ACV acct title. */
        /*GML_PO_GLDIST.P_amount_trans_aqui := GML_PO_GLDIST.P_tmp_amt - GML_PO_GLDIST.P_tmp_amt2;*/
        GML_PO_GLDIST.P_amount_trans_aqui  := -(GML_PO_GLDIST.P_tot_amount_inv_aqui +  GML_PO_GLDIST.P_tot_amount_aap_aqui);
      ELSE
        GML_PO_GLDIST.P_amount_trans_aqui := 0;
      END IF;
      /* B908529 clear for PPV calc with multiple lines */
      P_tot_amount_inv_aqui	:= 0;
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num = GML_PO_GLDIST.GL$AT_ERV  THEN
      GML_PO_GLDIST.P_amount_trans_aqui := 0;
    END IF;

    /*Sandeep. Bug Fixed.The following Amount base for Aquisition is modified.*/
    /* It is multiplied with Extended cost, instead of X_cost_amount.*/
    GML_PO_GLDIST.P_amount_base_aqui :=  X_cost_amount * GML_PO_GLDIST.P_exchange_rate;
    GML_PO_GLDIST.P_amount_base_aqui   :=  GML_PO_GLDIST.P_amount_trans_aqui * GML_PO_GLDIST.P_exchange_rate;

    GML_PO_GLDIST.P_amount_base_aqui := ROUND (GML_PO_GLDIST.P_amount_base_aqui, GML_PO_GLDIST.P_precision);

    GML_PO_GLDIST.P_amount_trans_aqui := ROUND (GML_PO_GLDIST.P_amount_trans_aqui, GML_PO_GLDIST.P_precision);

  RETURN 0;

  END calc_dist_amount_aqui;

  /*##########################################################################
  # PROC
  #  calc_dist_amount
  #
  # GLOBAL VARIABLES
  #
  # RETURNS
  #  1 = success
  # -1 = failure
  #
  # DESCRIPTION
  #  calculate amount_trans using indicators in gl_event_plc and po_cost_dtl
  #  before inserting into po_dist_dtl table
  #
  ##########################################################################*/

  PROCEDURE  calc_dist_amount  AS

    CURSOR  Cur_orgn_for_whse IS
      SELECT  orgn_code
         FROM  ic_whse_mst
       WHERE whse_code = GML_PO_GLDIST.P_to_whse;

    CURSOR Cur_get_ind_set  IS
      SELECT   std_actual_ind , exp_booked_ind ,
                        acquis_cost_ind
         FROM    gl_evnt_plc e, gl_srce_mst s, gl_evnt_mst m
       WHERE   e.co_code = GML_PO_GLDIST.P_co_code and
                        e.trans_source_type = s.trans_source_type and e.event_type = m.event_type
                        and e.trans_source_type = m.trans_source_type
                        and s.trans_source_code = 'PO' and m.event_code = 'RCPT'
                        and e.delete_mark = 0;

    X_std_actual_ind    NUMBER;
    X_exp_booked_ind    NUMBER;
    X_aqui_cost_ind     NUMBER;
    rvar                NUMBER;
    X_workfloat1        NUMBER;
    X_orgn_code         VARCHAR2(10);
    X_retvar            NUMBER;
    X_tmp_amt           NUMBER;
    X_cost_mthd         VARCHAR2(10) DEFAULT NULL;
    X_total_cost        NUMBER;
    X_row_count         NUMBER;
    x_cmpntcls_id       NUMBER;
    x_analysis_code     VARCHAR2(10);
    x_status            NUMBER;
    x_cost              NUMBER;
    X_retr_ind          NUMBER;

  BEGIN
    OPEN   Cur_orgn_for_whse;
    FETCH  Cur_orgn_for_whse  INTO  X_orgn_code;
    IF Cur_orgn_for_whse%NOTFOUND  THEN
      X_orgn_code  :=   FND_PROFILE.VALUE ('GEMMS_DEFAULT_ORGN');
    END IF;
    CLOSE  Cur_orgn_for_whse;

    IF GML_PO_GLDIST.P_cost_cmpntcls_id IS NOT NULL  AND GML_PO_GLDIST.P_cost_analysis_code IS NOT NULL THEN
      X_retr_ind  := 3;
      X_retvar := gmf_cmcommon.cmcommon_get_cost( GML_PO_GLDIST.P_gl_item_id, GML_PO_GLDIST.P_to_whse,
                                              X_orgn_code , GML_PO_GLDIST.P_po_date,
       		 			      X_cost_mthd , GML_PO_GLDIST.P_cost_cmpntcls_id,
                                              GML_PO_GLDIST.P_cost_analysis_code, X_retr_ind,
                                              X_total_cost, X_row_count );
      IF (x_row_count IS NULL) THEN
        x_row_count := 0;
      END IF;

      IF  X_retvar < 1  THEN
        GML_PO_GLDIST.P_po_cost   := 0 ;
      END IF;
    ELSE
      X_retr_ind := 5;
      X_retvar  :=   gmf_cmcommon.cmcommon_get_cost ( GML_PO_GLDIST.P_gl_item_id, GML_PO_GLDIST.P_to_whse,
                                                  X_orgn_code , GML_PO_GLDIST.P_po_date,
       		 			          X_cost_mthd , GML_PO_GLDIST.P_cost_cmpntcls_id,
                                                  GML_PO_GLDIST.P_cost_analysis_code, X_retr_ind,
                                                  X_total_cost, X_row_count );
      IF x_row_count IS NULL THEN
        x_row_count := 0;
      END IF;
    END IF;

    FOR i IN 1..x_row_count LOOP
      /* This routine below returns the total cost in a loop,as cmcommon_get_cost routine */
      /* returns only the row count.*/
      gmf_cmcommon.get_multiple_cmpts_cost(i,x_cmpntcls_id,x_analysis_code,x_total_cost,X_retr_ind,x_status);
      x_cost := nvl(x_cost,0) + nvl (x_total_cost,0)  ;
    END LOOP;
    IF  X_retvar < 1  THEN
      GML_PO_GLDIST.P_po_cost   := 0 ;
    ELSE
      GML_PO_GLDIST.P_po_cost   :=  X_cost; /* Returned cost for the particular pair.*/
    END IF;
    GML_PO_GLDIST.P_tmp_po_cost   :=   GML_PO_GLDIST.P_po_cost / GML_PO_GLDIST.P_exchange_rate;
    OPEN     Cur_get_ind_set;
    FETCH  Cur_get_ind_set  INTO  X_std_actual_ind, X_exp_booked_ind, X_aqui_cost_ind;
    CLOSE Cur_get_ind_set;

    IF  GML_PO_GLDIST.P_acct_ttl_num =  GML_PO_GLDIST.GL$AT_INV  THEN
      IF  X_std_actual_ind  =  1  THEN
        GML_PO_GLDIST.P_amount_trans  :=  GML_PO_GLDIST.P_extended_price ;
      ELSE
        GML_PO_GLDIST.P_amount_trans  := GML_PO_GLDIST.P_order_qty1 * GML_PO_GLDIST.P_tmp_po_cost ;
      END IF;
      GML_PO_GLDIST.P_tot_amount_inv  := nvl(GML_PO_GLDIST.P_tot_amount_inv,0) + nvl(GML_PO_GLDIST.P_amount_trans, 0);
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num =  GML_PO_GLDIST.GL$AT_EXP  THEN
      GML_PO_GLDIST.P_amount_trans :=  GML_PO_GLDIST.P_extended_price  ;
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num =  GML_PO_GLDIST.GL$AT_AAP  THEN
      GML_PO_GLDIST.P_amount_trans := GML_PO_GLDIST.P_extended_price * (-1);
      GML_PO_GLDIST.P_tot_amount_aap := GML_PO_GLDIST.P_amount_trans;
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num  =  GML_PO_GLDIST.GL$AT_PPV  THEN
      IF  ( X_std_actual_ind  =  1 OR  GML_PO_GLDIST.P_non_inv_ind = 1 ) THEN
        GML_PO_GLDIST.P_amount_trans := 0;
      ELSE
        X_tmp_amt := (GML_PO_GLDIST.P_order_qty1 * GML_PO_GLDIST.P_tmp_po_cost) ;
        X_tmp_amt := ROUND (X_tmp_amt, GML_PO_GLDIST.P_precision);
        /*P_amount_trans := P_tot_amount_inv - P_amount_trans - X_tmp_amt;*/
        GML_PO_GLDIST.P_amount_trans := -(GML_PO_GLDIST.P_tot_amount_inv + GML_PO_GLDIST.P_tot_amount_aap );
      END IF;
      /* B908529 clear for PPV calc with multiple lines */
      P_tot_amount_inv	:= 0;
    END IF;

    IF  GML_PO_GLDIST.P_acct_ttl_num = GML_PO_GLDIST.GL$AT_ERV  THEN
     GML_PO_GLDIST.P_amount_trans := 0;
    END IF;

    /*  # 10/13/95 Convert amount_trans to amount_base*/
    GML_PO_GLDIST.P_amount_base  :=  GML_PO_GLDIST.P_amount_trans * GML_PO_GLDIST.P_exchange_rate;
    GML_PO_GLDIST.P_amount_base := ROUND (GML_PO_GLDIST.P_amount_base, GML_PO_GLDIST.P_precision);
    GML_PO_GLDIST.P_amount_trans := ROUND (GML_PO_GLDIST.P_amount_trans, GML_PO_GLDIST.P_precision);  /* workfloat1 comes from curr_rounding procedure*/
  END calc_dist_amount;


  /*##########################################################################
  # PROC
  #  receive_data
  #
  # DESCRIPTION
  #  recieve arguments from calling_form
  #
  #  PARAMETERS to be passed ..
  #       doc_type
  #       pos_id
  #       line_id
  #       orgn_code
  #       po_date
  #       shipvend_id
  #       base_currency
  #       billing_currency
  #       to_whse
  #       line_no
  #       item_no
  #       extended_price
  #       project
  #       order_qty1
  #       order_um1
  #       item_id
  #       mul_div_sign
  #       exchange_rate
  #       price
  #       action
  #       V_Single_aqui
  #       retcode
  # HISTORY
  #     created by Sandeep 12.Oct.1998
  #     converted from PLL to Stored Proc by Tony Ricci 10/30/98
  #     major changes included using PL/SQL tables instead of RECORD GROUPS
  #
  #     21-JUN-1999 Tony Ricci change order by in select from gl_accu_map
  #                 B931936
  #	B1377089  RVK   31-Aug-2000     Some of the PO's were not getting
  #	updated with proper AAP and PPV accts as P_acqui_cost_id was not getting
  #	initialized. Also subledger update was failing due to uninitialized id
  #
  ############################################################################*/

  PROCEDURE  receive_data (V_doc_type  VARCHAR2, V_pos_id NUMBER,
                           V_line_id  NUMBER, V_orgn_code  VARCHAR2,
                           V_po_date  DATE, V_shipvend_id NUMBER,
                           V_base_currency  VARCHAR2,
			   V_billing_currency  VARCHAR2,
                           V_to_whse  VARCHAR2, V_line_no  NUMBER,
                           V_item_no  VARCHAR2, V_extended_price  NUMBER,
                           V_project  VARCHAR2, V_order_qty1  NUMBER,
                           V_order_um1 VARCHAR2, V_gl_item_id NUMBER,
                           V_mul_div_sign  NUMBER, V_exchange_rate  NUMBER,
                           V_price NUMBER,V_action NUMBER,
			   V_Single_aqui BOOLEAN,
			   retcode IN OUT NOCOPY NUMBER,
			   V_transaction_type IN VARCHAR2) AS

    X_co_code    VARCHAR2(5);

     CURSOR  Cur_base_curr IS
       SELECT  plcy.base_currency_code
         FROM  sy_orgn_mst orgn, gl_plcy_mst plcy
        WHERE  orgn.orgn_code = V_orgn_code and orgn.co_code = plcy.co_code;

     CURSOR  Cur_orgn_mst IS
       SELECT  co_code
         FROM  sy_orgn_mst
        WHERE  orgn_code = V_orgn_code;

     /* RVK B1394532 */
     CURSOR  Cur_whse_co_code IS
       SELECT  mst.co_code, mst.orgn_code
         FROM  sy_orgn_mst mst, ic_whse_mst ic
        WHERE  ic.whse_code = v_to_whse and
                mst.orgn_code = ic.orgn_code;

     CURSOR Cur_acctg_unit_id IS
       SELECT  acctg_unit_id
         FROM  gl_accu_map
 	WHERE  co_code = X_co_code and
       (orgn_code = V_orgn_code or orgn_code IS NULL) and
       (whse_code = V_to_whse or whse_code IS NULL) and
       delete_mark = 0
       order by nvl(orgn_code, ' ') desc, nvl(whse_code, ' ') desc;

     CURSOR Cur_item_mst IS
       SELECT  noninv_ind,gl_class
         FROM  ic_item_mst
        WHERE item_id = V_gl_item_id;

     CURSOR  Cur_po_vend_mst  IS
       SELECT   vendgl_class gl_vendorgl_class
         FROM  po_vend_mst
        WHERE  vendor_id = V_shipvend_id;

    CURSOR Cur_po_cost_mst IS
      SELECT  cmpntcls_id , analysis_code
        FROM  po_cost_mst
       WHERE aqui_cost_id = P_aqui_cost_id;

    /*Sandeep. Modified the Cursor for doc_type 'PORD' and 'RECV". */
    /*Initially, it was hard-coded to 'PORD'.*/
    CURSOR Cur_get_aqui_costs  IS
      SELECT  aqui_cost_id , cost_amount , incl_ind
        FROM  po_cost_dtl
       WHERE  doc_type = P_doc_type and pos_id = P_pos_id and
                     line_id = P_line_id;
    CURSOR Cur_fiscal_year IS
      SELECT fiscal_year,period
        FROM gl_cldr_dtl
       WHERE co_code = P_co_code and
             period_end_date >= P_po_date
             and delete_mark = 0;

    CURSOR Cur_ledg_code IS
      SELECT ledger_code
        FROM gl_ledg_map
       WHERE co_code = P_co_code and
       (orgn_code    = P_orgn_code or orgn_code IS NULL) and
       delete_mark   = 0;

    CURSOR Cur_dec_precision IS
      SELECT decimal_precision
        FROM gl_curr_mst
       WHERE currency_code = V_billing_currency;

    X_retvar        NUMBER DEFAULT 0;
    X_aqui_row_num  NUMBER DEFAULT 0;
    X_row_num       NUMBER DEFAULT 0;
    X_status        NUMBER DEFAULT 0;
    X_retval        NUMBER DEFAULT 0;

  /* PL/SQL table types are defined in gmlgldists.pls */
  X_gltitles1          t_gltitlestable;
  X_cmpntcls1          t_cmpntclstable;
  X_analysiscode1      t_analysiscodetable;

  BEGIN
    P_doc_type                :=  V_doc_type;
    P_pos_id                  :=  V_pos_id;
    P_line_id                 :=  V_line_id;
    P_orgn_code               :=  V_orgn_code;
    P_po_date                 :=  V_po_date;
    P_shipvend_id             :=  V_shipvend_id;
    P_base_currency           :=  V_base_currency;
    P_billing_currency        :=  V_billing_currency;
    P_to_whse                 :=  V_to_whse;
    P_line_no                 :=  V_line_no;
    P_item_no                 :=  V_item_no;
    P_project                 :=  V_project;
    P_order_qty1              :=  V_order_qty1;
    P_order_um1               :=  V_order_um1;
    P_gl_item_id              :=  V_gl_item_id;
    P_mul_div_sign            :=  V_mul_div_sign;
    P_exchange_rate           :=  V_exchange_rate;
    P_extended_price          :=  ( V_order_qty1 * v_price );
    P_action                  :=  V_action;
    retcode                   :=  0;
    P_transaction_type	      :=  V_transaction_type;

 /* B1377089 RVK */
    P_aqui_cost_id := NULL;

    /* Each time delete the distributions and recreate them. */
    /* B1409258*/
    IF V_action = 4
    THEN
    	DELETE 	po_dist_dtl
    	WHERE 	doc_type 	= P_doc_type
    	AND 	DOC_ID 		= P_pos_id
    	AND	line_id		= P_line_id;
    END IF;


    OPEN   Cur_dec_precision;
    FETCH  Cur_dec_precision INTO P_precision;
    CLOSE  Cur_dec_precision;

    IF  P_base_currency  IS NULL THEN
      OPEN   Cur_base_curr;
      FETCH  Cur_base_curr  INTO  P_base_currency ;
      CLOSE  Cur_base_curr;
    END IF;

    IF  P_exchange_rate  IS  NULL  OR  P_exchange_rate = 0 THEN
      IF  P_base_currency  IS NULL THEN
        P_default_currency  :=  SY$DEFAULT_CURR;
      END IF;


      IF P_default_currency = P_base_currency  THEN
        P_exchange_rate    := 1;
        P_mul_div_sign     := 0;
      ELSE
        /* PLL call to GLCOMMON*/
        X_retvar  :=  GML_PO_GLDIST.get_exchg_rate( 1, P_po_date, P_default_currency ,P_Billing_currency);
        IF X_retvar < 1  THEN  /*-  Query Fails*/
          P_exchange_rate :=  1;
          P_mul_div_sign  :=  0;
        END IF;
      END IF;
    END IF;

    IF P_mul_div_sign = 1 THEN
      P_exchange_rate := 1.0/P_exchange_rate;
    ELSE
      P_exchange_rate := P_exchange_rate;
    END IF;

    OPEN   Cur_orgn_mst;
    FETCH  Cur_orgn_mst  INTO P_co_code;
    CLOSE  Cur_orgn_mst;

     /* RVK B1394532 */
    OPEN   Cur_whse_co_code;
    FETCH  Cur_whse_co_code  INTO P_whse_co_code,P_whse_orgn_code;
    IF  Cur_whse_co_code%NOTFOUND THEN
        P_whse_co_code := P_co_code;
        P_whse_orgn_code := P_orgn_code;
    END IF;
    CLOSE  Cur_whse_co_code;


    /*Sandeep. Code added to check, if 'GL$FINANCIAL_PACKAGE' is set to ORAFIN,*/
    /* Then Fiscal Yr and Period values are fetched*/
    /* from FINANCIAL Tables, else, fetched from GEMMS Tables.*/
    /* B1297909 */
/*  IF FND_PROFILE.VALUE ('GL$FINANCIAL_PACKAGE' ) = 'ORAFIN' THEN */
      X_retval := GML_PO_GLDIST.get_orafin_sob (P_co_code, 0);
      IF X_retval >= 0 THEN
        /* GML_PO_GLDIST.P_period_date := P_po_date;*/
        X_retval := GML_PO_GLDIST.get_ofperiod_info (P_co_code, 0,
                    GML_PO_GLDIST.P_sobname,GML_PO_GLDIST.P_calendar_name,
                    GML_PO_GLDIST.P_period_type, NULL, NULL,P_po_date);
        /* 11.Nov.98 GLCOMMON.pll is modified, and accordingly , the changes */
        /* are reflected here.*/
        IF X_retval >= 0 THEN
          GML_PO_GLDIST.P_fiscal_year := GML_PO_GLDIST.P_periodyear;
          GML_PO_GLDIST.P_period      := GML_PO_GLDIST.P_periodnumber;
        END IF;
        /* 11.Nov.98. Change ends here.*/
      END IF;
/*  ELSE
    OPEN   Cur_fiscal_year;
    FETCH  Cur_fiscal_year INTO P_fiscal_year, P_period;
    CLOSE  Cur_fiscal_year;
  END IF;
 */
    OPEN   Cur_ledg_code;
    FETCH  Cur_ledg_code  INTO P_ledger_code;
    CLOSE  Cur_ledg_code;

    /* Select proper acctg_unit_id for each warehouse.*/
    OPEN   Cur_acctg_unit_id;
    FETCH  Cur_acctg_unit_id INTO P_acctg_unit_id;
    CLOSE  Cur_acctg_unit_id;

    /*Added select of gl_class to be passed to mapping PCR 9475*/
    OPEN   Cur_item_mst;
    FETCH  Cur_item_mst INTO P_non_inv_ind, P_itemglclass;
    CLOSE  Cur_item_mst;

    /* Added select of vendor gl_class to be passed to mapping*/
    OPEN    Cur_po_vend_mst;
    FETCH  Cur_po_vend_mst INTO P_vend_gl_class;
    CLOSE  Cur_po_vend_mst;

    IF V_Single_aqui = TRUE THEN
      GML_PO_GLDIST.poglded2_check_new_aqui(retcode) ;
    ELSE
      GML_PO_GLDIST.load_acct_titles('ITEM',
                                     P_gl_item_id,
                                     P_co_code,
                                     P_non_inv_ind,
                                     P_to_whse,
                                     P_po_date,
                                     0, /* incl_ind for aqui cost.*/
					/* '0' passed for an item*/
                                     X_row_num,
                                     X_status,
				     X_gltitles1,
				     X_cmpntcls1,
                                     X_analysiscode1);
      FOR  i IN 1 .. X_row_num LOOP
        P_amount_trans         :=  0;
        P_amount_base          :=  0;
        P_amount_trans_aqui    :=  0;
        P_amount_base_aqui     :=  0;

        P_acct_ttl_num        := X_gltitles1(i);
        P_cost_cmpntcls_id    := X_cmpntcls1(i);
        P_cost_analysis_code  := X_analysiscode1(i);
        IF P_cost_cmpntcls_id = 0 THEN
          P_cost_cmpntcls_id := NULL;
        END IF;
        GML_PO_GLDIST.process_trans ('ITEM', retcode);
      END LOOP;

      /*Initialise X_aqui_row_num*/
      X_aqui_row_num := 0;
      FOR Rec IN Cur_get_aqui_costs LOOP
        P_amount_trans         :=  0;
        P_amount_base          :=  0;
        P_amount_trans_aqui    :=  0;
        P_amount_base_aqui     :=  0;

        P_aqui_cost_id := Rec.aqui_cost_id;
        P_cost_amount  := Rec.cost_amount;
        P_incl_ind     := Rec.incl_ind;

        P_aqui_cmpntcls_id     := 0;
        P_aqui_analysis_code  := NULL;
        OPEN   Cur_po_cost_mst;
        FETCH  Cur_po_cost_mst INTO  P_aqui_cmpntcls_id,P_aqui_analysis_code;
        IF  Cur_po_cost_mst%NOTFOUND THEN
	  CLOSE  Cur_po_cost_mst;
        ELSE
          CLOSE  Cur_po_cost_mst;
          /*X_no_acqui_titles  :=  poglded2_load_acct_title_array ('AQUI',X_aqui_row_num );*/
          GML_PO_GLDIST.load_acct_titles('AQUI',
                                           P_gl_item_id,
                                           P_co_code,
                                           P_non_inv_ind,
                                           P_to_whse,
                                           P_po_date,
                                           P_incl_ind,
                                           X_row_num,
                                           X_status,
				           X_gltitles1,
				           X_cmpntcls1,
                                           X_analysiscode1);
          FOR  i IN 1..X_row_num LOOP
            P_acct_ttl_num        := X_gltitles1(i);
            P_cost_cmpntcls_id    := X_cmpntcls1(i);
            P_cost_analysis_code  := X_analysiscode1(i);
            IF P_cost_cmpntcls_id = 0 THEN
              P_cost_cmpntcls_id := NULL;
            END IF;
            process_trans ('AQUI',retcode);
          END LOOP;
        END IF;
      END LOOP;
     END IF;

    END receive_data;

  /*************************************************************************
  # PROC
  #     poglded2_process_trans
  #
  # INPUT PARAMETERS
  #                    V_type (10)         'TEMM' or 'AQUI'
  #
  #
  # DESCRIPTION
  #   pass data parmeters to poglded2_process_trans to post into the database.
  #
  # HISTORY
  #    created by 12.Oct.1998
  #
  #**************************************************************************/

  PROCEDURE  process_trans (V_type VARCHAR2, retcode IN OUT NOCOPY NUMBER) AS
    X_retvar          NUMBER;
  BEGIN
    P_acct_id        :=  GML_PO_GLDIST.default_mapping               ;
    P_acctg_unit_no  :=  GML_PO_GLDIST.get_acctg_unit_no             ;
    GML_PO_GLDIST.get_acct_no (P_acct_no, P_acct_desc );
    IF (V_type = 'ITEM') THEN
      GML_PO_GLDIST.calc_dist_amount ;
    ELSIF (V_type = 'AQUI') THEN
     IF P_aqui_cost_id > 0  THEN
      X_retvar := GML_PO_GLDIST.calc_dist_amount_aqui ;
     END IF;
    END IF;
    GML_PO_GLDIST.set_data (retcode);
  END process_trans;

  /*##########################################################################
  # PROC
  #  poglded2_default_mapping
  #
  # INPUT PARAMETERS
  #   Package Variables are passed to the fuction
  # HISTORY
  #   created by Sandeep 12.Oct.1998
  # RETURNS
  #   < 0 - Mapping failed
  #   > 0 - Mapping Successful.
  #
  #########################################################################*/

  FUNCTION default_mapping RETURN NUMBER AS
    X_i  NUMBER;
  BEGIN
	/* RVK B1394532 */
    gmf_get_mappings.get_account_mappings ( P_whse_co_code,
 					       					P_whse_orgn_code,
                                               P_to_whse,
                                               P_gl_item_id,
                                               P_shipvend_id,
                                               P_cust_id,
                                               P_reason_code,
                                               P_itemglclass,
                                               P_vend_gl_class,
                                               P_cust_gl_class,
                                               P_base_currency,
                                               P_routing_id,
                                               P_charge_id,
                                               P_taxauth_id,
                                               P_aqui_cost_id,
                                               P_resources,
                                               P_cost_cmpntcls_id,
                                               P_cost_analysis_code,
                                               P_order_type,
                                               P_sub_event_type );
     P_acct_id  :=  gmf_get_mappings.get_account_value (P_acct_ttl_num );
     RETURN (P_acct_id );

  END default_mapping;

  /*##########################################################################
  # PROC
  #   get_acctg_unit_no
  #
  # INPUT PARAMETERS
  #   Package Variables are passed to the Function
  # RETURNS
  #   If success, returns acctg_unit_no ELSE null.
  # HISTORY
  #    created by Sandeep 12.0ct.1998
  #
  #     21-JUN-1999 Tony Ricci change order by in select from gl_accu_map
  #                 B931936
  #     21-JUN-1999 Tony Ricci add login to select and check map_orgn_ind
  #                 B931936
  ############################################################################*/

  FUNCTION get_acctg_unit_no  RETURN VARCHAR2 AS

    CURSOR Cur_map_orgn_ind IS
      SELECT map_orgn_ind
        FROM gl_sevt_ttl
       WHERE sub_event_type = P_sub_event_type and
             acct_ttl_type = P_acct_ttl_num;

    CURSOR Cur_whse_orgn_code IS
      SELECT orgn_code
        FROM ic_whse_mst
       WHERE whse_code = P_to_whse;

	/* RVK B1394532 */
    CURSOR Cur_acctg_unit_id (vc_orgn_code VARCHAR2) IS
      SELECT  acctg_unit_id , orgn_code , whse_code
        FROM  gl_accu_map
       WHERE  co_code = P_whse_co_code and
			 (orgn_code = vc_orgn_code or orgn_code IS NULL) and
             (whse_code = P_to_whse or whse_code IS NULL) and
             delete_mark = 0
             order by nvl(orgn_code, ' ') desc, nvl(whse_code, ' ') desc;

    CURSOR Cur_acctg_unit_no  IS
      SELECT  acctg_unit_no
          FROM  gl_accu_mst
       WHERE  acctg_unit_id = P_acctg_unit_id;

    X_acctg_orgn  VARCHAR2(10);
    X_acctg_whse  VARCHAR2(10);
    X_map_orgn_ind	gl_sevt_ttl.map_orgn_ind%TYPE;
    X_orgn_code		sy_orgn_mst.orgn_code%TYPE;
    X_co_code		sy_orgn_mst.co_code%TYPE;

  BEGIN

    X_orgn_code		:= P_orgn_code;

    OPEN    Cur_map_orgn_ind;
    FETCH   Cur_map_orgn_ind INTO X_map_orgn_ind;
    CLOSE   Cur_map_orgn_ind;

    IF X_map_orgn_ind = 0 THEN
    	OPEN Cur_whse_orgn_code;
	FETCH Cur_whse_orgn_code INTO X_orgn_code;
    	CLOSE Cur_whse_orgn_code;
    END IF;

    OPEN    Cur_acctg_unit_id (X_orgn_code);
    FETCH  Cur_acctg_unit_id  INTO  P_acctg_unit_id, X_acctg_orgn, X_acctg_whse;
    CLOSE Cur_acctg_unit_id;

    OPEN    Cur_acctg_unit_no;
    FETCH  Cur_acctg_unit_no  INTO  P_acctg_unit_no;
    CLOSE  Cur_acctg_unit_no;
    RETURN ( P_acctg_unit_no );

  END get_acctg_unit_no;

  /*##########################################################################
  # PROC
  #  get_acct_no
  #
  # INPUT PARAMETERS
  #   Package variables are passed to the procedure
  # DESCRIPTION
  #   This procedure returns the corresponding Account no. and Account desc
  #   based on the P_acct_id
  ##########################################################################*/

  PROCEDURE get_acct_no(V_acct_no OUT NOCOPY VARCHAR2, V_acct_desc OUT NOCOPY VARCHAR2) AS

    CURSOR Cur_acct_no  IS
      SELECT  acct_no, acct_desc
        FROM  gl_acct_mst
       WHERE  acct_id= P_acct_id;

  BEGIN
    OPEN   Cur_acct_no;
    FETCH  Cur_acct_no INTO V_acct_no, V_acct_desc;
    CLOSE  Cur_acct_no;

  END get_acct_no;





  /*##############################################################################
  #
  # Procedure Name
  #   proc get_exchg_rate
  # Input Parameters
  #   psource_type   - the source type e.g. 1, 2 etc
  #   _date          - the name of the variable (NOT the date itself)
  #                    containing the trans date to use
  #   pto_currency   - the to currency code to select by
  #   pfrom_currency - the from currency code to select by
  # Description
  #   Retrieves the exchange rate and mul_div_sign based on the parameters
  #   send in, psource_type _date, pto_currency and pfrom_currency, from
  #   gl_xchg_rte table. the row selected should be the latest dated
  #   row.
  #
  ##############################################################################*/

  FUNCTION get_exchg_rate(V_psource_type  NUMBER, V_po_date  DATE,
                                   V_default_currency  VARCHAR2 ,V_billing_currency  VARCHAR2 )
                                   RETURN NUMBER AS
   CURSOR  Cur_get_exch_rate  IS
     SELECT   ex.exchange_rate , ex.mul_div_sign,
                      ex.exchange_rate_date
        FROM   gl_xchg_rte ex, gl_srce_mst src
      WHERE ex.to_currency_code  =  V_default_currency  and
                     ex.from_currency_code= V_billing_currency  and
                     ex.exchange_rate_date <=  V_po_date  and
                     ex.rate_type_code = src.rate_type_code and
                     src.trans_source_type = V_psource_type and ex.delete_mark=0
                     order by  3 desc;

   CURSOR  Cur_get_exch_rate_inv  IS
     SELECT   ex.exchange_rate , ex.mul_div_sign,
                      ex.exchange_rate_date
        FROM   gl_xchg_rte ex, gl_srce_mst src
      WHERE ex.to_currency_code  =  V_billing_currency  and
                     ex.from_currency_code= V_default_currency  and
                     ex.exchange_rate_date <=  V_po_date  and
                     ex.rate_type_code = src.rate_type_code and
                     src.trans_source_type = V_psource_type and ex.delete_mark=0
                     order by  3 desc;
    X_fetch  NUMBER  DEFAULT 0;
  BEGIN
    OPEN    Cur_get_exch_rate;
    FETCH  Cur_get_exch_rate  INTO  GML_PO_GLDIST.P_exchange_rate, GML_PO_GLDIST.P_mul_div_sign, GML_PO_GLDIST.P_exch_date;
    IF Cur_get_exch_rate%NOTFOUND THEN
      X_fetch  :=  0;
      OPEN   Cur_get_exch_rate_inv;
      X_fetch  :=  1;
      FETCH Cur_get_exch_rate_inv  INTO GML_PO_GLDIST.P_exchange_rate, GML_PO_GLDIST.P_mul_div_sign, GML_PO_GLDIST.P_exch_date;
      IF Cur_get_exch_rate_inv%NOTFOUND THEN
        X_fetch := 0;
        GML_PO_GLDIST.P_exchange_rate  :=  1;
        GML_PO_GLDIST.P_mul_div_sign    :=  0;
      ELSE
        IF GML_PO_GLDIST.P_mul_div_sign =  0  THEN
          GML_PO_GLDIST.P_mul_div_sign :=  1;
        ELSE
          GML_PO_GLDIST.P_mul_div_sign  := 0;
        END IF;
      END IF;
      CLOSE Cur_get_exch_rate_inv;
      CLOSE Cur_get_exch_rate;
      RETURN ( X_fetch );
    END IF;
  END get_exchg_rate;


  /*############################################################################
  #
  #  PROC
  #    set_data
  #
  #
  # DESCRIPTION
  #     This procedure would set data into the Record group for final posting
  #     into the PO Dist table. ( PO_DIST_DTL ).
  #     Uday Phadtare 02/25/2002 B2237665 Added do_type in the where clause
  #     when updating po_dist_dtl.
  ##############################################################################*/

  PROCEDURE set_data(retcode IN OUT NOCOPY NUMBER) AS
    /*x_row_num           NUMBER DEFAULT 0;*/
    X_amount_base       NUMBER DEFAULT 0;
    X_amount_trans      NUMBER DEFAULT 0;
    X_last_update_date  DATE;
    X_created_by        NUMBER;
    X_creation_date     DATE;
    X_last_updated_by   NUMBER;
    X_last_update_login NUMBER;
    X_trans_cnt         NUMBER;
    X_text_code         NUMBER;
    X_delete_mark       NUMBER;
    X_retval            NUMBER;
    X_order_qty1        NUMBER;
    err_msg             VARCHAR2(100);

/*Bug# 1324319      Added code to pass the AAP and PPV accts generated at the OPM side
over to the APPS side.*/
    X_combination_id	NUMBER;

    CURSOR Cur_count_rows IS
      SELECT count (*) from po_dist_dtl
      WHERE  doc_id = GML_PO_GLDIST.P_pos_id and
             line_id = GML_PO_GLDIST.P_line_id and
             doc_type = GML_PO_GLDIST.P_doc_type;

  BEGIN
    GML_PO_GLDIST.P_doc_type     := GML_PO_GLDIST.P_doc_type;
    GML_PO_GLDIST.P_recv_seq_no  := GML_PO_GLDIST.GL$SE_NEW_RECV ;

    OPEN  Cur_count_rows;
    FETCH Cur_count_rows  INTO  GML_PO_GLDIST.P_row_num;
    CLOSE Cur_count_rows;
    GML_PO_GLDIST.P_row_num  :=  nvl(GML_PO_GLDIST.P_row_num, 0) + 1;

    IF GML_PO_GLDIST.P_type = 'ITEM' THEN
      X_amount_base  := GML_PO_GLDIST.P_amount_base;
      X_amount_trans := GML_PO_GLDIST.P_amount_trans;
    ELSIF GML_PO_GLDIST.P_type = 'AQUI' THEN
      X_amount_base  := GML_PO_GLDIST.P_amount_base_aqui;
      X_amount_trans := GML_PO_GLDIST.P_amount_trans_aqui;
    END IF;

    X_last_update_date  := SYSDATE;
    X_created_by        := FND_PROFILE.VALUE ('USER_ID');
    X_creation_date     := SYSDATE;
    X_last_updated_by   := FND_PROFILE.VALUE ('USER_ID');
    X_last_update_login := 0;
    X_trans_cnt         := 0;
    X_text_code         := NULL;
    X_delete_mark       := 0;

    /*Sandeep. Bug Fixed. Modified for setting the Qty to '0' , if it is an*/
    /* Aqui. row.*/
    IF GML_PO_GLDIST.p_aqui_cost_id = 0 OR
       GML_PO_GLDIST.p_aqui_cost_id IS NULL THEN
      GML_PO_GLDIST.P_aqui_cost_id   := NULL;
      X_order_qty1  := GML_PO_GLDIST.P_order_qty1;
    ELSE
      X_order_qty1  := 0;
    END IF;

    IF (GML_PO_GLDIST.P_acct_id IS NULL OR GML_PO_GLDIST.P_acct_id = -1) THEN
      retcode := 1;
    ELSIF GML_PO_GLDIST.P_acctg_unit_id IS NULL THEN
      retcode := 2;
    ELSIF GML_PO_GLDIST.P_fiscal_year IS NULL THEN
      retcode := 3;
    ELSIF GML_PO_GLDIST.P_ledger_code IS NULL THEN
      retcode := 4;
    END IF;

  IF retcode >0 THEN
     RETURN;
    END IF;


    IF (GML_PO_GLDIST.P_action = 1 )  THEN
      INSERT INTO PO_DIST_DTL (	DOC_TYPE,
		    		DOC_ID,
				LINE_ID,
				RECV_SEQ_NO,
				SEQ_NO,
				AQUI_COST_ID,
				ITEM_ID,
				ACCTG_UNIT_ID,
				ACCT_ID,
				ACCT_DESC,
				ACCT_TTL_TYPE,
				AMOUNT_BASE,
				AMOUNT_TRANS,
				QUANTITY,
				QUANTITY_UM,
				PROJECT_NO,
				GL_POSTED_IND,
				EXPORTED_DATE,
				CURRENCY_TRANS,
				CURRENCY_BASE,
				CO_CODE,
				LEDGER_CODE,
				FISCAL_YEAR,
				PERIOD,
				LAST_UPDATE_DATE,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				TRANS_CNT,
				TEXT_CODE,
				DELETE_MARK)
                         VALUES (GML_PO_GLDIST.P_doc_type,
                                 GML_PO_GLDIST.P_pos_id,
                                 GML_PO_GLDIST.P_line_id,
                                 GML_PO_GLDIST.P_recv_seq_no,
                                 GML_PO_GLDIST.p_row_num,
                                 GML_PO_GLDIST.P_aqui_cost_id,
                                 GML_PO_GLDIST.P_gl_item_id,
                                 GML_PO_GLDIST.P_acctg_unit_id,
                                 GML_PO_GLDIST.P_acct_id,
                                 GML_PO_GLDIST.P_acct_desc,
                                 GML_PO_GLDIST.P_acct_ttl_num,
                                 nvl(X_amount_base,0),
	                         nvl(X_amount_trans,0),
        	                 nvl(X_order_qty1,0),
			         GML_PO_GLDIST.P_order_um1,
			         GML_PO_GLDIST.P_project,
		                 nvl(GML_PO_GLDIST.P_gl_posted_ind,0),
		                 GML_PO_GLDIST.P_po_date,
		                 GML_PO_GLDIST.P_billing_currency,
		                 GML_PO_GLDIST.P_base_currency,
		                 GML_PO_GLDIST.P_co_code,
			         GML_PO_GLDIST.P_ledger_code,
	                         GML_PO_GLDIST.P_fiscal_year,
                                 GML_PO_GLDIST.P_period,
                                 X_last_update_date,
                                 X_created_by,
                                 X_creation_date,
                                 X_last_updated_by,
                                 X_last_update_login,
                                 X_trans_cnt,
                                 X_text_code,
                                 X_delete_mark );


/*Bug# 1324319      Added code to pass the AAP and PPV accts generated at the OPM side
over to the APPS side. */
           if GML_PO_GLDIST.P_acct_ttl_num in (3100,6100) and GML_PO_GLDIST.P_aqui_cost_id is NULL
	   then
			/* RVK 1394532 */
			GML_PO_GLDIST.combination_id( GML_PO_GLDIST.P_whse_co_code,
							 GML_PO_GLDIST.P_acct_id,
							 GML_PO_GLDIST.P_acctg_unit_id,
							 X_combination_id);

			GML_PO_GLDIST.update_accounts_orcl(	GML_PO_GLDIST.P_pos_id,
								GML_PO_GLDIST.P_line_id,
								GML_PO_GLDIST.P_orgn_code,
								GML_PO_GLDIST.P_acct_ttl_num,
								X_combination_id);
	   end if;

      ELSIF ( GML_PO_GLDIST.P_action = 4 ) THEN
        GML_PO_GLDIST.P_row_num_upd := NVL(GML_PO_GLDIST.P_row_num_upd,0) + 1;
        UPDATE PO_DIST_DTL SET  aqui_cost_id = GML_PO_GLDIST.P_aqui_cost_id,
				item_id = GML_PO_GLDIST.P_gl_item_id,
				acctg_unit_id = GML_PO_GLDIST.P_acctg_unit_id,
				acct_id = GML_PO_GLDIST.P_acct_id,
				acct_desc = GML_PO_GLDIST.P_acct_desc,
				acct_ttl_type = GML_PO_GLDIST.P_acct_ttl_num,
				amount_base = nvl(X_amount_base,0),
			 	amount_trans = nvl(X_amount_trans,0),
				quantity = nvl(GML_PO_GLDIST.P_order_qty1,0),
				quantity_um = GML_PO_GLDIST.P_order_um1,
				project_no = GML_PO_GLDIST.P_project,
				gl_posted_ind = nvl(GML_PO_GLDIST.P_gl_posted_ind,0),
                                last_update_date = X_last_update_date,
                                last_updated_by = X_last_updated_by,
                                last_update_login = X_last_update_login

                      WHERE     doc_type = GML_PO_GLDIST.P_doc_type and     /* B2237665 */
                                doc_id = GML_PO_GLDIST.P_pos_id and
                                line_id = GML_PO_GLDIST.P_line_id and
				recv_seq_no = GML_PO_GLDIST.P_recv_seq_no and
                     		acct_ttl_type = GML_PO_GLDIST.P_acct_ttl_num and
                                seq_no = GML_PO_GLDIST.P_row_num_upd;

        /* B1409258  PPB added the above insert statement incase if PO distributions are not created
	   for PO due to some reason. If the PO is then updated the the correct distributions will be created...
	   ie program goes to update the po_dist_dtl and finds no record there and then inserts a new if there is
	   no record.  */
        IF (SQL%ROWCOUNT = 0)  THEN

        	INSERT INTO PO_DIST_DTL (	DOC_TYPE,
		    		DOC_ID,
				LINE_ID,
				RECV_SEQ_NO,
				SEQ_NO,
				AQUI_COST_ID,
				ITEM_ID,
				ACCTG_UNIT_ID,
				ACCT_ID,
				ACCT_DESC,
				ACCT_TTL_TYPE,
				AMOUNT_BASE,
				AMOUNT_TRANS,
				QUANTITY,
				QUANTITY_UM,
				PROJECT_NO,
				GL_POSTED_IND,
				EXPORTED_DATE,
				CURRENCY_TRANS,
				CURRENCY_BASE,
				CO_CODE,
				LEDGER_CODE,
				FISCAL_YEAR,
				PERIOD,
				LAST_UPDATE_DATE,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				TRANS_CNT,
				TEXT_CODE,
				DELETE_MARK)
                         VALUES (GML_PO_GLDIST.P_doc_type,
                                 GML_PO_GLDIST.P_pos_id,
                                 GML_PO_GLDIST.P_line_id,
                                 GML_PO_GLDIST.P_recv_seq_no,
                                 GML_PO_GLDIST.p_row_num,
                                 GML_PO_GLDIST.P_aqui_cost_id,
                                 GML_PO_GLDIST.P_gl_item_id,
                                 GML_PO_GLDIST.P_acctg_unit_id,
                                 GML_PO_GLDIST.P_acct_id,
                                 GML_PO_GLDIST.P_acct_desc,
                                 GML_PO_GLDIST.P_acct_ttl_num,
                                 nvl(X_amount_base,0),
	                         nvl(X_amount_trans,0),
        	                 nvl(X_order_qty1,0),
			         GML_PO_GLDIST.P_order_um1,
			         GML_PO_GLDIST.P_project,
		                 nvl(GML_PO_GLDIST.P_gl_posted_ind,0),
		                 GML_PO_GLDIST.P_po_date,
		                 GML_PO_GLDIST.P_billing_currency,
		                 GML_PO_GLDIST.P_base_currency,
		                 GML_PO_GLDIST.P_co_code,
			         GML_PO_GLDIST.P_ledger_code,
	                         GML_PO_GLDIST.P_fiscal_year,
                                 GML_PO_GLDIST.P_period,
                                 X_last_update_date,
                                 X_created_by,
                                 X_creation_date,
                                 X_last_updated_by,
                                 X_last_update_login,
                                 X_trans_cnt,
                                 X_text_code,
                                 X_delete_mark );
	END IF;

	/*Bug# 1324319      Added code to pass the AAP and PPV accts generated at the OPM side
	over to the APPS side.*/
           if GML_PO_GLDIST.P_acct_ttl_num in (3100,6100) and GML_PO_GLDIST.p_aqui_cost_id is NULL
	   then
			/* RVK 1394532 */
			GML_PO_GLDIST.combination_id( GML_PO_GLDIST.P_whse_co_code,
							 GML_PO_GLDIST.P_acct_id,
							 GML_PO_GLDIST.P_acctg_unit_id,
							 X_combination_id);

			GML_PO_GLDIST.update_accounts_orcl(	GML_PO_GLDIST.P_pos_id,
								GML_PO_GLDIST.P_line_id,
								GML_PO_GLDIST.P_orgn_code,
								GML_PO_GLDIST.P_acct_ttl_num,
								X_combination_id);
	   end if;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        err_msg := SUBSTRB(SQLERRM, 1, 100);
        RAISE_APPLICATION_ERROR(-20000,err_msg);
        retcode := 1;

  END set_data;

  /*############################################################################
  #
  #  PROC
  #  load_acct_title
  #
  # INPUT PARAMETERS
  #   v_type
  #   v_item_id
  #   v_non_ind_ind
  #   v_to_whse_code
  #   v_item_id
  #   v_trans_date
  #   v_include_ind
  # OUTPUT PARAMETERS
  #   v_row_num
  #   v_status   1 = success
  #   v_gltitles TYPE t_gltitlestable
  #   v_cmpntcls TYPE t_cmpntclstable
  #   v_analysiscode TYPE t_analysiscodetable
  #
  #
  # DESCRIPTION
  #     load appropriate GL acct titles into array for mapping
  #                        Dynamically create as many INV rows as there
  #                        are PPV/Material Component Class costs for this item
  #                        arrays for later use by _process_trans
  #
  #                        Create single INV row if we do not calculate PPV and
  #                        are booking at PO price, i.e. std_actual_ind is 1.
  ##############################################################################  */

  PROCEDURE load_acct_titles(v_type         VARCHAR2,
                             v_item_id      NUMBER,
                             v_co_code      VARCHAR2,
                             v_non_inv_ind  NUMBER,
                             v_to_whse     IN VARCHAR2,
                             v_trans_date   IN DATE,
                             v_include_ind  IN NUMBER,
                             v_row_num      OUT NOCOPY NUMBER,
                             v_status       OUT NOCOPY NUMBER,
                             v_gltitles     OUT NOCOPY t_gltitlestable,
                             v_cmpntcls     OUT NOCOPY t_cmpntclstable,
                             v_analysiscode OUT NOCOPY t_analysiscodetable) AS

  CURSOR cur_get_srcevtplc IS
    SELECT std_actual_ind,
           exp_booked_ind,
           acquis_cost_ind
    FROM   gl_evnt_plc e, gl_srce_mst s, gl_evnt_mst m
    WHERE  e.co_code = v_co_code
	  AND e.trans_source_type = s.trans_source_type
	  AND e.event_type = m.event_type
          AND e.trans_source_type = m.trans_source_type
          AND s.trans_source_code = 'PO'
	  AND m.event_code = 'RCPT'
          AND e.delete_mark = 0;

  CURSOR cur_get_orgn_code IS
    SELECT orgn_code
    FROM   ic_whse_mst
    WHERE  whse_code = v_to_whse
           AND delete_mark = 0;

    x_po_whse_orgn VARCHAR2(4);
    x_std_act_ind  NUMBER;
    x_acq_cst_ind  NUMBER;
    x_exp_booked_ind NUMBER;
    x_row_num NUMBER DEFAULT 1;
    x_at_inv          NUMBER DEFAULT  1500;
    x_at_aap          NUMBER DEFAULT  3100;
    x_at_ppv          NUMBER DEFAULT  6100;
    x_at_exp          NUMBER DEFAULT  5100;
    x_at_aac          NUMBER DEFAULT  3150;
    x_at_acv          NUMBER DEFAULT  6150;
    x_at_erv          NUMBER DEFAULT  5500;
    x_default_orgn    VARCHAR2(4) := FND_PROFILE.VALUE('SY$DEFAULT_ORGANIZATION');
    x_cost_mthd       VARCHAR2(10);
    x_cmpntcls_id     NUMBER;
    x_analysis_code   VARCHAR2(10);
    x_total_cost      NUMBER;
    x_stautus         NUMBER;
    x_status          NUMBER;
    x_row_count       NUMBER DEFAULT 0;

  BEGIN
    GML_PO_GLDIST.P_type := V_type;

    OPEN cur_get_srcevtplc;
    FETCH cur_get_srcevtplc INTO x_std_act_ind,x_exp_booked_ind,x_acq_cst_ind ;
    CLOSE cur_get_srcevtplc;
    IF v_type = 'ITEM' THEN
      IF v_non_inv_ind = 1 THEN
	v_gltitles(x_row_num) := x_at_exp;
	v_cmpntcls(x_row_num) := 0;
	v_analysiscode(x_row_num) := '';
        x_row_num := x_row_num + 1;
      ELSE
        /*prep to get all ppv/matl component costs for this item      */
        OPEN cur_get_orgn_code;
        FETCH cur_get_orgn_code INTO x_po_whse_orgn;
        IF (cur_get_orgn_code%notfound) THEN
          x_po_whse_orgn := x_default_orgn;
        END IF;
       CLOSE cur_get_orgn_code;
        /* get all ppv/matl component costs for this item*/
        x_status := gmf_cmcommon.cmcommon_get_cost(v_item_id,v_to_whse,
					       x_po_whse_orgn,v_trans_date,
       	              			       x_cost_mthd,x_cmpntcls_id,
					       x_analysis_code,4,x_total_cost,
          				       x_row_count);
        IF (x_row_count IS NULL) THEN
          x_row_count := 0;
        END IF;
       /*force single INV row if std_actual_ind was set to 1*/
	/* Bug 1483360 */
       IF (x_status <> 1 OR x_row_count = 0 OR x_std_act_ind = 1 OR x_std_act_ind = 2) THEN
         /*PPV: force single INV acct title row*/
	 v_gltitles(x_row_num) := x_at_inv;
	 v_cmpntcls(x_row_num) := 0;
	 v_analysiscode(x_row_num) := '';
         x_row_num := x_row_num + 1;
       ELSE
         FOR i IN 1..x_row_count LOOP
         /* This will loop for the no of rows returned from cmcommon_get_cost */
	 /* routine into x_row_count.*/
         gmf_cmcommon.get_multiple_cmpts_cost(i,x_cmpntcls_id,x_analysis_code,
					  x_total_cost,4,x_status);
         IF (x_status = 0) THEN
	   v_gltitles(x_row_num) := x_at_inv;
	   v_cmpntcls(x_row_num) := x_cmpntcls_id;
	   v_analysiscode(x_row_num) := x_analysis_code;
           x_row_num := x_row_num + 1;
         END IF;
         END LOOP;
       END IF;
     END IF;
      v_gltitles(x_row_num) := x_at_aap;
      v_cmpntcls(x_row_num) := 0;
      v_analysiscode(x_row_num) := '';
	/* Bug 1483360 */
      IF (x_std_act_ind = 0 OR x_std_act_ind = 2) THEN
        x_row_num := x_row_num + 1;
        v_gltitles(x_row_num) := x_at_ppv;
        v_cmpntcls(x_row_num) := 0;
        v_analysiscode(x_row_num) := '';
      END IF;
   ELSIF(v_type = 'AQUI') THEN
     IF (v_include_ind = 0) THEN
       v_gltitles(x_row_num) := x_at_exp;
     ELSE
       v_gltitles(x_row_num) := x_at_inv;
     END IF;
     v_cmpntcls(x_row_num) := 0;
     v_analysiscode(x_row_num) := '';
     x_row_num := x_row_num + 1;
     IF (x_acq_cst_ind = 1) THEN
       v_gltitles(x_row_num) := x_at_aac;
     ELSE
       v_gltitles(x_row_num) := x_at_aap;
     END IF;
     v_cmpntcls(x_row_num) := 0;
     v_analysiscode(x_row_num) := '';
	/* Bug 1483360 */
     IF (x_std_act_ind = 0 OR x_std_act_ind = 2) THEN
       x_row_num := x_row_num + 1;
       v_gltitles(x_row_num) := x_at_acv;
       v_cmpntcls(x_row_num) := 0;
       v_analysiscode(x_row_num) := '';
     END IF;
   END IF;
   V_row_num := x_row_num;

  END load_acct_titles;

  /*##########################################################################
  # PROC
  #  poglded2_check_new_aqui
  #
  # INPUT PARAMETERS
  #  p_occur row to change
  #
  # GLOBAL VARIABLES
  #
  # RETURNS
  #  1 = success
  # -1 = failure
  #
  # DESCRIPTION
  #  After po_dist_dtl database retreival if a new aquisition cost was entered
  #  (In popaced2) map it and display.
  #  If  :system.record_status in INSERT mode, we call this procedure from
  #  popaced2, for each of the record in the INSERT status.
  #
  ##########################################################################*/

  PROCEDURE  poglded2_check_new_aqui(retcode IN OUT NOCOPY NUMBER) AS

    CURSOR Cur_po_cost_mst IS
      SELECT  cmpntcls_id , analysis_code
        FROM  po_cost_mst
       WHERE aqui_cost_id = GML_PO_GLDIST.P_aqui_cost_id;

    CURSOR Cur_get_aqui_costs  IS
      SELECT  aqui_cost_id , cost_amount , incl_ind, delete_mark
        FROM  po_cost_dtl
       WHERE  doc_type = GML_PO_GLDIST.P_doc_type and
              pos_id = GML_PO_GLDIST.P_pos_id and
              line_id = GML_PO_GLDIST.P_line_id;

    X_aqui_row_num     NUMBER;
    X_no_acqui_titles  NUMBER;
    X_row_num          NUMBER;
    X_status           NUMBER;

  X_gltitles1          t_gltitlestable;

  X_cmpntcls1          t_cmpntclstable;

  X_analysiscode1      t_analysiscodetable;

  BEGIN
    /*initialize X_aqui_row_num*/
    X_aqui_row_num := 0;
    /* Sandeep. 11.Nov.98. This procedure modified to delete the existing aqui*/
    /* rows and re-post the same in Update mode.*/
    GML_PO_GLDIST.delete_aqui_costs;

    FOR Rec IN Cur_get_aqui_costs LOOP
      GML_PO_GLDIST.P_amount_trans         :=  0;
      GML_PO_GLDIST.P_amount_base          :=  0;
      GML_PO_GLDIST.P_amount_trans_aqui    :=  0;
      GML_PO_GLDIST.P_amount_base_aqui     :=  0;

      GML_PO_GLDIST.P_aqui_cost_id := Rec.aqui_cost_id;
      GML_PO_GLDIST.P_cost_amount  := Rec.cost_amount;
      GML_PO_GLDIST.P_incl_ind     := Rec.incl_ind;
      /*Sandeep. 11.Nov.98. Added an extra column.*/
      GML_PO_GLDIST.P_delete_mark  := Rec.delete_mark;

      GML_PO_GLDIST.P_aqui_cmpntcls_id     := 0;

    OPEN    Cur_po_cost_mst;
    FETCH  Cur_po_cost_mst INTO  GML_PO_GLDIST.P_aqui_cmpntcls_id,GML_PO_GLDIST.P_aqui_analysis_code;
    IF  Cur_po_cost_mst%NOTFOUND THEN
      CLOSE Cur_po_cost_mst;
    ELSE
      CLOSE Cur_po_cost_mst;
      GML_PO_GLDIST.load_acct_titles('AQUI',
                                     GML_PO_GLDIST.P_gl_item_id,
                                     GML_PO_GLDIST.P_co_code,
                                     GML_PO_GLDIST.P_non_inv_ind,
                                     GML_PO_GLDIST.P_to_whse,
                                     GML_PO_GLDIST.P_po_date,
                                     GML_PO_GLDIST.P_incl_ind,
                                     X_row_num,
                                     X_status,
				     X_gltitles1,
				     X_cmpntcls1,
                                     X_analysiscode1);
        FOR  i IN 1..X_row_num LOOP
          GML_PO_GLDIST.P_acct_ttl_num        := X_gltitles1(i);
          GML_PO_GLDIST.P_cost_cmpntcls_id    := X_cmpntcls1(i);
          GML_PO_GLDIST.P_cost_analysis_code  := X_analysiscode1(i);
          IF GML_PO_GLDIST.P_cost_cmpntcls_id = 0 THEN
            GML_PO_GLDIST.P_cost_cmpntcls_id := NULL;
          END IF;
          GML_PO_GLDIST.process_trans ('AQUI',retcode) ;
        END LOOP;
      END IF;
    END LOOP;
    /* Sandeep. 11.Nov.98. Change ends here.*/
      X_aqui_row_num  :=  0;
  END poglded2_check_new_aqui;

  /*##########################################################################
  # PROC
  #   delete_aqui_costs
  #
  # DESCRIPTION
  #   This Procedure deletes the existing Aquisition costs, when made a
  #   modification in the Query mode. In short, it would delete the existing
  #   Aquisition costs and re-post the data again.
  # HISTORY
  #   created by Sandeep 12.Oct.1998
  ##########################################################################*/

  PROCEDURE delete_aqui_costs IS
  BEGIN
    DELETE  FROM PO_DIST_DTL
       WHERE  nvl(aqui_cost_id,0)      > 0 and
              doc_id            = GML_PO_GLDIST.P_pos_id and
              line_id           = GML_PO_GLDIST.P_line_id and
              doc_type          = GML_PO_GLDIST.P_doc_type ;
  /*  FORMS_DDL ('COMMIT');*/
  END delete_aqui_costs;

  /*#############################################################
  # NAME
  #     get_orafin_sob
  # SYNOPSIS
  #     func   glcommon_get_orafin_sob
  #     V_co_code = company code for which set of books id is to be retrieved
  #     V_err_ind = If 1 display error messages
  # RETURNS
  #	 0   Success
  #	-1   Fiscal Policy not setup
  #	-2   set of books not defined for the co
  #     -3   DB error
  # DESCRIPTION
  #     This function will get set of books name for a co which is passed as
  #     input parameter. When ever a call is made to this procedure
  #     be sure that sob name(P_sobname), calendar_name, period type has to be
  #     copied back to  <block_name>.sob_name, <block_name>.calendar_name
  #     <block_name>.period_type.
  #
  # HISTORY
  # 11/23/98 T.Ricci Ported from glcommon.pll
  ##################################################################*/

  FUNCTION get_orafin_sob (V_co_code IN VARCHAR2, V_err_ind IN NUMBER)
           RETURN NUMBER IS
    X_syarg01	   DATE 	  DEFAULT NULL;		/* ST_DATE*/
    X_syarg02      DATE 	  DEFAULT NULL;		/* EN_DATE*/
    X_syarg03      VARCHAR2(30)	  DEFAULT NULL;		/* SOB_NAME*/
    X_syarg04	   NUMBER(15);				/* SOB_ID*/
    X_syarg05	   NUMBER(15)	  DEFAULT 0;		/* LAST_UDATED_BY*/
    X_syarg06	   VARCHAR2(15)	  DEFAULT NULL;		/* CURRENCY_CODE*/
    X_syarg07	   NUMBER(15)	  DEFAULT 0;		/* CHART_OF_ACCOUNTS_ID*/
    X_syarg08	   VARCHAR2(15)	  DEFAULT NULL;		/* PERIOD_SET_NAME*/
    X_syarg09	   VARCHAR2(1)	  DEFAULT NULL;		/* SUSPENSE_ALLOWED_FLAG*/
    X_syarg10	   VARCHAR2(1)	  DEFAULT NULL;	   /* ALLOW_POSTING_WARNING_FLAG*/
    X_syarg11	   VARCHAR2(15)	  DEFAULT NULL;		/* ACCOUNTED_PERIOD_TYPE*/
    X_syarg12	   VARCHAR2(20)	  DEFAULT NULL;		/* SHORT_NAME*/
    X_syarg13	   VARCHAR2(1)	  DEFAULT NULL;	 /* REQUIRE_BUDGET_JOURNALS_FLAG*/
    X_syarg14	   VARCHAR2(1)	  DEFAULT NULL;	/* ENABLE_BUDGETARY_CONTROL_FLAG*/
    X_syarg15	   VARCHAR2(1)	  DEFAULT NULL;/* ALLOW_INTERCOMANY_POSTING_FLAG*/
    X_syarg16	   DATE           DEFAULT NULL;		/* CREATION_DATE*/
    X_syarg17      NUMBER(15)	  DEFAULT 0;		/* CREATION_BY*/
    X_syarg18      NUMBER(15)	  DEFAULT 0;		/* LAST_UPDATE_LOGIN*/
    X_syarg19	   NUMBER(15)	  DEFAULT 0;	/* LATEST_ENCUMBERANCE_YEAR*/
    X_syarg20	   VARCHAR2(15)	  DEFAULT NULL;	/* EARLIEST_UNTRANS_PERIOD_NAME*/
    X_syarg21	   NUMBER(15)	  DEFAULT 0;	/* CUM_TRANS_CODE_COMBINATION_ID*/
    X_syarg22	   NUMBER(15)	  DEFAULT 0;   /* FUTURE_ENTERABLE_PERIODS_LIMIT*/
    X_syarg23	   VARCHAR2(15)	  DEFAULT NULL;	    /* LATEST_OPENED_PERIOD_NAME*/
    X_syarg24	   NUMBER(15)	  DEFAULT 0;    /* RET_EARN_CODE_COMBINATION_ID*/
    X_syarg25	   NUMBER(15)	  DEFAULT 0;   /* RES_ENCUMB_CODE_COMBINATION_ID*/
    X_syarg26	   NUMBER(15)	  DEFAULT 0;		/* ROW_TO_FETCH*/
    X_syarg27	   NUMBER(15)	  DEFAULT 0;		/* ERROR_STATUS   */
    X_rvar         NUMBER(10)     DEFAULT 0;


    CURSOR Cur_gl_plcy_mstc1 IS
      SELECT set_of_books_name
      FROM   gl_plcy_mst
      WHERE  co_code = V_co_code;
  BEGIN
  /* Select set of books name from fiscal policy.*/
  /*This function will be called from short_name procedure.*/

    IF V_co_code IS NOT NULL THEN
      OPEN Cur_gl_plcy_mstc1;
      FETCH Cur_gl_plcy_mstc1 INTO P_sobname;
      IF Cur_gl_plcy_mstc1%NOTFOUND THEN
        CLOSE Cur_gl_plcy_mstc1;
        RETURN (-1);
      END IF;
      IF Cur_gl_plcy_mstc1%ISOPEN THEN
        CLOSE Cur_gl_plcy_mstc1;
      END IF;
      IF P_sobname IS NULL THEN
        RETURN (-2);
      END IF;
    END IF;

    /* Get calendar name and period type for the set of books.*/

    X_syarg03 := P_sobname;
    X_syarg04 := NULL;
    X_syarg26 := 1;
    X_syarg27 := 0;
    gmf_gl_get_sob_det.proc_gl_get_sob_det (X_syarg01,X_syarg02,X_syarg03,
                                            X_syarg04,X_syarg05,X_syarg06,
                                            X_syarg07,X_syarg08,X_syarg09,
                                            X_syarg10,X_syarg11,X_syarg12,
                                            X_syarg13,X_syarg14,X_syarg15,
                                            X_syarg16,X_syarg17,X_syarg18,
                                            X_syarg19,X_syarg20,X_syarg21,
                                            X_syarg22,X_syarg23,X_syarg24,
                                            X_syarg25,X_syarg26,X_syarg27);

    X_rvar := X_syarg27;
    IF (X_syarg27 <> 0) THEN
      return -3;
    END IF;

    P_calendar_name := X_syarg08;
    P_period_type   := X_syarg11;
    RETURN(0);
  END get_orafin_sob;

  /*#############################################################
  # FUNCTION
  #     get_ofperiod_info
  # SYNOPSIS
  #     func   get_ofperiod_info
  # RETURNS
  #	field number of failed field - failure
  #	0 - success
  # GLOBAL VARIABLES
  #	workfield1 -  periodname
  #     workfield2 -  periodstatus
  #     workfield3 -  periodnumber
  #     workfield4 -  quarternum
  #     workfield5 -  description
  #     workfield6 -  statuscode
  #     workdated1 -  period_start_date
  #	workdated2 -  period_end_date
  # DESCRIPTION
  #     This procedure is to fetch Oracle financials GL data
  #     related to fiscal year.
  #     Before making call to this procedure be sure that sob name
  #     has to populated by the call glcommon_get_orafin_sob.
  #     when ever a call is made to this procedure be sure to copy the
  #     following variables.
  #  P_periodname        to <block_name>.periodname
  #  P_periodstatus      to <block_name>.periodstatus
  #  P_periodnumber      to <block_name>.periodnumber
  #  P_quarternum        to <block_name>.quarternum
  #  P_fiscal_year_desc  to <block_name>.fiscal_year_desc
  #  P_statuscode        to <block_name>.statuscode
  #  P_period_start_date to <block_name>.period_start_date
  #  P_period_end_date   to <block_name>.period_end_date
  #
  # HISTORY
  # 11/23/98 T.Ricci Ported from glcommon.pll
  ############################################################### */

  FUNCTION get_ofperiod_info(V_co_code IN VARCHAR2, V_err_ind IN NUMBER,
                             V_sobname VARCHAR2, V_calendar_name VARCHAR2,
                             V_period_type VARCHAR2, V_gl_period NUMBER,
		             V_fiscal_year NUMBER, V_gl_date DATE DEFAULT NULL)
                             RETURN NUMBER IS
    X_retvar	NUMBER	DEFAULT 0;

    /* Definition for the variables used in call to stored procedure*/
    /* named gmf_gl_get_period_info.gl_get_period_info*/
    X_syarg01	VARCHAR2(15);	/* CALENDARNAME*/
    X_syarg02	VARCHAR2(15);	/* PERIODTYPE*/
    X_syarg03	DATE;		/* DATEINPERIOD*/
    X_syarg04	VARCHAR2(30);	/* SOBNAME*/
    X_syarg05	VARCHAR2(2);	/* APPABBR*/
    X_syarg06	VARCHAR2(30);	/* PERIODNAME*/
    X_syarg07	VARCHAR2(1);	/* PERIODSTATUS*/
    X_syarg08	NUMBER;		/* PERIODYEAR*/
    X_syarg09	NUMBER;		/* PERIODNUMBER*/
    X_syarg10	NUMBER;		/* QUARTERNUM*/
    X_syarg11	VARCHAR2(240);	/* DESCRIPTION*/
    X_syarg12	NUMBER	DEFAULT 0;	/* STATUSCODE*/
    X_syarg13	NUMBER;		/* ROWTOFETCH*/
    X_syarg14	DATE;		/* PERIOD_START_DATE*/
    X_syarg15	DATE;		/* PERIOD_END_DATE*/

  BEGIN
    X_syarg01 := V_calendar_name;
    X_syarg02 := V_period_type;
    X_syarg04 := V_sobname;
    X_syarg05 := 'gl';
    IF V_fiscal_year IS NULL THEN
      X_syarg08 := NULL;
    ELSE
      X_syarg08 := V_fiscal_year;
    END IF;
    IF V_gl_period IS NULL THEN
      X_syarg09 := NULL;
    ELSE
      X_syarg09 := V_gl_period;
    END IF;
    IF V_gl_date is NULL then
      X_syarg03 := NULL;
    ELSE
      X_syarg03 := V_gl_date;
    END IF;
    X_syarg13 := 1;
    X_syarg12 := 0;
    gmf_gl_get_period_info.gl_get_period_info(X_syarg01,X_syarg02,X_syarg03,X_syarg04,
		   	 	       X_syarg05,X_syarg06,X_syarg07,X_syarg08,
				       X_syarg09,X_syarg10,X_syarg11,X_syarg12,
				       X_syarg13,X_syarg14,X_syarg15);
    IF X_syarg12 IS NULL THEN
      X_syarg12 := 0;
    END IF;

    IF X_syarg12 < 0 THEN
      RETURN (-1);
    END IF;

    P_periodname        := X_syarg06;
    P_periodstatus      := X_syarg07;
    P_periodyear	:= X_syarg08;
    P_periodnumber      := X_syarg09;
    P_quarternum        := X_syarg10;
    P_fiscal_year_desc  := X_syarg11;
    P_statuscode        := X_syarg12;
    P_period_start_date := X_syarg14;
    P_period_end_date   := X_syarg15;

    IF X_syarg12 = 100 THEN
      RETURN (-1);
    END IF;
    /* Since Data Type is set to Datetime, here statements are required
       to convert into DD-MON-YYYY HH24:MM:SS format. */
    /* Map the period status from OF to gemms*/
    IF ((P_periodstatus = 'F')  OR
        (P_periodstatus = 'N')) THEN
      P_periodstatus := '1';
    ELSIF P_periodstatus = 'O' THEN
      P_periodstatus := '2';
    ELSIF P_periodstatus = 'C' THEN
      P_periodstatus := '3';
    ELSE
      P_periodstatus := '4';
    END IF;

    RETURN (0);
  END get_ofperiod_info;



/*Bug# 1324319      Added code to pass the AAP and PPV accts generated at the OPM side
over to the APPS side.*/


/******************************************************************************
*  FUNCTION
*     get_combination_id
* SYNOPSIS
*     proc   get_combination_id
* RETURNS
*	returns the combination id for an account and accounting unit passed.
* GLOBAL VARIABLES
*
*
* DESCRIPTION
*
*
* HISTORY
* 02/28/00 Preetam Bamb
*******************************************************************************/

 PROCEDURE combination_id(	v_co_code 		IN VARCHAR2,
 				v_acct_id 		IN NUMBER,
 				v_acctg_unit_id 	IN NUMBER,
   				v_combination_id 	IN OUT NOCOPY NUMBER) IS

 v_acctg_unit_no		gl_accu_mst.acctg_unit_no%TYPE 	:= NULL;
 v_acct_no			gl_acct_mst.acct_no%TYPE 	:= NULL;
 v_application_short_name	VARCHAR2(50);
 v_key_flex_code		VARCHAR2(50);
 v_chart_of_account_id		NUMBER;
 v_validation_date		DATE;
 v_segment_count		NUMBER;
 v_of_seg			fnd_flex_ext.SegmentArray;
 x				BOOLEAN;
 v_segment_delimiter            gl_plcy_mst.segment_delimiter%TYPE;


 Cursor get_chart_id is
  select chart_of_accounts_id
  from gl_plcy_mst,gl_sets_of_books
  where 	co_code = P_CO_CODE
  and 	name like set_of_books_name
  and 	set_of_books_id = sob_id;


 BEGIN

	SELECT acctg_unit_no INTO v_acctg_unit_no
	FROM gl_accu_mst WHERE acctg_unit_id = p_acctg_unit_id;

	SELECT acct_no INTO v_acct_no
	FROM gl_acct_mst
	WHERE acct_id = p_acct_id;

        /* SR dt 25-Jan-2001 B1530509 added select to get segment delimiter */

	SELECT segment_delimiter INTO v_segment_delimiter
	FROM  gl_plcy_mst
	WHERE co_code = p_co_code
	  AND delete_mark = 0;

	parse_account(	p_co_code ,
			v_acctg_unit_no ||v_segment_delimiter|| v_acct_no,
			2,0, v_of_seg, v_segment_count ) ;

				/* structure_no */
	Open get_chart_id;
	Fetch	get_chart_id into v_chart_of_account_id;
	Close get_chart_id;




	v_application_short_name 	:= 'SQLGL';
	v_key_flex_code			:= 'GL#';
	v_validation_date		:= SYSDATE;


	x := fnd_flex_ext.get_combination_id(	v_application_short_name,
						v_key_flex_code,
						v_chart_of_account_id,
       						v_validation_date,
       						v_segment_count,
       						v_of_seg,
       						v_combination_id );




 END combination_id;



 /******************************************************************************
 *  FUNCTION
 *    parse_account
 *  DESCRIPTION
 *    Parses the gemms account string and sorts the segment according
 *    to the order defined in Oracle financials. This is done in order
 *    to retrieve account balances from financial into gemms interface
 *	  table. This procedure does two jobs one parses gemms to financial
 *	  when v_gemms_acct is set to FALSE and parses financial segments to gemms
 *	  when v_gemms_acct is set to TRUE.
 *
 *   INPUT PARAMETERS
 *	  v_account    = Account string to be parsed
 *	  v_type       = 0 Parses Account unit segments
 *	               = 1 Parses Account Segments
 *		       = 2 Parses both Account unit and Account segments
 *	  v_offset     = Offset value.
 *
 *    OUTPUT PARAMETERS
 *     GLOBAL
 *
 *  RETURNS
 *
 *
 *  HISTORY
 *  Dt 25-JAN-2001 Sukarna Reddy B1530509 Modified parse account To store segments
 *  in an array and discard considering Length of each segment while parsing.
 *  Piyush K. Mishra 17-May-2002 Bug#2376340
 *  Changed the query for cursor cur_plcy_seg to pick the proper segment number, even
 *  if the accounting flexfield segments are assigned to different segment columns in
 *  OPM and GL. Select clause and order by clause has been changed.
 ******************************************************************************/

  PROCEDURE parse_account(	v_co_code IN VARCHAR2,
  				v_account IN VARCHAR2,
  				v_type IN NUMBER,
  				v_offset IN NUMBER,
  				v_segment IN OUT  NOCOPY fnd_flex_ext.SegmentArray,
  				V_no_of_seg IN OUT NOCOPY NUMBER )
  IS

    /*Begin Bug#2376340 Piyush K. Mishra
    Changed the cursor query.*/
    CURSOR cur_plcy_seg IS
      SELECT    p.type, p.length,
	        --nvl(substrb(f.application_column_name,8),0) segment_ref, (Commented and added following for B#2376340)
	        f.segment_num segment_ref,
		pm.segment_delimiter
	FROM	gl_plcy_seg p,
		gl_plcy_mst pm,
		fnd_id_flex_segments f,
		gl_sets_of_books s
       WHERE    p.co_code = v_co_code
	  AND	p.delete_mark = 0
	  AND	p.co_code = pm.co_code
	  AND	pm.sob_id = s.set_of_books_id
	  AND	s.chart_of_accounts_id = f.id_flex_num
	  AND	f.application_id = 101
	  AND 	f.id_flex_code = 'GL#'
	  AND	LOWER(f.segment_name)  = LOWER(p.short_name)
	  AND 	f.enabled_flag         = 'Y'
	ORDER BY p.segment_no;
      /*End Bug#2376340*/

    x_segment_index    NUMBER(10) DEFAULT 0;
    x_value            NUMBER(10);
    x_index            NUMBER(10);
    x_position         NUMBER(10) DEFAULT 1;
    x_length           NUMBER(10);
    x_result           VARCHAR2(255);
    x_gemms_acct       VARCHAR2(255);
    x_description      VARCHAR2(1000) default '';
    source_accounts    gmf_get_mappings.my_opm_seg_values;
  BEGIN
    /* B1530509 */
    source_accounts := gmf_get_mappings.get_opm_segment_values(v_account,v_co_code,2);

    FOR cur_plcy_seg_tmp IN cur_plcy_seg LOOP
      x_segment_index := x_segment_index + 1;
      IF (cur_plcy_seg_tmp.type = v_type or v_type = 2) THEN
        IF (cur_plcy_seg_tmp.segment_ref = 0) THEN
          x_value := x_segment_index;
        ELSE
          x_value := cur_plcy_seg_tmp.segment_ref;
        END IF;
        x_index  := x_value + v_offset;
       --  x_length := cur_plcy_seg_tmp.length;  /*B1530509 Commented */
        v_segment(x_index) := source_accounts(x_position);
         --SUBSTR(v_account,x_position,x_length);  /*B1530509  Commented*/
        x_position := x_position + 1;
      END IF;
    END LOOP;

    v_no_of_seg := x_segment_index;

  END parse_account;



/******************************************************************************
 * PROCEDURE
 *    	update_accounts_orcl
 * SYNOPSIS
 *    	proc   update_accounts_orcl
 * RETURNS
 *   	This procedure will update the ORacle Fianancial table
 *	po_distributions_all table with the correct accounts combination id
 *	for Purchase Price Varaince (PPV ) and Accrued Accounts Payable(AAP)
 * GLOBAL VARIABLES
 *
 *
 * DESCRIPTION
 *
 *
 * HISTORY
 *02/28/00 Preetam Bamb
 *04/12/00 nchekuri	Added Cursors inplace of direct select statements 'coz it was causing problems.
 *03/27/03 Bug 1994882 Get ccid if null value is passed.
 *******************************************************************************/

PROCEDURE update_accounts_orcl(	v_po_id		IN NUMBER,
  				v_line_id	IN NUMBER,
  				v_orgn_code	IN VARCHAR2,
  				v_acct_ttl_num	IN NUMBER,
  				v_combination_id IN NUMBER)
IS

v_po_header_id	NUMBER;
v_po_line_id	NUMBER;
v_po_line_location_id	NUMBER;
v_po_release_id	NUMBER;
x_combination_id	NUMBER;

   CURSOR  Cur_get_std_poinf IS
      SELECT   po_header_id,po_line_id,po_line_location_id
         FROM	cpg_oragems_mapping
      WHERE    po_id = v_po_id AND
			line_id = v_line_id;

   CURSOR  Cur_get_blk_poinf IS
      SELECT   po_header_id, po_line_id, po_line_location_id, po_release_id
	FROM	cpg_oragems_mapping
      WHERE 	po_id = v_po_id AND
			line_id = v_line_id;

   CURSOR  Cur_get_pln_poinf IS
      SELECT   po_header_id, po_line_id, po_line_location_id, po_release_id
	FROM	cpg_oragems_mapping
      WHERE 	po_id 	= v_po_id AND 	line_id = v_line_id;

   /* B1994882 */
   CURSOR cur_get_ccid(v_act_ttl_typ NUMBER,v_po_id NUMBER,v_line_id NUMBER) IS
   SELECT cc.code_combination_id
   FROM   gl_code_combinations_kfv cc,
          cpg_oragems_mapping map,
          gl_accu_mst acu,
          gl_acct_mst act,
          po_dist_dtl pdd,
          po_distributions_all pod,
          gl_plcy_mst gpm,
          gl_sets_of_books gsob
   WHERE map.po_id                 = v_po_id
   AND   map.line_id               = v_line_id
   AND   pod.po_header_id          = map.po_header_id
   AND   pod.po_line_id            = map.po_line_id
   AND   pod.line_location_id      = map.po_line_location_id
   AND   NVL(pod.po_release_id,-1) = NVL(map.po_release_id,-1)
   AND   map.po_id                 = pdd.doc_id
   AND   map.line_id               = pdd.line_id
   AND   pdd.acct_ttl_type         = v_act_ttl_typ
   AND   pdd.acctg_unit_id         = acu.acctg_unit_id
   AND   pdd.acct_id               = act.acct_id
   AND   cc.concatenated_segments  = acu.acctg_unit_no||gpm.SEGMENT_DELIMITER||act.acct_no
   AND   cc.chart_of_accounts_id   = gsob.CHART_OF_ACCOUNTS_ID
   AND   gsob.name                 = gpm.set_of_books_name
   AND   gsob.set_of_books_id      = gpm.sob_id
   AND   gpm.co_code               = pdd.co_code;

BEGIN

  /* B1994882 */
   x_combination_id := v_combination_id;
   IF x_combination_id is null THEN
      OPEN  cur_get_ccid(p_acct_ttl_num,v_po_id,v_line_id);
      FETCH cur_get_ccid INTO x_combination_id;
      CLOSE cur_get_ccid;
   END IF;

    if GML_PO_GLDIST.P_transaction_type  in ('STANDARD')
    then
	OPEN    Cur_get_std_poinf;
    	FETCH   Cur_get_std_poinf INTO  v_po_header_id, v_po_line_id,
		v_po_line_location_id;
 	IF Cur_get_std_poinf%FOUND  THEN

	   if p_acct_ttl_num = 6100
	   then
		update	po_distributions_all
		set 	variance_account_id 	= x_combination_id
		where 	po_header_id		= v_po_header_id
		and	po_line_id		= v_po_line_id
		and	line_location_id	= v_po_line_location_id;
	   end if;

	   if p_acct_ttl_num = 3100
	   then
		update	po_distributions_all
		set 	accrual_account_id 	= x_combination_id
		where 	po_header_id		= v_po_header_id
		and	po_line_id		= v_po_line_id
		and	line_location_id	= v_po_line_location_id;
	   end if;
        end if;
        CLOSE Cur_get_std_poinf;
    END IF;



    if GML_PO_GLDIST.P_transaction_type  in ('BLANKET')
    then
	OPEN    Cur_get_blk_poinf;
    	FETCH   Cur_get_blk_poinf INTO v_po_header_id, v_po_line_id,
			v_po_line_location_id, v_po_release_id;

 	IF Cur_get_blk_poinf%FOUND  THEN
	   if p_acct_ttl_num = 6100
	   then
		update	po_distributions_all
		set 	variance_account_id 	= x_combination_id
		where 	po_header_id		= v_po_header_id
		and	po_line_id		= v_po_line_id
		and	line_location_id	= v_po_line_location_id
		and 	po_release_id		= v_po_release_id;
	   end if;

	  if p_acct_ttl_num = 3100
	  then
		update	po_distributions_all
		set 	accrual_account_id 	= x_combination_id
		where 	po_header_id		= v_po_header_id
		and	po_line_id		= v_po_line_id
		and	line_location_id	= v_po_line_location_id
		and 	po_release_id	= v_po_release_id;
	  end if;
       end if;
       CLOSE Cur_get_blk_poinf;
    END IF;


   if GML_PO_GLDIST.P_transaction_type  in ('PLANNED')
   then

   /* In planned purchase order -- distributions are generated on the OPM side only when we create a
   release against it and in that case there use po_header_id,po_line_id,po_line_location_id and po_release_id
   from cpg_oragems_mapping for the corresponding po_id and line_id (and not bpo_id and bpo_line_id)
   */
	OPEN    Cur_get_pln_poinf;
    	FETCH   Cur_get_pln_poinf INTO v_po_header_id, v_po_line_id,
			v_po_line_location_id, v_po_release_id;

 	IF Cur_get_pln_poinf%FOUND  THEN
	  if p_acct_ttl_num = 6100
	  then
		update	po_distributions_all
		set 	variance_account_id 	= x_combination_id
		where 	po_header_id		= v_po_header_id
		and	po_line_id		= v_po_line_id
		and	line_location_id	= v_po_line_location_id
		and 	po_release_id		= v_po_release_id;
	  end if;

	  if p_acct_ttl_num = 3100
	  then
		update	po_distributions_all
		set 	accrual_account_id 	= x_combination_id
		where 	po_header_id		= v_po_header_id
		and	po_line_id		= v_po_line_id
		and	line_location_id	= v_po_line_location_id
		and 	po_release_id		= v_po_release_id;
	  end if;
       end if;
       CLOSE Cur_get_pln_poinf;
    END IF;
end update_accounts_orcl;

/*End Bug# 1324319      */



END GML_PO_GLDIST;

/
