--------------------------------------------------------
--  DDL for Package GML_PO_GLDIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PO_GLDIST" AUTHID CURRENT_USER AS
/* $Header: GMLDISTS.pls 115.9 2002/12/04 19:03:16 gmangari ship $ */

  FUNCTION  calc_dist_amount_aqui  RETURN NUMBER;
  PROCEDURE calc_dist_amount ;

  PROCEDURE  receive_data (V_doc_type  VARCHAR2, V_pos_id NUMBER,
                                    V_line_id  NUMBER, V_orgn_code  VARCHAR2,
                                    V_po_date  DATE, V_shipvend_id NUMBER,
                                    V_base_currency  VARCHAR2,
				    V_billing_currency  VARCHAR2,
                                    V_to_whse  VARCHAR2, V_line_no  NUMBER,
                                    V_item_no  VARCHAR2,
				    V_extended_price  NUMBER,
                                    V_project  VARCHAR2, V_order_qty1  NUMBER,
                                    V_order_um1 VARCHAR2, V_gl_item_id NUMBER,
                                    V_mul_div_sign  NUMBER,
				    V_exchange_rate  NUMBER,
                                    V_price NUMBER, V_action NUMBER,
				    V_single_aqui BOOLEAN,
				    retcode  IN OUT NOCOPY NUMBER,
				    V_transaction_type IN VARCHAR2);

   PROCEDURE process_trans (V_type VARCHAR2, retcode IN OUT NOCOPY NUMBER);
   FUNCTION  default_mapping RETURN NUMBER;
   FUNCTION  get_acctg_unit_no  RETURN VARCHAR2;
   PROCEDURE get_acct_no(V_acct_no OUT NOCOPY VARCHAR2, V_acct_desc OUT NOCOPY VARCHAR2);

   /* Constant values.*/
  GL$SE_NEW_RECV    NUMBER DEFAULT 10010;
  GL$AT_INV         NUMBER DEFAULT 1500;
  GL$AT_AAP         NUMBER DEFAULT 3100;  /* Batch Close Variance.*/
  GL$AT_PPV         NUMBER DEFAULT 6100;
  GL$AT_EXP         NUMBER DEFAULT 5100;
  GL$AT_AAC         NUMBER DEFAULT 3150;
  GL$AT_ACV         NUMBER DEFAULT 6150;
  GL$AT_ERV         NUMBER DEFAULT 5500;
  SY$DEFAULT_CURR   VARCHAR2(5) DEFAULT 'USD';  /* This has to be modified accordingly.*/



  /* Package Variables.*/
  P_row_num                 NUMBER;
  P_row_num_upd             NUMBER;
  P_aqui_analysis_code      VARCHAR2(5);
  P_aqui_cmpntcls_id        NUMBER;
  P_cost_amount             NUMBER;
  P_itemglclass             VARCHAR2(20);
  P_acctg_unit_id           NUMBER;
  P_base_currency           VARCHAR2(5);
  P_default_currency        VARCHAR2(5);
  P_billing_currency        VARCHAR2(5);
  P_mul_div_sign            VARCHAR2(5);
  P_exchange_rate           NUMBER;
  P_exch_date               DATE;
  P_line_no                 NUMBER;
  P_line_id                 NUMBER;
  P_non_inv_ind             NUMBER;
  P_gl_class                VARCHAR2(50);
  P_vend_gl_class           VARCHAR2(50);
  P_co_code                 VARCHAR2(6);
  P_whse_co_code            sy_orgn_mst.co_code%TYPE; /* RVK B1394532 */
  P_whse_orgn_code          sy_orgn_mst.orgn_code%TYPE; /* RVK B1394532 */
  P_cust_id                 NUMBER;
  P_reason_code             VARCHAR2(10);
  P_cust_gl_class           VARCHAR2(20);
  P_routing_id              NUMBER;
  P_charge_id               NUMBER;
  P_taxauth_id              NUMBER;
  P_aqui_cost_id            NUMBER ;
  P_resources               VARCHAR2(10);
  P_cost_cmpntcls_id        NUMBER;
  P_cost_analysis_code      VARCHAR2(5);
  P_order_type              VARCHAR2(5);
  P_sub_event_type          NUMBER(10) DEFAULT 10010;
  P_doc_type                VARCHAR2(5);
  P_pos_id                  NUMBER;
  P_orgn_code               VARCHAR2(4);
  P_po_date                 DATE;
  P_shipvend_id             NUMBER;
  P_to_whse                 VARCHAR2(5);
  P_item_no                 VARCHAR2(70);
  P_extended_price          NUMBER;
  P_project                 VARCHAR2(16) ;
  P_order_qty1              NUMBER;
  P_order_um1               VARCHAR2(10);
  P_gl_item_id              NUMBER(10);
  P_acct_id                 NUMBER (10);
  P_acctg_unit_no           VARCHAR2( 270);
  P_acct_no                 VARCHAR2(270);
  P_acct_desc               VARCHAR2(270);
  P_po_cost                 NUMBER;
  P_tmp_po_cost             NUMBER;
  P_tmp_amt                 NUMBER;
  P_tmp_amt2                NUMBER;
  P_amount_trans            NUMBER;
  P_amount_base             NUMBER;
  P_amount_trans_aqui       NUMBER;
  P_amount_base_aqui        NUMBER;
  P_acct_ttl_num            NUMBER;
  P_incl_ind                NUMBER;
  P_type                    VARCHAR2(10);
  P_fiscal_year             NUMBER;
  P_period                  NUMBER;
  P_gl_posted_ind           NUMBER;
  P_ledger_code             VARCHAR2(70);
  P_recv_seq_no             NUMBER;
  P_precision               NUMBER;
  P_action                  NUMBER;
  P_tot_amount_inv          NUMBER;
  P_tot_amount_aap          NUMBER;
  P_tot_amount_inv_aqui     NUMBER;
  P_tot_amount_aap_aqui     NUMBER;

/*Bug# 1324319      Added code to pass the AAP and PPV accts generated at the OPM side
over to the APPS side.Just added one paramerter passed to receive_data procedure.
P_transaction_type */

  P_transaction_type	    VARCHAR2(100);

  /* 11.Nov.98.. Added an extra variable for delete_mark.*/
  P_delete_mark             NUMBER DEFAULT 0;

  /* From glcommon.pll*/
    P_sobname           gl_plcy_mst.set_of_books_name%TYPE;
    P_periodname        VARCHAR2(15);
    P_periodstatus      VARCHAR2(1);
    P_periodyear	NUMBER(5);
    P_periodnumber      NUMBER(15);
    P_quarternum        NUMBER(15);
    P_fiscal_year_desc  VARCHAR2(240);
    P_statuscode        NUMBER(19);
    P_period_start_date DATE;
    P_period_end_date   DATE;
    P_calendar_name     VARCHAR2(15);
    P_period_type       VARCHAR2(15);

  FUNCTION get_exchg_rate(V_psource_type  NUMBER, V_po_date  DATE,
                          V_default_currency  VARCHAR2 ,
                          V_billing_currency  VARCHAR2 )  RETURN NUMBER;

  PROCEDURE set_data (retcode IN OUT NOCOPY NUMBER);

  PROCEDURE poglded2_check_new_aqui(retcode IN OUT NOCOPY NUMBER);

  TYPE t_gltitlestable IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

  v_gltitles          t_gltitlestable;

  TYPE t_cmpntclstable IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

  v_cmpntcls          t_cmpntclstable;

  TYPE t_analysiscodetable IS TABLE OF VARCHAR2(4)
       INDEX BY BINARY_INTEGER;

  v_analysiscode      t_analysiscodetable;

  PROCEDURE load_acct_titles(v_type         VARCHAR2,
                           v_item_id      NUMBER,
                           v_co_code      VARCHAR2,
                           v_non_inv_ind  NUMBER,
                           v_to_whse     IN VARCHAR2,
                           v_trans_date   IN DATE,
                           v_include_ind  IN NUMBER,
                           v_row_num      OUT NOCOPY NUMBER,
                           v_status       OUT NOCOPY NUMBER,
                           v_gltitles OUT NOCOPY t_gltitlestable,
                           v_cmpntcls OUT NOCOPY t_cmpntclstable,
                           v_analysiscode OUT NOCOPY t_analysiscodetable);


  PROCEDURE delete_aqui_costs;


  /* From glcommon.pll*/
  FUNCTION get_orafin_sob (V_co_code IN VARCHAR2, V_err_ind IN NUMBER )
           RETURN NUMBER;
  FUNCTION get_ofperiod_info(V_co_code IN VARCHAR2, V_err_ind IN NUMBER,
           V_sobname VARCHAR2, V_calendar_name VARCHAR2,V_period_type VARCHAR2,
           V_gl_period NUMBER,V_fiscal_year NUMBER,V_gl_date DATE DEFAULT NULL)
           RETURN NUMBER;

/*Bug# 1324319      Added code to pass the AAP and PPV accts generated at the OPM side
over to the APPS side.Just added one paramerter passed to receive_data procedure.
P_transaction_type */
   TYPE A_segment IS TABLE OF VARCHAR(200) INDEX BY BINARY_INTEGER;

  PROCEDURE combination_id(	v_co_code 		IN VARCHAR2,
 				v_acct_id 		IN NUMBER,
 				v_acctg_unit_id 	IN NUMBER,
   				v_combination_id 	IN OUT NOCOPY NUMBER);


  PROCEDURE parse_account(	v_co_code IN VARCHAR2,
  				v_account IN VARCHAR2,
  				v_type IN NUMBER,
  				v_offset IN NUMBER,
  				v_segment IN OUT  NOCOPY fnd_flex_ext.SegmentArray,
  				V_no_of_seg IN OUT NOCOPY NUMBER );


/*Procedure to update the combination id on the apps side in the table PO_DISTRIBUTIONS_ALL */
  PROCEDURE update_accounts_orcl(v_po_id	IN NUMBER,
  				 v_line_id	IN NUMBER,
  				 v_orgn_code	IN VARCHAR2,
  				 v_acct_ttl_num	IN NUMBER,
  				 v_combination_id IN NUMBER);

/*End 1324319 */

END GML_PO_GLDIST;

 

/
