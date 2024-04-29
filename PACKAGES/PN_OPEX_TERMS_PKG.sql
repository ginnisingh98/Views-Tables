--------------------------------------------------------
--  DDL for Package PN_OPEX_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_OPEX_TERMS_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNOTERMS.pls 120.1 2007/10/11 06:27:10 rthumma noship $


-------------------------------------------------------------------
-- PROCEDURE CREATE_OPEX_PAYMENT_TERMS
-------------------------------------------------------------------
PROCEDURE create_opex_payment_terms(
    p_est_payment_id        IN            NUMBER,
    p_term_template_id      IN            NUMBER DEFAULT NULL,
    p_lease_id              IN            NUMBER,
    x_payment_term_id       OUT    NOCOPY NUMBER,
    x_catch_up_term_id      OUT    NOCOPY NUMBER,
    x_return_status         IN OUT NOCOPY VARCHAR2

    );

-------------------------------------------------------------------
-- PROCEDURE CREATE_RECON_OPEX_PAYMENT_TERMS
-------------------------------------------------------------------

PROCEDURE create_recon_pay_term(
    p_recon_id          IN             NUMBER DEFAULT NULL,
    p_agreement_id      IN             NUMBER,
    p_st_end_date       IN             DATE  DEFAULT SYSDATE,
    p_amount            IN             NUMBER,
    x_payment_term_id   OUT    NOCOPY  NUMBER,
    x_return_status     IN OUT NOCOPY  VARCHAR2
    );



-------------------------------------------------------------------
-- PROCEDURE LAST_SCHEDULE_DAY
-------------------------------------------------------------------
PROCEDURE last_schedule_day(
    p_lease_id              IN           NUMBER,
    p_payment_term_id       IN           NUMBER,
    x_end_date              OUT  NOCOPY  VARCHAR2
    );


FUNCTION get_curr_est_pay_term(agr_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_latest_recon(agr_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_stmt_due_date(agr_id IN NUMBER)
RETURN DATE;

FUNCTION get_prop_id(p_location_id IN NUMBER)
RETURN NUMBER;


-------------------------------------------------------------------
-- PROCEDURE CONTRACT_PREV_EST_TERM
-------------------------------------------------------------------

PROCEDURE contract_prev_est_term(
    p_lease_id          IN    NUMBER,
    p_est_payment_id    IN    NUMBER,
    x_return_status     IN OUT NOCOPY VARCHAR2);



FUNCTION recon_pct_change(p_agr_id IN NUMBER ,
                          p_recon_id IN NUMBER ,
                          p_period_start_dt DATE ,
                          p_ten_tot_charge NUMBER)
RETURN NUMBER;

PROCEDURE delete_agreement (p_agreement_id  IN  NUMBER
                           ,x_return_status  IN OUT NOCOPY VARCHAR2);


-------------------------------------------------------------------
-- PROCEDURE APPROVE_OPEX_PAY_TERM
-------------------------------------------------------------------
PROCEDURE approve_opex_pay_term (ip_lease_id            IN          NUMBER
                                 ,ip_opex_pay_term_id   IN          NUMBER
                                 ,op_msg                 OUT NOCOPY  VARCHAR2
                                  );


-------------------------------------------------------------------
-- PROCEDURE APPROVE_OPEX_PAY_TERM_BATCH
-- 15-MAY-2007  sdmahesh    o Bug # 6039220
--                            Changed the order of concurrent program
--                            parameters
-------------------------------------------------------------------
PROCEDURE approve_opex_pay_term_batch (
      errbuf                        OUT NOCOPY      VARCHAR2
     ,retcode                       OUT NOCOPY      VARCHAR2
     ,ip_agreement_number_lower     IN       VARCHAR2
     ,ip_agreement_number_upper     IN       VARCHAR2
     ,ip_main_lease_number_lower    IN       VARCHAR2
     ,ip_main_lease_number_upper    IN       VARCHAR2
     ,ip_location_code_lower        IN       VARCHAR2
     ,ip_location_code_upper        IN       VARCHAR2
     ,ip_user_responsible           IN       VARCHAR2
     ,ip_payment_start_date_lower   IN       VARCHAR2
     ,ip_payment_start_date_upper   IN       VARCHAR2
     ,ip_payment_function           IN       VARCHAR2
     ,ip_property_code_ret_by_id    IN       VARCHAR2
     ,ip_payment_status             IN       VARCHAR2
   );


  FUNCTION get_unpaid_amt(p_recon_id IN NUMBER)
  RETURN NUMBER;


END pn_opex_terms_pkg;

/
