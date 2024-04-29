--------------------------------------------------------
--  DDL for Package PAY_NL_NSI_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_NSI_PROCESS" AUTHID CURRENT_USER as
/* $Header: pynlnsia.pkh 115.1 2004/05/10 05:01:31 rtadikam noship $ */
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

 PROCEDURE get_all_parameters(
       p_payroll_action_id      IN   	    NUMBER
      ,p_business_group_id      OUT  NOCOPY NUMBER
      ,p_employer_id		    OUT  NOCOPY VARCHAR2
      ,p_si_provider_id		    OUT  NOCOPY VARCHAR2
      ,p_nsi_month              OUT  NOCOPY VARCHAR2
      ,p_output_media_type	    OUT  NOCOPY VARCHAR2
      ,p_payroll_id             OUT  NOCOPY VARCHAR2
      ,p_withdraw_asg_set_id    OUT  NOCOPY VARCHAR2
      ,p_report_type            OUT NOCOPY VARCHAR2) ;


/********************************************************
*       Cursor to fetch header record information       *
********************************************************/
CURSOR CSR_NL_NSIFILE_HEADER IS
SELECT  'SENDER_REGISTRATION_NUMBER=P'
	,nl_er_nsi.action_information3
        ,'SENDER_NAME=P'
	,nl_er_nsi.action_information4
	,'SENDER_ADDRESS=P'
	,nl_er_nsi.action_information5
	,'EMPLOYER_NAME=P'
	,nl_er_nsi.action_information6
	,'EMPLOYER_ADDRESS=P'
	,nl_er_nsi.action_information7
	,'EMPLOYER_REGISTRATION_NUMBER=P'
	,nl_er_nsi.action_information8
	,'OUTPUT_MEDIA_TYPE=P'
	,pay_magtape_generic.get_parameter_value('OUTPUT_MEDIA_TYPE')
FROM   pay_action_information nl_er_nsi
        ,pay_payroll_actions ppa
WHERE    nl_er_nsi.action_context_id=ppa.payroll_action_id
AND      ppa.payroll_action_id=pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
AND      nl_er_nsi.ACTION_CONTEXT_TYPE='PA'
AND      nl_er_nsi.ACTION_INFORMATION_CATEGORY='NL NSI EMPLOYER DETAILS'
AND      nl_er_nsi.effective_date between ppa.start_date
         and last_day(to_date('01'||pay_magtape_generic.get_parameter_value('NSI_MONTH'),'DDMMYYYY'));



/********************************************************
*   Cursor to fetch batch/payment record information    *
********************************************************/

CURSOR CSR_NL_NSIFILE_BODY IS
SELECT
    'NSI_PERSON_ID=P'
	,nl_ee_nsi.action_information2
    ,'NSI_ASSIGNMENT_ID=P'
	,nl_ee_nsi.action_information3
	,'TYPE_NOTIFICATION_A=P'
	,nvl(nl_ee_nsi.action_information9,'0')
	,'DATE_OF_NOTIFICATION_A=P'
 	,nvl(nl_ee_nsi.action_information10,'00000000')
	,'TYPE_NOTIFICATION_B=P'
	,nvl(nl_ee_nsi.action_information11,'0')
	,'DATE_OF_NOTIFICATION_B=P'
	,nvl(nl_ee_nsi.action_information12,'00000000')
	,'CODE_INSURANCE=P'
	,nl_ee_nsi.action_information13
	,'CODE_INSURANCE_BASIS=P'
	,nl_ee_nsi.action_information14
	,'CODE_OCCUPATION=P'
	,nl_ee_nsi.action_information15
	,'WORK_PATTERN=P'
	,nl_ee_nsi.action_information16
	,'START_DATE_LABOUR_RELATION=P'
	,nl_ee_nsi.action_information17
	,'SOFI_NUMBER=P'
	,nl_ee_nsi.action_information18
	,'EMPLOYEE_NAME=P'
	,nl_ee_nsi.action_information19
	,'EMPLOYEE_PRIMARY_ADDRESS=P'
	,nl_ee_nsi.action_information20
	,'EMPLOYEE_PR_ADDRESS=P'
	,nl_ee_nsi.action_information21
	,'GAK_REPORTING_INFO=P'
	,nl_ee_nsi.action_information22
	,'CADANS_REPORTING_INFO=P'
	,nl_ee_nsi.action_information23
	,'EMPLOYEE_DETAILS=P'
	,nl_ee_nsi.action_information24
  FROM   pay_action_information nl_ee_nsi
        ,pay_payroll_actions ppa
        ,pay_assignment_actions paa
 where nl_ee_nsi.ACTION_CONTEXT_ID= paa.assignment_Action_id
    	AND ppa.payroll_Action_id=paa.payroll_Action_id
        AND ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
        AND nl_ee_nsi.action_context_type='AAP'
        AND nl_ee_nsi.action_information_category = 'NL NSI EMPLOYEE DETAILS'
        AND nl_ee_nsi.effective_date BETWEEN ppa.start_date
        AND last_day(to_date('01'||pay_magtape_generic.get_parameter_value('NSI_MONTH'),'DDMMYYYY'))
 order by nl_ee_nsi.action_information_id;      --Bug No : 3612117
END PAY_NL_NSI_PROCESS;

 

/
