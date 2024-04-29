--------------------------------------------------------
--  DDL for Package Body OKL_REPORT_GENERATOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REPORT_GENERATOR_PVT" AS
/* $Header: OKLRRPTB.pls 120.35.12010000.12 2009/02/09 09:33:45 nikshah ship $ */

  -- Start of comments
  --
  -- Function Name   : populate_code_combinations
  -- Description    : Populates the okl_code_cmbns_gt table
  --
  -- Business Rules  : Called from prepare_gross_rec_report before any other
  --report call /*important */
  -- Parameters       :
  -- Version      : 1.0
  -- History        : Ravindranath Gooty created.
  --
  -- End of comments
  -- Package level variables
  G_MODULE                  CONSTANT  VARCHAR2(255):= 'LEASE.ACCOUNTING.RECONCILIATION.OKL_REPORT_GENERATOR_PVT';
  G_DEBUG_ENABLED           CONSTANT  VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_STATEMENT_ON             BOOLEAN;

    CURSOR get_contracts_csr(
              p_org_id          NUMBER
             ,p_legal_entity_id NUMBER
             ,p_ledger_id       NUMBER
             ,p_start_date      DATE
             ,p_end_date        DATE)
    IS
      -- Starting from OKL Transactions find all the Booking Transactions
      --    in the input Ledger, Org Id, Le Id whose Transaction Date < p_end_date
      -- Fetch all those khr_id
      --  Using this khr_id confirm that there exists no Termination Transaction
      --   on or before the Report Start Date
      SELECT   chr.currency_code              currency_code
              ,ou.name                        organization_name
              ,chr.contract_number            contract_number
              ,a.contract_id                  contract_id
              ,ou.organization_id             org_id
              ,a.bkg_transaction_date         bkg_transaction_date
              ,KHR.PDT_ID                     PDT_ID
      FROM
      (
        SELECT bkg_trx.khr_id                 contract_id
              ,min(bkg_trx.transaction_date)  bkg_transaction_date
         FROM  okl_trx_contracts_all          bkg_trx
              ,okl_k_headers                  khr
              ,okl_trx_types_b                try
              ,okl_rep_products_gt            pdt_gt
        WHERE  bkg_trx.tcn_type = 'BKG'
          AND  bkg_trx.try_id =  try.id
          AND  try.trx_type_class = 'BOOKING'
          -- Booking Transaction should be related to the Input Ledger
          AND  bkg_trx.set_of_books_id = p_ledger_id
          -- Booking Transaction should belong the Operating Unit inputted
          AND  bkg_trx.org_id = nvl( p_org_id, bkg_trx.org_id )
          -- Booking Transaction should belong the Legal Entity inputted
          AND  bkg_trx.legal_entity_id = nvl( p_legal_entity_id, bkg_trx.legal_entity_id )
          AND  bkg_trx.khr_id = khr.id
          -- Contracts product in context should be one of the Report Products
          AND  khr.pdt_id = pdt_gt.product_id
        GROUP BY  bkg_trx.khr_id
        -- Booking Transaction Date should be less than the Report To Date
        HAVING  MIN(bkg_trx.transaction_date ) <  p_end_date
      ) a
      ,okc_k_headers_all_b     CHR
      ,okl_k_headers           KHR
      ,hr_operating_units      ou
    WHERE
           a.contract_id = CHR.id
      AND  KHR.ID = CHR.ID
      AND  ou.organization_id = chr.authoring_org_id
           -- Pick only those Contracts [iff in Expired/Terminated Status]
           --  which got expired by a Termination Transaction
           --  after the Report Start Date
           -- Contract should not have occurbe before the Report Start Date
      AND  p_start_date <=
              nvl( ( SELECT  max(transaction_date) last_trm_trx_date
                        FROM  okl_trx_contracts_all term_trx
                       WHERE  term_trx.khr_id = a.contract_id
                         AND  term_trx.tcn_type ='TMT'
                         AND  trn_code = 'EXP'
                    ),
                    p_start_date + 1
                 )
    ; -- End of Cursor: get_contracts_csr


  PROCEDURE write_to_log(
              p_level                 IN VARCHAR2,
              p_module                IN fnd_log_messages.module%TYPE,
              msg                     IN VARCHAR2 )
  AS
    -- l_level: S - Statement, P- Procedure, B - Both
  BEGIN
    okl_debug_pub.log_debug(
      p_level,
      p_module,
      msg);
  END;

  PROCEDURE put_in_log(
              p_debug_enabled         IN VARCHAR2,
              is_debug_procedure_on   IN BOOLEAN,
              is_debug_statement_on   IN BOOLEAN,
              p_module                IN fnd_log_messages.module%TYPE,
              p_level                 IN VARCHAR2,
              msg                     IN VARCHAR2 )
  AS
    -- l_level: S - Statement, P- Procedure, B - Both
  BEGIN
    IF(p_debug_enabled='Y' AND is_debug_procedure_on AND p_level = 'P')
    THEN
        write_to_log(
          p_level   => FND_LOG.LEVEL_PROCEDURE,
          p_module  => p_module,
          msg       => msg);
    ELSIF (p_debug_enabled='Y' AND is_debug_statement_on AND
          (p_level = 'S' OR p_level = 'B' ))
    THEN
        write_to_log(
          p_level   => FND_LOG.LEVEL_STATEMENT,
          p_module  => p_module,
          msg       => msg);
    END IF;
    -- Log Each and Every Statement
    FND_FILE.PUT_LINE(FND_FILE.LOG, MSG );
  END put_in_log;

  -- Start of comments
  --
  -- Function Name   : populate_code_combinations
  -- Description    : Populates the okl_code_cmbns_gt table
  --
  -- Business Rules  : Called from prepare_gross_rec_report before any other
  --report call /*important */
  -- Parameters       :
  -- Version      : 1.0
  -- History        : Ravindranath Gooty created.
  --
  -- End of comments

  PROCEDURE populate_code_combinations(
              p_api_version   IN         NUMBER
             ,p_init_msg_list IN         VARCHAR2
             ,x_return_status OUT NOCOPY VARCHAR2
             ,x_msg_count     OUT NOCOPY NUMBER
             ,x_msg_data      OUT NOCOPY VARCHAR2
             ,p_report_id     IN         NUMBER
             ,p_ledger_id     IN         NUMBER)
  IS
    l_segment   VARCHAR2(50);
    l_report_id NUMBER := p_report_id;

    -- Cursor to identifiy what is the column Name for the Natural Account Segment
    CURSOR c_get_segment_num(p_ledger_id NUMBER)
    IS
      SELECT s.application_column_name    segment_col_name
      FROM   fnd_id_flex_segments         s,
             fnd_segment_attribute_values sav,
             gl_ledgers_public_v          glp --,
      WHERE  s.application_id = 101 -- GL Application ID
      AND    s.id_flex_code = 'GL#'
      AND    s.id_flex_num = glp.chart_of_accounts_id --COA ID
      AND    s.enabled_flag = 'Y'
      AND    s.application_column_name = sav.application_column_name
      AND    sav.application_id = 101
      AND    sav.id_flex_code = 'GL#'
      AND    sav.id_flex_num = glp.chart_of_accounts_id
      AND    sav.attribute_value = 'Y'
      AND    sav.segment_attribute_type = 'GL_ACCOUNT'
      AND    glp.ledger_id = p_ledger_id;
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'populate_code_combinations';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Debug related parameters
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Local Variables
    l_query_string        VARCHAR2(4000);
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRRPTB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_REPORT_GENERATOR_PVT.' || l_api_name );
    l_return_status := okl_api.g_ret_sts_success;
    -- The Report Definition stores the Range of Natural Account Segments.
    -- Using those prepare a list of Code Combinations and populate it into the
    -- OKL Account Code Combinations GT Table
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Execute the Cursor c_get_segment_num' || p_ledger_id );
    -- Given a Ledger find out the Segment Column Number which stores the Natural Account Segment
    OPEN c_get_segment_num(p_ledger_id => p_ledger_id);
    FETCH c_get_segment_num
      INTO l_segment;
    CLOSE c_get_segment_num;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Execute the Cursor c_get_segment_num' || p_ledger_id );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Segment Column Name=' || l_segment );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Ledger Id=' || p_ledger_id );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Report Id=' || p_report_id );

    -- Prepare the Query String
    l_query_string :=
         'INSERT INTO okl_code_cmbns_gt ('
       ||' ccid'
       ||' ,account_number'
       ||')'
       ||' SELECT  cc.code_combination_id'
       ||' ,' || l_segment || ' ' -- segment3
       ||' FROM  gl_code_combinations cc'
       ||' ,gl_ledgers_public_v gl'
       ||' WHERE  cc.chart_of_accounts_id = gl.chart_of_accounts_id'
       ||'  AND cc.enabled_flag =  ' || '''' || 'Y' || ''''
       ||'  AND gl.ledger_id =  ' || p_ledger_id
       ||'  AND EXISTS'
       ||' ('
       ||'  SELECT  sg_frm_fvl.flex_value segment_range_from'
       ||'  ,sg_to_fvl.flex_value  segment_range_to'
       ||'  FROM  fnd_flex_values_vl     sg_frm_fvl'
       ||'  ,fnd_flex_values_vl     sg_to_fvl'
       ||'  ,okl_report_acc_params  acc_params'
       ||'  WHERE  sg_frm_fvl.flex_value_id = acc_params.segment_range_from'
       ||'   AND  sg_to_fvl.flex_value_id  = acc_params.segment_range_to'
       ||'   AND  acc_params.report_id = ' || p_report_id || ' '
       ||'   AND  cc.' || l_segment || ' >= sg_frm_fvl.flex_value'
       ||'   AND  cc.' || l_segment || ' <= sg_to_fvl.flex_value'
       ||')';
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Query String=' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      l_query_string );
    -- Dynamically Execute the
    EXECUTE IMMEDIATE l_query_string;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executed the Dynamically Binded Query' );
    -- Set the Return Status and return back
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_get_segment_num%ISOPEN
      THEN
        CLOSE c_get_segment_num;
      END IF;
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
  END populate_code_combinations;

  -- Start of comments
  --
  -- Function Name   : populate_code_combinations
  -- Description    : Populates the okl_code_cmbns_gt table
  --
  -- Business Rules  : Called from prepare_gross_rec_report before any other
  --report call /*important */
  -- Parameters       :
  -- Version      : 1.0
  -- History        : Ravindranath Gooty created.
  --
  -- End of comments
  PROCEDURE populate_products(
              p_api_version   IN         NUMBER
             ,p_init_msg_list IN         VARCHAR2
             ,x_return_status OUT NOCOPY VARCHAR2
             ,x_msg_count     OUT NOCOPY NUMBER
             ,x_msg_data      OUT NOCOPY VARCHAR2
             ,p_report_id     IN         NUMBER
             ,p_org_id        IN         NUMBER )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    CURSOR is_pdt_or_bc_present_csr( p_report_id NUMBER )
    IS
      SELECT  DISTINCT 'Y'  flag
        FROM  okl_report_parameters params
       WHERE  params.report_id = p_report_id
         AND  params.parameter_type_code IN
              ( 'BOOK_CLASSIFICATION', 'PRODUCT' );

    -- Cursor to fetch all the products present in the System
    CURSOR get_all_pdts_from_sys_csr( p_report_id NUMBER )
    IS
      SELECT  pdt.NAME       product_name
             ,pdt.id         product_id
        FROM  okl_products   pdt;


    -- The following Cursor will fetch the product if
    --  a. The Products book classification is mentioned in the Report Definition
    --  b. The Product is directly mentioned in the Report Definition
    CURSOR get_pdts_from_report_csr(
            p_report_id       NUMBER)
    IS
      SELECT  pdt.NAME       product_name
             ,pdt.id         product_id
        FROM  okl_products              pdt
             ,okl_ae_tmpt_sets_all      aes
             ,okl_st_gen_tmpt_sets_all  gts
       WHERE  pdt.aes_id = aes.id
         AND  aes.gts_id = gts.id
         AND  gts.deal_type
              IN
               (
                  SELECT  params.param_char_value1
                    FROM  okl_report_parameters params
                   WHERE  params.report_id = p_report_id
                     AND  params.parameter_type_code = 'BOOK_CLASSIFICATION'
               )
   UNION
     -- Append list of products from the report too
      SELECT  pdt.NAME       product_name
             ,pdt.id         product_id
        FROM  okl_report_parameters  params
             ,okl_products           pdt
       WHERE  params.report_id = p_report_id
         AND  params.parameter_type_code = 'PRODUCT'
         AND  params.param_num_value1 = pdt.id;

    TYPE rep_pdts_tbl_type IS TABLE OF okl_rep_products_gt%ROWTYPE
      INDEX BY BINARY_INTEGER;
    l_report_pdts_tbl    rep_pdts_tbl_type;

    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'populate_products';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Debug related parameters
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Local Variables
    l_report_id            NUMBER := p_report_id;
    l_bc_or_pdts_mentioned VARCHAR2(1);
    l_pdt_count            NUMBER;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRRPTB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_REPORT_GENERATOR_PVT.' || l_api_name );
    l_return_status := okl_api.g_ret_sts_success;

    -- Logic:
    --  Check whether atleast one product or Book Classification is mentioned on the
    --   Report Definition or not
    --  If Mentioned:
    --    Fetch only those products from the System which are either mentioned
    --     directly on the report definition or
    --    The products Book Classification is mentioned in the Report Definition
    --  If Not mentioned:
    --    Fetch all products from the System

    l_bc_or_pdts_mentioned := 'N';
    FOR t_rec IN is_pdt_or_bc_present_csr( p_report_id => p_report_id )
    LOOP
      l_bc_or_pdts_mentioned := t_rec.flag;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Case when Book Classification or Product is Mentioned' );
    END LOOP;

    -- Initialize the l_pdt_count
    l_pdt_count := 1;
    IF l_bc_or_pdts_mentioned = 'Y'
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '!!! Fetching All products from System based on BC !!! ' );
      FOR t_rec IN get_pdts_from_report_csr(p_report_id  => p_report_id )
      LOOP
        l_report_pdts_tbl(l_pdt_count).product_name := t_rec.product_name;
        l_report_pdts_tbl(l_pdt_count).product_id   := t_rec.product_id;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
          'Product Name ' || t_rec.product_name ||
          'Product Id ' || t_rec.product_id );
        -- Increment the  l_pdt_count
        l_pdt_count := l_pdt_count +1;
      END LOOP;
    ELSE
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '!!! Fetching All products from System Without any restriction !!! ' );
      FOR t_rec IN get_all_pdts_from_sys_csr(p_report_id  => p_report_id )
      LOOP
        l_report_pdts_tbl(l_pdt_count).product_name := t_rec.product_name;
        l_report_pdts_tbl(l_pdt_count).product_id   := t_rec.product_id;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
          'Product Name ' || t_rec.product_name ||
          'Product Id ' || t_rec.product_id );
        -- Increment the  l_pdt_count
        l_pdt_count := l_pdt_count +1;
      END LOOP;
    END IF;

    -- Finally insert the list of Products figured out
    FORALL i IN l_report_pdts_tbl.FIRST .. l_report_pdts_tbl.LAST
      INSERT INTO okl_rep_products_gt VALUES l_report_pdts_tbl(i);

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'End: populate_products' );
    -- Set the Return Status and return back
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
  END populate_products;

  -- Start of comments
  --
  -- Function Name   : populate_code_combinations
  -- Description    : Populates the okl_code_cmbns_gt table
  --
  -- Business Rules  : Called from prepare_gross_rec_report before any other
  --report call /*important */
  -- Parameters       :
  -- Version      : 1.0
  -- History        : Ravindranath Gooty created.
  --
  -- End of comments

  PROCEDURE populate_trx_data(
              p_api_version   IN         NUMBER
             ,p_init_msg_list IN         VARCHAR2
             ,x_return_status OUT NOCOPY VARCHAR2
             ,x_msg_count     OUT NOCOPY NUMBER
             ,x_msg_data      OUT NOCOPY VARCHAR2
             ,p_report_id     IN         NUMBER
             ,p_ledger_id     IN         NUMBER
             ,p_start_date    IN         DATE
             ,p_end_date      IN         DATE
             ,p_org_id        IN         NUMBER
             ,p_le_id         IN         NUMBER)
  IS
    l_report_id NUMBER := p_report_id;
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'populate_trx_data';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Debug related parameters
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Local Variables
    l_query_string        VARCHAR2(4000);
    l_trace_time          DATE;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRRPTB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Begin: ' || l_api_name ||'(+)' );
    l_return_status := okl_api.g_ret_sts_success;
    -- By now we have the List of Eligible Products and Code Combinations Available
    -- in the corresponding _GT tables
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Input Parameters ' ||
      ' p_report_id=' || p_report_id ||
      ' p_ledger_id=' || p_ledger_id ||
      ' p_start_date=' || p_start_date ||
      ' p_end_date=' || p_end_date ||
      ' p_org_id=' || p_org_id ||
      ' p_le_id=' ||  p_le_id );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -------------------------------------------------------------------------------------
    -- Queries to Populate the Lease Accounting Transactions
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Lease Accounting Transactions GT Table Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                  ,value4_date
                )
      SELECT -- String Formatted Columns
             trx_detail_type_code        --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,trx_legal_entity_name       --value15_text
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,trx_acc_dr_ccid             --value4_num
            ,trx_acc_cr_ccid             --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_legal_entity_id         --value8_num
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
            ,accrual_date                --value4_date
        FROM
       (
         -- Query Segment to fetch the UnAccounted Transactions with No Accounting Events
         -- Bug 6835659: Modified the Report Extraction to fetch the Transactions
         --  of Non-Accounting Transaction Types
         SELECT 'TRX_UNACCOUNTED_NO_EVENT'                trx_detail_type_code
                ,trx.trx_number                           trx_number
                ,try.name                                 trx_type_name
                ,NULL                                     trx_event_name
                ,'Leasing and Finance Management'                       trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,trx.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,DECODE(nvl(dist.cr_dr_flag, 'D')
                          ,'D', dist.amount, NULL)        trx_dr_amount
                ,DECODE(nvl(dist.cr_dr_flag, 'D')
                          ,'C', dist.amount, NULL)        trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',       txl.amount
                         ,'SUBTRACT', txl.amount * -1
                       )                                  trx_net_amount
                -- Note that in ATS Mode only distributions can fetch you the CCID
                -- In AMB mode, the Un-Accounted Distributions may not have the Code Combinations ID
                ,DECODE(nvl(dist.cr_dr_flag, 'D')
                        ,'D', dist.code_combination_id
                        , NULL)                           trx_acc_dr_ccid
                ,DECODE(nvl(dist.cr_dr_flag, 'D')
                        ,'C', dist.code_combination_id
                        , NULL)                           trx_acc_cr_ccid
                ,trx.set_of_books_id                      trx_ledger_id
                ,trx.org_id                               trx_operating_unit_id
                ,trx.legal_entity_id                      trx_legal_entity_id
                ,trx.khr_id                               trx_khr_id
                ,txl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,txl.sty_id                               trx_sty_id
                ,540                                      trx_application_id
                -- DATE Format Columns
                ,trx.transaction_date                     trx_date
                ,dist.gl_date                             gl_date
                -- Additional Columns
                ,trx.id                                   trx_id
                ,txl.id                                   trx_txl_id
                ,trx.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,dist.id                                  trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,trx.transaction_date                     trx_occ_date
                ,trx.date_accrual                         accrual_date
                ,'Lease'                                  source
          FROM   okl_trx_contracts_all     trx
                ,okl_txl_cntrct_lns_all    txl
                ,okl_trns_acc_dstrs_all    dist
                ,okl_trx_types_v           try
                ,okl_strm_type_v           sty
                ,okc_k_headers_all_b       chr
                ,okl_k_headers             khr
                ,okl_products              pdt
                ,okl_ae_tmpt_sets_all      aes
                ,okl_st_gen_tmpt_sets_all  gts
                ,okl_reports_b             rep
                ,okl_report_trx_params     rtryp
                ,okl_rep_products_gt       pdt_gt
                -- To fetch Names
                ,hr_operating_units        ou
                ,xle_entity_profiles       le
                ,gl_ledgers_v              ledger
          WHERE  trx.id = txl.tcn_id
            AND  trx.try_id = try.id
            AND  try.accounting_event_class_code IS NOT NULL
            AND  txl.sty_id   = sty.id -- May be we dont need outer join here
            AND  dist.source_id = txl.id
            AND  dist.source_table = 'OKL_TXL_CNTRCT_LNS'
            -- Restrict to only one Distribution Line
            -- In ATS Mode restrict the distribution to Debit Only
            -- In AMB Mode only one dist. will be created in OKL, hence consider that as Debit
            AND  nvl(dist.cr_dr_flag, 'D') = 'D'
            AND  trx.khr_id = chr.id
            AND  chr.id = khr.id
            AND  khr.pdt_id = pdt.id
            AND  pdt.aes_id = aes.id
            AND  aes.gts_id = gts.id
            -- Pick the Distribution which doesnot have the Accounting Event Stamped on It
            AND  dist.accounting_event_id IS NULL
            -- Transaction should have occured in the Start and End date of the Context
            AND  trx.transaction_date >= p_start_date
            AND  trx.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,txl.sty_id), - 1 )  = nvl(txl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND trx.org_id = NVL( p_org_id, trx.org_id )
            AND trx.legal_entity_id = NVL(p_le_id, trx.legal_entity_id )
            AND trx.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = trx.org_id
            AND le.legal_entity_id = trx.legal_entity_id
            AND ledger.ledger_id = trx.set_of_books_id
            --End of Query Segment to fetch the UnAccounted Transactions
      UNION ALL
         -- Query Segment to fetch the UnAccounted Transactions
         -- from OLM only. Imp Predicates: XLA_EVENTS.event_status_code in ( 'I', 'U' )
         SELECT 'TRX_UNACCOUNTED'                         trx_detail_type_code
                ,trx.trx_number                           trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Leasing and Finance Management'                       trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,trx.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,DECODE(nvl(dist.cr_dr_flag, 'D')
                          ,'D', dist.amount, NULL)        trx_dr_amount
                ,DECODE(nvl(dist.cr_dr_flag, 'D')
                          ,'C', dist.amount, NULL)        trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',       txl.amount
                         ,'SUBTRACT', txl.amount * -1
                       )                                  trx_net_amount
                -- Note that in ATS Mode only distributions can fetch you the CCID
                -- In AMB mode, the Un-Accounted Distributions may not have the Code Combinations ID
                ,DECODE(nvl(dist.cr_dr_flag, 'D')
                        ,'D', dist.code_combination_id
                        , NULL)                           trx_acc_dr_ccid
                ,DECODE(nvl(dist.cr_dr_flag, 'D')
                        ,'C', dist.code_combination_id
                        , NULL)                           trx_acc_cr_ccid
                ,trx.set_of_books_id                      trx_ledger_id
                ,trx.org_id                               trx_operating_unit_id
                ,trx.legal_entity_id                      trx_legal_entity_id
                ,trx.khr_id                               trx_khr_id
                ,txl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,txl.sty_id                               trx_sty_id
                ,540                                      trx_application_id
                -- DATE Format Columns
                ,trx.transaction_date                     trx_date
                ,dist.gl_date                             gl_date
                -- Additional Columns
                ,trx.id                                   trx_id
                ,txl.id                                   trx_txl_id
                ,trx.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,dist.id                                  trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,trx.transaction_date                     trx_occ_date
                ,trx.date_accrual                         accrual_date
                ,'Lease'                                  source
          FROM   okl_trx_contracts_all     trx
                ,okl_txl_cntrct_lns_all    txl
                ,okl_trns_acc_dstrs_all    dist
                ,okl_trx_types_v           try
                ,okl_strm_type_v           sty
                ,okc_k_headers_all_b       chr
                ,okl_k_headers             khr
                ,okl_products              pdt
                ,okl_ae_tmpt_sets_all      aes
                ,okl_st_gen_tmpt_sets_all  gts
                ,okl_reports_b             rep
                ,okl_report_trx_params     rtryp
                ,okl_rep_products_gt       pdt_gt
                -- To fetch Names
                ,hr_operating_units        ou
                ,xle_entity_profiles       le
                ,gl_ledgers_v              ledger
                -- XLA Entities
                ,xla_events                xe
                ,xla_event_types_vl        xvl
          WHERE  trx.id = txl.tcn_id
            AND  trx.try_id = try.id
            AND  try.accounting_event_class_code IS NOT NULL
            AND  txl.sty_id   = sty.id -- May be we dont need outer join here
            AND  dist.source_id = txl.id
            AND  dist.source_table = 'OKL_TXL_CNTRCT_LNS'
            -- Restrict to only one Distribution Line
            -- In ATS Mode restrict the distribution to Debit Only
            -- In AMB Mode only one dist. will be created in OKL, hence consider that as Debit
            AND  nvl(dist.cr_dr_flag, 'D') = 'D'
            AND  trx.khr_id = chr.id
            AND  chr.id = khr.id
            AND  khr.pdt_id = pdt.id
            AND  pdt.aes_id = aes.id
            AND  aes.gts_id = gts.id
            AND  xe.event_id = dist.accounting_event_id -- Distribution have the Acc. Event Stamp on it
            AND  xe.application_id = 540 -- Lease
            AND  xe.event_status_code IN ( 'U', 'I' ) -- Un Accounted Or Errored out
            AND  xe.application_id = xvl.application_id
            AND  xvl.event_type_code = xe.event_type_code
            -- Transaction should have occured in the Start and End date of the Context
            AND  trx.transaction_date >= p_start_date
            AND  trx.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,txl.sty_id), - 1 )  = nvl(txl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND trx.org_id = NVL( p_org_id, trx.org_id )
            AND trx.legal_entity_id = NVL(p_le_id, trx.legal_entity_id )
            AND trx.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = trx.org_id
            AND le.legal_entity_id = trx.legal_entity_id
            AND ledger.ledger_id = trx.set_of_books_id
            --End of Query Segment to fetch the UnAccounted Transactions
      UNION ALL
        -- Query Segment to fetch the Unposted Accounting Transactions
        -- from OLM only. Imp Predicates: Accounting Event status in P
        -- xh.gl_transfer_status_code <> 'Y'
        SELECT 'TRX_UNPOSTED'                           trx_detail_type_code
              ,trx.trx_number                           trx_number
              ,try.name                                 trx_type_name
              ,xvl.name                                 trx_event_name
              ,'Leasing and Finance Management'                       trx_application_name
              ,chr.contract_number                      contract_number
              ,NULL                                     asset_number
              ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
              ,pdt.NAME                                 product_name
              ,sty.NAME                                 trx_sty_name
              ,sty.styb_purpose_meaning                 trx_sty_purpose
              ,trx.currency_code                        currency_code
              ,glcc.concatenated_segments               trx_account_name
              ,ou.name                                  trx_operating_unit_name
              ,le.name                                  trx_legal_entity_name
              ,ledger.name                              trx_ledger_name
              ,rtryp.add_substract_code                 trx_activity_code
              ,NULL                                     trx_period_name
              -- Number Format Columns
              ,DECODE(nvl(dist.cr_dr_flag, 'D')
                        ,'D', dist.amount, NULL)        trx_dr_amount
              ,DECODE(nvl(dist.cr_dr_flag, 'D')
                        ,'C', dist.amount, NULL)        trx_cr_amount
              ,DECODE(rtryp.add_substract_code
                       ,'ADD',       txl.amount
                       ,'SUBTRACT', txl.amount * -1
                     )                                  trx_net_amount
              -- Its safe to fetch the CCID from XLA itself instead of the OKL Dist. table
              ,DECODE(xl.entered_cr
                       ,NULL, xl.code_combination_id    -- When Credit Amount is Null, it means Debit Distribution
                       ,NULL
                     )                                  trx_acc_dr_ccid
              ,DECODE(xl.entered_dr
                       ,NULL, xl.code_combination_id    -- When Debit Amount is Null, it means Credit Distribution
                       ,NULL
                     )
              ,trx.set_of_books_id                      trx_ledger_id
              ,trx.org_id                               trx_operating_unit_id
              ,trx.legal_entity_id                      trx_legal_entity_id
              ,trx.khr_id                               trx_khr_id
              ,txl.kle_id                               txl_asset_id
              ,khr.pdt_id                               trx_pdt_id
              ,txl.sty_id                               trx_sty_id
              ,540                                      trx_application_id
              -- DATE Format Columns
              ,trx.transaction_date                     trx_date
              ,dist.gl_date                             gl_date
              -- Additional Columns
              ,trx.id                                   trx_id
              ,txl.id                                   trx_txl_id
              ,trx.try_id                               trx_try_id
              ,rep.report_id                            trx_report_id
              ,dist.id                                  trx_dist_id
              -- Occurance date of the Transaction, not the Transaction Effective Date
              ,trx.transaction_date                     trx_occ_date
              ,trx.date_accrual                         accrual_date
              ,'Lease'                                  source
        FROM    okl_trx_contracts_all     trx
               ,okl_txl_cntrct_lns_all    txl
               ,okl_trns_acc_dstrs_all    dist
               ,okl_trx_types_v           try
               ,okl_strm_type_v           sty
               ,okc_k_headers_all_b       chr
               ,okl_k_headers             khr
               ,okl_products              pdt
               ,okl_ae_tmpt_sets_all      aes
               ,okl_st_gen_tmpt_sets_all  gts
               -- SLA Entities
               ,xla_distribution_links    xd
               ,xla_ae_headers            xh
               ,xla_ae_lines              xl
               ,xla_events                xe
               ,xla_event_types_vl        xvl
               -- OLM Reconciliation Report Definitions Table
               ,okl_reports_b             rep
               ,okl_report_trx_params     rtryp
               ,okl_rep_products_gt       pdt_gt
               -- To fetch Names
               ,gl_code_combinations_kfv  glcc
               ,hr_operating_units        ou
               ,xle_entity_profiles       le
               ,gl_ledgers_v              ledger
        WHERE  trx.id = txl.tcn_id
          AND  trx.try_id = try.id
          AND  try.accounting_event_class_code IS NOT NULL
          AND  txl.sty_id   = sty.id -- May be we dont need outer join here
          AND  dist.source_id = txl.id
          AND  dist.source_table = 'OKL_TXL_CNTRCT_LNS'
          -- Restrict to only one Distribution Line based on the Transaction Activity Code Add/Substract
          -- If its Add Consider only Debit, else if its Substract consider Credit
          AND
          (
            DECODE(xl.entered_cr, NULL, 'DEBIT_DIST', 'CREDIT_DIST' ) =
                 DECODE(rtryp.add_substract_code,
                 'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
            OR
            DECODE(xl.entered_dr, NULL, 'CREDIT_DIST', 'DEBIT_DIST' ) =
                DECODE(rtryp.add_substract_code,
                'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
          )
          AND  dist.posted_yn = 'Y'
          AND  trx.khr_id = chr.id
          AND  chr.id = khr.id
          AND  khr.pdt_id = pdt.id
          AND  pdt.aes_id = aes.id
          AND  aes.gts_id = gts.id
          -- OKL to SLA Link predicates
          AND  dist.accounting_event_id = xe.event_id
          AND  xe.application_id = xvl.application_id
          AND  xvl.event_type_code = xe.event_type_code
          AND  xd.event_id = dist.accounting_event_id
          AND  dist.id = xd.source_distribution_id_num_1
          AND  xd.application_id = 540
          AND  xd.ae_header_id = xh.ae_header_id
          AND  xl.ae_header_id = xh.ae_header_id
          AND  xl.ledger_id = p_ledger_id
          AND  xd.ae_line_num = xl.ae_line_num --XD,XH,XL END
          -- Important Predicate: XLA Distribution Links should not have the GL Import Link ID
          AND  xh.gl_transfer_status_code <> 'Y' -- Not Imported to GL Yet
          -- Transaction should have occured in the Start and End date of the Context
          AND  trx.transaction_date >= p_start_date
          AND  trx.transaction_date <= p_end_date
          -- Add Predicates based on the report
          AND  rep.report_id = p_report_id
          AND  rtryp.report_id = rep.report_id
          AND  try.id = rtryp.try_id
          AND  nvl(nvl(rtryp.sty_id,txl.sty_id), - 1 )  = nvl(txl.sty_id, -1)
          -- Products restriction
          AND  pdt_gt.product_id = pdt.id
          -- Org., Ledger and Legal Entity Id restriction
          AND trx.org_id = NVL( p_org_id, trx.org_id )
          AND trx.legal_entity_id = NVL(p_le_id, trx.legal_entity_id )
          AND trx.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
          -- Predicates to fetch the Names
          AND ou.organization_id = trx.org_id
          AND le.legal_entity_id = trx.legal_entity_id
          AND ledger.ledger_id = trx.set_of_books_id
          AND glcc.code_combination_id = xl.code_combination_id
        -- End of Query Segment to fetch the Unposted Acc. Entries from OLM
      UNION ALL
        -- Query Segment to find the Journal Entries from GL, either Posted or Unposted
        -- If Unposted Detail Type will be TRX_UNPOSTED else if posted it will be TRX_POSTED
        SELECT DECODE( gh.status
                         ,'U',  'TRX_UNPOSTED'  -- Unposted Transactions
                         ,'P',  'TRX_POSTED'    -- Posted Transactions
                     )                                  trx_detail_type_code
              ,trx.trx_number                           trx_number
              ,try.name                                 trx_type_name
              ,xvl.name                                 trx_event_name
              ,'Leasing and Finance Management'                       trx_application_name
              ,chr.contract_number                      contract_number
              ,NULL                                     asset_number
              ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
              ,pdt.NAME                                 product_name
              ,sty.NAME                                 trx_sty_name
              ,sty.styb_purpose_meaning                 trx_sty_purpose
              ,trx.currency_code                        currency_code
              ,glcc.concatenated_segments               trx_account_name
              ,ou.name                                  trx_operating_unit_name
              ,le.name                                  trx_legal_entity_name
              ,ledger.name                              trx_ledger_name
              ,rtryp.add_substract_code                 trx_activity_code
              ,gh.period_name                           trx_period_name
              -- Number Format Columns
              ,xl.entered_dr                            trx_dr_amount
              ,xl.entered_cr                            trx_cr_amount
              ,DECODE(rtryp.add_substract_code
                       ,'ADD',       txl.amount
                       ,'SUBTRACT', txl.amount * -1
                     )                                  trx_net_amount
              -- Its safe to fetch the CCID from XLA itself instead of the OKL Dist. table
              ,DECODE(xl.entered_cr
                       ,NULL, xl.code_combination_id    -- When Credit Amount is Null, it means Debit Distribution
                       ,NULL
                     )                                  trx_acc_dr_ccid
              ,DECODE(xl.entered_dr
                       ,NULL, xl.code_combination_id    -- When Debit Amount is Null, it means Credit Distribution
                       ,NULL
                     )                                  trx_acc_cr_ccid
              ,trx.set_of_books_id                      trx_ledger_id
              ,trx.org_id                               trx_operating_unit_id
              ,trx.legal_entity_id                      trx_legal_entity_id
              ,trx.khr_id                               trx_khr_id
              ,txl.kle_id                               txl_asset_id
              ,khr.pdt_id                               trx_pdt_id
              ,txl.sty_id                               trx_sty_id
              ,540                                      trx_application_id
              -- DATE Format Columns
              ,trx.transaction_date                     trx_date
              ,dist.gl_date                             gl_date
              -- Additional Columns
              ,trx.id                                   trx_id
              ,txl.id                                   trx_txl_id
              ,trx.try_id                               trx_try_id
              ,rep.report_id                            trx_report_id
              ,dist.id                                  trx_dist_id
              -- Occurance date of the Transaction, not the Transaction Effective Date
              ,trx.transaction_date                     trx_occ_date
              ,trx.date_accrual                         accrual_date
              ,'Lease'                                  source
        FROM    okl_trx_contracts_all     trx
               ,okl_txl_cntrct_lns_all    txl
               ,okl_trns_acc_dstrs_all    dist
               ,okl_trx_types_v           try
               ,okl_strm_type_v           sty
               ,okc_k_headers_all_b       chr
               ,okl_k_headers             khr
               ,okl_products              pdt
               ,okl_ae_tmpt_sets_all      aes
               ,okl_st_gen_tmpt_sets_all  gts
               -- SLA Entities
               ,xla_distribution_links    xd
               ,xla_ae_headers            xh
               ,xla_ae_lines              xl
               ,xla_events                xe
               ,xla_event_types_vl        xvl
               -- GL Tables: Import Reference, GL Header and Lines
               ,gl_import_references      gi
               ,gl_je_headers             gh
               ,gl_je_lines               gl
               -- OKL Report Definition Tables
               ,okl_reports_b             rep
               ,okl_report_trx_params     rtryp
               ,okl_rep_products_gt       pdt_gt
               -- To fetch Names
               ,gl_code_combinations_kfv  glcc
               ,hr_operating_units        ou
               ,xle_entity_profiles       le
               ,gl_ledgers_v              ledger
        WHERE  trx.id = txl.tcn_id
          AND  trx.try_id = try.id
          AND  try.accounting_event_class_code IS NOT NULL
          AND  txl.sty_id   = sty.id -- May be we dont need outer join here
          AND  dist.source_id = txl.id
          AND  dist.source_table = 'OKL_TXL_CNTRCT_LNS'
          -- Restrict to only one Distribution Line based on the Transaction Activity Code Add/Substract
          -- If its Add Consider only Debit, else if its Substract consider Credit
          AND
          (
            DECODE(xl.entered_cr, NULL, 'DEBIT_DIST', 'CREDIT_DIST' ) =
                 DECODE(rtryp.add_substract_code,
                 'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
            OR
            DECODE(xl.entered_dr, NULL, 'CREDIT_DIST', 'DEBIT_DIST' ) =
                DECODE(rtryp.add_substract_code,
                'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
          )
          AND  dist.posted_yn = 'Y'
          AND  trx.khr_id = chr.id
          AND  chr.id = khr.id
          AND  khr.pdt_id = pdt.id
          AND  pdt.aes_id = aes.id
          AND  aes.gts_id = gts.id
          -- OKL to SLA Link predicates
          AND  dist.posted_yn = 'Y'
          AND  dist.accounting_event_id = xe.event_id
          AND  xe.application_id = xvl.application_id
          AND  xvl.event_type_code = xe.event_type_code
          AND  xd.event_id = dist.accounting_event_id --XE,XD,XH,XL BEGIN
          AND  dist.id = xd.source_distribution_id_num_1
          AND  xd.application_id = 540
          AND  xd.ae_header_id = xh.ae_header_id
          AND  xl.ae_header_id = xh.ae_header_id
          AND  xd.ae_line_num = xl.ae_line_num --XD,XH,XL END
          -- From SLA to GL Tables Link
          AND  gi.gl_sl_link_id = xl.gl_sl_link_id --GL TABLES JOIN START
          AND  xl.ledger_id = gl.ledger_id
          AND  xl.ledger_id = p_ledger_id
          AND  gi.gl_sl_link_table = xl.gl_sl_link_table
          AND  gi.je_header_id = gh.je_header_id
          AND  gh.je_header_id = gl.je_header_id
          AND  gi.je_line_num = gl.je_line_num
          AND  gh.je_source = 'Lease'
          -- Important Predicate: gl_je_headers.status can be either Posted
          -- There can be even Unposted Entries
          AND  gh.status IN ( 'U', 'P' ) -- Unposted or Posted Entries
          -- Transaction should have occured in the Start and End date of the Context
          AND  trx.transaction_date >= p_start_date
          AND  trx.transaction_date <= p_end_date
          -- Add Predicates based on the report
          AND  rep.report_id = p_report_id
          AND  rtryp.report_id = rep.report_id
          AND  try.id = rtryp.try_id
          AND  nvl(nvl(rtryp.sty_id,txl.sty_id), - 1 )  = nvl(txl.sty_id, -1)
          -- Products restriction
          AND  pdt_gt.product_id = pdt.id
          -- Org., Ledger and Legal Entity Id restriction
          AND trx.org_id = NVL( p_org_id, trx.org_id )
          AND trx.legal_entity_id = NVL(p_le_id, trx.legal_entity_id )
          AND trx.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
          -- Predicates to fetch the Names
          AND ou.organization_id = trx.org_id
          AND le.legal_entity_id = trx.legal_entity_id
          AND ledger.ledger_id = trx.set_of_books_id
          AND glcc.code_combination_id = xl.code_combination_id
        -- End of Query Segment to fetch Unposted or Posted Acc. Entries from GL
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Lease Transactions Data in GT Table End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Lease Transactions ' || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );


    ---------------------------------------------------------------------------
    -- Query Segments to Populate the Receivables Transactions Data
    ---------------------------------------------------------------------------
    -- Start the stop watch
    l_trace_time := SYSDATE;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Receivables Invoice Transactions Data in GT Table Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             trx_detail_type_code        --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,trx_legal_entity_name       --value15_text
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,trx_acc_dr_ccid             --value4_num
            ,trx_acc_cr_ccid             --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_legal_entity_id         --value8_num
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
       FROM
      (
        -------------------------------------------------------------------------------------
        -- Query segments to fetch OKL-AR Invoice Transactions from OKL, Not moved to even AR
        -------------------------------------------------------------------------------------
        -- Query Segment to find the UnAccounted Receivables Invoice Transactions from OKL
        SELECT  'TRX_UNACCOUNTED_NO_EVENT'                trx_detail_type_code
                ,tai.trx_number                           trx_number
                ,try.name                                 trx_type_name
                ,NULL                                     trx_event_name
                ,'Receivables'                            trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tai.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,NULL                                     trx_dr_amount
                ,NULL                                     trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',       txd.amount
                         ,'SUBTRACT',  txd.amount * -1
                       )                                  trx_net_amount
                -- Note that in ATS Mode only distributions can fetch you the CCID
                -- In AMB mode, the Un-Accounted Distributions may not have the Code Combinations ID
                ,NULL                                     trx_acc_dr_ccid
                ,NULL                                     trx_acc_cr_ccid
                ,tai.set_of_books_id                      trx_ledger_id
                ,tai.org_id                               trx_operating_unit_id
                ,tai.legal_entity_id                      trx_legal_entity_id
                ,txd.khr_id                               trx_khr_id
                ,txd.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,txd.sty_id                               trx_sty_id
                ,222                                      trx_application_id
                -- DATE Format Columns
                ,tai.transaction_date                     trx_date
                ,NULL                                     gl_date  -- Invoice Date
                -- Additional Columns
                ,tai.id                                   trx_id
                ,til.id                                   trx_txl_id
                ,tai.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,NULL                                     trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,tai.transaction_date                     trx_occ_date
                ,'Receivables'                            source
          FROM  okl_txd_ar_ln_dtls_b           txd
               ,okl_txl_ar_inv_lns_b           til
               ,okl_trx_ar_invoices_b          tai
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,xle_entity_profiles            le
               ,gl_ledgers_v                   ledger
          WHERE -- OKL to AR Application Predicates
                txd.til_id_details = til.id -- Trx. Detail to Trx. Line
            AND til.tai_id = tai.id         -- Trx. Line to Trx. Header
            AND txd.khr_id = chr.id         -- Trx. Header to Contract
            -- OKL_ARINTF_PVT picks
            -- Possible values found: CANCELED, ERROR, SUBMITTED, PROCESSED, WORKING
            -- When the Trx. Status is SUBMITTED, then it means that the Trx. is just in OKL
            -- When the Trx. Status is PROCESSED, then it means that the Trx. may
            --   a. have moved to AR Import Tables but not yet imported successfully.
            --   b. Have been moved to AR Import Tables successfully..
            AND  (
                    tai.trx_status_code = 'SUBMITTED'
                  OR (
                         tai.trx_status_code = 'PROCESSED'
                     AND NOT EXISTS
                         (
                            SELECT 1
                              FROM ra_customer_trx_lines_all  rcl
                             WHERE txd.id = rcl.interface_line_attribute14
                               AND chr.contract_number = rcl.interface_line_attribute6
                         ) -- Close: Not Exists
                    ) -- Close: Only for Processed
                 ) -- Close: For both Submitted/Processed
            -- Notes: In R12 Found that the OKL_ARINTF_PVT picks only submitted trx.s and moves it to AR
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND tai.try_id = try.id
            AND txd.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND tai.transaction_date >= p_start_date
            AND tai.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,txd.sty_id), - 1 )  = nvl(txd.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND tai.org_id = NVL( p_org_id, tai.org_id )
            AND tai.legal_entity_id = NVL(p_le_id, tai.legal_entity_id )
            AND tai.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = tai.org_id
            AND le.legal_entity_id = tai.legal_entity_id
            AND ledger.ledger_id = tai.set_of_books_id
      UNION ALL
        -------------------------------------------------------------------------
        -- Query segments to fetch Invoice Transactions from AR related to OLM Contracts
        -------------------------------------------------------------------------
        -- Query Segment to find the UnAccounted Receivables Invoice Transactions from Receivables
        SELECT  'TRX_UNACCOUNTED'                         trx_detail_type_code
                ,rct.trx_number                           trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Receivables'                            trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tai.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,NULL                                     trx_dr_amount
                ,NULL                                     trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',       txd.amount
                         ,'SUBTRACT',  txd.amount * -1
                       )                                  trx_net_amount
                -- Note that in ATS Mode only distributions can fetch you the CCID
                -- In AMB mode, the Un-Accounted Distributions may not have the Code Combinations ID
                ,NULL                                     trx_acc_dr_ccid
                ,NULL                                     trx_acc_cr_ccid
                ,tai.set_of_books_id                      trx_ledger_id
                ,tai.org_id                               trx_operating_unit_id
                ,tai.legal_entity_id                      trx_legal_entity_id
                ,txd.khr_id                               trx_khr_id
                ,txd.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,txd.sty_id                               trx_sty_id
                ,222                                      trx_application_id
                -- DATE Format Columns
                ,tai.transaction_date                     trx_date
                ,rct.trx_date                             gl_date  -- Invoice Date
                -- Additional Columns
                ,tai.id                                   trx_id
                ,til.id                                   trx_txl_id
                ,tai.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,NULL                                     trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,tai.transaction_date                     trx_occ_date
                ,'Receivables'                            source
          FROM  okl_txd_ar_ln_dtls_b           txd
               ,okl_txl_ar_inv_lns_b           til
               ,okl_trx_ar_invoices_b          tai
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- AR Tables
               ,ra_customer_trx_lines_all      rcl
               ,ra_customer_trx_all            rct
               ,ra_cust_trx_line_gl_dist_all   rad
               -- XLA Tables
               ,xla_events                     xe
               ,xla_event_types_vl             xvl
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,xle_entity_profiles            le
               ,gl_ledgers_v                   ledger
          WHERE -- OKL to AR Application Predicates
                txd.til_id_details = til.id -- Trx. Detail to Trx. Line
            AND til.tai_id = tai.id         -- Trx. Line to Trx. Header
            AND txd.khr_id = chr.id         -- Trx. Header to Contract
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND tai.try_id = try.id
            AND txd.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND tai.transaction_date >= p_start_date
            AND tai.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,txd.sty_id), - 1 )  = nvl(txd.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND tai.org_id = NVL( p_org_id, tai.org_id )
            AND tai.legal_entity_id = NVL(p_le_id, tai.legal_entity_id )
            AND tai.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = tai.org_id
            AND le.legal_entity_id = tai.legal_entity_id
            AND ledger.ledger_id = tai.set_of_books_id
            -- OKL to AR Predicates
            AND txd.id = rcl.interface_line_attribute14
            AND chr.contract_number = rcl.interface_line_attribute6
            AND rct.customer_trx_id = rcl.customer_trx_id
            AND rct.org_id = nvl(p_org_id, rct.org_id)
            AND rcl.customer_trx_line_id = rad.customer_trx_line_id
            AND rct.customer_trx_id = rad.customer_trx_id
            -- AR to XLA Relations
            AND rad.event_id = xe.event_id
            AND xe.application_id = 222
            AND xe.event_status_code IN ( 'U', 'I' )
            AND xe.application_id = xvl.application_id
            AND xvl.event_type_code = xe.event_type_code
      UNION ALL
        -- Query Segment to find the UnPosted Receivables Invoice Transactions from Receivables
        -- And hence the Dr/Cr CCId are from XLA only
        -- Important Predicate again is xh.gl_transfer_status_code <> 'Y'
        SELECT  'TRX_UNPOSTED'                            trx_detail_type_code
                ,rct.trx_number                           trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Receivables'                            trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tai.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,xl.entered_dr                            trx_dr_amount
                ,xl.entered_cr                            trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',      txd.amount
                         ,'SUBTRACT', txd.amount * -1
                       )                                  trx_net_amount
                -- Its safe to fetch the CCID from XLA itself instead of the OKL Dist. table
                ,DECODE(xl.entered_cr
                         ,NULL, xl.code_combination_id    -- When Credit Amount is Null, it means Debit Distribution
                         ,NULL
                       )                                  trx_acc_dr_ccid
                ,DECODE(xl.entered_dr
                         ,NULL, xl.code_combination_id    -- When Debit Amount is Null, it means Credit Distribution
                         ,NULL
                       )                                  trx_acc_cr_ccid
                ,tai.set_of_books_id                      trx_ledger_id
                ,tai.org_id                               trx_operating_unit_id
                ,tai.legal_entity_id                      trx_legal_entity_id
                ,txd.khr_id                               trx_khr_id
                ,txd.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,txd.sty_id                               trx_sty_id
                ,222                                      trx_application_id
                -- DATE Format Columns
                ,tai.transaction_date                     trx_date
                ,rct.trx_date                             gl_date  -- Invoice Date
                -- Additional Columns
                ,tai.id                                   trx_id
                ,til.id                                   trx_txl_id
                ,tai.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,NULL                                     trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,tai.transaction_date                     trx_occ_date
                ,'Receivables'                            source
          FROM  okl_txd_ar_ln_dtls_b           txd
               ,okl_txl_ar_inv_lns_b           til
               ,okl_trx_ar_invoices_b          tai
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- AR Tables
               ,ra_customer_trx_lines_all      rcl
               ,ra_customer_trx_all            rct
               ,ra_cust_trx_line_gl_dist_all   rad
               -- XLA Tables
               ,xla_events                     xe
               ,xla_event_types_vl             xvl
               ,xla_distribution_links         xd
               ,xla_ae_headers                 xh
               ,xla_ae_lines                   xl
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,xle_entity_profiles            le
               ,gl_ledgers_v                   ledger
          WHERE -- OKL to AR Application Predicates
                txd.til_id_details = til.id -- Trx. Detail to Trx. Line
            AND til.tai_id = tai.id         -- Trx. Line to Trx. Header
            AND txd.khr_id = chr.id         -- Trx. Header to Contract
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND tai.try_id = try.id
            AND txd.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND tai.transaction_date >= p_start_date
            AND tai.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,txd.sty_id), - 1 )  = nvl(txd.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND tai.org_id = NVL( p_org_id, tai.org_id )
            AND tai.legal_entity_id = NVL(p_le_id, tai.legal_entity_id )
            AND tai.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = tai.org_id
            AND le.legal_entity_id = tai.legal_entity_id
            AND ledger.ledger_id = tai.set_of_books_id
            -- OKL to AR Predicates
            AND txd.id = rcl.interface_line_attribute14
            AND chr.contract_number = rcl.interface_line_attribute6
            AND rct.customer_trx_id = rcl.customer_trx_id
            AND rct.org_id = nvl(p_org_id, rct.org_id )
            AND rcl.customer_trx_line_id = rad.customer_trx_line_id
            AND rct.customer_trx_id = rad.customer_trx_id
            -- AR to XLA Relations
            AND rad.event_id = xe.event_id
            AND xe.application_id = 222
            AND xe.event_status_code = 'P'
            AND xe.application_id = xvl.application_id
            AND xvl.event_type_code = xe.event_type_code
            AND xd.event_id = rad.event_id
            AND xd.source_distribution_id_num_1 = rad.cust_trx_line_gl_dist_id
            AND xd.application_id = 222
            AND xd.ae_header_id = xh.ae_header_id
            AND xl.ae_header_id = xh.ae_header_id
            AND xl.ledger_id = p_ledger_id
            AND xd.ae_line_num = xl.ae_line_num --XD,XH,XL END
            -- Important Predicate: XLA Distribution Links should not have the GL Import Link ID
            AND  xh.gl_transfer_status_code <> 'Y' -- Not Imported to GL Yet
            -- Restrict to only one Distribution Line based on the Transaction Activity Code Add/Substract
            -- If its Add Consider only Debit, else if its Substract consider Credit
            AND
            (
              DECODE(xl.entered_cr, NULL, 'DEBIT_DIST', 'CREDIT_DIST' ) =
                   DECODE(rtryp.add_substract_code,
                   'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
              OR
              DECODE(xl.entered_dr, NULL, 'CREDIT_DIST', 'DEBIT_DIST' ) =
                  DECODE(rtryp.add_substract_code,
                  'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
            )
      UNION ALL
        -- Query Segment to find the Imported Receivables Invoice Transactions from GL
        -- Note that that the Acc. Entry may or may not be posted into GL.
        -- Important Predicate again is xla_ae_lines.gl_sl_link_id IS NOT NULL
        SELECT   DECODE( gh.status
                         ,'U',  'TRX_UNPOSTED'  -- Unposted Transactions
                         ,'P',  'TRX_POSTED'    -- Posted Transactions
                     )                                    trx_detail_type_code
                ,rct.trx_number                           trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Receivables'                            trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tai.currency_code                        currency_code
                ,glcc.concatenated_segments               trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,gh.period_name                           trx_period_name
                -- Number Format Columns
                ,xl.entered_dr                            trx_dr_amount
                ,xl.entered_cr                            trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',      txd.amount
                         ,'SUBTRACT', txd.amount * -1
                       )                                  trx_net_amount
                -- Its safe to fetch the CCID from XLA itself instead of the OKL Dist. table
                ,DECODE(xl.entered_cr
                         ,NULL, xl.code_combination_id    -- When Credit Amount is Null, it means Debit Distribution
                         ,NULL
                       )                                  trx_acc_dr_ccid
                ,DECODE(xl.entered_dr
                         ,NULL, xl.code_combination_id    -- When Debit Amount is Null, it means Credit Distribution
                         ,NULL
                       )
                ,tai.set_of_books_id                      trx_ledger_id
                ,tai.org_id                               trx_operating_unit_id
                ,tai.legal_entity_id                      trx_legal_entity_id
                ,txd.khr_id                               trx_khr_id
                ,txd.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,txd.sty_id                               trx_sty_id
                ,222                                      trx_application_id
                -- DATE Format Columns
                ,tai.transaction_date                     trx_date
                ,rct.trx_date                             gl_date  -- Invoice Date
                -- Additional Columns
                ,tai.id                                   trx_id
                ,til.id                                   trx_txl_id
                ,tai.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,NULL                                     trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,tai.transaction_date                     trx_occ_date
                ,'Receivables'                            source
          FROM  okl_txd_ar_ln_dtls_b           txd
               ,okl_txl_ar_inv_lns_b           til
               ,okl_trx_ar_invoices_b          tai
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- AR Tables
               ,ra_customer_trx_lines_all      rcl
               ,ra_customer_trx_all            rct
               ,ra_cust_trx_line_gl_dist_all   rad
               -- XLA Tables
               ,xla_events                     xe
               ,xla_event_types_vl             xvl
               ,xla_distribution_links         xd
               ,xla_ae_headers                 xh
               ,xla_ae_lines                   xl
               -- GL Tables: Import Reference, GL Header and Lines
               ,gl_import_references           gi
               ,gl_je_headers                  gh
               ,gl_je_lines                    gl
               ,gl_code_combinations_kfv       glcc
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,xle_entity_profiles            le
               ,gl_ledgers_v                   ledger
          WHERE -- OKL to AR Application Predicates
                txd.til_id_details = til.id -- Trx. Detail to Trx. Line
            AND til.tai_id = tai.id         -- Trx. Line to Trx. Header
            AND txd.khr_id = chr.id         -- Trx. Header to Contract
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND tai.try_id = try.id
            AND txd.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND tai.transaction_date >= p_start_date
            AND tai.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,txd.sty_id), - 1 )  = nvl(txd.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND tai.org_id = NVL( p_org_id, tai.org_id )
            AND tai.legal_entity_id = NVL(p_le_id, tai.legal_entity_id )
            AND tai.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = tai.org_id
            AND le.legal_entity_id = tai.legal_entity_id
            AND ledger.ledger_id = tai.set_of_books_id
            -- OKL to AR Predicates
            AND txd.id = rcl.interface_line_attribute14
            AND chr.contract_number = rcl.interface_line_attribute6
            AND rct.customer_trx_id = rcl.customer_trx_id
            AND rct.org_id = nvl(p_org_id, rct.org_id )
            AND rcl.customer_trx_line_id = rad.customer_trx_line_id
            AND rct.customer_trx_id = rad.customer_trx_id
            -- AR to XLA Relations
            AND rad.event_id = xe.event_id
            AND xe.application_id = 222
            AND xe.event_status_code = 'P'
            AND xe.application_id = xvl.application_id
            AND xvl.event_type_code = xe.event_type_code
            AND xd.event_id = rad.event_id
            AND xd.source_distribution_id_num_1 = rad.cust_trx_line_gl_dist_id
            AND xd.application_id = 222
            AND xd.ae_header_id = xh.ae_header_id
            AND xl.ae_header_id = xh.ae_header_id
            AND xl.ledger_id = p_ledger_id
            AND glcc.code_combination_id = xl.code_combination_id
            AND xd.ae_line_num = xl.ae_line_num --XD,XH,XL END
            -- Restrict to only one Distribution Line based on the Transaction Activity Code Add/Substract
            -- If its Add Consider only Debit, else if its Substract consider Credit
            AND
            (
              DECODE(xl.entered_cr, NULL, 'DEBIT_DIST', 'CREDIT_DIST' ) =
                   DECODE(rtryp.add_substract_code,
                   'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
              OR
              DECODE(xl.entered_dr, NULL, 'CREDIT_DIST', 'DEBIT_DIST' ) =
                  DECODE(rtryp.add_substract_code,
                  'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
            )
            -- From SLA to GL Tables Link
            -- Important Predicate: XLA Distribution Links should have the GL Import Link ID
            AND  gi.gl_sl_link_id = xl.gl_sl_link_id --GL TABLES JOIN START
            AND  gl.ledger_id = xl.ledger_id
            AND  gi.gl_sl_link_table = xl.gl_sl_link_table
            AND  gi.je_header_id = gh.je_header_id
            AND  gh.je_header_id = gl.je_header_id
            AND  gi.je_line_num = gl.je_line_num
            --  AND  gl.code_combination_id = cc.ccid
            AND  gh.je_source = 'Receivables'
            -- Important Predicate: gl_je_headers.status can be either Posted
            -- There can be even Unposted Entries
            AND  gh.status IN ( 'U', 'P' ) -- Unposted or Posted Entries
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Receivables Invoice Transactions Data in GT Table End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Receivables Invoice Transactions '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

    ---------------------------------------------------------------------------
    -- Query Segments to Populate the Receivables Adjustments Transactions Data
    ---------------------------------------------------------------------------
    -- Start the stop watch
    l_trace_time := SYSDATE;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Receivables Adjustments Transactions Data in GT Table Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             trx_detail_type_code        --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,trx_legal_entity_name       --value15_text
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,trx_acc_dr_ccid             --value4_num
            ,trx_acc_cr_ccid             --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_legal_entity_id         --value8_num
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
        FROM
       (
        -- Query Segment to find the OLM-AR Adjustment Transactions
        -- which are not yet moved to AR even.
        -- Important predicate ajl.receivables_adjustment_id IS NULL
        SELECT  'TRX_UNACCOUNTED_NO_EVENT'                trx_detail_type_code
                ,chr.contract_number || adj.adjustment_reason_code
                                                          trx_number
                ,try.name                                 trx_type_name
                ,NULL                                     trx_event_name
                ,'Receivables'                            trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tai.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,NULL                                     trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,NULL                                     trx_dr_amount
                ,NULL                                     trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',       ajl.amount
                         ,'SUBTRACT',  ajl.amount * -1
                       )                                  trx_net_amount
                -- Note that in ATS Mode only distributions can fetch you the CCID
                -- In AMB mode, the Un-Accounted Distributions may not have the Code Combinations ID
                ,NULL                                     trx_acc_dr_ccid
                ,NULL                                     trx_acc_cr_ccid
                ,tai.set_of_books_id                     trx_ledger_id
                ,adj.org_id                               trx_operating_unit_id
                ,NULL                                     trx_legal_entity_id
                ,ajl.khr_id                               trx_khr_id
                ,ajl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,ajl.sty_id                               trx_sty_id
                ,222                                      trx_application_id
                -- DATE Format Columns
                ,adj.transaction_date                     trx_date
                ,adj.gl_date                              gl_date  -- Invoice Date
                -- Additional Columns
                ,adj.id                                   trx_id
                ,ajl.id                                   trx_txl_id
                ,adj.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,NULL                                     trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,adj.transaction_date                     trx_occ_date
                ,'Receivables - Adjustments'              source
          FROM  -- OKL AR Adjustment Entities
                okl_trx_ar_adjsts_all_b        adj
               ,okl_txl_adjsts_lns_all_b       ajl
               ,okl_txl_ar_inv_lns_b           til
               ,okl_trx_ar_invoices_b          tai
               -- OKL Entities
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,gl_ledgers_v                   ledger
          WHERE -- OKL - AR Adjustment Application Predicates
                adj.id     = ajl.adj_id
            AND ajl.til_id = til.id
            -- Important Predicate
            AND ajl.receivables_adjustment_id IS NULL
            -- The above predicate ensures that the OLM-AR Adjustment Trx. is not yet moved to AR even.
            AND til.tai_id = tai.id
            AND ajl.khr_id = khr.id
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND adj.try_id = try.id
            AND ajl.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND adj.transaction_date >= p_start_date
            AND adj.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,ajl.sty_id), - 1 )  = nvl(ajl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND adj.org_id = NVL( p_org_id, adj.org_id )
            AND tai.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = adj.org_id
            AND ledger.ledger_id = tai.set_of_books_id
      UNION ALL
        -- Query Segment to find the UnAccounted Receivables Invoice Transactions from Receivables
        SELECT  'TRX_UNACCOUNTED'                         trx_detail_type_code
                ,radj.adjustment_number                   trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Receivables'                            trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tai.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,NULL                                     trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,NULL                                     trx_dr_amount
                ,NULL                                     trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',       ajl.amount
                         ,'SUBTRACT',  ajl.amount * -1
                       )                                  trx_net_amount
                -- Note that in ATS Mode only distributions can fetch you the CCID
                -- In AMB mode, the Un-Accounted Distributions may not have the Code Combinations ID
                ,NULL                                     trx_acc_dr_ccid
                ,NULL                                     trx_acc_cr_ccid
                ,radj.set_of_books_id                     trx_ledger_id
                ,adj.org_id                               trx_operating_unit_id
                ,NULL                                     trx_legal_entity_id
                ,ajl.khr_id                               trx_khr_id
                ,ajl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,ajl.sty_id                               trx_sty_id
                ,222                                      trx_application_id
                -- DATE Format Columns
                ,adj.transaction_date                     trx_date
                ,adj.gl_date                              gl_date  -- Invoice Date
                -- Additional Columns
                ,adj.id                                   trx_id
                ,ajl.id                                   trx_txl_id
                ,adj.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,NULL                                     trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,adj.transaction_date                     trx_occ_date
                ,'Receivables - Adjustments'              source
          FROM  -- OKL AR Adjustment Entities
                okl_trx_ar_adjsts_all_b        adj
               ,okl_txl_adjsts_lns_all_b       ajl
               ,okl_txl_ar_inv_lns_b           til
               ,okl_trx_ar_invoices_b          tai
               -- OKL Entities
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- AR Tables
               ,ar_adjustments_all             radj
               -- XLA Tables
               ,xla_events                     xe
               ,xla_event_types_vl             xvl
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,gl_ledgers_v                   ledger
          WHERE -- OKL - AR Adjustment Application Predicates
                adj.id     = ajl.adj_id
            AND ajl.til_id = til.id
            AND til.tai_id = tai.id
            AND ajl.khr_id = khr.id
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND adj.try_id = try.id
            AND ajl.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND adj.transaction_date >= p_start_date
            AND adj.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,ajl.sty_id), - 1 )  = nvl(ajl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND adj.org_id = NVL( p_org_id, adj.org_id )
            AND radj.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = adj.org_id
            AND ledger.ledger_id = radj.set_of_books_id
            -- OKL to AR Predicates
            AND ajl.receivables_adjustment_id = radj.adjustment_id
            -- AR to XLA Relations
            AND radj.event_id = xe.event_id
            AND xe.application_id = 222
            AND xe.event_status_code IN ( 'U', 'I' )
            AND xe.application_id = xvl.application_id
            AND xvl.event_type_code = xe.event_type_code
      UNION ALL
        -- Query Segment to find the  Receivables Adjustment Transactions in SLA
        -- Only Adjustment Transactions that are not transferred to GL will be queried up
        --   by this segment.
        -- And hence the Dr/Cr CCId are from XLA only
        -- Important Predicate again is xh.gl_transfer_status_code <> 'Y'
        SELECT  'TRX_UNPOSTED'                            trx_detail_type_code
                ,radj.adjustment_number                   trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Receivables'                            trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tai.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,NULL                                     trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,xl.entered_dr                            trx_dr_amount
                ,xl.entered_cr                            trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',      NVL(xl.entered_dr, xl.entered_cr)
                         ,'SUBTRACT', NVL(xl.entered_dr, xl.entered_cr) * -1
                       )                                  trx_net_amount
                -- Its safe to fetch the CCID from XLA itself instead of the OKL Dist. table
                ,DECODE(xl.entered_cr
                         ,NULL, xl.code_combination_id    -- When Credit Amount is Null, it means Debit Distribution
                         ,NULL
                       )                                  trx_acc_dr_ccid
                ,DECODE(xl.entered_dr
                         ,NULL, xl.code_combination_id    -- When Debit Amount is Null, it means Credit Distribution
                         ,NULL
                       )                                  trx_acc_cr_ccid
                ,radj.set_of_books_id                     trx_ledger_id
                ,adj.org_id                               trx_operating_unit_id
                ,NULL                                     trx_legal_entity_id
                ,ajl.khr_id                               trx_khr_id
                ,ajl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,ajl.sty_id                               trx_sty_id
                ,222                                      trx_application_id
                -- DATE Format Columns
                ,adj.transaction_date                     trx_date
                ,adj.gl_date                              gl_date  -- Invoice Date
                -- Additional Columns
                ,adj.id                                   trx_id
                ,ajl.id                                   trx_txl_id
                ,adj.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,NULL                                     trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,adj.transaction_date                     trx_occ_date
                ,'Receivables - Adjustments'              source
          FROM  -- OKL AR Adjustment Entities
                okl_trx_ar_adjsts_all_b        adj
               ,okl_txl_adjsts_lns_all_b       ajl
               ,okl_txl_ar_inv_lns_b           til
               ,okl_trx_ar_invoices_b          tai
               -- OKL Entities
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- AR Tables
               ,ar_adjustments_all             radj
               ,ar_distributions_all           rdist
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,gl_ledgers_v                   ledger
               -- XLA Tables
               ,xla_events                     xe
               ,xla_event_types_vl             xvl
               ,xla_distribution_links         xd
               ,xla_ae_headers                 xh
               ,xla_ae_lines                   xl
          WHERE -- OKL - AR Adjustment Application Predicates
                adj.id     = ajl.adj_id
            AND ajl.til_id = til.id
            AND til.tai_id = tai.id
            AND ajl.khr_id = khr.id
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND adj.try_id = try.id
            AND ajl.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND adj.transaction_date >= p_start_date
            AND adj.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,ajl.sty_id), - 1 )  = nvl(ajl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND adj.org_id = NVL( p_org_id, adj.org_id )
            AND radj.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = adj.org_id
            AND ledger.ledger_id = radj.set_of_books_id
            -- OKL to AR Predicates
            AND ajl.receivables_adjustment_id = radj.adjustment_id
            AND radj.adjustment_id = rdist.source_id
            AND rdist.source_type = 'ADJ'  -- Assumption
            AND rdist.source_table = 'ADJ' -- Assumption
            -- AR to XLA Relations
            AND radj.event_id = xe.event_id
            AND xe.application_id = 222
            AND xe.event_status_code IN ( 'U', 'I' )
            AND xe.application_id = xvl.application_id
            AND xvl.event_type_code = xe.event_type_code
            AND xd.event_id = radj.event_id
            AND xd.application_id = 222
            AND xd.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
            AND xd.source_distribution_id_num_1 = rdist.line_id
            AND xd.ae_header_id = xh.ae_header_id
            AND xl.ae_header_id = xh.ae_header_id
            AND xl.ledger_id = p_ledger_id
            AND xd.ae_line_num = xl.ae_line_num --XD,XH,XL END
            -- Important Predicate: XLA Distribution Links should not have the GL Import Link ID
            AND  xh.gl_transfer_status_code <> 'Y' -- Not Imported to GL Yet
            -- Restrict to only one Distribution Line based on the Transaction Activity Code Add/Substract
            -- If its Add Consider only Debit, else if its Substract consider Credit
            AND
            (
              DECODE(xl.entered_cr, NULL, 'DEBIT_DIST', 'CREDIT_DIST' ) =
                   DECODE(rtryp.add_substract_code,
                   'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
              OR
              DECODE(xl.entered_dr, NULL, 'CREDIT_DIST', 'DEBIT_DIST' ) =
                  DECODE(rtryp.add_substract_code,
                  'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
            )
      UNION ALL
        -- Query Segment to find the  Receivables Adjustment Transactions in GL#
        -- Note that: These Adjustment Transactions may or may not be Posted in GL#,
        --  but got imported in GL# though.
        SELECT  DECODE( gh.status
                         ,'U',  'TRX_UNPOSTED'  -- Unposted Transactions
                         ,'P',  'TRX_POSTED'    -- Posted Transactions
                     )                                    trx_detail_type_code
                ,radj.adjustment_number                   trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Receivables'                            trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tai.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,NULL                                     trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,xl.entered_dr                            trx_dr_amount
                ,xl.entered_cr                            trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',      NVL(xl.entered_dr, xl.entered_cr)
                         ,'SUBTRACT', NVL(xl.entered_dr, xl.entered_cr) * -1
                       )                                  trx_net_amount
                -- Its safe to fetch the CCID from XLA itself instead of the OKL Dist. table
                ,DECODE(xl.entered_cr
                         ,NULL, xl.code_combination_id    -- When Credit Amount is Null, it means Debit Distribution
                         ,NULL
                       )                                  trx_acc_dr_ccid
                ,DECODE(xl.entered_dr
                         ,NULL, xl.code_combination_id    -- When Debit Amount is Null, it means Credit Distribution
                         ,NULL
                       )                                  trx_acc_cr_ccid
                ,radj.set_of_books_id                     trx_ledger_id
                ,adj.org_id                               trx_operating_unit_id
                ,NULL                                     trx_legal_entity_id
                ,ajl.khr_id                               trx_khr_id
                ,ajl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,ajl.sty_id                               trx_sty_id
                ,222                                      trx_application_id
                -- DATE Format Columns
                ,adj.transaction_date                     trx_date
                ,adj.gl_date                              gl_date  -- Invoice Date
                -- Additional Columns
                ,adj.id                                   trx_id
                ,ajl.id                                   trx_txl_id
                ,adj.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,NULL                                     trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,adj.transaction_date                     trx_occ_date
                ,'Receivables - Adjustments'              source
          FROM  -- OKL AR Adjustment Entities
                okl_trx_ar_adjsts_all_b        adj
               ,okl_txl_adjsts_lns_all_b       ajl
               ,okl_txl_ar_inv_lns_b           til
               ,okl_trx_ar_invoices_b          tai
               -- OKL Entities
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- AR Tables
               ,ar_adjustments_all             radj
               ,ar_distributions_all           rdist
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,gl_ledgers_v                   ledger
               -- XLA Tables
               ,xla_events                     xe
               ,xla_event_types_vl             xvl
               ,xla_distribution_links         xd
               ,xla_ae_headers                 xh
               ,xla_ae_lines                   xl
               -- GL Tables: Import Reference, GL Header and Lines
               ,gl_import_references           gi
               ,gl_je_headers                  gh
               ,gl_je_lines                    gl
               ,gl_code_combinations_kfv       glcc
          WHERE -- OKL - AR Adjustment Application Predicates
                adj.id     = ajl.adj_id
            AND ajl.til_id = til.id
            AND til.tai_id = tai.id
            AND ajl.khr_id = khr.id
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND adj.try_id = try.id
            AND ajl.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND adj.transaction_date >= p_start_date
            AND adj.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,ajl.sty_id), - 1 )  = nvl(ajl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND adj.org_id = NVL( p_org_id, adj.org_id )
            AND radj.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = adj.org_id
            AND ledger.ledger_id = radj.set_of_books_id
            -- OKL to AR Predicates
            AND ajl.receivables_adjustment_id = radj.adjustment_id
            AND radj.adjustment_id = rdist.source_id
            AND rdist.source_type = 'ADJ'  -- Assumption
            AND rdist.source_table = 'ADJ' -- Assumption
            -- AR to XLA Relations
            AND radj.event_id = xe.event_id
            AND xe.application_id = 222
            AND xe.event_status_code IN ( 'U', 'I' )
            AND xe.application_id = xvl.application_id
            AND xvl.event_type_code = xe.event_type_code
            AND xd.event_id = radj.event_id
            AND xd.application_id = 222
            AND xd.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
            AND xd.source_distribution_id_num_1 = rdist.line_id
            AND xd.ae_header_id = xh.ae_header_id
            AND xl.ae_header_id = xh.ae_header_id
            AND xl.ledger_id = p_ledger_id
            AND xd.ae_line_num = xl.ae_line_num --XD,XH,XL END
            -- Restrict to only one Distribution Line based on the Transaction Activity Code Add/Substract
            -- If its Add Consider only Debit, else if its Substract consider Credit
            AND
            (
              DECODE(xl.entered_cr, NULL, 'DEBIT_DIST', 'CREDIT_DIST' ) =
                   DECODE(rtryp.add_substract_code,
                   'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
              OR
              DECODE(xl.entered_dr, NULL, 'CREDIT_DIST', 'DEBIT_DIST' ) =
                  DECODE(rtryp.add_substract_code,
                  'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
            )
            -- From SLA to GL Tables Link
            -- Important Predicate: XLA Distribution Links should have the GL Import Link ID
            AND  gi.gl_sl_link_id = xl.gl_sl_link_id --GL TABLES JOIN START
            AND  gl.ledger_id = xl.ledger_id
            AND  gi.gl_sl_link_table = xl.gl_sl_link_table
            AND  gi.je_header_id = gh.je_header_id
            AND  gh.je_header_id = gl.je_header_id
            AND  gi.je_line_num = gl.je_line_num
            --  AND  gl.code_combination_id = cc.ccid
            AND  gh.je_source = 'Receivables'
            -- Important Predicate: gl_je_headers.status can be either Posted
            -- There can be even Unposted Entries
            AND  gh.status IN ( 'U', 'P' ) -- Unposted or Posted Entries
      );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Receivables Adjustment Transactions Data in GT Table End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Receivables Adjustment Transactions '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );
    ---------------------------------------------------------------------------
    -- Query Segments to Populate the Payables Invoice Transactions Data
    ---------------------------------------------------------------------------
    -- Start the stop watch
    l_trace_time := SYSDATE;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Payables Invoice Transactions Data in GT Table Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             trx_detail_type_code        --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,trx_legal_entity_name       --value15_text
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,trx_acc_dr_ccid             --value4_num
            ,trx_acc_cr_ccid             --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_legal_entity_id         --value8_num
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
        FROM
       (
        ---------------------------------------------------------------------------------------
        -- Query Segment to find the OKL-AP Invoice Transactions which are not moved to AP Yet.
        ---------------------------------------------------------------------------------------
        SELECT  'TRX_UNACCOUNTED_NO_EVENT'                trx_detail_type_code
                ,tap.invoice_number                       trx_number
                ,try.name                                 trx_type_name
                ,NULL                                     trx_event_name
                ,'Payables'                               trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tap.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,NULL                                     trx_dr_amount
                ,NULL                                     trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',       tpl.amount
                         ,'SUBTRACT',  tpl.amount * -1
                       )                                  trx_net_amount
                -- Note that in ATS Mode only distributions can fetch you the CCID
                -- In AMB mode, the Un-Accounted Distributions may not have the Code Combinations ID
                ,NULL                                     trx_acc_dr_ccid
                ,NULL                                     trx_acc_cr_ccid
                ,tap.set_of_books_id                      trx_ledger_id
                ,tap.org_id                               trx_operating_unit_id
                ,tap.legal_entity_id                      trx_legal_entity_id
                ,tpl.khr_id                               trx_khr_id
                ,tpl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,tpl.sty_id                               trx_sty_id
                ,200                                      trx_application_id
                -- DATE Format Columns
                ,tap.transaction_date                     trx_date
                ,NULL                                     gl_date  -- Invoice Date
                -- Additional Columns
                ,tap.id                                   trx_id
                ,tpl.id                                   trx_txl_id
                ,tap.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,NULL                                     trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,tap.transaction_date                     trx_occ_date
                ,'Payables'                               source
          FROM
                okl_txl_ap_inv_lns_all_b       tpl
               ,okl_trx_ap_invs_all_b          tap
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,xle_entity_profiles            le
               ,gl_ledgers_v                   ledger
          WHERE
                -- OKL to AP Application Predicates
                tpl.tap_id = tap.id
            --  Restrict to only transactions which are not yet moved to AP
            -- Observation: Only Funding requests need to be in APPROVED status
            -- For others Entered and Approved can be used for processing to move to AP
            AND (
                  (  tap.FUNDING_TYPE_CODE IS NULL AND
                       NVL(tap.trx_status_code, 'ENTERED') IN ( 'ENTERED', 'APPROVED' ) )
                  OR
                  (  tap.FUNDING_TYPE_CODE IS NOT NULL AND
                       NVL(tap.trx_status_code, 'APPROVED') in ( 'APPROVED')
                  )
                )
            AND tpl.khr_id = khr.id
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND tap.try_id = try.id
            AND tpl.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND tap.transaction_date >= p_start_date
            AND tap.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,tpl.sty_id), - 1 )  = nvl(tpl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND tap.org_id = NVL( p_org_id, tap.org_id )
            AND tap.legal_entity_id = NVL(p_le_id, tap.legal_entity_id )
            AND tap.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = tap.org_id
            AND le.legal_entity_id = tap.legal_entity_id
            AND ledger.ledger_id = tap.set_of_books_id
     UNION ALL
        -- Query Segment to find the UnAccounted Payables Invoice Transactions from Payables
        --
        -- Logic: Starting from okl_txl_ap lines go to the Invoice Line
        --        in AP and its Invoice Distributions. Invoice Distributions stamps the
        --        Accounting Event Id.
        -- Assumption: For a Given OKL AP Inv Lines, we assume that there is a one-one mapping
        --             to Invoice Line and to its Distribution.
        -- The Potential issue may be with the above assumption itself, as we found
        -- multiple Distributions for a given Invoice Line Id. Hence, used the
        -- LINE_TYPE_LOOKUP_CODE = 'ITEM' predicate. Not sure about this though !!
        SELECT  'TRX_UNACCOUNTED'                         trx_detail_type_code
                ,inv.invoice_num                          trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Payables'                               trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tap.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,NULL                                     trx_dr_amount
                ,NULL                                     trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',       tpl.amount
                         ,'SUBTRACT',  tpl.amount * -1
                       )                                  trx_net_amount
                -- Note that in ATS Mode only distributions can fetch you the CCID
                -- In AMB mode, the Un-Accounted Distributions may not have the Code Combinations ID
                ,NULL                                     trx_acc_dr_ccid
                ,NULL                                     trx_acc_cr_ccid
                ,tap.set_of_books_id                      trx_ledger_id
                ,tap.org_id                               trx_operating_unit_id
                ,tap.legal_entity_id                      trx_legal_entity_id
                ,tpl.khr_id                               trx_khr_id
                ,tpl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,tpl.sty_id                               trx_sty_id
                ,200                                      trx_application_id
                -- DATE Format Columns
                ,tap.transaction_date                     trx_date
                ,inv.invoice_date                         gl_date  -- Invoice Date
                -- Additional Columns
                ,tap.id                                   trx_id
                ,tpl.id                                   trx_txl_id
                ,tap.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,invdist.invoice_distribution_id          trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,tap.transaction_date                     trx_occ_date
                ,'Payables'                               source
          FROM
                okl_txl_ap_inv_lns_all_b       tpl
               ,okl_trx_ap_invs_all_b          tap
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- AP Tables
               ,ap_invoices_all                inv
               ,ap_invoice_lines_all           lin
               ,ap_invoice_distributions_all   invdist
               -- XLA Tables
               ,xla_events                     xe
               ,xla_event_types_vl             xvl
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,xle_entity_profiles            le
               ,gl_ledgers_v                   ledger
          WHERE
                -- OKL to AP Application Predicates
                tpl.tap_id = tap.id
            AND tpl.khr_id = khr.id
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND tap.try_id = try.id
            AND tpl.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND tap.transaction_date >= p_start_date
            AND tap.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,tpl.sty_id), - 1 )  = nvl(tpl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND tap.org_id = NVL( p_org_id, tap.org_id )
            AND tap.legal_entity_id = NVL(p_le_id, tap.legal_entity_id )
            AND tap.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = tap.org_id
            AND le.legal_entity_id = tap.legal_entity_id
            AND ledger.ledger_id = tap.set_of_books_id
            -- OKL to AP Invoice Lines Predicates
            AND invdist.line_type_lookup_code = 'ITEM' -- Need to verify
            AND invdist.invoice_id = lin.invoice_id
            AND invdist.invoice_line_number = lin.line_number
            AND lin.application_id = 540
            AND lin.product_table = 'OKL_TXL_AP_INV_LNS_ALL_B'
            AND lin.reference_key1 = tpl.id
            AND lin.invoice_id = inv.invoice_id
            -- AP to XLA Relations
           AND  invdist.accounting_event_id = xe.event_id
           AND  xe.application_id = 200 -- Payables
           AND  xe.event_status_code IN ( 'U', 'I' ) -- Un Accounted Or Errored out
           AND xe.application_id = xvl.application_id
           AND xvl.event_type_code = xe.event_type_code

      UNION ALL
        -- Query Segment to find the Unposted Payables Invoice Transactions from Payables
        --
        -- Logic: Starting from okl_txl_ap lines go to the Invoice Line
        --        in AP and its Invoice Distributions. Invoice Distributions stamps the
        --        Accounting Event Id.
        -- Assumption: For a Given OKL AP Inv Lines, we assume that there is a one-one mapping
        --             to Invoice Line and to its Distribution.
        -- The Potential issue may be with the above assumption itself, as we found
        -- multiple Distributions for a given Invoice Line Id. Hence, used the
        -- LINE_TYPE_LOOKUP_CODE = 'ITEM' predicate. Not sure about this though !!
        -- Important Predicate: xh.gl_transfer_status_code <> 'Y'
        SELECT  'TRX_UNPOSTED'                            trx_detail_type_code
                ,inv.invoice_num                          trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Payables'                               trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tap.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,NULL                                     trx_period_name
                -- Number Format Columns
                ,xl.entered_dr                            trx_dr_amount
                ,xl.entered_cr                            trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',      tpl.amount
                         ,'SUBTRACT', tpl.amount * -1
                       )                                  trx_net_amount
                -- Its safe to fetch the CCID from XLA itself instead of the OKL Dist. table
                ,DECODE(xl.entered_cr
                         ,NULL, xl.code_combination_id    -- When Credit Amount is Null, it means Debit Distribution
                         ,NULL
                       )                                  trx_acc_dr_ccid
                ,DECODE(xl.entered_dr
                         ,NULL, xl.code_combination_id    -- When Debit Amount is Null, it means Credit Distribution
                         ,NULL
                       )                                  trx_acc_cr_ccid
                ,tap.set_of_books_id                      trx_ledger_id
                ,tap.org_id                               trx_operating_unit_id
                ,tap.legal_entity_id                      trx_legal_entity_id
                ,tpl.khr_id                               trx_khr_id
                ,tpl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,tpl.sty_id                               trx_sty_id
                ,200                                      trx_application_id
                -- DATE Format Columns
                ,tap.transaction_date                     trx_date
                ,inv.invoice_date                         gl_date  -- Invoice Date
                -- Additional Columns
                ,tap.id                                   trx_id
                ,tpl.id                                   trx_txl_id
                ,tap.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,invdist.invoice_distribution_id          trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,tap.transaction_date                     trx_occ_date
                ,'Payables'                               source
          FROM
                okl_txl_ap_inv_lns_all_b       tpl
               ,okl_trx_ap_invs_all_b          tap
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- AP Tables
               ,ap_invoices_all                inv
               ,ap_invoice_lines_all           lin
               ,ap_invoice_distributions_all   invdist
               -- XLA Tables
               ,xla_events                     xe
               ,xla_event_types_vl             xvl
               ,xla_distribution_links         xd
               ,xla_ae_headers                 xh
               ,xla_ae_lines                   xl
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,xle_entity_profiles            le
               ,gl_ledgers_v                   ledger
          WHERE
                -- OKL to AP Application Predicates
                tpl.tap_id = tap.id
            AND tpl.khr_id = khr.id
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND tap.try_id = try.id
            AND tpl.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND tap.transaction_date >= p_start_date
            AND tap.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,tpl.sty_id), - 1 )  = nvl(tpl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND tap.org_id = NVL( p_org_id, tap.org_id )
            AND tap.legal_entity_id = NVL(p_le_id, tap.legal_entity_id )
            AND tap.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = tap.org_id
            AND le.legal_entity_id = tap.legal_entity_id
            AND ledger.ledger_id = tap.set_of_books_id
            -- OKL to AP Invoice Lines Predicates
            AND invdist.line_type_lookup_code = 'ITEM' -- Need to verify
            AND invdist.invoice_id = lin.invoice_id
            AND invdist.invoice_line_number = lin.line_number
            AND lin.application_id = 540
            AND lin.product_table = 'OKL_TXL_AP_INV_LNS_ALL_B'
            AND lin.reference_key1 = tpl.id
            AND lin.invoice_id = inv.invoice_id
            -- AP to XLA Relations
            AND  invdist.accounting_event_id = xe.event_id
            AND  xe.application_id = 200 -- Payables
            AND  xe.event_status_code = 'P' -- Pick Only processed XLA Events
            AND xe.application_id = xvl.application_id
            AND xvl.event_type_code = xe.event_type_code
            AND  xd.event_id = xe.event_id
            AND  xd.application_id = 200 -- Payables Application
            AND  xd.source_distribution_id_num_1 = invdist.invoice_distribution_id
            AND  xd.source_distribution_type = 'AP_INV_DIST'
            AND  xd.ae_header_id = xh.ae_header_id
            AND  xl.ae_header_id = xh.ae_header_id
            AND  xl.ledger_id = p_ledger_id
            AND  xd.ae_line_num = xl.ae_line_num --XD,XH,XL END
            -- Important Predicate: XLA Distribution Links should not have the GL Import Link ID
            AND  xh.gl_transfer_status_code <> 'Y' -- Not Imported to GL Yet
            -- Restrict to only one Distribution Line based on the Transaction Activity Code Add/Substract
            -- If its Add Consider only Debit, else if its Substract consider Credit
            AND
            (
              DECODE(xl.entered_cr, NULL, 'DEBIT_DIST', 'CREDIT_DIST' ) =
                   DECODE(rtryp.add_substract_code,
                   'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
              OR
              DECODE(xl.entered_dr, NULL, 'CREDIT_DIST', 'DEBIT_DIST' ) =
                  DECODE(rtryp.add_substract_code,
                  'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
           )
      UNION ALL
        -- Query Segment to find the Imported Payables Invoice Transactions from GL
        -- Note that Imported means either Posted or not posted.
        -- Logic: Starting from okl_txl_ap lines go to the Invoice Line
        --        in AP and its Invoice Distributions. Invoice Distributions stamps the
        --        Accounting Event Id.
        -- Assumption: For a Given OKL AP Inv Lines, we assume that there is a one-one mapping
        --             to Invoice Line and to its Distribution.
        -- The Potential issue may be with the above assumption itself, as we found
        -- multiple Distributions for a given Invoice Line Id. Hence, used the
        -- LINE_TYPE_LOOKUP_CODE = 'ITEM' predicate. Not sure about this though !!
        -- Important Predicate: xl.gl_sl_link_id = gl.gl_sl_link_id
        SELECT  DECODE( gh.status
                         ,'U',  'TRX_UNPOSTED'  -- Unposted Transactions
                         ,'P',  'TRX_POSTED'    -- Posted Transactions
                     )                                    trx_detail_type_code
                ,inv.invoice_num                          trx_number
                ,try.name                                 trx_type_name
                ,xvl.name                                 trx_event_name
                ,'Payables'                               trx_application_name
                ,chr.contract_number                      contract_number
                ,NULL                                     asset_number
                ,gts.deal_type                            book_classification -- Fetching Code need to change to fetch Meaning
                ,pdt.NAME                                 product_name
                ,sty.NAME                                 trx_sty_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,tap.currency_code                        currency_code
                ,NULL                                     trx_account_name
                ,ou.name                                  trx_operating_unit_name
                ,le.name                                  trx_legal_entity_name
                ,ledger.name                              trx_ledger_name
                ,rtryp.add_substract_code                 trx_activity_code
                ,gh.period_name                           trx_period_name
                -- Number Format Columns
                ,xl.entered_dr                            trx_dr_amount
                ,xl.entered_cr                            trx_cr_amount
                ,DECODE(rtryp.add_substract_code
                         ,'ADD',      tpl.amount
                         ,'SUBTRACT', tpl.amount * -1
                       )                                  trx_net_amount
                -- Its safe to fetch the CCID from XLA itself instead of the OKL Dist. table
                ,DECODE(xl.entered_cr
                         ,NULL, xl.code_combination_id    -- When Credit Amount is Null, it means Debit Distribution
                         ,NULL
                       )                                  trx_acc_dr_ccid
                ,DECODE(xl.entered_dr
                         ,NULL, xl.code_combination_id    -- When Debit Amount is Null, it means Credit Distribution
                         ,NULL
                       )                                  trx_acc_cr_ccid
                ,tap.set_of_books_id                      trx_ledger_id
                ,tap.org_id                               trx_operating_unit_id
                ,tap.legal_entity_id                      trx_legal_entity_id
                ,tpl.khr_id                               trx_khr_id
                ,tpl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,tpl.sty_id                               trx_sty_id
                ,200                                      trx_application_id
                -- DATE Format Columns
                ,tap.transaction_date                     trx_date
                ,inv.invoice_date                         gl_date  -- Invoice Date
                -- Additional Columns
                ,tap.id                                   trx_id
                ,tpl.id                                   trx_txl_id
                ,tap.try_id                               trx_try_id
                ,rep.report_id                            trx_report_id
                ,invdist.invoice_distribution_id          trx_dist_id
                -- Occurance date of the Transaction, not the Transaction Effective Date
                ,tap.transaction_date                     trx_occ_date
                ,'Payables'                               source
          FROM
                okl_txl_ap_inv_lns_all_b       tpl
               ,okl_trx_ap_invs_all_b          tap
               ,okc_k_headers_all_b            chr
               ,okl_k_headers                  khr
               ,okl_products                   pdt
               ,okl_ae_tmpt_sets_all           aes
               ,okl_st_gen_tmpt_sets_all       gts
               ,okl_trx_types_v                try
               ,okl_strm_type_v                sty
               -- AP Tables
               ,ap_invoices_all                inv
               ,ap_invoice_lines_all           lin
               ,ap_invoice_distributions_all   invdist
               -- XLA Tables
               ,xla_events                     xe
               ,xla_event_types_vl             xvl
               ,xla_distribution_links         xd
               ,xla_ae_headers                 xh
               ,xla_ae_lines                   xl
               -- GL Tables: Import Reference, GL Header and Lines
               ,gl_import_references           gi
               ,gl_je_headers                  gh
               ,gl_je_lines                    gl
               -- OLM Reconciliation Report Entities
               ,okl_reports_b                  rep
               ,okl_report_trx_params          rtryp
               ,okl_rep_products_gt            pdt_gt
               -- To fetch Names
               ,hr_operating_units             ou
               ,xle_entity_profiles            le
               ,gl_ledgers_v                   ledger
          WHERE
                -- OKL to AP Application Predicates
                tpl.tap_id = tap.id
            AND tpl.khr_id = khr.id
            AND chr.id     = khr.id
            AND khr.pdt_id = pdt.id
            AND pdt.aes_id = aes.id
            AND aes.gts_id = gts.id
            AND tap.try_id = try.id
            AND tpl.sty_id = sty.id
            -- Transaction should have occured in the Start and End date of the Context
            AND tap.transaction_date >= p_start_date
            AND tap.transaction_date <= p_end_date
            -- Add Predicates based on the report
            AND  rep.report_id = p_report_id
            AND  rtryp.report_id = rep.report_id
            AND  try.id = rtryp.try_id
            AND  nvl(nvl(rtryp.sty_id,tpl.sty_id), - 1 )  = nvl(tpl.sty_id, -1)
            -- Products restriction
            AND  pdt_gt.product_id = pdt.id
            -- Org., Ledger and Legal Entity Id restriction
            AND tap.org_id = NVL( p_org_id, tap.org_id )
            AND tap.legal_entity_id = NVL(p_le_id, tap.legal_entity_id )
            AND tap.set_of_books_id = p_ledger_id -- Ledger is Mandatory Input Param
            -- Predicates to fetch the Names
            AND ou.organization_id = tap.org_id
            AND le.legal_entity_id = tap.legal_entity_id
            AND ledger.ledger_id = tap.set_of_books_id
            -- OKL to AP Invoice Lines Predicates
            AND invdist.line_type_lookup_code = 'ITEM' -- Need to verify
            AND invdist.invoice_id = lin.invoice_id
            AND invdist.invoice_line_number = lin.line_number
            AND lin.application_id = 540
            AND lin.product_table = 'OKL_TXL_AP_INV_LNS_ALL_B'
            AND lin.reference_key1 = tpl.id
            AND lin.invoice_id = inv.invoice_id
            -- AP to XLA Relations
            AND  invdist.accounting_event_id = xe.event_id
            AND  xe.application_id = 200 -- Payables
            AND  xe.event_status_code = 'P' -- Pick Only processed XLA Events
            AND xe.application_id = xvl.application_id
            AND xvl.event_type_code = xe.event_type_code
            AND  xd.event_id = xe.event_id
            AND  xd.application_id = 200 -- Payables Application
            AND  xd.source_distribution_id_num_1 = invdist.invoice_distribution_id
            AND  xd.source_distribution_type = 'AP_INV_DIST'
            AND  xd.ae_header_id = xh.ae_header_id
            AND  xl.ae_header_id = xh.ae_header_id
            AND  xl.ledger_id = p_ledger_id
            AND  xd.ae_line_num = xl.ae_line_num --XD,XH,XL END
            -- Restrict to only one Distribution Line based on the Transaction Activity Code Add/Substract
            -- If its Add Consider only Debit, else if its Substract consider Credit
            AND
            (
              DECODE(xl.entered_cr, NULL, 'DEBIT_DIST', 'CREDIT_DIST' ) =
                   DECODE(rtryp.add_substract_code,
                   'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
              OR
              DECODE(xl.entered_dr, NULL, 'CREDIT_DIST', 'DEBIT_DIST' ) =
                  DECODE(rtryp.add_substract_code,
                  'ADD', 'DEBIT_DIST', 'SUBTRACT', 'CREDIT_DIST' )
            )
            -- From SLA to GL Tables Link
            -- Important Predicate: XLA Distribution Links should have the GL Import Link ID
            AND  gi.gl_sl_link_id = xl.gl_sl_link_id
            AND  gl.ledger_id = xl.ledger_id
            AND  gi.gl_sl_link_table = xl.gl_sl_link_table
            AND  gi.je_header_id = gh.je_header_id
            AND  gh.je_header_id = gl.je_header_id
            AND  gi.je_line_num = gl.je_line_num
            --  AND  gl.code_combination_id = cc.ccid
            AND  gh.je_source = 'Payables'
            -- Important Predicate: gl_je_headers.status can be either Posted Or Unposted
            AND  gh.status IN ( 'U', 'P' ) -- Unposted or Posted Entries
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Payables Invoice Transactions Data in GT Table End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Payables Invoice Transactions ' || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );
    -- Notes:
    --   The above Query segments fetch the following
    --   1. UnAccounted Entries: Means Trx.s are in corresponding applications itself
    --   2. Unposted Entries: Means, Trx. entries reached SLA, but may not be imported to GL
    --                       (Or) Trx. entries reached SLA, and also imported to GL but not posted
    --   3. Posted Entries: Means, Trx. entries reached SLA, got Imported to GL and got posted in GL too
    -- As functionally we need further split-up of (3), posted entries into
    --         "Posted into Non Specified Accounts"
    --   (Or)  "Posted into Non Specified Period"
    --  Note that "Posted into Non Specified Accounts" take precedence
    --    on the "Posted into Non Specified Period"
    --   As by now the okl_g_reports_gt table has all the TRX_POSTED [Posted Transactions]
    --   Update the entries which are not posted into the specified Accounts
    -- Logic:
    -- Step 1:
    --  For each record with detail type as TRX_POSTED in okl_g_reports_gt
    --  check whether the Code Combination does not exists in the okl_code_cmbns_gt
    --  If it doesnot exist, update the detail type from TRX_POSTED to TRX_POST_NON_SPEC_ACCOUNTS
    UPDATE okl_g_reports_gt
       SET value1_text   -- trx_detail_type_code
              = 'TRX_POST_NON_SPEC_ACCOUNTS'
     WHERE value1_text   -- trx_detail_type_code
              = 'TRX_POSTED'
       AND NVL( value4_num  -- trx_acc_dr_ccid
               ,value5_num  -- trx_acc_cr_ccid
              )
           NOT IN
           (
             SELECT ccid
               FROM okl_code_cmbns_gt
           );
    -- Step 2:
    --  And then, take rest of the records and,
    --  For each record with detail type as TRX_POSTED now in okl_g_reports_gt
    --  check whether the GL_DATE is not from the period_from_date and period_to_date
    --  If so, update the detail type from TRX_POSTED to TRX_POST_NON_SPEC_PERIOD
    UPDATE okl_g_reports_gt
       SET value1_text   -- trx_detail_type_code
              = 'TRX_POST_NON_SPEC_PERIOD'
     WHERE  value1_text   -- trx_detail_type_code
              = 'TRX_POSTED'
      AND ( value2_date -- GL_DATE
             < p_start_date
       OR  value2_date -- GL_DATE
             > p_end_date
      );

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After Inserting the Trx. Data in GT Table Start Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'End: ' || l_api_name ||'(-)' );
    -- Set the Return Status and return back
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
  END populate_trx_data;


  -- Start of comments
  --
  -- Function Name  : process_strm_bal_details.
  -- Description    : Procedure to Calculate Contract Streams Opening and Closing Balance
  -- Business Rules :
  -- Parameters     :
  -- Version        : 1.0
  -- History        : RGOOTY created.
  -- End of comments
  PROCEDURE process_strm_bal_details(
               p_api_version     IN         NUMBER
              ,p_init_msg_list   IN         VARCHAR2
              ,x_return_status   OUT NOCOPY VARCHAR2
              ,x_msg_count       OUT NOCOPY NUMBER
              ,x_msg_data        OUT NOCOPY VARCHAR2
              ,p_report_id       IN         NUMBER
              ,p_start_date      IN         DATE
              ,p_end_date        IN         DATE
              ,p_ledger_id       IN         NUMBER
              ,p_org_id          IN         NUMBER
              ,p_le_id           IN         NUMBER)
  IS
    TYPE khr_tbl_type IS TABLE OF get_contracts_csr%ROWTYPE
      INDEX BY BINARY_INTEGER;
    l_khr_tbl   khr_tbl_type;

    -- Cursor to find the Activity Code on the Reconciliation Report Definition
    CURSOR get_activity_code_csr( p_report_id NUMBER)
    IS
      SELECT  activity_code  activity_code
        FROM  okl_reports_b rep
       WHERE  rep.report_id = p_report_id;
    ------------------------------------------------------------------------
    --  Important: Logic to find the Stream Balances as on a particular Date
    --  Inputs   :
    --      p_date : Represents date on which the Unbilled receivables
    --                    balance has to be calculated.
    --
    --  Predicates:
    --   a. Restrict the Streams to the ones mentioned in the Report Params.
    --   b. Streams should be Active
    --   c. If Stream is in Current Status, date of current <= p_date
    --   d. If Stream is in History Status, date of current <= p_date AND date of History > p_date
    --   e. If Stream is billed, date_billed > p_date
    ------------------------------------------------------------------------
    CURSOR strm_bal_csr(
              p_date         DATE
             ,p_khr_id       NUMBER
             ,p_activity     VARCHAR2)
    IS
      SELECT  stm.khr_id                khr_id
             ,SUM(se.amount)            unbilled_amount
        FROM  okl_streams_rep_v               stm
             ,okl_strm_elements         se
             ,okl_strm_type_v           sty
       WHERE
              stm.khr_id = p_khr_id
         AND  se.stm_id = stm.id
         AND sty.id = stm.sty_id
              -- Stream Type should be setup as the Balancing Stream in Report Definition
         AND  stm.sty_id IN
              (
                 SELECT  sty_id
                   FROM  okl_report_stream_params  rsp
                  WHERE  rsp.report_id = p_report_id
              )
         AND  stm.say_code <>'WORKING'
              -- Only Active Streams are used by down stream processes like Billing/Accrual
         AND  stm.active_yn = 'Y'
              -- No need to Consider WORK Streams as they are never used by Billing/Accrual
         AND  stm.say_code <> 'WORK'
         AND
         (     -- If Stream is in Current Status, date_current should <= p_date
              (
                     stm.say_code = 'CURR'
                 AND stm.date_current <= p_date
              )
           OR -- If Stream is Historized, p_date should be in between
              --   date_current and date_history
              (
                     stm.say_code = 'HIST'
                 AND stm.date_current <= p_date
                 AND stm.date_history > p_date
              )
         )
        AND
        (
              -- Case 1: Activity Code is NULL, hence no other predicates
              --          should be considered
                  p_activity IS NULL
              -- Case 2: Activity Code is UNBILL, then fetch only those
              --          streams which arenot billed untill that date
          OR  (
                  p_activity = 'UNBILL'
                  -- Stream Billed Date should be later than the p_date
               AND NVL(se.date_billed, p_date ) >= p_date
              ) -- End Case 3: Activity Code is UNBILL
              -- Case 3:
              --   ACTIVITY Code is UNACCRUED.
              --   Consider only Un Accrued Streams as on the p_date.
              --   Assumption: Stream Element Date has to be considered as the
              --                Streams Accrual Date
          OR (
                   -- Case: Activity Code is UNACCRUED
                   p_activity = 'UNACCRUED'
               AND
               ( -- Case: UNACCURED (AND)
                   (
                     -- Stream was Un-Accrued till date, so considered this
                     NVL( se.accrued_yn, 'N' ) = 'N'
                   ) -- Accrued YN = N
                 OR
                  (
                      se.accrued_yn = 'Y'
                  AND se.stream_element_date > p_date
                   )
                ) -- End Case: UNACCURED (AND)
              ) -- End Case 3: Activity Code is UNACCRUED
        ) -- End of AND Clause based on Activity Codes
      GROUP BY stm.khr_id;

    -- Local Variables
    l_report_id NUMBER := p_report_id;
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'process_strm_bal_details';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Debug related parameters
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Local Variables
    khr_idx               NUMBER;
    l_trace_time          DATE;
    l_strm_bal_tbl        reports_gt_tbl_type;
    l_activity_code       VARCHAR2(30);
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRRPTB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Begin: ' || l_api_name ||'(+)' );
    l_return_status := okl_api.g_ret_sts_success;
    -- By now we have the List of Eligible Products and Code Combinations Available
    -- in the corresponding _GT tables
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Input Parameters ' ||
      ' p_report_id=' || p_report_id ||
      ' p_ledger_id=' || p_ledger_id ||
      ' p_start_date=' || p_start_date ||
      ' p_end_date=' || p_end_date ||
      ' p_org_id=' || p_org_id ||
      ' p_le_id=' ||  p_le_id );

    -------------------------------------------------------------------
    -- First find out all the eligible Contracts, and then find
    --  Opening Balance and Closing Balance for each of such Contract
    -------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before executing get_contracts_csr:' || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );
    -- Start the stop watch
    l_trace_time := SYSDATE;
    khr_idx := 0;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Need to find Balances for the following Contracts ' );
    FOR t_rec IN get_contracts_csr(
              p_org_id          => p_org_id
             ,p_legal_entity_id => p_le_id
             ,p_ledger_id       => p_ledger_id
             ,p_start_date      => p_start_date
             ,p_end_date        => p_end_date)
    LOOP
      khr_idx := khr_idx + 1;
      l_khr_tbl(khr_idx).currency_code     := t_rec.currency_code;
      l_khr_tbl(khr_idx).organization_name := t_rec.organization_name;
      l_khr_tbl(khr_idx).contract_number   := t_rec.contract_number;
      l_khr_tbl(khr_idx).contract_id       := t_rec.contract_id;
      l_khr_tbl(khr_idx).org_id            := t_rec.org_id;
      l_khr_tbl(khr_idx).bkg_transaction_date := t_rec.bkg_transaction_date;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Operating Unit:' || l_khr_tbl(khr_idx).organization_name ||
        'Contract Number:' || l_khr_tbl(khr_idx).contract_number );
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Executing and Populating Contracts' || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Number of Contracts Fetched ' || TO_NUMBER(khr_idx) );

    ---------------------------------------------------------------------------------
    -- Now, Loop on all the above contracts and find the Opening and Closing Balance
    ---------------------------------------------------------------------------------
    IF l_khr_tbl.COUNT > 0
    THEN

      -- First up, fetch the Activity Code on the Report Definition
      -- Stream Balances cursor is generic and it can calculate the
      --   Unbilled Receivables and also the Un-Accrued amount as on a particular date
      -- Hence, we will pass the Activity Code to Stream Balances Cursor
      FOR t_rec IN get_activity_code_csr( p_report_id => p_report_id )
      LOOP
        l_activity_code := t_rec.activity_code;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' ACTIVITY_CODE on the Report Definition= ' || l_activity_code );
      -- Reuse the khr_idx
      khr_idx := 0;
      FOR i IN l_khr_tbl.FIRST .. l_khr_tbl.LAST
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Fetching Balance for ' || TO_NUMBER(i) || ' Contract ' || l_khr_tbl(i).contract_number  );
        ------------------------------------------------------------------------
        -- Code snippet to store the Contract details and its Opening Balance
        ------------------------------------------------------------------------
        -- Increment the Index
        khr_idx := khr_idx + 1;
        -- First populate the Record structure
        l_strm_bal_tbl(khr_idx).value1_text  := 'OKL_STR_OPEN';
        l_strm_bal_tbl(khr_idx).value11_text := l_khr_tbl(i).currency_code;
        l_strm_bal_tbl(khr_idx).value9_num   := l_khr_tbl(i).contract_id;
        l_strm_bal_tbl(khr_idx).value5_text  := l_khr_tbl(i).contract_number;
        l_strm_bal_tbl(khr_idx).value14_text := l_khr_tbl(i).organization_name;
        l_strm_bal_tbl(khr_idx).value7_num   := l_khr_tbl(i).org_id;
        l_strm_bal_tbl(khr_idx).value3_num   := 0;
        -- Start the stop watch
        l_trace_time := SYSDATE;

        -- For secondary rep txn, set the security policy for streams. MG Uptake
        IF g_representation_type = 'SECONDARY' THEN
          OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
        END IF;
        -- Now, calculate the Opening Balance on the p_start_date
        FOR t_rec IN strm_bal_csr(
                       p_date     => p_start_date
                      ,p_khr_id   => l_khr_tbl(i).contract_id
                      ,p_activity => l_activity_code)
        LOOP
          l_strm_bal_tbl(khr_idx).value3_num := nvl(t_rec.unbilled_amount,0);
        END LOOP;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Opening Balance - Time Take' || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );
        ------------------------------------------------------------------------
        -- Code snippet to store the Contract details and its Closing Balance
        ------------------------------------------------------------------------
        -- Increment the Index
        khr_idx := khr_idx + 1;
        -- First populate the Record structure
        l_strm_bal_tbl(khr_idx).value1_text  := 'OKL_STR_CLOSE';
        l_strm_bal_tbl(khr_idx).value11_text := l_khr_tbl(i).currency_code;
        l_strm_bal_tbl(khr_idx).value9_num   := l_khr_tbl(i).contract_id;
        l_strm_bal_tbl(khr_idx).value5_text  := l_khr_tbl(i).contract_number;
        l_strm_bal_tbl(khr_idx).value14_text := l_khr_tbl(i).organization_name;
        l_strm_bal_tbl(khr_idx).value7_num   := l_khr_tbl(i).org_id;
        l_strm_bal_tbl(khr_idx).value3_num   := 0;
        -- Start the stop watch
        l_trace_time := SYSDATE;
        FOR t_rec IN strm_bal_csr(
                       p_date   => p_end_date
                      ,p_khr_id => l_khr_tbl(i).contract_id
                      ,p_activity => l_activity_code)
        LOOP
          -- Damn Important
          --  Negating the Closing Balance, as the Layout checks for
          -- Contracts Opening Balance + Transaction Amount + Closing Balance = 0
          -- Hence, taken the impact of negating the closing balance here
          l_strm_bal_tbl(khr_idx).value3_num := -1 * nvl(t_rec.unbilled_amount,0);
        END LOOP;

        -- For secondary rep txn, reset the security policy for streams. MG Uptake
        IF g_representation_type = 'SECONDARY' THEN
          OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
        END IF;

        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Closing Balance - Time Take' || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );
      END LOOP;
    END IF; -- IF l_khr_tbl.COUNT > 0
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      ' ******** Fetched Closing and Opening Balances for all Contracts ********' );
    IF l_strm_bal_tbl.COUNT > 0
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Before Call to Bulk Insert ' || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
      -- Finally insert the list of Products figured out
      FORALL i IN l_strm_bal_tbl.FIRST .. l_strm_bal_tbl.LAST
        INSERT INTO okl_g_reports_gt VALUES l_strm_bal_tbl(i);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After Call to Bulk Insert ' || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    END IF; -- IF l_strm_bal_tbl.COUNT > 0

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'End: ' || l_api_name ||'(-)' );
    -- Set the Return Status and return back
    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF get_contracts_csr%ISOPEN
      THEN
        CLOSE get_contracts_csr;
      END IF;
      IF strm_bal_csr%ISOPEN
      THEN
        CLOSE strm_bal_csr;
      END IF;
      -- If any exception was thrown, then reset the reporting streams - MG uptake
      IF g_representation_type = 'SECONDARY' THEN
        OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
      END IF;
      x_return_status := okl_api.g_ret_sts_error;
  END process_strm_bal_details;


  -- Start of comments
  --
  -- Function Name   : populate_acc_data
  -- Description     : API to populate the GL Journal Accounting Details
  --
  -- Business Rules  : Called from prepare_gross_rec_report
  -- Parameters      :
  -- Version         : 1.0
  -- History         : Ravindranath Gooty created.
  -- End of comments

  PROCEDURE populate_acc_data(
              p_api_version   IN         NUMBER
             ,p_init_msg_list IN         VARCHAR2
             ,x_return_status OUT NOCOPY VARCHAR2
             ,x_msg_count     OUT NOCOPY NUMBER
             ,x_msg_data      OUT NOCOPY VARCHAR2
             ,p_report_id     IN         NUMBER
             ,p_ledger_id     IN         NUMBER
             ,p_start_date    IN         DATE
             ,p_end_date      IN         DATE
             ,p_org_id        IN         NUMBER
             ,p_le_id         IN         NUMBER)
  IS
    CURSOR get_period_dtls_csr(
             p_ledger_id    NUMBER
            ,p_period_from  VARCHAR2
    )
    IS
      SELECT  gl.period_set_name   period_set_name
             ,per.period_type      period_type
        FROM  gl_ledgers           gl
             ,gl_periods           per
       WHERE  gl.ledger_id        = p_ledger_id
         AND  per.period_set_name = gl.period_set_name
         AND  per.period_name     = p_period_from;

    l_report_id NUMBER := p_report_id;
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'populate_acc_data';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Debug related parameters
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Local Variables
    l_query_string        VARCHAR2(4000);
    l_trace_time          DATE;
    l_period_set_name     VARCHAR2(15);
    l_period_type         VARCHAR2(15);
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRRPTB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Begin: ' || l_api_name ||'(+)' );
    l_return_status := okl_api.g_ret_sts_success;
    -- By now we have the List of Eligible Products and Code Combinations Available
    -- in the corresponding _GT tables
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Input Parameters ' ||
      ' p_report_id=' || p_report_id ||
      ' p_ledger_id=' || p_ledger_id ||
      ' p_start_date=' || p_start_date ||
      ' p_end_date=' || p_end_date ||
      ' p_org_id=' || p_org_id ||
      ' p_le_id=' ||  p_le_id );

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Executing the Cursor get_period_dtls_csr p_ledger_id=' || p_ledger_id
      || ' p_period_from= ' || p_gl_period_from );
    FOR t_rec IN get_period_dtls_csr(
                   p_ledger_id    => p_ledger_id
                  ,p_period_from  => p_gl_period_from )
    LOOP
      l_period_set_name := t_rec.period_set_name;
      l_period_type     := t_rec.period_type;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After executing the Cursor get_period_dtls_csr l_period_set_name=' || l_period_set_name
      || ' l_period_type=' || l_period_type );

    -------------------------------------------------------------------------------------
    -- Queries to Populate Manual Posted GL Journal Entries from GL Application
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Accounting Journals From GL Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             gl_detail_type_code         --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,NULL                        --value15_text -- Legal Entity Name
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text  -- Activity Code Add/Subtract for Dr/Cr
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,code_combination_id         --value4_num
            ,code_combination_id         --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_try_id                  --value8_num -- Transaction Type ID
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
        FROM
      (
        -- Query Segment to find the Manual Posted Journal Entries in GL
        SELECT 'GL_ACC_OTHER_APPS'                      gl_detail_type_code
              ,gh.currency_code                         currency_code
              ,app.application_name                     trx_application_name
              ,glcc.concatenated_segments               trx_account_name
              ,gh.je_source                             trx_event_name
              ,NULL                                     trx_type_name
              ,NULL                                     trx_sty_name
              ,gh.name                                  trx_number
              ,NULL                                     contract_number
              ,NULL                                     asset_number
              ,NULL                                     book_classification
              ,NULL                                     product_name
              ,NULL                                     trx_sty_purpose
              ,NULL                                     trx_operating_unit_name
              ,ledger.name                              trx_ledger_name
              ,gh.period_name                           trx_period_name
              ,gl.code_combination_id                   code_combination_id
              -- Number Format Columns
              ,gl.entered_dr                            trx_dr_amount
              ,gl.entered_cr                            trx_cr_amount
              ,( NVL(gl.entered_dr,0) - NVL(gl.entered_cr,0) )
                                                        trx_net_amount
              ,NULL                                     trx_activity_code
              ,gl.ledger_id                             trx_ledger_id
              ,NULL                                     trx_operating_unit_id
              ,NULL                                     trx_khr_id
              ,NULL                                     txl_asset_id
              ,NULL                                     trx_pdt_id
              ,NULL                                     trx_sty_id
              ,101                                      trx_application_id
              -- DATE Format Columns
              ,gh.default_effective_date                trx_date
              ,NULL                                     gl_date
              -- Additional Columns
              ,NULL                                     trx_id
              ,NULL                                     trx_txl_id
              ,NULL                                     trx_try_id
              ,NULL                                     trx_dist_id
        FROM    -- GL Tables: Import Reference, GL Header and Lines
                gl_je_lines               gl
               ,gl_je_headers             gh
               ,gl_code_combinations_kfv  glcc
               -- Code Combination GT Table
               ,okl_code_cmbns_gt         cc
               ,gl_ledgers                ledger
               ,fnd_application_vl        app
        WHERE
               -- Restrict the Code Combinations to the one setup on the Report
               gl.code_combination_id = cc.ccid AND
               -- GL Tables
               gl.ledger_id        = p_ledger_id
          AND  gh.je_header_id     = gl.je_header_id
          AND  gh.ledger_id        = gl.ledger_id
          AND  gh.je_source        = 'Manual'
          AND  gh.status           =  'P'  -- Pick Only Posted Journals
          AND  glcc.code_combination_id = gl.code_combination_id
               -- Predicates to fetch Names
          AND  ledger.ledger_id    = gl.ledger_id
          AND  app.application_id  = 101 -- GL Appliation Id
          AND  gh.default_effective_date >= p_start_date
          AND  gh.default_effective_date <= p_end_date
          -- End of Query Segment to fetch Manual Posted Journal Entries from GL Application
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Accounting Journals From GL End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Accounting Journals from GL Application '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );


    -------------------------------------------------------------------------------------
    -- Queries to Populate Posted GL Journal Entry details from Non OLM, AR, AP, FA App.
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Accounting Journals From Non GL, OLM, AR, AP, FA Applications:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             gl_detail_type_code         --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,NULL                        --value15_text -- Legal Entity Name
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text  -- Activity Code Add/Subtract for Dr/Cr
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,code_combination_id         --value4_num
            ,code_combination_id         --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_try_id                  --value8_num -- Transaction Type ID
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
        FROM
      (
        -- Query Segment to find the Posted Journal Entries from
        --  applications other than GL, OLM, FA, AR and AP
        SELECT 'GL_ACC_OTHER_APPS'                      gl_detail_type_code
              ,gh.currency_code                         currency_code
              ,app.application_name                     trx_application_name
              ,glcc.concatenated_segments               trx_account_name
              ,xvl.name                                 trx_event_name
              ,NULL                                     trx_type_name
              ,NULL                                     trx_sty_name
              ,xte.transaction_number                   trx_number
              ,NULL                                     contract_number
              ,NULL                                     asset_number
              ,NULL                                     book_classification
              ,NULL                                     product_name
              ,NULL                                     trx_sty_purpose
              ,NULL                                     trx_operating_unit_name
              ,ledger.name                              trx_ledger_name
              ,gh.period_name                           trx_period_name
              ,xl.code_combination_id                   code_combination_id
              -- Number Format Columns
              ,xl.entered_dr                            trx_dr_amount
              ,xl.entered_cr                            trx_cr_amount
              ,( NVL(xl.entered_dr,0) - NVL(xl.entered_cr,0) )
                                                        trx_net_amount
              ,NULL                                     trx_activity_code
              ,xl.ledger_id                             trx_ledger_id
              ,NULL                                     trx_operating_unit_id
              ,NULL                                     trx_khr_id
              ,NULL                                     txl_asset_id
              ,NULL                                     trx_pdt_id
              ,NULL                                     trx_sty_id
              ,xl.application_id                        trx_application_id
              -- DATE Format Columns
              ,xe.transaction_date                      trx_date
              ,NULL                                     gl_date
              -- Additional Columns
              ,NULL                                     trx_id
              ,NULL                                     trx_txl_id
              ,NULL                                     trx_try_id
              ,NULL                                     trx_dist_id
        FROM    -- GL Tables: Import Reference, GL Header and Lines
                gl_je_lines               gl
               ,gl_je_headers             gh
               ,gl_code_combinations_kfv  glcc
               ,gl_import_references      gi
               -- Code Combination GT Table
               ,okl_code_cmbns_gt         cc
               -- SLA Entities
               ,xla_ae_lines              xl
               ,xla_ae_headers            xh
               ,xla_events                xe
               ,xla_event_types_vl        xvl
               ,xla_transaction_entities  xte
               ,gl_ledgers                ledger
               ,fnd_application_vl        app
        WHERE
               -- Restrict the Code Combinations to the one setup on the Report
               gl.code_combination_id = cc.ccid AND
               -- GL Tables
               gl.ledger_id        = p_ledger_id
          AND  gh.je_header_id     = gl.je_header_id
          AND  gh.ledger_id        = gl.ledger_id
          AND  gh.status           =  'P'  -- Pick Only Posted Journals
          AND  glcc.code_combination_id = gl.code_combination_id
          AND  gi.je_header_id     = gh.je_header_id
          AND  gi.je_line_num      = gl.je_line_num
               -- GL to XLA Relations
          AND  xl.gl_sl_link_id    = gi.gl_sl_link_id
          AND  xl.gl_sl_link_table = gi.gl_sl_link_table
          AND  xl.ledger_id        = gl.ledger_id
               -- XLA Predicates
          AND  xl.ae_header_id     = xh.ae_header_id
          AND  xe.event_id         = xh.event_id
          AND  xe.application_id
               NOT IN
                 (  540  -- Leasing and Finance Management
                   ,200  -- Payables
                   ,222  -- Receivables
                 )
          AND  xe.application_id   = xvl.application_id
          AND  xvl.event_type_code = xe.event_type_code
          AND  xte.entity_id       = xe.entity_id
          AND  xte.application_id  = xe.application_id
          -- Predicates to fetch the Names
          AND  ledger.ledger_id    = xl.ledger_id
          AND  app.application_id  = xe.application_id
          -- Restrict the Journal Entries to be in between Start and End Dates
          AND  gh.default_effective_date >= p_start_date
          AND  gh.default_effective_date <= p_end_date
          -- End of Query Segment to fetch Posted Acc. Entries in GL
          --  from applications other than GL, OLM, FA, AR and AP
      );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Accounting Journals From Non GL, OLM, AR, AP, FA Applications End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Accounting Journals in GL from Non GL, OLM, AR, AP, FA Applications '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

    -------------------------------------------------------------------------------------
    -- Queries to Populate Posted GL Journal Entry details from OLM, AR, AP
    --  OLM - All Transactions. AR - Invoice, Adjustment, Credit Memo
    --  AP - Payables Invoices
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Accounting Journals in GT Table Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  ,value15_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             gl_detail_type_code         --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,NULL                        --value15_text -- Legal Entity Name
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text  -- Activity Code Add/Subtract for Dr/Cr
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,code_combination_id         --value4_num
            ,code_combination_id         --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_try_id                  --value8_num -- Transaction Type ID
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            ,trx_xla_event_id            --value15_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
        FROM
      (
        -- Query Segment to find the Posted Journal Entries from GL from Lease Contracts
        SELECT 'GL_ACC_OLM_ENTRIES'                     gl_detail_type_code
              ,gh.currency_code                         currency_code
              ,app.application_name                     trx_application_name
              ,glcc.concatenated_segments               trx_account_name
              ,xvl.name                                 trx_event_name
              ,try.name                                 trx_type_name
              ,sty.NAME                                 trx_sty_name
              ,trx.trx_number                           trx_number
              ,chr.contract_number                      contract_number
              ,NULL                                     asset_number
              ,gts.deal_type                            book_classification
              ,pdt.NAME                                 product_name
              ,sty.styb_purpose_meaning                 trx_sty_purpose
              ,ou.name                                  trx_operating_unit_name
              ,ledger.name                              trx_ledger_name
              ,gh.period_name                           trx_period_name
              ,xl.code_combination_id                   code_combination_id
              -- Number Format Columns
              ,xl.entered_dr                            trx_dr_amount
              ,xl.entered_cr                            trx_cr_amount
              ,( NVL(xl.entered_dr,0) - NVL(xl.entered_cr,0) )
                                                        trx_net_amount
              ,DECODE( xl.entered_dr, NULL, 'SUBTRACT', 'ADD' )
                                                        trx_activity_code
              ,xl.ledger_id                             trx_ledger_id
              ,trx.org_id                               trx_operating_unit_id
              ,trx.khr_id                               trx_khr_id
              ,txl.kle_id                               txl_asset_id
              ,khr.pdt_id                               trx_pdt_id
              ,txl.sty_id                               trx_sty_id
              ,xl.application_id                        trx_application_id
              ,xe.event_id                              trx_xla_event_id
              -- DATE Format Columns
              ,trx.transaction_date                     trx_date
              ,dist.gl_date                             gl_date
              -- Additional Columns
              ,trx.id                                   trx_id
              ,txl.id                                   trx_txl_id
              ,trx.try_id                               trx_try_id
              ,dist.id                                  trx_dist_id
        FROM    -- GL Tables: Import Reference, GL Header and Lines
                gl_je_lines               gl
               ,gl_je_headers             gh
               ,gl_code_combinations_kfv  glcc
               ,gl_import_references      gi
               -- Code Combination GT Table
               ,okl_code_cmbns_gt         cc
               -- SLA Entities
               ,xla_ae_lines              xl
               ,xla_ae_headers            xh
               ,xla_distribution_links    xd
               ,xla_events                xe
               ,xla_event_types_vl        xvl
              -- OLM Entities
               ,okl_trns_acc_dstrs_all    dist
               ,okl_txl_cntrct_lns_all    txl
               ,okl_trx_contracts_all     trx
               ,okl_trx_types_v           try
               ,okl_strm_type_v           sty
               ,okc_k_headers_all_b       chr
               ,okl_k_headers             khr
               ,okl_products              pdt
               ,okl_ae_tmpt_sets_all      aes
               ,okl_st_gen_tmpt_sets_all  gts
               -- To fetch Names
               ,hr_operating_units        ou
               ,gl_ledgers                ledger
               ,fnd_application_vl        app
        WHERE
               -- Restrict the Code Combinations to the one setup on the Report
               gl.code_combination_id = cc.ccid AND
               -- GL Tables
               gl.ledger_id        = p_ledger_id
          AND  gh.je_header_id     = gl.je_header_id
          AND  gh.ledger_id        = gl.ledger_id
          AND  gh.je_source        = 'Lease'
          AND  gh.status           =  'P'  -- Pick Only Posted Journals
          AND  glcc.code_combination_id = gl.code_combination_id
          AND  gi.je_header_id     = gh.je_header_id
          AND  gi.je_line_num      = gl.je_line_num
               -- GL to XLA Relations
          AND  xl.gl_sl_link_id    = gi.gl_sl_link_id
          AND  xl.gl_sl_link_table = gi.gl_sl_link_table
          AND  xl.ledger_id        = gl.ledger_id
               -- XLA Predicates
          AND  xl.ae_header_id     = xh.ae_header_id
          AND  xd.application_id   = 540  -- Restrict to Lease Journals
          AND  xd.ae_header_id     = xh.ae_header_id
          AND  xd.ae_line_num      = xl.ae_line_num
          AND  xe.event_id         = xd.event_id
          AND  xe.application_id   = xvl.application_id
          AND  xvl.event_type_code = xe.event_type_code
               -- XLA to OLM Predicates
          AND  xd.event_id         = dist.accounting_event_id
          AND  dist.id             = xd.source_distribution_id_num_1
          AND  dist.posted_yn      = 'Y'
               -- OLM Predicates
          AND  dist.source_table   = 'OKL_TXL_CNTRCT_LNS'
          AND  dist.source_id      = txl.id
          AND  trx.id              = txl.tcn_id
          AND  trx.try_id          = try.id
          AND  txl.sty_id          = sty.id
          AND  trx.khr_id          = chr.id
          AND  chr.id              = khr.id
          AND  khr.pdt_id          = pdt.id
          AND  pdt.aes_id          = aes.id
          AND  aes.gts_id          = gts.id
          -- Predicates to fetch the Names
          AND  ou.organization_id  = trx.org_id
          AND  ledger.ledger_id    = trx.set_of_books_id
          AND  app.application_id  = xe.application_id
          -- Restrict the Journal Entries to be in between Start and End Dates
          AND  gh.default_effective_date >= p_start_date
          AND  gh.default_effective_date <= p_end_date
          -- End of Query Segment to fetch Posted Acc. Entries from GL
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Lease Accounting Journals Data in GT Table End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Lease Accounting Journals '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

    -------------------------------------------------------------------------------------
    -- Queries to Populate Posted GL Journal Entry details
    --  related to AR Invoice Transactions
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Receivables Invoice Accounting Journals in GT Table Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  ,value15_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             gl_detail_type_code         --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,NULL                        --value15_text -- Legal Entity Name
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text  -- Activity Code Add/Subtract for Dr/Cr
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,code_combination_id         --value4_num
            ,code_combination_id         --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_try_id                  --value8_num -- Transaction Type ID
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            ,trx_xla_event_id            --value15_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
        FROM
      (
        -- Query Segment to find the Posted Journal Entries from GL
        --  On behalf of OLM Lease Contract Receivables Invoice
        SELECT 'GL_ACC_OLM_ENTRIES'                     gl_detail_type_code
              ,gh.currency_code                         currency_code
              ,app.application_name                     trx_application_name
              ,glcc.concatenated_segments               trx_account_name
              ,xvl.name                                 trx_event_name
              ,try.name                                 trx_type_name
              ,sty.NAME                                 trx_sty_name
              ,rct.trx_number                           trx_number
              ,chr.contract_number                      contract_number
              ,NULL                                     asset_number
              ,gts.deal_type                            book_classification
              ,pdt.NAME                                 product_name
              ,sty.styb_purpose_meaning                 trx_sty_purpose
              ,ou.name                                  trx_operating_unit_name
              ,ledger.name                              trx_ledger_name
              ,gh.period_name                           trx_period_name
              ,xl.code_combination_id                   code_combination_id
              -- Number Format Columns
              ,DECODE( xl.entered_cr
                       ,NULL, txd.amount
                       ,0 )                             trx_dr_amount
              ,DECODE( xl.entered_dr
                       ,NULL, txd.amount
                       ,0 )                             trx_cr_amount
              ,DECODE( xl.entered_cr, NULL, txd.amount, txd.amount * -1 )
                                                        trx_net_amount
              ,DECODE( xl.entered_dr, NULL, 'SUBTRACT', 'ADD' )
                                                        trx_activity_code
              ,xl.ledger_id                             trx_ledger_id
              ,tai.org_id                               trx_operating_unit_id
              ,tai.khr_id                               trx_khr_id
              ,txd.kle_id                               txl_asset_id
              ,khr.pdt_id                               trx_pdt_id
              ,txd.sty_id                               trx_sty_id
              ,xl.application_id                        trx_application_id
              ,xe.event_id                              trx_xla_event_id
              -- DATE Format Columns
              ,tai.transaction_date                     trx_date
              ,rad.gl_date                              gl_date
              -- Additional Columns
              ,tai.id                                   trx_id
              ,txd.id                                   trx_txl_id
              ,tai.try_id                               trx_try_id
              ,NULL                                     trx_dist_id
        FROM    -- GL Tables: Import Reference, GL Header and Lines
                gl_je_lines               gl
               ,gl_je_headers             gh
               ,gl_code_combinations_kfv  glcc
               ,gl_import_references      gi
               -- Code Combination GT Table
               ,okl_code_cmbns_gt         cc
               -- SLA Entities
               ,xla_ae_lines              xl
               ,xla_ae_headers            xh
               ,xla_distribution_links    xd
               ,xla_events                xe
               ,xla_event_types_vl        xvl
               -- AR Tables
               ,ra_cust_trx_line_gl_dist_all  rad
               ,ra_customer_trx_lines_all     rcl
               ,ra_customer_trx_all           rct
               -- OLM Tables
               ,okl_txd_ar_ln_dtls_b      txd
               ,okl_txl_ar_inv_lns_b      til
               ,okl_trx_ar_invoices_b     tai
               ,okc_k_headers_all_b       chr
               ,okl_k_headers             khr
               ,okl_products              pdt
               ,okl_ae_tmpt_sets_all      aes
               ,okl_st_gen_tmpt_sets_all  gts
               ,okl_trx_types_v           try
               ,okl_strm_type_v           sty
               -- To fetch Names
               ,hr_operating_units        ou
               ,gl_ledgers                ledger
               ,fnd_application_vl        app
        WHERE
               -- Restrict the Code Combinations to the one setup on the Report
               gl.code_combination_id = cc.ccid AND
               -- GL Tables
               gl.ledger_id        = p_ledger_id
          AND  gh.je_header_id     = gl.je_header_id
          AND  gh.ledger_id        = gl.ledger_id
          AND  gh.je_source        = 'Receivables'
          AND  gh.status           =  'P'  -- Pick Only Posted Journals
          AND  glcc.code_combination_id = gl.code_combination_id
          AND  gi.je_header_id     = gh.je_header_id
          AND  gi.je_line_num      = gl.je_line_num
               -- GL to XLA Relations
          AND  xl.gl_sl_link_id    = gi.gl_sl_link_id
          AND  xl.gl_sl_link_table = gi.gl_sl_link_table
          AND  xl.ledger_id        = gl.ledger_id
               -- XLA Predicates
          AND  xl.ae_header_id     = xh.ae_header_id
          AND  xd.application_id   = 222  -- Restrict to Receivables Journals
          AND  xd.ae_header_id     = xh.ae_header_id
          AND  xd.ae_line_num      = xl.ae_line_num
          AND  xe.event_id         = xd.event_id
          AND  xe.event_status_code = 'P'
          AND  xe.application_id   = xvl.application_id
          AND  xvl.event_type_code = xe.event_type_code
               -- XLA to AR Predicates
          AND  rad.event_id = xd.event_id
          AND  rad.cust_trx_line_gl_dist_id = xd.source_distribution_id_num_1
               -- AR Predicates
          AND  rcl.customer_trx_line_id = rad.customer_trx_line_id
          AND  rct.customer_trx_id = rcl.customer_trx_id
               -- OKL to AR Predicates
          AND  rcl.interface_line_attribute14 = txd.id
          AND  rcl.interface_line_attribute6 =  chr.contract_number
               -- OKL Predicates
          AND  txd.til_id_details = til.id -- Trx. Detail to Trx. Line
          AND  til.tai_id = tai.id         -- Trx. Line to Trx. Header
          AND  txd.khr_id = chr.id         -- Trx. Header to Contract
          AND  tai.try_id = try.id
          AND  txd.sty_id = sty.id
          AND  chr.id     = khr.id
          AND  khr.pdt_id = pdt.id
          AND  pdt.aes_id = aes.id
          AND  aes.gts_id = gts.id
          -- Predicates to fetch the Names
          AND  ou.organization_id  = tai.org_id
          AND  ledger.ledger_id    = tai.set_of_books_id
          AND  app.application_id  = xe.application_id
          AND  gh.default_effective_date >= p_start_date
          AND  gh.default_effective_date <= p_end_date
          -- End of Query Segment to fetch Posted Acc. Entries from GL
          --  from Receivables for a Lease Contract Invoice Transactions
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Receivables Invoice Accounting Journals Data in GT Table End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Receivables Invoice Accounting Journals '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );


    -------------------------------------------------------------------------------------
    -- Queries to Populate Posted GL Journal Entry details
    --  related to AR Adjustment Transactions
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Receivables Adjustment Accounting Journals in GT Table Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  ,value15_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             gl_detail_type_code         --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,NULL                        --value15_text -- Legal Entity Name
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text  -- Activity Code Add/Subtract for Dr/Cr
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,code_combination_id         --value4_num
            ,code_combination_id         --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_try_id                  --value8_num -- Transaction Type ID
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            ,trx_xla_event_id            --value15_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
        FROM
      (
        -- Query Segment to find the Posted Journal Entries from GL
        --  On behalf of OLM Lease Contract Receivables Adjustments
        SELECT 'GL_ACC_OLM_ENTRIES'                     gl_detail_type_code
              ,gh.currency_code                         currency_code
              ,app.application_name                     trx_application_name
              ,glcc.concatenated_segments               trx_account_name
              ,xvl.name                                 trx_event_name
              ,try.name                                 trx_type_name
              ,sty.NAME                                 trx_sty_name
              ,radj.adjustment_number                   trx_number
              ,chr.contract_number                      contract_number
              ,NULL                                     asset_number
              ,gts.deal_type                            book_classification
              ,pdt.NAME                                 product_name
              ,sty.styb_purpose_meaning                 trx_sty_purpose
              ,ou.name                                  trx_operating_unit_name
              ,ledger.name                              trx_ledger_name
              ,gh.period_name                           trx_period_name
              ,xl.code_combination_id                   code_combination_id
              -- Number Format Columns
              ,xl.entered_dr                            trx_dr_amount
              ,xl.entered_cr                            trx_cr_amount
              ,( NVL(xl.entered_dr,0) - NVL(xl.entered_cr,0) )
                                                        trx_net_amount
              ,DECODE( xl.entered_dr, NULL, 'SUBTRACT', 'ADD' )
                                                        trx_activity_code
              ,xl.ledger_id                             trx_ledger_id
              ,adj.org_id                               trx_operating_unit_id
              ,ajl.khr_id                               trx_khr_id
              ,ajl.kle_id                               txl_asset_id
              ,khr.pdt_id                               trx_pdt_id
              ,ajl.sty_id                               trx_sty_id
              ,xl.application_id                        trx_application_id
              ,xe.event_id                              trx_xla_event_id
              -- DATE Format Columns
              ,adj.transaction_date                     trx_date
              ,adj.gl_date                              gl_date
              -- Additional Columns
              ,adj.id                                   trx_id
              ,ajl.id                                   trx_txl_id
              ,adj.try_id                               trx_try_id
              ,NULL                                     trx_dist_id
        FROM    -- GL Tables: Import Reference, GL Header and Lines
                gl_je_lines               gl
               ,gl_je_headers             gh
               ,gl_code_combinations_kfv  glcc
               ,gl_import_references      gi
               -- Code Combination GT Table
               ,okl_code_cmbns_gt         cc
               -- SLA Entities
               ,xla_ae_lines              xl
               ,xla_ae_headers            xh
               ,xla_distribution_links    xd
               ,xla_events                xe
               ,xla_event_types_vl        xvl
               -- AR Tables
               ,ar_distributions_all      rdist
               ,ar_adjustments_all        radj
               -- OLM Tables
               ,okl_txl_adjsts_lns_all_b  ajl
               ,okl_trx_ar_adjsts_all_b   adj
               ,okc_k_headers_all_b       chr
               ,okl_k_headers             khr
               ,okl_products              pdt
               ,okl_ae_tmpt_sets_all      aes
               ,okl_st_gen_tmpt_sets_all  gts
               ,okl_trx_types_v           try
               ,okl_strm_type_v           sty
               -- To fetch Names
               ,hr_operating_units        ou
               ,gl_ledgers                ledger
               ,fnd_application_vl        app
        WHERE
               -- Restrict the Code Combinations to the one setup on the Report
               gl.code_combination_id = cc.ccid AND
               -- GL Tables
               gl.ledger_id        = p_ledger_id
          AND  gh.je_header_id     = gl.je_header_id
          AND  gh.ledger_id        = gl.ledger_id
          AND  gh.je_source        = 'Receivables'
          AND  gh.status           =  'P'  -- Pick Only Posted Journals
          AND  glcc.code_combination_id = gl.code_combination_id
          AND  gi.je_header_id     = gh.je_header_id
          AND  gi.je_line_num      = gl.je_line_num
               -- GL to XLA Relations
          AND  xl.gl_sl_link_id    = gi.gl_sl_link_id
          AND  xl.gl_sl_link_table = gi.gl_sl_link_table
          AND  xl.ledger_id        = gl.ledger_id
               -- XLA Predicates
          AND  xl.ae_header_id     = xh.ae_header_id
          AND  xd.application_id   = 222  -- Restrict to Receivables Journals
          AND  xd.ae_header_id     = xh.ae_header_id
          AND  xd.ae_line_num      = xl.ae_line_num
          AND  xe.event_id         = xd.event_id
          AND  xe.event_status_code = 'P'
          AND  xe.application_id   = xvl.application_id
          AND  xvl.event_type_code = xe.event_type_code
               -- XLA to AR Predicates
          AND  xd.event_id = radj.event_id
          AND  xd.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND  xd.source_distribution_id_num_1 = rdist.line_id
               -- AR Predicates
          AND  rdist.source_type = 'ADJ'  -- Assumption
          AND  radj.adjustment_id = rdist.source_id
               -- OKL to AR Predicates
          AND  ajl.receivables_adjustment_id = radj.adjustment_id
               -- OKL Predicates
          AND  adj.id     = ajl.adj_id
          AND  adj.try_id = try.id
          AND  ajl.sty_id = sty.id
          AND  ajl.khr_id = khr.id
          AND  chr.id     = khr.id
          AND  khr.pdt_id = pdt.id
          AND  pdt.aes_id = aes.id
          AND  aes.gts_id = gts.id
          -- Predicates to fetch the Names
          AND  ou.organization_id  = adj.org_id
          AND  ledger.ledger_id    = xl.ledger_id
          AND  app.application_id  = xe.application_id
          AND  gh.default_effective_date >= p_start_date
          AND  gh.default_effective_date <= p_end_date
          -- End of Query Segment to fetch Posted Acc. Entries from GL
          --  from Receivables for a Lease Contract Receivable Adjustment
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Receivables Adjustment Accounting Journals Data in GT Table End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Receivables Adjustment Accounting Journals '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

    -------------------------------------------------------------------------------------
    -- Queries to Populate Posted GL Journal Entry details
    --  related to AP Invoice Transactions
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Payables Invoice Accounting Journals in GT Table Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  ,value15_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             gl_detail_type_code         --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,NULL                        --value15_text -- Legal Entity Name
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text  -- Activity Code Add/Subtract for Dr/Cr
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,code_combination_id         --value4_num
            ,code_combination_id         --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_try_id                  --value8_num -- Transaction Type ID
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            ,trx_xla_event_id            --value15_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
        FROM
      (
        -- Query Segment to find the Posted Journal Entries from GL
        --  On behalf of OLM Lease Contract Receivables Adjustments
        SELECT 'GL_ACC_OLM_ENTRIES'                     gl_detail_type_code
              ,gh.currency_code                         currency_code
              ,app.application_name                     trx_application_name
              ,glcc.concatenated_segments               trx_account_name
              ,xvl.name                                 trx_event_name
              ,try.name                                 trx_type_name
              ,sty.name                                 trx_sty_name
              ,inv.invoice_num                          trx_number
              ,chr.contract_number                      contract_number
              ,NULL                                     asset_number
              ,gts.deal_type                            book_classification
              ,pdt.NAME                                 product_name
              ,sty.styb_purpose_meaning                 trx_sty_purpose
              ,ou.name                                  trx_operating_unit_name
              ,ledger.name                              trx_ledger_name
              ,gh.period_name                           trx_period_name
              ,xl.code_combination_id                   code_combination_id
              -- Number Format Columns
              ,xl.entered_dr                            trx_dr_amount
              ,xl.entered_cr                            trx_cr_amount
              ,( NVL(xl.entered_dr,0) - NVL(xl.entered_cr,0) )
                                                        trx_net_amount
              ,DECODE( xl.entered_dr, NULL, 'SUBTRACT', 'ADD' )
                                                        trx_activity_code
              ,xl.ledger_id                             trx_ledger_id
              ,tap.org_id                               trx_operating_unit_id
              ,tpl.khr_id                               trx_khr_id
              ,tpl.kle_id                               txl_asset_id
              ,khr.pdt_id                               trx_pdt_id
              ,tpl.sty_id                               trx_sty_id
              ,xl.application_id                        trx_application_id
              ,xe.event_id                              trx_xla_event_id
              -- DATE Format Columns
              ,inv.invoice_date                         trx_date
              ,inv.invoice_date                         gl_date
              -- Additional Columns
              ,tap.id                                   trx_id
              ,tpl.id                                   trx_txl_id
              ,tap.try_id                               trx_try_id
              ,invdist.invoice_distribution_id          trx_dist_id
        FROM    -- GL Tables: Import Reference, GL Header and Lines
                gl_je_lines               gl
               ,gl_je_headers             gh
               ,gl_code_combinations_kfv  glcc
               ,gl_import_references      gi
               -- Code Combination GT Table
               ,okl_code_cmbns_gt         cc
               -- SLA Entities
               ,xla_ae_lines              xl
               ,xla_ae_headers            xh
               ,xla_distribution_links    xd
               ,xla_events                xe
               ,xla_event_types_vl        xvl
               -- AP Tables
               ,ap_invoice_distributions_all   invdist
               ,ap_invoice_lines_all      lin
               ,ap_invoices_all           inv
               -- OLM Tables
               ,okl_txl_ap_inv_lns_all_b  tpl
               ,okl_trx_ap_invs_all_b     tap
               ,okc_k_headers_all_b       chr
               ,okl_k_headers             khr
               ,okl_products              pdt
               ,okl_ae_tmpt_sets_all      aes
               ,okl_st_gen_tmpt_sets_all  gts
               ,okl_trx_types_v           try
               ,okl_strm_type_v           sty
               -- To fetch Names
               ,hr_operating_units        ou
               ,gl_ledgers                ledger
               ,fnd_application_vl        app
        WHERE
               -- Restrict the Code Combinations to the one setup on the Report
               gl.code_combination_id = cc.ccid AND
               -- GL Tables
               gl.ledger_id        = p_ledger_id
          AND  gh.je_header_id     = gl.je_header_id
          AND  gh.ledger_id        = gl.ledger_id
          AND  gh.je_source        = 'Payables'
          AND  gh.status           =  'P'  -- Pick Only Posted Journals
          AND  glcc.code_combination_id = gl.code_combination_id
          AND  gi.je_header_id     = gh.je_header_id
          AND  gi.je_line_num      = gl.je_line_num
               -- GL to XLA Relations
          AND  xl.gl_sl_link_id    = gi.gl_sl_link_id
          AND  xl.gl_sl_link_table = gi.gl_sl_link_table
          AND  xl.ledger_id        = gl.ledger_id
               -- XLA Predicates
          AND  xl.ae_header_id     = xh.ae_header_id
          AND  xd.application_id   = 200  -- Restrict to Payables Journals
          AND  xd.ae_header_id     = xh.ae_header_id
          AND  xd.ae_line_num      = xl.ae_line_num
          AND  xe.event_id         = xd.event_id
          AND  xe.event_status_code = 'P'
          AND  xe.application_id   = xvl.application_id
          AND  xvl.event_type_code = xe.event_type_code
               -- XLA to AP Predicates
          AND  xd.event_id                 = invdist.accounting_event_id
          AND  xd.source_distribution_type = 'AP_INV_DIST'
          AND  xd.source_distribution_id_num_1 = invdist.invoice_distribution_id
               -- AP Predicates
          AND invdist.line_type_lookup_code = 'ITEM' -- Need to verify
          AND invdist.invoice_line_number = lin.line_number
          AND invdist.invoice_id = lin.invoice_id
          AND lin.invoice_id     = inv.invoice_id
               -- OKL to AP Predicates
          AND lin.application_id = 540
          AND lin.product_table  = 'OKL_TXL_AP_INV_LNS_ALL_B'
          AND lin.reference_key1 = tpl.id
               -- OKL Predicates
          AND  tap.id     = tpl.tap_id
          AND  tap.try_id = try.id
          AND  tpl.sty_id = sty.id
          AND  tpl.khr_id = khr.id
          AND  chr.id     = khr.id
          AND  khr.pdt_id = pdt.id
          AND  pdt.aes_id = aes.id
          AND  aes.gts_id = gts.id
          -- Predicates to fetch the Names
          AND  ou.organization_id  = tap.org_id
          AND  ledger.ledger_id    = xl.ledger_id
          AND  app.application_id  = xe.application_id
          AND  gh.default_effective_date >= p_start_date
          AND  gh.default_effective_date <= p_end_date
          -- End of Query Segment to fetch Posted Acc. Entries from GL
          --  from Payables for a Lease Contract Payables Invoice Transaction
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Payables Invoice Accounting Journals Data in GT Table End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Payables Invoice  Accounting Journals '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

   -- Important: Step 1
   --  Till Now we have fetched all the Journal Entries that can be linked
   --   back to an OLM Transaction.
   --  For the Reconciliation Report, we need to verify each and every Journal
   --   Entry fetched and verify the following criteria:
   --   a. If the Journal Entry is related to Transaction, Stream Type combination
   --        not specified in the Report. Move the GL Type to GL_ACC_NON_SPEC_CRITERIA
   --   b. If its a Debit Journal, find that the Corresponding Transaction
   --        has to be mentioned in report definition with "Add" flag
   --        and for Credit Journal, Trx. should be having "Subtract" flag
   --        Otherwsie also, change this Journal Type to GL_ACC_NON_SPEC_CRITERIA
   --  c. If the Journal is for a Contract whose product is not present in
   --        okl_g_products_gt, change this Journal Type to GL_ACC_NON_SPEC_CRITERIA
   -- Step 1:
   UPDATE  okl_g_reports_gt gt
      SET  value1_text = 'GL_ACC_NON_SPEC_CRITERIA'
    WHERE  value1_text = 'GL_ACC_OLM_ENTRIES'
           -- Need to Cover Two Cases:
           --  Case 1: When Only the Transaction Type is mentioned
           --  Case 2: When Combination of Transaction and Stream Type is mentioned
      AND
      (
          -- Step 1: Case (a)
           NOT EXISTS
           (
              SELECT  1
                FROM  okl_report_trx_params trep
               WHERE  trep.try_id = gt.value8_num  -- trx_try_id
                 AND  NVL( trep.sty_id,
                           gt.value12_num -- Stream Type Id
                          ) = gt.value12_num -- Stream Type Id
                 -- Step 1: Case (b)
                 AND  trep.add_substract_code = value17_text -- Debit/Credit or Add/Subtract
                 AND  trep.report_id = p_report_id
           )
           -- Step 1: Case (C)
           OR value11_num -- Product Id
              NOT IN
             ( SELECT product_id
                 FROM okl_rep_products_gt pdt_gt
             )
      );

   -- Important: Step 2
   -- Even if the Journal hasn't moved to GL_ACC_NON_SPEC_CRITERIA, means Journal
   --  is in the specified Criteria, check the Transaction Date
   -- If ithe Transaction Date is not lying in between the start and End Date
   --   change this Journal Type to GL_ACC_NON_SPEC_PERIOD
   -- Step 2:
   UPDATE  okl_g_reports_gt gt
      SET  value1_text = 'GL_ACC_NON_SPEC_PERIOD'
          ,value12_text -- trx_period_name
           = (
                 SELECT  per.period_name
                   FROM  gl_periods per
                  WHERE  per.period_set_name = l_period_set_name
                    AND  per.START_DATE <= value1_date
                    AND  per.end_date >=  value1_date
                    AND  per.adjustment_period_flag = 'N'
                    AND  period_type = l_period_type
             )
    WHERE  value1_text = 'GL_ACC_OLM_ENTRIES'
      AND
      (
           p_start_date > value1_date -- Transaction Date
        OR p_end_date   < value1_date
      );

    -------------------------------------------------------------------------------------
    -- Queries to Populate Posted GL Journal Entry details from AR and AP Applications
    --  which are not related to a Lease Contract
    -- As part of the Query segment above for GL_ACC_OLM_ENTRIES, we have fetched Journals
    --  from AR and AP which are related to OLM.
    -- Now we fetch from AR and AP all the Events, which are not fetched as part of above
    --  query segment, but got posted in GL from these applications.
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the Accounting Journals AR and AP Applications but not related to OLM:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );
    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value2_text
                  ,value3_text
                  ,value4_text
                  ,value5_text
                  ,value6_text
                  ,value7_text
                  ,value8_text
                  ,value9_text
                  ,value10_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  ,value14_text
                  ,value15_text
                  ,value16_text
                  ,value17_text
                  ,value18_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                  ,value3_num
                  ,value4_num
                  ,value5_num
                  ,value6_num
                  ,value7_num
                  ,value8_num
                  ,value9_num
                  ,value10_num
                  ,value11_num
                  ,value12_num
                  ,value13_num
                  ,value15_num
                  -- Date Formatted Columns
                  ,value1_date
                  ,value2_date
                )
      SELECT -- String Formatted Columns
             gl_detail_type_code         --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,NULL                        --value15_text -- Legal Entity Name
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text  -- Activity Code Add/Subtract for Dr/Cr
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,code_combination_id         --value4_num
            ,code_combination_id         --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_try_id                  --value8_num -- Transaction Type ID
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            ,trx_xla_event_id            --value15_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
        FROM
      (
        -- Query Segment to find the Posted Journal Entries from
        --  AR and AP applications but not related to Lease
        SELECT 'GL_ACC_OTHER_APPS'                      gl_detail_type_code
              ,gh.currency_code                         currency_code
              ,app.application_name                     trx_application_name
              ,glcc.concatenated_segments               trx_account_name
              ,xvl.name                                 trx_event_name
              ,NULL                                     trx_type_name
              ,NULL                                     trx_sty_name
              ,xte.transaction_number                   trx_number
              ,NULL                                     contract_number
              ,NULL                                     asset_number
              ,NULL                                     book_classification
              ,NULL                                     product_name
              ,NULL                                     trx_sty_purpose
              ,NULL                                     trx_operating_unit_name
              ,ledger.name                              trx_ledger_name
              ,gh.period_name                           trx_period_name
              ,xl.code_combination_id                   code_combination_id
              -- Number Format Columns
              ,xl.entered_dr                            trx_dr_amount
              ,xl.entered_cr                            trx_cr_amount
              ,( NVL(xl.entered_dr,0) - NVL(xl.entered_cr,0) )
                                                        trx_net_amount
              ,NULL                                     trx_activity_code
              ,xl.ledger_id                             trx_ledger_id
              ,NULL                                     trx_operating_unit_id
              ,NULL                                     trx_khr_id
              ,NULL                                     txl_asset_id
              ,NULL                                     trx_pdt_id
              ,NULL                                     trx_sty_id
              ,xl.application_id                        trx_application_id
              ,xe.event_id                              trx_xla_event_id
              -- DATE Format Columns
              ,xe.transaction_date                      trx_date
              ,NULL                                     gl_date
              -- Additional Columns
              ,NULL                                     trx_id
              ,NULL                                     trx_txl_id
              ,NULL                                     trx_try_id
              ,NULL                                     trx_dist_id
        FROM    -- GL Tables: Import Reference, GL Header and Lines
                gl_je_lines               gl
               ,gl_je_headers             gh
               ,gl_code_combinations_kfv  glcc
               ,gl_import_references      gi
               -- Code Combination GT Table
               ,okl_code_cmbns_gt         cc
               -- SLA Entities
               ,xla_ae_lines              xl
               ,xla_ae_headers            xh
               ,xla_events                xe
               ,xla_event_types_vl        xvl
               ,xla_transaction_entities  xte
               ,gl_ledgers                ledger
               ,fnd_application_vl        app
        WHERE
               -- Restrict the Code Combinations to the one setup on the Report
               gl.code_combination_id = cc.ccid AND
               -- GL Tables
               gl.ledger_id        = p_ledger_id
          AND  gh.je_header_id     = gl.je_header_id
          AND  gh.ledger_id        = gl.ledger_id
          AND  gh.status           =  'P'  -- Pick Only Posted Journals
          AND  glcc.code_combination_id = gl.code_combination_id
          AND  gi.je_header_id     = gh.je_header_id
          AND  gi.je_line_num      = gl.je_line_num
               -- GL to XLA Relations
          AND  xl.gl_sl_link_id    = gi.gl_sl_link_id
          AND  xl.gl_sl_link_table = gi.gl_sl_link_table
          AND  xl.ledger_id        = gl.ledger_id
               -- XLA Predicates
          AND  xl.ae_header_id     = xh.ae_header_id
          AND  xe.event_id         = xh.event_id
          AND  xe.application_id   = xvl.application_id
          AND  xvl.event_type_code = xe.event_type_code
          AND  xte.entity_id       = xe.entity_id
          AND  xte.application_id  = xe.application_id
          -- Important: Fetch Only Accounting Events from AR and AP Only
          AND  xe.application_id
               IN
                 (  200  -- Payables
                   ,222  -- Receivables
                 )
          --  These Accounting Events should not have been fetched
          --  as part of Entries related to Lease fetched above
          AND  xe.event_id
               NOT IN
                 (
                    SELECT  DISTINCT gt.value15_num -- trx_xla_event_id
                      FROM  okl_g_reports_gt  gt
                     WHERE  gt.value1_text IN
                            (
                              'GL_ACC_OLM_ENTRIES'
                             ,'GL_ACC_NON_SPEC_CRITERIA'
                             ,'GL_ACC_NON_SPEC_PERIOD'
                            )
                 )
          -- Predicates to fetch the Names
          AND  ledger.ledger_id    = xl.ledger_id
          AND  app.application_id  = xe.application_id
          -- Restrict the Journal Entries to be in between Start and End Dates
          AND  gl.period_name IN
               (
                 SELECT  per.period_name
                   FROM  gl_periods per
                  WHERE  per.period_set_name = l_period_set_name
                    AND  per.START_DATE >= p_start_date
                    AND  per.end_date <=  p_end_date
                    AND  per.adjustment_period_flag = 'N'
                    AND  period_type = l_period_type
               )
          -- End of Query Segment to fetch Posted Acc. Entries in GL
          --  from applications other than GL, OLM, FA, AR and AP
      );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the Accounting Journals AR and AP Applications but not related to OLM:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating Accounting Journals AR and AP Applications but not related to OLM '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'End: ' || l_api_name ||'(-)' );
    -- Set the Return Status and return back
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS
    THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
  END populate_acc_data;


  -- Start of comments
  --
  -- Function Name   : populate_gl_balances
  -- Description     : API to populate the GL Opening and Closing Balances
  --
  -- Business Rules  : Called from prepare_gross_rec_report
  -- Parameters      :
  -- Version         : 1.0
  -- History         : Ravindranath Gooty created.
  -- End of comments

  PROCEDURE populate_gl_balances(
              p_api_version   IN         NUMBER
             ,p_init_msg_list IN         VARCHAR2
             ,x_return_status OUT NOCOPY VARCHAR2
             ,x_msg_count     OUT NOCOPY NUMBER
             ,x_msg_data      OUT NOCOPY VARCHAR2
             ,p_ledger_id     IN         NUMBER
             ,p_period_from   IN         VARCHAR2
             ,p_period_to     IN         VARCHAR2)
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'populate_gl_balances';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Debug related parameters
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Local Variables
    l_trace_time          DATE;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRRPTB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Begin: ' || l_api_name ||'(+)' );
    l_return_status := okl_api.g_ret_sts_success;
    -- By now we have the List of Eligible Products and Code Combinations Available
    -- in the corresponding _GT tables
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Input Parameters ' ||
      ' p_ledger_id   =' || p_ledger_id  ||
      ' p_period_from =' || p_period_from ||
      ' p_period_to   =' || p_period_to );

    -------------------------------------------------------------------------------------
    -- Query segment to Insert the GL Opening Balances ...
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the GL Opening Balances Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                )
      SELECT -- String Formatted Columns
             'GL_OPENING_BALANCE'       --value1_text
            ,currency_code              --value11_text
            ,period_name                --value12_text
            ,account_number             --value13_text -- Stores the Segment Number
            -- Number Formatted Columns
            ,SUM(opening_bal_trx_curr)  --value1_num
            ,SUM(opening_bal_led_curr)  --value2_num
        FROM
      (
        -- Query Segment to fetch the GL Balances for Non-Ledger Currency
        SELECT  cc_gt.account_number          account_number -- Stores the Segment Number
               ,cc_gt.ccid                    ccid
               ,bal.currency_code             currency_code
               ,bal.period_name               period_name
               ,( begin_balance_dr
                  - begin_balance_cr )        opening_bal_trx_curr
               ,( begin_balance_dr_beq
                  - begin_balance_cr_beq )    opening_bal_led_curr
          FROM  gl_balances                   bal
               ,gl_ledgers                    led
               ,okl_code_cmbns_gt             cc_gt
         WHERE  led.ledger_id   = p_ledger_id
           AND  bal.ledger_id   = led.ledger_id
           -- opening Balance as on Period Start
           AND  bal.translated_flag IS NULL
           AND  bal.currency_code <> 'STAT'
           AND  bal.period_name = p_period_from
           AND  bal.actual_flag = 'A'
           AND  bal.currency_code <> led.currency_code
           AND  bal.currency_code <> 'STAT'
           AND  bal.code_combination_id = cc_gt.ccid
      UNION ALL
        -- Query Segment to fetch the GL Balances for Ledger Currency
        -- Logic: GL Balances store thes Accumulated Balance of all Currencies
        --        in the Ledger Currency. Hence need to deduct the non-ledger
        --        currency Total from the GL Balance
        SELECT  account_number              account_number -- Stores the Segment Number
               ,ccid                        ccid
               ,currency_code               currency_code
               ,period_name                 period_name
               ,nvl(opening_bal_led_curr,0) opening_bal_trx_curr
               ,nvl(opening_bal_led_curr,0) opening_bal_led_curr
          FROM
          (
            SELECT  cc_gt.account_number      account_number -- Segment Number
                   ,cc_gt.ccid                ccid
                   ,bal.currency_code         currency_code
                   ,bal.period_name           period_name
                   ,( begin_balance_dr
                      - begin_balance_cr )    opening_bal_led_curr
              FROM  gl_balances               bal
                   ,gl_ledgers                led
                   ,okl_code_cmbns_gt         cc_gt
             WHERE  led.ledger_id   = p_ledger_id
               AND  bal.ledger_id   = led.ledger_id
               -- opening Balance as on Period Start
               AND  bal.translated_flag IS NULL
               AND  bal.currency_code <> 'STAT'
               AND  bal.period_name = p_period_from
               AND  bal.actual_flag = 'A'
               AND  bal.currency_code = led.currency_code
               AND  bal.code_combination_id = cc_gt.ccid
          )
    )
    GROUP BY -- String Formatted Columns
       'GL_OPENING_BALANCE'
      ,currency_code
      ,period_name
      ,account_number
    ; -- End of Open Balances Query

   -- Logic:
   --  Till now, we have fetched the GL Opening Balances for both the
   --   Ledger Currency and Non-Ledger currencies.
   --  But the Ledger Currency Balances in GL is sum of Balances in all the
   --    Transactional Currencies too. Hence, need to deduct the Sum of
   --    Opening Balances for all non Ledger Currencies from the Ledger Currencies
   --    if exists.
   UPDATE okl_g_reports_gt lc
       SET  value1_num =
            value1_num -
             NVL(
              (
                SELECT  SUM(value2_num) -- Sum of Balance in Ledger Currency
                  FROM  okl_g_reports_gt nlc
                 WHERE  nlc.value1_text = 'GL_OPENING_BALANCE'
                    AND nlc.value12_text = lc.value12_text -- Period Name
                    AND nlc.value13_text = lc.value13_text -- Account Number
                    AND nlc.value11_text <> lc.value11_text
               ), 0 )
           ,value2_num =
            value2_num -
             NVL(
               (
                SELECT  SUM(value2_num) -- Sum of Balance in Ledger Currency
                  FROM  okl_g_reports_gt nlc
                 WHERE  nlc.value1_text = 'GL_OPENING_BALANCE'
                    AND nlc.value12_text = lc.value12_text -- Period Name
                    AND nlc.value13_text = lc.value13_text -- Account Number
                    AND nlc.value11_text <> lc.value11_text
               ), 0 )
     -- Pick only the Ledger Currency GL Opening Balances
     WHERE value1_text = 'GL_OPENING_BALANCE' --value1_text
       AND value11_text IN
       (
          SELECT  currency_code
            FROM  gl_ledgers
           WHERE  ledger_id = p_ledger_id
       );

   --Bug:7535993 by nikshah
   --If no records found for OPENING BALANCE in GL
   --for natural account, enter 0 amount with ledger currency
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                )
      SELECT -- String Formatted Columns
             'GL_OPENING_BALANCE'       --value1_text
            ,(select currency_code
              from gl_ledgers
              where ledger_id = p_ledger_id)              --value11_text
            ,p_period_from                --value12_text
            ,cgt.account_number           --value13_text -- Stores the Segment Number
            ,0  --value1_num
            ,0  --value2_num
      FROM (select distinct account_number
            from okl_code_cmbns_gt) cgt
      WHERE cgt.account_number not in (select value13_text
                                       from okl_g_reports_gt
                                       where value1_text = 'GL_OPENING_BALANCE'
                                       );

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the GL Opening Balances End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating GL Opening Balances '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

    -------------------------------------------------------------------------------------
    -- Query segment to Insert the GL Period Activity ... In case of income report
    -------------------------------------------------------------------------------------
    IF p_report_type_code = 'INCOME' THEN

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the GL Period Activity Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement

    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                )
      SELECT -- String Formatted Columns
             'GL_PERIOD_ACTIVITY'       --value1_text
            ,currency_code              --value11_text
            ,period_name                --value12_text
            ,account_number             --value13_text -- Stores the Segment Number
            ,SUM(period_activity_trx_curr)  --value1_num
            ,SUM(period_activity_led_curr)  --value2_num
        FROM
      (
        -- Query Segment to fetch the GL Closing Balances for Non-Ledger Currency
        SELECT  cc_gt.account_number          account_number -- Stores the Segment Number
               ,cc_gt.ccid                    ccid
               ,bal.currency_code             currency_code
               ,bal.period_name               period_name
               ,period_net_dr -
                period_net_cr                 period_activity_trx_curr
               ,period_net_dr_beq -
                period_net_cr_beq             period_activity_led_curr
          FROM  gl_balances                   bal
               ,gl_ledgers                    led
               ,okl_code_cmbns_gt             cc_gt
               ,gl_period_statuses        gps
         WHERE  led.ledger_id   = p_ledger_id
           AND  bal.ledger_id   = led.ledger_id
           AND  gps.application_id = 101
           and  gps.ledger_id = led.ledger_id
           and  bal.period_name = gps.period_name
           and  gps.effective_period_num >= ( select pf.effective_period_num
                                              from   gl_period_statuses pf
                                              where  pf.application_id = 101
                                                and  pf.ledger_id = p_ledger_id
                                                and  pf.period_name = p_period_from
                                                and  rownum < 2
                                            )
           and  gps.effective_period_num <= ( select pt.effective_period_num
                                              from   gl_period_statuses pt
                                              where  pt.application_id = 101
                                                and  pt.ledger_id = p_ledger_id
                                                and  pt.period_name = p_period_to
                                                and  rownum < 2
                                             )
           AND  bal.actual_flag = 'A'
           AND  bal.translated_flag IS NULL
           AND  bal.currency_code <> 'STAT'
           AND  bal.currency_code <> led.currency_code
           AND  bal.currency_code <> 'STAT'
           AND  bal.code_combination_id = cc_gt.ccid
      UNION ALL
        -- Query Segment to fetch the GL Closing Balances for Ledger Currency
        -- Logic: GL Balances store thes Accumulated Balance of all Currencies
        --        in the Ledger Currency. Hence need to deduct the non-ledger
        --        currency Total from the GL Balance
        SELECT  account_number              account_number -- Stores the Segment Number
               ,ccid                        ccid
               ,currency_code               currency_code
               ,period_name                 period_name
               ,nvl(period_activity_led_curr,0) period_activity_trx_curr
               ,nvl(period_activity_led_curr,0) period_activity_led_curr
          FROM
          (
            SELECT  cc_gt.account_number      account_number -- Segment Number
                   ,cc_gt.ccid                ccid
                   ,bal.currency_code         currency_code
                   ,bal.period_name           period_name
                   ,period_net_dr -
                    period_net_cr             period_activity_led_curr
              FROM  gl_balances               bal
                   ,gl_ledgers                led
                   ,okl_code_cmbns_gt         cc_gt
                   ,gl_period_statuses        gps
             WHERE  led.ledger_id   = p_ledger_id
               AND  gps.application_id = 101
               and  gps.ledger_id = led.ledger_id
               and  bal.period_name = gps.period_name
               and  gps.effective_period_num >= ( select pf.effective_period_num
                                                  from   gl_period_statuses pf
                                                  where  pf.application_id = 101
                                                    and  pf.ledger_id = p_ledger_id
                                                    and  pf.period_name = p_period_from
                                                    and  rownum < 2
                                                )
               and  gps.effective_period_num <= ( select pt.effective_period_num
                                                  from   gl_period_statuses pt
                                                  where  pt.application_id = 101
                                                    and  pt.ledger_id = p_ledger_id
                                                    and  pt.period_name = p_period_to
                                                    and  rownum < 2
                                                 )
               AND  bal.ledger_id   = led.ledger_id
               AND  bal.translated_flag IS NULL
               AND  bal.currency_code <> 'STAT'
               AND  bal.actual_flag = 'A'
               AND  bal.currency_code = led.currency_code
               AND  bal.code_combination_id = cc_gt.ccid
          )
    )
    GROUP BY -- String Formatted Columns
       'GL_PERIOD_ACTIVITY'
      ,currency_code
      ,period_name
      ,account_number
    ;

   -- Logic:
   --  Till now, we have fetched the GL Period Activity for both the
   --   Ledger Currency and Non-Ledger currencies.
   --  But the Ledger Currency Balances in GL is sum of Balances in all the
   --    Transactional Currencies too. Hence, need to deduct the Sum of
   --    Period Activity for all non Ledger Currencies from the Ledger Currencies
   --    if exists.
   UPDATE okl_g_reports_gt lc
       SET  value1_num =
            value1_num -
             NVL(
              (
                SELECT  SUM(value2_num) -- Sum of Balance in Ledger Currency
                  FROM  okl_g_reports_gt nlc
                 WHERE  nlc.value1_text = 'GL_PERIOD_ACTIVITY'
                    AND nlc.value12_text = lc.value12_text -- Period Name
                    AND nlc.value13_text = lc.value13_text -- Account Number
                    AND nlc.value11_text <> lc.value11_text
               ), 0)
           ,value2_num =
            value2_num -
             NVL(
              (
                SELECT  SUM(value2_num) -- Sum of Balance in Ledger Currency
                  FROM  okl_g_reports_gt nlc
                 WHERE  nlc.value1_text = 'GL_PERIOD_ACTIVITY'
                    AND nlc.value12_text = lc.value12_text -- Period Name
                    AND nlc.value13_text = lc.value13_text -- Account Number
                    AND nlc.value11_text <> lc.value11_text
              ), 0 )
     -- Pick only the Ledger Currency GL Opening Balances
     WHERE value1_text = 'GL_PERIOD_ACTIVITY' --value1_text
       AND value11_text IN
       (
          SELECT  currency_code
            FROM  gl_ledgers
           WHERE  ledger_id = p_ledger_id
       );

    --Bug:7535993 by nikshah
    --If no records found for Period Activity in GL
    --for natural account, enter 0 amount with ledger currency
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                )
      SELECT -- String Formatted Columns
             'GL_PERIOD_ACTIVITY'       --value1_text
            ,(select currency_code
              from gl_ledgers
              where ledger_id = p_ledger_id)              --value11_text
            ,null                --value12_text
            ,cgt.account_number             --value13_text -- Stores the Segment Number
            -- Number Formatted Columns
            ,0  --value1_num
            ,0  --value2_num
      FROM (select distinct account_number
            from okl_code_cmbns_gt) cgt
      WHERE cgt.account_number not in (select value13_text
                                       from okl_g_reports_gt
                                       where value1_text = 'GL_PERIOD_ACTIVITY'
                                       );

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the GL Period Activity End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating GL Period Activity '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

   END IF; --End if of period activity for report type INCOME
    -------------------------------------------------------------------------------------
    -- Query segment to Insert the GL Closing Balances ...
    -------------------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Inserting the GL Closing Balances Start Time:'
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    -- Start the stop watch
    l_trace_time := SYSDATE;
    -- Actual Insert Statement
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                )
      SELECT -- String Formatted Columns
             'GL_CLOSING_BALANCE'       --value1_text
            ,currency_code              --value11_text
            ,period_name                --value12_text
            ,account_number             --value13_text -- Stores the Segment Number
            -- Number Formatted Columns
            -- Populating the Closing Balance asa Negative Amount
            --  for XML Publisher Layout Publisher
            -- In the Layout sum( closing balance + gl accounts ) = 0 hence
            --  negated the Closing Balance
            ,SUM(closing_bal_trx_curr) * -1  --value1_num
            ,SUM(closing_bal_led_curr) * -1  --value2_num
        FROM
      (
        -- Query Segment to fetch the GL Closing Balances for Non-Ledger Currency
        SELECT  cc_gt.account_number          account_number -- Stores the Segment Number
               ,cc_gt.ccid                    ccid
               ,bal.currency_code             currency_code
               ,bal.period_name               period_name
               ,(
                  ( period_net_dr
                    + begin_balance_dr
                  )
                  -
                  ( period_net_cr
                    + begin_balance_cr
                  )
                )                              closing_bal_trx_curr
               ,(
                  ( period_net_dr_beq
                    + begin_balance_dr_beq
                  )
                  -
                  ( period_net_cr_beq
                    + begin_balance_cr_beq
                  )
                 )                            closing_bal_led_curr
          FROM  gl_balances                   bal
               ,gl_ledgers                    led
               ,okl_code_cmbns_gt             cc_gt
         WHERE  led.ledger_id   = p_ledger_id
           AND  bal.ledger_id   = led.ledger_id
           -- Closing Balance as on Period End
           AND  bal.period_name = p_period_to
           AND  bal.actual_flag = 'A'
           AND  bal.translated_flag IS NULL
           AND  bal.currency_code <> 'STAT'
           AND  bal.currency_code <> led.currency_code
           AND  bal.currency_code <> 'STAT'
           AND  bal.code_combination_id = cc_gt.ccid
      UNION ALL
        -- Query Segment to fetch the GL Closing Balances for Ledger Currency
        -- Logic: GL Balances store thes Accumulated Balance of all Currencies
        --        in the Ledger Currency. Hence need to deduct the non-ledger
        --        currency Total from the GL Balance
        SELECT  account_number              account_number -- Stores the Segment Number
               ,ccid                        ccid
               ,currency_code               currency_code
               ,period_name                 period_name
               ,nvl(closing_bal_led_curr,0) closing_bal_trx_curr
               ,nvl(closing_bal_led_curr,0) closing_bal_led_curr
          FROM
          (
            SELECT  cc_gt.account_number      account_number -- Segment Number
                   ,cc_gt.ccid                ccid
                   ,bal.currency_code         currency_code
                   ,bal.period_name           period_name
                   ,(
                      ( period_net_dr
                        + begin_balance_dr
                      )
                      -
                      ( period_net_cr
                        + begin_balance_cr
                      )
                    )                         closing_bal_led_curr
              FROM  gl_balances               bal
                   ,gl_ledgers                led
                   ,okl_code_cmbns_gt         cc_gt
             WHERE  led.ledger_id   = p_ledger_id
               AND  bal.ledger_id   = led.ledger_id
               -- Closing Balance as on Period End
               AND  bal.period_name = p_period_to
               AND  bal.translated_flag IS NULL
               AND  bal.currency_code <> 'STAT'
               AND  bal.actual_flag = 'A'
               AND  bal.currency_code = led.currency_code
               AND  bal.code_combination_id = cc_gt.ccid
          )
    )
    GROUP BY -- String Formatted Columns
       'GL_CLOSING_BALANCE'
      ,currency_code
      ,period_name
      ,account_number
    ;

   -- Logic:
   --  Till now, we have fetched the GL Closing Balances for both the
   --   Ledger Currency and Non-Ledger currencies.
   --  But the Ledger Currency Balances in GL is sum of Balances in all the
   --    Transactional Currencies too. Hence, need to deduct the Sum of
   --    Opening Balances for all non Ledger Currencies from the Ledger Currencies
   --    if exists.
   UPDATE okl_g_reports_gt lc
       SET  value1_num =
            value1_num -
             NVL(
              (
                SELECT  SUM(value2_num) -- Sum of Balance in Ledger Currency
                  FROM  okl_g_reports_gt nlc
                 WHERE  nlc.value1_text = 'GL_CLOSING_BALANCE'
                    AND nlc.value12_text = lc.value12_text -- Period Name
                    AND nlc.value13_text = lc.value13_text -- Account Number
                    AND nlc.value11_text <> lc.value11_text
               ), 0)
           ,value2_num =
            value2_num -
             NVL(
              (
                SELECT  SUM(value2_num) -- Sum of Balance in Ledger Currency
                  FROM  okl_g_reports_gt nlc
                 WHERE  nlc.value1_text = 'GL_CLOSING_BALANCE'
                    AND nlc.value12_text = lc.value12_text -- Period Name
                    AND nlc.value13_text = lc.value13_text -- Account Number
                    AND nlc.value11_text <> lc.value11_text
              ), 0 )
     -- Pick only the Ledger Currency GL Opening Balances
     WHERE value1_text = 'GL_CLOSING_BALANCE' --value1_text
       AND value11_text IN
       (
          SELECT  currency_code
            FROM  gl_ledgers
           WHERE  ledger_id = p_ledger_id
       );

    --Bug:7535993 by nikshah
    --If no records found for CLOSING BALANCE in GL
    --for natural account, enter 0 amount with ledger currency
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                )
      SELECT -- String Formatted Columns
             'GL_CLOSING_BALANCE'       --value1_text
            ,(select currency_code
              from gl_ledgers
              where ledger_id = p_ledger_id)              --value11_text
            ,p_period_to                --value12_text
            ,cgt.account_number             --value13_text -- Stores the Segment Number
            -- Number Formatted Columns
            ,0  --value1_num
            ,0  --value2_num
      FROM (select distinct account_number
            from okl_code_cmbns_gt) cgt
      WHERE cgt.account_number not in (select value13_text
                                       from okl_g_reports_gt
                                       where value1_text = 'GL_CLOSING_BALANCE'
                                       );

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Inserting the GL Closing Balances End Time:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Populating GL Balances '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

    -- Requirement:
    --   Always need to show the GL Closing and Opening Balances, when there are entries
    --   in the Streams Closing and Opening Balances. So that the Report generated fillay
    --   shows the GL and Stream Balance headers.
    -- Case 1: Insert GL Closing Balance record for which we have Streams Closing Balance
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                )
       SELECT -- String Formatted Columns
           'GL_CLOSING_BALANCE'       --value1_text
          ,value11_text               --value11_text -- Currency Code
          ,NULL                       --value12_text
          ,NULL                       --value13_text
          ,0                          --value1_num
          ,0                          --value2_num
        FROM okl_g_reports_gt
       WHERE value1_text IN ( 'OKL_STR_CLOSE' )
         AND value11_text
         NOT IN
           (
              SELECT  DISTINCT value11_text
                FROM  okl_g_reports_gt
               WHERE  value1_text = 'GL_CLOSING_BALANCE'
           )
       GROUP BY 'GL_CLOSING_BALANCE'
               ,value11_text;


    -- Case 2: Insert GL Opening Balance record for which we have Streams Opening Balance
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value12_text
                  ,value13_text
                  -- Number Formatted Columns
                  ,value1_num
                  ,value2_num
                )
       SELECT -- String Formatted Columns
           'GL_OPENING_BALANCE'       --value1_text
          ,value11_text               --value11_text -- Currency Code
          ,NULL                       --value12_text
          ,NULL                       --value13_text
          ,0                          --value1_num
          ,0                          --value2_num
        FROM okl_g_reports_gt
       WHERE value1_text IN ( 'OKL_STR_OPEN' )
         AND value11_text
         NOT IN
           (
              SELECT  DISTINCT value11_text
                FROM  okl_g_reports_gt
               WHERE  value1_text = 'GL_OPENING_BALANCE'
           )
       GROUP BY 'GL_OPENING_BALANCE'
               ,value11_text;
    -- Case 3: Insert Stream Closing Balance record for which we have GL Closing Balance
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value5_text  -- Contract Number
                  ,value14_text -- Organization Name
                  -- Number Formatted Columns
                  ,value3_num -- Stream Balances Amount
                )
       SELECT -- String Formatted Columns
           'OKL_STR_CLOSE'       --value1_text
          ,value11_text               --value11_text -- Currency Code
          ,NULL                       --value5_text
          ,NULL                       --value14_text
          ,0                          --value3_num
        FROM okl_g_reports_gt
       WHERE value1_text IN ( 'GL_CLOSING_BALANCE' )
         AND value11_text
         NOT IN
           (
              SELECT  DISTINCT value11_text
                FROM  okl_g_reports_gt
               WHERE  value1_text = 'OKL_STR_CLOSE'
           )
       GROUP BY 'OKL_STR_CLOSE'
                ,value11_text;

    -- Case 4: Insert Stream Opening Balance record for which we have GL Opening Balance
    INSERT INTO okl_g_reports_gt
                (
                  -- String Formatted Columns
                   value1_text
                  ,value11_text
                  ,value5_text  -- Contract Number
                  ,value14_text -- Organization Name
                  -- Number Formatted Columns
                  ,value3_num -- Stream Balances Amount
                )
       SELECT -- String Formatted Columns
           'OKL_STR_OPEN'       --value1_text
          ,value11_text               --value11_text -- Currency Code
          ,NULL                       --value5_text
          ,NULL                       --value14_text
          ,0                          --value3_num
        FROM okl_g_reports_gt
       WHERE value1_text IN ( 'GL_OPENING_BALANCE' )
         AND value11_text
         NOT IN
           (
              SELECT  DISTINCT value11_text
                FROM  okl_g_reports_gt
               WHERE  value1_text = 'OKL_STR_OPEN'
           )
       GROUP BY 'OKL_STR_OPEN'
                ,value11_text;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'End: ' || l_api_name ||'(-)' );
    -- Set the Return Status and return back
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS
    THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
  END populate_gl_balances;

  -- Start of comments
  --
  -- Function Name   : validate_orgs_access.
  -- Description     : API to validate that User has access to all Orgs
  --                    whose Journals can impact the Ledger inputted
  --
  -- Business Rules  :
  -- Parameters      : p_ledger_id
  -- Version         : 1.0
  -- History         : Ravindranath Gooty created.
  --
  -- End of comments
  FUNCTION validate_orgs_access( p_ledger_id NUMBER )
    RETURN BOOLEAN
  IS
    -- Cursor Declarations
    CURSOR c_orgs_using_ledger_csr( p_ledger_id NUMBER )
    IS
     SELECT  organization_id        org_id
            ,NAME                   org_name
       FROM  hr_operating_units     hr
      WHERE  hr.set_of_books_id = p_ledger_id;
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'validate_orgs_access';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Debug related parameters
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Local Variable Declarations
    l_error_out            VARCHAR2(1);
    l_check_access         VARCHAR2(1);

    TYPE rep_gt_tbl_type IS TABLE OF okl_g_reports_gt%ROWTYPE
      INDEX BY BINARY_INTEGER;
    l_invalid_orgs_tbl    rep_gt_tbl_type;
    i                     NUMBER;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRRPTB.pls call ' || l_api_name);
    -- Constraint:
    --  The Report shouldnot be generated if the user doesnot have access to atleast
    --  one Operating Unit, whose Journal Entries can impact the Ledger inputted for the
    --  Report
    --   Eg. If say User U1 has access to OU1, OU2 but the Ledger L1 has been associated
    --       Orgs OU1, OU2, OU3, OU4, OU5, then report should not be generated.
    -- Initialize the Error Out flag to 'N'
    l_error_out := 'N';
    i := 1;
    FOR t_rec IN c_orgs_using_ledger_csr( p_ledger_id => p_ledger_id )
    LOOP
      -- Check whether user has access to this Operating Unit
      l_check_access := MO_GLOBAL.check_access( p_org_id => t_rec.org_id );
      IF l_check_access = 'Y'
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'User has access to Operating Unit ID ' || t_rec.org_id );
      ELSE
        -- User doesnot have access to the Operating Unit, hence error out
        l_error_out := 'Y';
        l_invalid_orgs_tbl(i).value1_text := 'INVALID_ORG';
        l_invalid_orgs_tbl(i).value2_text := t_rec.org_name;
        l_invalid_orgs_tbl(i).value1_num  := t_rec.org_id;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'User doesnot have has access to Operating Unit ID ' || t_rec.org_id
          || 'Org Name' || t_rec.org_name);
        -- Increment Index i
        i := i + 1;
      END IF;
    END LOOP;

    IF l_error_out = 'Y'
    THEN
      -- Finally insert the list of Invalid Org Names to print it on the Report
      FORALL i IN l_invalid_orgs_tbl.FIRST .. l_invalid_orgs_tbl.LAST
        INSERT INTO okl_g_reports_gt VALUES l_invalid_orgs_tbl(i);

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
          'Returning FALSE. End API OKL_REPORT_GENERATOR_PVT.' || l_api_name );
      RETURN FALSE;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
          'End API OKL_REPORT_GENERATOR_PVT.' || l_api_name );
    -- Return TRUE and Exit
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS
    THEN
      l_return_status := okl_api.g_ret_sts_unexp_error;
      -- Set the oracle error message
      okl_api.set_message(p_app_name     => okc_api.g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      RETURN FALSE;
  END validate_orgs_access;


  -- Start of comments
  --
  -- Function Name   : POPULATE_STRM_TO_TRX_DATA
  -- Description    : Populates streams to transaction and vice versa data for
  --                  Income Reconciliation Report
  -- Business Rules  : Called from generate_gross_inv_recon_rpt
  -- Parameters       :
  -- Version      : 1.0
  -- History        : NIKSHAH created.
  --
  -- End of comments
PROCEDURE POPULATE_STRM_TO_TRX_DATA
             (p_api_version   IN         NUMBER
             ,p_init_msg_list IN         VARCHAR2
             ,x_return_status OUT NOCOPY VARCHAR2
             ,x_msg_count     OUT NOCOPY NUMBER
             ,x_msg_data      OUT NOCOPY VARCHAR2
             ,p_report_id     IN         NUMBER
             ,p_ledger_id     IN         NUMBER
             ,p_start_date    IN         DATE
             ,p_end_date      IN         DATE
             ,p_org_id        IN         NUMBER
             ,p_le_id         IN         NUMBER
             )IS

  L_EXPECTED_STREAMS CONSTANT VARCHAR2(30) := 'EXPECTED_STREAMS';
  L_STRMS_WITHOUT_TRX CONSTANT VARCHAR2(30) := 'STRMS_WITHOUT_TRX';
  L_TRX_SPEC_STRMS_ASE CONSTANT VARCHAR2(30) := 'TRX_SPEC_STRMS_ASE';
  L_NON_SPEC_STRMS_NASE CONSTANT VARCHAR2(30) := 'NON_SPEC_STRMS_NASE';
  L_TRX_SPEC_STRMS_NASE CONSTANT VARCHAR2(30) := 'TRX_SPEC_STRMS_NASE';
  L_TRX_ADD_ACC_EVENTS CONSTANT VARCHAR2(30) := 'TRX_ADD_ACC_EVENTS';
  L_NON_SPEC_STRMS_ASE CONSTANT VARCHAR2(30) := 'NON_SPEC_STRMS_ASE';
  L_TRX_NON_SPEC_STRMS CONSTANT VARCHAR2(30) := 'TRX_NON_SPEC_STRMS';

  l_api_version      CONSTANT NUMBER         := 1;
  l_api_name         CONSTANT VARCHAR2(30)   := 'POPULATE_STRM_TO_TRX_DATA';
  l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

  -- Debug related parameters
  l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
  l_debug_enabled       VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  l_start_date     DATE :=  p_start_date;
  l_end_date     DATE :=  p_end_date;

  l_s_khr_id NUMBER;
  l_s_kle_id NUMBER;
  l_s_sty_id NUMBER;

  l_no_single_trx_exists BOOLEAN := FALSE;
  l_trx_exists BOOLEAN := FALSE;
  l_stream_currency_exists BOOLEAN := FALSE;
  l_is_spec_strm_type BOOLEAN := FALSE;

  l_trx_date            DATE;
  l_trace_time          DATE;

  l_count NUMBER := 1;
  l_accrual_count NUMBER := 1;
  l_reverse_count NUMBER := 1;
  l_non_elig_count NUMBER := 1;
  l_report_count NUMBER;
  l_stream_amount_count NUMBER := 0;
  l_no_of_streams_defined NUMBER := 0;

  --Cursor to see if there are any stream types defined for a report
  CURSOR C_CHECK_STREAMS_DEFINED
  IS
  SELECT STY_ID
  FROM   okl_report_stream_params
  WHERE  report_id = p_report_id;

  --Cursor to fetch all accruable streams for a  product
  CURSOR C_ALL_ACCRUABLE_STREAMS (p_pdt_id NUMBER)
  IS
  SELECT styy.id STY_ID
  FROM OKL_PROD_STRM_TYPES PSYY,
       OKL_STRM_TYPE_V STYY
  WHERE psyy.sty_id = styy.id
    AND psyy.accrual_yn = 'Y'
    AND psyy.pdt_id = p_pdt_id;

  --Cursor to fetch stream type IDs which are not specified in the template
  CURSOR C_STREAM_TYPES_NOT_SPECIFIED
  IS
  SELECT param.STY_ID
  FROM   okl_report_trx_params param,
         okl_trx_types_b trx
  WHERE  report_id = p_report_id
    AND  trx.id = param.try_id
    AND  trx.AEP_CODE = 'ACCRUAL'
  MINUS
  SELECT STY_ID
  FROM   okl_report_stream_params
  WHERE  report_id = p_report_id;

  --Cursor to fetch all products
  CURSOR C_GET_PRODUCTS
  IS
  SELECT product_id
  FROM okl_rep_products_gt;

  --Cursor to fetch all streams for given contract number and specified streams
  CURSOR C_MASTER_STREAMS_SPECIFIED
         (p_khr_id NUMBER)
  IS
  SELECT OU.NAME OPERATING_UNIT,
         PRO.NAME PROD_NAME,
         KHR.CONTRACT_NUMBER,
         KLE.NAME ASSET_NUMBER,
         STY.NAME STREAM_TYPE_NAME,
         STY.STYB_PURPOSE_MEANING STREAM_PURPOSE,
         STE.STREAM_ELEMENT_DATE,
         STE.AMOUNT,
         KHR.CURRENCY_CODE,
         STE.SE_LINE_NUMBER,
         OU.ORGANIZATION_ID ORG_ID,
         PRO.ID PDT_ID,
         KHR.ID KHR_ID,
         KLE.ID KLE_ID,
         STY.ID STY_ID,
         (SELECT  per.period_name
          FROM  gl_periods per
          WHERE  per.period_set_name = (SELECT gl.period_set_name
                                                               FROM gl_ledgers gl
                                                               WHERE ledger_id = p_ledger_id)
            AND  per.START_DATE <= STE.STREAM_ELEMENT_DATE
            AND  per.end_date >=  STE.STREAM_ELEMENT_DATE
            AND  per.adjustment_period_flag = 'N'
            AND  period_type = (SELECT gl.accounted_period_type
                                             FROM gl_ledgers gl
                                             WHERE ledger_id = p_ledger_id)
            ) STREAM_PERIOD
  FROM   OKL_STRM_TYPE_V STY,
         okl_streams_rep_v STM,
         OKL_STRM_ELEMENTS STE,
         OKC_K_HEADERS_ALL_B KHR,
         OKL_K_HEADERS KH,
         OKC_K_LINES_V KLE,
         OKL_PRODUCTS_V PRO,
         HR_OPERATING_UNITS OU
  WHERE  STY.ID = STM.STY_ID
    AND  STM.ID = STE.STM_ID
    AND  STM.KHR_ID = KHR.ID
--    AND  STM.ACTIVE_YN = 'Y'
    AND  KLE.ID = STM.KLE_ID
    AND  KLE.DNZ_CHR_ID = KHR.ID
    AND  KH.ID = KHR.ID
    AND  KH.PDT_ID = PRO.ID
    AND  KHR.ORG_ID = OU.ORGANIZATION_ID
    AND  STY.ID IN ( SELECT styy.id
                     FROM OKL_PROD_STRM_TYPES PSYY,
                          OKL_STRM_TYPE_V STYY
                     WHERE psyy.sty_id = sty.id
                       AND psyy.accrual_yn = 'Y'
                       and psyy.pdt_id = KH.PDT_ID
                     UNION
                     SELECT  sty_id
                     FROM  okl_report_stream_params  rsp
                     WHERE  rsp.report_id = p_report_id
                     )
    and KH.ID = p_khr_id
    AND  STM.ID IN ( SELECT MAX(ID)
                     FROM ( SELECT STM.STY_ID, STM.ID, MAX(DATE_CURRENT)
                            FROM   OKL_STRM_TYPE_V STY,
                                   okl_streams_rep_v STM,
                                   OKL_STRM_ELEMENTS STE,
                                   OKC_K_HEADERS_ALL_B KHR,
                                   OKL_K_HEADERS KH,
                                   OKC_K_LINES_V KLE,
                                   OKL_PRODUCTS_V PRO,
                                   HR_OPERATING_UNITS OU
                            WHERE  STY.ID = STM.STY_ID
                              AND  STM.ID = STE.STM_ID
                              AND  STM.KHR_ID = KHR.ID
                              AND  STM.DATE_CURRENT <= p_end_date
                              AND  NVL(STM.date_history,  p_end_date) between p_start_date  and p_end_date
                              AND  KHR.ID = p_khr_id
                              AND  KLE.ID = STM.KLE_ID
                              AND  KLE.DNZ_CHR_ID = KHR.ID
                              AND  KH.ID = KHR.ID
                              AND  KH.PDT_ID = PRO.ID
                              AND  KHR.ORG_ID = OU.ORGANIZATION_ID
                            GROUP BY STM.STY_ID, STM.ID
                            ORDER BY 3 DESC
                           )
                     GROUP BY STY_ID
                   )
  ORDER BY KHR.ID, KLE.ID, STY.ID, STE.SE_LINE_NUMBER;

  --Cursor to fetch all streams for given contract number and all accruable streams
  CURSOR C_MASTER_STREAMS_ALL
         (p_khr_id NUMBER)
  IS
  SELECT OU.NAME OPERATING_UNIT,
         PRO.NAME PROD_NAME,
         KHR.CONTRACT_NUMBER,
         KLE.NAME ASSET_NUMBER,
         STY.NAME STREAM_TYPE_NAME,
         STY.STYB_PURPOSE_MEANING STREAM_PURPOSE,
         STE.STREAM_ELEMENT_DATE,
         STE.AMOUNT,
         KHR.CURRENCY_CODE,
         STE.SE_LINE_NUMBER,
         OU.ORGANIZATION_ID ORG_ID,
         PRO.ID PDT_ID,
         KHR.ID KHR_ID,
         KLE.ID KLE_ID,
         STY.ID STY_ID,
         (SELECT  per.period_name
          FROM  gl_periods per
          WHERE  per.period_set_name = (SELECT gl.period_set_name
                                        FROM gl_ledgers gl
                                        WHERE ledger_id = p_ledger_id)
            AND  per.START_DATE <= STE.STREAM_ELEMENT_DATE
            AND  per.end_date >=  STE.STREAM_ELEMENT_DATE
            AND  per.adjustment_period_flag = 'N'
            AND  period_type = (SELECT gl.accounted_period_type
                                FROM gl_ledgers gl
                                WHERE ledger_id = p_ledger_id)
            ) STREAM_PERIOD
  FROM   OKL_STRM_TYPE_V STY,
         okl_streams_rep_v STM,
         OKL_STRM_ELEMENTS STE,
         OKC_K_HEADERS_ALL_B KHR,
         OKL_K_HEADERS KH,
         OKC_K_LINES_V KLE,
         OKL_PRODUCTS_V PRO,
         HR_OPERATING_UNITS OU
  WHERE  STY.ID = STM.STY_ID
    AND  STM.ID = STE.STM_ID
    AND  STM.KHR_ID = KHR.ID
--    AND  STM.ACTIVE_YN = 'Y'
    AND  KLE.ID = STM.KLE_ID
    AND  KLE.DNZ_CHR_ID = KHR.ID
    AND  KH.ID = KHR.ID
    AND  KH.PDT_ID = PRO.ID
    AND  KHR.ORG_ID = OU.ORGANIZATION_ID
    AND  STY.ID IN ( SELECT styy.id
                     FROM OKL_PROD_STRM_TYPES PSYY,
                          OKL_STRM_TYPE_V STYY
                     WHERE psyy.sty_id = sty.id
                       AND psyy.accrual_yn = 'Y'
                       and psyy.pdt_id = KH.PDT_ID
                     UNION
                     SELECT  sty_id
                     FROM  okl_report_stream_params  rsp
                     WHERE  rsp.report_id = p_report_id
                     )
    and KH.ID = p_khr_id
    AND  STM.ID IN ( SELECT MAX(ID)
                     FROM ( SELECT STM.STY_ID, STM.ID, MAX(DATE_CURRENT)
                            FROM   OKL_STRM_TYPE_V STY,
                                   okl_streams_rep_v STM,
                                   OKL_STRM_ELEMENTS STE,
                                   OKC_K_HEADERS_ALL_B KHR,
                                   OKL_K_HEADERS KH,
                                   OKC_K_LINES_V KLE,
                                   OKL_PRODUCTS_V PRO,
                                   HR_OPERATING_UNITS OU
                            WHERE  STY.ID = STM.STY_ID
                              AND  STM.ID = STE.STM_ID
                              AND  STM.KHR_ID = KHR.ID
                              AND  STM.DATE_CURRENT <= p_end_date
                              AND  NVL(STM.date_history,  p_end_date) between p_start_date  and p_end_date
                              AND  KHR.ID = p_khr_id --BIND CONTRACT IDS WHICH ARE ELIGIBLE BASED ON PRODUCTS
                              AND  KLE.ID = STM.KLE_ID
                              AND  KLE.DNZ_CHR_ID = KHR.ID
                              AND  KH.ID = KHR.ID
                              AND  KH.PDT_ID = PRO.ID
                              AND  KHR.ORG_ID = OU.ORGANIZATION_ID
                            GROUP BY STM.STY_ID, STM.ID
                            ORDER BY 3 DESC
                           )
                     GROUP BY STY_ID
                   )
  ORDER BY KHR.ID, KLE.ID, STY.ID, STE.SE_LINE_NUMBER;

  --Get all transaction lines for a particular contract
  CURSOR C_TRANSACTION_LINES
         (p_khr_id NUMBER)
  IS
  SELECT * FROM
(
  SELECT TCN.ID TCN_ID,
         TCL.ID TCL_ID,
         TCN.TRX_NUMBER,
         TCL.KHR_ID,
         TCL.STY_ID,
         STY.NAME STREAM_TYPE,
         CLE.NAME ASSET_NUMBER,
         STY.STYB_PURPOSE_MEANING STREAM_PURPOSE,
         TCL.AMOUNT,
         TCN.CURRENCY_CODE,
         TCN.ORG_ID,
         OU.NAME OPERATING_UNIT,
         TCN.PRODUCT_NAME,
         TCL.KLE_ID,
         TCN.TRANSACTION_DATE,
         NULL REVERSAL_DATE,
         ACCRUAL_ACTIVITY,
         TCN.DATE_ACCRUAL,
         TCN.DATE_TRANSACTION_OCCURRED,
         TCL.LINE_NUMBER,
         TTY.ID TRY_ID,
         TTY.NAME TRANSACTION_TYPE,
         (SELECT  per.period_name
          FROM  gl_periods per
          WHERE  per.period_set_name = (SELECT gl.period_set_name
                                        FROM gl_ledgers gl
                                        WHERE ledger_id = p_ledger_id)
            AND  per.START_DATE <= TCN.TRANSACTION_DATE
            AND  per.end_date >=  TCN.TRANSACTION_DATE
            AND  per.adjustment_period_flag = 'N'
            AND  period_type = (SELECT gl.accounted_period_type
                                FROM gl_ledgers gl
                                WHERE ledger_id = p_ledger_id)
            ) TRANSACTION_PERIOD,
         NULL REVERSAL_PERIOD
  FROM   OKL_TRX_CONTRACTS_ALL TCN,
         OKL_TXL_CNTRCT_LNS_ALL TCL,
         OKL_TRX_TYPES_V TTY,
         OKL_STRM_TYPE_V STY,
         HR_OPERATING_UNITS OU,
         OKC_K_LINES_V CLE
  WHERE  TCN.ID = TCL.TCN_ID
    AND  TCN.TRY_ID = TTY.ID
    AND  TCL.STY_ID = STY.ID
    AND  TCL.KHR_ID = p_khr_id
    AND  TCN.KHR_ID = TCL.KHR_ID
    AND  CLE.ID (+) = TCL.KLE_ID
--
    AND  TCN.SET_OF_BOOKS_ID = p_ledger_id
    AND  TTY.ID IN (SELECT TRY_ID FROM  OKL_REPORT_TRX_PARAMS where report_id = p_report_id)
    AND  TCN.ACCRUAL_ACTIVITY <> 'REVERSAL'
    AND OU.ORGANIZATION_ID = TCN.ORG_ID
    AND  NVL(TCN.SOURCE_TRX_ID,-1) NOT IN (SELECT ID
                                           FROM OKL_TRX_CONTRACTS_ALL RBK_TRX
                                           WHERE RBK_TRX.KHR_ID = TCN.KHR_ID
                                             AND  RBK_TRX.ID = TCN.SOURCE_TRX_ID
                                             AND TCN_TYPE in('TRBK','ALT'))

  UNION ALL

  SELECT TCN.ID TCN_ID,
         TCL.ID TCL_ID,
         TCN.TRX_NUMBER,
         TCL.KHR_ID,
         TCL.STY_ID,
         STY.NAME STREAM_TYPE,
         CLE.NAME ASSET_NUMBER,
         STY.STYB_PURPOSE_MEANING STREAM_PURPOSE,
         TCL.AMOUNT,
         TCN.CURRENCY_CODE,
         TCN.ORG_ID,
         OU.NAME OPERATING_UNIT,
         TCN.PRODUCT_NAME,
         TCL.KLE_ID,
         TCN.TRANSACTION_DATE,
         TCN.TRANSACTION_REVERSAL_DATE REVERSAL_DATE,
         ACCRUAL_ACTIVITY,
         TCN.DATE_ACCRUAL,
         TCN.DATE_TRANSACTION_OCCURRED,
         TCL.LINE_NUMBER,
         TTY.ID TRY_ID,
         TTY.NAME TRANSACTION_TYPE,
         (SELECT  per.period_name
          FROM  gl_periods per
          WHERE  per.period_set_name = (SELECT gl.period_set_name
                                        FROM gl_ledgers gl
                                        WHERE ledger_id = p_ledger_id)
            AND  per.START_DATE <= TCN.TRANSACTION_DATE
            AND  per.end_date >=  TCN.TRANSACTION_DATE
            AND  per.adjustment_period_flag = 'N'
            AND  period_type = (SELECT gl.accounted_period_type
                                FROM gl_ledgers gl
                                WHERE ledger_id = p_ledger_id)
            ) TRANSACTION_PERIOD,
         (SELECT  per.period_name
          FROM  gl_periods per
          WHERE  per.period_set_name = (SELECT gl.period_set_name
                                        FROM gl_ledgers gl
                                        WHERE ledger_id = p_ledger_id)
            AND  per.START_DATE <= TCN.TRANSACTION_REVERSAL_DATE
            AND  per.end_date >=  TCN.TRANSACTION_REVERSAL_DATE
            AND  per.adjustment_period_flag = 'N'
            AND  period_type = (SELECT gl.accounted_period_type
                                FROM gl_ledgers gl
                                WHERE ledger_id = p_ledger_id)
            ) REVERSAL_PERIOD
  FROM   OKL_TRX_CONTRACTS_ALL TCN,
         OKL_TXL_CNTRCT_LNS_ALL TCL,
         OKL_TRX_TYPES_V TTY,
         OKL_STRM_TYPE_V STY,
         HR_OPERATING_UNITS OU,
         OKC_K_LINES_V CLE
  WHERE  TCN.ID = TCL.TCN_ID
    AND  TCN.TRY_ID = TTY.ID
    AND  TCL.KHR_ID = p_khr_id
    AND  TCL.STY_ID = STY.ID
    AND  TCN.KHR_ID = TCL.KHR_ID
    AND  CLE.ID (+) = TCL.KLE_ID
--
    AND  TCN.SET_OF_BOOKS_ID = p_ledger_id
    AND  TTY.ID IN (SELECT TRY_ID FROM  OKL_REPORT_TRX_PARAMS where report_id = p_report_id)
    AND  TCN.ACCRUAL_ACTIVITY = 'REVERSAL'
    AND  OU.ORGANIZATION_ID = TCN.ORG_ID
    AND  NVL(TCN.SOURCE_TRX_ID,-1) NOT IN (SELECT ID
                                           FROM OKL_TRX_CONTRACTS_ALL RBK_TRX
                                           WHERE RBK_TRX.KHR_ID = TCN.KHR_ID
                                             AND  RBK_TRX.ID = TCN.SOURCE_TRX_ID
                                             AND TCN_TYPE in ('TRBK','ALT'))
  )
  ORDER BY TCN_ID, KHR_ID, KLE_ID, STY_ID, DATE_ACCRUAL, TRANSACTION_DATE, LINE_NUMBER;

  --Cursor to get adjustment transactions for all stream types
  --and specified transaction types
  CURSOR C_GET_ADJUSTMENT_TRANSACTIONS(p_product_id NUMBER)
  IS
  SELECT ou.name operating_unit,
         prod.name Product,
         khr.Contract_Number,
         kle.name Asset_Number,
         st.name stream_type,
         st.styb_purpose_meaning Stream_purpose,
         tty.NAME TRANSACTION_TYPE,
         ce.Stream_Element_Date stream_element_date,
         acc_trx.transaction_date,
         acc_trx.trx_number,
         khr.CURRENCY_CODE,
         (ce.Amount - Nvl(pe.Amount,ce.Amount)) Delta_Amt,
         DECODE(Sign(ce.Stream_Element_Date - to_date(p_start_date)),
                - 1,'N',
                DECODE(Sign(to_date(p_end_date) - ce.Stream_Element_Date),
                       - 1,'N',
                       'Y')) In_rep_Period,
         ou.organization_id org_id,
         prod.id  product_id,
         c.khr_Id khr_Id,
         c.kle_Id kle_Id,
         c.Sty_Id Sty_Id,
         ce.se_Line_Number line_number
  FROM   okl_streams_rep_v c,
         okl_streams_rep_v p,
         Okl_strm_Type_v st,
         Okl_strm_Elements ce,
         Okl_strm_Elements pe,
         Okc_k_Headers_All_b khr,
         Okc_k_lines_v kle,
         hr_operating_units ou,
         okl_products prod,
         okl_k_headers chr,
         okl_trx_contracts_all rbk_trx,
         okl_trx_contracts_all acc_trx,
         okl_rep_products_gt pdt_gt,
         OKL_TRX_TYPES_V TTY
  WHERE  c.Link_Hist_Stream_Id = p.Id
    AND  c.Sty_Id = st.Id
    AND  c.Date_Current >= p.Date_Current
    AND  c.kle_Id = p.kle_Id
    AND  ce.stm_Id = c.Id
    AND  pe.stm_Id = p.Id
    AND  ce.Stream_Element_Date = pe.Stream_Element_Date
    AND  ce.se_Line_Number = pe.se_Line_Number
    AND  c.khr_Id = khr.Id
    AND  khr.sts_Code IN ('BOOKED','TERMINATED')
    AND  Nvl(p.Date_History,p_end_date) BETWEEN p_start_date
                                            AND p_end_date
    AND  Nvl(c.Date_History,p_end_date) BETWEEN p_start_date
                                            AND p_end_date
    AND  c.Date_Current <= p_end_date
    AND  Nvl(ce.Accrued_yn,'N') = 'Y'
    AND  pe.Accrued_yn = 'Y'
    AND  kle.id = c.kle_id
    AND  kle.id = p.kle_id
    AND  khr.org_id = ou.organization_id
    AND  chr.id = khr.id
    AND  chr.pdt_id = prod.id
    AND  rbk_trx.khr_id = khr.id
    AND  rbk_trx.id = c.trx_id
    AND  rbk_trx.pdt_id = prod.id
    AND  acc_trx.source_trx_id = rbk_trx.id
    AND  acc_trx.khr_id  = rbk_trx.khr_id
    AND  acc_trx.pdt_id = rbk_trx.pdt_id
    AND  acc_trx.khr_id = khr.id
    AND  acc_trx.pdt_id = prod.id
    AND  acc_trx.source_trx_type = 'TCN'
    AND  prod.id = pdt_gt.product_id
    AND  acc_trx.SET_OF_BOOKS_ID = p_ledger_id
    AND  rbk_trx.SET_OF_BOOKS_ID = p_ledger_id
    AND  TTY.ID IN (SELECT TRY_ID FROM OKL_REPORT_TRX_PARAMS WHERE report_id = p_report_id)
    AND  TTY.ID = ACC_TRX.TRY_ID
    AND  prod.id = p_product_id
    AND  (ce.Amount - Nvl(pe.Amount,ce.Amount)) <> 0
  order by org_id,product_id,khr_id,kle_id,sty_id,line_number;

  TYPE strm_tbl_type IS TABLE OF C_MASTER_STREAMS_SPECIFIED%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE trx_tbl_type IS TABLE OF C_TRANSACTION_LINES%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE sty_id_tbl_type IS TABLE OF OKL_REPORT_TRX_PARAMS.STY_ID%TYPE INDEX BY BINARY_INTEGER;

  l_master_strm_tbl strm_tbl_type;
  l_eligible_strm_tbl strm_tbl_type;
  l_non_eligible_strm_tbl strm_tbl_type;

  l_master_trx_tbl trx_tbl_type;
  l_subset_trx_tbl trx_tbl_type;

  l_exp_streams_tbl reports_gt_tbl_type;

  l_reports_tbl reports_gt_tbl_type;
  l_non_spec_sty_id_tbl sty_id_tbl_type;
  l_spec_sty_id_tbl sty_id_tbl_type;
  l_pdt_sty_id_tbl sty_id_tbl_type;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRRPTB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Input Parameters ' ||
      ' p_report_id=' || p_report_id ||
      ' p_ledger_id=' || p_ledger_id ||
      ' p_start_date=' || p_start_date ||
      ' p_end_date=' || p_end_date ||
      ' p_org_id=' || p_org_id ||
      ' p_le_id=' ||  p_le_id );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Begin: ' || l_api_name ||'(+)' );

    -- For secondary rep txn, set the security policy for streams. MG Uptake
    IF g_representation_type = 'SECONDARY' THEN
      OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
    END IF;

    -- Start the stop watch
    l_trace_time := SYSDATE;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Starting the processing of streams to transactions and transactions to streams for income: '
      || TO_CHAR(l_trace_time, 'DD-MON-YYY HH:MM:SS') );

    l_return_status := okl_api.g_ret_sts_success;

    l_report_count := 1;

    --Check and fetch streams defined on template
    OPEN C_CHECK_STREAMS_DEFINED;
    FETCH C_CHECK_STREAMS_DEFINED BULK COLLECT INTO l_spec_sty_id_tbl;
    CLOSE C_CHECK_STREAMS_DEFINED;

    --Get the list of stream types which are not specified
    OPEN C_STREAM_TYPES_NOT_SPECIFIED;
    FETCH C_STREAM_TYPES_NOT_SPECIFIED BULK COLLECT INTO l_non_spec_sty_id_tbl;
    CLOSE C_STREAM_TYPES_NOT_SPECIFIED;

    l_no_of_streams_defined  := l_spec_sty_id_tbl.COUNT;

    --Iterate to get adjustment transanctions for each product
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Getting adjustment transactions for each product');
    FOR pdt_rec IN C_GET_PRODUCTS
    LOOP
      --If no streams are specified, then take all the accruable streams
      --defined on product
      IF l_no_of_streams_defined = 0 THEN
        l_pdt_sty_id_tbl.delete;
        OPEN C_ALL_ACCRUABLE_STREAMS(pdt_rec.product_id);
        FETCH C_ALL_ACCRUABLE_STREAMS BULK COLLECT INTO l_pdt_sty_id_tbl;
        CLOSE C_ALL_ACCRUABLE_STREAMS;
      ELSE
        l_pdt_sty_id_tbl := l_spec_sty_id_tbl;
      END IF;

      --If there are any eligible streams for getting adjustment then
      --get those otherwise skip the product
      IF l_pdt_sty_id_tbl.COUNT > 0 THEN
        FOR adj_rec IN C_GET_ADJUSTMENT_TRANSACTIONS(pdt_rec.product_id)
        LOOP
          l_is_spec_strm_type := FALSE;
          --Check whether adjustment entry is belonging to specified stream
          FOR i IN l_pdt_sty_id_tbl.FIRST..l_pdt_sty_id_tbl.LAST
          LOOP
            IF adj_rec.STY_ID = l_pdt_sty_id_tbl(i) THEN
              l_is_spec_strm_type := TRUE;
              EXIT;
            END IF;
          END LOOP;

          --If it is not belonging to specified stream,
          --Check whether adjustment entry is belonging to non specified stream
          IF NOT l_is_spec_strm_type THEN
            FOR i IN l_non_spec_sty_id_tbl.FIRST..l_non_spec_sty_id_tbl.LAST
            LOOP
              IF adj_rec.STY_ID = l_non_spec_sty_id_tbl(i) THEN
                l_is_spec_strm_type := TRUE;
                EXIT;
              END IF;
            END LOOP;
          END IF;

          --If adjustment is belonging to either specified or non-specified
          --it should be taken into consideration
          --And fill bucket TRX_SPEC_STRMS_NASE
          IF l_is_spec_strm_type THEN
            l_reports_tbl(l_report_count).value1_text := L_TRX_SPEC_STRMS_NASE;
            l_reports_tbl(l_report_count).value2_text := adj_rec.TRX_NUMBER;
            l_reports_tbl(l_report_count).value1_date := adj_rec.TRANSACTION_DATE;
            l_reports_tbl(l_report_count).value3_date := adj_rec.STREAM_ELEMENT_DATE;
            l_reports_tbl(l_report_count).value7_num := adj_rec.ORG_ID;
            l_reports_tbl(l_report_count).value8_text := adj_rec.PRODUCT;
            l_reports_tbl(l_report_count).value9_text := adj_rec.STREAM_TYPE;
            l_reports_tbl(l_report_count).value10_text := adj_rec.STREAM_PURPOSE;
            l_reports_tbl(l_report_count).value5_text := adj_rec.contract_number;
            l_reports_tbl(l_report_count).value6_text := adj_rec.asset_number;
            l_reports_tbl(l_report_count).value11_text := adj_rec.CURRENCY_CODE;
            l_reports_tbl(l_report_count).value14_text := adj_rec.OPERATING_UNIT;
            l_reports_tbl(l_report_count).value9_num := adj_rec.KHR_ID;
            l_reports_tbl(l_report_count).value10_num := adj_rec.KLE_ID;
            l_reports_tbl(l_report_count).value12_num := adj_rec.STY_ID;
            l_reports_tbl(l_report_count).value3_text := adj_rec.TRANSACTION_TYPE;
            l_reports_tbl(l_report_count).value3_num := adj_rec.DELTA_AMT;
            l_report_count := l_report_count + 1;

            --If adjustment is of non specified period then also fill bucket
            -- NON_SPEC_STRMS_NASE
            IF adj_rec.IN_REP_PERIOD = 'N' THEN
              l_reports_tbl(l_report_count) := l_reports_tbl(l_report_count - 1);
              l_reports_tbl(l_report_count).value1_text := L_NON_SPEC_STRMS_NASE;
              l_report_count := l_report_count + 1;
            END IF;
          END IF;
        END LOOP; -- adjustment transactions
      END IF;
    END LOOP; --products

    IF l_no_of_streams_defined > 0 THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Streams are defined on this template, it will consider only these');
    ELSE
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Streams are NOT defined on this template, it will consider accruable streams defined on product');
    END IF;

    --Iterate through each eligible contract, and fill respective bucket
    FOR khr_rec IN get_contracts_csr(NULL,NULL,p_ledger_id,p_start_date,p_end_date)
    LOOP
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Starting for contract: ' || khr_rec.contract_number );

      --Purge all plsql tables
      l_master_strm_tbl.delete;
      l_eligible_strm_tbl.delete;
      l_non_eligible_strm_tbl.delete;
      l_master_trx_tbl.delete;
      l_subset_trx_tbl.delete;

      --If number of streams defined is > 0, then take those into consideration
      --Else consider all accruable streams defined in the product for this
      --     particular contract
      IF l_no_of_streams_defined > 0 THEN
        OPEN C_MASTER_STREAMS_SPECIFIED(khr_rec.contract_id);
        FETCH C_MASTER_STREAMS_SPECIFIED BULK COLLECT INTO l_master_strm_tbl;
        CLOSE C_MASTER_STREAMS_SPECIFIED;
      ELSE
        OPEN C_MASTER_STREAMS_ALL(khr_rec.contract_id);
        FETCH C_MASTER_STREAMS_ALL BULK COLLECT INTO l_master_strm_tbl;
        CLOSE C_MASTER_STREAMS_ALL;

        l_spec_sty_id_tbl.delete;
        OPEN C_ALL_ACCRUABLE_STREAMS(khr_rec.pdt_id);
        FETCH C_ALL_ACCRUABLE_STREAMS BULK COLLECT INTO l_spec_sty_id_tbl;
        CLOSE C_ALL_ACCRUABLE_STREAMS;
      END IF;

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '  This Contract is having total stream elements: ' || l_master_strm_tbl.COUNT );

      l_count := 1;
      l_non_elig_count := 1;

      --
      --At this time, we got all stream elements and out of them
      --identify eligible streams falling into reporting period
      --and put those in another plsql table
      IF l_master_strm_tbl.COUNT > 0 THEN
        FOR i IN l_master_strm_tbl.FIRST..l_master_strm_tbl.LAST
        LOOP
          l_is_spec_strm_type := FALSE;
          --Check whether stream is specified or not
          IF l_spec_sty_id_tbl.COUNT > 0 THEN
            FOR j in l_spec_sty_id_tbl.FIRST..l_spec_sty_id_tbl.LAST
            LOOP
              IF l_spec_sty_id_tbl(j) = l_master_strm_tbl(i).STY_ID THEN
                l_is_spec_strm_type := TRUE;
                EXIT;
              END IF;
            END LOOP;
          END IF;

          --If it is within reporting period and specified stream
          --Then put it into eligible stream PLSQL table
          --Also create EXPECTED_STREAMS bucket
          IF l_master_strm_tbl(i).STREAM_ELEMENT_DATE BETWEEN p_start_date AND p_end_date AND
             l_is_spec_strm_type
          THEN
            l_eligible_strm_tbl(l_count):= l_master_strm_tbl(i);
            l_stream_currency_exists := FALSE;
            IF l_exp_streams_tbl.COUNT > 0 THEN
              FOR j IN l_exp_streams_tbl.FIRST..l_exp_streams_tbl.LAST
              LOOP
                IF l_exp_streams_tbl(j).value11_text = l_master_strm_tbl(i).currency_code THEN
                  l_stream_currency_exists := TRUE;
                  l_exp_streams_tbl(j).value3_num := l_exp_streams_tbl(j).value3_num + l_master_strm_tbl(i).AMOUNT;
                  EXIT;
                END IF;
              END LOOP;
            END IF;

            IF NOT l_stream_currency_exists THEN
              put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                 '  Creating expected stream amount total line for currency: ' || l_master_strm_tbl(i).currency_code);
              l_stream_amount_count := l_stream_amount_count + 1;
              l_exp_streams_tbl(l_stream_amount_count).value3_num := l_master_strm_tbl(i).AMOUNT;
              l_exp_streams_tbl(l_stream_amount_count).value11_text := l_master_strm_tbl(i).currency_code;
              l_exp_streams_tbl(l_stream_amount_count).value1_text := L_EXPECTED_STREAMS;
            END IF;

            l_count := l_count + 1;
          --If it is outside reporting period and specified stream
          --Then put it into non eligible stream PLSQL table
          ELSIF l_master_strm_tbl(i).STREAM_ELEMENT_DATE NOT BETWEEN p_start_date AND p_end_date AND
                l_is_spec_strm_type
          THEN
            l_non_eligible_strm_tbl(l_non_elig_count):= l_master_strm_tbl(i);
            l_non_elig_count := l_non_elig_count + 1;
          END IF;
        END LOOP;
      END IF;
      l_count := 1;

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '  Total specified stream elements falling in specified period: ' || l_eligible_strm_tbl.COUNT);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '  Total specified stream elements falling in non specified period: ' || l_non_eligible_strm_tbl.COUNT);

      IF l_exp_streams_tbl.COUNT > 0 THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                   '  Total expected stream activity so far: ' || l_exp_streams_tbl(l_stream_amount_count).value3_num);
      END IF;

      --Get all transactions for a contract for specified transaction types
      OPEN C_TRANSACTION_LINES(khr_rec.contract_id);
      FETCH C_TRANSACTION_LINES BULK COLLECT INTO l_master_trx_tbl;
      CLOSE C_TRANSACTION_LINES;

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '  This contract is having total transaction lines: ' || l_master_trx_tbl.COUNT);

      IF l_master_trx_tbl.COUNT = 0 THEN
        l_no_single_trx_exists := TRUE;
      ELSE
        l_no_single_trx_exists := FALSE;
      END IF;

      IF l_eligible_strm_tbl.COUNT > 0 THEN
        l_s_khr_id := -1;
        l_s_kle_id := -1;
        l_s_sty_id := -1;

        --Iterate through each eligible stream and identify respective bucket
        FOR i IN l_eligible_strm_tbl.FIRST..l_eligible_strm_tbl.LAST
        LOOP
          --If any of khr_id, kle_id and sty_id change then populate
          --subset of master trx table
          IF l_s_khr_id <> l_eligible_strm_tbl(i).KHR_ID OR
             l_s_kle_id <> l_eligible_strm_tbl(i).KLE_ID OR
             l_s_sty_id <> l_eligible_strm_tbl(i).STY_ID
          THEN
            l_s_khr_id := l_eligible_strm_tbl(i).KHR_ID;
            l_s_kle_id := l_eligible_strm_tbl(i).KLE_ID;
            l_s_sty_id := l_eligible_strm_tbl(i).STY_ID;

            --Identify transactions which relate to non-specified period streams

            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '  Identify transactions relating non-specified period streams ');
            IF l_subset_trx_tbl.COUNT > 0 AND l_non_eligible_strm_tbl.COUNT > 0 THEN
              FOR j IN l_subset_trx_tbl.FIRST..l_subset_trx_tbl.LAST
              LOOP
                --If transaction or reversal date is within reporting period then consider
                --For each accrual reversal transaction, there will be 2 transactions
                --  1) Actual Accrual (TRANSACTION_DATE)
                --  2) Accrual Reversal (TRANSACTION_REVERSAL_DATE)
                --So for each reversal transaction, we need to pull two transactions
                --and then compare actual accrual date and accrual reversal date
                --against reporting period dates
                --This logic is similar across INCOME REPORT in this procedure
                IF l_subset_trx_tbl(j).TRANSACTION_DATE BETWEEN l_start_date AND l_end_date OR
                   NVL(l_subset_trx_tbl(j).REVERSAL_DATE, l_start_date-1) BETWEEN l_start_date AND l_end_date
                THEN
                  FOR k IN l_non_eligible_strm_tbl.FIRST..l_non_eligible_strm_tbl.LAST
                  LOOP
                    IF l_subset_trx_tbl(j).LINE_NUMBER = l_non_eligible_strm_tbl(k).SE_LINE_NUMBER AND
                       l_subset_trx_tbl(j).KHR_ID = l_non_eligible_strm_tbl(k).KHR_ID AND
                       l_subset_trx_tbl(j).KLE_ID = l_non_eligible_strm_tbl(k).KLE_ID AND
                       l_subset_trx_tbl(j).STY_ID = l_non_eligible_strm_tbl(k).STY_ID
                    THEN
                      IF l_reports_tbl.exists(l_report_count) THEN
                        l_report_count := l_report_count + 1;
                      END IF;
                      l_reports_tbl(l_report_count).value1_text := L_NON_SPEC_STRMS_ASE;
                      l_reports_tbl(l_report_count).value7_num := l_non_eligible_strm_tbl(k).ORG_ID;
                      l_reports_tbl(l_report_count).value8_text := l_non_eligible_strm_tbl(k).PROD_NAME;
                      l_reports_tbl(l_report_count).value9_text := l_non_eligible_strm_tbl(k).STREAM_TYPE_NAME;
                      l_reports_tbl(l_report_count).value10_text := l_non_eligible_strm_tbl(k).STREAM_PURPOSE;
                      l_reports_tbl(l_report_count).value5_text := l_non_eligible_strm_tbl(k).CONTRACT_NUMBER;
                      l_reports_tbl(l_report_count).value6_text := l_non_eligible_strm_tbl(k).ASSET_NUMBER;
                      l_reports_tbl(l_report_count).value3_date := l_non_eligible_strm_tbl(k).STREAM_ELEMENT_DATE;
                      l_reports_tbl(l_report_count).value11_text := l_non_eligible_strm_tbl(k).CURRENCY_CODE;
                      l_reports_tbl(l_report_count).value19_text := l_non_eligible_strm_tbl(k).STREAM_PERIOD;
                      l_reports_tbl(l_report_count).value14_text := l_non_eligible_strm_tbl(k).OPERATING_UNIT;
                      l_reports_tbl(l_report_count).value9_num := l_non_eligible_strm_tbl(k).KHR_ID;
                      l_reports_tbl(l_report_count).value10_num := l_non_eligible_strm_tbl(k).KLE_ID;
                      l_reports_tbl(l_report_count).value12_num := l_non_eligible_strm_tbl(k).STY_ID;

                      l_reports_tbl(l_report_count).value3_text := l_subset_trx_tbl(j).TRANSACTION_TYPE;
                      l_reports_tbl(l_report_count).value2_text := l_subset_trx_tbl(j).TRX_NUMBER;
                      l_reports_tbl(l_report_count).value18_text := l_subset_trx_tbl(j).ACCRUAL_ACTIVITY;
                      l_reports_tbl(l_report_count).value4_date := l_subset_trx_tbl(j).DATE_ACCRUAL;
                      l_reports_tbl(l_report_count).value14_num := l_subset_trx_tbl(j).TCN_ID;

                      IF l_subset_trx_tbl(j).ACCRUAL_ACTIVITY = 'REVERSAL' AND
                         NVL(l_subset_trx_tbl(j).REVERSAL_DATE, l_start_date - 1) BETWEEN l_start_date AND l_end_date
                      THEN
                        l_reports_tbl(l_report_count).value3_num := l_non_eligible_strm_tbl(k).AMOUNT * -1;
                        l_reports_tbl(l_report_count).value1_date := l_subset_trx_tbl(j).REVERSAL_DATE;
                        l_reports_tbl(l_report_count).value12_text := l_subset_trx_tbl(j).REVERSAL_PERIOD;
                      ELSIF l_subset_trx_tbl(j).ACCRUAL_ACTIVITY <> 'REVERSAL' AND
                            l_subset_trx_tbl(j).TRANSACTION_DATE BETWEEN l_start_date AND l_end_date
                      THEN
                        l_reports_tbl(l_report_count).value3_num := l_non_eligible_strm_tbl(k).AMOUNT;
                        l_reports_tbl(l_report_count).value1_date := l_subset_trx_tbl(j).TRANSACTION_DATE;
                        l_reports_tbl(l_report_count).value12_text := l_subset_trx_tbl(j).TRANSACTION_PERIOD;
                      END IF;

                      IF l_subset_trx_tbl(j).ACCRUAL_ACTIVITY = 'REVERSAL' AND
                         l_subset_trx_tbl(j).TRANSACTION_DATE BETWEEN l_start_date AND l_end_date
                      THEN
                        l_report_count := l_report_count + 1;
                        l_reports_tbl(l_report_count) := l_reports_tbl(l_report_count-1);
                        l_reports_tbl(l_report_count).value3_num := l_non_eligible_strm_tbl(k).AMOUNT;
                        l_reports_tbl(l_report_count).value1_date := l_subset_trx_tbl(j).TRANSACTION_DATE;
                        l_reports_tbl(l_report_count).value12_text := l_subset_trx_tbl(j).TRANSACTION_PERIOD;
                        l_reports_tbl(l_report_count).value18_text := 'ACCRUAL';
                      END IF;
                      l_report_count := l_report_count + 1;
                      EXIT;
                    END IF;
                  END LOOP;
                END IF;
              END LOOP;
            END IF;

            --Delete subset of transaction table
            l_subset_trx_tbl.delete;

            l_count := 1;
            l_accrual_count := 1;
            l_reverse_count := 1;

            --Out of master transaction table which comprises of all periods,
            --Get subset of transaction lines
            --Subset of transaction lines consists of only those transaction lines
            --whose contract, asset and stream type are same.
            --Moreover, generate line number to compare further against stream element
            --line number
            IF NOT l_no_single_trx_exists THEN
              FOR j IN l_master_trx_tbl.FIRST..l_master_trx_tbl.LAST
              LOOP
                IF l_master_trx_tbl(j).KHR_ID = l_s_khr_id AND
                     l_master_trx_tbl(j).KLE_ID = l_s_kle_id AND
                     l_master_trx_tbl(j).STY_ID = l_s_sty_id
                THEN
                   l_subset_trx_tbl(l_count) := l_master_trx_tbl(j);
                   l_subset_trx_tbl(l_count).LINE_NUMBER := l_accrual_count;
                   l_accrual_count := l_accrual_count + 1;
                   l_count := l_count + 1;
                END IF;

                --From these master transaction lines, if transaction date
                --or reversal date is within reporting
                --period, then put it into respective buckets
                l_trx_exists := FALSE;
                l_trx_date := l_master_trx_tbl(j).TRANSACTION_DATE;
                IF (l_master_trx_tbl(j).TRANSACTION_DATE between l_start_date AND l_end_date) OR
                   (NVL(l_master_trx_tbl(j).REVERSAL_DATE,l_start_date - 1) between l_start_date AND l_end_date)
                THEN
                  IF l_reports_tbl.exists(l_report_count) THEN
                    l_report_count := l_report_count + 1;
                  END IF;
                  l_trx_exists := TRUE;
                END IF;

                IF l_trx_exists THEN
                  l_reports_tbl(l_report_count).value7_num := l_master_trx_tbl(j).ORG_ID;
                  l_reports_tbl(l_report_count).value8_text := l_master_trx_tbl(j).PRODUCT_NAME;
                  l_reports_tbl(l_report_count).value9_text := l_master_trx_tbl(j).STREAM_TYPE;
                  l_reports_tbl(l_report_count).value10_text := l_master_trx_tbl(j).STREAM_PURPOSE;
                  l_reports_tbl(l_report_count).value5_text := khr_rec.CONTRACT_NUMBER;
                  l_reports_tbl(l_report_count).value6_text := l_master_trx_tbl(j).ASSET_NUMBER;
                  l_reports_tbl(l_report_count).value3_num := l_master_trx_tbl(j).AMOUNT;
                  l_reports_tbl(l_report_count).value11_text := l_master_trx_tbl(j).CURRENCY_CODE;
                  l_reports_tbl(l_report_count).value14_text := l_master_trx_tbl(j).OPERATING_UNIT;
                  l_reports_tbl(l_report_count).value9_num := l_master_trx_tbl(j).KHR_ID;
                  l_reports_tbl(l_report_count).value10_num := l_master_trx_tbl(j).KLE_ID;
                  l_reports_tbl(l_report_count).value12_num := l_master_trx_tbl(j).STY_ID;

                  l_reports_tbl(l_report_count).value3_text := l_master_trx_tbl(j).TRANSACTION_TYPE;
                  l_reports_tbl(l_report_count).value2_text := l_master_trx_tbl(j).TRX_NUMBER;
                  l_reports_tbl(l_report_count).value18_text := l_master_trx_tbl(j).ACCRUAL_ACTIVITY;
                  l_reports_tbl(l_report_count).value4_date := l_master_trx_tbl(j).DATE_ACCRUAL;
                  l_reports_tbl(l_report_count).value14_num := l_master_trx_tbl(j).TCN_ID;

                  --Identify whether transaction of corresponding stream type is
                  --specified or not on the template
                  l_is_spec_strm_type := FALSE;
                  IF l_spec_sty_id_tbl.COUNT > 0 THEN
                    FOR k IN l_spec_sty_id_tbl.FIRST..l_spec_sty_id_tbl.LAST
                    LOOP
                      IF l_master_trx_tbl(j).STY_ID = l_spec_sty_id_tbl(k) THEN
                        l_is_spec_strm_type := TRUE;
                        EXIT;
                      END IF;
                    END LOOP;
                  END IF;
                  --Based on specified or not, put it in different buckets

                  IF l_master_trx_tbl(j).ACCRUAL_ACTIVITY <> 'REVERSAL' THEN
                    IF l_is_spec_strm_type THEN
                      l_reports_tbl(l_report_count).value1_text := L_TRX_SPEC_STRMS_ASE;
                    ELSE
                      l_reports_tbl(l_report_count).value1_text := L_TRX_NON_SPEC_STRMS;
                    END IF;
                    l_reports_tbl(l_report_count).value1_date := l_master_trx_tbl(j).TRANSACTION_DATE;
                  ELSE
                    IF l_master_trx_tbl(j).TRANSACTION_DATE between l_start_date AND l_end_date THEN
                      IF l_is_spec_strm_type THEN
                        l_reports_tbl(l_report_count).value1_text := L_TRX_SPEC_STRMS_ASE;
                      ELSE
                        l_reports_tbl(l_report_count).value1_text := L_TRX_NON_SPEC_STRMS;
                      END IF;
                      l_reports_tbl(l_report_count).value18_text := 'ACCRUAL';
                      l_reports_tbl(l_report_count).value1_date := l_master_trx_tbl(j).TRANSACTION_DATE;
                    ELSE
                      IF l_is_spec_strm_type THEN
                        l_reports_tbl(l_report_count).value1_text := L_TRX_ADD_ACC_EVENTS;
                      ELSE
                        l_reports_tbl(l_report_count).value1_text := L_TRX_NON_SPEC_STRMS;
                        l_reports_tbl(l_report_count).value3_num := l_master_trx_tbl(j).AMOUNT * -1;
                      END IF;
                      l_reports_tbl(l_report_count).value18_text := 'REVERSAL';
                      l_reports_tbl(l_report_count).value1_date := l_master_trx_tbl(j).REVERSAL_DATE;
                    END IF;
                    IF (l_master_trx_tbl(j).TRANSACTION_DATE between l_start_date AND l_end_date) AND
                       (NVL(l_master_trx_tbl(j).REVERSAL_DATE,l_start_date - 1) between l_start_date AND l_end_date)
                    THEN
                      l_report_count := l_report_count + 1;
                      l_reports_tbl(l_report_count) := l_reports_tbl(l_report_count - 1);
                      IF l_is_spec_strm_type THEN
                        l_reports_tbl(l_report_count).value1_text := L_TRX_ADD_ACC_EVENTS;
                      ELSE
                        l_reports_tbl(l_report_count).value1_text := L_TRX_NON_SPEC_STRMS;
                        l_reports_tbl(l_report_count).value3_num := l_master_trx_tbl(j).AMOUNT * -1;
                      END IF;
                      l_reports_tbl(l_report_count).value18_text := 'REVERSAL';
                    END IF;
                  END IF;
                  l_report_count := l_report_count + 1;
                END IF;

              END LOOP;
            END IF; --End if of l_no_single_trx_exists
          END IF; --End if of khr_id, kle_id and sty_id inequality

          --Populate transaction details for different bucket
          IF l_subset_trx_tbl.COUNT > 0 THEN --this means transaction exist
            --Search for non-reversal transactions and put it in transaction bucket
            l_trx_exists := FALSE;
            FOR j IN l_subset_trx_tbl.FIRST..l_subset_trx_tbl.LAST
            LOOP
              IF l_subset_trx_tbl(j).LINE_NUMBER = l_eligible_strm_tbl(i).SE_LINE_NUMBER
              THEN
                l_trx_date := l_subset_trx_tbl(j).TRANSACTION_DATE;
                IF l_trx_date <= l_end_date THEN
                  l_trx_exists := TRUE;
                END IF;
                EXIT;
              END IF;
            END LOOP; --End looping of l_subset_trx_tbl

            --If transaction doesn't exist, then put it into STRMS_WITHOUT_TRX bucket
            IF NOT l_trx_exists THEN
              l_reports_tbl(l_report_count).value1_text := L_STRMS_WITHOUT_TRX;
              l_reports_tbl(l_report_count).value7_num := l_eligible_strm_tbl(i).ORG_ID;
              l_reports_tbl(l_report_count).value8_text := l_eligible_strm_tbl(i).PROD_NAME;
              l_reports_tbl(l_report_count).value9_text := l_eligible_strm_tbl(i).STREAM_TYPE_NAME;
              l_reports_tbl(l_report_count).value10_text := l_eligible_strm_tbl(i).STREAM_PURPOSE;
              l_reports_tbl(l_report_count).value5_text := l_eligible_strm_tbl(i).CONTRACT_NUMBER;
              l_reports_tbl(l_report_count).value6_text := l_eligible_strm_tbl(i).ASSET_NUMBER;
              l_reports_tbl(l_report_count).value3_date := l_eligible_strm_tbl(i).STREAM_ELEMENT_DATE;
              l_reports_tbl(l_report_count).value3_num := l_eligible_strm_tbl(i).AMOUNT;
              l_reports_tbl(l_report_count).value11_text := l_eligible_strm_tbl(i).CURRENCY_CODE;
              l_reports_tbl(l_report_count).value19_text := l_eligible_strm_tbl(i).STREAM_PERIOD;
              l_reports_tbl(l_report_count).value14_text := l_eligible_strm_tbl(i).OPERATING_UNIT;
              l_reports_tbl(l_report_count).value9_num := l_eligible_strm_tbl(i).KHR_ID;
              l_reports_tbl(l_report_count).value10_num := l_eligible_strm_tbl(i).KLE_ID;
              l_reports_tbl(l_report_count).value12_num := l_eligible_strm_tbl(i).STY_ID;
              l_report_count := l_report_count + 1;
            END IF;
          ELSE --No transaction exists
            l_reports_tbl(l_report_count).value1_text := L_STRMS_WITHOUT_TRX;
            l_reports_tbl(l_report_count).value7_num := l_eligible_strm_tbl(i).ORG_ID;
            l_reports_tbl(l_report_count).value8_text := l_eligible_strm_tbl(i).PROD_NAME;
            l_reports_tbl(l_report_count).value9_text := l_eligible_strm_tbl(i).STREAM_TYPE_NAME;
            l_reports_tbl(l_report_count).value10_text := l_eligible_strm_tbl(i).STREAM_PURPOSE;
            l_reports_tbl(l_report_count).value5_text := l_eligible_strm_tbl(i).CONTRACT_NUMBER;
            l_reports_tbl(l_report_count).value6_text := l_eligible_strm_tbl(i).ASSET_NUMBER;
            l_reports_tbl(l_report_count).value3_date := l_eligible_strm_tbl(i).STREAM_ELEMENT_DATE;
            l_reports_tbl(l_report_count).value3_num := l_eligible_strm_tbl(i).AMOUNT;
            l_reports_tbl(l_report_count).value11_text := l_eligible_strm_tbl(i).CURRENCY_CODE;
            l_reports_tbl(l_report_count).value19_text := l_eligible_strm_tbl(i).STREAM_PERIOD;
            l_reports_tbl(l_report_count).value14_text := l_eligible_strm_tbl(i).OPERATING_UNIT;
            l_reports_tbl(l_report_count).value9_num := l_eligible_strm_tbl(i).KHR_ID;
            l_reports_tbl(l_report_count).value10_num := l_eligible_strm_tbl(i).KLE_ID;
            l_reports_tbl(l_report_count).value12_num := l_eligible_strm_tbl(i).STY_ID;
            l_report_count := l_report_count + 1;
          END IF; --End if of l_subset_trx_tbl.COUNT > 0
        END LOOP; -- End loop of l_eligible_strm_tbl
      END IF; --End if of l_eligible_strm_tbl

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                  '  Now identify bucket related to transactions of non specified period streams - Outside loop');
      IF l_subset_trx_tbl.COUNT > 0 AND l_non_eligible_strm_tbl.COUNT > 0 THEN
        FOR j IN l_subset_trx_tbl.FIRST..l_subset_trx_tbl.LAST
        LOOP
          IF l_subset_trx_tbl(j).TRANSACTION_DATE BETWEEN l_start_date AND l_end_date OR
             NVL(l_subset_trx_tbl(j).REVERSAL_DATE, l_start_date-1) BETWEEN l_start_date AND l_end_date
          THEN
            FOR k IN l_non_eligible_strm_tbl.FIRST..l_non_eligible_strm_tbl.LAST
            LOOP
              IF l_subset_trx_tbl(j).LINE_NUMBER = l_non_eligible_strm_tbl(k).SE_LINE_NUMBER AND
                l_subset_trx_tbl(j).KHR_ID = l_non_eligible_strm_tbl(k).KHR_ID AND
                l_subset_trx_tbl(j).KLE_ID = l_non_eligible_strm_tbl(k).KLE_ID AND
                l_subset_trx_tbl(j).STY_ID = l_non_eligible_strm_tbl(k).STY_ID
              THEN
                IF l_reports_tbl.exists(l_report_count) THEN
                  l_report_count := l_report_count + 1;
                END IF;
                l_reports_tbl(l_report_count).value1_text := L_NON_SPEC_STRMS_ASE;
                l_reports_tbl(l_report_count).value7_num := l_non_eligible_strm_tbl(k).ORG_ID;
                l_reports_tbl(l_report_count).value8_text := l_non_eligible_strm_tbl(k).PROD_NAME;
                l_reports_tbl(l_report_count).value9_text := l_non_eligible_strm_tbl(k).STREAM_TYPE_NAME;
                l_reports_tbl(l_report_count).value10_text := l_non_eligible_strm_tbl(k).STREAM_PURPOSE;
                l_reports_tbl(l_report_count).value5_text := l_non_eligible_strm_tbl(k).CONTRACT_NUMBER;
                l_reports_tbl(l_report_count).value6_text := l_non_eligible_strm_tbl(k).ASSET_NUMBER;
                l_reports_tbl(l_report_count).value3_date := l_non_eligible_strm_tbl(k).STREAM_ELEMENT_DATE;
                l_reports_tbl(l_report_count).value11_text := l_non_eligible_strm_tbl(k).CURRENCY_CODE;
                l_reports_tbl(l_report_count).value19_text := l_non_eligible_strm_tbl(k).STREAM_PERIOD;
                l_reports_tbl(l_report_count).value14_text := l_non_eligible_strm_tbl(k).OPERATING_UNIT;
                l_reports_tbl(l_report_count).value9_num := l_non_eligible_strm_tbl(k).KHR_ID;
                l_reports_tbl(l_report_count).value10_num := l_non_eligible_strm_tbl(k).KLE_ID;
                l_reports_tbl(l_report_count).value12_num := l_non_eligible_strm_tbl(k).STY_ID;

                l_reports_tbl(l_report_count).value3_text := l_subset_trx_tbl(j).TRANSACTION_TYPE;
                l_reports_tbl(l_report_count).value2_text := l_subset_trx_tbl(j).TRX_NUMBER;
                l_reports_tbl(l_report_count).value18_text := l_subset_trx_tbl(j).ACCRUAL_ACTIVITY;
                l_reports_tbl(l_report_count).value4_date := l_subset_trx_tbl(j).DATE_ACCRUAL;
                l_reports_tbl(l_report_count).value14_num := l_subset_trx_tbl(j).TCN_ID;

                IF l_subset_trx_tbl(j).ACCRUAL_ACTIVITY = 'REVERSAL' AND
                   NVL(l_subset_trx_tbl(j).REVERSAL_DATE, l_start_date-1) BETWEEN l_start_date AND l_end_date
                THEN
                  l_reports_tbl(l_report_count).value3_num := l_non_eligible_strm_tbl(k).AMOUNT * -1;
                  l_reports_tbl(l_report_count).value1_date := l_subset_trx_tbl(j).REVERSAL_DATE;
                  l_reports_tbl(l_report_count).value12_text := l_subset_trx_tbl(j).REVERSAL_PERIOD;
                ELSIF l_subset_trx_tbl(j).ACCRUAL_ACTIVITY <> 'REVERSAL' AND
                      l_subset_trx_tbl(j).TRANSACTION_DATE BETWEEN l_start_date AND l_end_date
                THEN
                  l_reports_tbl(l_report_count).value3_num := l_non_eligible_strm_tbl(k).AMOUNT;
                  l_reports_tbl(l_report_count).value1_date := l_subset_trx_tbl(j).TRANSACTION_DATE;
                  l_reports_tbl(l_report_count).value12_text := l_subset_trx_tbl(j).TRANSACTION_PERIOD;
                END IF;

                IF l_subset_trx_tbl(j).ACCRUAL_ACTIVITY = 'REVERSAL' AND
                   l_subset_trx_tbl(j).TRANSACTION_DATE BETWEEN l_start_date AND l_end_date AND
                   NVL(l_subset_trx_tbl(j).REVERSAL_DATE, l_start_date-1) BETWEEN l_start_date AND l_end_date
                THEN
                  l_report_count := l_report_count + 1;
                  l_reports_tbl(l_report_count) := l_reports_tbl(l_report_count-1);
                  l_reports_tbl(l_report_count).value3_num := l_non_eligible_strm_tbl(k).AMOUNT;
                  l_reports_tbl(l_report_count).value1_date := l_subset_trx_tbl(j).TRANSACTION_DATE;
                  l_reports_tbl(l_report_count).value12_text := l_subset_trx_tbl(j).TRANSACTION_PERIOD;
                  l_reports_tbl(l_report_count).value18_text := 'ACCRUAL';
                END IF;
                l_report_count := l_report_count + 1;
                EXIT;
              END IF;
            END LOOP;
          END IF;
        END LOOP;
      END IF;

    END LOOP; --End loop of get_contracts_csr

    -- For secondary rep txn, reset the security policy for streams. MG Uptake
    IF g_representation_type = 'SECONDARY' THEN
      OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
    END IF;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '  Inserting records in okl_g_reports_gt table for expected sum of stream elements amount');

    FORALL i IN l_exp_streams_tbl.FIRST..l_exp_streams_tbl.LAST
      INSERT INTO okl_g_reports_gt VALUES l_exp_streams_tbl(i);

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '  Inserting all records into okl_g_reports_gt');

    --At this point of time we will have details of all buckets, so just bulk insert into GT table
    FORALL i IN l_reports_tbl.FIRST..l_reports_tbl.LAST
      INSERT INTO okl_g_reports_gt VALUES l_reports_tbl(i);

    --Now whatever allotted in NON_SPEC_STRMS_ASE bucket,
    --we want to populate same in NON_SPEC_PERIOD_TRX_SPEC_PERIOD bucket
    --if it was accounted and posted
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                '   Populating NON_SPEC_PERIOD_TRX_SPEC_PERIOD bucket based on NON_SPEC_STRMS_ASE bucket');
    INSERT INTO okl_g_reports_gt
      (  value1_text --Bucket name
        ,value2_text --trx number
        ,value3_text --trx_type name
        ,value4_text  --application name
        ,value5_text --contract number
        ,value6_text --asset number
        ,value7_text --book classification
        ,value8_text --product name
        ,value9_text --trx sty name
        ,value10_text --trx_sty_purpose
        ,value11_text --currency code
        ,value12_text --trx period name
        ,value13_text --trx account name
        ,value14_text --trx operating unit
        ,value15_text --legal entity name
        ,value16_text --trx ledger name
        ,value17_text --add subtract activity
        ,value18_text --trx event name
        -- Number Formatted Columns
        ,value1_num --trx dr amt
        ,value2_num --trx cr amt
        ,value3_num --trx net amt
        ,value4_num --code combination id
        ,value5_num --code combination id
        ,value6_num --trx ledger id
        ,value7_num --Org ID
        ,value8_num --TRY ID
        ,value9_num --KHR ID
        ,value10_num --asset Id
        ,value11_num --pdt id
        ,value12_num --sty id
        ,value13_num --application id
        ,value15_num --xla event id
        -- Date Formatted Columns
        ,value1_date --trx date
        ,value2_date --gl date
        ,value4_date --accrual date
      )

    SELECT   gl_detail_type_code         --value1_text
            ,trx_number                  --value2_text
            ,trx_type_name               --value3_text
            ,trx_application_name        --value4_text
            ,contract_number             --value5_text
            ,asset_number                --value6_text
            ,book_classification         --value7_text
            ,product_name                --value8_text
            ,trx_sty_name                --value9_text
            ,trx_sty_purpose             --value10_text
            ,currency_code               --value11_text
            ,trx_period_name             --value12_text -- Populated Only for Posted Entries
            ,trx_account_name            --value13_text
            ,trx_operating_unit_name     --value14_text
            ,NULL                        --value15_text -- Legal Entity Name
            ,trx_ledger_name             --value16_text
            ,trx_activity_code           --value17_text  -- Activity Code Add/Subtract for Dr/Cr
            ,trx_event_name              --value18_text
            -- Number Formatted Columns
            ,trx_dr_amount               --value1_num
            ,trx_cr_amount               --value2_num
            ,trx_net_amount              --value3_num
            ,code_combination_id         --value4_num
            ,code_combination_id         --value5_num
            ,trx_ledger_id               --value6_num
            ,trx_operating_unit_id       --value7_num
            ,trx_try_id                  --value8_num -- Transaction Type ID
            ,trx_khr_id                  --value9_num
            ,txl_asset_id                --value10_num
            ,trx_pdt_id                  --value11_num
            ,trx_sty_id                  --value12_num
            ,trx_application_id          --value13_num
            ,trx_xla_event_id            --value15_num
            -- Date Formatted Columns
            ,trx_date                    --value1_date
            ,gl_date                     --value2_date
            ,accrual_date                --value4_date
        FROM
        (
          SELECT 'NON_SPEC_PERIOD_TRX_SPEC_PERIOD'        gl_detail_type_code
                ,gh.currency_code                         currency_code
                ,app.application_name                     trx_application_name
                ,glcc.concatenated_segments               trx_account_name
                ,xvl.name                                 trx_event_name
                ,try.name                                 trx_type_name
                ,sty.NAME                                 trx_sty_name
                ,trx.trx_number                           trx_number
                ,chr.contract_number                      contract_number
                ,KLE.NAME                                     asset_number
                ,gts.deal_type                            book_classification
                ,pdt.NAME                                 product_name
                ,sty.styb_purpose_meaning                 trx_sty_purpose
                ,ou.name                                  trx_operating_unit_name
                ,ledger.name                              trx_ledger_name
                ,gh.period_name                           trx_period_name
                ,xl.code_combination_id                   code_combination_id
                -- Number Format Columns
                ,xl.entered_dr                            trx_dr_amount
                ,xl.entered_cr                            trx_cr_amount
                ,( NVL(xl.entered_dr,0) - NVL(xl.entered_cr,0) )
                                                          trx_net_amount
                ,DECODE( xl.entered_dr, NULL, 'SUBTRACT', 'ADD' )
                                                          trx_activity_code
                ,xl.ledger_id                             trx_ledger_id
                ,trx.org_id                               trx_operating_unit_id
                ,trx.khr_id                               trx_khr_id
                ,txl.kle_id                               txl_asset_id
                ,khr.pdt_id                               trx_pdt_id
                ,txl.sty_id                               trx_sty_id
                ,xl.application_id                        trx_application_id
                ,xe.event_id                              trx_xla_event_id
                -- DATE Format Columns
                ,trx.transaction_date                     trx_date
                ,dist.gl_date                             gl_date
                ,trx.date_accrual                         accrual_date
                -- Additional Columns
                ,trx.id                                   trx_id
                ,txl.id                                   trx_txl_id
                ,trx.try_id                               trx_try_id
                ,dist.id                                  trx_dist_id
          FROM    -- GL Tables: Import Reference, GL Header and Lines
                gl_je_lines               gl
               ,gl_je_headers             gh
               ,gl_code_combinations_kfv  glcc
               ,gl_import_references      gi
               -- Code Combination GT Table
               ,okl_code_cmbns_gt         cc
               -- SLA Entities
               ,xla_ae_lines              xl
               ,xla_ae_headers            xh
               ,xla_distribution_links    xd
               ,xla_events                xe
               ,xla_event_types_vl        xvl
              -- OLM Entities
               ,okl_trns_acc_dstrs_all    dist
               ,okl_txl_cntrct_lns_all    txl
               ,okl_trx_contracts_all     trx
               ,okl_trx_types_v           try
               ,okl_strm_type_v           sty
               ,okc_k_headers_all_b       chr
               ,okl_k_headers             khr
               ,okl_products              pdt
               ,okl_ae_tmpt_sets_all      aes
               ,okl_st_gen_tmpt_sets_all  gts
               -- To fetch Names
               ,hr_operating_units        ou
               ,gl_ledgers                ledger
               ,fnd_application_vl        app
               ,okc_k_lines_v        kle
               ,okl_report_trx_params trep
          WHERE
                 -- Restrict the Code Combinations to the one setup on the Report
                 gl.code_combination_id = cc.ccid AND
                 -- GL Tables
                 gl.ledger_id        = p_ledger_id
            AND  gh.je_header_id     = gl.je_header_id
            AND  gh.ledger_id        = gl.ledger_id
            AND  gh.je_source        = 'Lease'
            AND  gh.status           =  'P'  -- Pick Only Posted Journals
            AND  glcc.code_combination_id = gl.code_combination_id
            AND  gi.je_header_id     = gh.je_header_id
            AND  gi.je_line_num      = gl.je_line_num
                 -- GL to XLA Relations
            AND  xl.gl_sl_link_id    = gi.gl_sl_link_id
            AND  xl.gl_sl_link_table = gi.gl_sl_link_table
            AND  xl.ledger_id        = gl.ledger_id
                 -- XLA Predicates
            AND  xl.ae_header_id     = xh.ae_header_id
            AND  xd.application_id   = 540  -- Restrict to Lease Journals
            AND  xd.ae_header_id     = xh.ae_header_id
            AND  xd.ae_line_num      = xl.ae_line_num
            AND  xe.event_id         = xd.event_id
            AND  xe.application_id   = xvl.application_id
            AND  xvl.event_type_code = xe.event_type_code
                 -- XLA to OLM Predicates
            AND  xd.event_id         = dist.accounting_event_id
            AND  dist.id             = xd.source_distribution_id_num_1
            AND  dist.posted_yn      = 'Y'
                 -- OLM Predicates
            AND  dist.source_table   = 'OKL_TXL_CNTRCT_LNS'
            AND  dist.source_id      = txl.id
            AND  trx.id              = txl.tcn_id
            AND  trx.try_id          = try.id
            AND  txl.sty_id          = sty.id
            AND  trx.khr_id          = chr.id
            AND  chr.id              = khr.id
            AND  khr.pdt_id          = pdt.id
            AND  pdt.aes_id          = aes.id
            AND  aes.gts_id          = gts.id
            -- Predicates to fetch the Names
            AND  ou.organization_id  = trx.org_id
            AND  ledger.ledger_id    = trx.set_of_books_id
            AND  app.application_id  = xe.application_id
	    AND  kle.id = txl.kle_id
            -- Restrict the Journal Entries to be in between Start and End Dates
            AND  dist.gl_date between p_start_date AND p_end_date
            AND  trx.transaction_date not between p_start_date AND p_end_date
            AND  trep.try_id = trx.try_id  -- trx_try_id
            AND  NVL( trep.sty_id, txl.sty_id) = txl.sty_id -- Stream Type Id
            AND  DECODE( xl.entered_dr, NULL, 'SUBTRACT', 'ADD' ) = trep.add_substract_code -- Debit/Credit or Add/Subtract
            AND  trep.report_id = p_report_id
        );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Completed the processing of streams to transactions and transactions to streams for income:'
      || TO_CHAR(SYSDATE, 'DD-MON-YYY HH:MM:SS') );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Time taken for Income Report Processing (STRMS <-> TRANSACTIONS): '
       || ( SYSDATE - l_trace_time ) * 86400 || ' Seconds' );

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'End: ' || l_api_name ||'(-)' );
    -- Set the Return Status and return back
    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_CHECK_STREAMS_DEFINED%ISOPEN THEN
        CLOSE C_CHECK_STREAMS_DEFINED;
      END IF;
      IF C_ALL_ACCRUABLE_STREAMS%ISOPEN THEN
        CLOSE C_ALL_ACCRUABLE_STREAMS;
      END IF;
      IF C_STREAM_TYPES_NOT_SPECIFIED%ISOPEN THEN
        CLOSE C_STREAM_TYPES_NOT_SPECIFIED;
      END IF;
      IF C_GET_PRODUCTS%ISOPEN THEN
        CLOSE C_GET_PRODUCTS;
      END IF;
      IF C_MASTER_STREAMS_SPECIFIED%ISOPEN THEN
        CLOSE C_MASTER_STREAMS_SPECIFIED;
      END IF;
      IF C_MASTER_STREAMS_ALL%ISOPEN THEN
        CLOSE C_MASTER_STREAMS_ALL;
      END IF;
      IF C_TRANSACTION_LINES%ISOPEN THEN
        CLOSE C_TRANSACTION_LINES;
      END IF;
      IF C_GET_ADJUSTMENT_TRANSACTIONS%ISOPEN THEN
        CLOSE C_GET_ADJUSTMENT_TRANSACTIONS;
      END IF;
      IF GET_CONTRACTS_CSR%ISOPEN THEN
        CLOSE GET_CONTRACTS_CSR;
      END IF;
      -- If any exception was thrwon before resetting reporting streams, then do that
      IF g_representation_type = 'SECONDARY' THEN
        OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
      END IF;

      x_return_status := okl_api.g_ret_sts_error;
END POPULATE_STRM_TO_TRX_DATA;

  -- Start of comments
  --
  -- Function Name   :  generate_gross_inv_recon_rpt.
  -- Description    : Main Function called by CP
  --
  -- Business Rules  :
  -- Parameters       :
  -- Version      : 1.0
  -- History        : Ravindranath Gooty created.
  --
  -- End of comments
  FUNCTION generate_gross_inv_recon_rpt
  RETURN BOOLEAN IS
    -- Cursor to fetch teh Operating Unit
    CURSOR get_param_num_value( p_report_id NUMBER , p_parameter_type_code VARCHAR2)
    IS
      SELECT  param_num_value1
        FROM  okl_report_parameters oup
       WHERE  oup.report_id = p_report_id
         AND  oup.parameter_type_code = p_parameter_type_code ;

    -- Cursor to fetch GL Period From Date
    CURSOR get_period_from_date IS
      SELECT gl.start_date from_date
      FROM   gl_period_statuses    gl
      WHERE  gl.application_id = 540
      AND    gl.set_of_books_id = p_ledger_id
      AND    gl.period_name = p_gl_period_from;

    -- Cursor to fetch GL Period To Date
    CURSOR get_period_to_date IS
      SELECT gl.end_date to_date
      FROM   gl_period_statuses    gl
      WHERE  gl.application_id = 540
      AND    gl.set_of_books_id = p_ledger_id
      AND    gl.period_name = p_gl_period_to;

    --Cursor to fetch representation type of ledger
    CURSOR C_GET_LEGER_REPRENSENTATION(p_ledger_id NUMBER) IS
      SELECT NVL(LEDGER_CATEGORY_CODE,'PRIMARY') LEDGER_CATEGORY_CODE
      FROM   GL_LEDGERS
      WHERE  LEDGER_ID = p_ledger_id;

    l_init_msg_list VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_start_date    DATE;
    l_end_date      DATE;

    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'generate_gross_inv_recon_rpt';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Debug related parameters
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -- Local Variable declaration
    l_org_id              NUMBER;
    l_le_id               NUMBER;
    l_proceed_flag        BOOLEAN := TRUE;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRRPTB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_REPORT_GENERATOR_PVT.generate_gross_inv_recon_rpt');
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Start of the Main Logic');
    l_init_msg_list := OKL_API.G_FALSE;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    --Get representation type of the ledger
    OPEN C_GET_LEGER_REPRENSENTATION(p_ledger_id);
    FETCH C_GET_LEGER_REPRENSENTATION INTO g_representation_type;
    CLOSE C_GET_LEGER_REPRENSENTATION;

    -- First up, validate whether user has access to run the Report Or not
    l_proceed_flag :=  validate_orgs_access( p_ledger_id => p_ledger_id );

    IF l_proceed_flag = FALSE
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Validation Failed !!! Erroring Out !!!!');
      INSERT INTO OKL_G_REPORTS_GT ( VALUE1_TEXT )
        VALUES ('OKL_RECON_REP_NO_ACCESS' );
      RETURN TRUE; -- Always return TRUE
    END IF;
    -- Fetch the Operating Unit
    FOR t_rec IN get_param_num_value(
                  p_report_id => p_report_id
                 ,p_parameter_type_code => 'OPERATING_UNIT')
    LOOP
      l_org_id := t_rec.param_num_value1;
    END LOOP;
    -- Fetch the Legal Entity Setup on the Report Definition
    FOR t_rec IN get_param_num_value(
                  p_report_id => p_report_id
                 ,p_parameter_type_code => 'LEGAL_ENTITY')
    LOOP
      l_le_id := t_rec.param_num_value1;
    END LOOP;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before calling populate_code_combinations: p_report_id=' || p_report_id
      || 'p_ledger_id= ' || p_ledger_id );
    populate_code_combinations(
       p_api_version    => l_api_version
      ,p_init_msg_list  => l_init_msg_list
      ,x_return_status  => l_return_status
      ,x_msg_count      => l_msg_count
      ,x_msg_data       => l_msg_data
      ,p_report_id      => p_report_id
      ,p_ledger_id      => p_ledger_id);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After call to the populate_code_combinations ' || l_return_status );
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before calling populate_products: p_report_id=' || p_report_id
      || 'l_org_id= ' || l_org_id );
    populate_products(
       p_api_version    => l_api_version
      ,p_init_msg_list  => l_init_msg_list
      ,x_return_status  => l_return_status
      ,x_msg_count      => l_msg_count
      ,x_msg_data       => l_msg_data
      ,p_report_id      => p_report_id
      ,p_org_id         => l_org_id );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After call to the populate_products ' || l_return_status );
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Retreive the GL period from and period to dates.
    OPEN get_period_from_date;
    FETCH get_period_from_date
      INTO l_start_date;
    IF get_period_from_date%NOTFOUND
    THEN
      RAISE okl_api.g_exception_error;
    END IF;
    CLOSE get_period_from_date;

    OPEN get_period_to_date;
    FETCH get_period_to_date
      INTO l_end_date;
    IF get_period_to_date%NOTFOUND
    THEN
      RAISE okl_api.g_exception_error;
    END IF;
    CLOSE get_period_to_date;

    ---------------------------------------------------------------------------
    -- Invoking the API to Populate Transaction Details Originated from
    --  OLM, AR, AP Applications on behalf of a Lease Contract
    -- Transaction may be at any stage of its life, Un Accounted, Accounted,
    --   Not Imported in GL, Imported in GL, Not Posted in GL, Posted in GL
    ---------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before call to the populate_trx_data ' );
    populate_trx_data(
       p_api_version   => l_api_version
      ,p_init_msg_list => l_init_msg_list
      ,x_return_status => l_return_status
      ,x_msg_count     => l_msg_count
      ,x_msg_data      => l_msg_data
      ,p_report_id     => p_report_id
      ,p_ledger_id     => p_ledger_id
      ,p_start_date    => l_start_date
      ,p_end_date      => l_end_date
      ,p_org_id        => l_org_id
      ,p_le_id         => l_le_id);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After call to the populate_trx_data ' || l_return_status );
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    ------------------------------------------------------------
    -- Call the API to Calculate the Stream Balances
    ------------------------------------------------------------

    IF p_report_type_code <> 'INCOME' THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Before call to the  process_strm_bal_details' );
      process_strm_bal_details(
         p_api_version     => l_api_version
        ,p_init_msg_list   => l_init_msg_list
        ,x_return_status   => l_return_status
        ,x_msg_count       => l_msg_count
        ,x_msg_data        => l_msg_data
        ,p_report_id       => p_report_id
        ,p_start_date      => l_start_date
        ,p_end_date        => l_end_date
        ,p_ledger_id       => p_ledger_id
        ,p_org_id          => l_org_id
        ,p_le_id           => l_le_id);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After call to the process_strm_bal_details ' || l_return_status );
      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;

    ------------------------------------------------------------
    -- Call the API to Populate the GL Journal Details
    --  for Accounting Drill downs and Comparision
    ------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before call to the  populate_acc_data' );
    populate_acc_data(
       p_api_version     => l_api_version
      ,p_init_msg_list   => l_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => l_msg_count
      ,x_msg_data        => l_msg_data
      ,p_report_id       => p_report_id
      ,p_start_date      => l_start_date
      ,p_end_date        => l_end_date
      ,p_ledger_id       => p_ledger_id
      ,p_org_id          => l_org_id
      ,p_le_id           => l_le_id);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After call to the populate_acc_data ' || l_return_status );
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    ---------------------------------------------------------------------------
    -- Invoking the API to Populate the GL Opening Balances as on Period From
    --   and GL Closing Balances as on Period To both in Transaction and
    --   Functional Currency
    ---------------------------------------------------------------------------
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before call to the populate_gl_balances ' );
    populate_gl_balances(
       p_api_version   => l_api_version
      ,p_init_msg_list => l_init_msg_list
      ,x_return_status => l_return_status
      ,x_msg_count     => l_msg_count
      ,x_msg_data      => l_msg_data
      ,p_ledger_id     => p_ledger_id
      ,p_period_from   => p_gl_period_from
      ,p_period_to     => p_gl_period_to );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After call to the populate_gl_balances ' || l_return_status );
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    ------------------------------------------------------------
    -- If report type is INCOME then call the API to reconcile
    -- between streams to transactions
    ------------------------------------------------------------
    IF p_report_type_code = 'INCOME' THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Before call to the  POPULATE_STRM_TO_TRX_DATA' );
      POPULATE_STRM_TO_TRX_DATA(
         p_api_version     => l_api_version
        ,p_init_msg_list   => l_init_msg_list
        ,x_return_status   => l_return_status
        ,x_msg_count       => l_msg_count
        ,x_msg_data        => l_msg_data
        ,p_report_id       => p_report_id
        ,p_ledger_id       => p_ledger_id
        ,p_start_date      => l_start_date
        ,p_end_date        => l_end_date
        ,p_org_id          => l_org_id
        ,p_le_id           => l_le_id);
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After call to the POPULATE_STRM_TO_TRX_DATA ' || l_return_status );
      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;


    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
          'End API OKL_REPORT_GENERATOR_PVT.generate_gross_inv_recon_rpt');
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS
    THEN
      l_return_status := okl_api.g_ret_sts_unexp_error;
      -- Set the oracle error message
      okl_api.set_message(p_app_name     => okc_api.g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      RETURN FALSE;

  END generate_gross_inv_recon_rpt;

END OKL_REPORT_GENERATOR_PVT;

/
