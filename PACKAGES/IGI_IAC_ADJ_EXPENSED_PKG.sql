--------------------------------------------------------
--  DDL for Package IGI_IAC_ADJ_EXPENSED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_ADJ_EXPENSED_PKG" AUTHID CURRENT_USER AS
 -- $Header: igiiadxs.pls 120.3.12000000.2 2007/10/16 14:19:52 sharoy noship $

   FUNCTION Do_Expensed_Adj
               (p_asset_iac_adj_info 	igi_iac_types.iac_adj_hist_asset_info,
                P_asset_iac_dist_info 	igi_iac_types.iac_adj_dist_info_tab,
                p_adj_hist              igi_iac_adjustments_history%ROWTYPE,
                p_event_id              NUMBER)   --R12 uptake
    RETURN BOOLEAN ;

END igi_iac_adj_expensed_pkg;


 

/
