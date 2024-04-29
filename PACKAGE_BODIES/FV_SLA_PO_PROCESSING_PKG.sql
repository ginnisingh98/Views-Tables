--------------------------------------------------------
--  DDL for Package Body FV_SLA_PO_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SLA_PO_PROCESSING_PKG" AS
  --$Header: FVXLAPOB.pls 120.0.12010000.4 2010/03/26 21:24:10 sasukuma noship $

  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------

  c_FAILURE   CONSTANT  NUMBER := -1;
  c_SUCCESS   CONSTANT  NUMBER := 0;
  ---------------------------------------------------------------------------

  --==========================================================================
  ----Logging Declarations
  --==========================================================================
  C_STATE_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
  C_PROC_LEVEL  CONSTANT  NUMBER	   :=	FND_LOG.LEVEL_PROCEDURE;
  C_EVENT_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_EVENT;
  C_EXCEP_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
  C_ERROR_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_ERROR;
  C_UNEXP_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
  g_log_level   CONSTANT NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_path_name   CONSTANT VARCHAR2(100)  := 'fv.plsql.fvxlaacb.fv_sla_po_processing_pkg';
  --
  -- Linefeed character
  --
  CRLF          CONSTANT VARCHAR2(1) := FND_GLOBAL.newline;




  TYPE fv_pya_doc_info_rec IS RECORD
  (
    application_id     NUMBER,
    event_id           NUMBER,
    ledger_id          NUMBER,
    treasury_symbol_id NUMBER,
    fund               VARCHAR2(100),
    document_id        NUMBER,
    distribution_id    NUMBER,
    ent_curr_trx_amt   NUMBER,
    acc_curr_trx_amt   NUMBER,
    gl_date            DATE,
    event_type         VARCHAR2(100),
    old_ccid           NUMBER,
    ent_old_trx_amt     NUMBER,
    acc_old_trx_amt     NUMBER,
    old_event_type     VARCHAR2(100),
    old_fund           VARCHAR2(100),
    old_treasury_symbol_id  NUMBER,
    ent_pya_amt        NUMBER,
    acc_pya_amt        NUMBER,
    index_val          NUMBER
  );

  TYPE fv_pya_doc_info_tbl_type IS TABLE OF fv_pya_doc_info_rec INDEX BY BINARY_INTEGER;

  TYPE fv_pya_total_ts_info_rec IS RECORD
  (
    ledger_id            NUMBER,
    gl_date              DATE,
    treasury_symbol_id   NUMBER,
    tot_ent_curr_trx_amt NUMBER,
    tot_acc_curr_trx_amt NUMBER,
    tot_ent_old_trx_amt  NUMBER,
    tot_acc_old_trx_amt  NUMBER,
    anticipated_amt      NUMBER,
    pya_status           VARCHAR2(1)
  );

  TYPE fv_pya_total_ts_info_tbl_type IS TABLE OF fv_pya_total_ts_info_rec INDEX BY BINARY_INTEGER;


  PROCEDURE trace
  (
    p_level             IN NUMBER,
    p_procedure_name    IN VARCHAR2,
    p_debug_info        IN VARCHAR2
  )
  IS

  BEGIN
     fv_sla_utl_processing_pkg.trace
    (
      p_level             => p_level,
      p_procedure_name    => p_procedure_name,
      p_debug_info        => p_debug_info
    );
  END trace;

  PROCEDURE init
  IS
    l_procedure_name       VARCHAR2(100) :='.init';
  BEGIN
    trace(C_STATE_LEVEL, l_procedure_name, 'Package Information');
    trace(C_STATE_LEVEL, l_procedure_name, '$Header: FVXLAPOB.pls 120.0.12010000.4 2010/03/26 21:24:10 sasukuma noship $');
  END;


  PROCEDURE stack_error
  (
    p_program_name  IN VARCHAR2,
    p_location      IN VARCHAR2,
    p_error_message IN VARCHAR2
  )
  IS
  BEGIN
    NULL;
  END;

  PROCEDURE init_extract_record
  (
    p_application_id    IN NUMBER,
    p_fv_extract_detail IN OUT NOCOPY fv_extract_detail_gt%ROWTYPE
  )
  IS
  BEGIN
    p_fv_extract_detail.application_id := p_application_id;
    p_fv_extract_detail.ent_commitment_amount := 0;
    p_fv_extract_detail.acc_commitment_amount := 0;
    p_fv_extract_detail.ent_unpaid_obl_amount := 0;
    p_fv_extract_detail.acc_unpaid_obl_amount := 0;
    p_fv_extract_detail.ent_unpaid_obl_pya_amount := 0;
    p_fv_extract_detail.acc_unpaid_obl_pya_amount := 0;
    p_fv_extract_detail.ent_unpaid_obl_pya_off_amount := 0;
    p_fv_extract_detail.acc_unpaid_obl_pya_off_amount := 0;
    p_fv_extract_detail.ent_anticipated_budget_amount := 0;
    p_fv_extract_detail.acc_anticipated_budget_amount := 0;
    p_fv_extract_detail.ent_unanticipated_bud_amount := 0;
    p_fv_extract_detail.acc_unanticipated_bud_amount := 0;
    p_fv_extract_detail.ent_unreserved_budget_amount := 0;
    p_fv_extract_detail.acc_unreserved_budget_amount := 0;
  END;


  PROCEDURE po_pya_processing
  (
    p_fv_pya_total_ts_info_tbl IN OUT NOCOPY fv_pya_total_ts_info_tbl_type,
    p_fv_pya_doc_info_tbl      IN OUT NOCOPY fv_pya_doc_info_tbl_type,
    p_fv_extract_detail        IN OUT NOCOPY fv_sla_utl_processing_pkg.fv_ref_detail,
    p_error_code               OUT NOCOPY NUMBER,
    p_error_desc               OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name  VARCHAR2(100) :='.po_pya_processing';
    l_count           NUMBER;
    l_ts_id           NUMBER;
    l_index           NUMBER;
    l_anticipate_amt  NUMBER;

  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    -------------------------------------------------------------------------
    l_count := p_fv_pya_total_ts_info_tbl.FIRST;
    trace(C_STATE_LEVEL, l_procedure_name, 'l_count(1)='||l_count);
    IF l_count IS NOT NULL THEN
      LOOP
        trace(C_STATE_LEVEL, l_procedure_name, 'tot_ent_curr_trx_amt='||NVL(p_fv_pya_total_ts_info_tbl(l_count).tot_ent_curr_trx_amt, 0));
        trace(C_STATE_LEVEL, l_procedure_name, 'tot_ent_old_trx_amt='||NVL(p_fv_pya_total_ts_info_tbl(l_count).tot_ent_old_trx_amt, 0));
        IF (NVL(p_fv_pya_total_ts_info_tbl(l_count).tot_ent_curr_trx_amt, 0) = NVL(p_fv_pya_total_ts_info_tbl(l_count).tot_ent_old_trx_amt, 0)) THEN
          p_fv_pya_total_ts_info_tbl(l_count).pya_status := 'N';
        ELSIF (NVL(p_fv_pya_total_ts_info_tbl(l_count).tot_ent_curr_trx_amt, 0) > NVL(p_fv_pya_total_ts_info_tbl(l_count).tot_ent_old_trx_amt, 0)) THEN
          p_fv_pya_total_ts_info_tbl(l_count).pya_status := 'U';
        ELSE
          p_fv_pya_total_ts_info_tbl(l_count).pya_status := 'D';
        END IF;
        trace(C_STATE_LEVEL, l_procedure_name, 'pya_status='||p_fv_pya_total_ts_info_tbl(l_count).pya_status);
        fv_sla_utl_processing_pkg.get_anticipated_ts_amt
        (
          p_ledger_id          => p_fv_pya_total_ts_info_tbl(l_count).ledger_id,
          p_gl_date            => p_fv_pya_total_ts_info_tbl(l_count).gl_date,
          p_treasury_symbol_id => p_fv_pya_total_ts_info_tbl(l_count).treasury_symbol_id,
          p_anticipated_amt    => p_fv_pya_total_ts_info_tbl(l_count).anticipated_amt,
          p_error_code         => p_error_code,
          p_error_desc         => p_error_desc
        );
        IF (p_error_code <> C_SUCCESS) THEN
          EXIT;
        END IF;

        IF l_count = p_fv_pya_total_ts_info_tbl.LAST THEN
          EXIT;
        ELSE
          l_count := p_fv_pya_total_ts_info_tbl.NEXT(l_count);
          trace(C_STATE_LEVEL, l_procedure_name, 'l_count(1)='||l_count);
        END IF;
      END LOOP;
    END IF;

    l_count := p_fv_pya_doc_info_tbl.FIRST;
    trace(C_STATE_LEVEL, l_procedure_name, 'l_count(2)='||l_count);
    IF l_count IS NOT NULL THEN
      LOOP
        l_ts_id := p_fv_pya_doc_info_tbl(l_count).treasury_symbol_id;
        l_index := p_fv_pya_doc_info_tbl(l_count).index_val;
        trace(C_STATE_LEVEL, l_procedure_name, 'l_ts_id='||l_ts_id);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_index='||l_index);
        trace(C_STATE_LEVEL, l_procedure_name, 'event_type='||p_fv_pya_doc_info_tbl(l_count).event_type);
        IF (p_fv_pya_doc_info_tbl(l_count).event_type IN ('PO_PA_RESERVED', 'RELEASE_RESERVED')) THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'pya_status='||p_fv_pya_total_ts_info_tbl(l_ts_id).pya_status);
          IF (p_fv_pya_total_ts_info_tbl(l_ts_id).pya_status = 'U') THEN
            p_fv_extract_detail(l_index).adjustment_type := 'Upward';
          ELSE
            p_fv_extract_detail(l_index).adjustment_type := 'Downward';
          END IF;
          p_fv_extract_detail(l_index).ent_unpaid_obl_amount := 0;
          p_fv_extract_detail(l_index).acc_unpaid_obl_amount := 0;
          p_fv_extract_detail(l_index).ent_unreserved_budget_amount := p_fv_pya_doc_info_tbl(l_count).ent_old_trx_amt;
          p_fv_extract_detail(l_index).acc_unreserved_budget_amount := p_fv_pya_doc_info_tbl(l_count).acc_old_trx_amt;
          p_fv_extract_detail(l_index).ent_unpaid_obl_pya_amount := -1*(p_fv_extract_detail(l_index).ent_unreserved_budget_amount +
                                                                    p_fv_extract_detail(l_index).ent_unanticipated_bud_amount);
          p_fv_extract_detail(l_index).acc_unpaid_obl_pya_amount := -1*(p_fv_extract_detail(l_index).acc_unreserved_budget_amount +
                                                                      p_fv_extract_detail(l_index).acc_unanticipated_bud_amount);

          trace(C_STATE_LEVEL, l_procedure_name, 'prior_year_flag='||p_fv_extract_detail(l_index).prior_year_flag);
          trace(C_STATE_LEVEL, l_procedure_name, 'adjustment_type='||p_fv_extract_detail(l_index).adjustment_type);
          trace(C_STATE_LEVEL, l_procedure_name, 'ent_unpaid_obl_amount='||p_fv_extract_detail(l_index).ent_unpaid_obl_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'acc_unpaid_obl_amount='||p_fv_extract_detail(l_index).acc_unpaid_obl_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'ent_unpaid_obl_pya_amount='||p_fv_extract_detail(l_index).ent_unpaid_obl_pya_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'acc_unpaid_obl_pya_amount='||p_fv_extract_detail(l_index).acc_unpaid_obl_pya_amount);
        END IF;

        IF l_count = p_fv_pya_doc_info_tbl.LAST THEN
          EXIT;
        ELSE
          l_count := p_fv_pya_doc_info_tbl.NEXT(l_count);
          trace(C_STATE_LEVEL, l_procedure_name, 'l_count(2)='||l_count);
        END IF;
      END LOOP;
    END IF;

    trace(C_PROC_LEVEL, l_procedure_name, 'END');
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END;

  PROCEDURE cache_prev_pya_info
  (
    p_fv_pya_doc_info     IN fv_pya_doc_info_rec,
    p_fv_pya_doc_info_tbl IN OUT NOCOPY fv_pya_doc_info_tbl_type,
    p_fv_pya_total_ts_info_tbl IN OUT NOCOPY fv_pya_total_ts_info_tbl_type,
    p_error_code          OUT NOCOPY NUMBER,
    p_error_desc          OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name  VARCHAR2(100) :='.cache_prev_pya_info';
    l_fv_pya_doc_info fv_pya_doc_info_rec;
    l_fund_value              VARCHAR(30);
    l_account_value           VARCHAR2(30);
    l_bfy_value               VARCHAR2(30);
    l_fund_category fv_fund_parameters.fund_category%TYPE;
    l_fund_time_frame fv_fund_parameters.fund_time_frame%TYPE;
    l_treasury_symbol_id fv_treasury_symbols.treasury_symbol_id%TYPE;
    l_treasury_symbol fv_treasury_symbols.treasury_symbol%TYPE;
    l_fund_expired_status VARCHAR2(30);
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    -------------------------------------------------------------------------

    l_fv_pya_doc_info := p_fv_pya_doc_info;

    trace(C_STATE_LEVEL, l_procedure_name, 'event_type='||l_fv_pya_doc_info.event_type);
    trace(C_STATE_LEVEL, l_procedure_name, 'distribution_id='||l_fv_pya_doc_info.distribution_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'event_id='||l_fv_pya_doc_info.event_id);
    IF (l_fv_pya_doc_info.event_type IN ('PO_PA_RESERVED', 'RELEASE_RESERVED')) THEN
      /* Try to get the old unreserve information for the distribution*/
      BEGIN
        SELECT code_combination_id,
               entered_amt,
               accounted_amt,
               event_type_code
          INTO l_fv_pya_doc_info.old_ccid,
               l_fv_pya_doc_info.ent_old_trx_amt,
               l_fv_pya_doc_info.acc_old_trx_amt,
               l_fv_pya_doc_info.old_event_type
          FROM po_bc_distributions
         WHERE distribution_id = l_fv_pya_doc_info.distribution_id
           AND ae_event_id  = (SELECT max(ae_event_id)
                                 FROM po_bc_distributions pbd
                                WHERE pbd.distribution_id = l_fv_pya_doc_info.distribution_id
                                  AND pbd.ae_event_id <> l_fv_pya_doc_info.event_id
                                  AND pbd.distribution_type <> 'REQUISITION'
                                  AND pbd.main_or_backing_code = 'M'
                                  AND EXISTS (SELECT 1
                                                FROM xla_ae_headers xah
                                                WHERE application_id = 201
                                                  AND xah.event_id = pbd.ae_event_id
                                                  AND xah.accounting_entry_status_code = 'F') );

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'No Previous Entry Found');
          l_fv_pya_doc_info.old_ccid := -1;
          l_fv_pya_doc_info.ent_old_trx_amt := 0;
          l_fv_pya_doc_info.acc_old_trx_amt := 0;
          l_fv_pya_doc_info.old_event_type := NULL;
        WHEN OTHERS THEN
          p_error_code := c_FAILURE;
          p_error_desc := SQLERRM;
          stack_error (l_procedure_name, 'SELECT_po_bc_distributions', p_error_desc);
          trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_po_bc_distributions:'||p_error_desc);
      END;

      IF (p_error_code = C_SUCCESS) THEN
        trace(C_STATE_LEVEL, l_procedure_name, 'old_ccid='||l_fv_pya_doc_info.old_ccid);
        IF (NVL(l_fv_pya_doc_info.old_ccid, -1) <> -1) THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'Calling fv_sla_utl_processing_pkg.get_segment_values');
          l_fund_value := NULL;
          fv_sla_utl_processing_pkg.get_segment_values
          (
            p_ledger_id     => l_fv_pya_doc_info.ledger_id,
            p_ccid          => l_fv_pya_doc_info.old_ccid,
            p_fund_value    => l_fund_value,
            p_account_value => l_account_value,
            p_bfy_value     => l_bfy_value,
            p_error_code    => p_error_code,
            p_error_desc    => p_error_desc
          );
          trace(C_STATE_LEVEL, l_procedure_name, 'l_fund_value='||l_fund_value);

          IF (p_error_code = C_SUCCESS) THEN
            l_fv_pya_doc_info.old_fund := l_fund_value;
            trace(C_STATE_LEVEL, l_procedure_name, 'Calling fv_sla_utl_processing_pkg.get_fund_details');
            l_treasury_symbol_id := NULL;
            fv_sla_utl_processing_pkg.get_fund_details
            (
              p_application_id     => l_fv_pya_doc_info.application_id,
              p_ledger_id          => l_fv_pya_doc_info.ledger_id,
              p_fund_value         => l_fv_pya_doc_info.old_fund,
              p_gl_date            => l_fv_pya_doc_info.gl_date,
              p_fund_category      => l_fund_category,
              p_fund_status        => l_fund_expired_status,
              p_fund_time_frame    => l_fund_time_frame,
              p_treasury_symbol_id => l_treasury_symbol_id,
              p_treasury_symbol    => l_treasury_symbol,
              p_error_code         => p_error_code,
              p_error_desc         => p_error_desc
            );
            trace(C_STATE_LEVEL, l_procedure_name, 'l_treasury_symbol_id='||l_treasury_symbol_id);
            trace(C_STATE_LEVEL, l_procedure_name, 'l_treasury_symbol='||l_treasury_symbol);
          END IF;
        END IF;
      END IF;
    END IF;

    IF (p_error_code = C_SUCCESS) THEN
      l_fv_pya_doc_info.old_treasury_symbol_id := l_treasury_symbol_id;

      IF (l_fv_pya_doc_info.treasury_symbol_id IS NOT NULL) THEN
        IF p_fv_pya_total_ts_info_tbl.EXISTS(l_fv_pya_doc_info.treasury_symbol_id) THEN
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).tot_ent_curr_trx_amt := p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).tot_ent_curr_trx_amt + l_fv_pya_doc_info.ent_curr_trx_amt;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).tot_acc_curr_trx_amt := p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).tot_acc_curr_trx_amt + l_fv_pya_doc_info.acc_curr_trx_amt;
        ELSE
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).treasury_symbol_id := l_fv_pya_doc_info.treasury_symbol_id;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).tot_ent_curr_trx_amt := l_fv_pya_doc_info.ent_curr_trx_amt;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).tot_acc_curr_trx_amt := l_fv_pya_doc_info.acc_curr_trx_amt;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).tot_ent_old_trx_amt := 0;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).tot_acc_old_trx_amt := 0;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).gl_date := l_fv_pya_doc_info.gl_date;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).ledger_id := l_fv_pya_doc_info.ledger_id;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.treasury_symbol_id).anticipated_amt := 0;
        END IF;
      END IF;

      IF (l_fv_pya_doc_info.old_treasury_symbol_id IS NOT NULL) THEN
        IF p_fv_pya_total_ts_info_tbl.EXISTS(l_fv_pya_doc_info.old_treasury_symbol_id) THEN
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).tot_ent_old_trx_amt := p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).tot_ent_old_trx_amt + l_fv_pya_doc_info.ent_old_trx_amt;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).tot_acc_old_trx_amt := p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).tot_acc_old_trx_amt + l_fv_pya_doc_info.acc_old_trx_amt;
        ELSE
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).treasury_symbol_id := l_fv_pya_doc_info.old_treasury_symbol_id;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).tot_ent_old_trx_amt := l_fv_pya_doc_info.ent_old_trx_amt;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).tot_acc_old_trx_amt := l_fv_pya_doc_info.acc_old_trx_amt;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).tot_ent_curr_trx_amt := 0;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).tot_acc_curr_trx_amt := 0;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).gl_date := l_fv_pya_doc_info.gl_date;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).ledger_id := l_fv_pya_doc_info.ledger_id;
          p_fv_pya_total_ts_info_tbl(l_fv_pya_doc_info.old_treasury_symbol_id).anticipated_amt := 0;
        END IF;
      END IF;
    END IF;
    p_fv_pya_doc_info_tbl(l_fv_pya_doc_info.index_val) := l_fv_pya_doc_info;

    trace(C_PROC_LEVEL, l_procedure_name, 'END');
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END;

  PROCEDURE po_process_purchase_orders
  (
    p_application_id    IN NUMBER,
    p_fv_extract_detail IN OUT NOCOPY fv_sla_utl_processing_pkg.fv_ref_detail,
    p_error_code        OUT NOCOPY NUMBER,
    p_error_desc        OUT NOCOPY VARCHAR2
  )
  IS

    l_debug_info              VARCHAR2(240);
    l_procedure_name          VARCHAR2(100):='.PO_PROCESS_PURCHASE_ORDERS';

    CURSOR c_po_extract_detail IS
    SELECT pbd.*
      FROM po_bc_distributions pbd,
           xla_events_gt e
     where pbd.distribution_type <> 'REQUISITION'
       AND pbd.ae_event_id = e.event_id
     ORDER BY pbd.ae_event_id,
              pbd.header_id;

    l_po_extract_detail       c_po_extract_detail%ROWTYPE;
    l_ledger_info             fv_sla_utl_processing_pkg.LedgerRecType;
    l_index                   NUMBER;
    l_pya                     VARCHAR2(1) := 'N';
    l_pya_data_exists         BOOLEAN := FALSE;
    l_fund_value              VARCHAR(30);
    l_account_value           VARCHAR2(30);
    l_bfy_value               VARCHAR2(30);
    l_sign                    NUMBER;
    l_conversion_rate         NUMBER;
    l_pya_type                VARCHAR2(100);
    l_treasury_symbol_id      fv_treasury_symbols.treasury_symbol_id%TYPE;
    l_treasury_symbol         fv_treasury_symbols.treasury_symbol%TYPE;
    l_fv_pya_doc_info_tbl       fv_pya_doc_info_tbl_type;
    l_dist_fv_pya_doc_info_rec  fv_pya_doc_info_rec;
    l_fv_pya_total_ts_info_tbl fv_pya_total_ts_info_tbl_type;

  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    trace(C_PROC_LEVEL, l_procedure_name, 'Begin of PO ');
    -- loop thru the PO transaction objects for all distributions
    l_index := p_fv_extract_detail.COUNT;
    l_pya_data_exists := FALSE;
    FOR l_po_extract_detail IN c_po_extract_detail LOOP
      IF (p_error_code = C_SUCCESS) THEN
        --
        -- Get the Ledger Information
        --
        trace(C_PROC_LEVEL, l_procedure_name, 'Calling get_ledger_info');
        fv_sla_utl_processing_pkg.get_ledger_info
        (
          p_ledger_id  => l_po_extract_detail.ledger_id,
          p_ledger_rec => l_ledger_info,
          p_error_code => p_error_code,
          p_error_desc => p_error_desc
        );
      END IF;

      IF (p_error_code = C_SUCCESS) THEN
        trace(C_PROC_LEVEL, l_procedure_name, 'ledger id' ||l_ledger_info.ledger_id);
        trace(C_PROC_LEVEL, l_procedure_name, 'Calling get_segment_values');
        fv_sla_utl_processing_pkg.get_segment_values
        (
          p_ledger_id     => l_ledger_info.ledger_id,
          p_ccid          => l_po_extract_detail.code_combination_id,
          p_fund_value    => l_fund_value,
          p_account_value => l_account_value,
          p_bfy_value     => l_bfy_value,
          p_error_code    => p_error_code,
          p_error_desc    => p_error_desc
        );
      END IF;

      /*********** GET PYA FLAG *************/
      IF (p_error_code = C_SUCCESS) THEN
        trace(C_PROC_LEVEL, l_procedure_name, 'Calling get_prior_year_status');
        fv_sla_utl_processing_pkg.get_prior_year_status
        (
          p_application_id => p_application_id,
          p_ledger_id      => l_ledger_info.ledger_id,
          p_bfy_value      => l_bfy_value,
          p_gl_date        => l_po_extract_detail.gl_date,
          p_pya            => l_pya,
          p_pya_type       => l_pya_type,
          p_error_code     => p_error_code,
          p_error_desc     => p_error_desc
        );
      END IF;

      IF (p_error_code = C_SUCCESS) THEN
        trace(C_STATE_LEVEL, l_procedure_name, 'l_pya: '||l_pya);
        trace(C_STATE_LEVEL, l_procedure_name, 'PO Event ID: '||l_po_extract_detail.ae_event_id);
        trace(C_STATE_LEVEL, l_procedure_name, 'PO Line Number : '||l_po_extract_detail.Line_number);
        trace(C_STATE_LEVEL, l_procedure_name, 'Fund Value: '||l_fund_value);

        l_index := l_index + 1;
        p_fv_extract_detail(l_index).event_id :=l_po_extract_detail.ae_event_id;
        init_extract_record (p_application_id, p_fv_extract_detail(l_index));
        p_fv_extract_detail(l_index).line_number :=l_po_extract_detail.line_number;
        p_fv_extract_detail(l_index).fund_value :=l_fund_value;
        p_fv_extract_detail(l_index).old_ccid := NULL;
        p_fv_extract_detail(l_index).prior_year_flag := l_pya;
        /* Setting the Unpaid Obligation Amount Starts */
        l_sign := 1;
        IF (l_po_extract_detail.event_type_code NOT IN ('PO_PA_RESERVED', 'PO_PA_CANCELLED')) THEN
          l_sign := -1;
        END IF;
        p_fv_extract_detail(l_index).ent_unpaid_obl_amount := l_sign * NVL(l_po_extract_detail.entered_amt, 0);
        p_fv_extract_detail(l_index).acc_unpaid_obl_amount := l_sign * NVL(l_po_extract_detail.accounted_amt, 0);
        /* Setting the Unpaid Obligation Amount Finish */
        IF ((p_fv_extract_detail(l_index).acc_unpaid_obl_amount = 0) AND (p_fv_extract_detail(l_index).ent_unpaid_obl_amount = 0)) THEN
          l_conversion_rate := 1;
        ELSE
          l_conversion_rate := p_fv_extract_detail(l_index).acc_unpaid_obl_amount/p_fv_extract_detail(l_index).ent_unpaid_obl_amount;
        END IF;

        -- get the fund category and expiration date
        trace(C_PROC_LEVEL, l_procedure_name, 'Calling get_fund_details');
        fv_sla_utl_processing_pkg.get_fund_details
        (
          p_application_id     => p_application_id,
          p_ledger_id          => l_ledger_info.ledger_id,
          p_fund_value         => l_fund_value,
          p_gl_date            => l_po_extract_detail.gl_date,
          p_fund_category      => p_fv_extract_detail(l_index).fund_category,
          p_fund_status        => p_fv_extract_detail(l_index).fund_expired_status,
          p_fund_time_frame    => p_fv_extract_detail(l_index).fund_time_frame,
          p_treasury_symbol_id => l_treasury_symbol_id,
          p_treasury_symbol    => l_treasury_symbol,
          p_error_code         => p_error_code,
          p_error_desc         => p_error_desc
        );
        trace(C_PROC_LEVEL, l_procedure_name, 'fund_category='||p_fv_extract_detail(l_index).fund_category);
        trace(C_PROC_LEVEL, l_procedure_name, 'fund_expired_status='||p_fv_extract_detail(l_index).fund_expired_status);
        trace(C_PROC_LEVEL, l_procedure_name, 'fund_time_frame='||p_fv_extract_detail(l_index).fund_time_frame);
        trace(C_PROC_LEVEL, l_procedure_name, 'l_treasury_symbol_id='||l_treasury_symbol_id);
        trace(C_PROC_LEVEL, l_procedure_name, 'l_treasury_symbol='||l_treasury_symbol);
      END IF;

      IF (l_pya = 'N') THEN
        /* Setting the Commitment Amount Starts */
        p_fv_extract_detail(l_index).ent_commitment_amount := 0;
        p_fv_extract_detail(l_index).acc_commitment_amount := 0;

        FOR l_req_extract_detail IN (SELECT entered_amt,
                                            accounted_amt,
                                            event_type_code
                                       FROM po_bc_distributions pbd
                                      WHERE ae_event_id = l_po_extract_detail.ae_event_id
                                        AND main_or_backing_code = 'B_REQ'
                                        AND distribution_type = 'REQUISITION'
                                        AND applied_to_dist_id_2 = l_po_extract_detail.distribution_id) LOOP
          l_sign := 1;
          IF (l_req_extract_detail.event_type_code IN ('PO_PA_RESERVED', 'PO_PA_CANCELLED')) THEN
            l_sign := -1;
          END IF;
          p_fv_extract_detail(l_index).ent_commitment_amount := p_fv_extract_detail(l_index).ent_commitment_amount +
                                                             l_sign * l_req_extract_detail.entered_amt;
          p_fv_extract_detail(l_index).acc_commitment_amount := p_fv_extract_detail(l_index).acc_commitment_amount +
                                                             l_sign * l_req_extract_detail.accounted_amt;
        END LOOP;
        /* Setting the Commitment Amount Finish */
      ELSE
        trace(C_PROC_LEVEL, l_procedure_name, 'Store PYA');
        IF (l_po_extract_detail.event_type_code IN ('PO_PA_UNRESERVED', 'PO_RELEASE_UNRESERVED')) THEN
          p_fv_extract_detail(l_index).fund_expired_status := 'Unexpired';
        END IF;
        trace(C_PROC_LEVEL, l_procedure_name, 'fund_expired_status='||p_fv_extract_detail(l_index).fund_expired_status);
        l_pya_data_exists := TRUE;
        /*Populate all the PYA information so that it could be processed once all the
          lines of the document has been processed. */
        l_dist_fv_pya_doc_info_rec.application_id := p_application_id;
        l_dist_fv_pya_doc_info_rec.gl_date := l_po_extract_detail.gl_date;
        l_dist_fv_pya_doc_info_rec.event_id := l_po_extract_detail.ae_event_id;
        l_dist_fv_pya_doc_info_rec.ledger_id := l_ledger_info.ledger_id;
        l_dist_fv_pya_doc_info_rec.treasury_symbol_id := l_treasury_symbol_id;
        l_dist_fv_pya_doc_info_rec.fund := l_fund_value;
        l_dist_fv_pya_doc_info_rec.document_id := l_po_extract_detail.header_id;
        l_dist_fv_pya_doc_info_rec.distribution_id := l_po_extract_detail.distribution_id;
        l_dist_fv_pya_doc_info_rec.ent_curr_trx_amt := l_po_extract_detail.entered_amt;
        l_dist_fv_pya_doc_info_rec.acc_curr_trx_amt := l_po_extract_detail.accounted_amt;
        l_dist_fv_pya_doc_info_rec.event_type := l_po_extract_detail.event_type_code;
        l_dist_fv_pya_doc_info_rec.index_val := l_index;

        trace(C_PROC_LEVEL, l_procedure_name, 'Calling cache_prev_pya_info');
        /*
           Since the event processing is done line by line, where as the PYA processing
           is to be done at document level, saving the PYA information until the document
           changes
        */
        trace(C_PROC_LEVEL, l_procedure_name, 'Calling cache_prev_pya_info');
        cache_prev_pya_info
        (
          p_fv_pya_doc_info     => l_dist_fv_pya_doc_info_rec,
          p_fv_pya_doc_info_tbl => l_fv_pya_doc_info_tbl,
          p_fv_pya_total_ts_info_tbl => l_fv_pya_total_ts_info_tbl,
          p_error_code          => p_error_code,
          p_error_desc          => p_error_desc
        );
      END IF;

      IF (p_error_code = C_SUCCESS) THEN
        trace(C_STATE_LEVEL, l_procedure_name, 'Fund Category '||p_fv_extract_detail(l_index).fund_category);
        trace(C_STATE_LEVEL, l_procedure_name, 'Fund Expired Status: '||p_fv_extract_detail(l_index).fund_expired_status);
        IF (p_error_code = C_SUCCESS) THEN
          /* Setting the Unanticipated Budget Amount Starts */
          p_fv_extract_detail(l_index).ent_unanticipated_bud_amount := -1 * (p_fv_extract_detail(l_index).ent_commitment_amount +
                                                                       p_fv_extract_detail(l_index).ent_unpaid_obl_amount);
          p_fv_extract_detail(l_index).acc_unanticipated_bud_amount := -1 * (p_fv_extract_detail(l_index).acc_commitment_amount +
                                                                       p_fv_extract_detail(l_index).acc_unpaid_obl_amount);
          /* Setting the Unanticipated Budget Amount Finish */
        END IF;
      END IF;
    END LOOP;  -- for PO objects

    IF (l_pya_data_exists) THEN
      IF (p_error_code = C_SUCCESS) THEN
        -- prior year transaction additional processs
        po_pya_processing
        (
          p_fv_pya_total_ts_info_tbl => l_fv_pya_total_ts_info_tbl,
          p_fv_pya_doc_info_tbl      => l_fv_pya_doc_info_tbl,
          p_fv_extract_detail        => p_fv_extract_detail,
          p_error_code               => p_error_code,
          p_error_desc               => p_error_desc
        );
      END IF;
    END IF;

    ----------------------------------------------------------------------
    l_debug_info := 'End of PO ';
    trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
    ----------------------------------------------------------------------

    trace(C_PROC_LEVEL, l_procedure_name, 'END');
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);

  END po_process_purchase_orders;

  PROCEDURE po_process_requisition
  (
    p_application_id    IN NUMBER,
    p_fv_extract_detail IN OUT NOCOPY fv_sla_utl_processing_pkg.fv_ref_detail,
    p_error_code        OUT NOCOPY NUMBER,
    p_error_desc        OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name          VARCHAR2(100):='.PO_PROCESS_REQUISITION';

    CURSOR c_req_extract_detail IS
    SELECT pbd.*
      FROM po_bc_distributions pbd,
           xla_events_gt e
     WHERE pbd.distribution_type = 'REQUISITION'
       AND pbd.ae_event_id = e.event_id;

    l_req_extract_detail      c_req_extract_detail%ROWTYPE;
    l_index                   NUMBER;
    l_ledger_info             fv_sla_utl_processing_pkg.LedgerRecType;
    l_fund_value              VARCHAR(30);
    l_account_value           VARCHAR2(30);
    l_bfy_value               VARCHAR2(30);
    l_sign                    NUMBER;
    l_pya                     VARCHAR2(1) := 'N';
    l_treasury_symbol_id      fv_treasury_symbols.treasury_symbol_id%TYPE;
    l_treasury_symbol         fv_treasury_symbols.treasury_symbol%TYPE;


  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    trace(C_PROC_LEVEL, l_procedure_name, 'Begin of Requisition ');

    -- loop thru the requsition transaction objects for all distributions
    l_index := p_fv_extract_detail.COUNT;
    FOR l_req_extract_detail IN c_req_extract_detail LOOP
      --
      -- Get the Ledger Information
      --
      trace(C_PROC_LEVEL, l_procedure_name, 'Calling get_ledger_info');
      fv_sla_utl_processing_pkg.get_ledger_info
      (
        p_ledger_id  => l_req_extract_detail.ledger_id,
        p_ledger_rec => l_ledger_info,
        p_error_code => p_error_code,
        p_error_desc => p_error_desc
      );

      IF (p_error_code = C_SUCCESS) THEN
        trace(C_PROC_LEVEL, l_procedure_name, 'ledger id' ||l_ledger_info.ledger_id);
        trace(C_PROC_LEVEL, l_procedure_name, 'Calling get_segment_values');
        fv_sla_utl_processing_pkg.get_segment_values
        (
          p_ledger_id     => l_ledger_info.ledger_id,
          p_ccid          => l_req_extract_detail.code_combination_id,
          p_fund_value    => l_fund_value,
          p_account_value => l_account_value,
          p_bfy_value     => l_bfy_value,
          p_error_code    => p_error_code,
          p_error_desc    => p_error_desc
        );
      END IF;


      IF (l_pya = 'N') THEN
        IF (p_error_code = C_SUCCESS) THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'Req Event ID: '||l_req_extract_detail.ae_event_id);
          trace(C_STATE_LEVEL, l_procedure_name, 'Req Line Number : '||l_req_extract_detail.Line_number);
          trace(C_STATE_LEVEL, l_procedure_name, 'GL Date ='||l_req_extract_detail.gl_date);

          l_index := l_index + 1;
          p_fv_extract_detail(l_index).event_id :=l_req_extract_detail.ae_event_id;
          init_extract_record (p_application_id, p_fv_extract_detail(l_index));
          p_fv_extract_detail(l_index).line_Number :=l_req_extract_detail.line_number;
          p_fv_extract_detail(l_index).fund_value := l_fund_value;
          -- prior year flag -- requsition donot have prior year transactions
          p_fv_extract_detail(l_index).prior_year_flag := 'N';

          trace(C_PROC_LEVEL, l_procedure_name, 'fund value' || l_fund_value);

          -- get the fund category and expiration date
          fv_sla_utl_processing_pkg.get_fund_details
          (
            p_application_id  => p_application_id,
            p_ledger_id       => l_ledger_info.ledger_id,
            p_fund_value      => l_fund_value,
            p_gl_date         => l_req_extract_detail.gl_date,
            p_fund_category   => p_fv_extract_detail(l_index).fund_category,
            p_fund_status     => p_fv_extract_detail(l_index).fund_expired_status,
            p_fund_time_frame => p_fv_extract_detail(l_index).fund_time_frame,
            p_treasury_symbol_id => l_treasury_symbol_id,
            p_treasury_symbol    => l_treasury_symbol,
            p_error_code      => p_error_code,
            p_error_desc      => p_error_desc
          );
        END IF;

        IF (p_error_code = C_SUCCESS) THEN
          l_sign := 1;
          trace(C_STATE_LEVEL, l_procedure_name, 'event_type_code ='||l_req_extract_detail.event_type_code);
          trace(C_STATE_LEVEL, l_procedure_name, 'adjustment_status ='||l_req_extract_detail.adjustment_status);
          IF (l_req_extract_detail.main_or_backing_code = 'B_REQ') THEN
            IF (l_req_extract_detail.event_type_code IN ('PO_PA_RESERVED', 'PO_PA_CANCELLED')) THEN
              l_sign := -1;
            ELSE
              l_sign := 1;
            END IF;
          ELSE
            IF (l_req_extract_detail.event_type_code IN ('REQ_RESERVED', 'REQ_CANCELLED', 'PO_PA_RESERVED', 'PO_PA_CANCELLED')) THEN
              l_sign := 1;
            ELSIF (l_req_extract_detail.event_type_code = 'REQ_ADJUSTED') THEN
              IF (l_req_extract_detail.adjustment_status = 'OLD') THEN
                l_sign := -1;
              ELSE
                l_sign := 1;
              END IF;
            ELSE
              l_sign := -1;
            END IF;
          END IF;
          trace(C_STATE_LEVEL, l_procedure_name, 'l_sign ='||l_sign);
          p_fv_extract_detail(l_index).ent_commitment_amount := l_sign*l_req_extract_detail.entered_amt;
          p_fv_extract_detail(l_index).acc_commitment_amount := l_sign*l_req_extract_detail.accounted_amt;
        END IF;

        IF (p_error_code = C_SUCCESS) THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'Fund Category '||p_fv_extract_detail(l_index).fund_category);
          trace(C_STATE_LEVEL, l_procedure_name, 'Fund Expired Status: '||p_fv_extract_detail(l_index).fund_expired_status);
        END IF;
      END IF;
      IF (p_error_code <> C_SUCCESS) THEN
        EXIT;
      END IF;
    END LOOP;

    trace(C_PROC_LEVEL, l_procedure_name, 'End of Requisition ');
    trace(C_PROC_LEVEL, l_procedure_name, 'END');

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);

  END po_process_requisition;

  PROCEDURE po_extract
  (
    p_application_id  IN NUMBER,
    p_accounting_mode IN VARCHAR2
  )
  IS
    l_procedure_name         VARCHAR2(100):='.PO_EXTRACT';
    l_fv_extract_detail      fv_sla_utl_processing_pkg.fv_ref_detail;
    l_error_code             NUMBER;
    l_gt_error_code          NUMBER;
    l_error_desc             VARCHAR2(1024);
  BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    l_error_code := c_SUCCESS;
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_application_id='||p_application_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_accounting_mode='||p_accounting_mode);

    IF (p_application_id <> 201) THEN
      RETURN;
    END IF;


    trace(C_STATE_LEVEL, l_procedure_name, 'Calling po_process_requisition');
    po_process_requisition
    (
      p_application_id    => p_application_id,
      p_fv_extract_detail => l_fv_extract_detail,
      p_error_code        => l_error_code,
      p_error_desc        => l_error_desc
    );

    IF (l_error_code = C_SUCCESS) THEN
      trace(C_STATE_LEVEL, l_procedure_name, 'Calling po_process_purchase_orders');
      po_process_purchase_orders
      (
        p_application_id    => p_application_id,
        p_fv_extract_detail => l_fv_extract_detail,
        p_error_code        => l_error_code,
        p_error_desc        => l_error_desc
      );
    END IF;

    IF (l_error_code = C_SUCCESS) THEN
      trace(C_STATE_LEVEL, l_procedure_name, 'Inserting data into GT table');
      FORALL l_index  IN l_fv_extract_detail.first..l_fv_extract_detail.last
      INSERT INTO fv_extract_detail_gt
      VALUES l_fv_extract_detail(l_index);
      trace(C_STATE_LEVEL, l_procedure_name, 'No of rows inserted into FV_EXTRACT_DETAIL_GT: '|| SQL%ROWCOUNT );
    END IF;

    trace(C_STATE_LEVEL, l_procedure_name, 'Calling dump_gt_table');
    fv_sla_utl_processing_pkg.dump_gt_table
    (
      p_fv_extract_detail => l_fv_extract_detail,
      p_error_code        => l_gt_error_code,
      p_error_desc        => l_error_desc
    );

    IF (l_error_code <>  C_SUCCESS) OR (l_gt_error_code <> C_SUCCESS) THEN
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    trace(C_PROC_LEVEL, l_procedure_name, 'End of procedure'||l_procedure_name);

  EXCEPTION
    WHEN OTHERS THEN
      l_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error '||l_procedure_name||' :'||SQLERRM);
      l_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', l_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||l_error_desc);
      APP_EXCEPTION.RAISE_EXCEPTION();
  END po_extract;





PROCEDURE extract
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
)
IS

    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.EXTRACT';

BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------


    IF (p_application_id = 201) THEN
        po_extract(p_application_id, p_accounting_mode);

    ELSE
        RETURN;
    END IF;

    -------------------------------------------------------------------------
    l_debug_info := 'End of procedure '||l_procedure_name;
    trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------

EXCEPTION

  WHEN OTHERS THEN
     l_debug_info := 'Error in Federal SLA Processing ' || SQLERRM;
     trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :fv_sla_processing_pkg.extract'|| CRLF||
         'Error     :'||SQLERRM);
     FND_MSG_PUB.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;

END extract;

PROCEDURE preaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
) IS

l_log_module         VARCHAR2(240);
BEGIN
    NULL;
END;

PROCEDURE postprocessing
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
)
 IS

 l_procedure_name     VARCHAR2(240) := 'postprocessing';
 l_encumbered_flag    VARCHAR2(1);
 l_encumbered_amount  NUMBER;
 l_error_code         NUMBER;

BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    l_error_code := c_SUCCESS;
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_application_id='||p_application_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_accounting_mode='||p_accounting_mode);

    IF (p_application_id <> 201) THEN
      RETURN;
    END IF;

    IF (p_accounting_mode = 'F') THEN
      trace(C_STATE_LEVEL, l_procedure_name, 'FOR Loop');
      FOR gt_rec IN (SELECT p.entered_amt,
                            p.accounted_amt,
                            p.event_type_code,
                            p.header_id,
                            p.distribution_id
                       FROM xla_events_gt e,
                            po_bc_distributions p
                      WHERE e.process_status_code = 'P'
                        AND e.event_id = p.ae_event_id
                        AND p.je_source_name = 'Purchasing'
                        AND p.je_category_name = 'Requisitions'
                        AND p.distribution_type ='REQUISITION'
                        AND p.main_or_backing_code='B_REQ') LOOP
        trace(C_STATE_LEVEL, l_procedure_name, 'event_type_code='||gt_rec.event_type_code);
        IF (gt_rec.event_type_code IN ('PO_PA_RESERVED')) THEN
          l_encumbered_flag := 'N';
          l_encumbered_amount := -1*gt_rec.entered_amt;
        ELSE
          l_encumbered_flag := 'Y';
          l_encumbered_amount := gt_rec.entered_amt;
        END IF;

        trace(C_STATE_LEVEL, l_procedure_name, 'distribution_id='||gt_rec.distribution_id);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_encumbered_flag='||l_encumbered_flag);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_encumbered_amount='||l_encumbered_amount);
        UPDATE po_req_distributions_all
           SET encumbered_flag = l_encumbered_flag,
               encumbered_amount = NVL(encumbered_amount, 0) + l_encumbered_amount
         WHERE distribution_id = gt_rec.distribution_id;
      END LOOP;
    END IF;
    trace(C_STATE_LEVEL, l_procedure_name, 'END');
END;


PROCEDURE postaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
)
 IS
l_log_module         VARCHAR2(240);

BEGIN
    NULL;
END;
BEGIN
  init;
END fv_sla_po_processing_pkg;

/
