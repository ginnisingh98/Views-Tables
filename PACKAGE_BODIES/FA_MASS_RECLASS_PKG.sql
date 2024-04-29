--------------------------------------------------------
--  DDL for Package Body FA_MASS_RECLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_RECLASS_PKG" AS
/* $Header: FAXMRCLB.pls 120.13.12010000.2 2009/07/19 14:05:05 glchen ship $ */

-- Mass reclass record from fa_mass_reclass table.
mr_rec     FA_MASS_REC_UTILS_PKG.mass_reclass_rec;

g_log_level_rec fa_api_types.log_level_rec_type;

/*====================================================================================+
|   PROCEDURE Do_Mass_Reclass                                                         |
+=====================================================================================*/


PROCEDURE Do_Mass_Reclass(
                p_mass_reclass_id    IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_processed_count       OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number) IS

   -- cursor to fetch mass reclass record from fa_mass_reclass
   CURSOR mass_reclass IS
   SELECT mr.mass_reclass_id,
          mr.book_type_code,
          mr.transaction_date_entered,
          mr.concurrent_request_id,
          mr.status,
          mr.asset_type,
          mr.location_id,
          mr.employee_id,
          mr.asset_key_id,
          mr.from_cost,
          mr.to_cost,
          mr.from_asset_number,
          mr.to_asset_number,
          mr.from_date_placed_in_service,
          mr.to_date_placed_in_service,
          mr.from_category_id,
          mr.to_category_id,
          mr.segment1_low, mr.segment2_low, mr.segment3_low, mr.segment4_low,
          mr.segment5_low, mr.segment6_low, mr.segment7_low, mr.segment8_low,
          mr.segment9_low, mr.segment10_low, mr.segment11_low, mr.segment12_low,
          mr.segment13_low, mr.segment14_low, mr.segment15_low, mr.segment16_low,
          mr.segment17_low, mr.segment18_low, mr.segment19_low, mr.segment20_low,
          mr.segment21_low, mr.segment22_low, mr.segment23_low, mr.segment24_low,
          mr.segment25_low, mr.segment26_low, mr.segment27_low, mr.segment28_low,
          mr.segment29_low, mr.segment30_low,
          mr.segment1_high, mr.segment2_high, mr.segment3_high, mr.segment4_high,
          mr.segment5_high, mr.segment6_high, mr.segment7_high, mr.segment8_high,
          mr.segment9_high, mr.segment10_high, mr.segment11_high, mr.segment12_high,
          mr.segment13_high, mr.segment14_high, mr.segment15_high, mr.segment16_high,
          mr.segment17_high, mr.segment18_high, mr.segment19_high, mr.segment20_high,
          mr.segment21_high, mr.segment22_high, mr.segment23_high, mr.segment24_high,
          mr.segment25_high, mr.segment26_high, mr.segment27_high, mr.segment28_high,
          mr.segment29_high, mr.segment30_high,
          mr.include_fully_rsvd_flag,
          mr.copy_cat_desc_flag,
          mr.inherit_deprn_rules_flag,
          mr.amortize_flag,
          mr.created_by,
          mr.creation_date,
          mr.last_updated_by,
          mr.last_update_login,
          mr.last_update_date
     FROM fa_mass_reclass mr
    WHERE mass_reclass_id = p_mass_reclass_Id;

   -- assets that meet the user's selection criteria.
   -- some assets selected by this cursor are discarded in the validation engine.
   CURSOR mass_reclass_assets IS
   SELECT ad.asset_id,
          ad.asset_number,
          ad.asset_category_id,
          dh.assigned_to
     FROM gl_code_combinations     gc,
          fa_distribution_history  dh,
          fa_book_controls         bc,
          fa_books                 bk,
          fa_additions_b           ad
    WHERE ad.asset_type = nvl(mr_rec.asset_type, ad.asset_type)
      AND ad.asset_number >= nvl(mr_rec.from_asset_number, ad.asset_number)
      AND ad.asset_number <= nvl(mr_rec.to_asset_number, ad.asset_number)
      AND nvl(ad.asset_key_ccid, -9999)  = nvl(mr_rec.asset_key_id,
                                               nvl(ad.asset_key_ccid, -9999))
      AND ad.asset_category_id = nvl(mr_rec.from_category_id, ad.asset_category_id)
      AND bk.book_type_code = mr_rec.book_type_code
      AND bk.book_type_code = bc.book_type_code
      -- corp book should be currently effective.
      AND nvl(bc.date_ineffective, sysdate+1) > sysdate
      AND bk.asset_id = ad.asset_id
      AND nvl(bk.disabled_flag, 'N') = 'N' --HH
      AND bk.date_ineffective IS NULL -- pick the most recent row.
      -- dpis, exp acct, employee, location, cost range: selection criteria
      -- for corporate book only.
      AND bk.date_placed_in_service >= nvl(mr_rec.from_dpis,
                                           bk.date_placed_in_service)
      AND bk.date_placed_in_service <= nvl(mr_rec.to_dpis,
                                           bk.date_placed_in_service)
      AND bk.cost >= nvl(mr_rec.from_cost, bk.cost)
      AND bk.cost <= nvl(mr_rec.to_cost, bk.cost)
      AND dh.asset_id = ad.asset_id
      AND nvl(dh.assigned_to, -9999) = nvl(mr_rec.employee_id, nvl(dh.assigned_to, -9999))
      AND dh.location_id = nvl(mr_rec.location_id, dh.location_id)
      AND dh.date_ineffective IS NULL -- pick only the active distributions.
      AND dh.code_combination_id = gc.code_combination_id
      -- more check is done on retired asset in reclass validation engine.
      -- more check is done on reserved asset in Check_Criteria function.
      AND bk.period_counter_fully_retired IS NULL
      -- cannot avoid the use of OR, since gc.segment1 can be null.
      -- cannot use nvl(gc.segment1, 'NULL') for comparison, since
      -- the value 'NULL' may fall between the range accidentally.
      -- may break the OR to UNION later.
      -- rule-based optimizer transforms OR to UNION ALL automatically
      -- when it sees it being more efficient.  since the columns
      -- in OR are not indexed, transforming to UNION ALL has
      -- no gain in performance and using OR is unavoidable here
      -- for the correctness of the program.
      AND ((gc.segment1 between nvl(mr_rec.segment1_low, gc.segment1)
                     and nvl(mr_rec.segment1_high, gc.segment1)) OR
           (mr_rec.segment1_low IS NULL and mr_rec.segment1_high IS NULL))
      AND ((gc.segment2 between nvl(mr_rec.segment2_low, gc.segment2)
                     and nvl(mr_rec.segment2_high, gc.segment2)) OR
           (mr_rec.segment2_low IS NULL and mr_rec.segment2_high IS NULL))
      AND ((gc.segment3 between nvl(mr_rec.segment3_low, gc.segment3)
                     and nvl(mr_rec.segment3_high, gc.segment3)) OR
           (mr_rec.segment3_low IS NULL and mr_rec.segment3_high IS NULL))
      AND ((gc.segment4 between nvl(mr_rec.segment4_low, gc.segment4)
                     and nvl(mr_rec.segment4_high, gc.segment4)) OR
           (mr_rec.segment4_low IS NULL and mr_rec.segment4_high IS NULL))
      AND ((gc.segment5 between nvl(mr_rec.segment5_low, gc.segment5)
                     and nvl(mr_rec.segment5_high, gc.segment5)) OR
           (mr_rec.segment5_low IS NULL and mr_rec.segment5_high IS NULL))
      AND ((gc.segment6 between nvl(mr_rec.segment6_low, gc.segment6)
                     and nvl(mr_rec.segment6_high, gc.segment6)) OR
           (mr_rec.segment6_low IS NULL and mr_rec.segment6_high IS NULL))
      AND ((gc.segment7 between nvl(mr_rec.segment7_low, gc.segment7)
                     and nvl(mr_rec.segment7_high, gc.segment7)) OR
           (mr_rec.segment7_low IS NULL and mr_rec.segment7_high IS NULL))
      AND ((gc.segment8 between nvl(mr_rec.segment8_low, gc.segment8)
                     and nvl(mr_rec.segment8_high, gc.segment8)) OR
           (mr_rec.segment8_low IS NULL and mr_rec.segment8_high IS NULL))
      AND ((gc.segment9 between nvl(mr_rec.segment9_low, gc.segment9)
                     and nvl(mr_rec.segment9_high, gc.segment9)) OR
           (mr_rec.segment9_low IS NULL and mr_rec.segment9_high IS NULL))
      AND ((gc.segment10 between nvl(mr_rec.segment10_low, gc.segment10)
                     and nvl(mr_rec.segment10_high, gc.segment10)) OR
           (mr_rec.segment10_low IS NULL and mr_rec.segment10_high IS NULL))
      AND ((gc.segment11 between nvl(mr_rec.segment11_low, gc.segment11)
                     and nvl(mr_rec.segment11_high, gc.segment11)) OR
           (mr_rec.segment11_low IS NULL and mr_rec.segment11_high IS NULL))
      AND ((gc.segment12 between nvl(mr_rec.segment12_low, gc.segment12)
                     and nvl(mr_rec.segment12_high, gc.segment12)) OR
           (mr_rec.segment12_low IS NULL and mr_rec.segment12_high IS NULL))
      AND ((gc.segment13 between nvl(mr_rec.segment13_low, gc.segment13)
                     and nvl(mr_rec.segment13_high, gc.segment13)) OR
           (mr_rec.segment13_low IS NULL and mr_rec.segment13_high IS NULL))
      AND ((gc.segment14 between nvl(mr_rec.segment14_low, gc.segment14)
                     and nvl(mr_rec.segment14_high, gc.segment14)) OR
           (mr_rec.segment14_low IS NULL and mr_rec.segment14_high IS NULL))
      AND ((gc.segment15 between nvl(mr_rec.segment15_low, gc.segment15)
                     and nvl(mr_rec.segment15_high, gc.segment15)) OR
           (mr_rec.segment15_low IS NULL and mr_rec.segment15_high IS NULL))
      AND ((gc.segment16 between nvl(mr_rec.segment16_low, gc.segment16)
                     and nvl(mr_rec.segment16_high, gc.segment16)) OR
           (mr_rec.segment16_low IS NULL and mr_rec.segment16_high IS NULL))
      AND ((gc.segment17 between nvl(mr_rec.segment17_low, gc.segment17)
                     and nvl(mr_rec.segment17_high, gc.segment17)) OR
           (mr_rec.segment17_low IS NULL and mr_rec.segment17_high IS NULL))
      AND ((gc.segment18 between nvl(mr_rec.segment18_low, gc.segment18)
                     and nvl(mr_rec.segment18_high, gc.segment18)) OR
           (mr_rec.segment18_low IS NULL and mr_rec.segment18_high IS NULL))
      AND ((gc.segment19 between nvl(mr_rec.segment19_low, gc.segment19)
                     and nvl(mr_rec.segment19_high, gc.segment19)) OR
           (mr_rec.segment19_low IS NULL and mr_rec.segment19_high IS NULL))
      AND ((gc.segment20 between nvl(mr_rec.segment20_low, gc.segment20)
                     and nvl(mr_rec.segment20_high, gc.segment20)) OR
           (mr_rec.segment20_low IS NULL and mr_rec.segment20_high IS NULL))
      AND ((gc.segment21 between nvl(mr_rec.segment21_low, gc.segment21)
                     and nvl(mr_rec.segment21_high, gc.segment21)) OR
           (mr_rec.segment21_low IS NULL and mr_rec.segment21_high IS NULL))
      AND ((gc.segment22 between nvl(mr_rec.segment22_low, gc.segment22)
                     and nvl(mr_rec.segment22_high, gc.segment22)) OR
           (mr_rec.segment22_low IS NULL and mr_rec.segment22_high IS NULL))
      AND ((gc.segment23 between nvl(mr_rec.segment23_low, gc.segment23)
                     and nvl(mr_rec.segment23_high, gc.segment23)) OR
           (mr_rec.segment23_low IS NULL and mr_rec.segment23_high IS NULL))
      AND ((gc.segment24 between nvl(mr_rec.segment24_low, gc.segment24)
                     and nvl(mr_rec.segment24_high, gc.segment24)) OR
           (mr_rec.segment24_low IS NULL and mr_rec.segment24_high IS NULL))
      AND ((gc.segment25 between nvl(mr_rec.segment25_low, gc.segment25)
                     and nvl(mr_rec.segment25_high, gc.segment25)) OR
           (mr_rec.segment25_low IS NULL and mr_rec.segment25_high IS NULL))
      AND ((gc.segment26 between nvl(mr_rec.segment26_low, gc.segment26)
                     and nvl(mr_rec.segment26_high, gc.segment26)) OR
           (mr_rec.segment26_low IS NULL and mr_rec.segment26_high IS NULL))
      AND ((gc.segment27 between nvl(mr_rec.segment27_low, gc.segment27)
                     and nvl(mr_rec.segment27_high, gc.segment27)) OR
            (mr_rec.segment27_low IS NULL and mr_rec.segment27_high IS NULL))
      AND ((gc.segment28 between nvl(mr_rec.segment28_low, gc.segment28)
                     and nvl(mr_rec.segment28_high, gc.segment28)) OR
           (mr_rec.segment28_low IS NULL and mr_rec.segment28_high IS NULL))
      AND ((gc.segment29 between nvl(mr_rec.segment29_low, gc.segment29)
                     and nvl(mr_rec.segment29_high, gc.segment29)) OR
           (mr_rec.segment29_low IS NULL and mr_rec.segment29_high IS NULL))
      AND ((gc.segment30 between nvl(mr_rec.segment30_low, gc.segment30)
                     and nvl(mr_rec.segment30_high, gc.segment30)) OR
           (mr_rec.segment30_low IS NULL and mr_rec.segment30_high IS NULL))
      AND ad.asset_id > px_max_asset_id
      AND MOD(ad.asset_id, p_total_requests) = (p_request_number - 1)
    ORDER BY ad.asset_id;

   -- local variables
   TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE num_tbl  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;

   l_asset_number               v30_tbl;
   l_asset_id                   num_tbl;
   l_asset_category_id          num_tbl;
   l_assigned_to                num_tbl;

   l_msg_count       NUMBER := 0;
   l_msg_data        VARCHAR2(2000) := NULL;
   l_return_status   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   l_rowcount        NUMBER;
   l_warn_status     BOOLEAN := FALSE;

   -- to keep track of the last asset id that entered the mass_reclass_assets
   -- cursor loop.  we need this to avoid DISTINCT in the SELECT statement
   -- for mass_reclass_assets cursor.  asset may be selected multiple times
   -- if it is multi-distributed and if more than one distribution lines
   -- meet the reclass selection criteria(if at least one distribution line
   -- meets user criteria, the asset is selected for reclass.)
   l_last_asset       NUMBER(15) := NULL;
   l_status           BOOLEAN := FALSE;
   l_dummy_num        NUMBER;
   l_cat_flex_struct  NUMBER;
   l_concat_cat       VARCHAR2(220);
   l_cat_segs         fa_rx_shared_pkg.Seg_Array;

   -- counter to keep track of the number of assets that entered the
   -- mass_reclass_assets cursor loop and passed Check_Criteria.
   -- this counter is reset to zero, at every 200 assets.
   l_counter          NUMBER := 0;

   -- used for bulk fetch
   l_batch_size       NUMBER;
   l_loop_count       NUMBER;

   -- used for api call
   l_trans_rec        FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
   l_asset_cat_rec    FA_API_TYPES.asset_cat_rec_type;
   l_recl_opt_rec     FA_API_TYPES.reclass_options_rec_type;

   l_calling_fn       VARCHAR2(50) := 'FA_MASS_RECLASS_PKG.DO_RECLASS';
   l_string           varchar2(250);

   mrcl_failure       EXCEPTION; -- mass reclass failure
   done_exc           EXCEPTION;

BEGIN

   px_max_asset_id := nvl(px_max_asset_id, 0);
   x_processed_count := 0;
   x_success_count := 0;
   x_failure_count := 0;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  mrcl_failure;
      end if;
   end if;

   if (px_max_asset_id = 0) then

      FND_FILE.put(FND_FILE.output,'');
      FND_FILE.new_line(FND_FILE.output,1);

      -- dump out the headings
      fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_COLUMN');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

      fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_LINE');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

   end if;

   -- Fetch mass reclass record information.
   OPEN  mass_reclass;
   FETCH mass_reclass INTO mr_rec;
   CLOSE mass_reclass;

   if not (fa_cache_pkg.fazcbc(X_book => mr_rec.book_type_code, p_log_level_rec => g_log_level_rec)) then
      raise mrcl_failure;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   l_recl_opt_rec.copy_cat_desc_flag := mr_rec.copy_cat_desc_flag;
   l_recl_opt_rec.redefault_flag     := mr_rec.redefault_flag;
   l_asset_cat_rec.category_id       := mr_rec.to_category_id;
   l_asset_hdr_rec.book_type_code    := mr_rec.book_type_code;

   /*===========================================================================
     Check if reclass transaction date for the mass reclass record from
     mass reclass form is in the current corporate book period.
     (No prior period reclass is allowed.)
    ===========================================================================*/

   if px_max_asset_id = 0 then
      IF NOT Check_Trans_Date(
            X_Corp_Book      => mr_rec.book_type_code,
            X_Trans_Date     => mr_rec.trans_date_entered) THEN
         RAISE mrcl_failure;
      END IF;
   end if;

   /*===========================================================================
     Perform mass reclass.
    ===========================================================================*/
   IF (mr_rec.redefault_flag = 'YES') THEN
      -- Depreciation rules will be redefaulted.
      -- Reset g_deprn_count before initiating mass reclass transaction.
      FA_LOAD_TBL_PKG.g_deprn_count := 0;

      -- Load depreciation rules table for the corporate book and all the
      -- associated tax books for the new category.
      -- Simulates caching effect.
      FA_LOAD_TBL_PKG.Load_Deprn_Rules_Tbl(
          p_corp_book       => mr_rec.book_type_code,
          p_category_id     => mr_rec.to_category_id,
          x_return_status   => l_status, p_log_level_rec => g_log_level_rec);
      IF NOT l_status THEN
         RAISE mrcl_failure;
      END IF;
   END IF;

   /* Get the new category code from the new category id. */
   if not fa_cache_pkg.fazsys(g_log_level_rec) then
      RAISE mrcl_failure;
   end if;

   l_cat_flex_struct := fa_cache_pkg.fazsys_record.category_flex_structure;

   FA_RX_SHARED_PKG.Concat_Category(
             struct_id      => l_cat_flex_struct,
             ccid           => mr_rec.to_category_id,
             concat_string  => l_concat_cat,
             segarray       => l_cat_segs);


   /* Loop all the qualified assets, and perform mass reclass. */
   OPEN mass_reclass_assets;
   FETCH mass_reclass_assets BULK COLLECT INTO
         l_asset_id,
         l_asset_number,
         l_asset_category_id,
         l_assigned_to
   LIMIT l_batch_size;
   close mass_reclass_assets;

   x_processed_count := l_asset_id.count;

   if (l_asset_id.count = 0) then
      raise done_exc;
   end if;

   for l_loop_count in 1..l_asset_id.count loop

      -- clear the debug stack for each asset
      FA_DEBUG_PKG.Initialize;
      -- reset the message level to prevent bogus errors
      FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

      if NOT l_warn_status then
         if not FA_ASSET_VAL_PVT.validate_assigned_to (
                p_transaction_type_code => 'RECLASS',
                p_assigned_to           => l_assigned_to(l_loop_count),
                p_date                  => mr_rec.trans_date_entered,
                p_calling_fn            => l_calling_fn,
                p_log_level_rec         => g_log_level_rec
               ) then
             l_warn_status := TRUE; -- set to warning when invalid employee encountered
         end if;
      end if;

      IF (l_asset_id(l_loop_count) <> l_last_asset OR l_last_asset IS NULL) THEN
      -- Skip the reclass, if the asset has already entered this loop before.
      -- Using l_last_asset to keep track of the last asset that entered the
      -- cursor loop instead of using DISTINCT in the SELECT statement for
      -- mass_reclass_assets cursor.

         -- Save the asset id for the next loop.
         l_last_asset := l_asset_id(l_loop_count);

         IF Check_Criteria(
               X_Asset_Id            => l_asset_id(l_loop_count),
               X_Fully_Rsvd_Flag     => mr_rec.fully_rsvd_flag) THEN
            -- Perform reclass only on the assets that meet all the user
            -- selection criteria.

            fa_srvr_msg.add_message(
                calling_fn => NULL,
                name       => 'FA_SHARED_ASSET_NUMBER',
                token1     => 'NUMBER',
                value1     => l_asset_number(l_loop_count),
                p_log_level_rec => g_log_level_rec);

            IF (l_asset_category_id(l_loop_count) = mr_rec.to_category_id) THEN
               -- Reclass and redefault are not processed on the asset, if
               -- the new category is the same as the old category.
               -- This asset is printed on the log with a message, but is not
               -- counted as a Processed asset.
               -- (The log prints number of assets processed, number of success,
               --  number of failures.)

               -- List asset number and the message.
               -- use the write_message util

               write_message(l_asset_number(l_loop_count),
                             'FA_REC_NOT_PROCESSED');

               /*
               fnd_message.set_name('OFA', 'FA_SHARED_ASSET_NUMBER');
               fnd_message.set_token('NUMBER', l_asset_number(l_loop_count), FALSE);
               fnd_msg_pub.add;
               FA_SRVR_MSG.Add_Message(
                     CALLING_FN => l_calling_fn,
                     NAME       => 'FA_REC_NOT_PROCESSED',
                     TOKEN1     => 'ASSET',
                     VALUE1     => l_asset_number(l_loop_count));
               */
               -- Increment the counter.
               -- Increment only the counter for messaging.  This asset is
               -- not considered a Processed asset.
               l_counter := l_counter + 1;

            ELSE
               -- validation ok, null out then load the structs and process the adjustment
               l_trans_rec.transaction_header_id     := NULL;
               l_trans_rec.who_info.last_update_date := sysdate;
               l_trans_rec.transaction_date_entered  := mr_rec.trans_date_entered;
               l_trans_rec.mass_reference_id         := p_parent_request_id;
               l_trans_rec.calling_interface         := 'FAMRCL';
               l_trans_rec.mass_transaction_id       := p_mass_reclass_id;

               l_asset_hdr_rec.asset_id              := l_asset_id(l_loop_count);
               l_asset_hdr_rec.period_of_addition    := null;

               if (mr_rec.amortize_flag = 'YES') then
                  l_trans_rec.transaction_subtype := 'AMORTIZED';
               else
                  l_trans_rec.transaction_subtype := 'EXPENSED';
               end if;


               /* Call the new Reclass Public API for each asset. */

               FA_RECLASS_PUB.do_reclass (
                      -- std parameters
                      p_api_version         => 1.0,
                      p_init_msg_list       => FND_API.G_FALSE,
                      p_commit              => FND_API.G_FALSE,
                      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                      p_calling_fn          => l_calling_fn,
                      x_return_status       => l_return_status,
                      x_msg_count           => l_msg_count,
                      x_msg_data            => l_msg_data,
                      -- api parameters
                      px_trans_rec          => l_trans_rec,
                      px_asset_hdr_rec      => l_asset_hdr_rec,
                      px_asset_cat_rec_new  => l_asset_cat_rec,
                      p_recl_opt_rec        => l_recl_opt_rec );

               IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  FND_CONCURRENT.AF_COMMIT;
                  l_counter       := l_counter + 1;
                  x_success_count := x_success_count + 1;

                  write_message(l_asset_number(l_loop_count),
                                'FA_MCP_RECLASS_SUCCESS');

               ELSE
                  /* 'W'(warning status) or error status. */
                  -- Partial failure(failure in redefault only) is counted as failure.
                  l_counter       := l_counter + 1;
                  x_failure_count := x_failure_count + 1;
                  write_message(l_asset_number(l_loop_count),
                                NULL);

               END IF;

               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;

            END IF; /* IF (l_category_id = mr_rec.to_category_id) */
         END IF;  /* IF Check_Criteria */
      END IF;  /* IF (l_asset_id <> l_last_asset OR l_last_asset IS NULL) */
   END LOOP;

   IF (mr_rec.redefault_flag = 'YES') THEN
      -- Reset g_deprn_count after completing mass reclass transaction.
      FA_LOAD_TBL_PKG.g_deprn_count := 0;
   END IF;

   FND_CONCURRENT.AF_COMMIT;

   px_max_asset_id  := l_asset_id(l_asset_id.count);
   if (l_warn_status) then
      x_return_status := 1;  -- return warning
   else
      x_return_status := 0;  -- success
   end if;

EXCEPTION
   WHEN done_exc then
        if (l_warn_status) then
           x_return_status := 1;
        else
           x_return_status :=  0;
        end if;

   WHEN mrcl_failure THEN
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
        FND_CONCURRENT.AF_ROLLBACK;
        FA_LOAD_TBL_PKG.g_deprn_count := 0;
        x_return_status := 2;

   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
        FND_CONCURRENT.AF_ROLLBACK;
        FA_LOAD_TBL_PKG.g_deprn_count := 0;
        x_return_status :=  2;

END Do_Mass_Reclass;


/*====================================================================================+
|   FUNCTION Check_Trans_Date                                                         |
+=====================================================================================*/

FUNCTION Check_Trans_Date(
     X_Corp_Book          IN     VARCHAR2,
     X_Trans_Date         IN     DATE
     )     RETURN BOOLEAN IS
   l_cp_open_date     DATE;
   l_cp_close_date    DATE;
   -- cursor to get the calendar period open date of the current corpote
   -- book period.
   CURSOR get_cp_open_close_date IS
   SELECT calendar_period_open_date,
          calendar_period_close_date
     FROM fa_deprn_periods
    WHERE book_type_code = X_Corp_Book
      AND period_close_date IS NULL;

BEGIN
   -- Check if the transaction date is in the current corporate book period.
   OPEN  get_cp_open_close_date;
   FETCH get_cp_open_close_date
    INTO l_cp_open_date,
         l_cp_close_date;
   CLOSE get_cp_open_close_date;

   IF (X_Trans_Date < l_cp_open_date OR
       X_Trans_date > l_cp_close_date) THEN
        FA_SRVR_MSG.Add_Message(
         CALLING_FN => 'FA_MASS_RECLASS_PKG.Check_Trans_Date',
         NAME       => 'FA_REC_INVALID_TRANS_DATE',  p_log_level_rec => g_log_level_rec);
      RETURN (FALSE);
   END IF;

   RETURN (TRUE);

EXCEPTION
   WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
             CALLING_FN => 'FA_MASS_RECLASS_PKG.Check_Trans_Date',  p_log_level_rec => g_log_level_rec);
        RETURN (FALSE);
END Check_Trans_Date;


/*====================================================================================+
|   FUNCTION Check_Criteria                                                           |
+=====================================================================================*/

FUNCTION Check_Criteria(
     X_Asset_Id            IN     NUMBER,
     X_Fully_Rsvd_Flag     IN     VARCHAR2
     )     RETURN BOOLEAN IS

   l_book         VARCHAR2(30);
   check_flag     VARCHAR2(15);

   -- cursor to get all the corporate and tax books the asset belongs to.
   CURSOR book_cr IS
   SELECT bk.book_type_code
     FROM fa_book_controls bc, fa_books bk
    WHERE bk.asset_id = X_Asset_Id
      AND bk.date_ineffective IS NULL
      AND bk.book_type_code = bc.book_type_code
      AND bc.book_class IN ('CORPORATE', 'TAX')
      AND nvl(bc.date_ineffective, sysdate+1) > sysdate;

   CURSOR check_not_rsvd IS
   SELECT 'NOT RESERVED'
     FROM fa_books bk
    WHERE bk.asset_id = X_Asset_Id
      AND bk.book_type_code = l_book
      AND bk.date_ineffective IS NULL
      AND bk.period_counter_fully_reserved IS NULL;

   CURSOR check_rsvd IS
   SELECT 'RESERVED'
     FROM fa_books bk
    WHERE bk.asset_id = X_Asset_Id
      AND bk.book_type_code = l_book
      AND bk.date_ineffective IS NULL
      AND bk.period_counter_fully_reserved IS NOT NULL;

BEGIN
   -- Check to make sure fully reserved asset selection criteria is met in
   -- all the books the asset belongs to.
   IF (X_Fully_Rsvd_Flag IS NOT NULL) THEN
      -- if x_fully_rsvd_flag is null, then we don't care whether the asset is
      -- reserved or not.
      OPEN book_cr;
      LOOP
         FETCH book_cr INTO l_book;
         EXIT WHEN book_cr%NOTFOUND;

         IF (X_Fully_Rsvd_Flag = 'YES') THEN
            OPEN check_not_rsvd;
            FETCH check_not_rsvd INTO check_flag;
            IF (check_not_rsvd%FOUND) THEN
               CLOSE check_not_rsvd;
            RETURN (FALSE);
            END IF;
            CLOSE check_not_rsvd;
         ELSIF (X_Fully_Rsvd_Flag = 'NO') THEN
            OPEN check_rsvd;
            FETCH check_rsvd INTO check_flag;
            IF (check_rsvd%FOUND) THEN
               CLOSE check_rsvd;
               RETURN (FALSE);
            END IF;
            CLOSE check_rsvd;
         END IF;

      END LOOP;

      CLOSE book_cr;

   END IF;

   RETURN (TRUE);

EXCEPTION
   WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
             CALLING_FN => 'FA_MASS_RECLASS_PKG.Check_Criteria',  p_log_level_rec => g_log_level_rec);
        RETURN (FALSE);

END Check_Criteria;

-----------------------------------------------------------------------------

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2) IS

   l_message      varchar2(30);
   l_mesg         varchar2(100);
   l_string       varchar2(512);
   l_calling_fn   varchar2(40);  -- conditionally populated below

BEGIN

   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd

   l_message := nvl(p_message,  'FA_MASSRCL_FAIL_TRX');

   if (l_message <> 'FA_MCP_RECLASS_SUCCESS' and
       l_message <> 'FA_REC_NOT_PROCESSED')  then
      l_calling_fn := 'fa_mass_reclass_pkg.do_reclass';
   end if;

   fnd_message.set_name('OFA', l_message);
   l_mesg := substrb(fnd_message.get, 1, 100);

   l_string       := rpad(p_asset_number, 15) || ' ' || l_mesg;

   FND_FILE.put(FND_FILE.output,l_string);
   FND_FILE.new_line(FND_FILE.output,1);

   -- now process the messages for the log file
   fa_srvr_msg.add_message
       (calling_fn => l_calling_fn,
        name       => l_message, p_log_level_rec => g_log_level_rec);

EXCEPTION
   when others then
       raise;

END write_message;

END FA_MASS_RECLASS_PKG;

/
