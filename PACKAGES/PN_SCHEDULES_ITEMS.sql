--------------------------------------------------------
--  DDL for Package PN_SCHEDULES_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_SCHEDULES_ITEMS" AUTHID CURRENT_USER AS
  -- $Header: PNSCHITS.pls 120.4.12010000.4 2010/01/19 07:23:07 jsundara ship $

   g_lease_id          PN_LEASES.lease_id%TYPE;
   g_lease_num         PN_LEASES.lease_num%TYPE;
   g_lease_name        PN_LEASES.name%TYPE;
   g_pr_rule           PN_LEASES.payment_term_proration_rule%TYPE;
   g_lease_class_code  PN_LEASES.lease_class_code%TYPE;
   g_lease_status      PN_LEASES.lease_status%TYPE;
   g_new_lea_comm_dt   PN_LEASE_DETAILS_ALL.lease_commencement_date%TYPE;
   g_new_lea_term_dt   PN_LEASE_DETAILS_ALL.lease_termination_date%TYPE;
   g_new_ext_end_date  PN_LEASE_DETAILS_ALL.lease_extension_end_date%TYPE;
   g_norm_dt_avl  varchar2(1) := NULL; /* 9231686 */

PROCEDURE schedules_items (
  errbuf            OUT NOCOPY     VARCHAR2,
  retcode           OUT NOCOPY     VARCHAR2,
  p_lease_id        IN      NUMBER,
  p_lease_context   IN      VARCHAR2,
  p_called_from     IN      VARCHAR2 DEFAULT 'MAIN',
  p_term_id         IN      NUMBER DEFAULT NULL,
  p_term_end_dt     IN      DATE DEFAULT NULL,
  p_calc_batch      IN      VARCHAR2 DEFAULT 'N',
  p_cutoff_date     IN      VARCHAR2 DEFAULT NULL,
  p_extend_ri       IN      VARCHAR2 DEFAULT 'N',
  p_ten_trm_context IN      VARCHAR2 DEFAULT 'N');

PROCEDURE create_schedule(p_lease_id            NUMBER,
                          p_lc_id               NUMBER,
                          p_sch_dt              DATE,
                          p_sch_id          OUT NOCOPY NUMBER,
                          p_pymnt_st_lkp_cd OUT NOCOPY VARCHAR2,
                          p_payment_term_id     NUMBER DEFAULT NULL);

PROCEDURE create_normalize_items( p_lease_context      VARCHAR2,
                                  p_lease_id           NUMBER,
                                  p_term_id            NUMBER,
                                  p_vendor_id          NUMBER,
                                  p_cust_id            NUMBER,
                                  p_vendor_site_id     NUMBER,
                                  p_cust_site_use_id   NUMBER,
                                  p_cust_ship_site_id  NUMBER,
                                  p_sob_id             NUMBER,
                                  p_curr_code          VARCHAR2,
                                  p_sch_day            NUMBER   DEFAULT NULL,
                                  p_norm_str_dt        DATE,
                                  p_norm_end_dt        DATE,
                                  p_rate               NUMBER,
                                  p_lease_change_id    NUMBER);

PROCEDURE create_cash_items(p_est_amt          NUMBER,
                            p_act_amt          NUMBER,
                            p_sch_dt           DATE,
                            p_sch_id           NUMBER,
                            p_term_id          NUMBER,
                            p_vendor_id        NUMBER,
                            p_cust_id          NUMBER,
                            p_vendor_site_id   NUMBER,
                            p_cust_site_use_id NUMBER,
                            p_cust_ship_site_id NUMBER,
                            p_sob_id           NUMBER,
                            p_curr_code        VARCHAR2,
                            p_rate             NUMBER);

FUNCTION get_pro_amt(p_sch_str_dt    DATE,
                     p_sch_end_dt    DATE,
                     p_trm_str_dt    DATE,
                     p_trm_end_dt    DATE,
                     p_mth_amt       NUMBER,
                     p_pr_rule       VARCHAR2,
                     p_partial_start VARCHAR2,
                     p_partial_end   VARCHAR2)
RETURN NUMBER;


PROCEDURE get_amount(p_sch_str_dt    IN  DATE,
                     p_sch_end_dt    IN  DATE,
                     p_trm_str_dt    IN  DATE,
                     p_trm_end_dt    IN  DATE,
                     p_act_amt       IN  NUMBER,
                     p_est_amt       IN  NUMBER,
                     p_freq          IN  NUMBER,
                     p_pro_rule      IN  VARCHAR2 DEFAULT NULL,
                     p_cash_act_amt  OUT NOCOPY NUMBER,
                     p_cash_est_amt  OUT NOCOPY NUMBER);

PROCEDURE recalculate_cash(p_new_lease_term_date DATE);

FUNCTION get_frequency(p_freq_code VARCHAR2)
RETURN NUMBER;

FUNCTION first_day (p_date DATE)
RETURN DATE;

FUNCTION Get_Lease_Change_Id (p_lease_id IN NUMBER)
RETURN   NUMBER;


FUNCTION Get_Schedule_Date (p_lease_id   IN NUMBER,
                            p_day        IN NUMBER,
                            p_start_date IN DATE,
                            p_end_date   IN DATE,
                            p_freq       IN NUMBER DEFAULT 1)
RETURN DATE;

PROCEDURE Insert_Payment_Term (p_payment_term_rec              IN OUT NOCOPY pn_payment_terms_all%ROWTYPE,
                               x_return_status                    OUT NOCOPY VARCHAR2,
                               x_return_message                   OUT NOCOPY VARCHAR2);

PROCEDURE Create_Payment_Term (p_payment_term_rec  IN     pn_payment_terms_all%ROWTYPE,
                               p_lease_end_date    IN     DATE,
                               p_term_start_date   IN     DATE,
                               p_term_end_date     IN     DATE,
                               p_new_lea_term_dt   IN     DATE,
                               p_new_lea_comm_dt   IN     DATE,
                               p_mths              IN     NUMBER,
                               x_return_status     OUT NOCOPY VARCHAR2,
                               x_return_message    OUT NOCOPY VARCHAR2);


PROCEDURE Extend_Payment_Term (p_payment_term_rec  IN pn_payment_terms_all%rowtype,
                               p_new_lea_comm_dt   IN DATE,
                               p_new_lea_term_dt   IN DATE,
                               p_mths              IN NUMBER,
                               p_new_start_date    IN DATE ,
                               p_new_end_date      IN DATE,
                               x_return_status     OUT NOCOPY VARCHAR2,
                               x_return_message    OUT NOCOPY VARCHAR2);

PROCEDURE Rollover_lease (p_lease_id          IN     NUMBER,
                          p_lease_end_date    IN     DATE,
                          p_new_lea_term_dt   IN     DATE,
                          p_new_lea_comm_dt   IN     DATE,
                          p_mths              IN     NUMBER,
                          p_extend_ri         IN     VARCHAR2 DEFAULT NULL,
                          p_ten_trm_context   IN     VARCHAR2 DEFAULT 'N',
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_return_message    OUT NOCOPY VARCHAR2);

PROCEDURE norm_report(p_lease_context    VARCHAR2);

PROCEDURE  update_cash_item( p_item_id  NUMBER
                            ,p_term_id  NUMBER
                            ,p_sched_id NUMBER
                            ,p_act_amt  NUMBER);


procedure get_sch_start(p_yr_start_dt IN DATE,
                        p_freq_code IN VARCHAR2,
			p_term_start_dt IN VARCHAR2,
			p_sch_str_dt OUT NOCOPY DATE);

TYPE norm_st_dt_rec_tbl_type IS TABLE OF DATE
INDEX BY BINARY_INTEGER;

norm_st_dt_rec_tbl norm_st_dt_rec_tbl_type ; /* 9231686 */

END pn_schedules_items;

/
