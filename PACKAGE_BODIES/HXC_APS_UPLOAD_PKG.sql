--------------------------------------------------------
--  DDL for Package Body HXC_APS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APS_UPLOAD_PKG" AS
/* $Header: hxcapsupl.pkb 115.5 2002/06/10 00:36:16 pkm ship      $ */

PROCEDURE load_application_set_row (
          p_application_set_name IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_application_set_id	hxc_entity_groups.entity_group_id%TYPE;
l_ovn			hxc_entity_groups.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

	SELECT	application_set_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_application_set_id
	,	l_ovn
	,	l_owner
	FROM	hxc_application_sets_v
	WHERE	application_set_name	= P_APPLICATION_SET_NAME;

-- NOTE - there is no update section since there is nothing to update

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_application_set_api.create_application_set(
			 p_application_set_id    => l_application_set_id
	,		 p_object_version_number => l_ovn
	,		 p_name                  => p_application_set_name );

END load_application_set_row;

END hxc_aps_upload_pkg;

/
