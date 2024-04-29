--------------------------------------------------------
--  DDL for Package Body FA_ASSET_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_VAL_PVT" as
/* $Header: FAVVALB.pls 120.69.12010000.37 2010/06/10 08:03:23 deemitta ship $   */

FUNCTION validate
   (p_trans_rec          IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec      IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec     IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec     IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec      IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec      IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec    IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_dist_tbl     IN     FA_API_TYPES.asset_dist_tbl_type,
    p_inv_tbl            IN     FA_API_TYPES.inv_tbl_type,
    p_calling_fn         IN     VARCHAR2,
    p_log_level_rec      IN     FA_API_TYPES.log_level_rec_type) RETURN boolean IS

   l_distribution_count number;
   val_err              exception;
   l_asset_dist_tbl     FA_API_TYPES.asset_dist_tbl_type;
   -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
   l_japan_tax_reform   varchar2(1) := fnd_profile.value('FA_JAPAN_TAX_REFORMS');
   -- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End

   l_curr_index number;

BEGIN
   if ((p_trans_rec.transaction_type_code = 'ADDITION') OR
       (p_trans_rec.transaction_type_code = 'CIP ADDITION') OR
       (p_trans_rec.transaction_type_code = 'GROUP ADDITION')) then
       if not validate_asset_book (
          p_transaction_type_code => p_trans_rec.transaction_type_code,
          p_book_type_code        => p_asset_hdr_rec.book_type_code,
          p_asset_id              => p_asset_hdr_rec.asset_id,
          p_calling_fn            => p_calling_fn,
          p_log_level_rec         => p_log_level_rec
         ) then
          raise val_err;
       end if;
       if not validate_cost (
          p_transaction_type_code => p_trans_rec.transaction_type_code,
          p_cost                  => p_asset_fin_rec.cost,
          p_asset_type            => p_asset_type_rec.asset_type,
          p_num_invoices          => p_inv_tbl.COUNT,
          p_calling_fn            => p_calling_fn,
          p_log_level_rec         => p_log_level_rec
         ) then
          raise val_err;
       end if;

       -- Bug No#5708875
       -- Addding validation for current units
       if not validate_current_units (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_current_units          => p_asset_desc_rec.current_units,
          p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
       end if;

       -- Bug 7670767. added following condition to prevent addition of an extended asset as amortized

       if (p_trans_rec.transaction_type_code = 'ADDITION' and
           p_asset_fin_rec.deprn_method_code = 'JP-STL-EXTND'and
           l_japan_tax_reform = 'Y' and p_trans_rec.amortization_start_date is not NULL) then
          fa_srvr_msg.add_message(
               calling_fn => p_calling_fn,
               name       => 'FA_JP_EXTD_AMORT_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
          return FALSE;
       end if;

       -- bug 7670767 end

       if not validate_jp250db (
          p_transaction_type_code   => p_trans_rec.transaction_type_code,
          p_book_type_code          => p_asset_hdr_rec.book_type_code,
          p_asset_id                => p_asset_hdr_rec.asset_id,
          p_method_code             => p_asset_fin_rec.deprn_method_code,
          p_life_in_months          => p_asset_fin_rec.life_in_months,
          p_asset_type              => p_asset_type_rec.asset_type,
          p_bonus_rule              => p_asset_fin_rec.bonus_rule,
          p_transaction_key         => p_trans_rec.transaction_key,
          p_cash_generating_unit_id => p_asset_fin_rec.cash_generating_unit_id,
          p_deprn_override_flag     => p_trans_rec.deprn_override_flag,
          p_calling_fn              => p_calling_fn,
          p_log_level_rec           => p_log_level_rec
         ) then
          raise val_err;
       end if;

       if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
          if not validate_asset_number (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_asset_number          => p_asset_desc_rec.asset_number,
             p_asset_id              => p_asset_hdr_rec.asset_id,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
          if not validate_owned_leased (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_owned_leased          => p_asset_desc_rec.owned_leased,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
          if not validate_tag_number (
             p_tag_number            => p_asset_desc_rec.tag_number,
             p_mass_addition_id      => NULL,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
          if not validate_category (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_category_id           => p_asset_cat_rec.category_id,
             p_book_type_code        => p_asset_hdr_rec.book_type_code,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
           ) then
             raise val_err;
          end if;
          if not validate_category_df (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_cat_desc_flex         => p_asset_cat_rec.desc_flex,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
          if not validate_serial_number (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_serial_number         => p_asset_desc_rec.serial_number,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
          if not validate_asset_key (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_asset_key_ccid        => p_asset_desc_rec.asset_key_ccid,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
          if not validate_asset_type (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_asset_type            => p_asset_type_rec.asset_type,
             p_book_type_code        => p_asset_hdr_rec.book_type_code,
             p_category_id           => p_asset_cat_rec.category_id,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
          if not validate_supplier_name (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
          if not validate_supplier_number (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_calling_fn            => p_calling_fn,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
          if not validate_lease (
             p_asset_id              => p_asset_hdr_rec.asset_id,
             p_lease_id              => p_asset_desc_rec.lease_id,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;

          if not validate_warranty (
             p_warranty_id           => p_asset_desc_rec.warranty_id,
             p_date_placed_in_service
                                     => p_asset_fin_rec.date_placed_in_service,
             p_book_type_code        => p_asset_hdr_rec.book_type_code,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;

          if not validate_property_type (
             p_property_type_code    => p_asset_desc_rec.property_type_code,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;

          if not validate_1245_1250_code (
             p_1245_1250_code        => p_asset_desc_rec.property_1245_1250_code,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;

          l_distribution_count := p_asset_dist_tbl.COUNT;
          l_asset_dist_tbl := p_asset_dist_tbl;

          for i in 1..l_distribution_count loop

             if not validate_assigned_to (
                p_transaction_type_code => p_trans_rec.transaction_type_code,
                p_assigned_to           => p_asset_dist_tbl(i).assigned_to,
                p_calling_fn            => p_calling_fn,
                p_log_level_rec         => p_log_level_rec
               ) then
               raise val_err;
             end if;

             if not validate_expense_ccid (
                p_expense_ccid          => p_asset_dist_tbl(i).expense_ccid,
                p_gl_chart_id           => fa_cache_pkg.fazcbc_record.accounting_flex_structure,
                p_calling_fn            => p_calling_fn,
                p_log_level_rec         => p_log_level_rec
               ) then
               raise val_err;
             end if;

             if not validate_location_ccid (
                p_transaction_type_code => p_trans_rec.transaction_type_code,
                p_location_ccid         => p_asset_dist_tbl(i).location_ccid,
                p_calling_fn            => p_calling_fn,
                p_log_level_rec         => p_log_level_rec
               ) then
                raise val_err;
             end if;

             -- bugfix 2846357
             l_curr_index := i;
             if not validate_duplicate_dist (
                    p_transaction_type_code => p_trans_rec.transaction_type_code,
                    p_asset_dist_tbl        => l_asset_dist_tbl,
                    p_curr_index            => l_curr_index,
                    p_log_level_rec         => p_log_level_rec
                   ) then
                raise val_err;
             end if;


             --Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start
             if l_japan_tax_reform = 'Y'  AND p_trans_rec.calling_interface = 'FAMAPT' then

             -- Bug# 7698030 start

               if p_asset_fin_rec.deprn_method_code='JP-STL-EXTND' then

                       -- start validate JP-STL-EXTND
                 if not validate_JP_STL_EXTND(

                    p_prior_deprn_method       => p_asset_fin_rec.prior_deprn_method,
                    p_prior_basic_rate         => p_asset_fin_rec.prior_basic_rate,
                    p_prior_adjusted_rate      => p_asset_fin_rec.prior_adjusted_rate,
                    p_prior_life_in_months     => p_asset_fin_rec.prior_life_in_months,
                    p_calling_fn               => p_calling_fn,
                    p_log_level_rec         => p_log_level_rec
                   ) then

                   raise val_err;

                 end if;
                 -- end validate JP-STL-EXTND
                 /*For Jp-STL-EXTD we also need to
                  * validate Erlier depreciation limit,
                  * Period fully reserved
                  * Early first period extended depreciation
                  */
                 -- start validate_earl_deprn_limit
                 if not validate_earl_deprn_limit(
                      p_prior_deprn_limit_amount => p_asset_fin_rec.prior_deprn_limit_amount,
                      p_prior_deprn_limit        => p_asset_fin_rec.prior_deprn_limit,
                      p_prior_deprn_limit_type   => p_asset_fin_rec.prior_deprn_limit_type,
                      p_calling_fn               => p_calling_fn,
                      p_log_level_rec         => p_log_level_rec
                    ) then

                     raise val_err;

                 end if;
                 -- end validate_earl_deprn_limit

                       -- start validate_period_fully_reserved
                 if not validate_period_fully_reserved(
                       p_book_type_code           => p_asset_hdr_rec.book_type_code,
                       p_pc_fully_reserved        => p_asset_fin_rec.period_counter_fully_reserved,
                       p_date_placed_in_service   => p_asset_fin_rec.date_placed_in_service,
                       p_calling_fn               => p_calling_fn,
                       p_log_level_rec         => p_log_level_rec
                      ) then

                      raise val_err;
                 end if;
                 -- end validate_period_fully_reserved

                       -- Start validate_fst_prd_extd_deprn
                       if not validate_fst_prd_extd_deprn(
                    p_book_type_code           => p_asset_hdr_rec.book_type_code,
                    p_extended_deprn_period    => p_asset_fin_rec.extended_depreciation_period,
                    p_date_placed_in_service   => p_asset_fin_rec.date_placed_in_service,
                    p_calling_fn               => p_calling_fn,
                    p_log_level_rec         => p_log_level_rec
                        ) then

                         raise val_err;

                       end if;
                       --- end validate_fst_prd_extd_deprn
               end if;
               -- End of JP-STL-EXTD method validation
               -- Start of Not JP STL EXTD validation
               if p_asset_fin_rec.deprn_method_code <> 'JP-STL-EXTND' then

                       -- start validate_NOT_JP_STL_EXTND
                       if not validate_NOT_JP_STL_EXTND(
                      p_book_type_code           => p_asset_hdr_rec.book_type_code,
                      p_deprn_limit              => p_asset_fin_rec.allowed_deprn_limit,
                      p_sp_deprn_limit           => p_asset_fin_rec.allowed_deprn_limit_amount,
                      p_deprn_reserve            => p_asset_deprn_rec.deprn_reserve,
                      p_asset_type               => p_asset_type_rec.asset_type,
                      p_pc_fully_reserved        => p_asset_fin_rec.period_counter_fully_reserved,
                      p_date_placed_in_service   => p_asset_fin_rec.date_placed_in_service,
                      p_cost                     => p_asset_fin_rec.cost,
                      p_calling_fn               => p_calling_fn,
                      p_log_level_rec         => p_log_level_rec
                      ) then

                         raise val_err;
                 end if;

                     end if;
               -- Start of Not JP STL EXTD validation

               -- Start Validation for JP 250 DB methods
               if p_asset_fin_rec.deprn_method_code like 'JP%250DB%' then

                 if not validate_JP_250_DB(
                                            p_deprn_method_code        => p_asset_fin_rec.deprn_method_code,
                      p_cost                     => p_asset_fin_rec.cost,
                      p_nbv_at_switch            => p_asset_fin_rec.nbv_at_switch,
                      p_deprn_reserve            => p_asset_deprn_rec.deprn_reserve,
                      p_ytd_deprn                => p_asset_deprn_rec.ytd_deprn,
                      p_calling_fn               => p_calling_fn,
                      p_log_level_rec         => p_log_level_rec
                     ) then


                    raise val_err;
                 end if;

               end if;
               -- End Validation for JP 250 DB methods

             -- Bug# end 7698030
               NULL;
             end if;
             --Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End

          end loop;

       end if; -- corporate

       if (p_asset_fin_rec.group_asset_id is not null and
           p_asset_fin_rec.group_asset_id <> FND_API.G_MISS_NUM and
           nvl(fa_cache_pkg.fazcbc_record.allow_interco_group_flag, 'N') <> 'Y') then
          if not fa_interco_pvt.validate_grp_interco
                   (p_asset_hdr_rec    => p_asset_hdr_rec,
                    p_trans_rec        => p_trans_rec,
                    p_asset_type_rec   => p_asset_type_rec,
                    p_group_asset_id   => p_asset_fin_rec.group_asset_id,
                    p_asset_dist_tbl   => p_asset_dist_tbl,
                    p_calling_fn       => p_calling_fn, p_log_level_rec => p_log_level_rec) then
             raise val_err;
          end if;
       end if;

       /*Bug 8728813 - Member Assets can not have initial reserve - start*/
       if (p_trans_rec.transaction_type_code = 'ADDITION' and
           nvl(p_asset_fin_rec.group_asset_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM and
           nvl(p_asset_deprn_rec.deprn_reserve,0) <> 0 and
           nvl(p_asset_deprn_rec.ytd_deprn,0) <> 0) then
          fa_srvr_msg.add_message(
               calling_fn => p_calling_fn,
               name       => 'FA_NO_RESERVE_ALLOWED_MEM_ADD',
               p_log_level_rec => p_log_level_rec);
          return FALSE;
       end if;
       /*Bug 8728813 - Member Assets can not have initial reserve - end*/

       /*Bug 8828394 - Group Asset ID should be valid Group Asset ID - Begin*/
       if nvl(p_asset_fin_rec.group_asset_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
          if not validate_group_asset_id(
             p_asset_id              => p_asset_fin_rec.group_asset_id,
             p_log_level_rec         => p_log_level_rec
            ) then
             raise val_err;
          end if;
       end if;
       /*Bug 8828394 - Group Asset ID should be valid Group Asset ID - End*/

   end if; -- ADDITION only

   return TRUE;

EXCEPTION
  when val_err then
     fa_srvr_msg.add_message(calling_fn => 'fa_asset_val_pvt.validate',  p_log_level_rec => p_log_level_rec);
     return FALSE;

END;

FUNCTION validate_asset_number
   (p_transaction_type_code  IN    VARCHAR2,
    p_asset_number           IN    VARCHAR2,
    p_asset_id               IN    NUMBER   DEFAULT NULL,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_count              number;
   l_asset_number       number(15) := 0;

BEGIN

   if ((p_transaction_type_code = 'ADDITION') OR
       (p_transaction_type_code = 'CIP ADDITION')) then

      if (p_asset_number is not null) then

         -- Asset number must be unique.
         select count(*)
         into   l_count
         from   fa_additions_b
         where  asset_number = upper(p_asset_number);

         if (l_count > 0) then
            fa_srvr_msg.add_message(
               calling_fn => 'fa_asset_val_pvt.validate_asset_number',
               name       => 'FA_ADD_ASSET_NUMBER_USED',  p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;

         -- Need to check fa_mass_additions also.  Only do this validation
         -- if it is being called from Prepare Mass Additions.  Otherwise,
         -- it fails during Post Mass Additions.
         if (p_calling_fn = 'MASS_ADDITIONS_7.Check_S_Asset_Number') then
            select count(*)
            into   l_count
            from   fa_mass_additions
            where  asset_number = p_asset_number
            and queue_name = 'POST';  -- fix for bug 3433702

            --if (l_count > 1) then
            if (l_count > 0) then -- fix for bug 3433702
               fa_srvr_msg.add_message(
                  calling_fn => 'fa_asset_val_pvt.validate_asset_number',
                  name       => 'FA_ADD_ASSET_NUMBER_USED',  p_log_level_rec => p_log_level_rec);
               return FALSE;
            end if;
         end if;

         if (p_asset_number <> to_char(nvl(p_asset_id, -999))) then

            -- Check that numeric asset numbers are less than those used for
            -- automatic asset numbering.
            select count(*)
            into   l_count
            from   dual
            where  nvl(substr(p_asset_number, 1,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number, 2,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number, 3,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number, 4,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number, 5,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number, 6,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number, 7,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number, 8,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number, 9,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number,10,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number,11,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number,12,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number,13,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number,14,1), '0') between '0' and '9'
            and    nvl(substr(p_asset_number,15,1), '0') between '0' and '9';

            if (l_count > 0) then
               begin
                  l_asset_number := to_number(p_asset_number);
               exception
                  when value_error then
                     null;
                  when others then
                     fa_srvr_msg.add_message(
                        calling_fn => 'fa_asset_val_pvt.validate_asset_number',
                        name       => 'FA_ASSET_NUMBER',
                        token1     => 'ASSET_NUMBER',
                        value1     => p_asset_number,  p_log_level_rec => p_log_level_rec);
                     return FALSE;
               end;

               if not fa_cache_pkg.fazsys(p_log_level_rec => p_log_level_rec) then
                  fa_srvr_msg.add_message (
                     calling_fn => 'fa_asset_val_pvt.validate_asset_number',  p_log_level_rec => p_log_level_rec);
               end if;

               -- Fix for Bug #2585811.  You don't need to validate if they
               -- are using custom asset numbering.
               if ((l_asset_number >=
                    fa_cache_pkg.fazsys_record.initial_asset_id)  and
                   (nvl(fa_cache_pkg.fazsys_record.use_custom_asset_numbers_flag, 'N') <> 'Y')
               ) then
                  fa_srvr_msg.add_message(
                     calling_fn => 'fa_asset_val_pvt.validate_asset_number',
                     name       => 'FA_ADD_AUTOMATIC_NUMBER',  p_log_level_rec => p_log_level_rec);
                  return FALSE;
               end if;
            end if;
         end if;
      else -- Asset Number is NULL
         if not fa_cache_pkg.fazsys(p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_message (
               calling_fn => 'fa_asset_val_pvt.validate_asset_number',  p_log_level_rec => p_log_level_rec);
         end if;

         -- Fix for Bug #2585811.  If they are using custom asset numbering,
         -- they must populate asset number.
         if (nvl(fa_cache_pkg.fazsys_record.use_custom_asset_numbers_flag, 'N')
             = 'Y')
         then
            fa_srvr_msg.add_message(
               calling_fn => 'fa_asset_val_pvt.validate_asset_number',
               name       => 'FA_NULL_CUSTOM_ASSET_NUMBER',  p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      end if;
   end if;

   return TRUE;

END validate_asset_number;

FUNCTION validate_owned_leased
   (p_transaction_type_code  IN    VARCHAR2,
    p_owned_leased           IN    VARCHAR2,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   if (p_owned_leased not in ('OWNED', 'LEASED')) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_owned_leased',
           name       => 'FA_INVALID_PARAMETER',
           token1     => 'OWNED_LEASED',
           value1     => nvl(p_owned_leased, '-999'),
                   p_log_level_rec => p_log_level_rec);

      return FALSE;
   end if;

   return TRUE;

END validate_owned_leased;

FUNCTION validate_category
   (p_transaction_type_code  IN    VARCHAR2,
    p_category_id            IN    NUMBER,
    p_book_type_code         IN    VARCHAR2 DEFAULT NULL,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN
   -- Check that the category exists.
   if not fa_cache_pkg.fazcat (
      X_cat_id  => p_category_id
   , p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_asset_category',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Check that the category is enabled.
   if (fa_cache_pkg.fazcat_record.enabled_flag <> 'Y') then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_asset_category',
           name       => 'FA_INCORRECT_CATEGORY_ID',
           token1     => 'CATEGORY_ID',
           value1     => p_category_id,  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- removed check on capitalize flag as this isn't an asset level thing - bmr
   if (p_book_type_code is not null) then

      -- Make sure that the category/book exists.
      if not (fa_cache_pkg.fazccb (
         X_Book    => p_book_type_code,
         X_Cat_Id  => p_category_id
      , p_log_level_rec => p_log_level_rec)) then

         if (fa_cache_pkg.fazcbc_record.book_class = 'TAX') then
            fa_srvr_msg.add_message(
                calling_fn => 'fa_asset_val_pvt.validate_asset_category',
                name       => 'FA_MCP_CAT_NOT_IN_TAX',  p_log_level_rec => p_log_level_rec);
         else
            fa_srvr_msg.add_message(
                calling_fn => 'fa_asset_val_pvt.validate_asset_category',
                name       => 'FA_BOOK_CAT_NOT_SET_UP',  p_log_level_rec => p_log_level_rec);
         end if;

         return FALSE;
      end if;
   end if;

   return TRUE;
END validate_category;

-- Bug No#5708875
-- Addding validation for current units
--current units cannot be in fractions

FUNCTION validate_current_units
   (p_transaction_type_code  IN    VARCHAR2,
    p_current_units          IN    NUMBER,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS
BEGIN


   if ((p_transaction_type_code = 'ADDITION') OR
       (p_transaction_type_code = 'CIP ADDITION')) then


      --Checking if the current units contain fractional value
      if instr(nvl(p_current_units,0),'.')=0 then
                return TRUE;
        else

            fa_srvr_msg.add_message(
               calling_fn => 'fa_asset_val_pvt.validate_current_units',
               name       => 'FA_NO_FRAC_UNITS',  p_log_level_rec => p_log_level_rec);
            return FALSE;
      end if;
   end if;
return TRUE;
END validate_current_units;


FUNCTION validate_category_df
   (p_transaction_type_code  IN    VARCHAR2,
    p_cat_desc_flex          IN    FA_API_TYPES.desc_flex_rec_type,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN
   -- Check that the flexfield value is valid.

   return TRUE;
END validate_category_df;

FUNCTION validate_serial_number
   (p_transaction_type_code  IN    VARCHAR2,
    p_serial_number          IN    VARCHAR2,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN
   -- CRL check?

   return TRUE;
END validate_serial_number;

FUNCTION validate_asset_key
   (p_transaction_type_code  IN    VARCHAR2,
    p_asset_key_ccid         IN    NUMBER,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_required           number;
   l_is_asset_key_valid number;

   cursor c_asset_key_req is
    select 1
      from fnd_id_flex_segments
     where application_id = 140
       and id_flex_code   = 'KEY#'
       and id_flex_num    = fa_cache_pkg.fazsys_record.asset_key_flex_structure
       and required_flag  = 'Y';

BEGIN
   -- check if the flexfield has any required segments
   if G_asset_key_required is null then
      if not fa_cache_pkg.fazsys(p_log_level_rec) then
         fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_asset_key',   p_log_level_rec => p_log_level_rec);
         return false;
      end if;

      open c_asset_key_req;
      fetch c_asset_key_req into l_required;
      if c_asset_key_req%notfound then
         G_asset_key_required := FALSE;
      else
         G_asset_key_required := TRUE;
      end if;
      close c_asset_key_req;

   end if;


   -- check if the combination is null and required
   if G_asset_key_required and p_asset_key_ccid is null then
      fa_srvr_msg.add_message(
          calling_fn => 'fa_asset_val_pvt.validate_asset_key',
          name       => 'FA_NULL_ASSET_KEY',
          token1     => 'ASSET_KEY',
          value1     => NULL,  p_log_level_rec => p_log_level_rec);
      return false;
   end if;

   -- check if the combination is valid
   if (p_asset_key_ccid is not null) then

      select count(*)
        into l_is_asset_key_valid
        from fa_asset_keywords
       where code_combination_id = p_asset_key_ccid
         and enabled_flag = 'Y';

      if (l_is_asset_key_valid = 0) then
         fa_srvr_msg.add_message(
             calling_fn => 'fa_asset_val_pvt.validate_asset_key',
             name       => 'FA_INCORRECT_ASSET_KEY',
             token1     => 'ASSET_KEY_CCID',
             value1     => p_asset_key_ccid,  p_log_level_rec => p_log_level_rec);
         return false;
     end if;
   end if;

   return TRUE;
END validate_asset_key;

FUNCTION validate_asset_type
   (p_transaction_type_code     IN  VARCHAR2,
    p_asset_type                IN  VARCHAR2,
    p_book_type_code            IN  VARCHAR2,
    p_category_id               IN  NUMBER,
    p_calling_fn                IN  VARCHAR2,
    p_log_level_rec             IN  FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_capitalize_flag        varchar2(3);

BEGIN

   -- Check that it can only be capitalized, cip, or expensed.
   if not ((p_asset_type = 'CAPITALIZED') or
           (p_asset_type = 'CIP') or
           (p_asset_type = 'EXPENSED') or
           (p_asset_type = 'GROUP')) then

      fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_asset_type',
              name       => 'FA_DPR_BAD_ASSET_TYPE',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Check for invalid asset_type/category combinations.
   if ((fa_cache_pkg.fazcat_record.capitalize_flag =  'YES') and
       (p_asset_type = 'EXPENSED')) then

      fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_asset_type',
              name       => 'FA_INCORRECT_ASSET_TYPE',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if ((fa_cache_pkg.fazcat_record.capitalize_flag = 'NO') and
       ((p_asset_type = 'CAPITALIZED') or
        (p_asset_type = 'CIP') or
        (p_asset_type = 'GROUP'))) then

      fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_asset_type',
              name       => 'FA_INCORRECT_ASSET_TYPE',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- If asset is CIP, check the CIP accounts.
   if (p_asset_type = 'CIP') then
      if ((fa_cache_pkg.fazccb_record.cip_clearing_acct is null) OR
          (fa_cache_pkg.fazccb_record.cip_cost_acct is null)) then

         fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_asset_type',
              name       => 'FA_SHARED_NO_CIP_ACCOUNTS',  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   -- do not allow group if not enabled
   if (p_asset_type = 'GROUP' and
       nvl(fa_cache_pkg.fazcbc_record.allow_group_deprn_flag, 'N') <> 'Y') then
      fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_asset_type',
              name       => '***FA_GROUP_NOT_ALLOWED***',
                   p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   return TRUE;

END validate_asset_type;

FUNCTION validate_depreciate_flag
   (p_depreciate_flag           IN VARCHAR2,
    p_calling_fn                IN VARCHAR2,
    p_log_level_rec             IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   if ((p_depreciate_flag <> 'YES' and
        p_depreciate_flag <> 'NO') or
        p_depreciate_flag IS NULL) then
           fa_srvr_msg.add_message(
              calling_fn  => 'fa_asset_val_pvt.val_depreciate_flag',
              name       => 'FA_INCORRECT_DEPRECIATE_FLAG',  p_log_level_rec => p_log_level_rec);
           return FALSE;
   end if;

   return TRUE;

END validate_depreciate_flag;

FUNCTION validate_supplier_name
   (p_transaction_type_code  IN    VARCHAR2,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN
   -- From vendor_name_q lov in asset workbench.

   -- Check any dependencies w/ asset type.

   -- Check any dependencies w/ supplier number.

   return TRUE;
END validate_supplier_name;

FUNCTION validate_supplier_number
   (p_transaction_type_code  IN    VARCHAR2,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN
   -- From vendor_number_q lov in asset workbench.

   -- Check any dependencies w/ asset type.

   -- Check any dependencies w/ supplier name.

   return TRUE;
END validate_supplier_number;

FUNCTION validate_asset_book
   (p_transaction_type_code  IN    VARCHAR2,
    p_book_type_code         IN    VARCHAR2,
    p_asset_id               IN    NUMBER,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_exists     number;

BEGIN
   -- book controls cache should have already been loaded by calling api
   -- so this is obsolete: Validate that book exists.

   -- Validate that book is active.
   if (fa_cache_pkg.fazcbc_record.date_ineffective is not null) then

      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_asset_book',
         name       => 'FA_BOOK_INEFFECTIVE_BOOK',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if ((p_transaction_type_code = 'ADDITION') OR
       (p_transaction_type_code = 'CIP ADDITION') OR
       (p_transaction_type_code = 'GROUP ADDITION')) then

      -- Validate that asset does not already exist in book.
      select count(*)
      into   l_exists
      from   fa_books
      where  book_type_code = p_book_type_code
      and    asset_id = p_asset_id
      and    rownum <= 1;

      if (l_exists > 0) then
         fa_srvr_msg.add_message(
            calling_fn => 'fa_asset_val_pvt.validate_asset_book',
            name       => 'FA_MCP_IN_TAX_BOOK',
            token1     => 'ASSET',
            value1     => to_char (p_asset_id),
            token2     => 'BOOK',
            value2     => p_book_type_code,
                   p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      -- For Addition transactions, asset must exist in the Corporate book.
      if (fa_cache_pkg.fazcbc_record.book_class <> 'CORPORATE') then

         select count(*)
         into   l_exists
         from   fa_books bks
         where  exists
         (
          select 'X'
          from   fa_book_controls bc
          where  bc.book_type_code = p_book_type_code
          and    bc.distribution_source_book = bks.book_type_code
         )
         and    bks.asset_id = p_asset_id;

         if (l_exists = 0) then
            fa_srvr_msg.add_message(
                calling_fn => 'fa_asset_val_pvt.validate_asset_book',
                name       => 'FA_MASSCHG_NOT_IN_CORP',  p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      end if;
   else
      -- for non-addition trxs  verify asset does exist in book
      select count(*)
      into   l_exists
      from   fa_books
      where  book_type_code = p_book_type_code
      and    asset_id = p_asset_id
      and    rownum <= 1;

     if (l_exists = 0) then
        fa_srvr_msg.add_message(
                calling_fn => 'fa_asset_val_pvt.validate_asset_book',
                name       => 'FA_EXP_GET_ASSET_INFO',  p_log_level_rec => p_log_level_rec);
        return false;
     end if;

     if ((p_transaction_type_code = 'TRANSFER' or
          p_transaction_type_code = 'RECLASS' or
          p_transaction_type_code = 'UNIT ADJUSTMENT') and
         fa_cache_pkg.fazcbc_record.book_class <> 'CORPORATE') then
        fa_srvr_msg.add_message(
                calling_fn => 'fa_asset_val_pvt.validate_asset_book',
                name       => '***FA_BOOK_NOT_CORP***',
                   p_log_level_rec => p_log_level_rec);
        return false;
     end if;
   end if;

   return TRUE;
END validate_asset_book;

/*Bug 8601485 - Verify the if transfer date of asset is before DPIS */
FUNCTION validate_asset_transfer_date
   (p_asset_hdr_rec IN  FA_API_TYPES.asset_hdr_rec_type,
    p_trans_rec     IN  FA_API_TYPES.trans_rec_type,
    p_calling_fn    IN  VARCHAR2,
    p_log_level_rec IN  FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS
    x_same_period           NUMBER := 0; -- Added for 9643505
   l_dpis                DATE;

BEGIN

   -- Retrieve the Date placed in service for the asset
   select date_placed_in_service
   into   l_dpis
   from   fa_books
   where  book_type_code = p_asset_hdr_rec.book_type_code
   and    asset_id = p_asset_hdr_rec.asset_id
   and transaction_header_id_out is null;

   BEGIN

      SELECT 1
	INTO x_same_period
        FROM fa_calendar_periods fcp, fa_book_controls fbc
       WHERE fbc.book_type_code = p_asset_hdr_rec.book_type_code
         AND fcp.calendar_type = fbc.deprn_calendar
         AND p_trans_rec.transaction_date_entered BETWEEN
             fcp.start_date AND fcp.end_date
         AND l_dpis BETWEEN
             fcp.start_date AND fcp.end_date;

   EXCEPTION
   WHEN OTHERS THEN
       x_same_period := 0;
   END;

   if (p_trans_rec.transaction_date_entered < l_dpis) AND (x_same_period = 0) then
      return false;
   end if;

   return TRUE;
END validate_asset_transfer_date;

FUNCTION validate_cost
   (p_transaction_type_code  IN    VARCHAR2,
    p_cost                   IN    NUMBER,
    p_asset_type             IN    VARCHAR2,
    p_num_invoices           IN    NUMBER    DEFAULT 0,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN
   -- If asset type is CIP, cost should be zero.
   if ((fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') AND
       (p_asset_type = 'CIP') AND (p_cost <> 0) AND (p_num_invoices = 0)) then
        fa_srvr_msg.add_message(
                calling_fn => 'fa_asset_val_pvt.validate_cost',
                name       => 'FA_BOOK_CIP_COST',  p_log_level_rec => p_log_level_rec);
        return FALSE;
   elsif (p_asset_type = 'GROUP' and
          p_cost <> 0) then
        fa_srvr_msg.add_message(
                calling_fn => 'fa_asset_val_pvt.validate_cost',
                name       => '***FA_BOOK_GROUP_COST***',
                   p_log_level_rec => p_log_level_rec);
        return FALSE;
   end if;



   return TRUE;
END validate_cost;

FUNCTION validate_assigned_to
   (p_transaction_type_code  IN    VARCHAR2,
    p_assigned_to            IN    NUMBER,
    p_date                   IN    DATE DEFAULT sysdate,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

l_rowcount number;

BEGIN

   -- checks to see if employee is valid
   -- checks against p_date, p_date is default to sysdate

   if p_assigned_to is not null then

      select count(*)
      into l_rowcount
      from per_periods_of_service s, per_people_f p
      where p.person_id = s.person_id
      and trunc(p_date) between
          p.effective_start_date and p.effective_end_date
      and nvl(s.actual_termination_date,p_date) >= p_date
      and p.person_id = p_assigned_to;

      if (l_rowcount = 0) then
         -- bugfix 3854700
         fa_srvr_msg.add_message(
                calling_fn => 'fa_asset_val_pvt.validate_assigned_to',
                name       => 'FA_EMP_NOT_VALID' ,  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   return TRUE;

END validate_assigned_to;

FUNCTION validate_location_ccid
   (p_transaction_type_code  IN    VARCHAR2,
    p_location_ccid          IN    NUMBER,
    p_calling_fn             IN    VARCHAR2,
    p_log_level_rec          IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_is_location_valid        number;

BEGIN

   -- The location ccid cannot be null.
   if (p_location_ccid is null) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_location_ccid',
         name       => 'FA_NULL_LOCATION',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Check that location exists.
   select count(*)
   into   l_is_location_valid
   from   fa_locations
   where  location_id = p_location_ccid
   and    enabled_flag = 'Y';

   if (l_is_location_valid = 0) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_location_ccid',
         name       => 'FA_INCORRECT_LOCATION',
         token1     => 'LOCATION_ID',
         value1     => p_location_ccid,  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   return TRUE;

END validate_location_ccid;

--bug 5501090: Added parameter p_asset_type
FUNCTION validate_dpis
   (p_transaction_type_code      IN  VARCHAR2,
    p_book_type_code             IN  VARCHAR2,
    p_date_placed_in_service     IN  DATE,
    p_prorate_convention_code    IN  VARCHAR2 DEFAULT NULL,
    p_old_date_placed_in_service IN  DATE DEFAULT NULL,
    p_asset_id                   IN  NUMBER   DEFAULT NULL,
    p_db_rule_name               IN  VARCHAR2 DEFAULT NULL,   -- ENERGY
    p_rate_source_rule           IN  VARCHAR2 DEFAULT NULL,   -- ENERGY
    p_transaction_subtype        IN  VARCHAR2 DEFAULT 'EXPENSED',
    p_asset_type                 IN  VARCHAR2 DEFAULT NULL  ,
    p_calling_interface          IN  VARCHAR2 DEFAULT NULL,
    p_calling_fn                 IN  VARCHAR2,
    p_log_level_rec              IN  FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS
   --
   -- NOTE: ENERGY ENHANCEMENT
   --  p_db_rule_name and p_rate_source_rule are  added so that prior
   --  period date will not be allowed. p_db_rule_name is depreciable basis
   --  rule name.
   --
   -- NOTE: Bug:3724207
   -- p_old_date_placed_in_service and p_asset_id are populated from
   -- calc_fin_info(FAVCALB.pls) and not when this is called from otherplaces
   --
   -- Following cursor will fetch record if there is a transaction between addition and
   -- new dpis.  However following transaction will be excluded.
   -- ADDITION, ADDITION/VOID, GROUP ADDITION/VOID, GROUP ADDITION, REINSTATEMENT,
   -- TRANSFER IN, TRANSFER IN/VOID, and any retirement which has been reinstated
   --
   CURSOR c_chk_trx_before_dpis is
      SELECT TH.TRANSACTION_HEADER_ID
        FROM FA_TRANSACTION_HEADERS TH
       WHERE TH.ASSET_ID = p_asset_id
         AND TH.BOOK_TYPE_CODE = p_book_type_code
         AND TH.TRANSACTION_TYPE_CODE IN ('ADJUSTMENT', 'GROUP ADJUSTMENT', 'REVALUATION', 'TAX')
         AND NVL(TH.AMORTIZATION_START_DATE, TH.TRANSACTION_DATE_ENTERED)
                < p_date_placed_in_service
      UNION
      SELECT TH.TRANSACTION_HEADER_ID
        FROM FA_TRANSACTION_HEADERS TH,
             FA_RETIREMENTS RET
       WHERE  TH.ASSET_ID = p_asset_id
         AND TH.BOOK_TYPE_CODE = p_book_type_code
         AND TH.TRANSACTION_TYPE_CODE IN
             ('FULL RETIREMENT', 'PARTIAL RETIREMENT')
         AND NVL(TH.AMORTIZATION_START_DATE, TH.TRANSACTION_DATE_ENTERED)
             < p_date_placed_in_service
         AND RET.ASSET_ID = TH.ASSET_ID
         AND RET.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE
         AND RET.TRANSACTION_HEADER_ID_IN = TH.TRANSACTION_HEADER_ID
         AND RET.TRANSACTION_HEADER_ID_OUT IS NULL;

   l_dpis_jdate     number;
   l_dpis_fy        number;
   l_dpis_per_num   number;
   l_start_jdate    number;

   l_earliest_dpis  date;
   l_count          number;
   l_period_rec     FA_API_TYPES.period_rec_type;

   l_prorate_date          date;
   l_check_prorate_date    varchar2(1);
   l_temp_num       number;

BEGIN

   if (nvl(fa_cache_pkg.fazcbc_record.book_type_code, '-NULL') <>
       p_book_type_code) then
      if (NOT fa_cache_pkg.fazcbc (
         X_book => p_book_type_code
      )) then
         fa_srvr_msg.add_message(
            calling_fn => 'fa_asset_val_pvt.validate_dpis',
            name       => 'FA_POST_INVALID_BOOK');
         return FALSE;
      end if;
   end if;

   -- Validate that dpis passes the LOW_RANGE criteria (fa_date.validate)
   if (p_date_placed_in_service < to_date('1000/01/01', 'YYYY/MM/DD')) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_dpis',
         name       => 'FA_YEAR_GREATER_THAN',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Check that dpis is not too old.
   if not fa_cache_pkg.fazsys(p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message(calling_fn => 'fa_asset_val_pvt.validate_dpis',  p_log_level_rec => p_log_level_rec);
      return false;
   else
      l_earliest_dpis := fa_cache_pkg.fazsys_record.date_placed_in_service;
   end if;

   if (p_date_placed_in_service < l_earliest_dpis) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_dpis',
         name       => 'FA_BOOK_DPIS_TOO_OLD',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Not prior period transaction allowed for asset with
   -- Energy UOP
   if (p_db_rule_name = 'ENERGY PERIOD END BALANCE' and
       p_rate_source_rule = 'PRODUCTION') then

      if not FA_UTIL_PVT.get_period_rec
          (p_book           => p_book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then

          fa_srvr_msg.add_message(calling_fn => 'fa_asset_val_pvt.validate_dpis',  p_log_level_rec => p_log_level_rec);
          return false;
      end if;

      if (p_date_placed_in_service <> nvl(p_old_date_placed_in_service, p_date_placed_in_service) ) and
         (p_date_placed_in_service < l_period_rec.calendar_period_open_date) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('fa_asset_val_pvt.validate_dpis', 'Error', p_date_placed_in_service,  p_log_level_rec => p_log_level_rec);
         end if;

         fa_srvr_msg.add_message(
             calling_fn => 'fa_asset_val_pvt.validate_dpis',
             name       => 'FA_CURRENT_DATE_ONLY',  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

   end if; -- (p_db_rule_name = 'ENERGY PERIOD END BALANCE' and

   /* BUG# 875160 and 2144557 and 4146025
    *   we allow future adds in  masscp, and cip-in-tax
    *   lifting this restriction from the apis.  will need to
    *   place this in form, etc if we wish to keep it there.  --bmr
    */

   -- Fix for Bug #2621438.  Only validate this from FAXASSET
   if ((p_calling_fn in ('faxasset.fa_books_val2.dpis_val',
                        'faxasset.fa_addition_books.date_placed_in_service')
   or (p_calling_interface = 'FAMAPT') )
   ) then

      -- Check that dpis is not in a future period.
      if not FA_UTIL_PVT.get_period_rec
             (p_book           => p_book_type_code,
              p_effective_date => NULL,
              x_period_rec     => l_period_rec
             , p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => 'fa_asset_val_pvt.validate_dpis',  p_log_level_rec => p_log_level_rec);
          return false;
      end if;

      if (p_date_placed_in_service > l_period_rec.calendar_period_close_date) then
          fa_srvr_msg.add_message(
             calling_fn => 'fa_asset_val_pvt.validate_dpis',
             name       => 'FA_BOOK_FUTURE_PERIOD_DPIS',  p_log_level_rec => p_log_level_rec);
          return FALSE;
      end if;


      -- Check that prorate calendars and conventions are setup for this dpis.
      -- Will only be called from faxasset since it can be a performance
      -- issue in mass processes and is kind of redundant with validations
      -- that occur in the calculation engine.
      if (p_prorate_convention_code is not null) then

         begin
            select prorate_date
            into   l_prorate_date
            from   fa_conventions
            where  prorate_convention_code = p_prorate_convention_code
            and    p_date_placed_in_service between start_date and end_date;

         exception
            when others then
               fa_srvr_msg.add_message(
                  calling_fn => 'fa_asset_val_pvt.validate_dpis',
                  name       => 'FA_BOOK_CANT_GEN_PRORATE_DATE',  p_log_level_rec => p_log_level_rec);
               return FALSE;
         end;

         -- Check that prorate date is defined for given dpis.
         begin
            select 'x'
            into   l_check_prorate_date
            from   fa_calendar_periods cp,
                   fa_book_controls bc
            where  bc.book_type_code = p_book_type_code
            and    bc.prorate_calendar = cp.calendar_type
            and    l_prorate_date between cp.start_date and cp.end_date;

         exception
            when others then
               fa_srvr_msg.add_message(
                  calling_fn => 'fa_asset_val_pvt.validate_dpis',
                  name       => 'FA_BKS_INVALID_PRORATE_DATE',  p_log_level_rec => p_log_level_rec);
               return FALSE;
         end;

      end if;
   end if;

   -- Check to see if calendar periods are setup
   l_dpis_jdate := to_number(to_char(p_date_placed_in_service,'J'));

   if (not fa_cache_pkg.fazccp (
      X_target_calendar => fa_cache_pkg.fazcbc_record.deprn_calendar,
      X_target_fy_name  => fa_cache_pkg.fazcbc_record.fiscal_year_name,
      X_target_jdate    => l_dpis_jdate,
      X_period_num      => l_dpis_per_num,
      X_fiscal_year     => l_dpis_fy,
      X_start_jdate     => l_start_jdate
   , p_log_level_rec => p_log_level_rec)) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_dpis',
         name       => 'FA_PROD_INCORRECT_DATE',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Bug:3724207
   -- We should not allow dpis change when there is a transaction between addition and
   -- new dpis.  However following transaction will be excluded.
   -- ADDITION, ADDITION/VOID, GROUP ADDITION/VOID, GROUP ADDITION, REINSTATEMENT,
   -- TRANSFER IN, TRANSFER IN/VOID, and any retirement which has been reinstated
   -- Bug 4246638: Add dist-related transactions to exclusion list
   --
   if p_transaction_subtype <> 'EXPENSED' and (p_date_placed_in_service <>
       nvl(p_old_date_placed_in_service, p_date_placed_in_service)) then
      OPEN c_chk_trx_before_dpis;
      FETCH c_chk_trx_before_dpis INTO l_temp_num;

      if (c_chk_trx_before_dpis%FOUND) then
         CLOSE c_chk_trx_before_dpis;

         -- Use message FA_AMORT_DATE_INVALID until new message
         -- FA_INVALID_DPIS is available
         fa_srvr_msg.add_message(
            calling_fn => 'fa_asset_val_pvt.validate_dpis',
--            name       => 'FA_INVALID_DPIS',  p_log_level_rec => p_log_level_rec);
            name       => 'FA_AMORT_DATE_INVALID',
                   p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      CLOSE c_chk_trx_before_dpis;

   end if; -- (p_date_placed_in_service <>

   return TRUE;

END validate_dpis;

FUNCTION validate_rec_cost_reserve
   (p_transaction_type_code IN VARCHAR2,
    p_recoverable_cost      IN NUMBER,
    p_deprn_reserve         IN NUMBER,
    p_calling_fn            IN VARCHAR2,
    p_log_level_rec         IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   if (p_deprn_reserve <> 0 and
       (abs(p_recoverable_cost) < abs(p_deprn_reserve) or
        (sign(p_recoverable_cost) <> 0 and
         sign(p_recoverable_cost) = -sign(p_deprn_reserve)))) then
      fa_srvr_msg.add_message(
         calling_fn => 'validate_rec_cost_reserve',
         name       => 'FA_BOOK_INVALID_RESERVE', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   return TRUE;

END validate_rec_cost_reserve;

FUNCTION validate_adj_rec_cost
   (p_adjusted_recoverable_cost IN NUMBER,
    p_deprn_reserve             IN NUMBER,
    p_calling_fn                IN VARCHAR2,
    p_log_level_rec             IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   /* Added if condition for bug 863321 */
   IF ( fa_cache_pkg.fazccmt_record.rate_source_rule <> 'PRODUCTION'
            or nvl(fa_cache_pkg.fazcdrd_record.rule_name,'ZZ') <> 'ENERGY PERIOD END BALANCE') THEN
   if (abs(p_adjusted_recoverable_cost) < abs(p_deprn_reserve) or
       (sign(p_adjusted_recoverable_cost) <> 0 and
        sign(p_adjusted_recoverable_cost) = -sign(p_deprn_reserve))) then
      fa_srvr_msg.add_message(
          calling_fn  => 'fa_asset_val_pvt.val_adj_rec_cost',
          name       => 'FA_BOOK_INVALID_RESERVE',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   END IF;
   return TRUE;

END validate_adj_rec_cost;

FUNCTION validate_ytd_reserve /*Bug#9682863 - Modified the parameters/body - using recs now instead of individual parameter. */
   (p_asset_hdr_rec             IN  FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec            IN  FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_new         IN  FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_new       IN  FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec                IN  FA_API_TYPES.period_rec_type,
    p_asset_deprn_rec_old       IN  FA_API_TYPES.asset_deprn_rec_type,    /*Fix for bug 8790562 */
    p_calling_fn                IN  VARCHAR2,
    p_log_level_rec             IN  FA_API_TYPES.log_level_rec_type) return boolean IS

   l_current_fiscal_year  FA_BOOK_CONTROLS.current_fiscal_year%TYPE;
   l_fiscal_year_name     FA_BOOK_CONTROLS.fiscal_year_name%TYPE;

   l_same_fiscal_year     NUMBER;
   l_abs_deprn_reserve    NUMBER;
   l_abs_ytd_deprn        NUMBER;

BEGIN

   -- no need to load book controls cache as it's loaded
   l_current_fiscal_year := fa_cache_pkg.fazcbc_record.current_fiscal_year;
   l_fiscal_year_name    := fa_cache_pkg.fazcbc_record.fiscal_year_name;

   -- Get absolute values.
   l_abs_deprn_reserve := abs (nvl(p_asset_deprn_rec_new.deprn_reserve, 0));
   l_abs_ytd_deprn     := abs (nvl(p_asset_deprn_rec_new.ytd_deprn, 0));

   -- no reserve for non capitalized assets
   if ((p_asset_type_rec.asset_type <> 'CAPITALIZED') and
       (nvl(p_asset_deprn_rec_new.deprn_reserve, 0)             <> 0 or
        nvl(p_asset_deprn_rec_new.ytd_deprn, 0)                 <> 0 or
        nvl(p_asset_deprn_rec_new.bonus_ytd_deprn, 0)           <> 0 or
        nvl(p_asset_deprn_rec_new.bonus_deprn_reserve, 0)       <> 0 or
        nvl(p_asset_deprn_rec_new.ytd_impairment, 0)            <> 0 or
        nvl(p_asset_deprn_rec_new.impairment_reserve, 0)        <> 0 or
        nvl(p_asset_deprn_rec_new.reval_deprn_reserve, 0)       <> 0 or
        nvl(p_asset_deprn_rec_new.reval_ytd_deprn, 0)           <> 0 or
        nvl(p_asset_fin_rec_new.reval_amortization_basis, 0)    <> 0 or
        nvl(p_asset_fin_rec_new.fully_rsvd_revals_counter, 0)   <> 0)) then
      fa_srvr_msg.add_message(
          calling_fn => 'fa_asset_val_pvt.validate_ytd_reserve',
          name       => 'FA_BOOK_INVALID_RESERVE',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;


   -- ytd, ltd deprn validations from fa_books_trx3.when_validate_record
   -- in FAXASSET.

   -- Bug 7229863: Validation for preventing ytd/reserve change
   -- if the asset is not backdated
   /* Fix for Bug #2429665.  Should not have this validation.*/
   -- verify no reserve for asset in first period of life
   if (p_asset_fin_rec_new.prorate_date >= p_period_rec.calendar_period_open_date and
       (p_asset_deprn_rec_new.deprn_reserve <> 0 or
        p_asset_deprn_rec_new.ytd_deprn <> 0)) then
      fa_srvr_msg.add_message(
          calling_fn => 'fa_asset_val_pvt.validate_ytd_reserve',
          name       => 'FA_NO_RSV_IN_FIRST_PERIOD',  p_log_level_rec => p_log_level_rec);
      return false;
   end if;
   /*Fix for bug 8790562 - Not allowing reserve to be Zero*/
   if (p_asset_fin_rec_new.prorate_date >= p_period_rec.calendar_period_open_date and
         (p_asset_deprn_rec_old.ytd_deprn <> 0 and p_asset_deprn_rec_old.deprn_reserve <> 0) and
         (p_asset_deprn_rec_new.deprn_reserve = 0 or p_asset_deprn_rec_new.ytd_deprn = 0)) then
      fa_srvr_msg.add_message(
          calling_fn => 'fa_asset_val_pvt.validate_ytd_reserve',
          name       => 'FA_NO_RSV_IN_FIRST_PERIOD',  p_log_level_rec => p_log_level_rec);
      return false;
   end if;

   -- in first year of life ytd must equal reserve
   if (p_asset_fin_rec_new.prorate_date >= p_period_rec.fy_start_date and
       p_asset_fin_rec_new.prorate_date <= p_period_rec.fy_end_date) then
      if (p_asset_deprn_rec_new.ytd_deprn <> p_asset_deprn_rec_new.deprn_reserve) then
         fa_srvr_msg.add_message(
             calling_fn => 'fa_asset_val_pvt.validate_ytd_reserve',
             name       => 'FA_BOOK_RSV_EQL_YTD',  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   else
      -- BUG# 2341201
      -- need to consider the signs as well since due to historical
      -- data it is posible to have a negative ytd larger than the
      -- positive reserve  - BMR

      if (((sign(p_asset_deprn_rec_new.ytd_deprn) = sign(p_asset_deprn_rec_new.deprn_reserve)) or
           (sign(p_asset_deprn_rec_new.ytd_deprn) = 0) or
           (sign(p_asset_deprn_rec_new.deprn_reserve) = 0)) and
          (l_abs_ytd_deprn > l_abs_deprn_reserve)) then
         fa_srvr_msg.add_message(
            calling_fn => 'fa_asset_val_pvt.validate_ytd_reserve',
            name       => 'FA_BOOK_YTD_EXCEED_RSV',  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   return TRUE;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(
             calling_fn => 'fa_asset_val_pvt.validate_ytd_reserve',  p_log_level_rec => p_log_level_rec);
      return false;

END validate_ytd_reserve;

FUNCTION validate_short_tax_year
   (p_book_type_code            IN     VARCHAR2,
    p_transaction_type_code     IN     VARCHAR2,
    p_asset_type                IN     VARCHAR2,
    p_short_fiscal_year_flag    IN     VARCHAR2,
    p_conversion_date           IN     DATE,
    px_orig_deprn_start_date    IN OUT NOCOPY DATE,
    p_date_placed_in_service    IN     DATE,
    p_ytd_deprn                 IN     NUMBER,
    p_deprn_reserve             IN     NUMBER,
    p_period_rec                IN     FA_API_TYPES.period_rec_type,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_abs_ytd_deprn            number;
   l_abs_deprn_reserve        number;

BEGIN

   -- The short_fiscal_year_flag should be YES or NO.
   if not ((p_short_fiscal_year_flag = 'YES') OR
           (p_short_fiscal_year_flag = 'NO')) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_short_tax_year',
         name       => 'FA_INCORRECT_SHORT_FY_FLAG',
         token1     => 'SHORT_FY_FLAG',
         value1     => p_short_fiscal_year_flag,  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- The short_fiscal_year_flag cannot be YES is the asset is not CAPITALIZED.
   if ((p_asset_type <> 'CAPITALIZED') AND
       (p_short_fiscal_year_flag = 'YES')) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_short_tax_year',
         name       => 'FA_CANT_SET_SHORT_FY_FLAG',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- The conversion date cannot be null if the short_fiscal_year_flag is YES.
   if ((p_short_fiscal_year_flag = 'YES') AND
       (p_conversion_date is NULL)) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_short_tax_year',
         name       => 'FA_MUST_SET_CONV_DATE',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- May default orig_deprn_start_date if short_fiscal_year_flag is YES.
   if ((p_short_fiscal_year_flag = 'YES') AND
       (px_orig_deprn_start_date is NULL)) then
      px_orig_deprn_start_date := p_date_placed_in_service;
   end if;

   -- For creating new asset (non-add_to_asset) transactions, conversion
   -- date cannot have a value if short_fiscal_year_flag is not YES.
   if (((p_transaction_type_code <> 'ADDITION') OR
        (p_transaction_type_code <> 'CIP ADDITION')) AND
       (p_short_fiscal_year_flag <> 'YES') AND
       (p_conversion_date is not NULL)) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_short_tax_year',
         name       => 'FA_CONV_DATE_NO_VAL',
         token1     => 'CONV_DATE',
         value1     => p_conversion_date,  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- For creating new asset (non-add_to_asset) transactions, orig deprn start
   -- date cannot have a value if short_fiscal_year_flag is not YES.
   if (((p_transaction_type_code <> 'ADDITION') OR
        (p_transaction_type_code <> 'CIP ADDITION')) AND
       (p_short_fiscal_year_flag <> 'YES') AND
       (px_orig_deprn_start_date is not NULL)) then
      fa_srvr_msg.add_message(
         calling_fn => 'fa_asset_val_pvt.validate_short_tax_year',
         name       => 'FA_CONV_DATE_NO_VAL',
         token1     => 'CONV_DATE',
         value1     => px_orig_deprn_start_date,  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Conversion date must fall in the current open period which also means
   -- reserve up until conversion must be provided.
   if (p_conversion_date is not null) then
      if (p_conversion_date < p_period_rec.calendar_period_open_date or
          p_conversion_date > p_period_rec.calendar_period_close_date) then
         fa_srvr_msg.add_message(
            calling_fn => 'fa_asset_val_pvt.validate_short_tax_year',
            name       => 'FA_INCORRECT_CONV_DATE',
            token1     => 'CONV_DATE',
            value1     => p_conversion_date,  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      -- Validate conversion_date <> current fiscal year end date.
      if (p_conversion_date = p_period_rec.fy_end_date) then
         fa_srvr_msg.add_message(
            calling_fn => 'fa_asset_val_pvt.validate_short_tax_year',
            name       => 'FA_CONV_DATE_EQU_CURR_FYEND',  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   return TRUE;

END validate_short_tax_year;

FUNCTION validate_trx_date_entered
   (p_transaction_type_code     IN    VARCHAR2,
    p_book_type_code            IN    VARCHAR2,
    p_transaction_date_entered  IN    DATE,
    p_period_rec                IN    FA_API_TYPES.period_rec_type,
    p_calling_fn                IN    VARCHAR2,
    p_log_level_rec             IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

begin

   if (p_transaction_date_entered > p_period_rec.calendar_period_close_date) then
       fa_srvr_msg.add_message(calling_fn      => 'fa_asset_val_pvt.validate_trx_date_entered',
                               name            => 'FA_SHARED_CANNOT_FUTURE',
                               p_log_level_rec => p_log_level_rec);
       return FALSE;
   end if;

   return TRUE;

end validate_trx_date_entered;

FUNCTION validate_amort_start_date
   (p_transaction_type_code     IN     VARCHAR2,
    p_asset_id                  IN     NUMBER,
    p_book_type_code            IN     VARCHAR2,
    p_date_placed_in_service    IN     DATE      DEFAULT NULL,
    p_conversion_date           IN     DATE      DEFAULT NULL,
    p_period_rec                IN     FA_API_TYPES.period_rec_type,
    p_amortization_start_date   IN     DATE,
    p_db_rule_name              IN     VARCHAR2 DEFAULT NULL,  -- ENERGY
    p_rate_source_rule          IN     VARCHAR2 DEFAULT NULL,  -- ENERGY
    p_transaction_key           IN     VARCHAR2 DEFAULT 'XX',
    x_amortization_start_date      OUT NOCOPY DATE,
    x_trxs_exist                   OUT NOCOPY VARCHAR2,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_transaction_date          date;
   l_period_close_date         date;
   l_period_open_date          date;
   l_prior_transaction_date    date;
   l_prior_date_effective      date;
   l_amort_date                date;
   l_avail_date                date;
   l_count                     number;
   l_dpis_jdate                number;
   l_amort_jdate               number;
   l_dpis_fy                   number;
   l_amort_fy                  number;
   l_dpis_per_num              number;
   l_amort_per_num             number;
   l_fy_name                   varchar2(45);
   l_cal_type                  varchar2(15);
   l_start_jdate               number;
   l_period_rec                FA_API_TYPES.period_rec_type;
   l_calling_fn                varchar2(40) := 'fa_asset_val_pvt.val_amort_date';
   error_found                 exception;

begin

   x_amortization_start_date := p_amortization_start_date;

   if (p_amortization_start_date is not null) then

      -- sets to Y if any txn exist between current period
      -- and amortization period
      x_trxs_exist              := 'N';

      -- x_amortization_start_date cannot be future period
      l_transaction_date  := greatest(p_period_rec.calendar_period_open_date,
                                      least(sysdate,
                                            p_period_rec.calendar_period_close_date));
      l_period_close_date := p_period_rec.calendar_period_close_date;
      l_period_open_date  := p_period_rec.calendar_period_open_date;

      if (x_amortization_start_date > l_period_close_date) then
         fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                 name            => 'FA_SHARED_CANNOT_FUTURE',
                                 p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      -- x_amortization_start_date cannot be less than DPIS
      if (p_amortization_start_date < p_date_placed_in_service) then
         x_amortization_start_date := p_date_placed_in_service;
         x_trxs_exist := 'Y';
      end if;

      -- get book controls info from cache
      -- assumes cache has been called
      l_fy_name  := fa_cache_pkg.fazcbc_record.fiscal_year_name;
      l_cal_type := fa_cache_pkg.fazcbc_record.deprn_calendar;

      -- checks if amort start date is valid
      l_amort_jdate := to_number(to_char(x_amortization_start_date,'J'));
      if (not fa_cache_pkg.fazccp
                    (l_cal_type,
                     l_fy_name,
                     l_amort_jdate,
                     l_amort_per_num,
                     l_amort_fy,
                     l_start_jdate, p_log_level_rec => p_log_level_rec)) then
         fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_PROD_INCORRECT_DATE', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      /****
       ** Bug3218011
       ** output parameter x_trxs_exist is not used so comment out follwoing
       ** 2 sql
       **
      -- removed section comparing fys as it was commented out
      -- check if amort start date is eariler than
      -- previous txn date, set txns_exist
      select MAX(transaction_date_entered),
             MAX(date_effective)
      into   l_prior_transaction_date,
             l_prior_date_effective
      from   fa_transaction_headers
      where  asset_id       = p_asset_id
      and    book_type_code = p_book_type_code;

      if (x_amortization_start_date < l_prior_transaction_date) then
         x_trxs_exist := 'Y';
      end if;

      select count(*)
        into l_count
        from fa_deprn_periods pdp,
             fa_deprn_periods adp
       where pdp.book_type_code = p_book_type_code
         and pdp.book_type_code = adp.book_type_code
         and pdp.period_counter > adp.period_counter
         and l_prior_date_effective between pdp.period_open_date
         and nvl(pdp.period_close_date, to_date('31-12-4712','DD-MM-YYYY'))
         and x_amortization_start_date between
              adp.calendar_period_open_date and adp.calendar_period_close_date;

      if (l_count > 0) then
         x_trxs_exist := 'Y';
      end if;

      **
      ** End of Bug3218011
      ****/

      -- Not prior period transaction allowed for asset with
      -- Energy UOP
      if (p_db_rule_name = 'ENERGY PERIOD END BALANCE' and
          p_rate_source_rule = 'PRODUCTION' and
          p_transaction_key <> 'MS') then

         if (p_amortization_start_date < p_period_rec.calendar_period_open_date) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Error', p_date_placed_in_service, p_log_level_rec => p_log_level_rec);
            end if;
            fa_srvr_msg.add_message(
                calling_fn => 'fa_asset_val_pvt.validate_dpis',
                name       => 'FA_CURRENT_DATE_ONLY',  p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;

      end if; -- (p_db_rule_name = 'ENERGY PERIOD END BALANCE' and

      -- check to see if any retire/reinstate/reval txn is in between
      -- x_new_amort_start_date and current_period.
      -- this check covers for the prior period retire/reinste/reval
      -- set x_new_amort_start_date := latest txn date

      -- bug 3188779
      -- do not redefault at this point, but error and force
      -- user to pick a new date. also no need to prevent
      -- overlaps to a retirement either except in the case of
      -- group reclass which is done seperately in FAVCALB.pls.
      --
      -- changing logic to compare max(trx_date) to the amort date here too.

      select MAX(transaction_date_entered) -- date_effective
        into l_prior_transaction_date      -- l_prior_date_effective
        from fa_transaction_headers
       where asset_id       = p_asset_id
         and book_type_code = p_book_type_code
         and transaction_type_code in
               ('REVALUATION');
               --('PARTIAL RETIREMENT','REINSTATEMENT','REVALUATION');


      if (x_amortization_start_date < l_prior_transaction_date) then
         fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_SHARED_OTHER_TRX_FOLLOW', p_log_level_rec => p_log_level_rec);
         raise error_found;
      end if;

      /*
      if (l_prior_date_effective is not null) then

         -- get the latest available date
         -- use get_period rec and period cache

         if not FA_UTIL_PVT.get_period_rec
                 (p_book           => p_book_type_code,
                  p_effective_date => l_prior_date_effective,
                  x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then
            raise error_found;
         end if;

         l_amort_date := greatest(l_period_rec.calendar_period_open_date,
                                  least(SYSDATE,
                                        l_period_rec.calendar_period_close_date));

         if (x_amortization_start_date < l_amort_date) then
             x_amortization_start_date := l_amort_date;
         end if;
      end if;
      */

      -- NOTE: code for validating amort date to conversion date has been removed

   end if;  -- amort date not null

   return TRUE;

exception
   when error_found then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

end validate_amort_start_date;



FUNCTION validate_life
   (p_deprn_method              IN     VARCHAR2,
    p_rate_source_rule          IN     VARCHAR2,
    p_life_in_months            IN     NUMBER,
    p_lim                       IN     NUMBER,
    p_user_id                   IN     NUMBER,
    p_curr_date                 IN     DATE,
    px_new_life                 IN OUT NOCOPY NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_method_id             number;
   l_rowid                 rowid;

   l_method_id_old         number;
   l_method_name           fa_methods.name%type;
   l_deprn_basis_rule      varchar2(4);
   l_stl_method_flag       varchar2(3);
   l_dep_last_year_flag    varchar2(3);
   l_exclude_sal_flag      varchar2(3);
   l_polish_adj_calc_basis_flag varchar2(1);
   l_guarantee_rate_method_flag varchar2(3);
   l_original_rate         number;
   l_revised_rate          number;
   l_guarantee_rate        number;

   l_formula_actual        varchar2(4000);
   l_formula_displayed     varchar2(4000);
   l_formula_parsed        varchar2(4000);

   -- note due to formula changes, we are joining
   -- to the life of the category.  Since we would not
   -- be entering this function is the method and life
   -- existed, the current method in cache will be that
   -- of the category.  Thus we'll use that life in order
   -- to determine the correct formula to pull for new method.

   CURSOR METHOD_DEF (p_deprn_method   varchar2,
                      p_life_in_months number) IS
   SELECT DISTINCT
           method_id,
           name,
           deprn_basis_rule,
           depreciate_lastyear_flag,
           stl_method_flag,
           exclude_salvage_value_flag,
           polish_adj_calc_basis_flag,
           guarantee_rate_method_flag
     FROM FA_METHODS
    WHERE METHOD_CODE    = p_deprn_method
      AND LIFE_IN_MONTHS = p_life_in_months;

   CURSOR C_FORMULA (p_method_id number) IS
   SELECT formula_actual,
          formula_displayed,
          formula_parsed,
          original_rate,
          revised_rate,
          guarantee_rate
     FROM FA_FORMULAS
    WHERE method_id = p_method_id;

   l_calling_fn  varchar2(35) := 'fa_asset_val_pvt.validate_life';
   error_found   exception;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'calling', 'fazccmt', p_log_level_rec => p_log_level_rec);
   end if;

   if not fa_cache_pkg.fazccmt
          (X_method                => p_deprn_method,
           X_life                  => p_lim, p_log_level_rec => p_log_level_rec) then  -- method not found

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'after fazccmt', 'method not found', p_log_level_rec => p_log_level_rec);
      end if;

      if (p_rate_source_rule = 'TABLE') then

         if (p_life_in_months <> 0) then
            px_new_life := p_life_in_months;
         else
            fa_srvr_msg.add_message(
                 CALLING_FN => 'fa_asset_val_pvt.validate_life',
                 NAME => 'FA_LIM_TDM_NOTDEF',  p_log_level_rec => p_log_level_rec);
            raise error_found;
         end if;

      else -- not table

         select FA_METHODS_S.NEXTVAL
         into l_method_id
         from sys.dual;

         -- need to derive more values to distinguish between
         -- STL and Formula methods.  Can't use cache as life
         -- is unknown so like the function in calc engine,
         -- we'll use cursor here,  other option would be to
         -- pass the values as parameter into this function
         -- creating dependancies...

         OPEN METHOD_DEF(p_deprn_method   => p_deprn_method,
                         p_life_in_months => fa_cache_pkg.fazccbd_record.life_in_months);
         FETCH METHOD_DEF
          INTO l_method_id_old,
               l_method_name,
               l_deprn_basis_rule,
               l_dep_last_year_flag,
               l_stl_method_flag,
               l_exclude_sal_flag,
               l_polish_adj_calc_basis_flag,
               l_guarantee_rate_method_flag;

         if (METHOD_DEF%NOTFOUND) then
            CLOSE METHOD_DEF;
            fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_SHARED_OBJECT_NOT_DEF',
                TOKEN1     => 'OBJECT',
                VALUE1     => 'Method', p_log_level_rec => p_log_level_rec);
            raise error_found;
         else
            CLOSE METHOD_DEF;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'inserting', 'new method', p_log_level_rec => p_log_level_rec);
         end if;

         FA_METHODS_PKG.Insert_Row(
             X_Rowid                    => l_rowid,
             X_Method_Id                => l_method_id,
             X_Method_Code              => p_deprn_method,
             X_Life_In_Months           => p_lim,
             X_Depreciate_Lastyear_Flag => l_dep_last_year_flag, -- 'YES',
             X_STL_Method_Flag          => l_stl_method_flag,    -- 'YES'
             X_Rate_Source_Rule         => p_rate_source_rule,   -- 'CALCULATED',
             X_Deprn_Basis_Rule         => l_deprn_basis_rule,   -- 'COST',
             X_Prorate_Periods_Per_Year => NULL,
             X_Name                     => l_method_name,
             X_Last_Update_Date         => p_curr_date,
             X_Last_Updated_By          => p_user_id,
             X_Created_By               => p_user_id,
             X_Creation_Date            => p_curr_date,
             X_Last_Update_Login        => -1,
             X_Attribute1               => null,
             X_Attribute2               => null,
             X_Attribute3               => null,
             X_Attribute4               => null,
             X_Attribute5               => null,
             X_Attribute6               => null,
             X_Attribute7               => null,
             X_Attribute8               => null,
             X_Attribute9               => null,
             X_Attribute10              => null,
             X_Attribute11              => null,
             X_Attribute12              => null,
             X_Attribute13              => null,
             X_Attribute14              => null,
             X_Attribute15              => null,
             X_Attribute_Category_Code  => null,
             X_Exclude_Salvage_Value_Flag => l_exclude_sal_flag,
             X_Polish_Adj_Calc_Basis_Flag => l_polish_adj_calc_basis_flag,
             X_Guarantee_Rate_Method_Flag => l_guarantee_rate_method_flag,
             X_Calling_Fn               => 'fa_asset_val_pvt.validate_life',  p_log_level_rec => p_log_level_rec);

         -- if formula based, we need to copy the formula too
         if (p_rate_source_rule = 'FORMULA') then
            OPEN C_FORMULA (p_method_id => l_method_id_old);
            FETCH C_FORMULA
             INTO l_formula_actual,
                  l_formula_displayed,
                  l_formula_parsed,
                  l_original_rate,
                  l_revised_rate,
                  l_guarantee_rate;

            IF C_FORMULA%NOTFOUND then
               CLOSE C_FORMULA;
               fa_srvr_msg.add_message(
                    CALLING_FN => 'fa_asset_val_pvt.validate_life',
                    NAME => 'FA_FORMULA_RATE_NO_DATA_FOUND',  p_log_level_rec => p_log_level_rec);
               raise error_found;
            else
               CLOSE C_FORMULA;
            end if;

            FA_FORMULAS_PKG.insert_row
               (X_ROWID               => l_rowid,
                X_METHOD_ID           => l_method_id,
                X_FORMULA_ACTUAL      => l_formula_actual,
                X_FORMULA_DISPLAYED   => l_formula_displayed,
                X_FORMULA_PARSED      => l_formula_parsed,
                X_CREATION_DATE       => p_curr_date,
                X_CREATED_BY          => p_user_id,
                X_LAST_UPDATE_DATE    => p_curr_date,
                X_LAST_UPDATED_BY     => p_user_id,
                X_LAST_UPDATE_LOGIN   => -1,
                X_ORIGINAL_RATE       => l_original_rate,
                X_REVISED_RATE        => l_revised_rate,
                X_GUARANTEE_RATE      => l_guarantee_rate, p_log_level_rec => p_log_level_rec);

         end if;

      end if;  -- table based

      -- default the new life in months to the remaining life in months of
      -- parent.
      if (p_lim <> 0) then
         px_new_life := p_lim;
      end if;

   else
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'after fazccmt', 'method found', p_log_level_rec => p_log_level_rec);
      end if;
   end if;

   return true;

EXCEPTION
   when error_found then
       FA_SRVR_MSG.Add_Message(
            CALLING_FN => 'fa_asset_val_pvt.validate_life',  p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        FA_SRVR_MSG.Add_SQL_Error(
            CALLING_FN => 'fa_asset_val_pvt.validate_life',  p_log_level_rec => p_log_level_rec);
        return false;

END validate_life;



FUNCTION validate_payables_ccid
   (px_payables_ccid            IN OUT NOCOPY NUMBER,
    p_gl_chart_id               IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_is_valid_payables_ccid    number;

BEGIN

   if (px_payables_ccid is not NULL) then

      -- Validate payables ccid exists.
      select count(*)
      into   l_is_valid_payables_ccid
      from   gl_code_combinations
      where  code_combination_id = px_payables_ccid
      and    chart_of_accounts_id = p_gl_chart_id
      and    enabled_flag = 'Y'
      and    summary_flag = 'N'
      and    detail_posting_allowed_flag = 'Y';

      if (l_is_valid_payables_ccid = 0) then
         fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_payables_ccid',
              name       => 'FA_INCORRECT_PAYABLES_ID',  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   else
      -- Bug 885429  Payables CCID cannot be NULL, so set it to ZERO.
      -- Will generate the ccid based on default category if ccid is ZERO.
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_payables_ccid',
           name       => 'FA_NULL_PAYABLES_CCID',  p_log_level_rec => p_log_level_rec);
      px_payables_ccid := 0;

      return FALSE;
   end if;

   return TRUE;

END validate_payables_ccid;

FUNCTION validate_expense_ccid
   (p_expense_ccid              IN     NUMBER,
    p_gl_chart_id               IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_is_valid_expense_ccid        number;

BEGIN

   -- Expense ccid cannot be null.
   if (p_expense_ccid is null) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_expense_ccid',
           name       => 'FA_NULL_EXPENSE_CCID',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Check that expense ccid exists.
   select count(*)
   into   l_is_valid_expense_ccid
   from   gl_code_combinations
   where  code_combination_id = p_expense_ccid
   and    chart_of_accounts_id = p_gl_chart_id
   and    enabled_flag = 'Y'
   and    account_type = 'E'
   and    summary_flag = 'N'
   and    detail_posting_allowed_flag = 'Y';

   if (l_is_valid_expense_ccid = 0) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_expense_ccid',
           name       => 'FA_INCORRECT_EXPENSE_ID',
           token1     => 'EXPENSE_ID',
           value1     => p_expense_ccid,  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   return TRUE;

END validate_expense_ccid;

FUNCTION validate_fixed_assets_cost
   (p_fixed_assets_cost         IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   -- Fixed assets cost cannot be null.
   if (p_fixed_assets_cost is null) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_fixed_assets_cost',
           name       => 'FA_NULL_FA_COST',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   return TRUE;

END validate_fixed_assets_cost;

FUNCTION validate_fixed_assets_units
   (p_fixed_assets_units        IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   -- Fixed assets units cannot be null.
   if (p_fixed_assets_units is null) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_fixed_assets_units',
           name       => 'FA_NULL_FA_UNITS',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   else

      -- Fixed assets units cannot be zero.
      if (p_fixed_assets_units = 0) then
         fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_fixed_assets_units',
              name       => 'FA_ZERO_FA_UNITS',  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   return TRUE;

END validate_fixed_assets_units;

FUNCTION validate_payables_cost
   (p_payables_cost             IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   -- Payables cost cannot be null.
   if (p_payables_cost is null) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_payables_cost',
           name       => 'FA_NULL_PA_COST',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   return TRUE;

END validate_payables_cost;

FUNCTION validate_payables_units
   (p_payables_units            IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   -- Payables units cannot be null.
   if (p_payables_units is null) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_payables_units',
           name       => 'FA_NULL_PA_UNITS',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   return TRUE;

END validate_payables_units;

FUNCTION validate_po_vendor_id
   (p_po_vendor_id              IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_is_valid_vendor_id        number;

BEGIN

   if (p_po_vendor_id is not null) then

      -- Validate po_vendor_id exists.
      select count(*)
      into   l_is_valid_vendor_id
      from   po_vendors
      where  vendor_id = p_po_vendor_id;

      if (l_is_valid_vendor_id = 0) then
         fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_po_vendor_id',
              name       => 'FA_INCORRECT_PO_VENDOR_ID',  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   return TRUE;

END validate_po_vendor_id;

FUNCTION validate_unit_of_measure
   (p_unit_of_measure           IN     VARCHAR2,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_is_valid_uom        number;

BEGIN

   if (p_unit_of_measure is not null) then

      -- Validate unit of measure exists.
      select count(*)
      into   l_is_valid_uom
      from   mtl_units_of_measure
      where  unit_of_measure = p_unit_of_measure
      and    nvl(disable_date, sysdate+1) > sysdate;

      if (l_is_valid_uom = 0) then
         fa_srvr_msg.add_message(
              calling_fn => 'fa_asset_val_pvt.validate_unit_of_measure',
              name       => 'FA_INCORRECT_UOM',  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   return TRUE;

END validate_unit_of_measure;
-- Bug#7172602 Validating salvage value based on nbv.
FUNCTION validate_salvage_value
   (p_salvage_value             IN     NUMBER,
    p_nbv                       IN     NUMBER,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn                 varchar2(50) := 'fa_asset_val_pvt.validate_salvage_value';

BEGIN

    if (p_salvage_value is null or p_salvage_value = 0) then
       return TRUE;
    elsif ( p_nbv < 0 and p_salvage_value > 0 ) then
       fa_srvr_msg.add_message(calling_fn => l_calling_fn,name=> 'FA_BOOK_INVALID_SALVAGE ');
       return FALSE;
    elsif ( p_nbv > 0 and p_salvage_value < 0) then
       fa_srvr_msg.add_message(calling_fn => l_calling_fn,name=> 'FA_BOOK_POS_SALVAGE_VALUE');
       return FALSE;
    elsif ( (p_nbv < p_salvage_value and p_nbv >=0) OR ( p_nbv > p_salvage_value and p_nbv <=0)) then
       fa_srvr_msg.add_message(calling_fn => l_calling_fn,name=> 'FA_BOOK_INVALID_SALVAGE');
       return FALSE;
    end if;

    return TRUE;

END validate_salvage_value;

FUNCTION validate_tag_number
   (p_tag_number                IN     VARCHAR2,
    p_mass_addition_id          IN     NUMBER    DEFAULT NULL,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_tag_number_count        number;

BEGIN

   if (p_tag_number is not null) then

      -- Make sure that tag_number does not already exist in fa_additions.
      select count(*)
      into   l_tag_number_count
      from   fa_additions_b
      where  tag_number = p_tag_number;

      if (l_tag_number_count > 0) then
         fa_srvr_msg.add_message(
              calling_fn      => 'fa_asset_val_pvt.validate_tag_number',
              name            => 'FA_ADD_TAG_NUMBER_EXISTS',
              token1          => 'TAG_NUMBER',  -- Fix for Bug#5015917. Passed tag number token to
                                                -- display actual tag number in the log.
              value1          => p_tag_number,
              p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

   end if;

   return TRUE;

END validate_tag_number;

FUNCTION validate_split_merged_code
   (p_split_merged_code         IN     VARCHAR2,
    p_calling_fn                IN     VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   -- Split merged code cannot be zero.
   if (p_split_merged_code = 0) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_split_merged_code',
           name       => 'FA_INCORRECT_SPLIT_MERGED_CODE',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   return TRUE;

END validate_split_merged_code;

/* Japan Tax Phase 3 -- Added New parameter p_extended_flag
   For extended assets pass this flag as TRUE */
FUNCTION validate_exp_after_amort
  (p_asset_id           IN     number,
   p_book               IN     varchar2,
   p_extended_flag      IN     BOOLEAN DEFAULT FALSE,
   p_log_level_rec      IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

  l_count   number := 0 ;       -- 6348506: initialize
  l_rolled_back_imp number := 0;

BEGIN

   /* Japan Tax phase3 -- For extended assets consider transactions
      after extended transaction */

  -- perf issue 6348506: Insead of getting the actual count, just check for existence
  -- It will return 1 if recs exists and 0 if not. It will not return no-data-found

   if p_extended_flag then
      select count(1)
      into   l_count
      from   dual
      where exists (
         select 1
         from fa_transaction_headers th
         where th.book_type_code = p_book
         and   th.asset_id = p_asset_id
         and   (th.transaction_subtype = 'AMORTIZED' OR th.transaction_key = 'UA')
         and   th.transaction_header_id > (select max(th2.transaction_header_id)
                                        from fa_transaction_headers th2
                                        where th2.book_type_code = p_book
                                        and   th2.asset_id = p_asset_id
                                        and   th2.transaction_key = 'ES'));
   else
      select count(1)
      into   l_count
      from   dual
      where exists (
        select 1 from fa_transaction_headers
        where  book_type_code = p_book
        and  asset_id = p_asset_id
        and  (transaction_subtype = 'AMORTIZED' OR transaction_key = 'UA'));

   end if;

   /*8582979 - to allow expensed adj after impairment rollback */
   select count(1)
      into l_rolled_back_imp
   from dual
   where exists (
         select 1 from fa_transaction_headers
         where book_type_code = p_book
         and   asset_id = p_asset_id
         and   transaction_subtype = 'AMORTIZED' and transaction_key = 'RM');
   l_rolled_back_imp := l_rolled_back_imp * 2;

   if ((l_count - l_rolled_back_imp) > 0) then
      fa_srvr_msg.add_message(
           calling_fn => 'fa_asset_val_pvt.validate_exp_after_amort',
           name       => 'FA_BOOK_CANT_EXP_AFTER_AMORT',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   return true;

/** commenting out for perf  issue 6348506
 --bug fix 2772517
     select count(*)
     into l_count
     from fa_transaction_headers
     where  book_type_code = p_book
     and  asset_id = p_asset_id
     -- and  transaction_type_code = 'ADJUSTMENT' bug 5326226
     and  (transaction_subtype = 'AMORTIZED' OR transaction_key = 'UA');

   end if;
   Bug 2407786 - This is the consolidated select stmnt
*/


/*
  select count(*)
     into l_count
     from fa_books bk
    where bk.book_type_code           = p_book
      and bk.asset_id                 = p_asset_id
      and (bk.rate_Adjustment_factor <> 1 OR
           (bk.rate_adjustment_factor = 1 and
               exists (select 'YES'            -- and amortized before.
                   from fa_transaction_headers th,
                         fa_methods mt
                   where th.book_type_code = bk.book_type_code
                   and  th.asset_id =  bk.asset_id
                   and  th.transaction_type_code = 'ADJUSTMENT'
                   and  (th.transaction_subtype = 'AMORTIZED' OR th.transaction_key = 'UA')
                   and  th.transaction_header_id = bk.transaction_header_id_in
                   and  mt.method_code = bk.deprn_method_code
                   and  mt.rate_source_rule IN ('TABLE','FLAT','PRODUCTION'))));
*/

EXCEPTION
   when others then
            fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_asset_val_pvt.validate_exp_after_amort',  p_log_level_rec => p_log_level_rec);

   return false;

END validate_exp_after_amort;

FUNCTION validate_unplanned_exists
  (p_asset_id           IN     number,
   p_book               IN     varchar2,
   p_log_level_rec      IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

  l_count   number;

BEGIN

   SELECT count(*)
     INTO l_count
     FROM fa_transaction_headers
    WHERE book_type_code  = p_book
      AND asset_id        = p_asset_id
      AND transaction_key like 'U%';

   if (l_count > 0) then
      fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcbsx',
                              name       => '***FA_UNP_EXISTS***',
                   p_log_level_rec => p_log_level_rec);
      return TRUE;
   else
      return FALSE;
   end if;

END validate_unplanned_exists;



FUNCTION validate_period_of_addition
  (p_asset_id            IN     number,
   p_book                IN     varchar2,
   p_mode                IN     varchar2 DEFAULT 'ABSOLUTE',
   px_period_of_addition IN OUT NOCOPY varchar2,
   p_log_level_rec       IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

  l_last_pc      number;
  l_count        number;
  l_period_rec   FA_API_TYPES.period_rec_type;

BEGIN

   -- no need to load book controls cache here as it's loaded
   l_last_pc := FA_CACHE_PKG.fazcbc_record.last_period_counter;

   if (p_mode = 'ABSOLUTE') then
      SELECT count(*)
        INTO l_count
        FROM fa_deprn_summary
       WHERE book_type_code    = p_book
         AND asset_id          = p_asset_id
         AND deprn_source_code = 'BOOKS'
         AND period_counter    = l_last_pc;

      if (l_count <> 0) then
         px_period_of_addition := 'Y';
      else
         px_period_of_addition := 'N';
      end if;

   elsif (p_mode = 'CAPITALIZED') then

      if not FA_UTIL_PVT.get_period_rec
             (p_book           => p_book,
              p_effective_date => NULL,
              x_period_rec     => l_period_rec
             , p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message (
             calling_fn => 'fa_asset_val_pvt.validate_period_of_addition',  p_log_level_rec => p_log_level_rec);
          return false;
      end if;

      SELECT count(*)
        INTO l_count
        FROM fa_transaction_headers th
       WHERE th.asset_id              = p_asset_id
         AND th.book_type_code        = p_book
         AND th.transaction_type_code = 'ADDITION'
         AND th.date_effective        > l_period_rec.period_open_date;

      if (l_count <> 0) then
         px_period_of_addition := 'Y';
      else
         px_period_of_addition := 'N';
      end if;

   else
      fa_srvr_msg.add_message (
         calling_fn => 'fa_asset_val_pvt.validate_period_of_addition',
         name       => 'FA_CACHE_UNSUPPORTED_MODE',  p_log_level_rec => p_log_level_rec);
      return false;
   end if;

   return true;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(
          calling_fn => 'fa_asset_val_pvt.validate_period_of_addition',  p_log_level_rec => p_log_level_rec);
      return false;

END validate_period_of_addition;

FUNCTION validate_fully_retired
  (p_asset_id           IN     number,
   p_book               IN     varchar2,
   p_log_level_rec      IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

  l_count   number;

BEGIN

   select count(*)
     into l_count
     FROM FA_BOOKS   BK
    WHERE BK.ASSET_ID                      = p_asset_id
      AND BK.PERIOD_COUNTER_FULLY_RETIRED IS NOT NULL
      AND BK.DATE_INEFFECTIVE             IS NULL
      AND BK.BOOK_TYPE_CODE                = p_book
      AND rownum                           < 2;

      if (l_count <> 0) then
         RETURN TRUE;
      else
         RETURN FALSE;
      end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(
          calling_fn => 'fa_asset_val_pvt.validate_period_of_addition',  p_log_level_rec => p_log_level_rec);
      return false;

END validate_fully_retired;


FUNCTION validate_add_to_asset_pending
  (p_asset_id           in  number,
   p_book               in  varchar2,
   p_log_level_rec      IN  FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

  l_count   number;

BEGIN

    select count(*)
    into l_count
    from fa_mass_additions
    where book_type_code  = p_book
      and add_to_asset_id = p_asset_id
      and posting_status not in ('POSTED','MERGED','SPLIT','DELETE')
      and rownum < 2;

    if (l_count <> 0) then
         return TRUE;
    else
         return FALSE;
    end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_asset_val_pvt.validate_add_to_asset_pending',
                                p_log_level_rec => p_log_level_rec);
      return false;

END validate_add_to_asset_pending;


FUNCTION validate_asset_id_exist
  (p_asset_id       in    number,
   p_log_level_rec  IN    FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

  l_count   number;

BEGIN

    select count(*)
    into l_count
    from fa_additions
    where asset_id = p_asset_id
      and rownum < 2;

    if (l_count <> 0) then
         return TRUE;
    else
         return FALSE;
    end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(
          calling_fn => 'fa_asset_val_pvt.validate_asset_id_exist',  p_log_level_rec => p_log_level_rec);
      return FALSE;

END validate_asset_id_exist;

FUNCTION validate_ret_rst_pending
   (p_asset_id      in  number,
    p_book          in  varchar2,
    p_log_level_rec IN  FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

   l_count   number;

BEGIN

   select count(*)
   into l_count
   from fa_retirements
   where book_type_code = p_book
     and asset_id = p_asset_id
     and status in ('PENDING','REINSTATE');

   if (l_count <> 0) then
        return TRUE;
   else
        return FALSE;
   end if;

EXCEPTION

   when others then
      fa_srvr_msg.add_sql_error(
          calling_fn => 'fa_asset_val_pvt.validate_ret_rst_pending',  p_log_level_rec => p_log_level_rec);

      return FALSE;

END validate_ret_rst_pending;

FUNCTION validate_fa_lookup_code
   (p_lookup_type   in  varchar2,
    p_lookup_code   in  varchar2,
    p_log_level_rec IN  FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

   l_count   number;

BEGIN

   select count(*)
   into l_count
   from fa_lookups_b
   where lookup_type = p_lookup_type
     and lookup_code = p_lookup_code;

   if (l_count <> 0) then
      return TRUE;
   else
      fa_srvr_msg.add_message
            (calling_fn      => 'fa_asset_val_pvt.validate_fa_lookup_code',
             name            => '***FA_BAD_LOOKUP_CODE***',
             p_log_level_rec => p_log_level_rec);
        return FALSE;
   end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn      => 'fa_asset_val_pvt.validate_fa_lookup_code',
                                p_log_level_rec => p_log_level_rec);
      return false;

END validate_fa_lookup_code;

FUNCTION validate_dist_id
   (p_asset_id      in  number,
    p_dist_id       in  number,
    p_log_level_rec IN  FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

   l_count   number;

BEGIN

   select count(*)
   into   l_count
   from   fa_distribution_history
   where  asset_id = p_asset_id
   and    distribution_id = p_dist_id;

   if (l_count <> 0) then
      return TRUE;
   else
      fa_srvr_msg.add_message(calling_fn      => 'fa_asset_val_pvt.validate_dist_id',
                              p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(
          calling_fn => 'fa_asset_val_pvt.validate_dist_id',  p_log_level_rec => p_log_level_rec);
      return FALSE;

END validate_dist_id;

FUNCTION validate_corp_pending_ret
   (p_asset_id                 in  number,
    p_book                     in  varchar2,
    p_transaction_header_id_in in  number,
    p_log_level_rec            IN  FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_count1           number := 0;
   l_count2           number := 0;

   v_xfr_out_thid     number;

BEGIN

/*---------------------------------------------------------------+
| Bug 1577955.                                                   |
| We need to check if there are any partial Unit Retirements in  |
| the Corporate book. Then we check if there were any cost       |
| adjustments or if depreciation was run on  any of the          |
| associated Tax books before running Gain/Loss in the Corporate |
| book. If that is the case, we will not allow                   |
| the use of the 'Undo Retirement' function.                     |
| Instead, Gain/Loss must be run on the Corp book first          |
| and then you may reinstate the asset.                          |
+---------------------------------------------------------------+*/
   begin
     select  distinct transaction_header_id
     into    v_xfr_out_thid
     from    fa_transaction_headers thd
     where   thd.asset_id = p_Asset_Id
       and   thd.TRANSACTION_TYPE_CODE = 'TRANSFER OUT'
       and   thd.book_type_code = p_book
       and   thd.transaction_header_id > p_Transaction_Header_Id_In
       and   rownum = 1;
   exception
     when others then null;
   end;


   begin
     select  count(*)
     into    l_count1
     from    fa_adjustments adj,
             fa_distribution_history dh
     where   adj.asset_id = p_asset_id
       and   adj.asset_id = dh.asset_id
       and   adj.distribution_id = dh.distribution_id
       and   dh.transaction_header_id_in = v_xfr_out_thid
       and   adj.transaction_header_id  <> v_xfr_out_thid;
   exception
     when others then null;
   end;


   begin
     select  count(*)
     into    l_count2
     from    fa_deprn_detail dd,
             fa_distribution_history dh
     where   dd.asset_id = p_asset_id
       and   dd.asset_id = dh.asset_id
       and   dd.distribution_id = dh.distribution_id
       and   dh.transaction_header_id_in = v_xfr_out_thid;
   exception
     when others then null;
   end;

   if (l_count1 <> 0 or l_count2 <> 0) then
        return TRUE;
   else
        return FALSE;
   end if;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error(calling_fn      => 'fa_asset_val_pvt.validate_corp_pending_ret',
                                p_log_level_rec => p_log_level_rec);

      return false;

END validate_corp_pending_ret;

FUNCTION validate_parent_asset(
         p_parent_asset_id  IN number,
         p_asset_id         IN number,
         p_log_level_rec    IN FA_API_TYPES.log_level_rec_type) return boolean IS

  l_count number:=0;
  l_corp_book varchar2(30);
BEGIN
  -- always do this check for corp book
  if NOT FA_UTIL_PVT.get_corp_book(
                     p_asset_id    => p_asset_id,
                     p_corp_book  => l_corp_book , p_log_level_rec => p_log_level_rec) then
           return FALSE;
  end if;

  select count(1)
  into  l_count
  from  fa_books
  where book_type_code = l_corp_book
  and   asset_id = p_parent_asset_id
  and   date_ineffective is null;

  if l_count = 0 then
    fa_srvr_msg.add_message(
                calling_fn => 'validate_parent_asset',
                name       => 'FA_INCORRECT_PARENT_ASSET', p_log_level_rec => p_log_level_rec);
    return FALSE;
  end if;

  return TRUE;

END validate_parent_asset;

FUNCTION validate_warranty (
  p_warranty_id            IN NUMBER,
  p_date_placed_in_service IN DATE,
  p_book_type_code         IN VARCHAR2,
  p_log_level_rec          IN FA_API_TYPES.log_level_rec_type) return boolean IS

  l_count number := 0;

BEGIN

  if p_warranty_id is not null then

    -- Validate warranty is in valid date
    SELECT count(w.warranty_id) INTO l_count
    FROM   fa_warranties w
    WHERE  w.warranty_id = p_warranty_id
    AND    p_date_placed_in_service between
           nvl (w.start_date, p_date_placed_in_service) and
           nvl (w.end_date,   p_date_placed_in_service);

    if l_count = 0 then
      fa_srvr_msg.add_message(
                  calling_fn => 'validate_warranty',
                  name       => 'FA_INVALID_WARRANTY', p_log_level_rec => p_log_level_rec);
      return FALSE;
    end if;

    -- Validate warranty currency is correct
    SELECT count(w.warranty_id) INTO l_count
    FROM   gl_sets_of_books glsob,
           fa_book_controls bc,
           fa_warranties w
    WHERE  w.warranty_id = p_warranty_id
    AND    bc.book_type_code = p_book_type_code
    AND    bc.set_of_books_id = glsob.set_of_books_id
    AND    glsob.currency_code =
           nvl(w.currency_code, glsob.currency_code);

    if l_count = 0 then
      fa_srvr_msg.add_message(
                  calling_fn => 'validate_warranty',
                  name       => 'FA_SHARED_GET_CURRENCY_CODE', p_log_level_rec => p_log_level_rec);
      return FALSE;
    end if;
  end if;

  return TRUE;
END validate_warranty;

FUNCTION validate_lease(
         p_asset_id      IN number,
         p_lease_id      IN number,
         p_log_level_rec IN FA_API_TYPES.log_level_rec_type) return boolean IS

   CURSOR get_cat_type IS
   select category_type
   from fa_categories_b
   where category_id = ( select asset_category_id
                         from fa_additions_b
                         where asset_id = p_asset_id );
   CURSOR C1 IS
   select currency_code
   from gl_sets_of_books sob,
        fa_book_controls bc,
        fa_books bk
   where bk.asset_id = p_asset_id
   and   bk.date_ineffective is null
   and   bk.book_type_code = bc.book_type_code
   and   bc.set_of_books_id = sob.set_of_books_id;

   l_cat_type varchar2(30);
   l_count number:=0;
   l_lease_currency varchar2(15);
   lease_error EXCEPTION;
BEGIN

  if p_lease_id is not null then

    -- check if lease is valid
    select count(1)
    into l_count
    from fa_leases
    where lease_id = p_lease_id;
    if l_count = 0 then
      fa_srvr_msg.add_message(
                  calling_fn => 'validate_lease',
                  name       => 'FA_INVALID_LEASE', p_log_level_rec => p_log_level_rec);
      return FALSE;
    end if;

    -- check if lease is allowed
    OPEN get_cat_type;
    FETCH get_cat_type INTO l_cat_type;
    CLOSE get_cat_type;
    if l_cat_type NOT IN ( 'LEASE', 'LEASEHOLD IMPROVEMENT') then
       fa_srvr_msg.add_message(
                   calling_fn => 'validate_lease',
                   name       => 'FA_CANT_ADD_LEASE', p_log_level_rec => p_log_level_rec);
       return FALSE;
    end if;

    -- check if lease_currency same
    select currency_code
    into l_lease_currency
    from fa_leases
    where lease_id = p_lease_id;
    FOR c1_rec in c1 loop
        if (l_lease_currency <> c1_rec.currency_code) then
          raise lease_error;
        end if;
    END LOOP;
  end if;

      return TRUE;

  EXCEPTION
    when lease_error then
          fa_srvr_msg.add_message(
                      calling_fn => 'validate_lease',
                      name       => 'FA_CURRENCY_NOT_MATCH', p_log_level_rec => p_log_level_rec);
          return FALSE;

END validate_lease;

FUNCTION validate_property_type(
              p_property_type_code in VARCHAR2,
              p_log_level_rec      IN FA_API_TYPES.log_level_rec_type) return boolean IS
   l_count number:= 0;
BEGIN
  if p_property_type_code is not null then
    select count(1)
    into  l_count
    from  fa_lookups_b
    where lookup_type = 'PROPERTY TYPE'
    and   lookup_code = p_property_type_code;

    if l_count = 0 then
      fa_srvr_msg.add_message(
                  calling_fn => 'validate_property_type',
                  name       => 'FA_PROPERTY_TYPE_NOT_EXIST', p_log_level_rec => p_log_level_rec);
      return FALSE;
    end if;
  end if;

  return TRUE;

END validate_property_type;


FUNCTION validate_1245_1250_code(
                 p_1245_1250_code in VARCHAR2,
                 p_log_level_rec  IN FA_API_TYPES.log_level_rec_type) return boolean IS

  l_count number:= 0;
BEGIN
   if p_1245_1250_code is not null then
    select count(1)
    into  l_count
    from  fa_lookups_b
    where lookup_type = '1245/1250 PROPERTY'
    and   lookup_code = p_1245_1250_code;

    if l_count = 0 then
      fa_srvr_msg.add_message(
                  calling_fn => 'validate_1245_1250_code',
                  name       => 'FA_1245_1250_NOT_EXIST', p_log_level_rec => p_log_level_rec);
      return FALSE;
    end if;
  end if;

  return TRUE;

END validate_1245_1250_code;

FUNCTION validate_group_asset
  (p_group_asset_id in NUMBER,
   p_book_type_code in VARCHAR2,
   p_asset_type     in VARCHAR2,
   p_log_level_rec  IN FA_API_TYPES.log_level_rec_type) return boolean  is

   l_count number;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('val api', 'group', p_group_asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('val api', 'book', p_book_type_code, p_log_level_rec => p_log_level_rec);
   end if;

   --
   -- Following sql is too expensive
   --
   --   select count(*)
   --     into l_count
   --     from FA_BOOKS
   --    where ASSET_ID = p_group_asset_id
   --      and BOOK_TYPE_CODE = p_book_type_code;
   l_count := null;
   select 1
   into l_count
   from dual
   where exists (select 'X'
                 from FA_BOOKS
                 where ASSET_ID = p_group_asset_id
                 and BOOK_TYPE_CODE = p_book_type_code);

   if l_count is null then
      fa_srvr_msg.add_message(
                  calling_fn => 'fa_asset_val_pvt.validate_group_asset',
                  name       => 'FA_GROUP_NOT_IN_BOOK',  p_log_level_rec => p_log_level_rec);
      return false;
   end if;


   if (p_asset_type <> 'CAPITALIZED' and
       p_asset_type <> 'CIP') then
      fa_srvr_msg.add_message(
                  calling_fn => 'fa_asset_val_pvt.validate_group_asset',
                  name       => 'FA_INV_ASSET_TYPE',  p_log_level_rec => p_log_level_rec);
      return false;
   end if;

   return true;

END validate_group_asset;

--HH group enable/disable
FUNCTION validate_disabled_flag
  (p_group_asset_id in NUMBER,
   p_book_type_code in VARCHAR2,
   p_old_flag       IN VARCHAR2,
   p_new_flag       IN VARCHAR2,
   p_log_level_rec  IN FA_API_TYPES.log_level_rec_type) return boolean  is

 l_calling_fn   varchar2(40) :='fa_asset_val_pvt.validate_disabled_flag';

BEGIN

   IF ((NVL(p_old_flag,'N') Not IN ('Y','N')) OR
      (NVL(p_new_flag,'N') Not IN ('Y','N'))) THEN
      -- Garbage value for flag.
      fa_srvr_msg.add_message(
              calling_fn  => l_calling_fn,
              name       => 'FA_INCORRECT_DISABLED_FLAG', p_log_level_rec => p_log_level_rec);
           return FALSE;

   ELSIF (nvl(p_old_flag,'N')='Y' AND nvl(p_new_flag,'N')='Y') THEN
      --Disabled group.
      fa_srvr_msg.add_message(
              calling_fn  => l_calling_fn,
              name       => 'FA_DISABLED_GROUP', p_log_level_rec => p_log_level_rec);
           return FALSE;
   ELSIF (nvl(p_old_flag,'N')='N' AND nvl(p_new_flag,'N')='Y') THEN
      if NOT validate_group_info(p_group_asset_id => p_group_asset_id,
                                 p_book_type_code => p_book_type_code,
                                 p_calling_fn     => l_calling_fn,
                                 p_log_level_rec  => p_log_level_rec) THEN
         --Group doesn't meet criteria for disabling.
         return FALSE;
      end if;
   END IF;

   RETURN TRUE;

END validate_disabled_flag;

FUNCTION validate_group_info
  (p_group_asset_id in NUMBER,
   p_book_type_code in VARCHAR2,
   p_calling_fn     in VARCHAR2,
   p_log_level_rec  IN FA_API_TYPES.log_level_rec_type) return boolean is

l_has_members  number;
l_disabled     number;
l_calling_fn   varchar2(40) :='fa_asset_val_pvt.validate_group_info';

BEGIN

  SELECT count(1)
  INTO  l_disabled
  FROM  fa_books
  WHERE asset_id = p_group_asset_id
  AND   book_type_code = p_book_type_code
  AND   disabled_flag  = 'Y'
  AND   transaction_header_id_out is null;

  if (l_disabled = 0) then
     if p_calling_fn <> 'fa_asset_val_pvt.validate_disabled_flag' then
       return true;
     else
       SELECT count(1)
       INTO  l_has_members
       FROM  fa_books
       WHERE group_asset_id = p_group_asset_id
       AND   book_type_code = p_book_type_code
       AND   transaction_header_id_out is null
       AND   period_counter_fully_retired is null;
     end if;
  elsif (l_disabled > 0) then
     fa_srvr_msg.add_message(
            calling_fn => l_calling_fn,
            name       => 'FA_DISABLED_GROUP', p_log_level_rec => p_log_level_rec);
     return false;
  end if;

  if l_has_members > 0 then
     fa_srvr_msg.add_message(
            calling_fn => l_calling_fn,
            name       => 'FA_CANT_DISABLE_GROUP', p_log_level_rec => p_log_level_rec);
     return false;
  end if;

  return true;

END validate_group_info; -- End HH.

FUNCTION validate_over_depreciate
   (p_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type                 VARCHAR2,
    p_over_depreciate_option     VARCHAR2 default null,
    p_adjusted_recoverable_cost  NUMBER   default null,
    p_recoverable_cost           NUMBER   default null,
    p_deprn_reserve_new          NUMBER   default null,
    p_rate_source_rule           VARCHAR2 default null,
    p_deprn_basis_rule           VARCHAR2 default null,
    p_recapture_reserve_flag     VARCHAR2 default null,
    p_deprn_limit_type           VARCHAR2 default null,
    p_log_level_rec              FA_API_TYPES.log_level_rec_type) return boolean is

  l_calling_fn varchar2(50) := 'fa_asset_val_pvt.validate_over_depreciate';

  l_member_count   binary_integer := 0;

BEGIN


   if (p_asset_type = 'GROUP') then

      if (nvl(p_adjusted_recoverable_cost, p_recoverable_cost) = 0) then
         --
         -- Check to see if there is no member belongs to this group asset
         -- If no member asset exists, terminal gain loss will take care
         -- remaining reserve handling
         --
         select count(transaction_header_id_in)
         into   l_member_count
         from   fa_books
         where  group_asset_id = p_asset_hdr_rec.asset_id
         and    book_type_code = p_asset_hdr_rec.book_type_code
         and    transaction_header_id_out is null;
      else
         -- Group has a cost so set dummy 1
         l_member_count := 1;
      end if;


      if (l_member_count > 0) then
         -- Check to see if new reserve exceeds (adjusted )recoverable cost
         -- even thought asset is not suppsed to be over depreciated
         if (p_deprn_reserve_new is not null) and
            (nvl(p_adjusted_recoverable_cost, p_recoverable_cost) is not null) then

            if (nvl(p_over_depreciate_option, fa_std_types.FA_OVER_DEPR_NO) =
                fa_std_types.FA_OVER_DEPR_NO) then
               if (nvl(p_adjusted_recoverable_cost, p_recoverable_cost) > 0 and
                   nvl(p_adjusted_recoverable_cost, p_recoverable_cost) < p_deprn_reserve_new) or
                  (nvl(p_adjusted_recoverable_cost, p_recoverable_cost) < 0 and
                   nvl(p_adjusted_recoverable_cost, p_recoverable_cost) > p_deprn_reserve_new) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                          name       => 'FA_TOO_MUCH_RESERVE', p_log_level_rec => p_log_level_rec);
                  return FALSE;
               end if;

            end if;
         end if;

         -- Over Depreciate cannot be DEPRN if method is flat-nbv
         if (p_rate_source_rule is not null) and
            (p_deprn_basis_rule is not null) then
            if (p_rate_source_rule = 'FLAT') and
               (p_deprn_basis_rule = 'NBV') and
               (nvl(p_over_depreciate_option, fa_std_types.FA_OVER_DEPR_NO) =
                   fa_std_types.FA_OVER_DEPR_DEPRN) then

               fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                 name       => 'FA_NO_OVER_DEPRN_ALLOWED', p_log_level_rec => p_log_level_rec);
               return false;

            end if;

         end if;

         /* BUG# 2941674
          * removing this validation for now...
          * as we need it to account for CRL behavior

         if (p_deprn_limit_type is not null) then
            if (p_deprn_limit_type <> 'NONE') and
               (nvl(p_over_depreciate_option, fa_std_types.FA_OVER_DEPR_NO) <>
                fa_std_types.FA_OVER_DEPR_NO) then

               fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                 name       => 'FA_NO_OVER_DEPRN_ALLOWED', p_log_level_rec => p_log_level_rec);
               return false;
            end if;

         end if;

         */

         if (nvl(p_recapture_reserve_flag, 'N') <> 'N') and
            (nvl(p_over_depreciate_option, fa_std_types.FA_OVER_DEPR_NO) <>
             fa_std_types.FA_OVER_DEPR_NO) then

            fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                    name       => 'FA_NO_OVER_DEPRN_ALLOWED', p_log_level_rec => p_log_level_rec);
            return false;
         end if;
      end if; -- (l_member_count > 0)

   end if; -- (p_asset_type = 'GROUP')


   return TRUE;

END validate_over_depreciate;

FUNCTION validate_cost_change (
         p_asset_id               number,
         p_group_asset_id         number,
         p_book_type_code         varchar2,
         p_asset_type             varchar2,
         p_transaction_header_id  number,
         p_transaction_date       date,
         p_cost                   number default 0,
         p_cost_adj               number default 0,
         p_salvage_value          number default 0,
         p_salvage_value_adj      number default 0,
         p_deprn_limit_amount     number default 0,
         p_deprn_limit_amount_adj number default 0,
         p_mrc_sob_type_code      varchar2,
         p_set_of_books_id        number,
         p_over_depreciate_option varchar2,
         p_log_level_rec          FA_API_TYPES.log_level_rec_type) return boolean is

  l_calling_fn varchar2(50) := 'fa_asset_val_pvt.validate_cost_change';

  CURSOR c_get_current_amts IS
    select sum(inbk.cost - nvl(outbk.cost, 0))
         , sum(inbk.salvage_value - nvl(outbk.salvage_value, 0))
         , sum(nvl(inbk.allowed_deprn_limit_amount, 0) -
               nvl(outbk.allowed_deprn_limit_amount, 0))
    from   fa_transaction_headers th,
           fa_books inbk,
           fa_books outbk
    where  inbk.asset_id = p_asset_id
    and    inbk.book_type_code = p_book_type_code
    and    outbk.asset_id(+) = p_asset_id
    and    outbk.book_type_code(+) = p_book_type_code
    and    inbk.transaction_header_id_in = th.transaction_header_id
    and    decode(th.transaction_type_code, 'ADDITION', to_number(null),
                                            'CIP ADDITION', to_number(null),
                                            outbk.transaction_header_id_out(+)) = th.transaction_header_id
    and    th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    th.transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN',
                                            'TRANSFER', 'TRANSFER IN/VOID',
                                            'RECLASS', 'UNIT ADJUSTMENT',
                                            'REINSTATEMENT', 'ADDITION/VOID',
                                            'CIP ADDITION/VOID')
    and    th.transaction_header_id <> p_transaction_header_id
    and    decode(th.transaction_type_code,
                    'ADDITION', inbk.date_placed_in_service,
                    'CIP ADDITION', inbk.date_placed_in_service,
                    decode(th.transaction_subtype,
                                'EXPENSED', inbk.date_placed_in_service,
                                            nvl(th.amortization_start_date,
               th.transaction_date_entered))) <= p_transaction_date
    and    not exists(select 'Exclude Retirement which reinstatement exists'
                      from   fa_retirements ret,
                             fa_transaction_headers reith
                      where  ret.transaction_header_id_in = th.transaction_header_id
                      and    ret.transaction_header_id_out = reith.transaction_header_id
                      and    nvl(reith.amortization_start_date,
                              reith.transaction_date_entered) <= p_transaction_date);

  CURSOR c_get_current_mc_amts IS
    select sum(inbk.cost - nvl(outbk.cost, 0))
         , sum(inbk.salvage_value - nvl(outbk.salvage_value, 0))
         , sum(nvl(inbk.allowed_deprn_limit_amount, 0) -
               nvl(outbk.allowed_deprn_limit_amount, 0))
    from   fa_transaction_headers th,
           fa_mc_books inbk,
           fa_mc_books outbk
    where  inbk.asset_id = p_asset_id
    and    inbk.book_type_code = p_book_type_code
    and    inbk.set_of_books_id = p_set_of_books_id
    and    outbk.asset_id(+) = p_asset_id
    and    outbk.book_type_code(+) = p_book_type_code
    and    outbk.set_of_books_id = p_set_of_books_id
    and    inbk.transaction_header_id_in = th.transaction_header_id
    and    decode(th.transaction_type_code, 'ADDITION', to_number(null),
                                            'CIP ADDITION', to_number(null),
                                            outbk.transaction_header_id_out(+)) = th.transaction_header_id
    and    th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    th.transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN',
                                            'TRANSFER', 'TRANSFER IN/VOID',
                                            'RECLASS', 'UNIT ADJUSTMENT',
                                            'REINSTATEMENT', 'ADDITION/VOID',
                                            'CIP ADDITION/VOID')
    and    th.transaction_header_id <> p_transaction_header_id
    and    decode(th.transaction_type_code,
                    'ADDITION', inbk.date_placed_in_service,
                    'CIP ADDITION', inbk.date_placed_in_service,
                    decode(th.transaction_subtype,
                                'EXPENSED', inbk.date_placed_in_service,
                                            nvl(th.amortization_start_date,
               th.transaction_date_entered))) <= p_transaction_date
    and    not exists(select 'Exclude Retirement which reinstatement exists'
                      from   fa_retirements ret,
                             fa_transaction_headers reith
                      where  ret.transaction_header_id_in = th.transaction_header_id
                      and    ret.transaction_header_id_out = reith.transaction_header_id
                      and    nvl(reith.amortization_start_date,
                              reith.transaction_date_entered) <= p_transaction_date);

   l_cost               number;
   l_salvage_value      number;
   l_deprn_limit_amount number;

   val_err  EXCEPTION;

BEGIN

   --
   -- Perform the check only if
   -- Current cost is not 0
   -- and sign of current cost and delta cost is different.  OR
   -- Current salvage_value is not 0
   -- and sign of current salvage_value and delta salvage_value is different
   -- and asset type is GROUP.  OR
   -- Current deprn_limit_amount is not 0
   -- and sign of current deprn_limit_amount and delta deprn_limit_amount is different.
   --
   if (( p_cost <> 0 and p_cost_adj <> 0) and sign(p_cost_adj) <> sign(p_cost)) or
      (( p_salvage_value <> 0 and p_salvage_value_adj <> 0) and
       (sign(p_salvage_value_adj) <> sign(p_salvage_value)) and
       (p_asset_type <> 'GROUP')) or
      ((p_deprn_limit_amount <> 0 and p_deprn_limit_amount_adj <> 0) and
        sign(p_deprn_limit_amount_adj) <> sign(p_deprn_limit_amount)) then

      /* Commented for bug# 5131759
      if (p_mrc_sob_type_code = 'R') then
         OPEN c_get_current_mc_amts;
         FETCH c_get_current_mc_amts INTO l_cost, l_salvage_value, l_deprn_limit_amount;
         CLOSE c_get_current_mc_amts;
      else
         OPEN c_get_current_amts;
         FETCH c_get_current_amts INTO l_cost, l_salvage_value, l_deprn_limit_amount;
         CLOSE c_get_current_amts;
      end if; -- (p_mrc_sob_type_code = 'R') */

      --HH
      --Bug 3528634.  Check cost change flag and other conditions in bug.
      --Only do for cost and salvage amounts.  For deprn limit I think we always want
      --to check that.  See bug for more details.
      --Also, using the already loaded cache structures here since this is only
      --called from calc now.  Should this change, we may need to consider
      --changing the params passed in to this proc.

      if (fa_cache_pkg.fazccmt_record.rate_source_rule NOT IN ('CALCULATED','FLAT','TABLE')) OR
         (fa_cache_pkg.fazccmt_record.deprn_basis_rule = 'NBV') OR
         (NVL(fa_cache_pkg.fazcbc_record.ALLOW_COST_SIGN_CHANGE_FLAG,'N') = 'N') then

         --Members must also belong to a group that has the Over Depreciate Option as
         --"Allow and Depreciate"

         if ((p_group_asset_id is not null) and
             (nvl(p_over_depreciate_option, fa_std_types.FA_OVER_DEPR_NO) =
                                            fa_std_types.FA_OVER_DEPR_DEPRN) and
             (NVL(fa_cache_pkg.fazcbc_record.ALLOW_COST_SIGN_CHANGE_FLAG,'N') = 'Y')) then
           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'Member cost sign','can be changed', p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'over depreciate option',p_over_depreciate_option, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'group_asset_id',p_group_asset_id, p_log_level_rec => p_log_level_rec);
           end if;
         else
           if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'validating cost and salvage','', p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'sign change flag',
                                fa_cache_pkg.fazcbc_record.ALLOW_COST_SIGN_CHANGE_FLAG, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'over depr option',p_over_depreciate_option, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'group_asset_id',p_group_asset_id, p_log_level_rec => p_log_level_rec);
           end if;

           -- Added following if condition for bugfix# 5131759
           if (p_mrc_sob_type_code = 'R') then
              OPEN c_get_current_mc_amts;
              FETCH c_get_current_mc_amts INTO l_cost, l_salvage_value, l_deprn_limit_amount;
              CLOSE c_get_current_mc_amts;
           else
              OPEN c_get_current_amts;
              FETCH c_get_current_amts INTO l_cost, l_salvage_value, l_deprn_limit_amount;
              CLOSE c_get_current_amts;
           end if; -- (p_mrc_sob_type_code = 'R')

	   if (p_cost_adj <> 0) and
              (sign(nvl(l_cost, 0) + p_cost_adj) <> 0) and
              (sign(nvl(l_cost, 0) + p_cost_adj) <> sign(p_cost)) then
              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'Delta Cost', 'Invalid', p_log_level_rec => p_log_level_rec);
              end if;
              raise val_err;
           end if;

           if (p_salvage_value_adj <> 0) and
              (sign(nvl(l_salvage_value, 0) + p_salvage_value_adj) <> 0) and
              (sign(nvl(l_salvage_value, 0) + p_salvage_value_adj) <>
               sign(p_salvage_value)) and
              (p_salvage_value <> 0) then -- Bug#6618908
              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'Delta Salvage Value', 'Invalid', p_log_level_rec => p_log_level_rec);
              end if;
              raise val_err;
           end if;
         end if; --group_asset_id not null...

      end if; --Cost change condition.  End HH.

      if (p_deprn_limit_amount_adj <> 0) and
         (sign(nvl(l_deprn_limit_amount, 0) + p_deprn_limit_amount_adj) <> 0) and
         (sign(nvl(l_deprn_limit_amount, 0) + p_deprn_limit_amount_adj) <>
          sign(p_deprn_limit_amount)) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Delta Deprn Limit Amount', 'Invalid', p_log_level_rec => p_log_level_rec);
         end if;
         raise val_err;
      end if;

   end if; -- ( p_cost <> 0)

  return true;

EXCEPTION
  WHEN val_err THEN
         fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                 name       => 'FA_INVALID_AMOUNT_ADJUSTMENT', p_log_level_rec => p_log_level_rec);
    return false;

  WHEN OTHERS THEN
    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;

END validate_cost_change;


-- New function due for bug2846357
--
-- check if duplicate distribution info exist in p_asset_dist_tbl
-- current row( p_curr_index) of p_asset_dist_tbl is compared to
-- all of previous rows of p_asset_dist_tbl
-- to check for duplicates

FUNCTION validate_duplicate_dist (
         p_transaction_type_code IN             VARCHAR2,
         p_asset_dist_tbl        IN OUT NOCOPY  FA_API_TYPES.asset_dist_tbl_type,
         p_curr_index            IN             NUMBER,
         p_log_level_rec         IN             FA_API_TYPES.log_level_rec_type) return boolean  IS

  l_high_bound number;
  dup_err exception;
  l_calling_fn varchar2(50) := 'fa_asset_val_pvt.validate_duplicate_dist';

BEGIN

  l_high_bound := p_curr_index - 1;
  FOR k in p_asset_dist_tbl.first..l_high_bound LOOP

      -- if TRANSFER check if transfering to same line
      if p_transaction_type_code  = 'TRANSFER' then
          if ( p_asset_dist_tbl(k).distribution_id is not null and
               p_asset_dist_tbl(p_curr_index).distribution_id is not null) then
              if ( p_asset_dist_tbl(k).distribution_id =
                   p_asset_dist_tbl(p_curr_index).distribution_id)
                 then
                     raise dup_err;
              end if;
          end if;
      end if;

      -- Check for duplicate lines
      if ( nvl(p_asset_dist_tbl(k).assigned_to,-99) = nvl(p_asset_dist_tbl(p_curr_index).assigned_to,-99) and
           p_asset_dist_tbl(k).expense_ccid = p_asset_dist_tbl(p_curr_index).expense_ccid and
           p_asset_dist_tbl(k).location_ccid = p_asset_dist_tbl(p_curr_index).location_ccid)
               then
                 raise dup_err;
      end if;
  END LOOP;

  return true;

EXCEPTION

  WHEN dup_err THEN
         fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                 name       => 'FA_TFR_SAME_LINE', p_log_level_rec => p_log_level_rec);
    return false;

  WHEN OTHERS THEN

    fa_srvr_msg.add_sql_error(
          calling_fn => l_calling_fn , p_log_level_rec => p_log_level_rec);

    return false;

END validate_duplicate_dist;

FUNCTION validate_polish
   (p_transaction_type_code     IN    VARCHAR2,
    p_method_code               IN    VARCHAR2,
    p_life_in_months            IN    NUMBER   DEFAULT NULL,
    p_asset_type                IN    VARCHAR2 DEFAULT NULL,
    p_bonus_rule                IN    VARCHAR2 DEFAULT NULL,
    p_ceiling_name              IN    VARCHAR2 DEFAULT NULL,
    p_deprn_limit_type          IN    VARCHAR2 DEFAULT NULL,
    p_group_asset_id            IN    NUMBER   DEFAULT NULL,
    p_date_placed_in_service    IN    DATE     DEFAULT NULL,
    p_calendar_period_open_date IN    DATE     DEFAULT NULL,
    p_ytd_deprn                 IN    NUMBER   DEFAULT NULL,
    p_deprn_reserve             IN    NUMBER   DEFAULT NULL,
    p_calling_fn                IN    VARCHAR2,
    p_log_level_rec             IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN AS

   l_deprn_basis_rule     varchar2(80);
   l_polish_rule          number;
   l_calling_fn           varchar2(35) := 'fa_asset_val_pvt.validate_polish';

BEGIN

   -- First find out if we have a polish mechanism here
   if not fa_cache_pkg.fazccmt (
      X_method                => p_method_code,
      X_life                  => p_life_in_months
   , p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return FALSE;
   end if;

   if (fa_cache_pkg.fazccmt_record.deprn_basis_rule_id is not null) then
      l_polish_rule := fa_cache_pkg.fazcdbr_record.polish_rule;
   else
      -- No deprn basis rule attached to this method, so not Polish either
      return TRUE;
   end if;

   if (nvl(l_polish_rule, FA_STD_TYPES.FAD_DBR_POLISH_NONE)  not in (
                          FA_STD_TYPES.FAD_DBR_POLISH_1,
                          FA_STD_TYPES.FAD_DBR_POLISH_2,
                          FA_STD_TYPES.FAD_DBR_POLISH_3,
                          FA_STD_TYPES.FAD_DBR_POLISH_4,
                          FA_STD_TYPES.FAD_DBR_POLISH_5)) then
      -- Not Polish rule
      return TRUE;
   end if;

   -- This is a Polish rule, so start validations.
/*
   -- No adjustments allowed on Polish mechanisms.
   if (p_transaction_type_code in ('ADJUSTMENT', 'CIP ADJUSTMENT',
                                   'GROUP ADJUSTMENT')) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name       => 'FA_POLISH_NO_ADJ', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- No partial retirements allowed on Polish mechanisms.
   if (p_transaction_type_code = 'PARTIAL RETIREMENT') then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name       => 'FA_POLISH_NO_PARTIAL_RET', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;
*/
   -- No revaluations allowed on Polish mechanisms.
   if (p_transaction_type_code = 'REVALUATION') then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name       => 'FA_POLISH_NO_REVAL', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- No tax reserve adjustments allowed on Polish mechanisms.
   if (p_transaction_type_code = 'TAX RESERVE ADJUSTMENT') then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name       => 'FA_POLISH_NO_TAX_RSV_ADJ', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- No adding an Polish asset with reserve.
   if (p_transaction_type_code in ('ADDITION',
                                   'CIP ADDITION',
                                   'GROUP ADDITION')) then

      -- No backdated additions for Polish.
      if (p_date_placed_in_service < p_calendar_period_open_date) then
         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            name       => 'FA_POLISH_NO_PRIOR_ADD', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      -- No adding an Polish asset with reserve.
      if ((nvl(p_ytd_deprn,0) <> 0) OR (nvl(p_deprn_reserve,0) <> 0)) then
         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            name       => 'FA_POLISH_NO_ADD_RSV', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   if (p_transaction_type_code in ('ADDITION',
                                   'CIP ADDITION',
                                   'GROUP ADDITION',
                                   'ADJUSTMENT',
                                   'CIP ADJUSTMENT',
                                   'GROUP ADJUSTMENT')) then

      -- Mechanisms 1, 3, 4, 5 must have bonus rules attached
      if ((p_bonus_rule is null) and
          (l_polish_rule in (FA_STD_TYPES.FAD_DBR_POLISH_1,
                             FA_STD_TYPES.FAD_DBR_POLISH_3,
                             FA_STD_TYPES.FAD_DBR_POLISH_4,
                             FA_STD_TYPES.FAD_DBR_POLISH_5))) then

         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            name       => 'FA_POLISH_NO_BONUS_RULE', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      -- No ceilings allowed on Polish rules
      if (p_ceiling_name is not null) then
         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            name       => 'FA_POLISH_NO_CEILING', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      -- No depreciation limits allowed on Polish rules
      if (nvl(p_deprn_limit_type, 'NONE') <> 'NONE') then
         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            name       => 'FA_POLISH_NO_LIMIT', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      -- No group assets or members of group assets allowed to have Polish
      if (p_asset_type = 'GROUP') OR (p_group_asset_id is not null) then
         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            name       => 'FA_POLISH_NO_GROUP', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   return TRUE;

EXCEPTION
  WHEN OTHERS THEN

    fa_srvr_msg.add_sql_error( calling_fn => l_calling_fn , p_log_level_rec => p_log_level_rec);

    return FALSE;

END validate_polish;

FUNCTION validate_jp250db
   (p_transaction_type_code   IN    VARCHAR2,
    p_book_type_code          IN    VARCHAR2,
    p_asset_id                IN    NUMBER,
    p_method_code             IN    VARCHAR2,
    p_life_in_months          IN    NUMBER   DEFAULT NULL,
    p_asset_type              IN    VARCHAR2 DEFAULT NULL,
    p_bonus_rule              IN    VARCHAR2 DEFAULT NULL,
    p_transaction_key         IN    VARCHAR2 DEFAULT NULL,
    p_cash_generating_unit_id IN    VARCHAR2 DEFAULT NULL,
    p_deprn_override_flag     IN    VARCHAR2 DEFAULT 'N',
    p_calling_fn              IN    VARCHAR2,
    p_log_level_rec           IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN AS

   l_mrc_count            number := 0;
   l_override_count       number := 0;
   l_calling_fn           varchar2(35) := 'fa_asset_val_pvt.validate_jp250db';

BEGIN

   -- First find out if we have a jp 250db mechanism here
   if not fa_cache_pkg.fazccmt (
      X_method                => p_method_code,
      X_life                  => p_life_in_months
   , p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return FALSE;
   end if;

   if (nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') <>
'YES') then
      -- No guarantee rule attached to this method, so not JP 250DB either
      return TRUE;
   end if;

   if (p_transaction_type_code = 'REVALUATION') then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name       => 'FA_REVAL_DUAL_RATE', p_log_level_rec => p_log_level_rec);

      return FALSE;
   end if;

   select count(*)
   into   l_mrc_count
   from   fa_mc_book_controls
   where  book_type_code = p_book_type_code
   and    enabled_flag = 'Y';

   -- Fix for Bug #6334383.  Cannot use this method with MRC books.
   if (l_mrc_count > 0) then

      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name       => 'FA_MRC_DUAL_RATE', p_log_level_rec => p_log_level_rec);

      return FALSE;
   end if;

  /* Removed this resctriction for enhancement 6688475
   if (p_asset_type = 'CIP') then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name       => 'FA_CIP_DUAL_RATE', p_log_level_rec => p_log_level_rec);

      return FALSE;
   end if;
   */

   /* Japan Tax Phase3 -- Bonus is allowed
      Commenting the validation
   if (p_bonus_rule is not null) and (p_bonus_rule <> FND_API.G_MISS_CHAR) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name       => 'FA_BONUS_DUAL_RATE', p_log_level_rec => p_log_level_rec);

      return FALSE;
   end if; */

 /*Phase5 impairment is allowed on 250db Assets
 -- removing the validation to prevent Assigning of CGUs on assets using garauntee rate method*/

   return TRUE;

EXCEPTION
  WHEN OTHERS THEN

    fa_srvr_msg.add_sql_error( calling_fn => l_calling_fn , p_log_level_rec => p_log_level_rec);

    return FALSE;

END validate_jp250db;

FUNCTION validate_super_group (
   p_book_type_code       IN VARCHAR2,
   p_old_super_group_id   IN NUMBER,
   p_new_super_group_id   IN NUMBER,
   p_calling_fn           IN VARCHAR2,
   p_log_level_rec        IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN IS

   l_calling_fn           varchar2(40) := 'fa_asset_val_pvt.validate_super_group';

   CURSOR c_check_used is
      select 'Y'
      from   fa_super_group_rules
      where  super_group_id = p_new_super_group_id
      and    book_type_code = p_book_type_code
      and    used_flag = 'Y';

   l_used_flag   varchar2(1);

BEGIN

   if (not(nvl(p_old_super_group_id, -99) = nvl(p_new_super_group_id, -99))) then
      if (p_old_super_group_id is null) and
         (p_new_super_group_id is not null) then

         OPEN c_check_used;
         FETCH c_check_used INTO l_used_flag;

         if (c_check_used%FOUND) then

            CLOSE c_check_used;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'p_book_type_code', p_book_type_code, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'p_new_super_group_id', p_new_super_group_id, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'This Super group is used', 'TRUE', p_log_level_rec => p_log_level_rec);
            end if;

            fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                    name       => 'FA_SUPER_GROUP_USED', p_log_level_rec => p_log_level_rec);

            return FALSE;
         end if; -- (c_check_used%FOUND)

        CLOSE c_check_used;

      end if; -- (p_old_super_group_id is null) and

   end if;

   return true;

EXCEPTION
  WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'p_book_type_code', p_book_type_code, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'p_old_super_group_id', p_old_super_group_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'p_new_super_group_id', p_new_super_group_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION: OTHERS', sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_sql_error( calling_fn => l_calling_fn , p_log_level_rec => p_log_level_rec);

    return FALSE;
END validate_super_group;

FUNCTION validate_member_dpis
   (p_book_type_code           IN VARCHAR2,
    p_date_placed_in_service   IN DATE,
    p_group_asset_Id           IN NUMBER,
    p_calling_fn               IN VARCHAR2,
    p_log_level_rec            IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

  CURSOR c_group_dpis (p_group_asset_id NUMBER,
                       p_book_type_code VARCHAR2) is
   select date_placed_in_service
     from fa_books
    where asset_id = p_group_asset_id
      and book_type_code = p_book_type_code
      and transaction_header_id_out is null;

  l_group_dpis  date;
  l_calling_fn  varchar2(50) := 'fa_asset_val_pvt.validate_member_dpis';

BEGIN

   open  c_group_dpis(p_group_asset_Id, p_book_type_code);
   fetch c_group_dpis
    into l_group_dpis;
   close c_group_dpis;

   if (p_date_placed_in_service < l_group_dpis) then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              name       => 'FA_INVALID_MEMBER_DPIS',
                              token1     => 'DATE',
                              value1     => l_group_dpis, p_log_level_rec => p_log_level_rec);
      return false;
   else
      return true;
   end if;

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END validate_member_dpis;

FUNCTION validate_egy_prod_date (
   p_calendar_period_start_date IN DATE,
   p_transaction_date           IN DATE,
   p_transaction_key            IN VARCHAR2,
   p_rate_source_rule           IN VARCHAR2,
   p_rule_name                  IN VARCHAR2,
   p_calling_fn                 IN VARCHAR2,
   p_log_level_rec              IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN IS

   l_calling_fn    varchar2(50) := 'FA_ASSET_VAL_PVT.validate_egy_prod_date';

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'p_transaction_date', 'p_transaction_date', p_log_level_rec => p_log_level_rec);
   end if;

   if (p_calendar_period_start_date > p_transaction_date) and
      (p_rate_source_rule = 'PRODUCTION') and
      (p_rule_name = 'ENERGY PERIOD END BALANCE') and
      (nvl(p_transaction_key, 'NULL') <> 'MS') then

      fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_CURRENT_DATE_ONLY', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', ' ', p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
  WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'p_calendar_period_start_date', p_calendar_period_start_date, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'p_transaction_date', p_transaction_date, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'p_rate_source_rule', p_rate_source_rule, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'p_rule_name', p_rule_name, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION: OTHERS', sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_sql_error( calling_fn => l_calling_fn , p_log_level_rec => p_log_level_rec);

    return FALSE;
END validate_egy_prod_date;

-- Bug:5154035
FUNCTION validate_reval_exists (
    p_book_type_code IN   VARCHAR2,
    p_asset_Id       IN   NUMBER,
    p_calling_fn     IN   VARCHAR2,
    p_log_level_rec  IN   FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

  CURSOR c_reval_exists (l_asset_id NUMBER,
                         l_book_type_code VARCHAR2) is
     select 'x'
     from   FA_Transaction_Headers
     where  Asset_ID = l_asset_id
     and    Book_type_Code = l_book_type_code
     and    Transaction_Type_Code = 'REVALUATION';

  l_calling_fn  varchar2(50) := 'fa_asset_val_pvt.validate_reval_exists';
  l_reval_exists  varchar2(1);

BEGIN

   open  c_reval_exists(p_asset_id, p_book_type_code);
   fetch c_reval_exists into l_reval_exists;

   if (c_reval_exists%NOTFOUND) then
      close c_reval_exists;
      return false;
   end if;

   close c_reval_exists;

   return true;

EXCEPTION
   WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'p_asset_id', p_asset_id);
       fa_debug_pkg.add(l_calling_fn, 'p_book_type_code', p_book_type_code);
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION: OTHERS', sqlerrm);
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn);

    return false;
END validate_reval_exists;


/* Japan Tax Phase3 Prevent cost adjustment
   and method change for assets in extended depreciation */
FUNCTION validate_extended_asset (
   p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
   p_asset_fin_rec_old    IN     FA_API_TYPES.asset_fin_rec_type,
   p_asset_fin_rec_adj    IN     FA_API_TYPES.asset_fin_rec_type,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN IS

   l_calling_fn    varchar2(50) := 'FA_ASSET_VAL_PVT.validate_extended_asset';
   l_mrc_count     number := 0;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Enter ', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.cost', p_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.life_in_months', p_asset_fin_rec_adj.life_in_months, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.deprn_method_code',
                                        p_asset_fin_rec_adj.deprn_method_code, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.date_placed_in_service',
                                        p_asset_fin_rec_adj.date_placed_in_service, p_log_level_rec => p_log_level_rec);
   end if;

   if (nvl(p_asset_fin_rec_adj.cost,0) <> 0) then
      fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_JP_COST_CHG_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if (p_asset_fin_rec_old.deprn_method_code <> nvl(p_asset_fin_rec_adj.deprn_method_code,
                                                     p_asset_fin_rec_old.deprn_method_code)) then
      fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_JP_METHOD_CHG_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   select count(*)
   into   l_mrc_count
   from   fa_mc_book_controls
   where  book_type_code = p_asset_hdr_rec.book_type_code
   and    enabled_flag = 'Y';

   -- Cannot use extended deprn with MRC books.
   if (l_mrc_count > 0) then

      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name       => 'FA_JP_MRC_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);

      return FALSE;
   end if;

   -- Bug 6625840 prevent salvage value change
   if (nvl(p_asset_fin_rec_adj.percent_salvage_value, 0) <> 0 or
       nvl(p_asset_fin_rec_adj.salvage_value, 0) <> 0)then
      fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_JP_SALVAGE_CHG_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Bug 6625840 prevent deprn_limit change
   if (nvl(p_asset_fin_rec_adj.allowed_deprn_limit_amount, 0) <> 0 or
       nvl(p_asset_fin_rec_adj.allowed_deprn_limit, 0) <> 0) then
      fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_JP_LIMIT_CHG_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Bug 6669432 prevent DPIS change
   if (p_asset_fin_rec_old.date_placed_in_service <> nvl(p_asset_fin_rec_adj.date_placed_in_service,
                                                     p_asset_fin_rec_old.date_placed_in_service)) then
      fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_JP_DPIS_CHG_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', ' ', p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
  WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'p_asset_hdr_rec.asset_id', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.cost', p_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.deprn_method_code',
                                        p_asset_fin_rec_adj.deprn_method_code, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION: OTHERS', sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_sql_error( calling_fn => l_calling_fn , p_log_level_rec => p_log_level_rec);

    return FALSE;
END validate_extended_asset;

/** Japan Tax Reform ER No.s 6606548 and 6606552
   Validation of additional fields **/

-- Bug#7698030 Start
FUNCTION validate_JP_STL_EXTND(
                    p_prior_deprn_method   IN VARCHAR2 DEFAULT NULL,
                    p_prior_basic_rate     IN NUMBER   DEFAULT NULL,
                    p_prior_adjusted_rate  IN NUMBER   DEFAULT NULL,
                    p_prior_life_in_months IN NUMBER   DEFAULT NULL,
                    p_calling_fn           IN VARCHAR2,
                    p_log_level_rec        IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN IS

  cursor lcu_deprn_method(p_prior_deprn_method in varchar2)
  is

  select count('1')
  from fa_methods fm
  where fm.method_code = p_prior_deprn_method;

CURSOR l_life_in_months(p_method         IN VARCHAR2
                         ,p_life_in_months IN NUMBER
                         )
  IS
  select count(1)
  from fa_methods fm
  where fm.method_code    = p_method
  and   fm.life_in_months = p_life_in_months;

CURSOR lc_depr_rates(p_method              IN VARCHAR2
                      ,p_prior_basic_rate    IN NUMBER
                      ,p_prior_adjusted_rate IN NUMBER )
  IS
  select count(1)
  from fa_methods    fm
      ,fa_flat_rates ffr
  where fm.method_code    = p_method
  and   ffr.method_id     = fm.method_id
  and   ffr.basic_rate    = p_prior_basic_rate
  and   ffr.adjusted_rate = p_prior_adjusted_rate;

TYPE l_msg_error_rec IS RECORD(mass_addition_id  NUMBER
                                ,exception_code    VARCHAR2(10)
                                );
  TYPE l_msg_error_tbl IS TABLE OF l_msg_error_rec INDEX BY BINARY_INTEGER;

  l_error_msg             l_msg_error_tbl;
  l_dummy_cnt             number := 0;
  l_count                 number := 1;
  l_exception_code        varchar2(100);
  l_calling_fn    varchar2(50) := 'fa_asset_val_pvt.validate_JP_STL_EXTND';
  validate_ex             exception;

BEGIN

    l_exception_code     := null;

    if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(p_calling_fn,
                          'performing','JP-STL-EXTND method validation', p_log_level_rec => p_log_level_rec);

    end if;

      l_dummy_cnt := 0;
      if p_prior_deprn_method is not null then
        open lcu_deprn_method(p_prior_deprn_method);
        fetch lcu_deprn_method into l_dummy_cnt;
        close lcu_deprn_method;
        if l_dummy_cnt = 0 then
           fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_SHARED_OBJECT_NOT_DEF',
                TOKEN1     => 'OBJECT',
                VALUE1     => 'Method', p_log_level_rec => p_log_level_rec);
            return FALSE;

        else
          if (p_prior_basic_rate is null or p_prior_adjusted_rate is null) and (p_prior_life_in_months is null) then
            fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_RATES_LIFE_IN_MONTHS_NUL'
                                    , p_log_level_rec => p_log_level_rec);
            return FALSE;
          elsif p_prior_life_in_months is not null then
            l_dummy_cnt := 0;
            open l_life_in_months(p_prior_deprn_method
                                 ,p_prior_life_in_months
                                 );
            fetch l_life_in_months into l_dummy_cnt;
            close l_life_in_months;
            if l_dummy_cnt = 0 then
               fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_SHARED_INVALID_METHOD_LIFE'
                                    , p_log_level_rec => p_log_level_rec);
              return FALSE;
            end if;
          elsif p_prior_basic_rate is not null and  p_prior_adjusted_rate is not null then
            l_dummy_cnt := 0;
            open lc_depr_rates(p_prior_deprn_method
                              ,p_prior_basic_rate
                              ,p_prior_adjusted_rate
                              );
            fetch lc_depr_rates into l_dummy_cnt;
            close lc_depr_rates;
            if l_dummy_cnt = 0 then
               fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_SHARED_INVALID_METHOD_RATE'
                                    , p_log_level_rec => p_log_level_rec);
              return FALSE;
            end if;
          end if;
        end if;


      end if;


    return TRUE;
exception
 WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;
 END validate_JP_STL_EXTND;


FUNCTION validate_earl_deprn_limit(
                    p_prior_deprn_limit_amount IN NUMBER   DEFAULT NULL,
                    p_prior_deprn_limit        IN NUMBER   DEFAULT NULL,
                    p_prior_deprn_limit_type   IN VARCHAR2 DEFAULT NULL,
                    p_calling_fn               IN VARCHAR2,
                    p_log_level_rec            IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN IS

  TYPE l_msg_error_rec IS RECORD(mass_addition_id  NUMBER
                                ,exception_code    VARCHAR2(10)
                                );
  TYPE l_msg_error_tbl IS TABLE OF l_msg_error_rec INDEX BY BINARY_INTEGER;

  l_error_msg            l_msg_error_tbl;



  l_count                 number := 1;
  l_exception_code        varchar2(100);
  l_calling_fn    varchar2(50) := 'fa_asset_val_pvt.validate_earl_deprn_limit';
  validate_ex             exception;


BEGIN
      l_exception_code     := null;


      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(p_calling_fn,
                          'performing','Earlier depreciable limit Validation', p_log_level_rec => p_log_level_rec);
      end if;

      if p_prior_deprn_limit_type in ('AMT','PCT') then
        if ( (p_prior_deprn_limit_amount is null) and (p_prior_deprn_limit is null) ) then
           fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_ADI_INVALID_DEPRNLIMIT_TYPE'
                                    , p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;
      else
        fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_ADI_INVALID_DEPRNLIMIT_TYPE'
                                    , p_log_level_rec => p_log_level_rec);
           return FALSE;
      end if;

      return TRUE;
exception
WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END validate_earl_deprn_limit;

FUNCTION validate_period_fully_reserved(
                    p_book_type_code         IN VARCHAR2,
                    p_pc_fully_reserved      IN NUMBER   DEFAULT NULL,
                    p_date_placed_in_service IN DATE,
                    p_calling_fn             IN VARCHAR2,
                    p_log_level_rec          IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN IS

  cursor lcu_period_info(p_book_type_code in varchar2
                          ,p_period_ctr     in number
                          )
    is
    select fcp.end_date
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
    and (ffy.fiscal_year *  fct.number_per_fiscal_year + fcp.period_num) = p_period_ctr;

  cursor lcu_curr_open_period(p_book_type_code in varchar2
                               )
    is
    select fdp.calendar_period_close_date
    from fa_book_controls fbc
        ,fa_deprn_periods fdp
    where fbc.book_type_code = fdp.book_type_code
    and   fdp.period_counter = fbc.last_period_counter+1
    and   fbc.book_type_code =  p_book_type_code;

  TYPE l_msg_error_rec IS RECORD(mass_addition_id  NUMBER
                                ,exception_code    VARCHAR2(10)
                                );
  TYPE l_msg_error_tbl IS TABLE OF l_msg_error_rec INDEX BY BINARY_INTEGER;

  l_error_msg             l_msg_error_tbl;

  l_period_end_dt         date;
  l_current_period_dt     date;
  l_calling_fn    varchar2(50) := 'fa_asset_val_pvt.validate_period_fully_reserved';
  l_count                 number := 1;
  l_exception_code        varchar2(100);
  validate_ex             exception;


BEGIN

    l_exception_code     := null;

    open lcu_curr_open_period(p_book_type_code
                             );
    fetch lcu_curr_open_period into l_current_period_dt;
    close lcu_curr_open_period;


      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(p_calling_fn,
                          'performing','Period when fully reserved validation', p_log_level_rec => p_log_level_rec);
      end if;

      if p_pc_fully_reserved is null then
         fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_FULLY_RESERVED_PC_NULL'
                                    , p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      l_period_end_dt := null;
      open lcu_period_info(p_book_type_code
                          ,p_pc_fully_reserved
                          );
      fetch lcu_period_info into l_period_end_dt;
      close lcu_period_info;
      if   (l_period_end_dt is null) then
        fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_PERIOD_ENDDATE_NULL'
                                    , p_log_level_rec => p_log_level_rec);
        return FALSE;

      elsif (trunc(l_period_end_dt) < trunc(p_date_placed_in_service)) then
        fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_ENDDATE_EARLY_DPIS'
                                    , p_log_level_rec => p_log_level_rec);
        return FALSE;

      elsif (trunc(l_period_end_dt) > trunc(l_current_period_dt) ) then

        fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_ENDDATE_GREATER_CUR_DATE'
                                    , p_log_level_rec => p_log_level_rec);
        return FALSE;
      end if;


      return TRUE;
exception
WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END validate_period_fully_reserved;

FUNCTION validate_fst_prd_extd_deprn(
                    p_book_type_code          IN VARCHAR2,
                    p_extended_deprn_period   IN NUMBER   DEFAULT NULL,
                    p_date_placed_in_service  IN DATE,
                    p_calling_fn              IN VARCHAR2,
                    p_log_level_rec           IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN IS

  cursor lcu_period_info(p_book_type_code in varchar2,
                         p_period_ctr     in number) is
    select fcp.end_date
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
    and (ffy.fiscal_year *  fct.number_per_fiscal_year + fcp.period_num) = p_period_ctr;

  TYPE l_msg_error_rec IS RECORD(mass_addition_id  NUMBER
                                ,exception_code    VARCHAR2(10)
                                );
  TYPE l_msg_error_tbl IS TABLE OF l_msg_error_rec INDEX BY BINARY_INTEGER;

  l_error_msg             l_msg_error_tbl;
  l_calling_fn    varchar2(50) := 'fa_asset_val_pvt.validate_fst_prd_extd_deprn';
  l_period_end_dt         date;
  l_default_dt            date := to_date('01-04-2007','DD-MM-RRRR');



  l_count                 number := 1;
  l_exception_code        varchar2(100);
  validate_ex             exception;


BEGIN

      l_exception_code     := null;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(p_calling_fn,
                          'performing','First period of extended depreciation validation', p_log_level_rec => p_log_level_rec);
      end if;

      l_period_end_dt := null;
      open lcu_period_info(p_book_type_code
                          ,p_extended_deprn_period
                          );
      fetch lcu_period_info into l_period_end_dt;
      close lcu_period_info;
      if l_period_end_dt is null then
         fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_PERIOD_ENDDATE_NULL'
                                , p_log_level_rec => p_log_level_rec);
         return FALSE;
      elsif  (trunc(l_period_end_dt) < trunc(l_default_dt)) then
         fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_PERIOD_ENDDATE_WRONG'
                                , p_log_level_rec => p_log_level_rec);
         return FALSE;
      elsif  (trunc(l_period_end_dt) < trunc(p_date_placed_in_service)) then
        fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_ENDDATE_EARLY_DPIS'
                                , p_log_level_rec => p_log_level_rec);
        return FALSE;
      end if;

      return TRUE;
exception
WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;



END validate_fst_prd_extd_deprn;

FUNCTION validate_NOT_JP_STL_EXTND(
                    p_book_type_code         IN VARCHAR2,
                    p_deprn_limit            IN NUMBER   DEFAULT NULL,
                    p_sp_deprn_limit         IN NUMBER   DEFAULT NULL,
                    p_deprn_reserve          IN NUMBER   DEFAULT NULL,
                    p_asset_type             IN VARCHAR2 DEFAULT NULL,
                    p_pc_fully_reserved      IN NUMBER   DEFAULT NULL,
                    p_date_placed_in_service IN DATE,
                    p_cost                   IN NUMBER   DEFAULT NULL,
                    p_calling_fn             IN VARCHAR2,
                    p_log_level_rec          IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

  TYPE l_msg_error_rec IS RECORD(mass_addition_id  NUMBER
                                ,exception_code    VARCHAR2(10)
                                );
  TYPE l_msg_error_tbl IS TABLE OF l_msg_error_rec INDEX BY BINARY_INTEGER;

  l_error_msg             l_msg_error_tbl;

  l_count                 number := 1;
  l_period_end_dt         date;
  l_current_period_dt     date;
  l_amt                   number;
  l_exception_code        varchar2(100);
  l_calling_fn    varchar2(50) := 'fa_asset_val_pvt.validate_NOT_JP_STL_EXTND';
  validate_ex             exception;

cursor lcu_period_info(p_book_type_code in varchar2
                        ,p_period_ctr     in number
                        )
  is
  select fcp.end_date
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
  and (ffy.fiscal_year *  fct.number_per_fiscal_year + fcp.period_num) = p_period_ctr;

cursor lcu_curr_open_period(p_book_type_code in varchar2
                             )
  is
  select fdp.calendar_period_close_date
  from fa_book_controls fbc
      ,fa_deprn_periods fdp
  where fbc.book_type_code = fdp.book_type_code
  and   fdp.period_counter = fbc.last_period_counter+1
  and   fbc.book_type_code =  p_book_type_code;


BEGIN

    l_exception_code     := null;

    if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(p_calling_fn,
                                    'performing','NOT-JP-STL_EXTND validation', p_log_level_rec => p_log_level_rec);
    end if;

    open lcu_curr_open_period(p_book_type_code
                                 );
        fetch lcu_curr_open_period into l_current_period_dt;
    close lcu_curr_open_period;
    if p_deprn_limit is not null then
          l_amt := NVL(p_cost,0) * NVL(p_deprn_limit,0);
          l_amt := NVL(p_cost,0) - l_amt;
    end if;
    if p_sp_deprn_limit is not null then
          l_amt := NVL(p_sp_deprn_limit,0);
    end if;
    if NVL(p_cost,0) <> 0 AND NVL(p_cost,0) - NVL(l_amt,0) - NVL(p_deprn_reserve,0)  = 0 then   --- BUG# 7368126 "NVL(p_cost,0) > 0 AND" is added to avoid the erroring out of Mass Additions post program, if the Asset cost = 0
                --check with the nbv <= 0 then period full resrve is mandatory
      if p_asset_type NOT IN ( 'GROUP','CIP') then                                             --- BUG# 7368126 "p_asset_type NOT IN ( 'GROUP','CIP')" is added to avoid the erroring out of Mass Additions post program, if the Asset_type is  GROUP, CIP
        if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(p_calling_fn,
                                    'performing','First period of extended depreciation validation', p_log_level_rec => p_log_level_rec);
        end if;
        --Bug7114834 Changed the condition that checks for null p_pc_fully_reserved
        if p_pc_fully_reserved is not null then

                l_period_end_dt := null;
                 open lcu_period_info(p_book_type_code
                                    ,p_pc_fully_reserved
                                    );
                fetch lcu_period_info into l_period_end_dt;
                close lcu_period_info;
                if  (trunc(l_period_end_dt) < trunc(p_date_placed_in_service)) then
                         fa_srvr_msg.add_message(
                         CALLING_FN => l_calling_fn,
                         NAME       => 'FA_JP_ENDDATE_EARLY_DPIS'
                                    , p_log_level_rec => p_log_level_rec);
                         return FALSE;
                elsif (trunc(l_period_end_dt) > trunc(l_current_period_dt) ) then
                  fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_ENDDATE_GREATER_CUR_DATE'
                                    , p_log_level_rec => p_log_level_rec);
                         return FALSE;
                 end if;
        end if; --p_pc_fully_reserved is not null
      end if;  -- p_asset_type NOT IN ( 'GROUP','CIP')
    end if;

    return TRUE;
exception
WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END validate_NOT_JP_STL_EXTND;

FUNCTION validate_JP_250_DB(
                    p_deprn_method_code IN VARCHAR2 DEFAULT NULL,
                    p_cost              IN NUMBER   DEFAULT NULL,
                    p_nbv_at_switch     IN NUMBER   DEFAULT NULL,
                    p_deprn_reserve     IN NUMBER   DEFAULT NULL,
                    p_ytd_deprn         IN NUMBER   DEFAULT NULL,
                    p_calling_fn        IN VARCHAR2,
                    p_log_level_rec     IN FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN IS

 cursor lcu_rates_info(p_method_code in varchar2)
   is
   select ff.original_rate
         ,ff.revised_rate
         ,ff.guarantee_rate
   from fa_formulas ff
       ,fa_methods fm
   where ff.method_id = fm.method_id
   and fm.method_code = p_method_code;

  TYPE l_msg_error_rec IS RECORD(mass_addition_id  NUMBER
                                ,exception_code    VARCHAR2(10)
                                );
  TYPE l_msg_error_tbl IS TABLE OF l_msg_error_rec INDEX BY BINARY_INTEGER;

  l_error_msg  l_msg_error_tbl;

  l_count                 number := 1;
  l_nbv                   number := 0;
  l_exception_code        varchar2(100);
  l_calling_fn    varchar2(50) := 'fa_asset_val_pvt.validate_JP_250_DB';
  validate_ex           exception;

  l_rates_info_rec        lcu_rates_info%rowtype;

BEGIN

    l_exception_code     := null;

    if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(p_calling_fn,
                                            'performing','JP 250 DB validation', p_log_level_rec => p_log_level_rec);
    end if;

    -- bug7668308:Added ytd, in order to calculate correct NBV.
    l_nbv      := NVL(p_cost,0) - (NVL(p_deprn_reserve,0) - NVL(p_ytd_deprn,0));





    open lcu_rates_info(p_deprn_method_code);
    fetch lcu_rates_info into l_rates_info_rec;

      -- Bug:7668308:Added trunc to calculate correct rate in use.
    if (trunc(NVL(p_cost,0) * l_rates_info_rec.guarantee_rate)) > (trunc(l_nbv*l_rates_info_rec.original_rate)) then

      if p_nbv_at_switch is null then
                  fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_NBV_NULL'
                                    , p_log_level_rec => p_log_level_rec);
        return FALSE;
      end if;
      if p_nbv_at_switch < 0 then
                  fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_NBV_NEGATIVE'
                                    , p_log_level_rec => p_log_level_rec);
        return FALSE;
      end if;
      if p_nbv_at_switch > NVL(p_cost,0) then
                  fa_srvr_msg.add_message(
                CALLING_FN => l_calling_fn,
                NAME       => 'FA_JP_NBV_GREATER_COST'
                                    , p_log_level_rec => p_log_level_rec);
        return FALSE;
      end if;

    end if;
    close lcu_rates_info;


    return TRUE;
exception
WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;


END validate_JP_250_DB;
--Bug#7698030 End

--Bug 7260056 Negative transfer amount allowed based on depreciate_option
FUNCTION validate_reserve_transfer (
    p_book_type_code  IN    VARCHAR2 DEFAULT NULL,
    p_asset_id        IN    NUMBER   DEFAULT NULL,
    p_transfer_amount IN    NUMBER   DEFAULT 0,
    p_calling_fn      IN    VARCHAR2,
    p_log_level_rec   IN    FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

  cursor c_get_books_info(c_asset_id number,
                          c_book_type_code varchar2) IS
  select over_depreciate_option
  from   fa_books
  where  asset_id = c_asset_id
  and    book_type_code = c_book_type_code
  and    transaction_header_id_out is null;

  l_over_depreciate_option    varchar2(30);

BEGIN

  if (p_transfer_amount is not null) then
      OPEN c_get_books_info(p_asset_id,p_book_type_code);
      FETCH c_get_books_info INTO l_over_depreciate_option;
      CLOSE c_get_books_info;

       if (p_transfer_amount = 0) then
        fa_srvr_msg.add_message(
            calling_fn => p_calling_fn,
            name       => 'FA_ZERO_RESERVE_TRANSFER_AMOUNT', p_log_level_rec => p_log_level_rec);
        return FALSE;
       elsif ( p_transfer_amount < 0 ) and
       (l_over_depreciate_option = 'NO' or l_over_depreciate_option is NULL ) then
         fa_srvr_msg.add_message(
             calling_fn => p_calling_fn,
             name       => 'FA_NEGATIVE_RESERVE_TRANSFER_AMOUNT_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
          return FALSE;
       end if;

 end if; -- transfer_amount

 return true;

EXCEPTION
  WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(p_calling_fn, 'p_asset_id', p_asset_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(p_calling_fn, 'p_book_type_code', p_book_type_code, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(p_calling_fn, 'EXCEPTION: OTHERS', sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => p_calling_fn, p_log_level_rec => p_log_level_rec);
    return FALSE;
END validate_reserve_transfer;

/* Bug#7693266- To validate change of salvage_type or deprn_limit_type of group asset */
FUNCTION validate_sal_deprn_sum (
    p_asset_hdr_rec     IN FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_old IN FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj IN FA_API_TYPES.asset_fin_rec_type,
    p_log_level_rec     IN FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

   CURSOR c_mem_exists IS
      select 1
      from   fa_books
      where  group_asset_id = p_asset_hdr_rec.asset_id
      and    book_type_code = p_asset_hdr_rec.book_type_code
      and    transaction_header_id_out is null;

   l_calling_fn    varchar2(50) := 'FA_ASSET_VAL_PVT.validate_sal_deprn_sum';
   l_dummy   NUMBER;
   l_valid_parameter            BOOLEAN := TRUE;

BEGIN
    /* Checking for salvage_type and deprn_limit_type changed to SUM for group asset with member */
    if (((p_asset_fin_rec_adj.salvage_type = 'SUM') and
        (p_asset_fin_rec_adj.salvage_type <> nvl(p_asset_fin_rec_old.salvage_type,
                                                  p_asset_fin_rec_adj.salvage_type))) or
       ((p_asset_fin_rec_adj.deprn_limit_type = 'SUM') and
        (p_asset_fin_rec_adj.deprn_limit_type <> nvl(p_asset_fin_rec_old.deprn_limit_type,
                                                     p_asset_fin_rec_adj.deprn_limit_type)))) then

          if (p_asset_fin_rec_adj.cost = 0) then
             OPEN c_mem_exists;
             FETCH c_mem_exists INTO l_dummy;
             CLOSE c_mem_exists;
             if (l_dummy > 0) then
                fa_srvr_msg.add_message(
                        calling_fn => l_calling_fn,
                        name =>'FA_MEMBER_EXIST_IN_GROUP');
                l_valid_parameter := FALSE;
             else
                return TRUE;
             end if;
          else
             l_valid_parameter := FALSE;
          end if;
          if (not l_valid_parameter) then
             if (p_asset_fin_rec_adj.salvage_type = 'SUM') then
                 fa_srvr_msg.add_message(
                        calling_fn => l_calling_fn,
                        name       => 'FA_INVALID_PARAMETER',
                        token1     => 'VALUE',
                        value1     => p_asset_fin_rec_adj.salvage_type,
                        token2     => 'PARAM',
                        value2     => 'SALVAGE_TYPE',
                        p_log_level_rec => p_log_level_rec);
             else
                 fa_srvr_msg.add_message(
                        calling_fn => l_calling_fn,
                        name       => 'FA_INVALID_PARAMETER',
                        token1     => 'VALUE',
                        value1     => p_asset_fin_rec_adj.deprn_limit_type,
                        token2     => 'PARAM',
                        value2     => 'DEPRN_LIMIT_TYPE',
                        p_log_level_rec => p_log_level_rec);
             end if;
             return FALSE;
           end if;
     end if; -- End of SUM loop

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', ' ');
   end if;

   return TRUE;

EXCEPTION
  WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'p_asset_hdr_rec.asset_id', p_asset_hdr_rec.asset_id);
       fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.salvage_type', p_asset_fin_rec_adj.salvage_type);
       fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.deprn_limit_type',
                                       p_asset_fin_rec_adj.deprn_limit_type);
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION: OTHERS', sqlerrm);
    end if;
    fa_srvr_msg.add_sql_error( calling_fn => l_calling_fn );
    return FALSE;

END validate_sal_deprn_sum;

FUNCTION validate_impairment_exists
  (p_asset_id           IN     number,
   p_book               IN     varchar2,
   p_mrc_sob_type_code  IN     varchar2,
   p_set_of_books_id    IN     number,
   p_log_level_rec      IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_check_imp_flag varchar(15);
   l_period_rec     FA_API_TYPES.period_rec_type;

   CURSOR c_mc_check_imp is
        select 'POSTED'
        from   fa_mc_impairments
        where  status = 'POSTED'
        and    (asset_id   = p_asset_id or cash_generating_unit_id = (select cash_generating_unit_id
                                                                  from fa_mc_books bk
                                                                  where bk.asset_id = p_asset_id
                                                                  and   bk.book_type_code = p_book
                                                                  and   bk.date_ineffective is null))
        and    book_type_code = p_book
        AND PERIOD_COUNTER_IMPAIRED = l_period_rec.period_counter
        AND set_of_books_id = p_set_of_books_id;

   CURSOR c_check_imp is
        select 'POSTED'
        from   fa_impairments
        where  status = 'POSTED'
        and    (asset_id   = p_asset_id or cash_generating_unit_id = (select cash_generating_unit_id
                                                                  from fa_books bk
                                                                  where bk.asset_id = p_asset_id
                                                                  and   bk.book_type_code = p_book
                                                                  and   bk.date_ineffective is null))
        and    book_type_code = p_book
        AND PERIOD_COUNTER_IMPAIRED = l_period_rec.period_counter;

BEGIN
   if (NOT FA_UTIL_PVT.get_period_rec (
       p_book           => p_book,
       p_effective_date => NULL,
       x_period_rec     => l_period_rec,
       p_log_level_rec  => p_log_level_rec -- Bug:5475024
      )) then
      return false;
   end if;

   if (p_mrc_sob_type_code = 'R') then
      OPEN c_mc_check_imp;
      FETCH c_check_imp INTO l_check_imp_flag;
      CLOSE c_check_imp;
   else
      OPEN c_check_imp;
      FETCH c_check_imp INTO l_check_imp_flag;
      CLOSE c_check_imp;
   end if;
   if nvl(l_check_imp_flag,'NOTPOSTED') = 'POSTED' then
      fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcbsx',
                              name       => 'FA_IMPAIR_ROLLBACK_TRX',
                              token1     => 'FA_ASSET_ID',
                              value1     => to_char(p_asset_id),
                   p_log_level_rec => p_log_level_rec);
      return false;
    end if;
    return true;
end validate_impairment_exists;

/*Bug# 8527619 This function is called from public APIs to check if group will become over depreciate
  NBV should not have sign different than cost, when over_depreciation_option is set to NO*/
FUNCTION validate_over_depreciation (
    p_asset_hdr_rec        IN   FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec        IN   FA_API_TYPES.asset_fin_rec_type default null,
    p_validation_type      IN   varchar2,
    p_cost_adj             IN   number,
    p_rsv_adj              IN   number,
    p_asset_retire_rec     IN   FA_API_TYPES.asset_retire_rec_type default null,
    p_log_level_rec        IN   FA_API_TYPES.log_level_rec_type default null
   )  RETURN BOOLEAN IS

   l_calling_fn    varchar2(50) := 'FA_ASSET_VAL_PVT.validate_over_depreciation';
   l_deprn_reserve             number :=0;
   l_deprn_reserve_mem         number := 0;
   l_ytd_deprn                 number;
   dummy_num                   number;
   dummy_char                  varchar2(10);
   dummy_bool                  boolean;l_over_drpn_opt varchar2(3);
   l_new_group_cost            number := 0;
   l_new_group_reserve         number := 0;
   l_new_mem_cost              number := 0;
   l_new_mem_reserve           number := 0;
   l_group_cost                number := 0;

   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_hdr_rec_mem FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec_grp FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_mem FA_API_TYPES.asset_fin_rec_type;
   l_mem_asset_deprn_rec fa_api_types.asset_deprn_rec_type;
   l_grp_asset_deprn_rec fa_api_types.asset_deprn_rec_type;
   add_err1 exception;

BEGIN
   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'validate_over_depreciation', 'BEGINS', p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_validation_type', p_validation_type, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_cost_adj', p_cost_adj, p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_rsv_adj', p_rsv_adj, p_log_level_rec);
   end if;

   l_asset_hdr_rec     := p_asset_hdr_rec;
   l_asset_hdr_rec_mem := p_asset_hdr_rec;
   if p_validation_type <> 'RECLASS_DEST' then /*passing header for group only */
      l_asset_hdr_rec.asset_id :=  p_asset_fin_rec.group_asset_id ;
   end if;
   l_asset_fin_rec_mem := p_asset_fin_rec;

   --Fetch group record.
   if not FA_UTIL_PVT.get_asset_fin_rec
                    (p_asset_hdr_rec         => l_asset_hdr_rec,
                     px_asset_fin_rec        => l_asset_fin_rec_grp,
                     p_transaction_header_id => NULL,
                     p_mrc_sob_type_code     => 'P',
                     p_log_level_rec         => p_log_level_rec) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'ERROR', 'Calling get_asset_fin_rec',
                          p_log_level_rec => p_log_level_rec);
      end if;
      raise add_err1;
   end if;

   --Initialize cache
   if not fa_cache_pkg.fazccmt
                 (X_method => l_asset_fin_rec_grp.deprn_method_code,
                  X_life   => l_asset_fin_rec_grp.life_in_months) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'ERROR', 'Calling fazccmt',
                          p_log_level_rec => p_log_level_rec);
      end if;
      raise add_err1;
   end if;

   /*Need to do following validation only for
   -energy (UOP/STL) group
   -Over Depreciation - Do not Allow
   -tracking method - Allocate /
                    - CALCULATE and not sumup.*/

   if ( fa_cache_pkg.fazccmt_record.rate_source_rule = 'PRODUCTION' ) and
      (p_asset_fin_rec.group_Asset_id is not null OR p_validation_type = 'RECLASS_DEST'  ) and
      (l_asset_fin_rec_grp.tracking_method = ('ALLOCATE') OR
      (l_asset_fin_rec_grp.tracking_method = 'CALCULATE' and
        nvl(l_asset_fin_rec_grp.member_rollup_flag, 'N') = 'N')) and
      (l_asset_fin_rec_grp.over_depreciate_option = fa_std_types.FA_OVER_DEPR_NO ) then

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'Inside IF', 'Need to validate', p_log_level_rec);
      end if;

      if not FA_UTIL_PVT.get_asset_deprn_rec
                 (p_asset_hdr_rec         => l_asset_hdr_rec,
                  px_asset_deprn_rec      => l_grp_asset_deprn_rec,
                  p_period_counter        => NULL,
                  p_mrc_sob_type_code     => 'P',
                  p_log_level_rec    => p_log_level_rec
                 ) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'ERROR', 'Calling get_asset_deprn_rec',
                          p_log_level_rec => p_log_level_rec);
         end if;
         raise add_err1;
      end if;

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'group id:reserve:', l_asset_hdr_rec.asset_id || ' : ' || l_grp_asset_deprn_rec.deprn_reserve, p_log_level_rec);
      end if;
      if p_validation_type = 'RETIREMENT' then
         l_new_group_cost := nvl(l_asset_fin_rec_grp.cost,0) - nvl(p_cost_adj,0);
         /*if last member reserve will be cleared by terminal gain/loss */
         if l_asset_fin_rec_grp.cost <> p_asset_fin_rec.cost then
            l_new_group_reserve := nvl(l_grp_asset_deprn_rec.deprn_reserve,0) - nvl(p_rsv_adj,0);
         end if;

      elsif  p_validation_type = 'ADDITION' then
         l_new_group_cost := nvl(l_asset_fin_rec_grp.cost,0) + nvl(p_cost_adj,0);
         l_new_group_reserve := nvl(l_grp_asset_deprn_rec.deprn_reserve,0) + nvl(l_deprn_reserve_mem,0);

      elsif  p_validation_type = 'ADJUSTMENT' then

         if not FA_UTIL_PVT.get_asset_fin_rec
                    (p_asset_hdr_rec         => l_asset_hdr_rec_mem,
                     px_asset_fin_rec        => l_asset_fin_rec_mem,
                     p_transaction_header_id => NULL,
                     p_mrc_sob_type_code     => 'P',
                     p_log_level_rec           => p_log_level_rec) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'ERROR', 'Calling get_asset_fin_rec',
                          p_log_level_rec => p_log_level_rec);
            end if;
            raise add_err1;
          end if;

         if not FA_UTIL_PVT.get_asset_deprn_rec
                 (p_asset_hdr_rec         => l_asset_hdr_rec_mem,
                  px_asset_deprn_rec      => l_mem_asset_deprn_rec,
                  p_period_counter        => NULL,
                  p_mrc_sob_type_code     => 'P',
                  p_log_level_rec    => p_log_level_rec
                 ) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'ERROR', 'Calling get_asset_deprn_rec',
                          p_log_level_rec => p_log_level_rec);
            end if;
            raise add_err1;
         end if;
         if p_log_level_rec.statement_level then
            fa_debug_pkg.add(l_calling_fn, 'Member asset id:cost:reserve:', l_asset_hdr_rec_mem.asset_id || ' : ' || l_asset_fin_rec_mem.cost || ' : ' || l_mem_asset_deprn_rec.deprn_reserve, p_log_level_rec);
         end if;
         /*Bug 8754829 -start*/
         if (p_cost_adj = 0) then
            l_new_group_cost := nvl(l_asset_fin_rec_grp.cost,0) + nvl(l_asset_fin_rec_mem.cost,0);
            l_new_group_reserve := nvl(l_grp_asset_deprn_rec.deprn_reserve,0) + nvl(l_mem_asset_deprn_rec.deprn_reserve,0);
         else
            l_new_mem_cost := nvl(p_cost_adj,0) + nvl(l_asset_fin_rec_mem.cost,0);
            l_new_mem_reserve := nvl(l_mem_asset_deprn_rec.deprn_reserve,0);
            if (l_new_mem_cost = 0 and l_new_mem_reserve <> 0) OR
 	            (l_new_mem_cost > l_new_mem_reserve and l_new_mem_cost < 0 ) OR
 	            (l_new_mem_cost < l_new_mem_reserve and l_new_mem_cost > 0 ) then

 	            fa_srvr_msg.add_message(calling_fn => l_calling_fn
 	                           ,name       => 'FA_NOT_VALID_MEM_TRANSACTION'
 	                           ,token1     => 'ASSET_NUMBER',
 	                            value1     => l_asset_hdr_rec_mem.asset_id
 	                           ,p_log_level_rec => p_log_level_rec);
 	            return false;
 	         end if;
         end if;
         /*Bug 8754829 -end*/
      elsif  p_validation_type = 'REINSTATEMENT' then

         if p_asset_retire_rec.recognize_gain_loss = 'NO' then
            l_new_group_cost := nvl(l_asset_fin_rec_grp.cost,0) + nvl(p_asset_retire_rec.cost_retired,0);
            l_new_group_reserve := nvl(l_grp_asset_deprn_rec.deprn_reserve,0) + nvl(p_asset_retire_rec.cost_retired,0);
         elsif p_asset_retire_rec.recognize_gain_loss = 'YES' then
            l_new_group_cost := nvl(l_asset_fin_rec_grp.cost,0) + nvl(p_asset_retire_rec.cost_retired,0);
            l_new_group_reserve := nvl(l_grp_asset_deprn_rec.deprn_reserve,0) + nvl(p_asset_retire_rec.reserve_retired,0);
         END IF;
      elsif  p_validation_type = 'RECLASS_SOURCE' then
         l_new_group_cost := nvl(l_asset_fin_rec_grp.cost,0) - nvl(p_cost_adj,0);
         l_new_group_reserve := nvl(l_grp_asset_deprn_rec.deprn_reserve,0) - nvl(p_rsv_adj,0);
      elsif  p_validation_type = 'RECLASS_DEST' then
         l_new_group_cost := nvl(l_asset_fin_rec_grp.cost,0) + nvl(p_cost_adj,0);
         l_new_group_reserve := nvl(l_grp_asset_deprn_rec.deprn_reserve,0) + nvl(p_rsv_adj,0);
      end if;

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'validate_over_depreciation l_new_group_cost', l_new_group_cost, p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'validate_over_depreciation l_new_group_reserve', l_new_group_reserve, p_log_level_rec);
      end if;

      if (l_new_group_cost = 0 and l_new_group_reserve <> 0) OR
         (l_new_group_cost > l_new_group_reserve and l_new_group_cost < 0 ) OR
         (l_new_group_cost < l_new_group_reserve and l_new_group_cost > 0 ) then
         fa_srvr_msg.add_message(calling_fn => l_calling_fn
                              ,name       => 'FA_NOT_VALID_TRANSACTION'
                              ,token1     => 'ASSET_NUMBER',
                               value1     => l_asset_hdr_rec.asset_id
                              ,p_log_level_rec => p_log_level_rec);
         return false;
      end if;
   end if;
   return TRUE;

EXCEPTION
   WHEN add_err1 then
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'ERROR executing ',l_calling_fn,p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'Asset id :',l_asset_hdr_rec_mem.asset_id,p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'Book type code :',p_asset_hdr_rec.book_type_Code,p_log_level_rec);
    end if;
    return false;
   WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'EXCEPTION: OTHERS', sqlerrm);
    end if;
    fa_srvr_msg.add_sql_error( calling_fn => l_calling_fn );
    return FALSE;
END validate_over_depreciation;

FUNCTION validate_grp_track_method(
           p_asset_fin_rec_old         IN fa_api_types.asset_fin_rec_type,
           p_asset_fin_rec_new         IN fa_api_types.asset_fin_rec_type,
	   p_group_reclass_options_rec IN fa_api_types.group_reclass_options_rec_type,
	   p_log_level_rec             IN fa_api_types.log_level_rec_type DEFAULT NULL) RETURN BOOLEAN IS

   BEGIN

     IF (NVL(p_asset_fin_rec_old.group_asset_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) AND
        (NVL(p_asset_fin_rec_new.group_asset_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) THEN
        IF NVL(p_asset_fin_rec_old.tracking_method, FND_API.G_MISS_CHAR) <>
	                      NVL(p_asset_fin_rec_new.tracking_method, FND_API.G_MISS_CHAR) AND
           (p_group_reclass_options_rec.group_reclass_type = 'CALC') THEN
           FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN      => 'FA_ASSET_VAL_PVT.validate_grp_track_method',
                                   NAME            => 'FA_GRP_RCL_TRACK_MISMATCH',
                                   TOKEN1          => 'EXISTING_TRACK_METHOD',
                                   VALUE1          => p_asset_fin_rec_old.tracking_method,
                                   p_log_level_rec => p_log_level_rec);
           RETURN FALSE;
	ELSE
	   RETURN TRUE;
	END IF;
     END IF;

   RETURN TRUE;

END validate_grp_track_method;

/* Bug#8584206-To validate type of transactions allowed on Energy UOP assets  */
FUNCTION validate_energy_transactions (
   p_trans_rec            IN     FA_API_TYPES.trans_rec_type,
   p_asset_type_rec       IN     FA_API_TYPES.asset_type_rec_type default null,
   p_asset_fin_rec_old    IN     FA_API_TYPES.asset_fin_rec_type default null,
   p_asset_fin_rec_adj    IN     FA_API_TYPES.asset_fin_rec_type  default null,
   p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

   l_asset_fin_rec   FA_API_TYPES.asset_fin_rec_type;
   l_asset_type_rec  FA_API_TYPES.asset_type_rec_type;
   l_group_asset_fin_rec   FA_API_TYPES.asset_fin_rec_type;
   l_group_asset_hdr_rec   FA_API_TYPES.asset_hdr_rec_type;
   h_asset_id number;

   CURSOR c_group_mem_no_depreciate is
    select count(1) from dual
    where exists
    (select 'x' from fa_books
    where book_type_code = p_asset_hdr_rec.book_type_code
    and   group_asset_id = h_asset_id
    and   transaction_header_id_out is null
    and   depreciate_flag = 'NO');
   l_dummy_num number;

   CURSOR c_asset_with_reserve is
    select count(1) from dual
    where exists
    (select 'x' from fa_deprn_summary
    where book_type_code = p_asset_hdr_rec.book_type_code
    and   asset_id = p_asset_hdr_rec.asset_id
    and   deprn_source_code = 'BOOKS'
    and   deprn_reserve > 0);
    l_dummy_num_rsv number;

   l_calling_fn         varchar2(100)  := 'FA_ASSET_VAL_PVT.validate_egy_trans';
   val_err              exception;

BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'begin', '', p_log_level_rec);
   end if;

   l_asset_fin_rec := p_asset_fin_rec_old;
   l_asset_type_rec := p_asset_type_rec;

   -- First load asset type cache it is null
   IF l_asset_type_rec.asset_type is NULL Then
      if not FA_UTIL_PVT.get_asset_type_rec(p_asset_hdr_rec      => p_asset_hdr_rec,
                                            px_asset_type_rec    => l_asset_type_rec,
                                            p_date_effective     => NULL,
                                            p_log_level_rec      => p_log_level_rec) then
         raise val_err;
      end if;

      IF (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'loaded asset type cache', '', p_log_level_rec);
      END IF;
   END IF;

   -- Next load finrec in case of it is null
   IF l_asset_fin_rec.cost is NULL Then
      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'asset_fin_rec is NULL', '', p_log_level_rec);
      end if;

      IF not FA_UTIL_PVT.get_asset_fin_rec(p_asset_hdr_rec         => p_asset_hdr_rec,
                                           px_asset_fin_rec        => l_asset_fin_rec,
                                           p_transaction_header_id => NULL,
                                           p_mrc_sob_type_code     => 'P',
                                           p_log_level_rec         => p_log_level_rec) then
         raise val_err;
      END IF;

      IF (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'loaded finreec cache', '', p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec.cost', l_asset_fin_rec.cost, p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec.group_asset_id',
                          nvl(l_asset_fin_rec.group_asset_id,-100), p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec.depreciate_flag',
                          l_asset_fin_rec.depreciate_flag, p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'complete finreec cache', '', p_log_level_rec);
      END IF;
   END IF;

   --Load method cache
   if (not fa_cache_pkg.fazccmt(l_asset_fin_rec.deprn_method_code,
                                l_asset_fin_rec.life_in_months,
                                p_log_level_rec => p_log_level_rec)) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazccmt', p_log_level_rec);
      end if;

      raise val_err;
   end if;

   IF (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'loaded method cache : source_rule',
                       fa_cache_pkg.fazccmt_record.rate_source_rule, p_log_level_rec);
   END IF;

   IF fa_cache_pkg.fazccmt_record.rate_source_rule = 'PRODUCTION' THEN
      IF l_asset_type_rec.asset_type = 'CAPITALIZED' THEN
         -- During reclass into group, Group should have tracking method of ALLOCATE if asset is added with reserve.
         IF (nvl(l_asset_fin_rec.group_asset_id, FND_API.G_MISS_NUM) =  FND_API.G_MISS_NUM and
             nvl(p_asset_fin_rec_adj.group_asset_id, FND_API.G_MISS_NUM) <>  FND_API.G_MISS_NUM ) THEN  -- reclass case
            open c_asset_with_reserve;
            fetch c_asset_with_reserve into l_dummy_num_rsv;
            close c_asset_with_reserve;

            IF l_dummy_num_rsv = 1 THEN
               l_group_asset_hdr_rec.asset_id := p_asset_fin_rec_adj.group_asset_id;
               l_group_asset_hdr_rec.book_type_code := p_asset_hdr_rec.book_type_code;

               IF not FA_UTIL_PVT.get_asset_fin_rec(p_asset_hdr_rec         => l_group_asset_hdr_rec,
                                                    px_asset_fin_rec        => l_group_asset_fin_rec,
                                                    p_transaction_header_id => NULL,
                                                    p_mrc_sob_type_code     => 'P',
                                                    p_log_level_rec         => p_log_level_rec) then
                  raise val_err;
               END IF;

               IF nvl(l_group_asset_fin_rec.tracking_method,'ZZZ') <> 'ALLOCATE' THEN
                  fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                          name            => 'FA_PROD_MEM_NO_ALLOCATE',
                                          p_log_level_rec => p_log_level_rec);
                  return FALSE;
               END IF;
            END IF; -- l_dummy_num_rsv = 1
         END IF; -- reclass case

         -- Asset cannot be reclassed out of group if it was added with reserve when depreciate_flag = YES
         IF (l_asset_fin_rec.depreciate_flag = 'YES' and
             nvl(l_asset_fin_rec.group_asset_id, FND_API.G_MISS_NUM) <>  FND_API.G_MISS_NUM and
             p_asset_fin_rec_adj.group_asset_id =  FND_API.G_MISS_NUM ) THEN -- reclass out case

               open c_asset_with_reserve;
               fetch c_asset_with_reserve into l_dummy_num_rsv;
               close c_asset_with_reserve;

               IF l_dummy_num_rsv = 1 THEN
                  fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                          name            => 'FA_PROD_MEM_NO_CAP_RESV',
                                          p_log_level_rec => p_log_level_rec);
                  return FALSE;
               END IF;
         END IF; -- p_asset_fin_rec.depreciate_flag = 'YES'

         -- Validations when depreciate_flag = 'NO'
         IF l_asset_fin_rec.depreciate_flag = 'NO' THEN

            -- No transaction allowed on members asset with depreciate_flag = 'NO' except,
            -- a) moving out of group b) Setting depreciate_flag = 'YES'
            IF nvl(l_asset_fin_rec.group_asset_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

               IF (nvl(p_asset_fin_rec_adj.group_asset_id,-99) <> FND_API.G_MISS_NUM AND
                   nvl(p_asset_fin_rec_adj.depreciate_flag,'NO') <> 'YES' ) THEN
                  fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                          name            => 'FA_PROD_MEM_INVALID_TRANS',
                                          p_log_level_rec => p_log_level_rec);
                  return FALSE;
               END IF;
            ELSE

               -- Do not allow to depreciate_flag = YES on standalone asset
               -- if it is created with reserve. Other transactions allowed
               IF (nvl(p_asset_fin_rec_adj.depreciate_flag,'NO') = 'YES' ) THEN
                  open c_asset_with_reserve;
                  fetch c_asset_with_reserve into l_dummy_num_rsv;
                  close c_asset_with_reserve;

                  IF l_dummy_num_rsv = 1 THEN
                     fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                             name            => 'FA_PROD_CAP_DEPRN_RESV',
                                             p_log_level_rec => p_log_level_rec);
                     return FALSE;
                  END IF;
               END IF;
            END IF; -- nvl(l_asset_fin_rec.group_asset_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
         ELSE
            -- Check if member's group has any other members with depreciate_flag = NO. If so, raise error.
            -- Allowed transactions for such cases is, setting depreciating flag = NO and group reclass
            --   (out or assign to other group)

            IF ( nvl(p_asset_fin_rec_adj.depreciate_flag,'YES') = 'YES' and
                 nvl(l_asset_fin_rec.group_asset_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM and
                 nvl(p_asset_fin_rec_adj.group_asset_id,l_asset_fin_rec.group_asset_id) <>
                                                                           FND_API.G_MISS_NUM and
                 nvl(p_asset_fin_rec_adj.group_asset_id,l_asset_fin_rec.group_asset_id) =
                                                              l_asset_fin_rec.group_asset_id) THEN

               h_asset_id := l_asset_fin_rec.group_asset_id;

               open c_group_mem_no_depreciate;
               fetch c_group_mem_no_depreciate into l_dummy_num;
               close c_group_mem_no_depreciate;

               IF l_dummy_num = 1 THEN
                  fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                          name            => 'FA_PROD_GRP_NO_DEPR_FLAG',
                                          p_log_level_rec => p_log_level_rec);
                  return FALSE;
               END IF;
            END IF;
         END IF; --l_asset_fin_rec.depreciate_flag = 'NO'

      END IF; --l_asset_type_rec.asset_type = 'CAPITALIZED'

      IF l_asset_type_rec.asset_type = 'GROUP' THEN

         IF (nvl(p_trans_rec.transaction_key, 'NULL') <> 'GC') THEN

            h_asset_id := p_asset_hdr_rec.asset_id;

            open c_group_mem_no_depreciate;
            fetch c_group_mem_no_depreciate into l_dummy_num;
            close c_group_mem_no_depreciate;

            IF l_dummy_num = 1 THEN
               fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                       name            => 'FA_PROD_GRP_NO_DEPR_FLAG',
                                       p_log_level_rec => p_log_level_rec);
               return FALSE;
            END IF;

         END IF;

      END IF; --l_asset_type_rec.asset_type = 'GROUP'

   END IF; --fa_cache_pkg.fazccmt_record.rate_source_rule = 'PRODUCTION'

   return true;

EXCEPTION
   WHEN val_err THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              name       => 'ERROR executing : '|| l_calling_fn,
                              p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn);
      return false;

END validate_energy_transactions;

/* Bug#8633654-To validate type of transactions allowed on Energy UOP assets  */
FUNCTION validate_mbr_reins_possible (
      p_asset_retire_rec     IN     FA_API_TYPES.asset_retire_rec_type,
      p_asset_fin_rec        IN     FA_API_TYPES.asset_fin_rec_type,
      p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

      l_calling_fn         varchar2(100)  := 'FA_ASSET_VAL_PVT.validate_mbr_reins_possible';


      /* Cursor to get retirement adjustment happened during retirement */
      cursor c_ret_adj_amount is
         select nvl(sum(decode(debit_credit_flag,'DR',adjustment_amount,-1*adjustment_amount)),0) ret_adj_amount
         from   fa_transaction_headers th    -- member
             , fa_transaction_headers gth -- group
             , fa_adjustments aj
         where  th.book_type_code = p_asset_retire_rec.detail_info.book_type_code
         and    th.source_transaction_header_id = gth.transaction_header_id
         and    gth.book_type_code = p_asset_retire_rec.detail_info.book_type_code
         and    gth.member_transaction_header_id = p_asset_retire_rec.detail_info.transaction_header_id_in
         and    aj.asset_id = th.asset_id
         and    aj.book_type_code = p_asset_retire_rec.detail_info.book_type_code
         and    aj.transaction_header_id  = th.transaction_header_id;


      /* Cursor to get sum of all members adjusted cost */
      cursor c_mbr_adjusted_cost is
         select nvl(sum(bk.adjusted_cost),0) mbr_sum_adj_cost
         from   fa_books bk
         where  bk.book_type_code = p_asset_retire_rec.detail_info.book_type_code
         and    bk.transaction_header_id_out is null
         and    bk.group_asset_id = p_asset_fin_rec.group_asset_id;

     /* Cursor to get details during retirement, we have to use cursor as retire_rec will not provide salvage details*/
      cursor c_ret_mem_details is
         select bk.cost,nvl(bk.salvage_value,0)
         from   fa_books bk
         where  bk.book_type_code = p_asset_retire_rec.detail_info.book_type_code
         and    bk.asset_id = p_asset_retire_rec.detail_info.asset_id
         and    bk.transaction_header_id_out = p_asset_retire_rec.detail_info.transaction_header_id_in;

      /* Cursor to get last pending retirment for the group */
      cursor c_last_ret_mem_details is
         select ad.asset_id, ad.asset_number,
                ret.transaction_header_id_in
         from  fa_retirements ret,
               fa_additions_b ad
         where ret.book_type_code = p_asset_retire_rec.detail_info.book_type_code
         and   ad.asset_id = ret.asset_id
         and   ret.transaction_header_id_in =
                (select max(far.transaction_header_id_in)
                from    fa_retirements far,
                        fa_books bk
                where   far.book_type_code = p_asset_retire_rec.detail_info.book_type_code
                and     far.asset_id = bk.asset_id
                and     bk.book_type_code = p_asset_retire_rec.detail_info.book_type_code
                and     bk.group_asset_id = p_asset_fin_rec.group_asset_id
                and     bk.transaction_header_id_out is null
                and     far.status = 'PROCESSED');


      /* Cursor to get group cost */
      cursor c_grp_cost is
         select bk.cost
         from   fa_books bk
         where  bk.book_type_code = p_asset_retire_rec.detail_info.book_type_code
         and    bk.asset_id = p_asset_fin_rec.group_asset_id
         and    bk.transaction_header_id_out is null;


      l_ret_adj_amount number;
      l_mbr_sum_adj_cost number;
      l_ret_cost number;
      l_ret_salvage_value number;
      l_max_ret_adj_reverse number;
      l_max_ret_trx_id number;
      l_last_asset_id fa_additions_b.asset_id%type;
      l_last_asset_num fa_additions_b.asset_number%type;
      l_grp_cost fa_books.cost%type;

      val_err exception;


BEGIN
      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.add(l_calling_fn, 'bein', ' ', p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'retirement_id : recognize_gain_loss',
                         p_asset_retire_rec.retirement_id ||':'|| p_asset_retire_rec.recognize_gain_loss,
                         p_log_level_rec);
      END IF;

      IF p_asset_retire_rec.recognize_gain_loss = 'YES' THEN
         return TRUE;
      END IF;

      open c_ret_adj_amount;
      fetch c_ret_adj_amount into l_ret_adj_amount;
      close c_ret_adj_amount;

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.add(l_calling_fn, 'l_ret_adj_amount', l_ret_adj_amount, p_log_level_rec);
      END IF;

      if l_ret_adj_amount = 0 THEN
         return TRUE;
      end if;


      /* check if group cost is zero. That means, this reinstatement is first after retirement */
      open c_grp_cost;
      fetch c_grp_cost into l_grp_cost;
      close c_grp_cost;
      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.add(l_calling_fn, 'l_grp_cost', l_grp_cost, p_log_level_rec);
      END IF;
      if (l_grp_cost = 0) then
         open c_last_ret_mem_details;
         fetch c_last_ret_mem_details into l_last_asset_id,l_last_asset_num,l_max_ret_trx_id;
         close c_last_ret_mem_details;
         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn, 'l_last_asset_id', l_last_asset_id, p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_last_asset_num', l_last_asset_num, p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_max_ret_trx_id', l_max_ret_trx_id, p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'detail_info.transaction_header_id_in', p_asset_retire_rec.detail_info.transaction_header_id_in,
                            p_log_level_rec);
         END IF;

         if nvl(l_max_ret_trx_id,-99) <> p_asset_retire_rec.detail_info.transaction_header_id_in then
            fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_EGY_REINS_LAST_RET',
               token1     => 'ASSET_NUMBER',
                value1     => l_last_asset_num
               );
              raise val_err;
         end if;

      end if;

      open c_mbr_adjusted_cost;
      fetch c_mbr_adjusted_cost into l_mbr_sum_adj_cost;
      close c_mbr_adjusted_cost;

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.add(l_calling_fn, 'l_mbr_adjusted_cost', l_mbr_sum_adj_cost,p_log_level_rec);
      END IF;

      open c_ret_mem_details;
      fetch c_ret_mem_details into l_ret_cost, l_ret_salvage_value;
      close c_ret_mem_details;

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.add(l_calling_fn, 'p_asset_retire_rec.cost_retired', p_asset_retire_rec.cost_retired,p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_asset_retire_rec.reserve_retired', p_asset_retire_rec.reserve_retired,p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_ret_salvage_value', l_ret_salvage_value,p_log_level_rec);
      END IF;


      l_max_ret_adj_reverse := nvl(l_mbr_sum_adj_cost,0) + p_asset_retire_rec.cost_retired -
                               nvl(p_asset_retire_rec.reserve_retired,0) - nvl(l_ret_salvage_value,0);

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.add(l_calling_fn, 'l_max_ret_adj_reverse', l_max_ret_adj_reverse,p_log_level_rec);
      END IF;

      if l_ret_adj_amount*sign(l_ret_adj_amount) > l_max_ret_adj_reverse*sign(l_max_ret_adj_reverse) then
         fa_srvr_msg.add_message(
            calling_fn => l_calling_fn,
            name       => 'FA_EGY_REINS_NOT_POSSIBLE');
         raise val_err;
      end if;

      return TRUE;

EXCEPTION
   WHEN val_err THEN
      fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                              name            => 'ERROR executing : '|| l_calling_fn,
                              p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn);
      return false;

END validate_mbr_reins_possible;

-- Bug 8722521 : Validation for Japan methods during Tax upload
FUNCTION validate_jp_taxupl (
   p_trans_rec            IN     FA_API_TYPES.trans_rec_type,
   p_asset_type_rec       IN     FA_API_TYPES.asset_type_rec_type,
   p_asset_fin_rec        IN     FA_API_TYPES.asset_fin_rec_type,
   p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
   p_asset_deprn_rec      IN     FA_API_TYPES.asset_deprn_rec_type,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS


   --Bug# 7608030 start
   l_p_rsv_counter         number;
   l_ext_period_counter    number;
   l_fiscal_yr             number;
   l_period_num            number;
   l_num_fy_yr             number;
   l_period_end_dt         date;
   l_current_period_dt     date;
   l_default_dt            date := to_date('01-04-2007','DD-MM-RRRR');
   --#Bug 7608030 end

  -- Bug 7698030 start open period
  cursor l_curr_open_period(p_book_type_code in varchar2
                           )
  is
  select fdp.calendar_period_close_date
  from fa_book_controls fbc
      ,fa_deprn_periods fdp
  where fbc.book_type_code = fdp.book_type_code
  and   fdp.period_counter = fbc.last_period_counter+1
  and   fbc.book_type_code =  p_book_type_code;

  --7608030 full reserv counter
  cursor l_period_info(p_book_type_code in varchar2
                      ,p_period         in number   -- Bug 9131620
                      )
  is
  select fcp.end_date
        ,ffy.fiscal_year
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
  and (fcp.period_num + (fct.number_per_fiscal_year * ffy.fiscal_year)) = p_period;  -- Bug 9131620

    --Bug 7698030 end

   -- Exceptions

   val_error           EXCEPTION;
   l_calling_fn         varchar2(100)  := 'FA_ASSET_VAL_PVT.validate_jp_taxupl';

Begin

   if p_asset_fin_rec.deprn_method_code='JP-STL-EXTND' then
      if not fa_asset_val_pvt.validate_JP_STL_EXTND(
         p_prior_deprn_method       => p_asset_fin_rec.prior_deprn_method,
         p_prior_basic_rate         => p_asset_fin_rec.prior_basic_rate,
         p_prior_adjusted_rate      => p_asset_fin_rec.prior_adjusted_rate,
         p_prior_life_in_months     => p_asset_fin_rec.prior_life_in_months,
         p_calling_fn               => l_calling_fn,
         p_log_level_rec            => p_log_level_rec) then

         raise val_error;

      end if;
         -- end validate JP-STL-EXTND
         /*For Jp-STL-EXTD we also need to
          * validate Erlier depreciation limit,
          * Period fully reserved
          * Early first period extended depreciation
          */

         -- start validate_earl_deprn_limit
      if not fa_asset_val_pvt.validate_earl_deprn_limit(
         p_prior_deprn_limit_amount => p_asset_fin_rec.prior_deprn_limit_amount,
         p_prior_deprn_limit        => p_asset_fin_rec.prior_deprn_limit,
         p_prior_deprn_limit_type   => p_asset_fin_rec.prior_deprn_limit_type,
         p_calling_fn               => l_calling_fn,
         p_log_level_rec            => p_log_level_rec) then

         raise val_error;

      end if;
         -- end validate_earl_deprn_limit

        /*
        * For period fully reserv counter
        */
      l_period_end_dt := null;
      l_period_num    := null;
      l_num_fy_yr     := null;
      l_p_rsv_counter := null;
      open l_period_info(p_asset_hdr_rec.book_type_code
                        ,p_asset_fin_rec.period_counter_fully_reserved);  -- Bug 9131620
      fetch l_period_info into l_period_end_dt
                              ,l_fiscal_yr
                              ,l_period_num
                              ,l_num_fy_yr;
      close l_period_info;

      --Fetching the current open Period
      open l_curr_open_period(p_asset_hdr_rec.book_type_code);
      fetch l_curr_open_period into l_current_period_dt;
      close l_curr_open_period;

      if (trunc(l_period_end_dt) < trunc(p_asset_fin_rec.date_placed_in_service)) then
         fa_srvr_msg.add_message( CALLING_FN => l_calling_fn,
                                  NAME       => 'FA_JP_ENDDATE_EARLY_DPIS'
                                , p_log_level_rec => p_log_level_rec);
         raise val_error;
      elsif (trunc(l_period_end_dt) > trunc(l_current_period_dt) ) then
         fa_srvr_msg.add_message( CALLING_FN => l_calling_fn,
                                  NAME       => 'FA_JP_ENDDATE_GREATER_CUR_DATE'
                                , p_log_level_rec => p_log_level_rec);
         raise val_error;
      elsif l_period_end_dt is null then
         fa_srvr_msg.add_message(CALLING_FN => l_calling_fn,
                                 NAME       => 'FA_JP_PERIOD_ENDDATE_NULL'
                               , p_log_level_rec => p_log_level_rec);
         raise val_error;
      else
         l_p_rsv_counter := (l_fiscal_yr * l_num_fy_yr) + l_period_num; --  end
      end if;

      -- start validate_period_fully_reserved
      if not fa_asset_val_pvt.validate_period_fully_reserved(
                        p_book_type_code           => p_asset_hdr_rec.book_type_code,
                        p_pc_fully_reserved        => l_p_rsv_counter,
                        p_date_placed_in_service   => p_asset_fin_rec.date_placed_in_service,
                        p_calling_fn               => l_calling_fn,
                        p_log_level_rec            => p_log_level_rec) then

         raise val_error;
      end if;
      -- end validate_period_fully_reserved

         -- Start extd deprn period

      l_period_end_dt      := null;
      l_period_num         := null;
      l_period_end_dt      := null;
      l_num_fy_yr          := null;
      l_ext_period_counter := null;
      open l_period_info(p_asset_hdr_rec.book_type_code
                        ,p_asset_fin_rec.extended_depreciation_period);  -- Bug 9131620
      fetch l_period_info into l_period_end_dt
                              ,l_fiscal_yr
                              ,l_period_num
                              ,l_num_fy_yr;
      close l_period_info;

     if l_period_end_dt is null then
        fa_srvr_msg.add_message(
                    CALLING_FN => l_calling_fn,
                    NAME       => 'FA_JP_PERIOD_ENDDATE_NULL'
                        , p_log_level_rec => p_log_level_rec);
             raise val_error;
     elsif (trunc(l_period_end_dt) < trunc(l_default_dt)) then
             fa_srvr_msg.add_message(
                    CALLING_FN => l_calling_fn,
                    NAME       => 'FA_JP_PERIOD_ENDDATE_WRONG'
                        , p_log_level_rec => p_log_level_rec);
             raise val_error;
     elsif (trunc(l_period_end_dt) < trunc(p_asset_fin_rec.date_placed_in_service)) then
            fa_srvr_msg.add_message(
                    CALLING_FN => l_calling_fn,
                    NAME       => 'FA_JP_ENDDATE_EARLY_DPIS'
                        , p_log_level_rec => p_log_level_rec);
              raise val_error;
     else
          l_ext_period_counter := (l_fiscal_yr * l_num_fy_yr) + l_period_num; --  end
     end if;

           -- Start validate_fst_prd_extd_deprn
       if not fa_asset_val_pvt.validate_fst_prd_extd_deprn(
            p_book_type_code           => p_asset_hdr_rec.book_type_code,
            p_extended_deprn_period    => l_ext_period_counter,
            p_date_placed_in_service   => p_asset_fin_rec.date_placed_in_service,
            p_calling_fn               => l_calling_fn,
            p_log_level_rec            => p_log_level_rec) then

             raise val_error;

       end if;
           --- end validate_fst_prd_extd_deprn
   end if;
       -- End of JP-STL-EXTD method validation

       -- Start of Not JP STL EXTD validation
   /*if p_asset_fin_rec.deprn_method_code <> 'JP-STL-EXTND' then

           -- start validate_NOT_JP_STL_EXTND
       if not fa_asset_val_pvt.validate_NOT_JP_STL_EXTND(
              p_book_type_code           => p_asset_hdr_rec.book_type_code,
                      p_deprn_limit              => l_asset_fin_rec_adj.allowed_deprn_limit,
              p_sp_deprn_limit           => l_asset_fin_rec_adj.allowed_deprn_limit_amount,
              p_deprn_reserve            => p_asset_deprn_rec.deprn_reserve,
              p_asset_type               => l_asset_type(l_loop_count),
              p_pc_fully_reserved        => l_p_rsv_counter,
              p_date_placed_in_service   => p_asset_fin_rec.date_placed_in_service,
              p_cost                     => p_asset_fin_rec.cost,
              p_mass_addition_id         => l_request_id,
              p_calling_fn               => l_calling_fn,
            p_log_level_rec            => p_log_level_rec) then

             raise val_error;
     end if;

     end if; */
       -- Start of Not JP STL EXTD validation

       -- Start Validation for JP 250 DB methods
   if p_asset_fin_rec.deprn_method_code like 'JP%250DB%' then

     if not fa_asset_val_pvt.validate_JP_250_DB(
              p_deprn_method_code        => p_asset_fin_rec.deprn_method_code,
              p_cost                     => p_asset_fin_rec.cost,
              p_nbv_at_switch            => p_asset_fin_rec.nbv_at_switch,
              p_deprn_reserve            => p_asset_deprn_rec.deprn_reserve,
              p_ytd_deprn                => p_asset_deprn_rec.ytd_deprn,
              p_calling_fn               => l_calling_fn,
              p_log_level_rec            => p_log_level_rec) then

            raise val_error;
     end if;

   end if;

   return TRUE;

   EXCEPTION
      WHEN val_error THEN
         fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                 name       => 'ERROR executing : '|| l_calling_fn);
      return FALSE;

     WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn);
       return false;

END validate_jp_taxupl;

--Bug 8828394 - Group Asset ID should be valid Group Asset ID
FUNCTION validate_group_asset_id(
 p_asset_id             IN   NUMBER,
 p_log_level_rec        IN   FA_API_TYPES.log_level_rec_type default null
) RETURN BOOLEAN IS

l_count number;

BEGIN
   l_count := null;

   begin
      select 1
      into l_count
      from dual
      where exists (select 'X'
                      from fa_additions_b
                     where asset_id = p_asset_id
                       and asset_type = 'GROUP');
   exception
      when no_data_found then
         l_count := null;
   end;

   if l_count is null then
      fa_srvr_msg.add_message(
                  calling_fn => 'fa_asset_val_pvt.validate_group_asset_id',
                  name       => 'FA_INV_GROUP_ASSET_ID');
      return false;
   end if;

   return true;
END validate_group_asset_id;

-- Bug 8471701
FUNCTION validate_ltd_deprn_change (
    p_book_type_code       IN   VARCHAR2,
    p_asset_Id             IN   NUMBER,
    p_calling_fn           IN   VARCHAR2,
    p_log_level_rec        IN   FA_API_TYPES.log_level_rec_type
   ) RETURN BOOLEAN IS

CURSOR c_check_dist IS
select count(1)
from fa_deprn_detail fdd,
     fa_distribution_history fdh
where fdd.distribution_id = fdh.distribution_id
and fdd.book_type_code = p_book_type_code
and fdd.asset_id = p_asset_Id
and fdd.deprn_source_code = 'B'
and fdh.transaction_header_id_out is not null;

l_inactive_dist   NUMBER := 0;
BEGIN
   -- Check if any of the distributions for B row are inactive.
   -- If any, do not allow the reserve change transaction.
   OPEN c_check_dist;
   FETCH c_check_dist INTO l_inactive_dist;
   CLOSE c_check_dist;

   if (l_inactive_dist > 0) then
       fa_srvr_msg.add_message(
               calling_fn => p_calling_fn,
               name =>'FA_INVALID_RESERVE_CHANGE',
               p_log_level_rec => p_log_level_rec);

       return false;
   else
       return true;
   end if;

EXCEPTION
   WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(p_calling_fn, 'p_asset_id', p_asset_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(p_calling_fn, 'p_book_type_code', p_book_type_code, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(p_calling_fn, 'EXCEPTION: OTHERS', sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => p_calling_fn, p_log_level_rec => p_log_level_rec);

    return false;
END validate_ltd_deprn_change;
-- End Bug 8471701

/*phase5 This function will validate if current transaction is overlapping to any previously done impairment*/
FUNCTION check_overlapping_impairment (
   p_trans_rec            IN     FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

  --l_imp_exists            VARCHAR2(1) := 'N';
  l_imp_exists            number := 0;
  l_calling_fn            varchar2(100)  := 'FA_ASSET_VAL_PVT.check_overlapping_impairment';

BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'begin', '', p_log_level_rec);
   end if;

   BEGIN
      /*Bug 9718441  replacing this validation with new validation which will restrict user
        to do any transaction for which transaction date/ amortization date falls in or
	before the end of fiscal year in which any impairment is done. As this is a temporary
	fix so not removing the existing validation once we get the permanent solution
	we will replace back this validation.*/
      /*

      SELECT 'Y'
      INTO l_imp_exists
      FROM
      FA_TRANSACTION_HEADERS FATH,
      FA_DEPRN_PERIODS FADP
      WHERE FATH.BOOK_TYPE_CODE = p_asset_hdr_rec.BOOK_TYPE_CODE
      AND FATH.ASSET_ID = p_asset_hdr_rec.ASSET_ID
      AND FADP.BOOK_TYPE_CODE = FATH.BOOK_TYPE_CODE
      AND FATH.TRANSACTION_KEY = 'IM'
      AND FATH.TRANSACTION_DATE_ENTERED BETWEEN FADP.calendar_period_open_date AND NVL(FADP.calendar_period_close_date, SYSDATE)
      AND NVL (p_trans_rec.AMORTIZATION_START_DATE,p_trans_rec.TRANSACTION_DATE_ENTERED) <= NVL(FADP.calendar_period_close_date, SYSDATE);

      */

      SELECT count(*)
      INTO l_imp_exists
      FROM
      FA_TRANSACTION_HEADERS FATH,
      FA_DEPRN_PERIODS FADP,
      FA_BOOK_CONTROLS FABC,
      FA_CALENDAR_TYPES FACL,
      FA_FISCAL_YEAR FAFY
      WHERE FATH.BOOK_TYPE_CODE = p_asset_hdr_rec.BOOK_TYPE_CODE
      AND FATH.ASSET_ID = p_asset_hdr_rec.ASSET_ID
      AND FABC.BOOK_TYPE_CODE = p_asset_hdr_rec.BOOK_TYPE_CODE
      AND FACL.CALENDAR_TYPE = FABC.DEPRN_CALENDAR
      AND FAFY.FISCAL_YEAR_NAME = FACL.FISCAL_YEAR_NAME
      AND FADP.BOOK_TYPE_CODE = FATH.BOOK_TYPE_CODE
      AND FATH.TRANSACTION_KEY = 'IM'
      AND FATH.TRANSACTION_DATE_ENTERED BETWEEN FADP.CALENDAR_PERIOD_OPEN_DATE AND NVL(FADP.CALENDAR_PERIOD_CLOSE_DATE, SYSDATE)
      AND FADP.FISCAL_YEAR = FAFY.FISCAL_YEAR
      AND NVL (p_trans_rec.AMORTIZATION_START_DATE,p_trans_rec.TRANSACTION_DATE_ENTERED) <= NVL(FAFY.END_DATE, SYSDATE);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- l_imp_exists := 'N';
	l_imp_exists := 0;
   END;


      --IF (l_imp_exists = 'Y') then
      IF (l_imp_exists > 0) then
         IF (p_log_level_rec.statement_level) then
	    fa_debug_pkg.add(l_calling_fn, 'Current Transaction is overlapped to previously done Impairment', '', p_log_level_rec);
	    fa_debug_pkg.add(l_calling_fn, 'OR Amort start date/trx date entered falls ', 'in same Fiscal year in which an impairment already exists', p_log_level_rec);
	 END IF;
	    Return FALSE;
      ELSE
	    Return TRUE;
      END IF;

END check_overlapping_impairment;

/*phase5 This function will restrict any impairment posted on Asset added with depreciate flag NO and wiithout reserve*/
FUNCTION check_non_depreciating_asset (
   p_asset_id       IN   NUMBER,
   p_book_type_code IN   VARCHAR2,
   p_log_level_rec  IN   FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

  l_restrict_trx          VARCHAR2(1) := 'N';
  l_calling_fn            varchar2(100)  := 'FA_ASSET_VAL_PVT.check_non_depreciating_asset';

BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'begin', 'l_calling_fn', p_log_level_rec);
   end if;
   BEGIN
      SELECT 'Y'
      INTO l_restrict_trx
      FROM FA_BOOKS FABK
      WHERE FABK.ASSET_ID = p_asset_id
      AND   FABK.BOOK_TYPE_CODE = p_book_type_code
      AND   NOT EXISTS (SELECT 1 FROM FA_BOOKS FABK1
                        WHERE FABK1.ASSET_ID = p_asset_id
                          AND FABK1.BOOK_TYPE_CODE = p_book_type_code
                          AND FABK1.DEPRECIATE_FLAG = 'YES')
      AND   NOT EXISTS (SELECT 1 FROM FA_DEPRN_SUMMARY FADS
                        WHERE FADS.ASSET_ID = p_asset_id
                          AND FADS.BOOK_TYPE_CODE = p_book_type_code
                          AND FADS.DEPRN_SOURCE_CODE = 'BOOKS'
                          AND FADS.DEPRN_RESERVE > 0 );

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_restrict_trx := 'N';
   END;


      IF (l_restrict_trx = 'Y') then
         IF (p_log_level_rec.statement_level) then
	    fa_debug_pkg.add(l_calling_fn, 'This asset is added with Deprecition flag NO and without Reserve', '', p_log_level_rec);
	 END IF;
	    Return FALSE;
      ELSE
	    Return TRUE;
      END IF;

END check_non_depreciating_asset;

END FA_ASSET_VAL_PVT;

/
