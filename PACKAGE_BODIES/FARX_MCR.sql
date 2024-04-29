--------------------------------------------------------
--  DDL for Package Body FARX_MCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_MCR" AS
/* $Header: FARXMCRB.pls 120.3.12010000.2 2009/07/19 11:58:16 glchen ship $ */


-- Mass change record from fa_mass_changes table.
mc_rec     FA_MASS_CHG_UTILS_PKG.mass_change_rec_type;

-- Table of asset records.
-- (Stores book_type_code as well, and thus one asset will appear multiple
--  times if the asset belongs to multiple books.)
a_tbl       FA_MASS_CHG_UTILS_PKG.asset_tbl_type;

-- Index into the asset table, a_tbl.
a_index          NUMBER := 0;

-- Number of assets(disregaring book_type_code) stored in a_tbl.
-- Reset at every 200 assets.
g_asset_count      NUMBER := 0;

/* a_index <> g_asset_count if asset belongs to more than one book. */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;


/*============================================================================+
|   PROCEDURE Review_Change                                                   |
+=============================================================================*/

PROCEDURE Review_Change(
     X_Mass_Change_Id     IN     NUMBER,
     X_RX_Flag            IN     VARCHAR2 := 'NO',
     retcode              OUT NOCOPY NUMBER,
     errbuf               OUT NOCOPY VARCHAR2) IS

    -- cursor to fetch the current and review status
    CURSOR get_status IS
        SELECT  lu_rev.meaning,
                lu_curr.meaning
        FROM    fa_lookups lu_rev,
                fa_lookups lu_curr
        WHERE   lu_rev.lookup_type = 'MASS_TRX_STATUS'  AND
                lu_rev.lookup_code = 'COMPLETED'
        AND     lu_curr.lookup_type = 'MASS_TRX_STATUS' AND
                lu_curr.lookup_code = mc_rec.status;

    -- cursor to get category flexfield structure.
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

    -- asset-book records that were changed by mass change

    CURSOR mass_change_assets IS
     SELECT ad.asset_id,
            ad.asset_number,
            ad.description,
            ad.asset_type,
            bk1.book_type_code,
            ad.asset_category_id,
            NULL,
            bk1.prorate_convention_code,
            bk2.prorate_convention_code,
            bk1.deprn_method_code,
            bk2.deprn_method_code,
            bk1.life_in_months,
            bk2.life_in_months,
            NULL,
            NULL,
            bk1.basic_rate,
            bk2.basic_rate,
            NULL,
            NULL,
            bk1.adjusted_rate,
            bk2.adjusted_rate,
            NULL,
            NULL,
            bk1.bonus_rule,
            bk2.bonus_rule,
            bk1.production_capacity,
            bk2.production_capacity,
            bk1.unit_of_measure,
            bk2.unit_of_measure,
            gad1.asset_number,
            gad2.asset_number,
            bk1.salvage_type,
            bk2.salvage_type,
            bk1.percent_salvage_value,
            bk2.percent_salvage_value,
            bk1.salvage_value,
            bk2.salvage_value,
            bk1.deprn_limit_type,
            bk2.deprn_limit_type,
            bk1.allowed_deprn_limit,
            bk2.allowed_deprn_limit,
            bk1.allowed_deprn_limit_amount,
            bk2.allowed_deprn_limit_amount
        FROM    fa_books                bk1,
                fa_books                bk2,
                fa_additions            ad,
                fa_additions_b          gad1,
                fa_additions_b          gad2,
                fa_transaction_headers  th
        WHERE   th.mass_transaction_id = mc_rec.mass_change_id
        AND     th.member_transaction_header_id is null  -- exclude the spawned adjustments on groups
        AND     ad.asset_id = th.asset_id
        AND     bk1.asset_id = th.asset_id
        AND     bk2.asset_id = th.asset_id
        AND     bk1.book_type_code = th.book_type_code
        AND     bk2.book_type_code = th.book_type_code
        AND     bk1.transaction_header_id_out = th.transaction_header_id
        AND     bk2.transaction_header_id_in  = th.transaction_header_id
        AND     bk1.group_asset_id = gad1.asset_id(+)
        AND     bk2.group_asset_id = gad2.asset_id(+)
        ORDER BY ad.asset_number;

    -- to store th.transaction_header_id in the cursor above.
    h_mch_thid           NUMBER(15);

    h_request_id         NUMBER;
    h_msg_count          NUMBER;
    h_msg_data           VARCHAR2(2000) := NULL;
    -- Bug#6870987 Resetting Variable size.
    h_review_status_d    VARCHAR2(50);
    h_current_status_d   VARCHAR2(50);
    h_cat_flex_struct    NUMBER;
    h_cat_segs           FA_RX_SHARED_PKG.Seg_Array;
    h_category_id        NUMBER(15) := NULL;
    h_concat_cat         VARCHAR2(1000);
    h_debug_flag         VARCHAR2(20) := 'NO';

    -- to keep track of the last asset id that entered the mass_change_assets
    -- cursor loop.
    h_last_asset         NUMBER(15) := NULL;

    -- indicates whether the book information was found.  used only when
    -- redefault option was set to YES.
    h_bk_info_found      BOOLEAN;

    -- exception raised from this module and child modules.
    mchg_failure         EXCEPTION;

    -- Commit results per every 200 assets.
    h_commit_level       NUMBER := 200;
    -- Bug#6870987 Resetting Variable size.
    /* do not need these variables as per bug 8402286
       need to remove large rollback segment
    rbs_name             VARCHAR2(60);
    sql_stmt             VARCHAR2(500);
    */

BEGIN

    -- Initialize message stacks.
    FA_SRVR_MSG.Init_Server_Message;
    FA_DEBUG_PKG.Initialize;

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

    -- Get concurrent request id for the mass change review request.
    -- h_request_id is used when request_id is inserted into the interface
    -- table, fa_mass_changes_itf.
    -- Need to fetch request id from fnd_global package instead of fa_mass_changes
    -- table, since fa_mass_changes table stores the latest request id for
    -- the Preview or Run requests only.
    h_request_id := fnd_global.conc_request_id;

    -- Fetch mass changes record information.
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

    if not(fa_cache_pkg.fazcbc(X_book => mc_rec.book_type_code)) then
       raise mchg_failure;
    end if;

    g_print_debug := fa_cache_pkg.fa_print_debug;

    -- Set debug flag.
    IF (g_print_debug) THEN
       h_debug_flag := 'YES';
    END IF;

    /*===========================================================================
      Delete rows previously inserted into the interface table with the same
      request id, if there is any.
     ===========================================================================*/
    DELETE FROM fa_mass_changes_itf
    WHERE request_id = h_request_id;
    COMMIT;

    /*===========================================================================
      Check to make sure current status is 'COMPLETED'
     ===========================================================================*/
    OPEN get_status;
    FETCH get_status INTO h_review_status_d, h_current_status_d;
    CLOSE get_status;

    if g_print_debug then
      fa_debug_pkg.add('FARX_CR.Review_Change',
                       'After fetching status',
                       '');
    end if;

    IF (h_review_status_d <> h_current_status_d) THEN
        -- Re-using message for mass changes program.
        FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FARX_RR.Review_Change',
                NAME => 'FA_MASSRCL_WRONG_STATUS',
                TOKEN1 => 'CURRENT',
                VALUE1 => h_current_status_d,
                TOKEN2 => 'RUNNING',
                VALUE2 => h_review_status_d);
        -- Review will complete with error status.
        RAISE mchg_failure;
    END IF;

    /*===========================================================================
      Insert review records into the interface table.
     ===========================================================================*/

    if g_print_debug then
      fa_debug_pkg.add('FARX_CR.Review_Change',
                       'getting cat structure',
                       '');
    end if;


    /* Get category flex structure. */
    OPEN get_cat_flex_struct;
    FETCH get_cat_flex_struct INTO h_cat_flex_struct;
    CLOSE get_cat_flex_struct;

    OPEN mass_change_assets;

    LOOP

       if g_print_debug then
         fa_debug_pkg.add('FARX_CR.Review_Change',
                          'in loop',
                          '');
       end if;

       -- Fetch the asset-book pair into the pl/sql table.
       a_index := a_index + 1;

       FETCH mass_change_assets INTO
          a_tbl(a_index).asset_id,
          a_tbl(a_index).asset_number,
          a_tbl(a_index).description,
          a_tbl(a_index).asset_type,
          a_tbl(a_index).book_type_code,
          a_tbl(a_index).category_id,
          a_tbl(a_index).category,
          a_tbl(a_index).from_convention,
          a_tbl(a_index).to_convention,
          a_tbl(a_index).from_method,
          a_tbl(a_index).to_method,
          a_tbl(a_index).from_life_in_months,
          a_tbl(a_index).to_life_in_months,
          a_tbl(a_index).from_life,
          a_tbl(a_index).to_life,
          a_tbl(a_index).from_basic_rate,
          a_tbl(a_index).to_basic_rate,
          a_tbl(a_index).from_basic_rate_pct,
          a_tbl(a_index).to_basic_rate_pct,
          a_tbl(a_index).from_adjusted_rate,
          a_tbl(a_index).to_adjusted_rate,
          a_tbl(a_index).from_adjusted_rate_pct,
          a_tbl(a_index).to_adjusted_rate_pct,
          a_tbl(a_index).from_bonus_rule,
          a_tbl(a_index).to_bonus_rule,
          a_tbl(a_index).from_capacity,
          a_tbl(a_index).to_capacity,
          a_tbl(a_index).from_unit_of_measure,
          a_tbl(a_index).to_unit_of_measure,
          a_tbl(a_index).from_group_asset_number,
          a_tbl(a_index).to_group_asset_number,
          a_tbl(a_index).from_salvage_type,
          a_tbl(a_index).to_salvage_type,
          a_tbl(a_index).from_percent_salvage_value,
          a_tbl(a_index).to_percent_salvage_value,
          a_tbl(a_index).from_salvage_value,
          a_tbl(a_index).to_salvage_value,
          a_tbl(a_index).from_deprn_limit_type,
          a_tbl(a_index).to_deprn_limit_type,
          a_tbl(a_index).from_deprn_limit,
          a_tbl(a_index).to_deprn_limit,
          a_tbl(a_index).from_deprn_limit_amount,
          a_tbl(a_index).to_deprn_limit_amount;
       EXIT WHEN mass_change_assets%NOTFOUND;

       -- Get category in concatenated string format.
       FA_RX_SHARED_PKG.Concat_Category(
                  struct_id       => h_cat_flex_struct,
                  ccid            => a_tbl(a_index).category_id,
                  concat_string   => a_tbl(a_index).category,
                  segarray        => h_cat_segs);
       h_concat_cat := a_tbl(a_index).category;

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




       -- Update last asset processed and the asset count.
       IF (a_tbl(a_index).asset_id <> h_last_asset OR
          h_last_asset IS NULL) THEN
          h_last_asset := a_tbl(a_index).asset_id;
          g_asset_count := g_asset_count + 1;
       END IF;

       /* Insert asset records into the interface table, FA_MASS_CHANGES_ITF,
          at every 200 assets and re-initialize the counter and the asset table. */
       -- If the 200th asset belongs to more than one book, only the information
       -- for the first book of this asset will be inserted into the table.
       -- The rest will be taken care of in the next insertion.

       IF (g_asset_count = h_commit_level) THEN
          FOR i IN 1 .. a_index LOOP
             FA_MASS_CHG_UTILS_PKG.Insert_Itf(
                     X_Report_Type           => 'REVIEW',
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
          -- Also re-initialize h_last_asset so that g_asset_count
          -- is incremented to 1 at the next loop entry as in the former
          -- insertion.
          h_last_asset := NULL;
          COMMIT WORK;

       END IF;

    END LOOP;

    CLOSE mass_change_assets;

    /* Insert the remaining asset records into the interface table. */
    -- Up to a_index - 1, to account for the extra increment taken for a_index
    -- when no more rows were found in the cursor loop.
    FOR i IN 1 .. (a_index - 1) LOOP
       FA_MASS_CHG_UTILS_PKG.Insert_Itf(
             X_Report_Type           => 'REVIEW',
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

    fa_rx_conc_mesg_pkg.log('');
    fnd_message.set_name('OFA', 'FA_MASSRCL_CHG_RVW');
    h_msg_data := fnd_message.get;
    fa_rx_conc_mesg_pkg.log(h_msg_data);
    fa_rx_conc_mesg_pkg.log('');
    COMMIT WORK;


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

       -- Reset global variable values.
       a_tbl.delete;
       a_index := 0;
       g_asset_count := 0;
       /* A fatal error has occurred.  Rollback transaction. */
       ROLLBACK WORK;
       /* Delete rows inserted into the interface table. */
       DELETE FROM fa_mass_changes_itf
        WHERE request_id = h_request_id;
       /* Commit changes. */
       COMMIT WORK;
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
          FA_SRVR_MSG.Add_SQL_Error(CALLING_FN => 'FARX_RP.Review_Change');
       END IF;

       -- Reset global variable values.
       a_tbl.delete;
       a_index := 0;
       g_asset_count := 0;
       --g_total_assets := 0;
       /* A fatal error has occurred.  Rollback transaction. */
       ROLLBACK WORK;
       /* Delete rows inserted into the interface table. */
       DELETE FROM fa_mass_changes_itf
        WHERE request_id = h_request_id;
       /* Commit changes. */
       COMMIT WORK;
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

END Review_Change;

END FARX_MCR;

/
