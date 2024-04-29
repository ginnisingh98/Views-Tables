--------------------------------------------------------
--  DDL for Package Body FV_SLA_AR_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SLA_AR_PROCESSING_PKG" AS
--$Header: FVXLAARB.pls 120.0.12010000.1 2010/02/10 19:35:10 sasukuma noship $

---------------------------------------------------------------------------
---------------------------------------------------------------------------

  c_FAILURE   CONSTANT  NUMBER := -1;
  c_SUCCESS   CONSTANT  NUMBER := 0;
  C_GL_APPLICATION CONSTANT NUMBER := 101;
  C_GL_APPL_SHORT_NAME CONSTANT VARCHAR2(30) := 'SQLGL';
  C_GL_FLEX_CODE   CONSTANT VARCHAR2(10) := 'GL#';
  CRLF CONSTANT VARCHAR2(1) := FND_GLOBAL.newline;
  g_path_name   CONSTANT VARCHAR2(200)  := 'fv.plsql.fvxlaarb.fv_sla_ar_processing_pkg';
  C_STATE_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_STATEMENT;
  C_PROC_LEVEL  CONSTANT  NUMBER       :=  FND_LOG.LEVEL_PROCEDURE;

  --AR Attribute Category
  TYPE ARCategoryTabType IS TABLE OF fv_ar_acc_category_map_dtl.transaction_category%TYPE INDEX BY BINARY_INTEGER;
  g_ar_category_tab ARCategoryTabType;

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

  PROCEDURE stack_error
  (
    p_program_name  IN VARCHAR2,
    p_location      IN VARCHAR2,
    p_error_message IN VARCHAR2
  )
  IS
  BEGIN
    fv_sla_utl_processing_pkg.stack_error
    (
      p_program_name  => p_program_name,
      p_location      => p_location,
      p_error_message => p_error_message
    );
  END;

  PROCEDURE init
  IS
    l_procedure_name       VARCHAR2(100) :='.init';
  BEGIN
    trace(C_STATE_LEVEL, l_procedure_name, 'Package Information');
    trace(C_STATE_LEVEL, l_procedure_name, '$Header: FVXLAARB.pls 120.0.12010000.1 2010/02/10 19:35:10 sasukuma noship $');
  END;

  PROCEDURE get_ar_transaction_category
  (
    p_org_id             IN NUMBER,
    p_rec_attribute_type IN fv_ar_acc_category_map_hdr.receivable_attribute_type%TYPE,
    p_rec_atrribute_id   IN fv_ar_acc_category_map_dtl.receivable_attribute_id%TYPE,
    p_rec_attribute_cat  OUT NOCOPY fv_ar_acc_category_map_dtl.transaction_category%TYPE,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name VARCHAR2(100) :='.get_ar_transaction_category';
    l_hash_value     NUMBER;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_org_id='||p_org_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_rec_attribute_type='||p_rec_attribute_type);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_rec_atrrinbute_id='||p_rec_atrribute_id);
    -------------------------------------------------------------------------
    l_hash_value := DBMS_UTILITY.get_hash_value
                    (
                      name => 'ORG_ID:'||p_org_id||'@*?ATTRIBUTE_TYPE:'||p_rec_attribute_type||'@*?ATTRIBUTE_ID:'||p_rec_atrribute_id||'@*?END:',
                      base => 1000,
                      hash_size => 32768
                    );

    IF g_ar_category_tab.EXISTS(l_hash_value) THEN
      p_rec_attribute_cat := g_ar_category_tab(l_hash_value);
    ELSE
      BEGIN
        SELECT d.transaction_category
          INTO p_rec_attribute_cat
          FROM fv_ar_acc_category_map_hdr h,
               fv_ar_acc_category_map_dtl d
         WHERE h.fv_sla_map_hdr_id = d.fv_sla_map_hdr_id
           AND NVL(h.org_id, -1) = NVL(p_org_id, -1)
           AND h.receivable_attribute_type = p_rec_attribute_type
           AND d.receivable_attribute_id = p_rec_atrribute_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_rec_attribute_cat := NULL;
        WHEN OTHERS THEN
          p_error_code := c_FAILURE;
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
          p_error_desc := fnd_message.get;
          stack_error (l_procedure_name, 'LEDGER_TAB', p_error_desc);
          trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:LEDGER_TAB:'||p_error_desc);
      END;
     END IF;

    IF (p_error_code = c_SUCCESS) THEN
      g_ar_category_tab(l_hash_value) := p_rec_attribute_cat;
    END IF;

    trace(C_PROC_LEVEL, l_procedure_name, 'p_rec_attribute_cat='||p_rec_attribute_cat);
    trace(C_PROC_LEVEL, l_procedure_name, 'END');
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      fv_sla_utl_processing_pkg.stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END;

  PROCEDURE get_ar_transaction_category
  (
    p_event_id           IN NUMBER,
    p_rec_attribute_cat  OUT NOCOPY fv_ar_acc_category_map_dtl.transaction_category%TYPE,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name     VARCHAR2(100) :='.get_ar_transaction_category';
    l_source_id_int_1    NUMBER;
    l_org_id             NUMBER;
    l_rec_atrribute_id   NUMBER;
    l_entity_code        xla_transaction_entities.entity_code%TYPE;
    l_rec_attribute_type fv_ar_acc_category_map_hdr.receivable_attribute_type%TYPE;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;

    p_error_code := c_SUCCESS;
    p_error_desc := NULL;
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_event_id='||p_event_id);
    -------------------------------------------------------------------------

    BEGIN
      SELECT t.source_id_int_1,
             t.entity_code
        INTO l_source_id_int_1,
             l_entity_code
        FROM xla_events e,
             xla_transaction_entities t
       WHERE e.entity_id = t.entity_id
         AND e.event_id = p_event_id;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := c_FAILURE;
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
        p_error_desc := fnd_message.get;
        stack_error (l_procedure_name, 'xla_events_tab', p_error_desc);
        trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:xla_events_tab:'||p_error_desc);
    END;

    l_rec_atrribute_id := NULL;
    IF (p_error_code = c_SUCCESS) THEN
      IF (l_entity_code = 'TRANSACTIONS') THEN
        l_rec_attribute_type := 'TT';
        BEGIN
          SELECT h.org_id,
                 h.cust_trx_type_id
            INTO l_org_id,
                 l_rec_atrribute_id
            FROM ra_customer_trx_all h
           WHERE customer_trx_id = l_source_id_int_1;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := c_FAILURE;
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
            p_error_desc := fnd_message.get;
            stack_error (l_procedure_name, 'ra_customer_trx_all_tab', p_error_desc);
            trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:ra_customer_trx_all_tab:'||p_error_desc);
        END;
      ELSIF (l_entity_code = 'RECEIPTS') THEN
        l_rec_attribute_type := 'RM';
        BEGIN
          SELECT h.org_id,
                 h.receipt_method_id
            INTO l_org_id,
                 l_rec_atrribute_id
            FROM ar_cash_receipts_all h
           WHERE h.cash_receipt_id = l_source_id_int_1;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := c_FAILURE;
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
            p_error_desc := fnd_message.get;
            stack_error (l_procedure_name, 'ar_cash_receipts_all_tab', p_error_desc);
            trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:ar_cash_receipts_all_tab:'||p_error_desc);
        END;
        l_org_id := -1;
      ELSIF (l_entity_code = 'ADJUSTMENTS') THEN
        l_rec_attribute_type := 'RA';
        BEGIN
          SELECT h.org_id,
                 h.receivables_trx_id
            INTO l_org_id,
                 l_rec_atrribute_id
            FROM ar_adjustments_all h
           WHERE h.adjustment_id = l_source_id_int_1;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := c_FAILURE;
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
            p_error_desc := fnd_message.get;
            stack_error (l_procedure_name, 'ar_adjustments_all_tab', p_error_desc);
            trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:ar_adjustments_all_tab:'||p_error_desc);
        END;
      END IF;
    END IF;

    IF (p_error_code = c_SUCCESS AND l_rec_atrribute_id IS NOT NULL) THEN
      get_ar_transaction_category
      (
        p_org_id             => l_org_id,
        p_rec_attribute_type => l_rec_attribute_type,
        p_rec_atrribute_id   => l_rec_atrribute_id,
        p_rec_attribute_cat  => p_rec_attribute_cat,
        p_error_code         => p_error_code,
        p_error_desc         => p_error_desc
      );
    END IF;

    trace(C_PROC_LEVEL, l_procedure_name, 'p_rec_attribute_cat='||p_rec_attribute_cat);
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

  PROCEDURE ar_extract
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
  IS
    l_procedure_name     VARCHAR2(100):='.AR_EXTRACT';
    l_index              NUMBER;
    l_ledger_info        fv_sla_utl_processing_pkg.LedgerRecType;
    l_error_code         NUMBER;
    l_gt_error_code      NUMBER;
    l_error_desc         VARCHAR2(1024);
    l_fund_value         VARCHAR(30);
    l_account_value      VARCHAR2(30);
    l_bfy_value          VARCHAR2(30);
    l_fv_extract_detail  fv_sla_utl_processing_pkg.fv_ref_detail;
    l_treasury_symbol_id fv_treasury_symbols.treasury_symbol_id%TYPE;
    l_treasury_symbol    fv_treasury_symbols.treasury_symbol%TYPE;
    l_fund_category      fv_fund_parameters.fund_category%TYPE;
    l_fund_status        VARCHAR2(100);
    l_fund_time_frame    fv_treasury_symbols.time_frame%TYPE;
    l_rec_attribute_cat  fv_ar_acc_category_map_dtl.transaction_category%TYPE;
    l_pya                VARCHAR2(1);
    l_pya_type           VARCHAR2(20);

    CURSOR cur_ar_inv_extract_details
    (
      c_event_id NUMBER
    )
    IS
    SELECT l.event_id,
           l.trx_line_dist_ccid,
           l.line_number
      FROM ar_cust_trx_lines_l_v l
     WHERE l.event_id = c_event_id
       AND l.trx_line_dist_account_class = 'REV';

    CURSOR cur_ar_cm_extract_details
    (
      c_event_id NUMBER
    )
    IS
    SELECT l.event_id,
           l.trx_line_dist_ccid,
           l.line_number
      FROM ar_cust_trx_lines_l_v l
     WHERE l.event_id = c_event_id
       AND l.trx_line_dist_account_class = 'REV';

    CURSOR cur_ar_rct_extract_details
    (
      c_event_id         NUMBER
    ) IS
    SELECT d.event_id,
           d.line_number,
           d.dist_code_combination_id,
           l.trx_line_dist_ccid
      FROM ar_distributions_l_v d,
           ar_cust_trx_lines_l_v l
     WHERE d.dist_source_type IN ('REC', 'ADJ')
       AND l.event_id    = d.event_id
       AND l.line_number  = d.line_number
       AND d.event_id = c_event_id
       AND NVL(d.dist_ref_mf_dist_flag||d.dist_source_table_secondary, ' ') <> 'UUPMFCHMIAR';

    CURSOR cur_misc_rct_extract_details
    (
      c_event_id NUMBER
    )
    IS
    SELECT arv.event_id,
           arv.line_number,
           arv.dist_code_combination_id
      FROM ar_distributions_l_v arv
     WHERE arv.event_id = c_event_id
       AND dist_source_type = 'MISCCASH'
       AND dist_mfar_additional_entry = 'Y'
       AND dist_paired_source_type = 'CLEARED';



  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, 'Begin of procedure '||l_procedure_name);
    trace(C_STATE_LEVEL, l_procedure_name, 'Accounting Mode: ' || p_accounting_mode);
    trace(C_STATE_LEVEL, l_procedure_name, 'Application ID:  ' || p_application_id);

    /* Validate the application ID */
    IF (p_application_id <> 222) THEN
        RETURN;
    END IF;

    /* Validate the accounting mode */
    IF (p_accounting_mode NOT IN ('D', 'F')) THEN
        RETURN;
    END IF;

    l_index:=0;
    FOR event_rec IN (SELECT *
                        FROM xla_events_gt
                       WHERE application_id = p_application_id) LOOP
      fv_sla_utl_processing_pkg.get_ledger_info
      (
        p_ledger_id  => event_rec.ledger_id,
        p_ledger_rec => l_ledger_info,
        p_error_code => l_error_code,
        p_error_desc => l_error_desc
      );

      IF (l_error_code = c_SUCCESS) THEN
        get_ar_transaction_category
        (
          p_event_id           => event_rec.event_id,
          p_rec_attribute_cat  => l_rec_attribute_cat,
          p_error_code         => l_error_code,
          p_error_desc         => l_error_desc
        );
      END IF;


      IF (l_error_code = c_SUCCESS) THEN
        trace(C_STATE_LEVEL, l_procedure_name, 'event_rec.event_type_code: ' || event_rec.event_type_code);
        IF (event_rec.event_type_code IN ('INV_CREATE',
                                          'INV_UPDATE',
                                          'DM_CREATE',
                                          'DM_UPDATE',
                                          'CM_CREATE',
                                          'CM_UPDATE'
                                          )) THEN
          FOR inv_rec IN cur_ar_inv_extract_details(event_rec.event_id) LOOP
            IF (l_error_code = C_SUCCESS) THEN
              trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_segment_values');
              trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||l_ledger_info.ledger_id);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_ccid='||inv_rec.trx_line_dist_ccid);
              fv_sla_utl_processing_pkg.get_segment_values
              (
                p_ledger_id     => l_ledger_info.ledger_id,
                p_ccid          => inv_rec.trx_line_dist_ccid,
                p_fund_value    => l_fund_value,
                p_account_value => l_account_value,
                p_bfy_value     => l_bfy_value,
                p_error_code    => l_error_code,
                p_error_desc    => l_error_desc
              );
            END IF;

            IF (l_error_code = C_SUCCESS) THEN
              trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||l_fund_value);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_account_value='||l_account_value);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_bfy_value='||l_bfy_value);

              trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_fund_details');
              trace(C_STATE_LEVEL, l_procedure_name, 'p_application_id='||p_application_id);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||l_ledger_info.ledger_id);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||l_fund_value);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_gl_date='||event_rec.event_date);
              fv_sla_utl_processing_pkg.get_fund_details
              (
                p_application_id     => p_application_id,
                p_ledger_id          => l_ledger_info.ledger_id,
                p_fund_value         => l_fund_value,
                p_gl_date            => event_rec.event_date,
                p_fund_category      => l_fund_category,
                p_fund_status        => l_fund_status,
                p_fund_time_frame    => l_fund_time_frame,
                p_treasury_symbol_id => l_treasury_symbol_id,
                p_treasury_symbol    => l_treasury_symbol,
                p_error_code         => l_error_code,
                p_error_desc         => l_error_desc
              );
            END IF;

            IF (l_error_code = C_SUCCESS) THEN
              l_index := l_index + 1;
              l_fv_extract_detail(l_index).fund_value     := l_fund_value;
              l_fv_extract_detail(l_index).event_id       := event_rec.event_id;
              l_fv_extract_detail(l_index).line_number    := inv_rec.line_number;
              l_fv_extract_detail(l_index).application_id := p_application_id;
              l_fv_extract_detail(l_index).prior_year_flag := 'N';
              l_fv_extract_detail(l_index).fund_category  := l_fund_category;
              l_fv_extract_detail(l_index).fund_expired_status := l_fund_status;
              l_fv_extract_detail(l_index).fund_time_frame := l_fund_time_frame;
              l_fv_extract_detail(l_index).ar_transaction_category := l_rec_attribute_cat;
            END IF;
          END LOOP;
        ELSIF (event_rec.event_type_code IN ('RECP_CREATE',
                                             'RECP_UPDATE',
                                             'RECP_REVERSE',
                                             'ADJ_CREATE')) THEN
          FOR rec_rec IN cur_ar_rct_extract_details (event_rec.event_id) LOOP
            IF (l_error_code = C_SUCCESS) THEN
              trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_segment_values');
              trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||l_ledger_info.ledger_id);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_ccid='||rec_rec.trx_line_dist_ccid);
              fv_sla_utl_processing_pkg.get_segment_values
              (
                p_ledger_id     => l_ledger_info.ledger_id,
                p_ccid          => rec_rec.trx_line_dist_ccid,
                p_fund_value    => l_fund_value,
                p_account_value => l_account_value,
                p_bfy_value     => l_bfy_value,
                p_error_code    => l_error_code,
                p_error_desc    => l_error_desc
              );
            END IF;

            IF (l_error_code = C_SUCCESS) THEN
              trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||l_fund_value);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_account_value='||l_account_value);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_bfy_value='||l_bfy_value);

              trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_fund_details');
              trace(C_STATE_LEVEL, l_procedure_name, 'p_application_id='||p_application_id);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||l_ledger_info.ledger_id);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||l_fund_value);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_gl_date='||event_rec.event_date);
              fv_sla_utl_processing_pkg.get_fund_details
              (
                p_application_id     => p_application_id,
                p_ledger_id          => l_ledger_info.ledger_id,
                p_fund_value         => l_fund_value,
                p_gl_date            => event_rec.event_date,
                p_fund_category      => l_fund_category,
                p_fund_status        => l_fund_status,
                p_fund_time_frame    => l_fund_time_frame,
                p_treasury_symbol_id => l_treasury_symbol_id,
                p_treasury_symbol    => l_treasury_symbol,
                p_error_code         => l_error_code,
                p_error_desc         => l_error_desc
              );
            END IF;

            IF (l_error_code = C_SUCCESS) THEN
              l_pya := 'N';
              fv_sla_utl_processing_pkg.get_prior_year_status
              (
                p_application_id => p_application_id,
                p_ledger_id      => l_ledger_info.ledger_id,
                p_bfy_value      => l_bfy_value,
                p_gl_date        => event_rec.event_date,
                p_pya            => l_pya,
                p_pya_type       => l_pya_type,
                p_error_code     => l_error_code,
                p_error_desc     => l_error_desc
              );
            END IF;

            IF (l_error_code = C_SUCCESS) THEN
              l_index := l_index + 1;
              l_fv_extract_detail(l_index).fund_value     := l_fund_value;
              l_fv_extract_detail(l_index).event_id       := event_rec.event_id;
              l_fv_extract_detail(l_index).line_number    := rec_rec.line_number;
              l_fv_extract_detail(l_index).application_id := p_application_id;
              l_fv_extract_detail(l_index).prior_year_flag := l_pya;
              l_fv_extract_detail(l_index).fund_category  := l_fund_category;
              l_fv_extract_detail(l_index).fund_expired_status := l_fund_status;
              l_fv_extract_detail(l_index).fund_time_frame := l_fund_time_frame;
              l_fv_extract_detail(l_index).ar_transaction_category := l_rec_attribute_cat;
            END IF;
          END LOOP;
        ELSIF (event_rec.event_type_code IN ('MISC_RECP_CREATE', 'MISC_RECP_UPDATE', 'MISC_RECP_REVERSE')) THEN
          FOR misc_rec IN cur_misc_rct_extract_details (event_rec.event_id) LOOP
            IF (l_error_code = C_SUCCESS) THEN
              trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_segment_values');
              trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||l_ledger_info.ledger_id);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_ccid='||misc_rec.dist_code_combination_id);
              fv_sla_utl_processing_pkg.get_segment_values
              (
                p_ledger_id     => l_ledger_info.ledger_id,
                p_ccid          => misc_rec.dist_code_combination_id,
                p_fund_value    => l_fund_value,
                p_account_value => l_account_value,
                p_bfy_value     => l_bfy_value,
                p_error_code    => l_error_code,
                p_error_desc    => l_error_desc
              );
            END IF;

            IF (l_error_code = C_SUCCESS) THEN
              trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||l_fund_value);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_account_value='||l_account_value);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_bfy_value='||l_bfy_value);

              trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_fund_details');
              trace(C_STATE_LEVEL, l_procedure_name, 'p_application_id='||p_application_id);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||l_ledger_info.ledger_id);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||l_fund_value);
              trace(C_STATE_LEVEL, l_procedure_name, 'p_gl_date='||event_rec.event_date);
              fv_sla_utl_processing_pkg.get_fund_details
              (
                p_application_id     => p_application_id,
                p_ledger_id          => l_ledger_info.ledger_id,
                p_fund_value         => l_fund_value,
                p_gl_date            => event_rec.event_date,
                p_fund_category      => l_fund_category,
                p_fund_status        => l_fund_status,
                p_fund_time_frame    => l_fund_time_frame,
                p_treasury_symbol_id => l_treasury_symbol_id,
                p_treasury_symbol    => l_treasury_symbol,
                p_error_code         => l_error_code,
                p_error_desc         => l_error_desc
              );
            END IF;
            IF (l_error_code = C_SUCCESS) THEN
              l_pya := 'N';
              fv_sla_utl_processing_pkg.get_prior_year_status
              (
                p_application_id => p_application_id,
                p_ledger_id      => l_ledger_info.ledger_id,
                p_bfy_value      => l_bfy_value,
                p_gl_date        => event_rec.event_date,
                p_pya            => l_pya,
                p_pya_type       => l_pya_type,
                p_error_code     => l_error_code,
                p_error_desc     => l_error_desc
              );
            END IF;

            IF (l_error_code = C_SUCCESS) THEN
              l_index := l_index + 1;
              l_fv_extract_detail(l_index).fund_value     := l_fund_value;
              l_fv_extract_detail(l_index).event_id       := event_rec.event_id;
              l_fv_extract_detail(l_index).line_number    := misc_rec.line_number;
              l_fv_extract_detail(l_index).application_id := p_application_id;
              l_fv_extract_detail(l_index).prior_year_flag := l_pya;
              l_fv_extract_detail(l_index).fund_category  := l_fund_category;
              l_fv_extract_detail(l_index).fund_expired_status := l_fund_status;
              l_fv_extract_detail(l_index).fund_time_frame := l_fund_time_frame;
              l_fv_extract_detail(l_index).ar_transaction_category := l_rec_attribute_cat;
            END IF;
          END LOOP;
        END IF;
      END IF;
    END LOOP;

    IF (l_error_code = C_SUCCESS) THEN
       FORALL l_index IN l_fv_extract_detail .first..l_fv_extract_detail.last
          INSERT INTO fv_extract_detail_gt VALUES l_fv_extract_detail(l_index);
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
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR encountered in Federal AR SLA Processing: ' || SQLERRM);
      FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE' , 'Procedure :fv_sla_processing_pkg.ar_extract'|| CRLF||
      'Error     :'||SQLERRM);
      FND_MSG_PUB.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END ar_extract;

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


    IF (p_application_id = 222) THEN
        ar_extract(p_application_id, p_accounting_mode);
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
  BEGIN
    NULL;
  END;

  PROCEDURE postprocessing
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
  IS
  BEGIN
    NULL;
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
  BEGIN
    NULL;
  END;
BEGIN
  init;
END fv_sla_ar_processing_pkg;

/
