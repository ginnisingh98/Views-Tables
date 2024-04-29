--------------------------------------------------------
--  DDL for Package GL_MC_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_MC_INQUIRY_PKG" AUTHID CURRENT_USER AS
/* $Header: glmcinqs.pls 120.2 2004/12/07 03:11:39 lpoon noship $ */
   TYPE id_arr IS TABLE OF NUMBER (15);

   TYPE var_arr1 IS TABLE OF VARCHAR2 (1);

   TYPE var_arr15 IS TABLE OF VARCHAR2 (15);

   TYPE var_arr20 IS TABLE OF VARCHAR2 (20);

   TYPE var_arr30 IS TABLE OF VARCHAR2 (30);

   TYPE date_arr IS TABLE OF DATE;

   TYPE num_arr IS TABLE OF NUMBER;

   /* All attributes of this type of record are table of scalar type
      (NUMBER/VARCHAR2), so we can use it for BULK COLLECT */
   TYPE r_fa_bulk_data IS RECORD (
      asset_id                      id_arr,
      sob_currency_code             var_arr30,
      sob_name                      var_arr30,
      sob_book_type                 var_arr1,
      sob_id                        id_arr,
      sob_book_type_code            var_arr30,
      COST                          num_arr,
      recoverable_cost              num_arr,
      net_book_value                num_arr,
      original_cost                 num_arr,
      salvage_value                 num_arr,
      ytd_deprn                     num_arr,
      bonus_ytd_deprn               num_arr,
      deprn_reserve                 num_arr,
      bonus_deprn_reserve           num_arr,
      reval_ceiling                 num_arr,
      reval_reserve                 num_arr);

   TYPE r_fa_fin_rec IS RECORD (
      primary_data                  NUMBER,
      rsob1                         NUMBER,
      rsob2                         NUMBER,
      rsob3                         NUMBER,
      rsob4                         NUMBER,
      rsob5                         NUMBER,
      rsob6                         NUMBER,
      rsob7                         NUMBER,
      rsob8                         NUMBER);

   TYPE r_fa_fin_rec_list IS TABLE OF r_fa_fin_rec;

   -- r_sob_list is same as gl_mc_info.r_sob_list
   -- Instead of redefining it, just define the subtype
   SUBTYPE r_sob_list_type IS gl_mc_info.r_sob_list;

   /* All attributes of this type of record are table of scalar type
      (NUMBER/VARCHAR2), so we can use it for BULK COLLECT */
/*   TYPE r_sob_rec_col IS RECORD (
      r_sob_id                      id_arr,
      r_sob_name                    var_arr30,
      r_sob_type                    var_arr1,
      r_sob_curr                    var_arr15,
      r_sob_user_type               var_arr15,
      r_sob_short_name              var_arr20,
      r_sob_start_date              date_arr,
      r_sob_end_date                date_arr);

   TYPE r_sob_rec IS RECORD (
      r_sob_id                      NUMBER (15),
      r_sob_name                    VARCHAR2 (30),
      r_sob_type                    VARCHAR2 (1),
      r_sob_curr                    VARCHAR2 (15),
      r_sob_user_type               VARCHAR2 (15),
      r_sob_short_name              VARCHAR2 (20),
      r_sob_start_date              DATE,
      r_sob_end_date                DATE);

   TYPE r_sob_list IS TABLE OF r_sob_rec;
*/
  FUNCTION mrc_enabled(n_application_id NUMBER, n_primary_sob_id NUMBER, n_org_id NUMBER)
  RETURN BOOLEAN;
   PROCEDURE query_balances (
      x_asset_id     NUMBER,
      x_book         VARCHAR2,
      x_period_ctr   NUMBER DEFAULT 0,
      x_dist_id      NUMBER DEFAULT 0,
   -- Bug fix 3975695: Remove the default string value
      x_run_mode     VARCHAR2 DEFAULT NULL
   );

   PROCEDURE add_adj_to_deprn (
      x_adj_drs      IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
      x_dest_drs     IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
      x_book_type             VARCHAR2,
      x_book_id      IN       NUMBER,
      x_calling_fn            VARCHAR2
   );

   PROCEDURE query_balances_int (
      x_dpr_row                 IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
      x_run_mode                         VARCHAR2,
      x_book_type               IN       VARCHAR2,
      x_book_id                 IN       NUMBER,
      x_calling_fn                       VARCHAR2,
      x_original_cost           IN OUT NOCOPY   NUMBER,
      x_salvage_value           IN OUT NOCOPY   NUMBER,
      x_reval_ceiling           IN OUT NOCOPY   NUMBER,
      x_reval_reserve           IN OUT NOCOPY   NUMBER,
      x_cost                    IN OUT NOCOPY   NUMBER,
      x_recoverable_cost        IN OUT NOCOPY   NUMBER,
      x_transaction_header_id   IN       NUMBER DEFAULT -1
   );

   PROCEDURE get_period_info (
      x_book                   VARCHAR2,
      x_cur_per_ctr   IN OUT NOCOPY   NUMBER,
      x_cur_fy        IN OUT NOCOPY   NUMBER,
      x_num_pers_fy   IN OUT NOCOPY   NUMBER,
      x_book_type     IN       VARCHAR2,
      x_book_id       IN       NUMBER,
      x_calling_fn             VARCHAR2
   );

   PROCEDURE query_deprn_summary (
      x_dpr_row            IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
      x_found_per_ctr      IN OUT NOCOPY   NUMBER,
      x_run_mode                    VARCHAR2,
      x_book_type          IN       VARCHAR2,
      x_book_id            IN       NUMBER,
      x_original_cost      IN OUT NOCOPY   NUMBER,
      x_salvage_value      IN OUT NOCOPY   NUMBER,
      x_reval_ceiling      IN OUT NOCOPY   NUMBER,
      x_reval_reserve      IN OUT NOCOPY   NUMBER,
      x_cost               IN OUT NOCOPY   NUMBER,
      x_recoverable_cost   IN OUT NOCOPY   NUMBER,
      x_calling_fn                  VARCHAR2
   );

   PROCEDURE get_adjustments_info (
      x_adj_row                 IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
      x_found_per_ctr           IN OUT NOCOPY   NUMBER,
      x_run_mode                         VARCHAR2,
      x_transaction_header_id            NUMBER,
      x_book_type               IN       VARCHAR2,
      x_book_id                 IN       NUMBER,
      x_calling_fn                       VARCHAR2
   );

   PROCEDURE ar_init_cash_receipts (p_cash_receipt_id IN NUMBER);

   PROCEDURE init_invoice (l_inv_id IN NUMBER);

   PROCEDURE init_payment (l_pay_id IN NUMBER);

   PROCEDURE transaction_balances(
                              p_customer_trx_id             IN Number
                             );

-- R11i.X Changes - replace r_sob_list by r_sob_list_type
   PROCEDURE get_associated_sobs(
      n_sob_id         IN       NUMBER,
      n_appl_id        IN       NUMBER,
      n_org_id         IN       NUMBER,
      n_fa_book_code   IN       VARCHAR2,
      n_num_rec        IN       NUMBER DEFAULT NULL,
      n_sob_list       IN OUT NOCOPY   r_sob_list_type
   );

END gl_mc_inquiry_pkg;

 

/
