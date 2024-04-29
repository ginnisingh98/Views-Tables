--------------------------------------------------------
--  DDL for Package Body HXC_MPC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_MPC_UPLOAD_PKG" AS
/* $Header: hxcmpcupl.pkb 115.7 2002/06/10 13:30:25 pkm ship      $ */

FUNCTION find_bld_blk_info_type_id ( p_bld_Blk_info_type VARCHAR2 ) RETURN number IS

CURSOR	csr_get_bld_blk_info_type_id IS
SELECT	bld_blk_info_type_id
FROM	hxc_bld_blk_info_types
WHERE	bld_blk_info_type	= p_bld_blk_info_type;

l_bld_blk_info_type_id hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;

BEGIN

OPEN  csr_get_bld_blk_info_type_id;
FETCH csr_get_bld_blk_info_type_id INTO l_bld_blk_info_type_id;
CLOSE csr_get_bld_blk_info_type_id;

RETURN l_bld_blk_info_type_id;

END find_bld_blk_info_type_id;


PROCEDURE load_mapping_component_row (
          p_name                IN VARCHAR2
	, p_field_name		IN VARCHAR2
	, p_bld_blk_info_type	IN VARCHAR2
	, p_segment		IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_bld_blk_info_type_id	hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;
l_bld_blk_info_type	hxc_bld_blk_info_types.bld_blk_info_type%TYPE;
l_segment		hxc_mapping_components.segment%TYPE;
l_field_name		hxc_mapping_components.field_name%TYPE;
l_mapping_component_id  hxc_mapping_components.mapping_component_id%TYPE;
l_ovn			hxc_mapping_components.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

l_bld_blk_info_type_id := find_bld_blk_info_type_id ( p_bld_blk_info_type );

BEGIN

	SELECT	mapping_component_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	,	field_name
	,	bld_blk_info_type
	,	segment
	INTO	l_mapping_component_id
	,	l_ovn
	,	l_owner
	,	l_field_name
	,	l_bld_blk_info_type
	,	l_segment
	FROM	hxc_mapping_components_v
	WHERE	name	= P_NAME;

/* ALLOW UPDATE TO FLAG THAT MAPPING COMPONENTS CANNOT BE UPDATED
  THROUGH THE LOADER IF THEY ARE REFERENCED BY MAPPING */

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

		-- only update if the mapping component has actually changed

		-- v115.3 - if mpc being used need to use hcdelmpc.sql first

		IF ( ( p_segment <> l_segment ) OR ( p_field_name <> l_field_name )
                  OR ( p_bld_blk_info_type <> l_bld_blk_info_type ) )
		THEN

		hxc_mpc_upd.upd (
				p_mapping_component_id	=> l_mapping_component_id
  			,	p_object_version_number => l_ovn
  			,	p_field_name		=> p_field_name
  			,	p_name			=> p_name
  			,	p_bld_blk_info_type_id	=> l_bld_blk_info_type_id
  			,	p_segment		=> p_segment );

		END IF;

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_mapping_component_api.create_mapping_component (
   		p_field_name		=> p_field_name
	,	p_name			=> p_name
  	,	p_bld_blk_info_type_id	=> l_bld_blk_info_type_id
  	,	p_segment		=> p_segment
  	,	p_mapping_component_id 	=> l_mapping_component_id
  	,	p_object_version_number	=> l_ovn );

END;

END load_mapping_component_row;

END hxc_mpc_upload_pkg;

/
