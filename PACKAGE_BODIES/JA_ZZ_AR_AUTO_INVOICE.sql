--------------------------------------------------------
--  DDL for Package Body JA_ZZ_AR_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_ZZ_AR_AUTO_INVOICE" AS
/* $Header: jazzraib.pls 120.2 2005/10/30 01:48:12 appldev ship $ */
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
  FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER IS

    l_request_id     NUMBER;
    l_return_code    NUMBER(1);
    l_country_code   VARCHAR2(2);

  BEGIN

    l_request_id := p_request_id;
    ------------------------------------------------------------
    -- Let's assume everything is OK                          --
    ------------------------------------------------------------
    l_return_code := 1;

    l_country_code := fnd_profile.value ('JGZZ_COUNTRY_CODE');

    IF l_country_code = 'TW' THEN
      l_return_code := ja_tw_ar_auto_invoice.validate_gdff(
                                              l_request_id);
    ELSIF l_country_code = 'TH' THEN
      l_return_code := ja_th_ar_auto_invoice.validate_tax_invoice(
                                              l_request_id);
    END IF;

    arp_standard.debug('Return value from ja_zz_ar_atuo_invoice.'
                     ||'validate_gdff() = '||TO_CHAR(l_return_code));

    RETURN l_return_code;

  EXCEPTION
    WHEN OTHERS THEN

      arp_standard.debug('-- Return From Exception when others');
      arp_standard.debug('-- Return Code: 0');
      arp_standard.debug('ja_zz_ar_auto_invoice.validate_gdff()-');

      RETURN 0;

  END validate_gdff;

-------------------------------------------------------------------------------
-- FUNCTION                                                                  --
--    trx_num_upd                                                            --
--                                                                           --
-- PARAMETERS                                                                --
--   INPUT                                                                   --
--      p_batch_source_id    Number       -- Transaction Source ID           --
--      p_trx_number         VARCHAR2(20) -- Original Transaction Number     --
--                                                                           --
-- RETURNS                                                                   --
--      l_trx_number         VARCHAR2(20) -- New Transaction Number          --
--                                                                           --
-------------------------------------------------------------------------------
  FUNCTION trx_num_upd(p_batch_source_id IN NUMBER
                      ,p_trx_number      IN VARCHAR2) RETURN VARCHAR2 IS

    l_batch_source_id  NUMBER(15);
    l_trx_number       VARCHAR2(20);
    l_country_code     VARCHAR2(2);

  BEGIN

    l_batch_source_id  :=  p_batch_source_id;
    l_trx_number       :=  p_trx_number;

    l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');

    IF l_country_code = 'TW' THEN
       l_trx_number := ja_tw_ar_auto_invoice.trx_num_upd(
                                              l_batch_source_id
                                            , l_trx_number);
    --
    --ELSIF l_country_code = 'TH' THEN
    --
    END IF;

    RETURN l_trx_number;

  EXCEPTION
  WHEN OTHERS THEN
      RAISE;
  END trx_num_upd;

END ja_zz_ar_auto_invoice;

/
