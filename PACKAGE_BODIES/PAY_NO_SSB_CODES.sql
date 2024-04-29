--------------------------------------------------------
--  DDL for Package Body PAY_NO_SSB_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_SSB_CODES" AS
/* $Header: pynossbc.pkb 120.0.12000000.1 2007/05/20 09:29:22 rlingama noship $ */

FUNCTION populate_table
(p_assignment_action_id NUMBER, p_effective_date DATE) RETURN VARCHAR2 IS

CURSOR csr_get_processed_elements (p_assignment_action_id NUMBER,
                                   p_effective_date DATE) IS
select pet.element_type_id,
       pxi.eei_information1 input_value_id,
       prr.run_result_id,
       pxi.eei_information2 ssb_code,
       pxi.eei_information3 add_detail
from
pay_assignment_actions paa,
pay_run_results prr,
pay_element_types_f pet,
pay_element_type_extra_info pxi
where
paa.assignment_action_id =p_assignment_action_id
and paa.assignment_action_id = prr.assignment_action_id
and prr.element_type_id = pet.element_type_id
and p_effective_date between pet.effective_start_date and pet.effective_end_date
and pet.element_type_id = pxi.element_type_id
and pxi.eei_information_category = 'NO_SSB_CODES'
and pxi.eei_information3 = 'SUMMARY'
UNION
select pet.element_type_id,
       pxi.eei_information4 input_value_id,
       prr.run_result_id,
       pxi.eei_information3 ssb_code,
       'AMOUNT' add_detail
from
pay_assignment_actions paa,
pay_run_results prr,
pay_element_types_f pet,
pay_element_type_extra_info pxi
where
paa.assignment_action_id =p_assignment_action_id
and paa.assignment_action_id = prr.assignment_action_id
and prr.element_type_id = pet.element_type_id
and p_effective_date between pet.effective_start_date and pet.effective_end_date
and pet.element_type_id = pxi.element_type_id
and to_char(p_effective_date,'YYYY') between pxi.eei_information1 and nvl(pxi.eei_information2,'4712')
and pxi.eei_information_category = 'NO_EOY_REPORTING_CODE_MAPPING'
order by ssb_code;
--
l_cache_index number;
BEGIN

If (g_ssb_codes_table.count > 0) then
	l_cache_index := g_ssb_codes_table.last + 1;
else
	l_cache_index := 1;
End If;

--hr_utility.set_location('In populate table',10);

for csr_get_processed_elements_rec in csr_get_processed_elements (p_assignment_action_id, p_effective_date)
LOOP

	g_ssb_codes_table(l_cache_index).element_type_id := csr_get_processed_elements_rec.element_type_id;
	g_ssb_codes_table(l_cache_index).input_value_id := csr_get_processed_elements_rec.input_value_id;
	g_ssb_codes_table(l_cache_index).run_result_id := csr_get_processed_elements_rec.run_result_id;
	g_ssb_codes_table(l_cache_index).ssb_code := csr_get_processed_elements_rec.ssb_code;
	g_ssb_codes_table(l_cache_index).add_detail := csr_get_processed_elements_rec.add_detail;


/*hr_utility.set_location('g_ssb_codes_table(l_cache_index).element_type_id: ' || g_ssb_codes_table(l_cache_index).element_type_id, 10);
hr_utility.set_location('g_ssb_codes_table(l_cache_index).input_value_id: ' || g_ssb_codes_table(l_cache_index).input_value_id, 10);
hr_utility.set_location('g_ssb_codes_table(l_cache_index).run_result_id: ' || g_ssb_codes_table(l_cache_index).run_result_id, 10 );
hr_utility.set_location('g_ssb_codes_table(l_cache_index).ssb_code: ' || g_ssb_codes_table(l_cache_index).ssb_code, 10);
hr_utility.set_location('g_ssb_codes_table(l_cache_index).add_detail: ' || g_ssb_codes_table(l_cache_index).add_detail, 10);
*/
	l_cache_index := l_cache_index +1;
END LOOP;
return 'Y';

END populate_table;



FUNCTION set_next_cached_code(p_ssb_code in varchar2)
RETURN VARCHAR2
is
l_cache_index number;
l_ssb_code VARCHAR2(150);

begin

l_ssb_code:='XXXX';

l_cache_index := g_ssb_codes_table.FIRST;

--hr_utility.set_location('in set next ssb code',10);


WHILE l_cache_index IS NOT NULL
LOOP

--hr_utility.set_location('in loop l_cache_index' || l_cache_index,10);
	IF ( g_ssb_codes_table(l_cache_index).ssb_code = p_ssb_code )
	THEN
		l_ssb_code:=p_ssb_code;

	END IF;

	l_cache_index := g_ssb_codes_table.NEXT(l_cache_index);


if l_cache_index is null then
	exit;
end if;

	IF l_ssb_code <> 'XXXX' and g_ssb_codes_table(l_cache_index).ssb_code <> p_ssb_code THEN
		g_next_ssb_code :=g_ssb_codes_table(l_cache_index).ssb_code;
--hr_utility.set_location('g_ssb_codes_table(l_cache_index).ssb_code' || g_ssb_codes_table(l_cache_index).ssb_code,10);
		return g_next_ssb_code;--g_next_ssb_code;
	END IF;
END LOOP;

    g_next_ssb_code := 'NOT FOUND';
--hr_utility.set_location('out set next ssb code',10);
    RETURN 'NOT FOUND';

end set_next_cached_code;


FUNCTION clear_cached_value
(p_ssb_code VARCHAR2) RETURN VARCHAR2
IS
l_cache_index number;
BEGIN
l_cache_index := g_ssb_codes_table.FIRST;


-- filter out the desired preference

WHILE l_cache_index IS NOT NULL
LOOP

	IF ( g_ssb_codes_table(l_cache_index).ssb_code = p_ssb_code )
	THEN

    g_ssb_codes_table.delete(l_cache_index);

	    RETURN 'Y';
	END IF;

	l_cache_index := g_ssb_codes_table.NEXT(l_cache_index);


END LOOP;
	    RETURN 'N';
end clear_cached_value;


FUNCTION get_total_result_value
(p_assignment_action_id NUMBER,
p_ssb_code VARCHAR2
) RETURN NUMBER
IS

CURSOR CSR_SSB_CODES IS
select row_low_range_or_name
from pay_user_tables put,
pay_user_rows_f pur,
fnd_sessions fs
where
put.user_table_name ='NO_SSB_CODE_RULES'
and put.user_table_id = pur.user_table_id
and fs.session_id = userenv('sessionid')
and fs.effective_date between pur.effective_start_date
and pur.effective_end_date;

CURSOR csr_sum_results (p_run_result_id NUMBER, p_input_value_id NUMBER) IS
SELECT to_number (result_value)
FROM pay_run_result_values
WHERE run_result_id = p_run_result_id
AND input_value_id = p_input_value_id;

l_cache_index number;
l_run_result_id pay_run_results.run_result_id%TYPE;
l_input_value_id pay_input_values_f.input_value_id%type;
l_value NUMBER(15):=0;
l_value_sum NUMBER(15):=0;
l_ssb_code VARCHAR2(150);
l_add_detail VARCHAR2(150);

BEGIN

l_ssb_code := 'XXXX';
l_cache_index := g_ssb_codes_table.FIRST;


WHILE l_cache_index IS NOT NULL LOOP

    IF g_ssb_codes_table(l_cache_index).ssb_code = p_ssb_code THEN
			l_add_detail := g_ssb_codes_table(l_cache_index).add_detail;
			l_input_value_id := g_ssb_codes_table(l_cache_index).input_value_id;
			l_run_result_id  := g_ssb_codes_table(l_cache_index).run_result_id;

--hr_utility.set_location('l_run_result_id: ' ||l_run_result_id,10);
--hr_utility.set_location('l_input_value_id: ' ||l_input_value_id,10);

--			IF l_add_detail = 'SUMMARY' THEN
				OPEN csr_sum_results (l_run_result_id, l_input_value_id);
				FETCH csr_sum_results INTO l_value;
				CLOSE csr_sum_results;
--hr_utility.set_location('l_value: '|| l_value,10);
				l_value_sum := l_value_sum + l_value;
--hr_utility.set_location('l_value_sum: '|| l_value_sum,10);

--			END IF;
--hr_utility.set_location('after end if sum',10);

			l_ssb_code:=p_ssb_code;
	END IF;

		      l_cache_index :=g_ssb_codes_table.NEXT(l_cache_index);

if l_cache_index is null then
	exit;
end if;
-- SSB codes are arranged in order in the plsql table.
-- IF the SSB code value gets changed that means all the codes of one type have been exhausted.
-- If condition below checks this condition and exists the loop in case of change;

			IF l_ssb_code <> 'XXXX' and g_ssb_codes_table(l_cache_index).ssb_code <> p_ssb_code THEN
				exit;
			END IF;
END LOOP;

return nvl(l_value_sum,0);

END	get_total_result_value;


FUNCTION get_next_cached_code RETURN VARCHAR2 IS

BEGIN
--hr_utility.set_location('NVL(g_next_ssb_code): ' || NVL(g_next_ssb_code,'XXXX'), 10);
	return NVL(g_next_ssb_code,'XXXX');
END get_next_cached_code ;

FUNCTION get_current_cached_code RETURN VARCHAR2 IS

BEGIN



If (g_ssb_codes_table.count > 0) then
	g_cache_index := g_cache_index  + 1;
End If;

If g_cache_index > g_ssb_codes_table.LAST then
    	return 'XXXX';
end if;

    IF g_current_ssb_code IS NULL THEN
    	if g_cache_index <= g_ssb_codes_table.LAST then
    	g_current_ssb_code := g_ssb_codes_table(g_cache_index).ssb_code;
    	end if;
    	return NVL(g_current_ssb_code,'XXXX');
    ELSE

WHILE g_cache_index IS NOT NULL LOOP

   IF g_ssb_codes_table(g_cache_index).ssb_code = NVL(g_current_ssb_code,'XXXX') THEN

		g_cache_index :=g_ssb_codes_table.NEXT(g_cache_index);

--hr_utility.set_location('g_cache_index: ' || to_char (g_cache_index), 10);

	if g_cache_index is null then
		exit;
	end if;
   END IF;
-- SSB codes are arranged in order in the plsql table.
-- IF the SSB code value gets changed that means all the codes of one type have been exhausted.
-- If condition below checks this condition and exists the loop in case of change;

	IF g_ssb_codes_table(g_cache_index).ssb_code <> NVL(g_current_ssb_code,'XXXX')  THEN
		g_current_ssb_code:= g_ssb_codes_table(g_cache_index).ssb_code;
		return NVL(g_current_ssb_code,'XXXX') ;
	END IF;

    hr_utility.set_location('in while loop',10);
END LOOP;

END IF;

--	g_current_ssb_code:= g_ssb_codes_table(g_cache_index).ssb_code;

--hr_utility.set_location('NVL(g_current_ssb_code): ' || NVL(g_current_ssb_code,'XXXX'), 10);
	return NVL(g_current_ssb_code,'XXXX');
END get_current_cached_code ;

FUNCTION clear_cached_table RETURN VARCHAR2 IS

l_cache_index NUMBER(10);
BEGIN

l_cache_index := g_ssb_codes_table.FIRST;

WHILE l_cache_index IS NOT NULL LOOP

	g_ssb_codes_table.delete(l_cache_index);
	l_cache_index :=g_ssb_codes_table.NEXT(l_cache_index);
END LOOP;

       g_current_ssb_code := null;
       g_next_ssb_code := null;
       g_cache_index   :=0;
RETURN 'Y';
END clear_cached_table;

END pay_no_ssb_codes;

/
