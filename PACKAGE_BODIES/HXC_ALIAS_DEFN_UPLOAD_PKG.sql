--------------------------------------------------------
--  DDL for Package Body HXC_ALIAS_DEFN_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ALIAS_DEFN_UPLOAD_PKG" AS
/* $Header: hxcloddef.pkb 115.1 2002/09/03 12:09:27 ksethi noship $ */

FUNCTION find_alias_reference_object ( p_alias_type VARCHAR2,p_reference_object VARCHAR2 ) RETURN VARCHAR2 IS

CURSOR	csr_get_alias_reference_object IS
(select     ff.descriptive_flex_context_code
from       fnd_descr_flex_contexts_vl 	 ff
where     ff.DESCRIPTIVE_FLEX_CONTEXT_NAME = p_reference_object
          and  p_alias_type = 'OTL_ALT_DDF'
union
select    to_char(ff.FLEX_VALUE_SET_ID)
from      fnd_flex_value_sets 			 ff
where     ff.FLEX_VALUE_SET_NAME = p_reference_object
	      and  p_alias_type in ('VALUE_SET_NONE','VALUE_SET_TABLE')
);
l_alias_reference_object hxc_alias_types.reference_object%TYPE;
BEGIN
OPEN  csr_get_alias_reference_object;
FETCH csr_get_alias_reference_object INTO l_alias_reference_object;
CLOSE csr_get_alias_reference_object;
RETURN l_alias_reference_object;
END find_alias_reference_object;


FUNCTION find_alias_type_id ( p_alias_type VARCHAR2,p_alias_reference_object VARCHAR2 ) RETURN number IS
CURSOR	csr_get_alias_type_id IS
SELECT	alias_type_id
FROM	hxc_alias_types
WHERE	alias_type	 = p_alias_type
    and reference_object = p_alias_reference_object;
l_alias_type_id hxc_alias_types.alias_type_id%TYPE;
BEGIN
OPEN  csr_get_alias_type_id;
FETCH csr_get_alias_type_id INTO l_alias_type_id;
CLOSE csr_get_alias_type_id;
RETURN l_alias_type_id;
END find_alias_type_id;


PROCEDURE load_alias_definition_row (
          p_alias_definition_name    IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_legislation_code         IN VARCHAR2
	, p_alias_context_code       IN VARCHAR2
	, p_description              IN VARCHAR2
	, p_timecard_field           IN VARCHAR2
	, p_prompt		     IN VARCHAR2
	, p_alias_type               IN VARCHAR2
	, p_reference_object	     IN VARCHAR2
	, p_custom_mode	     	     IN VARCHAR2 ) IS

l_alias_type_id			hxc_alias_types.alias_type_id%TYPE;
l_alias_reference_object  	hxc_alias_types.reference_object%TYPE;
l_alias_definition_id  		hxc_alias_definitions.alias_definition_id%TYPE;
l_business_group_id  		hxc_alias_definitions.business_group_id%TYPE;
l_legislation_code  		hxc_alias_definitions.legislation_code%TYPE;
l_alias_context_code  		hxc_alias_definitions.alias_context_code%TYPE;
l_description  			hxc_alias_definitions.description%TYPE;
l_alias_definition_name  	hxc_alias_definitions.alias_definition_name%TYPE;
l_timecard_field  		hxc_alias_definitions.timecard_field%TYPE;
l_ovn				hxc_alias_definitions.object_version_number%TYPE;
l_owner				VARCHAR2(6);

BEGIN
l_alias_reference_object:= find_alias_reference_object(p_alias_type, p_reference_object);
l_alias_type_id 	:= find_alias_type_id(p_alias_type, l_alias_reference_object);


BEGIN
	SELECT    alias_definition_id
			, DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
			, business_group_id
			, legislation_code
			, alias_context_code
			, description
			, alias_definition_name
			, timecard_field
			, object_version_number

	INTO	 l_alias_definition_id
			,l_owner
			,l_business_group_id
			,l_legislation_code
			,l_alias_context_code
			,l_description
			,l_alias_definition_name
			,l_timecard_field
			,l_ovn

	FROM 	 hxc_alias_definitions had
	WHERE   had.alias_definition_name = p_alias_definition_name
	        and had.ALIAS_TYPE_ID  	  = l_alias_type_id;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN
		-- only update if the alias component mapping that has actually changed


		hxc_had_upd.upd
		  (p_alias_definition_id            => l_alias_definition_id
		  ,p_object_version_number          => l_ovn
		  ,p_alias_definition_name          => p_alias_definition_name
		  ,p_alias_context_code             => p_alias_context_code
		  ,p_business_group_id              => null
		  ,p_legislation_code               => p_legislation_code
		  ,p_timecard_field                 => p_timecard_field
		  ,p_description                    => p_description
		  ,p_prompt                         => p_prompt
		  ,p_alias_type_id		    => l_alias_type_id
  );

	END IF;
EXCEPTION WHEN NO_DATA_FOUND
THEN
		hxc_had_ins.ins
		  (p_alias_definition_name          => p_alias_definition_name
		  ,p_alias_context_code             => p_alias_context_code
		  ,p_business_group_id              => null
		  ,p_legislation_code               => p_legislation_code
		  ,p_timecard_field                 => p_timecard_field
		  ,p_description                    => p_description
		  ,p_prompt                         => p_prompt
		  ,p_alias_definition_id            => l_alias_definition_id
		  ,p_object_version_number          => l_ovn
		  ,p_alias_type_id                  => l_alias_type_id
  );
END;
END load_alias_definition_row;
END hxc_alias_defn_upload_pkg;

/
