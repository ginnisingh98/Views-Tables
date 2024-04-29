--------------------------------------------------------
--  DDL for Package Body HXC_HAS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAS_UPLOAD_PKG" AS
/* $Header: hxchasupl.pkb 115.9 2002/06/10 01:19:34 pkm ship      $ */

PROCEDURE load_has_row (
          p_name		VARCHAR2
        , p_legislation_code    VARCHAR2
	, p_description		VARCHAR2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 ) IS

l_approval_style_id	hxc_approval_styles.approval_style_id%TYPE;
l_ovn			hxc_approval_styles.object_version_number%TYPE := NULL;
l_owner			VARCHAR2(6);


BEGIN

	SELECT	approval_style_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_approval_style_id
	,	l_ovn
	,	l_owner
	FROM	hxc_approval_styles
	WHERE	name	= P_NAME;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

		hxc_approval_styles_api.update_approval_styles (
				  p_approval_style_id	=> l_approval_style_id
			,	  p_name		=> p_name
			,         p_business_group_id   => null
			,         p_legislation_code    => p_legislation_code
			,	  p_description		=> p_description
	  		,	  p_object_version_number  => l_ovn );

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_approval_styles_api.create_approval_styles (
			  p_name                   => p_name
		,         p_legislation_code    => p_legislation_code
		,	  p_description		   => p_description
		,	  p_approval_style_id 	   => l_approval_style_id
		,	  p_object_version_number  => l_ovn  );

END load_has_row;

END hxc_has_upload_pkg;

/
