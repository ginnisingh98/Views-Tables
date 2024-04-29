--------------------------------------------------------
--  DDL for Package PA_MC_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MC_CURRENCY_PKG" AUTHID CURRENT_USER AS
--$Header: PAXMCURS.pls 120.3 2005/08/11 11:35:51 eyefimov noship $
    FunctionalCurrency  fnd_currencies.currency_code%TYPE;

    Invoice_Action    Varchar2(15) := NULL;
    -- Updated by PAIGEN at CANCEL time with value CANCEL.

        /* Global Record and Table Definitions */

        TYPE rsob IS RECORD
        (rsob_id        gl_alc_ledger_rships_v.ledger_id%TYPE,
         rcurrency_code gl_alc_ledger_rships_v.currency_code%TYPE);

        TYPE rsob_tab IS TABLE OF rsob
         INDEX BY BINARY_INTEGER;

        g_rsob_tab  rsob_tab;

        /* Type of message */
        LOG NUMBER := 1;
        DEBUG NUMBER := 2;

FUNCTION CurrRound( x_amount        IN NUMBER ,
                    x_currency_code IN VARCHAR2 := FunctionalCurrency )
           RETURN NUMBER;

    PRAGMA RESTRICT_REFERENCES( CurrRound, WNPS,WNDS );

FUNCTION  functional_currency(x_org_id IN NUMBER) RETURN VARCHAR2;
--    PRAGMA RESTRICT_REFERENCES( functional_currency, WNPS,WNDS );

FUNCTION  set_of_books(x_org_id IN NUMBER) RETURN NUMBER;
--    PRAGMA RESTRICT_REFERENCES( set_of_books, WNPS,WNDS );

FUNCTION  set_of_books RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( set_of_books, WNPS,WNDS );

FUNCTION  get_mrc_sob_type_code( x_set_of_books_id IN NUMBER )
				RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES( get_mrc_sob_type_code, WNPS,WNDS );

FUNCTION  get_mrc_sob_type_code RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES( get_mrc_sob_type_code, WNPS,WNDS );

PROCEDURE eiid_details( x_eiid          IN  NUMBER,
                        x_orig_trx      OUT NOCOPY VARCHAR2,
                        x_adj_item      OUT NOCOPY NUMBER,
                        x_linkage       OUT NOCOPY VARCHAR2,
                        x_ei_date       OUT NOCOPY DATE,
--Bug#1078399
--New parameter x_txn_source added in eiid_details() - to be used to
--check whether the EI is an imported-one or not.
			            x_txn_source 	OUT	NOCOPY VARCHAR2,
                        x_err_stack     IN OUT NOCOPY VARCHAR2,
                        x_err_stage     IN OUT NOCOPY VARCHAR2,
                        x_err_code      OUT NOCOPY NUMBER);

PROCEDURE eiid_details( x_eiid          IN  NUMBER,
                        x_orig_trx      OUT NOCOPY VARCHAR2,
                        x_adj_item      OUT NOCOPY NUMBER,
                        x_linkage       OUT NOCOPY VARCHAR2,
                        x_ei_date       OUT NOCOPY DATE,
                        x_err_stack     IN OUT NOCOPY VARCHAR2,
                        x_err_stage     IN OUT NOCOPY VARCHAR2,
                        x_err_code      OUT NOCOPY NUMBER);

FUNCTION  max_cost_line( x_eiid  IN NUMBER,
                         x_sob   IN NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( max_cost_line, WNPS,WNDS );

FUNCTION  max_rev_line(x_eiid  IN NUMBER,
                       x_sob   IN NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( max_rev_line, WNPS,WNDS );

PROCEDURE get_orig_cost_rates( x_adj_item            IN NUMBER,
                               x_line_num            IN NUMBER,
                               x_set_of_books_id     IN NUMBER,
                               x_exchange_rate       OUT NOCOPY NUMBER,
                               x_exchange_date       OUT NOCOPY DATE,
                               x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                               x_err_stack           IN OUT NOCOPY VARCHAR2,
                               x_err_stage           IN OUT NOCOPY VARCHAR2,
                               x_err_code            OUT NOCOPY NUMBER);

PROCEDURE get_orig_ei_cost_rates( x_exp_item_id      IN NUMBER,
                               x_set_of_books_id     IN NUMBER,
                               x_exchange_rate       OUT NOCOPY NUMBER,
                               x_exchange_date       OUT NOCOPY DATE,
                               x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                               x_err_stack           IN OUT NOCOPY VARCHAR2,
                               x_err_stage           IN OUT NOCOPY VARCHAR2,
                               x_err_code            OUT NOCOPY NUMBER);

PROCEDURE get_cost_amts(x_exp_item_id         IN NUMBER,
                        x_set_of_books_id     IN NUMBER,
                        x_line_num            IN NUMBER,
                        x_amount              OUT NOCOPY NUMBER,
                        x_quantity            OUT NOCOPY NUMBER,
			            x_exchange_rate	      OUT NOCOPY NUMBER,
                        x_exchange_date       OUT NOCOPY DATE,
                        x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                        x_err_stack           IN OUT NOCOPY VARCHAR2,
                        x_err_stage           IN OUT NOCOPY VARCHAR2,
                        x_err_code            OUT NOCOPY NUMBER);

PROCEDURE get_max_cost_amts(x_exp_item_id         IN NUMBER,
                            x_set_of_books_id     IN NUMBER,
                            x_raw_cost            OUT NOCOPY NUMBER,
                            x_burdened_cost       OUT NOCOPY NUMBER,
                            x_exchange_rate       OUT NOCOPY NUMBER,
                            x_exchange_date       OUT NOCOPY DATE,
                            x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                            x_err_stack           IN OUT NOCOPY VARCHAR2,
                            x_err_stage           IN OUT NOCOPY VARCHAR2,
                            x_err_code            OUT NOCOPY NUMBER);

PROCEDURE get_max_crdl_amts(x_exp_item_id         IN NUMBER,
                            x_set_of_books_id     IN NUMBER,
                            x_revenue             OUT NOCOPY NUMBER,
                            x_bill_amount         OUT NOCOPY NUMBER,
                            x_exchange_rate       OUT NOCOPY NUMBER,
                            x_err_stack           IN OUT NOCOPY VARCHAR2,
                            x_err_stage           IN OUT NOCOPY VARCHAR2,
                            x_err_code            OUT NOCOPY NUMBER);


PROCEDURE get_orig_rev_rates( x_adj_item             IN NUMBER,
                              x_line_num             IN NUMBER,
                              x_set_of_books_id      IN NUMBER,
                              x_exchange_rate        OUT NOCOPY NUMBER,
                              x_exchange_date        OUT NOCOPY DATE,
                              x_exchange_rate_type   OUT NOCOPY VARCHAR2,
                              x_err_stack            IN OUT NOCOPY VARCHAR2,
                              x_err_stage            IN OUT NOCOPY VARCHAR2,
                              x_err_code             OUT NOCOPY NUMBER);

PROCEDURE get_orig_ei_mc_rates( x_adj_exp_item_id    IN NUMBER,
                                x_xfer_exp_item_id   IN NUMBER,
                                x_set_of_books_id    IN NUMBER,
                                x_raw_cost           OUT NOCOPY NUMBER,
                                x_raw_cost_rate      OUT NOCOPY NUMBER,
                                x_burden_cost        OUT NOCOPY NUMBER,
                                x_burden_cost_rate   OUT NOCOPY NUMBER,
                                x_bill_amount        OUT NOCOPY NUMBER,
                                x_bill_rate          OUT NOCOPY NUMBER,
                                x_accrued_revenue    OUT NOCOPY NUMBER,
                                x_accrual_rate       OUT NOCOPY NUMBER,
				                x_transfer_price     OUT NOCOPY NUMBER,
                                x_adjusted_rate      OUT NOCOPY NUMBER,
                                x_exchange_rate      OUT NOCOPY NUMBER,
                                x_exchange_date      OUT NOCOPY DATE,
                                x_exchange_rate_type OUT NOCOPY VARCHAR2,
                                x_err_stack          IN OUT NOCOPY VARCHAR2,
                                x_err_stage          IN OUT NOCOPY VARCHAR2,
                                x_err_code           OUT NOCOPY NUMBER);

--Overloaded procedure

PROCEDURE get_orig_ei_mc_rates( x_adj_exp_item_id    IN NUMBER,
                                x_xfer_exp_item_id   IN NUMBER,
                                x_set_of_books_id    IN NUMBER,
                                x_raw_cost           OUT NOCOPY NUMBER,
                                x_raw_cost_rate      OUT NOCOPY NUMBER,
                                x_burden_cost        OUT NOCOPY NUMBER,
                                x_burden_cost_rate   OUT NOCOPY NUMBER,
                                x_bill_amount        OUT NOCOPY NUMBER,
                                x_bill_rate          OUT NOCOPY NUMBER,
                                x_accrued_revenue    OUT NOCOPY NUMBER,
                                x_accrual_rate       OUT NOCOPY NUMBER,
				                x_transfer_price     OUT NOCOPY NUMBER,
                                x_adjusted_rate      OUT NOCOPY NUMBER,
                                x_exchange_rate      OUT NOCOPY NUMBER,
                                x_exchange_date      OUT NOCOPY DATE,
                                x_exchange_rate_type OUT NOCOPY VARCHAR2,
				                x_raw_revenue        OUT NOCOPY NUMBER,/*3024103*/
				                x_adj_revenue	     OUT NOCOPY NUMBER,/*3024103*/
				                x_forecast_revenue   OUT NOCOPY NUMBER,/*3024103*/
                                x_err_stack          IN OUT NOCOPY VARCHAR2,
                                x_err_stage          IN OUT NOCOPY VARCHAR2,
                                x_err_code           OUT NOCOPY NUMBER);

PROCEDURE get_orig_event_amts(  x_project_id         IN NUMBER,
                                x_event_num          IN NUMBER,
                                x_task_id            IN NUMBER,
                                x_set_of_books_id    IN NUMBER,
                                x_bill_amount        OUT NOCOPY NUMBER,
                                x_revenue_amount     OUT NOCOPY NUMBER,
                                x_rev_rate_type      OUT NOCOPY VARCHAR2,
                                x_rev_exchange_rate  OUT NOCOPY NUMBER,
                                x_rev_exchange_date  OUT NOCOPY DATE,
                                x_inv_exchange_rate  OUT NOCOPY NUMBER,
                                x_inv_exchange_date  OUT NOCOPY DATE,
                                x_err_stack          IN OUT NOCOPY VARCHAR2,
                                x_err_stage          IN OUT NOCOPY VARCHAR2,
                                x_err_code           OUT NOCOPY NUMBER);


PROCEDURE get_imported_rates( x_set_of_books_id      IN NUMBER,
                              x_exp_item_id          IN NUMBER,
                              x_raw_cost             OUT NOCOPY NUMBER,
                              x_raw_cost_rate        OUT NOCOPY NUMBER,
                              x_burden_cost          OUT NOCOPY NUMBER,
                              x_burden_cost_rate     OUT NOCOPY NUMBER,
                              x_exchange_rate        OUT NOCOPY NUMBER,
                              x_exchange_date        OUT NOCOPY DATE,
                              x_exchange_rate_type   OUT NOCOPY VARCHAR2,
                              x_err_stack            IN OUT NOCOPY VARCHAR2,
                              x_err_stage            IN OUT NOCOPY VARCHAR2,
                              x_err_code             OUT NOCOPY NUMBER);


PROCEDURE get_ap_keys( x_eiid          IN NUMBER,
                       x_ref2          OUT NOCOPY VARCHAR2,
                       x_ref3          OUT NOCOPY VARCHAR2,
                       x_err_stack     IN OUT NOCOPY VARCHAR2,
                       x_err_stage     IN OUT NOCOPY VARCHAR2,
                       x_err_code      OUT NOCOPY NUMBER);

/* added two IN parameters to get_ap_rate, system_reference4 and transaction_source
   for AP Variance processing*/

PROCEDURE get_ap_rate( x_invoice_id          IN NUMBER,
                       x_line_num            IN NUMBER,
                       x_system_reference4   IN VARCHAR2 DEFAULT NULL,
                       x_transaction_source  IN VARCHAR2 DEFAULT NULL,
                       x_sob                 IN NUMBER,
                       x_exchange_rate       OUT NOCOPY NUMBER,
                       x_exchange_date       OUT NOCOPY DATE,
                       x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                       x_amount              OUT NOCOPY NUMBER,
                       x_err_stack           IN OUT NOCOPY VARCHAR2,
                       x_err_stage           IN OUT NOCOPY VARCHAR2,
                       x_err_code            OUT NOCOPY NUMBER);

FUNCTION sum_rev_rdl( x_project_id     IN  NUMBER,
                      x_dr_num         IN  NUMBER,
                      x_sob            IN  NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( sum_rev_rdl, WNPS,WNDS );

FUNCTION sum_inv( x_project_id    IN  NUMBER,
                  x_di_num        IN  NUMBER,
                  x_line_num      IN  NUMBER,
                  x_sob           IN  NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( sum_inv, WNPS,WNDS );

FUNCTION sum_inv_rdl( x_project_id  IN   NUMBER,
                      x_di_num      IN   NUMBER,
                      x_line_num    IN   NUMBER,
                      x_sob         IN   NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( sum_inv_rdl, WNPS,WNDS );

FUNCTION sum_inv_erdl( x_project_id IN   NUMBER,
                       x_di_num     IN   NUMBER,
                       x_line_num   IN   NUMBER,
                       x_sob        IN   NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( sum_inv_erdl, WNPS,WNDS );

FUNCTION sum_inv_ev( x_project_id   IN   NUMBER,
                     x_task_id      IN   NUMBER,
                     x_event_num    IN   NUMBER,
                     x_sob          IN   NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( sum_inv_ev, WNPS,WNDS );

FUNCTION sum_mc_cust_rdl_erdl( x_project_id                   IN   NUMBER,
                               x_draft_revenue_num            IN   NUMBER,
                               x_draft_revenue_item_line_num  IN   NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( sum_mc_cust_rdl_erdl, WNPS,WNDS );

FUNCTION event_date( x_project_id   IN   NUMBER,
                     x_task_id      IN   NUMBER,
                     x_event_Num    IN   NUMBER) RETURN DATE;
    PRAGMA RESTRICT_REFERENCES( event_date, WNPS,WNDS );

FUNCTION orgid(  x_project_id       IN   NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( orgid, WNPS,WNDS );

FUNCTION get_wo_factor(x_project_id IN NUMBER,
                       x_di_num     IN NUMBER,
                       x_di_num_org IN NUMBER ) RETURN NUMBER;

FUNCTION get_cancel_flag( x_project_id IN   NUMBER,
                          x_di_num     IN   NUMBER ) RETURN VARCHAR2;

FUNCTION get_invoice_action RETURN VARCHAR2;

FUNCTION get_rtn_amount( x_project_id   IN  NUMBER,
                         x_di_num       IN  NUMBER,
                         x_rtn_pcnt     IN  NUMBER,
                         x_sob_id       IN  NUMBER ) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES( get_rtn_amount , WNPS,WNDS );


PROCEDURE raise_error(x_msg        IN VARCHAR2,
                      x_module     IN VARCHAR2,
                      x_currency   IN VARCHAR2 default NULL );

/*------------------------------ ins_mc_txn_interface_all ----------------------*/
/* This procedure will populate the Pa_mc_txn_interface_all table for a invoice */
/* distribution line pulled over from AP . First it will look for the data in   */
/* the AP MRC sub-table otherwise it will get the rates from GL based on the    */
/* Invoice Date and compute the amounts and populate the pa_mc_txn_interface_all*/
/* table                                                                        */
/*------------------------------------------------------------------------------*/

/* Changed the IN parameter names  and local variables
  from p_vendor_id to p_system_reference1,
   p_invoice_id         to p_system_reference2,
   p_dist_line_num      to p_system_reference3,
   p_invoice_payment_id to p_system_reference4
*/

/*
PROCEDURE ins_mc_txn_interface_all(

   p_vendor_id           IN      NUMBER,
   p_invoice_id          IN      NUMBER,
   p_dist_line_num       IN      NUMBER,
   p_interface_id        IN      NUMBER,
   p_transaction_source  IN      VARCHAR2,
   p_invoice_payment_id  IN      NUMBER DEFAULT NULL);
*/

PROCEDURE ins_mc_txn_interface_all(
   p_system_reference1   IN      NUMBER,
   p_system_reference2   IN      NUMBER,
   p_system_reference3   IN      NUMBER,
   p_system_reference4   IN      VARCHAR2 DEFAULT NULL,
   p_interface_id        IN      NUMBER,
   p_transaction_source  IN      VARCHAR2,
   p_acct_evt_id         IN      NUMBER DEFAULT NULL); --pricing changes, added param p_acct_evt_id

PROCEDURE get_ccdl_tp_amts( x_exp_item_id         IN NUMBER,
                            x_set_of_books_id     IN NUMBER,
                            x_transfer_price      OUT NOCOPY NUMBER,
                            x_tp_exchange_rate    OUT NOCOPY NUMBER,
                            x_tp_exchange_date    OUT NOCOPY DATE,
                            x_tp_rate_type        OUT NOCOPY VARCHAR2,
                            x_err_stack           IN OUT NOCOPY VARCHAR2,
                            x_err_stage           IN OUT NOCOPY VARCHAR2,
                            x_err_code            OUT NOCOPY NUMBER);

PROCEDURE get_invdtl_tp_amts( x_exp_item_id       IN NUMBER,
                            x_set_of_books_id     IN NUMBER,
                            x_transfer_price      OUT NOCOPY NUMBER,
                            x_tp_exchange_rate    OUT NOCOPY NUMBER,
                            x_tp_exchange_date    OUT NOCOPY DATE,
                            x_tp_rate_type        OUT NOCOPY VARCHAR2,
                            x_err_stack           IN OUT NOCOPY VARCHAR2,
                            x_err_stage           IN OUT NOCOPY VARCHAR2,
                            x_err_code            OUT NOCOPY NUMBER);


PROCEDURE get_po_rate( x_po_dist_id          IN NUMBER,
                       x_rcv_txn_id          IN VARCHAR2,
                       x_transaction_source  IN VARCHAR2,
                       x_sob                 IN NUMBER,
                       x_exchange_rate       OUT NOCOPY NUMBER,
                       x_exchange_date       OUT NOCOPY DATE,
                       x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                       x_amount              OUT NOCOPY NUMBER,
                       x_err_stack           IN OUT NOCOPY VARCHAR2,
                       x_err_stage           IN OUT NOCOPY VARCHAR2,
                       x_err_code            OUT NOCOPY NUMBER,
		               x_acct_evt_id         IN NUMBER DEFAULT NULL); --pricing changes, added param p_acct_evt_id

   G_PREV_ORG_ID  NUMBER(15);
   G_PREV_CURRENCY VARCHAR2(30);
   G_PREV_ORG_ID2 NUMBER(15);
   G_PREV_SOB_ID  NUMBER(15);

--Introduced for Re-Burdening process.

PROCEDURE eiid_details( x_eiid              IN  NUMBER,
                        x_orig_trx          OUT NOCOPY VARCHAR2,
                        x_adj_item          OUT NOCOPY NUMBER,
                        x_linkage           OUT NOCOPY VARCHAR2,
                        x_ei_date           OUT NOCOPY DATE,
			            x_txn_source   	    OUT	NOCOPY VARCHAR2,
			            x_ei_burdened_cost  OUT	NOCOPY NUMBER,
			            x_ei_burdened_delta OUT	NOCOPY NUMBER,
                        x_err_stack      IN OUT NOCOPY VARCHAR2,
                        x_err_stage      IN OUT NOCOPY VARCHAR2,
                        x_err_code          OUT NOCOPY NUMBER);

END PA_MC_CURRENCY_PKG;

 

/
