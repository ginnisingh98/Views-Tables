--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_TAX_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_TAX_REP_PKG" as
/* $Header: fadptxb.pls 120.37.12010000.7 2009/12/21 11:19:57 pmadas ship $ */

-- ER 7661628: Adding this variable to make the code changes for 7661628 specific to R12 only
g_release                  number  := fa_cache_pkg.fazarel_release;

--toru
--g_print_debug boolean := fa_cache_pkg.fa_print_debug;
g_print_debug boolean := TRUE;

/*===========================================================================
 PROCEDURE
        FADPTX_INSERT

 DESCRIPTION
        This procedure insert the data to interim table:FA_DEPRN_TAX_REP_ITF.
===========================================================================*/

procedure fadptx_insert (
        errbuf             out nocopy varchar2,
        retcode            out nocopy number,
        book               in  varchar2, /* Book type code */
        year               in  number,   /* Target Year */
        state_from         in  varchar2, /* Print Location State from */
        state_to           in  varchar2, /* Print Location State to */
        tax_asset_type_seg in  varchar2, /* Category Segment Number or Qualifier */
        category_from      in  varchar2, /* Tax Asset Type Category From */
        category_to        in  varchar2, /* Tax Asset Type Category To */
        sale_code          in  varchar2, /* Ritirement type for reason code */
        all_state          in  boolean,  -- Obsolete this parameter
        rounding           in  boolean, -- Round  bug4919991
        request_id         in  number,    /* Request id */
        login_id           in  number     /* login id */
) is

        v_MainCursor            number;
        v_MainReturn            number;
        v_MainFetch             number;

        v_SubCursor             number;
        v_SubReturn             number;
        v_SubFetch              number;

        h_login_id              number;
        h_request_id            number;

        /* Client Extension */
        v_ExtCursor     number;
        l_ExtString     varchar2(1500);
        v_ExtReturn     number;
        no_package      exception;
        PRAGMA EXCEPTION_INIT (no_package, -6550);

        /* Parameter */
        h_book                  varchar2(30);
        h_year                  number;
        h_category_from         varchar2(150);
        h_category_to           varchar2(150);
        h_sale_code             varchar2(30);

        /* If h_book is tax book, need source corp book */
        h_corp_book             varchar2(30);

        /* Start date and End date */
        h_target_date           date;
        h_prior_date            date;

        /* FA flexfield structure information */
        cat_flex_struct         number;
        loc_flex_struct         number;
        l_parm_minor            varchar2(50);
        l_parm_state            varchar2(50);

        /* Precision infomation */
        h_currency_code         varchar2(15);
        h_precision             number;
        h_ext_precision         number;
        h_min_acct_unit         number := null;

        h_company_name          varchar2(80);

        /* Dynamic SQL */
        sql_base                varchar2(20000);
        sql_both_base           varchar2(20000);
        l_parm_view             varchar2(5000);
        l_base_where            varchar2(3000);
        l_sm_where              varchar2(3000);

        l_select_sm             varchar2(1000);
        l_base_from             varchar2(7000);
        l_select_base           varchar2(2500);
        l_select_both           varchar2(2500);
        l_select_end            varchar2(2500);
        l_select_start          varchar2(2500);
        l_from_stmt             varchar2(2000);
        l_group_by              varchar2(500);

        l_main                  dbms_sql.varchar2s;

        l_sub_sql               varchar2(3000); -- Bug3896299 Extended.
        l_asset_id              number;
        l_total_cost            number; -- bug#2661575: asset total cost at target date
        l_total_prior_cost      number; -- bug#2661575: asset total cost at prior date
        l_total_units           number; -- bug#2661575: asset total units at target date
        l_total_prior_units     number; -- bug#2661575: asset total units at prior date

        /* Valiable for output */

        h_asset_id              number;
        h_asset_number          varchar2(15);
        h_asset_desc            varchar2(80);
        h_new_used              varchar2(4);
        h_book_type_code        varchar2(30);
        h_minor_category        varchar2(150);
        h_start_asset_type      varchar2(15);  -- Treate UTF8
        h_tax_asset_type        varchar2(15);  -- Treate UTF8
        h_minor_cat_desc        varchar2(240);
        h_start_state           varchar2(150);
        h_state                 varchar2(150);
        h_start_units_total     number;
        h_end_units_total       number;
        h_start_units_assigned  number;
        h_end_units_assigned    number;
        h_end_cost              number;
        h_increase_cost         number;
        h_start_cost            number;
        h_decrease_cost         number;
        h_theoretical_nbv       number;
        h_evaluated_nbv         number;
        h_date_in_service       date;
        h_era_name_num          varchar2(1);
        h_add_era_year          number; /* Japaese Imperial year */
        h_add_year              number; /* RRRR */
        h_add_month             number;
        h_start_life            number;
        h_end_life              number;
        h_theoretical_residual_rate             number;
        h_evaluated_residual_rate               number;
        h_adjusted_rate         number;
        h_theoretical_taxable_cost              number;
        h_evaluated_taxable_cost                number;
        h_all_reason_type       varchar2(30);
        h_all_reason_code       varchar2(1);
        h_adddec_reason_type    varchar2(30);
        h_adddec_reason_code    varchar2(1);
        h_dec_type              varchar2(1);
        h_add_dec_flag          varchar2(1);
        /* bug 2082460 */
        h_all_description       varchar2(80);
        h_adddec_description    varchar2(80);
        h_action_flag           varchar2(1);


        /* Variable fro Cost Distirbute Calculation */

        h_end_cost_total        number :=0;     /* Cost total of an asst */
        h_end_units_accm        number :=0;     /* Units accumlate */
        h_end_cost_accm         number :=0;     /* Cost accumlate */
        h_end_asset_id          number :=0;     /* Asset_id for cost distiribute */

        h_start_cost_total      number :=0;     /* Cost total of an asst */
        h_start_units_accm      number :=0;     /* Units accumlate */
        h_start_cost_accm       number :=0;     /* Cost accumlate */
        h_start_asset_id        number :=0;     /* Asset_id for cost distiribute */

        /* FLAG for Reason Code */
        r_addition_flag         varchar2(1);
        r_ret_flag              varchar2(1);
        r_ret_id                number;
        r_ret_type_code         varchar2(15);
        r_sold_to               varchar2(30); -- Bug#3560574 Expanded to 30 bites
        r_ret_transaction_name  varchar2(30);
        r_transfer_flag         varchar2(1);
        r_transfer_date         varchar2(10);
        r_trn_transaction_name  varchar2(30);
        /* bug 2082460 */
        r_change_life_desc      varchar2(80);

        /* Report Flag */
        h_sum_rep               BOOLEAN;
        h_all_rep               BOOLEAN;
        h_add_rep               BOOLEAN;
        h_dec_rep               BOOLEAN;

        /* Request Id */
        h_req1                  number;
        h_req2                  number;
        h_req3                  number;
        h_req4                  number;

        /* NBV CALCULATION */
        h_half_rate             number; /* half year residual rate */
        h_full_rate             number; /* full year residual rate */
        h_diff_year             number; /* target year - add_year */
        i                       number :=0; /* Loop counter */
        k                       number :=0; /* Loop counter for main sql */

        /* Restructure of Logic */
        sql_nbv                 varchar2(20000);
        l_nbv_where             varchar2(3000);
        l_select_nbv            varchar2(2500);
        l_from_nbv              varchar2(2000);

        sql_base_ba2            varchar2(20000);
        l_select_base_ba2       varchar2(2500);
        l_from_stmt_ba2         varchar2(100);
        l_where_ba2             varchar2(250);

        /* Bind Variable Project */
        h_method_code           varchar2(10) := 'JP-DB %';

        /* Bug#3305784 - Enhancement to make category flexfield segment flexible */
        h_tax_asset_type_segment     varchar2(30);

        /* bug#2433829 -- Supported Rate chenges */  -- Obsolete

        --
        /* bug#2448122 -- Treate FA_DEPRN_TAX_REP_NBVS */

        CURSOR c_last_update
          (
           p_asset_id   NUMBER,
           p_book_type_code   VARCHAR2,
           p_state            VARCHAR2,
           p_year             NUMBER
           ) IS
              SELECT cost,
                tax_asset_type,
                units_assigned,
                life
                FROM FA_DEPRN_TAX_REP_NBVS dtn
                WHERE dtn.asset_id = p_asset_id
                AND dtn.book_type_code = p_book_type_code
                AND dtn.state = p_state
                AND dtn.year = p_year -1;


        CURSOR c_nbv_update   --bug#2661575 Removed parameter p_add_year
          (
           p_asset_id   NUMBER,
           p_book_type_code   VARCHAR2,
           p_state            VARCHAR2,
           p_year             NUMBER
           ) IS
              SELECT cost,
                theoretical_nbv,
                evaluated_nbv,
                year,
                units_assigned
                FROM FA_DEPRN_TAX_REP_NBVS dtn
                WHERE dtn.asset_id = p_asset_id
                AND dtn.book_type_code = p_book_type_code
                AND dtn.state = p_state
                AND dtn.year = p_year;


        h_up_cost            NUMBER;
        h_up_last_cost       NUMBER;
        h_up_tax_asset_type  VARCHAR2(15);
        h_up_units_assigned  NUMBER;
        h_up_life            NUMBER;
        h_up_theoretical_nbv NUMBER;
        h_up_evaluated_nbv   NUMBER;
        h_up_year            NUMBER;
        h_up_nbv_flag        VARCHAR2(1);
        h_last_up_flag       VARCHAR2(1);
        l_start_loop         number;
        h_store_theoretical_nbv NUMBER;
        h_store_evaluated_nbv   NUMBER;

        l_state_query         VARCHAR2(1000);
        v_state_cursor        NUMBER;
        v_state_return        NUMBER;
        v_state_fetch         NUMBER;
        h_state_range         VARCHAR2(150);
        h_state_flag          VARCHAR2(1);
        h_deprn_tax_rep_nbv_id      NUMBER(15);

        BOTH_NBV_ERROR       EXCEPTION;
        --
        -- bug#2629893: Treate the transfer NBV distributions
        h_tmp_units_assigned       NUMBER;
        dist_asset_id              NUMBER(15);
        dist_year                  NUMBER;
        dist_total_cost            NUMBER; -- bug#2661575
        dist_total_evaluated_nbv   NUMBER;
        dist_total_theoretical_nbv NUMBER;
        dist_last_total_units      NUMBER; -- bug#2661575
        dist_total_units           NUMBER;
        dist_units_assigned        NUMBER;
        h_abs_units                NUMBER;  -- Output variable
        h_last_nbv_total_flag      VARCHAR2(1); -- flag for c_last_nbv_total

        CURSOR c_last_nbv_total (
                 p_asset_id         NUMBER,
                 p_book_type_code   VARCHAR2,
                 p_year             NUMBER
         )
         is
          SELECT sum(dtn.cost),   -- bug#2661575
                 sum(dtn.evaluated_nbv),
                 sum(dtn.theoretical_nbv),
                 sum(dtn.units_assigned),  -- bug#2661575
                 dtn.year
          FROM   FA_DEPRN_TAX_REP_NBVS dtn
          WHERE  asset_id       = p_asset_id
          AND    book_type_code = p_book_type_code
          AND    year =
                 (SELECT MAX(year) FROM fa_deprn_tax_rep_nbvs dtn2
                 WHERE dtn2.asset_id = p_asset_id
                 AND dtn2.book_type_code = p_book_type_code
                 AND dtn2.year < p_year)
          group by dtn.year;

        --
        -- Get total asset untis from FA_ASSET_HISTORY at target_date
        CURSOR c_total_units_cost (
                 p_book_type_code   VARCHAR2,
                 p_asset_id         NUMBER,
                 p_target_date      DATE)

        is
          select AH.UNITS,
                 bk.cost
          from   FA_ASSET_HISTORY AH,
                 FA_BOOKS         BK
          Where AH.ASSET_ID = p_asset_id
          and   AH.ASSET_ID = BK.ASSET_ID
          and   BK.BOOK_TYPE_CODE = p_book_type_code
          and   AH.DATE_EFFECTIVE =
           (select max(AH.DATE_EFFECTIVE )
            from   FA_ASSET_HISTORY AH,
                   FA_TRANSACTION_HEADERS TH1,
                   FA_TRANSACTION_HEADERS TH2
            where  AH.ASSET_ID = p_asset_id
            and    AH.TRANSACTION_HEADER_ID_IN =TH1.TRANSACTION_HEADER_ID
            and    AH.TRANSACTION_HEADER_ID_OUT=TH2.TRANSACTION_HEADER_ID(+)
            and    TH1.TRANSACTION_DATE_ENTERED <= p_target_date
            and    nvl(TH2.TRANSACTION_DATE_ENTERED,p_target_date +1)
                                             > p_target_date
           )
          and    bk.date_effective =
                (SELECT MAX(bk.date_effective)
                 from   FA_BOOKS bk ,
                        FA_TRANSACTION_HEADERS TH1,
                        FA_TRANSACTION_HEADERS TH2
                 where  bk.asset_id= p_asset_id
                 and    bk.book_type_code= p_book_type_code
                 and    BK.transaction_header_id_in = TH1.transaction_header_id
                 and    bk.transaction_header_id_out= TH2.transaction_header_id (+)
                 and    th1.transaction_date_entered <= p_target_date
                 and    nvl(th2.transaction_date_entered,p_target_date+1) > p_target_date
                );



      -- Exception message
      l_calling_fn            varchar2(50) :='fa_deprn_tax_rep_pkg.fadptx_insert';
      err_msg                 varchar2(100);

      -- Check the values of theoretical nbv and evaluated nbv on all states
      l_chk_nbv_total         number;
      l_chk_theoretical_nbv   number;
      l_chk_evaluated_nbv     number;


     -- For calling upgrade package
     v_MigCursor        number;
     l_MigString        varchar2(1500);
     v_MigReturn        number;
     no_package2        exception;
     PRAGMA EXCEPTION_INIT (no_package2, -6550);

-- Bug#3327616
-- New corsur to query MAX amounts separated from main SQL
cursor c_bk_max_date_effective(p_asset_id number,
                               p_book     varchar2,
                               p_prior_date date) is
SELECT MAX(bk.date_effective)
  from FA_BOOKS bk ,
       FA_TRANSACTION_HEADERS TH1,
       FA_TRANSACTION_HEADERS TH2
 where bk.asset_id= p_asset_id
   and bk.book_type_code= p_book
   and BK.transaction_header_id_in = TH1.transaction_header_id
   and bk.transaction_header_id_out= TH2.transaction_header_id (+)
   and th1.transaction_date_entered <= p_prior_date
   and nvl(th2.transaction_date_entered,p_prior_date+1) > p_prior_date;

cursor c_ah_max_date_effective(p_asset_id  number,
                               p_prior_date date) is
SELECT MAX(ah1.date_effective)
  from FA_ASSET_HISTORY ah1 ,
       FA_TRANSACTION_HEADERS TH1,
       FA_TRANSACTION_HEADERS TH2
 where ah1.asset_id= p_asset_id
   and ah1.transaction_header_id_in = TH1.transaction_header_id
   and ah1.transaction_header_id_out= TH2.transaction_header_id (+)
   and th1.transaction_date_entered <= p_prior_date
   and nvl(th2.transaction_date_entered, p_prior_date+1) > p_prior_date;

h_prior_bk_date_effective    date;
h_prior_ah_date_effective    date;
h_target_bk_date_effective   date;

cursor c_sum_nbvs_cost(p_asset_id number,
                      p_book     varchar2,
                      p_year     number) is
SELECT SUM(cost),asset_id
  from FA_DEPRN_TAX_REP_NBVS
 where book_type_code = p_book
   and asset_id = p_asset_id
   and year = p_year
group by asset_id;

h_sum_nbvs_cost  number;
h_sum_nbvs_asset_id number;

/* Bug3859151 */
/* Need to check THIDIN with Date Effective to support same date-time case */
cursor c_bk_max_thid_in(p_asset_id number,
                        p_book     varchar2,
                        p_date_effective date) is
SELECT MAX(bk.transaction_header_id_in)
  from FA_BOOKS bk
 where bk.asset_id= p_asset_id
   and bk.book_type_code= p_book
   and bk.date_effective = p_date_effective;

cursor c_ah_max_thid_in(p_asset_id  number,
                        p_date_effective date) is
SELECT MAX(ah1.transaction_header_id_in)
  from FA_ASSET_HISTORY ah1
 where ah1.asset_id= p_asset_id
   and ah1.date_effective = p_date_effective;

h_prior_bk_thid_in      number;
h_prior_ah_thid_in      number;
h_target_bk_thid_in     number;

--Bug6200581
h_current_state_flag     varchar2(1);
l_transfer_sql           varchar2(3000);  -- Bug 9071204
v_TransferCursor         number;
v_TransferFetch          number;
v_TransferReturn         number;

-- ER 7661628
-- To insert a record for tax authority code without any assets so that the asset types are displayed.
cursor c_missing_states(p_request_id number,
                        p_book       varchar2,
                        p_state_from varchar2,
                        p_state_to   varchar2) is
select ffv.flex_value
from fnd_flex_value_sets ffvs,
     fnd_flex_values ffv,
     fnd_flex_values_tl ffvt
where ffvs.flex_value_set_id = ffv.flex_value_set_id
and ffv.flex_value_id        = ffvt.flex_value_id
and ffvs.flex_value_set_name = 'Vision FA State'
and ffvt.language            = 'US'
and flex_value between p_state_from and p_state_to
and ffv.flex_value not in (select distinct state
                           from   fa_deprn_Tax_rep_itf
                           where  request_id = p_request_id)
and ffv.flex_value in (select fdta.code
                       from   fa_deprn_tax_entities fdte,
                              fa_deprn_tax_Authorities fdta
                       where  fdte.company_id = fdta.company_id  -- Bug 8677658
                       and    fdte.book_type_code    = p_book)
order by ffv.flex_value;
-- End ER 7661628

begin

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug ('*****START FA_DEPRN_TAX_REP_PKG.FADPTX_INSERT*****');
END IF;


/*======================================================================
        SET DEFALUT

        h_target_date : This is target date to print all report.
                        And end date to print addition and decrease
                        report.
        h_prior_date :  This is start date to print addition and
                        decrease report.
======================================================================*/

errbuf :=null;
retcode := 0;
h_year := year;
h_book := book;

h_category_from := category_from;
h_category_to   := category_to;
h_target_date := to_date('01-01-'||h_year,'DD-MM-YYYY');
/*
   bug 1978681
   Prior date is changed '01-JAN' from '02-JAN'
*/
h_prior_date := to_date('01-01-'||(h_year-1),'DD-MM-YYYY');

/* Bug#3305784 - Enhancement to make flexfield segment flexible */
h_tax_asset_type_segment := nvl(tax_asset_type_seg,'MINOR_CATEGORY');

h_request_id := request_id;
h_login_id := login_id;

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Book: '||h_book);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Year: '||h_year);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****State from: '||state_from);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****State to :'||state_to);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Tax Asset Type Segment: '||h_tax_asset_type_segment);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Category low: '||h_category_from);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Category high: '||h_category_to);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Target date: '||h_target_date);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Prior date: '||h_prior_date);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Request id: '||h_request_id);
        fa_rx_util_pkg.debug('fadptx_insert: ' || '*****login id: '||h_login_id);
        -- bug4919991
        if (rounding) then
           fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Round: Y');
        else
           fa_rx_util_pkg.debug('fadptx_insert: ' || '*****Round: N');
        end if;
END IF;

        /* Get Distribution Source CORPORATE BOOK */

Select  DISTRIBUTION_SOURCE_BOOK
Into    h_corp_book
From    FA_BOOK_CONTROLS
where   BOOK_TYPE_CODE =h_book;

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Distribution Source Book : '||h_corp_book);
END IF;

        /* Get Category FF and Loacation FF ,Currency information */

SELECT  SOB.CURRENCY_CODE,
        SC.COMPANY_NAME,
        SC.CATEGORY_FLEX_STRUCTURE,
        SC.LOCATION_FLEX_STRUCTURE
INTO    h_currency_code,
        h_company_name,
        cat_flex_struct,
        loc_flex_struct
FROM    FA_SYSTEM_CONTROLS      SC,
        FA_BOOK_CONTROLS        BC,
        GL_SETS_OF_BOOKS        SOB
WHERE   BC.BOOK_TYPE_CODE = h_book
and     SOB.SET_OF_BOOKS_ID = BC.SET_OF_BOOKS_ID;

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Currency Code: '||h_currency_code);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Category struct id: '||cat_flex_struct);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Location struct id: '||loc_flex_struct);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Company Name: '||h_company_name);
END IF;

        /* Get FA_LOOKUP CODE values */
select  meaning
into    r_change_life_desc
from    FA_LOOKUPS
where   lookup_type = 'JP_REASON_TYPE'
and     lookup_code = 'CHANGE LIFE';

        /* Get Precision */
FND_CURRENCY.GET_INFO(
        currency_code   => h_currency_code,
        precision       => h_precision,
        ext_precision   => h_ext_precision,
        min_acct_unit   => h_min_acct_unit
);

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Precision: '||h_currency_code);
END IF;

        /* Get Minor Category Segment */
/* Bug#3305764 - Enhancement to make flexfield segment flexible */
/* Changed hard-coded 'MINOR_CATEGORY' to h_tax_Asset_type_segment */
l_parm_minor := fa_rx_flex_pkg.flex_sql(140,'CAT#', cat_flex_struct,'CAT',
'SELECT', h_tax_asset_type_segment);

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Tax Asset Type Category Segment: '||l_parm_minor);
END IF;

        /* Get Location Segment */
l_parm_state := fa_rx_flex_pkg.flex_sql(140,'LOC#', loc_flex_struct,'LOC',
'SELECT', 'LOC_STATE');

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'State Segment: '||l_parm_state);
END IF;

/*============================================================================
        Dynamic SQL valiable set

The followings are Dynamic SQL.
This query diagram image is,

              +------------------+
     +--------|FA_LOCATIONS(LOC) |
     |        +------------------+
     |               |
     |               |
     |     +----------------------------+
     |     |FA_DISTRIBUTION_HISTORY(DH) |----|
     |     +----------------------------+    |
     |                                       | +-----------------------------+
     |                                       |-|FA_TRANSACTION_HEADERS (THD1)|
     |                                       | +-----------------------------+
     |                                       |
     |                                       | +-----------------------------+
     |                                       |-|FA_TRANSACTION_HEADERS (THD2)|
     |                                         +-----------------------------+
     |
     |              +-----------------+    +----------------------+
     |--------------|FA_ADDITIONS (AD)|----|FA_ASSET_HISTORY (AH) |
     |              +-----------------+    +----------------------+
     |                     |                 |
+--------------+           |                 | +--------------------+
|TEMP VIEW (SM)|           |                 |-|FA_CATEGORIES (CAT) |
+--------------+           |                 | +--------------------+
     |                     |                 |
     |                     |                 |
     |                     |                 | +-----------------------------+
     |                     |                 |-|FA_TRANSACTION_HEADERS (THA1)|
     |                     |                 | +-----------------------------+
     |                     |                 |
     |                     |                 | +-----------------------------+
     |                     |                 |-|FA_TRANSACTION_HEADERS (THA2)|
     |                     |                   +-----------------------------+
     |              +-------------+            +-----------------------------+
     |--------------|FA_BOOKS(BK) |------------|FA_METHODS (MTH)             |
                    +-------------+     |      +-----------------------------+
                                        |      +-----------------------------+
                                        |------|FA_TRANSACTION_HEADERS (THB1)|
                                        |      +-----------------------------+
                                        |
                                        |      +-----------------------------+
                                        |------|FA_TRANSACTION_HEADERS (THB2)|
                                               +-----------------------------+

TMEP VIEW(SM) is not database view.
And this is BK.COST and DH.UNITS_ASSIGNED
group by asset_id, book_type_code, state.
=============================================================================*/
l_select_sm :=
'Select
        AD.ASSET_ID             ASSET_ID,
        BK.BOOK_TYPE_CODE       BOOK_TYPE_CODE,
        BK.COST                 SUM_COST,
        '||l_parm_state||'      STATE,
        SUM(DH.UNITS_ASSIGNED)  SUM_UNITS_ASSIGNED ';

l_select_base :=
'Select
        AD.ASSET_ID     ASSET_ID,
        AD.ASSET_NUMBER ASSET_NUMBER,
        AD.DESCRIPTION  ASSET_DESCRIPTION,
        AD.NEW_USED     NEW_USED,
        BK.BOOK_TYPE_CODE       BOOK_TYPE_CODE,
        '||l_parm_minor||'      MINOR_CATEGORY,
        substr('||l_parm_minor||',1,1) TAX_ASSET_TYPE,
        SM.STATE                STATE,
        AH.UNITS                UNITS,
        SM.SUM_UNITS_ASSIGNED   UNITS_ASSIGNED,
        SM.SUM_COST             COST,
        BK.DATE_PLACED_IN_SERVICE       DATE_PLACED_IN_SERVICE,
        decode(to_char(decode (to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'', BK.DATE_PLACED_IN_SERVICE -1,BK.DATE_PLACED_IN_SERVICE),
                ''E'',''nls_calendar=''''Japanese Imperial''''''),
                ''M'',''1'',''T'',''2'',''S'',''3'',''H'',''4'',''0'') ERA_NAME_NUM,
        to_number(to_char(decode (to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'', BK.DATE_PLACED_IN_SERVICE -1,BK.DATE_PLACED_IN_SERVICE),
                ''YY'',''nls_calendar=''''Japanese Imperial'''''')) ADD_ERA_YEAR,
        decode(to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'',to_number(to_char(BK.DATE_PLACED_IN_SERVICE,''YYYY''))-1,
                to_number(to_char(BK.DATE_PLACED_IN_SERVICE,''YYYY''))) ADD_YEAR,
        decode(to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'',12,
                to_number(to_char(BK.DATE_PLACED_IN_SERVICE,''MM''))) ADD_MONTH,
        to_number(translate(MTH.METHOD_CODE,''JP-DBYR'',''       ''))   LIFE,
        BK.ADJUSTED_RATE        ADJUSTED_RATE ';

l_select_base_ba2 :=
'Select
        AD.ASSET_ID     ASSET_ID,
        AD.ASSET_NUMBER ASSET_NUMBER,
        AD.DESCRIPTION  ASSET_DESCRIPTION,
        AD.NEW_USED     NEW_USED,
        BK.BOOK_TYPE_CODE       BOOK_TYPE_CODE,
        decode(NBV.MINOR_CATEGORY,NULL,decode(NBV.TAX_ASSET_TYPE,substr('||l_parm_minor||',1,1),'||l_parm_minor||',
                                                                 nvl(NBV.TAX_ASSET_TYPE,'||l_parm_minor||'))
                                 ,NBV.MINOR_CATEGORY)   MINOR_CATEGORY,
        decode(NBV.MINOR_CATEGORY,NULL,nvl(NBV.TAX_ASSET_TYPE,substr('||l_parm_minor||',1,1)),
                                       substr(NBV.MINOR_CATEGORY,1,1)) TAX_ASSET_TYPE,
        decode(NBV.ASSET_ID,NULL,SM.STATE,NBV.STATE)    STATE,
        AH.UNITS                UNITS,
        decode(NBV.ASSET_ID,NULL,SM.SUM_UNITS_ASSIGNED,
                                 NBV.UNITS_ASSIGNED)    UNITS_ASSIGNED,
        decode(NBV.ASSET_ID,NULL,SM.SUM_COST,
                                 decode(nvl(BK.COST,0),0,:p_sum_nbvs_cost,SM.SUM_COST)) COST,
        BK.DATE_PLACED_IN_SERVICE       DATE_PLACED_IN_SERVICE,
        decode(to_char(decode (to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'', BK.DATE_PLACED_IN_SERVICE -1,BK.DATE_PLACED_IN_SERVICE),
                ''E'',''nls_calendar=''''Japanese Imperial''''''),
                ''M'',''1'',''T'',''2'',''S'',''3'',''H'',''4'',''0'') ERA_NAME_NUM,
        to_number(to_char(decode (to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'', BK.DATE_PLACED_IN_SERVICE -1,BK.DATE_PLACED_IN_SERVICE),
                ''YY'',''nls_calendar=''''Japanese Imperial'''''')) ADD_ERA_YEAR,
        decode(to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'',to_number(to_char(BK.DATE_PLACED_IN_SERVICE,''YYYY''))-1,
                to_number(to_char(BK.DATE_PLACED_IN_SERVICE,''YYYY''))) ADD_YEAR,
        decode(to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'',12,
                to_number(to_char(BK.DATE_PLACED_IN_SERVICE,''MM''))) ADD_MONTH,
        to_number(translate(MTH.METHOD_CODE,''JP-DBYR'',''       ''))   LIFE,
        BK.ADJUSTED_RATE        ADJUSTED_RATE,
        NBV.ACTION_FLAG         ACTION_FLAG  ';

-- For both start and end date select statement
-- BA1:end date base table, BA2: start date base table

l_select_both :=
'Select BA1.ASSET_ID                    ASSET_ID,
        BA1.ASSET_NUMBER                ASSET_NUMBER,
        BA1.ASSET_DESCRIPTION           ASSET_DESCRIPTION,
        BA1.NEW_USED                    NEW_USED,
        BA1.BOOK_TYPE_CODE              BOOK_TYPE_CODE,
        BA1.MINOR_CATEGORY              MINOR_CATEGORY,
        BA1.TAX_ASSET_TYPE              TAX_ASSET_TYPE,
        BA1.STATE                       STATE,
        decode(NBV1.ASSET_ID,NULL,0,BA2.UNITS)  START_UNITS,
        BA1.UNITS                       END_UNITS,
        decode(NBV1.ASSET_ID,NULL,0,BA2.UNITS_ASSIGNED)         START_UNITS_ASSIGNED,
        BA1.UNITS_ASSIGNED              END_UNITS_ASSIGNED,
        decode(NBV1.ASSET_ID,NULL,0,BA2.COST)                   START_COST,
        BA1.COST                        END_COST,
        BA1.DATE_PLACED_IN_SERVICE      DATE_PLACED_IN_SERVICE,
        BA1.ERA_NAME_NUM                ERA_NAME_NUM,
        BA1.ADD_ERA_YEAR                ADD_ERA_YEAR,
        BA1.ADD_YEAR                    ADD_YEAR,
        BA1.ADD_MONTH                   ADD_MONTH,
        BA2.LIFE                        START_LIFE,
        BA1.LIFE                        END_LIFE,
        BA1.ADJUSTED_RATE               ADJUSTED_RATE,
        abs(BA1.UNITS_ASSIGNED - BA2.UNITS_ASSIGNED)  ABS_UNITS'; -- Added for bug#2629893

l_select_end :=
'Select BA1.ASSET_ID                    ASSET_ID,
        BA1.ASSET_NUMBER                ASSET_NUMBER,
        BA1.ASSET_DESCRIPTION           ASSET_DESCRIPTION,
        BA1.NEW_USED                    NEW_USED,
        BA1.BOOK_TYPE_CODE              BOOK_TYPE_CODE,
        BA1.MINOR_CATEGORY              MINOR_CATEGORY,
        BA1.TAX_ASSET_TYPE              TAX_ASSET_TYPE,
        BA1.STATE                       STATE,
        nvl(BA2.UNITS,0)                START_UNITS,
        nvl(BA1.UNITS,0)                END_UNITS,
        nvl(BA2.UNITS_ASSIGNED,0)       START_UNITS_ASSIGNED,
        nvl(BA1.UNITS_ASSIGNED,0)       END_UNITS_ASSIGNED,
        nvl(BA2.COST,0)                 START_COST,
        nvl(BA1.COST,0)                 END_COST,
        BA1.DATE_PLACED_IN_SERVICE      DATE_PLACED_IN_SERVICE,
        BA1.ERA_NAME_NUM                ERA_NAME_NUM,
        BA1.ADD_ERA_YEAR                ADD_ERA_YEAR,
        BA1.ADD_YEAR                    ADD_YEAR,
        BA1.ADD_MONTH                   ADD_MONTH,
        nvl(BA2.LIFE,to_number(null))   START_LIFE,
        nvl(BA1.LIFE,to_number(null))   END_LIFE,
        BA1.ADJUSTED_RATE               ADJUSTED_RATE,
        abs(nvl(BA1.UNITS_ASSIGNED,0) - nvl(BA2.UNITS_ASSIGNED,0))  ABS_UNITS,
        BA2.ACTION_FLAG                 ACTION_FLAG
';

l_select_start :=
'Select decode(BA1.ASSET_ID,NULL,BA2.ASSET_ID,
                                 BA1.ASSET_ID)          ASSET_ID,
        decode(BA1.ASSET_ID,NULL,BA2.ASSET_NUMBER,
                                 BA1.ASSET_NUMBER)      ASSET_NUMBER,
        decode(BA1.ASSET_ID,NULL,BA2.ASSET_DESCRIPTION,
                                 BA1.ASSET_DESCRIPTION) ASSET_DESCRIPTION,
        decode(BA1.ASSET_ID,NULL,BA2.NEW_USED,
                                 BA1.NEW_USED)          NEW_USED,
        decode(BA1.ASSET_ID,NULL,BA2.BOOK_TYPE_CODE,
                                 BA1.BOOK_TYPE_CODE)    BOOK_TYPE_CODE,
        decode(BA1.ASSET_ID,NULL,BA2.MINOR_CATEGORY,
                                 BA1.MINOR_CATEGORY)    MINOR_CATEGORY,
        decode(BA1.ASSET_ID,NULL,BA2.TAX_ASSET_TYPE,
                                 BA1.TAX_ASSET_TYPE)    TAX_ASSET_TYPE,
        decode(BA1.ASSET_ID,NULL,BA2.STATE,BA1.STATE)   STATE,
        nvl(BA2.UNITS,0)                                START_UNITS,
        nvl(BA1.UNITS,0)                                END_UNITS,
        nvl(BA2.UNITS_ASSIGNED,0)                       START_UNITS_ASSIGNED,
        nvl(BA1.UNITS_ASSIGNED,0)                       END_UNITS_ASSIGNED,
        nvl(BA2.COST,0)                                 START_COST,
        nvl(BA1.COST,0)                                 END_COST,
        decode(BA1.ASSET_ID,NULL,BA2.DATE_PLACED_IN_SERVICE,
                                 BA1.DATE_PLACED_IN_SERVICE)    DATE_PLACED_IN_SERVICE,
        decode(BA1.ASSET_ID,NULL,BA2.ERA_NAME_NUM,
                                 BA1.ERA_NAME_NUM)      ERA_NAME_NUM,
        decode(BA1.ASSET_ID,NULL,BA2.ADD_ERA_YEAR,
                                 BA1.ADD_ERA_YEAR)      ADD_ERA_YEAR,
        decode(BA1.ASSET_ID,NULL,BA2.ADD_YEAR,
                                 BA1.ADD_YEAR)          ADD_YEAR,
        decode(BA1.ASSET_ID,NULL,BA2.ADD_MONTH,
                                 BA1.ADD_MONTH)         ADD_MONTH,
        nvl(BA2.LIFE,to_number(null))                   START_LIFE,
        nvl(BA1.LIFE,to_number(null))                   END_LIFE,
        decode(BA1.ASSET_ID,NULL,BA2.ADJUSTED_RATE,
                                 BA1.ADJUSTED_RATE)     ADJUSTED_RATE,
        abs(nvl(BA1.UNITS_ASSIGNED,0) - nvl(BA2.UNITS_ASSIGNED,0))  ABS_UNITS,
        BA2.ACTION_FLAG                                 ACTION_FLAG
';

l_from_stmt :=
' From
        FA_ADDITIONS            AD,
        FA_BOOKS                BK,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_TRANSACTION_HEADERS THA1,
        FA_TRANSACTION_HEADERS THA2,
        FA_TRANSACTION_HEADERS THB1,
        FA_TRANSACTION_HEADERS THB2,
        FA_TRANSACTION_HEADERS THD1,
        FA_TRANSACTION_HEADERS THD2,
        FA_CATEGORIES           CAT,
        FA_LOCATIONS            LOC,
        FA_METHODS              MTH
';

l_from_stmt_ba2 :=
'       , FA_DEPRN_TAX_REP_NBVS NBV
';

l_sm_where :=
        ' where
        AD.ASSET_ID = BK.ASSET_ID
and     AD.ASSET_ID = DH.ASSET_ID
and     AD.ASSET_ID = AH.ASSET_ID
and     DH.BOOK_TYPE_CODE = :p_corp_book
and     BK.DEPRN_METHOD_CODE = MTH.METHOD_CODE
and     AH.CATEGORY_ID = CAT.CATEGORY_ID
and     DH.LOCATION_ID = LOC.LOCATION_ID
and     AH.transaction_header_id_in =THA1.transaction_header_id
and     AH.transaction_header_id_out=THA2.transaction_header_id(+)
and     BK.transaction_header_id_in =THB1.transaction_header_id
and     BK.transaction_header_id_out=THB2.transaction_header_id(+)
and     DH.transaction_header_id_in =THD1.transaction_header_id
and     DH.transaction_header_id_out=THD2.transaction_header_id(+)
and     AH.ASSET_TYPE <>  ''EXPENSED''
and     AD.ASSET_ID = :p_asset_id
and     BK.BOOK_TYPE_CODE = :p_book
and     THA1.TRANSACTION_DATE_ENTERED <= :p_target_date
and     nvl(THA2.TRANSACTION_DATE_ENTERED,:p_target_date+1) > :p_target_date
and     THB1.TRANSACTION_DATE_ENTERED <= :p_target_date
and     nvl(THB2.TRANSACTION_DATE_ENTERED,:p_target_date+1) > :p_target_date
and     THD1.TRANSACTION_DATE_ENTERED <= :p_target_date
and     nvl(THD2.TRANSACTION_DATE_ENTERED,:p_target_date+1) > :p_target_date
and     MTH.METHOD_CODE like :p_method_code
and     MTH.RATE_SOURCE_RULE =''FLAT''
and     MTH.CREATED_BY = 1 -- Added to avoid customized method use
and not (BK.period_counter_fully_retired is not null and BK.COST=0)
and     '||l_parm_minor||' between :p_category_from and :p_category_to
AND     bk.date_effective = :p_target_bk_date_effective
AND     bk.transaction_header_id_in = :p_target_bk_thid_in -- Bug3859151
';

l_where_ba2 :=
' and     NBV.BOOK_TYPE_CODE(+) = :p_book
and     NBV.ASSET_ID(+) = :p_asset_id
and     NBV.YEAR(+) = :p_year - 1
and     '||l_parm_state||' = NBV.STATE(+)
';

--------------------------------------------------------------------------------
-- Following parts are added to restruct the logic for Deprn Asset Tax report --
--------------------------------------------------------------------------------
l_select_nbv :=
'Select
        AD.ASSET_ID     ASSET_ID,
        AD.ASSET_NUMBER ASSET_NUMBER,
        AD.DESCRIPTION  ASSET_DESCRIPTION,
        AD.NEW_USED     NEW_USED,
        BK.BOOK_TYPE_CODE       BOOK_TYPE_CODE,
        decode(NBV.MINOR_CATEGORY,NULL,decode(NBV.TAX_ASSET_TYPE,substr('||l_parm_minor||',1,1),'||l_parm_minor||',
                                                                 nvl(NBV.TAX_ASSET_TYPE,'||l_parm_minor||'))
                                 ,NBV.MINOR_CATEGORY)   MINOR_CATEGORY,
        decode(NBV.MINOR_CATEGORY,NULL,nvl(NBV.TAX_ASSET_TYPE,substr('||l_parm_minor||',1,1)),
                                       substr(NBV.MINOR_CATEGORY,1,1)) TAX_ASSET_TYPE,
        NBV.STATE               STATE,
        AH.UNITS                UNITS,
        NBV.UNITS_ASSIGNED      UNITS_ASSIGNED,
        decode(nvl(BK.COST,0),0,:p_sum_nbvs_cost,BK.COST)       COST, -- Bug3975288 Changed from BK.COST
        BK.DATE_PLACED_IN_SERVICE       DATE_PLACED_IN_SERVICE,
        decode(to_char(decode (to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'', BK.DATE_PLACED_IN_SERVICE -1,BK.DATE_PLACED_IN_SERVICE),
                ''E'',''nls_calendar=''''Japanese Imperial''''''),
                ''M'',''1'',''T'',''2'',''S'',''3'',''H'',''4'',''0'') ERA_NAME_NUM,
        to_number(to_char(decode (to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'', BK.DATE_PLACED_IN_SERVICE -1,BK.DATE_PLACED_IN_SERVICE),
                ''YY'',''nls_calendar=''''Japanese Imperial'''''')) ADD_ERA_YEAR,
        decode(to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'',to_number(to_char(BK.DATE_PLACED_IN_SERVICE,''YYYY''))-1,
                to_number(to_char(BK.DATE_PLACED_IN_SERVICE,''YYYY''))) ADD_YEAR,
        decode(to_char(BK.DATE_PLACED_IN_SERVICE,''MM-DD''),
                ''01-01'',12,
                to_number(to_char(BK.DATE_PLACED_IN_SERVICE,''MM''))) ADD_MONTH,

        to_number(translate(MTH.METHOD_CODE,''JP-DBYR'',''       ''))   LIFE,
        BK.ADJUSTED_RATE        ADJUSTED_RATE,
        NBV.ACTION_FLAG         ACTION_FLAG ';

l_from_nbv :=
'From
        FA_ADDITIONS            AD,
        FA_BOOKS                BK,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORIES           CAT,
        FA_METHODS              MTH,
        FA_DEPRN_TAX_REP_NBVS   NBV
';

l_nbv_where :=
        ' where
        AD.ASSET_ID = BK.ASSET_ID
and     AD.ASSET_ID = AH.ASSET_ID
and     BK.DEPRN_METHOD_CODE = MTH.METHOD_CODE
and     AH.CATEGORY_ID = CAT.CATEGORY_ID
and     AH.ASSET_TYPE <>  ''EXPENSED''
and     AD.ASSET_ID = :p_asset_id
and     BK.BOOK_TYPE_CODE = :p_book
and     NBV.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
and     NBV.ASSET_ID = AD.ASSET_ID
and     NBV.YEAR = :p_year - 1
and     MTH.METHOD_CODE like :p_method_code
and     MTH.RATE_SOURCE_RULE =''FLAT''
and     MTH.CREATED_BY = 1 -- Added to avoid customized method use
and not (BK.period_counter_fully_retired is not null and BK.COST=0)
and     nvl(NBV.MINOR_CATEGORY,'||l_parm_minor||') between :p_category_from and :p_category_to
AND bk.date_effective = :p_prior_bk_date_effective
AND bk.transaction_header_id_in = :p_prior_bk_thid_in -- Bug3859151
AND ah.date_effective = :p_prior_ah_date_effective
AND ah.transaction_header_id_in = :p_prior_ah_thid_in -- Bug3859151
';

------------------------------
-- End of Restructure Logic --
------------------------------

l_group_by :=' group by AD.ASSET_ID,BK.BOOK_TYPE_CODE,BK.COST, '||l_parm_state;

        /* set temporary view SM as variable */

l_parm_view :='('||l_select_sm||l_from_stmt||l_sm_where||l_group_by||') ';

l_base_where := l_sm_where
                ||'and  SM.ASSET_ID = AD.ASSET_ID
                and     SM.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
                and     '||l_parm_state||' = SM.STATE'
                ;


--

/*===========================================================================
Set Select Statement:
 This query is at target date.
===========================================================================*/

l_base_from := l_from_stmt||','||l_parm_view||' SM ';

sql_base := l_select_base||l_base_from||l_base_where;
sql_base_ba2 := l_select_base_ba2||l_base_from||l_from_stmt_ba2||l_base_where||l_where_ba2;
sql_nbv := l_select_nbv||l_from_nbv||l_nbv_where;

 Loop

    --  l_main(k) := substrb(fa_deprn_tax_rep_pkg.debug(    -- bug#2434220
        l_main(k) := fa_deprn_tax_rep_pkg.debug(substrb(
                l_select_end||' from ('||sql_base||') BA1,
                ('||replace(sql_base_ba2,':p_target_',':p_prior_')||'
                  UNION '||sql_nbv||') BA2
                where BA1.ASSET_ID=BA2.ASSET_ID (+)
                and     BA1.BOOK_TYPE_CODE = BA2.BOOK_TYPE_CODE (+)
                and     BA1.TAX_ASSET_TYPE = BA2.TAX_ASSET_TYPE (+)
                and     BA1.STATE = BA2.STATE (+)
                and not (BA1.COST=0 AND nvl(BA2.COST,-1)=0)
                union '||l_select_start||' from ('||sql_base||') BA1,
                ('||replace(sql_base_ba2,':p_target_',':p_prior_')||'
                  UNION '||sql_nbv||') BA2
                where BA1.ASSET_ID (+)=BA2.ASSET_ID
                and     BA1.BOOK_TYPE_CODE (+)= BA2.BOOK_TYPE_CODE
                and     BA1.TAX_ASSET_TYPE (+)= BA2.TAX_ASSET_TYPE
                and     BA1.STATE (+)= BA2.STATE
                and not (nvl(BA1.COST,-1)=0 AND BA2.COST=0)
                order by ASSET_ID, BOOK_TYPE_CODE,ABS_UNITS,STATE' -- Added ABS_UNITS for bug#2629893
--              ,k),256*k+1,256); -- bug#2434220
                ,256*k+1,256),k);

                if l_main(k) is null then
                        EXIT;
                end if;
        k := k+1;
 End Loop;

fa_rx_util_pkg.debug('debug: ***** Main SQL: *******');

/* Bug3896299 - Performance Fix */
/* Changed sub_sql to check the state range */
l_sub_sql :=
'Select distinct
        BK.ASSET_ID
From    FA_BOOKS BK,
        FA_ADDITIONS AD,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY AH,
        FA_LOCATIONS LOC,
        FA_CATEGORIES CAT,
        FA_METHODS MTH,
        FA_TRANSACTION_HEADERS TH1,
        FA_TRANSACTION_HEADERS TH2,
        FA_TRANSACTION_HEADERS TH_DH1,
        FA_TRANSACTION_HEADERS TH_DH2,
        FA_TRANSACTION_HEADERS TH_AH1,
        FA_TRANSACTION_HEADERS TH_AH2
Where   AD.ASSET_ID = BK.ASSET_ID
and     BK.BOOK_TYPE_CODE =:p_book
and     AD.ASSET_TYPE <>  ''EXPENSED''
and     AD.ASSET_ID = DH.ASSET_ID
and     DH.BOOK_TYPE_CODE = :p_corp_book
and     DH.LOCATION_ID = LOC.LOCATION_ID
and     '||l_parm_state||' between :p_state_from and :p_state_to
and     DH.TRANSACTION_HEADER_ID_IN = TH_DH1.TRANSACTION_HEADER_ID
and     DH.TRANSACTION_HEADER_ID_OUT = TH_DH2.TRANSACTION_HEADER_ID(+)
and     AD.ASSET_ID = AH.ASSET_ID
and     AH.CATEGORY_ID = CAT.CATEGORY_ID
and     AH.TRANSACTION_HEADER_ID_IN = TH_AH1.TRANSACTION_HEADER_ID
and     AH.TRANSACTION_HEADER_ID_OUT = TH_AH2.TRANSACTION_HEADER_ID(+)
and     '||l_parm_minor||' between :p_category_from and :p_category_to
and     BK.DEPRN_METHOD_CODE = MTH.METHOD_CODE
and     BK.TRANSACTION_HEADER_ID_IN =TH1.TRANSACTION_HEADER_ID
and     BK.TRANSACTION_HEADER_ID_OUT=TH2.TRANSACTION_HEADER_ID(+)
and     MTH.METHOD_CODE like :p_method_code
and     MTH.RATE_SOURCE_RULE =''FLAT''
and     MTH.CREATED_BY = 1 -- Added to avoid customized method use
Having  min(TH1.TRANSACTION_DATE_ENTERED) <= :p_target_date
and     max(nvl(TH2.TRANSACTION_DATE_ENTERED,:p_prior_date+1)) > :p_prior_date
and     min(TH_DH1.TRANSACTION_DATE_ENTERED) <= :p_target_date
and     max(nvl(TH_DH2.TRANSACTION_DATE_ENTERED, :p_prior_date+1)) > :p_prior_date
and     min(TH_AH1.TRANSACTION_DATE_ENTERED) <= :p_target_date
and     max(nvl(TH_AH2.TRANSACTION_DATE_ENTERED, :p_prior_date+1)) > :p_prior_date
group by BK.ASSET_ID
UNION
select distinct asset_id
from   FA_DEPRN_TAX_REP_NBVS NBVS
where  NBVS.BOOK_TYPE_CODE = :p_book
and    NBVS.STATE between :p_state_from and :p_state_to
and    NBVS.YEAR = :p_year - 1
';
/* Bug3896299 */

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: SUB SQL: '|| l_sub_sql);
END IF;



-- Open v_SubCursor
/* v_SubCursor is created for  performance issue. the cursor fetch asset_id */

v_SubCursor := DBMS_SQL.OPEN_CURSOR;
IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ***** OPEN CURSOR: v_SubCursor *****');
        fa_rx_util_pkg.debug('fadptx_insert: v_SubCursor :'|| v_SubCursor);
END IF;

DBMS_SQL.PARSE (v_SubCursor,l_sub_sql,DBMS_SQL.V7);

DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_book',h_book);
DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_prior_date',h_prior_date);
DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_target_date',h_target_date);
DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_method_code',h_method_code);
/* Bug3896299 */
DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_corp_book',h_corp_book);
DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_state_from',state_from);
DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_state_to',state_to);
DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_category_from',h_category_from);
DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_category_to',h_category_to);
DBMS_SQL.BIND_VARIABLE(v_SubCursor,':p_year',h_year);
/* Bug3896299 */

DBMS_SQL.DEFINE_COLUMN(v_SubCursor,1,l_asset_id);

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ***** BIND/DEFINE COLUMN: v_SubCursor *****');
END IF;

v_SubReturn := DBMS_SQL.EXECUTE(v_SubCursor);
IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ***** EXECUTE: v_SubCursor *****');
        fa_rx_util_pkg.debug('fadptx_insert: v_SubReturn :'|| v_SubReturn);
END IF;

--Open v_MainCursor
/* v_MainCursor is for fetch main data */

v_MainCursor := DBMS_SQL.OPEN_CURSOR;
IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ***** OPEN CURSOR: v_MainCursor *****');
        fa_rx_util_pkg.debug('fadptx_insert: v_MainCursor :' || v_MainCursor);
END IF;

--DBMS_SQL.PARSE (v_MainCursor, main_sql,DBMS_SQL.V7);
DBMS_SQL.PARSE (v_MainCursor, l_main,0,k,FALSE,DBMS_SQL.V7);

DBMS_SQL.DEFINE_COLUMN(v_MainCursor,1,h_asset_id);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,2,h_asset_number,15);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,3,h_asset_desc,80);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,4,h_new_used,4);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,5,h_book_type_code,15);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,6,h_minor_category,150);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,7,h_tax_asset_type,15);  -- Treate UTF8
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,8,h_state,150);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,9,h_start_units_total);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,10,h_end_units_total);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,11,h_start_units_assigned);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,12,h_end_units_assigned);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,13,h_start_cost_total);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,14,h_end_cost_total);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,15,h_date_in_service);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,16,h_era_name_num,1);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,17,h_add_era_year);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,18,h_add_year);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,19,h_add_month);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,20,h_start_life);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,21,h_end_life);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,22,h_adjusted_rate);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,23,h_abs_units);
DBMS_SQL.DEFINE_COLUMN(v_MainCursor,24,h_action_flag, 1);
IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ***** DEFINE COLUMN: v_MainCursor *****');
END IF;

--
        /* Loop For v_SubCursor */

h_sum_nbvs_asset_id := -1;
 Loop
        v_SubFetch := DBMS_SQL.FETCH_ROWS(v_SubCursor);
        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('fadptx_insert: ***** FETCH LOW: v_SubCursor *****');
                fa_rx_util_pkg.debug('fadptx_insert: v_SubFetch :'||v_SubFetch);
        END IF;

        If v_SubFetch =0 then
                Exit;
        end if;

        DBMS_SQL.COLUMN_VALUE(v_SubCursor,1,l_asset_id);

        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('fadptx_insert: l_asset_id : h_sum_nbvs_asset_id'||l_asset_id||':'||h_sum_nbvs_asset_id);
        END IF;

        -- Bug#3327616
        -- Added max query instead of doing it in main SQL
        open c_bk_max_date_effective(l_asset_id,h_book,h_prior_date);
        fetch c_bk_max_date_effective into h_prior_bk_date_effective;
        close c_bk_max_date_effective;
        if h_prior_bk_date_effective is null then
          h_prior_bk_date_effective := to_date(null);
          h_prior_bk_thid_in := to_number(null); -- BUg3859151
        else -- Bug3859151
          open c_bk_max_thid_in(l_asset_id,h_book,h_prior_bk_date_effective); -- Bug3859151
          fetch c_bk_max_thid_in into h_prior_bk_thid_in; -- Bug3859151
          close c_bk_max_thid_in; -- Bug3859151
        end if;

        open c_ah_max_date_effective(l_asset_id,h_prior_date);
        fetch c_ah_max_date_effective into h_prior_ah_date_effective;
        close c_ah_max_date_effective;
        if h_prior_ah_date_effective is null then
          h_prior_ah_date_effective := to_date(null);
          h_prior_ah_thid_in := to_number(null); -- Bug3859151
        else -- Bug3859151
          open c_ah_max_thid_in(l_asset_id,h_prior_ah_date_effective); -- Bug3859151
          fetch c_ah_max_thid_in into h_prior_ah_thid_in; -- Bug3859151
          close c_ah_max_thid_in; -- Bug3859151
        end if;

        open c_bk_max_date_effective(l_asset_id,h_book,h_target_date);
        fetch c_bk_max_date_effective into h_target_bk_date_effective;
        close c_bk_max_date_effective;
        if h_target_bk_date_effective is null then
          h_target_bk_date_effective := to_date(null);
          h_target_bk_thid_in := to_number(null); -- Bug3859151
        else -- Bug3859151
          open c_bk_max_thid_in(l_asset_id,h_book,h_target_bk_date_effective); -- Bug3859151
          fetch c_bk_max_thid_in into h_target_bk_thid_in; -- Bug3859151
          close c_bk_max_thid_in; -- Bug3859151
        end if;

        if nvl(h_sum_nbvs_asset_id,-1) <> l_asset_id then
          open c_sum_nbvs_cost(l_asset_id,h_book,h_year-1);
          fetch c_sum_nbvs_cost into h_sum_nbvs_cost, h_sum_nbvs_asset_id;
          close c_sum_nbvs_cost;
          if h_sum_nbvs_cost is null then
            h_sum_nbvs_cost := 0;
          end if;
        end if;

        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('fadptx_insert: h_prior_bk_date_effective :'||to_char(h_prior_bk_date_effective,'YYYY-MON-DD HH24:MI:SS'));
                fa_rx_util_pkg.debug('fadptx_insert: h_prior_ah_date_effective :'||to_char(h_prior_ah_date_effective,'YYYY-MON-DD HH24:MI:SS'));
                fa_rx_util_pkg.debug('fadptx_insert: h_target_bk_date_effective :'||to_Char(h_target_bk_date_effective,'YYYY-MON-DD HH24:MI:SS'));
                fa_rx_util_pkg.debug('fadptx_insert: h_sum_nbvs_cost :'||h_sum_nbvs_cost);
                fa_rx_util_pkg.debug('fadptx_insert: h_prior_bk_thid_in :'||h_prior_bk_thid_in);
                fa_rx_util_pkg.debug('fadptx_insert: h_prior_ah_thid_in :'||h_prior_ah_thid_in);
                fa_rx_util_pkg.debug('fadptx_insert: h_target_bk_thid_in :'||h_target_bk_thid_in);
        END IF;

        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_asset_id',l_asset_id);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_book',h_book);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_corp_book',h_corp_book);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_target_date',h_target_date);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_prior_date', h_prior_date);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_category_from',h_category_from);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_category_to',h_category_to);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_year',h_year);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_method_code',h_method_code);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_prior_bk_date_effective',h_prior_bk_date_effective);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_prior_ah_date_effective',h_prior_ah_date_effective);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_target_bk_date_effective',h_target_bk_date_effective);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_sum_nbvs_cost',h_sum_nbvs_cost);
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_prior_bk_thid_in',h_prior_bk_thid_in); -- Bug3859151
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_prior_ah_thid_in',h_prior_ah_thid_in); -- bug3859151
        DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_target_bk_thid_in',h_target_bk_thid_in); -- Bug3859151

        v_MainReturn := DBMS_SQL.EXECUTE(v_MainCursor);
        IF (g_print_debug) THEN
                fa_rx_util_pkg.debug('fadptx_insert: ***** EXECUTE: v_MainCursor *****');
                fa_rx_util_pkg.debug('fadptx_insert: v_MainReturn :'||v_MainReturn);
        END IF;

        /* Loop For v_MainCursor */

        -- bug#2629893
        -- Initialized dist_asset_id
        -- This is moved from just before Sub_Cursor Loop
        dist_asset_id :=0;

        Loop
                -- bug#2448145: Initialized update nbv flag
                h_up_nbv_flag := 'N'; -- bug#2661575

                v_MainFetch := DBMS_SQL.FETCH_ROWS(v_MainCursor);
                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ***** FETCH LOW: v_MainCursor *****');
                        fa_rx_util_pkg.debug('fadptx_insert: v_MainFetch :'|| v_MainFetch);
                END IF;

                If v_MainFetch =0 then
                        Exit;
                end if;

                DBMS_SQL.COLUMN_VALUE(v_MainCursor,1,h_asset_id);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,2,h_asset_number);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,3,h_asset_desc);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,4,h_new_used);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,5,h_book_type_code);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,6,h_minor_category);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,7,h_tax_asset_type);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,8,h_state);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,9,h_start_units_total);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,10,h_end_units_total);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,11,h_start_units_assigned);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,12,h_end_units_assigned);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,13,h_start_cost_total);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,14,h_end_cost_total);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,15,h_date_in_service);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,16,h_era_name_num);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,17,h_add_era_year);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,18,h_add_year);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,19,h_add_month);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,20,h_start_life);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,21,h_end_life);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,22,h_adjusted_rate);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,23,h_abs_units);
                DBMS_SQL.COLUMN_VALUE(v_MainCursor,24,h_action_flag);

        /* Get Minor Category Description */
                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: h_minor_category(tax asset type) '|| h_minor_category);
                END If;

                if h_minor_category is not null then
                  h_minor_cat_desc :=
                        fa_rx_flex_pkg.get_description(
                        p_application_id => 140,
                        p_id_flex_code   => 'CAT#',
                        p_id_flex_num    => cat_flex_struct,
--                      p_qualifier      => 'MINOR_CATEGORY',
                        p_qualifier      => h_tax_asset_type_segment,  -- Bug#3305764 - Enhancement to make Category Flexfield flexible
                        p_data            => h_minor_category);

                  IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: h_minor_category(after get_description) '|| h_minor_category);
                  END If;
                end if;

--              IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: **** Queried values by MainCursor ****');
                        fa_rx_util_pkg.debug('fadptx_insert: asset id: ' || h_asset_id);
                        fa_rx_util_pkg.debug('fadptx_insert: asset number:' || h_asset_number);
                        fa_rx_util_pkg.debug('fadptx_insert: asset desc:'|| h_asset_desc);
                        fa_rx_util_pkg.debug('fadptx_insert: new use:'||h_new_used);
                        fa_rx_util_pkg.debug('fadptx_insert: minor category:'||h_minor_category);
                        fa_rx_util_pkg.debug('fadptx_insert: tax asset  type: '||h_tax_asset_type);
                        fa_rx_util_pkg.debug('fadptx_insert: state: '||h_state);
                        fa_rx_util_pkg.debug('fadptx_insert: start total units: '||h_start_units_total);
                        fa_rx_util_pkg.debug('fadptx_insert: end total  units: '||h_end_units_total);
                        fa_rx_util_pkg.debug('fadptx_insert: start units assigned:'||h_start_units_assigned);
                        fa_rx_util_pkg.debug('fadptx_insert: end units assigned: '||h_end_units_assigned);
                        fa_rx_util_pkg.debug('fadptx_insert: start total cost:'||h_start_cost_total);
                        fa_rx_util_pkg.debug('fadptx_insert: end total cost: '||h_end_cost_total);
                        fa_rx_util_pkg.debug('fadptx_insert: date in service:'  ||h_date_in_service);
                        fa_rx_util_pkg.debug('fadptx_insert: era name   num: '||h_era_name_num);
                        fa_rx_util_pkg.debug('fadptx_insert: add era year: '||h_add_era_year);
                        fa_rx_util_pkg.debug('fadptx_insert: add year: '||h_add_year);
                        fa_rx_util_pkg.debug('fadptx_insert: add month: '||h_add_month);
                        fa_rx_util_pkg.debug('fadptx_insert: start life: '||h_start_life);
                        fa_rx_util_pkg.debug('fadptx_insert: end life: '||h_end_life);
                        fa_rx_util_pkg.debug('fadptx_insert: adjusted rate: '||h_adjusted_rate);
                        fa_rx_util_pkg.debug('fadptx_insert: h_abs_units: '||h_abs_units);
                        fa_rx_util_pkg.debug('fadptx_insert: action flag: '||h_action_flag);
                        fa_rx_util_pkg.debug('fadptx_insert: **** End of queried values list for '||h_asset_id||' ****');
--              END IF;

                /* Get theoretical and evaluated nbv,residual rate */

                /* following logic must be run only once for each asset */
                if dist_asset_id <> h_asset_id then

                  -- Store processed asset_id
                  dist_asset_id := h_asset_id;

                  -- Check the values of theoretical nbv and evaluated nbv on all states
                  select count(*),count(theoretical_nbv),count(evaluated_nbv)
                  into   l_chk_nbv_total,l_chk_theoretical_nbv,l_chk_evaluated_nbv
                  from   FA_DEPRN_TAX_REP_NBVS
                  where  asset_id = l_asset_id
                  and    book_type_code = h_book
                  and    year = h_year -1;

                  if nvl(l_chk_theoretical_nbv,0) <> nvl(l_chk_evaluated_nbv,0) then
                    RAISE BOTH_NBV_ERROR;
                  elsif (nvl(l_chk_theoretical_nbv,0) <> 0 and nvl(l_chk_nbv_total,0) <> nvl(l_chk_theoretical_nbv,0)) then
                    RAISE BOTH_NBV_ERROR;
                  end if;  -- End of check the values of theoretical nbv and evaluated nbv

                  -- Delete the data parameter's year on FA_DEPRN_TAX_REP_NBVS to refresh data
                  delete from FA_DEPRN_TAX_REP_NBVS
                   where asset_id = l_asset_id
                   and   book_type_code = h_book
                   and   year = h_year;

                  -- Fetch theoretical and evaluated NBV total
                  -- Initialization
                  dist_total_units := null;
                  dist_total_cost  := null;
                  l_total_cost := null;
                  l_total_prior_cost := null;
                  l_total_units :=null;
                  l_total_prior_units := null;

                 open c_total_units_cost(h_book, l_asset_id, h_target_date);
                 fetch c_total_units_cost into l_total_units, l_total_cost;
                 close c_total_units_cost;

                 open c_total_units_cost(h_book, l_asset_id, h_prior_date);
                 fetch c_total_units_cost into l_total_prior_units, l_total_prior_cost;
                 close c_total_units_cost;

/*
                 -- Set asset cost and Units from FA_BOOKS at prior date
                  l_total_prior_cost := h_prior_total_cost;
                  l_total_prior_units := h_prior_total_units;

                 -- Set asset cost from FA_BOOKS at target date
                  l_total_cost := h_total_cost;
                  l_total_units := h_total_units;
*/

               IF (g_print_debug) THEN
                 fa_rx_util_pkg.debug('fadptx_insert: l_asset_id (before c_last_nbv_total):'||l_asset_id);
                 fa_rx_util_pkg.debug('fadptx_insert: h_book:'||h_book);
                 fa_rx_util_pkg.debug('fadptx_insert: h_year:'||h_year);
               END IF;
                  --
                  open c_last_nbv_total(l_asset_id,h_book,h_year);
                  fetch c_last_nbv_total into dist_total_cost,  -- bug#2661575
                                              dist_total_evaluated_nbv, dist_total_theoretical_nbv,
                                              dist_last_total_units,
                                              dist_year;

                  -- Fetch total units at target date
                  if c_last_nbv_total%FOUND then
                    if (g_print_debug) then
                      fa_rx_util_pkg.debug('fadptx_insert: c_last_nbv_total: return with values');
                      fa_rx_util_pkg.debug('fadptx_insert: dist_last_total_cost(0.0):'||dist_total_cost);
                      fa_rx_util_pkg.debug('fadptx_insert: dist_last_total_units(0.0):'||dist_last_total_units);
                      fa_rx_util_pkg.debug('fadptx_insert: dist_total_evaluated_nbv(0.0):'||dist_total_evaluated_nbv);
                      fa_rx_util_pkg.debug('fadptx_insert: dist_total_theoretical_nbv(0.0):'||dist_total_theoretical_nbv);
                      fa_rx_util_pkg.debug('fadptx_insert: dist_year(0.0):'||dist_year);
                    end if;

                    h_last_nbv_total_flag :='Y';
                    dist_total_units := l_total_units;

                    -- Calculate dist_total_evaluated_nbv and dist_total_theoretical_nbv
                    if dist_total_cost =0 then
                      dist_total_evaluated_nbv := 0;
                      dist_total_theoretical_nbv := 0;
                    else
                      if dist_total_evaluated_nbv is not null then
                        dist_total_evaluated_nbv
                         := round(l_total_cost/dist_total_cost * dist_total_evaluated_nbv,h_precision);
                      end if;
                      if dist_total_theoretical_nbv is not null then
                        dist_total_theoretical_nbv
                         := round(l_total_cost/dist_total_cost * dist_total_theoretical_nbv,h_precision);
                      end if;
                    end if;
                 else
                 -- bug#2661575 initialization
                   h_last_nbv_total_flag :='N';
                   dist_total_evaluated_nbv := null;
                   dist_total_theoretical_nbv := null;
                   dist_year := null;
                   dist_total_cost := null;
                 end if;

               close c_last_nbv_total;

               IF (g_print_debug) THEN
                 fa_rx_util_pkg.debug('fadptx_insert: dist_total_cost(0):'||dist_total_cost);
                 fa_rx_util_pkg.debug('fadptx_insert: dist_total_units(0):'||dist_total_units);
                 fa_rx_util_pkg.debug('fadptx_insert: dist_last_total_units(0):'||dist_last_total_units);
                 fa_rx_util_pkg.debug('fadptx_insert: dist_total_evaluated_nbv(0):'||dist_total_evaluated_nbv);
                 fa_rx_util_pkg.debug('fadptx_insert: dist_total_theoretical_nbv(0):'||dist_total_theoretical_nbv);
                 fa_rx_util_pkg.debug('fadptx_insert: dist_year:'||dist_year);
              END IF;

           end if; -- if dist_asset_id <> h_asset_id
           --
                -- Get the latest data from NBV table.

                  IF (g_print_debug) THEN
                    fa_rx_util_pkg.debug('fadptx_insert: l_total_prior_cost(0):'||l_total_prior_cost);
                    fa_rx_util_pkg.debug('fadptx_insert: l_total_prior_units(0):'||l_total_prior_units);
                    fa_rx_util_pkg.debug('fadptx_insert: l_total_cost(0):'||l_total_cost);
                    fa_rx_util_pkg.debug('fadptx_insert: l_total_units(0):'||l_total_units);
                    fa_rx_util_pkg.debug('fadptx_insert: dist_total_units(0.5):'||dist_total_units);
                  END IF;

                -- Initializations
                h_up_cost := NULL;
                h_up_theoretical_nbv := NULL;
                h_up_evaluated_nbv := NULL;
                h_up_year := NULL;
                h_tmp_units_assigned := NULL;
                h_up_last_cost := NULL;
                h_up_tax_asset_type := NULL;
                h_up_units_assigned := NULL;
                h_up_life := NULL;


                OPEN c_nbv_update (h_asset_id,h_book,h_state, dist_year);
                FETCH c_nbv_update INTO h_up_cost,h_up_theoretical_nbv,
                                        h_up_evaluated_nbv,h_up_year, h_tmp_units_assigned;

                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'h_up_theoretical_nbv(0):'||h_up_theoretical_nbv);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'h_up_evaluated_nbv(0):'||h_up_evaluated_nbv);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'h_up_year(0):'||h_up_year);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'h_tmp_units_assigned(0):'||h_tmp_units_assigned);
                END IF;

                -- bug#2661575: Remove flag logic

                -- bug#2629893: Distribute NBVs
                if dist_total_units is null then
                  dist_total_units := h_end_units_total;
                end if;

                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_evaluated_nbv(0):'||h_up_evaluated_nbv);
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_year(0):'||h_up_year);
                        fa_rx_util_pkg.debug('fadptx_insert: h_tmp_units_assigned(0):'||h_tmp_units_assigned);
                        fa_rx_util_pkg.debug('fadptx_insert: dist_total_units(1):'||dist_total_units);
                        fa_rx_util_pkg.debug('fadptx_insert: dist_total_theoretical_nbv(1):'||dist_total_theoretical_nbv);
                        fa_rx_util_pkg.debug('fadptx_insert: dist_total_evaluated_nbv(1):'||dist_total_evaluated_nbv);
                END IF;


                IF dist_total_theoretical_nbv is not null and dist_total_evaluated_nbv is not null then
                  IF (nvl(h_tmp_units_assigned,0) <> h_end_units_assigned
                     or dist_total_cost <> l_total_cost
                     or dist_last_total_units <> l_total_units)
                     and dist_year =nvl(h_up_year,dist_year)  then
                    if dist_total_units = 0 then
                      h_up_theoretical_nbv := 0;
                      h_up_evaluated_nbv   := 0;
                    else
                      h_up_theoretical_nbv
                        := round(dist_total_theoretical_nbv*h_end_units_assigned/dist_total_units,h_precision);
                      h_up_evaluated_nbv
                        := round(dist_total_evaluated_nbv  *h_end_units_assigned/dist_total_units,h_precision);
                    end if;
                  END IF;

                  dist_total_units := dist_total_units - h_end_units_assigned;

                   -- bug#2661575 Treated rounding error
                  if dist_total_units =0 then
                    h_up_theoretical_nbv := dist_total_theoretical_nbv;
                    h_up_evaluated_nbv  := dist_total_evaluated_nbv;
                  end if;

                  dist_total_theoretical_nbv := dist_total_theoretical_nbv - nvl(h_up_theoretical_nbv,0);
                  dist_total_evaluated_nbv   := dist_total_evaluated_nbv - nvl(h_up_evaluated_nbv,0);
                  h_up_nbv_flag := 'Y';    -- bug#2661575
                  h_up_year := dist_year;  -- bug#2661575
                END IF;
                -- End of bug#2629893

                OPEN c_last_update (h_asset_id,h_book,h_state, h_year);
                FETCH c_last_update INTO h_up_last_cost, h_up_tax_asset_type,h_up_units_assigned,h_up_life;


                IF c_last_update%found THEN
                   h_last_up_flag :='Y';
                 ELSE
                   h_last_up_flag :='N';
                END IF;

                CLOSE c_last_update;

                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_nbv_flag:'||h_up_nbv_flag);
                        fa_rx_util_pkg.debug('fadptx_insert: h_last_up_flag:'||h_last_up_flag);
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_cost:'||h_up_cost);
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_theoretical_nbv:'||h_up_theoretical_nbv);
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_evaluated_nbv:'||h_up_evaluated_nbv);
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_year:'||h_up_year);
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_last_cost:'||h_up_last_cost);
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_tax_asset_type:'||h_up_tax_asset_type);
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_units_assigned:'||h_up_units_assigned);
                        fa_rx_util_pkg.debug('fadptx_insert: h_up_life:'||h_up_life);
                        fa_rx_util_pkg.debug('fadptx_insert: dist_total_units:'||dist_total_units);
                        fa_rx_util_pkg.debug('fadptx_insert: dist_total_theoretical_nbv:'||dist_total_theoretical_nbv);
                        fa_rx_util_pkg.debug('fadptx_insert: dist_total_evaluated_nbv:'||dist_total_evaluated_nbv);
                END IF;


                -- check h_up_theoretical_nbv and  h_up_evaluated_nbv
                IF (h_up_theoretical_nbv IS NULL AND h_up_evaluated_nbv IS NOT NULL)
                  OR (h_up_theoretical_nbv IS NOT NULL AND  h_up_evaluated_nbv IS NULL)
                    THEN
                   RAISE BOTH_NBV_ERROR;
                END IF;

                /* Start Cost distribute */ -- bug#2629893 Moved this logic to here

                if h_start_cost_total =0 then
                                h_start_cost :=0;
                                h_start_units_assigned :=0;
                else
                  if h_start_asset_id <> h_asset_id then
                                h_start_units_accm :=0;
                                h_start_cost_accm :=0;
                                h_start_asset_id := h_asset_id;
                  end if;

                    IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'h_start_asset_id:'||h_start_asset_id);
                    END IF;

                    if h_min_acct_unit is not null then

                      h_start_cost := round((h_start_units_assigned + h_start_units_accm) /
                                                h_start_units_total * h_start_cost_total/h_min_acct_unit
                                                ,h_precision) * h_min_acct_unit- h_start_cost_accm;

                    else
                      h_start_cost :=round((h_start_units_assigned + h_start_units_accm) /
                                                h_start_units_total * h_start_cost_total,h_precision) -
                                                h_start_cost_accm;
                    end if;

                        h_start_units_accm := h_start_units_accm + h_start_units_assigned;
                        h_start_cost_accm := h_start_cost_accm + h_start_cost;
                end if;

                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'start units accm :'||h_start_units_accm);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'start cost accm :'||h_start_cost_accm);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'start cost: '||h_start_cost);
                END IF;

                if h_end_cost_total = 0 then
                        h_end_cost :=0;
                        h_theoretical_nbv := 0;
                        h_evaluated_nbv := 0;
                        h_end_units_assigned :=0;

                else

                ----------------------------------------------------------------
                -- Cost distribute: Prevent rounding error, this logic is used.
                ----------------------------------------------------------------

                        /* End Cost distribute */
                        if h_end_asset_id <> h_asset_id then
                                h_end_units_accm:=0;
                                h_end_cost_accm :=0;
                                h_end_asset_id := h_asset_id;
                        end if;

                        IF (g_print_debug) THEN
                                fa_rx_util_pkg.debug('fadptx_insert: ' || 'h_end_asset_id:'||h_end_asset_id);
                        END IF;

                        if h_min_acct_unit is not null then

                                h_end_cost :=   round((h_end_units_assigned + h_end_units_accm) /
                                                h_end_units_total * h_end_cost_total/h_min_acct_unit
                                                ,h_precision) * h_min_acct_unit - h_end_cost_accm;

                        else
                                h_end_cost :=   round((h_end_units_assigned  + h_end_units_accm) /
                                                h_end_units_total * h_end_cost_total,h_precision) -
                                                h_end_cost_accm;
                        end if;

                        -- Treate rounding error for end cost

                        if nvl(h_tmp_units_assigned,h_start_units_assigned) = h_end_units_assigned
                         and nvl(dist_total_cost,l_total_prior_cost) = l_total_cost
                         and nvl(dist_last_total_units,l_total_prior_units) = l_total_units
                        then
                          if h_last_up_flag ='Y' then -- If NBVs table has cost, update end cost
                           h_end_cost := h_up_last_cost;
                          elsif h_start_cost >0 and h_end_cost >0 then
                           -- If NBVs table doesn't have cost and start cost and end cost are not 0
                           h_end_cost := h_start_cost;
                          end if;
                        end if;

                        h_end_units_accm := h_end_units_accm +  h_end_units_assigned;
                        h_end_cost_accm := h_end_cost_accm + h_end_cost;

                        IF (g_print_debug) THEN
                                fa_rx_util_pkg.debug('fadptx_insert: ' || 'end units accm:'||h_end_units_accm);
                                fa_rx_util_pkg.debug('fadptx_insert: ' || 'end cost accm:'||h_end_cost_accm);
                                fa_rx_util_pkg.debug('fadptx_insert: ' || 'end cost:'||h_end_cost);
                        END IF;

/*==========================================================================
NBV and Residual Rate Calculation: After half_rate and full_rate,
calculate NBV and Residual Rate.  [First year Theoretical NBV]
        = [COST]*(1-[adjusted rate]*(13- [addition month])/12
[Fist year Evaluated NBV]=[COST]*[half_rate] [After next year
Theoretical NBV]=[Prior year Theoretical NBV]*[full_rate] [After next
year Evaluated NBV] =[Prior year Evaluated NBV]*[full_rate]
===========================================================================
*/

        /* Calculate half and full rate */

                        --bug4919991: Now user can choose where to use round in middle or not
                        if not (rounding) then
                           h_half_rate := 1 - h_adjusted_rate/2;
                        else
                           h_half_rate := trunc(1 - h_adjusted_rate/2,3);
                        end if;

                        h_full_rate := 1 - h_adjusted_rate;

        /* Set parameter for calculation */
                        h_diff_year :=  to_number(to_char(h_target_date,'YYYY')) - h_add_year;

                        IF (g_print_debug) THEN
                                fa_rx_util_pkg.debug('fadptx_insert: ' || 'h_diff_year:'||h_diff_year);
                        END IF;

                        -- Set the variable for starting loop counter
                        IF h_up_nbv_flag ='Y'
                          AND (h_up_theoretical_nbv IS NOT NULL
                               AND h_up_evaluated_nbv IS NOT NULL) THEN
                           l_start_loop := h_up_year +1 - h_add_year;
                         ELSE
                           l_start_loop := 1;
                        END IF;

                        IF (g_print_debug) THEN
                                fa_rx_util_pkg.debug('fadptx_insert: ' || 'l_start_loop:'||l_start_loop);
                        END IF;

                       /* Evaluated and Theoretical NBV calculation */
                        For i in l_start_loop..h_diff_year LOOP

                           -- Bug#2629893
                           -- Remove rate history logic for Cost base calculation

                           /* bug#2433829 -- Supported Rate chenges */

                           -- Bug#2629893
                           -- Treate asset transfer

                           if i=1 then
                              --bug4919991: Now user can choose where to use round in middle or not
                              if not (rounding) then
                                 h_theoretical_nbv:= round(h_end_cost * (1-h_adjusted_rate*
                                                                  (13- h_add_month)/12),h_precision);
                              else
                                 h_theoretical_nbv:= round(h_end_cost * round(1-h_adjusted_rate*
                                                                  (13- h_add_month)/12,3),h_precision);
                              end if;
                              h_evaluated_nbv:= round(h_end_cost * h_half_rate,h_precision);
                            ELSE
                              IF i=l_start_loop AND h_up_theoretical_nbv IS NOT NULL THEN
                                   h_theoretical_nbv:= round(h_up_theoretical_nbv*h_full_rate,h_precision);
                              ELSE
                                 h_theoretical_nbv:= round(h_theoretical_nbv*h_full_rate,h_precision);
                              END IF;

                              IF i=l_start_loop AND h_up_evaluated_nbv IS NOT NULL THEN
                                    h_evaluated_nbv:= round(h_up_evaluated_nbv * h_full_rate,h_precision);
                               ELSE
                                 h_evaluated_nbv:= round(h_evaluated_nbv * h_full_rate,h_precision);
                              END IF;

                              -- End of bug#2433829 changes --
                           end if;
                        end Loop;

                        /* Mimimun NBV limitation -- bug#1797751 */

                        if (g_print_debug) then
                          fa_rx_util_pkg.debug('Test:asset_id:'||h_asset_id);
                          fa_rx_util_pkg.debug('Test:state:'||h_state);
                          fa_rx_util_pkg.debug('Test:tax_asset_type:'||h_tax_asset_type);
                          fa_rx_util_pkg.debug('Test:h_theoretical_nbv:'||h_theoretical_nbv);
                          fa_rx_util_pkg.debug('Test:h_evaluated_nbv:'||h_evaluated_nbv);
                        end if;

                        if h_theoretical_nbv < round(h_end_cost*0.05, h_precision) then
                                h_theoretical_nbv := round(h_end_cost*0.05, h_precision);
                        end if;

                        if h_evaluated_nbv < round(h_end_cost*0.05, h_precision) then
                                 h_evaluated_nbv := round(h_end_cost*0.05, h_precision);
                        end if;


                        /* Residual rates calculation */

                       -- The following code is being added as part of Japan tax reforms 2008
                       if h_year >= 2008 then
                         h_theoretical_nbv := 0;
                       end if;
                       -- End of Addition for  of Japan tax reforms 2008
                end if;
                CLOSE c_nbv_update;

                -- Bug: :Design Change
                -- Changed as followings
                -- At 1st year: Residual rate is h_half_rate
                -- After 2nd years: Residula rate is h_full_rate

                /* Bug  7422776 changed the formula for calculating h_theoretical_residual_rate for first year*/
                if h_diff_year = 1 then  -- At 1st year
                    h_theoretical_residual_rate := (1-h_adjusted_rate*
                                                                  (13- h_add_month)/12);
                    if (rounding) then
                         h_theoretical_residual_rate :=  trunc(h_theoretical_residual_rate,3);
                    end if;
                  h_evaluated_residual_rate   := h_half_rate;
                else -- After 2 years
                  h_theoretical_residual_rate := h_full_rate;
                  h_evaluated_residual_rate   := h_full_rate;
                end if;

                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'theoretical nbv:     '||h_theoretical_nbv);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'evaluated nbv: '||h_evaluated_nbv);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'theoretical residual rate: '||h_theoretical_residual_rate);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'evaluated residual rate:     '||h_evaluated_residual_rate);
                END IF;


        /* Set Taxable Cost */

                h_theoretical_taxable_cost := h_theoretical_nbv;
                h_evaluated_taxable_cost := h_evaluated_nbv;

                -- Set the values of nbv table
                IF h_last_up_flag='Y' THEN
                  -- bug#2629893 : Treate tax asset type changing
                   if not h_tax_asset_type <> Nvl(substr(h_up_tax_asset_type,1,1),h_start_asset_type)
                   then
                     h_start_cost := h_up_last_cost;
                     h_start_asset_type :=Nvl(substr(h_up_tax_asset_type,1,1),h_start_asset_type);
                     h_start_units_assigned := Nvl(h_up_units_assigned,h_start_units_assigned);
                     h_start_life := Nvl(h_up_life,h_start_life);
                   end if;
                END IF;

                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'overwritten start cost: '||h_start_cost);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'overwritten start asset type :'||h_start_asset_type);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'overwritten start units assigned :'||h_start_units_assigned);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'overwritten start life :'||h_start_life);
                END IF;

/*==========================================================================
  Check if current processed state is necessary state or not.
  Only if it is Yes, reason code process will be run
===========================================================================*/
                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'State check h_state:'||h_state);
                END IF;

                IF h_state >= nvl(state_from,h_state) and h_state <= nvl(state_to,h_state) THEN
                   h_state_flag := 'Y';
                ELSE
                   h_state_flag := 'N';
                END IF;

/*============================================================================
Set INCREASE COST, DECREASE COST and REASON CODE: Compaire start date
information and end date infomation, Set increase cost, decrease cost
and reason code.

Priority of reason: [1]INCREASE
        [1-1] NEW ADDITION [1-2] USED ADDITION [1-3] TRANSFER IN [1-4]
        OTHER
[2]DECREASE
        [2-1] FULL [2-2] PARTIAL

        [2-A] SALE RETIREMENT [2-B] RETIREMENT [2-C] TRANSFER OUT
        [2-D] OTHER

[3]OTHER
        [3-1] CHANGE LIFE [3-2] OTHER

If the asset is not changed for a year, 'All' Report print as 'NEW
ADDITION' or 'USED ADDITION'.

============================================================================*/

/*==========================================================================
The followings are set flag if addition, transfer, retirement transaction
from prior date to taraget date.
==========================================================================*/

         if not (h_start_cost =0  AND h_end_cost=0) THEN
            if h_state_flag = 'Y' then

        /* Set flag:Transaction ADDTION */
                begin
                        Select  distinct 'Y'
                        into    r_addition_flag
                        from    FA_TRANSACTION_HEADERS
                        where   ASSET_ID = h_asset_id
                        and     BOOK_TYPE_CODE =h_book_type_code
                        and     TRANSACTION_DATE_ENTERED >= h_prior_date
                        and     TRANSACTION_DATE_ENTERED <= h_target_date
                        and     (TRANSACTION_TYPE_CODE ='CIP ADDITION'
                                or      (TRANSACTION_TYPE_CODE ='ADDITION'
                                        and not exists
                                                (Select * from FA_TRANSACTION_HEADERS
                                                where   ASSET_ID = h_asset_id
                                                and     BOOK_TYPE_CODE =h_book_type_code
                                                and     TRANSACTION_DATE_ENTERED < h_prior_date
                                                and     TRANSACTION_TYPE_CODE ='CIP ADDITION')));

                exception
                        when NO_DATA_FOUND then r_addition_flag :='N';
                end;

        /* Set flag:Transaction Retirement */
                begin
                        Select  TRANSACTION_HEADER_ID
                        into    r_ret_id
                        from    FA_TRANSACTION_HEADERS
                        where   ASSET_ID = h_asset_id
                        and     BOOK_TYPE_CODE = h_book_type_code
                        and     TRANSACTION_HEADER_ID =
                                        (select max(TRANSACTION_HEADER_ID)
                                        from FA_TRANSACTION_HEADERS
                                        where   ASSET_ID = h_asset_id
                                        and     BOOK_TYPE_CODE= h_book_type_code
                                        and     TRANSACTION_DATE_ENTERED >= h_prior_date
                                        and     TRANSACTION_DATE_ENTERED <= h_target_date
                                        and     (TRANSACTION_TYPE_CODE ='FULL RETIREMENT'
                                        or TRANSACTION_TYPE_CODE ='PARTIAL RETIREMENT'));

                        r_ret_flag      :='Y';

        Exception
                when NO_DATA_FOUND then
                        r_ret_flag      :='N';
        end;

        /* Set flag:Transaction Transfer */
                begin
                        Select  decode (to_char(TRANSACTION_DATE_ENTERED,'MM-DD'),
                                        '01-01',to_char(TRANSACTION_DATE_ENTERED -1,'E YY.MM',
                                        'NLS_CALENDAR=''Japanese Imperial'''),
                                        to_char(TRANSACTION_DATE_ENTERED,'E YY.MM',
                                        'NLS_CALENDAR=''Japanese Imperial''')),
                                TRANSACTION_NAME
                        into    r_transfer_date,
                                r_trn_transaction_name
                        from    FA_TRANSACTION_HEADERS
                        where   ASSET_ID = h_asset_id
                        and     BOOK_TYPE_CODE = h_corp_book
                        and     TRANSACTION_HEADER_ID =
                                        (select max(TRANSACTION_HEADER_ID)
                                        from FA_TRANSACTION_HEADERS
                                        where   ASSET_ID = h_asset_id
                                        and     BOOK_TYPE_CODE = h_corp_book
                                        and     TRANSACTION_DATE_ENTERED >= h_prior_date
                                        and     TRANSACTION_DATE_ENTERED <= h_target_date
                                        and     TRANSACTION_TYPE_CODE ='TRANSFER');
                        --Bug6200581 begins
                        --Checking if the asset is in the current state or not ( has been transferred).
                        begin
                                l_transfer_sql := 'select ''N''
                                from    FA_DISTRIBUTION_HISTORY FDH,
                                        FA_LOCATIONS LOC
                                where   FDH.ASSET_ID = '||h_asset_id ||'
                                and     FDH.TRANSACTION_HEADER_ID_out in ( select TRANSACTION_HEADER_ID
                                                        from FA_TRANSACTION_HEADERS
                                                        where   ASSET_ID = '|| h_asset_id ||'
                                                        and     BOOK_TYPE_CODE =  '''||h_corp_book ||'''
                                                         and    TRANSACTION_DATE_ENTERED >= '''|| h_prior_date ||'''
                                                         and    TRANSACTION_DATE_ENTERED <= '''|| h_target_date ||'''
                                                         and    TRANSACTION_TYPE_CODE =''TRANSFER'')
                                and     FDH.LOCATION_ID = LOC.LOCATION_ID
                                and '||l_parm_state||' = '''||h_state ||'''';
                                v_TransferCursor := DBMS_SQL.OPEN_CURSOR;

                                DBMS_SQL.PARSE (v_TransferCursor,l_transfer_sql,DBMS_SQL.V7);
                                DBMS_SQL.DEFINE_COLUMN(v_TransferCursor,1,h_current_state_flag,1);

                                v_TransferReturn := DBMS_SQL.EXECUTE(v_TransferCursor);
                                v_TransferFetch := DBMS_SQL.FETCH_ROWS(v_TransferCursor);
                                If v_TransferFetch = 0 then
                                        h_current_state_flag:='Y';
                                end if;

                                DBMS_SQL.COLUMN_VALUE(v_TransferCursor,1,h_current_state_flag);
                                DBMS_SQL.CLOSE_CURSOR(v_TransferCursor);

                        end;
                        ----Bug6200581 ends

                        r_transfer_flag :='Y';

                Exception
                        when NO_DATA_FOUND then
                        r_transfer_flag :='N';
                        --Bug6200581
                        --Setting the flag to Yes if no transfer has been performed on the asset
                        h_current_state_flag:='Y';
                end;

                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason - addition flag:'||r_addition_flag);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason - retirement flag:'||r_ret_flag);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason - transfer flag:'||r_transfer_flag);
                END IF;

        /* Reset Reason and taxable cost information */

                h_all_reason_type := to_char(null);
                h_all_reason_code := to_char(null);
                h_all_description := to_char(null);
                h_adddec_reason_type := to_char(null);
                h_adddec_reason_code := to_char(null);
                h_dec_type := to_char(null);
                h_adddec_description := to_char(null);
                h_add_dec_flag := to_char(null);

/*===========================================================================
Get RETIREMENT_TYPE_CODE and SOLD_TO :
If sale code used, get SOLD_TO for printing decrease report.
========================================================================== */
                if      r_ret_flag ='Y' then

                        Select  RETIREMENT_TYPE_CODE,
                                SOLD_TO
                        Into    r_ret_type_code,
                                r_sold_to
                        From    FA_RETIREMENTS
                        Where   TRANSACTION_HEADER_ID_IN = r_ret_id;


                        IF (g_print_debug) THEN
                                fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason - Retirement type code:'||r_ret_type_code);
                        END IF;

                end if;

/*==========================================================================
Set ADD_DEC_FLAG, INCREASE_COST, DECREASE_COST
==========================================================================*/

        -- bug4954665: Set start cost to 0 if prior year data is dummy data
        if h_action_flag = 'Z' then
           h_start_cost := 0;
        end if;

        /* ADDTION for a year, set adddec flag is A */

                if      (h_end_cost - h_start_cost) >0 then
                        h_increase_cost := h_end_cost - h_start_cost;
                        h_decrease_cost := 0;
                        h_add_dec_flag := 'A';

        /* Set ADDDEC_REASON_CODE, ADD_DEC_REASON_TYPE, ADDDEC_DESCRIPTION when ADDDEC_FLAG ='A'*/

                                /* Set NEW ADDITION */
                        if      r_addition_flag = 'Y' and h_new_used = 'NEW' then

                                h_adddec_reason_code := '1';    /* NEW ADDITION */
                                h_adddec_reason_type :='NEW ADDITION';
                                h_adddec_description := to_char(null);

                                /* Set USED ADDTION */
                        elsif   r_addition_flag ='Y' and h_new_used = 'USED' then

                                h_adddec_reason_code := '2';    /* USED ADDITION */
                                h_adddec_reason_type :='USED ADDITION';
                                h_adddec_description := to_char(null);

                                /* Set Transfer in */
                        elsif   r_addition_flag ='N' and r_transfer_flag ='Y'
                                and h_end_units_assigned - h_start_units_assigned >0    then

                                h_adddec_reason_code := '3';    /* TRANSFER */
                                h_adddec_reason_type :='TRANSFER';
                                h_adddec_description := r_transfer_date;

                        else
                                /* Set Other Addition */
                                h_adddec_reason_code := '4';    /* OTHER */
                                h_adddec_reason_type :='OTHER';
                                h_adddec_description := to_char(null);
                        end if;

        /* Set ADDDEC_REASON_CODE, ADD_DEC_REASON_TYPE, ADDDEC_DESCRIPTION when ADDDEC_FLAG ='D'*/

                elsif   (h_end_cost - h_start_cost) <0 then
                        h_increase_cost := 0;
                        h_decrease_cost := h_start_cost - h_end_cost;
                        h_add_dec_flag := 'D';

        /* Set DEC_TYPE == Partial decrease or Full decrease  */

                        if      h_end_cost = 0 then
                                h_dec_type :='1';       /* Decrease type -- Full */
                        else
                                h_dec_type :='2';       /* Decrease type -- Partial */
                        end if;

        /* Set ADDDEC_REASON_CODE, ADD_DEC_REASON_TYPE, ADDDEC_DESCRIPTION when ADDDEC_FLAG ='D'*/

                        --Bug6200581 Added the condition to check if the asset is in the current state
                        if      r_ret_flag ='Y' and h_current_state_flag = 'Y' then
                                /* Set SALE RETIREMENT */

                                if      nvl(r_ret_type_code,'NULL') = nvl(sale_code,'NULL') then
                                        h_adddec_reason_code :='1';     /* Reason Code -- Sale */
                                        h_adddec_reason_type :='SALE';
                                        h_adddec_description := r_sold_to;

                                /* Set Normal Retirmenet */
                                else
                                        h_adddec_reason_code :='2';     /* Reason Code -- Retirement */
                                        h_adddec_reason_type :='RETIREMENT';

                                        /* Set Retirement Reason from FA Lookup code */
                                        if r_ret_type_code is not null then

                                                Select  MEANING
                                                into    h_adddec_description
                                                from    FA_LOOKUPS
                                                where   LOOKUP_TYPE = 'RETIREMENT'
                                                and     LOOKUP_CODE = r_ret_type_code;

                                        else
                                                h_adddec_description := to_char(null);
                                        end if;

                                end if;

                                /* Set Transfer out */

                        elsif   r_transfer_flag ='Y' then

                                h_adddec_reason_code := '3';    /* Reason Code -- Transfer */
                                h_adddec_reason_type := 'TRANSFER';
                                h_adddec_description := r_trn_transaction_name;

                                /* Set Other Decease */
                        else
                                h_adddec_reason_code := '4';    /* Reason Code -- Other */
                                h_adddec_reason_type := 'OTHER';
                                h_adddec_description := to_char(null);
                        end if;

        /* Set ADDDEC_REASON_CODE, ADD_DEC_REASON_TYPE, ADDDEC_DESCRIPTION when ADDDEC_FLAG is null */

                else
                        h_increase_cost := 0;
                        h_decrease_cost :=0;
                        h_add_dec_flag := to_char(null);
                end if;

        /* Set ALL_REASON_CODE, ALL_REASON_TYPE, ALL_DESCRIPTION */

                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason - Addition/Decrease Flag:'||h_add_dec_flag);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason - ADD/DEC reason type:'||h_adddec_reason_type);
                END IF;

                if      h_add_dec_flag ='A' and h_adddec_reason_code ='3' then

                        h_all_reason_code := '3';       /* TRANSFER IN */
                        h_all_reason_type := h_adddec_reason_type;
                        h_all_description := h_adddec_description;

                elsif   h_add_dec_flag is null and h_start_life <> h_end_life
                        and h_start_life >0 and h_end_life >0 then

                        h_all_reason_code := '4';       /* Change life*/
                        h_all_reason_type := 'CHANGE LIFE';

                        h_all_description := h_start_life||r_change_life_desc;

                elsif   (h_add_dec_flag ='A' or h_add_dec_flag ='D')
                        and h_adddec_reason_code ='4' then

                        h_all_reason_code := '4';       /* OTHER Addition */
                        h_all_reason_type := h_adddec_reason_type;
                        h_all_description := h_adddec_description;

                elsif   h_new_used ='NEW' then

                        h_all_reason_code := '1';       /* NEW ASSET */
                        h_all_reason_type := 'NEW ASSET';
                        h_all_description := to_char(null);

                elsif   h_new_used ='USED' then

                        h_all_reason_code := '2';       /* NEW ASSET */
                        h_all_reason_type := 'USED ASSET';
                        h_all_description := to_char(null);

                else

                        h_all_reason_code := '4';       /* OTHER */
                        h_all_reason_type := 'OTHER';
                        h_all_description := to_char(null);
                end if;

                IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason- increase_cost:'||h_increase_cost);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason- decrease_cost:'||h_decrease_cost);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason- all reason type:'||h_all_reason_type);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason- all reason code:'||h_all_reason_code);
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'Reason- all description:'||h_all_description);
                END IF;

        /* bug 2082460 */
                h_adddec_description := substrb(h_adddec_description,1,30);
                h_all_description := substrb(h_all_description,1,30);

        /* Insert end date's data to FA_DEPRN_TAX_REP_ITF */

                IF (g_print_debug) THEN
                   fa_rx_util_pkg.debug ('fadptx_insert: ' || 'h_state_flag :'||h_state_flag);
                END IF;

                -- bug#2629893
                -- For FA_DEPRN_TAX_REP_ITF, insert and update date for state ranages.
                -- For FA_DEPRN_TAX_REP_NBVS, insert and update date for all states.

                        Insert into FA_DEPRN_TAX_REP_ITF (
                                REQUEST_ID,
                                YEAR,
                                ASSET_ID,
                                ASSET_NUMBER,
                                ASSET_DESCRIPTION,
                                NEW_USED,
                                BOOK_TYPE_CODE,
                                MINOR_CATEGORY,
                                TAX_ASSET_TYPE,
                                MINOR_CAT_DESC,
                                STATE,
                                START_UNITS_ASSIGNED,
                                END_UNITS_ASSIGNED,
                                END_COST,
                                START_COST,
                                THEORETICAL_NBV,
                                EVALUATED_NBV,
                                DATE_PLACED_IN_SERVICE,
                                ERA_NAME_NUM,
                                ADD_ERA_YEAR,
                                ADD_MONTH,
                                START_LIFE,
                                END_LIFE,
                                THEORETICAL_RESIDUAL_RATE,
                                EVALUATED_RESIDUAL_RATE,
                                THEORETICAL_TAXABLE_COST,
                                EVALUATED_TAXABLE_COST,
                                ADJUSTED_RATE,
                                INCREASE_COST,
                                DECREASE_COST,
                                ALL_REASON_TYPE,
                                ALL_REASON_CODE,
                                ALL_DESCRIPTION,
                                ADDDEC_REASON_TYPE,
                                ADDDEC_REASON_CODE,
                                DEC_TYPE,
                                ADDDEC_DESCRIPTION,
                                ADD_DEC_FLAG,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_LOGIN,
                                FUNCTIONAL_CURRENCY_CODE,
                                ORGANIZATION_NAME
                        )
                  values (
                                h_request_id,
                                h_year,
                                h_asset_id,
                                h_asset_number,
                                h_asset_desc,
                                h_new_used,
                                h_book_type_code,
                                h_minor_category,
                                h_tax_asset_type,
                                h_minor_cat_desc,
                                h_state,
                                h_start_units_assigned,
                                h_end_units_assigned,
                                h_end_cost,
                                h_start_cost,
                                h_theoretical_nbv,
                                h_evaluated_nbv,
                                h_date_in_service,
                                h_era_name_num,
                                h_add_era_year,
                                h_add_month,
                                h_start_life,
                                h_end_life,
                                h_theoretical_residual_rate,
                                h_evaluated_residual_rate,
                                h_theoretical_taxable_cost,
                                h_evaluated_taxable_cost,
                                h_adjusted_rate,
                                h_increase_cost,
                                h_decrease_cost,
                                h_all_reason_type,
                                h_all_reason_code,
                                h_all_description,
                                h_adddec_reason_type,
                                h_adddec_reason_code,
                                h_dec_type,
                                h_adddec_description,
                                h_add_dec_flag,
                                h_login_id,
                                sysdate,
                                sysdate,
                                h_login_id,
                                h_login_id,
                                h_currency_code,
                                h_company_name
                    );

--                  IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug ('fadptx_insert: ' || 'Inserted - asset id:'||h_asset_id||', state: '||h_state||', asset type:'||h_tax_asset_type);
--                  END IF;

                 else
--                  IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug ('fadptx_insert: ' || 'Reject - asset id:'||h_asset_id||', state: '||h_state||', asset type:'||h_tax_asset_type);
--                  END IF;

                 end if;  -- End of h_state_flag = 'Y' condition


                 IF h_last_nbv_total_flag='Y'
                  AND dist_total_theoretical_nbv IS null
                  AND dist_total_evaluated_nbv IS null
                 THEN
                   h_store_theoretical_nbv := null;
                   h_store_evaluated_nbv := null;
                 ELSE
                   h_store_theoretical_nbv := h_theoretical_nbv;
                   h_store_evaluated_nbv := h_evaluated_nbv;
                 END IF;

--               OPEN c_chk_nbv(h_asset_id, h_book_type_code, h_state, h_year);
--               FETCH c_chk_nbv INTO h_chk_nbv_flag;
--
                 IF h_end_cost >0 then
--                 IF c_chk_nbv%found then
--                   UPDATE FA_DEPRN_TAX_REP_NBVS
--                     SET cost = h_end_cost,
--                         theoretical_nbv = h_store_theoretical_nbv,
--                         evaluated_nbv = h_store_evaluated_nbv,
--                         tax_asset_type = h_tax_asset_type,
--                         units_assigned = h_end_units_assigned,
--                         life = h_end_life,    -- Added for bug#2468448
--                         last_updated_by = h_login_id,
--                         last_update_date = sysdate,
--                         last_update_login = h_login_id
--                   WHERE asset_id = h_asset_id
--                     AND book_type_code = h_book_type_code
--                     AND state= h_state
--                     AND year = h_year
--                     ;
--                   fa_rx_util_pkg.debug ('Updated - asset id:'||h_asset_id||', state: '||h_state||' to NBV table.');
--                ELSE
                    SELECT FA.FA_DEPRN_TAX_REP_NBVS_S.NEXTVAL
                      INTO h_deprn_tax_rep_nbv_id
                      FROM dual;

                    INSERT INTO FA_DEPRN_TAX_REP_NBVS
                     (
                      deprn_tax_rep_nbv_id,
                      asset_id,
                      book_type_code,
                      state,
                      year,
                      cost,
                      theoretical_nbv,
                      evaluated_nbv,
                      tax_asset_type,
                      units_assigned,
                      life,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login,
                      minor_category
                      )
                     VALUES
                     (
                      h_deprn_tax_rep_nbv_id,
                      h_asset_id,
                      h_book_type_code,
                      h_state,
                      h_year,
                      h_end_cost,
                      h_store_theoretical_nbv,
                      h_store_evaluated_nbv,
                      h_tax_asset_type,
                      h_end_units_assigned,
                      h_end_life,
                      h_login_id,
                      sysdate,
                      h_login_id,
                      sysdate,
                      h_login_id,
                      h_minor_category
                      );
--                    IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug ('fadptx_insert: ' || 'Inserted - asset id:'||h_asset_id||', state: '||h_state||' to NBV table.');
--                    END IF;

               END IF; -- ENd of h_end_cost>0 condition
--            END IF; -- End of c_chk_nbv condition
--            CLOSE c_chk_nbv;
            end if; -- End of condition 'not (h_start_cost =0  AND h_end_cost=0)'

 END LOOP;



 IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || '***** End Loop for v_MainCursor *****');
 END IF;

END LOOP;

-- DBMS_SQL.close_cursor(v_state_cursor);

DBMS_SQL.CLOSE_CURSOR(v_MainCursor);

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || '***** Close Cursor v_MainCursor *****');
END IF;

DBMS_SQL.CLOSE_CURSOR(v_SubCursor);

IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || '***** End Loop and Close Cursor v_SubCursor *****');
END IF;

------------------------------------------------------
-- Upgrade logic for Migration
-- If the user apply Upgrade patch for Migration,
-- call upgrade package for Migration
--
-- After restructure of the logic, migration package has been obsolete
------------------------------------------------------

/* ====================================================================
Client Extension:
if the client would update exception of standard code,rate,taxable cost,
he create procedure FA_DEPRN_TAX_CUSTOM_PKG.FADPCUSTOM_UPDATE by himself
and can insert their date.
==================================================================== */

   begin
      v_ExtCursor := DBMS_SQL.OPEN_CURSOR;

      l_ExtString := '
         Begin
            FA_DEPRN_TAX_CUSTOM_PKG.FADPCUSTOM_UPDATE(
               c_request_id     => :h_request_id,
               c_year           => :h_year,
               c_book_type_code => :h_book_type_code,
               c_state          => :h_state);

               fa_rx_util_pkg.debug(''fadptx_insert: '' ||
                  ''There is FA_DEPRN_TAX_CUSTOM_PKG.FADPCUSTOM_UPDATE'');

         Exception
            when others then
              FND_FILE.PUT_LINE(fnd_file.log,
                 ''Unhandled error in FA_DEPRN_TAX_CUSTOM_PKG.FADPCUSTOM_UPDATE'');
              FND_FILE.PUT_LINE(fnd_file.log,
                 ''Please check your custom procedure FA_DEPRN_TAX_CUSTOM_PKG.FADPCUSTOM_UPDATE'');
              :retcode :=2;
              :errbuf := sqlerrm;

         end;';

                DBMS_SQL.PARSE (v_ExtCursor, l_ExtString, DBMS_SQL.V7);

                DBMS_SQL.BIND_VARIABLE (v_ExtCursor,':h_request_id' ,h_request_id );
                DBMS_SQL.BIND_VARIABLE (v_ExtCursor,':h_book_type_code' ,h_book_type_code );
                DBMS_SQL.BIND_VARIABLE (v_ExtCursor,':h_year' ,h_year);
                DBMS_SQL.BIND_VARIABLE (v_ExtCursor,':h_state' ,h_state );
                DBMS_SQL.BIND_VARIABLE (v_ExtCursor,':retcode' ,retcode );
                DBMS_SQL.BIND_VARIABLE (v_ExtCursor,':errbuf' ,errbuf );

                v_ExtReturn := DBMS_SQL.EXECUTE(v_ExtCursor);

                DBMS_SQL.CLOSE_CURSOR(v_ExtCursor);

                if retcode = 2 then
                        return;
                end if;

        Exception
         when no_package then
--              IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('fadptx_insert: ' || 'There is no FA_DEPRN_TAX_CUSTOM_PKG.FADPCUSTOM_UPDATE');
--              END IF;

        end;

-- ER 7661628
if g_release <> 11 then -- Making this code not applicable to 11i
   FOR c_missing_states_rec in c_missing_states(request_id, book, state_from, state_to)
   LOOP
      INSERT INTO FA_DEPRN_TAX_REP_ITF(
         request_id,
         year,
         book_type_code,
         state,
         start_cost,
         end_cost,
         theoretical_nbv,
         evaluated_nbv,
         theoretical_taxable_cost,
         evaluated_taxable_cost,
         increase_cost,
         decrease_cost,
         created_by,
         creation_date,
         last_update_date,
         last_updated_by,
         last_update_login
         )
      VALUES(
         request_id,
         year,
         book,
         c_missing_states_rec.flex_value,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         login_id,
         sysdate,
         sysdate,
         login_id,
         login_id
      );

   END LOOP;
end if;
-- End ER 7661628

fa_rx_util_pkg.debug ('*****END FA_DEPRN_TAX_REP_PKG.FADPTX_INSERT*****');

commit;

EXCEPTION
   WHEN BOTH_NBV_ERROR THEN

      if c_nbv_update%ISOPEN then
        CLOSE c_nbv_update;
      end if;

      FND_MESSAGE.SET_NAME('OFA','FA_INVALID_COMBINATION');
      FND_MESSAGE.SET_TOKEN('COLUMN1','THEORETICAL_NBV',TRUE);
      FND_MESSAGE.SET_TOKEN('COLUMN2','EVALUATED_NBV',TRUE);
      FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get);
      retcode :=2;
      errbuf := sqlerrm;

   WHEN OTHERS THEN
      err_msg := SUBSTRB(SQLERRM,1,100);
      FND_FILE.PUT_LINE(fnd_file.log,err_msg);
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn);
      retcode :=2;
      errbuf := sqlerrm;

end fadptx_insert;

/* ======================================================================
Function
        FA_DEPRN_TAX_REP_PKG.DEBUG

DESCRIPTION
        This function is to print debug main sql.
=======================================================================*/

function debug (p_print varchar2, k number) return varchar2 is

  l_calling_fn    varchar2(50) :='fa_deprn_tax_rep_pkg.debug';

begin
        if k =0 then
--              IF (g_print_debug) THEN
                        fa_rx_util_pkg.debug('debug: ***** Main SQL: ******');
--              END IF;
--              fa_rx_util_pkg.debug(p_print); -- bug#2434220 Commented out
        end if;
--      IF (g_print_debug) THEN
                fa_rx_util_pkg.debug(p_print);
--      END IF; -- bug#2434220

--              fa_rx_util_pkg.debug('fadpxtb.pls','debug: ', p_print);

 return p_print;
exception
 when others then
   fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn);

end debug;

end FA_DEPRN_TAX_REP_PKG;

/
