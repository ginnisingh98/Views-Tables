--------------------------------------------------------
--  DDL for Package Body JL_AR_AUTOINV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_AUTOINV_PKG" as
/* $Header: jlarranb.pls 120.5.12010000.4 2009/08/13 14:17:41 rsaini ship $ */

PROCEDURE UPDATE_BATCH_SOURCE(p_invoice_date_from IN DATE,
                              p_invoice_date_to   IN DATE,
                              p_gl_date_from      IN DATE,
                              p_gl_date_to        IN DATE,
                              p_ship_date_from    IN DATE,
                              p_ship_date_to      IN DATE,
                              p_default_date      IN DATE) IS
  l_contributor_class_code    VARCHAR2(150);
  l_organization_class_code   VARCHAR2(150);
  l_tax_category_id           NUMBER;
  l_org_attribute_name        VARCHAR2(30);
  l_org_attribute_value       VARCHAR2(30);
  l_cust_attribute_name       VARCHAR2(30);
  l_cust_attribute_value      VARCHAR2(30);
  l_document_letter           VARCHAR2(1);
  l_new_batch_source_name     VARCHAR2(50);
  l_so_org_id                 NUMBER;
  l_batch_source_id           NUMBER;
  l_cus_cls_flag              VARCHAR2(1);
  error_condition             EXCEPTION;
  l_org_id                    NUMBER;
  CURSOR trx_lines (p_invoice_date_from DATE,
                    p_invoice_date_to DATE,
                    p_gl_date_from DATE,
                    p_gl_date_to DATE,
                    p_ship_date_from DATE,
                    p_ship_date_to DATE) IS
    SELECT rowid,
           interface_line_attribute1,
           cust_trx_type_id,
           nvl(orig_system_ship_address_id,
               orig_system_bill_address_id) orig_system_address_id,
           batch_source_name,
           trx_date,
           org_id
      FROM ra_interface_lines
     WHERE nvl(interface_status, '~') <> 'P'
     AND   ((nvl(trx_date,sysdate-1) BETWEEN
           nvl(p_invoice_date_from,nvl(trx_date,sysdate)) AND
           nvl(p_invoice_date_to, nvl(trx_date,sysdate)))
           OR (p_invoice_date_from is null and p_invoice_date_to is null
               and trx_date is null))
     AND  ((nvl(gl_date,sysdate-1) BETWEEN
           nvl(p_gl_date_from, nvl(gl_date,sysdate)) AND
           nvl(p_gl_date_to, nvl(gl_date,sysdate)))
           OR (p_gl_date_from is null and p_gl_date_to is null
               and gl_date is null))
     AND  ((nvl(ship_date_actual,sysdate-1) BETWEEN
           nvl(p_ship_date_from,nvl(ship_date_actual,sysdate)) AND
           nvl(p_ship_date_to,nvl(ship_date_actual,sysdate)))
           OR (p_ship_date_from is null and p_ship_date_to is null
               and ship_date_actual is null));
BEGIN
  arp_file.write_log('inside update_batch_source',0);
  FOR trx_lines_rec IN
      trx_lines(p_invoice_date_from, p_invoice_date_to,
                p_gl_date_from, p_gl_date_to,
                p_ship_date_from, p_ship_date_to)
    LOOP

      arp_file.write_log('Processing interface line  '||
                          trx_lines_rec.interface_line_attribute1,0);

      l_contributor_class_code := null;
      l_organization_class_code := null;
      l_tax_category_id := null;
      l_org_attribute_name  := null;
      l_org_attribute_value := null;
      l_cust_attribute_name  := null;
      l_cust_attribute_value := null;
      l_document_letter := null;
      l_batch_source_id := null;
      l_so_org_id := null;
      l_new_batch_source_name := null;

      BEGIN
        SELECT ra.global_attribute8
        INTO   l_contributor_class_code
        FROM   hz_cust_acct_sites ra
        WHERE  ra.cust_acct_site_id = trx_lines_rec.orig_system_address_id;
        arp_file.write_log('Contributor class code '||l_contributor_class_code);

      EXCEPTION WHEN NO_DATA_FOUND THEN
         arp_file.write_log('Address Id invalid '||
                             trx_lines_rec.orig_system_address_id,0);
         IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                   'JL_ZZ_AR_INVALID_ADDRESS',
                                    trx_lines_rec.interface_line_attribute1,
                                    'JLERRUBS')  THEN
            RAISE error_condition;
         END IF;
      END;
      IF l_contributor_class_code is null then
         IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                   'JL_AR_AR_AI_CONT_CLS_NOT_DEF',
                                    trx_lines_rec.interface_line_attribute1,
                                    'JLERRUBS')  THEN
            RAISE  error_condition;
         END IF;
      END IF;

      -- Get Organization class code
      l_org_id := mo_global.get_current_org_id;
      l_so_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID',l_org_id);

      BEGIN
        SELECT hrl.global_attribute1
        INTO   l_organization_class_code
        FROM   hr_locations hrl,
               hr_organization_units hrou
        WHERE  hrou.organization_id = l_so_org_id
        AND    hrl.location_id = hrou.location_id;

        arp_file.write_log('Organization class code '||l_organization_class_code,0);

      EXCEPTION WHEN NO_DATA_FOUND THEN
       arp_file.write_log('Inv Org Id invalid '|| l_so_org_id,0);
       IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                         'JL_AR_AR_INVALID_ORGANIZATION',
                                         trx_lines_rec.interface_line_attribute1,
                                         'JLERRUBS')  THEN
          RAISE  error_condition;
       END IF;
      END;

      IF l_organization_class_code IS NULL THEN
        IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                         'JL_AR_AR_AI_ORG_CLS_NOT_DEF',
                                          trx_lines_rec.interface_line_attribute1,
                                          'JLERRUBS')  THEN
           RAISE  error_condition;
        END IF;
      END IF;

      -- Get VAT tax category from document letter table
      BEGIN
        SELECT distinct tax_category_id
        INTO   l_tax_category_id
        FROM   jl_ar_ar_doc_letter;

      EXCEPTION WHEN NO_DATA_FOUND THEN
        arp_file.write_log('Document letter not set up',0);
        IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                               'JL_AR_AR_DOC_LET_NOT_FOUND ',
                                trx_lines_rec.interface_line_attribute1,
                                'JLERRUBS')  THEN
           RAISE  error_condition;
        END IF;
      END;

      -- Get condition and value for organization class code and tax category
      IF l_organization_class_code IS NOT NULL AND
         l_tax_category_id IS NOT NULL THEN
        BEGIN
          SELECT tax_attribute_name, tax_attribute_value
          INTO   l_org_attribute_name, l_org_attribute_value
          FROM   jl_zz_ar_tx_att_cls cls, jl_zz_ar_tx_categ cat
          WHERE  cls.tax_attr_class_type = 'ORGANIZATION_CLASS'
          AND    cls.tax_attr_class_code = l_organization_class_code
          AND    cls.tax_category_id = l_tax_category_id
          AND    cls.tax_category_id = cat.tax_category_id
          AND    cls.tax_attribute_name = cat.org_tax_attribute;

          arp_file.write_log('Organization condition '||l_org_attribute_name,0);
          arp_file.write_log('Organization condition value '||l_org_attribute_value,0);

        EXCEPTION WHEN NO_DATA_FOUND THEN
          arp_file.write_log('Organization attributes not found',0);
          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                'JL_AR_AR_AI_ATT_CLS_NOT_DEF',
                                  trx_lines_rec.interface_line_attribute1,
                                'JLERRUBS')  THEN
           RAISE  error_condition;
          END IF;

        END;
      END IF;

      -- Get condition and value for contributor class code and tax category
      IF l_contributor_class_code IS NOT NULL AND
         l_tax_category_id IS NOT NULL THEN
         SELECT nvl(cas.global_attribute9,'N')
         INTO  l_cus_cls_flag
         FROM  hz_cust_acct_sites cas
         WHERE cas.cust_acct_site_id = trx_lines_rec.orig_system_address_id;
        IF l_cus_cls_flag = 'Y' THEN
          BEGIN
            SELECT tax_attribute_name, tax_attribute_value
            INTO   l_cust_attribute_name, l_cust_attribute_value
            FROM   jl_zz_ar_tx_cus_cls cus, jl_zz_ar_tx_categ cat
            WHERE  cus.tax_attr_class_code =  l_contributor_class_code
            AND    cus.address_id = trx_lines_rec.orig_system_address_id
            AND    cus.tax_category_id = l_tax_category_id
            AND    cus.tax_category_id = cat.tax_category_id
            AND    cus.tax_attribute_name = cat.cus_tax_attribute;

            arp_file.write_log('Contributor condition '||l_cust_attribute_name,0);
            arp_file.write_log('Contributor condition value '||l_cust_attribute_value,0);

          EXCEPTION WHEN NO_DATA_FOUND THEN
            arp_file.write_log('Contributor condition not found ',0);
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                'JL_AR_AR_AI_CU_SIT_PRO_NOT_DEF',
                                 trx_lines_rec.interface_line_attribute1,
                                 'JLERRUBS')  THEN
             RAISE  error_condition;
            END IF;
          END;
       ELSE
          BEGIN
             SELECT tax_attribute_name, tax_attribute_value
             INTO   l_cust_attribute_name, l_cust_attribute_value
             FROM   jl_zz_ar_tx_att_cls att, jl_zz_ar_tx_categ cat
             WHERE  att.tax_attr_class_type = 'CONTRIBUTOR_CLASS'
             AND    att.tax_attr_class_code =  l_contributor_class_code
             AND    att.tax_category_id = l_tax_category_id
             AND    att.tax_attribute_name = cat.cus_tax_attribute
             AND    att.tax_category_id = cat.tax_category_id;

            arp_file.write_log('Contributor condition '||l_cust_attribute_name,0);
            arp_file.write_log('Contributor condition value '||l_cust_attribute_value,0);

        EXCEPTION WHEN NO_DATA_FOUND THEN
          arp_file.write_log('Contributor condition not found ',0);
          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                'JL_AR_AR_AI_CU_SIT_PRO_NOT_DEF',
                                 trx_lines_rec.interface_line_attribute1,
                                 'JLERRUBS')  THEN
             RAISE  error_condition;
          END IF;
        END;

       END IF;
      END IF;

      --  Get document letter for Organization and contributor conditions
      --  and values and tax category
      IF l_org_attribute_name IS NOT NULL AND l_org_attribute_value IS NOT NULL AND
         l_cust_attribute_name IS NOT NULL AND l_cust_attribute_value IS NOT NULL THEN
         BEGIN
           SELECT document_letter
           INTO   l_document_letter
           FROM   jl_ar_ar_doc_letter
           WHERE tax_category_id = l_tax_category_id
           AND  org_tax_attribute_name = l_org_attribute_name
           AND  org_tax_attribute_value = l_org_attribute_value
           AND  con_tax_attribute_name = l_cust_attribute_name
           AND  con_tax_attribute_value = l_cust_attribute_value
           AND  nvl(trx_lines_rec.trx_date, p_default_date) BETWEEN start_date_active AND end_date_active;
           arp_file.write_log('Document letter is '||l_document_letter,0);

         EXCEPTION WHEN NO_DATA_FOUND THEN
           arp_file.write_log('Document letter not found ',0);
           IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                'JL_AR_AR_DOC_LET_NOT_FOUND',
                                trx_lines_rec.interface_line_attribute1,
                                'JLERRUBS')  THEN
             RAISE  error_condition;
           END IF;
         END;
      END IF;

     --  Get batch source using letter and transaction type
      IF l_document_letter IS NOT NULL THEN
        BEGIN
          SELECT ty.batch_source_id
          INTO   l_batch_source_id
          FROM   jg_zz_ar_src_trx_ty ty, ra_batch_sources src
          WHERE  ty.cust_trx_type_id = trx_lines_rec.cust_trx_type_id
          AND    ty.batch_source_id = src.batch_source_id
          AND    src.global_attribute3 = l_document_letter
          AND    ty.enable_flag = 'Y';

          arp_file.write_log('Correct Batch source id is '||l_batch_source_id,0);

        EXCEPTION WHEN NO_DATA_FOUND THEN
          arp_file.write_log('Batch source not found',0);
           IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                'JL_AR_AR_BT_SRC_NOT_FOUND',
                                trx_lines_rec.interface_line_attribute1,
                                'JLERRUBS')  THEN
             RAISE  error_condition;
           END IF;
        WHEN TOO_MANY_ROWS THEN
          arp_file.write_log('More than one batch source found',0);
           IF NOT JG_ZZ_AUTO_INVOICE.put_error_message1 ('JL',
                                'JL_AR_AR_BT_SRC_MORE_FOUND',
                                trx_lines_rec.interface_line_attribute1,
                                'JLERRUBS')  THEN
             RAISE  error_condition;
           END IF;
        END;
      END IF;

      BEGIN
        IF l_batch_source_id IS NOT NULL
        THEN
          SELECT name
          INTO   l_new_batch_source_name
          FROM   ra_batch_sources
          WHERE  batch_source_id = l_batch_source_id;
        END IF;

      END;

      IF nvl(l_new_batch_source_name,trx_lines_rec.batch_source_name) <> trx_lines_rec.batch_source_name THEN
        UPDATE ra_interface_lines
        SET batch_source_name = l_new_batch_source_name
        WHERE rowid = trx_lines_rec.rowid;
        INSERT INTO JL_AUTOINV_INT_LINES (INTERFACE_LINE_REF, MESSAGE_TEXT, INVALID_VALUE, ORG_ID)
                    VALUES(trx_lines_rec.interface_line_attribute1,
                           'Original batch source : '||trx_lines_rec.batch_source_name||
                           'is updated with new batch source :'||l_new_batch_source_name,
                           'JLUPDUBS',
                           trx_lines_rec.org_id);
        arp_file.write_log('Updated old batch source '||trx_lines_rec.batch_source_name ||
                           'to '|| l_new_batch_source_name,0);
      END IF;

    END LOOP;
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    arp_file.write_log(sqlerrm,0);
END;

PROCEDURE JL_AR_AR_UPDATE_BATCH_SOURCE (
  errbuf                      OUT NOCOPY varchar2,
  retcode                     OUT NOCOPY number,
  p_low_gl_date               IN VARCHAR2 ,
  p_high_gl_date              IN VARCHAR2 ,
  p_low_ship_date             IN VARCHAR2 ,
  p_high_ship_date            IN VARCHAR2,
  p_low_invoice_date          IN VARCHAR2 ,
  p_high_invoice_date         IN VARCHAR2,
  p_default_date              IN VARCHAR2) IS
  X_req_id    NUMBER(38);
  p_low_gl_dt  DATE;
  p_high_gl_dt DATE;
  p_low_ship_dt DATE;
  p_high_ship_dt DATE;
  p_low_invoice_dt DATE;
  p_high_invoice_dt DATE;
  p_default_dt DATE;
  BEGIN
    arp_file.write_log('Calling Update Batch source',0);

    p_low_gl_dt := fnd_date.canonical_to_date(p_low_gl_date);
    p_high_gl_dt := fnd_date.canonical_to_date(p_high_gl_date);
    p_low_ship_dt := fnd_date.canonical_to_date(p_low_ship_date);
    p_high_ship_dt := fnd_date.canonical_to_date(p_high_ship_date);
    p_low_invoice_dt := fnd_date.canonical_to_date(p_low_invoice_date);
    p_high_invoice_dt := fnd_date.canonical_to_date(p_high_invoice_date);
    p_default_dt := fnd_date.canonical_to_date(p_default_date);

    arp_file.write_log('low gl'||p_low_gl_date,0);
    arp_file.write_log('high gl'||p_high_gl_date,0);
    arp_file.write_log('l ship'||p_low_ship_date,0);
    arp_file.write_log('h ship'||p_high_ship_date,0);
    arp_file.write_log('l invoice'||p_low_invoice_date,0);
    arp_file.write_log('h invoice'||p_high_invoice_date,0);
    arp_file.write_log('default'||p_default_date,0);

    UPDATE_BATCH_SOURCE(p_low_invoice_dt, p_high_invoice_dt,
                        p_low_gl_dt, p_high_gl_dt,
                        p_low_ship_dt, p_high_ship_dt, p_default_dt);

    arp_file.write_log('After update batch source');
-- Call to the Batch Source Update error report
       X_req_id := FND_REQUEST.SUBMIT_REQUEST(
			  'JL' ,
			  'JLARRERR',
			  'Argentine Autoinvoice Batch Source Update Error Report',
			  SYSDATE,
                          FALSE);
EXCEPTION
 WHEN OTHERS THEN
    arp_file.write_log(sqlerrm,0);

END JL_AR_AR_UPDATE_BATCH_SOURCE;


PROCEDURE submit_request (
  errbuf                      OUT NOCOPY varchar2,
  retcode                     OUT NOCOPY number,
  p_parallel_module_name      IN varchar2,
  p_running_mode              IN varchar2,
  p_batch_source_id           IN ra_batch_sources.batch_source_id%TYPE,
  p_batch_source_name         IN varchar2,
  p_default_date              IN varchar2,
  p_trans_flexfield           IN varchar2,
  p_trans_type                IN ra_cust_trx_types.name%TYPE,
  p_low_bill_to_cust_num      IN hz_cust_accounts.account_number%TYPE  ,
  p_high_bill_to_cust_num     IN hz_cust_accounts.account_number%TYPE ,
  p_low_bill_to_cust_name     IN hz_parties.party_name%TYPE ,
  p_high_bill_to_cust_name    IN hz_parties.party_name%TYPE  ,
  p_low_gl_date               IN VARCHAR2 ,
  p_high_gl_date              IN VARCHAR2 ,
  p_low_ship_date             IN VARCHAR2,
  p_high_ship_date            IN VARCHAR2,
  p_low_trans_number          IN ra_interface_lines.trx_number%TYPE,
  p_high_trans_number         IN ra_interface_lines.trx_number%TYPE ,
  p_low_sales_order_num       IN ra_interface_lines.sales_order%TYPE ,
  p_high_sales_order_num      IN ra_interface_lines.sales_order%TYPE,
  p_low_invoice_date          IN VARCHAR2 ,
  p_high_invoice_date         IN VARCHAR2 ,
  p_low_ship_to_cust_num      IN hz_cust_accounts.account_number%TYPE ,
  p_high_ship_to_cust_num     IN hz_cust_accounts.account_number%TYPE ,
  p_low_ship_to_cust_name     IN hz_parties.party_name%TYPE ,
  p_high_ship_to_cust_name    IN hz_parties.party_name%TYPE,
  p_call_from_master_flag     IN varchar2 ,
  p_base_due_date_on_trx_date IN fnd_lookups.meaning%TYPE ,
  p_due_date_adj_days         IN number ) IS

  X_req_id    NUMBER(38);
  call_status BOOLEAN;
  rphase      VARCHAR2(30);
  rstatus     VARCHAR2(30);
  dphase      VARCHAR2(30);
  dstatus     VARCHAR2(30);
  message     VARCHAR2(240);
  l_org_id    NUMBER;

  BEGIN
       arp_file.write_log('JL Submitting Autoinvoice',0);

       -- Bug#7642995 Start
        l_org_id := mo_global.get_current_org_id;

        arp_file.write_log(l_org_id,0);

        fnd_request.set_org_id(l_org_id);

      -- Bug#7642995 End

       X_req_id := FND_REQUEST.SUBMIT_REQUEST(
			  'AR' ,
			  'RAXTRX',
			  'Autoinvoice Import Program',
			  SYSDATE,
                          FALSE,
			  p_parallel_module_name,
			  p_running_mode,
  			  p_batch_source_id,
			  p_batch_source_name,
			  p_default_date,
			  p_trans_flexfield,
			  p_trans_type,
			  p_low_bill_to_cust_num,
			  p_high_bill_to_cust_num,
			  p_low_bill_to_cust_name,
			  p_high_bill_to_cust_name,
			  p_low_gl_date,
  			  p_high_gl_date,
			  p_low_ship_date,
			  p_high_ship_date,
			  p_low_trans_number,
			  p_high_trans_number,
			  p_low_sales_order_num,
			  p_high_sales_order_num,
			  p_low_invoice_date,
			  p_high_invoice_date,
			  p_low_ship_to_cust_num,
  			  p_high_ship_to_cust_num,
			  p_low_ship_to_cust_name,
			  p_high_ship_to_cust_name,
			  p_call_from_master_flag,
			  p_base_due_date_on_trx_date,
			  p_due_date_adj_days,
			  l_org_id);

  END SUBMIT_REQUEST;

END JL_AR_AUTOINV_PKG;

/
