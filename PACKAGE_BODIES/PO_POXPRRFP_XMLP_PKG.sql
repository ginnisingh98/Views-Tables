--------------------------------------------------------
--  DDL for Package Body PO_POXPRRFP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPRRFP_XMLP_PKG" AS
/* $Header: POXPRRFPB.pls 120.1.12010000.2 2011/08/18 13:12:01 ssindhe ship $ */

USER_EXIT_FAILURE EXCEPTION;

DO_SQL_FAILURE EXCEPTION;

function where_clauseFormula return VARCHAR2 is
begin

if      P_report_type = 'N' then
         return('AND poh.printed_date is null');
elsif   P_report_type = 'C' then
         return('AND poh.revised_date > poh.printed_date');
elsif   P_report_type = 'A' then
         return('AND 1=1');
else
         return('AND 1=1');
end if;

RETURN NULL; end;

function BeforeReport return boolean is
begin
   /*srw.do_sql('alter session set SQL_TRACE=True');*/null;
    p_language_where:=' and 1=1';

if  p_uom_join_pll is null then
    p_uom_join_pll:=' ';
end if;

BEGIN
 select displayed_field
  into   C_address_at_top
  from   po_lookup_codes
  where  lookup_type = 'PO_POXPRRFP_XMLP_PKG'
  and    lookup_code = 'ADDRESS AT TOP';


  /*SRW.USER_EXIT('FND SRWINIT');*/null;




  If P_rfq_num_from = P_rfq_num_to THEN
	P_single_rfq_print := 1;
  END IF;



 null;
  if (MLS_INSTALLED) then
	POPULATE_MLS_LEXICALS;
  end if;

  RETURN TRUE;

END;  return (TRUE);
end;

function AfterReport return boolean is
begin
 execute immediate 'alter session set SQL_TRACE=false';


/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function c_amount_pllformula(pll_quantity_ordered in number, pll_price_override in number) return number is
begin

return(pll_quantity_ordered * pll_price_override);
end;

function g_headersgroupfilter(rfq_num_type in varchar2, poh_rfq_num in varchar2,poh_po_header_id in number,poh_sequence_num in number) return boolean is
begin

declare

check_rfq_num number;
check_rfq_num_from number;
check_rfq_num_to number;

begin

if rfq_num_type = 'NUMERIC' then
    if rtrim(poh_rfq_num, '0123456789') is null then
        check_rfq_num := to_number(poh_rfq_num);
    else
        check_rfq_num := -1;
    end if;

    if rtrim(nvl(P_rfq_num_from, poh_rfq_num), '0123456789') is null then
        check_rfq_num_from := to_number(nvl(P_rfq_num_from, poh_rfq_num));
    else
        check_rfq_num_from := -1;
    end if;

    if rtrim(nvl(P_rfq_num_to, poh_rfq_num), '0123456789') is null then
        check_rfq_num_to := to_number(nvl(P_rfq_num_to, poh_rfq_num));

    else
        check_rfq_num_to := -1;
    end if;

    if check_rfq_num between check_rfq_num_from and check_rfq_num_to then
        if (check_security(poh_rfq_num) = FALSE ) then
            return FALSE ;
        else
            if P_test_flag <> 'Y' then
               UPDATE po_headers
                  SET    printed_date       = sysdate
                  ,      print_count        = nvl(print_count,0) + 1
                  ,      status_lookup_code = 'P'
                  WHERE  po_header_id = poh_po_header_id;


                COMMIT;
                UPDATE po_rfq_vendors
                  SET    printed_date       = sysdate
                  ,      print_count        = nvl(print_count,0) + 1
                  ,      print_flag         = 'N'
                  WHERE  po_header_id       = poh_po_header_id
                  AND    sequence_num       = poh_sequence_num;

                COMMIT;
            end if;
        end if ;
    else
        return false;
    end if;
else
    if (check_security(poh_rfq_num) = FALSE ) then
        return FALSE ;
    else
        if P_test_flag <> 'Y' then
            UPDATE po_headers
                  SET    printed_date       = sysdate
                  ,      print_count        = nvl(print_count,0) + 1
                  ,      status_lookup_code = 'P'
                  WHERE  po_header_id = poh_po_header_id;


            COMMIT;
            UPDATE po_rfq_vendors
                  SET    printed_date       = sysdate
                  ,      print_count        = nvl(print_count,0) + 1
                  ,      print_flag         = 'N'
                  WHERE  po_header_id       = poh_po_header_id
                  AND    sequence_num       = poh_sequence_num;

            COMMIT;
        end if;
    end if ;
end if;

end ;


  return (TRUE);
end;

function c_shiptoformula(pll_ship_address_line1 in varchar2, poh_ship_address_line1 in varchar2, pll_ship_address_line2 in varchar2, poh_ship_address_line2 in varchar2,
pll_ship_address_line3 in varchar2, poh_ship_address_line3 in varchar2, pll_ship_adr_info in varchar2, poh_ship_adr_info in varchar2, pll_ship_country in varchar2, poh_ship_country in varchar2) return varchar2 is
begin

if nvl(pll_ship_address_line1,'1') = nvl(poh_ship_address_line1,'1')
and nvl(pll_ship_address_line2,'2') = nvl(poh_ship_address_line2,'2')
and nvl(pll_ship_address_line3,'3') = nvl(poh_ship_address_line3,'3')
and nvl(pll_ship_adr_info,'4') = nvl(poh_ship_adr_info,'4')
and nvl(pll_ship_country,'5') = nvl(poh_ship_country,'5')
   then
       return (C_address_at_top) ;
else return (pll_ship_address_line1) ;
end if;
RETURN NULL; end;

function check_security(poh_rfq_num in varchar2) return boolean is

l_dummy   VARCHAR2(200) ;

begin

select    'This PO is OK to be displayed so far as security is concerned'
into      l_dummy
from      dual
where     poh_rfq_num in
(select    ph.segment1
from      PO_HEADERS PH,
           PO_DOCUMENT_TYPES_ALL_TL T, PO_DOCUMENT_TYPES_ALL_B B ,
           fnd_user fnd,
          po_system_parameters psp
WHERE fnd.user_id = P_user_id
      and    fnd.employee_id is not null
      and    ph.type_lookup_code = 'RFQ'
and   B.DOCUMENT_TYPE_CODE = T.DOCUMENT_TYPE_CODE
      AND B.DOCUMENT_SUBTYPE = T.DOCUMENT_SUBTYPE
     AND B.ORG_ID = T.ORG_ID    AND B.ORG_ID = PH.ORG_ID AND T.LANGUAGE = USERENV('LANG')
 and    B.document_type_code = ph.type_lookup_code
 and    B.document_subtype = 'STANDARD'
 and    ( ph.agent_id = fnd.employee_id
               OR B.security_level_code = 'PUBLIC'
               OR
		  ( B.security_level_code = 'PURCHASING'
                  AND EXISTS
                      (  SELECT 'Is the user an agent'
                         FROM   PO_AGENTS POA
                         WHERE  POA.AGENT_ID =
fnd.employee_id ))
               OR
                  ( B.security_level_code = 'HIERARCHY'
                  AND fnd.employee_id IN
                      ( SELECT POEH.SUPERIOR_ID
                       FROM   PO_EMPLOYEE_HIERARCHIES   POEH
                        WHERE  POEH.EMPLOYEE_ID =
PH.AGENT_ID
                        AND    POEH.POSITION_STRUCTURE_ID =
PSP.SECURITY_POSITION_STRUCTURE_ID)))) ;

return TRUE ;

RETURN NULL; exception when no_data_found then return false ;
          when others then return false ;
end;

function round_pol_amt(c_amount_pol in number, c_currency_precision in number) return number is
begin

  /*srw.reference(c_amount_pol);*/null;

  /*srw.reference(c_currency_precision);*/null;


  return(round(c_amount_pol,c_currency_precision));
end;

procedure POPULATE_MLS_LEXICALS is
   statement     varchar2(1000);
   SESSION_LANGUAGE FND_LANGUAGES.NLS_LANGUAGE%TYPE;
   BASE_LANGUAGE    FND_LANGUAGES.NLS_LANGUAGE%TYPE;

begin

  select substr(userenv('LANGUAGE'),1,instr(userenv('LANGUAGE'),'_')-1)
  into SESSION_LANGUAGE
  from dual;

  select nls_language
  into BASE_LANGUAGE
  from fnd_languages
  where installed_flag = 'B';

  p_language_where := 'and nvl(poh.language,' || '''' ||
                        BASE_LANGUAGE || ''') = ' || '''' ||
                        SESSION_LANGUAGE || '''';

execute immediate 'select attribute_column_name
        from ak_translated_columns atc,
             ak_language_attribute_xrefs alax
       where atc.table_name = ' || '''PO_LINES''' ||
       ' and atc.column_name = ' || '''ITEM_DESCRIPTION''' ||
       ' and alax.translated_column_number = atc.translated_column_number
        and alax.language = ' || '''' || SESSION_LANGUAGE || ''''
   into temp_col_name;




    if temp_col_name is not NULL then
           p_description := 'pol.' || rtrim(temp_col_name,' ');
    end if;

execute immediate 'select alax.attribute_column_name
                  from ak_translated_columns atc,
             ak_language_attribute_xrefs alax
        where atc.table_name = ' || '''MTL_UNITS_OF_MEASURE''' ||
        ' and atc.column_name = ' || '''UNIT_OF_MEASURE''' || 'and alax.translated_column_number = atc.translated_column_number
        and alax.language = ' || '''' || SESSION_LANGUAGE || ''''
 into temp_col_name;




    if temp_col_name is not NULL then
  	p_uom_join_pol := ',mtl_units_of_measure mum
		WHERE pol.unit_of_measure = mum.unit_of_measure';

  	p_uom_join_pll := ',mtl_units_of_measure mum
		WHERE pll.lead_time_unit = mum.unit_of_measure';

        p_uom_col_pol := 'mum.' || rtrim(temp_col_name,' ');

	p_uom_col_pll := p_uom_col_pol;

    end if;

exception
  when  others then raise_application_error(-20001,' Error While processing POPULATE_MLS_LEXICALS');

end POPULATE_MLS_LEXICALS;

function mls_installed return boolean is

sql_stmt varchar2(500);

BEGIN

sql_stmt :=  'select multi_lingual_flag
              into :MLS_FLAG
              from fnd_product_groups';

/*srw.do_sql(sql_stmt);*/null;


if (MLS_FLAG = 'Y') then
    return TRUE;
else
    return FALSE;
end if;


RETURN NULL; exception
      when  DO_SQL_FAILURE /*srw.do_sql_failure */then return FALSE;
      when others then return FALSE;


END mls_installed;

function c_fax_headerformula(C_first_page in varchar2) return char is
d_fax_header varchar2(500);
begin

if (C_first_page <> 1) then
  return (' ');
end if;

if (UPPER(P_fax_enable) = 'Y') then
  d_fax_header := '{{begin}}{{doctype rfqfax}}';
  return(d_fax_header);
end if;

return(' ');
end;

function c_fax_trailerformula(poh_no_of_lines in number, C_last_sum in number, CS_poh_vendor_name in varchar2, CS_poh_rfq_num in varchar2, CS_poh_buyer in varchar2, CS_poh_agent_id in varchar2) return char is
d_fax_trailer varchar2(200);
begin
if (poh_no_of_lines is null and C_last_sum is null) or
   (C_Last_Sum = poh_no_of_lines) then
  if (UPPER(P_fax_enable) = 'Y') then
    d_fax_trailer := '{{company ' ||
      substrb(CS_poh_vendor_name,1,15) || '}}{{fax ' ||
      p_fax_num || '}}{{comment RFQ# ' ||
      CS_poh_rfq_num || '}}{{owner ' ||
      CS_poh_buyer || '}}{{lookup ' ||
      to_char(CS_poh_agent_id) || ' buyer.inc}}{{end}}';
    return (d_fax_trailer);
 end if;
end if;

return(' ');
end;

function c_item_descformula(pol_po_item_id in number, pol_item_description in varchar2, C_msi_desc in varchar2, C_msit_desc in varchar2) return char is
begin

  if (pol_po_item_id is null) then
    return (pol_item_description);
  end if;
  if (pol_item_description is null) or (C_msi_desc is null) then
    return (pol_item_description);
  end if;

  if (pol_item_description = C_msi_desc) then
    return (C_msit_desc);
  else
    return (pol_item_description);
  end if;

end;

function header_noteformula(header_note_datatype_id in number, header_note_media_id in number) return char is
short_note Varchar2(2000);
long_note Long;
begin
  if header_note_datatype_id = 1 then
    select short_text
      into short_note
      from fnd_documents_short_text
     where media_id = header_note_media_id;
    return short_note;
  elsif header_note_datatype_id = 2 then
    select long_text
      into long_note
      from fnd_documents_long_text
     where media_id = header_note_media_id;
    return long_note;
  else
    return 'Attachment is not a Text format';
  end if;

end;

function line_noteformula(line_note_datatype_id in number, line_note_media_id in number) return char is
short_note Varchar2(2000);
long_note Long;
begin
  if line_note_datatype_id = 1 then
    select short_text
      into short_note
      from fnd_documents_short_text
     where media_id = line_note_media_id;
    return short_note;
  elsif line_note_datatype_id = 2 then
    select long_text
      into long_note
      from fnd_documents_long_text
     where media_id = line_note_media_id;
    return long_note;
  else
    return 'Attachment is not a Text format';
  end if;

end;

function item_noteformula(item_note_datatype_id in number, item_note_media_id in number) return char is
short_note Varchar2(2000);
long_note Long;
begin
  if item_note_datatype_id = 1 then
    select short_text
      into short_note
      from fnd_documents_short_text
     where media_id = item_note_media_id;
    return short_note;
  elsif item_note_datatype_id = 2 then
    select long_text
      into long_note
      from fnd_documents_long_text
     where media_id = item_note_media_id;
    return long_note;
  else
    return 'Attachment is not a Text format';
  end if;

end;

--Functions to refer Oracle report placeholders--

 Function C_address_at_top_p return varchar2 is
	Begin
	 return C_address_at_top;
	 END;
END PO_POXPRRFP_XMLP_PKG ;


/
