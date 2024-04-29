--------------------------------------------------------
--  DDL for Package Body PQP_UPDATE_WORK_PATTERN_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_UPDATE_WORK_PATTERN_TABLE" AS
/* $Header: pquwprow.pkb 120.1 2005/08/24 05:01 akarmaka noship $ */

  g_package_name     VARCHAR2(61) := 'pqp_update_work_pattern_table.' ;
  g_debug            BOOLEAN ;
  g_legislation_code VARCHAR2(30) ;
  g_table_name       pay_user_tables.user_table_name%TYPE
                        :='PQP_COMPANY_WORK_PATTERNS' ;
  g_row_ids          t_row_ids ;

-- to cache the row_ids/name of the 3 seeded rows
-- 1. 'Average Working Days Per Week'
-- 2. 'Total Number of Days'
-- 3. 'Number of Working Days'
  g_row_names_seed             t_row_names ;
  g_row_ids_seed               t_row_details ;


--
--
--
  PROCEDURE debug(
    p_trace_message             IN       VARCHAR2
   ,p_trace_location            IN       NUMBER    DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug(p_trace_message, p_trace_location) ;
  END debug;
--
--
--
  PROCEDURE debug(p_trace_number IN NUMBER)
  IS
  BEGIN
    pqp_utilities.debug(p_trace_number) ;
  END debug;

--
--
--
  PROCEDURE debug(p_trace_date IN DATE)
  IS
  BEGIN
    pqp_utilities.debug(p_trace_date) ;
  END debug;

--
--
--
  PROCEDURE debug_enter(
    p_proc_name                 IN       VARCHAR2
   ,p_trace_on                  IN       VARCHAR2 DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug_enter(p_proc_name, p_trace_on) ;
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
    pqp_utilities.debug_exit(p_proc_name, p_trace_off) ;
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
    pqp_utilities.debug_others(p_proc_name, p_proc_step) ;
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
    pqp_utilities.check_error_code(p_error_code, p_error_message) ;
  END;
--
--
--
  PROCEDURE clear_cache
  IS
  BEGIN
    NULL;
  END;
--
--
--

PROCEDURE update_working_days_in_week (
         errbuf                OUT NOCOPY  VARCHAR2
        ,retcode               OUT NOCOPY  NUMBER
        ,p_column_name         IN  VARCHAR2
        ,p_business_group_id   IN  NUMBER
        ,p_overwrite_if_exists IN  VARCHAR2
  )
IS


CURSOR csr_get_table_id (
       p_table_name        IN VARCHAR2
      ,p_legislation_code  IN VARCHAR2
      ,p_business_group_id IN NUMBER )
IS
SELECT user_table_id
FROM   pay_user_tables
WHERE  user_table_name      = p_table_name
  AND  ( legislation_code   = p_legislation_code
       OR business_group_id = p_business_group_id ) ;


CURSOR csr_user_columns (
       p_user_table_id     IN NUMBER
      ,p_column_name       IN VARCHAR2
      ,p_business_group_id IN NUMBER )
IS
SELECT puc.user_column_name user_column_name
      ,puc.user_column_id user_column_id
FROM   pay_user_columns puc
WHERE  puc.user_table_id       = p_user_table_id
  AND (puc.business_group_id   = p_business_group_id
        OR puc.legislation_code = g_legislation_code )
  AND  ( puc.user_column_name LIKE p_column_name
         OR p_column_name IS NULL );


CURSOR csr_get_row_id (
       p_user_table_id     IN NUMBER
      ,p_user_row_name     IN VARCHAR2
      ,p_business_group_id IN NUMBER
      ,p_legislation_code  IN VARCHAR2 )
IS
SELECT pur.USER_ROW_ID
      ,pur.effective_start_date
      ,pur.effective_end_date
FROM  pay_user_rows_f pur
WHERE user_table_id             = p_user_table_id
  AND row_low_range_or_name     = p_user_row_name
  AND ( pur.business_group_id   = p_business_group_id
        OR pur.legislation_code = p_legislation_code )
  ;


CURSOR csr_get_day01_eff_date (
       p_user_column_id           IN        NUMBER
      ,p_user_row_id              IN        NUMBER
      ,p_business_group_id        IN        NUMBER
     ) IS
SELECT puci.effective_start_date effective_start_date
      ,puci.effective_end_date effective_end_date
FROM   pay_user_column_instances_f puci
WHERE  ( puci.business_group_id   = p_business_group_id
        OR puci.legislation_code = g_legislation_code )
  AND  puci.user_column_id      = p_user_column_id
  AND  puci.user_row_id         = p_user_row_id ;


  l_user_table_id            pay_user_tables.user_table_id%TYPE ;
  l_row_effective_start_date DATE ;
  l_row_effective_end_date   DATE ;

  l_row_values               t_row_values ; --Collection to keep values of 3 rows.

  idx                        NUMBER  := 0 ; -- Index for g_row_ids_seed and g_row_names_seed
                                                      -- and l_row_values collections
  l_proc_step                NUMBER(20,10);
  l_proc_name                VARCHAR2(200) := g_package_name||
                              'update_working_days_in_week';


  l_day01_row_id             pay_user_rows_f.user_row_id%TYPE ;
  l_day01_details            csr_get_row_id%ROWTYPE ;

  l_day01_eff_start_date     date ;
  l_day01_eff_end_date       date ;

BEGIN

   g_debug := hr_utility.debug_enabled ;

   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_column_name:'||p_column_name);
    debug('p_business_group_id:'||p_business_group_id);
    debug('g_legislation_code:'||g_legislation_code);
  END IF ;

   --Get the legislation code
  g_legislation_code  := pqp_utilities.pqp_get_legislation_code(
                           p_business_group_id => p_business_group_id);



-- Cache the names of the rows to be used later.
  IF g_row_names_seed.COUNT = 0 THEN

    l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
    --Populate the collection with the seeded row names.
    g_row_names_seed(1) := 'Average Working Days Per Week' ;
    g_row_names_seed(2) := 'Total Number of Days' ;
    g_row_names_seed(3) := 'Number of Working Days' ;

  ELSE  -- IF g_row_names_seed.COUNT = 0 THEN

    l_proc_step := 25 ;
    IF g_debug THEN
        debug(l_proc_name,l_proc_step) ;
	debug('Row Names already cached') ;
    END IF;
  END IF ;  --IF g_row_names_seed.COUNT = 0 THEN

  l_proc_step := 30;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

--Get table ID
  OPEN  csr_get_table_id ( p_table_name        => g_table_name
                          ,p_legislation_code  => g_legislation_code
                          ,p_business_group_id => p_business_group_id );
  FETCH csr_get_table_id INTO l_user_table_id ;
  CLOSE csr_get_table_id ;
  IF g_debug THEN
    debug('l_user_table_id :   '||l_user_table_id);
  END IF;

-- cache the row ID's for the 3 rows seeded to keep the WP information
-- that is being used all over.
  l_proc_step := 40;
  IF g_debug THEN
    debug('g_row_ids_seed.COUNT  '|| to_char(g_row_ids_seed.COUNT));
  END IF;
  IF g_row_ids_seed.COUNT = 0 THEN

    idx := g_row_names_seed.FIRST;

    IF g_debug THEN
        debug(l_proc_name,l_proc_step) ;
	debug_enter('WHILE idx IS NOT NULL LOOP') ;
    END IF ;

    WHILE idx IS NOT NULL LOOP

      l_proc_step := 40 + idx/10000;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
	debug('idx:'||idx);
      END IF ;

      OPEN csr_get_row_id ( p_user_table_id     => l_user_table_id
                           ,p_user_row_name     => g_row_names_seed(idx)
	                   ,p_business_group_id => p_business_group_id
		           ,p_legislation_code  => g_legislation_code ) ;

      FETCH csr_get_row_id INTO g_row_ids_seed(idx).user_row_id
                               ,g_row_ids_seed(idx).effective_start_date
			       ,g_row_ids_seed(idx).effective_end_date ;
      CLOSE csr_get_row_id ;

      l_proc_step := 50 + idx/10000;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
	debug('user_row_id:'||g_row_ids_seed(idx).user_row_id);
	debug('effective_start_date:'||g_row_ids_seed(idx).effective_start_date);
	debug('effective_end_date:'||g_row_ids_seed(idx).effective_end_date);
      END IF;

      idx := g_row_names_seed.NEXT(idx) ;

    END LOOP ; -- WHILE idx IS NOT NULL LOOP

    l_proc_step :=  55 ;
    IF g_debug THEN
        debug(l_proc_name,l_proc_step) ;
	debug_exit('WHILE idx IS NOT NULL LOOP') ;
    END IF ;

  ELSE  -- IF g_row_ids_seed.COUNT = 0 THEN
    IF g_debug THEN
        debug(l_proc_name,l_proc_step) ;
	debug('Row IDs already cached') ;
    END IF;
  END IF ; -- IF g_row_ids_seed.COUNT = 0 THEN


     -- The effective date for the calculation of Average Days per week is
     -- the date "Day 01" value is defined in that work pattern.
     -- below code gets the row id for the Day 01

-- here the effective date should be the efective date of the value set for 'Day 01'

      OPEN csr_get_row_id ( p_user_table_id     => l_user_table_id
                           ,p_user_row_name     => 'Day 01'
	                   ,p_business_group_id => p_business_group_id
		           ,p_legislation_code  => g_legislation_code ) ;
      FETCH csr_get_row_id INTO l_day01_details ;
      l_day01_row_id := l_day01_details.user_row_id ;
      CLOSE csr_get_row_id ;



-- get the column id for all the work patterns
-- get all the WP and process them one by one
-- calculate the vlaue for each row
-- check if the row already exists
-- if yes, check if it qualifies for updation, then update it
-- if no, insert a new row.

  l_proc_step := 70;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug_enter('FOR l_user_columns IN csr_user_columns') ;
  END IF;

  FOR l_user_columns IN csr_user_columns(p_user_table_id     => l_user_table_id
                                        ,p_column_name       => p_column_name
					,p_business_group_id => p_business_group_id )
  LOOP
    l_proc_step := 72;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('l_user_columns.user_column_id:'||l_user_columns.user_column_id);
      debug('l_user_columns.user_column_name:'||l_user_columns.user_column_name);
      debug('l_user_table_id:'||l_user_table_id);
      debug('p_business_group_id:'||p_business_group_id);
    END IF;


    -- for the 'Day 01' get the effective date of value defined
    -- and pass that down to calculate Average Number of Days per week
    OPEN csr_get_day01_eff_date (
               p_user_column_id    => l_user_columns.user_column_id
              ,p_user_row_id       => l_day01_row_id
              ,p_business_group_id => p_business_group_id ) ;

    FETCH csr_get_day01_eff_date INTO l_day01_eff_start_date,l_day01_eff_end_date ;
    CLOSE csr_get_day01_eff_date ;

--Calculate the Values to update
  l_row_values(1) := get_avg_working_days_in_week (
                         p_business_group_id          => p_business_group_id
                        ,p_effective_date             => l_day01_eff_start_date
                        ,p_user_column_id             => l_user_columns.user_column_id
                        ,p_user_table_id              => l_user_table_id
                        ,p_total_days_defined         => l_row_values(2)    --OUT -- total_days_defined
                        ,p_total_working_days_defined => l_row_values(3) ) ;--OUT -- total_working_days_defined ) ;

    l_proc_step := 110;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('avg_work_days_in_week:'||l_row_values(1));
      debug('total_days_defined:'||l_row_values(2));
      debug('total_working_days_defined:'||l_row_values(3));
    END IF ;

 -- update/insert value for seeded rows one by one
 -- in the table pay_user_column_instances_f.

 -- If the value for the said column already exists and
 -- the user has not updated the row manually, then
 -- update the value, else leave it as it is.
 -- but if the value does not exists for the column,
 -- insert a new row in the table pay_user_column_instances_f.

 -- if user has explicitly given the name of the WP, update the row
 -- even if it is updated by user manually.

    --FOR idx IN 1..3 LOOP
    idx := g_row_names_seed.FIRST;
    l_proc_step := 120;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug_enter('WHILE idx IS NOT NULL LOOP') ;
    END IF;

    WHILE idx IS NOT NULL LOOP

      l_proc_step := l_proc_step + idx/10000;
      IF g_debug THEN
        debug_enter('update_insert for loop');
        debug(l_proc_name,l_proc_step);
        debug('g_row_names_seed:'||g_row_names_seed(idx));
        debug('g_row_ids_seed:'||g_row_ids_seed(idx).user_row_id);
        debug('l_row_values:'||l_row_values(idx));
      END IF ;

      update_insert_row(
         p_user_column_id           => l_user_columns.user_column_id
        ,p_user_row_id              => g_row_ids_seed(idx).user_row_id
	,p_effective_date           => l_day01_eff_start_date
	,p_row_effective_start_date => l_day01_eff_start_date
        ,p_row_effective_end_date   => l_day01_eff_end_date
	,p_business_group_id        => p_business_group_id
	,p_value_to_update          => l_row_values(idx)
	,p_overwrite_if_exists      => p_overwrite_if_exists
         ) ;

      IF g_debug THEN
        debug_exit('update_insert for loop');
      END IF;

      idx := g_row_names_seed.NEXT(idx) ;
    END LOOP ; -- WHILE idx IS NOT NULL LOOP

    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug_exit('WHILE idx IS NOT NULL LOOP') ;
    END IF;

 END LOOP ; --FOR l_user_columns IN csr_user_columns
    l_proc_step := 160;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug_exit('FOR l_user_columns IN csr_user_columns') ;
      debug_exit(l_proc_name) ;
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
      clear_cache;
      errbuf   := SQLERRM;
      retcode  := SQLCODE;
      IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
        debug_others(l_proc_name,l_proc_step);
        IF g_debug THEN
          debug('Leaving: '||l_proc_name,-999);
        END IF;
        fnd_message.raise_error;
      ELSE
        RAISE;
      END IF;

END update_working_days_in_week ;

-----------------------------------------------------------------------------------------
-- Function to calculate the values for
-- 1. "Average Working Days Per Week"  -- As Return Value
-- 2. "Total Number of Days"           -- As OUT Parameter p_total_days_defined
-- 3. "TNumber of Working Days"        -- As OUT Parameter p_total_working_days_defined

FUNCTION get_avg_working_days_in_week (
         p_business_group_id          IN         NUMBER
        ,p_effective_date             IN         DATE
        ,p_user_column_id             IN         pay_user_columns.user_column_id%TYPE
        ,p_user_table_id              IN         pay_user_tables.user_table_id%TYPE
        ,p_total_days_defined         OUT NOCOPY NUMBER
        ,p_total_working_days_defined OUT NOCOPY NUMBER
 ) RETURN NUMBER IS


CURSOR csr_get_row_ids IS
SELECT user_row_id
FROM   pay_user_rows_f pur
WHERE  user_table_id   = p_user_table_id
  AND  row_low_range_or_name LIKE 'Day __'   -- this is hard coded as it is the seeded data.
  AND  p_effective_date BETWEEN pur.effective_start_date
                            AND pur.effective_end_date ;


   l_no_of_days_defined         NUMBER := 0 ;
   l_no_of_working_days         NUMBER := 0 ;
   l_no_of_working_days_in_week NUMBER := 0 ;


   l_value                    NUMBER ;
   l_row_id                   VARCHAR2(200) ;
   l_user_column_instance_id  pay_user_column_instances_f.user_column_instance_id%TYPE ;
   idx                        NUMBER := 1 ;  --index for the rows

   l_proc_step            NUMBER(20,10);
   l_proc_name            VARCHAR2(200) := g_package_name||
                                   'get_avg_working_days_in_week';
   l_effective_start_date DATE;
   l_effective_end_date   DATE;

BEGIN

  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_business_group_id:'||p_business_group_id) ;
    debug('p_effective_date:'||p_effective_date) ;
    debug('p_user_column_id:'||p_user_column_id) ;
    debug('p_user_table_id:'||p_user_table_id) ;
  END IF ;

  -- Cache the rows into a collection

  IF g_row_ids.COUNT = 0 THEN
    l_proc_step := 75;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF ;

    -- Get all the row Ids into the collection g_row_ids
    OPEN csr_get_row_ids ;
    FETCH csr_get_row_ids BULK COLLECT INTO g_row_ids ;
    CLOSE csr_get_row_ids ;

    l_proc_step := 80 ;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
  ELSE
    l_proc_step := 82;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('Row IDs already cached') ;
    END IF ;
  END IF ;  --IF g_row_ids.COUNT = 0 THEN

  idx := g_row_ids.FIRST ;

  l_proc_step := 85;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug(' index :'||idx);
    debug_enter('WHILE idx IS NOT NULL LOOP' ) ;
  END IF ;

  WHILE idx IS NOT NULL LOOP
    l_proc_step := 90 + idx/10000 ;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step) ;
      debug('index:'||idx) ;
      debug('count: '|| to_char(g_row_ids.COUNT) );
      debug('g_row_ids(idx):'|| g_row_ids(idx) ) ;
    END IF ;

    OPEN csr_get_value ( p_user_column_id    =>  p_user_column_id
                        ,p_user_row_id       =>  g_row_ids(idx)
                        ,p_effective_date    =>  p_effective_date
	                ,p_business_group_id =>  p_business_group_id
			,p_legislation_code  =>  g_legislation_code ) ;

    FETCH csr_get_value INTO l_value, l_user_column_instance_id, l_row_id
                             ,l_effective_start_date, l_effective_end_date ;

    IF g_debug THEN
      debug('l_value:'||l_value);
      debug('l_user_column_instance_id:'||l_user_column_instance_id);
      debug('l_row_id:'||l_row_id);
    END IF ;

    IF csr_get_value%NOTFOUND THEN
      l_proc_step := 95;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
	debug('csr_get_value in NOT FOUND') ;
      END IF;
    -- commented out the following code as it
    -- was exiting from the loop on the first row_id
    -- which returned no value
    -- details in BUG 4570501

    -- CLOSE csr_get_value ;
    --  EXIT ;
    ELSE --if csr_get_value%NOTFOUND
    -- if cursor returned a row that means the UDT
    -- has a row value defined for Work Pattern Column
    -- hence, increment the defined days count.
    l_no_of_days_defined := l_no_of_days_defined + 1 ;
    END IF;
    CLOSE csr_get_value ;



    IF NVL(l_value,0) > 0 THEN
      l_no_of_working_days := l_no_of_working_days + 1 ;
    END IF ;

    idx := g_row_ids.NEXT(idx) ;
    -- reset the value for next iteration
    l_value :=NULL;


    l_proc_step := 100 + idx/10000;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('index:'||idx);
      debug('l_no_of_days_defined:'||l_no_of_days_defined);
      debug('l_no_of_working_days:'||l_no_of_working_days);
    END IF;

  END LOOP ; --WHILE idx IS NOT NULL LOOP

  l_proc_step := 102;
  IF g_debug THEN
    debug_exit('WHILE idx IS NOT NULL LOOP') ;
    debug(l_proc_name,l_proc_step);
    debug(' l_no_of_working_days_in_week :'||l_no_of_working_days_in_week);
    debug(' l_no_of_working_days :'||l_no_of_working_days);
    debug(' l_no_of_days_defined :'||l_no_of_days_defined);
  END IF;

  IF l_no_of_days_defined > 0 THEN
    l_no_of_working_days_in_week := (l_no_of_working_days * 7 )/
                                     l_no_of_days_defined ;
  END IF;

  p_total_days_defined           := l_no_of_days_defined ;
  p_total_working_days_defined   := l_no_of_working_days ;

  l_proc_step := 105;

  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug(' p_total_days_defined :'||p_total_days_defined);
    debug(' p_total_working_days_defined :'||p_total_working_days_defined);
    debug(' l_no_of_working_days_in_week :'||l_no_of_working_days_in_week);
    debug_exit(l_proc_name);
  END IF;

  RETURN l_no_of_working_days_in_week ;

END get_avg_working_days_in_week ;

 -- Procedure to modularize the process of update/insert of row.
 -- the Procedure checks -

 -- If the value for the said column already exists and
 -- user has passed the WP name explicitly (without wild characters)
 -- then update the row (not done yet)
 -- else if the user has not updated the row manually, then
 -- update the row, else leave it as it is.

 -- but if the value does not exists for the column,
 -- insert a new row in the table pay_user_column_instances_f.

PROCEDURE update_insert_row(
               p_user_column_id            IN NUMBER
              ,p_user_row_id               IN NUMBER
              ,p_effective_date            IN DATE
              ,p_row_effective_start_date  IN DATE
              ,p_row_effective_end_date    IN DATE
              ,p_business_group_id         IN NUMBER
              ,p_value_to_update           IN NUMBER
              ,p_overwrite_if_exists       IN VARCHAR2
	     )IS

  l_value               pay_user_column_instances.value%TYPE ;
  l_row_id              VARCHAR2(200) ;
  l_column_instances_id pay_user_column_instances_f.
                             user_column_instance_id%TYPE ;
  l_return_row_id       VARCHAR2(200) ;
  l_proc_step           NUMBER(20,10);
  l_proc_name           VARCHAR2(200):=g_package_name||'update_insert_row';
  l_effective_start_date DATE ;
  l_effective_end_date   DATE ;

  BEGIN

  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_user_column_id:'||p_user_column_id);
    debug('p_user_row_id:'||p_user_row_id);
    debug('p_effective_date:'||p_effective_date);
    debug('p_row_effective_start_date:'||p_row_effective_start_date);
    debug('p_row_effective_end_date:'||p_row_effective_end_date);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_value_to_update:'||p_value_to_update);
  END IF ;

    l_proc_step := 115;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF ;

    OPEN csr_get_value ( p_user_column_id     => p_user_column_id
                        ,p_user_row_id        => p_user_row_id
                        ,p_effective_date     => p_effective_date
                        ,p_business_group_id  => p_business_group_id
			,p_legislation_code   => g_legislation_code ) ;

    FETCH csr_get_value INTO l_value, l_column_instances_id, l_row_id
                             ,l_effective_start_date,l_effective_end_date ;

    l_proc_step := 120;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('Value that is defined for the row:'||l_value);
      debug('l_column_instances_id:'||l_column_instances_id);
      debug('l_row_id:'||l_row_id);
    END IF ;


    IF csr_get_value%NOTFOUND THEN  -- No rows defined ,

      l_proc_step := 125;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step) ;
        debug('Row is not Defined') ;
      END IF ;

--Insert new Row in the table pay_user_column_instances_f
      pay_user_column_instances_pkg.insert_row(
                        p_rowid			  =>  l_return_row_id             --IN OUT
                       ,p_user_column_instance_id =>  l_column_instances_id       --IN OUT
                       ,p_effective_start_date    =>  p_row_effective_start_date
                       ,p_effective_end_date      =>  p_row_effective_end_date
                       ,p_user_row_id             =>  p_user_row_id
                       ,p_user_column_id          =>  p_user_column_id
                       ,p_business_group_id       =>  p_business_group_id
                       ,p_legislation_code        =>  NULL
                       ,p_legislation_subgroup    =>  NULL
                       ,p_value                   =>  p_value_to_update ) ;

      l_proc_step := 130;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step) ;
        debug('l_return_row_id:' || l_return_row_id);
	debug('l_column_instances_id:' || l_column_instances_id);
      END IF ;

    ELSE  -- IF csr_get_value%NOTFOUND THEN
-- update the existing rows, provided,
-- user has not overridden the data manually
       l_proc_step := 135;
       IF g_debug THEN
         debug(l_proc_name,l_proc_step) ;
       END IF ;


       IF l_value is NULL OR p_overwrite_if_exists = 'Y'  THEN
           IF g_debug THEN
	     debug('Row is Defined But Value is null');
           END IF ;


         l_proc_step := 140;
         IF g_debug THEN
           debug(l_proc_name,l_proc_step) ;
	   debug(' Row is defined, p_value_to_updat:'||p_value_to_update);
         END IF ;

	 -- Call method from pay_user_column_instances_pkg Package to updaet the row.
         pay_user_column_instances_pkg.update_row(
                        p_rowid			  =>  l_row_id
                       ,p_user_column_instance_id =>  l_column_instances_id
                       ,p_effective_start_date    =>  p_row_effective_start_date  -- changed from l_effective_start_date for BUG :4078709
                       ,p_effective_end_date      =>  p_row_effective_end_date    -- changed from l_effective_end_date for BUG :4078709
                       ,p_user_row_id             =>  p_user_row_id
                       ,p_user_column_id          =>  p_user_column_id
                       ,p_business_group_id       =>  p_business_group_id
                       ,p_legislation_code        =>  NULL
                       ,p_legislation_subgroup    =>  NULL
                       ,p_value                   =>  p_value_to_update );

	 l_proc_step := 145;
         IF g_debug THEN
           debug(l_proc_name,l_proc_step) ;
           debug('l_return_row_id:' || l_return_row_id);
	   debug('l_column_instances_id:' || l_column_instances_id);
         END IF ;
       END IF; -- IF l_value is NULL THEN

    END IF ; -- csr_get_value%NOTFOUND THEN

    CLOSE csr_get_value ;
    IF g_debug THEN
      debug_exit(l_proc_name) ;
    END IF ;

 END update_insert_row ;

END pqp_update_work_pattern_table ;

/
