--------------------------------------------------------
--  DDL for Package Body JG_ZZ_INVOICE_CREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_INVOICE_CREATE" AS
 /* $Header: jgzzricb.pls 115.3 2004/02/06 19:36:08 appradha ship $ */

/*------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  				    |
 *------------------------------------------------------------------*/

FUNCTION put_error_message (p_app_short_name    IN VARCHAR2
                           ,p_msg_name  IN VARCHAR2
                           ,p_header_id IN NUMBER
                           ,p_line_id IN NUMBER
                           ,p_invalid_value     IN VARCHAR2) RETURN BOOLEAN IS

message_text  VARCHAR2(2000);

BEGIN
  arp_standard.debug('-- Error for Interface Line Id: '|| to_char(p_line_id));

  fnd_message.set_name (p_app_short_name
                         ,p_msg_name);
  message_text := fnd_message.get;

  INSERT INTO ar_trx_errors_gt
            (trx_header_id,
             trx_line_id,
             error_message,
             invalid_value)
  VALUES     (p_header_id,
              p_line_id,
              message_text,
              p_invalid_value);

  IF SQL%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
  END IF;

  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug('-- Return From Exception when others in '||
                         'put_error_message');
      RETURN FALSE;

END put_error_message;


FUNCTION put_error_message (
           p_header_id IN NUMBER
          ,p_line_id IN NUMBER
          ,p_message_text      IN VARCHAR2
          ,p_invalid_value     IN VARCHAR2) RETURN BOOLEAN IS

BEGIN
  INSERT
    INTO ar_trx_errors_gt
        (trx_header_id
        ,trx_line_id
       , error_message
       , invalid_value)
  VALUES
        (p_header_id
       , p_line_id
       , p_message_text
       , p_invalid_value);

  RETURN TRUE;

  EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug('-- Cannot insert error messages '
                    || 'into ar_trx_errors_gt.');
    RETURN FALSE;
END;

--
--  FUNCTION
--     validate_gdff
--
--  DESCRIPTION
--
--  PARAMETERS
--    INPUT
--       p_request_id  Number -- Concurrent Request_id
--
--  RETURNS
--       0       Number -- Validation Fails, if there is any exceptional
--                         case which is handled in WHEN OTHERS
--       1       Number -- Validation Succeeds
--

  FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER IS

    l_return_code    NUMBER (1) := 1;
    l_product_code   VARCHAR2(2);

  BEGIN
    arp_standard.debug('jg_zz_invoice_create.validate_gdff()+');

    l_product_code := FND_PROFILE.VALUE('JGZZ_PRODUCT_CODE');

    IF l_product_code IS NULL THEN
       arp_standard.debug('Product Profile is Empty');
    ELSIF  l_product_code = 'JL' THEN
      l_return_code := jl_zz_invoice_create.validate_gdf_inv_api(p_request_id);
    ELSIF l_product_code = 'JA' THEN
      l_return_code := ja_zz_invoice_create.validate_gdff(p_request_id);
    ELSIF l_product_code = 'JE' THEN
      l_return_code := je_zz_invoice_create.validate_gdff(p_request_id);
    END IF;

    arp_standard.debug('jg_zz_auto_invoice.validate_gdff()-');

    RETURN l_return_code;

  EXCEPTION
    WHEN OTHERS THEN

      arp_standard.debug('-- Return From Exception when others');
      arp_standard.debug('-- Return Code: 0');
      arp_standard.debug('jg_zz_auto_invoice.validate_gdff()-');

      RETURN 0;

  END validate_gdff;

END jg_zz_invoice_create;

/
