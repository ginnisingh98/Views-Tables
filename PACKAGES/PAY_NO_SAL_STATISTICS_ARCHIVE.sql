--------------------------------------------------------
--  DDL for Package PAY_NO_SAL_STATISTICS_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_SAL_STATISTICS_ARCHIVE" AUTHID CURRENT_USER AS
 /* $Header: pynossta.pkh 120.0.12000000.1 2007/05/20 09:29:52 rlingama noship $ */
 --
 -- -----------------------------------------------------------------------------
 -- Parse out parameters from string.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_parameter
 (p_parameter_string IN VARCHAR2
 ,p_token            IN VARCHAR) RETURN VARCHAR2;
 --
 -- -----------------------------------------------------------------------------
 --
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE range_code
 (p_payroll_action_id IN NUMBER
 ,p_sql               OUT NOCOPY VARCHAR2);
 --
 -- -----------------------------------------------------------------------------
 --
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE assignment_action_code
 (p_payroll_action_id IN NUMBER
 ,p_start_person      IN NUMBER
 ,p_end_person        IN NUMBER
 ,p_chunk             IN NUMBER);
 --
 -- -----------------------------------------------------------------------------
 --
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE initialization_code
 (p_payroll_action_id IN NUMBER);
 --
 -- -----------------------------------------------------------------------------
 --
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE archive_code
 (p_assignment_action_id IN NUMBER
 ,p_effective_date       IN DATE);
 --
 -- -----------------------------------------------------------------------------
 --
 -- -----------------------------------------------------------------------------
 --

TYPE xml_rec_type IS RECORD
(
    TagName VARCHAR2(240),
    TagValue VARCHAR2(240)
);

TYPE xml_tab_type
IS TABLE OF xml_rec_type
INDEX BY BINARY_INTEGER;

xml_tab xml_tab_type;

PROCEDURE POPULATE_DATA_DETAIL
        (p_business_group_id     IN NUMBER,
         p_payroll_action_id     IN VARCHAR2,
         p_template_name         IN VARCHAR2,
         p_xml                   OUT NOCOPY CLOB);

END pay_no_sal_statistics_archive;

 

/
