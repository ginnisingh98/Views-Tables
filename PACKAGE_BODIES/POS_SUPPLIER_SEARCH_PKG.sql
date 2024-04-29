--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_SEARCH_PKG" AS
-- $Header: POS_SUPPLIER_SEARCH_PKG.plb 120.0.12010000.8 2014/11/18 06:38:19 irasoolm noship $

FUNCTION generate_uda_xml(p_party_id IN NUMBER,
                           p_party_site_id IN NUMBER,
                           p_vendor_site_id IN NUMBER)
RETURN xmltype AS
  attr_xml xmltype;
  temp_xml xmltype;
  attr_grp_xml xmltype;
  attr_qry VARCHAR2(3000);
  attr_val VARCHAR2(100);
  isFirstAttr NUMBER := 1;
  isFirstGrp NUMBER := 1;
BEGIN

/*
Step 1
First FOR loop iterates through attribute groups in  pos_supp_prof_ext_b for a
given party id, party site id, supplier site id combination

ATTR_GROUP_ID is selected in each iteration
*/
FOR grps IN (SELECT pos.EXTENSION_ID, pos.party_id, pos.ATTR_GROUP_ID,
          grp.ATTR_GROUP_DISP_NAME, grp.attr_group_name
        FROM pos_supp_prof_ext_b pos,
        EGO_ATTR_GROUPS_V grp
        WHERE pos.party_id = p_party_id
        AND (p_party_site_id IS NULL
                OR To_Char(p_party_site_id) = To_Char(pos.pk1_value))
        AND (p_vendor_site_id IS NULL OR p_vendor_site_id = pos.pk2_value)
        AND pos.ATTR_GROUP_ID=grp.ATTR_GROUP_ID) LOOP
  print_log(' grp iteration ' || grps.attr_group_name );

  /*
  Step 2
  Second FOR loop iterates through attributes that are available
  for the above  ATTR_GROUP_ID

  For each attribute, database column name in pos_supp_prof_ext_b
  has to be found.
  Then this column has to be queried and value should be taken
  */

  FOR attrs IN (SELECT attr.DATABASE_COLUMN,
                attr.ATTR_DISPLAY_NAME, attr.ATTR_NAME
                FROM ego_attrs_v attr
                WHERE attr.ATTR_GROUP_NAME = grps.ATTR_GROUP_NAME) LOOP
    print_log(' attr iteration ' || attrs.ATTR_NAME);
    print_log(grps.EXTENSION_ID);
    print_log(grps.party_id);
    print_log(grps.ATTR_GROUP_ID);
    print_log(p_party_site_id);
    print_log(p_vendor_site_id);


    -- Step 3
    -- Query for the database column name where attribute is
    -- stored in pos_supp_prof_ext_b table
    attr_qry := 'select to_char('|| attrs.DATABASE_COLUMN ||
        ') from pos_supp_prof_ext_b pos
          where pos.extension_id = :extn_id
          and pos.party_id = :party_id
          and pos.attr_group_id = :grp_id
          AND ( :party_site_id IS NULL OR :party_site_id = pos.pk1_value)
          AND ( :vendor_site_id IS NULL OR :vendor_site_id = pos.pk2_value) ';
    EXECUTE IMMEDIATE attr_qry INTO attr_val
    USING grps.EXTENSION_ID,grps.party_id,grps.ATTR_GROUP_ID,
    p_party_site_id,p_party_site_id,p_vendor_site_id,p_vendor_site_id ;

    print_log('attr_val ' || attr_val);

    -- Step 4
    -- Form xml snippet for the attribute name and its value
    SELECT xmlelement(evalname attrs.ATTR_NAME,attr_val)
    INTO temp_xml
    FROM dual;
    print_log(temp_xml.getclobval());

    -- Step 5
    -- Concatenate xml for this attribute with other attributes in
    -- the same attribute group
    IF isFirstAttr =1 THEN
      SELECT temp_xml INTO attr_xml FROM dual;
    ELSE
      SELECT xmlconcat(attr_xml,temp_xml)
      INTO attr_xml FROM dual;
    END IF;

    isFirstAttr:=2;

  END LOOP;
  -- Step 6
  -- Concatenated XML is ready for all attributes for
  -- a particular attribute group

  isFirstAttr := 1;
  print_log('attr xml ' || attr_xml.getclobval());

    -- Step 7
    -- Concatenate XML for this attribute group with other attribute groups
    --for same supplier
    SELECT xmlelement(evalname grps.attr_group_name, attr_xml)
    INTO temp_xml FROM dual;

    IF isFirstGrp = 1 THEN
      SELECT temp_xml INTO attr_grp_xml FROM dual;
    ELSE
      SELECT xmlconcat(attr_grp_xml,temp_xml)
      INTO attr_grp_xml FROM dual;
    END IF;

    isFirstGrp := 2;

END LOOP;
-- Step 8
-- Final UDA XML is available for all attribute groups for given party,
-- party site, supplier site combination

RETURN attr_grp_xml;


END generate_uda_xml;

PROCEDURE index_supplier (p_all_suppliers IN VARCHAR2,
                          EFFBUF           OUT NOCOPY VARCHAR2,
                          RETCODE          OUT NOCOPY VARCHAR2) AS
  l_request_id NUMBER;
  l_result VARCHAR2(1);
  l_msg VARCHAR2(20);
  l_party_id ap_suppliers.party_id%TYPE;
  l_vendor_id ap_suppliers.vendor_id%TYPE;
  l_vendor_name ap_suppliers.vendor_name%TYPE;
  l_vendors vendor_tbl;
  l_curr_date TIMESTAMP;
  l_is_updated VARCHAR2(1);
BEGIN
  l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
  print_log('This is a concurrent program; Entered the procedure index_supplier '
              || ' for request id ' || l_request_id);

  l_curr_date := SYSDATE;

  IF ( p_all_suppliers = 'Yes' ) THEN
    SELECT vendor_id BULK COLLECT INTO l_vendors
    FROM ap_suppliers WHERE enabled_flag = 'Y';
  ELSE
    has_supplier_changed(l_vendors);
  END IF;

  IF (l_vendors IS NULL OR l_vendors.Count = 0) then
    print_log('No supplier is modified. Returning from the procedure. ');
    retcode := 0;
    RETURN;
  END IF;

  FOR i IN 1..l_vendors.count
  LOOP
    BEGIN

      SELECT party_id,vendor_name
      INTO l_party_id, l_vendor_name
      FROM ap_suppliers WHERE vendor_id = l_vendors(i);

      generate_supplier_xml(l_party_id, l_vendors(i),l_result,l_msg);
      l_is_updated := 'Y';

    EXCEPTION
    WHEN OTHERS THEN
      print_log('XML creation failed for  '
                  || l_vendor_name || ' ; vendor id ' || l_vendor_id);
        print_log('Exception ' || SQLCODE || ' ' || SQLERRM );
    END;

    IF l_result = 'Y' THEN
        print_log('XML created for  '
                    || l_vendor_name || ' ; vendor id ' || l_vendor_id);
    ELSE
        print_log('XML creation failed for  '
                    || l_vendor_name || ' ; vendor id ' || l_vendor_id);
    END IF;
  END LOOP; -- loop for all suppliers

  IF l_is_updated = 'Y' THEN
    print_log( ' XML created. Now updating built date and indexing');
    UPDATE POS_SUPPLIER_ENTITY_DATA SET xml_built_date = l_curr_date ;
    ad_ctx_ddl.sync_index(pos_supplier_search_index_pkg.getPosSchemaName || '.POS_SUPPLIER_SEARCH_INDEX');
    print_log('Index is synced up. ');
  END IF;

  print_log('Returning from the procedure. '  );

  RETCODE := '0';

EXCEPTION
WHEN OTHERS THEN
  RETCODE := '2';
  print_log('Exception ; ' || SQLERRM || ' ' || SQLCODE );

END index_supplier;


PROCEDURE generate_supplier_xml(p_party_id IN NUMBER,
                                p_vendor_id IN NUMBER,
                                x_result OUT NOCOPY VARCHAR2,
                                x_msg OUT NOCOPY VARCHAR2 ) AS
                                --x_supplier_xml IN OUT NOCOPY xmltype) AS
  vendor_xml xmltype;
  address_xml xmltype;
  contact_xml xmltype;
  class_xml xmltype;
  attr_xml xmltype;
  temp_xml xmltype;
  attr_grp_xml xmltype;
  prodserv_xml xmltype;
  bank_xml xmltype;
  tax_xml xmltype;
  attr_qry VARCHAR2(3000);
  attr_val VARCHAR2(100);
  isFirstAttr NUMBER := 1;
  isFirstGrp NUMBER := 1;
  supplier_tag VARCHAR2(30) := 'SUPPLIER';
  class_tag VARCHAR2(30) := 'BUSINESS_CLASSIFICATION_';
  xml_clob CLOB;
  l_offset number default 1;

  l_vendor_id NUMBER;
  l_party_id NUMBER;
  l_prodserv_desc VARCHAR2 (3000);
  l_prodserv_has_subcat VARCHAR2(1);
  vendor_name_exc EXCEPTION ;

BEGIN

   print_log('Entered  procedure generate_supplier_xml');
   print_log('vendor_id  ' || p_vendor_id || '; party_id ' || p_party_id);

-- Get XML for business classification
BEGIN

  FOR rec IN (SELECT CLASSIFICATION_ID FROM POS_BUS_CLASS_ATTR
              WHERE vendor_id = p_vendor_id) LOOP

    print_log('Get XML for business classification start for Vendor_Id '||p_vendor_id);

    SELECT
      xmlelement("CLASSIFICATION",
      xmlattributes(CLASSIFICATION_ID AS "ID"),
      xmlelement("EXT_ATTR_1", EXT_ATTR_1),
      xmlelement("CERTIFYING_AGENCY", CERTIFYING_AGENCY),
      xmlelement("CERTIFICATE_NUMBER", CERTIFICATE_NUMBER),
      xmlelement("STATUS", STATUS),
      xmlelement("CLASS_STATUS", CLASS_STATUS),
      xmlagg(xmlelement(evalname (class_tag || lang.LANGUAGE_code),
            lkup.meaning)))
      INTO temp_xml
      FROM
      POS_BUS_CLASS_ATTR class,
      fnd_lookup_values lkup,
      FND_LANGUAGES lang
      WHERE class.vendor_id = p_vendor_id
      AND CLASSIFICATION_ID = rec.CLASSIFICATION_ID
      AND lang.installed_flag <> 'D'
      AND lkup.LANGUAGE = lang.LANGUAGE_code
      AND lkup.lookup_type = class.LOOKUP_TYPE
      AND lkup.lookup_code = class.lookup_code
      GROUP BY CLASSIFICATION_ID,EXT_ATTR_1,CERTIFYING_AGENCY,CERTIFICATE_NUMBER,STATUS,CLASS_STATUS;

      print_log('Get XML for business classification end for Vendor_Id '||p_vendor_id);

      SELECT xmlconcat(class_xml,temp_xml) INTO class_xml FROM dual;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
    print_log('Exception at business classification; p_vendor_id' || p_vendor_id
                || SQLERRM || ' ' || SQLCODE );
END;

BEGIN
FOR rec IN
(SELECT prods.classification_id, prods.segment1, prods.status,
  pos_product_service_utl_pkg.get_concat_code(prods.classification_id)
    AS prodserv_code
  FROM pos_supplier_mappings maps,
  pos_sup_products_services prods
  WHERE maps.party_id = p_party_id
  AND prods.vendor_id = p_vendor_id)
LOOP

print_log('Get XML for product and services start for Vendor_Id '||p_vendor_id);

    pos_product_service_utl_pkg.get_desc_check_subcategory
          (rec.classification_id, l_prodserv_desc, l_prodserv_has_subcat);

    SELECT xmlelement("PRODUCTSERVICE",
          xmlattributes(rec.CLASSIFICATION_ID AS "ID"),
          xmlelement("PRODSERV_CODE",rec.prodserv_code),
          xmlelement("PRODSERV_DESC",l_prodserv_desc),
          xmlelement("STATUS",rec.STATUS))
    INTO temp_xml
    FROM dual;

    SELECT xmlconcat(prodserv_xml,temp_xml) INTO prodserv_xml FROM dual;

print_log('Get XML for product and services end for Vendor_Id '||p_vendor_id);

END LOOP;

EXCEPTION
  WHEN OTHERS THEN
  print_log('Exception at products and services ; p_vendor_id' || p_vendor_id
                || SQLERRM || ' ' || SQLCODE );
END;

BEGIN

print_log('Get XML for Bank details start for Vendor_Id '||p_vendor_id);

  FOR rec IN
  ( SELECT
    eb.masked_bank_account_num bank_ac_num,
    eb.masked_iban iban,
    eb.currency_code,
    bp.party_name bank_name,
    eb.start_date,
    eb.end_date,
    inst.payment_function,
    payee.PARTY_SITE_ID address_id,
    address.party_site_name address_name,
    payee.SUPPLIER_SITE_ID site_id,
    site.VENDOR_SITE_CODE site_code,
    payee.ORG_ID,
    payee.ORG_TYPE,
    ops.name org_name
  FROM IBY_EXT_BANK_ACCOUNTS eb,
  IBY_PMT_INSTR_USES_ALL inst,
  IBY_EXTERNAL_PAYEES_ALL payee,
  hz_parties bp,
  hz_party_sites address,
  ap_supplier_sites_all site,
  hr_operating_units ops
  WHERE payee.payee_party_id = p_party_id
  AND payee.EXT_PAYEE_ID = inst.EXT_PMT_PARTY_ID
  AND inst.instrument_id = eb.ext_bank_account_id
    AND inst.instrument_type = 'BANKACCOUNT'
    AND eb.bank_id = bp.party_id (+)
    AND payee.PARTY_SITE_ID = address.PARTY_SITE_ID (+)
    AND payee.SUPPLIER_SITE_ID= site.vendor_site_id (+)
    AND payee.org_id = ops.organizatioN_id (+) )  LOOP

    SELECT xmlelement("BANK",
            xmlelement("BANK_ACCOUNT_NUM",rec.bank_ac_num),
            xmlelement("IBAN",rec.iban),
            xmlelement("CURRENCY",rec.currency_code),
            xmlelement("BANK_NAME",rec.bank_name),
            xmlelement("START_DATE",rec.start_date),
            xmlelement("END_DATE",rec.end_date),
            xmlelement("ADDRESS_NAME",rec.address_name),
            xmlelement("SITE_CODE",rec.site_code),
            xmlelement("ORG_NAME",rec.org_name))
      INTO temp_xml
      FROM dual;
      SELECT xmlconcat(bank_xml,temp_xml) INTO bank_xml FROM dual;

  END LOOP;



print_log('Get XML for Bank details end for Vendor_Id '||p_vendor_id);

EXCEPTION
WHEN OTHERS THEN
  print_log('Exception at banking;  p_vendor_id' || p_vendor_id
                || SQLERRM || ' ' || SQLCODE );
END;

BEGIN

  select xmlelement("TAX_DETAILS",
          xmlelement("TAX_REPORTING_NAME",aps.TAX_REPORTING_NAME),
          --xmlelement("TAX_TYPE", aptt.income_tax_type),
          xmlelement("TAXPAYER_ID", decode(upper(aps.vendor_type_lookup_code),
                'EMPLOYEE', papf.national_identifier,
                decode(aps.organization_type_lookup_code,
                        'INDIVIDUAL',aps.individual_1099,
                        'FOREIGN INDIVIDUAL',aps.individual_1099,
                        hp.jgzz_fiscal_code))) ,
          xmlelement("TAX_COUNTRY", tax.COUNTRY_CODE),
          xmlelement("TAX_REG_TYPE",tax.REGISTRATION_TYPE_CODE),
          xmlelement("TAX_REG_NUM",tax.REP_REGISTRATION_NUMBER))
  INTO tax_xml
  from ap_suppliers aps,
  hz_parties hp ,
  per_all_people_f papf,
  ZX_PARTY_TAX_PROFILE tax
  WHERE aps.vendor_id =  p_vendor_id
  AND aps.party_id = hp.party_id
  AND aps.employee_id = papf.person_id (+)
  AND aps.party_id = tax.party_id (+) ;

EXCEPTION
WHEN OTHERS THEN
  print_log('Exception at taxing; p_vendor_id' || p_vendor_id
                || SQLERRM || ' ' || SQLCODE );
END;



-- XML for Party site.
-- Supplie site xml will be part of this.
BEGIN
SELECT xmlagg
(--xmlelement("ADDRESSES",
--xmlattributes(hps.party_id AS "ID"),
xmlelement("ADDRESS",
    xmlattributes(hps.party_site_id AS "ID"),
    xmlelement("NAME",hps.party_site_name),
    xmlelement("ADDRESS1",hl.address1),
    xmlelement("ADDRESS2",hl.address2),
    xmlelement("CITY",hl.city),
    xmlelement("COUNTRY",hl.country),
    xmlelement("PARTY_SITE_UDA",
      xmlattributes(hps.party_site_id AS "ID"),
      generate_uda_xml(p_party_id,hps.party_site_id,null)),  -- party site uda
    (SELECT xmlagg
        (xmlelement("SITE",
            xmlattributes(apss.vendor_site_id AS "ID"),
            xmlelement("SITE_CODE",apss.VENDOR_SITE_CODE),
            xmlelement("SHIP_TO",apss.ship_to_location_id),
            xmlelement("BILL_TO",apss.bill_to_location_id),
            xmlelement("ORG",ou.name),
            xmlelement("PURCHASING_SITE_FLAG",
                      Decode(apss.PURCHASING_SITE_FLAG,'Y','Yes','No')),
            xmlelement("RFQ_ONLY_SITE_FLAG",
                      Decode(apss.RFQ_ONLY_SITE_FLAG,'Y','Yes','No')),
            xmlelement("PAY_SITE_FLAG",
                      Decode(apss.PAY_SITE_FLAG,'Y','Yes','No')),
            xmlelement("PAYMENT_CURRENCY_CODE",apss.PAYMENT_CURRENCY_CODE),
            xmlelement("HOLD_ALL_PAYMENTS_FLAG",
                      Decode(apss.HOLD_ALL_PAYMENTS_FLAG,'Y','Yes','No')),
            xmlelement("HOLD_FUTURE_PAYMENTS_FLAG",
                      Decode(apss.HOLD_FUTURE_PAYMENTS_FLAG,'Y','Yes','No')),
            xmlelement("HOLD_UNMATCHED_INVOICES_FLAG",
                      Decode(apss.HOLD_UNMATCHED_INVOICES_FLAG,'Y','Yes','No')),
            xmlelement("TAX_REPORTING_SITE_FLAG",
                      Decode(apss.TAX_REPORTING_SITE_FLAG,'Y','Yes','No')),
            xmlelement("SUPPLIER_SITE_UDA",
                      generate_uda_xml(p_party_id,hps.party_site_id,
                                        apss.vendor_site_id))
            ))
            -- supplier site uda
    FROM ap_supplier_sites_all apss, hr_operating_units ou
    WHERE party_site_id = hps.party_site_id
    AND apss.org_id = ou.ORGANIZATION_ID)))--)
  INTO address_xml
  FROM hz_party_sites hps,
  hz_locations hl
  WHERE hps.party_id= p_party_id
  AND hps.location_id = hl.location_id;
EXCEPTION
WHEN OTHERS THEN
  print_log('Exception at address and sites ; p_vendor_id' || p_vendor_id
                || SQLERRM || ' ' || SQLCODE );
END;

-- XML for contacts
BEGIN

print_log('Get XML for Contact details start for Vendor_Id '||p_vendor_id);


  SELECT xmlAgg
          (xmlelement
            ("CONTACT",
              xmlattributes(HPC.party_id AS "ID"),
            xmlelement("NAME", hpc.party_name),
            xmlelement("EMAIL",hcpe.EMAIL_ADDRESS),
            xmlelement("PHONE_AREA_CODE",hcpp.PHONE_AREA_CODE),
            xmlelement("PHONE_NUMBER",hcpp.PHONE_NUMBER),
            xmlelement("PHONE_EXT",hcpp.PHONE_EXTENSION),
            xmlelement("FAX_AREA_CODE",hcpf.PHONE_AREA_CODE),
            xmlelement("FAX_NUMBER",hcpf.PHONE_NUMBER),
            xmlelement("ALT_NAME",hpc.known_as),
            xmlelement("ALT_AREA_CODE",hcppa.phone_area_code),
            xmlelement("ALT_NUMBER",hcppa.phone_number),
            xmlelement("URL",hcppw.url)))
  INTO  contact_xml
  from Hz_parties hpc, HZ_CONTACT_POINTS hcpp, HZ_CONTACT_POINTS hcpf, HZ_CONTACT_POINTS hcpe, HZ_RELATIONSHIPS hr,
  hz_contact_points hcppa, hz_contact_points hcppw
  where hr.subject_id = p_party_id
  AND hcpp.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
  And hcpp.OWNER_TABLE_ID(+) = hr.PARTY_ID
  And hcpp.PHONE_LINE_TYPE(+) = 'GEN'
  And hcpp.CONTACT_POINT_TYPE(+) = 'PHONE'
  And hcpf.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
  And hcpf.OWNER_TABLE_ID(+) = hr.PARTY_ID
  And hcpf.PHONE_LINE_TYPE(+) = 'FAX'
  And hcpf.CONTACT_POINT_TYPE(+) = 'PHONE'
  And hcpe.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
  and hcpe.OWNER_TABLE_ID(+) = hr.PARTY_ID
  And hcpe.CONTACT_POINT_TYPE(+) = 'EMAIL'
  and hcppw.owner_table_id(+) = hr.party_id
  and hcppw.owner_table_name(+) = 'HZ_PARTIES'
  and hcppw.status(+) = 'A'
  and hcppw.contact_point_type(+) = 'WEB'
  and hcppa.owner_table_id(+) = hr.party_id
  and hcppa.owner_table_name(+) = 'HZ_PARTIES'
  and hcppa.status(+) = 'A'
  and hcppa.contact_point_type(+) = 'PHONE'
  and hcppa.phone_line_type (+) = 'GEN'
  and hcppa.primary_flag (+) = 'N'
  and hr.object_id = hpc.party_id
  and hr.subject_Type = 'ORGANIZATION'
  and hr.subject_table_name = 'HZ_PARTIES'
  and hr.object_table_name = 'HZ_PARTIES'
  and hr.object_Type = 'PERSON'
  and hr.relationship_code = 'CONTACT'
  and hr.directional_flag = 'B'
  and hr.RELATIONSHIP_TYPE = 'CONTACT'
  AND hcpe.status (+) = 'A'
  AND hcpe.primary_flag(+)='Y'
  AND hcpp.status (+) = 'A'
  AND hcpp.primary_flag(+)='Y'
  AND hcpf.status (+) = 'A';

print_log('Get XML for Contact details end for Vendor_Id '||p_vendor_id);


EXCEPTION
WHEN OTHERS THEN
  print_log('Exception at contacts; p_vendor_id' || p_vendor_id
                || SQLERRM || ' ' || SQLCODE );
END;
/*
-- XML for contact points
BEGIN
  SELECT xmlagg(
  xmlelement("CONTACT_POINT",
  xmlattributes(contact_point_id AS "ID"),
  xmlelement("CONTACT_POINT_TYPE",CONTACT_POINT_TYPE ),
  xmlelement("EMAIL_ADDRESS", email_address),
  xmlelement("PHONE_NUMBER", phone_number),
  xmlelement("RAW_PHONE_NUMBER", raw_phone_number),
  xmlelement("TRANSPOSED_PHONE_NUMBER", transposed_phone_number),
  xmlelement("URL", url)))
  INTO cp_xml
  FROM hz_contact_points
  WHERE OWNER_TABLE_NAME='HZ_PARTIES' AND OWNER_TABLE_ID = p_party_id ;
EXCEPTION
WHEN OTHERS THEN
  print_log('Exception at contact points; p_vendor_id' || p_vendor_id
                || SQLERRM || ' ' || SQLCODE );
END;
*/


-- Main supplier XML with other children built above embedded in it
BEGIN
  SELECT xmlelement
    ( "SUPPLIER" ,
      xmlattributes(aps.vendor_id AS "ID"),
      xmlelement("SUPPLIER_NAME",aps.vendor_name),
      xmlelement("SUPPLIER_NUMBER",aps.segment1),
      xmlelement("ALT_SUPPLIER_NAME",aps.vendor_name_alt),
      xmlelement("CUSTOMER_NUMBER",aps.CUSTOMER_NUM),
      xmlelement("ONE_TIME_FLAG",aps.one_time_flag),
      xmlelement("PARENT_VENDOR_ID",APS.PARENT_VENDOR_ID),
      xmlelement("NATIONAL_INSURANCE_NUM",decode(aps.NI_NUMBER,NULL,'')),
      xmlelement("STANDARD_INDUSTRY_CLASS",decode(aps.STANDARD_INDUSTRY_CLASS,
                                                   null,'')),
      xmlelement("INACTIVE_DATE",aps.END_DATE_ACTIVE),
      xmlelement("VENDOR_ENABLED", Decode(aps.enabled_flag,'Y','Yes','No')),
      xmlelement("VENDOR_TYPE", ven.displayed_field),
      xmlelement("SHIP_TO",(SELECT location_code FROM hr_locations_all
                            WHERE location_id = aps.ship_to_location_id)),
      xmlelement("BILL_TO",(SELECT location_code FROM hr_locations_all
                            WHERE location_id = aps.bill_to_location_id)),
      xmlelement("ONE_TIME_VENDOR", Decode(aps.ONE_TIME_FLAG,'Y','Yes','No')),
      xmlelement("SHIP_VIA_LOOKUP_CODE",aps.SHIP_VIA_LOOKUP_CODE),
      xmlelement("FREIGHT_TERMS_LOOKUP_CODE",aps.FREIGHT_TERMS_LOOKUP_CODE),
      xmlelement("FOB_LOOKUP_CODE", aps.FOB_LOOKUP_CODE),
      xmlelement("TERMS_ID",aps.TERMS_ID),
      xmlelement("SET_OF_BOOKS_ID",aps.SET_OF_BOOKS_ID),
      xmlelement("INVOICE_CURRENCY_CODE",aps.INVOICE_CURRENCY_CODE),
      xmlelement("PAYMENT_CURRENCY_CODE",aps.PAYMENT_CURRENCY_CODE),
      xmlelement("HOLD_ALL_PAYMENTS_FLAG", Decode(aps.HOLD_ALL_PAYMENTS_FLAG,
                                              'Y','Yes','No')),
      xmlelement("HOLD_FUTURE_PAYMENTS_FLAG",
                        Decode(aps.HOLD_FUTURE_PAYMENTS_FLAG,'Y','Yes','No')),
      xmlelement("ORGANIZATION_TYPE_LOOKUP_CODE",
                        aps.ORGANIZATION_TYPE_LOOKUP_CODE),
      xmlelement("IS_SUPP_CCR",
        Decode( pos_util_pkg.IS_SUPP_CCR(1.0,'T',p_vendor_id),'T','Yes','No')),
      xmlelement("DUNS_NUMBER",org.DUNS_NUMBER_C),
      xmlelement("CEO_NAME",org.ceo_name),
      xmlelement("CEO_TITLE",org.ceo_title),
      xmlelement("PRINCIPAL_NAME",org.principal_name),
      xmlelement("PRINCIPAL_TITLE",org.principal_title),
      xmlelement("BUSINESS_CLASSIFICATIONS",class_xml),
      tax_xml,
      xmlelement("BANK_ACCOUNTS",bank_xml),
      xmlelement("PRODUCT_SERVICES",prodserv_xml),
      xmlelement("ADDRESSES",address_xml) ,
      xmlelement("CONTACTS",contact_xml),
      xmlelement("SUPPLIER_UDA",generate_uda_xml(p_party_id, NULL,null))
      )
  INTO vendor_xml
  FROM ap_suppliers aps,
  po_lookup_codes ven,
  HZ_ORGANIZATION_PROFILES org
  WHERE aps.vendor_id = p_vendor_id
  AND ven.lookup_type(+) = 'VENDOR TYPE'
  AND ven.LOOKUP_CODE(+) = aps.vendor_type_lookup_code
  AND org.party_id(+) = aps.party_id
  AND org.effective_end_date IS NULL ;
EXCEPTION
WHEN OTHERS THEN
  print_log('Exception at main xml ;  p_vendor_id' || p_vendor_id
                || SQLERRM || ' ' || SQLCODE );
END;

  print_log('XML is built ; ');

  print_log('Updating POS_SUPPLIER_ENTITY_DATA Start for Vendor_Id '||p_vendor_id);


  UPDATE POS_SUPPLIER_ENTITY_DATA
  SET entity_data = vendor_xml.getclobval(),
    last_update_date = SYSDATE,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.login_id
  WHERE entity_id = p_vendor_id;

  print_log('Updating POS_SUPPLIER_ENTITY_DATA End for Vendor_Id '||p_vendor_id);

  IF SQL%ROWCOUNT = 0  THEN

  print_log('Inserting POS_SUPPLIER_ENTITY_DATA Start for Vendor_Id '||p_vendor_id);

    INSERT INTO POS_SUPPLIER_ENTITY_DATA
    (
     entity_name,
     entity_id,
     entity_data,
     xml_built_date,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login
    )
    VALUES ('VENDOR',p_vendor_id,vendor_xml.getclobval(),null,SYSDATE,fnd_global.user_id,
            SYSDATE,fnd_global.user_id,fnd_global.login_id);

  print_log('Inserting POS_SUPPLIER_ENTITY_DATA End for Vendor_Id '||p_vendor_id);

  END IF;

  COMMIT;
  x_result := 'Y';

EXCEPTION
WHEN OTHERS THEN
  print_log('Exception at main xml ;  p_vendor_id' || p_vendor_id
                || SQLERRM || ' ' || SQLCODE );
  ROLLBACK;
  RAISE;

END generate_supplier_xml;


PROCEDURE search_supplier ( p_keyword IN VARCHAR2,
                            x_record_found IN OUT NOCOPY VARCHAR2,
                            x_search_string IN OUT NOCOPY VARCHAR2 )  IS
searchTokens     typTokenTab;
searchCondition VARCHAR2 (2000);

BEGIN

    x_record_found := 'Y';

    searchTokens := creTokenList( p_keyword, '+');

    IF (searchTokens IS NULL OR searchTokens.Count = 0) THEN
      x_search_string := '1=2';
      RETURN;
    END IF;

    searchCondition := '?(';
    FOR indx IN 1..searchTokens.Count LOOP
      searchCondition := searchCondition || ' (%' || Trim(searchTokens(indx)) || '%) AND' ;
    END LOOP;
    searchCondition := SubStr(searchCondition,1, Length(searchCondition) - 3);
    searchCondition := searchCondition || ' )';

    x_search_string := ' vendor_id in (select entity_id from pos_supplier_entity_data s
                                           where contains(s.entity_data, '''|| searchCondition ||''' ) >0)';


EXCEPTION
WHEN OTHERS THEN
  print_log(SQLERRM || SQLCODE );
  x_record_found := 'N';
  RAISE;
END search_supplier;

FUNCTION creTokenList(pLine IN VARCHAR2, pDelimiter IN VARCHAR2) RETURN typTokenTab IS
  sLine       VARCHAR2(2000);
  nPos        INTEGER;
  nPosOld     INTEGER;
  nIndex      INTEGER;
  nLength     INTEGER;
  nCnt       INTEGER;
  sToken     VARCHAR2(200);
  tTokenTab  typTokenTab;
BEGIN
    sLine := pLine;
    IF (SUBSTR(sLine, LENGTH(sLine), 1) <> '|') THEN
        sLine := sLine || '|';
    END IF;

    nPos := 0;
    sToken := '';
    nLength := LENGTH(sLine);
    nCnt := 0;

    nindex := 1;
    FOR nIndex IN 1..nLength LOOP
        IF ((SUBSTR(sLine, nIndex, 1) = pDelimiter) OR (nIndex = nLength)) THEN
            nPosOld := nPos;
            nPos := nIndex;
            nCnt := nCnt + 1;
            sToken := SUBSTR(sLine, nPosOld + 1, nPos - nPosOld - 1);

            tTokenTab(nCnt) := sToken;
        END IF;
    END LOOP;

    RETURN tTokenTab;
END creTokenList;

PROCEDURE has_supplier_changed(vendors IN OUT NOCOPY vendor_tbl)
AS
  supp_change_time TIMESTAMP;
  l_last_xml_modified TIMESTAMP;
  vendor NUMBER ;

  CURSOR c1 (p_xml_last_modified TIMESTAMP ) IS
     SELECT vendor_id
   FROM ap_suppliers aps
  WHERE Nvl(aps.last_update_date,aps.creation_date) >  p_xml_last_modified
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps
  WHERE EXISTS (SELECT 1 FROM ap_supplier_sites_all apss
                WHERE aps.vendor_id = apss.vendor_id
                and Nvl(apss.last_update_date,apss.creation_date)> p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps
  WHERE EXISTS (SELECT 1 FROM hz_party_sites hps
                WHERE aps.party_id = hps.party_id
                AND  Nvl(hps.last_update_date,hps.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps, hz_relationships hr
  WHERE aps.party_id = hr.subject_id
  AND hr.subject_Type = 'ORGANIZATION'
  AND hr.subject_table_name = 'HZ_PARTIES'
  AND hr.RELATIONSHIP_CODE  = 'CONTACT'
  AND EXISTS (SELECT 1 FROM hz_parties hp
              WHERE hp.party_id = hr.object_id
              AND hp.party_type = 'PERSON'
              AND  Nvl(hp.last_update_date,hp.creation_date) > p_xml_last_modified)

  UNION
  SELECT vendor_id
  FROM ap_suppliers aps, hz_relationships hr
  WHERE aps.party_id = hr.subject_id
  AND hr.subject_Type = 'ORGANIZATION'
  AND hr.subject_table_name = 'HZ_PARTIES'
  AND hr.RELATIONSHIP_CODE  = 'CONTACT'
  AND EXISTS (SELECT 1 FROM hz_contact_points cp
              WHERE cp.owner_table_id = hr.party_id
              AND  Nvl(cp.last_update_date,cp.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps
  WHERE EXISTS (SELECT 1 FROM POS_BUS_CLASS_ATTR class
                WHERE class.vendor_id = aps.vendor_id
                AND  Nvl(class.last_update_date,class.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps
  WHERE EXISTS (SELECT 1 FROM pos_sup_products_services prods
                WHERE prods.vendor_id = aps.vendor_id
                AND  Nvl(prods.last_update_date,prods.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps
  WHERE EXISTS (SELECT 1 FROM IBY_EXTERNAL_PAYEES_ALL payee
                WHERE payee.payee_party_id = aps.party_id
                AND  Nvl(payee.last_update_date,payee.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps,IBY_EXTERNAL_PAYEES_ALL payee
  WHERE payee.payee_party_id = aps.party_id
  AND EXISTS (SELECT 1 FROM IBY_PMT_INSTR_USES_ALL inst
                WHERE inst.EXT_PMT_PARTY_ID = payee.ext_payee_id
                AND inst.instrument_type = 'BANKACCOUNT'
                AND  Nvl(inst.last_update_date,inst.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps,IBY_EXTERNAL_PAYEES_ALL payee, IBY_PMT_INSTR_USES_ALL inst
  WHERE payee.payee_party_id = aps.party_id
  AND inst.EXT_PMT_PARTY_ID = payee.ext_payee_id
  AND inst.instrument_type = 'BANKACCOUNT'
  AND EXISTS (SELECT 1 FROM IBY_EXT_BANK_ACCOUNTS eb
                WHERE eb.ext_bank_account_id = inst.instrument_id
                AND  Nvl(inst.last_update_date,inst.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps
  WHERE EXISTS (SELECT 1 FROM per_all_people_f papf
                WHERE aps.employee_id = papf.person_id
                AND  Nvl(papf.last_update_date,papf.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps
  WHERE EXISTS (SELECT 1 FROM ZX_PARTY_TAX_PROFILE tax
                WHERE aps.party_id = tax.party_id
                AND  Nvl(tax.last_update_date,tax.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps
  WHERE EXISTS (SELECT 1 FROM pos_supp_prof_ext_b uda
                WHERE uda.party_id = aps.party_id
                AND  Nvl(uda.last_update_date,uda.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps, pos_supp_prof_ext_b uda
  WHERE uda.party_id = aps.party_id
  AND EXISTS (SELECT 1 FROM EGO_FND_DSC_FLX_CTX_EXT fl_ctx_ext
              WHERE fl_ctx_ext.ATTR_GROUP_ID=uda.ATTR_GROUP_ID
              AND  Nvl(fl_ctx_ext.last_update_date,fl_ctx_ext.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps, pos_supp_prof_ext_b uda, EGO_FND_DSC_FLX_CTX_EXT fl_ctx_ext
  WHERE uda.party_id = aps.party_id
  AND fl_ctx_ext.ATTR_GROUP_ID=uda.ATTR_GROUP_ID
  AND EXISTS (SELECT 1 FROM FND_DESCR_FLEX_CONTEXTS_TL FL_CTX_tl
              WHERE fl_ctx_tl.DESCRIPTIVE_FLEX_CONTEXT_CODE = fl_ctx_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE
              AND  Nvl(FL_CTX_tl.last_update_date,FL_CTX_tl.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps, pos_supp_prof_ext_b uda, EGO_FND_DSC_FLX_CTX_EXT fl_ctx_ext
  WHERE uda.party_id = aps.party_id
  AND fl_ctx_ext.ATTR_GROUP_ID=uda.ATTR_GROUP_ID
  AND EXISTS (SELECT 1 FROM FND_DESCR_FLEX_COLUMN_USAGES fl_col
              WHERE fl_col.DESCRIPTIVE_FLEX_CONTEXT_CODE = fl_ctx_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE
              AND  Nvl(fl_col.last_update_date,fl_col.creation_date) > p_xml_last_modified)
  UNION
  SELECT vendor_id
  FROM ap_suppliers aps, pos_supp_prof_ext_b uda, EGO_FND_DSC_FLX_CTX_EXT fl_ctx_ext
  WHERE uda.party_id = aps.party_id
  AND fl_ctx_ext.ATTR_GROUP_ID=uda.ATTR_GROUP_ID
  AND EXISTS (SELECT 1 FROM FND_DESCR_FLEX_COL_USAGE_TL fl_col_tl
              WHERE fl_col_tl.DESCRIPTIVE_FLEX_CONTEXT_CODE = fl_ctx_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE
              AND  Nvl(fl_col_tl.last_update_date,fl_col_tl.creation_date) > p_xml_last_modified)

  UNION
  SELECT vendor_id
  FROM ap_suppliers aps
  WHERE EXISTS (SELECT 1 FROM po_lookup_codes lkup
                WHERE lkup.LOOKUP_CODE = aps.vendor_type_lookup_code
                AND lkup.lookup_type = 'VENDOR TYPE'
                AND  Nvl(lkup.last_update_date,lkup.creation_date) > p_xml_last_modified)
  UNION
  SELECT aps.vendor_id
  FROM ap_suppliers aps,POS_BUS_CLASS_ATTR class
  WHERE class.vendor_id = aps.vendor_id
  AND EXISTS (SELECT 1 FROM fnd_lookup_values lkup
              WHERE lkup.lookup_code = class.lookup_code
              AND lkup.lookup_type = class.LOOKUP_TYPE
              AND  Nvl(lkup.last_update_date,lkup.creation_date) > p_xml_last_modified)
  ;

BEGIN
  print_log('Entered  procedure has_supplier_changed');
  SELECT Max(xml_built_date)
  INTO  l_last_xml_modified
          FROM POS_SUPPLIER_ENTITY_DATA ;
  print_log('p_xml_last_modified ' || l_last_xml_modified);

  IF l_last_xml_modified IS NULL THEN
    SELECT vendor_id BULK COLLECT INTO vendors
    FROM ap_suppliers WHERE enabled_flag = 'Y';
  ELSE
    OPEN c1(l_last_xml_modified);
      LOOP
      FETCH c1 BULK COLLECT INTO vendors;
      EXIT WHEN c1%NOTFOUND;
      END LOOP;
      CLOSE c1;

  END IF;

  print_log('Vendors to be updated are : ');
  FOR i IN 1..vendors.count LOOP
      print_log(vendors(i));
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
  NULL;

END has_supplier_changed;

PROCEDURE print_log
  (
    p_message IN VARCHAR2 )
IS

BEGIN
  IF(g_fnd_debug                = 'Y') THEN
    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level  => FND_LOG.level_statement, module => g_module_prefix, MESSAGE => p_message);
    END IF;
  END IF;
END print_log;

END pos_supplier_search_pkg;

/
