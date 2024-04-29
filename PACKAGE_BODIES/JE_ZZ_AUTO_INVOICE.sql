--------------------------------------------------------
--  DDL for Package Body JE_ZZ_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_ZZ_AUTO_INVOICE" as
/* $Header: jezzraib.pls 120.3.12010000.2 2008/08/04 12:28:02 vgadde ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

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
 |  Although this package was really meant for validation we can 'bend' its   |
 |  use to insert the HU data we want and pass back to the JG package         |
 |  indicating that everything passes validation.                             |
 *----------------------------------------------------------------------------*/
  PG_DEBUG varchar2(1);

FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER IS

    return_code    NUMBER (1);
    l_country_code VARCHAR2(2);


  ------------------------------------------------------------
  -- Main function body.                                    --
  ------------------------------------------------------------
  BEGIN

  PG_DEBUG  := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

    IF PG_DEBUG in ('Y', 'C') THEN
    	arp_standard.debug('JE_ZZ_AUTO_INVOICE.validate_gdff()+');
    END IF;

    return_code := 1;
    l_country_code := fnd_profile.value ('JGZZ_COUNTRY_CODE');

    IF PG_DEBUG in ('Y', 'C') THEN
    	arp_standard.debug('validate_gdff: ' || '-- Country Code: '||l_country_code);
    	arp_standard.debug('validate_gdff: ' || '-- Request Id: '||to_char(p_request_id));
    END IF;

    ------------------------------------------------------------
    -- Check for HU country code, if present then we want to  --
    -- enter the context and attribute1 data                  --
    ------------------------------------------------------------

      IF l_country_code =  'HU' THEN


         IF PG_DEBUG in ('Y', 'C') THEN
         	arp_standard.debug('validate_gdff: ' || '-- Inserting HU specific GDF data');
         END IF;

	 update ra_interface_lines_gt
	 set HEADER_GDF_ATTR_CATEGORY = 'JE.HU.ARXTWMAI.TAX_DATE'
	 ,   HEADER_GDF_ATTRIBUTE1    = fnd_date.date_to_canonical(GL_DATE)
	 where request_id = p_request_id ;


    ------------------------------------------------------------
    -- Check for PL country code, if present then we want to  --
    -- enter the context and attribute1 data                  --
    ------------------------------------------------------------

     ELSIF  l_country_code =  'PL' THEN


         IF PG_DEBUG in ('Y', 'C') THEN
         	arp_standard.debug('validate_gdff: ' || '-- Inserting PL specific GDF data');
         END IF;

         update ra_interface_lines_gt
         set HEADER_GDF_ATTR_CATEGORY = 'JE.PL.ARXTWMAI.TAX_DATE'
         ,   HEADER_GDF_ATTRIBUTE1    = fnd_date.date_to_canonical(GL_DATE)
         where request_id = p_request_id ;

    ------------------------------------------------------------
    -- Check for CZ country code, if present then we want to  --
    -- enter the context and attribute1 data                  --
    -- Czech requirements are that the tax date should be:    --
    -- Tax Date : = Booking date of Sales Order if item is    --
    -- not shippable or the oldest Ship Confirm date from all --
    -- item lines if item is ship. These are the rules        --
    -- Autoinvoice uses to derive the GL date so we can just  --
    -- use that as the tax date                               --
    ------------------------------------------------------------



     ELSIF  l_country_code =  'CZ' THEN

         IF PG_DEBUG in ('Y', 'C') THEN
         	arp_standard.debug('validate_gdff: ' || '-- Inserting CZ specific GDF data');
         END IF;

         update ra_interface_lines_gt
         set HEADER_GDF_ATTR_CATEGORY = 'JE.CZ.ARXTWMAI.TAX_DATE'
         ,   HEADER_GDF_ATTRIBUTE1    = fnd_date.date_to_canonical(GL_DATE)
         where request_id = p_request_id ;



     END IF;


    RETURN return_code;

  EXCEPTION
    WHEN OTHERS THEN

      IF PG_DEBUG in ('Y', 'C') THEN
      	arp_standard.debug('validate_gdff: ' || '-- Return From Exception when others');
      	arp_standard.debug('validate_gdff: ' || '-- Return Code: 0');
      	arp_standard.debug('JE_ZZ_AUTO_INVOICE.validate_gdff()-');
      END IF;

      RETURN 0;

  END validate_gdff;


END JE_ZZ_AUTO_INVOICE;

/
