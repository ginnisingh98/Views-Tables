--------------------------------------------------------
--  DDL for Package Body PAY_PAYSG21A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYSG21A_XMLP_PKG" AS
/* $Header: PAYSG21AB.pls 120.1 2007/12/19 16:18:57 amakrish noship $ */

function BeforeReport return boolean is
begin


	/*srw.user_exit('FND SRWINIT');*/null;


  return (TRUE);
end;

--function afterreport(CS_1 in number, CS_2 in number) return boolean is
function afterreport(CS_1 in number, CS_2 in number,CS_3 in number) return boolean is

l number;
xml_layout boolean;

Begin

  If P_RUN is NULL then
		                  	P_CR_YEAR_AMOUNT := CS_1 + CS_2 + CS_3;
	-- commented by raj l:=SUBMIT_REQUEST(P_BUSINESS_GROUP_ID,P_PERSON_ID,P_BASIS_YEAR-1,P_IR21_MODE,P_CR_YEAR_AMOUNT,0,1,'PAY_PAYSG21A_XMLP_PKG');
	xml_layout := FND_REQUEST.ADD_LAYOUT('PAY','PAYSG21A_XML','en','US','PDF');
	l:=SUBMIT_REQUEST(P_BUSINESS_GROUP_ID,P_PERSON_ID,P_BASIS_YEAR-1,P_IR21_MODE,P_CR_YEAR_AMOUNT,0,1,'PAYSG21A_XML');
	P_RUN :=1;
  Else
	P_PR_YEAR_AMOUNT := CS_1 + CS_2 + CS_3;
	if P_PR_YEAR_AMOUNT = 0 then
		P_PR_YEAR_AMOUNT := null;
	end if;
	xml_layout := FND_REQUEST.ADD_LAYOUT('PAY','PAYSG21B_XML','en','US','PDF');
	l:= SUBMIT_REQUEST(P_BUSINESS_GROUP_ID,P_PERSON_ID,P_BASIS_YEAR+1,P_IR21_MODE,P_CR_YEAR_AMOUNT,P_PR_YEAR_AMOUNT,null,'PAYSG21B_XML');
	P_RUN :=NULL;   End if;
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);

End;

function CF_business_groupFormula return VARCHAR2 is
  v_business_group  hr_all_organization_units.name%type;

begin
  v_business_group := hr_reports.get_business_group(p_business_group_id);
  return v_business_group;
end;

function CF_legislation_codeFormula return VARCHAR2 is

  v_legislation_code    hr_organization_information.org_information9%type := null;

  cursor legislation_code
    (c_business_group_id hr_organization_information.organization_id%type) is

  select org_information9
  from   hr_organization_information
  where  organization_id  = c_business_group_id
  and    org_information9 is not null
  and    org_information_context = 'Business Group Information';
begin
  open legislation_code (p_business_group_id);
  fetch legislation_code into v_legislation_code;
  close legislation_code;

  return v_legislation_code;
end;

function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2 is

  v_currency_code    fnd_currencies.currency_code%type;
  v_format_mask      varchar2(100) := null;
  v_field_length     number(3)    := 14;

  cursor currency_format_mask
    (c_territory_code in fnd_currencies.issuing_territory_code%type) is
  select currency_code
  from   fnd_currencies
  where  issuing_territory_code = c_territory_code;

begin
  open currency_format_mask (cf_legislation_code);
  fetch currency_format_mask into v_currency_code;
  close currency_format_mask;

  v_format_mask := fnd_currency.get_format_mask(v_currency_code, v_field_length);

  return v_format_mask;
end;

PROCEDURE set_currency_format_mask IS
BEGIN

  /*SRW.SET_FORMAT_MASK(CF_currency_format_mask);*/null;


END;

function P_BUSINESS_GROUP_IDValidTrigge return boolean is
begin
  return (TRUE);
end;

function cf_gross_amt_not_tax_exemptfor(stock_option in number, market_value_exercise in varchar2, exercise_price in varchar2, no_of_shares_acq in varchar2, market_value_grant in varchar2) return number is
begin
	if (stock_option = 1) then
      CP_1 := ((market_value_exercise - exercise_price) * no_of_shares_acq);
	else
		  CP_1 := 0;
	end if;
	if (stock_option = 2) then
  		CP_2 := ((market_value_exercise - market_value_grant) * no_of_shares_acq);
    		CP_3 := ((market_value_grant - exercise_price) * no_of_shares_acq);
  		CP_4 := CP_2 + CP_3;
	else
		  CP_4 := 0;
		  CP_2 := 0;
		  CP_3 := 0;
	end if;

	if (stock_option = 3) then
  		CP_5 := ((market_value_exercise - market_value_grant) * no_of_shares_acq);
    		CP_6 := ((market_value_grant - exercise_price) * no_of_shares_acq);
  		CP_7 := CP_5 + CP_6;
	else
		  CP_7 := 0;
		  CP_5 := 0;
		  CP_6 := 0;
	end if;

  return 1;
end;

function cf_2formula(CS_1 in number, CS_2 in number, CS_3 in number) return number is
begin

    return(CS_1 + CS_2 + CS_3);
end;

function submit_request(t_business_group_id in number,t_person_id in number,t_basis_year in number,
                        t_ir21_mode in varchar2,t_cu_amt in number,t_pr_amt in number,t_run in number,
                        t_report_short_name in varchar2) return number is


  l_request_id          NUMBER := 0;
  e_submit_error        exception ;
  xml_layout boolean;

BEGIN
  	hr_utility.set_location('Submit report called',1);
  	hr_utility.set_location('fnd_request.set_print_options',1);



     	hr_utility.set_location('fnd_request.submit_request',1);

if t_report_short_name = 'PAYSG21B_XML' then

	xml_layout := FND_REQUEST.ADD_LAYOUT('PAY',t_report_short_name,'en','US','PDF');
 	l_request_id   :=  FND_REQUEST.SUBMIT_REQUEST (
 				APPLICATION    =>  'PAY',
 				PROGRAM        =>  t_report_short_name,
 				DESCRIPTION    =>  null,
 				START_TIME     =>  null,
 				SUB_REQUEST    =>  null,
 				ARGUMENT1      => 'P_BUSINESS_GROUP_ID=' || t_business_group_id,
 				ARGUMENT2      => 'P_BASIS_YEAR=' ||  t_basis_year,
				ARGUMENT3      => 'P_PERSON_ID='  || t_person_id,
 				ARGUMENT4      => 'P_IR21_MODE='  || t_ir21_mode,
 				ARGUMENT5      => 'P_CR_YEAR_AMOUNT=' || t_cu_amt,
 				ARGUMENT6      => 'P_PR_YEAR_AMOUNT=' || t_pr_amt,
 				ARGUMENT7      =>  t_run,
 				ARGUMENT8      =>  'Y', ARGUMENT9      =>  null, ARGUMENT10     =>  null, ARGUMENT11     =>  null,
				ARGUMENT12     =>  null, ARGUMENT13     =>  null, ARGUMENT14     =>  null, ARGUMENT15     =>  null,
 				ARGUMENT16     =>  null, ARGUMENT17     =>  null, ARGUMENT18     =>  null, ARGUMENT19     =>  null,
			 	ARGUMENT20     =>  null, ARGUMENT21     =>  null, ARGUMENT22     =>  null, ARGUMENT23     =>  null,
 				ARGUMENT24     =>  null, ARGUMENT25     =>  null, ARGUMENT26     =>  null, ARGUMENT27     =>  null,
 				ARGUMENT28     =>  null, ARGUMENT29     =>  null, ARGUMENT30     =>  null, ARGUMENT31     =>  null,
 				ARGUMENT32     =>  null, ARGUMENT33     =>  null, ARGUMENT34     =>  null, ARGUMENT35     =>  null,
 				ARGUMENT36     =>  null, ARGUMENT37     =>  null, ARGUMENT38     =>  null, ARGUMENT39     =>  null,
 				ARGUMENT40     =>  null, ARGUMENT41     =>  null, ARGUMENT42     =>  null, ARGUMENT43     =>  null,
 				ARGUMENT44     =>  null, ARGUMENT45     =>  null, ARGUMENT46     =>  null, ARGUMENT47     =>  null,
 				ARGUMENT48     =>  null, ARGUMENT49     =>  null, ARGUMENT50     =>  null, ARGUMENT51     =>  null,
 				ARGUMENT52     =>  null, ARGUMENT53     =>  null, ARGUMENT54     =>  null, ARGUMENT55     =>  null,
 				ARGUMENT56     =>  null, ARGUMENT57     =>  null, ARGUMENT58     =>  null, ARGUMENT59     =>  null,
 				ARGUMENT60     =>  null, ARGUMENT61     =>  null, ARGUMENT62     =>  null, ARGUMENT63     =>  null,
 				ARGUMENT64     =>  null, ARGUMENT65     =>  null, ARGUMENT66     =>  null, ARGUMENT67     =>  null,
 				ARGUMENT68     =>  null, ARGUMENT69     =>  null, ARGUMENT70     =>  null, ARGUMENT71     =>  null,
 				ARGUMENT72     =>  null, ARGUMENT73     =>  null, ARGUMENT74     =>  null, ARGUMENT75     =>  null,
 				ARGUMENT76     =>  null, ARGUMENT77     =>  null, ARGUMENT78     =>  null, ARGUMENT79     =>  null,
 				ARGUMENT80     =>  null, ARGUMENT81     =>  null, ARGUMENT82     =>  null, ARGUMENT83     =>  null,
 				ARGUMENT84     =>  null, ARGUMENT85     =>  null, ARGUMENT86     =>  null, ARGUMENT87     =>  null,
 				ARGUMENT88     =>  null, ARGUMENT89     =>  null, ARGUMENT90     =>  null, ARGUMENT91     =>  null,
 				ARGUMENT92     =>  null, ARGUMENT93     =>  null, ARGUMENT94     =>  null, ARGUMENT95     =>  null,
 				ARGUMENT96     =>  null, ARGUMENT97     =>  null, ARGUMENT98     =>  null, ARGUMENT99     =>  null,
 				ARGUMENT100    =>  null);
 	    	hr_utility.set_location('l_request_id : '||l_request_id,1);
else
	xml_layout := FND_REQUEST.ADD_LAYOUT('PAY',t_report_short_name,'en','US','PDF');
	l_request_id   :=  FND_REQUEST.SUBMIT_REQUEST (
 				APPLICATION    =>  'PAY',
 				PROGRAM        =>  t_report_short_name,
 				DESCRIPTION    =>  null,
 				START_TIME     =>  null,
 				SUB_REQUEST    =>  null,
 				ARGUMENT1      =>  t_business_group_id,
 				ARGUMENT2      =>  t_basis_year,
				ARGUMENT3      =>  t_person_id,
 				ARGUMENT4      =>  t_ir21_mode,
 				ARGUMENT5      =>  t_cu_amt,
 				ARGUMENT6      =>  t_pr_amt,
 				ARGUMENT7      =>  t_run,
 				ARGUMENT8      =>  'Y', ARGUMENT9      =>  null, ARGUMENT10     =>  null, ARGUMENT11     =>  null,
				ARGUMENT12     =>  null, ARGUMENT13     =>  null, ARGUMENT14     =>  null, ARGUMENT15     =>  null,
 				ARGUMENT16     =>  null, ARGUMENT17     =>  null, ARGUMENT18     =>  null, ARGUMENT19     =>  null,
			 	ARGUMENT20     =>  null, ARGUMENT21     =>  null, ARGUMENT22     =>  null, ARGUMENT23     =>  null,
 				ARGUMENT24     =>  null, ARGUMENT25     =>  null, ARGUMENT26     =>  null, ARGUMENT27     =>  null,
 				ARGUMENT28     =>  null, ARGUMENT29     =>  null, ARGUMENT30     =>  null, ARGUMENT31     =>  null,
 				ARGUMENT32     =>  null, ARGUMENT33     =>  null, ARGUMENT34     =>  null, ARGUMENT35     =>  null,
 				ARGUMENT36     =>  null, ARGUMENT37     =>  null, ARGUMENT38     =>  null, ARGUMENT39     =>  null,
 				ARGUMENT40     =>  null, ARGUMENT41     =>  null, ARGUMENT42     =>  null, ARGUMENT43     =>  null,
 				ARGUMENT44     =>  null, ARGUMENT45     =>  null, ARGUMENT46     =>  null, ARGUMENT47     =>  null,
 				ARGUMENT48     =>  null, ARGUMENT49     =>  null, ARGUMENT50     =>  null, ARGUMENT51     =>  null,
 				ARGUMENT52     =>  null, ARGUMENT53     =>  null, ARGUMENT54     =>  null, ARGUMENT55     =>  null,
 				ARGUMENT56     =>  null, ARGUMENT57     =>  null, ARGUMENT58     =>  null, ARGUMENT59     =>  null,
 				ARGUMENT60     =>  null, ARGUMENT61     =>  null, ARGUMENT62     =>  null, ARGUMENT63     =>  null,
 				ARGUMENT64     =>  null, ARGUMENT65     =>  null, ARGUMENT66     =>  null, ARGUMENT67     =>  null,
 				ARGUMENT68     =>  null, ARGUMENT69     =>  null, ARGUMENT70     =>  null, ARGUMENT71     =>  null,
 				ARGUMENT72     =>  null, ARGUMENT73     =>  null, ARGUMENT74     =>  null, ARGUMENT75     =>  null,
 				ARGUMENT76     =>  null, ARGUMENT77     =>  null, ARGUMENT78     =>  null, ARGUMENT79     =>  null,
 				ARGUMENT80     =>  null, ARGUMENT81     =>  null, ARGUMENT82     =>  null, ARGUMENT83     =>  null,
 				ARGUMENT84     =>  null, ARGUMENT85     =>  null, ARGUMENT86     =>  null, ARGUMENT87     =>  null,
 				ARGUMENT88     =>  null, ARGUMENT89     =>  null, ARGUMENT90     =>  null, ARGUMENT91     =>  null,
 				ARGUMENT92     =>  null, ARGUMENT93     =>  null, ARGUMENT94     =>  null, ARGUMENT95     =>  null,
 				ARGUMENT96     =>  null, ARGUMENT97     =>  null, ARGUMENT98     =>  null, ARGUMENT99     =>  null,
 				ARGUMENT100    =>  null);

    	hr_utility.set_location('l_request_id : '||l_request_id,1);
end if;

   	 If l_request_id = 0 Then
		RAISE e_submit_error;
    	 End If;

    	RETURN l_request_id;

EXCEPTION
    	WHEN e_submit_error then
              /*srw.message('Error in submit request',1);*/null;

END;

--Functions to refer Oracle report placeholders--

 Function CP_1_p return number is
	Begin
	 return CP_1;
	 END;
 Function CP_2_p return number is
	Begin
	 return CP_2;
	 END;
 Function CP_3_p return number is
	Begin
	 return CP_3;
	 END;
 Function CP_4_p return number is
	Begin
	 return CP_4;
	 END;
 Function CP_5_p return number is
	Begin
	 return CP_5;
	 END;
 Function CP_6_p return number is
	Begin
	 return CP_6;
	 END;
 Function CP_7_p return number is
	Begin
	 return CP_7;
	 END;
END PAY_PAYSG21A_XMLP_PKG ;

/
