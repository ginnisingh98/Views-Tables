--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_ALLOC_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_ALLOC_PRC_PKG" AS
/* $Header: jgzzvatallocprcb.pls 120.7.12010000.7 2010/06/09 09:53:17 spasupun ship $*/

  gv_debug_flag             BOOLEAN;  /* added for debug */

  -- Variables used by allocate_box procedure to allow multiple rules for same transaction
  gv_hierarchy_level        NUMBER(15); /* 1=tax_code; 2=tax_status; 3=tax_rate_code; 4=tax_jurisdiction_code */
  gv_tax_status             jg_zz_vat_alloc_rules.tax_status%TYPE;
  gv_tax_rate_code          jg_zz_vat_alloc_rules.tax_rate_code%TYPE;
  gv_tax_jurisdiction_code  jg_zz_vat_alloc_rules.tax_jurisdiction_code%TYPE;
  gv_allocation_rule_id     jg_zz_vat_alloc_rules.allocation_rule_id%TYPE;
  gv_appl_alloc_rule_id     jg_zz_vat_alloc_rules.allocation_rule_id%TYPE;

  /* API to flush the data */
  procedure purge_allocation_data(
    pn_reporting_status_id            number,           /* Primarykey Indicator for repEntity, tax_calerdar and source */
    pv_reallocate_flag                varchar2,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  ) IS

  begin

    if nvl(pv_reallocate_flag, 'N') = 'Y' then
      delete from jg_zz_vat_box_allocs
      where vat_transaction_id in
        ( select vat_transaction_id
          from jg_zz_vat_trx_details a
          where a.reporting_status_id = pn_reporting_status_id);

      delete from jg_zz_vat_box_errors
      where vat_transaction_id in
        ( select vat_transaction_id
          from jg_zz_vat_trx_details a
          where a.reporting_status_id = pn_reporting_status_id);

    end if;

  exception
    when others then
      xv_return_status  := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_alloc_prc_pkg.purge_allocation_data ~ Unexpected Error -' || sqlerrm;
  end purge_allocation_data;

  PROCEDURE insert_allocation_error (
    pn_vat_transaction_id      number,
    pv_allocation_error_code   varchar2,
    pv_period_type             varchar2,
    pn_created_by              number,
    pn_last_updated_by         number,
    pn_last_update_login       number,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  ) IS

  BEGIN
    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'insert_allocation_error - start');
    end if;
    /*
    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'pn_vat_transaction_id:'||pn_vat_transaction_id
        ||', pv_allocation_error_code:'||pv_allocation_error_code
        ||', pv_period_type:'||pv_period_type
        ||', pn_created_by:'||pn_created_by
        ||', pn_last_updated_by:'||pn_last_updated_by
        ||', pn_last_update_login:'||pn_last_update_login);
    end if;
    */
    INSERT INTO jg_zz_vat_box_errors(
      vat_transaction_id ,
      allocation_error_code ,
      period_type            ,
      creation_date          ,
      created_by             ,
      last_update_date       ,
      last_updated_by        ,
      last_update_login
    ) VALUES (
      pn_vat_transaction_id    ,
      pv_allocation_error_code ,
      pv_period_type           ,
      sysdate,
      pn_created_by            ,
      sysdate,
      pn_last_updated_by       ,
      pn_last_update_login
    );

  exception
    when others then
      xv_return_status  := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_alloc_prc_pkg.insert_allocation_error ~ Unexpected Error -' || sqlerrm;
  END insert_allocation_error;

  PROCEDURE update_allocation_error (
    pn_vat_transaction_id      number,
    pv_allocation_error_code   varchar2,
    pv_period_type             varchar2,
    pn_last_updated_by         number,
    pn_last_update_login       number,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  ) IS

  BEGIN
    UPDATE jg_zz_vat_box_errors
    SET allocation_error_code = pv_allocation_error_code,
        last_updated_by       = pn_last_updated_by,
        last_update_date      = sysdate,
        last_update_login     = pn_last_update_login
    WHERE Vat_transaction_id = pn_vat_transaction_id
    AND period_type = pv_period_type;

  exception
    when others then
      xv_return_status  := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_alloc_prc_pkg.update_allocation_error ~ Unexpected Error -' || sqlerrm;
  end update_allocation_error;

  PROCEDURE delete_allocation_error (
    pn_vat_transaction_id      number,
    pv_allocation_error_code   varchar2,
    pv_period_type             varchar2,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  ) IS

  BEGIN
    DELETE FROM jg_zz_vat_box_errors
    WHERE Vat_transaction_id = pn_vat_transaction_id
    AND allocation_error_code = pv_allocation_error_code
    AND period_type = pv_period_type;

  exception
    when others then
      xv_return_status  := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_alloc_prc_pkg.delete_allocation_error ~ Unexpected Error -' || sqlerrm;
  end delete_allocation_error;

  /* Main procedure that performs the allocation */
  PROCEDURE run_allocation (
    xv_errbuf              OUT nocopy varchar2,       /*Out parameter for conc. program*/
    xv_retcode             OUT nocopy varchar2,     /*Out parameter for conc. program*/
    pn_vat_reporting_entity_id number,       /*this contains TRN, tax_calerdar etc. */
    pv_tax_calendar_period     varchar2,     /* calendar period for which allocation should run*/
    pv_source                  varchar2,     /*one of AP, AR, GL, ALL */
    pv_reallocate_flag         varchar2      /*'Y'- to reallocate all the previous allocation again*/
  ) IS

    lv_extract_source_ledger varchar2(2);
    ld_today          DATE;

    /* WHO Columns */
    ld_creation_date        DATE;
    ln_created_by           NUMBER(15);
    ld_last_update_date     DATE;
    ln_last_updated_by      NUMBER(15);
    ln_last_update_login    NUMBER(15);

    /* Concurrent request identifier columns */
    ln_request_id               NUMBER(15);
    ln_program_application_id   NUMBER(15);
    ln_program_id               NUMBER(15);
    ln_program_login_id         NUMBER(15);
    ln_errors_conc_request_id   NUMBER(15);
    lb_ret_value                BOOLEAN;

    ln_allocation_process_id    NUMBER(15);
    lv_allocation_status_flag   jg_zz_vat_rep_status.allocation_status_flag%TYPE;
    lv_curr_allocation_status   jg_zz_vat_rep_status.allocation_status_flag%TYPE;

    /*indicates for how many products the allocation has to happen. will be initialized in code */
    ln_source_iterations        number(1);
    ln_period_type_iterations   number(1);
    ln_rep_status_id            jg_zz_vat_rep_status.reporting_status_id%TYPE;
    ln_rep_status_id_ap         jg_zz_vat_rep_status.reporting_status_id%TYPE;
    ln_rep_status_id_ar         jg_zz_vat_rep_status.reporting_status_id%TYPE;
    ln_rep_status_id_gl         jg_zz_vat_rep_status.reporting_status_id%TYPE;
    lv_period_type              jg_zz_vat_box_allocs.period_type%TYPE;
    lv_financial_document_type  jg_zz_vat_alloc_rules.financial_document_type%TYPE;

    lv_fresh_allocation_flag    varchar2(1);
    lv_enable_annual_alloc_flag varchar2(1);  /* variable that indicates whether annual allocation is required or not */
    lv_enable_alloc_flag        varchar2(1);  /* variable that indicates whether allocations is required or not */
    lv_allocation_errored_flag  varchar2(1);
    lv_allocation_error_code    varchar2(100);
    ln_allocation_rule_id       jg_zz_vat_box_allocs.allocation_rule_id%TYPE;
    lv_tax_box                  jg_zz_vat_box_allocs.tax_box%TYPE;
    lv_taxable_box              jg_zz_vat_box_allocs.taxable_box%TYPE;
    ln_vat_box_allocation_id    jg_zz_vat_box_allocs.vat_box_allocation_id%TYPE;
    lv_check_alloc_trans        number(15);

    lv_return_flag              jg_zz_vat_rep_status.allocation_status_flag%TYPE;
    lv_return_message           VARCHAR2(1996);
    ln_allocated_cnt            NUMBER;
    ln_del_errored_cnt          NUMBER;
    ln_upd_errored_cnt          NUMBER;
    ln_ins_errored_cnt          NUMBER;
    lv_tax_rate_code            zx_rates_b.tax_rate_code%type;
    lv_vat_trans_type           zx_rates_b.vat_transaction_type_code%type;
    lv_alloc_flag               VARCHAR2(1);

    CURSOR c_get_alloc_flags IS
      SELECT  nvl(map_jzvre.enable_allocations_flag, g_no)        enable_allocations,
              nvl(map_jzvre.enable_annual_allocation_flag, g_no)  enable_annual_allocations
      FROM jg_zz_vat_rep_entities jzvre
         , jg_zz_vat_rep_entities map_jzvre
      WHERE
      (jzvre.vat_reporting_entity_id   =  pn_vat_reporting_entity_id
       and
       jzvre.entity_type_code          = 'ACCOUNTING'
       and
       map_jzvre.vat_reporting_entity_id = jzvre.mapping_vat_rep_entity_id)
      OR
      (jzvre.vat_reporting_entity_id   =  pn_vat_reporting_entity_id
       and
       jzvre.entity_type_code          = 'LEGAL'
       and
       map_jzvre.vat_reporting_entity_id = jzvre.vat_reporting_entity_id);

    CURSOR c_ap_trx_type(cpn_trx_id in number) is
      SELECT invoice_type_lookup_code
      FROM ap_invoices_all
      WHERE invoice_id = cpn_trx_id;

    CURSOR c_cr_dtl(cpn_trx_id in number) is
      SELECT cr.reversal_category   cr_rev_category
      FROM ar_cash_receipts_all cr
      WHERE cr.cash_receipt_id = cpn_trx_id
      AND   cr.type = 'MISC';   /* got from R11i belgium solution */
    l_cr_dtl_rec          c_cr_dtl%ROWTYPE;

    CURSOR c_sl_trx_type_dtl(cpn_trx_id in number) is
      SELECT sl.trx_type  sl_trx_type
      FROM ar_cash_receipt_history_all crh,
        ce_statement_reconcils_all sr,
        ce_statement_lines sl
      WHERE crh.cash_receipt_id = cpn_trx_id
      AND   crh.cash_receipt_history_id = sr.reference_id
      AND   sr.statement_line_id = sl.statement_line_id
	  AND	crh.org_id = sr.org_id; -- Bug 	8364296
    l_sl_dtl_rec          c_sl_trx_type_dtl%ROWTYPE;

    CURSOR c_ar_trx_type(cp_trx_type_id in number) is
      SELECT type
      FROM ra_cust_trx_types_all
      WHERE cust_trx_type_id = cp_trx_type_id;

    /* fetches all transactions for which box is not allocated */
    /* this cursor is only used for reference in REF CURSOR RETURN statement */
    CURSOR c_trxs_for_allocation( cp_source varchar2, cp_period_name varchar2 ) IS
      SELECT
        jg_zz_vat_alloc_prc_pkg.g_fresh_allocation allocation_type,
        /* 'FRESH ALLOCATION'  allocation_type, */
        dtl.extract_source_ledger,
        dtl.tax,
        dtl.tax_status_code,
        dtl.tax_jurisdiction_code,
        dtl.tax_rate_code,
        dtl.tax_rate_id,
        dtl.reporting_status_id,
        dtl.event_class_code,
        dtl.entity_code,
        dtl.trx_id,
        dtl.trx_type_id,
        dtl.trx_type_mng,
        dtl.tax_recoverable_flag,
        dtl.vat_transaction_id,
        dtl.tax_rate_vat_trx_type_code vat_trans_type,
        nvl(dtl.tax_amt_funcl_curr, dtl.tax_amt) tax_amount,
        NULL  allocation_error_code,
        NULL  period_type
      FROM  jg_zz_vat_trx_details dtl, jg_zz_vat_rep_status status
      WHERE status.reporting_status_id = dtl.reporting_status_id
        AND status.vat_reporting_entity_id = pn_vat_reporting_entity_id
        AND status.tax_calendar_period = cp_period_name
        AND dtl.extract_source_ledger = cp_source;

    TYPE trxs_for_alloc_csr_type IS REF CURSOR RETURN c_trxs_for_allocation%ROWTYPE;
    l_trxs_for_alloc_csr    trxs_for_alloc_csr_type;
    l_trx_rec               c_trxs_for_allocation%ROWTYPE;

    FUNCTION get_transactions_cursor(
      pv_extract_source_ledger      varchar2,
      pv_tax_period_name            varchar2,
      pv_fresh_allocation_flag      varchar2
    ) return trxs_for_alloc_csr_type is

      l_trxs_csr trxs_for_alloc_csr_type;
    begin

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'get_transactions_cursor-begin');
      end if;

      if pv_fresh_allocation_flag = g_yes then

        if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'get_transactions_cursor- pv_fresh_allocation_flag = g_yes');
        end if;

        /*
         NOTE: if any of the below cursor is changed to add/remove select columns,
               then the same change also should be done for the other select statement
               + the cursor c_trxs_for_allocation which is defined above
        */
        OPEN l_trxs_csr FOR
                SELECT
                  jg_zz_vat_alloc_prc_pkg.g_fresh_allocation allocation_type,
                  /* 'FRESH ALLOCATION'  allocation_type, */
                  dtl.extract_source_ledger,
                  dtl.tax,
                  dtl.tax_status_code,
                  dtl.tax_jurisdiction_code,
                  dtl.tax_rate_code,
                  dtl.tax_rate_id,
                  dtl.reporting_status_id,
                  dtl.event_class_code,
                  dtl.entity_code,
                  dtl.trx_id,
                  dtl.trx_type_id,
                  dtl.trx_type_mng,
                  dtl.tax_recoverable_flag,
                  dtl.vat_transaction_id,
                  dtl.tax_rate_vat_trx_type_code vat_trans_type,
                  nvl(dtl.tax_amt_funcl_curr, dtl.tax_amt) tax_amount,
                  NULL  allocation_error_code,
                  NULL  period_type
                FROM  jg_zz_vat_trx_details dtl, jg_zz_vat_rep_status status
                WHERE status.reporting_status_id = dtl.reporting_status_id
                  AND status.vat_reporting_entity_id = pn_vat_reporting_entity_id
                  AND status.tax_calendar_period = pv_tax_period_name
                  AND dtl.extract_source_ledger = pv_extract_source_ledger;

      else /*return errors cursor */

        if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'get_transactions_cursor- pv_fresh_allocation_flag <> g_yes: returns errors only');
        end if;

        OPEN l_trxs_csr FOR
                SELECT
                  jg_zz_vat_alloc_prc_pkg.g_error_allocation   allocation_type,
                  /* 'ERROR ALLOCATION'  allocation_type, */
                  dtl.extract_source_ledger,
                  dtl.tax,
                  dtl.tax_status_code,
                  dtl.tax_jurisdiction_code,
                  dtl.tax_rate_code,
                  dtl.tax_rate_id,
                  dtl.reporting_status_id,
                  dtl.event_class_code,
                  dtl.entity_code,
                  dtl.trx_id,
                  dtl.trx_type_id,
                  dtl.trx_type_mng,
                  dtl.tax_recoverable_flag,
                  dtl.vat_transaction_id,
                  dtl.tax_rate_vat_trx_type_code vat_trans_type,
                  nvl(dtl.tax_amt_funcl_curr, dtl.tax_amt) tax_amount,
                  err.allocation_error_code   allocation_error_code,
                  err.period_type             period_type
                FROM  jg_zz_vat_trx_details dtl,
                      jg_zz_vat_box_errors err,
                      jg_zz_vat_rep_status status
                WHERE status.reporting_status_id = dtl.reporting_status_id
                  AND dtl.vat_transaction_id = err.vat_transaction_id
                  AND status.vat_reporting_entity_id = pn_vat_reporting_entity_id
                  AND status.tax_calendar_period = pv_tax_period_name
                  AND dtl.extract_source_ledger = pv_extract_source_ledger;

      end if;

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'get_transactions_cursor- return');
      end if;

      return l_trxs_csr;

    end get_transactions_cursor;

  BEGIN

    gv_debug_flag := true;
    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'run allocation - start');
    end if;


    /* Initializing Variables */
    ln_created_by               := FND_GLOBAL.user_id;
    ln_last_updated_by          := FND_GLOBAL.user_id;
    ln_last_update_login        := FND_GLOBAL.login_id;
    ld_today                    := trunc(SYSDATE);

    ln_request_id               := FND_PROFILE.value('CONC_REQUEST_ID');
    ln_program_application_id   := FND_PROFILE.value('PROG_APPL_ID');
    ln_program_id               := FND_PROFILE.value('CONC_PROGRAM_ID');
    ln_program_login_id         := FND_PROFILE.value('CONC_LOGIN_ID');
    ln_allocated_cnt            := 0;
    ln_ins_errored_cnt          := 0;
    ln_upd_errored_cnt          := 0;
    ln_del_errored_cnt          := 0;

    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'run allocation - before JG_ZZ_VAT_REP_UTILITY.validate_process_initiation');
    end if;


    /* Make a call to utility package which validates and determines whether to proceed further with this process or not */
    JG_ZZ_VAT_REP_UTILITY.validate_process_initiation(
      pn_vat_reporting_entity_id  => pn_vat_reporting_entity_id,
      pv_tax_calendar_period      => pv_tax_calendar_period,
      pv_source                   => pv_source,
      pv_reallocate_flag          => pv_reallocate_flag,
      pv_process_name             => 'ALLOCATION',     /* is this correct */
      xn_reporting_status_id_ap   => ln_rep_status_id_ap,
      xn_reporting_status_id_ar   => ln_rep_status_id_ar,
      xn_reporting_status_id_gl   => ln_rep_status_id_gl,
      xv_return_status            => lv_return_flag,
      xv_return_message           => lv_return_message
    );


    /* raise error if validation failed */
    if lv_return_flag in (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error)  then
      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'run allocation - Error JG_ZZ_VAT_REP_UTILITY.validate_process_initiation. value-'||lv_return_flag);
      end if;

      /* print return message;
      request WARNING (retcode=1), ERROR (retcode=2)*/
      xv_errbuf := lv_return_message;
      xv_retcode := 2;
      return;
    end if;

    open c_get_alloc_flags;
    fetch c_get_alloc_flags into lv_enable_alloc_flag, lv_enable_annual_alloc_flag;
    close c_get_alloc_flags;

    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'run allocation - lv_enable_alloc_flag:'||lv_enable_alloc_flag ||', lv_enable_annual_alloc_flag:'||lv_enable_annual_alloc_flag);
    end if;

    /* logic to set the variable that indicates the no of source ledgers the will be allocated */
    ln_source_iterations := 1;
    if pv_source = g_source_all then
      ln_source_iterations := 3;
    end if;

    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'run allocation - Product Iterations'||ln_source_iterations);
    end if;

	FOR product IN 1..ln_source_iterations LOOP  /* 1=AP, 2=AR, 3=GL */

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, ' product loop:'||product);
      end if;

      /* initialization for SOURCE specific variables */
      lv_curr_allocation_status   := null;
      lv_allocation_status_flag   := null;

      /* logic to decide for which source ledger the processing has to run */
      if pv_source <> g_source_all then
        lv_extract_source_ledger := pv_source;

        if pv_source = g_source_ap then ln_rep_status_id := ln_rep_status_id_ap;
        elsif pv_source = g_source_ar then ln_rep_status_id := ln_rep_status_id_ar;
        elsif pv_source = g_source_gl then ln_rep_status_id := ln_rep_status_id_gl;
        end if;

      /* this will get executed only if pv_source = g_source_all */
      elsif product = 1 then
        lv_extract_source_ledger := g_source_ap;
        ln_rep_status_id := ln_rep_status_id_ap;
      elsif product = 2 then
        lv_extract_source_ledger := g_source_ar;
        ln_rep_status_id := ln_rep_status_id_ar;
      elsif product = 3 then
        lv_extract_source_ledger := g_source_gl;
        ln_rep_status_id := ln_rep_status_id_gl;
      end if;

	  if gv_debug_flag then
         fnd_file.put_line(fnd_file.log, 'run allocation - Extract Source Ledger'||lv_extract_source_ledger);
		 fnd_file.put_line(fnd_file.log, 'run allocation - Rep Status ID'||ln_rep_status_id);
      end if;

      /*if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'run allocation - pl->bCallTo-get_allocation_status - ln_rep_status_id:'||ln_rep_status_id);
      end if;
        */
      lv_curr_allocation_status := get_allocation_status(pn_reporting_status_id => ln_rep_status_id);

      /*if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'run allocation - pl->aCallTo-get_allocation_status:'||lv_curr_allocation_status);
      end if;
        */
      /* logic to say whether to execute cursor for first time allocation/reallocation or errored allocations*/
      if pv_reallocate_flag = g_no and lv_curr_allocation_status = g_yes then
        GOTO next_source;   /*  no need of processing for this source as it is already done */
      elsif (pv_reallocate_flag = g_yes or lv_curr_allocation_status = g_no) then
        lv_fresh_allocation_flag := g_yes;
      else  /*meaning the processing for allocation errors */
        lv_fresh_allocation_flag := g_no;
      end if;

      /* Dynamic cursor that fetches data either from JG_ZZ_VAT_TRX_DETAILS or JG_ZZ_VAT_BOX_ERRORS depending
        on the REALLOCATE_FLAG value
        While looping thru transaction -
          If the record is being processed from JG_ZZ_VAT_TRX_DETAILS, then it is processed for both period_types
          else if the record is being processed from JG_ZZ_VAT_BOX_ERRORS, then only error period_type is processed
      */
      l_trxs_for_alloc_csr :=
            get_transactions_cursor(
              pv_extract_source_ledger  => lv_extract_source_ledger,
              pv_tax_period_name        => pv_tax_calendar_period,
              pv_fresh_allocation_flag  => lv_fresh_allocation_flag
            );

      LOOP

        lv_financial_document_type := null;

        FETCH l_trxs_for_alloc_csr INTO l_trx_rec;
        EXIT WHEN l_trxs_for_alloc_csr%NOTFOUND;

        if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'run allocation - trxloop 1. lv_fresh_allocation_flag:'||lv_fresh_allocation_flag);
		  fnd_file.put_line(fnd_file.log, 'run allocation - Transaction ID - '||l_trx_rec.trx_id);
		  fnd_file.put_line(fnd_file.log, 'run allocation - VAT Transaction ID - '||l_trx_rec.vat_transaction_id);
        end if;


        /* should we loop here twice if it is fresh allocation */

        if lv_fresh_allocation_flag = g_yes then
          if lv_enable_annual_alloc_flag = g_yes then
            ln_period_type_iterations := 2;
          else
            ln_period_type_iterations := 1;
          end if;

        /* incase of error allocations, period type iterations should be 1 as it can contain PERIODIC
        as well annual error */
        else
          ln_period_type_iterations := 1;
        end if;

        if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'run allocation - trxloop 2. lv_fresh_allocation_flag:'||lv_fresh_allocation_flag
            ||', entityCode:'||l_trx_rec.entity_code ||', trx_type_mng:'||l_trx_rec.trx_type_mng
          );
        end if;

        /* Financial document type derivation based on SOURCE (AP, AR, GL) */
        if lv_extract_source_ledger = g_source_ap then
          open c_ap_trx_type(l_trx_rec.trx_id);
          fetch c_ap_trx_type into lv_financial_document_type;
          close c_ap_trx_type;

        elsif lv_extract_source_ledger = g_source_ar then

          /* SOURCE = 'CR' i.e Cash Receipts */
          if l_trx_rec.entity_code = g_ar_entitycode_receipts then

            open c_cr_dtl(l_trx_rec.trx_id);
            fetch c_cr_dtl into l_cr_dtl_rec;
            close c_cr_dtl;

            open c_sl_trx_type_dtl(l_trx_rec.trx_id);
            fetch c_sl_trx_type_dtl into l_sl_dtl_rec;
            close c_sl_trx_type_dtl;

            if gv_debug_flag then
              fnd_file.put_line(fnd_file.log, 'run allocation - trxloop 3. sl_trx_type:'
                ||l_sl_dtl_rec.sl_trx_type ||', cr_rev_category:'||l_cr_dtl_rec.cr_rev_category
              );
            end if;

            if l_sl_dtl_rec.sl_trx_type in ('CREDIT','MISC_CREDIT') then
              /* Reversal Misc Receipt */
              if l_cr_dtl_rec.cr_rev_category = 'REV' then
                lv_financial_document_type := 'MISCREVR';

              /* Misc Cash Receipt */
              elsif l_cr_dtl_rec.cr_rev_category is NULL then
                lv_financial_document_type := 'MISCREC';
              end if;

            elsif l_sl_dtl_rec.sl_trx_type in ('DEBIT','MISC_DEBIT') then
              /* Reversal Misc Payment */
              if l_cr_dtl_rec.cr_rev_category = 'REV' then
                lv_financial_document_type := 'MISCREVP';

              /* Misc Cash Payment */
              elsif l_cr_dtl_rec.cr_rev_category is NULL then
                lv_financial_document_type := 'MISCPAY';
              end if;

            end if;

          elsif l_trx_rec.entity_code = g_ar_entitycode_transactions then
            open c_ar_trx_type(l_trx_rec.trx_type_id);
            fetch c_ar_trx_type into lv_financial_document_type;
            close c_ar_trx_type;

            /*  commented during UT
            lv_financial_document_type := l_trx_rec.trx_type_mng;
            */

          end if;

        elsif lv_extract_source_ledger = g_source_gl then
          lv_financial_document_type := 'N/A';

        end if;

		if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'run allocation - financial_document_type : '||lv_financial_document_type);
        end if;

		if gv_debug_flag then
           fnd_file.put_line(fnd_file.log, 'run allocation - Period Iterations'||ln_period_type_iterations);
        end if;

        /* loop to handle the processing for PERIODIC as well as ANNUAL allocations based on setup*/
        for period_type in 1..ln_period_type_iterations loop

          /* initialization for PERIOD_TYPE specific local variables */
          lv_tax_box                := null;
          lv_taxable_box            := null;
          ln_allocation_rule_id     := null;
          lv_allocation_error_code  := null;
          lv_allocation_errored_flag  := g_no;
          /*
            author: brathod
            Moved statement lv_allocation_errored_flag  := g_no; to from trx loop to here, as it needs to be
            initialized every time a new rules is picked-up.  This issue was identified because of the following
            senario,
            Consider that both rules (Periodic, Annual) are defined.  Now first time allocation process
            failes to find a rule for period_type='PERIODIC' and it sets the error flag (lv_allocation_errored_flag)to Y.
            Next time when a rule with period_type='ANNUAL' is actually matching, it will still have stale error flag
            with value Y (as it was being reset only for a new trx and not between the period_type iteration) and hence
            it thinks that the no applicable rule is found.  It tries to report this as an error by inserting a record
            in errors table.  However this time the rule is matching, hence error_code is null and due to this
            procedure to insert error record fails with exception "Cannot insert null"
          */

          if lv_fresh_allocation_flag = g_no then
            lv_period_type  := l_trx_rec.period_type; /* this is the period type of the error allocation */
          elsif period_type = 1 then
            lv_period_type  := g_period_type_periodic;
          else  /* period_type = 2 then */
            lv_period_type  := g_period_type_annual;
          end if;

          /*if gv_debug_flag then
            fnd_file.put_line(fnd_file.log, 'run allocation - periodTypeloop 1. BefAllocBox. lv_period_type:'||lv_period_type);
          end if;
            */

          -- Initialize the variable for counting the no. of transactions getting allocated
          lv_check_alloc_trans := 0;
          gv_hierarchy_level := 0;

		  if gv_debug_flag then
           fnd_file.put_line(fnd_file.log, 'run allocation - ENTERING LOOP Before calling Allocation_Box()');
          end if;

          LOOP

		  if gv_debug_flag then
           fnd_file.put_line(fnd_file.log, 'run allocation - INSIDE LOOP Before calling Allocation_Box()');
          end if;

              lv_tax_box                := null;
              lv_taxable_box            := null;
              ln_allocation_rule_id     := null;
              lv_allocation_error_code  := null;
              lv_allocation_errored_flag  := g_no;
              lv_allocation_status_flag := null;
              lv_return_flag            := null;
              lv_return_message         := null;

              begin
                 lv_alloc_flag    := NULL;
                 lv_tax_rate_code := NULL;
                 lv_vat_trans_type := NULL;

                 select tax_rate_code, vat_transaction_type_code
                 into lv_tax_rate_code, lv_vat_trans_type
                 from zx_rates_b
                 where tax_rate_id = l_trx_rec.tax_rate_id;

                 if l_trx_rec.tax_rate_code = lv_tax_rate_code then
                    if (l_trx_rec.vat_trans_type is null AND lv_vat_trans_type is null)
                       OR (l_trx_rec.vat_trans_type = lv_vat_trans_type) then
                       lv_alloc_flag := 'Y';
                    else
                       lv_alloc_flag := 'N';
                       lv_allocation_error_code := 'JG_ZZ_INVALID_VAT_TRANS_TYPE';
                    end if;
                 else
                    lv_alloc_flag := 'N';
                    lv_allocation_error_code := 'JG_ZZ_INVALID_TAX_RATE_CODE';
                 end if;

                 exception
                    when others then
                       lv_alloc_flag := 'N';
                       lv_allocation_error_code := 'JG_ZZ_INVALID_TAX_RATE_CODE';
              end;

			  if gv_debug_flag then
                 fnd_file.put_line(fnd_file.log, 'run allocation - Allocation Flag '||lv_alloc_flag);
              end if;
		      if gv_debug_flag then
                 fnd_file.put_line(fnd_file.log, 'run allocation - Allocation_error_code' ||lv_allocation_error_code);
              end if;

              if lv_alloc_flag = 'Y' then
                allocate_box(
                    pn_vat_reporting_entity_id  => pn_vat_reporting_entity_id,
                    pv_period_type          => lv_period_type,
                    pv_source               => l_trx_rec.extract_source_ledger,
                    pv_event_class_code     => lv_financial_document_type,  /* l_trx_rec.event_class_code, */
                    pv_tax                  => l_trx_rec.tax,
                    pv_tax_status           => l_trx_rec.tax_status_code,
                    pv_tax_jurisdiction     => l_trx_rec.tax_jurisdiction_code,
                    pv_tax_rate_code        => l_trx_rec.tax_rate_code,
                    pv_tax_recoverable_flag => l_trx_rec.tax_recoverable_flag,
                    xv_tax_box              => lv_tax_box,
                    xv_taxable_box          => lv_taxable_box,
                    xn_allocation_rule_id   => ln_allocation_rule_id,
                    xv_error_code           => lv_allocation_error_code,
                    xv_return_status        => lv_return_flag,
                    xv_return_message       => lv_return_message
                );

				if gv_debug_flag then
                 fnd_file.put_line(fnd_file.log, 'run allocation - AFTER allocation_box() CALL');
				end if;

                if gv_debug_flag then
                   fnd_file.put_line(fnd_file.log, 'run allocation - periodTypeloop 2. AftAllocBox. lv_period_type:'||lv_period_type
                     ||', lv_return_flag:'||lv_return_flag
                     ||', lv_return_message:'||lv_return_message
                     ||', tax_box:'||lv_tax_box
                     ||', taxable_box:'||lv_taxable_box
                     ||', alc_rule_id:'||ln_allocation_rule_id
                     ||', error_code:'||lv_allocation_error_code
                     --   ||', sign:'||ln_sign_indicator
                    );
                end if;
              end if;

              /* raise error if validation failed */
              if lv_return_flag in (fnd_api.g_ret_sts_unexp_error)  then
                 xv_errbuf := lv_return_message;
                 xv_retcode := 2;
                 return;
              end if;

              if lv_allocation_error_code IS NOT NULL then
                 if gv_hierarchy_level > 0 then
                    if lv_check_alloc_trans > 0 then
                       /* if the allocation is done for a previous error, then flush the error */
                       if lv_fresh_allocation_flag = g_no then
                          delete_allocation_error(
                             pn_vat_transaction_id    => l_trx_rec.vat_transaction_id,
                             pv_allocation_error_code => l_trx_rec.allocation_error_code,
                             pv_period_type           => lv_period_type,
                             xv_return_status        => lv_return_flag,
                             xv_return_message       => lv_return_message
                          );

                          /* raise error if validation failed */
                          if lv_return_flag in (fnd_api.g_ret_sts_unexp_error)  then
                             xv_errbuf := lv_return_message;
                             xv_retcode := 2;
                             return;
                          end if;

                          ln_del_errored_cnt  := ln_del_errored_cnt + 1;
                       end if;
                       exit;
                    elsif lv_tax_box is null or lv_taxable_box is null then
					   if gv_debug_flag then
                          fnd_file.put_line(fnd_file.log, 'run allocation - Setting ERROR JG_ZZ_NO_BOX_IN_RULE');
                       end if;
                       lv_allocation_error_code := 'JG_ZZ_NO_BOX_IN_RULE';
                    end if;
                 end if;

                 /* allocation error found */
                 if l_trx_rec.tax_amount = 0 and l_trx_rec.extract_source_ledger = 'AP' then
                   /* Transactions with Tax Amount = 0 and source = 'AP' should not go in jg_zz_vat_box_errors table */
                   exit;
                 end if;

                 if lv_fresh_allocation_flag = g_yes then

                   if gv_debug_flag then
                     fnd_file.put_line(fnd_file.log, 'run allocation - periodTypeloop. BefDML2 : '
                        ||' lv_allocation_errored_flag = g_yes and lv_fresh_allocation_flag = g_yes'
                     );
                   end if;

				   if gv_debug_flag then
                      fnd_file.put_line(fnd_file.log, 'run allocation - Calling PROCEDURE insert_allocation_error');
					  fnd_file.put_line(fnd_file.log, 'run allocation - VAT Transaction ID '||l_trx_rec.vat_transaction_id);
					  fnd_file.put_line(fnd_file.log, 'run allocation - Error Code '||lv_allocation_error_code);
				   end if;

                   insert_allocation_error(
                      pn_vat_transaction_id    => l_trx_rec.vat_transaction_id,
                      pv_allocation_error_code => lv_allocation_error_code,
                      pv_period_type           => lv_period_type,
                      pn_created_by            => ln_created_by,
                      pn_last_updated_by       => ln_last_updated_by,
                      pn_last_update_login     => ln_last_update_login,
                      xv_return_status        => lv_return_flag,
                      xv_return_message       => lv_return_message
                   );

				   if gv_debug_flag then
                      fnd_file.put_line(fnd_file.log, 'run allocation - AFTER PROCEDURE insert_allocation_error');
				   end if;

                   /* raise error if above call failed */
                   if lv_return_flag in (fnd_api.g_ret_sts_unexp_error)  then
                     xv_errbuf := lv_return_message;
                     xv_retcode := 2;
                     return;
                   end if;

                   ln_ins_errored_cnt  := ln_ins_errored_cnt + 1;

                   exit;

                 elsif lv_fresh_allocation_flag = g_no then

                   if gv_debug_flag then
                     fnd_file.put_line(fnd_file.log, 'run allocation - periodTypeloop. BefDML3 : '
                        ||' lv_allocation_errored_flag = g_yes and lv_fresh_allocation_flag = g_no'
                     );
                   end if;
                   update_allocation_error(
                       pn_vat_transaction_id    => l_trx_rec.vat_transaction_id,
                       pv_allocation_error_code => lv_allocation_error_code,
                       pv_period_type           => lv_period_type,
                       pn_last_updated_by       => ln_last_updated_by,
                       pn_last_update_login     => ln_last_update_login,
                       xv_return_status        => lv_return_flag,
                       xv_return_message       => lv_return_message
                   );
                   /* raise error if validation failed */
                   if lv_return_flag in (fnd_api.g_ret_sts_unexp_error)  then
                     xv_errbuf := lv_return_message;
                     xv_retcode := 2;
                     return;
                   end if;

                   ln_upd_errored_cnt  := ln_upd_errored_cnt + 1;

                   exit;

                 end if;

              end if;

              /* check if the call to allocate_box has assigned a tax and taxable box. If not error should be noted */
              if (lv_tax_box IS NULL and lv_taxable_box IS NULL) then
                lv_allocation_errored_flag  := g_yes;
                lv_allocation_status_flag   := fnd_api.g_ret_sts_error;
              end if;

              if gv_debug_flag then
                fnd_file.put_line(fnd_file.log, 'run allocation - periodTypeloop 3. BefDML.'
                  ||' lv_allocation_errored_flag:'||lv_allocation_errored_flag
                  ||', lv_allocation_status_flag:'||lv_allocation_status_flag
                );
              end if;

              /* following check is not required as per the Conf. Call with HQ
              <<posting_check>>
              If transaction is not posted then
                -- record the POSTING ERROR CODE (60163) in errors table
                lv_allocation_error_code := g_alloc_errcode_not_posted;
                lv_allocation_errored_flag := g_yes;
              end if;
              */

              /* i.e successfully found a reco. / non reco. Box */
              if lv_allocation_errored_flag = g_no then

                if gv_debug_flag then
                  fnd_file.put_line(fnd_file.log, 'run allocation - periodTypeloop. BefDML1 : lv_allocation_errored_flag = g_no'
                  );
                end if;

                ln_allocated_cnt  := ln_allocated_cnt + 1;

				if gv_debug_flag then
                  fnd_file.put_line(fnd_file.log, 'run allocation - Calling jg_zz_vat_box_allocs_pkg.insert_row');
                  fnd_file.put_line(fnd_file.log, 'run allocation - vat box allocation ID'||ln_vat_box_allocation_id);
				  fnd_file.put_line(fnd_file.log, 'run allocation - vat transaction ID'||l_trx_rec.vat_transaction_id);
				  fnd_file.put_line(fnd_file.log, 'run allocation - Allocation Rule ID'||ln_allocation_rule_id);

                end if;

                jg_zz_vat_box_allocs_pkg.insert_row(
                    xn_vat_box_allocation_id     => ln_vat_box_allocation_id,
                    pn_vat_transaction_id        => l_trx_rec.vat_transaction_id,
                    pv_period_type               => lv_period_type,
                    pn_allocation_rule_id        => ln_allocation_rule_id,
                    pv_tax_box                   => lv_tax_box,
                    pv_taxable_box               => lv_taxable_box,
                    pv_tax_recoverable_flag      => l_trx_rec.tax_recoverable_flag,
                    pn_request_id                => ln_request_id,
                    pn_program_application_id    => ln_program_application_id,
                    pn_program_id                => ln_program_id,
                    pn_program_login_id          => ln_program_login_id,
                    pn_created_by                => ln_created_by,
                    pn_last_updated_by           => ln_last_updated_by,
                    pn_last_update_login         => ln_last_update_login,
                    xv_return_status            => lv_return_flag,
                    xv_return_message           => lv_return_message
                );

                lv_check_alloc_trans := lv_check_alloc_trans + 1;

                /* raise error if error is returned from the call */
                if lv_return_flag in (fnd_api.g_ret_sts_unexp_error)  then
                  xv_errbuf := lv_return_message;
                  xv_retcode := 2;
                  return;
                end if;

              end if;

           end loop;   /* Fetch Allocation Rules */

        end loop;   /* for period types */

      end loop;   /* for JG transactions */

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'run allocation - EndLoop Trx. lv_allocation_status_flag:'||lv_allocation_status_flag );
      end if;

      /* derive the sequence value for the allocation process that will be punched in the status table
      Preparation for call to post process update */
      if lv_allocation_status_flag  is null then
        lv_allocation_status_flag  := fnd_api.g_ret_sts_success;
      end if;

      if ln_allocation_process_id is null then
        select jg_zz_vat_rep_status_s2.nextval into ln_allocation_process_id from dual;
      end if;
      lv_return_flag    := null;
      lv_return_message := null;

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'run allocation - before jg_zz_vat_rep_utility.post_process_update.'
        );
      end if;
      /* Call the utility API to update allocation_process columns of jg_zz_vat_rep_status table by passing proper values.*/
      jg_zz_vat_rep_utility.post_process_update(
        pn_vat_reporting_entity_id  => pn_vat_reporting_entity_id,
        pv_tax_calendar_period      => pv_tax_calendar_period,
        pv_source                   => lv_extract_source_ledger,
        pv_process_name             => 'ALLOCATION',
        pn_process_id               => ln_allocation_process_id,
        pv_process_flag             => lv_allocation_status_flag ,
        pv_enable_allocations_flag  => lv_enable_alloc_flag,
        xv_return_status            => lv_return_flag,
        xv_return_message           => lv_return_message
      );

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'run allocation - after jg_zz_vat_rep_utility.post_process_update.'
          ||' lv_return_flag:'||lv_return_flag
        );
      end if;
      /* raise error if validation failed */
      if lv_return_flag in (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error)  then
        xv_errbuf := lv_return_message;
        xv_retcode := 2;
        return;
      end if;

      <<next_source>>
      null;

    END LOOP;  /* end for source */

    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'run allocation - after EndLoop Source. ln_allocated_cnt:'||ln_allocated_cnt
        ||', ln_ins_errored_cnt:'||ln_ins_errored_cnt
        ||', ln_upd_errored_cnt:'||ln_upd_errored_cnt
        ||', ln_del_errored_cnt:'||ln_del_errored_cnt
      );
    end if;

    /* Finally submit allocation errors report to display the allocation errors
    Submit a request for ALLOCATION ERRORS report with a call to FND_REQUEST.SUBMIT API by providing the parameters */
    if ln_ins_errored_cnt > 0 or ln_upd_errored_cnt > 0 then

      /* need to correct these values filled for the parameters */
      /* add_layout call is required to associate a XML Pub. template to the request output */
      lb_ret_value :=
          fnd_request.add_layout(
            template_appl_name  => 'JG',
            template_code       => 'JGZZAERL',
            template_language   => 'en',
            template_territory  => 'US',
            output_format       => 'PDF'
          );

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'run allocation - after fnd_request.add_layout'
        );
      end if;

      ln_errors_conc_request_id :=
          fnd_request.submit_request(
            'JG','JGZZAERL','','',false,
            pn_vat_reporting_entity_id, pv_tax_calendar_period, pv_source, FND_GLOBAL.LOCAL_CHR(0),'',
            '','','','','','','','','','',
            '','','','','','','','','','',
            '','','','','','','','','','',
            '','','','','','','','','','',
            '','','','','','','','','','',
            '','','','','','','','','','',
            '','','','','','','','','','',
            '','','','','','','','','','',
            '','','','','','','','','','',
            '','','','','');

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'run allocation - after fnd_request.submit_request'
        );
      end if;

    end if;

  END run_allocation;

  /*
      Takes the transaction details and allocates a VAT box by matching them with the rule definition details.
      If not able to find any box, then returns the xv_error_code with corresponding MESSAGE_CODE
  */
  PROCEDURE allocate_box(
    pn_vat_reporting_entity_id    number,
    pv_period_type                VARCHAR2,
    pv_source                     VARCHAR2,
    pv_event_class_code           VARCHAR2,
    pv_tax                        VARCHAR2,
    pv_tax_status                 VARCHAR2,
    pv_tax_jurisdiction           VARCHAR2,
    pv_tax_rate_code              VARCHAR2,
    pv_tax_recoverable_flag       VARCHAR2,
    xv_tax_box                OUT nocopy VARCHAR2,
    xv_taxable_box            OUT nocopy VARCHAR2,
    xn_allocation_rule_id     OUT nocopy VARCHAR2,
    xv_error_code             OUT nocopy VARCHAR2,
    xv_return_status     out  nocopy  varchar2,
    xv_return_message    out  nocopy  varchar2
  ) is

    lv_rule_found       VARCHAR2(1);
    ld_today            DATE;

    lv_hierarchy_debug  varchar2(30);
    lv_statement        varchar2(10);

    lv_allocation_rule_id   jg_zz_vat_alloc_rules.allocation_rule_id%TYPE;
    lv_tax_box_recoverable  jg_zz_vat_alloc_rules.tax_box_recoverable%TYPE;
    lv_tax_box_non_rec      jg_zz_vat_alloc_rules.tax_box_non_recoverable%TYPE;
    lv_taxable_boxes  jg_zz_vat_alloc_rules.taxable_box_non_recoverable%TYPE;

    CURSOR c_get_alloc_rules_for_tax(
			cp_period_type              VARCHAR2,
			cp_source                   VARCHAR2,
			cp_financial_document_type  VARCHAR2,
			cp_tax                      VARCHAR2,
			cp_tax_status               VARCHAR2,
			cp_tax_rate_code            VARCHAR2,
			cp_tax_jurisdiction_code    VARCHAR2
          ) IS
      SELECT
              a.allocation_rule_id,
              a.source,
              a.financial_document_type,
              a.vat_transaction_type,
              a.tax_code tax,
              a.tax_status tax_status_code,
              a.tax_rate_code,
              a.tax_jurisdiction_code,
              a.tax_box_recoverable,
              a.tax_box_non_recoverable,
              a.taxable_box_recoverable,
              a.taxable_box_non_recoverable
      FROM jg_zz_vat_alloc_rules a
          ,jg_zz_vat_rep_entities b
      WHERE b.vat_reporting_entity_id       = pn_vat_reporting_entity_id
        and ((b.entity_type_code            = 'ACCOUNTING'
             and
             b.mapping_vat_rep_entity_id   = a.vat_reporting_entity_id)
            OR
            (b.entity_type_code            = 'LEGAL'
             and
             b.vat_reporting_entity_id     = a.vat_reporting_entity_id))
        AND a.period_type = cp_period_type
        AND a.source = cp_source
        AND a.financial_document_type = cp_financial_document_type
        AND a.tax_code = cp_tax
        --AND nvl(a.tax_status, '1') = nvl(cp_tax_status, '1')   --9729100
        --AND nvl(a.tax_rate_code, '1') = nvl(cp_tax_rate_code,'1')
        --AND nvl(a.tax_jurisdiction_code,'1') = nvl(cp_tax_jurisdiction_code, '1')
        AND (a.tax_status is null or a.tax_status = nvl(cp_tax_status, '1'))
        AND (a.tax_rate_code is null or a.tax_rate_code = nvl(cp_tax_rate_code, '1'))
        AND (a.tax_jurisdiction_code is null or a.tax_jurisdiction_code = nvl(cp_tax_jurisdiction_code, '1'))
        AND ld_today BETWEEN a.effective_from_date AND nvl(a.effective_to_date, ld_today)
      ORDER BY
        a.source,
        a.financial_document_type,
        a.tax_code NULLS LAST,
        a.tax_status NULLS LAST,
        a.tax_rate_code NULLS LAST,
        a.tax_jurisdiction_code NULLS LAST,
        decode(cp_source, 'AP', decode(pv_tax_recoverable_flag, g_yes,
                                    decode(a.taxable_box_non_recoverable, NULL, NULL,
                                           decode(a.tax_box_recoverable, NULL, NULL,
                                                        a.tax_box_recoverable)),
                                    decode(a.taxable_box_non_recoverable, NULL, NULL,
                                           decode(a.tax_box_non_recoverable, NULL, NULL,
                                                        a.tax_box_non_recoverable))),
                        decode(a.taxable_box_non_recoverable, NULL, NULL,
                                           decode(a.tax_box_recoverable, NULL, NULL,
                                                       a.tax_box_recoverable))) NULLS LAST;

    CURSOR c_get_rules_stat_code_jrdict(
            cp_vat_reporting_entity_id  NUMBER,
            cp_period_type              VARCHAR2,
            cp_source                   VARCHAR2,
            cp_financial_document_type  VARCHAR2,
            cp_tax                      VARCHAR2
          ) IS
      SELECT
              a.allocation_rule_id,
              a.tax_box_recoverable,
              a.tax_box_non_recoverable,
              nvl(a.taxable_box_recoverable, a.taxable_box_non_recoverable)
      FROM  jg_zz_vat_alloc_rules a
	       ,jg_zz_vat_rep_entities b
      WHERE b.vat_reporting_entity_id  = cp_vat_reporting_entity_id
	     AND ((b.entity_type_code            = 'ACCOUNTING'
             and
             b.mapping_vat_rep_entity_id   = a.vat_reporting_entity_id)
             OR
            (b.entity_type_code            = 'LEGAL'
             and
             b.vat_reporting_entity_id     = a.vat_reporting_entity_id))
        AND a.period_type = cp_period_type
        AND a.source = cp_source
        AND a.financial_document_type = cp_financial_document_type
        AND a.tax_code = cp_tax
        --AND nvl(a.tax_status, '1') = nvl(gv_tax_status, '1')  --9729100
        --AND nvl(a.tax_rate_code, '1') = nvl(gv_tax_rate_code,'1')
        --AND nvl(a.tax_jurisdiction_code,'1') = nvl(gv_tax_jurisdiction_code, '1')
	AND (a.tax_status is null or a.tax_status = nvl(gv_tax_status, '1'))
        AND (a.tax_rate_code is null or a.tax_rate_code = nvl(gv_tax_rate_code, '1'))
        AND (a.tax_jurisdiction_code is null or a.tax_jurisdiction_code = nvl(gv_tax_jurisdiction_code, '1'))
        AND ld_today BETWEEN a.effective_from_date AND nvl(a.effective_to_date, ld_today)
        AND a.allocation_rule_id <> gv_appl_alloc_rule_id
        AND a.allocation_rule_id > gv_allocation_rule_id
      ORDER BY
        a.allocation_rule_id;

    CURSOR c_get_minimum_alloc_rule_id(
            cp_vat_reporting_entity_id  NUMBER,
            cp_period_type              VARCHAR2,
            cp_source                   VARCHAR2,
            cp_financial_document_type  VARCHAR2,
            cp_tax                      VARCHAR2,
			cp_allocation_rule_id       NUMBER
          ) IS
      SELECT
              min(a.allocation_rule_id) - 1
      FROM  jg_zz_vat_alloc_rules a
	       ,jg_zz_vat_rep_entities b
      WHERE b.vat_reporting_entity_id  = cp_vat_reporting_entity_id
	     AND ((b.entity_type_code            = 'ACCOUNTING'
             and
             b.mapping_vat_rep_entity_id   = a.vat_reporting_entity_id)
             OR
            (b.entity_type_code            = 'LEGAL'
             and
             b.vat_reporting_entity_id     = a.vat_reporting_entity_id))
        AND a.period_type = cp_period_type
        AND a.source = cp_source
        AND a.financial_document_type = cp_financial_document_type
        AND a.tax_code = cp_tax
        --AND nvl(a.tax_status, '1') = nvl(gv_tax_status, '1') --9729100
        --AND nvl(a.tax_rate_code, '1') = nvl(gv_tax_rate_code,'1')
        --AND nvl(a.tax_jurisdiction_code,'1') = nvl(gv_tax_jurisdiction_code, '1')
	AND (a.tax_status is null or a.tax_status = nvl(gv_tax_status, '1'))
        AND (a.tax_rate_code is null or a.tax_rate_code = nvl(gv_tax_rate_code, '1'))
        AND (a.tax_jurisdiction_code is null or a.tax_jurisdiction_code = nvl(gv_tax_jurisdiction_code, '1'))
        AND ld_today BETWEEN a.effective_from_date AND nvl(a.effective_to_date, ld_today)
        AND a.allocation_rule_id <> cp_allocation_rule_id;

  begin

    ld_today := trunc(sysdate);
    lv_rule_found := g_no;

           if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'allocate_box - afterHierarchy. gv_hierarchy_level:'||gv_hierarchy_level
            ||', gv_appl_alloc_rule_id ::'||gv_appl_alloc_rule_id
			||', gv_allocation_rule_id ::'||gv_allocation_rule_id
          );
        end if;

    if gv_hierarchy_level = 0 then

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'allocate_box - start' );
		fnd_file.put_line(fnd_file.log, 'allocate_box - Hierarchy Level '||gv_hierarchy_level );
      end if;
      lv_statement := '1';

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'Params-'
          ||', pn_vat_reporting_entity_id:'||pn_vat_reporting_entity_id
          ||', pv_period_type:'||pv_period_type
          ||', pv_source:'||pv_source
          ||', pv_event_class_code:'||pv_event_class_code
          ||', pv_tax:'||pv_tax
          ||', pv_tax_status:'||pv_tax_status
          ||', pv_tax_jurisdiction:'||pv_tax_jurisdiction
          ||', pv_tax_rate_code:'||pv_tax_rate_code
          ||', pv_tax_recoverable_flag:'||pv_tax_recoverable_flag
        );
      end if;

      /* fetch all rules defined for the tax for a period type */
      for rule IN c_get_alloc_rules_for_tax(pv_period_type,
        pv_source, pv_event_class_code, pv_tax, pv_tax_status, pv_tax_rate_code,pv_tax_jurisdiction)
      loop

        if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'allocate_box - RECORD found in Cursor c_get_alloc_rules_for_tax');
        end if;

        lv_statement := '2';
        lv_rule_found := g_no;

        lv_hierarchy_debug := 'T';
        /* Start of hierarchical derivation of Tax box.  */
        /* Checking for Status */
		if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'allocate_box - rule.tax_status_code:'||rule.tax_status_code||', pv_tax_status:'||pv_tax_status);
        end if;
        if rule.tax_status_code = pv_tax_status then
          lv_statement := '3';
          lv_hierarchy_debug := 'T:S';
          /* checking for Tax Rate */
		 if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'allocate_box - rule.tax_rate_code:'||rule.tax_rate_code||', pv_tax_rate_code:'||pv_tax_rate_code);
         end if;
          if rule.tax_rate_code = pv_tax_rate_code then
            lv_statement := '4';
            lv_hierarchy_debug := 'T:S:R';
            /* checking for Jurisdiction */
			if gv_debug_flag then
				fnd_file.put_line(fnd_file.log, 'allocate_box - rule.tax_jurisdiction_code:'||rule.tax_jurisdiction_code||', pv_tax_jurisdiction:'||pv_tax_jurisdiction);
             end if;
            if rule.tax_jurisdiction_code = pv_tax_jurisdiction then
				if gv_debug_flag then
				fnd_file.put_line(fnd_file.log, 'allocate_box - rule.tax_jurisdiction_code = pv_tax_jurisdiction');
				end if;
              lv_statement := '5';
              lv_hierarchy_debug := 'T:S:R:J';
              lv_rule_found := g_yes;
              gv_hierarchy_level := 4;
            /* Tax Rate is success, but jurisdiction failed. so assign the default box of rate that is not specific to any jurisdiction under the rate*/

            elsif rule.tax_jurisdiction_code is null then
				if gv_debug_flag then
				fnd_file.put_line(fnd_file.log, 'allocate_box - rule.tax_jurisdiction_code is null');
				end if;

              lv_statement := '6';
              lv_hierarchy_debug := 'T:S:R:Jnull';
              lv_rule_found := g_yes;
              gv_hierarchy_level := 3;
            else
				if gv_debug_flag then
				fnd_file.put_line(fnd_file.log, 'allocate_box - else part one');
				end if;

              null;
            end if;

          /* Tax status is success, but rate failed. so assign the default box of status which is not specific to any rate under the status */
          elsif rule.tax_rate_code is null then
		  if gv_debug_flag then
				fnd_file.put_line(fnd_file.log, 'allocate_box - rule.tax_rate_code is null');
				end if;
            lv_statement := '7';
            lv_hierarchy_debug := 'T:S:Rnull';
            lv_rule_found := g_yes;
            gv_hierarchy_level := 2;
          else
		  		  if gv_debug_flag then
				fnd_file.put_line(fnd_file.log, 'allocate_box - else part two ');
				end if;
            lv_statement := '8';
            lv_hierarchy_debug := 'T:S:null';
            null;
          end if;

        /* Tax is success, but status failed. so assign the default box of tax which is not specific to any status under the tax*/
        elsif rule.tax_status_code is null then
				  		  if gv_debug_flag then
				fnd_file.put_line(fnd_file.log, 'allocate_box - rule.tax_status_code is null ');
				end if;
          lv_statement := '9';
          lv_hierarchy_debug := 'T:Snull';
          lv_rule_found := g_yes;
          gv_hierarchy_level := 1;
        else
				  		  if gv_debug_flag then
				fnd_file.put_line(fnd_file.log, 'allocate_box - else part three ');
				end if;
          lv_statement := '10';
          lv_hierarchy_debug := 'T:null';
          null;
        end if;

        if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'allocate_box - afterHierarchy. lv_rule_found:'||lv_rule_found
            ||', pv_tax_recoverable_flag:'||pv_tax_recoverable_flag
          );
        end if;

        if lv_rule_found = g_yes then
          -- Get the values from the cursor variable
          lv_allocation_rule_id := rule.allocation_rule_id;
          lv_tax_box_recoverable := rule.tax_box_recoverable;
          lv_tax_box_non_rec := rule.tax_box_non_recoverable;
          lv_taxable_boxes := nvl(rule.taxable_box_recoverable,rule.taxable_box_non_recoverable);

        if gv_debug_flag then
          fnd_file.put_line(fnd_file.log, 'allocate_box - afterHierarchy. lv_allocation_rule_id1:'||lv_allocation_rule_id);
        end if;

          -- Assign the value to global variables accordingly
          gv_tax_status := NULL;
          gv_tax_rate_code := NULL;
          gv_tax_jurisdiction_code := NULL;

          if (gv_hierarchy_level = 2) or (gv_hierarchy_level = 3) or (gv_hierarchy_level = 4) then
               gv_tax_status := rule.tax_status_code;
          end if;
          if (gv_hierarchy_level = 3) or (gv_hierarchy_level = 4) then
               gv_tax_rate_code := rule.tax_rate_code;
          end if;
          if (gv_hierarchy_level = 4) then
               gv_tax_jurisdiction_code := rule.tax_jurisdiction_code;
          end if;

          -- Assign the appropriate value to gv_allocation_rule_id variable
          gv_appl_alloc_rule_id := lv_allocation_rule_id;

		if gv_debug_flag then
		fnd_file.put_line(fnd_file.log, 'allocate_box - afterHierarchy. gv_appl_alloc_rule_id2:'||gv_appl_alloc_rule_id);
		end if;

      -- Get the minimum allocation rule ID
      open c_get_minimum_alloc_rule_id(pn_vat_reporting_entity_id, pv_period_type, pv_source, pv_event_class_code, pv_tax, lv_allocation_rule_id);
      fetch c_get_minimum_alloc_rule_id into gv_allocation_rule_id;
      close c_get_minimum_alloc_rule_id;

		if gv_debug_flag then
     		fnd_file.put_line(fnd_file.log, 'allocate_box - c_get_minimum_alloc_rule_id 1:'||gv_allocation_rule_id);
		end if;

	 IF gv_allocation_rule_id IS NULL THEN
		gv_allocation_rule_id := lv_allocation_rule_id;
		       if gv_debug_flag then
                fnd_file.put_line(fnd_file.log, 'Only one allocation rule applicable' );
               end if;
	 END IF;

		if gv_debug_flag then
     		fnd_file.put_line(fnd_file.log, 'allocate_box - c_get_minimum_alloc_rule_id 2:'||gv_allocation_rule_id);
		end if;
 	if gv_debug_flag then
   	  fnd_file.put_line(fnd_file.log, 'allocate_box - afterHierarchy. gv_allocation_rule_id3:'||gv_allocation_rule_id);
  	end if;
          exit;
        end if;
      end loop;
  else

      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'allocate_box - Hierarchy Level not 0');
      end if;
      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'Params-'
          ||', pn_vat_reporting_entity_id:'||pn_vat_reporting_entity_id
          ||', pv_period_type:'||pv_period_type
          ||', pv_source:'||pv_source
          ||', pv_event_class_code:'||pv_event_class_code
          ||', pv_tax:'||pv_tax
          ||', pv_tax_status:'||pv_tax_status
          ||', pv_tax_jurisdiction:'||pv_tax_jurisdiction
          ||', pv_tax_rate_code:'||pv_tax_rate_code
          ||', pv_tax_recoverable_flag:'||pv_tax_recoverable_flag
        );
      end if;

      lv_rule_found := g_no;

      lv_allocation_rule_id := 0;
	  if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'allocate_box - Opening Cursor c_get_rules_stat_code_jrdict' );
      end if;
      open c_get_rules_stat_code_jrdict(pn_vat_reporting_entity_id, pv_period_type, pv_source, pv_event_class_code, pv_tax);
      fetch c_get_rules_stat_code_jrdict into lv_allocation_rule_id,
                                      lv_tax_box_recoverable,
                                      lv_tax_box_non_rec,
                                      lv_taxable_boxes;

      close c_get_rules_stat_code_jrdict;

	  if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'allocate_box - AFTER Cursor c_get_rules_stat_code_jrdict FETCH' );
		fnd_file.put_line(fnd_file.log, 'allocate_box - Allocation_rule_id '||lv_allocation_rule_id);
		fnd_file.put_line(fnd_file.log, 'allocate_box - Tax Box Recoverable '||lv_tax_box_recoverable);
		fnd_file.put_line(fnd_file.log, 'allocate_box - tax Box Non Recoverables '||lv_tax_box_non_rec);
      end if;

     if lv_allocation_rule_id <> 0 then
       lv_rule_found := g_yes;
       gv_allocation_rule_id := lv_allocation_rule_id;
     end if;

    end if;

    if lv_rule_found = g_yes then
       xn_allocation_rule_id := lv_allocation_rule_id;
       xv_taxable_box        := lv_taxable_boxes;
       if (pv_source = 'AP' and pv_tax_recoverable_flag = g_yes) or (pv_source = 'AR') or (pv_source = 'GL') then
           xv_tax_box    := lv_tax_box_recoverable;
       else
           xv_tax_box    := lv_tax_box_non_rec;
       end if;
    elsif lv_rule_found = g_no then
	   if gv_debug_flag then
           fnd_file.put_line(fnd_file.log, 'allocate_box - Setting ERROR NO ALLOC RULE FOUND');
       end if;
       /* execution will come here if no matching rule is found */
       xv_error_code := JG_ZZ_VAT_ALLOC_PRC_PKG.g_alloc_errcode_rule_not_found;
       return;
    end if;

    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'allocate_box - end. Hierarchy Path-'||lv_hierarchy_debug );
    end if;

  exception
    when others then
      if gv_debug_flag then
        fnd_file.put_line(fnd_file.log, 'allocate_box - ERROR lv_statement:'||lv_statement );
      end if;
      xv_return_status  := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_alloc_prc_pkg.allocate_box ~ Unexpected Error -' || sqlerrm;

  end allocate_box;

  FUNCTION get_allocation_status(
    pn_reporting_status_id NUMBER
  ) return varchar2 IS
    cursor c_get_allocation_status is
      select nvl(allocation_status_flag, g_no) allocation_status
      from jg_zz_vat_rep_status a
      where a.reporting_status_id = pn_reporting_status_id;

    lv_allocation_status  jg_zz_vat_rep_status.allocation_status_flag%TYPE;

  begin
    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'get_allocation_status - start ->'||lv_allocation_status );
    end if;
    open c_get_allocation_status;
    fetch c_get_allocation_status into lv_allocation_status;
    close c_get_allocation_status;

    if gv_debug_flag then
      fnd_file.put_line(fnd_file.log, 'get_allocation_status - return ->'||lv_allocation_status );
    end if;

    return lv_allocation_status;
  end get_allocation_status;

END JG_ZZ_VAT_ALLOC_PRC_PKG;

/
