--------------------------------------------------------
--  DDL for Package PAY_NO_UNION_DUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_UNION_DUES" AUTHID CURRENT_USER AS
 /* $Header: pynouniondues.pkh 120.0.12000000.1 2007/05/20 07:54:52 rlingama noship $ */

TYPE xml_rec_type IS RECORD( xmlstring VARCHAR2(32000) );

-- Table Type for XML Table
TYPE xml_tab_type IS TABLE OF xml_rec_type INDEX BY BINARY_INTEGER;

-- Global declaration of Pl/Sql Table for storing Xml Data
xml_tab 	xml_tab_type;


/* GET PARAMETER */
FUNCTION GET_PARAMETER(
	 p_parameter_string IN VARCHAR2
	,p_token            IN VARCHAR2
	,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2 ;


/* GET ALL PARAMETERS */
PROCEDURE GET_ALL_PARAMETERS(
 		 p_payroll_action_id	IN           NUMBER
		,p_business_group_id    OUT  NOCOPY  NUMBER
		,p_legal_employer_id	OUT  NOCOPY  NUMBER
		,p_effective_date	OUT  NOCOPY  DATE
		,p_archive		OUT  NOCOPY  VARCHAR2
		,p_payee_org		OUT NOCOPY NUMBER
		,p_fromdate		OUT NOCOPY DATE
		,p_todate		OUT NOCOPY DATE
		) ;


/* RANGE CODE */
PROCEDURE RANGE_CODE (pactid    IN    NUMBER
		      ,sqlstr    OUT   NOCOPY VARCHAR2) ;


/* INITIALIZATION CODE */
PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER) ;


/* ASSIGNMENT ACTION CODE */
PROCEDURE ASSIGNMENT_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER) ;


 /* ARCHIVE CODE */
PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
 		      ,p_effective_date    IN DATE) ;



-- Main Procedure to populate details for reporting

procedure populate_details
(
	p_payroll_action_id in varchar2,
	p_template_name in varchar2,
	p_xml out nocopy clob
);

-- Procedure to write to clob object

PROCEDURE write_to_clob (p_xml out nocopy clob);

-- End of Package Header


 END PAY_NO_UNION_DUES;

/
