--------------------------------------------------------
--  DDL for Package Body JL_ZZ_INVOICE_CREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_INVOICE_CREATE" as
/* $Header: jlzzricb.pls 120.7 2007/10/24 10:29:39 hbalijep ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    validate_gdf_inv_api                                                    |
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
--  PG_DEBUG varchar2(1) :=  NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
-- Bugfix# 3259701
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

t_interface_line_tbl R_interface_line;
l_org_id NUMBER;

  ------------------------------------------------------------
  ----- Tax validation function.
  ----------------------------------------------------------

FUNCTION validate_gdf_inv_api (p_request_id  IN NUMBER) RETURN NUMBER IS

    return_code    NUMBER (1);
    l_tax_method   VARCHAR2(30);
    l_country_code VARCHAR2(2);
    l_index binary_integer;


    CURSOR trx_lines_cursor (c_request_id NUMBER) IS
      SELECT ar_trx_lines_gt.trx_line_id
           , ar_trx_header_gt.cust_trx_type_id  trx_type
           , ar_trx_header_gt.trx_date
           , nvl(ship_to_address_id , bill_to_address_id)
                         ship_to_address_id
           , ar_trx_lines_gt.line_type
           , ar_trx_lines_gt.memo_line_id
           , ar_trx_lines_gt.inventory_item_id
           , ar_trx_header_gt.global_attribute1
           , ar_trx_header_gt.global_attribute2
           , ar_trx_header_gt.global_attribute3
           , ar_trx_header_gt.global_attribute4
           , ar_trx_header_gt.global_attribute5
           , ar_trx_header_gt.global_attribute6
           , ar_trx_header_gt.global_attribute7
           , ar_trx_header_gt.global_attribute8
           , ar_trx_header_gt.global_attribute9
           , ar_trx_header_gt.global_attribute10
           , ar_trx_header_gt.global_attribute11
           , ar_trx_header_gt.global_attribute12
           , ar_trx_header_gt.global_attribute13
           , ar_trx_header_gt.global_attribute14
           , ar_trx_header_gt.global_attribute15
           , ar_trx_header_gt.global_attribute16
           , ar_trx_header_gt.global_attribute17
           , ar_trx_lines_gt.global_attribute1
           , ar_trx_lines_gt.global_attribute4
           , ar_trx_lines_gt.global_attribute5
           , ar_trx_lines_gt.global_attribute6
           , ar_trx_lines_gt.global_attribute7
           , ar_trx_lines_gt.global_attribute8
           , ar_trx_lines_gt.global_attribute9
           , ar_trx_lines_gt.global_attribute10
           , ar_trx_lines_gt.global_attribute11
           , ar_trx_lines_gt.global_attribute12
           , warehouse_id
           , rbs.name
           , ar_trx_header_gt.trx_number
        FROM ar_trx_lines_gt,ar_trx_header_gt,ra_batch_sources_all rbs
        WHERE ar_trx_lines_gt.request_id = c_request_id
        AND   ar_trx_header_gt.trx_header_id = ar_trx_lines_gt.trx_header_id
        AND   ar_trx_header_gt.batch_source_id = rbs.batch_source_id
        ORDER BY ar_trx_header_gt.trx_date;

  ------------------------------------------------------------
  -- Main function body.                                    --
  ------------------------------------------------------------
  BEGIN

    ------------------------------------------------------------
    -- Let's assume everything is OK                          --
    ------------------------------------------------------------
    --arp_standard.debug('JL_ZZ_INVOICE_CREATE.validate_gdff()+');
    IF PG_DEBUG = 'Y' THEN
    	arp_util_tax.debug('JL_ZZ_INVOICE_CREATE.validate_gdff()+');
    END IF;

    return_code := 1;
    --bug 5562805
    --l_country_code := fnd_profile.value ('JGZZ_COUNTRY_CODE');
    l_org_id := MO_GLOBAL.get_current_org_id;
    l_country_code := JG_ZZ_SHARED_PKG.get_country(l_org_id,null,null);


    --arp_standard.debug('-- Country Code: '||l_country_code);
    --arp_standard.debug('-- Request Id: '||to_char(p_request_id));
    IF PG_DEBUG = 'Y' THEN
    	arp_util_tax.debug('validate_gdff: ' || '-- Country Code: '||l_country_code);
    	arp_util_tax.debug('validate_gdff: ' || '-- Request Id: '||to_char(p_request_id));
    END IF;

    ------------------------------------------------------------
    -- Validate all the rows for this concurrent request      --
    ------------------------------------------------------------
    Open trx_lines_cursor(p_request_id);
    --Bug 6486460
    --LOOP

      Fetch trx_lines_cursor BULK COLLECT INTO
      t_interface_line_tbl.interface_line_id,
      t_interface_line_tbl.cust_trx_type_id,
      t_interface_line_tbl.trx_date,
      t_interface_line_tbl.orig_system_address_id,
      t_interface_line_tbl.line_type,
      t_interface_line_tbl.memo_line_id,
      t_interface_line_tbl.inventory_item_id,
      t_interface_line_tbl.header_gdf_attribute1,
      t_interface_line_tbl.header_gdf_attribute2,
      t_interface_line_tbl.header_gdf_attribute3,
      t_interface_line_tbl.header_gdf_attribute4,
      t_interface_line_tbl.header_gdf_attribute5,
      t_interface_line_tbl.header_gdf_attribute6,
      t_interface_line_tbl.header_gdf_attribute7,
      t_interface_line_tbl.header_gdf_attribute8,
      t_interface_line_tbl.header_gdf_attribute9,
      t_interface_line_tbl.header_gdf_attribute10,
      t_interface_line_tbl.header_gdf_attribute11,
      t_interface_line_tbl.header_gdf_attribute12,
      t_interface_line_tbl.header_gdf_attribute13,
      t_interface_line_tbl.header_gdf_attribute14,
      t_interface_line_tbl.header_gdf_attribute15,
      t_interface_line_tbl.header_gdf_attribute16,
      t_interface_line_tbl.header_gdf_attribute17,
      t_interface_line_tbl.line_gdf_attribute1,
      t_interface_line_tbl.line_gdf_attribute4,
      t_interface_line_tbl.line_gdf_attribute5,
      t_interface_line_tbl.line_gdf_attribute6,
      t_interface_line_tbl.line_gdf_attribute7,
      t_interface_line_tbl.line_gdf_attribute8,
      t_interface_line_tbl.line_gdf_attribute9,
      t_interface_line_tbl.line_gdf_attribute10,
      t_interface_line_tbl.line_gdf_attribute11,
      t_interface_line_tbl.line_gdf_attribute12,
      t_interface_line_tbl.warehouse_id,
      t_interface_line_tbl.batch_source_name,
      t_interface_line_tbl.trx_number
      ;

    --END LOOP;
    CLOSE trx_lines_cursor;


    FOR l_index IN 1..t_interface_line_tbl.warehouse_id.LAST
    LOOP

      IF l_country_code IN ('BR','AR','CO') THEN

         l_org_id := mo_global.get_current_org_id;

         l_tax_method := JL_ZZ_AR_TX_LIB_PKG.get_tax_method(l_org_id);

         --arp_standard.debug('-- Tax Method: '||l_tax_method);
         IF PG_DEBUG = 'Y' THEN
         	arp_util_tax.debug('validate_gdff: ' || '-- Tax Method: '||l_tax_method);
         END IF;

         IF l_tax_method = 'LTE' THEN
            IF NOT JL_ZZ_AUTO_INVOICE.validate_tax_attributes (t_interface_line_tbl.interface_line_id(l_index)
                                   , t_interface_line_tbl.line_type(l_index)
                                   , t_interface_line_tbl.memo_line_id(l_index)
                                   , t_interface_line_tbl.inventory_item_id(l_index)
                                   , t_interface_line_tbl.line_gdf_attribute2(l_index)
                                   , t_interface_line_tbl.line_gdf_attribute3(l_index)
                                   , NULL
                                   , t_interface_line_tbl.line_gdf_attribute11(l_index)
                                   , t_interface_line_tbl.line_gdf_attribute12(l_index)
                                   , t_interface_line_tbl.orig_system_address_id(l_index)
                                   , t_interface_line_tbl.warehouse_id(l_index)) THEN

               --arp_standard.debug('-- validate_tax_attributes routine failed');
               IF PG_DEBUG = 'Y' THEN
               	arp_util_tax.debug('validate_gdff: ' || '-- validate_tax_attributes routine failed');
               END IF;
               return_code := 0;
            END IF; -- Validate tax
         END IF; -- l_tax_method check
      END IF; -- Tax method check

      IF l_country_code = 'BR' THEN
         IF NOT JL_ZZ_AUTO_INVOICE.validate_interest_attributes
                                  (  t_interface_line_tbl.interface_line_id(l_index)
                                   , t_interface_line_tbl.line_type(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute1(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute2(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute3(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute4(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute5(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute6(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute7(l_index)) THEN

           --arp_standard.debug('-- validate_interest_attributes routine failed');
           IF PG_DEBUG = 'Y' THEN
           	arp_util_tax.debug('validate_gdff: ' || '-- validate_interest_attributes routine failed');
           END IF;

           return_code := 0;
         END IF;  -- Validate interest

         IF NOT JL_ZZ_AUTO_INVOICE.validate_billing_attributes (t_interface_line_tbl.interface_line_id(l_index)
                                   , t_interface_line_tbl.line_type(l_index)
                                   , t_interface_line_tbl.memo_line_id(l_index)
                                   , t_interface_line_tbl.inventory_item_id(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute9(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute10(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute11(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute13(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute15(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute16(l_index)
                                   , t_interface_line_tbl.header_gdf_attribute17(l_index)
                                   , t_interface_line_tbl.line_gdf_attribute1(l_index)
                                   , t_interface_line_tbl.line_gdf_attribute4(l_index)
                                   , t_interface_line_tbl.line_gdf_attribute5(l_index)
                                   , t_interface_line_tbl.line_gdf_attribute6(l_index)
                                   , t_interface_line_tbl.line_gdf_attribute7(l_index)) THEN

            --arp_standard.debug('-- validate_billing_attributes routine failed');
            IF PG_DEBUG = 'Y' THEN
            	arp_util_tax.debug('validate_gdff: ' || '-- validate_billing_attributes routine failed');
            END IF;

            return_code := 0;
         END IF; -- Validate billing

      ELSIF l_country_code = 'AR' THEN
         ------------------------------------------------------------
         -- Validate all the rows for this concurrent request      --
         ------------------------------------------------------------
         IF NOT JL_AR_DOC_NUMBERING_PKG.validate_interface_lines
                                  (  p_request_id
                                   , t_interface_line_tbl.interface_line_id(l_index)
                                   , t_interface_line_tbl.cust_trx_type_id(l_index)
                                   , t_interface_line_tbl.inventory_item_id(l_index)
                                   , t_interface_line_tbl.memo_line_id(l_index)
                                   , t_interface_line_tbl.trx_date(l_index)
                                   , t_interface_line_tbl.orig_system_address_id(l_index)
                                   , t_interface_line_tbl.warehouse_id(l_index)
                                   ) THEN

            --arp_standard.debug('-- JL_AR_DOC_NUMBERING_PKG.'||'validate_interface_lines routine failed');
            IF PG_DEBUG = 'Y' THEN
            	arp_util_tax.debug('validate_gdff: ' || '-- JL_AR_DOC_NUMBERING_PKG.'||'validate_interface_lines routine failed');
            END IF;

            return_code := 0;
         END IF;  -- Validate interface lines
      END IF;

    END LOOP;

    --arp_standard.debug('-- Return Code: '||to_char(return_code));
    --arp_standard.debug('JL_ZZ_INVOICE_CREATE.validate_gdff()-');
    IF PG_DEBUG = 'Y' THEN
    	arp_util_tax.debug('validate_gdff: ' || '-- Return Code: '||to_char(return_code));
    	arp_util_tax.debug('JL_ZZ_INVOICE_CREATE.validate_gdff()-');
    END IF;

    RETURN return_code;

  EXCEPTION
    WHEN OTHERS THEN

      --arp_standard.debug('-- Return From Exception when others');
      --arp_standard.debug('-- Return Code: 0');
      --arp_standard.debug('JL_ZZ_INVOICE_CREATE.validate_gdff()-');
      IF PG_DEBUG = 'Y' THEN
      	arp_util_tax.debug('validate_gdff: ' || '-- Return From Exception when others');
      	arp_util_tax.debug('validate_gdff: ' || '-- Return Code: 0');
      	arp_util_tax.debug('JL_ZZ_INVOICE_CREATE.validate_gdff()-');
      END IF;

      RETURN 0;

  END validate_gdf_inv_api;

END JL_ZZ_INVOICE_CREATE;

/
