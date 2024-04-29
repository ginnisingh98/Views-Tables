--------------------------------------------------------
--  DDL for Package Body HXC_MCU_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_MCU_UPLOAD_PKG" AS
/* $Header: hxcmcuupl.pkb 115.6 2002/06/10 13:30:19 pkm ship      $ */

FUNCTION get_mapping_id ( p_mapping_name IN VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_mapping_id IS
SELECT	mapping_id
FROM	hxc_mappings
WHERE	name = p_mapping_name;

l_mapping_id hxc_mappings.mapping_id%TYPE;

BEGIN

OPEN  csr_get_mapping_id;
FETCH csr_get_mapping_id INTO l_mapping_id;
CLOSE csr_get_mapping_id;

RETURN l_mapping_id;

END get_mapping_id;

FUNCTION get_mapping_component_id ( p_name IN VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_mapping_component_id IS
SELECT	mapping_component_id
FROM	hxc_mapping_components
WHERE	name = p_name;

l_mapping_component_id hxc_mapping_components.mapping_component_id%TYPE;

BEGIN

OPEN  csr_get_mapping_component_id;
FETCH csr_get_mapping_component_id INTO l_mapping_component_id;
CLOSE csr_get_mapping_component_id;

RETURN l_mapping_component_id;

END get_mapping_component_id;


PROCEDURE load_mapping_comp_usage_row (
          p_name                IN VARCHAR2
        , p_mapping_name        IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_mapping_comp_usage_id	hxc_mapping_comp_usages.mapping_comp_usage_id%TYPE;
l_mapping_component_id	hxc_mapping_components.mapping_component_id%TYPE;
l_mapping_id		hxc_mappings.mapping_id%TYPE;
l_ovn			hxc_mapping_comp_usages.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

l_mapping_id	:= get_mapping_id ( p_mapping_name => p_mapping_name );

l_mapping_component_id := get_mapping_component_id ( p_name => p_name );

	SELECT	mcu.mapping_comp_usage_id
	,	mcu.object_version_number
	,	DECODE( NVL( mcu.last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_mapping_comp_usage_id
	,	l_ovn
	,	l_owner
	FROM	hxc_mapping_comp_usages mcu
	,	hxc_mapping_components mpc
	WHERE	mpc.name	= P_NAME
	AND	mcu.mapping_component_id = mpc.mapping_component_id
	AND	mcu.mapping_id		 = l_mapping_id;


-- NOTE - there is no update section since updating the intersection table changes nothing

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_mcu_ins.ins ( p_mapping_comp_usage_id => l_mapping_comp_usage_id
	,		  p_object_version_number => l_ovn
	,		  p_mapping_component_id  => l_mapping_component_id
	,		  p_mapping_id            => l_mapping_id );

END load_mapping_comp_usage_row;

END hxc_mcu_upload_pkg;

/
