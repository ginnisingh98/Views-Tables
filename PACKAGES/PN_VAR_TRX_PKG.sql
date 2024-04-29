--------------------------------------------------------
--  DDL for Package PN_VAR_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_TRX_PKG" AUTHID CURRENT_USER AS
-- $Header: PNVRTRXS.pls 120.0 2007/10/03 14:30:19 rthumma noship $

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

/* sales volume status */
G_SALESVOL_STATUS_APPROVED VARCHAR2(30) := 'APPROVED';
G_SALESVOL_STATUS_DRAFT    VARCHAR2(30) := 'DRAFT';
G_SALESVOL_STATUS_ON_HOLD  VARCHAR2(30) := 'ON_HOLD';

/* period status */
G_PERIOD_ACTIVE_STATUS   VARCHAR2(30) := 'ACTIVE';
G_PERIOD_REVERSED_STATUS VARCHAR2(30) := 'REVERSED';

/* data structures */
TYPE TRX_HRD_T IS TABLE OF pn_var_trx_headers_all%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE TRX_DTL_T IS TABLE OF pn_var_trx_details_all%ROWTYPE INDEX BY BINARY_INTEGER;

/* functions */
FUNCTION exists_trx_hdr( p_vr_id           IN NUMBER
                        ,p_period_id       IN NUMBER
                        ,p_line_item_id    IN NUMBER
                        ,p_grp_date_id     IN NUMBER
                        ,p_calc_prd_st_dt  IN DATE
                        ,p_calc_prd_end_dt IN DATE)
RETURN NUMBER;

FUNCTION exists_trx_dtl( p_trx_hdr_id  IN NUMBER
                        ,p_bkpt_dtl_id IN NUMBER)
RETURN NUMBER;

/* procedures */
PROCEDURE insert_trx_hdr( p_trx_header_id          IN OUT NOCOPY NUMBER
                         ,p_var_rent_id            IN NUMBER
                         ,p_period_id              IN NUMBER
                         ,p_line_item_id           IN NUMBER
                         ,p_grp_date_id            IN NUMBER
                         ,p_calc_prd_start_date    IN DATE
                         ,p_calc_prd_end_date      IN DATE
                         ,p_var_rent_summ_id       IN NUMBER
                         ,p_line_item_group_id     IN NUMBER
                         ,p_reset_group_id         IN NUMBER
                         ,p_proration_factor       IN NUMBER
                         ,p_reporting_group_sales  IN NUMBER
                         ,p_prorated_group_sales   IN NUMBER
                         ,p_ytd_sales              IN NUMBER
                         ,p_fy_proration_sales     IN NUMBER
                         ,p_ly_proration_sales     IN NUMBER
                         ,p_percent_rent_due       IN NUMBER
                         ,p_ytd_percent_rent       IN NUMBER
                         ,p_calculated_rent        IN NUMBER
                         ,p_prorated_rent_due      IN NUMBER
                         ,p_invoice_flag           IN VARCHAR2
                         ,p_org_id                 IN NUMBER
                         ,p_last_update_date       IN DATE
                         ,p_last_updated_by        IN NUMBER
                         ,p_creation_date          IN DATE
                         ,p_created_by             IN NUMBER
                         ,p_last_update_login      IN NUMBER);

PROCEDURE insert_trx_dtl( p_trx_detail_id            IN OUT NOCOPY NUMBER
                         ,p_trx_header_id            IN NUMBER
                         ,p_bkpt_detail_id           IN NUMBER
                         ,p_bkpt_rate                IN NUMBER
                         ,p_prorated_grp_vol_start   IN NUMBER
                         ,p_prorated_grp_vol_end     IN NUMBER
                         ,p_fy_pr_grp_vol_start      IN NUMBER
                         ,p_fy_pr_grp_vol_end        IN NUMBER
                         ,p_ly_pr_grp_vol_start      IN NUMBER
                         ,p_ly_pr_grp_vol_end        IN NUMBER
                         ,p_pr_grp_blended_vol_start IN NUMBER
                         ,p_pr_grp_blended_vol_end   IN NUMBER
                         ,p_ytd_group_vol_start      IN NUMBER
                         ,p_ytd_group_vol_end        IN NUMBER
                         ,p_blended_period_vol_start IN NUMBER
                         ,p_blended_period_vol_end   IN NUMBER
                         ,p_org_id                   IN NUMBER
                         ,p_last_update_date         IN DATE
                         ,p_last_updated_by          IN NUMBER
                         ,p_creation_date            IN DATE
                         ,p_created_by               IN NUMBER
                         ,p_last_update_login        IN NUMBER);

/* ----------------------------------------------------------------------
   ----- PROCEDURES TO CREATE TRX HEADERS, DETAILS, POPULATE BKPTS  -----
   ---------------------------------------------------------------------- */

PROCEDURE populate_line_grp_id(p_var_rent_id IN NUMBER);

PROCEDURE populate_reset_grp_id(p_var_rent_id IN NUMBER);

PROCEDURE populate_ly_pro_vol( p_var_rent_id        IN NUMBER
                              ,p_proration_rule     IN VARCHAR2
                              ,p_vr_commencement_dt IN DATE
                              ,p_vr_termination_dt  IN DATE);

PROCEDURE populate_fy_pro_vol( p_var_rent_id        IN NUMBER
                              ,p_proration_rule     IN VARCHAR2
                              ,p_vr_commencement_dt IN DATE
                              ,p_vr_termination_dt  IN DATE);

PROCEDURE populate_blended_grp_vol( p_var_rent_id    IN NUMBER
                                   ,p_proration_rule IN VARCHAR2);

PROCEDURE populate_ytd_pro_vol( p_var_rent_id    IN NUMBER
                               ,p_proration_rule IN VARCHAR2);

PROCEDURE populate_blended_period_vol( p_var_rent_id    IN NUMBER
                                      ,p_proration_rule IN VARCHAR2
                                      ,p_calc_method    IN VARCHAR2);

PROCEDURE delete_transactions( p_var_rent_id  IN NUMBER
                              ,p_period_id    IN NUMBER
                              ,p_line_item_id IN NUMBER);

/* -- procedure to be called from outside this package -- */
PROCEDURE populate_transactions(p_var_rent_id IN NUMBER);

/* ----------------------------------------------------------------------
   -------------------- PROCEDURES TO POPULATE SALES --------------------
   ---------------------------------------------------------------------- */
PROCEDURE get_calc_prd_sales( p_var_rent_id  IN NUMBER
                             ,p_period_id    IN NUMBER
                             ,p_line_item_id IN NUMBER
                             ,p_grp_date_id  IN NUMBER
                             ,p_start_date   IN DATE
                             ,p_end_date     IN DATE
                             ,x_pro_sales    OUT NOCOPY NUMBER
                             ,x_sales        OUT NOCOPY NUMBER);

FUNCTION get_calc_prd_sales( p_var_rent_id  IN NUMBER
                            ,p_period_id    IN NUMBER
                            ,p_line_item_id IN NUMBER
                            ,p_grp_date_id  IN NUMBER
                            ,p_start_date   IN DATE
                            ,p_end_date     IN DATE)
RETURN NUMBER;

PROCEDURE populate_ly_pro_sales( p_var_rent_id        IN NUMBER
                                ,p_proration_rule     IN VARCHAR2
                                ,p_vr_commencement_dt IN DATE
                                ,p_vr_termination_dt  IN DATE);

PROCEDURE populate_fy_pro_sales( p_var_rent_id        IN NUMBER
                                ,p_proration_rule     IN VARCHAR2
                                ,p_vr_commencement_dt IN DATE
                                ,p_vr_termination_dt  IN DATE);

PROCEDURE populate_ytd_sales( p_var_rent_id    IN NUMBER
                             ,p_proration_rule IN VARCHAR2);

PROCEDURE populate_sales (p_var_rent_id IN NUMBER);
/* ----------------------------------------------------------------------
   ----- PROCEDURES TO POPULATE SALES DATA FOR FORCASTED SALES  -----
   ---------------------------------------------------------------------- */
PROCEDURE get_calc_prd_sales_for( p_var_rent_id  IN NUMBER
                                 ,p_period_id    IN NUMBER
                                 ,p_line_item_id IN NUMBER
                                 ,p_grp_date_id  IN NUMBER
                                 ,p_start_date   IN DATE
                                 ,p_end_date     IN DATE
                                 ,x_pro_sales    OUT NOCOPY NUMBER
                                 ,x_sales        OUT NOCOPY NUMBER);

FUNCTION get_calc_prd_sales_for( p_var_rent_id  IN NUMBER
                                ,p_period_id    IN NUMBER
                                ,p_line_item_id IN NUMBER
                                ,p_grp_date_id  IN NUMBER
                                ,p_start_date   IN DATE
                                ,p_end_date     IN DATE)
RETURN NUMBER;

PROCEDURE populate_ytd_sales_for( p_var_rent_id IN NUMBER
                                 ,p_calc_method IN VARCHAR2);

PROCEDURE populate_sales_for( p_var_rent_id IN NUMBER);
/* ----------------------------------------------------------------------
   ----- PROCEDURES TO POPULATE DEDUCTIONS-------------------------------
   ---------------------------------------------------------------------- */
PROCEDURE get_calc_prd_dedc( p_var_rent_id  IN NUMBER
                             ,p_period_id    IN NUMBER
                             ,p_line_item_id IN NUMBER
                             ,p_grp_date_id  IN NUMBER
                             ,p_start_date   IN DATE
                             ,p_end_date     IN DATE
                             ,x_pro_dedc    OUT NOCOPY NUMBER
                             ,x_dedc        OUT NOCOPY NUMBER);
FUNCTION get_calc_prd_dedc( p_var_rent_id  IN NUMBER
                             ,p_period_id    IN NUMBER
                             ,p_line_item_id IN NUMBER
                             ,p_grp_date_id  IN NUMBER
                             ,p_start_date   IN DATE
                             ,p_end_date     IN DATE)

RETURN NUMBER;
PROCEDURE populate_ly_pro_dedc( p_var_rent_id        IN NUMBER
                               ,p_proration_rule     IN VARCHAR2
                               ,p_vr_commencement_dt IN DATE
                               ,p_vr_termination_dt  IN DATE);
PROCEDURE populate_fy_pro_dedc( p_var_rent_id        IN NUMBER
                                ,p_proration_rule     IN VARCHAR2
                                ,p_vr_commencement_dt IN DATE
                                ,p_vr_termination_dt  IN DATE);
PROCEDURE populate_ytd_deductions( p_var_rent_id    IN NUMBER
                             ,p_proration_rule IN VARCHAR2);
PROCEDURE populate_deductions(p_var_rent_id IN NUMBER);

END pn_var_trx_pkg;

/
