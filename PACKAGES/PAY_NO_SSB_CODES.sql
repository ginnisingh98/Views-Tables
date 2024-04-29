--------------------------------------------------------
--  DDL for Package PAY_NO_SSB_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_SSB_CODES" AUTHID CURRENT_USER AS
 /* $Header: pynossbc.pkh 120.0.12000000.1 2007/05/20 09:29:32 rlingama noship $ */

TYPE ssb_codes_rec IS RECORD
(element_type_id NUMBER(9),
input_value_id NUMBER(9),
run_result_id NUMBER(15),
ssb_code VARCHAR2(150),
add_detail VARCHAR2(150)
);

g_next_ssb_code VARCHAR2(150);
g_current_ssb_code VARCHAR2(150);
g_cache_index NUMBER(10) :=0;

TYPE ssb_codes_table is TABLE OF
ssb_codes_rec
INDEX BY BINARY_INTEGER;

g_ssb_codes_table ssb_codes_table;



/*Function to populate cache table with element_name, element_type_id
and ssb code. Only the elements processed for the assignment will be
picked up in the cache table. Both direct and indirect elements linked
having ssb code as not null will be picked up.
Returns Y if successful and N if not.*/

FUNCTION populate_table
(p_assignment_action_id NUMBER, p_effective_date DATE)	RETURN VARCHAR2;


/* Function returns next cached value for ssb code*/
FUNCTION set_next_cached_code
(p_ssb_code VARCHAR2) RETURN VARCHAR2;

/*Function clears the table record for the ssb code.
Returns Y if successful and N if not.*/
FUNCTION clear_cached_value
(p_ssb_code VARCHAR2) RETURN VARCHAR2;


/*Function returns the total result value for the given
ssb code*/
FUNCTION get_total_result_value
(p_assignment_action_id NUMBER,
p_ssb_code VARCHAR2
) RETURN NUMBER;


/*FUnction to get next cached ssb code*/
FUNCTION get_next_cached_code RETURN VARCHAR2;

FUNCTION get_current_cached_code RETURN VARCHAR2;

FUNCTION clear_cached_table RETURN VARCHAR2;

END pay_no_ssb_codes;

 

/
