--------------------------------------------------------
--  DDL for Package Body HR_EFC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EFC_INFO" AS
/* $Header: hrefcinf.pkb 120.0 2005/05/31 00:01:00 appldev noship $ */
--
-- Local Variables
--
-- Global constants noting number of insert/update scripts in each phase.
-- g_update_step_10 CONSTANT NUMBER := 118;
-- g_update_step_20 CONSTANT NUMBER := 10;
-- g_update_step_30 CONSTANT NUMBER := 26;
-- g_update_step_40 CONSTANT NUMBER := 1;
-- g_update_step_50 CONSTANT NUMBER := 1;

-- Changed temporarily for the purpose of testing EFC process driver generation
g_update_step_10 CONSTANT NUMBER := 15;
g_update_step_20 CONSTANT NUMBER := 2;
g_update_step_30 CONSTANT NUMBER := 7;
g_update_step_40 CONSTANT NUMBER := 0;
g_update_step_50 CONSTANT NUMBER := 1;
--
-- Global constants noting number of recal scripts in each phase
g_recal_step_10 CONSTANT NUMBER := 9;
g_recal_step_20 CONSTANT NUMBER := 3;
g_recal_step_30 CONSTANT NUMBER := 2;
g_recal_step_40 CONSTANT NUMBER := 1;
g_recal_step_50 CONSTANT NUMBER := 1;
--
g_package varchar2(30) := 'hr_efc_info.';
g_name VARCHAR2(30);
g_bg   NUMBER;
g_last_currency_code   varchar2(15) := null;
g_return_currency_code varchar2(15) := null;
--
-- Cursors
-- Cursor to determine payment type and territory code.
--
  CURSOR csr_fetch_payment_types(c_payment_type_id IN number) IS
    SELECT ppt.payment_type_name
         , ppt.territory_code
         , ppt.category
      FROM pay_payment_types ppt
     WHERE ppt.payment_type_id = c_payment_type_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_bg >----------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_bg RETURN NUMBER IS
--
  l_bg  NUMBER := 0;
  l_proc varchar2(72) := g_package || 'get_bg';
  --
  -- Cursor to determine business group
  CURSOR csr_find_bg IS
    SELECT act.business_group_id
      FROM hr_efc_actions act
     WHERE act.efc_action_status = 'P'
       AND act.efc_action_type = 'C';
--
BEGIN
  --
  OPEN csr_find_bg;
  FETCH csr_find_bg INTO l_bg;
  IF csr_find_bg%NOTFOUND THEN
     -- No current action, so cannot determine business group id
     CLOSE csr_find_bg;
     hr_utility.set_message(800,'PER_52701_EFC_UNDEFINED_BG_ERR');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_find_bg;
  --
  -- Return business_group_id;
  RETURN l_bg;
END get_bg;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_chunk >--------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_chunk RETURN NUMBER IS
--
l_chunk NUMBER := 100;
l_proc   varchar2(72) := g_package || 'get_chunk';
--
CURSOR c_pap(g_name IN varchar2) IS
  SELECT pap.parameter_value
    FROM pay_action_parameters pap
   WHERE pap.parameter_name = g_name;
--
l_pap c_pap%ROWTYPE;
--
BEGIN
  --
  OPEN c_pap('EFC_PROCESS_CHUNK_SIZE');
  FETCH c_pap INTO l_pap;
  IF c_pap%FOUND THEN
     l_chunk := to_number(l_pap.parameter_value);
  END IF;
  CLOSE c_pap;
  --
  --
  -- Return chunk size.
  RETURN l_chunk;
END get_chunk;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_bg_currency >--------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_bg_currency(p_bg NUMBER) RETURN VARCHAR2 IS
--
l_currency VARCHAR2(150) := NULL;
--
CURSOR csr_bg(c_bg IN NUMBER) IS
  SELECT pbg.currency_code
    FROM per_business_groups pbg
   WHERE pbg.business_group_id = c_bg;
--
BEGIN
  --
  OPEN csr_bg(p_bg);
  FETCH csr_bg into l_currency;
  IF csr_bg%NOTFOUND THEN
     CLOSE csr_bg;
     -- No BG currency, so error
     -- fnd_message.set_name('PER','PER_52702_EFC_BG_CURR_IS_NULL');
     -- fnd_message.raise_error;
     -- Changed to raise an exception instead
     RAISE currency_null;
  END IF;
  CLOSE csr_bg;
  --
  -- Return currency
  RETURN l_currency;
END get_bg_currency;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< process_table >-------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION process_table(p_bg NUMBER) RETURN VARCHAR2 IS
--
l_currency VARCHAR2(150);
l_valid    VARCHAR2(1) := 'N';
l_proc      varchar2(72) := g_package || 'process_table';
--
BEGIN
  --
  l_currency := get_bg_currency(p_bg);
  --
  -- IF hr_currency_pkg.efc_is_ncu_currency(l_currency) THEN
  --    l_valid := 'Y';
  -- END IF;
  -- The above has been commented out, to allow processing for business
  -- groups that are based on non-NCU currency codes.
  --
  IF (l_currency IS NULL) THEN
     -- Error will already have been raised if cannot find BG currency.
     -- fnd_message.set_name('PER','PER_52702_EFC_BG_CURR_IS_NULL');
     -- fnd_message.raise_error;
     null;
  ELSIF hr_currency_pkg.efc_is_ncu_currency(l_currency) THEN
     l_valid := 'Y';
  ELSE
     -- Currency is non-NCU currency (and may be 'EUR')
     l_valid := 'N';
  END IF;
  --
  --
  -- Return value
  RETURN l_valid;
END process_table;
--
-- ----------------------------------------------------------------------------
-- |-------------------< validate_currency_code >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION validate_currency_code
           (p_currency_code in VARCHAR2) RETURN varchar2 IS
--
BEGIN
  IF p_currency_code IS NULL THEN
     return(NULL);
  END IF;
  --
  IF ((p_currency_code <> g_last_currency_code) OR
      (g_last_currency_code IS NULL)) THEN
     -- Fetch return currency code
     IF hr_currency_pkg.efc_is_ncu_currency(p_currency_code) THEN
        g_return_currency_code := 'EUR';
     ELSE
        g_return_currency_code := p_currency_code;
     END IF;
     g_last_currency_code := p_currency_code;
  END IF;
  --
  -- Return currency_code
  RETURN g_return_currency_code;
END validate_currency_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------< convert_aei_information >--------------------------|
-- ----------------------------------------------------------------------------
FUNCTION convert_aei_information
  (p_value    varchar2
  ,p_currency varchar2
  ,p_bg       number) RETURN varchar2 IS
--
  l_return  varchar2(100);
--
BEGIN
  --
  IF p_value IS NULL THEN
     l_return := NULL;
  ELSE
     IF p_currency IS NULL THEN
        -- Use bg's currency
        l_return := hr_currency_pkg.efc_convert_varchar2_amount
                      (hr_efc_info.get_bg_currency(p_bg)
                      ,p_value);
     ELSE
        l_return := hr_currency_pkg.efc_convert_varchar2_amount
                      (p_currency
                      ,p_value);
     END IF;
  END IF;
  --
  -- Return value
  RETURN l_return;
END convert_aei_information;
--
-- ----------------------------------------------------------------------------
-- |---------------------< convert_abs_information >--------------------------|
-- ----------------------------------------------------------------------------
FUNCTION convert_abs_information
  (p_value    varchar2
  ,p_currency varchar2
  ,p_bg       number) RETURN varchar2 IS
--
  l_return  varchar2(100);
--
BEGIN
  --
  IF p_value IS NULL THEN
     l_return := NULL;
  ELSE
     IF p_currency IS NULL THEN
        -- Use bg's currency
        l_return := hr_currency_pkg.efc_convert_varchar2_amount
                      (hr_efc_info.get_bg_currency(p_bg)
                      ,p_value);
     ELSE
        l_return := hr_currency_pkg.efc_convert_varchar2_amount
                      (p_currency
                      ,p_value);
     END IF;
  END IF;
  --
  -- Return value
  RETURN l_return;
END convert_abs_information;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_abs_currency >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_abs_currency(p_currency IN varchar2
                           ,p_bg       IN number) RETURN varchar2 IS
--
BEGIN
  --
  IF (p_currency IS NULL) THEN
     RETURN hr_efc_info.get_bg_currency(p_bg);
  ELSE
     RETURN p_currency;
  END IF;
END check_abs_currency;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_aei_currency >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_aei_currency(p_currency IN varchar2
                           ,p_bg       IN number) RETURN varchar2 IS
--
BEGIN
  --
  IF (p_currency IS NULL) THEN
     RETURN hr_efc_info.get_bg_currency(p_bg);
  ELSE
     RETURN p_currency;
  END IF;
END check_aei_currency;
--
-- ----------------------------------------------------------------------------
-- |------------------------< convert_num_value >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION convert_num_value
  (p_value IN VARCHAR2
  ,p_bg    IN NUMBER
  ,p_context1 IN VARCHAR2
  ,p_context2 IN VARCHAR2) RETURN varchar2 IS
--
  l_return  VARCHAR2(100);
--
BEGIN
  --
  IF p_value IS NULL THEN
     -- Return NULL
     l_return := NULL;
  ELSE
     -- Check whether or not we want to convert
     IF hr_efc_info.validate_hr_summary
          (p_context1,p_context2,p_bg) = 'Y' THEN
        -- Convert according to BG's currency
        l_return := hr_currency_pkg.efc_convert_varchar2_amount
                      (hr_efc_info.get_bg_currency(p_bg)
                      ,p_value);
     ELSE
        -- We dont want to convert, return original value
        l_return := p_value;
     END IF;
  END IF;
  --
  -- Return value
  RETURN l_return;
END convert_num_value;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_num_currency >---------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_num_currency(p_bg IN NUMBER) RETURN varchar2 IS
--
BEGIN
  RETURN hr_efc_info.get_bg_currency(p_bg);
END check_num_currency;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< convert_ppy_value >---------------------------|
-- ----------------------------------------------------------------------------
FUNCTION convert_ppy_value
  (p_value    IN number
  ,p_currency IN varchar2) RETURN number IS
--
  l_return NUMBER;
--
BEGIN
  --
  IF p_value IS NULL THEN
     l_return := NULL;
  ELSE
     IF hr_currency_pkg.efc_is_ncu_currency(p_currency) THEN
        l_return := hr_currency_pkg.efc_convert_number_amount
                      (p_currency
                      ,p_value);
     ELSE
       -- return value unchanged.
       l_return := p_value;
     END IF;
  END IF;
  --
  -- Return value
  RETURN l_return;
  --
END convert_ppy_value;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_ppy_currency >----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_ppy_currency(p_currency IN varchar2) RETURN varchar2 IS
--
BEGIN
  RETURN p_currency;
END check_ppy_currency;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< validate_total_workers >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE validate_total_workers(p_action_id      IN number
                                ,p_component_name IN varchar2
                                ,p_sub_step       IN number
                                ,p_total_workers  IN number
                                ,p_step           IN varchar2 default 'C_UPDATE'
                                ) IS
--
-- Cursor to find no. of workers
  CURSOR csr_check_workers(c_action_id IN number
                          ,c_component_name IN varchar2) IS
    SELECT epc.total_workers
      FROM hr_efc_process_components epc
     WHERE epc.efc_action_id = c_action_id
       AND epc.process_component_name = c_component_name;
--
-- Cursor to find sub phases
  CURSOR csr_check_phases(c_action_id IN number
                         ,c_sub_step  IN number
                         ,c_step      IN varchar2
                         ) IS
    SELECT 'Y'
      FROM hr_efc_process_components epc
         , hr_efc_workers efw
     WHERE epc.efc_action_id = c_action_id
       AND epc.step = c_step
       AND epc.sub_step < c_sub_step
       AND efw.efc_process_component_id = epc.efc_process_component_id
       AND efw.worker_process_status = 'P';

--
-- Cursor to find no. of completed worrkers for a certain sub_step
  CURSOR csr_check_rows(c_action_id IN number
                       ,c_sub_step  IN number
                       ,c_step      IN varchar2) IS
   SELECT count(*)
     FROM hr_efc_process_components epc
        , hr_efc_workers efw
    WHERE epc.efc_action_id = c_action_id
      AND epc.step = c_step
      AND epc.sub_step = c_sub_step
      AND efw.efc_process_component_id = epc.efc_process_component_id
      AND efw.worker_process_status = 'C';
--
  l_total csr_check_workers%ROWTYPE;
  l_exists  varchar2(1);
  l_rows     number := 0;
  l_expected number := 0;
  l_phase   number;
--
BEGIN
  -- check step parameter
  IF ((p_step <> 'C_UPDATE') and (p_step <> 'C_RECAL')) THEN
     -- Incorrect parameter
     hr_utility.set_message(800,'PER_52703_EFC_INVALID_STEP');
     hr_utility.raise_error;
  END IF;
  --
  OPEN csr_check_workers(p_action_id, p_component_name);
  FETCH csr_check_workers INTO l_total;
  --
  IF ((csr_check_workers%FOUND) and
      (l_total.total_workers <> p_total_workers)) THEN
     -- Row exists, yet workers does not match - error
     CLOSE csr_check_workers;
     hr_utility.set_message(800,'PER_52713_EFC_INVALID_WORKERS');
     hr_utility.raise_error;
  END IF;
  -- Close cursor.
  CLOSE csr_check_workers;
  --
  -- Check whether we have the expected no. of complete workers for the
  -- previous sub_step.  If not, check if some workers are still processing.
  l_phase := p_sub_step - 10;
  OPEN csr_check_rows(p_action_id, l_phase, p_step);
  FETCH csr_check_rows INTO l_rows;
  CLOSE csr_check_rows;
  --
  IF (p_step = 'C_UPDATE') THEN

     -- Work out if we have expected number of rows
     IF p_sub_step = '20' THEN
        l_expected := g_update_step_10 * p_total_workers;
     ELSIF p_sub_step = '30' THEN
        l_expected := g_update_step_20 * p_total_workers;
     ELSIF p_sub_step = '40' THEN
        l_expected := g_update_step_30 * p_total_workers;
     ELSIF p_sub_step = '50' THEN
        l_expected := g_update_step_40 * p_total_workers;
     ELSE
        l_expected := 0;
     END IF;
  ELSE
    -- p_step = 'C_RECAL'
    IF p_sub_step = '20' THEN
        l_expected := g_recal_step_10 * p_total_workers;
     ELSIF p_sub_step = '30' THEN
        l_expected := g_recal_step_20 * p_total_workers;
     ELSIF p_sub_step = '40' THEN
        l_expected := g_recal_step_30 * p_total_workers;
     ELSIF p_sub_step = '50' THEN
        l_expected := g_recal_step_40 * p_total_workers;
     ELSE
        l_expected := 0;
     END IF;
  END IF;
  --
  IF (l_expected <> l_rows) THEN
     -- Check whether any sub-phases exist for this BG that are not complete
     OPEN csr_check_phases(p_action_id, p_sub_step,p_step);
     FETCH csr_check_phases INTO l_exists;
     IF csr_check_phases%FOUND THEN
        -- sub-phase exists, so error
        CLOSE csr_check_phases;
        hr_utility.set_message(800,'PER_52704_EFC_PHASE_RUNNING');
        hr_utility.raise_error;
     ELSE
        -- All rows are complete, perhaps worker entries missing?
        IF l_expected > l_rows THEN
           hr_utility.set_message(800,'PER_52714_EFC_HIST_ENTRIES_ERR');
           hr_utility.raise_error;
        ELSIF l_expected < l_rows THEN
           hr_utility.set_message(800,'PER_52705_EFC_INCOMPLETE_HIST');
           hr_utility.raise_error;
        ELSE
           -- Have number of rows expected, no error.
           null;
        END IF;
     END IF;
     -- Close cursor
     CLOSE csr_check_phases;
  END IF;
  --
END validate_total_workers;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_action_details >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_action_details(p_efc_action_id     OUT NOCOPY number
                            ,p_business_group_id OUT NOCOPY number
                            ,p_get_chunk         OUT NOCOPY number
                            ) IS
--
  CURSOR csr_fetch_details IS
    SELECT act.efc_action_id
         , act.business_group_id
      FROM hr_efc_actions act
     WHERE act.efc_action_status = 'P'
       AND act.efc_action_type = 'C';
--
BEGIN
  --
  -- Fetch details from table.
  OPEN csr_fetch_details;
  FETCH csr_fetch_details INTO p_efc_action_id, p_business_group_id;
  IF csr_fetch_details%ROWCOUNT > 1 THEN
     -- error, more than one action being processed
     CLOSE csr_fetch_details;
     hr_utility.set_message(800,'PER_52715_EFC_MULTIPLE_ACTIONS');
     hr_utility.raise_error;
  ELSIF csr_fetch_details%NOTFOUND THEN
     -- error, no action tro process
     CLOSE csr_fetch_details;
     hr_utility.set_message(800,'PER_52721_EFC_NO_CURRNT_ACTION');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_fetch_details;
  --
  -- Get chunk size
  p_get_chunk := hr_efc_info.get_chunk;
  --
END get_action_details;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_line >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Adds the line to the actual database table.
--
-- ----------------------------------------------------------------------------
PROCEDURE insert_line(p_line VARCHAR2
                     ,p_line_num NUMBER default null) IS

  l_line_num number;

BEGIN
  --
  l_line_num := p_line_num;
  --
  IF l_line_num IS NULL THEN
    l_line_num := g_efc_message_line;
    g_efc_message_line := g_efc_message_line +1;
  END IF;

  INSERT INTO hr_api_user_hook_reports
    (session_id,
     line,
     text)
  VALUES
    (userenv('SESSIONID'),
     l_line_num,
     p_line);
  --
END insert_line;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< add_output >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_output(p_param1 IN     VARCHAR2
                    ,p_param2 IN     VARCHAR2
                    ,p_param3 IN     VARCHAR2
                    ,p_param4 IN     VARCHAR2
                    ,p_line   IN OUT NOCOPY NUMBER) IS
  --
  l_line varchar2(80);
  --
BEGIN
  --
  l_line := rpad(p_param1,20)  || ' ' ||
            rpad(p_param2,20)  || ' ' ||
            rpad(p_param3,20)  || ' ' ||
            rpad(p_param4,5);
  --
  insert_line(l_line, p_line);
  --
  p_line := p_line + 1;
  --
END add_output;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< add_header >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_header(p_line IN OUT NOCOPY NUMBER) IS
--
  l_line varchar2(80);
  l_line_num number;
  l_bg   number(15);
  l_bg_name varchar2(30);
  --
  CURSOR csr_bg_name(p_bg IN NUMBER) IS
    SELECT pbg.name
      FROM per_business_groups pbg
     WHERE pbg.business_group_id = p_bg;
--
BEGIN
  --
  l_bg := hr_efc_info.get_bg;
  open csr_bg_name(l_bg);
  fetch csr_bg_name into l_bg_name;
  close csr_bg_name;
  --
  l_line_num := p_line;
  --
  l_line := 'Business Group: ' || to_char(l_bg);
  insert_line(l_line,l_line_num);
  l_line_num := l_line_num + 1;
  --
  l_line := 'Business Group Name: '||l_bg_name;
  insert_line(l_line,l_line_num);
  l_line_num := l_line_num + 1;
  --
  l_line := rpad(' ',80);
  insert_line(l_line, l_line_num);
  l_line_num := l_line_num + 1;
  --
  l_line := rpad('RATE NAME',20) || ' ' ||
            rpad('SALARY BASIS NAME',20) || ' ' ||
            rpad('ELEMENT TYPE NAME',20) || ' ' ||
            rpad('CURR',5);
  insert_line(l_line, l_line_num);
  l_line_num := l_line_num + 1;
  --
  l_line := '----------------------------------------------------------------------';
  insert_line(l_line, l_line_num);
  l_line_num := l_line_num + 1;
  --
  p_line := l_line_num;
END add_header;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_hr_summary >--------------------------|
-- ----------------------------------------------------------------------------
FUNCTION validate_hr_summary(p_colname           VARCHAR2
                            ,p_item              VARCHAR2
                            ,p_business_group_id NUMBER) RETURN VARCHAR2 IS
  --
  l_process varchar2(1) := 'N';
  --
BEGIN
  --
  IF (p_colname = 'NUM_VALUE1') THEN
        --
        -- Oracle defined lookups
        -- Bilan social data
     IF    p_item = 'ANNUAL_REMUNERATION'
        OR p_item = 'MONTHLY_REMUNERATION'
        OR p_item = 'DECEMBER_REMUNERATION'
        OR p_item = 'ANNUAL_NON_MONTHLY_BONUSES'
        OR p_item = '10_HIGHEST_REMUNERATION'
        OR p_item = '10_PC_HIGHEST_REMUNERATION'
        OR p_item = '10_PC_LOWEST_REMUNERATION'
        OR p_item = 'OUTPUT_BASED_REMUNERATION'
        OR p_item = 'TIME_BASED_REMUNERATION'
        OR p_item = 'EMPLOYER_COST'
        --
        -- 2483 data
        OR p_item = 'INTERNAL_EVENT_COSTS'
        OR p_item = 'SKILLS_ASSESSMENT_COSTS'
        OR p_item = 'TRAINING_COSTS_EXCL_REP'
        OR p_item = 'TRAINING_PLAN_COST'
        --
        -- Add other Oracle defined Lookups
                                                THEN
        l_process := 'Y';
     ELSE
        -- Lookup may be user_defined
        l_process := hr_efc_stubs.cust_validate_hr_summary
                        (p_colname           => p_colname
                        ,p_item              => p_item
                        ,p_business_group_id => p_business_group_id);
     END IF;
  ELSIF (p_colname = 'NUM_VALUE2') THEN
     --
     -- Check Oracle Defined Lookups (as above)
     -- None.
     --
     -- Check User defined lookups
     l_process := hr_efc_stubs.cust_validate_hr_summary
                     (p_colname           => p_colname
                     ,p_item              => p_item
                     ,p_business_group_id => p_business_group_id);
  END IF;
  --
  -- Return value.
  RETURN l_process;
  --
END validate_hr_summary;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< find_payment_map >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure takes a payment_name, and a territory_code, and using these
--  will determine the new payment_type_id for the payment_type which maps on
--  to the original payment_type.
--
-- Post Success:
--  The procedure returns, as an out parameter, the payment_type_id of the
--  new payment type.
--
-- Post Failure:
--  The procedure returns, as an out parameter, a value of NULL for the new
--  payment type.
--
-- ----------------------------------------------------------------------------
PROCEDURE find_payment_map(p_payment_type    IN     VARCHAR2
                          ,p_territory_code  IN     VARCHAR2
                          ,p_category        IN     VARCHAR2
                          ,p_payment_type_id    OUT NOCOPY NUMBER) IS
--
  l_payment_type   varchar2(80);
  l_territory_code varchar2(2);
  l_category       varchar2(2);
  l_to_currency    varchar2(3);
  l_changed_id      boolean := true;
  l_vc_const        constant varchar2(9) := '$sysdef$';
  --
  -- Cursor to check if mapping exists
  CURSOR csr_check_map_exists(c_payment_type IN VARCHAR2
                             ,c_territory_code IN VARCHAR2) IS
    SELECT ppt.payment_type_id
         , ppt.category
         , ppt.currency_code
      FROM pay_payment_types ppt
     WHERE ppt.payment_type_name = c_payment_type
       AND ppt.territory_code = c_territory_code;
  --
  CURSOR csr_check_map_exists_null(c_payment_type IN VARCHAR2) IS
    SELECT ppt.payment_type_id
         , ppt.category
         , ppt.currency_code
      FROM pay_payment_types ppt
     WHERE ppt.payment_type_name = c_payment_type
       AND ppt.territory_code IS NULL;
  --
--
BEGIN
  --
  --
  IF ((p_payment_type='FR Cash') AND
       (p_territory_code='FR')) THEN
      l_payment_type := 'Cash';
      l_territory_code := NULL;
  ELSIF ((p_payment_type = 'FR Cheque') AND
         (p_territory_code = 'FR')) THEN
      l_payment_type := 'Cheque';
      l_territory_code := NULL;
  ELSIF ((p_payment_type = 'FR Magnetic Tape') AND
         (p_territory_code = 'FR')) THEN
      l_payment_type := 'FR Magnetic Tape - EUR';
      l_territory_code := 'FR';
  ELSIF ((p_payment_type = 'Cheque - ITL') AND
         (p_territory_code = 'IT')) THEN
      l_payment_type := 'Cheque';
      l_territory_code := NULL;
  ELSIF ((p_payment_type = 'Direct Deposit - ITL') AND
         (p_territory_code = 'IT')) THEN
      l_payment_type := 'Direct Deposit - EUR';
      l_territory_code := 'IT';
  ELSIF ((p_payment_type = 'Cheque') AND
         (p_territory_code = 'BE')) THEN
      l_payment_type := 'Cheque';
      l_territory_code := NULL;
  ELSIF ((p_payment_type = 'Direct Deposit') AND
         (p_territory_code = 'BE')) THEN
      l_payment_type := 'Direct Deposit - EUR';
      l_territory_code := 'BE';
  ELSIF ((p_payment_type = 'Cash') AND
         (p_territory_code IS NULL)) THEN
      l_payment_type := 'Cash';
      l_territory_code := NULL;
  ELSIF ((p_payment_type = 'Cheque') AND
         (p_territory_code IS NULL)) THEN
      l_payment_type := 'Cheque';
      l_territory_code := NULL;
  ELSE -- Deal with customer mappings
     hr_efc_stubs.chk_customer_mapping
       (p_payment_type       => p_payment_type
       ,p_territory_code     => p_territory_code
       ,p_new_payment_type   => l_payment_type
       ,p_new_territory_code => l_territory_code
       );
     IF ((nvl(l_payment_type, l_vc_const)
          = nvl(p_payment_type, l_vc_const)) AND
         (nvl(l_territory_code, l_vc_const)
          = nvl(p_territory_code, l_vc_const))) THEN
        l_changed_id := FALSE;
     END IF;
  END IF;
  --
  IF (l_changed_id) THEN
     -- Check mapping exists
     IF l_territory_code IS NOT NULL THEN
        OPEN csr_check_map_exists(l_payment_type, l_territory_code);
        --
        FETCH csr_check_map_exists INTO p_payment_type_id
                                      , l_category
                                      , l_to_currency;
        IF csr_check_map_exists%NOTFOUND THEN
           p_payment_type_id := NULL;
        --
        -- Otherwise, id has been inserted into p_payment_type_id.
        END IF;
        --
        CLOSE csr_check_map_exists;
        --
     ELSE
        --
        OPEN csr_check_map_exists_null(l_payment_type);
        --
        FETCH csr_check_map_exists_null INTO p_payment_type_id
                                           , l_category
                                           , l_to_currency;
        IF csr_check_map_exists_null%NOTFOUND THEN
           p_payment_type_id := NULL;
        --
        -- Otherwise, id has been inserted into p_payment_type_id.
        END IF;
        --
        CLOSE csr_check_map_exists_null;
        --
     END IF;
     IF (nvl(l_category, l_vc_const) <>
        nvl(p_category, l_vc_const)) THEN
        -- Invalid mapping, set payment_type_id to null
        p_payment_type_id := NULL;
     END IF;
     --
     IF ((l_to_currency IS NOT NULL) AND (l_to_currency <> 'EUR')) THEN
        -- Invalid mapping, set payment_type_id to null
        p_payment_type_id := NULL;
     END IF;
  ELSE
     -- payment_type_id has not changed - return null
     p_payment_type_id := NULL;
  END IF;
END find_payment_map;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_mapping_exists >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION chk_mapping_exists(p_payment_type_id IN number) RETURN varchar2 IS
  --
  l_payment_type_name VARCHAR2(80);
  l_territory_code    VARCHAR2(2);
  l_payment_type_id   NUMBER;
  l_category          VARCHAR2(2);
  --
BEGIN
  --
  -- Find payment_type_name, territory_code
  open csr_fetch_payment_types(p_payment_type_id);
  --
  FETCH csr_fetch_payment_types INTO l_payment_type_name,
                                     l_territory_code,
                                     l_category;
  --
  IF csr_fetch_payment_types%NOTFOUND THEN
     CLOSE csr_fetch_payment_types;
     RETURN('N');
  ELSE
     CLOSE csr_fetch_payment_types;
     -- Call procedure to return payment_type_id for mapped payment type
     find_payment_map(p_payment_type    => l_payment_type_name
                     ,p_territory_code  => l_territory_code
                     ,p_category        => l_category
                     ,p_payment_type_id => l_payment_type_id);
     --
     IF l_payment_type_id IS NULL THEN
        RETURN('N');
     ELSE
        RETURN('Y');
     END IF;
  END IF;
  --
END chk_mapping_exists;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_map_id >--------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION find_map_id(p_payment_type_id IN number) RETURN number IS
  --
  l_payment_type_name VARCHAR2(80);
  l_territory_code    VARCHAR2(2);
  l_payment_type_id   NUMBER;
  l_category          VARCHAR2(2);
  --
--
BEGIN
  --
  -- Find payment_type_name, territory_code
  OPEN csr_fetch_payment_types(p_payment_type_id);
  --
  FETCH csr_fetch_payment_types INTO l_payment_type_name
                                   , l_territory_code
                                   , l_category;
  --
  IF csr_fetch_payment_types%NOTFOUND THEN
     l_payment_type_id := NULL;
  ELSE
     -- Call procedure to return payment_type_id for mapped payment type
     find_payment_map(p_payment_type    => l_payment_type_name
                     ,p_territory_code  => l_territory_code
                     ,p_category        => l_category
                     ,p_payment_type_id => l_payment_type_id);
  END IF;
  CLOSE csr_fetch_payment_types;
  --
  IF l_payment_type_id IS NULL THEN
     hr_utility.set_message(800,'PER_52716_EFC_NO_PAYMENT_MAP');
     hr_utility.raise_error;
  END IF;
  --
  -- Return value
  RETURN l_payment_type_id;
  --
END find_map_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_opm_currency >---------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_opm_currency(p_currency IN varchar2) RETURN varchar2 IS
BEGIN
  RETURN p_currency;
END check_opm_currency;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_pra_currency >---------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_pra_currency(p_currency IN varchar2) RETURN varchar2 IS
BEGIN
  RETURN p_currency;
END check_pra_currency;
--
-- ----------------------------------------------------------------------------
-- |--------------------< insert_or_select_comp_row >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_or_select_comp_row
  (p_action_id                IN     number
  ,p_process_component_name   IN     varchar2
  ,p_table_name               IN     varchar2
  ,p_total_workers            IN     number
  ,p_worker_id                IN     number
  ,p_step                     IN     varchar2
  ,p_sub_step                 IN     number
  ,p_process_component_id        OUT NOCOPY number) IS
--
  l_lockhandle  varchar2(128);
  l_lock_result number;
  l_exists      varchar2(1);
  --
  -- Cursor to fetch existing component_id
  --
  CURSOR csr_fetch_comp_id(c_action_id              IN number
                          ,c_process_component_name IN varchar2) IS
    SELECT epc.efc_process_component_id
      FROM hr_efc_process_components epc
     WHERE epc.efc_action_id = c_action_id
       AND epc.process_component_name = c_process_component_name;
  --
BEGIN
  -- Get lock handle for EFC lock
  dbms_lock.allocate_unique(lockname   => 'HR_EFC_PROCESS_COMPONENTS'
                           ,lockhandle => l_lockhandle);
  --
  LOOP
    -- Attempt to take lock
    l_lock_result := dbms_lock.request(lockhandle        => l_lockhandle
                                      ,lockmode          => dbms_lock.x_mode
                                      ,timeout           => dbms_lock.maxwait
                                      ,release_on_commit => TRUE
                                      );
    IF ((l_lock_result = 0) OR (l_lock_result = 4)) THEN
       -- Have lock, exit loop
       EXIT;
    ELSIF ((l_lock_result =1) OR (l_lock_result = 2)) THEN
       -- Lock timed out, or deadlock
       dbms_lock.sleep(p_worker_id);
    ELSE
       -- Parameter error or illegal lock handle, so error
       hr_utility.set_message(800,'PER_52717_EFC_PROC_LOCK_ERR');
       hr_utility.raise_error;
    END IF;
  END LOOP;
  --
  -- Have lock, so determine if row exists
  OPEN csr_fetch_comp_id(p_action_id, p_process_component_name);
  FETCH csr_fetch_comp_id INTO p_process_component_id;
  IF csr_fetch_comp_id%NOTFOUND THEN
     -- row does not exist, so insert row into process components table.
     --
     INSERT INTO hr_efc_process_components
       (efc_process_component_id
       ,efc_action_id
       ,process_component_name
       ,table_name
       ,total_workers
       ,step
       ,sub_step
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,created_by
       ,creation_date)
     VALUES
       (hr_efc_process_components_s.nextval
       ,p_action_id
       ,p_process_component_name
       ,p_table_name
       ,p_total_workers
       ,p_step
       ,p_sub_step
       ,sysdate
       ,-1
       ,-1
       ,-1
       ,sysdate)
     RETURNING efc_process_component_id INTO p_process_component_id;
  END IF;
  CLOSE csr_fetch_comp_id;
  --
  -- Commit row, and release lock
  COMMIT;
  --
  --
END insert_or_select_comp_row;
--
-- ----------------------------------------------------------------------------
-- |-------------------< insert_or_select_worker_row >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_or_select_worker_row
  (p_efc_worker_id              OUT NOCOPY number
  ,p_status                  IN OUT NOCOPY varchar2
  ,p_process_component_id    IN     number
  ,p_process_component_name  IN     varchar2
  ,p_action_id               IN     number
  ,p_worker_number           IN     number
  ,p_pk1                     IN OUT NOCOPY number
  ,p_pk2                     IN OUT NOCOPY varchar2
  ,p_pk3                     IN OUT NOCOPY varchar2
  ,p_pk4                     IN OUT NOCOPY varchar2
  ,p_pk5                     IN OUT NOCOPY varchar2
  ) IS
--
-- Cursor to check restart
CURSOR csr_restart(c_action_id IN number
                  ,c_worker_id IN number
                  ,c_component IN varchar2) IS
  SELECT ewo.efc_worker_id
       , ewo.worker_process_status
       , ewo.pk1
       , ewo.pk2
       , ewo.pk3
       , ewo.pk4
       , ewo.pk5
    FROM hr_efc_process_components epc
       , hr_efc_workers ewo
   WHERE epc.efc_action_id = c_action_id
     AND epc.process_component_name = c_component
     AND epc.efc_process_component_id = ewo.efc_process_component_id
     AND ewo.worker_number = c_worker_id;
--
-- Cursor to determine SPID value
CURSOR csr_fetch_spid IS
  SELECT p.spid
    FROM v$session s
       , v$process p
   WHERE s.audsid = userenv('SESSIONID')
     AND p.addr = s.paddr;
--
l_restart csr_restart%ROWTYPE;
l_pk1        number := 0;
l_spid       varchar2(9);
--
BEGIN
  --
  IF nvl(p_status,'P') <> 'C' THEN
     p_status := 'P';
  END IF;
  --
  -- See if there is a restart row
  OPEN csr_restart(p_action_id, p_worker_number, p_process_component_name);
  FETCH csr_restart INTO l_restart;
  IF csr_restart%NOTFOUND THEN
     -- No row in worker table, so create a row.
     l_spid := NULL;
     -- always log the SPID, note that this does not mean
     -- that sql_trace was enabled
     -- find spid
     OPEN csr_fetch_spid;
     FETCH csr_fetch_spid INTO l_spid;
     CLOSE csr_fetch_spid;
     --
     INSERT INTO hr_efc_workers
       (efc_worker_id
       ,efc_process_component_id
       ,efc_action_id
       ,worker_number
       ,worker_process_status
       ,pk1
       ,pk2
       ,pk3
       ,pk4
       ,pk5
       ,spid
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,created_by
       ,creation_date
       )
     VALUES
       (hr_efc_workers_s.nextval
       ,p_process_component_id
       ,p_action_id
       ,p_worker_number
       ,p_status
       ,l_pk1
       ,p_pk2
       ,p_pk3
       ,p_pk4
       ,p_pk5
       ,l_spid
       ,sysdate
       ,-1
       ,-1
       ,-1
       ,sysdate
       )
     RETURNING efc_worker_id INTO p_efc_worker_id;
     COMMIT;
     --
     -- Set return values
     p_pk1 := l_pk1;
  ELSE
     -- Row exists in HR_EFC_WORKERS table already, so set return values
     -- and also update SPID
     IF l_restart.worker_process_status = 'P' THEN
        -- Check if SQL_TRACE is on
        l_spid := NULL;
        -- always log the SPID, note that this does not mean
        -- that sql_trace was enabled
        OPEN csr_fetch_spid;
        FETCH csr_fetch_spid INTO l_spid;
        CLOSE csr_fetch_spid;
        --
        IF l_spid IS NOT NULL THEN
           -- update worker row
           UPDATE hr_efc_workers
              SET spid = l_spid
            WHERE efc_worker_id = l_restart.efc_worker_id;
        END IF;
     END IF;
     p_efc_worker_id := l_restart.efc_worker_id;
     p_status := l_restart.worker_process_status;
     p_pk1 := l_restart.pk1;
     p_pk2 := l_restart.pk2;
     p_pk3 := l_restart.pk3;
     p_pk4 := l_restart.pk4;
     p_pk5 := l_restart.pk5;
     --
  END IF;
  CLOSE csr_restart;
  --
  -- We now definitely have a row in HR_EFC_WORKERS table
  --
END insert_or_select_worker_row;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< add_audit_row >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_audit_row (p_worker_id IN number
                        ,p_column_name IN varchar2
                        ,p_old_value IN varchar2
                        ,p_new_value IN varchar2
                        ,p_count     IN OUT NOCOPY number
                        ,p_currency  IN varchar2
                        ,p_last_curr IN OUT NOCOPY varchar2
                        ,p_commit    IN OUT NOCOPY boolean) IS
--
-- Cursor to select old values (if any) from audit table
--
  CURSOR csr_find_row(c_worker_id IN number, c_column_name IN varchar2,
                      c_currency IN varchar2) IS
    SELECT ewa.efc_worker_audit_id
         , ewa.number_of_rows
      FROM hr_efc_worker_audits ewa
     WHERE ewa.efc_worker_id = c_worker_id
       AND ewa.column_name = c_column_name
       AND ewa.currency_code = c_currency;
--
-- Cursor to fetch a unique id
  CURSOR csr_get_id IS
    SELECT hr_efc_worker_audits_s.nextval
      FROM dual;
--
  l_audit_id number;
  l_rows     number;
--
BEGIN
  -- Check if value has actually changed
  -- When the new and old values are different
  -- we can easily detect a conversion has occurred.
  -- If the new and old values are both zero
  -- then we also need to check if old currency
  -- is NCU. This will tell us the "meaning" of the
  -- zero has been converted to Euro.
  -- Null values which remain null values should not
  -- be counted.
  IF ((nvl(p_old_value,hr_api.g_varchar2) <>
       nvl(p_new_value,hr_api.g_varchar2)) OR
     (p_old_value = '0' AND p_new_value = '0'
      AND hr_currency_pkg.efc_is_ncu_currency(p_currency))) THEN
     -- Value has changed - check if we need to add/update a row
     IF ((p_currency = p_last_curr) OR (p_last_curr IS NULL)) THEN
        -- Increment count and return
        p_count := p_count + 1;
        p_last_curr := p_currency;
     ELSE
       -- Currency has changed, so flush contents to audit table
       OPEN csr_find_row(p_worker_id, p_column_name, p_last_curr);
       FETCH csr_find_row INTO l_audit_id, l_rows;
       IF csr_find_row%NOTFOUND THEN
          -- No current row in audit table, so add one
          CLOSE csr_find_row;
          --
          -- Insert row into audit table
          INSERT INTO hr_efc_worker_audits
           (efc_worker_audit_id
           ,efc_worker_id
           ,column_name
           ,currency_code
           ,number_of_rows
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,created_by
           ,creation_date
           )
          VALUES
           (hr_efc_worker_audits_s.nextval
           ,p_worker_id
           ,p_column_name
           ,p_last_curr
           ,p_count
           ,sysdate
           ,-1
           ,-1
           ,-1
           ,sysdate
           );
       ELSE
         CLOSE csr_find_row;
         -- Update row in Audit table
         UPDATE hr_efc_worker_audits
            SET number_of_rows = l_rows + p_count
          WHERE efc_worker_audit_id = l_audit_id;
       END IF;
       -- Changes made to audit table, so indicate this, and reset variables
       p_commit := TRUE;
       p_count := 1;
       p_last_curr := p_currency;
     END IF;
  END IF;
  --
END add_audit_row;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< flush_audit_details >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE flush_audit_details
  (p_efc_worker_id IN     number
  ,p_count         IN OUT NOCOPY number
  ,p_last_curr     IN OUT NOCOPY varchar2
  ,p_col_name      IN     varchar2
  ) IS
--
-- Cursor to check if row exists
  CURSOR csr_find_row(c_worker_id IN number, c_column_name IN varchar2,
                      c_currency IN varchar2) IS
    SELECT ewa.efc_worker_audit_id
         , ewa.number_of_rows
      FROM hr_efc_worker_audits ewa
     WHERE ewa.efc_worker_id = c_worker_id
       AND ewa.column_name = c_column_name
       AND ewa.currency_code = c_currency;
--
  l_audit_id number;
  l_rows     number;
--
BEGIN
  --
  -- Only flush if we have to (ie. count is > 0)
  IF p_count > 0 THEN
     OPEN csr_find_row(p_efc_worker_id, p_col_name, p_last_curr);
     FETCH csr_find_row INTO l_audit_id, l_rows;
     IF csr_find_row%NOTFOUND THEN
        -- No current row in audit table, so add one
        CLOSE csr_find_row;
        --
        -- Insert row into audit table
        INSERT INTO hr_efc_worker_audits
         (efc_worker_audit_id
         ,efc_worker_id
         ,column_name
         ,currency_code
         ,number_of_rows
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,created_by
         ,creation_date
         )
        VALUES
         (hr_efc_worker_audits_s.nextval
         ,p_efc_worker_id
         ,p_col_name
         ,p_last_curr
         ,p_count
         ,sysdate
         ,-1
         ,-1
         ,-1
         ,sysdate
         );
     ELSE
       CLOSE csr_find_row;
       -- Update row in Audit table
       UPDATE hr_efc_worker_audits
          SET number_of_rows = l_rows + p_count
        WHERE efc_worker_audit_id = l_audit_id;
     END IF;
     -- Changes made to audit table, so indicate this, and reset variables
     p_count := 0;
     p_last_curr := '';
     --
  END IF;
END flush_audit_details;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_worker_row >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_worker_row(p_efc_worker_id IN number
                           ,p_pk1           IN number
                           ,p_pk2           IN varchar2
                           ,p_pk3           IN varchar2
                           ,p_pk4           IN varchar2
                           ,p_pk5           IN varchar2
                           ) IS
BEGIN
  --
  -- Update the worker row
  UPDATE hr_efc_workers
  SET pk1 = p_pk1
    , pk2 = p_pk2
    , pk3 = p_pk3
    , pk4 = p_pk4
    , pk5 = p_pk5
  WHERE efc_worker_id = p_efc_worker_id;
  --
END update_worker_row;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< complete_worker_row >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE complete_worker_row(p_efc_worker_id IN number
                             ,p_pk1           IN number
                             ,p_pk2           IN varchar2
                             ,p_pk3           IN varchar2
                             ,p_pk4           IN varchar2
                             ,p_pk5           IN varchar2
                             ) IS
BEGIN
  --
  UPDATE hr_efc_workers
    SET pk1 = p_pk1
      , pk2 = p_pk2
      , pk3 = p_pk3
      , pk4 = p_pk4
      , pk5 = p_pk5
      , worker_process_status = 'C'
  WHERE efc_worker_id = p_efc_worker_id;
  --
END complete_worker_row;
--
-- ----------------------------------------------------------------------------
-- |------------------------< valid_budget_unit >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION valid_budget_unit(p_uom               IN VARCHAR2
                          ,p_business_group_id IN NUMBER) RETURN VARCHAR2 IS
--
lc_process varchar2(1) := 'N';
--
BEGIN
  --
  -- example shown, remove if not required
  IF p_uom = 'MONEY' THEN
     lc_process := 'Y';
  -- ELSIF -- Code other allowed types here
  ELSE
     -- Check for customer specific units
     lc_process := hr_efc_stubs.cust_valid_budget_unit(p_uom
                                                      ,p_business_group_id);
  END IF;
  --
  RETURN lc_process;
  --
END valid_budget_unit;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_action_history >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_action_history IS
--
l_del_tab_sql varchar2(2000) :=
'BEGIN
  LOOP
    DELETE FROM <TABLE> efc
    WHERE efc.efc_action_id = <ID>
      AND ROWNUM < <CHUNK>;
    COMMIT;
    EXIT WHEN SQL%NOTFOUND;
  END LOOP;
 END;';
--
-- Cursor to determine efc_action_id
CURSOR csr_get_action IS
  SELECT act.matching_efc_action_id
    FROM hr_efc_actions act
   WHERE act.efc_action_type = 'D'
     AND act.efc_action_status = 'P';
--
-- Cursor to find _efc tables
CURSOR csr_get_efc_tables IS
 SELECT distinct tab.table_name
   FROM all_tables tab
      , all_tab_columns col
      , user_synonyms syn
  WHERE ((tab.table_name like '%_EFC'
    AND tab.table_name <> 'PAY_BALANCE_TYPES_EFC'
    AND tab.table_name <> 'PAY_ORG_PAYMENT_METHODS_F_EFC'
    AND hr_general.hrms_object(tab.table_name) = 'TRUE')
     OR tab.table_name = 'HR_EFC_ROUNDING_ERRORS')
    AND col.table_name = tab.table_name
    AND col.column_name = 'EFC_ACTION_ID'
    AND tab.table_name = syn.synonym_name
    AND tab.owner = syn.table_owner
    AND col.owner = tab.owner;
--
l_action_id number;
l_cursor    integer;
l_return    integer;
l_sql       varchar2(2000);
l_chunk     number;
--
BEGIN
  --
  -- get efc_action_id for current delete action.
  OPEN csr_get_action;
  FETCH csr_get_action INTO l_action_id;
  IF csr_get_action%NOTFOUND THEN
     --
     CLOSE csr_get_action;
     hr_utility.set_message(800,'PER_52718_EFC_NO_DELETE_ACTION');
     hr_utility.raise_error;
     --
  END IF;
  CLOSE csr_get_action;
  --
  -- Get chunk size, so we process in chunks
  l_chunk := hr_efc_info.get_chunk;
  l_del_tab_sql := replace(l_del_tab_sql,'<CHUNK>',l_chunk);
  --
  -- For each _efc table, delete the appropriate rows
  FOR c1 IN csr_get_efc_tables LOOP
    --
    -- Replace tokens in SQL
    l_sql := replace(l_del_tab_sql,'<TABLE>',c1.table_name);
    l_sql := replace(l_sql,'<ID>',l_action_id);
    --
    -- Execute sql
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, l_sql, DBMS_SQL.v7);
    l_return := dbms_sql.execute(l_cursor);
    dbms_sql.close_cursor(l_cursor);
    --
  END LOOP;
  --
END delete_action_history;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_rounding_row >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_rounding_row
  (p_action_id                IN     number
  ,p_source_id                IN     number
  ,p_source_table             IN     varchar2
  ,p_source_column            IN     varchar2
  ,p_rounding_amount          IN     number) IS
--
  --
BEGIN
  --
  --
   INSERT INTO hr_efc_rounding_errors
       (efc_rounding_error_id
       ,efc_action_id
       ,source_id
       ,source_table
       ,source_column
       ,rounding_amount
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,created_by
       ,creation_date)
     VALUES
       (hr_efc_rounding_errors_s.nextval
       ,p_action_id
       ,p_source_id
       ,p_source_table
       ,p_source_column
       ,p_rounding_amount
       ,sysdate
       ,-1
       ,-1
       ,-1
       ,sysdate);
  --
  -- Commit row
  COMMIT;
  --
  --
END insert_rounding_row;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< find_row_size >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Determines the size of a row, for a given table, by looking at the column
--  definitions for that table in ALL_TAB_COLUMNS.
--  Criteria for estimation are:
--   - If the column is VARCHAR2, and a currency column, size is 3 bytes
--   - If the column is VARCHAR2, size is (length of column)/3 bytes.
--   - If the column type is NUMBER, size is (length of column)/2 bytes.
--
-- ----------------------------------------------------------------------------
FUNCTION find_row_size(p_table IN VARCHAR2) return NUMBER IS
--
-- Cursor to find table details
CURSOR csr_find_details(c_name IN varchar2) IS
  SELECT tab.column_name,
         tab.data_type,
         tab.data_length
    FROM all_tab_columns tab
    ,    user_synonyms syn
   WHERE tab.table_name = c_name
   AND   tab.table_name = syn.synonym_name
   AND   tab.owner = syn.table_owner;
--
  l_table varchar2(30);
  l_rowsize number := 0;
--
BEGIN
  --
  l_table := upper(p_table);
  -- Check if customer version returns a value
  l_rowsize := hr_efc_stubs.cust_find_row_size(l_table);
  IF l_rowsize = 0 THEN
     --
     -- Customer version returns nothing, so work from our version
     FOR c1 IN csr_find_details(l_table) LOOP
        IF instr(c1.column_name, 'CURRENCY') <> 0 THEN
           -- Currency column
           l_rowsize := l_rowsize + 3;
        ELSE
           IF c1.data_type = 'VARCHAR2' THEN
              l_rowsize := l_rowsize + (c1.data_length/3);
           ELSIF c1.data_type = 'NUMBER' THEN
              l_rowsize := l_rowsize + (c1.data_length/2);
           ELSE
              l_rowsize := l_rowsize + c1.data_length;
           END IF;
        END IF;
     END LOOP;
  END IF;
  --
  -- Return rowsize
  RETURN l_rowsize;
END find_row_size;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< clear_efc_report >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure is a cover for hr_api_user_hooks_utility.clear_hook_report.
--
-- ----------------------------------------------------------------------------
PROCEDURE clear_efc_report IS
--
BEGIN
--

-- clear table of messages
  hr_api_user_hooks_utility.clear_hook_report;

IF g_efc_error_message IS NOT NULL THEN
  hr_utility.set_message(g_efc_error_app,
                         g_efc_error_message);
  g_efc_error_message := null;
  hr_utility.raise_error;
END IF;

--
END clear_efc_report;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< process_cross_bg_data >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Determines if data spanning business groups will be converted.
--  This will can be overriden by the function cust_process_cross_bg_data.
--  By default, the data will be converted, unless overridden.
--
-- ----------------------------------------------------------------------------
FUNCTION process_cross_bg_data RETURN varchar2 IS
--
BEGIN
--
IF NVL(hr_efc_stubs.cust_process_cross_bg_data, 'Y') = 'N' THEN
  RETURN 'N';
ELSE
  RETURN 'Y';
END IF;
--
END process_cross_bg_data;
--
--
END hr_efc_info;

/
