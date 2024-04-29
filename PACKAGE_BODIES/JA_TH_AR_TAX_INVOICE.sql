--------------------------------------------------------
--  DDL for Package Body JA_TH_AR_TAX_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_TH_AR_TAX_INVOICE" AS
/* $Header: jathrtib.pls 120.4 2006/01/06 19:30:08 ykonishi ship $ */

  FUNCTION insert_interface_errors(
    p_customer_trx_id IN NUMBER,
    p_message_text IN VARCHAR2,
    p_invalid_value IN VARCHAR2,
    p_validation_name IN VARCHAR2
  )
  RETURN BOOLEAN IS
    CURSOR interface_line IS
      SELECT interface_line_id
      FROM ra_interface_lines_gt
      WHERE customer_trx_id = p_customer_trx_id;

    cannot_insert_error EXCEPTION;

  BEGIN

    FOR l IN interface_line
    LOOP
      IF NOT jg_zz_auto_invoice.put_error_message(
               l.interface_line_id,
               p_message_text,
               p_invalid_value) THEN

        raise cannot_insert_error;

      END IF;
    END LOOP;

    return(TRUE);

  EXCEPTION
    WHEN cannot_insert_error THEN
      arp_standard.debug('-- Found exception in ja_th_ar_tax_invoice.' ||
                         p_validation_name);
      arp_standard.debug('-- Cannot insert the error record into ' ||
                         'ra_interface_errors.');
      return(FALSE);

    WHEN others THEN
      arp_standard.debug('-- Found exception in ' ||
                         'ja_th_ar_tax_invoice.insert_interface_errors.');
      arp_standard.debug('-- ' || SQLERRM);

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

  BEGIN

    IF p_last_issued_date is NULL THEN
      return(1);
    ELSIF p_trx_date BETWEEN p_last_issued_date AND
                          (sysdate + nvl(p_advance_days,0)) THEN
      return(1);
    ELSE
      IF p_created_from = 'RAXTRX' THEN
        fnd_message.set_name('JA','JA_TH_AR_INVALID_TRX_DATE');
        fnd_message.set_token(
          'LAST_ISSUED_DATE',
          fnd_date.date_to_chardate(p_last_issued_date));
        fnd_message.set_token(
          'ADVANCED_DATE',
          fnd_date.date_to_chardate(sysdate+nvl(p_advance_days,0)));

        IF insert_interface_errors(
             p_customer_trx_id,
             fnd_message.get,
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
        arp_standard.debug('-- Found exception in ' ||
                           'ja_th_ar_tax_invoice.validate_trx_date.');
        arp_standard.debug('-- ' || SQLERRM);
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

    n NUMBER;

  BEGIN
  /*
  ** Bug 4756219
  **
  ** Stub out logic due to the reference with ar vat tax
  ** and Thai localization is obsolete in R12.
  **
  **
  **
  **
  */
  NULL;
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

  BEGIN

    BEGIN
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

          fnd_message.set_name('JA','JA_TH_AR_LAST_ISSD_DT_LOCKED');

          IF insert_interface_errors(
               p_customer_trx_id,
               fnd_message.get,
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
        arp_standard.debug('-- Found exception in ' ||
                           'ja_th_ar_tax_invoice.update_last_issued_date.');
        arp_standard.debug('-- ' || SQLERRM);
        return(-1);
      ELSIF p_created_from = 'ARXTWMAI' THEN
        return(0);
      END IF;

  END update_last_issued_date;

END ja_th_ar_tax_invoice;

/
