--------------------------------------------------------
--  DDL for Package Body HXC_TIME_CATEGORY_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_CATEGORY_HOOK" as
/* $Header: hxchtchk.pkb 120.5 2006/03/24 16:27:16 jdupont noship $ */

g_debug boolean := hr_utility.debug_enabled;

procedure maintain_pto_time_category (
		p_accrual_plan_id	  NUMBER default null
	,       p_net_calculation_rule_id NUMBER default null
	,	p_delete		BOOLEAN ) IS

l_proc	VARCHAR2(72) ;
l_dummy VARCHAR2(1);

CURSOR csr_get_time_category_info ( p_tc_name VARCHAR2 ) IS
SELECT
	tc.time_category_name
,	tc.time_category_id
,	tc.object_version_number
FROM
	hxc_time_categories tc
WHERE
	tc.time_Category_name like p_tc_name;

CURSOR  csr_get_accrual_plan_name ( p_pap_id NUMBER) IS
SELECT  pap.accrual_plan_name
FROM	pay_accrual_plans pap
WHERE	pap.accrual_plan_id = p_pap_id;


CURSOR  csr_get_accrual_plan_id IS
SELECT  ncr.accrual_plan_id
FROM	pay_net_calculation_rules ncr
WHERE	ncr.net_calculation_rule_id = p_net_calculation_rule_id;


CURSOR csr_get_elements ( p_pap_id NUMBER, p_ncr_id NUMBER ) IS
SELECT
	ap.accrual_plan_name
,	ncr.element_type_id
,	ncr.element_type_name
,	ncr.add_or_subtract
FROM
	pay_accrual_plans ap
,	pay_net_calculation_rules_v ncr
WHERE
	ncr.accrual_plan_id         = p_pap_id AND
	ncr.net_calculation_rule_id = p_ncr_id
AND
	ap.accrual_plan_id  = ncr.accrual_plan_id
ORDER BY
        ncr.net_calculation_rule_id;

CURSOR	csr_get_mpc_id IS
SELECT	mpc.mapping_component_id
FROM	hxc_mapping_components mpc
WHERE	mpc.name = 'Dummy Element Context';

CURSOR  csr_get_tc_comp ( p_tc_id NUMBER, p_mpc_id NUMBER, p_element_type_id NUMBER ) IS
SELECT	tcc.time_category_comp_id
,	tcc.object_version_number
FROM	hxc_time_category_comps tcc
WHERE	tcc.time_category_id  = p_tc_id
AND	tcc.component_type_id = p_mpc_id
AND	tcc.value_id = TO_CHAR(p_element_type_id);

CURSOR  csr_chk_tc_comps ( p_tc_id NUMBER ) IS
SELECT	'x'
FROM	hxc_time_categories tc
WHERE	tc.time_category_id = p_tc_id
AND	EXISTS ( select 'x'
		 FROM   hxc_time_category_comps tcc
		 WHERe  tcc.time_category_id = tc.time_category_id );

CURSOR  csr_get_min_inc_ncr ( p_pap_id NUMBER ) IS
SELECT  MIN (net_calculation_rule_id)
FROM    pay_net_calculation_rules
WHERE   accrual_plan_id = p_pap_id
AND     add_or_subtract = 1;

l_accrual_info	csr_get_elements%ROWTYPE;
l_dec_tc_name	hxc_time_categories.time_category_name%TYPE;
l_inc_tc_name	hxc_time_categories.time_category_name%TYPE;
l_tc_name	hxc_time_categories.time_category_name%TYPE;

l_dec_tc_id	hxc_time_categories.time_category_id%TYPE;
l_dec_tc_ovn	hxc_time_categories.object_version_number%TYPE;
l_inc_tc_id	hxc_time_categories.time_category_id%TYPE;
l_inc_tc_ovn	hxc_time_categories.object_version_number%TYPE;

l_tcc_id	hxc_time_category_comps.time_category_comp_id%TYPE;
l_tcc_ovn	hxc_time_category_comps.object_version_number%TYPE;
l_mpc_id	hxc_mapping_components.mapping_component_id%TYPE;

l_tc_info	csr_get_time_category_info%ROWTYPE;

l_pap_id	    pay_accrual_plans.accrual_plan_id%TYPE;
l_accrual_plan_name pay_accrual_plans.accrual_plan_name%TYPE;
l_min_inc_ncr_id    pay_net_calculation_rules.net_calculation_rule_id%TYPE;

l_session_id number;
l_old_user_id number;
l_old_resp_id number;
l_old_resp_appl_id number;
l_old_security_group_id number;
l_old_login_id number;

l_alter_Session varchar2(50) := 'alter session set sql_trace TRUE';

BEGIN


l_old_user_id := fnd_global.user_id;
l_old_resp_id := fnd_global.resp_id;
l_old_resp_appl_id := fnd_global.resp_appl_id;
l_old_security_group_id := fnd_global.security_group_id;
l_old_login_id := fnd_global.login_id;

hr_general2.init_fndload (p_resp_appl_id => 809 );

if g_debug then
	l_proc := g_package||'maintain_pto_time_category';
	hr_utility.trace('********** Params ***********');
	hr_utility.trace('p_accrual_plan_id is  :'||to_char(p_accrual_plan_id));
	hr_utility.trace('p_net_calc_rule_id is :'||to_char(p_net_calculation_rule_id));
end if;

IF ( p_delete )
THEN
	if g_debug then
		hr_utility.trace('Delete is TRUE');
	end if;
ELSE
	if g_debug then
		hr_utility.trace('Delete is FALSE');
	end if;
END IF;

if g_debug then
	hr_utility.trace('******** ENd Params ********');
end if;

if g_debug then
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

IF ( p_accrual_plan_id IS NULL )
THEN

	OPEN  csr_get_accrual_plan_id;
	FETCH csr_get_accrual_plan_id INTO l_pap_id;
	CLOSE csr_get_accrual_plan_id;

ELSE

	l_pap_id := p_accrual_plan_id;

END IF;

OPEN  csr_get_accrual_plan_name ( l_pap_id);
FETCH csr_get_accrual_plan_name INTO l_accrual_plan_name;
CLOSE csr_get_accrual_plan_name;

if g_debug then
	hr_utility.trace('l pap id is '||to_char(l_pap_id));
end if;


-- get the Dummy Element Context mapping component id

OPEN  csr_get_mpc_id;
FETCH csr_get_mpc_id INTO l_mpc_id;
CLOSE csr_get_mpc_id;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

-- set the Time Category name

l_tc_name := SUBSTR('OTL_DEC_'||l_accrual_plan_name,1,90)||'%';

OPEN  csr_get_time_category_info ( l_tc_name );
FETCH csr_get_time_category_info INTO l_tc_info;

IF ( l_tc_info.time_category_name IS NOT NULL )
THEN
	l_dec_tc_name := l_tc_info.time_category_name;
	l_dec_tc_id   := l_tc_info.time_category_id;
	l_dec_tc_ovn  := l_tc_info.object_version_number;

	if g_debug then
		hr_utility.trace('DEC TC NAME is '||l_dec_tc_name);
		hr_utility.trace('DEC TC ID   is '||to_char(l_dec_tc_id));
		hr_utility.trace('DEC TC OVN  is '||to_char(l_dec_tc_ovn));
	end if;

END IF;

CLOSE csr_get_time_category_info;

l_tc_info.time_category_name := NULL;

l_tc_name := SUBSTR('OTL_INC_'||l_accrual_plan_name,1,90)||'%';

OPEN  csr_get_time_category_info ( l_tc_name );
FETCH csr_get_time_category_info INTO l_tc_info;

IF ( l_tc_info.time_category_name IS NOT NULL )
THEN

	l_inc_tc_name := l_tc_info.time_category_name;
	l_inc_tc_id   := l_tc_info.time_category_id;
	l_inc_tc_ovn  := l_tc_info.object_version_number;

	if g_debug then
		hr_utility.trace('INC TC NAME is '||l_inc_tc_name);
		hr_utility.trace('INC TC ID   is '||to_char(l_inc_tc_id));
		hr_utility.trace('INC TC OVN  is '||to_char(l_inc_tc_ovn));
	end if;

END IF;

CLOSE csr_get_time_category_info;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 20);
end if;


OPEN  csr_get_elements ( l_pap_id, p_net_calculation_rule_id );
FETCH csr_get_elements INTO l_accrual_info;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

-- create the new time category name

WHILE csr_get_elements%FOUND
LOOP

	IF ( ( l_dec_tc_name IS NULL ) AND ( NOT p_delete ) AND ( l_accrual_info.add_or_subtract = -1 ) )
	THEN

		-- create time categories

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 40);
		end if;

		-- we always create the DEC since there is always one DEC NCR
		-- which can never be deleted

		l_dec_tc_name := SUBSTR('OTL_DEC_'||l_accrual_info.accrual_plan_name,1,90);

		if g_debug then
			hr_utility.trace('creating DEC TC');
			hr_utility.trace('DEC TC NAME is '||l_dec_tc_name);
		end if;

		hxc_time_category_api.create_time_category (
			 p_time_category_id      => l_dec_tc_id
			,p_object_version_number => l_dec_tc_ovn
			,p_time_category_name    => l_dec_tc_name
                        ,p_operator              => 'OR'
                        ,p_display               => 'Y'
                        ,p_description           => 'System Generated Decrementing PTO Time Category' );

			if g_debug then
				hr_utility.trace('DEC TC ID   is '||to_char(l_dec_tc_id));
				hr_utility.trace('DEC TC OVN  is '||to_char(l_dec_tc_ovn));
			end if;

		-- CREATE time category comp

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 50);

			hr_utility.trace('Creating DEC time component');
		end if;

		hxc_time_category_comp_api.create_time_category_comp (
			 p_time_category_comp_id => l_tcc_id
			,p_object_version_number => l_tcc_ovn
			,p_time_category_id      => l_dec_tc_id
			,p_ref_time_category_id  => NULL
			,p_component_type_id  => l_mpc_id
			,p_flex_value_set_id     => -1
			,p_value_id              => l_accrual_info.element_type_id
                        ,p_is_null               => 'Y'
                        ,p_equal_to              => 'Y'
                        ,p_type                  => 'MC' );

	ELSIF ( ( l_inc_tc_name IS NULL ) AND ( NOT p_delete ) AND ( l_accrual_info.add_or_subtract = 1 ) )
	THEN

		if g_debug then
			hr_utility.trace('Creating INC time component');

			hr_utility.trace('INC TC ID is null');
		end if;

		-- check to see this isn't the first INC NCR

		OPEN  csr_get_min_inc_ncr ( l_pap_id );
		FETCH csr_get_min_inc_ncr INTO l_min_inc_ncr_id;
		CLOSE csr_get_min_inc_ncr;

		if g_debug then
			hr_utility.trace('MIN inc ncr is '||to_char(l_min_inc_ncr_id));
		end if;

		IF ( p_net_calculation_rule_id > l_min_inc_ncr_id )
		THEN

			l_inc_tc_name := SUBSTR('OTL_INC_'||l_accrual_info.accrual_plan_name,1,90);

			if g_debug then
				hr_utility.trace('Creating INC TC');
				hr_utility.trace('INC TC NAME is '||l_inc_tc_name);
			end if;

			hxc_time_category_api.create_time_category (
				 p_time_category_id      => l_inc_tc_id
				,p_object_version_number => l_inc_tc_ovn
				,p_time_category_name    => l_inc_tc_name
	                        ,p_operator              => 'OR'
                                ,p_display               => 'Y'
                                ,p_description           => 'System Generated Inccrementing PTO Time Category' );

			if g_debug then
				hr_utility.trace('INC TC ID   is '||to_char(l_inc_tc_id));
				hr_utility.trace('INC TC OVN  is '||to_char(l_inc_tc_ovn));

				hr_utility.trace('Creating INC time component');
			end if;

			hxc_time_category_comp_api.create_time_category_comp (
				 p_time_category_comp_id => l_tcc_id
				,p_object_version_number => l_tcc_ovn
				,p_time_category_id      => l_inc_tc_id
				,p_ref_time_category_id  => NULL
				,p_component_type_id  => l_mpc_id
				,p_flex_value_set_id     => -1
				,p_value_id              => l_accrual_info.element_type_id
	                        ,p_is_null               => 'Y'
                                ,p_equal_to              => 'Y'
                                ,p_type                  => 'MC' );

		END IF; -- ( p_net_calculation_rule_id > l_min_inc_ncr_id )

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 60);
		end if;

	ELSIF ( ( l_dec_tc_name IS NOT NULL ) AND ( NOT p_delete ) AND ( l_accrual_info.add_or_subtract = -1 ) )
	THEN
		-- updating existing time category

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 70);
		end if;

		-- check to see if this time category comp exists

		OPEN  csr_get_tc_comp ( l_dec_tc_id, l_mpc_id, l_accrual_info.element_type_id );
		FETCH csr_get_tc_comp INTO l_tcc_id, l_tcc_ovn;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 90);
		end if;

		IF ( csr_get_tc_comp%NOTFOUND )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 130);
			end if;

			hxc_time_category_comp_api.create_time_category_comp (
				 p_time_category_comp_id => l_tcc_id
				,p_object_version_number => l_tcc_ovn
				,p_time_category_id      => l_dec_tc_id
				,p_ref_time_category_id  => NULL
				,p_component_type_id  => l_mpc_id
				,p_flex_value_set_id     => -1
				,p_value_id              => l_accrual_info.element_type_id
                                ,p_is_null               => 'Y'
                                ,p_equal_to              => 'Y'
                                ,p_type                  => 'MC' );

		ELSE

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 140);
			end if;

			hxc_time_category_comp_api.update_time_category_comp (
				 p_time_category_comp_id => l_tcc_id
				,p_object_version_number => l_tcc_ovn
				,p_time_category_id      => l_dec_tc_id
				,p_ref_time_category_id  => NULL
				,p_component_type_id  => l_mpc_id
				,p_flex_value_set_id     => -1
				,p_value_id              => l_accrual_info.element_type_id
                                ,p_is_null               => 'Y'
                                ,p_equal_to              => 'Y'
                                ,p_type                  => 'MC' );

		END IF; -- csr_get_tc_comp%NOTFOUND

		CLOSE csr_get_tc_comp;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 150);
		end if;


	ELSIF ( ( l_inc_tc_name IS NOT NULL ) AND ( NOT p_delete ) AND ( l_accrual_info.add_or_subtract = 1 ) )
	THEN

		if g_debug then
			hr_utility.trace('INC TC ID   is '||to_char(l_inc_tc_id));
			hr_utility.trace('INC TC OVN  is '||to_char(l_inc_tc_ovn));
		end if;

		OPEN  csr_get_tc_comp ( l_inc_tc_id, l_mpc_id, l_accrual_info.element_type_id );
		FETCH csr_get_tc_comp INTO l_tcc_id, l_tcc_ovn;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 160);
		end if;

		IF ( csr_get_tc_comp%NOTFOUND )
		THEN

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 170);
			end if;

			hxc_time_category_comp_api.create_time_category_comp (
				 p_time_category_comp_id => l_tcc_id
				,p_object_version_number => l_tcc_ovn
				,p_time_category_id      => l_inc_tc_id
				,p_ref_time_category_id  => NULL
				,p_component_type_id  => l_mpc_id
				,p_flex_value_set_id     => -1
				,p_value_id              => l_accrual_info.element_type_id
                                ,p_is_null               => 'Y'
                                ,p_equal_to              => 'Y'
                                ,p_type                  => 'MC' );

		ELSE

			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 180);
			end if;

			hxc_time_category_comp_api.update_time_category_comp (
				 p_time_category_comp_id => l_tcc_id
				,p_object_version_number => l_tcc_ovn
				,p_time_category_id      => l_inc_tc_id
				,p_ref_time_category_id  => NULL
				,p_component_type_id  => l_mpc_id
				,p_flex_value_set_id     => -1
				,p_value_id              => l_accrual_info.element_type_id
                                ,p_is_null               => 'Y'
                                ,p_equal_to              => 'Y'
                                ,p_type                  => 'MC' );

		END IF; -- csr_get_tc_comp%NOTFOUND

		CLOSE csr_get_tc_comp;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 190);
		end if;

	ELSE

		if g_debug then
			hr_utility.trace('Deleting');

			hr_utility.set_location('Processing '||l_proc, 210);
		end if;

		-- delete an individual time category comp

		-- get tc comp info

		IF ( l_accrual_info.add_or_subtract = -1 )
		THEN

			if g_debug then
				hr_utility.trace('delete dec tcc');
			end if;

			OPEN  csr_get_tc_comp ( l_dec_tc_id, l_mpc_id, l_accrual_info.element_type_id );
			FETCH csr_get_tc_comp INTO l_tcc_id, l_tcc_ovn;

			if g_debug then
				hr_utility.trace('tc id is '||to_char(l_dec_tc_id));
				hr_utility.trace('tc name is '||l_dec_tc_name);
				hr_utility.trace('tc ovn is '||to_char(l_dec_tc_ovn));
				hr_utility.trace('tcc id  is '||to_char(l_tcc_id));
				hr_utility.trace('tcc ovn is '||to_char(l_tcc_ovn));
				hr_utility.trace('element type id is '||to_char(l_accrual_info.element_type_id));
			end if;
                        IF csr_get_tc_comp%FOUND THEN
			   hxc_time_category_comp_api.delete_time_category_comp(
				 p_time_category_comp_id => l_tcc_id
				,p_object_version_number => l_tcc_ovn );
                        END IF;
			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 220);
			end if;

			CLOSE csr_get_tc_comp;

			-- test that this is not the last NCR.
			-- if it is then delete the time category

			OPEN  csr_chk_tc_comps ( l_dec_tc_id );
			FETCH csr_chk_tc_comps INTO l_dummy;

			IF ( csr_chk_tc_comps%NOTFOUND )
			THEN
				if g_debug then
					hr_utility.set_location('Processing '||l_proc, 230);
				end if;

				-- delete the whole time category
                                IF l_dec_tc_id is not null THEN
				hxc_time_category_api.delete_time_category (
						 p_time_category_id      => l_dec_tc_id
						,p_time_category_name    => l_dec_tc_name
						,p_object_version_number => l_dec_tc_ovn );
                                END IF;

			END IF;

			CLOSE csr_chk_tc_comps;

		ELSIF ( l_accrual_info.add_or_subtract = 1 )
		THEN

			-- check to see this isn't the first INC NCR

			OPEN  csr_get_min_inc_ncr ( l_pap_id );
			FETCH csr_get_min_inc_ncr INTO l_min_inc_ncr_id;
			CLOSE csr_get_min_inc_ncr;

			if g_debug then
				hr_utility.trace('MIN inc ncr is '||to_char(l_min_inc_ncr_id));
			end if;

			IF ( p_net_calculation_rule_id > l_min_inc_ncr_id )
			THEN

				if g_debug then
					hr_utility.trace('deleting inc tcc');
				end if;

				OPEN  csr_get_tc_comp ( l_inc_tc_id, l_mpc_id, l_accrual_info.element_type_id );
				FETCH csr_get_tc_comp INTO l_tcc_id, l_tcc_ovn;

				if g_debug then
					hr_utility.trace('tc id is '||to_char(l_inc_tc_id));
					hr_utility.trace('tc name is '||l_inc_tc_name);
					hr_utility.trace('tc ovn is '||to_char(l_inc_tc_ovn));
					hr_utility.trace('tcc id  is '||to_char(l_tcc_id));
					hr_utility.trace('tcc ovn is '||to_char(l_tcc_ovn));
					hr_utility.trace('element type id is '||to_char(l_accrual_info.element_type_id));
				end if;

				IF csr_get_tc_comp%FOUND THEN
				   hxc_time_category_comp_api.delete_time_category_comp(
					 p_time_category_comp_id => l_tcc_id
					,p_object_version_number => l_tcc_ovn );
                                END IF;
				if g_debug then
					hr_utility.set_location('Processing '||l_proc, 240);
				end if;

				CLOSE csr_get_tc_comp;

			ELSIF ( l_inc_tc_id IS NOT NULL )
			THEN
				-- this must be deleting the PTO plan since the user
				-- cannot delete the last inc ncr and the inc tc exists

				hxc_time_category_api.delete_time_category (
						 p_time_category_id      => l_inc_tc_id
						,p_time_category_name    => l_inc_tc_name
						,p_object_version_number => l_inc_tc_ovn );


			END IF; -- ( p_net_calculation_rule_id > l_min_inc_ncr_id )

		END IF; -- ( l_accrual_info.add_or_subtract = -1 )

	END IF; -- l_dec_tc_name IS NULL

FETCH csr_get_elements INTO l_accrual_info;

END LOOP;

CLOSE csr_get_elements;


if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 290);
end if;

fnd_global.INITIALIZE(
    session_id            => l_session_id,
    user_id               => l_old_user_id,
    resp_id               => l_old_resp_id,
    resp_appl_id          => l_old_resp_appl_id,
    security_group_id     => l_old_security_group_id,
    site_id               => -1,
    login_id              => l_old_login_id,
    conc_login_id         => -1,
    prog_appl_id          => -1,
    conc_program_id       => -1,
    conc_request_id       => -1,
    conc_priority_request => null);

EXCEPTION WHEN OTHERS THEN

if g_debug then
	hr_utility.trace('exception');
end if;

fnd_global.INITIALIZE(
    session_id            => l_session_id,
    user_id               => l_old_user_id,
    resp_id               => l_old_resp_id,
    resp_appl_id          => l_old_resp_appl_id,
    security_group_id     => l_old_security_group_id,
    site_id               => -1,
    login_id              => l_old_login_id,
    conc_login_id         => -1,
    prog_appl_id          => -1,
    conc_program_id       => -1,
    conc_request_id       => -1,
    conc_priority_request => null);

raise;

END maintain_pto_time_category;



-- ******************************************
-- create application hook procedures for PTO
-- ******************************************

procedure create_pto_time_category_a (
		p_accrual_plan_id	  NUMBER default null
	,	p_net_calculation_rule_id NUMBER default null ) IS

BEGIN

	maintain_pto_time_category (
                   p_accrual_plan_id         => p_accrual_plan_id
                 , p_net_calculation_rule_id => p_net_calculation_rule_id
                 , p_delete                  => FALSE );

END create_pto_time_category_a;


procedure update_pto_time_category_b (
		p_accrual_plan_id	  NUMBER default null
	,	p_net_calculation_rule_id NUMBER default null ) IS

BEGIN

	maintain_pto_time_category (
                   p_accrual_plan_id         => p_accrual_plan_id
                 , p_net_calculation_rule_id => p_net_calculation_rule_id
                 , p_delete                  => TRUE );

END update_pto_time_category_b;


procedure update_pto_time_category_a (
		p_accrual_plan_id	  NUMBER default null
	,	p_net_calculation_rule_id NUMBER default null ) IS

BEGIN

	maintain_pto_time_category (
                   p_accrual_plan_id         => p_accrual_plan_id
                 , p_net_calculation_rule_id => p_net_calculation_rule_id
                 , p_delete                  => FALSE );

END update_pto_time_category_a;

procedure delete_pto_time_category_b (
		p_net_calculation_rule_id NUMBER default null ) IS

BEGIN

	maintain_pto_time_category (
                   p_accrual_plan_id         => NULL
                 , p_net_calculation_rule_id => p_net_calculation_rule_id
                 , p_delete                  => TRUE );

END delete_pto_time_category_b;


END hxc_time_category_hook;

/
