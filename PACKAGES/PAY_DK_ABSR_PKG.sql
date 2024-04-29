--------------------------------------------------------
--  DDL for Package PAY_DK_ABSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_ABSR_PKG" AUTHID CURRENT_USER AS
 /* $Header: pydkabsr.pkh 120.0.12010000.1 2009/07/29 07:27:48 rsahai noship $ */

FUNCTION GET_LOOKUP_MEANING (p_lookup_type varchar2,p_lookup_code varchar2) RETURN VARCHAR2;

FUNCTION GET_PARAMETER
        (p_parameter_string      IN VARCHAR2
        ,p_token                 IN VARCHAR2
        ,p_segment_number        IN NUMBER default NULL ) RETURN VARCHAR2;

PROCEDURE GET_ALL_PARAMETERS
        (p_payroll_action_id     IN   NUMBER
        ,p_business_group_id     OUT  NOCOPY NUMBER
        ,p_payroll_id            OUT  NOCOPY NUMBER
        ,p_sender_id             OUT  NOCOPY NUMBER
        ,p_year                  OUT  NOCOPY VARCHAR2
        ,p_effective_date        OUT  NOCOPY DATE
        ,p_report_end_date       OUT  NOCOPY DATE
        ,p_archive               OUT  NOCOPY VARCHAR2);

FUNCTION GET_GLOBAL_VALUE
        (p_global_name 		VARCHAR2
	,p_effective_date 	DATE) RETURN ff_globals_f.global_value%TYPE;

/******** PROCEDURES FOR ARCHIVING THE REPORT DATA ********/

PROCEDURE RANGE_CODE
        (pactid                  IN    NUMBER
        ,sqlstr                  OUT   NOCOPY VARCHAR2) ;

PROCEDURE ASSIGNMENT_ACTION_CODE
        (p_payroll_action_id     IN NUMBER
        ,p_start_person          IN NUMBER
        ,p_end_person            IN NUMBER
        ,p_chunk                 IN NUMBER);

PROCEDURE INITIALIZATION_CODE
        (p_payroll_action_id     IN NUMBER);


PROCEDURE ARCHIVE_CODE
        (p_assignment_action_id  IN NUMBER
        ,p_effective_date        IN DATE);

/*PROCEDURE DEINITIALIZATION_CODE
        (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type);*/


/******** PROCEDURES FOR WRITING THE REPORT ********/

TYPE xml_rec_type IS RECORD
(
    TagName VARCHAR2(240),
    TagValue VARCHAR2(240)
);

TYPE xml_tab_type
IS TABLE OF xml_rec_type
INDEX BY BINARY_INTEGER;

xml_tab xml_tab_type;



PROCEDURE POPULATE_DATA
        (p_business_group_id     IN NUMBER,
         p_payroll_action_id     IN VARCHAR2 ,
         p_template_name         IN VARCHAR2,
         p_xml                   OUT NOCOPY CLOB);

PROCEDURE WritetoCLOB
        (p_xfdf_clob             OUT NOCOPY CLOB);

END PAY_DK_ABSR_PKG;

/
