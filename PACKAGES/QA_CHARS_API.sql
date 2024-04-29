--------------------------------------------------------
--  DDL for Package QA_CHARS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CHARS_API" AUTHID CURRENT_USER AS
/* $Header: qltcharb.pls 120.0 2005/05/24 17:50:57 appldev noship $ */


FUNCTION exists_qa_chars(element_id IN NUMBER) RETURN BOOLEAN;


PROCEDURE fetch_qa_chars (element_id IN NUMBER);


-- Bug 3769260. shkalyan 29 July 2004.
-- Added this procedure to fetch all the elements of a plan
-- The reason for introducing this procedure is to reduce the number of
-- hits on the QA_CHARS.
-- Callers will use this procedure to pre-fetch all the Plan elements
-- to the cache if all the elements of a plan would be accessed.

PROCEDURE fetch_plan_chars (plan_id IN NUMBER);


FUNCTION hardcoded_column(element_id IN NUMBER)
    RETURN VARCHAR2;


FUNCTION fk_meaning(element_id IN NUMBER)
    RETURN VARCHAR2;


FUNCTION fk_lookup_type(element_id IN NUMBER)
    RETURN NUMBER;


FUNCTION sql_validation_string(element_id IN NUMBER)
    RETURN VARCHAR2;


FUNCTION datatype(element_id IN NUMBER)
    RETURN NUMBER;


FUNCTION default_value(element_id IN NUMBER)
    RETURN NUMBER;

FUNCTION display_length(element_id IN NUMBER)
    RETURN NUMBER;


FUNCTION decimal_precision (element_id IN NUMBER)
    RETURN NUMBER;


FUNCTION lower_reasonable_limit(element_id IN NUMBER)
    RETURN VARCHAR2;


FUNCTION upper_reasonable_limit(element_id IN NUMBER)
    RETURN VARCHAR2;


FUNCTION prompt(element_id IN NUMBER)
    RETURN VARCHAR2;

-- SSQR project. 07/29/2003
FUNCTION data_entry_hint(element_id IN NUMBER)
    RETURN VARCHAR2;


FUNCTION mandatory_flag(element_id IN NUMBER)
    RETURN NUMBER;


FUNCTION format_sql_for_validation (x_string VARCHAR2, x_org_id IN NUMBER,
     x_created_by IN NUMBER)
     RETURN VARCHAR2;


FUNCTION format_sql_for_lov (x_string IN VARCHAR2, x_org_id IN NUMBER,
    x_created_by IN NUMBER)
    RETURN VARCHAR2;


FUNCTION get_element_id (p_element_name IN VARCHAR2)
    RETURN NUMBER;

--
-- Bug 3926150.  Added this useful utility function for this bug.
-- Can be of general use also.
-- bso Sat Dec  4 15:01:44 PST 2004
--
FUNCTION get_element_name (p_element_id IN NUMBER)
    RETURN VARCHAR2;


FUNCTION has_hardcoded_lov (p_element_id IN NUMBER)
    RETURN BOOLEAN;


 -- anagarwa Tue Jun 22 14:19:42 PDT 2004
 -- bug 3692326 Support element spec in QWB
FUNCTION lower_spec_limit(element_id IN NUMBER)
    RETURN VARCHAR2;


FUNCTION upper_spec_limit(element_id IN NUMBER)
    RETURN VARCHAR2;

FUNCTION target_value(element_id IN NUMBER)
    RETURN VARCHAR2;


-- Bug 3754667. Added the below function to fetch the developer_name of
-- a collection element. kabalakr.

FUNCTION developer_name(element_id IN NUMBER)
    RETURN VARCHAR2;


END qa_chars_api;

 

/
