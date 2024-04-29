--------------------------------------------------------
--  DDL for Package Body FII_RECONVERSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_RECONVERSION_PKG" AS
/* $Header: FIICRECB.pls 120.2 2005/10/14 18:21:44 lpoon noship $ */

 g_page_line_no  NUMBER := 65;
 INVALID_SETUP  EXCEPTION;
 RECONV_ERROR   EXCEPTION;
 MISSING_RATE   EXCEPTION;

-- PROCEDURE
--   reconvert_amounts()
--
-- DESCRIPTION:
--   This is the main function of this currency reconversion package. It will
--   initialize the variables and validate the passed in parameters from the
--   concurrent manager. Then, it will call other procdures to cache rates,
--   reconvert global amounts for different products and print execution report.
PROCEDURE reconvert_amounts(  errbuf                IN OUT NOCOPY VARCHAR2
                            , retcode               IN OUT NOCOPY VARCHAR2
                            , p_currency_type       IN            VARCHAR2
                            , p_primary_rate_type   IN            VARCHAR2
                            , p_secondary_rate_type IN            VARCHAR2
                            , p_from_date           IN            VARCHAR2
                            , p_to_date             IN            VARCHAR2
                            , p_transaction_type    IN            VARCHAR2
                            , p_log_filename        IN            VARCHAR2
                            , p_output_filename     IN            VARCHAR2
                           ) IS
  l_user_id            NUMBER := NULL;
  l_conc_req_id        NUMBER := NULL;
  l_installed_flag     VARCHAR2(1) := 'N';
  l_reconv_gl_flag     VARCHAR2(1) := 'N';
  l_reconv_ap_flag     VARCHAR2(1) := 'N';
  l_reconv_ar_flag     VARCHAR2(1) := 'N';
  l_gl_name            VARCHAR2(240);
  l_ap_name            VARCHAR2(240);
  l_ar_name            VARCHAR2(240);

  l_primaryText        VARCHAR2(30);
  l_primary_currency   VARCHAR2(15) := NULL;
  l_primary_mau        NUMBER := NULL;
  l_secondaryText      VARCHAR2(30);
  l_secondary_currency VARCHAR2(15) := NULL;
  l_secondary_mau      NUMBER := NULL;

  l_from_date          DATE := NULL;
  l_to_date            DATE := NULL;
  l_from_date_id       NUMBER := NULL;
  l_to_date_id         NUMBER := NULL;

  l_caching_status     VARCHAR2(1) := 'N';

  TYPE CHILD_REQ_REC_TYPE IS RECORD (request_id     NUMBER,
                                     application_id NUMBER,
                                     status         VARCHAR2(80),
                                     phase          VARCHAR2(80),
                                     dev_status     VARCHAR2(50),
                                     dev_phase      VARCHAR2(50),
                                     completion_msg VARCHAR2(300));
  TYPE CHILD_REQ_TBL_TYPE IS TABLE OF CHILD_REQ_REC_TYPE;
  l_req_list           CHILD_REQ_TBL_TYPE := CHILD_REQ_TBL_TYPE();
  l_launched_ct        NUMBER := 0;
  l_running_ct         NUMBER := 0;
  i                    INTEGER;

  l_completion_status  VARCHAR2(1) := 'S';
  l_return_val         BOOLEAN := FALSE;

  l_err_msg            VARCHAR2(500) := NULL;
  l_process_step       VARCHAR2(50) := 'INIT_LOG_UTIL';
  l_procedure_name     VARCHAR2(30) := 'reconvert_amounts';
BEGIN
  -- ================
  -- 1 Initialization
  -- ================

  --
  -- 1.1 Initialize the logging
  --
  FII_UTIL.initialize(p_log_filename || '.log',
                      p_output_filename || '.out',
                      NULL, 'FII_RECONVERSION_PKG');
  -- LOG: Function enter
  FII_RECONVERSION_PKG.func_enter(l_procedure_name);

  -- LOG: List all passed parameters
  l_process_step := 'LOG_LIST_PARAMS';
  FII_UTIL.put_line(' ');
  FII_UTIL.put_line(FND_MESSAGE.get_string('FND', 'CONC-PARAMETERS') || ':');
  FII_UTIL.put_line(FII_MESSAGE.get_message(
                       'FII_RECONV_TRX_TYPE_PARAM_P', NULL
                     , 'P_VALUE', p_transaction_type));
  FII_UTIL.put_line(FII_MESSAGE.get_message(
                       'FII_RECONV_CURR_TYPE_PARAM_P', NULL
                     , 'P_VALUE', p_currency_type));
  FII_UTIL.put_line(FII_MESSAGE.get_message(
                       'FII_RECONV_PRI_RTYPE_PARAM_P', NULL
                     , 'P_VALUE', p_primary_rate_type));
  FII_UTIL.put_line(FII_MESSAGE.get_message(
                       'FII_RECONV_SEC_RTYPE_PARAM_P', NULL
                     , 'P_VALUE', p_secondary_rate_type));
  FII_UTIL.put_line(FII_MESSAGE.get_message(
                       'FII_RECONV_FROM_DATE_PARAM_P', NULL
                     , 'P_VALUE', p_from_date));
  FII_UTIL.put_line(FII_MESSAGE.get_message(
                       'FII_RECONV_TO_DATE_PARAM_P', NULL
                     , 'P_VALUE', p_to_date));

  -- LOG: FII_RECONV_INIT_STEP || time stamp
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message('FII_RECONV_INIT_STEP', NULL));
  -- LOG: State debug mode is on if it does
  FII_UTIL.debug_line('This process is running in debug mode');

  --
  -- 1.2 Initialize the variables and validate the parameters
  --

  -- Set l_conc_req_id
  l_process_step := 'GET_CONC_REQ_ID';
  l_conc_req_id := FND_GLOBAL.conc_request_id;
  FII_UTIL.debug_line('Variables:');
  FII_UTIL.debug_line('  l_conc_req_id        = ' || l_conc_req_id);
  l_user_id := FND_GLOBAL.user_id;
  FII_UTIL.debug_line('  l_user_id            = ' || l_user_id);

  -- Set l_reconv_gl_flag based on p_transaction_type
  l_process_step := 'CHECK_RECONV_GL';
  IF (p_transaction_type = 'GL' OR p_transaction_type = 'ALL')
  THEN
    -- Check if GL is installed
    BEGIN
      SELECT 'Y'
      INTO l_installed_flag
      FROM FND_PRODUCT_INSTALLATIONS
      WHERE application_id = 101;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_installed_flag := 'N';
    END;

    -- Get GL application name
    BEGIN
      SELECT application_name
      INTO l_gl_name
      FROM FND_APPLICATION_TL
      WHERE application_id = 101;
    EXCEPTION
      WHEN OTHERS THEN
        l_gl_name := 'Oracle General Ledger';
    END;
    FII_UTIL.debug_line('  l_gl_name            = ' || l_gl_name);

    -- Set l_reconv_gl_flag
    IF (l_installed_flag = 'Y')
    THEN
      l_reconv_gl_flag := 'Y';

    ELSE
      l_reconv_gl_flag := 'N';

      IF (p_transaction_type = 'GL')
      THEN
        -- Only GL is selected for reconversion but it's not installed
        --   => Get error message and raise INVALID_SETUP exception
        l_err_msg := FII_MESSAGE.get_message(
                        'FII_RECONV_PROD_NOT_INSTALLED', NULL
                      , 'PROD_NAME', l_gl_name);
        RAISE INVALID_SETUP;
      END IF; -- IF (p_transaction_type = 'GL')

    END IF; -- IF (l_installed_flag = 'Y')
  END IF; -- IF (p_transaction_type = 'GL' OR p_transaction_type = 'ALL')
  FII_UTIL.debug_line('  l_reconv_gl_flag     = ' || l_reconv_gl_flag);

  -- Set l_reconv_ap_flag based on p_transaction_type
  l_process_step := 'CHECK_RECONV_AP';
  IF (p_transaction_type = 'AP' OR p_transaction_type = 'ALL')
  THEN
    -- Check if AP is installed
    BEGIN
      SELECT 'Y' INTO l_installed_flag
      FROM FND_PRODUCT_INSTALLATIONS
      WHERE application_id = 200;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_installed_flag := 'N';
    END;

    -- Get AP application name
    BEGIN
      SELECT application_name INTO l_ap_name
      FROM FND_APPLICATION_TL
      WHERE application_id = 200;
    EXCEPTION
      WHEN OTHERS THEN
        l_ap_name := 'Oracle Payables';
    END;
    FII_UTIL.debug_line('  l_ap_name            = ' || l_ap_name);

    -- Set l_reconv_ap_flag
    IF (l_installed_flag = 'Y')
    THEN
      l_reconv_ap_flag := 'Y';

    ELSE
      l_reconv_ap_flag := 'N';

      IF (p_transaction_type = 'AP')
      THEN
        -- Only AP is selected for reconversion but it's not installed
        --   => Get error message and raise INVALID_SETUP exception
        l_err_msg := FII_MESSAGE.get_message(
                        'FII_RECONV_PROD_NOT_INSTALLED', NULL
                      , 'PROD_NAME', l_ap_name);
        RAISE INVALID_SETUP;
      END IF; -- IF (p_transaction_type = 'AP')

    END IF; -- IF (l_installed_flag = 'Y')
  END IF; -- IF (p_transaction_type = 'AP' OR p_transaction_type = 'ALL')
  FII_UTIL.debug_line('  l_reconv_ap_flag     = ' || l_reconv_ap_flag);

  -- Set l_reconv_ar_flag based on p_transaction_type
  l_process_step := 'CHECK_RECONV_AR';
  IF (p_transaction_type = 'AR' OR p_transaction_type = 'ALL')
  THEN
    -- Check if AR is installed
    BEGIN
      SELECT 'Y' INTO l_installed_flag
      FROM FND_PRODUCT_INSTALLATIONS
      WHERE application_id = 222;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_installed_flag := 'N';
    END;

    -- Get AR application name
    BEGIN
      SELECT application_name INTO l_ar_name
      FROM FND_APPLICATION_TL
      WHERE application_id = 222;
    EXCEPTION
      WHEN OTHERS THEN
        l_ar_name := 'Oracle Receivables';
    END;
    FII_UTIL.debug_line('  l_ar_name            = ' || l_ar_name);

    -- Set l_reconv_ar_flag
    IF (l_installed_flag = 'Y')
    THEN
      l_reconv_ar_flag := 'Y';

    ELSE
      l_reconv_ar_flag := 'N';

      IF (p_transaction_type = 'AR')
      THEN
        -- Only AR is selected for reconversion but it's not installed
        --   => Get error message and raise INVALID_SETUP exception
        l_err_msg := FII_MESSAGE.get_message(
                        'FII_RECONV_PROD_NOT_INSTALLED', NULL
                      , 'PROD_NAME', l_ar_name);
        RAISE INVALID_SETUP;
      END IF; -- IF (p_transaction_type = 'AR')

    END IF; -- IF (l_installed_flag = 'Y')
  END IF; -- IF (p_transaction_type = 'AR' OR p_transaction_type = 'ALL')
  FII_UTIL.debug_line('  l_reconv_ar_flag     = ' || l_reconv_ar_flag);

  l_process_step := 'GET_PRI_SEC_TEXT';
  -- Set l_primaryText
  l_primaryText := FII_MESSAGE.get_message('FII_RECONV_PRIMARY', NULL);
  FII_UTIL.debug_line('  l_primaryText = ' || l_primaryText);
  -- Set l_secondaryText
  l_secondaryText := FII_MESSAGE.get_message('FII_RECONV_SECONDARY', NULL);
  FII_UTIL.debug_line('  l_secondaryText = ' || l_secondaryText);

  -- Validate Primary global currency setup
  l_process_step := 'VALIDATE_PRI_SETUP';
  IF (p_currency_type = 'PRIMARY' OR p_currency_type = 'ALL')
  THEN
    -- Check if the primary rate type is provided
    IF (p_primary_rate_type IS NULL)
    THEN
      -- It's not provided
        --   => Get error message and raise INVALID_SETUP exception
      l_err_msg := FII_MESSAGE.get_message(  'FII_RECONV_NO_RATE_TYPE', NULL
                                           , 'CURR_TYPE1', l_primaryText
                                           , 'CURR_TYPE2', l_primaryText);
      RAISE INVALID_SETUP;

    ELSE
      -- Set l_primary_currency and l_primary_mau
      l_primary_currency := BIS_COMMON_PARAMETERS.get_currency_code;
      FII_UTIL.debug_line('  l_primary_currency = ' || l_primary_currency);
      l_primary_mau := FII_CURRENCY.get_mau_primary;
      FII_UTIL.debug_line('  l_primary_mau = ' || l_primary_mau);

      -- Validate primary currency and its MAU
      IF (l_primary_currency IS NULL AND p_currency_type = 'PRIMARY')
      THEN
        -- Primary is selected only but fails to find its currency code
        --   => Get error message and raise INVALID_SETUP exception
        l_err_msg := FII_MESSAGE.get_message(  'FII_RECONV_CURR_NOT_FOUND', NULL
                                             , 'CURR_TYPE', l_primaryText);
        RAISE INVALID_SETUP;
      END IF; -- IF (l_primary_currency IS NULL AND p_currency_type = 'PRIMARY')

      IF (l_primary_currency IS NOT NULL AND l_primary_mau IS NULL)
      THEN
        -- Cannot find the MAU for primary global currency
        --   => Get error message and raise INVALID_SETUP exception
        l_err_msg := FII_MESSAGE.get_message(  'FII_RECONV_INVALID_MAU', NULL
                                             , 'CURR_TYPE', l_primaryText);
        RAISE INVALID_SETUP;
      END IF; -- IF (l_primary_currency IS NOT NULL AND l_primary_mau IS NULL)

    END IF; -- IF (p_primary_rate_type IS NULL)
  END IF; -- IF (p_currency_type = 'PRIMARY' OR p_currency_type = 'ALL')

  -- Validate Secondary global currency setup
  l_process_step := 'VALIDATE_SEC_SETUP';
  IF (p_currency_type = 'SECONDARY' OR p_currency_type = 'ALL')
  THEN
        -- Check if the secondary rate type is provided
    IF (p_secondary_rate_type IS NULL)
    THEN
      -- It's not provided
      --   => Get error message and raise INVALID_SETUP exception
      l_err_msg := FII_MESSAGE.get_message(  'FII_RECONV_NO_RATE_TYPE', NULL
                                           , 'CURR_TYPE1', l_secondaryText
                                           , 'CURR_TYPE2', l_secondaryText);
      RAISE INVALID_SETUP;

    ELSE
      l_secondary_currency := BIS_COMMON_PARAMETERS.get_secondary_currency_code;
      FII_UTIL.debug_line('  l_secondary_currency = ' || l_secondary_currency);
      l_secondary_mau := FII_CURRENCY.get_mau_secondary;
      FII_UTIL.debug_line('  l_secondary_mau      = ' || l_secondary_mau);

      IF (l_secondary_currency IS NULL AND p_currency_type = 'SECONDARY')
      THEN
        -- Secondary is selected only but fails to find its currency code
        --   => Get error message and raise INVALID_SETUP exception
        l_err_msg := FII_MESSAGE.get_message(  'FII_RECONV_CURR_NOT_FOUND', NULL
                                             , 'CURR_TYPE', l_secondaryText);
        RAISE INVALID_SETUP;
      END IF; -- IF (l_secondary_currency IS NULL AND p_currency_type = ...

      IF (l_secondary_currency IS NOT NULL AND l_secondary_mau IS NULL)
      THEN
        -- Cannot find the MAU for secondary global currency
        --   => Get error message and raise INVALID_SETUP exception
        l_err_msg := FII_MESSAGE.get_message(  'FII_RECONV_INVALID_MAU', NULL
                                             , 'CURR_TYPE', l_secondaryText);
        RAISE INVALID_SETUP;
      END IF; -- IF (l_secondary_currency IS NOT NULL AND l_secondary_mau ...

    END IF; -- IF (p_secondary_rate_type IS NULL)
  END IF; -- IF (p_currency_type = 'SECONDARY' OR p_currency_type = 'ALL')

  -- Convert date strings to date format
  l_process_step := 'CONVERT_STR_TO_DATE';
  l_from_date := TO_DATE(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  FII_UTIL.debug_line('  l_from_date          = ' || l_from_date);
  l_to_date := TO_DATE(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  FII_UTIL.debug_line('  l_to_date            = ' || l_to_date);

  -- Validate the date range
  l_process_step := 'CHECK_FROM_BEFORE_TO';
  IF (l_from_date > l_to_date)
  THEN
    -- From Date is after To Date
    --   => Get error message and raise INVALID_SETUP exception
    l_err_msg := FII_MESSAGE.get_message('FII_RECONV_INVALID_DATE_RANGE', NULL);
    RAISE INVALID_SETUP;

  ELSE
    -- Validate the passed From Date which is defined in the global calendar
    l_process_step := 'VALIDATE_FROM_DATE';
    BEGIN
      SELECT report_date_julian INTO l_from_date_id
      FROM FII_TIME_DAY
      WHERE report_date = l_from_date;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- From Date is not defined in the calendar
        --   => Get error message and raise INVALID_SETUP exception
        l_err_msg := FII_MESSAGE.get_message(  'FII_RECONV_INVALID_DATE', NULL
                                             , 'P_DATE', l_from_date);
        RAISE INVALID_SETUP;
    END;
    FII_UTIL.debug_line('  l_from_date_id       = ' || l_from_date_id);

    -- Validate the passed To Date which is defined in the global calendar
    l_process_step := 'VALIDATE_TO_DATE';
    BEGIN
      SELECT report_date_julian INTO l_to_date_id
      FROM FII_TIME_DAY
      WHERE report_date = l_to_date;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- To Date is not defined in the calendar
        --   => Get error message and raise INVALID_SETUP exception
        l_err_msg := FII_MESSAGE.get_message(  'FII_RECONV_INVALID_DATE', NULL
                                             , 'P_DATE', l_to_date);
        RAISE INVALID_SETUP;
    END;
    FII_UTIL.debug_line('  l_to_date_id         = ' || l_to_date_id);
  END IF; -- IF (l_from_date > l_to_date)

  -- ===========================
  -- 2. Cache reconversion rates
  -- ===========================
  l_process_step := 'CACHE_RATES';
  l_caching_status := FII_RECONVERSION_PKG.cache_rates(
                         l_conc_req_id, l_gl_name, l_ap_name, l_ar_name
                       , l_primary_currency, p_primary_rate_type
                       , l_secondary_currency, p_secondary_rate_type
                       , l_reconv_gl_flag, l_reconv_ap_flag, l_reconv_ar_flag
                       , l_from_date_id, l_to_date_id);

  l_process_step := 'CHECK_CACHING_STATUS';
  IF (l_caching_status = 'C')
  THEN
    -- All required rates are cached successfully, so launch 1 sub-request to
    -- reconvert global amounts for each product

    -- LOG: FII_RECONV_LAUNCH_STEP || time stamp
    FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                            'FII_RECONV_LAUNCH_STEP', NULL));

    -- ====================================================
    -- 3. Launch request to reconvert global amounts for GL
    -- ====================================================
    IF (l_reconv_gl_flag = 'Y')
    THEN
      l_process_step := 'LAUNCH_REQUEST_GL';
      -- Launch the request and store the reqeust record
      l_launched_ct := l_launched_ct + 1;
      l_req_list.extend;
      l_req_list(l_launched_ct).application_id := 101;
      l_req_list(l_launched_ct).request_id :=
	    FND_REQUEST.SUBMIT_REQUEST(  'FII'
                                   , 'FII_CURR_RECONV_GL_SUBWORKER'
                                   , ''
                                   , ''
                                   , FALSE
                                   , l_conc_req_id
                                   , l_user_id
                                   , l_gl_name
                                   , l_primary_currency
-- 09/26/05: Changed to convert MAUs to char properly in order to avoid from
-- encountering ORA-06502: PL/SQL: numeric or value error
                                   , TO_CHAR(NVL(l_primary_mau, -1),
                                             'FM99999.99999999999999999999')
                                   , l_secondary_currency
                                   , TO_CHAR(NVL(l_secondary_mau, -1),
                                             'FM99999.99999999999999999999')
                                   , l_from_date_id
                                   , l_to_date_id
                                   , p_log_filename
                                   , p_output_filename);

      -- Check if the child request is submitted successfully
      IF (l_req_list(l_launched_ct).request_id = 0)
      THEN
        -- Fail to submit the child request
        l_completion_status := 'E';
        FII_UTIL.put_line(FII_MESSAGE.get_message(
                             'FII_RECONV_LAUNCH_ERROR', NULL
                           , 'PROD_NAME', l_gl_name));
        FII_UTIL.put_line(' ');
      ELSE
        -- Succeed to submit the child request
        -- Commit it in order to launch the child request
        COMMIT;
        FII_UTIL.put_line(FII_MESSAGE.get_message(
                             'FII_RECONV_LAUNCH_SUCCESS', NULL
                           , 'REQ_ID', l_req_list(l_launched_ct).request_id
                           , 'PROD_NAME', l_gl_name));
        l_running_ct := l_running_ct + 1;
      END IF;
    END IF; -- IF (l_reconv_gl_flag)

    -- ====================================================
    -- 4. Launch request to reconvert global amounts for AP
    -- ====================================================
    IF (l_reconv_ap_flag = 'Y')
    THEN
      l_process_step := 'LAUNCH_REQUEST_AP';
      -- Launch the request and store the reqeust record
      l_launched_ct := l_launched_ct + 1;
      l_req_list.extend;
      l_req_list(l_launched_ct).application_id := 200;
      l_req_list(l_launched_ct).request_id :=
	    FND_REQUEST.SUBMIT_REQUEST(  'FII'
                                   , 'FII_CURR_RECONV_AP_SUBWORKER'
                                   , ''
                                   , ''
                                   , FALSE
                                   , l_conc_req_id
                                   , l_user_id
                                   , l_ap_name
                                   , l_primary_currency
-- 09/26/05: Changed to convert MAUs to char properly in order to avoid from
-- encountering ORA-06502: PL/SQL: numeric or value error
                                   , TO_CHAR(NVL(l_primary_mau, -1),
                                             'FM99999.99999999999999999999')
                                   , l_secondary_currency
                                   , TO_CHAR(NVL(l_secondary_mau, -1),
                                             'FM99999.99999999999999999999')
                                   , l_from_date_id
                                   , l_to_date_id
                                   , p_log_filename
                                   , p_output_filename);

      -- Check if the child request is submitted successfully
      IF (l_req_list(l_launched_ct).request_id = 0)
      THEN
        -- Fail to submit the child request
        l_completion_status := 'E';
        FII_UTIL.put_line(FII_MESSAGE.get_message(
                             'FII_RECONV_LAUNCH_ERROR', NULL
                           , 'PROD_NAME', l_ap_name));
      ELSE
        -- Succeed to submit the child request
        -- Commit it in order to launch the child request
        COMMIT;
        FII_UTIL.put_line(FII_MESSAGE.get_message(
                             'FII_RECONV_LAUNCH_SUCCESS', NULL
                           , 'REQ_ID', l_req_list(l_launched_ct).request_id
                           , 'PROD_NAME', l_ap_name));
        l_running_ct := l_running_ct + 1;
      END IF;
    END IF; -- IF (l_reconv_ap_flag)

    -- ====================================================
    -- 5. Launch request to reconvert global amounts for AR
    -- ====================================================
    IF (l_reconv_ar_flag = 'Y')
    THEN
      l_process_step := 'LAUNCH_REQUEST_AR';
      -- Launch the request and store the reqeust record
      l_launched_ct := l_launched_ct + 1;
      l_req_list.extend;
      l_req_list(l_launched_ct).application_id := 222;
      l_req_list(l_launched_ct).request_id :=
	    FND_REQUEST.SUBMIT_REQUEST(  'FII'
                                   , 'FII_CURR_RECONV_AR_SUBWORKER'
                                   , ''
                                   , ''
                                   , FALSE
                                   , l_conc_req_id
                                   , l_user_id
                                   , l_ar_name
                                   , l_primary_currency
-- 09/26/05: Changed to convert MAUs to char properly in order to avoid from
-- encountering ORA-06502: PL/SQL: numeric or value error
                                   , TO_CHAR(NVL(l_primary_mau, -1),
                                             'FM99999.99999999999999999999')
                                   , l_secondary_currency
                                   , TO_CHAR(NVL(l_secondary_mau, -1),
                                             'FM99999.99999999999999999999')
                                   , l_from_date_id
                                   , l_to_date_id
                                   , p_log_filename
                                   , p_output_filename);

      -- Check if the child request is submitted successfully
      IF (l_req_list(l_launched_ct).request_id = 0)
      THEN
        -- Fail to submit the child request
        l_completion_status := 'E';
        FII_UTIL.put_line(FII_MESSAGE.get_message(
                             'FII_RECONV_LAUNCH_ERROR', NULL
                           , 'PROD_NAME', l_ar_name));
      ELSE
        -- Succeed to submit the child request
        -- Commit it in order to launch the child request
        COMMIT;
        FII_UTIL.put_line(FII_MESSAGE.get_message(
                             'FII_RECONV_LAUNCH_SUCCESS', NULL
                           , 'REQ_ID', l_req_list(l_launched_ct).request_id
                           , 'PROD_NAME', l_ar_name));
        l_running_ct := l_running_ct + 1;
      END IF;
    END IF; -- IF (l_reconv_ar_flag)

    -- ========================================================
    -- 6. Wait until all running requests completed/errored out
    -- ========================================================
    IF (l_running_ct > 0)
    THEN
      -- At least one request is submitted successfully, so wait for it to
      -- complete before proceeding to print the execution report
      l_process_step := 'WAIT_FOR_REQUESTS';
      -- LOG: FII_RECONV_LAUNCH_STEP || time stamp
      FII_UTIL.put_line(' ');
      FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                              'FII_RECONV_WAIT_STEP', NULL));

      WHILE (l_running_ct > 0 )
      LOOP
        FOR i IN 1..l_launched_ct
        LOOP
          IF (l_req_list(i).request_id <> 0
              AND NVL(l_req_list(i).dev_phase, 'PENDING') <> 'COMPLETE')
          THEN
            -- Get the request status
            l_return_val := FND_CONCURRENT.get_request_status(
                               l_req_list(i).request_id
                             , NULL
                             , NULL
                             , l_req_list(i).phase
                             , l_req_list(i).status
                             , l_req_list(i).dev_phase
                             , l_req_list(i).dev_status
                             , l_req_list(i).completion_msg);

            IF (l_req_list(i).dev_phase = 'COMPLETE')
            THEN
              -- The launched request has completed
              l_running_ct := l_running_ct - 1;
              FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                                        'FII_RECONV_CHILD_COMPLETE', NULL
                                      , 'REQ_ID', l_req_list(i).request_id
                                      , 'STATUS', l_req_list(i).status));

              -- Check if it errors out
              IF (l_req_list(i).dev_status = 'ERROR')
              THEN
                -- The child process errors out, so print error message
                FII_UTIL.put_line(FII_MESSAGE.get_message(
                                     'FII_RECONV_CHILD_ERROR', NULL
                                   , 'REQ_ID', l_req_list(i).request_id));
                FII_UTIL.put_line('  ' || l_req_list(i).completion_msg);

                -- If any child request errors out, this process will error out
                l_completion_status := 'E';
              END IF; -- IF (l_req_list(i).dev_status = 'ERROR')
            END IF; -- IF (l_req_list(i).dev_phase = 'COMPLETE')
          END IF; -- IF (l_req_list(i).request_id <> 0)
        END LOOP; -- FOR LOOP

        -- Sleep 30 Seconds
        DBMS_LOCK.sleep(30);
      END LOOP; -- WHILE LOOP
    END IF; -- IF (l_running_ct > 0)

  ELSIF (l_caching_status = 'M')
  THEN
    -- There are missing rates, so exit the program with error
    l_completion_status := 'E';
    l_err_msg := FII_MESSAGE.get_message('FII_RECONV_MISSING_RATES', NULL);

  ELSE
    -- There are no transactions selected for reconversion. We will still
    -- exit the program successfully
    FII_UTIL.put_line(FII_MESSAGE.get_message(
                       'FII_RECONV_NO_TRANSACTIONS', NULL));

  END IF; -- IF (l_caching_status = 'C')

  -- =========================
  -- 7. Print execution report
  -- =========================
  l_process_step := 'PRINT_EXECUTION_REPORT';
  -- LOG: FII_RECONV_PRINT_RPT_STEP || time stamp
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                          'FII_RECONV_PRINT_RPT_STEP', NULL));
  FII_RECONVERSION_PKG.print_report(  l_conc_req_id
                                    , p_transaction_type
                                    , p_currency_type
                                    , p_primary_rate_type
                                    , p_secondary_rate_type
                                    , p_from_date
                                    , p_to_date
                                    , l_primary_currency
                                    , l_secondary_currency
                                    , l_caching_status
                                    , l_completion_status);

  -- ===========================
  -- 8. Cleanup the cached rates
  -- ===========================
  l_process_step := 'CLEANUP_CACHED_RATES';
  -- LOG: FII_RECONV_EXIT_PROCESS_STEP || time stamp
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                          'FII_RECONV_CLEANUP_STEP', NULL));
  -- Delete cached rates from FII_RECONV_RATES for this request and commit
  DELETE FROM FII_RECONV_RATES
  WHERE request_id = l_conc_req_id;
  COMMIT;

  -- ===================
  -- 9. Exit the process
  -- ===================
  l_process_step := 'EXIT_PROCESS';
  -- LOG: FII_RECONV_EXIT_PROCESS_STEP || time stamp
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                          'FII_RECONV_EXIT_PROCESS_STEP', NULL));

  IF (l_completion_status = 'E')
  THEN
    -- Process errors out
    IF (l_caching_status = 'C')
    THEN
      FII_UTIL.debug_line('This process errors out because of sub-request(s)');
      errbuf := FII_MESSAGE.get_message('FII_RECONV_PROCESS_FAIL', NULL);
      l_process_step := 'LAUNCH_REQUESTS';
    ELSE
      FII_UTIL.debug_line('This process errors out because of missing rate(s)');
      errbuf := l_err_msg;
      l_process_step := 'CACHE_RATES';
    END IF;
    -- Print error messages to log
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, errbuf);
    -- Set the concurrent program completion status to ERROR
    l_return_val := FND_CONCURRENT.set_completion_status('ERROR', NULL);
    -- Raise application error
    RAISE_APPLICATION_ERROR(-20010, errbuf);

  ELSE
    -- Process coompletes successfully
    FII_UTIL.debug_line('This process completes successfully');
    -- Commit changes to the database
    FND_CONCURRENT.af_commit;
    -- Set the concurrent program completion status
    l_return_val := FND_CONCURRENT.set_completion_status('COMPLETE', NULL);
    FII_RECONVERSION_PKG.func_succ(l_procedure_name);
  END IF;

EXCEPTION
  WHEN INVALID_SETUP THEN
    -- Process fails because of invalid setup
    -- Note: We don't need to rollback since there are no updates/insert
    FII_UTIL.debug_line('This process errors out because of invalid setup');
    -- Print error messages to log
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, l_err_msg);
    -- Set the concurrent program completion status to ERROR
    l_return_val := FND_CONCURRENT.set_completion_status('ERROR', NULL);
    -- Raise application error
    errbuf := l_err_msg;
    RAISE_APPLICATION_ERROR(-20020, errbuf);

  WHEN RECONV_ERROR THEN
    -- Process fails because of exceptions raised from other functions
    -- and we need to rollback
    FII_UTIL.debug_line('This process errors out because of other functions');
    -- Rollback
    FND_CONCURRENT.af_rollback;
    -- Print error messages to log file
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step);
    -- Set the concurrent program completion status to ERROR
    l_return_val := FND_CONCURRENT.set_completion_status('ERROR', NULL);
    -- Raise application error
    errbuf := sqlerrm;
    retcode := sqlcode;
    RAISE_APPLICATION_ERROR(-20030, errbuf);

  WHEN OTHERS THEN
    -- Process fails because of other exceptions and we need to rollback
    FII_UTIL.debug_line('This process errors out because of other exceptions');
    -- Rollback
    FND_CONCURRENT.af_rollback;
    -- Print error messages to log file
    errbuf := sqlerrm;
    retcode := sqlcode;
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, errbuf);
    -- Set the concurrent program completion status to ERROR
    l_return_val := FND_CONCURRENT.set_completion_status('ERROR', NULL);
    -- Raise application error
    RAISE_APPLICATION_ERROR(-20040, errbuf);

END reconvert_amounts;


--
-- FUCNTION
--   cache_rates()
--
-- DESCRIPTION:
--   It will insert global conversion rates (from set of books currencies to
--   global currencies) into FII_RECONV_RATES for the specified date range.
--
--   The return value can be:
--    'C' - all the required rates are cached
--    'M' - there are missing rates
--    'N' - no rates are cached
FUNCTION cache_rates(  p_request_id          IN NUMBER
                     , p_gl_name             IN VARCHAR2
                     , p_ap_name             IN VARCHAR2
                     , p_ar_name             IN VARCHAR2
                     , p_primary_currency    IN VARCHAR2
                     , p_primary_rate_type   IN VARCHAR2
                     , p_secondary_currency  IN VARCHAR2
                     , p_secondary_rate_type IN VARCHAR2
                     , p_cache_for_gl_flag   IN VARCHAR2
                     , p_cache_for_ap_flag   IN VARCHAR2
                     , p_cache_for_ar_flag   IN VARCHAR2
                     , p_from_date_id        IN NUMBER
                     , p_to_date_id          IN NUMBER
                    ) RETURN VARCHAR2 IS
  l_status             VARCHAR2(1) := 'C';
  l_cached_rate_count  NUMBER := 0;
  l_cached_rate_flag   BOOLEAN := FALSE;
  l_missing_rate_count NUMBER := 0;

  l_process_step       VARCHAR2(50) := 'INIT_CACHE_RATES';
  l_procedure_name     VARCHAR2(30) := 'cache_rates';
BEGIN
  FII_RECONVERSION_PKG.func_enter(l_procedure_name);

  IF (p_cache_for_gl_flag = 'Y')
  THEN
    --
    -- 2.1 Cache rates for GL
    --
    l_process_step := 'CACHE_RATES_FOR_GL';

    -- LOG: FII_RECONV_CACHE_RATE_STEP || time stamp for GL
    FII_UTIL.put_line(' ');
    FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                              'FII_RECONV_CACHE_RATE_STEP', NULL
                            , 'PROD_NAME', p_gl_name));

    -- Insert rates to FII_RECONV_RATES based on the transactions of
    -- FII_GL_JE_SUMMARY_B within the passed date range
    INSERT INTO FII_RECONV_RATES
    (  REQUEST_ID, RATE_DATE_ID, RATE_DATE, FROM_CURRENCY
     , PRIMARY_RATE, SECONDARY_RATE)
    (SELECT DISTINCT
        p_request_id, t.report_date_julian, t.report_date, sob.currency_code
      , DECODE(  p_primary_currency, sob.currency_code, 1, NULL, NULL
               , FII_CURRENCY.GET_RATE(  sob.currency_code, p_primary_currency
                                       , t.report_date, p_primary_rate_type))
      , DECODE(  p_secondary_currency, sob.currency_code, 1, NULL, NULL
               , FII_CURRENCY.GET_RATE(  sob.currency_code, p_secondary_currency
                                       , t.report_date, p_secondary_rate_type))
     FROM FII_TIME_DAY t, GL_LEDGERS_PUBLIC_V sob
     WHERE t.report_date_julian BETWEEN p_from_date_id and p_to_date_id
     AND EXISTS (SELECT 'This date has GL transaction'
                   FROM FII_GL_JE_SUMMARY_B gl
                  WHERE gl.time_id = t.report_date_julian
-- Bug fix 4637659: Added to check PERIOD_TYPE_ID since it is the first column
--                  of the changed FII_GL_JE_SUMMARY_B_U1
                    AND gl.period_type_id = 1
                    AND gl.ledger_id = sob.ledger_id));

    -- LOG: Print the number of cached rates for GL
    l_cached_rate_count := NVL(SQL%ROWCOUNT, 0);
    IF (l_cached_rate_count > 0)
    THEN
      l_cached_rate_flag := TRUE;
    END IF;
    FND_MESSAGE.set_name('FND', 'GENERIC_ROWS_PROCESSED');
    FND_MESSAGE.set_token('ROWS', l_cached_rate_count);
    FII_UTIL.put_timestamp(FND_MESSAGE.get);
  END IF; -- IF (p_cache_for_gl_flag = 'Y')

  IF (p_cache_for_ap_flag = 'Y')
  THEN
    --
    -- 2.2 Cache rates for AP only if they're not cached yet
    --
    l_process_step := 'CACHE_RATES_FOR_AP';

    -- LOG: FII_RECONV_CACHE_RATE_STEP || time stamp for AP
    FII_UTIL.put_line(' ');
    FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                              'FII_RECONV_CACHE_RATE_STEP', NULL
                            , 'PROD_NAME', p_ap_name));

    -- Insert rates to FII_RECONV_RATES based on the transactions of
    -- FII_AP_INV_B within the passed date range and they are not yet cached
    INSERT INTO FII_RECONV_RATES
    (  REQUEST_ID, RATE_DATE_ID, RATE_DATE, FROM_CURRENCY
     , PRIMARY_RATE, SECONDARY_RATE)
    (SELECT DISTINCT
        p_request_id, t.report_date_julian, t.report_date, sob.currency_code
      , DECODE(  p_primary_currency, sob.currency_code, 1, NULL, NULL
               , FII_CURRENCY.GET_RATE(  sob.currency_code, p_primary_currency
                                       , t.report_date, p_primary_rate_type))
      , DECODE(  p_secondary_currency, sob.currency_code, 1, NULL, NULL
               , FII_CURRENCY.GET_RATE(  sob.currency_code, p_secondary_currency
                                       , t.report_date, p_secondary_rate_type))
     FROM FII_TIME_DAY t, GL_LEDGERS_PUBLIC_V sob
     WHERE t.report_date_julian BETWEEN p_from_date_id and p_to_date_id
     AND EXISTS (SELECT /*+ parallel(ap) */ 'This date has AP transaction'
                   FROM FII_AP_INV_B ap
                  WHERE ap.account_date_id = t.report_date_julian
                    AND ap.ledger_id = sob.ledger_id)
     AND NOT EXISTS (SELECT 'This rate has been cached'
                       FROM FII_RECONV_RATES r
                      WHERE r.request_id = p_request_id
                        AND r.rate_date_id = t.report_date_julian
                        AND r.from_currency = sob.currency_code));

    -- LOG: Print the number of cached rates for AP
    l_cached_rate_count := NVL(SQL%ROWCOUNT, 0);
    IF (l_cached_rate_count > 0)
    THEN
      l_cached_rate_flag := TRUE;
    END IF;
    FND_MESSAGE.set_name('FND', 'GENERIC_ROWS_PROCESSED');
    FND_MESSAGE.set_token('ROWS', l_cached_rate_count);
    FII_UTIL.put_timestamp(FND_MESSAGE.get);
  END IF; -- IF (p_cache_for_ap_flag = 'Y')

  IF (p_cache_for_ar_flag = 'Y')
  THEN
    --
    -- 2.3 Cache rates for AR only if they're not cached yet
    --
    l_process_step := 'CACHE_RATES_FOR_AR';

    -- LOG: FII_RECONV_CACHE_RATE_STEP || time stamp for AR
    FII_UTIL.put_line(' ');
    FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                              'FII_RECONV_CACHE_RATE_STEP', NULL
                            , 'PROD_NAME', p_ar_name));

    -- Insert rates to FII_RECONV_RATES based on the transactions of
    -- FII_AR_REVENUE_B within the passed date range and they are not yet cached
    INSERT INTO FII_RECONV_RATES
    (  REQUEST_ID, RATE_DATE_ID, RATE_DATE, FROM_CURRENCY
     , PRIMARY_RATE, SECONDARY_RATE)
    (SELECT DISTINCT
        p_request_id, t.report_date_julian, t.report_date, sob.currency_code
      , DECODE(  p_primary_currency, sob.currency_code, 1, NULL, NULL
               , FII_CURRENCY.GET_RATE(  sob.currency_code, p_primary_currency
                                       , t.report_date, p_primary_rate_type))
      , DECODE(  p_secondary_currency, sob.currency_code, 1, NULL, NULL
               , FII_CURRENCY.GET_RATE(  sob.currency_code, p_secondary_currency
                                       , t.report_date, p_secondary_rate_type))
     FROM FII_TIME_DAY t, GL_LEDGERS_PUBLIC_V sob
     WHERE t.report_date_julian BETWEEN p_from_date_id and p_to_date_id
     AND EXISTS (SELECT /*+ parallel(ar) */ 'This date has AR transaction'
                   FROM FII_AR_REVENUE_B ar
                  WHERE ar.gl_date_id = t.report_date_julian
                    AND ar.ledger_id = sob.ledger_id)
     AND NOT EXISTS (SELECT 'This rate has been cached'
                       FROM FII_RECONV_RATES r
                      WHERE r.request_id = p_request_id
                        AND r.rate_date_id = t.report_date_julian
                        AND r.from_currency = sob.currency_code));

    -- LOG: Print the number of cached rates for AR
    l_cached_rate_count := NVL(SQL%ROWCOUNT, 0);
    IF (l_cached_rate_count > 0)
    THEN
      l_cached_rate_flag := TRUE;
    END IF;
    FND_MESSAGE.set_name('FND', 'GENERIC_ROWS_PROCESSED');
    FND_MESSAGE.set_token('ROWS', l_cached_rate_count);
    FII_UTIL.put_timestamp(FND_MESSAGE.get);
  END IF; -- IF (p_cache_for_ar_flag = 'Y')

  --
  -- 2.4 Determine the caching rate status
  --
  l_process_step := 'SET_CACHINE_STATUS';
  IF (l_cached_rate_flag)
  THEN
    -- Check if there are any missing/invalid rates (i.e. rate <= 0)
    -- only when there are cached rates
    l_process_step := 'CHECK_MISSING_RATES';
    SELECT count(*) INTO l_missing_rate_count
    FROM FII_RECONV_RATES
    WHERE request_id = p_request_id
    AND (NVL(primary_rate, 1) <= 0 OR NVL(secondary_rate, 1) <= 0);
    FII_UTIL.debug_line(' ');
    FII_UTIL.debug_line(TO_CHAR(l_missing_rate_count)
                         || ' days have missing rates');

    IF (l_missing_rate_count > 0)
    THEN
      -- There are missing rates
      l_status := 'M';

    ELSE
      -- All rates are cached
      l_status := 'C';

    END IF;

  ELSE
    -- No rates are cached
    l_status := 'N';

  END IF;

  FII_RECONVERSION_PKG.func_succ(l_procedure_name);
  RETURN l_status;

EXCEPTION
  WHEN OTHERS THEN
    -- Print error code and messages to log file and raise error
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, sqlerrm);
    -- Raise RECONV_ERROR which will be handled in reconvert_amounts()
    RAISE RECONV_ERROR;

END cache_rates;


-- PROCEDURE
--   `()
--
-- DESCRIPTION:
--   It will reconvert global amounts for the GL base table FII_GL_JE_SUMMARY_B.
PROCEDURE reconvert_gl(  errbuf               IN OUT NOCOPY VARCHAR2
                       , retcode              IN OUT NOCOPY VARCHAR2
                       , p_request_id         IN NUMBER
                       , p_user_id            IN NUMBER
                       , p_product_name       IN VARCHAR2
                       , p_primary_currency   IN VARCHAR2
                       , p_primary_mau        IN NUMBER
                       , p_secondary_currency IN VARCHAR2
                       , p_secondary_mau      IN NUMBER
                       , p_from_date_id       IN NUMBER
                       , p_to_date_id         IN NUMBER
                       , p_log_filename       IN VARCHAR2
                       , p_output_filename    IN VARCHAR2
                      ) IS
  l_use_id_columns BOOLEAN := FALSE;
  l_processSQL     DBMS_SQL.VARCHAR2S;
  i        NUMBER := 0;
  l_cursorID       INTEGER;
  l_message        VARCHAR2(255);
  l_processed_rows NUMBER := 0;
  l_return_val     BOOLEAN := FALSE;

  l_process_step   VARCHAR2(50) := 'INIT_RECONV_GL';
  l_procedure_name VARCHAR2(30) := 'reconvert_gl';
BEGIN
  --
  -- 3.1 Initialize the logging for this child request
  --
  FII_UTIL.initialize(p_log_filename || '_GL.log',
                      p_output_filename || '_GL.out',
                      NULL, 'FII_RECONVERSION_PKG');
  -- LOG: Function enter
  FII_RECONVERSION_PKG.func_enter(l_procedure_name);
  -- LOG: FII_RECONV_INIT_STEP || time stamp
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message('FII_RECONV_INIT_STEP', NULL));
  -- LOG: State debug mode is on if it does
  FII_UTIL.debug_line('This process is running in debug mode');

  -- Determine if we should use ID columns or not
  l_process_step := 'CHECK_USE_ID_COLS';
  BEGIN
    -- If it can pass through this SQL, it means we should use ID columns

    -- Build the SELECT SQL to check FII_GL_JE_SUMMARY_B
    l_processSQL(1) := 'SELECT company_id, cost_center_id, fin_category_id';
    l_processSQL(2) := 'FROM FII_GL_JE_SUMMARY_B WHERE rownum = 1';

    -- Open cursor
    l_cursorID := DBMS_SQL.OPEN_CURSOR;
    -- Parse the SQL
    DBMS_SQL.PARSE(l_cursorID, l_processSQL, 1, 2, TRUE, dbms_sql.native);
    -- Execute the SQL
    l_processed_rows := DBMS_SQL.EXECUTE(l_cursorID);
    -- Close cursor
    DBMS_SQL.CLOSE_CURSOR(l_cursorID);

    -- Modify the above SQL to check FII_RECONV_GL_ROLLUP_GT
    l_processSQL(2) := 'FROM FII_RECONV_GL_ROLLUP_GT WHERE rownum =1';

    -- Open cursor
    l_cursorID := DBMS_SQL.OPEN_CURSOR;
    -- Parse the SQL
    DBMS_SQL.PARSE(l_cursorID, l_processSQL, 1, 2, TRUE, dbms_sql.native);
    -- Execute the SQL
    l_processed_rows := DBMS_SQL.EXECUTE(l_cursorID);
    -- Close cursor
    DBMS_SQL.CLOSE_CURSOR(l_cursorID);

    -- It can select the ID columns from FII_GL_JE_SUMMARY_B and
    -- FII_RECONV_GL_ROLLUP_GT, so set l_use_id_columns to TRUE
    l_use_id_columns := TRUE;
    FII_UTIL.debug_line('ID columns exists');
  EXCEPTION
    WHEN OTHERS THEN
      l_use_id_columns := FALSE;
      FII_UTIL.debug_line('ID columns do not exist');
  END;

  -- LOG: FII_RECONV_RECONVERT_AMT_STEP || time stamp for GL
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                            'FII_RECONV_RECONVERT_AMT_STEP', NULL
                          , 'PROD_NAME', p_product_name));

  --
  -- 3.2 Populate daily reconversion differences into FII_RECONV_GL_ROLLUP_GT
  --

  -- Build the dynamic INSERT SQL for inserting daily differences
  l_process_step := 'BUILD_DAILY_SQL_INSERT';

  -- INSERT clause
  -- There are 3 INSERT SQLS and their first 8 lines are the same.
  l_processSQL(1) :=   'INSERT INTO FII_RECONV_GL_ROLLUP_GT';

  IF (l_use_id_columns)
  THEN
    l_processSQL(2) :=
      '(  COMPANY_ID, COST_CENTER_ID, FIN_CATEGORY_ID, JE_SOURCE';
  ELSE
    l_processSQL(2) := '(  COMPANY, COST_CENTER, NATURAL_ACCOUNT, JE_SOURCE';
  END IF;

-- Bug fix 4637659: START
  l_processSQL(3) := ' , JE_CATEGORY, CHART_OF_ACCOUNTS_ID, PROD_CATEGORY_ID
 , USER_DIM1_ID, USER_DIM2_ID, POSTED_DATE';
  l_processSQL(4) := ' , LEDGER_ID, TIME_ID, PERIOD_TYPE_ID';
  l_processSQL(5) :=
    ' , PRIMARY_DIFFERENCE, COMMITTED_AMT_PRI_DIFF
 , OBLIGATED_AMT_PRI_DIFF, OTHER_AMT_PRI_DIFF
 , SECONDARY_DIFFERENCE)';
-- Bug fix 4637659: END

  -- SELECT clause
  l_process_step := 'BUILD_DAILY_SQL_SELECT';
  l_processSQL(6) := '(SELECT /*+ use_hash(g) parallel(g) parallel(r) */';

  -- COLUMNS: COMPANY/COMPANY_ID, COST_CENTER/COST_CENTER_ID,
  --          NATURAL_ACCOUNT/FIN_CATEGORY_ID, JE_SOURCE
  IF (l_use_id_columns)
  THEN
    l_processSQL(7) :=
      '    g.company_id, g.cost_center_id, g.fin_category_id, g.je_source';
  ELSE
    l_processSQL(7) :=
      '    g.company, g.cost_center, g.natural_account, g.je_source';
  END IF;

-- Bug fix 4637659: START
  -- COLUMNS: JE_CATEGORY, CHART_OF_ACCOUNTS_ID, PROD_CATEGORY_ID, USER_DIM1_ID,
  --          USER_DIM2_ID, POSTED_DATE
  l_processSQL(8) :=
      '  , g.je_category, g.chart_of_accounts_id, g.prod_category_id
  , g.user_dim1_id, g.user_dim2_id, g.posted_date';

  -- Set the line count to 9
  i := 9;
  -- COLUMNS: LEDGER_ID, TIME_ID, PERIOD_TYPE_ID
  l_processSQL(i) := '  , g.ledger_id, g.time_id, 1';

  -- COLUMNS: PRIMARY_DIFFERENCE, COMMITTED_AMT_PRI_DIFF,
  --          OBLIGATED_AMT_PRI_DIFF, OTHER_AMT_PRI_DIFF
  i := i + 1;
  IF (p_primary_currency IS NOT NULL)
  THEN
    l_processSQL(i) := '  , Round((g.amount_b*r.primary_rate)/:pri_mau1)';
    i := i + 1;
    l_processSQL(i) := '     *:pri_mau2 - NVL(g.prim_amount_g,0)';
    i := i + 1;
    l_processSQL(i) := '  , Round((g.committed_amount_b*r.primary_rate)/:pri_mau3)';
    i := i + 1;
    l_processSQL(i) := '     *:pri_mau4 - NVL(g.committed_amount_prim,0)';
    i := i + 1;
    l_processSQL(i) := '  , Round((g.obligated_amount_b*r.primary_rate)/:pri_mau5)';
    i := i + 1;
    l_processSQL(i) := '     *:pri_mau6 - NVL(g.obligated_amount_prim,0)';
    i := i + 1;
    l_processSQL(i) := '  , Round((g.other_amount_b*r.primary_rate)/:pri_mau7)';
    i := i + 1;
    l_processSQL(i) := '     *:pri_mau8 - NVL(g.other_amount_prim,0)';
  ELSE
    l_processSQL(i) := '  , 0, 0, 0, 0';
  END IF; -- IF (p_primary_currency IS NOT NULL)
-- Bug fix 4637659: END

  -- COLUMN: SECONDARY_DIFFERENCE
  i := i + 1;
  IF (p_secondary_currency IS NOT NULL)
  THEN
    l_processSQL(i) := '  , Round((g.amount_b*r.secondary_rate)/:sec_mau1)';
    i := i + 1;
    l_processSQL(i) := '     *:sec_mau2 - NVL(g.sec_amount_g,0)';
  ELSE
    l_processSQL(i) := '  , 0';
  END IF; -- IF (p_secondary_currency IS NOT NULL)

  -- FROM clause
  l_process_step := 'BUILD_DAILY_SQL_FROM';
  i := i + 1;
  l_processSQL(i) := ' FROM FII_GL_JE_SUMMARY_B g, FII_RECONV_RATES r';

  -- WHERE clauses
  l_process_step := 'BUILD_DAILY_SQL_WHERE';
  i := i + 1;
  l_processSQL(i) :=
    ' WHERE r.request_id = :req_id AND r.rate_date_id = g.time_id';
  i := i + 1;
  l_processSQL(i) := ' AND g.time_id BETWEEN :from_date_id AND :to_date_id';
  i := i + 1;
  l_processSQL(i) := ' AND g.period_type_id = 1 AND g.amount_b <> 0';
  i := i + 1;
  l_processSQL(i) := ' AND g.functional_currency = r.from_currency';

  -- Check if we need to check primary differences
  IF (p_primary_currency IS NOT NULL)
  THEN
    i := i + 1;
-- Bug fix 4637659: START
    l_processSQL(i) := ' AND (   (Round((g.amount_b*r.primary_rate)/:pri_mau9)';
    i := i + 1;
    l_processSQL(i) := '           *:pri_mau10 - NVL(g.prim_amount_g,0)) <> 0';
    i := i + 1;
    l_processSQL(i) := '      OR (Round((g.committed_amount_b*r.primary_rate)/:pri_mau11)';
    i := i + 1;
    l_processSQL(i) := '           *:pri_mau12 - NVL(g.committed_amount_prim,0)) <> 0';
    i := i + 1;
    l_processSQL(i) := '      OR (Round((g.obligated_amount_b*r.primary_rate)/:pri_mau13)';
    i := i + 1;
    l_processSQL(i) := '           *:pri_mau14 - NVL(g.obligated_amount_prim,0)) <> 0';
    i := i + 1;
    l_processSQL(i) := '      OR (Round((g.other_amount_b*r.primary_rate)/:pri_mau15)';
    i := i + 1;
    l_processSQL(i) := '           *:pri_mau16 - NVL(g.other_amount_prim,0)) <> 0';
-- Bug fix 4637659: END
  END IF;

  -- Check if we need to check secondary differences
  IF (p_secondary_currency IS NOT NULL)
  THEN
    i := i + 1;
    IF (p_primary_currency IS NOT NULL)
    THEN
      l_processSQL(i) :=
        '      OR (Round((g.amount_b*r.secondary_rate)/:sec_mau3)';
    ELSE
      l_processSQL(i) :=
        ' AND (   (Round((g.amount_b*r.secondary_rate)/:sec_mau3)';
    END IF; -- IF (p_primary_currency IS NOT NULL)

    i := i + 1;
    l_processSQL(i) := '           *:sec_mau4- NVL(g.sec_amount_g,0)) <> 0';
  END IF;
  l_processSQL(i) := l_processSQL(i) || '))';

  -- Print the dynamic SQL only when debug is on
  l_process_step := 'PRINT_DAILY_SQL';
  FII_RECONVERSION_PKG.print_sql(
   'Insert daily differences SQL:', l_processSQL, i);

  -- Open cursor
  l_process_step := 'OPEN_DAILY_SQL';
  l_cursorID := DBMS_SQL.OPEN_CURSOR;

  -- Parse the SQL
  l_process_step := 'PARSE_DAILY_SQL';
  DBMS_SQL.PARSE(l_cursorID, l_processSQL, 1, i, TRUE, dbms_sql.native);

  -- Bind variables
  l_process_step := 'BIND_DAILY_SQL';
  IF (p_primary_currency IS NOT NULL)
  THEN
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau1', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau2', p_primary_mau);
-- Bug fix 4637659: START
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau3', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau4', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau5', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau6', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau7', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau8', p_primary_mau);
-- Bug fix 4637659: END
  END IF; -- IF (p_primary_currency IS NOT NULL)

  IF (p_secondary_currency IS NOT NULL)
  THEN
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':sec_mau1', p_secondary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':sec_mau2', p_secondary_mau);
  END IF; -- IF (p_secondary_currency IS NOT NULL)

  DBMS_SQL.BIND_VARIABLE(l_cursorID, ':req_id', p_request_id);
  DBMS_SQL.BIND_VARIABLE(l_cursorID, ':from_date_id', p_from_date_id);
  DBMS_SQL.BIND_VARIABLE(l_cursorID, ':to_date_id', p_to_date_id);

  IF (p_primary_currency IS NOT NULL)
  THEN
-- Bug fix 4637659: START
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau9', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau10', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau11', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau12', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau13', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau14', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau15', p_primary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':pri_mau16', p_primary_mau);
-- Bug fix 4637659: END
  END IF; -- IF (p_primary_currency IS NOT NULL)

  IF (p_secondary_currency IS NOT NULL)
  THEN
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':sec_mau3', p_secondary_mau);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':sec_mau4', p_secondary_mau);
  END IF; -- IF (p_secondary_currency IS NOT NULL)

  -- Execute the SQL
  l_process_step := 'RUN_DAILY_SQL';
  l_processed_rows := DBMS_SQL.EXECUTE(l_cursorID);
  FND_MESSAGE.set_name('FND', 'GENERIC_ROWS_PROCESSED');
  FND_MESSAGE.set_token('ROWS', l_processed_rows);
  FII_UTIL.put_timestamp(FND_MESSAGE.get);

  -- Close cursor
  l_process_step := 'CLOSE_DAILY_SQL';
  DBMS_SQL.CLOSE_CURSOR(l_cursorID);

  -- Check if any daily differences are inserted
  IF (l_processed_rows > 0)
  THEN
    --
    -- 3.3 Roll up to weekly differences
    --

    -- Build the SQL insert weekly differences - we can reuse the first 7 lines
    -- of the above SQL and we don't need to care about the extra lines as we
    -- will pass the number of lines of the new SQL
    l_process_step := 'BUILD_WEEKLY_SQL_SELECT';
    -- Reset the hints for this SQL
    l_processSQL(6) := '(SELECT /*+ parallel(g) parallel(t) use_hash(g) */';
    -- Reset the line count to 9
    i := 9;

    -- COLUMNS: LEDGER_ID, TIME_ID, PERIOD_TYPE_ID
    l_processSQL(i) := '  , g.ledger_id, t.week_id, 16';

-- Bug fix 4637659: START
    -- COLUMNS: PRIMARY_DIFFERENCE, COMMITTED_AMT_PRI_DIFF,
    --          OBLIGATED_AMT_PRI_DIFF, OTHER_AMT_PRI_DIFF
    i := i + 1;
    IF (p_primary_currency IS NOT NULL)
    THEN
      l_processSQL(i) := '  , SUM(g.primary_difference)';
      i := i + 1;
      l_processSQL(i) := '  , SUM(g.committed_amt_pri_diff)';
      i := i + 1;
      l_processSQL(i) := '  , SUM(g.obligated_amt_pri_diff)';
      i := i + 1;
      l_processSQL(i) := '  , SUM(g.other_amt_pri_diff)';
    ELSE
      l_processSQL(i) := '  , 0, 0, 0, 0';
-- Bug fix 4637659: END
    END IF;

    -- COLUMN: SECONDARY_DIFFERENCE
    i := i + 1;
    IF (p_secondary_currency IS NOT NULL)
    THEN
      l_processSQL(i) := '  , SUM(g.secondary_difference)';
    ELSE
      l_processSQL(i) := '  , 0';
    END IF;

    -- FROM clause
    l_process_step := 'BUILD_WEEKLY_SQL_FROM';
    i := i + 1;
    l_processSQL(i) := ' FROM FII_RECONV_GL_ROLLUP_GT g, FII_TIME_DAY t';

    -- WHERE clauses
    l_process_step := 'BUILD_WEEKLY_SQL_WHERE';
    i := i + 1;
    l_processSQL(i) := ' WHERE g.time_id = t.report_date_julian';
    i := i + 1;
    l_processSQL(i) := ' AND g.period_type_id = 1';

    -- HAVING clause
    l_process_step := 'BUILD_WEEKLY_SQL_HAVING';
    -- Check if we need to check primary differences
    IF (p_primary_currency IS NOT NULL)
    THEN
      i := i + 1;
      l_processSQL(i) := ' HAVING (   SUM(g.primary_difference) <> 0';
-- Bug fix 4637659: START
      i := i + 1;
      l_processSQL(i) := '         OR SUM(g.committed_amt_pri_diff) <> 0';
      i := i + 1;
      l_processSQL(i) := '         OR SUM(g.obligated_amt_pri_diff) <> 0';
      i := i + 1;
      l_processSQL(i) := '         OR SUM(g.other_amt_pri_diff) <> 0';
-- Bug fix 4637659: END
    END IF;

    -- Check if we need to check secondary differences
    IF (p_secondary_currency IS NOT NULL)
    THEN
      i := i + 1;
      IF (p_primary_currency IS NOT NULL)
      THEN
        l_processSQL(i) := '         OR SUM(g.secondary_difference) <> 0';
      ELSE
        l_processSQL(i) := ' HAVING (   SUM(g.secondary_difference) <> 0';
      END IF;
    END IF;
    l_processSQL(i) := l_processSQL(i) || ')';

    -- GROUP BY clause
    l_process_step := 'BUILD_WEEKLY_SQL_GROUP_BY';
    i := i + 1;
    IF (l_use_id_columns)
    THEN
      l_processSQL(i) :=
        ' GROUP BY   g.company_id, g.cost_center_id, g.fin_category_id';
    ELSE
      l_processSQL(i) :=
        ' GROUP BY   g.company, g.cost_center, g.natural_account';
    END IF;

    i := i + 1;
    l_processSQL(i) :=
      '          , g.je_source, g.je_category, g.chart_of_accounts_id';
-- Bug fix 4637659: START
    i := i + 1;
    l_processSQL(i) :=
      '          , g.prod_category_id, g.user_dim1_id, g.user_dim2_id';
    i := i + 1;
    l_processSQL(i) :=
      '          , g.posted_date, g.ledger_id, t.week_id)';
-- Bug fix 4637659: END

    -- Print the dynamic SQL only when debug is on
    l_process_step := 'PRINT_WEEKLY_SQL';
    FII_RECONVERSION_PKG.print_sql(
      'Rollup weekly differences SQL:', l_processSQL, i);

    -- Open cursor
    l_process_step := 'OPEN_WEEKLY_SQL';
    l_cursorID := DBMS_SQL.OPEN_CURSOR;

    --   Parse the SQL
    l_process_step := 'PARSE_WEEKLY_SQL';
    DBMS_SQL.PARSE(l_cursorID,l_processSQL,1,i,TRUE,dbms_sql.native);

    -- Execute the SQL
    l_process_step := 'RUN_WEEKLY_SQL';
    l_processed_rows := DBMS_SQL.EXECUTE(l_cursorID);
    FND_MESSAGE.set_name('FND', 'GENERIC_ROWS_PROCESSED');
    FND_MESSAGE.set_token('ROWS', l_processed_rows);
    FII_UTIL.put_timestamp(FND_MESSAGE.get);

    -- Close cursor
    l_process_step := 'CLOSE_WEEKLY_SQL';
    DBMS_SQL.CLOSE_CURSOR(l_cursorID);

    --
    -- 3.4 Roll up to periodly, quarterly, and yearly differences
    --

    -- Build the SQL insert periodly, quarterly, and yearly differences - same
    -- as above, we reuse first 7 lines of the previous SQL
    l_process_step := 'BUILD_OTHER_SQL_SELECT';

    -- Reset the line count to 9
    i := 9;

    -- COLUMNS: LEDGER_ID, TIME_ID
    l_processSQL(i) := '  , g.ledger_id, NVL(t.ent_period_id,';
    i := i + 1;
    l_processSQL(i) :=
      '                           NVL(t.ent_qtr_id, t.ent_year_id))';

    -- COLUMN: PERIOD_TYPE_ID
    i := i + 1;
    l_processSQL(i) := '  , DECODE(t.ent_period_id, NULL';
    i := i + 1;
    l_processSQL(i) := '     , DECODE(t.ent_qtr_id, NULL, 128, 64), 32)';

-- Bug fix 4637659: START
    -- COLUMNS: PRIMARY_DIFFERENCE, COMMITTED_AMT_PRI_DIFF,
    --          OBLIGATED_AMT_PRI_DIFF, OTHER_AMT_PRI_DIFF
    i := i + 1;
    IF (p_primary_currency IS NOT NULL)
    THEN
      l_processSQL(i) := '  , SUM(g.primary_difference)';
      i := i + 1;
      l_processSQL(i) := '  , SUM(g.committed_amt_pri_diff)';
      i := i + 1;
      l_processSQL(i) := '  , SUM(g.obligated_amt_pri_diff)';
      i := i + 1;
      l_processSQL(i) := '  , SUM(g.other_amt_pri_diff)';
    ELSE
      l_processSQL(i) := '  , 0, 0, 0, 0';
-- Bug fix 4637659: END
    END IF;

    -- COLUMN: SECONDARY_DIFFERENCE
    i := i + 1;
    IF (p_secondary_currency IS NOT NULL)
    THEN
      l_processSQL(i) := '  , SUM(g.secondary_difference)';
    ELSE
      l_processSQL(i) := '  , 0';
    END IF;

    -- FROM clause
    l_process_step := 'BUILD_OTHER_SQL_FROM';
    i := i + 1;
    l_processSQL(i) := ' FROM FII_RECONV_GL_ROLLUP_GT g, FII_TIME_DAY t';

    -- WHERE clauses
    l_process_step := 'BUILD_OTHER_SQL_WHERE';
    i := i + 1;
    l_processSQL(i) := ' WHERE g.time_id = t.report_date_julian';
    i := i + 1;
    l_processSQL(i) := ' AND g.period_type_id = 1';

    -- HAVING clause
    l_process_step := 'BUILD_OTHER_SQL_HAVING';
    -- Check if we need to check primary differences
    IF (p_primary_currency IS NOT NULL)
    THEN
      i := i + 1;
      l_processSQL(i) := ' HAVING (   SUM(g.primary_difference) <> 0';
-- Bug fix 4637659: START
      i := i + 1;
      l_processSQL(i) := '         OR SUM(g.committed_amt_pri_diff) <> 0';
      i := i + 1;
      l_processSQL(i) := '         OR SUM(g.obligated_amt_pri_diff) <> 0';
      i := i + 1;
      l_processSQL(i) := '         OR SUM(g.other_amt_pri_diff) <> 0';
-- Bug fix 4637659: END
    END IF;

    -- Check if we need to check secondary differences
    IF (p_secondary_currency IS NOT NULL)
    THEN
      i := i + 1;
      IF (p_primary_currency IS NOT NULL)
      THEN
        l_processSQL(i) := '         OR SUM(g.secondary_difference) <> 0';
      ELSE
        l_processSQL(i) := ' HAVING (   SUM(g.secondary_difference) <> 0';
      END IF;
    END IF;
    l_processSQL(i) := l_processSQL(i) || ')';

    -- GROUP BY clause
    l_process_step := 'BUILD_OTHER_SQL_GROUP_BY';
    i := i + 1;
    IF (l_use_id_columns)
    THEN
      l_processSQL(i) :=
        ' GROUP BY   g.company_id, g.cost_center_id, g.fin_category_id';
    ELSE
      l_processSQL(i) :=
        ' GROUP BY   g.company, g.cost_center, g.natural_account';
    END IF;

    i := i + 1;
    l_processSQL(i) :=
      '          , g.je_source, g.je_category, g.chart_of_accounts_id';
-- Bug fix 4637659: START
    i := i + 1;
    l_processSQL(i) :=
      '          , g.prod_category_id, g.user_dim1_id, g.user_dim2_id';
    i := i + 1;
    l_processSQL(i) :=
      '          , g.posted_date, g.ledger_id, t.ent_year_id';
-- Bug fix 4637659: END
    i := i + 1;
    l_processSQL(i) := '          , ROLLUP(t.ent_qtr_id, t.ent_period_id))';

    -- Print the dynamic SQL only when debug is on
    l_process_step := 'PRINT_OTHER_SQL';
    FII_RECONVERSION_PKG.print_sql(
      'Rollup other differences SQL:', l_processSQL, i);

    -- Open cursor
    l_process_step := 'OPEN_OTHER_SQL';
    l_cursorID := DBMS_SQL.OPEN_CURSOR;

    -- Parse the SQL
    l_process_step := 'PARSE_OTHER_SQL';
    DBMS_SQL.PARSE(l_cursorID, l_processSQL, 1, i, TRUE, dbms_sql.native);

    -- Execute the SQL
    l_process_step := 'RUN_OTHER_SQL';
    l_processed_rows := DBMS_SQL.EXECUTE(l_cursorID);
    FND_MESSAGE.set_name('FND', 'GENERIC_ROWS_PROCESSED');
    FND_MESSAGE.set_token('ROWS', l_processed_rows);
    FII_UTIL.put_timestamp(FND_MESSAGE.get);

    -- Close cursor
    l_process_step := 'CLOSE_OTHER_SQL';
    DBMS_SQL.CLOSE_CURSOR(l_cursorID);

    --
    -- 3.5 Updated FII_GL_JE_SUMMARY_B with the global amount differences,
    --

    -- Build the UPDATE SQL to update the differences to FII_GL_JE_SUMMARY_B
    l_process_step := 'DELETE_SQL_BUFFER';
    -- Reset line count to 1 and delete the SQL buffer since the UPDATE SQL is
    -- totally different with previous INSERT SQLs
    l_processSQL.delete;
    i := 1;

    -- UPDATE clause
    l_process_step := 'BUILD_UPDATE_SQL';
    l_processSQL(i) := 'UPDATE /*+ parallel(g) full(g) */ FII_GL_JE_SUMMARY_B g';
-- Bug fix 4637659: START
    i := i + 1;
    l_processSQL(i) :=
	  'SET (  PRIM_AMOUNT_G, COMMITTED_AMOUNT_PRIM, OBLIGATED_AMOUNT_PRIM';
    i := i + 1;
    l_processSQL(i) :=
	  '     , OTHER_AMOUNT_PRIM, SEC_AMOUNT_G, LAST_UPDATE_DATE';
-- Bug fix 4637659: END
    i := i + 1;
    l_processSQL(i) := '     , LAST_UPDATED_BY, LAST_UPDATE_LOGIN) = ';

    -- SELECT clause
    l_process_step := 'BUILD_UPDATE_SQL_SELECT';
    -- COLUMN: PRIM_AMOUNT_G
    i := i + 1;
    l_processSQL(i) :=
      '(SELECT  NVL(g.prim_amount_g, 0) + r.primary_difference';

-- Bug fix 4637659: START
    -- COLUMN: COMMITTED_AMOUNT_PRIM
    i := i + 1;
    l_processSQL(i) :=
      '       , NVL(g.committed_amount_prim, 0) + r.committed_amt_pri_diff';

    -- COLUMN: OBLIGATED_AMOUNT_PRIM
    i := i + 1;
    l_processSQL(i) :=
      '       , NVL(g.obligated_amount_prim, 0) + r.obligated_amt_pri_diff';

    -- COLUMN: OTHER_AMOUNT_PRIM
    i := i + 1;
    l_processSQL(i) :=
      '       , NVL(g.other_amount_prim, 0) + r.other_amt_pri_diff';
-- Bug fix 4637659: END

    -- COLUMN: SEC_AMOUNT_G
    i := i + 1;
    l_processSQL(i) :=
      '       , NVL(g.sec_amount_g, 0) + r.secondary_difference';

    -- COLUMNS: LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
    i := i + 1;
    l_processSQL(i) := '       , sysdate, :user_id1, :user_id2';

    -- SELECT FROM clause
    l_process_step := 'BUILD_UPDATE_SQL_FROM';
    i := i + 1;
    l_processSQL(i) := ' FROM FII_RECONV_GL_ROLLUP_GT r';

    -- SELECT WHERE clauses
    l_process_step := 'BUILD_UPDATE_SQL_WHERE1';
    i := i + 1;
    l_processSQL(i) := ' WHERE r.time_id = g.time_id';
    i := i + 1;
    l_processSQL(i) := ' AND r.chart_of_accounts_id = g.chart_of_accounts_id';

    i := i + 1;
    IF (l_use_id_columns)
    THEN
      l_processSQL(i) := ' AND r.cost_center_id = g.cost_center_id';
      i := i + 1;
      l_processSQL(i) := ' AND r.fin_category_id = g.fin_category_id';
      i := i + 1;
      l_processSQL(i) := ' AND r.company_id = g.company_id';
    ELSE
      l_processSQL(i) := ' AND r.cost_center = g.cost_center';
      i := i + 1;
      l_processSQL(i) := ' AND r.natural_account = g.natural_account';
      i := i + 1;
      l_processSQL(i) := ' AND r.company = g.company';
    END IF;

    i := i + 1;
    l_processSQL(i) := ' AND r.je_source = g.je_source';
    i := i + 1;
    l_processSQL(i) := ' AND r.je_category = g.je_category';
    i := i + 1;
    l_processSQL(i) := ' AND r.ledger_id = g.ledger_id';
-- Bug fix 4637659: START
    i := i + 1;
    l_processSQL(i) := ' AND r.period_type_id = g.period_type_id';
    i := i + 1;
    l_processSQL(i) := ' AND r.user_dim1_id = g.user_dim1_id';
    i := i + 1;
    l_processSQL(i) := ' AND r.user_dim2_id = g.user_dim2_id';
    i := i + 1;
    l_processSQL(i) := ' AND NVL(r.posted_date, to_date(''01/01/1950'', ''MM/DD/YYYY''))
      = NVL(g.posted_date, to_date(''01/01/1950'', ''MM/DD/YYYY''))';
-- Bug fix 4637659: END
    i := i + 1;
    l_processSQL(i) := ' AND r.prod_category_id = g.prod_category_id)';

    -- UPDATE WHERE clauses
    l_process_step := 'BUILD_UPDATE_SQL_WHERE2';
    i := i + 1;
    IF (l_use_id_columns)
    THEN
      l_processSQL(i) :=
        ' WHERE (  g.time_id, g.chart_of_accounts_id, g.cost_center_id';
      i := i + 1;
      l_processSQL(i) :=
        '        , g.fin_category_id, g.company_id, g.je_source';
    ELSE
      l_processSQL(i) :=
        ' WHERE (  g.time_id, g.chart_of_accounts_id, g.cost_center';
      i := i + 1;
      l_processSQL(i) :=
        '        , g.natural_account, g.company, g.je_source';
    END IF;
    i := i + 1;
-- Bug fix 4637659: START
    l_processSQL(i) :=
	  '        , g.je_category, g.ledger_id, g.period_type_id';
    i := i + 1;
    l_processSQL(i) :=
      '        , g.user_dim1_id, g.user_dim2_id, g.prod_category_id
        , NVL(g.posted_date, to_date(''01/01/1950'', ''MM/DD/YYYY'')))';
-- Bug fix 4637659: END

    i := i + 1;
    IF (l_use_id_columns)
    THEN
      l_processSQL(i) :=
        '  IN (SELECT  r2.time_id, r2.chart_of_accounts_id, r2.cost_center_id';
      i := i + 1;
      l_processSQL(i) :=
        '            , r2.fin_category_id, r2.company_id, r2.je_source';
    ELSE
      l_processSQL(i) :=
        '  IN (SELECT  r2.time_id, r2.chart_of_accounts_id, r2.cost_center';
      i := i + 1;
      l_processSQL(i) :=
        '            , r2.natural_account, r2.company, r2.je_source';
    END IF;

    i := i + 1;
-- Bug fix 4637659: START
    l_processSQL(i) :=
      '            , r2.je_category, r2.ledger_id, r2.period_type_id';
    i := i + 1;
    l_processSQL(i) :=
      '            , r2.user_dim1_id, r2.user_dim2_id, r2.prod_category_id
            , NVL(r2.posted_date, to_date(''01/01/1950'', ''MM/DD/YYYY''))';
-- Bug fix 4637659: END
    i := i + 1;
    l_processSQL(i) := '        FROM FII_RECONV_GL_ROLLUP_GT r2)';

    -- Print the dynamic SQL only when debug is on
    l_process_step := 'PRINT_UPDATE_SQL';
    FII_RECONVERSION_PKG.print_sql(
     'Update GL differences SQL:', l_processSQL, i);

    -- Open cursor
    l_process_step := 'OPEN_UPDATE_SQL';
    l_cursorID := DBMS_SQL.OPEN_CURSOR;

    -- Parse the SQL
    l_process_step := 'PARSE_UPDATE_SQL';
    DBMS_SQL.PARSE(l_cursorID,l_processSQL,1,i,TRUE,dbms_sql.native);

    -- Bind variables
    l_process_step := 'BIND_UPDATE_SQL';
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':user_id1', p_user_id);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':user_id2', p_user_id);

    -- Execute the SQL
    l_process_step := 'RUN_UPDATE_SQL';
    l_processed_rows := DBMS_SQL.EXECUTE(l_cursorID);
    COMMIT;
    FND_MESSAGE.set_name('FND', 'GENERIC_ROWS_PROCESSED');
    FND_MESSAGE.set_token('ROWS', l_processed_rows);
    FII_UTIL.put_timestamp(FND_MESSAGE.get);

    -- Close cursor
    l_process_step := 'CLOSE_UPDATE_SQL';
    DBMS_SQL.CLOSE_CURSOR(l_cursorID);

  END IF; -- IF (l_processed_rows > 0)
  -- LOG: Print out the number of updated rows for GL
  FII_UTIL.put_line(' ');
  l_message := FII_MESSAGE.get_message('FII_RECONV_UPDATED_ROWS', NULL,
                                       'NUM_ROWS', l_processed_rows,
                                       'PROD_NAME', p_product_name);
  FII_UTIL.put_line(l_message);

  --
  -- 3.6 This process completes successfully
  --
  l_process_step := 'EXIT_PROCESS';
  -- LOG: FII_RECONV_EXIT_PROCESS_STEP || time stamp
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                          'FII_RECONV_EXIT_PROCESS_STEP', NULL));
  FII_UTIL.debug_line('Process complete successfully');

  -- Commit changes to the database and print log messages
  FND_CONCURRENT.af_commit;
  -- Set the concurrent program completion status to COMPLETE
  l_return_val := FND_CONCURRENT.set_completion_status('COMPLETE', l_message);

  FII_RECONVERSION_PKG.func_succ(l_procedure_name);

EXCEPTION
  WHEN RECONV_ERROR THEN
    -- Process fails because of exceptions raised from other functions
    -- and we need to rollback
    FII_UTIL.debug_line('Proces errors out because of other functions'' error');
    -- Rollback
    FND_CONCURRENT.af_rollback;
    -- Print error messages to log file
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step);
    -- Set the concurrent program completion status to ERROR
    l_return_val := FND_CONCURRENT.set_completion_status('ERROR', NULL);
    -- Raise application error
    errbuf := sqlerrm;
    retcode := sqlcode;
    RAISE_APPLICATION_ERROR(-20050, errbuf);

  WHEN OTHERS THEN
    -- Process fails because of other exceptions and we need to rollback
    FII_UTIL.debug_line('Proces errors out because of other exception');
    -- Rollback
    FND_CONCURRENT.af_rollback;
    -- Print error messages to log file
    errbuf := sqlerrm;
    retcode := sqlcode;
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, errbuf);
    -- Set the concurrent program completion status to ERROR
    l_return_val := FND_CONCURRENT.set_completion_status('ERROR', NULL);
    -- Raise application error
    RAISE_APPLICATION_ERROR(-20060, errbuf);

END reconvert_gl;


-- PROCEDURE
--   reconvert_ap()
--
-- DESCRIPTION:
--   It will reconvert global amounts for the AP base table FII_AP_INV_B.
PROCEDURE reconvert_ap(  errbuf               IN OUT NOCOPY VARCHAR2
                       , retcode              IN OUT NOCOPY VARCHAR2
                       , p_request_id         IN NUMBER
                       , p_user_id            IN NUMBER
                       , p_product_name       IN VARCHAR2
                       , p_primary_currency   IN VARCHAR2
                       , p_primary_mau        IN NUMBER
                       , p_secondary_currency IN VARCHAR2
                       , p_secondary_mau      IN NUMBER
                       , p_from_date_id       IN NUMBER
                       , p_to_date_id         IN NUMBER
                       , p_log_filename       IN VARCHAR2
                       , p_output_filename    IN VARCHAR2
                      ) IS
  l_processed_rows NUMBER := 0;
  l_message        VARCHAR2(255);
  l_return_val     BOOLEAN := FALSE;

  l_process_step   VARCHAR2(50) := 'INIT_RECONV_AP';
  l_procedure_name VARCHAR2(30) := 'reconvert_ap';
BEGIN
  --
  -- 4.1 Initialize the logging for this child request
  --
  FII_UTIL.initialize(p_log_filename || '_AP.log',
                      p_output_filename || '_AP.out',
                      NULL, 'FII_RECONVERSION_PKG');
  FII_UTIL.put_line(' ');
  -- LOG: Function enter
  FII_RECONVERSION_PKG.func_enter(l_procedure_name);
  -- LOG: FII_RECONV_INIT_STEP || time stamp
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message('FII_RECONV_INIT_STEP', NULL));
  -- LOG: State debug mode is on if it does
  FII_UTIL.debug_line('This process is running in debug mode');

  -- LOG: FII_RECONV_RECONVERT_AMT_STEP || time stamp for AP
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                            'FII_RECONV_RECONVERT_AMT_STEP', NULL
                          , 'PROD_NAME', p_product_name));

  --
  -- 4.2 Update FII_AP_INV_B for the newly different reconverted global amounts
  --
  l_process_step := 'UPDATE_AP_B';
  UPDATE /*+ parallel(ap) */ FII_AP_INV_B ap
  SET (  PRIM_AMOUNT_G, SEC_AMOUNT_G, LAST_UPDATE_DATE
       , LAST_UPDATED_BY, LAST_UPDATE_LOGIN) =
  (SELECT   DECODE(p_primary_currency, NULL, ap.prim_amount_g
             , ROUND((ap.amount_b*r.primary_rate)
                /p_primary_mau)*p_primary_mau)
          , DECODE(p_secondary_currency, NULL, ap.sec_amount_g
             , ROUND((ap.amount_b*r.secondary_rate)
                /p_secondary_mau)*p_secondary_mau)
          , sysdate, p_user_id, p_user_id
   FROM FII_RECONV_RATES r, GL_LEDGERS_PUBLIC_V sob
   WHERE r.request_id = p_request_id
   AND r.rate_date_id = ap.account_date_id
   AND r.from_currency = sob.currency_code
   AND sob.ledger_id = ap.ledger_id)
  WHERE ap.amount_b <> 0
  AND ap.account_date_id BETWEEN p_from_date_id AND p_to_date_id
  AND ( (p_primary_currency IS NOT NULL
          AND ap.prim_amount_g <>
              (SELECT ROUND((ap.amount_b*r2.primary_rate)
                       /p_primary_mau)*p_primary_mau
                 FROM FII_RECONV_RATES r2, GL_LEDGERS_PUBLIC_V sob2
                WHERE r2.request_id = p_request_id
                  AND r2.rate_date_id = ap.account_date_id
                  AND r2.from_currency = sob2.currency_code
                  AND sob2.ledger_id = ap.ledger_id))
     OR (p_secondary_currency IS NOT NULL
         AND ap.sec_amount_g <>
              (SELECT ROUND((ap.amount_b*r3.secondary_rate)
                       /p_secondary_mau)*p_secondary_mau
                 FROM FII_RECONV_RATES r3, GL_LEDGERS_PUBLIC_V sob3
                WHERE r3.request_id = p_request_id
                  AND r3.rate_date_id = ap.account_date_id
                  AND r3.from_currency = sob3.currency_code
                  AND sob3.ledger_id = ap.ledger_id)));
  l_processed_rows := SQL%ROWCOUNT;
  COMMIT;

  -- LOG: Print out the number of updated rows for AP
  l_message := FII_MESSAGE.get_message('FII_RECONV_UPDATED_ROWS', NULL,
                                       'NUM_ROWS', NVL(l_processed_rows, 0),
                                       'PROD_NAME', p_product_name);
  FII_UTIL.put_line(l_message);

  --
  -- 4.3 This process completes successfully
  --
  l_process_step := 'EXIT_PROCESS';
  -- LOG: FII_RECONV_EXIT_PROCESS_STEP || time stamp
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                          'FII_RECONV_EXIT_PROCESS_STEP', NULL));
  FII_UTIL.debug_line('Process complete successfully');

  -- Commit changes to the database and print log messages
  FND_CONCURRENT.af_commit;
  -- Set the concurrent program completion status to COMPLETE
  l_return_val := FND_CONCURRENT.set_completion_status('COMPLETE', l_message);

  FII_RECONVERSION_PKG.func_succ(l_procedure_name);

EXCEPTION
  WHEN OTHERS THEN
    -- Process fails because of other exceptions and we need to rollback
    FII_UTIL.debug_line('Proces errors out because of other exception');
    -- Rollback
    FND_CONCURRENT.af_rollback;
    -- Print error messages to log file
    errbuf := sqlerrm;
    retcode := sqlcode;
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, errbuf);
    -- Set the concurrent program completion status to ERROR
    l_return_val := FND_CONCURRENT.set_completion_status('ERROR', NULL);
    -- Raise application error
    RAISE_APPLICATION_ERROR(-20070, errbuf);

END reconvert_ap;


-- PROCEDURE
--   reconvert_ar()
--
-- DESCRIPTION:
--   It will reconvert global amounts for the AR base table FII_AR_REVENUE_B.
PROCEDURE reconvert_ar(  errbuf               IN OUT NOCOPY VARCHAR2
                       , retcode              IN OUT NOCOPY VARCHAR2
                       , p_request_id         IN NUMBER
                       , p_user_id            IN NUMBER
                       , p_product_name       IN VARCHAR2
                       , p_primary_currency   IN VARCHAR2
                       , p_primary_mau        IN NUMBER
                       , p_secondary_currency IN VARCHAR2
                       , p_secondary_mau      IN NUMBER
                       , p_from_date_id       IN NUMBER
                       , p_to_date_id         IN NUMBER
                       , p_log_filename       IN VARCHAR2
                       , p_output_filename    IN VARCHAR2
                      ) IS
  l_processed_rows NUMBER := 0;
  l_message        VARCHAR2(255);
  l_return_val     BOOLEAN := FALSE;

  l_process_step   VARCHAR2(50) := 'INIT_LOG_UTIL';
  l_procedure_name VARCHAR2(30) := 'reconvert_ar';
BEGIN
  --
  -- 5.1 Initialize the logging for this child request
  --
  FII_UTIL.initialize(p_log_filename || '_AR.log',
                      p_output_filename || '_AR.out',
                      NULL, 'FII_RECONVERSION_PKG');
  FII_UTIL.put_line(' ');
  -- LOG: Function enter
  FII_RECONVERSION_PKG.func_enter(l_procedure_name);
  -- LOG: FII_RECONV_INIT_STEP || time stamp
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message('FII_RECONV_INIT_STEP', NULL));
  -- LOG: State debug mode is on if it does
  FII_UTIL.debug_line('This process is running in debug mode');
  -- LOG: FII_RECONV_RECONVERT_AMT_STEP || time stamp for AR
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                            'FII_RECONV_RECONVERT_AMT_STEP', NULL
                          , 'PROD_NAME', p_product_name));

  --
  -- 5.2 Update FII_AR_REVENUE_B for the different reconverted global amounts
  --
  l_process_step := 'UPDATE_AR_B';
  UPDATE /*+ parallel(ar) */ FII_AR_REVENUE_B ar
  SET (  PRIM_AMOUNT_G, SEC_AMOUNT_G, LAST_UPDATE_DATE
       , LAST_UPDATED_BY, LAST_UPDATE_LOGIN) =
  (SELECT   DECODE(p_primary_currency, NULL, ar.prim_amount_g
             , ROUND((ar.amount_b*r.primary_rate)
                /p_primary_mau)*p_primary_mau)
          , DECODE(p_secondary_currency, NULL, ar.sec_amount_g
             , ROUND((ar.amount_b*r.secondary_rate)
                /p_secondary_mau)*p_secondary_mau)
          , sysdate, p_user_id, p_user_id
   FROM FII_RECONV_RATES r
   WHERE r.request_id = p_request_id
   AND r.rate_date_id = ar.gl_date_id
   AND r.from_currency = ar.functional_currency
  )
  WHERE ar.amount_b <> 0
  AND ar.gl_date_id BETWEEN p_from_date_id AND p_to_date_id
  AND ( (p_primary_currency IS NOT NULL
         AND ar.prim_amount_g <>
              (SELECT ROUND((ar.amount_b*r2.primary_rate)
                       /p_primary_mau)*p_primary_mau
                 FROM FII_RECONV_RATES r2
                WHERE r2.request_id = p_request_id
                  AND r2.rate_date_id = ar.gl_date_id
                  AND r2.from_currency = ar.functional_currency))
     OR (p_secondary_currency IS NOT NULL
         AND ar.sec_amount_g <>
              (SELECT ROUND((ar.amount_b*r3.secondary_rate)
                       /p_secondary_mau)*p_secondary_mau
                 FROM FII_RECONV_RATES r3
                WHERE r3.request_id = p_request_id
                  AND r3.rate_date_id = ar.gl_date_id
                  AND r3.from_currency = ar.functional_currency)));
  l_processed_rows := SQL%ROWCOUNT;
  COMMIT;

  -- LOG: Print out the number of updated rows for AR
  l_message := FII_MESSAGE.get_message('FII_RECONV_UPDATED_ROWS', NULL,
                                       'NUM_ROWS', NVL(l_processed_rows, 0),
                                       'PROD_NAME', p_product_name);
  FII_UTIL.put_line(l_message);

  --
  -- 4.3 This process completes successfully
  --
  l_process_step := 'EXIT_PROCESS';
  -- LOG: FII_RECONV_EXIT_PROCESS_STEP || time stamp
  FII_UTIL.put_line(' ');
  FII_UTIL.put_timestamp(FII_MESSAGE.get_message(
                          'FII_RECONV_EXIT_PROCESS_STEP', NULL));
  FII_UTIL.debug_line('Process complete successfully');

  -- Commit changes to the database and print log messages
  FND_CONCURRENT.af_commit;
  -- Set the concurrent program completion status to COMPLETE
  l_return_val := FND_CONCURRENT.set_completion_status('COMPLETE', l_message);

  FII_RECONVERSION_PKG.func_succ(l_procedure_name);

EXCEPTION
  WHEN OTHERS THEN
    -- Process fails because of other exceptions and we need to rollback
    FII_UTIL.debug_line('Proces errors out because of other exception');
    -- Rollback
    FND_CONCURRENT.af_rollback;
    -- Print error messages to log file
    errbuf := sqlerrm;
    retcode := sqlcode;
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, errbuf);
    -- Set the concurrent program completion status to ERROR
    l_return_val := FND_CONCURRENT.set_completion_status('ERROR', NULL);
    -- Raise application error
    RAISE_APPLICATION_ERROR(-20080, errbuf);

END reconvert_ar;


-- PROCEDURE
--   print_report()
--
-- DESCRIPTION:
--   It will print the execution report for different modes. For ERROR mode, it
--   will list all the missing/invalid rates and proper error messages. For
--   SUCCESS mode, it will list all the cached rates and the number of rows
--   updated for each base table.
--
--   It will return TRUE when the execution report is generated successfuly.
--   Otherwise, it return FALSE.
PROCEDURE print_report(  p_request_id          IN NUMBER
                       , p_transaction_type    IN VARCHAR2
                       , p_currency_type       IN VARCHAR2
                       , p_primary_rate_type   IN VARCHAR2
                       , p_secondary_rate_type IN VARCHAR2
                       , p_from_date           IN VARCHAR2
                       , p_to_date             IN VARCHAR2
                       , p_primary_currency    IN VARCHAR2
                       , p_secondary_currency  IN VARCHAR2
                       , p_cache_rate_status   IN VARCHAR2
                       , p_completion_status   IN VARCHAR2
                      ) IS
  CURSOR c_mrate_lines IS
    SELECT RPAD(sob_curr, 15, ' ')
            || '  ' || RPAD(global_curr, 15, ' ')
            || '  ' || TO_CHAR(rate_date, 'DD-MON-YYYY') line_text
    FROM (SELECT   from_currency sob_curr
                 , p_primary_currency global_curr
                 , rate_date
            FROM FII_RECONV_RATES
           WHERE p_primary_currency IS NOT NULL
             AND request_id = p_request_id
             AND primary_rate <= 0
          UNION
          SELECT   from_currency sob_curr
                 , p_secondary_currency global_curr
                 , rate_date
            FROM FII_RECONV_RATES
           WHERE p_secondary_currency IS NOT NULL
             AND request_id = p_request_id
             AND secondary_rate <= 0) Q
    ORDER BY sob_curr, global_curr, rate_date;

  CURSOR c_crate_lines IS
    SELECT RPAD(from_currency, 15, ' ')
            || '  ' || TO_CHAR(rate_date, 'DD-MON-YYYY')
            || '  ' || LPAD(DECODE(SIGN(primary_rate), +1
                             , TO_CHAR(  ROUND(primary_rate, 15)
                                       , 'FM999999D999999999999999')
                             , ' '), 22 , ' ')
            || '  ' || LPAD(DECODE(SIGN(secondary_rate), +1
                             , TO_CHAR(  ROUND(secondary_rate, 15)
                                       , 'FM999999D999999999999999')
                             , ' '), 22, ' ') line_text
    FROM FII_RECONV_RATES
    WHERE request_id = p_request_id
    AND (NVL(primary_rate, -1) > 0 OR NVL(secondary_rate, -1) > 0)
    ORDER BY from_currency, rate_date;

  l_print_common_msg BOOLEAN       := TRUE;
  l_line_text        VARCHAR2(140) := NULL;
  l_page_count       NUMBER        := 1;
  l_line_count       NUMBER        := 1;

  l_process_step     VARCHAR2(50)  := 'PRINT_REPORT_HDR';
  l_procedure_name   VARCHAR2(30)  := 'print_report';
BEGIN
  FII_RECONVERSION_PKG.func_enter(l_procedure_name);

  --
  -- 6.1 Print the report header
  --
  FII_RECONVERSION_PKG.print_report_hdr(l_line_count, l_page_count);

  --
  -- 6.2 List the passed IN parameters
  --
  l_process_step := 'PRINT_IN_PARAMS';
  FND_FILE.new_line(FND_FILE.output, 1);
  FII_MESSAGE.write_output(  'FII_RECONV_TRX_TYPE_PARAM_P', 1
                           , 'P_VALUE', p_transaction_type);
  FII_MESSAGE.write_output(  'FII_RECONV_CURR_TYPE_PARAM_P', 1
                           , 'P_VALUE', p_currency_type);
  FII_MESSAGE.write_output(  'FII_RECONV_PRI_RTYPE_PARAM_P', 1
                           , 'P_VALUE', p_primary_rate_type);
  FII_MESSAGE.write_output(  'FII_RECONV_SEC_RTYPE_PARAM_P', 1
                           , 'P_VALUE', p_secondary_rate_type);
  FII_MESSAGE.write_output(  'FII_RECONV_FROM_DATE_PARAM_P', 1
                           , 'P_VALUE', p_from_date);
  FII_MESSAGE.write_output('FII_RECONV_TO_DATE_PARAM_P', 1
                           , 'P_VALUE', p_to_date);
  l_line_count := l_line_count + 7;

  --
  -- 6.3 Print report content
  --
  IF (p_cache_rate_status = 'N')
  THEN
    -- There are no transactions selected for reconversion
    l_process_step := 'PRINT_NO_TRX_MSG';
    FND_FILE.new_line(FND_FILE.output, 1);
    -- Print to report
    FII_MESSAGE.write_output('FII_RECONV_NO_TRANSACTIONS');
    l_line_count := l_line_count + 2;

  ELSE
    -- There are transactions selected for reconversion

    -- Check if it needs to list out the missing rates
    IF (p_cache_rate_status = 'M')
    THEN
      -- THere are missing rates, so list missing rates

      -- Print the error message
      l_process_step := 'PRINT_MRATE_MSG';
      FND_FILE.new_line(FND_FILE.output, 1);
      FII_MESSAGE.write_output('FII_RECONV_MISSING_RATES');
      FND_FILE.new_line(FND_FILE.output, 1);
      FII_MESSAGE.write_output('FII_RECONV_MRATE_LIST_PROMPT');
      l_line_count := l_line_count + 4;

      -- Print Missing Rates table header
      l_process_step := 'PRINT_MTABLE_HDR';
      FII_RECONVERSION_PKG.print_mtable_hdr(l_line_count);

      -- List SOB Currency, Global Currency, and Rate Date for missing rates

      -- Open c_mrate_lines cursor
      l_process_step := 'OPEN_MRATE_CURSOR';
      OPEN c_mrate_lines;

      -- Print each fetched line to report
      l_process_step := 'PRINT_MRATE_LINES';
      LOOP
        FETCH c_mrate_lines INTO l_line_text;
        EXIT WHEN c_mrate_lines%NOTFOUND;

        IF (l_line_count = 1)
        THEN
          FII_RECONVERSION_PKG.print_report_hdr(l_line_count, l_page_count);
          FII_RECONVERSION_PKG.print_mtable_hdr(l_line_count);
        END IF;

        FND_FILE.put_line(FND_FILE.output, l_line_text);
        l_line_count := l_line_count + 1;

        IF (l_line_count >= g_page_line_no - 2)
        THEN
          l_line_count := 1;
          l_page_count := l_page_count + 1;
          FND_FILE.new_line(FND_FILE.output, 2);
        END IF;

      END LOOP; -- c_mrate_lines cursor loop

      -- Close c_mrate_lines cursor
      l_process_step := 'CLOSE_MRATE_CURSOR';
      CLOSE c_mrate_lines;

    ELSE
      -- All rates are cached
      l_process_step := 'PRINT_CRATE_MSG';
      FND_FILE.new_line(FND_FILE.output, 1);
      IF (p_completion_status = 'S')
      THEN
        FII_MESSAGE.write_output('FII_RECONV_RECONVERT_SUCCESS');
      ELSE
        FII_MESSAGE.write_output('FII_RECONV_PROCESS_FAIL');
      END IF; -- IF (p_completion_status = 'N')
      l_line_count := l_line_count + 2;

    END IF; -- IF (p_cache_rate_status = 'M')

    -- Print cached rates

    -- Open c_crate_lines cursor
    l_process_step := 'OPEN_CRATE_CURSOR';
    OPEN c_crate_lines;

    -- Print each fetched cached rate line to report
    l_process_step := 'PRINT_CRATE_LINES';
    LOOP
      FETCH c_crate_lines INTO l_line_text;
      EXIT WHEN c_crate_lines%NOTFOUND;

      -- Only print the common msg for the first line
      IF (l_print_common_msg)
      THEN
        -- Print common message
        FND_FILE.new_line(FND_FILE.output, 1);
        FII_MESSAGE.write_output('FII_RECONV_CRATE_LIST_PROMPT');
        l_line_count := l_line_count + 2;

        -- Print Cached Rates table header
        FII_RECONVERSION_PKG.print_ctable_hdr(l_line_count);

        -- Set it to FALSE such that it won't print these again
        l_print_common_msg := FALSE;
      END IF; -- IF (l_print_common_msg)

      IF (l_line_count = 1)
      THEN
        FII_RECONVERSION_PKG.print_report_hdr(l_line_count, l_page_count);
        FII_RECONVERSION_PKG.print_ctable_hdr(l_line_count);
      END IF;

      FND_FILE.put_line(FND_FILE.output, l_line_text);
      l_line_count := l_line_count + 1;

      IF (l_line_count >= g_page_line_no - 2)
      THEN
        l_line_count := 1;
        l_page_count := l_page_count + 1;
        FND_FILE.new_line(FND_FILE.output, 2);
      END IF;
    END LOOP; -- c_crate_lines cursor loop

    -- Close c_crate_lines cursor
    l_process_step := 'CLOSE_CRATE_CURSOR';
    CLOSE c_crate_lines;

  END IF; -- IF (p_cache_rate_status = 'N')

  FII_RECONVERSION_PKG.func_succ(l_procedure_name);
EXCEPTION
  WHEN RECONV_ERROR THEN
    -- Print error code and messages to log file and raise error
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step);
    -- Raise RECONV_ERROR which will be handled in reconvert_amounts()
    RAISE RECONV_ERROR;

  WHEN OTHERS THEN
    -- Print error code and messages to log file and raise error
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, sqlerrm);
    -- Raise RECONV_ERROR which will be handled in reconvert_amounts()
    RAISE RECONV_ERROR;

END print_report;

-- PROCEDURE
--   print_report_hdr()
--
-- PARAMETERS:
--   None
--
-- DESCRIPTION:
--   It will print the report header.
PROCEDURE print_report_hdr (  p_line_count IN OUT NOCOPY NUMBER
                            , p_page_count IN            NUMBER) IS
  l_message        VARCHAR2(200);
  l_line_text      VARCHAR2(200);

  l_process_step   VARCHAR2(50) := 'APPEND_CURRENT_DATE';
  l_procedure_name VARCHAR2(30) := 'print_report_hdr';
BEGIN
  FII_RECONVERSION_PKG.func_enter(l_procedure_name);

  -- 6.1.1 Print 1 blank line
  FND_FILE.new_line(FND_FILE.output, 1);

  -- 6.1.2 Print 1 report header line

  -- Set the line starting with the report date (i.e. current date)
  l_message := FND_MESSAGE.get_string('FND', 'DATE') || ': '
                || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MM:SS');
  l_line_text := RPAD(l_message, 36, ' ');

  -- Append report title
  l_process_step := 'APPEND_TITLE';
  l_message := FND_MESSAGE.get_string('FII', 'FII_RECONV_REPORT_TITLE');
  l_line_text := l_line_text || LPAD(l_message, 48, ' ');

  -- Append page number
  l_process_step := 'APPEND_PAGE_NUMBER';
  l_message := FII_MESSAGE.get_message(  'FII_RECONV_PAGE_PROMPT', NULL
                                       , 'P_NUM', p_page_count);
  l_line_text := l_line_text || LPAD(l_message, 49, ' ');

  -- Print the header line
  l_process_step := 'PRINT_HEADER_LINE';
  FND_FILE.put_line(FND_FILE.output, l_line_text);

  -- Added 2 more lines
  p_line_count := p_line_count + 2;

  FII_RECONVERSION_PKG.func_succ(l_procedure_name);
EXCEPTION
  WHEN OTHERS THEN
    -- Print error code and messages to log file and raise error
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, sqlerrm);
    -- Raise RECONV_ERROR which will be handled in reconvert_amounts()
    RAISE RECONV_ERROR;

END print_report_hdr;


-- PROCEDURE
--   print_mtable_hdr()
--
-- PARAMETERS:
--   None
--
-- DESCRIPTION:
--   It will print the missing conversion rate table header.
PROCEDURE print_mtable_hdr (p_line_count IN OUT NOCOPY NUMBER) IS
  l_process_step   VARCHAR2(50) := 'PRINT_MISSING_RATES_HDR';
  l_procedure_name VARCHAR2(30) := 'print_mtable_hdr';
BEGIN
  FII_RECONVERSION_PKG.func_enter(l_procedure_name);

  -- 6.3.1 Print 1 blank line
  FND_FILE.new_line(FND_FILE.output, 1);
  -- 6.3.2 Print missing rate table column header
  FII_MESSAGE.write_output('FII_RECONV_MTABLE_COLS');
  -- 6.3.3 Print missing rate table column line header
  FII_MESSAGE.write_output('FII_RECONV_MTABLE_COL_LINE');
  p_line_count := p_line_count + 3;

  FII_RECONVERSION_PKG.func_succ(l_procedure_name);
EXCEPTION
  WHEN OTHERS THEN
    -- Print error code and messages to log file and raise error
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, sqlerrm);
    -- Raise RECONV_ERROR which will be handled in reconvert_amounts()
    RAISE RECONV_ERROR;

END print_mtable_hdr;


-- PROCEDURE
--   print_ctable_hdr()
--
-- PARAMETERS:
--   None
--
-- DESCRIPTION:
--   It will print the cached conversion rate table header.
PROCEDURE print_ctable_hdr (p_line_count IN OUT NOCOPY NUMBER) IS
  l_process_step   VARCHAR2(50) := 'PRINT_CACHED_RATES_HDR';
  l_procedure_name VARCHAR2(30) := 'print_ctable_hdr';
BEGIN
  FII_RECONVERSION_PKG.func_enter(l_procedure_name);

  -- 6.4.1 Print 1 blank line
  FND_FILE.new_line(FND_FILE.output, 1);
  -- 6.4.2 Print cached rate table column header
  FII_MESSAGE.write_output('FII_RECONV_CTABLE_COLS');
  -- 6.4.3 Print cached rate table column line header
  FII_MESSAGE.write_output('FII_RECONV_CTABLE_COL_LINE');
  p_line_count := p_line_count + 3;

  FII_RECONVERSION_PKG.func_succ(l_procedure_name);
EXCEPTION
  WHEN OTHERS THEN
    -- Print error code and messages to log file and raise error
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, sqlerrm);
    -- Raise RECONV_ERROR which will be handled in reconvert_amounts()
    RAISE RECONV_ERROR;

END print_ctable_hdr;


-- PROCEDURE
--   print_sql()
--
-- DESCRIPTION:
--   It will print the passed SQL statement to log file.
PROCEDURE print_sql(  p_sql_desc     IN VARCHAR2
                    , p_sql_stmt     IN DBMS_SQL.VARCHAR2S
                    , p_num_of_lines IN NUMBER) IS
  i NUMBER;

  l_process_step   VARCHAR2(50) := 'PRINT_BUILT_SQL';
  l_procedure_name VARCHAR2(30) := 'print_sql';
BEGIN
  FII_UTIL.debug_line(' ');
  FII_UTIL.debug_line(p_sql_desc);
  FOR i IN 1..p_num_of_lines
  LOOP
    FII_UTIL.debug_line(p_sql_stmt(i));
  END LOOP;
  FII_UTIL.debug_line(' ');
EXCEPTION
  WHEN OTHERS THEN
    -- Print error code and messages to log file and raise error
    FII_RECONVERSION_PKG.func_fail(l_procedure_name, l_process_step, sqlerrm);
    -- Raise RECONV_ERROR which will be handled in reconvert_amounts()
    RAISE RECONV_ERROR;

END print_sql;

-- PROCEDURE
--   func_enter()
--
-- DESCRIPTION:
--   It will print some customerized output to log and then call
--   FII_MESSAGE.func_enter() to print standard output for entering function
PROCEDURE func_enter(p_func_name IN VARCHAR2) IS
BEGIN
  FII_UTIL.put_line(' ');
  FII_MESSAGE.func_ent(p_func_name);
END func_enter;


-- PROCEDURE
--   func_succ()
--
-- DESCRIPTION:
--   It will print some customerized output to log and then call
--   FII_MESSAGE.func_succ() to print standard output for exiting function
--   successfully
PROCEDURE func_succ(p_func_name IN VARCHAR2) IS
BEGIN
  FII_MESSAGE.func_succ(p_func_name);
  FII_UTIL.put_line(' ');
END func_succ;


-- PROCEDURE
--   func_fail()
--
-- DESCRIPTION:
--   It will print some additional output/error message to log and then call
--   FII_MESSAGE.func_fail() to print standard output for exiting function with
--   error
PROCEDURE func_fail(  p_func_name  IN VARCHAR2
                    , p_debug_step IN VARCHAR2
                    , p_err_msg    IN VARCHAR2) IS
BEGIN
  -- Print the debug step when it's in debug mode
  FII_UTIL.debug_line(' ');
  FII_UTIL.debug_line('Raise error while ' || p_debug_step);

  -- Print the error message
  FII_UTIL.put_line(' ');
  FII_UTIL.put_line(FII_MESSAGE.get_message(
                       'FII_ERR_ENC_ROUT', NULL
                     , 'ROUTINE_NAME', p_func_name || '()'));
  IF (p_err_msg IS NOT NULL)
  THEN
    FII_UTIL.put_line(p_err_msg);
  END IF;
  FII_UTIL.put_line(' ');

  -- Print the standard output
  FII_MESSAGE.func_fail(p_func_name);
  FII_UTIL.put_line(' ');
END func_fail;

END FII_RECONVERSION_PKG;

/
