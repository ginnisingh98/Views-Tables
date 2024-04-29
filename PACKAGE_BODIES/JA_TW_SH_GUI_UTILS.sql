--------------------------------------------------------
--  DDL for Package Body JA_TW_SH_GUI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_TW_SH_GUI_UTILS" AS
/* $Header: jatwsgub.pls 120.7.12010000.2 2008/12/31 13:01:51 rsaini ship $ */

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
    l_apps_short_name CONSTANT VARCHAR2(2) := 'JA'; --bug7133650
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
     l_country_code    VARCHAR2(30);  --bug7133650
  BEGIN

    l_batch_source_id := TO_CHAR(p_batch_source_id);
    l_org_id := fnd_profile.value('ORG_ID');
    fnd_profile.get('JGZZ_COUNTRY_CODE', l_country_code);
    -- Start Bug 7133650
    If (l_country_code = 'TW') Then
    l_seq_name := 'JA_GUI_NUMBER_'
               || l_batch_source_id
               || '_'
               || l_org_id
               || '_S';
    Else
    l_seq_name := 'RA_TRX_NUMBER_'
               || l_batch_source_id
               || '_'
               || l_org_id
               || '_S';
    End If;
    -- End Bug 7133650
    RETURN l_seq_name;

  END get_seq_name;


  PROCEDURE get_trx_src_info(
            p_batch_source_id    IN  NUMBER
          , p_auto_trx_num_flag  OUT NOCOPY VARCHAR2
          , p_inv_word           OUT NOCOPY VARCHAR2
          , p_init_trx_num       OUT NOCOPY VARCHAR2
          , p_fin_trx_num        OUT NOCOPY VARCHAR2
          , p_last_trx_date      OUT NOCOPY VARCHAR2
          , p_adv_days           OUT NOCOPY NUMBER
          -- Bug 4673732 : R12 MOAC
          , p_org_id             IN  NUMBER) IS

    CURSOR c_trx_src_info(x_batch_source_id NUMBER,
                          x_org_id          NUMBER) IS
       SELECT
              src.auto_trx_numbering_flag      auto_trx_num_flag
            , src.global_attribute3            inv_word
            , src.global_attribute2            init_trx_num
            , src.global_attribute4            fin_trx_num
            , src.global_attribute5            last_trx_date
            , TO_NUMBER(src.global_attribute6) adv_days
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id
        -- Bug 4673732 : R12 MOAC change
        AND   decode(nvl(x_org_id,1), 1, 1, src.org_id) = nvl(x_org_id, 1);

    l_batch_source_id NUMBER;
    l_trx_src_info    c_trx_src_info%ROWTYPE;

  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_trx_src_info(l_batch_source_id, p_org_id);
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
          , p_inv_class        OUT NOCOPY VARCHAR2
            -- Bug 4673732 : R12 MOAC
          , p_org_id           IN  NUMBER) IS

    CURSOR c_trx_type_info(x_cust_trx_type_id NUMBER,
                           x_org_id           NUMBER) IS
       SELECT
              ctt.type inv_class
              -- R12 Change : , ctt.global_attribute1 gui_type
            , NULL  gui_type
         FROM ra_cust_trx_types ctt
        WHERE ctt.cust_trx_type_id = p_cust_trx_type_id
         -- Bug 4673732 : R12 MOAC change
        AND   decode(nvl(x_org_id,1), 1, 1, ctt.org_id) = nvl(x_org_id, 1);

    l_cust_trx_type_id NUMBER;
    l_trx_type_info    c_trx_type_info%ROWTYPE;

  BEGIN

    l_cust_trx_type_id := p_cust_trx_type_id;

    OPEN c_trx_type_info(l_cust_trx_type_id,
                         p_org_id);
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


 -- Bug 4673732 : R12 MOAC
  FUNCTION get_ref_src_id(
            p_batch_source_id IN NUMBER,
            p_org_id          IN NUMBER) RETURN NUMBER IS

    l_batch_source_id NUMBER(15);
    l_ref_source_id   NUMBER(15);

    CURSOR c_ref_src(x_batch_source_id NUMBER,
                     x_org_id          NUMBER) IS
       SELECT src.global_attribute1
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id
         -- Bug 4673732 : R12 MOAC change
        AND   decode(nvl(x_org_id,1), 1, 1, src.org_id) = nvl(x_org_id, 1);
  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_ref_src(l_batch_source_id, p_org_id);
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

  -- Bug 4673732 : R12 MOAC
  FUNCTION get_inv_word(
            p_batch_source_id IN NUMBER,
            p_org_id          IN NUMBER) RETURN VARCHAR2 IS

    l_batch_source_id NUMBER;
    l_inv_word        VARCHAR2(2);

    CURSOR c_inv_word(x_batch_source_id NUMBER,
                      x_org_id          NUMBER) IS
       SELECT src.global_attribute3
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id
         -- Bug 4673732 : R12 MOAC change
        AND   decode(nvl(x_org_id,1), 1, 1, src.org_id) = nvl(x_org_id, 1);
  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_inv_word(l_batch_source_id, p_org_id);
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

  -- Bug 4673732 : R12 MOAC
  FUNCTION get_gui_src_id(
            p_batch_source_id IN NUMBER,
            p_org_id          IN NUMBER) RETURN NUMBER IS

    l_batch_source_id NUMBER(15);
    l_gui_source_id   NUMBER(15);

    CURSOR c_gui_src(x_batch_source_id NUMBER,
                     x_org_id          NUMBER) IS
       SELECT decode(src.global_attribute1
                       , NULL
                       , x_batch_source_id
                       , src.global_attribute1)
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id
        -- Bug 4673732 : R12 MOAC change
        AND   decode(nvl(x_org_id,1), 1, 1, src.org_id) = nvl(x_org_id, 1);
  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_gui_src(l_batch_source_id, p_org_id);
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

  -- Bug 4673732
  FUNCTION get_trx_num_range(
           p_batch_source_id IN NUMBER
         , p_ini_or_fin      IN VARCHAR2
         , p_org_id          IN NUMBER) RETURN VARCHAR2 IS

    l_batch_source_id NUMBER(15);
    l_ini_or_fin      VARCHAR2(3);
    l_trx_num         VARCHAR2(8);

    CURSOR c_trx_num_range(
           x_batch_source_id NUMBER
         , x_ini_or_fin      VARCHAR2
         , x_org_id          NUMBER) IS
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
           src.batch_source_id = x_batch_source_id
           -- Bug 4673732 : R12 MOAC change
     AND   decode(nvl(x_org_id,1), 1, 1, src.org_id) = nvl(x_org_id, 1);
  BEGIN

    l_batch_source_id := p_batch_source_id;
    l_ini_or_fin := p_ini_or_fin;

    OPEN c_trx_num_range(
           l_batch_source_id
         , l_ini_or_fin
         , p_org_id);
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

  -- Bug 4673732 : R12 MOAC
  FUNCTION get_last_trx_date(
             p_batch_source_id IN NUMBER,
             p_org_id             NUMBER) RETURN DATE IS

    l_gui_source_id  NUMBER;
    l_last_trx_date  DATE;

    CURSOR c_last_trx_date(x_gui_source_id NUMBER,
                           x_org_id        NUMBER) IS
       SELECT fnd_date.chardate_to_date(src.global_attribute5)
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_gui_source_id
        -- Bug 4673732 : R12 MOAC change
        AND   decode(nvl(x_org_id,1), 1, 1, src.org_id) = nvl(x_org_id, 1);
  BEGIN

    l_gui_source_id  := p_batch_source_id;

    OPEN c_last_trx_date(l_gui_source_id,
                         p_org_id);
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

  -- Bug 4673732
  FUNCTION get_adv_days(
            p_batch_source_id IN NUMBER,
            p_org_id          IN NUMBER) RETURN NUMBER IS

    l_batch_source_id NUMBER;
    l_adv_days        NUMBER;

    CURSOR c_adv_days(x_batch_source_id NUMBER,
                      x_org_id          NUMBER) IS
       SELECT src.global_attribute6
         FROM ra_batch_sources src
        WHERE src.batch_source_id = x_batch_source_id
        -- Bug 4673732 : R12 MOAC change
        AND   decode(nvl(x_org_id,1), 1, 1, src.org_id) = nvl(x_org_id, 1);
  BEGIN

    l_batch_source_id := p_batch_source_id;

    OPEN c_adv_days(l_batch_source_id,
                    p_org_id);
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
             p_interface_line_id IN NUMBER
           , p_batch_source_id   IN NUMBER
           , p_cust_trx_type_id  IN NUMBER
           , p_created_from      IN VARCHAR2) RETURN VARCHAR2 IS

    l_interface_line_id NUMBER;
    l_batch_source_id   NUMBER;
    l_cust_trx_type_id  NUMBER;
    l_created_from      VARCHAR2(10);
    l_dummy             VARCHAR2(10);
    l_message_text      VARCHAR2(240);
    l_invalid_value     VARCHAR2(240);
  BEGIN
    /*
    **   R12 Changes : 4460720
    **
    **   Stub out logic as Source/Type relationship feature
    **   is obsolete in R12.
    **
    l_interface_line_id := p_interface_line_id;
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
      fnd_message.set_name('JA','JA_TW_AR_INVALID_TRX_TYPE');
      l_message_text  := fnd_message.get;
      l_invalid_value := l_cust_trx_type_id;

      IF NOT jg_zz_auto_invoice.put_error_message(
                                 l_interface_line_id
                               , l_message_text
                               , l_invalid_value)
      THEN
        arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_src_type_rel.');
        arp_standard.debug('-- Cannot insert the error record into ra_interface_errors.');
        RETURN 'FATAL';
      ELSE
        RETURN 'FAIL';
      END IF;
    ELSIF l_created_from IN ('ARXTWMAI','ARXREC') THEN  --bug7133650
      RETURN 'FAIL';
    END IF;
  WHEN OTHERS THEN
    arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_src_type_rel.');
    RETURN 'FATAL';
  END val_src_type_rel;

  FUNCTION  val_trx_num(
             p_interface_line_id IN NUMBER
           , p_batch_source_id   IN NUMBER
           , p_fin_trx_num       IN VARCHAR2
           , p_created_from      IN VARCHAR2) RETURN VARCHAR2  IS

    put_error_mesg      EXCEPTION;
    l_interface_line_id NUMBER;
    l_batch_source_id   NUMBER;
    l_fin_trx_num       VARCHAR2(8);
    l_created_from      VARCHAR2(10);
    l_seq_name          VARCHAR2(30);
    l_last_trx_num      VARCHAR2(8);

  BEGIN

    l_interface_line_id := p_interface_line_id;
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
        IF NOT jg_zz_auto_invoice.put_error_message(
                                   'JA'
                                 , 'JA_TW_AR_GUI_NUM_OUT_OF_RANGE'
                                 , TO_CHAR(l_interface_line_id)
                                 , l_last_trx_num)
        THEN
           RAISE  put_error_mesg;
        ELSE
           RETURN 'FAIL';
        END IF;
      ELSIF l_created_from IN ('ARXTWMAI','ARXREC') THEN --bug7133650
        RETURN 'FAIL';
      END IF;
    END IF;

    RETURN 'SUCCESS';

  EXCEPTION
  WHEN put_error_mesg THEN
    arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_trx_num.');
    arp_standard.debug('-- Cannot insert the error record into ra_interface_errors.');
    RETURN 'FATAL';
  WHEN OTHERS THEN
    arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_trx_num.');
    arp_standard.debug('-- ' || SQLERRM);
    RETURN 'FATAL';
  END;

  --
  -- Check if transaction date is within valid ranges.
  --
  FUNCTION val_trx_date(
             p_interface_line_id IN NUMBER
           , p_batch_source_id   IN NUMBER
           , p_trx_date          IN DATE
           , p_last_trx_date     IN VARCHAR2
           , p_advance_days      IN NUMBER
           , p_created_from      IN VARCHAR2
             -- Bug 4673732 : R12 MOAC
           , p_org_id            IN NUMBER) RETURN VARCHAR2 IS

    put_error_mesg      EXCEPTION;
    upd_last_trx_date   EXCEPTION;

    l_interface_line_id NUMBER;
    l_batch_source_id   NUMBER;
    l_trx_date          DATE;
    l_last_trx_date     DATE;
    l_adv_days          NUMBER;
    l_created_from      VARCHAR2(10);
    l_advanced_date     DATE;
    l_dummy             VARCHAR2(10);
    l_message_text      VARCHAR2(240);
    l_invalid_value     VARCHAR2(240);

  BEGIN

    l_interface_line_id := p_interface_line_id;
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
                   , l_created_from
                   , p_org_id)
          THEN
            app_exception.raise_exception;
          END IF;
        EXCEPTION
        WHEN OTHERS THEN
          IF l_created_from = 'RAXTRX' THEN
            IF SQLCODE = -54 THEN
              fnd_message.set_name('JA','JA_TW_AR_LAST_ISSD_DT_LOCKED');
              l_message_text := fnd_message.get;
              arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_trx_date.');
              arp_standard.debug('-- '|| l_message_text);
            ELSE
              arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_trx_date.');
              arp_standard.debug('-- '|| SQLERRM);
            END IF;
              RETURN 'FATAL';
          ELSIF l_created_from IN ('ARXTWMAI','ARXREC') THEN --bug7133650
            RETURN TO_CHAR(SQLCODE);
          END IF;
        END;
      END IF;
    ELSE
      IF l_created_from = 'RAXTRX' THEN
        fnd_message.set_name('JA','JA_TW_AR_INVALID_TRX_DATE');
        fnd_message.set_token('LAST_ISSUED_DATE',fnd_date.date_to_chardate(l_last_trx_date));
        fnd_message.set_token('ADVANCED_DATE',fnd_date.date_to_chardate(l_advanced_date));
        l_message_text  := fnd_message.get;
        l_invalid_value := fnd_date.date_to_chardate(l_trx_date);
        IF NOT jg_zz_auto_invoice.put_error_message(
                                 l_interface_line_id
                               , l_message_text
                               , l_invalid_value)
        THEN
          RAISE put_error_mesg;
        ELSE
          RETURN 'FAIL';
        END IF;
      ELSIF l_created_from IN ('ARXTWMAI','ARXREC') THEN --bug7133650
        RETURN 'FAIL';
      END IF;
    END IF;

    RETURN 'SUCCESS';

  EXCEPTION
  WHEN put_error_mesg THEN
    arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_trx_date.');
    arp_standard.debug('-- Cannot insert the error record into ra_interface_errors.');
    arp_standard.debug('-- '|| SQLERRM);
    RETURN 'FATAL';
  WHEN OTHERS THEN
    arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_trx_date. ');
    arp_standard.debug('-- '|| SQLERRM);
    RETURN 'FATAL';
  END val_trx_date;

  --
  -- Validate Mixed Tax Codes.
  --
  FUNCTION val_mixed_tax_codes(
             p_interface_line_id IN NUMBER
           , p_customer_trx_id   IN NUMBER
           , p_created_from      IN VARCHAR2) RETURN VARCHAR2 IS

    put_error_mesg      EXCEPTION;

    l_interface_line_id NUMBER;
    l_customer_trx_id   NUMBER;
    l_cnt               NUMBER;
    l_created_from      VARCHAR2(10);
    l_message_text      VARCHAR2(240);

    --
    -- Cursor for Autoinvoice
    --
    CURSOR c_cnt_tax_codes_ai(x_customer_trx_id NUMBER) IS
    SELECT
           COUNT(DISTINCT l.tax_code)
      FROM
           ra_interface_lines_gt l
     WHERE
           l.customer_trx_id = x_customer_trx_id;
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

    l_interface_line_id := p_interface_line_id;
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
    ELSIF l_created_from IN ('ARXTWMAI','ARXREC') THEN --bug7133650
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
        fnd_message.set_name('JA','JA_TW_AR_MIXED_TAX_CODE');
        l_message_text  := fnd_message.get;
        IF NOT jg_zz_auto_invoice.put_error_message(
                                 l_interface_line_id
                               , l_message_text
                               , NULL) -- Invalid Value
        THEN
          RAISE put_error_mesg;
        ELSE
          RETURN 'FAIL';
        END IF;
      ELSIF l_created_from IN ('ARXTWMAI','ARXREC') THEN  --bug7133650
        RETURN 'FAIL';
      END IF;
    ELSE
      RETURN 'SUCCESS';
    END IF;
  EXCEPTION
  WHEN put_error_mesg THEN
    arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_mixed_tax_codes.');
    arp_standard.debug('-- Cannot insert the error record into ra_interface_errors.');
    arp_standard.debug('-- '|| SQLERRM);
    RETURN 'FATAL';
  WHEN OTHERS THEN
    arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.val_mixed_tax_codes.');
    arp_standard.debug('-- '|| SQLERRM);
    RETURN 'FATAL';
  END;

  --
  -- Update Last Transaction Date of Transaction Sources.
  --
  -- Bug 4673732 : R12 MOAC
  FUNCTION  update_last_trx_date(
             p_batch_source_id IN NUMBER
           , p_last_trx_date   IN DATE
           , p_created_from    IN VARCHAR2
           , p_org_id          IN NUMBER) RETURN BOOLEAN IS

    CURSOR c_last_issued_date(
           x_batch_source_id NUMBER,
           x_org_id          NUMBER) IS
    SELECT global_attribute5
      FROM ra_batch_sources   src
     WHERE batch_source_id = x_batch_source_id
     -- Bug 4673732 : R12 MOAC change
     AND   decode(nvl(x_org_id,1), 1, 1, src.org_id) = nvl(x_org_id, 1)
       FOR UPDATE OF global_attribute5 NOWAIT;

    l_gui_source_id NUMBER;
    l_last_trx_date VARCHAR2(30);
    l_dummy         VARCHAR2(30);
    l_created_from  VARCHAR2(10);

  BEGIN

    l_gui_source_id := p_batch_source_id;
    l_created_from  := p_created_from;
    l_last_trx_date := fnd_date.date_to_canonical(p_last_trx_date);

      OPEN c_last_issued_date(l_gui_source_id,
                              p_org_id);
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
            p_interface_line_id IN NUMBER
          , p_gui_type          IN VARCHAR2
          , p_created_from      IN VARCHAR2) RETURN BOOLEAN IS

    l_interface_line_id NUMBER;
    l_gui_type          VARCHAR2(2);
    l_created_from      VARCHAR2(10);
  BEGIN
    /*
    **   R12 Changes : 4460720
    **
    **   Stub out logic as Source/Type relationship feature
    **   is obsolete in R12.
    **
    l_interface_line_id := p_interface_line_id;
    l_gui_type          := p_gui_type;
    l_created_from      := p_created_from;

    UPDATE ra_interface_lines_gt
       SET header_gdf_attribute1 = l_gui_type
     WHERE interface_line_id = l_interface_line_id;
    **
    **
    */

    RETURN TRUE;
  EXCEPTION
  WHEN OTHERS THEN
    IF l_created_from = 'RAXTRX' THEN
      arp_standard.debug('-- Found exception in ja_tw_sh_gui_utils.copy_gui_type.');
      arp_standard.debug('-- '|| SQLERRM);
    END IF;
    RETURN FALSE;
  END;

END ja_tw_sh_gui_utils;

/
