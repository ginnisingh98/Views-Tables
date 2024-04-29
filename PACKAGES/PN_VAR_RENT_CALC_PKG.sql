--------------------------------------------------------
--  DDL for Package PN_VAR_RENT_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_RENT_CALC_PKG" AUTHID CURRENT_USER AS
-- $Header: PNVRCALS.pls 120.0 2007/10/03 14:28:19 rthumma noship $
/* --------------------------------------------------------------------------
   ---------------------------- GLOBAL VARIABLES ----------------------------
   -------------------------------------------------------------------------- */
/* calculation methods */
G_CALC_CUMULATIVE     VARCHAR2(30) := 'C';
G_CALC_NON_CUMULATIVE VARCHAR2(30) := 'N';
G_CALC_YTD            VARCHAR2(30) := 'Y';
G_CALC_TRUE_UP        VARCHAR2(30) := 'T';

/* proration rules */
G_PRORUL_NP   VARCHAR2(30) := 'NP';
G_PRORUL_STD  VARCHAR2(30) := 'STD';
G_PRORUL_FY   VARCHAR2(30) := 'FY';
G_PRORUL_LY   VARCHAR2(30) := 'LY';
G_PRORUL_FLY  VARCHAR2(30) := 'FLY';
G_PRORUL_CYP  VARCHAR2(30) := 'CYP';
G_PRORUL_CYNP VARCHAR2(30) := 'CYNP';

/* breakpoint types */
G_BKPT_TYP_FLAT       VARCHAR2(30) := 'FLAT';
G_BKPT_TYP_SLIDING    VARCHAR2(30) := 'SLIDING';
G_BKPT_TYP_STRATIFIED VARCHAR2(30) := 'STRATIFIED';

/* sales volume status */
G_SALESVOL_STATUS_APPROVED VARCHAR2(30) := 'APPROVED';
G_SALESVOL_STATUS_DRAFT    VARCHAR2(30) := 'DRAFT';
G_SALESVOL_STATUS_ON_HOLD  VARCHAR2(30) := 'ON_HOLD';

/* term status */
G_TERM_STATUS_APPROVED VARCHAR2(30) := 'APPROVED';
G_TERM_STATUS_DRAFT    VARCHAR2(30) := 'DRAFT';

/* frequency codes */
G_FREQ_MON VARCHAR2(30) := 'MON';
G_FREQ_QTR VARCHAR2(30) := 'QTR';
G_FREQ_SA  VARCHAR2(30) := 'SA';
G_FREQ_YR  VARCHAR2(30) := 'YR';

/* number of calc periods for different calc freq */
G_CALC_PRD_IN_FREQ_MON NUMBER := 12;
G_CALC_PRD_IN_FREQ_QTR NUMBER := 4;
G_CALC_PRD_IN_FREQ_SA  NUMBER := 2;
G_CALC_PRD_IN_FREQ_YR  NUMBER := 1;

/*Number of months per period*/
G_FREQ_MON NUMBER := 1;
G_FREQ_QTR NUMBER := 3;
G_FREQ_SA NUMBER :=  6;
G_FREQ_YR NUMBER :=  12;

/* invoice ON */
G_INV_ON_ACTUAL     VARCHAR2(30) := 'ACTUAL';
G_INV_ON_FORECASTED VARCHAR2(30) := 'FORECASTED';
G_INV_ON_VARIANCE   VARCHAR2(30) := 'VARIANCE';

/* period status */
G_PERIOD_ACTIVE_STATUS   VARCHAR2(30) := 'ACTIVE';
G_PERIOD_REVERSED_STATUS VARCHAR2(30) := 'REVERSED';

/*Calculation types*/
G_CALC_TYPE_CALCULATE VARCHAR2(30) := 'CALCULATE';
G_CALC_TYPE_RECONCILE VARCHAR2(30) := 'RECONCILE';


/*Allowance application order*/
G_ALLOWANCE_FIRST VARCHAR(30) := 'AL';
G_ABATEMENT_FIRST VARCHAR(30) := 'AB';

/*Negative_rent*/
G_NEG_RENT_IGNORE VARCHAR(30) := 'IGNORE';
G_NEG_RENT_CREDIT VARCHAR(30) := 'CREDIT';
G_NEG_RENT_DEFER VARCHAR(30) := 'DEFER';

/*Excess abatements*/
G_EXC_ABAT_IGNORE VARCHAR(30) :='I';
G_EXC_ABAT_NEG_RENT VARCHAR(30) :='NR';

/*Fixed abatement/ Rolling Allowance*/
G_ABAT_TYPE_CODE_ABAT VARCHAR(30) := 'AB';
G_ABAT_TYPE_CODE_ALLO VARCHAR(30) := 'AL';
/* -------------------------------------------------------------------------
   ------------------------- PACKAGE LEVEL CURSORS -------------------------
   ------------------------------------------------------------------------- */

/* get VR info */
CURSOR vr_c(p_vr_id IN NUMBER) IS
  SELECT
   vr.org_id
  ,vr.var_rent_id
  ,vr.commencement_date
  ,vr.termination_date
  ,vr.proration_rule
  ,vr.cumulative_vol
  ,vr.negative_rent
  FROM
  pn_var_rents_all vr
  WHERE
  vr.var_rent_id = p_vr_id;

/* get trx headers */
CURSOR trx_hdr_c( p_vr_id  IN NUMBER
                 ,p_prd_id IN NUMBER) IS
  SELECT
   trx_header_id
  ,var_rent_id
  ,period_id
  ,line_item_id
  ,grp_date_id
  ,calc_prd_start_date
  ,calc_prd_end_date
  ,line_item_group_id
  ,reset_group_id
  ,proration_factor
  ,reporting_group_sales
  ,prorated_group_sales
  ,ytd_sales
  ,invoice_flag
  ,calculated_rent
  ,prorated_rent_due
  ,percent_rent_due
  ,ytd_percent_rent
  ,reporting_group_deductions
  ,prorated_group_deductions
  ,ytd_deductions
  ,first_yr_rent
  ,'N' AS update_flag
  FROM
  pn_var_trx_headers_all
  WHERE
  var_rent_id = p_vr_id AND
  period_id = p_prd_id
  ORDER BY
  line_item_id,
  calc_prd_start_date;

  /* get trx headers for forecasted data*/
CURSOR trx_hdr_for_c( p_vr_id  IN NUMBER
                     ,p_prd_id IN NUMBER) IS
  SELECT
   trx_header_id
  ,var_rent_id
  ,period_id
  ,line_item_id
  ,grp_date_id
  ,calc_prd_start_date
  ,calc_prd_end_date
  ,line_item_group_id
  ,reset_group_id
  ,proration_factor
  ,reporting_group_sales_for
  ,prorated_group_sales_for
  ,ytd_sales_for
  ,invoice_flag
  ,calculated_rent_for
  ,percent_rent_due_for
  ,ytd_percent_rent_for
  ,'N' AS update_flag
  FROM
  pn_var_trx_headers_all
  WHERE
  var_rent_id = p_vr_id AND
  period_id = p_prd_id
  ORDER BY
  line_item_id,
  calc_prd_start_date;

/* get trx details */
CURSOR trx_dtl_c( p_hdr_id IN NUMBER) IS
  SELECT
   trx_detail_id
  ,trx_header_id
  ,bkpt_detail_id
  ,bkpt_rate
  ,prorated_grp_vol_start
  ,prorated_grp_vol_end
  ,fy_pr_grp_vol_start
  ,fy_pr_grp_vol_end
  ,ly_pr_grp_vol_start
  ,ly_pr_grp_vol_end
  ,pr_grp_blended_vol_start
  ,pr_grp_blended_vol_end
  ,ytd_group_vol_start
  ,ytd_group_vol_end
  ,blended_period_vol_start
  ,blended_period_vol_end
  FROM
  pn_var_trx_details_all
  WHERE
  trx_header_id = p_hdr_id
  ORDER BY
  prorated_grp_vol_start;

/* -------------------------------------------------------------------------
   --------------------- PACKAGE LEVEL DATA STRUCTURES ---------------------
   ------------------------------------------------------------------------- */

TYPE TRX_HDR_TBL IS TABLE OF trx_hdr_c%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE TRX_DTL_TBL IS TABLE OF trx_dtl_c%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE TRX_HEADER_TBL IS TABLE OF trx_hdr_for_c%ROWTYPE INDEX BY BINARY_INTEGER;

TYPE TRX_HDR_RENT_REC IS RECORD
(
  percent_rent_due   pn_var_trx_headers_all.percent_rent_due%TYPE
 ,ytd_percent_rent   pn_var_trx_headers_all.ytd_percent_rent%TYPE
 ,calculated_rent    pn_var_trx_headers_all.calculated_rent%TYPE
 ,prorated_rent_due  pn_var_trx_headers_all.prorated_rent_due%TYPE
);

TYPE TRX_HDR_RENT_TBL IS TABLE OF TRX_HDR_RENT_REC INDEX BY BINARY_INTEGER;

g_org_id               pn_var_rents_all.org_id%TYPE;
g_vr_commencement_date pn_var_rents_all.commencement_date%TYPE;
g_vr_termination_date  pn_var_rents_all.termination_date%TYPE;
g_proration_rule       pn_var_rents_all.proration_rule%TYPE;
g_calculation_method   pn_var_rents_all.cumulative_vol%TYPE;
g_negative_rent        pn_var_rents_all.negative_rent%TYPE;
/* --------------------------------------------------------------------------
   ------------------------ PROCEDURES AND FUNCTIONS ------------------------
   -------------------------------------------------------------------------- */

PROCEDURE cache_vr_details(p_var_rent_id IN NUMBER);

FUNCTION get_fy_proration_factor(p_var_rent_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_ly_proration_factor(p_var_rent_id IN NUMBER)
RETURN NUMBER;

FUNCTION exists_approved_sales( p_line_item_id IN NUMBER
                               ,p_grp_date_id  IN NUMBER)
RETURN BOOLEAN;

FUNCTION find_prev_billed( p_var_rent_id      IN NUMBER
                          ,p_period_id        IN NUMBER
                          ,p_line_item_id     IN NUMBER
                          ,p_calc_prd_st_dt   IN DATE
                          ,p_calc_prd_end_dt  IN DATE
                          ,p_reset_grp_id     IN NUMBER)
RETURN NUMBER;

FUNCTION find_prev_billed( p_var_rent_id      IN NUMBER
                          ,p_line_item_grp_id IN NUMBER
                          ,p_calc_prd_st_dt   IN DATE
                          ,p_calc_prd_end_dt  IN DATE
                          ,p_reset_grp_id     IN NUMBER)
RETURN NUMBER;

PROCEDURE get_rent_applicable
(p_trx_hdr_rec IN OUT NOCOPY pn_var_rent_calc_pkg.trx_hdr_c%ROWTYPE) ;

PROCEDURE post_summary ( p_var_rent_id  IN NUMBER
                        ,p_period_id    IN NUMBER
                        ,p_line_item_id IN NUMBER
                        ,p_grp_date_id  IN NUMBER);

PROCEDURE post_summary ( p_var_rent_id  IN NUMBER
                        ,p_period_id    IN NUMBER);

PROCEDURE insert_invoice( p_var_rent_id IN NUMBER
                         ,p_period_id   IN NUMBER);

PROCEDURE calculate_rent( p_var_rent_id IN NUMBER
                         ,p_period_id   IN NUMBER);
/*procedures to insert forecasted data*/
PROCEDURE insert_invoice_for( p_var_rent_id IN NUMBER
                         ,p_period_id   IN NUMBER);
PROCEDURE get_rent_applicable_for
(p_trx_hdr_rec IN OUT NOCOPY pn_var_rent_calc_pkg.trx_hdr_for_c%ROWTYPE);

FUNCTION find_prev_billed_for( p_var_rent_id      IN NUMBER
                              ,p_period_id        IN NUMBER
                              ,p_line_item_id     IN NUMBER
                              ,p_calc_prd_st_dt   IN DATE
                              ,p_calc_prd_end_dt  IN DATE
                              ,p_reset_grp_id     IN NUMBER)
RETURN NUMBER;

PROCEDURE post_summary_for ( p_var_rent_id  IN NUMBER
                        ,p_period_id    IN NUMBER
                        ,p_line_item_id IN NUMBER
                        ,p_grp_date_id  IN NUMBER);
PROCEDURE post_summary_for ( p_var_rent_id  IN NUMBER
                        ,p_period_id    IN NUMBER);
/*Procedure to apply constraints*/
FUNCTION apply_constraints(p_period_id IN NUMBER,
                           p_invoice_date IN DATE,
                           p_actual_rent IN NUMBER)
RETURN NUMBER;
FUNCTION apply_constraints_fy(p_period_id IN NUMBER,
                           p_invoice_date IN DATE,
                           p_actual_rent IN NUMBER)
RETURN NUMBER;

/*Procedures to apply abatements*/
PROCEDURE apply_abatements(p_var_rent_id NUMBER,
                 p_period_id IN NUMBER,
                 p_flag IN VARCHAR2);
PROCEDURE apply_allow(p_var_rent_id IN NUMBER,
               p_period_id IN NUMBER,
               p_inv_id IN NUMBER,
               x_abated_rent IN OUT NOCOPY NUMBER);
PROCEDURE apply_abat(p_var_rent_id IN NUMBER,
           p_period_id IN NUMBER,
           p_inv_id IN NUMBER,
           x_abated_rent IN OUT NOCOPY NUMBER);
PROCEDURE populate_abat(p_var_rent_id IN NUMBER,
           p_period_id IN NUMBER,
           p_inv_id IN NUMBER);
PROCEDURE reset_abatements(p_var_rent_id IN NUMBER
          );
PROCEDURE apply_def_neg_rent(p_var_rent_id IN NUMBER,
                p_period_id IN NUMBER
               ,p_inv_id IN NUMBER,
               x_abated_rent IN OUT NOCOPY NUMBER);
PROCEDURE populate_neg_rent(p_var_rent_id IN NUMBER,
                p_period_id IN NUMBER
               ,p_inv_id IN NUMBER,
               x_abated_rent IN OUT NOCOPY NUMBER);
FUNCTION overage_cal(p_proration_rule IN VARCHAR2,
                     p_calculation_method IN VARCHAR2,
                     detail_id IN NUMBER) RETURN NUMBER;

FUNCTION overage_cal_for( p_proration_rule     IN VARCHAR2,
                          p_calculation_method IN VARCHAR2,
                          detail_id            IN NUMBER)
RETURN NUMBER ;

FUNCTION First_Day ( p_Date DATE )

RETURN DATE;

FUNCTION inv_end_date( inv_start_date IN DATE
                      ,vr_id IN NUMBER
                      ,p_period_id NUMBER DEFAULT NULL)
RETURN DATE;

FUNCTION inv_start_date( inv_start_date IN DATE
                      ,vr_id IN NUMBER
                      ,p_period_id NUMBER DEFAULT NULL)
RETURN DATE;

FUNCTION inv_sch_date(inv_start_date IN DATE
                      ,vr_id IN NUMBER
		      ,p_period_id NUMBER DEFAULT NULL)

RETURN DATE;

FUNCTION END_BREAKPOINT(bkpt_start IN NUMBER, bkpt_end IN  NUMBER)
RETURN NUMBER;

FUNCTION prev_invoiced_amt(p_var_rent_inv_id NUMBER, p_period_id NUMBER, p_invoice_date DATE)
RETURN NUMBER;

/* procedure called from concurent manager */
PROCEDURE process_rent_batch (errbuf                OUT NOCOPY  VARCHAR2,
                              retcode               OUT NOCOPY  VARCHAR2,
			      p_property_code       IN  VARCHAR2,
			      p_property_name       IN  VARCHAR2,
                              p_lease_num_from      IN  VARCHAR2,
                              p_lease_num_to        IN  VARCHAR2,
                              p_location_code_from  IN  VARCHAR2,
                              p_location_code_to    IN  VARCHAR2,
                              p_vrent_num_from      IN  VARCHAR2,
                              p_vrent_num_to        IN  VARCHAR2,
                              p_period_num_from     IN  NUMBER,
                              p_period_num_to       IN  NUMBER,
                              p_responsible_user    IN  NUMBER,
                              p_invoice_on          IN  VARCHAR2 DEFAULT NULL,
                              p_var_rent_id         IN  NUMBER,
                              p_period_id           IN  NUMBER,
                              p_line_item_id        IN  NUMBER,
                              p_invoice_date        IN  DATE,
                              p_calc_type           IN  VARCHAR2,
                              p_period_date         IN  VARCHAR2 DEFAULT NULL,
                              p_org_id              IN  NUMBER DEFAULT NULL);


PROCEDURE first_year_bkpt( p_vr_id            IN NUMBER
                          ,p_vr_comm_date     IN DATE
                          ,p_line_item_grp_id IN NUMBER
                          ,p_bkpt_rate        IN NUMBER
                          ,p_start_bkpt       OUT NOCOPY NUMBER
                          ,p_end_bkpt         OUT NOCOPY NUMBER);

PROCEDURE last_year_bkpt(  p_vr_id           IN NUMBER
                          ,p_vr_comm_date     IN DATE
                          ,p_line_item_grp_id IN NUMBER
                          ,p_bkpt_rate        IN NUMBER
                          ,p_start_bkpt       OUT NOCOPY NUMBER
                          ,p_end_bkpt         OUT NOCOPY NUMBER);

FUNCTION ytd_start_bkpt( p_proration_rule IN VARCHAR2
                        ,p_trx_detail_id  IN NUMBER) RETURN NUMBER ;

FUNCTION ytd_end_bkpt( p_proration_rule IN VARCHAR2
                        ,p_trx_detail_id  IN NUMBER) RETURN NUMBER ;

FUNCTION first_year_sales( p_vr_id            IN NUMBER
                           ,p_vr_comm_date     IN DATE
                           ,p_line_item_grp_id IN NUMBER)
RETURN NUMBER;

FUNCTION last_year_sales( p_vr_id            IN NUMBER
                           ,p_vr_comm_date     IN DATE
                           ,p_line_item_grp_id IN NUMBER)
RETURN NUMBER;

FUNCTION group_sales( p_proration_rule   IN VARCHAR2,
                      p_trx_detail_id    IN NUMBER,
                      p_calculation_type IN VARCHAR2)
RETURN NUMBER;

FUNCTION net_volume( p_proration_rule   IN VARCHAR2,
           p_trx_detail_id    IN NUMBER,
           p_calculation_type IN VARCHAR2)
RETURN NUMBER ;

FUNCTION group_deductions( p_proration_rule   IN VARCHAR2,
                                  p_trx_detail_id    IN NUMBER,
                                  p_calculation_type IN VARCHAR2)
RETURN NUMBER ;

FUNCTION cumulative_volume( p_proration_rule   IN VARCHAR2,
           p_trx_detail_id    IN NUMBER,
           p_calculation_type IN VARCHAR2)
RETURN NUMBER ;

FUNCTION annual_end_bkpt( p_proration_rule IN VARCHAR2
                         ,p_cumulative_vol IN VARCHAR2
                         ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER;

FUNCTION annual_start_bkpt( p_proration_rule IN VARCHAR2
                         ,p_cumulative_vol IN VARCHAR2
                         ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER;

FUNCTION prorated_start_bkpt( p_proration_rule IN VARCHAR2
                             ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER;

FUNCTION prorated_end_bkpt( p_proration_rule IN VARCHAR2
                           ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER;

FUNCTION current_gross_vr( p_proration_rule   IN VARCHAR2,
                           p_trx_detail_id    IN NUMBER)
RETURN NUMBER;

FUNCTION cumulative_gross_vr( p_proration_rule   IN VARCHAR2,
                              p_trx_detail_id    IN NUMBER)
RETURN NUMBER ;

FUNCTION fy_net_sales     (p_var_rent_id       IN NUMBER
                           ,p_line_item_id      IN NUMBER)
RETURN NUMBER;

FUNCTION first_yr_sales     (p_var_rent_id       IN NUMBER
                            ,p_line_item_id      IN NUMBER)
RETURN NUMBER;

FUNCTION first_yr_deductions(  p_var_rent_id       IN NUMBER
                              ,p_line_item_id      IN NUMBER)
RETURN NUMBER;

PROCEDURE true_up_details ( p_var_rent_id        IN NUMBER
                           ,p_trx_detail_id      IN NUMBER
                           ,p_rate               IN NUMBER
                           ,p_trueup_bkpt_vol_start OUT NOCOPY  NUMBER
                           ,p_trueup_bkpt_vol_end   OUT NOCOPY  NUMBER
                           ,p_trueup_volume         OUT NOCOPY  NUMBER
                           ,p_deductions            OUT NOCOPY  NUMBER
                           ,p_overage               OUT NOCOPY  NUMBER);

PROCEDURE true_up_summary ( p_period_id        IN NUMBER
                           ,p_true_up_rent     OUT NOCOPY  NUMBER
                           ,p_trueup_volume    OUT NOCOPY  NUMBER
                           ,p_deductions       OUT NOCOPY  NUMBER);

PROCEDURE pop_inv_date_tab (p_var_rent_id IN NUMBER
                           ,p_status      IN VARCHAR2);

PROCEDURE POP_INV_DATE_TAB_FIRSTYR(p_var_rent_id IN NUMBER,
                                   p_status      IN VARCHAR2);

PROCEDURE ROLL_FWD_SELECNS        (p_var_rent_id IN NUMBER);

PROCEDURE INCLUDE_INCREASES       (p_var_rent_id IN NUMBER);

PROCEDURE ROLL_FWD_PARTIAL_PRD    (p_var_rent_id IN NUMBER);

PROCEDURE ROLL_FWD_LST_PARTIAL_PRD(p_var_rent_id IN NUMBER);

PROCEDURE INCLUDE_INCREASES_FIRSTYR(p_var_rent_id IN NUMBER);

FUNCTION forecasted_var_rent ( p_var_rent_id IN NUMBER
                            , p_period_id  IN NUMBER )
RETURN NUMBER;

FUNCTION get_currency_precision (p_org_id NUMBER DEFAULT NULL)
RETURN NUMBER;

FUNCTION check_last_calc_prd(p_trx_hdr_id IN NUMBER,
                             p_prorul     IN VARCHAR2
                             )
RETURN NUMBER ;

FUNCTION get_rent_due(p_trx_hdr_id IN NUMBER,
                      p_prorul     IN VARCHAR2
                      )
RETURN NUMBER ;

FUNCTION get_cum_rent_due(p_trx_hdr_id IN NUMBER,
                          p_prorul     IN VARCHAR2
                         )
RETURN NUMBER ;
FUNCTION include_prd_no_term(p_prd_id IN NUMBER
                            )
RETURN VARCHAR2 ;

PROCEDURE delete_draft_terms( p_var_rent_id IN NUMBER);

FUNCTION actual_rent ( p_period_id IN NUMBER, p_invoice_date IN DATE, p_true_up_amt IN NUMBER, p_var_rent_inv_id IN NUMBER)
RETURN NUMBER;


FUNCTION VALIDATE_LY_CALC (p_varRentId NUMBER, p_periodId  IN NUMBER)
RETURN NUMBER;

PROCEDURE full_yr_summary ( p_line_item_id      IN NUMBER
                           ,p_yr_volume         OUT NOCOPY  NUMBER
                           ,p_deductions        OUT NOCOPY  NUMBER);

FUNCTION trueup_rent ( p_var_rent_id IN NUMBER
                      ,p_period_id   IN NUMBER
		      ,p_grp_date_id IN NUMBER)
RETURN NUMBER;

PROCEDURE true_up_bkpt ( p_period_id      IN NUMBER
                        ,p_bkpt_rate      IN NUMBER
                        ,p_bkpt_vol_start OUT NOCOPY  NUMBER
			,p_bkpt_vol_end   OUT NOCOPY  NUMBER);

FUNCTION new_term_amount ( p_invoice_date IN DATE
                          ,p_period_id   IN NUMBER
		          ,p_var_rent_inv_id IN NUMBER)
RETURN NUMBER;

FUNCTION true_up_header (  p_period_id   IN NUMBER
		          ,p_trx_hdr_id IN NUMBER
			  ,p_calc_prd_end_date IN DATE)
RETURN VARCHAR2;

END pn_var_rent_calc_pkg;

/
