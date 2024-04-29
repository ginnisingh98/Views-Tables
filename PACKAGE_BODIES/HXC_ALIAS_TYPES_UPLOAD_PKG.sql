--------------------------------------------------------
--  DDL for Package Body HXC_ALIAS_TYPES_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ALIAS_TYPES_UPLOAD_PKG" AS
/* $Header: hxcaltload.pkb 115.1 2002/09/03 12:10:15 ksethi noship $ */

FUNCTION find_alias_reference_object ( p_alias_type VARCHAR2,p_reference_object VARCHAR2 ) RETURN VARCHAR2 IS

CURSOR	csr_get_alias_reference_object IS
(select     ff.descriptive_flex_context_code
from      fnd_descr_flex_contexts_vl 	 ff
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


FUNCTION find_alias_type_id ( p_alias_type VARCHAR2,p_reference_object VARCHAR2 ) RETURN number IS
CURSOR	csr_get_alias_type_id IS
SELECT	alias_type_id
FROM	hxc_alias_types
WHERE	alias_type	 = p_alias_type
    and reference_object = p_reference_object;
l_alias_type_id hxc_alias_types.alias_type_id%TYPE;
BEGIN
OPEN  csr_get_alias_type_id;
FETCH csr_get_alias_type_id INTO l_alias_type_id;
CLOSE csr_get_alias_type_id;
RETURN l_alias_type_id;
END find_alias_type_id;

FUNCTION find_mapping_component_id (p_mapping_component_name VARCHAR2) RETURN number IS
CURSOR	csr_get_mapping_component_id IS
SELECT	mapping_component_id
FROM	hxc_mapping_components
WHERE	name	 = p_mapping_component_name;
l_mapping_component_id hxc_mapping_components.mapping_component_id%TYPE;
BEGIN
OPEN  csr_get_mapping_component_id;
FETCH csr_get_mapping_component_id INTO l_mapping_component_id;
CLOSE csr_get_mapping_component_id;
RETURN l_mapping_component_id;
END find_mapping_component_id;

PROCEDURE load_alias_type_row (
          p_alias_type              IN VARCHAR2
	, p_reference_object        IN VARCHAR2
	, p_owner		    IN VARCHAR2
	, p_custom_mode	     	    IN VARCHAR2 ) IS
l_alias_type_id		hxc_alias_types.alias_type_id%TYPE;
l_alias_type    		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;
l_ovn				hxc_alias_types.object_version_number%TYPE;
l_owner			VARCHAR2(6);
l_alias_reference_object hxc_alias_types.reference_object%TYPE;
BEGIN
l_alias_reference_object:= find_alias_reference_object(p_alias_type, p_reference_object);
BEGIN
	SELECT	alias_type_id
	,	alias_type
	,	reference_object
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_alias_type_id
	,	l_alias_type
	,	l_reference_object
	,	l_ovn
	,	l_owner
	FROM	hxc_alias_types
	WHERE	alias_type	= P_alias_type
	and     reference_object= l_alias_reference_object;
	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN
		-- only update if the alias type has actually changed
	IF ( ( p_alias_type <> l_alias_type ) OR ( l_alias_reference_object <> l_reference_object)
                   )		then
		hxc_hat_upd.upd (
		       p_alias_type                   => p_alias_type,
		       p_reference_object             => l_alias_reference_object,
		       p_alias_type_id                => l_alias_type_id,
		       p_object_version_number        => l_ovn
    				);
	END IF;
	END IF;
EXCEPTION WHEN NO_DATA_FOUND
THEN
		hxc_hat_ins.ins (
	              p_alias_type                   => p_alias_type,
       		  p_reference_object             => l_alias_reference_object,
		        p_alias_type_id                => l_alias_type_id,
		        p_object_version_number        => l_ovn
		               );
END;
END load_alias_type_row;

PROCEDURE load_alias_comp_row (
        p_component_name          IN VARCHAR2
	, p_component_type 	    IN VARCHAR2
	, p_mapping_component_name  IN VARCHAR2
	, p_alias_type              IN VARCHAR2
	, p_reference_object        IN VARCHAR2
	, p_owner			    IN VARCHAR2
	, p_custom_mode	     	    IN VARCHAR2 ) IS
l_alias_type_id			hxc_alias_types.alias_type_id%TYPE;
l_mapping_component_id  	hxc_mapping_components.mapping_component_id%TYPE;
l_alias_type_component_id	hxc_alias_type_components.alias_type_component_id%TYPE;
l_component_name		hxc_alias_type_components.component_name%TYPE;
l_component_type		hxc_alias_type_components.component_type%TYPE;
l_ovn				hxc_alias_type_components.object_version_number%TYPE;
l_owner				VARCHAR2(6);
l_alias_reference_object hxc_alias_types.reference_object%TYPE;

BEGIN
l_alias_reference_object:= find_alias_reference_object(p_alias_type, p_reference_object);
l_alias_type_id 	:= find_alias_type_id (p_alias_type, l_alias_reference_object);
l_mapping_component_id  := find_mapping_component_id (p_mapping_component_name);
BEGIN
	SELECT	alias_type_component_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	,	component_name
	,	component_type
	INTO	l_alias_type_component_id
	,	l_ovn
	,	l_owner
	,	l_component_name
	,	l_component_type
	FROM	hxc_alias_type_components hatc
	WHERE	hatc.mapping_component_id = l_mapping_component_id
	 AND	hatc.ALIAS_TYPE_ID  	  = l_alias_type_id;
	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN
		-- only update if the alias component mapping that has actually changed
--		IF ( ( p_component_name <> l_component_name ) OR ( p_component_type <> l_component_type)
--                   )
--		THEN
		hxc_atc_upd.upd (
	        p_component_name                 => p_component_name
	       ,p_component_type                 => p_component_type
	       ,p_mapping_component_id           => l_mapping_component_id
	       ,p_alias_type_id                  => l_alias_type_id
	       ,p_alias_type_component_id        => l_alias_type_component_id
	       ,p_object_version_number          => l_ovn
	       );
--		END IF;
	END IF;
EXCEPTION WHEN NO_DATA_FOUND
THEN
		hxc_atc_ins.ins (
	        p_component_name                 => p_component_name
	       ,p_component_type                 => p_component_type
	       ,p_mapping_component_id           => l_mapping_component_id
	       ,p_alias_type_id                  => l_alias_type_id
	       ,p_alias_type_component_id        => l_alias_type_component_id
	       ,p_object_version_number          => l_ovn
	);
END;
END load_alias_comp_row;
END hxc_alias_types_upload_pkg;

/
