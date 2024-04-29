--------------------------------------------------------
--  DDL for Package Body FA_GCCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GCCID_PKG" as
/* $Header: FAFBGCB.pls 120.6.12010000.2 2009/07/19 14:43:21 glchen ship $tpershad ship */

G_check_dist_accts      boolean := TRUE;
g_custom_gen_ccid       boolean := fa_cache_pkg.fa_custom_gen_ccid;
g_profile_init          boolean := fa_cache_pkg.fa_profile_init;
g_log_level_rec fa_api_types.log_level_rec_type;

FUNCTION fafb_load_functions(p_log_level_rec       IN
fa_api_types.log_level_rec_type default null)
return boolean is
 h_i		BINARY_INTEGER:=0;  /* Index to the table  */
 begin  <<load_functions>>
 h_i:= h_i+1;			/* h_i=1  */
fafb_accts(h_i).type_name := 'AP_INTERCOMPANY_ACCT';
fafb_accts(h_i).type_code := 'AP_INTERCO';
fafb_accts(h_i).flag := 'N';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'AR_INTERCOMPANY_ACCT';
fafb_accts(h_i).type_code := 'AR_INTERCO';
fafb_accts(h_i).flag := 'N';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'COST_OF_REMOVAL_CLEARING_ACCT';
fafb_accts(h_i).type_code := 'COR_CLEARING';
fafb_accts(h_i).flag := 'G';
h_i:=h_i+1;			/* h_i=4  */
fafb_accts(h_i).type_name := 'COST_OF_REMOVAL_GAIN_ACCT';
fafb_accts(h_i).type_code := 'COR_GAIN';
fafb_accts(h_i).flag := 'G';
h_i:=h_i+1;		/* h_i=5 */
fafb_accts(h_i).type_name := 'COST_OF_REMOVAL_LOSS_ACCT';
fafb_accts(h_i).type_code := 'COR_LOSS';
fafb_accts(h_i).flag := 'G';
h_i:=h_i+1;		/* h_i=6 */
fafb_accts(h_i).type_name := 'DEFERRED_DEPRN_EXPENSE_ACCT';
fafb_accts(h_i).type_code := 'DEF_DEPRN_EXP';
fafb_accts(h_i).flag := 'N';
h_i:=h_i+1;		/* h_i=7 */
fafb_accts(h_i).type_name := 'DEFERRED_DEPRN_RESERVE_ACCT';
fafb_accts(h_i).type_code := 'DEF_DEPRN_RSV';
fafb_accts(h_i).flag := 'N';
h_i:=h_i+1;		/* h_i=8 */
fafb_accts(h_i).type_name := 'NBV_RETIRED_GAIN_ACCT';
fafb_accts(h_i).type_code := 'NBV_GAIN';
fafb_accts(h_i).flag := 'G';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'NBV_RETIRED_LOSS_ACCT';
fafb_accts(h_i).type_code := 'NBV_LOSS';
fafb_accts(h_i).flag := 'G';
h_i:=h_i+1;		/* h_i=10  */
fafb_accts(h_i).type_name := 'PROCEEDS_OF_SALE_CLEARING_ACCT';
fafb_accts(h_i).type_code := 'POS_CLEARING';
fafb_accts(h_i).flag := 'G';
h_i:=h_i+1;  	/* h_i=11  */
fafb_accts(h_i).type_name := 'PROCEEDS_OF_SALE_GAIN_ACCT';
fafb_accts(h_i).type_code := 'POS_GAIN';
fafb_accts(h_i).flag := 'G';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'PROCEEDS_OF_SALE_LOSS_ACCT';
fafb_accts(h_i).type_code := 'POS_LOSS';
fafb_accts(h_i).flag := 'G';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'REVAL_RSV_RETIRED_GAIN_ACCT';
fafb_accts(h_i).type_code := 'REV_RSV_GAIN';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;		/* h_i=14  */
fafb_accts(h_i).type_name := 'REVAL_RSV_RETIRED_LOSS_ACCT';
fafb_accts(h_i).type_code := 'REV_RSV_LOSS';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'ASSET_CLEARING_ACCT';
fafb_accts(h_i).type_code := 'ASSET_CLEARING';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'ASSET_COST_ACCT';
fafb_accts(h_i).type_code := 'ASSET_COST';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;		/* h_i=17  */
fafb_accts(h_i).type_name := 'CIP_CLEARING_ACCT';
fafb_accts(h_i).type_code := 'CIP_CLEARING';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'CIP_COST_ACCT';
fafb_accts(h_i).type_code := 'CIP_COST';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'DEPRN_RESERVE_ACCT';
fafb_accts(h_i).type_code := 'DEPRN_RSV';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;		/* h_i=20 */
fafb_accts(h_i).type_name := 'BONUS_DEPRN_RESERVE_ACCT';
fafb_accts(h_i).type_code := 'BONUS_DEPRN_RSV';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'REVAL_AMORTIZATION_ACCT';
fafb_accts(h_i).type_code := 'REV_AMORT';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'REVAL_RESERVE_ACCT';
fafb_accts(h_i).type_code := 'REV_RSV';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;		/* h_i=23 */
fafb_accts(h_i).type_name := 'DEPRN_EXPENSE_ACCT';
fafb_accts(h_i).type_code := 'DEPRN_EXP';
fafb_accts(h_i).flag := 'D';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'BONUS_DEPRN_EXPENSE_ACCT';
fafb_accts(h_i).type_code := 'BONUS_DEPRN_EXP';
fafb_accts(h_i).flag := 'D';
h_i:=h_i+1;		/* h_i=25  */
fafb_accts(h_i).type_name := 'DEPRN_ADJUSTMENT_ACCT';
fafb_accts(h_i).type_code := 'DEPRN_ADJ';
fafb_accts(h_i).flag := 'N';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'IMPAIR_EXPENSE_ACCT';
fafb_accts(h_i).type_code := 'IMPAIR_EXP';
fafb_accts(h_i).flag := 'D';
h_i:=h_i+1;             /* h_i=27  */
fafb_accts(h_i).type_name := 'IMPAIR_RESERVE_ACCT';
fafb_accts(h_i).type_code := 'IMPAIR_RSV';
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;
fafb_accts(h_i).type_name := 'CAPITAL_ADJ_ACCT'; -- Bug 6666666 : Added for
fafb_accts(h_i).type_code := 'CAPITAL_ADJ';      -- SORP Compliance Project
fafb_accts(h_i).flag := 'A';
h_i:=h_i+1;             /* h_i=29  */
fafb_accts(h_i).type_name := 'GENERAL_FUND_ACCT';  -- Bug 6666666 : Added for
fafb_accts(h_i).type_code := 'GENERAL_FUND';       -- SORP Compliance Project
fafb_accts(h_i).flag := 'A';

return TRUE;
 EXCEPTION
   WHEN OTHERS THEN
     FA_SRVR_MSG.ADD_SQL_ERROR
	( CALLING_FN => 'FA_GCCID_PKG.fafb_load_functions',  p_log_level_rec => p_log_level_rec);
     return FALSE;
end fafb_load_functions;

------------------------------------------------------------------
FUNCTION fafb_search_functions(X_fin_trx_code varchar2,
			       X_function_code out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean
is
h_i  binary_integer:=0;
h_j  binary_integer:=0;
begin  <<fafb_search_functions>>
 FOR h_i in 1..FA_FLEX_TYPE.NUM_ACCTS+1
  LOOP
  h_j:=h_i;
  EXIT WHEN h_i > FA_FLEX_TYPE.NUM_ACCTS;
  if fafb_accts(h_i).type_name = X_fin_trx_code
  then
    X_function_code := fafb_accts(h_i).type_code;
    exit;
  end if;
 END LOOP;

 if h_j > FA_FLEX_TYPE.NUM_ACCTS then
   FA_SRVR_MSG.ADD_MESSAGE
	(CALLING_FN => 'FA_GCCID_PKG.fafb_search_functions',
	       NAME => 'FA_FLEX_NO_ACCOUNT',  p_log_level_rec => p_log_level_rec);
   return FALSE;
 end if;
return TRUE;
 EXCEPTION
   WHEN OTHERS THEN
    FA_SRVR_MSG.ADD_SQL_ERROR
		( CALLING_FN => 'FA_GCCID_PKG.fafb_search_functions',  p_log_level_rec => p_log_level_rec);
     return FALSE;
end fafb_search_functions;

-------------------------------------------------------------------
FUNCTION fafbgcc (X_book_type_code in fa_book_controls.book_type_code%type,
		  X_fn_trx_code    in varchar2,
		  X_dist_ccid	 in number,
		  X_acct_segval	 in varchar2,
		  X_account_ccid in number,
		  X_distribution_id in number,
	          X_rtn_ccid      out nocopy number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
 return boolean
 is
 h_acct_segval   varchar2(30);
 h_dist_ccid     number;
 h_dist_id       number;
 h_acct_ccid	 number;
 h_segs_def_ccid number;
 h_rtn_ccid	 number;
 h_flex_num      number:=null;
 h_flex_function_code	varchar2(30);
 h_ret_value		boolean;
 h_ccid_success		boolean := FALSE;
 h_ccid_found		boolean := FALSE;
 h_gen_expense		varchar2(1) := NULL;
 h_val_date             date;

 h_ccid_valid             varchar2(10) := NULL;

 CURSOR validate_ccid IS
        SELECT  'VALID'
        FROM    gl_code_combinations glcc
        WHERE   glcc.code_combination_id = X_rtn_ccid
        AND     glcc.enabled_flag = 'Y'
        AND     nvl(glcc.end_date_active, h_val_date) >=
                  h_val_date;

BEGIN <<fafbgcc>>


 h_dist_ccid := X_dist_ccid;
 h_acct_segval := X_acct_segval;
 h_dist_id := X_distribution_id;
 h_acct_ccid := X_account_ccid;

 h_ret_value := fafb_load_functions(p_log_level_rec);
  if not h_ret_value then
     FA_SRVR_MSG.ADD_MESSAGE
	    (CALLING_FN => 'FA_GCCID_PKG.fafbgcc',  p_log_level_rec => p_log_level_rec);
  end if;

 -- no need to call the cache here as it will already be loaded
 h_flex_num      := FA_CACHE_PKG.fazcbc_record.accounting_flex_structure;
 h_segs_def_ccid := FA_CACHE_PKG.fazcbc_record.flexbuilder_defaults_ccid;

 h_ret_value := fafb_search_functions(X_fin_trx_code=>X_fn_trx_code,
		       X_function_code=>h_flex_function_code,
                       p_log_level_rec => p_log_level_rec);
  if not h_ret_value  then
     FA_SRVR_MSG.ADD_MESSAGE
	    (CALLING_FN => 'FA_GCCID_PKG.fafbgcc',  p_log_level_rec => p_log_level_rec);
	return FALSE;
  end if;
  if (p_log_level_rec.statement_level)
  then
      FA_DEBUG_PKG.ADD(
              fname => 'FA_GCCID_PKG.fafbgcc',
	      element => 'dist_ccid in fafbgcc is ',
	       value => X_dist_ccid, p_log_level_rec => p_log_level_rec);
      FA_DEBUG_PKG.ADD(
              fname => 'FA_GCCID_PKG.fafbgcc',
	      element => 'flexbuilder defs ccid ',
	       value => h_segs_def_ccid, p_log_level_rec => p_log_level_rec);
  end if;

  -- BUG# 2215671
  -- Pass the validation date to start process to use the correct
  -- period date instead of system date.  G_validation_date will
  -- only be populated from FAPOST which is the only code where
  -- generation can occur for ccids from a prior or future period.
  --    bridgway

  if (G_validation_date is null) then
     if not fa_cache_pkg.fazcdp
              (x_book_type_code => x_book_type_code,
               x_period_counter => null,
               x_effective_date => null, p_log_level_rec => p_log_level_rec) then
       fa_srvr_msg.add_message(calling_fn => 'fa_gccid_pkg.fafbgcc',  p_log_level_rec => p_log_level_rec);
       return false;
     end if;
     h_val_date := fa_cache_pkg.fazcdp_record.calendar_period_close_date;
  else
     h_val_date := to_date(G_validation_date, 'DD/MM/RRRR'); --bug#5863965
  end if;

/*
  Call the START_PROCESS which will start the flex workflow process
*/
  if (p_log_level_rec.statement_level)
  then
     FA_DEBUG_PKG.ADD (
                fname => 'FA_GCCID_PKG.fafbgcc',
                element => 'validation_date in fafbgcb is ',
                 value =>h_val_date, p_log_level_rec => p_log_level_rec);

     FA_DEBUG_PKG.ADD (
		fname => 'FA_GCCID_PKG.fafbgcc',
		element => 'distribution ccid  in fafbgcc is ',
		 value =>X_dist_ccid, p_log_level_rec => p_log_level_rec);
     FA_DEBUG_PKG.ADD (
		fname => 'FA_GCCID_PKG.fafbgcc',
		element => 'Acct Type  in fafbgcc is ',
		 value =>h_flex_function_code, p_log_level_rec => p_log_level_rec);
      FA_DEBUG_PKG.ADD (
		fname => 'FA_GCCID_PKG.fafbgcc',
		element => 'segval  in fafbgcc is ',
		 value =>h_acct_segval, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (
		fname => 'FA_GCCID_PKG.fafbgcc',
		element => 'seg defs ccid  in fafbgcc is ',
		 value =>h_segs_def_ccid, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (
		fname => 'FA_GCCID_PKG.fafbgcc',
		element => 'acct ccid in fafbgcc is ',
		 value =>h_acct_ccid, p_log_level_rec => p_log_level_rec);
       FA_DEBUG_PKG.ADD (
		fname => 'FA_GCCID_PKG.fafbgcc',
		element => 'flex num  in fafbgcc is ',
		 value =>h_flex_num, p_log_level_rec => p_log_level_rec);
  end if;

  -- call get_ccid to check if ccid exists in fa_distribution_accounts
  -- G_check_dist_accts will be true when called from form transactions
  -- and false when called from fafbgcc_proc. When called from fafbgcc_proc
  -- not necessary to check fa_distribution_accounts again since get_ccid
  -- is already called in fafbgcc_proc

  --- BEGIN USE CUSTOM GEN CCID
  if not g_profile_init then
     if not fa_cache_pkg.fazprof then
        null;
     end if;
     g_custom_gen_ccid := fa_cache_pkg.fa_custom_gen_ccid;
     g_profile_init    := TRUE;
  end if;

  if (g_custom_gen_ccid) then

    if (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD(
              fname   => 'FA_GCCID_PKG.fafbgcc',
              element => 'entering ',
              value   => 'custom gen ccid logic', p_log_level_rec => p_log_level_rec);
    end if;


    h_ret_value := FA_CUSTOM_GEN_CCID_PKG.gen_ccid(
                          X_fn_trx_code=>X_fn_trx_code,
                          X_book_type_code=>X_book_type_code,
                          X_flex_num=>h_flex_num,
                          X_dist_ccid=>h_dist_ccid,
                          X_acct_segval=>h_acct_segval,
                          X_default_ccid=>h_segs_def_ccid,
                          X_account_ccid=>h_acct_ccid,
                          X_distribution_id=>h_dist_id,
                          X_rtn_ccid=>h_rtn_ccid, p_log_level_rec => p_log_level_rec);

      if not h_ret_value then

         X_rtn_ccid := -1;
         h_ret_value := FALSE;

      else

          X_rtn_ccid := h_rtn_ccid;

          if (X_rtn_ccid is NULL) OR (X_rtn_ccid <= 0) THEN

              h_ret_value := FALSE;

          else  -- (X_rtn_ccid > 0)

              open validate_ccid;
              fetch validate_ccid into h_ccid_valid;
              if (validate_ccid%NOTFOUND) then

                 h_ret_value := FALSE;

              else

                 h_ret_value := TRUE;

              end if;

              close validate_ccid;

          end if;

      end if;

      if (not h_ret_value) then
         FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN => 'FAFLEX_PKG_WF.START_PROCESS',
                 NAME       => 'FA_FLEXBUILDER_FAIL_CCID',
                 TOKEN1     => 'ACCOUNT_TYPE',
                 VALUE1     => X_fn_trx_code,
                 TOKEN2     => 'BOOK_TYPE_CODE',
                 VALUE2     => X_book_type_code,
                 TOKEN3     => 'DIST_ID',
                 VALUE3     => h_dist_id,
                 TOKEN4     => 'CONCAT_SEGS',
                 VALUE4     => 'from custom gen ccid'
                , p_log_level_rec => p_log_level_rec);
      end if;

      return h_ret_value;

  --- ELSE DO NOT USE CUSTOM GEN CCID
  else

    if (G_check_dist_accts) then
        h_ccid_success := FA_GCCID_PKG.get_ccid(
                                X_book_type_code,
                                X_distribution_id,
                                X_fn_trx_code,
                                h_val_date,
				h_ccid_found,
                                X_rtn_ccid, p_log_level_rec => p_log_level_rec);
    end if;

    -- Call workflow to generate ccid only when ccid is not in
    -- fa_distribution_accounts
    if (not h_ccid_found OR X_rtn_ccid = -1) then
      -- Bonus: BONUS_DEPRN_EXP_ACCT is not included in fa_distribution_accounts

      if (X_fn_trx_code = 'DEPRN_EXPENSE_ACCT') then

         --fnd_profile.get('FA_GEN_EXPENSE_ACCOUNT', h_gen_expense);
         if (not fa_cache_pkg.fa_gen_expense_account) then
             X_rtn_ccid := X_dist_ccid;
             return TRUE;
         end if;
      end if;

      h_ret_value := FAFLEX_PKG_WF.START_PROCESS(
				 X_flex_account_type=>h_flex_function_code,
			         X_book_type_code=>X_book_type_code,
				 X_flex_num=>h_flex_num,
				 X_dist_ccid=>h_dist_ccid,
				 X_acct_segval=>h_acct_segval,
				 X_default_ccid=>h_segs_def_ccid,
				 X_account_ccid=>h_acct_ccid,
				 X_distribution_id=>h_dist_id,
                                 X_validation_date=>h_val_date,
				 X_return_ccid=>h_rtn_ccid,
                                 p_log_level_rec=>p_log_level_rec);
      if (p_log_level_rec.statement_level)
      then
        FA_DEBUG_PKG.ADD (
		fname => 'FA_GCCID_PKG.fafbgcc',
		element => ' return from Start Process ',
		 value =>h_ret_value, p_log_level_rec => p_log_level_rec);
      end if;
      if not h_ret_value then
         /* BUG# 1504839
            this error is not needed.  We already dump an error to the
            stack in FAFLEX_WF_PKG

          Flexbuilder failed to generate the code combination id. Pls
          inform your systems administrator

         FA_SRVR_MSG.ADD_MESSAGE
	    (CALLING_FN => 'FA_GCCID_PKG.fafbgcc',
	           NAME => 'FA_FLEX_FUNCTION_FAILED',  p_log_level_rec => p_log_level_rec);
         */

         X_rtn_ccid := -1;
         return FALSE;
      end if;
      X_rtn_ccid := h_rtn_ccid;
      if (X_rtn_ccid is null)
      then
         return FALSE;
      end if;
    else
      -- not h_ccid_success is the case where ccid is found in
      -- fa_distribution_accounts but it is not valid. Otherwise ccid
      -- is valid.
      if (not h_ccid_success) then
	h_ret_value := FALSE;
      else
        -- ccid is valid
        h_ret_value := TRUE;
      end if;
    end if;
  end if;  -- custom_gen_ccid

  -- in case there is some problem return false when ccid is -1
  if (X_rtn_ccid = -1) then
     h_ret_value := FALSE;
  end if;

  return h_ret_value;

  EXCEPTION
   WHEN OTHERS THEN
     FA_SRVR_MSG.ADD_SQL_ERROR ( CALLING_FN => 'FA_GCCID_PKG.fafbgcc',  p_log_level_rec => p_log_level_rec);
     return FALSE;

END ;     /* fafbgcc  */

-------------------------------------------------------------------
PROCEDURE fafbgcc_proc
		  (X_book_type_code in fa_book_controls.book_type_code%type,
                  X_fn_trx_code  in varchar2,
                  X_dist_ccid    in integer,
                  X_acct_segval  in varchar2,
                  X_account_ccid in integer,
                  X_distribution_id in integer,
                  X_rtn_ccid        out nocopy number,
		  X_concat_segs     out nocopy varchar2,
		  X_return_value    out nocopy integer)
as
h_ret_value	boolean;
h_rtn_ccid	integer;
h_ccid_success	boolean;
h_ccid_found	boolean;

h_val_date      date;
error_found     exception;

begin
   -- initialize out variables to failure condition
   X_rtn_ccid := -1;
   h_rtn_ccid := -1;
   X_return_value := 0;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise error_found;
      end if;
   end if;

  -- for pro*c, we need to load the plsql cache for
  -- book controls and profile options
  if not FA_CACHE_PKG.fazcbc(X_book_type_code, p_log_level_rec => g_log_level_rec) then
     FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_GCCID_PKG.fafbgcc',  p_log_level_rec => g_log_level_rec);
     X_return_value := 0;
     return;
  end if;

  g_custom_gen_ccid := fa_cache_pkg.fa_custom_gen_ccid;
  g_profile_init    := TRUE;

  -- BUG# 2215671
  -- Pass the validation date to start process to use the correct
  -- period date instead of system date.  G_validation_date will
  -- only be populated from FAPOST which is the only code where
  -- generation can occur for ccids from a prior or future period.
  --    bridgway

  if (G_validation_date is null) then
     if not fa_cache_pkg.fazcdp
              (x_book_type_code => x_book_type_code,
               x_period_counter => null,
               x_effective_date => null, p_log_level_rec => g_log_level_rec) then
       X_return_value := 0;
       fa_srvr_msg.add_message(calling_fn => 'fa_gccid_pkg.fafbgcc',  p_log_level_rec => g_log_level_rec);
       return;
     end if;
     h_val_date := fa_cache_pkg.fazcdp_record.calendar_period_close_date;
  else
     h_val_date := to_date(G_validation_date, 'DD/MM/RRRR'); --bug#5863965
  end if;

   -- set G_check_dist_accts to FALSE so get_ccid does not get
   -- called again if ccid is not in fa_distribution_accounts
   -- and need to call fafbgcc to generate the ccid

   if not g_custom_gen_ccid then
      G_check_dist_accts := FALSE;
      h_ccid_success := FA_GCCID_PKG.get_ccid(
				X_book_type_code,
				to_number(X_distribution_id),
				X_fn_trx_code,
                                h_val_date,
			        h_ccid_found,
				h_rtn_ccid);
   end if;

   if (not h_ccid_found OR h_rtn_ccid = -1) then
      h_ret_value := FA_GCCID_PKG.fafbgcc(X_book_type_code,
                              X_fn_trx_code,
                              to_number(X_dist_ccid),
                              X_acct_segval,
                              to_number(X_account_ccid),
                              to_number(X_distribution_id),
                              h_rtn_ccid);
      if (h_ret_value) then
         X_return_value := 1;    /* True  */
      else
         X_return_value := 0;    /* False  */
      end if;
      X_rtn_ccid := h_rtn_ccid;
      X_concat_segs := FA_GCCID_PKG.global_concat_segs;
   elsif (not h_ccid_success) then
      X_rtn_ccid := h_rtn_ccid;
      X_concat_segs := FA_GCCID_PKG.global_concat_segs;
      X_return_value := 0;    /* False  */
   else
      X_rtn_ccid := h_rtn_ccid;
      X_concat_segs := FA_GCCID_PKG.global_concat_segs;
      X_return_value := 1;  /* True  */
   end if;

   -- in case there is some problem and ccid is not generated
   -- return false.
   if (X_rtn_ccid = -1) then
       X_return_value := 0;   /* False  */
   end if;

   if (g_log_level_rec.statement_level)
   then
    FA_DEBUG_PKG.ADD (
                     fname => 'fafbgcc_proc',
                     element=>'rtn ccid',
                     value=>h_rtn_ccid, p_log_level_rec => g_log_level_rec);
   end if;
   return;
EXCEPTION

   WHEN ERROR_FOUND THEN
        raise;

   WHEN OTHERS THEN
        if (g_log_level_rec.statement_level)
        then
           FA_DEBUG_PKG.ADD (
                     fname => 'fafbgcc_proc',
                     element=>'Errored',
                     value=>1, p_log_level_rec => g_log_level_rec);
        end if;
        X_return_value := 0;
        return;
END fafbgcc_proc;

--------------------------------------------------------------------------
FUNCTION get_ccid (X_book_type_code 	IN 	VARCHAR2,
		   X_distribution_id	IN	NUMBER,
		   X_fn_trx_code	IN      VARCHAR2,
                   X_validation_date    IN      DATE,
		   X_ccid_found	 OUT NOCOPY 	BOOLEAN,
		   X_rtn_ccid	 OUT NOCOPY NUMBER
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null)
		RETURN BOOLEAN is
h_cost_ccid     	number :=0;
h_clearing_ccid 	number :=0;
h_expense_ccid  	number :=0;
h_reserve_ccid  	number :=0;
h_cip_cost_ccid 	number :=0;
h_cip_clearing_ccid     number :=0;
h_nbv_retired_gain_ccid number :=0;
h_nbv_retired_loss_ccid number :=0;
h_pos_gain_ccid         number :=0;
h_pos_loss_ccid         number :=0;
h_cost_removal_gain_ccid number :=0;
h_cost_removal_loss_ccid number :=0;
h_cor_clearing_ccid      number :=0;
h_pos_clearing_ccid      number :=0;

h_reval_rsv_ret_gain_ccid number := 0;
h_reval_rsv_ret_loss_ccid number := 0;
h_deferred_dep_exp_ccid    number := 0;
h_deferred_dep_rsv_ccid    number := 0;
h_deprn_adjustment_ccid    number := 0;
h_reval_amortization_ccid  number := 0;
h_reval_reserve_ccid       number := 0;
h_bonus_deprn_expense_ccid number := 0;
h_bonus_deprn_reserve_ccid number := 0;
h_impair_expense_ccid      number := 0;
h_impair_reserve_ccid      number := 0;
h_capital_adj_ccid         number := 0; -- Bug 6666666 : Added for SORP
h_general_fund_ccid        number := 0; -- Bug 6666666 : Added for SORP

-- added following variables for fix to bug 969990
h_flex_num               number := null;
h_ccid_valid             varchar2(10) := NULL;
n_segs                   number;
all_segments             fnd_flex_ext.SegmentArray;
delim                    varchar2(1);
get_segs_success         boolean;
h_ret_value		 boolean := FALSE;

-- added the following for bug 1085809
h_pregen                 boolean := TRUE;


CURSOR get_accounts IS
       SELECT  nvl(ASSET_COST_ACCOUNT_CCID, -1),
               nvl(ASSET_CLEARING_ACCOUNT_CCID, -1),
               nvl(DEPRN_EXPENSE_ACCOUNT_CCID, -1),
               nvl(DEPRN_RESERVE_ACCOUNT_CCID, -1),
               nvl(CIP_COST_ACCOUNT_CCID, -1),
               nvl(CIP_CLEARING_ACCOUNT_CCID, -1),
               nvl(NBV_RETIRED_GAIN_CCID,-1),
               nvl(NBV_RETIRED_LOSS_CCID,-1),
               nvl(PROCEEDS_SALE_GAIN_CCID,-1),
               nvl(PROCEEDS_SALE_LOSS_CCID,-1),
               nvl(COST_REMOVAL_GAIN_CCID,-1),
               nvl(COST_REMOVAL_LOSS_CCID,-1),
               nvl(COST_REMOVAL_CLEARING_CCID,-1),
               nvl(PROCEEDS_SALE_CLEARING_CCID,-1),
               nvl(REVAL_RSV_GAIN_ACCOUNT_CCID, -1),
               nvl(REVAL_RSV_LOSS_ACCOUNT_CCID, -1),
               nvl(DEFERRED_EXP_ACCOUNT_CCID, -1),
               nvl(DEFERRED_RSV_ACCOUNT_CCID, -1),
               nvl(DEPRN_ADJ_ACCOUNT_CCID, -1),
               nvl(REVAL_AMORT_ACCOUNT_CCID, -1),
               nvl(REVAL_RSV_ACCOUNT_CCID, -1),
               nvl(BONUS_EXP_ACCOUNT_CCID, -1),
               nvl(BONUS_RSV_ACCOUNT_CCID, -1),
               nvl(IMPAIR_EXPENSE_ACCOUNT_CCID, -1),
               nvl(IMPAIR_RESERVE_ACCOUNT_CCID, -1),
               nvl(CAPITAL_ADJ_ACCOUNT_CCID, -1),  -- Bug 6666666 : SORP
               nvl(GENERAL_FUND_ACCOUNT_CCID, -1),  -- Bug 6666666 : SORP
               accounting_flex_structure
       FROM    FA_DISTRIBUTION_ACCOUNTS da,
               FA_BOOK_CONTROLS bc
       WHERE   bc.book_type_code = X_book_type_code
       AND     da.book_type_code = bc.book_type_code
       AND     da.distribution_id = X_distribution_id;

CURSOR validate_ccid IS
        SELECT  'VALID'
        FROM    gl_code_combinations glcc
        WHERE   glcc.code_combination_id = X_rtn_ccid
        AND     glcc.enabled_flag = 'Y'
        AND     nvl(glcc.end_date_active, X_validation_date) >=
                  X_validation_date;

BEGIN
   -- initialize out variables to failure condition
   X_rtn_ccid := -1;
   X_ccid_found := FALSE;

   -- bug# 1085809: do not check distribution_accounts for an account if
   -- the associated pregeneration profile option is set to 'N'

   if (X_fn_trx_code = 'DEPRN_EXPENSE_ACCT') then
      -- fnd_profile.get('FA_PREGEN_ASSET_ACCOUNT', h_pregen);
      h_pregen := fa_cache_pkg.fa_pregen_asset_account;
   end if;

   if (X_fn_trx_code in ('ASSET_COST_ACCT',
                         'ASSET_CLEARING_ACCT',
                         'DEPRN_RESERVE_ACCT',
                         'CIP_COST_ACCT',
                         'CIP_CLEARING_ACCT',
                         'REVAL_AMORTIZATION_ACCT',
                         'REVAL_RESERVE_ACCT',
                         'BONUS_DEPRN_EXPENSE_ACCT',
                         'BONUS_DEPRN_RESERVE_ACCT',
                         'IMPAIR_EXPENSE_ACCT',
                         'IMPAIR_RESERVE_ACCT',
                         'CAPITAL_ADJ_ACCT',  -- Bug 6666666 : Added for SORP
                         'GENERAL_FUND_ACCT'  -- Bug 6666666 : Added for SORP
                         )) then
      --fnd_profile.get('FA_PREGEN_CAT_ACCOUNT', h_pregen);
      h_pregen := fa_cache_pkg.fa_pregen_cat_account;
   end if;

   if (X_fn_trx_code in ('NBV_RETIRED_GAIN_ACCT',
                         'NBV_RETIRED_LOSS_ACCT',
                         'PROCEEDS_OF_SALE_GAIN_ACCT',
                         'PROCEEDS_OF_SALE_LOSS_ACCT',
                         'COST_OF_REMOVAL_GAIN_ACCT',
                         'COST_OF_REMOVAL_LOSS_ACCT',
                         'COST_OF_REMOVAL_CLEARING_ACCT',
                         'PROCEEDS_OF_SALE_CLEARING_ACCT',
                         'REVAL_RSV_RETIRED_GAIN_ACCT',
                         'REVAL_RSV_RETIRED_LOSS_ACCT',
                         'DEFERRED_DEPRN_EXPENSE_ACCT',
                         'DEFERRED_DEPRN_RESERVE_ACCT',
                         'DEPRN_ADJUSTMENT_ACCT'
                        )) then
      --fnd_profile.get('FA_PREGEN_BOOK_ACCOUNT', h_pregen);
      h_pregen := fa_cache_pkg.fa_pregen_book_account;
   end if;

   if (h_pregen) then
      OPEN get_accounts;
      FETCH get_accounts into
                h_cost_ccid,
                h_clearing_ccid,
                h_expense_ccid,
                h_reserve_ccid,
                h_cip_cost_ccid,
                h_cip_clearing_ccid,
                h_nbv_retired_gain_ccid,
                h_nbv_retired_loss_ccid,
                h_pos_gain_ccid,
                h_pos_loss_ccid,
                h_cost_removal_gain_ccid,
                h_cost_removal_loss_ccid,
                h_cor_clearing_ccid,
                h_pos_clearing_ccid,
                h_reval_rsv_ret_gain_ccid,
                h_reval_rsv_ret_loss_ccid,
                h_deferred_dep_exp_ccid,
                h_deferred_dep_rsv_ccid,
                h_deprn_adjustment_ccid,
                h_reval_amortization_ccid,
                h_reval_reserve_ccid,
                h_bonus_deprn_expense_ccid,
                h_bonus_deprn_reserve_ccid,
                h_impair_expense_ccid,
                h_impair_reserve_ccid,
                h_capital_adj_ccid, -- Bug 6666666 : Added for SORP
                h_general_fund_ccid, -- Bug 6666666 : Added for SORP
                h_flex_num;

      if (get_accounts%FOUND) then
         if (X_fn_trx_code = 'ASSET_COST_ACCT') then
            X_rtn_ccid := h_cost_ccid;
         elsif (X_fn_trx_code = 'ASSET_CLEARING_ACCT') then
            X_rtn_ccid := h_clearing_ccid;
         elsif (X_fn_trx_code = 'DEPRN_RESERVE_ACCT') then
            X_rtn_ccid := h_reserve_ccid;
         elsif (X_fn_trx_code = 'DEPRN_EXPENSE_ACCT') then
            X_rtn_ccid := h_expense_ccid;
         elsif (X_fn_trx_code = 'CIP_COST_ACCT') then
            X_rtn_ccid := h_cip_cost_ccid;
         elsif (X_fn_trx_code = 'CIP_CLEARING_ACCT') then
            X_rtn_ccid := h_cip_clearing_ccid;
         elsif (X_fn_trx_code = 'NBV_RETIRED_GAIN_ACCT') then
            X_rtn_ccid := h_nbv_retired_gain_ccid;
         elsif (X_fn_trx_code = 'NBV_RETIRED_LOSS_ACCT') then
            X_rtn_ccid := h_nbv_retired_loss_ccid;
         elsif (X_fn_trx_code = 'PROCEEDS_OF_SALE_GAIN_ACCT') then
            X_rtn_ccid := h_pos_gain_ccid;
         elsif (X_fn_trx_code = 'PROCEEDS_OF_SALE_LOSS_ACCT') then
            X_rtn_ccid := h_pos_loss_ccid;
         elsif (X_fn_trx_code = 'COST_OF_REMOVAL_GAIN_ACCT') then
            X_rtn_ccid := h_cost_removal_gain_ccid;
         elsif (X_fn_trx_code = 'COST_OF_REMOVAL_LOSS_ACCT') then
            X_rtn_ccid := h_cost_removal_loss_ccid; --BUG# 1390143
         elsif (X_fn_trx_code = 'COST_OF_REMOVAL_CLEARING_ACCT') then
            X_rtn_ccid := h_cor_clearing_ccid;
         elsif (X_fn_trx_code = 'PROCEEDS_OF_SALE_CLEARING_ACCT') then
            X_rtn_ccid := h_pos_clearing_ccid;
         elsif (X_fn_trx_code = 'REVAL_RSV_RETIRED_GAIN_ACCT') then
            X_rtn_ccid := h_reval_rsv_ret_gain_ccid;
         elsif (X_fn_trx_code = 'REVAL_RSV_RETIRED_LOSS_ACCT') then
            X_rtn_ccid := h_reval_rsv_ret_loss_ccid;
         elsif (X_fn_trx_code = 'DEFERRED_DEPRN_EXPENSE_ACCT') then
            X_rtn_ccid := h_deferred_dep_exp_ccid;
         elsif (X_fn_trx_code = 'DEFERRED_DEPRN_RESERVE_ACCT') then
            X_rtn_ccid := h_deferred_dep_rsv_ccid;
         elsif (X_fn_trx_code = 'DEPRN_ADJUSTMENT_ACCT') then
            X_rtn_ccid := h_deprn_adjustment_ccid;
         elsif (X_fn_trx_code = 'REVAL_AMORTIZATION_ACCT') then
            X_rtn_ccid := h_reval_amortization_ccid;
         elsif (X_fn_trx_code = 'REVAL_RESERVE_ACCT') then
            X_rtn_ccid := h_reval_reserve_ccid;
         elsif (X_fn_trx_code = 'BONUS_DEPRN_EXPENSE_ACCT') then
            X_rtn_ccid := h_bonus_deprn_expense_ccid;
         elsif (X_fn_trx_code = 'BONUS_DEPRN_RESERVE_ACCT') then
            X_rtn_ccid := h_bonus_deprn_reserve_ccid;
         elsif (X_fn_trx_code = 'IMPAIR_EXPENSE_ACCT') then
            X_rtn_ccid := h_impair_expense_ccid;
         elsif (X_fn_trx_code = 'IMPAIR_RESERVE_ACCT') then
            X_rtn_ccid := h_impair_reserve_ccid;
         elsif (X_fn_trx_code = 'CAPITAL_ADJ_ACCT') then -- Bug 6666666 :
            X_rtn_ccid := h_capital_adj_ccid;            -- Added for SORP
         elsif (X_fn_trx_code = 'GENERAL_FUND_ACCT') then -- Bug 6666666 :
            X_rtn_ccid := h_general_fund_ccid;           -- Added for SORP
         end if;

         if (X_rtn_ccid > 0) then
             -- fix for bug 969990
	    X_ccid_found := TRUE;
            open validate_ccid;
            fetch validate_ccid into h_ccid_valid;
            if (validate_ccid%NOTFOUND) then
               get_segs_success := FND_FLEX_EXT.get_segments(
                        application_short_name => 'SQLGL',
                        key_flex_code => 'GL#',
                        structure_number => h_flex_num,
                        combination_id => X_rtn_ccid,
                        n_segments => n_segs,
                        segments => all_segments);
               delim := FND_FLEX_EXT.get_delimiter(
                        application_short_name => 'SQLGL',
                        key_flex_code => 'GL#',
                        structure_number => h_flex_num);
               FA_GCCID_PKG.global_concat_segs :=
	  	FND_FLEX_EXT.concatenate_segments(
                        n_segments => n_segs,
                        segments   => all_segments,
                        delimiter  => delim);

               FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN=>'FAFLEX_PKG_WF.START_PROCESS',
                 NAME=>'FA_FLEXBUILDER_FAIL_CCID',
                 TOKEN1 => 'ACCOUNT_TYPE',
                 VALUE1 => X_fn_trx_code,
                 TOKEN2 => 'BOOK_TYPE_CODE',
                 VALUE2 => X_book_type_code,
                 TOKEN3 => 'DIST_ID',
                 VALUE3 => X_distribution_id,
                 TOKEN4 => 'CONCAT_SEGS',
                 VALUE4 => FA_GCCID_PKG.global_concat_segs
                ,  p_log_level_rec => p_log_level_rec);

               fnd_message.set_name('FND', 'FLEX-COMBINATION DISABLED');
               fnd_msg_pub.add;  -- end 1504839


               h_ret_value := FALSE;
            else
               h_ret_value := TRUE;
            end if;
            close validate_ccid;
         else
	    h_ret_value := FALSE;
         end if;
      else
	 h_ret_value := FALSE;
      end if;
      CLOSE get_accounts;
   else
      h_ret_value := FALSE;
   end if; -- pregen profile
   RETURN h_ret_value;
END get_ccid;

--------------------------------------------------------------------------

PROCEDURE fafbgcc_proc_msg(X_mesg_count IN OUT NOCOPY number,
                           X_mesg_string     IN OUT NOCOPY VARCHAR2) IS

begin

    X_mesg_count := fnd_msg_pub.count_msg;

     if (X_mesg_count > 0) then

         X_mesg_string := fnd_global.Local_Chr(10) || substr(fnd_msg_pub.get
                                       (fnd_msg_pub.G_FIRST, fnd_api.G_FALSE),
                                        1, 512);

         for i in 1..2 loop -- (X_mesg_count - 1) loop

            X_mesg_string := X_mesg_string || fnd_global.Local_Chr(10) ||
                        substr(fnd_msg_pub.get
                               (fnd_msg_pub.G_NEXT,
                                fnd_api.G_FALSE), 1, 512);
         end loop;

         fnd_msg_pub.delete_msg();

     else
       X_mesg_count  := 0;
       X_mesg_string := 'NONE';
     end if;

end fafbgcc_proc_msg;

END FA_GCCID_PKG;

/
