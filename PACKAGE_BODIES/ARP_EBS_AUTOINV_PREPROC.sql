--------------------------------------------------------
--  DDL for Package Body ARP_EBS_AUTOINV_PREPROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_EBS_AUTOINV_PREPROC" AS
/* $Header: AREBSPPB.pls 120.5 2005/07/01 15:31:58 mraymond noship $ */

PROCEDURE update_trx ( p_request_id IN NUMBER,
                       p_func_curr_code IN VARCHAR2,
                       p_error_code IN OUT NOCOPY NUMBER ) IS

CURSOR curr_code IS
     SELECT distinct l.currency_code, curr.end_date_active
     FROM   RA_INTERFACE_LINES_GT l,
            FND_CURRENCIES curr
     WHERE  l.request_id = p_request_id
     AND    l.currency_code = curr.currency_code
     AND    curr.derive_type = 'EMU'  ;

     err_msg VARCHAR2(255);

BEGIN
     err_msg := FND_MESSAGE.GET_STRING('AR','AR_RAXTRX_CONV_CM');

     FOR rec IN curr_code LOOP

     -- Flag credit memos with temporary error
     INSERT INTO RA_INTERFACE_ERRORS
     (INTERFACE_LINE_ID,
      MESSAGE_TEXT,
      INVALID_VALUE,
      ORG_ID )
     SELECT interface_line_id,
            err_msg,
            NULL,
            org_id
     FROM   RA_INTERFACE_LINES
     WHERE  request_id = p_request_id
     AND    trx_date > NVL(rec.end_date_active,
                         to_date('31-12-2001','DD-MM-YYYY'))
     AND    currency_code = rec.currency_code
     AND    cust_trx_type_id in ( SELECT cust_trx_type_id
                                  FROM   ra_cust_trx_types
                                  WHERE  type = 'CM' ) ;

     -- Updating dist rows
     -- note use of sysdate - EMU currencies have fixed conversion
     UPDATE ra_interface_distributions dist
     SET    amount = GL_CURRENCY_API.convert_amount( rec.currency_code,
                                                     p_func_curr_code,
                                                     sysdate,
                                                     'EMU FIXED',
                                                     dist.amount ),
            acctd_amount = null
     WHERE  interface_line_id in (
                  select interface_line_id
                  from   ra_interface_lines_gt
                  where  request_id = p_request_id
                  and    trx_date > NVL(rec.end_date_active,
                                      to_date('31-12-2001','DD-MM-YYYY'))
                  and    currency_code = rec.currency_code)
     AND    amount is not null;

     -- Updating salescredit
     UPDATE ra_interface_salescredits salescred
     SET     sales_credit_amount_split = GL_CURRENCY_API.convert_amount( rec.currency_code,
                                                     p_func_curr_code,
                                                     sysdate,
                                                     'EMU FIXED',
                                                     salescred.sales_credit_amount_split )
     WHERE interface_line_id in (
                  select interface_line_id
                  from   ra_interface_lines_gt
                  where  request_id = p_request_id
                  and    trx_date > NVL(rec.end_date_active,
                                      to_date('31-12-2001','DD-MM-YYYY'))
                  and    currency_code = rec.currency_code)
     AND   sales_credit_amount_split is not null;


     -- Update credit memo headers
     UPDATE ra_interface_lines_gt l
     SET
            reference_line_id = NULL,
            reference_line_context = NULL,
            reference_line_attribute1 = NULL,
            reference_line_attribute2 = NULL,
            reference_line_attribute3 = NULL,
            reference_line_attribute4 = NULL,
            reference_line_attribute5 = NULL,
            reference_line_attribute6 = NULL,
            reference_line_attribute7 = NULL,
            reference_line_attribute8 = NULL,
            reference_line_attribute9 = NULL,
            reference_line_attribute10 = NULL,
            reference_line_attribute11 = NULL,
            reference_line_attribute12 = NULL,
            reference_line_attribute13 = NULL,
            reference_line_attribute14 = NULL,
            reference_line_attribute15 = NULL,
            previous_customer_trx_id = NULL
     WHERE  request_id = p_request_id
     AND    trx_date > NVL(rec.end_date_active,
                         to_date('31-12-2001','DD-MM-YYYY'))
     AND    currency_code = rec.currency_code
     AND    cust_trx_type_id in ( SELECT cust_trx_type_id
                                  FROM   ra_cust_trx_types
                                  WHERE  type = 'CM' ) ;

     -- Update invoice and CM headers

     /* 4448712 - Need to update tax lines with null trx_dates too */
     UPDATE ra_interface_lines_gt l
     SET    currency_code = p_func_curr_code,
            conversion_rate = 1,
            conversion_type = 'User',
            amount = GL_CURRENCY_API.convert_amount( l.currency_code,
                                                     p_func_curr_code,
                                                     l.trx_date,
                                                     'EMU FIXED',
                                                     l.amount ) ,
            unit_selling_price = GL_CURRENCY_API.convert_amount( l.currency_code,
                                                     p_func_curr_code,
                                                     l.trx_date,
                                                     'EMU FIXED',
                                                     l.unit_selling_price ) ,
            unit_standard_price = GL_CURRENCY_API.convert_amount( l.currency_code,
                                                     p_func_curr_code,
                                                     l.trx_date,
                                                     'EMU FIXED',
                                                     l.unit_standard_price )
     WHERE  request_id = p_request_id
     AND    currency_code = rec.currency_code
     AND   (trx_date > NVL(rec.end_date_active,
                         to_date('31-12-2001','DD-MM-YYYY'))
      OR EXISTS (
         SELECT 'child needs processing'
         FROM   ra_interface_lines PARENT
         WHERE  l.link_to_line_id = PARENT.interface_line_id
         AND    PARENT.trx_date > NVL(rec.end_date_active,
                                    to_date('31-12-2001', 'DD-MM-YYYY'))
         AND    PARENT.request_id = p_request_id
         )
     );

     END LOOP;


EXCEPTION
     WHEN GL_CURRENCY_API.NO_RATE THEN
       arp_file.write_log( p_text => 'Exception : No rates defined between these 2 currencies');
       arp_file.write_log( p_text => SQLERRM(SQLCODE) );
     WHEN OTHERS THEN
       arp_file.write_log( p_text => SQLERRM(SQLCODE) );
END ;

END ARP_EBS_AUTOINV_PREPROC ;

/
