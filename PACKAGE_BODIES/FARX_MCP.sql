--------------------------------------------------------
--  DDL for Package Body FARX_MCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_MCP" AS
/* $Header: FARXMCPB.pls 120.3.12010000.3 2009/08/07 08:04:08 deemitta ship $ */

-- Mass change record from fa_mass_changes table.
mc_rec         FA_MASS_CHG_UTILS_PKG.mass_change_rec_type;

-- Table of asset records.
a_tbl          FA_MASS_CHG_UTILS_PKG.asset_tbl_type;

-- Index into the asset table, a_tbl.
a_index        NUMBER := 0;

-- Number of assets(disregaring book_type_code) stored in a_tbl.
-- Reset at every 200 assets.
g_asset_count      NUMBER := 0;

-- Total number of assets to be printed in report.
--g_total_assets      NUMBER := 0;

/* a_index <> g_asset_count if asset belongs to more than one book. */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;




/*============================================================================+
|   PROCEDURE Preview_Change                                                  |
+=============================================================================*/

PROCEDURE Preview_Change(
     X_Mass_Change_Id     IN     NUMBER,
     X_RX_Flag            IN     VARCHAR2 := 'NO',
     retcode              OUT NOCOPY NUMBER,
     errbuf               OUT NOCOPY VARCHAR2) IS

    -- cursor to fetch the current and preview status
    CURSOR get_status IS
        SELECT  lu_prev.meaning,
                lu_curr.meaning
        FROM    fa_lookups lu_prev,
                fa_lookups lu_curr
        WHERE   lu_prev.lookup_type = 'MASS_TRX_STATUS'  AND
                lu_prev.lookup_code = 'PREVIEW'
        AND     lu_curr.lookup_type = 'MASS_TRX_STATUS' AND
                lu_curr.lookup_code = mc_rec.status;

    -- cursor to get category flex structure.
    CURSOR get_cat_flex_struct IS
           SELECT category_flex_structure
             FROM fa_system_controls;

    -- cursor to fetch mass change record from fa_mass_change
    CURSOR mass_change IS
     SELECT mc.mass_change_id,
            mc.book_type_code,
            mc.transaction_date_entered,
            mc.concurrent_request_id,
            mc.status,
            mc.asset_type,
            mc.category_id,
            mc.from_asset_number,
            mc.to_asset_number,
            mc.from_date_placed_in_service,
            mc.to_date_placed_in_service,
            mc.from_convention,
            mc.to_convention,
            mc.from_method_code,
            mc.to_method_code,
            mc.from_life_in_months,
            mc.to_life_in_months,
            mc.from_bonus_rule,
            mc.to_bonus_rule,
            mc.date_effective,
            mc.from_basic_rate,
            mc.to_basic_rate,
            mc.from_adjusted_rate,
            mc.to_adjusted_rate,
            mc.from_production_capacity,
            mc.to_production_capacity,
            mc.from_uom,
            mc.to_uom,
            mc.from_group_association,
            mc.to_group_association,
            mc.from_group_asset_id,
            mc.to_group_asset_id,
            gad1.asset_number,
            gad2.asset_number,
            mc.change_fully_rsvd_assets,
            mc.amortize_flag,
            mc.created_by,
            mc.creation_date,
            mc.last_updated_by,
            mc.last_update_login,
            mc.last_update_date,
            mc.from_salvage_type,
            mc.to_salvage_type,
            mc.from_percent_salvage_value,
            mc.to_percent_salvage_value,
            mc.from_salvage_value,
            mc.to_salvage_value,
            mc.from_deprn_limit_type,
            mc.to_deprn_limit_type,
            mc.from_deprn_limit,
            mc.to_deprn_limit,
            mc.from_deprn_limit_amount,
            mc.to_deprn_limit_amount
       FROM fa_mass_changes mc,
            fa_additions_b gad1,
            fa_additions_b gad2
      WHERE mass_change_id = X_Mass_Change_Id
        AND mc.from_group_asset_id = gad1.asset_id(+)
        AND mc.to_group_asset_id   = gad2.asset_id(+);

    -- assets that meet the user's selection criteria.
    -- some assets selected by this cursor are discarded in the validation engine.
    CURSOR mass_change_assets IS
     SELECT ad.asset_id,
            ad.asset_number,
            ad.description,
            ad.asset_type,
            ad.asset_category_id,
            bk.prorate_convention_code,
            bk.deprn_method_code,
            bk.life_in_months,
            bk.bonus_rule,
            bk.basic_rate,
            bk.adjusted_rate,
            bk.production_capacity,
            bk.unit_of_measure,
            bk.book_type_code,
            gad.asset_number,
            bk.salvage_type,
            bk.percent_salvage_value,
            bk.salvage_value,
            bk.deprn_limit_type,
            bk.allowed_deprn_limit,
            bk.allowed_deprn_limit_amount
       FROM fa_books          bk,
            fa_additions      ad,
            fa_additions_b    gad,
            fa_mass_changes   mch
      WHERE mch.mass_change_id = mc_rec.mass_change_id
        AND ad.asset_type = nvl(mch.asset_type, ad.asset_type)
        AND ad.asset_type <> 'CIP'
        AND ad.asset_number >= nvl(mch.from_asset_number, ad.asset_number)
        AND ad.asset_number <= nvl(mch.to_asset_number, ad.asset_number)
        AND ad.asset_category_id = nvl(mch.category_id, ad.asset_category_id)
        AND bk.book_type_code = mch.book_type_code
        AND bk.asset_id = ad.asset_id
        AND NVL(bk.Disabled_flag, 'N') = 'N' --HH
        AND bk.date_ineffective IS NULL -- pick the most recent row.
        AND bk.period_counter_fully_retired IS NULL
        and nvl(bk.period_counter_fully_reserved,99)  =
                   nvl(bk.period_counter_life_complete,99)
        and nvl(bk.period_counter_fully_reserved, -1) =
                   decode(mch.change_fully_rsvd_assets, 'YES',
                          nvl(bk.period_counter_fully_reserved, -1), -1)
        and bk.date_placed_in_service                >=
                   nvl(mch.from_date_placed_in_service,
                       bk.date_placed_in_service)
        and bk.date_placed_in_service                <=
                   nvl(mch.to_date_placed_in_service,
                       bk.date_placed_in_service)
        and bk.deprn_method_code                      =
                   nvl(mch.from_method_code,
                       bk.deprn_method_code)
        and nvl(bk.life_in_months, -1)                =
                   nvl(mch.from_life_in_months,
                       nvl(bk.life_in_months, -1))
        and nvl(bk.basic_rate, -1)                    =
                   nvl(mch.from_basic_rate,
                       nvl(bk.basic_rate, -1))
        and nvl(bk.adjusted_rate, -1)                 =
                   nvl(mch.from_adjusted_rate,
                       nvl(bk.adjusted_rate, -1))
        and nvl(bk.production_capacity, -1)           =
                   nvl(mch.from_production_capacity,
                       nvl(bk.production_capacity, -1))
        and nvl(bk.unit_of_measure, -1)               =
                   nvl(mch.from_uom,
                       nvl(bk.unit_of_measure, -1))
        and bk.prorate_convention_code                =
                   nvl(mch.from_convention,
                       bk.prorate_convention_code)
        and nvl(bk.bonus_rule, -1)                    =
                   nvl(mch.from_bonus_rule,
                      nvl(bk.bonus_rule,-1))
        and ((mch.from_group_association is null) or
                (mch.from_group_association = 'STANDALONE' and
                 bk.group_asset_id is null) or
                (mch.from_group_association = 'MEMBER' and
                 nvl(bk.group_asset_id, -99) = mch.from_group_asset_id))
        AND     bk.group_asset_id = gad.asset_id(+)
        and nvl(bk.salvage_type, 'XX')                =
                   nvl(mch.from_salvage_type,
                       nvl(bk.salvage_type, 'XX'))
        and nvl(bk.salvage_value, -1)                 =
                   nvl(mch.from_salvage_value,
                       nvl(bk.salvage_value, -1))
        and nvl(bk.percent_salvage_value, -1)         =
                   nvl(mch.from_percent_salvage_value/100,
                      nvl(bk.percent_salvage_value, -1))
        and nvl(bk.deprn_limit_type, 'XX')            =
                   nvl(mch.from_deprn_limit_type,
                      nvl(bk.deprn_limit_type, 'XX'))
        and nvl(bk.allowed_deprn_limit_amount, -1)            =
                   nvl(mch.from_deprn_limit_amount,
                      nvl(bk.allowed_deprn_limit_amount, -1))
        and nvl(bk.allowed_deprn_limit, -1)                   =
                   nvl(mch.from_deprn_limit/100,
                      nvl(bk.allowed_deprn_limit, -1))
  MINUS
     SELECT ad.asset_id,
            ad.asset_number,
            ad.description,
            ad.asset_type,
            ad.asset_category_id,
            bk.prorate_convention_code,
            bk.deprn_method_code,
            bk.life_in_months,
            bk.bonus_rule,
            bk.basic_rate,
            bk.adjusted_rate,
            bk.production_capacity,
            bk.unit_of_measure,
            bk.book_type_code,
            gad.asset_number,
            bk.salvage_type,
            bk.percent_salvage_value,
            bk.salvage_value,
            bk.deprn_limit_type,
            bk.allowed_deprn_limit,
            bk.allowed_deprn_limit_amount
     FROM fa_books          bk,
          fa_additions      ad,
          fa_additions_b    gad,
          fa_mass_changes   mch
     WHERE mch.mass_change_id = mc_rec.mass_change_id
        AND ad.asset_type = nvl(mch.asset_type, ad.asset_type)
        AND ad.asset_type <> 'CIP'
        AND ad.asset_number >= nvl(mch.from_asset_number, ad.asset_number)
        AND ad.asset_number <= nvl(mch.to_asset_number, ad.asset_number)
        AND ad.asset_category_id = nvl(mch.category_id, ad.asset_category_id)
        AND bk.book_type_code = mch.book_type_code
        AND bk.asset_id = ad.asset_id
        AND NVL(bk.Disabled_flag, 'N') = 'N' --HH
        AND bk.date_ineffective IS NULL -- pick the most recent row.
        AND bk.period_counter_fully_retired IS NULL
        and nvl(bk.period_counter_fully_reserved,99)  =
                   nvl(bk.period_counter_life_complete,99)
        and nvl(bk.period_counter_fully_reserved, -1) =
                   decode(mch.change_fully_rsvd_assets, 'YES',
                          nvl(bk.period_counter_fully_reserved, -1), -1)
        and bk.date_placed_in_service                >=
                   nvl(mch.from_date_placed_in_service,
                       bk.date_placed_in_service)
        and bk.date_placed_in_service                <=
                   nvl(mch.to_date_placed_in_service,
                       bk.date_placed_in_service)
        and bk.deprn_method_code                      =
                   nvl(mch.to_method_code,
                       bk.deprn_method_code)
        and nvl(bk.life_in_months, -1)                =
                   nvl(mch.to_life_in_months,
                       nvl(bk.life_in_months, -1))
        and nvl(bk.basic_rate, -1)                    =
                   nvl(mch.to_basic_rate,
                       nvl(bk.basic_rate, -1))
        and nvl(bk.adjusted_rate, -1)                 =
                   nvl(mch.to_adjusted_rate,
                       nvl(bk.adjusted_rate, -1))
        and nvl(bk.production_capacity, -1)           =
                   nvl(mch.to_production_capacity,
                       nvl(bk.production_capacity, -1))
        and nvl(bk.unit_of_measure, -1)               =
                   nvl(mch.to_uom,
                       nvl(bk.unit_of_measure, -1))
        and bk.prorate_convention_code                =
                   nvl(mch.to_convention,
                       bk.prorate_convention_code)
        and nvl(bk.bonus_rule, -1)                    =
                   nvl(mch.to_bonus_rule,
                      nvl(bk.bonus_rule,-1))
        and nvl (mch.to_group_association,'XXXX') = nvl (mch.from_group_association,'XXXX')
        and nvl (mch.to_group_asset_id,-99) = nvl (mch.from_group_asset_id,-99)
        and     bk.group_asset_id = gad.asset_id(+)
        and nvl(bk.salvage_type, 'XX')                =
                   nvl(mch.to_salvage_type,
                       nvl(bk.salvage_type, 'XX'))
        and nvl(bk.salvage_value, -1)                 =
                   nvl(mch.to_salvage_value,
                       nvl(bk.salvage_value, -1))
        and nvl(bk.percent_salvage_value, -1)         =
                   nvl(mch.to_percent_salvage_value/100,
                      nvl(bk.percent_salvage_value, -1))
        and nvl(bk.deprn_limit_type, 'XX')            =
                   nvl(mch.to_deprn_limit_type,
                      nvl(bk.deprn_limit_type, 'XX'))
        and nvl(bk.allowed_deprn_limit_amount, -1)            =
                   nvl(mch.to_deprn_limit_amount,
                      nvl(bk.allowed_deprn_limit_amount, -1))
        and nvl(bk.allowed_deprn_limit, -1)                   =
                   nvl(mch.to_deprn_limit/100,
                      nvl(bk.allowed_deprn_limit, -1))
     ORDER BY 2;

    h_request_id        NUMBER;
    h_msg_count         NUMBER;
    h_msg_data          VARCHAR2(2000) := NULL;
    h_preview_status_d  VARCHAR2(80);
    h_current_status_d  VARCHAR2(80);
    h_status            BOOLEAN := FALSE;

    h_cat_flex_struct   NUMBER;
    h_concat_cat        VARCHAR2(220);  -- category in concatenated string.
    h_cat_segs          FA_RX_SHARED_PKG.Seg_Array;
    h_debug_flag        VARCHAR2(3) := 'NO';

    -- exception raised from this module and child modules.
    mchg_failure        EXCEPTION;
    h_dummy             VARCHAR2(30);

    -- Commit results per every 200 assets.
    h_commit_level      NUMBER := 200;

    /* do not need these variables as per bug 8402286
       need to remove large rollback segment
    rbs_name            VARCHAR2(30);
    sql_stmt            VARCHAR2(101);
    */
    l_to_rsr            varchar2(15);

BEGIN

   -- Initialize message stacks.
   FA_SRVR_MSG.Init_Server_Message;
   FA_DEBUG_PKG.Initialize;
   FA_DEBUG_PKG.SET_DEBUG_FLAG;

   /* Bug 8402286 removing LARGE ROLLBACK SEGMENT
   -- Set large rollback segment.
   fnd_profile.get('FA_LARGE_ROLLBACK_SEGMENT', rbs_name);
   IF (rbs_name is not null) THEN
       sql_stmt := 'Set Transaction Use Rollback Segment '|| rbs_name;
       execute immediate sql_stmt;
   END IF;
   */


   -- Initialize global variables.
   -- (These are session specific variables, and thus values need to
   --  be re-initialized.)
   a_tbl.delete;
   a_index := 0;
   g_asset_count := 0;

   -- Get concurrent request id for the mass change preview request.
   -- h_request_id is used when request_id is inserted into the interface
   -- table, fa_mass_change_itf.
   -- Need to fetch request id from fnd_global package instead of fa_mass_change
   -- table, since fa_mass_change table stores the latest request id for
   -- the SRS Preview report requests(run after this module) or
   -- Run requests only.
   h_request_id := fnd_global.conc_request_id;

    -- Fetch mass change record information.
   OPEN mass_change;
   FETCH mass_change INTO
            mc_rec.mass_change_id,
            mc_rec.book_type_code,
            mc_rec.transaction_date_entered,
            mc_rec.concurrent_request_id,
            mc_rec.status,
            mc_rec.asset_type,
            mc_rec.category_id,
            mc_rec.from_asset_number,
            mc_rec.to_asset_number,
            mc_rec.from_date_placed_in_service,
            mc_rec.to_date_placed_in_service,
            mc_rec.from_convention,
            mc_rec.to_convention,
            mc_rec.from_method_code,
            mc_rec.to_method_code,
            mc_rec.from_life_in_months,
            mc_rec.to_life_in_months,
            mc_rec.from_bonus_rule,
            mc_rec.to_bonus_rule,
            mc_rec.date_effective,
            mc_rec.from_basic_rate,
            mc_rec.to_basic_rate,
            mc_rec.from_adjusted_rate,
            mc_rec.to_adjusted_rate,
            mc_rec.from_production_capacity,
            mc_rec.to_production_capacity,
            mc_rec.from_uom,
            mc_rec.to_uom,
            mc_rec.from_group_association,
            mc_rec.to_group_association,
            mc_rec.from_group_asset_id,
            mc_rec.to_group_asset_id,
            mc_rec.from_group_asset_number,
            mc_rec.to_group_asset_number,
            mc_rec.change_fully_rsvd_assets,
            mc_rec.amortize_flag,
            mc_rec.created_by,
            mc_rec.creation_date,
            mc_rec.last_updated_by,
            mc_rec.last_update_login,
            mc_rec.last_update_date,
            mc_rec.from_salvage_type,
            mc_rec.to_salvage_type,
            mc_rec.from_percent_salvage_value,
            mc_rec.to_percent_salvage_value,
            mc_rec.from_salvage_value,
            mc_rec.to_salvage_value,
            mc_rec.from_deprn_limit_type,
            mc_rec.to_deprn_limit_type,
            mc_rec.from_deprn_limit,
            mc_rec.to_deprn_limit,
            mc_rec.from_deprn_limit_amount,
            mc_rec.to_deprn_limit_amount;
   CLOSE mass_change;


   if not (fa_cache_pkg.fazcbc(X_book => mc_rec.book_type_code)) then
      raise mchg_failure;
   end if;

   g_print_debug := fa_cache_pkg.fa_print_debug;

   -- Set debug flag.
   IF (g_print_debug) THEN
      h_debug_flag := 'YES';
   END IF;

   if (g_print_debug) then
      fa_debug_pkg.add('FARX_MCP.Preview_Change',
                       'Starting Preview',
                       '');
   end if;

   -- Concurrent request id fetched from fa_mass_changes table is in no use
   -- in the preview module.
   -- Assign h_request_id to the global mass change record field so that
   -- it can be used in other procedures.

   mc_rec.concurrent_request_id := h_request_id;

   /*=========================================================================
     Delete rows previously inserted into the interface table with the same
     request id, if there is any.
    =========================================================================*/

   if (g_print_debug) then
      fa_debug_pkg.add('FARX_MCP.Preview_Change',
                       'before deleting rows from itf table',
                       '');
   end if;

   DELETE FROM fa_mass_changes_itf
   WHERE request_id = h_request_id;
   COMMIT;


   /*=========================================================================
     Check to make sure current status is 'PREVIEW'
    =========================================================================*/

/*   OPEN get_status;
   FETCH get_status
    INTO h_preview_status_d, h_current_status_d;
   CLOSE get_status;

   IF (h_preview_status_d <> h_current_status_d) THEN
        -- Re-using message for mass change program.
        FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FARX_MCP.Preview_Change',
                NAME => 'FA_MASSRCL_WRONG_STATUS',
                TOKEN1 => 'CURRENT',
                VALUE1 => h_current_status_d,
                TOKEN2 => 'RUNNING',
                VALUE2 => h_preview_status_d);
      -- Preview will complete with error status.
      RAISE mchg_failure;
   END IF;
*/


    /*=========================================================================
      Validate assets and insert preview records into the interface table.
     =========================================================================*/
   -- Get category flex structure.
   OPEN get_cat_flex_struct;
   FETCH get_cat_flex_struct
    INTO h_cat_flex_struct;
   CLOSE get_cat_flex_struct;

   -- get the rate source rule for the to method
   if (mc_rec.to_method_code is not null) then
       if not fa_cache_pkg.fazccmt
          (X_method                => mc_rec.to_method_code,
           X_life                  => mc_rec.to_life_in_months
          ) then
         raise mchg_failure;
      end if;

      l_to_rsr := fa_cache_pkg.fazccmt_record.rate_source_rule;

   end if;


   -- Loop all the qualified assets, and insert all the validated assets
   -- into the interface table, fa_mass_change_itf.
   OPEN mass_change_assets;

   LOOP

      a_index := a_index + 1;

      FETCH mass_change_assets
       INTO a_tbl(a_index).asset_id,
            a_tbl(a_index).asset_number,
            a_tbl(a_index).description,
            a_tbl(a_index).asset_type,
            a_tbl(a_index).category_id,
            a_tbl(a_index).from_convention,
            a_tbl(a_index).from_method,
            a_tbl(a_index).from_life_in_months,
            a_tbl(a_index).from_bonus_rule,
            a_tbl(a_index).from_basic_rate,
            a_tbl(a_index).from_adjusted_rate,
            a_tbl(a_index).from_capacity,
            a_tbl(a_index).from_unit_of_measure,
            a_tbl(a_index).book_type_code,
            a_tbl(a_index).from_group_asset_number,
            a_tbl(a_index).from_salvage_type,
            a_tbl(a_index).from_percent_salvage_value,
            a_tbl(a_index).from_salvage_value,
            a_tbl(a_index).from_deprn_limit_type,
            a_tbl(a_index).from_deprn_limit,
            a_tbl(a_index).from_deprn_limit_amount;
      EXIT WHEN mass_change_assets%NOTFOUND;

      if (g_print_debug) then
         fa_debug_pkg.add('after fecth',
                          'asset_id',
                          a_tbl(a_index).asset_id);
      end if;

      if (g_print_debug) then
         fa_debug_pkg.add('calling',
                          'store results',
                          a_index);
      end if;

      Store_Results(X_mc_rec              => mc_rec,
                    X_To_RSR              => l_to_rsr,
                    X_Cat_Flex_Struct     => h_cat_flex_struct);


      -- Insert asset records into the interface table, FA_MASS_RECLASS_ITF,
      -- at every 200 assets.
      -- If g_asset_count(number of valid assets) = 200, insert all the 200
      -- asset records in a_tbl(1..a_index) into the interface table,
      -- re-initialize the pl/sql table, a_tbl, and reset g_asset_count
      -- and a_index to 0.  Commit changes at every 200 assets as well.
      IF (g_asset_count = h_commit_level) THEN
         FOR i IN 1 .. a_index LOOP
            if (g_print_debug) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
                                'Preview - inserting asset into itf-table at 200 loop',
                                a_tbl(a_index).asset_id );
            end if;

            FA_MASS_CHG_UTILS_PKG.Insert_Itf(
                 X_Report_Type           => 'PREVIEW',
                 X_Request_Id            => h_request_id,
                 X_Mass_Change_Id        => X_Mass_Change_Id,
                 X_Asset_Rec             => a_tbl(i),
                 X_Last_Update_Date      => mc_rec.last_update_date,
                 X_Last_Updated_By       => mc_rec.last_updated_by,
                 X_Created_By            => mc_rec.created_by,
                 X_Creation_Date         => mc_rec.creation_date,
                 X_Last_Update_Login     => mc_rec.last_update_login,
                 p_log_level_rec         => null
                 );
         END LOOP;

         a_tbl.delete;
         g_asset_count := 0;
         a_index := 0;
         COMMIT WORK;
      END IF;

   END LOOP;

   if (g_print_debug) then
      fa_debug_pkg.add('FARX_MCP.Preview_Change',
                       'after loop',
                       '');
   end if;

   CLOSE mass_change_assets;

   -- Insert the remaining valid asset records into the interface table.
   -- Up to a_index - 1, to account for the extra increment taken for a_index
   -- when no more rows were found in the cursor loop.

   if (g_print_debug) then
      fa_debug_pkg.add('FARX_MCP.Preview_Change',
                       'after closing cursor',
                       '');
   end if;


   FOR i IN 1 .. (a_index - 1) LOOP

      if (g_print_debug) then
         fa_debug_pkg.add('FARX_MCP.Preview_Change',
                          'asset inserted',
                          a_tbl(i).asset_id);
         fa_debug_pkg.add('FARX_MCP.Preview_Change',
                          'book inserted',
                          a_tbl(i).book_type_code);
      end if;



      FA_MASS_CHG_UTILS_PKG.Insert_Itf(
           X_Report_Type           => 'PREVIEW',
           X_Request_Id            => h_request_id,
           X_Mass_Change_Id        => X_Mass_Change_Id,
           X_Asset_Rec             => a_tbl(i),
           X_Last_Update_Date      => mc_rec.last_update_date,
           X_Last_Updated_By       => mc_rec.last_updated_by,
           X_Created_By            => mc_rec.created_by,
           X_Creation_Date         => mc_rec.creation_date,
           X_Last_Update_Login     => mc_rec.last_update_login,
           p_log_level_rec         => null
           );
    END LOOP;

    a_tbl.delete;
    g_asset_count := 0;
    a_index := 0;
    COMMIT WORK;

    /*=========================================================================
      Fetch the preview records from the interface table and print them on
      the SRS output screen for the preview report.
     =========================================================================*/

    -- Commenting out, since this will be taken care of by SRS report(FASRCPVW.rdf.)


    /*=========================================================================
      Update the status of the mass change to 'PREVIEWED'
      (This step is now handled in SRS report(FASRCPVW.rdf), which is fired
       after the RX report request.)
     =========================================================================*/

    /*
    UPDATE      fa_mass_changes
    SET         status = 'PREVIEWED'
    WHERE       mass_change_id = X_Mass_Reclass_Id
    AND         status = 'PREVIEW';
    COMMIT WORK;
    */

    /* Bug 8402286 : BP:4672237
    if (g_print_debug) then
       fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
    end if;
    */
            FND_MSG_PUB.Count_And_Get(
                 p_count         => h_msg_count,
                 p_data          => h_msg_data);
            FA_SRVR_MSG.Write_Msg_Log(
                msg_count       => h_msg_count,
                msg_data        => h_msg_data);
            IF (h_debug_flag = 'YES') THEN
                FA_DEBUG_PKG.Write_Debug_Log;
            END IF;

    errbuf := ''; -- No error.
    retcode := 0; -- Completed normally.

EXCEPTION
    WHEN mchg_failure THEN
         retcode := 2;  -- Completed with error.

         a_tbl.delete;
         a_index := 0;
         g_asset_count := 0;
         --g_total_assets := 0;

         /* A fatal error has occurred.  Update status to 'FAILED_PRE'. */
         ROLLBACK WORK;
         UPDATE fa_mass_changes
            SET status = 'FAILED_PRE'
          WHERE mass_change_id = X_Mass_Change_Id;

         /* Delete rows inserted into the interface table. */
         DELETE FROM fa_mass_changes_itf
          WHERE request_id = h_request_id;

         /* Commit changes. */
         COMMIT WORK;
         /* Bug 8402286 : BP:4672237
         if (g_print_debug) then
            fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
         end if;
         */
         /* Retrieve message log and write result to log and output. */
         IF (X_RX_Flag = 'YES') THEN
            FND_MSG_PUB.Count_And_Get(
                 p_count         => h_msg_count,
                 p_data          => h_msg_data);
            FA_SRVR_MSG.Write_Msg_Log(
                msg_count       => h_msg_count,
                msg_data        => h_msg_data);
            IF (h_debug_flag = 'YES') THEN
                FA_DEBUG_PKG.Write_Debug_Log;
            END IF;
         END IF;
    WHEN OTHERS THEN
         retcode := 2;  -- Completed with error.
         IF SQLCODE <> 0 THEN
            FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN => 'FARX_RP.Preview_Reclass');
         END IF;

         -- Reset global variable values.
         a_tbl.delete;
         a_index := 0;
         g_asset_count := 0;
         --g_total_assets := 0;

         /* A fatal error has occurred.  Update status to 'FAILED_PRE'. */
         ROLLBACK WORK;
         UPDATE fa_mass_changes
            SET status = 'FAILED_PRE'
          WHERE mass_change_id = X_Mass_Change_Id;

         /* Delete rows inserted into the interface table. */
         DELETE FROM fa_mass_changes_itf
          WHERE request_id = h_request_id;

         /* Commit changes. */
         COMMIT WORK;
         /* Bug 8402286 : BP:4672237
         if (g_print_debug) then
            fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
         end if;
         */
         /* Retrieve message log and write result to log and output. */
        IF (X_RX_Flag = 'YES') THEN
            FND_MSG_PUB.Count_And_Get(
                p_count         => h_msg_count,
                p_data          => h_msg_data);
            FA_SRVR_MSG.Write_Msg_Log(
                msg_count       => h_msg_count,
                msg_data        => h_msg_data);
            IF (h_debug_flag = 'YES') THEN
                FA_DEBUG_PKG.Write_Debug_Log;
            END IF;
        END IF;

END Preview_Change;


/*============================================================================+
|   PROCEDURE Store_Results                                                   |
+=============================================================================*/

PROCEDURE Store_Results(
     X_mc_rec              IN  FA_MASS_CHG_UTILS_PKG.mass_change_rec_type,
     X_To_RSR              IN  VARCHAR2,
     X_Cat_Flex_Struct     IN  NUMBER   := NULL
     ) IS

    h_book_type_code      VARCHAR2(30) := NULL;
    h_cat_flex_struct     NUMBER := X_Cat_Flex_Struct;
    h_concat_cat          VARCHAR2(220);
    h_cat_segs            FA_RX_SHARED_PKG.Seg_Array;
    h_from_RSR            VARCHAR2(30);

    store_failure         EXCEPTION;

    -- cursor to get the category flex structure.
    CURSOR get_cat_flex_struct IS
        SELECT  category_flex_structure
          FROM    fa_system_controls;

    -- cursor to get the old(current) depreciation rules.
    CURSOR get_old_info IS
     SELECT prorate_convention_code,
            deprn_method_code,
            life_in_months,
            basic_rate,
            adjusted_rate,
            bonus_rule,
            production_capacity,
            unit_of_measure,
            ad.asset_number
       FROM FA_BOOKS bk,
            FA_ADDITIONS_B ad
      WHERE bk.asset_id       = a_tbl(a_index).asset_id
        AND bk.book_type_code = h_book_type_code
        AND bk.date_ineffective IS NULL
        AND bk.group_asset_id = ad.asset_id(+);

BEGIN
   -- Get the category flexfield structure, if value not provided.
   IF X_Cat_Flex_Struct IS NULL THEN
      OPEN get_cat_flex_struct;
      FETCH get_cat_flex_struct INTO h_cat_flex_struct;
      CLOSE get_cat_flex_struct;
   END IF;

   -- Get the category in concatenated string for the asset's current
   -- category.
   FA_RX_SHARED_PKG.Concat_Category(
        struct_id       => h_cat_flex_struct,
        ccid            => a_tbl(a_index).category_id,
        concat_string   => h_concat_cat,
        segarray        => h_cat_segs);


   -- For each book, store a preview record for an asset with
   -- new depreciation rules, if redefault is allowed and if user
   -- chooses to redefault the depreciation rules.  Otherwise,
   -- there is no change in depreciation rules for the book. */

   -- asset_id, asset_number, category_id fields are already assigned.

   -- a_tbl(a_index).book_type_code := h_book_type_code;  -- done above
   h_book_type_code := a_tbl(a_index).book_type_code;
   a_tbl(a_index).category := h_concat_cat;


   -- load the current rules first
   OPEN get_old_info;
   FETCH get_old_info
    INTO a_tbl(a_index).from_convention,
         a_tbl(a_index).from_method,
         a_tbl(a_index).from_life_in_months,
         a_tbl(a_index).from_basic_rate,
         a_tbl(a_index).from_adjusted_rate,
         a_tbl(a_index).from_bonus_rule,
         a_tbl(a_index).from_capacity,
         a_tbl(a_index).from_unit_of_measure,
         a_tbl(a_index).from_group_asset_number;
   CLOSE get_old_info;


   -- Set new depreciation rules.
   a_tbl(a_index).to_convention            := nvl(X_mc_rec.to_convention,   a_tbl(a_index).from_convention);
   a_tbl(a_index).to_method                := nvl(X_mc_rec.to_method_code, a_tbl(a_index).from_method);
   a_tbl(a_index).to_bonus_rule            := nvl(X_mc_rec.to_bonus_rule,   a_tbl(a_index).from_bonus_rule);

   if (g_print_debug) then
      fa_debug_pkg.add('store',
                       'entering group logic, to group assoc',
                       X_mc_rec.to_group_association);
      fa_debug_pkg.add('store',
                       'entering group logic, from group num',
                       X_mc_rec.from_group_asset_number);

      fa_debug_pkg.add('store',
                       'entering group logic, to group number',
                       X_mc_rec.to_group_asset_number);

   end if;

   if (X_mc_rec.to_group_association is null) then
      a_tbl(a_index).to_group_asset_number    := a_tbl(a_index).from_group_asset_number;
   elsif (X_mc_rec.to_group_association = 'MEMBER') then
      a_tbl(a_index).to_group_asset_number    := X_mc_rec.to_group_asset_number;
   else
      a_tbl(a_index).to_group_asset_number    := null;
   end if;

   if (nvl(X_mc_rec.from_method_code, 'X') <> nvl(X_mc_rec.to_method_code, 'X')) then

      if (X_mc_rec.from_method_code is not null) then
          if not fa_cache_pkg.fazccmt
             (X_method                => mc_rec.from_method_code,
              X_life                  => mc_rec.from_life_in_months
             ) then
            raise store_failure;
         end if;
      end if;


      if (nvl(h_from_rsr, 'X') <> nvl(X_to_rsr, 'X')) then
         if (X_to_rsr = 'FLAT') then
            a_tbl(a_index).to_life_in_months  := null;
            a_tbl(a_index).to_capacity        := null;
            a_tbl(a_index).to_unit_of_measure := null;
            a_tbl(a_index).to_basic_rate      := nvl(X_mc_rec.to_basic_rate, a_tbl(a_index).from_basic_rate);
            a_tbl(a_index).to_adjusted_rate   := nvl(X_mc_rec.to_adjusted_rate, a_tbl(a_index).from_adjusted_rate);
         elsif (X_to_rsr = 'PRODUCTION') then
            a_tbl(a_index).to_life_in_months  := null;
            a_tbl(a_index).to_basic_rate      := null;
            a_tbl(a_index).to_adjusted_rate   := null;
            a_tbl(a_index).to_capacity        := nvl(X_mc_rec.to_production_capacity, a_tbl(a_index).from_capacity);
            a_tbl(a_index).to_unit_of_measure := nvl(X_mc_rec.to_uom, a_tbl(a_index).from_unit_of_measure);
         else
            a_tbl(a_index).to_life_in_months  := nvl(X_mc_rec.to_life_in_months, a_tbl(a_index).from_life_in_months);
            a_tbl(a_index).to_basic_rate      := null;
            a_tbl(a_index).to_adjusted_rate   := null;
            a_tbl(a_index).to_capacity        := null;
            a_tbl(a_index).to_unit_of_measure := null;
         end if;

      else
         a_tbl(a_index).to_life_in_months     := nvl(X_mc_rec.to_life_in_months, a_tbl(a_index).from_life_in_months);
         a_tbl(a_index).to_basic_rate         := nvl(X_mc_rec.to_basic_rate, a_tbl(a_index).from_basic_rate);
         a_tbl(a_index).to_adjusted_rate      := nvl(X_mc_rec.to_adjusted_rate, a_tbl(a_index).from_adjusted_rate);
         a_tbl(a_index).to_capacity           := nvl(X_mc_rec.to_production_capacity, a_tbl(a_index).from_capacity);
         a_tbl(a_index).to_unit_of_measure    := nvl(X_mc_rec.to_uom, a_tbl(a_index).from_unit_of_measure);
      end if;

   else
      a_tbl(a_index).to_life_in_months     := nvl(X_mc_rec.to_life_in_months, a_tbl(a_index).from_life_in_months);
      a_tbl(a_index).to_basic_rate         := nvl(X_mc_rec.to_basic_rate, a_tbl(a_index).from_basic_rate);
      a_tbl(a_index).to_adjusted_rate      := nvl(X_mc_rec.to_adjusted_rate, a_tbl(a_index).from_adjusted_rate);
      a_tbl(a_index).to_capacity           := nvl(X_mc_rec.to_production_capacity, a_tbl(a_index).from_capacity);
      a_tbl(a_index).to_unit_of_measure    := nvl(X_mc_rec.to_uom, a_tbl(a_index).from_unit_of_measure);
   end if;

   -- Convert formats for certain fields.

   -- life...
   -- Need to get the substring from the second position, since
   -- to_char conversion with the format, always attaches extra space
   -- at the beginning of the string.

   IF a_tbl(a_index).From_Life_In_Months IS NOT NULL THEN
      a_tbl(a_index).From_Life := lpad(to_char(trunc(a_tbl(a_index).From_Life_In_Months/12)), 3)||'.'||
         substr(to_char(mod(a_tbl(a_index).From_Life_In_Months, 12), '00'), 2, 2);
   ELSE
      a_tbl(a_index).From_Life := NULL;
   END IF;

   IF a_tbl(a_index).To_Life_In_Months IS NOT NULL THEN
      a_tbl(a_index).To_Life := lpad(to_char(trunc(a_tbl(a_index).To_Life_In_Months/12)), 3)||'.'||
        substr(to_char(mod(a_tbl(a_index).To_Life_In_Months, 12), '00'), 2, 2);
   ELSE
      a_tbl(a_index).To_Life := NULL;
   END IF;

   -- rates...
   -- May use the following format in report output:
   -- substr(to_char(round(a_tbl(a_index).From_Basic_Rate*100, 2), '999.99'), 2, 6) or
   -- lpad(to_char(round(a_tbl(a_index).From_Basic_Rate*100, 2)), 6)

   IF a_tbl(a_index).From_Basic_Rate IS NOT NULL THEN
      a_tbl(a_index).From_Basic_Rate_Pct := round(a_tbl(a_index).From_Basic_Rate*100, 2);
   ELSE
      a_tbl(a_index).From_Basic_Rate_Pct := NULL;
   END IF;

   IF a_tbl(a_index).To_Basic_Rate IS NOT NULL THEN
      a_tbl(a_index).To_Basic_Rate_Pct := round(a_tbl(a_index).To_Basic_Rate*100, 2);
   ELSE
      a_tbl(a_index).To_Basic_Rate_Pct := NULL;
   END IF;

   IF a_tbl(a_index).From_Adjusted_Rate IS NOT NULL THEN
      a_tbl(a_index).From_Adjusted_Rate_Pct := round(a_tbl(a_index).From_Adjusted_Rate*100, 2);
   ELSE
      a_tbl(a_index).From_Adjusted_Rate_Pct := NULL;
   END IF;

   IF a_tbl(a_index).To_Adjusted_Rate IS NOT NULL THEN
      a_tbl(a_index).To_Adjusted_Rate_Pct := round(a_tbl(a_index).To_Adjusted_Rate*100, 2);
   ELSE
      a_tbl(a_index).To_Adjusted_Rate_Pct := NULL;
   END IF;

   -- The following values are used in review reports only.
   -- a_tbl(a_index).cost_acct_ccid      := NULL;
   -- a_tbl(a_index).cost_acct           := NULL;
   -- a_tbl(a_index).deprn_rsv_acct_ccid := NULL;
   -- a_tbl(a_index).deprn_rsv_acct      := NULL;

   -- Propagate asset_id, asset_number, category_id to the next
   -- book record for the asset.
   a_tbl(a_index + 1).asset_id     := a_tbl(a_index).asset_id;
   a_tbl(a_index + 1).asset_number := a_tbl(a_index).asset_number;
   a_tbl(a_index + 1).description  := a_tbl(a_index).description;
   a_tbl(a_index + 1).category_id  := a_tbl(a_index).category_id;

EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FARX_MCP.Store_Results');
        raise;

END Store_Results;



END FARX_MCP;

/
