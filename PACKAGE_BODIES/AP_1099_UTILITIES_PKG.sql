--------------------------------------------------------
--  DDL for Package Body AP_1099_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_1099_UTILITIES_PKG" AS
/* $Header: ap1099utlb.pls 120.11.12010000.3 2009/10/06 12:49:38 ppodhiya ship $ */

   PROCEDURE insert_1099_data
     ( p_calling_module IN varchar2,
       p_sob_id         IN number,
       p_tax_entity_id  IN number,
       p_combined_flag  IN varchar2,
       p_start_date     IN date,
       p_end_date       IN date,
       p_vendor_id      IN number,
       p_query_driver   IN varchar2,
       p_min_reportable_flag IN varchar2,
       p_federal_reportable_flag in varchar2,
       p_region varchar2) is

   l_chart_of_accounts_id number;
   l_app_column_name varchar2(25);

   l_dynamic_sql1   varchar2(4000);
   l_dynamic_sql2   varchar2(4000);
   l_dynamic_sql2_1 varchar2(4000);
   l_dynamic_sql3   varchar2(4000);

   l_id_start_date date;
   l_id_end_date date;

   l_org_id number;  -- Bug 4946930
x number;

   begin

   l_org_id := mo_global.get_current_org_id;
   l_id_start_date := p_start_date-1;
   l_id_end_date := p_end_date+1;


   SELECT fnd.application_column_name, gl.chart_of_accounts_id
   INTO   l_app_column_name, l_chart_of_accounts_id
   FROM fnd_segment_attribute_values fnd, gl_sets_of_books gl
   WHERE segment_attribute_type = 'GL_BALANCING'
   AND fnd.attribute_value = 'Y'
   AND fnd.id_flex_code = 'GL#'
   AND fnd.id_flex_num = gl.chart_of_accounts_id
   AND gl.set_of_books_id = p_sob_id;


   l_dynamic_sql1:=
        'INSERT INTO ap_1099_tape_data '
||                '(vendor_id,region_code,'
||                 'misc1,misc2,misc3,misc4,misc5,'
||                ' misc6,misc7,misc8,misc9,misc10,'
||                 'misc13, misc14, misc15aNT, misc15aT, misc15b,org_id) '    -- Bug 4946930
||        'SELECT  P.vendor_id,';

   if p_combined_flag = '1' then
      l_dynamic_sql1 := l_dynamic_sql1 || 'ITR.region_code,';
   else
      l_dynamic_sql1 := l_dynamic_sql1 || 'null,';
   end if;

   l_dynamic_sql1 := l_dynamic_sql1
||                'round(sum(decode(ID.type_1099,''MISC1'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''|| l_id_end_date||'''  ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                        ' decode( INV_NET_AMT.netamount ,0,1,'     /*Bug5943123  This change is done in almost 15 places in this same pls*/
||                                ' INV_NET_AMT.netamount ))'
-- Bug 5768112. Backing out the fix of bug 5620442
--||                       ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                       ' *IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC2'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC3'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                        'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                   ' decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||             ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                '-1*(round(sum(decode(ID.type_1099,''MISC4'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2)),' -- Bug 5260442
||                        '*IP.amount),0)),2)),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC5'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC6'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC7'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),'; -- Bug 5260442
||                        '*IP.amount),0)),2),'; -- Bug 5768112

   l_dynamic_sql2:=  'round(sum(decode(ID.type_1099,''MISC8'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                        ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC9'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                        ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC10'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC13'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC14'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' ;-- Bug 5260442
||                        '*IP.amount),0)),2), '; -- Bug 5768112

l_dynamic_sql2_1 := 'round(sum(decode(ID.type_1099,''MISC15a NT'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC15a T'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC15b'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2), ' -- Bug 5768112
||			  l_org_id     -- Bug 4946930
||        ' FROM    ap_income_tax_regions ITR, '
||                'ap_reporting_entity_lines_all REL, '
||                'po_vendors P, '
||                'ce_bank_accounts ABA, ' --for bug 6275528 - replaced ap_bank_accounts_all with ce_bank_Accounts
                                           --as ap_bank_accounts_All is obsolete in R12.
||                'ce_bank_acct_uses_all BAU, ' -- Bug 6604204. Included table to join AP_CHECKS and
                                                -- CE_BANK_ACCOUNTS table.
||                'ap_checks_all AC, '
||                'ap_invoices_all I, '
||                'gl_code_combinations CC, '
||                'ap_invoice_distributions_all ID, '
||                'ap_invoice_payments_all IP,'   --Bug 6064614 --for bug 6275528 - changed ap_invoice_payments
                                                  --to ap_invoice_payments_all.
||    '( select  AI.invoice_id ,  nvl(AIL1.amount+AI.invoice_amount , AI.invoice_amount) as netamount  '         --Bug5943123
||    ' from  ap_invoices_all AI, ( select AIL.invoice_id, SUM(AIL.amount) as amount   '
||    '                    FROM ap_invoice_lines_all AIL     '                               --Bug6064614
||	'						WHERE (nvl(AIL.invoice_includes_prepay_flag,''N'') = ''N''  '   --Bug6052333
||	'						AND (AIL.line_type_lookup_code = ''PREPAY''  '
||	'						OR (AIL.line_type_lookup_code =''TAX''  '
||	'						AND AIL.prepay_invoice_id IS NOT NULL   '
||	'						AND AIL.prepay_line_number IS NOT NULL))) '
||    '                        OR  AIL.line_type_lookup_code  = ''AWT'' '
||    '                    GROUP by AIL.invoice_id  ) AIL1  '                                                  --Bug5943123
||    '                 where AI.invoice_id = AIL1.invoice_id (+)   ) INV_NET_AMT   '
||        'WHERE   ID.income_tax_region = ITR.region_short_name (+) '
||        'AND     P.vendor_id=I.vendor_id '
||        'AND     (AC.void_date is null '
||        '         OR AC.void_date NOT BETWEEN '''|| p_start_date || ''' AND '''|| p_end_date || ''') ' --4480766, 8925235
||        'AND     I.invoice_id=IP.invoice_id '
||        'AND     I.invoice_id=ID.invoice_id '
||        'AND     INV_NET_AMT.invoice_id = I.invoice_id '
||        'AND     IP.accounting_date BETWEEN '''|| p_start_date || ''' AND '''|| p_end_date || ''' '
||        'AND     ID.type_1099 is not null '
---- ||        'AND     AC.bank_account_id = ABA.bank_account_id '  Commeted this for bug 6275528 - as in ap_checks_all
               ---bank_account_id is not getting stamped in R12.bank_account_anme is there so we will use it.
--||        'AND     AC.bank_account_name = ABA.bank_account_name ' --added for bug  6275528 for the aobve explained reason.
                                                                    -- Commented for Bug 6604204.
||        'AND     AC.ce_bank_acct_use_id = BAU.bank_acct_use_id '  -- Bug 6604204. Please refer bug for details.
||        'AND     BAU.bank_account_id = ABA.bank_account_id '      -- Bug 6604204. Please refer bug for details.
||        'AND     AC.org_id = mo_global.get_current_org_id '   --added for bug 6275528
||        'AND     IP.check_id = AC.check_id '
||        'AND     REL.tax_entity_id = ' || p_tax_entity_id|| ' '
||        'AND     CC.chart_of_accounts_id = ' || l_chart_of_accounts_id || ' ';


   if p_calling_module = 'PAYMENTS REPORT' and nvl(p_federal_reportable_flag,'N') = 'N' then
     null;
   else -- for all other situations we want federal reportable vendors only
     l_dynamic_sql3:= 'AND P.federal_reportable_flag = ''Y'' ';
   end if;

   if p_vendor_id is not null then
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND P.vendor_id = '||p_vendor_id||' ';
   end if;

   if p_query_driver = 'INV' then
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND ID.dist_code_combination_id = CC.code_combination_id ';
   else
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND ABA.asset_code_combination_id = CC.code_combination_id ';
   end if;

   if p_region is not null then
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND id.income_tax_region = '''|| p_region ||''' ';
   end if;

   if (l_app_column_name LIKE 'SEGMENT1') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment1 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT2') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment2 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT3') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment3 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT4') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment4 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT5') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment5 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT6') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment6 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT7') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment7 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT8') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment8 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT9') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment9 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT10') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment10 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT11') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment11 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT12') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment12 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT13') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment13 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT14') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment14 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT15') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment15 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT16') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment16 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT17') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment17 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT18') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment18 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT19') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment19 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT20') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment20 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT21') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment21 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT22') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment22 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT23') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment23 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT24') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment24 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT25') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment25 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT26') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment26 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT27') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment27 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT28') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment28 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT29') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment29 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT30') THEN
    l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment30 = REL.balancing_segment_value ';
   end if;

   if p_combined_flag = '1' then
     l_dynamic_sql3 := l_dynamic_sql3 || 'GROUP BY ITR.region_code, P.vendor_id';
   else
     l_dynamic_sql3 := l_dynamic_sql3 || 'GROUP BY P.vendor_id';
   end if;

   declare
   stemp    VARCHAR2(80);
   nlength  NUMBER := 1;

   BEGIN

     WHILE(length(l_dynamic_sql1) >= nlength)
     LOOP
        stemp := substrb(l_dynamic_sql1, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
       nlength := (nlength + 80);
     END LOOP;
   end;

   declare
   stemp    VARCHAR2(80);
   nlength  NUMBER := 1;

   BEGIN

     WHILE(length(l_dynamic_sql2) >= nlength)
     LOOP
        stemp := substrb(l_dynamic_sql2, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
       nlength := (nlength + 80);
     END LOOP;
   end;

   declare
   stemp    VARCHAR2(80);
   nlength  NUMBER := 1;

   BEGIN

     WHILE(length(l_dynamic_sql2_1) >= nlength)
     LOOP
        stemp := substrb(l_dynamic_sql2_1, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
       nlength := (nlength + 80);
     END LOOP;
   end;

   declare
   stemp    VARCHAR2(80);
   nlength  NUMBER := 1;

   BEGIN

     WHILE(length(l_dynamic_sql3) >= nlength)
     LOOP
        stemp := substrb(l_dynamic_sql3, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
       nlength := (nlength + 80);
     END LOOP;
   end;

   execute immediate l_dynamic_sql1 || l_dynamic_sql2 || l_dynamic_sql2_1 || l_dynamic_sql3;

   select count(*) into x from ap_1099_tape_data;
    fnd_file.put_line(FND_FILE.LOG, to_char(x));


   end insert_1099_data;

   -- Added for backup withholding enhancement.
   -- Please refer bug8947583 for details.

   PROCEDURE do_awt_withholding_update
     ( p_calling_module IN varchar2,
       p_sob_id         IN number,
       p_tax_entity_id  IN number,
       p_combined_flag  IN varchar2,
       p_start_date     IN date,
       p_end_date       IN date,
       p_vendor_id      IN number,
       p_query_driver   IN varchar2,
       p_min_reportable_flag IN varchar2,
       p_federal_reportable_flag in varchar2,
       p_region varchar2) is

   l_chart_of_accounts_id number;
   l_app_column_name varchar2(25);

   l_dynamic_sql1   varchar2(4000);
   l_dynamic_sql2   varchar2(4000);
   l_dynamic_sql2_1 varchar2(4000);
   l_dynamic_sql3   varchar2(4000);

   l_id_start_date date;
   l_id_end_date date;

   l_org_id number;  -- Bug 4946930
x number;

   TYPE r_backup_awt_info IS RECORD(
      vendor_id                  AP_1099_TAPE_DATA_ALL.vendor_id%TYPE,
      region_code                AP_1099_TAPE_DATA_ALL.region_code%TYPE,
      misc1                      AP_1099_TAPE_DATA_ALL.misc1%TYPE,
      misc2                      AP_1099_TAPE_DATA_ALL.misc2%TYPE,
      misc3                      AP_1099_TAPE_DATA_ALL.misc3%TYPE,
      misc4                      AP_1099_TAPE_DATA_ALL.misc4%TYPE,
      misc5                      AP_1099_TAPE_DATA_ALL.misc5%TYPE,
      misc6                      AP_1099_TAPE_DATA_ALL.misc6%TYPE,
      misc7                      AP_1099_TAPE_DATA_ALL.misc7%TYPE,
      misc8                      AP_1099_TAPE_DATA_ALL.misc8%TYPE,
      misc9                      AP_1099_TAPE_DATA_ALL.misc9%TYPE,
      misc10                     AP_1099_TAPE_DATA_ALL.misc10%TYPE,
      misc13                     AP_1099_TAPE_DATA_ALL.misc13%TYPE,
      misc14                     AP_1099_TAPE_DATA_ALL.misc14%TYPE,
      misc15aNT                  AP_1099_TAPE_DATA_ALL.misc15aNT%TYPE,
      misc15aT                   AP_1099_TAPE_DATA_ALL.misc15aT%TYPE,
      misc15b                    AP_1099_TAPE_DATA_ALL.misc15b%TYPE
      ) ;

   l_backup_awt_rec r_backup_awt_info ;

   TYPE c_backup_awt IS REF CURSOR;

   c_awt c_backup_awt;

   begin

   l_org_id := mo_global.get_current_org_id;
   l_id_start_date := p_start_date-1;
   l_id_end_date := p_end_date+1;


   SELECT fnd.application_column_name, gl.chart_of_accounts_id
   INTO   l_app_column_name, l_chart_of_accounts_id
   FROM fnd_segment_attribute_values fnd, gl_sets_of_books gl
   WHERE segment_attribute_type = 'GL_BALANCING'
   AND fnd.attribute_value = 'Y'
   AND fnd.id_flex_code = 'GL#'
   AND fnd.id_flex_num = gl.chart_of_accounts_id
   AND gl.set_of_books_id = p_sob_id;


   l_dynamic_sql1:=
        'SELECT  P.vendor_id,';

   if p_combined_flag = '1' then
      l_dynamic_sql1 := l_dynamic_sql1 || 'ITR.region_code,';
   else
      l_dynamic_sql1 := l_dynamic_sql1 || 'null,';
   end if;

   l_dynamic_sql1 := l_dynamic_sql1
||                'round(sum(decode(ID.type_1099,''MISC1'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''|| l_id_end_date||'''  ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                        ' decode( INV_NET_AMT.netamount ,0,1,'     /*Bug5943123  This change is done in almost 15 places in this same pls*/
||                                ' INV_NET_AMT.netamount ))'
-- Bug 5768112. Backing out the fix of bug 5620442
--||                       ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                       ' *IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC2'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC3'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                        'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                   ' decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||             ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                '-1*(round(sum(decode(ID.type_1099,''MISC4'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2)),' -- Bug 5260442
||                        '*IP.amount),0)),2)),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC5'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC6'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC7'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),'; -- Bug 5260442
||                        '*IP.amount),0)),2),'; -- Bug 5768112

   l_dynamic_sql2:=  'round(sum(decode(ID.type_1099,''MISC8'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                        ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC9'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                        ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC10'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC13'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC14'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' ;-- Bug 5260442
||                        '*IP.amount),0)),2), '; -- Bug 5768112

l_dynamic_sql2_1 := 'round(sum(decode(ID.type_1099,''MISC15a NT'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC15a T'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2),' -- Bug 5768112
||                'round(sum(decode(ID.type_1099,''MISC15b'','
||                  '(decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,0,decode(greatest(ID.accounting_date,'''||l_id_end_date||''' ),'
||                         'ID.accounting_date,0,decode(least(ID.accounting_date,'''||l_id_start_date||''' ),'
||                         'ID.accounting_date,0,ABS(ID.amount)))),ID.amount)/'
||                    'decode(I.invoice_amount,0,decode(I.cancelled_amount,'
||                         'null,1,0,1,I.cancelled_amount),'
||                         ' decode( INV_NET_AMT.netamount ,0,1,'
||                                ' INV_NET_AMT.netamount ))'
--||                         ' *decode(IP.payment_base_amount,null,IP.amount,IP.payment_base_amount)),0)),2),' -- Bug 5260442
||                        '*IP.amount),0)),2) ' -- Bug 5768112
||        ' FROM    ap_income_tax_regions ITR, '
||                'ap_reporting_entity_lines_all REL, '
||                'po_vendors P, '
||                'ce_bank_accounts ABA, ' --for bug 6275528 - replaced ap_bank_accounts_all with ce_bank_Accounts
                                           --as ap_bank_accounts_All is obsolete in R12.
||                'ce_bank_acct_uses_all BAU, ' -- Bug 6604204. Included table to join AP_CHECKS and
                                                -- CE_BANK_ACCOUNTS table.
||                'ap_checks_all AC, '
||                'ap_invoices_all I, '
||                'gl_code_combinations CC, '
||                'ap_invoice_distributions_all ID, '
||                'ap_invoice_payments_all IP,'   --Bug 6064614 --for bug 6275528 - changed ap_invoice_payments
                                                  --to ap_invoice_payments_all.
||    '( select  AI.invoice_id ,  nvl(AIL1.amount+AI.invoice_amount , AI.invoice_amount) as netamount  '         --Bug5943123
||    ' from  ap_invoices_all AI, ( select AIL.invoice_id, SUM(AIL.amount) as amount   '
||    '                    FROM ap_invoice_lines_all AIL     '                               --Bug6064614
||	'						WHERE (nvl(AIL.invoice_includes_prepay_flag,''N'') = ''N''  '   --Bug6052333
||	'						AND (AIL.line_type_lookup_code = ''PREPAY''  '
||	'						OR (AIL.line_type_lookup_code =''TAX''  '
||	'						AND AIL.prepay_invoice_id IS NOT NULL   '
||	'						AND AIL.prepay_line_number IS NOT NULL))) '
||    '                        OR  AIL.line_type_lookup_code  = ''AWT'' '
||    '                    GROUP by AIL.invoice_id  ) AIL1  '                                                  --Bug5943123
||    '                 where AI.invoice_id = AIL1.invoice_id (+)   ) INV_NET_AMT   '
||        'WHERE   ID.income_tax_region = ITR.region_short_name (+) '
||        'AND     P.vendor_id=I.vendor_id '
||        'AND     (AC.void_date is null '
||        '         OR AC.void_date NOT BETWEEN '''|| p_start_date || ''' AND '''|| p_end_date || ''') ' --4480766, 8925235
||        'AND     I.invoice_id=IP.invoice_id '
||        'AND     I.invoice_id=ID.invoice_id '
||        'AND     exists '
||        '        ( '
||        '           select   1 '
||        '           from     ap_invoice_distributions_all AID '
||        '           where    AID.invoice_id = I.invoice_id '
||        '           AND      AID.type_1099 = ''MISC4'' '
||        '        ) '
||        'AND     INV_NET_AMT.invoice_id = I.invoice_id '
||        'AND     IP.accounting_date BETWEEN '''|| p_start_date || ''' AND '''|| p_end_date || ''' '
||        'AND     ID.type_1099 is not null '
---- ||        'AND     AC.bank_account_id = ABA.bank_account_id '  Commeted this for bug 6275528 - as in ap_checks_all
               ---bank_account_id is not getting stamped in R12.bank_account_anme is there so we will use it.
--||        'AND     AC.bank_account_name = ABA.bank_account_name ' --added for bug  6275528 for the aobve explained reason.
                                                                    -- Commented for Bug 6604204.
||        'AND     AC.ce_bank_acct_use_id = BAU.bank_acct_use_id '  -- Bug 6604204. Please refer bug for details.
||        'AND     BAU.bank_account_id = ABA.bank_account_id '      -- Bug 6604204. Please refer bug for details.
||        'AND     AC.org_id = mo_global.get_current_org_id '   --added for bug 6275528
||        'AND     IP.check_id = AC.check_id '
||        'AND     REL.tax_entity_id = ' || p_tax_entity_id|| ' '
||        'AND     CC.chart_of_accounts_id = ' || l_chart_of_accounts_id || ' ';


   if p_calling_module = 'PAYMENTS REPORT' and nvl(p_federal_reportable_flag,'N') = 'N' then
     null;
   else -- for all other situations we want federal reportable vendors only
     l_dynamic_sql3:= 'AND P.federal_reportable_flag = ''Y'' ';
   end if;

   if p_vendor_id is not null then
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND P.vendor_id = '||p_vendor_id||' ';
   end if;

   if p_query_driver = 'INV' then
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND ID.dist_code_combination_id = CC.code_combination_id ';
   else
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND ABA.asset_code_combination_id = CC.code_combination_id ';
   end if;

   if p_region is not null then
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND id.income_tax_region = '''|| p_region ||''' ';
   end if;

   if (l_app_column_name LIKE 'SEGMENT1') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment1 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT2') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment2 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT3') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment3 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT4') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment4 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT5') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment5 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT6') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment6 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT7') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment7 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT8') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment8 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT9') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment9 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT10') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment10 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT11') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment11 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT12') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment12 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT13') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment13 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT14') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment14 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT15') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment15 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT16') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment16 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT17') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment17 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT18') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment18 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT19') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment19 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT20') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment20 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT21') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment21 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT22') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment22 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT23') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment23 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT24') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment24 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT25') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment25 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT26') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment26 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT27') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment27 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT28') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment28 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT29') THEN
     l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment29 = REL.balancing_segment_value ';
   elsif (l_app_column_name LIKE 'SEGMENT30') THEN
    l_dynamic_sql3 := l_dynamic_sql3 || 'AND CC.segment30 = REL.balancing_segment_value ';
   end if;

   if p_combined_flag = '1' then
     l_dynamic_sql3 := l_dynamic_sql3 || 'GROUP BY ITR.region_code, P.vendor_id';
   else
     l_dynamic_sql3 := l_dynamic_sql3 || 'GROUP BY P.vendor_id';
   end if;

   open c_awt for l_dynamic_sql1 || l_dynamic_sql2 || l_dynamic_sql2_1 || l_dynamic_sql3;

   LOOP

      fetch c_awt into l_backup_awt_rec ;
      exit when c_awt%NOTFOUND ;

      update ap_1099_tape_data atd
      set  misc1     = decode(atd.misc1, 0, l_backup_awt_rec.misc1, atd.misc1),
           misc2     = decode(atd.misc2, 0, l_backup_awt_rec.misc2, atd.misc2),
           misc3     = decode(atd.misc3, 0, l_backup_awt_rec.misc3, atd.misc3),
           misc5     = decode(atd.misc5, 0, l_backup_awt_rec.misc5, atd.misc5),
           misc6     = decode(atd.misc6, 0, l_backup_awt_rec.misc6, atd.misc6),
           misc7     = decode(atd.misc7, 0, l_backup_awt_rec.misc7, atd.misc7),
           misc8     = decode(atd.misc8, 0, l_backup_awt_rec.misc8, atd.misc8),
           misc9     = decode(atd.misc9, 0, l_backup_awt_rec.misc9, atd.misc9),
           misc10    = decode(atd.misc10, 0, l_backup_awt_rec.misc10, atd.misc10),
           misc13    = decode(atd.misc13, 0, l_backup_awt_rec.misc13, atd.misc13),
           misc14    = decode(atd.misc14, 0, l_backup_awt_rec.misc14, atd.misc14),
           misc15aNT = decode(atd.misc15aNT, 0, l_backup_awt_rec.misc15aNT, atd.misc15aNT),
           misc15aT  = decode(atd.misc15aT, 0, l_backup_awt_rec.misc15aT, atd.misc15aT),
           misc15b   = decode(atd.misc15b, 0, l_backup_awt_rec.misc15b, atd.misc15b)
      where          atd.vendor_id = l_backup_awt_rec.vendor_id
      and            nvl(atd.region_code, -99) = nvl(l_backup_awt_rec.region_code, -99)
      and            atd.misc4 > 0 ;

   END LOOP ;

   close c_awt ;

   end do_awt_withholding_update;

END AP_1099_UTILITIES_PKG;

/
