--------------------------------------------------------
--  DDL for Package PA_REVENUE_AMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REVENUE_AMT" AUTHID CURRENT_USER AS
/*$Header: PAXIIRSS.pls 120.1.12010000.2 2009/07/28 07:04:31 rdegala ship $ */

-- Table type definitions to hold host array that will be passed from Pro *c
--
 TYPE t_int IS TABLE OF INTEGER
      INDEX BY BINARY_INTEGER;
 TYPE t_varchar_30 IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;
 TYPE t_varchar_2 IS TABLE OF VARCHAR2(2)
      INDEX BY BINARY_INTEGER;
 TYPE t_varchar_13 IS TABLE OF VARCHAR2(13)
      INDEX BY BINARY_INTEGER;
/* 658088 */
 TYPE t_varchar_100 IS TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;
/*Added for nonlabor client extension*/
 TYPE t_varchar_20 IS TABLE OF VARCHAR2(20)
      INDEX BY BINARY_INTEGER;
/*End of change for nonlabor client extension*/
/*** Start MCB Changes   ***/

 TYPE t_varchar_15 IS TABLE OF VARCHAR2(15)
      INDEX BY BINARY_INTEGER;

/*** End MCB Changes ***/



 PROCEDURE get_irs_amt  (
	 process_irs                        OUT    NOCOPY  VARCHAR2,
	 process_bill_rate                  OUT    NOCOPY  VARCHAR2,
	 message_code                       OUT    NOCOPY  VARCHAR2,
 	 rows_this_time			    IN     INTEGER,
	 error_code			    IN OUT  NOCOPY    t_int,
	 reason				    OUT     NOCOPY t_varchar_30,
	 bill_amount			    OUT     NOCOPY t_varchar_100,  /* for bug 7232008 */
	 rev_amount			    OUT     NOCOPY t_varchar_30,
	 inv_amount			    OUT     NOCOPY t_varchar_30,
	 d_rule_decode			    IN OUT     NOCOPY t_int,
	 sl_function			    IN OUT     NOCOPY t_int,
	 ei_id			    	    IN OUT     NOCOPY t_int,
	 t_rev_irs_id		    	    IN OUT     NOCOPY t_int,
	 t_inv_irs_id		    	    IN OUT     NOCOPY t_int,
	 rev_comp_set_id	    	    IN OUT     NOCOPY t_int,
	 inv_comp_set_id	    	    IN OUT     NOCOPY t_int,
	 bill_rate_markup		    OUT     NOCOPY t_varchar_2,
	 t_lab_sch			    IN     t_varchar_2,
	 t_nlab_sch			    IN     t_varchar_2,
         p_mcb_flag                         IN     VARCHAR2,
         x_bill_trans_currency_code         IN OUT  NOCOPY t_varchar_15,       /* MCB Changes start  */
         x_bill_txn_bill_rate               IN OUT  NOCOPY t_varchar_30,
         x_rate_source_id                   IN OUT  NOCOPY t_int,
         x_markup_percentage                IN OUT  NOCOPY t_varchar_30,         /* MCB Changes end */
         x_exp_type                         IN             t_varchar_30,        /*change for nonlabor client extension */
         x_nl_resource                      IN             t_varchar_20,
         x_nl_res_org_id                    IN             t_int            /*End of change for nonlabor client extension*/
  );

/* The following Signature of PROCEDURE get_irs_amt is added for Bug 2517675.
 !!!This is overloaded procedure for compilation of pro*c files of Patchset H.
 !!!Note: This .pls with overload function should not be sent along with
          the patch for Patchset H customers */

 PROCEDURE get_irs_amt  (
         process_irs                        OUT    NOCOPY VARCHAR2,
         process_bill_rate                  OUT    NOCOPY VARCHAR2,
         message_code                       OUT    NOCOPY VARCHAR2,
         rows_this_time                     IN     INTEGER,
         error_code                         IN OUT     NOCOPY t_int,
         reason                             OUT     NOCOPY t_varchar_30,
         bill_amount                        OUT     NOCOPY t_varchar_30,
         rev_amount                         OUT     NOCOPY t_varchar_30,
         inv_amount                         OUT     NOCOPY t_varchar_30,
         d_rule_decode                      IN OUT     NOCOPY t_int,
         sl_function                        IN OUT     NOCOPY t_int,
         ei_id                              IN OUT     NOCOPY t_int,
         t_rev_irs_id                       IN OUT     NOCOPY t_int,
         t_inv_irs_id                       IN OUT     NOCOPY t_int,
         rev_comp_set_id                    IN OUT     NOCOPY t_int,
         inv_comp_set_id                    IN OUT     NOCOPY t_int,
         bill_rate_markup                   OUT     NOCOPY t_varchar_2,
         t_lab_sch                          IN     t_varchar_2,
         t_nlab_sch                         IN     t_varchar_2
  );

/* Bug 2517675 -End  */
/*This procedure is overloaded for patchset L changes(nonlabor client extension)*/
PROCEDURE get_irs_amt
(
 process_irs                        OUT NOCOPY   VARCHAR2,
 process_bill_rate                  OUT NOCOPY   VARCHAR2,
 message_code                       OUT NOCOPY   VARCHAR2,
 rows_this_time                     IN     INTEGER,
 error_code                         IN OUT  NOCOPY    t_int,
 reason                             OUT     NOCOPY t_varchar_30,
 bill_amount                        OUT     NOCOPY t_varchar_30,
 rev_amount                         OUT     NOCOPY t_varchar_30,
 inv_amount                         OUT     NOCOPY t_varchar_30,
 d_rule_decode                      IN OUT     NOCOPY t_int,
 sl_function                        IN OUT     NOCOPY t_int,
 ei_id                              IN OUT     NOCOPY t_int,
 t_rev_irs_id                       IN OUT     NOCOPY t_int,
 t_inv_irs_id                       IN OUT     NOCOPY t_int,
 rev_comp_set_id                    IN OUT     NOCOPY t_int,
 inv_comp_set_id                    IN OUT     NOCOPY t_int,
 bill_rate_markup                   OUT     NOCOPY t_varchar_2,
 t_lab_sch                          IN     t_varchar_2,
 t_nlab_sch                         IN     t_varchar_2,
 p_mcb_flag                         IN     VARCHAR2,
 x_bill_trans_currency_code         IN OUT  NOCOPY t_varchar_15,        /* MCB Chnages start */
 x_bill_txn_bill_rate               IN OUT  NOCOPY t_varchar_30,
 x_rate_source_id                   IN OUT  NOCOPY t_int,
 x_markup_percentage                IN OUT  NOCOPY t_varchar_30);         /* MCB Changes end */

 PROCEDURE  adjust_rounding_error
  (
         p_project_id          IN      NUMBER,
         p_request_id          IN      NUMBER,
         p_task_level_funding  IN      NUMBER ,
         x_max_items_allowed   IN      NUMBER  ,
         x_message_code        OUT  NOCOPY   VARCHAR2 ,
         x_total_exp_items     OUT  NOCOPY   NUMBER,
         x_exp_item_list       OUT  NOCOPY     t_varchar_100
  );

 PROCEDURE rev_ccid_chk(P_rec_ccid  IN NUMBER,
                        P_rev_ccid  IN NUMBER,
                        P_rg_ccid   IN NUMBER,
                        P_rl_ccid   IN NUMBER,
                        P_ou_reval_flag IN VARCHAR2,
                        P_out_status  OUT NOCOPY VARCHAR2
                        );



END pa_revenue_amt;

/
