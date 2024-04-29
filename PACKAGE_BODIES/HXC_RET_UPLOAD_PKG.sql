--------------------------------------------------------
--  DDL for Package Body HXC_RET_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RET_UPLOAD_PKG" AS
/* $Header: hxcretupl.pkb 115.5 2002/06/10 13:30:33 pkm ship      $ */

FUNCTION get_time_recipient_id ( p_time_recipient VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_time_recipient_id IS
SELECT	time_recipient_id
FROM	hxc_time_recipients
WHERE	name	= p_time_recipient;

l_time_recipient_id hxc_time_recipients.time_recipient_id%TYPE;

BEGIN

OPEN  csr_get_time_recipient_id;
FETCH csr_get_time_recipient_id INTO l_time_recipient_id;
CLOSE csr_get_time_recipient_id;

RETURN l_time_recipient_id;

END get_time_recipient_id;


PROCEDURE load_retrieval_process_row (
          p_name		IN VARCHAR2
	, p_time_recipient	IN VARCHAR2
	, p_mapping_name	IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_retrieval_process_id	hxc_retrieval_processes.retrieval_process_id%TYPE;
l_time_recipient_id	hxc_time_recipients.time_recipient_id%TYPE;
l_mapping_id		hxc_mappings.mapping_id%TYPE;
l_ovn			hxc_deposit_processes.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

l_time_recipient_id	:= get_time_recipient_id ( p_time_recipient );
l_mapping_id		:= hxc_mcu_upload_pkg.get_mapping_id ( p_mapping_name );

	SELECT	retrieval_process_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_retrieval_process_id
	,	l_ovn
	,	l_owner
	FROM	hxc_retrieval_processes
	WHERE	name	= P_NAME;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

	hxc_retrieval_processes_api.update_retrieval_processes (
	  			  p_name                   => p_name
	  		,	  p_time_recipient_id      => l_time_recipient_id
	  		,	  p_mapping_id             => l_mapping_id
	  		,	  p_retrieval_process_id   => l_retrieval_process_id
	  		,	  p_object_version_number  => l_ovn );

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_retrieval_processes_api.create_retrieval_processes (
  			  p_name                   => p_name
  		,	  p_time_recipient_id      => l_time_recipient_id
  		,	  p_mapping_id             => l_mapping_id
  		,	  p_retrieval_process_id   => l_retrieval_process_id
  		,	  p_object_version_number  => l_ovn );

END load_retrieval_process_row;

END hxc_ret_upload_pkg;

/
