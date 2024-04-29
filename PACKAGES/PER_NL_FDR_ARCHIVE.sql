--------------------------------------------------------
--  DDL for Package PER_NL_FDR_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NL_FDR_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: penlfdra.pkh 120.0.12000000.1 2007/04/10 11:59:15 rajesrin noship $ */

	/*Record for storing XML tag and its value*/

	TYPE XMLRec IS RECORD	(TagName VARCHAR2(1000),
				TagValue VARCHAR2(1000));

	TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;

	vXMLTable tXMLTable;


	/*------------------------------------------------------------------------------
	|Name           : GET_PARAMETER    					        |
	|Type           : Function						        |
	|Description    : Funtion to get the parameters of the archive process          |
	-------------------------------------------------------------------------------*/


	FUNCTION get_parameter	(p_parameter_string in varchar2
	        		,p_token            in varchar2
	        		,p_segment_number   in number default null )    RETURN varchar2;



	/*-----------------------------------------------------------------------------
	|Name       : GET_ALL_PARAMETERS                                               |
	|Type       : Procedure							       |
	|Description: Procedure which returns all the parameters of the archive	process|
	-------------------------------------------------------------------------------*/


	PROCEDURE get_all_parameters	(p_payroll_action_id	IN NUMBER
					,p_report_date		OUT NOCOPY VARCHAR2
					,p_org_struct_id	OUT NOCOPY NUMBER
					,p_person_id		OUT NOCOPY NUMBER
					,p_org_id		OUT NOCOPY NUMBER
					,p_bg_id		OUT NOCOPY NUMBER);



	/*-----------------------------------------------------------------------------
	|Name       : WRITETOCLOB_RTF                                                  |
	|Type       : Procedure							       |
	|Description: Procedure to write contents of XML file as CLOB                  |
	-------------------------------------------------------------------------------*/


	PROCEDURE WritetoCLOB_rtf(p_xfdf_clob out nocopy clob, p_XMLTable IN tXMLTable);



	/*------------------------------------------------------------------------------
	|Name           : CHECK_TAX_DETAILS    					        |
	|Type           : Function                                                      |
	|Description    : Returns 1 if the organization has tax details attached        |
	-------------------------------------------------------------------------------*/


	FUNCTION check_tax_details	(p_org_id IN NUMBER) RETURN NUMBER;


	/*------------------------------------------------------------------------------
	|Name           : GET_REF_DATE                                                  |
	|Type           : Function                                                      |
	|Description    : Function to return the date at which the assignment record    |
	|                 needs to be picked for an employee.                           |
	-------------------------------------------------------------------------------*/


	FUNCTION get_ref_date	(p_person_id IN NUMBER)	return DATE;


	/*------------------------------------------------------------------------------
	|Name           : ORG_CHECK                                                     |
	|Type           : Function                                                      |
	|Description    : Function required for valueset HR_NL_EMPLOYER_FDR             |
	-------------------------------------------------------------------------------*/


	FUNCTION org_check	(p_bg_id IN NUMBER
				,p_org_struct_id IN NUMBER
				,p_org_id IN NUMBER
				,p_report_date IN DATE) return NUMBER;



	/*------------------------------------------------------------------------------
	|Name           : EMP_CHECK                                                     |
	|Type           : Function                                                      |
	|Description    : Function required for valueset HR_NL_EMPLOYEE_FDR             |
	-------------------------------------------------------------------------------*/


	FUNCTION emp_check	(p_bg_id IN NUMBER
				,p_org_struct_id IN NUMBER
				,p_org_id IN NUMBER
				,p_person_id IN NUMBER
				,p_report_date IN DATE) return NUMBER;



	/*--------------------------------------------------------------------
	|Name       : RANGE_CODE                                              |
	|Type	    : Procedure                                               |
	|Description: This procedure returns an sql string to select a range  |
	|             of assignments eligible for reporting                   |
	----------------------------------------------------------------------*/


	PROCEDURE RANGE_CODE (pactid    IN    NUMBER
	                     ,sqlstr    OUT   NOCOPY VARCHAR2);



	/*--------------------------------------------------------------------
	|Name       : ASSIGNMENT_ACTION_CODE                                  |
	|Type	    : Procedure                                               |
	|Description: This procedure further filters which assignments are    |
	|             eligible for reporting                                  |
	----------------------------------------------------------------------*/


	PROCEDURE ASSIGNMENT_ACTION_CODE (p_payroll_action_id  in number
					  ,p_start_person_id   in number
					  ,p_end_person_id     in number
					  ,p_chunk             in number);



	/*-------------------------------------------------------------------------------
	|Name           : ARCHIVE_CODE                                                  |
	|Type		: Procedure                                                     |
	|Description    : Archival code                                                 |
	-------------------------------------------------------------------------------*/


	PROCEDURE ARCHIVE_CODE (p_assignment_action_id  IN NUMBER
				,p_effective_date       IN DATE);



	/*-------------------------------------------------------------------------------
	|Name           : ARCHIVE_DEINIT_CODE                                           |
	|Type		: Procedure                                                     |
	|Description    : Deinitialization code                                         |
	-------------------------------------------------------------------------------*/


	PROCEDURE archive_deinit_code(p_actid IN  NUMBER);


END PER_NL_FDR_ARCHIVE;


 

/
