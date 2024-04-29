--------------------------------------------------------
--  DDL for Package Body FA_DISTRIBUTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DISTRIBUTION_PVT" AS
/* $Header: FAVDISTB.pls 120.24.12010000.6 2009/08/07 14:01:17 souroy ship $   */

g_release                  number  := fa_cache_pkg.fazarel_release;

FUNCTION do_distribution(
                        px_trans_rec            IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                        px_asset_hdr_rec        IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
                        px_asset_cat_rec_new    IN OUT NOCOPY FA_API_TYPES.asset_cat_rec_type,
                        px_asset_dist_tbl       IN OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type,
                        p_validation_level     IN NUMBER :=
FND_API.G_VALID_LEVEL_FULL
                        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

l_trans_rec             FA_API_TYPES.trans_rec_type;
l_asset_hdr_rec         FA_API_TYPES.asset_hdr_rec_type;

l_asset_type_rec_old    FA_API_TYPES.asset_type_rec_type;
l_asset_cat_rec_old     FA_API_TYPES.asset_cat_rec_type;
l_asset_desc_rec_new    FA_API_TYPES.asset_desc_rec_type;
l_period_rec            FA_API_TYPES.period_rec_type;
l_src_trans_rec         FA_API_TYPES.trans_rec_type;
l_src_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
l_dest_trans_rec        FA_API_TYPES.trans_rec_type;
l_dest_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;

l_txn_date_entered      date;
l_cal_period_close_date date;
l_current_pc            number;
l_period_addition       varchar2(1);
l_book                  varchar2(30);
l_old_units             number := 0;
l_total_txn_units       number := 0;
l_primary_sob_id        number;
l_mrc_sob_type_code     varchar2(1);

l_index                 number;
l_init_null_trx_date    boolean;
l_backdated_xfr         boolean;

error_found             exception;

-- SLA Uptake
-- rewriting this to pick up all tax books
-- as each needs a seperate transaction

CURSOR c_books (l_book_type_code varchar2,
                l_asset_id number) IS
      SELECT bc.book_type_code
        FROM fa_books         bk,
             fa_book_controls bc
       WHERE bc.distribution_source_book  = l_book_type_code
         AND bk.book_type_code            = bc.book_type_code
         AND bk.asset_id                  = l_asset_id
         AND bk.transaction_header_id_out is null
         AND bc.date_ineffective is null
       ORDER BY bc.book_class,
                bc.book_type_code;

CURSOR n_sob_id (p_psob_id IN NUMBER,
                 p_book_type_code IN VARCHAR2) is
    SELECT p_psob_id AS sob_id,
           1 AS index_id
    FROM dual
    UNION
    SELECT set_of_books_id AS sob_id,
           2 AS index_id
    FROM fa_mc_book_controls
    WHERE book_type_code = p_book_type_code
    AND primary_set_of_books_id = p_psob_id
    AND enabled_flag = 'Y'
    ORDER BY 2;

--Added for 8759611
CURSOR cur_dists_eff (c_asset_id NUMBER,c_transaction_id NUMBER,c_book VARCHAR2) IS
SELECT NULL distribution_id,units_assigned,units_assigned transaction_units,
       code_combination_id expense_ccid,location_id location_ccid,assigned_to
  FROM fa_distribution_history
 WHERE asset_id = c_asset_id
   AND transaction_header_id_in = c_transaction_id
   AND book_type_code = c_book
UNION ALL
SELECT distribution_id,units_assigned,transaction_units,
       code_combination_id expense_ccid,location_id location_ccid,assigned_to
  FROM fa_distribution_history
 WHERE asset_id = c_asset_id
   AND transaction_header_id_out = c_transaction_id
   AND book_type_code = c_book
ORDER BY distribution_id;

l_dum_dist_table fa_api_types.asset_dist_tbl_type;
l_dist_cntr NUMBER;
--End of addition for 8759611
BEGIN

   l_trans_rec := px_trans_rec;

   -- populate category_id for the asset
   if not FA_UTIL_PVT.get_asset_cat_rec(px_asset_hdr_rec,
                                        l_asset_cat_rec_old
                                        ,p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   -- populate new_category_id with old category if non-reclass
   if px_trans_rec.transaction_type_code in ('UNIT ADJUSTMENT','TRANSFER OUT',
                                             'TRANSFER') then
      px_asset_cat_rec_new.category_id := l_asset_cat_rec_old.category_id;
   elsif (px_trans_rec.transaction_type_code = 'RECLASS') then
      if px_asset_cat_rec_new.category_id is null then
         fa_srvr_msg.add_message(
            calling_fn => 'FA_DISTRIBUTION_PVT.do_distribution',
            name       => 'FA_SHARED_UNDEFINE_CATEGORY'
            ,p_log_level_rec => p_log_level_rec);
         raise error_found;
      end if;
   end if;

   -- populate old asset type for the asset
   if not FA_UTIL_PVT.get_asset_type_rec(px_asset_hdr_rec,
                                         l_asset_type_rec_old
                                         ,p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;


   -- get current unit
   select sum(units_assigned - nvl(transaction_units, 0))
     into l_old_units
     from fa_distribution_history
    where asset_id = px_asset_hdr_rec.asset_id
      and book_type_code = px_asset_hdr_rec.book_type_code
      and date_ineffective IS NULL;

   -- validate input data
   if not do_validation(px_trans_rec,
                        px_asset_hdr_rec,
                        px_asset_cat_rec_new,
                        px_asset_dist_tbl,
                        l_old_units,
                        l_total_txn_units,
                        p_validation_level
                        ,p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   -- populate new units
   l_asset_desc_rec_new.current_units     := l_old_units;
   if (px_trans_rec.transaction_type_code in ('TRANSFER OUT','UNIT ADJUSTMENT')) then
      l_asset_desc_rec_new.current_units := l_old_units + l_total_txn_units;
   end if;

   l_index := 0;
   l_asset_hdr_rec := px_asset_hdr_rec;

   -- loop through corp and tax books
   open c_books(px_asset_hdr_rec.book_type_code,
              px_asset_hdr_rec.asset_id);
   loop

      l_index := l_index + 1;

      fetch c_books into l_book;
      exit when c_books%NOTFOUND;

      l_trans_rec := px_trans_rec;
      l_asset_hdr_rec.book_type_code := l_book;

      if not FA_UTIL_PVT.get_period_rec
                 (p_book       => l_book,
                  x_period_rec => l_period_rec
                  ,p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;

      if not FA_CACHE_PKG.fazcbc(X_book => l_book
                        ,p_log_level_rec => p_log_level_rec) then
         fa_srvr_msg.add_message(calling_fn => 'FA_DISTRIBUTION_PVT.do_distribution'
                  ,p_log_level_rec => p_log_level_rec);
         raise error_found;
      end if;

--      if (l_index = 1) then  -- for bug fix 4969369
         -- populate transaction date if null
         if (px_trans_rec.transaction_date_entered is null) then
            l_init_null_trx_date := TRUE;

            px_trans_rec.transaction_date_entered :=
                       greatest(l_period_rec.calendar_period_open_date,
                                least(sysdate,l_period_rec.calendar_period_close_date));
            px_trans_rec.transaction_date_entered :=
               to_date(to_char(px_trans_rec.transaction_date_entered,'DD/MM/YYYY'),'DD/MM/YYYY');
         end if;
--       else               -- for bug fix 4969369
            -- check if date is backdated
            if (px_trans_rec.transaction_date_entered  < l_period_rec.calendar_period_open_date) then
               l_backdated_xfr := true;
            else
               l_backdated_xfr := false;
            end if;
 --        end if;          -- for bug fix 4969369

         l_trans_rec := px_trans_rec;

 --     end if;             -- for bug fix 4969369

      -- populate period_of_addition
      -- SLA: always populate for all trx including TRANSFER OUT
      if not fa_asset_val_pvt.validate_period_of_addition
                (l_asset_hdr_rec.asset_id,
                 l_asset_hdr_rec.book_type_code,
                 'ABSOLUTE',
                 l_asset_hdr_rec.period_of_addition
                 ,p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;

      /*Bug#8478435 - set_of_books_id issue - POST MRC change */
      l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
      -- SLA UPTAKE
      -- assign an event for the transaction
      -- at this point key info asset/book/trx info is known from initialize
      -- call and the above code (i.e. trx_type, etc)
      --
      -- Note changing this so even though we have a single TH,
      -- we are creating an event/entity for each book (VM)

      if not fa_xla_events_pvt.create_transaction_event
               (p_asset_hdr_rec => l_asset_hdr_rec,
                p_asset_type_rec=> l_asset_type_rec_old,
                px_trans_rec    => l_trans_rec,
                p_event_status  => NULL,
                p_calling_fn    => 'FA_DISTRIBUTION_PVT.do_distribution'
                ,p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;

      --Bug6391045
      --Assigned the generated event_id into the px_trans_rec.event_id
      px_trans_rec.event_id := l_trans_rec.event_id;

      if (l_index = 1) then
         -- insert fa_transaction_headers
         if not insert_txn_headers(l_trans_rec,
                                   l_asset_hdr_rec
                                   ,p_log_level_rec => p_log_level_rec) then
            raise error_found;
         end if;

         -- update fa_asset_history
         if px_trans_rec.transaction_type_code <> 'TRANSFER' then
            if not update_asset_history(l_trans_rec,
                                        l_asset_hdr_rec,
                                        px_asset_cat_rec_new,
                                        l_asset_desc_rec_new
                                        ,p_log_level_rec => p_log_level_rec) then
               raise error_found;
            end if;
         end if;


         -- update fa_additions
         if not update_additions(l_trans_rec,
                                 l_asset_hdr_rec,
                                 px_asset_cat_rec_new,
                                 l_asset_desc_rec_new
                                 ,p_log_level_rec => p_log_level_rec) then
            raise error_found;
         end if;

      end if;

      -- update fa_books for prior period transfer
      if (px_trans_rec.transaction_type_code = 'TRANSFER' and
          G_release = 11) then
         if not update_books(l_trans_rec,
                             l_asset_hdr_rec,
                             l_period_rec
                             ,p_log_level_rec => p_log_level_rec) then
            raise error_found;
         end if;
      end if;


      if (l_index = 1) then
         -- update fa_distribution_history
         if not update_dist_history(l_trans_rec,
                                    l_asset_hdr_rec,
                                    px_asset_dist_tbl
                                    ,p_log_level_rec => p_log_level_rec) then
            raise error_found;
         end if;

         -- check to make sure units are in sync after the updates
         if not units_in_sync(px_asset_hdr_rec, p_log_level_rec) then
            raise error_found;
         end if;
      end if;

      -- R12 conditional handling
      if (px_asset_hdr_rec.period_of_addition = 'Y' and
          G_release = 11) then
         l_primary_sob_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
         -- loop thru primary and its reporting books
         for c_rec in n_sob_id(l_primary_sob_id, px_asset_hdr_rec.book_type_code) loop
            if c_rec.index_id = 1 then
               l_mrc_sob_type_code := 'P';
            else
               l_mrc_sob_type_code := 'R';
            end if;

           -- Bug:5915051
           if NOT fa_cache_pkg.fazcbcs(X_book => l_asset_hdr_rec.book_type_code,
                                       X_set_of_books_id => c_rec.sob_id) then
                return FALSE;
           end if;

           if not FA_INS_DETAIL_PKG.FAXINDD(
                        X_book_type_code => px_asset_hdr_rec.book_type_code,
                        X_asset_id       => px_asset_hdr_rec.asset_id,
                        X_period_counter => NULL,
                        X_cost           => NULL,
                        X_deprn_reserve  => NULL,
                        X_reval_reserve  => NULL,
                        X_ytd            => NULL,
                        X_ytd_reval_dep_exp => NULL,
                        X_init_message_flag => 'NO',
                        X_mrc_sob_type_code => l_mrc_sob_type_code,
                        X_set_of_books_id    => c_rec.sob_id,
                        p_log_level_rec => p_log_level_rec) then
                fa_srvr_msg.add_message(
                   calling_fn => 'FA_DISTRIBUTION_PVT.do_distribution');
                   return FALSE;
             end if;
         end loop;
      end if;

      l_current_pc := FA_CACHE_PKG.fazcbc_record.last_period_counter + 1;

      if not FA_TRANSFER_XIT_PKG.fautfr(
                        X_thid              => l_trans_rec.transaction_header_id,
                        X_asset_id          => l_asset_hdr_rec.asset_id,
                        X_book              => l_asset_hdr_rec.book_type_code,
                        X_txn_type_code     => l_trans_rec.transaction_type_code,
                        X_period_ctr        => l_current_pc,
                        X_curr_units        => l_asset_desc_rec_new.current_units,
                        X_today             => l_trans_rec.who_info.last_update_date,
                        X_old_cat_id        => l_asset_cat_rec_old.category_id,
                        X_new_cat_id        => px_asset_cat_rec_new.category_id,
                        X_asset_type        => l_asset_type_rec_old.asset_type,
                        X_last_update_date  => l_trans_rec.who_info.last_update_date,
                        X_last_updated_by   => l_trans_rec.who_info.last_updated_by,
                        X_last_update_login =>l_trans_rec.who_info.last_update_login,
                        X_init_message_flag => 'NO'
                        ,p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;

      -- Bug 4739563  call the catchup logic only when the transfer ia a
      -- backdated one
      -- added the check on l_backdated_xfr

      if (G_release <> 11 and
          l_backdated_xfr and
          l_trans_rec.transaction_type_code = 'TRANSFER' and
          (l_asset_type_rec_old.asset_type = 'GROUP' or
           l_asset_type_rec_old.asset_type = 'CAPITALIZED'))then
            --Change for 8759611
             l_dist_cntr := 1;
             FOR rec_dists_eff IN cur_dists_eff(l_asset_hdr_rec.asset_id,
                                                l_trans_rec.transaction_header_id,
				                            l_asset_hdr_rec.book_type_code)
             LOOP
                  l_dum_dist_table(l_dist_cntr).distribution_id := rec_dists_eff.distribution_id;
                  l_dum_dist_table(l_dist_cntr).units_assigned := rec_dists_eff.units_assigned;
                  l_dum_dist_table(l_dist_cntr).transaction_units := rec_dists_eff.transaction_units;
                  l_dum_dist_table(l_dist_cntr).assigned_to := rec_dists_eff.assigned_to;
                  l_dum_dist_table(l_dist_cntr).expense_ccid := rec_dists_eff.expense_ccid;
                  l_dum_dist_table(l_dist_cntr).location_ccid := rec_dists_eff.location_ccid;

                  l_dist_cntr := l_dist_cntr + 1;
             END LOOP;
            --End of change for 8759611
         if not FA_TRANSFER_PVT.fadppt
                (p_trans_rec       => l_trans_rec,
                 p_asset_hdr_rec   => l_asset_hdr_rec,
                 p_asset_desc_rec  => l_asset_desc_rec_new,
                 p_asset_cat_rec   => px_asset_cat_rec_new,
                 -- p_asset_dist_tbl  => px_asset_dist_tbl changed for 8759611
			  p_asset_dist_tbl  => l_dum_dist_table -- Added for 8759611
                 ,p_log_level_rec => p_log_level_rec) then
            raise error_found;
         end if;
      end if;

      -- fix for bug 2725999 - call INTERCO private API to create
      -- INTERCO AP/AR rows in fa_adjustments table

      if (px_asset_hdr_rec.period_of_addition <> 'Y' and
          G_release = 11) then

          l_src_trans_rec := px_trans_rec;
          l_src_asset_hdr_rec := px_asset_hdr_rec;
          l_src_trans_rec.transaction_type_code := 'TRANSFER';
          l_dest_trans_rec := NULL;
          l_dest_asset_hdr_rec := NULL;

          if (px_trans_rec.transaction_type_code in ('TRANSFER', 'UNIT ADJUSTMENT')) then

             if not FA_INTERCO_PVT.do_all_books(
                        p_src_trans_rec      => l_src_trans_rec,
                        p_src_asset_hdr_rec  => l_src_asset_hdr_rec,
                        p_dest_trans_rec     => l_dest_trans_rec,
                        p_dest_asset_hdr_rec => l_dest_asset_hdr_rec,
                        p_calling_fn         => 'FA_DISTRIBUTION_PVT.do_distribution', p_log_level_rec => p_log_level_rec) then
                 fa_srvr_msg.add_message(
                        calling_fn => 'FA_DISTRIBUTION_PVT.do_distribution',  p_log_level_rec => p_log_level_rec);
                 return FALSE;
             end if;
          end if;
      end if;
   end loop;

   close c_books;

   -- reset cache to incoming corp book instead of last tax
   if not FA_CACHE_PKG.fazcbc(X_book => px_asset_hdr_rec.book_type_code
                     ,p_log_level_rec => p_log_level_rec) then
         fa_srvr_msg.add_message(calling_fn => 'FA_DISTRIBUTION_PVT.do_distribution'
                  ,p_log_level_rec => p_log_level_rec);
      raise error_found;
   end if;

   return TRUE;

EXCEPTION
   when others then
       fa_srvr_msg.add_sql_error(
                calling_fn => 'FA_DISTRIBUTION_PVT.do_distribution',  p_log_level_rec => p_log_level_rec);
       return FALSE;

END do_distribution;


FUNCTION do_validation(p_trans_rec          IN     FA_API_TYPES.trans_rec_type,
                       p_asset_hdr_rec      IN     FA_API_TYPES.asset_hdr_rec_type,
                       p_asset_cat_rec_new  IN     FA_API_TYPES.asset_cat_rec_type,
                       px_asset_dist_tbl    IN OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type,
                       p_old_units          IN     NUMBER,
                       x_total_txn_units    OUT NOCOPY    NUMBER,
                       p_validation_level      IN NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is

   l_tot_txn number := 0;   --total txn units
   l_prev_txn number := 0;
   l_count       number;
   l_curr_index  number;
   l_msg_name   varchar2(100);
   l_asset_id   number;
   d_distribution_id   number;
   d_transaction_units number;
   d_assigned_to       number;
   d_expense_ccid      number;
   d_location_ccid     number;
   l_minus_rec     number := 0;
   -- l_match_units is used to make sure source and destination units
   -- match, for transfer and reclass txn
   l_match_unit    number := 0;

   l_asset_type_rec_old   fa_api_types.asset_type_rec_type;
   l_group_asset_id       number;

cursor DH_C1 is
   select distribution_id,
          units_assigned
   from fa_distribution_history
   where asset_id = l_asset_id
   and  nvl(assigned_to,-9999) = nvl(d_assigned_to,-9999)
   and  code_combination_id = d_expense_ccid
   and  location_id = d_location_ccid
   and  date_ineffective is null;

cursor DH_C2 is
   select units_assigned
   from fa_distribution_history
   where asset_id = l_asset_id
   and  distribution_id = d_distribution_id;
--   and  nvl(assigned_to,-9999) = nvl(d_assigned_to,-9999)
--   and  code_combination_id = nvl(d_expense_ccid,code_combination_id)
--   and  location_id = nvl(d_location_ccid,location_id);

   DIST_DATA_ERROR     EXCEPTION;
begin

     -- validate if units are in sync before proceeding

      if not units_in_sync(p_asset_hdr_rec, p_log_level_rec) then
          return FALSE;
      end if;

      -- check period_of_addition is correctly set
      if (p_asset_hdr_rec.period_of_addition not in ('Y','N')) then
          fa_srvr_msg.add_message(
                      calling_fn => 'FA_DISTRIBUTION_PVT.do_validation',
                      name   => 'FA_API_SHARED_INVALID_YN',
                      token1 => 'VALUE',
                      value1 => p_asset_hdr_rec.period_of_addition,
                      token2 => 'XMLTAG',
                      value2 => 'PERIOD_OF_ADDITION',  p_log_level_rec => p_log_level_rec);
          return FALSE;
      end if;


      -- validate all the dist_tbl records
      l_asset_id := p_asset_hdr_rec.asset_id;
      FOR i in px_asset_dist_tbl.first..px_asset_dist_tbl.last LOOP

         l_curr_index := i;
         d_distribution_id := px_asset_dist_tbl(i).distribution_id;
         d_transaction_units := px_asset_dist_tbl(i).transaction_units;
         d_assigned_to := px_asset_dist_tbl(i).assigned_to;
         d_expense_ccid := px_asset_dist_tbl(i).expense_ccid;
         d_location_ccid := px_asset_dist_tbl(i).location_ccid;

         -- make sure distribution_id or 3-tuple columns is provided
         if (d_distribution_id is null and
             (d_expense_ccid is null or d_location_ccid is null)) then
              l_msg_name := 'FA_WHATIF_ASSET_DIST_INFO';
              raise DIST_DATA_ERROR;
         end if;
        -- BUG# 6936546

      -- if (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then

         -- make sure transaction_units are populated
         if (d_transaction_units is null or d_transaction_units = 0) then
              l_msg_name := 'FA_INVALID_TXN_UNITS';
              raise DIST_DATA_ERROR;
         end if;

     --  end if;

         if (p_trans_rec.transaction_type_code in ('TRANSFER','RECLASS','TRANSFER OUT')) then
             if (d_distribution_id is null) then
                 if (d_transaction_units < 0) then
                     open DH_C1;
                     fetch DH_C1 into px_asset_dist_tbl(i).distribution_id,
                                      px_asset_dist_tbl(i).units_assigned;
                     if (DH_C1%NOTFOUND) then
                         l_msg_name := 'FA_WHATIF_ASSET_DIST_INFO';
                         raise DIST_DATA_ERROR;
                     end if;
                     close DH_C1;
                     l_tot_txn := l_tot_txn + d_transaction_units;
                     l_match_unit := l_match_unit + d_transaction_units;
                     l_minus_rec := l_minus_rec + 1;
                 else
                     if (p_trans_rec.transaction_type_code = 'TRANSFER OUT') then
                         l_msg_name := 'FA_INVALID_TXN_UNITS';
                         raise DIST_DATA_ERROR;
                     elsif (p_trans_rec.transaction_type_code = 'TRANSFER') then
                        -- BUG# 6936546
                        if (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then
                         open DH_C1;
                         fetch DH_C1 into px_asset_dist_tbl(i).distribution_id,
                                          px_asset_dist_tbl(i).units_assigned;
                         close DH_C1;
                        end if;
                     end if;

                     if not valid_dist_data(p_trans_rec,
                                            p_asset_hdr_rec,
                                            px_asset_dist_tbl,
                                            l_curr_index,
                                            p_validation_level,
                                            p_log_level_rec) then
                        raise DIST_DATA_ERROR;
                     end if;
                     l_match_unit := l_match_unit + d_transaction_units;
                 end if;
             else -- d_distribution_id not null
                 if (d_transaction_units <0) then
                     open DH_C2;
                     fetch DH_C2 into px_asset_dist_tbl(i).units_assigned;
                     if DH_C2%NOTFOUND then
                         l_msg_name := 'FA_WHATIF_ASSET_DIST_INFO';
                         raise DIST_DATA_ERROR;
                     end if;
                     close DH_C2;
                     l_tot_txn := l_tot_txn + d_transaction_units;
                     l_match_unit := l_match_unit + d_transaction_units;
                     l_minus_rec := l_minus_rec + 1;
                 else
                     if (p_trans_rec.transaction_type_code = 'TRANSFER') then
                         open DH_C2;
                         fetch DH_C2 into px_asset_dist_tbl(i).units_assigned;
                         if DH_C2%NOTFOUND then
                            l_msg_name := 'FA_WHATIF_ASSET_DIST_INFO';
                            raise DIST_DATA_ERROR;
                         end if;
                         close DH_C2;
                         l_match_unit := l_match_unit + d_transaction_units;
                     else
                         l_msg_name := 'FA_INVALID_TXN_UNITS';
                         raise DIST_DATA_ERROR;
                     end if;
                 end if;
             end if;

         elsif (p_trans_rec.transaction_type_code = 'UNIT ADJUSTMENT') then
             if (d_distribution_id is null) then
                 open DH_C1;
                 fetch DH_C1 into px_asset_dist_tbl(i).distribution_id,
                                  px_asset_dist_tbl(i).units_assigned;
                 if DH_C1%NOTFOUND then
                    if (d_transaction_units < 0) then
                        l_msg_name := 'FA_WHATIF_ASSET_DIST_INFO';
                        raise DIST_DATA_ERROR;
                    end if;
                 end if;
                 close DH_C1;
             else
                open DH_C2;
                fetch DH_C2 into px_asset_dist_tbl(i).units_assigned;
                if DH_C2%NOTFOUND then
                      l_msg_name := 'FA_WHATIF_ASSET_DIST_INFO';
                      raise DIST_DATA_ERROR;
                end if;
                close DH_C2;
             end if;
             l_tot_txn := l_tot_txn + d_transaction_units;
             if ABS(l_tot_txn) < ABS(l_prev_txn) then
                  l_msg_name := 'FA_INVALID_TXN_UNITS';
                  raise DIST_DATA_ERROR;
             end if;
             l_prev_txn := l_tot_txn;
         end if;

         -- check to make sure txn unit don't exceed units_assigned
         if (d_transaction_units < 0) then
            if ABS(d_transaction_units) > px_asset_dist_tbl(i).units_assigned then
               l_msg_name := 'FA_TFR_UNITS_TFRED_EXCEEDED';
               raise DIST_DATA_ERROR;
            end if;
         end if;

         -- txn_units and units_assigned must be same for reclass
         if (p_trans_rec.transaction_type_code = 'RECLASS') then
           if (d_transaction_units < 0 and
               ABS(d_transaction_units) <> px_asset_dist_tbl(i).units_assigned) then
               l_msg_name := 'FA_INVALID_TXN_UNITS';
               raise DIST_DATA_ERROR;
           end if;
         end if;

     END LOOP;

   -- BUG# 6936546
   --    if (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then

   -- check if txn_units are valid for transfer and reclass
   -- sum of txn units in dist_tbl should be zeroed out
   -- for transfer and reclass case
     if (p_trans_rec.transaction_type_code in ('TRANSFER','RECLASS')) then
         if l_match_unit <> 0 then
            l_msg_name := 'FA_INVALID_TXN_UNITS';
            raise DIST_DATA_ERROR;
         end if;
         -- allow only one transfer
         if (p_trans_rec.transaction_type_code = 'TRANSFER' and
             l_minus_rec > 1) then
                l_msg_name := 'FA_INVALID_TXN_UNITS';
                raise DIST_DATA_ERROR;
         elsif (p_trans_rec.transaction_type_code = 'RECLASS' and
                p_old_units <> ABS(l_tot_txn)) then
                l_msg_name := 'FA_INVALID_TXN_UNITS';
                raise DIST_DATA_ERROR;
         end if;
     -- check if unit balance goes to 0
     elsif (p_trans_rec.transaction_type_code in ('TRANSFER OUT','UNIT ADJUSTMENT')) then
         if ((p_old_units + l_tot_txn) < 1 ) then
            l_msg_name := 'FA_INS_ADJ_ZERO_UNITS';
            raise DIST_DATA_ERROR;
         end if;
     end if;

     -- make sure total txn units are whole number except transfer txn
     if (p_trans_rec.transaction_type_code <> 'TRANSFER') then
        if (ABS(l_tot_txn) > trunc(ABS(l_tot_txn))) then
           l_msg_name := 'FA_INVALID_TXN_UNITS';
           raise DIST_DATA_ERROR;
        end if;
     end if;

     -- end if;


     x_total_txn_units := l_tot_txn;

     if (p_trans_rec.transaction_type_code in ('TRANSFER', 'UNIT ADJUSTMENT') and
         nvl(fa_cache_pkg.fazcbc_record.allow_interco_group_flag, 'N') <> 'Y') then

        if not FA_UTIL_PVT.get_asset_type_rec(p_asset_hdr_rec,
                                              l_asset_type_rec_old, p_log_level_rec => p_log_level_rec) then
           fa_srvr_msg.add_message(calling_fn => 'FA_DISTRIBUTION_PVT.do_validation',  p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;

        if (l_asset_type_rec_old.asset_type <> 'GROUP') then
           select group_asset_id
             into l_group_asset_id
             from fa_books
            where asset_id         = p_asset_hdr_rec.asset_id
              and book_type_code   = p_asset_hdr_rec.book_type_code
              and date_ineffective is null;
        end if;

        if (l_group_asset_id is not null or
            l_asset_type_rec_old.asset_type  = 'GROUP') then

           if not fa_interco_pvt.validate_grp_interco
                   (p_asset_hdr_rec    => p_asset_hdr_rec,
                    p_trans_rec        => p_trans_rec,
                    p_asset_type_rec   => l_asset_type_rec_old,
                    p_group_asset_id   => 1,
                    p_asset_dist_tbl   => px_asset_dist_tbl,
                    p_calling_fn       => 'FA_DISTRIBUTION_PVT.do_validation', p_log_level_rec => p_log_level_rec) then

              fa_srvr_msg.add_message(calling_fn => 'FA_DISTRIBUTION_PVT.do_validation',  p_log_level_rec => p_log_level_rec);
              return FALSE;
           end if;

        end if;
     end if;

   return TRUE;

EXCEPTION
   when DIST_DATA_ERROR then

       if DH_C1%ISOPEN then
            close DH_C1;
       end if;
       if DH_C2%ISOPEN then
            close DH_C2;
       end if;

       fa_srvr_msg.add_message(
                calling_fn => 'FA_DISTRIBUTION_PVT.do_validation',
                name => l_msg_name,  p_log_level_rec => p_log_level_rec);
       return FALSE;

   when others then
       fa_srvr_msg.add_sql_error(
                calling_fn => 'FA_DISTRIBUTION_PVT.do_validation',  p_log_level_rec => p_log_level_rec);
       return FALSE;
END do_validation;


FUNCTION valid_dist_data(p_trans_rec      IN   FA_API_TYPES.trans_rec_type,
                         p_asset_hdr_rec  IN   FA_API_TYPES.asset_hdr_rec_type,
                         p_asset_dist_tbl IN OUT NOCOPY   FA_API_TYPES.asset_dist_tbl_type,
                         p_curr_index     IN   NUMBER,
                         p_validation_level      IN NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

RETURN BOOLEAN IS


 l_count NUMBER;
 l_high_bound  number;
 l_gl_chart_id number;

BEGIN

     -- validate assigned_to
     if (p_asset_dist_tbl(p_curr_index).assigned_to is not null) then
        select count(*)
        into l_count
        from per_periods_of_service s, per_people_f p
        where p.person_id = s.person_id
        and trunc(sysdate) between
             p.effective_start_date and p.effective_end_date
        and nvl(s.actual_termination_date,sysdate) >= sysdate
        and p.person_id = p_asset_dist_tbl(p_curr_index).assigned_to;
        if (l_count = 0) then
            fa_srvr_msg.add_message(
               calling_fn => 'FA_DISTRIBUTION_PVT.valid_dist_data',
               name       => 'FA_INCORRECT_ASSIGNED_TO',
               token1     => 'ASSIGNED_TO',
               value1     => p_asset_dist_tbl(p_curr_index).assigned_to,
                   p_log_level_rec => p_log_level_rec);
            return FALSE;
        end if;
     end if;

     if not FA_CACHE_PKG.fazcbc(X_book => p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
        return FALSE;
     else
        l_gl_chart_id := FA_CACHE_PKG.fazcbc_record.accounting_flex_structure;
     end if;

     -- validate expense ccid
     if not FA_ASSET_VAL_PVT.validate_expense_ccid(p_asset_dist_tbl(p_curr_index).expense_ccid,
                                              l_gl_chart_id,
                                              'FA_DISTRIBUTION_PVT.valid_dist_data', p_log_level_rec) then
        return FALSE;
     end if;


     -- validate location id
     if not FA_ASSET_VAL_PVT.validate_location_ccid(
                                p_trans_rec.transaction_type_code,
                                p_asset_dist_tbl(p_curr_index).location_ccid,
                                'FA_DISTRIBUTION_PVT.valid_dist_data',
                                p_log_level_rec) then
        return FALSE;
     end if;



   -- check for duplicate lines
   if (p_trans_rec.transaction_type_code = 'TRANSFER') then

      -- bugfix 2846357
      -- BUG# 6936546
      if (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then
         if not FA_ASSET_VAL_PVT.validate_duplicate_dist (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_asset_dist_tbl        => p_asset_dist_tbl,
             p_curr_index            => p_curr_index , p_log_level_rec => p_log_level_rec) then

              fa_srvr_msg.add_message(
                         calling_fn => 'FA_DISTRIBUTION_PVT.valid_dist_data',  p_log_level_rec => p_log_level_rec);
              return FALSE;
         end if;
      end if;
  end if;  /* if txn_type */

     return TRUE;


EXCEPTION
     when others then
         fa_srvr_msg.add_sql_error(calling_fn => 'FA_DISTRIBUTION_PVT.valid_dist_data',  p_log_level_rec => p_log_level_rec);
         return FALSE;
END valid_dist_data;


FUNCTION units_in_sync(p_asset_hdr_rec IN FA_API_TYPES.asset_hdr_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

RETURN BOOLEAN IS

  l_ad_units number;
  l_ah_units number;
  l_dh_units number;

BEGIN
      select current_units
      into   l_ad_units
      from   fa_additions
      where  asset_id = p_asset_hdr_rec.asset_id;

      select  units
      into    l_ah_units
      from    fa_asset_history
      where   asset_id = p_asset_hdr_rec.asset_id
      and     date_ineffective IS NULL;

      select  sum(units_assigned - nvl(transaction_units, 0))
      into    l_dh_units
      from    fa_distribution_history
      where   asset_id = p_asset_hdr_rec.asset_id
      and     book_type_code = p_asset_hdr_rec.book_type_code
      and     date_ineffective IS NULL;

      if (l_ad_units <> l_ah_units or
          l_ad_units <> l_dh_units or
          l_ah_units <> l_dh_units) then

          fa_srvr_msg.add_message(
                calling_fn => 'FA_DISTRIBUTION_PVT.units_in_sync',
                name       => 'FA_UNITS_DIFFERENT',  p_log_level_rec => p_log_level_rec);

        return FALSE;
      end if;

   return TRUE;

EXCEPTION
   when others then
      fa_srvr_msg.add_sql_error
                (calling_fn => 'FA_DISTRIBUTION_PVT.units_in_sync',  p_log_level_rec => p_log_level_rec);
      return FALSE;

END units_in_sync;



FUNCTION insert_txn_headers(px_trans_rec     IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                            p_asset_hdr_rec  IN     FA_API_TYPES.asset_hdr_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   l_transaction_type_code px_trans_rec.transaction_type_code%TYPE;
   l_transaction_subtype px_trans_rec.transaction_subtype%TYPE;
   l_success boolean;
   l_rowid    ROWID;
   l_txn_head_id px_trans_rec.transaction_header_id%TYPE;

BEGIN

   l_txn_head_id := px_trans_rec.transaction_header_id; --for 3188851
   l_transaction_type_code := px_trans_rec.transaction_type_code;
   l_transaction_subtype := px_trans_rec.transaction_subtype;

   -- if period of addition, update fa_transaction_headers with transfer in/void
   if (p_asset_hdr_rec.period_of_addition = 'Y' and
       G_release = 11) then

        update fa_transaction_headers
        set transaction_type_code = 'TRANSFER IN/VOID',
            transaction_subtype = decode(l_transaction_type_code,
                                         'RECLASS',l_transaction_subtype,
                                         transaction_subtype)
        where asset_id = p_asset_hdr_rec.asset_id
        and book_type_code = p_asset_hdr_rec.book_type_code
        and transaction_type_code = 'TRANSFER IN';

        l_transaction_type_code := 'TRANSFER IN';
   end if;

   -- insert new row with transaction type associated with this transaction
   FA_TRANSACTION_HEADERS_PKG.INSERT_ROW(
                 X_Rowid => l_rowid,
                 X_Transaction_Header_Id => l_txn_head_id,
                 X_Book_Type_Code => p_asset_hdr_rec.book_type_code,
                 X_Asset_Id => p_asset_hdr_rec.asset_id,
                 X_Transaction_Type_Code => l_transaction_type_code,
                 X_Transaction_Date_Entered => px_trans_rec.transaction_date_entered,
                 X_Date_Effective => px_trans_rec.who_info.last_update_date,
                 X_Last_Update_Date => px_trans_rec.who_info.last_update_date,
                 X_Last_Updated_By => px_trans_rec.who_info.last_updated_by,
                 X_Transaction_Name => px_trans_rec.transaction_name,
                 X_Invoice_Transaction_Id => NULL,
                 X_Source_Transaction_Header_Id => px_trans_rec.source_transaction_header_id,
                 X_Mass_Reference_Id => px_trans_rec.mass_reference_id,
                 X_Last_Update_Login => px_trans_rec.who_info.last_update_login,
                 X_Transaction_Subtype => px_trans_rec.transaction_subtype,
                 X_Attribute1          => px_trans_rec.desc_flex.attribute1,
                 X_Attribute2          => px_trans_rec.desc_flex.attribute2,
                 X_Attribute3          => px_trans_rec.desc_flex.attribute3,
                 X_Attribute4          => px_trans_rec.desc_flex.attribute4,
                 X_Attribute5          => px_trans_rec.desc_flex.attribute5,
                 X_Attribute6          => px_trans_rec.desc_flex.attribute6,
                 X_Attribute7          => px_trans_rec.desc_flex.attribute7,
                 X_Attribute8          => px_trans_rec.desc_flex.attribute8,
                 X_Attribute9          => px_trans_rec.desc_flex.attribute9,
                 X_Attribute10         => px_trans_rec.desc_flex.attribute10,
                 X_Attribute11         => px_trans_rec.desc_flex.attribute11,
                 X_Attribute12         => px_trans_rec.desc_flex.attribute12,
                 X_Attribute13         => px_trans_rec.desc_flex.attribute13,
                 X_Attribute14         => px_trans_rec.desc_flex.attribute14,
                 X_Attribute15         => px_trans_rec.desc_flex.attribute15,
                 X_Attribute_Category_Code=> px_trans_rec.desc_flex.attribute_category_code,
                 X_Transaction_Key     => px_trans_rec.transaction_key,
                 X_Amortization_Start_Date
                                       => NULL,
                 X_Calling_Interface   => px_trans_rec.calling_interface,
                 X_Mass_Transaction_ID => px_trans_rec.mass_transaction_id,
                 X_Event_ID            => px_trans_rec.event_id,
                 X_Return_status       => l_success,
                 X_calling_FN          =>'FA_DISTRIBUTION_PVT.insert_txn_headers',  p_log_level_rec => p_log_level_rec);

   if (not l_success) then
       return FALSE;
   end if;

   px_trans_rec.transaction_header_id := l_txn_head_id;
   return TRUE;

EXCEPTION
   when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'FA_DISTRIBUTION_PVT.insert_txn_headers',  p_log_level_rec => p_log_level_rec);
        return FALSE;

END insert_txn_headers;



FUNCTION update_asset_history(p_trans_rec          IN FA_API_TYPES.trans_rec_type,
                               p_asset_hdr_rec     IN FA_API_TYPES.asset_hdr_rec_type,
                               p_asset_cat_rec_new IN FA_API_TYPES.asset_cat_rec_type,
                               p_asset_desc_rec_new IN FA_API_TYPES.asset_desc_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

RETURN BOOLEAN IS

  CURSOR ah_cur (l_asset_id in NUMBER) IS
        select ah.rowid row_id,
                asset_id,
                category_id,
                asset_type,
                units,
                date_effective,
                date_ineffective,
                transaction_header_id_in,
                transaction_header_id_out,
                last_update_date,
                last_updated_by,
                last_update_login
        from fa_asset_history ah
        where asset_id = l_asset_id
        and date_ineffective is null;

  ah_rec        ah_cur%ROWTYPE;
  l_rowid       ROWID;
  l_success     boolean;
  l_asset_id    number;
  l_txn_id      number;

  BEGIN

     if (p_trans_rec.transaction_type_code = 'TRANSFER OUT') then
         select transaction_header_id_in
         into l_txn_id
         from fa_retirements
         where asset_id = p_asset_hdr_rec.asset_id
         and   book_type_code = p_asset_hdr_rec.book_type_code
         and   status = 'PENDING';
         --l_txn_id := 9999;
     else
         l_txn_id := p_trans_rec.transaction_header_id;
     end if;

     open ah_cur(p_asset_hdr_rec.asset_id);
     fetch ah_cur into ah_rec;
     close ah_cur;
        --
     if (p_asset_hdr_rec.period_of_addition = 'Y' and
         G_release = 11) then

        FA_ASSET_HISTORY_PKG.Update_Row
                (X_Rowid                  => ah_rec.Row_Id,
                 X_Asset_Id               => ah_rec.Asset_Id,
                 X_Category_Id            => p_asset_cat_rec_new.category_id,
                 X_Asset_Type             => ah_rec.Asset_Type,
                 X_Units                  => p_asset_desc_rec_new.current_units,
                 X_Date_Effective         => ah_rec.Date_Effective,
                 X_Date_Ineffective       => ah_rec.date_ineffective,
                 X_Transaction_Header_Id_In =>
                                ah_rec.Transaction_Header_Id_In,
                 X_Transaction_Header_Id_Out=> ah_rec.transaction_header_id_out,
                 X_Last_Update_Date       => p_trans_rec.who_info.last_update_date,
                 X_Last_Updated_By        => p_trans_rec.who_info.last_updated_by,
                 X_Last_Update_Login      => p_trans_rec.who_info.last_update_login,
                 X_Return_Status          => l_success,
                 X_Calling_Fn             => 'FA_DISTRIBUTION_PVT.update_asset_history',  p_log_level_rec => p_log_level_rec);
        if (not l_success) then
           return FALSE;
        end if;

     else

        -- terminate old_asset_history
        FA_ASSET_HISTORY_PKG.Update_Row
                (X_Rowid                  => ah_rec.Row_Id,
                 X_Asset_Id               => ah_rec.Asset_Id,
                 X_Category_Id            => ah_rec.Category_Id,
                 X_Asset_Type             => ah_rec.Asset_Type,
                 X_Units                  => ah_rec.Units,
                 X_Date_Effective         => ah_rec.Date_Effective,
                 X_Date_Ineffective       => p_trans_rec.who_info.last_update_date,
                 X_Transaction_Header_Id_In =>
                                ah_rec.Transaction_Header_Id_In,
                 X_Transaction_Header_Id_Out=> l_txn_id,
                 X_Last_Update_Date       => p_trans_rec.who_info.last_update_date,
                 X_Last_Updated_By        => p_trans_rec.who_info.last_updated_by,
                 X_Last_Update_Login      => p_trans_rec.who_info.last_update_login,
                 X_Return_Status          => l_success,
                 X_Calling_Fn             => 'FA_DISTRIBUTION_PVT.update_asset_history',  p_log_level_rec => p_log_level_rec);
        if (not l_success) then
           return FALSE;
        end if;


        -- insert new row with new units and new category if applicable
        FA_ASSET_HISTORY_PKG.Insert_Row
                (X_Rowid                  => l_rowid,
                 X_Asset_Id               => p_asset_hdr_rec.asset_id,
                 X_Category_Id            => p_asset_cat_rec_new.category_id,
                 X_Asset_Type             => ah_rec.asset_type,
                 X_Units                  => p_asset_desc_rec_new.current_units,
                 X_Date_Effective         => p_trans_rec.who_info.last_update_date,
                 X_Date_Ineffective       => NULL,
                 X_Transaction_Header_Id_In=> l_txn_id,
                 X_Transaction_Header_Id_Out=> NULL,
                 X_Last_Update_Date       => p_trans_rec.who_info.last_update_date,
                 X_Last_Updated_By        => p_trans_rec.who_info.last_updated_by,
                 X_Last_Update_Login      => p_trans_rec.who_info.last_update_login,
                 X_Return_Status          => l_success,
                 X_Calling_Fn             => 'FA_DISTRIBUTION_PVT.update_asset_history',  p_log_level_rec => p_log_level_rec);
        if (not l_success) then
           return FALSE;
        end if;

     end if;
     return TRUE;

  EXCEPTION
        WHEN Others THEN
              fa_srvr_msg.add_sql_error(
                        calling_fn => 'FA_DISTRIBUTION_PVT.update_asset_history',  p_log_level_rec => p_log_level_rec);
              return FALSE;
  END update_asset_history;


FUNCTION update_additions(p_trans_rec         IN  FA_API_TYPES.trans_rec_type,
                          p_asset_hdr_rec     IN  FA_API_TYPES.asset_hdr_rec_type,
                          p_asset_cat_rec_new IN  FA_API_TYPES.asset_cat_rec_type,
                          p_asset_desc_rec_new IN FA_API_TYPES.asset_desc_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

BEGIN
     if (p_trans_rec.transaction_type_code in ('UNIT ADJUSTMENT','TRANSFER OUT')) then
         update fa_additions_b
         set current_units = p_asset_desc_rec_new.current_units,
             last_update_date = p_trans_rec.who_info.last_update_date,
             last_update_login = p_trans_rec.who_info.last_update_login,
             last_updated_by   = p_trans_rec.who_info.last_updated_by
        where asset_id = p_asset_hdr_rec.asset_id;

     elsif (p_trans_rec.transaction_type_code = 'RECLASS') then
        if not fa_cache_pkg.fazcat(p_asset_cat_rec_new.category_id, p_log_level_rec => p_log_level_rec) then
            return FALSE;
        end if;

        -- Bug 3148518 : Assign context with context value not attribute_category_code

        update fa_additions_b
        set asset_category_id = p_asset_cat_rec_new.category_id,
            property_type_code = fa_cache_pkg.fazcat_record.property_type_code,
            property_1245_1250_code = fa_cache_pkg.fazcat_record.property_1245_1250_code,
            owned_leased = fa_cache_pkg.fazcat_record.owned_leased,
            attribute1 = p_asset_cat_rec_new.desc_flex.attribute1,
            attribute2 = p_asset_cat_rec_new.desc_flex.attribute2,
            attribute3 = p_asset_cat_rec_new.desc_flex.attribute3,
            attribute4 = p_asset_cat_rec_new.desc_flex.attribute4,
            attribute5 = p_asset_cat_rec_new.desc_flex.attribute5,
            attribute6 = p_asset_cat_rec_new.desc_flex.attribute6,
            attribute7 = p_asset_cat_rec_new.desc_flex.attribute7,
            attribute8 = p_asset_cat_rec_new.desc_flex.attribute8,
            attribute9 = p_asset_cat_rec_new.desc_flex.attribute9,
            attribute10 = p_asset_cat_rec_new.desc_flex.attribute10,
            attribute11 = p_asset_cat_rec_new.desc_flex.attribute11,
            attribute12 = p_asset_cat_rec_new.desc_flex.attribute12,
            attribute13 = p_asset_cat_rec_new.desc_flex.attribute13,
            attribute14 = p_asset_cat_rec_new.desc_flex.attribute14,
            attribute15 = p_asset_cat_rec_new.desc_flex.attribute15,
            attribute16 = p_asset_cat_rec_new.desc_flex.attribute16,
            attribute17 = p_asset_cat_rec_new.desc_flex.attribute17,
            attribute18 = p_asset_cat_rec_new.desc_flex.attribute18,
            attribute19 = p_asset_cat_rec_new.desc_flex.attribute19,
            attribute20 = p_asset_cat_rec_new.desc_flex.attribute20,
            attribute21 = p_asset_cat_rec_new.desc_flex.attribute21,
            attribute22 = p_asset_cat_rec_new.desc_flex.attribute22,
            attribute23 = p_asset_cat_rec_new.desc_flex.attribute23,
            attribute24 = p_asset_cat_rec_new.desc_flex.attribute24,
            attribute25 = p_asset_cat_rec_new.desc_flex.attribute25,
            attribute26 = p_asset_cat_rec_new.desc_flex.attribute26,
            attribute27 = p_asset_cat_rec_new.desc_flex.attribute27,
            attribute28 = p_asset_cat_rec_new.desc_flex.attribute28,
            attribute29 = p_asset_cat_rec_new.desc_flex.attribute29,
            attribute30 = p_asset_cat_rec_new.desc_flex.attribute30,
            attribute_category_code =
                p_asset_cat_rec_new.desc_flex.attribute_category_code,
            context     = p_asset_cat_rec_new.desc_flex.context,
            last_update_date = p_trans_rec.who_info.last_update_date,
            last_update_login = p_trans_rec.who_info.last_update_login,
            last_updated_by   = p_trans_rec.who_info.last_updated_by
        where asset_id = p_asset_hdr_rec.asset_id;
     end if;

     if (p_trans_rec.transaction_type_code in ('TRANSFER','UNIT ADJUSTMENT')) then
         update fa_additions_b
         set unit_adjustment_flag = 'NO'
         where asset_id = p_asset_hdr_rec.asset_id
         and unit_adjustment_flag = 'YES';
     end if;
     return TRUE;

EXCEPTION
     when others then
         fa_srvr_msg.add_sql_error(
                calling_fn => 'FA_DISTRIBUTION_PVT.update_additions',  p_log_level_rec => p_log_level_rec);
         return FALSE;
END update_additions;


FUNCTION update_books(p_trans_rec      IN   FA_API_TYPES.trans_rec_type,
                      p_asset_hdr_rec  IN   FA_API_TYPES.asset_hdr_rec_type,
                      p_period_rec     IN   FA_API_TYPES.period_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   cursor prior_period_tax_books(l_asset_id in number,
                                 l_book_type_code in varchar2) is
          select bc.book_type_code,nvl(bc.allow_backdated_transfers_flag,'Y')
          from fa_book_controls bc,
               fa_books bk,
               fa_deprn_summary ds
          where bk.asset_id = l_asset_id
          and   bk.book_type_code = bc.book_type_code
          and   bk.date_ineffective is null
          and   nvl(bc.date_ineffective, sysdate+1) > sysdate
          and   bc.distribution_source_book = l_book_type_code
          and   bc.book_class = 'TAX'
          -- bug# 2152033 only updates assets which have been depreciated
          and   ds.asset_id       = bk.asset_id
          and   ds.book_type_code = bc.book_type_code
          and   ds.period_counter < bc.last_period_counter
          and   ds.deprn_source_code = 'BOOKS';
  --bug fix 2186234 starts
     cursor prior_period_tfr_tax_books (l_asset_id in number,
                                        l_book_type_code in varchar2) is
     select distinct transaction_header_id
     from fa_adjustments adj
     where adj.asset_id = l_asset_id
     and adj.book_type_code = l_book_type_code
     and source_type_code = 'TRANSFER'
     and adj.period_counter_created =
     (select period_counter from fa_deprn_periods where book_type_code =
      l_book_type_code and period_close_date is null);
   --bug fix 2186234 ends


l_cal_period_close_date  DATE;
l_tax_cal_period_close_date DATE;
l_tax_cal_period_open_date  DATE;
l_tax_book_type_code p_asset_hdr_rec.book_type_code%TYPE;
l_asset_id   number;
l_allow_backdated_transfers varchar2(1);
  --bug fix 2186234 starts
           l_trx_id number;
           trx_date_entered date;
           l_tax_flag  number;
   --bug fix 2186234 ends

BEGIN

    l_tax_flag:= 1;--bug fix 2186234
    -- if prior period transfer, update books
    if (p_trans_rec.transaction_date_entered < p_period_rec.calendar_period_open_date) then

        update fa_books fabk
        set adjustment_required_status = 'TFR',
            annual_deprn_rounding_flag = 'TFR'
        where fabk.asset_id = p_asset_hdr_rec.asset_id
        and fabk.book_type_code = p_asset_hdr_rec.book_type_code
        and fabk.date_ineffective is NULL;

        update fa_mc_books fabk
        set adjustment_required_status = 'TFR',
            annual_deprn_rounding_flag = 'TFR'
        where fabk.asset_id = p_asset_hdr_rec.asset_id
        and fabk.book_type_code = p_asset_hdr_rec.book_type_code
        and fabk.date_ineffective is NULL;

    end if;

    open prior_period_tax_books(p_asset_hdr_rec.asset_id,
                                p_asset_hdr_rec.book_type_code);
    loop
       fetch prior_period_tax_books into l_tax_book_type_code,l_allow_backdated_transfers;

       if (prior_period_tax_books%NOTFOUND) then
              exit;
       end if;

       -- get the current open period dates
       -- did not use common routine get_period_rec
       -- as it does extra select on fiscal yr which
       -- is redundant.
       select calendar_period_open_date
       into   l_tax_cal_period_open_date
       from   fa_deprn_periods
       where  book_type_code = l_tax_book_type_code
       and    period_close_date is null;

  --bug fix 2186234 starts
     begin
     open prior_period_tfr_tax_books (p_asset_hdr_rec.asset_id,
                                      l_tax_book_type_code);

        loop

            fetch prior_period_tfr_tax_books into l_trx_id;

            exit when prior_period_tfr_tax_books%notfound;

            select TRANSACTION_DATE_ENTERED into trx_date_entered from
                   fa_transaction_headers where transaction_header_id = l_trx_id;
           if (trx_date_entered < l_tax_cal_period_open_date)
           then
               l_tax_flag:= 0;

               update fa_books fabk
                set
               adjustment_required_status = 'NONE',
               annual_deprn_rounding_flag = NULL
               where  fabk.asset_id = p_asset_hdr_rec.asset_id
               and fabk.book_type_code = l_tax_book_type_code
               and fabk.date_ineffective is  NULL;

                update fa_mc_books fabk
                 set
                 adjustment_required_status = 'NONE',
                 annual_deprn_rounding_flag = NULL
                 where fabk.asset_id = p_asset_hdr_rec.asset_id
                 and fabk.book_type_code = l_tax_book_type_code
                 and fabk.date_ineffective is NULL;
               exit;

          end if;
        end loop;

        close prior_period_tfr_tax_books;
        EXCEPTION
        when no_data_found then
          l_tax_flag:= 1;
          close prior_period_tfr_tax_books;
    end;

   --bug fix 2186234 ends


       if (p_trans_rec.transaction_date_entered < l_tax_cal_period_open_date) then

           update fa_books fabk
           set adjustment_required_status = decode(l_allow_backdated_transfers,'N','NONE','TFR'),
               annual_deprn_rounding_flag = decode(l_allow_backdated_transfers,'N',NULL,'TFR')
           where fabk.asset_id = p_asset_hdr_rec.asset_id
           and fabk.book_type_code = l_tax_book_type_code
           and fabk.date_ineffective is NULL;

           update fa_mc_books fabk
           set adjustment_required_status = decode(l_allow_backdated_transfers,'N','NONE','TFR'),
               annual_deprn_rounding_flag = decode(l_allow_backdated_transfers,'N',NULL,'TFR')
           where fabk.asset_id = p_asset_hdr_rec.asset_id
           and fabk.book_type_code = l_tax_book_type_code
           and fabk.date_ineffective is NULL;

        end if;

    end loop;
    close prior_period_tax_books;

    return TRUE;

EXCEPTION
    when others then
         fa_srvr_msg.add_sql_error(
                calling_fn => 'FA_DISTRIBUTION_PVT.update_books',  p_log_level_rec => p_log_level_rec);
         return FALSE;

END update_books;

FUNCTION update_dist_history(p_trans_rec      IN     FA_API_TYPES.trans_rec_type,
                             p_asset_hdr_rec  IN   FA_API_TYPES.asset_hdr_rec_type,
                             p_asset_dist_tbl IN   FA_API_TYPES.asset_dist_tbl_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

  CURSOR dh_cur (l_asset_id IN NUMBER, l_distribution_id IN NUMBER) IS
        select dh.rowid row_id, dh.*
        from fa_distribution_history dh
        where asset_id = l_asset_id
        and   distribution_id = l_distribution_id
        and date_ineffective is null;

   dh_rec        dh_cur%ROWTYPE;
   l_rowid       ROWID;
   l_asset_id    number;
   l_distribution_id number;
   l_book_header_id NUMBER;
   l_tfr_det_dist_id NUMBER;
   l_retirement_id   NUMBER;
   l_ret_id          NUMBER;

BEGIN

   select transaction_header_id_in
   into l_Book_Header_Id
   from fa_books
   where asset_id = p_asset_hdr_rec.asset_id
   and book_type_code = p_asset_hdr_rec.book_type_code
   and date_ineffective is null;

   if p_trans_rec.transaction_type_code = 'TRANSFER OUT' then
      select retirement_id
      into l_retirement_id
      from fa_retirements
      where asset_id = p_asset_hdr_rec.asset_id
      and book_type_code = p_asset_hdr_rec.book_type_code
      and status = 'PENDING';
      --l_retirement_id := 8888;
   end if;


   FOR i in p_asset_dist_tbl.first..p_asset_dist_tbl.last LOOP

       l_rowid := NULL;
       l_distribution_id := NULL;
       if (p_asset_dist_tbl(i).distribution_id is not null) then

           open dh_cur(p_asset_hdr_rec.asset_id,
                       p_asset_dist_tbl(i).distribution_id);
           fetch dh_cur into dh_rec;
           close dh_cur;

           if (p_trans_rec.transaction_type_code = 'TRANSFER OUT') then
              l_ret_id := l_retirement_id;
           else
              l_ret_id := dh_rec.retirement_id;
           end if;

           -- partial unit change
           if ((p_asset_dist_tbl(i).transaction_units +
               p_asset_dist_tbl(i).units_assigned) > 0) then

               -- terminate old row
               FA_DISTRIBUTION_HISTORY_PKG.UPDATE_ROW
                       (X_Rowid                    => dh_rec.row_id,
                        X_Distribution_Id          => dh_rec.distribution_id,
                        X_Book_Type_Code           => dh_rec.book_type_code,
                        X_Asset_Id                 => dh_rec.asset_id,
                        X_Units_Assigned           => dh_rec.units_assigned,
                        X_Date_Effective           => dh_rec.date_effective,
                        X_Code_Combination_Id      => dh_rec.code_combination_id,
                        X_Location_Id              => dh_rec.location_id,
                        X_Transaction_Header_Id_In => dh_rec.transaction_header_id_in,
                        X_Last_Update_Date         => p_trans_rec.who_info.last_update_date,
                        X_Last_Updated_By          => p_trans_rec.who_info.last_updated_by,
                        X_Date_Ineffective         => p_trans_rec.who_info.last_update_date,
                        X_Assigned_To              => dh_rec.assigned_to,
                        X_Transaction_Header_Id_Out =>p_trans_rec.transaction_header_id,
                        X_Transaction_Units        => p_asset_dist_tbl(i).transaction_units,
                        X_Retirement_Id            => l_ret_id,
                        X_Last_Update_Login        => p_trans_rec.who_info.last_update_login,
                        X_Calling_Fn   => 'FA_DISTRIBUTION_PVT.update_dist_history', p_log_level_rec => p_log_level_rec);

               -- create new row with new units
               FA_DISTRIBUTION_HISTORY_PKG.INSERT_ROW
                       (X_Rowid                    => l_rowid,
                        X_Distribution_Id          => l_distribution_id,
                        X_Book_Type_Code           => dh_rec.book_type_code,
                        X_Asset_Id                 => dh_rec.asset_id,
                        X_Units_Assigned           => p_asset_dist_tbl(i).units_assigned +
                                                      p_asset_dist_tbl(i).transaction_units,
                        X_Date_Effective           => p_trans_rec.who_info.last_update_date,
                        X_Code_Combination_Id      => dh_rec.code_combination_id,
                        X_Location_Id              => dh_rec.location_id,
                        X_Transaction_Header_Id_In => p_trans_rec.transaction_header_id,
                        X_Last_Update_Date         => p_trans_rec.who_info.last_update_date,
                        X_Last_Updated_By          => p_trans_rec.who_info.last_updated_by,
                        X_Date_Ineffective         => NULL,
                        X_Assigned_To              => dh_rec.assigned_to,
                        X_Transaction_Header_Id_Out => NULL,
                        X_Transaction_Units        => NULL,
                        X_Retirement_Id            => NULL,
                        X_Last_Update_Login        => p_trans_rec.who_info.last_update_login,
                        X_Calling_Fn   => 'FA_DISTRIBUTION_PVT.update_dist_history', p_log_level_rec => p_log_level_rec);

           else -- full unit change, then terminate the row only

               FA_DISTRIBUTION_HISTORY_PKG.UPDATE_ROW
                       (X_Rowid                    => dh_rec.row_id,
                        X_Distribution_Id          => dh_rec.distribution_id,
                        X_Book_Type_Code           => dh_rec.book_type_code,
                        X_Asset_Id                 => dh_rec.asset_id,
                        X_Units_Assigned           => dh_rec.units_assigned,
                        X_Date_Effective           => dh_rec.date_effective,
                        X_Code_Combination_id      => dh_rec.code_combination_id,
                        X_Location_Id              => dh_rec.location_id,
                        X_Transaction_Header_Id_In => dh_rec.transaction_header_id_in,
                        X_Last_Update_Date         => p_trans_rec.who_info.last_update_date,
                        X_Last_Updated_By          => p_trans_rec.who_info.last_updated_by,
                        X_Date_Ineffective         => p_trans_rec.who_info.last_update_date,
                        X_Assigned_To              => dh_rec.assigned_to,
                        X_Transaction_Header_Id_Out =>p_trans_rec.transaction_header_id,
                        X_Transaction_Units        => p_asset_dist_tbl(i).transaction_units,
                        X_Retirement_Id            => l_ret_id,
                        X_Last_Update_Login        => p_trans_rec.who_info.last_update_login,
                        X_Calling_Fn   => 'FA_DISTRIBUTION_PVT.update_dist_history', p_log_level_rec => p_log_level_rec);
           end if;
           l_tfr_det_dist_id := p_asset_dist_tbl(i).distribution_id;
       else

           -- create new row with new units
           FA_DISTRIBUTION_HISTORY_PKG.INSERT_ROW
                       (X_Rowid                    => l_rowid,
                        X_Distribution_Id          => l_distribution_id,
                        X_Book_Type_Code           => p_asset_hdr_rec.book_type_code,
                        X_Asset_Id                 => p_asset_hdr_rec.asset_id,
                        X_Units_Assigned           => p_asset_dist_tbl(i).transaction_units,
                        X_Date_Effective           => p_trans_rec.who_info.last_update_date,
                        X_Code_Combination_Id      => p_asset_dist_tbl(i).expense_ccid,
                        X_Location_Id              => p_asset_dist_tbl(i).location_ccid,
                        X_Transaction_Header_Id_In => p_trans_rec.transaction_header_id,
                        X_Last_Update_Date         => p_trans_rec.who_info.last_update_date,
                        X_Last_Updated_By          => p_trans_rec.who_info.last_updated_by,
                        X_Date_Ineffective         => NULL,
                        X_Assigned_To              => p_asset_dist_tbl(i).assigned_to,
                        X_Transaction_Header_Id_Out => NULL,
                        X_Transaction_Units        => NULL,
                        X_Retirement_Id            => NULL,
                        X_Last_Update_Login        => p_trans_rec.who_info.last_update_login,
                        X_Calling_Fn   => 'FA_DISTRIBUTION_PVT.update_dist_history', p_log_level_rec => p_log_level_rec);
           l_tfr_det_dist_id := l_distribution_id;
       end if;


       if (p_trans_rec.transaction_type_code <> 'RECLASS') then
           FA_TRANSFER_DETAILS_PKG.INSERT_ROW
                (X_Rowid              => l_rowid,
                 X_Transfer_Header_Id => p_trans_rec.transaction_header_id,
                 X_Distribution_Id    => l_tfr_det_dist_id,
                 X_Book_Header_Id     => l_book_header_id,
                 X_Calling_Fn         => 'FA_DISTRIBUTION_PVT.update_dist_history',  p_log_level_rec => p_log_level_rec);
       end if;

   END LOOP;

   return TRUE;

EXCEPTION
      when others then
          fa_srvr_msg.add_sql_error(
                calling_fn => 'FA_DISTRIBUTION_PVT.update_dist_history',  p_log_level_rec => p_log_level_rec);
          return FALSE;
END update_dist_history;



END FA_DISTRIBUTION_PVT;

/
