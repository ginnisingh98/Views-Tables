--------------------------------------------------------
--  DDL for Package Body AP_OPEN_ITEMS_REVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_OPEN_ITEMS_REVAL_PKG" AS
/* $Header: apopitrb.pls 120.1.12010000.9 2010/03/22 22:11:37 sanjagar noship $ */

  C_NEW_LINE CONSTANT VARCHAR2(8) := fnd_global.newline;

  /* case when transfer to gl only = Yes
  GL transfered invoices */
  C_GL_TRANSFER_INVOICES_GT_SQL CONSTANT VARCHAR2(32000) := '
            select /*+ leading(xte) parallel(xte) */ distinct
                    $segment_columns$
                    gcck.code_combination_id,
                    gcck.concatenated_segments account,
                    ai.party_id,
                    ai.party_site_id,
                    hp.party_name,
                    ai.vendor_id,
                    supp.segment1 vendor_number,
                    ai.vendor_site_id,
                    site.vendor_site_code,
                    ai.invoice_id txn_id,
                    ai.invoice_num txn_number,
                    alc.displayed_field txn_type_lookup_code,
                    ai.invoice_date txn_date,
                    ai.invoice_amount txn_amount,
                    nvl(ai.base_amount, ai.invoice_amount) txn_base_amount,
                    xal.currency_code txn_currency_code,
                    1 TXN_CURR_MIN_ACCT_UNIT,
                    2 TXN_CURR_PRECISION,
                    nvl(ai.exchange_rate, 1) txn_base_exchange_rate,
                    ai.payment_currency_code payment_currency_code,
                    nvl(ai.payment_cross_rate, 1) payment_cross_rate,
                    2 PAYMENT_CURR_PRECISION,
                    1 PMT_CURR_MIN_ACCT_UNIT,
                    ai.payment_status_flag,
                    sum(nvl(xal.entered_cr, 0) - nvl(xal.entered_dr, 0)) entered_amount,
                    sum(nvl(xal.accounted_cr, 0) - nvl(xal.accounted_dr, 0)) accounted_amount,
                    NULL DUE_DATE
              from ap_system_parameters_all asp,
                   xla_transaction_entities xte,
                   xla_ae_headers xah,
                   xla_ae_lines xal,
                   gl_code_combinations_kfv gcck,
                   ap_invoices_all ai,
                   ap_lookup_codes alc,
                   hz_parties hp,
                   ap_suppliers supp,
                   ap_supplier_sites_all site
             where xte.ledger_id = $ledger_id$
               and asp.set_of_books_id = $ledger_id$
               and xah.ledger_id = $ledger_id$
               and xal.ledger_id = $ledger_id$
               and ai.set_of_books_id = $ledger_id$
               and nvl(xte.security_id_int_1, -99) = $org_id$
               and asp.org_id = $org_id$
               and ai.org_id = $org_id$
               and xte.entity_code = ''AP_INVOICES''
               and xte.application_id = 200
               and xah.entity_id = xte.entity_id
               and xah.gl_transfer_status_code = ''Y''
               and xah.application_id = 200
               and xal.ae_header_id = xah.ae_header_id
               and xal.accounting_class_code = ''LIABILITY''
               and xal.application_id = 200
               and gcck.code_combination_id = xal.code_combination_id
               and ai.invoice_id = nvl(xte.source_id_int_1, -99)
               and ai.invoice_type_lookup_code = alc.lookup_code
               and alc.lookup_type = ''INVOICE TYPE''
               and hp.party_id = ai.party_id
               and ai.vendor_id = supp.vendor_id(+)
               and ai.vendor_site_id = site.vendor_site_id(+)
               and xah.accounting_date <= $accounting_date$
               and :G_DAILY_RATE_ERROR = ''N''
               $bal_segment_condition$
             group by $segment_group$
                      gcck.code_combination_id,
                    gcck.concatenated_segments ,
                    ai.party_id,
                    ai.party_site_id,
                    hp.party_name,
                    ai.vendor_id,
                    supp.segment1 ,
                    ai.vendor_site_id,
                    site.vendor_site_code,
                    ai.invoice_id ,
                    ai.invoice_num ,
                    alc.displayed_field ,
                    ai.invoice_date ,
                    ai.invoice_amount ,
                    nvl(ai.base_amount, ai.invoice_amount) ,
                    xal.currency_code ,
                    --1 TXN_CURR_MIN_ACCT_UNIT,
                    --2 TXN_CURR_PRECISION,
                    nvl(ai.exchange_rate, 1) ,
                    ai.payment_currency_code ,
                    nvl(ai.payment_cross_rate, 1) ,
                    --2 PAYMENT_CURR_PRECISION,
                    --1 PMT_CURR_MIN_ACCT_UNIT,
                    ai.payment_status_flag';

  /* case when transfer to gl only = Yes,
  These are payments for which none of the  invoices are falling inside the end-date.
  GL transfered payments with out invoices */
  C_GL_TRANSFER_PAYMENTS_GT_SQL CONSTANT VARCHAR2(32000) := '
        select distinct balancing_segment,
                account_segment,
                code_combination_id,
                account,
                party_id,
                party_site_id,
                party_name,
                vendor_id,
                vendor_number,
                vendor_site_id,
                vendor_site_code,
                check_id txn_id,
                check_number txn_number,
                alc.displayed_field txn_type_lookup_code,
                check_date txn_date,
                check_amount txn_amount,
                nvl(check_base_amount, check_amount) txn_base_amount,
                currency_code txn_currency_code,
                1 TXN_CURR_MIN_ACCT_UNIT,
                2 TXN_CURR_PRECISION,
                currency_conversion_rate txn_base_exchange_rate,
                currency_code payment_currency_code,
                1 payment_cross_rate,
                2 PAYMENT_CURR_PRECISION,
                1 PMT_CURR_MIN_ACCT_UNIT,
                ''Y'' payment_status_flag,
                sum(entered_amount) entered_amount,
                sum(accounted_amount) accounted_amount,
                null due_date
          from (
                select /*+ leading (aip xte xah aal) parallel(aip)*/ distinct
                                $segment_columns$
                                gcck.code_combination_id,
                                gcck.concatenated_segments account,
                                null ref_ae_header_id,
                                null temp_line_num,
                                xah.ae_header_id,
                                aal.ae_line_id ap_ae_line_id,
                                aal.ae_header_id ap_ae_header_id,
                                aal.ae_line_number ap_ae_line_number,
                                aip.check_id,
                                ac.check_number,
                                ac.check_date,
                                aip.invoice_id,
                                ai.vendor_id,
                                hp.party_name,
                                supp.segment1 vendor_number,
                                ai.vendor_site_id,
                                site.vendor_site_code,
                                ai.party_id,
                                ai.party_site_id,
                                aal.currency_code,
                                aal.currency_conversion_rate,
                                ac.amount check_amount,
                                ac.base_amount check_base_amount,
                                nvl(aal.entered_cr, 0) - nvl(aal.entered_dr, 0) entered_amount,
                                nvl(aal.accounted_cr, 0) - nvl(aal.accounted_dr, 0) accounted_amount
                  from ap_system_parameters_all asp,
                       ap_invoice_payments_all aip,
                       ap_invoices_all ai,
                       hz_parties hp,
                       ap_suppliers supp,
                       ap_supplier_sites_all site,
                       ap_checks_all ac,
                       xla_transaction_entities xte,
                       xla_ae_headers xah,
                       ap_ae_lines_all aal,
                       gl_code_combinations_kfv gcck
                 where nvl(xte.source_id_int_1, -99) = aip.check_id
                   and nvl(xte.security_id_int_1, -99) = $org_id$
                   and aip.org_id = $org_id$
                   and asp.org_id = $org_id$
                   and ac.org_id = $org_id$
                   and ai.org_id = $org_id$
                   and ai.set_of_books_id = $ledger_id$
                   and aip.set_of_books_id = $ledger_id$
                   and xah.ledger_id = $ledger_id$
                   and asp.set_of_books_id = $ledger_id$
                   and xte.ledger_id = $ledger_id$
                   and ac.check_id = aip.check_id
                   and xah.entity_id = xte.entity_id
                   and xah.gl_transfer_status_code = ''Y''
                   and xah.event_type_code <> ''MANUAL''
                   and xah.application_id = 200
                   and xte.application_id = 200
                   and xte.entity_code = ''AP_PAYMENTS''
                   and xah.accounting_date <= $accounting_date$
                   /* upgrade case */
                   and xah.upg_batch_id is not null
                   and aal.ae_header_id = xah.completion_acct_seq_value
                   and gcck.code_combination_id = aal.code_combination_id
                   and aal.reference2 = aip.invoice_id
                   and aal.ae_line_type_code = ''LIABILITY''
                   and ai.invoice_id = aip.invoice_id
                   and hp.party_id = ai.party_id
                   and ai.vendor_id = supp.vendor_id(+)
                   and ai.vendor_site_id = site.vendor_site_id(+)
                   and not exists (select 1
                                     from ap_open_items_reval_gt
                                    where txn_id = aip.invoice_id)
                   and :G_DAILY_RATE_ERROR = ''N''
                   $bal_segment_condition$
                union
                select /*+ leading (aip xte xah xdl) parallel(aip)*/ distinct
                                $segment_columns$
                                gcck.code_combination_id,
                                gcck.concatenated_segments account,
                                xdl.ref_ae_header_id,
                                xdl.temp_line_num,
                                xdl.ae_header_id,
                                null ap_ae_line_id,
                                null ap_ae_header_id,
                                null ap_ae_line_number,
                                aip.check_id,
                                ac.check_number,
                                ac.check_date,
                                aip.invoice_id,
                                ai.vendor_id,
                                hp.party_name,
                                supp.segment1 vendor_number,
                                ai.vendor_site_id,
                                site.vendor_site_code,
                                ai.party_id,
                                ai.party_site_id,
                                xal.currency_code,
                                xal.currency_conversion_rate,
                                ac.amount check_amount,
                                ac.base_amount check_base_amount,
                                nvl(xdl.unrounded_entered_cr, 0) - nvl(xdl.unrounded_entered_dr, 0) entered_amount,
                                nvl(xdl.unrounded_accounted_cr, 0) - nvl(xdl.unrounded_accounted_dr, 0) accounted_amount
                  from ap_system_parameters_all asp,
                       ap_invoice_payments_all aip,
                       ap_invoices_all ai,
                       hz_parties hp,
                       ap_suppliers supp,
                       ap_supplier_sites_all site,
                       ap_checks_all ac,
                       xla_transaction_entities xte,
                       xla_ae_headers xah,
                       xla_ae_lines xal,
                       xla_distribution_links xdl,
                       gl_code_combinations_kfv gcck
                 where nvl(xte.source_id_int_1, -99) = aip.check_id
                   and nvl(xte.security_id_int_1, -99) = $org_id$
                   and asp.org_id = $org_id$
                   and aip.org_id = $org_id$
                   and ai.org_id = $org_id$
                   and ai.set_of_books_id = $ledger_id$
                   and xte.ledger_id = $ledger_id$
                   and xah.ledger_id = $ledger_id$
                   and aip.set_of_books_id = $ledger_id$
                   and ac.check_id = aip.check_id
                   and xah.entity_id = xte.entity_id
                   and xah.gl_transfer_status_code = ''Y''
                   and xah.event_type_code <> ''MANUAL''
                   and xah.application_id = 200
                   and xte.application_id = 200
                   and xte.entity_code = ''AP_PAYMENTS''
                   and xah.accounting_date <= $accounting_date$
                   /* non-upgrade case */
                   and xah.upg_batch_id is null
                   and xal.ae_header_id = xah.ae_header_id
                   and xdl.ae_header_id = xah.ae_header_id
                   and xdl.ae_line_num = xal.ae_line_num
                   and xal.code_combination_id = gcck.code_combination_id
                   and xdl.applied_to_source_id_num_1 = aip.invoice_id
                   and xdl.rounding_class_code = ''LIABILITY''
                   and xdl.applied_to_entity_code = ''AP_INVOICES''
                   and xdl.application_id = 200
                   and ai.invoice_id = aip.invoice_id
                   and hp.party_id = ai.party_id
                   and ai.vendor_id = supp.vendor_id(+)
                   and ai.vendor_site_id = site.vendor_site_id(+)
                   and not exists (select 1
                                     from ap_open_items_reval_gt
                                    where txn_id = aip.invoice_id)
                   and :G_DAILY_RATE_ERROR = ''N''
                   $bal_segment_condition$
           )a,ap_lookup_codes alc
          where alc.lookup_code = ''PAYMENT''
            and alc.lookup_type = ''SYSTEM OPTIONS'' -- need modification
          group by balancing_segment,
                account_segment,
                code_combination_id,
                account,
                party_id,
                party_site_id,
                party_name,
                vendor_id,
                vendor_number,
                vendor_site_id,
                vendor_site_code,
                check_id ,
                check_number ,
                alc.displayed_field ,
                check_date ,
                check_amount ,
                nvl(check_base_amount, check_amount) ,
                currency_code ,
                --1 TXN_CURR_MIN_ACCT_UNIT,
                --2 TXN_CURR_PRECISION,
                currency_conversion_rate
            having sum(entered_amount) <> 0';

  /* case when gl transfer only = No.
  invoices*/
  C_INVOICES_GT_SQL CONSTANT VARCHAR2(32000) := '
        select /*parallel (ai)*/ distinct
                $segment_columns$
                gcck.code_combination_id,
                gcck.concatenated_segments account,
                ai.party_id,
                ai.party_site_id,
                hp.party_name,
                ai.vendor_id,
                supp.segment1 vendor_number,
                ai.vendor_site_id,
                site.vendor_site_code,
                ai.invoice_id txn_id,
                ai.invoice_num txn_number,
                alc.displayed_field txn_type_lookup_code,
                ai.invoice_date txn_date,
                ai.invoice_amount txn_amount,
                nvl(ai.base_amount, ai.invoice_amount) txn_base_amount,
                ai.invoice_currency_code txn_currency_code,
                1 TXN_CURR_MIN_ACCT_UNIT ,
                2 TXN_CURR_PRECISION     ,
                nvl(ai.exchange_rate,1) TXN_BASE_EXCHANGE_RATE,
                ai.payment_currency_code payment_currency_code,
                nvl(ai.payment_cross_rate, 1) payment_cross_rate,
                2 PAYMENT_CURR_PRECISION,
                1 PMT_CURR_MIN_ACCT_UNIT,
                ai.payment_status_flag,
                sum(nvl(aid.amount, 0)) entered_amount,
                sum(nvl(aid.base_amount, nvl(aid.amount, 0))) accounted_amount,
                NULL due_Date
          from ap_system_parameters_all asp,
               ap_invoice_distributions_all aid,
               ap_invoice_lines_all ail,
               gl_code_combinations_kfv gcck,
               ap_invoices_all ai,
               ap_lookup_codes alc,
               hz_parties hp,
               ap_suppliers supp,
               ap_supplier_sites_all site
         where asp.set_of_books_id = $ledger_id$
           and ai.set_of_books_id = $ledger_id$
           and aid.set_of_books_id = $ledger_id$
           and ail.set_of_books_id = $ledger_id$
           and asp.org_id = $org_id$
           and ai.org_id = $org_id$
           and ail.org_id = $org_id$
           and aid.org_id = $org_id$
           and gcck.code_combination_id = ai.accts_pay_code_combination_id
           and ai.invoice_type_lookup_code = alc.lookup_code
           and alc.lookup_type = ''INVOICE TYPE''
           and hp.party_id = ai.party_id
           and ai.vendor_id = supp.vendor_id(+)
           and ai.vendor_site_id = site.vendor_site_id(+)
           and aid.invoice_id = ai.invoice_id
           and ail.invoice_id = ai.invoice_id
           and ail.line_number = aid.invoice_line_number
           and aid.match_status_flag in (''A'', ''T'')
           and aid.accounting_date <= $accounting_date$
           and :G_DAILY_RATE_ERROR = ''N''
           $bal_segment_condition$
        group by  $segment_group$
                gcck.code_combination_id,
                gcck.concatenated_segments,
                ai.party_id,
                ai.party_site_id,
                hp.party_name,
                ai.vendor_id,
                supp.segment1 ,
                ai.vendor_site_id,
                site.vendor_site_code,
                ai.invoice_id ,
                ai.invoice_num ,
                alc.displayed_field ,
                ai.invoice_date ,
                ai.invoice_amount ,
                nvl(ai.base_amount, ai.invoice_amount) ,
                ai.invoice_currency_code ,
                --1 TXN_CURR_MIN_ACCT_UNIT ,
                --2 TXN_CURR_PRECISION     ,
                nvl(ai.exchange_rate,1) ,
                ai.payment_currency_code ,
                nvl(ai.payment_cross_rate, 1) ,
                --2 PAYMENT_CURR_PRECISION,
                --1 PMT_CURR_MIN_ACCT_UNIT,
                ai.payment_status_flag';

  /* case when gl transfer only = No
  these are the payments for which invoices fall outside of end date*/
  C_PAYMENTS_GT_SQL CONSTANT VARCHAR2(32000) := '
        select /*+ leading (aip) parallel(aip)*/ distinct
                $segment_columns$
                gcck.code_combination_id,
                gcck.concatenated_segments account,
                ai.party_id,
                ai.party_site_id,
                hp.party_name,
                ai.vendor_id,
                supp.segment1 vendor_number,
                ai.vendor_site_id,
                site.vendor_site_code,
                ac.check_id txn_id,
                ac.check_number txn_number,
                alc.displayed_field txn_type_lookup_code,
                ac.check_date txn_date,
                ac.amount txn_amount,
                nvl(ac.base_amount, ac.amount) txn_base_amount,
                ac.currency_code txn_currency_code,
                1 TXN_CURR_MIN_ACCT_UNIT ,
                2 TXN_CURR_PRECISION,
                nvl(ac.exchange_rate, 1) TXN_BASE_EXCHANGE_RATE,
                ac.currency_code payment_currency_code,
                1 payment_cross_rate,
                2 PAYMENT_CURR_PRECISION,
                1 PMT_CURR_MIN_ACCT_UNIT,
                ''Y'' payment_status_flag,
                -sum(aip.amount) entered_amount,
                -sum(nvl(aip.payment_base_amount, aip.amount)) accounted_amount,
                null due_Date
          from ap_system_parameters_all asp,
               ap_invoices_all ai,
               ap_invoice_payments_all aip,
               ap_checks_all ac,
               ap_lookup_codes alc,
               hz_parties hp,
               ap_suppliers supp,
               ap_supplier_sites_all site,
               gl_code_combinations_kfv gcck
         where alc.lookup_code = ''PAYMENT''
           and alc.lookup_type = ''SYSTEM OPTIONS'' -- need modification
           and hp.party_id = ai.party_id
           and ai.vendor_id = supp.vendor_id(+)
           and ai.vendor_site_id = site.vendor_site_id(+)
           and gcck.code_combination_id = ai.accts_pay_code_combination_id
           and aip.invoice_id = ai.invoice_id
           and ac.check_id = aip.check_id
           and ai.set_of_books_id = $ledger_id$
           and aip.set_of_books_id = $ledger_id$
           and asp.set_of_books_id = $ledger_id$
           and ai.org_id = $org_id$
           and aip.org_id = $org_id$
           and ac.org_id = $org_id$
           and asp.org_id = $org_id$
           and aip.accounting_date <= $accounting_date$
           and aip.invoice_id not in (select distinct a.txn_id
                                        from ap_open_items_reval_gt a)
           and :G_DAILY_RATE_ERROR = ''N''
           and :G_DAILY_RATE_ERROR = ''N''
           $bal_segment_condition$
        group by  $segment_group$
                gcck.code_combination_id,
                gcck.concatenated_segments ,
                ai.party_id,
                ai.party_site_id,
                hp.party_name,
                ai.vendor_id,
                supp.segment1 ,
                ai.vendor_site_id,
                site.vendor_site_code,
                ac.check_id ,
                ac.check_number ,
                alc.displayed_field ,
                ac.check_date ,
                ac.amount ,
                nvl(ac.base_amount, ac.amount) ,
                ac.currency_code ,
                --1 TXN_CURR_MIN_ACCT_UNIT ,
                --2 TXN_CURR_PRECISION,
                nvl(ac.exchange_rate, 1),
                ac.currency_code
                --1 payment_cross_rate
                --2 PAYMENT_CURR_PRECISION,
                --1 PMT_CURR_MIN_ACCT_UNIT
        having sum(aip.amount) <> 0';

  /* case when transfer to gl only = 'Y'
  all open trnasactions */
  C_GL_TRAN_OPEN_INVOICES_SQL CONSTANT VARCHAR2(32000) := '
         select /*+ parallal b */distinct
                b.balancing_segment,
                b.account_segment,
                b.code_combination_id,
                b.account,
                b.party_id,
                b.party_site_id,
                b.party_name,
                b.vendor_id,
                b.vendor_number,
                b.vendor_site_id,
                b.vendor_site_code,
                b.txn_id,
                b.txn_number,
                b.txn_type_lookup_code,
                b.txn_date,
                b.txn_currency_code,
                b.payment_currency_code,
                b.TXN_BASE_EXCHANGE_RATE,
                b.payment_cross_rate,
                AP_OPEN_ITEMS_REVAL_PKG.get_revaluation_rate(b.txn_currency_code) revaluation_rate,
                b.payment_status_flag,
                b.entered_amount,
                b.accounted_amount,
                --sum(nvl(a.entered_amount, 0)) pmt_entered_amount,
                --sum(nvl(a.accounted_amount, 0)) pmt_accounted_amount,
                b.entered_amount - sum(nvl(a.entered_amount, 0)) open_entered_amount,
                b.accounted_amount - sum(nvl(a.accounted_amount, 0)) open_accounted_amount
          from
          (select /*+ leading (aoi aip xte xah aal) parallel(aoi)*/ distinct
                          200 application_id,
                          null ref_ae_header_id,
                          null temp_line_num,
                          xah.ae_header_id,
                          aal.ae_line_id ap_ae_line_id,
                          aal.ae_header_id ap_ae_header_id,
                          aal.ae_line_number ap_ae_line_number,
                          aoi.code_combination_id,
                          aoi.account,
                          aip.invoice_id,
                          --aoi.invoice_currency_code,
                          --aoi.payment_currency_code,
                          aoi.txn_base_exchange_rate,
                          txn_amount invoice_amount,
                          txn_base_amount invoice_base_amount,
                          nvl(aal.entered_dr, 0) - nvl(aal.entered_cr, 0) entered_amount,
                          nvl(aal.accounted_dr, 0) - nvl(aal.accounted_cr, 0) accounted_amount
            from ap_open_items_reval_gt aoi,
                 ap_invoice_payments_all aip,
                 ap_checks_all ac,
                 xla_transaction_entities xte,
                 xla_ae_headers xah,
                 ap_ae_lines_all aal
           where aip.invoice_id = aoi.txn_id
             and nvl(xte.source_id_int_1, -99) = aip.check_id
             and nvl(xte.security_id_int_1, -99) = $org_id$
             and aip.set_of_books_id = $ledger_id$
             and aip.org_id = $org_id$
             and xte.ledger_id = $ledger_id$
             and ac.check_id = aip.check_id
             and xah.entity_id = xte.entity_id
             and xah.ledger_id = $ledger_id$
             and xah.gl_transfer_status_code = ''Y''
             and xah.event_type_code <> ''MANUAL''
             and xah.application_id = 200
             and xte.application_id = 200
             and xte.entity_code = ''AP_PAYMENTS''
             and xah.accounting_date <= $accounting_date$
             /* upgrade case */
             and xah.upg_batch_id is not null
             and aal.ae_header_id = xah.completion_acct_seq_value
             and aal.code_combination_id = aoi.code_combination_id
             and aal.reference2 = aoi.txn_id
             and aal.ae_line_type_code = ''LIABILITY''
             and aoi.txn_type_lookup_code <> ''Payment''
             $cleared_condition$
          union
          select /*+ leading (aoi aip xte xah xal xdl) parallel(aoi)*/ distinct
                          xdl.application_id,
                          xdl.ref_ae_header_id,
                          xdl.temp_line_num,
                          xdl.ae_header_id,
                          null ap_ae_line_id,
                          null ap_ae_header_id,
                          null ap_ae_line_number,
                          aoi.code_combination_id,
                          aoi.account,
                          aip.invoice_id,
                          --aoi.invoice_currency_code,
                          --aoi.payment_currency_code,
                          aoi.TXN_BASE_EXCHANGE_RATE,
                          txn_amount invoice_amount,
                          txn_base_amount invoice_base_amount,
                          nvl(xdl.unrounded_entered_dr, 0) - nvl(xdl.unrounded_entered_cr, 0) entered_amount,
                          nvl(xdl.unrounded_accounted_dr, 0) - nvl(xdl.unrounded_accounted_cr, 0) accounted_amount
            from ap_open_items_reval_gt aoi,
                 ap_invoice_payments_all aip,
                 ap_checks_all ac,
                 xla_transaction_entities xte,
                 xla_ae_headers xah,
                 xla_ae_lines xal,
                 xla_distribution_links xdl
           where aip.invoice_id = aoi.txn_id
             and nvl(xte.source_id_int_1, -99) = aip.check_id
             and nvl(xte.security_id_int_1, -99) = $org_id$
             and aip.set_of_books_id = $ledger_id$
             and aip.org_id = $org_id$
             and xte.ledger_id = $ledger_id$
             and ac.check_id = aip.check_id
             and xah.entity_id = xte.entity_id
             and xah.ledger_id = $ledger_id$
             and xah.gl_transfer_status_code = ''Y''
             and xah.event_type_code <> ''MANUAL''
             and xah.application_id = 200
             and xte.application_id = 200
             and xte.entity_code = ''AP_PAYMENTS''
             and xah.accounting_date <= $accounting_date$
             /* non-upgrade case */
             and xah.upg_batch_id is null
             and xal.ae_header_id = xah.ae_header_id
             and xdl.ae_header_id = xah.ae_header_id
             and xdl.ae_line_num = xal.ae_line_num
             and xal.code_combination_id = aoi.code_combination_id
             and xdl.applied_to_source_id_num_1 = aip.invoice_id
             and xdl.rounding_class_code = ''LIABILITY''
             and xdl.applied_to_entity_code = ''AP_INVOICES''
             and xdl.application_id = 200
             and aoi.txn_type_lookup_code <> ''Payment''
             $cleared_condition$)a,
             ap_open_items_reval_gt b
          where b.txn_id = a.invoice_id(+)
            and b.code_combination_id = a.code_combination_id(+)
          group by b.balancing_segment,
                    b.account_segment,
                    b.code_combination_id,
                    b.account,
                    b.party_id,
                    b.party_site_id,
                    b.party_name,
                    b.vendor_id,
                    b.vendor_number,
                    b.vendor_site_id,
                    b.vendor_site_code,
                    b.txn_id,
                    b.txn_number,
                    b.txn_type_lookup_code,
                    b.txn_date,
                    b.txn_currency_code,
                    b.payment_currency_code,
                    b.TXN_BASE_EXCHANGE_RATE,
                    b.payment_cross_rate,
                    b.payment_status_flag,
                    b.entered_amount,
                    b.accounted_amount
          having b.entered_amount <> sum(nvl(a.entered_amount, 0))
          ';

  /* case when transfer to gl only = 'N'
     all open trnasactions
  */
  C_OPEN_INVOICES_SQL CONSTANT VARCHAR2(32000) := '
        select  b.balancing_segment,
                b.account_segment,
                b.code_combination_id,
                b.account,
                b.party_id,
                b.party_site_id,
                b.party_name,
                b.vendor_id,
                b.vendor_number,
                b.vendor_site_id,
                b.vendor_site_code,
                b.txn_id,
                b.txn_number,
                b.txn_type_lookup_code,
                b.txn_date,
                b.txn_currency_code,
                b.payment_currency_code,
                b.TXN_BASE_EXCHANGE_RATE,
                b.payment_cross_rate,
                AP_OPEN_ITEMS_REVAL_PKG.get_revaluation_rate(b.txn_currency_code) revaluation_rate,
                b.payment_status_flag,
                b.entered_amount,
                b.accounted_amount,
                nvl(round((pay_cur_inv_entered_amt - payment_entered_amount)/b.payment_cross_rate, 2), b.entered_amount) open_entered_amount,
                nvl(round(round((pay_cur_inv_entered_amt - payment_entered_amount)/b.payment_cross_rate, 2) * b.TXN_BASE_EXCHANGE_RATE, :g_base_precision), b.accounted_amount) open_accounted_amount
          from (
              select /*+ leading (aoi aip) parallel(aoi)*/ distinct
                              aoi.code_combination_id,
                              aoi.party_id,
                              aoi.party_site_id,
                              aoi.vendor_id,
                              aoi.vendor_number,
                              aoi.vendor_site_id,
                              aoi.txn_id invoice_id,
                              aoi.txn_currency_code,
                              aoi.payment_currency_code,
                              aoi.TXN_BASE_EXCHANGE_RATE,
                              aoi.payment_cross_rate,
                              round(aoi.entered_amount * aoi.payment_cross_rate, 2) pay_cur_inv_entered_amt,
                              sum((nvl(aip.amount, 0) + nvl(aip.discount_taken, 0))) payment_entered_amount
                from ap_open_items_reval_gt aoi,
                     ap_invoice_payments_all aip,
                     ap_checks_all ac
               where aip.invoice_id = aoi.txn_id
                 and aip.set_of_books_id = $ledger_id$
                 and aip.org_id = $org_id$
                 and ac.check_id = aip.check_id
                 and aoi.txn_type_lookup_code <> ''Payment''
                 $cleared_condition$
                group by aoi.code_combination_id,
                         aoi.party_id,
                         aoi.party_site_id,
                         aoi.vendor_id,
                         aoi.vendor_number,
                         aoi.vendor_site_id,
                         aoi.txn_id ,
                         aoi.txn_currency_code,
                         aoi.payment_currency_code,
                         aoi.TXN_BASE_EXCHANGE_RATE,
                         aoi.payment_cross_rate,
                         aoi.entered_amount
               )a, ap_open_items_reval_gt b
          where b.txn_id = a.invoice_id(+)
            and b.code_combination_id = a.code_combination_id(+)
            and nvl((a.pay_cur_inv_entered_amt - a.payment_entered_amount), b.entered_amount) <> 0
            and decode(nvl(sign(abs(a.pay_cur_inv_entered_amt - a.payment_entered_amount)-1), 1)
                           ,-1, decode(nvl(b.payment_status_flag, ''N'')
                                      ,''Y'', 0
                                          , 1
                                      )
                              , 1
                      ) <> 0
          ';

  -- for getting the revaluation rate
  function get_revaluation_rate(l_currency_code IN gl_sets_of_books.currency_code%type)
    return number is
    l_revaluation_rate gl_daily_rates.conversion_rate%type;
  begin

    if l_currency_code = g_base_currency_code then
      return 1;
    end if;

    if P_RATE_TYPE_LOOKUP_CODE = 'PERIOD' then

      begin
        select 1 / min(eop_rate)
          into l_revaluation_rate
          from gl_translation_rates gtr
         where gtr.set_of_books_id = g_ledger_id
           and gtr.to_currency_code = l_currency_code
           and upper(gtr.period_name) = upper(P_REVALUATION_PERIOD)
           and gtr.actual_flag = 'A';

        return l_revaluation_rate;
      exception
        when others then
          return null;
      end;

    else
      if P_RATE_TYPE_LOOKUP_CODE = 'DAILY' then
        begin

          l_revaluation_rate := ap_utilities_pkg.get_exchange_rate(l_currency_code,
                                                                   g_base_currency_code,
                                                                   P_DAILY_RATE_TYPE,
                                                                   P_DAILY_RATE_DATE,
                                                                   'APOPITRN');

          return l_revaluation_rate;
        exception
          when others then
            return null;
        end;
      else
        null; --invalid rate type
      end if;
    end if;

    return null;
  end get_revaluation_rate;

  -- for due_date calculation
  function get_due_date(p_invoice_id IN number, p_type in varchar2)
    return date is
    l_due_date DATE;
  begin
    select min(due_date)
      into l_due_date
      from ap_payment_schedules_all
     where invoice_id = p_invoice_id
       and p_type <> 'Payment';

    return l_due_Date;
  exception
    when others then
      return null;
  end get_due_date;

  PROCEDURE set_displayed_values IS
  BEGIN

    select name
      into g_operating_unit_dsp
      from hr_operating_units
     where organization_id = P_ORG_ID;

    select gsob.name,
           gsob.set_of_books_id,
           gsob.currency_code,
           fc.precision,
           nvl(fc.minimum_accountable_unit, 0),
           fc.description,
           gsob.chart_of_accounts_id
      into g_gl_name_dsp,
           g_ledger_id,
           g_base_currency_code,
           g_base_precision,
           g_base_min_acct_unit,
           g_base_currency_desc,
           g_coa_id
      from gl_sets_of_books         gsob,
           ap_system_parameters_all asp,
           fnd_currencies_vl        fc
     where gsob.set_of_books_id = asp.set_of_books_id
       and fc.currency_code = gsob.currency_code
       and asp.org_id = P_ORG_ID;

    select gps.end_date
      into g_revaluation_date
      from gl_period_statuses gps
     where upper(gps.period_name) = upper(P_REVALUATION_PERIOD)
       and gps.set_of_books_id = g_ledger_id
       and gps.application_id = c_application_id;

    select displayed_field
      into g_rate_type_dsp
      from ap_lookup_codes
     where lookup_type = 'APXINREV_RATE_TYPE'
       and lookup_code = P_RATE_TYPE_LOOKUP_CODE;

    if P_RATE_TYPE_LOOKUP_CODE = 'PERIOD' then
      if P_DAILY_RATE_TYPE is not null or P_DAILY_RATE_DATE is not null then
        g_daily_rate_information := 'Y';
      end if;
    else

      if P_RATE_TYPE_LOOKUP_CODE = 'DAILY' then
        if P_DAILY_RATE_TYPE is null or P_DAILY_RATE_DATE is null then
          g_daily_rate_error := 'Y';
        else
          select user_conversion_type
            into g_daily_rate_type_dsp
            from gl_daily_conversion_types
           where conversion_type = P_DAILY_RATE_TYPE;
        end if;
      end if;
    end if;

    select meaning
      into g_trans_to_gl_only_dsp
      from fnd_lookups
     where lookup_type = 'YES_NO'
       and lookup_code = P_TRANSFER_TO_GL_ONLY;

    select meaning
      into g_cleared_only_dsp
      from fnd_lookups
     where lookup_type = 'YES_NO'
       and lookup_code = P_CLEARED_ONLY;

  END set_displayed_values;

  FUNCTION before_report RETURN BOOLEAN AS
    l_balancing_segment    VARCHAR2(80);
    l_account_segment      VARCHAR2(80);
    l_costcenter_segment   VARCHAR2(80);
    l_management_segment   VARCHAR2(80);
    l_intercompany_segment VARCHAR2(80);
    l_segments_column      VARCHAR2(1000);
    l_segments_group       VARCHAR2(1000);

    l_cleared_condition VARCHAR2(1000);
    l_bal_seg_condition VARCHAR2(1000) := '';
    l_invoices_gt_sql   VARCHAR2(32000) := '';
    l_payments_gt_sql   VARCHAR2(32000) := '';
    l_open_sql          VARCHAR2(32000) := '';
  BEGIN

    /* report values to be display on report header */
    set_displayed_values;

    /* get qualifier segments for the charts of accounts */
    xla_report_utility_pkg.get_acct_qualifier_segs(p_coa_id               => g_coa_id,
                                                   p_balance_segment      => l_balancing_segment,
                                                   p_account_segment      => l_account_segment,
                                                   p_cost_center_segment  => l_costcenter_segment,
                                                   p_management_segment   => l_management_segment,
                                                   p_intercompany_segment => l_intercompany_segment);

    -- form the required conditions for the queries
    l_segments_column := 'gcck.' || l_balancing_segment ||
                         ' balancing_segment,' || C_NEW_LINE || 'gcck.' ||
                         l_account_segment || ' account_segment,';
    l_segments_group  := 'gcck.' || l_balancing_segment || ',' ||
                         C_NEW_LINE || 'gcck.' || l_account_segment || ' ,';

    if P_FROM_BALANCING_SEGMENT is not null then
      l_bal_seg_condition := 'and gcck.' || l_balancing_segment || ' >= ' ||
                             ''''||P_FROM_BALANCING_SEGMENT||''''; --8552975
    end if;

    if P_TO_BALACING_SEGMENT is not null then
      l_bal_seg_condition := l_bal_seg_condition || ' and gcck.' ||
                             l_balancing_segment || ' <= ' ||
                             ''''||P_TO_BALACING_SEGMENT||''''; --8552975
    end if;

    if P_CLEARED_ONLY = 'Y' then
      l_cleared_condition := ' and ac.status_lookup_code IN (''CLEARED'',
                                                                ''RECONCILED'',
                                                                ''CLEARED BUT UNACCOUNTED'',
                                                                ''RECONCILED UNACCOUNTED'')'; --bug9483780
    end if;

    -- build the gt queries
    if P_TRANSFER_TO_GL_ONLY = 'Y' then
      l_invoices_gt_sql := C_GL_TRANSFER_INVOICES_GT_SQL;
      l_payments_gt_sql := C_GL_TRANSFER_PAYMENTS_GT_SQL;
      l_open_sql        := C_GL_TRAN_OPEN_INVOICES_SQL;
    else
      l_invoices_gt_sql := C_INVOICES_GT_SQL;
      l_payments_gt_sql := C_PAYMENTS_GT_SQL;
      l_open_sql        := C_OPEN_INVOICES_SQL;
    end if;

    l_invoices_gt_sql := replace(l_invoices_gt_sql,
                                 '$segment_columns$',
                                 l_segments_column);
    l_invoices_gt_sql := replace(l_invoices_gt_sql,
                                 '$segment_group$',
                                 l_segments_group);
    l_invoices_gt_sql := replace(l_invoices_gt_sql,
                                 '$bal_segment_condition$',
                                 l_bal_seg_condition);
    l_invoices_gt_sql := replace(l_invoices_gt_sql,
                                 '$ledger_id$',
                                 g_ledger_id);
    l_invoices_gt_sql := replace(l_invoices_gt_sql, '$org_id$', P_ORG_ID);
    l_invoices_gt_sql := replace(l_invoices_gt_sql,
                                 '$accounting_date$',
                                 '''' || g_revaluation_date || '''');

    l_payments_gt_sql := replace(l_payments_gt_sql,
                                 '$segment_columns$',
                                 l_segments_column);
    l_payments_gt_sql := replace(l_payments_gt_sql,
                                 '$segment_group$',
                                 l_segments_group);
    l_payments_gt_sql := replace(l_payments_gt_sql,
                                 '$bal_segment_condition$',
                                 l_bal_seg_condition);
    l_payments_gt_sql := replace(l_payments_gt_sql,
                                 '$ledger_id$',
                                 g_ledger_id);
    l_payments_gt_sql := replace(l_payments_gt_sql, '$org_id$', P_ORG_ID);
    l_payments_gt_sql := replace(l_payments_gt_sql,
                                 '$accounting_date$',
                                 '''' || g_revaluation_date || '''');

    -- execute the gt queries
    execute immediate 'insert into ap_open_items_reval_gt (
BALANCING_SEGMENT,
ACCOUNT_SEGMENT,
CODE_COMBINATION_ID,
ACCOUNT,
PARTY_ID,
PARTY_SITE_ID,
PARTY_NAME,
VENDOR_ID,
VENDOR_NUMBER,
VENDOR_SITE_ID,
VENDOR_SITE_CODE,
TXN_ID,
TXN_NUMBER,
TXN_TYPE_LOOKUP_CODE,
TXN_DATE,
TXN_AMOUNT,
TXN_BASE_AMOUNT,
TXN_CURRENCY_CODE,
TXN_CURR_MIN_ACCT_UNIT,
TXN_CURR_PRECISION,
TXN_BASE_EXCHANGE_RATE,
PAYMENT_CURRENCY_CODE,
PAYMENT_CROSS_RATE,
PAYMENT_CURR_PRECISION,
PMT_CURR_MIN_ACCT_UNIT,
PAYMENT_STATUS_FLAG,
ENTERED_AMOUNT,
ACCOUNTED_AMOUNT,
DUE_DATE)	' ||
                      l_invoices_gt_sql
      using g_daily_rate_error;

    execute immediate 'insert into ap_open_items_reval_gt (
BALANCING_SEGMENT,
ACCOUNT_SEGMENT,
CODE_COMBINATION_ID,
ACCOUNT,
PARTY_ID,
PARTY_SITE_ID,
PARTY_NAME,
VENDOR_ID,
VENDOR_NUMBER,
VENDOR_SITE_ID,
VENDOR_SITE_CODE,
TXN_ID,
TXN_NUMBER,
TXN_TYPE_LOOKUP_CODE,
TXN_DATE,
TXN_AMOUNT,
TXN_BASE_AMOUNT,
TXN_CURRENCY_CODE,
TXN_CURR_MIN_ACCT_UNIT,
TXN_CURR_PRECISION,
TXN_BASE_EXCHANGE_RATE,
PAYMENT_CURRENCY_CODE,
PAYMENT_CROSS_RATE,
PAYMENT_CURR_PRECISION,
PMT_CURR_MIN_ACCT_UNIT,
PAYMENT_STATUS_FLAG,
ENTERED_AMOUNT,
ACCOUNTED_AMOUNT,
DUE_DATE)	' ||
                      l_payments_gt_sql
      using g_daily_rate_error, g_daily_rate_error;

    -- build the xml query
    l_open_sql := replace(l_open_sql, '$ledger_id$', g_ledger_id);
    l_open_sql := replace(l_open_sql, '$org_id$', P_ORG_ID);
    l_open_sql := replace(l_open_sql,
                          '$cleared_condition$',
                          l_cleared_condition);
    l_open_sql := replace(l_open_sql,
                          '$accounting_date$',
                          '''' || g_revaluation_date || '''');

    G_SQL_STATEMENT := replace(G_SQL_STATEMENT,
                               '$open_items_query$',
                               l_open_sql);

    RETURN TRUE;
  END before_report;

END AP_OPEN_ITEMS_REVAL_PKG;

/
