--------------------------------------------------------
--  DDL for Package Body PQP_GB_ABSENCE_PLAN_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_ABSENCE_PLAN_PROCESS" AS
/* $Header: pqgbabpr.pkb 120.0 2005/05/29 01:48:18 appldev noship $ */
--
--
--
  g_package_name                VARCHAR2(31)
                                            := 'pqp_gb_absence_plan_process.';
  g_debug                       BOOLEAN := hr_utility.debug_enabled;


-- Cache Variables
-- Cache for get_absence_pay_plan_category

  g_gap_primary_element_type_id  pay_element_types_f.element_type_id%TYPE;
  g_plan                         csr_abs_plan_category_by_eid%ROWTYPE;

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
  PROCEDURE clear_cache
  IS
  BEGIN
    g_gap_primary_element_type_id := NULL;
    g_plan                        := NULL;
  END;

--
--
--
  FUNCTION get_absence_pay_plan_category(p_element_type_id IN NUMBER)
    RETURN VARCHAR2
  IS
    l_plan                        csr_abs_plan_category_by_eid%ROWTYPE;
    l_proc_step                   NUMBER(38, 10);
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_absence_pay_plan_category';
  BEGIN
    IF g_debug
    THEN
      debug_enter(l_proc_name);
      debug('Caching Check:g_gap_primary_element_type_id:'||
        fnd_number.number_to_canonical(g_gap_primary_element_type_id));
      debug('Caching Check:p_element_type_id:'||
        fnd_number.number_to_canonical(p_element_type_id));
    END IF;

    IF g_gap_primary_element_type_id IS NULL
       OR
       g_gap_primary_element_type_id <> p_element_type_id
    THEN

      IF g_debug
      THEN
        l_proc_step := 20;
        debug(l_proc_name, l_proc_step);
      END IF;

      -- DO NOT CLEAR THE CACHE Look at if found logic
      --g_gap_primary_element_type_id:= NULL;
      --g_plan := NULL;

      OPEN csr_abs_plan_category_by_eid(p_element_type_id);
      FETCH csr_abs_plan_category_by_eid INTO l_plan;
      IF csr_abs_plan_category_by_eid%FOUND THEN
        -- if some information has been found then its because this element
        -- type id is a primary OSP element type. The fact the code is here
        -- indicates that it is not the same primary element as the last
        -- primary osp element cached or that this is the first call for a
        -- any primary osp element.
        -- In this case save the elment details and its associated plan category
        -- in the cache for possible re-use in subsequent calls.
        IF g_debug
        THEN
          l_proc_step := 24;
          debug(l_proc_name, l_proc_step);
        END IF;
        g_gap_primary_element_type_id := p_element_type_id;
        g_plan := l_plan;

      ELSE
        -- if csr_abs_plan_category_by_eid was not found then its because
        -- this element type is either not a primary OSP element type or is
        -- not a OSP element at all in which case we could either
        -- destroy the cache and return the null plan category or not clear
        -- the cache but still return a NULL category
        -- In essence the cache is refreshed when a new OSP Primary element is
        -- processed.
        IF g_debug
        THEN
          l_proc_step := 28;
          debug(l_proc_name, l_proc_step);
        END IF;
        l_plan.absence_pay_plan_category:= NULL;
      END IF;
      CLOSE csr_abs_plan_category_by_eid;

    ELSE
      -- this element is the same primary osp element as one
      -- which has been previously processed in which
      -- case do not fetch that information again return from
      -- saved global g_plan
      IF g_debug
      THEN
        l_proc_step := 30;
        debug(l_proc_name, l_proc_step);
      END IF;

      l_plan := g_plan;
    END IF;

    IF g_debug
    THEN
      debug(l_plan.absence_pay_plan_category);
      debug_exit(l_proc_name);
    END IF;

    RETURN l_plan.absence_pay_plan_category;

  EXCEPTION
    WHEN OTHERS
    THEN
      clear_cache;
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
  END get_absence_pay_plan_category;

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
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_absence_date_start        IN       DATE
   ,p_absence_date_end          IN       DATE
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
  IS
    l_absence_pay_plan_category   pay_element_type_extra_info.eei_information30%TYPE;
    l_error_code                  fnd_new_messages.message_number%TYPE;
    l_message                     fnd_new_messages.MESSAGE_TEXT%TYPE;
    l_proc_step                   NUMBER(38,10);
    l_proc_name                   VARCHAR2(61):=
      g_package_name || 'create_absence_plan_details';

  BEGIN
    g_debug := hr_utility.debug_enabled;

    IF g_debug
    THEN
      debug_enter(l_proc_name);
    END IF;

    l_absence_pay_plan_category :=
      get_absence_pay_plan_category(p_element_type_id);

    IF g_debug
    THEN
      debug('l_absence_pay_plan_category:' || l_absence_pay_plan_category);
    END IF;

    l_absence_pay_plan_category := UPPER(l_absence_pay_plan_category);

    IF l_absence_pay_plan_category IN ('SICKNESS','UNPAID')
    THEN
      IF g_debug
      THEN
        l_proc_step := 20;
        debug(l_proc_name, l_proc_step);
      END IF;

      pqp_absval_pkg.create_absence_plan_details(
        p_assignment_id =>              p_assignment_id
       ,p_person_id =>                  p_person_id
       ,p_business_group_id =>          p_business_group_id
       ,p_absence_id =>                 p_absence_attendance_id
       ,p_absence_date_start =>         p_absence_date_start
       ,p_absence_date_end =>           p_absence_date_end
       ,p_pl_id =>                      p_pl_id
       ,p_pl_typ_id =>                  p_pl_typ_id
       ,p_element_type_id =>            p_element_type_id
       ,p_create_start_date =>          p_effective_start_date
       ,p_create_end_date =>            p_effective_end_date
       ,p_output_type =>                p_formula_outputs
       ,p_error_code =>                 l_error_code
       ,p_message =>                    l_message
      );
    ELSIF l_absence_pay_plan_category = 'MATERNITY'
    THEN
      IF g_debug
      THEN
        l_proc_step := 30;
        debug(l_proc_name, l_proc_step);
      END IF;

      pqp_gb_omp_daily_absences.create_absence_plan_details(
        p_assignment_id =>              p_assignment_id
       ,p_person_id =>                  p_person_id
       ,p_business_group_id =>          p_business_group_id
       ,p_absence_id =>                 p_absence_attendance_id
       ,p_absence_date_start =>         p_absence_date_start
       ,p_absence_date_end =>           p_absence_date_end
       ,p_pl_id =>                      p_pl_id
       ,p_pl_typ_id =>                  p_pl_typ_id
       ,p_element_type_id =>            p_element_type_id
       ,p_create_start_date =>          p_effective_start_date
       ,p_create_end_date =>            p_effective_end_date
       ,p_output_type =>                p_formula_outputs
       ,p_error_code =>                 l_error_code
       ,p_message =>                    l_message
      );
    ELSE
      IF g_debug
      THEN
        debug('!');
        l_proc_step := 40;
        debug(l_proc_name, l_proc_step);
      END IF;
    END IF;

    --p_error_code := l_error_code;
    --p_error_message := l_message;

    IF g_debug
    THEN
      debug_exit(l_proc_name);
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      clear_cache;
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
  END create_absence_plan_details;

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
   ,p_effective_start_date      IN       DATE
   ,p_effective_end_date        IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_per_in_ler_id             IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_absence_date_start        IN       DATE
   ,p_absence_date_end          IN       DATE
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
  IS
    l_absence_pay_plan_category   pay_element_type_extra_info.eei_information30%TYPE;
    l_error_code                  fnd_new_messages.message_number%TYPE;
    l_message                     fnd_new_messages.MESSAGE_TEXT%TYPE;
    l_proc_step                   NUMBER(20, 10);
    l_proc_name                   VARCHAR2(61)
                           := g_package_name || 'update_absence_plan_details';
  BEGIN
    g_debug := hr_utility.debug_enabled;

    IF g_debug
    THEN
      debug_enter(l_proc_name);
    END IF;

    l_absence_pay_plan_category :=
      get_absence_pay_plan_category(p_element_type_id);

    IF g_debug
    THEN
      debug('l_absence_pay_plan_category:' || l_absence_pay_plan_category);
    END IF;

    l_absence_pay_plan_category := UPPER(l_absence_pay_plan_category);

    IF l_absence_pay_plan_category IN ('SICKNESS','UNPAID')
    THEN
      IF g_debug
      THEN
        l_proc_step := 20;
        debug(l_proc_name, l_proc_step);
      END IF;

      pqp_absval_pkg.update_absence_plan_details(
        p_assignment_id =>              p_assignment_id
       ,p_person_id =>                  p_person_id
       ,p_business_group_id =>          p_business_group_id
       ,p_absence_id =>                 p_absence_attendance_id
       ,p_absence_date_start =>         p_absence_date_start
       ,p_absence_date_end =>           p_absence_date_end
       ,p_pl_id =>                      p_pl_id
       ,p_pl_typ_id =>                  p_pl_typ_id
       ,p_element_type_id =>            p_element_type_id
       ,p_update_start_date =>          p_effective_start_date
       ,p_update_end_date =>            p_effective_end_date
       ,p_output_type =>                p_formula_outputs
       ,p_error_code =>                 l_error_code
       ,p_message =>                    l_message
      );
    ELSIF l_absence_pay_plan_category = 'MATERNITY'
    THEN
      IF g_debug
      THEN
        l_proc_step := 30;
        debug(l_proc_name, l_proc_step);
      END IF;

      pqp_gb_omp_daily_absences.update_absence_plan_details(
        p_assignment_id =>              p_assignment_id
       ,p_person_id =>                  p_person_id
       ,p_business_group_id =>          p_business_group_id
       ,p_absence_id =>                 p_absence_attendance_id
       ,p_absence_date_start =>         p_absence_date_start
       ,p_absence_date_end =>           p_absence_date_end
       ,p_pl_id =>                      p_pl_id
       ,p_pl_typ_id =>                  p_pl_typ_id
       ,p_element_type_id =>            p_element_type_id
       ,p_update_start_date =>          p_effective_start_date
       ,p_update_end_date =>            p_effective_end_date
       ,p_output_type =>                p_formula_outputs
       ,p_error_code =>                 l_error_code
       ,p_message =>                    l_message
      );
    ELSE
      IF g_debug
      THEN
        debug('!');
        l_proc_step := 40;
        debug(l_proc_name, l_proc_step);
      END IF;
    END IF;

    --p_error_code := l_error_code;
    --p_error_message := l_message;

    IF g_debug
    THEN
      debug_exit(l_proc_name);
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      clear_cache;
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
   ,p_effective_end_date        IN       DATE
   ,p_formula_outputs           IN       ff_exec.outputs_t
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_element_type_id           IN       NUMBER DEFAULT NULL
  )
  IS
    l_absence_pay_plan_category   pay_element_type_extra_info.eei_information30%TYPE;
    l_error_code                  fnd_new_messages.message_number%TYPE;
    l_message                     fnd_new_messages.MESSAGE_TEXT%TYPE;
    l_proc_step                   NUMBER(20, 10);
    l_proc_name                   VARCHAR2(61)
                           := g_package_name || 'delete_absence_plan_details';
  BEGIN
    IF g_debug
    THEN
      debug_enter(l_proc_name);
    END IF;

    IF p_element_type_id IS NOT NULL THEN -- temp code remove once ben gives changes

      l_absence_pay_plan_category :=
        get_absence_pay_plan_category(p_element_type_id);
    -- no point in checking by plan id
    END IF;

    IF g_debug
    THEN
      debug('l_absence_pay_plan_category:' || l_absence_pay_plan_category);
    END IF;

    l_absence_pay_plan_category := UPPER(l_absence_pay_plan_category);

    IF l_absence_pay_plan_category IN('SICKNESS', 'MATERNITY','UNPAID')
      OR
       p_element_type_id IS NULL -- temp code till ben gives new benelmen
    THEN
      IF g_debug
      THEN
        l_proc_step := 20;
        debug(l_proc_name, l_proc_step);
      END IF;

      pqp_absval_pkg.delete_absence_plan_details(
        p_assignment_id =>              p_assignment_id
       ,p_business_group_id =>          p_business_group_id
       ,p_plan_id =>                    p_pl_id
       ,p_absence_id =>                 p_absence_attendance_id
       ,p_delete_start_date =>          p_effective_start_date
       ,p_delete_end_date =>            p_effective_end_date
       ,p_error_code =>                 l_error_code
       ,p_message =>                    l_message
      );

    ELSE

      IF g_debug
      THEN
        debug('!');
        l_proc_step := 30;
        debug(l_proc_name, l_proc_step);
      END IF;

    END IF; -- IF UPPER(l_absence_pay_plan_category) IN ('SICKNESS','MATERNITY')

    p_error_code := l_error_code;
    p_error_message := l_message;

-- Added by tmehra for nocopy changes Feb'03

    IF g_debug
    THEN
      debug_exit(l_proc_name);
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      clear_cache;
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
END;

/
