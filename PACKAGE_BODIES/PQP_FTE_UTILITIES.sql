--------------------------------------------------------
--  DDL for Package Body PQP_FTE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_FTE_UTILITIES" AS
/* $Header: pqftepkg.pkb 120.4 2006/11/16 04:23:08 agolechh noship $ */
--
g_package_name                 VARCHAR2(31) := 'pqp_fte_utilities.';
g_debug                        BOOLEAN:=FALSE;
--
--
TYPE g_output_file_rec_type IS RECORD
  (assignment_id                  per_all_assignments_f.assignment_id%TYPE
  ,status                         VARCHAR2(80)
  ,employee_number                per_all_people_f.employee_number%TYPE
  ,assignment_number              per_all_assignments_f.assignment_number%TYPE
  ,effective_date                 per_all_assignments_f.effective_start_date%TYPE
  ,change_in                      VARCHAR2(80)
  ,FTE_old_value                  per_assignment_budget_values_f.value%TYPE
  ,change_type                    VARCHAR2(80)
  ,FTE_new_value                  per_assignment_budget_values_f.value%TYPE
  ,normal_hours                   per_all_assignments_f.normal_hours%TYPE
  ,frequency                      per_all_assignments_f.frequency%TYPE
  ,contract_type                  pqp_assignment_attributes_f.contract_type%TYPE
  ,annual_hours                   pay_user_column_instances_f.value%TYPE
  ,period_divisor                 pay_user_column_instances_f.value%TYPE
  ,message                        fnd_new_messages.message_text%TYPE
  );
TYPE t_output_file_record_type    IS TABLE OF g_output_file_rec_type
  INDEX BY BINARY_INTEGER;
g_output_file_records          t_output_file_record_type; -- do not include in clear cache
g_is_concurrent_program_run    BOOLEAN:= FALSE;
g_column_separator             VARCHAR2(10):=' , ';
--
--
-- cache for get_installation_status
g_application_id               fnd_product_installations.application_id%TYPE;
g_status                       fnd_product_installations.status%TYPE;

-- cache for load_cached_constants
g_pqp_contract_table_id        pay_user_tables.user_table_id%TYPE;
g_annual_hours_col_id          pay_user_columns.user_column_id%TYPE;
g_period_divisor_col_id        pay_user_columns.user_column_id%TYPE;
g_not_cached_constants         BOOLEAN:=TRUE;

-- cache for chk_fte_exists
g_fte_exists_assignment_id     per_all_assignments_f.assignment_id%TYPE;
g_fte_exists                   BOOLEAN;

-- cache for get_earliest_possible_date
g_epFd_assignment_id           per_all_assignments_f.assignment_id%TYPE;
g_epFd_earliest_possible_date  DATE;


--
--
--
CURSOR csr_fte_exists
  (p_assignment_id                NUMBER
  ) IS
SELECT 1
FROM   per_assignment_budget_values_f
WHERE  assignment_id = p_assignment_id
  AND  unit = 'FTE'
  AND  ROWNUM < 2;

CURSOR csr_effective_fte
  (p_assignment_id                NUMBER
  ,p_effective_date               DATE
  ) IS
SELECT assignment_budget_value_id,
       value,
       effective_start_date,
       effective_end_date,
       object_version_number
FROM   per_assignment_budget_values_f
WHERE  assignment_id = p_assignment_id
  AND  unit = 'FTE'
  AND  p_effective_date
         BETWEEN effective_start_date
             AND effective_end_date;

CURSOR csr_assignment_details
  (p_assignment_id                NUMBER
  ,p_effective_date               DATE
  ) IS
SELECT asg.business_group_id
      ,asg.normal_hours
      ,asg.frequency
FROM   per_all_assignments_f asg
WHERE  asg.assignment_id = p_assignment_id
AND    p_effective_date
         BETWEEN asg.effective_start_date
             AND asg.effective_end_date;

-- dummy cursor for record structure
CURSOR csr_contract_details IS
SELECT TO_NUMBER('0') annual_hours
      ,TO_NUMBER('0') period_divisor
      ,row_low_range_or_name contract_type
      ,user_row_id
FROM  pay_user_rows_f
WHERE user_row_id = 0;


CURSOR csr_assignment_contract
  (p_assignment_id                NUMBER
  ,p_effective_date               DATE
  ,p_pqp_contract_table_id        NUMBER
  ) IS
SELECT pur.user_row_id, aat.contract_type
FROM   pqp_assignment_attributes_f aat
      ,pay_user_rows_f             pur
WHERE  aat.assignment_id = p_assignment_id
  AND  p_effective_date
           BETWEEN aat.effective_start_date
               AND aat.effective_end_date
  AND  pur.user_table_id = p_pqp_contract_table_id
  AND  pur.business_group_id = aat.business_group_id
  AND  pur.row_low_range_or_name = aat.contract_type
  AND  aat.effective_start_date
         BETWEEN pur.effective_start_date
             AND pur.effective_end_date;


CURSOR csr_get_contract_value
  (p_contract_column_id           NUMBER
  ,p_contract_row_id              NUMBER
  ,p_effective_date               DATE
  ) IS
SELECT inst.value
FROM   pay_user_column_instances_f inst
WHERE  inst.user_column_id = p_contract_column_id
  AND  inst.user_row_id    = p_contract_row_id
  AND  p_effective_date
         BETWEEN inst.effective_start_date
             AND inst.effective_end_date;

--
--
--
PROCEDURE debug(
  p_trace_message             IN       VARCHAR2
 ,p_trace_location            IN       NUMBER DEFAULT NULL
)
IS
BEGIN
  IF NOT g_is_concurrent_program_run THEN
    pqp_utilities.debug(p_trace_message, p_trace_location);
  ELSE
    IF p_trace_location IS NULL THEN
      fnd_file.put_line(fnd_file.log,p_trace_message);
    ELSE
      fnd_file.put_line(fnd_file.log,RPAD(p_trace_message,80,' ')||TO_CHAR(p_trace_location));
    END IF;
  END IF;
END debug;
--
--
--
--PROCEDURE debug(p_trace_number IN NUMBER)
--IS
--BEGIN
--  pqp_utilities.debug(p_trace_number);
--END debug;
----
----
----
--PROCEDURE debug(p_trace_date IN DATE)
--IS
--BEGIN
--  pqp_utilities.debug(p_trace_date);
--END debug;
--
--
--
PROCEDURE debug_enter(
  p_proc_name                 IN       VARCHAR2
 ,p_trace_on                  IN       VARCHAR2 DEFAULT NULL
)
IS
BEGIN
  IF NOT g_is_concurrent_program_run THEN
    pqp_utilities.debug_enter(p_proc_name, p_trace_on);
  ELSE
      fnd_file.put_line(fnd_file.log,RPAD(p_proc_name,80,' ')||'+0');
  END IF;
END debug_enter;
--
--
--
PROCEDURE debug_exit(
  p_proc_name                 IN       VARCHAR2
 ,p_trace_off                 IN       VARCHAR2 DEFAULT NULL
)
IS
BEGIN
  IF NOT g_is_concurrent_program_run THEN
    pqp_utilities.debug_exit(p_proc_name, p_trace_off);
  ELSE
      fnd_file.put_line(fnd_file.log,RPAD(p_proc_name,80,' ')||'-0');
  END IF;
END debug_exit;
--
--
--
PROCEDURE debug_others(
  p_proc_name                 IN       VARCHAR2
 ,p_proc_step                 IN       NUMBER DEFAULT NULL
)
IS
BEGIN
  pqp_utilities.debug_others(p_proc_name, p_proc_step);
END debug_others;
--
--
--
PROCEDURE check_error_code
  (p_error_code               IN       NUMBER
  ,p_error_message            IN       VARCHAR2
  )
IS
BEGIN
  pqp_utilities.check_error_code(p_error_code, p_error_message);
END;
--
--
--
PROCEDURE clear_cache
IS
BEGIN
-- cache for get_installation_status
g_application_id               := NULL;
g_status                       := NULL;

-- cache for load_cached_constants
g_pqp_contract_table_id        :=NULL;
g_annual_hours_col_id          :=NULL;
g_period_divisor_col_id        :=NULL;
g_not_cached_constants         :=TRUE;

-- cache for chk_fte_exists
g_fte_exists_assignment_id     :=NULL;
g_fte_exists                   :=NULL;

-- cache for get_earliest_possible_date
g_epFd_assignment_id           :=NULL;
g_epFd_earliest_possible_date  :=NULL;

END clear_cache;
--
--
--
FUNCTION convert_record_to_outputstring
  (p_output_file_record           g_output_file_rec_type
  ) RETURN VARCHAR2
IS
  l_proc_step                    NUMBER(20,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'convert_record_to_outputstring';

  l_outputstring                VARCHAR2(4000);

BEGIN -- convert_record_to_outputstring

  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;

  l_outputstring :=
    RPAD(NVL(p_output_file_record.status,' '),30,' ')||g_column_separator||
    RPAD(NVL(p_output_file_record.employee_number,' '),20,' ')||g_column_separator||
    RPAD(NVL(p_output_file_record.assignment_number,'AsgId:'||p_output_file_record.assignment_id),30,' ')||g_column_separator||
    RPAD(NVL(fnd_date.date_to_displaydate(p_output_file_record.effective_date),' '),15,' ')||g_column_separator||
    RPAD(NVL(p_output_file_record.change_in,' '),30,' ')||g_column_separator||
    RPAD(NVL(TO_CHAR(p_output_file_record.FTE_old_value),' '),20,' ')||g_column_separator||
    RPAD(NVL(p_output_file_record.change_type,' '),15,' ')||g_column_separator||
    RPAD(NVL(TO_CHAR(p_output_file_record.FTE_new_value),' '),20,' ')||g_column_separator||
    RPAD(NVL(TO_CHAR(p_output_file_record.normal_hours),' '),15,' ')||g_column_separator||
    RPAD(NVL(HR_GENERAL.DECODE_LOOKUP('FREQUENCY',p_output_file_record.frequency),' '),10,' ')||g_column_separator||
    RPAD(NVL(p_output_file_record.contract_type,' '),30,' ')||g_column_separator||
    RPAD(NVL(p_output_file_record.annual_hours,' '),15,' ')||g_column_separator||
    RPAD(NVL(p_output_file_record.period_divisor,' '),15,' ')||g_column_separator||
    RPAD(p_output_file_record.message,255,' ')
  ;

  IF g_debug THEN
    debug_exit(l_proc_name);
    debug('l_outputstring_1_200:'||SUBSTR(l_outputstring,1,200));
    debug('l_outputstring_201_400:'||SUBSTR(l_outputstring,201,200));
    debug('l_outputstring_401_600:'||SUBSTR(l_outputstring,401,200));
  END IF;

  RETURN l_outputstring;

EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END convert_record_to_outputstring;
--
--
--
PROCEDURE write_output_file_records
IS

  l_proc_step                    NUMBER(20,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'write_output_file_records';

  i                              BINARY_INTEGER;

BEGIN -- write_output_file_records

 IF g_debug THEN
   debug_enter(l_proc_name);
 END IF;

 i:= g_output_file_records.FIRST;

 WHILE i IS NOT NULL
 LOOP

   fnd_file.put_line
     (fnd_file.output
     ,convert_record_to_outputstring(g_output_file_records(i))
     );

   i := g_output_file_records.NEXT(i);

 END LOOP;

 IF g_debug THEN
   debug_exit(l_proc_name);
 END IF;


EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END write_output_file_records;
--
--
--
FUNCTION get_installation_status
  (p_application_id               IN NUMBER
  ) RETURN VARCHAR2
IS

l_proc_step                    NUMBER(20,10):=0;
l_proc_name                    VARCHAR2(61):=
  g_package_name||'get_installation_status';

CURSOR csr_is_installed
  (p_application_id               NUMBER
  ) IS
SELECT status
FROM   fnd_product_installations
WHERE  application_id = p_application_id;

l_status        fnd_product_installations.status%TYPE;

BEGIN -- get_installation_status

IF g_debug THEN
  debug_enter(l_proc_name);
  debug('p_application_id:'||p_application_id);
  debug('g_application_id:'||g_application_id);
  debug('g_status:'||g_status);
END IF;

IF g_application_id <> p_application_id
  OR
   g_application_id IS NULL
  OR
   g_status IS NULL
THEN

  OPEN csr_is_installed(p_application_id);
  FETCH csr_is_installed INTO l_status;
  IF csr_is_installed%FOUND THEN
    IF l_status = 'I' THEN
      g_application_id := p_application_id;
      g_status := l_status;
    ELSE
      g_application_id := p_application_id;
      g_status := l_status;
    END IF;
  ELSE
    -- invalid application id, destroy cache, set status to null -- redundant
    g_application_id := NULL;
    g_status := NULL;
    l_status := NULL;
  END IF;
  CLOSE csr_is_installed;

ELSE

  l_status := g_status;

END IF; -- IF g_application_id <> p_application_id


IF g_debug THEN
  debug('l_status:'||l_status);
  debug_exit(l_proc_name);
END IF;

RETURN l_status;

EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END get_installation_status;
--
--
--
PROCEDURE load_cached_constants
IS
  l_proc_step                    NUMBER(20,10):= 0;
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'load_cached_constants';

  CURSOR csr_pqp_contract_table IS
  SELECT user_table_id
  FROM   pay_user_tables
  WHERE  user_table_name = 'PQP_CONTRACT_TYPES'
    AND  legislation_code = 'GB';

  CURSOR csr_relevant_columns
    (p_user_table_id              IN NUMBER
    ,p_user_column_name           IN VARCHAR2
    ) IS
  SELECT user_column_id
  FROM   pay_user_columns
  WHERE  user_table_id = p_user_table_id
    AND  UPPER(user_column_name) = UPPER(p_user_column_name)
    AND  legislation_code = 'GB';

  l_status                       fnd_product_installations.status%TYPE;


BEGIN -- load_cached_constants

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('g_pqp_contract_table_id:'||g_pqp_contract_table_id);
    debug('g_annual_hours_col_id:'||g_annual_hours_col_id);
    debug('g_period_divisor_col_id:'||g_period_divisor_col_id);
    IF g_not_cached_constants THEN
      debug('g_not_cached_constants:TRUE');
    ELSE
      debug('g_not_cached_constants:FALSE');
    END IF;
  END IF;

  IF g_not_cached_constants THEN

    g_pqp_contract_table_id := NULL;
    g_annual_hours_col_id := NULL;
    g_period_divisor_col_id := NULL;
    g_not_cached_constants := FALSE;

    l_status := get_installation_status(801);

    OPEN csr_pqp_contract_table;
    FETCH csr_pqp_contract_table INTO g_pqp_contract_table_id;
    IF csr_pqp_contract_table%NOTFOUND THEN
      l_proc_step := 10;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      g_not_cached_constants := TRUE;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE csr_pqp_contract_table;

    IF g_debug THEN
      debug('g_pqp_contract_table_id:'||g_pqp_contract_table_id);
    END IF;

    OPEN csr_relevant_columns
      (p_user_table_id              => g_pqp_contract_table_id
      ,p_user_column_name           => 'Annual Hours'
      );
    FETCH csr_relevant_columns INTO g_annual_hours_col_id;
    IF csr_relevant_columns%NOTFOUND THEN
      l_proc_step := 20;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      g_not_cached_constants := TRUE;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE csr_relevant_columns;

    IF g_debug THEN
      debug('g_annual_hours_col_id:'||g_annual_hours_col_id);
    END IF;


    OPEN csr_relevant_columns
      (p_user_table_id              => g_pqp_contract_table_id
      ,p_user_column_name           => 'Period Divisor'
      );
    FETCH csr_relevant_columns INTO g_period_divisor_col_id;
    IF csr_relevant_columns%NOTFOUND THEN
      l_proc_step := 30;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      g_not_cached_constants := TRUE;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE csr_relevant_columns;

    IF g_debug THEN
      debug('g_period_divisor_col_id:'||g_period_divisor_col_id);
    END IF;

  ELSE
    IF g_debug THEN
      debug('g_not_cached_constants:FALSE');
    END IF;
  END IF;

  IF g_debug THEN
    debug('g_pqp_contract_table_id:'||g_pqp_contract_table_id);
    debug('g_annual_hours_col_id:'||g_annual_hours_col_id);
    debug('g_period_divisor_col_id:'||g_period_divisor_col_id);
    debug('g_application_id:'||g_application_id);
    debug('g_status:'||g_status);
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END load_cached_constants;
--
--
--
FUNCTION get_earliest_possible_FTE_date
  (p_assignment_id                NUMBER
  ,p_reload_cache                 BOOLEAN DEFAULT FALSE
  ) RETURN DATE
IS

  l_proc_step                    NUMBER(20,10):=0;
  l_proc_name                    VARCHAR2(61):=
      g_package_name||'get_earliest_possible_FTE_date';

  CURSOR csr_min_aat_start_date
    (p_assignment_id                NUMBER
    ) IS
  SELECT MIN(aat.effective_start_date)
  FROM   pqp_assignment_attributes_f aat
  WHERE  aat.assignment_id = p_assignment_id
    AND  aat.contract_type IS NOT NULL;

  CURSOR csr_min_asg_start_date
    (p_assignment_id                NUMBER
    ) IS
  SELECT MIN(asg.effective_start_date)
  FROM   per_all_assignments_f asg
  WHERE  asg.assignment_id = p_assignment_id
    AND  asg.normal_hours IS NOT NULL;


  l_aat_effective_start_date     DATE;
  l_asg_effective_start_date     DATE;
  --l_earliest_possible_FTE_date   DATE;

BEGIN -- get_earliest_possible_FTE_date

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('g_epFd_assignment_id:'||g_epFd_assignment_id);
    debug('g_epFd_earliest_possible_date:'||
      fnd_date.date_to_canonical(g_epFd_earliest_possible_date));
    IF p_reload_cache = TRUE THEN
      debug('p_reload_cache:TRUE');
    END IF;
    IF p_reload_cache = FALSE THEN
      debug('p_reload_cache:FALSE');
    END IF;
    IF p_reload_cache IS NULL THEN
      debug('p_reload_cache:IS NULL');
    END IF;
  END IF;


  IF p_assignment_id <> g_epFd_assignment_id
    OR
     g_epFd_assignment_id IS NULL
    OR
     g_epFd_earliest_possible_date IS NULL
    OR
     p_reload_cache = TRUE
  THEN

    -- always clear cache before reloading it
    g_epFd_assignment_id := NULL;
    g_epFd_earliest_possible_date := NULL;

    OPEN  csr_min_aat_start_date(p_assignment_id);
    FETCH csr_min_aat_start_date INTO l_aat_effective_start_date;
    CLOSE csr_min_aat_start_date;

    OPEN  csr_min_asg_start_date(p_assignment_id);
    FETCH csr_min_asg_start_date INTO l_asg_effective_start_date;
    CLOSE csr_min_asg_start_date;

    IF g_debug THEN
      debug('l_aat_effective_start_date:'||l_aat_effective_start_date);
      debug('l_asg_effective_start_date:'||l_asg_effective_start_date);
    END IF;

    g_epFd_assignment_id := p_assignment_id;

    g_epFd_earliest_possible_date :=
      GREATEST(l_aat_effective_start_date, l_asg_effective_start_date);

   END IF;

  IF g_debug THEN
    debug('g_epFd_assignment_id:'||g_epFd_assignment_id);
    debug('g_epFd_earliest_possible_date:'||
      fnd_date.date_to_canonical(g_epFd_earliest_possible_date));
    debug_exit(l_proc_name);
  END IF;

  RETURN g_epFd_earliest_possible_date;

EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END get_earliest_possible_FTE_date;
--
--
--
FUNCTION chk_fte_exists
  (p_assignment_id                NUMBER
  ,p_reload_cache                 BOOLEAN DEFAULT FALSE
  ) RETURN BOOLEAN
IS
  l_proc_step                    NUMBER(20,10):=0;
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'chk_fte_exists';

  l_fte_exists_tmp               csr_fte_exists%ROWTYPE;
  l_fte_exists                   BOOLEAN;
  l_FTE_processing_start_date    DATE;

BEGIN -- chk_fte_exists

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('g_fte_exists_assignment_id:'||g_fte_exists_assignment_id);
    IF g_fte_exists = TRUE THEN
      debug('g_fte_exists:TRUE');
    END IF;
    IF g_fte_exists = FALSE THEN
      debug('g_fte_exists:FALSE');
    END IF;
    IF g_fte_exists IS NULL THEN
      debug('g_fte_exists:IS NULL');
    END IF;
    IF p_reload_cache = TRUE THEN
      debug('p_reload_cache:TRUE');
    END IF;
    IF p_reload_cache = FALSE THEN
      debug('p_reload_cache:FALSE');
    END IF;
    IF p_reload_cache IS NULL THEN
      debug('p_reload_cache:IS NULL');
    END IF;
  END IF;

  IF p_assignment_id <> g_fte_exists_assignment_id
    OR
     g_fte_exists IS NULL
    OR
     g_fte_exists_assignment_id IS NULL
    OR
     p_reload_cache = TRUE
  THEN
    IF p_assignment_id IS NOT NULL
    THEN
      OPEN csr_fte_exists(p_assignment_id);
      FETCH csr_fte_exists INTO l_fte_exists_tmp;
      g_fte_exists := csr_fte_exists%FOUND;
      g_fte_exists_assignment_id := p_assignment_id;
      CLOSE csr_fte_exists;
    ELSE
      RAISE NO_DATA_FOUND;
      -- do not allow function to return
      -- as this may cause the calling logic to make
      -- an incorrect decision
    END IF;
  END IF; -- IF g_fte_exists_assignment_id <> p_assignment_id

  -- DO NOT RETURN cache globals always copy to local first
  l_fte_exists := g_fte_exists;

  IF g_debug THEN
    IF g_fte_exists = TRUE THEN
      debug('g_fte_exists:TRUE');
    END IF;
    IF g_fte_exists = FALSE THEN
      debug('g_fte_exists:FALSE');
    END IF;
    IF g_fte_exists IS NULL THEN
      debug('g_fte_exists:IS NULL');
    END IF;
    debug('g_fte_exists_assignment_id:'||g_fte_exists_assignment_id);
    debug_exit(l_proc_name);
  END IF;

  RETURN l_fte_exists;

EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END chk_fte_exists;
--
--
--
FUNCTION get_FTE_processing_start_date
  (p_assignment_id                IN NUMBER
  ,p_effective_date               IN DATE
  ) RETURN DATE
IS
  l_proc_step                    NUMBER(20,10):=0;
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'get_FTE_processing_start_date';

  l_FTE_processing_start_date    DATE;

BEGIN  -- get_FTE_processing_start_date

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_effective_date:'||p_effective_date);
  END IF;

-- IF FTE does not exist, processing start date = earliest possible
-- IF FTE does exist and effective date passed < earliest possible use earliest possible
-- IF FTE does exist and effective date passed > earliest possible use effective date

  l_FTE_processing_start_date :=
    get_earliest_possible_FTE_date(p_assignment_id,TRUE);

  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_FTE_processing_start_date:'||l_FTE_processing_start_date);
  END IF;

  IF chk_fte_exists(p_assignment_id,TRUE)
    AND
     p_effective_date > l_FTE_processing_start_date
  THEN
    l_proc_step := 15;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
    l_FTE_processing_start_date := p_effective_date;
  END IF;

  IF g_debug THEN
    debug('l_FTE_processing_start_date:'||l_FTE_processing_start_date);
    debug_exit(l_proc_name);
  END IF;

  RETURN l_FTE_processing_start_date;

EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END get_FTE_processing_start_date;
--
--
--
FUNCTION is_fte_enabled
  (p_assignment_id                 NUMBER
  ) RETURN BOOLEAN
IS
  l_proc_step                    NUMBER(20,10):=0;
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'is_fte_enabled';

--  l_does_fte_exist               BOOLEAN;
  l_earliest_possible_FTE_date   DATE;

  l_fte_is_enabled               BOOLEAN;


BEGIN -- is_fte_enabled

  -- setting reload cache to true here is ok
  -- as this will if this true

--  l_does_fte_exist := chk_fte_exists(p_assignment_id);

  l_earliest_possible_FTE_date :=
    get_earliest_possible_FTE_date(p_assignment_id);

--  l_fte_is_enabled :=
--    (
--     l_earliest_possible_FTE_date IS NOT NULL
--    OR
--     l_does_fte_exist = TRUE
--    );

  IF l_earliest_possible_FTE_date IS NOT NULL
  THEN
    l_fte_is_enabled := TRUE;
  ELSE
    l_fte_is_enabled := FALSE;
  END IF;

  RETURN l_fte_is_enabled;

END is_fte_enabled;
--
--
--
/* =====================================================================
   Name    : set_fte_value
   Purpose : Calculate FTE and write to database.
   Returns :
   ---------------------------------------------------------------------*/
PROCEDURE set_fte_value
  (p_assignment_id               IN  NUMBER
  ,p_business_group_id           IN  NUMBER
  ,p_calculation_date            IN  DATE
  ,p_fte_value                   IN  NUMBER
  )
IS

l_proc_step                    NUMBER(20,10):= 0;
l_proc_name                    VARCHAR2(61):=
  g_package_name||'set_fte_value';

l_datetrack_mode               VARCHAR2(30);
l_future_end_date              DATE;

-- Added a new variable obj

--l_object_version_number      number;

l_fte_exists                 csr_fte_exists%ROWTYPE;
l_effective_fte_row          csr_effective_fte%ROWTYPE;

-- Retrieve object_version_number
-- as this col is added recently
-- PS bug 2093889 for details

CURSOR csr_chk_future_fte_rows
  (p_assignment_budget_value_id   NUMBER
  ,p_effective_date               DATE
  )
  IS
SELECT effective_end_date
FROM   per_assignment_budget_values_f
WHERE  assignment_budget_value_id = p_assignment_budget_value_id
  AND  effective_start_date > p_effective_date
  AND  ROWNUM < 2;

BEGIN -- set_fte_value

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_calculation_date:'||
          fnd_date.date_to_canonical(p_calculation_date)
         );
    debug('p_fte_value:'||p_fte_value);
  END IF;


  IF NOT chk_fte_exists(p_assignment_id)
  THEN

    l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

        per_abv_ins.ins(
           p_effective_date             => p_calculation_date
          ,p_business_group_id          => p_business_group_id
          ,p_assignment_id              => p_assignment_id
          ,p_unit                       => 'FTE'
          ,p_value                      => p_fte_value
          ,p_request_id                 => null
          ,p_program_application_id     => null
          ,p_program_id                 => null
          ,p_program_update_date        => null
          ,p_assignment_budget_value_id => l_effective_fte_row.assignment_budget_value_id
          ,p_object_version_number      => l_effective_fte_row.object_version_number -- new param added
          ,p_effective_start_date       => l_effective_fte_row.effective_start_date
          ,p_effective_end_date         => l_effective_fte_row.effective_end_date
           );

    IF g_is_concurrent_program_run THEN
      g_output_file_records(g_output_file_records.LAST).status := 'Processed';
      g_output_file_records(g_output_file_records.LAST).change_type := 'INSERT';
    END IF;

    -- dummy call to repopulate chk_fte_exists cache
    -- as in the subsequent call we want it to know that an fte exists
    -- after this insert has taken and subsequent calls to set_fte_value
    -- should attempt updates
    IF NOT chk_fte_exists(p_assignment_id,TRUE)
    THEN
      -- if all goes well I never expect code to reach here
      -- if it does it implies that some fatal error during insert
      -- has been masked so abort processing now
      l_proc_step := 15;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      RAISE NO_DATA_FOUND;
    END IF;

  ELSE -- an FTE record was found

    OPEN  csr_effective_fte(p_assignment_id,p_calculation_date);
    FETCH csr_effective_fte INTO l_effective_fte_row;
    CLOSE csr_effective_fte;

    l_proc_step := 20;
    IF g_debug THEN
      debug('ROUND(p_fte_value,5):'||ROUND(p_fte_value,5));
      debug('l_effective_fte_row.assignment_budget_value_id:'||
            l_effective_fte_row.assignment_budget_value_id);
      debug('l_effective_fte_row.object_version_number:'||
            l_effective_fte_row.object_version_number);
      debug('l_effective_fte_row.effective_start_date:'||
            fnd_date.date_to_canonical(l_effective_fte_row.effective_start_date)
           );
      debug('l_effective_fte_row.effective_end_date:'||
            fnd_date.date_to_canonical(l_effective_fte_row.effective_end_date)
           );
      debug('l_effective_fte_row.value:'||l_effective_fte_row.value);
    END IF;

    IF g_is_concurrent_program_run THEN
      g_output_file_records(g_output_file_records.LAST).FTE_old_value :=
        l_effective_fte_row.value;
    END IF;

    OPEN csr_chk_future_fte_rows
      (l_effective_fte_row.assignment_budget_value_id
      ,p_calculation_date
      );
    FETCH csr_chk_future_fte_rows INTO l_future_end_date;
    IF csr_chk_future_fte_rows%FOUND
    THEN
      --
      --
      -- For updates, if future rows exist, use update override.
      -- This has been agreed as a valid requirement
      --
      l_datetrack_mode := 'UPDATE_OVERRIDE';
    ELSE
      --
      -- If no future changes exist, just use update
      --
      IF l_effective_fte_row.effective_start_date <> p_calculation_date
      THEN
        l_datetrack_mode := 'UPDATE';
      ELSE
        l_datetrack_mode := 'CORRECTION';
      END IF;
    END IF;
    CLOSE csr_chk_future_fte_rows;

   l_proc_step := 30;
   IF g_debug THEN
     debug('l_future_end_date:'||l_future_end_date);
     debug('l_datetrack_mode:'||l_datetrack_mode);
   END IF;

   IF l_datetrack_mode <> 'UPDATE_OVERRIDE'
   THEN

     -- only do a datetrack UPDATE or correction if the value is different

     IF ROUND(l_effective_fte_row.value,5) <> ROUND(p_fte_value,5)
     THEN

     per_abv_upd.upd(
       p_effective_date             => p_calculation_date
      ,p_datetrack_mode             => l_datetrack_mode
      ,p_assignment_budget_value_id => l_effective_fte_row.assignment_budget_value_id
      ,p_object_version_number      => l_effective_fte_row.object_version_number -- new param added
      ,p_unit                       => 'FTE'
      ,p_value                      => p_fte_value
      ,p_request_id                 => null
      ,p_program_application_id     => null
      ,p_program_id                 => null
      ,p_program_update_date        => null
      ,p_effective_start_date       => l_effective_fte_row.effective_start_date
      ,p_effective_end_date         => l_effective_fte_row.effective_end_date
       );

       IF g_is_concurrent_program_run THEN
         g_output_file_records(g_output_file_records.LAST).status := 'Processed';
         g_output_file_records(g_output_file_records.LAST).change_type := l_datetrack_mode;
       END IF;

     ELSE
       IF g_is_concurrent_program_run THEN
         g_output_file_records(g_output_file_records.LAST).status := 'Processed (No Change)';
         g_output_file_records(g_output_file_records.LAST).change_type := l_datetrack_mode;
       END IF;
     END IF;

   ELSE

     IF g_debug THEN
       IF g_is_concurrent_program_run THEN
         debug('g_is_concurrent_program_run:TRUE');
       ELSE
         debug('g_is_concurrent_program_run:FALSE');
       END IF;
     END IF;

     IF ( g_is_concurrent_program_run
         AND
          ROUND(l_effective_fte_row.value,5) <> ROUND(p_fte_value,5)
        )
       OR
        NOT g_is_concurrent_program_run
     THEN

       l_proc_step := 40;
       IF g_debug THEN
         debug(l_proc_name,l_proc_step);
       END IF;

       IF l_effective_fte_row.effective_start_date <> p_calculation_date
       THEN

         per_abv_upd.upd(
            p_effective_date             => p_calculation_date
           ,p_datetrack_mode             => l_datetrack_mode
           ,p_assignment_budget_value_id => l_effective_fte_row.assignment_budget_value_id
           ,p_object_version_number      => l_effective_fte_row.object_version_number -- new param added
           ,p_unit                       => 'FTE'
           ,p_value                      => p_fte_value
           ,p_request_id                 => null
           ,p_program_application_id     => null
           ,p_program_id                 => null
           ,p_program_update_date        => null
           ,p_effective_start_date       => l_effective_fte_row.effective_start_date
           ,p_effective_end_date         => l_effective_fte_row.effective_end_date
            );

       ELSE

         l_datetrack_mode := hr_api.g_future_change;
         per_abv_del.del(
            p_effective_date             => p_calculation_date
           ,p_datetrack_mode             => l_datetrack_mode
           ,p_assignment_budget_value_id => l_effective_fte_row.assignment_budget_value_id
           ,p_object_version_number      => l_effective_fte_row.object_version_number -- new param added
           ,p_effective_start_date       => l_effective_fte_row.effective_start_date
           ,p_effective_end_date         => l_effective_fte_row.effective_end_date
            );

         l_datetrack_mode := hr_api.g_correction;
         per_abv_upd.upd(
            p_effective_date             => p_calculation_date
           ,p_datetrack_mode             => l_datetrack_mode
           ,p_assignment_budget_value_id => l_effective_fte_row.assignment_budget_value_id
           ,p_object_version_number      => l_effective_fte_row.object_version_number -- new param added
           ,p_unit                       => 'FTE'
           ,p_value                      => p_fte_value
           ,p_request_id                 => null
           ,p_program_application_id     => null
           ,p_program_id                 => null
           ,p_program_update_date        => null
           ,p_effective_start_date       => l_effective_fte_row.effective_start_date
           ,p_effective_end_date         => l_effective_fte_row.effective_end_date
            );

       END IF; -- IF l_effective_fte_row.effective_start_date <> p_calculation_date

       IF g_is_concurrent_program_run THEN
         g_output_file_records(g_output_file_records.LAST).change_type := 'UPDATE_OVERRIDE';
         g_output_file_records(g_output_file_records.LAST).status := 'Processed';
       END IF;

     ELSE

       IF g_is_concurrent_program_run THEN
         g_output_file_records(g_output_file_records.LAST).change_type := 'UPDATE_OVERRIDE';
         g_output_file_records(g_output_file_records.LAST).status := 'Processed(No Change)';
       END IF;

     END IF; -- IF ( g_is_concurrent_program_run AND ROUND(l_effective_fte_row.value,5)...


   END IF; -- IF l_datetrack_mode <> 'UPDATE_OVERRIDE'

  END IF; -- IF NOT chk_fte_exists(p_assignment_id) THEN

  IF g_debug THEN
    debug('l_effective_fte_row.assignment_budget_value_id:'||
          l_effective_fte_row.assignment_budget_value_id);
    debug('l_effective_fte_row.object_version_number:'||
          l_effective_fte_row.object_version_number);
    debug('l_effective_fte_row.effective_start_date:'||
          fnd_date.date_to_canonical(l_effective_fte_row.effective_start_date)
         );
    debug('l_effective_fte_row.effective_end_date:'||
          fnd_date.date_to_canonical(l_effective_fte_row.effective_end_date)
         );
    debug('l_effective_fte_row.value:'||l_effective_fte_row.value);
    debug('ROUND(p_fte_value,5):'||ROUND(p_fte_value,5));
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END set_fte_value;
-- =====================================================================
-- Name    : Get_FTE_Value
-- Purpose : Query FTE value from database.
-- Returns : FTE
-- -------------------------------------------------------------------
FUNCTION get_fte_value
  (p_assignment_id               IN  NUMBER
  ,p_calculation_date            IN  DATE
  ) RETURN NUMBER
IS

l_proc_step                    NUMBER(20,10):=0;
l_proc_name                    VARCHAR2(61):=
  g_package_name||'get_fte_value';

l_effective_fte_row            csr_effective_fte%ROWTYPE;


BEGIN -- get_fte_value

  IF NOT g_is_concurrent_program_run THEN
    g_debug := hr_utility.debug_enabled;
  END IF;

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_calculation_date:'||p_calculation_date);
  END IF;

  OPEN  csr_effective_fte(p_assignment_id,p_calculation_date);
  FETCH csr_effective_fte INTO l_effective_fte_row;
  CLOSE csr_effective_fte;

  IF g_debug THEN
    debug('l_effective_fte_row.value:'||l_effective_fte_row.value);
    debug_exit(l_proc_name);
  END IF;

  RETURN l_effective_fte_row.value;

EXCEPTION
WHEN OTHERS THEN
  clear_cache;
  IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
    debug_others(l_proc_name,l_proc_step);
    IF g_debug THEN
      debug('Leaving: '||l_proc_name,-999);
    END IF;
    fnd_message.raise_error;
  ELSE
    RAISE;
  END IF;
END get_fte_value;
--
--
--
PROCEDURE get_assignment_details
  (p_assignment_id                IN NUMBER
  ,p_effective_date               IN DATE
  ,p_assignment_details           IN OUT NOCOPY csr_assignment_details%ROWTYPE
  )
IS
l_proc_step               NUMBER(20,10):=0;
l_proc_name               VARCHAR2(61):= 'get_assignment_details';
l_assignment_details      csr_assignment_details%ROWTYPE;

BEGIN -- get_assignment_details

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_effective_date:'||p_effective_date);
    debug('p_assignment_details.business_group_id:'||p_assignment_details.business_group_id);
    debug('p_assignment_details.normal_hours:'||p_assignment_details.normal_hours);
    debug('p_assignment_details.frequency:'||p_assignment_details.frequency);
  END IF;

  OPEN csr_assignment_details(p_assignment_id,p_effective_date);
  FETCH csr_assignment_details INTO p_assignment_details;
  IF csr_assignment_details%NOTFOUND THEN
    l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
    p_assignment_details := l_assignment_details; -- empty it
  ELSE
    l_proc_step := 15;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
  END IF;
  CLOSE csr_assignment_details;

  IF p_assignment_details.normal_hours IS NULL
    OR
     p_assignment_details.frequency IS NULL
  THEN
    l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
    IF g_is_concurrent_program_run
     OR
      is_fte_enabled(p_assignment_id)
    THEN
      fnd_message.set_name('PQP','PQP_230456_FTE_NO_ASG_DETAILS');
      fnd_message.set_token
        ('EFFECTIVEDATE'
        ,fnd_date.date_to_displaydate(p_effective_date)
        );
      fnd_message.raise_error;
    END IF;
  END IF;

  IF g_debug THEN
    debug('p_assignment_details.business_group_id:'||p_assignment_details.business_group_id);
    debug('p_assignment_details.normal_hours:'||p_assignment_details.normal_hours);
    debug('p_assignment_details.frequency:'||p_assignment_details.frequency);
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_assignment_details := l_assignment_details; -- nocopy
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_assignment_details;
--
--
--
PROCEDURE get_contract_details
  (p_assignment_id                IN NUMBER
  ,p_effective_date               IN DATE
  ,p_contract_details             IN OUT NOCOPY csr_contract_details%ROWTYPE
  )
IS
l_proc_step               NUMBER(20,10):=0;
l_proc_name               VARCHAR2(61):= 'get_contract_details';
l_contract_details        csr_contract_details%ROWTYPE;
l_assignment_contract     csr_assignment_contract%ROWTYPE;

l_pqp_contract_table_id     pay_user_tables.user_table_id%TYPE;
l_annual_hours_col_id       pay_user_columns.user_column_id%TYPE;
l_period_divisor_col_id     pay_user_columns.user_column_id%TYPE;

BEGIN -- get_contract_details

IF g_debug THEN
  debug_enter(l_proc_name);
  debug('p_assignment_id:'||p_assignment_id);
  debug('p_effective_date:'||p_effective_date);
  debug('p_contract_details.annual_hours:'||p_contract_details.annual_hours);
  debug('p_contract_details.period_divisor:'||p_contract_details.period_divisor);
END IF;

IF g_not_cached_constants THEN
  load_cached_constants;
END IF;

l_pqp_contract_table_id := g_pqp_contract_table_id;
l_annual_hours_col_id   := g_annual_hours_col_id;
l_period_divisor_col_id := g_period_divisor_col_id;

IF g_debug THEN
  debug('l_pqp_contract_table_id:'||l_pqp_contract_table_id);
  debug('l_annual_hours_col_id:'||l_annual_hours_col_id);
  debug('l_period_divisor_col_id:'||l_period_divisor_col_id);
END IF;

OPEN csr_assignment_contract
  (p_assignment_id
  ,p_effective_date
  ,l_pqp_contract_table_id
  );
FETCH csr_assignment_contract INTO l_assignment_contract;
IF csr_assignment_contract%FOUND
THEN

  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_assignment_contract.user_row_id:'||l_assignment_contract.user_row_id);
  END IF;

   IF l_assignment_contract.user_row_id IS NOT NULL
   THEN
     p_contract_details.contract_type := l_assignment_contract.contract_type;
     p_contract_details.user_row_id := l_assignment_contract.user_row_id;


     l_proc_step := 20;
     IF g_debug THEN
       debug(l_proc_name,l_proc_step);
     END IF;

     OPEN csr_get_contract_value
        (l_annual_hours_col_id
        ,l_assignment_contract.user_row_id
        ,p_effective_date
        );
     FETCH csr_get_contract_value INTO p_contract_details.annual_hours;
     IF csr_get_contract_value%NOTFOUND THEN
       p_contract_details := l_contract_details; -- empty
       l_proc_step := 25;
       IF g_debug THEN
         debug(l_proc_name,l_proc_step);
       END IF;
     END IF;
     CLOSE csr_get_contract_value;

     l_proc_step := 30;
     IF g_debug THEN
       debug(l_proc_name,l_proc_step);
     END IF;

     OPEN csr_get_contract_value
        (l_period_divisor_col_id
        ,l_assignment_contract.user_row_id
        ,p_effective_date
        );
     FETCH csr_get_contract_value INTO p_contract_details.period_divisor;
     IF csr_get_contract_value%NOTFOUND
     THEN
       p_contract_details := l_contract_details; -- empty
       l_proc_step := 35;
       IF g_debug THEN
         debug(l_proc_name,l_proc_step);
       END IF;
     END IF;
     CLOSE csr_get_contract_value;

   END IF; -- IF l_assignment_contract.user_row_id IS NOT NULL
ELSE

  p_contract_details := l_contract_details; -- empty

  l_proc_step := 40;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

END IF; -- IF csr_assignment_contract%FOUND
CLOSE csr_assignment_contract;

IF p_contract_details.annual_hours IS NULL
  OR
   p_contract_details.period_divisor IS NULL
THEN
  l_proc_step := 50;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;
  IF g_is_concurrent_program_run
    OR
     is_fte_enabled(p_assignment_id)
  THEN
    IF l_assignment_contract.contract_type IS NOT NULL
    THEN
      fnd_message.set_name('PQP','PQP_230457_FTE_NO_CTR_DETAILS');
      fnd_message.set_token
        ('CONTRACTTYPE'
        ,l_assignment_contract.contract_type
        );

      fnd_message.set_token
        ('EFFECTIVEDATE'
        ,fnd_date.date_to_displaydate(p_effective_date)
        );
      fnd_message.raise_error;
    ELSE
      fnd_message.set_name('PQP','PQP_230113_AAT_MISSING_CONTRCT');
      fnd_message.set_token
        ('EFFECTIVEDATE'
        ,fnd_date.date_to_displaydate(p_effective_date)
        );
      fnd_message.raise_error;
    END IF;
  END IF;
END IF; -- IF p_contract_details.annual_hours IS NULL

IF g_debug THEN
  debug('p_contract_details.annual_hours:'||p_contract_details.annual_hours);
  debug('p_contract_details.period_divisor:'||p_contract_details.period_divisor);
  debug_exit(l_proc_name);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_contract_details := l_contract_details; -- empty for nocopy
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_contract_details;
--
--
-- procedure to calculate and store FTE called in a loop from the main
PROCEDURE calculate_and_store_fte
  (p_assignment_id                NUMBER
  ,p_effective_date               DATE
  )
IS

l_proc_name               VARCHAR2(61):= 'calculate_and_store_fte';
l_proc_step               NUMBER:=0;
l_FTE_value               NUMBER;

l_assignment_details           csr_assignment_details%ROWTYPE;
l_contract_details             csr_contract_details%ROWTYPE;
BEGIN -- calculate_and_store_fte


  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
  END IF;

  -- fetch the relevant assignment details normal hours and contract

  -- get_assignment_normal_hours_and_frequency
  -- use out paramater to capitalize on nocopy of output parameters

    get_assignment_details
      (p_assignment_id
      ,p_effective_date
      ,l_assignment_details
      );

  IF g_is_concurrent_program_run THEN
    g_output_file_records(g_output_file_records.LAST).normal_hours:=
      l_assignment_details.normal_hours;

    g_output_file_records(g_output_file_records.LAST).frequency:=
    l_assignment_details.frequency;
  END IF;

  l_proc_step :=10;
  IF g_debug THEN
    debug(l_proc_name, l_proc_step);
  END IF;

    get_contract_details
      (p_assignment_id
      ,p_effective_date
      ,l_contract_details
      );

  IF g_is_concurrent_program_run THEN
    g_output_file_records(g_output_file_records.LAST).contract_type:=
      l_contract_details.contract_type;

    g_output_file_records(g_output_file_records.LAST).annual_hours:=
      l_contract_details.annual_hours;

    g_output_file_records(g_output_file_records.LAST).period_divisor:=
      l_contract_details.period_divisor;
  END IF;

  l_proc_step :=20;
  IF g_debug THEN
    debug('l_contract_details.annual_hours:'||l_contract_details.annual_hours);
    debug('l_contract_details.period_divisor:'||l_contract_details.period_divisor);
    debug(l_proc_name,l_proc_step);
  END IF;

  IF l_assignment_details.frequency <> 'Y'
  THEN
    l_fte_value :=
      l_assignment_details.normal_hours /
        ( l_contract_details.annual_hours / l_contract_details.period_divisor );
  ELSE
    l_fte_value := l_assignment_details.normal_hours / l_contract_details.annual_hours;
  END IF; -- IF l_assignment_details.frequency = 'Y' THEN

  IF g_is_concurrent_program_run THEN
    g_output_file_records(g_output_file_records.LAST).FTE_new_value:=
      l_fte_value;
  END IF;

  IF l_fte_value IS NOT NULL
  THEN
    l_proc_step :=35;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('l_FTE_value:'||l_FTE_value);
    END IF;
    set_fte_value
      (p_assignment_id     => p_assignment_id
      ,p_business_group_id => l_assignment_details.business_group_id
      ,p_calculation_date  => p_effective_date
      ,p_FTE_value         => l_FTE_value
      );

    IF g_debug THEN
      hr_utility.trace(
       'Updated, '||p_assignment_id||', '||
       fnd_date.date_to_displaydate(p_effective_date)||', '||
       l_FTE_value||', '||
       l_assignment_details.normal_hours||', '||
--       l_assignment_details.contract_type||', '||
       l_contract_details.annual_hours||', '||
       l_contract_details.period_divisor
      );
    END IF;

  ELSE

    IF g_is_concurrent_program_run THEN
      g_output_file_records(g_output_file_records.LAST).change_type:= 'Not Known';
      g_output_file_records(g_output_file_records.LAST).status:= 'Errored(Skipped)';
    END IF;

  END IF;

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END calculate_and_store_fte;
--
--
PROCEDURE update_fte_for_assignment
  (p_assignment_id                NUMBER
  ,p_effective_date               DATE
  )
IS

  l_proc_name             VARCHAR2(61):=
    g_package_name||'update_fte_for_assignment';
  l_proc_step             NUMBER(20,10):=0;

  i                       BINARY_INTEGER:=0;
  l_max_iterations        BINARY_INTEGER:= 10000;

  l_pqp_contract_table_id        pay_user_tables.user_table_id%TYPE;
  l_annual_hours_col_id          pay_user_columns.user_column_id%TYPE;
  l_period_divisor_col_id        pay_user_columns.user_column_id%TYPE;



  -- there is no need for the change type column in the following cursor
  -- it gives rise to have logic to eliminate duplicate dates to be implemented in loop
  -- as we use UNION ALL as opposed to UNION
  -- but when debugging , knowing the change type that was relevant can speed up investigation
  CURSOR csr_get_relevant_change_dates
    (p_assignment_id                              IN NUMBER
    ,p_min_effective_start_date                   IN DATE
    ,p_pqp_contract_table_id                      IN NUMBER
    ,p_annual_hours_col_id                        IN NUMBER
    ,p_period_divisor_col_id                      IN NUMBER
    ) IS
  SELECT 'Normal Hours' change_type,asg2.effective_start_date
  FROM   per_all_assignments_f asg1
        ,per_all_assignments_f asg2
  WHERE  asg1.assignment_id = p_assignment_id
    AND  ( asg1.effective_start_date >= p_min_effective_start_date
          OR
           p_min_effective_start_date
             BETWEEN asg1.effective_start_date
                 AND asg1.effective_end_date
         )
    AND  asg2.assignment_id = asg1.assignment_id
    AND  asg2.effective_start_date = asg1.effective_end_date+1
    AND  NVL(asg2.normal_hours,-1) <> NVL(asg1.normal_hours,-2)
  UNION ALL
  SELECT 'Assignment Contract' change_type,aat2.effective_start_date
  FROM   pqp_assignment_attributes_f aat1
        ,pqp_assignment_attributes_f aat2
  WHERE  aat1.assignment_id = p_assignment_id
    AND  ( aat1.effective_start_date >= p_min_effective_start_date
          OR
           p_min_effective_start_date
             BETWEEN aat1.effective_start_date
                 AND aat1.effective_end_date
         )
    AND  aat1.assignment_id = aat2.assignment_id
    AND  aat2.effective_start_date = aat1.effective_end_date+1
    AND  NVL(aat2.contract_type,'{null}') <> NVL(aat1.contract_type,'[NULL]')
  UNION ALL
  SELECT 'Contract Type' change_type,inst2.effective_start_date
  FROM   pqp_assignment_attributes_f aat
        ,pay_user_rows_f             pur
        ,pay_user_column_instances_f inst1
        ,pay_user_column_instances_f inst2
  WHERE  aat.assignment_id = p_assignment_id
    AND  ( aat.effective_start_date >= p_min_effective_start_date
          OR
           p_min_effective_start_date
             BETWEEN aat.effective_start_date
                 AND aat.effective_end_date
         )
    AND  pur.user_table_id = p_pqp_contract_table_id
    AND  pur.business_group_id = aat.business_group_id
    AND  pur.row_low_range_or_name = aat.contract_type
    AND  aat.effective_start_date
           BETWEEN pur.effective_start_date
               AND pur.effective_end_date
    AND  inst1.user_column_id IN
           (p_annual_hours_col_id
           ,p_period_divisor_col_id
           )
    AND  ( inst1.effective_start_date >= p_min_effective_start_date
          OR
           p_min_effective_start_date
             BETWEEN inst1.effective_start_date
                 AND inst1.effective_end_date
         )
    AND  inst1.user_row_id = pur.user_row_id
    AND  inst2.user_column_instance_id = inst1.user_column_instance_id
    AND  inst2.effective_start_date = inst1.effective_end_date+1
    AND  NVL(inst2.value,'{null}') <> NVL(inst1.value,'~NULL~')
  ORDER BY 2 ASC;


  l_last_change_date             DATE;
  l_relevant_change              csr_get_relevant_change_dates%ROWTYPE;
  l_status                       VARCHAR2(30);
  l_fte_exists                   BOOLEAN;
  l_earliest_possible_FTE_date   DATE;
  l_effective_date               DATE;

BEGIN -- update_fte_for_assignment


IF NOT g_is_concurrent_program_run  THEN
  g_debug := hr_utility.debug_enabled;
END IF;

IF g_debug THEN
  debug_enter(l_proc_name);
  debug('p_assignment_id:'||p_assignment_id);
  debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
  IF g_is_concurrent_program_run = TRUE THEN
    debug('g_is_concurrent_program_run:TRUE');
  END IF;
  IF g_is_concurrent_program_run = FALSE THEN
    debug('g_is_concurrent_program_run:FALSE');
  END IF;
  IF g_is_concurrent_program_run IS NULL THEN
    debug('g_is_concurrent_program_run:IS NULL');
  END IF;
END IF;

l_status := get_installation_status(801);

IF l_status = 'I' THEN -- do nothing unless payroll installed

  IF g_not_cached_constants THEN
    load_cached_constants;
  ELSE
    IF g_debug THEN
      debug('g_not_cached_constants:FALSE');
    END IF;
  END IF;

  l_pqp_contract_table_id := g_pqp_contract_table_id;
  l_annual_hours_col_id   := g_annual_hours_col_id;
  l_period_divisor_col_id := g_period_divisor_col_id;

  IF g_is_concurrent_program_run THEN
    g_output_file_records(g_output_file_records.LAST).effective_date := p_effective_date;
    g_output_file_records(g_output_file_records.LAST).change_in := 'Initial';
  END IF;

  -- force a cache reload of this check as
  -- we cannot be sure that the underlying assignment
  -- data has not changed between two calls to
  -- update_fte_for_assignment when being invoked
  -- from forms

  IF NOT g_is_concurrent_program_run
  THEN

    l_fte_exists := chk_fte_exists(p_assignment_id,TRUE);

    l_earliest_possible_FTE_date :=
      get_earliest_possible_FTE_date(p_assignment_id,TRUE);
    -- if earliest possible date is null
    -- it implies
    -- a) it will not be possible to calculate FTE for this asg
    -- b) he has either never had any normal hours recorded against his asg
    -- c) or he has never had any contract type on extra details of service
    -- in which case its no use processing further
    -- if however there do exist an FTE row they have either been manually created
    -- or the user has performed an operation such a nulling out the contract type
    -- or a purge which has led to earliest processing date being null
    -- in which case we do want to allow FTE processing to take place, error
    -- (converted to message) and allow the overall operation to succeeed
    -- so that the user is aware that his action has resulted in
    -- the FTE not being changed

      IF l_fte_exists
      THEN
        IF p_effective_date IS NULL -- e.g. when a purge takes place in online mode
        THEN
          IF l_earliest_possible_FTE_date IS NULL THEN
            l_effective_date := HR_GBNICAR.NICAR_SESSION_DATE(0);
          ELSE
            l_effective_date := l_earliest_possible_FTE_date;
          END IF;
          -- if at this point l_effective_date is still null
          -- it implies
        ELSE
          l_effective_date := p_effective_date;
        END IF;
          -- if p_effective_date is > earliest processing date
          -- the expectation that processing will complet normally
          -- if the p_eff_date < earliest process date
          -- then the processing will fail to update an FTE
          -- unlike a conc pgm rum we do not change the processing
          -- date at this stage in order to allow it to proceed and
          -- error
      ELSE
        IF l_earliest_possible_FTE_date < p_effective_date THEN
          l_effective_date := l_earliest_possible_FTE_date;
        ELSE
          l_effective_date := p_effective_date; -- only because its not conc run
        END IF;
        -- it is possible at this stage for earliest processing to be null
        -- in which case the subsequent check for l_eff being not null
        -- will prevent any processing from taking place and raising no errors
        -- which is ok becase that should only happen when an employee
        -- has never had any FTE and neither has sufficent data for FTE to
        -- be calculated
      END IF; -- IF NOT l_fte_exists THEN

  ELSE

    l_effective_date := p_effective_date;

  END IF; -- IF NOT g_is_concurrent_program_run

IF g_debug THEN
  debug('l_effective_date:'||fnd_date.date_to_displaydate(l_effective_date));
END IF;

IF l_effective_date IS NOT NULL
THEN

  -- create the first FTE row
  calculate_and_store_fte
    (p_assignment_id
    ,l_effective_date
    );

  --  iterate thru relevant dates for assignment normal hours and contract changes
  l_last_change_date := hr_api.g_eot;
  FOR this_change IN csr_get_relevant_change_dates
    (p_assignment_id                              => p_assignment_id
    ,p_min_effective_start_date                   => l_effective_date
    ,p_pqp_contract_table_id                      => l_pqp_contract_table_id
    ,p_annual_hours_col_id                        => l_annual_hours_col_id
    ,p_period_divisor_col_id                      => l_period_divisor_col_id
    )
  LOOP

    l_relevant_change := this_change;

    IF g_is_concurrent_program_run THEN
      IF g_debug THEN
       debug('In the Debug -1: ');
      END IF;
      g_output_file_records(g_output_file_records.LAST+1).assignment_id := p_assignment_id;
      g_output_file_records(g_output_file_records.LAST).employee_number :=
        g_output_file_records(g_output_file_records.LAST-1).employee_number;
      g_output_file_records(g_output_file_records.LAST).assignment_number :=
        g_output_file_records(g_output_file_records.LAST-1).assignment_number;
      g_output_file_records(g_output_file_records.LAST).effective_date := this_change.effective_start_date;
      g_output_file_records(g_output_file_records.LAST).change_in := this_change.change_type;
    END IF;


    IF g_debug THEN
      debug('this_change.effective_start_date:'||this_change.effective_start_date);
      debug('this_change.change_type:'||this_change.change_type);
      debug('l_last_change_date:'||l_last_change_date);
    END IF;

    IF this_change.effective_start_date <> l_last_change_date THEN
      IF g_debug THEN
        debug('In the Debug -2 This_change.effective_start_date:-'||this_change.effective_start_date);
        debug('In the Debug -3 l_last_change_date:-'||l_last_change_date);
      END IF;
      l_last_change_date := this_change.effective_start_date;
      calculate_and_store_fte
        (p_assignment_id
        ,this_change.effective_start_date
        );
    ELSE
     BEGIN -- For bug 5531482
       IF g_debug THEN
        hr_utility.set_location('In the Debug -4 This_change.effective_start_date:-'||this_change.effective_start_date,70);
        hr_utility.set_location('In the Debug -5 l_last_change_date:-'||l_last_change_date,80);
       END IF;
        g_output_file_records(g_output_file_records.LAST) :=
        g_output_file_records(g_output_file_records.LAST-1);
        g_output_file_records(g_output_file_records.LAST).change_in :=
        this_change.change_type;
        g_output_file_records(g_output_file_records.LAST).status :=
        'Processed(Skipped)';
        g_output_file_records(g_output_file_records.LAST).message :=
        'Processing was skipped as this change effective the same date as the previous record.';
     EXCEPTION
      when VALUE_ERROR then
         hr_utility.set_location('In the Debug -6 VALUE_ERROR',90);
         null;
      when others then
         hr_utility.set_location('In the Debug -7 OTHERS',100);
         hr_utility.set_location('In the Debug -8:'||sqlerrm,110);
         Raise;
      END; -- End For bug 5531482
   END IF;
  END LOOP; --FOR this_change IN csr_get_relevant_change_dates

END IF; -- IF l_effective_date IS NOT NULL

END IF; -- IF l_status = 'I' THEN

IF g_debug THEN
  debug('l_status:'||l_status);
  debug_exit(l_proc_name);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END update_fte_for_assignment;
--
/* =====================================================================
   Name    : Update_FTE_For Assignment_Set
   Purpose : Update multiple FTE values. Normally called as a
             concurrent process.
   Returns :
   ---------------------------------------------------------------------*/
PROCEDURE update_fte_for_assignment_set
  (ERRBUF                        OUT NOCOPY VARCHAR2
  ,RETCODE                       OUT NOCOPY NUMBER
  ,p_contract_type               IN  VARCHAR2
  ,p_payroll_id                  IN  NUMBER
  ,p_calculation_date            IN  VARCHAR2
  ,p_trace                       IN  VARCHAR2
  )
IS

l_proc_step                    NUMBER(20,10):=0;
l_proc_name                    VARCHAR2(61) :=
  g_package_name||'update_fte_for_assignment_set';

l_calculation_date             DATE;
l_error                        VARCHAR2(2000);
l_message                      VARCHAR2(240);
l_full_name                    VARCHAR2(80);
l_business_group_id            per_all_assignments_f.business_group_id%TYPE;
l_contract_type                pay_user_rows_f.row_low_range_or_name%TYPE;
i                              BINARY_INTEGER;

CURSOR csr_payroll_assignment_set
  (p_payroll_id                   NUMBER
  ,p_effective_date               DATE
  )
IS
SELECT DISTINCT asg.assignment_id
FROM   per_all_assignments_f asg
WHERE  asg.payroll_id = p_payroll_id
  AND  ( p_effective_date
           BETWEEN asg.effective_start_date AND asg.effective_end_date
        OR
         asg.effective_start_date > p_effective_date
       );


CURSOR csr_contract_assignment_set
  (p_business_group_id            NUMBER
  ,p_contract_type                VARCHAR2
  ,p_effective_date               DATE
  )
IS
SELECT DISTINCT aat.assignment_id
FROM   pqp_assignment_attributes_f aat
WHERE  aat.business_group_id = p_business_group_id
  AND  aat.contract_type = NVL(p_contract_type,aat.contract_type)
  AND  ( p_effective_date
           BETWEEN aat.effective_start_date AND aat.effective_end_date
        OR
         aat.effective_start_date > p_effective_date
       );


CURSOR csr_payroll_and_contract
  (p_payroll_id                   NUMBER
  ,p_contract_type                VARCHAR2
  ,p_effective_date               DATE
  ) IS
SELECT  DISTINCT asg.assignment_id
FROM    per_all_assignments_f asg,
        pqp_assignment_attributes_f aat
WHERE   asg.payroll_id    = p_payroll_id
  AND   ( p_effective_date
           BETWEEN asg.effective_start_date AND asg.effective_end_date
        OR
         asg.effective_start_date > p_effective_date
        )
  AND   aat.assignment_id = asg.assignment_id
  AND   aat.contract_type = p_contract_type
  AND   ( p_effective_date
           BETWEEN aat.effective_start_date AND aat.effective_end_date
        OR
         aat.effective_start_date > p_effective_date
        );

CURSOR csr_person_details
  (p_assignment_id                 NUMBER)
IS
SELECT per.full_name
FROM   per_all_people_f per,
       per_all_assignments_f asg
WHERE  asg.person_id = per.person_id
  AND  asg.assignment_id = p_assignment_id
  AND  l_calculation_date
       BETWEEN asg.effective_start_date AND asg.effective_end_date
  AND  l_calculation_date
       BETWEEN per.effective_start_date AND per.effective_end_date;

l_assignment                   t_asg_details;
l_FTE_processing_start_date    DATE;
l_errored                      BINARY_INTEGER:=0;
l_processed                    BINARY_INTEGER:=0;
l_log_string                   VARCHAR2(4000);

BEGIN -- update_fte_for_assignment_set

  g_is_concurrent_program_run := TRUE;

  g_debug := hr_utility.debug_enabled;

  IF p_trace = 'Y' THEN
    g_debug := TRUE;
  END IF;

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_payroll_id:'||p_payroll_id);
    debug('p_contract_type:'||p_contract_type);
    debug('p_calculation_date_txt:'||p_calculation_date);
  END IF;

  fnd_file.put_line
    (fnd_file.log
    ,'Calculate FTE For Assignments - '||
     fnd_date.date_to_displaydate(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  -- Set the standard concurrent program out paramters
  ERRBUF:= NULL;
  RETCODE:= 0;

  -- In concurrent programs, the date is passed in as a string in canonical format. We must convert this
  -- to a date

  --l_calculation_date := to_date(substr(p_calculation_date, 1, 10), 'YYYY/MM/DD');
  l_calculation_date := fnd_date.canonical_to_date(p_calculation_date);

  -- as business group id is not passed as a parameter use the fnd_global value
  -- this implies that concurrent process must be run from within apps
  -- and cannot be run from sql unless an explicit apps initialization is done
  -- as a prereq step.
  -- we donot want to add the parameter as that implies a conc spec change
  -- which in turn will cause the patch size for this change to increase
  -- as it will force us to include/pre-req several
  l_business_group_id := fnd_global.per_business_group_id;

  IF g_debug THEN
    debug('l_business_group_id:'||l_business_group_id);
  END IF;

  l_log_string := NULL;
  SELECT name
  INTO   l_log_string
  FROM   per_business_groups_perf
  WHERE  business_group_id = l_business_group_id;

  fnd_file.put_line
    (fnd_file.log
    ,RPAD('Business Group',30,' ')||':'||l_log_string
    );

  l_log_string := NULL;
  IF p_payroll_id IS NOT NULL
  THEN
    SELECT a.payroll_name
    INTO   l_log_string
    FROM   pay_all_payrolls_f a
    WHERE  a.payroll_id = p_payroll_id
      AND  effective_start_date =
             (SELECT MAX(b.effective_start_date)
              FROM   pay_all_payrolls_f b
              WHERE  b.payroll_id = a.payroll_id
              );
  END IF;

  fnd_file.put_line
      (fnd_file.log
      ,RPAD('Payroll Name',30,' ')||':'||l_log_string
      );

  fnd_file.put_line
    (fnd_file.log
    ,RPAD('Contract Type',30,' ')||':'||p_contract_type
    );

  fnd_file.put_line
    (fnd_file.log
    ,RPAD('Effective On or After',30,' ')||':'||fnd_date.date_to_displaydate(l_calculation_date)
    );


/*  if P_Payroll_ID IS NULL AND P_Contract_Type IS NULL then
    fnd_message.set_name('PQP', 'PQP_230686_FTE_PROG_FAIL_PARAM');
    l_message := fnd_message.get;
    fnd_file.put_line(fnd_file.log, l_message);
    fnd_message.raise_error;
*/

  IF (p_contract_type IS NOT NULL AND p_payroll_id IS NOT NULL)
  THEN

    l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    OPEN  csr_payroll_and_contract
      (p_payroll_id
      ,p_contract_type
      ,l_calculation_date
      );
    FETCH csr_payroll_and_contract BULK COLLECT INTO l_assignment;
    CLOSE csr_payroll_and_contract;

  ELSIF (p_contract_type IS NULL AND p_payroll_id IS NOT NULL)
  THEN

    l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    OPEN csr_payroll_assignment_set(p_payroll_id,l_calculation_date);
    FETCH csr_payroll_assignment_set BULK COLLECT INTO l_assignment;
    CLOSE csr_payroll_assignment_set;

  ELSE

    l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    --fetch data if both the contract type and payroll are null
    --or only when the contract type is not null
    OPEN  csr_contract_assignment_set
      (l_business_group_id
      ,p_contract_type
      ,l_calculation_date
      );
    FETCH csr_contract_assignment_set BULK COLLECT INTO l_assignment;
    CLOSE csr_contract_assignment_set;

  END IF;

  l_proc_step := 30;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;


  DELETE FROM fnd_sessions WHERE session_id = USERENV('sessionid');
  INSERT INTO fnd_sessions
    (session_id
    ,effective_date
    )
  VALUES
    (USERENV('sessionid')
    ,l_calculation_date
    );

  l_proc_step := 40;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  fnd_file.put_line
    (fnd_file.log
    ,'Number of Assignments To Process: '||l_assignment.COUNT
    );


  fnd_file.put_line
    (fnd_file.log
    ,'Error Log:'
    );


    i := l_assignment.FIRST();

    WHILE i IS NOT NULL
    LOOP

      IF i = l_assignment.FIRST() THEN
        fnd_file.put_line
        (fnd_file.output
        ,RPAD('Status',30,' ')||g_column_separator||
         RPAD('Employee Number',20,' ')||g_column_separator||
         RPAD('Assignment_Number',30,' ')||g_column_separator||
         RPAD('Effective Date',15,' ')||g_column_separator||
         RPAD('Change In',30,' ')||g_column_separator||
         RPAD('FTE - Before Change',20,' ')||g_column_separator||
         RPAD('Change Type',15,' ')||g_column_separator||
         RPAD('FTE - After Change',20,' ')||g_column_separator||
         RPAD('Normal Hours',15,' ')||g_column_separator||
         RPAD('Frequency',10,' ')||g_column_separator||
         RPAD('Contract Type',30,' ')||g_column_separator||
         RPAD('Annual Hours',15,' ')||g_column_separator||
         RPAD('Period Divisor',15,' ')||g_column_separator||
         RPAD('Message',255,' ')
        );

        fnd_file.put_line
        (fnd_file.output
        ,RPAD('-',30,'-')||g_column_separator||
         RPAD('-',20,'-')||g_column_separator||
         RPAD('-',30,'-')||g_column_separator||
         RPAD('-',15,'-')||g_column_separator||
         RPAD('-',30,'-')||g_column_separator||
         RPAD('-',20,'-')||g_column_separator||
         RPAD('-',15,'-')||g_column_separator||
         RPAD('-',20,'-')||g_column_separator||
         RPAD('-',15,'-')||g_column_separator||
         RPAD('-',10,'-')||g_column_separator||
         RPAD('-',30,'-')||g_column_separator||
         RPAD('-',15,'-')||g_column_separator||
         RPAD('-',15,'-')||g_column_separator||
         RPAD('-',255,'-')
        );

      END IF;

        l_proc_step := 40+i/100000;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
        END IF;

      --
      --
      -- Update assignments within new block. This way, if one
      -- assignment should error, we can still process the rest,
      -- whilst writing the error details to the concurrent
      -- manager log, if available.
      --

      g_output_file_records.DELETE;

      IF g_debug THEN
        debug('l_assignment(i):'||l_assignment(i));
      END IF;

      g_output_file_records(i).assignment_id:= l_assignment(i);

      l_proc_step := 45+i/100000;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      BEGIN

      -- if assignment has duplicate FTE rows, do a zap on both and then call
      -- get relevant date, it will return earliest possible
      -- not implemented above comment

      l_proc_step := 50+(i/100000);
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      l_FTE_processing_start_date :=
        get_FTE_processing_start_date
         (p_assignment_id  => l_assignment(i)
         ,p_effective_date => l_calculation_date
         );

      l_proc_step := 60+(i/100000);
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      g_output_file_records(i).effective_date:= l_FTE_processing_start_date;

      SELECT employee_number
      INTO   g_output_file_records(i).employee_number
      FROM   per_all_people_f a
      WHERE  a.person_id =
               (SELECT asg.person_id
                FROM   per_all_assignments_f asg
                WHERE  asg.assignment_id = l_assignment(i)
                  AND  ROWNUM < 2
                )
        AND  effective_start_date =
               (SELECT MAX(b.effective_start_date)
                FROM   per_all_people_f b
                WHERE  b.person_id = a.person_id
               );

      l_proc_step := 70+(i/100000);
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      SELECT assignment_number
      INTO   g_output_file_records(i).assignment_number
      FROM   per_all_assignments_f a
      WHERE  a.assignment_id = l_assignment(i)
        AND  a.effective_start_date =
               (SELECT MAX(b.effective_start_date)
                FROM   per_all_assignments_f b
                WHERE  b.assignment_id = a.assignment_id
               );


      l_proc_step := 80+(i/100000);
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      IF l_FTE_processing_start_date IS NOT NULL
      THEN

      update_fte_for_assignment
        (p_assignment_id  => l_assignment(i)
        ,p_effective_date => l_FTE_processing_start_date
        );

      ELSE
        g_output_file_records(i).status := 'Processed(Warning)';
        g_output_file_records(i).message :=
         'This person has no assignment normal hours or '||
         'an extra details of service contract type at any point in time.';
      END IF;

      l_proc_step := 90+(i/100000);
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      write_output_file_records;

      l_proc_step := 100+(i/100000);
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      EXCEPTION
        WHEN OTHERS THEN

          clear_cache;

          IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
            debug_others(l_proc_name,l_proc_step);
            IF g_debug THEN
              debug('Leaving: '||l_proc_name,-999);
            END IF;
            g_output_file_records(g_output_file_records.LAST).status := 'Errored(Fatal)';
            g_output_file_records(g_output_file_records.LAST).message :=
              l_proc_name||'{'||
              fnd_number.number_to_canonical(l_proc_step)|| '}: '||
              SUBSTRB(SQLERRM, 1, 2000);
          ELSE
            g_output_file_records(g_output_file_records.LAST).status := 'Errored';
            g_output_file_records(g_output_file_records.LAST).message := SQLCODE||':'||SQLERRM;
          END IF;

          l_errored := l_errored + 1;

          IF l_errored = 1 THEN

          fnd_file.put_line
            (fnd_file.log
            ,RPAD('Employee Number',15,' ')||g_column_separator||RPAD('Error Message',255,' ')
            );

          fnd_file.put_line
            (fnd_file.log
            ,RPAD('-',15,'-')||g_column_separator||RPAD('-',255,'-')
            );

          END IF;

          fnd_file.put_line
            (fnd_file.log
            ,RPAD(NVL(g_output_file_records(g_output_file_records.LAST).employee_number
                     ,'Asg_Id:'||l_assignment(i)
                     )
                 ,15,' '
                 )||g_column_separator||
             RPAD(g_output_file_records(g_output_file_records.LAST).message,255,' ')
            );

          write_output_file_records;
          g_output_file_records.DELETE; -- do not include in clear cache

      END;

      l_processed := l_processed + 1;
      i := l_assignment.NEXT(i);

      IF g_debug THEN
        debug('NEXT i:'||i);
      END IF;

    END LOOP;

  DELETE FROM fnd_sessions WHERE session_id = USERENV('sessionid');

  ERRBUF := null;
  RETCODE:= 0;

  fnd_file.put_line
    (fnd_file.log
    ,'Number of Assignments Processed:'||l_processed
    );

  fnd_file.put_line
    (fnd_file.log
    ,'Number of Assignments Errored:'||l_errored
    );


  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END update_fte_for_assignment_set;

END pqp_fte_utilities;

/
