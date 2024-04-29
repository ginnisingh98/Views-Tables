--------------------------------------------------------
--  DDL for Package Body AP_PERIOD_CLOSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PERIOD_CLOSE_PKG" as
/* $Header: apprdclb.pls 120.9.12010000.14 2010/04/23 17:46:02 imandal noship $ */

  cursor c_get_period_dates (cp_period_name             gl_period_statuses.period_name%type default g_period_name
                            ,cp_include_adj_period      gl_period_statuses.adjustment_period_flag%type default null
                            )
    is
    SELECT start_date, end_date, closing_status
    FROM  gl_period_statuses
    WHERE period_name = cp_period_name
    AND application_id = G_AP_APPLICATION_ID
    AND set_of_books_id = g_ledger_id
    and  (cp_include_adj_period is null or (nvl(adjustment_period_flag,'N') = cp_include_adj_period));

  cursor c_ledger_attribs
  is
  select name, sla_ledger_cash_basis_flag
  from gl_sets_of_books
  where set_of_books_id = g_ledger_id;

  /*------------------------------------------------------------------------------------------------------------------------*/
  PROCEDURE Print
            (
            p_string IN     VARCHAR2
            )
  IS
    lv_stemp    VARCHAR2(80);
    ln_length  NUMBER := 1;
  BEGIN

       WHILE(length(P_string) >= ln_length)
       LOOP

          lv_stemp := substrb(P_string, ln_length, 80);
          fnd_file.put_line(FND_FILE.LOG, lv_stemp);
          ln_length := (ln_length + 80);

       END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Print;


 /*------------------------------------------------------------------------------------------------------------------------*/
  procedure debug (p_debug_msg  in varchar2)
  is
  begin
      print (p_debug_msg);
  end debug;

/*------------------------------------------------------------------------------------------------------------------------*/
  procedure populate_orgs (p_ledger_id  number
                          ,p_process_flag out nocopy varchar2
                          ,p_process_message out nocopy varchar2
                          )
  is
    ln_org_cnt number :=0;
  begin
    --
    -- we are fetching all the operating units defined under ledger and populating
    -- a GTT
    --
    for r_org in c_get_all_orgs
    loop

      insert into ap_org_attributes_gt
                    (org_name
                    ,org_id
                    ,recon_accounting_flag
                    ,when_to_account_pmt
		    ,set_of_books_id
                    )
          values    (r_org.operating_unit_name
                    ,r_org.org_id
                    ,r_org.recon_accounting_flag
                    ,r_org.when_to_account_pmt
                    ,r_org.set_of_books_id
                    );
       ln_org_cnt := ln_org_cnt + 1;


    end loop;

    if ln_org_cnt = 0 then
       p_process_flag := 'EE';
       p_process_message := 'AP_INVALID_LEDGER';
       return;
    end if;

    debug ('populate_orgs: total orgs populated in ap_org_attributes_gt= '||ln_org_cnt);

    p_process_flag := 'SS';
    p_process_message := null;

  end populate_orgs;

  /*------------------------------------------------------------------------------------------------------------------------*/
  --
  -- get_unposted_transactions
  -- contains logic to derive unposted (exceptional) invoice distributions, lines and
  -- payment related transaction.  It operate in two different mode.
  -- if action = PERIOD_CLOSE, it will populate only one row to check for existance of
  -- such exceptions and returns immediately if any.
  -- For action other than PERIOD_CLOSE it actually poupulates all the rows
  --
 /*------------------------------------------------------------------------------------------------------------------------*/
  function get_unposted_transactions
  return varchar2
  is

   /*Bug#7649020: Defining table collection type to hold exception
     data reported by SLA cursors.
     For bugs related to events not picked by SLA cursors log a
     bug against SLA team.
   */
   type xla_period_close_header_tab is table of XLA_PERIOD_CLOSE_EXP_PKG.period_close_hdr_date_cur%rowtype;
   xla_headers_untransfered xla_period_close_header_tab := xla_period_close_header_tab();

   type xla_period_close_evt_tab is table of XLA_PERIOD_CLOSE_EXP_PKG.period_close_evt_date_cur%rowtype;
   xla_events_unacct xla_period_close_evt_tab := xla_period_close_evt_tab();

   l_rowcount NUMBER := NULL;  -- bug 9509700

  begin

    --
    --  Invoice processing is not required If ledger is set to CASH based accounting
    --


      debug ('g_cash_basis_flag='||g_cash_basis_flag);
      --TODO Need to figure out from XLA about how to derive the accounting method - Cash/Accrual.
      if g_cash_basis_flag <> 'Y' then

      --------------
      -- INVOICES --
      --------------

      <<invoice_processing>>

      -- insert statement will populate all un-posted invoice distributions
      -- if action is PERIOD_CLOSE only one row will be fetched to check
      -- existance unposted transactions
      insert into ap_period_close_excps_gt
                  (   invoice_id
                     ,invoice_distribution_id
		     ,invoice_payment_id  -- 7318763
		     ,accounting_event_id
                     ,accounting_date
                     ,org_id
                     ,invoice_num
                     ,invoice_currency_code
		     ,party_id
                     ,vendor_id
                     ,doc_sequence_value
                     ,voucher_num
                     ,invoice_date
                     ,invoice_amount
                     ,cancelled_date
                     ,match_status_flag
		     ,legal_entity_id
		     ,po_distribution_id
		     ,amount
		     ,detail_tax_dist_id
		     ,invoice_line_number
                     ,source_type
                     ,source_table_name
                  )
      select     ai.invoice_id
                ,aid.invoice_distribution_id
		,aid.awt_invoice_payment_id  -- 7318763
		,aid.accounting_event_id
                ,aid.accounting_date
                ,aid.org_id
                ,ai.invoice_num
                ,ai.invoice_currency_code
		,ai.party_id
                ,ai.vendor_id
                ,ai.doc_sequence_value
                ,ai.voucher_num
                ,ai.invoice_date
                ,ai.invoice_amount
                ,ai.cancelled_date
                ,aid.match_status_flag
                ,ai.legal_entity_id
                ,aid.po_distribution_id
                ,aid.amount
                ,aid.detail_tax_dist_id
		,aid.invoice_line_number
                ,G_SRC_TYP_UNACCT_DISTS
                ,G_SRC_TAB_AP_INV_DISTS_ALL
      from
                 ap_invoices_all ai
                ,ap_invoice_distributions_all aid
                ,ap_org_attributes_gt org_gtt
      where
                ai.invoice_id = aid.invoice_id
        and ( aid.accounting_date between g_period_start_date and g_period_end_date)
        and     aid.posted_flag  in ('N' , 'S', 'P') -- N=Not Accounted, S=Selected for Accounting, P=Partially Accounted for CASH based accounting
        and     aid.set_of_books_id = g_ledger_id
        and     aid.org_id = org_gtt.org_id
        and     (  g_action <> G_ACTION_PERIOD_CLOSE
                OR (g_action = G_ACTION_PERIOD_CLOSE and ROWNUM = 1 )  -- for period close we just need check if any such record exists
                )
        and     ai.approval_ready_flag <> 'S'; --bug 9224843


	l_rowcount := sql%rowcount; -- bug 9509700

       debug ('Total records inserted in ap_period_close_excps_gt for source_type='||G_SRC_TYP_UNACCT_DISTS||' is:'||l_rowcount);

      if g_action = G_ACTION_PERIOD_CLOSE and l_rowcount > 0 then
        -- current action is PERIOD_CLOSE and there are unposted invoices
        -- and  we cannot allow to close period hence return
        return 'Y';
      end if;

      l_rowcount := NULL;

      insert into ap_period_close_excps_gt
                  (   invoice_id
                     ,invoice_distribution_id
		     ,accounting_event_id
                     ,accounting_date
                     ,org_id
                     ,invoice_num
                     ,invoice_currency_code
		     ,party_id
                     ,vendor_id
                     ,doc_sequence_value
                     ,voucher_num
                     ,invoice_date
                     ,invoice_amount
                     ,cancelled_date
                     ,match_status_flag
		     ,legal_entity_id
		     ,po_distribution_id
		     ,amount
		     ,detail_tax_dist_id
                     ,source_type
                     ,source_table_name
                  )
      select     ai.invoice_id
                ,astd.invoice_distribution_id
		,astd.accounting_event_id
                ,astd.accounting_date
                ,astd.org_id
                ,ai.invoice_num
                ,ai.invoice_currency_code
		,ai.party_id
                ,ai.vendor_id
                ,ai.doc_sequence_value
                ,ai.voucher_num
                ,ai.invoice_date
                ,ai.invoice_amount
                ,ai.cancelled_date
                ,astd.match_status_flag
                ,ai.legal_entity_id
                ,astd.po_distribution_id
                ,astd.amount
                ,astd.detail_tax_dist_id
                ,G_SRC_TYP_UNACCT_DISTS
                ,G_SRC_TAB_AP_SELF_TAX_DIST_ALL
      from
                 ap_invoices_all ai
                ,ap_self_assessed_tax_dist_all astd
                ,ap_org_attributes_gt org_gtt
      where
                ai.invoice_id = astd.invoice_id
        and (astd.accounting_date between g_period_start_date and g_period_end_date )
        and     astd.posted_flag  in ('N' , 'S', 'P') -- N=Not Accounted, S=Selected for Accounting, P=Partially Accounted for CASH based accounting
        and    astd.set_of_books_id = g_ledger_id
        and     astd.org_id = org_gtt.org_id
        and     (  g_action <> G_ACTION_PERIOD_CLOSE
                OR (g_action = G_ACTION_PERIOD_CLOSE and ROWNUM = 1 )  -- for period close we just need check if any such record exists
                )
        and     ai.approval_ready_flag <> 'S'; --bug 9224843


	l_rowcount := sql%rowcount; -- bug 9509700

       debug ('Total records inserted in ap_period_close_excps_gt for source_type='||G_SRC_TYP_UNACCT_DISTS||'for table='||G_SRC_TAB_AP_SELF_TAX_DIST_ALL
 || ' is:'||l_rowcount);

      if g_action = G_ACTION_PERIOD_CLOSE and l_rowcount > 0 then
        -- current action is PERIOD_CLOSE and there are unposted self assessed tax dists
        -- and  we cannot allow to close period hence return
        return 'Y';
      end if;

      l_rowcount := NULL;

      insert into ap_period_close_excps_gt
              (   invoice_id
                 ,invoice_line_number
                 ,accounting_date
                 ,org_id
                 ,invoice_num
                 ,invoice_currency_code
		 ,party_id
                 ,vendor_id
                 ,doc_sequence_value
                 ,voucher_num
                 ,invoice_date
                 ,invoice_amount
                 ,cancelled_date
                 ,source_type
                 ,source_table_name
              )
                 select ai.invoice_id  /* Removed the Hint (leading(ail)) for bug#8870730 */
                ,ail.line_number
                ,ail.accounting_date
                ,ail.org_id
                ,ai.invoice_num
                ,ai.invoice_currency_code
		,ai.party_id
                ,ai.vendor_id
                ,ai.doc_sequence_value
                ,ai.voucher_num
                ,ai.invoice_date
                ,ai.invoice_amount
                ,ai.cancelled_date
                ,G_SRC_TYP_LINES_WITHOUT_DISTS
                ,G_SRC_TAB_AP_INV_LINES_ALL
          from
                ap_invoices_all ai
               ,ap_invoice_lines_all ail
               ,ap_org_attributes_gt org_gtt
          where
                ai.invoice_id = ail.invoice_id
        and (ail.accounting_date between g_period_start_date and g_period_end_date)
          and   not exists (select 1                                          --> lines without distributions
                            from   ap_invoice_distributions_all aid
                            where  aid.invoice_id = ai.invoice_id
                            and    aid.invoice_line_number = ail.line_number
                           )
          --Bug 7242216 Excluding invoices having discarded lines with
          --no distributions
 	  and  ail.discarded_flag <> 'Y'
	  and  ail.amount <> 0
          and  ai.cancelled_date is null
          and  ail.set_of_books_id = g_ledger_id
          and  ail.org_id = org_gtt.org_id
          and  (  g_action <> G_ACTION_PERIOD_CLOSE
               OR (g_action = G_ACTION_PERIOD_CLOSE and ROWNUM = 1 )  -- for period close we just need check if any such record exists
               )
          and  ai.approval_ready_flag <> 'S'; --bug 9224843

	  l_rowcount := sql%rowcount; -- bug 9509700

       debug ('Total records inserted in ap_period_close_excps_gt for source_type='||G_SRC_TYP_LINES_WITHOUT_DISTS||' is:'||l_rowcount);

      if g_action = G_ACTION_PERIOD_CLOSE and l_rowcount > 0 then
        -- current action is PERIOD_CLOSE and there are lines without any distributions
        -- so we cannot allow to close perio,  hence return
        return 'Y';
      end if;

      l_rowcount := NULL;

      -- gagrawal
      insert into ap_period_close_excps_gt
                  (   invoice_id
		     ,accounting_event_id
                     ,accounting_date
                     ,org_id
                     ,invoice_num
                     ,invoice_currency_code
		     ,party_id
                     ,vendor_id
                     ,doc_sequence_value
                     ,voucher_num
                     ,invoice_date
                     ,invoice_amount
                     ,cancelled_date
		     ,legal_entity_id
                     ,source_type
                     ,source_table_name
                  )
      select     ai.invoice_id
		,apph.accounting_event_id
                ,apph.accounting_date
                ,ai.org_id
                ,ai.invoice_num
                ,ai.invoice_currency_code
		,ai.party_id
                ,ai.vendor_id
                ,ai.doc_sequence_value
                ,ai.voucher_num
                ,ai.invoice_date
                ,ai.invoice_amount
                ,ai.cancelled_date
                ,ai.legal_entity_id
                ,G_SRC_TYP_UNACCT_PREPAY_HIST
                ,G_SRC_TAB_AP_PREPAY_HIST
      from       ap_invoices_all ai
                ,ap_prepay_history_all apph
                ,ap_org_attributes_gt org_gtt
      where
                ai.invoice_id = apph.invoice_id
        and ( apph.accounting_date between g_period_start_date and g_period_end_date)
        and     apph.posted_flag  in ('N' , 'S', 'P') -- N=Not Accounted, S=Selected for Accounting, P=Partially Accounted for CASH based accounting
	and     apph.accounting_event_id IS NOT NULL
        and     ai.set_of_books_id = g_ledger_id
        and     ai.org_id = org_gtt.org_id
        and     (  g_action <> G_ACTION_PERIOD_CLOSE
                OR (g_action = G_ACTION_PERIOD_CLOSE and ROWNUM = 1 )  -- for period close we just need check if any such record exists
                );

	l_rowcount := sql%rowcount;  -- bug 9509700


      debug ('Total records inserted in ap_period_close_excps_gt for source_type='||G_SRC_TYP_UNACCT_PREPAY_HIST||' is:'||l_rowcount);

      if g_action = G_ACTION_PERIOD_CLOSE and l_rowcount > 0 then
        -- current action is PERIOD_CLOSE and there are lines without any distributions
        -- so we cannot allow to close perio,  hence return
        return 'Y';
      end if;

      l_rowcount := NULL;

     end if; -->  g_cash_basis_flag <> 'Y'


    ---------------
    --  PAYMENTS --
    ----------------
    <<payment_processing>>

    INSERT INTO AP_PERIOD_CLOSE_EXCPS_GT
            (payment_history_id
            ,accounting_event_id
            ,accounting_date
            ,check_id
            ,transaction_type
            ,org_id
            ,recon_accounting_flag
            ,check_number
            ,exchange_rate
            ,check_date
            ,legal_entity_id
            ,vendor_name
            ,bank_account_name
            ,check_amount
            ,currency_code
	    ,party_id
            ,vendor_id
            ,source_type
            ,source_table_name
            )
    SELECT  aph.payment_history_id,
            aph.accounting_event_id,
            aph.accounting_date,
            aph.check_id,
            aph.transaction_type,
            aph.org_id,
            orgs.recon_accounting_flag,
            ac.check_number,
            ac.exchange_rate,
            ac.check_date,
            ac.legal_entity_id,
	    ac.vendor_name,
            ac.bank_account_name,
            --ac.amount, --bug 7416004
	    decode(aph.transaction_type,'PAYMENT CANCELLED',(-1*ac.amount),
	                               'REFUND CANCELLED',(-1*ac.amount),
				       ac.amount),
            ac.currency_code,
	    ac.party_id,
            ac.vendor_id
            ,G_SRC_TYP_UNACCT_PMT_HISTORY
            ,G_SRC_TAB_AP_PMT_HISTORY
    FROM    ap_payment_history_all aph,
            ap_checks_all ac,
            ap_org_attributes_gt orgs
    WHERE  aph.posted_flag IN ('N','S')
    AND    ac.check_id = aph.check_id
    and (aph.accounting_date between g_period_start_date and g_period_end_date)
    AND    aph.org_id = orgs.org_id
    AND    ( NVL(orgs.when_to_account_pmt, 'ALWAYS') = 'ALWAYS' or
               (NVL(orgs.when_to_account_pmt, 'ALWAYS') = 'CLEARING ONLY'  and
                        aph.transaction_type in ('PAYMENT CLEARING', 'PAYMENT UNCLEARING')))
    and   (  g_action <> G_ACTION_PERIOD_CLOSE
          OR (g_action = G_ACTION_PERIOD_CLOSE and ROWNUM = 1 )  -- for period close we just need check if any such record exists
          );

    l_rowcount := sql%rowcount;  -- bug 9509700

    debug ('Total records inserted in ap_period_close_excps_gt for source_type='||G_SRC_TYP_UNACCT_PMT_HISTORY||' is:'||l_rowcount);

    if g_action = G_ACTION_PERIOD_CLOSE and l_rowcount > 0 then
      -- current action is PERIOD_CLOSE and there are lines without any distributions
      -- so we cannot allow to close period,  hence return
      return 'Y';
    end if;

    l_rowcount := NULL;

  if g_action = G_ACTION_SWEEP then -- populate GT ONLY when sweeping
    -- get unaccounted invoice payments
    insert into ap_period_close_excps_gt
            (invoice_payment_id
            ,accounting_event_id
            ,accounting_date
            ,check_id
            ,payment_amount
            ,org_id
            ,recon_accounting_flag
            ,check_number
            ,exchange_rate
            ,check_date
            ,legal_entity_id
            ,vendor_name
            ,bank_account_name
            ,check_amount
            ,currency_code
            ,status_lookup_code
            ,party_id
            ,vendor_id
            ,source_type
            ,source_table_name
            )
    SELECT  aip.invoice_payment_id,
            aip.accounting_event_id,
            aip.accounting_date,
            aip.check_id,
            aip.amount,
            aip.org_id,
            orgs.recon_accounting_flag,
            ac.check_number,
            ac.exchange_rate,
            ac.check_date,
            ac.legal_entity_id,
            ac.vendor_name,
            ac.bank_account_name,
            ac.amount,
            ac.currency_code,
            ac.status_lookup_code,
	    ac.party_id,
            ac.vendor_id
            ,G_SRC_TYP_UNACCT_INV_PMTS
            ,G_SRC_TAB_AP_INV_PAYMENTS
    FROM    ap_invoice_payments_all aip,
    ap_checks_All ac,
            ap_org_attributes_gt orgs
    WHERE   aip.posted_flag IN ('N','S')
    and (aip.accounting_date between g_period_start_date and g_period_end_date)
    AND     aip.org_id = orgs.org_id
    AND     ac.check_id = aip.check_id
    AND     NVL(orgs.when_to_account_pmt, 'ALWAYS') = 'ALWAYS';

    l_rowcount := sql%rowcount;  -- bug 9509700

    debug ('Total records inserted in ap_period_close_excps_gt for source_type='||G_SRC_TYP_UNACCT_INV_PMTS||' is:'||l_rowcount);

    l_rowcount := NULL;
  end if;

  /*Bug#7649020: Fetching data from SLA cursors and inserting into GT tables.
   * If action is period closure returing after check of one record.
   * If action is other than period closure (UTR,PCER,SWEEP), inserting
   * data fetched by cursor into GT table.
   *
   *Bug#8240910: SLA cursor modified to fetch data over a date range instead
   * of period name as the reports can be submitted over any date range and
   * not specifically over a period. Modified the call to SLA cursor to pass
   * start date and end date instead of passing period name
  */
  IF g_action = G_ACTION_PERIOD_CLOSE THEN
    OPEN xla_period_close_exp_pkg.period_close_hdr_date_cur(200,g_ledger_id,g_period_start_date,g_period_end_date);
    xla_headers_untransfered.EXTEND();
    FETCH xla_period_close_exp_pkg.period_close_hdr_date_cur INTO xla_headers_untransfered(1);
    CLOSE xla_period_close_exp_pkg.period_close_hdr_date_cur;
    IF xla_headers_untransfered(1).event_id IS NOT NULL THEN
	RETURN 'Y';
    END IF;

    OPEN xla_period_close_exp_pkg.period_close_evt_date_cur(200,g_ledger_id,g_period_start_date,g_period_end_date);
    xla_events_unacct.EXTEND();
    FETCH xla_period_close_exp_pkg.period_close_evt_date_cur INTO xla_events_unacct(1);
    CLOSE xla_period_close_exp_pkg.period_close_evt_date_cur;
    IF xla_events_unacct(1).event_id IS NOT NULL THEN
	RETURN 'Y';
    END IF;

  ELSE

   IF g_action = G_ACTION_PCER THEN
    -- Insert untransferred headers to GT table only if action is PCER
    OPEN xla_period_close_exp_pkg.period_close_hdr_date_cur(200,g_ledger_id,g_period_start_date,g_period_end_date);
    FETCH xla_period_close_exp_pkg.period_close_hdr_date_cur
    BULK COLLECT INTO xla_headers_untransfered;
    CLOSE xla_period_close_exp_pkg.period_close_hdr_date_cur;

    IF xla_headers_untransfered.COUNT> 0 THEN
    FOR i IN xla_headers_untransfered.FIRST..xla_headers_untransfered.LAST
    LOOP

    -- Bug 8887052: Modified decode on invoices to consider MANUAL events
    -- untransferred headers as well.

    INSERT INTO ap_period_close_excps_gt
          (accounting_event_id
           ,accounting_date
	   ,org_id
	   ,legal_entity_id
	   ,invoice_num
	   ,invoice_id
	   ,invoice_date
	   ,check_number
           ,check_id
	   ,check_date
	   ,event_type_code
	   ,entity_code
           ,source_type
           ,source_table_name
          ) values
	  (xla_headers_untransfered(i).event_id
	   ,xla_headers_untransfered(i).event_date
	   ,xla_headers_untransfered(i).security_id_int_1
	   ,xla_headers_untransfered(i).legal_entity_id
	   ,CASE WHEN xla_headers_untransfered(i).entity_code IN ('AP_INVOICES','MANUAL')
	    THEN xla_headers_untransfered(i).transaction_number
	    ELSE NULL END
	   ,CASE WHEN xla_headers_untransfered(i).entity_code IN ('AP_INVOICES','MANUAL')
	    THEN xla_headers_untransfered(i).source_id_int_1
	    ELSE NULL END
	   ,CASE WHEN xla_headers_untransfered(i).entity_code IN ('AP_INVOICES','MANUAL')
	    THEN xla_headers_untransfered(i).transaction_date
	    ELSE NULL END
	   ,decode(xla_headers_untransfered(i).entity_code,'AP_PAYMENTS',xla_headers_untransfered(i).transaction_number,NULL)
	   ,decode(xla_headers_untransfered(i).entity_code,'AP_PAYMENTS',xla_headers_untransfered(i).source_id_int_1,NULL)
	   ,decode(xla_headers_untransfered(i).entity_code,'AP_PAYMENTS',xla_headers_untransfered(i).transaction_date,NULL)
	   ,xla_headers_untransfered(i).event_type_code
	   ,xla_headers_untransfered(i).entity_code
	   ,G_SRC_TYP_UNTRANSFERED_HEADERS
	   ,G_SRC_TAB_XLA_AE_HEADERS
	  );

     END LOOP;
    END IF;
    END IF;

    OPEN xla_period_close_exp_pkg.period_close_evt_date_cur(200,g_ledger_id,g_period_start_date,g_period_end_date);
    FETCH xla_period_close_exp_pkg.period_close_evt_date_cur
    BULK COLLECT INTO xla_events_unacct;
    CLOSE xla_period_close_exp_pkg.period_close_evt_date_cur;

    IF xla_events_unacct.COUNT> 0 THEN
    FOR i IN xla_events_unacct.FIRST..xla_events_unacct.LAST
    LOOP
    INSERT WHEN NOT EXISTS (SELECT accounting_event_id
    		              FROM ap_period_close_excps_gt
                   	     WHERE accounting_event_id = xla_events_unacct(i).event_id)
            AND xla_events_unacct(i).entity_code='AP_INVOICES'  THEN
    INTO ap_period_close_excps_gt
                  (   invoice_id
                     ,invoice_distribution_id
		     ,invoice_payment_id  -- 7318763
		     ,accounting_event_id
                     ,accounting_date
                     ,org_id
                     ,invoice_num
                     ,invoice_currency_code
		     ,party_id
                     ,vendor_id
                     ,doc_sequence_value
                     ,voucher_num
                     ,invoice_date
                     ,invoice_amount
                     ,cancelled_date
                     ,match_status_flag
		     ,legal_entity_id
		     ,po_distribution_id
		     ,amount
		     ,detail_tax_dist_id
		     ,invoice_line_number
		     ,event_type_code
		     ,entity_code
                     ,source_type
                     ,source_table_name
                  )
        SELECT  xla_events_unacct(i).source_id_int_1
                ,aid.invoice_distribution_id
		,aid.awt_invoice_payment_id  -- 7318763
		,aid.accounting_event_id
                ,aid.accounting_date
                ,aid.org_id
                ,xla_events_unacct(i).transaction_number
                ,ai.invoice_currency_code
		,ai.party_id
                ,ai.vendor_id
                ,ai.doc_sequence_value
                ,ai.voucher_num
                ,xla_events_unacct(i).transaction_date
                ,ai.invoice_amount
                ,ai.cancelled_date
                ,aid.match_status_flag
                ,xla_events_unacct(i).legal_entity_id
                ,aid.po_distribution_id
                ,aid.amount
                ,aid.detail_tax_dist_id
		,aid.invoice_line_number
		,xla_events_unacct(i).event_type_code
		,xla_events_unacct(i).entity_code
                ,G_SRC_TYP_OTHER_EXCPS
                ,G_SRC_TAB_AP_INV_DISTS_ALL
          FROM  ap_invoices_all ai
                ,ap_invoice_distributions_all aid
                ,ap_org_attributes_gt org_gtt
          WHERE aid.invoice_id = ai.invoice_id(+)
            AND aid.set_of_books_id = g_ledger_id
            AND aid.org_id = org_gtt.org_id
	    AND aid.accounting_event_id = xla_events_unacct(i).event_id
         UNION ALL
         SELECT xla_events_unacct(i).source_id_int_1
                ,astd.invoice_distribution_id
		,NULL invoice_payment_id
		,astd.accounting_event_id
                ,astd.accounting_date
                ,astd.org_id
                ,xla_events_unacct(i).transaction_number
                ,ai.invoice_currency_code
		,ai.party_id
                ,ai.vendor_id
                ,ai.doc_sequence_value
                ,ai.voucher_num
                ,xla_events_unacct(i).transaction_date
                ,ai.invoice_amount
                ,ai.cancelled_date
                ,astd.match_status_flag
                ,xla_events_unacct(i).legal_entity_id
                ,astd.po_distribution_id
                ,astd.amount
                ,astd.detail_tax_dist_id
		,NULL invoice_line_number
		,xla_events_unacct(i).event_type_code
		,xla_events_unacct(i).entity_code
                ,G_SRC_TYP_OTHER_EXCPS
                ,G_SRC_TAB_AP_SELF_TAX_DIST_ALL
           FROM ap_invoices_all ai
                ,ap_self_assessed_tax_dist_all astd
                ,ap_org_attributes_gt org_gtt
       WHERE astd.invoice_id = ai.invoice_id(+)
         AND astd.set_of_books_id = g_ledger_id
         AND astd.org_id = org_gtt.org_id
         AND astd.accounting_event_id = xla_events_unacct(i).event_id
	 UNION ALL
	 SELECT  xla_events_unacct(i).source_id_int_1
	         ,NULL invoice_distribution_id
		 ,NULL invoice_payment_id
		,apph.accounting_event_id
                ,apph.accounting_date
                ,ai.org_id
                ,xla_events_unacct(i).transaction_number
                ,ai.invoice_currency_code
		,ai.party_id
                ,ai.vendor_id
                ,ai.doc_sequence_value
                ,ai.voucher_num
                ,xla_events_unacct(i).transaction_date
                ,ai.invoice_amount
                ,ai.cancelled_date
		,NULL match_status_flag
		,NULL po_distribution_id
		,NULL amount
		,NULL detail_tax_dist_id
		,NULL invoice_line_number
                ,xla_events_unacct(i).legal_entity_id
		,xla_events_unacct(i).event_type_code
		,xla_events_unacct(i).entity_code
                ,G_SRC_TYP_OTHER_EXCPS
                ,G_SRC_TAB_AP_PREPAY_HIST
           FROM ap_invoices_all ai
                ,ap_prepay_history_all apph
                ,ap_org_attributes_gt org_gtt
          WHERE apph.invoice_id = ai.invoice_id(+)
	    AND apph.accounting_event_id IS NOT NULL
            AND ai.set_of_books_id = g_ledger_id
            AND ai.org_id = org_gtt.org_id
            AND apph.accounting_event_id = xla_events_unacct(i).event_id;
   END LOOP;

    FOR i IN xla_events_unacct.FIRST..xla_events_unacct.LAST
    LOOP
    INSERT WHEN NOT EXISTS (SELECT accounting_event_id
    		              FROM ap_period_close_excps_gt
                   	     WHERE accounting_event_id = xla_events_unacct(i).event_id)
            AND xla_events_unacct(i).entity_code='AP_PAYMENTS' then
    INTO AP_PERIOD_CLOSE_EXCPS_GT
            (payment_history_id
            ,accounting_event_id
            ,accounting_date
            ,check_id
            ,transaction_type
            ,org_id
            ,recon_accounting_flag
            ,check_number
            ,exchange_rate
            ,check_date
            ,legal_entity_id
            ,vendor_name
            ,bank_account_name
            ,check_amount
            ,currency_code
	    ,party_id
            ,vendor_id
	    ,event_type_code
	    ,entity_code
            ,source_type
            ,source_table_name
            )
    SELECT  aph.payment_history_id,
            aph.accounting_event_id,
            aph.accounting_date,
            xla_events_unacct(i).source_id_int_1,
            aph.transaction_type,
            aph.org_id,
            orgs.recon_accounting_flag,
            xla_events_unacct(i).transaction_number,
            ac.exchange_rate,
            xla_events_unacct(i).transaction_date,
            xla_events_unacct(i).legal_entity_id,
	    ac.vendor_name,
            ac.bank_account_name,
            ac.amount,
            ac.currency_code,
	    ac.party_id,
            ac.vendor_id
            ,xla_events_unacct(i).event_type_code
	    ,xla_events_unacct(i).entity_code
            ,G_SRC_TYP_OTHER_EXCPS
            ,G_SRC_TAB_AP_PMT_HISTORY
       FROM ap_payment_history_all aph,
            ap_checks_all ac,
            ap_org_attributes_gt orgs
      WHERE aph.check_id = ac.check_id(+)
        AND aph.org_id = orgs.org_id
        AND ( NVL(orgs.when_to_account_pmt, 'ALWAYS') = 'ALWAYS' or
            (NVL(orgs.when_to_account_pmt, 'ALWAYS') = 'CLEARING ONLY'  and
                        aph.transaction_type in ('PAYMENT CLEARING', 'PAYMENT UNCLEARING')))
        AND aph.accounting_event_id = xla_events_unacct(i).event_id;

   END LOOP;



    FOR i IN xla_events_unacct.FIRST..xla_events_unacct.LAST
    LOOP

    -- Bug 8887052: Modified decode on invoices to consider
    -- unaccounted MANUAL events as well

    INSERT WHEN NOT EXISTS (SELECT accounting_event_id
    		              FROM ap_period_close_excps_gt
                   	     WHERE accounting_event_id = xla_events_unacct(i).event_id)
    THEN
    INTO ap_period_close_excps_gt
          (accounting_event_id
           ,accounting_date
	   ,org_id
	   ,legal_entity_id
	   ,invoice_num
	   ,invoice_id
	   ,invoice_date
	   ,check_number
           ,check_id
	   ,check_date
	   ,event_type_code
	   ,entity_code
           ,source_type
           ,source_table_name
          )
     SELECT xla_events_unacct(i).event_id
	   ,xla_events_unacct(i).event_date
	   ,xla_events_unacct(i).security_id_int_1
	   ,xla_events_unacct(i).legal_entity_id
	   ,CASE WHEN xla_events_unacct(i).entity_code IN ('AP_INVOICES','MANUAL')
	    THEN xla_events_unacct(i).transaction_number
	    ELSE NULL END
	   ,CASE WHEN xla_events_unacct(i).entity_code IN ('AP_INVOICES','MANUAL')
	    THEN xla_events_unacct(i).source_id_int_1
	    ELSE NULL END
	   ,CASE WHEN xla_events_unacct(i).entity_code IN ('AP_INVOICES','MANUAL')
	    THEN xla_events_unacct(i).transaction_date
	    ELSE NULL END
	   ,decode(xla_events_unacct(i).entity_code,'AP_PAYMENTS',xla_events_unacct(i).transaction_number,NULL)
	   ,decode(xla_events_unacct(i).entity_code,'AP_PAYMENTS',xla_events_unacct(i).source_id_int_1,NULL)
	   ,decode(xla_events_unacct(i).entity_code,'AP_PAYMENTS',xla_events_unacct(i).transaction_date,NULL)
	   ,xla_events_unacct(i).event_type_code
	   ,xla_events_unacct(i).entity_code
	   ,G_SRC_TYP_OTHER_EXCPS
	   ,'ORPHAN_EVENTS'
      FROM DUAL;
    END LOOP;
   end if;
  -- Bug# 8240910: Since other exceptions are not swept anymore, removed the
  -- code which populates records from ap_invocie_payments_all to GT table.

  --END Bug#7649020: Fetching data from SLA cursors
  END IF;

    return null;

  end get_unposted_transactions;

 /*------------------------------------------------------------------------------------------------------------------------*/
  function get_reporting_level_name
  return varchar2
  is

  lv_name varchar2(100);

  begin
	SELECT meaning
	into lv_name
	FROM FND_LOOKUPS
	WHERE LOOKUP_TYPE = 'FND_MO_REPORTING_LEVEL'
	and lookup_code = g_reporting_level;

   debug ('get_reporting_level_name: lv_name='||lv_name);
   return lv_name;
   exception
	when others then

    debug ('EXCEPTION: get_reporting_level_name: '||sqlerrm);
    return null;
  end;

 /*------------------------------------------------------------------------------------------------------------------------*/
  function get_reporting_context
  return varchar2
  is
  cursor c_org_name
  is
  select org_name
  from ap_org_attributes_gt
  where org_id = g_org_id;

  lv_name varchar2(100);

  begin

     if (G_ACTION = G_ACTION_PCER or G_ACTION = G_ACTION_SWEEP
		or (G_ACTION = G_ACTION_UTR and G_REPORTING_LEVEL = 1000)) then
       lv_name := g_ledger_name;

     elsif (G_ACTION = G_ACTION_UTR and G_REPORTING_LEVEL = 3000) then
	open c_org_name;
	fetch c_org_name into lv_name;
	close c_org_name;
     end if;

   debug ('get_reporting_context: lv_name='||lv_name);
   return lv_name;
   exception
	when others then

    debug ('EXCEPTION: get_reporting_context: '||sqlerrm);
    return null;
  end;

  /*------------------------------------------------------------------------------------------------------------------------*/
  procedure validate_sweep
                    (p_validation_flag     out  nocopy  varchar2
                    ,p_validation_message  out  nocopy  varchar2
                    )
  is

    ln_cnt number;

    cursor c_cnt_org_access
    is
    select count(1)
    from ap_org_attributes_gt all_orgs
    where org_id not in (select org_id from ap_system_parameters);


  begin
    --
    --  Validation: SWEEP can be done only if all operating units defifned under the given ledger are accessible.
    --
    -- we have a all valid orgs in ap_org_attributes_gt.  If a particular org_id is present in ap_org_attributes_gt
    -- but not in ap_system_paramter it means we don't have access to that org
    --

    ln_cnt := 0;
    open  c_cnt_org_access;
    fetch c_cnt_org_access into ln_cnt;
    close c_cnt_org_access;

    if ln_cnt > 0 then  -- there are some orgs which are no accessible
        --
        -- You must have access to all the operating units defined for a ledger
        --
      p_validation_flag    := 'EE';
      p_validation_message := 'AP_SWEEP_ACCESS_ERROR';

      debug ('Number of orgs which are not accessible='||ln_cnt);

      return;
    end if;

    if p_validation_flag <> 'EE' then
      p_validation_flag := 'SS';
      p_validation_message := '';
    end if;

  end validate_sweep;
  /*------------------------------------------------------------------------------------------------------------------------*/
  procedure validate_period_close
                    (p_validation_flag     out  nocopy  varchar2
                    ,p_validation_message  out  nocopy  varchar2
                    )
  is
    -- check if any unconfirmed payment batches
    cursor c_uncnf_pmt_batch_exists is
    SELECT  'Y'
    FROM ap_inv_selection_criteria_all AISC,
         iby_pay_service_requests  IPSR ,
         ap_selected_invoices_all ASI
    WHERE  IPSR.call_app_pay_service_req_code (+) = AISC.checkrun_name
    AND    trunc(aisc.check_date) between g_period_start_date and g_period_end_date
    AND DECODE(IPSR.payment_service_request_id, NULL,
              AISC.status,
              AP_PAYMENT_UTIL_PKG.get_psr_status(IPSR.payment_service_request_id,
                                                 IPSR.payment_service_request_status) )
               NOT IN ('CONFIRMED','CANCELED','QUICKCHECK', 'CANCELLED NO PAYMENTS', 'TERMINATED')
    AND aisc.checkrun_id = asi.checkrun_id
    AND asi.org_id in (select org_id org_id from ap_org_attributes_gt org_gtt)
    AND rownum = 1;

     -- check if any unmatured future payments exists
     cursor c_unmat_fut_pmts_exists
     is
      select    'Y'
      from	ap_checks_all c
      where	c.future_pay_due_date is not null
      and	c.status_lookup_code = 'ISSUED'
      and	c.future_pay_due_date between g_period_start_date
                                     and      g_period_end_date
      and       c.org_id in (select org_id org_id from ap_org_attributes_gt org_gtt)
      and       rownum = 1;

     lv_exists varchar2 (1);

     procedure set_expected_error (p_msg  varchar2)
     is
     begin
       p_validation_flag := 'EE';
       p_validation_message := 'AP_SET_CANNOT_CLOSED_PERIOD';
       print(p_msg);
     end set_expected_error;


  begin

    -- check if unconfirmed payment batch exists
    lv_exists := 'N';
    open  c_uncnf_pmt_batch_exists;
    fetch c_uncnf_pmt_batch_exists into lv_exists;
    close c_uncnf_pmt_batch_exists;

    debug ('cursor c_uncnf_pmt_batch_exists: lv_exists='||lv_exists);

    if lv_exists = 'Y' then
      set_expected_error ('AP_UNCNF_PMT_BATCH_EXISTS ' || '- Unconfirmed Payment Batches');
      return;
    end if;

    -- check if unmatured future payment exists
    lv_exists := 'N';
    open  c_unmat_fut_pmts_exists;
    fetch c_unmat_fut_pmts_exists into lv_exists;
    close c_unmat_fut_pmts_exists;

    debug ('cursor c_unmat_fut_pmts_exists: lv_exists='||lv_exists);

    if lv_exists = 'Y' then
      set_expected_error ('AP_UNMAT_FUT_PMTS_EXISTS ' || '- Unmatured Future Payments');
      return;
    end if;

    -- check transfer to GL
    -- Bug#7649020: Commented call to xla package to make codepath
    -- for period close and PCER as close as possible
    /*xla_events_pub_pkg.period_close(P_API_VERSION    => 1
                                  , X_RETURN_STATUS  => p_validation_flag
                                  , P_APPLICATION_ID => G_AP_APPLICATION_ID
                                  , P_LEDGER_ID      => g_ledger_id
                                  , P_PERIOD_NAME    => g_period_name);

    debug ('xla_events_pub_pkg.period_close: p_validation_flag='||p_validation_flag);

    if (p_validation_flag <> 'S') then
      set_expected_error ('AP_UNTRNF_EVENTS_IN_XLA ' ||' - Untransferred XLA events');
      return;
    end if;*/

    -- check if unposted invoices or unposted payment exists
    lv_exists := 'N';
    lv_exists := get_unposted_transactions ;

    debug ('get_unposted_transactions: return value: lv_exists='||lv_exists);

    if lv_exists = 'Y' then
      set_expected_error ('AP_UNACCT_TRXS_EXISTS '|| '- Unaccounted Invoices and/or payments');
      return;
    end if;

    if p_validation_flag <> 'EE' then
      p_validation_flag := 'SS';
      p_validation_message := '';
    end if;

  end validate_period_close;

  /*------------------------------------------------------------------------------------------------------------------------*/
  procedure validate_parameters
                    ( p_validation_flag     out  nocopy  varchar2
                    ,p_validation_message  out  nocopy  varchar2
                    )
  is

    cursor c_get_ledger_from_org
    is
      select set_of_books_id ledger_id
      from   ap_system_parameters_all
      where org_id = g_org_id;

      lv_closing_status     gl_period_statuses.closing_status%type;
      ld_period_start_date  gl_period_statuses.start_date%type;
      ld_period_end_date    gl_period_statuses.end_date%type;
      ld_sweep_to_end_date  gl_period_statuses.end_date%type;

      l_min_date            gl_period_statuses.start_date%type;
      l_max_date            gl_period_statuses.end_date%type;

  begin

    if g_ledger_id is null
    and g_org_id is null then
      p_validation_flag := 'EE';
      p_validation_message := 'AP_LEDGER_OR_OU_REQ';
      return;
   -- elsif g_ledger_id is null then
   /*
     * veramach bug 7412634. g_ledger_id is passed as -9999 when reporting context is set to a OU. But,
     * earlier the condition was being checked as g_ledger_id is null. So, when running for an OU,
     g_ledger_id was never getting set. So, c_get_all_orgs cursor was failing in populate_orgs method.
     */
    elsif NVL(g_ledger_id,-9999) = -9999 THEN

      --
      --  we will derive ledger_id based on the the org_id
      --
      open c_get_ledger_from_org;
      fetch c_get_ledger_from_org into g_ledger_id;
      close c_get_ledger_from_org;

      debug ('cursor c_get_ledger_from_org: g_ledger_id='||g_ledger_id);

    end if;

    --
    -- Get ledger attributes
    --

    open  c_ledger_attribs;
    fetch c_ledger_attribs into g_ledger_name, g_cash_basis_flag;
    close c_ledger_attribs;

    debug ('cursor c_ledger_attribs: g_ledger_name='||g_ledger_name||'; g_cash_basis_flag='||g_cash_basis_flag);

    if g_period_name is null
    and (g_period_start_date is null or g_period_end_date is null)
    then
      --7649020: If action is UTR, dates should default if no dates are given.
      if g_action = G_ACTION_UTR  then

       SELECT min(start_date), max(end_date)
	 INTO l_min_date,l_max_date
	 FROM gl_period_statuses
        WHERE application_id = G_AP_APPLICATION_ID
          AND set_of_books_id = g_ledger_id
          AND closing_status in ('C','O','F');

	  if g_period_start_date is null then
	     g_period_start_date := l_min_date;
	  end if;

	  if g_period_end_date is null then
	     g_period_end_date := l_max_date;
	  end if;
      else
        p_validation_flag := 'EE';
        p_validation_message := 'AP_PERIOD_OR_DATE_REQ';
        return;
      end if;
    end if;

    if g_period_name is not null then
      open  c_get_period_dates;
      fetch c_get_period_dates into ld_period_start_date
                                  , ld_period_end_date
                                  , lv_closing_status;
      close c_get_period_dates;

    debug ('cursor c_get_period_dates: ld_period_start_date='||ld_period_start_date
                                  ||'; ld_period_end_date='||ld_period_end_date
                                  ||'; lv_closing_status='||lv_closing_status
                                  );

      g_period_start_date := ld_period_start_date;
      g_period_end_date := ld_period_end_date;
    end if;

    if lv_closing_status <> 'O' then
      p_validation_flag := 'EE';
      p_validation_message := 'AP_ALL_NOT_OPEN_PERIOD';
      return;
    end if;


    if (g_action in (G_ACTION_SWEEP, G_ACTION_PERIOD_CLOSE)
      and (g_ledger_id is null or g_period_name is null )
      ) then

      --  We cannot perform PERIOD_CLOSE/SWEEP without a valid ledger and period name
       p_validation_flag := 'EE';
       p_validation_message := 'AP_LEDGER_PERIOD_REQ';
       return;
    end if;

    if (g_action = G_ACTION_SWEEP) then

      -- Validation:  To SWEEP, paramter sweep_to_period must be given

      if g_sweep_to_period is null then
        p_validation_flag := 'EE';
        p_validation_message := 'AP_SWEEP_TO_PERIOD_REQ';
        return;
      end if;


      lv_closing_status :=null;

      open c_get_period_dates (cp_period_name => g_sweep_to_period
                              ,cp_include_adj_period => 'N'
                              );
      fetch c_get_period_dates into g_sweep_to_date
                                   ,ld_sweep_to_end_date
                                   ,lv_closing_status;
      close c_get_period_dates;

      debug ('cursor c_get_period_dates (cp_period_name=>'||g_sweep_to_period||',cp_include_adj_period=N');
      debug ('cursor c_get_period_dates: g_sweep_to_date='||g_sweep_to_date
                                      ||'; ld_sweep_to_end_date='||ld_sweep_to_end_date
                                      ||'; lv_closing_status='||lv_closing_status
            );

      --
      --  Check that sweep to date is valid
      --  Sweep to date is invalid if
      --  1. It is NULL
      --  2. It is prior to the start date of the current period (the period being closed/swept)
      --  3. If it is in closed period
      --

      if   g_sweep_to_date is null
        or g_sweep_to_date <= g_period_end_date
        or lv_closing_status not in ('O','F')
      then

        p_validation_flag := 'EE';
        p_validation_message := 'AP_INVALID_SWEEP_PERIOD';
      end if;

    end if;

    if p_validation_flag <> 'EE' then
      p_validation_flag := 'SS';
      p_validation_message := '';
    end if;

  end validate_parameters;


  /*------------------------------------------------------------------------------------------------------------------------*/
  --Bug#7649020: removed the call to validate_action
  --and this code handled in process_period
  /*procedure validate_action
                    (p_action              in           varchar2
                    ,p_validation_flag     out  nocopy  varchar2
                    ,p_validation_message  out  nocopy  varchar2
                    )
  is
l_msg_count 	NUMBER;
  begin

    if p_action = G_ACTION_PERIOD_CLOSE then

      validate_period_close
                     (p_validation_flag     => p_validation_flag
                     ,p_validation_message  => p_validation_message
                     );

    end if;

    if p_action  = G_ACTION_SWEEP then

	  PSA_AP_BC_PVT.delete_events(
    		p_init_msg_list => 'F',
	    	p_ledger_id => g_ledger_id,
    		p_start_date => g_period_start_date,
    		p_end_date => g_period_end_date,
    		p_calling_sequence => 'ap_period_close_pkg.validate_action',
    		x_return_status => p_validation_flag,
    		x_msg_count =>l_msg_count,
    		x_msg_data => p_validation_message
 	  );

	  if p_validation_flag <> 'S' then
		p_validation_flag := 'EE';
		print ('l_msg_count = ' || l_msg_count || ' error msg - ' || p_validation_message);
	  else
		p_validation_flag := 'SS';
		p_validation_message := '';
	  end if;

    end if;

  exception
    when others then
      p_validation_flag := 'UE';
      p_validation_message := 'ERROR: validate_action :'|| sqlerrm;
      debug ('EXCEPTION: validate_action: '||sqlerrm);
  end validate_action;*/

/*============================================================================
 |  FUNCTION  -  GET_EVENT_SECURITY_CONTEXT(PRIVATE)
 |
 |  DESCRIPTION
 |    This function is used to get the event security context.
 |
 |  PRAMETERS:
 |         p_org_id: Organization ID
 |         p_calling_sequence: Debug information
 |
 |  RETURN: XLA_EVENTS_PUB_PKG.T_SECURITY
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  14-MAR-08    PRANPAUL           New
 *===========================================================================*/
FUNCTION get_event_security_context(
               p_org_id           IN NUMBER,
               p_calling_sequence IN VARCHAR2)
RETURN XLA_EVENTS_PUB_PKG.T_SECURITY
IS

  l_event_security_context XLA_EVENTS_PUB_PKG.T_SECURITY;

BEGIN

  l_event_security_context.security_id_int_1 := p_org_id;

  RETURN l_event_security_context;

END get_event_security_context;


/*============================================================================
 |  FUNCTION  -  GET_EVENT_SOURCE_INFO(PRIVATE)
 |
 |  DESCRIPTION
 |    This function is used to get invoice/payment event source information
 |
 |  PRAMETERS:
 |         p_legal_entity_id: Legal entity ID
 |         p_ledger_id: Ledger ID
 |         p_trans_id: Invoice ID / Check ID
 |         p_calling_sequence: Debug information
 |
 |  RETURN: XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  14-MAR-08    PRANPAUL           New
 *===========================================================================*/
FUNCTION get_event_source_info(
                p_legal_entity_id  IN   NUMBER,
                p_ledger_id        IN   NUMBER,
                p_trans_id         IN   NUMBER,
                p_event_id         IN   NUMBER,
		p_inv_payment_id   IN   NUMBER,       -- 7318763
  		p_trans_num        IN   VARCHAR2,
		p_context          IN   VARCHAR2,
		p_calling_sequence IN   VARCHAR2)
RETURN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO
IS
  /* Modified the procedure for bug 7137359, related to AWT event creation */
  l_invoice_num VARCHAR2(50);
  l_event_source_info XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
  l_count       NUMBER(15);
  l_check_id    AP_CHECKS_ALL.Check_Id%TYPE;
  l_check_number AP_CHECKS_ALL.Check_Number%TYPE;

BEGIN

  l_event_source_info.application_id := G_AP_APPLICATION_ID;
  l_event_source_info.legal_entity_id := p_legal_entity_id;
  l_event_source_info.ledger_id := p_ledger_id;

  if p_context = 'INV' then
 /*    select count(*)   --commented this peice of code 7318763
     into l_count
     from ap_invoice_distributions_all
     where accounting_event_id = p_event_id
     and invoice_id = p_trans_id
     and awt_invoice_payment_id is not null;  */

     if (nvl(p_inv_payment_id ,-1) > 0)  then -- 7318763
       BEGIN
         select ac.check_id, ac.check_number
         into l_check_id, l_check_number
       	 from ap_invoice_payments_all aip,
              ap_checks_all ac
         where aip.check_id=ac.check_id
         and   aip.accounting_event_id = p_event_id
         and   aip.invoice_id= p_trans_id;

         l_event_source_info.entity_type_code := 'AP_PAYMENTS';
         l_event_source_info.transaction_number := l_check_number;
         l_event_source_info.source_id_int_1 := l_check_id;

       EXCEPTION
         WHEN OTHERS THEN
               NULL;
       END;
     else
       l_event_source_info.entity_type_code := 'AP_INVOICES';
       l_event_source_info.transaction_number := p_trans_num;
       l_event_source_info.source_id_int_1 := p_trans_id;
     end if;

  else
    l_event_source_info.entity_type_code := 'AP_PAYMENTS';
    l_event_source_info.transaction_number := p_trans_num;
    l_event_source_info.source_id_int_1 := p_trans_id;

  end if;


  RETURN l_event_source_info;

END;




  /*============================================================================
 |  FUNCTION  -  UPDATE_PO_CLOSE_DATE
 |
 |  DESCRIPTION
 |      This function is used to sweep closed date of PO Shipment and Headers
 |      to an open date in next accounting period for unaccounted invoice
 |      distributions matched to these shipments.
 |
 |
 |  PRAMETERS
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  14-MAR-08    PRANPAUL           New
 *===========================================================================*/
FUNCTION update_po_close_date RETURN BOOLEAN IS

BEGIN

	UPDATE po_headers_all POH
	SET POH.closed_date = g_sweep_to_date
	WHERE po_header_id in (SELECT PLL.PO_HEADER_ID
				   FROM   PO_LINE_LOCATIONS_ALL PLL,
				   PO_DISTRIBUTIONS_ALL PD,
				   AP_PERIOD_CLOSE_EXCPS_GT GT
				   WHERE PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
				   AND PD.PO_DISTRIBUTION_ID = GT.PO_DISTRIBUTION_ID
				   AND GT.SOURCE_TYPE = G_SRC_TYP_UNACCT_DISTS
				   AND GT.SOURCE_TABLE_NAME in ( G_SRC_TAB_AP_INV_DISTS_ALL,
								 G_SRC_TAB_AP_SELF_TAX_DIST_ALL)
				   AND ( PLL.CLOSED_DATE IS NOT NULL
				         AND PLL.CLOSED_DATE < g_sweep_to_date )
				   GROUP BY PLL.PO_HEADER_ID, GT.PO_DISTRIBUTION_ID
				   HAVING SUM(GT.AMOUNT) > 0)
	AND ( POH.CLOSED_DATE IS NOT NULL
	      AND POH.CLOSED_DATE < g_sweep_to_date );

  debug ('update_po_close_date: total records updated in po_headers_all:'||sql%rowcount);


	UPDATE po_line_locations_all
	SET closed_date = g_sweep_to_date
	WHERE line_location_id in (SELECT PLL.LINE_LOCATION_ID
				   FROM   PO_LINE_LOCATIONS_ALL PLL,
				   PO_DISTRIBUTIONS_ALL PD,
				   AP_PERIOD_CLOSE_EXCPS_GT GT
				   WHERE PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
				   AND PD.PO_DISTRIBUTION_ID = GT.PO_DISTRIBUTION_ID
				   AND GT.SOURCE_TYPE = G_SRC_TYP_UNACCT_DISTS
				   AND GT.SOURCE_TABLE_NAME in ( G_SRC_TAB_AP_INV_DISTS_ALL,
								 G_SRC_TAB_AP_SELF_TAX_DIST_ALL)
				   AND ( PLL.CLOSED_DATE IS NOT NULL
				         AND PLL.CLOSED_DATE < g_sweep_to_date )
				   GROUP BY PLL.LINE_LOCATION_ID, GT.PO_DISTRIBUTION_ID
				   HAVING SUM(GT.AMOUNT) > 0);

  debug ('update_po_close_date: total records updated in po_line_locations_all:'||sql%rowcount);

 return TRUE;

exception
  WHEN OTHERS THEN
    debug ('EXCEPTION: update_po_close_date: '||sqlerrm);
    return FALSE;

END;


  /*============================================================================
 |  FUNCTION  -  UPDATE_EBTAX_DISTS
 |
 |  DESCRIPTION
 |      This function is used to sweep all eBtax distributions to
 |      to an open date in next accounting period for unaccounted tax
 |      distributions generated by eBtax.
 |
 |
 |  PRAMETERS
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  14-MAR-08    PRANPAUL           New
 *===========================================================================*/
FUNCTION update_ebtax_dists RETURN BOOLEAN IS

l_return_status		varchar2(20);
l_msg_count		number;
l_msg_data		varchar2(2000);
BEGIN

        INSERT into ZX_TAX_DIST_ID_GT
		(SELECT detail_tax_dist_id
		FROM ap_period_close_excps_gt
		WHERE detail_tax_dist_id is not null
		AND source_type = G_SRC_TYP_UNACCT_DISTS
		AND source_table_name in ( G_SRC_TAB_AP_INV_DISTS_ALL,
					   G_SRC_TAB_AP_SELF_TAX_DIST_ALL));

    debug ('update_ebtax_dists: total records inserted in ZX_TAX_DIST_ID_GT: '||sql%rowcount);

      if sql%rowcount > 0 then

	ZX_API_PUB.Update_Tax_dist_gl_date (
				1.0,
				FND_API.G_TRUE,
				FND_API.G_FALSE,
				FND_API.G_VALID_LEVEL_FULL,
				l_return_status,
				l_msg_count,
				l_msg_data,
				g_sweep_to_date );

  debug ('update_ebtax_dists: l_return_status='||l_return_status||';l_msg_data='||l_msg_data||';l_msg_count='||l_msg_count );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
	print (l_msg_data);
	return FALSE;
      end if;
    end if;
      return TRUE;

exception
  WHEN OTHERS THEN
    debug ('EXCEPTION: update_ebtax_dists: '||sqlerrm);
    return FALSE;
END;


/*============================================================================
 |  PROCEDURE  -  UPDATE_XLA_EVENTS
 |
 |  DESCRIPTION
 |      This procedure is used to sweep accounting events from one accounting period
 |      to another.
 |
 |
 |  PRAMETERS
 |
 |         p_sweep_to_date: The new event date
 |         p_calling_sequence: Debug information
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  14-MAR-08    PRANPAUL           New
 *===========================================================================*/

PROCEDURE update_xla_events (
               p_calling_sequence IN    VARCHAR2,
	       p_success          OUT   NOCOPY BOOLEAN)
IS

  TYPE t_event_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  TYPE t_trans_ids IS TABLE OF NUMBER(15) INDEX BY PLS_INTEGER;
  TYPE t_inv_payment_ids IS TABLE OF NUMBER(15) INDEX BY PLS_INTEGER; -- 7318763
  TYPE t_trans_nums IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
  TYPE t_source IS TABLE OF VARCHAR2(30) INDEX BY PLS_INTEGER;
  TYPE t_org_ids IS TABLE OF NUMBER(15) INDEX BY PLS_INTEGER;
  TYPE t_legal_entity_ids IS TABLE OF NUMBER(15) INDEX BY PLS_INTEGER;
  TYPE t_ledger_ids IS TABLE OF NUMBER(15) INDEX BY PLS_INTEGER;


  l_event_ids t_event_ids;
  l_inv_payment_ids t_inv_payment_ids; -- 7318763
  l_trans_ids t_trans_ids;
  l_trans_nums t_trans_nums;
  l_org_ids t_org_ids;
  l_legal_entity_ids t_legal_entity_ids;
  --l_ledger_ids t_ledger_ids;
  l_sources t_source;
  l_event_security_context XLA_EVENTS_PUB_PKG.T_SECURITY;
  l_event_source_info XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
  l_curr_calling_sequence VARCHAR2(200);

  -- Bug 7137359
  l_xla_event        XLA_EVENTS.EVENT_ID%TYPE;
  l_xla_event_status XLA_EVENTS.EVENT_STATUS_CODE%TYPE;
  l_call_xla_api     VARCHAR2(1);

  --Bug#8240910 Reverted back changes done on cursor to handle other exceptions
  -- reported by SLA as they are not swept now.
CURSOR c_events IS
    SELECT gt.accounting_event_id accounting_event_id,
           decode (gt.source_table_name
                  ,G_SRC_TAB_AP_INV_DISTS_ALL, gt.invoice_id
		  ,G_SRC_TAB_AP_PREPAY_HIST, gt.invoice_id
		  ,G_SRC_TAB_AP_SELF_TAX_DIST_ALL, gt.invoice_id
                  ,G_SRC_TAB_AP_PMT_HISTORY, gt.check_id
                  ) trans_id,
           gt.org_id org_id,
           gt.legal_entity_id legal_entity_id,
	         decode (gt.source_table_name
                  ,G_SRC_TAB_AP_INV_DISTS_ALL,  gt.invoice_num
                  ,G_SRC_TAB_AP_PREPAY_HIST, gt.invoice_num
		  ,G_SRC_TAB_AP_SELF_TAX_DIST_ALL, gt.invoice_num
                  ,G_SRC_TAB_AP_PMT_HISTORY, gt.check_number
                  )trans_num,
	         decode(gt.source_table_name
                 ,G_SRC_TAB_AP_INV_DISTS_ALL, 'INV'
		 ,G_SRC_TAB_AP_PREPAY_HIST, 'INV'
		 ,G_SRC_TAB_AP_SELF_TAX_DIST_ALL, 'INV'
                 ,G_SRC_TAB_AP_PMT_HISTORY,'PMT'
                 ) source
		 ,invoice_payment_id  -- 7318763
    FROM ap_period_close_excps_gt gt
    WHERE gt.source_type in (G_SRC_TYP_UNACCT_DISTS, G_SRC_TYP_UNACCT_PMT_HISTORY,
                             G_SRC_TYP_UNACCT_PREPAY_HIST)
    AND	  gt.source_table_name in (G_SRC_TAB_AP_INV_DISTS_ALL, G_SRC_TAB_AP_PMT_HISTORY,
				   G_SRC_TAB_AP_SELF_TAX_DIST_ALL, G_SRC_TAB_AP_PREPAY_HIST)
    AND gt.accounting_event_id is NOT NULL;

  begin

  l_curr_calling_sequence := p_calling_sequence;
  debug ('begin update_xla_events: Bulk fetch cursor c_events');

  OPEN c_events;
   LOOP
	FETCH c_events
	BULK COLLECT INTO
         l_event_ids,
         l_trans_ids,
         l_org_ids,
         l_legal_entity_ids,
	 l_trans_nums,
	 l_sources,
	 l_inv_payment_ids     -- 7318763
         LIMIT g_fetch_limit;

    debug ('update_xla_events: l_event_ids.count='||l_event_ids.count );

    EXIT WHEN
    l_event_ids.count = 0;

    FOR i IN 1 .. l_event_ids.count LOOP

      /** Bug 7137359 */
      BEGIN

        SELECT event_id, event_status_code
        INTO l_xla_event, l_xla_event_status
        FROM xla_events
        WHERE event_id = l_event_ids(i)
        AND application_id = 200;

        IF l_xla_event_status = 'P' THEN
          l_call_xla_api := 'N';
        ELSE
          l_call_xla_api := 'Y';
        END IF;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_call_xla_api := 'N';

      END;

      IF l_call_xla_api = 'Y'  THEN

        l_event_security_context :=
        get_event_security_context
        ( p_org_id => l_org_ids(i),
          p_calling_sequence => l_curr_calling_sequence
        );


        l_event_source_info :=
        get_event_source_info
        ( p_legal_entity_id => l_legal_entity_ids(i),
          p_ledger_id => g_ledger_id, 	-- l_ledger_ids(i),
          p_trans_id => l_trans_ids(i),
          p_event_id => l_event_ids(i),
	  p_trans_num => l_trans_nums(i),
	  p_inv_payment_id => l_inv_payment_ids(i),  -- 7318763
	  p_context => l_sources(i),
          p_calling_sequence => l_curr_calling_sequence
        );

        AP_XLA_EVENTS_PKG.UPDATE_EVENT
        ( p_event_source_info => l_event_source_info,
          p_event_id => l_event_ids(i),
          p_event_type_code => NULL,
          p_event_date => g_sweep_to_date,
          p_event_status_code => NULL,
          p_valuation_method => NULL,
          p_security_context => l_event_security_context,
          p_calling_sequence => l_curr_calling_sequence
        );

      END IF;

    END LOOP;

    forall i in l_event_ids.first..l_event_ids.last
      UPDATE xla_ae_headers aeh
         SET aeh.accounting_date = g_sweep_to_date,
             aeh.period_name = g_sweep_to_period,
             last_update_date = SYSDATE,
             last_updated_by =  FND_GLOBAL.user_id
       WHERE aeh.event_id = l_event_ids(i)
         AND application_id = 200
         AND gl_transfer_status_code <> 'Y'
      AND accounting_entry_status_code <> 'F';

    forall i in l_event_ids.first..l_event_ids.last
    UPDATE xla_ae_lines ael
       SET ael.accounting_date = g_sweep_to_date,
           last_update_date = sysdate,
           last_updated_by =  FND_GLOBAL.user_id
     WHERE ael.ae_header_id in (
          SELECT aeh.ae_header_id
            FROM xla_ae_headers aeh
           WHERE aeh.event_id = l_event_ids(i)
             AND aeh.application_id = 200
             AND aeh.gl_transfer_status_code <> 'Y'
    AND aeh.accounting_entry_status_code <> 'F');

   END LOOP;
  CLOSE c_events;

  debug ('end update_xla_events');

 p_success := TRUE;

EXCEPTION
  WHEN OTHERS THEN

       IF (c_events%ISOPEN) THEN
         CLOSE c_events;
       END IF;
    debug ('EXCEPTION: update_xla_events: '|| sqlerrm);
    p_success := FALSE;

END update_xla_events;

  /*============================================================================
 |  FUNCTION  -  UPDATE_AP_ACCT_DATE
 |
 |  DESCRIPTION
 |      This function is used to sweep invoice distributions, lines and
 |      payment, payment history records to an open date in next accounting
 |      period that are unaccounted in the current period.
 |
 |
 |  PRAMETERS
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  14-MAR-08    PRANPAUL           New
 *===========================================================================*/
FUNCTION update_ap_acct_date RETURN BOOLEAN IS


  type typ_number_tab is table of number (15) index by binary_integer;

  ltab_id         typ_number_tab;
  ltab_line_num   typ_number_tab;
  Itab_event_id   typ_number_tab; --Bug 9045217

  l_dbi_key_value_list        ap_dbi_pkg.r_dbi_key_value_arr;

BEGIN
       --Bug#8240910 Reverted changes done on UPDATES to handle other exceptions reported
       -- by SLA as they are not swept now.
	UPDATE ap_invoice_distributions_all aid
	SET accounting_date = g_sweep_to_date,
	    period_name = g_sweep_to_period,
	    last_update_date = sysdate,
	    last_updated_by = 5
	WHERE aid.invoice_distribution_id in (SELECT gt.invoice_distribution_id
					      FROM ap_period_close_excps_gt gt
					      WHERE gt.source_type = G_SRC_TYP_UNACCT_DISTS
					      AND   gt.source_table_name = G_SRC_TAB_AP_INV_DISTS_ALL)
        AND aid.posted_flag in ('N','S','P') --Bug 9045217
   returning invoice_distribution_id bulk collect into l_dbi_key_value_list;

   debug ('update_ap_acct_date: total records updated in ap_invoice_distributions_all: '||sql%rowcount);

   forall i in l_dbi_key_value_list.first .. l_dbi_key_value_list.last
     update /*+index (gt AP_PERIOD_CLOSE_EXCPS_GT_N3)*/ ap_period_close_excps_gt gt --Bug 9045217
     set    process_status_flag = 'Y'
     where  invoice_distribution_id = l_dbi_key_value_list(i)
     AND  gt.source_type = G_SRC_TYP_UNACCT_DISTS
     AND  gt.source_table_name = G_SRC_TAB_AP_INV_DISTS_ALL;      -- 7318763

   AP_DBI_PKG.Maintain_DBI_Summary
                (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
                 p_operation => 'U',
                 p_key_value_list => l_dbi_key_value_list,
                 p_calling_sequence => 'AP_PERIOD_CLOSE_PKG.update_ap_acct_date');

   debug ('update_ap_acct_date: total distributions processed in ap_period_close_excps_gt: '||l_dbi_key_value_list.count);

  forall i in l_dbi_key_value_list.first .. l_dbi_key_value_list.last
	UPDATE ap_invoice_lines_all ail
	SET accounting_date = g_sweep_to_date,
	    period_name = g_sweep_to_period,
	    last_update_date = sysdate,
	    last_updated_by = 5
	WHERE (ail.invoice_id, ail.line_number)
          in (SELECT /*+index (gt AP_PERIOD_CLOSE_EXCPS_GT_N3)*/  gt.invoice_id, gt.invoice_line_number --Bug 9045217
                FROM ap_period_close_excps_gt gt
               WHERE gt.invoice_distribution_id = l_dbi_key_value_list(i)
                 AND gt.source_type = G_SRC_TYP_UNACCT_DISTS
                 AND gt.source_table_name = G_SRC_TAB_AP_INV_DISTS_ALL);     -- 7318763

    debug ('update_ap_acct_date: total lines processed in ap_invoice_lines_all: '||l_dbi_key_value_list.count);

  l_dbi_key_value_list.delete;


	UPDATE ap_self_assessed_tax_dist_all astd
	SET accounting_date = g_sweep_to_date,
	    period_name = g_sweep_to_period,
	    last_update_date = sysdate,
	    last_updated_by = 5
	WHERE astd.invoice_distribution_id
           in (SELECT gt.invoice_distribution_id
                 FROM ap_period_close_excps_gt gt
                WHERE gt.source_type = G_SRC_TYP_UNACCT_DISTS
                  AND   gt.source_table_name = G_SRC_TAB_AP_SELF_TAX_DIST_ALL)
        AND astd.posted_flag <> 'Y'
   returning invoice_distribution_id bulk collect into ltab_id;

   debug ('update_ap_acct_date: total records updated in ap_self_assessed_tax_dist_all: '||sql%rowcount);

   forall i in ltab_id.first .. ltab_id.last
     update /*+index (gt AP_PERIOD_CLOSE_EXCPS_GT_N3)*/ ap_period_close_excps_gt  gt --Bug 9045217
     set    process_status_flag = 'Y'
     where  invoice_distribution_id = ltab_id(i)
     AND  gt.source_type = G_SRC_TYP_UNACCT_DISTS
     AND  gt.source_table_name = G_SRC_TAB_AP_SELF_TAX_DIST_ALL;   -- 7318763

   debug ('update_ap_acct_date: total self assessed tax distributions processed in ap_period_close_excps_gt: '||ltab_id.count);

  ltab_id.delete;


	UPDATE ap_invoice_lines_all ail
	SET accounting_date = g_sweep_to_date,
	    period_name = g_sweep_to_period,
	    last_update_date = sysdate,
	    last_updated_by = 5
	WHERE (ail.invoice_id,ail.line_number) in
                  (SELECT gt.invoice_id, gt.invoice_line_number
                   FROM ap_period_close_excps_gt gt
                   WHERE gt.source_type = G_SRC_TYP_LINES_WITHOUT_DISTS
                   AND   gt.source_table_name = G_SRC_TAB_AP_INV_LINES_ALL)
  returning ail.invoice_id, ail.line_number bulk collect into ltab_id, ltab_line_num;
  debug ('update_ap_acct_date: total records updated in ap_invoice_lines_all: '||sql%rowcount);

  forall i in ltab_id.first..ltab_id.last
    update /*+index (gt AP_PERIOD_CLOSE_EXCPS_GT_N4)*/ap_period_close_excps_gt gt --Bug 9045217
    set    process_status_flag = 'Y'
    where  invoice_id = ltab_id(i)
    and    invoice_line_number = ltab_line_num(i)
    AND  gt.source_type =G_SRC_TYP_LINES_WITHOUT_DISTS
    AND  gt.source_table_name = G_SRC_TAB_AP_INV_LINES_ALL;     -- 7318763

  debug ('update_ap_acct_date: total invoice lines processed in ap_period_close_excps_gt: '||ltab_id.count );

  ltab_id.delete;

	UPDATE ap_invoice_payments_all aip
	SET accounting_date = g_sweep_to_date,
	    period_name = g_sweep_to_period,
	    last_update_date = sysdate,
	    last_updated_by = 5
	WHERE aip.invoice_payment_id in (SELECT gt.invoice_payment_id
					 FROM ap_period_close_excps_gt gt
					 WHERE gt.source_type = G_SRC_TYP_UNACCT_INV_PMTS
					 AND   gt.source_table_name = G_SRC_TAB_AP_INV_PAYMENTS)
        AND aip.posted_flag <> 'Y'
  returning invoice_payment_id, accounting_event_id bulk collect into ltab_id,Itab_event_id; --Bug 9045217

  debug ('update_ap_acct_date: total records updated in ap_invoice_payments_all: '||sql%rowcount);

  forall i in ltab_id.first .. ltab_id.last
     update ap_period_close_excps_gt gt
     set    process_status_flag = 'Y'
     where  invoice_payment_id = ltab_id(i)
     AND  gt.accounting_event_id = Itab_event_id(i) --Bug 9045217
     AND  gt.source_type = G_SRC_TYP_UNACCT_INV_PMTS
     AND  gt.source_table_name = G_SRC_TAB_AP_INV_PAYMENTS;     -- 7318763

  debug ('update_ap_acct_date: total invoice payments processed in ap_period_close_excps_gt: '||ltab_id.count );

  ltab_id.delete;
  Itab_event_id.delete; --Bug 9045217

	UPDATE ap_payment_history_all aph
	SET accounting_date = g_sweep_to_date,
	    last_update_date = sysdate,
	    last_updated_by = 5
	WHERE aph.payment_history_id in (SELECT gt.payment_history_id
					 FROM ap_period_close_excps_gt gt
					 WHERE gt.source_type = G_SRC_TYP_UNACCT_PMT_HISTORY
					 AND   gt.source_table_name = G_SRC_TAB_AP_PMT_HISTORY)
        AND aph.posted_flag <> 'Y'
  returning aph.payment_history_id,aph.accounting_event_id bulk collect into ltab_id,Itab_event_id; --Bug 9045217

  debug ('update_ap_acct_date: total records updated in ap_payment_history_all: '||sql%rowcount);

  forall i in ltab_id.first .. ltab_id.last
     update ap_period_close_excps_gt gt
     set    process_status_flag = 'Y'
     where  payment_history_id = ltab_id(i)
     AND  gt.accounting_event_id = Itab_event_id(i) --Bug 9045217
     AND  gt.source_type = G_SRC_TYP_UNACCT_PMT_HISTORY
     AND  gt.source_table_name = G_SRC_TAB_AP_PMT_HISTORY;        -- 7318763
  debug ('update_ap_acct_date: total payment history processed in ap_period_close_excps_gt: '||ltab_id.count );

  ltab_id.delete;
  Itab_event_id.delete; --Bug 9045217

  -- gagrawal

        UPDATE ap_prepay_history_all apph
	SET accounting_date = g_sweep_to_date,
	    last_update_date = sysdate,
	    last_updated_by = 5
	WHERE apph.accounting_event_id in (SELECT gt.accounting_event_id
	                                   FROM ap_period_close_excps_gt gt
					   WHERE gt.source_type = G_SRC_TYP_UNACCT_PREPAY_HIST
					   AND gt.source_table_name = G_SRC_TAB_AP_PREPAY_HIST
					   AND gt.accounting_event_id IS NOT NULL)
        AND apph.posted_flag <> 'Y'
  returning apph.accounting_event_id bulk collect into ltab_id;

  debug ('update_ap_acct_date: total records updated in ap_prepay_history_all: '||sql%rowcount);


  forall i in ltab_id.first .. ltab_id.last
     update ap_period_close_excps_gt gt
     set process_status_flag = 'Y'
     where accounting_event_id = ltab_id(i)
     AND gt.source_type = G_SRC_TYP_UNACCT_PREPAY_HIST
     AND gt.source_table_name = G_SRC_TAB_AP_PREPAY_HIST;

  debug ('update_ap_acct_date: total prepay history processed in ap_period_close_excps_gt: '||ltab_id.count );

  ltab_id.delete;

 return TRUE;

exception
  WHEN OTHERS THEN
    return FALSE;
END;


--Deletion of orphan events handled as GDF

  /*============================================================================
 |  FUNCTION  -  SWEEP_TRANSACTIONS
 |
 |  DESCRIPTION
 |      This function is used to sweep payables transations from one
 |      accounting period to another. This includes sweeping the following
 |      transactions -:
 |      1. PO Shipments
 |      2. XLA Invoice and Payment Accounting events
 |      3. Invoice Distributions
 |      4. Invoice Lines
 |      5. Invoice Payments
 |      6. Payment History
 |
 |  PARAMETERS
 |
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  14-MAR-08    PRANPAUL           New
 *===========================================================================*/
  FUNCTION sweep_transactions
  RETURN BOOLEAN
  IS

    l_success BOOLEAN;
  BEGIN

    l_success := update_po_close_date;

    if (l_success <> TRUE) then
        print ('Failure in update_po_close_date while updating PO shipments');
        return FALSE;
    end if;


    update_xla_events('AP_PERIOD_CLOSE_EXCP_PKG.DO_SWEEP',
           l_success);

    if (l_success <> TRUE) then
        print ('Failure in update_xla_events while updating XLA unaccounted events');
        return FALSE;
    end if;

    l_success := update_ebtax_dists;

    if (l_success <> TRUE) then
        print ('Failure in update_ebtax_dists while updating tax distributions in eBtax');
        return FALSE;
    end if;

    l_success := update_ap_acct_date;


    if (l_success <> TRUE) then
        print ('Failure in update_ap_acct_date while updating payables invoices and payments');
    end if;

    return l_success;

  END;



/*------------------------------------------------------------------------------------------------------------------------*/
 procedure process_period
              ( p_ledger_id         in  number    default null
               ,p_org_id            in  number    default null
               ,p_period_name       in  varchar2  default null
               ,p_period_start_date in  date      default null
               ,p_period_end_date   in  date      default null
               ,p_sweep_to_period   in  varchar2  default null
               ,p_action            in  varchar2
               ,p_debug             in  varchar2 default 'N'
               ,p_process_flag      out nocopy varchar2
               ,p_process_message   out nocopy varchar2
              )
  is

    lv_dummy varchar2(3);
    lv_closing_status     gl_period_statuses.closing_status%type;
    ld_sweep_to_end_date  gl_period_statuses.end_date%type;

    l_msg_count 	NUMBER;

  begin

    g_debug := nvl(p_debug,'N');

    debug('begin process_period.  Current time stamp is= '|| current_timestamp);
    debug('Parameters:  p_ledger_id='||p_ledger_id||'; p_org_id='||p_org_id||'; p_period_name='||p_period_name
        ||'; p_period_start_date='||p_period_start_date||'; p_period_end_date='||p_period_end_date
        ||'; p_sweep_to_period='||p_sweep_to_period||'; p_action='||p_action
        );

    g_ledger_id           := p_ledger_id;
    g_org_id              := p_org_id;
    g_period_name         := p_period_name;
    g_period_start_date   := p_period_start_date;
    g_period_end_date     := p_period_end_date;
    g_action              := p_action;
    g_sweep_to_period     := p_sweep_to_period;

    debug ('Global variables initialized');

    -- validate the input paramters and also performs the initialization
    validate_parameters
                    (p_validation_flag     => p_process_flag
                    ,p_validation_message  => p_process_message
                    );

    debug ('validate_parameters:  flag='||p_process_flag ||'; message='|| p_process_message);
    if (p_process_flag <> 'SS') then
      -- parameters are not proper hence should avoid processing further
      return;
    end if;

    -- Populate all the orgs for a ledger

    populate_orgs
          (p_ledger_id =>  g_ledger_id
          ,p_process_flag => p_process_flag
          ,p_process_message => p_process_message
          );
    debug ('populate_orgs:  flag='||p_process_flag ||'; message='|| p_process_message);
    if (p_process_flag <> 'SS') then
      -- There is problem in populating org GTT hence should avoid processing further
      return;
    end if;


      --Bug#7649020: removed the call to validate_action
      --and this code handled in process_period
      --Deletion of orphan events handled as GDF

     if p_action = G_ACTION_PERIOD_CLOSE then
        --
        -- User is trying to close the period. We are returning unconditionally because
        -- we have already validated the user action.  validate_period_close has set the flag
        -- and message beased on the validation outcome and if any error, form will take care to
        -- display the message.  For success, form can continue to close the period
        --
	      validate_period_close
                     (p_validation_flag     => p_process_flag
                     ,p_validation_message  => p_process_message
                     );
        return;

    end if;

    --
    -- We reach here only if the action is one of the following
    -- 1. SWEEP
    -- 2. Run Un-Accounted Transaction Report (UTR)
    -- 3. Run Period Close Exception Report   (PCER)
    --
    -- All of the above three action refers data populated by
    -- procedure get_unposted_transactions in global temp table AP_PERIOD_CLOSE_EXCP_GT.
    --

    lv_dummy := get_unposted_transactions;
    debug ('get_unposted_transaction: return value='||lv_dummy);

      --Bug#7649020: removed the call to validate_action
      --and this code handled in process_period
    if g_action = G_ACTION_SWEEP then

      	  PSA_AP_BC_PVT.delete_events(
    		p_init_msg_list => 'F',
	    	p_ledger_id => g_ledger_id,
    		p_start_date => g_period_start_date,
    		p_end_date => g_period_end_date,
    		p_calling_sequence => 'ap_period_close_pkg.process_period',
    		x_return_status => p_process_flag,
    		x_msg_count =>l_msg_count,
    		x_msg_data => p_process_message
 	  );

 	  if p_process_flag <> 'S' then
		p_process_flag := 'EE';
		print ('l_msg_count = ' || l_msg_count || ' error msg - ' || p_process_message);
	       -- there is either expected or un-expected error
               return; --app_exception.raise_exception ('AP',-20001,p_process_message);
         end if;

      debug ('begin sweep_transactions: current timestamp is= '||current_timestamp);

      if NOT sweep_transactions then -- perform the SWEEP logic
        p_process_flag := 'EE';
        p_process_message := 'AP_SWEEP_FAILED';
        return;
      end if;

      debug ('sweep_transactions: flag='||p_process_flag||'; message='||p_process_message);
      debug ('end sweep_transactions: current timestamp is= '||current_timestamp);

    end if;
    debug ('end process period: current timestamp is= '||current_timestamp);
    p_process_flag := 'SS';
  exception
    when others then
      p_process_flag := 'UE';
      p_process_message:='ERROR: process_period:' || sqlerrm;
      debug ('EXCEPTION: process_period: '||sqlerrm);
  end process_period;

  /*------------------------------------------------------------------------------------------------------------------------*/

  function before_report_apxpcer
  return boolean
  is
    lv_process_flag	varchar2 (2);
    lv_process_message  varchar2 (2000);
  begin

    g_period_start_date := fnd_date.canonical_to_date (g_start_date);
    g_period_end_date   := fnd_date.canonical_to_date (g_end_date);

    debug ('Begin process_period: current timestamp:'|| current_timestamp);

    process_period
               (p_ledger_id         => G_ledger_id
               ,p_period_start_date => g_period_start_date
               ,p_period_end_date   => g_period_end_date
               ,p_period_name       => g_period_name
               ,p_action            => G_ACTION_PCER
	       ,p_debug             => g_debug
               ,p_process_flag      => lv_process_flag
               ,p_process_message   => lv_process_message
               );
     debug ('End process_period: current timestamp:'||current_timestamp);

    if lv_process_flag <> 'SS' then
      print ('before_report_apxpcer: flag='|| lv_process_flag ||'; message='||lv_process_message);
	return (false);
    end if;

    return (true);

  exception
    when others then
    print ('EXCEPTION: before_report_apxpcer: '|| sqlerrm);
    return (false);
  end before_report_apxpcer;

  /*------------------------------------------------------------------------------------------------------------------------*/

   /*============================================================================
 |  PROCEDURE  -  PROCESS_APTRNSWP
 |
 |  DESCRIPTION
 |      This procedure is used as wrapper call to process_period procedure
 |      for PL/SQL stored procedure executable for Payables Transaction
 |      Sweep concurrent program.
 |
 |
 |  PARAMETERS
 |
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  14-MAR-08    PRANPAUL           New
 *===========================================================================*/

  PROCEDURE process_aptrnswp ( ErrCode OUT NOCOPY NUMBER,
                               ErrMesg OUT NOCOPY VARCHAR2,
			       P_REPORTING_LEVEL IN VARCHAR2,
			       P_REPORTING_ENTITY_ID IN VARCHAR2,
			       P_SET_OF_BOOKS_ID IN NUMBER,
			       P_FROM_ACCTG_DATE IN DATE,
			       P_TO_ACCTG_DATE IN DATE,
			       P_PERIOD_NAME IN VARCHAR2,
			       P_SWEEP_NOW IN VARCHAR2,
			       P_TO_PERIOD IN VARCHAR2,
			       P_DEBUG_SWITCH IN VARCHAR2,
			       P_TRACE_SWITCH IN VARCHAR2 )

  is
    lv_process_flag	varchar2 (2);
    lv_process_message  varchar2 (2000);
  begin
    debug ('begin process_aptrnswp: current timestamp:'||current_timestamp);
    process_period
               (p_ledger_id         =>  P_SET_OF_BOOKS_ID
               ,p_period_name       =>  P_PERIOD_NAME
               ,p_sweep_to_period   =>  P_TO_PERIOD
               ,p_action            =>  G_ACTION_SWEEP
               ,p_process_flag      =>  lv_process_flag
               ,p_process_message   =>  lv_process_message
               );
    debug ('end process_aptrnswp: current timestamp:'||current_timestamp);

  end process_aptrnswp;

  /*============================================================================
 |  FUNCTION  -  BEFORE_REPORT_APXUATR
 |
 |  DESCRIPTION
 |      This function is used as a wrapper for Unaccounted Transactions report
 |      and Payables Sweep program. This function is directky called from XML
 |      Pub report.
 |
 |  PARAMETERS
 |
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  20-MAR-08    PRANPAUL           New
 *===========================================================================*/

   function before_report_apxuatr
  return boolean
  is
    lv_process_flag	varchar2 (2);
    lv_process_message  varchar2 (2000);
    l_action		varchar2 (100);
  begin

    g_period_start_date := fnd_date.canonical_to_date (g_start_date);
    g_period_end_date   := fnd_date.canonical_to_date (g_end_date);


    debug ('begin before_report_apxuatr: current timestamp:' || current_timestamp);
    debug ('g_reporting_level='||g_reporting_level);

    if g_reporting_level = 1000 then
	    g_ledger_id := g_reporting_entity_id;
    elsif g_reporting_level = 3000 then
	    g_org_id := g_reporting_entity_id;
    end if;

    if g_sweep_now = 'Y' then
	    l_action := G_ACTION_SWEEP;
    else
	    l_action := G_ACTION_UTR;
    end if;

    process_period
               (p_ledger_id         =>  g_ledger_id
	       ,p_org_id            =>  g_org_id
               ,p_period_start_date =>  g_period_start_date
               ,p_period_end_date   =>  g_period_end_date
               ,p_period_name       =>  g_period_name
               ,p_action            =>  l_action
	       ,p_sweep_to_period   =>  g_sweep_to_period
	       ,p_debug             =>  g_debug
               ,p_process_flag      =>  lv_process_flag
               ,p_process_message   =>  lv_process_message
               );

    debug ('end before_report_apxuatr:  current timestamp: '|| current_timestamp);

    if lv_process_flag <> 'SS' then
      print ('before_report_apxuatr: flag='|| lv_process_flag ||'; message='||lv_process_message);
	    return (false);
    end if;

    return (true);

  end before_report_apxuatr;

  /*------------------------------------------------------------------------------------------------------------------------*/

  procedure check_orgs_for_ledger
              (p_ledger_id in number
              ,p_process_flag out nocopy varchar2
              ,p_process_message out nocopy varchar2
              )
  is
  begin

    --
    --  This procedure is called from forms to check if SWEEP can be performed
    --  Hence first populate the org GTT and call validate_sweep to check if sweep
    --  action is valid
    --

    populate_orgs
      (p_ledger_id       =>  p_ledger_id
      ,p_process_flag    => p_process_flag
      ,p_process_message => p_process_message
      );

    if (p_process_flag <> 'SS') then
      -- There is problem in populating org GTT hence should avoid processing further
      return;
    end if;

    validate_sweep (p_validation_flag => p_process_flag
                   ,p_validation_message => p_process_message
                   );

  end check_orgs_for_ledger;



end ap_period_close_pkg;

/
