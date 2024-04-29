--------------------------------------------------------
--  DDL for Package Body FARX_BL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_BL" as
/* $Header: farxblb.pls 120.23.12010000.10 2010/03/11 13:18:07 mswetha ship $ */


-- balances_reports is Intended as private function...
-- please do not call directly.
-- Performs all report activities, given book, period range,
-- and report type as parameters.  Adj_Mode is currently not used.

-- General Overview:  Consists of two main steps:
-- 1. Insert info into temporary table FA_BALANCES_REPORT_GT:
--   A. Beginning balances for all accounts (subdivided by assets)
--   B. Ending balances
--   C. Effects of depreciation/amortization
--   D. Effects of transactional adjustments
-- 2. Select from this table in a more reportable format, insert
-- into interface table.
--
--

procedure balances_reports
   (Book                in      varchar2,
    Start_Period_Name   in      varchar2,
    End_Period_Name     in      varchar2,
    Report_Type         in      varchar2,
    Adj_Mode            in      varchar2,
    sob_id              in      varchar2 default NULL,   -- MRC
    Report_Style        in      varchar2,
    Request_id          in      number,
    user_id             in      number,
    calling_fn          in      varchar2,
    mesg         out nocopy varchar2,
    success      out nocopy boolean)

  is
    Period1_PC                  number;
    Period1_POD                 date;
    Period1_PCD                 date;
    Period2_PC                  number;
    Period2_PCD                 date;
    Distribution_Source_Book    varchar2(30);
    Balance_Type                varchar2(2);
    bal_seg                     varchar2(25);
    cost_seg                    varchar2(25);
    acct_seg                    varchar2(25);
    acct_flex_structure         number;
    acct_all_segs               fa_rx_shared_pkg.Seg_Array;
    aj_acct_all_segs            fa_rx_shared_pkg.Seg_Array;
    seg_no                      number;
    n_segs                      number;
    n_ajsegs                    number;
    gl_balancing_seg            number;
    gl_account_seg              number;
    fa_cost_ctr_seg             number;

    h_concat_key                varchar2(500);
    h_concat_cat                varchar2(500);


    h_login_id                  number;
    h_request_id                number;

    h_ccid                      number;
    h_account                   FA_BALANCES_REPORT_GT.Category_Books_Account%TYPE; --bug 8432604
    h_ajccid                    number;
    h_asset                     FA_ADDITIONS.Asset_Number%TYPE; --bug 8432604
    h_tag_number                FA_ADDITIONS.tag_number%TYPE; --bug 8432604
    h_serial_number             FA_ADDITIONS.serial_number%TYPE; --bug 8432604
    h_inventorial               FA_ADDITIONS.inventorial%TYPE; --bug 8432604
    h_description               FA_ADDITIONS.description%TYPE; --bug 8432604
    h_begin                     number;
    h_end                       number;
    h_addition                  number;
    h_adjustment                number;
    h_reclass                   number;
    h_retirement                number;
    h_revaluation               number;
    h_transfer                  number;
    h_depreciation              number;
    h_capitalization            number;
    h_tax                       number;
    h_out_of_bal_flag           varchar2(1);

    h_ccid_error                number;
    h_br_ajccid                 number;
    h_br_account                varchar2(15);
    h_br_rowid                  rowid;

    h_nonqual_col_name          varchar2(30);
    h_nonqual_seg_name          varchar2(30);
    h_nonqual_seg_num           varchar2(30);

    h_nq_col_names      fa_rx_shared_pkg.Seg_Array;
    h_nq_seg_names      fa_rx_shared_pkg.Seg_Array;
    h_nq_seg_nums       fa_rx_shared_pkg.Seg_Array;
    h_ctr  number;

    get_segments_success        boolean;

    get_segments_failure        exception;


    h_mesg_name         varchar2(50);
    h_mesg_str          varchar2(2000);
    h_table_token       varchar2(30);
    h_flex_error        varchar2(30);

    -- Additional variables added for globalization -- statutory reporting requirements

    h_key_flex_struct           number;         /* StatReq */
    h_cat_flex_struct           number;         /* StatReq */

    h_asset_key_ccid            number;
    h_category_id               number;         /* StatReq */

    h_key_segs                  fa_rx_shared_pkg.Seg_Array; /* StatReq */
    h_cat_segs                  fa_rx_shared_pkg.Seg_Array; /* StatReq */

    h_asset_id                  FA_ADDITIONS.asset_id%TYPE;             /* StatReq */
    h_stl_depreciation_rate     NUMBER;         /* StatReq */
    h_date_placed_in_service    DATE;           /* StatReq */
    h_life_in_months            NUMBER;         /* StatReq */
    h_account_description       VARCHAR2(500);  /* StatReq */

    h_short_account_description VARCHAR2(240);
    h_short_location            VARCHAR2(500);
    h_shortconcat_key           VARCHAR2(240);
    h_stl_method_flag           FA_METHODS.stl_method_flag%TYPE; --bug8432604           /* StatReq */
    h_rate_source_rule          FA_METHODS.rate_source_rule%TYPE; --bug8432604          /* StatReq */

    h_method_code               FA_METHODS.method_code%TYPE; --bug8432604               /* StatReq */

    h_Cost_Account              FA_BALANCES_REPORT_GT.Cost_Account%TYPE; --bug8432604           /* StatReq */
    h_Cost_Begin_Balance        NUMBER;         /* StatReq */
    h_location                  VARCHAR2(1500); /* StatReq */

    -- bug 5944006 (Increased length to 1500 from 500 for following variables)
    h_invoice_number            VARCHAR2(1500); /* StatReq */
    h_invoice_descr             VARCHAR2(1500); /* StatReq */
    h_vendor_name               VARCHAR2(1500); /* StatReq */
    h_retirement_type           VARCHAR2(1500); /* StatReq */
    -- End of changes for bug 5944006

    -- Added for bug 5944006
    h_short_invoice_number      VARCHAR2(500);
    h_short_invoice_descr       VARCHAR2(500);
    h_short_vendor_name         VARCHAR2(500);
    h_short_retirement_type     VARCHAR2(500);
    -- End of changes for bug 5944006

    return_status               BOOLEAN;        /* StatReq */
    acct_appl_col               VARCHAR2(240);  /* StatReq */
    acct_segname                VARCHAR2(240);  /* StatReq */
    acct_prompt                 VARCHAR2(240);  /* StatReq */
    acct_valueset_name          VARCHAR2(240);  /* StatReq */

  -- Additional variables for Drill Down Report
    h_group_asset               FA_LOOKUPS.MEANING%TYPE; --bug8432604 -- Group Asset_number

   -- MRC
   h_sob_id                     NUMBER;
   h_mrcsobtype                 VARCHAR2(1);
   -- End MRC

  -- Used in finding account segments for FA_BALANCES_REPORT_GT

  CURSOR BAL_REPORT_AJCCID IS
    SELECT DISTINCT ADJUSTMENT_CCID, CATEGORY_BOOKS_ACCOUNT, ROWID
        FROM FA_BALANCES_REPORT_GT;

  -- Main selector from FA_BALANCES_REPORT_GT for asset cost
  -- and CIP cost reports.

  CURSOR COST_REPORT (c_book VARCHAR2, c_to_date DATE, c_from_date DATE) IS             /* StatReq */
    SELECT DISTINCT
        ad.asset_id,                                                    /* StatReq */
        DHCC.CODE_COMBINATION_ID,
        BAL.Category_Books_Account,
        BAL.Cost_Account,                                               /* StatReq */
        AD.Asset_Number,
        AD.tag_number,
        AD.description,
        ad.serial_number, ad.inventorial, ad.asset_key_ccid,            /* StatReq */
        ah.category_id,                                                 /* StatReq */
        b.date_placed_in_service,                                       /* StatReq */
        m.method_code,                                                  /* StatReq */
        b.life_in_months,                                               /* StatReq */
        m.stl_method_flag,                                              /* StatReq */
        m.rate_source_rule,                                             /* StatReq */
        NVL(SUM(DECODE(BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Cost_Begin_Balance, 0), NULL)), 0),    /* StatReq */
        NVL(SUM (DECODE (BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Amount,0), NULL)), 0),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE,'COST','ADDITION', 'CIP ADDITION'),
                NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE, 'CIP COST', 'ADDITION'),
                -NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE,'COST','ADJUSTMENT','CIP ADJUSTMENT'),
                 NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'RECLASS', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE,'COST','RETIREMENT','CIP RETIREMENT'),
                 -NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'REVALUATION', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'TRANSFER', NVL(BAL.Amount,0), NULL)),
        NVL(SUM (DECODE (BAL.Source_Type_Code,
                'END', NVL(BAL.Amount,0), NULL)), 0)  /*Bug# 9293000 */
    FROM
        FA_ASSET_HISTORY AH,                                            /* StatReq */
        fa_category_books cb,
        FA_METHODS M,                                                   /* StatReq */
        FA_BOOKS B,                                                     /* StatReq */
        FA_BALANCES_REPORT_GT BAL,
        FA_ADDITIONS AD,
        GL_CODE_COMBINATIONS DHCC,
        GL_CODE_COMBINATIONS AJCC,
        FA_ADDITIONS AD1,
        FA_LOOKUPS LU
    WHERE       AD.Asset_ID             =       BAL.Asset_ID
    AND DHCC.Code_Combination_ID        =       BAL.Distribution_CCID
    AND AJCC.Code_Combination_ID (+)    =       BAL.Adjustment_CCID
    AND B.ASSET_ID                      =       AD.ASSET_ID
    AND B.Book_Type_Code                =       c_book
    AND B.Date_Ineffective              is      NULL
    AND B.Transaction_Header_Id_Out     is      NULL
    AND nvl(M.LIFE_IN_MONTHS, -9)       =       nvl(B.LIFE_IN_MONTHS, -9)
    AND M.METHOD_CODE                   =       B.DEPRN_METHOD_CODE
    AND AH.ASSET_ID                     =       AD.ASSET_ID
    /* Commented for bug #5015612. It was cousing No data found in Rxi: Asset Cost Balance Reprort.
    -- Added for bug#4860955
    and ah.transaction_header_id_in = ( select min(ah1.transaction_header_id_in)
                                        from fa_asset_history ah1
                                        where ah1.asset_id=ah.asset_id
                                        and ah1.category_id=ah.category_id
                                        and ah1.asset_type='CIP') */
    and ah.category_id = cb.category_id
    and cb.book_type_code = c_book
    and decode(ah.asset_type,'CIP',cb.cip_cost_acct, cb.asset_cost_acct) = BAL.Category_Books_Account
-- Added for bug#4860955
    and nvl(ah.date_effective,c_to_date) <= c_to_date
-- Added for bug #5015612
--bug 6668625
-- Bug#9384471 Modified for displaying correct category after reclass
    and ah.transaction_header_id_in = ( select max(ah1.transaction_header_id_in)
                                        from fa_asset_history ah1,
                                             fa_category_books cb1
                                        where ah1.asset_id=ah.asset_id
                                        -- and ah1.category_id=ah.category_id  Bug#9384471
                                        and ah1.asset_type=decode(report_type,'CIP COST','CIP',
                                                                              'COST','CAPITALIZED',ah1.asset_type)
                                        and cb1.book_type_code=c_book
                                        and cb1.category_id=ah1.category_id
                                        and decode(report_type,'CIP COST',cb1.cip_cost_acct,cb1.asset_cost_acct)
                                                     = decode(report_type,'CIP COST',cb.cip_cost_acct,cb.asset_cost_acct)
                                        and nvl(ah1.date_effective,c_to_date) <= c_to_date )

-- Commented for bug#4860955
--  AND c_to_date between ah.date_effective and nvl(ah.date_ineffective, c_to_date)
    AND AD1.Asset_ID(+)                 = nvl(BAL.Group_Asset_ID,-99) -- Added for Drill Down Report
    AND LU.Lookup_Type (+)              = 'ASSET TYPE'
    AND LU.Lookup_Code (+)              = AD.Asset_Type
    GROUP BY
        ad.asset_id,
        dhcc.code_combination_id,
        BAL.Category_Books_Account,
        BAL.Cost_Account,
        AD.ASSET_NUMBER,
        AD.tag_number,
        AD.description,
        ad.serial_number, ad.inventorial, ad.asset_key_ccid,
        ah.category_id,
        b.date_placed_in_service,
        m.method_code,
        b.life_in_months,
        m.stl_method_flag,
        m.rate_source_rule;

  -- MRC
  CURSOR MC_COST_REPORT (c_book VARCHAR2, c_to_date DATE, c_from_date DATE) IS             /* StatReq */
    SELECT DISTINCT
        ad.asset_id,                                                    /* StatReq */
        DHCC.CODE_COMBINATION_ID,
        BAL.Category_Books_Account,
        BAL.Cost_Account,                                               /* StatReq */
        AD.Asset_Number,
        AD.tag_number,
        AD.description,
        ad.serial_number, ad.inventorial, ad.asset_key_ccid,            /* StatReq */
        ah.category_id,                                                 /* StatReq */
        b.date_placed_in_service,                                       /* StatReq */
        m.method_code,                                                  /* StatReq */
        b.life_in_months,                                               /* StatReq */
        m.stl_method_flag,                                              /* StatReq */
        m.rate_source_rule,                                             /* StatReq */
        NVL(SUM(DECODE(BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Cost_Begin_Balance, 0), NULL)), 0),    /* StatReq */
        NVL(SUM (DECODE (BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Amount,0), NULL)), 0),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE,'COST','ADDITION', 'CIP ADDITION'),
                NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE, 'CIP COST', 'ADDITION'),
                -NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE,'COST','ADJUSTMENT','CIP ADJUSTMENT'),
                 NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'RECLASS', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE,'COST','RETIREMENT','CIP RETIREMENT'),
                 -NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'REVALUATION', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'TRANSFER', NVL(BAL.Amount,0), NULL)),
        NVL(SUM (DECODE (BAL.Source_Type_Code,
                'END', NVL(BAL.Amount,0), NULL)), 0)  /*Bug# 9293000 */
    FROM
        FA_ASSET_HISTORY AH,                                            /* StatReq */
        fa_category_books cb,
        FA_METHODS M,                                                   /* StatReq */
        FA_MC_BOOKS B,                                                     /* StatReq */
        FA_BALANCES_REPORT_GT BAL,
        FA_ADDITIONS AD,
        GL_CODE_COMBINATIONS DHCC,
        GL_CODE_COMBINATIONS AJCC,
        FA_ADDITIONS AD1,
        FA_LOOKUPS LU
    WHERE       AD.Asset_ID             =       BAL.Asset_ID
    AND DHCC.Code_Combination_ID        =       BAL.Distribution_CCID
    AND AJCC.Code_Combination_ID (+)    =       BAL.Adjustment_CCID
    AND B.ASSET_ID                      =       AD.ASSET_ID
    AND B.Book_Type_Code                =       c_book
    AND B.Date_Ineffective              is      NULL
    AND B.Transaction_Header_Id_Out     is      NULL
    AND nvl(M.LIFE_IN_MONTHS, -9)       =       nvl(B.LIFE_IN_MONTHS, -9)
    AND M.METHOD_CODE                   =       B.DEPRN_METHOD_CODE
    AND AH.ASSET_ID                     =       AD.ASSET_ID
    /* Commented for bug #5015612. It was cousing No data found in Rxi: Asset Cost Balance Reprort.
    -- Added for bug#4860955
    and ah.transaction_header_id_in = ( select min(ah1.transaction_header_id_in)
                                        from fa_asset_history ah1
                                        where ah1.asset_id=ah.asset_id
                                        and ah1.category_id=ah.category_id
                                        and ah1.asset_type='CIP') */
    and ah.category_id = cb.category_id
    and cb.book_type_code = c_book
    and decode(ah.asset_type,'CIP',cb.cip_cost_acct, cb.asset_cost_acct) = BAL.Category_Books_Account
    -- Added for bug#4860955
    and nvl(ah.date_effective,c_to_date) <= c_to_date
    -- Added for bug #5015612
    --bug 6668625
    and ah.transaction_header_id_in = ( select max(ah1.transaction_header_id_in)
                                        from fa_asset_history ah1,
                                             fa_category_books cb1
                                        where ah1.asset_id=ah.asset_id
                                        -- and ah1.category_id=ah.category_id   Bug#9384471
                                        and ah1.asset_type=decode(report_type,'CIP COST','CIP',
                                                                              'COST','CAPITALIZED',ah1.asset_type)
                                        and cb1.book_type_code=c_book
                                        and cb1.category_id=ah1.category_id
                                        and decode(report_type,'CIP COST',cb1.cip_cost_acct,cb1.asset_cost_acct)
                                                     = decode(report_type,'CIP COST',cb.cip_cost_acct,cb.asset_cost_acct)
                                        and nvl(ah1.date_effective,c_to_date) <= c_to_date )

    -- Commented for bug#4860955
    --  AND c_to_date between ah.date_effective and nvl(ah.date_ineffective, c_to_date)
    AND AD1.Asset_ID(+)                 = nvl(BAL.Group_Asset_ID,-99) -- Added for Drill Down Report
    AND LU.Lookup_Type (+)              = 'ASSET TYPE'
    AND LU.Lookup_Code (+)              = AD.Asset_Type
    AND B.set_of_books_id               = h_sob_id
    GROUP BY
        ad.asset_id,
        dhcc.code_combination_id,
        BAL.Category_Books_Account,
        BAL.Cost_Account,
        AD.ASSET_NUMBER,
        AD.tag_number,
        AD.description,
        ad.serial_number, ad.inventorial, ad.asset_key_ccid,
        ah.category_id,
        b.date_placed_in_service,
        m.method_code,
        b.life_in_months,
        m.stl_method_flag,
        m.rate_source_rule;
  -- End MRC

  -- Main selector from FA_BALANCES_REPORT_GT for accum deprn
  -- and reval reserve reports.


   CURSOR RESERVE_REPORT (c_book VARCHAR2, c_to_date DATE) IS           /* StatReq */
     SELECT DISTINCT
        ad.asset_id,                                                    /* StatReq */
        DHCC.CODE_COMBINATION_ID,
        BAL.Category_Books_Account,
        BAL.Cost_Account,                                               /* StatReq */
        AD.Asset_Number,
        AD.tag_number,
        AD.description,
        ad.serial_number, ad.inventorial, ad.asset_key_ccid,
        ah.category_id,                                                 /* StatReq */
        b.date_placed_in_service,                                       /* StatReq */
        m.method_code,                                                  /* StatReq */
        b.life_in_months,                                               /* StatReq */
        m.stl_method_flag,                                              /* StatReq */
        m.rate_source_rule,                                             /* StatReq */
        NVL(SUM(DECODE(BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Cost_Begin_Balance, 0), NULL)), 0),    /* StatReq */
        SUM (DECODE (BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'ADDITION', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'ADJUSTMENT', NVL(BAL.Amount,0), NULL)), /*9293000 */
        SUM (DECODE (BAL.Source_Type_Code,
                'DEPRECIATION', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'RECLASS', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'RETIREMENT', -NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'REVALUATION', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'TAX', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'TRANSFER', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'END', NVL(BAL.Amount,0), NULL))  /*Bug# 9293000 */
    FROM
        FA_ASSET_HISTORY AH,                                            /* StatReq */
        FA_METHODS M,                                                   /* StatReq */
        FA_BOOKS B,                                                     /* StatReq */
        FA_BALANCES_REPORT_GT BAL,
        FA_ADDITIONS AD,
        GL_CODE_COMBINATIONS DHCC,
        GL_CODE_COMBINATIONS AJCC,
        FA_ADDITIONS AD1,  -- This is only used to get Group Asset Number
        FA_LOOKUPS LU
    WHERE       AD.Asset_ID     = BAL.Asset_ID
    AND DHCC.Code_Combination_ID        = BAL.Distribution_CCID
    AND AJCC.Code_Combination_ID (+)    = BAL.Adjustment_CCID
    AND B.Book_Type_Code                =       c_book                  /* StatReq */
    AND B.ASSET_ID                      =       AD.ASSET_ID             /* StatReq */
    AND B.Date_Ineffective              is      NULL                    /* StatReq */
    AND B.Transaction_Header_Id_Out     is      NULL                    /* StatReq */
    AND nvl(M.LIFE_IN_MONTHS, -9)       =       nvl(B.LIFE_IN_MONTHS, -9) /* StatReq */
    AND M.METHOD_CODE                   =       B.DEPRN_METHOD_CODE     /* StatReq */
    AND AH.ASSET_ID                     =       AD.ASSET_ID             /* StatReq */
    AND AH.DATE_EFFECTIVE               <=      c_to_date               /* StatReq */
    AND NVL(AH.DATE_INEFFECTIVE, SYSDATE + 1) > c_to_date               /* StatReq */
    AND AD1.Asset_ID(+)                 = nvl(BAL.Group_Asset_ID,-99)
    AND LU.Lookup_Type (+)              = 'ASSET TYPE'
    AND LU.Lookup_Code (+)              = AD.Asset_Type
    GROUP BY
        ad.asset_id,                                                    /* StatReq */
        DHCC.CODE_COMBINATION_ID,
        BAL.Category_Books_Account,
        BAL.Cost_Account,                                               /* StatReq */
        AD.ASSET_NUMBER,
        AD.TAG_NUMBER,
        AD.DESCRIPTION, ad.serial_number, ad.inventorial, ad.asset_key_ccid,
        ah.category_id,                                                 /* StatReq */
        b.date_placed_in_service,                                       /* StatReq */
        m.method_code,                                                  /* StatReq */
        b.life_in_months,                                               /* StatReq */
        m.stl_method_flag,                                              /* StatReq */
        m.rate_source_rule;                                             /* StatReq */

   -- MRC
   CURSOR MC_RESERVE_REPORT (c_book VARCHAR2, c_to_date DATE) IS           /* StatReq */
     SELECT DISTINCT
        ad.asset_id,                                                    /* StatReq */
        DHCC.CODE_COMBINATION_ID,
        BAL.Category_Books_Account,
        BAL.Cost_Account,                                               /* StatReq */
        AD.Asset_Number,
        AD.tag_number,
        AD.description,
        ad.serial_number, ad.inventorial, ad.asset_key_ccid,
        ah.category_id,                                                 /* StatReq */
        b.date_placed_in_service,                                       /* StatReq */
        m.method_code,                                                  /* StatReq */
        b.life_in_months,                                               /* StatReq */
        m.stl_method_flag,                                              /* StatReq */
        m.rate_source_rule,                                             /* StatReq */
        NVL(SUM(DECODE(BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Cost_Begin_Balance, 0), NULL)), 0),    /* StatReq */
        SUM (DECODE (BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'ADDITION', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'ADJUSTMENT', NVL(BAL.Amount,0), NULL)), /*9293000 */
        SUM (DECODE (BAL.Source_Type_Code,
                'DEPRECIATION', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'RECLASS', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'RETIREMENT', -NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'REVALUATION', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'TAX', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'TRANSFER', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'END', NVL(BAL.Amount,0), NULL))/*Bug# 9293000 */
    FROM
        FA_ASSET_HISTORY AH,                                            /* StatReq */
        FA_METHODS M,                                                   /* StatReq */
        FA_MC_BOOKS B,                                                     /* StatReq */
        FA_BALANCES_REPORT_GT BAL,
        FA_ADDITIONS AD,
        GL_CODE_COMBINATIONS DHCC,
        GL_CODE_COMBINATIONS AJCC,
        FA_ADDITIONS AD1,  -- This is only used to get Group Asset Number
        FA_LOOKUPS LU
    WHERE       AD.Asset_ID     = BAL.Asset_ID
    AND DHCC.Code_Combination_ID        = BAL.Distribution_CCID
    AND AJCC.Code_Combination_ID (+)    = BAL.Adjustment_CCID
    AND B.Book_Type_Code                =       c_book                  /* StatReq */
    AND B.ASSET_ID                      =       AD.ASSET_ID             /* StatReq */
    AND B.Date_Ineffective              is      NULL                    /* StatReq */
    AND B.Transaction_Header_Id_Out     is      NULL                    /* StatReq */
    AND nvl(M.LIFE_IN_MONTHS, -9)       =       nvl(B.LIFE_IN_MONTHS, -9) /* StatReq */
    AND M.METHOD_CODE                   =       B.DEPRN_METHOD_CODE     /* StatReq */
    AND AH.ASSET_ID                     =       AD.ASSET_ID             /* StatReq */
    AND AH.DATE_EFFECTIVE               <=      c_to_date               /* StatReq */
    AND NVL(AH.DATE_INEFFECTIVE, SYSDATE + 1) > c_to_date               /* StatReq */
    AND AD1.Asset_ID(+)                 = nvl(BAL.Group_Asset_ID,-99)
    AND LU.Lookup_Type (+)              = 'ASSET TYPE'
    AND LU.Lookup_Code (+)              = AD.Asset_Type
    AND B.set_of_books_id               = h_sob_id
    GROUP BY
        ad.asset_id,                                                    /* StatReq */
        DHCC.CODE_COMBINATION_ID,
        BAL.Category_Books_Account,
        BAL.Cost_Account,                                               /* StatReq */
        AD.ASSET_NUMBER,
        AD.TAG_NUMBER,
        AD.DESCRIPTION, ad.serial_number, ad.inventorial, ad.asset_key_ccid,
        ah.category_id,                                                 /* StatReq */
        b.date_placed_in_service,                                       /* StatReq */
        m.method_code,                                                  /* StatReq */
        b.life_in_months,                                               /* StatReq */
        m.stl_method_flag,                                              /* StatReq */
        m.rate_source_rule;                                             /* StatReq */
   -- End MRC

  CURSOR PERIOD_INFO IS
    SELECT      P1.Period_Counter,
                P1.Period_Open_Date,
                P1.Period_Close_Date,
                P2.Period_Counter,
                NVL(P2.Period_Close_Date, SYSDATE),
                BC.Distribution_Source_Book,
                BC.Accounting_Flex_Structure
    FROM        FA_DEPRN_PERIODS P1,
                FA_DEPRN_PERIODS P2,
                FA_BOOK_CONTROLS BC
    WHERE       BC.Book_Type_Code       = Book
    AND         P1.Book_Type_Code       = Book                  AND
                P1.Period_Name          = Start_Period_Name
    AND         P2.Book_Type_Code       = Book                  AND
                P2.Period_Name          = End_Period_Name;

    -- Cursor for Drill Down Report
    CURSOR GROUP_ASSETS IS
      SELECT DISTINCT BAL.Group_Asset_ID Group_Asset_ID
        FROM FA_BALANCES_REPORT_GT BAL
       WHERE BAL.Asset_ID = BAL.Group_Asset_ID;

    CURSOR GROUP_RESERVE_AMOUNTS (p_group_asset_id number) is
      SELECT
        NVL(SUM(DECODE(BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Cost_Begin_Balance, 0), NULL)), 0)     /* StatReq */
      FROM  FA_BALANCES_REPORT_GT  BAL
      WHERE BAL.Group_Asset_id = p_group_asset_id
        AND BAL.Group_Asset_id <> BAL.Asset_id;

    CURSOR GROUP_COST_AMOUNTS (p_group_asset_id number) is
      SELECT
        NVL(SUM(DECODE(BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Cost_Begin_Balance, 0), NULL)), 0),
        NVL(SUM (DECODE (BAL.Source_Type_Code,
                'BEGIN', NVL(BAL.Amount,0), NULL)), 0),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE,'COST','ADDITION', 'CIP ADDITION'),
                NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE, 'CIP COST', 'ADDITION'),
                -NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE,'COST','ADJUSTMENT','CIP ADJUSTMENT'),
                 NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'RECLASS', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                DECODE(REPORT_TYPE,'COST','RETIREMENT','CIP RETIREMENT'),
                 -NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'REVALUATION', NVL(BAL.Amount,0), NULL)),
        SUM (DECODE (BAL.Source_Type_Code,
                'TRANSFER', NVL(BAL.Amount,0), NULL)),
        NVL(SUM (DECODE (BAL.Source_Type_Code,
                'END', NVL(BAL.Amount,0), NULL)), 0)
      FROM  FA_BALANCES_REPORT_GT  BAL
      WHERE BAL.Group_Asset_id = p_group_asset_id
        AND BAL.Group_Asset_id <> BAL.Asset_id;

--  cursor non_qualified_segs is
--        SELECT s.application_column_name,
--               s.segment_name,
--              s.segment_num
--          FROM fnd_id_flex_segments_vl s
--         WHERE s.application_id = 101
--           AND s.id_flex_code = 'GL#'
--           AND s.id_flex_num  = Acct_Flex_STructure
--           AND s.enabled_flag = 'Y'
--      and 1 = (select count(*)
--      from fnd_segment_attribute_values
--      where application_id = s.application_id
--      and id_flex_code = s.id_flex_code
--      and id_flex_num = s.id_flex_num and attribute_value = 'Y'
--      and application_column_name = s.application_column_name);


  begin

    h_sob_id := to_number(sob_id);  -- MRC

fa_debug_pkg.add('farxblb','report_style in main (1)', Report_Style);

--    acct_all_segs(1) := '';
--    acct_all_segs(2) := '';
--    acct_all_segs(3) := '';
--    acct_all_segs(4) := '';
--    acct_all_segs(5) := '';
--    acct_all_segs(6) := '';
--    acct_all_segs(7) := '';
    --  acct_all_segs(8) := '';
    --  acct_all_segs(9) := '';
    --  acct_all_segs(10) := '';
    --  acct_all_segs(11) := '';
    --  acct_all_segs(12) := '';
    --  acct_all_segs(13) := '';
    --  acct_all_segs(14) := '';
    --  acct_all_segs(15) := '';
    --  acct_all_segs(16) := '';
    --  acct_all_segs(17) := '';
    --  acct_all_segs(18) := '';
    --  acct_all_segs(19) := '';
    --  acct_all_segs(20) := '';
    --  acct_all_segs(21) := '';
    --  acct_all_segs(22) := '';
    --  acct_all_segs(23) := '';
    --  acct_all_segs(24) := '';
    --  acct_all_segs(25) := '';
    --  acct_all_segs(26) := '';
    --  acct_all_segs(27) := '';
    --  acct_all_segs(28) := '';
    --  acct_all_segs(29) := '';
    --  acct_all_segs(30) := '';



    success := FALSE;

    h_request_id := request_id;


    fnd_profile.get('LOGIN_ID',h_login_id);

    -- MRC
    if h_sob_id is not null then
       begin
          select 'P'
          into h_mrcsobtype
          from fa_book_controls
          where book_type_code = book
          and set_of_books_id = h_sob_id;
       exception
          when no_data_found then
             h_mrcsobtype := 'R';
       end;
    else
       h_mrcsobtype := 'P';
    end if;
    -- End MRC


  -- Select dates corresponding to given period range.
  -- Error out if periods given in range do not exist.
  -- Also get structure_id

  h_mesg_name := 'FA_AMT_SEL_PERIODS';

   OPEN PERIOD_INFO;
   FETCH PERIOD_INFO INTO
        Period1_PC,
        Period1_POD,
        Period1_PCD,
        Period2_PC,
        Period2_PCD,
        Distribution_Source_Book,
        Acct_Flex_Structure;

   if (PERIOD_INFO%NOTFOUND) then
        h_mesg_name := 'FA_SHARED_SEL_DEPRN_PERIODS';
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        CLOSE PERIOD_INFO;
        return;
   end if;
   CLOSE PERIOD_INFO;

    if (Report_Type = 'RESERVE' or Report_Type = 'REVAL RESERVE') then
        Balance_Type := 'CR';
    else
        Balance_Type := 'DR';
    end if;

    h_mesg_name := 'FA_SHARED_DELETE_FAILED';
    h_table_token := 'FA_BALANCES_REPORT_GT';

    -- no longer needed with GT
    -- DELETE FROM FA_BALANCES_REPORT_GT;

    h_table_token := 'FA_LOOKUPS';

-- bug 1068054

    Delete from fa_lookups_b
    where lookup_type = 'REPORT TYPE';


    Delete from fa_lookups_tl
    where lookup_type = 'REPORT TYPE';


    h_mesg_name := 'FA_SHARED_INSERT_FAILED';
-- bug 1068054

    INSERT INTO FA_LOOKUPS_B
        (lookup_type,
         lookup_code,
         last_updated_by,
         last_update_date,
         enabled_flag)
     VALUES
        ('REPORT TYPE',
         Report_Type,
         1,
         SYSDATE,
         'Y');

    insert into FA_LOOKUPS_TL (
        LOOKUP_TYPE,
        LOOKUP_CODE,
        MEANING,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LANGUAGE,
        SOURCE_LANG)
        Select 'REPORT TYPE',
                Report_Type,
                Report_Type,
                SYSDATE,
                1,
            L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FA_LOOKUPS_TL T
    where T.LOOKUP_TYPE = 'REPORT TYPE'
    and T.LOOKUP_CODE = Report_Type
    and T.LANGUAGE = L.LANGUAGE_CODE);



     /* StatReq - Added category flex structure to the following
                  SQL Statement */
        select
                category_flex_structure,
                asset_key_flex_structure
        into
                h_cat_flex_struct,
                h_key_flex_struct
        from
                fa_system_controls;


    /* Get Beginning Balance */
    /* Use Period1_PC-1, to get balance as of end of period immediately
       preceding Period1_PC */
--    Get_Balance (Book, Distribution_Source_Book,
--               Period1_PC-1, Period1_POD,
--               Report_Type, Balance_Type,
--               'BEGIN');

  h_mesg_name := 'FA_RX_BEGIN_BALANCES';

  if(h_mrcsobtype <> 'R') then  -- MRC
     INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Group_Asset_ID, -- Added for Member Track
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Cost_Account,
        Source_Type_Code,
        Amount,
        Cost_Begin_Balance)
     SELECT
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID),
        DH.Code_Combination_ID,
        null,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', 'BEGIN', 'T', 'BEGIN', 'ADDITION'), -- Added 'T'
                'REVAL RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', 'BEGIN', 'T', 'BEGIN', 'ADDITION'), -- Added 'T'
                'BEGIN'),
        DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve),
        DD.COST
     FROM
        FA_CATEGORY_BOOKS       CB,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_DEPRN_DETAIL         DD,
        FA_BOOKS                BK  -- Added for Member Track
     WHERE       DH.Book_Type_Code       = Distribution_Source_Book
     AND DD.Asset_ID             = AH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= Period1_Pc - 1               AND
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_DEPRN_DETAIL SUB_DD
        WHERE   SUB_DD.Asset_ID         = DH.Asset_ID           AND
                SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                SUB_DD.Period_Counter   <= Period1_Pc - 1)
     AND (( DD.Deprn_Source_Code <> 'T' AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE') /*Bug# 9293000 */
     AND (( 0 = (select count(1)
                from fa_deprn_detail dd1
                where dd1.asset_id = DD.Asset_ID
                AND   dd1.Deprn_Source_Code = 'T'
                AND   dd1.book_type_code = Book
                AND   dd1.Period_Counter = DD.Period_Counter
                AND   dd1.distribution_id > dd.distribution_id) AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE')
     AND AH.Asset_ID             = DH.Asset_ID                  AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type         in ('CAPITALIZED', 'GROUP')  AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')) OR
         (AH.Asset_Type         <> 'EXPENSED' AND nvl(Report_Style,'S') = 'D'))
     AND ((Period1_Pod BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, Period1_Pod) AND
                DD.Deprn_Source_Code = 'D')     OR
         (DD.Deprn_Run_Date BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, DD.Deprn_Run_Date) AND
                DD.Deprn_Source_Code = 'B')     OR
         (Period1_Pod BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, Period1_Pod) AND
     --         DD.Deprn_Source_Code = 'T' AND
                nvl(Report_Style,'S')= decode(substr(report_type,-4),'COST', nvl(Report_Style,'S'),'D'))) /*Bug# 9293000 */
     AND CB.Category_ID          = AH.Category_ID
     AND CB.Book_Type_Code       = Book
     AND DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                DECODE(Report_Style,'D',DECODE(AH.Asset_Type,'GROUP',CB.Asset_Cost_Acct,null),
                                null)), -- Added for second decode for drill down report
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
     AND BK.Book_Type_Code       = CB.book_type_code
     AND   BK.Asset_ID             = DD.Asset_ID   AND
        DECODE(DD.Deprn_Source_Code, 'D', Period1_pod,
                        nvl(Period1_pcd,Period1_pod)) BETWEEN /*Bug# 9293000 */
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, sysdate) AND
        NVL(BK.Period_Counter_Fully_Retired, Period1_PC)
                > period1_pc - 1
     UNION ALL-- Added to get assets added with reserve when multiple periods intervall bug  3756517
        SELECT
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID),
        DH.Code_Combination_ID,
        null,
        DECODE (Report_Type,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', 'BEGIN', 'T', 'BEGIN', 'ADDITION'), -- Added 'T'
                'REVAL RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', 'BEGIN', 'T', 'BEGIN', 'ADDITION'), -- Added 'T'
                'BEGIN'),
        DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve),
        DD.COST
     FROM
        FA_CATEGORY_BOOKS       CB,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_DEPRN_DETAIL         DD,
        FA_BOOKS                BK,
        FA_DEPRN_PERIODS        DP_BROW
     WHERE       DH.Book_Type_Code       = distribution_source_book
     AND DD.Asset_ID            = AH.Asset_ID           AND
        DD.Book_Type_Code       = book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        dd.deprn_reserve <> 0                           AND
        dd.deprn_source_code = 'B'                      AND
        DD.Period_Counter       between period1_pc and period2_pc
     AND AH.Asset_ID            = DH.Asset_ID                   AND
        (       (AH.Asset_Type          in ('CAPITALIZED', 'GROUP')  AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')))
     AND
        DP_BROW.book_type_code = dd.book_type_code and
        DP_BROW.period_counter = dd.period_counter +1
     and DP_BROW.period_close_date between ah.date_effective and nvl(ah.date_ineffective,sysdate)
     AND CB.Category_ID         = AH.Category_ID        AND
        CB.Book_Type_Code       = book
     AND DECODE (Report_Type,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
     AND BK.Book_Type_Code       = CB.book_type_code
     AND ((DD.Deprn_Source_Code <> 'T' AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE') /*Bug# 9293000 */
     AND   BK.Asset_ID             = DD.Asset_ID   AND
        ah.date_effective  between               BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, sysdate);

  -- MRC
  else
     INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Group_Asset_ID, -- Added for Member Track
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Cost_Account,
        Source_Type_Code,
        Amount,
        Cost_Begin_Balance)
     SELECT
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID),
        DH.Code_Combination_ID,
        null,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', 'BEGIN', 'T', 'BEGIN', 'ADDITION'), -- Added 'T'
                'REVAL RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', 'BEGIN', 'T', 'BEGIN', 'ADDITION'), -- Added 'T'
                'BEGIN'),
        DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve),
        DD.COST
     FROM
        FA_CATEGORY_BOOKS       CB,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_MC_DEPRN_DETAIL      DD,
        FA_MC_BOOKS             BK  -- Added for Member Track
     WHERE       DH.Book_Type_Code       = Distribution_Source_Book
     AND DD.Asset_ID            = AH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= Period1_Pc - 1               AND
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_MC_DEPRN_DETAIL SUB_DD
        WHERE   SUB_DD.Asset_ID         = DH.Asset_ID           AND
                SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                SUB_DD.Period_Counter   <= Period1_Pc - 1       AND
                SUB_DD.set_of_books_id  = h_sob_id)
     AND (( DD.Deprn_Source_Code <> 'T' AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE') /*Bug# 9293000 */
     AND (( 0 = (select count(1)
                from fa_mc_deprn_detail dd1
                where dd1.asset_id = DD.Asset_ID
                AND   dd1.Deprn_Source_Code = 'T'
                AND   dd1.book_type_code = Book
                AND   dd1.Period_Counter = DD.Period_Counter
                AND   dd1.set_of_books_id = h_sob_id
                AND   dd1.distribution_id > dd.distribution_id) AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE')
     AND AH.Asset_ID            = DH.Asset_ID                   AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type         in ('CAPITALIZED', 'GROUP')  AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')) OR
         (AH.Asset_Type         <> 'EXPENSED' AND nvl(Report_Style,'S') = 'D'))
     AND ((Period1_Pod BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, Period1_Pod) AND
                DD.Deprn_Source_Code = 'D')     OR
         (DD.Deprn_Run_Date BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, DD.Deprn_Run_Date) AND
                DD.Deprn_Source_Code = 'B')     OR
         (Period1_Pod BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, Period1_Pod) AND
     --           DD.Deprn_Source_Code = 'T' AND
                nvl(Report_Style,'S')= decode(substr(report_type,-4),'COST', nvl(Report_Style,'S'),'D'))) /*Bug# 9293000 */
     AND CB.Category_ID          = AH.Category_ID
     AND CB.Book_Type_Code       = Book
     AND DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                DECODE(Report_Style,'D',DECODE(AH.Asset_Type,'GROUP',CB.Asset_Cost_Acct,null),
                                null)), -- Added for second decode for drill down report
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
     AND BK.Book_Type_Code       = CB.book_type_code
     AND   BK.Asset_ID             = DD.Asset_ID   AND
        DECODE(DD.Deprn_Source_Code, 'D', Period1_pod,
                        nvl(Period1_pcd,Period1_pod)) BETWEEN /*Bug# 9293000 */
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, sysdate) AND
        NVL(BK.Period_Counter_Fully_Retired, Period1_PC)
                > period1_pc - 1
     AND DD.set_of_books_id      = h_sob_id
     AND BK.set_of_books_id      = h_sob_id
     UNION ALL-- Added to get assets added with reserve when multiple periods intervall bug  3756517
        SELECT
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID),
        DH.Code_Combination_ID,
        null,
        DECODE (Report_Type,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', 'BEGIN', 'T', 'BEGIN', 'ADDITION'), -- Added 'T'
                'REVAL RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', 'BEGIN', 'T', 'BEGIN', 'ADDITION'), -- Added 'T'
                'BEGIN'),
        DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve),
        DD.COST
     FROM
        FA_CATEGORY_BOOKS       CB,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_MC_DEPRN_DETAIL      DD,
        FA_MC_BOOKS             BK,
        FA_MC_DEPRN_PERIODS     DP_BROW
     WHERE       DH.Book_Type_Code       = distribution_source_book
     AND DD.Asset_ID            = AH.Asset_ID           AND
        DD.Book_Type_Code       = book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        dd.deprn_reserve <> 0                           AND
        dd.deprn_source_code = 'B'                      AND
        DD.Period_Counter       between period1_pc and period2_pc
     AND AH.Asset_ID            = DH.Asset_ID                   AND
        (       (AH.Asset_Type          in ('CAPITALIZED', 'GROUP')  AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')))
     AND
        DP_BROW.book_type_code = dd.book_type_code and
        DP_BROW.period_counter = dd.period_counter +1
     and DP_BROW.period_close_date between ah.date_effective and nvl(ah.date_ineffective,sysdate)
     AND CB.Category_ID          = AH.Category_ID        AND
         CB.Book_Type_Code       = book
     AND DECODE (Report_Type,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
     AND BK.Book_Type_Code       = CB.book_type_code
     AND ((DD.Deprn_Source_Code <> 'T' AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE') /*Bug# 9293000 */
     AND   BK.Asset_ID           = DD.Asset_ID   AND
        ah.date_effective  between               BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, sysdate)
     AND DD.set_of_books_id      = h_sob_id
     AND BK.set_of_books_id      = h_sob_id
     AND DP_BROW.set_of_books_id = h_sob_id;
  end if;
  -- End MRC

    h_mesg_name := 'FA_RX_END_BALANCES';

  if(h_mrcsobtype <> 'R') then -- MRC
     INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Group_Asset_ID, -- Added for Drill Down Report
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Cost_Account,
        Source_Type_Code,
        Amount)
     SELECT
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
        DH.Code_Combination_ID,
        null,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                                'D', 'END', 'T', 'END', 'ADDITION'), -- Added 'T'
                'REVAL RESERVE', DECODE(DD.Deprn_Source_Code,
                                'D', 'END', 'T', 'END', 'ADDITION'), -- Added 'T'
                'END'),
        DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve)
     FROM
        FA_CATEGORY_BOOKS       CB,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_DEPRN_DETAIL         DD,
        FA_BOOKS                BK
     WHERE       DH.Book_Type_Code       = Distribution_Source_Book
     AND DD.Asset_ID            = AH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= period2_pc           AND
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_DEPRN_DETAIL SUB_DD
        WHERE   SUB_DD.Asset_ID         = DH.Asset_ID           AND
                SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                SUB_DD.Period_Counter   <= period2_pc)
     -- Added for bug#4860955
     and Period2_pcd between dh.date_effective and nvl(dh.date_ineffective,Period2_pcd)
     AND AH.Asset_ID             = DH.Asset_ID                   AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type         in ('CAPITALIZED', 'GROUP')  AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')) OR
         (AH.Asset_Type         <> 'EXPENSED' AND nvl(Report_Style,'S') = 'D'))
     AND ((Period2_Pcd BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, Period2_Pcd) AND
                DD.Deprn_Source_Code = 'D') OR
         (DD.deprn_run_date between ah.date_effective AND
                NVL(ah.date_ineffective, DD.Deprn_run_date) AND
                DD.deprn_source_code = 'B') OR
         (Period2_Pcd BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, Period2_Pcd) AND
                DD.Deprn_Source_Code = decode(substr(report_type,-4),'COST', DD.Deprn_Source_Code, 'T') AND
                nvl(Report_Style,'S')= decode(substr(report_type,-4),'COST', nvl(Report_Style,'S'),'D') ))
     AND DD.deprn_source_code in ('D', 'T')
     AND CB.Category_ID         = AH.Category_ID        AND
        CB.Book_Type_Code       = Book
     AND DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                DECODE(Report_Style,'D',DECODE(AH.Asset_Type,'GROUP',CB.Asset_Cost_Acct,null),
                                null)),
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
     AND ((DD.Deprn_Source_Code <> 'T' AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE') /*Bug# 9293000 */
     AND BK.Book_Type_Code      = CB.book_type_code     AND
        BK.Asset_ID             = DD.Asset_ID   AND
        Period2_pcd   BETWEEN
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, sysdate) AND
        NVL(BK.Period_Counter_Fully_Retired, Period2_PC+1)
                > period1_pc - 1;

  -- MRC
  else
     INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Group_Asset_ID, -- Added for Drill Down Report
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Cost_Account,
        Source_Type_Code,
        Amount)
     SELECT
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
        DH.Code_Combination_ID,
        null,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                                'D', 'END', 'T', 'END', 'ADDITION'), -- Added 'T'
                'REVAL RESERVE', DECODE(DD.Deprn_Source_Code,
                                'D', 'END', 'T', 'END', 'ADDITION'), -- Added 'T'
                'END'),
        DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve)
     FROM
        FA_CATEGORY_BOOKS       CB,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_MC_DEPRN_DETAIL      DD,
        FA_MC_BOOKS             BK
     WHERE       DH.Book_Type_Code       = Distribution_Source_Book
     AND DD.Asset_ID            = AH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= period2_pc           AND
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_MC_DEPRN_DETAIL SUB_DD
        WHERE   SUB_DD.Asset_ID         = DH.Asset_ID           AND
                SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                SUB_DD.Period_Counter   <= period2_pc           AND
                SUB_DD.set_of_books_id  = h_sob_id)
     -- Added for bug#4860955
     and Period2_pcd between dh.date_effective and nvl(dh.date_ineffective,Period2_pcd)
     AND AH.Asset_ID             = DH.Asset_ID                   AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type         in ('CAPITALIZED', 'GROUP')  AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')) OR
         (AH.Asset_Type         <> 'EXPENSED' AND nvl(Report_Style,'S') = 'D'))
     AND ((Period2_Pcd BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, Period2_Pcd) AND
                DD.Deprn_Source_Code = 'D') OR
         (DD.deprn_run_date between ah.date_effective AND
                NVL(ah.date_ineffective, DD.Deprn_run_date) AND
                DD.deprn_source_code = 'B') OR
         (Period2_Pcd BETWEEN AH.Date_Effective AND
                NVL(AH.Date_Ineffective, Period2_Pcd) AND
                DD.Deprn_Source_Code = decode(substr(report_type,-4),'COST', DD.Deprn_Source_Code, 'T') AND
                nvl(Report_Style,'S')= decode(substr(report_type,-4),'COST', nvl(Report_Style,'S'),'D') ))
     AND DD.deprn_source_code in ('D', 'T')
     AND CB.Category_ID         = AH.Category_ID        AND
        CB.Book_Type_Code       = Book
     AND DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                DECODE(Report_Style,'D',DECODE(AH.Asset_Type,'GROUP',CB.Asset_Cost_Acct,null),
                                null)),
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
     AND ((DD.Deprn_Source_Code <> 'T' AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE') /*Bug# 9293000 */
     AND BK.Book_Type_Code      = CB.book_type_code     AND
        BK.Asset_ID             = DD.Asset_ID   AND
        Period2_pcd   BETWEEN
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, sysdate) AND
        NVL(BK.Period_Counter_Fully_Retired, Period2_PC+1)
                > period1_pc - 1
     AND DD.set_of_books_id      = h_sob_id
     AND BK.set_of_books_id      = h_sob_id;

  end if;
  -- End MRC

  h_mesg_name := 'FA_INS_ADJ_GET_VOST_ADJS';

  if(h_mrcsobtype <> 'R') then  -- MRC
     INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Group_Asset_ID, -- Added for Drill Down Report
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Cost_Account,
        Source_Type_Code,
        Amount)
     SELECT
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
        DH.Code_Combination_ID,
        AJ.Code_Combination_ID,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),  -- Bug 8616752
        CB.Asset_Cost_Acct,
        AJ.Source_Type_Code,
        SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
                AJ.Adjustment_Amount)
     FROM        FA_LOOKUPS              RT,
        FA_CATEGORY_BOOKS       CB,
        FA_ASSET_HISTORY        AH1,
        FA_DISTRIBUTION_HISTORY DH,
        FA_TRANSACTION_HEADERS  TH,
        FA_ASSET_HISTORY        AH,
        FA_ADJUSTMENTS          AJ,
        FA_BOOKS                BK
     WHERE       RT.Lookup_Type          = 'REPORT TYPE' AND
        RT.Lookup_Code          = Report_Type
     AND DH.Book_Type_Code      = Distribution_Source_Book
     AND AJ.Asset_ID            = DH.Asset_ID           AND
        AJ.Book_Type_Code       = Book                  AND
        AJ.Distribution_ID      = DH.Distribution_ID    AND
        AJ.Adjustment_Type      in
                (Report_Type, DECODE(Report_Type,
                        'REVAL RESERVE', 'REVAL AMORT')) AND
        AJ.Period_Counter_Created BETWEEN
                        Period1_PC AND Period2_PC
     AND TH.Transaction_Header_ID        = AJ.Transaction_Header_ID
     AND AH.Asset_ID            = DH.Asset_ID           AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type         in ('CAPITALIZED', 'GROUP')  AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')) OR
         (AH.Asset_Type         <> 'EXPENSED' AND nvl(Report_Style,'S') = 'D')) AND
        TH.Transaction_Header_ID BETWEEN
                AH.Transaction_Header_ID_In AND
                NVL (AH.Transaction_Header_ID_Out - 1,
                        TH.Transaction_Header_ID)
     AND (DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
                AJ.Adjustment_Amount) <> 0
     AND AH1.ASSET_ID            = AJ.ASSET_ID                   /* StatReq */
     AND AH1.DATE_EFFECTIVE     <= DH.DATE_EFFECTIVE             /* StatReq */
     AND NVL(AH1.DATE_INEFFECTIVE, SYSDATE) > DH.DATE_EFFECTIVE  /* StatReq */
     AND CB.Category_ID          = AH1.Category_ID       AND     /* StatReq */
         CB.Book_Type_Code       = Book                          /* StatReq */
     AND BK.Book_Type_Code       = Book   -- Added for Drill Down Report
     AND BK.Asset_ID             = DH.Asset_ID
     --    AND BK.DATE_EFFECTIVE      <= DH.DATE_EFFECTIVE
     --    AND NVL(BK.DATE_INEFFECTIVE, SYSDATE) > DH.DATE_EFFECTIVE
     AND BK.DATE_EFFECTIVE      <= nvl(DH.DATE_INEFFECTIVE, sysdate)
     AND NVL(BK.DATE_INEFFECTIVE, SYSDATE + 1) > nvl(DH.DATE_INEFFECTIVE, sysdate)
     AND AJ.track_member_flag is null /*Bug# 9293000 */
     GROUP BY
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
        DH.Code_Combination_ID,
        AJ.Code_Combination_ID,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        AJ.Source_Type_Code;

  -- MRC
  else
     INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Group_Asset_ID, -- Added for Drill Down Report
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Cost_Account,
        Source_Type_Code,
        Amount)
     SELECT
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
        DH.Code_Combination_ID,
        AJ.Code_Combination_ID,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),  -- Bug 8616752
        CB.Asset_Cost_Acct,
        AJ.Source_Type_Code,
        SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
                AJ.Adjustment_Amount)
     FROM        FA_LOOKUPS              RT,
        FA_CATEGORY_BOOKS       CB,
        FA_ASSET_HISTORY        AH1,
        FA_DISTRIBUTION_HISTORY DH,
        FA_TRANSACTION_HEADERS  TH,
        FA_ASSET_HISTORY        AH,
        FA_MC_ADJUSTMENTS       AJ,
        FA_MC_BOOKS             BK
     WHERE       RT.Lookup_Type          = 'REPORT TYPE' AND
        RT.Lookup_Code          = Report_Type
     AND DH.Book_Type_Code      = Distribution_Source_Book
     AND AJ.Asset_ID            = DH.Asset_ID           AND
        AJ.Book_Type_Code       = Book                  AND
        AJ.Distribution_ID      = DH.Distribution_ID    AND
        AJ.Adjustment_Type      in
                (Report_Type, DECODE(Report_Type,
                        'REVAL RESERVE', 'REVAL AMORT')) AND
        AJ.Period_Counter_Created BETWEEN
                        Period1_PC AND Period2_PC
     AND TH.Transaction_Header_ID        = AJ.Transaction_Header_ID
     AND AH.Asset_ID             = DH.Asset_ID           AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type         in ('CAPITALIZED', 'GROUP')  AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')) OR
         (AH.Asset_Type         <> 'EXPENSED' AND nvl(Report_Style,'S') = 'D')) AND
        TH.Transaction_Header_ID BETWEEN
                AH.Transaction_Header_ID_In AND
                NVL (AH.Transaction_Header_ID_Out - 1,
                        TH.Transaction_Header_ID)
     AND (DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
                AJ.Adjustment_Amount) <> 0
     AND AH1.ASSET_ID            = AJ.ASSET_ID                   /* StatReq */
     AND AH1.DATE_EFFECTIVE     <= DH.DATE_EFFECTIVE             /* StatReq */
     AND NVL(AH1.DATE_INEFFECTIVE, SYSDATE) > DH.DATE_EFFECTIVE  /* StatReq */
     AND CB.Category_ID          = AH1.Category_ID       AND     /* StatReq */
         CB.Book_Type_Code       = Book                          /* StatReq */
     AND BK.Book_Type_Code       = Book   -- Added for Drill Down Report
     AND BK.Asset_ID             = DH.Asset_ID
     --    AND BK.DATE_EFFECTIVE      <= DH.DATE_EFFECTIVE
     --    AND NVL(BK.DATE_INEFFECTIVE, SYSDATE) > DH.DATE_EFFECTIVE
     AND BK.DATE_EFFECTIVE      <= nvl(DH.DATE_INEFFECTIVE, sysdate)
     AND NVL(BK.DATE_INEFFECTIVE, SYSDATE + 1) > nvl(DH.DATE_INEFFECTIVE, sysdate)
     AND AJ.set_of_books_id      = h_sob_id
     AND BK.set_of_books_id      = h_sob_id
     AND AJ.track_member_flag is null /*Bug# 9293000 */
     GROUP BY
        DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
        DH.Code_Combination_ID,
        AJ.Code_Combination_ID,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        AJ.Source_Type_Code;
  end if;
  -- End MRC

    if (Report_Type = 'RESERVE' or Report_Type = 'REVAL RESERVE') then
--      Get_Deprn_Effects (Book, Distribution_Source_Book,
--                         Period1_PC, Period2_PC,
--                         Report_Type);

  h_mesg_name := 'FA_INS_ADJ_GET_RSV_ADJ';

  if(h_mrcsobtype <> 'R') then  -- MRC
     INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Group_Asset_ID, -- Added for Drill Down Report
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Cost_Account,
        Source_Type_Code,
        Amount)
     SELECT      DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
        DH.Code_Combination_ID,
        null,
        DECODE (RT.Lookup_Code,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        DECODE(DD.Deprn_Source_Code,
                'D', 'DEPRECIATION', 'T', 'DEPRECIATION', 'ADDITION'),
        SUM (DECODE (RT.Lookup_Code,
                'RESERVE', DD.Deprn_Amount,
                'REVAL RESERVE', -DD.Reval_Amortization))
     FROM        FA_LOOKUPS              RT,
        FA_CATEGORY_BOOKS       CB,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_DEPRN_DETAIL         DD,
        FA_DEPRN_PERIODS        DP,
        FA_BOOKS                BK -- Added for Drill Down Report
     WHERE       DH.Book_Type_Code       = Distribution_Source_Book
     AND AH.Asset_ID             = DH.Asset_ID
     AND ((AH.Asset_Type         in ('CAPITALIZED', 'GROUP')) OR
           AH.Asset_Type        <> 'EXPENSED' AND nvl(Report_Style,'S') = 'D') -- Added for Drill Down Report
     AND AH.Date_Effective       <= nvl(DP.Period_Close_Date,sysdate)    AND
         NVL (AH.Date_Ineffective, SYSDATE) >=
                         nvl(DP.Period_Close_Date,sysdate)
     AND CB.Category_ID          = AH.Category_ID        AND
         CB.Book_Type_Code       = Book
     AND ((DD.Deprn_Source_Code  = 'B'
                 AND DD.Period_Counter < Period2_PC)     OR
          (DD.Deprn_Source_Code  = 'D') OR
          (DD.Deprn_Source_Code  = 'T' and nvl(Report_Style,'S') = 'D')) AND
         DD.Book_Type_Code       = Book                  AND
         DD.Asset_ID             = DH.Asset_ID           AND
         DD.Distribution_ID      = DH.Distribution_ID    AND
         DD.Period_Counter between
                 Period1_PC and Period2_PC
     AND DP.Book_Type_Code       = DD.Book_Type_Code     AND
         DP.Period_Counter       = DD.Period_Counter
     AND RT.LOOKUP_TYPE          = 'REPORT TYPE'
     AND DECODE (RT.Lookup_Code,
                 'RESERVE', CB.Deprn_Reserve_Acct,
                 'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
     AND ((DD.Deprn_Source_Code <> 'T' AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE') /*Bug# 9293000 */
     AND DECODE (RT.Lookup_Code,
                 'RESERVE', DD.Deprn_Amount,
                 'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0
     AND BK.Book_Type_Code       = Book        -- Added for Drill Down Report
     AND BK.Asset_ID             = DH.Asset_ID
     AND nvl(DP.Period_Close_Date,sysdate)     BETWEEN BK.Date_Effective and nvl(BK.Date_Ineffective, Sysdate)
     GROUP BY
         DH.Asset_ID,
         DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
         DH.Code_Combination_ID,
         DECODE (RT.Lookup_Code,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
         CB.Asset_Cost_Acct,
         DD.Deprn_Source_Code;

  -- MRC
  else
     INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Group_Asset_ID, -- Added for Drill Down Report
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Cost_Account,
        Source_Type_Code,
        Amount)
     SELECT      DH.Asset_ID,
        DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
        DH.Code_Combination_ID,
        null,
        DECODE (RT.Lookup_Code,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        CB.Asset_Cost_Acct,
        DECODE(DD.Deprn_Source_Code,
                'D', 'DEPRECIATION', 'T', 'DEPRECIATION', 'ADDITION'),
        SUM (DECODE (RT.Lookup_Code,
                'RESERVE', DD.Deprn_Amount,
                'REVAL RESERVE', -DD.Reval_Amortization))
     FROM        FA_LOOKUPS              RT,
        FA_CATEGORY_BOOKS       CB,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_MC_DEPRN_DETAIL      DD,
        FA_MC_DEPRN_PERIODS     DP,
        FA_MC_BOOKS             BK -- Added for Drill Down Report
     WHERE       DH.Book_Type_Code       = Distribution_Source_Book
     AND AH.Asset_ID             = DH.Asset_ID
     AND ((AH.Asset_Type         in ('CAPITALIZED', 'GROUP')) OR
           AH.Asset_Type        <> 'EXPENSED' AND nvl(Report_Style,'S') = 'D') -- Added for Drill Down Report
     AND AH.Date_Effective       <= nvl(DP.Period_Close_Date,sysdate)    AND
         NVL (AH.Date_Ineffective, SYSDATE) >=
                         nvl(DP.Period_Close_Date,sysdate)
     AND CB.Category_ID          = AH.Category_ID        AND
         CB.Book_Type_Code       = Book
     AND ((DD.Deprn_Source_Code  = 'B'
                 AND DD.Period_Counter < Period2_PC)     OR
          (DD.Deprn_Source_Code  = 'D') OR
          (DD.Deprn_Source_Code  = 'T' and nvl(Report_Style,'S') = 'D')) AND
         DD.Book_Type_Code       = Book                  AND
         DD.Asset_ID             = DH.Asset_ID           AND
         DD.Distribution_ID      = DH.Distribution_ID    AND
         DD.Period_Counter between
                 Period1_PC and Period2_PC
     AND DP.Book_Type_Code       = DD.Book_Type_Code     AND
         DP.Period_Counter       = DD.Period_Counter
     AND RT.LOOKUP_TYPE          = 'REPORT TYPE'
     AND DECODE (RT.Lookup_Code,
                 'RESERVE', CB.Deprn_Reserve_Acct,
                 'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
     AND ((DD.Deprn_Source_Code <> 'T' AND Report_Type = 'RESERVE' ) OR Report_Type <> 'RESERVE') /*Bug# 9293000 */
     AND DECODE (RT.Lookup_Code,
                 'RESERVE', DD.Deprn_Amount,
                 'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0
     AND BK.Book_Type_Code       = Book        -- Added for Drill Down Report
     AND BK.Asset_ID             = DH.Asset_ID
     AND nvl(DP.Period_Close_Date,sysdate)     BETWEEN BK.Date_Effective and nvl(BK.Date_Ineffective, Sysdate)
     AND DD.set_of_books_id      = h_sob_id
     AND DP.set_of_books_id      = h_sob_id
     AND BK.set_of_books_id      = h_sob_id
     GROUP BY
         DH.Asset_ID,
         DECODE(AH.Asset_Type,'GROUP',DH.Asset_ID,BK.Group_Asset_ID), -- Added for Drill Down Report
         DH.Code_Combination_ID,
         DECODE (RT.Lookup_Code,
                 'RESERVE', CB.Deprn_Reserve_Acct,
                 'REVAL RESERVE', CB.Reval_Reserve_Acct),
         CB.Asset_Cost_Acct,
         DD.Deprn_Source_Code;
  end if;
  -- End MRC

    end if;


-- Get segment numbers corresponding to the given structure_id.
-- Will need these later for getting segments for given ccids.

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.get_acct_segment_numbers (
        BOOK => Book,
        BALANCING_SEGNUM => gl_balancing_seg,
        ACCOUNT_SEGNUM => gl_account_seg,
        CC_SEGNUM => fa_cost_ctr_seg,
        CALLING_FN => 'FA_BALANCES_REPORT');

   /* StatReq - The following statement has been added to get the natural account segment's valueset */

   return_status := FND_FLEX_APIS.GET_SEGMENT_INFO
                        (101, 'GL#', Acct_Flex_Structure, Gl_Account_Seg,
                         Acct_Appl_Col, Acct_Segname, Acct_Prompt, Acct_Valueset_Name);

      fa_rx_shared_pkg.get_acct_segment_index (
        BOOK => Book,
        BALANCING_SEGNUM => gl_balancing_seg,
        ACCOUNT_SEGNUM => gl_account_seg,
        CC_SEGNUM => fa_cost_ctr_seg,
        CALLING_FN => 'FA_BALANCES_REPORT');



--   open non_qualified_segs;
--   loop
--     fetch non_qualified_segs into
--    h_nonqual_col_name,
--    h_nonqual_seg_name,
--    h_nonqual_seg_num;
--
--     if (non_qualified_segs%NOTFOUND) then exit; end if;
--
--   fa_rx_dynamic_columns_pkg.add_column (
--  X_request_id        => h_request_id,
--  X_attribute_name => h_nonqual_seg_name,
--  X_column_name       => h_nonqual_col_name,
--  X_ordering  => 'NONE',
-- X_BREAK        => 'N',
-- X_DISPLAY_LENGTH   => 30,
-- X_DISPLAY_FORMAT   => 'VARCHAR2',
-- X_DISPLAY_STATUS   => 'YES',
--  calling_fn => 'BALANCES REP');
--
--   end loop;
--   close non_qualified_segs;
--
--   mesg := 'Error looping through adjustment ccids';

-- Each FA_BALANCES_REPORT_GT row corresponds to one of the following:
-- (1) begin balance, (2) end balance, (3) an adjustment, (4)
-- depreciation.  Each corresponds to a given account.  Sometimes,
-- the account is the default from FA_CATEGORY_BOOKS; in this case
-- the account segment itself is stored here and we can simply select
-- it later.  However, sometimes the "account" is stored as a ccid.
-- In this case, we must find the accounting segment corresponding
-- to that ccid, and store it now, so we can select it later.
-- Use get_segments to find the accounting segment now.  Doing it now
-- vastly simplifies selecting later.

  h_mesg_name := 'FA_RX_ADJ_SEGMENTS';

  OPEN BAL_REPORT_AJCCID;
  loop
    fetch BAL_REPORT_AJCCID into
        h_br_ajccid,
        h_br_account,
        h_br_rowid;

    if (BAL_REPORT_AJCCID%NOTFOUND) then exit;  end if;

    if (h_br_account is null and h_br_ajccid is not null ) then

        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_ccid_error := h_br_ajccid;

        fa_rx_shared_pkg.get_acct_segments (
          combination_id => h_br_ajccid,
          n_segments => n_segs,
          segments => acct_all_segs,
          calling_fn => 'FA_BALANCES_REPORT');

        h_mesg_name := 'FA_POST_SQL_UPDATE_TABLE';
        h_table_token := 'FA_BALANCES_REPORT_GT';

        update fa_balances_report_gt
        set category_books_account = acct_all_segs(gl_account_seg)
        where rowid = h_br_rowid;

    end if;
  end loop;
  CLOSE BAL_REPORT_AJCCID;


-- Now report in data in FA_BALANCES_REPORT_GT (if an accum deprn
-- or reval reserve report).

  if (report_type in ('RESERVE','REVAL RESERVE')) then

   mesg := 'Error getting reserve balances';


  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  if(h_mrcsobtype <> 'R') then -- MRC
     open RESERVE_REPORT (book, Period2_PCD);     /* StatReq */
  -- MRC
  else
     open MC_RESERVE_REPORT (book, Period2_PCD);
  end if;
  -- End MRC

   loop

        h_mesg_name := 'FA_DEPRN_SQL_FCUR';

  if(h_mrcsobtype <> 'R') then -- MRC
     fetch RESERVE_REPORT into
        h_asset_id,                                                     /* StatReq */
        h_ccid,
        h_account,
        h_cost_account,                                                 /* StatReq */
        h_asset,
        h_tag_number,
        h_description, h_serial_number, h_inventorial, h_asset_key_ccid,
        h_category_id,                                                  /* StatReq */
        h_date_placed_in_service,                                       /* StatReq */
        h_method_code,                                                  /* StatReq */
        h_life_in_months,                                               /* StatReq */
        h_stl_method_flag,                                              /* StatReq */
        h_rate_source_rule,                                             /* StatReq */
        h_cost_begin_balance,                                           /* StatReq */
        h_begin,
        h_addition,
        h_adjustment, /*9293000 */
        h_depreciation,
        h_reclass,
        h_retirement,
        h_revaluation,
        h_tax,
        h_transfer,
        h_end;/*Bug# 9293000 */

     if (RESERVE_REPORT%NOTFOUND) then exit;  end if;

  -- MRC
  else
     fetch MC_RESERVE_REPORT into
        h_asset_id,                                                     /* StatReq */
        h_ccid,
        h_account,
        h_cost_account,                                                 /* StatReq */
        h_asset,
        h_tag_number,
        h_description, h_serial_number, h_inventorial, h_asset_key_ccid,
        h_category_id,                                                  /* StatReq */
        h_date_placed_in_service,                                       /* StatReq */
        h_method_code,                                                  /* StatReq */
        h_life_in_months,                                               /* StatReq */
        h_stl_method_flag,                                              /* StatReq */
        h_rate_source_rule,                                             /* StatReq */
        h_cost_begin_balance,                                           /* StatReq */
        h_begin,
        h_addition,
        h_adjustment, /*9293000 */
        h_depreciation,
        h_reclass,
        h_retirement,
        h_revaluation,
        h_tax,
        h_transfer,
        h_end;/*Bug# 9293000 */

     if (MC_RESERVE_REPORT%NOTFOUND) then exit;  end if;
  end if;
  -- End MRC

    h_mesg_name := 'FA_RX_CONCAT_SEGS';
    h_ccid_error := h_ccid;

    fa_rx_shared_pkg.get_acct_segments (
      combination_id => h_ccid,
      n_segments => n_segs,
      segments => acct_all_segs,
      calling_fn => 'FA_BALANCES_REPORT');

     /* StatReq - The following 6 function calls have been added to retrieve more
        detailed asset information */

     h_account_description :=
        fa_rx_shared_pkg.get_flex_val_meaning(NULL, acct_valueset_name, h_account);

     h_vendor_name :=
        fa_rx_shared_pkg.get_asset_info('VENDOR_NAME', h_asset_id, period1_pod, period2_pcd, book,
                                        acct_all_segs(gl_balancing_seg));
     h_invoice_number :=
        fa_rx_shared_pkg.get_asset_info('INVOICE_NUMBER', h_asset_id, period1_pod, period2_pcd, book,
                                        acct_all_segs(gl_balancing_seg));
     h_invoice_descr :=
        fa_rx_shared_pkg.get_asset_info('INVOICE_DESCR', h_asset_id, period1_pod, period2_pcd, book,
                                        acct_all_segs(gl_balancing_seg));
     h_location :=
        fa_rx_shared_pkg.get_asset_info('LOCATION', h_asset_id, period1_pod, period2_pcd, distribution_source_book,
                                        acct_all_segs(gl_balancing_seg));
     h_retirement_type :=
        fa_rx_shared_pkg.get_asset_info('RETIREMENT_TYPE',h_asset_id, period1_pod, period2_pcd, book,
                                        acct_all_segs(gl_balancing_seg));


   h_adjustment := nvl(h_adjustment,0) + nvl(h_tax,0) + nvl(h_revaluation,0); /*9293000 */

   if (nvl(h_begin,0) + nvl(h_addition,0) + nvl(h_depreciation,0)
        + nvl(h_reclass,0) - nvl(h_retirement,0) + nvl(h_transfer,0)
        + nvl(h_adjustment,0) = nvl(h_end,0)) then
     h_out_of_bal_flag := 'N';
   else h_out_of_bal_flag := 'Y';
   end if;

   if h_asset_key_ccid is not null then
        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'KEY#';
        h_ccid_error := h_asset_key_ccid;

        fa_rx_shared_pkg.concat_asset_key (
        struct_id => h_key_flex_struct,
        ccid => h_asset_key_ccid,
        concat_string => h_concat_key,
        segarray => h_key_segs);

    else
        h_concat_key := null;

    end if;

   /* StatReq - The following if statement has been added to retrieve the category
      each asset */

   if h_category_id is not null then
        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'CAT#';
        h_ccid_error := h_category_id;

        fa_rx_shared_pkg.concat_category (
        struct_id => h_cat_flex_struct,
        ccid => h_category_id,
        concat_string => h_concat_cat,
        segarray => h_cat_segs);

    else
        h_concat_cat := null;
    end if;

   /* StatReq - The following if statement has been added to calculate the annual depreciation rate
                for straight-line, calculated depreciation methods */

  if (h_stl_method_flag = 'YES' and h_rate_source_rule = 'CALCULATED')
  then
        h_stl_depreciation_rate := 12 / h_life_in_months * 100;

        -- MRC
        IF NOT FA_UTILS_PKG.faxrnd(
                   X_amount => h_stl_depreciation_rate,
                   X_book   => book,
                   X_set_of_books_id => h_sob_id,
                   p_log_level_rec   => null) then

           success := FALSE;
        end if;
        -- End MRC

  else
        h_stl_depreciation_rate := NULL;
  end if;

  h_short_account_description := substr(h_account_description,1,239);

  h_short_location := substr(h_location, 1, 499);

  h_shortconcat_key := substr(h_concat_key,1,239);

  -- Added following code for bug 5944006
  h_short_invoice_number := substrb(h_invoice_number, 1, 499);
  h_short_invoice_descr := substrb(h_invoice_descr, 1, 499);
  h_short_vendor_name   := substrb(h_vendor_name, 1, 499);
  h_short_retirement_type := substrb(h_retirement_type, 1, 499);
  -- End of bug fix 5944006

  h_mesg_name := 'FA_SHARED_INSERT_FAILED';
  h_table_token := 'FA_BALANCES_REP_ITF';

-- insert into interface table
    insert /*+ noappend */ into fa_balances_rep_itf
        (request_id, company, cost_center, account,
         cost_account,
         inventorial, asset_key,        asset_number, tag_number, description,
         category, deprn_method,
         account_description, date_placed_in_service, book_type_code,
         life_in_months, stl_depreciation_rate,
         concat_vendor_name, concat_invoice_number,
         concat_invoice_description, concat_location,
         concat_retirement_type, cost_begin_balance,
         begin_balance, additions,adjustments,  /*9293000 */
         retirements, revaluations, reclasses, transfers, depreciation,
         amortization, end_balance, out_of_balance_flag, serial_number,
         created_by, creation_date,
         last_updated_by, last_update_date, last_update_login,
         group_asset_number  ) values (
         Request_Id, acct_all_segs(gl_balancing_seg),
         acct_all_segs(fa_cost_ctr_seg), h_account,
         h_cost_account,
         h_inventorial, h_shortconcat_key,
         -- 'BAL','CC','ACCT',
         h_asset, h_tag_number, h_description,
         h_concat_cat, h_method_code,
         h_short_account_description, h_date_placed_in_service, book,
         h_life_in_months, h_stl_depreciation_rate,
         h_short_vendor_name, h_short_invoice_number, h_short_invoice_descr,    -- bug 5944006
         h_short_location,
         h_short_retirement_type, h_cost_begin_balance,         -- bug 5944006
         h_begin, h_addition,h_adjustment, h_retirement,
         h_revaluation, h_reclass, h_transfer, h_depreciation,
         h_depreciation, nvl(h_end,0), h_out_of_bal_flag, h_serial_number,
         User_Id, sysdate, user_id, sysdate, h_Login_id,
         h_group_asset);


    end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  if(h_mrcsobtype <> 'R') then   -- MRC
     close RESERVE_REPORT;
  -- MRC
  else
     close MC_RESERVE_REPORT;
  end if;
  -- End MRC

    if nvl(Report_Style,'S') = 'D' then
      -- Following logic is summarize the member level amounts into group level
      For group_asset in GROUP_ASSETS loop

        open GROUP_RESERVE_AMOUNTS(group_asset.group_asset_id);
        fetch GROUP_RESERVE_AMOUNTS into h_cost_begin_balance;
        close GROUP_RESERVE_AMOUNTS;

        select distinct asset_number
          into h_group_asset
          from fa_additions
         where asset_id=group_asset.group_asset_id;

        Update fa_balances_rep_itf
           set cost_begin_balance = h_cost_begin_balance
         where request_id = Request_Id
           and asset_number = h_group_asset;

      end loop;
    end if; -- Report_Style

  else


-- Now report on data in FA_BALANCES_REPORT_GT (for asset cost and
-- CIP cost reports).

   mesg := 'Error selecting cost balances';

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  if(h_mrcsobtype <> 'R') then -- MRC
     open COST_REPORT (book, Period2_PCD, period1_pod);
  -- MRC
  else
     open MC_COST_REPORT (book, Period2_PCD, period1_pod);
  end if;
  -- End MRC

  loop
  h_mesg_name := 'FA_DEPRN_SQL_FCUR';

  if(h_mrcsobtype <> 'R') then -- MRC
     fetch COST_REPORT into
        h_asset_id,
        h_ccid,
        h_account,
        h_cost_account,
        h_asset,
        h_tag_number,
        h_description,
        h_serial_number, h_inventorial, h_asset_key_ccid,
        h_category_id,
        h_date_placed_in_service,
        h_method_code,
        h_life_in_months,
        h_stl_method_flag,
        h_rate_source_rule,
        h_cost_begin_balance,
        h_begin,
        h_addition,
        h_capitalization,
        h_adjustment,
        h_reclass,
        h_retirement,
        h_revaluation,
        h_transfer,
        h_end;/*Bug# 9293000 */

     if (COST_REPORT%NOTFOUND) then exit;  end if;

  -- MRC
  else
     fetch MC_COST_REPORT into
        h_asset_id,
        h_ccid,
        h_account,
        h_cost_account,
        h_asset,
        h_tag_number,
        h_description,
        h_serial_number, h_inventorial, h_asset_key_ccid,
        h_category_id,
        h_date_placed_in_service,
        h_method_code,
        h_life_in_months,
        h_stl_method_flag,
        h_rate_source_rule,
        h_cost_begin_balance,
        h_begin,
        h_addition,
        h_capitalization,
        h_adjustment,
        h_reclass,
        h_retirement,
        h_revaluation,
        h_transfer,
        h_end;/*Bug# 9293000 */

     if (MC_COST_REPORT%NOTFOUND) then exit;  end if;
  end if;
  -- End MRC

     h_mesg_name := 'FA_RX_CONCAT_SEGS';
     h_ccid_error := h_ccid;

     fa_rx_shared_pkg.get_acct_segments (
       combination_id => h_ccid,
       n_segments => n_segs,
       segments => acct_all_segs,
       calling_fn => 'FA_BALANCES_REPORT');

     /* StatReq - The following 6 function calls have been added to retrieve more
        detailed asset information */

     h_account_description :=
        fa_rx_shared_pkg.get_flex_val_meaning(NULL, acct_valueset_name, h_account);

     h_vendor_name :=
        fa_rx_shared_pkg.get_asset_info('VENDOR_NAME', h_asset_id, period1_pod, period2_pcd, book,
                                        acct_all_segs(gl_balancing_seg));
     h_invoice_number :=
        fa_rx_shared_pkg.get_asset_info('INVOICE_NUMBER', h_asset_id, period1_pod, period2_pcd, book,
                                        acct_all_segs(gl_balancing_seg));
     h_invoice_descr :=
        fa_rx_shared_pkg.get_asset_info('INVOICE_DESCR', h_asset_id, period1_pod, period2_pcd, book,
                                        acct_all_segs(gl_balancing_seg));
     h_location :=
        fa_rx_shared_pkg.get_asset_info('LOCATION', h_asset_id, period1_pod, period2_pcd, distribution_source_book,
                                        acct_all_segs(gl_balancing_seg));
     h_retirement_type :=
        fa_rx_shared_pkg.get_asset_info('RETIREMENT_TYPE',h_asset_id, period1_pod, period2_pcd, book,
                                        acct_all_segs(gl_balancing_seg));


   if (nvl(h_begin,0) + nvl(h_addition,0) - nvl(h_capitalization,0)
        + nvl(h_reclass,0) - nvl(h_retirement,0) + nvl(h_transfer,0)
        + nvl(h_adjustment,0) + nvl(h_revaluation,0) = nvl(h_end,0)) then
     h_out_of_bal_flag := 'N';
   else h_out_of_bal_flag := 'Y';
   end if;

   if h_asset_key_ccid is not null then
        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'KEY#';
        h_ccid_error := h_asset_key_ccid;

        fa_rx_shared_pkg.concat_asset_key (
        struct_id => h_key_flex_struct,
        ccid => h_asset_key_ccid,
        concat_string => h_concat_key,
        segarray => h_key_segs);

    else
        h_concat_key := null;

    end if;


   /* StatReq - The following if statement has been added to retrieve the category
      for each asset */

   if h_category_id is not null then
        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'CAT#';
        h_ccid_error := h_category_id;

        fa_rx_shared_pkg.concat_category (
        struct_id => h_cat_flex_struct,
        ccid => h_category_id,
        concat_string => h_concat_cat,
        segarray => h_cat_segs);

    else
        h_concat_cat := null;
    end if;

   /* StatReq - The following if statement has been added to calculate the annual depreciation rate
                for straight-line, calculated depreciation methods */

  if (h_stl_method_flag = 'YES' and h_rate_source_rule = 'CALCULATED')
  then
        h_stl_depreciation_rate := 12 / h_life_in_months * 100;

        -- MRC
        IF NOT FA_UTILS_PKG.faxrnd(
                   X_amount => h_stl_depreciation_rate,
                   X_book   => book,
                   X_set_of_books_id => h_sob_id,
                   p_log_level_rec   => null) then

           success := FALSE;
        end if;
        -- End MRC

  else
        h_stl_depreciation_rate := NULL;
  end if;

  h_short_account_description := substr(h_account_description,1,239);

  h_short_location := substr(h_location, 1, 499);

  h_shortconcat_key := substr(h_concat_key,1, 239);


  h_mesg_name := 'FA_SHARED_INSERT_FAILED';
  h_table_token := 'FA_BALANCES_REP_ITF';

  -- Added following code for bug 5944006
  h_short_invoice_number := substrb(h_invoice_number, 1, 499);
  h_short_invoice_descr := substrb(h_invoice_descr, 1, 499);
  h_short_vendor_name   := substrb(h_vendor_name, 1, 499);
  h_short_retirement_type := substrb(h_retirement_type, 1, 499);
  -- End of bug fix 5944006

--insert into interface table
    insert /*+ noappend */ into fa_balances_rep_itf
        (request_id, company, cost_center, account,
         cost_account,                                                  /* StatReq */
         asset_key, asset_number, tag_number, description,
         inventorial, serial_number,
         category, deprn_method,                                        /* StatReq */
         account_description, date_placed_in_service, book_type_code,   /* StatReq */
         life_in_months, stl_depreciation_rate,                         /* StatReq */
         concat_vendor_name, concat_invoice_number,                     /* StatReq */
         concat_invoice_description, concat_location,                   /* StatReq */
         concat_retirement_type, cost_begin_balance,                    /* StatReq */
         begin_balance, additions, adjustments,
         retirements, revaluations, reclasses, capitalizations, transfers,
         end_balance, out_of_balance_flag, created_by, creation_date,
         last_updated_by, last_update_date, last_update_login, group_asset_number
--       , segment1, segment2, segment3, segment4, segment5,
--       segment6, segment7, segment8, segment9, segment10,
--       segment11, segment12, segment13, segment14, segment15,
--       segment16, segment17, segment18, segment19, segment20,
--       segment21, segment22, segment23, segment24, segment25,
--       segment26, segment27, segment28, segment29, segment30
         ) values (
         Request_Id, acct_all_segs(gl_balancing_seg),
         acct_all_segs(fa_cost_ctr_seg), h_account,
         h_cost_account,
         h_shortconcat_key,
         -- 'BAL','CC','ACCT',
         h_asset, h_tag_number, h_description,
         h_inventorial, h_serial_number,
         h_concat_cat, h_method_code,
         h_short_account_description, h_date_placed_in_service, book,
         h_life_in_months, h_stl_depreciation_rate,
         h_short_vendor_name, h_short_invoice_number, h_short_invoice_descr,    -- bug 5944006
         h_short_location,
         h_short_retirement_type, h_cost_begin_balance,         -- bug 5944006
         h_begin, h_addition, h_adjustment, h_retirement,
         h_revaluation, h_reclass, h_capitalization, h_transfer,
         h_end, h_out_of_bal_flag, User_Id, sysdate, User_Id,
         sysdate, h_Login_Id, h_group_Asset);

    end loop;
  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  if(h_mrcsobtype <> 'R') then   -- MRC
     close COST_REPORT;
  -- MRC
  else
     close MC_COST_REPORT;
  end if;
  -- End MRC

    if nvl(Report_Style,'S') = 'D' then
      -- Following logic is summarize the member level amounts into group level
      For group_asset in GROUP_ASSETS loop

        open GROUP_COST_AMOUNTS(group_asset.group_asset_id);
        fetch GROUP_COST_AMOUNTS into h_cost_begin_balance,
                                 h_begin,
                                 h_addition,
                                 h_capitalization,
                                 h_adjustment,
                                 h_reclass,
                                 h_retirement,
                                 h_revaluation,
                                 h_transfer,
                                 h_end;
        close GROUP_COST_AMOUNTS;

        select distinct asset_number
          into h_group_asset
          from fa_additions
         where asset_id=group_asset.group_asset_id;

        Update fa_balances_rep_itf
           set cost_begin_balance = h_cost_begin_balance,
               begin_balance      = h_begin,
               additions          = h_addition,
               capitalizations    = h_capitalization,
               adjustments        = h_adjustment,
               reclasses          = h_reclass,
               retirements        = h_retirement,
               revaluations       = h_revaluation,
               transfers          = h_transfer,
               end_balance        = h_end
         where request_id = Request_Id
           and asset_number = h_group_asset;

      end loop;
    end if; -- Report_Style

  end if;   -- if report_type like %RESERVE

  success := TRUE;

  exception
    when others then success := FALSE;

  fa_rx_conc_mesg_pkg.log(SQLERRM);

  fnd_message.set_name('OFA',h_mesg_name);

  if h_mesg_name in ('FA_SHARED_DETELE_FAILED','FA_SHARED_INSERT_FAILED') then
        fnd_message.set_token('TABLE',h_table_token,FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE','GL#',FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);

end balances_reports;


PROCEDURE CIP_BALANCES_RPT (
  book                  in      varchar2,
  start_period_name     in      varchar2,
  end_period_name       in      varchar2,
  request_id            in      number,
  user_id               in      number,
  retcode        out nocopy number,
  errbuf         out nocopy varchar2) is

h_success boolean;
BEGIN

  farx_bl.balances_reports (
    book => book,
    start_period_name => start_period_name,
    end_period_name => end_period_name,
    report_type => 'CIP COST',
    adj_mode => 'ADJUSTMENTS',
    request_id => request_id,
    user_id => user_id,
    calling_fn => 'CIP_BALANCES_RPT',
    mesg => errbuf,
    success => h_success);

  if (h_success) then retcode := 0;  else retcode := 2;  end if;

  commit;
END CIP_BALANCES_RPT;


PROCEDURE ASSET_COST_BALANCES_RPT (
  book                  in      varchar2,
  start_period_name     in      varchar2,
  end_period_name       in      varchar2,
  sob_id                in      varchar2 default NULL,   -- MRC: Set of books id
  report_style          in      varchar2,
  request_id            in      number,
  user_id               in      number,
  retcode        out nocopy number,
  errbuf         out nocopy varchar2) is

h_success boolean;
BEGIN

fa_debug_pkg.initialize;
fa_debug_pkg.add('farxblb','report_style', report_style);


  farx_bl.balances_reports (
    book => book,
    start_period_name => start_period_name,
    end_period_name => end_period_name,
    report_type => 'COST',
    adj_mode => 'ADJUSTMENTS',
    sob_id   => sob_id,        -- MRC
    report_style => report_style,
    request_id => request_id,
    user_id => user_id,
    calling_fn => 'ASSET_COST_BALANCES_RPT',
    mesg => errbuf,
    success => h_success);


  if (h_success) then retcode := 0;  else retcode := 2;  end if;

  commit;
END ASSET_COST_BALANCES_RPT;

PROCEDURE ACCUM_DEPRN_BALANCES_RPT (
  book                  in      varchar2,
  start_period_name     in      varchar2,
  end_period_name       in      varchar2,
  sob_id                in      varchar2 default NULL,   -- MRC: Set of books id
  report_style          in      varchar2,
  request_id            in      number,
  user_id               in      number,
  retcode        out nocopy number,
  errbuf         out nocopy varchar2) is

  h_success boolean;

BEGIN

fa_debug_pkg.initialize;
fa_debug_pkg.add('farxblb','report_style', report_style);

  farx_bl.balances_reports (
    book => book,
    start_period_name => start_period_name,
    end_period_name => end_period_name,
    report_type => 'RESERVE',
    adj_mode => 'ADJUSTMENTS',
    sob_id   => sob_id,        -- MRC
    report_style => report_style,
    request_id => request_id,
    user_id => user_id,
    calling_fn => 'ACCUM_DEPRN_BALANCES_RPT',
    mesg => errbuf,
    success => h_success);

  if (h_success) then retcode := 0;  else retcode := 2;  end if;

  commit;
END ACCUM_DEPRN_BALANCES_RPT;



PROCEDURE REVAL_RESERVE_BALANCES_RPT (
  book                  in      varchar2,
  start_period_name     in      varchar2,
  end_period_name       in      varchar2,
  request_id            in      number,
  user_id               in      number,
  retcode        out nocopy number,
  errbuf         out nocopy varchar2) is

  h_success  boolean;
BEGIN

  farx_bl.balances_reports (
    book => book,
    start_period_name => start_period_name,
    end_period_name => end_period_name,
    report_type => 'REVAL RESERVE',
    adj_mode => 'ADJUSTMENTS',
    request_id => request_id,
    user_id => user_id,
    calling_fn => 'REVAL_RESERVE_BALANCES_RPT',
    mesg => errbuf,
    success => h_success);

  if (h_success) then retcode := 0;  else retcode := 2;  end if;

  commit;
END REVAL_RESERVE_BALANCES_RPT;


END FARX_BL;

/
