--------------------------------------------------------
--  DDL for Package FA_DEPRN_ROLLBACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEPRN_ROLLBACK_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVDRBS.pls 120.3.12010000.2 2009/07/19 11:41:52 glchen ship $   */

function do_rollback (
   p_asset_hdr_rec          IN     fa_api_types.asset_hdr_rec_type,
   p_period_rec             IN     fa_api_types.period_rec_type,
   p_deprn_run_id           IN     NUMBER,
   p_reversal_event_id      IN     NUMBER,
   p_reversal_date          IN     DATE,
   p_deprn_exists_count     IN     NUMBER,
   p_mrc_sob_type_code      IN     VARCHAR2,
   p_calling_fn             IN     VARCHAR2,
   p_log_level_rec          IN     FA_API_TYPES.log_level_rec_type default null
) return boolean;

END FA_DEPRN_ROLLBACK_PVT;

/
