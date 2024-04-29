--------------------------------------------------------
--  DDL for Package Body HXC_MAP_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_MAP_UPLOAD_PKG" AS
/* $Header: hxcmapupl.pkb 115.5 2002/06/10 00:37:46 pkm ship      $ */

PROCEDURE load_mapping_row (
          p_name                IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_mapping_id		hxc_mappings.mapping_id%TYPE;
l_ovn			hxc_mappings.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

	SELECT	mapping_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_mapping_id
	,	l_ovn
	,	l_owner
	FROM	hxc_mappings
	WHERE	name	= P_NAME;

-- NOTE - there is no update section since there is nothing to update

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_map_ins.ins( p_mapping_id            => l_mapping_id
	,		 p_object_version_number => l_ovn
	,		 p_name                  => p_name );

END load_mapping_row;

END hxc_map_upload_pkg;

/
