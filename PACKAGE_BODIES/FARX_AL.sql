--------------------------------------------------------
--  DDL for Package Body FARX_AL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_AL" as
  /* $Header: farxalb.pls 120.17.12010000.6 2010/02/04 18:47:09 mswetha ship $ */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE asset_listing_run(book           in   varchar2,
                            period         in   varchar2,
                            from_bal       in   varchar2,
                            to_bal         in   varchar2,
                            from_acct      in   varchar2,
                            to_acct        in   varchar2,
                            from_cc        in   varchar2,
                            to_cc          in   varchar2,
                            major_category in   varchar2,
                            minor_category in   varchar2,
                            cat_seg_num    in   varchar2,
                            cat_seg_val    in   varchar2,
                            prop_type      in   varchar2,
                            fully_reserved in   varchar2,
                            nbv            in   number,
                            cat_deprn_flag in   varchar2,
                            bought         in   varchar2,
                            sob_id         in   varchar2 default NULL,
                            request_id     in   number,
                            login_id       in   number,
                            retcode        out nocopy  number,
                            errbuf         out nocopy  VARCHAR2) IS

   h_request_id                 number;
   mesg                         varchar2(200);
   h_book                       varchar2(15);
   h_period                     varchar2(15);
   cat_flex_struct              number;
   loc_flex_struct              number;
   assetkey_flex_struct         number;
   acct_flex_struct             number;
   h_currency_code              varchar2(15);
   h_bal_segnum                 number;
   h_acct_segnum                number;
   h_cc_segnum                  number;
   acct_all_segs                fa_rx_shared_pkg.Seg_Array;
   cat_segs                     fa_rx_shared_pkg.Seg_Array;
   loc_segs                     fa_rx_shared_pkg.Seg_Array;
   concat_cat_str               varchar2(500);
   concat_loc_str               varchar2(500);
   concat_acct_str              varchar2(500);
   h_fy_name                    fa_fiscal_year.fiscal_year_name%type; -- fix for bug 3286727
   h_life                       number;
   h_ccid                       number;
   h_asset_cost_acct            varchar2(25);
   h_deprn_rsv_acct             varchar2(25);
   h_asset_number               varchar2(15);
   h_description                varchar2(80);
   h_dpis                       date;
   h_method_code                varchar2(15);
   h_rate                       number;
   h_capacity                   number;
   h_cost                       number;
   h_percent                    number;
   h_deprn_amount               number;
   h_ytd_deprn                  number;
   h_reserve                    number;
   h_transaction_Type           varchar2(1);
   h_category_id                number;
   h_location_id                number;
   h_tag_number                 varchar2(15);
   h_serial_number              varchar2(35);
   h_inventorial                varchar2(3);
   h_user_id                    number;
   h_account_description        varchar2(240);
   h_asset_key_ccid             number;
   concat_key_str               varchar2(500);
   key_segs                     fa_rx_shared_pkg.Seg_Array;
   return_status                boolean;
   acct_appl_col                varchar2(240);
   acct_segname                 varchar2(240);
   acct_prompt                  varchar2(240);
   acct_valueset_name           varchar2(240);
   h_asset_type                 varchar2(1);
   h_assigned_to                number;
   h_emp_name                   VARCHAR2(50); --varchar2(240);
   h_emp_number                 VARCHAR2(15); -- varchar2(30);
   h_asset_id                   number;
   h_category_description       varchar2(240);
   h_units                      number;
   ucd                          date;
   upc                          number;
   l_param_where                varchar2(2000);
   h_company_description        varchar2(240);
   h_expense_acct_description   varchar2(240);
   h_cost_center_description    varchar2(240);
   h_major_category             varchar2(30);
   h_minor_category             varchar2(30);
   h_chart_of_accounts_id       number;
   h_organization_name          varchar2(30);
   h_set_of_books_id            number;
   h_book_deprn_flag            varchar2(20);
   h_category_deprn_flag        varchar2(20);
    TYPE cur IS ref cursor;
   asset_lst_rows               cur;
   sql_stmt                     varchar2(30000);
   h_mesg_name                  varchar2(30);
   h_mesg_str                   varchar2(2000);
   h_ccid_error                 number;
   h_flex_error                 varchar2(5);
   flag                         varchar2(1);

   maj_select_column            varchar2(50);
   min_select_column            varchar2(50);

   h_is_retired                 number; -- added this for bug 2681076

--+ Bug#2953964: Bind Variable Project --
   h_from_bal                   varchar2(25);
   h_to_bal                     varchar2(25);
   h_from_acct                  varchar2(25);
   h_to_acct                    varchar2(25);
   h_from_cc                    varchar2(25);
   h_to_cc                      varchar2(25);
   h_cat_seg_num                varchar2(50);
   h_cat_seg_val                varchar2(30);
   h_prop_type                  varchar2(30);
   h_bought                     varchar2(30);
   h_sob_id                     number;
   H_MRCSOBTYPE                 varchar2(1);
   -- used to store original sob info upon entry into api
   l_orig_set_of_books_id    number;
   l_orig_currency_context   varchar2(64);

BEGIN
   --
   -- For debug
   --
   h_sob_id := to_number(sob_id);
   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('asset_listing_run: ' || 'BEGIN REPORT');
   END IF;
   retcode := 2;
   h_book           := book;
   h_period         := period;
   h_request_id     := request_id;
   h_major_category := major_category;
   h_minor_category := minor_category;

--+ Bug#2953964 +----
   h_from_bal       := from_bal;
   h_to_bal         := to_bal;
   h_from_acct      := from_acct;
   h_to_acct        := to_acct;
   h_from_cc        := from_cc;
   h_to_cc          := to_cc;
   h_cat_seg_num    := cat_seg_num;
   h_cat_seg_val    := cat_seg_val;
   h_prop_type      := prop_type;
   h_bought         := bought;

   fnd_profile.get('USER_ID',h_user_id);
   fnd_profile.get ('GL_SET_OF_BKS_ID',l_orig_set_of_books_id);
   l_orig_currency_context :=  SUBSTRB(USERENV('CLIENT_INFO'),45,10);
   -- Set the gl_sob profile to this book
   fnd_profile.put('GL_SET_OF_BKS_ID', h_sob_id);
   fnd_client_info.set_currency_context (h_sob_id);
  if h_sob_id <> -1999 then
    begin
       select 'P'
       into H_MRCSOBTYPE
       from fa_book_controls
       where book_type_code = h_book
       and set_of_books_id = h_sob_id;
    exception
       when others then
           H_MRCSOBTYPE := 'R';
    end;
  else
    H_MRCSOBTYPE := 'P';
  end if;

   SELECT CATEGORY_FLEX_STRUCTURE,
          LOCATION_FLEX_STRUCTURE,
          ASSET_KEY_FLEX_STRUCTURE
   INTO   cat_flex_struct,
          loc_flex_struct,
          assetkey_flex_struct
   FROM   FA_SYSTEM_CONTROLS;

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK                 => h_book,
   BALANCING_SEGNUM     => h_bal_segnum,
   ACCOUNT_SEGNUM       => h_acct_segnum,
   CC_SEGNUM            => h_cc_segnum,
   CALLING_FN           => 'ASSET_LISTING_REP');

   if(H_MRCSOBTYPE <> 'R')then

        SELECT BC.ACCOUNTING_FLEX_STRUCTURE,
          SOB.CURRENCY_CODE,
          BC.FISCAL_YEAR_NAME,
          SOB.CHART_OF_ACCOUNTS_ID,
          SOB.NAME,
          SOB.SET_OF_BOOKS_ID
        INTO   acct_flex_struct,
          h_currency_code,
          h_fy_name,
          h_chart_of_accounts_id,
          h_organization_name,
          h_set_of_books_id
        FROM   FA_BOOK_CONTROLS         BC,
          GL_SETS_OF_BOOKS      SOB
        WHERE  BC.BOOK_TYPE_CODE   = h_book
        AND    SOB.SET_OF_BOOKS_ID = BC.SET_OF_BOOKS_ID;
   else
        SELECT BC.ACCOUNTING_FLEX_STRUCTURE,
          SOB.CURRENCY_CODE,
          BC.FISCAL_YEAR_NAME,
          SOB.CHART_OF_ACCOUNTS_ID,
          SOB.NAME,
          SOB.SET_OF_BOOKS_ID
        INTO   acct_flex_struct,
          h_currency_code,
          h_fy_name,
          h_chart_of_accounts_id,
          h_organization_name,
          h_set_of_books_id
        FROM   FA_BOOK_CONTROLS_mrc_v   BC,
          GL_SETS_OF_BOOKS      SOB
        WHERE  BC.BOOK_TYPE_CODE   = h_book
        AND    SOB.SET_OF_BOOKS_ID = BC.SET_OF_BOOKS_ID;
   END if;

   return_status := FND_FLEX_APIS.GET_SEGMENT_INFO
                        (101, 'GL#', Acct_Flex_Struct, h_Acct_Segnum,
                         Acct_Appl_Col, Acct_Segname, Acct_Prompt, Acct_Valueset_Name);

   if(H_MRCSOBTYPE <> 'R') then
        SELECT PERIOD_COUNTER,
          NVL(PERIOD_CLOSE_DATE, SYSDATE)
        INTO   upc,
          ucd
        FROM   FA_DEPRN_PERIODS
        WHERE  BOOK_TYPE_CODE = h_book
        AND    PERIOD_NAME    = h_period;
   else
        SELECT PERIOD_COUNTER,
          NVL(PERIOD_CLOSE_DATE, SYSDATE)
        INTO   upc,
          ucd
        FROM   FA_DEPRN_PERIODS_mrc_v
        WHERE  BOOK_TYPE_CODE = h_book
        AND    PERIOD_NAME    = h_period;
   END if;
   --
   -- Additional where clause are created using the parameters dynamically
   --
   l_param_where := null;

   -- BALANCING --
   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'CC',
        'SELECT', 'GL_BALANCING') ||' >= :from_bal or :from_bal is NULL)';

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'CC',
        'SELECT', 'GL_BALANCING') ||' <= :to_bal or :to_bal is NULL)';

   -- ACCOUNT --
   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'CC',
        'SELECT', 'GL_ACCOUNT') ||' >= :from_acct or :from_acct is NULL)';

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'CC',
        'SELECT', 'GL_ACCOUNT') ||' <= :to_acct or :to_acct is NULL)';

   -- COST CENTER --
   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'CC',
        'SELECT', 'FA_COST_CTR') ||' >= :from_cc or :from_cc is NULL)';

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'CC',
        'SELECT', 'FA_COST_CTR') ||' <= :to_cc or :to_cc is NULL)';

  -- Major Category --
   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', cat_flex_struct,'CAT',
        'SELECT', 'BASED_CATEGORY') ||'= :major_category or :major_category is NULL)';

   -- Minor Category --
   begin
     l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', cat_flex_struct,'CAT',
        'SELECT', 'MINOR_CATEGORY') ||'= :minor_category or :minor_category is NULL)';
   exception
     when others then
       l_param_where := l_param_where || ' AND (:minor_category is NULL and :minor_category is NULL)';
   end;


   -- Property Type --
   l_param_where := l_param_where || ' AND (CAT.PROPERTY_TYPE_CODE = :prop_type or :prop_type is null)';

   -- Fully Reserved --
   flag := substr(upper(fully_reserved), 1,1);
   IF (flag = 'Y') THEN
      l_param_where := l_param_where ||
        ' AND BOOKS.PERIOD_COUNTER_FULLY_RESERVED <= ' || upc;
   ELSIF (flag = 'N') THEN
      l_param_where := l_param_where ||
        ' AND (BOOKS.PERIOD_COUNTER_FULLY_RESERVED is null OR' ||
        '      BOOKS.PERIOD_COUNTER_FULLY_RESERVED > ' || upc || ')';
   END IF;

   -- Category Depreciation Flag --
   flag := substr(upper(cat_deprn_flag), 1,1);
   IF (flag = 'N') THEN
      l_param_where := l_param_where ||
        ' AND  CAT.CAPITALIZE_FLAG = ''NO'' AND CAT.OWNED_LEASED = ''LEASED''';
   END IF;

   -- Bought --
   l_param_where := l_param_where || ' AND AD.NEW_USED = nvl(:bought,AD.NEW_USED)';

   --

   -- Category Segment Number --
   IF (cat_seg_num IS NOT NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', cat_flex_struct,'CAT',
        'SELECT',cat_seg_num) || '= :cat_seg_val';
   END IF;

   --
   -- Get Columns for Major_category and Minor_category
   --
   maj_select_column := null;
   min_select_column := null;

   maj_select_column := fa_rx_flex_pkg.flex_sql(140,'CAT#',cat_flex_struct,'CAT','SELECT','BASED_CATEGORY');
   maj_select_column := maj_select_column || '     MAJOR_CATEGORY';

   begin
     min_select_column := fa_rx_flex_pkg.flex_sql(140,'CAT#',cat_flex_struct,'CAT','SELECT','MINOR_CATEGORY');
     min_select_column := min_select_column || '      MINOR_CATEGORY';
    exception
      when others then
        min_select_column := 'NULL';
   end;

   --
   -- Main Select Statment
   --
   if(H_MRCSOBTYPE <> 'R') then
        sql_stmt :=
        'SELECT DISTINCT
                CB.ASSET_COST_ACCT                                      COST_ACCOUNT,
                CB.DEPRN_RESERVE_ACCT                                   RSV_ACCOUNT,
                AH.CATEGORY_ID                                          CATEGORY_ID,
                BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
                BOOKS.DEPRN_METHOD_CODE                                 METHOD,
                BOOKS.LIFE_IN_MONTHS                                    LIFE,
                BOOKS.ADJUSTED_RATE                                     RATE,
                BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
                BOOKS.DEPRECIATE_FLAG                                   BOOK_DEPRN_FLAG,
                DH.LOCATION_ID                                          LOCATION_ID,
                DH.ASSIGNED_TO                                          ASSIGNED_TO,
                DH.UNITS_ASSIGNED / AH.UNITS * 100                      PERCENT,
                substrb(EMP.full_name, 1, 50)                           EMP_NAME,
                substrb(EMP.employee_number, 1, 15)                     EMP_NUMBER, --Bug#9206900
                CC.CODE_COMBINATION_ID                                  CCID,
                AH.ASSET_ID                                             ASSET_ID,
                AD.ASSET_NUMBER                                         ASSET_NUMBER,
                AD.DESCRIPTION                                          ASSET_DESCRIPTION,
                AD.TAG_NUMBER                                           TAG_NUMBER,
                AD.serial_number                                        SERIAL_NUMBER,
                AD.INVENTORIAL                                          INVENTORIAL,
                AD.ASSET_KEY_CCID                                       ASSET_KEY_CCID,
                DECODE(AD.ASSET_TYPE,''CIP'',''C'',''EXPENSED'',''E'','''')     ASSET_TYPE,
                CBD.DEPRECIATE_FLAG                                     CATEGORY_DEPRN_FLAG, ' ||
                maj_select_column || ' , ' || min_select_column || '
        FROM
                FA_CATEGORY_BOOKS       CB,
                FA_ASSET_HISTORY        AH,
                FA_BOOKS                BOOKS,
                FA_DISTRIBUTION_HISTORY DH,
                GL_CODE_COMBINATIONS    CC,
                PER_PEOPLE_F            EMP,
                FA_ADDITIONS            AD,
                FA_CATEGORIES           CAT,
                FA_CATEGORY_BOOK_DEFAULTS CBD,
                FA_BOOK_CONTROLS        BC      -- Added for bug#2675646
        WHERE
                CB.BOOK_TYPE_CODE               =  :h_book                      AND
                CB.CATEGORY_ID                  =  AH.CATEGORY_ID
        AND
                AH.ASSET_ID                     =  DH.ASSET_ID AND
                AH.DATE_EFFECTIVE               <= :ucd                         AND
                NVL(AH.DATE_INEFFECTIVE,:ucd+1)  > :ucd
        AND
                BOOKS.BOOK_TYPE_CODE            = :h_book                       AND
                BOOKS.ASSET_ID                  = DH.ASSET_ID AND
                nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, :upc) >= :upc           AND
                BOOKS.DATE_EFFECTIVE            <=  :ucd                        AND
                nvl(BOOKS.DATE_INEFFECTIVE,:ucd+1)> :ucd
        AND   -- Added for Bug#2675646
                BC.BOOK_TYPE_CODE               =  :h_book
        AND
                DH.BOOK_TYPE_CODE               =  nvl(BC.DISTRIBUTION_SOURCE_BOOK, :h_book)    AND -- Changed from = :h_book
                DH.DATE_EFFECTIVE               <= :ucd                         AND
                nvl(DH.DATE_INEFFECTIVE,:ucd+1) >  :ucd                         AND
                DH.CODE_COMBINATION_ID          = CC.CODE_COMBINATION_ID        AND
                DH.ASSIGNED_TO                  = EMP.PERSON_ID(+)
        AND     trunc(sysdate)  between emp.effective_start_date(+) and emp.effective_end_date(+)
        AND     AD.ASSET_ID                     = AH.ASSET_ID
        AND     CAT.CATEGORY_ID                 = AH.CATEGORY_ID
        AND     CBD.CATEGORY_ID                 = CAT.CATEGORY_ID               AND
                CBD.BOOK_TYPE_CODE              = :h_book                       AND
                CBD.START_DPIS                  <= BOOKS.DATE_PLACED_IN_SERVICE  AND -- Changed for Bug:5276352
                nvl(CBD.END_DPIS,sysdate)       >= BOOKS.DATE_PLACED_IN_SERVICE';
   else
        sql_stmt :=
        'SELECT DISTINCT
                CB.ASSET_COST_ACCT                                      COST_ACCOUNT,
                CB.DEPRN_RESERVE_ACCT                                   RSV_ACCOUNT,
                AH.CATEGORY_ID                                          CATEGORY_ID,
                BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
                BOOKS.DEPRN_METHOD_CODE                                 METHOD,
                BOOKS.LIFE_IN_MONTHS                                    LIFE,
                BOOKS.ADJUSTED_RATE                                     RATE,
                BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
                BOOKS.DEPRECIATE_FLAG                                   BOOK_DEPRN_FLAG,
                DH.LOCATION_ID                                          LOCATION_ID,
                DH.ASSIGNED_TO                                          ASSIGNED_TO,
                DH.UNITS_ASSIGNED / AH.UNITS * 100                      PERCENT,
                substrb(EMP.full_name, 1, 50)                           EMP_NAME,
                substrb(EMP.employee_number, 1, 15)                     EMP_NUMBER, --Bug#9206900
                CC.CODE_COMBINATION_ID                                  CCID,
                AH.ASSET_ID                                             ASSET_ID,
                AD.ASSET_NUMBER                                         ASSET_NUMBER,
                AD.DESCRIPTION                                          ASSET_DESCRIPTION,
                AD.TAG_NUMBER                                           TAG_NUMBER,
                AD.serial_number                                        SERIAL_NUMBER,
                AD.INVENTORIAL                                          INVENTORIAL,
                AD.ASSET_KEY_CCID                                       ASSET_KEY_CCID,
                DECODE(AD.ASSET_TYPE,''CIP'',''C'',''EXPENSED'',''E'','''')     ASSET_TYPE,
                CBD.DEPRECIATE_FLAG                                     CATEGORY_DEPRN_FLAG, ' ||
                maj_select_column || ' , ' || min_select_column || '
        FROM
                FA_CATEGORY_BOOKS       CB,
                FA_ASSET_HISTORY        AH,
                FA_BOOKS_mrc_v          BOOKS,
                FA_DISTRIBUTION_HISTORY DH,
                GL_CODE_COMBINATIONS    CC,
                PER_PEOPLE_F            EMP,
                FA_ADDITIONS            AD,
                FA_CATEGORIES           CAT,
                FA_CATEGORY_BOOK_DEFAULTS CBD,
                FA_BOOK_CONTROLS_mrc_v  BC      -- Added for bug#2675646
        WHERE
                CB.BOOK_TYPE_CODE               =  :h_book                      AND
                CB.CATEGORY_ID                  =  AH.CATEGORY_ID
        AND
                AH.ASSET_ID                     =  DH.ASSET_ID AND
                AH.DATE_EFFECTIVE               <= :ucd                         AND
                NVL(AH.DATE_INEFFECTIVE,:ucd+1)  > :ucd
        AND
                BOOKS.BOOK_TYPE_CODE            = :h_book                       AND
                BOOKS.ASSET_ID                  = DH.ASSET_ID AND
                nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, :upc) >= :upc           AND
                BOOKS.DATE_EFFECTIVE            <=  :ucd                        AND
                nvl(BOOKS.DATE_INEFFECTIVE,:ucd+1)> :ucd
        AND   -- Added for Bug#2675646
                BC.BOOK_TYPE_CODE               =  :h_book
        AND
                DH.BOOK_TYPE_CODE               =  nvl(BC.DISTRIBUTION_SOURCE_BOOK, :h_book)    AND -- Changed from = :h_book
                DH.DATE_EFFECTIVE               <= :ucd                         AND
                nvl(DH.DATE_INEFFECTIVE,:ucd+1) >  :ucd                         AND
                DH.CODE_COMBINATION_ID          = CC.CODE_COMBINATION_ID        AND
                DH.ASSIGNED_TO                  = EMP.PERSON_ID(+)
        AND     trunc(sysdate)  between emp.effective_start_date(+) and emp.effective_end_date(+)
        AND     AD.ASSET_ID                     = AH.ASSET_ID
        AND     CAT.CATEGORY_ID                 = AH.CATEGORY_ID
        AND     CBD.CATEGORY_ID                 = CAT.CATEGORY_ID               AND
                CBD.BOOK_TYPE_CODE              = :h_book                       AND
                CBD.START_DPIS                  <= BOOKS.DATE_PLACED_IN_SERVICE  AND -- Changed for Bug:5276352
                nvl(CBD.END_DPIS,sysdate)       >= BOOKS.DATE_PLACED_IN_SERVICE';
   end if;

   sql_stmt := sql_stmt || l_param_where;

   IF (cat_seg_num IS NOT NULL) THEN

     OPEN asset_lst_rows FOR sql_stmt
       using h_book,ucd,ucd,ucd,h_book,upc,upc,ucd,ucd,ucd,h_book,h_book,ucd,ucd,ucd,h_book,
             h_from_bal,h_from_bal,h_to_bal,h_to_bal,h_from_acct,h_from_acct,h_to_acct,h_to_acct,
             h_from_cc,h_from_cc,h_to_cc,h_to_cc,h_major_category,h_major_category,
             h_minor_category,h_minor_category,h_prop_type,h_prop_type,h_bought,h_cat_seg_val;

   ELSE

     OPEN asset_lst_rows FOR sql_stmt
       using h_book,ucd,ucd,ucd,h_book,upc,upc,ucd,ucd,ucd,h_book,h_book,ucd,ucd,ucd,h_book,
             h_from_bal,h_from_bal,h_to_bal,h_to_bal,h_from_acct,h_from_acct,h_to_acct,h_to_acct,
             h_from_cc,h_from_cc,h_to_cc,h_to_cc,h_major_category,h_major_category,
             h_minor_category,h_minor_category,h_prop_type,h_prop_type,h_bought;

   END IF;

/*   OPEN asset_lst_rows FOR sql_stmt
     using h_book,ucd,ucd,ucd,h_book,upc,upc,ucd,ucd,ucd,h_book,h_book,ucd,ucd,ucd,h_book;
*/
   LOOP
     h_mesg_name := 'FA_ASSET_LISTING_SQL_FCUR';
     IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('asset_listing_run: ' || h_mesg_name);
     END IF;
     FETCH asset_lst_rows INTO
           h_asset_cost_acct,
           h_deprn_rsv_acct,
           h_category_id,
           h_dpis,
           h_method_code,
           h_life,
           h_rate,
           h_capacity,
           h_book_deprn_flag,
           h_location_id,
           h_assigned_to,
           h_percent,
           h_emp_name,
           h_emp_number,
           h_ccid,
           h_asset_id,
           h_asset_number,
           h_description,
           h_tag_number,
           h_serial_number,
           h_inventorial,
           h_asset_key_ccid,
           h_asset_type,
           h_category_deprn_flag,
           h_major_category,
           h_minor_category;

     IF (asset_lst_rows%NOTFOUND) THEN
        exit;
     END IF;

     h_mesg_name := 'FA_RX_FETCH_CUR';
     IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('asset_listing_run: ' || h_mesg_name);
     END IF;

     h_account_description :=
     fa_rx_shared_pkg.get_flex_val_meaning(NULL, acct_valueset_name, h_asset_cost_acct);

     h_mesg_name := 'FA_RX_CONCAT_SEGS';
     h_flex_error := 'GL#';
     h_ccid_error := h_ccid;

     fa_rx_shared_pkg.concat_acct (
           struct_id     => acct_flex_struct,
           ccid          => h_ccid,
           concat_string => concat_acct_str,
           segarray      => acct_all_segs);

     h_flex_error := 'CAT#';
     h_ccid_error := h_category_id;

     fa_rx_shared_pkg.concat_category (
           struct_id     => cat_flex_struct,
           ccid          => h_category_id,
           concat_string => concat_cat_str,
           segarray      => cat_segs);

     h_flex_error := 'LOC#';
     h_ccid_error := h_location_id;

     fa_rx_shared_pkg.concat_location (
           struct_id     => loc_flex_struct,
           ccid          => h_location_id,
           concat_string => concat_loc_str,
           segarray      => loc_segs);

     IF (h_asset_key_ccid is not NULL) THEN
        h_flex_error := 'KEY#';
        h_ccid_error := h_asset_key_ccid;

        fa_rx_shared_pkg.concat_asset_key (
              struct_id     => assetkey_flex_struct,
              ccid          => h_asset_key_ccid,
              concat_string => concat_key_str,
              segarray      => key_segs);

     ELSE
        concat_key_str := '';  --bug#7456179
     END IF;

     h_company_description :=
       fa_rx_flex_pkg.get_description(
         p_application_id => 101,
         p_id_flex_code   => 'GL#',
         p_id_flex_num    => h_chart_of_accounts_id,
         p_qualifier      => 'GL_BALANCING',
         p_data           => acct_all_segs(h_bal_segnum));

     h_expense_acct_description :=
       fa_rx_flex_pkg.get_description(
         p_application_id => 101,
         p_id_flex_code   => 'GL#',
         p_id_flex_num    => h_chart_of_accounts_id,
         p_qualifier      => 'GL_ACCOUNT',
         p_data           => acct_all_segs(h_acct_segnum));

     h_cost_center_description :=
       fa_rx_flex_pkg.get_description(
         p_application_id => 101,
         p_id_flex_code   => 'GL#',
         p_id_flex_num    => h_chart_of_accounts_id,
         p_qualifier      => 'FA_COST_CTR',
         p_data           => acct_all_segs(h_cc_segnum));

     h_mesg_name := 'FA_SHARED_INSERT_FAILED';
     h_is_retired := 0; -- added this for bug 2681076

-- check whether the Asset is Fully Retired and Processed
-- added this for bug 2681076
   if(H_MRCSOBTYPE <> 'R') then
	SELECT count(*) INTO h_is_retired
	FROM FA_RETIREMENTS RET,
	     fa_transaction_headers th
	WHERE RET.ASSET_ID = h_asset_id
	and ret.book_type_code = h_book
	AND trunc(RET.DATE_EFFECTIVE) <= ucd
	AND RET.STATUS in  ('PROCESSED','REINSTATE')
	and th.transaction_header_id = ret.transaction_header_id_in
	and th.transaction_type_code = 'FULL RETIREMENT';
   else
	SELECT count(*) INTO h_is_retired
	FROM FA_RETIREMENTS_mrc_v RET,
	     fa_transaction_headers th
	WHERE RET.ASSET_ID = h_asset_id
	and ret.book_type_code = h_book
	AND trunc(RET.DATE_EFFECTIVE) <= ucd
	AND RET.STATUS in  ('PROCESSED','REINSTATE')
	and th.transaction_header_id = ret.transaction_header_id_in
	and th.transaction_type_code = 'FULL RETIREMENT';
   end if;

     IF h_is_retired = 0 THEN -- added this for bug 2681076
        --the asset is not Fully Retired and the Report Should display the asset.

     --
     -- Each time the main select statement gets the row, the following query is executed.
     -- This is used to sum up units, cost, and reserve, in case, multiple distributions share
     -- the same location and the same employee.
     --
-- This union should be analyzed further to improve performance,
-- however, solution in v.115.18 is not working due to no data found
-- error for select into construct.
      if(H_MRCSOBTYPE <> 'R') then
	SELECT
                SUM(COST),
                SUM(RESERVE),
                SUM(DEPRN_AMOUNT),
                SUM(UNITS)
        INTO    h_cost,
                h_reserve,
                h_deprn_amount,
                h_units
        FROM(
        SELECT
                DECODE(DD.DEPRN_SOURCE_CODE,'B',
                       DD.ADDITION_COST_TO_CLEAR,DD.COST)               COST,
                DD.DEPRN_RESERVE                                        RESERVE,
                DECODE(DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT,0)       DEPRN_AMOUNT,
                DH.UNITS_ASSIGNED                                       UNITS
        FROM
                FA_DEPRN_DETAIL                 DD,
                FA_DISTRIBUTION_HISTORY         DH,
                FA_BOOK_CONTROLS                BC  -- Added for Bug#2675646
        WHERE
                DD.ASSET_ID             = h_asset_id                            AND
                DD.BOOK_TYPE_CODE       = h_book                                AND
                DD.DISTRIBUTION_ID      = DH.DISTRIBUTION_ID                    AND
                DD.PERIOD_COUNTER       =
                        (SELECT MAX(DD2.PERIOD_COUNTER)
                         FROM   FA_DEPRN_DETAIL DD2
                         WHERE  DD2.BOOK_TYPE_CODE      = h_book
                         AND    DD2.ASSET_ID            = h_asset_id
                         AND    DD2.DISTRIBUTION_ID     = DD.DISTRIBUTION_ID
                         AND    DD2.PERIOD_COUNTER      <= upc)
        AND  -- Added for Bug#2675646
                BC.BOOK_TYPE_CODE       = h_book
        AND
                DH.ASSET_ID             = h_asset_id and
                DH.BOOK_TYPE_CODE       = nvl(BC.DISTRIBUTION_SOURCE_BOOK,h_book)       AND
                DH.LOCATION_ID          = h_location_id                 AND
                (DH.ASSIGNED_TO         = h_assigned_to  OR
                 (DH.ASSIGNED_TO is null and h_assigned_to is null))    AND
                DH.CODE_COMBINATION_ID  = h_ccid                        AND
                DH.DATE_EFFECTIVE               <= ucd                  AND
                nvl(DH.DATE_INEFFECTIVE, ucd+1) >  ucd
        union all
        SELECT
                0 COST,
                0 RESERVE,
                DECODE(DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT,0)       DEPRN_AMOUNT,
                0 UNITS
        FROM
                FA_DEPRN_DETAIL                 DD,
                FA_DISTRIBUTION_HISTORY         DH,
                FA_DISTRIBUTION_HISTORY         DH_PRIOR,
                FA_BOOK_CONTROLS                BC  -- Added for Bug#2675646
        WHERE
                DD.ASSET_ID             = h_asset_id                            AND
                DD.BOOK_TYPE_CODE       = h_book                                AND
                DD.DISTRIBUTION_ID      = DH_PRIOR.DISTRIBUTION_ID                      AND
                DD.PERIOD_COUNTER       =
                        (SELECT MAX(DD2.PERIOD_COUNTER)
                         FROM   FA_DEPRN_DETAIL DD2
                         WHERE  DD2.BOOK_TYPE_CODE      = h_book
                         AND    DD2.ASSET_ID            = h_asset_id
                         AND    DD2.DISTRIBUTION_ID     = DD.DISTRIBUTION_ID
                         AND    DD2.PERIOD_COUNTER      <= upc)
        AND  -- Added for Bug#2675646
                BC.BOOK_TYPE_CODE       = h_book
        AND
                dh.transaction_header_id_in = dh_prior.transaction_header_id_out
        and     dh.asset_id = dh_prior.asset_id
        and     dh.book_type_code = dh_prior.book_type_code
        -- Bug 7565805
        /*and
                DH.ASSET_ID             = h_asset_id and
                DH.BOOK_TYPE_CODE       = nvl(BC.DISTRIBUTION_SOURCE_BOOK,h_book)       AND
                DH.LOCATION_ID          = h_location_id                 AND
                (DH.ASSIGNED_TO         = h_assigned_to  OR
                 (DH.ASSIGNED_TO is null and h_assigned_to is null))    AND
                DH.CODE_COMBINATION_ID  = h_ccid                        AND
                DH.DATE_EFFECTIVE               <= ucd                  AND
                nvl(DH.DATE_INEFFECTIVE, ucd+1) >  ucd                   */
        UNION ALL
        SELECT
                DECODE(LU.LOOKUP_CODE, 'ADDITION COST',
                        DECODE(ADJ.DEBIT_CREDIT_FLAG, 'DR', 1, -1) *
                                ADJ.ADJUSTMENT_AMOUNT,0)                COST,
                DECODE(LU.LOOKUP_CODE,
                        'DEPRECIATION RESERVE',
                        DECODE(ADJ.DEBIT_CREDIT_FLAG, 'DR', -1, 1) *
                        ADJ.ADJUSTMENT_AMOUNT, 0)                       RESERVE,
                0                                                       DEPRN_AMOUNT,
                DECODE(LU.LOOKUP_CODE,
                        'ADDITION COST',
                        DECODE(ADJ.DEBIT_CREDIT_FLAG, 'DR', 1, -1) *
                        DH.UNITS_ASSIGNED,0)                            UNITS
        FROM
                FA_ADJUSTMENTS                  ADJ,
                FA_LOOKUPS                      LU,
                FA_DISTRIBUTION_HISTORY         DH,
                FA_BOOK_CONTROLS                BC  -- Added for Bug#2675646
        WHERE
                LU.LOOKUP_TYPE          = 'JOURNAL ENTRIES'                     AND
                ((ADJ.ADJUSTMENT_TYPE IN ('COST','CIP COST') AND
                  LU.LOOKUP_CODE = 'ADDITION COST')
                  OR
                 (ADJ.ADJUSTMENT_TYPE   = 'RESERVE'          AND
                  LU.LOOKUP_CODE        = 'DEPRECIATION RESERVE'))              AND
                ADJ.SOURCE_TYPE_CODE NOT IN
                        ('DEPRECIATION','ADDITION', 'CIP ADDITION')             AND
                ADJ.BOOK_TYPE_CODE      = h_book                                AND
                ADJ.ASSET_ID            = h_asset_id                            AND
                ADJ.DISTRIBUTION_ID     = DH.DISTRIBUTION_ID                    AND
                ADJ.PERIOD_COUNTER_CREATED = upc
        AND  -- Added for Bug#2675646
                BC.BOOK_TYPE_CODE       = h_book
        AND
                DH.ASSET_ID             = h_asset_id                            AND
                DH.BOOK_TYPE_CODE       = nvl(BC.DISTRIBUTION_SOURCE_BOOK,h_book) AND -- Changed from = h_book
                DH.LOCATION_ID          = h_location_id                         AND
                DH.DATE_EFFECTIVE               <= ucd                  AND
                nvl(DH.DATE_INEFFECTIVE, ucd+1) >  ucd                  AND
                (DH.ASSIGNED_to         = h_assigned_to  OR
                 (DH.ASSIGNED_TO is null and h_assigned_to is null))    AND
                (NOT EXISTS (SELECT 1 FROM FA_DEPRN_DETAIL DD
                             WHERE  DD.ASSET_ID       = h_asset_id
                             AND    DD.BOOK_TYPE_CODE = h_book
                             AND    DD.PERIOD_COUNTER = upc)));
      else/* else */

	SELECT
                SUM(COST),
                SUM(RESERVE),
                SUM(DEPRN_AMOUNT),
                SUM(UNITS)
        INTO    h_cost,
                h_reserve,
                h_deprn_amount,
                h_units
        FROM(
        SELECT
                DECODE(DD.DEPRN_SOURCE_CODE,'B',
                       DD.ADDITION_COST_TO_CLEAR,DD.COST)               COST,
                DD.DEPRN_RESERVE                                        RESERVE,
                DECODE(DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT,0)       DEPRN_AMOUNT,
                DH.UNITS_ASSIGNED                                       UNITS
        FROM
                FA_DEPRN_DETAIL_mrc_v           DD,
                FA_DISTRIBUTION_HISTORY         DH,
                FA_BOOK_CONTROLS_mrc_v          BC  -- Added for Bug#2675646
        WHERE
                DD.ASSET_ID             = h_asset_id                            AND
                DD.BOOK_TYPE_CODE       = h_book                                AND
                DD.DISTRIBUTION_ID      = DH.DISTRIBUTION_ID                    AND
                DD.PERIOD_COUNTER       =
                        (SELECT MAX(DD2.PERIOD_COUNTER)
                         FROM   FA_DEPRN_DETAIL_mrc_v DD2
                         WHERE  DD2.BOOK_TYPE_CODE      = h_book
                         AND    DD2.ASSET_ID            = h_asset_id
                         AND    DD2.DISTRIBUTION_ID     = DD.DISTRIBUTION_ID
                         AND    DD2.PERIOD_COUNTER      <= upc)
        AND  -- Added for Bug#2675646
                BC.BOOK_TYPE_CODE       = h_book
        AND
                DH.ASSET_ID             = h_asset_id and
                DH.BOOK_TYPE_CODE       = nvl(BC.DISTRIBUTION_SOURCE_BOOK,h_book)       AND
                DH.LOCATION_ID          = h_location_id                 AND
                (DH.ASSIGNED_TO         = h_assigned_to  OR
                 (DH.ASSIGNED_TO is null and h_assigned_to is null))    AND
                DH.CODE_COMBINATION_ID  = h_ccid                        AND
                DH.DATE_EFFECTIVE               <= ucd                  AND
                nvl(DH.DATE_INEFFECTIVE, ucd+1) >  ucd
        union all
        SELECT
                0 COST,
                0 RESERVE,
                DECODE(DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT,0)       DEPRN_AMOUNT,
                0 UNITS
        FROM
                FA_DEPRN_DETAIL_mrc_v           DD,
                FA_DISTRIBUTION_HISTORY         DH,
                FA_DISTRIBUTION_HISTORY         DH_PRIOR,
                FA_BOOK_CONTROLS_mrc_v          BC  -- Added for Bug#2675646
        WHERE
                DD.ASSET_ID             = h_asset_id                            AND
                DD.BOOK_TYPE_CODE       = h_book                                AND
                DD.DISTRIBUTION_ID      = DH_PRIOR.DISTRIBUTION_ID                      AND
                DD.PERIOD_COUNTER       =
                        (SELECT MAX(DD2.PERIOD_COUNTER)
                         FROM   FA_DEPRN_DETAIL_mrc_v DD2
                         WHERE  DD2.BOOK_TYPE_CODE      = h_book
                         AND    DD2.ASSET_ID            = h_asset_id
                         AND    DD2.DISTRIBUTION_ID     = DD.DISTRIBUTION_ID
                         AND    DD2.PERIOD_COUNTER      <= upc)
        AND  -- Added for Bug#2675646
                BC.BOOK_TYPE_CODE       = h_book
        AND
                dh.transaction_header_id_in = dh_prior.transaction_header_id_out
        and     dh.asset_id = dh_prior.asset_id
        and     dh.book_type_code = dh_prior.book_type_code
        -- Bug 7565805
        /*and
                DH.ASSET_ID             = h_asset_id and
                DH.BOOK_TYPE_CODE       = nvl(BC.DISTRIBUTION_SOURCE_BOOK,h_book)       AND
                DH.LOCATION_ID          = h_location_id                 AND
                (DH.ASSIGNED_TO         = h_assigned_to  OR
                 (DH.ASSIGNED_TO is null and h_assigned_to is null))    AND
                DH.CODE_COMBINATION_ID  = h_ccid                        AND
                DH.DATE_EFFECTIVE               <= ucd                  AND
                nvl(DH.DATE_INEFFECTIVE, ucd+1) >  ucd                  */
        UNION ALL
        SELECT
                DECODE(LU.LOOKUP_CODE, 'ADDITION COST',
                        DECODE(ADJ.DEBIT_CREDIT_FLAG, 'DR', 1, -1) *
                                ADJ.ADJUSTMENT_AMOUNT,0)                COST,
                DECODE(LU.LOOKUP_CODE,
                        'DEPRECIATION RESERVE',
                        DECODE(ADJ.DEBIT_CREDIT_FLAG, 'DR', -1, 1) *
                        ADJ.ADJUSTMENT_AMOUNT, 0)                       RESERVE,
                0                                                       DEPRN_AMOUNT,
                DECODE(LU.LOOKUP_CODE,
                        'ADDITION COST',
                        DECODE(ADJ.DEBIT_CREDIT_FLAG, 'DR', 1, -1) *
                        DH.UNITS_ASSIGNED,0)                            UNITS
        FROM
                FA_ADJUSTMENTS_mrc_v            ADJ,
                FA_LOOKUPS                      LU,
                FA_DISTRIBUTION_HISTORY         DH,
                FA_BOOK_CONTROLS_mrc_v          BC  -- Added for Bug#2675646
        WHERE
                LU.LOOKUP_TYPE          = 'JOURNAL ENTRIES'                     AND
                ((ADJ.ADJUSTMENT_TYPE IN ('COST','CIP COST') AND
                  LU.LOOKUP_CODE = 'ADDITION COST')
                  OR
                 (ADJ.ADJUSTMENT_TYPE   = 'RESERVE'          AND
                  LU.LOOKUP_CODE        = 'DEPRECIATION RESERVE'))              AND
                ADJ.SOURCE_TYPE_CODE NOT IN
                        ('DEPRECIATION','ADDITION', 'CIP ADDITION')             AND
                ADJ.BOOK_TYPE_CODE      = h_book                                AND
                ADJ.ASSET_ID            = h_asset_id                            AND
                ADJ.DISTRIBUTION_ID     = DH.DISTRIBUTION_ID                    AND
                ADJ.PERIOD_COUNTER_CREATED = upc
        AND  -- Added for Bug#2675646
                BC.BOOK_TYPE_CODE       = h_book
        AND
                DH.ASSET_ID             = h_asset_id                            AND
                DH.BOOK_TYPE_CODE       = nvl(BC.DISTRIBUTION_SOURCE_BOOK,h_book) AND -- Changed from = h_book
                DH.LOCATION_ID          = h_location_id                         AND
                DH.DATE_EFFECTIVE               <= ucd                  AND
                nvl(DH.DATE_INEFFECTIVE, ucd+1) >  ucd                  AND
                (DH.ASSIGNED_to         = h_assigned_to  OR
                 (DH.ASSIGNED_TO is null and h_assigned_to is null))    AND
                (NOT EXISTS (SELECT 1 FROM FA_DEPRN_DETAIL_mrc_v DD
                             WHERE  DD.ASSET_ID       = h_asset_id
                             AND    DD.BOOK_TYPE_CODE = h_book
                             AND    DD.PERIOD_COUNTER = upc)));
      END if;
      IF (nbv IS NULL) OR
        (h_cost - h_reserve <= nbv) THEN
         --
         -- Insert the data to the interface table
         --
        INSERT INTO fa_asset_listing_rep_itf (
                request_id,
                date_placed_in_service,
                deprn_method,
                life_yr_mo,
                ltd_deprn,
                cost,
                nbv,
                period_name,
                deprn_expense_acct,
                asset_cost_acct,
                account_description,
                company,
                asset_number,
                tag_number,
                serial_number,
                description,
                inventorial,
                cost_center,
                accum_deprn_acct,
                book_type_code,
                category,
                location,
                asset_key,
                organization_name,
                major_category,
                minor_category,
                employee_name,
                employee_number,
                set_of_books_id,
                functional_currency_code,
                company_description,
                expense_acct_description,
                cost_center_description,
                category_description,
                adjusted_rate,
                deprn_amount,
                percent,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                units,
                book_deprn_flag,
                category_deprn_flag)
                VALUES  (
                h_request_id,
                h_dpis,
                h_method_code,
                fnd_number.canonical_to_number(
                     decode(h_life,null,null,
                     to_char(floor(h_life/12)) || '.' || to_char(mod(h_life,12),'FM00'))),
                h_reserve,
                h_cost,
                h_cost - h_reserve,
                h_period,
                acct_all_segs(h_acct_segnum),
                h_asset_cost_acct,
                h_account_description,
                acct_all_segs(h_bal_segnum),
                h_asset_number,
                h_tag_number,
                h_serial_number,
                h_description,
                h_inventorial,
                acct_all_segs(h_cc_segnum),
                h_deprn_rsv_acct,
                h_book,
                concat_cat_str,
                concat_loc_str,
                concat_key_str,
                h_organization_name,
                h_major_category,
                h_minor_category,
                h_emp_name,
                h_emp_number,
                h_set_of_books_id,
                h_currency_code,
                h_company_description,
                h_expense_acct_description,
                h_cost_center_description,
                h_category_description,
                h_rate,
                h_deprn_amount,
                h_percent,
                h_user_id,
                sysdate,
                h_user_id,
                sysdate,
                login_id,
                h_units,
                h_book_deprn_flag,
                h_category_deprn_flag);
        END IF;
        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('asset_listing_run: ' || 'INSERT END');
        END IF;
        END IF; -- added for bug 2681076
   END LOOP;

   h_mesg_name := 'FA_ASSET_LISTING_SQL_CCUR';

    CLOSE asset_lst_rows;

    retcode := 0;
    errbuf := '';
    IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('asset_listing_run: ' || 'END REPORT');
    END IF;

    -- reset GL sob id to original value before moving to next book
    fnd_profile.put('GL_SET_OF_BKS_ID', l_orig_set_of_books_id);
    fnd_client_info.set_currency_context (l_orig_currency_context);
    commit;
EXCEPTION
    WHEN OTHERS THEN
      -- reset GL sob id to original value before moving to next book
      fnd_profile.put('GL_SET_OF_BKS_ID', l_orig_set_of_books_id);
      fnd_client_info.set_currency_context (l_orig_currency_context);
      fa_rx_conc_mesg_pkg.log(SQLERRM);

      fnd_message.set_name('OFA',h_mesg_name);

      IF h_mesg_name in ('FA_SHARED_DETELE_FAILED','FA_SHARED_INSERT_FAILED') THEN
         fnd_message.set_token('TABLE','FA_ASSET_LISTING_REP_ITF',FALSE);
     END IF;
     IF h_mesg_name = 'FA_RX_CONCAT_SEGS' THEN
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
     END IF;

     h_mesg_str := fnd_message.get;
     fa_rx_conc_mesg_pkg.log(h_mesg_str);
END asset_listing_run;
END FARX_AL;

/
