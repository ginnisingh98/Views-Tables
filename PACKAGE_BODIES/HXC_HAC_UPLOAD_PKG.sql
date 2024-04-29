--------------------------------------------------------
--  DDL for Package Body HXC_HAC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAC_UPLOAD_PKG" AS
/* $Header: hxchacupl.pkb 115.7 2002/06/10 01:19:32 pkm ship      $ */

PROCEDURE load_hac_row (
          p_as_name		VARCHAR2
	, p_time_recipient      VARCHAR2
	, p_approval_order 	NUMBER
	, p_approval_mechanism	VARCHAR2
	, p_approval_mechanism_name VARCHAR2
	, p_wf_item_type	VARCHAR2
	, p_wf_name		VARCHAR2
	, p_start_date		VARCHAR2
	, p_end_date		VARCHAR2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 ) IS


l_approval_comp_id	hxc_approval_comps.approval_comp_id%TYPE;
l_approval_style_id	hxc_approval_styles.approval_style_id%TYPE;
l_time_recipient_id	hxc_time_recipients.time_recipient_id%TYPE;
l_approval_mechanism_id hxc_approval_comps.approval_mechanism_id%TYPE;
l_ovn			hxc_approval_styles.object_version_number%TYPE := NULL;
l_owner			VARCHAR2(6);

FUNCTION get_approval_style_id ( p_name VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_as_id IS
SELECT	approval_style_id
FROM	hxc_approval_styles
WHERE	name	= p_name;

l_approval_style_id	hxc_approval_styles.approval_style_id%TYPE;

BEGIN

OPEN  csr_get_as_id;
FETCH csr_get_as_id INTO l_approval_style_id;
CLOSE csr_get_as_id;

RETURN l_approval_style_id;

END get_approval_style_id;

FUNCTION get_formula_id ( p_formula_name VARCHAR2 ) RETURN NUMBER IS

CURSOR  csr_get_ff_id IS
SELECT	ff.formula_id
FROM	ff_formulas_f ff
WHERE	ff.formula_name = p_formula_name;

l_formula_id ff_formulas_f.formula_id%TYPE;

BEGIN

OPEN  csr_get_ff_id;
FETCH csr_get_ff_id INTO l_formula_id;
CLOSE csr_get_ff_id;

RETURN l_formula_id;

END get_formula_id;

BEGIN -- load_hac_row

l_approval_style_id := get_approval_style_id ( p_as_name );
l_time_recipient_id := hxc_ret_upload_pkg.get_time_recipient_id ( p_time_recipient );

IF ( p_approval_mechanism LIKE 'FORMULA%' )
THEN

	l_approval_mechanism_id := get_formula_id ( p_approval_mechanism_name );

END IF;

	SELECT	hac.approval_comp_id
	,	hac.object_version_number
	,	DECODE( NVL(hac.last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_approval_comp_id
	,	l_ovn
	,	l_owner
	FROM	hxc_approval_comps hac
	,	hxc_approval_styles has
	WHERE	has.name	= P_AS_NAME
	AND	hac.approval_style_id = has.approval_style_id
	AND	hac.time_recipient_id = l_time_recipient_id
	AND	hac.approval_mechanism = p_approval_mechanism;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

		hxc_hac_upd.upd (
			p_effective_date	 => sysdate
  		,	p_approval_comp_id       => l_approval_comp_id
  		,	p_object_version_number  => l_ovn
  		,	p_approval_style_id      => l_approval_style_id
  		,	p_time_recipient_id      => l_time_recipient_id
  		,	p_approval_mechanism     => p_approval_mechanism
  		,	p_start_date             => to_date(p_start_date, 'DD-MM-YYYY')
  		,	p_end_date               => to_date(p_end_date, 'DD-MM-YYYY')
  		,	p_approval_mechanism_id  => l_approval_mechanism_id
  		,	p_wf_item_type           => p_wf_item_type
  		,	p_wf_name                => p_wf_name
  		,	p_approval_order         => p_approval_order );

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_hac_ins.ins (
		p_effective_date	 => sysdate
 	,	p_approval_comp_id       => l_approval_comp_id
  	,	p_object_version_number  => l_ovn
  	,	p_approval_style_id      => l_approval_style_id
  	,	p_time_recipient_id      => l_time_recipient_id
  	,	p_approval_mechanism     => p_approval_mechanism
  	,	p_start_date             => to_date(p_start_date, 'DD-MM-YYYY')
  	,	p_end_date               => to_date(p_end_date, 'DD-MM-YYYY')
  	,	p_approval_mechanism_id  => l_approval_mechanism_id
  	,	p_wf_item_type           => p_wf_item_type
  	,	p_wf_name                => p_wf_name
  	,	p_approval_order         => p_approval_order );

END load_hac_row;

END hxc_hac_upload_pkg;

/
