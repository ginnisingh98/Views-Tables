--------------------------------------------------------
--  DDL for Package PN_VARIABLE_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VARIABLE_AMOUNT_PKG" AUTHID CURRENT_USER AS
-- $Header: PNVRAMTS.pls 120.2 2007/03/16 10:45:08 rdonthul noship $


-- LEASE CLASS
   c_lease_class_direct             CONSTANT CHAR (6)  := 'DIRECT';

-- PAYMENT STATUS
  c_payment_term_status_draft      CONSTANT CHAR (5)   := 'DRAFT';
  c_payment_term_status_approved   CONSTANT CHAR (8)   := 'APPROVED';



PROCEDURE process_variable_rent (
        p_var_rent_id  IN NUMBER,
        p_period_id    IN NUMBER,
        p_line_item_id IN NUMBER,
        p_cumulative   IN VARCHAR2,
        p_invoice_on   IN VARCHAR2,
        p_calc_type    IN VARCHAR2,
        p_invoice_date IN DATE DEFAULT NULL);

PROCEDURE process_rent (
        p_var_rent_id         IN NUMBER,
        p_period_id           IN NUMBER,
        p_line_item_id        IN NUMBER,
        p_grp_date_id         IN NUMBER,
        p_invoice_date        IN DATE,
        p_group_date          IN DATE,
        p_tot_vol             IN NUMBER,
        p_tot_ded             IN NUMBER,
        p_var_rent            IN NUMBER,
        p_calc_type           IN VARCHAR2,
        p_cumulative          IN VARCHAR2
        );

PROCEDURE Insert_invoice(
        p_calc_type    IN VARCHAR2,
        p_period_id    IN NUMBER,
        p_var_rent_id  IN NUMBER);

FUNCTION get_rent_applicable (
        p_cumulative IN VARCHAR2,
        p_net_volume IN NUMBER,
        p_percent_days_open IN NUMBER)
RETURN NUMBER;


PROCEDURE process_calculate_type (
        p_line_item_id IN NUMBER,
        p_cumulative IN  VARCHAR2,
        p_calc_type IN VARCHAR2,
        p_period_id IN NUMBER,
        p_invoice_date IN DATE);


PROCEDURE get_cum_vol_by_grpdt(
        p_grp_date_id IN NUMBER,
        p_cum_actual_vol OUT NOCOPY NUMBER,
        p_cum_for_vol OUT NOCOPY NUMBER,
        p_cum_ded OUT NOCOPY NUMBER);


PROCEDURE get_bkp_details (p_line_item_id IN NUMBER);

FUNCTION find_varrent_exists (
        p_line_item_id IN NUMBER,
        p_grp_date_id IN NUMBER)
RETURN VARCHAR2;


PROCEDURE calculate_var_rent (
        p_grp_date_id   IN NUMBER,
        p_line_item_id    IN NUMBER,
        p_volume          IN NUMBER,
        p_cum_volume      IN NUMBER,
        p_cum_ded         IN NUMBER,
        p_cumulative      IN VARCHAR2,
        p_calc_type       IN VARCHAR2);



PROCEDURE get_varrent_details (
        p_var_rent_id IN NUMBER,
        p_cumulative OUT NOCOPY VARCHAR2,
        p_invoice_on OUT NOCOPY VARCHAR2,
        p_negative_rent OUT NOCOPY VARCHAR2);

FUNCTION apply_constraints(
        p_period_id IN NUMBER,
        p_actual_rent IN NUMBER)
RETURN NUMBER;


PROCEDURE get_transferred_flag(
        p_period_id IN NUMBER,
        p_invoice_date IN DATE,
        p_actual_flag  OUT NOCOPY VARCHAR2,
        p_forecasted_flag OUT NOCOPY VARCHAR2,
        p_variance_flag OUT NOCOPY VARCHAR2);

FUNCTION get_prior_transfer_flag(
        p_var_rent_inv_id NUMBER,
        p_var_rent_type   VARCHAR2,
        p_var_rent_id     NUMBER)
RETURN VARCHAR2;

FUNCTION get_prev_inv_amt(
        p_var_rent_id NUMBER,
        p_invoice_date DATE,
        p_adjust_num NUMBER)
RETURN NUMBER;


FUNCTION find_if_term_exists (
        p_var_rent_inv_id IN NUMBER,
        p_var_rent_type IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION find_volume_exists (
        p_period_id IN NUMBER,
        p_invoice_date IN DATE,
        p_var_rent_type IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE get_deductions(p_line_item_id  IN NUMBER);

PROCEDURE get_percent_open (
        p_period_id  IN NUMBER,
        p_cumulative IN VARCHAR2,
        p_start_date IN DATE,
        p_end_date   IN DATE );

PROCEDURE get_cumulative_volume (
       p_line_item_id IN NUMBER);

PROCEDURE put_log(p_string VARCHAR2);

PROCEDURE put_output(p_string VARCHAR2);

PROCEDURE apply_abatements (p_var_rent_id IN NUMBER);

FUNCTION get_vol_ded(
        p_line_item_id NUMBER,
        p_group_date DATE,
        p_type VARCHAR2)
RETURN NUMBER;


PROCEDURE process_rent_batch (
        errbuf                OUT NOCOPY  VARCHAR2,
        retcode               OUT NOCOPY  VARCHAR2,
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

PROCEDURE process_vol_hist (
        p_grp_date_id         IN   NUMBER,
        p_invoice_date        IN   DATE,
        p_period_id           IN   NUMBER,
        p_line_item_id        IN   NUMBER,
        p_invoice_on          IN   VARCHAR2,
        p_calc_type           OUT NOCOPY  VARCHAR2);

FUNCTION get_msg (
        p_calc IN VARCHAR2,
        p_adj  IN VARCHAR2,
        p_rec  IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_prorated_bkpt(p_cumulative IN VARCHAR2,
                           p_grp_st_dt  IN DATE,
                           p_grp_end_dt IN DATE,
                           p_per_st_dt  IN DATE,
                           p_per_end_dt IN DATE,
                           p_per_bkpt   IN NUMBER,
                           p_grp_bkpt   IN NUMBER,
                           p_pror_factor IN NUMBER)
RETURN NUMBER;

FUNCTION derive_actual_invoiced_amt(p_constr_actual_rent number,
                                    p_negative_rent_flag varchar2,
                                    p_abatement_appl number,
                                    p_negative_rent number,
                                    p_rec_abatement number,
                                    p_rec_abatement_override number)
RETURN NUMBER;

PROCEDURE get_approved_flag(
                            p_period_id          IN NUMBER,
                            p_invoice_date       IN DATE,
			    p_true_up_flag       IN VARCHAR2,
                            p_actual_flag        OUT NOCOPY VARCHAR2,
                            p_forecasted_flag    OUT NOCOPY VARCHAR2,
                            p_variance_flag      OUT NOCOPY VARCHAR2);

END pn_variable_amount_pkg;



/
