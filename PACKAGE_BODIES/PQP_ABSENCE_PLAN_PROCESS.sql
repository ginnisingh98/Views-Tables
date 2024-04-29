--------------------------------------------------------
--  DDL for Package Body PQP_ABSENCE_PLAN_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ABSENCE_PLAN_PROCESS" AS
/* $Header: pqabproc.pkb 120.0 2005/05/29 01:41:04 appldev noship $ */
--
--
--
  g_package_name                VARCHAR2(31) := 'pqp_absence_plan_process.';
  g_debug                       BOOLEAN:= hr_utility.debug_enabled;

--
--
--
  CURSOR csr_absence_dates(p_absence_attendance_id IN NUMBER)
  IS
    SELECT paa.absence_attendance_id
          ,paa.date_start
          ,paa.date_end
	  ,paa.absence_attendance_type_id
    FROM   per_absence_attendances paa
    WHERE  paa.absence_attendance_id = p_absence_attendance_id;
--
--writting a seperate cursor to get absence type as this is required
-- only when there is a overlap.
  CURSOR csr_absence_type(p_absence_attendance_type_id IN NUMBER)
  IS
    SELECT paat.NAME
    FROM   per_absence_attendance_types paat
    WHERE  paat.absence_attendance_type_id = p_absence_attendance_type_id ;
--
--
--
  PROCEDURE debug(
    p_trace_message             IN       VARCHAR2
   ,p_trace_location            IN       NUMBER DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug(p_trace_message, p_trace_location);
  END debug;

--
--
--
  PROCEDURE debug(p_trace_number IN NUMBER)
  IS
  BEGIN
    pqp_utilities.debug(fnd_number.number_to_canonical(p_trace_number));
  END debug;

--
--
--
  PROCEDURE debug(p_trace_date IN DATE)
  IS
  BEGIN
    pqp_utilities.debug(fnd_date.date_to_canonical(p_trace_date));
  END debug;

--
--
--
  PROCEDURE debug_enter(
    p_proc_name                 IN       VARCHAR2
   ,p_trace_on                  IN       VARCHAR2 DEFAULT NULL
  )
  IS
--     l_trace_options    VARCHAR2(200);
  BEGIN
    pqp_utilities.debug_enter(p_proc_name, p_trace_on);
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
    pqp_utilities.debug_exit(p_proc_name, p_trace_off);
  END debug_exit;

--
--
  PROCEDURE debug_others(
    p_proc_name                 IN       VARCHAR2
   ,p_proc_step                 IN       VARCHAR2 DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug_others(p_proc_name, p_proc_step);
  END debug_others;
--
--
--
  PROCEDURE clear_cache
  IS
  BEGIN
    NULL;
  END clear_cache;
--
--
--
  PROCEDURE create_absence_plan_details(
    p_person_id                 IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_element_type_id           IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
  IS
    l_absence_dates               csr_absence_dates%ROWTYPE;
    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61)
                           := g_package_name || 'create_absence_plan_details';
    l_is_overlapped               BOOLEAN ;
    l_absence_type                csr_absence_type%ROWTYPE;

  BEGIN
    g_debug := hr_utility.debug_enabled;

    IF g_debug THEN
    debug_enter(l_proc_name);
    END IF;
    OPEN csr_absence_dates(p_absence_attendance_id);
    FETCH csr_absence_dates INTO l_absence_dates;
    CLOSE csr_absence_dates;
    IF g_debug THEN
      l_proc_step:=10;
      debug(l_proc_name, l_proc_step);
    END IF;

    IF l_absence_dates.absence_attendance_id IS NOT NULL
    THEN
      IF g_debug THEN
        l_proc_step:=20;
        debug(l_proc_name, l_proc_step);
      END IF;


        l_is_overlapped := is_absence_overlapped
                           (
                           p_absence_attendance_id =>
			        l_absence_dates.absence_attendance_id
                           ) ;

        IF l_is_overlapped THEN
	 IF g_debug THEN
           l_proc_step := 21;
           debug(l_proc_name, l_proc_step);
         END IF;
          -- get Absence Type to display in Error Message
           OPEN csr_absence_type(l_absence_dates.absence_attendance_type_id);
           FETCH csr_absence_type INTO l_absence_type ;
           CLOSE csr_absence_type ;

          fnd_message.set_name('PQP', 'PQP_230183_ABS_OVERLAP');
          fnd_message.set_token('ABSTYPE',l_absence_type.name);
          fnd_message.set_token('STARTDATE',l_absence_dates.date_start);
          fnd_message.set_token('ENDDATE',l_absence_dates.date_end);
          fnd_message.raise_error ;
        END IF ;


      IF p_legislation_code = 'GB'
      THEN
        IF g_debug THEN
          l_proc_step:=30;
          debug(l_proc_name, l_proc_step);
        END IF;
        pqp_gb_absence_plan_process.create_absence_plan_details(
          p_person_id =>                  p_person_id
         ,p_assignment_id =>              p_assignment_id
         ,p_business_group_id =>          p_business_group_id
         ,p_legislation_code =>           p_legislation_code
         ,p_effective_date =>             p_effective_date
         ,p_element_type_id =>            p_element_type_id
         ,p_pl_id =>                      p_pl_id
         ,p_pl_typ_id =>                  p_pl_typ_id
         ,p_ler_id =>                     p_ler_id
         ,p_per_in_ler_id =>              p_per_in_ler_id
         ,p_absence_attendance_id =>      p_absence_attendance_id
         ,p_absence_date_start =>         l_absence_dates.date_start
         ,p_absence_date_end =>           NVL(
                                            l_absence_dates.date_end
                                           ,hr_api.g_eot
                                          )
         ,p_effective_start_date =>       p_effective_start_date
         ,p_effective_end_date =>         p_effective_end_date
         ,p_formula_outputs =>            p_formula_outputs
         ,p_error_code =>                 p_error_code
         ,p_error_message =>              p_error_message
        );
      END IF; -- p_legislation_code = 'GB' then
    END IF; -- IF l_absence_dates.absence_attendance_id IS NOT NULL

    IF g_debug THEN
    debug_exit(l_proc_name);
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF SQLCODE <> hr_utility.hr_error_number
      THEN
        debug_others(l_proc_name, l_proc_step);

        IF g_debug
        THEN
          debug('Leaving: ' || l_proc_name, -999);
        END IF;

        fnd_message.raise_error;
      ELSE
        RAISE;
      END IF;
  END create_absence_plan_details ;

--
--
--
  PROCEDURE update_absence_plan_details(
    p_person_id                 IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_element_type_id           IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE -- NULL 31-DEC-4712
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
  IS
    l_absence_dates               csr_absence_dates%ROWTYPE;
    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61):=
      g_package_name || 'update_absence_plan_details';
    l_is_overlapped               BOOLEAN ;
    l_absence_type                csr_absence_type%ROWTYPE;

  BEGIN
    IF g_debug THEN
    debug_enter(l_proc_name);
    END IF;
    OPEN csr_absence_dates(p_absence_attendance_id);
    FETCH csr_absence_dates INTO l_absence_dates;
    CLOSE csr_absence_dates;
    IF g_debug THEN
      l_proc_step:=10;
      debug(l_proc_name, l_proc_step);
    END IF;

    IF l_absence_dates.absence_attendance_id IS NOT NULL -- absence not been deleted
    THEN
      IF g_debug THEN
        l_proc_step:=20;
        debug(l_proc_name, l_proc_step);
      END IF;
-- Commenting the overlap check as this is triggered during backout processing
-- and will not allow backout of overlaps if there are any existing. ideally
-- once the overlap check is in place in create porcess there cant be any
-- overlaps processed in the data.
--       l_is_overlapped := is_absence_overlapped
--                           (
--                           p_absence_attendance_id => l_absence_dates.absence_attendance_id
--                           ) ;
--        IF l_is_overlapped THEN
--	  IF g_debug THEN
--            l_proc_step := 21;
--            debug(l_proc_name, l_proc_step);
--          END IF;
          -- get Absence Type to display in Error Message
--           OPEN csr_absence_type(l_absence_dates.absence_attendance_type_id);
--           FETCH csr_absence_type INTO l_absence_type ;
--           CLOSE csr_absence_type ;

--          fnd_message.set_name('PQP', 'PQP_230183_ABS_OVERLAP');
--          fnd_message.set_token('ABSTYPE',l_absence_type.name);
--          fnd_message.set_token('STARTDATE',l_absence_dates.date_start);
--          fnd_message.set_token('ENDDATE',l_absence_dates.date_end);
--          fnd_message.raise_error ;
--        END IF ;


      IF p_legislation_code = 'GB'
      THEN
        IF g_debug THEN
          l_proc_step:=30;
          debug(l_proc_name, l_proc_step);
        END IF;
        pqp_gb_absence_plan_process.update_absence_plan_details(
          p_person_id =>                  p_person_id
         ,p_assignment_id =>              p_assignment_id
         ,p_business_group_id =>          p_business_group_id
         ,p_legislation_code =>           p_legislation_code
         ,p_effective_date =>             p_effective_date
         ,p_absence_attendance_id =>      p_absence_attendance_id
         ,p_absence_date_start =>         l_absence_dates.date_start
         ,p_absence_date_end =>           NVL(
                                            l_absence_dates.date_end
                                           ,hr_api.g_eot
                                          )
         ,p_pl_id =>                      p_pl_id
         ,p_pl_typ_id =>                  p_pl_typ_id
         ,p_element_type_id =>            p_element_type_id
         ,p_effective_start_date =>       p_effective_start_date
         ,p_effective_end_date =>         p_effective_end_date
         ,p_ler_id =>                     p_ler_id
         ,p_per_in_ler_id =>              p_per_in_ler_id
         ,p_formula_outputs =>            p_formula_outputs
         ,p_error_code =>                 p_error_code
         ,p_error_message =>              p_error_message
        );
      END IF; -- IF  p_legislation_code='GB' THEN
    END IF; -- IF l_absence_dates.absence_attendance_id IS NOT NULL

    IF g_debug THEN
    debug_exit(l_proc_name);
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF SQLCODE <> hr_utility.hr_error_number
      THEN
        debug_others(l_proc_name, l_proc_step);

        IF g_debug
        THEN
          debug('Leaving: ' || l_proc_name, -999);
        END IF;

        fnd_message.raise_error;
      ELSE
        RAISE;
      END IF;
  END update_absence_plan_details;

--
--
--
  PROCEDURE delete_absence_plan_details(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_legislation_code          IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE -- NULL 31-DEC-4712
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_element_type_id           IN       NUMBER DEFAULT NULL
  )
  IS
    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61)
                           := g_package_name || 'update_absence_plan_details';
  BEGIN
    IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;

    -- a delete at this level needs no check for absences start and end date
    -- as this is only called when an absence has been physically deleted
    -- where as the lower level counterparts of delete_absence_plan_details
    -- get called from update also

    IF p_legislation_code = 'GB'
    THEN
        l_proc_step:=10;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;
      pqp_gb_absence_plan_process.delete_absence_plan_details(
        p_assignment_id =>              p_assignment_id
       ,p_business_group_id =>          p_business_group_id
       ,p_legislation_code =>           p_legislation_code
       ,p_effective_date =>             p_effective_date
       ,p_pl_id =>                      p_pl_id
       ,p_pl_typ_id =>                  p_pl_typ_id
       ,p_ler_id =>                     p_ler_id
       ,p_per_in_ler_id =>              p_per_in_ler_id
       ,p_absence_attendance_id =>      p_absence_attendance_id
       ,p_effective_start_date =>       p_effective_start_date
       ,p_effective_end_date =>         p_effective_end_date
       ,p_formula_outputs =>            p_formula_outputs
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
      );
    END IF; -- IF  p_legislation_code='GB' THEN

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;

  EXCEPTION
    WHEN OTHERS
    THEN
      IF SQLCODE <> hr_utility.hr_error_number
      THEN
        debug_others(l_proc_name, l_proc_step);

        IF g_debug
        THEN
          debug('Leaving: ' || l_proc_name, -999);
        END IF;

        fnd_message.raise_error;
      ELSE
        RAISE;
      END IF;
  END delete_absence_plan_details;


FUNCTION is_gap_absence_type(
                             p_absence_attendance_type_id IN NUMBER
			    )
RETURN NUMBER IS

  CURSOR csr_gap_absence_type(p_absence_type_id NUMBER) IS
  SELECT 1
  FROM   hr_lookups
  WHERE  lookup_type = 'PQP_GAP_ABSENCE_TYPES_LIST'
  AND    lookup_code = p_absence_type_id ;

  l_exists    NUMBER ;
  l_proc_name VARCHAR2(61)
              := g_package_name || 'is_gap_absence_type';
  l_proc_step NUMBER(20,10);

BEGIN

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_absence_attendance_type_id:'||p_absence_attendance_type_id);
  END IF ;

  l_exists := 0 ;

  OPEN  csr_gap_absence_type (p_absence_attendance_type_id) ;
  FETCH csr_gap_absence_type INTO l_exists ;
  CLOSE csr_gap_absence_type ;

  IF l_exists = 1 THEN
    l_proc_step := 10 ;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug_exit(l_proc_name);
    END IF;
    RETURN 1 ;
  ELSE
    l_proc_step := 20 ;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug_exit(l_proc_name);
    END IF ;
    RETURN 0 ;
  END IF ;

EXCEPTION
    WHEN OTHERS
    THEN
      IF SQLCODE <> hr_utility.hr_error_number
      THEN
        debug_others(l_proc_name, l_proc_step);

        IF g_debug
        THEN
          debug('Leaving: ' || l_proc_name, -999);
        END IF;

        fnd_message.raise_error;
      ELSE
        RAISE;
      END IF;

END is_gap_absence_type ;



FUNCTION is_absence_overlapped(
                               p_absence_attendance_id IN NUMBER
			      )
RETURN BOOLEAN IS

CURSOR csr_overlap_absence (p_absence_attendance_id NUMBER) IS
SELECT 1
FROM   per_absence_attendances a
WHERE  a.absence_Attendance_id = p_absence_attendance_id
  AND EXISTS ( SELECT 1
               FROM   per_absence_attendances b
               WHERE  a.person_id = b.person_id
               AND (
                    (a.date_start BETWEEN b.date_start
		      AND NVL(b.date_end,hr_api.g_eot) )
                 OR (NVL(a.date_end,hr_api.g_eot) BETWEEN b.date_start
		     AND NVL(b.date_end,hr_api.g_eot) )
                 OR (b.date_start BETWEEN a.date_start
		      AND NVL(a.date_end,hr_api.g_eot))
                    )
                AND is_gap_absence_type(b.absence_attendance_type_id) = 1
 -- checking only for the absence_type_id in table, it is assumed that a
 -- is the driving absence for which the process is triggered and if that
 -- has reached this point of code means its a gap absence type
                AND a.absence_attendance_id <> b.absence_attendance_id
            ) ;

   l_exists                      NUMBER ;
   l_proc_step                   NUMBER(20,10);
   l_proc_name                   VARCHAR2(61)
                           := g_package_name || 'is_absence_overlapped';

BEGIN

  IF g_debug THEN
    debug_enter(l_proc_name) ;
    debug('p_absence_attendance_id:'||p_absence_attendance_id);
  END IF ;

  OPEN  csr_overlap_absence (p_absence_attendance_id) ;
  FETCH csr_overlap_absence INTO l_exists ;
  CLOSE csr_overlap_absence ;

  IF l_exists = 1 THEN
      l_proc_step := 10 ;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug_exit(l_proc_name);
    END IF ;
    RETURN TRUE ;
  ELSE
      l_proc_step := 20 ;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug_exit(l_proc_name);
    END IF ;
    RETURN FALSE ;
  END IF ;

EXCEPTION
    WHEN OTHERS
    THEN
      IF SQLCODE <> hr_utility.hr_error_number
      THEN
        debug_others(l_proc_name, l_proc_step);

        IF g_debug
        THEN
          debug('Leaving: ' || l_proc_name, -999);
        END IF;

        fnd_message.raise_error;
      ELSE
        RAISE;
      END IF;

END is_absence_overlapped ;

END pqp_absence_plan_process;

/
