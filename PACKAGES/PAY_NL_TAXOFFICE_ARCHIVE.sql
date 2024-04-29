--------------------------------------------------------
--  DDL for Package PAY_NL_TAXOFFICE_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_TAXOFFICE_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pynltosa.pkh 120.0.12000000.2 2007/04/19 09:58:01 abhgangu noship $ */
level_cnt NUMBER;

TYPE UserBalRec IS RECORD(
BalName VARCHAR2(1000),
TagName VARCHAR2(1000));

TYPE tUserBalTable IS TABLE OF UserBalRec INDEX BY BINARY_INTEGER;
vUserBalTable tUserBalTable;

/*------------------------------------------------------------------------------
|Name           : GET_PARAMETER    					        |
|Type		    : Function							|
|Description    : Funtion to get the parameters of the archive process     	|
-------------------------------------------------------------------------------*/

Function get_parameter(
		 p_parameter_string in varchar2
		,p_token            in varchar2
		,p_segment_number   in number default null )RETURN varchar2;

/*-------------------------------------------------------------------------------
|Name           : RANGE_CODE                                       		        |
|Type		: Procedure							                                |
|Description    : This procedure returns a sql string to select a range of 	    |
|		  assignments eligible for archival		  		                        |
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
         ,p_effective_date        OUT NOCOPY DATE
         ,p_tax_year              OUT NOCOPY DATE
         ,p_employer              OUT NOCOPY number  )  ;
--         ,p_org_struct_id         OUT NOCOPY number  )  ;

/*-----------------------------------------------------------------------------
|Name       : get_max_assgt_act_id                                             |
|Type       : Function							       |
|Description: Function which returns the max. assignment_action_id for a given |
|	      assignment_id between a given start and end date		       |
-------------------------------------------------------------------------------*/


function get_max_assgt_act_id(p_assignment_id number
                              ,p_date_from date
                              ,p_date_to date)RETURN number;


/*-----------------------------------------------------------------------------
|Name       : get_context_id                                                   |
|Type       : Function							       |
|Description: Function which returns the context id for a given context neme   |
-------------------------------------------------------------------------------*/



function get_context_id(p_context_name VARCHAR2)return number;



/*-----------------------------------------------------------------------------
|Name       : get_wage		                                               |
|Type       : Function							       |
|Description: Function which returns the wage for a given assignment action    |
-------------------------------------------------------------------------------*/

function get_wage(p_assgt_act_id number)RETURN number;



/*-----------------------------------------------------------------------------
|Name       : get_taxable_income                                               |
|Type       : Function							       |
|Description: Function which returns the taxable income for a given assignment |
|             action                                                           |
-------------------------------------------------------------------------------*/

function get_taxable_income(p_assgt_act_id number)RETURN number;



/*-----------------------------------------------------------------------------
|Name       : get_deduct_wage_tax_si_cont                                      |
|Type       : Function							       |
|Description: Function which returns the deduct_wage_tax value                 |
|	      for a given assignment action    				       |
-------------------------------------------------------------------------------*/

function get_deduct_wage_tax_si_cont(p_assgt_act_id number) return number;


/*-----------------------------------------------------------------------------
|Name       : get_labour_discount                                              |
|Type       : Function							       |
|Description: Function which returns the labour discount value                 |
|	      for a given assignment action    				       |
-------------------------------------------------------------------------------*/

function get_labour_discount(p_assgt_act_id number) return number;



/*-----------------------------------------------------------------------------
|Name       : get_special_indicators                                           |
|Type       : Procedure							       |
|Description: Procedure which returns the special indicators string            |
-------------------------------------------------------------------------------*/


Procedure get_special_indicators(p_assgt_act_id in number
				,p_assignment_id in number
				,p_tax_year_start_date in date
				,p_tax_year_end_date in date
                                ,p_special_indicator out nocopy varchar2
                                ,p_Amount_Special_indicator out nocopy varchar2);

/*-----------------------------------------------------------------------------
|Name       : get_ZFW_PHI_contributions				               |
|Type       : Function							       |
|Description: Function which returns the ZFW PHI contributions	 	       |
-------------------------------------------------------------------------------*/

function get_ZFW_PHI_contributions(p_assgt_act_id number) return number;


/*-----------------------------------------------------------------------------
|Name       : get_PRIVATE_USE_CAR				               |
|Type       : Function							       |
|Description: Function which returns the private use car balance value 	       |
-------------------------------------------------------------------------------*/

function get_PRIVATE_USE_CAR(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : get_NET_EXPENSE_ALLOWANCE				               |
|Type       : Function							       |
|Description: Function which returns the NET EXPENSE ALLOWANCE balance value   |
-------------------------------------------------------------------------------*/

function get_NET_EXPENSE_ALLOWANCE(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : get_wage_tax_discount				               |
|Type       : Function							       |
|Description: Function which returns the wage tax discount value               |
-------------------------------------------------------------------------------*/


function get_wage_tax_discount(p_assignment_id number
                              ,p_tax_year_start_date date
                              ,p_tax_year_end_date date) return varchar2;

/*-----------------------------------------------------------------------------
|Name       : get_wage_tax_table_code				               |
|Type       : Function							       |
|Description: Function which returns the wage tax table code 		       |
-------------------------------------------------------------------------------*/


function get_wage_tax_table_code(p_assignment_id number
				,p_tax_year_start_date date
				,p_tax_year_end_date date) return varchar2;

/*-----------------------------------------------------------------------------
|Name       : get_si_insured_flag				               |
|Type       : Function							       |
|Description: Function which returns the si insured flag string		       |
-------------------------------------------------------------------------------*/

function get_si_insured_flag(p_assignment_id number
			    ,p_tax_year_start_date date
			    ,p_tax_year_end_date date) return varchar2;

/*-----------------------------------------------------------------------------
|Name       : get_income_code					               |
|Type       : Function							       |
|Description: Function which returns the income code 			       |
-------------------------------------------------------------------------------*/

function get_income_code(p_assignment_id number
			,p_tax_year_start_date date
			,p_tax_year_end_date date)return varchar2;


/*-----------------------------------------------------------------------------
|Name       : get_org_hierarchy					               |
|Type       : Function							       |
|Description: Function which returns organization structure version id         |
-------------------------------------------------------------------------------*/

function get_org_hierarchy(p_org_struct_id varchar2
			  ,p_tax_year_end_date date) return number;

/*-----------------------------------------------------------------------------
|Name       : get_IZA_contributions			                       |
|Type       : Function							       |
|Description: Function which returns sum of IZA balances                       |
-------------------------------------------------------------------------------*/

function get_IZA_contributions(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : get_ZVW_basis					               |
|Type       : Function							       |
|Description: Function which returns the ZVW basis		 	       |
-------------------------------------------------------------------------------*/
function get_ZVW_basis(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : get_ZVW_contributions				               |
|Type       : Function							       |
|Description: Function which returns the ZVW contributions	 	       |
-------------------------------------------------------------------------------*/

function get_ZVW_contributions(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : get_VALUE_PRIVATE_USE_CAR					       |
|Type       : Function							       |
|Description: Function which returns the value private use car balance value   |
-------------------------------------------------------------------------------*/

function get_VALUE_PRIVATE_USE_CAR(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : get_LSS_Saved_Amount				               |
|Type       : Function							       |
|Description: Function which returns the saved amount for life saving scheme   |
-------------------------------------------------------------------------------*/

function get_LSS_Saved_Amount(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : get_Employer_Part_Child_Care			               |
|Type       : Function							       |
|Description: Function which returns the Employer part Child Care balance value|
-------------------------------------------------------------------------------*/

function get_Employer_Part_Child_Care(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : get_Allowance_On_Disability			               |
|Type       : Function							       |
|Description: Function which returns the paid allowance on Disability Allowance|
-------------------------------------------------------------------------------*/

function get_Allowance_On_Disability(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : get_Applied_LCLD					               |
|Type       : Function							       |
|Description: Function which returns the Applied Life Cycle Leave Discount     |
-------------------------------------------------------------------------------*/

function get_Applied_LCLD(p_assgt_act_id number) return number;

/*-----------------------------------------------------------------------------
|Name       : populate_UserBal					               |
|Type       : Procedure							       |
|Description: Procedure which populates pl/sql table with user defined balance |
|             names and tag names                                              |
-------------------------------------------------------------------------------*/

PROCEDURE populate_UserBal(p_bg_id number, p_effective_date DATE);

/*-----------------------------------------------------------------------------
|Name       : get_User_Balances                                                |
|Type       : Procedure							       |
|Description: Procedure which returns the User Defined Balances                |
-------------------------------------------------------------------------------*/

PROCEDURE get_User_Balances	(p_assgt_act_id in number
				,p_bg_id in number
                                ,p_User_Bal_String out nocopy varchar2);

/*-----------------------------------------------------------------------------
|Name       : get_User_Defined_Balance_Id                                      |
|Type       : Procedure							       |
|Description: Procedure which returns the User Defined Balance Id              |
-------------------------------------------------------------------------------*/

FUNCTION get_User_Defined_Balance_Id	(p_user_name IN VARCHAR2, p_bg_id IN NUMBER) RETURN NUMBER;


END PAY_NL_TAXOFFICE_ARCHIVE;

 

/
