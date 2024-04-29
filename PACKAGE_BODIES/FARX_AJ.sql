--------------------------------------------------------
--  DDL for Package Body FARX_AJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_AJ" as
/* $Header: farxajb.pls 120.18.12010000.4 2010/03/19 04:47:13 mswetha ship $ */

  procedure cost_adjust (
        book            in varchar2,
        begin_period    in varchar2,
        end_period      in varchar2,
        request_id      in number,
        user_id         in number,
        retcode  out nocopy number,
        errbuf   out nocopy varchar2) is

  h_count               number;
  h_book                varchar2(15);
  h_period1_pod         date;
  h_period2_pcd         date;
  h_precision           number;

  h_acct_segs           fa_rx_shared_pkg.Seg_Array;
  h_acct_struct         number;
  h_concat_acct         varchar2(500);
  h_acct_seg            number;
  h_cc_seg              number;
  h_bal_seg             number;

  h_cat_struct          number;
  h_concat_cat          varchar2(500);
  h_cat_segs            fa_rx_shared_pkg.Seg_Array;

  h_loc_struct          number;
  h_concat_loc          varchar2(500);
  h_loc_segs            fa_rx_shared_pkg.Seg_Array;

  h_login_id            number;
  h_request_id          number;

  h_mass_ref_id         number;
  h_ccid                number;
  h_asset_type          varchar2(25);
  h_category_id         number;
  h_location_id         number;
  h_emp_name            varchar2(240);
  h_emp_number          varchar2(30);
  h_cost_acct           varchar2(25);
  h_asset_number        varchar2(15);
  h_tag_number          varchar2(15);
  h_serial_number       varchar2(35);
  h_inventorial         varchar2(3);
  h_before_cost         number;
  h_after_cost          number;
  h_vendor_name         varchar2(240);
  h_invoice_number      varchar2(50);
  h_line_number         number;
  h_distribution_line_number number; -- Bug#9166346
  h_thid                number;
  h_description         varchar2(80);
  h_invoice_descr       varchar2(80);
  h_invoice_adjust      number;
  h_asset_adjust        number;
  h_inv_flag            varchar2(1);
  h_is_inv_adj          varchar2(3);
  h_group_asset_number  varchar2(15);
  h_distribution_source_book varchar2(15);

  h_mesg_name           varchar2(50);
  h_mesg_str            varchar2(2000);
  h_flex_error          varchar2(5);
  h_ccid_error          number;

cursor cost_adjust is
SELECT  TH.MASS_REFERENCE_ID,
        dhcc.code_combination_id,
        FALU.MEANING, cat_bk.category_id, dh.location_id,
        emp.name, emp.employee_number,
        DECODE(AH.ASSET_TYPE, 'CIP',CAT_BK.CIP_COST_ACCT,
                CAT_BK.ASSET_COST_ACCT),
        AD.ASSET_NUMBER,
        ad.description, ad.tag_number, ad.serial_number, ad.inventorial,
        bk_out.cost, bk_in.cost,
        DECODE(NVL(PO_IN.SEGMENT1,PO_OUT.SEGMENT1),NULL,NULL,
            NVL(PO_IN.SEGMENT1,PO_OUT.SEGMENT1)||' - '||
            NVL(PO_IN.VENDOR_NAME,PO_OUT.VENDOR_NAME)),
        nvl(AI_IN.invoice_number,AI_OUT.invoice_number) ,
        /* bug#9166346 */
        nvl(AI_IN.INVOICE_LINE_NUMBER, AI_OUT.INVOICE_LINE_NUMBER),
        NVL(AI_IN.AP_DISTRIBUTION_LINE_NUMBER, AI_OUT.AP_DISTRIBUTION_LINE_NUMBER),
        TH.TRANSACTION_HEADER_ID,
        NVL(AI_IN.DESCRIPTION,AI_OUT.DESCRIPTION),
        ROUND(SUM((DH.UNITS_ASSIGNED/AH.UNITS) *
                (
         decode(it.transaction_type,'INVOICE DELETE',
                                0-NVL(AI_IN.FIXED_ASSETS_COST,0),
                        'INVOICE REINSTATE',
                                NVL(AI_IN.FIXED_ASSETS_COST,0),
            NVL(AI_IN.FIXED_ASSETS_COST,0)-NVL(AI_OUT.FIXED_ASSETS_COST,0)
                         )
        )), h_precision),
        ROUND(SUM((DH.UNITS_ASSIGNED/AH.UNITS) *
                DECODE(TH.INVOICE_TRANSACTION_ID,NULL,
                    (NVL(BK_IN.COST,0) - NVL(BK_OUT.COST,0)),
                (
                decode(it.transaction_type,'INVOICE DELETE',
                                0-NVL(AI_IN.FIXED_ASSETS_COST,0),
                        'INVOICE REINSTATE',
                                NVL(AI_IN.FIXED_ASSETS_COST,0),
            NVL(AI_IN.FIXED_ASSETS_COST,0)-NVL(AI_OUT.FIXED_ASSETS_COST,0)
                                     )
                          ))), h_precision),
        DECODE(IT.TRANSACTION_TYPE,'INVOICE ADDITION','M',
                                   'INVOICE ADJUSTMENT','A',
                                   'INVOICE TRANSFER','T',
                                   'INVOICE DELETE','D',
                                   'INVOICE REINSTATE','R',
                                                NULL),
        DECODE(IT.TRANSACTION_TYPE, NULL, 'NO', 'YES'),
        GAD.ASSET_NUMBER GROUP_ASSET_NUMBER
FROM FA_INVOICE_TRANSACTIONS    IT,
     FA_ASSET_INVOICES          AI_IN,
     FA_ASSET_INVOICES          AI_OUT,
     FA_BOOKS                   BK_IN,
     FA_BOOKS                   BK_OUT,
     FA_TRANSACTION_HEADERS     TH,
     ( select full_name name, employee_number, person_id employee_id
       from per_people_f
       where TRUNC(SYSDATE) BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      ) EMP,
     FA_DISTRIBUTION_HISTORY    DH,
     FA_ASSET_HISTORY           AH,
     FA_CATEGORY_BOOKS          CAT_BK,
     FA_LOOKUPS                 FALU,
     PO_VENDORS                 PO_IN,
     PO_VENDORS                 PO_OUT,
     FA_ADDITIONS               AD,
     GL_CODE_COMBINATIONS       DHCC,
     FA_BOOKS                   ACTIVE_BK,
     FA_ADDITIONS_B             GAD
WHERE
        TH.TRANSACTION_TYPE_CODE IN ('ADJUSTMENT','CIP ADJUSTMENT') AND
        TH.BOOK_TYPE_CODE = h_book                          AND
        TH.INVOICE_TRANSACTION_ID = IT.INVOICE_TRANSACTION_ID (+)       AND
        TH.DATE_EFFECTIVE BETWEEN
                  h_period1_pod AND
                  nvl(h_period2_pcd,sysdate)
-- added to get the active group asset
-- in respect to the group active at end of last period
AND     ACTIVE_BK.book_type_code = h_book AND
        ACTIVE_BK.ASSET_ID = TH.ASSET_ID AND
        ACTIVE_BK.date_effective <= nvl(h_period2_pcd,sysdate) AND
        NVL(ACTIVE_BK.date_ineffective, sysdate) >= nvl(h_period2_pcd,sysdate) AND
        ACTIVE_BK.group_asset_id = gad.asset_id (+)
AND
        DH.TRANSACTION_HEADER_ID_IN <= TH.TRANSACTION_HEADER_ID AND
        NVL(DH.TRANSACTION_HEADER_ID_OUT, TH.TRANSACTION_HEADER_ID +1)
                > TH.TRANSACTION_HEADER_ID                      AND
/*fix for bug no.3803578 */
        DH.BOOK_TYPE_CODE = h_distribution_source_book  AND
        DH.ASSET_ID = TH.ASSET_ID                                   AND
        DH.CODE_COMBINATION_ID = DHCC.CODE_COMBINATION_ID
AND
        emp.employee_id (+) = dh.assigned_to
AND
        CAT_BK.CATEGORY_ID = AH.CATEGORY_ID                         AND
        CAT_BK.BOOK_TYPE_CODE = h_book
AND
        BK_IN.COST <> BK_OUT.COST
AND
        AD.ASSET_ID = TH.ASSET_ID
AND
        BK_IN.ASSET_ID(+) = TH.ASSET_ID                             AND
        BK_IN.BOOK_TYPE_CODE(+) = h_book                    AND
        BK_IN.TRANSACTION_HEADER_ID_IN(+) = TH.TRANSACTION_HEADER_ID
AND
        BK_OUT.ASSET_ID(+) = TH.ASSET_ID                            AND
        BK_OUT.BOOK_TYPE_CODE(+)||'' = h_book               AND
        BK_OUT.TRANSACTION_HEADER_ID_OUT(+) = TH.TRANSACTION_HEADER_ID
AND
        AI_IN.ASSET_ID (+) = TH.ASSET_ID                AND
        AI_IN.INVOICE_TRANSACTION_ID_IN(+) = TH.INVOICE_TRANSACTION_ID
AND
        AI_OUT.ASSET_ID(+)      = TH.ASSET_ID           AND
        AI_OUT.INVOICE_TRANSACTION_ID_OUT(+) = TH.INVOICE_TRANSACTION_ID
AND
        IT.BOOK_TYPE_CODE (+) = h_book
AND
        AH.ASSET_ID = TH.ASSET_ID                       AND
        TH.DATE_EFFECTIVE BETWEEN AH.DATE_EFFECTIVE AND
                NVL(AH.DATE_INEFFECTIVE,
                    nvl(h_period2_pcd,sysdate))
AND
        PO_IN.VENDOR_ID(+) = AI_IN.po_vendor_id         AND
        PO_OUT.VENDOR_ID(+) = AI_OUT.PO_VENDOR_ID
AND
        FALU.LOOKUP_CODE = AH.ASSET_TYPE                AND
        FALU.LOOKUP_TYPE = 'ASSET TYPE'
GROUP BY
        TH.MASS_REFERENCE_ID,
        dhcc.code_combination_id,
        FALU.MEANING,cat_bk.category_id, dh.location_id,
        emp.name, emp.employee_number,
        DECODE(AH.ASSET_TYPE, 'CIP',CAT_BK.CIP_COST_ACCT,
                CAT_BK.ASSET_COST_ACCT) ,
        AD.ASSET_NUMBER,
        AD.DESCRIPTION, ad.tag_number, ad.serial_number, ad.inventorial,
        bk_out.cost, bk_in.cost,
        DECODE(NVL(PO_IN.SEGMENT1,PO_OUT.SEGMENT1),NULL,NULL,
            NVL(PO_IN.SEGMENT1,PO_OUT.SEGMENT1)||' - '||
            NVL(PO_IN.VENDOR_NAME,PO_OUT.VENDOR_NAME)),
        nvl(AI_IN.invoice_number,AI_OUT.invoice_number),
        /* Bug#9166346 */
        nvl(AI_IN.INVOICE_LINE_NUMBER, AI_OUT.INVOICE_LINE_NUMBER),
        NVL(AI_IN.AP_DISTRIBUTION_LINE_NUMBER, AI_OUT.AP_DISTRIBUTION_LINE_NUMBER),
        TH.TRANSACTION_HEADER_ID,
        NVL(AI_IN.DESCRIPTION,AI_OUT.DESCRIPTION),
        IT.TRANSACTION_TYPE,
        GAD.ASSET_NUMBER;


begin
  h_book := book;
  h_request_id := request_id;

  select fcr.last_update_login into h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

  h_mesg_name := 'FA_AMT_SEL_PERIODS';
/* fix for bug no.3803578. Added the following query to get the distribution_source_book*/
select distribution_source_book into h_distribution_source_book
 from fa_book_controls
 where book_type_code=h_book;

  select period_open_date
  into h_period1_pod
  from fa_deprn_periods
  where book_type_code = h_book and period_name = begin_period;

  select count(*) into h_count
  from fa_deprn_periods where period_name = end_period
  and book_type_code = h_book;

  if (h_count > 0) then
    select period_close_date
    into h_period2_pcd
    from fa_deprn_periods
    where book_type_code = h_book and period_name = end_period;
  else
    h_period2_pcd := null;
  end if;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select accounting_flex_structure
  into h_acct_struct
  from fa_book_controls
  where book_type_code = h_book;

  h_mesg_name := 'FA_FA_LOOKUP_IN_SYSTEM_CTLS';

  select location_flex_structure, category_flex_structure
  into h_loc_struct, h_cat_struct
  from fa_system_controls;

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK         => h_book,
   BALANCING_SEGNUM     => h_bal_seg,
   ACCOUNT_SEGNUM       => h_acct_seg,
   CC_SEGNUM            => h_cc_seg,
   CALLING_FN           => 'COST_ADJUST');

  select cur.precision into h_precision
  from fa_book_controls bc, gl_sets_of_books sob, fnd_currencies cur
  where bc.book_type_code = h_book
  and sob.set_of_books_id = bc.set_of_books_id
  and sob.currency_code = cur.currency_code;

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open cost_adjust;
  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch cost_adjust into
        h_mass_ref_id,
        h_ccid,
        h_asset_type,
        h_category_id,
        h_location_id,
        h_emp_name,
        h_emp_number,
        h_cost_acct,
        h_asset_number,
        h_description,
        h_tag_number,
        h_serial_number, h_inventorial,
        h_before_cost,
        h_after_cost,
        h_vendor_name,
        h_invoice_number,
        h_line_number,
        h_distribution_line_number,
        h_thid,
        h_invoice_descr,
        h_invoice_adjust,
        h_asset_adjust,
        h_inv_flag,
        h_is_inv_adj,
        h_group_asset_number;

    if (cost_adjust%NOTFOUND) then exit;   end if;

        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'GL#';
        h_ccid_error := h_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_struct,
           ccid => h_ccid,
           concat_string => h_concat_acct,
           segarray => h_acct_segs);

     if (h_category_id is not null) then

        h_flex_error := 'CAT#';
        h_ccid_error := h_category_id;

        fa_rx_shared_pkg.concat_category (
           struct_id => h_cat_struct,
           ccid => h_category_id,
           concat_string => h_concat_cat,
           segarray => h_cat_segs);

     end if;

     if (h_location_id is not null) then

        h_flex_error := 'LOC#';
        h_ccid_error := h_location_id;

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_struct,
           ccid => h_location_id,
           concat_string => h_concat_loc,
           segarray => h_loc_segs);

     end if;

    h_mesg_name := 'FA_SHARED_INSERT_FAILED';

    insert into fa_adjust_rep_itf (
        request_id, mass_ref_id, company, cost_center,
        expense_Acct, cost_acct, employee_name, employee_number,
        location, category,
        asset_number, description, tag_number, serial_number, inventorial,
        before_cost, after_cost, vendor_name, invoice_number,
        line_number,distribution_line_number, invoice_description, transaction_header_id,
        invoice_adjustment, asset_adjustment, inv_trx_flag,
        is_inv_adj_flag, created_by, creation_date,
        last_updated_by, last_update_date, last_update_login, group_asset_number)
        values (request_id, h_mass_ref_id, h_acct_segs(h_bal_seg),
        h_acct_segs(h_cc_seg), h_acct_segs(h_acct_seg),
        h_cost_acct, h_emp_name, h_emp_number,
        h_concat_loc, h_concat_cat, h_asset_number,
        h_description, h_tag_number, h_serial_number, h_inventorial,
        h_before_cost, h_after_cost, h_vendor_name,
        h_invoice_number, h_line_number,h_distribution_line_number, h_invoice_descr, h_thid,
        h_invoice_adjust, h_asset_adjust,
        h_inv_flag, h_is_inv_adj,
        user_id, sysdate, user_id, sysdate, h_login_id, h_group_asset_number);



  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close cost_adjust;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
        fnd_message.set_token('TABLE','FA_ADJUST_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;


end cost_adjust;




procedure cost_clear_rec (
        book            in varchar2,
        period          in varchar2,
        request_id      in number,
        user_id         in number,
        retcode  out nocopy number,
        errbuf   out nocopy varchar2)  is


  h_book                varchar2(15);
  h_count               number;
  h_period1_pod         date;
  h_period1_pcd         date;


  h_fa_ccid             number;
  h_ar_ccid             number;
  h_thcode              varchar2(25);
  h_asset_number        varchar2(15);
  h_description         varchar2(80);
  h_tag_number          varchar2(15);
  h_serial_number       varchar2(35);
  h_inventorial         varchar2(3);
  h_vendor_name         varchar2(240);
  h_invoice_number      varchar2(50);
  h_line_number         number;
  h_distribution_line_number number; --Bug#9166346
  h_inv_description     varchar2(80);
  h_payables_cost       number;

  h_acct_struct         number;
  h_ar_acct_segs        fa_rx_shared_pkg.Seg_Array;
  h_fa_acct_segs        fa_rx_shared_pkg.Seg_Array;
  h_concat_ar           varchar2(500);
  h_concat_fa           varchar2(500);
  h_bal_seg             number;
  h_cc_seg              number;
  h_acct_seg            number;

  h_request_id          number;
  h_login_id            number;

  h_mesg_name           varchar2(50);
  h_mesg_str            varchar2(2000);
  h_flex_error          varchar2(5);
  h_ccid_error          number;


cursor cost_clear_lines is
select  dh.code_combination_id,glcc_ar.code_combination_id,
                lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        -- Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description,
        sum(nvl(ai_in.payables_cost,0) * nvl(dh.units_assigned, ah.units) / ah.units )
from
                po_vendors              po_ai_in,
         fa_lookups             lu,
        gl_code_combinations            glcc_ar,
        fa_additions            ad,
        fa_distribution_history dh,
        fa_asset_history                ah,
        fa_asset_invoices               ai_in,
        fa_transaction_headers  th
where
        lu.lookup_code         = 'CIP ADDITION' and
        lu.lookup_type         = 'FAXOLTRX' and
        ah.asset_type          = 'CIP' and
        th.date_effective between
                h_period1_pod   and
                nvl(h_period1_pcd,sysdate) and
        th.book_type_code       = h_book                                and
        th.transaction_type_code = 'TRANSFER IN'
and     dh.asset_id             = th.asset_id
and     dh.transaction_header_id_in = th.transaction_header_id
and     ad.asset_id             = th.asset_id
and     ah.asset_id             = th.asset_id                   and
        ah.date_effective       <=
                nvl(h_period1_pcd,sysdate)      and
        nvl(ah.date_ineffective,sysdate) >=
                nvl(h_period1_pcd,sysdate)
and     ai_in.asset_id          = th.asset_id                           and
        ai_in.date_effective    <=
                nvl(h_period1_pcd,sysdate) and
        nvl(ai_in.date_ineffective,sysdate) >=
                nvl(h_period1_pcd,sysdate)
and     glcc_ar.code_combination_id = ai_in.payables_code_combination_id
and     nvl(ai_in.payables_cost, 0) <> 0
and             po_ai_in.vendor_id (+)  = ai_in.po_vendor_id
group by
        dh.code_combination_id,
        glcc_ar.code_combination_id,
                lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        -- Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description
union
select  dh.code_combination_id,glcc_ar.code_combination_id,
                lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        -- Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description,
        sum(nvl(ai_in.payables_cost,0) * nvl(dh.units_assigned, ah.units) / ah.units )
from
                po_vendors              po_ai_in,
         fa_lookups             lu,
        gl_code_combinations            glcc_ar,
        fa_additions            ad,
        fa_distribution_history dh,
        fa_asset_history                ah,
        fa_asset_invoices               ai_in,
        fa_transaction_headers  th
where
        lu.lookup_code         = 'ADDITION' and
        lu.lookup_type         = 'FAXOLTRX' and
        ah.asset_type          <> 'CIP' and
        th.date_effective between
                h_period1_pod   and
                nvl(h_period1_pcd,sysdate) and
        th.book_type_code       = h_book                                and
        th.transaction_type_code = 'TRANSFER IN'
and     dh.asset_id             = th.asset_id
and     dh.transaction_header_id_in = th.transaction_header_id
and     ad.asset_id             = th.asset_id
and     ah.asset_id             = th.asset_id                   and
        ah.date_effective       <=
                nvl(h_period1_pcd,sysdate)      and
        nvl(ah.date_ineffective,sysdate) >=
                nvl(h_period1_pcd,sysdate)
and     ai_in.asset_id          = th.asset_id                           and
        ai_in.date_effective    <=
                nvl(h_period1_pcd,sysdate) and
        nvl(ai_in.date_ineffective,sysdate) >=
                nvl(h_period1_pcd,sysdate)
and     glcc_ar.code_combination_id = ai_in.payables_code_combination_id
and     nvl(ai_in.payables_cost, 0) <> 0
and             po_ai_in.vendor_id (+)  = ai_in.po_vendor_id
group by
        dh.code_combination_id,
        glcc_ar.code_combination_id,
                lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        --Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description
union
select  dh.code_combination_id,
        glcc_ar.code_combination_id,
        lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        --Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description,
        sum(nvl(ai_in.payables_cost,0) * nvl(dh.units_assigned, ah.units) / ah.units )
from    po_vendors              po_ai_in,
                fa_lookups              lu,
        gl_code_combinations            glcc_ar,
        fa_additions            ad,
        fa_distribution_history dh,
        fa_asset_history        ah,
        fa_invoice_transactions it,
        fa_asset_invoices               ai_in,
        fa_transaction_headers  tht,
        fa_transaction_headers  th
where   it.book_type_code      = h_book                                 and
        it.invoice_transaction_id = th.invoice_transaction_id           and
        it.transaction_type     = 'MASS ADDITION'
and     lu.lookup_code         = decode(th.transaction_type_code,
                                'ADDITION/VOID','ADDITION',
                                th.transaction_type_code)               and
        lu.lookup_type         = 'FAXOLTRX'
and     th.date_effective between
                h_period1_pod                                   and
                nvl(h_period1_pcd,sysdate)                                      and
        th.book_type_code       = h_book                                and
        th.transaction_type_code in
                ('CIP ADJUSTMENT', 'ADJUSTMENT', 'ADDITION','ADDITION/VOID')
and     tht.date_effective <
                h_period1_pod   and
        tht.book_type_code      = h_book                         and
        tht.asset_id            = th.asset_id                   and
        tht.transaction_type_code = 'TRANSFER IN'
and     dh.asset_id             = tht.asset_id
and     dh.transaction_header_id_in = tht.transaction_header_id
and     ad.asset_id = th.asset_id
and     ah.asset_id             = th.asset_id                   and
        ah.date_effective       <=
                nvl(h_period1_pcd,sysdate)      and
        nvl(ah.date_ineffective,sysdate) >=
                nvl(h_period1_pcd,sysdate)
and     ai_in.asset_id         = th.asset_id                            and
        ai_in.payables_code_combination_id
                = glcc_ar.code_combination_id
and     ai_in.invoice_transaction_id_in = it.invoice_transaction_id
and             ai_in.date_effective     <= th.date_effective                           and
        nvl(ai_in.date_ineffective,sysdate) >= th.date_effective
and     nvl(ai_in.payables_cost, 0) <> 0
and      ai_in.po_vendor_id     = po_ai_in.vendor_id(+)
group by
        dh.code_combination_id,
        glcc_ar.code_combination_id,
                lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        --Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description
union   /* FA's bal, AR's cc and acct */
select  glcc_fa.code_combination_id, glcc_ar.code_combination_id,
        lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        --Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description,
        sum((decode(ai_in.deleted_flag, 'YES', 0,
                nvl(ai_in.fixed_assets_cost, 0)) -
                        nvl(ai_in.payables_cost, 0))
            * (nvl (dh.units_assigned, ah.units) /
                        ah.units))
from    po_vendors                              po_ai_in,
         fa_lookups             lu,
        fa_distribution_history dh,
        gl_code_combinations            glcc_fa,
        gl_code_combinations     glcc_ar,
        fa_additions            ad,
        fa_asset_history                ah,
        fa_category_books        cat_bk,
        fa_asset_invoices               ai_in,
        fa_transaction_headers  th
where
        lu.lookup_code         = decode(ah.asset_type, 'CIP',
                                'CIP ADDITION', 'ADDITION')             and
        lu.lookup_type         = 'FAXOLTRX'
and     th.date_effective between
                h_period1_pod                                   and
                nvl(h_period1_pcd,sysdate)                                      and
        th.book_type_code       = h_book                                and
        th.transaction_type_code = 'TRANSFER IN'
and     ad.asset_id             = th.asset_id
and     ah.asset_id             = th.asset_id                           and
        ah.date_effective       <=
                nvl(h_period1_pcd,sysdate)      and
        nvl(ah.date_ineffective,sysdate) >=
                nvl(h_period1_pcd,sysdate)      and
        ah.asset_type           <> 'EXPENSED'
and     cat_bk.book_type_code   = h_book                                and
        cat_bk.category_id      = ah.category_id
and     dh.book_type_code       = h_book                                and
        dh.asset_id             = th.asset_id                           and
        dh.date_effective  <=
                nvl(h_period1_pcd,sysdate) and
        nvl(dh.date_ineffective,sysdate) >=
                nvl(h_period1_pcd,sysdate)

and     glcc_fa.code_combination_id = dh.code_combination_id
and     ai_in.asset_id         = th.asset_id                            and
        ai_in.date_effective  <=
                nvl(h_period1_pcd,sysdate) and
        nvl(ai_in.date_ineffective,sysdate) >=
                nvl(h_period1_pcd,sysdate)      and
        nvl(ai_in.fixed_assets_cost,0) <>
                nvl(ai_in.payables_cost,0)
and     decode(ah.asset_type,'CIP',cat_bk.wip_clearing_account_ccid,
                                    cat_bk.asset_clearing_account_ccid)
                                = glcc_ar.code_combination_id
and     po_ai_in.vendor_id (+)  = ai_in.po_vendor_id
group by
        glcc_fa.code_combination_id, glcc_ar.code_combination_id,
                lu.meaning,
        ad.asset_number, ad.description,  ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        --Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description
union
select  glcc_fa.code_combination_id, glcc_ar.code_combination_id,
                lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, null,
        null,
        to_number (null),
        to_number (null), -- Bug#9166346
        null,
        round(sum((bk_in.cost - nvl(bk_out.cost,0)) *
                dh.units_assigned / ah.units),2)
from    fa_books                bk_in,
        fa_books                bk_out,
        fa_distribution_history dh,
        fa_lookups              lu,
        gl_code_combinations    glcc_fa,
        gl_code_combinations    glcc_ar,
        fa_additions            ad,
        fa_asset_history        ah,
        fa_category_books       cat_bk,
        fa_transaction_headers  th
where
        th.book_type_code  = h_book                             and
        th.invoice_transaction_id is null                               and
        th.transaction_type_code in ('CIP ADDITION', 'CIP ADDITION/VOID',
        'ADDITION','ADDITION/VOID', 'ADJUSTMENT', 'CIP ADJUSTMENT')     and
        th.date_effective between
                h_period1_pod and
                nvl(h_period1_pcd,sysdate)
and     lu.lookup_code         = decode(ah.asset_type, 'CIP',
                                   decode(th.transaction_type_code,
                                        'CIP ADDITION/VOID','CIP ADDITION',
                                        'ADDITION/VOID','CIP ADDITION',
                                        th.transaction_type_code),
                                   decode(th.transaction_type_code,
                                        'CIP ADDITION/VOID','ADDITION',
                                        'ADDITION/VOID','ADDITION',
                                        th.transaction_type_code)) and
        lu.lookup_type          = 'FAXOLTRX'
and     ad.asset_id             = th.asset_id
and     ah.asset_id             = th.asset_id                           and
        ah.date_effective <=
                decode(th.transaction_type_code,
                'CIP ADJUSTMENT', th.date_effective,
                'ADJUSTMENT', th.date_effective,
                nvl(h_period1_pcd,sysdate)) and
        nvl(ah.date_ineffective,sysdate) >=
                decode(th.transaction_type_code,
                'CIP ADJUSTMENT', th.date_effective,
                'ADJUSTMENT', th.date_effective,
                nvl(h_period1_pcd,sysdate)) and
        ah.asset_type         <> 'EXPENSED'
and     bk_in.transaction_header_id_in = th.transaction_header_id
and     bk_out.transaction_header_id_out(+) = th.transaction_header_id
and     dh.book_type_code       = h_book                                and
        dh.asset_id             = th.asset_id                   and
        dh.date_effective       <=
                decode(th.transaction_type_code,
                'CIP ADJUSTMENT', th.date_effective,
                'ADJUSTMENT', th.date_effective,
                nvl(h_period1_pcd,sysdate)) and
        nvl(dh.date_ineffective,sysdate) >=
                decode(th.transaction_type_code,
                'CIP ADJUSTMENT', th.date_effective,
                'ADJUSTMENT', th.date_effective,
                nvl(h_period1_pcd,sysdate))
and     glcc_fa.code_combination_id     = dh.code_combination_id
and     cat_bk.category_id      = ah.category_id                                and
        cat_bk.book_type_code   = h_book                        and
        decode(ah.asset_type,'CIP',cat_bk.wip_clearing_account_ccid,
                                   cat_bk.asset_clearing_account_ccid)
                               = glcc_ar.code_combination_id
and             bk_in.cost            <> nvl(bk_out.cost,0)
group by
        glcc_ar.code_combination_id, glcc_fa.code_combination_id,
                lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial
union
select  glcc_fa.code_combination_id, glcc_ar.code_combination_id,
         lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        --Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description,
        round(sum(decode(it.transaction_type,
        'INVOICE ADJUSTMENT',
                nvl(ai_in.fixed_assets_cost,0) -
                nvl(ai_out.fixed_assets_cost,0),
        'INVOICE DELETE',
                -nvl(ai_in.fixed_assets_cost,0),
        'INVOICE REINSTATE',
                nvl(ai_in.fixed_assets_cost,0),
        nvl(ai_in.fixed_assets_cost, 0) -
                        nvl(ai_in.payables_cost, 0))
            * (dh.units_assigned / ah.units)),2)
from    fa_asset_invoices               ai_out,
                po_vendors              po_ai_in,
         fa_lookups             lu,
        fa_distribution_history dh,
        gl_code_combinations     glcc_fa,
        gl_code_combinations            glcc_ar,
        fa_additions            ad,
         fa_asset_history               ah,
        fa_category_books               cat_bk,
        fa_transaction_headers  th,
        fa_invoice_transactions it,
        fa_asset_invoices               ai_in
where   it.book_type_code       = h_book  and
        ((it.transaction_type   = 'MASS ADDITION'       and
         nvl(ai_in.fixed_assets_cost,0) <>
                nvl(ai_in.payables_cost,0))                     or
        (it.transaction_type    = 'INVOICE ADDITION'            and
         nvl(ai_in.fixed_assets_cost,0) <> 0)                   or
        (it.transaction_type    = 'INVOICE ADJUSTMENT'          and
         nvl(ai_in.fixed_assets_cost,0) <>
                nvl(ai_out.fixed_assets_cost,0))                or
         (it.transaction_type = 'INVOICE DELETE'                and
         nvl(ai_in.fixed_assets_cost,0) <> 0)                   or
         (it.transaction_type = 'INVOICE REINSTATE'             and
         nvl(ai_in.fixed_assets_cost,0) <> 0))
and     lu.lookup_code         = th.transaction_type_code       and
        lu.lookup_type         = 'FAXOLTRX'
and     th.date_effective between
                h_period1_pod                           and
                nvl(h_period1_pcd,sysdate) and
        th.invoice_transaction_id = it.invoice_transaction_id           and
        th.transaction_type_code in ('ADJUSTMENT', 'CIP ADJUSTMENT')    and
        th.book_type_code       = h_book
and     ad.asset_id = th.asset_id                                       and
        ad.asset_id = ah.asset_id
and             ah.date_effective     <= th.date_effective                      and
        nvl(ah.date_ineffective,sysdate) >= th.date_effective           and
        ah.category_id         = cat_bk.category_id                     and
        ah.asset_type           <> 'EXPENSED'
and             cat_bk.book_type_code   = h_book
and     dh.book_type_code       = h_book                        and
        dh.asset_id             = th.asset_id           and
        dh.date_effective       <= th.date_effective                    and
        nvl(dh.date_ineffective,sysdate) >= th.date_effective
and
        dh.code_combination_id = glcc_fa.code_combination_id
and     ai_in.invoice_transaction_id_in = th.invoice_transaction_id     and
        ai_in.asset_id = th.asset_id                            and
        ai_in.date_effective  <= th.date_effective                      and
        nvl(ai_in.date_ineffective,sysdate) >= th.date_effective
and             decode(ah.asset_type,'CIP',cat_bk.wip_clearing_account_ccid,
                                    cat_bk.asset_clearing_account_ccid)
                               = glcc_ar.code_combination_id
and     ai_out.invoice_transaction_id_out (+)
                        = ai_in.invoice_transaction_id_in               and
        ai_out.asset_id (+) = ai_in.asset_id                            and
        ai_out.asset_invoice_id (+) = ai_in.asset_invoice_id
and     po_ai_in.vendor_id (+)  = ai_in.po_vendor_id
group by
        glcc_fa.code_combination_id, glcc_ar.code_combination_id,
                lu.meaning,
        ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
        ad.inventorial, po_ai_in.vendor_name,
        ai_in.invoice_number,
        --Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
        ai_in.description
union
--propagetd fix for bug 3375136 starts
select
         lines.code_combination_id, --adj1.code_combination_id,
         lines.code_combination_id, --adj1.code_combination_id,
         lu.meaning,
         ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
         ad.inventorial, po_ai_in.vendor_name,
         ai_in.invoice_number,
         --Bug#9166346
         ai_in.invoice_line_number,
         ai_in.ap_distribution_line_number,
         ai_in.description,
         round(sum(decode(th.asset_id,
                                     ai_in.asset_id,
                 nvl(ai_in.fixed_assets_cost,0),
                                     ai_out.asset_id,
                 -nvl(ai_out.fixed_assets_cost,0),0)
             * (dh.units_assigned / ah.units)),2)
 from    fa_asset_invoices                ai_out,
         po_vendors                po_ai_in,
         fa_lookups                lu,
         fa_distribution_history        dh,
         gl_code_combinations            glcc_fa,
         gl_code_combinations            glcc_ar,
         fa_additions                ad,
         fa_asset_history                ah,
         fa_category_books               cat_bk,
         fa_transaction_headers        th,
         fa_invoice_transactions        it,
         fa_asset_invoices                ai_in,
         fa_adjustments                        adj1

        /* SLA Changes */
        ,xla_ae_headers headers
        ,xla_ae_lines lines
        ,xla_distribution_links links
        ,fa_book_controls bc

 where   bc.book_type_code           = h_book and
         it.book_type_code        = h_book  and
         it.transaction_type         = 'INVOICE TRANSFER'         and
         nvl(ai_in.fixed_assets_cost,0) <> 0
 and     lu.lookup_code                = th.transaction_type_code and
         lu.lookup_type         = 'FAXOLTRX'
 and     th.date_effective between
                 h_period1_pod         and
                 nvl(h_period1_pcd,sysdate) and
         th.invoice_transaction_id = it.invoice_transaction_id            and
         th.transaction_type_code in ('ADJUSTMENT', 'CIP ADJUSTMENT')        and
         th.book_type_code          = h_book
 and     ad.asset_id = th.asset_id                                           and
         ad.asset_id = ah.asset_id
 and      ah.date_effective     <= th.date_effective                        and
         nvl(ah.date_ineffective,sysdate) >= th.date_effective                and
         ah.category_id                = cat_bk.category_id        and
         ah.asset_type                <> 'EXPENSED'
 and             cat_bk.book_type_code        = h_book
 and     dh.book_type_code        = h_book                        and
         dh.asset_id                = th.asset_id                and
         dh.date_effective        <= th.date_effective                        and
         nvl(dh.date_ineffective,sysdate) >= th.date_effective
 and
         dh.code_combination_id = glcc_fa.code_combination_id
 and     ai_in.invoice_transaction_id_in = th.invoice_transaction_id        and
         ai_in.date_effective  <= th.date_effective                        and
         nvl(ai_in.date_ineffective,sysdate) >= th.date_effective
 and             decode(ah.asset_type,'CIP',cat_bk.wip_clearing_account_ccid,
                                     cat_bk.asset_clearing_account_ccid)
                                 = glcc_ar.code_combination_id
 and     ai_out.invoice_transaction_id_out
                         = ai_in.invoice_transaction_id_in        and
         ai_out.asset_invoice_id = ai_in.asset_invoice_id
 and             ai_in.po_vendor_id     = po_ai_in.vendor_id(+)

 and     ai_out.asset_id  = ai_in.asset_id /* Added for High Cost SQL - to remove FTS on FA-ASSET_INVOICES*/


 and     adj1.book_type_code        = h_book                        and
         adj1.asset_id                = th.asset_id
 and     adj1.adjustment_type = 'COST CLEARING'
 and     adj1.transaction_header_id = th.transaction_header_id

    /* SLA Changes */
    and links.Source_distribution_id_num_1 = adj1.transaction_header_id
    and links.Source_distribution_id_num_2 = adj1.adjustment_line_id
    and links.application_id               = 140
    and links.source_distribution_type     = 'TRX'
    and headers.ae_header_id               = links.ae_header_id
    and headers.ledger_id                  = bc.set_of_books_id
    and headers.application_id             = 140
    and lines.ae_header_id                 = links.ae_header_id
    and lines.ae_line_num                  = links.ae_line_num
    and lines.application_id               = 140
 group by
         lines.code_combination_id, --adj1.code_combination_id,
         lu.meaning,
         ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
         ad.inventorial, po_ai_in.vendor_name,
         ai_in.invoice_number,
         --Bug#9166346
        ai_in.invoice_line_number,
        ai_in.ap_distribution_line_number,
         ai_in.description;
--propagetd fix for bug 3375136 ends

 cc_value       gl_code_combinations.segment1%TYPE;
begin

  retcode := 0;
  h_book := book;
  h_request_id := request_id;

  select fcr.last_update_login into h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

  h_mesg_name := 'FA_AMT_SEL_PERIODS';

  select period_open_date, period_close_date
  into h_period1_pod, h_period1_pcd
  from fa_deprn_periods
  where book_type_code = h_book and period_name = period;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select accounting_flex_structure
  into h_acct_struct
  from fa_book_controls
  where book_type_code = h_book;

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK         => h_book,
   BALANCING_SEGNUM     => h_bal_seg,
   ACCOUNT_SEGNUM       => h_acct_seg,
   CC_SEGNUM            => h_cc_seg,
   CALLING_FN           => 'COST_CLEAR_REC');


  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open cost_clear_lines;
  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch cost_clear_lines into
        h_fa_ccid,
        h_ar_ccid,
        h_thcode,
        h_asset_number,
        h_description,
        h_tag_number,
        h_serial_number,
        h_inventorial,
        h_vendor_name,
        h_invoice_number,
        h_line_number,
        h_distribution_line_number,   -- Bug#9166346
        h_inv_description,
        h_payables_cost;




    if (cost_clear_lines%NOTFOUND) then exit;  end if;

        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'GL#';
        h_ccid_error := h_ar_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_struct,
           ccid => h_ar_ccid,
           concat_string => h_concat_ar,
           segarray => h_ar_acct_segs);

    if (h_fa_ccid is not null) then

        h_flex_error := 'GL#';
        h_ccid_error := h_fa_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_struct,
           ccid => h_fa_ccid,
           concat_string => h_concat_fa,
           segarray => h_fa_acct_segs);

        h_ar_acct_segs(h_bal_seg) := h_fa_acct_segs(h_bal_seg);
    else
        h_fa_acct_segs(h_bal_seg) := null;
        h_fa_acct_segs(h_cc_seg) := null;
        h_fa_acct_segs(h_acct_seg) := null;
    end if;


    h_mesg_name := 'FA_SHARED_INSERT_FAILED';
    -- Bug#9166346
    insert into fa_costclear_rep_itf (
        request_id, company, cost_Center, account, transaction_type,
        asset_number, description, tag_number, serial_number,
        vendor_name, invoice_number, line_number,distribution_line_number, inventorial,
        inv_description, payables_cost, created_by,
        creation_date, last_updated_by, last_update_date,
        last_update_login) values (request_id,
        h_ar_acct_segs(h_bal_seg), h_fa_acct_segs(h_cc_seg),
        h_ar_acct_segs(h_acct_seg), h_thcode, h_asset_number, h_description,
        h_tag_number, h_serial_number, h_vendor_name,
        h_invoice_number, h_line_number,h_distribution_line_number, h_inventorial, h_inv_description,
        h_payables_cost, user_id, sysdate, user_id, sysdate, h_login_id);



  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close cost_clear_lines;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
        fnd_message.set_token('TABLE','FA_COSTCLEAR_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

end cost_clear_rec;

END FARX_AJ;

/
