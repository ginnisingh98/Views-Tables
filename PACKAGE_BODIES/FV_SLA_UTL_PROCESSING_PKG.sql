--------------------------------------------------------
--  DDL for Package Body FV_SLA_UTL_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SLA_UTL_PROCESSING_PKG" AS
--$Header: FVXLAUTB.pls 120.0.12010000.2 2010/03/24 19:04:47 sasukuma noship $

---------------------------------------------------------------------------
---------------------------------------------------------------------------

  c_FAILURE   CONSTANT  NUMBER := -1;
  c_SUCCESS   CONSTANT  NUMBER := 0;
  C_GL_APPLICATION CONSTANT NUMBER := 101;
  C_GL_APPL_SHORT_NAME CONSTANT VARCHAR2(30) := 'SQLGL';
  C_GL_FLEX_CODE   CONSTANT VARCHAR2(10) := 'GL#';
  CRLF CONSTANT VARCHAR2(1) := FND_GLOBAL.newline;
  g_path_name   CONSTANT VARCHAR2(200)  := 'fv.plsql.fvxlautb.fv_sla_utl_processing_pkg';
  C_STATE_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_STATEMENT;
  C_PROC_LEVEL  CONSTANT  NUMBER       :=  FND_LOG.LEVEL_PROCEDURE;
  g_log_level   CONSTANT NUMBER         := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_adjustment_type VARCHAR2(30);

  g_ledger_tab LedgerTabType;


  TYPE fv_extract_rec IS RECORD
  (
     event_id NUMBER,
     line_number NUMBER,
     fund_value fv_extract_detail_gt.fund_value%TYPE := 'X',
     fund_category fv_extract_detail_gt.fund_category%TYPE DEFAULT 'N',
     fund_expired_status fv_extract_detail_gt.fund_expired_status%TYPE DEFAULT 'NONE',
     fund_time_frame fv_extract_detail_gt.fund_time_frame%TYPE DEFAULT 'NONE',
     prior_year_flag fv_extract_detail_gt.prior_year_flag%TYPE DEFAULT 'N',
     account_rule fv_extract_detail_gt.account_rule%TYPE DEFAULT 'DEFAULT',
     receivable_with_advance fv_extract_detail_gt.receivable_with_advance%TYPE DEFAULT 'N'
  );


  PROCEDURE trace
  (
    p_level             IN NUMBER,
    p_procedure_name    IN VARCHAR2,
    p_debug_info        IN VARCHAR2
  )
  IS
  BEGIN
    IF (p_level >= g_log_level ) THEN
      FND_LOG.STRING(p_level, p_procedure_name, p_debug_info);
    END IF;

  END trace;

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

  PROCEDURE init
  IS
    l_procedure_name       VARCHAR2(100) :='.init';
  BEGIN
    trace(C_STATE_LEVEL, l_procedure_name, 'Package Information');
    trace(C_STATE_LEVEL, l_procedure_name, '$Header: FVXLAUTB.pls 120.0.12010000.2 2010/03/24 19:04:47 sasukuma noship $');
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
    p_fv_extract_detail.ent_charge_amount := 0;
    p_fv_extract_detail.acc_charge_amount := 0;
    p_fv_extract_detail.ent_unpaid_exp_amount := 0;
    p_fv_extract_detail.acc_unpaid_exp_amount := 0;
    p_fv_extract_detail.ent_paid_exp_amount := 0;
    p_fv_extract_detail.acc_paid_exp_amount := 0;
  END;

  /*
  ----------------------------------------------------------------------------
  -- This procedure is used to get the segment values for a specific ccid   --
  -- Returns the fund (balancing), account and bfy values specfic to the    --
  -- ccid                                                                   --
  ----------------------------------------------------------------------------
  */
  PROCEDURE get_segment_values
  (
    p_ledger_id     IN NUMBER,
    p_ccid          IN NUMBER,
    p_fund_value    OUT NOCOPY VARCHAR2,
    p_account_value OUT NOCOPY VARCHAR2,
    p_bfy_value     OUT NOCOPY VARCHAR2,
    p_error_code    OUT NOCOPY NUMBER,
    p_error_desc    OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name       VARCHAR2(100) :='.get_fund_and_account_value';

    l_result				       BOOLEAN;
    l_ledger_info          LedgerRecType;
    l_no_of_segments       NUMBER;
    l_segments             fnd_flex_ext.SegmentArray;
  BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;

    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ccid='||p_ccid);

    -- Call Ledger Info to get Chart of Accounts id for the Ledger
    l_ledger_info := g_ledger_tab(p_ledger_id);

    -- Call FND API to split the segments into l_segments
    l_result := fnd_flex_ext.get_segments
                (
                  C_GL_APPL_SHORT_NAME,
                  C_GL_FLEX_CODE,
                  l_ledger_info.coaid,
                  p_ccid,
                  l_no_of_segments,
                  l_segments
                );

    trace(C_STATE_LEVEL, l_procedure_name, 'l_no_of_segments='||l_no_of_segments);

    p_fund_value    := l_segments(l_ledger_info.balancing_seg_num);
    p_account_value := l_segments(l_ledger_info.accounting_seg_num);
    p_bfy_value     := l_segments(l_ledger_info.bfy_segment_num);

    trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||p_fund_value);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_account_value='||p_account_value);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_bfy_value='||p_bfy_value);
    trace(C_PROC_LEVEL, l_procedure_name, 'END');

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END get_segment_values;

  /*
  ----------------------------------------------------------------------------
  -- This procedure is used to get the Ledger Information given a ledger_id --
  -- If the ledger_id is not in cache, the ledger information is obtained   --
  -- form the tables and cached for future calls.                           --
  ----------------------------------------------------------------------------
  */
  PROCEDURE get_ledger_info
  (
    p_ledger_id  IN NUMBER,
    p_ledger_rec OUT NOCOPY LedgerRecType,
    p_error_code OUT NOCOPY NUMBER,
    p_error_desc OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name VARCHAR2(100) :='.get_ledger_info';
    l_ledger_rec LedgerRecType;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;

    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id = '||p_ledger_id);

    -- See if the ledger information is in Cache
    IF g_ledger_tab.EXISTS(p_ledger_id) THEN
      l_ledger_rec := g_ledger_tab(p_ledger_id);
    ELSE
      trace(C_STATE_LEVEL, l_procedure_name, 'Getting Ledger Information');
      BEGIN
        SELECT l.ledger_id,
               l.chart_of_accounts_id,
               l.name,
               l.currency_code
          INTO l_ledger_rec.ledger_id,
               l_ledger_rec.coaid,
               l_ledger_rec.ledger_name,
               l_ledger_rec.currency_code
          FROM gl_ledgers l
         WHERE ledger_id = p_ledger_id;
        trace(C_STATE_LEVEL, l_procedure_name, 'chart_of_accounts_id='||l_ledger_rec.coaid);
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := c_FAILURE;
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
          p_error_desc := fnd_message.get;
          stack_error (l_procedure_name, 'SELECT_GL_LEDGERS', p_error_desc);
          trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_GL_LEDGERS:'||p_error_desc);
      END;

      IF (p_error_code = c_SUCCESS) THEN
        -- Get the GL ACCOUNT segment num and name
        BEGIN
          SELECT b.segment_num,
                 b.application_column_name
            INTO l_ledger_rec.accounting_seg_num,
                 l_ledger_rec.accounting_seg_name
            FROM fnd_segment_attribute_values a,
                 fnd_id_flex_segments b
           WHERE a.application_id = b.application_id
             AND a.id_flex_code = b.id_flex_code
             AND a.id_flex_num = b.id_flex_num
             AND a.application_column_name = b.application_column_name
             AND a.segment_attribute_type = 'GL_ACCOUNT'
             AND a.attribute_value = 'Y'
             AND b.application_id = C_GL_APPLICATION
             AND b.id_flex_code = C_GL_FLEX_CODE
             AND b.id_flex_num = l_ledger_rec.coaid;
        trace(C_STATE_LEVEL, l_procedure_name, 'accounting_seg_num='||l_ledger_rec.accounting_seg_num);
        trace(C_STATE_LEVEL, l_procedure_name, 'accounting_seg_name='||l_ledger_rec.accounting_seg_name);
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := c_FAILURE;
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
            p_error_desc := fnd_message.get;
            stack_error (l_procedure_name, 'SELECT_FND_ID_FLEX_SEGMENTS (GL_ACCOUNT)', p_error_desc);
            trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_FND_ID_FLEX_SEGMENTS (GL_ACCOUNT):'||p_error_desc);
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE' , 'Error in Getting Accounting Segment.'||CRLF||
                                  'Accounting Segment is not Defined for the Ledger '||l_ledger_rec.ledger_name);
            p_error_desc := fnd_message.get;
            stack_error (l_procedure_name, 'SELECT_FND_ID_FLEX_SEGMENTS (GL_ACCOUNT)', p_error_desc);
            l_ledger_rec.balancing_seg_num := NULL;
            l_ledger_rec.balancing_seg_name := NULL;
        END;
      END IF;

      IF (p_error_code = c_SUCCESS) THEN
        -- Get the GL BALANCING segment num and name
        BEGIN
          SELECT b.segment_num,
                 b.application_column_name
            INTO l_ledger_rec.balancing_seg_num,
                 l_ledger_rec.balancing_seg_name
            FROM fnd_segment_attribute_values a,
                 fnd_id_flex_segments b
           WHERE a.application_id = b.application_id
             AND a.id_flex_code = b.id_flex_code
             AND a.id_flex_num = b.id_flex_num
             AND a.application_column_name = b.application_column_name
             AND a.segment_attribute_type = 'GL_BALANCING'
             AND a.attribute_value = 'Y'
             AND b.application_id = C_GL_APPLICATION
             AND b.id_flex_code = C_GL_FLEX_CODE
             AND b.id_flex_num = l_ledger_rec.coaid;
        trace(C_STATE_LEVEL, l_procedure_name, 'balancing_segment_num='||l_ledger_rec.balancing_seg_num);
        trace(C_STATE_LEVEL, l_procedure_name, 'balancing_segment_name='||l_ledger_rec.balancing_seg_name);
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := c_FAILURE;
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
            p_error_desc := fnd_message.get;
            stack_error (l_procedure_name, 'SELECT_FND_ID_FLEX_SEGMENTS (GL_BALANCING)', p_error_desc);
            trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_FND_ID_FLEX_SEGMENTS (GL_BALANCING):'||p_error_desc);
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE' , 'Error in Getting Balancing Segment.'||CRLF||
                                  'Balancing Segment is not Defined for the Ledger '||l_ledger_rec.ledger_name);
            p_error_desc := fnd_message.get;
            stack_error (l_procedure_name, 'SELECT_FND_ID_FLEX_SEGMENTS (GL_BALANCING)', p_error_desc);
            l_ledger_rec.balancing_seg_num := NULL;
            l_ledger_rec.balancing_seg_name := NULL;
        END;
      END IF;

      IF (p_error_code = c_SUCCESS) THEN
        -- Get the BFY segment num and bfy id
        BEGIN
          SELECT b.segment_num,
                 a.fyr_segment_id
            INTO l_ledger_rec.bfy_segment_num,
                 l_ledger_rec.fyr_segment_id
            FROM fv_pya_fiscalyear_segment a,
                 fnd_id_flex_segments b
           WHERE set_of_books_id = p_ledger_id
             AND a.application_column_name = b.application_column_name
             AND b.application_id = C_GL_APPLICATION
             AND b.id_flex_code = C_GL_FLEX_CODE
             AND b.id_flex_num = l_ledger_rec.coaid;
        trace(C_STATE_LEVEL, l_procedure_name, 'bfy_segment_num='||l_ledger_rec.bfy_segment_num);
        trace(C_STATE_LEVEL, l_procedure_name, 'fyr_segment_id='||l_ledger_rec.fyr_segment_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_error_code := c_FAILURE;
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
            p_error_desc := fnd_message.get;
            stack_error (l_procedure_name, 'SELECT_FV_PYA_FISCALYEAR_SEGMENT', p_error_desc);
            trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_FV_PYA_FISCALYEAR_SEGMENT:'||p_error_desc);
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE' , 'Error in setup of Define Federal Options Form.'||CRLF||
                                  'BFY Segment is not Defined for the Ledger '||l_ledger_rec.ledger_name);
            p_error_desc := fnd_message.get;
            stack_error (l_procedure_name, 'SELECT_FV_PYA_FISCALYEAR_SEGMENT', p_error_desc);
            trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_FV_PYA_FISCALYEAR_SEGMENT:'||p_error_desc);
            l_ledger_rec.bfy_segment_num := NULL;
            l_ledger_rec.fyr_segment_id := NULL;
        END;
      END IF;

      IF (p_error_code = c_SUCCESS) THEN
        g_ledger_tab(p_ledger_id) := l_ledger_rec;
      END IF;
    END IF;

    IF (p_error_code = c_SUCCESS) THEN
      p_ledger_rec := l_ledger_rec;
    END IF;

    trace(C_STATE_LEVEL, l_procedure_name, 'END');
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END;


  /*
  ----------------------------------------------------------------------------
  -- This procedure gets the fund information from Federal tables for a     --
  -- specific fund                                                          --
  ----------------------------------------------------------------------------
  */
  PROCEDURE get_fund_details
  (
    p_application_id     IN  NUMBER,
    p_ledger_id          IN  NUMBER,
    p_fund_value         IN  VARCHAR2,
    p_gl_date            IN  DATE,
    p_fund_category      OUT NOCOPY fv_fund_parameters.fund_category%TYPE,
    p_fund_status        OUT NOCOPY VARCHAR2,
    p_fund_time_frame    OUT NOCOPY fv_treasury_symbols.time_frame%TYPE,
    p_treasury_symbol_id OUT NOCOPY fv_fund_parameters.treasury_symbol_id%TYPE,
    p_treasury_symbol    OUT NOCOPY fv_treasury_symbols.treasury_symbol%TYPE,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name               VARCHAR2(100) :='.get_fund_details';

    CURSOR c_get_fund_details IS
    SELECT a.fund_category,
           a.fund_expire_date,
           b.time_frame,
           a.treasury_symbol_id,
           b.treasury_symbol
      FROM fv_fund_parameters a,
           fv_treasury_symbols b
     WHERE fund_value=p_fund_value
       AND a.treasury_symbol_id = b.treasury_symbol_id
       AND a.set_of_books_id = p_ledger_id;

    l_fund_details            c_get_fund_details%ROWTYPE;

  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;

    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_application_id='||p_application_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||p_fund_value);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_gl_date='||p_gl_date);

    p_fund_status    := NULL;
    p_fund_category  := NULL;
    p_fund_time_frame := NULL;

    -- get the fund category and expiration date
     OPEN c_get_fund_details;
    FETCH c_get_fund_details
     INTO l_fund_details;

    IF c_get_fund_details%FOUND THEN
      p_treasury_symbol_id := l_fund_details.treasury_symbol_id;
      p_treasury_symbol := l_fund_details.treasury_symbol;
      -- fund category
      IF p_application_id in (201, 707) THEN
        IF l_fund_details.fund_category IN ('A','S') THEN
          p_fund_category := 'A';
        ELSIF l_fund_details.fund_category IN ('B','T') THEN
          p_fund_category := 'B';
        ELSE
          p_fund_category := 'C';
        END IF;
      ELSIF p_application_id IN (200, 222) THEN
        p_fund_category := l_fund_details.fund_category;
      END IF;

      -- fund expired
      IF l_fund_details.fund_expire_date < p_gl_date THEN
        p_fund_status := 'Expired';
      ELSE
        p_fund_status := 'Unexpired';
      END IF;

      IF (p_application_id = 202) THEN
        p_fund_time_frame := l_fund_details.time_frame;
      END IF;
    END IF;
    CLOSE c_get_fund_details;

    trace(C_PROC_LEVEL, l_procedure_name, 'END');
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END get_fund_details;

  PROCEDURE get_prior_year_status
  (
    p_application_id IN NUMBER,
    p_ledger_id      IN NUMBER,
    p_bfy_value      IN VARCHAR2,
    p_gl_date        IN DATE,
    p_pya            OUT NOCOPY VARCHAR2,
    p_pya_type       OUT NOCOPY VARCHAR2,
    p_error_code     OUT NOCOPY NUMBER,
    p_error_desc     OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name   VARCHAR2(100) := '.get_prior_year_status';
    l_transaction_year gl_period_statuses.period_year%TYPE;
    l_bfy_map_year     fv_pya_fiscalyear_map.period_year%TYPE;
    l_ledger_info      LedgerRecType;

  BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;

    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_application_id='||p_application_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_bfy_value='||p_bfy_value);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_gl_date='||p_gl_date);
    -------------------------------------------------------------------------

    get_ledger_info
    (
      p_ledger_id  => p_ledger_id,
      p_ledger_rec => l_ledger_info,
      p_error_code => p_error_code,
      p_error_desc => p_error_desc
    );

    IF (p_error_code = c_SUCCESS) THEN
      BEGIN
        SELECT period_year
          INTO l_bfy_map_year
          FROM fv_pya_fiscalyear_map
         WHERE set_of_books_id = p_ledger_id
          AND fyr_segment_id = l_ledger_info.fyr_segment_id
          AND fyr_segment_value = p_bfy_value;
        trace(C_STATE_LEVEL, l_procedure_name, 'l_bfy_map_year='||l_bfy_map_year);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_error_code := c_FAILURE;
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE' , 'Error in setup of Define Federal Options Form.'||CRLF||
                                'Segment Mapping is missing for the Ledger '||l_ledger_info.ledger_name||'. '||CRLF||
                                'Mapping of BFY Year '||p_bfy_value||' is missing.');
          p_error_desc := fnd_message.get;
          stack_error (l_procedure_name, 'SELECT_FV_PYA_FISCALYEAR_MAP', p_error_desc);
          trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_FV_PYA_FISCALYEAR_MAP:'||p_error_desc);
        WHEN OTHERS THEN
          p_error_code := c_FAILURE;
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
          p_error_desc := fnd_message.get;
          stack_error (l_procedure_name, 'SELECT_FV_PYA_FISCALYEAR_MAP', p_error_desc);
          trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_FV_PYA_FISCALYEAR_MAP:'||p_error_desc);
      END;
    END IF;

    IF (p_error_code = c_SUCCESS) THEN
      BEGIN
        SELECT period_year
          INTO l_transaction_year
          FROM gl_period_statuses
         WHERE ledger_id = p_ledger_id
           AND application_id = p_application_id
           AND trunc(p_gl_date) BETWEEN start_date AND end_date
           AND adjustment_period_flag='N';
        trace(C_STATE_LEVEL, l_procedure_name, 'l_transaction_year='||l_transaction_year);
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := c_FAILURE;
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
          p_error_desc := fnd_message.get;
          stack_error (l_procedure_name, 'SELECT_GL_PERIOD_STATUSES', p_error_desc);
          trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_GL_PERIOD_STATUSES:'||p_error_desc);
      END;
    END IF;

    IF (p_error_code = c_SUCCESS) THEN
      p_pya_type := NULL;
      IF l_transaction_year <> l_bfy_map_year THEN
        IF l_transaction_year > l_bfy_map_year THEN
          p_pya_type := 'Upward';
        ELSIF l_transaction_year < l_bfy_map_year THEN
          p_pya_type := 'Downward';
        END IF;
        p_pya := 'Y';
      ELSE
        p_pya := 'N';
      END IF;
    END IF;

    trace(C_PROC_LEVEL, l_procedure_name, 'p_pya='||p_pya);
    trace(C_PROC_LEVEL, l_procedure_name, 'p_pya_type='||p_pya_type);
    trace(C_PROC_LEVEL, l_procedure_name, 'END');
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END get_prior_year_status;


  PROCEDURE dump_gt_table
  (
    p_fv_extract_detail IN fv_ref_detail,
    p_error_code OUT NOCOPY NUMBER,
    p_error_desc OUT NOCOPY VARCHAR2
  )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_procedure_name VARCHAR2(100) :='.dump_gt_table';
    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;

    IF (p_fv_extract_detail.count = 0) THEN
      RETURN;
    END IF;

    IF (l_debug = 'Y') THEN
      FOR i IN p_fv_extract_detail.first..p_fv_extract_detail.last LOOP
        INSERT INTO fv_extract_detail_gt_logs
        (
          event_id,
          line_number,
          application_id,
          fund_value,
          fund_category,
          fund_expired_status,
          prior_year_flag,
          adjustment_type,
          net_pya_adj_amt,
          entered_pya_amt,
          entered_pya_diff_amt,
          anticipation,
          anticipated_amt,
          unanticipated_amt,
          tcf_amt,
          unexpended_obligation,
          paid_unexpended_obligation,
          paid_received_amt,
          unpaid_unexpended_obligation,
          unpaid_received_amt,
          unpaid_open_amt,
          fund_time_frame,
          rcv_parent_sub_ledger_id,
          account_valid_flag,
          account_rule,
          old_ccid,
          receivable_with_advance,
          ent_commitment_amount,
          ent_unpaid_obl_amount,
          acc_commitment_amount,
          acc_unpaid_obl_amount,
          ent_unpaid_obl_pya_amount,
          acc_unpaid_obl_pya_amount,
          ent_unpaid_obl_pya_off_amount,
          acc_unpaid_obl_pya_off_amount,
          ent_anticipated_budget_amount,
          acc_anticipated_budget_amount,
          ent_unanticipated_bud_amount,
          acc_unanticipated_bud_amount,
          ent_unreserved_budget_amount,
          acc_unreserved_budget_amount,
          ent_charge_amount,
          acc_charge_amount,
          ent_unpaid_exp_amount,
          acc_unpaid_exp_amount,
          ent_paid_exp_amount,
          acc_paid_exp_amount,
          ar_transaction_category
        )
        VALUES
        (
          p_fv_extract_detail(i).event_id,
          p_fv_extract_detail(i).line_number,
          p_fv_extract_detail(i).application_id,
          p_fv_extract_detail(i).fund_value,
          p_fv_extract_detail(i).fund_category,
          p_fv_extract_detail(i).fund_expired_status,
          p_fv_extract_detail(i).prior_year_flag,
          p_fv_extract_detail(i).adjustment_type,
          p_fv_extract_detail(i).net_pya_adj_amt,
          p_fv_extract_detail(i).entered_pya_amt,
          p_fv_extract_detail(i).entered_pya_diff_amt,
          p_fv_extract_detail(i).anticipation,
          p_fv_extract_detail(i).anticipated_amt,
          p_fv_extract_detail(i).unanticipated_amt,
          p_fv_extract_detail(i).tcf_amt,
          p_fv_extract_detail(i).unexpended_obligation,
          p_fv_extract_detail(i).paid_unexpended_obligation,
          p_fv_extract_detail(i).paid_received_amt,
          p_fv_extract_detail(i).unpaid_unexpended_obligation,
          p_fv_extract_detail(i).unpaid_received_amt,
          p_fv_extract_detail(i).unpaid_open_amt,
          p_fv_extract_detail(i).fund_time_frame,
          p_fv_extract_detail(i).rcv_parent_sub_ledger_id,
          p_fv_extract_detail(i).account_valid_flag,
          p_fv_extract_detail(i).account_rule,
          p_fv_extract_detail(i).old_ccid,
          p_fv_extract_detail(i).receivable_with_advance,
          p_fv_extract_detail(i).ent_commitment_amount,
          p_fv_extract_detail(i).ent_unpaid_obl_amount,
          p_fv_extract_detail(i).acc_commitment_amount,
          p_fv_extract_detail(i).acc_unpaid_obl_amount,
          p_fv_extract_detail(i).ent_unpaid_obl_pya_amount,
          p_fv_extract_detail(i).acc_unpaid_obl_pya_amount,
          p_fv_extract_detail(i).ent_unpaid_obl_pya_off_amount,
          p_fv_extract_detail(i).acc_unpaid_obl_pya_off_amount,
          p_fv_extract_detail(i).ent_anticipated_budget_amount,
          p_fv_extract_detail(i).acc_anticipated_budget_amount,
          p_fv_extract_detail(i).ent_unanticipated_bud_amount,
          p_fv_extract_detail(i).acc_unanticipated_bud_amount,
          p_fv_extract_detail(i).ent_unreserved_budget_amount,
          p_fv_extract_detail(i).acc_unreserved_budget_amount,
          p_fv_extract_detail(i).ent_charge_amount,
          p_fv_extract_detail(i).acc_charge_amount,
          p_fv_extract_detail(i).ent_unpaid_exp_amount,
          p_fv_extract_detail(i).acc_unpaid_exp_amount,
          p_fv_extract_detail(i).ent_paid_exp_amount,
          p_fv_extract_detail(i).acc_paid_exp_amount,
          p_fv_extract_detail(i).ar_transaction_category
        );
      END LOOP;
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END;


  PROCEDURE get_sla_doc_balances
  (
    p_called_from        IN VARCHAR2,
    p_trx_amount         IN NUMBER,
    p_ordered_amount     IN NUMBER,
    p_delivered_amount   IN NUMBER,
    p_billed_amount      IN NUMBER,
    p_4801_bal           OUT NOCOPY NUMBER,
    p_4802_bal           OUT NOCOPY NUMBER,
    p_4901_bal           OUT NOCOPY NUMBER,
    p_4902_bal           OUT NOCOPY NUMBER,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name     VARCHAR2(100) :='.get_sla_doc_balances';
    l_delivered_amt      NUMBER;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;

    p_error_code := c_SUCCESS;
    p_error_desc := NULL;
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_called_from='||p_called_from);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_trx_amount='||p_trx_amount);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ordered_amount='||p_ordered_amount);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_delivered_amount='||p_delivered_amount);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_billed_amount='||p_billed_amount);
    -------------------------------------------------------------------------

    p_4801_bal := 0;
    p_4802_bal := 0;
    p_4901_bal := 0;
    p_4902_bal := 0;

    IF (p_called_from = 'CST') THEN
      l_delivered_amt := p_delivered_amount - p_trx_amount;
      trace(C_STATE_LEVEL, l_procedure_name, 'l_delivered_amt='||l_delivered_amt);
      IF (NVL(l_delivered_amt, 0) >= NVL(p_billed_amount, 0)) THEN
        p_4902_bal :=  NVL(p_billed_amount, 0);
        p_4901_bal := NVL(l_delivered_amt, 0) -  NVL(p_billed_amount, 0);
      ELSE
        p_4902_bal :=  NVL(l_delivered_amt, 0);
        p_4802_bal := NVL(p_billed_amount, 0) -  NVL(l_delivered_amt, 0);
      END IF;
      p_4801_bal := p_ordered_amount - (p_4802_bal + p_4901_bal + p_4902_bal);
      IF (p_4801_bal <= 0) THEN
        p_4801_bal := 0;
      END IF;
    END IF;
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'p_4801_bal='||p_4801_bal);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_4802_bal='||p_4802_bal);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_4901_bal='||p_4901_bal);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_4902_bal='||p_4902_bal);
    trace(C_PROC_LEVEL, l_procedure_name, 'END');
    -------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END;

--
--
-- Function to derive the balance amount for the fund and antipicated segment
-- returns the period balances for the account
-- Logic
--    1. with the inputs constructs the CCID
--    2. queries the gl_balances for the period and returns the balances
--
--
  PROCEDURE get_anticipated_fund_amt
  (
    p_ledger_id         IN NUMBER,
    p_gl_date           IN DATE,
    p_fund_value        IN VARCHAR2,
    p_anticipated_amt   OUT NOCOPY NUMBER,
    p_error_code        OUT NOCOPY NUMBER,
    p_error_desc        OUT NOCOPY VARCHAR2
  )
  IS
    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.GET_ANTICIPATED_FUND_AMT';

    CURSOR c_template_id
    (
      c_ledger_id NUMBER
    )
    IS
    SELECT template_id
      FROM fv_pya_fiscalyear_segment
     WHERE set_of_books_id = c_ledger_id;

    CURSOR c_period
    (
      c_ledger_id NUMBER,
      c_gl_date DATE
    ) IS
    SELECT period_year,
           period_num,
           period_name
      FROM gl_period_statuses
     WHERE ledger_id = c_ledger_id
       AND application_id = C_GL_APPLICATION
       AND c_gl_date BETWEEN start_date AND end_date;

    l_ledger_info          LedgerRecType;

    --l_anticipated_acct        VARCHAR2(30);
    l_template_id             NUMBER;
    l_ccid		    Gl_Code_Combinations.code_combination_id%TYPE;
    l_fund_value	Fv_Fund_Parameters.fund_value%TYPE;
    l_amount	    NUMBER;
    l_tot_amount NUMBER := 0;

    -- Variable declartions for Dynamic SQL
    l_fund_cur_id	INTEGER;
    l_fund_select	VARCHAR2(2000);
    l_fund_ret	  INTEGER;
    l_period_year gl_period_statuses.period_year%TYPE;
    l_period_num  gl_period_statuses.period_num%TYPE;
    l_period_name gl_period_statuses.period_name%TYPE;

  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;

    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||p_fund_value);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_gl_date='||p_gl_date);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
    -------------------------------------------------------------------------
    get_ledger_info
    (
      p_ledger_id  => p_ledger_id,
      p_ledger_rec => l_ledger_info,
      p_error_code => p_error_code,
      p_error_desc => p_error_desc
    );

    IF (p_error_code = c_SUCCESS) THEN
      OPEN c_template_id (p_ledger_id);
      FETCH c_template_id
       INTO l_template_id;

      trace(C_STATE_LEVEL, l_procedure_name, 'l_template_id='||l_template_id);
      IF (c_template_id%NOTFOUND) THEN
        p_error_code := c_FAILURE;
        trace(C_STATE_LEVEL, l_procedure_name, 'Error in Federal SLA processing.');
        FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('MESSAGE' ,
        'No summary Template found for the ledger. Please Associate a Summary'||
        'Template to the ledger in the Federal Financial Options form.');
        p_error_desc := fnd_message.get;
        stack_error (l_procedure_name, 'GET_TEMPLATE_ID', p_error_desc);
        trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_GL_PERIOD_STATUSES:'||p_error_desc);
      END IF;
      CLOSE c_template_id;
    END IF;


    IF (p_error_code = c_SUCCESS) THEN
       OPEN c_period (p_ledger_id, p_gl_date);
      FETCH c_period
       INTO l_period_year,
            l_period_num,
            l_period_name;
      CLOSE c_period;
      trace(C_STATE_LEVEL, l_procedure_name, 'l_period_year='||l_period_year);
      trace(C_STATE_LEVEL, l_procedure_name, 'l_period_num='||l_period_num);
    END IF;

    IF (p_error_code = c_SUCCESS) THEN
      -- get the ccid that contains this fund in its balancing segment
      -- and this anticipated account in Natural account segment
      -- assumption is federal would set up summary template for the anticpated account

      l_fund_cur_id := DBMS_SQL.OPEN_CURSOR;

      --Build the Select statement for getting the fund values and ccids
      l_fund_select := 'SELECT code_combination_id ' ||
                        ' FROM gl_code_Combinations ' ||
                       ' WHERE chart_of_accounts_id = :p_coaid '||
                       ' AND segment'||l_ledger_info.balancing_seg_name || ' = :p_fund_value '||
                       ' AND template_id = :p_template_id '||
                       ' AND summary_flag = ''Y''' ;

      -------------------------------------------------------------------------
      trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||p_fund_value);
      trace(C_STATE_LEVEL, l_procedure_name, 'l_template_id='||l_template_id);
      trace(C_STATE_LEVEL, l_procedure_name, 'l_fund_select='||l_fund_select);
      -------------------------------------------------------------------------

      -------------------------------------------------------------------------
      trace(C_STATE_LEVEL, l_procedure_name, 'parse');
      -------------------------------------------------------------------------
      DBMS_SQL.PARSE(l_fund_cur_id, l_fund_select, DBMS_SQL.Native);
      DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_coaid', l_ledger_info.coaid);
      DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_fund_value', p_fund_value, 25);
      DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_template_id', l_template_id, 30);

      -------------------------------------------------------------------------
      trace(C_STATE_LEVEL, l_procedure_name, 'DEFINE_COLUMN');
      -------------------------------------------------------------------------
      DBMS_SQL.DEFINE_COLUMN(l_fund_cur_id,1,l_ccid);

      l_fund_ret := DBMS_SQL.EXECUTE(l_fund_cur_id);

      LOOP
        -- Fetch the ccid's  from Gl_Code_Combinations
        trace(C_STATE_LEVEL, l_procedure_name, 'FETCH_ROWS');
        IF DBMS_SQL.FETCH_ROWS(l_fund_cur_id) = 0 THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'EXIT');
          EXIT;
        ELSE
          trace(C_STATE_LEVEL, l_procedure_name, 'COLUMN_VALUE');
          DBMS_SQL.COLUMN_VALUE(l_fund_cur_id, 1,l_ccid);
        END IF;

        trace(C_PROC_LEVEL, l_procedure_name, 'Before calling calc_funds');
        trace(C_STATE_LEVEL, l_procedure_name, 'l_ccid='||l_ccid);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_template_id='||l_template_id);
        trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_period_name='||l_period_name);

        SELECT SUM((begin_balance_dr - begin_balance_cr) +
                   (period_net_dr - period_net_cr))
          INTO l_amount
          FROM gl_balances
         WHERE ledger_id = p_Ledger_id
           AND currency_code = l_ledger_info.currency_code
           AND code_combination_id = l_ccid
           AND period_name = l_period_name;

        trace(C_STATE_LEVEL, l_procedure_name, ' gl_balances l_amount='||l_amount);

        l_tot_amount := l_tot_amount + NVL(l_amount, 0);

        trace(C_STATE_LEVEL, l_procedure_name, ' gl_balances l_tot_amount='||l_tot_amount);

        SELECT SUM(NVL(accounted_dr,0) - NVL(accounted_cr,0))
          INTO l_amount
          FROM gl_bc_packets gbc,
               gl_account_hierarchies gah
         WHERE gbc.ledger_id = p_Ledger_id
           AND gah.ledger_id = p_Ledger_id
           AND gah.template_id = l_template_id
           AND gah.summary_code_combination_id = l_ccid
           AND gbc.currency_code = l_ledger_info.currency_code
           AND gbc.code_combination_id = gah.detail_code_combination_id
           AND gbc.period_year = l_period_year
           AND gbc.period_num <= l_period_num
           AND gbc.status_code = 'A';

        trace(C_STATE_LEVEL, l_procedure_name, ' gl_bc_packets l_amount='||l_amount);

        l_tot_amount := l_tot_amount + NVL(l_amount, 0);

        trace(C_STATE_LEVEL, l_procedure_name, ' gl_bc_packets l_tot_amount='||l_tot_amount);
      END LOOP;
      dbms_sql.close_cursor (l_fund_cur_id);
    END IF;

    p_anticipated_amt := l_tot_amount;
    trace(C_PROC_LEVEL, l_procedure_name, 'p_anticipated_amt='||p_anticipated_amt);
    trace(C_PROC_LEVEL, l_procedure_name, 'END');

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END get_anticipated_fund_amt;

  PROCEDURE get_anticipated_ts_amt
  (
    p_ledger_id          IN NUMBER,
    p_gl_date            IN DATE,
    p_treasury_symbol_id IN VARCHAR2,
    p_anticipated_amt    OUT NOCOPY NUMBER,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  )
  IS
    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.get_anticipated_ts_amt';

    l_ledger_info          LedgerRecType;

    --l_anticipated_acct        VARCHAR2(30);
    l_template_id             NUMBER;
    l_ccid		    Gl_Code_Combinations.code_combination_id%TYPE;
    l_fund_value	Fv_Fund_Parameters.fund_value%TYPE;
    l_amount	    NUMBER;
    l_tot_amount NUMBER := 0;
    p_fund_value VARCHAR2(100);

    -- Variable declartions for Dynamic SQL
    l_fund_cur_id	INTEGER;
    l_fund_select	VARCHAR2(2000);
    l_fund_ret	  INTEGER;
    l_period_year gl_period_statuses.period_year%TYPE;
    l_period_num  gl_period_statuses.period_num%TYPE;
    l_period_name gl_period_statuses.period_name%TYPE;

  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;

    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_treasury_symbol_id='||p_treasury_symbol_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_gl_date='||p_gl_date);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
    -------------------------------------------------------------------------
    get_ledger_info
    (
      p_ledger_id  => p_ledger_id,
      p_ledger_rec => l_ledger_info,
      p_error_code => p_error_code,
      p_error_desc => p_error_desc
    );

    IF (p_error_code = c_SUCCESS) THEN
      BEGIN
        SELECT template_id
          INTO l_template_id
          FROM fv_pya_fiscalyear_segment
         WHERE set_of_books_id = p_ledger_id;
        trace(C_STATE_LEVEL, l_procedure_name, 'l_template_id='||l_template_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_error_code := c_FAILURE;
          trace(C_STATE_LEVEL, l_procedure_name, 'Error in Federal SLA processing.');
          FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('MESSAGE' , 'No summary Template found for the ledger. Please Associate a Summary'||
          'Template to the ledger in the Federal Financial Options form.');
          p_error_desc := fnd_message.get;
          stack_error (l_procedure_name, 'GET_TEMPLATE_ID', p_error_desc);
          trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_GL_PERIOD_STATUSES:'||p_error_desc);
        WHEN OTHERS THEN
          p_error_code := c_FAILURE;
          fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
          p_error_desc := fnd_message.get;
          stack_error (l_procedure_name, 'SELECT_fv_pya_fiscalyear_segment', p_error_desc);
          trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_fv_pya_fiscalyear_segment:'||p_error_desc);
      END;
    END IF;


    IF (p_error_code = c_SUCCESS) THEN
      BEGIN
        SELECT period_year,
               period_num,
               period_name
          INTO l_period_year,
               l_period_num,
               l_period_name
          FROM gl_period_statuses
         WHERE ledger_id = p_ledger_id
           AND application_id = C_GL_APPLICATION
           AND p_gl_date BETWEEN start_date AND end_date;
        trace(C_STATE_LEVEL, l_procedure_name, 'l_period_year='||l_period_year);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_period_num='||l_period_num);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_period_name='||l_period_name);
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := c_FAILURE;
          fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
          p_error_desc := fnd_message.get;
          stack_error (l_procedure_name, 'SELECT_gl_period_statuses', p_error_desc);
          trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:SELECT_gl_period_statuses:'||p_error_desc);
      END;
    END IF;

    IF (p_error_code = c_SUCCESS) THEN
      -- get the ccid that contains this fund in its balancing segment
      -- and this anticipated account in Natural account segment
      -- assumption is federal would set up summary template for the anticpated account

      l_fund_cur_id := DBMS_SQL.OPEN_CURSOR;

      --Build the Select statement for getting the fund values and ccids
      l_fund_select := 'SELECT code_combination_id ' ||
                       '  FROM gl_code_Combinations g, ' ||
                       '       fv_fund_parameters f'||
                       ' WHERE g.chart_of_accounts_id = :p_coaid '||
                       ' AND g.'||l_ledger_info.balancing_seg_name || ' = f.fund_value '||
                       ' AND f.treasury_symbol_id = :p_treasury_symbol_id '||
                       ' AND f.set_of_books_id = :p_ledger_id '||
                       ' AND g.template_id = :p_template_id '||
                       ' AND g.summary_flag = ''Y''' ;

      -------------------------------------------------------------------------
      trace(C_STATE_LEVEL, l_procedure_name, 'l_fund_select='||l_fund_select);
      -------------------------------------------------------------------------

      -------------------------------------------------------------------------
      trace(C_STATE_LEVEL, l_procedure_name, 'parse');
      -------------------------------------------------------------------------
      DBMS_SQL.PARSE(l_fund_cur_id, l_fund_select, DBMS_SQL.Native);
      DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_coaid', l_ledger_info.coaid);
      DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_treasury_symbol_id', p_treasury_symbol_id);
      DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_ledger_id', p_ledger_id);
      DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_template_id', l_template_id);

      -------------------------------------------------------------------------
      trace(C_STATE_LEVEL, l_procedure_name, 'DEFINE_COLUMN');
      -------------------------------------------------------------------------
      DBMS_SQL.DEFINE_COLUMN(l_fund_cur_id,1,l_ccid);

      l_fund_ret := DBMS_SQL.EXECUTE(l_fund_cur_id);

      LOOP
        -- Fetch the ccid's  from Gl_Code_Combinations
        trace(C_STATE_LEVEL, l_procedure_name, 'FETCH_ROWS');
        IF DBMS_SQL.FETCH_ROWS(l_fund_cur_id) = 0 THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'EXIT');
          EXIT;
        ELSE
          trace(C_STATE_LEVEL, l_procedure_name, 'COLUMN_VALUE');
          DBMS_SQL.COLUMN_VALUE(l_fund_cur_id, 1,l_ccid);
        END IF;

        trace(C_PROC_LEVEL, l_procedure_name, 'Before calling calc_funds');
        trace(C_STATE_LEVEL, l_procedure_name, 'l_ccid='||l_ccid);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_template_id='||l_template_id);
        trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_period_name='||l_period_name);

        SELECT SUM((begin_balance_dr - begin_balance_cr) +
                   (period_net_dr - period_net_cr))
          INTO l_amount
          FROM gl_balances
         WHERE ledger_id = p_Ledger_id
           AND currency_code = l_ledger_info.currency_code
           AND code_combination_id = l_ccid
           AND period_name = l_period_name;

        trace(C_STATE_LEVEL, l_procedure_name, ' gl_balances l_amount='||l_amount);

        l_tot_amount := l_tot_amount + NVL(l_amount, 0);

        trace(C_STATE_LEVEL, l_procedure_name, ' gl_balances l_tot_amount='||l_tot_amount);

        SELECT SUM(NVL(accounted_dr,0) - NVL(accounted_cr,0))
          INTO l_amount
          FROM gl_bc_packets gbc,
               gl_account_hierarchies gah
         WHERE gbc.ledger_id = p_Ledger_id
           AND gah.ledger_id = p_Ledger_id
           AND gah.template_id = l_template_id
           AND gah.summary_code_combination_id = l_ccid
           AND gbc.currency_code = l_ledger_info.currency_code
           AND gbc.code_combination_id = gah.detail_code_combination_id
           AND gbc.period_year = l_period_year
           AND gbc.period_num <= l_period_num
           AND gbc.status_code = 'A';

        trace(C_STATE_LEVEL, l_procedure_name, ' gl_bc_packets l_amount='||l_amount);

        l_tot_amount := l_tot_amount + NVL(l_amount, 0);

        trace(C_STATE_LEVEL, l_procedure_name, ' gl_bc_packets l_tot_amount='||l_tot_amount);
      END LOOP;
      dbms_sql.close_cursor (l_fund_cur_id);
    END IF;

    p_anticipated_amt := l_tot_amount;
    trace(C_PROC_LEVEL, l_procedure_name, 'p_anticipated_amt='||p_anticipated_amt);
    trace(C_PROC_LEVEL, l_procedure_name, 'END');

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END get_anticipated_ts_amt;


  PROCEDURE pya_adj_amt_by_fund
  (
    p_ledger_id   IN NUMBER,
    p_event_id    IN NUMBER,
    p_header_id   IN NUMBER,
    p_fund_value  IN VARCHAR2,
    p_net_amt     OUT NOCOPY NUMBER,
    p_error_code  OUT NOCOPY NUMBER,
    p_error_desc  OUT NOCOPY VARCHAR2
  )
  IS
    l_procedure_name               VARCHAR2(100) :='.PYA_ADJ_AMT_BY_FUND';

    CURSOR c_net_adj_amt (p_dist_id NUMBER) IS
    SELECT accounted_amt,
           event_type_code,
           code_combination_id
      FROM po_bc_distributions
     WHERE distribution_id = p_dist_id
       AND ae_event_id  = (SELECT max(ae_event_id)
                             FROM po_bc_distributions pbd
                            WHERE distribution_id = p_dist_id
                              AND main_or_backing_code = 'M'
                              AND ae_event_id <> p_event_id
                              AND distribution_type <> 'REQUISITION'
                              AND EXISTS (SELECT 1
                                            FROM xla_ae_headers xah
                                            WHERE application_id = 201
                                              AND xah.event_id = pbd.ae_event_id
                                              AND xah.accounting_entry_status_code = 'F'));

    --currently we are using only po_bc_distributions only, but infuture we may
    --have to use gl_bc_packets or xla_events

    /*Get all the distribution ids in p_event_id event which belong to the same document*/
    CURSOR c_get_dist_ids IS
    SELECT pbd.distribution_id,
           pbd.code_combination_id,
           pbd.accounted_amt
      FROM po_extract_detail_v ped,
           po_bc_distributions pbd
     WHERE ped.event_id = pbd.ae_event_id  --p_event_id AND
       AND ped.po_distribution_id = pbd.distribution_id
       AND pbd.header_id = p_header_id
       AND pbd.main_or_backing_code = 'M';

    l_fund_value_current    VARCHAR2(30);
    l_account_value_current VARCHAR2(30);
    l_bfy_value_current     VARCHAR2(30);
    l_fund_value_old        VARCHAR2(30);
    l_account_value_old     VARCHAR2(30);
    l_bfy_value_old         VARCHAR2(30);

    l_net_amt_current       NUMBER;
    l_net_amt_old           NUMBER;
    l_old_amt               c_net_adj_amt%ROWTYPE;
    l_po_distribution_id    NUMBER;
    l_code_combination_id   NUMBER;
    l_accounted_amt      NUMBER;
    l_old_event_type_code    VARCHAR2(30);
    l_ledger_info          LedgerRecType;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;

    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_event_id='||p_event_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_header_id='||p_header_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||p_fund_value);
    -------------------------------------------------------------------------
    get_ledger_info
    (
      p_ledger_id  => p_ledger_id,
      p_ledger_rec => l_ledger_info,
      p_error_code => p_error_code,
      p_error_desc => p_error_desc
    );

    IF (p_error_code = C_SUCCESS) THEN
      l_net_amt_current := 0;
      l_net_amt_old     := 0;
      OPEN c_get_dist_ids;
      LOOP
        FETCH c_get_dist_ids
         INTO l_po_distribution_id,
              l_code_combination_id,
              l_accounted_amt;
        EXIT WHEN c_get_dist_ids%NOTFOUND;
        trace(C_STATE_LEVEL, l_procedure_name, 'l_po_distribution_id='||l_po_distribution_id);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_code_combination_id='||l_code_combination_id);
        trace(C_STATE_LEVEL, l_procedure_name, 'l_accounted_amt='||l_accounted_amt);

        get_segment_values
        (
          p_ledger_id     => p_ledger_id,
          p_ccid          => l_code_combination_id,
          p_fund_value    => l_fund_value_current,
          p_account_value => l_account_value_current,
          p_bfy_value     => l_bfy_value_current,
          p_error_code    => p_error_code,
          p_error_desc    => p_error_desc
        );
        trace(C_STATE_LEVEL, l_procedure_name, 'l_fund_value_current='||l_fund_value_current);

        IF (p_error_code = C_SUCCESS) THEN
          OPEN c_net_adj_amt (l_po_distribution_id);
          FETCH c_net_adj_amt
           INTO l_old_amt;
          IF c_net_adj_amt%FOUND THEN
            trace(C_STATE_LEVEL, l_procedure_name, 'Old event_type_code found: ' || l_old_amt.event_type_code);
            trace(C_STATE_LEVEL, l_procedure_name, 'Old code_combination_id found: ' || l_old_amt.code_combination_id);
            get_segment_values
            (
              p_ledger_id     => p_ledger_id,
              p_ccid          => l_old_amt.code_combination_id,
              p_fund_value    => l_fund_value_old,
              p_account_value => l_account_value_old,
              p_bfy_value     => l_bfy_value_old,
              p_error_code    => p_error_code,
              p_error_desc    => p_error_desc
            );

            IF (p_error_code = C_SUCCESS) THEN
              IF p_fund_value = l_fund_value_old THEN
                l_net_amt_old := l_net_amt_old + l_old_amt.accounted_amt;
              END IF;

              IF p_fund_value = l_fund_value_current THEN
                l_old_event_type_code := l_old_amt.event_type_code;
                IF (l_old_event_type_code = 'PO_PA_RESERVED' OR
                    l_old_event_type_code = 'RELEASE_RESERVED') THEN
                  l_net_amt_current := l_net_amt_current + (l_old_amt.accounted_amt + l_accounted_amt) ;
                ELSE
                  l_net_amt_current := l_net_amt_current + l_accounted_amt ;
                END IF;
              END IF;
            END IF;
          ELSE                         -- prev event not found i.e., first reserve action is happening on this distribution. Bug 5006499.
            IF p_fund_value = l_fund_value_current THEN
              l_net_amt_current := l_net_amt_current + l_accounted_amt ;
            END IF;
          END IF;
          CLOSE c_net_adj_amt;
        END IF;
        IF (p_error_code <> C_SUCCESS) THEN
          EXIT;
        END IF;
      END LOOP;
      CLOSE c_get_dist_ids;
    END IF;

    p_net_amt := l_net_amt_current - l_net_amt_old;
    trace(C_PROC_LEVEL, l_procedure_name, 'p_net_amt='||p_net_amt);

    trace(C_PROC_LEVEL, l_procedure_name, 'END');

  EXCEPTION
    WHEN OTHERS THEN
      IF c_get_dist_ids%ISOPEN THEN
        CLOSE c_get_dist_ids;
      END IF;
      p_error_code := c_FAILURE;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE' , 'System Error :'||SQLERRM);
      p_error_desc := fnd_message.get;
      stack_error (l_procedure_name, 'FINAL', p_error_desc);
      trace(C_STATE_LEVEL, l_procedure_name, 'ERROR:FINAL:'||p_error_desc);
  END pya_adj_amt_by_fund;


  PROCEDURE determine_upward_downward
  (
    p_ledger_id            IN NUMBER,
    p_event_id             IN NUMBER,
    p_po_header_id         IN NUMBER,
    p_fund_value           IN VARCHAR2,
    p_gl_date              IN DATE,
    p_entered_pya_diff_amt IN NUMBER,
    p_net_pya_adj_amt      OUT NOCOPY NUMBER,
    p_adjustment_type      OUT NOCOPY VARCHAR2,
    p_anticipation         OUT NOCOPY VARCHAR2,
    p_anticipated_amt      OUT NOCOPY NUMBER,
    p_unanticipated_amt    OUT NOCOPY NUMBER,
    p_balance_amt          OUT NOCOPY NUMBER,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_debug_info              VARCHAR2(240);
    l_procedure_name          VARCHAR2(100):='.DETERMINE_UPWARD_DOWNWARD';
    l_balance_amt             NUMBER;

  BEGIN
    p_error_code := c_SUCCESS;
    p_error_desc := NULL;
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_event_id='||p_event_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_po_header_id='||p_po_header_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||p_fund_value);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_gl_date='||p_gl_date);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_entered_pya_diff_amt='||p_entered_pya_diff_amt);
    -------------------------------------------------------------------------

    pya_adj_amt_by_fund
    (
      p_ledger_id   => p_ledger_id,
      p_event_id    => p_event_id,
      p_header_id   => p_po_header_id,
      p_fund_value  => p_fund_value,
      p_net_amt     => p_net_pya_adj_amt,
      p_error_code  => p_error_code,
      p_error_desc  => p_error_desc
    );

    trace(C_STATE_LEVEL, l_procedure_name, 'Net PYA adj amount = ' || p_net_pya_adj_amt);

    IF p_net_pya_adj_amt > 0 THEN   -- upward movement
      p_adjustment_type := 'Upward';
    ELSIF p_net_pya_adj_amt = 0 THEN   -- no movement
      -- When the net effect of the prior year adjustments is zero,
      ---the adjustments are booked for the individual distributions
      --                        l_fv_extract_detail(l_index).entered_pya_amt := l_fv_extract_detail(l_index).entered_pya_diff_amt;
      --                        l_fv_extract_detail(l_index).entered_pya_diff_amt := 0;
      p_adjustment_type := 'None';
    ELSE  --p_net_pya_adj_amt < 0 THEN -- Downward movement
      p_adjustment_type := 'Downward';
    END IF; -- pya adjustment type D,U,N

    ------------------------------------------------------------
    l_debug_info := 'PYA adjustment type = ' || p_adjustment_type;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------

    --
    -- Downward PYA adjustment
    -- Determine antipicated, unanticpated
    --

    IF p_adjustment_type = 'Downward' THEN
    -- Find the Anticipated Account
    --   BEGIN	/* Anti Acct */

    get_anticipated_fund_amt
    (
      p_ledger_id         => p_ledger_id,
      p_gl_date           => p_gl_date,
      p_fund_value        => p_fund_value,
      p_anticipated_amt   => l_balance_amt,
      p_error_code        => p_error_code,
      p_error_desc        => p_error_desc
    );

    l_balance_amt := Nvl(l_balance_amt,0);
    p_balance_amt := l_balance_amt;
    --l_balance_amt := 0;
    --psa_summ_det_combinations_v

    ------------------------------------------------------------
    l_debug_info := 'balance in the anticipated account =  ' || l_balance_amt;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------
    IF l_balance_amt <= 0 THEN
      -- unanticapted
      p_Anticipation := 'Unanticipated';
      p_Anticipated_amt := 0;
      p_UnAnticipated_amt := -1 * p_entered_pya_diff_amt;
    ELSIF l_balance_amt > abs(p_net_pya_adj_amt) THEN
      -- anticapted
      p_Anticipation := 'Anticipated';
      p_Anticipated_amt := -1 * p_entered_pya_diff_amt;
      p_UnAnticipated_amt := 0;
    ELSIF l_balance_amt < abs(p_net_pya_adj_amt) THEN
      p_Anticipation := 'Partial';
      p_Anticipated_amt := l_balance_amt;
      p_UnAnticipated_amt := -1 * p_entered_pya_diff_amt - l_balance_amt;
    END IF; -- anticiaped values
    ------------------------------------------------------------
    l_debug_info := 'Anticipation =  ' || p_Anticipation;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------
    END IF; -- end downward PYA adjustmemt
  END determine_upward_downward;


BEGIN
  init;
END fv_sla_utl_processing_pkg;

/
