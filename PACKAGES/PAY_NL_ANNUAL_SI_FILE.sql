--------------------------------------------------------
--  DDL for Package PAY_NL_ANNUAL_SI_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_ANNUAL_SI_FILE" AUTHID CURRENT_USER as
/* $Header: pynlasif.pkh 120.0.12000000.1 2007/01/17 22:54:35 appldev noship $ */
level_cnt NUMBER;


 Cursor Csr_NL_Annual_SI_Header IS

 SELECT
 'TAX_YEAR=P',pay_magtape_generic.get_parameter_value('TAX_YEAR'),
 'BUSINESS_GROUP_ID=P',ppa.business_group_id,
 'EMPLOYER_ID=P',pay_magtape_generic.get_parameter_value('EMPLOYER_ID'),
 'ORG_HEIRARCHY_ID=P',pay_magtape_generic.get_parameter_value('ORG_HEIRARCHY'),
 'SI_PROVIDER_ID=P',pay_magtape_generic.get_parameter_value('SI_PROVIDER_ID')
 FROM   pay_payroll_actions ppa
 WHERE    ppa.payroll_action_id
 =pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
 AND EXISTS
 (select * from pay_assignment_actions paa
  where paa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'));


 Cursor Csr_NL_Annual_SI_Body IS
 SELECT
 	'ASI_EMPLOYER_ID=P'		,ee_asi.action_information1 ,
 	'ASI_SIP_ID=P'		        ,ee_asi.action_information3 ,
 	'ASI_ASSIGNMENT_ID=P'		,ee_asi.action_information2 ,
 	'ASI_PERSON_ID=P'		,ee_asi.action_information4 ,
 	'SOFI_NUMBER=P'			,pap.National_Identifier,
 	'ASI_NOD=P' 			,ee_asi.action_information5 ,
 	'ASI_SI_WAGE=P'		        ,ee_asi.action_information6 ,
 	'ASI_SUP_DAYS=P'  	        ,ee_asi.action_information7 ,
 	'ASI_AMT_ALLOWANCE=P'           ,ee_asi.action_information8 ,
 	'ASI_SPL_IND=P'		        ,ee_asi.action_information9
 FROM
 pay_assignment_actions pay_act,
 pay_action_interlocks arc_lck,
 pay_action_information ee_asi,
 per_all_people_f pap
 WHERE    pay_act.payroll_action_id
 =pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
 AND pay_act.assignment_action_id = arc_lck.locking_action_id
 AND arc_lck.locking_action_id = ee_asi.action_context_id
 AND ee_asi.action_context_type='AAP'
 AND ee_asi.action_information_category = 'NL ASI EMPLOYEE DETAILS'
 AND ee_asi.action_information4 = pap.person_id
 AND ee_asi.effective_date between pap.effective_start_date and pap.effective_end_date;


/*-------------------------------------------------------------------------------
|Name           : RANGE_CODE                                       		 |
|Type		: Procedure							 |
|Description    : This procedure returns a sql string to select a range of 	 |
|		  assignments eligible for archival		  		 |
-------------------------------------------------------------------------------*/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2);


/*--------------------------------------------------------------------
|Name       : ASSIGNMENT_ACTION_CODE  	                            |
|Type		: Procedure				            |
|Description: This procedure Fetches,validates and archives	    |
|	      information in the newly created context 		    |
|	      NL ATS EMPLOYEE DETAILS				    |
----------------------------------------------------------------------*/

Procedure ASSIGNMENT_ACTION_CODE (p_payroll_action_id  in number
				  ,p_start_person_id   in number
				  ,p_end_person_id     in number
				  ,p_chunk             in number);


/*----------------------------------------------------------------------------------
|Name           : ARCHIVE_INIT                                            	   |
|Type		    : Procedure							   |
|Description    : Initialization Code for Archiver				   |
-----------------------------------------------------------------------------------*/

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER);

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_CODE                                            	|
|Type		: Procedure							|
|Description    : Archival code for archiver					|
-------------------------------------------------------------------------------*/

Procedure ARCHIVE_CODE (p_assignment_action_id                 IN NUMBER
	     	       ,p_effective_date                       IN DATE);



/*-----------------------------------------------------------------------------
|Name       : GET_ALL_PARAMETERS                                               |
|Type       : Procedure							       |
|Description: Procedure which returns all the parameters of the archive	process|
-------------------------------------------------------------------------------*/

PROCEDURE get_all_parameters (
          p_payroll_action_id     IN         NUMBER
         ,p_business_group_id     OUT NOCOPY NUMBER
         ,p_si_provider_id        OUT NOCOPY NUMBER
         ,p_effective_date        OUT NOCOPY DATE
         ,p_tax_year              OUT NOCOPY DATE
         ,p_employer              OUT NOCOPY NUMBER
         ,p_org_struct_id         OUT NOCOPY NUMBER  ) ;


/*-----------------------------------------------------------------------------
|Name       : Get_SIP_Details                                                  |
|Type       : Function							       |
|Description: Procedure gets Reg Number , reporting name details at the        |
|                        SIP level                                             |
-------------------------------------------------------------------------------*/
FUNCTION Get_SIP_Details
( P_Employer_ID IN NUMBER
 ,P_SI_PROVIDER_ID IN NUMBER
 ,P_PROCESS_DATE IN DATE
 ,p_Sender_Rep_Name_sip OUT NOCOPY VARCHAR2
 ,p_Sender_Reg_Number_sip OUT NOCOPY VARCHAR2
 ,p_Employer_Rep_Name_sip OUT NOCOPY VARCHAR2
 ,p_Employer_Reg_Number_sip OUT NOCOPY VARCHAR2
 )RETURN NUMBER ;

/*-----------------------------------------------------------------------------
|Name       : GET_SI_WAGE                                                      |
|Type       : Function							       |
|Description: Function returns SI Wage - sum of SI_INCOME_STANDARD_TAX,        |
|             SI_INCOME_SPECIAL_TAX , RETRO_SI_INCOME_STANDARD_TAX ,           |
|              RETRO_SI_INCOME_SPECIAL_TAX                                     |
|                        SIP,ORG levels                                        |
-------------------------------------------------------------------------------*/

function get_si_wage(p_assgt_act_id number)RETURN number;

/*-----------------------------------------------------------------------------
|Name       : GET_SI_SUPPLEMENTARY_DAYS                                        |
|Type       : Function							       |
|Description: Function returns SI Supplementary Days -                         |
|             balance SI_SUPPLEMENATRY_DAYS                                    |
-------------------------------------------------------------------------------*/

function get_si_supplementary_days(p_assgt_act_id number)RETURN number;

/*-----------------------------------------------------------------------------
|Name       : GET_SI_AMOUNT_ALLOWANCE                                          |
|Type       : Function							       |
|Description: Function returns SI Amount Allowance -                           |
|             balance SI_AMOUNT_ALLOWANCE                                      |
-------------------------------------------------------------------------------*/

function get_si_amount_allowance(p_assgt_act_id number)RETURN number;

/*-----------------------------------------------------------------------------
|Name       : GET_SI_SPECIAL_INDICATOR                                         |
|Type       : Procedure 						       |
|Description: Function fetches the SI Special Indicator                        |
-------------------------------------------------------------------------------*/

PROCEDURE get_si_special_indicator(p_assignment_id IN NUMBER,
                                  l_si_special_indicator OUT NOCOPY VARCHAR2 );

/*-----------------------------------------------------------------------------
|Name       : GET_NUMBER_OF_DAYS                                               |
|Type       : Function							       |
|Description: Function returns Number Of Days -                                |
|             balance REAL_SOCIAL_INSURANCE_DAYS                               |
-------------------------------------------------------------------------------*/

function get_number_of_days(p_assgt_act_id number)RETURN number;

function get_org_name(p_org_id number
                      ,l_org_name OUT NOCOPY VARCHAR2)RETURN NUMBER;

END PAY_NL_ANNUAL_SI_FILE;

 

/
