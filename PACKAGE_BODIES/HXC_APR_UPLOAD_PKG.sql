--------------------------------------------------------
--  DDL for Package Body HXC_APR_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APR_UPLOAD_PKG" AS
/* $Header: hxcaprupl.pkb 115.5 2002/06/10 00:36:13 pkm ship      $ */

PROCEDURE load_approval_period_set_row (
          p_approval_period_set_name IN VARCHAR2
	, p_owner	             IN VARCHAR2
	, p_custom_mode		     IN VARCHAR2 ) IS

l_approval_period_set_id	hxc_entity_groups.entity_group_id%TYPE;
l_ovn		        	hxc_entity_groups.object_version_number%TYPE;
l_owner		        	VARCHAR2(6);

BEGIN

	SELECT	approval_period_set_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_approval_period_set_id
	,	l_ovn
	,	l_owner
	FROM	hxc_approval_period_sets
	WHERE	name	= P_APPROVAL_PERIOD_SET_NAME;

-- NOTE - there is no update section since there is nothing to update

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_approval_period_sets_api.create_approval_period_sets(
			 p_approval_period_set_id => l_approval_period_set_id
	,		 p_object_version_number  => l_ovn
	,		 p_name                   => p_approval_period_set_name );

END load_approval_period_set_row;

END hxc_apr_upload_pkg;

/
