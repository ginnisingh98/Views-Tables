--------------------------------------------------------
--  DDL for Package Body HXC_HTS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HTS_UPLOAD_PKG" AS
/* $Header: hxchtsupl.pkb 115.7 2004/05/13 02:18:32 dragarwa noship $ */

PROCEDURE load_time_source_row (
          p_name                IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_time_source_id	hxc_time_sources.time_source_id%TYPE;
l_ovn			hxc_time_sources.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

	SELECT	time_source_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_time_source_id
	,	l_ovn
	,	l_owner
	FROM	hxc_time_sources
	WHERE	name	= P_NAME;

-- NOTE - there is no update section since there is nothing to update

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_time_source_api.create_time_source (
			 p_time_source_id        => l_time_source_id
	,		 p_object_version_number => l_ovn
	,		 p_name                  => p_name );

END load_time_source_row;
PROCEDURE load_time_source_row (
          p_name                IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2
	,p_last_update_date         IN VARCHAR2) IS

l_time_source_id	hxc_time_sources.time_source_id%TYPE;
l_ovn			hxc_time_sources.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

	SELECT	time_source_id
	,	object_version_number

	INTO	l_time_source_id
	,	l_ovn

	FROM	hxc_time_sources
	WHERE	name	= P_NAME;

-- NOTE - there is no update section since there is nothing to update

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_time_source_api.create_time_source (
			 p_time_source_id        => l_time_source_id
	,		 p_object_version_number => l_ovn
	,		 p_name                  => p_name );

END load_time_source_row;

END hxc_hts_upload_pkg;

/
