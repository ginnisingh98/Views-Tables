--------------------------------------------------------
--  DDL for Package Body HXC_ASC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ASC_UPLOAD_PKG" AS
/* $Header: hxcascupl.pkb 120.2 2005/09/23 10:39:09 sechandr noship $ */

g_debug boolean :=hr_utility.debug_enabled;

FUNCTION get_application_set_id ( p_application_set_name IN VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_application_set_id IS
SELECT	application_set_id
FROM	hxc_application_sets_v
WHERE	application_set_name = p_application_set_name;

l_application_set_id hxc_entity_groups.entity_group_id%TYPE;

BEGIN

OPEN  csr_get_application_set_id;
FETCH csr_get_application_set_id INTO l_application_set_id;
CLOSE csr_get_application_set_id;

RETURN l_application_set_id;

END get_application_set_id;

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


PROCEDURE load_application_set_comp_row (
          p_time_recipient_name  IN VARCHAR2
        , p_application_set_name IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_application_set_comp_id	hxc_entity_group_comps.entity_group_comp_id%TYPE;
l_time_recipient_id		hxc_entity_group_comps.entity_id%TYPE;
l_application_set_id		hxc_entity_group_comps.entity_group_id%TYPE;
l_ovn			hxc_entity_group_comps.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN
g_debug:=hr_utility.debug_enabled;
if g_debug then
	hr_utility.set_location ('In load application set comp row ', 10 );
end if;

l_application_set_id	:= get_application_set_id ( p_application_set_name => p_application_set_name );

if g_debug then
	hr_utility.set_location ('In load application set comp row ', 20 );
end if;

l_time_recipient_id := get_time_recipient_id ( p_name => p_time_recipient_name );

if g_debug then
	hr_utility.set_location ('In load application set comp row ', 30 );
end if;

	SELECT	sc.application_set_comp_id
	,	sc.object_version_number
	,	DECODE( NVL( sc.last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_application_set_comp_id
	,	l_ovn
	,	l_owner
	FROM	hxc_application_sets_v aps
	,	hxc_application_set_comps_v sc
	WHERE	sc.time_recipient_id	= l_time_recipient_id
	AND	aps.application_set_id	= sc.application_set_id
	AND	aps.application_set_id  = l_application_set_id;


-- NOTE - there is no update section since updating the intersection table changes nothing

EXCEPTION WHEN NO_DATA_FOUND
THEN

if g_debug then
	hr_utility.set_location ('In load application set comp row ', 40 );
end if;

	hxc_application_set_comp_api.create_application_set_comp (
			  p_application_set_comp_id => l_application_set_comp_id
	,		  p_effective_date          => sysdate
	,		  p_object_version_number   => l_ovn
	,		  p_time_recipient_id       => l_time_recipient_id
	,		  p_application_set_id      => l_application_set_id );

END load_application_set_comp_row;

END hxc_asc_upload_pkg;

/
