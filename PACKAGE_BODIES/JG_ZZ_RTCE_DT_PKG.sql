--------------------------------------------------------
--  DDL for Package Body JG_ZZ_RTCE_DT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_RTCE_DT_PKG" AS
/* $Header: jgzztoarntrlb.pls 120.10.12010000.2 2008/08/04 13:57:18 vgadde ship $*/

function BeforeReport return boolean is

    CURSOR c_get_le_and_period_dates
    IS
    SELECT  nvl(cfg.legal_entity_id,cfgd.legal_entity_id)
           ,nvl(cfg.tax_registration_number,cfgd.tax_registration_number) repent_trn
           ,min(glp.start_date)
           ,max(glp.end_date)
    FROM   jg_zz_vat_rep_entities cfg
          ,jg_zz_vat_rep_entities cfgd
          ,gl_periods             glp
    WHERE cfg.vat_reporting_entity_id          =  P_REPORTING_ENTITY_ID
    AND   ((     cfg.entity_type_code          = 'ACCOUNTING'
             AND cfg.mapping_vat_rep_entity_id = cfgd.vat_reporting_entity_id)
             OR
             (    cfg.entity_type_code         = 'LEGAL'
              AND cfg.vat_reporting_entity_id  = cfgd.vat_reporting_entity_id))
    AND    glp.period_set_name                 = nvl(cfg.tax_calendar_name,cfgd.tax_calendar_name)
    AND    glp.period_year                     = P_FISCAL_YEAR
    GROUP BY nvl(cfg.legal_entity_id,cfgd.legal_entity_id),
             nvl(cfg.tax_registration_number,cfgd.tax_registration_number);

    CURSOR c_currency_tax_reg_num
    IS
    SELECT gllev.currency_code
          ,arsp.tax_registration_number
    FROM   gl_ledger_le_v       gllev
          ,ar_system_parameters arsp
    WHERE  gllev.legal_entity_id       =  gn_legal_entity_id
    AND    arsp.set_of_books_id        =  gllev.ledger_id
    AND    gllev.ledger_category_code  =  'PRIMARY';

    /* Modified the cursor for bug#5199499 */
    CURSOR c_get_rep_entity_info
    IS
    SELECT  xfpiv.registration_number
          , xfpiv.name
          , xfpiv.address_line_1
          , xfpiv.address_line_2
          , xfpiv.address_line_3
          , xfpiv.town_or_city
          , xfpiv.postal_code
          , xfpiv.country
          , NULL  phone_number
          , xle_auth.city tax_office_location
          , xle_auth.address2 tax_office_number
          , xle_auth.address3 tax_office_code
          , xle_reg.issuing_authority_id
          , xle_auth.party_id
    FROM  xle_firstparty_information_v xfpiv
        , xle_registrations xle_reg
--        , hz_parties hzp   -- Bug 5522964
        , xle_legalauth_v xle_auth
    WHERE xle_reg.source_id          = xfpiv.legal_entity_id
    AND   xle_reg.source_table       = 'XLE_ENTITY_PROFILES'
    AND   xle_auth.legalauth_id (+)  = xle_reg.issuing_authority_id
    AND   xle_reg.identifying_flag   = 'Y'
    AND   xfpiv.legislative_cat_code = 'INCOME_TAX'
    AND   xfpiv.legal_entity_id      = gn_legal_entity_id;
--    AND   hzp.party_id               = xle_auth.party_id ;   -- Bug 5522964

    CURSOR c_generic_ar_inv_lines
    IS
    SELECT   ract.customer_trx_id
            ,ract.cust_trx_type_id
            ,ract.trx_number
            ,ract.trx_date
            ,ract.sold_to_customer_id
            ,ract.bill_to_customer_id
            ,ract.exchange_rate
            ,ract.printing_original_date
            ,ract.previous_customer_trx_id
            ,ract.complete_flag
            ,ractl.customer_trx_line_id
            ,ractl.line_number
            ,ractl.line_type
            ,ractl.link_to_cust_trx_line_id
            ,ractl.extended_amount
            ,ractl.vat_tax_id
            ,sum(racgd.acctd_amount) acctd_amount
            ,sum(racgd.amount) amount
    FROM     ra_customer_trx          ract
            ,ra_customer_trx_lines    ractl
            ,ra_cust_trx_line_gl_dist racgd
            ,jg_zz_vat_rep_entities   repent
    WHERE repent.vat_reporting_entity_id = P_REPORTING_ENTITY_ID
    AND  (( repent.entity_type_code = 'LEGAL'      AND
            ract.legal_entity_id = gn_legal_entity_id )
           OR
          ( repent.entity_type_code = 'ACCOUNTING' AND
            repent.entity_level_code = 'LEDGER'    AND
            ract.set_of_books_id = gv_ledger_id )
           OR
          ( repent.entity_type_code = 'ACCOUNTING' AND
            repent.entity_level_code = 'BSV'       AND
            ract.set_of_books_id = gv_ledger_id    AND
            get_bsv(racgd.code_combination_id) = gv_balancing_segment_value ))
    AND     racgd.customer_trx_line_id = ractl.customer_trx_line_id
    AND     racgd.customer_trx_id      = ractl.customer_trx_id
    AND     ractl.customer_trx_id      = ract.customer_trx_id
    GROUP BY ract.customer_trx_id
            ,ract.cust_trx_type_id
            ,ract.trx_number
            ,ract.trx_date
            ,ract.sold_to_customer_id
            ,ract.bill_to_customer_id
            ,ract.exchange_rate
            ,ract.printing_original_date
            ,ract.previous_customer_trx_id
            ,ract.complete_flag
            ,ractl.customer_trx_line_id
            ,ractl.line_number
            ,ractl.line_type
            ,ractl.link_to_cust_trx_line_id
            ,ractl.extended_amount
            ,ractl.vat_tax_id ;

   CURSOR entity_details
   IS
   SELECT  repent.ledger_id
          ,repent.balancing_segment_value
          ,gl.chart_of_accounts_id
   FROM    jg_zz_vat_rep_entities repent
          ,gl_ledgers gl
   WHERE  vat_reporting_entity_id = P_REPORTING_ENTITY_ID AND
          gl.ledger_id            = repent.ledger_id;

   lv_count NUMBER default 0 ;
   ln_party_id NUMBER ;
   p_debug_flag VARCHAR2(1) default 'Y' ;
   lv_party_id NUMBER(15);
   lv_issuing_authority_id NUMBER(15);

begin

fnd_file.put_line ( fnd_file.log, 'In main' );

    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Inside BeforeReport Trigger');
      fnd_file.put_line(fnd_file.log,'p_reporting_entity_id   : ' || P_REPORTING_ENTITY_ID);
      fnd_file.put_line(fnd_file.log,'p_fiscal_year           : ' || P_FISCAL_YEAR);
      fnd_file.put_line(fnd_file.log,'p_dec_type              : ' || P_DEC_TYPE);
      fnd_file.put_line(fnd_file.log,'p_min_inv_amt           : ' || P_MIN_INV_AMT);
      fnd_file.put_line(fnd_file.log,'p_called_from           : ' || P_CALLED_FROM);
      fnd_file.put_line(fnd_file.log,'$Profile$.ORG_ID        : ' || fnd_profile.value('ORG_ID'));
    END IF ;

    OPEN  c_get_le_and_period_dates ;
    FETCH c_get_le_and_period_dates INTO gn_legal_entity_id
                                        ,gv_repent_trn
                                        ,gd_period_start_date
                                        ,gd_period_end_date ;
    CLOSE c_get_le_and_period_dates ;

fnd_file.put_line ( fnd_file.log, gn_legal_entity_id || ' : ' || gv_repent_trn || ' : ' || gd_period_start_date || ' : ' || gd_period_end_date );

    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'gn_legal_entity_id      : ' ||gn_legal_entity_id);
      fnd_file.put_line(fnd_file.log,'gv_repent_trn           : ' ||gv_repent_trn);
      fnd_file.put_line(fnd_file.log,'gd_period_start_date    : ' ||gd_period_start_date);
      fnd_file.put_line(fnd_file.log,'gd_period_end_date      : ' ||gd_period_end_date);
    END IF ;

    OPEN  c_get_rep_entity_info;
    FETCH c_get_rep_entity_info INTO gv_repent_id_number
                                    ,gv_repent_name
                                    ,gv_repent_address_line_1
                                    ,gv_repent_address_line_2
                                    ,gv_repent_address_line_3
                                    ,gv_repent_town_or_city
                                    ,gv_repent_postal_code
                                    ,gv_country
                                    ,gv_repent_phone_number
                                    ,gv_tax_office_location
                                    ,gv_tax_office_number
                                    ,gv_tax_office_code
                                    ,lv_issuing_authority_id
                                    ,lv_party_id;
    CLOSE c_get_rep_entity_info;

    IF lv_issuing_authority_id IS NOT NULL THEN
        SELECT hzp.primary_phone_area_code
            ||' '|| hzp.primary_phone_country_code
            ||' '|| hzp.primary_phone_number phone_number
        INTO gv_repent_phone_number
        FROM hz_parties hzp
        WHERE hzp.party_id = lv_party_id;
    END IF;

    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'gv_repent_id_number      : ' ||gv_repent_id_number ) ;
      fnd_file.put_line(fnd_file.log,'gv_repent_name           : ' ||gv_repent_name ) ;
      fnd_file.put_line(fnd_file.log,'gv_repent_address_line_1 : ' ||gv_repent_address_line_1 ) ;
      fnd_file.put_line(fnd_file.log,'gv_repent_address_line_2 : ' ||gv_repent_address_line_2 ) ;
      fnd_file.put_line(fnd_file.log,'gv_repent_address_line_3 : ' ||gv_repent_address_line_3 ) ;
      fnd_file.put_line(fnd_file.log,'gv_repent_town_or_city   : ' ||gv_repent_town_or_city ) ;
      fnd_file.put_line(fnd_file.log,'gv_repent_postal_code    : ' ||gv_repent_postal_code ) ;
      fnd_file.put_line(fnd_file.log,'gv_country               : ' ||gv_country ) ;
      fnd_file.put_line(fnd_file.log,'gv_repent_phone_number   : ' ||gv_repent_phone_number ) ;
      fnd_file.put_line(fnd_file.log,'gv_tax_office_location   : ' ||gv_tax_office_location ) ;
      fnd_file.put_line(fnd_file.log,'gv_tax_office_number     : ' ||gv_tax_office_number ) ;
      fnd_file.put_line(fnd_file.log,'gv_tax_office_code       : ' ||gv_tax_office_code ) ;
    END IF ;


    OPEN  c_currency_tax_reg_num;
    FETCH c_currency_tax_reg_num INTO  gv_currency_code
                                       ,gv_tax_reg_num    ;
    CLOSE c_currency_tax_reg_num;

    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'gv_currency_code          : '|| gv_currency_code ) ;
      fnd_file.put_line(fnd_file.log,'gv_tax_reg_num            : '|| gv_tax_reg_num ) ;
    END IF ;

    OPEN entity_details;
    FETCH entity_details INTO  gv_ledger_id,
                               gv_balancing_segment_value,
                               gv_chart_of_accounts_id;
    CLOSE entity_details;

    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'gv_ledger_id               : '|| gv_ledger_id ) ;
      fnd_file.put_line(fnd_file.log,'gv_balancing_segment_value : '|| gv_balancing_segment_value ) ;
      fnd_file.put_line(fnd_file.log,'gv_chart_of_accounts_id    : '||  gv_chart_of_accounts_id ) ;
    END IF ;

    fnd_file.put_line(fnd_file.log,'Before Insert INTO JG_ZZ_VAT_TRX_GT table' ) ;

    FOR r_inv_lines in c_generic_ar_inv_lines
    LOOP

      INSERT INTO jg_zz_vat_trx_gt
                  (  jg_info_n1
                  ,  jg_info_n2
                  ,  jg_info_v1
                  ,  jg_info_d1
                  ,  jg_info_n3
                  ,  jg_info_n4
                  ,  jg_info_n5
                  ,  jg_info_d2
                  ,  jg_info_n6
                  ,  jg_info_v2
                  ,  jg_info_n7
                  ,  jg_info_n8
                  ,  jg_info_v3
                  ,  jg_info_n9
                  ,  jg_info_n10
                  ,  jg_info_n11
                  ,  jg_info_n12
                  ,  jg_info_n13
                  )
     values      (   r_inv_lines.customer_trx_id
                    ,r_inv_lines.cust_trx_type_id
                    ,r_inv_lines.trx_number
                    ,r_inv_lines.trx_date
                    ,r_inv_lines.sold_to_customer_id
                    ,r_inv_lines.bill_to_customer_id
                    ,r_inv_lines.exchange_rate
                    ,r_inv_lines.printing_original_date
                    ,r_inv_lines.previous_customer_trx_id
                    ,r_inv_lines.complete_flag
                    ,r_inv_lines.customer_trx_line_id
                    ,r_inv_lines.line_number
                    ,r_inv_lines.line_type
                    ,r_inv_lines.link_to_cust_trx_line_id
                    ,r_inv_lines.extended_amount
                    ,r_inv_lines.vat_tax_id
                    ,r_inv_lines.acctd_amount
                    ,r_inv_lines.amount
                  );
   end loop;

    select count(*) INTO lv_count from jg_zz_vat_trx_gt;

    fnd_file.put_line(fnd_file.log,'Number of records inserted INTO JG_ZZ_VAT_TRX_GT table: ' || lv_count );
  return (TRUE);
EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Unexpected error occurred in BeforeReport Trigger. Error : ' || SUBSTR(SQLERRM,1,200));
      RETURN (NULL) ;

END BeforeReport;

FUNCTION cf_total_amount(taxable_amount in number, tax_amount in number, exempt_amount in number, nontaxable_amount in number) return number is
begin
return (    taxable_amount
         +  tax_amount
         +  exempt_amount
         +  nontaxable_amount
         );
end cf_total_amount;

FUNCTION get_bsv(ccid number) RETURN VARCHAR2 IS
l_segment VARCHAR2(30);
bal_segment_value VARCHAR2(25);
BEGIN

  SELECT application_column_name
    INTO   l_segment
  FROM   fnd_segment_attribute_values ,
         gl_ledgers gl
  WHERE    id_flex_code                    = 'GL#'
    AND    attribute_value                 = 'Y'
    AND    segment_attribute_type          = 'GL_BALANCING'
    AND    application_id                  = 101
    AND    id_flex_num                = gl.chart_of_accounts_id
    AND    gl.chart_of_accounts_id        = gv_chart_of_accounts_id
    AND    gl.ledger_id             = gv_ledger_id;


    EXECUTE IMMEDIATE 'SELECT '||l_segment ||
                  ' FROM gl_code_combinations '||
                  ' WHERE code_combination_id = '||ccid
  INTO bal_segment_value;

RETURN (bal_segment_value);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,' No record was returned for the GL_Balancing segment. Error : ' || SUBSTR(SQLERRM,1,200));
      RETURN NULL;
END get_bsv;

/*
|| Added the following funtions during UT, Start
*/

FUNCTION  cf_currency_code  return VARCHAR2 IS
 BEGIN
    return ( gv_currency_code );
 END ;

FUNCTION  cf_country  return VARCHAR2 IS
 BEGIN
    return ( gv_country ) ;
 END ;


FUNCTION  cf_tax_reg_num  return VARCHAR2 IS
 BEGIN
    return ( gv_tax_reg_num ) ;
 END ;


FUNCTION  cf_legal_entity_id  return NUMBER IS
 BEGIN
    return ( gn_legal_entity_id ) ;
 END ;


FUNCTION  cf_repent_id_number  return VARCHAR2 IS
 BEGIN
    return ( gv_repent_id_number ) ;
 END ;


FUNCTION  cf_repent_trn  return VARCHAR2 IS
 BEGIN
    return ( gv_repent_trn ) ;
 END ;


FUNCTION  cf_period_start_date  return DATE IS
 BEGIN
    return ( gd_period_start_date ) ;
 END ;


FUNCTION  cf_period_end_date  return DATE IS
 BEGIN
    return ( gd_period_END_date ) ;
 END ;


FUNCTION  cf_repent_name  return VARCHAR2 IS
 BEGIN
    return ( gv_repent_name ) ;
 END ;


FUNCTION  cf_repent_address_line_1  return VARCHAR2 IS
 BEGIN
    return ( gv_repent_address_line_1 ) ;
 END ;


FUNCTION  cf_repent_address_line_2  return VARCHAR2 IS
 BEGIN
    return ( gv_repent_address_line_2 ) ;
 END ;


FUNCTION  cf_repent_address_line_3  return VARCHAR2 IS
 BEGIN
    return ( gv_repent_address_line_3 ) ;
 END ;


FUNCTION  cf_repent_town_or_city  return VARCHAR2 IS
 BEGIN
    return ( gv_repent_town_or_city ) ;
 END ;


FUNCTION  cf_repent_postal_code  return VARCHAR2 IS
 BEGIN
    return ( gv_repent_postal_code ) ;
 END ;


FUNCTION  cf_repent_phone_number  return VARCHAR2 IS
 BEGIN
    return ( gv_repent_phone_number ) ;
 END ;


FUNCTION  cf_tax_office_location  return VARCHAR2 IS
 BEGIN
    return ( gv_tax_office_location ) ;
 END ;


FUNCTION  cf_tax_office_number  return VARCHAR2 IS
 BEGIN
    return ( gv_tax_office_number ) ;
 END ;


FUNCTION  cf_tax_office_code  return VARCHAR2 IS
 BEGIN
    return ( gv_tax_office_code ) ;
 END ;

FUNCTION  cf_prev_fiscal_code  return VARCHAR2 IS
 BEGIN
    return ( gv_prev_fiscal_code  ) ;
 END ;

/*
|| Added the Funtions during UT, end
*/

END JG_ZZ_RTCE_DT_PKG ;

/
