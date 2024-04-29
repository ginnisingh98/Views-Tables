--------------------------------------------------------
--  DDL for Package Body FA_TAX_RSV_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TAX_RSV_ADJ_PVT" as
/* $Header: FAVTRSVB.pls 120.5.12010000.3 2009/07/19 09:56:04 glchen ship $   */

/* Bug 4597471 -- added one more parameter p_mrc_sob_type_code for passing the type of reporting flag whether 'P' = Primary
   or 'R'= Reporting */

FUNCTION do_tax_rsv_adj
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec          IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    px_asset_fin_rec          IN OUT NOCOPY  FA_API_TYPES.asset_fin_rec_type,
    p_asset_tax_rsv_adj_rec   IN     FA_API_TYPES.asset_tax_rsv_adj_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2,
    p_calling_fn              IN     VARCHAR2,
    p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type default null
   )  RETURN BOOLEAN
IS

   l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;       -- This is the original / old asset_fin_rec.
   l_asset_fin_rec_adj        FA_API_TYPES.asset_fin_rec_type := NULL;
   l_asset_fin_rec_new        FA_API_TYPES.asset_fin_rec_type;


   l_fin_info                 fa_std_types.fin_info_struct;
   l_asset_tax_rsv_adj_rec    FA_API_TYPES.asset_tax_rsv_adj_rec_type;

   l_asset_deprn_rec_old      FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new      FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;

   l_cur_period_rec           FA_API_TYPES.period_rec_type;
   l_period_rec               FA_API_TYPES.period_rec_type;


   l_reporting_flag           VARCHAR2(1);
   l_pers_per_yr              Number;

   l_adj_acct                 Number;
   l_exp_acct                 Number;
   l_rsv_acct                 Number;
   l_cost_acct	              Number;

   l_cur_dpr_rsv              Number;
   l_old_dpr_rsv              Number;
   l_new_dpr_rsv              Number;
   l_new_adj_cost             Number;
   l_old_adj_cost             Number;
   l_last_year_old_dpr_rsv    Number;
   l_cur_bonus_deprn_rsv      Number;
   l_new_rate_adj_factor      Number;
   l_new_ann_adj_exp          Number;
   l_signed_adj_amount        Number;

   l_adj_amount               Number;
   l_total_adjs               Number;
   L_SIGNED_ADJ_AMT           Number;

   l_exchange_rate            Number;
   l_avg_rate                 Number;
   l_old_ytd_deprn            Number;

   l_deprn_basis_rule         VARCHAR2(10);
   l_annual_deprn_rounding_flag  FA_BOOKS.ANNUAL_DEPRN_ROUNDING_FLAG%Type;

   l_dummy_varch              varchar2(124);
   l_dummy_bool               Boolean;
   l_dummy_dpr_arr            fa_std_types.dpr_arr_type;


   l_adj                      FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

   dpr                        fa_std_types.dpr_struct;
   dpr_row                    fa_std_types.fa_deprn_row_struct;
   dpr_out                    fa_std_types.dpr_out_struct;

   l_bks_rowid                varchar2(30);
   l_th_rowid                 varchar2(30);

   l_status                   BOOLEAN;
   l_rsv_flag                 BOOLEAN := FALSE;
   l_calling_fn               VARCHAR2(40) := 'FA_TAX_RSV_ADJ_PVT.do_tax_rsv_adj';


   TAX_RSV_ADJ_ERR            EXCEPTION;

   CURSOR fiscal_year_cr (p_book_type_code FA_BOOKS.book_type_code%TYPE, p_fiscal_year Number)  is
   SELECT   DP.FISCAL_YEAR, MAX(DP.PERIOD_NUM),MAX(DP.PERIOD_COUNTER)
   FROM     FA_DEPRN_PERIODS DP
   WHERE    DP.BOOK_TYPE_CODE = p_book_type_code
   AND      DP.FISCAL_YEAR > p_fiscal_year
   AND      DP.PERIOD_CLOSE_DATE IS NOT NULL
   GROUP BY DP.FISCAL_YEAR
   ORDER BY MIN(DP.PERIOD_OPEN_DATE);
BEGIN

   SAVEPOINT do_tax_rsv_adj;
   -- Get the book type code P,R or N

   if not fa_cache_pkg.fazcsob
         (X_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
          X_mrc_sob_type_code => l_reporting_flag,
          p_log_level_rec     => p_log_level_rec
         ) then
      raise tax_rsv_adj_err;
   end if;

   /* Bug 4597471 -- loading the reporting falg which denoted the type of book Primary or Reporting */
   l_reporting_flag := p_mrc_sob_type_code;

   -- Make a local copy of the asset_fin_rec, asset_tax_rsv_adj_rec.

   l_asset_fin_rec := px_asset_fin_rec;
   l_asset_tax_rsv_adj_rec := p_asset_tax_rsv_adj_rec;

   -- Load l_fin_info for non-financial info.

   -- substitute values at asset level.

   l_fin_info.current_time := px_trans_rec.who_info.creation_date;
   l_fin_info.asset_number := p_asset_desc_rec.asset_number;
   l_fin_info.asset_id     := PX_ASSET_HDR_REC.asset_id;


  if not FA_UTIL_PVT.get_current_units
         (l_calling_fn,
          px_asset_hdr_rec.asset_id,
          l_fin_info.units,
          p_log_level_rec  => p_log_level_rec
         ) then
      raise tax_rsv_adj_err;
   end if;

--   l_fin_info.units        := p_asset_desc_rec.current_units;
   l_fin_info.category_id  := p_asset_cat_rec.category_id;
   l_fin_info.asset_type   := p_asset_type_rec.asset_type;

   -- substitute values at book level.

   l_fin_info.adj_rate           := l_asset_fin_rec.adjusted_rate;
   l_fin_info.ceiling_name       := l_asset_fin_rec.ceiling_name;
   l_fin_info.bonus_rule         := l_asset_fin_rec.bonus_rule;
   l_fin_info.book               := PX_ASSET_HDR_REC.book_type_code;
   l_fin_info.transaction_id     := px_trans_rec.transaction_header_id;
   l_fin_info.method_code        := l_asset_fin_rec.deprn_method_code;
   l_fin_info.life               := l_asset_fin_rec.life_in_months;
   l_fin_info.date_placed_in_svc := l_asset_fin_rec.date_placed_in_service;
   l_fin_info.jdate_in_svc       := to_number(to_char(l_asset_fin_rec.date_placed_in_service,'J'));
   l_fin_info.prorate_date       := l_asset_fin_rec.prorate_date;
   l_fin_info.deprn_start_date   := l_asset_fin_rec.deprn_start_date;
   l_fin_info.capacity           := l_asset_fin_rec.production_capacity;
   l_fin_info.adj_capacity       := l_fin_info.capacity;
   l_fin_info.deprn_rounding_flag := fa_std_types.FA_DPR_ROUND_ADJ;

   if (px_asset_fin_rec.depreciate_flag = 'YES') then
       l_fin_info.dep_flag := TRUE;
   else
       l_fin_info.dep_flag := FALSE;
   end if;

   if not fa_cache_pkg.fazcbc(l_fin_info.book) then
          fa_srvr_msg.add_message (calling_fn => 'fa_tax_rsv_adj_pkg.do_tax_rsv_adj_pub',
                                   p_log_level_rec     => p_log_level_rec);
      return (FALSE);
   end if;

   l_fin_info.period_ctr := fa_cache_pkg.fazcbc_record.last_period_counter + 1;

   -- End of non financial loading of l_fin_info.

   l_asset_fin_rec_new := l_asset_fin_rec;
   if l_reporting_flag <> 'R' then


      -- (3) Fin_info : Calculate / Populate amts. based on Primary SOB.

      l_fin_info.cost            := px_asset_fin_rec.cost;
      l_fin_info.salvage_value   := px_asset_fin_rec.salvage_value;


      if not fa_asset_calc_pvt.calc_deprn_limit_adj_rec_cost
            (p_asset_hdr_rec           => px_asset_hdr_rec,
             p_asset_type_rec          => p_asset_type_rec,
             p_asset_fin_rec_old       => l_asset_fin_rec,
             p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
             px_asset_fin_rec_new      => l_asset_fin_rec_new,
             p_mrc_sob_type_code       => l_reporting_flag,
             p_log_level_rec           => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      if (l_asset_fin_rec_new.adjusted_recoverable_cost is not null) then
          l_fin_info.rec_cost     := l_asset_fin_rec_new.adjusted_recoverable_cost;
      else
          l_fin_info.rec_cost     := l_asset_fin_rec_new.recoverable_cost;
      end if;

      l_fin_info.adj_cost        := l_fin_info.rec_cost;
      l_fin_info.rate_adj_factor := px_asset_fin_rec.rate_adjustment_factor;
      l_fin_info.reval_amo_basis := px_asset_fin_rec.reval_amortization_basis;
      l_asset_tax_rsv_adj_rec.adjusted_ytd_deprn := p_asset_tax_rsv_adj_rec.adjusted_ytd_deprn;

      -- (3) Fin_info : End of loading l_fin_info.

      -- Bug 4597471 -- Insert into fa_transaction_headers. only when the mode is 'RUN'

      if (l_asset_tax_rsv_adj_rec.run_mode = 'RUN') then

	  -- Generate Thid nextval sequence for PSOB.

	  select fa_transaction_headers_s.nextval
	  into   px_trans_rec.transaction_header_id
	  from   dual;

	  l_fin_info.transaction_id := px_trans_rec.transaction_header_id;--vmarella

	  -- SLA UPTAKE
	  -- assign an event for the transaction
	  -- at this point key info asset/book/trx info is known from above code

	  if not fa_xla_events_pvt.create_transaction_event
	 	   (p_asset_hdr_rec => px_asset_hdr_rec,
		    p_asset_type_rec=> p_asset_type_rec,
	 	    px_trans_rec    => px_trans_rec,
		    p_event_status  => NULL,
		    p_calling_fn    => l_calling_fn,
		    p_log_level_rec => p_log_level_rec
		   ) then
	     raise tax_rsv_adj_err;
	  end if;


	  FA_TRANSACTION_HEADERS_PKG.Insert_Row
		 (X_Rowid                          => l_th_rowid,
		  X_Transaction_Header_Id          => px_trans_rec.transaction_header_id,
		  X_Book_Type_Code                 => px_asset_hdr_rec.book_type_code,
		  X_Asset_Id                       => px_asset_hdr_rec.asset_id,
		  X_Transaction_Type_Code          => px_trans_rec.transaction_type_code,
		  X_Transaction_Date_Entered       => px_trans_rec.transaction_date_entered,
		  X_Date_Effective                 => px_trans_rec.who_info.creation_date,
		  X_Last_Update_Date               => px_trans_rec.who_info.last_update_date,
		  X_Last_Updated_By                => px_trans_rec.who_info.last_updated_by,
		  X_Transaction_Name               => px_trans_rec.transaction_name,
		  X_Invoice_Transaction_Id         => NULL,
		  X_Source_Transaction_Header_Id   => px_trans_rec.Source_Transaction_Header_Id,
		  X_Mass_Reference_Id              => px_trans_rec.mass_reference_id,
		  X_Last_Update_Login              => px_trans_rec.who_info.last_update_login,
		  X_Transaction_Subtype            => px_trans_rec.transaction_subtype,
		  X_Attribute1                     => px_trans_rec.desc_flex.attribute1,
		  X_Attribute2                     => px_trans_rec.desc_flex.attribute2,
		  X_Attribute3                     => px_trans_rec.desc_flex.attribute3,
		  X_Attribute4                     => px_trans_rec.desc_flex.attribute4,
		  X_Attribute5                     => px_trans_rec.desc_flex.attribute5,
		  X_Attribute6                     => px_trans_rec.desc_flex.attribute6,
		  X_Attribute7                     => px_trans_rec.desc_flex.attribute7,
		  X_Attribute8                     => px_trans_rec.desc_flex.attribute8,
		  X_Attribute9                     => px_trans_rec.desc_flex.attribute9,
		  X_Attribute10                    => px_trans_rec.desc_flex.attribute10,
		  X_Attribute11                    => px_trans_rec.desc_flex.attribute11,
		  X_Attribute12                    => px_trans_rec.desc_flex.attribute12,
		  X_Attribute13                    => px_trans_rec.desc_flex.attribute13,
		  X_Attribute14                    => px_trans_rec.desc_flex.attribute14,
		  X_Attribute15                    => px_trans_rec.desc_flex.attribute15,
		  X_Attribute_Category_Code        => px_trans_rec.desc_flex.attribute_category_code,
		  X_Transaction_Key                => px_trans_rec.transaction_key,
		  X_Amortization_Start_Date        => px_trans_rec.amortization_start_date,
		  X_Calling_Interface              => px_trans_rec.calling_interface,
		  X_Mass_Transaction_ID            => px_trans_rec.mass_transaction_id,
		  X_Member_Transaction_Header_Id   => px_trans_rec.member_transaction_header_id,
		  X_Trx_Reference_Id               => px_trans_rec.trx_reference_id,
		  X_event_Id                       => px_trans_rec.event_id,
		  X_Return_Status                  => l_status,
		  X_Calling_Fn                     => l_calling_fn,
		  p_log_level_rec                  => p_log_level_rec
		 );

	   if not l_status then
		raise tax_rsv_adj_err;
	   end if;

	end if;  -- Run_mode checking

   else   -- for reporting = 'R'.

      -- get the latest average rate (used conditionally in some cases below)

      if not fa_mc_util_pvt.get_latest_rate
            (p_asset_id            => px_asset_hdr_rec.asset_id,
             p_book_type_code      => px_asset_hdr_rec.book_type_code,
             p_set_of_books_id     => px_asset_hdr_rec.set_of_books_id,
             px_rate               => l_exchange_rate,
             px_avg_exchange_rate  => l_avg_rate,
             p_log_level_rec       => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      -- (4) Fin_info : Calculate / Populate amts. based on Reporting SOB.

      l_fin_info.cost            := l_asset_fin_rec.cost * l_avg_rate;
      l_fin_info.salvage_value   := l_asset_fin_rec.salvage_value * l_avg_rate;

      if not fa_asset_calc_pvt.calc_deprn_limit_adj_rec_cost
            (p_asset_hdr_rec           => px_asset_hdr_rec,
             p_asset_type_rec          => p_asset_type_rec,
             p_asset_fin_rec_old       => l_asset_fin_rec,
             p_asset_fin_rec_adj       => l_asset_fin_rec_adj, -- NULL;
             px_asset_fin_rec_new      => l_asset_fin_rec_new,
             p_mrc_sob_type_code       => l_reporting_flag,
             p_log_level_rec           => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      if (l_asset_fin_rec_new.adjusted_recoverable_cost is not null) then
          l_fin_info.rec_cost     := l_asset_fin_rec_new.adjusted_recoverable_cost * l_avg_rate;
      else
          l_fin_info.rec_cost     := l_asset_fin_rec_new.recoverable_cost * l_avg_rate;
      end if;

      l_fin_info.adj_cost        := l_fin_info.rec_cost * l_avg_rate;
      l_fin_info.rate_adj_factor := px_asset_fin_rec.rate_adjustment_factor * l_avg_rate;
      l_fin_info.reval_amo_basis := px_asset_fin_rec.reval_amortization_basis * l_avg_rate;
      l_asset_tax_rsv_adj_rec.adjusted_ytd_deprn := p_asset_tax_rsv_adj_rec.adjusted_ytd_deprn * l_avg_rate;

      -- (4) Fin_info : End of loading l_fin_info.

      -- for reporting currency round to correct precision.

      if not fa_utils_pkg.faxrnd
            (x_amount => l_fin_info.cost,
             x_book   => px_asset_hdr_rec.book_type_code,
             x_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
             p_log_level_rec     => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      if not fa_utils_pkg.faxrnd
            (x_amount => l_fin_info.salvage_value,
             x_book   => px_asset_hdr_rec.book_type_code,
             x_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
             p_log_level_rec     => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      if not fa_utils_pkg.faxrnd
            (x_amount => l_fin_info.rec_cost,
             x_book   => px_asset_hdr_rec.book_type_code,
             x_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
             p_log_level_rec     => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      if not fa_utils_pkg.faxrnd
            (x_amount => l_fin_info.adj_cost,
             x_book   => px_asset_hdr_rec.book_type_code,
             x_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
             p_log_level_rec     => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      if not fa_utils_pkg.faxrnd
            (x_amount => l_fin_info.rate_adj_factor,
             x_book   => px_asset_hdr_rec.book_type_code,
             x_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
             p_log_level_rec     => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      if not fa_utils_pkg.faxrnd
            (x_amount => l_fin_info.reval_amo_basis,
             x_book   => px_asset_hdr_rec.book_type_code,
             x_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
             p_log_level_rec     => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      if not fa_utils_pkg.faxrnd
            (x_amount => l_asset_tax_rsv_adj_rec.adjusted_ytd_deprn,
             x_book   => px_asset_hdr_rec.book_type_code,
             x_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
             p_log_level_rec     => p_log_level_rec
            ) then
         raise tax_rsv_adj_err;
      end if;

      -- Get asset_fin_rec for mrc

      if not FA_UTIL_PVT.get_asset_fin_rec
            (P_ASSET_HDR_REC         => px_asset_hdr_rec,
             px_asset_fin_rec        => l_asset_fin_rec,
             p_transaction_header_id => NULL,
             p_mrc_sob_type_code     => l_reporting_flag,
             p_log_level_rec         => p_log_level_rec
            ) then
          raise tax_rsv_adj_err;
      end if;


   end if; --l_reporting_flag


   -- Initialize variables

   l_cur_dpr_rsv := 0;
   l_old_dpr_rsv := 0;
   l_new_dpr_rsv := 0;
   l_new_adj_cost := 0;
   l_adj_amount := 0;
   l_total_adjs := 0;
   l_signed_adj_amt := 0;
   l_last_year_old_dpr_rsv := 0;
   l_asset_deprn_rec_old.deprn_reserve := 0;
   l_asset_deprn_rec_new.deprn_reserve := 0;
   l_fin_info.adj_capacity := 0;   -- MVK : Just why we doing this.

   -- Build the depreciation structure

   -- MVK  fa_exp_pvt.faxbds ???? refer FAVAMRTB.pls for its usage.
/*
  if not FA_EXP_PVT.faxbds
           (PX_ASSET_HDR_REC      => px_asset_hdr_rec,
            px_asset_fin_rec_new => l_asset_fin_rec,
            p_asset_deprn_rec    => l_asset_deprn_rec,
            p_asset_desc_rec     => p_asset_desc_rec,
            X_dpr_ptr            => dpr,
            X_deprn_rsv          => l_cur_deprn_rsv,
            X_bonus_deprn_rsv    => l_cur_bonus_deprn_rsv,
            p_amortized_flag     => FALSE,
            p_mrc_sob_type_code  => p_mrc_sob_type_code) then
      fa_srvr_msg.add_message (calling_fn => l_calling_fn);
      return (FALSE);
   end if;
*/

   if not fa_exp_pkg.faxbds
         (l_fin_info,
          dpr,
          l_dummy_varch,
          l_asset_deprn_rec_new.deprn_reserve,
          FALSE,
          l_reporting_flag,
          p_log_level_rec     => p_log_level_rec
         ) then
      raise TAX_RSV_ADJ_ERR;
   end if;

   -- Get calendar period information from cache

   if not fa_cache_pkg.fazcct (dpr.calendar_type,
                               p_log_level_rec => p_log_level_rec) then
          raise TAX_RSV_ADJ_ERR;
   end if;

   l_pers_per_yr := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

   -- Get current fiscal year and Deprn_Adjustment_Acct from FA_BOOK_CONTROLS

   if not fa_cache_pkg.fazcbc(l_fin_info.book,
                              p_log_level_rec  => p_log_level_rec) then
          raise TAX_RSV_ADJ_ERR;
   end if;

   l_cur_period_rec.fiscal_year := fa_cache_pkg.fazcbc_record.CURRENT_FISCAL_YEAR;

   l_adj_acct := fa_cache_pkg.fazcbc_record.DEPRN_ADJUSTMENT_ACCT;

   -- Get the Deprn Accounts for insertion into FA_ADJ.

   if not fa_cache_pkg.fazccb
         (l_fin_info.book,
          l_fin_info.category_id,
          p_log_level_rec     => p_log_level_rec )then
          raise TAX_RSV_ADJ_ERR;
   end if;

   l_rsv_acct := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
   l_exp_acct := fa_cache_pkg.fazccb_record.DEPRN_EXPENSE_ACCT;

   -- Bug 4597471 -- cost Account for inserting into interface table when run_mode is 'PREVIEW'
   l_cost_acct := fa_cache_pkg.fazccb_record.ASSET_COST_ACCT;

   -- Get the deprn basis rule

   if not fa_cache_pkg.fazccmt
               ( dpr.method_code,
                 dpr.life,
                 p_log_level_rec     => p_log_level_rec) then
          raise TAX_RSV_ADJ_ERR;
   end if;

   l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;


   -- Calculate the LTD deprn_rsv.
   -- Initialize...

   dpr_row.asset_id := l_fin_info.asset_id;
   dpr_row.book := l_fin_info.book;
   dpr_row.dist_id := 0;
   dpr_row.mrc_sob_type_code := l_reporting_flag;
   dpr_row.set_of_books_id := px_asset_hdr_rec.set_of_books_id;

   -- MVK : i guess I can avoid this call ... since we are passing the delta rsv.
   --       Can move this logic into the FAPAPIB.pls

   dpr_row.period_ctr := 0;

   FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
               dpr_row,
               'ADJUSTED',
               FALSE,
               l_dummy_bool,
               'fa_tax_rsv_adj_pvt.do_tax_rsv_adj',
               -1,
               p_log_level_rec     => p_log_level_rec);


   if not (l_dummy_bool) then
         raise TAX_RSV_ADJ_ERR;
   elsif (dpr_row.period_ctr <> 0) then
         l_cur_dpr_rsv := dpr_row.deprn_rsv;
   else
         raise TAX_RSV_ADJ_ERR;
   end if;

   -- MVK. Upto here.

   -- Old Deprn Reserve for the FY where Tax rsv. adjusted.

   dpr_row.period_ctr := l_asset_tax_rsv_adj_rec.max_period_ctr_adjusted;

   FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
               dpr_row,
               'ADJUSTED',
               FALSE,
               l_dummy_bool,
               'fa_tax_rsv_adj_pvt.do_tax_rsv_adj',
               -1,
               p_log_level_rec     => p_log_level_rec);

   if not (l_dummy_bool) then
         raise TAX_RSV_ADJ_ERR;
   elsif (dpr_row.period_ctr <> 0) then
         l_old_dpr_rsv := dpr_row.deprn_rsv;
   else
         raise TAX_RSV_ADJ_ERR;
   end if;

   -- Bug 4597471 -- variable used for PREVIEW mode
   l_old_ytd_deprn := dpr_row.ytd_deprn;

   -- Initialize variables for loop

   --Bug7630553: fa_tax_rsv_adj_pub.do_tax_rsv_adj is expecting delta reserve between current one and user specified reserve
   l_adj_amount := l_asset_tax_rsv_adj_rec.adjusted_ytd_deprn;
   l_new_dpr_rsv := l_old_dpr_rsv + l_adj_amount;
   l_new_rate_adj_factor := l_fin_info.rate_adj_factor;
   l_new_adj_cost := l_fin_info.rec_cost - l_new_dpr_rsv;
   l_total_adjs := l_adj_amount;




   -- Make sure the reserve doesn't exceed recoverable cost
   -- For NBV check for current open period. Also check end of fy since
   -- following fy's will be checked by deprn engine calls

   if (l_deprn_basis_rule = fa_std_types.FAD_DBR_COST) then

       if  (l_fin_info.rec_cost > 0 and
            l_fin_info.rec_cost < (l_cur_dpr_rsv + l_adj_amount)) or
           (l_fin_info.rec_cost < 0 and
            l_fin_info.rec_cost > (l_cur_dpr_rsv + l_adj_amount)) then

            l_adj_amount := l_fin_info.rec_cost;

       end if;

   else   -- NBV

       if  (l_fin_info.rec_cost > 0 and
            l_fin_info.rec_cost < l_new_dpr_rsv) or
           (l_fin_info.rec_cost < 0 and
            l_fin_info.rec_cost > l_new_dpr_rsv) then

            l_adj_amount := l_fin_info.rec_cost;

       end if;

   end if;

   /*
    * Insert the adjustment row for the first fiscal year adjusted
    * using the Insert into FA_ADJUSTMENTS function*/
   /*
    * Bug 4597471  -- only when the run_mode is 'RUN' we need to insert into FA_ADJUSTMENTS
    *
    */
   if (l_asset_tax_rsv_adj_rec.run_mode = 'RUN') then

        l_adj.transaction_header_id := l_fin_info.transaction_id;
        l_adj.source_type_code := 'TAX';
        l_adj.code_combination_id := 0;    -- ??
        l_adj.book_type_code := l_fin_info.book;
        l_adj.period_counter_created := l_fin_info.period_ctr;
        l_adj.asset_id := l_fin_info.asset_id;
        l_adj.adjustment_amount := abs(l_adj_amount);
        l_adj.annualized_adjustment := 0;
        l_adj.period_counter_adjusted := l_asset_tax_rsv_adj_rec.max_period_ctr_adjusted;
        l_adj.distribution_id := 0;
        l_adj.last_update_date := l_fin_info.current_time;
        l_adj.current_units := l_fin_info.units;
        l_adj.selection_mode := fa_std_types.FA_AJ_ACTIVE;

   --   l_adj.flush_adj_flag := TRUE;    -- ** ** ** MVK ??

        l_adj.flush_adj_flag := FALSE;

        l_adj.gen_ccid_flag := TRUE;
        l_adj.leveling_flag := TRUE;
        l_adj.asset_invoice_id := 0;

        l_adj.account_type := 'DEPRN_RESERVE_ACCT';
        l_adj.adjustment_type := 'RESERVE';
        l_adj.account := l_rsv_acct;

        if (l_adj_amount < 0) then
            l_adj.debit_credit_flag := 'DR';
        else
            l_adj.debit_credit_flag := 'CR';
        end if;

        l_adj.mrc_sob_type_code := l_reporting_flag;
        l_adj.set_of_books_id := px_asset_hdr_rec.set_of_books_id;

        if not FA_INS_ADJUST_PKG.faxinaj
              (adj_ptr_passed  => l_adj,
               p_log_level_rec => p_log_level_rec
               ) then
           raise TAX_RSV_ADJ_ERR;
        end if;

        l_adj.account_type := 'DEPRN_ADJUSTMENT_ACCT';
        l_adj.adjustment_type := 'DEPRN ADJUST';
        l_adj.account := l_adj_acct;

        if (l_adj_amount < 0) then
           l_adj.debit_credit_flag := 'CR';
        else
           l_adj.debit_credit_flag := 'DR';
        end if;

        l_adj.flush_adj_flag := TRUE;

        if (not FA_INS_ADJUST_PKG.faxinaj
              (adj_ptr_passed  => l_adj,
               p_log_level_rec => p_log_level_rec)) then
           raise TAX_RSV_ADJ_ERR;
        end if;


 /*
  * We're done if deprn method is not based on the net book value;
  * (We don't want to insert any more FA_ADJUSTMENTS rows, and
  * don't want to terminate and insert FA_BOOKS rows, for non NBV-based
  * assets unless asset is no longer fully reserved.
  */

   	if l_deprn_basis_rule = fa_std_types.FAD_DBR_COST then

	   If (( l_asset_fin_rec.period_counter_fully_reserved > 0 ) and
		  ( l_new_dpr_rsv < l_fin_info.rec_cost ))then

		   If  (l_asset_tax_rsv_adj_rec.deprn_basis_formula = 'STRICT_FLAT' ) then
				l_annual_deprn_rounding_flag := l_asset_fin_rec.annual_deprn_rounding_flag;
		   else
				l_annual_deprn_rounding_flag :=  'ADJ';
		   end if;


		   -- terminate/insert fa_books rows
		   -- terminate the active row

		   fa_books_pkg.deactivate_row
			 (X_asset_id                  => px_asset_hdr_rec.asset_id,
			  X_book_type_code            => px_asset_hdr_rec.book_type_code,
			  X_transaction_header_id_out => px_trans_rec.transaction_header_id,
			  X_date_ineffective          => px_trans_rec.who_info.last_update_date,
			  X_mrc_sob_type_code         => l_reporting_flag,
                          X_set_of_books_id           => px_asset_hdr_rec.set_of_books_id,
			  X_Calling_Fn                => l_calling_fn,
			  p_log_level_rec             => p_log_level_rec
			 );

		   -- fa books
		   fa_books_pkg.insert_row
			 (X_Rowid                        => l_bks_rowid,
			  X_Book_Type_Code               => px_asset_hdr_rec.book_type_code,
			  X_Asset_Id                     => px_asset_hdr_rec.asset_id,
			  X_Date_Placed_In_Service       => l_asset_fin_rec.date_placed_in_service,
			  X_Date_Effective               => px_trans_rec.who_info.last_update_date,
			  X_Deprn_Start_Date             => l_asset_fin_rec.deprn_start_date,
			  X_Deprn_Method_Code            => l_asset_fin_rec.deprn_method_code,
			  X_Life_In_Months               => l_asset_fin_rec.life_in_months,
			  X_Rate_Adjustment_Factor       => l_fin_info.rate_adj_factor,  -- MVK will change.
			  X_Adjusted_Cost                => l_fin_info.adj_cost,           -- MVK will change.
			  X_Cost                         => l_asset_fin_rec.cost,
			  X_Original_Cost                => l_asset_fin_rec.original_cost,
			  X_Salvage_Value                => l_asset_fin_rec.salvage_value,
			  X_Prorate_Convention_Code      => l_asset_fin_rec.prorate_convention_code,
			  X_Prorate_Date                 => l_asset_fin_rec.prorate_date,
			  X_Cost_Change_Flag             => l_asset_fin_rec.cost_change_flag,
			  X_Adjustment_Required_Status   => l_asset_fin_rec.adjustment_required_status,
			  X_Capitalize_Flag              => l_asset_fin_rec.capitalize_flag,
			  X_Retirement_Pending_Flag      => l_asset_fin_rec.retirement_pending_flag,
			  X_Depreciate_Flag              => l_asset_fin_rec.depreciate_flag,
			  X_Disabled_Flag                => l_asset_fin_rec.disabled_flag,--HH
			  X_Last_Update_Date             => px_trans_rec.who_info.last_update_date,
			  X_Last_Updated_By              => px_trans_rec.who_info.last_updated_by,
			  X_Date_Ineffective             => NULL,      -- MVK will change.
			  X_Transaction_Header_Id_In     => l_fin_info.transaction_id,  -- MVK will change.
			  X_Transaction_Header_Id_Out    => NULL,           -- MVK will change.
			  X_Itc_Amount_Id                => l_asset_fin_rec.itc_amount_id,
			  X_Itc_Amount                   => l_asset_fin_rec.itc_amount,
			  X_Retirement_Id                => l_asset_fin_rec.retirement_id,
			  X_Tax_Request_Id               => l_asset_fin_rec.tax_request_id,
			  X_Itc_Basis                    => l_asset_fin_rec.itc_basis,
			  X_Basic_Rate                   => l_asset_fin_rec.basic_rate,
			  X_Adjusted_Rate                => l_asset_fin_rec.adjusted_rate,
			  X_Bonus_Rule                   => l_asset_fin_rec.bonus_rule,
			  X_Ceiling_Name                 => l_asset_fin_rec.ceiling_name,
			  X_Recoverable_Cost             => l_asset_fin_rec.recoverable_cost,
			  X_Last_Update_Login            => px_trans_rec.who_info.last_update_login,
			  X_Adjusted_Capacity            => l_asset_fin_rec.adjusted_capacity,
			  X_Fully_Rsvd_Revals_Counter    => l_asset_fin_rec.fully_rsvd_revals_counter,
			  X_Idled_Flag                   => l_asset_fin_rec.idled_flag,
			  X_Period_Counter_Capitalized   => l_asset_fin_rec.period_counter_capitalized,
			  X_PC_Fully_Reserved            => l_asset_fin_rec.period_counter_fully_reserved,  -- MVK will change
			  X_Period_Counter_Fully_Retired => l_asset_fin_rec.period_counter_fully_retired,
			  X_Production_Capacity          => l_asset_fin_rec.production_capacity,
			  X_Reval_Amortization_Basis     => l_asset_fin_rec.reval_amortization_basis,
			  X_Reval_Ceiling                => l_asset_fin_rec.reval_ceiling,
			  X_Unit_Of_Measure              => l_asset_fin_rec.unit_of_measure,
			  X_Unrevalued_Cost              => l_asset_fin_rec.unrevalued_cost,
			  X_Annual_Deprn_Rounding_Flag   => l_annual_deprn_rounding_flag,  -- MVK will change
			  X_Percent_Salvage_Value        => l_asset_fin_rec.percent_salvage_value,
			  X_Allowed_Deprn_Limit          => l_asset_fin_rec.allowed_deprn_limit,
			  X_Allowed_Deprn_Limit_Amount   => l_asset_fin_rec.allowed_deprn_limit_amount,
			  X_Period_Counter_Life_Complete => l_asset_fin_rec.period_counter_life_complete,
			  X_Adjusted_Recoverable_Cost    => l_asset_fin_rec.adjusted_recoverable_cost,
			  X_Short_Fiscal_Year_Flag       => l_asset_fin_rec.short_fiscal_year_flag,
			  X_Conversion_Date              => l_asset_fin_rec.conversion_date,
			  X_Orig_Deprn_Start_Date        => l_asset_fin_rec.orig_deprn_start_date,
			  X_Remaining_Life1              => l_asset_fin_rec.remaining_life1,
			  X_Remaining_Life2              => l_asset_fin_rec.remaining_life2,
			  X_Old_Adj_Cost                 => l_asset_fin_rec.old_adjusted_cost,
			  X_Formula_Factor               => l_asset_fin_rec.formula_factor,
			  X_gf_Attribute1                => l_asset_fin_rec.global_attribute1,
			  X_gf_Attribute2                => l_asset_fin_rec.global_attribute2,
			  X_gf_Attribute3                => l_asset_fin_rec.global_attribute3,
			  X_gf_Attribute4                => l_asset_fin_rec.global_attribute4,
			  X_gf_Attribute5                => l_asset_fin_rec.global_attribute5,
			  X_gf_Attribute6                => l_asset_fin_rec.global_attribute6,
			  X_gf_Attribute7                => l_asset_fin_rec.global_attribute7,
			  X_gf_Attribute8                => l_asset_fin_rec.global_attribute8,
			  X_gf_Attribute9                => l_asset_fin_rec.global_attribute9,
			  X_gf_Attribute10               => l_asset_fin_rec.global_attribute10,
			  X_gf_Attribute11               => l_asset_fin_rec.global_attribute11,
			  X_gf_Attribute12               => l_asset_fin_rec.global_attribute12,
			  X_gf_Attribute13               => l_asset_fin_rec.global_attribute13,
			  X_gf_Attribute14               => l_asset_fin_rec.global_attribute14,
			  X_gf_Attribute15               => l_asset_fin_rec.global_attribute15,
			  X_gf_Attribute16               => l_asset_fin_rec.global_attribute16,
			  X_gf_Attribute17               => l_asset_fin_rec.global_attribute17,
			  X_gf_Attribute18               => l_asset_fin_rec.global_attribute18,
			  X_gf_Attribute19               => l_asset_fin_rec.global_attribute19,
			  X_gf_Attribute20               => l_asset_fin_rec.global_attribute20,
			  X_global_attribute_category    => l_asset_fin_rec.global_attribute_category,
			  X_group_asset_id               => l_asset_fin_rec.group_asset_id,
			  X_salvage_type                 => l_asset_fin_rec.salvage_type,
			  X_deprn_limit_type             => l_asset_fin_rec.deprn_limit_type,
			  X_over_depreciate_option       => l_asset_fin_rec.over_depreciate_option,
			  X_super_group_id               => l_asset_fin_rec.super_group_id,
			  X_reduction_rate               => l_asset_fin_rec.reduction_rate,
			  X_reduce_addition_flag         => l_asset_fin_rec.reduce_addition_flag,
			  X_reduce_adjustment_flag       => l_asset_fin_rec.reduce_adjustment_flag,
			  X_reduce_retirement_flag       => l_asset_fin_rec.reduce_retirement_flag,
			  X_recognize_gain_loss          => l_asset_fin_rec.recognize_gain_loss,
			  X_recapture_reserve_flag       => l_asset_fin_rec.recapture_reserve_flag,
			  X_limit_proceeds_flag          => l_asset_fin_rec.limit_proceeds_flag,
			  X_terminal_gain_loss           => l_asset_fin_rec.terminal_gain_loss,
			  X_exclude_proceeds_from_basis  => l_asset_fin_rec.exclude_proceeds_from_basis,
			  X_retirement_deprn_option      => l_asset_fin_rec.retirement_deprn_option,
			  X_tracking_method              => l_asset_fin_rec.tracking_method,
			  X_allocate_to_fully_rsv_flag   => l_asset_fin_rec.allocate_to_fully_rsv_flag,
			  X_allocate_to_fully_ret_flag   => l_asset_fin_rec.allocate_to_fully_ret_flag,
			  X_exclude_fully_rsv_flag       => l_asset_fin_rec.exclude_fully_rsv_flag,
			  X_excess_allocation_option     => l_asset_fin_rec.excess_allocation_option,
			  X_depreciation_option          => l_asset_fin_rec.depreciation_option,
			  X_member_rollup_flag           => l_asset_fin_rec.member_rollup_flag,
			  X_ytd_proceeds                 => nvl(l_asset_fin_rec.ytd_proceeds, 0),
			  X_ltd_proceeds                 => nvl(l_asset_fin_rec.ltd_proceeds, 0),
			  X_eofy_reserve                 => l_asset_fin_rec.eofy_reserve,
			  X_terminal_gain_loss_amount    => l_asset_fin_rec.terminal_gain_loss_amount,
			  X_ltd_cost_of_removal          => nvl(l_asset_fin_rec.ltd_cost_of_removal, 0),
			  X_mrc_sob_type_code            => l_reporting_flag,
                          X_set_of_books_id              => px_asset_hdr_rec.set_of_books_id,
			  X_Return_Status                => l_status,
			  X_Calling_Fn                   => l_calling_fn,
			  p_log_level_rec                => p_log_level_rec
			 );

		if not l_status then
			raise tax_rsv_adj_err;
		else
			return (TRUE);
		end if;
	   end if;
	end if;
    end if;  /* run_mode checking */


   -- For NBV basis ... and strict_ flat..  Will go with the existing logic for now ??
   /*
    * Main driving loop for this program. Loop for each fiscal year after
    * the adjustment; recalculate reserve up until the last closed period
    */

   open fiscal_year_cr(l_fin_info.book,l_cur_period_rec.fiscal_year);

   loop

        fetch fiscal_year_cr into l_period_rec.fiscal_year,l_period_rec.period_num, l_period_rec.period_counter;
        exit when fiscal_year_cr%notfound;


        -- Set the deprn struct parms to calculate deprn reserve
        dpr.y_begin := l_period_rec.fiscal_year;
        dpr.y_end := l_period_rec.fiscal_year;
        dpr.p_cl_begin := 1;
        dpr.p_cl_end := l_period_rec.period_num;
        dpr.deprn_rsv := l_new_dpr_rsv;
        dpr.adj_cost := l_new_adj_cost;
        dpr.mrc_sob_type_code := l_reporting_flag;
        dpr.set_of_books_id := px_asset_hdr_rec.set_of_books_id;

        --

        -- Call deprn engine to calc new reserve.
        if not fa_cde_pkg.faxcde (
             dpr,
             l_dummy_dpr_arr,
             dpr_out,
             fa_std_types.FA_DPR_NORMAL,
             p_log_level_rec     => p_log_level_rec
             ) then
           raise tax_rsv_adj_err;
        end if;


        -- Set the new_adj_cost and new_deprn_rsv to the value
        -- recalculated by deprn
        l_new_adj_cost := dpr_out.new_adj_cost;
        l_new_dpr_rsv := dpr_out.new_deprn_rsv;

        -- Get the adjusted cost and the reserve previously taken as of
        -- the end of the fiscal year, or the last closed deprn period

        l_last_year_old_dpr_rsv := l_old_dpr_rsv;


        -- MVK
        dpr_row.asset_id := l_fin_info.asset_id;
        dpr_row.book := l_fin_info.book;
        dpr_row.dist_id := 0;
        dpr_row.period_ctr := l_period_rec.period_counter;
        dpr_row.mrc_sob_type_code := l_reporting_flag;
        dpr_row.set_of_books_id := px_asset_hdr_rec.set_of_books_id;

        /*
         * Use the Query Fin Info function to get the reserve as of
         * this period.
         */

         FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
             dpr_row,
            'STANDARD',
             FALSE,
             l_dummy_bool,
             l_calling_fn,
             -1,
             p_log_level_rec     => p_log_level_rec);

         if not (l_dummy_bool) then
            fa_srvr_msg.add_message (calling_fn => l_calling_fn,
                                     p_log_level_rec     => p_log_level_rec);
            return (FALSE);
         end if;

        l_asset_deprn_rec_old.deprn_reserve := dpr_row.deprn_rsv;
        l_old_adj_cost := dpr_row.adj_cost;


        -- UPTO here

        -- Calculate the adjustment amount , new_adjusted_cost, total adjustments

        l_adj_amount   := l_new_dpr_rsv - (l_asset_deprn_rec_old.deprn_reserve + l_total_adjs);
        l_new_adj_cost := l_fin_info.rec_cost - l_new_dpr_rsv;
        l_total_adjs   := l_total_adjs + l_adj_amount;

        -- Process the adjustment rows for this fiscal year

        /*
         * Call the Insert into FA_ADJUSTMENTS function
         * for EXPENSE adjustment; use the CCID from FA_DISTRIBUTION_HISTORY,
         * so set adj.ccid = 0 and gen_ccid_flag = FALSE
         */

        l_adj.transaction_header_id := l_fin_info.transaction_id;
        l_adj.source_type_code := 'TAX';
        l_adj.adjustment_type := 'EXPENSE';
        l_adj.code_combination_id := 0;
        l_adj.book_type_code := l_fin_info.book;
        l_adj.period_counter_created := l_fin_info.period_ctr;
        l_adj.asset_id := l_fin_info.asset_id;
        l_adj.adjustment_amount := abs(l_adj_amount);
        l_adj.period_counter_adjusted := l_period_rec.period_counter;
        l_adj.distribution_id := 0;


        /*
         * If this is the current fiscal year, then annualized adjustment
         * is the difference between the new annualized expense and
         * the extrapolated pre-tax-adjustment annualized expense amounts.
         */


        if l_cur_period_rec.fiscal_year = l_period_rec.fiscal_year then

             l_new_ann_adj_exp := dpr_out.ann_adj_exp;

             -- reset deprn struct parms to calculate what the
             -- annulalized expense would have been

             dpr.p_cl_end := l_pers_per_yr;
             dpr.deprn_rsv := l_last_year_old_dpr_rsv;
             dpr.adj_cost := l_old_adj_cost;
             dpr.mrc_sob_type_code := l_reporting_flag;
             dpr.set_of_books_id := px_asset_hdr_rec.set_of_books_id;

             -- Call deprn engine to calc expense

             if not fa_cde_pkg.faxcde
                   (dpr,
                    l_dummy_dpr_arr,
                    dpr_out,
                    fa_std_types.FA_DPR_NORMAL,
                    p_log_level_rec     => p_log_level_rec
                   ) then
                raise tax_rsv_adj_err;
             end if;

             l_adj.annualized_adjustment := l_new_ann_adj_exp - dpr_out.ann_adj_exp;

        else

             l_adj.annualized_adjustment := 0;

        end if;

	/* Bug 4597471 -- insert into FA_ADJUSTMENTS only if the run_mode is 'RUN' */

	if (l_asset_tax_rsv_adj_rec.run_mode = 'RUN') then

		l_adj.last_update_date := l_fin_info.current_time;
		l_adj.current_units := l_fin_info.units;
		l_adj.selection_mode := fa_std_types.FA_AJ_ACTIVE;
		l_adj.flush_adj_flag := TRUE;    -- MVK ??
		l_adj.gen_ccid_flag := TRUE;
		l_adj.asset_invoice_id := 0;
		l_adj.leveling_flag := TRUE;
		l_adj.account_type := 'DEPRN_EXPENSE_ACCT';
		l_adj.account := l_exp_acct;

		if (l_adj_amount < 0) then
			 l_adj.debit_credit_flag := 'CR';
		else
			 l_adj.debit_credit_flag := 'DR';
		end if;

		l_adj.mrc_sob_type_code := l_reporting_flag;
                l_adj.set_of_books_id := px_asset_hdr_rec.set_of_books_id;

		if not FA_INS_ADJUST_PKG.faxinaj
			  (adj_ptr_passed => l_adj,
			   p_log_level_rec     => p_log_level_rec) then
			 raise tax_rsv_adj_err;
		end if;
	end if;
   end loop;

   close fiscal_year_cr;

   /*
    * This is like Strict Calculation Basis
    * If user choose to do this, then reset adjusted cost to
    * the adjusted cost as of beggining of current fiscal year
    */
   -- Bug 3045324 : Added the if ..else stmt.

   if (l_adj.debit_credit_flag = 'DR') then
      l_signed_adj_amount := -1 * nvl(l_adj.adjustment_amount, 0);
   else
      l_signed_adj_amount := nvl(l_adj.adjustment_amount, 0);
   end if;

   if ( (l_asset_tax_rsv_adj_rec.deprn_basis_formula = 'STRICT_FLAT') and
       (nvl(dpr.ytd_deprn, 0) <> 0) ) then
      l_new_adj_cost := l_new_adj_cost + nvl(dpr.ytd_deprn, 0) - nvl(l_signed_adj_amount, 0);
   end if;


   /*
    * terminate the current FA_BOOKS row; and insert a new one, with
    * the updated adjusted cost and rate adjustment factor
    * we only do this for assets with an NBV-based deprn method
    * and if this is not the year of adjustment
    */

   if l_new_dpr_rsv < l_fin_info.rec_cost then
      l_rsv_flag := TRUE;
   end if;

   If  (l_asset_tax_rsv_adj_rec.deprn_basis_formula = 'STRICT_FLAT' ) then
       l_annual_deprn_rounding_flag := l_asset_fin_rec.annual_deprn_rounding_flag;
   else
       l_annual_deprn_rounding_flag :=  'ADJ';
   end if;

   -- terminate/insert fa_books rows
   -- terminate the active row
   -- Bug 4597471 -- only if the run_mode is 'RUN'

   if (l_asset_tax_rsv_adj_rec.run_mode = 'RUN') then

      fa_books_pkg.deactivate_row
	  (X_asset_id                  => px_asset_hdr_rec.asset_id,
	   X_book_type_code            => px_asset_hdr_rec.book_type_code,
	   X_transaction_header_id_out => px_trans_rec.transaction_header_id,
	   X_date_ineffective          => px_trans_rec.who_info.last_update_date,
	   X_mrc_sob_type_code         => l_reporting_flag,
           X_set_of_books_id           => px_asset_hdr_rec.set_of_books_id,
	   X_Calling_Fn                => l_calling_fn,
	   p_log_level_rec             => p_log_level_rec
	  );

      -- fa books

      fa_books_pkg.insert_row
	 (X_Rowid                        => l_bks_rowid,
	  X_Book_Type_Code               => px_asset_hdr_rec.book_type_code,
	  X_Asset_Id                     => px_asset_hdr_rec.asset_id,
	  X_Date_Placed_In_Service       => l_asset_fin_rec.date_placed_in_service,
	  X_Date_Effective               => px_trans_rec.who_info.last_update_date,
	  X_Deprn_Start_Date             => l_asset_fin_rec.deprn_start_date,
	  X_Deprn_Method_Code            => l_asset_fin_rec.deprn_method_code,
	  X_Life_In_Months               => l_asset_fin_rec.life_in_months,
	  X_Rate_Adjustment_Factor       => l_fin_info.rate_adj_factor,  -- MVK will change.
	  X_Adjusted_Cost                => l_fin_info.adj_cost,           -- MVK will change.
	  X_Cost                         => l_asset_fin_rec.cost,
	  X_Original_Cost                => l_asset_fin_rec.original_cost,
	  X_Salvage_Value                => l_asset_fin_rec.salvage_value,
	  X_Prorate_Convention_Code      => l_asset_fin_rec.prorate_convention_code,
	  X_Prorate_Date                 => l_asset_fin_rec.prorate_date,
	  X_Cost_Change_Flag             => l_asset_fin_rec.cost_change_flag,
	  X_Adjustment_Required_Status   => l_asset_fin_rec.adjustment_required_status,
	  X_Capitalize_Flag              => l_asset_fin_rec.capitalize_flag,
	  X_Retirement_Pending_Flag      => l_asset_fin_rec.retirement_pending_flag,
	  X_Depreciate_Flag              => l_asset_fin_rec.depreciate_flag,
	  X_Disabled_Flag                => l_asset_fin_rec.disabled_flag,--HH
	  X_Last_Update_Date             => px_trans_rec.who_info.last_update_date,
	  X_Last_Updated_By              => px_trans_rec.who_info.last_updated_by,
	  X_Date_Ineffective             => NULL,      -- MVK will change.
	  X_Transaction_Header_Id_In     => px_trans_rec.transaction_header_id,  -- MVK will change.
	  X_Transaction_Header_Id_Out    => NULL,           -- MVK will change.
	  X_Itc_Amount_Id                => l_asset_fin_rec.itc_amount_id,
	  X_Itc_Amount                   => l_asset_fin_rec.itc_amount,
	  X_Retirement_Id                => l_asset_fin_rec.retirement_id,
	  X_Tax_Request_Id               => l_asset_fin_rec.tax_request_id,
	  X_Itc_Basis                    => l_asset_fin_rec.itc_basis,
	  X_Basic_Rate                   => l_asset_fin_rec.basic_rate,
	  X_Adjusted_Rate                => l_asset_fin_rec.adjusted_rate,
	  X_Bonus_Rule                   => l_asset_fin_rec.bonus_rule,
	  X_Ceiling_Name                 => l_asset_fin_rec.ceiling_name,
	  X_Recoverable_Cost             => l_asset_fin_rec.recoverable_cost,
	  X_Last_Update_Login            => px_trans_rec.who_info.last_update_login,
	  X_Adjusted_Capacity            => l_asset_fin_rec.adjusted_capacity,
	  X_Fully_Rsvd_Revals_Counter    => l_asset_fin_rec.fully_rsvd_revals_counter,
	  X_Idled_Flag                   => l_asset_fin_rec.idled_flag,
	  X_Period_Counter_Capitalized   => l_asset_fin_rec.period_counter_capitalized,
	  X_PC_Fully_Reserved            => l_asset_fin_rec.period_counter_fully_reserved,  -- MVK will change
	  X_Period_Counter_Fully_Retired => l_asset_fin_rec.period_counter_fully_retired,
	  X_Production_Capacity          => l_asset_fin_rec.production_capacity,
	  X_Reval_Amortization_Basis     => l_asset_fin_rec.reval_amortization_basis,
	  X_Reval_Ceiling                => l_asset_fin_rec.reval_ceiling,
	  X_Unit_Of_Measure              => l_asset_fin_rec.unit_of_measure,
	  X_Unrevalued_Cost              => l_asset_fin_rec.unrevalued_cost,
	  X_Annual_Deprn_Rounding_Flag   => l_annual_deprn_rounding_flag,  -- MVK will change
	  X_Percent_Salvage_Value        => l_asset_fin_rec.percent_salvage_value,
	  X_Allowed_Deprn_Limit          => l_asset_fin_rec.allowed_deprn_limit,
	  X_Allowed_Deprn_Limit_Amount   => l_asset_fin_rec.allowed_deprn_limit_amount,
	  X_Period_Counter_Life_Complete => l_asset_fin_rec.period_counter_life_complete,
	  X_Adjusted_Recoverable_Cost    => l_asset_fin_rec.adjusted_recoverable_cost,
	  X_Short_Fiscal_Year_Flag       => l_asset_fin_rec.short_fiscal_year_flag,
	  X_Conversion_Date              => l_asset_fin_rec.conversion_date,
	  X_Orig_Deprn_Start_Date        => l_asset_fin_rec.orig_deprn_start_date,
	  X_Remaining_Life1              => l_asset_fin_rec.remaining_life1,
	  X_Remaining_Life2              => l_asset_fin_rec.remaining_life2,
	  X_Old_Adj_Cost                 => l_asset_fin_rec.old_adjusted_cost,
	  X_Formula_Factor               => l_asset_fin_rec.formula_factor,
	  X_gf_Attribute1                => l_asset_fin_rec.global_attribute1,
	  X_gf_Attribute2                => l_asset_fin_rec.global_attribute2,
	  X_gf_Attribute3                => l_asset_fin_rec.global_attribute3,
	  X_gf_Attribute4                => l_asset_fin_rec.global_attribute4,
	  X_gf_Attribute5                => l_asset_fin_rec.global_attribute5,
	  X_gf_Attribute6                => l_asset_fin_rec.global_attribute6,
	  X_gf_Attribute7                => l_asset_fin_rec.global_attribute7,
	  X_gf_Attribute8                => l_asset_fin_rec.global_attribute8,
	  X_gf_Attribute9                => l_asset_fin_rec.global_attribute9,
	  X_gf_Attribute10               => l_asset_fin_rec.global_attribute10,
	  X_gf_Attribute11               => l_asset_fin_rec.global_attribute11,
	  X_gf_Attribute12               => l_asset_fin_rec.global_attribute12,
	  X_gf_Attribute13               => l_asset_fin_rec.global_attribute13,
	  X_gf_Attribute14               => l_asset_fin_rec.global_attribute14,
	  X_gf_Attribute15               => l_asset_fin_rec.global_attribute15,
	  X_gf_Attribute16               => l_asset_fin_rec.global_attribute16,
	  X_gf_Attribute17               => l_asset_fin_rec.global_attribute17,
	  X_gf_Attribute18               => l_asset_fin_rec.global_attribute18,
	  X_gf_Attribute19               => l_asset_fin_rec.global_attribute19,
	  X_gf_Attribute20               => l_asset_fin_rec.global_attribute20,
	  X_global_attribute_category    => l_asset_fin_rec.global_attribute_category,
	  X_group_asset_id               => l_asset_fin_rec.group_asset_id,
	  X_salvage_type                 => l_asset_fin_rec.salvage_type,
	  X_deprn_limit_type             => l_asset_fin_rec.deprn_limit_type,
	  X_over_depreciate_option       => l_asset_fin_rec.over_depreciate_option,
	  X_super_group_id               => l_asset_fin_rec.super_group_id,
	  X_reduction_rate               => l_asset_fin_rec.reduction_rate,
	  X_reduce_addition_flag         => l_asset_fin_rec.reduce_addition_flag,
	  X_reduce_adjustment_flag       => l_asset_fin_rec.reduce_adjustment_flag,
	  X_reduce_retirement_flag       => l_asset_fin_rec.reduce_retirement_flag,
	  X_recognize_gain_loss          => l_asset_fin_rec.recognize_gain_loss,
	  X_recapture_reserve_flag       => l_asset_fin_rec.recapture_reserve_flag,
	  X_limit_proceeds_flag          => l_asset_fin_rec.limit_proceeds_flag,
	  X_terminal_gain_loss           => l_asset_fin_rec.terminal_gain_loss,
	  X_exclude_proceeds_from_basis  => l_asset_fin_rec.exclude_proceeds_from_basis,
	  X_retirement_deprn_option      => l_asset_fin_rec.retirement_deprn_option,
	  X_tracking_method              => l_asset_fin_rec.tracking_method,
	  X_allocate_to_fully_rsv_flag   => l_asset_fin_rec.allocate_to_fully_rsv_flag,
	  X_allocate_to_fully_ret_flag   => l_asset_fin_rec.allocate_to_fully_ret_flag,
	  X_exclude_fully_rsv_flag       => l_asset_fin_rec.exclude_fully_rsv_flag,
	  X_excess_allocation_option     => l_asset_fin_rec.excess_allocation_option,
	  X_depreciation_option          => l_asset_fin_rec.depreciation_option,
	  X_member_rollup_flag           => l_asset_fin_rec.member_rollup_flag,
	  X_ytd_proceeds                 => nvl(l_asset_fin_rec.ytd_proceeds, 0),
	  X_ltd_proceeds                 => nvl(l_asset_fin_rec.ltd_proceeds, 0),
	  X_eofy_reserve                 => l_asset_fin_rec.eofy_reserve,
	  X_terminal_gain_loss_amount    => l_asset_fin_rec.terminal_gain_loss_amount,
	  X_ltd_cost_of_removal          => nvl(l_asset_fin_rec.ltd_cost_of_removal, 0),
	  X_mrc_sob_type_code            => l_reporting_flag,
          X_set_of_books_id              => px_asset_hdr_rec.set_of_books_id,
	  X_Return_Status                => l_status,
	  X_Calling_Fn                   => l_calling_fn,
	  p_log_level_rec                => p_log_level_rec
	 );

	if not l_status then
		raise tax_rsv_adj_err;
	else
		return (TRUE);
	end if;
   end if; /* run_mode checking */

   /* Bug 4597471 -- for PREVIEW mode insert into interface table so that the preview report can just pick the
      values from the interface table */

   if not fa_utils_pkg.faxrnd
            (x_amount => l_asset_tax_rsv_adj_rec.adjusted_ytd_deprn,
             x_book   => px_asset_hdr_rec.book_type_code,
             x_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
             p_log_level_rec     => p_log_level_rec
            ) then
        raise tax_rsv_adj_err;
   end if;



   if (l_asset_tax_rsv_adj_rec.run_mode = 'PREVIEW') then
	insert into fa_mass_tax_adj_rep_t
	           (MASS_TAX_ADJ_ID			,
		   REQUEST_ID				,
		   ADJUSTED_BOOK_TYPE_CODE	        ,
		   ASSET_ID				,
		   ASSET_NUMBER				,
		   DESCRIPTION				,
		   DEPRN_RESERVE_ACCT		        ,
		   ASSET_COST_ACCT 			,
		   COST					,
		   OLD_YTD_DEPRN			,
		   ADJ_YTD_DEPRN			,
		   NEW_YTD_DEPRN			,
		   LAST_UPDATE_DATE			,
		   LAST_UPDATED_BY			,
		   CREATED_BY				,
		   CREATION_DATE			,
		   LAST_UPDATE_LOGIN		)
		values
		  (px_trans_rec.mass_transaction_id		   ,
		   px_trans_rec.mass_reference_id 		   ,
		   px_asset_hdr_rec.book_type_code		   ,
		   px_asset_hdr_rec.asset_id			   ,
		   p_asset_desc_rec.asset_number                   ,
		   p_asset_desc_rec.description			   ,
		   l_rsv_acct					   ,
		   l_cost_acct					   ,
		   l_asset_fin_rec.cost				   ,
		   l_old_ytd_deprn                         	   ,--old_ytd
		   l_asset_tax_rsv_adj_rec.adjusted_ytd_deprn - l_old_ytd_deprn,--adj_ytd
		   l_asset_tax_rsv_adj_rec.adjusted_ytd_deprn,--new_ytd_deprn
	           px_trans_rec.who_info.last_update_date          ,
		   px_trans_rec.who_info.last_updated_by           ,
		   px_trans_rec.who_info.last_updated_by           ,
		   px_trans_rec.who_info.last_update_date          ,
		   px_trans_rec.who_info.last_update_login );
   end if; /* run mode is PREVIEW */

   return TRUE;

exception
   when tax_rsv_adj_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              p_log_level_rec => p_log_level_rec);
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'tax_rsv_adj_err',
                          p_log_level_rec => p_log_level_rec);
      end if;
      return(FALSE);

   when others then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              p_log_level_rec => p_log_level_rec);
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'others',
                          p_log_level_rec => p_log_level_rec);

      end if;
      return(FALSE);
END do_tax_rsv_adj;

END FA_TAX_RSV_ADJ_PVT;

/
