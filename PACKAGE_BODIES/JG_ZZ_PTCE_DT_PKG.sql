--------------------------------------------------------
--  DDL for Package Body JG_ZZ_PTCE_DT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_PTCE_DT_PKG" AS
/* $Header: jgzztoapntrlb.pls 120.11.12010000.3 2009/03/19 14:02:06 vkejriwa ship $*/

function BeforeReport return boolean is

    CURSOR c_get_le_and_period_dates
    is
    SELECT  nvl(cfg.legal_entity_id,cfgd.legal_entity_id)
           ,nvl(cfg.tax_registration_number,cfgd.tax_registration_number) repent_trn
           ,min(glp.start_date)
           ,max(glp.end_date)
	   ,nvl(cfg.entity_identifier,cfgd.entity_identifier) entity_identifier
    FROM   jg_zz_vat_rep_entities cfg
            ,jg_zz_vat_rep_entities cfgd
            ,gl_periods glp
    WHERE  cfg.vat_reporting_entity_id = p_reporting_entity_id
    and   (
             ( cfg.entity_type_code  = 'ACCOUNTING'
               and cfg.mapping_vat_rep_entity_id = cfgd.vat_reporting_entity_id
             )
             or
            ( cfg.entity_type_code  = 'LEGAL'
               and cfg.vat_reporting_entity_id = cfgd.vat_reporting_entity_id
            )
         )
    AND    glp.period_set_name = nvl(cfg.tax_calendar_name,cfgd.tax_calendar_name)
    AND    glp.period_year = p_fiscal_year
    GROUP BY nvl(cfg.legal_entity_id,cfgd.legal_entity_id)
            ,nvl(cfg.tax_registration_number,cfgd.tax_registration_number)
            ,nvl(cfg.entity_identifier,cfgd.entity_identifier);

    CURSOR c_currency_vat_reg_num
    IS
    SELECT gllev.currency_code
          ,gl.name
          ,fsp.vat_registration_num
          ,fsp.vat_country_code
    FROM   gl_ledger_le_v gllev
          ,gl_ledgers     gl
          ,financials_system_parameters fsp
    WHERE  gllev.ledger_category_code='PRIMARY'
    AND    gllev.legal_entity_id = gn_legal_entity_id
    AND    gl.ledger_id = gllev.ledger_id
    AND    fsp.set_of_books_id   = gllev.ledger_id ;

    CURSOR c_get_gl_name IS
    SELECT gl.name
    FROM  gl_ledger_le_v glle,
          gl_ledgers     gl
    WHERE
          glle.legal_entity_id = gn_legal_entity_id
    AND   gl.ledger_id = glle.ledger_id ;

   CURSOR c_get_rep_entity_info   IS
   SELECT    xfpiv.registration_number
          ,  xfpiv.name
          , xfpiv.address_line_1
          , xfpiv.address_line_2
          , xfpiv.address_line_3
          , xfpiv.town_or_city
          , xfpiv.postal_code
          , xfpiv.country
          , hzp.primary_phone_area_code
            ||' '|| hzp.primary_phone_country_code
            ||' '|| hzp.primary_phone_number phone_number
          , xlelav.city          tax_office_location
          , xlelav.address2   tax_office_number
          , xlelav.address3   tax_office_code
    FROM   XLE_FIRSTPARTY_INFORMATION_V xfpiv
	  ,xle_registrations xle_reg
          , hz_parties hzp
          , xle_legalauth_v   xlelav
    WHERE xle_reg.source_id = xfpiv.legal_entity_id
    AND xle_reg.source_table = 'XLE_ENTITY_PROFILES'
    AND xlelav.legalauth_id = xle_reg.issuing_authority_id
    AND xle_reg.identifying_flag = 'Y'
    AND xfpiv.legislative_cat_code = 'INCOME_TAX'
    AND   xfpiv.legal_entity_id      = gn_legal_entity_id
    AND hzp.party_id = xlelav.party_id;

    CURSOR c_generic_ap_inv_lines   IS
    SELECT
       i.invoice_id
      ,i.vendor_id
      ,i.vendor_site_id
      ,i.invoice_date
      ,i.invoice_currency_code
      ,i.invoice_type_lookup_code
      ,i.legal_entity_id
      ,i.doc_sequence_value
      ,il.line_number
      ,il.line_type_lookup_code
      ,id.period_name
      ,nvl(id.tax_code_id,get_item_tax_code_id(id.invoice_id,id.invoice_distribution_id,tax_rate_id)) tax_code_id
      ,id.match_status_flag
      ,id.charge_applicable_to_dist_id
      ,id.invoice_distribution_id
      ,id.merchant_taxpayer_id
      ,id.line_type_lookup_code id_line_type_lookup_code
      -- ,sum(id.stat_amount) stat_amount Commented for Bug 5750278
      ,sum(il.assessable_value) taxable_amount --Added for 5750278
      ,sum(id.amount)      amount
      ,sum(id.base_amount) base_amount
     FROM
      ap_invoices i,
      ap_invoice_lines il,
      ap_invoice_distributions id,
      gl_code_combinations gl,
      jg_zz_vat_rep_entities repent
    WHERE repent.vat_reporting_entity_id = p_reporting_entity_id
       and ( ( repent.entity_type_code = 'LEGAL' AND i.legal_entity_id = gn_legal_entity_id )
       or  ( repent.entity_type_code = 'ACCOUNTING' AND repent.entity_level_code = 'LEDGER'  AND
            i.set_of_books_id = gv_ledger_id)
       or  ( repent.entity_type_code = 'ACCOUNTING' AND repent.entity_level_code = 'BSV'
      and i.set_of_books_id = gv_ledger_id
      and get_bsv(id.dist_code_combination_id) = gv_balancing_segment_value ) )
       and    i.invoice_id            =  il.invoice_id
       and    i.invoice_id            =  id.invoice_id
       and    il.line_number          =  id.invoice_line_number
       and    id.dist_code_combination_id = gl.code_combination_id
       and    ( (P_called_from = 'JEITRAVL' and  to_char(i.invoice_date, 'YYYY') in
		  (to_char(gd_period_end_date, 'YYYY'),to_char(add_months(gd_period_end_date,-12),'YYYY')))
               or (P_called_from = 'JEPTAPVR' and
			id.accounting_date between to_date('01/01/' || to_char(p_fiscal_year),'DD/MM/YYYY')
					    and to_date('31/12/' || to_char(p_fiscal_year),'DD/MM/YYYY'))

	      )
     GROUP BY
       i.invoice_id
      ,i.vendor_id
      ,i.vendor_site_id
      ,i.invoice_date
      ,i.invoice_currency_code
      ,i.invoice_type_lookup_code
      ,i.legal_entity_id
      ,i.doc_sequence_value
      ,il.line_number
      ,il.line_type_lookup_code
      ,id.period_name
      ,nvl(id.tax_code_id,get_item_tax_code_id(id.invoice_id,id.invoice_distribution_id,tax_rate_id))
      ,id.match_status_flag
      ,id.charge_applicable_to_dist_id
      ,id.invoice_distribution_id
      ,id.merchant_taxpayer_id
      ,id.line_type_lookup_code;



   CURSOR entity_details IS
   SELECT repent.ledger_id,
          repent.balancing_segment_value,
          gl.CHART_OF_ACCOUNTS_ID
   FROM   jg_zz_vat_rep_entities repent
         ,gl_ledgers gl
   WHERE vat_reporting_entity_id = p_reporting_entity_id
   AND   gl.ledger_id = repent.ledger_id;

begin

	OPEN  c_get_le_and_period_dates;
     FETCH c_get_le_and_period_dates into  gn_legal_entity_id
                                         ,gv_repent_trn
                                         ,gd_period_start_date
                                         ,gd_period_end_date
					 ,gv_entity_identifier;
     CLOSE c_get_le_and_period_dates;

        fnd_file.put_line(fnd_file.log,'*******Information*********');
        fnd_file.put_line(fnd_file.log,' gn_legal_entity_id   :'|| gn_legal_entity_id);
	fnd_file.put_line(fnd_file.log,' gv_repent_trn   :'|| gv_repent_trn);
	fnd_file.put_line(fnd_file.log,' gd_period_start_date   :'||gd_period_start_date);
        fnd_file.put_line(fnd_file.log,' gd_period_end_date   :'|| gd_period_end_date);
	fnd_file.put_line(fnd_file.log,' gv_entity_identifier   :'|| gv_entity_identifier);

     OPEN  c_get_rep_entity_info;
     FETCH c_get_rep_entity_info into gv_repent_id_number
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
                                   ,gv_tax_office_code ;
    CLOSE c_get_rep_entity_info;

        fnd_file.put_line(fnd_file.log,' gv_repent_id_number   :'||gv_repent_id_number);
	fnd_file.put_line(fnd_file.log,' gv_repent_name   :'|| gv_repent_name);
	fnd_file.put_line(fnd_file.log,' gv_repent_address_line_1   :'||gv_repent_address_line_1);
	fnd_file.put_line(fnd_file.log,' gv_repent_address_line_2  :'||gv_repent_address_line_2);
        fnd_file.put_line(fnd_file.log,' gv_repent_address_line_3   :'||gv_repent_address_line_3);
	fnd_file.put_line(fnd_file.log,' gv_repent_town_or_city   :'||gv_repent_town_or_city);
	fnd_file.put_line(fnd_file.log,' gv_repent_postal_code   :'||gv_repent_postal_code);
	fnd_file.put_line(fnd_file.log,' gv_country  :'||gv_country);
        fnd_file.put_line(fnd_file.log,' gv_repent_phone_number   :'||gv_repent_phone_number);
	fnd_file.put_line(fnd_file.log,' gv_tax_office_location   :'||gv_tax_office_location);
	fnd_file.put_line(fnd_file.log,' gv_tax_office_number   :'||gv_tax_office_number);
	fnd_file.put_line(fnd_file.log,' gv_tax_office_code   :'||gv_tax_office_code );



    OPEN  c_currency_vat_reg_num ;
    FETCH c_currency_vat_reg_num  into   gv_currency_code
                                       , gv_name
                                       , gv_vat_reg_num
                                       , gv_vat_country_code ;
    CLOSE c_currency_vat_reg_num;

        fnd_file.put_line(fnd_file.log,' gv_currency_code   :'||gv_currency_code);
	fnd_file.put_line(fnd_file.log,' gv_name   :'||gv_name);
	fnd_file.put_line(fnd_file.log,' gv_vat_reg_num   :'||gv_vat_reg_num);
	fnd_file.put_line(fnd_file.log,' gv_vat_country_code   :'||gv_vat_country_code );

    IF(gv_currency_code = 'PTE') THEN
     gn_thousands:= 1000;
    ELSE
     gn_thousands := 1;
    END IF;

    OPEN  c_get_gl_name;
    FETCH c_get_gl_name into  gv_name ;
    CLOSE c_get_gl_name;

  OPEN entity_details;
  FETCH  entity_details INTO gv_ledger_id,
          gv_balancing_segment_value,
          gv_chart_of_accounts_id;
  CLOSE entity_details;

    FOR r_inv_lines IN c_generic_ap_inv_lines
    LOOP

    INSERT INTO jg_zz_vat_trx_gt
           (jg_info_n1 ,
            jg_info_n2 ,
            jg_info_n3 ,
            jg_info_d1 ,
            jg_info_v1 ,
            jg_info_v2 ,
            jg_info_n4 ,
            jg_info_n5 ,
            jg_info_n6 ,
            jg_info_v3 ,
            jg_info_v4 ,
            jg_info_n7 ,
	    jg_info_v5 ,
            jg_info_n8 , --stat_amount Now Taxable Amount Bug 5750278
            jg_info_n9 , --amount
            jg_info_n10, --base_amount
	    jg_info_n11, --charge_applicable_to_dist_id
	    jg_info_n12, --invoice_distribution_id
            jg_info_v7, --merchant_taxpayer_id
	    jg_info_v6 --id_line_type_lookup_code
	    )
    VALUES(
            r_inv_lines.invoice_id
            , r_inv_lines.vendor_id
            , r_inv_lines.vendor_site_id
            , r_inv_lines.invoice_date
            , r_inv_lines.invoice_currency_code
            , r_inv_lines.invoice_type_lookup_code
            , r_inv_lines.legal_entity_id
            , r_inv_lines.doc_sequence_value
            , r_inv_lines.line_number
            , r_inv_lines.line_type_lookup_code
            , r_inv_lines.period_name
            , r_inv_lines.tax_code_id
	    , r_inv_lines.match_status_flag
            -- , r_inv_lines.stat_amount -- Commented for Bug 5750278
            , r_inv_lines.taxable_amount -- Added for Bug 5750278
            , r_inv_lines.amount
            , r_inv_lines.base_amount
	    , r_inv_lines.charge_applicable_to_dist_id
	    , r_inv_lines.invoice_distribution_id
            , r_inv_lines.merchant_taxpayer_id
	    , r_inv_lines.id_line_type_lookup_code
	    );

    END LOOP;

    fnd_file.put_line(fnd_file.log,' After inserting the data into Global Temp Table');

  RETURN (TRUE);
END;

/*
REM +======================================================================+
REM Name: get_bsv
REM
REM Description: This function is called in the generic cursor for getting the
REM              BSV for each invoice distribution.
REM
REM
REM Parameters:  ccid  (code combination id)
REM
REM +======================================================================+
*/

FUNCTION get_bsv(ccid number) RETURN VARCHAR2 IS

l_segment VARCHAR2(30);
bal_segment_value VARCHAR2(25);

BEGIN

  SELECT application_column_name
  INTO   l_segment
  FROM   fnd_segment_attribute_values ,
         gl_ledgers gl
  WHERE    id_flex_code               = 'GL#'
    AND    attribute_value            = 'Y'
    AND    segment_attribute_type     = 'GL_BALANCING'
    AND    application_id             = 101
    AND    id_flex_num                = gl.chart_of_accounts_id
    AND    gl.chart_of_accounts_id    = gv_chart_of_accounts_id
    AND    gl.ledger_id               = gv_ledger_id;

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

function get_gd_period_end_date return date IS
begin
 return(gd_period_end_date);
end;

function get_gn_thousands return number IS
begin
	return(gn_thousands);
end;

function get_gv_vat_country_code return varchar2 IS
begin
	return(gv_vat_country_code);
end;

function get_gv_currency_code return varchar2 IS
begin
	return(gv_currency_code);
end;

function get_gv_repent_country return varchar2 IS
begin
	return(gv_country);
end;

function get_gv_vat_reg_num return varchar2 IS
begin
	return(gv_vat_reg_num);
end;

function get_gv_repent_trn return varchar2 IS
begin
	return(gv_repent_trn);
end;

function get_gv_repent_name return varchar2 IS
begin
	return(gv_repent_name);
end;

function get_gv_repent_address_line_1 return varchar2 IS
begin
	return(gv_repent_address_line_1);
end;

function get_gv_repent_address_line_2 return varchar2 IS
begin
	return(gv_repent_address_line_2);
end;

function get_gv_repent_address_line_3 return varchar2 IS
begin
	return(gv_repent_address_line_3);
end;

function get_gv_repent_town_or_city return varchar2 IS
begin
	return(gv_repent_town_or_city);
end;

function get_gv_repent_postal_code return varchar2 IS
begin
	return(gv_repent_postal_code);
end;

function get_gv_country return varchar2 IS
begin
	return(gv_country);
end;

function get_gv_repent_id_number return varchar2 IS
begin
	return(gv_repent_id_number);
end;

function get_gv_tax_office_location return varchar2 IS
begin
	return(gv_tax_office_location);
end;

function get_gv_tax_office_number return varchar2 IS
begin
	return(gv_tax_office_number);
end;

function get_gv_tax_office_code return varchar2 IS
begin
	return(gv_tax_office_code);
end;

function get_gv_repent_phone_number return varchar2 IS
begin
        return(gv_repent_phone_number);
end;

function get_gv_entity_identifier  return varchar2 IS
begin
	return(gv_entity_identifier);
end;

function get_item_tax_code_id(inv_id number,inv_dist_id number,tax_rate_id number) return number IS

tax_code_id number;

CURSOR c_get_tax_code_id(p_inv_id number,p_inv_dist_id number,p_tax_rate_id number) IS
SELECT distinct tax_code_id
FROM ap_invoice_distributions
WHERE invoice_id = p_inv_id
AND charge_applicable_to_dist_id = p_inv_dist_id;
begin

FOR r_tax_codes IN c_get_tax_code_id(inv_id,inv_dist_id,tax_rate_id)
LOOP
if ( tax_rate_id = r_tax_codes.tax_code_id ) then
RETURN(tax_rate_id);
end if;
END LOOP;
RETURN(1);

end;


END JG_ZZ_PTCE_DT_PKG ;

/
