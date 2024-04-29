--------------------------------------------------------
--  DDL for Package Body HXC_DEP_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DEP_UPLOAD_PKG" AS
/* $Header: hxcdepupl.pkb 115.5 2002/06/10 00:36:37 pkm ship      $ */

FUNCTION get_time_source_id ( p_time_source VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_time_source_id IS
SELECT	time_source_id
FROM	hxc_time_sources
WHERE	name	= p_time_source;

l_time_source_id hxc_time_sources.time_source_id%TYPE;

BEGIN

OPEN  csr_get_time_source_id;
FETCH csr_get_time_source_id INTO l_time_source_id;
CLOSE csr_get_time_source_id;

RETURN l_time_source_id;

END get_time_source_id;


PROCEDURE load_deposit_process_row (
          p_name		IN VARCHAR2
	, p_time_source		IN VARCHAR2
	, p_mapping_name	IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_deposit_process_id	hxc_deposit_processes.deposit_process_id%TYPE;
l_time_source_id	hxc_time_sources.time_source_id%TYPE;
l_mapping_id		hxc_mappings.mapping_id%TYPE;
l_ovn			hxc_deposit_processes.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

l_time_source_id	:= get_time_source_id ( p_time_source );
l_mapping_id		:= hxc_mcu_upload_pkg.get_mapping_id ( p_mapping_name );

	SELECT	deposit_process_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_deposit_process_id
	,	l_ovn
	,	l_owner
	FROM	hxc_deposit_processes
	WHERE	name	= P_NAME;

	IF ( p_custom_mode = 'FORCE' OR p_owner = 'SEED' )
	THEN
		hxc_deposit_processes_api.update_deposit_processes (
				  p_effective_date         => sysdate
	  		,	  p_name                   => p_name
	  		,	  p_time_source_id         => l_time_source_id
	  		,	  p_mapping_id             => l_mapping_id
	  		,	  p_deposit_process_id     => l_deposit_process_id
	  		,	  p_object_version_number  => l_ovn );

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_deposit_processes_api.create_deposit_processes (
			  p_effective_date         => sysdate
  		,	  p_name                   => p_name
  		,	  p_time_source_id         => l_time_source_id
  		,	  p_mapping_id             => l_mapping_id
  		,	  p_deposit_process_id     => l_deposit_process_id
  		,	  p_object_version_number  => l_ovn );

END load_deposit_process_row;

END hxc_dep_upload_pkg;

/
