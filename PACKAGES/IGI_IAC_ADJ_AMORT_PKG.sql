--------------------------------------------------------
--  DDL for Package IGI_IAC_ADJ_AMORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_ADJ_AMORT_PKG" AUTHID CURRENT_USER AS
 -- $Header: igiiadas.pls 120.3.12000000.2 2007/10/16 14:16:15 sharoy noship $

   FUNCTION Do_Amort_Deprn_Reval(p_asset_iac_adj_info  igi_iac_types.iac_adj_hist_asset_info,
                                 p_asset_iac_dist_info igi_iac_types.iac_adj_dist_info_tab,
                                 p_adj_hist            igi_iac_adjustments_history%ROWTYPE,
                                 p_event_id            number)  --R12 uptake
   RETURN BOOLEAN ;

END IGI_IAC_ADJ_AMORT_PKG;


 

/
