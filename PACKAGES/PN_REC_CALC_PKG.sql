--------------------------------------------------------
--  DDL for Package PN_REC_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_REC_CALC_PKG" AUTHID CURRENT_USER as
/* $Header: PNRECALS.pls 120.0.12010000.2 2008/09/04 12:26:31 mumohan ship $ */

g_rec_agr_line_id        pn_rec_agr_linconst_all.rec_agr_line_id%TYPE;
g_calc_period_as_of_date   pn_rec_calc_periods_all.as_of_date%TYPE;

g_ext_precision number;
g_min_acct_unit number;
g_currency_code gl_sets_of_books.currency_code%type;
g_precision     number;

TYPE ten_recoverable_area_rec IS RECORD (
          occupied_area                 PN_REC_ARCL_DTLLN_ALL.occupied_area%TYPE
          ,occupancy_pct                 PN_REC_ARCL_DTLLN_ALL.occupancy_pct%TYPE
          );

TYPE period_bill_record IS RECORD (
          period_billrec_id PN_REC_PERIOD_BILL_ALL.period_billrec_id%TYPE
          ,amount            PN_REC_PERIOD_BILL_ALL.amount%TYPE
          );

TYPE expenses_record IS RECORD (
          computed_recoverable_amt PN_REC_EXPCL_DTLLN_ALL.computed_recoverable_amt%TYPE
          ,budgeted_amt            PN_REC_EXPCL_DTLLN_ALL.computed_recoverable_amt%TYPE
          );


CURSOR get_line_constr_csr IS
     SELECT constr_order
            ,const.scope
            ,const.relation
            ,const.value
            ,const.cpi_index
            ,const.base_year
     FROM   pn_rec_agr_linconst_all const
     WHERE  const.rec_agr_line_id = g_rec_agr_line_id
     AND    g_calc_period_as_of_date between const.start_date
     AND    const.end_date
     ORDER BY const.constr_order ;

TYPE g_line_constr_type IS
TABLE OF get_line_constr_csr%ROWTYPE
INDEX BY BINARY_INTEGER;


g_line_success      VARCHAR2(30);
g_all_lines_success VARCHAR2(30);

PROCEDURE CALCULATE_REC_AMOUNT_BATCH(
                               errbuf                   OUT NOCOPY VARCHAR2
                               ,retcode                 OUT NOCOPY VARCHAR2
                               ,p_rec_agreement_id      IN  NUMBER
                               ,p_lease_id              IN  NUMBER
                               ,p_location_id           IN  NUMBER
                               ,p_customer_id           IN  NUMBER
                               ,p_cust_site_id          IN  NUMBER
                               ,p_rec_agr_line_id       IN  NUMBER DEFAULT NULL
                               ,p_rec_calc_period_id    IN  NUMBER DEFAULT NULL
                               ,p_calc_period_startdate IN  VARCHAR2
                               ,p_calc_period_enddate   IN  VARCHAR2
                               ,p_as_ofdate             IN  VARCHAR2
                               ,p_lease_num_from        IN  VARCHAR2
                               ,p_lease_num_to          IN  VARCHAR2
                               ,p_location_code_from    IN  VARCHAR2
                               ,p_location_code_to      IN  VARCHAR2
                               ,p_rec_agr_num_from      IN  VARCHAR2
                               ,p_rec_agr_num_to        IN  VARCHAR2
                               ,p_property_name         IN  VARCHAR2
                               ,p_customer_name         IN  VARCHAR2
                               ,p_customer_site         IN  VARCHAR2
                               ,p_calc_period_ending    IN  VARCHAR2
                               ,p_org_id                IN NUMBER DEFAULT NULL
                              );

-- Created an overloaded proc to fix bug 3138335

PROCEDURE CALCULATE_REC_AMOUNT_BATCH(
                               errbuf                   OUT NOCOPY VARCHAR2
                               ,retcode                 OUT NOCOPY VARCHAR2
			       ,p_calc_period_startdate IN  VARCHAR2	--Bug#6438840
                               ,p_calc_period_enddate   IN  VARCHAR2	--Bug#6438840
                               ,p_as_ofdate             IN  VARCHAR2	--Bug#6438840
                               ,p_lease_num_from        IN  VARCHAR2
                               ,p_lease_num_to          IN  VARCHAR2
                               ,p_location_code_from    IN  VARCHAR2
                               ,p_location_code_to      IN  VARCHAR2
                               ,p_rec_agr_num_from      IN  VARCHAR2
                               ,p_rec_agr_num_to        IN  VARCHAR2
                               ,p_property_name         IN  VARCHAR2
                               ,p_customer_name         IN  VARCHAR2
                               ,p_customer_site         IN  VARCHAR2
                               ,p_calc_period_ending    IN  VARCHAR2
                               ,p_org_id                IN NUMBER DEFAULT NULL
                              );

PROCEDURE CALCULATE_REC_AMOUNT(
                               p_rec_agreement_id        IN NUMBER
                               ,p_lease_id               IN NUMBER
                               ,p_location_id            IN NUMBER
                               ,p_customer_id            IN NUMBER
                               ,p_cust_site_id           IN NUMBER
                               ,p_rec_agr_line_id        IN NUMBER   DEFAULT NULL
                               ,p_rec_calc_period_id     IN NUMBER   DEFAULT NULL
                               ,p_calc_period_start_date IN DATE
                               ,p_calc_period_end_date   IN DATE
                               ,p_as_of_date             IN DATE
                               ,p_error                  IN OUT NOCOPY VARCHAR2
                               ,p_error_code             IN OUT NOCOPY NUMBER
                              );

FUNCTION get_recoverable_area (
         p_rec_calc_period_id  pn_rec_period_lines_all.rec_calc_period_id%TYPE
         ,p_rec_agr_line_id    pn_rec_period_lines_all.rec_agr_line_id%TYPE
                              )
      RETURN pn_rec_period_lines_all.recoverable_area%TYPE;

PROCEDURE get_line_expenses (
         p_rec_agr_line_id         IN NUMBER
         ,p_customer_id            IN NUMBER
         ,p_lease_id               IN NUMBER
         ,p_location_id            IN NUMBER
         ,p_calc_period_start_date IN DATE
         ,p_calc_period_end_date   IN DATE
         ,p_calc_period_as_of_date IN DATE
         ,p_recoverable_amt        IN OUT NOCOPY   NUMBER
         ,p_fee_before_contr       IN OUT  NOCOPY  NUMBER
         ,p_fee_after_contr        IN OUT   NOCOPY NUMBER
         ,p_error                  IN OUT  NOCOPY VARCHAR2
         ,p_error_code             IN OUT NOCOPY NUMBER
                           );

FUNCTION get_contr_actual_recovery (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_customer_id            pn_rec_agreements_all.customer_id%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
         ,p_called_from            VARCHAR2 DEFAULT 'CALCUI'
                           )
      RETURN pn_rec_period_lines_all.actual_recovery%TYPE;

FUNCTION get_budget_expenses (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_customer_id            pn_rec_agreements_all.customer_id%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_calc_period_as_of_date pn_rec_calc_periods_all.as_of_date%TYPE
                           )
      RETURN pn_rec_expcl_dtlln_all.budgeted_amt%TYPE;

FUNCTION get_tot_prop_area (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_customer_id            pn_rec_agreements_all.customer_id%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
                           )
      RETURN pn_rec_arcl_dtl_all.TOTAL_assignable_area%TYPE;

FUNCTION ten_recoverable_area (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_customer_id            pn_rec_agreements_all.customer_id%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
                           )
      RETURN ten_recoverable_area_rec;

 -- 04-Nov-2003  Daniel Thota  o Changed the where clause to account for multi-tenancy
 --                              so that billing terms of a lease are now associated with a location.
 --                              Added a new parameter p_location_id for the function

FUNCTION get_billed_recovery (
         p_payment_purpose         pn_rec_agr_lines_all.purpose%TYPE
         ,p_payment_type           pn_rec_agr_lines_all.type%TYPE
         ,p_lease_id               pn_rec_agreements_all.lease_id%TYPE
         ,p_location_id            pn_rec_agreements_all.location_id%TYPE
         ,p_calc_period_start_date pn_rec_calc_periods_all.start_date%TYPE
         ,p_calc_period_end_date   pn_rec_calc_periods_all.end_date%TYPE
         ,p_rec_agr_line_id        pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_rec_calc_period_id     pn_rec_calc_periods_all.rec_calc_period_id%TYPE
                             )
      RETURN pn_rec_period_lines_all.billed_recovery%TYPE;

FUNCTION get_line_constraints (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
                             )
      RETURN g_line_constr_type;

FUNCTION get_line_abatements (
         p_rec_agr_line_id         pn_rec_agr_lines_all.rec_agr_line_id%TYPE
         ,p_as_of_date             pn_rec_calc_periods_all.as_of_date%TYPE
                             )
      RETURN pn_rec_agr_linabat_all.amount%TYPE;

FUNCTION find_if_period_line_exists (
         p_rec_agr_line_id pn_rec_period_lines_all.rec_agr_line_id%TYPE
         ,p_rec_calc_period_id pn_rec_period_lines_all.rec_calc_period_id%TYPE
                                    )
      RETURN pn_rec_period_lines_all.rec_period_lines_id%TYPE;

procedure INSERT_PERIOD_LINES_ROW (
  X_ROWID                in out NOCOPY VARCHAR2
  ,X_REC_PERIOD_LINES_ID  in out NOCOPY NUMBER
  ,X_BUDGET_PCT           in NUMBER
  ,X_OCCUPANCY_PCT        in NUMBER
  ,X_MULTIPLE_PCT         in NUMBER
  ,X_TENANCY_START_DATE   in DATE
  ,X_TENANCY_END_DATE     in DATE
  ,X_STATUS               in VARCHAR2
  ,X_BUDGET_PRORATA_SHARE in NUMBER
  ,X_BUDGET_COST_PER_AREA in NUMBER
  ,X_TOTAL_AREA           in NUMBER
  ,X_TOTAL_EXPENSE        in NUMBER
  ,X_RECOVERABLE_AREA     in NUMBER
  ,X_ACTUAL_RECOVERY      in NUMBER
  ,X_CONSTRAINED_ACTUAL   in NUMBER
  ,X_ABATEMENTS           in NUMBER
  ,X_ACTUAL_PRORATA_SHARE in NUMBER
  ,X_BILLED_RECOVERY      in NUMBER
  ,X_RECONCILED_AMOUNT    in NUMBER
  ,X_BUDGET_RECOVERY      in NUMBER
  ,X_BUDGET_EXPENSE       in NUMBER
  ,X_REC_CALC_PERIOD_ID   in NUMBER
  ,X_REC_AGR_LINE_ID      in NUMBER
  ,X_AS_OF_DATE           in DATE
  ,X_START_DATE           in DATE
  ,X_END_DATE             in DATE
  ,X_BILLING_TYPE         in VARCHAR2
  ,X_BILLING_PURPOSE      in VARCHAR2
  ,X_CUST_ACCOUNT_ID      in NUMBER
  ,X_CREATION_DATE        in DATE
  ,X_CREATED_BY           in NUMBER
  ,X_LAST_UPDATE_DATE     in DATE
  ,X_LAST_UPDATED_BY      in NUMBER
  ,X_LAST_UPDATE_LOGIN    in NUMBER
  ,X_FIXED_PCT            in NUMBER
  ,X_ERROR_CODE           in out NOCOPY NUMBER
  );

procedure UPDATE_PERIOD_LINES_ROW(
  X_REC_PERIOD_LINES_ID  in NUMBER
  ,X_BUDGET_PCT           in NUMBER
  ,X_OCCUPANCY_PCT        in NUMBER
  ,X_MULTIPLE_PCT         in NUMBER
  ,X_TENANCY_START_DATE   in DATE
  ,X_TENANCY_END_DATE     in DATE
  ,X_STATUS               in VARCHAR2
  ,X_BUDGET_PRORATA_SHARE in NUMBER
  ,X_BUDGET_COST_PER_AREA in NUMBER
  ,X_TOTAL_AREA           in NUMBER
  ,X_TOTAL_EXPENSE        in NUMBER
  ,X_RECOVERABLE_AREA     in NUMBER
  ,X_ACTUAL_RECOVERY      in NUMBER
  ,X_CONSTRAINED_ACTUAL   in NUMBER
  ,X_ABATEMENTS           in NUMBER
  ,X_ACTUAL_PRORATA_SHARE in NUMBER
  ,X_BILLED_RECOVERY      in NUMBER
  ,X_RECONCILED_AMOUNT    in NUMBER
  ,X_BUDGET_RECOVERY      in NUMBER
  ,X_BUDGET_EXPENSE       in NUMBER
  ,X_REC_CALC_PERIOD_ID   in NUMBER
  ,X_REC_AGR_LINE_ID      in NUMBER
  ,X_AS_OF_DATE           in DATE
  ,X_START_DATE           in DATE
  ,X_END_DATE             in DATE
  ,X_BILLING_TYPE         in VARCHAR2
  ,X_BILLING_PURPOSE      in VARCHAR2
  ,X_CUST_ACCOUNT_ID      in NUMBER
  ,X_LAST_UPDATE_DATE     in DATE
  ,X_LAST_UPDATED_BY      in NUMBER
  ,X_LAST_UPDATE_LOGIN    in NUMBER
  ,X_FIXED_PCT            in NUMBER
  ,X_ERROR_CODE           in out NOCOPY NUMBER
  );

procedure DELETE_PERIOD_LINES_ROW (
  X_REC_PERIOD_LINES_ID in NUMBER
);

procedure INSERT_PERIOD_BILLREC_ROW (
  X_ROWID               in out NOCOPY VARCHAR2
  ,X_PERIOD_BILLREC_ID  in out NOCOPY NUMBER
  ,X_REC_AGREEMENT_ID   in NUMBER
  ,X_REC_AGR_LINE_ID    in NUMBER
  ,X_REC_CALC_PERIOD_ID in NUMBER
  ,X_AMOUNT             in NUMBER
  ,X_CREATION_DATE      in DATE
  ,X_CREATED_BY         in NUMBER
  ,X_LAST_UPDATE_DATE   in DATE
  ,X_LAST_UPDATED_BY    in NUMBER
  ,X_LAST_UPDATE_LOGIN  in NUMBER
);

procedure UPDATE_PERIOD_BILLREC_ROW (
  X_PERIOD_BILLREC_ID   in NUMBER
  ,X_REC_AGREEMENT_ID   in NUMBER
  ,X_REC_AGR_LINE_ID    in NUMBER
  ,X_REC_CALC_PERIOD_ID in NUMBER
  ,X_AMOUNT             in NUMBER
  ,X_LAST_UPDATE_DATE   in DATE
  ,X_LAST_UPDATED_BY    in NUMBER
  ,X_LAST_UPDATE_LOGIN  in NUMBER
);

procedure DELETE_PERIOD_BILLREC_ROW (
  X_PERIOD_BILLREC_ID in NUMBER
);

PROCEDURE create_payment_terms(
      p_lease_id               IN  NUMBER
     ,p_payment_amount         IN  NUMBER
     ,p_calc_period_end_date   IN  DATE
     ,p_rec_agreement_id       IN  NUMBER
     ,p_rec_agr_line_id        IN  NUMBER
     ,p_rec_calc_period_id     IN  NUMBER
     ,p_location_id            IN  NUMBER
     ,p_amount_type            IN  VARCHAR2
     ,p_org_id                 IN  NUMBER
     ,p_billing_type           IN VARCHAR2
     ,p_billing_purpose        IN VARCHAR2
     ,p_customer_id            IN NUMBER
     ,p_cust_site_id           IN NUMBER
     ,p_consolidate            IN VARCHAR2
     ,p_error                  IN OUT NOCOPY VARCHAR2
     ,p_error_code             IN OUT NOCOPY NUMBER
    );

FUNCTION find_if_rec_payterm_exists(
         p_rec_agreement_id PN_REC_PERIOD_BILL_all.period_billrec_id%TYPE
         ,p_rec_agr_line_id PN_REC_PERIOD_BILL_all.rec_agr_line_id%TYPE
         ,p_rec_calc_period_id PN_REC_PERIOD_BILL_all.rec_calc_period_id%TYPE
         ,p_consolidate            IN VARCHAR2
        )
      RETURN period_bill_record;

FUNCTION get_prior_period_actual_amount(
         p_rec_agr_line_id   pn_rec_period_lines_all.rec_agr_line_id%TYPE
         ,p_start_date       pn_rec_calc_periods_all.start_date%TYPE
         ,p_as_of_date       pn_rec_calc_periods_all.as_of_date%TYPE DEFAULT NULL
         ,p_called_from      VARCHAR2 DEFAULT 'CALCUI'
        )
      RETURN pn_rec_period_lines_all.constrained_actual%TYPE;

FUNCTION get_prior_period_cap(
         p_rec_agr_line_id   pn_rec_period_lines_all.rec_agr_line_id%TYPE
         ,p_start_date       pn_rec_calc_periods_all.start_date%TYPE
         ,p_end_date         pn_rec_calc_periods_all.end_date%TYPE
         ,p_as_of_date       pn_rec_calc_periods_all.as_of_date%TYPE
         ,p_called_from      VARCHAR2 DEFAULT 'CALCUI'
        )
      RETURN pn_rec_period_lines_all.actual_recovery%TYPE;

PROCEDURE lock_area_exp_cls_dtl( p_payment_term_id  IN pn_payment_terms_all.payment_term_id%TYPE);

FUNCTION validate_create_calc_period(p_rec_agreement_id pn_rec_agreements_all.REC_AGREEMENT_ID%TYPE,
                                     p_start_date pn_rec_calc_periods_all.start_date%TYPE,
				     p_end_date   pn_rec_calc_periods_all.end_date%TYPE,
				     p_as_of_date pn_rec_calc_periods_all.as_of_date%TYPE)
RETURN NUMBER;

END PN_REC_CALC_PKG;

/
