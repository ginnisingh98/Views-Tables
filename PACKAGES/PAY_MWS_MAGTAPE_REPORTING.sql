--------------------------------------------------------
--  DDL for Package PAY_MWS_MAGTAPE_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MWS_MAGTAPE_REPORTING" AUTHID CURRENT_USER as
/* $Header: pymwsrep.pkh 115.0 99/07/17 06:17:21 porting ship $ */

 /* 'level_cnt' will allow the cursors to select function results,
    whether it is a standard fuction such as to_char or a function
    defined in a package (with the correct pragma restriction).
 */

  level_cnt	number;

  TYPE numeric_data_table  IS TABLE OF number(15)
                                INDEX BY BINARY_INTEGER;
  TYPE character_data_table  IS TABLE OF varchar2(240)
                                INDEX BY BINARY_INTEGER;

  /* Sets up the tax unit context for the transmitter. */

 cursor us_mws_transmitter is
   select 'TAX_UNIT_ID=C'      , 	  htv.tax_unit_id,
	  'TRANSFER_CONTACT_TITLE=P', 	  htv.mws_title,
	  'TRANSFER_CONTACT_TELEPHONE=P', htv.mws_telephone_no,
	  'TRANSFER_TRANS_NAME=P',        htv.name,
	  'TRANSFER_TRANS_ADDR_LINE_1=P', htv.address_line_1,
	  'TRANSFER_TRANS_ADDR_LINE_2=P', htv.address_line_2,
	  'TRANSFER_TRANS_ADDR_LINE_3=P', htv.address_line_3,
	  'TRANSFER_TRANS_CITY=P',        htv.town_or_city,
	  'TRANSFER_TRANS_STATE=P',       htv.state_code,
	  'TRANSFER_TRANS_ZIP_CODE=P',    htv.zip_code,
	  'TRANSFER_TAPE_MEDIUM=P',       htv.mws_tape_medium,
	  'TRANSFER_TAPE_DENSITY=P',      htv.mws_tape_density,
	  'TRANSFER_HEADER_LABEL=P',      htv.mws_header_label
   from   hr_tax_units_v  htv
   where  htv.tax_unit_id = pay_magtape_generic.get_parameter_value
	                     ('TRANSFER_TRANS_LEGAL_CO_ID')
   and	  htv.business_group_id = pay_magtape_generic.get_parameter_value
				('TRANSFER_BUSINESS_GROUP');


  /* Sets up the State context for US_MWS_GET_STATE formula and the State
     parameter for the us_mws_sui cursor */

  cursor us_mws_state is
    select distinct 'TRANSFER_MWS_STATE=P', hwv.mws_state ,
    		    'TRANSFER_FIPS_CODE=P', psr.fips_code
    from HR_WORKSITE_V   hwv,
	 PAY_STATE_RULES psr
    where hwv.mws_business_group_id = pay_magtape_generic.get_parameter_value
					('TRANSFER_BUSINESS_GROUP')
    and psr.state_code = hwv.mws_state
    order by hwv.mws_state;

  /* Get the SUIs within the state and set up the SUI A/C and the Tax unit Id
     as the parameter for us_mws_worksite cursor. Also set the context of the
     TAX_UNIT_ID of the SUI A/C, for the database items */

  cursor us_mws_sui is
    select distinct 'TRANSFER_SUI_ACCOUNT_NO=P', hwv.mws_sui_account_no,
    'MWS_TAX_UNIT_ID=P', hwv.mws_tax_unit_id,
    'TAX_UNIT_ID=C', hwv.mws_tax_unit_id
    from HR_WORKSITE_V hwv
    where hwv.mws_state = pay_magtape_generic.get_parameter_value
				('TRANSFER_MWS_STATE')
    and hwv.mws_business_group_id = pay_magtape_generic.get_parameter_value
					('TRANSFER_BUSINESS_GROUP')
    order by hwv.mws_sui_account_no;


   /* Get worksites within a SUI. Set up the context of Organization id (the
      primary organization id for the worksite). Also set up the
      TRANSFER_WORKSITE_RUN as a parameter for
      us_mws_worksite_organization cursor */

   cursor us_mws_worksite is
     select 'TRANSFER_WORKSITE_RUN=P', hwv.mws_reporting_unit_no,
     'TRANSFER_WORKSITE_TRADE_NAME=P', hwv.mws_trade_name,
     'TRANSFER_WORKSITE_DESCRIPTION=P', hwv.mws_worksite_description,
     'TRANSFER_WORKSITE_COMMENT_CODE1=P', hwv.mws_comment_code1,
     'TRANSFER_WORKSITE_COMMENT_CODE2=P', hwv.mws_comment_code2,
     'TRANSFER_WORKSITE_COMMENTS=P', hwv.mws_comments,
     'TRANSFER_WORKSITE_ADDRESS_LINE_1=P', hwv.mws_address_line_1,
     'TRANSFER_WORKSITE_ADDRESS_LINE_2=P', hwv.mws_address_line_2,
     'TRANSFER_WORKSITE_ADDRESS_LINE_3=P', hwv.mws_address_line_3,
     'TRANSFER_WORKSITE_CITY=P', hwv.mws_city,
     'TRANSFER_WORKSITE_STATE=P', hwv.mws_state,
     'TRANSFER_WORKSITE_ZIP_CODE=P', hwv.mws_zip_code
     from HR_WORKSITE_V hwv
     where hwv.mws_sui_account_no = pay_magtape_generic.get_parameter_value
				('TRANSFER_SUI_ACCOUNT_NO')
    and hwv.mws_tax_unit_id = pay_magtape_generic.get_parameter_value
					('MWS_TAX_UNIT_ID')
    and hwv.mws_state = pay_magtape_generic.get_parameter_value
					('TRANSFER_MWS_STATE')
    and hwv.mws_business_group_id = pay_magtape_generic.get_parameter_value
					('TRANSFER_BUSINESS_GROUP')
    order by hwv.mws_reporting_unit_no;


    /* Get all the organizations belonging to the worksite . We will check
       to see that the RUN i.e. org_information3 of the table if not null */

   cursor us_mws_worksite_organization is
     select 'ORGANIZATION_ID=C', hoi.organization_id,
     'ORGANIZATION_ID=P', hoi.organization_id
     from HR_ORGANIZATION_INFORMATION hoi
     where hoi.org_information_context = 'Worksite Filing'
	and hoi.org_information3 is not null
	and hoi.org_information2 = pay_magtape_generic.get_parameter_value
				('TRANSFER_SUI_ACCOUNT_NO')
    	and hoi.org_information3 = pay_magtape_generic.get_parameter_value
					('TRANSFER_WORKSITE_RUN')
        order by hoi.organization_id;



    /* Get all the employees  belonging to an organization of the worksite.
	We will check for the primary flag of PER_ASSIGNMENTS_F to be Y, in
	order to see that it is the primary assignment of the employee */

   cursor us_mws_organization_employees is
     select 'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
     'ASSIGNMENT_ID=C', paa.assignment_id,
     'TRANSFER_WAGES_EARNED=P', ltrim(substr(paa.serial_number,1,20)),
     'TRANSFER_ASG_START_DATE=P',to_char(paf.effective_start_date,'DD-MM-YYYY'),
     'TRANSFER_ASG_END_DATE=P', to_char(paf.effective_end_date,'DD-MM-YYYY')
     from PAY_PAYROLL_ACTIONS ppa,
	  PAY_ASSIGNMENT_ACTIONS paa,
	  PER_ASSIGNMENTS_F paf,
	  PER_PEOPLE_F  ppf,
          HR_SOFT_CODING_KEYFLEX scl
        where ppa.payroll_action_id = pay_magtape_generic.get_parameter_value
				   ('TRANSFER_PAYROLL_ACTION_ID')
        and paa.payroll_action_id = ppa.payroll_action_id
	and paf.assignment_id = paa.assignment_id
	and paf.organization_id = pay_magtape_generic.get_parameter_value
					('ORGANIZATION_ID')
        and paf.effective_end_date = to_date((substr(paa.serial_number,21,10)),
					'DD-MM-YYYY')
        and scl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
        and scl.segment1 = paa.tax_unit_id
	and paf.primary_flag = 'Y'
        and ppf.person_id = paf.person_id;

 procedure redo
 (
  errbuf               out varchar2,
  retcode              out number,
  p_payroll_action_id  in varchar2
 );

 procedure Run_Magtape
 (
  p_effective_date     date,
  p_report_type        varchar2,
  p_payroll_action_id  varchar2,
  p_state              varchar2,
  p_reporting_year     varchar2,
  p_reporting_quarter  varchar2,
  p_trans_legal_co_id  varchar2,
  p_quarter_start      date,
  p_quarter_end	       date,
  p_business_group_id  varchar2
 );

 procedure run
 (
  errbuf                out varchar2,
  retcode               out number,
  p_business_group_id   in number,
  p_report_type		in varchar2,
  p_quarter		in varchar2,
  p_year                in varchar2,
  p_trans_legal_co_id   in number
 );

 function generate_people_list
 (
  p_report_type       varchar2,
  p_state             varchar2,
  p_trans_legal_co_id varchar2,
  p_business_group_id number,
  p_period_end        date,
  p_quarter_start     date,
  p_quarter_end       date
 )return number;

end pay_mws_magtape_reporting;


 

/
