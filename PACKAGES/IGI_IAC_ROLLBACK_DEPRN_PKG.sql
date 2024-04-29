--------------------------------------------------------
--  DDL for Package IGI_IAC_ROLLBACK_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_ROLLBACK_DEPRN_PKG" AUTHID CURRENT_USER as
/* $Header: igiacrds.pls 120.1 2007/10/29 15:27:50 vkilambi noship $   */


FUNCTION Do_Rollback_Deprn(
   p_asset_hdr_rec               fa_api_types.asset_hdr_rec_type,
   p_period_rec                  fa_api_types.period_rec_type,
   p_deprn_run_id                NUMBER,
   p_reversal_event_id           NUMBER,
   p_reversal_date               DATE,
   p_deprn_exists_count          NUMBER,
   p_calling_function            VARCHAR2
) return BOOLEAN;

END IGI_IAC_ROLLBACK_DEPRN_PKG;


/
