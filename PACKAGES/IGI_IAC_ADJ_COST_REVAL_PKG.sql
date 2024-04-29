--------------------------------------------------------
--  DDL for Package IGI_IAC_ADJ_COST_REVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_ADJ_COST_REVAL_PKG" AUTHID CURRENT_USER AS
 -- $Header: igiiadcs.pls 120.5.12000000.2 2007/10/16 14:17:08 sharoy noship $

    -- this is the main function
    FUNCTION Do_Cost_Revaluation
               (p_asset_iac_adj_info     igi_iac_types.iac_adj_hist_asset_info,
                p_asset_iac_dist_info    igi_iac_types.iac_adj_dist_info_tab,
                p_adj_hist               igi_iac_adjustments_history%ROWTYPE,
                p_event_id               number)  --R12 uptake
    RETURN BOOLEAN;

    -- function to check asset life
    FUNCTION  Chk_Asset_Life(p_book_code fa_books.book_type_code%TYPE,
                             p_period_counter fa_deprn_periods.period_counter%TYPE,
                             p_asset_id fa_books.asset_id%TYPE,
                             l_last_period_counter OUT NOCOPY fa_deprn_periods.period_counter%TYPE
                            )
   RETURN BOOLEAN;

   -- process that rolls the inactive YTD distributions forward
   PROCEDURE Roll_YTD_Forward(p_asset_id        igi_iac_det_balances.asset_id%TYPE,
                              p_book_type_code  igi_iac_det_balances.book_type_code%TYPE,
                              p_prev_adj_id     igi_iac_det_balances.adjustment_id%TYPE,
                              p_new_adj_id      igi_iac_det_balances.adjustment_id%TYPE,
                              p_prd_counter     igi_iac_det_balances.period_counter%TYPE);

END igi_iac_adj_cost_reval_pkg;


 

/
