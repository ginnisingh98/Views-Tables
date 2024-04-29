--------------------------------------------------------
--  DDL for Package Body JA_ZZ_INVOICE_CREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_ZZ_INVOICE_CREATE" AS
/* $Header: jazzricb.pls 120.6 2005/10/30 01:48:14 appldev ship $ */

-- pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

-----------------------------------------------------------------------------
--   PRIVATE FUNCTIONS/PROCEDURES ** FORWARD DECLARATION **                --
-----------------------------------------------------------------------------
  FUNCTION val_interface_lines(
             p_request_id             IN NUMBER
           , p_trx_header_id          IN NUMBER
           , p_trx_line_id            IN NUMBER
           , p_customer_trx_id        IN NUMBER
           , p_cust_trx_type_id       IN NUMBER
           , p_trx_date               IN DATE) RETURN BOOLEAN;

  FUNCTION ja_tw_validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER;

  FUNCTION ja_th_validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER;

-----------------------------------------------------------------------------
--   PUBLIC FUNCTIONS/PROCEDURES                                           --
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- FUNCTION                                                                --
--    validate_gdff                                                        --
--                                                                         --
-- PARAMETERS                                                              --
--   INPUT                                                                 --
--      p_request_id         Number   -- Concurrent Request_id             --
--                                                                         --
-- RETURNS                                                                 --
--      0                    Number   -- Validation Fails, if there is any --
--                                       exceptional case which is handled --
--                                       in WHEN OTHERS                    --
--      1                    Number   -- Validation Succeeds               --
--                                                                         --
-----------------------------------------------------------------------------

 t_interface_line_tbl    R_interface_line;
 t_interface_line_tbl1   R_interface_line1;


  FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER IS

    l_request_id     NUMBER;
    l_return_code    NUMBER(1);
    l_country_code   VARCHAR2(2);
    pg_debug         VARCHAR2(1);

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    ------------------------------------------------------------
    -- Let's assume everything is OK                          --
    ------------------------------------------------------------
    l_request_id := p_request_id;

    l_return_code := 1;

    l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');

    IF l_country_code = 'TW' THEN
      l_return_code := ja_tw_validate_gdff(l_request_id);
    ELSIF l_country_code = 'TH' THEN
      l_return_code := ja_th_validate_gdff(l_request_id);
    END IF;

    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('Return value from ja_zz_invoice_create.'
                       ||'validate_gdff() = '||TO_CHAR(l_return_code));
    END IF;

    RETURN l_return_code;

  EXCEPTION
    WHEN OTHERS THEN

    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('-- Return From Exception when others');
      ar_invoice_utils.debug('-- Return Code: 0');
      ar_invoice_utils.debug('ja_zz_invoice_create.validate_gdff()-');
    END IF;

      RETURN 0;

  END validate_gdff;

--
-- Validation for TAIWAN
--

-----------------------------------------------------------------------------
--   ** Private ** Private ** Private ** Private ** Private ** Private **  --
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- FUNCTION                                                                --
--    ja_tw_validate_gdff                                               --
--                                                                         --
-- PARAMETERS                                                              --
--   INPUT                                                                 --
--      p_request_id   Number   -- Concurrent Request_id                   --
--                                                                         --
--   RETURNS                                                               --
--      0              Number   -- Validation Fails, if there is any       --
--                                 exceptional case which is handled       --
--                                 in WHEN OTHERS                          --
--      1              Number   -- Validation Succeeds                     --
--                                                                         --
-----------------------------------------------------------------------------
  FUNCTION ja_tw_validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER IS

    l_return_code    NUMBER(1);
    l_country_code   VARCHAR2(2);
    l_index          binary_integer;
    pg_debug         VARCHAR2(1);

    CURSOR c_trx_lines (c_request_id NUMBER) IS
    SELECT header.trx_header_id
         , lines.trx_line_id
         , lines.customer_trx_id
         , header.cust_trx_type_id
         , header.trx_date
         , lines.vat_tax_id
         , lines.line_type
      FROM
           ar_trx_lines_gt      lines,
           ar_trx_header_gt     header,
           ra_batch_sources_all rbs
     WHERE
           lines.request_id = c_request_id
       AND lines.customer_trx_id IS NOT NULL
       AND header.trx_header_id = lines.trx_header_id
       AND header.batch_source_id = rbs.batch_source_id
     ORDER BY header.trx_date;

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

  --
  -- Let's assume everything is OK
  --
    l_return_code := 1;


      -------------------------------------------------------
      -- Validate all the rows for this concurrent request --
      -------------------------------------------------------

      OPEN c_trx_lines(p_request_id);

      LOOP

        Fetch c_trx_lines BULK COLLECT INTO
          t_interface_line_tbl.trx_header_id,
          t_interface_line_tbl.trx_line_id,
          t_interface_line_tbl.customer_trx_id,
          t_interface_line_tbl.cust_trx_type_id,
          t_interface_line_tbl.trx_date,
          t_interface_line_tbl.vat_tax_id,
          t_interface_line_tbl.line_type;

      EXIT WHEN c_trx_lines%NOTFOUND;

      END LOOP;

      CLOSE c_trx_lines;

      FOR l_index IN 1..t_interface_line_tbl.trx_line_id.LAST
      LOOP

      IF NOT val_interface_lines(
               p_request_id
             , t_interface_line_tbl.trx_header_id(l_index)
             , t_interface_line_tbl.trx_line_id(l_index)
             , t_interface_line_tbl.customer_trx_id(l_index)
             , t_interface_line_tbl.cust_trx_type_id(l_index)
             , t_interface_line_tbl.trx_date(l_index))
      THEN
        IF pg_debug = 'Y' THEN
          ar_invoice_utils.debug('-- ja_tw_validate_gdff.'
                           ||'val_interface_lines routine failed');
        END IF;

        l_return_code := 0;
      END IF;
      END LOOP;

    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('Return value from ja_tw_validate_gdff.'
                       ||'ja_tw_validate_gdff() = '||TO_CHAR(l_return_code));
    END IF;

    RETURN l_return_code;

  EXCEPTION
    WHEN OTHERS THEN

    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('-- Return From Exception when others');
      ar_invoice_utils.debug('-- Return Code: 0');
      ar_invoice_utils.debug('ja_zz_invoice_create.ja_tw_validate_gdff()-');
    END IF;

      RETURN 0;

  END ja_tw_validate_gdff ;

-------------------------------------------------------------------------------
--    ** Private ** Private ** Private ** Private ** Private ** Private **   --
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- PRIBATE FUNCTION                                                          --
--    val_interface_lines                                                    --
--                                                                           --
-- PARAMETERS                                                                --
--   INPUT                                                                   --
--      p_request_id             NUMBER       -- Transaction Source ID       --
--      p_trx_header_id          NUMBER       -- Trasaction Header ID        --
--      p_trx_line_id            NUMBER       -- Trasaction Line ID          --
--      p_cust_trx_type_id       NUMBER       -- Transaction Type            --
--      p_trx_date               DATE         -- Transaction Date            --
--                                                                           --
-- RETURNS                                                                   --
--      TRUE/FALSE               BOOLEAN                                     --
--                                                                           --
-------------------------------------------------------------------------------
  FUNCTION val_interface_lines(
             p_request_id              IN NUMBER
           , p_trx_header_id           IN NUMBER
           , p_trx_line_id             IN NUMBER
           , p_customer_trx_id         IN NUMBER
           , p_cust_trx_type_id        IN NUMBER
           , p_trx_date                IN DATE) RETURN BOOLEAN IS

    not_inv_class       EXCEPTION;
    auto_trx_num_no     EXCEPTION;
    fatal_error         EXCEPTION;
    l_exception_name    VARCHAR2(10);
    l_message_text      VARCHAR2(240);
    l_val_status        VARCHAR2(10); -- SUCCESS,FAIL,or FATAL
    l_cust_trx_type_id  NUMBER;
    l_trx_header_id     NUMBER;
    l_trx_line_id       NUMBER;
    l_customer_trx_id   NUMBER;
    l_trx_date          DATE;
    l_invalid_value     VARCHAR2(240);
    l_batch_source_id   NUMBER;
    l_auto_trx_num_flag VARCHAR2(1);
    l_inv_word          VARCHAR2(2);
    l_init_trx_num      VARCHAR2(8);
    l_fin_trx_num       VARCHAR2(8);
    l_last_trx_date     VARCHAR2(30);
    l_adv_days          NUMBER;
    l_gui_type          VARCHAR2(2);
    l_inv_class         VARCHAR2(20);

    l_debug_loc         VARCHAR2(100);

    pg_debug            VARCHAR2(1);

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    l_cust_trx_type_id  := p_cust_trx_type_id;
    l_trx_header_id     := p_trx_header_id;
    l_trx_line_id       := p_trx_line_id;
    l_customer_trx_id   := p_customer_trx_id;
    l_trx_date          := p_trx_date;

  --
  -- Get the transaction type information
  --
    l_debug_loc := 'ja_zz_validate_invoice_gdf.get_trx_type_info';
    ja_zz_validate_invoice_gdf.get_trx_type_info(
                        l_cust_trx_type_id
                      , l_gui_type
                      , l_inv_class);
  --
  -- Get transaction source id
  --
    l_debug_loc := 'Get Transaction Source ID.';
    BEGIN
      SELECT TO_NUMBER(cr.argument3)
        INTO l_batch_source_id
        FROM fnd_concurrent_requests cr
       WHERE request_id = p_request_id;
    END;
  --
  -- Get the transaction source information
  --
    l_debug_loc := 'ja_zz_validate_invoice_gdf.get_trx_src_info';
    ja_zz_validate_invoice_gdf.get_trx_src_info(
                        l_batch_source_id
                      , l_auto_trx_num_flag
                      , l_inv_word
                      , l_init_trx_num
                      , l_fin_trx_num
                      , l_last_trx_date
                      , l_adv_days);

  --
  -- Exit when the invoice class is other than Invoice.
  --
    IF l_inv_class <> 'INV' THEN
      RAISE not_inv_class;
    END IF;
  --
  -- Exit when automatic trx numbering flag is 'No'.
  --
    IF l_auto_trx_num_flag = 'N' THEN
      RAISE auto_trx_num_no;
    END IF;
  --
  -- Check if Source and Type Relationship is defined.
  --
    l_debug_loc := 'ja_zz_validate_invoice_gdf.val_src_type_rel';
    IF ja_zz_validate_invoice_gdf.val_src_type_rel(
                           l_trx_header_id
                         , l_trx_line_id
                         , l_batch_source_id
                         , l_cust_trx_type_id
                         , 'RAXTRX') = 'FATAL'
    THEN
      RAISE fatal_error;
    END IF;
  --
  -- Check if transaction date is within valid range.
  --
    l_debug_loc := 'ja_zz_validate_invoice_gdf.val_trx_date';
    IF ja_zz_validate_invoice_gdf.val_trx_date(
                           l_trx_header_id
                         , l_trx_line_id
                         , l_batch_source_id
                         , l_trx_date
                         , l_last_trx_date
                         , l_adv_days
                         , 'RAXTRX') = 'FATAL'
    THEN
      RAISE fatal_error;
    END IF;
  --
  -- Check if transaction number is within valid range.
  --
    l_debug_loc := 'ja_zz_validate_invoice_gdf.val_trx_num';
    IF ja_zz_validate_invoice_gdf.val_trx_num(
                           l_trx_header_id
                         , l_trx_line_id
                         , l_batch_source_id
                         , l_fin_trx_num
                         , 'RAXTRX') = 'FATAL'
    THEN
      RAISE fatal_error;
    END IF;

  --
  -- Check if a transaction header has multiple tax codes..
  --
    l_debug_loc := 'ja_zz_validate_invoice_gdf.val_mixed_tax_codes';
    IF ja_zz_validate_invoice_gdf.val_mixed_tax_codes(
                           l_trx_header_id
                         , l_trx_line_id
                         , l_customer_trx_id
                         , 'RAXTRX') = 'FATAL'
    THEN
      RAISE fatal_error;
    END IF;

  --
  -- Copy GUI Type of the transaction type to GDF in Transactions.
  --
    l_debug_loc := 'ja_zz_validate_invoice_gdf.copy_gui_type';
    IF NOT ja_zz_validate_invoice_gdf.copy_gui_type(
                               l_trx_line_id
                             , l_gui_type
                             , 'RAXTRX')
    THEN
      RAISE fatal_error;
    END IF;

    RETURN TRUE;

  EXCEPTION
  WHEN not_inv_class THEN
    RETURN TRUE;
  WHEN auto_trx_num_no THEN
    RETURN TRUE;
  WHEN OTHERS THEN
    IF pg_debug ='Y' THEN
      ar_invoice_utils.debug('-- Found an exception at ' ||l_debug_loc||'.');
      ar_invoice_utils.debug('-- ' ||SQLERRM);
    END IF;

    RETURN FALSE;
  END;


--
-- Validation for THAILAND
--

-----------------------------------------------------------------------------
--   ** Private ** Private ** Private ** Private ** Private ** Private **  --
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- FUNCTION                                                                --
--    ja_th_validate_gdff                                                  --
--                                                                         --
-- PARAMETERS                                                              --
--   INPUT                                                                 --
--      p_request_id   Number   -- Concurrent Request_id                   --
--                                                                         --
--   RETURNS                                                               --
--      0              Number   -- Validation Fails, if there is any       --
--                                 exceptional case which is handled       --
--                                 in WHEN OTHERS                          --
--      1              Number   -- Validation Succeeds                     --
--                                                                         --
-----------------------------------------------------------------------------

  FUNCTION ja_th_validate_gdff(p_request_id  IN NUMBER)
  RETURN NUMBER IS

    CURSOR tax_invoice_headers(c_request_id NUMBER) IS
      SELECT distinct
             lines.trx_line_id,
             lines.customer_trx_id,
             header.cust_trx_type_id,
             header.trx_date,
             fnd_date.canonical_to_date(types.global_attribute2) last_issued_date,
             to_number(types.global_attribute3) advance_days,
             lines.vat_tax_id,
             lines.line_type
      FROM   ar_trx_lines_gt      lines,
             ar_trx_header_gt     header,
             ra_batch_sources_all rbs,
             ra_cust_trx_types    types
      WHERE  lines.request_id = c_request_id
        AND  header.trx_header_id = lines.trx_header_id
        AND  header.batch_source_id = rbs.batch_source_id
        AND  header.cust_trx_type_id = types.cust_trx_type_id
        AND  nvl(types.global_attribute1, 'N') = 'Y';

    return_code  NUMBER;
    validation1  NUMBER;
    validation2  NUMBER;
    validation3  NUMBER;
    l_index1     binary_integer;

    pg_debug     VARCHAR2(1);

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('ja_th_validate_gdff()+');
    END IF;

    return_code := 1;

    -------------------------------------------------------
    -- Validate all the rows for this concurrent request --
    -------------------------------------------------------
    Open tax_invoice_headers(p_request_id);

    LOOP

      Fetch tax_invoice_headers BULK COLLECT INTO
        t_interface_line_tbl1.trx_line_id,
        t_interface_line_tbl1.customer_trx_id,
        t_interface_line_tbl1.cust_trx_type_id,
        t_interface_line_tbl1.trx_date,
        t_interface_line_tbl1.last_issued_date,
        t_interface_line_tbl1.advance_days,
        t_interface_line_tbl1.vat_tax_id,
        t_interface_line_tbl1.line_type
        ;

    EXIT WHEN tax_invoice_headers%NOTFOUND;

    END LOOP;

    CLOSE tax_invoice_headers;

    FOR l_index1 IN 1..t_interface_line_tbl1.trx_line_id.LAST
    LOOP

      validation1 := ja_zz_validate_invoice_gdf.validate_trx_date(
                       t_interface_line_tbl1.customer_trx_id(l_index1),
                       t_interface_line_tbl1.trx_date(l_index1),
                       t_interface_line_tbl1.last_issued_date(l_index1),
                       t_interface_line_tbl1.advance_days(l_index1),
                       'RAXTRX');

       IF t_interface_line_tbl1.line_type(l_index1) = 'LINE' AND t_interface_line_tbl1.vat_tax_id(l_index1) IS NULL THEN
        validation2 := 1;
      ELSE
        validation2 := ja_zz_validate_invoice_gdf.validate_tax_code(
                       t_interface_line_tbl1.customer_trx_id(l_index1),
                       'RAXTRX');
      END IF;

      IF validation1 = 1 AND validation2 = 1 THEN
        validation3 := ja_zz_validate_invoice_gdf.update_last_issued_date(
                         t_interface_line_tbl1.customer_trx_id(l_index1),
                         t_interface_line_tbl1.cust_trx_type_id(l_index1),
                         t_interface_line_tbl1.trx_date(l_index1),
                         'RAXTRX');
      END IF;

      IF validation1 = -1 OR validation2 = -1 OR validation3 = -1 THEN
        -- At the first sign of Fatal error, quite validation with
        -- return_code=0.
        return_code := 0;
        exit;
      END IF;

    END LOOP;

    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('ja_th_validate_gdff()-');
    END IF;

    return(return_code);

  EXCEPTION
    WHEN others THEN

      IF pg_debug = 'Y' THEN
        ar_invoice_utils.debug('-- Return From Exception when others');
        ar_invoice_utils.debug('-- Return Code: 0');
        ar_invoice_utils.debug('ja_th_validate_gdff()-');
      END IF;

      return(0);

  END ja_th_validate_gdff;

END ja_zz_invoice_create;

/
