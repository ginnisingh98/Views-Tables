--------------------------------------------------------
--  DDL for Package Body HXC_FF_DICT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_FF_DICT" as
/* $Header: hxcffpkg.pkb 120.4 2005/09/23 08:08:37 sechandr noship $ */

g_debug boolean	:=hr_utility.debug_enabled;

function formula(
		 p_formula_id            in number
	,        p_resource_id           in number
	, 	 p_submission_date	 in date
	,	 p_ss_timecard_hours	 in number
	,        p_period_start_date     in date
	,        p_period_end_date       in date
	,	 p_db_pre_period_start	 in date
	,	 p_db_pre_period_end     in date
	,	 p_db_post_period_start	 in date
	,	 p_db_post_period_end    in date
	,	 p_db_ref_period_start	 in date
	,	 p_db_ref_period_end     in date
	,	 p_duration_in_days      in number
        ,        p_param_rec             in r_param )
    return ff_exec.outputs_t is
  --
  l_inputs    ff_exec.inputs_t;
  l_outputs   ff_exec.outputs_t;

l_proc varchar2(72);

l_assignment_id	per_assignments_f.assignment_id%TYPE;

CURSOR  csr_get_asg_id IS
SELECT	asg.assignment_id
FROM	per_assignments_f asg
WHERE	asg.person_id	= p_resource_id
AND	p_submission_date BETWEEN
	asg.effective_start_date AND asg.effective_end_date
AND	asg.primary_flag = 'Y'
AND	asg.assignment_type in ('E','C');

begin -- formula

  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	  l_proc := g_package||'.formula';
	  hr_utility.set_location ('Entering '||l_proc,10);
	  hr_utility.set_location ('Before Init Formula '||l_proc,20);
  end if;
  ff_utils.set_debug(127);
  ff_exec.init_formula
       (p_formula_id     => p_formula_id,
        p_effective_date => p_submission_date,
        p_inputs         => l_inputs,
        p_outputs        => l_outputs);
  if g_debug then
	hr_utility.set_location ('After Init Formula '||l_proc,30);
  end if;

-- check the cache for the assignment id
-- (should always be there now)

IF ( hxc_time_entry_rules_utils_pkg.g_assignment_info.EXISTS ( p_resource_id ) )
THEN

	-- set assignment id from cache

	l_assignment_id := hxc_time_entry_rules_utils_pkg.g_assignment_info(p_resource_id).assignment_id;

ELSE

	OPEN  csr_get_asg_id;
	FETCH csr_get_asg_id INTO l_assignment_id;

	IF csr_get_asg_id%NOTFOUND
	THEN

		CLOSE csr_get_asg_id;

		    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
		    fnd_message.set_token('PROCEDURE', l_proc);
		    fnd_message.set_token('STEP','assignment context');
		    fnd_message.raise_error;

	END IF;

	CLOSE csr_get_asg_id;

END IF;


  -- NOTE that we use special parameter values in order to state which
  -- array locations we put the values into, this is because of the caching
  -- mechanism that formula uses.
  --
  if g_debug then
	  hr_utility.set_location ('First Position'||l_inputs.first,10);
	  hr_utility.set_location ('Last Position'||l_inputs.last,10);
  end if;
  --
  -- Account for case where formula has no contexts or inputs
  --
  for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1) loop
    --
    if g_debug then
	hr_utility.set_location ('Current Context'||l_inputs(l_count).name,10);
    end if;
    --  *** CONTEXTS ****

    if l_inputs(l_count).name = 'DATE_EARNED'
    then

      l_inputs(l_count).value := to_char(p_period_start_date, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'ASSIGNMENT_ID'
    then

      l_inputs(l_count).value := to_char(l_assignment_id);

    --  *** INPUTS ****

    elsif l_inputs(l_count).name = 'RESOURCE_ID' then

      l_inputs(l_count).value := nvl(p_resource_id, -1);

    elsif l_inputs(l_count).name = 'TIMECARD_HRS' then
      --
      l_inputs(l_count).value := p_ss_timecard_hours;
      --
    elsif l_inputs(l_count).name = 'SUBMISSION_DATE' then
      --
      -- Note that you must pass the date as a string, that is because
      -- of the canonical date change of 11.5
      --
      if g_debug then
	hr_utility.set_location ('Submission Date '||to_char(p_submission_date),10);
      end if;
      -- Still the fast formula does't accept the full canonical form.
      -- l_inputs(l_count).value := fnd_date.date_to_canonical(p_submission_date);
      l_inputs(l_count).value := to_char(p_submission_date, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'PERIOD_START_DATE' then
      l_inputs(l_count).value := to_char(p_period_start_date, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'PERIOD_END_DATE' then
      l_inputs(l_count).value := to_char(p_period_end_date, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'DB_PRE_PERIOD_START' then
      l_inputs(l_count).value := to_char(p_db_pre_period_start, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'DB_PRE_PERIOD_END' then
      l_inputs(l_count).value := to_char(p_db_pre_period_end, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'DB_POST_PERIOD_START' then
      l_inputs(l_count).value := to_char(p_db_post_period_start, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'DB_POST_PERIOD_END' then
      l_inputs(l_count).value := to_char(p_db_post_period_end, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'DB_REF_PERIOD_START' then
      l_inputs(l_count).value := to_char(p_db_ref_period_start, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'DB_REF_PERIOD_END' then
      l_inputs(l_count).value := to_char(p_db_ref_period_end, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = 'DURATION_IN_DAYS' then
      l_inputs(l_count).value := to_char(p_duration_in_days);

    elsif l_inputs(l_count).name = 'DATE_EARNED' then
      l_inputs(l_count).value := to_char(p_submission_date, 'YYYY/MM/DD HH24:MI:SS');

    elsif l_inputs(l_count).name = p_param_rec.param1 then
      --
      l_inputs(l_count).value := p_param_rec.param1_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param2 then
      --
      l_inputs(l_count).value := p_param_rec.param2_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param3 then
      --
      l_inputs(l_count).value := p_param_rec.param3_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param4 then
      --
      l_inputs(l_count).value := p_param_rec.param4_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param5 then
      --
      l_inputs(l_count).value := p_param_rec.param5_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param6 then
      --
      l_inputs(l_count).value := p_param_rec.param6_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param7 then
      --
      l_inputs(l_count).value := p_param_rec.param7_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param8 then
      --
      l_inputs(l_count).value := p_param_rec.param8_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param9 then
      --
      l_inputs(l_count).value := p_param_rec.param9_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param10 then
      --
      l_inputs(l_count).value := p_param_rec.param10_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param11 then
      --
      l_inputs(l_count).value := p_param_rec.param11_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param12 then
      --
      l_inputs(l_count).value := p_param_rec.param12_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param13 then
      --
      l_inputs(l_count).value := p_param_rec.param13_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param14 then
      --
      l_inputs(l_count).value := p_param_rec.param14_value;
      --
    elsif l_inputs(l_count).name = p_param_rec.param15 then
      --
      l_inputs(l_count).value := p_param_rec.param15_value;
      --
    end if;
    --
  end loop;
  for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1) loop
    --
    if g_debug then
	hr_utility.set_location ('GAZ Current Context: '||l_inputs(l_count).name||' Value: '||l_inputs(l_count).value ,999);
    end if;
    --
  END LOOP;
  --
  -- Ok we have loaded the input record now run the formula.
  --
  ff_utils.set_debug(127);
  ff_exec.run_formula(p_inputs  => l_inputs,
                      p_outputs => l_outputs);
  --
  if g_debug then
	hr_utility.set_location ('Leaving '||l_proc,10);
  end if;
  for l_count in nvl(l_outputs.first,0)..nvl(l_outputs.last,-1) loop
    --
    if g_debug then
	hr_utility.set_location ('GAZ Current Context: '||l_outputs(l_count).name||' Value: '||l_outputs(l_count).value ,999);
    end if;
    --
  END LOOP;
  return l_outputs;

EXCEPTION WHEN OTHERS THEN

if g_debug then
	hr_utility.trace('gazza - error is '||SQLERRM);
end if;

raise_application_error(-20000,'ORA'||sqlcode||':'||sqlerrm);


end formula;


PROCEDURE decode_formula_segments (
		p_formula_name	  VARCHAR2
	,       p_rule_rec        hxc_time_entry_rules_utils_pkg.csr_get_rules%rowtype
	,	p_param_rec	  IN OUT NOCOPY r_param
	,	p_period_value    IN OUT NOCOPY NUMBER
	,	p_reference_value IN OUT NOCOPY NUMBER
        ,       p_consider_zero_hours IN OUT NOCOPY VARCHAR2 )
IS

CURSOR  csr_get_flex_segments ( p_formula_name ff_formulas_f.formula_name%TYPE ) IS
SELECT	df.end_user_column_name
,	df.application_column_name
FROM
	fnd_descr_Flex_Column_usages df
WHERE
        df.application_id               = 809            AND
	df.descriptive_flexfield_name	= 'OTL Formulas' AND
	df.descriptive_flex_context_code= p_formula_name
ORDER BY
	df.application_column_name;

l_proc	VARCHAR2(72);



PROCEDURE set_pto_time_category ( p_accrual_plan_id NUMBER ) IS

CURSOR  csr_get_time_category_id IS
SELECT  htc.time_category_id
,       htc.time_category_name
FROM	hxc_time_categories htc
,	pay_accrual_plans pap
WHERE
	pap.accrual_plan_id = p_accrual_plan_id
AND (
	( htc.time_category_name like SUBSTR('OTL_DEC_'||pap.accrual_plan_name,1,90)||'%' )
      OR
	( htc.time_category_name like SUBSTR('OTL_INC_'||pap.accrual_plan_name,1,90)||'%' )
    );

l_tc_id NUMBER(15);
l_tc_name VARCHAR2(90);
l_proc  VARCHAR2(72);

BEGIN



if g_debug then
	l_proc := g_package||'.set_pto_time_category';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

OPEN  csr_get_time_category_id;
FETCH csr_get_time_category_id INTO l_tc_id, l_tc_name;

IF ( csr_get_time_category_id%NOTFOUND )
THEN

    CLOSE csr_get_time_category_id;

    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','PTO Time Category');
    fnd_message.raise_error;

END IF;

WHILE csr_get_time_category_id%FOUND
LOOP

    IF ( l_tc_name like 'OTL_DEC_%' )
    THEN

	hxc_time_category_utils_pkg.g_time_category_id := l_tc_id;

    ELSIF ( l_tc_name like 'OTL_INC_%' )
    THEN

	hxc_time_entry_rules_utils_pkg.g_ter_record.ter_inc_pto_plan_id := l_tc_id;

    END IF;

FETCH csr_get_time_category_id INTO l_tc_id, l_tc_name;

END LOOP;

CLOSE csr_get_time_category_id;

END set_pto_time_category;


BEGIN

g_debug:=hr_utility.debug_enabled;
if g_debug then
	 l_proc:= g_package||'.decode_formula_segments';
	 hr_utility.set_location('Entering '||l_proc, 10);
end if;

-- initialise g_time_category_id

hxc_time_category_utils_pkg.g_time_category_id := NULL;

FOR r_seg IN csr_get_flex_segments ( p_formula_name => p_formula_name )
LOOP

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 10);
end if;

	IF ( r_seg.application_column_name = 'ATTRIBUTE1' )
	THEN
		if g_debug then
			hr_utility.trace('');
			hr_utility.trace('attribute 1 param is '||r_seg.end_user_column_name);
			hr_utility.trace('attribute 1 param value is '||p_rule_rec.attribute1);
		end if;

		p_param_rec.param1_value  := p_rule_rec.attribute1;
		p_param_rec.param1	  := UPPER(r_seg.end_user_column_name);

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute1);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute1);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute1);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute1) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute1, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE2' )
	THEN
		if g_debug then
			hr_utility.trace('');
			hr_utility.trace('attribute 2 param is '||r_seg.end_user_column_name);
			hr_utility.trace('attribute 2 param value is '||p_rule_rec.attribute2);
		end if;

		p_param_rec.param2_value  := p_rule_rec.attribute2;
		p_param_rec.param2	  := UPPER(r_seg.end_user_column_name);

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute2);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute2);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute2);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute2) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute2, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE3' )
	THEN
		if g_debug then
			hr_utility.trace('');
			hr_utility.trace('attribute 3 param is '||r_seg.end_user_column_name);
			hr_utility.trace('attribute 3 param value is '||p_rule_rec.attribute3);
		end if;

		p_param_rec.param3_value  := p_rule_rec.attribute3;
		p_param_rec.param3	  := UPPER(r_seg.end_user_column_name);

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute3);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute3);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute3);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute3) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute3, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE4' )
	THEN
		p_param_rec.param4_value  := p_rule_rec.attribute4;
		p_param_rec.param4	  := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute4);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute4);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute4);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute4) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute4, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE5' )
	THEN
		p_param_rec.param5_value  := p_rule_rec.attribute5;
		p_param_rec.param5	  := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute5);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute5);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute5);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute5) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute5, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE6' )
	THEN
		p_param_rec.param6_value  := p_rule_rec.attribute6;
		p_param_rec.param6	  := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute6);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute6);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute6);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute6) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute6, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE7' )
	THEN
		p_param_rec.param7_value  := p_rule_rec.attribute7;
		p_param_rec.param7	  := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute7);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute7);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute7);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute7) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute7, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE8' )
	THEN
		p_param_rec.param8_value  := p_rule_rec.attribute8;
		p_param_rec.param8	  := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute8);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute8);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute8);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute8) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute8, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE9' )
	THEN
		p_param_rec.param9_value  := p_rule_rec.attribute9;
		p_param_rec.param9	  := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute9);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute9);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute9);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute9) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute9, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE10' )
	THEN
		p_param_rec.param10_value  := p_rule_rec.attribute10;
		p_param_rec.param10	   := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute10);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute10);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute10);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute10) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute10, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE11' )
	THEN
		p_param_rec.param11_value  := p_rule_rec.attribute11;
		p_param_rec.param11	   := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute11);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute11);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute11);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute11) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute11, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE12' )
	THEN
		p_param_rec.param12_value  := p_rule_rec.attribute12;
		p_param_rec.param12	   := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute12);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute12);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute12);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute12) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute12, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE13' )
	THEN
		p_param_rec.param13_value  := p_rule_rec.attribute13;
		p_param_rec.param13	   := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute13);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute13);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute13);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute13) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute13, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE14' )
	THEN
		p_param_rec.param14_value  := p_rule_rec.attribute14;
		p_param_rec.param14	   := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute14);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute14);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute14);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute14) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute14, 'Y');

		END IF;

	ELSIF ( r_seg.application_column_name = 'ATTRIBUTE15' )
	THEN
		p_param_rec.param15_value  := p_rule_rec.attribute15;
		p_param_rec.param15	   := r_seg.end_user_column_name;

		IF ( UPPER(r_seg.end_user_column_name) = 'PERIOD' )
		THEN
			p_period_value	:= TO_NUMBER(p_rule_rec.attribute15);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'REFERENCE_PERIOD' )
		THEN
			p_reference_value := TO_NUMBER(p_rule_rec.attribute15);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'TIME_CATEGORY' )
		THEN
			hxc_time_category_utils_pkg.g_time_category_id := TO_NUMBER(p_rule_rec.attribute15);

		ELSIF ( UPPER(r_seg.end_user_column_name) = 'ACCRUAL_PLAN' )
		THEN
			set_pto_time_category ( TO_NUMBER(p_rule_rec.attribute15) );

                ELSIF ( UPPER(r_seg.end_user_column_name) = 'CONSIDER_ZERO_HOURS' )
                THEN
                        p_consider_zero_hours := NVL(p_rule_rec.attribute15, 'Y');

		END IF;

	ELSE
		fnd_message.set_name('HXC', 'HXC_WTD_INVALID_FORMULA_DDF');
		fnd_message.set_token('FORMULA', p_rule_rec.formula_name);
		fnd_message.raise_error;
	END IF;

END LOOP;  -- csr_get_flex_segments

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
end if;


END decode_formula_segments;



FUNCTION execute_approval_formula (
		p_resource_id		NUMBER
	,	p_period_start_date	DATE
	,	p_period_end_date	DATE
	,	p_tc_period_start_date	DATE
	,	p_tc_period_end_date	DATE
	,	p_rule_rec		hxc_time_entry_rules_utils_pkg.csr_get_rules%rowtype
	,	p_message_table		IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE )
RETURN varchar2 IS

l_proc	VARCHAR2(72);

l_result	VARCHAR2(1);
l_param_rec	r_param;
l_outputs	ff_exec.outputs_t;

l_timecard_hrs		NUMBER	:= 0;
l_reference_period	NUMBER(10);
l_consider_zero_hours   VARCHAR2(10);
l_period_id             NUMBER(15);
l_period_tab		hxc_time_entry_rules_utils_pkg.t_period;

l_period_start		DATE;
l_period_start_date	DATE;
l_period_end_date	DATE;
l_period_type	        hxc_recurring_periods.period_type%TYPE;
l_duration_in_days      hxc_recurring_periods.duration_in_days%TYPE;

-- GPM v115.19

l_submission_date	DATE;

CURSOR  csr_get_first_asg_date ( p_resource_id NUMBER ) IS
SELECT	MIN( asg.effective_start_date)
FROM	per_assignments_f asg
WHERE	asg.person_id	= p_resource_id
AND	asg.primary_flag = 'Y'
AND	asg.assignment_type in ('E','C');



FUNCTION fix_periods ( p_period_tab hxc_time_entry_rules_utils_pkg.t_period )
RETURN hxc_time_entry_rules_utils_pkg.t_period IS

l_period_tab	hxc_time_entry_rules_utils_pkg.t_period;

BEGIN

l_period_tab := p_period_tab;

FOR x IN l_period_tab.FIRST .. l_period_tab.LAST
LOOP

IF ( l_period_tab(x).db_pre_period_start  IS NULL AND
     l_period_tab(x).db_pre_period_end    IS NULL AND
     l_period_tab(x).db_post_period_start IS NULL AND
     l_period_tab(x).db_post_period_end   IS NULL )
THEN

	l_period_tab(x).db_pre_period_start := l_period_tab(x).period_start;
	l_period_tab(x).db_pre_period_end   := l_period_tab(x).period_end;

	l_period_tab(x).db_post_period_start := NULL;
	l_period_tab(x).db_post_period_end   := NULL;
	l_period_tab(x).period_start         := NULL;
	l_period_tab(x).period_end           := NULL;

ELSIF ( l_period_tab(x).db_pre_period_start  IS NULL AND
        l_period_tab(x).db_pre_period_end    IS NULL )
THEN

	l_period_tab(x).db_pre_period_start := l_period_tab(x).period_start;
	l_period_tab(x).db_pre_period_end   := l_period_tab(x).db_post_period_end;

	l_period_tab(x).db_post_period_start := NULL;
	l_period_tab(x).db_post_period_end   := NULL;
	l_period_tab(x).period_start         := NULL;
	l_period_tab(x).period_end           := NULL;

ELSIF ( l_period_tab(x).db_post_period_start IS NULL AND
        l_period_tab(x).db_post_period_end   IS NULL )
THEN

	l_period_tab(x).db_pre_period_end   := l_period_tab(x).period_end;

	l_period_tab(x).db_post_period_start := NULL;
	l_period_tab(x).db_post_period_end   := NULL;
	l_period_tab(x).period_start         := NULL;
	l_period_tab(x).period_end           := NULL;

ELSE

	l_period_tab(x).db_pre_period_end   := l_period_tab(x).db_post_period_end;

	l_period_tab(x).db_post_period_start := NULL;
	l_period_tab(x).db_post_period_end   := NULL;
	l_period_tab(x).period_start         := NULL;
	l_period_tab(x).period_end           := NULL;

END IF;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace(' ********** Fix Periods ************** ');
	hr_utility.trace(' TC period start is     :'||TO_CHAR(l_period_tab(x).period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' TC period end is       :'||TO_CHAR(l_period_tab(x).period_end, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' pre TC period start is :'||TO_CHAR(l_period_tab(x).db_pre_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' pre TC period end is   :'||TO_CHAR(l_period_tab(x).db_pre_period_end, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' post TC period start is:'||TO_CHAR(l_period_tab(x).db_post_period_start, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace(' post TC period end is  :'||TO_CHAR(l_period_tab(x).db_post_period_end, 'DD-MON-YY HH24:MI:SS'));
end if;

END LOOP;

RETURN l_period_tab;

END fix_periods;

BEGIN

g_debug:=hr_utility.debug_enabled;
if g_debug then
	l_proc := g_package||'.execute_approval_formula';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

decode_formula_segments (
		p_formula_name	      => p_rule_rec.formula_name
	,       p_rule_rec            => p_rule_rec
	,	p_param_rec	      => l_param_rec
	,	p_period_value        => l_period_id
	,       p_reference_value     => l_reference_period
        ,       p_consider_zero_hours => l_consider_zero_hours );

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

IF ( l_period_id IS NULL )
THEN

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 40);
end if;


-- no period id entered via TER thus use application period

l_period_end_date := TO_DATE(TO_CHAR(p_period_end_date, 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

if g_debug then
	hr_utility.trace('Application approval period start is '||TO_CHAR(p_period_start_date, 'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace('Application approval period end is '  ||TO_CHAR(l_period_end_date, 'DD-MON-YY HH24:MI:SS'));
end if;

hxc_time_entry_rules_utils_pkg.calc_timecard_periods (
		p_timecard_period_start	=> p_tc_period_start_date
	,	p_timecard_period_end	=> p_tc_period_end_date
	,	p_period_start_date	=> p_period_start_date
	,	p_period_end_date	=> l_period_end_date
	,	p_duration_in_days	=> 100 -- arbitrary
	,	p_periods_tab		=> l_period_tab );

ELSE -- user entered period via TER thus override application period

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 50);
end if;

/* NOTE: This code pulled from hxc_time_Entry_rules_utils_pkg */


OPEN  hxc_time_entry_rules_utils_pkg.csr_get_period_info ( p_recurring_period_id => l_period_id );
FETCH hxc_time_entry_rules_utils_pkg.csr_get_period_info INTO l_period_type, l_duration_in_days, l_period_start;
CLOSE hxc_time_entry_rules_utils_pkg.csr_get_period_info;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('*********** Period Info ************');
	hr_utility.trace('period type is '||l_period_type);
	hr_utility.trace('duration in days is  '||TO_CHAR(l_duration_in_days));
	hr_utility.trace('period start date is '||TO_CHAR(l_period_start,'DD-MON-YY HH24:MI:SS'));
end if;

-- gaz - remove this when function changed

IF ( UPPER(l_period_type) = 'WEEK' )
THEN
	l_duration_in_days := 7;

ELSIF( UPPER(l_period_type) = 'BI-WEEK')
THEN
	l_duration_in_days := 14;
END IF;

IF ( l_duration_in_days IS NOT NULL )
THEN

   l_period_start_date := l_period_start +
        (l_duration_in_days *
         FLOOR(((p_tc_period_start_date - l_period_start)/l_duration_in_days)));

   l_period_end_date := l_period_start_date + l_duration_in_days - 1;

ELSE

   -- Call application specific function to generate the period
   -- start and end dates from the period type.

   hr_generic_util.get_period_dates
            (p_rec_period_start_date => l_period_start
            ,p_period_type           => l_period_type
            ,p_current_date          => p_tc_period_start_date
            ,p_period_start_date     => l_period_start_date
            ,p_period_end_date       => l_period_end_date);

   l_duration_in_days := ( l_period_end_date - l_period_start_date ) + 1;

END IF;

-- now add time component to l_period_end

   l_period_end_date := TO_DATE(TO_CHAR(l_period_end_date, 'DD/MM/YYYY')||' 23:59:59','DD/MM/YYYY HH24:MI:SS');

if g_debug then
	Hr_utility.trace('');
	hr_utility.trace('*********** Period Start and End ************');
	hr_utility.trace('period start date is '||TO_CHAR(l_period_start_date,'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace('period end date is   '||TO_CHAR(l_period_end_date,'DD-MON-YY HH24:MI:SS'));
	hr_utility.trace('duration in days is  '||TO_CHAR(l_duration_in_days));
end if;

-- now build up table of time entry rule periods that the timecard
-- may span

hxc_time_entry_rules_utils_pkg.calc_timecard_periods (
		p_timecard_period_start	=> p_tc_period_start_date
	,	p_timecard_period_end	=> p_tc_period_end_date
	,	p_period_start_date	=> l_period_start_date
	,	p_period_end_date	=> l_period_end_date
	,	p_duration_in_days	=> l_duration_in_days
	,	p_periods_tab		=> l_period_tab );

END IF; -- ( l_period_id IS NOT NULL )

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 60);
end if;

-- set submission date to be within valid assignment

OPEN  csr_get_first_asg_date ( p_resource_id );
FETCH csr_get_first_asg_date INTO l_submission_date;
CLOSE csr_get_first_asg_date;

-- Since we are re-using code from TER which assumes we calculated
-- hours from the TC we need to manipulate the table of periods
-- to calculate all hours from the database.

l_period_tab := fix_periods ( l_period_tab );

-- now loop through the periods to execute the formula

FOR p IN l_period_tab.FIRST .. l_period_tab.LAST
LOOP

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 70);
end if;

l_timecard_hrs := 0;

      if g_debug then
	      hr_utility.set_location('Processing '||l_proc, 80);
      end if;

      -- Execute the formula

      if g_debug then
	      hr_utility.trace('Before call to execute formula');
      end if;

-- GPM v115.19
-- take the greater of the first assignment date or the period start date

l_submission_date := GREATEST( l_submission_date, l_period_tab(p).db_pre_period_start );

      l_outputs := hxc_ff_dict.formula(
                        p_formula_id            => p_rule_rec.formula_id
                ,       p_resource_id           => p_resource_id
                ,       p_submission_date       => l_submission_date -- GPM v115.19
		,	p_ss_timecard_hours	=> l_timecard_hrs
		,	p_db_pre_period_start	=> l_period_tab(p).db_pre_period_start
		,	p_db_pre_period_end	=> l_period_tab(p).db_pre_period_end
		,	p_db_post_period_start	=> l_period_tab(p).db_post_period_start
		,	p_db_post_period_end	=> l_period_tab(p).db_post_period_end
		,	p_db_ref_period_start	=> l_period_tab(p).db_ref_period_start
		,	p_db_ref_period_end	=> l_period_tab(p).db_ref_period_end
		,	p_duration_in_days	=> 1
		,	p_param_rec		=> l_param_rec );

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 100);
end if;

      --
      if g_debug then
	      hr_utility.trace('After call to execute formula');
      end if;
      --
      -- Analyze the outputs
      --
      FOR l_count IN l_outputs.FIRST .. l_outputs.LAST
      LOOP
         --
         IF (l_outputs(l_count).name = 'TO_APPROVE') THEN

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 110);
		end if;

            l_result := l_outputs(l_count).value;

	ELSIF ( l_outputs(l_count).name = 'RULE_STATUS' )
	THEN

	-- since time entry rule formulas can potentially also be used
	-- in approvals translate the time entry rule return
	-- value to a value the approvals code can
	-- understand. RULE_STATUS=E is an exception in the
	-- time entry rule world thus is to approve = Y

		IF ( l_outputs(l_count).value = 'E' )
		THEN
			l_result := 'Y';
		ELSE
			l_result := 'N';
		END IF;

	END IF;

     END LOOP; -- formula outputs loop

	-- in the case where we execute the formula many times
	-- exit when the result is Y

	IF ( l_result = 'Y' )
	THEN
		EXIT;
	END IF;

	IF ( p = 1 AND l_period_id IS NULL )
	THEN
	        if g_debug then
			 hr_utility.set_location('Processing '||l_proc, 90);
		end if;

		-- remember only want to do this once for the
		-- application approval period

		EXIT;
	END IF;

END LOOP; -- period loop

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 120);
end if;


 	-- we used to populate the message table here but the approval
 	-- process does not currently support ANY message being returned
 	-- for the formulas executed in the date interdependcy rules

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 130);
end if;

if g_debug then
	hr_utility.trace('l result is  '||l_result);
end if;

RETURN l_result;

EXCEPTION WHEN OTHERS THEN

        if g_debug then
		hr_utility.trace('In exception : '||SQLERRM);
	end if;

	raise;

END execute_approval_formula;

FUNCTION get_formula_segment_value (
           p_param_rec r_param
 ,         p_param fnd_descr_flex_column_usages.end_user_column_name%TYPE ) RETURN hxc_time_entry_rules.attribute1%TYPE IS

l_proc varchar2(72) := g_package||'.get_formula_segment_value';
l_param_value hxc_time_entry_rules.attribute1%TYPE;

BEGIN

IF ( p_param = p_param_rec.param1 )
THEN
	l_param_value := p_param_rec.param1_value;

ELSIF ( p_param = p_param_rec.param2 )
THEN
	l_param_value := p_param_rec.param2_value;

ELSIF ( p_param = p_param_rec.param3 )
THEN
	l_param_value := p_param_rec.param3_value;

ELSIF ( p_param = p_param_rec.param4 )
THEN
	l_param_value := p_param_rec.param4_value;

ELSIF ( p_param = p_param_rec.param5 )
THEN
	l_param_value := p_param_rec.param5_value;

ELSIF ( p_param = p_param_rec.param6 )
THEN
	l_param_value := p_param_rec.param6_value;

ELSIF ( p_param = p_param_rec.param7 )
THEN
	l_param_value := p_param_rec.param7_value;

ELSIF ( p_param = p_param_rec.param8 )
THEN
	l_param_value := p_param_rec.param8_value;

ELSIF ( p_param = p_param_rec.param9 )
THEN
	l_param_value := p_param_rec.param9_value;

ELSIF ( p_param = p_param_rec.param10 )
THEN
	l_param_value := p_param_rec.param10_value;

ELSIF ( p_param = p_param_rec.param11 )
THEN
	l_param_value := p_param_rec.param11_value;

ELSIF ( p_param = p_param_rec.param12 )
THEN
	l_param_value := p_param_rec.param12_value;

ELSIF ( p_param = p_param_rec.param13 )
THEN
	l_param_value := p_param_rec.param13_value;

ELSIF ( p_param = p_param_rec.param14 )
THEN
	l_param_value := p_param_rec.param14_value;

ELSIF ( p_param = p_param_rec.param15 )
THEN
	l_param_value := p_param_rec.param15_value;

ELSE

    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','Invalid formula param name');
    fnd_message.raise_error;

END IF;

RETURN l_param_value;

END get_formula_segment_value;


end hxc_ff_dict;

/
