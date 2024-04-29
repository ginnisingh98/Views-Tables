--------------------------------------------------------
--  DDL for Package Body HXC_HRR_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HRR_UPLOAD_PKG" AS
/* $Header: hxchrrupl.pkb 115.7 2002/06/10 00:37:26 pkm ship      $ */

PROCEDURE load_hrr_row (
          p_name			VARCHAR2
        , p_legislation_code            VARCHAR2
	, p_eligibility_criteria_type 	VARCHAR2
	, p_pref_hierarchy_name		VARCHAR2
	, p_rule_evaluation_order	NUMBER
	, p_resource_type		VARCHAR2
	, p_start_date			VARCHAR
	, p_end_date			VARCHAR
	, p_owner			VARCHAR2
	, p_custom_mode			VARCHAR2 ) IS

l_resource_rule_id	hxc_resource_rules.resource_rule_id%TYPE;
l_pref_hierarchy_id	hxc_pref_hierarchies.pref_hierarchy_id%TYPE;
l_ovn			hxc_pref_hierarchies.object_version_number%TYPE := NULL;
l_owner			VARCHAR2(6);

FUNCTION get_pref_id ( p_name VARCHAR2 ) RETURN NUMBER IS

l_pref_id	hxc_pref_hierarchies.parent_pref_hierarchy_id%TYPE;

CURSOR	csr_get_pref_id IS
SELECT	pref_hierarchy_id
FROM	hxc_pref_hierarchies
WHERE	name	= p_name
AND	parent_pref_hierarchy_id is null;

BEGIN

OPEN  csr_get_pref_id;
FETCH csr_get_pref_id INTO l_pref_id;
CLOSE csr_get_pref_id;

RETURN l_pref_id;

END get_pref_id;


BEGIN -- load_hrr_row

l_pref_hierarchy_id := get_pref_id ( p_pref_hierarchy_name );

	SELECT	resource_rule_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_resource_rule_id
	,	l_ovn
	,	l_owner
	FROM	hxc_resource_rules
	WHERE	name	= P_NAME;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

		hxc_resource_rules_api.update_resource_rules (
				  p_effective_date		=> sysdate
				, p_name			=> p_name
				, p_business_group_id           => null
				, p_legislation_code            => p_legislation_code
				, p_resource_rule_id		=> l_resource_rule_id
				, p_eligibility_criteria_type   => p_eligibility_criteria_type
				, p_pref_hierarchy_id           => l_pref_hierarchy_id
				, p_rule_evaluation_order       => p_rule_evaluation_order
				, p_resource_type               => p_resource_type
				, p_start_date                  => TO_DATE(p_start_date, 'DD-MM-YYYY')
				, p_end_date                    => TO_DATE(p_end_date, 'DD-MM-YYYY')
	  			, p_object_version_number  	=> l_ovn );

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN
		hxc_resource_rules_api.create_resource_rules (
			  p_effective_date		=> sysdate
			, p_name			=> p_name
			, p_business_group_id           => null
			, p_legislation_code            => p_legislation_code
			, p_resource_rule_id		=> l_resource_rule_id
			, p_eligibility_criteria_type   => p_eligibility_criteria_type
			, p_pref_hierarchy_id           => l_pref_hierarchy_id
			, p_rule_evaluation_order       => p_rule_evaluation_order
			, p_resource_type               => p_resource_type
			, p_start_date                  => TO_DATE(p_start_date, 'DD-MM-YYYY')
			, p_end_date                    => TO_DATE(p_end_date, 'DD-MM-YYYY')
  			, p_object_version_number  	=> l_ovn );
END load_hrr_row;

END hxc_hrr_upload_pkg;

/
