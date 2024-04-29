--------------------------------------------------------
--  DDL for Package PAY_NL_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_PAYSLIP_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pynlparc.pkh 120.0.12000000.1 2007/01/17 22:59:29 appldev noship $ */

/*-------------------------------------------------------------------------------
|Name           : RANGE_CODE                                       		|
|Type		: Procedure							|
|Description    : This procedure returns a sql string to select a range of 	|
|		  assignments eligible for archival		  		|
-------------------------------------------------------------------------------*/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2);


/*-------------------------------------------------------------------------------
|Name           : ASSIGNMENT_ACTION_CODE                                      	|
|Type		: Procedure							|
|Description    : This procedure further restricts the assignment id's returned |
|		  by the range code. It locks all the completed Prepayments/	|
|		  Quickpay Prepayments in the specified period			|
-------------------------------------------------------------------------------*/

Procedure ASSIGNMENT_ACTION_CODE (p_payroll_action_id  in number
				  ,p_start_person_id   in number
				  ,p_end_person_id     in number
				  ,p_chunk             in number);


/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_INIT                                            	|
|Type		: Procedure							|
|Description    : Procedure sets the global tables g_statutory_balance_table,   |
|		  g_stat_element_table,g_user_balance_table,g_element_table.	|
-------------------------------------------------------------------------------*/

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER);

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_CODE                                            	|
|Type		: Procedure							|
|Description    : This is the main procedure which calls the several procedures |
|		  to archive the data.						|
-------------------------------------------------------------------------------*/

Procedure ARCHIVE_CODE (p_assignment_action_id                 IN NUMBER
	     	       ,p_effective_date                       IN DATE);



/*-------------------------------------------------------------------------------
|Name           : GET_PARAMETER    						|
|Type		: Function							|
|Description    : Funtion to get the parameters of the archive process     	|
-------------------------------------------------------------------------------*/

Function get_parameter(
		 p_parameter_string in varchar2
		,p_token            in varchar2
		,p_segment_number   in number default null )RETURN varchar2;

/*-------------------------------------------------------------------------------
|Name           : GET_ALL_PARAMETERS                                           	|
|Type		: Procedure							|
|Description    : Procedure which returns all the parameters of the archive	|
|		  process						   	|
-------------------------------------------------------------------------------*/
PROCEDURE get_all_parameters(
       p_payroll_action_id                    IN   	  NUMBER
      ,p_business_group_id                    OUT  NOCOPY NUMBER
      ,p_start_date                           OUT  NOCOPY VARCHAR2
      ,p_end_date                             OUT  NOCOPY VARCHAR2
      ,p_effective_date                       OUT  NOCOPY DATE
      ,p_payroll_id                           OUT  NOCOPY VARCHAR2
      ,p_consolidation_set                    OUT  NOCOPY VARCHAR2);
/*-------------------------------------------------------------------------------
|Name           : get_country_name                                           	|
|Type		: Function							|
|Description    : Function to get the country name from FND_TERRITORIES_VL	|
-------------------------------------------------------------------------------*/

FUNCTION get_country_name(p_territory_code VARCHAR2) RETURN VARCHAR2;

END PAY_NL_PAYSLIP_ARCHIVE;

 

/
