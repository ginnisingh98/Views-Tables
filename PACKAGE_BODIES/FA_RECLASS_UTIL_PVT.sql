--------------------------------------------------------
--  DDL for Package Body FA_RECLASS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RECLASS_UTIL_PVT" AS
/* $Header: FAVRCUTB.pls 120.15.12010000.3 2009/12/10 11:25:22 snandiko ship $   */


/* Global Variables */
g_release       number  := fa_cache_pkg.fazarel_release; -- Bug 8660186

------------------------------------------------------------------
FUNCTION validate_CIP_accounts(
         p_transaction_type_code  IN  VARCHAR2,
         p_book_type_code         IN  VARCHAR2,
         p_asset_type             IN  VARCHAR2,
         p_category_id            IN  VARCHAR2,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

    v_count number;
    l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.validate_cip_accts';

BEGIN
  if p_asset_type = 'CIP' then
     select count(1)
     into v_count
     from fa_category_books
     where category_id = p_category_id
     and book_type_code = p_book_type_code
     and cip_cost_acct is not null
     and cip_clearing_acct is not null
     and rownum < 2;

     if v_count = 0 then
          fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn,
                      name       => 'FA_SHARED_NO_CIP_ACCOUNTS', p_log_level_rec => p_log_level_rec);
	         return FALSE;
     end if;
  end if;

  return TRUE;

EXCEPTION
  WHEN OTHERS THEN
     FA_SRVR_MSG.ADD_SQL_ERROR(
                 CALLING_FN => l_calling_fn , p_log_level_rec => p_log_level_rec);
     RETURN (FALSE);
END validate_CIP_accounts;

-- -------------------------------------------------------
-- check to see if category is setup for the book
--
-- ------------------------------------------------------
FUNCTION check_cat_book_setup(
         p_transaction_type_code  IN  VARCHAR2,
         p_new_category_id        IN  NUMBER,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

    l_count1 number;
    l_count2 number;
    l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.check_cat_book_setup';
  BEGIN

   -- Make sure the new category is defined in all the books the asset belongs to.
    -- Get the number of books in which the new category is defined for the asset.
    SELECT count(*) INTO l_count1
    FROM FA_CATEGORY_BOOKS cb, FA_BOOKS bk, fa_book_controls bc
    WHERE bk.asset_id = p_asset_id
    AND bk.date_ineffective IS NULL
    AND bk.book_type_code = cb.book_type_code
    AND cb.category_id = p_new_category_id
    AND bc.book_type_code = bk.book_type_code
    AND nvl(bc.date_ineffective,sysdate) >= sysdate;

    -- Get the total number of books the asset belongs to.
    SELECT count(*) INTO l_count2
    FROM FA_BOOKS bk, FA_BOOK_CONTROLS bc
    WHERE bk.asset_id = p_asset_id
    AND bk.date_ineffective IS NULL
    AND bk.book_type_code = bc.book_type_code
    AND nvl(bc.date_ineffective,sysdate) >= sysdate;


    IF (l_count1 <> l_count2) THEN
        FA_SRVR_MSG.Add_Message(
                    CALLING_FN => l_calling_fn,
                    NAME       => 'FA_REC_CAT_BOOK_NOT_SETUP', p_log_level_rec => p_log_level_rec);
                    /* Message text:
                       'The new category is not defined in at least one of
                       the depreciation books the asset belongs to.' */
        RETURN (FALSE);
    END IF;

  return TRUE;
EXCEPTION
  WHEN OTHERS THEN
     FA_SRVR_MSG.ADD_SQL_ERROR(
                 CALLING_FN => l_calling_fn , p_log_level_rec => p_log_level_rec);
     RETURN (FALSE);
END check_cat_book_setup;

-------------------------------------------------------
FUNCTION validate_cat_types(
         p_transaction_type_code  IN  VARCHAR2,
         p_old_cat_id             IN  NUMBER,
         p_new_cat_id             IN  NUMBER,
         p_lease_id               IN  NUMBER,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS
    v_new_cap_flag varchar2(3);
    v_new_cat_type varchar2(30);

    v_old_cap_flag varchar2(3);
    v_old_cat_type varchar2(30);

    v_count number;
    l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.validate_cat_types';
  BEGIN
     -- both categories must be capitalized or expensed types
    --old values
    select capitalize_flag, category_type
    into v_old_cap_flag, v_old_cat_type
    from fa_categories
    where category_id = p_old_cat_id;

    -- new values
    select capitalize_flag, category_type
    into v_new_cap_flag, v_new_cat_type
    from fa_categories
    where category_id = p_new_cat_id;
    --
    if v_old_cap_flag = 'YES' then
       if v_new_cap_flag = 'NO' then
          fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn,
                      name       => 'FA_ADD_RECLS_TO_EXPENSE', p_log_level_rec => p_log_level_rec);
          return FALSE;
       end if;
    elsif v_old_cap_flag = 'NO' then
       if v_new_cap_flag = 'YES' then
           fa_srvr_msg.add_message(
                       calling_fn => l_calling_fn,
                       name       => 'FA_ADD_RECLS_TO_CAP_ASSET', p_log_level_rec => p_log_level_rec);
           return FALSE;
       end if;
    end if;

    -- validate lease
    if v_old_cat_type = 'LEASE' and v_new_cat_type <> 'LEASE' then
       if p_lease_id is not null then -- fix for bug 3507682
       v_count := 0;
   -- using count(*) instead of 1 as it throwing no data found. Fix for 8974754
       select count(*) into v_count
       from dual
       where exists ( select 'x'
                      from fa_additions a,
                           fa_categories b
                      where a.asset_id = p_asset_id
                      and a.lease_id = p_Lease_Id
                      and a.asset_category_id = b.category_id
     	                and b.category_type = 'LEASEHOLD IMPROVEMENT');

       --
       if v_count > 0 then
         fa_srvr_msg.add_message(
                     calling_fn => l_calling_fn,
                     name       => 'FA_ADD_DELETE_LHOLD_BEFORE_RCL', p_log_level_rec => p_log_level_rec);
         return FALSE;
       end if;

       --
       v_count:= 0;
       -- using count(*) instead of 1 as it throwing no data found. Fix for 8974754
       select count(*) into v_count
       from dual
       where exists ( select 'x'
                      from fa_leases
                      where lease_id = p_lease_id );
       --
       if v_count > 0 then
         fa_srvr_msg.add_message(
                     calling_fn => l_calling_fn,
                     name       => 'FA_ADD_DELETE_LEASE_BEFORE_RCL', p_log_level_rec => p_log_level_rec);
         return FALSE;
       end if;
     end if;
    end if; -- fix for bug 3507682
  return TRUE;

EXCEPTION
  WHEN OTHERS THEN
     FA_SRVR_MSG.ADD_SQL_ERROR(
                 CALLING_FN => l_calling_fn , p_log_level_rec => p_log_level_rec);
     RETURN FALSE;
END validate_cat_types;

------------------------------------------------------

FUNCTION validate_units(
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS
   v_ah_units number;
   v_dh_units number;

   CURSOR get_ah_units IS
	    SELECT units FROM FA_ASSET_HISTORY
	    WHERE asset_id = p_asset_id
	    AND date_ineffective IS NULL;

	CURSOR get_dh_units IS
	    SELECT sum(units_assigned) FROM FA_DISTRIBUTION_HISTORY
	    WHERE asset_id = p_asset_id
	    AND date_ineffective is NULL;
   l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.validate_units';
BEGIN

   --  Units in asset history and
   -- distribution history must match.
   OPEN get_ah_units;
   FETCH get_ah_units INTO v_ah_units;
   CLOSE get_ah_units;

   OPEN get_dh_units;
   FETCH get_dh_units INTO v_dh_units;
   CLOSE get_dh_units;

   IF (v_ah_units <> v_dh_units) THEN
	        FA_SRVR_MSG.Add_Message(
        	             CALLING_FN  =>  l_calling_fn,
                      NAME        =>  'FA_SHARED_UNITS_UNBAL', p_log_level_rec => p_log_level_rec);
	    RETURN FALSE;
   END IF;

   return TRUE;

EXCEPTION
  WHEN OTHERS THEN
     FA_SRVR_MSG.ADD_SQL_ERROR(
                 CALLING_FN => l_calling_fn , p_log_level_rec => p_log_level_rec);
     RETURN FALSE;

END validate_units;

------------------------------------------------------
FUNCTION validate_pending_retire(
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

  v_count number:= 0;
  l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.validate_pending_ret';
BEGIN

  --  no pending retirements
  	select count(1)
  	into v_count
  	from fa_retirements
  	where asset_id = p_Asset_Id
  	and status in ('PENDING', 'REINSTATE', 'PARTIAL')
	and rownum < 2;
  	--
  	if v_count > 0 then
              fa_srvr_msg.add_message(
              calling_fn => l_calling_fn,
              name       => 'FA_RET_PENDING_RETIREMENTS', p_log_level_rec => p_log_level_rec);
            return FALSE;
  	end if;

  return TRUE;

EXCEPTION
  WHEN OTHERS THEN
     FA_SRVR_MSG.ADD_SQL_ERROR(
                 CALLING_FN => l_calling_fn , p_log_level_rec => p_log_level_rec);
     RETURN FALSE;

END validate_pending_retire;

-----------------------------------------------------
FUNCTION validate_fully_retired(
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

  v_count	NUMBER := 0;
  l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.validate_fully_ret';

  BEGIN
      SELECT count(1)
      INTO v_count
      FROM FA_BOOKS   BK,
           FA_BOOK_CONTROLS BC
      WHERE BK.ASSET_ID = p_asset_id AND
            BK.PERIOD_COUNTER_FULLY_RETIRED IS NOT NULL AND
            BK.DATE_INEFFECTIVE IS NULL AND
            BK.BOOK_TYPE_CODE = BC.BOOK_TYPE_CODE AND
            BC.DATE_INEFFECTIVE IS NULL AND
            rownum < 2;

      if v_count = 1 then
          FA_SRVR_MSG.add_message(
                      CALLING_FN => l_calling_fn,
                      NAME       => 'FA_REC_RETIRED', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      return TRUE;
EXCEPTION
  WHEN OTHERS THEN
     FA_SRVR_MSG.ADD_SQL_ERROR(
                 CALLING_FN => l_calling_fn , p_log_level_rec => p_log_level_rec);
     RETURN FALSE;

END validate_fully_retired;

--------------------------------------------------------------
FUNCTION validate_prior_per_add (
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
         p_book                   IN  VARCHAR2,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS


  v_is_prior_period  NUMBER :=0;
  l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.val_prior_per_add';

  BEGIN

        /**** donot know whether I need this

        h_mesg_name := 'FA_REC_SQL_PRIOR_PER';

        select count(1)
        into v_is_prior_period
	    FA_DEPRN_PERIODS DP_NOW,
	    FA_DEPRN_PERIODS DP,
	    FA_BOOK_CONTROLS BC,
            FA_TRANSACTION_HEADERS TH
        WHERE
            TH.ASSET_ID = p_asset_id AND
            TH.TRANSACTION_TYPE_CODE = DECODE(BC.BOOK_CLASS,'CORPORATE',
                                              'TRANSFER IN','ADDITION') AND
            TH.BOOK_TYPE_CODE = BC.BOOK_TYPE_CODE AND
            BC.BOOK_TYPE_CODE = nvl( p_book,BC.BOOK_TYPE_CODE ) AND
            TH.DATE_EFFECTIVE BETWEEN
                DP.PERIOD_OPEN_DATE AND
                NVL(DP.PERIOD_CLOSE_DATE, SYSDATE)
        AND
            DP.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE AND
            DP.PERIOD_COUNTER < DP_NOW.PERIOD_COUNTER AND
            DP_NOW.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE AND
            DP_NOW.PERIOD_CLOSE_DATE IS NULL );


        if v_is_prior_period = 1 then
           X_is_prior_period := TRUE ;
        else
           X_is_prior_period := FALSE;
        end if;

        RETURN (TRUE);

    EXCEPTION
	   WHEN NO_DATA_FOUND THEN
            X_is_prior_period := FALSE;
            RETURN (TRUE);

     WHEN OTHERS THEN
	      FA_SRVR_MSG.ADD_SQL_ERROR (
	      		CALLING_FN => l_calling_fn, p_log_level_rec => p_log_level_rec);

            RETURN (FALSE);
    **/
    return TRUE;
END validate_prior_per_add;

---------------------------------------------------------------
FUNCTION validate_transaction_date(
         p_trans_rec       IN     FA_API_TYPES.trans_rec_type,
         p_asset_id        IN     NUMBER,
         p_book            IN     VARCHAR2,
         p_calling_fn      IN     VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

	l_prior_trans_date	DATE;
	l_prior_date_effective	DATE;
	l_check_another_trans	NUMBER := 0;

   l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.validate_trx_date';

	CURSOR get_prior_trans_date IS
	    SELECT 	max(transaction_date_entered)
            FROM 	FA_TRANSACTION_HEADERS
            WHERE 	asset_id = p_asset_id
            AND 	book_type_code = p_book
            AND         transaction_type_code not like '%/VOID';

	CURSOR get_prior_date_effective IS
	    SELECT 	max(date_effective)
            FROM 	FA_TRANSACTION_HEADERS
            WHERE 	asset_id = p_asset_id
            AND 	book_type_code = p_book;
BEGIN
    /*  Logic from FA_BOOKS_VAL5.Amortization_Start_Date from FAXASSET. */
    -- Check another transaction between transaction date and current period.
    OPEN get_prior_trans_date;
    FETCH get_prior_trans_date INTO l_prior_trans_date;
    CLOSE get_prior_trans_date;

    IF (p_trans_rec.transaction_date_entered < l_prior_trans_date) THEN
        FA_SRVR_MSG.Add_Message(
            CALLING_FN => l_calling_fn,
            NAME => 'FA_SHARED_OTHER_TRX_FOLLOW', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
    END IF;

    OPEN get_prior_date_effective;
    FETCH get_prior_date_effective INTO l_prior_date_effective;
    CLOSE get_prior_date_effective;

    SELECT count(1) INTO l_check_another_trans
    FROM FA_DEPRN_PERIODS pdp, FA_DEPRN_PERIODS adp
    WHERE pdp.book_type_code = p_book
    AND pdp.book_type_code = adp.book_type_code
    AND pdp.period_counter > adp.period_counter
    AND l_prior_date_effective between pdp.period_open_date
            and nvl(pdp.period_close_date, to_date('31-12-4712','DD-MM-YYYY'))
    AND p_trans_rec.transaction_date_entered between
            adp.calendar_period_open_date and adp.calendar_period_close_date;

    IF (l_check_another_trans > 0) THEN
        FA_SRVR_MSG.Add_Message(
            CALLING_FN => l_calling_fn,
            NAME => 'FA_SHARED_OTHER_TRX_FOLLOW', p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
    END IF;

    RETURN (TRUE);

EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN =>  l_calling_fn, p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END validate_transaction_date;


---------------------------------------------------------
FUNCTION Validate_Adjustment(
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
         p_book_type_code         IN  VARCHAR2,
         p_amortize_flag          IN  VARCHAR2,
         p_mr_req_id              IN  NUMBER := -1 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

	check_flag		VARCHAR2(3);
	prior_transaction_date	DATE;
	prior_date_effective    DATE;
	check_another_trans     NUMBER;
        l_period_of_addition    varchar2(1);

   l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.validate_adjustment';

	CURSOR check_mass_change_allowed IS
	    SELECT 'x' FROM FA_BOOK_CONTROLS
	    WHERE book_type_code = p_book_type_code AND allow_mass_changes = 'NO'
	    AND p_mr_req_id <> -1;
	CURSOR check_prior_amort IS
	    SELECT 'x' FROM FA_BOOKS
	    WHERE book_type_code = p_book_type_code AND asset_id = p_asset_id
	    AND rate_adjustment_factor <> 1;
	CURSOR check_cip IS
	    SELECT 'x' FROM FA_ADDITIONS
	    WHERE asset_id = p_asset_id AND asset_type = 'CIP';
	CURSOR check_amort_allowed IS
	    SELECT 'x' FROM FA_BOOK_CONTROLS
	    WHERE book_type_code = p_book_type_code AND amortize_flag = 'NO';
	CURSOR check_deprn IS
	    SELECT 'x' FROM FA_DEPRN_SUMMARY
	    WHERE book_type_code = p_book_type_code
            AND asset_id = p_asset_id
	    AND deprn_source_code = 'DEPRN';
BEGIN
    -- Check if mass change(adjustment) is allowed.
    OPEN check_mass_change_allowed;
    FETCH check_mass_change_allowed INTO check_flag;
    IF (check_mass_change_allowed%found) THEN
	   CLOSE check_mass_change_allowed;
	   FA_SRVR_MSG.Add_Message( CALLING_FN => l_calling_fn,
		                         NAME => 'FA_REC_MASSCHG_NOT_ALLOWED', p_log_level_rec => p_log_level_rec);
		    /* Message text:
		   'You cannot use mass transaction to redefault depreciation rules
		    for the asset in this book because Allow Mass Changes field in the
		    Book Controls form is set to No. */
	   RETURN (FALSE);
    END IF;
    CLOSE check_mass_change_allowed;


    ---- Checks for Expensed Adjustment ----

    -- Check if there were prior amortized adjustments, in case of expensed
    -- adjustment.
    IF (p_amortize_flag = 'NO') THEN
    	  OPEN check_prior_amort;
	     FETCH check_prior_amort INTO check_flag;
	     IF (check_prior_amort%found) THEN
	       CLOSE check_prior_amort;
	       FA_SRVR_MSG.Add_Message( CALLING_FN => l_calling_fn,
                                   NAME => 'FA_BOOK_CANT_EXP_AFTER_AMORT', p_log_level_rec => p_log_level_rec);
	       RETURN (FALSE);
       	     END IF;
	     CLOSE check_prior_amort;

      ---- Checks for Amortized Adjustment ----

    ELSE
      -- Check if an asset is a CIP asset.  CIP assets cannot be amortized.
      --   Rule from fa_fin_adj3_pkg.transaction_type().
   	  OPEN check_cip;
          FETCH check_cip INTO check_flag;
	  IF (check_cip%found) THEN
	     CLOSE check_cip;
	     FA_SRVR_MSG.Add_Message( CALLING_FN => l_calling_fn,
		                           NAME => 'FA_REC_CIP_CANNOT_AMORT', p_log_level_rec => p_log_level_rec);
		  -- Message text:
		  -- 'You cannot amortize an adjustment for a CIP asset.'
	     RETURN (FALSE);
          END IF;
	  CLOSE check_cip;

	   -- Check if amortization is allowed in this book.
	   OPEN check_amort_allowed;
	   FETCH check_amort_allowed INTO check_flag;
	   IF (check_amort_allowed%found) THEN
	       CLOSE check_amort_allowed;
	       FA_SRVR_MSG.Add_Message( CALLING_FN => l_calling_fn,
		                             NAME => 'FA_BOOK_AMORTIZED_NOT_ALLOW', p_log_level_rec => p_log_level_rec);
	       RETURN (FALSE);
           END IF;
	   CLOSE check_amort_allowed;

/*

	   -- Check if the asset has already been depreciated.
	   OPEN check_deprn;
	   FETCH check_deprn INTO check_flag;
	   IF (check_deprn%notfound) THEN
	       CLOSE check_deprn;

               -- if in period of addition, check if previously amortized
               OPEN check_prior_amort;
               FETCH check_prior_amort INTO check_flag;
               IF (check_prior_amort%notfound) THEN
                   CLOSE check_prior_amort;
	           FA_SRVR_MSG.Add_Message( CALLING_FN => l_calling_fn,
	                                    NAME => 'FA_BOOK_CANT_AMORT_BEF_DEPRN', p_log_level_rec => p_log_level_rec);
	           RETURN (FALSE);
               ELSE
                   CLOSE check_prior_amort;
               END IF;
           ELSE
               CLOSE check_deprn;
           END IF;
*/

    -- END IF; /* commented for bug 3844678 */

    -- BUG# 3354951
    -- replacing the above with call to common validation routine
    if not fa_asset_val_pvt.validate_period_of_addition
            (p_asset_id            => p_asset_id,
             p_book                => p_book_type_code,
             p_mode                => 'ABSOLUTE',
             px_period_of_addition => l_period_of_addition, p_log_level_rec => p_log_level_rec) then
        FA_SRVR_MSG.Add_Message( CALLING_FN => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return FALSE;
    -- Bug 8660186 : No need of validation in R12
    elsif ( (l_period_of_addition = 'Y') and (g_release = 11)) then
        FA_SRVR_MSG.Add_Message(CALLING_FN => l_calling_fn,
                                NAME => 'FA_BOOK_CANT_AMORT_BEF_DEPRN', p_log_level_rec => p_log_level_rec);
        return false;
    end if;

   END IF; /* added for bug 3844678 */

    RETURN (TRUE);
EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error( CALLING_FN =>  l_calling_fn, p_log_level_rec => p_log_level_rec);
        RETURN (FALSE);
END Validate_Adjustment;


-------------------------------------------------------------
FUNCTION get_new_ccid(
         p_trans_rec          IN      FA_API_TYPES.trans_rec_type,
         p_asset_hdr_rec      IN      FA_API_TYPES.asset_hdr_rec_type,
         p_asset_cat_rec_new  IN      FA_API_TYPES.asset_cat_rec_type,
         p_dist_rec_old       IN      FA_API_TYPES.asset_dist_rec_type,
         px_dist_rec_new      IN OUT NOCOPY  FA_API_TYPES.asset_dist_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

   h_mesg_name 		VARCHAR2(30);
   h_new_deprn_exp_acct 	VARCHAR2(26);
   --  h_new_ccid 		NUMBER(15) := 0;
	fardodh_done		EXCEPTION;
	fardodh_error		EXCEPTION;
	h_cost_acct_ccid	NUMBER	   :=0;

	h_chart_of_accounts_id 	   GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
	h_flex_segment_delimiter 	varchar2(5);
	h_flex_segment_number		number;
	h_num_of_segments 		NUMBER;
	h_concat_array_segments	FND_FLEX_EXT.SEGMENTARRAY;

   h_appl_short_name  varchar2(30);
   h_message_name     varchar2(30);
   h_num              number := 0;
   h_errmsg           varchar2(512);
   h_concat_segs      varchar2(2000) := '';
   h_delimiter        varchar2(1);

   l_err_stage varchar2(250);
   l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.get_new_ccid';

   BEGIN

      l_err_stage := 'Get the new category DEPRN_EXPENSE_ACCT';
      -- dbms_output.put_line(l_err_stage);
      SELECT deprn_expense_acct,asset_cost_account_ccid
      INTO h_new_deprn_exp_acct,h_cost_acct_ccid
      FROM fa_category_books
      WHERE book_type_code = p_asset_hdr_rec.book_type_code
      AND category_id = p_asset_cat_rec_new.category_id;


      l_err_stage:= 'Get Chart of Accounts ID';
      -- dbms_output.put_line(l_err_stage);
	   Select  sob.chart_of_accounts_id
	   into    h_chart_of_accounts_id
	   From    fa_book_controls bc,
         	 gl_sets_of_books sob
	   Where   sob.set_of_books_id = bc.set_of_books_id
	   And 	  bc.book_type_code  = p_asset_hdr_rec.book_type_code;

      -- dbms_output.put_line('h_chart_of_accounts_id '||to_char(h_chart_of_accounts_id));

      l_err_stage:= 'Get Account Qualifier Segment Number';
      -- dbms_output.put_line(l_err_stage);
      -- h_message_name := 'FND_FLEX_EXT.GET_QUALIFIER_SEGNUM';
	   IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                h_chart_of_accounts_id,
                                'GL_ACCOUNT',
                                h_flex_segment_number)) THEN
                RAISE fardodh_error;
	   END IF;

      l_err_stage:= 'Retrieve distribution segments';
      -- dbms_output.put_line(l_err_stage);
      -- h_message_name := 'FND_FLEX_EXT.GET_SEGMENTS';
	   IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL',
				    'GL#',
				    h_chart_of_accounts_id,
				    p_dist_rec_old.expense_ccid, --h_old_ccid,
				    h_num_of_segments,
				    h_concat_array_segments)) THEN

                RAISE fardodh_error;
	   END IF;
      -- -- dbms_output.put_line('old_expense_ccid '||to_char(p_dist_rec_old.expense_ccid));
      -- -- dbms_output.put_line('h_new_deprn_exp_acct'||h_new_deprn_exp_acct);
      -- -- dbms_output.put_line('h_flex_number'||to_char(h_flex_segment_number));

   -- Updating array with new account value
        h_concat_array_segments(h_flex_segment_number) := h_new_deprn_exp_acct;

   l_err_stage:=  'Retrieve new ccid with overlaid account';
   --  get_combination_id function generates new ccid if rules allows.
   --  h_message_name := 'FND_FLEX_EXT.GET_COMBINATION_ID';
   -- dbms_output.put_line(l_err_stage);
	   IF (NOT FND_FLEX_EXT.GET_COMBINATION_ID(
				'SQLGL',
				'GL#',
				h_chart_of_accounts_id,
				SYSDATE,
				h_num_of_segments,
				h_concat_array_segments,
				px_dist_rec_new.expense_ccid )) THEN
       -- dbms_output.put_line('error ----- FND_FLEX_EXT.GET_COMBINATION_ID');

                -- -- dbms_output.put_line('FND_FLEX_APIS.get_segment_delimiter');
               -- build message
                h_delimiter := FND_FLEX_APIS.get_segment_delimiter(
                               101,
                               'GL#',
                               h_chart_of_accounts_id);

                -- fill the string for messaging with concat segs...
                while (h_num < h_num_of_segments) loop
                   h_num := h_num + 1;

                   if (h_num > 1) then
                      h_concat_segs := h_concat_segs ||
                                       h_delimiter;
                   end if;

                   h_concat_segs := h_concat_segs ||
                                    h_concat_array_segments(h_num);

                end loop;

                h_errmsg:= null;
                h_errmsg := FND_FLEX_EXT.GET_ENCODED_MESSAGE;

                FA_SRVR_MSG.ADD_MESSAGE
                       (CALLING_FN=>'FAFLEX_PKG_WF.START_PROCESS',
                        NAME=>'FA_FLEXBUILDER_FAIL_CCID',
                        TOKEN1 => 'ACCOUNT_TYPE',
                        VALUE1 => 'DEPRN_EXP',
                        TOKEN2 => 'BOOK_TYPE_CODE',
                        VALUE2 => p_asset_hdr_rec.book_type_code,
                        TOKEN3 => 'DIST_ID',
                        VALUE3 => 'NEW',
                        TOKEN4 => 'CONCAT_SEGS',
                        VALUE4 => h_concat_segs
                        , p_log_level_rec => p_log_level_rec);

                fnd_message.set_encoded(h_errmsg);
                fnd_msg_pub.add;

                RAISE fardodh_error;
	   END IF;


        RETURN (TRUE);

EXCEPTION
	  WHEN fardodh_error THEN
	    FA_SRVR_MSG.add_message(
                   CALLING_FN => l_calling_fn,
                   NAME       => h_mesg_name, p_log_level_rec => p_log_level_rec);
            RETURN (FALSE);
     WHEN OTHERS THEN
	     FA_SRVR_MSG.ADD_SQL_ERROR (
                    CALLING_FN => l_calling_fn, p_log_level_rec => p_log_level_rec);

            RETURN (FALSE);

END get_new_ccid;


--
FUNCTION get_asset_distribution(
         p_trans_rec           IN     FA_API_TYPES.trans_rec_type,
         p_asset_hdr_rec       IN     FA_API_TYPES.asset_hdr_rec_type,
         p_asset_cat_rec_old   IN     FA_API_TYPES.asset_cat_rec_type,
         p_asset_cat_rec_new   IN     FA_API_TYPES.asset_cat_rec_type,
         px_asset_dist_tbl     IN OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type,
         p_calling_fn          IN     VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

 CURSOR dh_csr IS
   Select dh.distribution_id,
          dh.code_combination_id,
          dh.units_assigned,
          dh.location_id,
          dh.assigned_to,
          ad.asset_number
   from  fa_book_controls bc,
         fa_distribution_history dh,
         fa_additions ad
   where dh.asset_id = p_asset_hdr_rec.asset_id
   and   dh.book_type_code = bc.distribution_source_book
   and   bc.book_type_code = p_asset_hdr_rec.book_type_code
   and   dh.book_type_code = p_asset_hdr_rec.book_type_code
   and   dh.date_ineffective is null
   and   dh.retirement_id is null
   and   dh.asset_id = ad.asset_id;

   CURSOR cat_csr( p_book varchar2, p_cat_id number) IS
     select deprn_expense_acct
     from   fa_category_books
     where  book_type_code = p_book
     and    category_id = p_cat_id;

   -- fix for bug 3255715
   CURSOR trx_date_csr( p_book varchar2) IS
            SELECT greatest(dp.calendar_period_open_date,
                   least(sysdate, dp.calendar_period_close_date))
            FROM fa_deprn_periods dp
            WHERE dp.book_type_code = p_book
                  AND dp.period_close_date IS NULL;

   i integer:= 0;
   j integer:= 0;
   l_rowcount number;
   l_dist_rec_old FA_API_TYPES.asset_dist_rec_type;
   l_dist_rec_new FA_API_TYPES.asset_dist_rec_type;

   l_new_deprn_exp_acct fa_category_books.deprn_expense_acct%type;
   l_old_deprn_exp_acct fa_category_books.deprn_expense_acct%type;
   l_err_stage varchar2(250);
   l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.get_asset_dist';
   l_trx_date_entered date; -- fix for bug 3255715

BEGIN

   l_err_stage:= 'initialize the table';
   -- -- dbms_output.put_line(l_err_stage);
   px_asset_dist_tbl.delete;

   -- check whether distribution change is needed
   OPEN cat_csr(p_asset_hdr_rec.book_type_code, p_asset_cat_rec_new.category_id );
   FETCH cat_csr INTO l_new_deprn_exp_acct;
   CLOSE cat_csr;

   OPEN cat_csr(p_asset_hdr_rec.book_type_code, p_asset_cat_rec_old.category_id );
   FETCH cat_csr INTO l_old_deprn_exp_acct;
   CLOSE cat_csr;

   -- fix for bug 3255715
   if(p_trans_rec.transaction_date_entered is null) then
     OPEN trx_date_csr(p_asset_hdr_rec.book_type_code);
     FETCH trx_date_csr into l_trx_date_entered;
     CLOSE trx_date_csr;
   else l_trx_date_entered := p_trans_rec.transaction_date_entered;
   end if;

   l_err_stage:= 'dh_csr';
   -- -- dbms_output.put_line(l_err_stage);
   FOR dh_rec in dh_csr LOOP
   i:= i+1;

   if not FA_ASSET_VAL_PVT.validate_assigned_to (
            p_transaction_type_code => p_trans_rec.transaction_type_code,
            p_assigned_to           => dh_rec.assigned_to,
            p_date                  => l_trx_date_entered,  -- fix for bug 3255715
            p_calling_fn            => p_calling_fn
            , p_log_level_rec => p_log_level_rec) then
       fa_srvr_msg.add_message(
               calling_fn => NULL,
               name       => 'FA_INVALID_ASSIGNED_TO',
               token1     => 'ASSET_NUMBER',
               value1     => dh_rec.asset_number,
               token2     => 'ASSIGNED_TO',
               value2     => dh_rec.assigned_to, p_log_level_rec => p_log_level_rec);
       dh_rec.assigned_to := NULL;  -- set to null if invalid employee
   end if;

   l_err_stage:= 'pop asset_dist_tbl with old dist row to be obseleted';
   -- dbms_output.put_line(l_err_stage);
   px_asset_dist_tbl(i).distribution_id   := dh_rec.distribution_id;
   px_asset_dist_tbl(i).transaction_units := ( dh_rec.units_assigned * -1);
   px_asset_dist_tbl(i).units_assigned    := dh_rec.units_assigned;
   px_asset_dist_tbl(i).assigned_to       := dh_rec.assigned_to;
   px_asset_dist_tbl(i).expense_ccid      := dh_rec.code_combination_id;
   px_asset_dist_tbl(i).location_ccid      := dh_rec.location_id;

  l_err_stage:= 'pop l_dist_rec_old';
   -- dbms_output.put_line(l_err_stage);
   l_dist_rec_old.expense_ccid  := dh_rec.code_combination_id;
   l_dist_rec_old.assigned_to   := dh_rec.assigned_to;
   l_dist_rec_old.location_ccid := dh_rec.location_id;


  -- dbms_output.put_line('l_old_deprn_exp_acct '||to_char(l_old_deprn_exp_acct));
  -- dbms_output.put_line('l_new_deprn_exp_acct '||to_char(l_new_deprn_exp_acct));
   if l_old_deprn_exp_acct <> l_new_deprn_exp_acct then
      -- pop new dist row to be created
      -- get new expense_ccid
      l_err_stage:= 'pop get_new_ccid';
      -- dbms_output.put_line(l_err_stage);
      if not get_new_ccid(
            p_trans_rec         => p_trans_rec,
            p_asset_hdr_rec     => p_asset_hdr_rec,
            p_asset_cat_rec_new => p_asset_cat_rec_new,
            p_dist_rec_old      => l_dist_rec_old,
            px_dist_rec_new     => l_dist_rec_new,
            p_log_level_rec     => p_log_level_rec ) then

         FA_SRVR_MSG.add_message( calling_fn => l_calling_fn , p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   else
     -- no need for change
     -- same as old
     l_dist_rec_new.expense_ccid := dh_rec.code_combination_id;
   end if;

  i:= i+1;
  l_err_stage:= 'pop asset_dist_tbl with new dist row';
  -- dbms_output.put_line(l_err_stage);
   px_asset_dist_tbl(i).distribution_id   := null;
   px_asset_dist_tbl(i).transaction_units := dh_rec.units_assigned;
   px_asset_dist_tbl(i).units_assigned    := dh_rec.units_assigned;
   px_asset_dist_tbl(i).assigned_to       := dh_rec.assigned_to;
   px_asset_dist_tbl(i).expense_ccid      := l_dist_rec_new.expense_ccid;
   px_asset_dist_tbl(i).location_ccid      := dh_rec.location_id;


   l_dist_rec_old := null;
   l_dist_rec_new := null;
  END LOOP;
   -- dbms_output.put_line('no of dist populated ' ||to_char(i));
   -- check whether this asset has any distribution
   if i = 0 then
      FA_SRVR_MSG.add_message(
                    CALLING_FN => l_calling_fn,
                    NAME       => 'FA_REC_NO_DIST_LINES' , p_log_level_rec => p_log_level_rec);
      return TRUE;
   end if;


  return TRUE;

EXCEPTION
  WHEN OTHERS THEN
     fa_srvr_msg.add_sql_error( calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
     return FALSE;
END get_asset_distribution;

-- ------------------------------------------------------


-- ------------------------------------------------------

FUNCTION get_cat_desc_flex(
         p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
         px_asset_desc_rec      IN OUT NOCOPY FA_API_TYPES.asset_desc_rec_type,
         p_asset_cat_rec_old    IN     FA_API_TYPES.asset_cat_rec_type,
         px_asset_cat_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_cat_rec_type,
         p_recl_opt_rec         IN     FA_API_TYPES.reclass_options_rec_type,
         p_calling_fn           IN     VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

  l_cat_struct    number;
  l_concat_cat    varchar2(210);
  l_cat_segs      fa_rx_shared_pkg.Seg_Array;
  i               integer:= 0;
  l_seg           varchar2(30);
  l_err_stage  varchar2(100);

  l_bal_seg_equal varchar2(1):= null;
  l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.get_cat_desc_flex';

--

  delim  varchar2(1);
  col_name  varchar2(25);

  num_segs  integer;
  seg_ctr   integer;

  v_cursorid   integer;
  v_sqlstmt     varchar2(500);
  v_return     integer;

  h_mesg_name  varchar2(30);
  h_mesg_str  varchar2(2000);

--
  h_table_id 	number;
  h_table_name  varchar2(30) := 'FA_CATEGORIES_B';

  h_ccid_col_name  varchar2(100) := 'CATEGORY_ID';
  h_flex_code      varchar2(10) :=  'CAT#';
  h_appl_id     number :=  140;
  h_appl_short_name	varchar2(10) := 'OFA';
  concat_string	varchar2(100);
  segarray		fa_rx_shared_pkg.Seg_Array;
  cursor segcolumns is
    select distinct g.application_column_name, g.segment_num
    from fnd_columns c, fnd_id_flex_segments g
	WHERE g.application_id = h_appl_id
	  AND g.id_flex_code = h_flex_code
	  AND g.id_flex_num = l_cat_struct
	  AND g.enabled_flag = 'Y'
	  AND g.display_flag = 'Y'
	  AND c.application_id = h_appl_id
	  AND c.table_id = h_table_id
	  AND c.column_name = g.application_column_name
	ORDER BY g.segment_num;

BEGIN

   l_err_stage:= 'get concatenated segs for the new category';
   -- dbms_output.put_line(l_err_stage);
   select category_flex_structure
   into l_cat_struct
   from fa_system_controls;

   l_err_stage:= 'fa_rx_shared_pkg.concat_category';
   -- dbms_output.put_line(l_err_stage);

-- bug 3225015
-- Replacing call to fa_rx_shared_pkg, with code underneatch
-- due to specific requirement, not to be shared.
/*   fa_rx_shared_pkg.concat_category (
                    struct_id     => l_cat_struct,
                    ccid          => px_asset_cat_rec_new.category_id,
                    concat_string => l_concat_cat,
                    segarray      => l_cat_segs, p_log_level_rec => p_log_level_rec);
*/
  select table_id into h_table_id from fnd_tables
  where table_name = h_table_name
  and application_id = 140;
--
  concat_string := '';

  select s.concatenated_segment_delimiter into delim
      FROM fnd_id_flex_structures s, fnd_application a
     WHERE s.application_id = a.application_id
       AND s.id_flex_code = h_flex_code
       AND s.id_flex_num = l_cat_struct
       AND a.application_short_name = h_appl_short_name;

  num_segs := 0;
  seg_ctr := 0;

  v_sqlstmt := 'select ';


  h_mesg_name := 'FA_SHARED_FLEX_SEGCOLUMNS';

  open segcolumns;
  loop

    fetch segcolumns into col_name, v_return;

    if (segcolumns%NOTFOUND) then exit;  end if;

    v_sqlstmt := v_sqlstmt || col_name || ', ';
    num_segs := num_segs + 1;

    segarray(num_segs) := 'seeded';

  end loop;
  close segcolumns;

  h_mesg_name := 'FA_SHARED_FLEX_DYNAMIC_SQL';

  v_sqlstmt := rtrim(v_sqlstmt,', ');
  v_sqlstmt := v_sqlstmt || ' from ' || h_table_name;
  v_sqlstmt := v_sqlstmt || ' where ' || h_ccid_col_name || ' = ';
  v_sqlstmt := v_sqlstmt || to_char(px_asset_cat_rec_new.category_id);

  v_cursorid := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursorid, v_sqlstmt, DBMS_SQL.V7);

  for seg_ctr in 1 .. num_segs loop

    --bugfix 3128860 msiddiqu
    --dbms_sql.define_column(v_cursorid, seg_ctr, segarray(seg_ctr), 25);
    dbms_sql.define_column(v_cursorid, seg_ctr, segarray(seg_ctr), 30);

  end loop;

  v_return := dbms_sql.execute(v_cursorid);
  v_return := dbms_sql.fetch_rows(v_cursorid);

  for seg_ctr in 1 .. num_segs loop
    dbms_sql.column_value(v_cursorid, seg_ctr, segarray(seg_ctr));

  end loop;

  for seg_ctr in 1 .. num_segs loop
    concat_string := concat_string || segarray(seg_ctr) || delim;

  end loop;

  concat_string := rtrim(concat_string,delim);

  dbms_sql.close_cursor(v_cursorid);

--  End replacing fa_rx_shared_pkg. This is what we finally need.
  l_concat_cat := concat_string;

--
   -- determine whether balancing seg of old and new cat is same
   l_err_stage:= 'FA_RECLASS_UTIL_PVT.check_bal_seg_equal';
   -- dbms_output.put_line(l_err_stage);
   if FA_RECLASS_UTIL_PVT.check_bal_seg_equal(
                          p_old_category_id => p_asset_cat_rec_old.category_id,
                          p_new_category_id => px_asset_cat_rec_new.category_id,
                          p_calling_fn      => l_calling_fn , p_log_level_rec => p_log_level_rec) then
       l_bal_seg_equal:= 'Y';
   else
       l_bal_seg_equal:= 'N';
   end if;

   -- determine whether to copy cat_desc info

   -- If copy_cat_desc_flag option is set to YES and if the old
   -- and new major category segment values are the same,
   -- old category descriptive flexfield information remains unchanged.
   -- Set context = attribute_category_code.  Do not update attribute columns.
   if ( p_recl_opt_rec.copy_cat_desc_flag = 'YES' and
        l_bal_seg_equal = 'Y' )then

      -- dbms_output.put_line('balancing segment same');

      px_asset_cat_rec_new.desc_flex.attribute_category_code := l_concat_cat;
      -- Bug 3148518
      --px_asset_cat_rec_new.desc_flex.context := l_concat_cat;
      px_asset_cat_rec_new.desc_flex.context := p_asset_cat_rec_old.desc_flex.context;

      px_asset_cat_rec_new.desc_flex.attribute_category_code := l_concat_cat;
      px_asset_cat_rec_new.desc_flex.attribute1:=
                           p_asset_cat_rec_old.desc_flex.attribute1;
      px_asset_cat_rec_new.desc_flex.attribute2:=
                                p_asset_cat_rec_old.desc_flex.attribute2;
      px_asset_cat_rec_new.desc_flex.attribute3:=
                                p_asset_cat_rec_old.desc_flex.attribute3;
      px_asset_cat_rec_new.desc_flex.attribute4:=
                                p_asset_cat_rec_old.desc_flex.attribute4;
      px_asset_cat_rec_new.desc_flex.attribute5:=
                                p_asset_cat_rec_old.desc_flex.attribute5;
      px_asset_cat_rec_new.desc_flex.attribute6:=
                                p_asset_cat_rec_old.desc_flex.attribute6;
      px_asset_cat_rec_new.desc_flex.attribute7:=
                                p_asset_cat_rec_old.desc_flex.attribute7;
      px_asset_cat_rec_new.desc_flex.attribute8:=
                                p_asset_cat_rec_old.desc_flex.attribute8;
      px_asset_cat_rec_new.desc_flex.attribute9:=
                                p_asset_cat_rec_old.desc_flex.attribute9;
      px_asset_cat_rec_new.desc_flex.attribute10:=
                                p_asset_cat_rec_old.desc_flex.attribute10;
      px_asset_cat_rec_new.desc_flex.attribute11:=
                                p_asset_cat_rec_old.desc_flex.attribute11;
      px_asset_cat_rec_new.desc_flex.attribute12:=
                                p_asset_cat_rec_old.desc_flex.attribute12;
      px_asset_cat_rec_new.desc_flex.attribute13:=
                                p_asset_cat_rec_old.desc_flex.attribute13;
      px_asset_cat_rec_new.desc_flex.attribute14:=
                                p_asset_cat_rec_old.desc_flex.attribute14;
      px_asset_cat_rec_new.desc_flex.attribute15:=
                                p_asset_cat_rec_old.desc_flex.attribute15;
      px_asset_cat_rec_new.desc_flex.attribute16:=
                                p_asset_cat_rec_old.desc_flex.attribute16;
      px_asset_cat_rec_new.desc_flex.attribute17:=
                                p_asset_cat_rec_old.desc_flex.attribute17;
      px_asset_cat_rec_new.desc_flex.attribute18:=
                                p_asset_cat_rec_old.desc_flex.attribute18;
      px_asset_cat_rec_new.desc_flex.attribute19:=
                                p_asset_cat_rec_old.desc_flex.attribute19;
      px_asset_cat_rec_new.desc_flex.attribute20:=
                                p_asset_cat_rec_old.desc_flex.attribute20;
      px_asset_cat_rec_new.desc_flex.attribute21:=
                                p_asset_cat_rec_old.desc_flex.attribute21;
      px_asset_cat_rec_new.desc_flex.attribute22:=
                                p_asset_cat_rec_old.desc_flex.attribute22;
      px_asset_cat_rec_new.desc_flex.attribute23:=
                                p_asset_cat_rec_old.desc_flex.attribute23;
      px_asset_cat_rec_new.desc_flex.attribute24:=
                                p_asset_cat_rec_old.desc_flex.attribute24;
      px_asset_cat_rec_new.desc_flex.attribute25:=
                                p_asset_cat_rec_old.desc_flex.attribute25;
      px_asset_cat_rec_new.desc_flex.attribute26:=
                                p_asset_cat_rec_old.desc_flex.attribute26;
      px_asset_cat_rec_new.desc_flex.attribute27:=
                                p_asset_cat_rec_old.desc_flex.attribute27;
      px_asset_cat_rec_new.desc_flex.attribute28:=
                                p_asset_cat_rec_old.desc_flex.attribute28;
      px_asset_cat_rec_new.desc_flex.attribute29:=
                                p_asset_cat_rec_old.desc_flex.attribute29;
      px_asset_cat_rec_new.desc_flex.attribute30:=
                                p_asset_cat_rec_old.desc_flex.attribute30;

  else
      -- Set context = attribute_category_code.
      px_asset_cat_rec_new.desc_flex.attribute_category_code := l_concat_cat;

      -- Bug 3066664
      -- px_asset_cat_rec_new.desc_flex.context := l_concat_cat;

      -- Fix for Bug #2475293.  We should not be nulling the new cat flex
/*    px_asset_cat_rec_new.desc_flex.attribute1:= null;
      px_asset_cat_rec_new.desc_flex.attribute2:= null;
      px_asset_cat_rec_new.desc_flex.attribute3:= null;
      px_asset_cat_rec_new.desc_flex.attribute4:= null;
      px_asset_cat_rec_new.desc_flex.attribute5:= null;
      px_asset_cat_rec_new.desc_flex.attribute6:= null;
      px_asset_cat_rec_new.desc_flex.attribute7:= null;
      px_asset_cat_rec_new.desc_flex.attribute8:= null;
      px_asset_cat_rec_new.desc_flex.attribute9:= null;
      px_asset_cat_rec_new.desc_flex.attribute10:= null;
      px_asset_cat_rec_new.desc_flex.attribute11:= null;
      px_asset_cat_rec_new.desc_flex.attribute12:= null;
      px_asset_cat_rec_new.desc_flex.attribute13:= null;
      px_asset_cat_rec_new.desc_flex.attribute14:= null;
      px_asset_cat_rec_new.desc_flex.attribute15:= null;
      px_asset_cat_rec_new.desc_flex.attribute16:= null;
      px_asset_cat_rec_new.desc_flex.attribute17:= null;
      px_asset_cat_rec_new.desc_flex.attribute18:= null;
      px_asset_cat_rec_new.desc_flex.attribute19:= null;
      px_asset_cat_rec_new.desc_flex.attribute20:= null;
      px_asset_cat_rec_new.desc_flex.attribute21:= null;
      px_asset_cat_rec_new.desc_flex.attribute22:= null;
      px_asset_cat_rec_new.desc_flex.attribute23:= null;
      px_asset_cat_rec_new.desc_flex.attribute24:= null;
      px_asset_cat_rec_new.desc_flex.attribute25:= null;
      px_asset_cat_rec_new.desc_flex.attribute26:= null;
      px_asset_cat_rec_new.desc_flex.attribute27:= null;
      px_asset_cat_rec_new.desc_flex.attribute28:= null;
      px_asset_cat_rec_new.desc_flex.attribute29:= null;
      px_asset_cat_rec_new.desc_flex.attribute30:= null;
*/
   end if;

   return TRUE;

EXCEPTION
  WHEN OTHERS THEN
     fa_srvr_msg.add_sql_error(
                      calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
     return FALSE;

END get_cat_desc_flex;
-----------------------------------------------------

----------------------------------------------------
FUNCTION check_bal_seg_equal(
         p_old_category_id   IN NUMBER,
         p_new_category_id   IN NUMBER,
         p_calling_fn        IN VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

    CURSOR get_cat_flex_struct IS
    SELECT category_flex_structure
    FROM FA_SYSTEM_CONTROLS;

    l_cat_flex_struct NUMBER;
    l_gsval           BOOLEAN;
    l_bal_segnum      NUMBER;
    l_numof_segs      NUMBER;
    l_all_segs_old    FND_FLEX_EXT.SegmentArray;
    l_all_segs_new    FND_FLEX_EXT.SegmentArray;
    l_old_bal_seg     VARCHAR2(30);
    l_new_bal_seg     VARCHAR2(30);
    l_calling_fn varchar2(40) := 'fa_reclass_util_pvt.check_bal_seg_equal';

    seg_err EXCEPTION;
BEGIN

     -- determine old and new bal segments
        -- -- dbms_output.put_line('get_cat_flex_struct');
        OPEN get_cat_flex_struct;
        FETCH get_cat_flex_struct INTO l_cat_flex_struct;
        CLOSE get_cat_flex_struct;

        -- Get the segment number for the major category.
        -- -- dbms_output.put_line('getqaulifier segnum');
        if NOT FND_FLEX_APIS.Get_Qualifier_Segnum (
                             appl_id          => 140 ,
                             key_flex_code    => 'CAT#',
                             structure_number => l_cat_flex_struct,
                             flex_qual_name   => 'BASED_CATEGORY',
                             segment_number   => l_bal_segnum) then
              raise seg_err;
        end if;

       -- get the segment valuse for the old category
        if NOT FND_FLEX_EXT.Get_Segments(
                            application_short_name  => 'OFA',
                            key_flex_code           => 'CAT#',
                            structure_number        => l_cat_flex_struct,
                            combination_id          => p_old_category_id,
                            n_segments              => l_numof_segs,
                            segments                => l_all_segs_old) then
              raise seg_err;
        end if;

        -- Get the old major category segment value.
        -- -- dbms_output.put_line('l_bal_segnum '||to_char(l_bal_segnum));
       if nvl(l_bal_segnum, 0) <> 0 then
          l_old_bal_seg := l_all_segs_old(l_bal_segnum);
       end if;

        -- Get the segment values for the new category.
        -- -- dbms_output.put_line('get_segments');
        if NOT FND_FLEX_EXT.Get_Segments(
                            application_short_name  => 'OFA',
                            key_flex_code           => 'CAT#',
                            structure_number        => l_cat_flex_struct,
                            combination_id          => p_new_category_id,
                            n_segments              => l_numof_segs,
                            segments                => l_all_segs_new) then
              raise seg_err;
        end if;

         -- Get the new major category segment value.
        -- -- dbms_output.put_line('l_bal_segnum'||to_char(l_bal_segnum));
       if nvl(l_bal_segnum, 0) <> 0 then
          l_new_bal_seg := l_all_segs_new(l_bal_segnum);
       end if;

       if ( nvl(l_old_bal_seg, '-999') <> nvl(l_new_bal_seg, '-999')) then
        -- dbms_output.put_line('balancing segment not equal - returning FALSE');
           return FALSE;
       end if;

       -- dbms_output.put_line('balancing segment equal - returning TRUE');
       return TRUE;

EXCEPTION
  when seg_err then
     FA_SRVR_MSG.Add_Message(
                          CALLING_FN => l_calling_fn,
                          NAME => 'FA_REC_GET_CATSEG_FAILED', p_log_level_rec => p_log_level_rec);
                          -- Message: 'Failed to get category segments.'
     return FALSE;

  when others then
     fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
     return FALSE;

END check_bal_seg_equal;

END FA_RECLASS_UTIL_PVT;

/
