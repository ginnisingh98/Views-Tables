--------------------------------------------------------
--  DDL for Package Body HXC_RTR_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RTR_UPLOAD_PKG" AS
/* $Header: hxrtrupl.pkb 115.4 2002/03/04 17:55:54 pkm ship      $*/

PROCEDURE load_rtr_row (
          p_name		VARCHAR2
        , p_ret_name		VARCHAR2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 ) IS

l_retrieval_rule_id	hxc_retrieval_rules.retrieval_rule_id%TYPE;
l_retrieval_process_id	hxc_retrieval_processes.retrieval_process_id%TYPE;
l_ovn			hxc_retrieval_rules.object_version_number%TYPE := NULL;
l_owner			VARCHAR2(6);

FUNCTION get_retrieval_process_id ( p_retrieval_process_name VARCHAR2 ) RETURN NUMBER IS

l_retrieval_process_id	hxc_retrieval_processes.retrieval_process_id%TYPE;

CURSOR	csr_get_ret_id IS
SELECT	retrieval_process_id
FROM 	hxc_retrieval_processes
WHERE	name 	= p_retrieval_process_name;

BEGIN

OPEN  csr_get_ret_id;
FETCH csr_get_ret_id INTO l_retrieval_process_id;
CLOSE csr_get_ret_id;

RETURN l_retrieval_process_id;

END get_retrieval_process_id;

BEGIN

l_retrieval_process_id := get_retrieval_process_id ( p_ret_name );

	SELECT	retrieval_rule_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_retrieval_rule_id
	,	l_ovn
	,	l_owner
	FROM	hxc_retrieval_rules
	WHERE	name	= P_NAME;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

		hxc_retrieval_rules_api.update_retrieval_rules (
				  p_effective_date	  => sysdate
			,	  p_retrieval_rule_id	  => l_retrieval_rule_id
			,	  p_retrieval_process_id  => l_retrieval_process_id
			,	  p_name		  => p_name
	  		,	  p_object_version_number => l_ovn );

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_retrieval_rules_api.create_retrieval_rules (
			  p_effective_date	   => sysdate
		,	  p_name                   => p_name
		,	  p_retrieval_rule_id 	   => l_retrieval_rule_id
		,	  p_retrieval_process_id   => l_retrieval_process_id
		,	  p_object_version_number  => l_ovn  );

END load_rtr_row;

PROCEDURE load_rtc_row (
          p_rtr_name		VARCHAR2
	, p_time_recipient      VARCHAR2
	, p_status      	VARCHAR2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 ) IS

l_retrieval_rule_comp_id	hxc_retrieval_rule_comps.retrieval_rule_comp_id%TYPE;
l_retrieval_rule_id	hxc_retrieval_rules.retrieval_rule_id%TYPE;
l_time_recipient_id	hxc_time_recipients.time_recipient_id%TYPE;
l_ovn			hxc_retrieval_rules.object_version_number%TYPE := NULL;
l_owner			VARCHAR2(6);

FUNCTION get_retrieval_rule_id ( p_retrieval_rule_name VARCHAR2 ) RETURN NUMBER IS

l_retrieval_rule_id	hxc_retrieval_rules.retrieval_rule_id%TYPE;

CURSOR	csr_get_rtr_id IS
SELECT	retrieval_rule_id
FROM 	hxc_retrieval_rules
WHERE	name 	= p_retrieval_rule_name;

BEGIN

OPEN  csr_get_rtr_id;
FETCH csr_get_rtr_id INTO l_retrieval_rule_id;
CLOSE csr_get_rtr_id;

RETURN l_retrieval_rule_id;

END get_retrieval_rule_id;

BEGIN

l_time_recipient_id	:= hxc_ret_upload_pkg.get_time_recipient_id ( p_time_recipient );
l_retrieval_rule_id	:= get_retrieval_rule_id ( p_rtr_name );

	SELECT	rtc.retrieval_rule_comp_id
	,	rtc.object_version_number
	,	DECODE( NVL(rtc.last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_retrieval_rule_comp_id
	,	l_ovn
	,	l_owner
	FROM	hxc_retrieval_rule_comps rtc
	WHERE	rtc.retrieval_rule_id	= l_retrieval_rule_id
	AND	rtc.time_recipient_id	= l_time_recipient_id
	AND	rtc.status		= p_status;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

		hxc_retrieval_rule_comps_api.update_retrieval_rule_comps (
				  p_retrieval_rule_id	=> l_retrieval_rule_id
			,	  p_effective_date      => sysdate
			,	  p_status              => p_status
			,	  p_time_recipient_id   => l_time_recipient_id
			,	  p_retrieval_rule_comp_id => l_retrieval_rule_comp_id
	  		,	  p_object_version_number  => l_ovn );

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_retrieval_rule_comps_api.create_retrieval_rule_comps (
			  p_retrieval_rule_id	=> l_retrieval_rule_id
		,	  p_effective_date      => sysdate
		,	  p_status              => p_status
		,	  p_time_recipient_id   => l_time_recipient_id
		,	  p_retrieval_rule_comp_id => l_retrieval_rule_comp_id
  		,	  p_object_version_number  => l_ovn );

END load_rtc_row;

END hxc_rtr_upload_pkg;

/
