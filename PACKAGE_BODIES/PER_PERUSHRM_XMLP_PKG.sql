--------------------------------------------------------
--  DDL for Package Body PER_PERUSHRM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERUSHRM_XMLP_PKG" AS
/* $Header: PERUSHRMB.pls 120.0 2007/12/28 07:01:44 srikrish noship $ */

function BeforeReport return boolean is
 l_name          varchar2(61) := 'BEFORE_REPORT';

begin
 -- hr_standard.event('BEFORE REPORT');
   hr_utility.set_location('Entering.... :' || l_name,10);
 p_multi_state_1 := p_multi_state;
 c_end_of_time := hr_general.end_of_time;

 c_business_group_name := hr_reports.get_business_group(p_business_group_id);

  c_no_of_gre := 0;
  c_no_of_newhire := 0;
  c_a03_header_flag := 0;
  c_fatal_error_flag := null;
  if p_multi_state_1 is null then
    p_multi_state_1 := 'N';
  end if;

 if p_tax_unit_id is not null then
    c_tax_unit := hr_us_reports.get_org_name
                   (p_tax_unit_id,p_business_group_id);
 end if;

 if p_state_code is not null then
    c_state_name := hr_us_reports.get_state_name
                   (p_state_code);
 end if;

    hr_utility.set_location(l_name,20);

	--file_io.open;
        hr_utility.set_location(l_name,30);
        --file_io.open_a01;


     hr_utility.set_location(l_name,40);
     char_set_init('US7ASCII') ;

        if p_audit_report = 'Y' then
        hr_utility.set_location(l_name,50);
		--file_io.open_a03;
          end if;

  hr_utility.set_location('Leaving.....:' || l_name,100);
return (TRUE);

RETURN NULL; exception when no_data_found then null;
	  RETURN NULL; when others then
		/*srw.message(288, 'Error found in before report trigger');*/null;


RETURN NULL; end;

function c_employee_addressformula(person_id in number) return varchar2 is
begin

DECLARE l_employee_address VARCHAR2(2000) := NULL;
        l_person_id NUMBER(15);

begin

   l_person_id := person_id;

   hr_us_reports.get_employee_address
                   (l_person_id
                   ,l_employee_address);


  return(l_employee_address);

exception
	when others then
		/*srw.message('88','Error found in c_employee_address is '||sqlerrm);*/null;


end;

RETURN NULL; end;

function c_salaryformula(assignment_id in number) return number is
begin

declare

l_business_group_id 	number(15);
l_report_date		date;
l_salary		number;

begin

hr_utility.set_location('Entered c_salary formula', 5);

if p_state_code = 'TX' or p_state_code = 'OR'
  or p_state_code = 'MD' then
	l_business_group_id := P_BUSINESS_GROUP_ID;
	l_report_date := fnd_date.canonical_to_date(P_REPORT_DATE);

	l_salary := hr_us_reports.get_salary(l_business_group_id,
					 assignment_id,
					 l_report_date
				            );
    hr_utility.set_location('Leaving c_salary formula', 10);
        if p_state_code = 'TX' then
	    return(l_salary);
        else
            return(l_salary/12);
        end if;
else
    hr_utility.set_location('Leaving c_salary formula', 15);
	return(NULL);
end if;


exception when NO_DATA_FOUND then
		/*srw.message(1,'Error is found in c_salary');*/null;

	  when others then
		/*srw.message(1,'Error is found in c_salary');*/null;


end;

RETURN NULL; end;

function AfterReport (CS_NO_OF_NEW_HIRE in number)return boolean is
begin

--hr_standard.event('AFTER REPORT');

  hr_utility.set_location('Entered after report trigger',1);


  if c_fatal_error_flag is null and C_NO_OF_NEWHIRE > 0 then
        total_record() ;
        hr_utility.set_location('after report trigger',2);
  end if;
    hr_utility.set_location('after report trigger',3);

       -- file_io.close;

    if c_fatal_error_flag is null then
      hr_utility.set_location('after report trigger',4);
    p_output_new_hire_null() ;
    hr_utility.set_location('after report trigger',5);
        p_mag_update_status() ;
        hr_utility.set_location('after report trigger',6);
    end if;


  if c_fatal_error_flag is null then
	  a01_total_record(CS_NO_OF_NEW_HIRE) ;
  end if;
 -- file_io.close_a01;


  if p_audit_report = 'Y' then
          hr_utility.set_location('after report trigger',8);
       -- file_io.close_a03;
    end if;
    hr_utility.set_location('Leaving after report trigger',10);
return(TRUE);
RETURN NULL; exception when others then
	hr_utility.set_location('Error found in after report trigger',20);
	hr_utility.trace('The error message is '||sqlerrm);

RETURN NULL; end;

function G_new_hiresGroupFilter return boolean is
begin
  /*srw.message(1,'Tax Unit ID1                     => '||to_char(tax_unit_id));*/null;

  /*srw.message(2,'Finish g_new_hires and person_id => '||to_char(person_id));*/null;

  return (TRUE);
end;

function BetweenPage return boolean is
begin
  hr_utility.set_location('Entered between page trigger',5);
  return (TRUE);
end;

function CF_new_hireFormula (SUI_COMPANY_STATE_ID in varchar2,DATE_START in date,FEDERAL_ID in varchar2,
NATIONAL_IDENTIFIER in varchar2,MIDDLE_NAME in varchar2,gre_location_id in number,HIRE_STATE in varchar2,
person_id in number,LAST_NAME in varchar2,FIRST_NAME in varchar2,DATE_OF_BIRTH in date,
TAX_UNIT_NAME in varchar2,FULL_MIDDLE_NAME in varchar2,SIT_COMPANY_STATE_ID in varchar2,
c_contact_name in varchar2,c_contact_phone in varchar2)return Number is
l_name  varchar2(60) := 'CF_new_hireFormula';
begin

    hr_utility.set_location('Entering... :' || l_name,10);

     new_hire_record(person_id ,NATIONAL_IDENTIFIER ,FIRST_NAME,MIDDLE_NAME ,LAST_NAME,DATE_START,
     FULL_MIDDLE_NAME ,gre_location_id ,DATE_OF_BIRTH ,HIRE_STATE ,FEDERAL_ID,SUI_COMPANY_STATE_ID,
     TAX_UNIT_NAME ,c_contact_phone ,c_contact_name ,SIT_COMPANY_STATE_ID );

    hr_utility.set_location('Leaving... :' || l_name,20);

  return(0);
end;

PROCEDURE char_set_init
(
                p_character_set in varchar2
) IS
BEGIN

	per_new_hire_pkg.char_set_init(	p_character_set	=> p_character_set);


END;
 procedure  new_hire_record(person_id in number,NATIONAL_IDENTIFIER in varchar2,FIRST_NAME in varchar2,
 MIDDLE_NAME in varchar2,LAST_NAME in varchar2,DATE_START in date,FULL_MIDDLE_NAME in varchar2,
 gre_location_id in number,DATE_OF_BIRTH in date,HIRE_STATE in varchar2,FEDERAL_ID in number,
 SUI_COMPANY_STATE_ID in varchar2,TAX_UNIT_NAME in varchar2,c_contact_phone in number,
 c_contact_name in varchar2,SIT_COMPANY_STATE_ID in varchar2) is
l_buffer		varchar2(2000);
l_address 		varchar2(1000);
l_city			varchar2(50);
l_state			varchar2(50);
l_zip			varchar2(10);
l_zip_extension 	varchar2(10);
l_loc_address_line1 	varchar2(240);
l_loc_address_line2 	varchar2(240);
l_loc_address_line3 	varchar2(240);
l_loc_city		varchar2(50);
l_loc_state		varchar2(10);
l_loc_zip		varchar2(10);
l_loc_zip_extension 	varchar2(10);
l_loc_country		varchar2(10);
l_emp_address_line1 	varchar2(240);
l_emp_address_line2 	varchar2(240);
l_emp_address_line3 	varchar2(240);
l_emp_city		varchar2(50);
l_emp_state		varchar2(50);
l_emp_zip		varchar2(10);
l_emp_zip_extension 	varchar2(10);
l_emp_country		varchar2(10);
l_person_id  		number(15);
l_location_id   	number(15);
l_name   		varchar(60) := 'New_Hire_Record';
g_delimiter		varchar2(1) := fnd_global.local_chr(10);
l_date_start		varchar2(10);
l_date_of_birth		varchar2(10);


BEGIN

    hr_utility.set_location('Entering....' || l_name,10);
    l_person_id := person_id;


   if p_state_code = 'CA' then
               hr_utility.set_location(l_name,20);

      per_new_hire_pkg.get_employee_address
      (l_person_id,l_address,l_city,l_state,l_zip,l_zip_extension);
				l_buffer := per_new_hire_pkg.ca_w4_record(
		 p_record_identifier	=> 'W4'
		,p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_first_name	   	=> FIRST_NAME
		,p_middle_name   	=> MIDDLE_NAME
		,p_last_name		=> LAST_NAME
		,p_street_address	=> l_address
		,p_city          	=> l_city
                ,p_state                => l_state
    		,p_zip   		=> l_zip
		,p_zip_extension 	=> l_zip_extension
		,p_date_of_hire		=> DATE_START
	);
	hr_utility.set_location(l_name,30);
       c_no_of_newhire := c_no_of_newhire + 1;
             -- file_io.put(l_buffer);
              if p_audit_report = 'Y' then


	 l_buffer := per_new_hire_pkg.a03_ca_new_hire_record(
		 p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_first_name	   	=> FIRST_NAME
		,p_middle_name   	=> FULL_MIDDLE_NAME
		,p_last_name		=> LAST_NAME
		,p_emp_address_line	=> l_address
		,p_emp_city          	=> l_city
                ,p_emp_state            => l_state
    		,p_emp_zip   		=> l_zip
		,p_emp_zip_extension 	=> l_zip_extension
		,p_date_of_hire		=> DATE_START

	 );
	 	          hr_utility.set_location(l_name,35);
        -- file_io.put_a03(l_buffer);
	       end if;
        	   elsif p_state_code = 'NY' then
                 hr_utility.set_location(l_name,40);

  	per_new_hire_pkg.get_employee_address
        (l_person_id,l_address,l_city,l_state,l_zip,l_zip_extension);
       hr_utility.trace('date_start = ' ||to_char(DATE_START));

	l_buffer := per_new_hire_pkg.ny_1h_record(
		 p_record_identifier	=> '1H'
		,p_last_name		=> LAST_NAME
		,p_middle_name   	=> MIDDLE_NAME
		,p_first_name	   	=> FIRST_NAME
		,p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_street_address	=> l_address
		,p_city          	=> l_city
                ,p_state                => l_state
    		,p_zip   		=> l_zip
		,p_date_of_hire		=> DATE_START
	);
        c_no_of_newhire := c_no_of_newhire + 1;
             -- file_io.put(l_buffer);
                     if p_audit_report = 'Y' then

	 l_buffer := per_new_hire_pkg.a03_ny_new_hire_record(
		 p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_first_name	   	=> FIRST_NAME
		,p_middle_name   	=> FULL_MIDDLE_NAME
		,p_last_name		=> LAST_NAME
		,p_emp_address_line	=> l_address
		,p_emp_city          	=> l_city
                ,p_emp_state            => l_state
    		,p_emp_zip   		=> l_zip
		,p_date_of_hire		=> DATE_START
	 );
	 	          --file_io.put_a03(l_buffer);
	       end if;

       hr_utility.set_location(l_name,50);
          elsif p_state_code = 'FL' then
			        hr_utility.trace('p_state_code = FL');
	l_location_id := gre_location_id;
	per_new_hire_pkg.get_location_address_3lines
	      (l_location_id,l_loc_address_line1,l_loc_address_line2,l_loc_address_line3
              ,l_loc_city,l_loc_state,l_loc_zip,l_loc_zip_extension,l_loc_country);
		per_new_hire_pkg.get_employee_address_3lines
	      (l_person_id,l_emp_address_line1,l_emp_address_line2,l_emp_address_line3
               ,l_emp_city,l_emp_state,l_emp_zip,l_emp_zip_extension,l_emp_country);
 	hr_utility.set_location(l_name,51);
		hr_utility.trace('p_mult_state =   ' || p_multi_state_1);
  	hr_utility.trace('l_loc_state =    ' || l_loc_state);
 	  	  l_buffer := per_new_hire_pkg.fl_new_hire_record(
		 p_record_identifier	=> 'FL Newhire Record'
		,p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_first_name	   	=> FIRST_NAME
		,p_middle_name   	=> FULL_MIDDLE_NAME
		,p_last_name		=> LAST_NAME
		,p_emp_address_line1	=> l_emp_address_line1
		,p_emp_address_line2	=> l_emp_address_line2
		,p_emp_address_line3	=> l_emp_address_line3
		,p_emp_city          	=> l_emp_city
                ,p_emp_state            => l_emp_state
    		,p_emp_zip   		=> l_emp_zip
		,p_emp_zip_extension 	=> l_emp_zip_extension
		,p_emp_country_code	=> l_emp_country
		,p_date_of_birth	=> DATE_OF_BIRTH
		,p_date_of_hire		=> DATE_START
		,p_state_of_hire	=> HIRE_STATE
		,p_federal_id           => FEDERAL_ID
		,p_sit_company_state_id	=> SUI_COMPANY_STATE_ID 		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_loc_address_line1	=> l_loc_address_line1
		,p_loc_address_line2	=> l_loc_address_line2
		,p_loc_address_line3	=> l_loc_address_line3
		,p_loc_city          	=> l_loc_city
                ,p_loc_state            => l_loc_state
    		,p_loc_zip   		=> l_loc_zip
		,p_loc_zip_extension 	=> l_loc_zip_extension
		,p_loc_country_code	=> l_loc_country
		,p_loc_phone		=> c_contact_phone
		,p_loc_phone_extension => '   '
		,p_loc_contact		=> c_contact_name
		,p_opt_address_line1	=> ' '
		,p_opt_address_line2	=> ' '
		,p_opt_address_line3	=> ' '
		,p_opt_city		=> ' '
		,p_opt_state		=> ' '
		,p_opt_zip		=> ' '
		,p_opt_zip_extension	=> ' '
		,p_opt_country_code	=> ' '
		,p_opt_phone		=> ' '
		,p_opt_phone_extension 	=> ' '
		,p_opt_contact 		=> ' '
		,p_multi_state		=> p_multi_state_1
	  );

	         -- file_io.put(l_buffer);
         	 	 if p_audit_report = 'Y' then

	   l_buffer := per_new_hire_pkg.a03_fl_new_hire_record(
		 p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_first_name	   	=> FIRST_NAME
		,p_middle_name   	=> FULL_MIDDLE_NAME
		,p_last_name		=> LAST_NAME
		,p_emp_address_line1	=> l_emp_address_line1
		,p_emp_address_line2	=> l_emp_address_line2
		,p_emp_address_line3	=> l_emp_address_line3
		,p_emp_city          	=> l_emp_city
                ,p_emp_state            => l_emp_state
    		,p_emp_zip   		=> l_emp_zip
		,p_emp_zip_extension 	=> l_emp_zip_extension
		,p_emp_country_code	=> l_emp_country
		,p_date_of_birth	=> DATE_OF_BIRTH
		,p_date_of_hire		=> DATE_START
		,p_state_of_hire	=> HIRE_STATE
		,p_federal_id           => FEDERAL_ID
		,p_state_ein		=> SUI_COMPANY_STATE_ID 		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_loc_address_line1	=> l_loc_address_line1
		,p_loc_address_line2	=> l_loc_address_line2
		,p_loc_address_line3	=> l_loc_address_line3
		,p_loc_city          	=> l_loc_city
                ,p_loc_state            => l_loc_state
    		,p_loc_zip   		=> l_loc_zip
		,p_loc_zip_extension 	=> l_loc_zip_extension
		,p_loc_country_code	=> l_loc_country
		,p_contact_phone	=> c_contact_phone
		,p_contact_phone_ext	=> ' '
		,p_contact_name		=> c_contact_name
                ,p_multi_state		=> p_multi_state_1
	  );
	  	     	 -- file_io.put_a03(l_buffer);
	        end if;
	    elsif p_state_code = 'IL' then
				l_location_id := gre_location_id;
		per_new_hire_pkg.get_location_address_3lines
	      (l_location_id,l_loc_address_line1,l_loc_address_line2,l_loc_address_line3
              ,l_loc_city,l_loc_state,l_loc_zip,l_loc_zip_extension,l_loc_country);
		per_new_hire_pkg.get_employee_address_3lines
	      (l_person_id,l_emp_address_line1,l_emp_address_line2,l_emp_address_line3
               ,l_emp_city,l_emp_state,l_emp_zip,l_emp_zip_extension,l_emp_country);
        	l_buffer := per_new_hire_pkg.il_new_hire_record(
		 p_record_identifier	=> 'W4'
		,p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_first_name	   	=> FIRST_NAME
		,p_middle_name   	=> FULL_MIDDLE_NAME
		,p_last_name		=> LAST_NAME
		,p_emp_address_line1	=> l_emp_address_line1
		,p_emp_address_line2	=> l_emp_address_line2
		,p_emp_city          	=> l_emp_city
                ,p_emp_state            => l_emp_state
    		,p_emp_zip   		=> l_emp_zip
		,p_emp_zip_extension 	=> l_emp_zip_extension
		,p_date_of_hire		=> DATE_START
		,p_federal_id           => FEDERAL_ID
		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_loc_address_line1	=> l_loc_address_line1
		,p_loc_address_line2	=> l_loc_address_line2
		,p_loc_city          	=> l_loc_city
                ,p_loc_state            => l_loc_state
    		,p_loc_zip   		=> l_loc_zip
		,p_loc_zip_extension 	=> l_loc_zip_extension
		,p_opt_address_line1	=> ' '
		,p_opt_address_line2	=> ' '
		,p_opt_city		=> ' '
		,p_opt_state		=> ' '
		,p_opt_zip		=> ' '
		,p_opt_zip_extension	=> ' '
	);
		       -- file_io.put(l_buffer);
        	if p_audit_report = 'Y' then

	  l_buffer := per_new_hire_pkg.a03_il_new_hire_record(
		 p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_first_name	   	=> FIRST_NAME
		,p_middle_name   	=> FULL_MIDDLE_NAME
		,p_last_name		=> LAST_NAME
		,p_emp_address_line1	=> l_emp_address_line1
		,p_emp_address_line2	=> l_emp_address_line2 || ' ' || l_emp_address_line3
		,p_emp_city          	=> l_emp_city
                ,p_emp_state            => l_emp_state
    		,p_emp_zip   		=> l_emp_zip
		,p_emp_zip_extension 	=> l_emp_zip_extension
		,p_date_of_hire		=> DATE_START
		,p_federal_id           => FEDERAL_ID
		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_loc_address_line1	=> l_loc_address_line1
		,p_loc_address_line2	=> l_loc_address_line2 ||  ' ' || l_loc_address_line3
				,p_loc_city          	=> l_loc_city
                ,p_loc_state            => l_loc_state
    		,p_loc_zip   		=> l_loc_zip
		,p_loc_zip_extension 	=> l_loc_zip_extension
	  );
	  	     	--  file_io.put_a03(l_buffer);
	        end if;
          elsif p_state_code = 'TX' then
				l_location_id := gre_location_id;
        hr_utility.trace('gre_location_id = ' || l_location_id);
	per_new_hire_pkg.get_location_address_3lines
	      (l_location_id,l_loc_address_line1,l_loc_address_line2,l_loc_address_line3
              ,l_loc_city,l_loc_state,l_loc_zip,l_loc_zip_extension,l_loc_country);
	 	per_new_hire_pkg.get_employee_address_3lines
	      (l_person_id,l_emp_address_line1,l_emp_address_line2,l_emp_address_line3
               ,l_emp_city,l_emp_state,l_emp_zip,l_emp_zip_extension,l_emp_country);
        	l_buffer := per_new_hire_pkg.tx_new_hire_record(
		 p_record_identifier	=> 'W4'
		,p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_first_name	   	=> FIRST_NAME
		,p_middle_name   	=> FULL_MIDDLE_NAME
		,p_last_name		=> LAST_NAME
		,p_emp_address_line1	=> l_emp_address_line1
		,p_emp_address_line2	=> l_emp_address_line2 ||' ' || l_emp_address_line3
		,p_emp_city          	=> l_emp_city
                ,p_emp_state            => l_emp_state
    		,p_emp_zip   		=> l_emp_zip
		,p_emp_zip_extension 	=> l_emp_zip_extension
		,p_emp_country_code	=> l_emp_country
		,p_emp_country_name	=> '  '
		,p_emp_country_zip	=> '  '
		,p_date_of_birth	=> DATE_OF_BIRTH
		,p_date_of_hire		=> DATE_START
		,p_state_of_hire	=> HIRE_STATE
		,p_federal_id           => FEDERAL_ID
		,p_state_ein		=> SIT_COMPANY_STATE_ID
		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_loc_address_line1	=> l_loc_address_line1
		,p_loc_address_line2	=> l_loc_address_line2
		,p_loc_address_line3	=> l_loc_address_line3
		,p_loc_city          	=> l_loc_city
                ,p_loc_state            => l_loc_state
    		,p_loc_zip   		=> l_loc_zip
		,p_loc_zip_extension 	=> l_loc_zip_extension
		,p_loc_country_code	=> l_loc_country
		,p_loc_country_name	=> ' '
		,p_loc_country_zip	=> ' '
		,p_opt_address_line1	=> ' '
		,p_opt_address_line2	=> ' '
		,p_opt_address_line3	=> ' '
		,p_opt_city		=> ' '
		,p_opt_state		=> ' '
		,p_opt_zip		=> ' '
		,p_opt_zip_extension	=> ' '
		,p_opt_country_code	=> ' '
		,p_opt_country_name	=> ' '
		,p_opt_country_zip 	=> ' '
		,p_salary 		=> ' ' 		,p_frequency		=> ' ' 	);
	       -- file_io.put(l_buffer);
        		if p_audit_report = 'Y' then

	  l_buffer := per_new_hire_pkg.a03_tx_new_hire_record(
		 p_national_identifier	=> NATIONAL_IDENTIFIER
		,p_first_name	   	=> FIRST_NAME
		,p_middle_name   	=> FULL_MIDDLE_NAME
		,p_last_name		=> LAST_NAME
		,p_emp_address_line1	=> l_emp_address_line1
		,p_emp_address_line2	=> l_emp_address_line2
		,p_emp_address_line3	=> l_emp_address_line3
		,p_emp_city          	=> l_emp_city
                ,p_emp_state            => l_emp_state
    		,p_emp_zip   		=> l_emp_zip
		,p_emp_zip_extension 	=> l_emp_zip_extension
		,p_emp_country_code	=> l_emp_country
		,p_emp_country_name	=> ' '
		,p_emp_country_zip	=> ' '
		,p_date_of_birth	=> DATE_OF_BIRTH
		,p_date_of_hire		=> DATE_START
		,p_state_of_hire        => HIRE_STATE
		,p_federal_id           => FEDERAL_ID
		,p_state_ein		=> SIT_COMPANY_STATE_ID
		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_loc_address_line1	=> l_loc_address_line1
		,p_loc_address_line2	=> l_loc_address_line2
		,p_loc_address_line3	=> l_loc_address_line3
		,p_loc_city          	=> l_loc_city
                ,p_loc_state            => l_loc_state
    		,p_loc_zip   		=> l_loc_zip
		,p_loc_zip_extension 	=> l_loc_zip_extension
		,p_loc_country_code	=> l_loc_country
		,p_loc_country_name	=> ' '
		,p_loc_country_zip	=> ' '
	 );
	 	    	-- file_io.put_a03(l_buffer);
	       end if;
          end if;
      hr_utility.set_location('Leaving...' || l_name,100);
    exception when others then
                hr_utility.set_location('Leaving....' || l_name,999);
                c_fatal_error_flag := 7;
		/*srw.message(288, 'Error found in ' || l_name);*/null;

                fnd_message.raise_error;
END;

PROCEDURE TOTAL_RECORD IS
l_buffer	varchar2(2000);
l_name 		varchar(60) := 'TOTAL_RECORD';
BEGIN

  hr_utility.set_location('Entering.....:' || l_name,10);
  if p_state_code = 'CA' then
      	l_buffer := per_new_hire_pkg.ca_t4_record(
		p_record_identifier	=> 'T4'
		,p_number_of_employee    => C_NO_OF_NEWHIRE
	);

 	hr_utility.trace('l_buffer = ' || l_buffer);
		--file_io.put(l_buffer);
    elsif p_state_code = 'NY' then
      	l_buffer := per_new_hire_pkg.ny_1t_record(
		 p_record_identifier  	=> '1T'
		,p_number_of_employee  	=> C_NO_OF_NEWHIRE
	);

 	hr_utility.trace('l_buffer = ' || l_buffer);
		--file_io.put(l_buffer);
				l_buffer := per_new_hire_pkg.ny_1f_record(
		 p_record_identifier  	=> '1F'
		,p_number_of_employer  	=> c_no_of_gre
	);

 	hr_utility.trace('l_buffer = ' || l_buffer);
		--file_io.put(l_buffer);

  end if;
    hr_utility.set_location('Leaving.....:' || l_name,100);
    exception when others then
                hr_utility.set_location('Leaving....' || l_name,999);
                c_fatal_error_flag := 9;
		/*srw.message(288, 'Error found in ' || l_name);*/null;



END;

procedure a01_header_record(TAX_UNIT_ID in number,federal_id in varchar2)   is
l_buffer		varchar2(2000);
l_loc_address_line1 	varchar2(240);
l_loc_address_line2 	varchar2(240);
l_loc_address_line3 	varchar2(240);
l_loc_city		varchar2(50);
l_loc_state		varchar2(50);
l_loc_zip		varchar2(10);
l_loc_zip_extension 	varchar2(10);
l_loc_country		varchar2(10);
l_location_id   	number(15);
l_tax_unit_name 	varchar2(240);
l_name   		varchar2(60) := 'a01_header_record';
l_zip			varchar2(10);
g_delimiter  		varchar2(1) := fnd_global.local_chr(10);

CURSOR c_tax_unit_name IS
	select hou.name
              ,hou.location_id
	from hr_organization_units hou
	where hou.business_group_id = P_BUSINESS_GROUP_ID
and hou.organization_id = TAX_UNIT_ID;

BEGIN

  hr_utility.set_location('Entering....' || l_name,10);
  hr_utility.trace('p_tax_unit_id        = ' || to_char(P_TAX_UNIT_ID));
  hr_utility.trace('p_business_group_id  = ' || to_char(P_BUSINESS_GROUP_ID));

    open c_tax_unit_name;
    fetch c_tax_unit_name into l_tax_unit_name,l_location_id;
    close c_tax_unit_name;

    hr_utility.trace('location_id  = ' || to_char(l_location_id));
    per_new_hire_pkg.get_location_address_3lines
      (l_location_id,l_loc_address_line1,l_loc_address_line2,l_loc_address_line3
            ,l_loc_city,l_loc_state,l_loc_zip,l_loc_zip_extension,l_loc_country);

    l_tax_unit_name := upper(l_tax_unit_name);
    l_loc_address_line1 := upper(l_loc_address_line1);
    l_loc_address_line2 := upper(l_loc_address_line2);
    l_loc_address_line3 := upper(l_loc_address_line3);
    l_loc_city := upper(l_loc_city);
    l_loc_state := upper(l_loc_state);

   /*file_io.put_a01('Employer Record' || g_delimiter);
 file_io.put_a01(g_delimiter);
 file_io.put_a01('Name                                : ' || l_tax_unit_name || g_delimiter);
 file_io.put_a01('FEIN                                : ' || federal_id || g_delimiter);
 file_io.put_a01('Address                             : ' || l_loc_address_line1 || ' ' || l_loc_address_line2 || ' ' || l_loc_address_line3 || g_delimiter);
 file_io.put_a01('City                                : ' || l_loc_city || g_delimiter);
 file_io.put_a01('State                               : ' || l_loc_state || g_delimiter);
 if l_loc_zip_extension is null then
 file_io.put_a01('zip                                 : ' || l_loc_zip || g_delimiter);
  else
    file_io.put_a01('zip                                 : ' || l_loc_zip || '-' || l_loc_zip_extension || g_delimiter);
  end if;
  file_io.put_a01(g_delimiter); */
    hr_utility.set_location('Leaving....' || l_name,100);

  exception when others then
                hr_utility.set_location('Leaving....' || l_name,999);
                c_fatal_error_flag := 3;
		/*srw.message(288, 'Error found in ' || l_name);*/null;


END;

procedure a01_total_record(CS_NO_OF_NEW_HIRE in number) is
l_name   		varchar(60) := 'a01_total_record';
g_delimiter  		varchar2(1) :=  fnd_global.local_chr(10);
l_total_number          number(10);


BEGIN

  hr_utility.set_location('Entering....' || l_name,10);
    l_total_number := CS_NO_OF_NEW_HIRE ;
 -- file_io.put_a01('All state new hire reported Totals  : ' ||  l_total_number);
    hr_utility.set_location('Leaving....' || l_name,100);
END;

PROCEDURE A03_HEADER_RECORD IS
l_name   		varchar(60) := 'a03_header_record';
l_buffer       		varchar2(2000);

BEGIN

  hr_utility.set_location('Entering....' || l_name,10);
  if p_state_code = 'CA' then
	l_buffer := per_new_hire_pkg.a03_ca_new_hire_header;
  elsif p_state_code = 'NY' then
	l_buffer := per_new_hire_pkg.a03_ny_new_hire_header;
  elsif p_state_code = 'IL' then
	l_buffer := per_new_hire_pkg.a03_il_new_hire_header;
  elsif p_state_code = 'FL' then
	l_buffer := per_new_hire_pkg.a03_fl_new_hire_header;
  elsif p_state_code = 'TX' then
	l_buffer := per_new_hire_pkg.a03_tx_new_hire_header;
  end if;
    hr_utility.set_location('Entering....' || l_name,20);

 -- file_io.put_a03(l_buffer);

  hr_utility.set_location('Leaving....' || l_name,100);
    exception when others then
                hr_utility.set_location('Leaving....' || l_name,999);
                c_fatal_error_flag := 4;
		/*srw.message(288, 'Error found in ' || l_name);*/null;

  END;

PROCEDURE P_MAG_UPDATE_STATUS IS
BEGIN
DECLARE
CURSOR c_person_id is
select
	 ppf.PERSON_ID
	,ppf.LAST_NAME		 LAST_NAME
	,ppf.FIRST_NAME      FIRST_NAME
	,hl.region_2		 STATE
From
	 per_all_people_f 		ppf

        ,hr_locations_all		hl
	,hr_soft_coding_keyflex	hscf
	,per_all_assignments_f	paf
	,per_periods_of_service	pps
	,hr_organization_information	hoi4
	,hr_organization_information	hoi3
	,hr_organization_information 	hoi2
	,hr_organization_information	hoi1
	,hr_organization_units	hou
Where
	pps.person_id			= ppf.person_id

And	fnd_date.canonical_to_date(P_REPORT_DATE)
	between 	pps.date_start and NVL(pps.actual_termination_date,C_END_OF_TIME)
And 	fnd_date.canonical_to_date(P_REPORT_DATE)
	between ppf.effective_start_date and ppf.effective_end_date
And	ppf.person_id			= paf.person_id
And 	fnd_date.canonical_to_date(P_REPORT_DATE)
	between 	paf.effective_start_date and paf.effective_end_date

and hscf.segment1 = to_char(hou.organization_id)
and hou.business_group_id = p_business_group_id
and hou.organization_id = NVL(p_tax_unit_id,hou.organization_id)
and hl.region_2 = DECODE(p_multi_state_1,'N',p_state_code,hl.region_2)
And	paf.soft_coding_keyflex_id	= hscf.soft_coding_keyflex_id
And	paf.assignment_type		= 'E'
And	paf.primary_flag		= 'Y'
And	paf.location_id			= hl.location_id


And    	ppf.business_group_id +0	= P_BUSINESS_GROUP_ID
And	ppf.per_information_category    = 'US'
And    	pps.date_start  		<= fnd_date.canonical_to_date(P_REPORT_DATE)
And     ppf.per_information7 	= 'INCL'
 and	hou.business_group_id		= ppf.business_group_id
and	hoi1.organization_id		= hou.organization_id
and	hoi1.org_information_context	= 'CLASS'
and 	hoi1.org_information1		= 'HR_LEGAL'
and	hoi1.org_information2		='Y'
and 	hoi2.organization_id(+)		= hou.organization_id
and	hoi2.org_information_context	='Employer Identification'
and	hoi3.organization_id(+) 	= hou.organization_id
and	hoi3.org_information_context(+)	= 'New Hire Reporting'
and	hoi4.organization_id(+)		= hou.organization_id
and	hoi4.org_information_context(+)	= 'State Tax Rules'
and	hoi4.org_information1(+)	= nvl(P_STATE_CODE,hoi4.org_information1(+))
UNION

select   ppf.PERSON_ID
	,ppf.LAST_NAME	         LAST_NAME
	,ppf.FIRST_NAME        	 FIRST_NAME
	,hl.region_2		 STATE
From
	per_all_people_f 		ppf

        ,hr_locations_all		hl
	,hr_soft_coding_keyflex		hscf
	,per_all_assignments_f		paf
	,per_periods_of_service		pps
        ,hr_organization_information	hoi4
	,hr_organization_information	hoi3
	,hr_organization_information 	hoi2
	,hr_organization_information	hoi1
	,hr_organization_units		hou
Where
	pps.person_id			= ppf.person_id

And	fnd_date.canonical_to_date(P_REPORT_DATE)
	between 	ppf.effective_start_date and ppf.effective_end_date
And	pps.actual_termination_date	IS NOT NULL
And	ppf.person_id			= paf.person_id
And 	not exists (select 1 from per_all_assignments_f paf2
   	where ppf.person_id = paf2.person_id
    	and fnd_date.canonical_to_date(P_REPORT_DATE)
   	between paf2.effective_start_date and paf2.effective_end_date
   	)
And	pps.date_start			= paf.effective_start_date

and hscf.segment1 = to_char(hou.organization_id)
and hou.business_group_id = p_business_group_id
and hou.organization_id = NVL(p_tax_unit_id,hou.organization_id)
and hl.region_2 = DECODE(p_multi_state_1,'N',p_state_code,hl.region_2)
And	paf.soft_coding_keyflex_id	= hscf.soft_coding_keyflex_id
And paf.assignment_type			= 'E'
And	paf.primary_flag		= 'Y'
And	paf.location_id			= hl.location_id


And     	ppf.business_group_id +0	= P_BUSINESS_GROUP_ID
And	ppf.per_information_category    	= 'US'
And    	pps.date_start  			<= fnd_date.canonical_to_date(P_REPORT_DATE)
And     ppf.per_information7 			= 'INCL'
 and	hou.business_group_id		= ppf.business_group_id
and	hoi1.organization_id		= hou.organization_id
and	hoi1.org_information_context	= 'CLASS'
and 	hoi1.org_information1		= 'HR_LEGAL'
and	hoi1.org_information2		='Y'
and 	hoi2.organization_id(+)		= hou.organization_id
and	hoi2.org_information_context	='Employer Identification'
and	hoi3.organization_id(+) 	= hou.organization_id
and	hoi3.org_information_context(+)	= 'New Hire Reporting'
and	hoi4.organization_id(+)		= hou.organization_id
and	hoi4.org_information_context(+)	= 'State Tax Rules'
and	hoi4.org_information1(+)	= nvl(P_STATE_CODE,hoi4.org_information1(+))
order by    4,2,3;


  v_person_id	per_people_f.person_id%TYPE;
  v_first_name	per_people_f.first_name%TYPE;
  v_last_name	per_people_f.last_name%TYPE;
  v_state         hr_locations_all.region_2%TYPE;
  l_name   	varchar(60) := 'P_MAG_UPDATE_STATUS';
  g_delimiter	varchar2(1) :=  fnd_global.local_chr(10);

BEGIN
hr_utility.set_location('Entered ......:' || l_name,10);
if c_person_id%ISOPEN then
   close c_person_id;
end if;
OPEN c_person_id;
   LOOP

	FETCH c_person_id INTO v_person_id, v_last_name, v_first_name, v_state;

        hr_utility.trace('v_person_id  = ' || to_char(v_person_id));
        hr_utility.trace('v_state      = ' || v_state);

                if p_report_mode = 'F' then
	  UPDATE per_people_f
	  SET 	 per_information7	= 'DONE'
	  WHERE	 person_id = v_person_id
          AND    per_information7 = 'INCL';
        end if;


        hr_utility.trace('c_old_state  = ' || c_old_state);
        if c_old_state is NULL then
                    hr_utility.set_location(l_name,20);
          c_old_state := v_state;
          c_state_count := 1;
                  elsif c_old_state <> v_state then
                    hr_utility.set_location(l_name,30);
                    	--  file_io.put_a01(c_old_state || '  state new hire reported Totals  : ' || c_state_count || g_delimiter);
	  c_state_count := 1;
          c_old_state := v_state;
       else
          hr_utility.set_location(l_name,40);
 	  c_state_count := c_state_count + 1;
          hr_utility.trace('c_state_count   =' || c_state_count);
       end if;

	EXIT WHEN c_person_id%NOTFOUND;

   END LOOP;

   hr_utility.set_location(l_name,50);

   c_state_count := c_state_count - 1;
   if c_state_count <> 0 then
         -- file_io.put_a01(c_old_state || '  state new hire reported Totals  : ' || c_state_count || g_delimiter);
        null;
	end if;
   hr_utility.set_location(l_name,60);
CLOSE c_person_id;
COMMIT;
hr_utility.set_location(l_name,90);

/*srw.message('101', 'Report Mode : ' || p_report_mode);*/null;

if p_report_mode = 'F' then
  /*srw.message('100', 'The New Hire Status has changed to ''Already Reported'' if there is/are any new employee(s).');*/null;

end if;
/*srw.message('102', 'Called Status Update');*/null;

hr_utility.set_location('Leaving....' || l_name,100);
  exception
	when others then
		/*srw.message(290, 'The error message is '||sqlerrm);*/null;

                rollback;

  END;


END;

function CF_GREFormula (FEDERAL_ID in varchar2,gre_location_id in number,TAX_UNIT_ID in number,TAX_UNIT_NAME in varchar2,SIT_COMPANY_STATE_ID in varchar2)return Number is
l_name  varchar2(60) := 'CF_GREFormula';
l_buffer varchar2(1000);
g_delimiter varchar2(1) :=  fnd_global.local_chr(10);
begin

hr_utility.set_location('Entering...' || l_name,0);
hr_utility.trace('p_audit_report =       ' || p_audit_report);
hr_utility.trace('p_state_code =         ' || p_state_code);

  hr_utility.set_location(l_name,20);
        gre_record(gre_location_id,tax_unit_id,FEDERAL_ID,SIT_COMPANY_STATE_ID,TAX_UNIT_NAME) ;
      hr_utility.set_location(l_name,30);


  hr_utility.set_location('Leaving....:' || l_name,100);
  return(0);

end;

function c_contact_nameformula(new_hire_contact_id in varchar2) return varchar2 is
begin

declare

l_person_id		number(15);
l_business_group_id 	number(15);
l_report_date		date;
l_contact_name		varchar2(240);
l_contact_title		varchar2(60);
l_contact_phone		varchar2(60);

begin

l_person_id := new_hire_contact_id;
l_report_date := fnd_date.canonical_to_date(P_REPORT_DATE);
l_business_group_id := P_BUSINESS_GROUP_ID;

per_new_hire_pkg.get_new_hire_contact
                (l_person_id,
		 l_business_group_id,
		 l_report_date,
		 l_contact_name,
		 l_contact_title,
		 l_contact_phone
		);

hr_utility.set_location('Entered c_person_dets',5);


hr_utility.trace('Contact name => '||l_contact_name);
hr_utility.set_location('Leaving c_contact_name', 10);

return(l_contact_name);

exception when NO_DATA_FOUND then
hr_utility.trace('Error is found in c_contact_name');
null;

end;


RETURN NULL; end;

function c_contact_phoneformula(new_hire_contact_id in varchar2) return varchar2 is
begin

declare

l_person_id		number(15);
l_business_group_id 	number(15);
l_report_date		date;
l_contact_name		varchar2(240);
l_contact_title		varchar2(60);
l_contact_phone		varchar2(60);

begin

l_person_id := new_hire_contact_id;
l_report_date := fnd_date.canonical_to_date(P_REPORT_DATE);
l_business_group_id := P_BUSINESS_GROUP_ID;

per_new_hire_pkg.get_new_hire_contact
                (l_person_id,
		 l_business_group_id,
		 l_report_date,
		 l_contact_name,
		 l_contact_title,
		 l_contact_phone
		);

hr_utility.set_location('Entered c_contact_phone',5);


hr_utility.trace('Contact phone => '||l_contact_phone);
hr_utility.set_location('Leaving c_contact_phone', 10);

return(l_contact_phone);

exception when NO_DATA_FOUND then
hr_utility.trace('Error is found in c_contact_phone');
null;

end;

RETURN NULL; end;

function c_contact_titleformula(new_hire_contact_id in varchar2) return varchar2 is
begin

declare

l_person_id		number(15);
l_business_group_id 	number(15);
l_report_date		date;
l_contact_name		varchar2(240);
l_contact_title		varchar2(60);
l_contact_phone		varchar2(60);

begin

l_person_id := new_hire_contact_id;
l_report_date := fnd_date.canonical_to_date(P_REPORT_DATE);
l_business_group_id := P_BUSINESS_GROUP_ID;

per_new_hire_pkg.get_new_hire_contact
                (l_person_id,
		 l_business_group_id,
		 l_report_date,
		 l_contact_name,
		 l_contact_title,
		 l_contact_phone
		);

hr_utility.set_location('Entered c_contact_title',5);


hr_utility.trace('Contact title => '||l_contact_title);
hr_utility.set_location('Leaving c_contact_title',10);

return(l_contact_title);

exception when NO_DATA_FOUND then
hr_utility.trace('Error is found in c_contact_title');
null;

end;

RETURN NULL; end;

function c_tax_unit_addressformula(location_id in number) return varchar2 is

begin

DECLARE l_tax_unit_address 	VARCHAR2(2000);
        l_location_id 		NUMBER(15);

begin

   l_location_id := location_id;
   hr_us_reports.get_address(l_location_id, l_tax_unit_address);
   return(l_tax_unit_address);

exception
	when others then
		hr_utility.trace('the error is '|| to_char(sqlcode)||sqlerrm);
		/*srw.message('1','Error is found in tax_unit_address formula');*/null;

		/*srw.message('10','sqlcode is : '||to_char(sqlcode)||sqlerrm);*/null;

end;

RETURN NULL;
end;

procedure gre_record(gre_location_id in number, federal_id in varchar2,TAX_UNIT_ID in number,SIT_COMPANY_STATE_ID in varchar2, TAX_UNIT_NAME in varchar2) is

	l_buffer		varchar2(2000);
     	l_address 		varchar2(1000);
	l_city			varchar2(50);
	l_state			varchar2(50);
	l_zip			varchar2(10);
	l_zip_extension 	varchar2(10);
 	l_location_id  		number(15);
	l_transmitter_count 	number(15);
	l_trans_tax_unit_name 	varchar2(240);
	l_trans_federal_id 	varchar2(15);
	l_trans_location_id 	number(15);
	l_trans_tax_unit_id 	number(15);
        l_trans_address 	varchar2(1000);
	l_trans_city		varchar2(50);
	l_trans_state		varchar2(50);
	l_trans_zip		varchar2(10);
	l_trans_zip_extension 	varchar2(10);
       	l_branch_code  		varchar2(3) := '   ';         l_name          	varchar2(61) := 'GRE_RECORD';
        g_delimiter 		varchar2(1) :=  fnd_global.local_chr(10);
        l_tx_emp_num            number := 0;
        l_tx_term_num           number := 0;

	CURSOR c_transmitter IS
	SELECT
	       distinct
	       hou.name                 	transmitter_name
	,      replace(hoi2.org_information1 ,'-',null)  trans_federal_id
	,      hou.organization_id     	trans_tax_unit_id
	,      hou.location_id         	trans_location_id
	FROM
	       hr_organization_information          hoi3
	,      hr_organization_information          hoi2
	,      hr_organization_information          hoi1
	,      hr_organization_units                hou
	WHERE
	       hou.business_group_id            = P_BUSINESS_GROUP_ID
	AND    hoi1.organization_id 		= hou.organization_id
	AND    hoi1.org_information_context 	= 'CLASS'
	AND    hoi1.org_information1 		= 'HR_LEGAL'
	AND    hoi1.org_information2 		= 'Y'
	AND    hoi2.organization_id(+) 		= hou.organization_id
	AND    hoi2.org_information_context 	= 'Employer Identification'
	AND    hoi3.organization_id 		= hou.organization_id
	AND    hoi3.org_information_context 	= 'New Hire Reporting'
	AND    hoi3.org_information2       	= 'Y'
    	;

	CURSOR c_transmitter_count IS
	SELECT
	       count(hou.organization_id)
	FROM
	       hr_organization_information          hoi3
	,      hr_organization_units                hou
	WHERE
	       hou.business_group_id            = P_BUSINESS_GROUP_ID
	AND    hoi3.organization_id 		= hou.organization_id
	AND    hoi3.org_information_context 	= 'New Hire Reporting'
	AND    hoi3.org_information2       	= 'Y'
    	;

	CURSOR c_tx_emp_number IS
		select
	 	        count(ppf.person_id)

		From
			per_all_people_f 		ppf
			,per_all_assignments_f		paf
			,hr_soft_coding_keyflex		hscf
			,hr_locations_all		hl   			,per_jobs			job
			,per_periods_of_service 	pps
                        ,hr_organization_information          hoi4
                        ,hr_organization_information          hoi3
	                ,hr_organization_information          hoi2
	                ,hr_organization_information          hoi1
	                ,hr_organization_units                hou

                Where
			pps.person_id				= ppf.person_id
					And	fnd_date.canonical_to_date(P_REPORT_DATE)
			between pps.date_start and NVL(pps.actual_termination_date, C_END_OF_TIME)
		And	fnd_date.canonical_to_date(P_REPORT_DATE)
			between ppf.effective_start_date and ppf.effective_end_date
		And	ppf.person_id				= paf.person_id
		And 	fnd_date.canonical_to_date(P_REPORT_DATE)
			between paf.effective_start_date and paf.effective_end_date

		And	hscf.segment1			= to_char(hou.organization_id)
		and	hou.business_group_id		= P_BUSINESS_GROUP_ID
		and 	hou.organization_id		= NVL(P_TAX_UNIT_ID,hou.organization_id)
		and	hl.region_2			= DECODE(P_MULTI_STATE_1,'N',P_STATE_CODE,hl.region_2)
				And	paf.soft_coding_keyflex_id		= hscf.soft_coding_keyflex_id
		And 	paf.assignment_type			= 'E'
		And	paf.primary_flag			= 'Y'
		And	paf.location_id				= hl.location_id
		And	paf.job_id				= job.job_id(+)
		And	fnd_date.canonical_to_date(P_REPORT_DATE)	between job.date_from(+)
								and     nvl(job.date_to, C_END_OF_TIME)
		And     ppf.business_group_id	 		= P_BUSINESS_GROUP_ID
		And	ppf.per_information_category    	= 'US'
		And    	ppf.start_date  			<= fnd_date.canonical_to_date(P_REPORT_DATE)
		And     ppf.per_information7 	= 'INCL'                 And     hou.business_group_id           = ppf.business_group_id
                	        AND     hoi1.organization_id 		= hou.organization_id
	        AND     hoi1.org_information_context 	= 'CLASS'
	        AND     hoi1.org_information1 		= 'HR_LEGAL'
	        AND     hoi1.org_information2 		= 'Y'
	        AND     hoi2.organization_id(+) 	= hou.organization_id
	        AND     hoi2.org_information_context 	= 'Employer Identification'
	        AND     hoi3.organization_id(+) 	= hou.organization_id
	        AND     hoi3.org_information_context(+)	= 'New Hire Reporting'
	        AND     hoi4.organization_id(+)      = hou.organization_id
                AND     hoi4.org_information_context(+) = 'State Tax Rules'
                AND     hoi4.org_information1(+) = NVL(P_STATE_CODE,hoi4.org_information4(+))
                ;

      CURSOR c_tx_term_number IS
								select
	 		count(ppf.person_id)

		From
			per_all_people_f 		ppf
			,per_all_assignments_f		paf
			,hr_soft_coding_keyflex		hscf
			,hr_locations_all		hl   			,per_jobs			job
			,per_periods_of_service 	pps
                        ,hr_organization_information          hoi4
                        ,hr_organization_information          hoi3
	                ,hr_organization_information          hoi2
	                ,hr_organization_information          hoi1
	                ,hr_organization_units                hou

                Where
			pps.person_id				= ppf.person_id

		And	fnd_date.canonical_to_date(P_REPORT_DATE)
			between ppf.effective_start_date and ppf.effective_end_date
				And	ppf.person_id				= paf.person_id
		And 	not exists (select 1 from per_all_assignments_f paf2
				where ppf.person_id = paf2.person_id
				and fnd_date.canonical_to_date(P_REPORT_DATE)
				between paf2.effective_start_date and paf2.effective_end_date
			)
		And	pps.date_start				= paf.effective_start_date

		And	hscf.segment1			= to_char(hou.organization_id)
		and	hou.business_group_id		= P_BUSINESS_GROUP_ID
		and 	hou.organization_id		= NVL(P_TAX_UNIT_ID,hou.organization_id)
		and	hl.region_2			= DECODE(P_MULTI_STATE_1,'N',P_STATE_CODE,hl.region_2)
				And	paf.soft_coding_keyflex_id		= hscf.soft_coding_keyflex_id
		And 	paf.assignment_type			= 'E'
		And	paf.primary_flag			= 'Y'
		And	paf.location_id				= hl.location_id
               	And	paf.job_id				= job.job_id(+)
		And	fnd_date.canonical_to_date(P_REPORT_DATE)	between job.date_from(+)
								and     nvl(job.date_to, C_END_OF_TIME)
		And     ppf.business_group_id	 		= P_BUSINESS_GROUP_ID
		And	ppf.per_information_category    	= 'US'
		And    	ppf.start_date  	<= fnd_date.canonical_to_date(P_REPORT_DATE)
		And     ppf.per_information7 	= 'INCL' 		And     hou.business_group_id           = ppf.business_group_id
               	        AND     hoi1.organization_id 		= hou.organization_id
	        AND     hoi1.org_information_context 	= 'CLASS'
	        AND     hoi1.org_information1 		= 'HR_LEGAL'
	        AND     hoi1.org_information2 		= 'Y'
	        AND     hoi2.organization_id(+) 	= hou.organization_id
	        AND     hoi2.org_information_context 	= 'Employer Identification'
	        AND     hoi3.organization_id(+) 	= hou.organization_id
	        AND     hoi3.org_information_context(+)	= 'New Hire Reporting'
	        AND     hoi4.organization_id(+)      = hou.organization_id
                AND     hoi4.org_information_context(+) = 'State Tax Rules'
                AND     hoi4.org_information1(+) = NVL(P_STATE_CODE,hoi4.org_information4(+))
                ;



BEGIN
   hr_utility.set_location('Entering.. ' || l_name,10);
   l_location_id := gre_location_id;
   hr_utility.trace('l_location_id = ' || l_location_id);
   hr_utility.set_location(l_name,20);
   hr_utility.trace('p_state_code = ' || p_state_code);

   if p_state_code = 'CA' then
              hr_utility.set_location(l_name,30);
     hr_utility.trace('cp_pre_tax_unit_id = ' || cp_pre_tax_unit_id);
     hr_utility.trace('tax_unit_id     =    ' || tax_unit_id);

     per_new_hire_pkg.get_location_address
      (l_location_id,l_address,l_city,l_state,l_zip,l_zip_extension);


     if cp_pre_tax_unit_id is NULL then
        	a01_header_record(TAX_UNIT_ID,federal_id) ;
        				l_buffer := per_new_hire_pkg.ca_e4_record(
		 p_record_identifier	=> 'E4'
		,p_federal_id           => FEDERAL_ID
		,p_sit_company_state_id	=> SIT_COMPANY_STATE_ID
		,p_branch_code   	=> l_branch_code
		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_street_address	=> l_address
		,p_city          	=> l_city
                ,p_state                => l_state
    		,p_zip   		=> l_zip
		,p_zip_extension 	=> l_zip_extension
	);
	hr_utility.trace('l_buffer = ' || l_buffer);
	--file_io.put(l_buffer);
        cp_pre_tax_unit_id := tax_unit_id;
        c_no_of_newhire := 0;
        c_no_of_gre := c_no_of_gre + 1;
  	      elsif cp_pre_tax_unit_id <> tax_unit_id then
       				l_buffer := per_new_hire_pkg.ca_t4_record(
		p_record_identifier	=> 'T4'
		,p_number_of_employee    => C_NO_OF_NEWHIRE
	);

 	hr_utility.trace('l_buffer = ' || l_buffer);
		--file_io.put(l_buffer);

        a01_header_record(TAX_UNIT_ID,federal_id) ;

        			l_buffer := per_new_hire_pkg.ca_e4_record(
		 p_record_identifier	=> 'E4'
		,p_federal_id           => FEDERAL_ID
		,p_sit_company_state_id	=> SIT_COMPANY_STATE_ID
		,p_branch_code   	=> l_branch_code
		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_street_address	=> l_address
		,p_city          	=> l_city
                ,p_state                => l_state
    		,p_zip   		=> l_zip
		,p_zip_extension 	=> l_zip_extension
	);
	hr_utility.trace('l_buffer = ' || l_buffer);
	--file_io.put(l_buffer);
        cp_pre_tax_unit_id := tax_unit_id;
        c_no_of_newhire := 0;
        c_no_of_gre := c_no_of_gre + 1;
      end if;

    elsif p_state_code = 'NY' then
      	hr_utility.set_location(l_name,40);
     	hr_utility.trace('p_report_date = ' || p_report_date);
        per_new_hire_pkg.get_location_address
         (l_location_id,l_address,l_city,l_state,l_zip,l_zip_extension);

        if cp_pre_tax_unit_id is NULL then
          hr_utility.set_location(l_name,41);
				  open c_transmitter;
          fetch c_transmitter into l_trans_tax_unit_name,l_trans_federal_id,
      		  l_trans_tax_unit_id,l_trans_location_id;
          if c_transmitter%NOTFOUND then
	    hr_utility.set_location(l_name,42);
            close c_transmitter;
	    /*srw.message('100', 'You have selected New York to be your reporting state, but have not identified a GRE as the transmitter for the New Hire report.');*/null;

            /*srw.message('100', 'Please select one of your GREs as the transmitter for this report in the New Hire Reporting organization information type.');*/null;

            c_fatal_error_flag := 1;
            fnd_message.raise_error;
          else
            open c_transmitter_count;
 	    fetch c_transmitter_count into l_transmitter_count;
 	    hr_utility.trace('transmitter count = ' || to_char(l_transmitter_count));
	    if l_transmitter_count > 1 then
              hr_utility.set_location(l_name,43);
	      close c_transmitter_count;
              close c_transmitter;
              c_fatal_error_flag := 2;
              /*srw.message('100', 'You have selected New York to be your reporting state, and have identified two GREs as the transmitter for the New Hire report.');*/null;

              /*srw.message('100', 'Please select only one of your GREs as the transmitter for this report in the New Hire Reporting organization information type. ');*/null;

              fnd_message.raise_error;
	    end if;
            close c_transmitter_count;
	  end if;
          	  	  close c_transmitter;
	  hr_utility.trace('transmitter_tax_unit_name = ' || l_trans_tax_unit_name);
          hr_utility.trace('transmitter_federal_id =    ' || l_trans_federal_id);
          hr_utility.trace('transmitter_location_id =   ' || to_char(l_trans_location_id));

          per_new_hire_pkg.get_location_address
  	    (l_trans_location_id,l_trans_address
            ,l_trans_city,l_trans_state,l_trans_zip,l_trans_zip_extension);


	  l_buffer := per_new_hire_pkg.ny_1a_record(
		 p_record_identifier	=> '1A'
		,p_creation_date	=> to_char(SYSDATE,'MMDDRR')
		,p_federal_id   	=> l_trans_federal_id
		,p_tax_unit_name	=> l_trans_tax_unit_name
		,p_street_address	=> l_trans_address
		,p_city          	=> l_trans_city
                ,p_state                => l_trans_state
    		,p_zip   		=> l_trans_zip
        	);

	  	  hr_utility.set_location(l_name,42);
	 /*file_io.put(l_buffer);

           	  file_io.put_a01('Transmitter Record' || g_delimiter);
 	  file_io.put_a01(g_delimiter);
 	  file_io.put_a01('Name                                : ' || upper(l_trans_tax_unit_name) || g_delimiter);
          file_io.put_a01('FEIN                                : ' || upper(l_trans_federal_id) || g_delimiter);
 	  file_io.put_a01('Address                             : ' || upper(l_trans_address) || g_delimiter);
 	  file_io.put_a01('City                                : ' || upper(l_trans_city) || g_delimiter);
	  file_io.put_a01('State                               : ' || upper(l_trans_state) || g_delimiter);
	  if l_trans_zip_extension is null then
	    file_io.put_a01('zip                                 : ' || l_trans_zip || g_delimiter);
 	  else
 	    file_io.put_a01('zip                                 : ' || l_trans_zip || '-' || l_trans_zip_extension || g_delimiter);
 	  end if;
 	  file_io.put_a01(g_delimiter); */
          	  a01_header_record(TAX_UNIT_ID,federal_id) ;


	  l_buffer := per_new_hire_pkg.ny_1e_record(
		 p_record_identifier	=> '1E'
		,p_federal_id   	=> FEDERAL_ID
		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_street_address	=> l_address
		,p_city          	=> l_city
                ,p_state                => l_state
    		,p_zip   		=> l_zip
	  );
	  hr_utility.set_location(l_name,45);
	  hr_utility.trace('l_buffer = ' || l_buffer);
	 -- file_io.put(l_buffer);
	  cp_pre_tax_unit_id := tax_unit_id;
          c_no_of_newhire := 0;
	  c_no_of_gre := 1;

        elsif cp_pre_tax_unit_id <> tax_unit_id then
	  hr_utility.set_location(l_name,50);

          a01_header_record(TAX_UNIT_ID,federal_id) ;

	  	  	  	  l_buffer := per_new_hire_pkg.ny_1t_record(
		 p_record_identifier  	=> '1T'
		,p_number_of_employee  	=> C_NO_OF_NEWHIRE
	  );

 	  hr_utility.trace('l_buffer = ' || l_buffer);
	  	--  file_io.put(l_buffer);
	   	            	  l_buffer := per_new_hire_pkg.ny_1e_record(
		 p_record_identifier	=> '1E'
		,p_federal_id   	=> FEDERAL_ID
		,p_tax_unit_name	=> TAX_UNIT_NAME
		,p_street_address	=> l_address
		,p_city          	=> l_city
                ,p_state                => l_state
    		,p_zip   		=> l_zip
	  );
	  hr_utility.set_location(l_name,60);
	  hr_utility.trace('l_buffer = ' || l_buffer);
	--  file_io.put(l_buffer);
  	  cp_pre_tax_unit_id := tax_unit_id;
          c_no_of_newhire := 0;
	  C_no_of_gre := c_no_of_gre + 1;
	end if;
   elsif p_state_code = 'TX' then
     hr_utility.set_location(l_name,70);
     if cp_pre_tax_unit_id is NULL then
        hr_utility.set_location(l_name,71);
	a01_header_record(TAX_UNIT_ID,federal_id) ;
        cp_pre_tax_unit_id := tax_unit_id;
                               open c_tx_emp_number;
       fetch c_tx_emp_number into l_tx_emp_num;
       if c_tx_emp_number%NOTFOUND then
         l_tx_emp_num := 0;
       end if;
       close c_tx_emp_number;

       hr_utility.trace('l_tx_emp_num = ' || l_tx_emp_num);
       open c_tx_term_number;
       fetch c_tx_term_number into l_tx_term_num;
       if c_tx_term_number%NOTFOUND then
         l_tx_term_num := 0;
       end if;
       close c_tx_term_number;
       hr_utility.trace('l_tx_term_num = ' || l_tx_term_num);

	l_buffer := per_new_hire_pkg.tx_t4_record(
		p_record_identifier	=> 'T4'
	       ,p_number_of_employee    => l_tx_emp_num + l_tx_term_num
	);

 	hr_utility.trace('l_buffer = ' || l_buffer);
		--file_io.put(l_buffer);
     elsif cp_pre_tax_unit_id <> tax_unit_id then
        hr_utility.set_location(l_name,72);
        a01_header_record(TAX_UNIT_ID,federal_id) ;
        cp_pre_tax_unit_id := tax_unit_id;
     end if;
      else      hr_utility.set_location(l_name,80);
     if cp_pre_tax_unit_id is NULL then
        hr_utility.set_location(l_name,81);
	a01_header_record(TAX_UNIT_ID,federal_id) ;
        cp_pre_tax_unit_id := tax_unit_id;
     elsif cp_pre_tax_unit_id <> tax_unit_id then
        hr_utility.set_location(l_name,82);
        a01_header_record(TAX_UNIT_ID,federal_id) ;
        cp_pre_tax_unit_id := tax_unit_id;
     end if;
   end if;
  hr_utility.set_location('Leaving... ' || l_name,100);
    exception when others then
                hr_utility.set_location('Leaving....' || l_name,999);
                c_fatal_error_flag := 6;
                fnd_message.raise_error;

END;

PROCEDURE P_OUTPUT_NEW_HIRE_NULL IS
BEGIN

DECLARE
CURSOR c_person_id IS
		select
	 		 ppf.person_id
			,ppf.last_name 		LAST_NAME
			,ppf.first_name		FIRST_NAME
                        ,substr(ppf.middle_names,1,1) middle_name
                	,ppf.national_identifier
			,ppf.date_of_birth
                        ,pps.date_start
                        ,hl.region_2 	 	STATE

		From
			per_all_people_f 		ppf
			,per_all_assignments_f		paf
			,hr_soft_coding_keyflex		hscf
			,hr_locations_all		hl   			,per_jobs			job
			,per_periods_of_service 	pps

                Where
			pps.person_id				= ppf.person_id
					And	fnd_date.canonical_to_date(P_REPORT_DATE)
			between pps.date_start and NVL(pps.actual_termination_date, C_END_OF_TIME)
			And	fnd_date.canonical_to_date(P_REPORT_DATE)
			between ppf.effective_start_date and ppf.effective_end_date
				And	ppf.person_id				= paf.person_id
				And 	fnd_date.canonical_to_date(P_REPORT_DATE)
			between paf.effective_start_date and paf.effective_end_date
		And	hscf.segment1				in
				(SELECT to_char(hou.organization_id )
				FROM     hr_organization_units    hou
				WHERE    hou.business_group_id    = P_BUSINESS_GROUP_ID
 				)
		And	paf.soft_coding_keyflex_id		= hscf.soft_coding_keyflex_id
		And 	paf.assignment_type			= 'E'
		And	paf.primary_flag			= 'Y'
		And	paf.location_id				= hl.location_id
                And     ((P_STATE_CODE = 'FL' and  P_MULTI_STATE_1 <> 'Y' and hl.region_2 = 'FL')
    			 or (P_STATE_CODE = 'FL' and  P_MULTI_STATE_1 = 'Y')
			 or (P_STATE_CODE <> 'FL')
                        )
		And	paf.job_id				= job.job_id(+)
		And	fnd_date.canonical_to_date(P_REPORT_DATE)	between job.date_from(+)
								and     nvl(job.date_to, C_END_OF_TIME)
		And     ppf.business_group_id	 		= P_BUSINESS_GROUP_ID
		And	ppf.per_information_category    	= 'US'
		And    	ppf.start_date  			<= fnd_date.canonical_to_date(P_REPORT_DATE)
		And     ppf.per_information7 	is NULL
		UNION
								select
	 		 ppf.person_id
			,ppf.last_name 		LAST_NAME
			,ppf.first_name		FIRST_NAME
                        ,substr(ppf.middle_names,1,1) middle_name
                	,ppf.national_identifier
			,ppf.date_of_birth
                        ,pps.date_start
                        ,hl.region_2 		STATE

		From
			per_all_people_f 		ppf
			,per_all_assignments_f		paf
			,hr_soft_coding_keyflex		hscf
			,hr_locations_all		hl   			,per_jobs			job
			,per_periods_of_service 	pps

                Where
			pps.person_id				= ppf.person_id

		And	fnd_date.canonical_to_date(P_REPORT_DATE)
			between ppf.effective_start_date and ppf.effective_end_date
				And	ppf.person_id				= paf.person_id
		And 	not exists (select 1 from per_all_assignments_f paf2
				where ppf.person_id = paf2.person_id
				and fnd_date.canonical_to_date(P_REPORT_DATE)
				between paf2.effective_start_date and paf2.effective_end_date
			)
		And	pps.date_start				= paf.effective_start_date
		And	hscf.segment1				in
				(SELECT to_char(hou.organization_id )
				FROM     hr_organization_units    hou
				WHERE    hou.business_group_id    = P_BUSINESS_GROUP_ID
 				)
		And	paf.soft_coding_keyflex_id		= hscf.soft_coding_keyflex_id
		And 	paf.assignment_type			= 'E'
		And	paf.primary_flag			= 'Y'
		And	paf.location_id				= hl.location_id
                And     ((P_STATE_CODE = 'FL' and  P_MULTI_STATE_1 <> 'Y' and hl.region_2 = 'FL')
    			 or (P_STATE_CODE = 'FL' and  P_MULTI_STATE_1 = 'Y')
			 or (P_STATE_CODE <> 'FL')
                        )
		And	paf.job_id				= job.job_id(+)
		And	fnd_date.canonical_to_date(P_REPORT_DATE)	between job.date_from(+)
								and     nvl(job.date_to, C_END_OF_TIME)
		And     ppf.business_group_id	 		= P_BUSINESS_GROUP_ID
		And	ppf.per_information_category    	= 'US'
		And    	ppf.start_date  			<= fnd_date.canonical_to_date(P_REPORT_DATE)
		And     ppf.per_information7 	is NULL
		Order by   2,3;


	v_person_id	per_all_people_f.person_id%TYPE;
	v_last_name	per_all_people_f.last_name%TYPE;
	v_first_name 	per_all_people_f.first_name%TYPE;
        v_middle_name 	per_all_people_f.middle_names%TYPE;
        v_ssn 	 	per_all_people_f.national_identifier%TYPE;
	v_dob		per_all_people_f.date_of_birth%TYPE;
 	v_date_start	per_periods_of_service.date_start%TYPE;
        v_header        number;
        v_buffer        varchar2(120);
        v_boolean       boolean;
        v_state         hr_locations_all.region_2%TYPE;


BEGIN
hr_utility.set_location('Entered p_output_new_hire_null',10);
v_header := 0;
if c_person_id%ISOPEN then
   close c_person_id;
end if;
OPEN c_person_id;
  FETCH c_person_id INTO v_person_id,v_last_name,v_first_name,v_middle_name,v_ssn,v_dob,v_date_start,v_state;
  WHILE c_person_id%FOUND LOOP
    if v_header = 0 then
      v_boolean := fnd_concurrent.set_completion_status('WARNING','');
      fnd_file.put_line(1,'Warning : The New Hire field of the following employees on people form is blank.');
      fnd_file.put_line(1,'Warning : Please update the New Hire field.');
      fnd_file.put_line(1,' ');
      fnd_file.put_line(1,'Last Name                 First Name          MI SSN         Hire Date DOB      ');
      fnd_file.put_line(1,' ') ;
      v_buffer := rpad(v_last_name,24,' ') ||
		  rpad(' ',1,' ') ||
	     	  rpad(nvl(v_first_name,' '),20,' ') ||
                  rpad(' ',1,' ') ||
 		  rpad(nvl(v_middle_name,' '),2,' ') ||
                  rpad(' ',1,' ') ||
	          rpad(nvl(v_ssn,' '),11,' ') ||
                  rpad(' ',1,' ') ||
		  rpad(to_date(v_date_start,'DD-MM-RRRR'),9,' ') ||
 	          rpad(' ',1,' ') ||
		  rpad(to_date(v_dob,'DD-MM-RRRR'),9,' ');
      fnd_file.put_line(1,v_buffer);
      v_header := 1;
    else
       v_buffer := rpad(v_last_name,24,' ') ||
		  rpad(' ',1,' ') ||
	     	  rpad(nvl(v_first_name,' '),20,' ') ||
                  rpad(' ',1,' ') ||
 		  rpad(nvl(v_middle_name,' '),2,' ') ||
                  rpad(' ',1,' ') ||
	          rpad(nvl(v_ssn,' '),11,' ') ||
                  rpad(' ',1,' ') ||
		  rpad(to_date(v_date_start,'DD-MM-RRRR'),9,' ') ||
		  rpad(' ',1,' ') ||
 		  rpad(to_date(v_dob,'DD-MM-RRRR'),9,' ') ;
      fnd_file.put_line(1,v_buffer);
     end if;
          FETCH c_person_id INTO v_person_id,v_last_name,v_first_name,v_middle_name,v_ssn,v_dob,v_date_start,v_state;

   END LOOP;
   fnd_file.put_line(1,' ');

hr_utility.set_location('p_output_new_hire_null',100);

CLOSE c_person_id;
exception
	when others then
		/*srw.message(290, 'The error message is '||sqlerrm);*/null;

                rollback;
END;

END;

--Functions to refer Oracle report placeholders--

 Function CP_pre_tax_unit_id_p return number is
	Begin
	 return CP_pre_tax_unit_id;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_TAX_UNIT_p return varchar2 is
	Begin
	 return C_TAX_UNIT;
	 END;
 Function C_STATE_NAME_p return varchar2 is
	Begin
	 return C_STATE_NAME;
	 END;
 Function C_MEDICAL_AVAIL_p return varchar2 is
	Begin
	 return C_MEDICAL_AVAIL;
	 END;
 Function C_END_OF_TIME_p return date is
	Begin
	 return C_END_OF_TIME;
	 END;
 Function C_STATE_COUNT_p return number is
	Begin
	 return C_STATE_COUNT;
	 END;
 Function C_OLD_STATE_p return varchar2 is
	Begin
	 return C_OLD_STATE;
	 END;
 Function C_no_of_newhire_p return number is
	Begin
	 return C_no_of_newhire;
	 END;
 Function C_no_of_gre_p return number is
	Begin
	 return C_no_of_gre;
	 END;
 Function C_no_of_multi_state_p return number is
	Begin
	 return C_no_of_multi_state;
	 END;
 Function C_Fatal_error_flag_p return number is
	Begin
	 return C_Fatal_error_flag;
	 END;
 Function C_a03_header_flag_p return number is
	Begin
	 return C_a03_header_flag;
	 END;
END PER_PERUSHRM_XMLP_PKG ;

/
