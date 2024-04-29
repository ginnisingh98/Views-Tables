--------------------------------------------------------
--  DDL for Package Body JA_ZZ_VALIDATE_INVOICE_GDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_ZZ_VALIDATE_INVOICE_GDF" AS
/* $Header: jazzrivb.pls 120.4 2006/01/06 20:19:19 ykonishi ship $ */

-- pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

-----------------------------------------------------------------------------
--   Taiwan Validation                                                     --
-----------------------------------------------------------------------------

  PROCEDURE get_next_seq_num(
            p_sequence_name IN  VARCHAR2
          , p_sequence_num  OUT NOCOPY NUMBER
          , p_error_code    OUT NOCOPY NUMBER) IS

     l_sql_stmt         VARCHAR2(100);
     l_seq_num          NUMBER;

  BEGIN
    l_sql_stmt := 'SELECT '
                 || p_sequence_name
                 || '.nextval seq_number '
                 || 'FROM dual';

    EXECUTE IMMEDIATE l_sql_stmt INTO l_seq_num;
    p_sequence_num := l_seq_num;
    p_error_code := 0;

  EXCEPTION
  WHEN OTHERS THEN
    p_sequence_num := NULL;
    p_error_code := SQLCODE;
  END get_next_seq_num;

  FUNCTION  get_last_trx_num(
            p_sequence_name IN  VARCHAR2) RETURN NUMBER IS

    l_apps_short_name CONSTANT VARCHAR2(2) := 'AR';
    l_status          VARCHAR2(50);
    l_industry        VARCHAR2(50);
    l_seq_owner       VARCHAR2(30);
    l_seq_name        VARCHAR2(30);
    l_last_trx_num    NUMBER;

    CURSOR c_last_trx_num(
           x_seq_name  IN VARCHAR2
         , x_seq_owner IN VARCHAR2) IS
    SELECT last_number - 1
      FROM all_sequences
     WHERE sequence_name  = x_seq_name
       AND sequence_owner = x_seq_owner;

  BEGIN

    l_seq_name  := p_sequence_name;

    IF NOT fnd_installation.get_app_info(
                             l_apps_short_name
                           , l_status
                           , l_industry
                           , l_seq_owner)
    THEN
      app_exception.raise_exception;
    END IF;

    OPEN  c_last_trx_num(
          l_seq_name
        , l_seq_owner);
    FETCH c_last_trx_num INTO l_last_trx_num;
    IF c_last_trx_num%NOTFOUND THEN
      app_exception.raise_exception;
    END IF;
    CLOSE c_last_trx_num;

    RETURN l_last_trx_num;

  END get_last_trx_num;

  FUNCTION get_seq_name(
            p_batch_source_id IN NUMBER) RETURN VARCHAR2 IS

     l_org_id          VARCHAR2(15);
     l_batch_source_id VARCHAR2(15);
     l_seq_name        VARCHAR2(30);
  BEGIN

    l_batch_source_id := TO_CHAR(p_batch_source_id);

    l_org_id := fnd_profile.value('ORG_ID');

    l_seq_name := 'RA_TRX_NUMBER_'
               || l_batch_source_id
               || '_'
               || l_org_id
               || '_S';

    RETURN l_seq_name;

  END get_seq_name;


  PROCEDURE get_trx_src_info(
            p_batch_source_id    IN  NUMBER
          , p_auto_trx_num_flag  OUT NOCOPY VARCHAR2
          , p_inv_word           OUT NOCOPY VARCHAR2
          , p_init_trx_num       OUT NOCOPY VARCHAR2
          , p_fin_trx_num        OUT NOCOPY VARCHAR2
          , p_last_trx_date      OUT NOCOPY VARCHAR2
          , p_adv_days           OUT NOCOPY NUMBER) IS

    CURSOR c_trx_src_info(x_batch_source_id NUMBER) IS
       SELECT
              src.auto_trx_numbering_flag      auto_trx_num_flag
            , src.global_attribute3            inv_word
            , src.global_attribute2            init_trx_num
            , src.global_attribute4            fin_trx_num
            , src.global_attribute5            last_trx_date
            , TO_NUMBER(src.global_attribute6) adv_days
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id;

    l_batch_source_id NUMBER;
    l_trx_src_info    c_trx_src_info%ROWTYPE;

  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_trx_src_info(l_batch_source_id);
    LOOP
      FETCH c_trx_src_info INTO l_trx_src_info;
      EXIT WHEN c_trx_src_info%NOTFOUND;
    END LOOP;
    CLOSE c_trx_src_info;

    p_auto_trx_num_flag := l_trx_src_info.auto_trx_num_flag;
    p_inv_word          := l_trx_src_info.inv_word;
    p_init_trx_num      := l_trx_src_info.init_trx_num;
    p_fin_trx_num       := l_trx_src_info.fin_trx_num;
    p_last_trx_date     := l_trx_src_info.last_trx_date;
    p_adv_days          := l_trx_src_info.adv_days;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END get_trx_src_info;

  PROCEDURE get_trx_type_info(
            p_cust_trx_type_id IN  NUMBER
          , p_gui_type         OUT NOCOPY VARCHAR2
          , p_inv_class        OUT NOCOPY VARCHAR2) IS

    CURSOR c_trx_type_info(x_cust_trx_type_id NUMBER) IS
       SELECT
              ctt.type inv_class
              -- R12 Changes : , ctt.global_attribute1 gui_type
              , NULL   gui_type
         FROM ra_cust_trx_types ctt
        WHERE ctt.cust_trx_type_id = p_cust_trx_type_id;

    l_cust_trx_type_id NUMBER;
    l_trx_type_info    c_trx_type_info%ROWTYPE;

  BEGIN

    l_cust_trx_type_id := p_cust_trx_type_id;

    OPEN c_trx_type_info(l_cust_trx_type_id);
    LOOP
      FETCH c_trx_type_info INTO l_trx_type_info;
      EXIT WHEN c_trx_type_info%NOTFOUND;
    END LOOP;
    CLOSE c_trx_type_info;

    p_gui_type  := l_trx_type_info.gui_type;
    p_inv_class := l_trx_type_info.inv_class;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END get_trx_type_info;


  FUNCTION get_ref_src_id(
            p_batch_source_id IN NUMBER) RETURN NUMBER IS

    l_batch_source_id NUMBER(15);
    l_ref_source_id   NUMBER(15);

    CURSOR c_ref_src(x_batch_source_id NUMBER) IS
       SELECT src.global_attribute1
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id;
  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_ref_src(l_batch_source_id);
    LOOP
      FETCH c_ref_src INTO l_ref_source_id;
      EXIT WHEN c_ref_src%NOTFOUND;
    END LOOP;
    CLOSE c_ref_src;

    RETURN l_ref_source_id;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END get_ref_src_id;

  FUNCTION get_inv_word(
            p_batch_source_id IN NUMBER) RETURN VARCHAR2 IS

    l_batch_source_id NUMBER;
    l_inv_word        VARCHAR2(2);

    CURSOR c_inv_word(x_batch_source_id NUMBER) IS
       SELECT src.global_attribute3
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id;
  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_inv_word(l_batch_source_id);
    LOOP
      FETCH c_inv_word INTO l_inv_word;
      EXIT WHEN c_inv_word%NOTFOUND;
    END LOOP;
    CLOSE c_inv_word;

    RETURN l_inv_word;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END get_inv_word;

  --
  -- When Reference Transaction Source is not null, return
  -- Reference Transaction Source ID(GLOBAL_ATTRIBUTE1).
  -- Otherwise, return Transaction Source Id(BATCH_SOURCE_ID).
  --
  FUNCTION get_gui_src_id(
            p_batch_source_id IN NUMBER) RETURN NUMBER IS

    l_batch_source_id NUMBER(15);
    l_gui_source_id   NUMBER(15);

    CURSOR c_gui_src(x_batch_source_id NUMBER) IS
       SELECT decode(src.global_attribute1
                       , NULL
                       , x_batch_source_id
                       , src.global_attribute1)
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id;

  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_gui_src(l_batch_source_id);
    LOOP
      FETCH c_gui_src INTO l_gui_source_id;
      EXIT WHEN c_gui_src%NOTFOUND;
    END LOOP;
    CLOSE c_gui_src;

    RETURN l_gui_source_id;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END get_gui_src_id;

  FUNCTION get_trx_num_range(
           p_batch_source_id IN NUMBER
         , p_ini_or_fin      IN VARCHAR2 ) RETURN VARCHAR2 IS

    l_batch_source_id NUMBER(15);
    l_ini_or_fin      VARCHAR2(3);
    l_trx_num         VARCHAR2(8);

    CURSOR c_trx_num_range(
           x_batch_source_id NUMBER
         , x_ini_or_fin      VARCHAR2) IS
    SELECT
           DECODE(x_ini_or_fin
                , 'INI'
                , src.global_attribute2
                , 'FIN'
                , src.global_attribute4
                , NULL)
      FROM
           ra_batch_sources src
     WHERE
           src.batch_source_id = x_batch_source_id;
  BEGIN

    l_batch_source_id := p_batch_source_id;
    l_ini_or_fin      := p_ini_or_fin;

    OPEN c_trx_num_range(
           l_batch_source_id
         , l_ini_or_fin);
    LOOP
      FETCH c_trx_num_range INTO l_trx_num;
      EXIT WHEN c_trx_num_range%NOTFOUND;
    END LOOP;
    CLOSE c_trx_num_range;

    RETURN l_trx_num;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END get_trx_num_range;

  FUNCTION get_last_trx_date(
             p_batch_source_id IN NUMBER) RETURN DATE IS

    l_gui_source_id  NUMBER;
    l_last_trx_date  DATE;

    CURSOR c_last_trx_date(x_gui_source_id NUMBER) IS
       SELECT fnd_date.chardate_to_date(src.global_attribute5)
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_gui_source_id;

  BEGIN

    l_gui_source_id  := p_batch_source_id;

    OPEN c_last_trx_date(l_gui_source_id);
    LOOP
      FETCH c_last_trx_date INTO l_last_trx_date;
      EXIT WHEN c_last_trx_date%NOTFOUND;
    END LOOP;
    CLOSE c_last_trx_date;

    RETURN l_last_trx_date;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END get_last_trx_date;

  FUNCTION get_adv_days(
            p_batch_source_id IN NUMBER) RETURN NUMBER IS

    l_batch_source_id NUMBER;
    l_adv_days        NUMBER;

    CURSOR c_adv_days(x_batch_source_id NUMBER) IS
       SELECT src.global_attribute6
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id;

  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_adv_days(l_batch_source_id);
    LOOP
      FETCH c_adv_days INTO l_adv_days;
      EXIT WHEN c_adv_days%NOTFOUND;
    END LOOP;
    CLOSE c_adv_days;

    RETURN l_adv_days;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END get_adv_days;

  --
  -- Check if source and type relationship is defined.
  --
  FUNCTION val_src_type_rel(
             p_trx_header_id     IN NUMBER
           , p_trx_line_id       IN NUMBER
           , p_batch_source_id   IN NUMBER
           , p_cust_trx_type_id  IN NUMBER
           , p_created_from      IN VARCHAR2) RETURN VARCHAR2 IS

    l_trx_header_id     NUMBER;
    l_trx_line_id       NUMBER;
    l_batch_source_id   NUMBER;
    l_cust_trx_type_id  NUMBER;
    l_created_from      VARCHAR2(10);
    l_dummy             VARCHAR2(10);
    l_message_text      VARCHAR2(240);
    l_invalid_value     VARCHAR2(240);
    pg_debug            VARCHAR2(1);
  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    /*
    **   R12 Changes : 4460720
    **
    **   Stub out logic as Source/Type relationship feature
    **   is obsolete in R12.
    **
    l_trx_header_id     := p_trx_header_id;
    l_trx_line_id       := p_trx_line_id;
    l_batch_source_id   := p_batch_source_id;
    l_cust_trx_type_id  := p_cust_trx_type_id;
    l_created_from      := p_created_from;

    SELECT 'SUCCESS'
      INTO l_dummy
      FROM jg_zz_ar_src_trx_ty st
     WHERE st.batch_source_id  = l_batch_source_id
       AND st.cust_trx_type_id = l_cust_trx_type_id
       AND st.enable_flag = 'Y';  -- Bug 1865837
    **
    **
    **
    */

    RETURN 'SUCCESS';

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF l_created_from = 'RAXTRX' THEN
      l_invalid_value := l_cust_trx_type_id;

      IF NOT jg_zz_invoice_create.put_error_message( 'JA'
                                  , 'JA_TW_AR_INVALID_TRX_TYPE'
                                  , p_trx_header_id
                                  , p_trx_line_id
                                  , l_invalid_value)
      THEN
        IF pg_debug = 'Y' THEN
          ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_src_type_rel.');
          ar_invoice_utils.debug('-- Cannot insert the error record into ar_trx_errors.');
        END IF;
        RETURN 'FATAL';
      ELSE
        RETURN 'FAIL';
      END IF;
    ELSIF l_created_from = 'ARXTWMAI' THEN
      RETURN 'FAIL';
    END IF;
  WHEN OTHERS THEN
    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_src_type_rel.');
    END IF;
    RETURN 'FATAL';
  END val_src_type_rel;

  FUNCTION  val_trx_num(
             p_trx_header_id     IN NUMBER
           , p_trx_line_id       IN NUMBER
           , p_batch_source_id   IN NUMBER
           , p_fin_trx_num       IN VARCHAR2
           , p_created_from      IN VARCHAR2) RETURN VARCHAR2  IS

    put_error_mesg      EXCEPTION;
    l_trx_header_id     NUMBER;
    l_trx_line_id       NUMBER;
    l_batch_source_id   NUMBER;
    l_fin_trx_num       VARCHAR2(8);
    l_created_from      VARCHAR2(10);
    l_seq_name          VARCHAR2(30);
    l_last_trx_num      VARCHAR2(8);
    pg_debug            VARCHAR2(1);

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    l_trx_header_id     := p_trx_header_id;
    l_trx_line_id       := p_trx_line_id;
    l_batch_source_id   := p_batch_source_id;
    l_fin_trx_num       := p_fin_trx_num;
    l_created_from      := p_created_from;

    --
    -- Get the sequence name.
    --
    l_seq_name := get_seq_name(
                    l_batch_source_id);
    --
    -- Get the last transaction number.
    --
    -- Bug 2739911
    -- l_last_trx_num := LPAD(get_last_trx_num(l_seq_name),8,'0');
    l_last_trx_num := get_last_trx_num(l_seq_name);
    --
    -- Check if the current sequence number is within the trx number range.
    --
    IF l_last_trx_num >= TO_NUMBER(l_fin_trx_num) THEN
      IF l_created_from = 'RAXTRX' THEN
        IF NOT jg_zz_invoice_create.put_error_message(
                                   'JA'
                                   , 'JA_TW_AR_GUI_NUM_OUT_OF_RANGE'
                                   , l_trx_header_id
                                   , l_trx_line_id
                                   , l_last_trx_num)
        THEN
           RAISE  put_error_mesg;
        ELSE
           RETURN 'FAIL';
        END IF;
      ELSIF l_created_from = 'ARXTWMAI' THEN
        RETURN 'FAIL';
      END IF;
    END IF;

    RETURN 'SUCCESS';

  EXCEPTION
  WHEN put_error_mesg THEN
    IF pg_debug = 'Y' THEN
       ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_trx_num.');
       ar_invoice_utils.debug('-- Cannot insert the error record into ar_trx_errors.');
    END IF;
    RETURN 'FATAL';
  WHEN OTHERS THEN
    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_trx_num.');
      ar_invoice_utils.debug('-- ' || SQLERRM);
    END IF;
    RETURN 'FATAL';
  END;

  --
  -- Check if transaction date is within valid ranges.
  --
  FUNCTION val_trx_date(
             p_trx_header_id     IN NUMBER
           , p_trx_line_id       IN NUMBER
           , p_batch_source_id   IN NUMBER
           , p_trx_date          IN DATE
           , p_last_trx_date     IN VARCHAR2
           , p_advance_days      IN NUMBER
           , p_created_from      IN VARCHAR2) RETURN VARCHAR2 IS

    put_error_mesg      EXCEPTION;
    upd_last_trx_date   EXCEPTION;

    l_trx_header_id     NUMBER;
    l_trx_line_id       NUMBER;
    l_batch_source_id   NUMBER;
    l_trx_date          DATE;
    l_last_trx_date     DATE;
    l_adv_days          NUMBER;
    l_created_from      VARCHAR2(10);
    l_advanced_date     DATE;
    l_dummy             VARCHAR2(10);
    l_message_text      VARCHAR2(240);
    l_invalid_value     VARCHAR2(240);
    pg_debug            VARCHAR2(1);

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    l_trx_header_id     := p_trx_header_id;
    l_trx_line_id       := p_trx_line_id;
    l_batch_source_id   := p_batch_source_id;
    l_trx_date          := TRUNC(p_trx_date);
    l_last_trx_date     := TRUNC(fnd_date.canonical_to_date(p_last_trx_date));
    l_adv_days          := p_advance_days;
    l_created_from      := p_created_from;

    l_advanced_date := sysdate + NVL(l_adv_days,0);

    IF l_trx_date BETWEEN NVL(l_last_trx_date,l_trx_date - 1) AND l_advanced_date THEN
      IF l_trx_date > NVL(l_last_trx_date,l_trx_date -1) THEN
        BEGIN
          IF NOT update_last_trx_date(
                     l_batch_source_id
                   , l_trx_date
                   , l_created_from)
          THEN
            app_exception.raise_exception;
          END IF;
        EXCEPTION
        WHEN OTHERS THEN
          IF l_created_from = 'RAXTRX' THEN
            IF SQLCODE = -54 THEN
              fnd_message.set_name('JA','JA_TW_AR_LAST_ISSD_DT_LOCKED');
              l_message_text := fnd_message.get;
              IF pg_debug = 'Y' THEN
                ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_trx_date.');
                ar_invoice_utils.debug('-- '|| l_message_text);
              END IF;
            ELSE
              IF pg_debug = 'Y' THEN
                ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_trx_date.');
                ar_invoice_utils.debug('-- '|| SQLERRM);
              END IF;
            END IF;
              RETURN 'FATAL';
          ELSIF l_created_from = 'ARXTWMAI' THEN
            RETURN TO_CHAR(SQLCODE);
          END IF;
        END;
      END IF;
    ELSE
      IF l_created_from = 'RAXTRX' THEN
        fnd_message.set_token('LAST_ISSUED_DATE',fnd_date.date_to_chardate(l_last_trx_date));
        fnd_message.set_token('ADVANCED_DATE',fnd_date.date_to_chardate(l_advanced_date));
        l_message_text  := fnd_message.get;
        l_invalid_value := fnd_date.date_to_chardate(l_trx_date);
        IF NOT jg_zz_invoice_create.put_error_message(
                                 'JA'
                               , 'JA_TW_AR_INVALID_TRX_DATE'
                               , l_trx_header_id
                               , l_trx_line_id
                               , l_invalid_value)
        THEN
          RAISE put_error_mesg;
        ELSE
          RETURN 'FAIL';
        END IF;
      ELSIF l_created_from = 'ARXTWMAI' THEN
        RETURN 'FAIL';
      END IF;
    END IF;

    RETURN 'SUCCESS';

  EXCEPTION
  WHEN put_error_mesg THEN
    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_trx_date.');
      ar_invoice_utils.debug('-- Cannot insert the error record into ar_trx_errors.');
      ar_invoice_utils.debug('-- '|| SQLERRM);
    END IF;
    RETURN 'FATAL';
  WHEN OTHERS THEN
    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_trx_date. ');
      ar_invoice_utils.debug('-- '|| SQLERRM);
    END IF;
    RETURN 'FATAL';
  END val_trx_date;

  --
  -- Validate Mixed Tax Codes.
  --
  FUNCTION val_mixed_tax_codes(
             p_trx_header_id     IN NUMBER
           , p_trx_line_id       IN NUMBER
           , p_customer_trx_id   IN NUMBER
           , p_created_from      IN VARCHAR2) RETURN VARCHAR2 IS

    put_error_mesg      EXCEPTION;

    l_trx_header_id     NUMBER;
    l_trx_line_id       NUMBER;
    l_customer_trx_id   NUMBER;
    l_cnt               NUMBER;
    l_created_from      VARCHAR2(10);
    l_message_text      VARCHAR2(240);

    pg_debug            VARCHAR2(1);

    --
    -- Cursor for Invoice
    --
    CURSOR c_cnt_tax_codes_ai(x_customer_trx_id NUMBER) IS
    SELECT
           COUNT(DISTINCT tax.tax_rate_code)
      FROM
           ar_trx_lines_gt l,
           --
           -- Bug 4756219
           -- Changing reference to ar vat tax to zx_mco_rates
           zx_mco_rates       tax

     WHERE
           l.customer_trx_id = x_customer_trx_id
       AND l.vat_tax_id = tax.tax_rate_id;
    --
    -- Cursor for Transactions
    --
    CURSOR c_cnt_tax_codes_tx(x_customer_trx_id NUMBER) IS
    SELECT
           COUNT(DISTINCT tl.vat_tax_id)
      FROM
           ra_customer_trx_lines tl
     WHERE
           tl.customer_trx_id = x_customer_trx_id
       AND tl.line_type = 'TAX';                 -- Bug 2753541
  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    l_trx_header_id     := p_trx_header_id;
    l_trx_line_id       := p_trx_line_id;
    l_customer_trx_id   := p_customer_trx_id;
    l_cnt               := 0;
    l_created_from      := p_created_from;

    IF l_created_from = 'RAXTRX' THEN
      OPEN c_cnt_tax_codes_ai(l_customer_trx_id);
      LOOP
        FETCH c_cnt_tax_codes_ai
         INTO l_cnt;
         EXIT WHEN c_cnt_tax_codes_ai%NOTFOUND;
      END LOOP;
      CLOSE c_cnt_tax_codes_ai;
    ELSIF l_created_from = 'ARXTWMAI' THEN
      OPEN c_cnt_tax_codes_tx(l_customer_trx_id);
      LOOP
        FETCH c_cnt_tax_codes_tx
         INTO l_cnt;
         EXIT WHEN c_cnt_tax_codes_tx%NOTFOUND;
      END LOOP;
      CLOSE c_cnt_tax_codes_tx;
    END IF;

    IF l_cnt >= 2 THEN
      IF l_created_from = 'RAXTRX' THEN
        IF NOT jg_zz_invoice_create.put_error_message(
                                'JA'
                              , 'JA_TW_AR_MIXED_TAX_CODE'
                              , l_trx_header_id
                              , l_trx_line_id
                              , NULL) -- Invalid Value
        THEN
          RAISE put_error_mesg;
        ELSE
          RETURN 'FAIL';
        END IF;
      ELSIF l_created_from = 'ARXTWMAI' THEN
        RETURN 'FAIL';
      END IF;
    ELSE
      RETURN 'SUCCESS';
    END IF;
  EXCEPTION
  WHEN put_error_mesg THEN
    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_mixed_tax_codes.');
      ar_invoice_utils.debug('-- Cannot insert the error record into ar_trx_errors.');
      ar_invoice_utils.debug('-- '|| SQLERRM);
    END IF;
    RETURN 'FATAL';
  WHEN OTHERS THEN
    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.val_mixed_tax_codes.');
      ar_invoice_utils.debug('-- '|| SQLERRM);
    END IF;
    RETURN 'FATAL';
  END;

  --
  -- Update Last Transaction Date of Transaction Sources.
  --
  FUNCTION  update_last_trx_date(
             p_batch_source_id IN NUMBER
           , p_last_trx_date   IN DATE
           , p_created_from    IN VARCHAR2) RETURN BOOLEAN IS

    CURSOR c_last_issued_date(
           x_batch_source_id NUMBER) IS
    SELECT global_attribute5
      FROM ra_batch_sources
     WHERE batch_source_id = x_batch_source_id
       FOR UPDATE OF global_attribute5 NOWAIT;

    l_gui_source_id NUMBER;
    l_last_trx_date VARCHAR2(30);
    l_dummy         VARCHAR2(30);
    l_created_from  VARCHAR2(10);

  BEGIN

    l_gui_source_id := p_batch_source_id;
    l_created_from  := p_created_from;

    l_last_trx_date := fnd_date.date_to_canonical(p_last_trx_date);

      OPEN c_last_issued_date(l_gui_source_id);
     FETCH c_last_issued_date INTO l_dummy;

    UPDATE ra_batch_sources
       SET global_attribute5 = l_last_trx_date
     WHERE CURRENT OF c_last_issued_date;

     CLOSE c_last_issued_date;

    RETURN TRUE;
  --
  -- Removed Exception Handler to pass SQLCODE to val_trx_date.
  --
  END update_last_trx_date;

  --
  -- Copy GUI Type of the transaction type to GDF in Transactions.
  --
  FUNCTION  copy_gui_type(
            p_trx_line_id       IN NUMBER
          , p_gui_type          IN VARCHAR2
          , p_created_from      IN VARCHAR2) RETURN BOOLEAN IS

    l_trx_line_id              NUMBER;
    l_gui_type                 VARCHAR2(2);
    l_created_from             VARCHAR2(10);
    pg_debug                   VARCHAR2(1);

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');
    /*
    **   R12 Changes : 4460720
    **
    **   Stub out logic as Source/Type relationship feature
    **   is obsolete in R12.
    **
    l_trx_line_id      := p_trx_line_id;
    l_gui_type         := p_gui_type;
    l_created_from     := p_created_from;

    UPDATE ar_trx_header_gt
       SET global_attribute1 = l_gui_type
     WHERE trx_header_id =
           (select trx_header_id
            from ar_trx_lines_gt
            where trx_line_id = l_trx_line_id);
    **
    **
    */

    RETURN TRUE;
  EXCEPTION
  WHEN OTHERS THEN
    IF l_created_from = 'RAXTRX' THEN
      IF pg_debug = 'Y' THEN
        ar_invoice_utils.debug('-- Found exception in ja_tw_invoice_create.copy_gui_type.');
        ar_invoice_utils.debug('-- '|| SQLERRM);
      END IF;
    END IF;
    RETURN FALSE;
  END;

-----------------------------------------------------------------------------
--   Thailand Validation                                                   --
-----------------------------------------------------------------------------

  FUNCTION insert_interface_errors(
    p_customer_trx_id IN NUMBER,
    p_msg_name        IN VARCHAR2,
    p_invalid_value   IN VARCHAR2,
    p_validation_name IN VARCHAR2
  )
  RETURN BOOLEAN IS
    CURSOR interface_line IS
      SELECT header.trx_header_id,
             lines.trx_line_id
      FROM ar_trx_header_gt  header,
           ar_trx_lines_gt   lines
      WHERE lines.customer_trx_id = p_customer_trx_id
        AND lines.trx_header_id = header.trx_header_id;

    cannot_insert_error EXCEPTION;

    pg_debug     VARCHAR2(1);

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    FOR l IN interface_line
    LOOP
      IF NOT jg_zz_invoice_create.put_error_message(
               'JA',
               p_msg_name,
               l.trx_header_id,
               l.trx_line_id,
               p_invalid_value) THEN

        raise cannot_insert_error;

      END IF;
    END LOOP;

    return(TRUE);

  EXCEPTION
    WHEN cannot_insert_error THEN
      IF pg_debug = 'Y' THEN
        ar_invoice_utils.debug('-- Found exception in ja_th_invoice_create.' ||
                           p_validation_name);
        ar_invoice_utils.debug('-- Cannot insert the error record into ' ||
                           'ar_trx_errors.');
      END IF;
      return(FALSE);

    WHEN others THEN
      IF pg_debug = 'Y' THEN
        ar_invoice_utils.debug('-- Found exception in ' ||
                           'ja_th_invoice_create.insert_interface_errors.');
        ar_invoice_utils.debug('-- ' || SQLERRM);
      END IF;

      return(FALSE);

  END insert_interface_errors;


  FUNCTION validate_trx_date(
    p_customer_trx_id  IN NUMBER,
    p_trx_date         IN DATE,
    p_last_issued_date IN DATE,
    p_advance_days     IN NUMBER,
    p_created_from     IN VARCHAR2
  )
  RETURN NUMBER IS

    pg_debug    VARCHAR2(1);

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    IF p_last_issued_date is NULL THEN
      return(1);
    ELSIF p_trx_date BETWEEN p_last_issued_date AND
                          (sysdate + nvl(p_advance_days,0)) THEN
      return(1);
    ELSE
      IF p_created_from = 'RAXTRX' THEN
        fnd_message.set_token(
          'LAST_ISSUED_DATE',
          fnd_date.date_to_chardate(p_last_issued_date));
        fnd_message.set_token(
          'ADVANCED_DATE',
          fnd_date.date_to_chardate(sysdate+nvl(p_advance_days,0)));

        IF insert_interface_errors(
             p_customer_trx_id,
             'JA_TH_AR_INVALID_TRX_DATE',
             fnd_date.date_to_chardate(p_trx_date),
             'validate_trx_date') THEN
          return(0);
        ELSE
          return(-1);
        END IF;
      ELSIF p_created_from = 'ARXTWMAI' THEN
        return(0);
      END IF;
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      IF p_created_from = 'RAXTRX' THEN
        IF pg_debug = 'Y' THEN
          ar_invoice_utils.debug('-- Found exception in ' ||
                           'ja_th_invoice_create.validate_trx_date.');
          ar_invoice_utils.debug('-- ' || SQLERRM);
        END IF;
        return(-1);
      ELSIF p_created_from = 'ARXTWMAI' THEN
        return(0);
      END IF;

  END validate_trx_date;


  FUNCTION validate_tax_code(
    p_customer_trx_id IN NUMBER,
    p_created_from IN VARCHAR2
  )
  RETURN NUMBER IS

    n          NUMBER;
    pg_debug   VARCHAR2(1);

  BEGIN

    pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

    IF p_created_from = 'ARXTWMAI' THEN
      SELECT count(l.customer_trx_line_id)
      INTO n
      FROM ra_customer_trx_lines l,
           -- Bug 4756219
           -- Changing reference to ar vat tax to zx_mco_rates
           zx_mco_rates  v,
           zx_accounts   a
      WHERE l.customer_trx_id = p_customer_trx_id
      AND v.tax_rate_id = l.vat_tax_id
      AND v.tax_rate_id = a.tax_account_entity_id
      AND a.tax_account_entity_code = 'RATES'
      AND a.interim_tax_ccid is NULL;
    ELSIF p_created_from = 'RAXTRX' THEN
      SELECT count(l.customer_trx_line_id)
      INTO n
      FROM ar_trx_lines_gt l,
           -- Bug 4756219
           -- Changing reference to ar vat tax to zx_mco_rates
           zx_mco_rates  v,
           zx_accounts   a
      WHERE l.customer_trx_id = p_customer_trx_id
      AND v.tax_rate_id = l.vat_tax_id
      AND (v.tax_class = 'O' OR v.tax_class IS NULL)
      AND v.active_flag='Y'
      AND v.effective_from <= sysdate
      AND (v.effective_to >= sysdate OR v.effective_to is NULL)
      AND v.tax_rate_id = a.tax_account_entity_id
      AND  a.tax_account_entity_code = 'RATES'
      AND  a.interim_tax_ccid is NULL;
    END IF;

    IF n > 0 THEN
      return(1);
    ELSE
      IF p_created_from = 'RAXTRX' THEN

        IF insert_interface_errors(
             p_customer_trx_id,
             'JA_TH_AR_INVALID_TAX_CODE',
             NULL,
             'validate_tax_code') THEN
          return(0);
        ELSE
          return(-1);
        END IF;
      ELSIF p_created_from = 'ARXTWMAI' THEN
        return(0);
      END IF;
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      IF p_created_from = 'RAXTRX' THEN
        IF pg_debug = 'Y' THEN
          ar_invoice_utils.debug('-- Found exception in ' ||
                             'ja_th_invoice_create.validate_tax_code.');
          ar_invoice_utils.debug('-- ' || SQLERRM);
        END IF;
        return(-1);
      ELSIF p_created_from = 'ARXTWMAI' THEN
        return(0);
      END IF;

  END validate_tax_code;


  FUNCTION update_last_issued_date(
    p_customer_trx_id  IN NUMBER,
    p_cust_trx_type_id IN NUMBER,
    p_trx_date         IN DATE,
    p_created_from     IN VARCHAR2
  )
  RETURN NUMBER IS

    CURSOR last_issued_date IS
      SELECT global_attribute2
      FROM ra_cust_trx_types
      WHERE cust_trx_type_id = p_cust_trx_type_id
      FOR UPDATE OF global_attribute2 NOWAIT;

    cannot_lock EXCEPTION;
    PRAGMA EXCEPTION_INIT(cannot_lock, -54);

    dummy VARCHAR2(150);
    trx_type_name VARCHAR2(20);

    pg_debug   VARCHAR2(1);

  BEGIN

    BEGIN

      pg_debug := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

      OPEN last_issued_date;

      FETCH last_issued_date INTO dummy;

      UPDATE ra_cust_trx_types
      SET global_attribute2 = fnd_date.date_to_canonical(p_trx_date)
      WHERE CURRENT OF last_issued_date;

      CLOSE last_issued_date;

    EXCEPTION
      WHEN cannot_lock THEN

        IF p_created_from = 'RAXTRX' THEN

          BEGIN
            SELECT name
            INTO trx_type_name
            FROM ra_cust_trx_types
            WHERE cust_trx_type_id = p_cust_trx_type_id;
          EXCEPTION
            WHEN others THEN
              raise;
          END;

          IF insert_interface_errors(
               p_customer_trx_id,
               'JA_TH_AR_LAST_ISSD_DT_LOCKED',
               fnd_date.date_to_chardate(p_trx_date),
               'update_last_issued_date') THEN
            return(0);
          ELSE
            return(-1);
          END IF;
        ELSIF p_created_from = 'ARXTWMAI' THEN
          return(0);
        END IF;

        raise;

    END;

    return(1);

  EXCEPTION

    WHEN others THEN
      IF p_created_from = 'RAXTRX' THEN
        IF pg_debug = 'Y' THEN
          ar_invoice_utils.debug('-- Found exception in ' ||
                             'ja_th_invoice_create.update_last_issued_date.');
          ar_invoice_utils.debug('-- ' || SQLERRM);
        END IF;
        return(-1);
      ELSIF p_created_from = 'ARXTWMAI' THEN
        return(0);
      END IF;

  END update_last_issued_date;

END ja_zz_validate_invoice_gdf;

/
