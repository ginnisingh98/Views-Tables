--------------------------------------------------------
--  DDL for Package PAY_NL_CBS_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_CBS_FILE" AUTHID CURRENT_USER as
/* $Header: pynlcbsf.pkh 120.0.12000000.1 2007/01/17 22:54:40 appldev noship $ */

-- +--------------------------------------------------------------------+
-- |                        PUBLIC FUNCTIONS                            |
-- +--------------------------------------------------------------------+
level_cnt         NUMBER;
hr_formula_error  EXCEPTION;
/********************************************************************************
|Name           : RANGE_CODE                                       		|
|Type		: Procedure							|
|Description    : This procedure returns a sql string to select a range of 	|
|		  assignments eligible for archival		  		|
*********************************************************************************/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2);

/*******************************************************************************|
|Name           : ASSIGNMENT_ACTION_CODE                                	|
|Type		: Procedure							|
|Description    : This procedure further restricts the assignment id's returned |
|		  by the range code.                                            |
*********************************************************************************/

Procedure ASSIGNMENT_ACTION_CODE (p_payroll_action_id  in number
				  ,p_start_person_id   in number
				  ,p_end_person_id     in number
				  ,p_chunk             in number);

/********************************************************************************
|Name           : ARCHIVE_INIT                                            	|
|Type		: Procedure							|
|Description    : Procedure sets the global tables g_statutory_balance_table,   |
|		  g_stat_element_table,g_user_balance_table,g_element_table.	|
*********************************************************************************/

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER);

/********************************************************************************
|Name           : ARCHIVE_CODE                                            	|
|Type		: Procedure							|
|Description    : This is the main procedure which calls the several procedures |
|		  to archive the data.						|
*********************************************************************************/
Procedure ARCHIVE_CODE (p_assignment_action_id                 IN NUMBER
	     	       ,p_effective_date                       IN DATE);

/********************************************************************************
|Name           : GET_ALL_PARAMETERS                                           	|
|Type		: Procedure							|
|Description    : Procedure which returns all the parameters of the archive	|
|		  process						   	|
*********************************************************************************/
PROCEDURE get_all_parameters (
          p_payroll_action_id         IN                    NUMBER
         ,p_business_group_id         OUT NOCOPY NUMBER
         ,p_reporting_date            OUT NOCOPY DATE
         ,p_effective_date            OUT NOCOPY DATE
         ,p_employer                  OUT NOCOPY NUMBER
         ,p_si_provider               OUT NOCOPY NUMBER
         ,p_org_struct_id             OUT NOCOPY NUMBER
         ,p_medium_code               OUT NOCOPY NUMBER
         ,p_density                   OUT NOCOPY NUMBER
  ) ;

/********************************************************************************
|Name           : Mandatory_Check                                           	|
|Type		: Procedure						        |
|Description    : Procedure to check if the specified Mandatory Field is NULL   |
|                 if so flag a Error message to the Log File                    |
*********************************************************************************/
Procedure Mandatory_Check(p_message_name  IN varchar2
			,p_field IN varchar2
			,p_value IN varchar2);

/********************************************************************************
|Name           : get_loc_extra_info                                            |
|Type		: Function						        |
|Description    : This Function returns extra information like Contact and      |
|                 Telephone No for Employer details 		  		|
*********************************************************************************/
Function get_loc_extra_info(p_org_id NUMBER
                                           ,p_contact OUT NOCOPY VARCHAR2
                                           ,p_telephone OUT NOCOPY VARCHAR2
					   ) return number;

/********************************************************************************
|Name           : get_er_sequence                                               |
|Type		: Function						        |
|Description    : This Function returns the next sequence number for            |
|                 employer                                                      |
*********************************************************************************/
Function Get_er_sequence(p_employer_id NUMBER
		     ,p_si_provider_id  NUMBER
	             ,p_reporting_date DATE
                     ,p_sequence OUT NOCOPY NUMBER ) return number;

/*******************************************************************************
|Name       : Get_Balances1                                                    |
|Type       : Function							       |
|Description: Function which returns all the balances required for CBS File    |
*******************************************************************************/
function get_balances1(    p_frequency varchar2
                          ,p_assgt_act_id number
                          ,l_holiday_hours out nocopy number
                          ,l_adv_hours out nocopy number
                          ,l_si_wage out nocopy number
                          ,l_unique_payments out nocopy number
                          ,l_pre_tax_deductions out nocopy number
                          ,l_saving_scheme out nocopy number
                          ,l_sickness_days out nocopy number
                          ,l_unpaid_hours out nocopy number
                          ,l_sickness_pay out nocopy number
                          ,l_overtime_hours out nocopy number
 )
return number;

/*******************************************************************************
|Name       : Get_Balances2                                                    |
|Type       : Function							       |
|Description: Function which returns all the balances required for CBS File    |
*******************************************************************************/
function get_balances2          ( p_frequency varchar2
                                 ,p_assgt_act_id number
                                 ,l_wage_agreed_by_contract out nocopy number
                                 ,l_number_of_days out nocopy number
                                 ,l_si_days_quarter out nocopy number
                                 ,l_paid_gross_wage out nocopy number
                                 ,l_wage_for_overtime out nocopy number
                                 ) return number;

/*******************************************************************************
|Name       : Get_health_insurance                                             |
|Type       : Function							       |
|Description: Function used to pick the si status of the assignment for ZFW    |
|             insurance. If health insurance is from a Private Insurance       |
|	      provider,the provider type of the Private Health Insurance       |
|	      Provider is returned.                                            |
*******************************************************************************/
Function get_health_insurance(p_assignment_id  IN number
                             ,p_date           IN date)
RETURN VARCHAR2;

/*******************************************************************************
|Name       : Get_working_schedule                                             |
|Type       : Function							       |
|Description: Function to get the postal code from the employee primary address|
*******************************************************************************/
PROCEDURE Get_working_schedule  (p_assignment_id IN NUMBER,
                                 p_working_schedule OUT NOCOPY NUMBER,
                                 p_reporting_start_date IN DATE,
                                 p_reporting_end_date IN DATE );

/*******************************************************************************
|Name       : Get_tax_details                                                  |
|Type       : Function							       |
|Description: Function to get the postal code from the employee primary address|
*******************************************************************************/
Function Get_tax_details(p_max_assgt_act_id number
                        ,p_wage_tax_discount OUT NOCOPY varchar2
                        ,p_tax_code OUT NOCOPY VARCHAR2
                        ,p_labour_relation_code OUT NOCOPY VARCHAR2)
RETURN NUMBER;

/********************************************************************************
|Name       : Get_dev_work_hours                                                |
|Type       : Function							        |
|Description: Function to get the Deviating Working Hours for the longest period|
*********************************************************************************/
PROCEDURE Get_dev_work_hours (p_assignment_id IN NUMBER,
                                 p_dev_work_hours OUT NOCOPY NUMBER,
                                 p_reporting_start_date IN DATE,
                                 p_reporting_end_date IN DATE );

/********************************************************************************
|Name       : Get_Employment_Code                                               |
|Type       : Function							        |
|Description: Function to get the Employment Code                               |
*********************************************************************************/
Function Get_Employment_Code  (p_assignment_id IN NUMBER,
                                 p_employment_code IN OUT NOCOPY NUMBER,
                                 p_reporting_start_date IN DATE,
                                 p_reporting_end_date IN DATE ) RETURN NUMBER;

/********************************************************************************
|Name       : Get_Working_Hours                                                 |
|Type       : Function				  			        |
|Description: Function to get the Working Hours                                 |
*********************************************************************************/
FUNCTION Get_cbs_Working_Hours(p_business_group_id IN NUMBER,
			       p_assignment_id IN NUMBER ,
                               p_reporting_date IN DATE
			       ) RETURN  NUMBER ;

/*******************************************************************************
|Name       : Check_Asg_si_provider                                            |
|Type       : Function							       |
|Description: Function to check whether the given employer is subscribed with  |
|             given si provider.                                               |
*******************************************************************************/
FUNCTION Check_Asg_si_provider(p_organization_id IN NUMBER
			  ,p_si_provider_id  IN NUMBER
			  ,p_assignment_id   IN NUMBER )
			  RETURN NUMBER;

/*******************************************************************************
|Name       : GET_CAO_CODE                                                     |
|Type       : Procedure							       |
|Description: Function to get the collective agreement for the given assignmnent|
*******************************************************************************/
PROCEDURE GET_CAO_CODE (p_assignment_id in number,
              p_cao_code    in out nocopy number,
	      p_rep_date     in DATE);

/********************************************************************************
|Name       : get_grade_salary_number                                           |
|Type       : Function							        |
|Description: Function to get the grade and salary numbers                      |
********************************************************************************/
Function get_grade_salary_number(p_assignment_id     in number,
                                 P_business_group_id in number,
				 p_org_id            in number,
				 P_grade_id          in number,
                                 P_reporting_date    in date,
 				 P_public_sector     in varchar2,
                                 P_grade_number      out nocopy varchar2,
                                 P_salary_number     out nocopy varchar2) return number;


/*******************************************************************************|
|Name           : check_asg_terminate                                      	|
|Type		: FUNCTION							|
|Description    : This FUNCTION checks whether the given assignment terminated  |
|		: on the given date                                             |
*********************************************************************************/

Function check_asg_terminate ( p_assignment_id NUMBER,
                                p_rep_date      DATE)  return NUMBER ;


/********************************************************
*       Cursor to fetch header record information       *
********************************************************/
Cursor Csr_NL_CBS_Header IS
 SELECT
 'ORG_STRUCT_ID=P',pay_magtape_generic.get_parameter_value('ORG_STRUCT_ID'),
 'BUSINESS_GROUP_ID=P',ppa.business_group_id,
 'EMPLOYER_ID=P',pay_magtape_generic.get_parameter_value('EMPLOYER_ID'),
 'SI_PROVIDER_ID=P',pay_magtape_generic.get_parameter_value('SI_PROVIDER_ID'),
 'REPORTING_DATE=P',TO_CHAR(fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('REPORTING_DATE')),'DDMMYYYY'),
 'MEDIUM_CODE=P',pay_magtape_generic.get_parameter_value('MEDIUM_CODE'),
 'DENSITY=P',pay_magtape_generic.get_parameter_value('DENSITY'),
 'ORG_STRUCT_VERSION_ID=P',posv.organization_structure_id,
 'REPORTING_SEQUENCE=P',pai.action_information4,
 'PERIODIC_REP_START_DATE=P' ,TO_CHAR(fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('REPORTING_DATE'))-28,'DDMMYYYY')
  FROM   pay_payroll_actions ppa,
         per_org_structure_versions posv,
         pay_action_information pai
 WHERE   ppa.payroll_action_id
  =pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  and fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('REPORTING_DATE')) between posv.date_from
  and nvl(posv.date_to,hr_general.end_of_time)
  and posv.organization_structure_id = pay_magtape_generic.get_parameter_value('ORG_STRUCT_ID')
  and pai.action_context_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  AND EXISTS
 (select * from pay_assignment_actions paa
  where paa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'));

/********************************************************
*   Cursor to fetch Employee record information    *
********************************************************/
 Cursor Csr_NL_CBS_Body IS
   SELECT
   	'CBS_EMPLOYER_ID=P'		,cbs_pai.action_information1 ,
   	'CBS_SIP_ID=P'		        ,cbs_pai.action_information2 ,
   	'CBS_ASSIGNMENT_ID=P'		,cbs_pai.action_information3 ,
   	'CBS_PERSON_ID=P'		,cbs_pai.action_information4 ,
   	'CBS_EMPLOYEE_NUMBER=P'         ,pap.employee_number,
   	'CBS_SEX=P'                     ,decode(pap.sex,'M','1','F','2'),
   	'CBS_DATE_OF_BIRTH=P'           ,TO_CHAR(pap.date_of_birth,'DDMMYYYY'),
   	'CBS_SOFI_NUMBER=P'		,pap.National_Identifier,
   	'CBS_PAYROLL_TYPE=P'            ,decode(ppf.period_type,'Calendar Month','M','Quarter','K','Week','W','Lunar Month','P'),
   	'CBS_GRADE_NUMBER=P'            ,substr(cbs_pai.action_information5,1,3),
   	'CBS_SALARY_NUMBER=P'           ,substr(cbs_pai.action_information5,4,3),
   	'CBS_WAGE_TAX_DISCOUNT=P'       ,SUBSTR(cbs_pai.action_information6,1,2),
   	'CBS_TAX_TABLE_CODE=P'          ,SUBSTR(cbs_pai.action_information6,3,3),
   	'CBS_INCOME_CODE=P'             ,SUBSTR(cbs_pai.action_information6,6,2),
   	'CBS_LABOUR_RELATION_CODE=P'    ,SUBSTR(cbs_pai.action_information6,8,2),
   	'CBS_HEALTH_INSURANCE=P'        ,SUBSTR(cbs_pai.action_information7,1,1),
   	'CBS_EMPLOYMENT=P'              ,SUBSTR(cbs_pai.action_information8,1,1),
   	'CBS_WORKING_SCHEDULE=P'        ,SUBSTR(cbs_pai.action_information9,1,1),
   	'CBS_DEVIATING_WORKING_HOURS=P' ,SUBSTR(cbs_pai.action_information9,2,1),
   	'CBS_HOLIDAY_HOURS=P'           ,SUBSTR(cbs_pai.action_information9,3,3),
   	'CBS_ADV_HOURS=P'               ,SUBSTR(cbs_pai.action_information9,6,3),
   	'CBS_CAO_CODE=P'                ,cbs_pai.action_information10,
   	'CBS_NOD=P'                     ,cbs_pai.action_information11,
   	'CBS_UNPAID_HOURS=P'            ,cbs_pai.action_information12,
   	'CBS_OVERTIME_HOURS=P'          ,cbs_pai.action_information13,
   	'CBS_WAGE_AGREED_BY_CONTRACT=P' ,cbs_pai.action_information14,
   	'CBS_PAID_GROSS_WAGE=P'         ,cbs_pai.action_information15,
   	'CBS_WAGE_FOR_OVERTIME=P'       ,cbs_pai.action_information16,
   	'CBS_SI_WAGE=P'                 ,cbs_pai.action_information17,
   	'CBS_UNIQUE_PAYMENTS=P'         ,cbs_pai.action_information18,
   	'CBS_PRE_TAX_DEDUCTIONS=P'      ,cbs_pai.action_information19,
   	'CBS_SAVING_SCHEME=P'           ,cbs_pai.action_information20,
   	'CBS_SICKNESS_PAY=P'            ,cbs_pai.action_information21,
   	'CBS_SICKNESS_DAYS=P'           ,cbs_pai.action_information22,
   	'CBS_SI_DAYS_QUARTER=P'         ,cbs_pai.action_information23,
        'CBS_FOREIGN_WORK=P'            ,pap.per_information14
   FROM
   pay_assignment_actions pay_act,
   pay_action_information cbs_pai,
   per_all_people_f pap,
   per_all_assignments_f paa,
   pay_payrolls_f  ppf
   WHERE  pay_act.payroll_action_id
   =pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
   AND pay_act.assignment_action_id = cbs_pai.action_context_id
   AND cbs_pai.action_context_type='AAP'
   AND cbs_pai.action_information_category = 'NL CBS EMPLOYEE DETAILS'
   AND cbs_pai.action_information4 = pap.person_id
   AND cbs_pai.action_information3 = paa.assignment_id
   AND paa.person_id = pap.person_id
   AND ppf.payroll_id = paa.payroll_id
   AND cbs_pai.effective_date between pap.effective_start_date and pap.effective_end_date
   AND cbs_pai.effective_date between ppf.effective_start_date and ppf.effective_end_date
   AND paa.effective_end_date in(select max(asg.effective_end_date)
				 from per_all_assignments_f asg
				 where asg.effective_end_date >= cbs_pai.effective_date
				 and asg.assignment_id=paa.assignment_id)
   ORDER BY ppf.period_type;
END PAY_NL_CBS_FILE;

 

/
