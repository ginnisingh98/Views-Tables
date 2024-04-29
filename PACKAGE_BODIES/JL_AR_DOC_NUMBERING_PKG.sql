--------------------------------------------------------
--  DDL for Package Body JL_AR_DOC_NUMBERING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_DOC_NUMBERING_PKG" as
/* $Header: jlarrdnb.pls 120.14.12010000.4 2009/09/15 14:23:15 mbarrett ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

PG_DEBUG varchar2(1);

FUNCTION validate_trx_type (p_batch_source_id IN NUMBER,
                            p_trx_type IN NUMBER,
                            p_invoice_class IN VARCHAR2,
                            p_document_letter IN VARCHAR2,
                            p_interface_line_id IN NUMBER,
                            p_created_from IN VARCHAR2) RETURN VARCHAR2 IS

l_dummy_code     VARCHAR2(15);
error_condition  EXCEPTION;
l_return_code	 VARCHAR2(30);
l_document_letter VARCHAR2(1);
l_count          NUMBER;
l_branch_number  VARCHAR2(4);
l_org_id         NUMBER;

BEGIN
   l_return_code := 'SUCCESS';
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('validate_trx_type: ' || '-- validate trx type ');
   END IF;
   -- Bug 8825457 Start
   l_org_id := MO_GLOBAL.get_current_org_id;
   -- Bug 8825457 End
   BEGIN
     SELECT 'Success'
     INTO   l_dummy_code
     FROM   jg_zz_ar_src_trx_ty st, ra_batch_sources_all src
     WHERE  st.cust_trx_type_id = p_trx_type
     AND    st.batch_source_id = p_batch_source_id
     AND    invoice_class = p_invoice_class
     AND    st.batch_source_id = src.batch_source_id
     AND    src.global_attribute3 = p_document_letter
     AND    st.enable_flag = 'Y'
     -- Bug 8825457 Start
     AND src.org_id = l_org_id;
     -- Bug 8825457 End
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('validate_trx_type: ' || '-- First validate trx type check');
   END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          IF p_created_from = 'RAXTRX' THEN
  	     l_return_code := 'ERROR';
             IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
	                               'JL_AR_AR_INVALID_TRANS_TYPE',
                                       'p_interface_line_id',
                                       'p_trx_type') THEN
                RAISE  error_condition;
             END IF;
	  ELSIF p_created_from = 'ARXTWMAI' THEN
	     l_return_code := 'JL_AR_AR_TRXTYP_BTSRC_NOT_ASSO';
             RAISE error_condition;
 	  END IF;
    WHEN TOO_MANY_ROWS THEN
          IF p_created_from = 'RAXTRX' THEN
  	     l_return_code := 'ERROR';
             IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
	                               'JL_AR_AR_BT_SRC_MORE_FOUND',
                                       'p_interface_line_id',
                                       'p_trx_type') THEN
                RAISE  error_condition;
             END IF;
	  ELSIF p_created_from = 'ARXTWMAI' THEN
	     l_return_code := 'JL_AR_AR_BT_SRC_MORE_FOUND';
             RAISE error_condition;
 	  END IF;
   END;
   BEGIN
     --
     SELECT substr(global_attribute2,1,4)
     INTO   l_branch_number
     FROM   ra_batch_sources a
     WHERE  a.batch_source_id = p_batch_source_id;
     --
     SELECT count(*)
     INTO   l_count
     FROM   jg_zz_ar_src_trx_ty ty, ra_batch_sources_all src
     WHERE  ty.cust_trx_type_id = p_trx_type
     AND    ty.batch_source_id = src.batch_source_id
     AND    substr(src.global_attribute3,1,1) <> p_document_letter
     AND    substr(src.global_attribute2,1,4) <> l_branch_number
     AND    ty.enable_flag = 'Y';
     --
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('validate_trx_type: ' || '-- Second validate trx type check');
     END IF;
     IF l_count > 0 THEN
       IF p_created_from = 'RAXTRX' THEN
         l_return_code := 'ERROR';
         IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                               'JL_AR_AR_BT_SRC_MORE_FOUND',
                               'p_interface_line_id',
                               'p_trx_type') THEN
           RAISE  error_condition;
         END IF;
       ELSIF p_created_from = 'ARXTWMAI' THEN
         l_return_code := 'JL_AR_AR_BT_SRC_MORE_FOUND';
         RAISE error_condition;
       END IF;
     END IF;
   END;
   RETURN  l_return_code;
EXCEPTION
  WHEN OTHERS THEN
       IF l_return_code is null then
	  IF p_created_from = 'ARXTWMAI' THEN
	     l_return_code := 'JL_AR_AR_TRXTYP_BTSRC_NOT_ASSO';
             RAISE error_condition;
          ELSE
	     l_return_code := 'JL_AR_AR_INVALID_TRANS_TYPE';
             IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
	                               'JL_AR_AR_INVALID_TRANS_TYPE',
                                       'p_interface_line_id',
                                       'p_trx_type') THEN
                RAISE  error_condition;
             END IF;
          END IF;
       END IF;
       RETURN l_return_code;
END validate_trx_type;

FUNCTION validate_four_digit (p_batch_source_id   IN NUMBER,
                              p_interface_line_id IN NUMBER,
                              p_created_from      IN VARCHAR2,
                              p_inventory_item_id IN NUMBER,
                              p_memo_line_id      IN NUMBER,
                              p_so_org_id         IN VARCHAR2) RETURN VARCHAR2
IS

l_dummy_code           VARCHAR2(15);
error_condition        EXCEPTION;
l_return_code	       VARCHAR2(30);
l_so_org_id            NUMBER(15);
l_four_digit_code      VARCHAR2(20);
l_point_of_sale_code   VARCHAR2(4);
l_product_line_code    VARCHAR2(4);
l_loc_id               NUMBER(15);
l_org_id               NUMBER;

BEGIN
  l_return_code := 'SUCCESS';

  --Bug 1404824 removed check to see if p_so_org_id is not null since it will
  --be mandatory.
  --Commented following line for bug 1612359
--  l_so_org_id := to_number(p_so_org_id);
    l_org_id := mo_global.get_current_org_id;
    l_so_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID',l_org_id);

  BEGIN
    SELECT global_attribute1
    INTO   l_four_digit_code
    FROM   ar_system_parameters;
  END;

  --Bug 1612359 - removed branch number validation for point of sale

  IF l_four_digit_code = 'PRODUCT_LINE' THEN
     l_product_line_code := NULL;
     IF p_inventory_item_id IS NOT NULL THEN
        BEGIN
          SELECT substr(global_attribute10,1,4)
          INTO   l_product_line_code
          FROM   mtl_system_items
          WHERE  inventory_item_id = p_inventory_item_id
          AND    organization_id = l_so_org_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
	       IF p_created_from = 'RAXTRX' THEN
                  l_return_code := 'ERROR';
                  IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                                            'JL_AR_AR_INVALID_ITEM_CODE',
                                            p_interface_line_id,
                                            p_inventory_item_id)  THEN
                     RAISE error_condition;
                  END IF;
               ELSIF p_created_from = 'ARXTWMAI' THEN
                  l_return_code := 'JL_AR_AR_INVALID_ITEM_CODE';
                  RAISE error_condition;
               END IF;
        END;
     ELSE
        IF p_memo_line_id IS NOT NULL THEN
           BEGIN
             SELECT substr(global_attribute7,1,4)
             INTO   l_product_line_code
             FROM   ar_memo_lines
             WHERE  memo_line_id = p_memo_line_id;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
	          IF p_created_from = 'RAXTRX' THEN
                     l_return_code := 'ERROR';
                     IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                                               'JL_AR_AR_INVALID_MEMO_LINE',
                                               p_interface_line_id,
                                               p_memo_line_id) THEN
                        RAISE error_condition;
                     END IF;
                  ELSIF p_created_from = 'ARXTWMAI' THEN
                     l_return_code := 'JL_AR_AR_INVALID_MEMO_LINE';
                     RAISE  error_condition;
                  END IF;
           END;
        END IF;
     END IF;
     BEGIN
        SELECT 'Success'
        INTO   l_dummy_code
        FROM   ra_batch_sources
        WHERE  substr(global_attribute2,1,4) = l_product_line_code
        AND    batch_source_id = p_batch_source_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
               IF p_created_from = 'RAXTRX' THEN
                  l_return_code := 'ERROR';
                  IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                                           'JL_AR_AR_INV_PROD_LINE_CODE',
                                            p_interface_line_id,
                                            l_product_line_code) THEN
                     RAISE error_condition;
                  END IF;
               ELSIF p_created_from = 'ARXTWMAI' THEN
                  l_return_code := 'JL_AR_AR_INV_PROD_LINE_CODE';
                  RAISE error_condition;
               END IF;
     END;
  END IF;
  RETURN l_return_code;
EXCEPTION
  WHEN OTHERS THEN
       IF l_return_code is null then
          IF p_created_from = 'RAXTRX' THEN
             l_return_code := 'JL_AR_AR_AI_BR_NUM_NOT_DEF';
             IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                                      'JL_AR_AR_AI_BR_NUM_NOT_DEF',
                                       p_interface_line_id,
                                       p_batch_source_id) THEN
                     RAISE error_condition;
             END IF;
          ELSIF p_created_from = 'ARXTWMAI' THEN
             l_return_code := 'JL_AR_AR_BRANCH_NUM_NOT_DEF';
          END IF;
       END IF;
       RETURN l_return_code;
END validate_four_digit;

FUNCTION get_num_bar_code (p_batch_source_id IN NUMBER, p_trx_type_id IN NUMBER,p_legal_entity_id IN NUMBER) RETURN VARCHAR2 IS
  l_comp_cuit VARCHAR2(15);
  l_dgi_code VARCHAR2(4);
  l_branch_num VARCHAR2(4);
  l_cai_num VARCHAR2(30);
  l_cai_date VARCHAR2(12);
  l_inv_org_id NUMBER;
  l_doc_letter VARCHAR2(2);
  l_num_bar_code VARCHAR2(100);
  l_valid_digit VARCHAR2(2);
  l_odd_temp NUMBER;
  l_even_temp NUMBER;
  l_temp NUMBER;
  l_leng NUMBER;
  l_count NUMBER;
BEGIN

  --oe_profile.get('MASTER_ORGANIZATION_ID',l_org_id);
-- Fetching the company Cuit from hr locations
  BEGIN
    SELECT registration_number
    INTO   l_comp_cuit
    FROM   xle_firstparty_information_v
    WHERE  legal_entity_id = p_legal_entity_id;
  EXCEPTION
    WHEN OTHERS THEN
         l_comp_cuit  := NULL;
  END;

-- Fetching the document letter,branch number, cai number, cai date
  BEGIN
     SELECT substr(global_attribute3,1,1),substr(global_attribute2,1,4)
     ,global_attribute8, to_char(fnd_date.canonical_to_date(global_attribute9),'YYYY/MM/DD')
     INTO   l_doc_letter, l_branch_num, l_cai_num, l_cai_date
     FROM   ra_batch_sources
     WHERE  batch_source_id = p_batch_source_id;

     SELECT REPLACE(l_cai_date,'/') INTO l_cai_date from dual;

     SELECT REPLACE(l_comp_cuit,'-') INTO l_comp_cuit from dual;

  EXCEPTION
    WHEN OTHERS THEN
         l_branch_num  := NULL;
  END;

  BEGIN

-- Fetching the dgi code
    SELECT lpad(substr(dgi_code,1,2),2,'0')
    INTO   l_dgi_code
    FROM   jl_ar_ap_trx_dgi_codes dgi,
           ra_cust_trx_types rctt
    WHERE  trx_letter = l_doc_letter
    AND    rctt.cust_trx_type_id = p_trx_type_id
    AND    trx_category = (select type from ra_cust_trx_types where
                           cust_trx_type_id = p_trx_type_id);
  EXCEPTION
    WHEN OTHERS THEN
         l_doc_letter := NULL;
         l_dgi_code  := NULL;
  END;

-- IF any of the components of the bar code is null then the entire bar code is
-- null

  IF l_comp_cuit is NULL or l_dgi_code is NULL or l_branch_num is NULL or l_cai_num is NULL or l_cai_date is NULL THEN
      RETURN NULL;
    END IF;

    l_num_bar_code := l_comp_cuit||l_dgi_code||l_branch_num||l_cai_num||l_cai_date;

    Select length(l_num_bar_code) into l_leng from dual;

    l_count := 1;
    l_odd_temp := 0;

-- Sum up the digits at the odd positions
    Loop

      l_odd_temp := l_odd_temp + to_number(substr(l_num_bar_code,l_count,1));
      l_count := l_count + 2;

      exit when l_count > l_leng;

    End Loop;

    l_odd_temp := l_odd_temp * 3;

    l_count := 2;
    l_even_temp := 0;

-- Sum up the digits at the even positions
    Loop

      l_even_temp := l_even_temp + to_number(substr(l_num_bar_code,l_count,1));
      l_count := l_count + 2;

      exit when l_count > l_leng;

    End Loop;

    l_temp := l_odd_temp + l_even_temp;

-- Get the modulus of the sum
    SELECT MOD(l_temp,10) into l_temp FROM dual;
	    -- Bug 8727000 FW Port of 11i Bug 8279519
        -- MOD will return 0 if l_temp passed is multiple of 10
        --In that case l_valid_digit will be 10-0 = 10 which is incorrect
        IF l_temp = 0 then
          l_valid_digit := to_char(l_temp);
        ELSE

-- Validation Digit is equivalent to 10 - modulus
    l_valid_digit := to_char(10 - l_temp);
	    END IF;

    l_num_bar_code := l_num_bar_code || l_valid_digit;

    RETURN l_num_bar_code;

END get_num_bar_code;


FUNCTION validate_document_letter
                   (p_batch_source_id    IN     NUMBER,
                    p_interface_line_id  IN     NUMBER,
                    p_created_from       IN     VARCHAR2,
                    p_ship_to_address_id IN     NUMBER,
                    p_document_letter    IN OUT NOCOPY VARCHAR2,
                    p_so_org_id          IN     VARCHAR2) RETURN VARCHAR2  IS

l_dummy_code              VARCHAR2(15);
error_condition           EXCEPTION;
l_return_code	          VARCHAR2(30);
l_match_flag              VARCHAR2(1) := 'N';
l_so_org_id               NUMBER;
l_auto_trx_numbering_flag VARCHAR2(1);
l_organization_class_code VARCHAR2(150);
l_contributor_class_code  VARCHAR2(150);
l_loc_id                  NUMBER(15);
l_cus_cls_flag            VARCHAR2(1);
l_org_id                  NUMBER;

CURSOR doc_letter_cursor IS
      SELECT tax_category_id,
	     org_tax_attribute_name,
	     org_tax_attribute_value,
	     con_tax_attribute_name,
             con_tax_attribute_value
      FROM   jl_ar_ar_doc_letter
      WHERE  document_letter = p_document_letter
      AND    sysdate between start_date_active and nvl(end_date_active,sysdate);

BEGIN
-- Commented out the following line, will be assigned 'SUCCESS' at the end of successful completion of the loop
--  l_return_code := 'SUCCESS';

  IF p_created_from = 'ARXTWMAI' THEN
     BEGIN
       SELECT global_attribute3
       INTO   p_document_letter
       FROM   ra_batch_sources
       WHERE  batch_source_id = p_batch_source_id;
     EXCEPTION
       WHEN OTHERS THEN
         l_return_code := 'JL_AR_AR_INVALID_DOC_LETTER';
         RAISE error_condition;
     END;
  END IF;

  --Bug 1404824 - l_so_org_id variable will be assigned using the parameter
  --passed
  --Commented the below line for bug 1612359
--  l_so_org_id := to_number(p_so_org_id);
    l_org_id := mo_global.get_current_org_id;
    l_so_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID',l_org_id);

  BEGIN
    l_loc_id := null;
    SELECT hou.location_id
    INTO   l_loc_id
    FROM   hr_organization_units hou
    WHERE  hou.organization_id = l_so_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          IF p_created_from = 'RAXTRX' THEN
             l_return_code := 'ERROR';
             IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                                        'JL_AR_AR_INVALID_ORGANIZATION',
                                         p_interface_line_id,
                                         l_so_org_id)  THEN
                RAISE  error_condition;
             END IF;
          ELSIF p_created_from = 'ARXTWMAI' THEN
             l_return_code := 'JL_AR_AR_INVALID_ORGANIZATION';
             RAISE error_condition;
          END IF;
  END;
  IF l_loc_id is not null then
     BEGIN
       SELECT hrl.global_attribute1
       INTO   l_organization_class_code
       FROM   hr_locations hrl,
              hr_organization_units hrou
       WHERE  hrou.organization_id = l_so_org_id
       AND    hrl.location_id = hrou.location_id;
       EXCEPTION WHEN NO_DATA_FOUND THEN
           IF p_created_from = 'RAXTRX' THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                                         'JL_AR_AR_INVALID_ORGANIZATION',
                                         p_interface_line_id,
                                         l_so_org_id)  THEN
                 RAISE  error_condition;
              END IF;
           ELSIF p_created_from = 'ARXTWMAI' THEN
              l_return_code := 'JL_AR_AR_INVALID_ORGANIZATION';
              RAISE error_condition;
           END IF;
     END;
  ELSE
     l_return_code := 'JL_AR_AR_LOCATION_NULL';
     RAISE error_condition;
  END IF;
  IF l_organization_class_code is null then
     IF p_created_from = 'RAXTRX' THEN
        l_return_code := 'JL_AR_AR_AI_ORG_CLS_NOT_DEF';
        IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                               'JL_AR_AR_AI_ORG_CLS_NOT_DEF',
                                p_interface_line_id,
                                l_so_org_id)  THEN
           RAISE  error_condition;
        END IF;
     ELSIF p_created_from = 'ARXTWMAI' THEN
        l_return_code := 'JL_AR_AR_ORG_CLS_CODE_NOT_DEF';
        RAISE error_condition;
     END IF;
  END IF;

  l_contributor_class_code := NULL;

  IF p_ship_to_address_id IS NOT NULL THEN
     IF p_created_from = 'ARXTWMAI' THEN
        BEGIN
          SELECT adr.global_attribute8
          INTO   l_contributor_class_code
          FROM   hz_cust_acct_sites_all adr,
                 hz_cust_site_uses rsu
          WHERE  rsu.site_use_id = p_ship_to_address_id
          AND    rsu.cust_acct_site_id = adr.cust_acct_site_id;
        END;
        IF l_contributor_class_code is null then
          l_return_code := 'JL_AR_AR_CONT_CLS_CODE_NOT_DEF';
          RAISE error_condition;
        END IF;
     ELSIF p_created_from = 'RAXTRX' THEN
        BEGIN
          SELECT cas.global_attribute8
          INTO   l_contributor_class_code
          FROM   hz_cust_acct_sites cas
          WHERE  cas.cust_acct_site_id = p_ship_to_address_id;
        END;
        IF l_contributor_class_code is null then
          l_return_code := 'ERROR';
          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                                   'JL_AR_AR_AI_CONT_CLS_NOT_DEF',
                                    p_interface_line_id,
                                    p_ship_to_address_id)  THEN
             RAISE  error_condition;
          END IF;
        END IF;
     END IF;
  END IF;

  FOR  doc_letter_rec IN doc_letter_cursor
  LOOP
    l_match_flag := 'N';

    BEGIN
      l_dummy_code := NULL;

      SELECT 'Success'
      INTO   l_dummy_code
      FROM   jl_zz_ar_tx_att_cls
      WHERE  tax_attr_class_code = l_organization_class_code
      AND    tax_attr_class_type = 'ORGANIZATION_CLASS'
      AND    tax_category_id = doc_letter_rec.tax_category_id
      AND    tax_attribute_name = doc_letter_rec.org_tax_attribute_name
      AND    tax_attribute_value = doc_letter_rec.org_tax_attribute_value;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           IF p_created_from = 'RAXTRX' THEN
              l_return_code := 'JL_AR_AR_AI_ATT_CLS_NOT_DEF';
           ELSIF p_created_from = 'ARXTWMAI' THEN
              l_return_code := 'JL_AR_AR_ATT_CLS_NOT_DEF';
           END IF;
    END;

    IF l_dummy_code = 'Success'  THEN
       l_match_flag := 'Y';
    END IF;

    l_dummy_code := NULL;
    BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('validate_document_letter: ' || '-- validate doc letter contributor class code ' || l_contributor_class_code);
           arp_standard.debug('validate_document_letter: ' || '-- validate doc letter ship to address id '|| to_char(p_ship_to_address_id));
           arp_standard.debug('validate_document_letter: ' || '-- validate doc letter tax category id '||to_char(doc_letter_rec.tax_category_id));
           arp_standard.debug('validate_document_letter: ' || '-- validate doc letter tax att name '||doc_letter_rec.con_tax_attribute_name);
           arp_standard.debug('validate_document_letter: ' || '-- validate doc letter tax att value '||doc_letter_rec.con_tax_attribute_value);
        END IF;
        IF p_created_from = 'ARXTWMAI' THEN
           SELECT nvl(cas.global_attribute9,'N')
           INTO  l_cus_cls_flag
           FROM  hz_cust_acct_sites_all cas, hz_cust_site_uses rsu
           WHERE rsu.site_use_id = p_ship_to_address_id
           AND   rsu.cust_acct_site_id = cas.cust_acct_site_id;
           --
           IF l_cus_cls_flag = 'Y' THEN
             SELECT 'Success'
             INTO   l_dummy_code
             FROM   jl_zz_ar_tx_cus_cls_all cus, hz_cust_acct_sites_all cas, hz_cust_site_uses rsu
             WHERE  tax_attr_class_code =  l_contributor_class_code
             AND    rsu.site_use_id = p_ship_to_address_id
             AND    cas.cust_acct_site_id = cus.address_id
             AND    rsu.cust_acct_site_id = cas.cust_acct_site_id
             AND    tax_category_id = doc_letter_rec.tax_category_id
             AND    tax_attribute_name = doc_letter_rec.con_tax_attribute_name
             AND    tax_attribute_value = doc_letter_rec.con_tax_attribute_value;
           ELSE
             SELECT 'Success'
             INTO   l_dummy_code
             FROM   jl_zz_ar_tx_att_cls att
             WHERE  tax_attr_class_type = 'CONTRIBUTOR_CLASS'
             AND    tax_attr_class_code =  l_contributor_class_code
             AND    tax_category_id = doc_letter_rec.tax_category_id
             AND    tax_attribute_name = doc_letter_rec.con_tax_attribute_name
             AND    tax_attribute_value = doc_letter_rec.con_tax_attribute_value;

           END IF;

       ELSE
           SELECT nvl(cas.global_attribute9,'N')
           INTO   l_cus_cls_flag
           FROM   hz_cust_acct_sites cas
           WHERE  cas.cust_acct_site_id = p_ship_to_address_id;
           IF l_cus_cls_flag = 'Y' THEN
             SELECT 'Success'
             INTO   l_dummy_code
             FROM   jl_zz_ar_tx_cus_cls_all cus, hz_cust_acct_sites cas
             WHERE  tax_attr_class_code =  l_contributor_class_code
             AND    cas.cust_acct_site_id = cus.address_id
             AND    cas.cust_acct_site_id = p_ship_to_address_id
             AND    tax_category_id = doc_letter_rec.tax_category_id
             AND    tax_attribute_name = doc_letter_rec.con_tax_attribute_name
             AND    tax_attribute_value = doc_letter_rec.con_tax_attribute_value;
           ELSE
             SELECT 'Success'
             INTO   l_dummy_code
             FROM   jl_zz_ar_tx_att_cls att
             WHERE  tax_attr_class_type = 'CONTRIBUTOR_CLASS'
             AND    tax_attr_class_code =  l_contributor_class_code
             AND    tax_category_id = doc_letter_rec.tax_category_id
             AND    tax_attribute_name = doc_letter_rec.con_tax_attribute_name
             AND    tax_attribute_value = doc_letter_rec.con_tax_attribute_value;

           END IF;
       END IF;

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           IF p_created_from = 'RAXTRX' THEN
              l_return_code := 'JL_AR_AR_AI_CU_SIT_PRO_NOT_DEF';
           ELSIF p_created_from = 'ARXTWMAI' THEN
              l_return_code := 'JL_AR_AR_CUS_SITE_PROF_NOT_DEF';
           END IF;
           l_dummy_code := NULL;
           l_match_flag := 'N';
    END;

    IF l_dummy_code = 'Success' AND l_match_flag = 'Y' THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('validate_document_letter: ' || '-- Successfully found a combination ');
     END IF;
-- Assigned SUCCESS to l_return_code Bug 1323607
       l_return_code := 'SUCCESS';
       EXIT;
    END IF;

  END LOOP;

  IF l_match_flag = 'N' THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('validate_document_letter: ' || '-- match flag is n');
     END IF;
-- Added the following if condition Bug 1323607

     IF l_return_code IS NULL THEN   -- Cursor contained no records
        l_return_code := 'JL_AR_AR_DOC_LET_NOT_FOUND';
     END IF;

     IF p_created_from = 'RAXTRX' THEN
  	IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                                  l_return_code,
                                  p_interface_line_id,
                                  p_batch_source_id) THEN

           RAISE error_condition;
        END IF;
     ELSIF p_created_from = 'ARXTWMAI' THEN
        RAISE error_condition;
     END IF;
  END IF;

  RETURN  l_return_code;

EXCEPTION
  WHEN OTHERS THEN
       IF l_return_code is null then
          l_return_code := 'JL_AR_AR_INVALID_DOC_LETTER';
       END IF;
       RETURN l_return_code;

END validate_document_letter;

FUNCTION validate_interface_lines ( p_request_id IN NUMBER
                                   ,p_interface_line_id IN NUMBER
                                   ,p_trx_type IN NUMBER
                                   ,p_inventory_item_id IN NUMBER
                                   ,p_memo_line_id IN NUMBER
                                   ,p_trx_date IN DATE
                                   ,p_orig_system_address_id IN NUMBER
                                   ,p_so_org_id              IN VARCHAR2)
RETURN BOOLEAN IS

l_dummy_code               VARCHAR2(15);
error_condition            EXCEPTION;
l_return_code              NUMBER;
l_max_trx_date             DATE;
l_batch_source_id          NUMBER(15);
l_auto_trx_numbering_flag  VARCHAR2(1);
l_last_trx_date            DATE;
l_advance_days             NUMBER;
l_document_letter          VARCHAR2(1);
l_invoice_class            VARCHAR2(20);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- JL_AR_DOC_NUMBERING_PKG validation begins');
  END IF;

  l_return_code := 1;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- trying to get the batch source id for the request');
  END IF;
  BEGIN
    SELECT to_number(argument3)
    INTO   l_batch_source_id
    FROM   fnd_concurrent_requests
    WHERE  request_id = p_request_id;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- the batch source id for the request is '||to_char(l_batch_source_id));
  END IF;
  END;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- trying to get the batch source gdf segments');
  END IF;
  BEGIN
    SELECT auto_trx_numbering_flag
          ,substr(global_attribute3,1,1)
          ,to_date(global_attribute4,'YYYY/MM/DD HH24:MI:SS')
          ,to_number(global_attribute5)
    INTO  l_auto_trx_numbering_flag
         ,l_document_letter
         ,l_last_trx_date
	 ,l_advance_days
    FROM  ra_batch_sources
    WHERE  batch_source_id = l_batch_source_id;
  END;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- the batch source gdf segments found');
  END IF;

  IF l_auto_trx_numbering_flag ='N' THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('validate_interface_lines: ' || '-- auto trx numbering flag is N');
     END IF;
     l_return_code := 1;
     RAISE error_condition;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- auto trx numbering flag is Y');
     arp_standard.debug('validate_interface_lines: ' || '-- validate document letter begins');
  END IF;

  IF validate_document_letter (l_batch_source_id
                              ,p_interface_line_id
                              ,'RAXTRX'
                              ,p_orig_system_address_id
                              ,l_document_letter
                              ,p_so_org_id ) <> 'SUCCESS' THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('validate_interface_lines: ' || '-- validate document letter set up problem');
     END IF;
     l_return_code := 1;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- trying to get the type for the trx type');
  END IF;
  BEGIN
    SELECT type
    INTO   l_invoice_class
    FROM   ra_cust_trx_types
    WHERE  cust_trx_type_id = p_trx_type;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- the type for the trx type found');
  END IF;
  END;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- validate trx type begins');
  END IF;

  IF validate_trx_type (l_batch_source_id
                       ,p_trx_type
                       ,l_invoice_class
                       ,l_document_letter
                       ,p_interface_line_id
                       ,'RAXTRX' ) <> 'SUCCESS' THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('validate_interface_lines: ' || '-- validate trx types and sources are not set');
     END IF;
     l_return_code := 1;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- validate branch number begins');
  END IF;
  IF validate_four_digit (l_batch_source_id
                         ,p_interface_line_id
                         ,'RAXTRX'
                         ,p_inventory_item_id
                         ,p_memo_line_id
                         ,p_so_org_id ) <> 'SUCCESS' THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('validate_interface_lines: ' || '-- branch number validation problem');
     END IF;
     l_return_code := 1;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- validate trx date begins');
  END IF;
  IF p_trx_date BETWEEN
     l_last_trx_date AND (sysdate+l_advance_days) THEN
     IF p_trx_date <> l_last_trx_date  THEN
        l_max_trx_date := p_trx_date;
     END IF;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('validate_interface_lines: ' || '-- validate trx date ok');
     END IF;
  ELSE
     BEGIN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('validate_interface_lines: ' || '-- date validation problem');
          END IF;
          l_return_code := 1;
          IF p_trx_date < l_last_trx_date THEN
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                          'JL_AR_AR_INVALID_TRANS_DATE',
                           to_char(p_interface_line_id),
                           to_char(l_batch_source_id))  THEN
              RAISE  error_condition;
            END IF;
          ELSE
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL',
                          'JL_AR_AR_INVALID_TRX_DT_AFT',
                           to_char(p_interface_line_id),
                           to_char(l_batch_source_id))  THEN
              RAISE  error_condition;
            END IF;
          END IF;
     END;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('validate_interface_lines: ' || '-- update the dates');
  END IF;
  IF l_last_trx_date <> l_max_trx_date THEN
    UPDATE ra_batch_sources
    SET    global_attribute4 = fnd_date.date_to_canonical(l_max_trx_date)
    WHERE  batch_source_id = l_batch_source_id;
  END IF;

  IF l_return_code = 0 THEN
     RETURN FALSE;
  ELSE
     RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('validate_interface_lines: ' || '-- validate interface lines problem  - in others1');
       END IF;
       IF l_auto_trx_numbering_flag ='N' THEN
          l_return_code := 1;
       ELSE
          l_return_code := 0;
       END IF;
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('validate_interface_lines: ' || '-- validate interface lines problem  - in others2');
       END IF;
       IF l_return_code = 0 THEN
          RETURN FALSE;
       ELSE
          RETURN TRUE;
       END IF;

END validate_interface_lines;

FUNCTION get_imported_batch_source (p_batch_source_id IN NUMBER)
                                    RETURN NUMBER IS
  l_imp_batch_src NUMBER;
  l_imp_batch_type varchar2(30);
BEGIN
  l_imp_batch_src := NULL;
  BEGIN
    SELECT decode(batch_source_type, 'INV',to_number(global_attribute1),
                                     batch_source_id)
    INTO   l_imp_batch_src
    FROM   ra_batch_sources
    WHERE  batch_source_id = p_batch_source_id;
  EXCEPTION
    WHEN OTHERS THEN
         l_imp_batch_src := NULL;
  END;
  RETURN l_imp_batch_src;
END;

FUNCTION get_flex_value(p_concat_segs IN VARCHAR2,p_flex_delimiter IN VARCHAR2)
RETURN VARCHAR2 IS
l_num_code VARCHAR2(50);
BEGIN

  SELECT substr(p_concat_segs,instr(p_concat_segs,''||p_flex_delimiter||'',1,4)+1) INTO l_num_code FROM dual;

  RETURN l_num_code;

EXCEPTION
 WHEN OTHERS THEN
   RETURN NULL;
END;

FUNCTION get_flex_delimiter RETURN VARCHAR2 IS
  l_dfinfo_rec  FND_FLEX_SERVER1.DESCFLEXINFO;
  l_success_bln BOOLEAN;
BEGIN
  l_success_bln:= FND_FLEX_SERVER2.GET_DESCSTRUCT('JG','JG_RA_CUSTOMER_TRX',l_dfinfo_rec);
  IF l_success_bln = TRUE THEN
     RETURN l_dfinfo_rec.segment_delimiter;
  ELSE
     RETURN NULL;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

FUNCTION get_batch_source_type (p_batch_source_id IN NUMBER)
                                    RETURN VARCHAR2 IS
  l_imp_batch_src_type varchar2(30);
BEGIN
  l_imp_batch_src_type := NULL;
  BEGIN
    SELECT batch_source_type
    INTO   l_imp_batch_src_type
    FROM   ra_batch_sources
    WHERE  batch_source_id = p_batch_source_id;
  EXCEPTION
    WHEN OTHERS THEN
         l_imp_batch_src_type := NULL;
  END;
  RETURN l_imp_batch_src_type;
END get_batch_source_type;

FUNCTION validate_transaction_date
                      (p_trx_date IN DATE,
                       p_batch_source_id IN NUMBER) RETURN VARCHAR2 IS
  l_return_code varchar2(30);
BEGIN
  l_return_code := 'SUCCESS';
  BEGIN
    SELECT 'SUCCESS'
    INTO   l_return_code
    FROM   ra_batch_sources
    WHERE  batch_source_id = p_batch_source_id
    AND    batch_source_type = 'FOREIGN'
    AND    p_trx_date BETWEEN
                 to_date(global_attribute4,'YYYY/MM/DD HH24:MI:SS')
            AND  SYSDATE + to_number(global_attribute5);
  EXCEPTION
    WHEN OTHERS THEN
        l_return_code := 'JL_AR_AR_INVALID_TRX_DATE';
  END;
  RETURN l_return_code;
END validate_transaction_date;


FUNCTION get_printing_count (p_cust_trx_id IN VARCHAR2) RETURN NUMBER IS
  l_return_code number(38) := 0;
BEGIN
  BEGIN
    SELECT nvl(printing_count,0)
    INTO   l_return_code
    FROM   ra_customer_trx
    WHERE  customer_trx_id  = p_cust_trx_id;
  EXCEPTION
    WHEN OTHERS THEN
        l_return_code := 0;
  END;
  RETURN l_return_code;
END get_printing_count;

FUNCTION get_branch_number_method RETURN VARCHAR2 IS
  l_br_numb_method varchar2(20);
BEGIN
  BEGIN
    SELECT global_attribute1
    INTO   l_br_numb_method
    FROM   ar_system_parameters;
  EXCEPTION
    WHEN OTHERS THEN
        l_br_numb_method := null;
  END;
  RETURN l_br_numb_method;
END get_branch_number_method;

FUNCTION get_point_of_sale_code(p_inv_org_id IN VARCHAR2) RETURN VARCHAR2 IS
  l_br_numb_code varchar2(4);
BEGIN
  BEGIN
    SELECT hl.global_attribute7
    INTO   l_br_numb_code
    FROM   hr_locations hl, hr_organization_units hou
    WHERE  hl.location_id = hou.location_id
    AND    hou.organization_id = p_inv_org_id;
  EXCEPTION
    WHEN OTHERS THEN
        l_br_numb_code := -1;
  END;
  IF l_br_numb_code IS NULL THEN
     l_br_numb_code := -1;
  END IF;
  RETURN l_br_numb_code;
END get_point_of_sale_code;

FUNCTION get_doc_letter(p_batch_source_id  IN NUMBER) RETURN VARCHAR2 IS
  l_doc_letter varchar2(4);
BEGIN
  BEGIN
    SELECT substr(rbs.global_attribute3,1,1)
    INTO   l_doc_letter
    FROM   ra_batch_sources rbs
    WHERE  rbs.batch_source_id = p_batch_source_id;
  EXCEPTION
    WHEN OTHERS THEN
        l_doc_letter := null;
  END;
  RETURN l_doc_letter;
END get_doc_letter;

FUNCTION get_branch_number(p_batch_source_id  IN NUMBER) RETURN VARCHAR2 IS
  l_br_number varchar2(4);
BEGIN
  BEGIN
    SELECT lpad(substr(rbs.global_attribute2,1,4),4,'0')
    INTO   l_br_number
    FROM   ra_batch_sources rbs
    WHERE  rbs.batch_source_id = p_batch_source_id;
  EXCEPTION
    WHEN OTHERS THEN
        l_br_number := null;
  END;
  RETURN l_br_number;
END get_branch_number;

FUNCTION get_last_trx_date(p_batch_source_id  IN NUMBER) RETURN DATE IS
  l_last_trx_date date;
BEGIN
  BEGIN
    SELECT to_date(rbs.global_attribute4,'YYYY/MM/DD HH24:MI:SS')
    INTO   l_last_trx_date
    FROM   ra_batch_sources rbs
    WHERE  rbs.batch_source_id = p_batch_source_id;
  EXCEPTION
    WHEN OTHERS THEN
        l_last_trx_date := null;
  END;
  RETURN l_last_trx_date;
END get_last_trx_date;

FUNCTION get_adv_days(p_batch_source_id  IN NUMBER) RETURN VARCHAR2 IS
  l_adv_days varchar2(5);
BEGIN
  BEGIN
    SELECT substr(rbs.global_attribute5,1,3)
    INTO   l_adv_days
    FROM   ra_batch_sources rbs
    WHERE  rbs.batch_source_id = p_batch_source_id;
  EXCEPTION
    WHEN OTHERS THEN
        l_adv_days := null;
  END;
  RETURN l_adv_days;
END get_adv_days;

FUNCTION get_hr_branch_number(p_location_id  IN NUMBER) RETURN VARCHAR2 IS
  l_hr_br_number varchar2(4);
BEGIN
  BEGIN
    SELECT lpad(substr(hl.global_attribute7,1,4),4,'0')
    INTO   l_hr_br_number
    FROM   hr_locations  hl
    WHERE  hl.location_id  = p_location_id;
  EXCEPTION
    WHEN OTHERS THEN
        l_hr_br_number := null;
  END;
  RETURN l_hr_br_number;
END get_hr_branch_number;

FUNCTION trx_num_gen(p_batch_source_id   IN NUMBER,
                     p_trx_number        IN VARCHAR2) RETURN VARCHAR2 IS
    l_country_code 	      VARCHAR2(2);
    l_document_letter         VARCHAR2(1);
    l_branch_number           VARCHAR2(4);
    l_auto_trx_numbering_flag ra_batch_sources_all.auto_trx_numbering_flag%TYPE;
    l_trx_number              ra_customer_trx_all.trx_number%TYPE;
    l_org_id                  NUMBER;
    l_ledger_id               NUMBER;
    l_batch_src_type          ra_batch_sources_all.batch_source_type%TYPE;
    l_source_id               ra_batch_sources_all.batch_source_id%TYPE;
    l_seq_name VARCHAR2(100);
-- This function is being called from auto invoice.
    l_trx_num_cursor INTEGER;
    --l_seq_name VARCHAR2(100);
    seq_no number;
    l_count number;
    l_string varchar2(1000);

BEGIN
  l_org_id := mo_global.get_current_org_id;
  l_ledger_id := NULL;
  l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id,l_ledger_id);
  -- MOAC changes
  --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');
  l_trx_number := p_trx_number;

  IF l_country_code = 'AR' THEN

     SELECT batch_source_type into l_batch_src_type
     FROM ra_batch_sources_all
     WHERE batch_source_id = p_batch_source_id;

     IF l_batch_src_type <> 'FOREIGN' THEN

       SELECT global_attribute1 into l_source_id
       FROM ra_batch_sources_all
       WHERE batch_source_id = p_batch_source_id;

       SELECT substr(global_attribute2,1,4),
              substr(global_attribute3,1,1),
              auto_trx_numbering_flag
       INTO   l_branch_number,
              l_document_letter,
              l_auto_trx_numbering_flag
       FROM   ra_batch_sources_all
       WHERE  batch_source_id = l_source_id;
    --Bug#7697795
    --Start
      l_seq_name := 'RA_TRX_NUMBER_'
	               || to_char(l_source_id)
		       || '_'
                       || l_org_id
		       || '_S';


     l_string := 'select '||
                       l_seq_name||'.nextval seq_number '||
                       'from dual' ;

     execute immediate l_string into seq_no;
     l_trx_number := seq_no;

     --End

    ELSE

       SELECT substr(global_attribute2,1,4),
              substr(global_attribute3,1,1),
              auto_trx_numbering_flag
       INTO   l_branch_number,
              l_document_letter,
              l_auto_trx_numbering_flag
       FROM   ra_batch_sources_all
       WHERE  batch_source_id = p_batch_source_id;

    END IF;

       IF l_auto_trx_numbering_flag = 'Y' AND
            substr(p_trx_number,1,6) <> l_document_letter || '-' ||
            l_branch_number THEN
          l_trx_number := l_document_letter || '-' || l_branch_number || '-'
                               || lpad(l_trx_number,8,'0');
       END IF;
  END IF;

  RETURN l_trx_number;
  EXCEPTION
  WHEN OTHERS THEN
      RAISE;
END;

BEGIN

PG_DEBUG :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

END JL_AR_DOC_NUMBERING_PKG;

/
