--------------------------------------------------------
--  DDL for Package HXC_RESOURCE_RULES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RESOURCE_RULES_UTILS" AUTHID CURRENT_USER as
/* $Header: hxchrrutl.pkh 115.5 2004/01/12 06:27:04 avramach noship $ */

g_scl_num_of_segs NUMBER(2) := NULL;
g_scl_delimiter   varchar2(1) := NULL;
g_scl_id_flex_num NUMBER(15) := NULL;

g_people_num_of_segs NUMBER(2) := NULL;
g_people_delimiter   varchar2(1) := NULL;
g_people_id_flex_num NUMBER(15) := NULL;

g_grade_num_of_segs NUMBER(2) := NULL;
g_grade_delimiter   varchar2(1) := NULL;
g_grade_id_flex_num NUMBER(15) := NULL;


TYPE r_flex_valid IS RECORD (
     segment1 varchar2(60),
     segment2 varchar2(60),
     segment3 varchar2(60),
     segment4 varchar2(60),
     segment5 varchar2(60),
     segment6 varchar2(60),
     segment7 varchar2(60),
     segment8 varchar2(60),
     segment9 varchar2(60),
     segment10 varchar2(60),
     segment11 varchar2(60),
     segment12 varchar2(60),
     segment13 varchar2(60),
     segment14 varchar2(60),
     segment15 varchar2(60),
     segment16 varchar2(60),
     segment17 varchar2(60),
     segment18 varchar2(60),
     segment19 varchar2(60),
     segment20 varchar2(60),
     segment21 varchar2(60),
     segment22 varchar2(60),
     segment23 varchar2(60),
     segment24 varchar2(60),
     segment25 varchar2(60),
     segment26 varchar2(60),
     segment27 varchar2(60),
     segment28 varchar2(60),
     segment29 varchar2(60),
     segment30 varchar2(60)
    );

TYPE t_flex_valid IS TABLE OF r_flex_valid INDEX BY BINARY_INTEGER;

g_flex_valid_scl_ct t_flex_valid;
g_flex_valid_people_ct t_flex_valid;
g_flex_valid_grade_ct t_flex_valid;

PROCEDURE get_value_set_sql ( 	p_flex_Field_name 	varchar2
			,	p_legislation_code	varchar2 );

FUNCTION get_sequence ( p_type varchar2
		,	p_id_flex_num number default null ) RETURN NUMBER;

FUNCTION get_meaning (  p_type  VARCHAR2
		,	p_value VARCHAR2
		,	p_business_group_id NUMBER default null
		,	p_legislation_code  VARCHAR2 ) RETURN VARCHAR2;

FUNCTION get_criteria_meaning ( p_type varchar2
			,	p_business_group_id number ) RETURN VARCHAR2;

FUNCTION chk_flex_valid ( p_type	VARCHAR2
		,	 p_flex_id	NUMBER
		,	 p_segment	VARCHAR2
		,	 p_value	VARCHAR2 ) RETURN NUMBER;

-- Bug 3322725
FUNCTION chk_criteria_exists ( p_eligibility_criteria_type VARCHAR2,
			       p_eligibility_criteria_id VARCHAR2) RETURN BOOLEAN;

END hxc_resource_rules_utils;

 

/
