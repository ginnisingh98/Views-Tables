--------------------------------------------------------
--  DDL for Package HRI_BPL_DBI_CALC_PERIOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_DBI_CALC_PERIOD" AUTHID CURRENT_USER AS
/* $Header: hribdcrp.pkh 120.6 2005/11/10 01:53:36 jrstewar noship $ */

PROCEDURE calc_sup_absence(p_supervisor_id         IN NUMBER,
                            p_from_date            IN DATE,
                            p_to_date              IN DATE,
                            p_period_type          IN VARCHAR2,
                            p_comparison_type      IN VARCHAR2,
                            p_total_type           IN VARCHAR2,
                            p_wkth_wktyp_sk_fk     IN VARCHAR2,
                            p_total_abs_drtn_days     OUT NOCOPY NUMBER,
                            p_total_abs_drtn_hrs      OUT NOCOPY NUMBER,
                            p_total_abs_in_period     OUT NOCOPY NUMBER,
                            p_total_abs_ntfctn_period OUT NOCOPY NUMBER);

PROCEDURE calc_sup_wcnt_chg(p_supervisor_id        IN NUMBER,
                            p_from_date            IN DATE,
                            p_to_date              IN DATE,
                            p_period_type          IN VARCHAR2,
                            p_comparison_type      IN VARCHAR2,
                            p_total_type           IN VARCHAR2,
                            p_total_gain_hire      OUT NOCOPY NUMBER,
                            p_total_gain_transfer  OUT NOCOPY NUMBER,
                            p_total_loss_term      OUT NOCOPY NUMBER,
                            p_total_loss_transfer  OUT NOCOPY NUMBER);

PROCEDURE calc_sup_wcnt_chg(p_supervisor_id        IN NUMBER,
                            p_from_date            IN DATE,
                            p_to_date              IN DATE,
                            p_period_type          IN VARCHAR2,
                            p_comparison_type      IN VARCHAR2,
                            p_total_type           IN VARCHAR2,
                            p_wkth_wktyp_sk_fk     IN VARCHAR2,
                            p_total_gain_hire      OUT NOCOPY NUMBER,
                            p_total_gain_transfer  OUT NOCOPY NUMBER,
                            p_total_loss_term      OUT NOCOPY NUMBER,
                            p_total_loss_transfer  OUT NOCOPY NUMBER);

PROCEDURE calc_sup_turnover(p_supervisor_id        IN NUMBER,
                            p_from_date            IN DATE,
                            p_to_date              IN DATE,
                            p_period_type          IN VARCHAR2,
                            p_comparison_type      IN VARCHAR2,
                            p_total_type           IN VARCHAR2,
                            p_wkth_wktyp_sk_fk     IN VARCHAR2,
                            p_total_trn_vol        OUT NOCOPY NUMBER,
                            p_total_trn_invol      OUT NOCOPY NUMBER);

/* Total terminations by supervisor and length of service */
/**********************************************************/
PROCEDURE calc_sup_term_low_pvt
        (p_supervisor_id  IN NUMBER,
         p_from_date      IN DATE,
         p_to_date        IN DATE,
         p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
         p_total_term     OUT NOCOPY NUMBER,
         p_total_term_b1  OUT NOCOPY NUMBER,
         p_total_term_b2  OUT NOCOPY NUMBER,
         p_total_term_b3  OUT NOCOPY NUMBER,
         p_total_term_b4  OUT NOCOPY NUMBER,
         p_total_term_b5  OUT NOCOPY NUMBER);

PROCEDURE calc_sup_term_perf_pvt
    (p_supervisor_id  IN NUMBER,
     p_from_date      IN DATE,
     p_to_date        IN DATE,
     p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
     p_total_term     OUT NOCOPY NUMBER,
     p_total_term_b1  OUT NOCOPY NUMBER,
     p_total_term_b2  OUT NOCOPY NUMBER,
     p_total_term_b3  OUT NOCOPY NUMBER,
     p_total_term_na  OUT NOCOPY NUMBER);

PROCEDURE calc_sup_term_pvt
    (p_supervisor_id     IN NUMBER,
     p_from_date         IN DATE,
     p_to_date           IN DATE,
     p_bind_tab          IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
     p_total_term_vol    OUT NOCOPY NUMBER,
     p_total_term_invol  OUT NOCOPY NUMBER,
     p_total_term        OUT NOCOPY NUMBER);

/* Get Termination and Hire Date */
/*********************************/

FUNCTION get_term_date(p_assignment_id      IN NUMBER
                      ,p_person_id          IN NUMBER)

            RETURN DATE;

END hri_bpl_dbi_calc_period;

 

/
