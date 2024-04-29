--------------------------------------------------------
--  DDL for Package Body FA_SORP_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SORP_UPG_PKG" AS
/* $Header: FAVSRUB.pls 120.3.12010000.1 2009/07/21 12:37:51 glchen noship $   */

-- this fucntion determines if a book to be upgraded is MRC enabled or not
function fa_sorp_upg_mc_flag(p_book_type_code varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
return boolean
is
v_mc_source_flag varchar2(5);
cursor c_mc_cur is
select nvl(MC_SOURCE_FLAG,'N') from FA_BOOK_CONTROLS
where book_type_code = p_book_type_code;
begin
        open c_mc_cur;
        fetch c_mc_cur into v_mc_source_flag;
        close c_mc_cur;

        if v_mc_source_flag = 'Y' then
                return true;
        else
                return false;
        end if;

end fa_sorp_upg_mc_flag;

   FUNCTION get_ccid (p_acct_flex_struct NUMBER, p_account VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN NUMBER
   IS
      CURSOR c_ccid_cur
      IS
         SELECT code_combination_id
           FROM gl_code_combinations_kfv
           WHERE chart_of_accounts_id = p_acct_flex_struct
            AND concatenated_segments = p_account;

      v_ccid   NUMBER;
   BEGIN
      OPEN c_ccid_cur;

      FETCH c_ccid_cur
       INTO v_ccid;

      CLOSE c_ccid_cur;

      RETURN v_ccid;
   END get_ccid;

   FUNCTION get_account_seg (p_acct_flex_struct NUMBER, p_ccid NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN NUMBER
   IS
      CURSOR c_acct_seg_cur
      IS
         SELECT application_column_name
           FROM fnd_segment_attribute_values fndsav
          WHERE fndsav.id_flex_code = 'GL#'
            AND fndsav.segment_attribute_type = 'GL_ACCOUNT'
            AND fndsav.attribute_value = 'Y'
            AND application_id = 101
            AND fndsav.id_flex_num = p_acct_flex_struct;

      v_appl_col_name   VARCHAR2 (25);
      l_string          VARCHAR2 (4000);
      v_acct            NUMBER;
   BEGIN
      OPEN c_acct_seg_cur;

      FETCH c_acct_seg_cur
       INTO v_appl_col_name;

      CLOSE c_acct_seg_cur;

      l_string :=
            'SELECT '
         || v_appl_col_name
         || ' from GL_CODE_COMBINATIONS_KFV where chart_of_accounts_id = '
         || p_acct_flex_struct
         || ' and code_combination_id = '
         || p_ccid;

      EXECUTE IMMEDIATE l_string
                   INTO v_acct;

      RETURN v_acct;
   END get_account_seg;

   FUNCTION get_flex_struct (p_flex_name VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN NUMBER
   IS
      v_cat_struct_id   NUMBER;
   BEGIN
      IF p_flex_name = 'CAT'
      THEN
         SELECT category_flex_structure
           INTO v_cat_struct_id
           FROM fa_system_controls;

         RETURN (v_cat_struct_id);
      END IF;
   END get_flex_struct;

   FUNCTION get_cat_flex (p_category_id NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN VARCHAR2
   IS
      v_category_name   VARCHAR2 (1000);

      CURSOR c_cat_cur
      IS
         SELECT DISTINCT attribute_category_code
                    FROM fa_additions_v
                   WHERE asset_category_id = p_category_id;
   BEGIN
      OPEN c_cat_cur;

      FETCH c_cat_cur
       INTO v_category_name;

      CLOSE c_cat_cur;

      RETURN v_category_name;
   END get_cat_flex;

function get_impairment_sorp_values(
   p_book_type_code IN VARCHAR2,
   p_asset_id IN NUMBER,
   p_dist_id IN NUMBER,
   p_period_counter IN NUMBER,
   p_mode varchar2,
   px_capital_adj IN OUT NOCOPY NUMBER,
   px_general_fund IN OUT NOCOPY NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN
IS
cursor c_deprn_detail_cur is
select itf.asset_id,
       itf.impairment_id,
       th.transaction_header_id,
       adj.adjustment_type,
       nvl(decode(adj.debit_credit_flag,'DR',(-1*adj.adjustment_amount)),0) adjustment_amount,
       det.distribution_id
from
fa_itf_impairments itf,
fa_impairments imp,
fa_transaction_headers th,
fa_adjustments adj,
fa_deprn_detail det
where itf.impairment_id = imp.impairment_id
and itf.impairment_id = th.mass_transaction_id
and th.transaction_header_id = adj.transaction_header_id
and adj.distribution_id = det.distribution_id
and det.period_counter = p_period_counter
and det.period_counter = itf.period_counter
and det.asset_id = itf.asset_id
and itf.asset_id = p_asset_id
and det.book_type_code = p_book_type_code
and imp.status = 'POSTED'
and adj.adjustment_type = 'REVAL RESERVE'
and adj.source_type_code = 'ADJUSTMENT'
and substr(imp.description,1,3) = 'CEB'
and det.distribution_id = p_dist_id;

v_deprn_detail_cur c_deprn_detail_cur%rowtype;

cursor c_deprn_summary_cur is
select itf.asset_id,
       itf.impairment_id,
       th.transaction_header_id,
       adj.adjustment_type,
       nvl(decode(adj.debit_credit_flag,'DR',(-1*adj.adjustment_amount)),0) adjustment_amount
from
fa_itf_impairments itf,
fa_impairments imp,
fa_transaction_headers th,
fa_adjustments adj,
fa_deprn_summary su
where itf.impairment_id = imp.impairment_id
and itf.impairment_id = th.mass_transaction_id
and th.transaction_header_id = adj.transaction_header_id
and su.period_counter = itf.period_counter
and itf.asset_id = su.asset_id
and su.period_counter =  p_period_counter
and itf.asset_id = p_asset_id
and su.book_type_code = p_book_type_code
and imp.status = 'POSTED'
and adj.adjustment_type = 'REVAL RESERVE'
and adj.source_type_code = 'ADJUSTMENT'
and substr(imp.description,1,3) = 'CEB';

v_deprn_summary_cur c_deprn_summary_cur%rowtype;

begin

if p_mode = 'D' then

        open c_deprn_detail_cur;
        fetch c_deprn_detail_cur into v_deprn_detail_cur;

        if c_deprn_detail_cur%rowcount <> 0 then

                px_capital_adj := v_deprn_detail_cur.adjustment_amount;
                px_general_fund := 0;

        else

            px_capital_adj := 0;
                px_general_fund := 0;
        end if;

        close c_deprn_detail_cur;

else

    open c_deprn_summary_cur;
        fetch c_deprn_summary_cur into v_deprn_summary_cur;

        if c_deprn_summary_cur%rowcount <>0 then

                px_capital_adj := v_deprn_summary_cur.adjustment_amount;
                px_general_fund := 0;

        else

            px_capital_adj := 0;
                px_general_fund := 0;
        end if;

        close c_deprn_summary_cur;

end if;

return true;
exception when others then
return false;

end get_impairment_sorp_values;

function get_impairment_sorp_mc(
   p_book_type_code IN VARCHAR2,
   p_asset_id IN NUMBER,
   p_dist_id IN NUMBER,
   p_period_counter IN NUMBER,
   p_mode varchar2,
   px_capital_adj IN OUT NOCOPY NUMBER,
   px_general_fund IN OUT NOCOPY NUMBER,
   p_set_of_books_id IN NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN
IS
cursor c_deprn_detail_cur is
select itf.asset_id,
       itf.impairment_id,
       th.transaction_header_id,
       adj.adjustment_type,
       nvl(decode(adj.debit_credit_flag,'DR',(-1*adj.adjustment_amount)),0) adjustment_amount,
       det.distribution_id
from
FA_MC_ITF_IMPAIRMENTS itf,
FA_MC_IMPAIRMENTS imp,
fa_transaction_headers th,
fa_adjustments adj,
FA_MC_DEPRN_DETAIL det
where itf.impairment_id = imp.impairment_id
and itf.impairment_id = th.mass_transaction_id
and th.transaction_header_id = adj.transaction_header_id
and adj.distribution_id = det.distribution_id
and det.period_counter = p_period_counter
and det.period_counter = itf.period_counter
and det.asset_id = itf.asset_id
and itf.asset_id = p_asset_id
and det.book_type_code = p_book_type_code
and imp.status = 'POSTED'
and adj.adjustment_type = 'REVAL RESERVE'
and adj.source_type_code = 'ADJUSTMENT'
and substr(imp.description,1,3) = 'CEB'
and det.distribution_id = p_dist_id
and det.set_of_books_id = NVL(p_set_of_books_id,det.set_of_books_id);

v_deprn_detail_cur c_deprn_detail_cur%rowtype;

cursor c_deprn_summary_cur is
select itf.asset_id,
       itf.impairment_id,
       th.transaction_header_id,
       adj.adjustment_type,
       nvl(decode(adj.debit_credit_flag,'DR',(-1*adj.adjustment_amount)),0) adjustment_amount
from
FA_MC_ITF_IMPAIRMENTS itf,
FA_MC_IMPAIRMENTS imp,
fa_transaction_headers th,
fa_adjustments adj,
FA_MC_DEPRN_SUMMARY su
where itf.impairment_id = imp.impairment_id
and itf.impairment_id = th.mass_transaction_id
and th.transaction_header_id = adj.transaction_header_id
and su.period_counter = itf.period_counter
and itf.asset_id = su.asset_id
and su.period_counter =  p_period_counter
and itf.asset_id = p_asset_id
and su.book_type_code = p_book_type_code
and imp.status = 'POSTED'
and adj.adjustment_type = 'REVAL RESERVE'
and adj.source_type_code = 'ADJUSTMENT'
and substr(imp.description,1,3) = 'CEB'
and su.set_of_books_id = NVL(p_set_of_books_id,su.set_of_books_id);

v_deprn_summary_cur c_deprn_summary_cur%rowtype;

begin

if p_mode = 'D' then

        open c_deprn_detail_cur;
        fetch c_deprn_detail_cur into v_deprn_detail_cur;

        if c_deprn_detail_cur%rowcount <> 0 then

                px_capital_adj := v_deprn_detail_cur.adjustment_amount;
                px_general_fund := 0;

        else

            px_capital_adj := 0;
                px_general_fund := 0;
        end if;

        close c_deprn_detail_cur;

else

    open c_deprn_summary_cur;
        fetch c_deprn_summary_cur into v_deprn_summary_cur;

        if c_deprn_summary_cur%rowcount <>0 then

                px_capital_adj := v_deprn_summary_cur.adjustment_amount;
                px_general_fund := 0;

        else

            px_capital_adj := 0;
                px_general_fund := 0;
        end if;

        close c_deprn_summary_cur;

end if;

return true;
exception when others then
return false;

end get_impairment_sorp_mc;

FUNCTION get_retirement_sorp_values(
  p_book_type_code IN VARCHAR2,
  p_asset_id IN NUMBER,
  p_dist_id IN NUMBER,
  p_period_counter IN NUMBER,
  px_capital_adj IN OUT NOCOPY NUMBER,
  px_general_fund IN OUT NOCOPY NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN
IS
  l_reval_reserve_ca NUMBER;
  l_nbv_retired_ca NUMBER;
  l_nbv_retired_gf NUMBER;
  l_old_dist_ca NUMBER;
  l_old_dist_gf NUMBER;
BEGIN
  px_capital_adj := 0;
  px_general_fund := 0;
  l_reval_reserve_ca := 0;
  l_nbv_retired_ca := 0;
  l_nbv_retired_gf := 0;
  l_old_dist_ca := 0;
  l_old_dist_gf := 0;
     BEGIN
      select NVL(SUM(DECODE(DEBIT_CREDIT_FLAG,'DR',-1 * ADJUSTMENT_AMOUNT,ADJUSTMENT_AMOUNT)),0)
      into l_reval_reserve_ca
      from fa_adjustments
      where asset_id = p_asset_id
          and distribution_id = nvl(p_dist_id,distribution_id)
          and period_counter_created = p_period_counter
          and book_type_code = p_book_type_code
          and source_type_code = 'RETIREMENT'
          and adjustment_type = 'REVAL RESERVE';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          l_reval_reserve_ca := 0;
      WHEN OTHERS THEN
          RETURN FALSE;
  END;




  BEGIN
      select NVL(SUM(DECODE(DEBIT_CREDIT_FLAG,'DR',ADJUSTMENT_AMOUNT,-1 * ADJUSTMENT_AMOUNT)),0)
      into l_nbv_retired_ca
      from fa_adjustments
      where asset_id = p_asset_id
          and distribution_id = nvl(p_dist_id,distribution_id)
          and period_counter_created = p_period_counter
          and book_type_code = p_book_type_code
          and source_type_code = 'RETIREMENT'
          and adjustment_type = 'NBV RETIRED';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          l_nbv_retired_ca := 0;
      WHEN OTHERS THEN
          RETURN FALSE;
  END;


  /*8246943 - Value will be same for capital adjustment and general fund*/
  l_nbv_retired_gf := l_nbv_retired_ca;


  IF p_dist_id IS NOT NULL THEN
      BEGIN
          SELECT
            sum(nvl(capital_adjustment,   0)),
            sum(nvl(general_fund,   0))
          INTO
                 l_old_dist_ca,
                 l_old_dist_gf
          FROM FA_DISTRIBUTION_HISTORY dh_old,
            FA_DEPRN_DETAIL sumold
          WHERE dh_old.distribution_id = sumold.distribution_id
           AND dh_old.book_type_code = sumold.book_type_code
           AND dh_old.asset_id = sumold.asset_id
           ANd dh_old.retirement_id is not null
           AND EXISTS
            (SELECT 1
             FROM FA_DISTRIBUTION_HISTORY dh_new
             WHERE dh_new.distribution_id = p_dist_id
             AND dh_new.asset_id = dh_old.asset_id
             AND dh_new.transaction_header_id_in = dh_old.transaction_header_id_out
             AND dh_new.location_id = dh_old.location_id
             AND nvl(dh_new.assigned_to,    -99) = nvl(dh_old.assigned_to,    -99)
             AND dh_new.code_combination_id = dh_old.code_combination_id
             AND dh_new.book_type_code = dh_old.book_type_code
             )
          AND sumold.period_counter =
            (SELECT MAX(period_counter)
             FROM FA_DEPRN_DETAIL
             WHERE book_type_code = p_book_type_code
             AND asset_id = p_asset_id
             AND distribution_id = p_dist_id
             AND period_counter < p_period_counter);
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              l_old_dist_ca := 0;
              l_old_dist_gf := 0;
      END;
  ELSE
      l_old_dist_ca := 0;
      l_old_dist_gf := 0;
  END IF;

  /*Bug#8246943 - placed nvl function around variables*/
  px_capital_adj := nvl(l_nbv_retired_ca,0) + nvl(l_reval_reserve_ca,0) + nvl(l_old_dist_ca,0);
  px_general_fund := nvl(l_nbv_retired_gf,0) + nvl(l_old_dist_gf,0);
     RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
      RETURN FALSE;
END get_retirement_sorp_values;


FUNCTION get_retirement_sorp_mc(
   p_book_type_code IN VARCHAR2,
   p_asset_id IN NUMBER,
   p_dist_id IN NUMBER,
   p_period_counter IN NUMBER,
   px_capital_adj IN OUT NOCOPY NUMBER,
   px_general_fund IN OUT NOCOPY NUMBER,
   p_set_of_books_id IN NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN
IS
   l_reval_reserve_ca NUMBER;
   l_nbv_retired_ca NUMBER;
   l_nbv_retired_gf NUMBER;
   l_old_dist_ca NUMBER;
   l_old_dist_gf NUMBER;
BEGIN
   px_capital_adj := 0;
   px_general_fund := 0;
   l_reval_reserve_ca := 0;
   l_nbv_retired_ca := 0;
   l_nbv_retired_gf := 0;
   l_old_dist_ca := 0;
   l_old_dist_gf := 0;
      BEGIN
       select NVL(SUM(DECODE(DEBIT_CREDIT_FLAG,'DR',-1 * ADJUSTMENT_AMOUNT,ADJUSTMENT_AMOUNT)),0)
       into l_reval_reserve_ca
       from fa_mc_adjustments
       where asset_id = p_asset_id
           and distribution_id = nvl(p_dist_id,distribution_id)
           and period_counter_created = p_period_counter
           and book_type_code = p_book_type_code
           and source_type_code = 'RETIREMENT'
           and adjustment_type = 'REVAL RESERVE'
	   and set_of_books_id = p_set_of_books_id;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           l_reval_reserve_ca := 0;
       WHEN OTHERS THEN
           RETURN FALSE;
   END;


   BEGIN
       select NVL(SUM(DECODE(DEBIT_CREDIT_FLAG,'DR',ADJUSTMENT_AMOUNT,-1 * ADJUSTMENT_AMOUNT)),0)
       into l_nbv_retired_ca
       from fa_mc_adjustments
       where asset_id = p_asset_id
           and distribution_id = nvl(p_dist_id,distribution_id)
           and period_counter_created = p_period_counter
           and book_type_code = p_book_type_code
           and source_type_code = 'RETIREMENT'
           and adjustment_type = 'NBV RETIRED'
	   and set_of_books_id = p_set_of_books_id;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           l_nbv_retired_ca := 0;
       WHEN OTHERS THEN
           RETURN FALSE;
   END;


   /*8246943 - Value will be same for capital adjustment and general fund*/
  l_nbv_retired_gf := l_nbv_retired_ca;


   IF p_dist_id IS NOT NULL THEN

   BEGIN
       SELECT
         sum(nvl(capital_adjustment,   0)),
         sum(nvl(general_fund,   0))
       INTO
              l_old_dist_ca,
              l_old_dist_gf
       FROM FA_DISTRIBUTION_HISTORY dh_old,
         FA_MC_DEPRN_DETAIL sumold
       WHERE dh_old.distribution_id = sumold.distribution_id
        AND dh_old.book_type_code = sumold.book_type_code
        AND dh_old.asset_id = sumold.asset_id
        ANd dh_old.retirement_id is not null
	AND sumold.set_of_books_id = p_set_of_books_id
        AND EXISTS
         (SELECT 1
          FROM FA_DISTRIBUTION_HISTORY dh_new
          WHERE dh_new.distribution_id = p_dist_id
          AND dh_new.asset_id = dh_old.asset_id
          AND dh_new.transaction_header_id_in = dh_old.transaction_header_id_out
          AND dh_new.location_id = dh_old.location_id
          AND nvl(dh_new.assigned_to,    -99) = nvl(dh_old.assigned_to,    -99)
          AND dh_new.code_combination_id = dh_old.code_combination_id
          AND dh_new.book_type_code = dh_old.book_type_code
          )
       AND sumold.period_counter =
         (SELECT MAX(period_counter)
          FROM FA_MC_DEPRN_DETAIL
          WHERE book_type_code = p_book_type_code
          AND asset_id = p_asset_id
          AND distribution_id = p_dist_id
          AND period_counter < p_period_counter
	  AND set_of_books_id=p_set_of_books_id);
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           l_old_dist_ca := 0;
           l_old_dist_gf := 0;
   END;
   ELSE
      l_old_dist_ca := 0;
      l_old_dist_gf := 0;
  END IF;


   /*Bug#8246943 - placed nvl function around variables*/
   px_capital_adj := nvl(l_nbv_retired_ca,0) + nvl(l_reval_reserve_ca,0) + nvl(l_old_dist_ca,0);
   px_general_fund := nvl(l_nbv_retired_gf,0) + nvl(l_old_dist_gf,0);
      RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
       RETURN FALSE;
END get_retirement_sorp_mc;


   FUNCTION fa_category_impl (
      p_book                fa_books.book_type_code%TYPE,
      p_acct_flex_struct    NUMBER,
      p_capital_adj_acct    VARCHAR2,
      p_general_fund_acct   VARCHAR2,
      p_run_mode            VARCHAR2
   )
      RETURN BOOLEAN
   IS
      CURSOR c_category_cur
      IS
         SELECT book_type_code, category_id, reval_amortization_acct,
                reval_amort_account_ccid, impair_expense_acct,
                impair_expense_account_ccid, impair_reserve_acct,
                impair_reserve_account_ccid
           FROM fa_category_books
          WHERE book_type_code = p_book
            AND (capital_adj_acct IS NULL OR general_fund_acct IS NULL);

--type v_category_cur is c_category_cur%rowtype;
      TYPE v_category_tab_type IS TABLE OF c_category_cur%ROWTYPE;

      v_category_tab                v_category_tab_type;
      l_imp_acct_chk_flag           VARCHAR2 (1)          := 'I';
      l_reval_amort_acct_chk_flag   VARCHAR2 (1)          := 'R';
      l_success_chk_flag            VARCHAR2 (1)          := 'Y';
      v_capital_adj_acct            NUMBER;
      v_capital_adj_ccid            NUMBER;
      v_general_fund_acct           NUMBER;
      v_general_fund_ccid           NUMBER;

      CURSOR c_final_cur
      IS
         SELECT category_id, capital_adj_acct, capital_adj_account_ccid,
                general_fund_acct, general_fund_account_ccid
           FROM fa_sorp_upg_cat
          WHERE book_type_code = p_book AND validation_flag <> 'I';

      v_final_cur                   c_final_cur%ROWTYPE;
      l_cat_struct                  NUMBER;
      l_category_name               VARCHAR2 (1000);
      p_error_code                  VARCHAR2 (100);
      p_status_msg                  VARCHAR2 (100);
   BEGIN
      p_error_code := 0;
      p_status_msg := 'SUCCESS';
-- Get Capital Adjustment CCID and Account
      v_capital_adj_ccid := get_ccid (p_acct_flex_struct, p_capital_adj_acct);
      v_capital_adj_acct :=
                     get_account_seg (p_acct_flex_struct, v_capital_adj_ccid);
-- Get General Fund CCID and Account
      v_general_fund_ccid :=
                           get_ccid (p_acct_flex_struct, p_general_fund_acct);
      v_general_fund_acct :=
                    get_account_seg (p_acct_flex_struct, v_general_fund_ccid);
--Get category flex structure
      l_cat_struct := get_flex_struct ('CAT');

      DELETE FROM fa_sorp_upg_cat;

      COMMIT;

      OPEN c_category_cur;

      FETCH c_category_cur
      BULK COLLECT INTO v_category_tab;

      IF c_category_cur%ROWCOUNT = 0
      THEN
         RETURN TRUE;
      END IF;

      CLOSE c_category_cur;

      FOR i IN v_category_tab.FIRST .. v_category_tab.LAST
      LOOP
         -- get category name
         l_category_name := get_cat_flex (v_category_tab (i).category_id);

         IF    v_category_tab (i).impair_expense_acct IS NULL
            OR v_category_tab (i).impair_reserve_acct IS NULL
         THEN
            INSERT INTO fa_sorp_upg_cat
                        (book_type_code,
                         category_id,
                         reval_amortization_acct,
                         reval_amort_account_ccid,
                         impair_expense_acct,
                         impair_expense_account_ccid,
                         impair_reserve_acct,
                         impair_reserve_account_ccid,
                         capital_adj_acct, capital_adj_account_ccid,
                         general_fund_acct, general_fund_account_ccid,
                         validation_flag, category_flex, run_mode,
                         run_date
                        )
                 VALUES (v_category_tab (i).book_type_code,
                         v_category_tab (i).category_id,
                         v_category_tab (i).reval_amortization_acct,
                         v_category_tab (i).reval_amort_account_ccid,
                         v_category_tab (i).impair_expense_acct,
                         v_category_tab (i).impair_expense_account_ccid,
                         v_category_tab (i).impair_reserve_acct,
                         v_category_tab (i).impair_reserve_account_ccid,
                         v_capital_adj_acct, v_capital_adj_ccid,
                         v_general_fund_acct, v_general_fund_ccid,
                         l_imp_acct_chk_flag, l_category_name, p_run_mode,
                         SYSDATE
                        );
         ELSIF (   (v_category_tab (i).reval_amortization_acct <>
                                                            v_capital_adj_acct
                   )
                OR (v_category_tab (i).reval_amort_account_ccid <>
                                                            v_capital_adj_ccid
                   )
               )
         THEN
            INSERT INTO fa_sorp_upg_cat
                        (book_type_code,
                         category_id,
                         reval_amortization_acct,
                         reval_amort_account_ccid,
                         impair_expense_acct,
                         impair_expense_account_ccid,
                         impair_reserve_acct,
                         impair_reserve_account_ccid,
                         capital_adj_acct, capital_adj_account_ccid,
                         general_fund_acct, general_fund_account_ccid,
                         validation_flag, category_flex,
                         run_mode, run_date
                        )
                 VALUES (v_category_tab (i).book_type_code,
                         v_category_tab (i).category_id,
                         v_category_tab (i).reval_amortization_acct,
                         v_category_tab (i).reval_amort_account_ccid,
                         v_category_tab (i).impair_expense_acct,
                         v_category_tab (i).impair_expense_account_ccid,
                         v_category_tab (i).impair_reserve_acct,
                         v_category_tab (i).impair_reserve_account_ccid,
                         v_capital_adj_acct, v_capital_adj_ccid,
                         v_general_fund_acct, v_general_fund_ccid,
                         l_reval_amort_acct_chk_flag, l_category_name,
                         p_run_mode, SYSDATE
                        );
         ELSE
            INSERT INTO fa_sorp_upg_cat
                        (book_type_code,
                         category_id,
                         reval_amortization_acct,
                         reval_amort_account_ccid,
                         impair_expense_acct,
                         impair_expense_account_ccid,
                         impair_reserve_acct,
                         impair_reserve_account_ccid,
                         capital_adj_acct, capital_adj_account_ccid,
                         general_fund_acct, general_fund_account_ccid,
                         validation_flag, category_flex, run_mode,
                         run_date
                        )
                 VALUES (v_category_tab (i).book_type_code,
                         v_category_tab (i).category_id,
                         v_category_tab (i).reval_amortization_acct,
                         v_category_tab (i).reval_amort_account_ccid,
                         v_category_tab (i).impair_expense_acct,
                         v_category_tab (i).impair_expense_account_ccid,
                         v_category_tab (i).impair_reserve_acct,
                         v_category_tab (i).impair_reserve_account_ccid,
                         v_capital_adj_acct, v_capital_adj_ccid,
                         v_general_fund_acct, v_general_fund_ccid,
                         l_success_chk_flag, l_category_name, p_run_mode,
                         SYSDATE
                        );
         END IF;
      END LOOP;

      COMMIT;

      IF p_run_mode = 'PREVIEW'
      THEN
         RETURN TRUE;
      END IF;

      IF p_run_mode = 'FINAL'
      THEN
         OPEN c_final_cur;

         LOOP
            FETCH c_final_cur
             INTO v_final_cur;

            EXIT WHEN c_final_cur%NOTFOUND;

            UPDATE fa_category_books
               SET capital_adj_acct = v_final_cur.capital_adj_acct,
                   capital_adj_account_ccid =
                                          v_final_cur.capital_adj_account_ccid,
                   general_fund_acct = v_final_cur.general_fund_acct,
                   general_fund_account_ccid =
                                         v_final_cur.general_fund_account_ccid,
                   last_update_date = SYSDATE
             WHERE book_type_code = p_book
               AND category_id = v_final_cur.category_id;
         END LOOP;

         CLOSE c_final_cur;

         COMMIT;
         RETURN TRUE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_error_code := SQLCODE;
         p_status_msg := SQLERRM;
         RETURN FALSE;
   END fa_category_impl;

   FUNCTION fa_sorp_reval_chk_fn (p_book_type_code VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN
   IS
      v_period_counter   NUMBER;
      v_period_name      VARCHAR2 (30);
      v_asset_id         NUMBER;
      v_asset_number     VARCHAR2 (50);
      v_category_id      NUMBER;
      v_category_name    VARCHAR2 (250);
      v_apr_reval_rsv    NUMBER;
      v_reval_rsv        NUMBER;
      l_message          VARCHAR2 (500);
      l_status_code      VARCHAR2 (5);

      CURSOR c_cal_per
      IS
         SELECT fadep.period_counter, facalp.period_name
           FROM fa_calendar_periods facalp,
                fa_deprn_periods fadep,
                fa_book_controls fabkctl
          WHERE facalp.calendar_type = fabkctl.deprn_calendar
            AND fabkctl.book_type_code = p_book_type_code
            AND fadep.book_type_code = fabkctl.book_type_code
            AND facalp.period_name = fadep.period_name
            AND TO_DATE ('01-04-07', 'DD-MM-YY')
                   BETWEEN TO_DATE (TO_CHAR (facalp.start_date, 'DD-MM-YY'),
                                    'DD-MM-YY'
                                   )
                       AND TO_DATE (TO_CHAR (facalp.end_date, 'DD-MM-YY'),
                                    'DD-MM-YY'
                                   );

      CURSOR c_asset_cur
      IS
         SELECT DISTINCT dep.asset_id, adda.asset_number,
                         adda.asset_category_id,
                         adda.attribute_category_code category_name
                    FROM fa_deprn_summary dep, fa_additions_v adda
                   WHERE adda.asset_id = dep.asset_id
                     AND book_type_code = p_book_type_code;

      CURSOR c_deprn_apr_cur
      IS
         SELECT reval_reserve
           FROM (SELECT   dep.reval_reserve
                     FROM fa_deprn_summary dep
                    WHERE dep.book_type_code = p_book_type_code
                      AND dep.asset_id = v_asset_id
                      AND dep.period_counter < v_period_counter
                 ORDER BY dep.period_counter DESC)
          WHERE ROWNUM < 2;

      CURSOR c_deprn_cur
      IS
         SELECT dep.reval_reserve
           FROM fa_deprn_summary dep
          WHERE dep.book_type_code = p_book_type_code
            AND dep.asset_id = v_asset_id
            AND dep.period_counter =
                   (SELECT   MAX (period_counter)
                        FROM fa_deprn_summary
                       WHERE book_type_code = p_book_type_code
                         AND asset_id = v_asset_id
                    GROUP BY asset_id);
   BEGIN
      DELETE FROM fa_sorp_reval_chk;

      COMMIT;

      OPEN c_asset_cur;

      LOOP
         FETCH c_asset_cur
          INTO v_asset_id, v_asset_number, v_category_id, v_category_name;

         EXIT WHEN c_asset_cur%NOTFOUND;

         OPEN c_cal_per;

         FETCH c_cal_per
          INTO v_period_counter, v_period_name;

         CLOSE c_cal_per;

         IF v_period_counter IS NOT NULL
         THEN
            OPEN c_deprn_apr_cur;

            FETCH c_deprn_apr_cur
             INTO v_apr_reval_rsv;

            CLOSE c_deprn_apr_cur;

            IF v_apr_reval_rsv IS NULL
            THEN
               l_message := 'SUCCESS';
               l_status_code := 'SD';
            END IF;
         ELSE
            l_message := 'SUCCESS';
            l_status_code := 'SP';
         END IF;

         IF (l_message IS NULL) AND (v_apr_reval_rsv <> 0)
         THEN
            l_message :=
                        'FAILED:Revaluation reserve on 01-APR-07 is not zero';
            l_status_code := 'ARSV';
         END IF;

         OPEN c_deprn_cur;

         FETCH c_deprn_cur
          INTO v_reval_rsv;

         CLOSE c_deprn_cur;

         IF (v_reval_rsv < 0)
         THEN
            l_message := 'FAILED:Current revaluation reserve is negative';
            l_status_code := 'CRSV';
         END IF;

         IF (l_message IS NULL)
         THEN
            l_message := 'SUCCESS';
            l_status_code := 'S';
         END IF;

         INSERT INTO fa_sorp_reval_chk
                     (book_type_code, category_id, category_name,
                      asset_id, asset_number, apr_reval_rsv,
                      reval_rsv, status_code, status
                     )
              VALUES (p_book_type_code, v_category_id, v_category_name,
                      v_asset_id, v_asset_number, v_apr_reval_rsv,
                      v_reval_rsv, l_status_code, l_message
                     );

         l_message := NULL;
         l_status_code := NULL;
      END LOOP;

      CLOSE c_asset_cur;

      COMMIT;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN FALSE;
   END fa_sorp_reval_chk_fn;

    FUNCTION fa_sorp_upg_cagf_mc_fn (p_book_type_code VARCHAR2, p_mode VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN
   IS
      l_deprn_rsv                     NUMBER;
      l_impairment_rsv                NUMBER;
      l_reval_rsv                     NUMBER;
      dummy_char                      VARCHAR2 (10);
      dummy_bool                      BOOLEAN;
      dummy_num                       NUMBER;
      v_asset_id                      NUMBER;
      v_capital_adj_amount            NUMBER;
      v_general_fund_amount           NUMBER;
      v_capital_adj_summary_amount    NUMBER;
      v_general_fund_summary_amount   NUMBER;

      CURSOR c_asset_cur
      IS
         SELECT DISTINCT adda.asset_id, adda.asset_number,
                         adda.description asset_description,
                         adda.asset_category_id,
                         adda.attribute_category_code category_name
                    FROM FA_MC_DEPRN_SUMMARY dep, fa_additions_v adda
                   WHERE adda.asset_id = dep.asset_id
                     AND book_type_code = p_book_type_code;

      v_asset_cur                     c_asset_cur%ROWTYPE;

      CURSOR c_book_cur
      IS
         SELECT date_placed_in_service, COST current_cost
           FROM fa_books_v
          WHERE book_type_code = p_book_type_code AND asset_id = v_asset_id;

      v_book_cur                      c_book_cur%ROWTYPE;

      CURSOR c_deprn_cur
      IS
         SELECT   distribution_id, deprn_reserve, deprn_amount,
                  reval_amortization, impairment_amount, period_counter,set_of_books_id
             FROM FA_MC_DEPRN_DETAIL
            WHERE book_type_code = p_book_type_code AND asset_id = v_asset_id
         ORDER BY SET_OF_BOOKS_ID ASC,period_counter;

      v_deprn_cur                     c_deprn_cur%ROWTYPE;

      CURSOR c_deprn_summary_cur
      IS
         SELECT   deprn_reserve, deprn_amount, reval_amortization,
                  impairment_amount, period_counter,set_of_books_id
             FROM FA_MC_DEPRN_SUMMARY
            WHERE book_type_code = p_book_type_code AND asset_id = v_asset_id
         ORDER BY SET_OF_BOOKS_ID ASC,period_counter;

      v_deprn_summary_cur             c_deprn_summary_cur%ROWTYPE;

          cursor c_fa_sorp_upg_cagf_hist_cur is
          select                                        book_type_code ,
                                asset_id,
                                asset_number ,
                                asset_description,
                                date_placed_in_service,
                                category_name,
                                current_cost,
                                depriciation_reserve,
                                revaluation_reserve,
                                impairment_reserve,
                                capital_adjustment_acct_amount,
                                general_fund_acct_amount
                from fa_sorp_upg_cagf;

                v_fa_sorp_upg_cagf_hist_cur c_fa_sorp_upg_cagf_hist_cur%rowtype;

                l_request_id number;
                v_final_cnt number;
                v_period_name varchar2(25);



                l_imp_cap_det_value number;
                l_imp_gen_det_value number;
                l_imp_cap_sum_value number;
                l_imp_gen_sum_value number;

                l_ret_cap_det_value number;
                l_ret_gen_det_value number;
                l_ret_cap_sum_value number;
                l_ret_gen_sum_value number;

		l_old_sob_id NUMBER;

   BEGIN
      DELETE FROM fa_sorp_upg_cagf;

      COMMIT;

           l_request_id :=  fnd_global.conc_request_id;

        p_from := 'fa_sorp_upg_cagf';
        p_where := ' where 1=1';
        p_order_by := 'order by category_name'; -- Bug#7632825
        P_REQUEST_WHERE := ' AND REQUEST_ID <> '||l_request_id;

      OPEN c_asset_cur;

      LOOP
         FETCH c_asset_cur
          INTO v_asset_cur;

         EXIT WHEN c_asset_cur%NOTFOUND;
         v_asset_id := v_asset_cur.asset_id;

         OPEN c_book_cur;

         FETCH c_book_cur
          INTO v_book_cur;

         CLOSE c_book_cur;

         fa_query_balances_pkg.query_balances
                          (x_asset_id                   => v_asset_cur.asset_id,
                           x_book                       => p_book_type_code,
                           x_period_ctr                 => 0,
                           x_dist_id                    => 0,
                           x_run_mode                   => 'STANDARD',
                           x_cost                       => dummy_num,
                           x_deprn_rsv                  => l_deprn_rsv,
                           x_reval_rsv                  => l_reval_rsv,
                           x_ytd_deprn                  => dummy_num,
                           x_ytd_reval_exp              => dummy_num,
                           x_reval_deprn_exp            => dummy_num,
                           x_deprn_exp                  => dummy_num,
                           x_reval_amo                  => dummy_num,
                           x_prod                       => dummy_num,
                           x_ytd_prod                   => dummy_num,
                           x_ltd_prod                   => dummy_num,
                           x_adj_cost                   => dummy_num,
                           x_reval_amo_basis            => dummy_num,
                           x_bonus_rate                 => dummy_num,
                           x_deprn_source_code          => dummy_char,
                           x_adjusted_flag              => dummy_bool,
                           x_transaction_header_id      => -1,
                           x_bonus_deprn_rsv            => dummy_num,
                           x_bonus_ytd_deprn            => dummy_num,
                           x_bonus_deprn_amount         => dummy_num,
                           x_impairment_rsv             => l_impairment_rsv,
                                                                 --Bug#7293626
                           x_ytd_impairment             => dummy_num,
                           x_impairment_amount          => dummy_num,
                           x_capital_adjustment         => dummy_num,
                           x_general_fund               => dummy_num,
                           x_mrc_sob_type_code          => 'P',
                           x_set_of_books_id            => null
                          , p_log_level_rec => p_log_level_rec);
         l_old_sob_id := 0;
         OPEN c_deprn_cur;

         LOOP
            FETCH c_deprn_cur
             INTO v_deprn_cur;

            EXIT WHEN c_deprn_cur%NOTFOUND;



                                if  not get_impairment_sorp_mc
                                                                        (p_book_type_code,
                                                                         v_asset_id,
                                                                         v_deprn_cur.distribution_id,
                                                                         v_deprn_cur.period_counter,
                                                                         'D',
                                                                         l_imp_cap_det_value,
                                                                         l_imp_gen_det_value,
									 v_deprn_cur.set_of_books_id) then
                                        return false;
                                end if;


                                if  not get_retirement_sorp_mc
                                                                        (p_book_type_code,
                                                                         v_asset_id,
                                                                         v_deprn_cur.distribution_id,
                                                                         v_deprn_cur.period_counter,
                                                                         l_ret_cap_det_value,
                                                                         l_ret_gen_det_value,
									 v_deprn_cur.set_of_books_id) then
                                        return false;
                                end if;





            IF c_deprn_cur%ROWCOUNT = 1  or (l_old_sob_id <> v_deprn_cur.set_of_books_id )
	    THEN
               v_capital_adj_amount :=
                    NVL (v_deprn_cur.deprn_reserve, 0)
                  + NVL (v_deprn_cur.impairment_amount, 0)
                  - NVL (v_deprn_cur.reval_amortization, 0)
                                  + NVL (l_imp_cap_det_value,0)
                                  + NVL(l_ret_cap_det_value,0);
               v_general_fund_amount :=
                    NVL (v_deprn_cur.deprn_reserve, 0)
                  + NVL (v_deprn_cur.impairment_amount, 0)
                                  + NVL(l_ret_gen_det_value,0);

               l_old_sob_id := v_deprn_cur.set_of_books_id;

               IF p_mode = 'FINAL'
               THEN
                  UPDATE FA_MC_DEPRN_DETAIL
                     SET capital_adjustment = v_capital_adj_amount,
                         general_fund = v_general_fund_amount
                   WHERE distribution_id = v_deprn_cur.distribution_id
                     AND book_type_code = p_book_type_code
                     AND period_counter = v_deprn_cur.period_counter
		     AND set_of_books_id = v_deprn_cur.set_of_books_id;
               END IF;
            ELSE
               v_capital_adj_amount :=
                    NVL (v_capital_adj_amount, 0)
                  + NVL (v_deprn_cur.deprn_amount, 0)
                  + NVL (v_deprn_cur.impairment_amount, 0)
                  - NVL (v_deprn_cur.reval_amortization, 0)
                                  + NVL (l_imp_cap_det_value,0)
                                  + NVL(l_ret_cap_det_value,0);
               v_general_fund_amount :=
                    NVL (v_general_fund_amount, 0)
                  + NVL (v_deprn_cur.deprn_amount, 0)
                  + NVL (v_deprn_cur.impairment_amount, 0)
                                  + NVL(l_ret_gen_det_value,0);

               IF p_mode = 'FINAL'
               THEN
                  UPDATE FA_MC_DEPRN_DETAIL
                     SET capital_adjustment = v_capital_adj_amount,
                         general_fund = v_general_fund_amount
                   WHERE distribution_id = v_deprn_cur.distribution_id
                     AND book_type_code = p_book_type_code
                     AND period_counter = v_deprn_cur.period_counter
		     AND set_of_books_id = v_deprn_cur.set_of_books_id;
               END IF;
            END IF;
         END LOOP;

         CLOSE c_deprn_cur;



         IF p_mode = 'FINAL'
         THEN
	    l_old_sob_id := 0;
            OPEN c_deprn_summary_cur;

            LOOP
               FETCH c_deprn_summary_cur
                INTO v_deprn_summary_cur;

               EXIT WHEN c_deprn_summary_cur%NOTFOUND;


                                                if  not get_impairment_sorp_mc
                                                                        (p_book_type_code,
                                                                         v_asset_id,
                                                                         NULL,
                                                                         v_deprn_summary_cur.period_counter,
                                                                         'S',
                                                                         l_imp_cap_sum_value,
                                                                         l_imp_gen_sum_value,
									 v_deprn_summary_cur.set_of_books_id) then
                                                        return false;
                                                end if;

                                                if  not get_retirement_sorp_mc
                                                                        (p_book_type_code,
                                                                         v_asset_id,
                                                                         NULL,
                                                                         v_deprn_summary_cur.period_counter,
                                                                         l_ret_cap_det_value,
                                                                         l_ret_gen_det_value,
									 v_deprn_summary_cur.set_of_books_id) then
                                        return false;
                                end if;




               IF c_deprn_summary_cur%ROWCOUNT = 1 or (l_old_sob_id <> v_deprn_summary_cur.set_of_books_id)
	       THEN
                  v_capital_adj_summary_amount :=
                       NVL (v_deprn_summary_cur.deprn_reserve, 0)
                     + NVL (v_deprn_summary_cur.impairment_amount, 0)
                     - NVL (v_deprn_summary_cur.reval_amortization, 0)
                                         + NVL(l_imp_cap_sum_value,0)
                                         + NVL(l_ret_cap_det_value,0);

                  v_general_fund_summary_amount :=
                       NVL (v_deprn_summary_cur.deprn_reserve, 0)
                     + NVL (v_deprn_summary_cur.impairment_amount, 0)
                     + NVL(l_ret_gen_det_value,0);

                 l_old_sob_id := v_deprn_summary_cur.set_of_books_id;

                  UPDATE FA_MC_DEPRN_SUMMARY
                     SET capital_adjustment = v_capital_adj_summary_amount,
                         general_fund = v_general_fund_summary_amount
                   WHERE asset_id = v_asset_id
                     AND book_type_code = p_book_type_code
                     AND period_counter = v_deprn_summary_cur.period_counter
		     AND set_of_books_id = v_deprn_summary_cur.set_of_books_id;
               ELSE
                  v_capital_adj_summary_amount :=
                       NVL (v_capital_adj_summary_amount, 0)
                     + NVL (v_deprn_summary_cur.deprn_amount, 0)
                     + NVL (v_deprn_summary_cur.impairment_amount, 0)
                     - NVL (v_deprn_summary_cur.reval_amortization, 0)
                                         + NVL(l_imp_cap_sum_value,0)
                                         + NVL(l_ret_cap_det_value,0);
                  v_general_fund_summary_amount :=
                       NVL (v_general_fund_summary_amount, 0)
                     + NVL (v_deprn_summary_cur.deprn_amount, 0)
                     + NVL (v_deprn_summary_cur.impairment_amount, 0)
                     + NVL(l_ret_gen_det_value,0);

                  UPDATE FA_MC_DEPRN_SUMMARY
                     SET capital_adjustment = v_capital_adj_summary_amount,
                         general_fund = v_general_fund_summary_amount
                   WHERE asset_id = v_asset_id
                     AND book_type_code = p_book_type_code
                     AND period_counter = v_deprn_summary_cur.period_counter
		     AND set_of_books_id = v_deprn_summary_cur.set_of_books_id;
               END IF;
            END LOOP;

            CLOSE c_deprn_summary_cur;
         END IF;

         INSERT INTO fa_sorp_upg_cagf
                     (book_type_code, asset_id, asset_number,
                      asset_description,
                      date_placed_in_service,
                      category_name, current_cost,
                      depriciation_reserve, revaluation_reserve,
                      impairment_reserve, capital_adjustment_acct_amount,
                      general_fund_acct_amount
                     )
              VALUES (p_book_type_code, v_asset_id, v_asset_cur.asset_number,
                      v_asset_cur.asset_description,
                      v_book_cur.date_placed_in_service,
                      v_asset_cur.category_name, v_book_cur.current_cost,
                      l_deprn_rsv, l_reval_rsv,
                      l_impairment_rsv, v_capital_adj_amount,
                      v_general_fund_amount
                     );

         v_capital_adj_amount := 0;
         v_general_fund_amount := 0;
      END LOOP;

      CLOSE c_asset_cur;

          IF p_mode = 'FINAL' then



                   select period_name into v_period_name
                   from fa_deprn_periods
                   where book_type_code = P_FA_BOOK
                   and period_close_date is null;

                        open c_fa_sorp_upg_cagf_hist_cur;
                        loop
                                fetch c_fa_sorp_upg_cagf_hist_cur into v_fa_sorp_upg_cagf_hist_cur;
                                exit when c_fa_sorp_upg_cagf_hist_cur%notfound;

                                    INSERT INTO fa_sorp_upg_cagf_hist
                     (book_type_code,
                                          asset_id,
                                          asset_number,
                      asset_description,
                      date_placed_in_service,
                      category_name,
                                          current_cost,
                      depriciation_reserve,
                                          revaluation_reserve,
                      impairment_reserve,
                                          capital_adjustment_acct_amount,
                      general_fund_acct_amount,
                                          request_id,
                                          report_mode,
                                          period_name
                     )
                                        VALUES
                                          (v_fa_sorp_upg_cagf_hist_cur.book_type_code,
                                          v_fa_sorp_upg_cagf_hist_cur.asset_id,
                                          v_fa_sorp_upg_cagf_hist_cur.asset_number,
                      v_fa_sorp_upg_cagf_hist_cur.asset_description,
                      v_fa_sorp_upg_cagf_hist_cur.date_placed_in_service,
                      v_fa_sorp_upg_cagf_hist_cur.category_name,
                                          v_fa_sorp_upg_cagf_hist_cur.current_cost,
                      v_fa_sorp_upg_cagf_hist_cur.depriciation_reserve,
                                          v_fa_sorp_upg_cagf_hist_cur.revaluation_reserve,
                      v_fa_sorp_upg_cagf_hist_cur.impairment_reserve,
                                          v_fa_sorp_upg_cagf_hist_cur.capital_adjustment_acct_amount,
                      v_fa_sorp_upg_cagf_hist_cur.general_fund_acct_amount,
                                          l_request_id,
                                          p_mode,
                                          v_period_name);
                        end loop;
                        close c_fa_sorp_upg_cagf_hist_cur;

          END IF;


      COMMIT;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN FALSE;
   END fa_sorp_upg_cagf_mc_fn;

   FUNCTION fa_sorp_upg_cagf_fn (p_book_type_code VARCHAR2, p_mode VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN
   IS
      l_deprn_rsv                     NUMBER;
      l_impairment_rsv                NUMBER;
      l_reval_rsv                     NUMBER;
      dummy_char                      VARCHAR2 (10);
      dummy_bool                      BOOLEAN;
      dummy_num                       NUMBER;
      v_asset_id                      NUMBER;
      v_capital_adj_amount            NUMBER;
      v_general_fund_amount           NUMBER;
      v_capital_adj_summary_amount    NUMBER;
      v_general_fund_summary_amount   NUMBER;

          V_BOOLEAN BOOLEAN;

      CURSOR c_asset_cur
      IS
         SELECT DISTINCT adda.asset_id, adda.asset_number,
                         adda.description asset_description,
                         adda.asset_category_id,
                         adda.attribute_category_code category_name
                    FROM fa_deprn_summary dep, fa_additions_v adda
                   WHERE adda.asset_id = dep.asset_id
                     AND book_type_code = p_book_type_code;

      v_asset_cur                     c_asset_cur%ROWTYPE;

      CURSOR c_book_cur
      IS
         SELECT date_placed_in_service, COST current_cost
           FROM fa_books_v
          WHERE book_type_code = p_book_type_code AND asset_id = v_asset_id;

      v_book_cur                      c_book_cur%ROWTYPE;

      CURSOR c_deprn_cur
      IS
         SELECT   distribution_id, deprn_reserve, deprn_amount,
                  reval_amortization, impairment_amount, period_counter
             FROM fa_deprn_detail
            WHERE book_type_code = p_book_type_code AND asset_id = v_asset_id
         ORDER BY period_counter;

      v_deprn_cur                     c_deprn_cur%ROWTYPE;

      CURSOR c_deprn_summary_cur
      IS
         SELECT   deprn_reserve, deprn_amount, reval_amortization,
                  impairment_amount, period_counter
             FROM fa_deprn_summary
            WHERE book_type_code = p_book_type_code AND asset_id = v_asset_id
         ORDER BY period_counter;

      v_deprn_summary_cur             c_deprn_summary_cur%ROWTYPE;

          cursor c_fa_sorp_upg_cagf_hist_cur is
          select                                        book_type_code ,
                                asset_id,
                                asset_number ,
                                asset_description,
                                date_placed_in_service,
                                category_name,
                                current_cost,
                                depriciation_reserve,
                                revaluation_reserve,
                                impairment_reserve,
                                capital_adjustment_acct_amount,
                                general_fund_acct_amount
                from fa_sorp_upg_cagf;

                v_fa_sorp_upg_cagf_hist_cur c_fa_sorp_upg_cagf_hist_cur%rowtype;

                l_request_id number;
                v_final_cnt number;
                v_period_name varchar2(25);



                l_imp_cap_det_value number;
                l_imp_gen_det_value number;
                l_imp_cap_sum_value number;
                l_imp_gen_sum_value number;

                l_ret_cap_det_value number;
                l_ret_gen_det_value number;
                l_ret_cap_sum_value number;
                l_ret_gen_sum_value number;

   BEGIN

    fa_srvr_msg.Init_Server_Message; -- Initialize server message stack
   fa_debug_pkg.Initialize;         -- Initialize debug message stack
 fa_debug_pkg.add('fa_sorp_upg_cagf_fn', 'process calculation', 'BEGINs', p_log_level_rec => p_log_level_rec);


      DELETE FROM fa_sorp_upg_cagf;

      COMMIT;

           l_request_id :=  fnd_global.conc_request_id;

        p_from := 'fa_sorp_upg_cagf';
        p_where := ' where 1=1';
        p_order_by := 'order by category_name'; -- Bug#7632825
        P_REQUEST_WHERE := ' AND REQUEST_ID <> '||l_request_id;



        select count(1) into v_final_cnt
        from fa_sorp_upg_cagf_hist
        where book_type_code = p_book_type_code
        and report_mode = p_mode;

        IF v_final_cnt = 0 then


      OPEN c_asset_cur;

      LOOP
         FETCH c_asset_cur
          INTO v_asset_cur;

         EXIT WHEN c_asset_cur%NOTFOUND;
         v_asset_id := v_asset_cur.asset_id;

         OPEN c_book_cur;

         FETCH c_book_cur
          INTO v_book_cur;

         CLOSE c_book_cur;

         fa_query_balances_pkg.query_balances
                          (x_asset_id                   => v_asset_cur.asset_id,
                           x_book                       => p_book_type_code,
                           x_period_ctr                 => 0,
                           x_dist_id                    => 0,
                           x_run_mode                   => 'STANDARD',
                           x_cost                       => dummy_num,
                           x_deprn_rsv                  => l_deprn_rsv,
                           x_reval_rsv                  => l_reval_rsv,
                           x_ytd_deprn                  => dummy_num,
                           x_ytd_reval_exp              => dummy_num,
                           x_reval_deprn_exp            => dummy_num,
                           x_deprn_exp                  => dummy_num,
                           x_reval_amo                  => dummy_num,
                           x_prod                       => dummy_num,
                           x_ytd_prod                   => dummy_num,
                           x_ltd_prod                   => dummy_num,
                           x_adj_cost                   => dummy_num,
                           x_reval_amo_basis            => dummy_num,
                           x_bonus_rate                 => dummy_num,
                           x_deprn_source_code          => dummy_char,
                           x_adjusted_flag              => dummy_bool,
                           x_transaction_header_id      => -1,
                           x_bonus_deprn_rsv            => dummy_num,
                           x_bonus_ytd_deprn            => dummy_num,
                           x_bonus_deprn_amount         => dummy_num,
                           x_impairment_rsv             => l_impairment_rsv,
                                                                 --Bug#7293626
                           x_ytd_impairment             => dummy_num,
                           x_impairment_amount          => dummy_num,
                           x_capital_adjustment         => dummy_num,
                           x_general_fund               => dummy_num,
                           x_mrc_sob_type_code          => 'P',
                           x_set_of_books_id            => null
                          , p_log_level_rec => p_log_level_rec);

         OPEN c_deprn_cur;

         LOOP
            FETCH c_deprn_cur
             INTO v_deprn_cur;

            EXIT WHEN c_deprn_cur%NOTFOUND;

                        if  not get_impairment_sorp_values
                                                                        (p_book_type_code,
                                                                         v_asset_id,
                                                                         v_deprn_cur.distribution_id,
                                                                         v_deprn_cur.period_counter,
                                                                         'D',
                                                                         l_imp_cap_det_value,
                                                                         l_imp_gen_det_value) then
                                return false;
                        end if;


                        if  not get_retirement_sorp_values
                                                                        (p_book_type_code,
                                                                         v_asset_id,
                                                                         v_deprn_cur.distribution_id,
                                                                         v_deprn_cur.period_counter,
                                                                         l_ret_cap_det_value,
                                                                         l_ret_gen_det_value) then
                                return false;
                        end if;



            IF c_deprn_cur%ROWCOUNT = 1
            THEN
               v_capital_adj_amount :=
                    NVL (v_deprn_cur.deprn_reserve, 0)
                  + NVL (v_deprn_cur.impairment_amount, 0)
                  - NVL (v_deprn_cur.reval_amortization, 0)
                                  + NVL (l_imp_cap_det_value,0)
                                  + NVL(l_ret_cap_det_value,0);
               v_general_fund_amount :=
                    NVL (v_deprn_cur.deprn_reserve, 0)
                  + NVL (v_deprn_cur.impairment_amount, 0)
                                  + NVL(l_ret_gen_det_value,0);



               IF p_mode = 'FINAL'
               THEN
                  UPDATE fa_deprn_detail
                     SET capital_adjustment = v_capital_adj_amount,
                         general_fund = v_general_fund_amount
                   WHERE distribution_id = v_deprn_cur.distribution_id
                     AND book_type_code = p_book_type_code
                     AND period_counter = v_deprn_cur.period_counter;
               END IF;
            ELSE
               v_capital_adj_amount :=
                    NVL (v_capital_adj_amount, 0)
                  + NVL (v_deprn_cur.deprn_amount, 0)
                  + NVL (v_deprn_cur.impairment_amount, 0)
                  - NVL (v_deprn_cur.reval_amortization, 0)
                                  + NVL (l_imp_cap_det_value,0)
                                  + NVL(l_ret_cap_det_value,0);
               v_general_fund_amount :=
                    NVL (v_general_fund_amount, 0)
                  + NVL (v_deprn_cur.deprn_amount, 0)
                  + NVL (v_deprn_cur.impairment_amount, 0)
                                  + NVL(l_ret_gen_det_value,0);

               IF p_mode = 'FINAL'
               THEN
                  UPDATE fa_deprn_detail
                     SET capital_adjustment = v_capital_adj_amount,
                         general_fund = v_general_fund_amount
                   WHERE distribution_id = v_deprn_cur.distribution_id
                     AND book_type_code = p_book_type_code
                     AND period_counter = v_deprn_cur.period_counter;
               END IF;
            END IF;
         END LOOP;

         CLOSE c_deprn_cur;



         IF p_mode = 'FINAL'
         THEN
            OPEN c_deprn_summary_cur;

            LOOP
               FETCH c_deprn_summary_cur
                INTO v_deprn_summary_cur;

               EXIT WHEN c_deprn_summary_cur%NOTFOUND;

                                                 if  not get_impairment_sorp_values
                                                                        (p_book_type_code,
                                                                         v_asset_id,
                                                                         NULL,
                                                                         v_deprn_summary_cur.period_counter,
                                                                         'S',
                                                                         l_imp_cap_sum_value,
                                                                         l_imp_gen_sum_value) then
                                                        return false;
                                                end if;

                                                if  not get_retirement_sorp_values
                                                                        (p_book_type_code,
                                                                         v_asset_id,
                                                                         NULL,
                                                                         v_deprn_summary_cur.period_counter,
                                                                         l_ret_cap_det_value,
                                                                         l_ret_gen_det_value) then
                                                return false;
                                                end if;

               IF c_deprn_summary_cur%ROWCOUNT = 1
               THEN
                  v_capital_adj_summary_amount :=
                       NVL (v_deprn_summary_cur.deprn_reserve, 0)
                     + NVL (v_deprn_summary_cur.impairment_amount, 0)
                     - NVL (v_deprn_summary_cur.reval_amortization, 0)
                                         + NVL(l_imp_cap_sum_value,0)
                                         + NVL(l_ret_cap_det_value,0);
                  v_general_fund_summary_amount :=
                       NVL (v_deprn_summary_cur.deprn_reserve, 0)
                     + NVL (v_deprn_summary_cur.impairment_amount, 0)
                                         + NVL(l_ret_gen_det_value,0);

                  UPDATE fa_deprn_summary
                     SET capital_adjustment = v_capital_adj_summary_amount,
                         general_fund = v_general_fund_summary_amount
                   WHERE asset_id = v_asset_id
                     AND book_type_code = p_book_type_code
                     AND period_counter = v_deprn_summary_cur.period_counter;
               ELSE
                  v_capital_adj_summary_amount :=
                       NVL (v_capital_adj_summary_amount, 0)
                     + NVL (v_deprn_summary_cur.deprn_amount, 0)
                     + NVL (v_deprn_summary_cur.impairment_amount, 0)
                     - NVL (v_deprn_summary_cur.reval_amortization, 0)
                                         + NVL(l_imp_cap_sum_value,0)
                                         + NVL(l_ret_cap_det_value,0);
                  v_general_fund_summary_amount :=
                       NVL (v_general_fund_summary_amount, 0)
                     + NVL (v_deprn_summary_cur.deprn_amount, 0)
                     + NVL (v_deprn_summary_cur.impairment_amount, 0)
                     + NVL(l_ret_gen_det_value,0);


                  UPDATE fa_deprn_summary
                     SET capital_adjustment = v_capital_adj_summary_amount,
                         general_fund = v_general_fund_summary_amount
                   WHERE asset_id = v_asset_id
                     AND book_type_code = p_book_type_code
                     AND period_counter = v_deprn_summary_cur.period_counter;
               END IF;
            END LOOP;

            CLOSE c_deprn_summary_cur;
         END IF;

         INSERT INTO fa_sorp_upg_cagf
                     (book_type_code, asset_id, asset_number,
                      asset_description,
                      date_placed_in_service,
                      category_name, current_cost,
                      depriciation_reserve, revaluation_reserve,
                      impairment_reserve, capital_adjustment_acct_amount,
                      general_fund_acct_amount
                     )
              VALUES (p_book_type_code, v_asset_id, v_asset_cur.asset_number,
                      v_asset_cur.asset_description,
                      v_book_cur.date_placed_in_service,
                      v_asset_cur.category_name, v_book_cur.current_cost,
                      l_deprn_rsv, l_reval_rsv,
                      l_impairment_rsv, v_capital_adj_amount,
                      v_general_fund_amount
                     );

         v_capital_adj_amount := 0;
         v_general_fund_amount := 0;
      END LOOP;

      CLOSE c_asset_cur;

          IF p_mode = 'FINAL' then



                   select period_name into v_period_name
                   from fa_deprn_periods
                   where book_type_code = P_FA_BOOK
                   and period_close_date is null;

                        open c_fa_sorp_upg_cagf_hist_cur;
                        loop
                                fetch c_fa_sorp_upg_cagf_hist_cur into v_fa_sorp_upg_cagf_hist_cur;
                                exit when c_fa_sorp_upg_cagf_hist_cur%notfound;

                                    INSERT INTO fa_sorp_upg_cagf_hist
                     (book_type_code,
                                          asset_id,
                                          asset_number,
                      asset_description,
                      date_placed_in_service,
                      category_name,
                                          current_cost,
                      depriciation_reserve,
                                          revaluation_reserve,
                      impairment_reserve,
                                          capital_adjustment_acct_amount,
                      general_fund_acct_amount,
                                          request_id,
                                          report_mode,
                                          period_name
                     )
                                        VALUES
                                          (v_fa_sorp_upg_cagf_hist_cur.book_type_code,
                                          v_fa_sorp_upg_cagf_hist_cur.asset_id,
                                          v_fa_sorp_upg_cagf_hist_cur.asset_number,
                      v_fa_sorp_upg_cagf_hist_cur.asset_description,
                      v_fa_sorp_upg_cagf_hist_cur.date_placed_in_service,
                      v_fa_sorp_upg_cagf_hist_cur.category_name,
                                          v_fa_sorp_upg_cagf_hist_cur.current_cost,
                      v_fa_sorp_upg_cagf_hist_cur.depriciation_reserve,
                                          v_fa_sorp_upg_cagf_hist_cur.revaluation_reserve,
                      v_fa_sorp_upg_cagf_hist_cur.impairment_reserve,
                                          v_fa_sorp_upg_cagf_hist_cur.capital_adjustment_acct_amount,
                      v_fa_sorp_upg_cagf_hist_cur.general_fund_acct_amount,
                                          l_request_id,
                                          p_mode,
                                          v_period_name);
                        end loop;
                        close c_fa_sorp_upg_cagf_hist_cur;

          END IF;

	  COMMIT;

	     IF fa_sorp_upg_mc_flag(p_book_type_code) THEN
                V_BOOLEAN := fa_sorp_upg_cagf_MC_FN(p_book_type_code,P_MODE);
                IF V_BOOLEAN  THEN RETURN TRUE;
                ELSE RETURN FALSE;
                END IF;

             END IF;

        ELSE  -- v_final_cnt = 0
                p_from := 'fa_sorp_upg_cagf_hist';
            p_where := ' where book_type_code = '||''''||p_book_type_code||''''||' and report_mode ='||''''||p_mode||'''';
        END IF;

    RETURN TRUE;

   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN FALSE;
   END fa_sorp_upg_cagf_fn;

      FUNCTION fa_sorp_upg_impreval_mc_fn(p_book VARCHAR2, p_mode VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN
   IS
      v_impairment_id           NUMBER;
      v_mass_reval_id           NUMBER;
      v_mass_description        VARCHAR2(250);
      v_description             VARCHAR2(100);
      v_asset_id                NUMBER;
      v_cash_id                 NUMBER;

      CURSOR c_imp_asset_cur IS SELECT 'Impairment'  transaction_type,
          i.asset_id,
          a.asset_number,
                a.description asset_description, a.asset_category_id,
                a.attribute_category_code category_name, i.impairment_id,
                i.impairment_name,
                NVL (i.description, 'Others') imp_description,
                                -- Bug#7704219
                NVL (
                                     decode(SUBSTR (i.description, 1, 3),'CPP','CPP',
                                                                             'CEB','CEB',
                                                                                                                 'OTH'),
                     'OTH'
                    ) impair_classification_type
           FROM fa_additions_v a, FA_MC_IMPAIRMENTS i
          WHERE a.asset_id = i.asset_id AND i.book_type_code = p_book;

      v_imp_asset_cur           c_imp_asset_cur%ROWTYPE;

      CURSOR c_imp_itf_asset_cur
      IS
         SELECT impairment_amount
           FROM FA_MC_ITF_IMPAIRMENTS
          WHERE impairment_id = v_impairment_id
            AND asset_id = v_asset_id
            AND book_type_code = p_book;

      v_imp_itf_asset_cur       c_imp_itf_asset_cur%ROWTYPE;

          cursor c_imp_deprn_asset_cur(l_book varchar2,
                                       l_asset_id number,
                                                                   l_period_counter number)
          is
                 select capital_adjustment,
                                general_fund
                         from FA_MC_DEPRN_SUMMARY
                         where book_type_code = l_book
                         and asset_id = l_asset_id
                         and period_counter = (select max(period_counter)
                                              from FA_MC_DEPRN_SUMMARY
                                                                  where book_type_code = l_book
                                                          and asset_id = l_asset_id
                                                                  and period_counter < l_period_counter);

          v_imp_deprn_asset_cur c_imp_deprn_asset_cur%rowtype;


      CURSOR c_imp_cash_cur
      IS
         SELECT 'Impairment' transaction_type, i.cash_generating_unit_id,
                a.cash_generating_unit, a.description asset_description,
                NULL asset_category_id, NULL category_name, i.impairment_id,
                i.impairment_name,
                NVL (i.description, 'Others') imp_description,
                NVL (SUBSTR (i.description, 1, 3),
                     'OTH'
                    ) impair_classification_type
           FROM fa_cash_gen_units a, FA_MC_IMPAIRMENTS i
          WHERE a.cash_generating_unit_id = i.cash_generating_unit_id
            AND i.book_type_code = p_book;

      v_imp_cash_cur            c_imp_cash_cur%ROWTYPE;

      CURSOR c_imp_itf_cash_cur
      IS
         SELECT impairment_amount
           FROM FA_MC_ITF_IMPAIRMENTS
          WHERE impairment_id = v_impairment_id
            AND cash_generating_unit_id = v_cash_id
            AND book_type_code = p_book;

      v_imp_itf_cash_cur        c_imp_itf_cash_cur%ROWTYPE;

      CURSOR c_reval_id_cur
      IS
         SELECT DISTINCT mass_reval_id, description
                    FROM fa_mass_revaluations
                   WHERE book_type_code = p_book;

     -- Bug#7578069 cursor queries for c_reval_asset_cur and  c_reval_cat_cur modified

      CURSOR c_reval_asset_cur
      IS
         SELECT 'Revaluation' transaction_type, r.asset_id, a.asset_number,
                a.description asset_description, r.mass_reval_id,
                r.reval_percent
           FROM fa_additions_v a, fa_mass_revaluation_rules r,fa_mass_revaluations mr
          WHERE a.asset_id = r.asset_id
            AND r.mass_reval_id = mr.mass_reval_id
            AND mr.mass_reval_id = v_mass_reval_id
            AND r.category_id IS NULL
            AND mr.book_type_code = p_book;

      v_reval_asset_cur         c_reval_asset_cur%ROWTYPE;

      CURSOR c_reval_cat_cur
      IS
          SELECT  distinct 'Revaluation' transaction_type,
                r.category_id asset_category_id,
                a.attribute_category_code category_name, r.mass_reval_id,
                r.reval_percent
           FROM fa_additions_v a, fa_mass_revaluation_rules r,fa_mass_revaluations mr
          WHERE a.asset_category_id = r.category_id
          AND r.mass_reval_id = mr.mass_reval_id
            AND mr.mass_reval_id = v_mass_reval_id
            AND r.asset_id IS NULL
            AND mr.book_type_code = p_book;

      v_reval_cat_cur           c_reval_cat_cur%ROWTYPE;

      CURSOR c_final_imp_asset_cur
      IS
         SELECT ID, impairment_id, imp_description, imp_class_type,
                imp_amount, book_type_code
           FROM fa_sorp_upg_impreval
          WHERE transaction_type = 'Impairment' AND id_type = 'A';

      v_final_imp_asset_cur     c_final_imp_asset_cur%ROWTYPE;

      CURSOR c_final_imp_cash_cur
      IS
         SELECT ID, impairment_id, imp_description, imp_class_type,
                imp_amount, book_type_code
           FROM fa_sorp_upg_impreval
          WHERE transaction_type = 'Impairment' AND id_type = 'C';

      v_final_imp_cash_cur      c_final_imp_cash_cur%ROWTYPE;

      CURSOR c_final_reval_asset_cur
      IS
         SELECT mass_reval_id, ID, reval_reason, book_type_code
           FROM fa_sorp_upg_impreval
          WHERE transaction_type = 'Revaluation' AND asset_category_id IS NULL;

      v_final_reval_asset_cur   c_final_reval_asset_cur%ROWTYPE;

      CURSOR c_final_reval_cat_cur
      IS
         SELECT mass_reval_id, asset_category_id category_id, reval_reason,
                book_type_code
           FROM fa_sorp_upg_impreval
          WHERE transaction_type = 'Revaluation' AND ID IS NULL;

      v_final_reval_cat_cur     c_final_reval_cat_cur%ROWTYPE;

          cursor c_srp_upg_impreval_hist_cur
                is select transaction_type ,
                                        id,
                                        name,
                                        description,
                                        asset_category_id,
                                        category_name,
                                        impairment_id,
                                        impairment_name,
                                        imp_description,
                                        imp_class_type,
                                        imp_amount,
                                        mass_reval_id,
                                        reval_percent,
                                        reval_reason,
                                        book_type_code,
                                        report_mode,
                                        id_type
                                        from fa_sorp_upg_impreval;

        v_srp_upg_impreval_hist_cur c_srp_upg_impreval_hist_cur%rowtype;

        l_request_id number;
        v_final_cnt number;

        l_capital_amount number;
        l_general_fund_amount number;
        l_counter number;

   BEGIN
      DELETE FROM fa_sorp_upg_impreval;

      COMMIT;

        l_request_id :=  fnd_global.conc_request_id;

        p_from := 'fa_sorp_upg_impreval';
        p_where := ' and 1=1';

        P_REQUEST_WHERE := ' AND REQUEST_ID <> '||l_request_id;



        select count(1) into v_final_cnt
        from fa_sorp_upg_impreval_hist
        where book_type_code = p_book
        and report_mode = p_mode;

        IF v_final_cnt = 0 then

      OPEN c_imp_asset_cur;

      LOOP
         FETCH c_imp_asset_cur
          INTO v_imp_asset_cur;

         EXIT WHEN c_imp_asset_cur%NOTFOUND;
         v_impairment_id := v_imp_asset_cur.impairment_id;
         v_asset_id := v_imp_asset_cur.asset_id;

         OPEN c_imp_itf_asset_cur;

         FETCH c_imp_itf_asset_cur
          INTO v_imp_itf_asset_cur;

         INSERT INTO fa_sorp_upg_impreval
                     (transaction_type,
                      ID,
                      NAME,
                      description,
                      asset_category_id,
                      category_name,
                      impairment_id,
                      impairment_name,
                      imp_description,
                      imp_class_type,
                      imp_amount, book_type_code, report_mode,
                      id_type
                     )
              VALUES (v_imp_asset_cur.transaction_type,
                      v_imp_asset_cur.asset_id,
                      v_imp_asset_cur.asset_number,
                      v_imp_asset_cur.asset_description,
                      v_imp_asset_cur.asset_category_id,
                      v_imp_asset_cur.category_name,
                      v_imp_asset_cur.impairment_id,
                      v_imp_asset_cur.impairment_name,
                      v_imp_asset_cur.imp_description,
                      v_imp_asset_cur.impair_classification_type,
                      v_imp_itf_asset_cur.impairment_amount,
                                          p_book,
                                          p_mode,
                      'A'
                     );

         CLOSE c_imp_itf_asset_cur;
      END LOOP;

      CLOSE c_imp_asset_cur;

      OPEN c_imp_cash_cur;

      LOOP
         FETCH c_imp_cash_cur
          INTO v_imp_cash_cur;

         EXIT WHEN c_imp_cash_cur%NOTFOUND;
         v_impairment_id := v_imp_cash_cur.impairment_id;
         v_cash_id := v_imp_cash_cur.cash_generating_unit_id;

         OPEN c_imp_itf_cash_cur;

         FETCH c_imp_itf_cash_cur
          INTO v_imp_itf_cash_cur;

         INSERT INTO fa_sorp_upg_impreval
                     (transaction_type,
                      ID,
                      NAME,
                      description,
                      asset_category_id,
                      category_name,
                      impairment_id,
                      impairment_name,
                      imp_description,
                      imp_class_type,
                      imp_amount, book_type_code, report_mode,
                      id_type
                     )
              VALUES (v_imp_cash_cur.transaction_type,
                      v_imp_cash_cur.cash_generating_unit_id,
                      v_imp_cash_cur.cash_generating_unit,
                      v_imp_cash_cur.asset_description,
                      v_imp_cash_cur.asset_category_id,
                      v_imp_cash_cur.category_name,
                      v_imp_cash_cur.impairment_id,
                      v_imp_cash_cur.impairment_name,
                      v_imp_cash_cur.imp_description,
                      v_imp_cash_cur.impair_classification_type,
                      v_imp_itf_cash_cur.impairment_amount, p_book, p_mode,
                      'C'
                     );

         CLOSE c_imp_itf_cash_cur;
      END LOOP;

      CLOSE c_imp_cash_cur;

      OPEN c_reval_id_cur;

      LOOP
         FETCH c_reval_id_cur
          INTO v_mass_reval_id, v_mass_description;

         EXIT WHEN c_reval_id_cur%NOTFOUND;

         OPEN c_reval_asset_cur;

         LOOP
            FETCH c_reval_asset_cur
             INTO v_reval_asset_cur;

            EXIT WHEN c_reval_asset_cur%NOTFOUND;

            INSERT INTO fa_sorp_upg_impreval
                        (transaction_type,
                         ID,
                         NAME,
                         description,
                         mass_reval_id, reval_percent,
                         reval_reason, book_type_code, report_mode
                        )
                 VALUES (v_reval_asset_cur.transaction_type,
                         v_reval_asset_cur.asset_id,
                         v_reval_asset_cur.asset_number,
                         v_reval_asset_cur.asset_description,
                         v_mass_reval_id, v_reval_asset_cur.reval_percent,
                         v_mass_description, p_book, p_mode
                        );
         END LOOP;

         CLOSE c_reval_asset_cur;

         OPEN c_reval_cat_cur;

         LOOP
            FETCH c_reval_cat_cur
             INTO v_reval_cat_cur;

            EXIT WHEN c_reval_cat_cur%NOTFOUND;

            INSERT INTO fa_sorp_upg_impreval
                        (transaction_type,
                         asset_category_id,
                         category_name, mass_reval_id,
                         reval_percent, reval_reason,
                         book_type_code, report_mode
                        )
                 VALUES (v_reval_cat_cur.transaction_type,
                         v_reval_cat_cur.asset_category_id,
                         v_reval_cat_cur.category_name, v_mass_reval_id,
                         v_reval_cat_cur.reval_percent, v_mass_description,
                         p_book, p_mode
                        );
         END LOOP;

         CLOSE c_reval_cat_cur;
      END LOOP;

      CLOSE c_reval_id_cur;

      IF p_mode = 'FINAL'
      THEN
         OPEN c_final_imp_asset_cur;

         LOOP
            FETCH c_final_imp_asset_cur
             INTO v_final_imp_asset_cur;

            EXIT WHEN c_final_imp_asset_cur%NOTFOUND;

                        select period_counter into l_counter
                        from FA_MC_ITF_IMPAIRMENTS
                        where impairment_id = v_final_imp_asset_cur.impairment_id;

                        OPEN c_imp_deprn_asset_cur(p_book,v_final_imp_asset_cur.ID,l_counter);
                        FETCH c_imp_deprn_asset_cur into v_imp_deprn_asset_cur;
                        close c_imp_deprn_asset_cur;

                        l_capital_amount := v_final_imp_asset_cur.imp_amount+nvl(v_imp_deprn_asset_cur.capital_adjustment,0);
                        l_general_fund_amount := v_final_imp_asset_cur.imp_amount+nvl(v_imp_deprn_asset_cur.general_fund,0);

            UPDATE FA_MC_IMPAIRMENTS
               SET reason = v_final_imp_asset_cur.imp_description,
                   impair_class = v_final_imp_asset_cur.imp_class_type,
                   split_impair_flag = 'N'
             WHERE book_type_code = p_book
               AND impairment_id = v_final_imp_asset_cur.impairment_id
               AND asset_id = v_final_imp_asset_cur.ID;

            UPDATE FA_MC_ITF_IMPAIRMENTS
               SET capital_adjustment = l_capital_amount,
                   general_fund = l_general_fund_amount,
                   split_impair_flag = 'N'
             WHERE book_type_code = p_book
               AND impairment_id = v_final_imp_asset_cur.impairment_id
               AND asset_id = v_final_imp_asset_cur.ID;
         END LOOP;

         CLOSE c_final_imp_asset_cur;

         OPEN c_final_imp_cash_cur;

         LOOP
            FETCH c_final_imp_cash_cur
             INTO v_final_imp_cash_cur;

            EXIT WHEN c_final_imp_cash_cur%NOTFOUND;

            UPDATE FA_MC_IMPAIRMENTS
               SET reason = v_final_imp_cash_cur.imp_description,
                   impair_class = v_final_imp_cash_cur.imp_class_type,
                   split_impair_flag = 'N'
             WHERE book_type_code = p_book
               AND impairment_id = v_final_imp_cash_cur.impairment_id
               AND cash_generating_unit_id = v_final_imp_cash_cur.ID;

            UPDATE FA_MC_ITF_IMPAIRMENTS
               SET capital_adjustment = v_final_imp_cash_cur.imp_amount,
                   general_fund = v_final_imp_cash_cur.imp_amount,
                   split_impair_flag = 'N'
             WHERE book_type_code = p_book
               AND impairment_id = v_final_imp_cash_cur.impairment_id
               AND cash_generating_unit_id = v_final_imp_cash_cur.ID;
         END LOOP;

         CLOSE c_final_imp_cash_cur;

         OPEN c_final_reval_asset_cur;

         LOOP
            FETCH c_final_reval_asset_cur
             INTO v_final_reval_asset_cur;

            EXIT WHEN c_final_reval_asset_cur%NOTFOUND;

            UPDATE fa_mass_revaluation_rules
               SET reason = v_final_reval_asset_cur.reval_reason,
                   value_type = 'PER',
                   book_type_code = p_book
             WHERE mass_reval_id = v_final_reval_asset_cur.mass_reval_id
               AND asset_id = v_final_reval_asset_cur.ID;
         END LOOP;

         CLOSE c_final_reval_asset_cur;

         OPEN c_final_reval_cat_cur;

         LOOP
            FETCH c_final_reval_cat_cur
             INTO v_final_reval_cat_cur;

            EXIT WHEN c_final_reval_cat_cur%NOTFOUND;

            UPDATE fa_mass_revaluation_rules
               SET reason = v_final_reval_cat_cur.reval_reason,
                   value_type = 'PER',
                   book_type_code = p_book
               WHERE mass_reval_id = v_final_reval_cat_cur.mass_reval_id
               AND category_id = v_final_reval_cat_cur.category_id;
         END LOOP;

         CLOSE c_final_reval_cat_cur;
      END IF;

          IF p_mode = 'FINAL' then




                        open c_srp_upg_impreval_hist_cur;
                        loop
                                fetch c_srp_upg_impreval_hist_cur into v_srp_upg_impreval_hist_cur;
                                exit when c_srp_upg_impreval_hist_cur%notfound;

                                    INSERT INTO fa_sorp_upg_impreval_hist
                     (transaction_type ,
                                                id,
                                                name,
                                                description,
                                                asset_category_id,
                                                category_name,
                                                impairment_id,
                                                impairment_name,
                                                imp_description,
                                                imp_class_type,
                                                imp_amount,
                                                mass_reval_id,
                                                reval_percent,
                                                reval_reason,
                                                book_type_code,
                                                report_mode,
                                                id_type,
                                                request_id)
                     VALUES
                                          (v_srp_upg_impreval_hist_cur.transaction_type ,
                                                v_srp_upg_impreval_hist_cur.id,
                                                v_srp_upg_impreval_hist_cur.name,
                                                v_srp_upg_impreval_hist_cur.description,
                                                v_srp_upg_impreval_hist_cur.asset_category_id,
                                                v_srp_upg_impreval_hist_cur.category_name,
                                                v_srp_upg_impreval_hist_cur.impairment_id,
                                                v_srp_upg_impreval_hist_cur.impairment_name,
                                                v_srp_upg_impreval_hist_cur.imp_description,
                                                v_srp_upg_impreval_hist_cur.imp_class_type,
                                                v_srp_upg_impreval_hist_cur.imp_amount,
                                                v_srp_upg_impreval_hist_cur.mass_reval_id,
                                                v_srp_upg_impreval_hist_cur.reval_percent,
                                                v_srp_upg_impreval_hist_cur.reval_reason,
                                                v_srp_upg_impreval_hist_cur.book_type_code,
                                                v_srp_upg_impreval_hist_cur.report_mode,
                                                v_srp_upg_impreval_hist_cur.id_type,
                                                l_request_id);
                        end loop;
                        close c_srp_upg_impreval_hist_cur;
          END IF;
        ELSE  -- v_final_cnt = 0
                p_from := 'fa_sorp_upg_impreval_hist';
            p_where := ' and book_type_code = '||''''||p_book||''''||' and report_mode ='||''''||p_mode||'''';
        END IF;


      COMMIT;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN FALSE;
   END fa_sorp_upg_impreval_mc_fn;

    FUNCTION fa_sorp_upg_impreval_fn(p_book VARCHAR2, p_mode VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN
   IS
      v_impairment_id           NUMBER;
      v_mass_reval_id           NUMBER;
      v_mass_description        VARCHAR2(250);
      v_description             VARCHAR2(100);
      v_asset_id                NUMBER;
      v_cash_id                 NUMBER;

          v_boolean boolean;

      CURSOR c_imp_asset_cur IS SELECT 'Impairment'  transaction_type,
          i.asset_id,
          a.asset_number,
                a.description asset_description, a.asset_category_id,
                a.attribute_category_code category_name, i.impairment_id,
                i.impairment_name,
                NVL (i.description, 'Others') imp_description,
                                -- Bug#7704219
                NVL (
                                     decode(SUBSTR (i.description, 1, 3),'CPP','CPP',
                                                                             'CEB','CEB',
                                                                                                                 'OTH'),
                     'OTH'
                    ) impair_classification_type
           FROM fa_additions_v a, fa_impairments i
          WHERE a.asset_id = i.asset_id AND i.book_type_code = p_book;

      v_imp_asset_cur           c_imp_asset_cur%ROWTYPE;

      CURSOR c_imp_itf_asset_cur
      IS
         SELECT impairment_amount
           FROM fa_itf_impairments
          WHERE impairment_id = v_impairment_id
            AND asset_id = v_asset_id
            AND book_type_code = p_book;

      v_imp_itf_asset_cur       c_imp_itf_asset_cur%ROWTYPE;

          cursor c_imp_deprn_asset_cur(l_book varchar2,
                                       l_asset_id number,
                                                                   l_period_counter number)
          is
                 select capital_adjustment,
                                general_fund
                         from fa_deprn_summary
                         where book_type_code = l_book
                         and asset_id = l_asset_id
                         and period_counter = (select max(period_counter)
                                              from fa_deprn_summary
                                                                  where book_type_code = l_book
                                                          and asset_id = l_asset_id
                                                                  and period_counter < l_period_counter);

          v_imp_deprn_asset_cur c_imp_deprn_asset_cur%rowtype;


      CURSOR c_imp_cash_cur
      IS
         SELECT 'Impairment' transaction_type, i.cash_generating_unit_id,
                a.cash_generating_unit, a.description asset_description,
                NULL asset_category_id, NULL category_name, i.impairment_id,
                i.impairment_name,
                NVL (i.description, 'Others') imp_description,
                NVL (SUBSTR (i.description, 1, 3),
                     'OTH'
                    ) impair_classification_type
           FROM fa_cash_gen_units a, fa_impairments i
          WHERE a.cash_generating_unit_id = i.cash_generating_unit_id
            AND i.book_type_code = p_book;

      v_imp_cash_cur            c_imp_cash_cur%ROWTYPE;

      CURSOR c_imp_itf_cash_cur
      IS
         SELECT impairment_amount
           FROM fa_itf_impairments
          WHERE impairment_id = v_impairment_id
            AND cash_generating_unit_id = v_cash_id
            AND book_type_code = p_book;

      v_imp_itf_cash_cur        c_imp_itf_cash_cur%ROWTYPE;

      CURSOR c_reval_id_cur
      IS
         SELECT DISTINCT mass_reval_id, description
                    FROM fa_mass_revaluations
                   WHERE book_type_code = p_book;

     -- Bug#7578069 cursor queries for c_reval_asset_cur and  c_reval_cat_cur modified

      CURSOR c_reval_asset_cur
      IS
         SELECT 'Revaluation' transaction_type, r.asset_id, a.asset_number,
                a.description asset_description, r.mass_reval_id,
                r.reval_percent
           FROM fa_additions_v a, fa_mass_revaluation_rules r,fa_mass_revaluations mr
          WHERE a.asset_id = r.asset_id
            AND r.mass_reval_id = mr.mass_reval_id
            AND mr.mass_reval_id = v_mass_reval_id
            AND r.category_id IS NULL
            AND mr.book_type_code = p_book;

      v_reval_asset_cur         c_reval_asset_cur%ROWTYPE;

      CURSOR c_reval_cat_cur
      IS
          SELECT  distinct 'Revaluation' transaction_type,
                r.category_id asset_category_id,
                a.attribute_category_code category_name, r.mass_reval_id,
                r.reval_percent
           FROM fa_additions_v a, fa_mass_revaluation_rules r,fa_mass_revaluations mr
          WHERE a.asset_category_id = r.category_id
          AND r.mass_reval_id = mr.mass_reval_id
            AND mr.mass_reval_id = v_mass_reval_id
            AND r.asset_id IS NULL
            AND mr.book_type_code = p_book;

      v_reval_cat_cur           c_reval_cat_cur%ROWTYPE;

      CURSOR c_final_imp_asset_cur
      IS
         SELECT ID, impairment_id, imp_description, imp_class_type,
                imp_amount, book_type_code
           FROM fa_sorp_upg_impreval
          WHERE transaction_type = 'Impairment' AND id_type = 'A';

      v_final_imp_asset_cur     c_final_imp_asset_cur%ROWTYPE;

      CURSOR c_final_imp_cash_cur
      IS
         SELECT ID, impairment_id, imp_description, imp_class_type,
                imp_amount, book_type_code
           FROM fa_sorp_upg_impreval
          WHERE transaction_type = 'Impairment' AND id_type = 'C';

      v_final_imp_cash_cur      c_final_imp_cash_cur%ROWTYPE;

      CURSOR c_final_reval_asset_cur
      IS
         SELECT mass_reval_id, ID, reval_reason, book_type_code
           FROM fa_sorp_upg_impreval
          WHERE transaction_type = 'Revaluation' AND asset_category_id IS NULL;

      v_final_reval_asset_cur   c_final_reval_asset_cur%ROWTYPE;

      CURSOR c_final_reval_cat_cur
      IS
         SELECT mass_reval_id, asset_category_id category_id, reval_reason,
                book_type_code
           FROM fa_sorp_upg_impreval
          WHERE transaction_type = 'Revaluation' AND ID IS NULL;

      v_final_reval_cat_cur     c_final_reval_cat_cur%ROWTYPE;

          cursor c_srp_upg_impreval_hist_cur
                is select transaction_type ,
                                        id,
                                        name,
                                        description,
                                        asset_category_id,
                                        category_name,
                                        impairment_id,
                                        impairment_name,
                                        imp_description,
                                        imp_class_type,
                                        imp_amount,
                                        mass_reval_id,
                                        reval_percent,
                                        reval_reason,
                                        book_type_code,
                                        report_mode,
                                        id_type
                                        from fa_sorp_upg_impreval;

        v_srp_upg_impreval_hist_cur c_srp_upg_impreval_hist_cur%rowtype;

        l_request_id number;
        v_final_cnt number;

        l_capital_amount number;
        l_general_fund_amount number;
        l_counter number;

   BEGIN

   if not  fa_sorp_upg_mc_flag(p_book) then

      DELETE FROM fa_sorp_upg_impreval;

      COMMIT;

        l_request_id :=  fnd_global.conc_request_id;

        p_from := 'fa_sorp_upg_impreval';
        p_where := ' and 1=1';

        P_REQUEST_WHERE := ' AND REQUEST_ID <> '||l_request_id;



        select count(1) into v_final_cnt
        from fa_sorp_upg_impreval_hist
        where book_type_code = p_book
        and report_mode = p_mode;

        IF v_final_cnt = 0 then

      OPEN c_imp_asset_cur;

      LOOP
         FETCH c_imp_asset_cur
          INTO v_imp_asset_cur;

         EXIT WHEN c_imp_asset_cur%NOTFOUND;
         v_impairment_id := v_imp_asset_cur.impairment_id;
         v_asset_id := v_imp_asset_cur.asset_id;

         OPEN c_imp_itf_asset_cur;

         FETCH c_imp_itf_asset_cur
          INTO v_imp_itf_asset_cur;

         INSERT INTO fa_sorp_upg_impreval
                     (transaction_type,
                      ID,
                      NAME,
                      description,
                      asset_category_id,
                      category_name,
                      impairment_id,
                      impairment_name,
                      imp_description,
                      imp_class_type,
                      imp_amount, book_type_code, report_mode,
                      id_type
                     )
              VALUES (v_imp_asset_cur.transaction_type,
                      v_imp_asset_cur.asset_id,
                      v_imp_asset_cur.asset_number,
                      v_imp_asset_cur.asset_description,
                      v_imp_asset_cur.asset_category_id,
                      v_imp_asset_cur.category_name,
                      v_imp_asset_cur.impairment_id,
                      v_imp_asset_cur.impairment_name,
                      v_imp_asset_cur.imp_description,
                      v_imp_asset_cur.impair_classification_type,
                      v_imp_itf_asset_cur.impairment_amount,
                                          p_book,
                                          p_mode,
                      'A'
                     );

         CLOSE c_imp_itf_asset_cur;
      END LOOP;

      CLOSE c_imp_asset_cur;

      OPEN c_imp_cash_cur;

      LOOP
         FETCH c_imp_cash_cur
          INTO v_imp_cash_cur;

         EXIT WHEN c_imp_cash_cur%NOTFOUND;
         v_impairment_id := v_imp_cash_cur.impairment_id;
         v_cash_id := v_imp_cash_cur.cash_generating_unit_id;

         OPEN c_imp_itf_cash_cur;

         FETCH c_imp_itf_cash_cur
          INTO v_imp_itf_cash_cur;

         INSERT INTO fa_sorp_upg_impreval
                     (transaction_type,
                      ID,
                      NAME,
                      description,
                      asset_category_id,
                      category_name,
                      impairment_id,
                      impairment_name,
                      imp_description,
                      imp_class_type,
                      imp_amount, book_type_code, report_mode,
                      id_type
                     )
              VALUES (v_imp_cash_cur.transaction_type,
                      v_imp_cash_cur.cash_generating_unit_id,
                      v_imp_cash_cur.cash_generating_unit,
                      v_imp_cash_cur.asset_description,
                      v_imp_cash_cur.asset_category_id,
                      v_imp_cash_cur.category_name,
                      v_imp_cash_cur.impairment_id,
                      v_imp_cash_cur.impairment_name,
                      v_imp_cash_cur.imp_description,
                      v_imp_cash_cur.impair_classification_type,
                      v_imp_itf_cash_cur.impairment_amount, p_book, p_mode,
                      'C'
                     );

         CLOSE c_imp_itf_cash_cur;
      END LOOP;

      CLOSE c_imp_cash_cur;

      OPEN c_reval_id_cur;

      LOOP
         FETCH c_reval_id_cur
          INTO v_mass_reval_id, v_mass_description;

         EXIT WHEN c_reval_id_cur%NOTFOUND;

         OPEN c_reval_asset_cur;

         LOOP
            FETCH c_reval_asset_cur
             INTO v_reval_asset_cur;

            EXIT WHEN c_reval_asset_cur%NOTFOUND;

            INSERT INTO fa_sorp_upg_impreval
                        (transaction_type,
                         ID,
                         NAME,
                         description,
                         mass_reval_id, reval_percent,
                         reval_reason, book_type_code, report_mode
                        )
                 VALUES (v_reval_asset_cur.transaction_type,
                         v_reval_asset_cur.asset_id,
                         v_reval_asset_cur.asset_number,
                         v_reval_asset_cur.asset_description,
                         v_mass_reval_id, v_reval_asset_cur.reval_percent,
                         v_mass_description, p_book, p_mode
                        );
         END LOOP;

         CLOSE c_reval_asset_cur;

         OPEN c_reval_cat_cur;

         LOOP
            FETCH c_reval_cat_cur
             INTO v_reval_cat_cur;

            EXIT WHEN c_reval_cat_cur%NOTFOUND;

            INSERT INTO fa_sorp_upg_impreval
                        (transaction_type,
                         asset_category_id,
                         category_name, mass_reval_id,
                         reval_percent, reval_reason,
                         book_type_code, report_mode
                        )
                 VALUES (v_reval_cat_cur.transaction_type,
                         v_reval_cat_cur.asset_category_id,
                         v_reval_cat_cur.category_name, v_mass_reval_id,
                         v_reval_cat_cur.reval_percent, v_mass_description,
                         p_book, p_mode
                        );
         END LOOP;

         CLOSE c_reval_cat_cur;
      END LOOP;

      CLOSE c_reval_id_cur;

      IF p_mode = 'FINAL'
      THEN
         OPEN c_final_imp_asset_cur;

         LOOP
            FETCH c_final_imp_asset_cur
             INTO v_final_imp_asset_cur;

            EXIT WHEN c_final_imp_asset_cur%NOTFOUND;

                        select period_counter into l_counter
                        from fa_itf_impairments
                        where impairment_id = v_final_imp_asset_cur.impairment_id;

                        OPEN c_imp_deprn_asset_cur(p_book,v_final_imp_asset_cur.ID,l_counter);
                        FETCH c_imp_deprn_asset_cur into v_imp_deprn_asset_cur;
                        close c_imp_deprn_asset_cur;

                        l_capital_amount := v_final_imp_asset_cur.imp_amount+nvl(v_imp_deprn_asset_cur.capital_adjustment,0);
                        l_general_fund_amount := v_final_imp_asset_cur.imp_amount+nvl(v_imp_deprn_asset_cur.general_fund,0);

            UPDATE fa_impairments
               SET reason = v_final_imp_asset_cur.imp_description,
                   impair_class = v_final_imp_asset_cur.imp_class_type,
                   split_impair_flag = 'N'
             WHERE book_type_code = p_book
               AND impairment_id = v_final_imp_asset_cur.impairment_id
               AND asset_id = v_final_imp_asset_cur.ID;

            UPDATE fa_itf_impairments
               SET capital_adjustment = l_capital_amount,
                   general_fund = l_general_fund_amount,
                   split_impair_flag = 'N'
             WHERE book_type_code = p_book
               AND impairment_id = v_final_imp_asset_cur.impairment_id
               AND asset_id = v_final_imp_asset_cur.ID;
         END LOOP;

         CLOSE c_final_imp_asset_cur;

         OPEN c_final_imp_cash_cur;

         LOOP
            FETCH c_final_imp_cash_cur
             INTO v_final_imp_cash_cur;

            EXIT WHEN c_final_imp_cash_cur%NOTFOUND;

            UPDATE fa_impairments
               SET reason = v_final_imp_cash_cur.imp_description,
                   impair_class = v_final_imp_cash_cur.imp_class_type,
                   split_impair_flag = 'N'
             WHERE book_type_code = p_book
               AND impairment_id = v_final_imp_cash_cur.impairment_id
               AND cash_generating_unit_id = v_final_imp_cash_cur.ID;

            UPDATE fa_itf_impairments
               SET capital_adjustment = v_final_imp_cash_cur.imp_amount,
                   general_fund = v_final_imp_cash_cur.imp_amount,
                   split_impair_flag = 'N'
             WHERE book_type_code = p_book
               AND impairment_id = v_final_imp_cash_cur.impairment_id
               AND cash_generating_unit_id = v_final_imp_cash_cur.ID;
         END LOOP;

         CLOSE c_final_imp_cash_cur;

         OPEN c_final_reval_asset_cur;

         LOOP
            FETCH c_final_reval_asset_cur
             INTO v_final_reval_asset_cur;

            EXIT WHEN c_final_reval_asset_cur%NOTFOUND;

            UPDATE fa_mass_revaluation_rules
               SET reason = v_final_reval_asset_cur.reval_reason,
                   value_type = 'PER',
                   book_type_code = p_book
             WHERE mass_reval_id = v_final_reval_asset_cur.mass_reval_id
               AND asset_id = v_final_reval_asset_cur.ID;
         END LOOP;

         CLOSE c_final_reval_asset_cur;

         OPEN c_final_reval_cat_cur;

         LOOP
            FETCH c_final_reval_cat_cur
             INTO v_final_reval_cat_cur;

            EXIT WHEN c_final_reval_cat_cur%NOTFOUND;

            UPDATE fa_mass_revaluation_rules
               SET reason = v_final_reval_cat_cur.reval_reason,
                   value_type = 'PER',
                   book_type_code = p_book
               WHERE mass_reval_id = v_final_reval_cat_cur.mass_reval_id
               AND category_id = v_final_reval_cat_cur.category_id;
         END LOOP;

         CLOSE c_final_reval_cat_cur;
      END IF;

          IF p_mode = 'FINAL' then




                        open c_srp_upg_impreval_hist_cur;
                        loop
                                fetch c_srp_upg_impreval_hist_cur into v_srp_upg_impreval_hist_cur;
                                exit when c_srp_upg_impreval_hist_cur%notfound;

                                    INSERT INTO fa_sorp_upg_impreval_hist
                     (transaction_type ,
                                                id,
                                                name,
                                                description,
                                                asset_category_id,
                                                category_name,
                                                impairment_id,
                                                impairment_name,
                                                imp_description,
                                                imp_class_type,
                                                imp_amount,
                                                mass_reval_id,
                                                reval_percent,
                                                reval_reason,
                                                book_type_code,
                                                report_mode,
                                                id_type,
                                                request_id)
                     VALUES
                                          (v_srp_upg_impreval_hist_cur.transaction_type ,
                                                v_srp_upg_impreval_hist_cur.id,
                                                v_srp_upg_impreval_hist_cur.name,
                                                v_srp_upg_impreval_hist_cur.description,
                                                v_srp_upg_impreval_hist_cur.asset_category_id,
                                                v_srp_upg_impreval_hist_cur.category_name,
                                                v_srp_upg_impreval_hist_cur.impairment_id,
                                                v_srp_upg_impreval_hist_cur.impairment_name,
                                                v_srp_upg_impreval_hist_cur.imp_description,
                                                v_srp_upg_impreval_hist_cur.imp_class_type,
                                                v_srp_upg_impreval_hist_cur.imp_amount,
                                                v_srp_upg_impreval_hist_cur.mass_reval_id,
                                                v_srp_upg_impreval_hist_cur.reval_percent,
                                                v_srp_upg_impreval_hist_cur.reval_reason,
                                                v_srp_upg_impreval_hist_cur.book_type_code,
                                                v_srp_upg_impreval_hist_cur.report_mode,
                                                v_srp_upg_impreval_hist_cur.id_type,
                                                l_request_id);
                        end loop;
                        close c_srp_upg_impreval_hist_cur;
          END IF;
        ELSE  -- v_final_cnt = 0
                p_from := 'fa_sorp_upg_impreval_hist';
            p_where := ' and book_type_code = '||''''||p_book||''''||' and report_mode ='||''''||p_mode||'''';
        END IF;


      COMMIT;
      RETURN TRUE;

        else

           v_boolean := fa_sorp_upg_impreval_mc_fn(p_book,p_mode);
           IF V_BOOLEAN THEN
           RETURN TRUE;
           ELSE
           RETURN FALSE;
           END IF;

        end if;

   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN FALSE;
   END fa_sorp_upg_impreval_fn;


END fa_sorp_upg_pkg;

/
