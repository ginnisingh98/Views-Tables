--------------------------------------------------------
--  DDL for Package Body PER_CAGR_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAGR_UTILITY_PKG" AS
/* $Header: pecgrutl.pkb 120.0 2005/05/31 06:40:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                          Package Type Specification                      |
-- ----------------------------------------------------------------------------
--

TYPE cagr_log_text_table  IS TABLE OF varchar2(2000)
                          INDEX BY BINARY_INTEGER;

TYPE cagr_log_priority_table  IS TABLE OF number(9)
                              INDEX BY BINARY_INTEGER;
--
-- ----------------------------------------------------------------------------
-- |                          Package Variables (globals)                     |
-- ----------------------------------------------------------------------------
--
g_log_text_table      cagr_log_text_table;
g_log_priority_table  cagr_log_priority_table;
g_pkg                 constant varchar2(25) := 'PER_CAGR_UTILITY_PKG.';
g_log_counter         NUMBER  := 0;
--
-- ----------------------------------------------------------------------------
-- |--------------------< convert_uom_to_data_type >--------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION convert_uom_to_data_type
  (p_uom IN per_cagr_entitlement_items.uom%TYPE) RETURN CHAR IS
  --
  -- Delcare Local Variables
  --
  l_proc      VARCHAR2(72) := g_pkg||'convert_uom_to_data_type';
  l_data_type per_cagr_entitlement_items.column_type%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc||'/'||p_uom,10);
  --
  IF p_uom = 'C' THEN
    --
    hr_utility.set_location(l_proc,20);
	--
	l_data_type := 'VAR';
	--
  ELSIF p_uom IN ('H_DECIMAL1','H_DECIMAL2','H_DECIMAL3'
                 ,'H_HH','I','M','N','ND') THEN
	--
	hr_utility.set_location(l_proc,30);
	--
	l_data_type := 'NUM';
	--
  ELSIF p_uom IN ('D','H_HHMM','H_HHMMSS','T') THEN
    --
	hr_utility.set_location(l_proc,40);
	--
	l_data_type := 'DATE';
	--
  ELSE
    --
	hr_utility.set_location(l_proc,50);
	--
	l_data_type := 'VAR';
	--
  END IF;
  --
  hr_utility.set_location('Leaving  '||l_proc,999);
  --
  RETURN(l_data_type);
  --
END convert_uom_to_data_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_sql_statement >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_sql_statement(p_sql_statement IN VARCHAR2) IS
  --
  -- Delcare Local Variables
  --
  l_proc     VARCHAR2(72) := g_pkg||'chk_sql_statement';
  l_value_id VARCHAR2(200);
  l_name     VARCHAR2(2000);
  --
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  EXECUTE IMMEDIATE p_sql_statement INTO l_value_id, l_name;
  --
  hr_utility.set_location('Leaving '||l_proc,997);
  --
  EXCEPTION
    --
    WHEN TOO_MANY_ROWS THEN
	  --
	  hr_utility.set_location('Leaving '||l_proc,998);
	  --
	WHEN NO_DATA_FOUND THEN
	  --
	  -- If no data was found then ignore this message
	  --
	  NULL;
	  --
    WHEN OTHERS THEN
	  --
	  hr_utility.set_location(l_proc||substr(sqlerrm,1,50),999);
	  hr_utility.set_message(800,'HR_289399_INVALID_VALUE_SET');
      hr_utility.raise_error;
      --
END;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_elig_source >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_elig_source(p_eligy_prfl_id in NUMBER
                        ,p_formula_id in NUMBER
                        ,p_effective_date in DATE) return VARCHAR2 is
  --
  -- Returns the name of the eligibility profile for the criteria line
  -- or the name of the ff for the entitlement
  --

 CURSOR csr_elig IS
   select name
   from ben_eligy_prfl_f
   where ELIGY_PRFL_ID = p_eligy_prfl_id
   and p_effective_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;

 CURSOR csr_ff IS
   select formula_name
   from FF_FORMULAS_F
   where FORMULA_ID = p_formula_id
   and p_effective_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;

  l_proc     VARCHAR2(72) := g_pkg||'get_elig_source';
  l_name     VARCHAR2(200);
  --
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  if p_eligy_prfl_id is not null then
    open csr_elig;
    fetch csr_elig into l_name;
    close csr_elig;
  elsif p_formula_id is not null then
    open csr_ff;
    fetch csr_ff into l_name;
    close csr_ff;
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,50);
  RETURN l_name;
  --
END get_elig_source;

--
-- ----------------------------------------------------------------------------
-- |----------------------< multiple_entries_allowed >------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION multiple_entries_allowed
  (p_element_type_id IN pay_element_types_f.element_type_id%TYPE
  ,p_effective_date  IN DATE) RETURN BOOLEAN IS
  --
  -- Delcare Local Variables
  --
  l_proc         VARCHAR2(72) := g_pkg||'mulitple_entries_allowed';
  l_return_value BOOLEAN;
  l_flag         VARCHAR2(2);
  --
  CURSOR csr_multiple_entries_allowed IS
    SELECT 'X'
      FROM pay_element_types_f p
     WHERE p.element_type_id = p_element_type_id
	   AND p.multiple_entries_allowed_flag = 'Y'
       AND p_effective_date BETWEEN p.effective_start_date
                                         AND p.effective_end_date;
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  OPEN  csr_multiple_entries_allowed;
  FETCH csr_multiple_entries_allowed INTO l_flag;
  --
  IF csr_multiple_entries_allowed%NOTFOUND THEN
    --
	hr_utility.set_location(l_proc,20);
	--
    CLOSE csr_multiple_entries_allowed;
    --
    l_return_value := FALSE;
    --
  ELSIF csr_multiple_entries_allowed%FOUND THEN
    --
	hr_utility.set_location(l_proc,30);
	--
    CLOSE csr_multiple_entries_allowed;
    --
    l_return_value := TRUE;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc,999);
  --
  RETURN(l_return_value);
  --
END multiple_entries_allowed;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_cagr_request_id >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_cagr_request_id (p_assignment_id in NUMBER
                             ,p_effective_date  in DATE) RETURN NUMBER IS
  --
  -- Attemnpts to return the latest cagr_request_id for an assignment on or before
  -- the effective date so that the user may view logs that relate to the run
  -- which failed to return results. As there could be multiple requests generated
  -- on a particular date this function returns the id of the latest request,
  -- which represents the most recent run on or before the session date.
  -- Called from PERWSCAR.fmb View_Log.
  -- Note: The norm is that an CAGR evaluation run produces a result, giving
  -- a handle on the cagr_request_id. When the user taskflows to the form,
  -- when there are no results, then if they do not wish
  -- to refresh the results to get the new cagr_request_id returned to the
  -- results window, (even if no results), this function
  -- may be used to get the request_id of the previous run that failed to
  -- produce entitlement results, so that the log can still be displayed.
  --

  l_effective_date    DATE       := NULL;

  CURSOR csr_requests IS
   select max(cr.cagr_request_id)
   from per_cagr_requests cr
   where cr.assignment_id = p_assignment_id
   and cr.process_date = (select max(cr1.process_date)
                         from per_cagr_requests cr1
                         where cr1.assignment_id = p_assignment_id
                         and l_effective_date >= cr1.process_date);

  l_proc              VARCHAR2(72) := g_pkg||'get_cagr_request_id';
  l_request_id        NUMBER(20) := NULL;

  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  If p_assignment_id is not null and p_effective_date is not null then
  --
    l_effective_date := trunc(p_effective_date);
  --
    OPEN csr_requests;
    FETCH csr_requests INTO l_request_id;
    CLOSE csr_requests;
  End If;
  --
  hr_utility.set_location('Leaving :'|| l_proc, 20);
  RETURN l_request_id;
  --
END get_cagr_request_id;

--
-- ----------------------------------------------------------------------------
-- |---------------------< set_mode_from_node_name >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION set_mode_from_node_name (p_nav_node_usage_id in NUMBER) RETURN VARCHAR2 IS
  --
  -- Returns the mode the form should run in based on node name
  -- (as taskflow doesn't support additional form parameters).
  --
  CURSOR csr_nodes IS
   select n.name
   from hr_navigation_nodes n, hr_navigation_node_usages nu
   where n.NAV_NODE_ID = nu.NAV_NODE_ID
   and nu.NAV_NODE_USAGE_ID = p_nav_node_usage_id;

  --
  l_proc         VARCHAR2(72) := g_pkg||'set_mode_from_node_name';
  l_name         hr_navigation_nodes.name%TYPE;
  l_return       VARCHAR2(20);
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  OPEN csr_nodes;
  FETCH csr_nodes INTO l_name;
  CLOSE csr_nodes;
  --
  IF l_name = 'PERWSCAR' then
    l_return := 'NORMAL';
  elsif l_name = 'PERWSCAR_RETAINED' then
    l_return := 'RETAINED';
  end if;
  --
  hr_utility.set_location('Leaving :'|| l_proc, 999);
  --
  RETURN (l_return);
  --
END set_mode_from_node_name;

--
-- ----------------------------------------------------------------------------
-- |------------------------------< plan_name >-------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION plan_name RETURN VARCHAR2 IS
  --
  -- Declare Sequence Number
  --
  CURSOR csr_seq_number IS
    SELECT ben_pl_f_s.NEXTVAL
    FROM   sys.dual;
  --
  -- Declare Local Variables
  --
  l_proc         VARCHAR2(72) := g_pkg||'plan_name';
  l_seq_number   NUMBER;
  l_plan_name    ben_pl_f.name%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  OPEN csr_seq_number;
  FETCH csr_seq_number INTO l_seq_number;
  --
  CLOSE csr_seq_number;
  --
  l_plan_name := 'CAGR_PLAN_'||l_seq_number;
  --
  hr_utility.set_location('Leaving :'|| l_proc, 999);
  --
  RETURN (l_plan_name);
  --
END plan_name;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< option_name >-----------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION option_name RETURN VARCHAR IS
  --
  -- Declare Cursors
  --
  CURSOR csr_next_sequence IS
    SELECT ben_opt_f_s.NEXTVAL
    FROM   sys.dual;
  --
  -- Declare Local Variables
  --
  l_proc         VARCHAR2(72) := g_pkg||'option_name';
  l_seq_number   NUMBER;
  l_option_name  ben_opt_f.name%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  OPEN csr_next_sequence;
  FETCH csr_next_sequence INTO l_seq_number;
  --
  CLOSE csr_next_sequence;
  --
  l_option_name := 'CAGR_OPTION'||l_seq_number;
  --
  hr_utility.set_location('Leaving :'|| l_proc, 999);
  --
  RETURN(l_option_name);
  --
END option_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_next_order_number >-----------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_next_order_number(p_pl_id IN ben_oipl_f.pl_id%TYPE) RETURN NUMBER IS
  --
  -- Declare Cursors
  --
  CURSOR csr_order_number IS
    SELECT MAX(b.ordr_num)+10
	FROM   ben_oipl_f b
	WHERE  b.pl_id = p_pl_id;
  --
  -- Declare Local Variables
  --
  l_proc         VARCHAR2(72) := g_pkg||'get_order_number';
  l_order_number ben_oipl_f.ordr_num%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  OPEN csr_order_number;
  FETCH csr_order_number INTO l_order_number;
  --
  CLOSE csr_order_number;
  --
  -- If l_order_number is null because its
  -- the first opition in a plan to be created
  -- for the plan then set it to 10
  --
  IF l_order_number IS NULL THEN
    --
    l_order_number := 10;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 999);
  --
  RETURN(l_order_number);
  --
  EXCEPTION
    WHEN OTHERS THEN
      --
      fnd_message.set_name('PER', 'HR_289334_GET_ORDR_NUM_ERROR');
      fnd_message.raise_error;
  --
END get_next_order_number;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_column_type >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_column_type
  (p_cagr_entitlement_item_id IN NUMBER
  ,p_effective_date           IN DATE) RETURN VARCHAR2 IS
  --
  -- Delcare Local Variables
  --
  l_return_value     per_cagr_entitlement_items.column_type%TYPE;
  l_proc             VARCHAR2(72) := g_pkg||'get_column_type';
  l_item_category    per_cagr_entitlement_items.category_name%TYPE;
  l_input_value_id   pay_input_values.input_value_id%TYPE;
  l_uom              per_cagr_entitlement_items.uom%TYPE;
  l_column_type      per_cagr_entitlement_items.column_type%TYPE;
  l_uom_lookup       per_cagr_api_parameters.uom_lookup%TYPE;
  --
  CURSOR csr_get_uom_details IS
    SELECT cei.uom,
	       cei.column_type,
		   p.uom_lookup
	  FROM per_cagr_entitlement_items cei,
	       per_cagr_api_parameters p
	 WHERE cei.cagr_entitlement_item_id = p_cagr_entitlement_item_id
	   AND p.cagr_api_param_id (+)      = cei.cagr_api_param_id;
  --
  CURSOR c_item_category IS
    SELECT pce.category_name,
	       pce.input_value_id
	FROM   per_cagr_entitlement_items pce
	WHERE  pce.cagr_entitlement_item_id = p_cagr_entitlement_item_id;
  --
  CURSOR c_pay_item_type IS
    SELECT piv.uom
	FROM   pay_input_values_f piv
	WHERE  piv.input_value_id = l_input_value_id
	AND    p_effective_date BETWEEN piv.effective_start_date
	                            AND piv.effective_end_date;
  --
  CURSOR c_item_type IS
    SELECT pce.column_type
	FROM   per_cagr_entitlement_items pce
	WHERE  pce.cagr_entitlement_item_id = p_cagr_entitlement_item_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  OPEN  csr_get_uom_details;
  FETCH csr_get_uom_details INTO l_uom,l_column_type,l_uom_lookup;
  CLOSE csr_get_uom_details;
  --
  IF l_uom IS NULL AND l_uom_lookup IS NULL THEN
    --
	hr_utility.set_location(l_proc, 20);
	--
	l_return_value := l_column_type;
	--
  ELSIF l_uom IS NOT NULL AND
        (l_uom_lookup IS NULL OR
		 l_uom_lookup = 'UNITS') THEN
    --
	hr_utility.set_location(l_proc, 30);
	--
	l_return_value := l_uom;
	--
  ELSE
    --
	hr_utility.set_location(l_proc, 40);
	--
	l_return_value := l_column_type;
	--
  END IF;
  --
  /*
  OPEN  c_item_category;
  FETCH c_item_category INTO l_item_category, l_input_value_id;
  --
  IF c_item_category%NOTFOUND THEN
    --
	CLOSE c_item_category;
	--
    fnd_message.set_name('PER', 'HR_289329_ITEM_TYPE_ERROR');
    fnd_message.raise_error;
	--
  END IF;
  --
  hr_utility.set_location(l_proc, 20);
  --
  IF l_item_category = 'PAY' THEN
    --
	hr_utility.set_location(l_proc, 30);
	--
	OPEN c_pay_item_type;
	FETCH c_pay_item_type INTO l_column_type;
	CLOSE c_pay_item_type;
	--
  ELSE
    --
	hr_utility.set_location(l_proc, 40);
	--
    OPEN c_item_type;
    FETCH c_item_type INTO l_column_type;
    --
    IF c_item_type%FOUND THEN
      --
	  hr_utility.set_location(l_proc, 50);
	  --
	  CLOSE c_item_type;
	  --
    ELSE
      --
	  hr_utility.set_location(l_proc, 60);
	  --
	  CLOSE c_item_type;
	  --
	  -- There has been an error in retrieving the
	  -- column type therefore we must error
      --
      fnd_message.set_name('PER', 'HR_289329_ITEM_TYPE_ERROR');
      fnd_message.raise_error;
	  --
    END IF;
	--
  END IF;
  --
  */
  hr_utility.set_location('Leaving:'|| l_proc, 99);
  --
  RETURN(l_return_value);
  --
END get_column_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_sql_from_vset_id >------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_sql_from_vset_id(p_vset_id IN NUMBER) RETURN VARCHAR2 IS
  --
  l_v_r  fnd_vset.valueset_r;
  l_v_dr fnd_vset.valueset_dr;
  l_str  varchar2(4000);
  l_whr  varchar2(4000);
  l_ord  varchar2(4000);
  l_col  varchar2(4000);
  --
BEGIN
  --
  fnd_vset.get_valueset(valueset_id => p_vset_id ,
                        valueset    => l_v_r,
                        format      => l_v_dr);
  --
  IF l_v_r.table_info.table_name IS NULL THEN
    --
    l_str := '';
	--
  END IF;
  --
  IF l_v_r.table_info.id_column_name IS NULL THEN
    --
    l_str := '';
	--
  END IF;
  --
  IF l_v_r.table_info.value_column_name IS NULL THEN
    --
    l_str := '';
	--
  END IF;
  --
  l_whr := l_v_r.table_info.where_clause ;
  l_str := 'select '||substr(l_v_r.table_info.id_column_name,1,instr(l_v_r.table_info.id_column_name||' ',' '))||','
                    ||substr(l_v_r.table_info.value_column_name,1,instr(l_v_r.table_info.value_column_name||' ',' '))
                    ||' from '
                    ||l_v_r.table_info.table_name||' '||l_whr;
  --
  RETURN (l_str);
  --
END get_sql_from_vset_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_name_from_value_set >------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_name_from_value_set
  (p_flex_value_set_id IN NUMBER
  ,p_business_group_id IN NUMBER
  ,p_value             IN CHAR) RETURN VARCHAR2 IS
  --
  -- Overload of get_name_from_value_set to accept vs_id and bg and do less work!
  -- Called from per_cagr_entitlement_results_v view
  --
  -- Delcare Local Variables
  --
  l_sql_statement           VARCHAR2(2000);
  l_value_id                VARCHAR2(10);
  l_id_column               VARCHAR2(200);
  l_name                    VARCHAR2(2000);
  l_proc  varchar2(90) := g_pkg||'get_name_from_value_set overload';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  IF p_flex_value_set_id IS NOT NULL and p_business_group_id is NOT NULL and p_value IS NOT NULL THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
	l_sql_statement := get_sql_from_vset_id(p_vset_id => p_flex_value_set_id);
    --
    l_sql_statement := REPLACE(l_sql_statement
                              ,':$PROFILES$.PER_BUSINESS_GROUP_ID'
						      ,p_business_group_id);
    --
    l_id_column := SUBSTR(l_sql_statement,(INSTR(UPPER(l_sql_statement),'SELECT') +7)
                                          ,INSTR(UPPER(l_sql_statement),',') -
										  (INSTR(UPPER(l_sql_statement),'SELECT')+ 7));

    l_sql_statement := l_sql_statement||' and '||l_id_column||' = :id';
    --
    hr_utility.set_location(l_proc, 40);
    --
	BEGIN
	  --
      EXECUTE IMMEDIATE l_sql_statement INTO l_value_id, l_name USING p_value;
      --
	  EXCEPTION
	    --
		WHEN OTHERS THEN
		  hr_utility.set_message(800,'HR_289399_INVALID_VALUE_SET');
          hr_utility.raise_error;
	  --
	END;
    hr_utility.set_location(l_proc, 50);
    --
  END IF;
  --
  hr_utility.set_location('Leaving :'||l_proc, 60);
  --
  RETURN(l_name);
  --
END get_name_from_value_set;
--
-- ----------------------------------------------------------------------------
-- |--------------- -------< get_name_from_value_set >------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_name_from_value_set
  (p_cagr_entitlement_id IN NUMBER
  ,p_value               IN CHAR) RETURN VARCHAR2 IS
  --
  -- Declare Cursors
  --
  CURSOR csr_entitlement_details IS
    SELECT pci.flex_value_set_id,
	       pci.business_group_id
	  FROM per_cagr_entitlements pce,
	       per_cagr_entitlement_items pci
	 WHERE pci.cagr_entitlement_item_id = pce.cagr_entitlement_item_id
	   AND pce.cagr_entitlement_id      = p_cagr_entitlement_id;
  --
  -- Delcare Local Variables
  --
  l_flex_value_set_id       per_cagr_entitlement_items.flex_value_set_id%TYPE;
  l_business_group_id       per_cagr_entitlement_items.business_group_id%TYPE;
  l_sql_statement           VARCHAR2(2000);
  l_value_id                VARCHAR2(10);
  l_id_column               VARCHAR2(200);
  l_name                    VARCHAR2(2000);
  l_proc  varchar2(72) := g_pkg||'get_name_from_value_set';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc||'/'||
                          p_cagr_entitlement_id||'/'||
						  p_value, 10);
  --
  --
  OPEN csr_entitlement_details;
  FETCH csr_entitlement_details INTO l_flex_value_set_id, l_business_group_id;
  --
  hr_utility.set_location(l_proc, 20);
  --
  CLOSE csr_entitlement_details;
  --
  IF l_flex_value_set_id IS NOT NULL AND p_value IS NOT NULL THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
	l_sql_statement := get_sql_from_vset_id(p_vset_id => l_flex_value_set_id);
    --
    l_sql_statement := REPLACE(l_sql_statement
                              ,':$PROFILES$.PER_BUSINESS_GROUP_ID'
						      ,l_business_group_id);
    --
    l_id_column := SUBSTR(l_sql_statement,(INSTR(UPPER(l_sql_statement),'SELECT') +7)
                                          ,INSTR(UPPER(l_sql_statement),',') -
										  (INSTR(UPPER(l_sql_statement),'SELECT')+ 7));
    --
    l_sql_statement := l_sql_statement||' and '||l_id_column||' = :id';
    --
    hr_utility.set_location(l_proc, 40);
    --
	BEGIN
	  --
      EXECUTE IMMEDIATE l_sql_statement INTO l_value_id, l_name USING p_value;
      --
	  EXCEPTION
	    --
		WHEN OTHERS THEN
		  hr_utility.set_location(l_proc||substr(sqlerrm,1,50),999);
		  hr_utility.set_message(800,'HR_289399_INVALID_VALUE_SET');
          hr_utility.raise_error;
	  --
	END;
    --
    hr_utility.set_location(l_proc, 50);
    --
  END IF;
  --
  hr_utility.set_location('Leaving :'||l_proc, 999);
  --
  RETURN(l_name);
  --
END get_name_from_value_set;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_cagr_request >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_cagr_request (p_process_date IN DATE
                              ,p_operation_mode IN VARCHAR2
                              ,p_business_group_id IN NUMBER
                              ,p_assignment_id IN NUMBER
                              ,p_assignment_set_id IN NUMBER
                              ,p_collective_agreement_id IN NUMBER
                              ,p_collective_agreement_set_id IN NUMBER
                              ,p_payroll_id  IN NUMBER
                              ,p_person_id IN NUMBER
                              ,p_entitlement_item_id IN NUMBER
                              ,p_parent_request_id  IN NUMBER
                              ,p_commit_flag IN VARCHAR2
                              ,p_denormalise_flag IN VARCHAR2
                              ,p_cagr_request_id OUT NOCOPY NUMBER) IS
--
-- Create a per_cagr_request record and return the id to stripe all result and log
-- records by.
--
  pragma autonomous_transaction;

 BEGIN
   insert into per_cagr_requests (cagr_request_id
                                 ,process_date
                                 ,operation_mode
                                 ,business_group_id
                                 ,assignment_id
                                 ,assignment_set_id
                                 ,collective_agreement_id
                                 ,collective_agreement_set_id
                                 ,payroll_id
                                 ,person_id
                                 ,cagr_entitlement_item_id
                                 ,parent_request_id
                                 ,commit_flag
                                 ,denormalise_flag)
                   values     (PER_CAGR_REQUESTS_S.nextval
                              ,trunc(p_process_date)
                              ,p_operation_mode
                              ,p_business_group_id
                              ,p_assignment_id
                              ,p_assignment_set_id
                              ,p_collective_agreement_id
                              ,p_collective_agreement_set_id
                              ,p_payroll_id
                              ,p_person_id
                              ,p_entitlement_item_id
                              ,p_parent_request_id
                              ,p_commit_flag
                              ,p_denormalise_flag) RETURNING cagr_request_id
                                                   INTO p_cagr_request_id;

  commit;

END create_cagr_request;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< put_log >-------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE put_log (p_text IN VARCHAR2
                  ,p_priority IN NUMBER default 2) IS
--
-- Place text in new record within pl/sql log tables
--

 BEGIN
   -- insert new row in the pl/sql log table
   g_log_text_table(g_log_counter) := p_text;
   g_log_priority_table(g_log_counter) := p_priority;
   g_log_counter := g_log_counter + 1;

END put_log;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< write_log_file >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE write_log_file (p_cagr_request_id IN NUMBER)IS

-- Writes text held in pl/sql log table to PER_CAGR_LOG table,
-- and also to host file system via FND_FILE, if run from SRS.

 l_proc constant varchar2(61) := g_pkg || '.write_log_file';

  --
  -- |------------------------------< write_log >-------------------------------|
  --

  PROCEDURE write_log (p_cagr_request_id in NUMBER) IS
  --
  -- Writes text held in pl/sql log table to PER_CAGR_LOG table, AUTONOMOUSLY.
  --
    pragma autonomous_transaction;

   BEGIN
     -- bulk bind pl/sql table to PER_CAGR_LOG.
     forall l_count in g_log_text_table.first .. g_log_text_table.last
          insert into PER_CAGR_LOG
            (LOG_ID
            ,CAGR_REQUEST_ID
            ,TEXT
            ,PRIORITY)
          values
            (PER_CAGR_LOG_S.nextval
            ,p_cagr_request_id
            ,g_log_text_table(l_count)
            ,g_log_priority_table(l_count));

     COMMIT;

  END write_log;

 BEGIN             -- Write_Log_File

   hr_utility.set_location('Entering:'||l_proc, 10);

   -- always populate the cagr log table
   if g_log_text_table.count > 0 then
     write_log(p_cagr_request_id);

     hr_utility.set_location(l_proc, 20);

     if fnd_global.conc_request_id <> -1 then
     -- log is additionally written out via FND_FILE,
     -- for visibility from view SRS window.

       for i in g_log_text_table.first .. g_log_text_table.last loop
         fnd_file.put_line(which => fnd_file.log,   -- Bug 2719987
                           buff  => g_log_text_table(i));
       end loop;
     end if;

     -- remove log entries
     g_log_text_table.delete;
     g_log_priority_table.delete;
   end if;
   hr_utility.set_location('Leaving:'||l_proc, 30);

END write_log_file;

--
-- ----------------------------------------------------------------------------
-- |---------------------< log_and_raise_error >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE log_and_raise_error (p_error IN VARCHAR2
                              ,p_cagr_request_id IN NUMBER) IS
--
-- Accept an error code, log the error message, and raise the error to the
-- calling code.
--
-- Used for errors which should be both logged in per_cagr_log table and
-- raised to calling APPS code, via fnd_message.
--
 BEGIN
  --
   fnd_message.set_name('PER',p_error);
   put_log(fnd_message.get,1);
   write_log_file(p_cagr_request_id);
   fnd_message.raise_error;
  --
END log_and_raise_error;

--
-- ----------------------------------------------------------------------------
-- |---------------------< create_formatted_log_file >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_formatted_log_file (p_cagr_request_id IN  NUMBER
                                    ,p_filepath        OUT NOCOPY VARCHAR2) IS
--
-- Accept cagr_request_id to query entries from per_cagr_log table and write a
-- log file to the file system. Log must have been written in SA mode, so updates
-- from SE, BE mode are not visible. (SC runs dummys as SA)
--
-- Used to create a file that may be viewed in FNDCPVWR.fmb (which is called
-- from PERWSCAR.fmb)

 TYPE logTab IS TABLE OF per_cagr_log.text%TYPE INDEX BY BINARY_INTEGER;

 CURSOR csr_filepath IS
  SELECT decode(substr(value,1,INSTR(value,',')-1),
                NULL, value, substr(value,1,INSTR(value,',')-1)) "filepath"
  FROM v$parameter
  WHERE name = 'utl_file_dir';

 CURSOR csr_log(l_level in NUMBER) IS
  SELECT text
  FROM per_cagr_log
  WHERE cagr_request_id = p_cagr_request_id
  AND priority <= l_level
  AND exists (select 'X' from per_cagr_requests req
              where req.cagr_request_id = p_cagr_request_id
              and req.operation_mode = 'SA')
  ORDER BY log_id;

  l_proc constant varchar2(60) := g_pkg || '.create_formatted_log_file';

  l_cagr_log_table logTab;
  l_filepath       varchar2(255);
  l_name           varchar2(20);
  l_log_detail     varchar2(30);
  l_fileh          utl_file.file_type;

 BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open csr_filepath;
  fetch csr_filepath into l_filepath;
  if csr_filepath%notfound then
    close csr_filepath;
    fnd_message.set_name('PER', 'HR_289832_CAGR_NO_FILEPATH');
    fnd_message.raise_error;
  end if;
  close csr_filepath;

  l_name := p_cagr_request_id||'.txt';

  begin

    hr_utility.set_location(l_proc, 10);
    --
    -- bug 2461389, raise error if filepath is not set
    -- we have not been able to set a path, so raise an error
    -- path is either full value or first string before a comma
    if l_filepath is null then
      fnd_message.set_name('PER', 'HR_289832_CAGR_NO_FILEPATH');
      fnd_message.raise_error;
    end if;
    --
    -- check if the file alrteady exists, else
    -- attempt to open a file for write
    l_fileh := utl_file.fopen(l_filepath,l_name,'w');
    hr_utility.set_location(l_proc, 20);

    -- get log entries restricted to certain levels
    l_log_detail := fnd_profile.value('PER_CAGR_LOG_DETAIL');
    if nvl(l_log_detail,'H') = 'H' then
      -- default to showing everything
      -- when profile not set.
      open csr_log(2);
    else
      open csr_log(1);
    end if;
    fetch csr_log BULK COLLECT into l_cagr_log_table;
    close csr_log;
    If l_cagr_log_table.count > 0 then
      for i in l_cagr_log_table.first .. l_cagr_log_table.last loop
        utl_file.put_line(l_fileh,l_cagr_log_table(i));
      end loop;
    end if;

    -- close file
    utl_file.fclose(l_fileh);

  exception
    when UTL_FILE.INVALID_PATH then
      fnd_message.set_name('PER', 'HR_289832_CAGR_NO_FILEPATH');
      fnd_message.raise_error;
    when UTL_FILE.WRITE_ERROR then
      fnd_message.set_name('PER', 'HR_289833_CAGR_FILE_WRITE_ERR');
      fnd_message.raise_error;
   end;

   -- id the directory separator?

   -- pass back the concatenated path and file name
    p_filepath := l_filepath||'/'||l_name;

  --
  hr_utility.set_location('Leaving:'||l_proc, 40);

  --
END create_formatted_log_file;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< remove_log_entries >---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE remove_log_entries (p_cagr_request_id IN  NUMBER) IS
--
-- Accept cagr_request_id, if there are no more results existing for the request_id
-- then delete all records in the per_cagr_log table for that request_id.
--
-- Called from the engine after removing a result set for a request_id.
--

 CURSOR csr_more_results IS
  SELECT 'X'
  FROM per_cagr_entitlement_results
  WHERE cagr_request_id = p_cagr_request_id
  AND rownum = 1;

  l_proc constant varchar2(60) := g_pkg || '.remove_log_entries';
  l_dummy       varchar2(1);

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 10);

  open csr_more_results;
  fetch csr_more_results into l_dummy;
  if csr_more_results%notfound then
    close csr_more_results;
    begin
      hr_utility.set_location(l_proc, 20);

      DELETE FROM per_cagr_log
      WHERE cagr_request_id = p_cagr_request_id;

      per_cagr_utility_pkg.put_log('     last result deleted for cagr_request_id '
               ||p_cagr_request_id||', log entries deleted');

    exception
      when no_data_found then
        null;
    end;
  else
    close csr_more_results;
  end if;


  hr_utility.set_location('Leaving:'||l_proc, 30);

END remove_log_entries;


--
-- ----------------------------------------------------------------------------
-- |---------------------< get_collective_agreement_id >----------------------|
-- ----------------------------------------------------------------------------
--

FUNCTION get_collective_agreement_id(p_assignment_id IN NUMBER
                                    ,p_effective_date IN DATE) RETURN NUMBER IS

  CURSOR csr_get_cagr is
   select collective_agreement_id
   from per_all_assignments_f
   where assignment_id = p_assignment_id
   and p_effective_date between effective_start_date
                        and nvl(effective_end_date,hr_general.end_of_time);

  l_id     per_all_assignments_f.collective_agreement_id%TYPE;
BEGIN

  open csr_get_cagr;
  fetch csr_get_cagr into l_id;
  close csr_get_cagr;

  return l_id;

END get_collective_agreement_id;
-- ----------------------------------------------------------------------------
-- |---------------------< populate_current_asg >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure populate_current_asg(p_assignment_id     IN            NUMBER
                              ,p_sess              IN            date
                              ,p_grade_ladder_name IN OUT nocopy varchar2
                              ,p_grade_name        IN OUT nocopy varchar2
                              ,p_step              IN OUT nocopy varchar2
                              ,p_salary            IN OUT nocopy varchar2
                       ) IS
  --
  -- Fix for bug 3648748. Removed per_grades table from the following curosr.
  --
  CURSOR csr_get_current_asg is
       select 	 pgm.name
        	,grdtl.name
        	,pspp.step_id
                ,pqh_gsp_utility.get_cur_sal(p_assignment_id
                                            ,p_sess)
                ,psps.spinal_point_id
                ,psps.grade_spine_id
	from ben_pgm_f pgm
	    ,per_grades_tl grdtl
	    ,per_all_assignments_f paaf
            ,per_spinal_point_placements_f pspp
            ,per_spinal_point_steps_f psps
	where
            paaf.assignment_id = p_assignment_id
	and p_sess between
	    paaf.effective_start_date and paaf.effective_end_date
	and paaf.grade_ladder_pgm_id = pgm.pgm_id
	and p_sess
            between pgm.effective_start_date and pgm.effective_end_date
	and grdtl.grade_id = paaf.grade_id
	and grdtl.language = userenv('LANG')
        and pspp.assignment_id (+)= paaf.assignment_id
	and p_sess
            between pspp.effective_start_date(+)
                and pspp.effective_end_date(+)
        and pspp.step_id = psps.step_id(+)
	and p_sess
            between psps.effective_start_date(+)
                and psps.effective_end_date(+)
        ;

  cursor csr_get_current_gsp is
        select distinct current_grade_name
              ,current_grade_ladder_name
              ,current_step_name
              ,current_sal
              ,currency_code
              ,currency_name
         from  pqh_gsp_electable_choice_v
         where assignment_id = p_assignment_id
         and rownum <= 1;

  l_proc            VARCHAR2(72) := g_pkg||'populate_current_asg';
  l_grade           varchar2(240) := null;
  l_grade_ladder    varchar2(240) := null;
  l_step            varchar2(240) := null;
  l_step_name       varchar2(240) := null;
  l_salary          varchar2(100) := null;
  l_currency_code   varchar2(50) := null;
  l_currency_name   varchar2(50) := null;
  l_step_id         number;
  l_spinal_point_id number;
  l_grade_spine_id  number;

  BEGIN

  hr_utility.set_location('Entering:' || l_proc,10);
  /*
    --
    -- Comment out for BUG3282957
    --
  open csr_get_current_gsp;
  fetch csr_get_current_gsp into l_grade,l_grade_ladder,l_step,l_salary
                                ,l_currency_code,l_currency_name;
  if csr_get_current_gsp%NOTFOUND then
    hr_utility.set_location(l_proc,20);
    close csr_get_current_gsp;
  else
    hr_utility.set_location(l_proc,30);
    close csr_get_current_gsp;
    p_grade_name        := l_grade;
    p_grade_ladder_name := l_grade_ladder;
    p_step              := l_step;
    p_salary            := l_salary;
  end if;
*/
  --
  -- BUG3282957
  -- Using csr_get_current_asg intead of csr_get_current_gsp
  --
  open csr_get_current_asg;
  fetch csr_get_current_asg into l_grade_ladder,l_grade,l_step,l_salary
                                ,l_spinal_point_id,l_grade_spine_id;
  if csr_get_current_asg%NOTFOUND then
    hr_utility.set_location(l_proc,20);
    close csr_get_current_asg;
  else
    hr_utility.set_location(l_proc,30);
    close csr_get_current_asg;
    p_grade_name        := l_grade;
    p_grade_ladder_name := l_grade_ladder;
    p_salary            := l_salary;

    per_spinal_point_steps_pkg.pop_flds(l_Step_name,
                                       p_sess,
                                       l_spinal_point_id,
                                       l_grade_spine_id);

    hr_utility.trace('step              :' || l_step_name);

    p_step              := l_step_name;
  end if;

  hr_utility.trace('grade_name        :' || p_grade_name);
  hr_utility.trace('grade_ladder_name :' || p_grade_ladder_name);
  hr_utility.trace('step              :' || p_step);
  hr_utility.trace('salary            :' || p_salary);
  hr_utility.trace('currency_code     :' || l_currency_code);
  hr_utility.trace('currency_name     :' || l_currency_name);

  hr_utility.set_location(' Leaving:' || l_proc,40);
END populate_current_asg;

END per_cagr_utility_pkg;

/
