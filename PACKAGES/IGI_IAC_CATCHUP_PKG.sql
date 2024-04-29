--------------------------------------------------------
--  DDL for Package IGI_IAC_CATCHUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_CATCHUP_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiacts.pls 120.5.12000000.2 2007/10/16 14:15:19 sharoy ship $

    FUNCTION Do_Deprn_Catchup(
                    p_period_counter_from   IN  NUMBER,
                    p_period_counter_to     IN  NUMBER,
                    p_period_counter        IN  NUMBER,
                    p_crud_iac_tables       IN  BOOLEAN,
                    p_calling_function      IN  VARCHAR2,
                    p_fa_deprn_expense_py   IN  NUMBER,
                    p_fa_deprn_expense_cy   IN  NUMBER,
                    p_asset_last_period     IN  NUMBER,
                    p_fa_deprn_reserve      IN  NUMBER,
                    p_fa_deprn_ytd          IN  NUMBER,
                    p_asset_balance         IN OUT NOCOPY igi_iac_types.iac_reval_input_asset,
                    p_event_id              IN  NUMBER  --R12 uptake
                    ) return BOOLEAN;

    FUNCTION get_FA_Deprn_Expense(
                    p_asset_id          IN NUMBER,
                    p_book_type_code    IN VARCHAR2,
                    p_period_counter    IN NUMBER,
                    p_calling_function  IN VARCHAR2,
                    p_deprn_reserve     IN NUMBER,
                    p_deprn_YTD         IN NUMBER,
                    p_deprn_expense_py  OUT NOCOPY NUMBER,
                    p_deprn_expense_cy  OUT NOCOPY NUMBER,
                    p_last_asset_period OUT NOCOPY NUMBER
                    ) return BOOLEAN;

    FUNCTION do_reval_init_struct(
                    p_period_counter        IN NUMBER,
                    p_reval_control         IN OUT NOCOPY igi_iac_types.iac_reval_control_tab,
                    p_reval_asset_params    IN OUT NOCOPY igi_iac_types.iac_reval_asset_params_tab,
                    p_reval_input_asset     IN OUT NOCOPY igi_iac_types.iac_reval_asset_tab,
                    p_reval_output_asset    IN OUT NOCOPY igi_iac_types.iac_reval_asset_tab,
                    p_reval_output_asset_mvmt IN OUT NOCOPY igi_iac_types.iac_reval_asset_tab,
                    p_reval_asset_rules     IN OUT NOCOPY igi_iac_types.iac_reval_asset_rules_tab,
                    p_prev_rate_info        IN OUT NOCOPY igi_iac_types.iac_reval_rates_tab,
                    p_curr_rate_info_first  IN OUT NOCOPY igi_iac_types.iac_reval_rates_tab,
                    p_curr_rate_info_next   IN OUT NOCOPY igi_iac_types.iac_reval_rates_tab,
                    p_curr_rate_info        IN OUT NOCOPY igi_iac_types.iac_reval_rates_tab,
                    p_reval_exceptions      IN OUT NOCOPY igi_iac_types.iac_reval_exceptions_tab,
                    p_fa_asset_info         IN OUT NOCOPY igi_iac_types.iac_reval_fa_asset_info_tab,
                    p_fa_deprn_expense_py   IN NUMBER,
                    p_fa_deprn_expense_cy   IN NUMBER,
                    p_asset_last_period     IN NUMBER,
                    p_calling_function      IN varchar2
                    ) return BOOLEAN;

END igi_iac_catchup_pkg;

 

/
