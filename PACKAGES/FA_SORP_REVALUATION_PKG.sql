--------------------------------------------------------
--  DDL for Package FA_SORP_REVALUATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SORP_REVALUATION_PKG" AUTHID CURRENT_USER AS
/* $Header: FAVSRVS.pls 120.4.12010000.1 2009/07/21 12:37:57 glchen noship $   */

   --Procedure has logic for linking revaluations with prior impairments
   PROCEDURE fa_sorp_link_reval (
      -- p_nbv                            NUMBER,
      p_adj_amt                        NUMBER,
      p_mass_reval_id                  NUMBER,
      p_asset_id                       NUMBER,
      p_book_type_code                 VARCHAR2,
      p_run_mode                       VARCHAR2,
      p_request_id                     NUMBER,
      p_mrc_sob_type_code              VARCHAR2,
      p_category_id                    NUMBER,
      p_reval_type                     VARCHAR2,
      p_set_of_books_id                NUMBER,
      x_imp_loss_impact          OUT NOCOPY  NUMBER,
      x_reval_gain               OUT NOCOPY  NUMBER,
      x_impair_loss_acct         OUT NOCOPY  VARCHAR2,
      x_temp_imp_deprn_effect    OUT NOCOPY  NUMBER,
      x_reval_rsv_deprn_effect   OUT NOCOPY  NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

--Procedure updates FA_ITF_IMPAIRMENTS with reversed amounts
   PROCEDURE fa_imp_itf_upd (
      p_request_id         NUMBER,
      p_book_type_code     VARCHAR2,
      p_asset_id           NUMBER,
      p_last_updated_by    NUMBER,
      p_last_update_date   DATE
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

--Function returns impairment efffect on depriciation
   FUNCTION fa_imp_deprn_eff_fn (
      p_impairment_id    NUMBER,
      p_book_type_code   VARCHAR2,
      p_asset_id         NUMBER,
      p_reval_imp_flag   VARCHAR2,
      p_amount           NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN NUMBER;

-- Performs Accounting related to SORP
   FUNCTION fa_sorp_accounting (
      p_asset_id        IN       NUMBER,
      p_request_id      IN       NUMBER,
      px_adj            IN OUT NOCOPY  fa_adjust_type_pkg.fa_adj_row_struct,
      p_created_by      IN       NUMBER,
      p_creation_date   IN       DATE
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN;

-- Changes concatenated impairment id to original impairment id
   FUNCTION fa_sorp_process_imp_id_fn (p_impairment_id NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN NUMBER;

   /*Bug#7392015 function to calculate deprn effect for double db depreciation method*/
   Function fa_sorp_link_reval_dd(
      p_mass_reval_id       IN           NUMBER,
      p_asset_id            IN           NUMBER,
      p_book_type_code      IN           VARCHAR2,
      p_impairment_id       IN           NUMBER,
      p_unused_imp_amount   IN           NUMBER,
      p_mrc_sob_type_code   IN           VARCHAR2,
      p_set_of_books_id     IN           NUMBER,
      x_deprn_rsv           OUT NOCOPY   NUMBER,
      x_impairment_amt      OUT NOCOPY   NUMBER,
      x_impair_split_flag   OUT NOCOPY   VARCHAR2,
      x_override_flag       OUT NOCOPY   VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

END fa_sorp_revaluation_pkg;


/
