--------------------------------------------------------
--  DDL for Package Body FA_RX_SHARED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_SHARED_PKG" as
/* $Header: farxb.pls 120.21.12010000.6 2010/02/05 23:33:28 saalampa ship $ */


type flex_val_rec is record  (
   flex_value_set_name varchar2(60),
   flex_value_id varchar2(240)
);
type flex_val_tab is table of flex_val_rec index by binary_integer;
flex_val_cache flex_val_tab;
flex_val_count number := 0;

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE GET_ACCT_SEGMENT_NUMBERS (
   BOOK                         IN      VARCHAR2,
   BALANCING_SEGNUM      OUT NOCOPY NUMBER,
   ACCOUNT_SEGNUM        OUT NOCOPY NUMBER,
   CC_SEGNUM             OUT NOCOPY NUMBER,
   CALLING_FN                   IN      VARCHAR2)  IS

  structure_num         number;
  this_segment_num   number;

  h_mesg_name   varchar2(50);
  h_mesg_str    varchar2(2000);

BEGIN
 -- get structure ID for this book

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select accounting_flex_structure
  into structure_num
  from fa_book_controls
  where book_type_code = BOOK;

   h_mesg_name := 'FA_RX_SEGNUMS';

 -- get Balancing Segment
 -- (Code copied from fnd_flex_apis.get_qualifier_segnum in
 --     FND source control.)

    SELECT s.segment_num INTO this_segment_num
      FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
           fnd_segment_attribute_types sat
     WHERE s.application_id = 101
       AND s.id_flex_code = 'GL#'
       AND s.id_flex_num = structure_num
       AND s.enabled_flag = 'Y'
       AND s.application_column_name = sav.application_column_name
       AND sav.application_id = 101
       AND sav.id_flex_code = 'GL#'
       AND sav.id_flex_num = structure_num
       AND sav.attribute_value = 'Y'
       AND sav.segment_attribute_type = sat.segment_attribute_type
       AND sat.application_id = 101
       AND sat.id_flex_code = 'GL#'
       AND sat.unique_flag = 'Y'
       AND sat.segment_attribute_type = 'GL_BALANCING';

    SELECT count(segment_num) INTO balancing_segnum
      FROM fnd_id_flex_segments
     WHERE application_id = 101
       AND id_flex_code = 'GL#'
       AND id_flex_num = structure_num
       AND enabled_flag = 'Y'
       AND segment_num <= this_segment_num;

 -- get Account segment

    SELECT s.segment_num INTO this_segment_num
      FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
           fnd_segment_attribute_types sat
     WHERE s.application_id = 101
       AND s.id_flex_code = 'GL#'
       AND s.id_flex_num = structure_num
       AND s.enabled_flag = 'Y'
       AND s.application_column_name = sav.application_column_name
       AND sav.application_id = 101
       AND sav.id_flex_code = 'GL#'
       AND sav.id_flex_num = structure_num
       AND sav.attribute_value = 'Y'
       AND sav.segment_attribute_type = sat.segment_attribute_type
       AND sat.application_id = 101
       AND sat.id_flex_code = 'GL#'
       AND sat.unique_flag = 'Y'
       AND sat.segment_attribute_type = 'GL_ACCOUNT';

    SELECT count(segment_num) INTO account_segnum
      FROM fnd_id_flex_segments
     WHERE application_id = 101
       AND id_flex_code = 'GL#'
       AND id_flex_num = structure_num
       AND enabled_flag = 'Y'
       AND segment_num <= this_segment_num;


  -- Get Cost Center segment

    SELECT s.segment_num INTO this_segment_num
      FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
           fnd_segment_attribute_types sat
     WHERE s.application_id = 101
       AND s.id_flex_code = 'GL#'
       AND s.id_flex_num = structure_num
       AND s.enabled_flag = 'Y'
       AND s.application_column_name = sav.application_column_name
       AND sav.application_id = 101
       AND sav.id_flex_code = 'GL#'
       AND sav.id_flex_num = structure_num
       AND sav.attribute_value = 'Y'
       AND sav.segment_attribute_type = sat.segment_attribute_type
       AND sat.application_id = 101
       AND sat.id_flex_code = 'GL#'
       AND sat.unique_flag = 'Y'
       AND sat.segment_attribute_type = 'FA_COST_CTR';

    SELECT count(segment_num) INTO cc_segnum
      FROM fnd_id_flex_segments
     WHERE application_id = 101
       AND id_flex_code = 'GL#'
       AND id_flex_num = structure_num
       AND enabled_flag = 'Y'
       AND segment_num <= this_segment_num;



EXCEPTION
  when others then
  fnd_message.set_name('OFA',h_mesg_name);
  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  raise;

END GET_ACCT_SEGMENT_NUMBERS;

PROCEDURE GET_ACCT_SEGMENT_INDEX (
   BOOK                         IN      VARCHAR2,
   BALANCING_SEGNUM             OUT NOCOPY     NUMBER,
   ACCOUNT_SEGNUM               OUT NOCOPY     NUMBER,
   CC_SEGNUM                    OUT NOCOPY     NUMBER,
   CALLING_FN                   IN      VARCHAR2)  IS

  structure_num         number;
  this_segment_num   number;

  h_mesg_name   varchar2(50);
  h_mesg_str    varchar2(2000);

BEGIN

 -- get structure ID for this book

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select accounting_flex_structure
  into structure_num
  from fa_book_controls
  where book_type_code = BOOK;

   h_mesg_name := 'FA_RX_SEGNUMS';

 -- get Balancing Segment
 -- (Code copied from fnd_flex_apis.get_qualifier_segnum in
 --     FND source control.)

    SELECT to_number(substr(s.application_column_name,8,2)) INTO this_segment_num
      FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
           fnd_segment_attribute_types sat
     WHERE s.application_id = 101
       AND s.id_flex_code = 'GL#'
       AND s.id_flex_num = structure_num
       AND s.enabled_flag = 'Y'
       AND s.application_column_name = sav.application_column_name
       AND sav.application_id = 101
       AND sav.id_flex_code = 'GL#'
       AND sav.id_flex_num = structure_num
       AND sav.attribute_value = 'Y'
       AND sav.segment_attribute_type = sat.segment_attribute_type
       AND sat.application_id = 101
       AND sat.id_flex_code = 'GL#'
       AND sat.unique_flag = 'Y'
       AND sat.segment_attribute_type = 'GL_BALANCING';

-- bug 1796224, changed where-clause below.

    SELECT count(segment_num) INTO balancing_segnum
      FROM fnd_id_flex_segments
     WHERE application_id = 101
       AND id_flex_code = 'GL#'
       AND id_flex_num = structure_num
       AND enabled_flag = 'Y'
       AND to_number(substr(application_column_name,8,2)) <= this_segment_num;


 -- get Account segment

    SELECT to_number(substr(s.application_column_name,8,2)) INTO this_segment_num
      FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
           fnd_segment_attribute_types sat
     WHERE s.application_id = 101
       AND s.id_flex_code = 'GL#'
       AND s.id_flex_num = structure_num
       AND s.enabled_flag = 'Y'
       AND s.application_column_name = sav.application_column_name
       AND sav.application_id = 101
       AND sav.id_flex_code = 'GL#'
       AND sav.id_flex_num = structure_num
       AND sav.attribute_value = 'Y'
       AND sav.segment_attribute_type = sat.segment_attribute_type
       AND sat.application_id = 101
       AND sat.id_flex_code = 'GL#'
       AND sat.unique_flag = 'Y'
       AND sat.segment_attribute_type = 'GL_ACCOUNT';

-- bug 1796224, changed where-clause below.

    SELECT count(segment_num) INTO account_segnum
    FROM fnd_id_flex_segments
    WHERE application_id = 101
       AND id_flex_code = 'GL#'
       AND id_flex_num = structure_num
       AND enabled_flag = 'Y'
       AND to_number(substr(application_column_name,8,2)) <= this_segment_num;

  -- Get Cost Center segment

    SELECT to_number(substr(s.application_column_name,8,2)) INTO this_segment_num
      FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
           fnd_segment_attribute_types sat
     WHERE s.application_id = 101
       AND s.id_flex_code = 'GL#'
       AND s.id_flex_num = structure_num
       AND s.enabled_flag = 'Y'
       AND s.application_column_name = sav.application_column_name
       AND sav.application_id = 101
       AND sav.id_flex_code = 'GL#'
       AND sav.id_flex_num = structure_num
       AND sav.attribute_value = 'Y'
       AND sav.segment_attribute_type = sat.segment_attribute_type
       AND sat.application_id = 101
       AND sat.id_flex_code = 'GL#'
       AND sat.unique_flag = 'Y'
       AND sat.segment_attribute_type = 'FA_COST_CTR';

-- bug 1796224, changed where-clause below.

    SELECT count(segment_num) INTO cc_segnum
      FROM fnd_id_flex_segments
     WHERE application_id = 101
       AND id_flex_code = 'GL#'
       AND id_flex_num = structure_num
       AND enabled_flag = 'Y'
       AND to_number(substr(application_column_name,8,2)) <= this_segment_num;

EXCEPTION
  when others then
  fnd_message.set_name('OFA',h_mesg_name);
  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  raise;

END GET_ACCT_SEGMENT_INDEX;


PROCEDURE GET_ACCT_SEGMENTS (
   combination_id               IN      NUMBER,
   n_segments                   IN OUT NOCOPY NUMBER,
   segments                     IN OUT NOCOPY  Seg_Array,
   calling_fn                   IN      VARCHAR2)  IS

  ii   number;
  selectedsegs   Seg_Array;

  l_ccid         number;


BEGIN
  n_segments := 0;
  l_ccid := combination_id;

  select  segment1, segment2, segment3, segment4, segment5,
          segment6, segment7, segment8, segment9, segment10,
          segment11, segment12, segment13, segment14, segment15,
          segment16, segment17, segment18, segment19, segment20,
          segment21, segment22, segment23, segment24, segment25,
          segment26, segment27, segment28, segment29, segment30
  into    selectedsegs(1), selectedsegs(2), selectedsegs(3), selectedsegs(4), selectedsegs(5),
          selectedsegs(6), selectedsegs(7), selectedsegs(8), selectedsegs(9), selectedsegs(10),
          selectedsegs(11), selectedsegs(12), selectedsegs(13), selectedsegs(14), selectedsegs(15),
          selectedsegs(16), selectedsegs(17), selectedsegs(18), selectedsegs(19), selectedsegs(20),
          selectedsegs(21), selectedsegs(22), selectedsegs(23), selectedsegs(24), selectedsegs(25),
          selectedsegs(26), selectedsegs(27), selectedsegs(28), selectedsegs(29), selectedsegs(30)
  from    gl_code_combinations
  where   code_combination_id = l_ccid;

  for i in 1..30 loop
    if (selectedsegs(i) is not null) then
        n_segments := n_segments + 1;
        segments(n_segments) := selectedsegs(i);
    end if;
  end loop;



EXCEPTION
  when others then raise;


END GET_ACCT_SEGMENTS;



procedure fadolif (
   life                 in   number default null,
   adj_rate             in   number default null,
   bonus_rate           in   number default null,
   prod                 in   number default null,
   retval        out nocopy  varchar2)  IS

BEGIN

   IF life IS NOT NULL
   THEN

      retval := (LPAD(TO_CHAR(TRUNC(life/12, 0), '90'),3,' ')  || '.' ||
                SUBSTR(TO_CHAR(MOD(life, 12), '00'), 2, 2)) || ' ';

   ELSIF adj_rate IS NOT NULL
   THEN
      retval := TO_CHAR(ROUND((adj_rate + NVL(bonus_rate, 0))*100,                                      2), '90.99') || '%';
   ELSIF prod IS NOT NULL
   THEN
        --test for length of production_capacity; if it's longer
        --than 7 characters, then display in exponential notation

      --IF prod <= 9999999
      --THEN
      --   retval := TO_CHAR(prod);
      --ELSE
      --   retval := SUBSTR(LTRIM(TO_CHAR(prod, '9.9EEEE')), 1, 7);
      --END IF;

        --display nothing for UOP assets
        retval := '';
   ELSE
        --should not occur
      retval := ' ';
   END IF;



end fadolif;


procedure fa_rsvldg (
   book                 in  varchar2,
   period               in  varchar2,
   report_style         in  varchar2,
   sob_id               in  number,  -- MRC
   errbuf        out nocopy varchar2,
   retcode       out nocopy number) IS

        operation       varchar2(200);
        dist_book       varchar2(30);
        ucd             date;
        upc             number;
        tod             date;
        tpc             number;


  h_mesg_name varchar2(50);
  h_mesg_str  varchar2(2000);
  h_table_token varchar2(30);
  h_mrcsobtype  varchar2(1);  -- MRC

BEGIN

   h_mesg_name := 'FA_SHARED_DELETE_FAILED';
   h_table_token := 'FA_RESERVE_LEDGER_GT';

/*
        no longer needed when using global temp table
        DELETE FROM FA_RESERVE_LEDGER;

        if (SQL%ROWCOUNT > 0) then
            COMMIT;
        else
            ROLLBACK;
        end if;
*/

  -- MRC
  if sob_id is not null then
    begin
       select 'P'
       into h_mrcsobtype
       from fa_book_controls
       where book_type_code = book
       and set_of_books_id = sob_id;
    exception
       when no_data_found then
          h_mrcsobtype := 'R';
    end;
  else
    h_mrcsobtype := 'P';
  end if;
  -- End MRC

   h_mesg_name := 'FA_AMT_SEL_DP';

        SELECT
                BC.DISTRIBUTION_SOURCE_BOOK             dbk,
                nvl (DP.PERIOD_CLOSE_DATE, sysdate)     ucd,
                DP.PERIOD_COUNTER                       upc,
                min (DP_FY.PERIOD_OPEN_DATE)            tod,
                min (DP_FY.PERIOD_COUNTER)              tpc
        INTO
                dist_book,
                ucd,
                upc,
                tod,
                tpc
        FROM
                FA_DEPRN_PERIODS        DP,
                FA_DEPRN_PERIODS        DP_FY,
                FA_BOOK_CONTROLS        BC
        WHERE
                DP.BOOK_TYPE_CODE       =  book                 AND
                DP.PERIOD_NAME          =  period               AND
                DP_FY.BOOK_TYPE_CODE    =  book                 AND
                DP_FY.FISCAL_YEAR       =  DP.FISCAL_YEAR
        AND     BC.BOOK_TYPE_CODE       =  book
        GROUP BY
                BC.DISTRIBUTION_SOURCE_BOOK,
                DP.PERIOD_CLOSE_DATE,
                DP.PERIOD_COUNTER;

        operation := 'Inserting into FA_RESERVE_LEDGER_GT';

   h_mesg_name := 'FA_SHARED_INSERT_FAILED';
   h_table_token := 'FA_RESERVE_LEDGER_GT';

  if(h_mrcsobtype <> 'R') then  -- MRC

     INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
        DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
        RATE,
        CAPACITY,
        COST,
        DEPRN_AMOUNT,
        YTD_DEPRN,
        DEPRN_RESERVE,
        PERCENT,
        TRANSACTION_TYPE,
        PERIOD_COUNTER,
        DATE_EFFECTIVE,
        DISTRIBUTION_ID)
     SELECT
        DH.ASSET_ID                                             ASSET_ID,
        DH.CODE_COMBINATION_ID                                  DH_CCID,
        CB.DEPRN_RESERVE_ACCT                                   RSV_ACCOUNT,
        BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
        BOOKS.DEPRN_METHOD_CODE                                 METHOD,
        BOOKS.LIFE_IN_MONTHS                                    LIFE,
        BOOKS.ADJUSTED_RATE                                     RATE,
        BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
        DD.COST                                                 COST,
        decode (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0)
                                                                DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN)
                                                                YTD_DEPRN,
        DD.DEPRN_RESERVE                                        DEPRN_RESERVE,
        round (decode (TH.TRANSACTION_TYPE_CODE, null,
                        DH.UNITS_ASSIGNED / AH.UNITS * 100),2)
                                                                PERCENT,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                decode (TH_RT.TRANSACTION_TYPE_CODE,
                        'FULL RETIREMENT', 'F',
                        decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                'TRANSFER', 'T',
                'TRANSFER OUT', 'P',
                'RECLASS', 'R')                                 T_TYPE,
        DD.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd),
        DH.DISTRIBUTION_ID
     FROM
        FA_DEPRN_DETAIL         DD,
        FA_ASSET_HISTORY        AH,
        FA_TRANSACTION_HEADERS  TH,
        FA_TRANSACTION_HEADERS  TH_RT,
        FA_BOOKS                BOOKS,
        FA_DISTRIBUTION_HISTORY DH,
        FA_CATEGORY_BOOKS       CB
     WHERE
        CB.BOOK_TYPE_CODE               =  book                     AND
        CB.CATEGORY_ID                  =  AH.CATEGORY_ID
     AND
        AH.ASSET_ID                     =  DH.ASSET_ID              AND
        AH.DATE_EFFECTIVE               < nvl(TH.DATE_EFFECTIVE, ucd)   AND
        nvl(AH.DATE_INEFFECTIVE,sysdate)
                                        >=  nvl(TH.DATE_EFFECTIVE, ucd) AND
     --    AH.ASSET_TYPE                   = 'CAPITALIZED'
     ( (   AH.ASSET_TYPE                 in ('CAPITALIZED', 'GROUP')  AND
           BOOKS.GROUP_ASSET_ID is null
        ) OR
       (   AH.ASSET_TYPE                 = 'CAPITALIZED' AND
           BOOKS.GROUP_ASSET_ID is not null
           and exists (select 1
                       from   fa_books oldbk
                            , fa_transaction_headers oldth
                            , fa_deprn_periods dp
                       where  oldbk.transaction_header_id_out = books.transaction_header_id_in
                       and    oldbk.transaction_header_id_out = oldth.transaction_header_id
                       and   dp.book_type_code = book
                       and   dp.period_counter = dd.period_counter
                       and   oldth.date_effective between dp.period_open_date
                                                      and nvl(dp.period_close_date, oldth.date_effective)
                       and   oldbk.group_asset_id is null)
       ) OR
       ( nvl(report_style,'S') = 'D' AND
        AH.ASSET_TYPE                   in ('CAPITALIZED', 'GROUP')
       )
     )
     AND
        DD.BOOK_TYPE_CODE               = book                       AND
        DD.DISTRIBUTION_ID              = DH.DISTRIBUTION_ID         AND
        DD.PERIOD_COUNTER               =
       (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = DH.ASSET_ID
        AND     DD_SUB.DISTRIBUTION_ID  = DH.DISTRIBUTION_ID
        AND     DD_SUB.PERIOD_COUNTER   <= upc)
     AND
        TH_RT.BOOK_TYPE_CODE            = book                          AND
        TH_RT.TRANSACTION_HEADER_ID     = BOOKS.TRANSACTION_HEADER_ID_IN
     AND
        BOOKS.BOOK_TYPE_CODE            = book                          AND
        BOOKS.ASSET_ID                  = DH.ASSET_ID                   AND
        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc             AND
     -- Rolling back fix for bug 4610445
     --        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= upc      AND
        BOOKS.DATE_EFFECTIVE            <= nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(BOOKS.DATE_INEFFECTIVE,sysdate+1) > nvl(TH.DATE_EFFECTIVE, ucd)
     AND
        TH.BOOK_TYPE_CODE (+)           = dist_book                     AND
        TH.TRANSACTION_HEADER_ID (+)    = DH.TRANSACTION_HEADER_ID_OUT  AND
        TH.DATE_EFFECTIVE (+)           BETWEEN tod and ucd
     AND
        DH.BOOK_TYPE_CODE               = dist_book                     AND
        DH.DATE_EFFECTIVE               <= ucd AND
        nvl(DH.DATE_INEFFECTIVE, sysdate) > tod;
     -- Rolling back fix for bug 4610445
     -- ucd between dh.date_effective and nvl(dh.date_ineffective,ucd);

  -- MRC
  else
     INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
        DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
        RATE,
        CAPACITY,
        COST,
        DEPRN_AMOUNT,
        YTD_DEPRN,
        DEPRN_RESERVE,
        PERCENT,
        TRANSACTION_TYPE,
        PERIOD_COUNTER,
        DATE_EFFECTIVE,
        DISTRIBUTION_ID)
     SELECT
        DH.ASSET_ID                                             ASSET_ID,
        DH.CODE_COMBINATION_ID                                  DH_CCID,
        CB.DEPRN_RESERVE_ACCT                                   RSV_ACCOUNT,
        BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
        BOOKS.DEPRN_METHOD_CODE                                 METHOD,
        BOOKS.LIFE_IN_MONTHS                                    LIFE,
        BOOKS.ADJUSTED_RATE                                     RATE,
        BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
        DD.COST                                                 COST,
        decode (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0)
                                                                DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN)
                                                                YTD_DEPRN,
        DD.DEPRN_RESERVE                                        DEPRN_RESERVE,
        round (decode (TH.TRANSACTION_TYPE_CODE, null,
                        DH.UNITS_ASSIGNED / AH.UNITS * 100),2)
                                                                PERCENT,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                decode (TH_RT.TRANSACTION_TYPE_CODE,
                        'FULL RETIREMENT', 'F',
                        decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                'TRANSFER', 'T',
                'TRANSFER OUT', 'P',
                'RECLASS', 'R')                                 T_TYPE,
        DD.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd),
        DH.DISTRIBUTION_ID
     FROM
        FA_MC_DEPRN_DETAIL      DD,
        FA_ASSET_HISTORY        AH,
        FA_TRANSACTION_HEADERS  TH,
        FA_TRANSACTION_HEADERS  TH_RT,
        FA_MC_BOOKS             BOOKS,
        FA_DISTRIBUTION_HISTORY DH,
        FA_CATEGORY_BOOKS       CB
     WHERE
        CB.BOOK_TYPE_CODE               =  book                         AND
        CB.CATEGORY_ID                  =  AH.CATEGORY_ID
     AND
        AH.ASSET_ID                     =  DH.ASSET_ID              AND
        AH.DATE_EFFECTIVE               < nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(AH.DATE_INEFFECTIVE,sysdate)
                                        >=  nvl(TH.DATE_EFFECTIVE, ucd)  AND
     --    AH.ASSET_TYPE                   = 'CAPITALIZED'
     ( (   AH.ASSET_TYPE                 in ('CAPITALIZED', 'GROUP')  AND
           BOOKS.GROUP_ASSET_ID is null
       ) OR
       (   AH.ASSET_TYPE                 = 'CAPITALIZED' AND
           BOOKS.GROUP_ASSET_ID is not null
           and exists (select 1
                       from   fa_mc_books oldbk
                            , fa_transaction_headers oldth
                            , fa_mc_deprn_periods dp
                       where  oldbk.transaction_header_id_out = books.transaction_header_id_in
                       and    oldbk.transaction_header_id_out = oldth.transaction_header_id
                       and   dp.book_type_code = book
                       and   dp.period_counter = dd.period_counter
                       and   oldth.date_effective between dp.period_open_date
                                                      and nvl(dp.period_close_date, oldth.date_effective)
                       and   oldbk.group_asset_id is null
                       and   oldbk.set_of_books_id = sob_id
                       and   dp.set_of_books_id    = sob_id)
       ) OR
       ( nvl(report_style,'S') = 'D' AND
         AH.ASSET_TYPE                   in ('CAPITALIZED', 'GROUP')
       )
    )
     AND
        DD.BOOK_TYPE_CODE               = book                          AND
        DD.DISTRIBUTION_ID              = DH.DISTRIBUTION_ID         AND
        DD.PERIOD_COUNTER               =
       (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_MC_DEPRN_DETAIL DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = DH.ASSET_ID
        AND     DD_SUB.DISTRIBUTION_ID  = DH.DISTRIBUTION_ID
        AND     DD_SUB.PERIOD_COUNTER   <= upc
        AND     DD_SUB.SET_OF_BOOKS_ID  = sob_id)
     AND
        TH_RT.BOOK_TYPE_CODE            = book                          AND
        TH_RT.TRANSACTION_HEADER_ID     = BOOKS.TRANSACTION_HEADER_ID_IN
     AND
        BOOKS.BOOK_TYPE_CODE            = book                          AND
        BOOKS.ASSET_ID                  = DH.ASSET_ID                AND
        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc             AND
     -- Rolling back fix for bug 4610445
     --        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= upc             AND
        BOOKS.DATE_EFFECTIVE            <= nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(BOOKS.DATE_INEFFECTIVE,sysdate+1) > nvl(TH.DATE_EFFECTIVE, ucd)
     AND
        TH.BOOK_TYPE_CODE (+)           = dist_book                     AND
        TH.TRANSACTION_HEADER_ID (+)    = DH.TRANSACTION_HEADER_ID_OUT  AND
        TH.DATE_EFFECTIVE (+)           BETWEEN tod and ucd
     AND
        DH.BOOK_TYPE_CODE               = dist_book                     AND
        DH.DATE_EFFECTIVE               <= ucd AND
        nvl(DH.DATE_INEFFECTIVE, sysdate) > tod
     AND
        DD.SET_OF_BOOKS_ID              = sob_id
     AND
        BOOKS.SET_OF_BOOKS_ID           = sob_id;
     -- Rolling back fix for bug 4610445
     --      ucd between dh.date_effective and nvl(dh.date_ineffective,ucd);
  end if;
  -- End MRC

retcode := 1;

exception
    when others then
        retcode := 2;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name in ('FA_FLEX_DELETE_FAILED','FA_FLEX_INSERT_FAILED') then
        fnd_message.set_token('TABLE',h_table_token,FALSE);
  end if;
  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);

end fa_rsvldg;


procedure concat_general (
   table_id             in      number,
   table_name           in      varchar2,
   ccid_col_name        in      varchar2,
   struct_id            in      number,
   flex_code            in      varchar2,
   ccid                 in      number,
   appl_id              in      number,
   appl_short_name      in      varchar2,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy  Seg_Array) is

--   seg_table          in fa_whatif_deprn2_pkg.seg_data_tbl
  cursor segcolumns is
    select g.application_column_name, g.segment_num
    from fnd_columns c, fnd_id_flex_segments g
        WHERE g.application_id = appl_id
          AND g.id_flex_code = flex_code
          AND g.id_flex_num = struct_id
          AND g.enabled_flag = 'Y'
          AND c.application_id = appl_id
          AND c.table_id = table_id
          AND c.column_name = g.application_column_name
        group by g.application_column_name, g.segment_num
        ORDER BY g.segment_num;

  i     number;
  delim  varchar2(1);
  col_name  varchar2(25);

  num_segs  integer;
  seg_ctr   integer;

  v_cursorid   integer;
  v_sqlstmt     varchar2(500);
  v_return     integer;

  h_mesg_name  varchar2(30);
  h_mesg_str  varchar2(2000);

  l_use_global_table    varchar2(10);

  BEGIN

  if (fa_rx_shared_pkg.g_seg_count = 0) then
        l_use_global_table := 'NO';
  else
        l_use_global_table := 'YES';
  end if;

  concat_string := '';

  h_mesg_name := 'FA_BUDGET_NO_SEG_DELIM';

  num_segs := 0;
  seg_ctr := 0;

  v_sqlstmt := 'select ';


  h_mesg_name := 'FA_SHARED_FLEX_SEGCOLUMNS';


-- global table is currently initialized when called
-- from what if, to improve performance. When time
-- allows all other RX procedures should use the
-- global table instead of selects same data over and over.
-- What needs to be done is to find all entry points and
-- fill the global table there.

  if l_use_global_table = 'NO' then

     Select s.concatenated_segment_delimiter into delim
     FROM fnd_id_flex_structures s, fnd_application a
     WHERE s.application_id = a.application_id
       AND s.id_flex_code = flex_code
       AND s.id_flex_num = struct_id
       AND a.application_short_name = appl_short_name;

    open segcolumns;
    loop

      fetch segcolumns into col_name, v_return;

      if (segcolumns%NOTFOUND) then exit;  end if;

        v_sqlstmt := v_sqlstmt || col_name || ', ';
        num_segs := num_segs + 1;

        segarray(num_segs) := 'seeded';

    end loop;
    close segcolumns;


  else
     FOR i IN fa_rx_shared_pkg.g_seg_table.FIRST .. fa_rx_shared_pkg.g_seg_table.LAST LOOP

       if table_name = fa_rx_shared_pkg.g_seg_table(i).tabname then


         v_sqlstmt := v_sqlstmt || fa_rx_shared_pkg.g_seg_table(i).colname || ', ';
         num_segs := num_segs + 1;
         delim := fa_rx_shared_pkg.g_seg_table(i).delimiter;

         segarray(num_segs) := 'seeded';

       end if;

    end loop;
  end if;
--


  h_mesg_name := 'FA_SHARED_FLEX_DYNAMIC_SQL';

  v_sqlstmt := rtrim(v_sqlstmt,', ');
  v_sqlstmt := v_sqlstmt || ' from ' || table_name;
  /*Modified code for bug 9351332
  v_sqlstmt := v_sqlstmt || ' where ' || ccid_col_name || ' = ';
  v_sqlstmt := v_sqlstmt || to_char(ccid);*/
  v_sqlstmt := v_sqlstmt || ' where ' || ccid_col_name || ' =:x ';

  v_cursorid := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursorid, v_sqlstmt, DBMS_SQL.V7);
  --Added code for bug 9351332
  dbms_sql.bind_variable(v_cursorid,':x', to_char(ccid));

  for seg_ctr in 1 .. num_segs loop

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

exception
    when others then

  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name like 'FA_SHARED_FLEX%' then
        fnd_message.set_token('STRUCT_ID',struct_id,FALSE);
        fnd_message.set_token('FLEX_CODE',flex_Code,FALSE);
  end if;
  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  raise;

  end concat_general;

procedure concat_category (
   struct_id            in      number,
   ccid                 in      number,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy Seg_Array) is

--    seg_table         in fa_whatif_deprn2_pkg.seg_data_tbl,
  h_table_id     number;
  h_id_flex_code varchar2(4);

  h_mesg_name   varchar2(30);
  h_mesg_str  varchar2(2000);

  begin

  h_mesg_name := 'FA_SHARED_FLEX_UNHANDLED';

  select table_id into h_table_id from fnd_tables
  where table_name = 'FA_CATEGORIES_B' and application_id = 140;

   concat_general (
   table_id     => h_table_id,
   table_name   => 'FA_CATEGORIES_B',
   ccid_col_name => 'CATEGORY_ID',
   struct_id    => struct_id,
   flex_code    => 'CAT#',
   ccid         => ccid,
   appl_id     => 140,
   appl_short_name => 'OFA',
   concat_string => concat_string,
   segarray => segarray);

--    seg_table => seg_table,
exception
    when others then

  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name like 'FA_SHARED_FLEX%' then
        fnd_message.set_token('STRUCT_ID',struct_id,FALSE);
        fnd_message.set_token('FLEX_CODE','CAT#',FALSE);
  end if;
  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  raise;

  end concat_category;

procedure concat_location (
   struct_id            in      number,
   ccid                 in      number,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy  Seg_Array) is

--    seg_table         in fa_whatif_deprn2_pkg.seg_data_tbl,

  h_id_flex_code varchar2(4);
  h_table_id     number;

  h_mesg_name   varchar2(30);
  h_mesg_str  varchar2(2000);

  begin

  h_mesg_name := 'FA_SHARED_FLEX_UNHANDLED';


  select table_id into h_table_id from fnd_tables
  where table_name = 'FA_LOCATIONS' and application_id = 140;

   concat_general (
   table_id     => h_table_id,
   table_name   => 'FA_LOCATIONS',
   ccid_col_name => 'LOCATION_ID',
   struct_id    => struct_id,
   flex_code    => 'LOC#',
   ccid         => ccid,
   appl_id     => 140,
   appl_short_name => 'OFA',
   concat_string => concat_string,
   segarray => segarray);

--    seg_table => seg_table,

exception
    when others then

  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name like 'FA_SHARED_FLEX%' then
        fnd_message.set_token('STRUCT_ID',struct_id,FALSE);
        fnd_message.set_token('FLEX_CODE','LOC#',FALSE);
  end if;
  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  raise;

  end concat_location;

procedure concat_asset_key (
   struct_id            in      number,
   ccid                 in      number,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy  Seg_Array)  is

--   seg_table          in fa_whatif_deprn2_pkg.seg_data_tbl,

  h_id_flex_code varchar2(4);
  h_table_id     number;

  h_mesg_name   varchar2(30);
  h_mesg_str  varchar2(2000);

  begin
  h_mesg_name := 'FA_SHARED_FLEX_UNHANDLED';


  select table_id into h_table_id from fnd_tables
  where table_name = 'FA_ASSET_KEYWORDS' and application_id = 140;

   concat_general (
   table_id     => h_table_id,
   table_name   => 'FA_ASSET_KEYWORDS',
   ccid_col_name => 'CODE_COMBINATION_ID',
   struct_id    => struct_id,
   flex_code    => 'KEY#',
   ccid         => ccid,
   appl_id     => 140,
   appl_short_name => 'OFA',
   concat_string => concat_string,
   segarray     => segarray);

--    seg_table => seg_table,

exception
    when others then

  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name like 'FA_SHARED_FLEX%' then
        fnd_message.set_token('STRUCT_ID',struct_id,FALSE);
        fnd_message.set_token('FLEX_CODE','KEY#',FALSE);
  end if;
  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  raise;

  end concat_asset_key;

procedure concat_acct (
   struct_id            in      number,
   ccid                 in      number,
   concat_string        in out nocopy varchar2,
   segarray             in out nocopy Seg_Array)  is

--    seg_table         in fa_whatif_deprn2_pkg.seg_data_tbl,

  h_id_flex_code varchar2(4);
  h_table_id     number;

  h_mesg_name   varchar2(30);
  h_mesg_str  varchar2(2000);

  begin

  h_mesg_name := 'FA_SHARED_FLEX_UNHANDLED';

  select table_id into h_table_id from fnd_tables
  where table_name = 'GL_CODE_COMBINATIONS' and application_id = 101;

   concat_general (
   table_id     => h_table_id,
   table_name   => 'GL_CODE_COMBINATIONS',
   ccid_col_name => 'CODE_COMBINATION_ID',
   struct_id    => struct_id,
   flex_code    => 'GL#',
   ccid         => ccid,
   appl_id     => 101,
   appl_short_name => 'SQLGL',
   concat_string => concat_string,
   segarray => segarray);
--    seg_table => seg_table,

exception
    when others then

  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name like 'FA_SHARED_FLEX%' then
        fnd_message.set_token('STRUCT_ID',struct_id,FALSE);
        fnd_message.set_token('FLEX_CODE','GL#',FALSE);
  end if;
  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  raise;


  end concat_acct;


-- This procedure, get_request_info doesn't seem to be called
-- from anywhere, at some point try to remove it.
procedure get_request_info (
        userid                in  number,
        prog_name_template    in  varchar2,
        max_requests          in  number,
        dateform              in  varchar2,
        applid                in  number,
        user_conc_prog_names  out nocopy largevarchar2table,
        conc_prog_names       out nocopy varchar2table,
        arg_texts             out nocopy largevarchar2table,
        request_ids           out nocopy numbertable,
        phases                out nocopy varchar2table,
        statuses              out nocopy varchar2table,
        dev_phases            out nocopy smallvarchar2table,
        dev_statuses          out nocopy smallvarchar2table,
        timestamps            out nocopy varchar2table,
        num_requests          out nocopy number) is

  ii integer;

  cursor request_info is
  select ltrim(ltrim(t.user_concurrent_program_name, 'RX-only:')),
    b.concurrent_program_name, cr.argument_text,
    cr.request_id, lp.meaning, ls.meaning, cr.phase_code, cr.status_code,
    to_char(cr.request_date, dateform || ' HH24:MI:SS')
  from fnd_lookups ls, fnd_lookups lp, fnd_concurrent_programs_tl t,
        fnd_concurrent_programs b,  fnd_concurrent_requests cr
  where lp.lookup_type = 'CP_PHASE_CODE' and
    lp.lookup_code = cr.phase_code and
    ls.lookup_type = 'CP_STATUS_CODE' and
    ls.lookup_code = cr.status_code and
    cr.requested_by = userid and
    b.concurrent_program_id = cr.concurrent_program_id  and
    b.application_id = applid and
    B.CONCURRENT_PROGRAM_ID = T.CONCURRENT_PROGRAM_ID and
    B.APPLICATION_ID = T.APPLICATION_ID and
    T.LANGUAGE = userenv('LANG')   and
    b.concurrent_program_name like prog_name_template
  order by cr.request_id desc;



  userconcprogname  varchar2(250);
  concprogname  varchar2(50);
  argtext varchar2(250);
  requestid number;
  phase varchar2(50);
  status varchar2(50);
  devphase varchar2(1);
  devstatus varchar2(1);
  timestamp varchar2(50);

  indarg        varchar2(25);
  remargtext    varchar2(250);
  oldremargtext varchar2(250);
  datestr       varchar2(25);

begin
  open request_info;
  ii := 1;
  loop

 -- Can't fetch directly into table type due to bug 334538,
 -- so we need to use temporary variables

    fetch  request_info into
        userconcprogname, concprogname, argtext, requestid, phase, status,
        devphase, devstatus, timestamp;
    exit when request_info%notfound;

-- remove trailing user_id argument
--    argtext := substr(argtext,1,instr(argtext,',',-1,1)-1);

-- remove date format from argument string
--    argtext := replace(argtext,'_'||dateform);


    user_conc_prog_names(ii) := userconcprogname;
    conc_prog_names(ii) := concprogname;
    arg_texts(ii) := argtext;
    request_ids(ii) := requestid;
    phases(ii) := phase;
    statuses(ii) := status;
    dev_phases(ii) := devphase;
    dev_statuses(ii) := devstatus;
    timestamps(ii) := timestamp;

    ii := ii + 1;
    exit when ii = max_requests + 1;
  end loop;
  close request_info;
  num_requests := ii - 1;

end get_request_info;



procedure get_arguments (
        req_id      in  number,
        arg1       out nocopy varchar2,
        arg2       out nocopy varchar2,
        arg3       out nocopy varchar2,
        arg4       out nocopy varchar2,
        arg5       out nocopy varchar2,
        arg6       out nocopy varchar2,
        arg7       out nocopy varchar2,
        arg8       out nocopy varchar2,
        arg9       out nocopy varchar2,
        arg10       out nocopy varchar2,
        arg11       out nocopy varchar2,
        arg12       out nocopy varchar2,
        arg13       out nocopy varchar2,
        arg14       out nocopy varchar2,
        arg15       out nocopy varchar2,
        arg16       out nocopy varchar2,
        arg17       out nocopy varchar2,
        arg18       out nocopy varchar2,
        arg19       out nocopy varchar2,
        arg20       out nocopy varchar2,
        arg21       out nocopy varchar2,
        arg22       out nocopy varchar2,
        arg23       out nocopy varchar2,
        arg24       out nocopy varchar2,
        arg25       out nocopy varchar2) is


begin

  select argument1, argument2, argument3, argument4, argument5,
        argument6, argument7, argument8, argument9, argument10,
        argument11, argument12, argument13, argument14, argument15,
        argument16, argument17, argument18, argument19, argument20,
        argument21, argument22, argument23, argument24, argument25
  into  arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10,
        arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18,
        arg19, arg20, arg21, arg22, arg23, arg24, arg25
  from fnd_concurrent_requests
  where request_id = req_id;

end get_arguments;



  procedure add_dynamic_column (
        X_request_id  in      number,
        X_attribute_name      in varchar2,
        X_column_name         in varchar2,
        X_ordering            in varchar2,
        X_BREAK                  in VARCHAR2,
        X_DISPLAY_LENGTH         in NUMBER,
        X_DISPLAY_FORMAT         in VARCHAR2,
        X_DISPLAY_STATUS         in VARCHAR2,
         calling_fn            in varchar2) is
h_user_id  number;
h_login_id number;
h_mesg_str varchar2(2000);
begin

  h_user_id := fnd_profile.value('USER_ID');
  h_login_id := fnd_profile.value('LOGIN_ID');
  insert into fa_rx_dynamic_columns (
        request_id, attribute_name, column_name, ordering, break,
        display_length, display_format, display_status, last_update_date,
        last_update_login, last_updated_by, created_by, creation_date)
  values (X_request_id, X_attribute_name, X_column_name, X_ordering,
        X_break, X_display_length, X_display_format, X_display_status,
        sysdate, h_login_id, h_user_id, h_user_id, sysdate);


EXCEPTION
  when others then
  fnd_message.set_name('OFA','FA_FLEX_INSERT_FAILED');
  fnd_message.set_token('TABLE','FA_RX_DYNAMIC_COLUMNS',FALSE);
  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  raise;

end add_dynamic_column;

/* -------------------------------------------------------------------------------------------*/
/* StatReq - The following two functions have been added for statutory reporting requirements */
/* -------------------------------------------------------------------------------------------*/

PROCEDURE Initialize_Where(vset in out nocopy fnd_vset.valueset_r,v_flex_value in varchar2)
is

   where_clause long;

   replace_string VARCHAR2(200);
   src VARCHAR2(100);
   value VARCHAR2(240);
   default_value VARCHAR2(240);
   idx NUMBER;
   ch VARCHAR2(10);

   isprof BOOLEAN;
   flex_len NUMBER;
   prof_len NUMBER;

begin
  if vset.validation_type <> 'F' then return;
  elsif vset.table_info.where_clause is null then return;
  end if;

   flex_len := length(':$FLEX$.');
   prof_len := length(':$PROFILES$.');

   where_clause := vset.table_info.where_clause;

   LOOP
      src := NULL;
      idx := instr(Upper(where_clause), ':$PROFILES$.');
      IF idx = 0 THEN
         idx := instr(Upper(where_clause), ':$FLEX$.');

         IF idx <> 0 THEN
            isprof := FALSE;
            replace_string := substr(where_clause, idx, flex_len);
            idx := idx + flex_len;
         END IF;
       ELSE
         isprof := TRUE;
         replace_string := substr(where_clause, idx, prof_len);
         idx := idx + prof_len;
      END IF;
      EXIT WHEN idx = 0;

      LOOP
         ch := substr(where_clause, idx, 1);
         EXIT WHEN ch IS NULL OR NOT (Upper(ch) BETWEEN 'A' AND 'Z' OR ch BETWEEN '0' and '9' OR ch = '_');

         src := src || ch;
         idx := idx+1;
      END LOOP;

      IF ch = ':' THEN
        idx := idx + 1;
        default_value := null;
        LOOP
          ch := substr(where_clause, idx, 1);
          EXIT WHEN ch IS NULL OR NOT (Upper(ch) BETWEEN 'A' AND 'Z' OR ch BETWEEN '0' and '9' OR ch = '_');

          default_value := default_value || ch;
          idx := idx + 1;
        END LOOP;
      END IF;

      value := null;
      IF isprof THEN
         fnd_profile.get(Upper(src), value);
       ELSE
         for i in 1..flex_val_count loop
            if upper(src) = flex_val_cache(i).flex_value_set_name then
                value := flex_val_cache(i).flex_value_id;
                exit;
            end if;
         end loop;
      END IF;
      if value is null then
           value := default_value;
      end if;
      if value is null then
           value := 'NULL';
      end if;

      replace_string := replace_string||src;

      IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('Initialize_Where: ' || src);
      END IF;

      where_clause := REPLACE(where_clause, replace_string, ''''||value||'''');
   END LOOP;

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('Initialize_Where: ' || where_clause);
   END IF;

   if v_flex_value is Not null then
           fa_rx_util_pkg.debug('Initialize_Where: to change the where clause for long list ' ||where_clause);
           where_clause := upper(nvl(where_clause,'WHERE 1=1'));
           where_clause := substr(where_clause,instr(where_clause,'WHERE')+5);
           where_clause := ' WHERE to_char('||vset.table_info.value_column_name||') = '||''''||v_flex_value||''''||' AND '||where_clause;
   end if;

   fa_rx_util_pkg.debug('Initialize_Where: after ** ' ||where_clause);

   vset.table_info.where_clause := where_clause;

end initialize_where;

FUNCTION get_flex_val_meaning (
                v_flex_value_set_id     IN NUMBER,
                v_flex_value_set_name   IN VARCHAR2,
                v_flex_value            IN VARCHAR2)
RETURN VARCHAR2 IS
   vsid number;
   vset fnd_vset.valueset_r;
   fmt fnd_vset.valueset_dr;
   found BOOLEAN;
   row NUMBER;
   value fnd_vset.value_dr;
   meaning varchar2(240) := '';
   vsname varchar2(150);

   i            BINARY_INTEGER := 0;
   y            BINARY_INTEGER := 0;

   /* This function returns:
         - the meaning of a passed flex value, if the valueset is found and it has an entry
           for the flex value and the entry has a meaning associated with it.
         - the flex value, if the flex value passed is null or if the flex value is
           not found in the valueset or if both valueset parameters are NULL or if the
           flex value is found in the valueset but doesn't have a meaning */

BEGIN

   /* Return NULL if flex value is null */

   if (v_flex_value is null) then return (v_flex_value); end if;

   /* If flex value set id is null and flex value set name is null too,
      return the flex value passed into the function.

      If either of the flex value set id or the flex valueset name is null,
      select it and move on with the rest of the function. */

   if (v_flex_value_set_name is null)
   then
      if (v_flex_value_set_id is null)
      then
          return(v_flex_value);
      else
          select flex_value_set_name
          into   vsname
          from   fnd_flex_value_sets
          where  flex_value_set_id = v_flex_value_set_id;

          vsid := v_flex_value_set_id;

      end if;
   else
      if (v_flex_value_set_id is null)
      then
          select flex_value_set_id
          into   vsid
          from   fnd_flex_value_sets
          where  flex_value_set_name = v_flex_value_set_name;

      else
          vsid := v_flex_value_set_id;
      end if;

      vsname := v_flex_value_set_name;

   end if;

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('get_flex_val_meaning: ' || 'Caching values for value set '||vsname);
   END IF;
   /* Search PL/SQL tables for valuesets and values that have already been loaded */

   if (g_value_set_counter >= 1)
   then
         FOR i in 1..g_value_set_counter LOOP
              if (g_value_set_tab(i).value_set_name = vsname)
              then
                  FOR y in g_value_set_tab(i).from_counter..g_value_set_tab(i).to_counter LOOP
                     if (g_values_tab(y).value = v_flex_value)
                     then

                        meaning := nvl(g_values_tab(y).meaning, v_flex_value);
                        return(meaning);
                     end if;
                  END LOOP;
                  return(v_flex_value);
              end if;
         END LOOP;
   end if;

   g_value_set_counter := g_value_set_counter + 1;
   g_value_set_tab(g_value_set_counter).value_set_name := vsname;
   g_value_set_tab(g_value_set_counter).from_counter := g_value_counter + 1;
   g_value_set_tab(g_value_set_counter).to_counter := g_value_counter + 1;

   /* Get valueset info */
   fnd_vset.get_valueset(vsid, vset, fmt);

   If nvl(vset.validation_type,'*') = 'F' and nvl(fmt.longlist_flag,'N') = 'Y' Then
        /* Initialize WHERE Clause for Table validated value sets */
        Initialize_Where(vset,v_flex_value);
   Else
        Initialize_Where(vset,null);
   End If;

   /* Initialize valueset variables */
   fnd_vset.get_value_init(vset, TRUE);

   /* Fetch first value of valueset */
   fnd_vset.get_value(vset, row, found, value);

   WHILE(found) LOOP
      /* Increase session flex value counter by 1 */

      g_value_counter := g_value_counter + 1;

      /* Store flex values away */
      fa_rx_util_pkg.debug(':Meaning = '||Nvl(value.meaning, '<<<NULL>>>')||', Value = '||value.value||':');
      g_values_tab(g_value_counter).meaning := substr(nvl(value.meaning, value.value), 1, 240);
      g_values_tab(g_value_counter).value   := substr(Nvl(value.id, value.value), 1, 150);
      g_value_set_tab(g_value_set_counter).to_counter := g_value_counter;

      /* Check if fetched value matches the passed flex value, if yes
         store the meaning in variable meaning */

      if (v_flex_value = Nvl(value.id, value.value))
      then
             meaning := nvl(value.meaning, value.value);
      end if;

      /* Get next flex value in set */

      fnd_vset.get_value(vset, row, found, value);

   END LOOP;

   fnd_vset.get_value_end(vset);

   /* cache the value of this value set */
   flex_val_count := flex_val_count + 1;
   flex_val_cache(flex_val_count).flex_value_set_name := upper(vsname);
   flex_val_cache(flex_val_count).flex_value_id := v_flex_value;

   /* Return meaning (if found) otherwise the flex value. */

   return(nvl(meaning, v_flex_value));

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           fnd_vset.get_value_end(vset);
           return(v_flex_value);
        WHEN OTHERS THEN
          IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('EXCEPTION in get_flex_val_meaning');
                fa_rx_util_pkg.debug('get_flex_val_meaning: ' || sqlerrm);
          END IF;
--         return(NULL);
          return(v_flex_value);
END get_flex_val_meaning;


--* Bug2991482, rravunny
--* new overridden function to support parent value.
--*
FUNCTION get_flex_val_meaning (
                v_flex_value_set_id     IN NUMBER,
                v_flex_value_set_name   IN VARCHAR2,
                v_flex_value            IN VARCHAR2,
                v_parent_flex_val       IN VARCHAR2)
RETURN VARCHAR2 IS
   vsid number;
   vset fnd_vset.valueset_r;
   fmt fnd_vset.valueset_dr;
   found BOOLEAN;
   row NUMBER;
   value fnd_vset.value_dr;
   meaning varchar2(240) := '';
   vsname varchar2(150);

   i            BINARY_INTEGER := 0;
   y            BINARY_INTEGER := 0;

   /* This function returns:
         - the meaning of a passed flex value, if the valueset is found and it has an entry
           for the flex value and the entry has a meaning associated with it.
         - the flex value, if the flex value passed is null or if the flex value is
           not found in the valueset or if both valueset parameters are NULL or if the
           flex value is found in the valueset but doesn't have a meaning */

BEGIN

   /* Return NULL if flex value is null */

   if (v_flex_value is null) then return (v_flex_value); end if;

   /* If flex value set id is null and flex value set name is null too,
      return the flex value passed into the function.

      If either of the flex value set id or the flex valueset name is null,
      select it and move on with the rest of the function. */

   if (v_flex_value_set_name is null)
   then
      if (v_flex_value_set_id is null)
      then
          return(v_flex_value);
      else
          select flex_value_set_name
          into   vsname
          from   fnd_flex_value_sets
          where  flex_value_set_id = v_flex_value_set_id;

          vsid := v_flex_value_set_id;

      end if;
   else
      if (v_flex_value_set_id is null)
      then
          select flex_value_set_id
          into   vsid
          from   fnd_flex_value_sets
          where  flex_value_set_name = v_flex_value_set_name;

      else
          vsid := v_flex_value_set_id;
      end if;

      vsname := v_flex_value_set_name;

   end if;

   /* Search PL/SQL tables for valuesets and values that have already been loaded */

   if (g_value_set_counter >= 1)
   then
         FOR i in 1..g_value_set_counter LOOP
              if (g_value_set_tab(i).value_set_name = vsname)
              then
                  FOR y in g_value_set_tab(i).from_counter..g_value_set_tab(i).to_counter LOOP
                    --* if dependant value set.
                     if (v_parent_flex_val is not null and g_values_tab(y).value = v_flex_value
                         and g_values_tab(y).parent_flex_value_low = v_parent_flex_val)
                     then
                        meaning := nvl(g_values_tab(y).meaning, v_flex_value);
                        return(meaning);
                     end if;
                    --* if other than dependant value set.

                     if (g_values_tab(y).value = v_flex_value and v_parent_flex_val is null)
                     then
                        meaning := nvl(g_values_tab(y).meaning, v_flex_value);
                        return(meaning);
                     end if;
                  END LOOP;
                  return(v_flex_value);
              end if;

         END LOOP;
   end if;
   g_value_set_counter := g_value_set_counter + 1;
   g_value_set_tab(g_value_set_counter).value_set_name := vsname;
   g_value_set_tab(g_value_set_counter).from_counter := g_value_counter + 1;
   g_value_set_tab(g_value_set_counter).to_counter := g_value_counter + 1;

   /* Get valueset info */
   fnd_vset.get_valueset(vsid, vset, fmt);

   If nvl(vset.validation_type,'*') = 'F' and nvl(fmt.longlist_flag,'N') = 'Y' Then
        /* Initialize WHERE Clause for Table validated value sets */
        Initialize_Where(vset,v_flex_value);
   Else
        Initialize_Where(vset,null);
   End If;

   /* Initialize valueset variables */
   fnd_vset.get_value_init(vset, TRUE);

   /* Fetch first value of valueset */
   fnd_vset.get_value(vset, row, found, value);

   WHILE(found) LOOP
      /* Increase session flex value counter by 1 */

      g_value_counter := g_value_counter + 1;

      /* Store flex values away */

      g_values_tab(g_value_counter).meaning := substr(nvl(value.meaning, value.value), 1, 240);
      g_values_tab(g_value_counter).value   := substr(Nvl(value.id, value.value), 1, 150);
      g_values_tab(g_value_counter).parent_flex_value_low   := value.parent_flex_value_low;
      g_value_set_tab(g_value_set_counter).to_counter := g_value_counter;

      /* Check if fetched value matches the passed flex value, if yes
         store the meaning in variable meaning */

      if (v_flex_value = Nvl(value.id, value.value) and v_parent_flex_val is not null and v_parent_flex_val = value.parent_flex_value_low)
      then
             meaning := nvl(value.meaning, value.value);
      end if;

      if (v_flex_value = Nvl(value.id, value.value) and v_parent_flex_val is null)
      then
             meaning := nvl(value.meaning, value.value);
      end if;
      /* Get next flex value in set */
      fnd_vset.get_value(vset, row, found, value);

   END LOOP;

   fnd_vset.get_value_end(vset);
   /* cache the value of this value set */
   flex_val_count := flex_val_count + 1;
   flex_val_cache(flex_val_count).flex_value_set_name := upper(vsname);
   flex_val_cache(flex_val_count).flex_value_id := v_flex_value;
   /* Return meaning (if found) otherwise the flex value. */

   return(nvl(meaning, v_flex_value));

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           fnd_vset.get_value_end(vset);
           return(v_flex_value);
        WHEN OTHERS THEN
        fnd_vset.get_value_end(vset);
          return(v_flex_value);
END get_flex_val_meaning;

FUNCTION get_asset_info (
        v_info_type             IN VARCHAR2,
        v_asset_id              IN NUMBER,
        v_from_date             IN DATE,
        v_to_date               IN DATE,
        v_book_type_code        IN VARCHAR2,
        v_balancing_segment     IN VARCHAR2)
  return VARCHAR2 is

  CURSOR c_vendor_name (c_asset_id NUMBER, c_to_date DATE) IS
        select
                distinct v.vendor_name
        from
                po_vendors v,
                fa_asset_invoices i
        where
                i.asset_id                      =       c_asset_id and
                i.date_effective                <=      c_to_date and
                nvl(i.date_ineffective,
                    sysdate)                    >       c_to_date
        and
                v.vendor_id = i.po_vendor_id;

  CURSOR c_invoice (c_asset_id NUMBER, c_to_date DATE) IS
        select
                distinct ap_i.invoice_num, ap_i.description
        from
                ap_invoices_all ap_i,
                fa_asset_invoices i
        where
                i.asset_id                      =       c_asset_id and

                i.date_effective                <=      c_to_date and
                nvl(i.date_ineffective,
                    sysdate)                    >       c_to_date
        and
                ap_i.invoice_id                 =       i.invoice_id;

  CURSOR c_retirement_type (c_asset_id NUMBER, c_from_date DATE, c_to_date DATE, c_book_type_code VARCHAR2) IS
        select
                distinct lu.meaning
        from
                fa_lookups lu,
                fa_transaction_headers th,
                fa_retirements r
        where
                r.asset_id                      =       c_asset_id and
                r.book_type_code                =       c_book_type_code and
                th.transaction_header_id        =       r.transaction_header_id_in and
                th.date_effective               between c_from_date and c_to_date
        and
                lu.lookup_type                  = 'RETIREMENT' and
                lu.lookup_code                  = r.retirement_type_code;

  CURSOR c_location (c_asset_id NUMBER, c_to_date DATE, c_book_type_code VARCHAR2) IS
        select
                distinct dh.location_id, dh.code_combination_id
        from
                fa_distribution_history dh
        where
                dh.asset_id                     =       c_asset_id and
                dh.book_type_code               =       c_book_type_code and
                dh.date_effective               <=      c_to_date and
                nvl(dh.date_ineffective,
                    sysdate)                    >       c_to_date;


  h_vendor_name         VARCHAR2(240);
  h_invoice_number      VARCHAR2(50);
  h_invoice_descr       VARCHAR2(240);
  h_retirement_type     VARCHAR2(80);
  h_location            VARCHAR2(240);
  h_location_id         NUMBER;
  h_loc_segs            fa_rx_shared_pkg.Seg_Array;
  h_ccid                NUMBER;

  first_vendor          BOOLEAN := TRUE;
  first_invoice_number  BOOLEAN := TRUE;
  first_invoice_descr   BOOLEAN := TRUE;
  first_retirement_type BOOLEAN := TRUE;
  first_location        BOOLEAN := TRUE;

  concat_vendor_name    VARCHAR2(1000);
  concat_invoice_number VARCHAR2(1000);
  concat_invoice_descr  VARCHAR2(1000);
  concat_retirement_type VARCHAR2(1000);
  concat_location       VARCHAR2(1000);

  acct_all_segs         fa_rx_shared_pkg.Seg_Array;
  n_segs                number;
  gl_balancing_seg      number;
  gl_account_seg        number;
  fa_cost_ctr_seg       number;
  max_length            number := 500;


BEGIN

   /* Get location flex structure if it's not there already */

   if (g_loc_flex_struct is NULL)
   then
     select     location_flex_structure
     into       g_loc_flex_struct
     from       fa_system_controls;
   end if;

  /* Get vendor name */

  if (v_info_type = 'VENDOR_NAME')
  then
     open c_vendor_name (v_asset_id, v_to_date);
     loop
        fetch c_vendor_name into h_vendor_name;
        if (c_vendor_name%NOTFOUND) then exit; end if;
        if (first_vendor)
        then
           concat_vendor_name   := h_vendor_name;
           first_vendor         := FALSE;
        else
           if (length(concat_vendor_name || ', ' || h_vendor_name ) > max_length)
           then
                exit;
           else
                concat_vendor_name  := concat_vendor_name || ', ' || h_vendor_name ;
           end if;
        end if;
     end loop;
     close c_vendor_name;
     return(concat_vendor_name);
  end if;

  /* Get invoice */

  if (v_info_type = 'INVOICE_NUMBER')
  then

     open c_invoice (v_asset_id, v_to_date);
     loop
        fetch c_invoice into h_invoice_number, h_invoice_descr;
        if (c_invoice%NOTFOUND) then exit; end if;
        if (first_invoice_number)
        then
           concat_invoice_number        := h_invoice_number;
           first_invoice_number         := FALSE;
        else
           if (length(concat_invoice_number || ', ' || h_invoice_number) > max_length)
           then
                exit;
           else
                concat_invoice_number   := concat_invoice_number || ', ' || h_invoice_number ;
           end if;
        end if;
     end loop;
     close c_invoice;
     return(concat_invoice_number);
  end if;

  /* Get invoice description */

  if (v_info_type = 'INVOICE_DESCR')
  then
     open c_invoice (v_asset_id, v_to_date);
     loop

        fetch c_invoice into h_invoice_number, h_invoice_descr;
        if (c_invoice%NOTFOUND) then exit; end if;

        if (h_invoice_descr is not null)
        then
           if (first_invoice_descr)
           then
              concat_invoice_descr      := h_invoice_descr;
              first_invoice_descr       := FALSE;
           else
              if (length(concat_invoice_descr || ', ' || h_invoice_descr) > max_length)
              then
                   exit;
              else
                   concat_invoice_descr         := concat_invoice_descr || ', ' || h_invoice_descr;
              end if;
           end if;
        end if;

     end loop;
     close c_invoice;
     return(concat_invoice_descr);
  end if;

  /* Get retirement type */

  if (v_info_type = 'RETIREMENT_TYPE')
  then
     open c_retirement_type (v_asset_id, v_from_date, v_to_date, v_book_type_code);
     loop
        fetch c_retirement_type into h_retirement_type;
        if (c_retirement_type%NOTFOUND) then exit; end if;
        if (first_retirement_type)
        then
           concat_retirement_type               := h_retirement_type;
           first_retirement_type                := FALSE;
        else
           if (length(concat_retirement_type || ', ' || h_retirement_type) > max_length)
           then
                exit;
           else
                concat_retirement_type          := concat_retirement_type || ', ' || h_retirement_type;
           end if;
        end if;
     end loop;
     close c_retirement_type;
     return(concat_retirement_type);
  end if;

  /* Get location */

  if (v_info_type = 'LOCATION')
  then

     /* Get accounting flexfield's segment numbers */

     fa_rx_shared_pkg.get_acct_segment_numbers (
           BOOK => v_book_type_code,
           BALANCING_SEGNUM => gl_balancing_seg,
           ACCOUNT_SEGNUM => gl_account_seg,
           CC_SEGNUM => fa_cost_ctr_seg,
           CALLING_FN => 'FA_BALANCES_REPORT');

     open c_location (v_asset_id, v_to_date, v_book_type_code);
     loop
        fetch c_location into h_location_id, h_ccid;

        if (c_location%NOTFOUND) then exit; end if;

        /* Get accounting flexfield segment values */

        fa_rx_shared_pkg.get_acct_segments (
          combination_id => h_ccid,
          n_segments => n_segs,
          segments => acct_all_segs,
          calling_fn => 'FA_BALANCES_REPORT');

        /* Add location only if it is for the appropriate balancing segment */

        if (acct_all_segs(gl_balancing_seg) = v_balancing_segment)
        then

             /* Get concatenated location */

             fa_rx_shared_pkg.concat_location (
                struct_id               => g_loc_flex_struct,
                ccid                    => h_location_id,
                concat_string           => h_location,
                segarray                => h_loc_segs);

             if (first_location)
             then
                concat_location         := h_location;
                first_location          := FALSE;
             else

               if (length(concat_location || ', ' || h_location) > max_length) then
                  exit;
               else
                concat_location         := concat_location || ', ' || h_location;
               end if;

             end if;
        end if;

     end loop;

     close c_location;

     return(concat_location);

  end if;

END get_asset_info;

PROCEDURE clear_flex_val_cache
IS
BEGIN
  flex_val_count := 0;
END clear_flex_val_cache;

END FA_RX_SHARED_PKG;

/
