--------------------------------------------------------
--  DDL for Package Body HXC_RRG_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RRG_UPLOAD_PKG" AS
/* $Header: hxcrrgupl.pkb 115.4 2002/06/10 13:30:45 pkm ship      $ */

PROCEDURE load_retrieval_rule_group_row (
          p_retrieval_rule_group_name IN VARCHAR2
	, p_owner		      IN VARCHAR2
	, p_custom_mode		      IN VARCHAR2 ) IS

l_retrieval_rule_group_id	hxc_entity_groups.entity_group_id%TYPE;
l_ovn			hxc_entity_groups.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

	SELECT	retrieval_rule_group_id
	,	object_version_number
	,	DECODE( last_updated_by, 1, 'SEED', 'CUSTOM')
	INTO	l_retrieval_rule_group_id
	,	l_ovn
	,	l_owner
	FROM	hxc_retrieval_rule_groups_v
	WHERE	retrieval_rule_group_name	= P_RETRIEVAL_RULE_GROUP_NAME;

-- NOTE - there is no update section since there is nothing to update

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_retrieval_rule_grp_api.create_retrieval_rule_grp(
			 p_retrieval_rule_grp_id    => l_retrieval_rule_group_id
	,		 p_object_version_number      => l_ovn
	,		 p_name                       => p_retrieval_rule_group_name );

END load_retrieval_rule_group_row;

END hxc_rrg_upload_pkg;

/
