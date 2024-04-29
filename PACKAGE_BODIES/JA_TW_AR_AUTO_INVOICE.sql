--------------------------------------------------------
--  DDL for Package Body JA_TW_AR_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_TW_AR_AUTO_INVOICE" as
/* $Header: jatwraib.pls 120.2 2005/10/18 22:49:24 ykonishi ship $ */

-----------------------------------------------------------------------------
--   PRIVATE FUNCTIONS/PROCEDURES ** FORWARD DECLARATION **                --
-----------------------------------------------------------------------------
  FUNCTION val_interface_lines(
             p_request_id             IN NUMBER
           , p_interface_line_id      IN NUMBER
           , p_customer_trx_id        IN NUMBER
           , p_cust_trx_type_id       IN NUMBER
           , p_trx_date               IN DATE) RETURN BOOLEAN;

-----------------------------------------------------------------------------
--   PUBLIC FUNCTIONS/PROCEDURES                                           --
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- FUNCTION                                                                --
--    validate_gdff                                                        --
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
  FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER IS

    l_return_code    NUMBER(1);
    l_country_code   VARCHAR2(2);

    CURSOR c_trx_lines (x_request_id NUMBER) IS
    SELECT l.interface_line_id
         , l.customer_trx_id
         , l.cust_trx_type_id
         , l.trx_date
         , l.tax_code
         , l.line_type
      FROM
           ra_interface_lines_gt l
     WHERE
           l.request_id = x_request_id
       AND NVL(l.interface_status, '~') <> 'P'
       AND l.customer_trx_id IS NOT NULL
     ORDER BY l.trx_date;

  BEGIN
  --
  -- Let's assume everything is OK
  --
    l_return_code := 1;

    FOR trx_line_rec IN c_trx_lines (p_request_id)
    LOOP
      IF NOT val_interface_lines(
               p_request_id
             , trx_line_rec.interface_line_id
             , trx_line_rec.customer_trx_id
             , trx_line_rec.cust_trx_type_id
             , trx_line_rec.trx_date)
      THEN
        arp_standard.debug('-- ja_tw_ar_auto_invoice.'
                         ||'val_interface_lines routine failed');
        l_return_code := 0;
      END IF;
    END LOOP;

    arp_standard.debug('Return value from ja_tw_ar_auto_invoice.'
                     ||'validate_gdff() = '||TO_CHAR(l_return_code));

    RETURN l_return_code;

  EXCEPTION
    WHEN OTHERS THEN

      arp_standard.debug('-- Return From Exception when others');
      arp_standard.debug('-- Return Code: 0');
      arp_standard.debug('ja_tw_ar_auto_invoice.validate_gdff()-');

      RETURN 0;

  END validate_gdff;

-------------------------------------------------------------------------------
-- PUBLICE FUNCTION                                                          --
--    trx_num_upd                                                            --
--                                                                           --
-- PARAMETERS                                                                --
--   INPUT                                                                   --
--      p_batch_source_id    NUMBER       -- Transaction Source ID           --
--      p_trx_number         VARCHAR2(20) -- Original Transaction Number     --
--                                                                           --
-- RETURNS                                                                   --
--      l_trx_number         VARCHAR(20)  -- GUI Number                      --
--                                                                           --
-------------------------------------------------------------------------------
  FUNCTION trx_num_upd(p_batch_source_id IN NUMBER
                      ,p_trx_number      IN VARCHAR2) RETURN VARCHAR2 IS


    l_gui_src_id       NUMBER(15);
    l_inv_word         VARCHAR2(2);
    l_batch_source_id  NUMBER(15);
    l_trx_number       VARCHAR2(20);
    l_country_code     VARCHAR2(2);

  BEGIN

    l_batch_source_id := p_batch_source_id;
    l_trx_number := p_trx_number;

    --
    -- Get GUI Source ID.
    --
    -- Bug 4673732 : R12 MOAC
    l_gui_src_id := ja_tw_sh_gui_utils.get_gui_src_id(l_batch_source_id, NULL);
    --
    -- Get Invoice Word.
    --
    -- Bug 4673732 : R12 MOAC
    l_inv_word := ja_tw_sh_gui_utils.get_inv_word(l_gui_src_id, NULL);
    --
    -- Generate GUI Number.
    --
    IF l_inv_word IS NULL THEN
       IF LENGTHB(l_trx_number) < 8
       THEN
          l_trx_number :=  LPAD(l_trx_number,8,'0');
       END IF;
    ELSE
       IF NVL(SUBSTRB(l_trx_number,1,2),'&*') <> l_inv_word
       THEN
          l_trx_number := l_inv_word || LPAD(l_trx_number,8,'0');
       END IF;
    END IF;


    RETURN l_trx_number;

  EXCEPTION
  WHEN OTHERS THEN
      RAISE;
  END trx_num_upd;

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
--      p_interface_line_id      NUMBER       -- Interface Line ID           --
--      p_cust_trx_type_id       NUMBER       -- Transaction Type            --
--      p_trx_date               DATE         -- Transaction Date            --
--                                                                           --
-- RETURNS                                                                   --
--      TRUE/FALSE               BOOLEAN                                     --
--                                                                           --
-------------------------------------------------------------------------------
  FUNCTION val_interface_lines(
             p_request_id              IN NUMBER
           , p_interface_line_id       IN NUMBER
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
    l_interface_line_id NUMBER;
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
  BEGIN

    l_cust_trx_type_id  := p_cust_trx_type_id;
    l_interface_line_id := p_interface_line_id;
    l_customer_trx_id   := p_customer_trx_id;
    l_trx_date          := p_trx_date;

  -- Get the transaction type information
  --
    l_debug_loc := 'ja_tw_sh_gui_utils.get_trx_type_info';
    ja_tw_sh_gui_utils.get_trx_type_info(
                        l_cust_trx_type_id
                      , l_gui_type
                      , l_inv_class
                        -- Bug 4673732 : R12 MOAC
                      , NULL);
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
    l_debug_loc := 'ja_tw_sh_gui_utils.get_trx_src_info';
    ja_tw_sh_gui_utils.get_trx_src_info(
                        l_batch_source_id
                      , l_auto_trx_num_flag
                      , l_inv_word
                      , l_init_trx_num
                      , l_fin_trx_num
                      , l_last_trx_date
                      , l_adv_days
                      -- Bug 4673732 : R12 MOAC
                      , NULL);

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
    l_debug_loc := 'ja_tw_sh_gui_utils.val_src_type_rel';
    IF ja_tw_sh_gui_utils.val_src_type_rel(
                           l_interface_line_id
                         , l_batch_source_id
                         , l_cust_trx_type_id
                         , 'RAXTRX') = 'FATAL'
    THEN
      RAISE fatal_error;
    END IF;
  --
  -- Check if transaction date is within valid range.
  --
    l_debug_loc := 'ja_tw_sh_gui_utils.val_trx_date';
    IF ja_tw_sh_gui_utils.val_trx_date(
                           l_interface_line_id
                         , l_batch_source_id
                         , l_trx_date
                         , l_last_trx_date
                         , l_adv_days
                         , 'RAXTRX'
                         , NULL) = 'FATAL'
    THEN
      RAISE fatal_error;
    END IF;
  --
  -- Check if transaction number is within valid range.
  --
    l_debug_loc := 'ja_tw_sh_gui_utils.val_trx_num';
    IF ja_tw_sh_gui_utils.val_trx_num(
                           l_interface_line_id
                         , l_batch_source_id
                         , l_fin_trx_num
                         , 'RAXTRX') = 'FATAL'
    THEN
      RAISE fatal_error;
    END IF;

  --
  -- Check if a transaction header has multiple tax codes..
  --
    l_debug_loc := 'ja_tw_sh_gui_utils.val_mixed_tax_codes';
    IF ja_tw_sh_gui_utils.val_mixed_tax_codes(
                           l_interface_line_id
                         , l_customer_trx_id
                         , 'RAXTRX') = 'FATAL'
    THEN
      RAISE fatal_error;
    END IF;

  --
  -- Copy GUI Type of the transaction type to GDF in Transactions.
  --
    l_debug_loc := 'ja_tw_sh_gui_utils.copy_gui_type';
    IF NOT ja_tw_sh_gui_utils.copy_gui_type(
                               l_interface_line_id
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
    arp_standard.debug('-- Found an exception at ' ||l_debug_loc||'.');
    arp_standard.debug('-- ' ||SQLERRM);
    RETURN FALSE;
  END;

END ja_tw_ar_auto_invoice;

/
