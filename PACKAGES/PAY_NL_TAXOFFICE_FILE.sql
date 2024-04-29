--------------------------------------------------------
--  DDL for Package PAY_NL_TAXOFFICE_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_TAXOFFICE_FILE" AUTHID CURRENT_USER as
/* $Header: pynltosf.pkh 120.0.12000000.1 2007/01/17 23:04:58 appldev noship $ */
level_cnt NUMBER;
/*-------------------------------------------------------------------------------
|Name           : RANGE_CODE                                       		        |
|Type		: Procedure							                                |
|Description    : This procedure returns a sql string to select a range of 	    |
|		  assignments eligible for archival		  		                        |
-------------------------------------------------------------------------------*/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2);



/*-------------------------------------------------------------------------------
|NAME           : ASSIGNMENT_ACTION_CODE                                      	|
|TYPE		    : PROCEDURE							                            |
|DESCRIPTION    : THIS PROCEDURE FURTHER RESTRICTS THE ASSIGNMENT ID'S RETURNED |
|		  BY THE RANGE CODE.                                           	        |
-------------------------------------------------------------------------------*/

Procedure ASSIGNMENT_ACTION_CODE (p_payroll_action_id  in number
				  ,p_start_person_id   in number
				  ,p_end_person_id     in number
				  ,p_chunk             in number);


/*----------------------------------------------------------------------------------
|Name           : ARCHIVE_INIT                                            	   |
|Type		    : Procedure							   |
|Description    : Procedure sets the global tables g_statutory_balance_table,      |
|		          g_stat_element_table,g_user_balance_table,g_element_table|
-----------------------------------------------------------------------------------*/

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER);

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_CODE                                            	|
|Type		: Procedure							|
|Description    : This is the main procedure which calls the several procedures |
|		  to archive the data.						|
-------------------------------------------------------------------------------*/

Procedure ARCHIVE_CODE (p_assignment_action_id                 IN NUMBER
	     	       ,p_effective_date                       IN DATE);



/*------------------------------------------------------------------------------
|Name           : GET_PARAMETER    					        |
|Type		    : Function							|
|Description    : Funtion to get the parameters of the archive process     	|
-------------------------------------------------------------------------------*/

Function get_parameter(
		 p_parameter_string in varchar2
		,p_token            in varchar2
		,p_segment_number   in number default null )RETURN varchar2;

/*-----------------------------------------------------------------------------
|Name       : GET_ALL_PARAMETERS                                               |
|Type       : Procedure							       |
|Description: Procedure which returns all the parameters of the archive	process|
-------------------------------------------------------------------------------*/

PROCEDURE get_all_parameters (
          p_payroll_action_id     IN         NUMBER
         ,p_business_group_id     OUT NOCOPY NUMBER
         ,p_effective_date        OUT NOCOPY DATE
         ,p_tax_year              OUT NOCOPY date
         ,p_employer              OUT NOCOPY number
         ,p_org_struct_id         OUT NOCOPY number  ) ;


/*-----------------------------------------------------------------------------
|Name       : Get_TOS_Sender_Details                                           |
|Type       : Function							       |
|Description: Function which returns Tax office and Sender Details	       |
-------------------------------------------------------------------------------*/


FUNCTION Get_TOS_Sender_Details(P_Business_Group_Id in number
				,P_Employer_ID in number
				,P_Sender_Tax_Rep_Name out nocopy varchar2
				,P_Sender_Tax_Reg_Number out nocopy varchar2
				,P_Tax_Rep_Name out nocopy varchar2
				,P_Tax_Reg_Number out nocopy varchar2) return number;





/********************************************************
*       Cursor to fetch header record information       *
********************************************************/
/* Cursor for driving the Header Formula - NL_TAXOFFICE_FILE_HEADER
and the Trailer Formula -- NL_TAXOFFICE_FILE_TRAILER
to generate the following records in the electronic file
Record Type -1 Sender Identification Record and
Record Type -3 Employer Identification Record and
Record Type -7 Employer Closing Record and
Record Type -9 Sender Closing Record
*/

Cursor Csr_NL_TaxOff_Header IS
SELECT
'TAX_YEAR=P',pay_magtape_generic.get_parameter_value('REPORT_YEAR'),
'BUSINESS_GROUP_ID=P',ppa.business_group_id,
'EMPLOYER_ID=P',pay_magtape_generic.get_parameter_value('EMPLOYER_ID'),
'ORG_STRUCT_ID=P',pay_magtape_generic.get_parameter_value('ORG_HIERARCHY'),
'MEDIUM_CODE=P',pay_magtape_generic.get_parameter_value('MEDIUM_CODE'),
'DENSITY=P',pay_magtape_generic.get_parameter_value('DENSITY_CODE')
FROM   pay_payroll_actions ppa
WHERE    ppa.payroll_action_id
=pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');



/********************************************************
*   Cursor to fetch batch/payment record information    *
********************************************************/

/* Cursor for driving the Body Formula - NL_TAXOFFICE_FILE_BODY
to generate the following records in the electronic file
Record Type -5 Employee Identification Record and
Record Type -7 Employee Fiscal Record and
*/
Cursor Csr_NL_TaxOff_Body IS
SELECT
	'ATS_EMPLOYER_ID=P'			,ee_ats.action_information1 ,
	'ATS_PERSON_ID=P'			,ee_ats.action_information2 ,
	'ATS_ASSIGNMENT_ID=P'			,ee_ats.action_information3 ,
	'DATE_OF_BIRTH=P'			,TO_CHAR(pap.Date_of_Birth,'DDMMYYYY') ,
	'SOFI_NUMBER=P'				,pap.National_Identifier,
	'EMPLOYEE_NAME=P'			,pap.last_name,
	'WAGE=P'				,ee_ats.action_information4 ,
	'DEDUCT_WAGE_TAX_NI_CONT=P'		,ee_ats.action_information5 ,
	'ASG_TAXYEAR_START_DATE=P'		,ee_ats.action_information6 ,
	'ASG_TAXYEAR_END_DATE=P'		,ee_ats.action_information7 ,
	'LABOUR_DISCOUNT=P'			,ee_ats.action_information8 ,
	'WAGE_TAX_DISCOUNT=P'			,ee_ats.action_information9,
	'WAGE_TAX_TABLE_CODE=P'			,ee_ats.action_information10 ,
	'INCOME_CODE=P'				,ee_ats.action_information11 ,
	'SPECIAL_INDICATOR=P'			,ee_ats.action_information12 ,
	'AMOUNT_SPECIAL_INDICATOR=P'		,ee_ats.action_information13
FROM
pay_assignment_actions pay_act,
pay_action_interlocks arc_lck,
pay_action_information ee_ats,
per_all_people_f pap
WHERE    pay_act.payroll_action_id
=pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
AND pay_act.assignment_action_id = arc_lck.locking_action_id
AND arc_lck.locked_action_id = ee_ats.action_context_id
AND ee_ats.action_context_type='AAP'
AND ee_ats.action_information_category = 'NL ATS EMPLOYEE DETAILS'
AND ee_ats.action_information2 = fnd_number.number_to_canonical(pap.person_id)
and ee_ats.effective_date between pap.effective_start_date and pap.effective_end_date;

END PAY_NL_TAXOFFICE_FILE ;

 

/
