--------------------------------------------------------
--  DDL for Package Body FA_ADDITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ADDITION_PVT" AS
/* $Header: FAVADDB.pls 120.42.12010000.10 2010/03/17 15:25:57 spooyath ship $   */

g_release                  number  := fa_cache_pkg.fazarel_release;

function initialize (
   -- Transaction Object --
   px_trans_rec                IN OUT NOCOPY  fa_api_types.trans_rec_type,
   px_dist_trans_rec           IN OUT NOCOPY  fa_api_types.trans_rec_type,
   -- Asset Object --
   px_asset_hdr_rec            IN OUT NOCOPY  fa_api_types.asset_hdr_rec_type,
   px_asset_desc_rec           IN OUT NOCOPY  fa_api_types.asset_desc_rec_type,
   px_asset_type_rec           IN OUT NOCOPY  fa_api_types.asset_type_rec_type,
   px_asset_cat_rec            IN OUT NOCOPY  fa_api_types.asset_cat_rec_type,
   px_asset_hierarchy_rec      IN OUT NOCOPY  fa_api_types.asset_hierarchy_rec_type,
   px_asset_fin_rec            IN OUT NOCOPY  fa_api_types.asset_fin_rec_type,
   px_asset_deprn_rec          IN OUT NOCOPY  fa_api_types.asset_deprn_rec_type,
   px_asset_dist_tbl           IN OUT NOCOPY  fa_api_types.asset_dist_tbl_type,
   -- Invoice Object --
   px_inv_tbl                  IN OUT NOCOPY  fa_api_types.inv_tbl_type,
   x_return_status                OUT NOCOPY VARCHAR2,
   p_calling_fn                IN     VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean as

   l_return_status                boolean;
   l_distribution_count           number;

   l_period_rec                   fa_api_types.period_rec_type;

   -- Category information
   l_category_chart_id            number;
   l_num_segs                     number;
   l_delimiter                    varchar2(1);
   l_segment_array                FND_FLEX_EXT.SEGMENTARRAY;
   l_concat_string                varchar2(210);

   init_err                       EXCEPTION;

--Bug# 7715087
   cursor c_get_context_date(c_book_type_code varchar2) is
   select   greatest(calendar_period_open_date,
      least(sysdate, calendar_period_close_date))
   from     fa_deprn_periods
   where    book_type_code = c_book_type_code
   and      period_close_date is null;

   l_trx_date           date;
--Bug# 7715087 end

-- Bug# 7698326 start
   l_fiscal_year                       number;
   l_number_per_fiscal_year            number;
   l_period_num                        number;
   l_period_counter_extd   number;
   ln_limit_amt            number;
   l_japan_tax_reform      varchar2(1) := fnd_profile.value('FA_JAPAN_TAX_REFORMS');


   cursor lcu_period_info(p_book_type_code in varchar2,
                          p_period         in varchar2 )   is
       select ffy.fiscal_year
             ,fcp.period_num
             ,fct.number_per_fiscal_year
       from fa_fiscal_year      ffy
           ,fa_book_controls    fbc
           ,fa_calendar_periods fcp
           ,fa_calendar_types   fct
       where ffy.fiscal_year_name = fbc.fiscal_year_name
       and ffy.fiscal_year_name   = fct.fiscal_year_name
       and fbc.book_type_code     = p_book_type_code
       and fcp.calendar_type      = fct.calendar_type
       and fct.calendar_type      = fbc.deprn_calendar
       and fcp.start_date        >= ffy.start_date
       and fcp.end_date          <= ffy.end_date
       and upper(fcp.period_name) = upper(p_period);

--Bug#7698326 End

   --Bug# 8630874 - to default value of group options from category defaults for group type asset.
   l_recognize_gain_loss          varchar2(30);
   l_terminal_gain_loss           varchar2(30);
   l_tracking_method              varchar2(30);
   l_excess_allocation_option     varchar2(30);
   l_allocate_to_fully_rsv_flag   varchar2(30);
   l_recapture_reserve_flag       varchar2(1);
   l_limit_proceeds_flag          varchar2(1);
   l_depreciation_option          varchar2(30);
   l_member_rollup_flag           varchar2(1);

   cursor c_get_group_defaults(c_book_type_code px_asset_hdr_rec.book_type_code%type,c_category_id px_asset_cat_rec.category_id%type,c_date_placed_in_service px_asset_fin_rec.date_placed_in_service%type) is
     select
         nvl(cbd.recognize_gain_loss,'NO'),
         nvl(cbd.terminal_gain_loss,'YES'),
         cbd.tracking_method,
         cbd.excess_allocation_option,
         cbd.allocate_to_fully_rsv_flag,
         cbd.Recapture_Reserve_Flag,
         decode(nvl(cbd.recognize_gain_loss,'NO'),'NO',cbd.LIMIT_PROCEEDS_FLAG,NULL),
         cbd.depreciation_option,
         cbd.member_rollup_flag
     FROM
         fa_categories cat,
         fa_category_book_defaults cbd,
         fa_methods mth,
         fa_deprn_periods dp,
         fa_deprn_basis_rules dbr
     WHERE
         dp.book_type_code = c_book_type_code and
         dp.period_close_date is null
     AND
         cbd.category_id = c_category_id    and
         cbd.book_type_code = c_book_type_code     and
         nvl(c_date_placed_in_service,
                 greatest(dp.calendar_period_open_date,
                 least(sysdate,
                 nvl(dp.calendar_period_close_date,sysdate))))
                                       >= cbd.start_dpis and
         nvl(c_date_placed_in_service,
         greatest(dp.calendar_period_open_date,
         least(sysdate,
                 nvl(dp.calendar_period_close_date,sysdate))))
          <= nvl(cbd.end_dpis,greatest(dp.calendar_period_open_date,
                 least(sysdate, dp.calendar_period_close_date))) and
         cat.category_id  = c_category_id    and
         mth.method_code  =  cbd.deprn_method              and
         decode(mth.rate_source_rule,'PRODUCTION','PROD',
                                    'FLAT','FLAT',mth.life_in_months)
         = decode(mth.rate_source_rule,
                         'PRODUCTION','PROD',
                         'FLAT','FLAT',cbd.life_in_months)      and
         mth.deprn_basis_rule_id = dbr.deprn_basis_rule_id(+);
   --Bug# 8630874 end

begin

   -- For Addition transactions, the period_of_addition flag
   -- should be 'Y'
   px_asset_hdr_rec.period_of_addition := 'Y';

   if (NOT FA_UTIL_PVT.get_period_rec (
      p_book           => px_asset_hdr_rec.book_type_code,
      p_effective_date => NULL,
      x_period_rec     => l_period_rec
   , p_log_level_rec => p_log_level_rec)) then
      raise init_err;
   end if;


-- may need to modify for group addition !!!


   -- Default transaction_subtype if needed.
   if (px_trans_rec.amortization_start_date is not null) then
      px_trans_rec.transaction_subtype := 'AMORTIZED';
      px_trans_rec.amortization_start_date :=
         to_date(to_char(px_trans_rec.amortization_start_date,'DD/MM/YYYY'),'DD/MM/YYYY');
   elsif ((px_trans_rec.amortization_start_date is null) AND
          (px_trans_rec.transaction_subtype is not null)) then

      fa_srvr_msg.add_message(
         calling_fn => 'fa_addition_pvt.initialize',
         name       => 'FA_INVALID_PARAMETER',
         token1     => 'VALUE',
         value1     => px_trans_rec.transaction_subtype,
         token2     => 'PARAM',
         value2     => 'TRANSACTION_SUBTYPE',  p_log_level_rec => p_log_level_rec);

      fa_srvr_msg.add_message(
         calling_fn => 'fa_addition_pvt.initialize',
         name       => 'FA_INVALID_PARAMETER',
         token1     => 'VALUE',
         value1     => 'NULL',
         token2     => 'PARAM',
         value2     => 'AMORTIZATION_START_DATE',  p_log_level_rec => p_log_level_rec);

       raise init_err;

   end if;

   -- Fix for Bug #2515034.  Derive current_units rather than
   -- accept value from user.
   l_distribution_count := px_asset_dist_tbl.COUNT;
   px_asset_desc_rec.current_units := 0;

   for i in 1..l_distribution_count loop
      px_asset_desc_rec.current_units := px_asset_desc_rec.current_units +
         px_asset_dist_tbl(i).units_assigned;
   end loop;

   -- For corporate books, default the following info if its null
   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

      if (px_asset_hdr_rec.asset_id is null) then
         -- Pop the asset_id
         select fa_additions_s.nextval
         into   px_asset_hdr_rec.asset_id
         from   dual;
      end if;

      -- Get defaults from the category.
      if not fa_cache_pkg.fazcat (
         X_cat_id => px_asset_cat_rec.category_id
      , p_log_level_rec => p_log_level_rec) then
         raise init_err;
      end if;

      -- Set Appropriate values to defaults if user did not provide them.
      if (px_asset_desc_rec.asset_number = FND_API.G_MISS_CHAR) then
         px_asset_desc_rec.asset_number := NULL;
      end if;

      if (px_asset_desc_rec.description = FND_API.G_MISS_CHAR) then
         px_asset_desc_rec.description := NULL;
      end if;

      if (px_asset_desc_rec.tag_number = FND_API.G_MISS_CHAR) then
         px_asset_desc_rec.tag_number := NULL;
      end if;

      if (px_asset_desc_rec.serial_number = FND_API.G_MISS_CHAR) then
         px_asset_desc_rec.serial_number := NULL;
      end if;

      if (px_asset_desc_rec.asset_key_ccid = FND_API.G_MISS_NUM) then
         px_asset_desc_rec.asset_key_ccid := NULL;
      end if;

      if (px_asset_desc_rec.parent_asset_id = FND_API.G_MISS_NUM) then
         px_asset_desc_rec.parent_asset_id := NULL;
      end if;

      if (px_asset_desc_rec.manufacturer_name = FND_API.G_MISS_CHAR) then
         px_asset_desc_rec.manufacturer_name := NULL;
      end if;

      if (px_asset_desc_rec.model_number = FND_API.G_MISS_CHAR) then
         px_asset_desc_rec.model_number := NULL;
      end if;

      if (px_asset_desc_rec.warranty_id = FND_API.G_MISS_NUM) then
         px_asset_desc_rec.warranty_id := NULL;
      end if;

      if (px_asset_desc_rec.lease_id = FND_API.G_MISS_NUM) then
         px_asset_desc_rec.lease_id := NULL;
      end if;

      if (px_asset_desc_rec.in_use_flag = FND_API.G_MISS_CHAR or
          px_asset_desc_rec.in_use_flag is null) then
         px_asset_desc_rec.in_use_flag := 'YES';
      end if;

      if (px_asset_desc_rec.inventorial = FND_API.G_MISS_CHAR or
          px_asset_desc_rec.inventorial is null) then
         px_asset_desc_rec.inventorial :=
            fa_cache_pkg.fazcat_record.inventorial;
      end if;

      if (px_asset_desc_rec.property_type_code = FND_API.G_MISS_CHAR or
          px_asset_desc_rec.property_type_code is null) then
         px_asset_desc_rec.property_type_code :=
            fa_cache_pkg.fazcat_record.property_type_code;
      end if;

      if (px_asset_desc_rec.property_1245_1250_code = FND_API.G_MISS_CHAR or
          px_asset_desc_rec.property_1245_1250_code is null) then
         px_asset_desc_rec.property_1245_1250_code :=
            fa_cache_pkg.fazcat_record.property_1245_1250_code;
      end if;

      if (px_asset_desc_rec.owned_leased = FND_API.G_MISS_CHAR or
          px_asset_desc_rec.owned_leased is null) then
         px_asset_desc_rec.owned_leased :=
            fa_cache_pkg.fazcat_record.owned_leased;
      end if;

      if (px_asset_desc_rec.new_used = FND_API.G_MISS_CHAR or
          px_asset_desc_rec.new_used is null) then
         px_asset_desc_rec.new_used := 'NEW';
      end if;

      if (px_asset_desc_rec.unit_adjustment_flag = FND_API.G_MISS_CHAR or
          px_asset_desc_rec.unit_adjustment_flag is null) then
         px_asset_desc_rec.unit_adjustment_flag := 'NO';
      end if;

      if (px_asset_desc_rec.add_cost_je_flag = FND_API.G_MISS_CHAR or
          px_asset_desc_rec.add_cost_je_flag is null) then
         px_asset_desc_rec.add_cost_je_flag := 'NO';
      end if;

      if (px_asset_desc_rec.status = FND_API.G_MISS_CHAR) then
         px_asset_desc_rec.status := NULL;
      end if;

      -- Bug:8240522
      if (px_asset_fin_rec.contract_id = FND_API.G_MISS_NUM) then
         px_asset_fin_rec.contract_id := NULL;
      end if;

      if (px_asset_fin_rec.itc_amount_id = FND_API.G_MISS_NUM) then
         px_asset_fin_rec.itc_amount_id := NULL;
      end if;

      if (px_asset_fin_rec.ceiling_name = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.ceiling_name := NULL;
      end if;

      if (px_asset_fin_rec.capitalize_flag = NULL) then
         px_asset_fin_rec.capitalize_flag :=
            fa_cache_pkg.fazcat_record.capitalize_flag;
      end if;

      if (px_asset_fin_rec.global_attribute1 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute1 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute2 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute2 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute3 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute3 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute4 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute4 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute5 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute5 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute6 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute6 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute7 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute7 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute8 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute8 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute9 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute9 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute10 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute10 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute11 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute11 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute12 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute12 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute13 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute13 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute14 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute14 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute15 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute15 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute16 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute16 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute17 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute17 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute18 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute18 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute19 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute19 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute20 = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute20 := NULL;
      end if;

      if (px_asset_fin_rec.global_attribute_category = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.global_attribute_category := NULL;
      end if;

      if (px_asset_cat_rec.desc_flex.attribute_category_code is null) then

         l_return_status := fa_cache_pkg.fazsys(p_log_level_rec);

         if not (l_return_status) then
            raise init_err;
         else
            l_category_chart_id :=
               fa_cache_pkg.fazsys_record.category_flex_structure;
         end if;

         l_return_status := fa_flex_pvt.get_concat_segs (
            p_ccid                   => px_asset_cat_rec.category_id,
            p_application_short_name => 'OFA',
            p_flex_code              => 'CAT#',
            p_flex_num               => l_category_chart_id,
            p_num_segs               => l_num_segs,
            p_delimiter              => l_delimiter,
            p_segment_array          => l_segment_array,
            p_concat_string          => l_concat_string
         , p_log_level_rec => p_log_level_rec);

         if not (l_return_status) then
            raise init_err;
         end if;

         px_asset_cat_rec.desc_flex.attribute_category_code :=
            l_concat_string;

      end if;

-- Removing condition due to bug 5211950
/*      if (px_asset_cat_rec.desc_flex.context is null) then
          px_asset_cat_rec.desc_flex.context :=
             px_asset_cat_rec.desc_flex.attribute_category_code;
      end if;
*/
   else -- tax book

      -- Default cost/dpis in Tax to cost in corp if needed.
      if (px_asset_fin_rec.cost is null or
          px_asset_fin_rec.date_placed_in_service is null) then

         select nvl(px_asset_fin_rec.cost, cost),
                nvl(px_asset_fin_rec.date_placed_in_service, date_placed_in_service)
         into   px_asset_fin_rec.cost,
                px_asset_fin_rec.date_placed_in_service
         from   fa_books bks
         where  book_type_code =
                fa_cache_pkg.fazcbc_record.distribution_source_book
         and    asset_id = px_asset_hdr_rec.asset_id
         and    transaction_header_id_out is null;
      end if;

      -- load the shared structs
      if not FA_UTIL_PVT.get_asset_desc_rec
       (p_asset_hdr_rec         => px_asset_hdr_rec,
        px_asset_desc_rec       => px_asset_desc_rec
       , p_log_level_rec => p_log_level_rec) then
         raise init_err;
      end if;

      if not FA_UTIL_PVT.get_asset_cat_rec
       (p_asset_hdr_rec         => px_asset_hdr_rec,
        px_asset_cat_rec        => px_asset_cat_rec,
        p_date_effective        => null
       , p_log_level_rec => p_log_level_rec) then
         raise init_err;
      end if;

      if not FA_UTIL_PVT.get_asset_type_rec
       (p_asset_hdr_rec         => px_asset_hdr_rec,
        px_asset_type_rec       => px_asset_type_rec,
         p_date_effective        => null
        , p_log_level_rec => p_log_level_rec) then
         raise init_err;
      end if;


      -- remove and items in the distribution table as they are
      -- irrelevant to tax
      px_asset_dist_tbl.delete;

   end if; -- corp or tax


   -- Determine defaults for transaction_date_entered and
   -- date_placed_in_service - dpis is populated abiove for tax


   if ((px_trans_rec.transaction_date_entered is null) and
       (px_asset_fin_rec.date_placed_in_service is null)) then

      if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
         -- Default to last day of the period
         px_asset_fin_rec.date_placed_in_service :=
            l_period_rec.calendar_period_close_date;
      end if;

      px_trans_rec.transaction_date_entered :=
         px_asset_fin_rec.date_placed_in_service;

   elsif ((px_trans_rec.transaction_date_entered is null) and
          (px_asset_fin_rec.date_placed_in_service is not null)) then

      px_trans_rec.transaction_date_entered :=
         px_asset_fin_rec.date_placed_in_service;

   elsif ((px_trans_rec.transaction_date_entered is not null) and
          (px_asset_fin_rec.date_placed_in_service is null)) then

      px_asset_fin_rec.date_placed_in_service :=
         px_trans_rec.transaction_date_entered;

   elsif (px_trans_rec.transaction_date_entered <>
            px_asset_fin_rec.date_placed_in_service) then

      fa_srvr_msg.add_message(
         calling_fn => NULL,
         name       => 'FA_WHATIF_ASSET_CHK_TRX_DATE',
         token1     => 'ASSET_ID',
         value1     => to_char(px_asset_hdr_rec.asset_id),
                   p_log_level_rec => p_log_level_rec);

      raise init_err;
   end if;

   -- BUG# 3549470
   -- remove time stamp if provided

   px_trans_rec.transaction_date_entered :=
      to_date(to_char(px_trans_rec.transaction_date_entered,'DD/MM/YYYY'),'DD/MM/YYYY');

   px_asset_fin_rec.date_placed_in_service :=
      to_date(to_char(px_asset_fin_rec.date_placed_in_service,'DD/MM/YYYY'),'DD/MM/YYYY');

   -- Derive the transaction type - needs to be done after the
   -- asset type is derived for tax assets

   if (px_asset_type_rec.asset_type = 'CIP') then
      px_trans_rec.transaction_type_code := 'CIP ADDITION';
   elsif (px_asset_type_rec.asset_type = 'GROUP') then
      px_trans_rec.transaction_type_code := 'GROUP ADDITION';
   else
     px_trans_rec.transaction_type_code := 'ADDITION';
   end if;

   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
      -- Set the default values for the distribution trans rec if corp book
      px_dist_trans_rec.transaction_type_code := 'TRANSFER IN';

      px_dist_trans_rec.transaction_date_entered :=
         px_trans_rec.transaction_date_entered;

      px_dist_trans_rec.source_transaction_header_id := NULL;

      px_dist_trans_rec.mass_reference_id := px_trans_rec.mass_reference_id;

      px_dist_trans_rec.transaction_subtype := NULL;

      px_dist_trans_rec.transaction_key := NULL;

      px_dist_trans_rec.amortization_start_date := NULL;

      px_dist_trans_rec.who_info := px_trans_rec.who_info;
      --9413081
      px_dist_trans_rec.event_id := NULL;
   end if;

   -- Default values in inv_rec
   for i in 1 .. px_inv_tbl.COUNT loop
       if (px_inv_tbl(i).deleted_flag is NULL) then
          px_inv_tbl(i).deleted_flag := 'NO';
       end if;
   end loop;

   -- *****************************
   -- begin changes for group deprn
   -- *****************************
   if (px_asset_type_rec.asset_type = 'GROUP') then
      px_asset_fin_rec.cost := 0;
   end if;



   -- following section is for setting various defaults from the category
   -- if needed - this code used to reside in the calculation engine
   -- but has grown complex and easier to place it here.

   if not fa_cache_pkg.fazccbd (X_book   => px_asset_hdr_rec.book_type_code,
                                X_cat_id => px_asset_cat_rec.category_id,
                                X_jdpis  => to_number(to_char(px_asset_fin_rec.date_placed_in_service, 'J')),
                                p_log_level_rec => p_log_level_rec) then
      raise init_err;
   end if;

   -- for period of addition, if deprn info is not populated, then first
   -- default from the parent rules (if applicable) or from the category

   if (px_asset_fin_rec.deprn_method_code is null) then

      px_asset_fin_rec.deprn_method_code   := fa_cache_pkg.fazccbd_record.deprn_method;
      px_asset_fin_rec.life_in_months      := fa_cache_pkg.fazccbd_record.life_in_months;
      px_asset_fin_rec.basic_rate          := fa_cache_pkg.fazccbd_record.basic_rate;
      px_asset_fin_rec.adjusted_rate       := fa_cache_pkg.fazccbd_record.adjusted_rate;

      -- BUG# 2417520 - mass additions can send in prod capacity only, so allow this
      px_asset_fin_rec.production_capacity := nvl(px_asset_fin_rec.production_capacity,
                                                  fa_cache_pkg.fazccbd_record.production_capacity);

      -- BUG# 3066139 - need to default UOP as well
      px_asset_fin_rec.unit_of_measure := nvl(px_asset_fin_rec.unit_of_measure,
                                              fa_cache_pkg.fazccbd_record.unit_of_measure);

      if (nvl(fa_cache_pkg.fazccbd_record.subcomponent_life_rule, 'NULL') <> 'NULL' and
          nvl(px_asset_desc_rec.parent_asset_id, -99) <> -99) then

         if not FA_ASSET_CALC_PVT.calc_subcomp_life
                  (p_trans_rec                => px_trans_rec,
                   p_asset_hdr_rec            => px_asset_hdr_rec,
                   p_asset_cat_rec            => px_asset_cat_rec,
                   p_asset_desc_rec           => px_asset_desc_rec,
                   p_period_rec               => l_period_rec,
                   px_asset_fin_rec           => px_asset_fin_rec,
                   p_calling_fn               => 'fa_ddition_pvt.initialize'
                  , p_log_level_rec => p_log_level_rec) then
            raise init_err;
         end if;
      end if;
   end if;



   /*Bug# 7715087 -to default amortization start date for energy if not provided.
     Initialize the cache first*/
   if not fa_cache_pkg.fazccmt
                 (X_method => px_asset_fin_rec.deprn_method_code,
                  X_life   => px_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec) then
      raise init_err;
   end if;
   if( fa_cache_pkg.fazccmt_record.rate_source_rule = 'PRODUCTION'
        AND fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') then
      open  c_get_context_date(px_asset_hdr_rec.book_type_code);
      fetch c_get_context_date into l_trx_date ;
      close c_get_context_date;
      if( px_trans_rec.amortization_start_date is null ) then
          px_trans_rec.amortization_start_date := to_date(to_char(l_trx_date,'DD/MM/YYYY'),'DD/MM/YYYY');
          px_trans_rec.transaction_subtype := 'AMORTIZED';
      end if;
   end if;
   --Bug# 7715087 end

   if (px_asset_fin_rec.bonus_rule is null) then
       px_asset_fin_rec.bonus_rule  :=
         fa_cache_pkg.fazccbd_record.bonus_rule;
   elsif (px_asset_fin_rec.bonus_rule = FND_API.G_MISS_CHAR) then
      px_asset_fin_rec.bonus_rule  := NULL;
   end if;

   if (px_asset_fin_rec.ceiling_name is null) then
      px_asset_fin_rec.ceiling_name  :=
         fa_cache_pkg.fazccbd_record.ceiling_name;
   elsif (px_asset_fin_rec.ceiling_name = FND_API.G_MISS_CHAR) then
      px_asset_fin_rec.ceiling_name  := NULL;
   end if;

   -- this is where we would allow for multi-tier group
   -- associations if we ever offer it and in the if
   -- condition surrounding the load_miss call below
   if px_asset_type_rec.asset_type <> 'GROUP' then
      if (px_asset_fin_rec.group_asset_id is null) then
         --Call validate disabled_flag to confirm default group is not disabled
         if NOT FA_ASSET_VAL_PVT.validate_group_info
                  (p_group_asset_id => fa_cache_pkg.fazccbd_record.group_asset_id,
                   p_book_type_code => px_asset_hdr_rec.book_type_code,
                   p_calling_fn     => 'fa_addition_pvt.initialize', p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_message(calling_fn => 'fa_addition_pvt.initialize',
                                    name       => 'FA_DISABLED_DEFAULT_GROUP',  p_log_level_rec => p_log_level_rec);
            raise init_err;
         end if;
         --HH do this check for conditional group defaulting
         if (px_asset_type_rec.asset_type <> 'CIP') OR
            ((px_asset_type_rec.asset_type = 'CIP') AND
            (fa_cache_pkg.fazcbc_record.allow_cip_member_flag = 'Y')) then
           px_asset_fin_rec.group_asset_id  := fa_cache_pkg.fazccbd_record.group_asset_id;
         else
           px_asset_fin_rec.group_asset_id  := NULL;
          /* fa_srvr_msg.add_message(calling_fn => 'fa_addition_pvt.initialize',
                                   name       => 'FA_CIP_MEMBER_NOT_ALLOWED',  p_log_level_rec => p_log_level_rec);
           raise init_err; */
         end if; --end HH -- conditional group defaulting
      elsif (px_asset_fin_rec.group_asset_id = FND_API.G_MISS_NUM) then
         px_asset_fin_rec.group_asset_id := NULL;
      end if;  --group asset_id null
   else
      px_asset_fin_rec.group_asset_id := null;
   end if;  --<>Group

   -- percent salvage  - this is where we should derive
   -- the various copy options (NO/YES/PER) for tax books
   -- during mass copy and autocopy.  we will try to
   -- determine user intent first by looking at the
   -- type then by looking at the values

   if (px_asset_fin_rec.salvage_type is null) then
      if (px_asset_fin_rec.percent_salvage_value is null and
          px_asset_fin_rec.salvage_value is null) then
         if (fa_cache_pkg.fazcbc_record.book_class = 'TAX' and
             px_trans_rec.source_transaction_header_id is not null and
             fa_cache_pkg.fazcbc_record.copy_salvage_value_flag = 'YES') then
            -- get the primary corp book value from source transaction
            -- using this and then converting in case mrc is anabled on tax
            -- books but not on corp

            if (px_asset_fin_rec.cost <> 0) then
               select nvl(salvage_value, 0)
                 into px_asset_fin_rec.salvage_value
                 from fa_books
                where transaction_header_id_in = px_trans_rec.source_transaction_header_id;
            else
               px_asset_fin_rec.salvage_value := 0;
            end if;
         else  -- corp, manual tax, or no copy salvage
            px_asset_fin_rec.percent_salvage_value  :=
               fa_cache_pkg.fazccbd_record.percent_salvage_value;
         end if;
      end if;

      if (px_asset_fin_rec.percent_salvage_value is null) then
         if (px_asset_type_rec.asset_type = 'GROUP') then
            px_asset_fin_rec.salvage_type  := 'PCT';
            px_asset_fin_rec.salvage_value :=  0;
         else
            px_asset_fin_rec.salvage_type := 'AMT';
         end if;
      else
         px_asset_fin_rec.salvage_type := 'PCT';
      end if;

   elsif (px_asset_fin_rec.salvage_type = 'PCT' and
          px_asset_fin_rec.percent_salvage_value is null) then
      px_asset_fin_rec.percent_salvage_value := nvl(fa_cache_pkg.fazccbd_record.percent_salvage_value, 0);
   elsif (px_asset_fin_rec.salvage_type = 'AMT' and
          px_asset_fin_rec.salvage_value is null) then
      px_asset_fin_rec.salvage_value := 0;
   elsif (px_asset_fin_rec.salvage_type <> 'PCT' and
          px_asset_fin_rec.salvage_type <> 'AMT' and
          px_asset_fin_rec.salvage_type <> 'SUM') then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_addition_pvt.initialize',
         name       => 'FA_INVALID_PARAMETER',
         token1     => 'VALUE',
         value1     => px_asset_fin_rec.salvage_type,
         token2     => 'PARAM',
         value2     => 'SALVAGE_TYPE',  p_log_level_rec => p_log_level_rec);      raise init_err;
   end if;

   -- note that if after the following logic the deprn_limit type
   -- is not NONE and the amount and percentage remain null, we will error
   -- but this is caught inside the calculation engine.

   if (px_asset_fin_rec.deprn_limit_type is null) then
      if (px_asset_fin_rec.allowed_deprn_limit_amount is null and
          px_asset_fin_rec.allowed_deprn_limit is null) then
         if (fa_cache_pkg.fazccbd_record.use_deprn_limits_flag = 'YES') then
            px_asset_fin_rec.allowed_deprn_limit :=
               fa_cache_pkg.fazccbd_record.allowed_deprn_limit;
            px_asset_fin_rec.allowed_deprn_limit_amount :=
               fa_cache_pkg.fazccbd_record.special_deprn_limit_amount;
         end if;
      end if;

      if (px_asset_fin_rec.allowed_deprn_limit is not null) then
         px_asset_fin_rec.deprn_limit_type := 'PCT';
      elsif (px_asset_fin_rec.allowed_deprn_limit_amount is not null) then
         px_asset_fin_rec.deprn_limit_type := 'AMT';
      else
         px_asset_fin_rec.deprn_limit_type := 'NONE';
      end if;

   elsif (px_asset_fin_rec.deprn_limit_type = 'PCT' and
          px_asset_fin_rec.allowed_deprn_limit is null) then
      px_asset_fin_rec.allowed_deprn_limit:=
         fa_cache_pkg.fazccbd_record.allowed_deprn_limit;
      if (px_asset_fin_rec.allowed_deprn_limit is null) then
         fa_srvr_msg.add_message(
            calling_fn => 'fa_addition_pvt.initialize',
            name       => '***FA_MUST_SPECIFY_LIMIT***',
                   p_log_level_rec => p_log_level_rec);
         raise init_err;
      end if;
   elsif (px_asset_fin_rec.deprn_limit_type = 'AMT' and
          px_asset_fin_rec.allowed_deprn_limit_amount is null) then
      px_asset_fin_rec.allowed_deprn_limit_amount:=
         fa_cache_pkg.fazccbd_record.special_deprn_limit_amount;
      if (px_asset_fin_rec.allowed_deprn_limit_amount is null) then
         fa_srvr_msg.add_message(
            calling_fn => 'fa_addition_pvt.initialize',
            name       => '***FA_MUST_SPECIFY_LIMIT***',
                   p_log_level_rec => p_log_level_rec);
         raise init_err;
      end if;
   elsif (px_asset_fin_rec.deprn_limit_type = 'NONE') then
      px_asset_fin_rec.allowed_deprn_limit        := null;
      px_asset_fin_rec.allowed_deprn_limit_amount := null;
   elsif (px_asset_fin_rec.deprn_limit_type <> 'PCT' and
          px_asset_fin_rec.deprn_limit_type <> 'AMT' and
          px_asset_fin_rec.deprn_limit_type <> 'SUM' and
          px_asset_fin_rec.deprn_limit_type <> 'NONE') then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_addition_pvt.initialize',
         name       => 'FA_INVALID_PARAMETER',
         token1     => 'VALUE',
         value1     => px_asset_fin_rec.deprn_limit_type,
         token2     => 'PARAM',
         value2     => 'DEPRN_LIMIT_TYPE',  p_log_level_rec => p_log_level_rec);
      raise init_err;
   end if;

   -- end category defaulting

  -- Bug#7698326 - Start JP Dprn mthod modification


  if l_japan_tax_reform = 'Y' then
     l_fiscal_year := null;
     l_period_num  := null;
     l_number_per_fiscal_year := null;
     if px_asset_fin_rec.period_full_reserve is not null AND
        px_asset_fin_rec.period_counter_fully_reserved is null then
        open lcu_period_info(p_book_type_code  => px_asset_hdr_rec.book_type_code
                            ,p_period          => px_asset_fin_rec.period_full_reserve
                            );
        fetch lcu_period_info
        into l_fiscal_year,
             l_period_num,
             l_number_per_fiscal_year;
        if lcu_period_info%found then
           px_asset_fin_rec.period_counter_fully_reserved := ( NVL(l_fiscal_year,0)* NVL(l_number_per_fiscal_year,0) ) + NVL(l_period_num,0);
        else
           px_asset_fin_rec.period_counter_fully_reserved := null;
        end if;
        close lcu_period_info;
     end if;
     l_fiscal_year := null;
     l_period_num  := null;
     l_number_per_fiscal_year := null;
     l_period_counter_extd := null;

     if px_asset_fin_rec.period_extd_deprn is not null AND
        px_asset_fin_rec.extended_depreciation_period is null then
        open lcu_period_info(p_book_type_code  => px_asset_hdr_rec.book_type_code
                            ,p_period          => px_asset_fin_rec.period_extd_deprn
                             );
        fetch lcu_period_info
        into l_fiscal_year,
             l_period_num,
             l_number_per_fiscal_year;
        if lcu_period_info%found then
           px_asset_fin_rec.extended_depreciation_period := ( NVL(l_fiscal_year,0)*NVL(l_number_per_fiscal_year,0) ) + NVL(l_period_num,0);
        else
           px_asset_fin_rec.extended_depreciation_period := null;
        end if;
        close lcu_period_info;
     end if;
     if px_asset_fin_rec.allowed_deprn_limit_amount is null AND
        px_asset_fin_rec.allowed_deprn_limit IS NOT NULL then
        px_asset_fin_rec.allowed_deprn_limit_amount := nvl(px_asset_fin_rec.cost,0) - nvl(px_asset_fin_rec.cost,0)* NVL(px_asset_fin_rec.allowed_deprn_limit,0);
	/* Bug 8590070*/
	FA_ROUND_PKG.fa_ceil
                        (X_amount => px_asset_fin_rec.allowed_deprn_limit_amount,
                         X_book   => px_asset_hdr_rec.book_type_code
                         );
     end if;
     /*Bug 8590070
       px_asset_fin_rec.period_counter_fully_reserved := l_period_counter_rsv;
       px_asset_fin_rec.period_counter_life_complete  := l_period_counter_rsv;
       px_asset_fin_rec.extended_depreciation_period  := l_period_counter_extd;*/
     px_asset_fin_rec.period_counter_life_complete  := px_asset_fin_rec.period_counter_fully_reserved;
  end if;

-- End of Japan profile option value

   if px_asset_fin_rec.deprn_method_code like 'JP%250DB%' then
      px_asset_fin_rec.prior_deprn_limit_type        := null;
      px_asset_fin_rec.prior_deprn_limit_amount      := null;
      px_asset_fin_rec.prior_deprn_limit             := null;
      px_asset_fin_rec.extended_depreciation_period  := null;
      px_asset_fin_rec.prior_deprn_method            := null;
      px_asset_fin_rec.prior_life_in_months          := null;
      px_asset_fin_rec.prior_basic_rate              := null;
      px_asset_fin_rec.prior_adjusted_rate           := null;
      px_asset_fin_rec.period_full_reserve           := null;
      px_asset_fin_rec.period_extd_deprn             := null;
   elsif px_asset_fin_rec.deprn_method_code = 'JP-STL-EXTND' then
      ln_limit_amt := null;
      px_asset_fin_rec.nbv_at_switch := null;
      -- bug#9118540
      if (px_asset_fin_rec.extended_deprn_flag is null) then
         px_asset_fin_rec.extended_deprn_flag := 'Y';
      end if;
      if px_asset_fin_rec.prior_deprn_limit_type  = 'AMT' then
         px_asset_fin_rec.prior_deprn_limit        := null;
      elsif  px_asset_fin_rec.prior_deprn_limit_type  = 'PCT' then
         ln_limit_amt := (px_asset_fin_rec.prior_deprn_limit)*nvl(px_asset_fin_rec.cost,0);
         ln_limit_amt := nvl(px_asset_fin_rec.cost,0) - ln_limit_amt;
         -- Bug 8520695
         if ln_limit_amt <> 0 then
            FA_ROUND_PKG.fa_ceil
                        (X_amount => ln_limit_amt,
                         X_book   => px_asset_hdr_rec.book_type_code
                         );
         end if;
         -- End Bug 8520695
         px_asset_fin_rec.prior_deprn_limit_amount := ln_limit_amt;
      else
         px_asset_fin_rec.prior_deprn_limit_amount := null;
         px_asset_fin_rec.prior_deprn_limit        := null;
      end if;
   else
      /*Bug 8590070
      if px_asset_fin_rec.deprn_method_code <> 'JP-STL-EXTND' then
         IF nvl(px_asset_fin_rec.cost,0) - NVL(px_asset_deprn_rec.deprn_reserve,0) - NVL(px_asset_fin_rec.allowed_deprn_limit_amount,0)  = 0 THEN
            px_asset_fin_rec.period_counter_fully_reserved := px_asset_fin_rec.period_counter_fully_reserved;
            px_asset_fin_rec.period_counter_life_complete  := px_asset_fin_rec.period_counter_fully_reserved;
         ELSE
            px_asset_fin_rec.period_counter_fully_reserved := NULL;
            px_asset_fin_rec.period_counter_life_complete  := NULL;
         END IF;
      end if;*/
      px_asset_fin_rec.nbv_at_switch                 := null;
      px_asset_fin_rec.prior_deprn_limit_type        := null;
      px_asset_fin_rec.prior_deprn_limit_amount      := null;
      px_asset_fin_rec.prior_deprn_limit             := null;
      px_asset_fin_rec.extended_depreciation_period  := null;
      px_asset_fin_rec.prior_deprn_method            := null;
      px_asset_fin_rec.prior_life_in_months          := null;
      px_asset_fin_rec.prior_basic_rate              := null;
      px_asset_fin_rec.prior_adjusted_rate           := null;
      px_asset_fin_rec.period_full_reserve           := null;
      px_asset_fin_rec.period_extd_deprn             := null;
      px_asset_fin_rec.extended_deprn_flag           := null;
   end if;

  -- Bug#7698326 End



   -- begin group defaulting
   if (px_asset_type_rec.asset_type = 'GROUP') then

      if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('add',
                     'entering group flag defaulting',
                     'X', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('add',
                     'px_asset_fin_rec.over_depreciate_option',
                      px_asset_fin_rec.over_depreciate_option, p_log_level_rec => p_log_level_rec);
      end if;

      --Bug# 8630874 Group option defaulting from category group default
      open c_get_group_defaults(px_asset_hdr_rec.book_type_code,px_asset_cat_rec.category_id,px_asset_fin_rec.date_placed_in_service);
      fetch c_get_group_defaults into  l_recognize_gain_loss,
                                 l_terminal_gain_loss,
                                 l_tracking_method,
                                 l_excess_allocation_option,
                                 l_allocate_to_fully_rsv_flag,
                                 l_recapture_reserve_flag,
                                 l_limit_proceeds_flag,
                                 l_depreciation_option,
                                 l_member_rollup_flag;

      if (px_asset_fin_rec.recognize_gain_loss is null) then
         px_asset_fin_rec.recognize_gain_loss := l_recognize_gain_loss;
      end if;

      if (px_asset_fin_rec.tracking_method is null) then
         px_asset_fin_rec.tracking_method := l_tracking_method;
      end if;

      if (px_asset_fin_rec.allocate_to_fully_rsv_flag is null) then
         px_asset_fin_rec.allocate_to_fully_rsv_flag := l_allocate_to_fully_rsv_flag;
      end if;
      if (px_asset_fin_rec.terminal_gain_loss is null) then
         px_asset_fin_rec.terminal_gain_loss := l_terminal_gain_loss;
      end if;

      if (px_asset_fin_rec.excess_allocation_option is null) then
         px_asset_fin_rec.excess_allocation_option := l_excess_allocation_option;
      end if;

      if (px_asset_fin_rec.recapture_reserve_flag is null) then
         px_asset_fin_rec.recapture_reserve_flag := l_recapture_reserve_flag;
      end if;

      if (px_asset_fin_rec.limit_proceeds_flag is null) then
         px_asset_fin_rec.limit_proceeds_flag := l_limit_proceeds_flag;
      end if;

      if (px_asset_fin_rec.depreciation_option is null) then
         px_asset_fin_rec.depreciation_option := l_depreciation_option;
      end if;

      if (not (l_recognize_gain_loss = 'NO') or (l_terminal_gain_loss <> 'YES')) then
         px_asset_fin_rec.member_rollup_flag := l_member_rollup_flag;
      end if;
      --Bug8630874 end

      if (px_asset_fin_rec.over_depreciate_option is null) then
         px_asset_fin_rec.over_depreciate_option :=
            fa_std_types.FA_OVER_DEPR_NO;
      end if;

      if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('add',
                     'px_asset_fin_rec.over_depreciate_option',
                      px_asset_fin_rec.over_depreciate_option, p_log_level_rec => p_log_level_rec);
      end if;

      if not fa_cache_pkg.fazccmt
                 (X_method => px_asset_fin_rec.deprn_method_code,
                  X_life   => px_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec) then
         raise init_err;
      end if;

      if (nvl(fa_cache_pkg.fazcdrd_record.allow_reduction_rate_flag, 'N') = 'N') then
         px_asset_fin_rec.reduction_rate := to_number(null);
         px_asset_fin_rec.reduce_addition_flag := null;
         px_asset_fin_rec.reduce_adjustment_flag := null;
         px_asset_fin_rec.reduce_adjustment_flag := null;
      else
         if (px_asset_fin_rec.reduction_rate is null) then
            px_asset_fin_rec.reduction_rate := 0;
         end if;

         if (px_asset_fin_rec.reduce_addition_flag is null) then
            px_asset_fin_rec.reduce_addition_flag := 'N';
         end if;

         if (px_asset_fin_rec.reduce_adjustment_flag is null) then
            px_asset_fin_rec.reduce_adjustment_flag := 'N';
         end if;

         if (px_asset_fin_rec.reduce_retirement_flag is null) then
            px_asset_fin_rec.reduce_retirement_flag := 'N';
         end if;

      end if;

      --
      -- Bug5032617:  Following if is just to ensure to prevent
      -- wrong combination of group setup values. (for API)
      -- If member_rollup_flag is given and Y, then set
      -- retirement option accordingly if they are null.
      --
      if (px_asset_fin_rec.member_rollup_flag = 'Y') then
         if (px_asset_fin_rec.recognize_gain_loss is null) then
            px_asset_fin_rec.recognize_gain_loss := 'YES';
         end if;
         if (px_asset_fin_rec.terminal_gain_loss is null) then
            px_asset_fin_rec.terminal_gain_loss := 'YES';
         end if;
      end if;

      if (px_asset_fin_rec.recognize_gain_loss is null) then
         px_asset_fin_rec.recognize_gain_loss := 'NO';
         px_asset_fin_rec.limit_proceeds_flag := 'N';
         px_asset_fin_rec.terminal_gain_loss  := 'YES';
      else
         if (px_asset_fin_rec.limit_proceeds_flag is null) then
            px_asset_fin_rec.limit_proceeds_flag := 'N';
         end if;
         if (px_asset_fin_rec.terminal_gain_loss is null) then
            px_asset_fin_rec.terminal_gain_loss := 'YES';
         end if;
      end if;

      --
      -- Bug5032617:  Following if is just to ensure to prevent
      -- wrong combination of group setup values. (for API)
      --
      if ((px_asset_fin_rec.recognize_gain_loss = 'NO') or
          (px_asset_fin_rec.terminal_gain_loss <> 'YES')) and
         (px_asset_fin_rec.member_rollup_flag = 'Y') then
         fa_srvr_msg.add_message(
               calling_fn => 'fa_addition_pvt.initialize',
               name       => 'FA_INVALID_PARAMETER',
               token1     => 'VALUE',
               value1     => px_asset_fin_rec.recognize_gain_loss,
               token2     => 'PARAM',
               value2     => 'RECOGNIZE_GAIN_LOSS',  p_log_level_rec => p_log_level_rec);
         fa_srvr_msg.add_message(
               calling_fn => 'fa_addition_pvt.initialize',
               name       => 'FA_INVALID_PARAMETER',
               token1     => 'VALUE',
               value1     => px_asset_fin_rec.terminal_gain_loss,
               token2     => 'PARAM',
               value2     => 'TERMINAL_GAIN_LOSS',  p_log_level_rec => p_log_level_rec);
         fa_srvr_msg.add_message(
               calling_fn => 'fa_addition_pvt.initialize',
               name       => 'FA_INVALID_PARAMETER',
               token1     => 'VALUE',
               value1     => px_asset_fin_rec.member_rollup_flag,
               token2     => 'PARAM',
               value2     => 'MEMBER_ROLLUP_FLAG',  p_log_level_rec => p_log_level_rec);

         raise init_err;
      end if;

      if (px_asset_fin_rec.recapture_reserve_flag is null) then
         px_asset_fin_rec.recapture_reserve_flag := 'N';
      end if;

      if (px_asset_fin_rec.tracking_method is null or
          px_asset_fin_rec.tracking_method = FND_API.G_MISS_CHAR) then
         px_asset_fin_rec.tracking_method            := null;
         px_asset_fin_rec.allocate_to_fully_rsv_flag := null;
         px_asset_fin_rec.allocate_to_fully_ret_flag := null;
         px_asset_fin_rec.excess_allocation_option   := null;
         px_asset_fin_rec.depreciation_option        := null;
         px_asset_fin_rec.member_rollup_flag         := null;
      else
         if (px_asset_fin_rec.tracking_method = 'ALLOCATE') then
            if (px_asset_fin_rec.allocate_to_fully_rsv_flag is null) then
               px_asset_fin_rec.allocate_to_fully_rsv_flag := 'N';
            end if;
            if (px_asset_fin_rec.allocate_to_fully_ret_flag is null) then
               px_asset_fin_rec.allocate_to_fully_ret_flag := 'N';
            end if;
            if (px_asset_fin_rec.excess_allocation_option is null) then
               px_asset_fin_rec.excess_allocation_option := 'REDUCE';
            end if;
            px_asset_fin_rec.depreciation_option      := null;
            px_asset_fin_rec.member_rollup_flag       := null;
         elsif (px_asset_fin_rec.tracking_method = 'CALCULATE') then
            px_asset_fin_rec.allocate_to_fully_rsv_flag   := null;
            px_asset_fin_rec.allocate_to_fully_ret_flag   := null;
            px_asset_fin_rec.excess_allocation_option := null;

            if (px_asset_fin_rec.depreciation_option is null) then
               px_asset_fin_rec.depreciation_option := 'GROUP';
            end if;
            if (px_asset_fin_rec.member_rollup_flag is null) then
               px_asset_fin_rec.member_rollup_flag := 'N';
            end if;
         end if;
      end if;

   end if;
   -- end group defaulting

   return TRUE;

exception
   when init_err then
      fa_srvr_msg.add_message(
             calling_fn => 'fa_addition_pvt.initialize',  p_log_level_rec => p_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(
             calling_fn => 'fa_addition_pvt.initialize',  p_log_level_rec => p_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;
      return FALSE;

end initialize;

function insert_asset (
   p_trans_rec              IN OUT NOCOPY fa_api_types.trans_rec_type,
   p_dist_trans_rec         IN     fa_api_types.trans_rec_type,
   p_asset_hdr_rec          IN     fa_api_types.asset_hdr_rec_type,
   p_asset_desc_rec         IN     fa_api_types.asset_desc_rec_type,
   p_asset_type_rec         IN     fa_api_types.asset_type_rec_type,
   p_asset_cat_rec          IN     fa_api_types.asset_cat_rec_type,
   p_asset_hierarchy_rec    IN     fa_api_types.asset_hierarchy_rec_type,
   p_asset_fin_rec          IN OUT NOCOPY fa_api_types.asset_fin_rec_type,
   p_asset_deprn_rec        IN     fa_api_types.asset_deprn_rec_type,
   px_asset_dist_tbl        IN OUT NOCOPY fa_api_types.asset_dist_tbl_type,
   p_inv_trans_rec          IN     fa_api_types.inv_trans_rec_type,
   p_primary_cost           IN     NUMBER,
   p_exchange_rate          IN     NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2,
   p_mrc_sob_type_code      IN     VARCHAR2,
   p_period_rec             IN     fa_api_types.period_rec_type,
   p_calling_fn             IN     VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean as

   l_rowid                        ROWID;
   l_asset_id                     NUMBER(15);
   l_asset_number                 VARCHAR2(15);

   l_transaction_header_id        NUMBER(15);
   l_trans_in_header_id           NUMBER(15);
   l_return_status                BOOLEAN;

   l_date_effective               DATE;

   l_distribution_id              NUMBER(15);
   l_distribution_count           NUMBER := 0;

   l_deprn_run_date               DATE;
   l_period_counter               NUMBER(15);
   l_bonus_rate                   NUMBER;

   -- For merging primary/mrc and amort nbv logic
   l_status                       BOOLEAN;
   l_deprn_exp                    NUMBER;
   l_bonus_deprn_exp              NUMBER;
   l_impairment_exp               NUMBER;
   l_ann_adj_deprn_exp            NUMBER;
   l_ann_adj_bonus_deprn_exp      NUMBER;

   l_clearing                     NUMBER := 0;
   l_ds_rowid                     ROWID;

   l_new_adjusted_cost            NUMBER := p_asset_fin_rec.adjusted_cost;
   l_new_adjusted_capacity        NUMBER := p_asset_fin_rec.adjusted_capacity;
   l_rate_adjustment_factor       NUMBER := 1;
   l_reval_amortization_basis     NUMBER
        := p_asset_fin_rec.reval_amortization_basis;
   l_formula_factor               NUMBER := p_asset_fin_rec.formula_factor;

   deprn_override_flag_default    varchar2(1);

   l_period_rec                   fa_api_types.period_rec_type;
   l_capitalized_flag             VARCHAR2(1);
   l_fully_reserved_flag          VARCHAR2(1);
   l_fully_retired_flag           VARCHAR2(1);
   l_life_complete_flag           VARCHAR2(1);

   mrc_check_error                EXCEPTION;
   general_error                  EXCEPTION;

   l_asset_fin_rec_null           FA_API_TYPES.asset_fin_rec_type;

   --bug3548724
   l_asset_deprn_rec_adj          fa_api_types.asset_deprn_rec_type;


   -- Bug:5930979:Japan Tax Reform Project
   l_method_type                  NUMBER := 0;
   l_success                      INTEGER;
   l_rate_in_use                  NUMBER;
   l_revised_count                NUMBER := 0;

l_original_Rate NUMBER;
l_Revised_Rate NUMBER;
l_Guaranteed_Rate NUMBER;
l_is_revised_rate NUMBER;

   -- sla
   l_adj fa_adjust_type_pkg.fa_adj_row_struct;


   TYPE num_tbl IS TABLE OF number;

   l_payables_cost_tbl     num_tbl;
   l_payables_ccid_tbl     num_tbl;
   l_source_line_id_tbl    num_tbl;
   l_asset_invoice_id_tbl  num_tbl;

   cursor c_invoices
            (p_asset_id               number,
             p_invoice_transaction_id number) is
   select source_line_id,
          asset_invoice_id,
          payables_cost,
          nvl(payables_code_combination_id, 0)
     from fa_asset_invoices
    where asset_id = p_asset_id
      and invoice_transaction_id_in = p_invoice_transaction_id
      and nvl(payables_cost, 0) <> 0;


   cursor c_mc_invoices
            (p_asset_id               number,
             p_invoice_transaction_id number) is
  select source_line_id,
          asset_invoice_id,
          payables_cost,
          nvl(payables_code_combination_id, 0)
     from fa_mc_asset_invoices
    where asset_id = p_asset_id
      and invoice_transaction_id_in = p_invoice_transaction_id
      and nvl(payables_cost, 0) <> 0
      and set_of_books_id = p_asset_hdr_rec.set_of_books_id;


begin

   l_period_counter := fa_cache_pkg.fazcbc_record.last_period_counter;

   l_rowid := NULL;
   l_transaction_header_id := p_trans_rec.transaction_header_id;
   l_trans_in_header_id := p_dist_trans_rec.transaction_header_id;
   l_date_effective := p_trans_rec.who_info.last_update_date;
   l_deprn_run_date := p_trans_rec.who_info.last_update_date;

   deprn_override_flag_default:= fa_std_types.FA_NO_OVERRIDE;

   if (p_mrc_sob_type_code <> 'R') then

     if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

       -- Insert into fa_additions.
       l_rowid := NULL;
       l_asset_id := p_asset_hdr_rec.asset_id;
       l_asset_number := upper(p_asset_desc_rec.asset_number);

       -- for bug no. 3643781. made the serial number case sensitive.

       fa_additions_pkg.insert_row (
         X_Rowid                => l_rowid,
         X_Asset_Id             => l_asset_id,
         X_Asset_Number         => l_asset_number,
         X_Asset_Key_Ccid       => p_asset_desc_rec.asset_key_ccid,
         X_Current_Units        => p_asset_desc_rec.current_units,
         X_Asset_Type           => upper(p_asset_type_rec.asset_type),
         X_Tag_Number           => upper(p_asset_desc_rec.tag_number),
         X_Description          => p_asset_desc_rec.description,
         X_Asset_Category_Id    => p_asset_cat_rec.category_id,
         X_Parent_Asset_Id      => p_asset_desc_rec.parent_asset_id,
         X_Manufacturer_Name    => p_asset_desc_rec.manufacturer_name,
         X_Serial_Number        => p_asset_desc_rec.serial_number,
         X_Model_Number         => p_asset_desc_rec.model_number,
         X_Property_Type_Code   => upper(p_asset_desc_rec.property_type_code),
         X_Property_1245_1250_Code
                                =>
              p_asset_desc_rec.property_1245_1250_code,
         X_In_Use_Flag          => upper(p_asset_desc_rec.in_use_flag),
         X_Owned_Leased         => upper(p_asset_desc_rec.owned_leased),
         X_New_Used             => upper(p_asset_desc_rec.new_used),
         X_Unit_Adjustment_Flag => upper(p_asset_desc_rec.unit_adjustment_flag),
         X_Add_Cost_Je_Flag     => upper(p_asset_desc_rec.add_cost_je_flag),
         X_attribute1           => p_asset_cat_rec.desc_flex.attribute1,
         X_attribute2           => p_asset_cat_rec.desc_flex.attribute2,
         X_attribute3           => p_asset_cat_rec.desc_flex.attribute3,
         X_attribute4           => p_asset_cat_rec.desc_flex.attribute4,
         X_attribute5           => p_asset_cat_rec.desc_flex.attribute5,
         X_attribute6           => p_asset_cat_rec.desc_flex.attribute6,
         X_attribute7           => p_asset_cat_rec.desc_flex.attribute7,
         X_attribute8           => p_asset_cat_rec.desc_flex.attribute8,
         X_attribute9           => p_asset_cat_rec.desc_flex.attribute9,
         X_attribute10          => p_asset_cat_rec.desc_flex.attribute10,
         X_attribute11          => p_asset_cat_rec.desc_flex.attribute11,
         X_attribute12          => p_asset_cat_rec.desc_flex.attribute12,
         X_attribute13          => p_asset_cat_rec.desc_flex.attribute13,
         X_attribute14          => p_asset_cat_rec.desc_flex.attribute14,
         X_attribute15          => p_asset_cat_rec.desc_flex.attribute15,
         X_attribute16          => p_asset_cat_rec.desc_flex.attribute16,
         X_attribute17          => p_asset_cat_rec.desc_flex.attribute17,
         X_attribute18          => p_asset_cat_rec.desc_flex.attribute18,
         X_attribute19          => p_asset_cat_rec.desc_flex.attribute19,
         X_attribute20          => p_asset_cat_rec.desc_flex.attribute20,
         X_attribute21          => p_asset_cat_rec.desc_flex.attribute21,
         X_attribute22          => p_asset_cat_rec.desc_flex.attribute22,
         X_attribute23          => p_asset_cat_rec.desc_flex.attribute23,
         X_attribute24          => p_asset_cat_rec.desc_flex.attribute24,
         X_attribute25          => p_asset_cat_rec.desc_flex.attribute25,
         X_attribute26          => p_asset_cat_rec.desc_flex.attribute26,
         X_attribute27          => p_asset_cat_rec.desc_flex.attribute27,
         X_attribute28          => p_asset_cat_rec.desc_flex.attribute28,
         X_attribute29          => p_asset_cat_rec.desc_flex.attribute29,
         X_attribute30          => p_asset_cat_rec.desc_flex.attribute30,
         X_attribute_Category_Code
                                =>
              p_asset_cat_rec.desc_flex.attribute_category_code,
         X_gf_attribute1        =>
              p_asset_desc_rec.global_desc_flex.attribute1,
         X_gf_attribute2        =>
              p_asset_desc_rec.global_desc_flex.attribute2,
         X_gf_attribute3        =>
              p_asset_desc_rec.global_desc_flex.attribute3,
         X_gf_attribute4        =>
              p_asset_desc_rec.global_desc_flex.attribute4,
         X_gf_attribute5        =>
              p_asset_desc_rec.global_desc_flex.attribute5,
         X_gf_attribute6        =>
              p_asset_desc_rec.global_desc_flex.attribute6,
         X_gf_attribute7        =>
              p_asset_desc_rec.global_desc_flex.attribute7,
         X_gf_attribute8        =>
              p_asset_desc_rec.global_desc_flex.attribute8,
         X_gf_attribute9        =>
              p_asset_desc_rec.global_desc_flex.attribute9,
         X_gf_attribute10       =>
              p_asset_desc_rec.global_desc_flex.attribute10,
         X_gf_attribute11       =>
              p_asset_desc_rec.global_desc_flex.attribute11,
         X_gf_attribute12       =>
              p_asset_desc_rec.global_desc_flex.attribute12,
         X_gf_attribute13       =>
              p_asset_desc_rec.global_desc_flex.attribute13,
         X_gf_attribute14       =>
              p_asset_desc_rec.global_desc_flex.attribute14,
         X_gf_attribute15       =>
              p_asset_desc_rec.global_desc_flex.attribute15,
         X_gf_attribute16       =>
              p_asset_desc_rec.global_desc_flex.attribute16,
         X_gf_attribute17       =>
              p_asset_desc_rec.global_desc_flex.attribute17,
         X_gf_attribute18       =>
              p_asset_desc_rec.global_desc_flex.attribute18,
         X_gf_attribute19       =>
              p_asset_desc_rec.global_desc_flex.attribute19,
         X_gf_attribute20       =>
              p_asset_desc_rec.global_desc_flex.attribute20,
         X_gf_attribute_Category_Code
                                =>
              p_asset_desc_rec.global_desc_flex.attribute_category_code,
         X_Context              => p_asset_cat_rec.desc_flex.context,
         X_Lease_Id             => p_asset_desc_rec.lease_id,
         X_Inventorial          => upper(p_asset_desc_rec.inventorial),
         X_Commitment           => p_asset_desc_rec.commitment,
         X_Investment_Law       => p_asset_desc_rec.investment_law,
         X_Status               => upper(p_asset_desc_rec.status),
         X_Last_Update_Date     => p_trans_rec.who_info.last_update_date,
         X_Last_Updated_By      => p_trans_rec.who_info.last_updated_by,
         X_Created_By           => p_trans_rec.who_info.created_by,
         X_Creation_Date        => p_trans_rec.who_info.creation_date,
         X_Last_Update_Login    => p_trans_rec.who_info.last_update_login,
         X_Calling_Fn           => 'fa_addition_pvt.insert_asset'
       , p_log_level_rec => p_log_level_rec);

       -- Should only update the lease desc flex if modified.
       -- Probably need to change later to use table handler.
       if (p_asset_desc_rec.lease_id is not null) and
          (p_trans_rec.mass_reference_id is null) then -- Bug 7445419

          UPDATE fa_leases
          SET
              last_update_date  = p_trans_rec.who_info.last_update_date,
              last_updated_by   = p_trans_rec.who_info.last_updated_by,
              last_update_login = p_trans_rec.who_info.last_update_login,
              attribute1        = p_asset_desc_rec.lease_desc_flex.attribute1,
              attribute2        = p_asset_desc_rec.lease_desc_flex.attribute2,
              attribute3        = p_asset_desc_rec.lease_desc_flex.attribute3,
              attribute4        = p_asset_desc_rec.lease_desc_flex.attribute4,
              attribute5        = p_asset_desc_rec.lease_desc_flex.attribute5,
              attribute6        = p_asset_desc_rec.lease_desc_flex.attribute6,
              attribute7        = p_asset_desc_rec.lease_desc_flex.attribute7,
              attribute8        = p_asset_desc_rec.lease_desc_flex.attribute8,
              attribute9        = p_asset_desc_rec.lease_desc_flex.attribute9,
              attribute10       = p_asset_desc_rec.lease_desc_flex.attribute10,
              attribute11       = p_asset_desc_rec.lease_desc_flex.attribute11,
              attribute12       = p_asset_desc_rec.lease_desc_flex.attribute12,
              attribute13       = p_asset_desc_rec.lease_desc_flex.attribute13,
              attribute14       = p_asset_desc_rec.lease_desc_flex.attribute14,
              attribute15       = p_asset_desc_rec.lease_desc_flex.attribute15,
              attribute_category_code
                                =
                   p_asset_desc_rec.lease_desc_flex.attribute_category_code
          WHERE lease_id = p_asset_desc_rec.lease_id;
       end if;

       -- Add warranty if applicable.
       -- Should probably use table handler.
       if (p_asset_desc_rec.warranty_id is not null) then
          INSERT INTO fa_add_warranties (
             warranty_id,
             asset_id,
             date_effective,
             last_update_date,
             last_updated_by,
             created_by,
             creation_date,
             last_update_login
          ) VALUES (
             p_asset_desc_rec.warranty_id,
             p_asset_hdr_rec.asset_id,
             l_date_effective,
             p_trans_rec.who_info.last_update_date,
             p_trans_rec.who_info.last_updated_by,
             p_trans_rec.who_info.created_by,
             p_trans_rec.who_info.creation_date,
             p_trans_rec.who_info.last_update_login
          );
       end if;
      end if;  -- end corporate

      -- SLA UPTAKE
      -- assign an event for the transaction
      -- at this point key info asset/book/trx info is known from initialize
      -- call and the above code (i.e. trx_type, etc)
      if not FA_XLA_EVENTS_PVT.create_transaction_event
              (p_asset_hdr_rec          => p_asset_hdr_rec,
               p_asset_type_rec         => p_asset_type_rec,
               px_trans_rec             => p_trans_rec,
               p_event_status           => NULL,
               p_calling_fn             => 'fa_addition_pvt.insert_asset',
               p_log_level_rec  => p_log_level_rec) then
         raise general_error;
      end if;

      -- Insert into fa_transaction_headers.
      l_rowid := NULL;

      fa_transaction_headers_pkg.insert_row (
        X_Rowid                    => l_rowid,
        X_Transaction_header_Id    => l_transaction_header_id,
        X_Book_Type_Code           => p_asset_hdr_rec.book_type_code,
        X_Asset_Id                 => p_asset_hdr_rec.asset_id,
        X_Transaction_Type_Code    => p_trans_rec.transaction_type_code,
        X_Transaction_Date_Entered => p_trans_rec.transaction_date_entered,
        X_Date_Effective           => l_date_effective,
        X_Last_Update_Date         => p_trans_rec.who_info.last_update_date,
        X_Last_Updated_By          => p_trans_rec.who_info.last_updated_by,
        X_Transaction_Name         => p_trans_rec.transaction_name,
        X_Invoice_Transaction_Id   => p_inv_trans_rec.invoice_transaction_id,
        X_Source_Transaction_Header_Id
                                   => p_trans_rec.source_transaction_header_id,
        X_Mass_Reference_Id        => p_trans_rec.mass_reference_id,
        X_Last_Update_Login        => p_trans_rec.who_info.last_update_login,
        X_Transaction_Subtype      => p_trans_rec.transaction_subtype,
        X_attribute1               => p_trans_rec.desc_flex.attribute1,
        X_attribute2               => p_trans_rec.desc_flex.attribute2,
        X_attribute3               => p_trans_rec.desc_flex.attribute3,
        X_attribute4               => p_trans_rec.desc_flex.attribute4,
        X_attribute5               => p_trans_rec.desc_flex.attribute5,
        X_attribute6               => p_trans_rec.desc_flex.attribute6,
        X_attribute7               => p_trans_rec.desc_flex.attribute7,
        X_attribute8               => p_trans_rec.desc_flex.attribute8,
        X_attribute9               => p_trans_rec.desc_flex.attribute9,
        X_attribute10              => p_trans_rec.desc_flex.attribute10,
        X_attribute11              => p_trans_rec.desc_flex.attribute11,
        X_attribute12              => p_trans_rec.desc_flex.attribute12,
        X_attribute13              => p_trans_rec.desc_flex.attribute13,
        X_attribute14              => p_trans_rec.desc_flex.attribute14,
        X_attribute15              => p_trans_rec.desc_flex.attribute15,
        X_attribute_Category_Code  =>
             p_trans_rec.desc_flex.attribute_category_code,
        X_Transaction_Key          => p_trans_rec.transaction_key,
        X_Amortization_Start_Date  => p_trans_rec.amortization_start_date,
        X_Calling_Interface        => p_trans_rec.calling_interface,
        X_Mass_Transaction_ID      => p_trans_rec.mass_transaction_id,
        X_Trx_Reference_Id         => p_trans_rec.trx_reference_id,
        X_Event_Id                 => p_trans_rec.event_id,
        X_Return_Status            => l_return_status,
        X_Calling_Fn               => 'fa_addition_pvt.insert_asset'
      ,  p_log_level_rec => p_log_level_rec);

      if not (l_return_status) then
         raise general_error;
      end if;

      l_rowid := NULL;

      if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

          fa_transaction_headers_pkg.insert_row (
           X_Rowid                 => l_rowid,
           X_Transaction_Header_Id => l_trans_in_header_id,
           X_Book_Type_Code        => p_asset_hdr_rec.book_type_code,
           X_Asset_Id              => p_asset_hdr_rec.asset_id,
           X_Transaction_Type_Code => p_dist_trans_rec.transaction_type_code,
           X_Transaction_Date_Entered
                                   => p_dist_trans_rec.transaction_date_entered,
           X_Date_Effective        => l_date_effective,
           X_Last_Update_Date      =>
              p_dist_trans_rec.who_info.last_update_date,
           X_Last_Updated_By       => p_dist_trans_rec.who_info.last_updated_by,
           X_Transaction_Name      => p_dist_trans_rec.transaction_name,
           X_Invoice_Transaction_Id
                                   => p_inv_trans_rec.invoice_transaction_id,
           X_Source_Transaction_Header_Id
                                   =>
              p_dist_trans_rec.source_transaction_header_id,
           X_Mass_Reference_Id     => p_dist_trans_rec.mass_reference_id,
           X_Last_Update_Login     =>
              p_dist_trans_rec.who_info.last_update_login,
           X_Transaction_Subtype   => p_dist_trans_rec.transaction_subtype,
           X_attribute1            => p_dist_trans_rec.desc_flex.attribute1,
           X_attribute2            => p_dist_trans_rec.desc_flex.attribute2,
           X_attribute3            => p_dist_trans_rec.desc_flex.attribute3,
           X_attribute4            => p_dist_trans_rec.desc_flex.attribute4,
           X_attribute5            => p_dist_trans_rec.desc_flex.attribute5,
           X_attribute6            => p_dist_trans_rec.desc_flex.attribute6,
           X_attribute7            => p_dist_trans_rec.desc_flex.attribute7,
           X_attribute8            => p_dist_trans_rec.desc_flex.attribute8,
           X_attribute9            => p_dist_trans_rec.desc_flex.attribute9,
           X_attribute10           => p_dist_trans_rec.desc_flex.attribute10,
           X_attribute11           => p_dist_trans_rec.desc_flex.attribute11,
           X_attribute12           => p_dist_trans_rec.desc_flex.attribute12,
           X_attribute13           => p_dist_trans_rec.desc_flex.attribute13,
           X_attribute14           => p_dist_trans_rec.desc_flex.attribute14,
           X_attribute15           => p_dist_trans_rec.desc_flex.attribute15,
           X_attribute_Category_Code
                                   =>
                p_dist_trans_rec.desc_flex.attribute_category_code,
           X_Transaction_Key       => p_dist_trans_rec.transaction_key,
           X_Amortization_Start_Date
                                   => p_dist_trans_rec.amortization_start_date,
           X_Calling_Interface     => p_dist_trans_rec.calling_interface,
           X_Mass_Transaction_ID   => p_trans_rec.mass_transaction_id,
           X_Trx_Reference_Id      => p_trans_rec.trx_reference_id,
           X_Event_Id              => p_dist_trans_rec.event_id, --9413081
           X_Return_Status         => l_return_status,
           X_Calling_Fn            => 'fa_addition_pvt.insert_asset'
      ,  p_log_level_rec => p_log_level_rec);

      if not (l_return_status) then
         raise general_error;
      end if;
    end if;  -- end corporate
   end if;  -- end primary book

   -- Insert into fa_books.
   l_rowid := NULL;
   ---Added by Satish Byreddy In order to cater the Japan tax Reforms Migration Requirements

   IF p_asset_fin_rec.period_counter_life_complete IS NULL AND p_asset_fin_rec.period_counter_fully_reserved IS NOT NULL THEN
     p_asset_fin_rec.period_counter_life_complete := p_asset_fin_rec.period_counter_fully_reserved;
   END IF;

  -- End OF Additions

   fa_books_pkg.insert_row (
     X_Rowid                          => l_rowid,
     X_Book_Type_Code                 => p_asset_hdr_rec.book_type_code,
     X_Asset_Id                       => p_asset_hdr_rec.asset_id,
     X_Date_Placed_In_Service         => p_asset_fin_rec.date_placed_in_service,
     X_Date_Effective                 => l_date_effective,
     X_Deprn_Start_Date               => p_asset_fin_rec.deprn_start_date,
     X_Deprn_Method_Code              => p_asset_fin_rec.deprn_method_code,
     X_Life_In_Months                 => p_asset_fin_rec.life_in_months,
     X_Rate_Adjustment_Factor         => p_asset_fin_rec.rate_adjustment_factor,
     X_Adjusted_Cost                  => p_asset_fin_rec.adjusted_cost,
     X_Cost                           => p_asset_fin_rec.cost,
     X_Original_Cost                  => p_asset_fin_rec.original_cost,
     X_Salvage_Value                  => p_asset_fin_rec.salvage_value,
     X_Prorate_Convention_Code        => p_asset_fin_rec.prorate_convention_code,
     X_Prorate_Date                   => p_asset_fin_rec.prorate_date,
     X_Cost_Change_Flag               => p_asset_fin_rec.cost_change_flag,
     X_Adjustment_Required_Status     => p_asset_fin_rec.adjustment_required_status,
     X_Capitalize_Flag                => p_asset_fin_rec.capitalize_flag,
     X_Retirement_Pending_Flag        => p_asset_fin_rec.retirement_pending_flag,
     X_Depreciate_Flag                => p_asset_fin_rec.depreciate_flag,
     X_Disabled_Flag                  => p_asset_fin_rec.disabled_flag,--HH
     X_Last_Update_Date               => p_trans_rec.who_info.last_update_date,
     X_Last_Updated_By                => p_trans_rec.who_info.last_updated_by,
     X_Date_Ineffective               => NULL,
     X_Transaction_Header_Id_In       => p_trans_rec.transaction_header_id,
     X_Transaction_Header_Id_Out      => NULL,
     X_Itc_Amount_Id                  => p_asset_fin_rec.itc_amount_id,
     X_Itc_Amount                     => p_asset_fin_rec.itc_amount,
     X_Retirement_Id                  => p_asset_fin_rec.retirement_id,
     X_Tax_Request_Id                 => p_asset_fin_rec.tax_request_id,
     X_Itc_Basis                      => p_asset_fin_rec.itc_basis,
     X_Basic_Rate                     => p_asset_fin_rec.basic_rate,
     X_Adjusted_Rate                  => p_asset_fin_rec.adjusted_rate,
     X_Bonus_Rule                     => p_asset_fin_rec.bonus_rule,
     X_Ceiling_Name                   => p_asset_fin_rec.ceiling_name,
     X_Recoverable_Cost               => p_asset_fin_rec.recoverable_cost,
     X_Last_Update_Login              => p_trans_rec.who_info.last_update_login,
     X_Adjusted_Capacity              => p_asset_fin_rec.adjusted_capacity,
     X_Fully_Rsvd_Revals_Counter      => p_asset_fin_rec.period_counter_capitalized,
     X_PC_Fully_Reserved              => p_asset_fin_rec.period_counter_fully_reserved,
     X_Period_Counter_Fully_Retired   => p_asset_fin_rec.period_counter_fully_retired,
     X_Production_Capacity            => p_asset_fin_rec.production_capacity,
     X_Reval_Amortization_Basis       => p_asset_fin_rec.reval_amortization_basis,
     X_Reval_Ceiling                  => p_asset_fin_rec.reval_ceiling,
     X_Unit_Of_Measure                => p_asset_fin_rec.unit_of_measure,
     X_Unrevalued_Cost                => p_asset_fin_rec.unrevalued_cost,
     X_Annual_Deprn_Rounding_Flag     => p_asset_fin_rec.annual_deprn_rounding_flag,
     X_Percent_Salvage_Value          => p_asset_fin_rec.percent_salvage_value,
     X_Allowed_Deprn_Limit            => p_asset_fin_rec.allowed_deprn_limit,
     X_Allowed_Deprn_Limit_Amount     => p_asset_fin_rec.allowed_deprn_limit_amount,
     X_Period_Counter_Life_Complete   => p_asset_fin_rec.period_counter_life_complete,
     X_Adjusted_Recoverable_Cost      => p_asset_fin_rec.adjusted_recoverable_cost,
     X_Short_Fiscal_Year_Flag         => p_asset_fin_rec.short_fiscal_year_flag,
     X_Conversion_Date                => p_asset_fin_rec.conversion_date,
     X_Orig_Deprn_Start_Date          => p_asset_fin_rec.orig_deprn_start_date,
     X_Remaining_Life1                => p_asset_fin_rec.remaining_life1,
     X_Remaining_Life2                => p_asset_fin_rec.remaining_life2,
     X_Old_Adj_Cost                   => p_asset_fin_rec.old_adjusted_cost,
     X_Formula_Factor                 => p_asset_fin_rec.formula_factor,
     X_gf_attribute1                  => p_asset_fin_rec.global_attribute1,
     X_gf_attribute2                  => p_asset_fin_rec.global_attribute2,
     X_gf_attribute3                  => p_asset_fin_rec.global_attribute3,
     X_gf_attribute4                  => p_asset_fin_rec.global_attribute4,
     X_gf_attribute5                  => p_asset_fin_rec.global_attribute5,
     X_gf_attribute6                  => p_asset_fin_rec.global_attribute6,
     X_gf_attribute7                  => p_asset_fin_rec.global_attribute7,
     X_gf_attribute8                  => p_asset_fin_rec.global_attribute8,
     X_gf_attribute9                  => p_asset_fin_rec.global_attribute9,
     X_gf_attribute10                 => p_asset_fin_rec.global_attribute10,
     X_gf_attribute11                 => p_asset_fin_rec.global_attribute11,
     X_gf_attribute12                 => p_asset_fin_rec.global_attribute12,
     X_gf_attribute13                 => p_asset_fin_rec.global_attribute13,
     X_gf_attribute14                 => p_asset_fin_rec.global_attribute14,
     X_gf_attribute15                 => p_asset_fin_rec.global_attribute15,
     X_gf_attribute16                 => p_asset_fin_rec.global_attribute16,
     X_gf_attribute17                 => p_asset_fin_rec.global_attribute17,
     X_gf_attribute18                 => p_asset_fin_rec.global_attribute18,
     X_gf_attribute19                 => p_asset_fin_rec.global_attribute19,
     X_gf_attribute20                 => p_asset_fin_rec.global_attribute20,
     X_global_attribute_category      => p_asset_fin_rec.global_attribute_category,
     X_group_asset_id                 => p_asset_fin_rec.group_asset_id,
     X_salvage_type                   => p_asset_fin_rec.salvage_type,
     X_deprn_limit_type               => p_asset_fin_rec.deprn_limit_type,
     X_over_depreciate_option         => p_asset_fin_rec.over_depreciate_option,
     X_super_group_id                 => p_asset_fin_rec.super_group_id,
     X_reduction_rate                 => p_asset_fin_rec.reduction_rate,
     X_reduce_addition_flag           => p_asset_fin_rec.reduce_addition_flag,
     X_reduce_adjustment_flag         => p_asset_fin_rec.reduce_adjustment_flag,
     X_reduce_retirement_flag         => p_asset_fin_rec.reduce_retirement_flag,
     X_recognize_gain_loss            => p_asset_fin_rec.recognize_gain_loss,
     X_recapture_reserve_flag         => p_asset_fin_rec.recapture_reserve_flag,
     X_limit_proceeds_flag            => p_asset_fin_rec.limit_proceeds_flag,
     X_terminal_gain_loss             => p_asset_fin_rec.terminal_gain_loss,
     X_exclude_proceeds_from_basis    => p_asset_fin_rec.exclude_proceeds_from_basis,
     X_retirement_deprn_option        => p_asset_fin_rec.retirement_deprn_option,
     X_tracking_method                => p_asset_fin_rec.tracking_method,
     X_allocate_to_fully_rsv_flag     => p_asset_fin_rec.allocate_to_fully_rsv_flag,
     X_allocate_to_fully_ret_flag     => p_asset_fin_rec.allocate_to_fully_ret_flag,
     X_exclude_fully_rsv_flag         => p_asset_fin_rec.exclude_fully_rsv_flag,
     X_excess_allocation_option       => p_asset_fin_rec.excess_allocation_option,
     X_depreciation_option            => p_asset_fin_rec.depreciation_option,
     X_member_rollup_flag             => p_asset_fin_rec.member_rollup_flag,
     X_ytd_proceeds                   => p_asset_fin_rec.ytd_proceeds,
     X_ltd_proceeds                   => p_asset_fin_rec.ltd_proceeds,
     X_eofy_reserve                   => p_asset_fin_rec.eofy_reserve,
     X_terminal_gain_loss_amount      => p_asset_fin_rec.terminal_gain_loss_amount,
     X_ltd_cost_of_removal            => p_asset_fin_rec.ltd_cost_of_removal,
     X_cip_cost                       => p_asset_fin_rec.cip_cost,
     X_contract_id                    => p_asset_fin_rec.contract_id, -- Bug:8240522
     X_cash_generating_unit_id        => p_asset_fin_rec.cash_generating_unit_id,
     X_mrc_sob_type_code              => p_mrc_sob_type_code,
     X_set_of_books_id                => p_asset_hdr_rec.set_of_books_id,
     X_Return_Status                  => l_return_status,
     X_Calling_Fn                     => 'fa_addition_pvt.insert_asset'  ,
     X_nbv_at_switch                  => p_asset_fin_rec.nbv_at_switch             ,   -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
     X_prior_deprn_limit_type         => p_asset_fin_rec.prior_deprn_limit_type  ,
     X_prior_deprn_limit_amount       => p_asset_fin_rec.prior_deprn_limit_amount,
     X_prior_deprn_limit              => p_asset_fin_rec.prior_deprn_limit       ,
     X_period_counter_fully_rsrved    => p_asset_fin_rec.period_counter_fully_reserved       ,
     X_extended_depreciation_period   => p_asset_fin_rec.extended_depreciation_period         ,
     X_prior_deprn_method             => p_asset_fin_rec.prior_deprn_method      ,
     X_prior_life_in_months           => p_asset_fin_rec.prior_life_in_months    ,
     X_prior_basic_rate               => p_asset_fin_rec.prior_basic_rate        ,
     X_prior_adjusted_rate            => p_asset_fin_rec.prior_adjusted_rate ,
     X_extended_deprn_flag            => p_asset_fin_rec.extended_deprn_flag
     -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
,  p_log_level_rec => p_log_level_rec);

   if not (l_return_status) then
      raise general_error;
   end if;

   if ( p_mrc_sob_type_code <> 'R') then
      if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

        -- Insert into fa_asset_history.
        l_rowid := NULL;

        fa_asset_history_pkg.insert_row (
         X_Rowid                  => l_rowid,
         X_Asset_Id               => p_asset_hdr_rec.asset_id,
         X_Category_Id            => p_asset_cat_rec.category_id,
         X_Asset_Type             => upper(p_asset_type_rec.asset_type),
         X_Units                  => p_asset_desc_rec.current_units,
         X_Date_Effective         => l_date_effective,
         X_Transaction_Header_Id_In
                      => p_trans_rec.transaction_header_id,
         X_Transaction_Header_Id_Out
                      => NULL,
         X_Last_Update_Date       => p_trans_rec.who_info.last_update_date,
         X_Last_Updated_By        => p_trans_rec.who_info.last_updated_by,
         X_Last_Update_Login      => p_trans_rec.who_info.last_update_login,
         X_Return_Status          => l_return_status,
         X_Calling_Fn             => 'fa_addition_pvt.insert_asset'
        , p_log_level_rec => p_log_level_rec);

        if not (l_return_status) then
           raise general_error;
        end if;

        -- Insert into fa_distributions.
        l_distribution_count := px_asset_dist_tbl.COUNT;

        for i in 1..l_distribution_count loop
           l_rowid := NULL;
           l_distribution_id := NULL;

           fa_distribution_history_pkg.insert_row (
              X_Rowid                => l_rowid,
              X_Distribution_Id      => l_distribution_id,
              X_Book_Type_Code       => p_asset_hdr_rec.book_type_code,
              X_Asset_Id             => p_asset_hdr_rec.asset_id,
              X_Units_Assigned       => px_asset_dist_tbl(i).units_assigned,
              X_Date_Effective       => l_date_effective,
              X_Code_Combination_Id  => px_asset_dist_tbl(i).expense_ccid,
              X_Location_Id          => px_asset_dist_tbl(i).location_ccid,
              X_Transaction_Header_Id_In
                                     => p_dist_trans_rec.transaction_header_id,
              X_Last_Update_Date     =>
                 p_dist_trans_rec.who_info.last_update_date,
              X_Last_Updated_By      =>
                 p_dist_trans_rec.who_info.last_updated_by,
              X_Date_Ineffective     => NULL,
              X_Assigned_To          => px_asset_dist_tbl(i).assigned_to,
              X_Transaction_Header_Id_Out
                                     => NULL,
              X_Transaction_Units    => NULL,
              X_Retirement_Id        => p_asset_fin_rec.retirement_id,
              X_Last_Update_Login    =>
                 p_dist_trans_rec.who_info.last_update_login,
              X_Calling_Fn           => 'fa_addition_pvt.insert_asset'
           , p_log_level_rec => p_log_level_rec);

           px_asset_dist_tbl(i).distribution_id := l_distribution_id;

        end loop;
      end if;  -- end corporate
   end if;  -- end primary book

   l_ds_rowid := NULL;

   -- Insert into fa_deprn_summary
   fa_deprn_summary_pkg.insert_row (
     X_Rowid               => l_ds_rowid,
     X_Book_Type_Code      => p_asset_hdr_rec.book_type_code,
     X_Asset_Id            => p_asset_hdr_rec.asset_id,
     X_Deprn_Run_Date      => l_deprn_run_date,
     X_Deprn_Amount        => nvl(p_asset_deprn_rec.deprn_amount,0),
     X_Ytd_Deprn           => nvl(p_asset_deprn_rec.ytd_deprn,0),
     X_Deprn_Reserve       => nvl(p_asset_deprn_rec.deprn_reserve,0),
     X_Deprn_Source_Code   => 'BOOKS',
     X_Adjusted_Cost       => nvl(p_asset_fin_rec.adjusted_cost,0),
     X_Bonus_Rate          => l_bonus_rate,
     X_Ltd_Production      => p_asset_deprn_rec.ltd_production,
     X_Period_Counter      => l_period_counter,
     X_Production          => p_asset_deprn_rec.production,
     X_Reval_Amortization  => p_asset_deprn_rec.reval_amortization,
     X_Reval_Amortization_Basis
                           => p_asset_deprn_rec.reval_amortization_basis,
     X_Reval_Deprn_Expense => p_asset_deprn_rec.reval_deprn_expense,
     X_Reval_Reserve       => p_asset_deprn_rec.reval_deprn_reserve,
     X_Ytd_Production      => p_asset_deprn_rec.ytd_production,
     X_Ytd_Reval_Deprn_Expense
                           => p_asset_deprn_rec.reval_ytd_deprn,
     X_Bonus_Deprn_Amount  => p_asset_deprn_rec.bonus_deprn_amount,
     X_Bonus_Ytd_Deprn     => p_asset_deprn_rec.bonus_ytd_deprn,
     X_Bonus_Deprn_Reserve => p_asset_deprn_rec.bonus_deprn_reserve,
     X_Impairment_Amount   => p_asset_deprn_rec.impairment_amount,
     X_Ytd_Impairment      => p_asset_deprn_rec.ytd_impairment,
     X_impairment_reserve  => p_asset_deprn_rec.impairment_reserve,
     X_mrc_sob_type_code   => p_mrc_sob_type_code,
     X_set_of_books_id     => p_asset_hdr_rec.set_of_books_id,
     X_Calling_Fn          => 'fa_addition_pvt.insert_asset'
   , p_log_level_rec => p_log_level_rec);

   -- Insert into fa_deprn_detail
   -- br: changed to use faxindd which automatically handles multi-dist
   l_status := FA_INS_DETAIL_PKG.FAXINDD (
          X_book_type_code     => p_asset_hdr_rec.book_type_code,
          X_asset_id           => p_asset_hdr_rec.asset_id,
          X_mrc_sob_type_code  => p_mrc_sob_type_code,
          X_set_of_books_id    => p_asset_hdr_rec.set_of_books_id
   , p_log_level_rec => p_log_level_rec);

   if not (l_status) then
      raise general_error;
   end if;


   -- BUG# 2115343 need to reset the cache to the active book after faxindd

   l_status := fa_cache_pkg.fazcbc (
      X_book => p_asset_hdr_rec.book_type_code
   , p_log_level_rec => p_log_level_rec);

   if not (l_status) then
      raise general_error;
   end if;

   -- Insert into fa_books_summary if polish rule
   if not fa_cache_pkg.fazccmt
          (X_method => p_asset_fin_rec.deprn_method_code,
           X_life   => p_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec) then
      raise general_error;
   end if;

   if (p_asset_type_rec.asset_type <> 'GROUP') then
      l_rowid := NULL;

      if (NOT FA_UTIL_PVT.get_period_rec (
         p_book           => p_asset_hdr_rec.book_type_code,
         p_effective_date => NULL,
         x_period_rec     => l_period_rec
      , p_log_level_rec => p_log_level_rec)) then
         raise general_error;
      end if;

      if (p_asset_fin_rec.period_counter_capitalized is null) then
         l_capitalized_flag := 'N';
      else
         l_capitalized_flag := 'Y';
      end if;

      if (p_asset_fin_rec.period_counter_fully_reserved is null) then
         l_fully_reserved_flag := 'N';
      else
         l_fully_reserved_flag := 'Y';
      end if;

      if (p_asset_fin_rec.period_counter_fully_retired is null) then
         l_fully_retired_flag := 'N';
      else
         l_fully_retired_flag := 'Y';
      end if;

      if (p_asset_fin_rec.period_counter_life_complete is null) then
         l_life_complete_flag := 'N';
      else
         l_life_complete_flag := 'Y';
      end if;

      -- Insert into current period DEPRN row
      fa_books_summary_pkg.insert_row (
        X_Rowid                       => l_rowid,
        X_Book_Type_Code              => p_asset_hdr_rec.book_type_code,
        X_Asset_Id                    => p_asset_hdr_rec.asset_id,
        X_Period_Counter              => l_period_counter + 1,
        X_Calendar_Period_Open_Date   =>
           l_period_rec.calendar_period_open_date,
        X_Calendar_Period_Close_Date  =>
           l_period_rec.calendar_period_close_date,
        X_Reset_Adjusted_Cost_Flag    => 'Y',
        X_Change_In_Cost              => 0,
        X_Change_In_Additions_Cost    => 0,
        X_Change_In_Adjustments_Cost  => 0,
        X_Change_In_Retirements_Cost  => 0,
        X_Change_In_Group_Rec_Cost    => 0,
        X_Change_In_CIP_Cost          => 0,
        X_Cost                        => p_asset_fin_rec.cost,
        X_CIP_Cost                    => p_asset_fin_rec.cip_cost,
        X_Salvage_Type                => p_asset_fin_rec.salvage_type,
        X_Percent_Salvage_Value       => p_asset_fin_rec.percent_salvage_value,
        X_Salvage_Value               => p_asset_fin_rec.salvage_value,
        X_Member_Salvage_Value        => 0,
        X_Recoverable_Cost            => p_asset_fin_rec.recoverable_cost,
        X_Deprn_Limit_Type            => p_asset_fin_rec.deprn_limit_type,
        X_Allowed_Deprn_Limit         => p_asset_fin_rec.allowed_deprn_limit,
        X_Allowed_Deprn_Limit_Amount  =>
           p_asset_fin_rec.allowed_deprn_limit_amount,
        X_Member_Deprn_Limit_Amount   => 0,
        X_Adjusted_Recoverable_Cost   =>
           p_asset_fin_rec.adjusted_recoverable_cost,
        X_Adjusted_Cost               => p_asset_fin_rec.adjusted_cost,
        X_Depreciate_Flag             => p_asset_fin_rec.depreciate_flag,
        X_Disabled_Flag               => p_asset_fin_rec.disabled_flag,
        X_Date_Placed_In_Service      => p_asset_fin_rec.date_placed_in_service,
        X_Deprn_Method_Code           => p_asset_fin_rec.deprn_method_code,
        X_Life_In_Months              => p_asset_fin_rec.life_in_months,
        X_Rate_Adjustment_Factor      => p_asset_fin_rec.rate_adjustment_factor,
        X_Adjusted_Rate               => p_asset_fin_rec.adjusted_rate,
        X_Bonus_Rule                  => p_asset_fin_rec.bonus_rule,
        X_Adjusted_Capacity           => p_asset_fin_rec.adjusted_capacity,
        X_Production_Capacity         => p_asset_fin_rec.production_capacity,
        X_Unit_Of_Measure             => p_asset_fin_rec.unit_of_measure,
        X_Remaining_Life1             => p_asset_fin_rec.remaining_life1,
        X_Remaining_Life2             => p_asset_fin_rec.remaining_life2,
        X_Formula_Factor              => p_asset_fin_rec.formula_factor,
        X_Unrevalued_Cost             => p_asset_fin_rec.unrevalued_cost,
        X_Reval_Amortization_Basis    =>
           p_asset_fin_rec.reval_amortization_basis,
        X_Reval_Ceiling               => p_asset_fin_rec.reval_ceiling,
        X_Ceiling_Name                => p_asset_fin_rec.ceiling_name,
        X_Eofy_Adj_Cost               => nvl(p_asset_fin_rec.eofy_adj_cost, 0),
        X_Eofy_Formula_Factor         =>
           nvl(p_asset_fin_rec.eofy_formula_factor, 1),
        X_Eofy_Reserve                => nvl(p_asset_fin_rec.eofy_reserve, 0),
        X_Eop_Adj_Cost                => nvl(p_asset_fin_rec.eop_adj_cost, 0),
        X_Eop_Formula_Factor          =>
           nvl(p_asset_fin_rec.eop_formula_factor, 1),
        X_Short_Fiscal_Year_Flag      => p_asset_fin_rec.short_fiscal_year_flag,
        X_Group_Asset_ID              => p_asset_fin_rec.group_asset_id,
        X_Super_Group_ID              => p_asset_fin_rec.super_group_id,
        X_Over_Depreciate_Option      => p_asset_fin_rec.over_depreciate_option,
        X_Fully_Rsvd_Revals_Counter   =>
           p_asset_fin_rec.period_counter_capitalized,
        X_Capitalized_Flag            => l_capitalized_flag,
        X_Fully_Reserved_Flag         => l_fully_reserved_flag,
        X_Fully_Retired_Flag          => l_fully_retired_flag,
        X_Life_Complete_Flag          => l_life_complete_flag,
        X_Terminal_Gain_Loss_Amount   =>
           nvl(p_asset_fin_rec.terminal_gain_loss_amount, 0),
        X_Terminal_Gain_Loss_Flag     =>
           nvl(p_asset_fin_rec.terminal_gain_loss_flag, 'N'),
        X_Deprn_Amount                => nvl(p_asset_deprn_rec.deprn_amount,0),
        X_Ytd_Deprn                   => nvl(p_asset_deprn_rec.ytd_deprn,0),
        X_Deprn_Reserve               => nvl(p_asset_deprn_rec.deprn_reserve,0),
        X_Bonus_Deprn_Amount          => p_asset_deprn_rec.bonus_deprn_amount,
        X_Bonus_Ytd_Deprn             => p_asset_deprn_rec.bonus_ytd_deprn,
        X_Bonus_Deprn_Reserve         => p_asset_deprn_rec.bonus_deprn_reserve,
        X_Bonus_Rate                  => l_bonus_rate,
        X_Impairment_Amount           => p_asset_deprn_rec.impairment_amount,
        X_Ytd_Impairment              => p_asset_deprn_rec.ytd_impairment,
        X_impairment_reserve              => p_asset_deprn_rec.impairment_reserve,
        X_Ltd_Production              => p_asset_deprn_rec.ltd_production,
        X_Ytd_Production              => p_asset_deprn_rec.ytd_production,
        X_Production                  => p_asset_deprn_rec.production,
        X_Reval_Amortization          => p_asset_deprn_rec.reval_amortization,
        X_Reval_Deprn_Expense         => p_asset_deprn_rec.reval_deprn_expense,
        X_Reval_Reserve               => p_asset_deprn_rec.reval_deprn_reserve,
        X_Ytd_Reval_Deprn_Expense     => p_asset_deprn_rec.reval_ytd_deprn,
        X_Deprn_Override_Flag         => deprn_override_flag_default,
        X_System_Deprn_Amount         => 0,
        X_System_Bonus_Deprn_Amount   => 0,
        X_Ytd_Proceeds_Of_Sale        => p_asset_fin_rec.ytd_proceeds,
        X_Ltd_Proceeds_Of_Sale        => p_asset_fin_rec.ltd_proceeds,
        X_Ytd_Cost_Of_Removal         => 0,
        X_Ltd_Cost_Of_Removal         =>
           nvl(p_asset_fin_rec.ltd_cost_of_removal, 0),
        X_Deprn_Adjustment_Amount     => 0,
        X_Expense_Adjustment_Amount   => 0,
        X_Unplanned_Amount            => 0,
        X_Reserve_Adjustment_Amount   => 0,
        X_Last_Update_Date            => p_trans_rec.who_info.last_update_date,
        X_Last_Updated_By             => p_trans_rec.who_info.last_updated_by,
        X_Created_By                  => p_trans_rec.who_info.created_by,
        X_Creation_Date               => p_trans_rec.who_info.creation_date,
        X_Last_Update_Login           => p_trans_rec.who_info.last_update_login,
        X_Change_In_Eofy_Reserve      => 0,
        X_Switch_Code                 => NULL, -- derived at depreciation
        X_mrc_sob_type_code           => p_mrc_sob_type_code,
        X_set_of_books_id             => p_asset_hdr_rec.set_of_books_id,
        X_Return_Status               => l_return_status,
        X_Calling_Fn                  => 'fa_addition_pvt.insert_asset', p_log_level_rec => p_log_level_rec);

      if not (l_return_status) then
         raise general_error;
      end if;
   end if;

   -- br: moved this from the main code so that primary and reporting
   --     books are processed

   -- br: moved this from the main code so that primary and reporting
   --     books are processed

   -- SLA Uptake, do catchup if applicable...
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('fa_addition_pvt.insert_asset', 'trx_subtype',
p_trans_rec.transaction_subtype
            ,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('fa_addition_pvt.insert_asset', 'asset_type',
p_asset_type_rec.asset_type
            ,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('fa_addition_pvt.insert_asset', 'group asset id',
p_asset_fin_rec.group_asset_id
            ,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('fa_addition_pvt.insert_asset', 'annaul round flag',
p_asset_fin_rec.annual_deprn_rounding_flag
            ,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('fa_addition_pvt.insert_asset',
'p_trans_rec.transaction_date_entered', p_trans_rec.transaction_date_entered
            ,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('fa_addition_pvt.insert_asset',
'p_period_rec.calendar_period_open_date', p_period_rec.calendar_period_open_date
            ,p_log_level_rec => p_log_level_rec);

   end if;

   -- Bug no 4704128 spooyath
   -- added nvl checking for p_asset_fin_rec.annual_deprn_rounding_flag
   -- its value is null for assets added with DPIS not in current fiscal year

   -- Bug 4739563  call the catchup logic only when the addition is a
   -- backdated one
   -- added the check on p_trans_rec.transaction_date_entered and
   -- p_period_rec.calendar_period_open_date

   --bug7228041 Added the 'OR' condition in following IF condition.
   --so that correct catch-up is calculated in case of 'START OF YEAR prorate convention

   -- R12 conditional handling
   if (G_release <> 11 and
       (nvl(p_trans_rec.transaction_subtype, 'EXPENSED') <> 'AMORTIZED') and
       (p_asset_type_rec.asset_type = 'CAPITALIZED') and
       (p_asset_fin_rec.group_asset_id is null) and
       (nvl(p_asset_fin_rec.annual_deprn_rounding_flag,'ADD') <> 'RES') and
       ((p_trans_rec.transaction_date_entered < p_period_rec.calendar_period_open_date)
       or (p_asset_fin_rec.prorate_date < p_period_rec.calendar_period_open_date))) then

      if not FA_EXP_PVT.faxexp
                        (px_trans_rec          => p_trans_rec,
                         p_asset_hdr_rec       => p_asset_hdr_rec,
                         p_asset_desc_rec      => p_asset_desc_rec,
                         p_asset_cat_rec       => p_asset_cat_rec,
                         p_asset_type_rec      => p_asset_type_rec,
                         p_asset_fin_rec_old   => l_asset_fin_rec_null,
                         px_asset_fin_rec_new  => p_asset_fin_rec,
                         p_asset_deprn_rec     => p_asset_deprn_rec,
                         p_period_rec          => p_period_rec,
                         p_mrc_sob_type_code   => p_mrc_sob_type_code,
                         p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation => null,
                         x_deprn_exp           => l_deprn_exp,
                         x_bonus_deprn_exp     => l_bonus_deprn_exp,
                         x_impairment_exp      => l_impairment_exp,
                         x_ann_adj_deprn_exp   => l_ann_adj_deprn_exp,
                         x_ann_adj_bonus_deprn_exp   => l_ann_adj_bonus_deprn_exp,
                         p_log_level_rec  => p_log_level_rec) then
                        raise general_error;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('fa_addition_pvt.insert_asset', 'l_deprn_exp after faxexp',
                          l_deprn_exp, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add('fa_addition_pvt.insert_asset', 'l_bonus_deprn_exp after faxexp',
                           l_bonus_deprn_exp, p_log_level_rec =>
p_log_level_rec);
         fa_debug_pkg.add('fa_addition_pvt.insert_asset', 'Calling fa_books_pkg.update_row',
                           'after calling faxexp', p_log_level_rec => p_log_level_rec);
      end if;

      --
      -- Bug4439895:  Reflect post catch-up info to fa_books
      --
      fa_books_pkg.update_row
           (X_asset_id                  => p_asset_hdr_rec.asset_id,
            X_book_type_code            => p_asset_hdr_rec.book_type_code,
            X_rate_adjustment_factor    => p_asset_fin_rec.rate_adjustment_factor,
            X_reval_amortization_basis  => p_asset_fin_rec.reval_amortization_basis,
            X_adjusted_cost             => p_asset_fin_rec.adjusted_cost,
            X_adjusted_capacity         => p_asset_fin_rec.adjusted_capacity,
            X_formula_factor            => p_asset_fin_rec.formula_factor,
            X_eofy_reserve              => p_asset_fin_rec.eofy_reserve,
            X_mrc_sob_type_code         => p_mrc_sob_type_code,
            X_set_of_books_id           => p_asset_hdr_rec.set_of_books_id,
            X_calling_fn                => 'fa_addition_pvt.insert_asset',
            p_log_level_rec  => p_log_level_rec);

      -- Bug:5701095
      FA_DEPRN_SUMMARY_PKG.Update_Row (
          X_Rowid                    => l_ds_rowid,
          X_Book_Type_Code           => p_asset_hdr_rec.book_type_code,
          X_Asset_Id                 => p_asset_hdr_rec.asset_id,
          X_Deprn_Run_Date           => p_trans_rec.who_info.last_update_date,
          X_Deprn_Amount             => p_asset_deprn_rec.deprn_amount,
          X_Ytd_Deprn                => p_asset_deprn_rec.ytd_deprn,
          X_Deprn_Reserve            => p_asset_deprn_rec.deprn_reserve,
          X_Deprn_Source_Code        => 'BOOKS',
          X_Adjusted_Cost            => p_asset_fin_rec.adjusted_cost,
          X_Bonus_Rate               => NULL,
          X_Ltd_Production           => NULL,
          X_Period_Counter           => l_period_counter,
          X_Production               => NULL,
          X_Reval_Amortization       => p_asset_deprn_rec.reval_amortization,
          X_Reval_Amortization_Basis => l_reval_amortization_basis,
          X_Reval_Deprn_Expense      => p_asset_deprn_rec.reval_deprn_expense,
          X_Reval_Reserve            => p_asset_deprn_rec.reval_deprn_reserve,
          X_Ytd_Production           => NULL,
          X_Ytd_Reval_Deprn_Expense  => p_asset_deprn_rec.reval_ytd_deprn,
          X_mrc_sob_type_code        => p_mrc_sob_type_code,
          X_set_of_books_id          => p_asset_hdr_rec.set_of_books_id,
          X_Calling_Fn               => 'fa_addition_pvt.insert_asset',
          p_log_level_rec  => p_log_level_rec);

   elsif ((p_trans_rec.transaction_subtype = 'AMORTIZED') and
       (p_asset_type_rec.asset_type = 'CAPITALIZED') and
       ((p_asset_fin_rec.group_asset_id is null) or
        (p_asset_fin_rec.group_asset_id is not null and
         nvl(p_asset_fin_rec.tracking_method, 'OTHER') = 'CALCULATE'))) then
      --bug3548724
      l_asset_deprn_rec_adj.deprn_reserve := p_asset_deprn_rec.deprn_reserve;
      l_asset_deprn_rec_adj.ytd_deprn := p_asset_deprn_rec.ytd_deprn; -- Bug 9231768

      if not FA_AMORT_PVT.faxama
               (px_trans_rec          => p_trans_rec,
                p_asset_hdr_rec       => p_asset_hdr_rec,
                p_asset_desc_rec      => p_asset_desc_rec,
                p_asset_cat_rec       => p_asset_cat_rec,
                p_asset_type_rec      => p_asset_type_rec,
                p_asset_fin_rec_old   => p_asset_fin_rec,
                px_asset_fin_rec_new  => p_asset_fin_rec,
                p_asset_deprn_rec     => p_asset_deprn_rec,
                p_asset_deprn_rec_adj => l_asset_deprn_rec_adj, --bug3548724
                p_period_rec          => p_period_rec,
                p_mrc_sob_type_code   => p_mrc_sob_type_code,
                p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                p_used_by_revaluation => null,
                x_deprn_exp           => l_deprn_exp,
                x_bonus_deprn_exp     => l_bonus_deprn_exp,
                x_impairment_exp      => l_impairment_exp
                , p_log_level_rec => p_log_level_rec) then raise general_error;
      end if;

      if not (l_status) then
         raise general_error;
      end if;

      -- R12 conditional handling
      -- SLA: removing original faxiat call from here as we now call for all

      if (G_release = 11) then
         -- insert all the amounts
         if not FA_INS_ADJ_PVT.faxiat
                     (p_trans_rec       => p_trans_rec,
                      p_asset_hdr_rec   => p_asset_hdr_rec,
                      p_asset_desc_rec  => p_asset_desc_rec,
                      p_asset_cat_rec   => p_asset_cat_rec,
                      p_asset_type_rec  => p_asset_type_rec,
                      p_cost            => 0,
                      p_clearing        => 0,
                      p_deprn_expense   => l_deprn_exp,
                      p_bonus_expense   => l_bonus_deprn_exp,
                      p_impair_expense  => l_impairment_exp,
                      p_ann_adj_amt     => 0,
                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                      p_calling_fn      => 'fa_addition_pvt.insert_asset'
                     , p_log_level_rec => p_log_level_rec) then raise general_error;
         end if;

      end if;

      fa_books_pkg.update_row
           (X_asset_id                  => p_asset_hdr_rec.asset_id,
            X_book_type_code            => p_asset_hdr_rec.book_type_code,
            X_rate_adjustment_factor    => p_asset_fin_rec.rate_adjustment_factor,
            X_reval_amortization_basis  => p_asset_fin_rec.reval_amortization_basis,
            X_adjusted_cost             => p_asset_fin_rec.adjusted_cost,
            X_adjusted_capacity         => p_asset_fin_rec.adjusted_capacity,
            X_formula_factor            => p_asset_fin_rec.formula_factor,
            X_eofy_reserve              => p_asset_fin_rec.eofy_reserve,
            X_mrc_sob_type_code         => p_mrc_sob_type_code,
            X_set_of_books_id           => p_asset_hdr_rec.set_of_books_id,
            X_calling_fn                => 'fa_addition_pvt.insert_asset',  p_log_level_rec => p_log_level_rec);

      -- now update the primary or reporting amounts accordingly
      if (p_mrc_sob_type_code <> 'R') then

         delete from fa_adjustments
          where asset_id        = p_asset_hdr_rec.asset_id
            and book_type_code  = p_asset_hdr_rec.book_type_code
            and adjustment_type in ('COST', 'COST CLEARING');

      else

         delete from fa_mc_adjustments
          where asset_id        = p_asset_hdr_rec.asset_id
            and book_type_code  = p_asset_hdr_rec.book_type_code
            and adjustment_type in ('COST', 'COST CLEARING')
            and set_of_books_id = p_asset_hdr_rec.set_of_books_id;

      end if;

      FA_DEPRN_SUMMARY_PKG.Update_Row (
          X_Rowid                    => l_ds_rowid,
          X_Book_Type_Code           => p_asset_hdr_rec.book_type_code,
          X_Asset_Id                 => p_asset_hdr_rec.asset_id,
          X_Deprn_Run_Date           => p_trans_rec.who_info.last_update_date,
          X_Deprn_Amount             => p_asset_deprn_rec.deprn_amount,
          X_Ytd_Deprn                => p_asset_deprn_rec.ytd_deprn,
          X_Deprn_Reserve            => p_asset_deprn_rec.deprn_reserve,
          X_Deprn_Source_Code        => 'BOOKS',
          X_Adjusted_Cost            => p_asset_fin_rec.adjusted_cost,
          X_Bonus_Rate               => NULL,
          X_Ltd_Production           => NULL,
          X_Period_Counter           => l_period_counter,
          X_Production               => NULL,
          X_Reval_Amortization       => p_asset_deprn_rec.reval_amortization,
          X_Reval_Amortization_Basis => l_reval_amortization_basis,
          X_Reval_Deprn_Expense      => p_asset_deprn_rec.reval_deprn_expense,
          X_Reval_Reserve            => p_asset_deprn_rec.reval_deprn_reserve,
          X_Ytd_Production           => NULL,
          X_Ytd_Reval_Deprn_Expense  => p_asset_deprn_rec.reval_ytd_deprn,
          X_mrc_sob_type_code        => p_mrc_sob_type_code,
          X_set_of_books_id          => p_asset_hdr_rec.set_of_books_id,
          X_Calling_Fn               => 'fa_addition_pvt.insert_asset'
       ,  p_log_level_rec => p_log_level_rec);
   end if;  -- end amort nbv

   -- R12 conditonal handling
   if (G_release <> 11) then

   if (p_inv_trans_rec.invoice_transaction_id is not null) then

      l_adj.transaction_header_id    := p_trans_rec.transaction_header_id;
      l_adj.asset_id                 := p_asset_hdr_rec.asset_id;
      l_adj.book_type_code           := p_asset_hdr_rec.book_type_code;
      l_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
      l_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
      l_adj.current_units            := p_asset_desc_rec.current_units ;
      l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
      l_adj.selection_thid           := 0;
      l_adj.selection_retid          := 0;
      l_adj.leveling_flag            := TRUE;
      l_adj.last_update_date         := p_trans_rec.who_info.last_update_date;

      l_adj.flush_adj_flag           := FALSE;
      l_adj.gen_ccid_flag            := FALSE;
      l_adj.annualized_adjustment    := 0;
      l_adj.distribution_id          := 0;

      l_adj.adjustment_type          := 'COST CLEARING';
      l_adj.source_type_code         := p_trans_rec.transaction_type_code;

      if l_adj.source_type_code = 'CIP ADJUSTMENT' then
         l_adj.account_type     := 'CIP_CLEARING_ACCT';
      else
         l_adj.account_type     := 'ASSET_CLEARING_ACCT';
      end if;

      if (p_mrc_sob_type_code <> 'R') then

         OPEN c_invoices(p_asset_id               => p_asset_hdr_rec.asset_id,
                         p_invoice_transaction_id => p_inv_trans_rec.invoice_transaction_id);
         FETCH c_invoices bulk collect
          into l_source_line_id_tbl,
               l_asset_invoice_id_tbl,
               l_payables_cost_tbl,
               l_payables_ccid_tbl;
          close c_invoices;

         for i in 1..l_payables_cost_tbl.count loop

             -- SLA changes
             l_adj.source_line_id      := l_source_line_id_tbl(i);
             l_adj.code_combination_id := l_payables_ccid_tbl(i);
             l_adj.asset_invoice_id    := l_asset_invoice_id_tbl(i);

             if l_payables_cost_tbl(i) > 0 then
                l_adj.debit_credit_flag   := 'CR';
                l_adj.adjustment_amount   := l_payables_cost_tbl(i);
             else
                l_adj.debit_credit_flag   := 'DR';
                l_adj.adjustment_amount   := -l_payables_cost_tbl(i);
             end if;

             l_adj.mrc_sob_type_code := 'P';
             l_adj.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

             if not FA_INS_ADJUST_PKG.faxinaj
                      (l_adj,
                       p_trans_rec.who_info.last_update_date,
                       p_trans_rec.who_info.last_updated_by,
                       p_trans_rec.who_info.last_update_login,
                       p_log_level_rec  => p_log_level_rec) then
                raise general_error;
             end if;

            l_clearing := l_clearing + l_payables_cost_tbl(i);
         end loop;

      else

         open c_mc_invoices(p_asset_id               => p_asset_hdr_rec.asset_id,
                            p_invoice_transaction_id => p_inv_trans_rec.invoice_transaction_id);

         FETCH c_mc_invoices bulk collect
          into l_source_line_id_tbl,
               l_asset_invoice_id_tbl,
               l_payables_cost_tbl,
               l_payables_ccid_tbl;
          close c_mc_invoices;

         for i in 1..l_payables_cost_tbl.count loop

             -- SLA changes
             l_adj.source_line_id      := l_source_line_id_tbl(i);
             l_adj.code_combination_id := l_payables_ccid_tbl(i);
             l_adj.asset_invoice_id    := l_asset_invoice_id_tbl(i);

             if l_payables_cost_tbl(i) > 0 then
                l_adj.debit_credit_flag   := 'CR';
                l_adj.adjustment_amount   := l_payables_cost_tbl(i);
             else
                l_adj.debit_credit_flag   := 'DR';
                l_adj.adjustment_amount   := -l_payables_cost_tbl(i);
             end if;

             l_adj.mrc_sob_type_code := 'R';
             l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

             if not FA_INS_ADJUST_PKG.faxinaj
                      (l_adj,
                       p_trans_rec.who_info.last_update_date,
                       p_trans_rec.who_info.last_updated_by,
                       p_trans_rec.who_info.last_update_login
                       ,p_log_level_rec => p_log_level_rec) then
                raise general_error;
             end if;

             l_clearing := l_clearing + l_payables_cost_tbl(i);

          end loop;

       end if;

    end if;

    -- flush them
    l_adj.transaction_header_id := 0;
    l_adj.flush_adj_flag        := TRUE;
    l_adj.leveling_flag         := TRUE;

    if not FA_INS_ADJUST_PKG.faxinaj
            (l_adj,
             p_trans_rec.who_info.last_update_date,
             p_trans_rec.who_info.last_updated_by,
             p_trans_rec.who_info.last_update_login,
             p_log_level_rec  => p_log_level_rec) then
       raise general_error;
    end if;

    -- need to reset this after each flush
    l_adj.transaction_header_id  := p_trans_rec.transaction_header_id;


    -- insert all the amounts
    -- SLA: include catchup/amort nbv/cost and clearing now

    if not FA_INS_ADJ_PVT.faxiat
              (p_trans_rec       => p_trans_rec,
               p_asset_hdr_rec   => p_asset_hdr_rec,
               p_asset_desc_rec  => p_asset_desc_rec,
               p_asset_cat_rec   => p_asset_cat_rec,
               p_asset_type_rec  => p_asset_type_rec,
               p_cost            => p_asset_fin_rec.cost,
               p_clearing        => p_asset_fin_rec.cost - l_clearing,
               p_deprn_expense   => l_deprn_exp,
               p_bonus_expense   => l_bonus_deprn_exp,
               p_ann_adj_amt     => l_ann_adj_deprn_exp, --0,
               p_mrc_sob_type_code => p_mrc_sob_type_code,
               p_calling_fn      => 'fa_addition_pvt.insert_asset',
               p_log_level_rec  => p_log_level_rec) then raise general_error;
    end if;

    end if;

    -- Bug:5930979:Japan Tax Reform Project (Start)
    -- Modified below code for Japan enhancement 6606548 (Backdated Asset Addition for JP-250DB methods)
    if nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES' then

       p_asset_fin_rec.nbv_at_switch := nvl(p_asset_fin_rec.nbv_at_switch,0);  -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start

       -- deprn reserve not entered and nbv_at_switch entered
       if (p_asset_deprn_rec.deprn_reserve = 0 and p_asset_fin_rec.nbv_at_switch <> 0) then
            fa_srvr_msg.add_message(calling_fn => 'fa_addition_pvt.insert_asset',
                                   name       => 'FA_ADD_SWITCH_NBV_WITHOUT_RSV',  p_log_level_rec => p_log_level_rec);  -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
            raise general_error;
       end if;

       FA_CDE_PKG.faxgfr (X_Book_Type_Code         => p_asset_hdr_rec.book_type_code,
                           X_Asset_Id               => p_asset_hdr_rec.asset_id,
                           X_Short_Fiscal_Year_Flag => p_asset_fin_rec.short_fiscal_year_flag,
                           X_Conversion_Date        => p_asset_fin_rec.conversion_date,
                           X_Prorate_Date           => p_asset_fin_rec.prorate_date,
                           X_Orig_Deprn_Start_Date  => p_asset_fin_rec.orig_deprn_start_date,
                           C_Prorate_Date           => NULL,
                           C_Conversion_Date        => NULL,
                           C_Orig_Deprn_Start_Date  => NULL,
                           X_Method_Code            => p_asset_fin_rec.deprn_method_code,
                           X_Life_In_Months         => p_asset_fin_rec.life_in_months,
                           X_Fiscal_Year            => -99,
                           X_Current_Period         => l_period_rec.period_counter,
                           X_calling_interface      => 'ADDITION',
                           X_Rate                   => l_rate_in_use,
                           X_Method_Type            => l_method_type,
                           X_Success                => l_success, p_log_level_rec => p_log_level_rec);

       if (l_success <= 0) then
         fa_srvr_msg.add_message(calling_fn => 'fa_addition_pvt.insert_asset',  p_log_level_rec => p_log_level_rec);
         raise general_error;
       end if;


       -- Fix for Bug #6334489.  Do not allow addition of asset with
       -- revised rate.
       select count(*)
       into   l_revised_count
       from   fa_methods mt,
              fa_formulas f
       where  mt.method_code = p_asset_fin_rec.deprn_method_code
       and    mt.life_in_months = p_asset_fin_rec.life_in_months
       and    mt.method_id = f.method_id
       and    f.revised_rate = l_rate_in_use;

       -- revised rate with nbv_at_switch not entered                        -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start

   -- Fix for Bug #7109596 .  The NBV_AT_SWITCH can be ZERO ( = 0) for Zero value Assets. Hence Commenting the below Piece of Code

   /*    if (l_revised_count > 0) and (p_asset_fin_rec.nbv_at_switch = 0) then
            fa_srvr_msg.add_message(calling_fn => 'fa_addition_pvt.insert_asset',
                                    name       => 'FA_ADD_REVISED_WITHOUT_SWITCH',  p_log_level_rec => p_log_level_rec);
            raise general_error;

       els*/
       ----End of the Comment for the Bug 7109596
       -- original rate with nbv_at_switch entered
       if (l_revised_count = 0) and (p_asset_fin_rec.nbv_at_switch <> 0) then
            fa_srvr_msg.add_message(calling_fn => 'fa_addition_pvt.insert_asset',
                                    name       => 'FA_ADD_SWITCH_NBV_ORIGINAL_RAT',  p_log_level_rec => p_log_level_rec);
            raise general_error;
       end if;                                                              -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy  End

       if (l_revised_count > 0) and               -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
          (p_asset_deprn_rec.deprn_reserve > 0) then

           UPDATE FA_BOOKS
           SET adjusted_cost = p_asset_fin_rec.nbv_at_switch
           WHERE book_type_code = p_asset_hdr_rec.book_type_code
           AND asset_id = p_asset_hdr_rec.asset_id
           AND date_ineffective is null;

           UPDATE FA_DEPRN_SUMMARY
           SET adjusted_cost = p_asset_fin_rec.nbv_at_switch
           WHERE book_type_code = p_asset_hdr_rec.book_type_code
           AND asset_id = p_asset_hdr_rec.asset_id
           AND DEPRN_SOURCE_CODE = 'BOOKS';

            /*fa_srvr_msg.add_message(calling_fn => 'fa_addition_pvt.initialize',
                                    name       => 'FA_ADDITION_REVISED_RATE',  p_log_level_rec => p_log_level_rec);
            raise general_error; */
       end if;                                    -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End

      BEGIN
        SELECT FF.original_rate
             , FF.revised_rate
             , FF.guarantee_rate
        INTO   l_original_Rate
             , l_Revised_Rate
             , l_Guaranteed_Rate
        FROM   FA_FORMULAS FF
             , FA_METHODS FM
        WHERE  FF.METHOD_ID = FM.METHOD_ID
        AND    FM.METHOD_CODE = p_asset_fin_rec.deprn_method_code;
      EXCEPTION
        WHEN OTHERS THEN
             l_original_Rate := 0;
             l_Revised_Rate := 0;
             l_Guaranteed_Rate := 0;
             l_is_revised_rate := 0;
      END;

       /* Bug 7626457 Modified the below IF condition to correcly calculate the state of Asset */
       IF (TRUNC(p_asset_fin_rec.cost * l_Guaranteed_Rate)) >
          (TRUNC((p_asset_fin_rec.original_cost - (p_asset_deprn_rec.deprn_reserve -
                                                   p_asset_deprn_rec.ytd_deprn))* l_original_Rate)) THEN
         l_rate_in_use := l_Revised_Rate;
       END IF;

       UPDATE FA_BOOKS
       SET rate_in_use = l_rate_in_use
       WHERE book_type_code = p_asset_hdr_rec.book_type_code
       AND asset_id = p_asset_hdr_rec.asset_id
       AND date_ineffective is null;
    end if;
    -- Bug:5930979:Japan Tax Reform Project (End)

    if (p_mrc_sob_type_code = 'R') then

       -- insert the books_rates record
       mc_fa_utilities_pkg.insert_books_rates (
          p_set_of_books_id        => p_asset_hdr_rec.set_of_books_id,
          p_asset_id               => p_asset_hdr_rec.asset_id,
          p_book_type_code         => p_asset_hdr_rec.book_type_code,
          p_transaction_header_id  => p_trans_rec.transaction_header_id,
          p_invoice_transaction_id => p_inv_trans_rec.invoice_transaction_id,
          p_exchange_date          => p_trans_rec.transaction_date_entered,
          p_cost                   => p_primary_cost,
          p_exchange_rate          => p_exchange_rate,
          p_avg_exchange_rate      => p_exchange_rate,
          p_last_updated_by        => p_trans_rec.who_info.last_updated_by,
          p_last_update_date       => p_trans_rec.who_info.last_update_date,
          p_last_update_login      => p_trans_rec.who_info.last_update_login,
          p_complete               => 'Y',
          p_trigger                => 'fa_addition_pvt.insert_asset',
          p_currency_code          => to_char(p_asset_hdr_rec.set_of_books_id),
          p_log_level_rec          => p_log_level_rec
       );
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;

  EXCEPTION
    when mrc_check_error then
         fa_srvr_msg.add_message(
             calling_fn => 'fa_addition_pvt.insert_asset',  p_log_level_rec => p_log_level_rec);
         x_return_status := FND_API.G_RET_STS_ERROR;
         return FALSE;

    when general_error then
         fa_srvr_msg.add_message(
             calling_fn => 'fa_addition_pvt.insert_asset',  p_log_level_rec => p_log_level_rec);
         x_return_status := FND_API.G_RET_STS_ERROR;
         return FALSE;

    when others then
         fa_srvr_msg.add_sql_error(
             calling_fn => 'fa_addition_pvt.insert_asset',  p_log_level_rec => p_log_level_rec);
         x_return_status := FND_API.G_RET_STS_ERROR;
         return FALSE;

end insert_asset;

END FA_ADDITION_PVT;

/
