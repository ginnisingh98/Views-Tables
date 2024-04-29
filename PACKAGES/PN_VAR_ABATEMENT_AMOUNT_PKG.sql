--------------------------------------------------------
--  DDL for Package PN_VAR_ABATEMENT_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_ABATEMENT_AMOUNT_PKG" AUTHID CURRENT_USER AS
-- $Header: PNVRCABS.pls 120.2 2007/05/31 11:39:14 sraaj ship $

--Global variables--
G_INCLUDE_TERM_YES VARCHAR2(30) := 'Y';
G_INCLUDE_TERM_NO VARCHAR2(30) := 'N';


FUNCTION calc_abatement(
                      p_var_rent_inv_id in number,
                      p_min_grp_dt in date,
                      p_max_grp_dt in date) return number;

FUNCTION calc_abatement(p_var_rent_id IN NUMBER,
                        p_period_id IN NUMBER,
                      p_var_rent_inv_id in number,
                      p_min_grp_dt in date,
                      p_max_grp_dt in date,
		      p_trp_flag IN VARCHAR2) return number;


PROCEDURE process_abatement(
                      p_var_rent_inv_id in number,
                      p_negative_rent_flag in varchar2,
                      p_term_exists in varchar2,
                      p_var_rent_type in varchar2,
                      p_min_grp_dt in date,
                      p_max_grp_dt in date);

FUNCTION get_group_dt(p_invoice_date date,
                      p_period_id number,
                      p_date_type in varchar2)
RETURN date;

FUNCTION get_term_exists (
                      p_payment_term_id in number,
                      p_var_rent_inv_id number)
RETURN varchar2;


END pn_var_abatement_amount_pkg;


/
