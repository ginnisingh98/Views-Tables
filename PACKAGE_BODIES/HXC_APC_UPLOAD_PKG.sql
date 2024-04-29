--------------------------------------------------------
--  DDL for Package Body HXC_APC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APC_UPLOAD_PKG" AS
/* $Header: hxcapcupl.pkb 120.2 2005/09/23 08:04:37 sechandr noship $ */

------------------------------------------------------------------------------
g_debug	boolean		:= hr_utility.debug_enabled;
------------------------------------------------------------------------------
FUNCTION get_approval_period_set_id ( p_approval_period_set_name IN VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_approval_period_set_id IS
SELECT	approval_period_set_id
FROM	hxc_approval_period_sets
WHERE	name = p_approval_period_set_name;

l_approval_period_set_id hxc_entity_groups.entity_group_id%TYPE;

BEGIN

OPEN  csr_get_approval_period_set_id;
FETCH csr_get_approval_period_set_id INTO l_approval_period_set_id;
CLOSE csr_get_approval_period_set_id;

RETURN l_approval_period_set_id;

END get_approval_period_set_id;

FUNCTION get_time_recipient_id ( p_name IN VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_time_recipient_id IS
SELECT	time_recipient_id
FROM	hxc_time_recipients
WHERE	name = p_name;

l_time_recipient_id hxc_time_recipients.time_recipient_id%TYPE;

BEGIN

OPEN  csr_get_time_recipient_id;
FETCH csr_get_time_recipient_id INTO l_time_recipient_id;
CLOSE csr_get_time_recipient_id;

RETURN l_time_recipient_id;

END get_time_recipient_id;

FUNCTION get_recurring_period_id ( p_name IN VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_recurring_period_id IS
SELECT	recurring_period_id
FROM	hxc_recurring_periods
WHERE	name = p_name;

l_recurring_period_id hxc_recurring_periods.recurring_period_id%TYPE;

BEGIN

OPEN  csr_get_recurring_period_id;
FETCH csr_get_recurring_period_id INTO l_recurring_period_id;
CLOSE csr_get_recurring_period_id;

RETURN l_recurring_period_id;

END get_recurring_period_id;

PROCEDURE load_approval_period_comp_row (
          p_time_recipient_name      IN VARCHAR2
        , p_recurring_period_name    IN VARCHAR2
        , p_approval_period_set_name IN VARCHAR2
	, p_owner	       	     IN VARCHAR2
	, p_custom_mode		     IN VARCHAR2 ) IS

l_approval_period_comp_id   hxc_entity_group_comps.entity_group_comp_id%TYPE;
l_time_recipient_id	    hxc_entity_group_comps.entity_id%TYPE;
l_recurring_period_id       hxc_entity_group_comps.entity_id%TYPE;
l_approval_period_set_id    hxc_entity_group_comps.entity_group_id%TYPE;
l_ovn			    hxc_entity_group_comps.object_version_number%TYPE;
l_owner			    VARCHAR2(6);

BEGIN
g_debug:=hr_utility.debug_enabled;
if g_debug then
	hr_utility.set_location ('In load approval period comp row ', 10 );
end if;

l_approval_period_set_id  := get_approval_period_set_id ( p_approval_period_set_name => p_approval_period_set_name );

if g_debug then
	hr_utility.set_location ('In load approval period comp row ', 20 );
end if;

l_time_recipient_id := get_time_recipient_id( p_name => p_time_recipient_name );

l_recurring_period_id := get_recurring_period_id( p_name => p_recurring_period_name );

if g_debug then
	hr_utility.set_location ('In load approval period comp row ', 30 );
end if;

	SELECT	sc.approval_period_comp_id
	,	sc.object_version_number
	,	DECODE( NVL( sc.last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_approval_period_comp_id
	,	l_ovn
	,	l_owner
	FROM	hxc_approval_period_sets aps
	,	hxc_approval_period_comps_v sc
	WHERE	sc.time_recipient_id    	= l_time_recipient_id
        AND     sc.recurring_period_id          = l_recurring_period_id
	AND     sc.approval_period_set_id	= aps.approval_period_set_id
	AND	aps.approval_period_set_id      = l_approval_period_set_id;


-- NOTE - there is no update section since updating the intersection table changes nothing

EXCEPTION WHEN NO_DATA_FOUND
THEN

if g_debug then
	hr_utility.set_location ('In load approval period comp row ', 40 );
end if;

	hxc_approval_period_comps_api.create_approval_period_comps (
		  p_approval_period_comp_id => l_approval_period_comp_id
	,	  p_effective_date          => sysdate
	,	  p_object_version_number   => l_ovn
	,	  p_time_recipient_id       => l_time_recipient_id
        ,         p_recurring_period_id     => l_recurring_period_id
	,	  p_approval_period_set_id  => l_approval_period_set_id );

END load_approval_period_comp_row;

END hxc_apc_upload_pkg;

/
