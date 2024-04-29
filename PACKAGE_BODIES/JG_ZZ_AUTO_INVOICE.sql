--------------------------------------------------------
--  DDL for Package Body JG_ZZ_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_AUTO_INVOICE" AS
/* $Header: jgzzraib.pls 120.5.12010000.3 2009/08/13 14:36:36 rsaini ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

FUNCTION put_error_message (p_app_short_name    IN VARCHAR2
                           ,p_mssg_name         IN VARCHAR2
                           ,p_interface_line_id IN VARCHAR2
                           ,p_invalid_value     IN VARCHAR2) RETURN BOOLEAN IS

message_text  VARCHAR2(2000);
l_org_id      NUMBER;

BEGIN
  arp_standard.debug('-- Error for Interface Line Id: '|| p_interface_line_id);

  fnd_message.set_name (p_app_short_name
                         ,p_mssg_name);
  message_text := fnd_message.get;
  l_org_id := MO_GLOBAL.get_current_org_id;

  INSERT INTO ra_interface_errors
             (interface_line_id,
              message_text,
              org_id,
              invalid_value)
  VALUES     (p_interface_line_id,
              message_text,
              l_org_id,
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
           p_interface_line_id IN NUMBER
          ,p_message_text      IN VARCHAR2
          ,p_invalid_value     IN VARCHAR2) RETURN BOOLEAN IS

  l_interface_line_id NUMBER(15)    ;
  l_message_text      VARCHAR2(240) ;
  l_invalid_value     VARCHAR2(240) ;
  l_org_id            NUMBER;
BEGIN

  l_interface_line_id := p_interface_line_id;
  l_message_text      := p_message_text;
  l_invalid_value     := p_invalid_value;

  l_org_id := MO_GLOBAL.get_current_org_id;
  INSERT
    INTO ra_interface_errors
        (interface_line_id
       , message_text
       , org_id
       , invalid_value)
  VALUES
        (l_interface_line_id
       , l_message_text
       , l_org_id
       , l_invalid_value);

  RETURN TRUE;

  EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug('-- Cannot insert error messages '
                    || 'into ra_interface_errors.');
    RETURN FALSE;
END;

FUNCTION put_error_message1 (p_app_short_name     IN VARCHAR2
                            ,p_mssg_name          IN VARCHAR2
                            ,p_interface_line_ref IN VARCHAR2
                            ,p_invalid_value      IN VARCHAR2) RETURN BOOLEAN IS

 	 message_text  VARCHAR2(2000);
         l_org_id NUMBER;


BEGIN
   arp_standard.debug('-- Error for Interface Line Id: '|| p_interface_line_ref);

   fnd_message.set_name (p_app_short_name
 	                          ,p_mssg_name);
   message_text := fnd_message.get;
   l_org_id := MO_GLOBAL.get_current_org_id;

   INSERT INTO jl_autoinv_int_lines
 	              (interface_line_ref,
 	               message_text,
 	               invalid_value,
                       org_id)
 	   VALUES     (p_interface_line_ref,
 	               message_text,
 	               p_invalid_value,
                       l_org_id);

 	   IF SQL%NOTFOUND THEN
 	        RAISE NO_DATA_FOUND;
 	   END IF;

 	   RETURN TRUE;

 	   EXCEPTION
 	     WHEN OTHERS THEN
 	       arp_standard.debug('-- Return From Exception when others in '||
 	                          'put_error_message');
 	       RETURN FALSE;

END put_error_message1;

/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    validate_gdff                                                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |      p_request_id            Number   -- Concurrent Request_id             |
 |                                                                            |
 | RETURNS                                                                    |
 |      0                       Number   -- Validation Fails, if there is any |
 |                                          exceptional case which is handled |
 |                                          in WHEN OTHERS                    |
 |      1                       Number   -- Validation Succeeds               |
 |                                                                            |
 *----------------------------------------------------------------------------*/
  FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER IS

    l_return_code    NUMBER (1);
    l_product_code   VARCHAR2(2);

  ------------------------------------------------------------
  -- Main function body.                                    --
  ------------------------------------------------------------
  BEGIN
    arp_standard.debug('jg_zz_auto_invoice.validate_gdff()+');
    ------------------------------------------------------------
    -- Let's assume everything is OK                          --
    ------------------------------------------------------------
    l_return_code := 1;

    l_product_code := FND_PROFILE.VALUE('JGZZ_PRODUCT_CODE');

    IF l_product_code IS NULL THEN
       NULL;
    ELSIF  l_product_code = 'JL' THEN
      l_return_code := jl_zz_auto_invoice.validate_gdff(
                                          p_request_id);
    ELSIF l_product_code = 'JA' THEN
      l_return_code := ja_zz_ar_auto_invoice.validate_gdff(
                                             p_request_id);
 /* commented for June 24 th release bug by shijain, uncomment later
    ELSIF l_product_code = 'JE' THEN
      l_return_code := je_zz_auto_invoice.validate_gdff(
                                             p_request_id);
*/
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

END jg_zz_auto_invoice;

/
