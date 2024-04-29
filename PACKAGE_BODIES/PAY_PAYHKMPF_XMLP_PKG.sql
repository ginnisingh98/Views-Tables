--------------------------------------------------------
--  DDL for Package Body PAY_PAYHKMPF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYHKMPF_XMLP_PKG" AS
/* $Header: PAYHKMPFB.pls 120.0 2007/12/13 12:17:12 amakrish noship $ */

USER_EXIT_FAILURE EXCEPTION;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function BeforeReport return boolean is
BEGIN

  p_global_sequence_no := 0;

  /*srw.user_exit('FND SRWINIT');*/null;



if p_surcharge_parti_mand is null then
    p_surcharge_parti_mand_t := 0;
else
    p_surcharge_parti_mand_t := p_surcharge_parti_mand;
end if;

if p_surcharge_parti_vol is null then
    p_surcharge_parti_vol_t := 0;
else
    p_surcharge_parti_vol_t := p_surcharge_parti_vol;
end if;

if p_surcharge_partii_mand is null then
    p_surcharge_partii_mand_t := 0;
else
    p_surcharge_partii_mand_t := p_surcharge_partii_mand;
end if;

if p_surcharge_partii_vol is null then
    p_surcharge_partii_vol_t := 0;
else
    p_surcharge_partii_vol_t := p_surcharge_partii_vol;
end if;

P_CONTRIBUTIONS_START_DATE_T := to_char(p_contributions_start_date,'dd/mm/yyyy');
P_CONTRIBUTIONS_END_DATE_T := to_char(p_contributions_end_date,'dd/mm/yyyy');
effective_date := to_char(p_contributions_end_date,'dd-mon-yyyy');
  construct_where_clause;
  construct_scheme_employer;

  return (TRUE);

EXCEPTION
 when  USER_EXIT_FAILURE /*srw.user_exit_failure */then
   begin
     /*srw.message(100, 'Foundation is not initialised');*/null;

     raise_application_error(-20101,null);/*srw.program_abort;*/null;

   end;
END;

PROCEDURE construct_where_clause IS
BEGIN


  --cp_where_current := null;
  cp_where_current := ' ';



  if p_scheme_id is not null then
     cp_where_current := cp_where_current || ' and scheme_id = ' || to_char(p_scheme_id);
  end if;

  if p_legal_employer_id is not null then
     cp_where_current := cp_where_current || ' and tax_unit_id = ' || to_char(p_legal_employer_id);
  end if;



  if p_contributions_start_date is not null and
     p_contributions_end_date is not null then
     cp_where_current := cp_where_current || ' and effective_date between ' || '''' ||
               to_char(p_contributions_start_date,'dd-mon-yyyy') || '''' || ' and ' || '''' ||
               to_char(p_contributions_end_date,'dd-mon-yyyy') || '''' ;
  end if;

END;

PROCEDURE construct_scheme_employer IS
BEGIN


BEGIN
select substr(hoi.org_information2, 1, 52)                      scheme_name,
       substr(hoi.org_information1, 1, 17)                      scheme_registration_no,
       substr(hoi.org_information5, 1, 32)                      contact_person,
       substr(hoi.org_information6, 1, 17)                      employer_participation_no
into   cp_scheme_name,
       cp_scheme_reg_number,
       cp_contact,
       cp_participation_no
from hr_organization_information  hoi
where hoi.org_information20 = p_scheme_id
and   hoi.org_information_context = 'HK_MPF_SCHEMES';

EXCEPTION
    when no_data_found then
        cp_scheme_name       := null;
        cp_scheme_reg_number := null;
        cp_contact           := null;
        cp_participation_no  := null;
END;


BEGIN
select substr(hou.name, 1, 32)                                  employer_name,
       hl.address_line_1 ||
       decode(hl.address_line_2, null, null, ', ' || hl.address_line_2) ||
       decode(hl.address_line_3, null, null, ', ' || hl.address_line_3) ||
       decode(hl.town_or_city, null, null, ', '   || hl.town_or_city) address,
       substr(hl.telephone_number_1, 1, 32)                     telephone_number
into   cp_employer_name,
       cp_address,
       cp_telephone_no
from hr_organization_units        hou,
     hr_locations                 hl
where hou.organization_id = p_legal_employer_id
and   hou.location_id     = hl.location_id;

cp_address := substr(cp_address, 1, 70);
EXCEPTION
    when no_data_found then
        cp_employer_name       := null;
        cp_address             := null;
        cp_telephone_no        := null;
END;

END;

function cf_total_mandatoryformula(er_mandatory in number, ee_mandatory in number) return number is
begin
  return er_mandatory + ee_mandatory;
end;

function cf_total_voluntaryformula(er_voluntary in number, ee_voluntary in number) return number is
begin
  return er_voluntary + ee_voluntary;
end;

function cf_part1_mandatoryformula(CS_er_mandatory in number, CS_ee_mandatory in number) return number is
begin
  --return CS_er_mandatory + CS_ee_mandatory + p_surcharge_parti_mand;
  return CS_er_mandatory + CS_ee_mandatory + p_surcharge_parti_mand_t;
end;

function cf_part1_voluntaryformula(CS_er_voluntary in number, CS_ee_voluntary in number) return number is
begin
  --return CS_er_voluntary + CS_ee_voluntary + p_surcharge_parti_vol;
  return CS_er_voluntary + CS_ee_voluntary + p_surcharge_parti_vol_t;
end;

function CF_sequence_noFormula return Number is
begin



  if cp_display_sequence_1 is null then
     cp_display_sequence_1 := 0;
  end if;

  cp_display_sequence_1 := cp_display_sequence_1 + 1;
  p_global_sequence_no  := p_global_sequence_no + 1;

  return 0;

end;

function CF_CURRENCY_FORMAT_MASKFormula return Number is

  v_currency_code    fnd_currencies.currency_code%type;
  v_format_mask      varchar2(100) := null;
  v_field_length     number(3);

begin


  v_currency_code := pay_hk_soe_pkg.business_currency_code(p_business_group_id);


	v_field_length := 12;
  v_format_mask   := fnd_currency.get_format_mask(v_currency_code, v_field_length);
  cp_currency_format_mask_12 := v_format_mask;

	v_field_length := 14;
  v_format_mask   := fnd_currency.get_format_mask(v_currency_code, v_field_length);
  cp_currency_format_mask_14 := v_format_mask;

  return 0;

end;

function cf_total_mandatory1formula(er_mandatory1 in number, ee_mandatory1 in number) return number is
begin
    return er_mandatory1 + ee_mandatory1;
end;

function cf_total_voluntary1formula(er_voluntary1 in number, ee_voluntary1 in number) return number is
begin
    return er_voluntary1 + ee_voluntary1;
end;

function cf_partii_mandatoryformula(CS_er_mandatory1 in number, CS_ee_mandatory1 in number) return number is
begin
  --return CS_er_mandatory1 + CS_ee_mandatory1 + p_surcharge_partii_mand;
  return CS_er_mandatory1 + CS_ee_mandatory1 + p_surcharge_partii_mand_t;
end;

function cf_partii_voluntaryformula(CS_er_voluntary1 in number, CS_ee_voluntary1 in number) return number is
begin
  --return CS_er_voluntary1 + CS_ee_voluntary1 + p_surcharge_partii_vol;
  return CS_er_voluntary1 + CS_ee_voluntary1 + p_surcharge_partii_vol_t;
end;

function cf_overall_mandatoryformula(CF_parti_mandatory in number, CF_partii_mandatory in number) return number is
begin
  return CF_parti_mandatory + CF_partii_mandatory;
end;

function cf_overall_voluntaryformula(CF_parti_voluntary in number, CF_partii_voluntary in number) return number is
begin
  return CF_parti_voluntary + CF_partii_voluntary;
end;

function CF_sequence_no1Formula return Number is
begin



  if cp_display_sequence_2 is null then
     cp_display_sequence_2 := p_global_sequence_no;
  end if;

  cp_display_sequence_2  := cp_display_sequence_2 + 1;
  p_global_sequence_no   := p_global_sequence_no + 1;

  return 0;

end;

--Functions to refer Oracle report placeholders--

 Function CP_display_sequence_1_p return number is
	Begin
	 return CP_display_sequence_1;
	 END;
 Function CP_display_sequence_2_p return number is
	Begin
	 return CP_display_sequence_2;
	 END;
 Function CP_where_current_p return varchar2 is
	Begin
	 return CP_where_current;
	 END;
 Function CP_scheme_name_p return varchar2 is
	Begin
	 return CP_scheme_name;
	 END;
 Function CP_scheme_reg_number_p return varchar2 is
	Begin
	 return CP_scheme_reg_number;
	 END;
 Function CP_employer_name_p return varchar2 is
	Begin
	 return CP_employer_name;
	 END;
 Function CP_contact_p return varchar2 is
	Begin
	 return CP_contact;
	 END;
 Function CP_address_p return varchar2 is
	Begin
	 return CP_address;
	 END;
 Function CP_telephone_no_p return varchar2 is
	Begin
	 return CP_telephone_no;
	 END;
 Function CP_participation_no_p return varchar2 is
	Begin
	 return CP_participation_no;
	 END;
 Function CP_CURRENCY_FORMAT_MASK_12_p return varchar2 is
	Begin
	 return CP_CURRENCY_FORMAT_MASK_12;
	 END;
 Function CP_CURRENCY_FORMAT_MASK_14_p return varchar2 is
	Begin
	 return CP_CURRENCY_FORMAT_MASK_14;
	 END;
END PAY_PAYHKMPF_XMLP_PKG ;

/
