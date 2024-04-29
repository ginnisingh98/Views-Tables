--------------------------------------------------------
--  DDL for Package Body AR_INVOICE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INVOICE_UTILS" AS
/* $Header: ARXVINUB.pls 120.65.12010000.24 2010/07/06 12:31:41 npanchak ship $ */
-- declare global variables.

g_set_of_books_id       NUMBER;
g_org_id                NUMBER;

/*Bug 5122918/4709987/3752043*/
pg_so_org_id             NUMBER := to_number(oe_profile.value('SO_ORGANIZATION_ID'));

pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');


PROCEDURE debug (
  p_message     IN VARCHAR2,
  p_log_level   IN NUMBER default fnd_log.level_statement,
  p_module_name IN VARCHAR2 default 'ar.plsql.InvoiceAPI') IS

BEGIN

/*Bug 3736074*/
/*
if ( (pg_debug = 'Y') and  ( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )) then
  FND_LOG.string(p_log_level,p_module_name, p_message);
  --arp_util.debug( p_message);
end if;
*/

arp_standard.debug(p_message);

END debug;

PROCEDURE validate_gdf(
      p_request_id           NUMBER,
      x_errmsg               OUT NOCOPY VARCHAR2,
      x_return_status        OUT NOCOPY VARCHAR2) IS

      l_return_code         NUMBER;
BEGIN
    IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_gdf(+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_return_code := jg_zz_invoice_create.validate_gdff
                (p_request_id   =>  p_request_id);

    IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_gdf(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'error in ar_invoice_utils.validate_gdf ' || sqlerrm;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RETURN;
END;

-- Bug # 3099975
-- ORASHID
-- 21-AUG-2003

PROCEDURE validate_remit_to_address_id (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_remit_to_address_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_REMIT_ADDR_ID'),
           remit_to_address_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.remit_to_address_id IS NOT NULL
    AND    NOT EXISTS
      (SELECT 'X'
       FROM ar_active_remit_to_addresses_v arta
       WHERE arta.address_id = gt.remit_to_address_id);

    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_remit_to_address_id(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_remit_to_address_id '
        || sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_remit_to_address_id;


PROCEDURE validate_trx_class (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_trx_class(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_TRX_CLASS'),
           trx_class
    FROM   ar_trx_header_gt gt
    WHERE  gt.trx_class NOT IN ('INV', 'DM' , 'CM')  -- added CM for ER 5869149
    AND    gt.trx_class IS NOT NULL;

    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_trx_class(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error in ar_invoice_utils.validate_trx_class '||sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_trx_class;


PROCEDURE validate_ship_via (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_ship_via(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_SHIP_VIA'),
           ship_via
    FROM   ar_trx_header_gt gt
    WHERE  gt.ship_via IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM  org_freight orf
       WHERE orf.freight_code = gt.ship_via
       AND   orf.organization_id = pg_so_org_id  /*Bug4709987*/
       AND   gt.trx_date <= nvl(trunc(orf.disable_date), gt.trx_date));

    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_ship_via(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_ship_via '|| sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_ship_via;


PROCEDURE validate_fob_point (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_fob_point(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_FOB'),
           fob_point
    FROM   ar_trx_header_gt gt
    WHERE  gt.fob_point IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM   ar_lookups
       WHERE  lookup_code = gt.fob_point
       AND    lookup_type = 'FOB'
       AND    gt.trx_date
         BETWEEN start_date_active and nvl(end_date_active, gt.trx_date));

    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_fob_point(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_fob_point '|| sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_fob_point;


PROCEDURE validate_ussgl_code (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_ussgl_code(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_USSGL_CODE'),
           default_ussgl_transaction_code
    FROM   ar_trx_header_gt gt
    WHERE  gt.default_ussgl_transaction_code IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM  gl_ussgl_transaction_codes gutc
       WHERE gutc.ussgl_transaction_code = gt.default_ussgl_transaction_code
       AND   gutc.chart_of_accounts_id = arp_global.chart_of_accounts_id
       AND   gt.trx_date
         BETWEEN NVL(gutc.start_date_active, gt.trx_date)
         AND NVL(gutc.end_date_active, gt.trx_date));

    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_ussgl_code(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_ussgl_code '|| sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_ussgl_code;


PROCEDURE validate_payment_method (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_payment_method(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INVALID_PAYMENT_METHOD'),
           receipt_method_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.receipt_method_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM   ar_receipt_methods rm
       WHERE  rm.receipt_method_id = gt.receipt_method_id
       AND    gt.trx_date BETWEEN NVL(rm.start_date, gt.trx_date)
              AND NVL(rm.end_date, gt.trx_date));

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_BOE_OBSOLETE'),
           receipt_method_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.receipt_method_id IS NOT NULL
      AND  arpt_sql_func_util.check_boe_paymeth(gt.receipt_method_id) = 'Y';

/* PAYMENT UPTAKE */

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INVALID_PAYMENT_METHOD'),
           receipt_method_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.payment_trxn_extension_id  IS  NOT NULL
    AND   EXISTS
      (SELECT 'X'
       FROM   ar_receipt_methods rm,
              ar_receipt_classes rc
       WHERE  rm.receipt_method_id = gt.receipt_method_id
       AND    rm.receipt_class_id  = rc.receipt_class_id
       AND    rc.creation_method_code = 'MANUAL' );

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INVALID_PAYMENT_METHOD'),
           receipt_method_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.payment_trxn_extension_id  IS  NOT NULL
    AND   EXISTS
      (SELECT 'X'
       FROM   ar_receipt_methods rm,
              iby_trxn_extensions_v iby
       WHERE  rm.receipt_method_id = gt.receipt_method_id
       AND    iby.trxn_extension_id= gt.payment_trxn_extension_id
       AND    iby.PAYMENT_CHANNEL_CODE <> rm.payment_channel_code );

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INVALID_PAYMENT_METHOD'),
           receipt_method_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.receipt_method_id IS NOT NULL
    AND    gt.payment_trxn_extension_id IS NULL
    AND   EXISTS
      (SELECT 'X'
       FROM   ar_receipt_methods rm,
              ar_receipt_classes rc
       WHERE  rm.receipt_method_id = gt.receipt_method_id
       AND    rm.receipt_class_id  = rc.receipt_class_id
       AND    rc.creation_method_code = 'AUTOMATIC' );

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INVALID_PAYMENT_METHOD'),
           receipt_method_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.receipt_method_id IS NULL
    AND    gt.payment_trxn_extension_id IS NOT NULL;

    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_payment_method(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_payment_method '
       || sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_payment_method;

/* 4188835 etax uptake */
PROCEDURE validate_legal_entity (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_legal_entity(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INVALID_LEGAL_ENTITY'),
           legal_entity_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.legal_entity_id IS NOT NULL
    AND NOT EXISTS (
               SELECT 'valid LE'
               FROM   XLE_LE_OU_LEDGER_V LE
               WHERE  LE.legal_entity_id = GT.legal_entity_id
               AND    LE.operating_unit_id = GT.org_id);

    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_legal_entity(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_legal_entity '
       || sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_legal_entity;

PROCEDURE validate_cust_bank_account_id (
  x_errmsg           OUT NOCOPY  VARCHAR2,
  x_return_status    OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_cust_bank_account_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
/* payment uptake removed the validation for cust_bank_account_id */

END validate_cust_bank_account_id;


PROCEDURE validate_paying_customer_id (
  p_trx_system_param_rec ar_invoice_default_pvt.trx_system_parameters_rec_type,
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_paying_customer_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Removed the prospect join as per the bug 3310138
  IF p_trx_system_param_rec.pay_unrelated_invoices_flag = 'Y'
  THEN
        INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
            arp_standard.fnd_message('AR_INAPI_INVALID_PAYING_CUS_ID'),
            paying_customer_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.paying_customer_id IS NOT NULL
        AND    NOT EXISTS (
                    SELECT 'X'
                    FROM  hz_cust_accounts cust_acct
                    WHERE cust_acct.cust_account_id = gt.paying_customer_id
                    AND   cust_acct.status = 'A' );
   ELSIF p_trx_system_param_rec.pay_unrelated_invoices_flag = 'N'
   THEN
        INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_PAYING_CUS_ID'),
           paying_customer_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.paying_customer_id IS NOT NULL
        AND NOT EXISTS
            (   SELECT 'X'
                FROM  hz_cust_accounts cust_acct
                WHERE cust_acct.cust_account_id = gt.paying_customer_id
                AND   cust_acct.status = 'A'
                AND cust_acct.cust_account_id IN
                    (
                        SELECT cr.cust_account_id
                        FROM hz_cust_acct_relate cr
                        WHERE cr.related_cust_account_id = gt.bill_to_customer_id
                        AND cr.status = 'A'
                        AND cr.bill_to_flag ='Y'
                        UNION
                        SELECT to_number(gt.bill_to_customer_id)
                        FROM DUAL
                        UNION
                        SELECT acc.cust_account_id
                        FROM ar_paying_relationships_v rel, hz_cust_accounts acc
                        WHERE rel.party_id = acc.party_id
                        AND rel.related_cust_account_id = gt.bill_to_customer_id
                        AND gt.trx_date BETWEEN effective_start_date
                        AND effective_end_date)
            );
    END IF;
    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_paying_customer_id(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_paying_customer_id '||
        sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_paying_customer_id;


PROCEDURE validate_paying_site_use_id (
  p_trx_system_param_rec ar_invoice_default_pvt.trx_system_parameters_rec_type,
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_paying_site_use_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_PAYING_SIT_ID'),
           paying_site_use_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.paying_site_use_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM   hz_cust_acct_sites acct_site,
              hz_cust_site_uses site_uses
       WHERE  acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
       AND    acct_site.cust_account_id = gt.paying_customer_id
       AND    site_uses.site_use_id = gt.paying_site_use_id
       AND    site_uses.site_use_code IN
               ('BILL_TO', decode(p_trx_system_param_rec.br_enabled_flag,
                'DRAWEE', 'PAYING')));

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_paying_site_use_id(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_paying_site_use_id '||
        sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_paying_site_use_id;


PROCEDURE validate_sold_to_customer_id (
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_sold_to_customer_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_DAPI_SOLD_CUST_ID_INVALID'),
           sold_to_customer_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.sold_to_customer_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM  hz_cust_accounts cust_acct
       WHERE cust_acct.cust_account_id = gt.sold_to_customer_id
       AND   cust_acct.status = 'A');

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_sold_to_customer_id(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_sold_to_customer_id '||
        sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_sold_to_customer_id;


PROCEDURE validate_ship_to_customer_name (
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_ship_to_customer_name(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INV_SHIP_TO_CUST_NAME'),
           ship_to_customer_name
    FROM   ar_trx_header_gt gt
    WHERE  gt.ship_to_customer_name IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM  hz_cust_accounts cust_acct,
             hz_parties party
       WHERE cust_acct.party_id = party.party_id
       AND   party.party_name = gt.ship_to_customer_name);

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_ship_to_customer_name(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_ship_to_customer_name '
        || sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_ship_to_customer_name;


PROCEDURE validate_ship_to_cust_number (
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_ship_to_cust_number(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INV_SHIP_TO_CUST_NUM'),
           ship_to_account_number
    FROM   ar_trx_header_gt gt
    WHERE  gt.ship_to_account_number IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM  hz_cust_accounts cust_acct
       WHERE cust_acct.account_number = gt.ship_to_account_number);

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_ship_to_cust_number(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_ship_to_cust_number '
        || sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_ship_to_cust_number;


PROCEDURE validate_bill_to_customer_name (
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_bill_to_customer_name(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INV_BILL_TO_CUST_NAME'),
           bill_to_customer_name
    FROM   ar_trx_header_gt gt
    WHERE  gt.bill_to_customer_name IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM  hz_cust_accounts cust_acct,
             hz_parties party
       WHERE cust_acct.party_id = party.party_id
       AND   party.party_name = gt.bill_to_customer_name);

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_bill_to_customer_name(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_bill_to_customer_name '
        || sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_bill_to_customer_name;


PROCEDURE validate_bill_to_cust_number (
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_bill_to_cust_number(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INV_BILL_TO_CUST_NUM'),
           bill_to_account_number
    FROM   ar_trx_header_gt gt
    WHERE  gt.bill_to_account_number IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM  hz_cust_accounts cust_acct
       WHERE cust_acct.account_number = gt.bill_to_account_number);

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_bill_to_cust_number(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_bill_to_cust_number '
        || sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_bill_to_cust_number;


PROCEDURE validate_bill_to_contact_id (
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_bill_to_contact_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_BAD_BLL_TO_CONTACT_ID'),
           bill_to_contact_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.bill_to_contact_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM hz_cust_account_roles acct_role,
            hz_parties       	  party,
            hz_relationships 	  rel,
            hz_org_contacts  	  org_cont,
            hz_parties       	  rel_party
       WHERE acct_role.party_id = rel.party_id
       AND   acct_role.role_type = 'CONTACT'
       and org_cont.party_relationship_id = rel.relationship_id
       and rel.subject_id = party.party_id
       and rel.party_id = rel_party.party_id
       and rel.subject_table_name = 'HZ_PARTIES'
       and rel.object_table_name = 'HZ_PARTIES'
       and rel.directional_flag = 'F'
       and acct_role.cust_account_id = gt.bill_to_customer_id
       and ( acct_role.cust_acct_site_id = gt.bill_to_address_id
             or acct_role.cust_acct_site_id IS NULL )
       AND acct_role.status = 'A');

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_bill_to_contact_id(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_bill_to_contact_id '||
        sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_bill_to_contact_id;


PROCEDURE validate_ship_to_contact_id (
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_ship_to_contact_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_BAD_SHP_TO_CONTACT_ID'),
           ship_to_contact_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.ship_to_contact_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM hz_cust_account_roles acct_role,
            hz_parties       	  party,
            hz_relationships 	  rel,
            hz_org_contacts  	  org_cont,
            hz_parties       	  rel_party
       WHERE acct_role.party_id = rel.party_id
       AND   acct_role.role_type = 'CONTACT'
       and org_cont.party_relationship_id = rel.relationship_id
       and rel.subject_id = party.party_id
       and rel.party_id = rel_party.party_id
       and rel.subject_table_name = 'HZ_PARTIES'
       and rel.object_table_name = 'HZ_PARTIES'
       and rel.directional_flag = 'F'
       and acct_role.cust_account_id = gt.ship_to_customer_id
       and ( acct_role.cust_acct_site_id = gt.ship_to_address_id
             or acct_role.cust_acct_site_id IS NULL )
       AND acct_role.status = 'A');

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_ship_to_contact_id(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_ship_to_contact_id '||
        sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_ship_to_contact_id;


PROCEDURE validate_exchange_rate_type (
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_exchange_rate_type(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INV_XCHNG_RATE_TYPE'),
           exchange_rate_type
    FROM   ar_trx_header_gt gt
    WHERE  gt.exchange_rate_type IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM   gl_daily_conversion_types
       WHERE  conversion_type <> 'EMU FIXED'
       AND    conversion_type = gt.exchange_rate_type); /*Bug 4517001*/

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_exchange_rate_type(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_exchange_rate_type '||
        sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_exchange_rate_type;


PROCEDURE validate_doc_sequence_value (
  p_trx_system_param_rec ar_invoice_default_pvt.trx_system_parameters_rec_type,
  p_trx_profile_rec      ar_invoice_default_pvt.trx_profile_rec_type,
  x_errmsg               OUT NOCOPY VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2 ) IS

  CURSOR header_rows IS
    SELECT *
    FROM  ar_trx_header_gt gt
    WHERE gt.doc_sequence_value IS NOT NULL;

  l_seq_num_profile fnd_profile_option_values.profile_option_value%type;

  l_doc_seq_ret_stat   	NUMBER;
  l_doc_sequence_id  	NUMBER;
  l_doc_sequence_name  	VARCHAR2(50);
  l_doc_sequence_type  	VARCHAR2(50);
  l_doc_sequence_value 	NUMBER;
  l_db_sequence_name  	VARCHAR2(50);
  l_seq_ass_id  	NUMBER;
  l_prd_tab_name  	VARCHAR2(50);
  l_aud_tab_name  	VARCHAR2(50);
  l_msg_flag      	VARCHAR2(1);

BEGIN

  -- Accept document sequence value only when sequence numbering
  -- is manual and sequence numbering turned on.

  l_seq_num_profile := NVL( p_trx_profile_rec.ar_unique_seq_numbers, 'N');

  FOR header_rec IN header_rows LOOP

    l_doc_seq_ret_stat:= fnd_seqnum.get_seq_info (
      222,
      header_rec.cust_trx_type_name,
      p_trx_system_param_rec.set_of_books_id,
      'M',
      trunc(header_rec.trx_date),
      l_doc_sequence_id,
      l_doc_sequence_type,
      l_doc_sequence_name,
      l_db_sequence_name,
      l_seq_ass_id,
      l_prd_tab_name,
      l_aud_tab_name,
      l_msg_flag,
      'Y',
      'Y');

    IF (l_seq_num_profile = 'N')
        AND SUBSTRB(l_doc_sequence_type,1,1) IN ( 'A', 'G') THEN

      INSERT INTO ar_trx_errors_gt (
        trx_header_id,
        error_message,
        invalid_value)
      VALUES
        (header_rec.trx_header_id,
         arp_standard.fnd_message('AR', 'AR_RAPI_DOC_SEQ_AUTOMATIC'),
         header_rec.doc_sequence_value);

    END IF;

  END LOOP;

END validate_doc_sequence_value;

PROCEDURE validate_bfb IS
BEGIN

  IF pg_debug = 'Y' THEN
     debug ('validate_bfb(+)');
  END IF;

  -- R12:BFB : billing_date is required if BFB is event-based
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_TAPI_BFB_BILLING_DATE_REQD'),
           billing_date
    FROM ar_trx_header_gt
    WHERE term_id IS NOT NULL
    AND billing_date IS NULL
    AND ar_bfb_utils_pvt.is_payment_term_bfb(term_id) = 'Y'
    AND nvl(ar_bfb_utils_pvt.get_cycle_type (ar_bfb_utils_pvt.get_billing_cycle(term_id)),'XXX') = 'EVENT';

  -- R12:BFB : BFB is not allowed with open Rec = No
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_TAPI_BFB_OPEN_REC'),
           term_id
    FROM ar_trx_header_gt
    WHERE term_id IS NOT NULL
    AND cust_trx_type_id IS NOT NULL
    AND ar_bfb_utils_pvt.is_payment_term_bfb(term_id) = 'Y'
    AND ar_bfb_utils_pvt.get_open_rec(cust_trx_type_id) = 'N';

  -- R12:BFB : billing_date validation
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_TAPI_BFB_BILLING_DATE_INV'),
           billing_date
    FROM ar_trx_header_gt
    WHERE term_id IS NOT NULL
    AND billing_date IS NOT NULL
    AND
    (
       (-- billing_date should be null for non-BFB
        ar_bfb_utils_pvt.is_payment_term_bfb(term_id) = 'N'
       )
       OR
       (-- BFB is not valid for open_rec = No, so there should be NO billing date either
        cust_trx_type_id IS NOT NULL
        AND ar_bfb_utils_pvt.is_payment_term_bfb(term_id) = 'Y'
        AND ar_bfb_utils_pvt.get_open_rec(cust_trx_type_id) = 'N'
       )
    );

  IF pg_debug = 'Y' THEN
     debug ('validate_bfb(-)');
  END IF;

END validate_bfb;

PROCEDURE validate_dependent_parameters (
  p_trx_system_param_rec ar_invoice_default_pvt.trx_system_parameters_rec_type,
  x_errmsg          OUT NOCOPY  VARCHAR2,
  x_return_status   OUT NOCOPY  VARCHAR2 ) IS

BEGIN

  -- Reject Trx Number as input if the batch source passed has
  -- automatic transaction numbering:

/* 4536358 - both trx_number validations tested using
   ra_batch_sources_all without an org_Id join.  This resulted
   in false error returns if even a single batch source of that
   ID was set Y (or N) respectively.  In other words, the EXISTS
   would test all batch sources of that ID and fail if even one
   had the opposite setting as the record for the current org.

   REMOVED _ALL from ra_batch_sources in exists clauses */

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           DECODE(b.auto_trx_numbering_flag, 'Y',
               arp_standard.fnd_message('AR_INAPI_TRX_NUM_NOT_REQUIRED'),
               arp_standard.fnd_message('AR_TW_NULL_TRX_NUMBER')),
           trx_number
    FROM   ar_trx_header_gt gt,
           ra_batch_sources b
    WHERE  b.batch_source_id = gt.batch_source_id
    AND   ((gt.trx_number IS NULL AND
            NVL(b.auto_trx_numbering_flag,'N') = 'N')
    OR     (gt.trx_number IS NOT NULL AND
            b.auto_trx_numbering_flag = 'Y'));

  -- Accept Customer Bank Account ID only when payment method
  -- is passed and it is automatic.

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_BANK_ACC_NOT_REQUIRED'),
           customer_bank_account_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.customer_bank_account_id IS NOT NULL
    AND    NOT EXISTS (
           SELECT 'X'
           FROM   ar_receipt_methods rm,
                  ar_receipt_classes rc
           WHERE  rm.receipt_class_id     = rc.receipt_class_id
           AND    rm.receipt_method_id    = gt.receipt_method_id
           AND    rc.creation_method_code = 'AUTOMATIC');

  -- If paying_site_use_id must be entered when paying_customer_id is
  -- entered.

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
      arp_standard.fnd_message('AR_INAPI_PAYING_SITE_REQUIRED'),
      paying_customer_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.paying_customer_id IS NOT NULL
    AND    gt.paying_site_use_id IS NULL;


  -- Purchase Order Reveision and Date should be accepted only
  -- when purchase order is passed.

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
      arp_standard.fnd_message('AR_INAPI_PO_REQUIRED'),
      paying_customer_id
    FROM   ar_trx_header_gt gt
    WHERE  (gt.purchase_order_revision IS NOT NULL
            OR gt.purchase_order_date IS NOT NULL)
    AND purchase_order IS NULL;

  -- Accounting Rule ID and Duration should be entered  only
  -- invoicing rule id is populated at header.

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    trx_line_id,
    error_message,
    invalid_value)
    SELECT lgt.trx_header_id,
           lgt.trx_line_id,
           arp_standard.fnd_message('AR_INAPI_RULE_INFO_UNNECESSARY'),
           NVL(lgt.accounting_rule_id, lgt.accounting_rule_duration)
    FROM   ar_trx_lines_gt lgt,
           ar_trx_header_gt hgt
    WHERE  (lgt.accounting_rule_id IS NOT NULL
            OR lgt.accounting_rule_duration IS NOT NULL)
    AND    lgt.trx_header_id = hgt.trx_header_id
    AND    hgt.invoicing_rule_id IS NULL;

  -- Link_to_line_id should always point to a line of type LINE
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    trx_line_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_INV_MASTER_LINE_TYPE'),
           link_to_trx_line_id
    FROM   ar_trx_lines_gt gt
    WHERE  gt.link_to_trx_line_id IS NOT NULL
    AND    NOT EXISTS
      (SELECT 'X'
       FROM  ar_trx_lines_gt gt2
       WHERE gt2.trx_line_id = gt.link_to_trx_line_id
       AND   gt2.line_type = 'LINE');

  -- Sub Lines can not have a line type of 'LINE'
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    trx_line_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_SUB_LINE_TYPE'),
           link_to_trx_line_id
    FROM   ar_trx_lines_gt gt
    WHERE  gt.link_to_trx_line_id IS NOT NULL
    AND    gt.line_type NOT IN ('TAX', 'FREIGHT');


  -- Exchange rate info is required only if exchange rate type
  -- is 'User'

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_TAPI_EXCHANGE_RATE_REQUIRED'),
           gt.trx_currency
    FROM   ar_trx_header_gt gt
    WHERE  gt.trx_currency IS NOT NULL
    AND    ( exchange_rate IS NULL
       OR    exchange_rate <= 0 )
    AND    exchange_rate_type = 'User'
    AND    gt.trx_currency <> p_trx_system_param_rec.base_currency_code;

  -- Exchange rate should not be entered for rate type != 'User'.

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_RATE_NOT_REQUIRED2'),
           exchange_rate
    FROM ar_trx_header_gt
    WHERE exchange_rate IS NOT NULL
    AND exchange_rate_type <> 'User';

  -- Exchange rate cannot be specified for base currency trxns.

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_TAPI_EXCHG_INFO_NOT_ALLOWED'),
           trx_currency
    FROM ar_trx_header_gt
    WHERE  ( exchange_rate IS NOT NULL
        OR   exchange_rate_type IS NOT NULL
        OR   exchange_date      IS NOT NULL )
    AND trx_currency = p_trx_system_param_rec.base_currency_code;

  -- amount includes tax flag should be NULL, Y or N

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    trx_line_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_TAX_CHOOSE_YES_NO'),
           amount_includes_tax_flag
    FROM ar_trx_lines_gt lgt
    WHERE amount_includes_tax_flag IS NOT NULL
    AND   amount_includes_tax_flag NOT IN ('Y', 'N');

  -- validate_bfb;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'ar_invoice_utils.validate_dependent_parameters: '||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END validate_dependent_parameters;


PROCEDURE validate_master_detail (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
     debug ('ar_invoice_utils.validate_master_detail(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Every header level row should have atleast one line level row.
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_TW_NO_LINES'),
           null
    FROM   ar_trx_header_gt gt
    WHERE  NOT EXISTS
      (SELECT 'X'
       FROM ar_trx_lines_gt lgt
       WHERE lgt.trx_header_id = gt.trx_header_id);

  -- Every line level row should have a corresponding header level row.
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    trx_line_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_ORPHAN_LINES'),
           null
    FROM   ar_trx_lines_gt lgt
    WHERE  NOT EXISTS
      (SELECT 'X'
       FROM ar_trx_header_gt hgt
       WHERE hgt.trx_header_id = lgt.trx_header_id);

  -- Line numbers must be unique
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    trx_line_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_LINE_NUMS_NOT_UNIQUE'),
           lgt.line_number
    FROM   ar_trx_lines_gt lgt
    WHERE  EXISTS
      (SELECT 'X'
       FROM  ar_trx_lines_gt lgt2
       WHERE lgt2.trx_header_id = lgt.trx_header_id
       AND   lgt2.line_number = lgt.line_number
       AND   lgt2.line_type = lgt.line_type
       GROUP BY lgt2.trx_header_id, lgt2.line_number
       HAVING count(*) > 1);

  -- Line IDs must be unique
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    trx_line_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_LINE_ID_NOT_UNIQUE'),
           null
    FROM   ar_trx_lines_gt lgt
    WHERE  EXISTS
      (SELECT 'X'
       FROM  ar_trx_lines_gt lgt2
       WHERE lgt2.trx_header_id = lgt.trx_header_id
       AND   lgt2.trx_line_id = lgt.trx_line_id
       GROUP BY lgt2.trx_header_id, lgt2.trx_line_id
       HAVING count(*) > 1);

  -- Header IDs must be unique
  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_HEADER_ID_NOT_UNIQUE'),
           null
    FROM   ar_trx_header_gt hgt
    WHERE  EXISTS
      (SELECT 'X'
       FROM  ar_trx_header_gt hgt2
       WHERE hgt2.trx_header_id = hgt.trx_header_id
       GROUP BY hgt2.trx_header_id
       HAVING count(*) > 1);


    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_master_detail(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_master_detail '
        || sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_master_detail;


-- Bug # 3099975
-- ORASHID
-- 21-AUG-2003 (END)


PROCEDURE validate_trx_number (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2)    AS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_trx_number(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_TW_INVALID_TRX_NUMBER'),
               trx_number
        FROM ar_trx_header_gt gt
        WHERE  gt.trx_number IS NOT NULL
        AND    gt.batch_source_id IS NOT NULL
        AND    EXISTS (
                    SELECT 'X'
                    FROM ra_batch_sources batch,
                         ra_customer_trx trx
                    WHERE  trx.batch_source_id   = gt.batch_source_id
                    AND    trx.trx_number        = gt.trx_number
                    AND    trx.customer_trx_id  <> NVL(gt.customer_trx_id, -99)
                    AND    trx.batch_source_id = batch.batch_source_id
                    AND    nvl(batch.copy_doc_number_flag,'N') = 'N'
                    AND    nvl(batch.allow_duplicate_trx_num_flag,'N') = 'N'
                    UNION
                    SELECT 'X'
                    FROM   ra_recur_interim  ri,
                           ra_customer_trx   ct,
                           ra_batch_sources batch
                    WHERE  ct.customer_trx_id       = ri.customer_trx_id
                    AND    ct.batch_source_id       = gt.batch_source_id
                    AND    ri.trx_number            = gt.trx_number
                    AND    NVL(ri.new_customer_trx_id, -98)
                                             <> NVL(gt.customer_trx_id, -99)
                    AND    ct.batch_source_id = batch.batch_source_id
                    AND    nvl(batch.copy_doc_number_flag,'N') = 'N'
                    AND    nvl(batch.allow_duplicate_trx_num_flag,'N') = 'N'
                    UNION
                    SELECT 'X'
                    FROM   ra_batch_sources    bs,
                           ar_trx_header_gt  ril
                    WHERE  ril.batch_source_id = bs.batch_source_id
                    AND    bs.batch_source_id    = gt.batch_source_id
                    AND    ril.trx_number        = gt.trx_number
                    AND    ril.customer_trx_id  <> NVL(gt.customer_trx_id, -99)
                    AND    nvl(bs.copy_doc_number_flag,'N') = 'N'
                    AND    nvl(bs.allow_duplicate_trx_num_flag,'N') = 'N'
                    );

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_trx_number(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_trx_number '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

/* Changes for SEPA */
PROCEDURE validate_mandate_flag(
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS
BEGIN
    IF pg_debug = 'Y' THEN
        debug ('AR_INVOICE_UTILS.validate_mandate_flag(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
                  trx_header_id,
                  error_message,
                  invalid_value)
            SELECT trx_header_id,
                   arp_standard.fnd_message('AR_INVALID_MANDATE_FLAG_VALUE'),
                   trx_number
            FROM ar_trx_header_gt gt
            WHERE nvl(upper(mandate_last_trx_flag),'N') not in ('Y','N');


    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_mandate_flag(-)' );
    END IF;
    EXCEPTION
	WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_mandate_flag'||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END;


PROCEDURE validate_batch_source (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN
    -- validate the batch source id
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_batch_source(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
        INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INVALID_BATCH_SOURCE'),
               batch_source_id
        FROM   ar_trx_header_gt gt
        WHERE  NOT EXISTS (
            SELECT 'X'
            FROM ra_batch_sources bs
            where nvl(gt.trx_date, trunc(sysdate)) between
                nvl(bs.start_date, nvl(gt.trx_date, trunc(sysdate)))
                and nvl(bs.end_date, nvl(gt.trx_date, trunc(sysdate)))
            and nvl(bs.status, 'A') = 'A'
            --and bs.batch_source_type = 'INV' -- means manual batch
            and bs.batch_source_id not in (11, 12)
            and gt.batch_source_id = bs.batch_source_id);
    END;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_batch_source(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_batch_source '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END;

PROCEDURE validate_currency
    (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_currency(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          error_message,
          invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INVALID_CURRENCY'),
           trx_currency
    FROM   ar_trx_header_gt gt
    WHERE  gt.trx_currency IS NOT NULL
    AND NOT EXISTS (
      SELECT 'X'
      FROM  fnd_currencies c
      WHERE c.currency_code = gt.trx_currency
      AND   gt.trx_date BETWEEN NVL(c.start_date_active, gt.trx_date)
            AND NVL(c.end_date_active, gt.trx_date) );

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_currency(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_currency '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_transaction_type
    (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_transaction_type(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_BR_TRX_TYPE_NULL'),
               cust_trx_type_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.cust_trx_type_id IS NULL;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INVALID_TRX_TYPE'),
               cust_trx_type_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.cust_trx_type_id IS NOT NULL
        AND    NOT EXISTS (
            SELECT 'X'
            FROM ra_cust_trx_types ctt
            where nvl(gt.trx_date, trunc(sysdate)) between
                  ctt.start_date and nvl(ctt.end_date, nvl(gt.trx_date, trunc(sysdate)))
            and   type IN ('INV', 'DM', 'CM') -- added CM for ER 5869149
            and   ctt.cust_trx_type_id = gt.cust_trx_type_id);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_transaction_type(-)' );
    END IF;

    EXCEPTION
            WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_transaction_type '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END;

PROCEDURE validate_bill_to_customer_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_bill_to_customer_id(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INV_BILL_TO_CUST_ID'),
               bill_to_customer_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.bill_to_customer_id IS NOT NULL
        AND    NOT EXISTS (
            SELECT 'X'
            FROM hz_cust_accounts ct
            WHERE ct.cust_account_id = gt.bill_to_customer_id
            AND   status = 'A');

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_bill_to_customer_id(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_bill_to_customer_id '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END;

PROCEDURE validate_bill_to_site_use_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS
BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_bill_to_site_use_id(+)' );
    END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

if(nvl(FND_PROFILE.value('AR_TRX_DEFAULT_PRIM_SITE_USE'),'BILL_SHIP_TO') not in ('BILL_TO','BILL_SHIP_TO')) then
        INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_BILL_TO_SITE_ID_REQ'),
               bill_to_site_use_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.bill_to_site_use_id IS NULL
	and gt.bill_to_customer_id is not null;
end if;

        INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INV_BILL_TO_SITE_USE'),
               bill_to_site_use_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.bill_to_site_use_id IS NOT NULL
        AND    NOT EXISTS (
            SELECT 'X'
            FROM hz_cust_site_uses ct
            WHERE site_use_code = 'BILL_TO'
            AND   cust_acct_site_id in (
                    SELECT cust_acct_site_id
                    FROM   hz_cust_acct_sites
                    WHERE  cust_account_id = gt.bill_to_customer_id)
            AND site_use_id = gt.bill_to_site_use_id);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_bill_to_site_use_id(-)' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.validate_bill_to_site_use_id '
          ||sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;

END validate_bill_to_site_use_id;


PROCEDURE validate_bill_to_address_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_bill_to_address_id(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INVALID_BILL_ADDR_ID'),
               bill_to_address_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.bill_to_address_id IS NOT NULL
        AND     NOT EXISTS (
            SELECT 'X'
              FROM HZ_CUST_ACCT_SITES ACCT_SITE,
                   HZ_PARTY_SITES PARTY_SITE,
                   --HZ_LOCATIONS LOC,
                   HZ_CUST_SITE_USES SU
                   -- FND_TERRITORIES_VL T
              WHERE  ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND    ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              --AND    LOC.LOCATION_ID =  PARTY_SITE.LOCATION_ID
              --AND    LOC.COUNTRY = T.TERRITORY_CODE
              AND    ACCT_SITE.CUST_ACCOUNT_ID = gt.bill_to_customer_id
              AND    SU.SITE_USE_ID = NVL(gt.bill_to_site_use_id, SU.SITE_USE_ID)
              AND    SU.SITE_USE_CODE = 'BILL_TO'
              AND    (SU.SITE_USE_ID =   gt.bill_to_site_use_id
                   OR (gt.bill_to_site_use_id IS NULL
                   AND SU.STATUS = 'A'  AND ACCT_SITE.STATUS = 'A' ))
              AND SU.CUST_ACCT_SITE_ID = gt.bill_to_address_id );

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_bill_to_address_id(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_bill_to_address_id '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END;

PROCEDURE validate_ship_to_customer_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2)  AS

   l_dummy varchar2(240);
   l_dummyn number;

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_ship_to_customer_id(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INV_SHIP_TO_CUST_ID'),
               ship_to_customer_id
        FROM   ar_trx_header_gt gt
        WHERE gt.ship_to_customer_id IS NOT NULL
        AND  NOT EXISTS (
            SELECT 'X'
            FROM hz_cust_accounts ct
            WHERE ct.cust_account_id = gt.ship_to_customer_id
            AND   ct.status = 'A');
            -- OR    gt.ship_to_customer_id IS NOT NULL);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_ship_to_customer_id(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
          x_errmsg := 'Error in AR_INVOICE_UTILS.validate_ship_to_customer_id '
            ||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_ship_to_site_use_id (
     x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_called			in varchar2  default null) AS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_ship_to_site_use_id(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

--  The below if condition is added to validate ship_to_site_use_id before defaulting ship_to details
    if(x_called = 'BEFORE') then
    if( nvl(FND_PROFILE.value('AR_TRX_DEFAULT_PRIM_SITE_USE'),'BILL_SHIP_TO') not in ('SHIP_TO','BILL_SHIP_TO')) then

        INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_SHIP_TO_SITE_ID_REQ'),
               ship_to_site_use_id
        FROM   ar_trx_header_gt gt
        WHERE   gt.ship_to_site_use_id IS NULL
        AND    gt.ship_to_customer_id IS NOT NULL;
    end if;

        INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INVALID_SHIP_SITE_USE'),
               ship_to_site_use_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.ship_to_site_use_id IS NOT NULL
        AND    gt.ship_to_customer_id IS NOT NULL
        AND    NOT EXISTS (
            SELECT 'X'
            FROM hz_cust_site_uses ct
            WHERE site_use_code = 'SHIP_TO'
              and cust_acct_site_id in (
                      select cust_acct_site_id from hz_cust_acct_sites
                     where cust_account_id = gt.ship_to_customer_id)
              and site_use_id = gt.ship_to_site_use_id);

   else
         INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_NULL_SHIP_TO_SITE'),
               ship_to_site_use_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.ship_to_site_use_id IS NULL
        AND    gt.ship_to_customer_id IS NOT NULL;

   end if;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_ship_to_site_use_id(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_ship_to_site_use_id '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_ship_to_location (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_ship_to_location(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_SHIP_SITE_USE'),
           ship_to_site_use_id
    FROM   ar_trx_header_gt gt
    WHERE gt.ship_to_site_use_id IS NOT NULL
      AND NOT EXISTS (
        select 'X'
        from
        (
          SELECT
            A.CUST_ACCOUNT_ID CUSTOMER_ID ,
            A.STATUS A_STATUS ,
            SU.STATUS SU_STATUS ,
            SU.SITE_USE_ID SITE_USE_ID
          FROM
            HZ_CUST_ACCT_SITES A,
            HZ_CUST_SITE_USES SU
          WHERE
            A.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
            AND SU.SITE_USE_CODE = 'SHIP_TO'
        ) asa
        where asa.customer_id = gt.ship_to_customer_id
        and ( asa.site_use_id = gt.ship_to_site_use_id
        or ( asa.su_status = 'A' and asa.a_status = 'A' ) ));

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_ship_to_location(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_ship_to_location '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;


PROCEDURE populate_ship_to_site_use_id (
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2)  IS

BEGIN

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_ship_to_site_use_id (+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- We are here to populate ship_to_site_use_id column.   We should only
  -- do it for rows where it is not already populated.  Moreover, first we
  -- should see if ship_to_address_id is populated then we should derive the
  -- ship_to_site_use_id from that.

  UPDATE ar_trx_header_gt gt
  SET    ship_to_site_use_id = (
           SELECT site_use_id
           FROM   hz_cust_site_uses
           WHERE  site_use_code = 'SHIP_TO'
           AND    cust_acct_site_id = gt.ship_to_address_id
           AND    gt.ship_to_site_use_id IS NULL
           AND    gt.ship_to_address_id IS NOT NULL)
  WHERE  gt.ship_to_site_use_id IS NULL
  AND    gt.ship_to_address_id IS NOT NULL;

  -- Now we will worry about cases where only customer id
  -- is populated and we must derive the primary ship to site id.

  UPDATE ar_trx_header_gt gt
  SET    ship_to_site_use_id = (
           SELECT site_use_id
           FROM   hz_cust_site_uses
           WHERE  primary_flag = 'Y'
           AND    site_use_code = 'SHIP_TO'
           AND    cust_acct_site_id IN (
                    SELECT cust_acct_site_id
                    FROM   hz_cust_acct_sites
                   WHERE  cust_account_id = gt.ship_to_customer_id))
  WHERE gt.ship_to_site_use_id IS NULL;

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_ship_to_site_use_id (-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error in AR_INVOICE_UTILS.populate_ship_to_site_use_id '
        ||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END populate_ship_to_site_use_id;


PROCEDURE validate_ship_to_address (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS

   l_dummy varchar2(240);
   l_dummyn number;

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_ship_to_address(+)' );
    END IF;

    populate_ship_to_site_use_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_SHIP_SITE_USE'),
           gt.ship_to_site_use_id
    FROM   ar_trx_header_gt gt
    WHERE gt.ship_to_customer_id IS NOT NULL
    AND   gt.ship_to_site_use_id IS NOT NULL
    AND   NOT EXISTS (
        select 'X'
        from
        (
          SELECT
            A.CUST_ACCOUNT_ID CUSTOMER_ID ,
            A.STATUS A_STATUS ,
            SU.STATUS SU_STATUS ,
            SU.SITE_USE_ID SITE_USE_ID
          FROM
            HZ_CUST_ACCT_SITES A,
            HZ_CUST_SITE_USES SU
          WHERE
            A.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
            AND SU.SITE_USE_CODE = 'SHIP_TO'
        )asa
        where asa.customer_id = gt.ship_to_customer_id
        and ( asa.site_use_id = gt.ship_to_site_use_id
        or ( gt.customer_trx_id is null
             and asa.su_status = 'A' and asa.a_status = 'A' ) ) );

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_ship_to_address(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_ship_to_address '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END validate_ship_to_address;


PROCEDURE validate_terms (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_terms(+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT gt.trx_header_id,
               arp_standard.fnd_message('AR_INVALID_TERM'),
               gt.term_id
        FROM   ar_trx_header_gt gt,
	       ra_cust_trx_types ctt
        WHERE  gt.term_id IS NOT NULL
	AND    gt.trx_class <> 'CM' -- added for ER 5869149
        AND    ctt.cust_trx_type_id = gt.cust_trx_type_id -- ER 5869149
        AND    ctt.type <> 'CM'  -- ER 5869149
        AND   NOT EXISTS (
            SELECT 'X'
            from ra_terms_lines tl, ra_terms t
            where nvl(gt.trx_date, trunc(sysdate))
            between t.start_date_active and nvl(t.end_date_active, nvl( gt.trx_date, trunc(sysdate) ) )
            and t.term_id = tl.term_id
            and t.term_id = gt.term_id );

     -- Term id not allowed for Credit Memo
     -- added for ER 5869149
     INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT gt.trx_header_id,
               arp_standard.fnd_message('AR_INAPI_TERM_NOT_ALLOWED'),
               gt.term_id
        FROM   ar_trx_header_gt gt,
               ra_cust_trx_types ctt
        WHERE  gt.term_id IS NOT NULL
        AND    gt.cust_trx_type_id = ctt.cust_trx_type_id
        AND    ctt.type = 'CM';

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_terms(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_terms '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END validate_terms;


PROCEDURE validate_salesrep (
  p_trx_system_param_rec ar_invoice_default_pvt.trx_system_parameters_rec_type,
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

  l_message_name VARCHAR2(30);

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_salesrep(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INVALID_PRIMARY_SALESREP'),
               primary_salesrep_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.primary_salesrep_id IS NOT NULL
        AND     NOT EXISTS (
            SELECT 'X'
            FROM HZ_CUST_ACCT_SITES ACCT_SITE,
                 HZ_PARTY_SITES PARTY_SITE,
                 HZ_LOCATIONS LOC,
                 HZ_CUST_SITE_USES SU,
                 FND_TERRITORIES_VL T
            WHERE ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
            AND   ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
            AND   LOC.LOCATION_ID =  PARTY_SITE.LOCATION_ID
            AND   LOC.COUNTRY = T.TERRITORY_CODE
            AND   ACCT_SITE.CUST_ACCOUNT_ID = gt.bill_to_customer_id
            AND SU.SITE_USE_ID = NVL(gt.bill_to_site_use_id, SU.SITE_USE_ID)
            AND SU.SITE_USE_CODE = 'BILL_TO'
            AND (SU.SITE_USE_ID =  gt.bill_to_site_use_id
               OR (gt.bill_to_site_use_id IS NULL
                   AND SU.STATUS = 'A'
                   AND ACCT_SITE.STATUS = 'A' ))
            -- AND SU.PRIMARY_FLAG = 'Y'
            AND SU.primary_salesrep_id = gt.primary_salesrep_id);
*/

    -- Bug # 3099975
    -- ORASHID
    -- 21-AUG-2003 (END)


    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INVALID_PRIMARY_SALESREP',
      p_app_short_name => 'AR');

    INSERT INTO ar_trx_errors_gt (
           trx_header_id,
           error_message,
           invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message(l_message_name),
           primary_salesrep_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.primary_salesrep_id IS NOT NULL
    AND     NOT EXISTS (
              (SELECT  'X'
               FROM    ra_salesreps rs
               WHERE   rs.salesrep_id = gt.primary_salesrep_id
               AND     gt.trx_date
               BETWEEN rs.start_date_active
               AND     NVL(rs.end_date_active, gt.trx_date)));

    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INAPI_SALESREP_REQUIRED',
      p_app_short_name => 'AR');

    INSERT INTO ar_trx_errors_gt (
           trx_header_id,
           error_message,
           invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message(l_message_name),
           primary_salesrep_id
    FROM   ar_trx_header_gt gt
    WHERE  gt.primary_salesrep_id IS NULL
    AND    p_trx_system_param_rec.salesrep_required_flag = 'Y';

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_salesrep(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error in AR_INVOICE_UTILS.validate_salesrep '||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END validate_salesrep;


PROCEDURE validate_invoicing_rule_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_invoicing_rule_id(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- in case of debit memo invoice rule id is not required
    -- in case of credit memo invoice rule id is not required ER 5869149
    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INV_RULE_NOT_REQUIRED'),
               invoicing_rule_id
        FROM ar_trx_header_gt gt
        WHERE  gt.invoicing_rule_id IS NOT NULL
        AND    gt.cust_trx_type_id NOT IN  (
                SELECT tt.cust_trx_type_id
                FROM   ra_cust_trx_types tt
                WHERE  tt.cust_trx_type_id = gt.cust_trx_type_id
                AND    tt.type = 'INV' );

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INVALID_INV_RULE_ID'),
               invoicing_rule_id
        FROM ar_trx_header_gt gt
        WHERE  gt.invoicing_rule_id IS NOT NULL
        AND    gt.invoicing_rule_id not in ( -2, -3);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_invoicing_rule_id(-)' );
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.validate_invoicing_rule_id '
          ||sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RETURN;

END validate_invoicing_rule_id;


PROCEDURE validate_print_option (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_print_option(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INVALID_PRINT_OPTION'),
               printing_option
        FROM   ar_trx_header_gt gt
        WHERE  gt.printing_option IS NOT NULL
        AND    gt.printing_option NOT IN ( 'PRI', 'NOT');
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_print_option(-)' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.validate_print_option '
          ||sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;

END validate_print_option;


/*bug4369585-4589309*/

PROCEDURE populate_printing_pending (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_printing_pendings(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

update ar_trx_header_gt gt
    set gt.printing_pending=decode(gt.PRINTING_OPTION,'PRI','Y','N');

IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_printing_pending(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_printing_pending '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

End populate_printing_pending;


PROCEDURE validate_default_tax (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS
    l_tax_use_exempt_flag       zx_product_options.tax_use_customer_exempt_flag%type;

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_default_tax(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        /* 4257557 - changed to zx_product_options */
        select nvl(tax_use_customer_exempt_flag,'N')
        into  l_tax_use_exempt_flag
        from  zx_product_options
        where application_id = 222;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF pg_debug = 'Y'
        THEN
            debug ('  No rows in zx_product_options' );
            debug ('AR_INVOICE_UTILS.validate_default_tax(-)' );
        END IF;
        RETURN;
    END;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INV_TAX_EXEMPT_FLAG'),
               default_tax_exempt_flag
        FROM  ar_trx_header_gt gt
        WHERE default_tax_exempt_flag IS NOT NULL
        AND   NOT EXISTS (
            select 'X'
            from ar_lookups AL1
            where AL1.lookup_type = 'TAX_CONTROL_FLAG'
            and (AL1.lookup_code in ('R','S')
            or (AL1.lookup_code = 'E' and
                l_tax_use_exempt_flag = 'Y'))
            and gt.default_tax_exempt_flag = AL1.lookup_code );

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_default_tax(-)' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.validate_default_tax '||sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;

END validate_default_tax;


PROCEDURE validate_status (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_Status(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INVALID_TRX_STATUS'),
               status_trx
        FROM  ar_trx_header_gt
        WHERE status_trx  IS NOT NULL
        AND   status_trx not in ( 'OP','CL','PEN','VD');

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_Status(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_Status '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END validate_status;


PROCEDURE validate_finance_charges (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_finance_charges(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INVALID_FIN_CHARGE'),
               finance_charges
        FROM  ar_trx_header_gt
        WHERE finance_charges  IS NOT NULL
        AND   finance_charges not in ( 'Y','N');

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_finance_charges(-)' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.validate_finance_charges '
          ||sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;

END validate_finance_charges;


PROCEDURE validate_related_cust_trx_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_related_cust_trx_id(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INAVLID_CROSS_REF'),
               related_customer_trx_id
        FROM  ar_trx_header_gt gt
        WHERE gt.related_customer_trx_id IS NOT NULL
        AND   NOT EXISTS (
            SELECT 'X'
            FROM   ra_customer_trx trx, ra_batch_sources bs, ar_lookups look,
                   ra_cust_trx_types types
            where trx.batch_source_id = bs.batch_source_id
            and trx.cust_trx_type_id = types.cust_trx_type_id
            and look.lookup_type = 'INV/CM'
            and types.type = look.lookup_code
            and types.type <> 'BR'
            and trx.complete_flag = 'Y'
            and trx.customer_trx_id = gt.related_customer_trx_id
            and trx.bill_to_customer_id  IN
                (
                select distinct cr.cust_account_id
                from hz_cust_acct_relate cr
                where cr.related_cust_account_id = gt.bill_to_customer_id
                and cr.status = 'A'
                and cr.bill_to_flag ='Y'
                --union
                --select to_number(gt.bill_to_customer_id)
                --from dual
                UNION
                SELECT acc.cust_account_id
                FROM ar_paying_relationships_v rel,
                     hz_cust_accounts acc
                WHERE rel.party_id = acc.party_id
                AND rel.related_cust_account_id = gt.bill_to_customer_id
                AND gt.trx_date BETWEEN effective_start_date
                                  AND effective_end_date));

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_related_cust_trx_id(-)' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.validate_related_cust_trx_id '
          ||sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;

END validate_related_cust_trx_id;

PROCEDURE validate_gl_date (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

    /* 5921925 - added post_to_gl logic */
    CURSOR cglDate IS
        select hdr.trx_header_id, hdr.gl_date, hdr.invoicing_rule_id,
               NVL(tt.post_to_gl, 'N') post_to_gl
        from ar_trx_header_gt hdr,
             ra_cust_trx_types tt
        where tt.cust_trx_type_id = hdr.cust_trx_type_id;

    l_period_status  gl_period_statuses.closing_status%type  DEFAULT 'U';
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_gl_date(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR cglDateRec IN cglDate
    LOOP

      IF cglDateRec.post_to_gl = 'Y'
      THEN
        /* Validate the gl_date for open period, etc */
        BEGIN
            SELECT closing_status
            INTO l_period_status
            FROM   gl_period_statuses g,
                  gl_sets_of_books   b
            WHERE  b.set_of_books_id         = g.set_of_books_id
            AND    g.set_of_books_id         = arp_global.set_of_books_id
            AND    g.period_type             = b.accounted_period_type
            AND    g.application_id          = 222
            AND    g.adjustment_period_flag  = 'N'
            AND    closing_status           <> 'C'
            AND    trunc(cglDateRec.gl_date) between start_date and end_date;

            IF l_period_status NOT IN ( 'O', 'F')
            THEN
                INSERT INTO ar_trx_errors_gt (
                    trx_header_id,
                    error_message,
                    invalid_value)
                    values
                    ( cglDateRec.trx_header_id,
                    arp_standard.fnd_message('AR_INAPI_NO_PERIOD_FOR_GL_DATE'),
                    cglDateRec.gl_date );
            END IF;

            IF cglDateRec.invoicing_rule_id IS NOT NULL
            THEN
                IF cglDateRec.invoicing_rule_id = -2
                THEN
                    IF l_period_status not in ('O', 'F' , 'U')
                    THEN
                        INSERT INTO ar_trx_errors_gt (
                            trx_header_id,
                            error_message,
                            invalid_value)
                        values
                            ( cglDateRec.trx_header_id,
                            arp_standard.fnd_message('AR_INAPI_BAD_GL_DATE_FOR_ADV'),
                            cglDateRec.gl_date );
                    END IF;
                ELSIF cglDateRec.invoicing_rule_id = -3
                THEN
                    IF l_period_status not in ('O', 'F' , 'U', 'N')
                    THEN
                        INSERT INTO ar_trx_errors_gt (
                            trx_header_id,
                            error_message,
                            invalid_value)
                        values
                            ( cglDateRec.trx_header_id,
                            arp_standard.fnd_message('AR_INAPI_BAD_GL_DATE_FOR_ARR'),
                            cglDateRec.gl_date );
                    END IF;
                END IF;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO ar_trx_errors_gt (
                    trx_header_id,
                    error_message,
                    invalid_value)
                    values
                    ( cglDateRec.trx_header_id,
                    arp_standard.fnd_message('AR_TAPI_NO_PERIOD_FOR_GL_DATE'),
                    cglDateRec.gl_date );

        END;
      ELSE
         /* post_to_gl = 'N'.. if a gl_date is supplied,
            then it's an error */
         IF cglDateRec.gl_date IS NOT NULL
         THEN
                INSERT INTO ar_trx_errors_gt (
                    trx_header_id,
                    error_message,
                    invalid_value)
                    values
                    ( cglDateRec.trx_header_id,
                    arp_standard.fnd_message('AR_RAXTRX-1785'),
                    cglDateRec.gl_date );

         END IF;
      END IF;
    END LOOP;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_gl_date(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.validate_gl_date '||sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
END;

PROCEDURE validate_agreement_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_agreement_id(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt (
            trx_header_id,
            error_message,
            invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INVALID_AGREEMENT_ID'),
               agreement_id
        FROM  ar_trx_header_gt gt
        WHERE  gt.agreement_id IS NOT NULL
        AND    NOT EXISTS (
                SELECT 'X'
                from hz_cust_accounts cust_acct,
                hz_parties  party,
                so_agreements a,
                qp_lookups sl
                where a.agreement_type_code = sl.lookup_code
                and sl.lookup_type = 'QP_AGREEMENT_TYPE'
                and a.customer_id = cust_acct.cust_account_id(+)
                and cust_acct.party_id = party.party_id(+)
                and a.customer_id in ( select cr.cust_account_id
                                        from hz_cust_acct_relate cr
                                        where related_cust_account_id =
                                                gt.bill_to_customer_id
                                        and cr.status = 'A'
                                        and cr.bill_to_flag='Y'
                                        union
                                        select to_number(gt.bill_to_customer_id)
                                        from dual
                                        union
                                        select -1 /* no customer case */ from dual )
                and gt.trx_date between
                        nvl( trunc( a.start_date_active ), gt.trx_date )
                        and nvl( trunc( a.end_date_active ), gt.trx_date )
                and gt.agreement_id = a.agreement_id);

     IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_agreement_id(-)' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.validate_agreement_id '||
          sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;

END validate_agreement_id;

PROCEDURE Get_batch_source_details (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

    l_bs_batch_auto_num_flag            ra_batch_sources.auto_batch_numbering_flag%type;
    l_bs_auto_trx_num_flag              ra_batch_sources.auto_trx_numbering_flag%type;
    l_dft_ref                           ra_batch_sources.default_reference%type;
    l_cust_trx_type_id                  ra_batch_sources.default_inv_trx_type%type;
    l_copy_doc_number_flag              ra_batch_sources.copy_doc_number_flag%type;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.Get_batch_source_details(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT   bs.auto_batch_numbering_flag,
             bs.auto_trx_numbering_flag,
             bs.default_reference,
             bs.default_inv_trx_type, -- trx_type_id,
             bs.copy_doc_number_flag
      INTO   l_bs_batch_auto_num_flag,
             l_bs_auto_trx_num_flag,
             l_dft_ref,
             l_cust_trx_type_id,
             l_copy_doc_number_flag
      FROM   RA_BATCH_SOURCES bs
      WHERE  batch_source_id = (SELECT gt.batch_source_id
                             FROM   ar_trx_header_gt gt
                             WHERE  rownum =1 );

        IF pg_debug = 'Y'
        THEN
            debug ('Cust Trx Type Id ' || l_cust_trx_type_id);
            debug ('Auto Batch Numbering Flag ' || l_bs_batch_auto_num_flag);
            debug ('Auto Trx Numbering Flag ' || l_bs_auto_trx_num_flag);
        END IF;

      -- Bug # 3099975
      -- ORASHID
      -- 21-AUG-2003 (END)


      UPDATE ar_trx_header_gt
        SET  auto_batch_numbering_flag =  l_bs_batch_auto_num_flag,
             auto_trx_numbering_flag = l_bs_auto_trx_num_flag,
             copy_doc_number_flag  = l_copy_doc_number_flag,
             cust_trx_type_id = NVL(cust_trx_type_id, l_cust_trx_type_id),
             ct_reference = decode(l_dft_ref,
                                   1, interface_header_attribute1,
                                   2, interface_header_attribute2,
                                   3, interface_header_attribute3,
                                   4, interface_header_attribute4,
                                   5, interface_header_attribute5,
                                   6, interface_header_attribute6,
                                   7, interface_header_attribute7,
                                   8, interface_header_attribute8,
                                   9, interface_header_attribute9,
                                   10, interface_header_attribute10,
                                   11, interface_header_attribute11,
                                   12, interface_header_attribute12,
                                   13, interface_header_attribute13,
                                   14, interface_header_attribute14,
                                   15, interface_header_attribute15,
                                   NULL );

      IF pg_debug = 'Y'
      THEN
        debug ('AR_INVOICE_UTILS.Get_batch_source_details(-)' );
      END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	       INSERT INTO ar_trx_errors_gt (
                trx_header_id,
                error_message,
                invalid_value)
            SELECT gt.trx_header_id,
                   arp_standard.fnd_message('AR_INAPI_INVALID_BATCH_SOURCE'),
                   gt.batch_source_id
            FROM  ar_trx_header_gt gt;
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.Get_batch_source_details '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END get_batch_source_details;


PROCEDURE Get_trx_type_details (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

    l_default_printing_option          ra_cust_trx_types.default_printing_option%type;
    l_default_status                   ra_cust_trx_types.default_status%type;
    l_allow_freight_flag               ra_cust_trx_types.allow_freight_flag%type;
    l_tax_calculation_flag             ra_cust_trx_types.tax_calculation_flag%type;
    l_allow_overapplication_flag       ra_cust_trx_types.allow_overapplication_flag%type;
    l_creation_sign                    ra_cust_trx_types.creation_sign%type;
    l_natural_application_flag         ra_cust_trx_types.natural_application_only_flag%type;
    l_accounting_affect_flag           ra_cust_trx_types.accounting_affect_flag%type;
    l_cust_trx_type_name               ra_cust_trx_types.name%type;
    l_trx_type                         ra_cust_trx_types.type%type;

    CURSOR cust_trx_type_c IS
        SELECT distinct cust_trx_type_id
        FROM  ar_trx_header_gt;
BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.Get_trx_type_details(+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR cust_trx_type_rec IN cust_trx_type_c
    LOOP
        BEGIN
            SELECT default_printing_option,
                   default_status,
                   allow_freight_flag,
                   tax_calculation_flag,
                   allow_overapplication_flag,
                   creation_sign,
                   natural_application_only_flag,
                   accounting_affect_flag,
                   name,
                   type
            INTO   l_default_printing_option,
                   l_default_status,
                   l_allow_freight_flag,
                   l_tax_calculation_flag,
                   l_allow_overapplication_flag,
                   l_creation_sign,
                   l_natural_application_flag,
                   l_accounting_affect_flag,
                   l_cust_trx_type_name,
                   l_trx_type
            FROM   ra_cust_trx_types
            WHERE  cust_trx_type_id = cust_trx_type_rec.cust_trx_type_id;


            IF pg_debug = 'Y'
            THEN
                debug ('Default Priniting Option '|| l_default_printing_option );
                debug ('Default Status '|| l_default_status );
                debug ('Tax Calculation Flag '|| l_tax_calculation_flag );
                debug ('Over Application Flag '|| l_allow_overapplication_flag );
                debug ('Creation Sign '|| l_creation_sign );
                debug ('Natural Application Flag '|| l_natural_application_flag );
                debug ('Accounting affect flag  '|| l_accounting_affect_flag );
                debug ('Cust Trx Type Name  '|| l_cust_trx_type_name );
            END IF;

            -- Bug # 3099975
            -- ORASHID
            -- 21-AUG-2003 (END)
            UPDATE ar_trx_header_gt
              SET  printing_option = nvl(printing_option,l_default_printing_option),
                   status_trx = NVL(status_trx,l_default_status),
                   allow_freight_flag  = l_allow_freight_flag,
                   tax_calculation_flag = l_tax_calculation_flag,
                   allow_overapplication_flag = l_allow_overapplication_flag,
                   creation_sign = l_creation_sign,
                   natural_application_only_flag = l_natural_application_flag,
                   accounting_affect_flag = l_accounting_affect_flag,
                   cust_trx_type_name    = l_cust_trx_type_name,
                   trx_class = l_trx_type
              WHERE cust_trx_type_id =  cust_trx_type_rec.cust_trx_type_id;

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     INSERT INTO ar_trx_errors_gt (
                        trx_header_id,
                        error_message,
                        invalid_value)
                     SELECT gt.trx_header_id,
                        arp_standard.fnd_message('ARTA_INVALID_TRX_TYPE'),
                        gt.cust_trx_type_id
                     FROM  ar_trx_header_gt gt
                     WHERE gt.cust_trx_type_id = cust_trx_type_rec.cust_trx_type_id;

        END;
    END LOOP;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.Get_trx_type_details(-)' );
    END IF;

    EXCEPTION


        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.Get_trx_type_details '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END get_trx_type_details;


PROCEDURE populate_salesreps (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_salesreps(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
/*Bug8266696*/
    UPDATE ar_trx_header_gt gt
        SET gt.primary_salesrep_id =
            ( SELECT SU.PRIMARY_SALESREP_ID
              FROM HZ_CUST_ACCT_SITES ACCT_SITE,
                   HZ_PARTY_SITES PARTY_SITE,
                   HZ_LOCATIONS LOC,
                   HZ_CUST_SITE_USES SU,
                   FND_TERRITORIES_VL T
              WHERE  ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND    ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND    LOC.LOCATION_ID =  PARTY_SITE.LOCATION_ID
              AND    LOC.COUNTRY = T.TERRITORY_CODE
              AND    ACCT_SITE.CUST_ACCOUNT_ID = gt.bill_to_customer_id
              AND    SU.SITE_USE_ID = NVL(gt.bill_to_site_use_id, SU.SITE_USE_ID)
              AND    SU.SITE_USE_CODE = 'BILL_TO'
              AND    (SU.SITE_USE_ID =   gt.bill_to_site_use_id
                   OR (gt.bill_to_site_use_id IS NULL
                   AND SU.STATUS = 'A'  AND ACCT_SITE.STATUS = 'A' ))
              AND SU.PRIMARY_FLAG = 'Y' )
     WHERE    gt.primary_salesrep_id IS NULL
     AND NVL(gt.late_charges_assessed,'N') <> 'Y';

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_salesreps(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_salesreps '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END populate_salesreps;


PROCEDURE populate_bill_to_customer_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_bill_to_customer_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if bill to customer number is passed then that should be used
  -- derive the bill to customer id.

  UPDATE ar_trx_header_gt gt
  SET    gt.bill_to_customer_id =
           (SELECT cust_acct.cust_account_id
            FROM   hz_cust_accounts cust_acct
            WHERE  cust_acct.account_number = gt.bill_to_account_number
            AND    cust_acct.status = 'A'
            AND   gt.bill_to_customer_id IS NULL
            AND   gt.bill_to_account_number IS NOT NULL
           )
  WHERE  gt.bill_to_customer_id IS NULL
  AND    gt.bill_to_account_number IS NOT NULL;

  -- if ship to customer number is passed then that should be used
  -- derive the bill to customer id.

  UPDATE ar_trx_header_gt gt
  SET    gt.bill_to_customer_id =
           (SELECT cust_acct.cust_account_id
            FROM   hz_cust_accounts cust_acct
            WHERE  cust_acct.account_number = gt.ship_to_account_number
            AND    cust_acct.status = 'A'
            AND   gt.bill_to_customer_id IS NULL
            AND   gt.ship_to_account_number IS NOT NULL
           )
  WHERE  gt.bill_to_customer_id IS NULL
  AND    gt.bill_to_account_number IS NOT NULL;

  -- if ship to customer id is passed then that should be used
  -- derive the bill to customer id.

  UPDATE ar_trx_header_gt gt
  SET    gt.bill_to_customer_id = gt.ship_to_customer_id
  WHERE  gt.bill_to_customer_id IS NULL
  AND    gt.ship_to_customer_id IS NOT NULL;


  -- for the remaining rows bill to customer name should be used
  -- derive the bill to customer id.

  UPDATE ar_trx_header_gt gt
  SET    gt.bill_to_customer_id =
           (SELECT cust_acct.cust_account_id
            FROM  hz_cust_accounts cust_acct,
                  hz_parties party
            WHERE cust_acct.party_id = party.party_id
            AND   party.party_name = gt.bill_to_customer_name
            AND   gt.bill_to_customer_id IS NULL
            AND   gt.bill_to_customer_name IS NOT NULL
           )
  WHERE  gt.bill_to_customer_id IS NULL
  AND    gt.bill_to_customer_name IS NOT NULL;


  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_bill_to_customer_id(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error in AR_INVOICE_UTILS.populate_bill_to_customer_id '
        ||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END populate_bill_to_customer_id;


PROCEDURE populate_bill_to_site_use_id (
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2)  IS

BEGIN

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_bill_to_site_use_id (+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- We are here to populate bill_to_site_use_id column.   We should only
  -- do it for rows where it is not already populated.  Moreover, first we
  -- should see if bill_to_address_id is populated then we should derive the
  -- bill_to_site_use_id from that.

  UPDATE ar_trx_header_gt gt
  SET    bill_to_site_use_id = (
           SELECT site_use_id
           FROM   hz_cust_site_uses
           WHERE  site_use_code = 'BILL_TO'
           AND    cust_acct_site_id = gt.bill_to_address_id
           AND    gt.bill_to_site_use_id IS NULL
           AND    gt.bill_to_address_id IS NOT NULL)
  WHERE  gt.bill_to_site_use_id IS NULL
  AND    gt.bill_to_address_id IS NOT NULL;

  -- Now we will worry about cases where only customer id
  -- is populated and we must derive the primary ship to site id.

  UPDATE ar_trx_header_gt gt
  SET    bill_to_site_use_id = (
           SELECT site_use_id
           FROM   hz_cust_site_uses
           WHERE  primary_flag = 'Y'
           AND    site_use_code = 'BILL_TO'
           AND    cust_acct_site_id IN (
                    SELECT cust_acct_site_id
                    FROM   hz_cust_acct_sites
                   WHERE  cust_account_id = gt.bill_to_customer_id))
  WHERE gt.bill_to_site_use_id IS NULL;

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_bill_to_site_use_id (-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error in AR_INVOICE_UTILS.populate_bill_to_site_use_id '
        ||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END populate_bill_to_site_use_id;

PROCEDURE populate_paying_site_use_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

    CURSOR cSiteUSe IS
         select sgt.bill_to_site_use_id,  sgt.bill_to_customer_id,
                sgt.paying_customer_id
            from ar_trx_header_gt sgt
            WHERE sgt.bill_to_customer_id = sgt.paying_customer_id;

BEGIN
  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_paying_site_use_id(+)' );
  END IF;

  -- first populate paying_customer_id if it is null
  UPDATE ar_trx_header_gt
    set  paying_customer_id = bill_to_customer_id
  WHERE  paying_customer_id IS NULL;

  FOR cSiteUSeRec IN cSiteUSe
  LOOP
        UPDATE ar_trx_header_gt ugt
            set ugt.paying_site_use_id = cSiteUSeRec.bill_to_site_use_id
        WHERE  ugt.paying_site_use_id IS NULL
        AND    ugt.paying_customer_id = cSiteUSeRec.paying_customer_id;

  END LOOP;


  -- incase paying_customer_id and bill_to_customer_id is
  -- different

  UPDATE ar_trx_header_gt gt
  SET    paying_site_use_id = (
           SELECT site_use_id
           FROM   hz_cust_site_uses
           WHERE  primary_flag = 'Y'
           AND    site_use_code = 'BILL_TO'
           AND    cust_acct_site_id IN (
                    SELECT cust_acct_site_id
                    FROM   hz_cust_acct_sites
                   WHERE  cust_account_id = gt.paying_customer_id))
  WHERE gt.paying_site_use_id IS NULL;

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_paying_site_use_id(-)' );
  END IF;
END;

PROCEDURE populate_bill_to_address_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_bill_to_address_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- We are here to populate bill_to_address_id column.   We should only
  -- do it for rows where it is not already populated.  Moreover, first we
  -- should see if bill_to_site_use_id is populated then we should derive the
  -- bill_to_address_id from that.

  UPDATE ar_trx_header_gt gt
  SET    bill_to_address_id = (
           SELECT site_use_id
           FROM   hz_cust_site_uses
           WHERE  site_use_code = 'BILL_TO'
           AND    site_use_id= gt.bill_to_site_use_id
           AND    gt.bill_to_address_id IS NULL
           AND    gt.bill_to_site_use_id IS NOT NULL)
  WHERE  gt.bill_to_address_id IS NULL
  AND    gt.bill_to_site_use_id IS NOT NULL;

  -- Now if it is still not populated then you default it from
  -- primary bill to.

  UPDATE ar_trx_header_gt gt
  SET gt.bill_to_address_id = (
      SELECT su.cust_acct_site_id
      FROM   hz_cust_acct_sites acct_site,
             hz_party_sites party_site,
             hz_locations loc,
             hz_cust_site_uses su,
             fnd_territories_vl t
      WHERE  acct_site.cust_acct_site_id = su.cust_acct_site_id
      AND    acct_site.party_site_id = party_site.party_site_id
      AND    loc.location_id =  party_site.location_id
      AND    loc.country = t.territory_code
      AND    acct_site.cust_account_id = gt.bill_to_customer_id
      AND    SU.SITE_USE_ID = NVL(gt.bill_to_site_use_id, SU.SITE_USE_ID)
      AND    SU.SITE_USE_CODE = 'BILL_TO'
      AND    (SU.SITE_USE_ID =   gt.bill_to_site_use_id
              OR (gt.bill_to_site_use_id IS NULL
      AND SU.STATUS = 'A'  AND ACCT_SITE.STATUS = 'A' ))
      AND SU.PRIMARY_FLAG = 'Y' )
  WHERE gt.bill_to_address_id IS NULL;

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_bill_to_address_id(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error in AR_INVOICE_UTILS.populate_bill_to_address_id '
        ||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END populate_bill_to_address_id;


PROCEDURE populate_remit_to_address_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

l_site_use_id               NUMBER;

CURSOR HdrGtc IS
    SELECT distinct bill_to_site_use_id
    FROM   ar_trx_header_gt
    WHERE  bill_to_site_use_id IS NOT NULL
    AND    remit_to_address_id IS NULL;

-- Get country, state, and zip code info. for each bill to site
CURSOR bill_to_site_c IS
    SELECT su.site_use_id,
           loc.state,
           loc.country,
           loc.postal_code
    FROM   hz_cust_acct_sites acct_site,
           hz_party_sites party_site,
           hz_locations loc,
           hz_cust_site_uses   su
    WHERE  acct_site.cust_acct_site_id  = su.cust_acct_site_id
    AND    su.site_use_id = l_site_use_id
    AND    acct_site.party_site_id = party_site.party_site_id
    AND    loc.location_id = party_site.location_id;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_remit_to_address_id (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR HdrGtRec IN HdrGtc
    LOOP
        l_site_use_id := HdrGtRec.bill_to_site_use_id;
        FOR bill_to_site_rec IN bill_to_site_c
        LOOP
            IF pg_debug = 'Y'
            THEN
                debug ('Site Use Id ' || bill_to_site_rec.site_use_id);
                debug ('State ' || bill_to_site_rec.state);
                debug ('Country ' || bill_to_site_rec.country);
                debug ('Postal code  ' || bill_to_site_rec.postal_code);
            END IF;

            UPDATE ar_trx_header_gt gt
            SET  remit_to_address_id = (
                    SELECT acct_site.cust_acct_site_id
                    FROM   hz_cust_acct_sites acct_site,
                           hz_party_sites party_site,
                           hz_locations loc,
                           fnd_territories_vl territory,
                           ra_remit_tos  rt
                    WHERE  NVL( acct_site.status, 'A' )  = 'A'
                    AND    acct_site.cust_acct_site_id  = rt.address_id
                    AND    acct_site.party_site_id = party_site.party_site_id
                    AND    loc.location_id = party_site.location_id
                    AND    rt.status             = 'A'
                    AND    rt.country            = bill_to_site_rec.country
                    AND    loc.country = territory.territory_code
                    AND    (
                            bill_to_site_rec.state = NVL( rt.state, bill_to_site_rec.state )
                            OR
                                (
                                bill_to_site_rec.state IS NULL   AND
                                rt.state      IS NULL
                                )
                            OR  (
                                bill_to_site_rec.state IS NULL         AND
                                bill_to_site_rec.postal_code <= NVL( rt.postal_code_high,
                                                bill_to_site_rec.postal_code )   AND
                                bill_to_site_rec.postal_code >= NVL( rt.postal_code_low,
                                                bill_to_site_rec.postal_code )   AND
                                    (
                                    postal_code_low  IS NOT NULL
                                    OR  postal_code_high IS NOT NULL
                                    )
                                )
                            )
                    AND    (
                            (
                                bill_to_site_rec.postal_code <= NVL( rt.postal_code_high,
                                                 bill_to_site_rec.postal_code )  AND
                                bill_to_site_rec.postal_code >= NVL( rt.postal_code_low,
                                                 bill_to_site_rec.postal_code )
                            )
                    OR      (
                                bill_to_site_rec.postal_code IS NULL  AND
                                rt.postal_code_low  IS NULL  AND
                                rt.postal_code_high IS NULL
                            )
                           ) and rownum = 1)
            WHERE gt.bill_to_site_use_id = bill_to_site_rec.site_use_id
            AND   gt.remit_to_address_id IS NULL;
        END LOOP;
    END LOOP;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_remit_to_address_id (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_remit_to_address_id '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END populate_remit_to_address_id;


PROCEDURE populate_bill_to_contact_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

    CURSOR bill_to_customer_id_c IS
        SELECT distinct bill_to_customer_id,
               bill_to_address_id
        FROM   ar_trx_header_gt
        WHERE  bill_to_contact_id IS NULL;
    l_contact_id            HZ_CUST_ACCOUNT_ROLES.CUST_ACCOUNT_ROLE_ID%type;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_bill_to_contact_id(+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- the cursor is required becoz the select to get the contact id
    -- returns more than one row. In case it returns more than one row
    -- then contact id will be null.
    FOR bill_to_customer_id_rec IN bill_to_customer_id_c
    LOOP
        BEGIN
            SELECT distinct ACCT_ROLE.CUST_ACCOUNT_ROLE_ID  -- CONTACT_ID
            INTO   l_contact_id
              FROM HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,HZ_PARTIES PARTY,HZ_RELATIONSHIPS REL,
                   HZ_ORG_CONTACTS ORG_CONT,HZ_PARTIES REL_PARTY
              WHERE ACCT_ROLE.PARTY_ID = REL.PARTY_ID
              AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
              AND  ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
              AND REL.SUBJECT_ID =  PARTY.PARTY_ID
              AND REL.PARTY_ID = REL_PARTY.PARTY_ID
              AND  REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
              AND REL.OBJECT_TABLE_NAME =  'HZ_PARTIES'
              AND REL.DIRECTIONAL_FLAG = 'F'
              AND ACCT_ROLE.CUST_ACCOUNT_ID  = bill_to_customer_id_rec.bill_to_customer_id
              AND ACCT_ROLE.CUST_ACCT_SITE_ID =  bill_to_customer_id_rec.bill_to_address_id
              AND ACCT_ROLE.STATUS = 'A' ;

        IF pg_debug = 'Y'
        THEN
            debug ('Bill to contact Id '|| l_contact_id);
            debug ('Bill to customer Id ' || bill_to_customer_id_rec.bill_to_customer_id);
            debug ('Bill to Address Id ' || bill_to_customer_id_rec.bill_to_address_id);
        END IF;
        UPDATE ar_trx_header_gt
            SET  bill_to_contact_id = l_contact_id
        WHERE bill_to_customer_id = bill_to_customer_id_rec.bill_to_customer_id
        AND   bill_to_address_id = bill_to_customer_id_rec.bill_to_address_id
        AND   bill_to_contact_id IS NOT NULL;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            WHEN TOO_MANY_ROWS THEN
                NULL;
        END;
    END LOOP;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_bill_to_contact_id(-)' );
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.populate_bill_to_contact_id '
          ||sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;

END populate_bill_to_contact_id;


PROCEDURE populate_ship_to_customer_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_ship_to_customer_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if bill to customer number is passed then that should be used
  -- derive the bill to customer id.

  UPDATE ar_trx_header_gt gt
  SET    gt.ship_to_customer_id =
           (SELECT cust_acct.cust_account_id
            FROM   hz_cust_accounts cust_acct
            WHERE  cust_acct.account_number = gt.ship_to_account_number
            AND    cust_acct.status = 'A'
            AND   gt.ship_to_customer_id IS NULL
            AND   gt.ship_to_account_number IS NOT NULL
           )
  WHERE  gt.ship_to_customer_id IS NULL
  AND    gt.ship_to_account_number IS NOT NULL;

  -- for the remaining rows bill to customer name should be used
  -- derive the bill to customer id.

  UPDATE ar_trx_header_gt gt
  SET    gt.ship_to_customer_id =
           (SELECT cust_acct.cust_account_id
            FROM  hz_cust_accounts cust_acct,
                  hz_parties party
            WHERE cust_acct.party_id = party.party_id
            AND   party.party_name = gt.ship_to_customer_name
            AND    cust_acct.status = 'A'
            AND   gt.ship_to_customer_id IS NULL
            AND   gt.ship_to_customer_name IS NOT NULL
           )
  WHERE  gt.ship_to_customer_id IS NULL
  AND    gt.ship_to_customer_name IS NOT NULL;


  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_ship_to_customer_id(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error in AR_INVOICE_UTILS.populate_ship_to_customer_id '
        ||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END populate_ship_to_customer_id;


PROCEDURE populate_ship_to_address_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2)  IS

BEGIN

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_ship_to_address_id(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- We are here to populate ship_to_address_id column.   We should only
  -- do it for rows where it is not already populated.  Moreover, first we
  -- should see if ship_to_site_use_id is populated then we should derive the
  -- ship_to_address_id from that.

  UPDATE ar_trx_header_gt gt
  SET    ship_to_address_id = (
           SELECT site_use_id
           FROM   hz_cust_site_uses
           WHERE  site_use_code = 'SHIP_TO'
           AND    site_use_id= gt.ship_to_site_use_id
           AND    gt.ship_to_address_id IS NULL
           AND    gt.ship_to_site_use_id IS NOT NULL)
  WHERE  gt.ship_to_address_id IS NULL
  AND    gt.ship_to_site_use_id IS NOT NULL;

  -- Now we will worry about cases where only customer id
  -- is populated and we must derive the primary ship to site id.


  UPDATE ar_trx_header_gt gt
  SET gt.ship_to_address_id = (
        SELECT su.cust_acct_site_id
        FROM   hz_cust_acct_sites acct_site,
               hz_party_sites party_site,
               hz_locations loc,
               hz_cust_site_uses su,
               fnd_territories_vl t
        WHERE  acct_site.cust_acct_site_id = su.cust_acct_site_id
        AND    acct_site.party_site_id = party_site.party_site_id
        AND    loc.location_id =  party_site.location_id
        AND    loc.country = t.territory_code
        AND    acct_site.cust_account_id = gt.ship_to_customer_id
        AND    su.site_use_id = nvl(gt.ship_to_site_use_id, su.site_use_id)
        AND    su.site_use_code = 'ship_to'
        AND    (su.site_use_id =   gt.ship_to_site_use_id
                or (gt.ship_to_site_use_id IS NULL
        AND su.status = 'a'  AND acct_site.status = 'a' ))
        AND su.primary_flag = 'y' )
  WHERE gt.ship_to_address_id IS NULL;

  IF pg_debug = 'Y' THEN
    debug ('AR_INVOICE_UTILS.populate_ship_to_address_id(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error in AR_INVOICE_UTILS.populate_ship_to_address_id '
        ||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END populate_ship_to_address_id;


PROCEDURE populate_ship_to_contact_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2)   IS

    CURSOR ship_to_customer_id_c IS
        SELECT distinct ship_to_customer_id,
               ship_to_address_id
        FROM   ar_trx_header_gt
        WHERE  ship_to_contact_id IS NULL;
    l_contact_id            HZ_CUST_ACCOUNT_ROLES.CUST_ACCOUNT_ROLE_ID%type;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_ship_to_contact_id(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- the cursor is required becoz the select to get the contact id
    -- returns more than one row. In case it returns more than one row
    -- then contact id will be null.
    FOR ship_to_customer_id_rec IN ship_to_customer_id_c
    LOOP
        BEGIN
            SELECT distinct ACCT_ROLE.CUST_ACCOUNT_ROLE_ID  -- CONTACT_ID
            INTO   l_contact_id
              FROM HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,HZ_PARTIES PARTY,HZ_RELATIONSHIPS REL,
                   HZ_ORG_CONTACTS ORG_CONT,HZ_PARTIES REL_PARTY
              WHERE ACCT_ROLE.PARTY_ID = REL.PARTY_ID
              AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
              AND  ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
              AND REL.SUBJECT_ID =  PARTY.PARTY_ID
              AND REL.PARTY_ID = REL_PARTY.PARTY_ID
              AND  REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
              AND REL.OBJECT_TABLE_NAME =  'HZ_PARTIES'
              AND REL.DIRECTIONAL_FLAG = 'F'
              AND ACCT_ROLE.CUST_ACCOUNT_ID  = ship_to_customer_id_rec.ship_to_customer_id
              AND ACCT_ROLE.CUST_ACCT_SITE_ID =  ship_to_customer_id_rec.ship_to_address_id
              AND ACCT_ROLE.STATUS = 'A' ;

        IF pg_debug = 'Y'
        THEN
            debug ('Ship to Contact Id ' || l_contact_id);
            debug ('Ship to Customer Id ' || ship_to_customer_id_rec.ship_to_customer_id);
            debug ('Ship to Address Id ' || ship_to_customer_id_rec.ship_to_address_id);
        END IF;
        UPDATE ar_trx_header_gt
            SET  ship_to_contact_id = l_contact_id
        WHERE ship_to_customer_id = ship_to_customer_id_rec.ship_to_customer_id
        AND   ship_to_address_id = ship_to_customer_id_rec.ship_to_address_id;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            WHEN TOO_MANY_ROWS THEN
                NULL;
        END;
    END LOOP;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_ship_to_contact_id(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_ship_to_contact_id '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END;

procedure populate_territory (
    p_trx_system_param_rec      IN  AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2)  IS

    l_trx_date                  DATE;
    l_salesrep_id               NUMBER;
    CURSOR cSalesTer IS
        SELECT /*+ LEADING(gt) */ st.territory_id territory_id, gt.primary_salesrep_id
        FROM   ra_salesrep_territories st, ar_trx_header_gt gt
        WHERE  st.salesrep_id = gt.primary_salesrep_id
        AND    'A'            = NVL(st.status(+), 'A')
        AND    gt.trx_date BETWEEN NVL(st.start_date_active(+), gt.trx_date  )
                          AND NVL(st.end_date_active(+), gt.trx_date );

    CURSOR cBillTo IS
        SELECT /*+ LEADING(gt) */ hz.territory_id, gt.bill_to_site_use_id
        FROM   HZ_CUST_SITE_USES hz, ar_trx_header_gt gt
        WHERE  hz.site_use_id = gt.bill_to_site_use_id;

    CURSOR cShipTo IS
        SELECT /*+ LEADING(gt) */ site_uses.territory_id, gt.ship_to_site_use_id,
               gt.ship_to_customer_id
        FROM   HZ_CUST_SITE_USES site_uses,
	       ar_trx_header_gt gt
	WHERE  site_uses.SITE_USE_CODE = 'SHIP_TO'
        AND    site_uses.site_use_id = gt.ship_to_site_use_id
        AND    site_uses.primary_flag = 'Y';

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_populate_territory  (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*----------------------------------------------------------------+
     |  Default the territory flexfield from                           |
     |  - The Bill To site use                                         |
     |  - The Ship To Site Use                                         |
     |  - The Primary Salesrep's territory                             |
     |  depending on the value of the DEFAULT_TERRITORY system option  |
     +-----------------------------------------------------------------*/
    IF p_trx_system_param_rec.default_territory = 'BILL'
    THEN
        FOR cBillToRec IN cBillTo
        LOOP
            UPDATE ar_trx_header_gt
                SET territory_id = cBillToRec.territory_id
             WHERE bill_to_site_use_id = cBillToRec.bill_to_site_use_id;
        END LOOP;
    ELSIF p_trx_system_param_rec.default_territory = 'SHIP'
    THEN
        FOR cShipToRec IN cShipTo
        LOOP
            UPDATE ar_trx_header_gt
                SET territory_id = cShipToRec.territory_id
             WHERE ship_to_site_use_id = cShipToRec.ship_to_site_use_id
             AND   ship_to_customer_id  = cShipToRec.ship_to_customer_id;
        END LOOP;
    ELSIF p_trx_system_param_rec.default_territory = 'SALES'
    THEN
        FOR cSalesTerRec IN cSalesTer
        LOOP
            UPDATE ar_trx_header_gt
                SET territory_id = cSalesTerRec.territory_id
             WHERE primary_salesrep_id = cSalesTerRec.primary_salesrep_id;
        END LOOP;
    END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_populate_territory  (-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_territory '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

/* 4188835 - call legal_entity function to default it for
   and trx rows that do not have one */
procedure populate_legal_entity (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2)  IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_legal_entity(+)' );
    END IF;

      /* single update to default value */
      UPDATE ar_trx_header_gt
      SET  legal_entity_id = arp_legal_entity_util.get_default_le(
                sold_to_customer_id,
                bill_to_customer_id,
                cust_trx_type_id,
                batch_source_id)
      WHERE legal_entity_id is NULL;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_legal_entity(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_legal_entity '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END populate_legal_entity;

procedure populate_customer_attributes (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2)  IS

BEGIN
    -- first get the site use id
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_customer_attributes  (+)' );
    END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('Getting bill_to_site_use_id(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

	populate_bill_to_site_use_id (
	x_errmsg            =>  x_errmsg,
	x_return_status     =>  x_return_status );

	IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		RETURN;
	END IF;

    -- Get the Term Id
    IF pg_debug = 'Y'
    THEN
        debug ('Getting bill_to_site_use_id(-)' );
        debug ('Getting term_id(+)' );
    END IF;

    -- Get term_id for NON-BFB enabled customers
    UPDATE ar_trx_header_gt gt
    SET    term_id = (SELECT tl.term_id
                     FROM   ra_terms              t_su,
                            ra_terms              t_cp1,
                            ra_terms              t_cp2,
                            ra_terms              tl, /*Bug 3984916*/
                            hz_customer_profiles  cp1,
                            hz_customer_profiles  cp2,
                            hz_cust_site_uses     su
                     WHERE  gt.bill_to_customer_id  = cp1.cust_account_id(+)
                     AND    su.site_use_id    = gt.bill_to_site_use_id
                     AND    cp2.cust_account_id   = gt.bill_to_customer_id
                     AND    su.site_use_id    = cp1.site_use_id(+)
                     AND    cp2.site_use_id   IS NULL
                     AND    su.payment_term_id = t_su.term_id(+)
                     AND    cp1.standard_terms = t_cp1.term_id(+)
                     AND    cp2.standard_terms = t_cp2.term_id(+)
                     AND    NVL(
                                  t_su.term_id,
                                  NVL(
                                       t_cp1.term_id,
                                       t_cp2.term_id
                                     )
                               )             = tl.term_id
                     AND gt.trx_date BETWEEN t_su.start_date_active(+)
                                        AND NVL(t_su.end_date_active(+),
                                                gt.trx_date)
                     AND gt.trx_date BETWEEN t_cp1.start_date_active(+)
                                        AND NVL(t_cp1.end_date_active(+),
                                                gt.trx_date)
                     AND gt.trx_date BETWEEN t_cp2.start_date_active(+)
                                        AND NVL(t_cp2.end_date_active(+),
                                                gt.trx_date))
    WHERE gt.term_id IS NULL
    AND gt.trx_class in ('INV','DM')  -- added for ER 5869149
    AND ar_bfb_utils_pvt.get_bill_level(gt.bill_to_customer_id) = 'N';

    -- R12:BFB : get term_id for BFB-enabled customers
    UPDATE ar_trx_header_gt gt
    SET term_id =  ar_bfb_utils_pvt.get_default_term(
                         gt.cust_trx_type_id,
                         gt.trx_date,
                         gt.org_id,
                         gt.bill_to_site_use_id,
                         gt.bill_to_customer_id)
    WHERE gt.term_id IS NULL
    AND gt.trx_class in ('INV','DM')  -- added for ER 5869149 **addtional condition**
    AND ar_bfb_utils_pvt.get_bill_level(gt.bill_to_customer_id) in ('A','S');

    IF pg_debug = 'Y'
    THEN
      debug ('Getting term_id(-)' );
      debug ('Getting billing_date(+)');
    END IF;

    UPDATE ar_trx_header_gt gt
    SET billing_date =  ar_bfb_utils_pvt.get_billing_date
                           (ar_bfb_utils_pvt.get_billing_cycle(gt.term_id),
                           nvl(gt.trx_date,sysdate))
    WHERE gt.term_id IS NOT NULL
    AND ar_bfb_utils_pvt.is_payment_term_bfb(gt.term_id) = 'Y'
    AND gt.billing_date IS NULL
    AND ar_bfb_utils_pvt.get_bill_level(gt.bill_to_customer_id) in ('A','S')
    AND nvl(ar_bfb_utils_pvt.get_cycle_type
       (ar_bfb_utils_pvt.get_billing_cycle(term_id)),'XXX') = 'RECURRING';

    -- override incorrect billing dates
    UPDATE ar_trx_header_gt gt
    SET billing_date =  ar_bfb_utils_pvt.get_billing_date
                           (ar_bfb_utils_pvt.get_billing_cycle(gt.term_id),
                           gt.billing_date)
    WHERE gt.term_id IS NOT NULL
    AND ar_bfb_utils_pvt.is_payment_term_bfb(gt.term_id) = 'Y'
    AND gt.billing_date IS NOT NULL
    AND billing_date <> ar_bfb_utils_pvt.get_billing_date(
                        ar_bfb_utils_pvt.get_billing_cycle(term_id),
                        gt.billing_date)
    AND nvl(ar_bfb_utils_pvt.get_cycle_type
       (ar_bfb_utils_pvt.get_billing_cycle(term_id)),'XXX') = 'RECURRING';

    IF pg_debug = 'Y'
    THEN
      debug ('Getting billing_date(-)');
      debug ('Getting term_due_date(+)' );
    END IF;

    -- Bug # 3099975
    -- ORASHID
    -- 21-AUG-2003 (END)

    -- get due_date for NON-BFB enabled
    UPDATE ar_trx_header_gt gt
    SET    term_due_date = trunc(arpt_sql_func_util.get_First_Due_Date(
                               gt.term_id, NVL(gt.trx_date,sysdate)))
    WHERE  gt.term_id IS NOT NULL
    AND    ar_bfb_utils_pvt.is_payment_term_bfb(gt.term_id) = 'N'
    AND NOT EXISTS
      (SELECT 'X'
       FROM ar_trx_errors_gt errgt
       WHERE errgt.trx_header_id = gt.trx_header_id);

    -- get due_date for BFB enabled
    UPDATE ar_trx_header_gt gt
    SET    term_due_date = ar_bfb_utils_pvt.get_due_date(gt.billing_date, gt.term_id)
    WHERE  gt.term_id IS NOT NULL
    AND    ar_bfb_utils_pvt.is_payment_term_bfb(gt.term_id) = 'Y'
    AND    gt.billing_date IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM ar_trx_errors_gt errgt
       WHERE errgt.trx_header_id = gt.trx_header_id);

    IF pg_debug = 'Y'
    THEN
       debug ('Getting term_due_date(-)' );

    END IF;

    IF pg_debug = 'Y'
    THEN
       debug ('Populate Salesrep Id(+)' );
    END IF;
      populate_salesreps (
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );
      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            RETURN;
      END IF;
      IF pg_debug = 'Y'
      THEN
        debug ('Populate Salesrep Id(-)' );
        debug ('Populate Bill to address Id(+)' );
      END IF;

      populate_bill_to_customer_id (
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );
      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RETURN;
      ELSE
        INSERT INTO ar_trx_errors_gt (
          trx_header_id,
          error_message,
          invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INV_BILL_TO_CUST_ID'),
               bill_to_address_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.bill_to_customer_id IS NULL;
      END IF;
      populate_ship_to_site_use_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RETURN;
      END IF;
      populate_paying_site_use_id (
             x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RETURN;
      END IF;
      populate_bill_to_address_id (
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RETURN;
      ELSE
        INSERT INTO ar_trx_errors_gt (
          trx_header_id,
          error_message,
          invalid_value)
        SELECT trx_header_id,
               arp_standard.fnd_message('AR_INAPI_INVALID_BILL_ADDR_ID'),
               bill_to_address_id
        FROM   ar_trx_header_gt gt
        WHERE  gt.bill_to_address_id IS NULL;
      END IF;
      IF pg_debug = 'Y'
      THEN
        debug ('Populate Bill to address Id(-)' );
        debug ('Populate remit to address Id(+)' );
      END IF;

      populate_remit_to_address_id (
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            RETURN;
      END IF;

      IF pg_debug = 'Y'
      THEN
        debug ('Populate remit to address Id(-)' );
        debug ('Populate bill to contact id(+)' );
      END IF;

      populate_bill_to_contact_id (
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            RETURN;
      END IF;

      IF pg_debug = 'Y'
      THEN
        debug ('Populate bill to contact id(-)' );
      END IF;

      IF pg_debug = 'Y'
      THEN
        debug ('AR_INVOICE_UTILS.populate_customer_attributes  (-)' );
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_customer_attributes '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END populate_customer_attributes;


PROCEDURE populate_ref_hdr_attributes (
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_ref_hdr_attributes (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.Get_batch_source_details (+)' );
    END IF;
    Get_batch_source_details (
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            RETURN;
      END IF;
    -- validate the trx type.
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.Get_batch_source_details (-)' );
        debug ('AR_INVOICE_UTILS.validate_transaction_type (+)' );
    END IF;
    validate_transaction_type(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_transaction_type (-)' );
    END IF;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.Get_trx_type_details (+)' );
    END IF;
    Get_trx_type_details (
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            RETURN;
      END IF;
      IF pg_debug = 'Y'
      THEN
        debug ('AR_INVOICE_UTILS.Get_trx_type_details (-)' );
        debug ('AR_INVOICE_DEFAULT_PVT.Default_gl_date (+)' );
      END IF;
    AR_INVOICE_DEFAULT_PVT.Default_gl_date;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            RETURN;
      END IF;
      IF pg_debug = 'Y'
      THEN
        debug ('AR_INVOICE_DEFAULT_PVT.Default_gl_date (-)' );
        debug ('AR_INVOICE_UTILS.populate_customer_attributes (+)' );
      END IF;
    populate_customer_attributes (
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );

    validate_bfb;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            RETURN;
      END IF;
     IF pg_debug = 'Y'
      THEN
        debug ('AR_INVOICE_UTILS.populate_customer_attributes (-)' );
      END IF;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_ref_hdr_attributes (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_ref_hdr_attributes '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END populate_ref_hdr_attributes;


PROCEDURE validate_UOM_CODE (
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2) IS

	/*Bug 3752043*/
	l_so_org_id  NUMBER;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_UOM_CODE (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_so_org_id := to_number(oe_profile.value('SO_ORGANIZATION_ID'));  /*Bug 3752043*/

    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value )
          SELECT trx_header_id,
                 trx_line_id,
                 arp_standard.fnd_message('AR_INAPI_UOM_NOT_REQ'),
                 gt.uom_code
          FROM ar_trx_lines_gt gt
          WHERE  gt.uom_code IS NOT NULL
          AND    gt.line_type <> 'LINE';

      -- UOM Code not allowed for CM

      INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value )
          SELECT gt.trx_header_id,
                 gt.trx_line_id,
                 arp_standard.fnd_message('AR_INAPI_CM_UOM_NOT_ALLOWED'),
                 gt.uom_code
          FROM ar_trx_lines_gt gt, ar_trx_header_gt gt2
          WHERE  gt.uom_code IS NOT NULL
          AND    gt.line_type = 'LINE'
          AND   gt2.trx_header_id = gt.trx_header_id
          AND   gt2.trx_class = 'CM'; -- added for ER 5869149

    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value )
          SELECT gt.trx_header_id,
                 gt.trx_line_id,
                 arp_standard.fnd_message('AR_INAPI_INVALID_UOM'),
                 gt.uom_code
          FROM ar_trx_lines_gt gt , ar_trx_header_gt gt2
          WHERE gt.uom_code IS NOT NULL
          AND   gt.line_type = 'LINE'
	  AND   gt2.trx_header_id = gt.trx_header_id
	  AND   gt2.trx_class <> 'CM' -- added for ER 5869149
          AND   NOT EXISTS (
                SELECT 'X'
                FROM mtl_item_uoms_view uom
                where organization_id = nvl(gt.warehouse_id,l_so_org_id) /*Bug 3752043*/
                and inventory_item_id = gt.inventory_item_id
                and  uom.uom_code = gt.uom_code
                union
                select 'X'
                from mtl_units_of_measure uom
                where sysdate <= nvl(trunc(uom.disable_date), sysdate)
                and gt.inventory_item_id is null
                and gt.uom_code = uom.uom_code);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_UOM_CODE (-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_UOM_CODE '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END validate_uom_code;


PROCEDURE validate_tax_code (
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_tax_code (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* With etax, they are now responsible for insuring that
       - tax is valid
       - not a location tax
       - rate is overridden
       - inclusive flag mismatch

       Because of this, we no longer have to perform these
       validations here. */

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_tax_code (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_tax_code '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END validate_tax_code;

PROCEDURE validate_tax_freight_lines (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS
BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_tax_lines (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value )
          SELECT trx_header_id,
                 trx_line_id,
                 arp_standard.fnd_message('AR_INAPI_INVALID_TAX_LINE'),
                 gt.vat_tax_id
          FROM ar_trx_lines_gt gt
          WHERE extended_amount IS NULL
          AND   line_type in ('TAX', 'FREIGHT');

     INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value )
          SELECT trx_header_id,
                 trx_line_id,
                 arp_standard.fnd_message('AR_INAPI_QTY_NOT_ALLOWED'),
                 gt.vat_tax_id
          FROM ar_trx_lines_gt gt
          WHERE  line_type in ('TAX', 'FREIGHT')
          AND    (quantity_invoiced IS NOT NULL
               OR unit_selling_price IS NOT NULL );

     /* In etax, a manual tax line must have regime, tax, juris,
        rate, and status -- no exceptions */
     INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value )
          SELECT trx_header_id,
                 trx_line_id,
                 arp_standard.fnd_message('AR_RAXTRX-1706B'),
                 gt.tax_regime_code || ', ' ||
                 gt.tax || ', ' ||
                 gt.tax_status_code || ', ' ||
                 gt.tax_rate_code || ', ' ||
                 gt.tax_jurisdiction_code
          FROM ar_trx_lines_gt gt
          WHERE  line_type = 'TAX'
          AND    gt.tax_regime_code ||
                 gt.tax ||
                 gt.tax_status_code ||
                 gt.tax_rate_code ||
                 gt.tax_jurisdiction_code IS NULL;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_tax_lines (-)' );
    END IF;

     EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_tax_freight_lines '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_tax_exemption (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS
    l_tax_use_exempt_flag       zx_product_options.tax_use_customer_exempt_flag%type;
BEGIN
    -- tax handling
    -- if tax_exempt flag is 'E' then tax exempt reason is mandatory.
    -- tax reason is alterable only if profile ar_allow_trx_line_exemptions
    -- is set to Yes. If tax_exempt falg is 'E then only Reason and
    -- certificate is allowed.

    -- tax handling
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_tax_exemption (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BEGIN
        /* 4257557 - changed to zx_product_options */
        select nvl(tax_use_customer_exempt_flag,'N')
        into  l_tax_use_exempt_flag
        from  zx_product_options
        where application_id = 222;

    EXCEPTION             /*7448838-Adding Exception Block*/
      WHEN NO_DATA_FOUND THEN
        IF pg_debug = 'Y'
        THEN
            debug ('  No rows in zx_product_options' );
            debug ('AR_INVOICE_UTILS.validate_tax_exemption(-)' );
        END IF;
        RETURN;
    END;

    IF pg_debug = 'Y'
    THEN
        debug ('Tax use customer exempt Flag ' || l_tax_use_exempt_flag);
    END IF;
    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value )
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_INV_TAX_EXEMPT_FLAG'),
           tax_exempt_flag
    FROM ar_trx_lines_gt
    WHERE tax_exempt_flag IS NOT NULL
    AND   NOT EXISTS
        ( select 'X'
          from ar_lookups AL1
          where AL1.lookup_type = 'TAX_CONTROL_FLAG'
             and (AL1.lookup_code in ('R','S')
             or (AL1.lookup_code = 'E'
             and  'Y' = l_tax_use_exempt_flag))
/*           4257557 - This logic is temporarily disabled
             or (AL1.lookup_code = 'O'
             and exists (select 1 from ar_system_parameters where tax_database_view_set in ('_V','_A') ))) */
             and tax_exempt_flag = lookup_code);

   -- now validate the reson code in case the exempt flag = 'E'
   -- if exempt flag is E then reason code must be supplied.
   INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_REASON_NOT_REQ')
    FROM ar_trx_lines_gt
    WHERE tax_exempt_flag = 'E'
    AND   TAX_EXEMPT_REASON_CODE IS NULL;

    -- Also in case of 'R' and 'S' reason code and tax_exempt_number is not required.
    UPDATE  ar_trx_lines_gt
        SET TAX_EXEMPT_REASON_CODE = null,
            tax_exempt_number = null
    WHERE tax_exempt_flag in ( 'R', 'S');

    -- Validate the reason code
    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_TAX_EXEMPT_CODE'),
           TAX_EXEMPT_REASON_CODE
    FROM ar_trx_lines_gt
    WHERE  TAX_EXEMPT_REASON_CODE IS NOT null
    AND    NOT EXISTS (
            SELECT 'X'
            FROM   ar_lookups
            WHERE  lookup_type = 'TAX_REASON'
            AND    enabled_flag = 'Y'
            AND    trx_date between start_date_active and nvl(end_date_active,trx_date)
            AND    lookup_code = TAX_EXEMPT_REASON_CODE );

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_tax_exemption (-)' );
    END IF;
   EXCEPTION
     WHEN OTHERS THEN
       x_errmsg := 'Error in AR_INVOICE_UTILS.validate_tax_exemption '
         ||sqlerrm;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RETURN;

END validate_tax_exemption;


PROCEDURE validate_more_tab (
     x_errmsg                    OUT NOCOPY  VARCHAR2,
     x_return_status             OUT NOCOPY  VARCHAR2) IS
    l_trx_date Date := sysdate; --:= g_trx_date;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_more_tab (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- reason code
    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value )
          SELECT trx_header_id,
                 trx_line_id,
                 arp_standard.fnd_message('AR_INAPI_REASON_NOT_REQ'),
                 gt.reason_code
          FROM ar_trx_lines_gt gt
          WHERE  gt.reason_code IS NOT NULL
          AND    gt.line_type = 'TAX';


    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message,
          invalid_value )
          SELECT trx_header_id,
                 trx_line_id,
                 arp_standard.fnd_message('AR_INAPI_INVALID_REASON'),
                 gt.reason_code
          FROM ar_trx_lines_gt gt
          WHERE gt.reason_code IS NOT NULL
          AND   NOT EXISTS (
                select 'X'
                from ar_lookups
                where lookup_type =  'INVOICING_REASON'
                and enabled_flag = 'Y'
                and lookup_code = gt.reason_code
                and sysdate -- g_trx_date
                between start_date_active and nvl(end_date_active, sysdate));
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_more_tab (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_more_tab '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END validate_more_tab;


PROCEDURE validate_line_description (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN

    IF pg_debug = 'Y' THEN
      debug ('AR_INVOICE_UTILS.validate_line_description (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          error_message)
          SELECT trx_header_id,
                 arp_standard.fnd_message('AR_INAPI_INV_DESC_NULL')
          FROM ar_trx_lines_gt gt
          WHERE gt.description IS NULL
          AND   gt.inventory_item_id IS NULL
          AND   gt.memo_line_id IS NULL
          AND   gt.line_type = 'LINE';

    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message)
          SELECT trx_header_id,
                 trx_line_id,
                 arp_standard.fnd_message('AR_DAPI_MEMO_NAME_INVALID')
          FROM ar_trx_lines_gt gt
          WHERE gt.memo_line_id IS NOT NULL
          AND   gt.line_type = 'LINE'
          AND   NOT EXISTS (
                SELECT 'X'
                FROM ar_memo_lines m
                WHERE m.memo_line_id = gt.memo_line_id
                AND   m.line_type = 'LINE'
                AND   sysdate between start_date and nvl(end_date,sysdate) );

    /*Bug 3844408*/
    /*This update should be fired only when the description isn't populated
      initially*/

   /* 4536358 - changed ar_memo_lines_all_tl to
      ar_memo_lines_tl.  Removed rownum = 1.  This was
      just masking issues that would arise due to
      cartesian join.  */

    UPDATE ar_trx_lines_gt gt
    SET description = ( SELECT description
                        FROM   ar_memo_lines_tl
                        WHERE  memo_line_id = gt.memo_line_id
                        AND    language = USERENV('LANG')
                        AND    rownum = 1)
    WHERE gt.memo_line_id IS NOT NULL
    AND   description is NULL;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_line_description (-)' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'Error in AR_INVOICE_UTILS.validate_line_description '||
          sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;

END validate_line_description;


PROCEDURE validate_quantity_invoiced (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_quantity_invoiced (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          error_message)
          SELECT gt.trx_header_id,
                 arp_standard.fnd_message('AR_INAPI_QTY_NOT_NULL')
          FROM ar_trx_lines_gt gt ,
	       ar_trx_header_gt gt2
          WHERE gt.quantity_invoiced IS NULL
	  AND   gt.trx_header_id = gt2.trx_header_id
          AND   gt2.trx_class <> 'CM' -- added for ER 5869149
          AND   gt.line_type = 'LINE';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_quantity_invoiced (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_quantity_invoiced '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

END;

PROCEDURE validate_unit_selling_price (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_unit_selling_price (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          error_message)
          SELECT gt.trx_header_id,
                 arp_standard.fnd_message('AR_INAPI_UNIT_PRICE_NOT_NULL')
          FROM ar_trx_lines_gt gt ,
	       ar_trx_header_gt gt2
          WHERE gt.unit_selling_price IS NULL
	  AND   gt.trx_header_id = gt2.trx_header_id
          AND   gt2.trx_class <> 'CM' -- Added for ER 5869149
          AND   gt.line_type = 'LINE';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_unit_selling_price (-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_unit_selling_price '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_line_type (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_line_type (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          error_message,
          invalid_value )
          SELECT trx_header_id,
                 arp_standard.fnd_message('AR_INAPI_INAVLID_LINE_TYPE'),
                 gt.line_type
          FROM ar_trx_lines_gt gt
          WHERE gt.line_type not in ('LINE', 'TAX', 'FREIGHT');
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_line_type (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_line_type '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE check_dup_line_number (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2)  IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.check_dup_line_number (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- first check if line number is null or not
    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          error_message)
          SELECT trx_header_id,
                 arp_standard.fnd_message('AR_INAPI_LINE_NUM_NOT_NULL')
          FROM ar_trx_lines_gt gt
          WHERE gt.line_number IS NULL;

    -- check for duplicate line number
   /* INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          error_message
          SELECT trx_header_id,
                 'Duplicate Line Number'
          FROM ar_trx_lines_gt gt
          WHERE gt.line_number IS NOT NULL
          AND   ; */
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.check_dup_line_number (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.check_dup_line_number '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_line_integrity (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

-- first get all the freight lines
l_header_freight_count          NUMBER;
l_line_freight_count            NUMBER;
l_allow_freight_flag            ra_cust_trx_types.allow_freight_flag%type;
l_cust_trx_type_id              ra_cust_trx_types.cust_trx_type_id%type;
CURSOR c_freight IS
    SELECT trx_header_id, count(*) number_of_freight_lines
    FROM   ar_trx_lines_gt
    WHERE  line_type = 'FREIGHT'
    group by trx_header_id;

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_line_integrity (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- first check whether all  lines have line and header id
    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message)
          SELECT trx_header_id,
                 trx_line_id,
                 arp_standard.fnd_message('AR_INAPI_HDR_ID_NOT_NULL')
          FROM ar_trx_lines_gt gt
          WHERE gt.trx_header_id IS NULL
          OR    gt.trx_line_id IS NULL;

    -- Now check if the line is of Tax type then
    -- link_to link_to_trx_line_id not null
    INSERT INTO ar_trx_errors_gt
        ( trx_header_id,
          trx_line_id,
          error_message)
          SELECT trx_header_id,
                 trx_line_id,
                 arp_standard.fnd_message('AR_INAPI_LINK_LINE_ID_NOT_NULL')
          FROM ar_trx_lines_gt gt
          WHERE gt.line_type = 'TAX'
          AND   gt.link_to_trx_line_id IS NULL;

    -- Vlaidate if line type is freight then whether
    -- it is associated with header or lines. It is allowed
    -- either with header or line level. Not allowed with both levels.

    /* 5921925 - This could be reduced to a single sql verifiying
       that all freight lines for a given trx are either linked or not linked */

    FOR  c_freight_rec IN c_freight
    LOOP
        l_header_freight_count := 0;
        l_line_freight_count := 0;
        -- first check whether freight is allowed for this transaction type
        -- or not

        BEGIN
            SELECT nvl(gt.allow_freight_flag, 'N'), gt.cust_trx_type_id
            INTO   l_allow_freight_flag, l_cust_trx_type_id
            FROM   ar_trx_header_gt gt
            WHERE  gt.trx_header_id = c_freight_rec.trx_header_id;

            IF l_allow_freight_flag = 'N'
            THEN
                INSERT INTO ar_trx_errors_gt
                    ( trx_header_id,
                      error_message)
                VALUES
                    ( c_freight_rec.trx_header_id,
                      arp_standard.fnd_message('AR_TAPI_FREIGHT_NOT_ALLOWED'));
            END IF;
        END;

        IF  ( c_freight_rec.number_of_freight_lines > 1 )
        THEN
            -- now check what type of freight record it has
            BEGIN
                SELECT  count(*)
                INTO    l_header_freight_count
                FROM    ar_trx_lines_gt
                WHERE   trx_header_id = c_freight_rec.trx_header_id
                AND     link_to_trx_line_id IS NULL;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- need to put error message
            END;
            BEGIN
                SELECT  count(*)
                INTO    l_line_freight_count
                FROM    ar_trx_lines_gt
                WHERE   trx_header_id = c_freight_rec.trx_header_id
                AND     link_to_trx_line_id IS NOT NULL;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- need to put error message
            END;
            IF ( nvl(l_header_freight_count, 0) >= 1 and
                 nvl(l_line_freight_count, 0) >= 1 )
            THEN
                INSERT INTO ar_trx_errors_gt
                    ( trx_header_id,
                      error_message)
                        SELECT trx_header_id,
                        arp_standard.fnd_message('AR_TAPI_TOO_MANY_FREIGHT_LINE')
                        FROM ar_trx_header_gt gt
                        WHERE gt.trx_header_id = c_freight_rec.trx_header_id;
            END IF;
        END IF;
    END LOOP;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_line_integrity (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_line_integrity '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_freight (
     x_errmsg                    OUT NOCOPY  VARCHAR2,
     x_return_status             OUT NOCOPY  VARCHAR2)  IS
BEGIN
    -- validate ship via
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_freight (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt
         ( trx_header_id,
           trx_line_id,
           error_message)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_SHIP_VIA')
    FROM    ar_trx_lines_gt gt
    WHERE  gt.line_type = 'FREIGHT'
    AND    gt.ship_via IS NOT NULL
    AND    NOT EXISTS (
                SELECT 'X' FROM
                org_freight fr
                WHERE fr.organization_id =  gt.org_id
                and   gt.trx_date <= nvl(trunc(disable_date), gt.trx_date)
                and   freight_code = gt.ship_via);

    -- validate FOB
    INSERT INTO ar_trx_errors_gt
         ( trx_header_id,
           trx_line_id,
           error_message)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_FOB')
    FROM    ar_trx_lines_gt gt
    WHERE  gt.line_type = 'FREIGHT'
    AND    gt.fob_point IS NOT NULL
    AND    NOT EXISTS (
                SELECT 'X' FROM
                ar_lookups
                WHERE  lookup_type = 'FOB'
                and    lookup_code = gt.fob_point
                and    gt.trx_date between start_date_active and nvl(end_date_active, gt.trx_date));

   -- error if extended_amount is null
   INSERT INTO ar_trx_errors_gt
         ( trx_header_id,
           trx_line_id,
           error_message)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_EXT_AMT_NOT_NULL')
    FROM    ar_trx_lines_gt gt
    WHERE  gt.line_type = 'FREIGHT'
    AND    gt.extended_amount IS NULL;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_freight (-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_freight '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE populate_extended_amount (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
     x_return_status             OUT NOCOPY  VARCHAR2) IS

-- Added for ER 5869149

    CURSOR c_line IS
    SELECT gt.trx_header_id, gt.trx_line_id,
           gt2.creation_sign, gt.extended_amount,
           gt.revenue_amount, gt.quantity_invoiced,
           gt.unit_selling_price
      FROM ar_trx_lines_gt gt,
           ar_trx_header_gt gt2
     WHERE gt.line_type ='LINE'
       AND gt2.trx_header_id = gt.trx_header_id;
       --AND gt2.trx_class = 'CM';  --Commented Since the below Check has to be performed for both CM and INV

/*    CURSOR c_line_amount_sign IS
    SELECT gt.trx_header_id,  gt2.creation_sign,
	   sum(gt.extended_amount) extended_amount,
	   sum(gt.revenue_amount)  revenue_amount
      FROM ar_trx_lines_gt gt,
           ar_trx_header_gt gt2
     WHERE gt.line_type ='LINE'
       AND gt2.trx_header_id = gt.trx_header_id
     group by gt.trx_header_id,  gt2.creation_sign ;
--commented for bug 8731646
*/
/* Bug 6397348  Set the amount precision as per currency precision*/

ext_amt         NUMBER;

Cursor  c_ext_amt is
select
trx_line_id,extended_amount,quantity_invoiced,unit_selling_price,currency_code
from ar_trx_lines_gt
where extended_amount IS NULL;

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_extended_amount (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Added for ER 5869149
    -- Credit memos should be created with correct sign for amounts

/*    FOR c_line_rec IN c_line_amount_sign
    LOOP
      debug ('c_line_rec.creation_sign = ' || c_line_rec.creation_sign);
      debug ('c_line_rec.extended_amount = '|| c_line_rec.extended_amount );
      debug ('c_line_rec.revenue_amount = '|| c_line_rec.revenue_amount );

      -- check if amount matches creation sign for Transaction Type
      IF ( c_line_rec.creation_sign = 'A' ) THEN
        NULL;
      ELSIF ( c_line_rec.creation_sign  = 'P' ) THEN
        IF ( (NVL( c_line_rec.extended_amount, 0 ) < 0)
            OR ( NVL( c_line_rec.revenue_amount, 0 ) < 0 )) THEN
          INSERT INTO ar_trx_errors_gt
             ( trx_header_id,
               error_message)
          VALUES
             ( c_line_rec.trx_header_id,
               arp_standard.fnd_message('AR_INAPI_AMT_SIGN_INVALID'));
        END IF;
      ELSIF ( c_line_rec.creation_sign = 'N' ) THEN
        IF ( (NVL( c_line_rec.extended_amount, 0 ) > 0)
            OR ( NVL( c_line_rec.revenue_amount, 0 ) > 0 )) THEN
          INSERT INTO ar_trx_errors_gt
             ( trx_header_id,
               error_message)
          VALUES
             ( c_line_rec.trx_header_id,
               arp_standard.fnd_message('AR_INAPI_AMT_SIGN_INVALID'));
        END IF;
      END IF;
    END LOOP;
*/
/* Moved this validation to ARXVINTB.pls
 *  For Bug 8731646
 *  */

    FOR c_line_rec IN c_line
    LOOP
     -- Check if amount matches quantity_invoiced*unit_selling_price
     -- Check 1*-20 = -20
     IF (c_line_rec.quantity_invoiced IS NOT NULL AND
         c_line_rec.unit_selling_price IS NOT NULL AND
         c_line_rec.extended_amount IS NOT NULL) THEN
         IF (c_line_rec.quantity_invoiced*c_line_rec.unit_selling_price <>
             c_line_rec.extended_amount) THEN
             INSERT INTO ar_trx_errors_gt
             ( trx_header_id,
               trx_line_id,
               error_message)
             VALUES
             ( c_line_rec.trx_header_id,
               c_line_rec.trx_line_id,
               arp_standard.fnd_message('AR_INAPI_AMT_INVALID'));
         END IF;
      END IF;

    END LOOP;

	/* Bug 6397348  Set the amount precision as per currency precision*/

	For I in c_ext_amt
	Loop
	    ext_amt := arpcurr.currround(I.quantity_invoiced *
	I.unit_selling_price,I.CURRENCY_CODE);
	    UPDATE ar_trx_lines_gt
		SET extended_amount =ext_amt
	    WHERE extended_amount IS NULL
	    AND trx_line_id= I.trx_line_id;
	End Loop;

	UPDATE ar_trx_lines_gt
	SET    revenue_amount = extended_amount
	WHERE  revenue_amount IS NULL
    	AND    line_type <> 'TAX';

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_extended_amount (-)' );
    END IF;

   EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_extended_amount '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_doc_sequence(
     x_errmsg                    OUT NOCOPY  VARCHAR2,
     x_return_status             OUT NOCOPY  VARCHAR2)
     IS

BEGIN
    IF pg_debug = 'Y'
    THEN
            debug ('AR_INVOICE_UTILS.validate_doc_sequence (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt
         ( trx_header_id,
           error_message)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_INAPI_DUP_DOC_SEQUENCE')
    FROM    ar_trx_header_gt gt
    WHERE  gt.cust_trx_type_id IS NOT NULL
    AND    gt.doc_sequence_value IS NOT NULL
    AND    EXISTS (
              SELECT 'Y'   --already exists
              FROM   ra_recur_interim  ri,
                     ra_customer_trx   ct
              WHERE  ct.customer_trx_id       = ri.customer_trx_id
              AND    ct.cust_trx_type_id      = gt.cust_trx_type_id
              AND    ri.doc_sequence_value    = gt.doc_sequence_value
              AND    NVL(ri.new_customer_trx_id, -98)
                            <> NVL(gt.customer_trx_id, -99)
              UNION
        	SELECT 'Y'   --already exists /*Bug 4080107*/
		FROM   ra_cust_trx_types   ctt,
                       ra_interface_lines  ril
                WHERE  ril.cust_trx_type_name     = ctt.name(+)
                AND    NVL(ril.cust_trx_type_id,
                           ctt.cust_trx_type_id)  = gt.cust_trx_type_id
                AND    ril.document_number        = gt.doc_sequence_value
	        AND    NVL(ril.customer_trx_id, -98)       <> NVL(gt.customer_trx_id, -99));


    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_doc_sequence (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_doc_sequence '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;


PROCEDURE populate_doc_sequence (
     p_trx_system_param_rec      IN          AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
     p_trx_profile_rec           IN          AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type,
     x_errmsg                    OUT NOCOPY  VARCHAR2,
     x_return_status             OUT NOCOPY  VARCHAR2) IS

     CURSOR ctrxHeader IS
        SELECT * FROM
          ar_trx_header_gt
          WHERE trx_header_id NOT IN (
                SELECT trx_header_id FROM
                  ar_trx_errors_gt);

     l_sequence_name            FND_DOCUMENT_SEQUENCES.NAME%TYPE;
     l_doc_sequence_id          ra_customer_trx.doc_sequence_id%type;
     l_doc_sequence_value       ra_customer_trx.doc_sequence_value%type;
     l_dummy                    BINARY_INTEGER;

     l_status                   number;




    l_seq_assign_id       fnd_doc_sequence_assignments.doc_sequence_assignment_id%TYPE;
    l_sequence_type       fnd_document_sequences.type%TYPE;
    l_db_sequence_name    fnd_document_sequences.db_sequence_name%TYPE;
    l_prod_table_name     fnd_document_sequences.table_name%TYPE;
    l_audit_table_name    fnd_document_sequences.audit_table_name%TYPE;
    l_mesg_flag           fnd_document_sequences.message_flag%TYPE;
    l_update_trx          boolean := FALSE;
    l_seq_err             boolean := FALSE;
    l_trx_str             VARCHAR2(2000);
    l_org_str             VARCHAR2(30);
    l_trx_number          ra_customer_trx.trx_number%type;
    l_seq_num_profile     fnd_profile_option_values.profile_option_value%type;
BEGIN
    IF pg_debug = 'Y'
    THEN
            debug ('AR_INVOICE_UTILS.populate_doc_sequence (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_seq_num_profile := NVL(p_trx_profile_rec.ar_unique_seq_numbers, 'N');

        FOR ctrxHeaderRec IN ctrxHeader
        LOOP
            l_update_trx := FALSE;

          IF l_seq_num_profile <> 'N'
          THEN
            l_status :=  fnd_seqnum.get_seq_info (
                                                  222,
                                                  ctrxHeaderRec.cust_trx_type_name,
                                                  p_trx_system_param_rec.set_of_books_id,
                                                  'M',
                                                  trunc(ctrxHeaderRec.trx_date),
                                                  l_doc_sequence_id,
                                                  l_sequence_type,
                                                  l_sequence_name,
                                                  l_db_sequence_name,
                                                  l_seq_assign_id,
                                                  l_prod_table_name,
                                                  l_audit_table_name,
                                                  l_mesg_flag,'y','y');

            l_doc_sequence_value := ctrxHeaderRec.doc_sequence_value;

            IF l_sequence_type IS NULL
               AND l_seq_num_profile = 'A'
            THEN
               INSERT into ar_trx_errors_gt (
                        trx_header_id,
                        error_message )
                    VALUES
                        ( ctrxHeaderRec.trx_header_id,
                          'UNIQUE-ALWAYS USED');

            ELSIF (
                ( l_doc_sequence_value IS NOT NULL
                  AND  l_sequence_type = 'M' )
                OR
                (
                  l_doc_sequence_value IS NULL
                  AND  l_sequence_type IN ( 'A', 'G') )
                 )
            THEN
	      BEGIN  /*Bug 4080107*/
                l_status := FND_SEQNUM.GET_SEQ_VAL(222,
                                 ctrxHeaderRec.cust_trx_type_name,
                                 p_trx_system_param_rec.set_of_books_id,
                                 'M',
                                  trunc(ctrxHeaderRec.trx_date),
                                  l_doc_sequence_value,
                                  l_doc_sequence_id);

                l_update_trx := TRUE;
              EXCEPTION
	        WHEN OTHERS THEN
                    INSERT into ar_trx_errors_gt (
                        trx_header_id,
                        error_message,
                        invalid_value)
                     VALUES
                        ( ctrxHeaderRec.trx_header_id,
                        arp_standard.fnd_message('AR_INAPI_DUP_DOC_SEQUENCE'),
                        l_doc_sequence_value );

                    l_seq_err := TRUE;
               END;
            END IF;
          END IF; /* end if seq_num <> N */

            /* 5921925 - moved update outside of doc sequence code so I could
               use it for trx_number also */
            IF ctrxHeaderRec.auto_trx_numbering_flag = 'Y' AND
               ctrxHeaderRec.trx_number IS NULL AND
               NOT l_seq_err
            THEN
               /* pull trx_number from sequence dynamically */
               IF (ctrxHeaderRec.org_id IS NOT NULL)
               THEN
                  l_org_str := '_'||to_char(ctrxHeaderRec.org_id);
               ELSE
                  l_org_str := NULL;
               END IF;

               l_trx_str :=  'select ra_trx_number_' ||
                             REPLACE(ctrxHeaderRec.batch_source_id, '-', 'N') ||
                             l_org_str||
                             '_s.nextval trx_number from dual';

               IF pg_debug = 'Y'
               THEN
                   debug ('Sql String l_trx_str ' || l_trx_str );
               END IF;

               EXECUTE IMMEDIATE l_trx_str
                  INTO l_trx_number;

               IF l_trx_number IS NOT NULL
               THEN
                  l_update_trx := TRUE;
                  IF pg_debug = 'Y'
                  THEN
                     debug('trx_number from bs sequence is ' || l_trx_number);
                  END IF;
               END IF;

            END IF;

            IF l_update_trx
            THEN

		UPDATE ar_trx_header_gt
                    SET doc_sequence_value = l_doc_sequence_value,
                        doc_sequence_id    = l_doc_sequence_id,
                        trx_number =   DECODE(ctrxHeaderRec.copy_doc_number_flag,
                                            'Y',NVL(to_char(l_doc_sequence_value),
                                                 NVL(l_trx_number,trx_number)),
                                           DECODE(ctrxHeaderRec.auto_trx_numbering_flag,
                                            'Y',l_trx_number,trx_number))
                WHERE   trx_header_id = ctrxHeaderRec.trx_header_id;
            END IF;

            l_trx_number := NULL;
            l_update_trx := FALSE;
            l_seq_err    := FALSE;
        END LOOP;

    validate_doc_sequence ( x_errmsg , x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    IF pg_debug = 'Y'
    THEN
            debug ('AR_INVOICE_UTILS.populate_doc_sequence (-)' );
    END IF;
	 EXCEPTION
            WHEN OTHERS THEN
                  x_errmsg := 'Error in AR_INVOICE_UTILS.populate_doc_sequence '||sqlerrm ;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  RETURN;

END;

/* PAYMENT UPTAKE  start */

PROCEDURE copy_pmt_extension(
     x_errmsg                    OUT NOCOPY  VARCHAR2,
     x_return_status             OUT NOCOPY  VARCHAR2) IS

     CURSOR ctrxHeader IS
          SELECT * FROM
          ar_trx_header_gt
          WHERE trx_header_id NOT IN (
                SELECT trx_header_id FROM
                  ar_trx_errors_gt)
          AND   payment_trxn_extension_id is not null;

             l_payer_rec                     IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
             l_cpy_msg_data                  VARCHAR2(2000);
             l_trxn_attribs_rec              IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
             p_trxn_entity_id                RA_CUSTOMER_TRX.PAYMENT_TRXN_EXTENSION_ID%TYPE;
             l_response_rec                  IBY_FNDCPT_COMMON_PUB.Result_rec_type;
             l_party_id                      NUMBER;
             l_pmt_trxn_extension_id          IBY_FNDCPT_COMMON_PUB.Id_tbl_type;
             o_payment_trxn_extension_id         RA_CUSTOMER_TRX.PAYMENT_TRXN_EXTENSION_ID%TYPE;

            l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
            l_assignment_id                 NUMBER;

            l_msg_count                     NUMBER;
            l_msg_data                      VARCHAR2(2000);



BEGIN


arp_standard.debug ( 'inside Copy payment trxn ');

    IF pg_debug = 'Y'
    THEN
        arp_standard.debug ( 'inside Copy payment trxn ');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

        FOR ctrxHeaderRec IN ctrxHeader
        LOOP
                   SELECT party.party_id
                   INTO   l_party_id
                   FROM   hz_cust_accounts hca,
                          hz_parties    party
                   WHERE  hca.party_id = party.party_id
                   AND    hca.cust_account_id = ctrxHeaderRec.paying_customer_id ;

            SELECT INSTR_ASSIGNMENT_ID
            INTO  l_assignment_id
            from  iby_fndcpt_tx_extensions
            where trxn_extension_id = ctrxHeaderRec.payment_trxn_extension_id;

        -- set up payer (=customer) record:

        l_payer_rec.Payment_Function := 'CUSTOMER_PAYMENT';
        l_payer_rec.Party_Id :=   l_party_id;
        l_payer_rec.org_id   := ctrxHeaderRec.org_id ;
        l_payer_rec.org_type := 'OPERATING_UNIT';
        l_payer_rec.Cust_Account_Id := ctrxHeaderRec.paying_customer_id;
        l_payer_rec.Account_Site_Id := ctrxHeaderRec.paying_site_use_id;


        if  ctrxHeaderRec.paying_site_use_id is NULL  THEN

          l_payer_rec.org_id := NULL;
          l_payer_rec.org_type := NULL;

        end if;

        l_trxn_attribs_rec.Originating_Application_Id := arp_standard.application_id;
        l_trxn_attribs_rec.order_id := ctrxHeaderRec.customer_trx_id ;
        l_trxn_attribs_rec.Trxn_Ref_Number1 := 'INVOICE';
        l_trxn_attribs_rec.Trxn_Ref_Number2 := ctrxHeaderRec.trx_number;
        l_trxn_attribs_rec.seq_type_last        := ctrxHeaderRec.mandate_last_trx_flag;
        l_assignment_id := l_assignment_id;
        l_pmt_trxn_extension_id(1) := ctrxHeaderRec.payment_trxn_extension_id;


             arp_standard.debug('l_payer.payment_function :<' || l_payer_rec.payment_function  || '>');
             arp_standard.debug('l_payer.Party_Id         :<' || l_payer_rec.Party_Id || '>');
             arp_standard.debug('l_payer.Org_Type         :<' || l_payer_rec.Org_Type || '>');
             arp_standard.debug('l_payer.Org_id           :<' || l_payer_rec.Org_id || '>');
             arp_standard.debug('l_payer.Cust_Account_Id  :<' || l_payer_rec.Cust_Account_Id || '>');
   		arp_standard.debug('l_trxn_attribs.order_id  :<'|| l_trxn_attribs_rec.order_id || '>');
   		arp_standard.debug('l_assignment_id          :<'|| l_assignment_id || '>');
   		arp_standard.debug('payment_trx_extension_id          :<'|| l_pmt_trxn_extension_id(1) || '>');

                  IBY_FNDCPT_TRXN_PUB.Copy_Transaction_Extension
                     ( p_api_version        => 1.0,
                       p_init_msg_list      => FND_API.G_TRUE,
                       p_commit             => FND_API.G_FALSE,
                       x_return_status      => l_return_status,
                       x_msg_count          => l_msg_count,
                       x_msg_data           => l_msg_data,
                       p_payer              => l_payer_rec,
                       p_payer_equivalency  => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                       p_entities           => l_pmt_trxn_extension_id,
                       p_trxn_attribs       => l_trxn_attribs_rec,
                       x_entity_id          => p_trxn_entity_id,          -- out parm
                       x_response           => l_response_rec             -- out
                      );


                 IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN

                         o_payment_trxn_extension_id  := p_trxn_entity_id ;

                   arp_standard.debug('the copied value of trx_entn is ' || o_payment_trxn_extension_id );

                    UPDATE ar_trx_header_gt
                    SET payment_trxn_extension_id = o_payment_trxn_extension_id
                    WHERE trx_header_id =  ctrxHeaderRec.trx_header_id;
                 END IF;



                 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN


                    l_cpy_msg_data := substrb( l_response_rec.Result_Code || ': '||
                                   l_response_rec.Result_Message , 1, 240);


                     INSERT into ar_trx_errors_gt (
                        trx_header_id,
                        error_message,
                        invalid_value)
                     VALUES
                        ( ctrxHeaderRec.trx_header_id,
                         arp_standard.fnd_message('AR_CC_AUTH_FAILED'),
                         ctrxHeaderRec.payment_trxn_extension_id );

                 END IF;

       END LOOP;

         EXCEPTION
            WHEN OTHERS THEN
                  x_errmsg := 'Error in AR_INVOICE_UTILS.copy_pmt_extension '||sqlerrm ;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  RETURN;

END;


/* payment uptake end */
PROCEDURE  validate_item_kflex (
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2) IS

        l_so_id_flex_code   fnd_profile_option_values.profile_option_value%type;
        l_so_org_id         fnd_profile_option_values.profile_option_value%type;

        CURSOR cItemFlex IS
            SELECT trx_header_id, trx_line_id,inventory_item_id, org_id
            FROM   ar_trx_lines_gt
            WHERE  inventory_item_id IS NOT NULL;

BEGIN
        IF pg_debug = 'Y'
        THEN
            debug ('AR_INVOICE_UTILS.validate_item_kflex (+)' );
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        oe_profile.get('SO_ID_FLEX_CODE', l_so_id_flex_code);




        FOR cItemFlexRec IN cItemFlex
        LOOP
            IF (
                fnd_flex_keyval.validate_ccid(
                             appl_short_name   => 'INV',
                             key_flex_code     => l_so_id_flex_code,
                             structure_number  => 101,
                             data_set          => pg_so_org_id,
                             get_columns       => 'invoice_enabled_flag',
                             combination_id    => cItemFlexRec.inventory_item_id)
                                 = TRUE    )
           THEN
                -- check whether invoice_enable_flag is 'Y'
                IF    fnd_flex_keyval.column_value(1) <> 'Y'
                THEN
                    INSERT into ar_trx_errors_gt (
                        trx_header_id,
                        trx_line_id,
                        error_message,
                        invalid_value)
                    VALUES
                        ( cItemFlexRec.trx_header_id,
                        cItemFlexRec.trx_line_id,
                        arp_standard.fnd_message('AR_INAPI_INVALID_ITEM_D'),
                        cItemFlexRec.inventory_item_id );
		ELSE
		/*Bug 3844408*/
		/*This update should be fired only when the description isn't populated
		  initially*/
		   -- get the description
		   update ar_trx_lines_gt
			SET description = (
				select description
				from mtl_system_items_vl
				WHERE  inventory_item_id = cItemFlexRec.inventory_item_id
				AND    organization_id = pg_so_org_id)
		   WHERE  trx_line_id = cItemFlexRec.trx_line_id
		   AND    description is NULL;
                END IF;
           ELSE
                    INSERT into ar_trx_errors_gt (
                        trx_header_id,
                        trx_line_id,
                        error_message,
                        invalid_value)
                    VALUES
                        ( cItemFlexRec.trx_header_id,
                        cItemFlexRec.trx_line_id,
                        arp_standard.fnd_message('AR_INAPI_INVALID_ITEM_ID'),
                        cItemFlexRec.inventory_item_id );
           END IF;
       END LOOP;

       IF pg_debug = 'Y'
        THEN
            debug ('AR_INVOICE_UTILS.validate_item_kflex (-)' );
        END IF;
         EXCEPTION
            WHEN OTHERS THEN
                  x_errmsg := 'Error in AR_INVOICE_UTILS.validate_item_kflex '||sqlerrm ;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  RETURN;
END;

PROCEDURE validate_territory_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

    Cursor cTerritory IS
        SELECT territory_id, trx_header_id
        FROm   ar_trx_header_gt
        WHERE  territory_id IS NOT NULL;

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_territory_id (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR cTerritoryRec IN cTerritory
    LOOP
        IF ( fnd_flex_keyval.validate_ccid(
                                appl_short_name   => 'AR',
                                key_flex_code     => 'CT#',
                                structure_number  => 101,
                                combination_id    => cTerritoryRec.territory_id)
                          <> TRUE )
        THEN
            INSERT into ar_trx_errors_gt (
                        trx_header_id,
                        error_message,
                        invalid_value)
                    VALUES
                        ( cTerritoryRec.trx_header_id,
                        arp_standard.fnd_message('AR_INAPI_INVALID_TERRITORY'),
                        cTerritoryRec.territory_id );
        END IF;
    END LOOP;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_territory_id (-)' );
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                  x_errmsg := 'Error in AR_INVOICE_UTILS.validate_territory_id '||sqlerrm ;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  RETURN;
END;

PROCEDURE validate_warehouse_id (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_warehouse_id (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ar_trx_errors_gt
     ( trx_line_id,
       trx_header_id,
       error_message,
       Invalid_value )
     select l.trx_line_id,
            l.trx_header_id,
            arp_standard.fnd_message('AR_RAXTRX_INV_WAREHOUSE'),
            l.warehouse_id
     from   ar_trx_lines_gt l
     where  l.line_type = 'LINE'
        and l.warehouse_id is not null
        and not exists (select 'x'
                     from hr_organization_units hou,
                          hr_organization_information hoi1,
                          hr_organization_information hoi2,
                          mtl_parameters mp,
                          gl_sets_of_books gsob
                     where hou.organization_id = hoi1.organization_id
                     and hou.organization_id = hoi2.organization_id
                     and hou.organization_id = mp.organization_id
                     and hoi1.org_information1 = 'INV'
                     and hoi1.org_information2 = 'Y'
                     and ( hoi1.org_information_context || '') = 'CLASS'
                     and ( hoi2.org_information_context || '') ='Accounting Information'
                     and to_number(hoi2.org_information1) = gsob.set_of_books_id
                     and l.warehouse_id = hou.organization_id
                     and l.trx_date <= nvl(hou.date_to, l.trx_date));


    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_warehouse_id (-)' );
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                  x_errmsg := 'Error in AR_INVOICE_UTILS.validate_warehouse_id '||sqlerrm ;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  RETURN;
END;


PROCEDURE validate_accounting_rules (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
     x_return_status             OUT NOCOPY  VARCHAR2) IS


 --PPRR Added rule_end_date in the select
    CURSOR c_invoicing_rule_c IS
    SELECT line.trx_header_id, line.trx_line_id, hdr.invoicing_rule_id,
           line.ACCOUNTING_RULE_ID, line.ACCOUNTING_RULE_DURATION,
           line.RULE_START_DATE,line.RULE_END_DATE,line.set_of_books_id,hdr.trx_date,
           rr.type, rr.frequency, rr.occurrences
    FROM   ar_trx_lines_gt line, ar_trx_header_gt hdr,
           ra_rules rr
    WHERE  hdr.invoicing_rule_id IS NOT NULL
    AND    line.accounting_rule_id IS NOT NULL
    AND    hdr.trx_header_id = line.trx_header_id
    AND    hdr.trx_class <> 'CM' -- Added for ER 5869149
    AND    line.line_type = 'LINE'
    AND    line.accounting_rule_id = rr.rule_id
    AND    rr.status = 'A';
BEGIN
    -- validate the rule ID
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_accounting_rules (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

	--PPRR Added PP rule types in the type condition
        INSERT INTO ar_trx_errors_gt
            (   trx_header_id,
                trx_line_id,
                error_message)
                SELECT gt.trx_header_id,
                       gt.trx_line_id,
                       arp_standard.fnd_message('AR_INAPI_INVALID_RULE_NAME')
                FROM ar_trx_lines_gt gt , ar_trx_header_gt gt2
                WHERE gt.accounting_rule_id IS NOT NULL
		AND   gt2.trx_header_id = gt.trx_header_id
                AND   gt2.trx_class <> 'CM' -- Added for ER 5869149
                AND    NOT EXISTS (
                        SELECT 'X'
                        FROM   ra_rules rr
                        WHERE  rr.type in ('A', 'ACC_DUR','PP_DR_ALL','PP_DR_PP')
                        and    rr.status = 'A'
                        AND    rr.rule_id = gt.accounting_rule_id);

         INSERT INTO ar_trx_errors_gt
            (   trx_header_id,
                trx_line_id,
                error_message)
                SELECT gt.trx_header_id,
                       gt.trx_line_id,
                       arp_standard.fnd_message('AR_INAPI_RULE_NAME_NOT_NULL')
                FROM ar_trx_lines_gt gt, ar_trx_header_gt gth
                WHERE gt.accounting_rule_id IS NULL
                AND   gt.trx_header_id = gth.trx_header_id
                AND   gth.invoicing_rule_id IS NOT NULL
		AND   gth.trx_class <> 'CM' -- Added for ER 5869149
                AND   gt.line_type = 'LINE';

	-- Rule name is not allowed for Credit Memos

         INSERT INTO ar_trx_errors_gt
            (   trx_header_id,
                trx_line_id,
                error_message)
                SELECT gt.trx_header_id,
                       gt.trx_line_id,
                       arp_standard.fnd_message('AR_INAPI_RULE_NOT_ALLOWED')
                FROM ar_trx_lines_gt gt, ar_trx_header_gt gth
                WHERE (gt.accounting_rule_id IS  NOT NULL
                      OR gth.invoicing_rule_id IS NOT NULL)
                AND   gt.trx_header_id = gth.trx_header_id
                AND   gth.trx_class = 'CM' -- Added for ER 5257046
                AND   gt.line_type = 'LINE';

    FOR c_invoicing_rule_rec IN c_invoicing_rule_c
    LOOP
        -- first check whether accounting rule name is supplied or not
        -- in case it is not supplied then log a error
        IF ( c_invoicing_rule_rec.accounting_rule_id IS NULL )
        THEN
            INSERT INTO ar_trx_errors_gt
            (   trx_header_id,
                trx_line_id,
                error_message) VALUES
                ( c_invoicing_rule_rec.trx_header_id,
                  c_invoicing_rule_rec.trx_line_id,
                  arp_standard.fnd_message('AR_INAPI_RULE_NAME_NOT_NULL') );
           --PPRR Accounting rule  Validations
         ELSIF c_invoicing_rule_rec.type in ('PP_DR_ALL','PP_DR_PP') THEN
                IF c_invoicing_rule_rec.RULE_START_DATE IS NULL THEN
                      INSERT INTO ar_trx_errors_gt
		            (   trx_header_id,
		                trx_line_id,
		                error_message) VALUES
                	    ( c_invoicing_rule_rec.trx_header_id,
	                      c_invoicing_rule_rec.trx_line_id,
			     arp_standard.fnd_message('AR_RAXTRX_RULE_START_DT_NULL'));
                 END IF;

		 IF c_invoicing_rule_rec.RULE_END_DATE IS NULL THEN
                      INSERT INTO ar_trx_errors_gt
                            (   trx_header_id,
                                trx_line_id,
                                error_message) VALUES
                            ( c_invoicing_rule_rec.trx_header_id,
                              c_invoicing_rule_rec.trx_line_id,
                             arp_standard.fnd_message('AR_RAXTRX_RULE_END_DT_NULL'));
                 END IF;

                 IF c_invoicing_rule_rec.RULE_END_DATE <  c_invoicing_rule_rec.RULE_START_DATE
                 THEN
                    INSERT INTO ar_trx_errors_gt
                            (   trx_header_id,
                                trx_line_id,
                                error_message) VALUES
                            ( c_invoicing_rule_rec.trx_header_id,
                              c_invoicing_rule_rec.trx_line_id,
			      arp_standard.fnd_message('AR_RAXTRX_RSD_LT_RED'));
		ELSE
                   UPDATE ar_trx_lines_gt a
                        SET ACCOUNTING_RULE_DURATION =
					 (SELECT COUNT(*)
					  FROM   ar_periods gps,
						 ra_rules rr2,
				                 ar_system_parameters sys,
				                 gl_sets_of_books gl
				         WHERE
		                        rr2.rule_id        =  a.ACCOUNTING_RULE_ID
	                                AND    rr2.frequency          = gps.period_type
                                        AND    rr2.type               NOT IN ('A', 'ACC_DUR')
                                        AND    sys.set_of_books_id    = gl.set_of_books_id
                                        AND    gl.period_set_name     = gps.period_set_name
                                        AND (  a.RULE_START_DATE  BETWEEN gps.start_date
                                                AND     gps.end_date
                                            OR a.RULE_end_DATE  BETWEEN gps.start_date
			                       AND gps.end_date
				            OR    gps.start_date   BETWEEN a.RULE_START_DATE
                                                AND  a.RULE_end_DATE ))
                    WHERE  trx_line_id = c_invoicing_rule_rec.trx_line_id
                    AND    trx_header_id = c_invoicing_rule_rec.trx_header_id;
                 END IF;
          ELSE

            -- validate the duration and rule start date
            IF c_invoicing_rule_rec.accounting_rule_duration IS NULL
            THEN
                IF c_invoicing_rule_rec.type = 'ACC_DUR'
                THEN
                    INSERT INTO ar_trx_errors_gt
                    (  trx_header_id,
                       trx_line_id,
                       error_message) VALUES
                    (   c_invoicing_rule_rec.trx_header_id,
                        c_invoicing_rule_rec.trx_line_id,
                        arp_standard.fnd_message('AR_INAPI_RULE_DUR_NOT_NULL' ));
                ELSE
                    UPDATE ar_trx_lines_gt
                        SET ACCOUNTING_RULE_DURATION = c_invoicing_rule_rec.occurrences
                    WHERE  trx_line_id = c_invoicing_rule_rec.trx_line_id
                    AND    trx_header_id = c_invoicing_rule_rec.trx_header_id;
                END IF;
            ELSE
                IF c_invoicing_rule_rec.type = 'A'
                THEN
                    -- validate the user supplied value
                    IF c_invoicing_rule_rec.ACCOUNTING_RULE_DURATION <>
                        c_invoicing_rule_rec.occurrences
                    THEN
                        UPDATE ar_trx_lines_gt
                        SET ACCOUNTING_RULE_DURATION = c_invoicing_rule_rec.occurrences
                        WHERE  trx_line_id = c_invoicing_rule_rec.trx_line_id
                        AND    trx_header_id = c_invoicing_rule_rec.trx_header_id;
                    END IF;
                END IF;
            END IF;

            -- depending on the type validate the dependents field
            -- and populate the date columns.
            DECLARE
            l_period_exist	NUMBER;
            l_set_of_books_id   NUMBER;
            l_frequency         VARCHAR2(30);
            l_rule_start_date   DATE;
            l_accounting_rule_id NUMBER;
            --
            CURSOR c_special IS
               SELECT MIN(rs.rule_date)
               FROM   ra_rule_schedules rs
               WHERE  rs.rule_id = l_accounting_rule_id;
            BEGIN
            l_set_of_books_id := c_invoicing_rule_rec.set_of_books_id;
            l_frequency := c_invoicing_rule_rec.frequency;
            l_accounting_rule_id := c_invoicing_rule_rec.accounting_rule_id;

            IF l_frequency = 'SPECIFIC'  THEN
               OPEN c_special;
               FETCH c_special INTO l_rule_start_date;
               CLOSE c_special;
            ELSE
               IF ( c_invoicing_rule_rec.invoicing_rule_id = -2 ) THEN
                  l_rule_start_date := c_invoicing_rule_rec.trx_date;
               ELSIF ( c_invoicing_rule_rec.invoicing_rule_id = -3 ) THEN
                  l_rule_start_date := trunc(sysdate);
               END IF;
            END IF;
            --
            -- if the default date is not in an existing period, do not set the default.
            --
            IF ( l_rule_start_date IS NOT NULL ) THEN
               IF (l_frequency = 'SPECIFIC') THEN
                 IF c_invoicing_rule_rec.rule_start_date IS NOT NULL
                 THEN
                    IF c_invoicing_rule_rec.rule_start_date <>
                        l_rule_start_date
                    THEN
                        UPDATE ar_trx_lines_gt
                        SET rule_start_date = l_rule_start_date
                        WHERE  trx_line_id = c_invoicing_rule_rec.trx_line_id
                        AND    trx_header_id = c_invoicing_rule_rec.trx_header_id;
                    END IF;
                 END IF;
               ELSE -- frequency <> 'SPECIFIC'
                  /* Bug 5444387 - Checked for line rule_start_date to be in a GL period instead of trx_date
                     and also added check for the status of the gl_period with a join to gl_period_statuses */
                  SELECT COUNT(*)
                  INTO   l_period_exist
                  FROM   gl_periods gp,
                         gl_sets_of_books sob,
                         gl_period_statuses gps
                  WHERE  sob.set_of_books_id = l_set_of_books_id
                  AND    gp.adjustment_period_flag = 'N'
                  AND    gp.period_set_name = sob.period_set_name
                  AND    gp.period_type = l_frequency
                  AND    gp.period_name  = gps.period_name
                  AND    gp.period_type  = gps.period_type
                  AND    gp.period_year  = gps.period_year
                  AND    gp.period_num  = gps.period_num
                  AND    gp.quarter_num  = gps.quarter_num
                  AND    gp.year_start_date = gps.year_start_date
                  AND    gp.quarter_start_date = gps.quarter_start_date
                  AND    gp.start_date = gps.start_date
                  AND    gp.end_date  = gps.end_date
                  AND    gps.application_id  = 222
                  AND    gps.adjustment_period_flag = 'N'
                  AND    sob.set_of_books_id = gps.set_of_books_id
                  AND    gps.period_type = sob.accounted_period_type
                  AND    c_invoicing_rule_rec.rule_start_date BETWEEN gp.start_date AND gp.end_date;

                  /* Bug 5444387 - Removed the check for trx_date to be equal to rule_start_date of each line
                     as it is unnecessory and not always satisfied */
                  IF ( l_period_exist <> 1 ) THEN
                         INSERT INTO ar_trx_errors_gt
                            (  trx_header_id,
                               trx_line_id,
                               error_message) VALUES
                            (   c_invoicing_rule_rec.trx_header_id,
                                c_invoicing_rule_rec.trx_line_id,
                                arp_standard.fnd_message('AR_INAPI_RULE_START_DT_NO_NULL') );
                  END IF;
               END IF;
            END IF;
         END;

        END IF;



    END LOOP;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_accounting_rules (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_accounting_rules '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_line_ussgl_code (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

  IF pg_debug = 'Y' THEN
    debug ('ar_invoice_utils.validate_line_ussgl_code(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    trx_line_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           trx_line_id,
           arp_standard.fnd_message('AR_INAPI_INVALID_USSGL_CODE'),
           default_ussgl_transaction_code
    FROM   ar_trx_lines_gt gt
    WHERE  gt.default_ussgl_transaction_code IS NOT NULL
    AND NOT EXISTS
      (SELECT 'X'
       FROM  gl_ussgl_transaction_codes gutc
       WHERE gutc.ussgl_transaction_code = gt.default_ussgl_transaction_code
       AND   gutc.chart_of_accounts_id = arp_global.chart_of_accounts_id
       AND   gt.trx_date
         BETWEEN NVL(gutc.start_date_active, gt.trx_date)
         AND NVL(gutc.end_date_active, gt.trx_date));

    IF pg_debug = 'Y' THEN
      debug ('ar_invoice_utils.validate_line_ussgl_code(-)' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error in ar_invoice_utils.validate_line_ussgl_code '|| sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END validate_line_ussgl_code;


PROCEDURE populate_line_attributes (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_line_attributes (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check if memo line is passed and any unit of measue and unit price.
    BEGIN
        UPDATE ar_trx_lines_gt gt
            set gt.unit_selling_price =
                    ( SELECT m.unit_std_price
                      FROM ar_memo_lines_vl m
                      WHERE  m.memo_line_id = gt.memo_line_id
                      AND    gt.memo_line_id IS NOT NULL
                      AND    sysdate between m.start_date and nvl(m.end_date,sysdate))
        WHERE gt.unit_selling_price IS NULL;

        UPDATE ar_trx_lines_gt gt
            set gt.uom_code =
                    ( SELECT m.uom_code
                      FROM ar_memo_lines_vl m
                      WHERE  m.memo_line_id = gt.memo_line_id
                      AND    gt.memo_line_id IS NOT NULL
                      AND    sysdate between m.start_date and nvl(m.end_date,sysdate))
        WHERE gt.uom_code IS NULL;
    END;
    populate_extended_amount (
        x_errmsg            =>  x_errmsg,
        x_return_status     =>  x_return_status );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
         RETURN;
    END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_line_attributes (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.populate_line_attributes '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE populate_exchange_rate (
        p_trx_system_parameters_rec     IN  AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
        p_trx_profile_rec               IN  AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type,
        x_errmsg                        OUT NOCOPY  VARCHAR2,
        x_return_status                 OUT NOCOPY  VARCHAR2) IS


        l_relation                    VARCHAR2(1);
        l_exchange_rate               ra_customer_trx.exchange_rate%type;
        l_default_exchange_rate_type  ra_customer_trx.exchange_rate_type%type;
        CURSOR cExchangeRate IS
            SELECT trx_header_id, trx_currency,
                   nvl(exchange_rate_type,
                   p_trx_profile_rec.default_exchange_rate_type) exchange_rate_type,
                   trunc(nvl(exchange_date,trx_date)) exchange_date, exchange_rate
            FROM   ar_trx_header_gt gt
            WHERE  p_trx_system_parameters_rec.base_currency_code <>
                   trx_currency
            AND    nvl(exchange_rate_type,
                    p_trx_profile_rec.default_exchange_rate_type)  <> 'User'
            AND NOT EXISTS
              (SELECT 'X'
               FROM   ar_trx_errors_gt errgt
               WHERE  errgt.trx_header_id = gt.trx_header_id
               AND    errgt.invalid_value = gt.trx_currency);

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_exchange_rate (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR cExchangeRateRec IN cExchangeRate
    LOOP
      BEGIN
        l_relation := gl_currency_api.is_fixed_rate
            ( cExchangeRateRec.trx_currency,
              p_trx_system_parameters_rec.base_currency_code,
              cExchangeRateRec.exchange_date);
        IF l_relation = 'Y'
        THEN
            IF pg_debug = 'Y'
            THEN
                 debug ( 'in Y ');
                 debug ( 'trx curr  ' || cExchangeRateRec.trx_currency);
                 debug ( 'Base  curr  ' || p_trx_system_parameters_rec.base_currency_code);
                 debug ( 'Exch date  ' || cExchangeRateRec.exchange_date);
                 debug ( 'Rate type ' || cExchangeRateRec.exchange_rate_type);
            END IF;


             l_exchange_rate :=
                    gl_currency_api.get_rate(cExchangeRateRec.trx_currency,
                                             p_trx_system_parameters_rec.base_currency_code,
                                             cExchangeRateRec.exchange_date,
                                             cExchangeRateRec.exchange_rate_type );
        ELSIF ( cExchangeRateRec.exchange_rate_type <> 'User')
        THEN
            IF pg_debug = 'Y'
            THEN
                 debug ( 'in Y ');
                 debug ( 'trx curr  ' || cExchangeRateRec.trx_currency);
                 debug ( 'Base  curr  ' || p_trx_system_parameters_rec.base_currency_code);
                 debug ( 'Exch date  ' || cExchangeRateRec.exchange_date);
                 debug ( 'Rate type ' || cExchangeRateRec.exchange_rate_type);
            END IF;
            l_exchange_rate :=
                gl_currency_api.get_rate(cExchangeRateRec.trx_currency,
                                             p_trx_system_parameters_rec.base_currency_code,
                                             cExchangeRateRec.exchange_date,
                                             cExchangeRateRec.exchange_rate_type );
        END IF;
        IF pg_debug = 'Y'
        THEN
                 debug ( ' Exchange Rate ' || l_exchange_rate);
        END IF;

        UPDATE ar_trx_header_gt
            SET exchange_rate = l_exchange_rate,
                exchange_date = cExchangeRateRec.exchange_date,
                exchange_rate_type = cExchangeRateRec.exchange_rate_type
        WHERE trx_header_id = cExchangeRateRec.trx_header_id;
    EXCEPTION
        WHEN OTHERS THEN
                -- in case gl_api fails it will insert record
                -- into error table
            INSERT INTO ar_trx_errors_gt
                    (   trx_header_id,
                        error_message,
                        invalid_value)
                VALUES
                    ( cExchangeRateRec.trx_header_id,
                      arp_standard.fnd_message('AR_INAPI_NO_EXCH_DEFINE'),
                      cExchangeRateRec.trx_currency);

      END;
    END LOOP;

    -- Update the exchange_date  in case exchange_rate_type is 'User'
    -- and no exchange date has been provided.
    UPDATE ar_trx_header_gt
     SET   exchange_date = trunc(trx_date)
    WHERE  exchange_rate_type = 'User'
    AND    exchange_date IS NULL;

    -- Now validates whether all exchange information is populated
    -- in case trxn currecny <> func currency
    INSERT INTO ar_trx_errors_gt (
    trx_header_id,
    error_message,
    invalid_value)
    SELECT trx_header_id,
           arp_standard.fnd_message('AR_EXCHANGE_RATE_NEEDED'),
           gt.trx_currency
    FROM   ar_trx_header_gt gt
    WHERE  gt.trx_currency IS NOT NULL
    AND    ( exchange_rate IS NULL
       OR    exchange_rate <= 0
       OR    exchange_date IS NULL)
    AND    gt.trx_currency <> p_trx_system_parameters_rec.base_currency_code;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.populate_exchange_rate (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS
            THEN
                x_errmsg := 'Error in AR_INVOICE_UTILS.populate_exchange_rate '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RETURN;

END;

Procedure populate_payment_method (
         x_errmsg                   OUT NOCOPY VARCHAR2,
         x_return_status            OUT NOCOPY VARCHAR2 ) AS

    CURSOR cCustDetails IS
        SELECT trx_currency, paying_customer_id,
               paying_site_use_id, bill_to_customer_id,
               bill_to_site_use_id, trx_date, trx_header_id,
	       payment_trxn_extension_id
        FROM ar_trx_header_gt
        WHERE receipt_method_id IS NULL;
	--AND   payment_trxn_extension_id IS NOT NULL;
    l_receipt_method_name             ar_receipt_methods.name%type;
    l_receipt_method_id               ar_receipt_methods.receipt_method_id%type;
    l_creation_method_code            ar_receipt_classes.creation_method_code%type;
    l_bank_account_id                 ce_bank_accounts.bank_account_id%type;
    l_bank_account_num                ce_bank_accounts.bank_account_num%type;
    l_bank_name                       ce_bank_branches_v.bank_name%type;
    l_bank_branch_name                ce_bank_branches_v.bank_branch_name%type;
    l_bank_branch_id                  ce_bank_accounts.bank_branch_id%type;

BEGIN
    FOR cCustDetailsRec IN cCustDetails
    LOOP
        arp_trx_defaults_3.get_pay_method_and_bank_deflts (
               p_trx_date           => cCustDetailsRec.trx_date,
               p_currency_code      => cCustDetailsRec.trx_currency,
               p_paying_customer_id => cCustDetailsRec.paying_customer_id,
               p_paying_site_use_id => cCustDetailsRec.paying_site_use_id,
               p_bill_to_customer_id => cCustDetailsRec.bill_to_customer_id,
               p_bill_to_site_use_id => cCustDetailsRec.bill_to_site_use_id,
               p_payment_type_code   => null,
               p_payment_method_name => l_receipt_method_name,
               p_receipt_method_id   => l_receipt_method_id,
               p_creation_method_code => l_creation_method_code,
               p_customer_bank_account_id  => l_bank_account_id,
               p_bank_account_num     => l_bank_account_num,
               p_bank_name            => l_bank_name,
               p_bank_branch_name     => l_bank_branch_name,
               p_bank_branch_id       => l_bank_branch_id
                                   );

	 IF l_creation_method_code = 'AUTOMATIC'
           AND l_receipt_method_id IS NOT NULL
	   AND cCustDetailsRec.payment_trxn_extension_id IS NOT NULL
         THEN
            UPDATE ar_trx_header_gt
                set receipt_method_id = l_receipt_method_id
            WHERE trx_header_id = cCustDetailsRec.trx_header_id;
         END IF;

	 IF l_creation_method_code = 'MANUAL'
	    AND l_receipt_method_id IS NOT NULL
         THEN
            UPDATE ar_trx_header_gt
                set receipt_method_id = l_receipt_method_id
            WHERE trx_header_id = cCustDetailsRec.trx_header_id;
         END IF;

    END LOOP;
END;


/*Bug 8622438 Populate default payment method. Populates default data when both receipt method and
  payment trxn extension id passed ar enull*/

PROCEDURE populate_default_pay_method (
         x_errmsg                   OUT NOCOPY VARCHAR2,
         x_return_status            OUT NOCOPY VARCHAR2 ) AS

    CURSOR cCustDetails IS
        SELECT trx_currency, paying_customer_id, paying_site_use_id,
               bill_to_customer_id, bill_to_site_use_id, trx_date,
               trx_header_id, org_id, trx_number, customer_trx_id,
               mandate_last_trx_flag
        FROM ar_trx_header_gt
        WHERE receipt_method_id IS NULL
        AND   payment_trxn_extension_id IS NULL;

    l_receipt_method_name             ar_receipt_methods.name%type;
    l_receipt_method_id               ar_receipt_methods.receipt_method_id%type;
    l_creation_method_code            ar_receipt_classes.creation_method_code%type;
    l_bank_account_id                 ce_bank_accounts.bank_account_id%type;
    l_bank_account_num                ce_bank_accounts.bank_account_num%type;
    l_bank_name                       ce_bank_branches_v.bank_name%type;
    l_bank_branch_name                ce_bank_branches_v.bank_branch_name%type;
    l_bank_branch_id                  ce_bank_accounts.bank_branch_id%type;

    l_instrument_assignment_id        iby_trxn_extensions_v.instr_assignment_id%type;
    l_instrument_type                 iby_fndcpt_payer_assgn_instr_v.instrument_type%type;
    l_payment_channel_code            varchar2(30);

    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(500);
    l_payer                IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
    l_payer_equivalency    VARCHAR2(500);
    l_trxn_attribs         IBY_FNDCPT_TRXN_PUB.trxnextension_rec_type;
    l_entity_id            NUMBER;
    l_response             IBY_FNDCPT_COMMON_PUB.result_rec_type;

    -- This values based on global variables from FND_API G_TRUE and G_FALSE;
    l_true                 VARCHAR2(1) := 'T';
    l_false                 VARCHAR2(1) := 'F';


BEGIN

    FOR cCustDetailsRec IN cCustDetails
    LOOP
        arp_trx_defaults_3.get_pay_method_and_bank_deflts (
               p_trx_date                  => cCustDetailsRec.trx_date,
               p_currency_code             => cCustDetailsRec.trx_currency,
               p_paying_customer_id        => cCustDetailsRec.paying_customer_id,
               p_paying_site_use_id        => cCustDetailsRec.paying_site_use_id,
               p_bill_to_customer_id       => cCustDetailsRec.bill_to_customer_id,
               p_bill_to_site_use_id       => cCustDetailsRec.bill_to_site_use_id,
               p_payment_type_code         => null,
               p_payment_method_name       => l_receipt_method_name,
               p_receipt_method_id         => l_receipt_method_id,
               p_creation_method_code      => l_creation_method_code,
               p_customer_bank_account_id  => l_bank_account_id,
               p_bank_account_num          => l_bank_account_num,
               p_bank_name                 => l_bank_name,
               p_bank_branch_name          => l_bank_branch_name,
               p_bank_branch_id            => l_bank_branch_id
                                   );

         IF l_creation_method_code = 'AUTOMATIC'
                AND l_receipt_method_id IS NOT NULL
         THEN

             -- Set IN parameters for API from the block.
                l_payer.payment_function                  := 'CUSTOMER_PAYMENT';
                l_payer.party_id                          := ARP_TRX_DEFAULTS_3.get_party_id(cCustDetailsRec.paying_customer_id);
                l_payer.org_type                          := 'OPERATING_UNIT';
                l_payer.org_id                            := cCustDetailsRec.org_id;
                l_payer.cust_account_id                   := cCustDetailsRec.paying_customer_id;
                l_payer.account_site_id                   := cCustDetailsRec.paying_site_use_id;

                l_payer_equivalency                       := 'UPWARD';

                SELECT payment_channel_code,decode(payment_channel_code,'BANK_ACCT_XFER','BANKACCOUNT',
                                        'BILLS_RECEIVABLE','BANKACCOUNT','CREDIT_CARD','CREDITCARD','BANKACCOUNT')
                INTO     l_payment_channel_code,l_instrument_type
                FROM ar_receipt_methods
                WHERE receipt_method_id = l_receipt_method_id;


                arp_trx_defaults_3.get_instr_defaults(
                                        cCustDetailsRec.org_id,
                                        cCustDetailsRec.paying_customer_id,
                                        cCustDetailsRec.paying_site_use_id,
                                        l_instrument_type,
                                        cCustDetailsRec.trx_currency,
                                        l_instrument_assignment_id
                                         );

                l_trxn_attribs.originating_application_id := 222;
                l_trxn_attribs.order_id                   := cCustDetailsRec.trx_number;
                l_trxn_attribs.po_number                  := NULL;
                l_trxn_attribs.po_line_number             := NULL;
                l_trxn_attribs.trxn_ref_number1           := 'TRANSACTION';
                l_trxn_attribs.trxn_ref_number2           := cCustDetailsRec.customer_trx_id;
                l_trxn_attribs.instrument_security_code   := NULL;
                l_trxn_attribs.voiceauth_flag             := NULL;
                l_trxn_attribs.voiceauth_code             := NULL;
                l_trxn_attribs.voiceauth_date             := NULL;
                l_trxn_attribs.additional_info            := NULL;
                l_trxn_attribs.seq_type_last              := cCustDetailsRec.mandate_last_trx_flag;


                -- Call to insert the transaction extension through Payments PL/SQL API
                  IBY_FNDCPT_TRXN_PUB.create_transaction_extension(
                  p_api_version           => 1.0,
                  p_init_msg_list         => l_false,
                  p_commit                => l_true,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_payer                 => l_payer,
                  p_payer_equivalency     => l_payer_equivalency,
                  p_pmt_channel           => l_payment_channel_code,
                  p_instr_assignment      => l_instrument_assignment_id,
                  p_trxn_attribs          => l_trxn_attribs,
                  x_entity_id             => l_entity_id,
                  x_response              => l_response);

                -- The values are based on FND_API.  S, E, U (Success, Error, Unexpected
                IF (l_return_status = 'S') THEN
                    UPDATE ar_trx_header_gt
                    set receipt_method_id = l_receipt_method_id,
                    payment_trxn_extension_id=l_entity_id
                    WHERE trx_header_id = cCustDetailsRec.trx_header_id;

                ELSE
                        arp_standard.debug('Processing customer_trx_id :- '||cCustDetailsRec.customer_trx_id);
                        arp_standard.debug('result_code :- '||l_response.result_code);
                        arp_standard.debug('result_category :- '||l_response.result_category);
                        arp_standard.debug('result_message :- '||l_response.result_message);
                        arp_standard.debug('l_return_status :- '||l_return_status);
                        arp_standard.debug('l_msg_count :- '||l_msg_count);
                        arp_standard.debug('l_msg_data :- '||l_msg_data);
                END IF;


         END IF;
  END LOOP;

 EXCEPTION
 WHEN OTHERS THEN
   arp_standard.debug('Error in Default Payment Transaction Extension ID');
   arp_standard.debug('[' || SQLERRM(SQLCODE) || ']');
   x_errmsg := 'Error in Default Payment Transaction Extension ID' ||  SQLERRM;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   RAISE;


END populate_default_pay_method;

PROCEDURE validate_header (
    p_trx_system_param_rec      IN          AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
    p_trx_profile_rec           IN          AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) AS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_header (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    validate_trx_number (
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    --validate_no_of_batch_sources;
    validate_batch_source(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_currency(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    -- moving this check to populate_ref_header_attribute
    -- becoz transaction type can be populated from
    -- batch source in case user does not pass any.
    /*validate_transaction_type(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF; */





    populate_bill_to_customer_id (
      x_errmsg            =>  x_errmsg,
      x_return_status     =>  x_return_status );
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RETURN;
    END IF;

    validate_bill_to_customer_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_bill_to_customer_name(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_bill_to_cust_number(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    populate_ship_to_customer_id (
      x_errmsg            =>  x_errmsg,
      x_return_status     =>  x_return_status );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RETURN;
    END IF;

    validate_bill_to_site_use_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_bill_to_address_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_bill_to_contact_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;


    validate_sold_to_customer_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_terms(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_salesrep(
        p_trx_system_param_rec => p_trx_system_param_rec,
        x_errmsg                => x_errmsg,
        x_return_status         => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_invoicing_rule_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_print_option(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_default_tax(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_status(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_finance_charges(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_related_cust_trx_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_agreement_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_trx_class (
      x_errmsg         => x_errmsg,
      x_return_status  => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    validate_ship_via (
      x_errmsg         => x_errmsg,
      x_return_status  => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    validate_fob_point (
      x_errmsg         => x_errmsg,
      x_return_status  => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    validate_remit_to_address_id (
      x_errmsg         => x_errmsg,
      x_return_status  => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    validate_ussgl_code (
      x_errmsg         => x_errmsg,
      x_return_status  => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    validate_cust_bank_account_id (
      x_errmsg         => x_errmsg,
      x_return_status  => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    validate_doc_sequence_value (
      p_trx_system_param_rec => p_trx_system_param_rec,
      p_trx_profile_rec      => p_trx_profile_rec,
      x_errmsg               => x_errmsg,
      x_return_status        => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    validate_exchange_rate_type (
      x_errmsg               => x_errmsg,
      x_return_status        => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    validate_ship_to_site_use_id(
         x_errmsg                    => x_errmsg,
         x_return_status             => x_return_status,
	 x_called		     => 'BEFORE');
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
       RETURN;
    END IF;

    -- After validation of user input values
    -- now populate all the related values.

    populate_ref_hdr_attributes(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_gl_date (
        x_errmsg               => x_errmsg,
        x_return_status        => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

     validate_paying_customer_id (
      p_trx_system_param_rec => p_trx_system_param_rec,
      x_errmsg               => x_errmsg,
      x_return_status        => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    validate_paying_site_use_id (
      p_trx_system_param_rec => p_trx_system_param_rec,
      x_errmsg               => x_errmsg,
      x_return_status        => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    populate_doc_sequence (
        p_trx_system_param_rec      =>  p_trx_system_param_rec,
        p_trx_profile_rec           =>   p_trx_profile_rec,
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

/* PAYMENT UPTAKE */

     copy_pmt_extension(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;


    populate_ship_to_site_use_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;



    populate_ship_to_site_use_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    populate_ship_to_address_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    populate_ship_to_contact_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    validate_ship_to_customer_name(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_ship_to_cust_number(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_ship_to_customer_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;


    validate_ship_to_site_use_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_ship_to_location(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_ship_to_address(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_ship_to_contact_id(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    populate_exchange_rate (
        p_trx_system_parameters_rec      =>  p_trx_system_param_rec,
        p_trx_profile_rec            => p_trx_profile_rec,
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    populate_territory (
         p_trx_system_param_rec      => p_trx_system_param_rec,
         x_errmsg                    => x_errmsg,
         x_return_status             => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_territory_id (
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    populate_payment_method (
         x_errmsg                    => x_errmsg,
         x_return_status             => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

   /*8622438*/
    populate_default_pay_method (
         x_errmsg                    => x_errmsg,
         x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;


    validate_payment_method (
      x_errmsg         => x_errmsg,
      x_return_status  => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    /* SEPA changes */
    validate_mandate_flag (
      x_errmsg         => x_errmsg,
      x_return_status  => x_return_status);
    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RETURN;
    END IF;

    /* 4188835 - Default legal_entity_id */
    populate_legal_entity (
         x_errmsg                    => x_errmsg,
         x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    /* 4188835 - validate legal entity */
    validate_legal_entity(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_desc_flex for header (+)' );
    END IF;

    ar_invoice_validate_flex.validate_desc_flex (
        p_validation_type   => 'HEADER',
        x_errmsg            => x_errmsg,
        x_return_status     => x_return_status);
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_desc_flex for header (-)' );
        debug ('AR_INVOICE_UTILS.validate_header (-)' );
    END IF;

/*4369585-4589309*/
 populate_printing_pending(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

END validate_header;


PROCEDURE validate_lines (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2 ) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_lines (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    populate_line_attributes(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_line_integrity(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_tax_freight_lines (
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    validate_item_kflex (
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    validate_line_description(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    validate_quantity_invoiced(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    validate_unit_selling_price(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    validate_accounting_rules(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    validate_freight(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    -- populate extended and revenue amount
    --ar_invoice_default_pvt.get_extended_amount;

    validate_line_type(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    check_dup_line_number(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_warehouse_id (
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_uom_code(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    /* eTax now handles these validations, no need to call this
       routine
    validate_tax_code (
    x_errmsg                    => x_errmsg,
    x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;
    */

    validate_tax_exemption(
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_more_tab (
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    validate_line_ussgl_code  (
        x_errmsg                    => x_errmsg,
        x_return_status             => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RETURN;
    END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_desc_flex for lines (+)' );
    END IF;

    ar_invoice_validate_flex.validate_desc_flex (
        p_validation_type   => 'LINES',
        x_errmsg            => x_errmsg,
        x_return_status     => x_return_status);
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_desc_flex for lines (-)' );
        debug ('AR_INVOICE_UTILS.validate_lines (-)' );
    END IF;

END validate_lines;

PROCEDURE validate_accounting_flex (
     x_errmsg                    OUT NOCOPY  VARCHAR2,
     x_return_status             OUT NOCOPY  VARCHAR2 ) IS

CURSOR Cccid IS
    SELECT code_combination_id, trx_dist_id, trx_line_id, trx_header_id
    FROM   ar_trx_dist_gt
    WHERE  code_combination_id IS NOT NULL;
BEGIN
    -- first validate the ccid, if user has passed any ccid
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_accounting_flex (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR CccidRec IN Cccid
    LOOP
        IF NOT fnd_flex_keyval.validate_ccid (
                appl_short_name     => 'SQLGL',
                key_flex_code       => 'GL#',
                structure_number    => ARP_GLOBAL.chart_of_accounts_id,
                combination_id      => CccidRec.code_combination_id )
        THEN
            INSERT INTO ar_trx_errors_gt
            (   trx_header_id,
                trx_line_id,
                trx_dist_id,
                error_message,
                invalid_value)
                VALUES
                ( CccidRec.trx_header_id,
                  CccidRec.trx_line_id,
                  CccidRec.trx_dist_id,
                  arp_standard.fnd_message('AR_INVALID_CCID'),
                  CccidRec.code_combination_id);
        END IF;
    END LOOP;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_accounting_flex (-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_accounting_flex '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END;

PROCEDURE validate_distributions (
    p_trx_system_parameters_rec AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2 ) IS

    l_precision                 fnd_currencies.precision%type;
    l_min_acc_unit              fnd_currencies.minimum_accountable_unit%type;
 -- bug 6429861
	    l_per  number := 1;
	    l_amt  number := 1;


BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_distributions (+)' );
        debug ('Percentage Is null for Account Class: REC (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_precision := p_trx_system_parameters_rec.precision;
    l_min_acc_unit :=
            p_trx_system_parameters_rec.MINIMUM_ACCOUNTABLE_UNIT;

    INSERT INTO ar_trx_errors_gt
            (   trx_header_id,
                trx_line_id,
                trx_dist_id,
                error_message)
     SELECT  d.trx_header_id,
             d.trx_line_id,
             D.trx_DIST_ID,
             arp_standard.fnd_message('AR_INAPI_CCID_NULL')
     FROM   ar_trx_DIST_gt D
     WHERE  code_combination_id IS NULL;
    -- the user can pass either amount or percent. If both amount and percent
    -- is passed then amount will take precendence.

    --First check whether user passed either amounts or percent.
    INSERT INTO ar_trx_errors_gt
            (   trx_header_id,
                trx_line_id,
                trx_dist_id,
                error_message)
     SELECT  d.trx_header_id,
             d.trx_line_id,
             D.trx_DIST_ID,
             arp_standard.fnd_message('AR_INAPI_AMT_PER_REQUIRED')
     FROM   ar_trx_DIST_gt D
     WHERE  d.PERCENT IS NULL
      AND   d.amount IS NULL;

    --If accounting rule id is passed
    -- then all the amounts must be passed as percentage. All the amounts will be
    -- ignored.
    -- first check if account _class is 'REC' and if any accounting rule is passed
    -- then only percent is  allowed. Amount is not allowed.

    INSERT INTO ar_trx_errors_gt
            (   trx_header_id,
                trx_line_id,
                trx_dist_id,
                error_message)
     SELECT  d.trx_header_id,
             L.trx_line_id,
             D.trx_DIST_ID,
             arp_standard.fnd_message('AR_INAPI_ONLY_PER_ALLOWED')
        FROM   ar_trx_DIST_gt D,
               ar_trx_lines_GT L
        WHERE  (L.ACCOUNTING_RULE_ID IS NOT NULL
                OR D.ACCOUNT_CLASS = 'REC')
        AND    d.PERCENT IS NULL
        --AND    L.trx_line_ID = D.trx_line_ID;
        AND    L.trx_header_ID = D.trx_header_ID;

     IF pg_debug = 'Y'
    THEN
        debug ('Percentage Is null for Account Class: REC (-)' );
    END IF;



    -- check whether line type and account class matches

     INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_line_id,
         trx_dist_ID,
         error_message)
        SELECT d.trx_header_id,
               L.trx_LINE_ID,
               D.trx_DIST_ID,
               arp_standard.fnd_message('AR_INAPI_INAVLID_LINE_TYPE')
        FROM  ar_trx_dist_gt D,
              ar_trx_LINES_GT L
        WHERE  L.trx_LINE_ID = D.trx_LINE_ID
        AND    DECODE(D.ACCOUNT_CLASS,
                          'TAX',    'TAX',
                          'FREIGHT','FREIGHT',
                          'CHARGES','CHARGES',
                                    'LINE')
                <> L.LINE_TYPE;

    /*------------------------------------------------------------+
     | Update distribution lines with rounded amount              |
     | for account class: 'REV', 'TAX', 'FREIGHT', 'CHARGES'      |
     | For lines w/o accounting rules.                            |
    +------------------------------------------------------------*/

    UPDATE ar_trx_dist_gt D
        SET AMOUNT =
        (
         SELECT
         DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                NULL, ROUND(((D.PERCENT * L.extended_AMOUNT) / 100), C.PRECISION),
                ROUND(((D.PERCENT * L.extended_AMOUNT) / 100) /
                      C.MINIMUM_ACCOUNTABLE_UNIT) *
                  C.MINIMUM_ACCOUNTABLE_UNIT
                )
          FROM   FND_CURRENCIES C,
                 ar_trx_LINES_GT L
          WHERE  L.CURRENCY_CODE = C.CURRENCY_CODE
          AND    L.trx_LINE_ID = D.trx_LINE_ID
        )
        WHERE  ACCOUNT_CLASS IN ('REV', 'TAX', 'FREIGHT','CHARGES')
        AND   D.PERCENT IS NOT NULL
        AND   d.amount IS NULL
        AND   EXISTS
             (SELECT 'X'
              FROM   ar_trx_LINES_GT L
              WHERE  L.trx_LINE_ID = D.trx_LINE_ID
              AND    L.ACCOUNTING_RULE_ID IS NULL);

             -- bug 6429861
	     if(sql%rowcount=0) then
 	         l_amt :=0;
 	       end if;

    /*-----------------------------------------------------------+
     |  Calculate percents from amounts in GL Distributions for  |
     |  account classes REV, TAX, FREIGHT, CHARGES.              |
     |  If the line amount is 0, then percent is set to 0        |
     |  Precision = 4 digits to be consistent with the Invoice   |
     |              Entry form.                                  |
     |  For lines w/o accounting rules only.                     |
     +-----------------------------------------------------------*/

      UPDATE ar_trx_dist_gt D
        SET d.PERCENT =
        (
          SELECT DECODE(L.extended_AMOUNT,
                        0, 0,   /* set percent =0 if line amt = 0 */
                        ROUND(100 * (D.AMOUNT / L.extended_AMOUNT), 4))
          FROM   FND_CURRENCIES C,
                 ar_trx_LINES_GT L
          WHERE  L.CURRENCY_CODE = C.CURRENCY_CODE
          AND    L.trx_LINE_ID = D.trx_LINE_ID
        )
        WHERE ACCOUNT_CLASS in ('REV', 'TAX', 'FREIGHT', 'CHARGES')
        AND   D.AMOUNT IS NOT NULL
        AND   d.percent IS NULL
        AND   EXISTS
             (SELECT 'X'
              FROM   ar_trx_LINES_GT L
              WHERE  L.trx_LINE_ID = D.trx_LINE_ID
              AND    L.ACCOUNTING_RULE_ID IS NULL);

	      -- bug 6429861
	      if(sql%rowcount=0) then
 	         l_per :=0;
 	       end if;

    /* Bug-5532061 Begin*/
    /*------------------------------------------------------------+
     | Update distribution lines with rounded acctd_amount        |
     | for account class: 'REV', 'TAX', 'FREIGHT', 'CHARGES'      |
     | For lines w/o accounting rules.                            |
    +------------------------------------------------------------*/

      UPDATE ar_trx_dist_gt D
        SET ACCTD_AMOUNT =
        (
         SELECT
         DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                NULL, ROUND(((D.PERCENT * L.extended_AMOUNT * nvl(h.exchange_rate,1)) / 100), C.PRECISION),
                ROUND(((D.PERCENT * L.extended_AMOUNT * nvl(h.exchange_rate,1)) / 100) /
                      C.MINIMUM_ACCOUNTABLE_UNIT) *
                  C.MINIMUM_ACCOUNTABLE_UNIT
                )
          FROM   FND_CURRENCIES C,
                 ar_trx_LINES_GT L,
                 ar_trx_header_gt h
          WHERE  C.CURRENCY_CODE = p_trx_system_parameters_rec.base_currency_code
          AND    L.trx_LINE_ID = D.trx_LINE_ID
          AND    L.trx_header_id = h.trx_header_id
        )
        WHERE  ACCOUNT_CLASS IN ('REV', 'TAX', 'FREIGHT','CHARGES')
        AND   d.acctd_amount IS NULL
        AND   D.PERCENT IS NOT NULL
        AND   EXISTS
             (SELECT 'X'
              FROM   ar_trx_LINES_GT L
              WHERE  L.trx_LINE_ID = D.trx_LINE_ID
              AND    L.ACCOUNTING_RULE_ID IS NULL);

     /* Bug-5340103 End*/

     /*---------------------------------------------------------------+
     | Requirements for total amount of the gl distribution by        |
     | account class:                                                 |
     | REV must equal the amount at the line of line type LINE        |
     | TAX must equal the amount at the line of line type TAX         |
     | FREIGHT must equal the amount at the line of line type FREIGHT |
     | CHARGES must equal the amount at the line of line type CHARGES |
     +----------------------------------------------------------------*/
     /* 4652982 - fixed message name */
     INSERT INTO ar_trx_errors_gt
            (   trx_header_id,
                trx_line_id,
                error_message,
                invalid_value)
        SELECT l.trx_header_id,
               L.trx_LINE_ID,
               arp_standard.fnd_message('AR_INAPI_NVALID_SUM_DIST_AMT'),
               d.account_class || ':'||SUM(d.amount)
        FROM   ar_trx_DIST_gt D,
               ar_trx_lines_GT L
        WHERE  L.ACCOUNTING_RULE_ID IS NULL
        AND    L.LINE_TYPE = DECODE(D.ACCOUNT_CLASS,
                                    'REV', 'LINE',
                                    'TAX', 'TAX',
                                    'FREIGHT', 'FREIGHT',
                                    'CHARGES', 'CHARGES',
                                    'INVALID_TYPE')
        AND    L.trx_LINE_ID = D.trx_LINE_ID
        GROUP BY l.trx_header_id,
                 L.trx_LINE_ID,
                 L.LINE_TYPE,
                 L.extended_AMOUNT,
                 D.ACCOUNT_CLASS
        HAVING   L.extended_AMOUNT <> SUM(D.AMOUNT);

	--bug 6429861
	if(sql%rowcount=0 and l_per=0 and l_amt=0) then

     /*-----------------------------------------------------------------+
         | Percent should total to 100 for each account class              |
         +-----------------------------------------------------------------*/
    INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_LINE_ID,
         error_message,
         invalid_value)
        SELECT d.trx_header_id,
               d.trx_line_ID,
               arp_standard.fnd_message('AR_INAPI_100_PERCENT'),
               sum(d.percent)
        FROM   ar_trx_dist_gt d, ar_trx_lines_gt L, ar_trx_header_gt h
        WHERE  d.trx_line_id = l.trx_line_id
        AND    l.trx_header_id = h.trx_header_id
        GROUP BY d.trx_header_id,d.trx_line_ID, ACCOUNT_CLASS
        HAVING   SUM(d.PERCENT) <> 100;

     /*-----------------------------------------------------------------+
         | Percent should total to 100 for REC class in case it is passed |
         +-----------------------------------------------------------------*/
    INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         error_message,
         invalid_value)
        SELECT d.trx_header_id,
               arp_standard.fnd_message('AR_INAPI_100_PERCENT'),
               sum(d.percent)
        FROM   ar_trx_dist_gt d
        WHERE  d.account_class = 'REC'
        GROUP BY d.trx_header_id
        HAVING   SUM(d.PERCENT) <> 100;

	end if;

    /*********************************************************************
    ** The following checks are for  percent if the distribution is passed
    ** percent instead of Amount.
    ***********************************************************************/

    -- This is temporary code. First need to find out whether user will send
    -- the line  amount or percent.

    /* INSERT INTO RA_INTERFACE_ERRORS
        (INTERFACE_LINE_ID,
         INTERFACE_DISTRIBUTION_ID,
         MESSAGE_TEXT,
         INVALID_VALUE)
        SELECT INTERFACE_LINE_ID,
               INTERFACE_DISTRIBUTION_ID,
               DECODE(PERCENT, NULL, :error_message, :message2),
               NVL(TO_CHAR(PERCENT), :nil_message)
        FROM   RA_INTERFACE_DISTRIBUTIONS
        WHERE  REQUEST_ID = :request_id
        AND    ( PERCENT IS NULL
                OR
                 (NVL(PERCENT, 0) - ROUND(NVL(PERCENT,0), :pct_precision)) <> 0
                ); */

    -- update accounting set flag
    UPDATE ar_trx_dist_gt dgt
        SET dgt.account_set_flag =
                    (SELECT DECODE(hgt.invoicing_rule_id,null,'N','Y')
                      FROM ar_trx_header_gt hgt, ar_trx_lines_gt lgt
                      WHERE  hgt.trx_header_id = lgt.trx_header_id
                      AND    lgt.trx_line_id = dgt.trx_line_id
                      AND    dgt.account_class <> 'REC'
                      UNION
                      SELECT DECODE(h.invoicing_rule_id,null,'N','Y')
                      FROM ar_trx_header_gt h
                      WHERE h.trx_header_id = dgt.trx_header_id
                      AND   dgt.account_class = 'REC');

     -- Now update the amount
    /* UPDATE ar_trx_dist_gt D
     set (amount,acctd_amount) =
        (Select DECODE(D.ACCOUNT_CLASS,
                   'REC', NULL,
                   'TAX', DECODE(NVL(PREV_TRX.INVOICING_RULE_ID,
                            NVL(L_PARENT.INVOICING_RULE_ID,
                            L.INVOICING_RULE_ID)), NULL,
                            DECODE(D.AMOUNT, NULL,
                            DECODE(L.TAX_PRECEDENCE, NULL,
                              DECODE(L_PARENT.QUANTITY *
                                L_PARENT.UNIT_SELLING_PRICE, NULL,
                              DECODE(l_min_acc_unit, NULL,
                                     ROUND(NVL(l_parent.amount,0) *
                                           (NVL(l.tax_rate, 0)/100),
                                           l_precision),
                                     ROUND(NVL(l_parent.amount,0) *
                                           (NVL(l.tax_rate, 0)/100)/
                                           l_min_acc_unit) *
                                           l_min_acc_unit),
                              DECODE(l_min_acc_unit, NULL,
                                     ROUND(l_parent.quantity *
                                           l_parent.unit_selling_price *
                                           (NVL(l.tax_rate, 0)/100),
                                           l_precision),
                                     ROUND(l_parent.quantity *
                                     l_parent.unit_selling_price *
                                           (nvl(l.tax_rate, 0)/100)/
                                           l_min_acc_unit) *
                                           l_min_acc_unit)),0),
                                    D.AMOUNT), NULL ),
                            DECODE(NVL(PREV_TRX.INVOICING_RULE_ID,
                                   NVL(L_PARENT.INVOICING_RULE_ID,
                                    L.INVOICING_RULE_ID)),
                                    NULL, D.AMOUNT,
                                    NULL)), -- amount
                            DECODE(D.ACCOUNT_CLASS,
                            'REC', null,
                            'TAX', DECODE(NVL(PREV_TRX.INVOICING_RULE_ID,
                              NVL(L_PARENT.INVOICING_RULE_ID,
                                  L.INVOICING_RULE_ID)),
                          NULL, DECODE(D.ACCTD_AMOUNT, NULL,
                                       DECODE(L.CURRENCY_CODE,
                                              G.CURRENCY_CODE,
                       DECODE(D.AMOUNT, NULL, DECODE(L.TAX_PRECEDENCE, NULL,
                         DECODE(L_PARENT.QUANTITY * L_PARENT.UNIT_SELLING_PRICE,
                              NULL, DECODE(l_min_acc_unit, NULL,
                                      ROUND(NVL(l_parent.amount,0) *
                                           (NVL(l.tax_rate, 0)/100), l_precision)
,
                                      ROUND(NVL(l_parent.amount,0) *
                                           (NVL(l.tax_rate, 0)/100)/
                                           l_min_acc_unit) * l_min_acc_unit),
                                    DECODE(l_min_acc_unit, NULL,
                                      ROUND(l_parent.quantity *
                                            l_parent.unit_selling_price *
                                            (NVL(l.tax_rate, 0)/100),l_precision)
,
                                      ROUND(l_parent.quantity *
                                       l_parent.unit_selling_price *
                                            (nvl(l.tax_rate, 0)/100)/
                                            l_min_acc_unit) * l_min_acc_unit)),0),
                       D.amount) ,
                                              DECODE(l_min_acc_unit,
                                                     NULL,
                                                     ROUND(
                       DECODE(D.AMOUNT, NULL, DECODE(L.TAX_PRECEDENCE, NULL,
                         DECODE(L_PARENT.QUANTITY * L_PARENT.UNIT_SELLING_PRICE,
                              NULL, DECODE(l_min_acc_unit, NULL,
                                      ROUND(NVL(l_parent.amount,0) *
                                           (NVL(l.tax_rate, 0)/100), l_precision)
,
                                      ROUND(NVL(l_parent.amount,0) *
                                           (NVL(l.tax_rate, 0)/100)/
                                           l_min_acc_unit) * l_min_acc_unit),
                                    DECODE(l_min_acc_unit, NULL,
                                      ROUND(l_parent.quantity *
                                            l_parent.unit_selling_price *
                                            (NVL(l.tax_rate, 0)/100),l_precision)
,
                                      ROUND(l_parent.quantity *
                                            l_parent.unit_selling_price * --
                                            (nvl(l.tax_rate, 0)/100)/
                                            l_min_acc_unit) * l_min_acc_unit)),0),
                       D.amount) * h.exchange_rate , l_precision ), --L.CONVERSION_RATE, l_precision,
                                                     ROUND(
                       DECODE(D.AMOUNT, NULL, DECODE(L.TAX_PRECEDENCE, NULL,
                         DECODE(L_PARENT.QUANTITY * L_PARENT.UNIT_SELLING_PRICE,
                              NULL, DECODE(l_min_acc_unit, NULL,
                                      ROUND(NVL(l_parent.amount,0) *
                                           (NVL(l.tax_rate, 0)/100), l_precision)
,
                                      ROUND(NVL(l_parent.amount,0) *
                                           (NVL(l.tax_rate, 0)/100)/
                                           l_min_acc_unit) * l_min_acc_unit),
                                    DECODE(l_min_acc_unit, NULL,
                                      ROUND(l_parent.quantity *
                                            l_parent.unit_selling_price *
                                            (NVL(l.tax_rate, 0)/100),l_precision)
,
                                      ROUND(l_parent.quantity *
                                            l_parent.unit_selling_price *
                                            (nvl(l.tax_rate, 0)/100)/
                                            l_min_acc_unit) * l_min_acc_unit)),0),
                       D.amount) * h.exchange_rate / l_min_acc_unit ) * --L.CONVERSION_RATE / l_min_acc_unit *
                       l_min_acc_unit)),
                                       D.ACCTD_AMOUNT), NULL),
                   DECODE(NVL(PREV_TRX.INVOICING_RULE_ID,
                              NVL(L_PARENT.INVOICING_RULE_ID,
                                  L.INVOICING_RULE_ID)),
                          NULL, DECODE(D.ACCTD_AMOUNT, NULL,
                                       DECODE(L.CURRENCY_CODE,
                                              G.CURRENCY_CODE, D.AMOUNT,
                                              DECODE(l_min_acc_unit,
                                                     NULL,
                                                     ROUND(D.AMOUNT *
                                                           h.exchange_rate , --L.CONVERSION_RATE,
                                                           l_precision),
                                                     ROUND(D.AMOUNT *
                                                           h.exchange_rate ,--L.CONVERSION_RATE /
                                                      l_min_acc_unit) *
                                                     l_min_acc_unit)),
                                       D.ACCTD_AMOUNT),
                          NULL))
                          FROM   ar_trx_DIST_gt D,
                                 ar_trx_header_gt h
                                 --RA_CUST_TRX_TYPES TYPE,
                                 FND_CURRENCIES C,
                                 GL_SETS_OF_BOOKS G,
                                 --RA_CUSTOMER_TRX PREV_TRX,
                                 ar_trx_LINES_GT L_PARENT,
                                 ar_trx_LINES_GT L
                          WHERE  --L.REQUEST_ID = :request_id
                                 --L.PREVIOUS_CUSTOMER_TRX_ID = PREV_TRX.CUSTOMER_TRX_ID(+)
                          --AND    L.CUST_TRX_TYPE_ID = TYPE.CUST_TRX_TYPE_ID
                                 h.trx_header_id = l_trx_header_id
                          AND    L.CURRENCY_CODE = C.CURRENCY_CODE
                          AND    L.SET_OF_BOOKS_ID = G.SET_OF_BOOKS_ID
                          AND    L.CUSTOMER_TRX_ID IS NOT NULL
                          AND    L.LINK_TO_cust_trx_LINE_ID = L_PARENT.trx_LINE_ID (+)
                          AND    L.trx_LINE_ID = D.trx_LINE_ID
                          AND    D.ACCOUNT_CLASS = 'TAX'); */

    validate_accounting_flex (
        x_errmsg        => x_errmsg,
        x_return_status => x_return_status );
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
         RETURN;
    END IF;

    -- validate desc flex

    ar_invoice_validate_flex.validate_desc_flex (
        p_validation_type   => 'DISTRIBUTIONS',
        x_errmsg            => x_errmsg,
        x_return_status     => x_return_status);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_desc_flex for distributions(-)' );
    END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_distributions (-)' );
    END IF;

    /*4673387*/
    UPDATE ar_trx_dist_gt
       SET gl_date = NULL
       WHERE trx_header_id IN  (SELECT trx_header_id
                                    FROM ar_trx_header_gt gt,
                                         ra_cust_trx_types ctt
                                    WHERE ctt.cust_trx_type_id = gt.cust_trx_type_id
                                    AND   ctt.post_to_gl = 'N');

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_UTILS.validate_distributions '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;
END validate_distributions;


PROCEDURE validate_salescredits (
  p_trx_system_param_rec ar_invoice_default_pvt.trx_system_parameters_rec_type,
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2 ) IS

    pct_precision       NUMBER := 4;
    CURSOR cRounding IS
        SELECT trx_line_id, (100 - SUM(revenue_percent_split)) rounding_error,
               MAX(SC.trx_SALESCREDIT_ID) max_trx_salescredit_id
        FROM   ar_trx_SALESCREDITS_gt SC,
               SO_SALES_CREDIT_TYPES CR
        WHERE  SC.SALES_CREDIT_TYPE_ID = CR.SALES_CREDIT_TYPE_ID
        AND    CR.QUOTA_FLAG = 'Y'
        GROUP BY trx_LINE_ID
        HAVING SUM(revenue_percent_split) <> 100;

     CURSOR   cRoundingAmt IS
     SELECT  l.trx_line_id, MIN(L.trx_LINE_ID) min_trx_line_id,
                MIN(DECODE(L.QUANTITY_invoiced * L.UNIT_SELLING_PRICE,
                           NULL, L.extended_AMOUNT,
                           DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                                  NULL,
                                  ROUND(L.quantity_invoiced * L.UNIT_SELLING_PRICE,
                                        C.PRECISION),
                                  ROUND(L.quantity_invoiced *
                                        L.UNIT_SELLING_PRICE/
                                        C.MINIMUM_ACCOUNTABLE_UNIT)
                                  * C.MINIMUM_ACCOUNTABLE_UNIT
                                  )
                           )
                    ) line_amount,
                MAX(SC.trx_SALESCREDIT_ID) max_trx_salescredit_id,
                SUM(revenue_amount_split) sales_credit_amount
        FROM    FND_CURRENCIES C,
                ar_trx_SALESCREDITS_gt SC,
                SO_SALES_CREDIT_TYPES CR,
                ar_trx_LINES_GT L
        WHERE   L.LINE_TYPE = 'LINE'
        AND     L.CURRENCY_CODE = C.CURRENCY_CODE
        and     L.trx_LINE_ID = SC.trx_LINE_ID
        and     SC.SALES_CREDIT_TYPE_ID = CR.SALES_CREDIT_TYPE_ID
        AND     CR.QUOTA_FLAG = 'Y'
        GROUP BY L.trx_LINE_ID;

  l_message_name VARCHAR2(30);

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_salescredits (+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INAPI_INVALID_SALESREP_ID',
      p_app_short_name => 'AR');

    -- validate  salesrep_id
    INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_LINE_ID,
         trx_salescredit_id,
         error_MESSAGE,
         INVALID_VALUE)
        SELECT trx_header_id,
               trx_LINE_ID,
               trx_SALESCREDIT_ID,
               arp_standard.fnd_message(l_message_name),
               sc.salesrep_id
        FROM   ar_trx_salescredits_gt SC
        WHERE  salesrep_id IS NOT NULL
        AND    NOT EXISTS
              (SELECT 'X'
               FROM   RA_SALESREPS REP
               WHERE  REP.SALESREP_ID = SC.SALESREP_ID);

    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INAPI_NVALID_SALESREP_NUM',
      p_app_short_name => 'AR');

    -- validate salesrep number
     INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_LINE_ID,
         trx_salescredit_id,
         error_MESSAGE,
         INVALID_VALUE)
        SELECT trx_header_id,
               trx_LINE_ID,
               trx_salescredit_id,
               arp_standard.fnd_message(l_message_name),
               sc.salesrep_num
        FROM   ar_trx_salescredits_gt SC
        WHERE  sc.salesrep_num IS NOT NULL
        AND    NOT EXISTS
              (SELECT 'X'
               FROM   RA_SALESREPS REP
               WHERE  REP.SALESREP_NUMber = SC.SALESREP_NUM);

       UPDATE ar_trx_salescredits_gt SC
        SET    SALESREP_ID = (SELECT SALESREP_ID
                              FROM   RA_SALESREPS REP
                              WHERE  REP.SALESREP_NUMBER = SC.SALESREP_NUM)
        WHERE  salesrep_id IS NULL;

    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INAPI_INVALID_SCR_TYPE_ID',
      p_app_short_name => 'AR');

    -- validate sales credit type ID
    INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_LINE_ID,
         trx_salescredit_id,
         error_MESSAGE,
         INVALID_VALUE)
        SELECT trx_header_id,
               trx_LINE_ID,
               trx_SALESCREDIT_ID,
               arp_standard.fnd_message(l_message_name),
               sc.sales_credit_type_id
        FROM   ar_trx_salescredits_gt SC
        WHERE  sales_credit_type_id IS NOT NULL
        AND    NOT EXISTS
              (SELECT 'X'
               FROM   SO_SALES_CREDIT_TYPES CR
               WHERE  CR.SALES_CREDIT_TYPE_ID = SC.SALES_CREDIT_TYPE_ID);

    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INAPI_INVLD_SCR_TYPE_NAME',
      p_app_short_name => 'AR');

    -- validate sales credit type name
    INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_LINE_ID,
         trx_salescredit_id,
         error_MESSAGE,
         INVALID_VALUE)
        SELECT trx_header_id,
               trx_line_id,
               trx_salescredit_id,
               arp_standard.fnd_message(l_message_name),
               sc.sales_credit_type_name
        FROM   ar_trx_salescredits_gt SC
        WHERE  sales_credit_type_name IS NOT NULL
        AND    NOT EXISTS
              (SELECT 'X'
               FROM   SO_SALES_CREDIT_TYPES CR
               WHERE  CR.NAME = SC.SALES_CREDIT_TYPE_NAME);

    -- update the sales credit type id
    UPDATE ar_trx_salescredits_gt SC
    SET    SALES_CREDIT_TYPE_ID =
                      (SELECT SALES_CREDIT_TYPE_ID
                       FROM   SO_SALES_CREDIT_TYPES CR
                       WHERE  CR.NAME = SC.SALES_CREDIT_TYPE_NAME)
         WHERE  SALES_CREDIT_TYPE_ID IS NULL;

    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INAPI_SCR_AMT_PERCENT_REQ',
      p_app_short_name => 'AR');

    -- validate either amount or percent has been passed by user
     INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_LINE_ID,
         trx_salescredit_id,
         error_MESSAGE)
         SELECT trx_header_id,
                trx_LINE_ID,
                trx_SALESCREDIT_ID,
                arp_standard.fnd_message(l_message_name)
         FROM   ar_trx_salescredits_gt SC,
               so_sales_credit_types CR				 --Bug8202014
        WHERE  sc.sales_credit_type_id = cr.sales_credit_type_id --Bug8202014
        AND  revenue_amount_split IS NULL
        AND  revenue_percent_split IS NULL
        AND  cr.quota_flag = 'Y';	--Bug8202014


    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INAPI_INVALID_SCR',
      p_app_short_name => 'AR');

    /*--------------------------------------------------------------+
     | Verify that sales credit assignments are for line type LINE  |
     +--------------------------------------------------------------*/
   INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_LINE_ID,
         trx_salescredit_id,
         error_MESSAGE,
         INVALID_VALUE)
    SELECT S.trx_header_id,
           S.trx_LINE_ID,
           S.trx_SALESCREDIT_ID,
           arp_standard.fnd_message(l_message_name),
           L.LINE_TYPE
    FROM   ar_trx_LINES_GT L,
           ar_trx_SALESCREDITS_gt S
    WHERE  S.trx_LINE_ID = L.trx_LINE_ID
    AND    L.LINE_TYPE <> 'LINE';



    -- Depending on the amount passed update the percent split
    UPDATE ar_trx_SALESCREDITS_gt S1
        SET revenue_percent_split =
        (
          SELECT DECODE(DECODE(L.QUANTITY_invoiced * L.UNIT_SELLING_PRICE,
                               NULL, L.extended_AMOUNT,
                               DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                                      NULL, ROUND(QUANTITY_invoiced *
                                                  UNIT_SELLING_PRICE,
                                                  C.PRECISION),
                                      ROUND(L.QUANTITY_invoiced *
                                            L.UNIT_SELLING_PRICE/
                                            C.MINIMUM_ACCOUNTABLE_UNIT)
                                      * C.MINIMUM_ACCOUNTABLE_UNIT
                                      )
                               ),
                        0, 0,
                        ROUND(S2.revenue_amount_split * 100 /
                              DECODE(L.QUANTITY_invoiced * L.UNIT_SELLING_PRICE,
                                     NULL, L.extended_AMOUNT,
                                     DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                                            NULL, ROUND(QUANTITY_invoiced *
                                                        UNIT_SELLING_PRICE,
                                                        C.PRECISION),
                                            ROUND(L.QUANTITY_invoiced *
                                                  L.UNIT_SELLING_PRICE/
                                                  C.MINIMUM_ACCOUNTABLE_UNIT)
                                            * C.MINIMUM_ACCOUNTABLE_UNIT
                                            )
                                     ),
                              pct_precision))
        FROM   ar_trx_LINES_GT L,
                FND_CURRENCIES C,
                ar_trx_SALESCREDITS_gt S2
        WHERE  L.trx_LINE_ID = S2.trx_LINE_ID
              AND    L.LINE_TYPE = 'LINE'
            AND    L.CURRENCY_CODE = C.CURRENCY_CODE
            AND    S2.ROWID = S1.ROWID
            )
        WHERE  S1.revenue_amount_split IS NOT NULL
        AND    S1.revenue_percent_split IS NULL;


    -- update amount split if percent has been passed
    UPDATE ar_trx_salescredits_gt SC
        SET    revenue_amount_split =
              (SELECT DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                             NULL,
                             ROUND(SC.revenue_percent_split *
                                   DECODE(L.QUANTITY_invoiced * L.UNIT_SELLING_PRICE,
                                          NULL, L.extended_AMOUNT,
                                          DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                                                 NULL,
                                                 ROUND(L.QUANTITY_invoiced *
                                                       L.UNIT_SELLING_PRICE,
                                                       C.PRECISION),
                                                 ROUND(L.QUANTITY_invoiced *
                                                       L.UNIT_SELLING_PRICE/
                                                    C.MINIMUM_ACCOUNTABLE_UNIT)
                                                 * C.MINIMUM_ACCOUNTABLE_UNIT
                                                 )
                                          ) / 100,
                                   C.PRECISION),
                             ROUND((SC.revenue_percent_split *
                                    DECODE(L.QUANTITY_invoiced *
                                           L.UNIT_SELLING_PRICE,
                                           NULL, L.extended_amount,
                                           DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                                                  NULL,
                                                  ROUND(L.QUANTITY_invoiced *
                                                        L.UNIT_SELLING_PRICE,
                                                        C.PRECISION),
                                                  ROUND(L.QUANTITY_invoiced *
                                                        L.UNIT_SELLING_PRICE/
                                                    C.MINIMUM_ACCOUNTABLE_UNIT)
                                                  * C.MINIMUM_ACCOUNTABLE_UNIT
                                                  )
                                           ) / 100) /
                                   C.MINIMUM_ACCOUNTABLE_UNIT)
                             * C.MINIMUM_ACCOUNTABLE_UNIT
                             )
               FROM   ar_trx_LINES_GT L,
                      FND_CURRENCIES C
               WHERE  L.trx_LINE_ID = SC.trx_LINE_ID
               AND    L.CURRENCY_CODE = C.CURRENCY_CODE)
        WHERE  SC.revenue_percent_split IS NOT NULL
        AND    SC.revenue_amount_split IS NULL;

        /******************************************************************************
         Bug8202014 Changes Start Here
         If non_revenue_percent_split is passed, calculate the non_revenue_amount_split
         If non_revenue_amount_split is passed, calculate the non_revenue_percent_split
         Added the following 2 updated statements for this.
         *******************************************************************************/

    -- update non_revenue_percent_split if non_revenue_amount_split has been passed
    UPDATE ar_trx_SALESCREDITS_gt S1
        SET non_revenue_percent_split =
        (
          SELECT DECODE(DECODE(L.QUANTITY_invoiced * L.UNIT_SELLING_PRICE,
                               NULL, L.extended_AMOUNT,
                               DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                                      NULL, ROUND(QUANTITY_invoiced *
                                                  UNIT_SELLING_PRICE,
                                                  C.PRECISION),
                                      ROUND(L.QUANTITY_invoiced *
                                            L.UNIT_SELLING_PRICE/
                                            C.MINIMUM_ACCOUNTABLE_UNIT)
                                      * C.MINIMUM_ACCOUNTABLE_UNIT
                                      )
                               ),
                        0, 0,
                        ROUND(S2.non_revenue_amount_split * 100 /
                              DECODE(L.QUANTITY_invoiced * L.UNIT_SELLING_PRICE,
                                     NULL, L.extended_AMOUNT,
                                     DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                                            NULL, ROUND(QUANTITY_invoiced *
                                                        UNIT_SELLING_PRICE,
                                                        C.PRECISION),
                                            ROUND(L.QUANTITY_invoiced *
                                                  L.UNIT_SELLING_PRICE/
                                                  C.MINIMUM_ACCOUNTABLE_UNIT)
                                            * C.MINIMUM_ACCOUNTABLE_UNIT
                                            )
                                     ),
                              pct_precision))
        FROM   ar_trx_LINES_GT L,
                FND_CURRENCIES C,
                ar_trx_SALESCREDITS_gt S2
        WHERE  L.trx_LINE_ID = S2.trx_LINE_ID
              AND    L.LINE_TYPE = 'LINE'
            AND    L.CURRENCY_CODE = C.CURRENCY_CODE
            AND    S2.ROWID = S1.ROWID
            )
        WHERE  S1.non_revenue_amount_split IS NOT NULL
        AND    S1.non_revenue_percent_split IS NULL;


    -- update non_revenue_amount_split if non_revenue_percent_split has been passed
    UPDATE ar_trx_salescredits_gt SC
        SET    non_revenue_amount_split =
              (SELECT DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                             NULL,
                             ROUND(SC.non_revenue_percent_split *
                                   DECODE(L.QUANTITY_invoiced * L.UNIT_SELLING_PRICE,
                                          NULL, L.extended_AMOUNT,
                                          DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                                                 NULL,
                                                 ROUND(L.QUANTITY_invoiced *
                                                       L.UNIT_SELLING_PRICE,
                                                       C.PRECISION),
                                                 ROUND(L.QUANTITY_invoiced *
                                                       L.UNIT_SELLING_PRICE/
                                                    C.MINIMUM_ACCOUNTABLE_UNIT)
                                                 * C.MINIMUM_ACCOUNTABLE_UNIT
                                                 )
                                          ) / 100,
                                   C.PRECISION),
                             ROUND((SC.non_revenue_percent_split *
                                    DECODE(L.QUANTITY_invoiced *
                                           L.UNIT_SELLING_PRICE,
                                           NULL, L.extended_amount,
                                           DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                                                  NULL,
                                                  ROUND(L.QUANTITY_invoiced *
                                                        L.UNIT_SELLING_PRICE,
                                                        C.PRECISION),
                                                  ROUND(L.QUANTITY_invoiced *
                                                        L.UNIT_SELLING_PRICE/
                                                    C.MINIMUM_ACCOUNTABLE_UNIT)
                                                  * C.MINIMUM_ACCOUNTABLE_UNIT
                                                  )
                                           ) / 100) /
                                   C.MINIMUM_ACCOUNTABLE_UNIT)
                             * C.MINIMUM_ACCOUNTABLE_UNIT
                             )
               FROM   ar_trx_LINES_GT L,
                      FND_CURRENCIES C
               WHERE  L.trx_LINE_ID = SC.trx_LINE_ID
               AND    L.CURRENCY_CODE = C.CURRENCY_CODE)
        WHERE  SC.non_revenue_percent_split IS NOT NULL
        AND    SC.non_revenue_amount_split IS NULL;

        /*********************************************************
         Bug8202014 Changes End Here
         ********************************************************/

    -- fix rounding error if any in percent
    FOR cRoundingRec IN cRounding
    LOOP
        UPDATE ar_trx_SALESCREDITS_gt
        SET    revenue_percent_split = revenue_percent_split + cRoundingRec.rounding_error
        WHERE  trx_SALESCREDIT_ID = cRoundingRec.max_trx_salescredit_id;
    END LOOP;

    -- fix rounding error in amount if any
    For cRoundingAmtRec IN cRoundingAmt
    LOOP
         UPDATE ar_trx_SALESCREDITS_gt
         SET    revenue_amount_split = revenue_amount_split +
                                          (cRoundingAmtRec.line_amount -
                                            cRoundingAmtRec.sales_credit_amount)
            WHERE   trx_SALESCREDIT_ID = cRoundingAmtRec.max_trx_salescredit_id;


    END LOOP;

    -- validate amount precision
     INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_LINE_ID,
         trx_salescredit_id,
         error_MESSAGE,
         invalid_value)
     SELECT S.trx_header_id,
            S.trx_LINE_ID,
            S.trx_SALESCREDIT_ID,
            arp_standard.fnd_message('AR_INAPI_INVALID_PRECISION'),
            S.revenue_amount_split
     FROM   ar_trx_salescredits_gt  S,
            ar_trx_LINES_GT L,
            FND_CURRENCIES C
     WHERE  S.trx_LINE_ID = L.trx_LINE_ID
     AND    L.CURRENCY_CODE = C.CURRENCY_CODE
     AND    s.revenue_amount_split IS NOT NULL
     GROUP BY S.trx_header_id, S.trx_LINE_ID,
                  S.trx_SALESCREDIT_ID,
                  S.revenue_amount_split,
                  C.MINIMUM_ACCOUNTABLE_UNIT,
                  C.PRECISION
     HAVING DECODE(C.MINIMUM_ACCOUNTABLE_UNIT,
                       NULL, ROUND(S.revenue_amount_split,
                                   C.PRECISION),
                       ROUND(S.revenue_amount_split /
                             C.MINIMUM_ACCOUNTABLE_UNIT) *
                       C.MINIMUM_ACCOUNTABLE_UNIT) -
                           S.revenue_amount_split <> 0;

    /*------------------------------------------------------------+
         | Identify null or invalid sales credit percent split        |
         +------------------------------------------------------------*/

    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INAPI_INVALID_PERCENT_SPLIT',
      p_app_short_name => 'AR');

        INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_LINE_ID,
         trx_salescredit_id,
         error_MESSAGE,
         invalid_value)
        SELECT SC.trx_header_id,
               SC.trx_LINE_ID,
               SC.trx_SALESCREDIT_ID,
               arp_standard.fnd_message(l_message_name),
               SC.revenue_percent_split
        FROM   ar_trx_salescredits_gt SC,
               SO_SALES_CREDIT_TYPES SCT
        WHERE  SC.SALES_CREDIT_TYPE_ID = SCT.SALES_CREDIT_TYPE_ID
     	AND    SCT.QUOTA_FLAG = 'Y'					--Bug8202014
        AND    ( SC.revenue_percent_split IS NULL
                OR
                 (NVL(SC.revenue_percent_split, 0) -
                  ROUND(NVL(SC.revenue_percent_split, 0),
                        pct_precision) <> 0)
                );

        /*------------------------------------------------------------+
         | Identify un-foot sales credit                              |
         +------------------------------------------------------------*/
        INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_line_id,
         error_MESSAGE)
        SELECT SC.trx_header_id,
               SC.trx_LINE_ID,
               arp_standard.fnd_message(l_message_name)
        FROM
               ar_trx_salescredits_gt SC,
               SO_SALES_CREDIT_TYPES CR
        WHERE  SC.SALES_CREDIT_TYPE_ID = CR.SALES_CREDIT_TYPE_ID
        AND    cr.quota_flag = 'Y'					--Bug8202014
        GROUP BY
               sc.trx_header_id, sc.trx_LINE_ID
        HAVING
                SUM(DECODE(CR.QUOTA_FLAG,
                           'Y',  SC.revenue_percent_split,
                           'N', 0,
                           NULL, 0
                           ) )  <> 100;

    l_message_name := gl_public_sector.get_message_name (
      p_message_name => 'AR_INAPI_SUM_NOT_EQUAL_LINE',
      p_app_short_name => 'AR');

    -- identify un-foot sales credit for amount
    -- Sum of sales credit does not equal to line amount
    INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_line_id,
         error_message,
         invalid_value)
         SELECT s.trx_header_id,
                s.trx_line_id,
                arp_standard.fnd_message(l_message_name),
                SUM(S.revenue_amount_split)
         FROM   ar_trx_salescredits_gt s,
                so_sales_credit_types t
         WHERE  s.sales_credit_type_id = t.sales_credit_type_id
         AND    s.revenue_amount_split IS NOT NULL
         AND    t.quota_flag = 'Y'
         GROUP BY S.trx_header_id, S.trx_line_id
         HAVING SUM(S.revenue_amount_split) <>
           (SELECT DECODE(l.quantity_invoiced * l.unit_selling_price,
                          NULL, l.extended_amount,
                          DECODE(c.minimum_accountable_unit, NULL,
                            ROUND(quantity_invoiced * unit_selling_price,
                                  c.precision),
                             ROUND(l.quantity_invoiced * l.unit_selling_price
                               / c.minimum_accountable_unit) *
                               c.minimum_accountable_unit))
            FROM  ar_trx_lines_gt l,
                  fnd_currencies c
            WHERE l.trx_line_id = s.trx_line_id
            AND   l.line_type = 'LINE'
            AND   l.currency_code = c.currency_code);


    -- if the require salesrep option is checked in the system options form,
    -- then salescredit information must be passed.
    --

    IF (p_trx_system_param_rec.salesrep_required_flag = 'Y') THEN

      l_message_name := gl_public_sector.get_message_name (
        p_message_name => 'AR_INAPI_ONE_SALESCREDIT_ROW',
        p_app_short_name => 'AR');

      INSERT INTO ar_trx_errors_gt
        (trx_header_id,
         trx_line_id,
         error_message)
       SELECT lgt.trx_header_id,
              lgt.trx_line_id,
              arp_standard.fnd_message(l_message_name)
       FROM   ar_trx_lines_gt lgt
       WHERE  lgt.line_type = 'LINE'
       AND    NOT EXISTS
         (SELECT 'X'
          FROM   ar_trx_salescredits_gt scgt,
                 so_sales_credit_types type
          WHERE  scgt.trx_header_id = lgt.trx_header_id
          AND    scgt.trx_line_id   = lgt.trx_line_id
          AND    scgt.sales_credit_type_id = type.sales_credit_type_id
          AND    type.quota_flag = 'Y' );

    END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_salescredits (-)' );
    END IF;

    -- validate desc flex
    ar_invoice_validate_flex.validate_desc_flex (
        p_validation_type   => 'SALESREPS',
        x_errmsg            => x_errmsg,
        x_return_status     => x_return_status);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_INVOICE_UTILS.validate_desc_flex in Salesereps(-)' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_errmsg := 'AR_INVOICE_UTILS.validate_salescredits '||sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;

END validate_salescredits;

END AR_INVOICE_UTILS;

/
