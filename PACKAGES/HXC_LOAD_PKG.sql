--------------------------------------------------------
--  DDL for Package HXC_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcload.pkh 120.0 2005/05/29 04:36:49 appldev noship $ */

g_package  varchar2(33)	:= ' hxc_load_pkg.';  -- Global package name

FUNCTION get_pref_def_name ( p_pref_definition_id NUMBER ) RETURN VARCHAR2;
FUNCTION chk_tc_ref_integrity ( p_time_category_id NUMBER ) RETURN BOOLEAN ;

FUNCTION get_attribute ( p_attribute_category	VARCHAR2
		,	 p_attribute		VARCHAR2
		,	  p_attribute_name   IN VARCHAR2 DEFAULT null
		) RETURN VARCHAR2 ;

FUNCTION get_parent ( p_pref_top_node	VARCHAR2
		,   p_pref_node		VARCHAR2
		,   p_pref_level	NUMBER
		,   p_count		NUMBER ) RETURN VARCHAR2 ;

FUNCTION get_value_set_sql
              (p_flex_value_set_id IN NUMBER,
               p_session_date   IN     DATE ) RETURN LONG;

FUNCTION get_flex_value (  p_flex_value_set_id NUMBER
	,		p_id  VARCHAR2 ) RETURN VARCHAR2;
PROCEDURE upgrade_custom_tcs ( p_time_category_id NUMBER ) ;

CURSOR csr_chk_ref_integ ( p_time_category_id NUMBER ) IS
SELECT	DISTINCT ter.time_entry_rule_id
               , dfcu.application_column_name
FROM	fnd_descr_flex_column_usages dfcu
,	hxc_time_entry_rules ter
WHERE	ter.formula_id IS NOT NULL
AND
        dfcu.application_id = 809 AND
        dfcu.descriptive_flex_context_code = ter.attribute_category AND
        UPPER(dfcu.end_user_column_name) like 'TIME_CATEGORY%'
AND
	DECODE ( dfcu.application_column_name,
        'ATTRIBUTE1', ter.attribute1,
        'ATTRIBUTE2', ter.attribute2,
        'ATTRIBUTE3', ter.attribute3,
        'ATTRIBUTE4', ter.attribute4,
        'ATTRIBUTE5', ter.attribute5,
        'ATTRIBUTE6', ter.attribute6,
        'ATTRIBUTE7', ter.attribute7,
        'ATTRIBUTE8', ter.attribute8,
        'ATTRIBUTE9', ter.attribute9,
        'ATTRIBUTE10', ter.attribute10,
        'ATTRIBUTE11', ter.attribute11,
        'ATTRIBUTE12', ter.attribute12,
        'ATTRIBUTE13', ter.attribute13,
        'ATTRIBUTE14', ter.attribute14,
        'ATTRIBUTE15', ter.attribute15,
        'ATTRIBUTE16', ter.attribute16,
        'ATTRIBUTE17', ter.attribute17,
        'ATTRIBUTE18', ter.attribute18,
        'ATTRIBUTE19', ter.attribute19,
        'ATTRIBUTE20', ter.attribute20,
        'ATTRIBUTE21', ter.attribute21,
        'ATTRIBUTE22', ter.attribute22,
        'ATTRIBUTE23', ter.attribute23,
        'ATTRIBUTE24', ter.attribute24,
        'ATTRIBUTE25', ter.attribute25,
        'ATTRIBUTE26', ter.attribute26,
        'ATTRIBUTE27', ter.attribute27,
        'ATTRIBUTE28', ter.attribute28,
        'ATTRIBUTE29', ter.attribute29,
        'ATTRIBUTE30', ter.attribute30, 'zZz' ) = TO_CHAR(p_time_category_id);



TYPE r_ter_record IS RECORD ( ter_id hxc_time_entry_rules.time_entry_rule_id%TYPE
                             ,attribute varchar2(20) );

TYPE t_ter_table IS TABLE OF r_ter_record INDEX BY BINARY_INTEGER;
FUNCTION get_tc_ref_integrity_list ( p_time_category_id NUMBER ) RETURN t_ter_table;

Procedure get_node_data
  (
   p_preference_full_name     in varchar2
  ,p_name                     in varchar2
  ,p_business_group_id	      in number
  ,p_legislation_code         in varchar2
  ,p_mode                     out nocopy varchar2
  ,p_pref_hierarchy_id        out nocopy number
  ,p_parent_pref_hierarchy_id out nocopy number
  ,p_object_version_number    out nocopy number
   ) ;


FUNCTION get_ter_attributes(p_formula_id       IN NUMBER,
			    p_attribute_name   IN VARCHAR2,
			    p_attrubute_val    IN VARCHAR2
			   )
RETURN VARCHAR2;

FUNCTION get_id_set_sql
              (p_flex_value_set_id    IN NUMBER,
               p_session_date         IN DATE ) RETURN LONG;

FUNCTION get_ter_attribute_id(p_formula_name   IN VARCHAR2,
			    p_attribute_name   IN VARCHAR2,
			    p_attrubute_val    IN VARCHAR2
			   )
RETURN VARCHAR2;

PROCEDURE set_dynamic_sql_string ( p_time_category_id NUMBER );

END hxc_load_pkg;




 

/
