--------------------------------------------------------
--  DDL for Package Body FARX_RR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_RR" AS
/* $Header: FARXRRB.pls 120.5.12010000.2 2009/07/19 11:44:15 glchen ship $ */


-- Mass reclass record from fa_mass_reclass table.
mr_rec	FA_MASS_REC_UTILS_PKG.mass_reclass_rec;

-- Table of asset records.
-- (Stores book_type_code as well, and thus one asset will appear multiple
--  times if the asset belongs to multiple books.)
a_tbl  	FA_MASS_REC_UTILS_PKG.asset_table;
-- Index into the asset table, a_tbl.
a_index		NUMBER := 0;

-- Number of assets(disregaring book_type_code) stored in a_tbl.
-- Reset at every 200 assets.
g_asset_count 	NUMBER := 0;

/* a_index <> g_asset_count if asset belongs to more than one book. */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;
g_log_level_rec fa_api_types.log_level_rec_type;

/*====================================================================================+
|   PROCEDURE Review_Reclass                                                         |
+=====================================================================================*/

PROCEDURE Review_Reclass(
	X_Mass_Reclass_Id	IN	NUMBER,
	X_RX_Flag		IN	VARCHAR2 := 'NO',
	retcode		 OUT NOCOPY NUMBER,
	errbuf		 OUT NOCOPY VARCHAR2) IS

    -- cursor to fetch the current and review status
    CURSOR get_status IS
        SELECT  lu_rev.meaning,
                lu_curr.meaning
        FROM    fa_lookups lu_rev,
                fa_lookups lu_curr
        WHERE   lu_rev.lookup_type = 'MASS_TRX_STATUS'  AND
                lu_rev.lookup_code = 'COMPLETED'
        AND     lu_curr.lookup_type = 'MASS_TRX_STATUS' AND
                lu_curr.lookup_code = mr_rec.status;

    -- cursor to get category flexfield structure.
    CURSOR get_cat_flex_struct IS
	SELECT 	category_flex_structure
	FROM 	fa_system_controls;

    -- cursor to fetch mass reclass record from fa_mass_reclass
    CURSOR mass_reclass IS
	SELECT	mr.mass_reclass_id,
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
	FROM	fa_mass_reclass mr
	WHERE 	mass_reclass_id = X_Mass_Reclass_Id;

    -- asset-book pairs that were reclassified by mass reclass program.
    -- use cursor 1 if inherit_deprn_rules_flag = 'NO'
    CURSOR mass_reclass_assets1 IS
        SELECT  ad.asset_id,
                ad.asset_number,
		ad.description,
                bk.book_type_code,
                ah.category_id,
                NULL,                   -- category in concatenated format.
                bk.prorate_convention_code,
                bk.ceiling_name,
                bk.deprn_method_code,
                bk.life_in_months,
                NULL,                   -- in converted format.
                bk.basic_rate,
                NULL,                   -- in converted format.
                bk.adjusted_rate,
                NULL,                   -- in converted format.
                bk.bonus_rule,
                bk.production_capacity,
                bk.unit_of_measure,
                bk.depreciate_flag,
                bk.allowed_deprn_limit,
                NULL,
                bk.allowed_deprn_limit_amount,
                bk.percent_salvage_value,
                NULL,
                -- for cost account
                decode(ah.asset_type, 'CIP', cb.wip_cost_account_ccid,
                                             cb.asset_cost_account_ccid),
                NULL,
                -- for reserve account
                decode(ah.asset_type, 'CIP', NULL, cb.reserve_account_ccid),
                NULL
        FROM    fa_category_books       cb,
                fa_book_controls        bc,
                fa_books                bk,
                fa_asset_history        ah,
                fa_additions            ad,
                fa_transaction_headers  th
                /* mr_rec.conc_request_id will correspond to the request id
                   for the last time the transaction was "run" by the mass
                   reclass program.

                   BMR: this is no longer true - see BUG# 2371326
                        for rerunnability we will show all assets/trxs

                   WHERE   th.mass_reference_id = mr_rec.conc_request_id
                */
        WHERE   th.mass_transaction_id = mr_rec.mass_reclass_id
        AND     ad.asset_id = th.asset_id
        AND     ah.asset_id = th.asset_id
        -- transaction_type_code = 'RECLASS' if transaction is after the period
        -- the asset was added.
	-- use transaction_header_id comparison, since there could be more than
	-- one transaction in the period the asset is added.
	--AND	((th.transaction_type_code = 'RECLASS' AND
	--	  ah.transaction_header_id_in = th.transaction_header_id) OR
	--	 (th.transaction_type_code <> 'RECLASS' AND
	--	  ah.transaction_header_id_in < th.transaction_header_id AND
	--	  nvl(ah.transaction_header_id_out, th.transaction_header_id + 1) >
	--		th.transaction_header_id))
        AND     ah.transaction_header_id_in =
                        decode(th.transaction_type_code, 'RECLASS',
                               th.transaction_header_id, ah.transaction_header_id_in)
	AND	ah.transaction_header_id_in <= th.transaction_header_id
	AND	nvl(ah.transaction_header_id_out, th.transaction_header_id + 1) >
			th.transaction_header_id
        -- Only corporate book is stored in fa_transaction_headers in case
        -- of basic reclass only(without redefault.)
        AND     bk.asset_id = th.asset_id
        AND     bk.book_type_code = bc.book_type_code
        AND     bc.book_class IN ('CORPORATE', 'TAX')
        AND     bc.distribution_source_book = th.book_type_code
        -- Get the book row at the time of reclass run.  Need to figure out
        -- the book row by comparing transaction_header_id's, since only
        -- basic reclass transaction is recorded in fa_transaction_headers
        -- table, when redefault is not performed.
        AND     bk.transaction_header_id_in < th.transaction_header_id
        AND     nvl(bk.transaction_header_id_out, th.transaction_header_id + 1) >
                        th.transaction_header_id
        AND     cb.category_id = mr_rec.to_category_id
        AND     cb.book_type_code = bk.book_type_code
        ORDER BY ad.asset_number, bk.book_type_code;

    -- asset-book pairs that were reclassified by mass reclass program.
    -- use cursor 2 if inherit_deprn_rules_flag = 'YES'
    -- the rest of the book information for the asset comes from
    -- cursor book_info1 or 2.
    CURSOR mass_reclass_assets2 IS
	SELECT 	ad.asset_id,
		ad.asset_number,
		ad.description,
		bk.book_type_code,
		ah.category_id,
                -- for cost account
                decode(ah.asset_type, 'CIP', cb.wip_cost_account_ccid,
                                             cb.asset_cost_account_ccid),
                -- for reserve account
                decode(ah.asset_type, 'CIP', NULL, cb.reserve_account_ccid),
		th.transaction_header_id
	FROM	fa_category_books       cb,
                fa_book_controls        bc,
                fa_books                bk,
		fa_asset_history	ah,
		fa_additions		ad,
		fa_transaction_headers	th
		/* mr_rec.conc_request_id will correspond to the request id
		   for the last time the transaction was "run" by the mass
		   reclass program.
                   BMR: this is no longer true - see BUG# 2371326
                        for rerunnability we will show all assets/trxs

                   WHERE   th.mass_reference_id = mr_rec.conc_request_id
                */
        WHERE   th.mass_transaction_id = mr_rec.mass_reclass_id
	-- there are two transactions, 'RECLASS' and 'ADJUSTMENT'
	AND     ((th.transaction_type_code||'' = 'RECLASS') OR
                 (th.transaction_subtype = 'RECLASS'))
	AND	ad.asset_id = th.asset_id
	AND 	ah.asset_id = th.asset_id
	-- transaction_type_code = 'RECLASS' if transaction is after the period
	-- the asset was added.
	-- use transaction_header_id comparison, since there could be more than
	-- one transaction in the period the asset is added.
	--AND	((th.transaction_type_code = 'RECLASS' AND
	--	  ah.transaction_header_id_in = th.transaction_header_id) OR
	--	 (th.transaction_type_code <> 'RECLASS' AND
	--	  ah.transaction_header_id_in < th.transaction_header_id AND
	--	  nvl(ah.transaction_header_id_out, th.transaction_header_id + 1) >
	--		th.transaction_header_id))
        AND     ah.transaction_header_id_in =
                        decode(th.transaction_type_code, 'RECLASS',
                               th.transaction_header_id, ah.transaction_header_id_in)
	AND	ah.transaction_header_id_in <= th.transaction_header_id
	AND	nvl(ah.transaction_header_id_out, th.transaction_header_id + 1) >
			th.transaction_header_id
        AND     bk.asset_id = th.asset_id
        AND     bk.book_type_code = bc.book_type_code
        AND     bc.book_class IN ('CORPORATE', 'TAX')
        AND     bc.distribution_source_book = th.book_type_code
	-- to select only one book row per book.  selects all the currently
	-- effective books.
	AND	bk.date_ineffective IS NULL
        AND     cb.category_id = mr_rec.to_category_id
        AND     cb.book_type_code = bk.book_type_code
        ORDER BY ad.asset_number, bk.book_type_code;

    -- to store th.transaction_header_id in the cursor above.
    -- transaction header id for RECLASS transaction.
    h_rcl_thid		NUMBER(15);

    -- cursor to get the book information.
    -- book_info1 is used when inherit_deprn_rules_flag = 'YES' but there
    -- was no actual change made in the depreciation rules
    -- (because rules remain the same.)  fetch the book information
    -- at the time of reclass transaction.
    CURSOR book_info1 IS
	SELECT	bk.book_type_code,
                bk.prorate_convention_code,
                bk.ceiling_name,
                bk.deprn_method_code,
                bk.life_in_months,
                bk.basic_rate,
                bk.adjusted_rate,
                bk.bonus_rule,
                bk.production_capacity,
                bk.unit_of_measure,
                bk.depreciate_flag,
                bk.allowed_deprn_limit,
                bk.allowed_deprn_limit_amount,
                bk.percent_salvage_value
        FROM    fa_books                bk
        WHERE   bk.asset_id = a_tbl(a_index).asset_id
	AND	bk.book_type_code = a_tbl(a_index).book_type_code
        -- Get the book row at the time of reclass run.  Need to figure out
        -- the book row by comparing transaction_header_id's, since only
        -- basic reclass transaction is recorded in fa_transaction_headers
        -- table, when redefault is not performed or when rules remain the same.
        AND     bk.transaction_header_id_in < h_rcl_thid
        AND     nvl(bk.transaction_header_id_out, h_rcl_thid + 1) > h_rcl_thid;

    -- cursor to get ADJUSTMENT transaction header id for redefault transaction.
    CURSOR get_adjust_thid IS
	SELECT 	transaction_header_id
	FROM 	fa_transaction_headers
        --      BMR: BUG# 2371326
        --          for rerunnability we will show all assets/trxs
        --      WHERE	mass_reference_id = mr_rec.conc_request_id
        WHERE   mass_transaction_id = mr_rec.mass_reclass_id
        AND     asset_id = a_tbl(a_index).asset_id
	AND	book_type_code = a_tbl(a_index).book_type_code
        AND     transaction_type_code||'' IN
                   ('ADDITION', 'CIP ADDITION', 'ADJUSTMENT', 'CIP ADJUSTMENT','GROUP ADDITION','GROUP ADJUSTMENT');


    -- to store ADJUSTMENT transaction header id for redefault transaction.
    h_adj_thid		NUMBER(15);

    -- cursor to get the book information.
    -- book_info2 is used when inherit_deprn_rules_flag = 'YES' and
    -- when redefault transaction was actually performed and caused
    -- changes in depreciation rules(a separate ADJUSTMENT transaction
    -- is recorded in fa_transaction_headers in this case.)
    CURSOR book_info2 IS
	SELECT	bk.book_type_code,
                bk.prorate_convention_code,
                bk.ceiling_name,
                bk.deprn_method_code,
                bk.life_in_months,
                bk.basic_rate,
                bk.adjusted_rate,
                bk.bonus_rule,
                bk.production_capacity,
                bk.unit_of_measure,
                bk.depreciate_flag,
                bk.allowed_deprn_limit,
                bk.allowed_deprn_limit_amount,
                bk.percent_salvage_value
        FROM    fa_books                bk
	WHERE   bk.asset_id = a_tbl(a_index).asset_id
        AND     bk.book_type_code = a_tbl(a_index).book_type_code
        AND     bk.transaction_header_id_in = h_adj_thid;

    -- cursor to fetch accounting flexfield structure.
    CURSOR get_acct_flex_struct IS
	SELECT 	accounting_flex_structure
	FROM 	fa_book_controls
	WHERE	book_type_code = a_tbl(a_index).book_type_code;

    h_request_id	NUMBER;
    h_msg_count		NUMBER;
    h_msg_data		VARCHAR2(2000) := NULL;
    h_review_status_d   VARCHAR2(10);
    h_current_status_d  VARCHAR2(10);
    h_cat_flex_struct	NUMBER;
    h_acct_flex_struct 	NUMBER;
    h_cat_segs		FA_RX_SHARED_PKG.Seg_Array;
    h_acct_segs		FA_RX_SHARED_PKG.Seg_Array;
    h_category_id	NUMBER(15) := NULL;
    h_concat_cat	VARCHAR2(220);
    h_debug_flag	VARCHAR2(3) := 'NO';
    -- to keep track of the last asset id that entered the mass_reclass_assets
    -- cursor loop.
    h_last_asset	NUMBER(15) := NULL;
    -- indicates whether the book information was found.  used only when
    -- redefault option was set to YES.
    h_bk_info_found	BOOLEAN;
    -- exception raised from this module and child modules.
    mrcl_failure	EXCEPTION;
    -- Commit results per every 200 assets.
    h_commit_level 	NUMBER := 200;
    /* do not need these variables as per bug 8402286
       need to remove large rollback segment
    rbs_name		VARCHAR2(30);
    sql_stmt            VARCHAR2(101);
    */

BEGIN

    -- Initialize message stacks.
    FA_SRVR_MSG.Init_Server_Message;
    FA_DEBUG_PKG.Initialize;

    -- Set debug flag.
    IF (g_print_debug) THEN
	h_debug_flag := 'YES';
    END IF;

/* Fix for BUG# 1302611 where the rbs_name variable was being
   interpreted as a literal string rather than using the
   value of the variable
*/


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

    -- Get concurrent request id for the mass reclass review request.
    -- h_request_id is used when request_id is inserted into the interface
    -- table, fa_mass_reclass_itf.
    -- Need to fetch request id from fnd_global package instead of fa_mass_reclass
    -- table, since fa_mass_reclass table stores the latest request id for
    -- the Preview or Run requests only.
    h_request_id := fnd_global.conc_request_id;

    -- Fetch mass reclass record information.
    OPEN mass_reclass;
    FETCH mass_reclass INTO mr_rec;
    CLOSE mass_reclass;

    /*===========================================================================
      Delete rows previously inserted into the interface table with the same
      request id, if there is any.
     ===========================================================================*/
    DELETE FROM fa_mass_reclass_itf
    WHERE request_id = h_request_id;
    COMMIT;

    /*===========================================================================
      Check to make sure current status is 'COMPLETED'
     ===========================================================================*/
    OPEN get_status;
    FETCH get_status INTO h_review_status_d, h_current_status_d;
    CLOSE get_status;

    IF (h_review_status_d <> h_current_status_d) THEN
        -- Re-using message for mass reclass program.
        FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FARX_RR.Review_Reclass',
                NAME => 'FA_MASSRCL_WRONG_STATUS',
                TOKEN1 => 'CURRENT',
                VALUE1 => h_current_status_d,
                TOKEN2 => 'RUNNING',
                VALUE2 => h_review_status_d);
        -- Review will complete with error status.
        RAISE mrcl_failure;
    END IF;

    /*===========================================================================
      Insert review records into the interface table.
     ===========================================================================*/

    /* Get category flex structure. */
    OPEN get_cat_flex_struct;
    FETCH get_cat_flex_struct INTO h_cat_flex_struct;
    CLOSE get_cat_flex_struct;

    /* Fetch asset-book pairs from mass_reclass_assets cursor and insert them
       into the interface table, fa_mass_reclass_itf. */
    IF (mr_rec.redefault_flag = 'NO') THEN
	OPEN mass_reclass_assets1;

	LOOP
	    -- Fetch the asset-book pair into the pl/sql table.
	    a_index := a_index + 1;
            FETCH mass_reclass_assets1 INTO a_tbl(a_index);
            EXIT WHEN mass_reclass_assets1%NOTFOUND;

	    /* Convert results into appropriate formats. */
	    -- Get category in concatenated string format.
	    IF (a_tbl(a_index).category_id <> h_category_id OR
		h_category_id IS NULL) THEN
		FA_RX_SHARED_PKG.Concat_Category(
        		struct_id       => h_cat_flex_struct,
        		ccid            => a_tbl(a_index).category_id,
        		concat_string   => a_tbl(a_index).category,
        		segarray        => h_cat_segs);
 		-- Keep track of last category_id.
	    	h_category_id := a_tbl(a_index).category_id;
		h_concat_cat := a_tbl(a_index).category;
	    ELSE
		a_tbl(a_index).category := h_concat_cat;
	    END IF;

	    -- Get numbers in rounded figures.
	    FA_MASS_REC_UTILS_PKG.Convert_Formats(
		X_Life_In_Months => a_tbl(a_index).life_in_months,
                X_Basic_Rate     => a_tbl(a_index).basic_rate,
                X_Adjusted_Rate  => a_tbl(a_index).adjusted_rate,
                X_Allowed_Deprn_Limit => a_tbl(a_index).allowed_deprn_limit,
                X_Percent_Salvage_Val => a_tbl(a_index).percent_salvage_val,
                X_Life           => a_tbl(a_index).life,
                X_Basic_Rate_Pct => a_tbl(a_index).basic_rate_pct,
                X_Adjusted_Rate_Pct   => a_tbl(a_index).adjusted_rate_pct,
                X_Deprn_Limit_Pct     => a_tbl(a_index).deprn_limit_pct,
                X_Salvage_Val_Pct     => a_tbl(a_index).salvage_val_pct,
                p_log_level_rec      => g_log_level_rec
                );

	    -- Get cost and reserve accounts in concatenated formats.
	    OPEN get_acct_flex_struct;
	    FETCH get_acct_flex_struct INTO h_acct_flex_struct;
	    CLOSE get_acct_flex_struct;

	    IF (a_tbl(a_index).cost_acct_ccid IS NOT NULL) THEN
		FA_RX_SHARED_PKG.Concat_Acct (
           		struct_id => h_acct_flex_struct,
           		ccid => a_tbl(a_index).cost_acct_ccid,
           		concat_string => a_tbl(a_index).cost_acct,
           		segarray => h_acct_segs);
	    END IF;

	    IF (a_tbl(a_index).deprn_rsv_acct_ccid IS NOT NULL) THEN
		FA_RX_SHARED_PKG.Concat_Acct (
           		struct_id => h_acct_flex_struct,
           		ccid => a_tbl(a_index).deprn_rsv_acct_ccid,
           		concat_string => a_tbl(a_index).deprn_rsv_acct,
           		segarray => h_acct_segs);
	    END IF;

	    -- Update last asset processed and the asset count.
	    IF (a_tbl(a_index).asset_id <> h_last_asset OR
		h_last_asset IS NULL) THEN
		h_last_asset := a_tbl(a_index).asset_id;
		g_asset_count := g_asset_count + 1;
	    END IF;

            /* Insert asset records into the interface table, FA_MASS_RECLASS_ITF,
               at every 200 assets and re-initialize the counter and the asset table. */
	    -- If the 200th asset belongs to more than one book, only the information
	    -- for the first book of this asset will be inserted into the table.
	    -- The rest will be taken care of in the next insertion.
	    IF (g_asset_count = h_commit_level) THEN
		FOR i IN 1 .. a_index LOOP
        	    FA_MASS_REC_UTILS_PKG.Insert_Itf(
                	X_Report_Type           => 'REVIEW',
                	X_Request_Id            => h_request_id,
			X_Mass_Reclass_Id	=> X_Mass_Reclass_Id,
                	X_Asset_Rec             => a_tbl(i),
                	X_New_Category          => NULL,
               	 	X_Last_Update_Date      => mr_rec.last_update_date,
                	X_Last_Updated_By       => mr_rec.last_updated_by,
                	X_Created_By            => mr_rec.created_by,
                	X_Creation_Date         => mr_rec.creation_date,
                	X_Last_Update_Login     => mr_rec.last_update_login,
                p_log_level_rec      => g_log_level_rec
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

      	CLOSE mass_reclass_assets1;

    -----------------------------------------------------------------------------------

    ELSIF (mr_rec.redefault_flag = 'YES') THEN
	OPEN mass_reclass_assets2;

	LOOP
	    -- Fetch the asset-book pair into the pl/sql table.
	    a_index := a_index + 1;
            FETCH mass_reclass_assets2
	    INTO  a_tbl(a_index).asset_id, a_tbl(a_index).asset_number,
		  a_tbl(a_index).description,
		  a_tbl(a_index).book_type_code, a_tbl(a_index).category_id,
		  a_tbl(a_index).cost_acct_ccid, a_tbl(a_index).deprn_rsv_acct_ccid,
		  h_rcl_thid;
            EXIT WHEN mass_reclass_assets2%NOTFOUND;

	    /* Fetch the remaining book information. */
	    -- First, check if ADJUSTMENT actually occurred.
	    OPEN get_adjust_thid;
	    FETCH get_adjust_thid INTO h_adj_thid;
	    IF get_adjust_thid%notfound THEN
	    -- No ADJUSTMENT transaction recorded.
	    -- Get the book info at the time of RECLASS transaction.
		CLOSE get_adjust_thid;
		OPEN book_info1;
		FETCH book_info1
		INTO  a_tbl(a_index).book_type_code, a_tbl(a_index).convention,
                      a_tbl(a_index).ceiling, a_tbl(a_index).method,
                      a_tbl(a_index).life_in_months, a_tbl(a_index).basic_rate,
                      a_tbl(a_index).adjusted_rate, a_tbl(a_index).bonus_rule,
                      a_tbl(a_index).capacity, a_tbl(a_index).unit_of_measure,
                      a_tbl(a_index).depreciate_flag,
		      a_tbl(a_index).allowed_deprn_limit,
		      a_tbl(a_index).deprn_limit_amt,
		      a_tbl(a_index).percent_salvage_val;
		IF book_info1%notfound THEN
		    -- This book was not open at the time of reclass transaction.
		    -- It opened at the time after this transaction.
		    CLOSE book_info1;
		    h_bk_info_found := FALSE;  -- Book info not found.
		    -- Decrement the index so that the next asset-book record
		    -- overwrites on this position.
		    a_index := a_index - 1;
		ELSE
		    CLOSE book_info1;
		    h_bk_info_found := TRUE;
	   	END IF;
	    ELSE
		CLOSE get_adjust_thid;
		OPEN book_info2;
		FETCH book_info2
		INTO  a_tbl(a_index).book_type_code, a_tbl(a_index).convention,
                      a_tbl(a_index).ceiling, a_tbl(a_index).method,
                      a_tbl(a_index).life_in_months, a_tbl(a_index).basic_rate,
                      a_tbl(a_index).adjusted_rate, a_tbl(a_index).bonus_rule,
                      a_tbl(a_index).capacity, a_tbl(a_index).unit_of_measure,
                      a_tbl(a_index).depreciate_flag,
		      a_tbl(a_index).allowed_deprn_limit,
		      a_tbl(a_index).deprn_limit_amt,
		      a_tbl(a_index).percent_salvage_val;
		CLOSE book_info2;
		h_bk_info_found := TRUE;
	    END IF;

	    /* Process the remaining only if book info was found. */

	    IF h_bk_info_found THEN
	    	/* Convert results into appropriate formats. */
	    	-- Get category in concatenated string format.
	    	IF (a_tbl(a_index).category_id <> h_category_id OR
		    h_category_id IS NULL) THEN
		    FA_RX_SHARED_PKG.Concat_Category(
        		struct_id       => h_cat_flex_struct,
        		ccid            => a_tbl(a_index).category_id,
        		concat_string   => a_tbl(a_index).category,
        		segarray        => h_cat_segs);
 		    -- Keep track of last category_id.
	    	    h_category_id := a_tbl(a_index).category_id;
		    h_concat_cat := a_tbl(a_index).category;
	    	ELSE
		    a_tbl(a_index).category := h_concat_cat;
	    	END IF;

	    	-- Get numbers in rounded figures.
	    	FA_MASS_REC_UTILS_PKG.Convert_Formats(
			X_Life_In_Months => a_tbl(a_index).life_in_months,
                	X_Basic_Rate     => a_tbl(a_index).basic_rate,
                	X_Adjusted_Rate  => a_tbl(a_index).adjusted_rate,
                	X_Allowed_Deprn_Limit => a_tbl(a_index).allowed_deprn_limit,
                	X_Percent_Salvage_Val => a_tbl(a_index).percent_salvage_val,
                	X_Life           => a_tbl(a_index).life,
                	X_Basic_Rate_Pct => a_tbl(a_index).basic_rate_pct,
                	X_Adjusted_Rate_Pct   => a_tbl(a_index).adjusted_rate_pct,
                	X_Deprn_Limit_Pct     => a_tbl(a_index).deprn_limit_pct,
                	X_Salvage_Val_Pct     => a_tbl(a_index).salvage_val_pct,
                p_log_level_rec      => g_log_level_rec
                	);

	    	-- Get cost and reserve accounts in concatenated formats.
	    	OPEN get_acct_flex_struct;
	    	FETCH get_acct_flex_struct INTO h_acct_flex_struct;
	    	CLOSE get_acct_flex_struct;

	    	IF (a_tbl(a_index).cost_acct_ccid IS NOT NULL) THEN
		    FA_RX_SHARED_PKG.Concat_Acct (
           		struct_id => h_acct_flex_struct,
           		ccid => a_tbl(a_index).cost_acct_ccid,
           		concat_string => a_tbl(a_index).cost_acct,
           		segarray => h_acct_segs);
	    	END IF;

	    	IF (a_tbl(a_index).deprn_rsv_acct_ccid IS NOT NULL) THEN
		    FA_RX_SHARED_PKG.Concat_Acct (
           		struct_id => h_acct_flex_struct,
           		ccid => a_tbl(a_index).deprn_rsv_acct_ccid,
           		concat_string => a_tbl(a_index).deprn_rsv_acct,
           		segarray => h_acct_segs);
	    	END IF;

	    	-- Update last asset processed and the asset count.
	    	IF (a_tbl(a_index).asset_id <> h_last_asset OR
		    h_last_asset IS NULL) THEN
		    h_last_asset := a_tbl(a_index).asset_id;
		    g_asset_count := g_asset_count + 1;
	    	END IF;

            	/* Insert asset records into the interface table, FA_MASS_RECLASS_ITF,
               	   at every 200 assets and re-initialize the counter and the asset table. */
	    	-- If the 200th asset belongs to more than one book, only the information
	    	-- for the first book of this asset will be inserted into the table.
	    	-- The rest will be taken care of in the next insertion.
	    	IF (g_asset_count = h_commit_level) THEN
		    FOR i IN 1 .. a_index LOOP
        	        FA_MASS_REC_UTILS_PKG.Insert_Itf(
                		X_Report_Type           => 'REVIEW',
                		X_Request_Id            => h_request_id,
				X_Mass_Reclass_Id	=> X_Mass_Reclass_Id,
                		X_Asset_Rec             => a_tbl(i),
                		X_New_Category          => NULL,
               	 		X_Last_Update_Date      => mr_rec.last_update_date,
                		X_Last_Updated_By       => mr_rec.last_updated_by,
                		X_Created_By            => mr_rec.created_by,
                		X_Creation_Date         => mr_rec.creation_date,
                		X_Last_Update_Login     => mr_rec.last_update_login,
                p_log_level_rec      => g_log_level_rec
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

	    END IF; /* IF h_bk_info_found */

	END LOOP;

      	CLOSE mass_reclass_assets2;

    END IF; /* IF (mr_rec.redefault_flag = 'NO') */

    /* Insert the remaining asset records into the interface table. */
    -- Up to a_index - 1, to account for the extra increment taken for a_index
    -- when no more rows were found in the cursor loop.
    FOR i IN 1 .. (a_index - 1) LOOP
	FA_MASS_REC_UTILS_PKG.Insert_Itf(
		X_Report_Type		=> 'REVIEW',
        	X_Request_Id  		=> h_request_id,
		X_Mass_Reclass_Id	=> X_Mass_Reclass_Id,
        	X_Asset_Rec             => a_tbl(i),
        	X_New_Category         	=> NULL,
        	X_Last_Update_Date    	=> mr_rec.last_update_date,
        	X_Last_Updated_By    	=> mr_rec.last_updated_by,
        	X_Created_By        	=> mr_rec.created_by,
        	X_Creation_Date    	=> mr_rec.creation_date,
        	X_Last_Update_Login     => mr_rec.last_update_login,
                p_log_level_rec      => g_log_level_rec
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

    errbuf := ''; -- No error.
    retcode := 0; -- Completed normally.

EXCEPTION
    WHEN mrcl_failure THEN
	retcode := 2;  -- Completed with error.

	-- Reset global variable values.
	a_tbl.delete;
	a_index := 0;
	g_asset_count := 0;
        /* A fatal error has occurred.  Rollback transaction. */
        ROLLBACK WORK;
        /* Delete rows inserted into the interface table. */
        DELETE FROM fa_mass_reclass_itf
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
            FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN => 'FARX_RP.Preview_Reclass');
        END IF;

	-- Reset global variable values.
	a_tbl.delete;
	a_index := 0;
	g_asset_count := 0;
	--g_total_assets := 0;
        /* A fatal error has occurred.  Rollback transaction. */
        ROLLBACK WORK;
        /* Delete rows inserted into the interface table. */
        DELETE FROM fa_mass_reclass_itf
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
END Review_Reclass;


END FARX_RR;

/
