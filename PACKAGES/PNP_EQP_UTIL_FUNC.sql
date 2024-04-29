--------------------------------------------------------
--  DDL for Package PNP_EQP_UTIL_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNP_EQP_UTIL_FUNC" AUTHID CURRENT_USER AS
  -- $Header: PNEQUTFS.pls 120.0.12010000.6 2019/03/08 13:22:48 vbkumar noship $

  -- Global Variable for use by
  /*29459789*/
  	g_curr_code  VARCHAR2(10);
	g_org_id  NUMBER;
	g_conv_type VARCHAR2(30);

  -- SET_VIEW_CONTEXT (procedure)  and  GET_VIEW_CONTEXT (function)
    g_view_context VARCHAR2(2) DEFAULT NULL;
    g_start_of_time DATE := TO_DATE('01-01-0001','DD-MM-YYYY');
    g_end_of_time DATE := TO_DATE('31-12-4712','DD-MM-YYYY');
    g_as_of_date DATE := SYSDATE;
    g_retro_enabled BOOLEAN := false;
    g_mini_retro_enabled BOOLEAN := true;
    g_as_of_date_4_loc_pubview DATE := NULL;
    g_as_of_date_4_emp_pubview DATE := NULL;
    TYPE item_end_dt_rec IS RECORD ( term_id pn_eqp_payment_terms_all.payment_term_id%TYPE,
    item_end_dt DATE,
    index_period_id pn_eqp_payment_terms_all.index_period_id%TYPE );
    TYPE item_end_dt_tbl_type IS
        TABLE OF item_end_dt_rec INDEX BY BINARY_INTEGER;
    FUNCTION item_end_date (
        p_term_id     IN NUMBER,
        p_freq_code   IN VARCHAR
    ) RETURN DATE;

    FUNCTION fetch_item_end_dates (
        p_lease_id NUMBER
    ) RETURN pnp_eqp_util_func.item_end_dt_tbl_type;

    FUNCTION retro_enabled RETURN BOOLEAN;

  /*-----------------------------------------------------------------------------
  -- Returns a boolean TRUE if mini retro is enabled
  -----------------------------------------------------------------------------*/

    FUNCTION mini_retro_enabled RETURN BOOLEAN;

    FUNCTION norm_trm_exsts (
        p_lease_id IN NUMBER
    ) RETURN BOOLEAN;

    FUNCTION get_lease_id_by_schedule (
        p_schedule_id pn_eqp_payment_schedules_all.payment_schedule_id%TYPE
    ) RETURN NUMBER;

	-----------------------------------------------------------------------------------
	-- To return Conversion Rate Type either from profile option setup or pn_currencies.
	-----------------------------------------------------------------------------------

    FUNCTION check_conversion_type (
        p_curr_code   IN VARCHAR2,
        p_org_id      IN NUMBER
    ) RETURN VARCHAR2;


    -------------------------------------------------------------------
	-- To Return EXPORT_CURRENCY_AMOUNT column
	-- Get Export Currency Amount from GL's API
	-------------------------------------------------------------------

    FUNCTION export_curr_amount (
        currency_code          IN VARCHAR2,
        export_currency_code   IN VARCHAR2,
        export_date            IN DATE,
        conversion_type        IN VARCHAR2,
        actual_amount          IN NUMBER,
        p_called_from          IN VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER;

    FUNCTION get_lease_status (
        p_leaseid NUMBER
    ) RETURN VARCHAR2;

    PRAGMA restrict_references ( get_lease_status,wnds,wnps );
    FUNCTION get_profile_value (
        p_profile_name   IN VARCHAR2,
        p_org_id         IN NUMBER DEFAULT NULL
    ) RETURN VARCHAR2;

    FUNCTION get_start_date (
        p_period_name VARCHAR2,
        p_org_id NUMBER
    ) RETURN DATE;

    FUNCTION get_default_gl_period (
        p_sch_date         IN DATE,
        p_application_id   IN NUMBER,
        p_org_id           IN NUMBER
    ) RETURN VARCHAR2;

END pnp_eqp_util_func;

/
