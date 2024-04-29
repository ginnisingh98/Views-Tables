--------------------------------------------------------
--  DDL for Package Body FARX_RP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_RP" AS
/* $Header: FARXRPB.pls 120.7.12010000.2 2009/07/19 11:43:19 glchen ship $ */

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
-- Total number of assets to be printed in report.
--g_total_assets 	NUMBER := 0;
/* a_index <> g_asset_count if asset belongs to more than one book. */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

g_log_level_rec fa_api_types.log_level_rec_type;

/*============================================================================+
|   PROCEDURE Preview_Reclass                                                 |
+=============================================================================*/

PROCEDURE Preview_Reclass(
	X_Mass_Reclass_Id	IN	NUMBER,
	X_RX_Flag		IN	VARCHAR2 := 'NO',
	retcode		 OUT NOCOPY NUMBER,
	errbuf		 OUT NOCOPY VARCHAR2) IS

    -- cursor to fetch the current and preview status
    CURSOR get_status IS
        SELECT  lu_prev.meaning,
                lu_curr.meaning
        FROM    fa_lookups lu_prev,
                fa_lookups lu_curr
        WHERE   lu_prev.lookup_type = 'MASS_TRX_STATUS'  AND
                lu_prev.lookup_code = 'PREVIEW'
        AND     lu_curr.lookup_type = 'MASS_TRX_STATUS' AND
                lu_curr.lookup_code = mr_rec.status;

    -- cursor to get category flex structure.
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

    -- assets that meet the user's selection criteria.
    -- some assets selected by this cursor are discarded in the validation engine.
    CURSOR mass_reclass_assets IS
	SELECT 	ad.asset_id,
	    	ad.asset_number,
		ad.description,
		ad.asset_category_id
	FROM	gl_code_combinations	gc,
		fa_distribution_history	dh,
		fa_book_controls	bc,
		fa_books		bk,
		fa_additions		ad
	WHERE	ad.asset_type = nvl(mr_rec.asset_type, ad.asset_type)
	AND	ad.asset_number >= nvl(mr_rec.from_asset_number, ad.asset_number)
	AND	ad.asset_number <= nvl(mr_rec.to_asset_number, ad.asset_number)
	AND	nvl(ad.asset_key_ccid, -9999)  = nvl(mr_rec.asset_key_id,
						  nvl(ad.asset_key_ccid, -9999))
	AND	ad.asset_category_id = nvl(mr_rec.from_category_id, ad.asset_category_id)
	AND	bk.book_type_code = mr_rec.book_type_code
	AND	bk.book_type_code = bc.book_type_code
	-- corp book should be currently effective.
	AND	nvl(bc.date_ineffective, sysdate+1) > sysdate
	AND	bk.asset_id = ad.asset_id
    AND NVL(bk.Disabled_flag, 'N') = 'N' --HH
	AND	bk.date_ineffective IS NULL -- pick the most recent row.
	-- dpis, exp acct, employee, location, cost range: selection criteria
	-- for corporate book only.
	AND 	bk.date_placed_in_service >= nvl(mr_rec.from_dpis,
						 bk.date_placed_in_service)
	AND	bk.date_placed_in_service <= nvl(mr_rec.to_dpis,
						 bk.date_placed_in_service)
	AND	bk.cost >= nvl(mr_rec.from_cost, bk.cost)
	AND	bk.cost <= nvl(mr_rec.to_cost, bk.cost)
	AND	dh.asset_id = ad.asset_id
	AND	nvl(dh.assigned_to, -9999) = nvl(mr_rec.employee_id, nvl(dh.assigned_to, -9999))
	AND	dh.location_id = nvl(mr_rec.location_id, dh.location_id)
	AND	dh.date_ineffective IS NULL -- pick only the active distributions.
	AND	dh.code_combination_id = gc.code_combination_id
	-- cannot avoid the use of OR, since gc.segment1 can be null.
	-- cannot use nvl(gc.segment1, 'NULL') for comparison, since
	-- the value 'NULL' may fall between the range accidentally.
	-- may break the OR to UNION later.
        -- rule-based optimizer transforms OR to UNION ALL automatically
        -- when it sees it being more efficient.  since the columns
        -- in OR are not indexed, transforming to UNION ALL has
        -- no gain in performance and using OR is unavoidable here
        -- for the correctness of the program.
	AND	((gc.segment1 between nvl(mr_rec.segment1_low, gc.segment1)
				  and nvl(mr_rec.segment1_high, gc.segment1)) OR
		 (mr_rec.segment1_low IS NULL and mr_rec.segment1_high IS NULL))
	AND	((gc.segment2 between nvl(mr_rec.segment2_low, gc.segment2)
				  and nvl(mr_rec.segment2_high, gc.segment2)) OR
		 (mr_rec.segment2_low IS NULL and mr_rec.segment2_high IS NULL))
	AND	((gc.segment3 between nvl(mr_rec.segment3_low, gc.segment3)
				  and nvl(mr_rec.segment3_high, gc.segment3)) OR
		 (mr_rec.segment3_low IS NULL and mr_rec.segment3_high IS NULL))
	AND	((gc.segment4 between nvl(mr_rec.segment4_low, gc.segment4)
				  and nvl(mr_rec.segment4_high, gc.segment4)) OR
		 (mr_rec.segment4_low IS NULL and mr_rec.segment4_high IS NULL))
	AND	((gc.segment5 between nvl(mr_rec.segment5_low, gc.segment5)
				  and nvl(mr_rec.segment5_high, gc.segment5)) OR
		 (mr_rec.segment5_low IS NULL and mr_rec.segment5_high IS NULL))
	AND	((gc.segment6 between nvl(mr_rec.segment6_low, gc.segment6)
				  and nvl(mr_rec.segment6_high, gc.segment6)) OR
		 (mr_rec.segment6_low IS NULL and mr_rec.segment6_high IS NULL))
	AND	((gc.segment7 between nvl(mr_rec.segment7_low, gc.segment7)
				  and nvl(mr_rec.segment7_high, gc.segment7)) OR
		 (mr_rec.segment7_low IS NULL and mr_rec.segment7_high IS NULL))
	AND	((gc.segment8 between nvl(mr_rec.segment8_low, gc.segment8)
				  and nvl(mr_rec.segment8_high, gc.segment8)) OR
		 (mr_rec.segment8_low IS NULL and mr_rec.segment8_high IS NULL))
	AND	((gc.segment9 between nvl(mr_rec.segment9_low, gc.segment9)
				  and nvl(mr_rec.segment9_high, gc.segment9)) OR
		 (mr_rec.segment9_low IS NULL and mr_rec.segment9_high IS NULL))
	AND	((gc.segment10 between nvl(mr_rec.segment10_low, gc.segment10)
				  and nvl(mr_rec.segment10_high, gc.segment10)) OR
		 (mr_rec.segment10_low IS NULL and mr_rec.segment10_high IS NULL))
	AND	((gc.segment11 between nvl(mr_rec.segment11_low, gc.segment11)
				  and nvl(mr_rec.segment11_high, gc.segment11)) OR
		 (mr_rec.segment11_low IS NULL and mr_rec.segment11_high IS NULL))
	AND	((gc.segment12 between nvl(mr_rec.segment12_low, gc.segment12)
				  and nvl(mr_rec.segment12_high, gc.segment12)) OR
		 (mr_rec.segment12_low IS NULL and mr_rec.segment12_high IS NULL))
	AND	((gc.segment13 between nvl(mr_rec.segment13_low, gc.segment13)
				  and nvl(mr_rec.segment13_high, gc.segment13)) OR
		 (mr_rec.segment13_low IS NULL and mr_rec.segment13_high IS NULL))
	AND	((gc.segment14 between nvl(mr_rec.segment14_low, gc.segment14)
				  and nvl(mr_rec.segment14_high, gc.segment14)) OR
		 (mr_rec.segment14_low IS NULL and mr_rec.segment14_high IS NULL))
	AND	((gc.segment15 between nvl(mr_rec.segment15_low, gc.segment15)
				  and nvl(mr_rec.segment15_high, gc.segment15)) OR
		 (mr_rec.segment15_low IS NULL and mr_rec.segment15_high IS NULL))
	AND	((gc.segment16 between nvl(mr_rec.segment16_low, gc.segment16)
				  and nvl(mr_rec.segment16_high, gc.segment16)) OR
		 (mr_rec.segment16_low IS NULL and mr_rec.segment16_high IS NULL))
	AND	((gc.segment17 between nvl(mr_rec.segment17_low, gc.segment17)
				  and nvl(mr_rec.segment17_high, gc.segment17)) OR
		 (mr_rec.segment17_low IS NULL and mr_rec.segment17_high IS NULL))
	AND	((gc.segment18 between nvl(mr_rec.segment18_low, gc.segment18)
				  and nvl(mr_rec.segment18_high, gc.segment18)) OR
		 (mr_rec.segment18_low IS NULL and mr_rec.segment18_high IS NULL))
	AND	((gc.segment19 between nvl(mr_rec.segment19_low, gc.segment19)
				  and nvl(mr_rec.segment19_high, gc.segment19)) OR
		 (mr_rec.segment19_low IS NULL and mr_rec.segment19_high IS NULL))
	AND	((gc.segment20 between nvl(mr_rec.segment20_low, gc.segment20)
				  and nvl(mr_rec.segment20_high, gc.segment20)) OR
		 (mr_rec.segment20_low IS NULL and mr_rec.segment20_high IS NULL))
	AND	((gc.segment21 between nvl(mr_rec.segment21_low, gc.segment21)
				  and nvl(mr_rec.segment21_high, gc.segment21)) OR
		 (mr_rec.segment21_low IS NULL and mr_rec.segment21_high IS NULL))
	AND	((gc.segment22 between nvl(mr_rec.segment22_low, gc.segment22)
				  and nvl(mr_rec.segment22_high, gc.segment22)) OR
		 (mr_rec.segment22_low IS NULL and mr_rec.segment22_high IS NULL))
	AND	((gc.segment23 between nvl(mr_rec.segment23_low, gc.segment23)
				  and nvl(mr_rec.segment23_high, gc.segment23)) OR
		 (mr_rec.segment23_low IS NULL and mr_rec.segment23_high IS NULL))
	AND	((gc.segment24 between nvl(mr_rec.segment24_low, gc.segment24)
				  and nvl(mr_rec.segment24_high, gc.segment24)) OR
		 (mr_rec.segment24_low IS NULL and mr_rec.segment24_high IS NULL))
	AND	((gc.segment25 between nvl(mr_rec.segment25_low, gc.segment25)
				  and nvl(mr_rec.segment25_high, gc.segment25)) OR
		 (mr_rec.segment25_low IS NULL and mr_rec.segment25_high IS NULL))
	AND	((gc.segment26 between nvl(mr_rec.segment26_low, gc.segment26)
				  and nvl(mr_rec.segment26_high, gc.segment26)) OR
		 (mr_rec.segment26_low IS NULL and mr_rec.segment26_high IS NULL))
	AND	((gc.segment27 between nvl(mr_rec.segment27_low, gc.segment27)
				  and nvl(mr_rec.segment27_high, gc.segment27)) OR
		 (mr_rec.segment27_low IS NULL and mr_rec.segment27_high IS NULL))
	AND	((gc.segment28 between nvl(mr_rec.segment28_low, gc.segment28)
				  and nvl(mr_rec.segment28_high, gc.segment28)) OR
		 (mr_rec.segment28_low IS NULL and mr_rec.segment28_high IS NULL))
	AND	((gc.segment29 between nvl(mr_rec.segment29_low, gc.segment29)
				  and nvl(mr_rec.segment29_high, gc.segment29)) OR
		 (mr_rec.segment29_low IS NULL and mr_rec.segment29_high IS NULL))
	AND	((gc.segment30 between nvl(mr_rec.segment30_low, gc.segment30)
				  and nvl(mr_rec.segment30_high, gc.segment30)) OR
		 (mr_rec.segment30_low IS NULL and mr_rec.segment30_high IS NULL))
	-- more check is done on retired asset in reclass validation engine.
	-- more check is done on reserved asset in Check_Criteria function.
	AND	bk.period_counter_fully_retired IS NULL
	ORDER BY ad.asset_number;

    h_request_id	NUMBER;
    h_msg_count		NUMBER;
    h_msg_data		VARCHAR2(2000) := NULL;
    h_preview_status_d  VARCHAR2(80);
    h_current_status_d  VARCHAR2(80);
    h_status 	 	BOOLEAN := FALSE;
    -- to keep track of the last asset id that entered the mass_reclass_assets
    -- cursor loop.  we need this to avoid DISTINCT in the SELECT statement
    -- for mass_reclass_assets cursor.  asset may be selected multiple times
    -- if it is multi-distributed and if more than one distribution lines
    -- meet the reclass selection criteria(if at least one distribution line
    -- meets user criteria, the asset is selected for reclass.)
    h_last_asset	NUMBER(15) := NULL;
    h_cat_flex_struct	NUMBER;
    h_new_concat_cat    VARCHAR2(220);  -- new category in concatenated string.
    h_cat_segs		FA_RX_SHARED_PKG.Seg_Array;
    h_debug_flag	VARCHAR2(3) := 'NO';
    -- exception raised from this module and child modules.
    mrcl_failure	EXCEPTION;
    h_dummy		VARCHAR2(30);
    -- Commit results per every 200 assets.
    h_commit_level	NUMBER := 200;
    /* do not need these variables as per bug 8402286
       need to remove large rollback segment
    rbs_name            VARCHAR2(30);
    sql_stmt            VARCHAR2(101);
    */

BEGIN

    -- Initialize message stacks.
    FA_SRVR_MSG.Init_Server_Message;

    FA_DEBUG_PKG.Initialize;

    FA_DEBUG_PKG.SET_DEBUG_FLAG;

    -- Set debug flag.
    IF (g_print_debug) THEN
	h_debug_flag := 'YES';
    END IF;

          if (g_print_debug) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Starting Preview',
	        '');
	  end if;
/* Fix for BUG# 1302611 where rbs_name was being intepreted as a literal
   rather than using the value in the variable
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
    --g_total_assets := 0;

    -- Get concurrent request id for the mass reclass preview request.
    -- h_request_id is used when request_id is inserted into the interface
    -- table, fa_mass_reclass_itf.
    -- Need to fetch request id from fnd_global package instead of fa_mass_reclass
    -- table, since fa_mass_reclass table stores the latest request id for
    -- the SRS Preview report requests(run after this module) or
    -- Run requests only.
    h_request_id := fnd_global.conc_request_id;

    -- Fetch mass reclass record information.
    OPEN mass_reclass;
    FETCH mass_reclass INTO mr_rec;
    CLOSE mass_reclass;

    -- Concurrent request id fetched from fa_mass_reclass table is in no use
    -- in the preview module.
    -- Assign h_request_id to the global mass reclass record field so that
    -- it can be used in other procedures.
    mr_rec.conc_request_id := h_request_id;

    /*=========================================================================
      Delete rows previously inserted into the interface table with the same
      request id, if there is any.
     =========================================================================*/
    DELETE FROM fa_mass_reclass_itf
    WHERE request_id = h_request_id;
    COMMIT;

    /*=========================================================================
      Check to make sure current status is 'PREVIEW'
     =========================================================================*/
    OPEN get_status;
    FETCH get_status INTO h_preview_status_d, h_current_status_d;
    CLOSE get_status;

    IF (h_preview_status_d <> h_current_status_d) THEN
        -- Re-using message for mass reclass program.
        FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FARX_RP.Preview_Reclass',
                NAME => 'FA_MASSRCL_WRONG_STATUS',
                TOKEN1 => 'CURRENT',
                VALUE1 => h_current_status_d,
                TOKEN2 => 'RUNNING',
                VALUE2 => h_preview_status_d);
        -- Preview will complete with error status.
        RAISE mrcl_failure;
    END IF;

    /*=========================================================================
      Check if reclass transaction date for the mass reclass record from
      mass reclass form is in the current corporate book period.
      (No prior period reclass is allowed.)
     =========================================================================*/
    IF NOT FA_MASS_RECLASS_PKG.Check_Trans_Date(
                X_Corp_Book     => mr_rec.book_type_code,
                X_Trans_Date    => mr_rec.trans_date_entered) THEN
        RAISE mrcl_failure;
    END IF;

    /*=========================================================================
      Validate assets and insert preview records into the interface table.
     =========================================================================*/
    IF (mr_rec.redefault_flag = 'YES') THEN
    -- Depreciation rules will be redefaulted.
        -- Reset g_deprn_count before loading the cache table.
        FA_LOAD_TBL_PKG.g_deprn_count := 0;
        -- Load depreciation rules table for the corporate book and all the
        -- associated tax books for the new category.
        -- Simulates caching effect.
        FA_LOAD_TBL_PKG.Load_Deprn_Rules_Tbl(
                p_corp_book     => mr_rec.book_type_code,
                p_category_id   => mr_rec.to_category_id,
                x_return_status => h_status,
                p_log_level_rec => g_log_level_rec);
        IF NOT h_status THEN
                RAISE mrcl_failure;
        END IF;
	-- Load the conversion table to store converted values for certain
	-- fields of the depreciation rules records in the depreciation rules
	-- table.
	FA_MASS_REC_UTILS_PKG.Load_Conversion_Table(p_log_level_rec => g_log_level_rec);
    END IF;

    /* Get category flex structure. */
    OPEN get_cat_flex_struct;
    FETCH get_cat_flex_struct INTO h_cat_flex_struct;
    CLOSE get_cat_flex_struct;

    /* Get the new category code from the new category id. */
    FA_RX_SHARED_PKG.Concat_Category(
                struct_id       => h_cat_flex_struct,
                ccid            => mr_rec.to_category_id,
                concat_string   => h_new_concat_cat,
                segarray        => h_cat_segs);

    /* Loop all the qualified assets, and insert all the validated assets
       into the interface table, fa_mass_reclass_itf. */
    OPEN mass_reclass_assets;

    LOOP
	a_index := a_index + 1;
        FETCH mass_reclass_assets
	INTO a_tbl(a_index).asset_id, a_tbl(a_index).asset_number,
	     a_tbl(a_index).description, a_tbl(a_index).category_id;
        EXIT WHEN mass_reclass_assets%NOTFOUND;

	IF (a_tbl(a_index).asset_id <> h_last_asset OR
	    h_last_asset IS NULL) THEN
	-- This is the first time the asset entered this loop.

	    -- Save the asset id for the next loop.
	    h_last_asset := a_tbl(a_index).asset_id;

	    -- Check if the asset meets the additional user criteria.
	    IF FA_MASS_RECLASS_PKG.Check_Criteria(
                        X_Asset_Id              => a_tbl(a_index).asset_id,
                        X_Fully_Rsvd_Flag       => mr_rec.fully_rsvd_flag) THEN

          if (g_print_debug) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Preview - after check_criteria',
	        a_tbl(a_index).asset_id );
	  end if;
		IF (a_tbl(a_index).category_id = mr_rec.to_category_id) THEN
		-- Reclass and redefault are not processed on the asset, if
                -- the new category is the same as the old category.
		-- Retrieve the old asset information into the pl/sql table,
	        -- a_tbl for all the books the asset belongs to.
		-- (At every 200 assets, the records stored in a_tbl, will be inserted
		--  into the interface table.)
		    Store_Results(X_Get_New_Rules => 'NO',
				  X_Cat_Flex_Struct => h_cat_flex_struct);
		    -- Increment the number of assets stored in a_tbl.
		    g_asset_count := g_asset_count + 1;
	    	ELSE
		    /* Validate asset for reclass with Reclass Validation engine. */
		    IF FA_REC_PVT_PKG1.Validate_Reclass_Basic(
                	  p_asset_id              => a_tbl(a_index).asset_id,
                	  p_old_category_id       => a_tbl(a_index).category_id,
                	  p_new_category_id       => mr_rec.to_category_id,
                	  p_mr_req_id             => h_request_id,
                	  x_old_cat_type          => h_dummy,
                          p_log_level_rec         => g_log_level_rec) THEN
			-- Now, we allow redefault to be performed per book.
			-- Validate redefault per each book and store the
			-- results in the asset table.
			Store_Results(X_Get_New_Rules => 'YES',
				      X_Cat_Flex_Struct => h_cat_flex_struct);
			-- Increment the number of assets stored in a_tbl.
		    	g_asset_count := g_asset_count + 1;
		    ELSE
          if (g_print_debug) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Preview - validate_reclass_basic skipped asset',
	        a_tbl(a_index).asset_id );
	  end if;
		    -- Basic reclass validation failed.  Reclass fails.
			a_index := a_index - 1;
		    END IF; /* IF FA_REC_PVT_PKG1.Validate_Reclass_Basic */
		END IF; /* IF (a_tbl(a_index).category_id = */
	    ELSE
          if (g_print_debug) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Preview - check_criteria skipped asset ',
	        a_tbl(a_index).asset_id );
	  end if;
		-- Invalid asset record.
		a_index := a_index - 1;
	    END IF; /* 	IF FA_MASS_RECLASS_PKG.Check_Criteria */
	ELSE /* a_tbl(a_index).asset_id = h_last_asset */
	    -- This asset has already been validated.  Decrementing index count
	    -- to avoid records with duplicate asset id's in a_tbl.
	    a_index := a_index - 1;
	END IF; /* IF (a_tbl(a_index).asset_id <> */

	/* Insert asset records into the interface table, FA_MASS_RECLASS_ITF,
	   at every 200 assets. */
	-- If g_asset_count(number of valid assets) = 200, insert all the 200
	-- asset records in a_tbl(1..a_index) into the interface table,
	-- re-initialize the pl/sql table, a_tbl, and reset g_asset_count
	-- and a_index to 0.  Commit changes at every 200 assets as well.
	IF (g_asset_count = h_commit_level) THEN
	    FOR i IN 1 .. a_index LOOP
          if (g_print_debug) then
               fa_debug_pkg.add('FARX_RP.Preview_Reclass',
	       'Preview - inserting asset into itf-table',
	        a_tbl(a_index).asset_id );
	  end if;
	        FA_MASS_REC_UTILS_PKG.Insert_Itf(
		 	X_Report_Type		=> 'PREVIEW',
        		X_Request_Id  		=> h_request_id,
			X_Mass_Reclass_Id	=> X_Mass_Reclass_Id,
        		X_Asset_Rec             => a_tbl(i),
        		X_New_Category         	=> h_new_concat_cat,
        		X_Last_Update_Date    	=> mr_rec.last_update_date,
        		X_Last_Updated_By    	=> mr_rec.last_updated_by,
        		X_Created_By        	=> mr_rec.created_by,
        		X_Creation_Date    	=> mr_rec.creation_date,
        		X_Last_Update_Login     => mr_rec.last_update_login,
                        p_log_level_rec => g_log_level_rec
        		);
	    END LOOP;
	    a_tbl.delete;
	    --g_total_assets := g_total_assets + g_asset_count;
	    g_asset_count := 0;
	    a_index := 0;
	    COMMIT WORK;
	END IF;

    END LOOP;

    CLOSE mass_reclass_assets;

    /* Insert the remaining valid asset records into the interface table. */
    -- Up to a_index - 1, to account for the extra increment taken for a_index
    -- when no more rows were found in the cursor loop.
    FOR i IN 1 .. (a_index - 1) LOOP
	FA_MASS_REC_UTILS_PKG.Insert_Itf(
		X_Report_Type		=> 'PREVIEW',
        	X_Request_Id  		=> h_request_id,
		X_Mass_Reclass_Id	=> X_Mass_Reclass_Id,
        	X_Asset_Rec             => a_tbl(i),
        	X_New_Category         	=> h_new_concat_cat,
        	X_Last_Update_Date    	=> mr_rec.last_update_date,
        	X_Last_Updated_By    	=> mr_rec.last_updated_by,
        	X_Created_By        	=> mr_rec.created_by,
        	X_Creation_Date    	=> mr_rec.creation_date,
        	X_Last_Update_Login     => mr_rec.last_update_login,
                p_log_level_rec => g_log_level_rec
        	);
    END LOOP;
    a_tbl.delete;
    --g_total_assets := g_total_assets + g_asset_count;
    g_asset_count := 0;
    a_index := 0;
    COMMIT WORK;

    IF (mr_rec.redefault_flag = 'YES') THEN
        -- Reset g_deprn_count after completing mass reclass transaction.
        FA_LOAD_TBL_PKG.g_deprn_count := 0;
    END IF;

    /*=========================================================================
      Fetch the preview records from the interface table and print them on
      the SRS output screen for the preview report.
     =========================================================================*/
/* Commenting out, since this will be taken care of by SRS report(FASRCPVW.rdf.)
     FA_MASS_REC_UTILS_PKG.Print_RX_Report(
	X_Report_Type		=> 'PREVIEW',
	X_Mass_Reclass_Rec	=> mr_rec,
	X_Num_Assets		=> g_total_assets);
*/

    /*=========================================================================
      Update the status of the mass reclass to 'PREVIEWED'
      (This step is now handled in SRS report(FASRCPVW.rdf), which is fired
       after the RX report request.)
     =========================================================================*/
/*
    UPDATE      fa_mass_reclass
    SET         status = 'PREVIEWED'
    WHERE       mass_reclass_id = X_Mass_Reclass_Id
    AND         status = 'PREVIEW';
    COMMIT WORK;
*/
    errbuf := ''; -- No error.
    retcode := 0; -- Completed normally.

EXCEPTION
    WHEN mrcl_failure THEN
	retcode := 2;  -- Completed with error.

	-- Reset global variable values.
        FA_LOAD_TBL_PKG.g_deprn_count := 0;
	a_tbl.delete;
	a_index := 0;
	g_asset_count := 0;
	--g_total_assets := 0;
        /* A fatal error has occurred.  Update status to 'FAILED_PRE'. */
        ROLLBACK WORK;
        UPDATE fa_mass_reclass
        SET status = 'FAILED_PRE'
        WHERE mass_reclass_id = X_Mass_Reclass_Id;
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
        FA_LOAD_TBL_PKG.g_deprn_count := 0;
	a_tbl.delete;
	a_index := 0;
	g_asset_count := 0;
	--g_total_assets := 0;
        /* A fatal error has occurred.  Update status to 'FAILED_PRE'. */
        ROLLBACK WORK;
        UPDATE fa_mass_reclass
        SET status = 'FAILED_PRE'
        WHERE mass_reclass_id = X_Mass_Reclass_Id;
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
END Preview_Reclass;


/*============================================================================+
|   PROCEDURE Store_Results                                                   |
+=============================================================================*/

PROCEDURE Store_Results(
	X_Get_New_Rules		IN	VARCHAR2 := 'NO',
	X_Cat_Flex_Struct	IN	NUMBER := NULL
	) IS

    h_book_type_code	VARCHAR2(30) := NULL;
    h_cat_flex_struct	NUMBER := X_Cat_Flex_Struct;
    h_concat_cat	VARCHAR2(220);
    h_cat_segs          FA_RX_SHARED_PKG.Seg_Array;
    h_dpis		DATE;
    h_depreciate_flag	VARCHAR2(3);
    pos			NUMBER;
    h_dummy_bool1       BOOLEAN;
    h_dummy_bool2       BOOLEAN;
    h_dummy_rules1      FA_LOAD_TBL_PKG.asset_deprn_info;
    h_dummy_rules2      FA_LOAD_TBL_PKG.asset_deprn_info;
    h_dummy_date        DATE;
    h_dummy_char1	VARCHAR2(10);
    h_dummy_char2	VARCHAR2(4);
    store_failure	EXCEPTION;

    -- cursor to get all the corporate and tax books the asset belongs to.
    -- books are ordered in alphabetical order in preview report.
    CURSOR book_cr IS
        SELECT  bk.book_type_code
        FROM    fa_book_controls bc, fa_books bk
        WHERE   bk.asset_id = a_tbl(a_index).asset_id
        AND     bk.date_ineffective IS NULL
        AND     bk.book_type_code = bc.book_type_code
        AND     bc.book_class IN ('CORPORATE', 'TAX')
        AND     nvl(bc.date_ineffective, sysdate+1) > sysdate
	ORDER BY bk.book_type_code;
/*
	SELECT      TH.book_type_code
        FROM        FA_BOOK_CONTROLS BC,
                    FA_TRANSACTION_HEADERS TH
        WHERE       TH.transaction_type_code||''  IN ('ADDITION','CIP ADDITION')
        AND         TH.asset_id = a_tbl(a_index).asset_id
        AND         BC.book_type_code = TH.book_type_code
        AND         nvl(BC.date_ineffective, sysdate + 1) > sysdate
        GROUP BY    TH.book_type_code
        ORDER BY    MIN(TH.date_effective);
*/

    -- cursor to get the category flex structure.
    CURSOR get_cat_flex_struct IS
        SELECT  category_flex_structure
        FROM    fa_system_controls;

    -- cursor to get date placed in service and depreciate flag.
    CURSOR get_dpis_deprn_flag IS
	SELECT 	date_placed_in_service, depreciate_flag
	FROM 	FA_BOOKS
	WHERE	asset_id = a_tbl(a_index).asset_id
	AND	book_type_code = h_book_type_code
	AND	date_ineffective IS NULL;

    -- cursor to get the old(current) depreciation rules.
    CURSOR get_old_rules IS
	SELECT	prorate_convention_code, ceiling_name, deprn_method_code,
		life_in_months, basic_rate, adjusted_rate,
		bonus_rule, production_capacity, unit_of_measure,
		depreciate_flag, allowed_deprn_limit, allowed_deprn_limit_amount,
		percent_salvage_value
	FROM	FA_BOOKS
	WHERE	asset_id = a_tbl(a_index).asset_id
	AND	book_type_code = h_book_type_code
	AND	date_ineffective IS NULL;

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

    IF (X_Get_New_Rules = 'YES') THEN
        OPEN book_cr;
        LOOP
            FETCH book_cr INTO h_book_type_code;
            EXIT WHEN book_cr%notfound;

            /* For each book, store a preview record for an asset with
	       new depreciation rules, if redefault is allowed and if user
	       chooses to redefault the depreciation rules.  Otherwise,
	       there is no change in depreciation rules for the book. */
	    -- asset_id, asset_number, category_id fields are already assigned.
	    a_tbl(a_index).book_type_code := h_book_type_code;
	    a_tbl(a_index).category := h_concat_cat;

	    IF (mr_rec.redefault_flag = 'YES') THEN
	    -- User chooses to redefault.  Validate redefault.
	        IF FA_REC_PVT_PKG2.Validate_Redefault(
                	p_asset_id              => a_tbl(a_index).asset_id,
                	p_new_category_id       => mr_rec.to_category_id,
                	p_book_type_code        => h_book_type_code,
                	p_amortize_flag         => mr_rec.amortize_flag,
                	p_mr_req_id             => mr_rec.conc_request_id,
                	x_rule_change_exists    => h_dummy_bool1,
                	x_old_rules             => h_dummy_rules1,
                	x_new_rules             => h_dummy_rules2,
                	x_use_rules             => h_dummy_bool2,
                	x_prorate_date          => h_dummy_date,
			x_rate_source_rule	=> h_dummy_char1,
			x_deprn_basis_rule	=> h_dummy_char2,
                        p_log_level_rec         => g_log_level_rec) AND
		   Check_Trans_Date_Book(
			X_Asset_Id		=> a_tbl(a_index).asset_id,
			X_Book_Type_Code	=> h_book_type_code,
			X_Trx_Type		=> 'ADJUSTMENT')

		/* Now also check the transaction_date_entered for the asset
		   in each book in which we try to perform redefault.
		   Make sure no other transaction follows.
		   Transaction_date_entered values are validated in reclass/redefault
		   engines, as the values required for the validation are all
		   calculated in the transaction engine.  Here, we separate this
		   logic out nocopy for redefault.
		   FA_MASS_RECLASS_PKG.Check_Trans_Date(called in Preview_Reclass())
		   performs an equivalent validation for transaction_date_entered
		   for the reclass part. */
        	THEN
		-- Validation for redefault succeeded in this book.
		-- Store new rules for this book.
	    	    -- Get the date placed in service of the asset to fetch
	    	    -- the new depreciation rules.
 	    	    -- Also get depreciate flag, since we will not redefault depreciate
 	    	    -- flag through mass reclass any more.
	    	    OPEN get_dpis_deprn_flag;
	    	    FETCH get_dpis_deprn_flag INTO h_dpis, h_depreciate_flag;
	    	    CLOSE get_dpis_deprn_flag;

	    	    -- Get new depreciation rules.

	    	    -- First, get the index of the new depreciation rules record
	    	    -- from the depreciation table.
	    	    FA_LOAD_TBL_PKG.Find_Position_Deprn_Rules(
                	p_book_type_code         => h_book_type_code,
                	p_date_placed_in_service => h_dpis,
	  		x_pos			 => pos,
                        p_log_level_rec          => g_log_level_rec);
	    	    IF pos IS NULL THEN
        		FA_SRVR_MSG.Add_Message(
                		CALLING_FN => 'FARX_RP.Store_Results',
               	 		NAME => 'FA_REC_NO_CAT_DEFAULTS');
			raise store_failure;
    	    	    END IF;

	    	    a_tbl(a_index).convention
			:= FA_LOAD_TBL_PKG.deprn_table(pos).prorate_conv_code;
       	    	    a_tbl(a_index).ceiling
			:= FA_LOAD_TBL_PKG.deprn_table(pos).ceiling_name;
            	    a_tbl(a_index).method
			:= FA_LOAD_TBL_PKG.deprn_table(pos).deprn_method;
            	    a_tbl(a_index).life_in_months
			:= FA_LOAD_TBL_PKG.deprn_table(pos).life_in_months;
            	    a_tbl(a_index).basic_rate
			:= FA_LOAD_TBL_PKG.deprn_table(pos).basic_rate;
            	    a_tbl(a_index).adjusted_rate
			:= FA_LOAD_TBL_PKG.deprn_table(pos).adjusted_rate;
            	    a_tbl(a_index).bonus_rule
	   		:= FA_LOAD_TBL_PKG.deprn_table(pos).bonus_rule;
            	    a_tbl(a_index).capacity
			:= FA_LOAD_TBL_PKG.deprn_table(pos).production_capacity;
            	    a_tbl(a_index).unit_of_measure
			:= FA_LOAD_TBL_PKG.deprn_table(pos).unit_of_measure;
	    	    -- We will not redefault depreciate flag through mass reclass.
            	    a_tbl(a_index).depreciate_flag := h_depreciate_flag;
            	    a_tbl(a_index).allowed_deprn_limit
			:= FA_LOAD_TBL_PKG.deprn_table(pos).allow_deprn_limit;
            	    a_tbl(a_index).deprn_limit_amt
			:= FA_LOAD_TBL_PKG.deprn_table(pos).deprn_limit_amount;
            	    a_tbl(a_index).percent_salvage_val
			:= FA_LOAD_TBL_PKG.deprn_table(pos).percent_salvage_value;

	       	    -- Convert values using conversion_table, which caches
	    	    -- converted values of certain fields for the new rules.
	    	    -- (The corresponding converted record is stored in the
	    	    --  same index position in conv_tbl as that of deprn_table.)
	    	    a_tbl(a_index).life	:= FA_MASS_REC_UTILS_PKG.conv_tbl(pos).life;
	    	    a_tbl(a_index).basic_rate_pct
			:= FA_MASS_REC_UTILS_PKG.conv_tbl(pos).basic_rate_pct;
	    	    a_tbl(a_index).adjusted_rate_pct
			:= FA_MASS_REC_UTILS_PKG.conv_tbl(pos).adjusted_rate_pct;
	    	    a_tbl(a_index).deprn_limit_pct
			:= FA_MASS_REC_UTILS_PKG.conv_tbl(pos).deprn_limit_pct;
	    	    a_tbl(a_index).salvage_val_pct
			:= FA_MASS_REC_UTILS_PKG.conv_tbl(pos).salvage_val_pct;
	    	ELSE /* IF FA_REC_PVT_PKG2.Validate_Redefault */
		-- Validation for redefault failed in this book.
		-- Store old results for this book.
	            -- Get the old(current) depreciation rules.
            	    OPEN get_old_rules;
            	    FETCH get_old_rules
            	    INTO a_tbl(a_index).convention, a_tbl(a_index).ceiling,
                 	 a_tbl(a_index).method,
                 	 a_tbl(a_index).life_in_months, a_tbl(a_index).basic_rate,
                 	 a_tbl(a_index).adjusted_rate,
                 	 a_tbl(a_index).bonus_rule, a_tbl(a_index).capacity,
                 	 a_tbl(a_index).unit_of_measure,
                 	 a_tbl(a_index).depreciate_flag,
			 a_tbl(a_index).allowed_deprn_limit,
                 	 a_tbl(a_index).deprn_limit_amt,
                 	 a_tbl(a_index).percent_salvage_val;
            	    CLOSE get_old_rules;

	    	    -- Convert formats for certain fields.
 	    	    FA_MASS_REC_UTILS_PKG.Convert_Formats(
        		X_Life_In_Months => a_tbl(a_index).life_in_months,
        		X_Basic_Rate 	 => a_tbl(a_index).basic_rate,
        		X_Adjusted_Rate  => a_tbl(a_index).adjusted_rate,
        		X_Allowed_Deprn_Limit => a_tbl(a_index).allowed_deprn_limit,
       	 		X_Percent_Salvage_Val => a_tbl(a_index).percent_salvage_val,
        		X_Life           => a_tbl(a_index).life,
        		X_Basic_Rate_Pct => a_tbl(a_index).basic_rate_pct,
        		X_Adjusted_Rate_Pct   => a_tbl(a_index).adjusted_rate_pct,
        		X_Deprn_Limit_Pct     => a_tbl(a_index).deprn_limit_pct,
        		X_Salvage_Val_Pct     => a_tbl(a_index).salvage_val_pct,
                        p_log_level_rec => g_log_level_rec
        		);
		END IF; /* IF FA_REC_PVT_PKG2.Validate_Redefault */
	    ELSE /* IF (mr_rec.redefault_flag = 'YES') */
	    -- User chooses not to redefault.
	    -- Store old results.
	    	-- Get the old(current) depreciation rules.
            	OPEN get_old_rules;
            	FETCH get_old_rules
            	INTO a_tbl(a_index).convention, a_tbl(a_index).ceiling,
              	     a_tbl(a_index).method,
                     a_tbl(a_index).life_in_months, a_tbl(a_index).basic_rate,
                     a_tbl(a_index).adjusted_rate,
                     a_tbl(a_index).bonus_rule, a_tbl(a_index).capacity,
                     a_tbl(a_index).unit_of_measure,
                     a_tbl(a_index).depreciate_flag,
		     a_tbl(a_index).allowed_deprn_limit,
                     a_tbl(a_index).deprn_limit_amt,
                     a_tbl(a_index).percent_salvage_val;
            	CLOSE get_old_rules;

	        -- Convert formats for certain fields.
 	        FA_MASS_REC_UTILS_PKG.Convert_Formats(
        		X_Life_In_Months => a_tbl(a_index).life_in_months,
        		X_Basic_Rate 	 => a_tbl(a_index).basic_rate,
        		X_Adjusted_Rate  => a_tbl(a_index).adjusted_rate,
        		X_Allowed_Deprn_Limit => a_tbl(a_index).allowed_deprn_limit,
       	 		X_Percent_Salvage_Val => a_tbl(a_index).percent_salvage_val,
        		X_Life           => a_tbl(a_index).life,
        		X_Basic_Rate_Pct => a_tbl(a_index).basic_rate_pct,
        		X_Adjusted_Rate_Pct   => a_tbl(a_index).adjusted_rate_pct,
        		X_Deprn_Limit_Pct     => a_tbl(a_index).deprn_limit_pct,
        		X_Salvage_Val_Pct     => a_tbl(a_index).salvage_val_pct,
                        p_log_level_rec => g_log_level_rec
        		);
	    END IF; /* IF (mr_rec.redefault_flag = 'YES') */

	    -- The following values are used in review reports only.
            a_tbl(a_index).cost_acct_ccid := NULL;
            a_tbl(a_index).cost_acct := NULL;
            a_tbl(a_index).deprn_rsv_acct_ccid := NULL;
            a_tbl(a_index).deprn_rsv_acct := NULL;

	    -- Propagate asset_id, asset_number, category_id to the next
	    -- book record for the asset.
	    a_tbl(a_index + 1).asset_id := a_tbl(a_index).asset_id;
	    a_tbl(a_index + 1).asset_number := a_tbl(a_index).asset_number;
	    a_tbl(a_index + 1).description := a_tbl(a_index).description;
	    a_tbl(a_index + 1).category_id := a_tbl(a_index).category_id;

	    -- Increment the index position for the next book to be stored.
	    a_index := a_index + 1;

    	END LOOP;

	-- Decrement a_index by 1 to cancel the extra index movement made
	-- at the last book entry.
	a_index := a_index - 1;

    	CLOSE book_cr;
    ELSE /* X_Get_New_Rules = 'NO' */
	OPEN book_cr;
        LOOP
            FETCH book_cr INTO h_book_type_code;
            EXIT WHEN book_cr%notfound;

            /* For each book, store a preview record for an asset in the
	       asset table.  Depreciation rules remain unchanged for
	       the asset. */
	    -- asset_id, asset_number, category_id fields are already assigned.
	    a_tbl(a_index).book_type_code := h_book_type_code;
	    a_tbl(a_index).category := h_concat_cat;

	    -- Get the old(current) depreciation rules.
	    OPEN get_old_rules;
	    FETCH get_old_rules
	    INTO a_tbl(a_index).convention, a_tbl(a_index).ceiling,
		 a_tbl(a_index).method,
		 a_tbl(a_index).life_in_months, a_tbl(a_index).basic_rate,
		 a_tbl(a_index).adjusted_rate,
		 a_tbl(a_index).bonus_rule, a_tbl(a_index).capacity,
		 a_tbl(a_index).unit_of_measure,
		 a_tbl(a_index).depreciate_flag, a_tbl(a_index).allowed_deprn_limit,
		 a_tbl(a_index).deprn_limit_amt,
		 a_tbl(a_index).percent_salvage_val;
	    CLOSE get_old_rules;

	    -- The following values are used in review reports only.
            a_tbl(a_index).cost_acct_ccid := NULL;
            a_tbl(a_index).cost_acct := NULL;
            a_tbl(a_index).deprn_rsv_acct_ccid := NULL;
            a_tbl(a_index).deprn_rsv_acct := NULL;

	    -- Convert formats for certain fields.
 	    FA_MASS_REC_UTILS_PKG.Convert_Formats(
        	X_Life_In_Months => a_tbl(a_index).life_in_months,
        	X_Basic_Rate 	 => a_tbl(a_index).basic_rate,
        	X_Adjusted_Rate  => a_tbl(a_index).adjusted_rate,
        	X_Allowed_Deprn_Limit => a_tbl(a_index).allowed_deprn_limit,
       	 	X_Percent_Salvage_Val => a_tbl(a_index).percent_salvage_val,
        	X_Life           => a_tbl(a_index).life,
        	X_Basic_Rate_Pct => a_tbl(a_index).basic_rate_pct,
        	X_Adjusted_Rate_Pct   => a_tbl(a_index).adjusted_rate_pct,
        	X_Deprn_Limit_Pct     => a_tbl(a_index).deprn_limit_pct,
        	X_Salvage_Val_Pct     => a_tbl(a_index).salvage_val_pct,
                p_log_level_rec => g_log_level_rec
        	);

	    -- Propagate asset_id, asset_number, category_id to the next
	    -- book record for the asset.
	    a_tbl(a_index + 1).asset_id := a_tbl(a_index).asset_id;
	    a_tbl(a_index + 1).asset_number := a_tbl(a_index).asset_number;
	    a_tbl(a_index + 1).description := a_tbl(a_index).description;
	    a_tbl(a_index + 1).category_id := a_tbl(a_index).category_id;

	    -- Increment the index position for the next book to be stored.
	    a_index := a_index + 1;

    	END LOOP;

	-- Decrement a_index by 1 to cancel the extra index movement made
	-- at the last book entry.
	a_index := a_index - 1;

    	CLOSE book_cr;
    END IF; /* IF (X_Get_New_Rules = 'YES') */

EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FARX_RP.Store_Results');
        raise;
END Store_Results;


/*============================================================================+
|   FUNCTIONE Check_Trans_Date_Book                                           |
+=============================================================================*/

FUNCTION Check_Trans_Date_Book(
	X_Asset_Id		IN	NUMBER,
	X_Book_Type_Code	IN	VARCHAR2,
	X_Trx_Type		IN	VARCHAR2
	) RETURN BOOLEAN IS
	h_current_period_flag	VARCHAR2(3) := 'N';
	h_trans_date		DATE;
	h_dpis			DATE;
        -- Cursor to check whether the asset was added in the current open period.
        CURSOR added_this_period IS
            SELECT 'Y'
            FROM FA_DEPRN_PERIODS dp,
                 FA_TRANSACTION_HEADERS th
            WHERE th.book_type_code = X_Book_Type_Code
            AND th.asset_id = X_Asset_Id
            AND th.transaction_type_code||'' in ('ADDITION', 'CIP ADDITION')
            AND dp.book_type_code = X_Book_Type_Code
            AND dp.period_open_date <= th.date_effective
            AND nvl(dp.period_close_date, sysdate) > th.date_effective
            AND dp.period_close_date IS NULL
	    AND th.transaction_date_entered >= dp.calendar_period_open_date;
	-- Cursor to get transaction date entered.
    	CURSOR get_trx_date_entered IS
            SELECT greatest(dp.calendar_period_open_date,
                   least(trunc(sysdate), dp.calendar_period_close_date))
            FROM   FA_DEPRN_PERIODS dp
            WHERE  dp.book_type_code = X_Book_Type_Code
            AND    dp.period_close_date is null;
	-- Cursor to get date placed in service.
	CURSOR get_dpis IS
	    SELECT date_placed_in_service
	    FROM   FA_BOOKS bk
	    WHERE  bk.asset_id = X_Asset_Id
	    AND    bk.book_type_code = X_Book_Type_Code
	    AND    date_ineffective IS NULL;
BEGIN
    /* Get transaction_date_entered. */
    /* Adjustment calculates transaction_date_entered slightly differently from
       other transaction engines.  If the asset is added in the current period,
       transaction_date_entered defaults to date placed in service. */
    IF (X_Trx_Type = 'ADJUSTMENT') THEN
        -- Check if the asset is added in the current period or not.
    	OPEN added_this_period;
    	FETCH added_this_period INTO h_current_period_flag;
    	CLOSE added_this_period;

    	-- Get transaction_date_entered.
    	IF (h_current_period_flag = 'Y') THEN
    	-- Added in the current period.
	    OPEN get_dpis;
	    FETCH get_dpis INTO h_dpis;
	    CLOSE get_dpis;
            h_trans_date := h_dpis;
        ELSE
    	    OPEN get_trx_date_entered;
    	    FETCH get_trx_date_entered INTO h_trans_date;
   	    CLOSE get_trx_date_entered;
        END IF;
    ELSE /* IF (X_Trx_Type = 'ADJUSTMENT') */
        OPEN get_trx_date_entered;
        FETCH get_trx_date_entered INTO h_trans_date;
        CLOSE get_trx_date_entered;
    END IF;

    -- Check if any other transaction exists between the transaction date
    -- entered and the current date.
    IF NOT FA_REC_PVT_PKG1.Check_Trans_Date(
                p_asset_id              => X_Asset_Id,
                p_book_type_code        => X_Book_Type_Code,
                p_trans_date            => h_trans_date,
                p_log_level_rec         => g_log_level_rec)
    THEN
        FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FARX_RP.Check_Trans_Date_Book');
        RETURN (FALSE);
    END IF;

    RETURN (TRUE);

EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  'FARX_RP.Check_Trans_Date_Book');
    	RETURN (FALSE);
END Check_Trans_Date_Book;


END FARX_RP;

/
