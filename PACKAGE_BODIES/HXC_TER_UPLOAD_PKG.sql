--------------------------------------------------------
--  DDL for Package Body HXC_TER_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TER_UPLOAD_PKG" AS
/* $Header: hxcterupl.pkb 120.2 2005/09/23 09:20:53 nissharm noship $ */

g_debug boolean := hr_utility.debug_enabled;

PROCEDURE load_ter_row (
          p_name		IN VARCHAR2
        , p_legislation_code    IN VARCHAR2
	, p_rule_usage		IN VARCHAR2
	, p_mapping_name	IN VARCHAR2
	, p_formula_name	IN VARCHAR2
        , p_attribute_category  IN VARCHAR2
	, p_attribute1		IN Varchar2
	, p_attribute2		IN varchar2
	, p_attribute3		IN Varchar2
	, p_attribute4		IN varchar2
	, p_attribute5		IN Varchar2
	, p_attribute6		IN varchar2
	, p_attribute7		IN Varchar2
	, p_attribute8		IN varchar2
	, p_attribute9		IN Varchar2
	, p_attribute10 	IN varchar2
	, p_attribute11 	IN Varchar2
	, p_attribute12 	IN varchar2
	, p_attribute13 	IN Varchar2
	, p_attribute14 	IN varchar2
	, p_attribute15 	IN Varchar2
	, p_attribute16 	IN varchar2
	, p_attribute17 	IN Varchar2
	, p_attribute18 	IN varchar2
	, p_attribute19 	IN Varchar2
	, p_attribute20 	IN varchar2
	, p_attribute21 	IN Varchar2
	, p_attribute22 	IN varchar2
	, p_attribute23 	IN Varchar2
	, p_attribute24 	IN varchar2
	, p_attribute25 	IN Varchar2
	, p_attribute26 	IN varchar2
	, p_attribute27 	IN Varchar2
	, p_attribute28 	IN varchar2
	, p_attribute29 	IN Varchar2
	, p_attribute30 	IN varchar2
	, p_description		IN VARCHAR2
	, p_start_date		IN VARCHAR2
	, p_end_date		IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_time_entry_rule_id	hxc_time_entry_rules.time_entry_rule_id%TYPE;
l_mapping_id		hxc_mappings.mapping_id%TYPE;
l_formula_id		ff_formulas_f.formula_id%TYPE;
l_ovn			hxc_deposit_processes.object_version_number%TYPE := NULL;
l_owner			VARCHAR2(6);
l_formula_name		Varchar2(150);

l_attribute_category  hxc_time_entry_rules.attribute_category%TYPE;
l_attribute1           hxc_time_entry_rules.attribute1%TYPE;
l_attribute2           hxc_time_entry_rules.attribute1%TYPE;

FUNCTION get_ff_id ( p_formula_name VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_ff_id IS
SELECT	formula_id
FROM	ff_formulas_f ff
WHERE   ff.formula_name	= p_formula_name
AND	TO_DATE(p_start_date, 'DD-MM-YYYY') BETWEEN ff.effective_start_date AND ff.effective_end_date;

l_formula_id	ff_formulas_f.formula_id%TYPE;

BEGIN

OPEN  csr_get_ff_id;
FETCH csr_get_ff_id INTO l_formula_id;
CLOSE csr_get_ff_id;

RETURN l_formula_id;

END get_ff_id;

FUNCTION get_app_id ( p_time_recipient_name VARCHAR2 ) RETURN NUMBER IS

l_tr_id hxc_time_recipients.time_recipient_id%TYPE;

CURSOR csr_get_app_id IS
SELECT tr.time_recipient_id
FROM   hxc_time_recipients tr
WHERE  tr.name = p_time_recipient_name;

BEGIN

OPEN  csr_get_app_id;
FETCH csr_get_app_id INTO l_tr_id;
CLOSE csr_get_app_id;

RETURN l_tr_id;

END get_app_id;

FUNCTION get_tc_id ( p_time_category_name VARCHAR2 ) RETURN NUMBER IS

l_tc_id hxc_time_categories.time_category_id%TYPE;

CURSOR csr_get_tc_id IS
SELECT htc.time_category_id
FROM   hxc_time_categories htc
WHERE  htc.time_category_name = p_time_category_name;

BEGIN

OPEN  csr_get_tc_id;
FETCH csr_get_tc_id INTO l_tc_id;
CLOSE csr_get_tc_id;

RETURN l_tc_id;

END get_tc_id;


BEGIN -- load_ter_row

g_debug := hr_utility.debug_enabled;

l_mapping_id	:= hxc_mcu_upload_pkg.get_mapping_id ( p_mapping_name );
l_formula_id	:= get_ff_id ( p_formula_name );
l_attribute_category := p_formula_name;

IF ( p_formula_name = 'HXC_ELP' )
THEN
	l_attribute1 := get_app_id ( p_attribute1 );
	l_attribute2 := get_tc_id ( p_attribute2 );

ELSIF ( p_formula_name = 'HXC_CLA_CHANGE_FORMULA' or p_formula_name = 'HXC_CLA_LATE_FORMULA')
THEN
        if (p_attribute1 is not null) then
	    l_attribute1 := get_tc_id (p_attribute1);
	else
	    l_attribute1 := null;
	end if;

	l_attribute2 := p_attribute2;

ELSE

	l_attribute1 := p_attribute1;
	l_attribute2 := p_attribute2;

END IF;

if g_debug then
	hr_utility.set_location('gaz', 1);
end if;

	SELECT	time_entry_rule_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_time_entry_rule_id
	,	l_ovn
	,	l_owner
	FROM	hxc_time_entry_rules
	WHERE	name	= P_NAME;

if g_debug then
	hr_utility.set_location('gaz', 2);
end if;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

if g_debug then
	hr_utility.set_location('gaz', 3);
end if;
		hxc_time_entry_rule_api.update_time_entry_rule (
				  p_effective_date         => to_date(p_start_date, 'DD-MM-YYYY')
			,	  p_time_entry_rule_id  => l_time_entry_rule_id
			,	  p_name                   => p_name
			,         p_business_group_id      => null
			,         p_legislation_code       => p_legislation_code
			,	  p_rule_usage             => p_rule_usage
			,	  p_start_date             => to_date(p_start_date, 'DD-MM-YYYY')
			,	  p_mapping_id             => l_mapping_id
			,	  p_formula_id             => l_formula_id
			,	  p_description            => p_description
			,	  p_end_date               => to_date(p_end_date, 'DD-MM-YYYY')
			,	  p_attribute_category	   => l_attribute_category
			,	  p_attribute1		   => l_attribute1
			,	  p_attribute2		   => l_attribute2
			,	  p_attribute3		   => p_attribute3
			,	  p_attribute4		   => p_attribute4
			,	  p_attribute5		   => p_attribute5
			,	  p_attribute6		   => p_attribute6
			,	  p_attribute7		   => p_attribute7
			,	  p_attribute8		   => p_attribute8
			,	  p_attribute9		   => p_attribute9
			,	  p_attribute10		   => p_attribute10
			,	  p_attribute11 	   => p_attribute11
			,	  p_attribute12		   => p_attribute12
			,	  p_attribute13		   => p_attribute13
			,	  p_attribute14		   => p_attribute14
			,	  p_attribute15		   => p_attribute15
			,	  p_attribute16		   => p_attribute16
			,	  p_attribute17		   => p_attribute17
			,	  p_attribute18		   => p_attribute18
			,	  p_attribute19		   => p_attribute19
			,	  p_attribute20		   => p_attribute20
			,	  p_attribute21		   => p_attribute21
			,	  p_attribute22		   => p_attribute22
			,	  p_attribute23		   => p_attribute23
			,	  p_attribute24		   => p_attribute24
			,	  p_attribute25		   => p_attribute25
			,	  p_attribute26		   => p_attribute26
			,	  p_attribute27		   => p_attribute27
			,	  p_attribute28		   => p_attribute28
			,	  p_attribute29		   => p_attribute29
			,	  p_attribute30		   => p_attribute30
	  		,	  p_object_version_number  => l_ovn );

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

if g_debug then
	hr_utility.set_location('gaz', 4);
end if;
	hxc_time_entry_rule_api.create_time_entry_rule (
			  p_effective_date         => to_date(p_start_date, 'DD-MM-YYYY')
		,	  p_name                   => p_name
		,         p_business_group_id      => null
		,         p_legislation_code       => p_legislation_code
		,	  p_rule_usage             => p_rule_usage
		,	  p_start_date             => to_date(p_start_date, 'DD-MM-YYYY')
		,	  p_mapping_id             => l_mapping_id
		,	  p_formula_id             => l_formula_id
		,	  p_description            => p_description
		,	  p_end_date               => to_date(p_end_date, 'DD-MM-YYYY')
		,	  p_time_entry_rule_id  => l_time_entry_rule_id
		,	  p_attribute_category	   => l_attribute_category
		,	  p_attribute1		   => l_attribute1
		,	  p_attribute2		   => l_attribute2
		,	  p_attribute3		   => p_attribute3
		,	  p_attribute4		   => p_attribute4
		,	  p_attribute5		   => p_attribute5
		,	  p_attribute6		   => p_attribute6
		,	  p_attribute7		   => p_attribute7
		,	  p_attribute8		   => p_attribute8
		,	  p_attribute9		   => p_attribute9
		,	  p_attribute10		   => p_attribute10
		,	  p_attribute11 	   => p_attribute11
		,	  p_attribute12		   => p_attribute12
		,	  p_attribute13		   => p_attribute13
		,	  p_attribute14		   => p_attribute14
		,	  p_attribute15		   => p_attribute15
		,	  p_attribute16		   => p_attribute16
		,	  p_attribute17		   => p_attribute17
		,	  p_attribute18		   => p_attribute18
		,	  p_attribute19		   => p_attribute19
		,	  p_attribute20		   => p_attribute20
		,	  p_attribute21		   => p_attribute21
		,	  p_attribute22		   => p_attribute22
		,	  p_attribute23		   => p_attribute23
		,	  p_attribute24		   => p_attribute24
		,	  p_attribute25		   => p_attribute25
		,	  p_attribute26		   => p_attribute26
		,	  p_attribute27		   => p_attribute27
		,	  p_attribute28		   => p_attribute28
		,	  p_attribute29		   => p_attribute29
		,	  p_attribute30		   => p_attribute30
		,	  p_object_version_number  => l_ovn  );

END load_ter_row;

PROCEDURE load_daru_row (
          p_time_entry_rule_name IN VARCHAR2
	, p_approval_style_name	IN VARCHAR2
	, p_time_recipient	IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 ) IS

l_data_app_rule_usage_id hxc_data_app_rule_usages.data_app_rule_usage_id%TYPE;
l_time_entry_rule_id hxc_data_app_rule_usages.time_entry_rule_id%TYPE;
l_approval_style_id	hxc_approval_styles.approval_style_id%TYPE;
l_time_recipient_id	hxc_time_recipients.time_recipient_id%TYPE;
l_ovn			hxc_deposit_processes.object_version_number%TYPE;
l_owner			VARCHAR2(6);

FUNCTION get_time_entry_rule_id ( p_time_entry_rule_name VARCHAR2 ) RETURN NUMBER IS

CURSOR	csr_get_ter_id IS
SELECT	time_entry_rule_id
FROM	hxc_time_entry_rules
WHERE	name 	= p_time_entry_rule_name;

l_time_entry_rule_id	hxc_time_entry_rules.time_entry_rule_id%TYPE;

BEGIN

OPEN  csr_get_ter_id;
FETCH csr_get_ter_id INTO l_time_entry_rule_id;
CLOSE csr_get_ter_id;

RETURN l_time_entry_rule_id;

END get_time_entry_rule_id;



FUNCTION get_approval_style_id ( p_approval_style_name VARCHAR2 ) RETURN NUMBER IS

CURSOR csr_get_as_id IS
SELECT	approval_style_id
FROM	hxc_approval_styles
WHERE	name	= p_approval_style_name;

l_approval_style_id	hxc_approval_styles.approval_style_id%TYPE;

BEGIN

OPEN  csr_get_as_id;
FETCH csr_get_as_id INTO l_approval_style_id;
CLOSE csr_get_as_id;

RETURN l_approval_style_id;

END get_approval_style_id;

BEGIN

l_time_entry_rule_id := get_time_entry_rule_id ( p_time_entry_rule_name );
l_approval_style_id	:= get_approval_style_id ( p_approval_style_name );
l_time_recipient_id	:= hxc_ret_upload_pkg.get_time_recipient_id ( p_time_recipient );

	SELECT	data_app_rule_usage_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_data_app_rule_usage_id
	,	l_ovn
	,	l_owner
	FROM	hxc_data_app_rule_usages
	WHERE	time_entry_rule_id	= l_time_entry_rule_id
	AND	approval_style_id	= l_approval_style_id;

	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	THEN

		hxc_data_app_rule_usages_api.update_data_app_rule_usages (
				  p_effective_date		=> sysdate
			,	  p_approval_style_id		=> l_approval_style_id
			,	  p_time_entry_rule_id          => l_time_entry_rule_id
			,	  p_time_recipient_id           => l_time_recipient_id
			,	  p_data_app_rule_usage_id      => l_data_app_rule_usage_id
	  		,	  p_object_version_number	=> l_ovn );

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_data_app_rule_usages_api.create_data_app_rule_usages (
			  p_effective_date         => sysdate
		,	  p_approval_style_id		=> l_approval_style_id
		,	  p_time_entry_rule_id          => l_time_entry_rule_id
		,	  p_time_recipient_id           => l_time_recipient_id
		,	  p_data_app_rule_usage_id      => l_data_app_rule_usage_id
  		,	  p_object_version_number  => l_ovn );

END load_daru_row;

END hxc_ter_upload_pkg;

/
