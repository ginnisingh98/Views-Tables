--------------------------------------------------------
--  DDL for Package Body FA_RSVLDG_REP_INS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RSVLDG_REP_INS_PKG" AS
/*$Header: farsvinb.pls 120.0.12010000.6 2009/12/23 05:23:39 anujain noship $*/
PROCEDURE RSVLDG (book in  varchar2,
                  period in  varchar2,
                  errbuf out NOCOPY varchar2,
		  retcode out NOCOPY number,
                  operation out nocopy varchar2,
		  request_id in number)   --bug 9235908
IS
        --operation       varchar2(200);
        dist_book       varchar2(15);
        ucd             date;
        upc             number;
        tod             date;
        tpc             number;

        h_set_of_books_id  number;
        h_reporting_flag   varchar2(1);
        bonus_count number := 0 ;  -- bugfix 6677528 (initialize)
        l_request_id  Number;

        CURSOR Launch_worker(request_id_in NUMBER) IS
                SELECT Start_range ,
                       End_range
                FROM   FA_WORKER_JOBS
                WHERE  request_id = request_id_in;
begin
      -- get mrc related info
    begin
      select  to_number(substrb(userenv('CLIENT_INFO'),45,10))
      into    h_set_of_books_id from dual;
    exception
    when others then
     h_set_of_books_id := null;
    end;
    if (h_set_of_books_id is not null) then
     if not fa_cache_pkg.fazcsob
            (X_set_of_books_id   => h_set_of_books_id,
             X_mrc_sob_type_code => h_reporting_flag) then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
    else
     h_reporting_flag := 'P';
    end if;
    operation := 'Selecting Book and Period information';
       if (h_reporting_flag = 'R') then
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
                FA_DEPRN_PERIODS_MRC_V        DP,
                FA_DEPRN_PERIODS_MRC_V        DP_FY,
                FA_BOOK_CONTROLS_MRC_V        BC
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
       else
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
       end if;


/* Bugfix 6677528 : query should have  more  conditions. Use exists instead of count */
       BEGIN
         Select 1
         Into   bonus_count
         From   dual
         where exists (select 1 from FA_Books
                     Where book_type_code = book
                     and   bonus_rule is not null
                     and   transaction_header_id_out is null);
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
         bonus_count := 0;
       END;
-- end bugfix 6677528
       operation := 'Inserting into FA_RESERVE_LEDGER_GT';

 --==================================================
--OPEN LOAD WORKER CURSOR HERE.
--==================================================
     -- fnd_profile.get('CONC_REQUEST_ID', l_request_id); bug 9235908
     -- request_id will be passed from report directly instead of
     -- getting its value from profile option.
     l_request_id := request_id;

     --Call another PL/SQL here to insert this data into FA_WORKER_JOBS
     FA_BALREP_PKG.LOAD_WORKERS( Book,l_request_id, errbuf, retcode);

     if (retcode <> 1 ) then
       null;
       --Error
     End if;
     commit;
 --==================================================

For Rec1 in Launch_worker(l_request_id) loop
Exit when Launch_worker%notfound;

  -- run only if CRL not installed

  If (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'N' ) then

   If bonus_count > 0 then

    if (h_reporting_flag = 'R') then
       INSERT  INTO   FA_RESERVE_LEDGER_GT
              (
                     ASSET_ID              ,
                     DH_CCID               ,
                     DEPRN_RESERVE_ACCT    ,
                     DATE_PLACED_IN_SERVICE,
                     METHOD_CODE           ,
                     LIFE                  ,
                     RATE                  ,
                     CAPACITY              ,
                     COST                  ,
                     DEPRN_AMOUNT          ,
                     YTD_DEPRN             ,
                     DEPRN_RESERVE         ,
                     PERCENT               ,
                     TRANSACTION_TYPE      ,
                     PERIOD_COUNTER        ,
                     DATE_EFFECTIVE        ,
                     RESERVE_ACCT
              )
       SELECT  /*+ ORDERED
                   Index(DD1 FA_DEPRN_DETAIL_N1)
		   Index(DD_BONUS FA_DEPRN_DETAIL_U1)
		   index(DH FA_DISTRIBUTION_HISTORY_U1)
		   Index(AH FA_ASSET_HISTORY_N2)
		   */
              DH.ASSET_ID ASSET_ID                                                                                                                                                                                             ,
              DH.CODE_COMBINATION_ID DH_CCID                                                                                                                                                                                   ,
              CB.DEPRN_RESERVE_ACCT RSV_ACCOUNT                                                                                                                                                                                ,
              BOOKS.DATE_PLACED_IN_SERVICE START_DATE                                                                                                                                                                          ,
              BOOKS.DEPRN_METHOD_CODE METHOD                                                                                                                                                                                   ,
              BOOKS.LIFE_IN_MONTHS LIFE                                                                                                                                                                                        ,
              BOOKS.ADJUSTED_RATE RATE                                                                                                                                                                                         ,
              BOOKS.PRODUCTION_CAPACITY CAPACITY                                                                                                                                                                               ,
              DD_BONUS.COST COST                                                                                                                                                                                               ,
              DECODE (DD_BONUS.PERIOD_COUNTER, upc, DD_BONUS.DEPRN_AMOUNT   - DD_BONUS.BONUS_DEPRN_AMOUNT, 0) DEPRN_AMOUNT                                                                                                     ,
              DECODE (SIGN (tpc                                             - DD_BONUS.PERIOD_COUNTER), 1, 0, DD_BONUS.YTD_DEPRN - DD_BONUS.BONUS_YTD_DEPRN) YTD_DEPRN                                                         ,
              DD_BONUS.DEPRN_RESERVE                                        - DD_BONUS.BONUS_DEPRN_RESERVE DEPRN_RESERVE                                                                                                       ,
              DECODE (DH.TRANSACTION_HEADER_ID_OUT, NULL, DH.UNITS_ASSIGNED / AH.UNITS * 100) PERCENT                                                                                                                          ,
              DECODE (DH.TRANSACTION_HEADER_ID_OUT, NULL, DECODE (TH_RT.TRANSACTION_TYPE_CODE, 'FULL RETIREMENT', 'F', DECODE (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')), 'TRANSFER', 'T', 'TRANSFER OUT', 'P', 'RECLASS', 'R') T_TYPE,
              DD_BONUS.PERIOD_COUNTER                                                                                                                                                                                          ,
              ucd                                                                                                                                                                                                              ,
              ''
       FROM
           --FA_DEPRN_DETAIL_MRC_V DD_BONUS,
              (   SELECT DISTRIBUTION_ID   ,
                         MAX(PERIOD_COUNTER) PERIOD_COUNTER
                   FROM  FA_DEPRN_DETAIL_MRC_V
                   WHERE BOOK_TYPE_CODE  = book
                     AND PERIOD_COUNTER <= upc
                     AND ASSET_ID BETWEEN REC1.START_RANGE AND REC1.END_RANGE
                   GROUP BY DISTRIBUTION_ID
              ) dd1,
              FA_DEPRN_DETAIL_MRC_V DD_BONUS,
	      FA_DISTRIBUTION_HISTORY DH  ,
              FA_ASSET_HISTORY AH         ,
	      FA_BOOKS_MRC_V BOOKS        ,
              FA_TRANSACTION_HEADERS TH_RT,
              FA_CATEGORY_BOOKS CB
       WHERE  BOOKS.BOOK_TYPE_CODE                          = book
          AND BOOKS.ASSET_ID                                = DD_BONUS.ASSET_ID --7721457
          AND NVL(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc
          AND BOOKS.DATE_EFFECTIVE                         <= ucd
          AND NVL(BOOKS.DATE_INEFFECTIVE,sysdate+1)         > ucd
          AND CB.BOOK_TYPE_CODE                             = BOOKS.BOOK_TYPE_CODE
          AND CB.CATEGORY_ID                                = AH.CATEGORY_ID
          AND AH.ASSET_ID                                   = DD_BONUS.ASSET_ID --7721457
          AND AH.DATE_EFFECTIVE                             < ucd
          AND NVL(AH.DATE_INEFFECTIVE,sysdate)             >= ucd
          AND AH.ASSET_TYPE                                 = 'CAPITALIZED'
          AND DD_BONUS.BOOK_TYPE_CODE                       = BOOKS.BOOK_TYPE_CODE
          AND DD_BONUS.DISTRIBUTION_ID                      = DD1.DISTRIBUTION_ID --7721457
          AND DD_BONUS.PERIOD_COUNTER                       = DD1.PERIOD_COUNTER  --7721457
          AND DD_BONUS.ASSET_ID  BETWEEN REC1.START_RANGE AND REC1.END_RANGE
          AND DD_BONUS.DISTRIBUTION_ID                      = DH.DISTRIBUTION_ID
          AND TH_RT.BOOK_TYPE_CODE                          = BOOKS.BOOK_TYPE_CODE
          AND TH_RT.TRANSACTION_HEADER_ID       = BOOKS.TRANSACTION_HEADER_ID_IN
          AND DH.BOOK_TYPE_CODE                 = dist_book
          AND DH.DATE_EFFECTIVE                <= ucd
          AND NVL(DH.DATE_INEFFECTIVE, sysdate) > tod
       UNION ALL
       SELECT  /*+ ORDERED
                   Index(DD1 FA_DEPRN_DETAIL_N1)
		   Index(DD FA_DEPRN_DETAIL_U1)
		   index(DH FA_DISTRIBUTION_HISTORY_U1)
		   Index(AH FA_ASSET_HISTORY_N2)
               */
              DH.ASSET_ID ASSET_ID                                                       ,
              DH.CODE_COMBINATION_ID DH_CCID                                             ,
              CB.BONUS_DEPRN_RESERVE_ACCT RSV_ACCOUNT                                    ,
              BOOKS.DATE_PLACED_IN_SERVICE START_DATE                                    ,
              BOOKS.DEPRN_METHOD_CODE METHOD                                             ,
              BOOKS.LIFE_IN_MONTHS LIFE                                                  ,
              BOOKS.ADJUSTED_RATE RATE                                                   ,
              BOOKS.PRODUCTION_CAPACITY CAPACITY                                         ,
              0 COST                                                                     ,
              DECODE (DD.PERIOD_COUNTER, upc, DD.BONUS_DEPRN_AMOUNT, 0) DEPRN_AMOUNT     ,
              DECODE (SIGN (tpc - DD.PERIOD_COUNTER), 1, 0, DD.BONUS_YTD_DEPRN) YTD_DEPRN,
              DD.BONUS_DEPRN_RESERVE DEPRN_RESERVE                                       ,
              0 PERCENT                                                                  ,
              'B' T_TYPE                                                                 ,
              DD.PERIOD_COUNTER                                                          ,
              ucd                                                                        ,
              CB.BONUS_DEPRN_EXPENSE_ACCT
       FROM
              --FA_DEPRN_DETAIL_MRC_V DD,
	     ( SELECT  DISTRIBUTION_ID   ,
                       MAX(PERIOD_COUNTER) PERIOD_COUNTER
              FROM     FA_DEPRN_DETAIL_MRC_V
              WHERE    BOOK_TYPE_CODE  = book
                   AND PERIOD_COUNTER <= upc
                   AND ASSET_ID BETWEEN REC1.START_RANGE AND REC1.END_RANGE
              GROUP BY DISTRIBUTION_ID
              ) dd1,
	      FA_DEPRN_DETAIL_MRC_V DD,
	      FA_DISTRIBUTION_HISTORY DH  ,
              FA_ASSET_HISTORY AH         ,
	      FA_BOOKS_MRC_V BOOKS        ,
              FA_TRANSACTION_HEADERS TH_RT,
              FA_CATEGORY_BOOKS CB
       WHERE  BOOKS.BOOK_TYPE_CODE                          = book
          AND BOOKS.ASSET_ID                                = DD.ASSET_ID   --7721457
          AND NVL(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc
          AND BOOKS.DATE_EFFECTIVE                         <= ucd
          AND NVL(BOOKS.DATE_INEFFECTIVE,sysdate+1)         > ucd
          AND BOOKS.BONUS_RULE IS NOT NULL
          AND DD.DISTRIBUTION_ID                = DD1.DISTRIBUTION_ID --7721457
          AND DD.PERIOD_COUNTER                 = DD1.PERIOD_COUNTER  --7721457
	  AND DD.BOOK_TYPE_CODE                 = BOOKS.BOOK_TYPE_CODE
          AND DD.DISTRIBUTION_ID                = DH.DISTRIBUTION_ID
          AND DD.ASSET_ID         BETWEEN REC1.START_RANGE AND REC1.END_RANGE
          AND CB.BOOK_TYPE_CODE                 = BOOKS.BOOK_TYPE_CODE
          AND CB.CATEGORY_ID                    = AH.CATEGORY_ID
          AND AH.ASSET_ID                       = DD.ASSET_ID  --7721457
          AND AH.DATE_EFFECTIVE                 < ucd
          AND NVL(AH.DATE_INEFFECTIVE,sysdate) >= ucd
          AND AH.ASSET_TYPE                     = 'CAPITALIZED'
          AND TH_RT.BOOK_TYPE_CODE              = BOOKS.BOOK_TYPE_CODE
          AND TH_RT.TRANSACTION_HEADER_ID       = BOOKS.TRANSACTION_HEADER_ID_IN
          AND DH.BOOK_TYPE_CODE                 = dist_book
          AND DH.DATE_EFFECTIVE                <= ucd
          AND NVL(DH.DATE_INEFFECTIVE, sysdate) > tod ;

   else
      /* ie h_reporting_flag <> 'R' */

-- start here...
INSERT INTO   FA_RESERVE_LEDGER_GT
       (
              ASSET_ID              ,
              DH_CCID               ,
              DEPRN_RESERVE_ACCT    ,
              DATE_PLACED_IN_SERVICE,
              METHOD_CODE           ,
              LIFE                  ,
              RATE                  ,
              CAPACITY              ,
              COST                  ,
              DEPRN_AMOUNT          ,
              YTD_DEPRN             ,
              DEPRN_RESERVE         ,
              PERCENT               ,
              TRANSACTION_TYPE      ,
              PERIOD_COUNTER        ,
              DATE_EFFECTIVE        ,
              RESERVE_ACCT
       )
SELECT /*+ ORDERED
                   Index(DD1 FA_DEPRN_DETAIL_N1)
		   Index(DD_BONUS FA_DEPRN_DETAIL_U1)
		   index(DH FA_DISTRIBUTION_HISTORY_U1)
		   Index(AH FA_ASSET_HISTORY_N2)
       */
       DH.ASSET_ID ASSET_ID                                                                                                                                                                                             ,
       DH.CODE_COMBINATION_ID DH_CCID                                                                                                                                                                                   ,
       CB.DEPRN_RESERVE_ACCT RSV_ACCOUNT                                                                                                                                                                                ,
       BOOKS.DATE_PLACED_IN_SERVICE START_DATE                                                                                                                                                                          ,
       BOOKS.DEPRN_METHOD_CODE METHOD                                                                                                                                                                                   ,
       BOOKS.LIFE_IN_MONTHS LIFE                                                                                                                                                                                        ,
       BOOKS.ADJUSTED_RATE RATE                                                                                                                                                                                         ,
       BOOKS.PRODUCTION_CAPACITY CAPACITY                                                                                                                                                                               ,
       DD_BONUS.COST COST                                                                                                                                                                                               ,
       DECODE (DD_BONUS.PERIOD_COUNTER, upc, DD_BONUS.DEPRN_AMOUNT   - DD_BONUS.BONUS_DEPRN_AMOUNT, 0) DEPRN_AMOUNT                                                                                                     ,
       DECODE (SIGN (tpc                                             - DD_BONUS.PERIOD_COUNTER), 1, 0, DD_BONUS.YTD_DEPRN - DD_BONUS.BONUS_YTD_DEPRN) YTD_DEPRN                                                         ,
       DD_BONUS.DEPRN_RESERVE                                        - DD_BONUS.BONUS_DEPRN_RESERVE DEPRN_RESERVE                                                                                                       ,
       DECODE (DH.TRANSACTION_HEADER_ID_OUT, NULL, DH.UNITS_ASSIGNED / AH.UNITS * 100) PERCENT                                                                                                                          ,
       DECODE (DH.TRANSACTION_HEADER_ID_OUT, NULL, DECODE (TH_RT.TRANSACTION_TYPE_CODE, 'FULL RETIREMENT', 'F', DECODE (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')), 'TRANSFER', 'T', 'TRANSFER OUT', 'P', 'RECLASS', 'R') T_TYPE,
       DD_BONUS.PERIOD_COUNTER                                                                                                                                                                                          ,
       ucd                                                                                                                                                                                                              ,
       ''
FROM
       --FA_DEPRN_DETAIL DD_BONUS,
       ( SELECT  DISTRIBUTION_ID   ,
                MAX(PERIOD_COUNTER) PERIOD_COUNTER
       FROM     FA_DEPRN_DETAIL
       WHERE    BOOK_TYPE_CODE  = book
            AND PERIOD_COUNTER <= upc
            AND ASSET_ID BETWEEN REC1.START_RANGE AND REC1.END_RANGE
       GROUP BY DISTRIBUTION_ID
       ) DD1 ,
       FA_DEPRN_DETAIL DD_BONUS    ,
       FA_DISTRIBUTION_HISTORY DH  ,
       FA_ASSET_HISTORY AH         ,
       FA_BOOKS BOOKS              ,
       FA_TRANSACTION_HEADERS TH_RT,
       FA_CATEGORY_BOOKS CB
WHERE  BOOKS.BOOK_TYPE_CODE                          = book
   AND BOOKS.ASSET_ID                                = DD_BONUS.ASSET_ID --7721457
   AND NVL(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc
   AND BOOKS.DATE_EFFECTIVE                         <= ucd
   AND NVL(BOOKS.DATE_INEFFECTIVE,sysdate+1)         > ucd
   AND CB.BOOK_TYPE_CODE                             = BOOKS.BOOK_TYPE_CODE
   AND CB.CATEGORY_ID                                = AH.CATEGORY_ID
   AND AH.ASSET_ID                                   = DD_BONUS.ASSET_ID --7721457
   AND DD_BONUS.BOOK_TYPE_CODE                       = BOOKS.BOOK_TYPE_CODE
   AND DD_BONUS.DISTRIBUTION_ID                      = DH.DISTRIBUTION_ID
   AND DD_BONUS.DISTRIBUTION_ID                      = dd1.DISTRIBUTION_ID --7721457
   AND DD_BONUS.PERIOD_COUNTER                       = DD1.PERIOD_COUNTER  --7721457
   AND DD_BONUS.ASSET_ID           BETWEEN REC1.START_RANGE AND REC1.END_RANGE
   AND AH.DATE_EFFECTIVE                             < ucd
   AND NVL(AH.DATE_INEFFECTIVE,sysdate)              >= ucd
   AND AH.ASSET_TYPE                                 = 'CAPITALIZED'
   AND TH_RT.BOOK_TYPE_CODE                          = BOOKS.BOOK_TYPE_CODE
   AND TH_RT.TRANSACTION_HEADER_ID                   = BOOKS.TRANSACTION_HEADER_ID_IN
   AND DH.BOOK_TYPE_CODE                             = dist_book
   AND DH.DATE_EFFECTIVE                             <= ucd
   AND NVL(DH.DATE_INEFFECTIVE, sysdate)             > tod
UNION ALL
SELECT /*+ ORDERED
                   Index(DD1 FA_DEPRN_DETAIL_N1)
		   Index(DD FA_DEPRN_DETAIL_U1)
		   index(DH FA_DISTRIBUTION_HISTORY_U1)
		   Index(AH FA_ASSET_HISTORY_N2)
       */
       DH.ASSET_ID ASSET_ID                                                       ,
       DH.CODE_COMBINATION_ID DH_CCID                                             ,
       CB.BONUS_DEPRN_RESERVE_ACCT RSV_ACCOUNT                                    ,
       BOOKS.DATE_PLACED_IN_SERVICE START_DATE                                    ,
       BOOKS.DEPRN_METHOD_CODE METHOD                                             ,
       BOOKS.LIFE_IN_MONTHS LIFE                                                  ,
       BOOKS.ADJUSTED_RATE RATE                                                   ,
       BOOKS.PRODUCTION_CAPACITY CAPACITY                                         ,
       0 COST                                                                     ,
       DECODE (DD.PERIOD_COUNTER, upc, DD.BONUS_DEPRN_AMOUNT, 0) DEPRN_AMOUNT     ,
       DECODE (SIGN (tpc - DD.PERIOD_COUNTER), 1, 0, DD.BONUS_YTD_DEPRN) YTD_DEPRN,
       DD.BONUS_DEPRN_RESERVE DEPRN_RESERVE                                       ,
       0 PERCENT                                                                  ,
       'B' T_TYPE                                                                 ,
       DD.PERIOD_COUNTER                                                          ,
       ucd                                                                        ,
       CB.BONUS_DEPRN_EXPENSE_ACCT
FROM
       --FA_DEPRN_DETAIL         DD,
       ( SELECT  DISTRIBUTION_ID   ,
                MAX(PERIOD_COUNTER) PERIOD_COUNTER
       FROM     FA_DEPRN_DETAIL
       WHERE    BOOK_TYPE_CODE  = book
            AND PERIOD_COUNTER <= upc
            AND ASSET_ID BETWEEN REC1.START_RANGE AND REC1.END_RANGE
       GROUP BY DISTRIBUTION_ID
       ) DD1,
       FA_DEPRN_DETAIL DD          ,
       FA_DISTRIBUTION_HISTORY DH  ,
       FA_ASSET_HISTORY AH         ,
       FA_BOOKS BOOKS              ,
       FA_TRANSACTION_HEADERS TH_RT,
       FA_CATEGORY_BOOKS CB
WHERE  BOOKS.BOOK_TYPE_CODE                          = book
   AND BOOKS.ASSET_ID                                = DD.ASSET_ID  --7721457
   AND NVL(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc
   AND BOOKS.DATE_EFFECTIVE                         <= ucd
   AND NVL(BOOKS.DATE_INEFFECTIVE,sysdate+1)         > ucd
   AND BOOKS.BONUS_RULE                IS NOT NULL
   AND CB.BOOK_TYPE_CODE                             = BOOKS.BOOK_TYPE_CODE
   AND CB.CATEGORY_ID                                = AH.CATEGORY_ID
   AND AH.ASSET_ID                                   = DD.ASSET_ID  --7721457
   AND AH.DATE_EFFECTIVE                             < ucd
   AND NVL(AH.DATE_INEFFECTIVE,sysdate)              >= ucd
   AND AH.ASSET_TYPE                                 = 'CAPITALIZED'
   AND DD.DISTRIBUTION_ID                            = dd1.DISTRIBUTION_ID --7721457
   AND DD.PERIOD_COUNTER                             = DD1.PERIOD_COUNTER  --7721457
   AND DD.ASSET_ID                 BETWEEN REC1.START_RANGE AND REC1.END_RANGE
   AND DD.BOOK_TYPE_CODE                             = BOOKS.BOOK_TYPE_CODE
   AND DD.DISTRIBUTION_ID                            = DH.DISTRIBUTION_ID
   AND TH_RT.BOOK_TYPE_CODE                          = BOOKS.BOOK_TYPE_CODE
   AND TH_RT.TRANSACTION_HEADER_ID                   = BOOKS.TRANSACTION_HEADER_ID_IN
   AND DH.BOOK_TYPE_CODE                             = dist_book
   AND DH.DATE_EFFECTIVE                             <= ucd
   AND NVL(DH.DATE_INEFFECTIVE, sysdate)             > tod ;
END IF;

 Else -- bonus_count i.e. if no bonus assets this branch.

   /* ie. bonus_count = 0 */

    -- run only if CRL not installed
   if (h_reporting_flag = 'R') then
    INSERT  INTO   FA_RESERVE_LEDGER_GT
         (      ASSET_ID              ,
                DH_CCID               ,
                DEPRN_RESERVE_ACCT    ,
                DATE_PLACED_IN_SERVICE,
                METHOD_CODE           ,
                LIFE                  ,
                RATE                  ,
                CAPACITY              ,
                COST                  ,
                DEPRN_AMOUNT          ,
                YTD_DEPRN             ,
                DEPRN_RESERVE         ,
                PERCENT               ,
                TRANSACTION_TYPE      ,
                PERIOD_COUNTER        ,
                DATE_EFFECTIVE        ,
                RESERVE_ACCT
         )
  SELECT  /*+ ORDERED
                   Index(DD1 FA_DEPRN_DETAIL_N1)
		   Index(DD_BONUS FA_DEPRN_DETAIL_U1)
		   index(DH FA_DISTRIBUTION_HISTORY_U1)
		   Index(AH FA_ASSET_HISTORY_N2)
	  */
         DH.ASSET_ID ASSET_ID                                                                                                                                                                                             ,
         DH.CODE_COMBINATION_ID DH_CCID                                                                                                                                                                                   ,
         CB.DEPRN_RESERVE_ACCT RSV_ACCOUNT                                                                                                                                                                                ,
         BOOKS.DATE_PLACED_IN_SERVICE START_DATE                                                                                                                                                                          ,
         BOOKS.DEPRN_METHOD_CODE METHOD                                                                                                                                                                                   ,
         BOOKS.LIFE_IN_MONTHS LIFE                                                                                                                                                                                        ,
         BOOKS.ADJUSTED_RATE RATE                                                                                                                                                                                         ,
         BOOKS.PRODUCTION_CAPACITY CAPACITY                                                                                                                                                                               ,
         DD_BONUS.COST COST                                                                                                                                                                                               ,
         DECODE (DD_BONUS.PERIOD_COUNTER, upc, DD_BONUS.DEPRN_AMOUNT   - DD_BONUS.BONUS_DEPRN_AMOUNT, 0) DEPRN_AMOUNT                                                                                                     ,
         DECODE (SIGN (tpc                                             - DD_BONUS.PERIOD_COUNTER), 1, 0, DD_BONUS.YTD_DEPRN - DD_BONUS.BONUS_YTD_DEPRN) YTD_DEPRN                                                         ,
         DD_BONUS.DEPRN_RESERVE                                        - DD_BONUS.BONUS_DEPRN_RESERVE DEPRN_RESERVE                                                                                                       ,
         DECODE (DH.TRANSACTION_HEADER_ID_OUT, NULL, DH.UNITS_ASSIGNED / AH.UNITS * 100) PERCENT                                                                                                                          ,
         DECODE (DH.TRANSACTION_HEADER_ID_OUT, NULL, DECODE (TH_RT.TRANSACTION_TYPE_CODE, 'FULL RETIREMENT', 'F', DECODE (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')), 'TRANSFER', 'T', 'TRANSFER OUT', 'P', 'RECLASS', 'R') T_TYPE,
         DD_BONUS.PERIOD_COUNTER                                                                                                                                                                                          ,
         ucd                                                                                                                                                                                                              ,
         ''
  FROM
         --FA_DEPRN_DETAIL_MRC_V   DD_BONUS,
	 ( SELECT  DISTRIBUTION_ID   ,
                  MAX(PERIOD_COUNTER) PERIOD_COUNTER
         FROM     FA_DEPRN_DETAIL_MRC_V
         WHERE    BOOK_TYPE_CODE  = book
              AND PERIOD_COUNTER <= upc
              AND ASSET_ID BETWEEN REC1.START_RANGE AND REC1.END_RANGE
         GROUP BY DISTRIBUTION_ID
         ) dd1,
	 FA_DEPRN_DETAIL_MRC_V DD_BONUS,
	 FA_DISTRIBUTION_HISTORY DH  ,
         FA_ASSET_HISTORY AH         ,
	 FA_BOOKS_MRC_V BOOKS        ,
         FA_TRANSACTION_HEADERS TH_RT,
         FA_CATEGORY_BOOKS CB
  WHERE  BOOKS.BOOK_TYPE_CODE                          = book
     AND BOOKS.ASSET_ID                                = DD_BONUS.ASSET_ID --7721457
     AND NVL(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc
     AND BOOKS.DATE_EFFECTIVE                         <= ucd
     AND NVL(BOOKS.DATE_INEFFECTIVE,sysdate+1)         > ucd
     AND DD_BONUS.DISTRIBUTION_ID                      = DD1.DISTRIBUTION_ID --7721457
     AND DD_BONUS.PERIOD_COUNTER                       = DD1.PERIOD_COUNTER  --7721457
     AND DD_BONUS.ASSET_ID  BETWEEN REC1.START_RANGE AND REC1.END_RANGE
     AND CB.BOOK_TYPE_CODE                             = BOOKS.BOOK_TYPE_CODE
     AND CB.CATEGORY_ID                                = AH.CATEGORY_ID
     AND AH.ASSET_ID                                   = DD_BONUS.ASSET_ID --7721457
     AND AH.DATE_EFFECTIVE                             < ucd
     AND NVL(AH.DATE_INEFFECTIVE,sysdate)             >= ucd
     AND AH.ASSET_TYPE                                 = 'CAPITALIZED'
     AND DD_BONUS.BOOK_TYPE_CODE                       = BOOKS.BOOK_TYPE_CODE
     AND -- BOOKS.BOOK_TYPE_CODE CHNGD
         DD_BONUS.DISTRIBUTION_ID                      = DH.DISTRIBUTION_ID
     AND TH_RT.BOOK_TYPE_CODE                          = BOOKS.BOOK_TYPE_CODE
     AND --chngd
         TH_RT.TRANSACTION_HEADER_ID       = BOOKS.TRANSACTION_HEADER_ID_IN
     AND DH.BOOK_TYPE_CODE                 = dist_book
     AND DH.DATE_EFFECTIVE                <= ucd
     AND NVL(DH.DATE_INEFFECTIVE, sysdate) > tod;
 Else -- reporting vs primary
     /* ie. h_reporting_flag <> 'R' */
    INSERT INTO FA_RESERVE_LEDGER_GT
       (
              ASSET_ID              ,
              DH_CCID               ,
              DEPRN_RESERVE_ACCT    ,
              DATE_PLACED_IN_SERVICE,
              METHOD_CODE           ,
              LIFE                  ,
              RATE                  ,
              CAPACITY              ,
              COST                  ,
              DEPRN_AMOUNT          ,
              YTD_DEPRN             ,
              DEPRN_RESERVE         ,
              PERCENT               ,
              TRANSACTION_TYPE      ,
              PERIOD_COUNTER        ,
              DATE_EFFECTIVE        ,
              RESERVE_ACCT
       )
   SELECT /*+ ORDERED
                   Index(DD1 FA_DEPRN_DETAIL_N1)
		   Index(DD_BONUS FA_DEPRN_DETAIL_U1)
		   index(DH FA_DISTRIBUTION_HISTORY_U1)
		   Index(AH FA_ASSET_HISTORY_N2)
          */
       DH.ASSET_ID ASSET_ID                                                                                                                                                                                             ,
       DH.CODE_COMBINATION_ID DH_CCID                                                                                                                                                                                   ,
       CB.DEPRN_RESERVE_ACCT RSV_ACCOUNT                                                                                                                                                                                ,
       BOOKS.DATE_PLACED_IN_SERVICE START_DATE                                                                                                                                                                          ,
       BOOKS.DEPRN_METHOD_CODE METHOD                                                                                                                                                                                   ,
       BOOKS.LIFE_IN_MONTHS LIFE                                                                                                                                                                                        ,
       BOOKS.ADJUSTED_RATE RATE                                                                                                                                                                                         ,
       BOOKS.PRODUCTION_CAPACITY CAPACITY                                                                                                                                                                               ,
       DD_BONUS.COST COST                                                                                                                                                                                               ,
       DECODE (DD_BONUS.PERIOD_COUNTER, upc, DD_BONUS.DEPRN_AMOUNT   - DD_BONUS.BONUS_DEPRN_AMOUNT, 0) DEPRN_AMOUNT                                                                                                     ,
       DECODE (SIGN (tpc                                             - DD_BONUS.PERIOD_COUNTER), 1, 0, DD_BONUS.YTD_DEPRN - DD_BONUS.BONUS_YTD_DEPRN) YTD_DEPRN                                                         ,
       DD_BONUS.DEPRN_RESERVE                                        - DD_BONUS.BONUS_DEPRN_RESERVE DEPRN_RESERVE                                                                                                       ,
       DECODE (DH.TRANSACTION_HEADER_ID_OUT, NULL, DH.UNITS_ASSIGNED / AH.UNITS * 100) PERCENT                                                                                                                          ,
       DECODE (DH.TRANSACTION_HEADER_ID_OUT, NULL, DECODE (TH_RT.TRANSACTION_TYPE_CODE, 'FULL RETIREMENT', 'F', DECODE (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')), 'TRANSFER', 'T', 'TRANSFER OUT', 'P', 'RECLASS', 'R') T_TYPE,
       DD_BONUS.PERIOD_COUNTER                                                                                                                                                                                          ,
       ucd                                                                                                                                                                                                              ,
       ''
    FROM
       --FA_DEPRN_DETAIL         DD_BONUS,
       ( SELECT  DISTRIBUTION_ID   ,
                MAX(PERIOD_COUNTER) PERIOD_COUNTER
       FROM     FA_DEPRN_DETAIL
       WHERE    BOOK_TYPE_CODE  = book
            AND PERIOD_COUNTER <= upc
            AND ASSET_ID BETWEEN REC1.START_RANGE AND REC1.END_RANGE
       GROUP BY DISTRIBUTION_ID
       ) DD1,
       FA_DEPRN_DETAIL DD_BONUS    ,
       FA_DISTRIBUTION_HISTORY DH  ,
       FA_ASSET_HISTORY AH         ,
       FA_BOOKS BOOKS              ,
       FA_TRANSACTION_HEADERS TH_RT,
       FA_CATEGORY_BOOKS CB
   WHERE  BOOKS.BOOK_TYPE_CODE                          = book
   AND BOOKS.ASSET_ID                                = DD_BONUS.ASSET_ID --7721457
   AND NVL(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc
   AND BOOKS.DATE_EFFECTIVE                         <= ucd
   AND NVL(BOOKS.DATE_INEFFECTIVE,sysdate+1)         > ucd
   AND CB.BOOK_TYPE_CODE                             = BOOKS.BOOK_TYPE_CODE
   AND DD_BONUS.DISTRIBUTION_ID                      = DD1.DISTRIBUTION_ID --7721457
   AND DD_BONUS.PERIOD_COUNTER                       = DD1.PERIOD_COUNTER  --7721457
   AND DD_BONUS.ASSET_ID  BETWEEN REC1.START_RANGE AND REC1.END_RANGE
   AND CB.CATEGORY_ID                                = AH.CATEGORY_ID
   AND AH.ASSET_ID                                   = DD_BONUS.ASSET_ID --7721457
   AND AH.DATE_EFFECTIVE                             < ucd
   AND NVL(AH.DATE_INEFFECTIVE,sysdate)             >= ucd
   AND AH.ASSET_TYPE                                 = 'CAPITALIZED'
   AND DD_BONUS.BOOK_TYPE_CODE                       = BOOKS.BOOK_TYPE_CODE
   AND DD_BONUS.DISTRIBUTION_ID                      = DH.DISTRIBUTION_ID
   AND TH_RT.BOOK_TYPE_CODE                          = BOOKS.BOOK_TYPE_CODE
   AND TH_RT.TRANSACTION_HEADER_ID                   = BOOKS.TRANSACTION_HEADER_ID_IN
   AND DH.BOOK_TYPE_CODE                             = dist_book
   AND DH.DATE_EFFECTIVE                             <= ucd
   AND NVL(DH.DATE_INEFFECTIVE, sysdate)             > tod;

 End if;

End if;

  -- run only if CRL installed
  elsif (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y' ) then

    -- Insert Non-Group Details
   if (h_reporting_flag = 'R') then
    INSERT   INTO   FA_RESERVE_LEDGER_GT
       (
              ASSET_ID              ,
              DH_CCID               ,
              DEPRN_RESERVE_ACCT    ,
              DATE_PLACED_IN_SERVICE,
              METHOD_CODE           ,
              LIFE                  ,
              RATE                  ,
              CAPACITY              ,
              COST                  ,
              DEPRN_AMOUNT          ,
              YTD_DEPRN             ,
              DEPRN_RESERVE         ,
              PERCENT               ,
              TRANSACTION_TYPE      ,
              PERIOD_COUNTER        ,
              DATE_EFFECTIVE
       )
     SELECT /*+ ORDERED
                   Index(DD1 FA_DEPRN_DETAIL_N1)
		   Index(DD FA_DEPRN_DETAIL_U1)
		   index(DH FA_DISTRIBUTION_HISTORY_U1)
		   Index(AH FA_ASSET_HISTORY_N2)
            */
       DH.ASSET_ID ASSET_ID                                                                                                                                                                                         ,
       DH.CODE_COMBINATION_ID DH_CCID                                                                                                                                                                               ,
       CB.DEPRN_RESERVE_ACCT RSV_ACCOUNT                                                                                                                                                                            ,
       BOOKS.DATE_PLACED_IN_SERVICE START_DATE                                                                                                                                                                      ,
       BOOKS.DEPRN_METHOD_CODE METHOD                                                                                                                                                                               ,
       BOOKS.LIFE_IN_MONTHS LIFE                                                                                                                                                                                    ,
       BOOKS.ADJUSTED_RATE RATE                                                                                                                                                                                     ,
       BOOKS.PRODUCTION_CAPACITY CAPACITY                                                                                                                                                                           ,
       DD.COST COST                                                                                                                                                                                                 ,
       DECODE (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0) DEPRN_AMOUNT                                                                                                                                             ,
       DECODE (SIGN (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN) YTD_DEPRN                                                                                                                                        ,
       DD.DEPRN_RESERVE DEPRN_RESERVE                                                                                                                                                                               ,
       DECODE (TH.TRANSACTION_TYPE_CODE, NULL, DH.UNITS_ASSIGNED / AH.UNITS * 100) PERCENT                                                                                                                          ,
       DECODE (TH.TRANSACTION_TYPE_CODE, NULL, DECODE (TH_RT.TRANSACTION_TYPE_CODE, 'FULL RETIREMENT', 'F', DECODE (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')), 'TRANSFER', 'T', 'TRANSFER OUT', 'P', 'RECLASS', 'R') T_TYPE,
       DD.PERIOD_COUNTER                                                                                                                                                                                            ,
       NVL(TH.DATE_EFFECTIVE, ucd)
     FROM
       --FA_DEPRN_DETAIL_MRC_V   DD,
       ( SELECT  DISTRIBUTION_ID   ,
                MAX(PERIOD_COUNTER) PERIOD_COUNTER
       FROM     FA_DEPRN_DETAIL_MRC_V
       WHERE    BOOK_TYPE_CODE  = book
            AND PERIOD_COUNTER <= upc
            AND ASSET_ID BETWEEN REC1.START_RANGE AND REC1.END_RANGE
       GROUP BY DISTRIBUTION_ID
       )                        dd1,
       FA_DEPRN_DETAIL_MRC_V    DD ,
       FA_DISTRIBUTION_HISTORY  DH ,
       FA_ASSET_HISTORY AH         ,
       FA_BOOKS_MRC_V BOOKS        ,
       FA_TRANSACTION_HEADERS TH   ,
       FA_TRANSACTION_HEADERS TH_RT,
       FA_CATEGORY_BOOKS CB
     WHERE books.group_asset_id IS NULL
     AND CB.BOOK_TYPE_CODE                             = book
     AND CB.CATEGORY_ID                                = AH.CATEGORY_ID
     AND AH.ASSET_ID                                   = DD.ASSET_ID         --7721457
     AND DD.DISTRIBUTION_ID                            = DD1.DISTRIBUTION_ID --7721457
     AND DD.PERIOD_COUNTER                             = DD1.PERIOD_COUNTER  --7721457
     AND DD.ASSET_ID  BETWEEN REC1.START_RANGE AND REC1.END_RANGE
     AND AH.DATE_EFFECTIVE                             < NVL(TH.DATE_EFFECTIVE, ucd)
     AND NVL(AH.DATE_INEFFECTIVE,sysdate)             >= NVL(TH.DATE_EFFECTIVE, ucd)
     AND AH.ASSET_TYPE                                 = 'CAPITALIZED'
     AND DD.BOOK_TYPE_CODE                             = book
     AND DD.DISTRIBUTION_ID                            = DH.DISTRIBUTION_ID
     AND TH_RT.BOOK_TYPE_CODE                          = book
     AND TH_RT.TRANSACTION_HEADER_ID                   = BOOKS.TRANSACTION_HEADER_ID_IN
     AND BOOKS.BOOK_TYPE_CODE                          = book
     AND BOOKS.ASSET_ID                                = DD.ASSET_ID         --7721457
     AND NVL(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc
     AND BOOKS.DATE_EFFECTIVE                         <= NVL(TH.DATE_EFFECTIVE, ucd)
     AND NVL(BOOKS.DATE_INEFFECTIVE,sysdate+1)         > NVL(TH.DATE_EFFECTIVE, ucd)
     AND TH.BOOK_TYPE_CODE (+)                         = dist_book
     AND TH.TRANSACTION_HEADER_ID (+)                  = DH.TRANSACTION_HEADER_ID_OUT
     AND TH.DATE_EFFECTIVE (+) BETWEEN tod AND ucd
     AND DH.BOOK_TYPE_CODE                             = dist_book
     AND DH.DATE_EFFECTIVE                             <= ucd
     AND NVL(DH.DATE_INEFFECTIVE, sysdate) > tod     -- start cua  - exclude the group Assets
     AND books.group_asset_id IS NULL;
   else
     INSERT  INTO   FA_RESERVE_LEDGER_GT
           (
                  ASSET_ID              ,
                  DH_CCID               ,
                  DEPRN_RESERVE_ACCT    ,
                  DATE_PLACED_IN_SERVICE,
                  METHOD_CODE           ,
                  LIFE                  ,
                  RATE                  ,
                  CAPACITY              ,
                  COST                  ,
                  DEPRN_AMOUNT          ,
                  YTD_DEPRN             ,
                  DEPRN_RESERVE         ,
                  PERCENT               ,
                  TRANSACTION_TYPE      ,
                  PERIOD_COUNTER        ,
                  DATE_EFFECTIVE
           )
     SELECT
           /*+ ORDERED
	           Index(DD1 FA_DEPRN_DETAIL_N1)
		   Index(DD FA_DEPRN_DETAIL_U1)
		   index(DH FA_DISTRIBUTION_HISTORY_U1)
		   Index(AH FA_ASSET_HISTORY_N2)
	   */
           DH.ASSET_ID ASSET_ID                                                                                                                                                                                         ,
           DH.CODE_COMBINATION_ID DH_CCID                                                                                                                                                                               ,
           CB.DEPRN_RESERVE_ACCT RSV_ACCOUNT                                                                                                                                                                            ,
           BOOKS.DATE_PLACED_IN_SERVICE START_DATE                                                                                                                                                                      ,
           BOOKS.DEPRN_METHOD_CODE METHOD                                                                                                                                                                               ,
           BOOKS.LIFE_IN_MONTHS LIFE                                                                                                                                                                                    ,
           BOOKS.ADJUSTED_RATE RATE                                                                                                                                                                                     ,
           BOOKS.PRODUCTION_CAPACITY CAPACITY                                                                                                                                                                           ,
           DD.COST COST                                                                                                                                                                                                 ,
           DECODE (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0) DEPRN_AMOUNT                                                                                                                                             ,
           DECODE (SIGN (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN) YTD_DEPRN                                                                                                                                        ,
           DD.DEPRN_RESERVE DEPRN_RESERVE                                                                                                                                                                               ,
           DECODE (TH.TRANSACTION_TYPE_CODE, NULL, DH.UNITS_ASSIGNED / AH.UNITS * 100) PERCENT                                                                                                                          ,
           DECODE (TH.TRANSACTION_TYPE_CODE, NULL, DECODE (TH_RT.TRANSACTION_TYPE_CODE, 'FULL RETIREMENT', 'F', DECODE (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')), 'TRANSFER', 'T', 'TRANSFER OUT', 'P', 'RECLASS', 'R') T_TYPE,
           DD.PERIOD_COUNTER                                                                                                                                                                                            ,
           NVL(TH.DATE_EFFECTIVE, ucd)
      FROM
           --FA_DEPRN_DETAIL DD,
	   ( SELECT  DISTRIBUTION_ID   ,
                    MAX(PERIOD_COUNTER) PERIOD_COUNTER
           FROM     FA_DEPRN_DETAIL
           WHERE    BOOK_TYPE_CODE  = book
                AND PERIOD_COUNTER <= upc
                AND ASSET_ID BETWEEN REC1.START_RANGE AND REC1.END_RANGE
           GROUP BY DISTRIBUTION_ID
           ) DD1,
	   FA_DEPRN_DETAIL DD          ,
	   FA_DISTRIBUTION_HISTORY DH  ,
           FA_ASSET_HISTORY AH         ,
	   FA_BOOKS BOOKS              ,
           FA_TRANSACTION_HEADERS TH   ,
           FA_TRANSACTION_HEADERS TH_RT,
           FA_CATEGORY_BOOKS CB
      WHERE  books.group_asset_id IS NULL
       AND CB.BOOK_TYPE_CODE                             = book
       AND CB.CATEGORY_ID                                = AH.CATEGORY_ID
       AND DD.DISTRIBUTION_ID                            = DD1.DISTRIBUTION_ID --7721457
       AND DD.PERIOD_COUNTER                             = DD1.PERIOD_COUNTER  --7721457
       AND DD.ASSET_ID  BETWEEN REC1.START_RANGE AND REC1.END_RANGE
       AND AH.ASSET_ID                                   = DD.ASSET_ID         --7721457
       AND AH.DATE_EFFECTIVE                             < NVL(TH.DATE_EFFECTIVE, ucd)
       AND NVL(AH.DATE_INEFFECTIVE,sysdate)             >= NVL(TH.DATE_EFFECTIVE, ucd)
       AND AH.ASSET_TYPE                                 = 'CAPITALIZED'
       AND DD.BOOK_TYPE_CODE                             = book
       AND DD.DISTRIBUTION_ID                            = DH.DISTRIBUTION_ID
       AND TH_RT.BOOK_TYPE_CODE                          = book
       AND TH_RT.TRANSACTION_HEADER_ID                   = BOOKS.TRANSACTION_HEADER_ID_IN
       AND BOOKS.BOOK_TYPE_CODE                          = book
       AND BOOKS.ASSET_ID                                = DD.ASSET_ID         --7721457
       AND NVL(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc
       AND BOOKS.DATE_EFFECTIVE                         <= NVL(TH.DATE_EFFECTIVE, ucd)
       AND NVL(BOOKS.DATE_INEFFECTIVE,sysdate+1)         > NVL(TH.DATE_EFFECTIVE, ucd)
       AND TH.BOOK_TYPE_CODE (+)                         = dist_book
       AND TH.TRANSACTION_HEADER_ID (+)                  = DH.TRANSACTION_HEADER_ID_OUT
       AND TH.DATE_EFFECTIVE (+)               BETWEEN tod AND ucd
       AND DH.BOOK_TYPE_CODE                             = dist_book
       AND DH.DATE_EFFECTIVE                             <= ucd
       AND NVL(DH.DATE_INEFFECTIVE, sysdate)             > tod
       AND books.group_asset_id IS NULL;
    END IF;
        -- end cua


    -- Insert the Group Depreciation Details
   IF (h_reporting_flag = 'R') THEN
           INSERT INTO   FA_RESERVE_LEDGER_GT
                  (      ASSET_ID              ,
                         DH_CCID               ,
                         DEPRN_RESERVE_ACCT    ,
                         DATE_PLACED_IN_SERVICE,
                         METHOD_CODE           ,
                         LIFE                  ,
                         RATE                  ,
                         CAPACITY              ,
                         COST                  ,
                         DEPRN_AMOUNT          ,
                         YTD_DEPRN             ,
                         DEPRN_RESERVE         ,
                         PERCENT               ,
                         TRANSACTION_TYPE      ,
                         PERIOD_COUNTER        ,
                         DATE_EFFECTIVE
                  )
           SELECT GAR.GROUP_ASSET_ID ASSET_ID                                          ,
                  GAD.DEPRN_EXPENSE_ACCT_CCID CH_CCID                                  ,
                  GAD.DEPRN_RESERVE_ACCT_CCID RSV_ACCOUNT                              ,
                  GAR.DEPRN_START_DATE START_DATE                                      ,
                  GAR.DEPRN_METHOD_CODE METHOD                                         ,
                  GAR.LIFE_IN_MONTHS LIFE                                              ,
                  GAR.ADJUSTED_RATE RATE                                               ,
                  GAR.PRODUCTION_CAPACITY CAPACITY                                     ,
                  DD.ADJUSTED_COST COST                                                ,
                  DECODE (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0) DEPRN_AMOUNT     ,
                  DECODE (SIGN (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN) YTD_DEPRN,
                  DD.DEPRN_RESERVE DEPRN_RESERVE                                       ,
                  /* round (decode (TH.TRANSACTION_TYPE_CODE, null,
                  DH.UNITS_ASSIGNED / AH.UNITS * 100),2)
                  PERCENT,
                  decode (TH.TRANSACTION_TYPE_CODE, null,
                  decode (TH_RT.TRANSACTION_TYPE_CODE,
                  'FULL RETIREMENT', 'F',
                  decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                  'TRANSFER', 'T',
                  'TRANSFER OUT', 'P',
                  'RECLASS', 'R')         T_TYPE,
                  DD.PERIOD_COUNTER,
                  NVL(TH.DATE_EFFECTIVE, ucd) */
                  100 PERCENT      ,
                  'G' T_TYPE       ,
                  DD.PERIOD_COUNTER,
                  UCD
           FROM   FA_DEPRN_SUMMARY_MRC_V DD ,
                  FA_GROUP_ASSET_RULES GAR  ,
                  FA_GROUP_ASSET_DEFAULT GAD,
                  FA_DEPRN_PERIODS_MRC_V DP
           WHERE  DD.BOOK_TYPE_CODE = book
              AND DD.ASSET_ID       = GAR.GROUP_ASSET_ID
              AND DD.ASSET_ID  BETWEEN REC1.START_RANGE AND REC1.END_RANGE
              AND GAD.SUPER_GROUP_ID IS NULL -- MPOWELL
              AND GAR.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
              AND GAD.BOOK_TYPE_CODE = GAR.BOOK_TYPE_CODE
              AND GAD.GROUP_ASSET_ID = GAR.GROUP_ASSET_ID
              AND DD.PERIOD_COUNTER  =
                  (SELECT MAX (DD_SUB.PERIOD_COUNTER)
                  FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
                  WHERE   DD_SUB.BOOK_TYPE_CODE  = book
                      AND DD_SUB.ASSET_ID        = GAR.GROUP_ASSET_ID
                      AND DD_SUB.PERIOD_COUNTER <= upc
                  )
              AND DD.PERIOD_COUNTER                                              = DP.PERIOD_COUNTER
              AND DD.BOOK_TYPE_CODE                                              = DP.BOOK_TYPE_CODE
              AND GAR.DATE_EFFECTIVE                                            <= DP.CALENDAR_PERIOD_CLOSE_DATE  -- mwoodwar
              AND NVL(GAR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1)) > DP.CALENDAR_PERIOD_CLOSE_DATE; -- mwoodwar
   ELSE
           INSERT  INTO   FA_RESERVE_LEDGER_GT
                  (      ASSET_ID              ,
                         DH_CCID               ,
                         DEPRN_RESERVE_ACCT    ,
                         DATE_PLACED_IN_SERVICE,
                         METHOD_CODE           ,
                         LIFE                  ,
                         RATE                  ,
                         CAPACITY              ,
                         COST                  ,
                         DEPRN_AMOUNT          ,
                         YTD_DEPRN             ,
                         DEPRN_RESERVE         ,
                         PERCENT               ,
                         TRANSACTION_TYPE      ,
                         PERIOD_COUNTER        ,
                         DATE_EFFECTIVE
                  )
           SELECT GAR.GROUP_ASSET_ID ASSET_ID                                          ,
                  GAD.DEPRN_EXPENSE_ACCT_CCID CH_CCID                                  ,
                  GAD.DEPRN_RESERVE_ACCT_CCID RSV_ACCOUNT                              ,
                  GAR.DEPRN_START_DATE START_DATE                                      ,
                  GAR.DEPRN_METHOD_CODE METHOD                                         ,
                  GAR.LIFE_IN_MONTHS LIFE                                              ,
                  GAR.ADJUSTED_RATE RATE                                               ,
                  GAR.PRODUCTION_CAPACITY CAPACITY                                     ,
                  DD.ADJUSTED_COST COST                                                ,
                  DECODE (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0) DEPRN_AMOUNT     ,
                  DECODE (SIGN (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN) YTD_DEPRN,
                  DD.DEPRN_RESERVE DEPRN_RESERVE                                       ,
                  /* round (decode (TH.TRANSACTION_TYPE_CODE, null,
                  DH.UNITS_ASSIGNED / AH.UNITS * 100),2)
                  PERCENT,
                  decode (TH.TRANSACTION_TYPE_CODE, null,
                  decode (TH_RT.TRANSACTION_TYPE_CODE,
                  'FULL RETIREMENT', 'F',
                  decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                  'TRANSFER', 'T',
                  'TRANSFER OUT', 'P',
                  'RECLASS', 'R')         T_TYPE,
                  DD.PERIOD_COUNTER,
                  NVL(TH.DATE_EFFECTIVE, ucd) */
                  100 PERCENT      ,
                  'G' T_TYPE       ,
                  DD.PERIOD_COUNTER,
                  UCD
           FROM   FA_DEPRN_SUMMARY DD       ,
                  FA_GROUP_ASSET_RULES GAR  ,
                  FA_GROUP_ASSET_DEFAULT GAD,
                  FA_DEPRN_PERIODS DP
           WHERE  DD.BOOK_TYPE_CODE = book
              AND DD.ASSET_ID  BETWEEN REC1.START_RANGE AND REC1.END_RANGE
              AND DD.ASSET_ID       = GAR.GROUP_ASSET_ID
              AND GAD.SUPER_GROUP_ID IS NULL -- MPOWELL
              AND GAR.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
              AND GAD.BOOK_TYPE_CODE = GAR.BOOK_TYPE_CODE
              AND GAD.GROUP_ASSET_ID = GAR.GROUP_ASSET_ID
              AND DD.PERIOD_COUNTER  =
                  (SELECT MAX (DD_SUB.PERIOD_COUNTER)
                  FROM    FA_DEPRN_DETAIL DD_SUB
                  WHERE   DD_SUB.BOOK_TYPE_CODE  = book
                      AND DD_SUB.ASSET_ID        = GAR.GROUP_ASSET_ID
                      AND DD_SUB.PERIOD_COUNTER <= upc
                  )
              AND DD.PERIOD_COUNTER                                              = DP.PERIOD_COUNTER
              AND DD.BOOK_TYPE_CODE                                              = DP.BOOK_TYPE_CODE
              AND GAR.DATE_EFFECTIVE                                            <= DP.CALENDAR_PERIOD_CLOSE_DATE  -- mwoodwar
              AND NVL(GAR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1)) > DP.CALENDAR_PERIOD_CLOSE_DATE; -- mwoodwar
   END IF;

     -- Insert the SuperGroup Depreciation Details    MPOWELL

   IF (h_reporting_flag = 'R') THEN
         INSERT INTO   FA_RESERVE_LEDGER_GT
                (
                       ASSET_ID              ,
                       DH_CCID               ,
                       DEPRN_RESERVE_ACCT    ,
                       DATE_PLACED_IN_SERVICE,
                       METHOD_CODE           ,
                       LIFE                  ,
                       RATE                  ,
                       CAPACITY              ,
                       COST                  ,
                       DEPRN_AMOUNT          ,
                       YTD_DEPRN             ,
                       DEPRN_RESERVE         ,
                       PERCENT               ,
                       TRANSACTION_TYPE      ,
                       PERIOD_COUNTER        ,
                       DATE_EFFECTIVE
                )
         SELECT GAR.GROUP_ASSET_ID ASSET_ID                                          ,
                GAD.DEPRN_EXPENSE_ACCT_CCID DH_CCID                                  ,
                GAD.DEPRN_RESERVE_ACCT_CCID RSV_ACCOUNT                              ,
                GAR.DEPRN_START_DATE START_DATE                                      ,
                SGR.DEPRN_METHOD_CODE METHOD                                         , -- MPOWELL
                GAR.LIFE_IN_MONTHS LIFE                                              ,
                SGR.ADJUSTED_RATE RATE                                               , -- MPOWELL
                GAR.PRODUCTION_CAPACITY CAPACITY                                     ,
                DD.ADJUSTED_COST COST                                                ,
                DECODE (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0) DEPRN_AMOUNT     ,
                DECODE (SIGN (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN) YTD_DEPRN,
                DD.DEPRN_RESERVE DEPRN_RESERVE                                       ,
                100 PERCENT                                                          ,
                'G' T_TYPE                                                           ,
                DD.PERIOD_COUNTER                                                    ,
                UCD
         FROM   FA_DEPRN_SUMMARY_MRC_V DD ,
                fa_GROUP_ASSET_RULES GAR  ,
                fa_GROUP_ASSET_DEFAULT GAD,
                fa_SUPER_GROUP_RULES SGR  ,
                FA_DEPRN_PERIODS_MRC_V DP
         WHERE  DD.BOOK_TYPE_CODE  = book
            AND DD.ASSET_ID  BETWEEN REC1.START_RANGE AND REC1.END_RANGE
            AND DD.ASSET_ID        = GAR.GROUP_ASSET_ID
            AND GAR.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
            AND GAD.SUPER_GROUP_ID = SGR.SUPER_GROUP_ID -- MPOWELL
            AND GAD.BOOK_TYPE_CODE = SGR.BOOK_TYPE_CODE -- MPOWELL
            AND GAD.BOOK_TYPE_CODE = GAR.BOOK_TYPE_CODE
            AND GAD.GROUP_ASSET_ID = GAR.GROUP_ASSET_ID
            AND DD.PERIOD_COUNTER  =
                (SELECT MAX (DD_SUB.PERIOD_COUNTER)
                FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
                WHERE   DD_SUB.BOOK_TYPE_CODE  = book
                    AND DD_SUB.ASSET_ID        = GAR.GROUP_ASSET_ID
                    AND DD_SUB.PERIOD_COUNTER <= upc
                )
            AND DD.PERIOD_COUNTER                                              = DP.PERIOD_COUNTER
            AND DD.BOOK_TYPE_CODE                                              = DP.BOOK_TYPE_CODE
            AND GAR.DATE_EFFECTIVE                                            <= DP.CALENDAR_PERIOD_CLOSE_DATE
            AND NVL(GAR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1)) > DP.CALENDAR_PERIOD_CLOSE_DATE
            AND SGR.DATE_EFFECTIVE                                            <= DP.CALENDAR_PERIOD_CLOSE_DATE
            AND NVL(SGR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1)) > DP.CALENDAR_PERIOD_CLOSE_DATE;
    ELSE
            INSERT  INTO   FA_RESERVE_LEDGER_GT
                   (
                          ASSET_ID              ,
                          DH_CCID               ,
                          DEPRN_RESERVE_ACCT    ,
                          DATE_PLACED_IN_SERVICE,
                          METHOD_CODE           ,
                          LIFE                  ,
                          RATE                  ,
                          CAPACITY              ,
                          COST                  ,
                          DEPRN_AMOUNT          ,
                          YTD_DEPRN             ,
                          DEPRN_RESERVE         ,
                          PERCENT               ,
                          TRANSACTION_TYPE      ,
                          PERIOD_COUNTER        ,
                          DATE_EFFECTIVE
                   )
            SELECT GAR.GROUP_ASSET_ID ASSET_ID                                          ,
                   GAD.DEPRN_EXPENSE_ACCT_CCID DH_CCID                                  ,
                   GAD.DEPRN_RESERVE_ACCT_CCID RSV_ACCOUNT                              ,
                   GAR.DEPRN_START_DATE START_DATE                                      ,
                   SGR.DEPRN_METHOD_CODE METHOD                                         , -- MPOWELL
                   GAR.LIFE_IN_MONTHS LIFE                                              ,
                   SGR.ADJUSTED_RATE RATE                                               , -- MPOWELL
                   GAR.PRODUCTION_CAPACITY CAPACITY                                     ,
                   DD.ADJUSTED_COST COST                                                ,
                   DECODE (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0) DEPRN_AMOUNT     ,
                   DECODE (SIGN (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN) YTD_DEPRN,
                   DD.DEPRN_RESERVE DEPRN_RESERVE                                       ,
                   100 PERCENT                                                          ,
                   'G' T_TYPE                                                           ,
                   DD.PERIOD_COUNTER                                                    ,
                   UCD
            FROM   FA_DEPRN_SUMMARY DD       ,
                   fa_GROUP_ASSET_RULES GAR  ,
                   fa_GROUP_ASSET_DEFAULT GAD,
                   fa_SUPER_GROUP_RULES SGR  ,
                   FA_DEPRN_PERIODS DP
            WHERE  DD.BOOK_TYPE_CODE  = book
               AND DD.ASSET_ID  BETWEEN REC1.START_RANGE AND REC1.END_RANGE
               AND DD.ASSET_ID        = GAR.GROUP_ASSET_ID
               AND GAR.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
               AND GAD.SUPER_GROUP_ID = SGR.SUPER_GROUP_ID -- MPOWELL
               AND GAD.BOOK_TYPE_CODE = SGR.BOOK_TYPE_CODE -- MPOWELL
               AND GAD.BOOK_TYPE_CODE = GAR.BOOK_TYPE_CODE
               AND GAD.GROUP_ASSET_ID = GAR.GROUP_ASSET_ID
               AND DD.PERIOD_COUNTER  =
                   (SELECT MAX (DD_SUB.PERIOD_COUNTER)
                   FROM    FA_DEPRN_DETAIL DD_SUB
                   WHERE   DD_SUB.BOOK_TYPE_CODE  = book
                       AND DD_SUB.ASSET_ID        = GAR.GROUP_ASSET_ID
                       AND DD_SUB.PERIOD_COUNTER <= upc
                   )
               AND DD.PERIOD_COUNTER                                              = DP.PERIOD_COUNTER
               AND DD.BOOK_TYPE_CODE                                              = DP.BOOK_TYPE_CODE
               AND GAR.DATE_EFFECTIVE                                            <= DP.CALENDAR_PERIOD_CLOSE_DATE
               AND NVL(GAR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1)) > DP.CALENDAR_PERIOD_CLOSE_DATE
               AND SGR.DATE_EFFECTIVE                                            <= DP.CALENDAR_PERIOD_CLOSE_DATE
               AND NVL(SGR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1)) > DP.CALENDAR_PERIOD_CLOSE_DATE;

    END IF;
    END IF; --end of CRL check
  End Loop;
 commit;

exception
  when others then
    retcode := SQLCODE;
    errbuf := SQLERRM;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END RSVLDG;
END FA_RSVLDG_REP_INS_PKG;

/
