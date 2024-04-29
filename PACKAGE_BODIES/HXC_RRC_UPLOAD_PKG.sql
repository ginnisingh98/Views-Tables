--------------------------------------------------------
--  DDL for Package Body HXC_RRC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RRC_UPLOAD_PKG" AS
/* $Header: hxcrrcupl.pkb 120.2 2005/09/23 06:19:35 nissharm noship $ */

g_debug boolean := hr_utility.debug_enabled;

FUNCTION get_retrieval_rule_group_id ( p_retrieval_rule_group_name IN VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_rtr_group_id IS
SELECT	retrieval_rule_group_id
FROM	hxc_retrieval_rule_groups_v
WHERE	retrieval_rule_group_name = p_retrieval_rule_group_name;

l_retrieval_rule_group_id hxc_entity_groups.entity_group_id%TYPE;

BEGIN

OPEN  csr_get_rtr_group_id;
FETCH csr_get_rtr_group_id INTO l_retrieval_rule_group_id;
CLOSE csr_get_rtr_group_id;

RETURN l_retrieval_rule_group_id;

END get_retrieval_rule_group_id;

FUNCTION get_retrieval_rule_id ( p_name IN VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_retrieval_rule_id IS
SELECT	retrieval_rule_id
FROM	hxc_retrieval_rules
WHERE	name = p_name;

l_retrieval_rule_id hxc_retrieval_rules.retrieval_rule_id%TYPE;

BEGIN

OPEN  csr_get_retrieval_rule_id;
FETCH csr_get_retrieval_rule_id INTO l_retrieval_rule_id;
CLOSE csr_get_retrieval_rule_id;

RETURN l_retrieval_rule_id;

END get_retrieval_rule_id;

PROCEDURE load_rtr_group_comp_row (
          p_retrieval_rule_name      IN VARCHAR2
        , p_retrieval_rule_group_name IN VARCHAR2
	, p_owner	       	     IN VARCHAR2
	, p_custom_mode		     IN VARCHAR2 ) IS

l_rtr_group_comp_id         hxc_entity_group_comps.entity_group_comp_id%TYPE;
l_retrieval_rule_id	    hxc_entity_group_comps.entity_id%TYPE;
l_retrieval_rule_group_id   hxc_entity_group_comps.entity_group_id%TYPE;
l_ovn			    hxc_entity_group_comps.object_version_number%TYPE;
l_owner			    VARCHAR2(6);

BEGIN

g_debug := hr_utility.debug_enabled;

if g_debug then
	hr_utility.set_location ('In load retrieval rule  comp row ', 10 );
end if;

l_retrieval_rule_group_id  := get_retrieval_rule_group_id ( p_retrieval_rule_group_name =>
                                 p_retrieval_rule_group_name );

if g_debug then
	hr_utility.set_location ('In load retrieval rule  comp row ', 20 );
end if;

l_retrieval_rule_id := get_retrieval_rule_id( p_name => p_retrieval_rule_name );

if g_debug then
	hr_utility.set_location ('In load retrieval rule  comp row ', 30 );
end if;

	SELECT	rrc.retrieval_rule_group_comp_id
	,	rrc.object_version_number
	,	DECODE( NVL( rrc.last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_rtr_group_comp_id
	,	l_ovn
	,	l_owner
	FROM	hxc_retrieval_rule_groups_v rrg
	,	hxc_retrieval_rule_grp_comps_v rrc
	WHERE	rrc.retrieval_rule_id    	= l_retrieval_rule_id
	AND     rrc.retrieval_rule_group_id	= rrg.retrieval_rule_group_id
	AND	rrg.retrieval_rule_group_id     = l_retrieval_rule_group_id;


-- NOTE - there is no update section since updating the intersection table changes nothing

EXCEPTION WHEN NO_DATA_FOUND
THEN

if g_debug then
	hr_utility.set_location ('In load retrieval rule comp row ', 40 );
end if;

	hxc_ret_rule_grp_comp_api.create_ret_rule_grp_comp (
		  p_ret_rule_grp_comp_id    => l_rtr_group_comp_id
	,	  p_effective_date          => sysdate
	,	  p_object_version_number   => l_ovn
	,	  p_retrieval_rule_id       => l_retrieval_rule_id
	,	  p_retrieval_rule_grp_id   => l_retrieval_rule_group_id );

END load_rtr_group_comp_row;

END hxc_rrc_upload_pkg;

/
