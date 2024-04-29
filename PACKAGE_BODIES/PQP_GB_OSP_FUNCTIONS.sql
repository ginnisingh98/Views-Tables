--------------------------------------------------------
--  DDL for Package Body PQP_GB_OSP_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_OSP_FUNCTIONS" AS
/* $Header: pqpospfn.pkb 120.23.12010000.7 2008/08/25 06:54:05 bachakra ship $ */
--
  g_package_name                VARCHAR2(31) := 'pqp_gb_osp_functions.';
  g_debug                       BOOLEAN:= hr_utility.debug_enabled;


  g_udt_name                    VARCHAR2(80):=
    pqp_schedule_calculation_pkg.g_udt_name;

  g_default_start_day           VARCHAR2(30):=
    pqp_schedule_calculation_pkg.g_default_start_day;

  g_assignment_id               per_all_assignments_f.assignment_id%TYPE := 0;
  g_pl_typ_id                   ben_pl_f.pl_id%TYPE := 0;
  g_balance_date                DATE := hr_api.g_date;
  g_absences_taken_to_date      pqp_absval_pkg.t_entitlements;

  g_scheme_calendar_type pay_element_type_extra_info.eei_information1%TYPE;
  g_scheme_calendar_duration pay_element_type_extra_info.eei_information1%TYPE;
  g_scheme_calendar_uom pay_element_type_extra_info.eei_information1%TYPE;
  g_scheme_start_date_txt       VARCHAR2(80);

  -- Cache for get_omp_band_ent_bal_pl_typ
  g_omp_assignment_id           per_all_assignments_f.assignment_id%TYPE := 0;
  g_omp_pl_typ_id               ben_pl_f.pl_id%TYPE := 0;
  g_omp_balance_date            DATE := hr_api.g_date;
  g_omp_absences_taken_to_date  pqp_absval_pkg.t_entitlements;

  -- Cache for pqp_get_plan_extra_info
  g_element_type_id             pay_element_type_extra_info.element_type_id%TYPE;
  g_plan_id                     ben_pl_f.pl_id%TYPE;

  -- Cache for pqp_get_los_based_entitlements
  g_entitlement_UDT_id          pay_user_tables.user_table_id%TYPE;
  g_entitlement_UOM             pay_element_type_extra_info.eei_information8%TYPE;

  -- Cache for PQP_GB_GET_ABSENCE_SSP
  --g_ssp_element_id              pay_element_types_f.element_type_id%TYPE;
  --g_ssp_correction_element_id   pay_element_types_f.element_type_id%TYPE;
  --g_max_ssp_period              NUMBER(11,5);
  --c_ssp_eit_context CONSTANT
  --  pay_element_types_f.element_information_category%TYPE:=
  --   'GB_SSP NON PAYMENT';
  --
  --g_pattern_id_for_bg           hr_patterns.pattern_id%TYPE;
  --g_input_value_ids_ele1        t_input_value_ids; -- IVs of ssp_element
  --g_input_value_ids_ele2        t_input_value_ids; -- IVs of ssp_correction_element
  --g_person_id                   per_absence_attendances.person_id%TYPE;
  --g_t_pat_exceptions            t_pat_exceptions;
  --g_t_per_pat_exceptions        t_pat_exceptions;
  --g_per_pattern                 c_per_pattern%ROWTYPE;

  -- Cache for get_actual_ssp_days
  --g_pattern                     c_pattern%ROWTYPE;
  --g_t_pat_cons                  pat_cons_t;
  --g_pattern_id                  hr_patterns.pattern_id%TYPE;


  -- Cache for get_absence_ssp
  g_ssp_business_group_id       hr_all_organization_units.business_group_id%TYPE;
  g_ssp_element_type_id         pay_element_types_f.element_type_id%TYPE;
  g_ssp_input_values            t_input_value_ids;
  g_ssp_retro_element_type_id   pay_element_types_f.element_type_id%TYPE;
  g_ssp_retro_input_values      t_input_value_ids;
  g_ssp_element_links           t_element_links;
  g_ssp_retro_element_links     t_element_links;

  -- Cache for get_absence_smp
  g_smp_element_type_id         pay_element_types_f.element_type_id%TYPE;
  g_smp_input_values            t_input_value_ids;
  g_smp_element_links           t_element_links;
  g_smp_retro_element_type_id   pay_element_types_f.element_type_id%TYPE;
  g_smp_retro_input_values      t_input_value_ids;
  g_smp_retro_element_links     t_element_links;
  g_smp_business_group_id       hr_all_organization_units.business_group_id%TYPE;
  g_absence_category            VARCHAR2(30);
 -- Cache for rounding of factors
 /*check it absence round_to handle*/

/*  g_parttimers_entitl_round_to         VARCHAR2(10):=null;
  g_parttimers_absence_round_to        VARCHAR2(10):=null;
  g_parttimers_rounding_factor         pqp_gap_daily_absences.duration%TYPE;
  g_fulltimers_rounding_factor         pqp_gap_daily_absences.duration%TYPE;
  g_fulltimers_entitl_round_to         VARCHAR2(10):=null ;
  g_fulltimers_absence_round_to        VARCHAR2(10):=null;*/

  g_pt_entitl_rounding_type       VARCHAR2(10):=null;
  g_pt_rounding_precision         pqp_gap_daily_absences.duration%TYPE;
  g_ft_rounding_precision         pqp_gap_daily_absences.duration%TYPE;
  g_ft_entitl_rounding_type       VARCHAR2(10):=null ;
  g_abs_rounding_precision         pqp_gap_daily_absences.duration%TYPE;
  g_abs_rounding_type             VARCHAR2(10):='ROUNDTO' ;
  g_round_cache_plan_id           NUMBER;

--

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
    pqp_utilities.debug(p_trace_number);
  END debug;

--
--
--
  PROCEDURE debug(p_trace_date IN DATE)
  IS
  BEGIN
    pqp_utilities.debug(p_trace_date);
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
    --l_null_per_pattern         c_per_pattern%ROWTYPE;
    --l_null_pattern             c_pattern%ROWTYPE;
  BEGIN

  g_assignment_id              := NULL;--per_all_assignments_f.assignment_id%TYPE := 0
  g_pl_typ_id                  := NULL;--ben_pl_f.pl_id%TYPE := 0
  g_balance_date               := NULL;--DATE := hr_api.g_date
  g_absences_taken_to_date.DELETE;     --pqp_absval_pkg.t_entitlements

  g_scheme_calendar_type := NULL ;
  g_scheme_calendar_duration := NULL ;
  g_scheme_calendar_uom := NULL ;
  g_scheme_start_date_txt := NULL ;

  -- Cache for get_omp_band_ent_bal_pl_typ
  g_omp_assignment_id          :=  NULL;--per_all_assignments_f.assignment_id%TYPE := 0
  g_omp_pl_typ_id              :=  NULL;--ben_pl_f.pl_id%TYPE := 0
  g_omp_balance_date           :=  NULL;--DATE := hr_api.g_date
  g_omp_absences_taken_to_date.DELETE;  --pqp_absval_pkg.t_entitlements

  -- Cache for pqp_get_plan_extra_info
  g_element_type_id            :=  NULL;--pay_element_type_extra_info.element_type_id%TYPE
  g_plan_id                    :=  NULL;--ben_pl_f.pl_id%TYPE

  -- Cache for pqp_get_los_based_entitlements
  g_entitlement_UDT_id         :=  NULL;--pay_user_tables.user_table_id%TYPE
  g_entitlement_UOM            :=  NULL;--pay_element_type_extra_info.eei_information8%TYPE

  -- Cache for PQP_GB_GET_ABSENCE_SSP
  --g_ssp_element_id             :=  NULL;--pay_element_types_f.element_type_id%TYPE
  --g_ssp_correction_element_id  :=  NULL;--pay_element_types_f.element_type_id%TYPE
  --g_max_ssp_period             :=  NULL;--NUMBER(11,5)
  --c_ssp_eit_context CONSTANT          -- Constants donot need to be NULLed
  --  pay_element_types_f.element_information_category%TYPE:=
  --   'GB_SSP NON PAYMENT'
  --g_pattern_id_for_bg          :=  NULL;--hr_patterns.pattern_id%TYPE
  --g_input_value_ids_ele1.DELETE;        --t_input_value_ids; -- IVs of ssp_element
  --g_input_value_ids_ele2.DELETE;        --t_input_value_ids; -- IVs of ssp_correction_element
  --g_person_id                  :=  NULL;--per_absence_attendances.person_id%TYPE
  --g_t_pat_exceptions.DELETE;            --t_pat_exceptions
  --g_t_per_pat_exceptions.DELETE;        --t_pat_exceptions
  --g_per_pattern                := l_null_per_pattern;
                                        --c_per_pattern%ROWTYPE
  -- Cache for get_actual_ssp_days
  --g_pattern                    := l_null_pattern;
                                         --c_pattern%ROWTYPE
  --g_t_pat_cons.DELETE;                   --pat_cons_t
  --g_pattern_id                 :=  NULL; --hr_patterns.pattern_id%TYPE

  -- Cache for get_absence_ssp
  g_ssp_business_group_id      := NULL;  --hr_all_organization_units.business_group_id%TYPE;

  g_ssp_element_type_id        := NULL;  --pay_element_types_f.element_type_id%TYPE;
  g_ssp_input_values.DELETE;             --t_input_value_ids;
  g_ssp_element_links.DELETE;            --t_element_links;

  g_ssp_retro_element_type_id  := NULL;  --pay_element_types_f.element_type_id%TYPE;
  g_ssp_retro_input_values.DELETE;       --t_input_value_ids;
  g_ssp_retro_element_links.DELETE;      --t_element_links;

  -- Cache for get_absence_smp
  g_smp_business_group_id       := NULL; --hr_all_organization_units.business_group_id%TYPE;

  g_smp_element_type_id         := NULL; --pay_element_types_f.element_type_id%TYPE;
  g_smp_input_values.DELETE;             --t_input_value_ids;
  g_smp_element_links.DELETE;            --t_element_links;

  g_smp_retro_element_type_id   := NULL; --pay_element_types_f.element_type_id%TYPE;
  g_smp_retro_input_values.DELETE;       --t_input_value_ids;
  g_smp_retro_element_links.DELETE;      --t_element_links;
  g_absence_category           :=NULL;
  END clear_cache;
--
-- pqp_get_absence_attendances is the function to get the value
-- of the column from table per_absence_attendances
--
  FUNCTION pqp_get_absence_attendances(
    p_absence_attendance_id     IN       NUMBER
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_val                         VARCHAR2(2000);
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_absence_attendances';
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_col_name:'||p_col_name);
    END IF;

    l_val :=
      pqp_utilities.get_col_value(
        p_col_nam =>                    p_col_name
       ,p_key_val =>                    p_absence_attendance_id
       ,p_table =>                      'PER_ABSENCE_ATTENDANCES'
       ,p_key_col =>                    'ABSENCE_ATTENDANCE_ID'
       ,p_where =>                      NULL
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );
    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;

    RETURN l_val;

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
  END pqp_get_absence_attendances;

-- pqp_get_absence_further_info returns the value of the items
-- from the flex filed Additional Absence Detail Information
  FUNCTION pqp_get_absence_further_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_attendance_id     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_val                         VARCHAR2(2000);
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_absence_further_info';
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_segment_name:'||p_segment_name);
    END IF;

    -- If the sement name passed is Concatenated then return the
    -- Concatenated Value
     --
    IF p_segment_name = 'CONCATENATED'
    THEN
      --
      debug(l_proc_name, 10);
      l_val :=
        pqp_utilities.pqp_get_concat_value(
          p_key_col =>                    'ABSENCE_ATTENDANCE_ID'
         ,p_key_val =>                    p_absence_attendance_id
         ,p_tab_name =>                   'PER_ABSENCE_ATTENDANCES'
         ,p_view_name =>                  'PER_ABSENCE_ATTENDANCES_DFV'
         ,p_message =>                    p_message
        );
    --
    ELSE
      --
      debug(l_proc_name, 20);
      l_val :=
        pqp_utilities.get_ddf_value(
          p_flex_name =>                  'PER_ABS_DEVELOPER_DF'
         ,p_flex_context =>               'GB'
         ,p_flex_field_title =>           p_segment_name
         ,p_key_col =>                    'ABSENCE_ATTENDANCE_ID'
         ,p_key_val =>                    p_absence_attendance_id
         ,p_effective_date =>             p_effective_date
         ,p_eff_date_req =>               'N'
         ,p_business_group_id =>          p_business_group_id
         ,p_bus_group_id_req =>           'N'
         ,p_error_code =>                 p_error_code
         ,p_message =>                    p_message
        );
    --
    END IF;

    --


    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
    ELSE
      p_error_code := 0;
    END IF;

    --
    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;

    IF LENGTH(l_val) > 250
    THEN
      p_truncated_yes_no := 'Y';
      RETURN SUBSTR(l_val, 1, 250);
    ELSE
      p_truncated_yes_no := 'N';
      RETURN l_val;
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
  END pqp_get_absence_further_info;

-- pqp_get_absence_further_info returns the value of the items
-- from the flex filed Additional Absence Details
  FUNCTION pqp_get_absence_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_attendance_id     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_val                         VARCHAR2(2000);
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_absence_Addnl_attr';
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date:'||p_effective_date);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_segment_name:'||p_segment_name);
    END IF;

    --
    IF p_segment_name = 'CONCATENATED'
    THEN
      --
      debug(l_proc_name, 10);
      l_val :=
        pqp_utilities.pqp_get_concat_value(
          p_key_col =>                    'ABSENCE_ATTENDANCE_ID'
         ,p_key_val =>                    p_absence_attendance_id
         ,p_tab_name =>                   'PER_ABSENCE_ATTENDANCES'
         ,p_view_name =>                  'PER_ABSENCE_ATTENDANCES_DFV'
         ,p_message =>                    p_message
        );
    --
    ELSE
      --
      debug(l_proc_name, 10);
      l_val :=
        pqp_utilities.get_df_value(
          p_flex_name =>                  'PER_ABSENCE_ATTENDANCES'
         ,p_flex_context =>               NULL
         ,p_flex_field_title =>           p_segment_name
         ,p_key_col =>                    'ABSENCE_ATTENDANCE_ID'
         ,p_key_val =>                    p_absence_attendance_id
         ,p_tab_name =>                   'PER_ABSENCE_ATTENDANCES'
         ,p_effective_date =>             p_effective_date
         ,p_eff_date_req =>               'N'
         ,p_business_group_id =>          p_business_group_id
         ,p_bus_group_id_req =>           'N'
         ,p_error_code =>                 p_error_code
         ,p_message =>                    p_message
        );
    --
    END IF;

    --
    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;

    --
    IF LENGTH(l_val) > 250
    THEN
      p_truncated_yes_no := 'Y';
      RETURN SUBSTR(l_val, 1, 250);
    ELSE
      p_truncated_yes_no := 'N';
      RETURN l_val;
    END IF;
  --



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
  END pqp_get_absence_addnl_attr;

-- pqp_get_ssp_medicals_details is the function to get the value
-- of the column from table SSP_MEDICALS
  FUNCTION pqp_get_ssp_medicals_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_val                         VARCHAR2(2000);
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_ssp_medicals_details';
    l_medical_id                  ssp_medicals.medical_id%TYPE;
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,5);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_col_name:'||p_col_name);

    END IF;
    --
    debug(l_proc_name, 10);
    l_medical_id :=
      pqp_gb_osp_functions.pqp_get_medical_id(p_absence_id => p_absence_attendance_id
       ,p_message =>                    p_message);

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
      debug_exit(l_proc_name || ' ' || p_message);
      RETURN 0;
    END IF;

    --
    --
    debug(l_proc_name, 20);
    l_val :=
      pqp_utilities.get_col_value(
        p_col_nam =>                    p_col_name
       ,p_key_val =>                    l_medical_id
       ,p_table =>                      'SSP_MEDICALS'
       ,p_key_col =>                    'MEDICAL_ID'
       ,p_where =>                      NULL
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );
    --

    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;


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
  END pqp_get_ssp_medicals_details;

-- pqp_get_ssp_medical_addnl_attr returns the value of the items
-- from the flex filed SSP_MEDICALS
  FUNCTION pqp_get_ssp_medical_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_attendance_id     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_val                         VARCHAR2(2000);
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_ssp_medical_addnl_attr';
    l_medical_id                  ssp_medicals.medical_id%TYPE;
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_segment_name:'||p_segment_name);
    END IF;
    --
    debug(l_proc_name, 10);

    l_medical_id :=
      pqp_gb_osp_functions.pqp_get_medical_id(p_absence_id => p_absence_attendance_id
       ,p_message =>                    p_message);

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
      debug_exit(l_proc_name || ' ' || p_message);
      RETURN NULL;
    END IF;

    --
    --
    IF p_segment_name = 'CONCATENATED'
    THEN
      --
      debug(l_proc_name, 20);
      l_val :=
        pqp_utilities.pqp_get_concat_value(
          p_key_col =>                    'MEDICAL_ID'
         ,p_key_val =>                    l_medical_id
         ,p_tab_name =>                   'SSP_MEDICALS'
         ,p_view_name =>                  'SSP_MEDICALS_DFV'
         ,p_message =>                    p_message
        );
    --
    ELSE
      --
      debug(l_proc_name, 30);
      l_val :=
        pqp_utilities.get_df_value(
          p_flex_name =>                  'SSP_MEDICALS'
         ,p_flex_context =>               NULL
         ,p_flex_field_title =>           p_segment_name
         ,p_key_col =>                    'MEDICAL_ID'
         ,p_key_val =>                    l_medical_id
         ,p_tab_name =>                   'SSP_MEDICALS'
         ,p_effective_date =>             p_effective_date
         ,p_eff_date_req =>               'N'
         ,p_business_group_id =>          p_business_group_id
         ,p_bus_group_id_req =>           'N'
         ,p_error_code =>                 p_error_code
         ,p_message =>                    p_message
        );
    --
    END IF;

    --

    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;

    --
    IF LENGTH(l_val) > 250
    THEN
      p_truncated_yes_no := 'Y';
      RETURN SUBSTR(l_val, 1, 250);
    ELSE
      p_truncated_yes_no := 'N';
      RETURN l_val;
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
  --
  END pqp_get_ssp_medical_addnl_attr;

-- pqp_get_ssp_matrnty_details is the main function to get the value
-- of the column from table SSP_MATERNITIES
  FUNCTION pqp_get_ssp_matrnty_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_val                         VARCHAR2(2000);
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_ssp_matrnty_details';
    l_maternity_id                ssp_maternities.maternity_id%TYPE;
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,5);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_col_name:'||p_col_name);

    END IF;
    --
    debug(l_proc_name, 10);
    l_maternity_id :=
      pqp_gb_osp_functions.pqp_get_maternity_id(p_absence_id => p_absence_attendance_id
       ,p_message =>                    p_message);

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
      debug_exit(l_proc_name || ' ' || p_message);
      RETURN NULL;
    END IF;

    --
    --
    debug(l_proc_name, 20);
    l_val :=
      pqp_utilities.get_col_value(
        p_col_nam =>                    p_col_name
       ,p_key_val =>                    l_maternity_id
       ,p_table =>                      'SSP_MATERNITIES'
       ,p_key_col =>                    'MATERNITY_ID'
       ,p_where =>                      NULL
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );
    --

    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;


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
  END pqp_get_ssp_matrnty_details;

-- pqp_get_ssp_matrnty_addnl_attr returns the value of the items
-- from the flex filed SSP_MATERNITIES
  FUNCTION pqp_get_ssp_matrnty_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_attendance_id     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_val                         VARCHAR2(2000);
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_ssp_matrnty_addnl_attr';
    l_maternity_id                ssp_maternities.maternity_id%TYPE;
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,5);
      debug('p_business_group_id'||to_char(p_business_group_id));
      debug('p_effective_date'||to_char(p_effective_date));
      debug('p_absence_attendance_id'||to_char(p_absence_attendance_id));
      debug('p_segment_name'||p_segment_name);

    END IF;
    --
    debug(l_proc_name, 10);
    l_maternity_id :=
      pqp_gb_osp_functions.pqp_get_maternity_id(p_absence_id => p_absence_attendance_id
       ,p_message =>                    p_message);

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
      debug_exit(l_proc_name || ' ' || p_message);
      RETURN NULL;
    END IF;

    --
    --
    IF p_segment_name = 'CONCATENATED'
    THEN
      --
      debug(l_proc_name, 20);
      l_val :=
        pqp_utilities.pqp_get_concat_value(
          p_key_col =>                    'MATERNITY_ID'
         ,p_key_val =>                    l_maternity_id
         ,p_tab_name =>                   'SSP_MATERNITIES'
         ,p_view_name =>                  'SSP_MATERNITIES_DFV'
         ,p_message =>                    p_message
        );
    --
    ELSE
      --
      debug(l_proc_name, 30);
      l_val :=
        pqp_utilities.get_df_value(
          p_flex_name =>                  'SSP_MATERNITIES'
         ,p_flex_context =>               NULL
         ,p_flex_field_title =>           p_segment_name
         ,p_key_col =>                    'MATERNITY_ID'
         ,p_key_val =>                    l_maternity_id
         ,p_tab_name =>                   'SSP_MATERNITIES'
         ,p_effective_date =>             p_effective_date
         ,p_eff_date_req =>               'N'
         ,p_business_group_id =>          p_business_group_id
         ,p_bus_group_id_req =>           'N'
         ,p_error_code =>                 p_error_code
         ,p_message =>                    p_message
        );
    --
    END IF;

    --

    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;
    --
    IF LENGTH(l_val) > 250
    THEN
      p_truncated_yes_no := 'Y';
      RETURN SUBSTR(l_val, 1, 250);
    ELSE
      p_truncated_yes_no := 'N';
      RETURN l_val;
    END IF;
   --

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
  END pqp_get_ssp_matrnty_addnl_attr;

-- pqp_get_plan_extra_info gets the value of the segment passed for
-- a given information type. plan id is a context.First Element
-- Type id is extracted and pqp_get_extra_element_info is called
-- which returns the value of the segment for the given information type.
-- If any error -1 is returned, 0 is returned for success.
  FUNCTION pqp_get_plan_extra_info(
    p_pl_id                     IN       NUMBER
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
--  l_element_type_id pay_element_types_f.element_type_id%TYPE ;
    l_retval                      NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_element_type_id    pay_element_types_f.element_type_id%TYPE ;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_plan_extra_info';
  BEGIN
   IF g_debug THEN
    debug_enter(l_proc_name);
    debug(' Plan id: ' || p_pl_id || ' Segment Name: ' || p_segment_name);
    debug(' Caching Check: ' || g_plan_id);
    debug(' p_information_type :'|| p_information_type );
   END IF;
    -- Check if Plan Id is cached.
    IF NVL(g_plan_id, 0) <> p_pl_id
    THEN
      g_element_type_id := NULL ;
      g_plan_id               := NULL ;
      debug(l_proc_name, 10);
      OPEN csr_plan_element_type(p_pl_id => p_pl_id
           ,p_information_type =>           p_information_type);
      FETCH csr_plan_element_type INTO l_element_type_id ; --g_element_type_id;
      CLOSE csr_plan_element_type;

      IF l_element_type_id IS NULL
      THEN
        debug(l_proc_name, 20);
        p_error_msg :=
                    fnd_message.get_string('PQP', 'PQP_230602_INV_INFO_TYPE');
        debug_exit(l_proc_name || ' ' || p_error_msg);
        RETURN -1;
      ELSE
        debug(l_proc_name, 30);
        g_plan_id := p_pl_id; -- Cache Plan Id.
        g_element_type_id := l_element_type_id ; --Cache

      END IF; -- IF l_element_type_id IS NULL THEN
    END IF;       -- IF nvl(g_plan_id,0) <> p_pl_id THEN
            --

    debug(l_proc_name, 40);
    l_retval :=
      pqp_utilities.pqp_get_extra_element_info(
        p_element_type_id =>            g_element_type_id
       ,p_information_type =>           p_information_type
       ,p_segment_name =>               p_segment_name
       ,p_value =>                      p_value
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_msg =>                  p_error_msg
      );

    IF g_debug THEN
      debug('l_retval:'||l_retval);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;

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
  --
  END pqp_get_plan_extra_info;

-- pqp_get_other_plan_extra_info takes Plan Name as Input. Plan Id is
-- derived from plan name, business group id and effective date and is
-- passed to pqp_get_plan_extra_info and segment value is derived.
-- If any error -1 is returned, success 0 is retuned.
  FUNCTION pqp_get_other_plan_extra_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_name                   IN       VARCHAR2
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_retval                      NUMBER;
    l_pl_id                       ben_pl_f.pl_id%TYPE;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_other_plan_extra_info';
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,5);
      debug('p_business_group_id'||to_char(p_business_group_id));
      debug('p_effective_date'||to_char(p_effective_date));
      debug('p_pl_name' ||p_pl_name);
      debug('p_information_type'|| p_information_type);
      debug('p_segment_name'|| p_segment_name);

    END IF;
    OPEN csr_plan_id(
          p_business_group_id =>          p_business_group_id
         ,p_effective_date =>             p_effective_date
         ,p_pl_name =>                    p_pl_name
                    );
    FETCH csr_plan_id INTO l_pl_id;
    CLOSE csr_plan_id;

    IF l_pl_id IS NULL
    THEN
      p_error_msg :=
                    fnd_message.get_string('PQP', 'PQP_230606_INV_PLAN_NAME');
      debug_exit(l_proc_name || ' ' || p_error_msg);
      RETURN -1;
    END IF;

    debug(l_proc_name, 10);
    l_retval :=
      pqp_gb_osp_functions.pqp_get_plan_extra_info(
        p_pl_id =>                      l_pl_id
       ,p_information_type =>           p_information_type
       ,p_segment_name =>               p_segment_name
       ,p_value =>                      p_value
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_msg =>                  p_error_msg
      );

    IF g_debug THEN
      debug('l_retval:'||l_retval);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;

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
  END pqp_get_other_plan_extra_info;

-- pqp_get_osp_pl_extra_info Returns the value of the segment
-- in Plan EIT. The Information Type is PQP_GB_OSP_ABSENCE_PLAN_INFO
  FUNCTION pqp_get_osp_pl_extra_info(
    p_pl_id                     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_retval                      NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_osp_pl_extra_info';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_pl_id:'||p_pl_id);
      debug('p_segment_name:'||p_segment_name);

    END IF;
    l_retval :=
      pqp_gb_osp_functions.pqp_get_plan_extra_info(
        p_pl_id =>                      p_pl_id
       ,p_information_type =>           'PQP_GB_OSP_ABSENCE_PLAN_INFO'
       ,p_segment_name =>               p_segment_name
       ,p_value =>                      p_value
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_msg =>                  p_error_msg
      );

    IF g_debug THEN
      debug('l_retval:'||l_retval);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;

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
  --

  END pqp_get_osp_pl_extra_info;

-- pqp_get_osp_pl_extra_info Returns the value of the segment
-- in Plan EIT. Plan Name is the Input.The Information Type is
-- PQP_GB_OSP_ABSENCE_PLAN_INFO
  FUNCTION pqp_get_osp_oth_pl_extra_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_name                   IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_retval                      NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_osp_oth_pl_extra_info';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_business_group_id'||to_char(p_business_group_id));
      debug('p_effective_date'||to_char(p_effective_date));
      debug('p_pl_name'|| p_pl_name);
      debug('p_segment_name'||p_segment_name);

    END IF;
    l_retval :=
      pqp_gb_osp_functions.pqp_get_other_plan_extra_info(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_pl_name =>                    p_pl_name
       ,p_information_type =>           'PQP_GB_OSP_ABSENCE_PLAN_INFO'
       ,p_segment_name =>               p_segment_name
       ,p_value =>                      p_value
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_msg =>                  p_error_msg
      );

    IF g_debug THEN
      debug('l_retval:'||l_retval);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;

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
  --

  END pqp_get_osp_oth_pl_extra_info;

-- ben_get_absence_id derives absence_attendance_id from assignment_id
-- and effective_date which are contexts.
  FUNCTION ben_get_absence_id(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
  )
    RETURN NUMBER
  IS
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_get_absence_id';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_assignment_id'||to_char(p_assignment_id));
      debug('p_effective_date'||to_char(p_effective_date));

    END IF;
    OPEN csr_absence_id(
          p_assignment_id =>              p_assignment_id
         ,p_effective_date =>             p_effective_date
                       );
    FETCH csr_absence_id INTO l_absence_id;
    CLOSE csr_absence_id;

    IF g_debug THEN
      debug('l_absence_id:'||l_absence_id);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_absence_id;
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
  END ben_get_absence_id;

-- ben_get_per_abs_attendances is the main function to get the value
-- of the column from table per_absence_attendances.Called from
-- BEN where assignment_id and effective Date are contexts.
  FUNCTION ben_get_per_abs_attendances(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_get_per_abs_attendances';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_assignment_id'||to_char(p_assignment_id));
      debug(p_effective_date);
      debug('p_col_name'|| p_col_name);

    END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.pqp_get_absence_attendances(
        p_absence_attendance_id =>      l_absence_id
       ,p_col_name =>                   p_col_name
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );

    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;

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
  END ben_get_per_abs_attendances;

-- ben_get_absence_further_info returns the value of the items
-- from the flex filed Additional Absence Detail Information
-- Called from BEN where businee group,assignment_id
-- and effective Date are contexts.
  FUNCTION ben_get_absence_further_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_get_absence_further_info';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_business_group_id:'||p_business_group_id);
      debug(p_effective_date);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_segment_name'||p_segment_name);

    END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.pqp_get_absence_further_info(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_absence_attendance_id =>      l_absence_id
       ,p_segment_name =>               p_segment_name
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );

    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;

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

  END ben_get_absence_further_info;

-- ben_get_absence_further_info returns the value of the items
-- from the flex filed Additional Absence Details.
  FUNCTION ben_get_absence_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_get_absence_addnl_attr';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_business_group_id:'||p_business_group_id);
      debug(p_effective_date);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_segment_name'||p_segment_name);

    END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.pqp_get_absence_addnl_attr(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_absence_attendance_id =>      l_absence_id
       ,p_segment_name =>               p_segment_name
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );

    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;


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

  END ben_get_absence_addnl_attr;

-- ben_get_ssp_medicals_details is the main function to get the value
-- of the column from table SSP_MEDICALS
  FUNCTION ben_get_ssp_medicals_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_get_ssp_medicals_details';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_assignment_id:'||p_assignment_id);
      debug(p_effective_date);
      debug('p_col_name'||p_col_name);
    END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.pqp_get_ssp_medicals_details(
        p_absence_attendance_id =>      l_absence_id
       ,p_col_name =>                   p_col_name
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );
    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;


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

  END ben_get_ssp_medicals_details;

-- ben_get_absence_further_info returns the value of the items
-- from the flex filed SSP_MEDICALS
  FUNCTION ben_get_ssp_medical_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_get_ssp_medical_addnl_attr';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_business_group_id:'||p_business_group_id);
      debug(p_effective_date);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_segment_name'||p_segment_name);
    END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.pqp_get_ssp_medical_addnl_attr(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_absence_attendance_id =>      l_absence_id
       ,p_segment_name =>               p_segment_name
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );
    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;


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

  END ben_get_ssp_medical_addnl_attr;

-- ben_get_ssp_matrnty_details is the main function to get the value
-- of the column from table SSP_MATERNITIES
  FUNCTION ben_get_ssp_matrnty_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_get_ssp_matrnty_details';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_assignment_id:'||p_assignment_id);
      debug(p_effective_date);
      debug('p_col_name'|| p_col_name);
    END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.pqp_get_ssp_matrnty_details(
        p_absence_attendance_id =>      l_absence_id
       ,p_col_name =>                   p_col_name
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );
    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
                END IF;
    RETURN l_val;

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
  END ben_get_ssp_matrnty_details;

-- ben_get_ssp_matrnty_addnl_attr returns the value of the items
-- from the flex filed SSP_MATERNITIES
  FUNCTION ben_get_ssp_matrnty_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_get_ssp_matrnty_addnl_attr';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_business_group_id:'||p_business_group_id);
      debug(p_effective_date);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_segment_name'|| p_segment_name);
    END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.pqp_get_ssp_matrnty_addnl_attr(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_absence_attendance_id =>      l_absence_id
       ,p_segment_name =>               p_segment_name
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );
    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;

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

  END ben_get_ssp_matrnty_addnl_attr;

-- function returns the values of the look up code which is the column name
-- related to the prompt defined in lookup
  FUNCTION get_lookup_code(
    p_lookup_type               IN       VARCHAR2
   ,p_lookup_meaning            IN       VARCHAR2
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_lookup_code                 fnd_lookup_values_vl.lookup_code%TYPE;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_lookup_code';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_lookup_type'|| p_lookup_type);
      debug('p_lookup_meaning'|| p_lookup_meaning);
    END IF;
    OPEN csr_lookup_code(
          p_lookup_type =>                p_lookup_type
         ,p_lookup_meaning =>             p_lookup_meaning
                        );
    FETCH csr_lookup_code INTO l_lookup_code;

    --
    IF csr_lookup_code%NOTFOUND
    THEN
      fnd_message.set_name('PQP', 'PQP_230598_INV_TITLE');
      fnd_message.set_token('LKUP_MEANING', p_lookup_meaning);
      p_message := fnd_message.get();
--          CLOSE csr_lookup_code ;
--        RETURN NULL ;
    END IF;

    --
    CLOSE csr_lookup_code;
    IF g_debug THEN
      debug('l_lookup_code:'||l_lookup_code);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_lookup_code;

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
  END get_lookup_code;

-- get_absence_details Returns the value of the column in table
-- per_absence_attendances. Inputs are absence_attendance_id and the title
-- of the column in the absence form.The mapping of form title to the DB
-- column is done in Lookup and the same is fetched by calling
-- get_lookup_code function. For the Fields which are displayed from
-- Other Tables are derived individually and those columns are ABSENCE_TYPE,
-- ABSENCE_CATEGORY, ABSENCE_REASON, AUTHORIZATION PERSON,
-- AUTHORIZATION PERSON EMPLOYEE NUMBER ,REPLACEMENT PERSON NAME,
-- REPLACEMENT PERSON EMPLOYEE NUMBER
  FUNCTION get_absence_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_absence_details';
    l_col_name                    VARCHAR2(30);
    l_val                         VARCHAR2(2000);
    l_person_det                  VARCHAR2(250);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_title:'|| p_title);
    END IF;
    -- Call get_lookup_code to get the Database column name.
    l_col_name :=
      pqp_gb_osp_functions.get_lookup_code(
        p_lookup_type =>                'PQP_GET_ABSENCE_DETAILS'
       ,p_lookup_meaning =>             p_title
       ,p_message =>                    p_message
      );

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
      debug_exit(l_proc_name || ' ' || p_message);
      RETURN NULL;
    ELSIF l_col_name = 'ABSENCE_TYPE'
    THEN
      --
      debug(l_proc_name, 10);
      OPEN csr_abs_type(p_absence_attendance_id => p_absence_attendance_id);
      FETCH csr_abs_type INTO l_val;
      CLOSE csr_abs_type;
    --
    ELSIF l_col_name = 'ABSENCE_CATEGORY'
    THEN
      --
      debug(l_proc_name, 20);
      OPEN csr_abs_cat(p_absence_attendance_id => p_absence_attendance_id);
      FETCH csr_abs_cat INTO l_val;
      CLOSE csr_abs_cat;
    --
    ELSIF l_col_name = 'ABSENCE_REASON'
    THEN
      --
      debug(l_proc_name, 30);
      OPEN csr_abs_rea(p_absence_attendance_id => p_absence_attendance_id);
      FETCH csr_abs_rea INTO l_val;
      CLOSE csr_abs_rea;
    --
    ELSIF l_col_name IN('AUTH_NAME', 'AUTH_NUM', 'REPL_NAME', 'REPL_NUM')
    THEN
      --
      IF l_col_name LIKE 'AUTH%'
      THEN
        debug(l_proc_name, 40);
        l_person_det :=
          pqp_gb_osp_functions.pqp_get_absence_attendances(
            p_absence_attendance_id =>      p_absence_attendance_id
           ,p_col_name =>                   'AUTHORISING_PERSON_ID'
           ,p_error_code =>                 p_error_code
           ,p_message =>                    p_message
          );
      ELSE
        debug(l_proc_name, 50);
        l_person_det :=
          pqp_gb_osp_functions.pqp_get_absence_attendances(
            p_absence_attendance_id =>      p_absence_attendance_id
           ,p_col_name =>                   'REPLACEMENT_PERSON_ID'
           ,p_error_code =>                 p_error_code
           ,p_message =>                    p_message
          );
      END IF;

      --
        --
      IF l_person_det IS NOT NULL
      THEN
        IF l_col_name LIKE '%NAME'
        THEN
          debug(l_proc_name, 60);
          l_val :=
            pqp_utilities.get_col_value(
              p_col_nam =>                    'FULL_NAME'
             ,p_key_val =>                    l_person_det
             ,p_table =>                      'PER_PEOPLE_V'
             ,p_key_col =>                    'PERSON_ID'
             ,p_where =>                      NULL
             ,p_error_code =>                 p_error_code
             ,p_message =>                    p_message
            );
        ELSE
          debug(l_proc_name, 70);
          l_val :=
            pqp_utilities.get_col_value(
              p_col_nam =>                    'EMPLOYEE_NUMBER'
             ,p_key_val =>                    l_person_det
             ,p_table =>                      'PER_PEOPLE_V'
             ,p_key_col =>                    'PERSON_ID'
             ,p_where =>                      NULL
             ,p_error_code =>                 p_error_code
             ,p_message =>                    p_message
            );
        END IF;
      END IF;
    --
    ELSE
      --
        -- Call pqp_get_absence_details to get the value of the column.
      debug(l_proc_name, 80);
      l_val :=
        pqp_gb_osp_functions.pqp_get_absence_attendances(
          p_absence_attendance_id =>      p_absence_attendance_id
         ,p_col_name =>                   l_col_name
         ,p_error_code =>                 p_error_code
         ,p_message =>                    p_message
        );
    --
    END IF;

    IF g_debug THEN
      debug('l_val'|| l_val);
      debug_exit(l_proc_name);
    END IF;

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
    ELSE
      p_error_code := 0;
    END IF;

    RETURN l_val;

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
  END get_absence_details;

-- ben_get_absence_details is the main function to get the value
-- of the column from table per_absence_attendances.Called from
-- BEN where assignment_id and effective Date are contexts.
  FUNCTION ben_get_absence_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_get_absence_details';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_title:'||p_title);
    END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.get_absence_details(
        p_absence_attendance_id =>      l_absence_id
       ,p_title =>                      p_title
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
    ELSE
      p_error_code := 0;
    END IF;

    IF g_debug THEN
      debug('l_val'|| l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;

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
  END ben_get_absence_details;

-- get_medical_details Returns the value of the column in table
-- ssp_medicals. Inputs are absence_attendance_id and the title
-- of the column in the absence form.The mapping of form title to the DB
-- column is done in Lookup and the same is fetched by calling
-- get_lookup_code function.
  FUNCTION get_medical_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_medical_details';
    l_col_name                    VARCHAR2(30);
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_title'||p_title);
    END IF;
    -- Call get_lookup_code to get the Database column name.
    debug(l_proc_name, 10);
    l_col_name :=
      pqp_gb_osp_functions.get_lookup_code(
        p_lookup_type =>                'PQP_GET_ABSENCE_EVIDENCE'
       ,p_lookup_meaning =>             p_title
       ,p_message =>                    p_message
      );

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
      debug_exit(l_proc_name || ' ' || p_message);
      RETURN NULL;
    ELSE
      --
      debug(l_proc_name, 20);
      -- Call pqp_get_absence_details to get the value of the column.
      l_val :=
        pqp_gb_osp_functions.pqp_get_ssp_medicals_details(
          p_absence_attendance_id =>      p_absence_attendance_id
         ,p_col_name =>                   l_col_name
         ,p_error_code =>                 p_error_code
         ,p_message =>                    p_message
        );
    --
    END IF;

    IF g_debug THEN
      debug('l_val'|| l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;

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
  END get_medical_details;

-- get_matrnty_details Returns the value of the column in table
-- ssp_maternities. Inputs are absence_attendance_id and the title
-- of the column in the absence form.The mapping of form title to the DB
-- column is done in Lookup and the same is fetched by calling
-- get_lookup_code function.
  FUNCTION get_matrnty_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_matrnty_details';
    l_col_name                    VARCHAR2(30);
    l_val                         VARCHAR2(2000);
    l_due_date                    VARCHAR2(200);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_title:'||p_title);
    END IF;
    -- Call get_lookup_code to get the Database column name.
    debug(l_proc_name, 10);
    l_col_name :=
      pqp_gb_osp_functions.get_lookup_code(
        p_lookup_type =>                'PQP_GET_MATERNITY'
       ,p_lookup_meaning =>             p_title
       ,p_message =>                    p_message
      );

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
      debug_exit(l_proc_name || ' ' || p_message);
      RETURN NULL;
    ELSIF l_col_name = 'SMPQUADAT'
    THEN
      -- The Values are not directly stored but Derived.
      -- SMP Qualifying Date is Derived Based on Due_Date. First Due_Date is
      -- Fetched and Qualifying Date is Derived.
      debug(l_proc_name, 20);
      l_due_date :=
        pqp_gb_osp_functions.pqp_get_ssp_matrnty_details(
          p_absence_attendance_id =>      p_absence_attendance_id
         ,p_col_name =>                   'DUE_DATE'
         ,p_error_code =>                 p_error_code
         ,p_message =>                    p_message
        );

      IF p_message IS NULL
      THEN
        BEGIN
          SELECT fnd_date.date_to_canonical(
                   ssp_smp_pkg.qualifying_week(fnd_date.canonical_to_date(l_due_date))
                 )
          INTO   l_val
          FROM   DUAL;
        EXCEPTION
          WHEN OTHERS
          THEN
            p_error_code := -1;
            p_message := SQLERRM;
            RETURN NULL;
        END;
      END IF;
    ELSIF l_col_name = 'EWC'
    THEN
      -- The Values are not directly stored but Derived.
      -- EWC is Derived based on Due_Date, so fetch the Due_Date and the
      -- Derive EWC.
      debug(l_proc_name, 30);
      debug(l_proc_name, 40);
      l_due_date :=
        pqp_gb_osp_functions.pqp_get_ssp_matrnty_details(
          p_absence_attendance_id =>      p_absence_attendance_id
         ,p_col_name =>                   'DUE_DATE'
         ,p_error_code =>                 p_error_code
         ,p_message =>                    p_message
        );

      IF p_message IS NULL
      THEN
        BEGIN
          SELECT fnd_date.date_to_canonical(
                   ssp_smp_pkg.expected_week_of_confinement(fnd_date.canonical_to_date(l_due_date))
                 )
          INTO   l_val
          FROM   DUAL;
        EXCEPTION
          WHEN OTHERS
          THEN
            p_error_code := -1;
            p_message := SQLERRM;
            RETURN NULL;
        END;
      END IF;
    ELSE
      --
        -- Call pqp_get_absence_details to get the value of the column.
      debug(l_proc_name, 50);
      l_val :=
        pqp_gb_osp_functions.pqp_get_ssp_matrnty_details(
          p_absence_attendance_id =>      p_absence_attendance_id
         ,p_col_name =>                   l_col_name
         ,p_error_code =>                 p_error_code
         ,p_message =>                    p_message
        );
    --
    END IF;

    IF g_debug THEN
      debug('l_val'||l_val);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_val;

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
  END get_matrnty_details;
--
--
--
FUNCTION get_override_entitlements
   (p_assignment_id                IN            NUMBER
   ,p_business_group_id            IN            NUMBER
   ,p_pl_id                        IN            NUMBER
   ,p_effective_date               IN            DATE
   ,p_band_entitlements               OUT NOCOPY pqp_absval_pkg.t_entitlements
   ,p_absence_pay_plan_class       IN            VARCHAR2 DEFAULT 'OMP'
   ,p_omp_intend_to_return_to_work IN            VARCHAR2 DEFAULT 'X'
   ,p_entitlement_bands_list_name  IN            VARCHAR2 DEFAULT
      'PQP_GAP_ENTITLEMENT_BANDS'
   ) RETURN BOOLEAN
IS

    CURSOR csr_override_entitlement
      (p_assignment_id  IN NUMBER
      ,p_effective_date IN DATE
      ,p_pl_id_txt      IN VARCHAR2
      ) IS
    SELECT pei_information1  override_start_date_txt
          ,pei_information2  override_end_date_txt
          ,pei_information11 band1
          ,pei_information12 band2
          ,pei_information13 band3
          ,pei_information14 band4
    FROM   per_all_assignments_f asg
          ,per_people_extra_info pei
    WHERE  asg.assignment_id = p_assignment_id -- index primary key
      AND  p_effective_date
             BETWEEN asg.effective_start_date
                 AND asg.effective_end_date
      AND  pei.person_id = asg.person_id -- index PER_PEOPLE_EXTRA_INFO_N50
      AND  pei.information_type = 'PQP_GB_GAP_ENTITLEMENT_INFO'
      AND  pei.pei_information3 = p_pl_id_txt;

    l_override_entitlement  csr_override_entitlement%ROWTYPE;

    l_override_entitlement_found BOOLEAN:= FALSE;

    l_pl_id_txt             per_people_extra_info.pei_information3%TYPE;

    l_band_entitlements     pqp_absval_pkg.t_entitlements;

    i                       BINARY_INTEGER:= 0;
    l_band_entitlement      NUMBER;

    l_proc_step             NUMBER(38,10);
    l_proc_name             VARCHAR2(61):=
      g_package_name||'get_override_entitlements';

BEGIN

  IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_pl_id:'||p_pl_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
 END IF;

--  IF p_absence_pay_plan_class = 'OSP'
--  THEN -- check for an override, OMP does not yet need to support overrides

    l_proc_step := 10;
    debug(l_proc_name, l_proc_step);

    -- loop through the override entitlements and determine the first one
    -- in which the given effective date falls.
    -- NOTE: we need to do this outside the SQL query and not inlcude
    -- the p_effective date between clause in the SQL statement for two
    -- reasons
    -- a) performance
    -- b) depending on the explain plan the SQL query maybe executed
    --    using a different route which might cause the query to pei for
    --    information_types other than the one desired which might cause
    --    the fnd_date conversion to fail.
    l_override_entitlement_found := FALSE;

    l_pl_id_txt := fnd_number.number_to_canonical(p_pl_id);

    FOR r_override_entitlement
      IN csr_override_entitlement
           (p_assignment_id  => p_assignment_id
           ,p_effective_date => p_effective_date
           ,p_pl_id_txt      => l_pl_id_txt)
    LOOP

        l_proc_step := 20;
        debug(l_proc_name, l_proc_step);

      IF p_effective_date BETWEEN
        fnd_date.canonical_to_date
          (r_override_entitlement.override_start_date_txt)
        AND
        fnd_date.canonical_to_date
          (r_override_entitlement.override_end_date_txt)
      THEN

        l_proc_step := 25;
        debug(l_proc_name, l_proc_step);

        l_override_entitlement := r_override_entitlement;
        l_override_entitlement_found := TRUE;

      END IF;

    END LOOP;

    IF l_override_entitlement_found
    THEN

      l_proc_step := 30;
      debug(l_proc_name, l_proc_step);

      -- think of a way for removing hard coded band names

      l_band_entitlement :=
        fnd_number.canonical_to_number(l_override_entitlement.band1);

      --IF l_band_entitlement > 0
      --THEN
      i := i + 1;
      l_band_entitlements(i).band := 'BAND1';
      l_band_entitlements(i).meaning :=
        hr_general.decode_lookup
          (p_entitlement_bands_list_name
          ,l_band_entitlements(i).band);
      l_band_entitlements(i).entitlement := l_band_entitlement;
      --END IF;

      l_band_entitlement := fnd_number.canonical_to_number(l_override_entitlement.band2);

      IF l_band_entitlement > 0
      THEN
        i := i + 1;
        l_band_entitlements(i).band := 'BAND2';
        l_band_entitlements(i).meaning :=
          hr_general.decode_lookup
            (p_entitlement_bands_list_name
            ,l_band_entitlements(i).band);
        l_band_entitlements(i).entitlement := l_band_entitlement;
      END IF;

      l_band_entitlement := fnd_number.canonical_to_number(l_override_entitlement.band3);

      IF l_band_entitlement > 0
      THEN
        i := i + 1;
        l_band_entitlements(i).band := 'BAND3';
        l_band_entitlements(i).meaning :=
          hr_general.decode_lookup
           (p_entitlement_bands_list_name
           ,l_band_entitlements(i).band);
        l_band_entitlements(i).entitlement := l_band_entitlement;
      END IF;

      l_band_entitlement := fnd_number.canonical_to_number(l_override_entitlement.band4);

      IF l_band_entitlement > 0
      THEN
        i := i + 1;
        l_band_entitlements(i).band := 'BAND4';
        l_band_entitlements(i).meaning :=
          hr_general.decode_lookup
            (p_entitlement_bands_list_name
            ,l_band_entitlements(i).band);
        l_band_entitlements(i).entitlement := l_band_entitlement;
      END IF;

    END IF; -- IF l_override_entitlement.override_start_date_txt IS NOT NULL

--  END IF; -- IF p_absence_pay_plan_class = 'OSP'

  l_proc_step := 35;
  debug(l_proc_name, l_proc_step);

  p_band_entitlements := l_band_entitlements;

  IF g_debug THEN
     debug_exit(l_proc_name);
  END IF;
  RETURN l_override_entitlement_found;

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
END get_override_entitlements;
--
--
--
  FUNCTION get_los_based_entitlements
   (p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_absence_pay_plan_class    IN       VARCHAR2
   ,p_entitlement_table_id      IN       NUMBER
   ,p_benefits_length_of_service IN      NUMBER
   ,p_band_entitlements         OUT NOCOPY pqp_absval_pkg.t_entitlements
   ,p_error_msg                 OUT NOCOPY VARCHAR2
   ,p_omp_intend_to_return_to_work IN    VARCHAR2 DEFAULT 'X'
   ,p_entitlement_bands_list_name IN     VARCHAR2 DEFAULT
      'PQP_GAP_ENTITLEMENT_BANDS'
   ,p_is_ent_override             IN OUT NOCOPY BOOLEAN
   )
    RETURN NUMBER
  IS
    l_user_column_id              pay_user_columns.user_column_id%TYPE;
    l_band_ent                    pqp_absval_pkg.t_entitlements;
    l_band_entitlement            NUMBER;
    l_retval                      NUMBER;

    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_LOS_based_entitlements';

    i                             BINARY_INTEGER;
    l_column_name                 hr_lookups.meaning%TYPE;
    l_lookup_code                 hr_lookups.lookup_code%TYPE;

    --l_fte                         csr_get_asg_fte_value%ROWTYPE;
    l_fte_value                   per_assignment_budget_values.value%TYPE;

    -- for the moment private cursors
    -- as we do not want to encourage their use outside this function

    CURSOR csr_omp_entitlement_UOM
      (p_entitlement_UDT_id IN NUMBER
      ) IS
    SELECT eei_information9 UOM -- "Absence Entitlement Days Type" segment
    FROM   pay_element_type_extra_info
    WHERE  information_type = 'PQP_GB_OMP_ABSENCE_PLAN_INFO' -- OMP col indexed
      AND  eei_information11 = -- "Absence Entitlement Parameters" segment
            fnd_number.number_to_canonical(p_entitlement_UDT_id);


    CURSOR csr_osp_entitlement_UOM
      (p_entitlement_UDT_id IN NUMBER
      ) IS
    SELECT eei_information8 UOM -- "Absence Days" segment
    FROM   pay_element_type_extra_info
    WHERE  information_type = 'PQP_GB_OSP_ABSENCE_PLAN_INFO' -- OSP col indexed
      AND  eei_information9 = -- "Absence Entitlement Sick Leave" segment
            fnd_number.number_to_canonical(p_entitlement_UDT_id);

    l_entitlement_UOM              pay_element_type_extra_info.eei_information8%TYPE;
    l_entitlement_override_is_set  BOOLEAN:= FALSE;


  BEGIN
    --
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,5);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_business_group_id:'||p_business_group_id);
      debug(p_effective_date);
      debug('p_pl_id:'||p_pl_id);
      debug('p_absence_pay_plan_class'||p_absence_pay_plan_class);
      debug('p_entitlement_table_id:'||p_entitlement_table_id);
      debug('p_benefits_length_of_service:'||p_benefits_length_of_service);
  END IF;
    --
    -- Determine if the person has any override entitlement against the
    -- assignment/person. If the person has any override entitlement
    -- defined against the person then use that and do NOT multiply the FTE
    -- to that value.
    -- The override entitlements could be supported for either OSP or OMP.
    -- At the moment it doesnot apply to OMP.
    --

--    IF p_absence_pay_plan_class = 'OSP'
--    THEN

      l_proc_step := 10;
      debug(l_proc_name, l_proc_step);

      l_entitlement_override_is_set :=
        get_override_entitlements
        (p_assignment_id                => p_assignment_id
        ,p_business_group_id            => p_business_group_id
        ,p_pl_id                        => p_pl_id
        ,p_effective_date               => p_effective_date
        ,p_band_entitlements            => l_band_ent
        ,p_absence_pay_plan_class       => p_absence_pay_plan_class -- Default OMP
        ,p_entitlement_bands_list_name  => p_entitlement_bands_list_name
        );

--    END IF; -- IF p_absence_pay_plan_class = 'OSP'

    IF NOT l_entitlement_override_is_set THEN

      l_proc_step := 15;
      debug(l_proc_name, l_proc_step);

      -- has no override set or is an OMP entitlement

      -- Determine the UOM for this scheme using p_entitlement_table_id
      -- to determine the UOM
      -- we need to hit element extra information
      -- to find and OSP/OMP information type which has
      -- PQP_GB_OMP_ABSENCE_PLAN_INFO or PQP_GB_OSP_ABSENCE_PLAN_INFO
      -- which has a "Absence Entitlement Parameters" (OMP EEI_INFORMATION11)
      -- or "Absence Entitlement Sick Leave" (OSP EEI_INFORMATION9)
      -- that matches with the given table id
      -- and then determine its entitlement UOM (OSP "Absence Days"
      -- EEI_INFORMATION8) (OMP Absence Entitlement Days Type EEI_INFORMATION9)
      -- since this is an inefficient hit and we are loathe to add a UOM
      -- parameter the UOM will be cached for a given entitlement_table_id

      debug('g_entitlement_UDT_id:'|| g_entitlement_UDT_id);
      debug('p_entitlement_table_id:'||to_char(p_entitlement_table_id));
      debug('g_entitlement_UOM:'||g_entitlement_UOM);

      IF g_entitlement_UDT_id <> p_entitlement_table_id
        OR
         g_entitlement_UDT_id IS NULL
        OR
         g_entitlement_UOM IS NULL
      THEN

      l_proc_step := 20;
      debug(l_proc_name, l_proc_step);


        IF p_absence_pay_plan_class = 'OSP'
        THEN

      l_proc_step := 25;
      debug(l_proc_name, l_proc_step);

          OPEN csr_osp_entitlement_UOM(p_entitlement_table_id);
          FETCH csr_osp_entitlement_UOM INTO l_entitlement_UOM;
          CLOSE csr_osp_entitlement_UOM;

        ELSE -- IF p_absence_pay_plan_class = 'OSP' THEN

      l_proc_step := 30;
      debug(l_proc_name, l_proc_step);

          -- must be p_absence_pay_plan_class = 'OMP' THEN
          OPEN csr_omp_entitlement_UOM(p_entitlement_table_id);
          FETCH csr_omp_entitlement_UOM INTO l_entitlement_UOM;
          CLOSE csr_omp_entitlement_UOM;

        END IF; -- IF p_absence_pay_plan_class = 'OSP' THEN

        -- Cache the UDT id and UOM
        g_entitlement_UDT_id := p_entitlement_table_id;
        g_entitlement_UOM := l_entitlement_UOM;

      ELSE --IF g_entitlement_UDT_id <> p_entitlement_table_id
        -- we need the UOM for the same UDT id as before
        -- use cached value
        l_proc_step := 35;
        debug(l_proc_name, l_proc_step);
        l_entitlement_UOM := g_entitlement_UOM;

      END IF; --IF g_entitlement_UDT_id <> p_entitlement_table_id

    IF g_debug THEN
      debug('l_entitlement_UOM:'||l_entitlement_UOM);
    END IF;

    IF l_entitlement_UOM IN ( 'H', 'WH')
    THEN

      l_proc_step := 40;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- Determine the FTE
      l_fte_value :=
        pqp_fte_utilities.get_fte_value
          (p_assignment_id    => p_assignment_id
          ,p_calculation_date => p_effective_date);

      IF g_debug THEN
        debug('l_fte_value:'||l_fte_value);
      END IF;

    END IF;

    -- Set the FTE to 1 if no FTE is found or it was a days based scheme
    IF l_fte_value IS NULL THEN
      l_proc_step := 45;
      l_fte_value := 1;
      IF g_debug THEN
        debug('l_fte_value:'||l_fte_value);
      END IF;
    END IF;


    OPEN csr_get_lookup_info(p_entitlement_bands_list_name, 'BAND%');
    FETCH csr_get_lookup_info INTO l_column_name, l_lookup_code;

    --IF csr_get_lookup_info%FOUND -- why not found ?
    --THEN
      i := 1;

      debug('l_column_name:'||l_column_name);
      l_proc_step := 50;
      debug(l_proc_name, l_proc_step);

      IF p_absence_pay_plan_class = 'OMP'
      THEN
        l_proc_step := 55;
        debug(l_proc_name, l_proc_step);
        l_column_name := l_column_name || p_omp_intend_to_return_to_work;
      END IF;

      l_retval :=
        pqp_utilities.pqp_gb_get_table_value_id(
          p_business_group_id =>          p_business_group_id
         ,p_effective_date =>             p_effective_date
         ,p_table_id =>                   p_entitlement_table_id
         ,p_column_name =>                l_column_name
         ,p_row_name =>                   p_benefits_length_of_service
         ,p_value =>                      l_band_entitlement
         ,p_error_msg =>                  p_error_msg
        );

      IF l_retval < 0 THEN
        l_proc_step := 60;
        debug(l_proc_name, l_proc_step);
        check_error_code(l_retval,p_error_msg);
      END IF;

      --IF l_band_entitlement IS NULL THEN -- remove
      --  --
      --  -- If there is no value defined
      --  --
      --  CLOSE csr_get_lookup_info;
      --  p_error_msg := fnd_message.get_string('PQP', 'PQP_230603_DEF_BAND1');
      --  debug(p_error_msg);
      --  debug_exit(l_proc_name);
      --  RETURN -1;
       --
      --ELSE -- IF l_band_entitlement IS NULL THEN

        l_band_ent(i).band        := l_lookup_code;
        l_band_ent(i).meaning     := l_column_name;
        l_band_ent(i).entitlement := NVL(l_band_entitlement,0) * l_fte_value;
        -- For Band1 we are NLVing the entitlement
        -- this ensures that when the code to get the entitlement parameters
        -- tries to get a percentage (and/or earning type value) it will
        -- error out if the percentage values for Band1 have not been
        -- defined.
        -- the purpose is two fold,
        -- one the process should error if the UDT setup isn't complete
        -- two the process should not error if band1 entitlement has not been
        --     entered. This allows us to setup LOS bands which have just
        --     band2 and 3 but not band1 and also makes the system have fewer
        --     error raising points.
        -- I suspect this will break some other code. but need to test


      --END IF; -- IF l_band_entitlement IS NULL THEN

        l_proc_step := 70;
        debug(l_proc_name, l_proc_step);

      LOOP

        l_proc_step := 75;
        debug(l_proc_name, l_proc_step);

        FETCH csr_get_lookup_info INTO l_column_name, l_lookup_code;
        EXIT WHEN csr_get_lookup_info%NOTFOUND;
        i := i + 1;

        l_proc_step := 75;
        debug(l_proc_name, l_proc_step+i/100);

        IF p_absence_pay_plan_class = 'OMP'
        THEN
          l_proc_step := 80;
          debug(l_proc_name, l_proc_step+i/100);
          l_column_name := l_column_name || p_omp_intend_to_return_to_work;
        END IF;

        debug('l_column_name: '||l_column_name);

        l_proc_step := 85;
        debug(l_proc_name, l_proc_step+i/100);

        l_retval :=
          pqp_utilities.pqp_gb_get_table_value_id(
            p_business_group_id =>          p_business_group_id
           ,p_effective_date =>             p_effective_date
           ,p_table_id =>                   p_entitlement_table_id
           ,p_column_name =>                l_column_name
           ,p_row_name =>                   p_benefits_length_of_service
           ,p_value =>                      l_band_entitlement
           ,p_error_msg =>                  p_error_msg
          );

        IF    l_retval < 0
        THEN
          l_proc_step := 87;
          debug(l_proc_name, l_proc_step+i/100);
          check_error_code(l_retval,p_error_msg);
        END IF;

        --IF l_band_entitlement IS NULL -- removed this check
        --THEN -- to allow easy setup wherein I may want band1 and 3 but not 2
               -- for a particular LOS range but in the same scheme a diff LOS range
               -- gets all three bands.
        --  CLOSE csr_get_lookup_info;
        --  p_band_entitlements := l_band_ent;
        --  p_error_msg := NULL;
        --  debug_exit(l_proc_name);
        --  RETURN 0;

        --ELSE

        IF l_band_entitlement IS NOT NULL
        THEN
          l_proc_step := 90;
          debug(l_proc_name, l_proc_step+i/100);
          -- by checking for NOT NULL
          -- we are ensuring we only store the details of only those
          -- bands which have some information setup even its 0
          -- may even check for 0...hmmm
          l_band_ent(i).band        := l_lookup_code;
          l_band_ent(i).meaning     := l_column_name;
          l_band_ent(i).entitlement := l_band_entitlement * l_fte_value;
        END IF;

        --END IF; -- End if of retval -1 Check...
        l_proc_step := 95;
        debug(l_proc_name, l_proc_step+i/100);

      END LOOP;

      l_proc_step := 100;
      debug(l_proc_name, l_proc_step);

      CLOSE csr_get_lookup_info;

    END IF; --IF NOT l_entitlement_override_is_set THEN

    l_proc_step := 110;
    debug(l_proc_name, l_proc_step);

    p_is_ent_override   := l_entitlement_override_is_set ;
    p_band_entitlements := l_band_ent;
    --
    --END IF; -- End if of row found check ...
    --
    debug_exit(l_proc_name);
    RETURN 0;

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
  END get_los_based_entitlements;
--
--
--
  FUNCTION pqp_get_band_ent_parameters(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_pay_plan_class    IN       VARCHAR2
   ,p_entitlement_table_id      IN       NUMBER
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_entitlement_parameters    OUT NOCOPY r_entitlement_parameters
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_user_column_id              pay_user_columns.user_column_id%TYPE;
    l_band_ent_rows               r_entitlement_parameters;
    l_band_percentage             NUMBER;
    l_lookup_code                 hr_lookups.lookup_code%TYPE;
    l_row_val                     hr_lookups.meaning%TYPE;
    l_row_earn_type               hr_lookups.meaning%TYPE;
    l_band_avg_rec_ind            hr_lookups.meaning%TYPE;
    l_retval                      NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_band_ent_parameters';
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug(p_effective_date);
      debug('p_absence_pay_plan_class'||p_absence_pay_plan_class);
      debug('p_entitlement_table_id:'||p_entitlement_table_id);
      debug('p_level_of_entitlement'||p_level_of_entitlement);
    END IF;

    -- Get Percentage

    l_row_val := NULL;
    OPEN csr_get_lookup_info
      ('PQP_GAP_ENTITLEMENT_ROWS'
      ,'GB_GAP_PERCENTAGE_ROW');
    FETCH csr_get_lookup_info INTO l_row_val, l_lookup_code;
    CLOSE csr_get_lookup_info;

    debug('p_level_of_entitlement:'||p_level_of_entitlement);
    l_retval :=
      pqp_utilities.pqp_gb_get_table_value_id(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_table_id =>                   p_entitlement_table_id
       ,p_column_name =>                p_level_of_entitlement
       ,p_row_name =>                   l_row_val
       ,p_value =>                      l_band_percentage
       ,p_error_msg =>                  p_error_msg
      );


    IF    l_retval < 0
    THEN
      check_error_code(l_retval,p_error_msg);
    END IF;

    IF l_band_percentage IS NULL
    THEN
      fnd_message.set_name('PQP', 'PQP_230604_DEF_BND_PER');
      fnd_message.set_token('BAND', p_level_of_entitlement);
      p_error_msg := fnd_message.get();
      debug_exit(l_proc_name);
      RETURN -1;
    ELSE
      l_band_ent_rows.meaning := p_level_of_entitlement;
      l_band_ent_rows.percentage := l_band_percentage;
    END IF;         -- End if of retval = -1 Check ...
            --

    IF p_absence_pay_plan_class = 'OMP'
    THEN
      -- Get Earnings Row
      l_row_earn_type := NULL;
      OPEN csr_get_lookup_info
        ('PQP_GAP_ENTITLEMENT_ROWS'
        ,'GB_OMP_EARNINGS_TYPE_ROW'
        );
      FETCH csr_get_lookup_info INTO l_row_earn_type, l_lookup_code;
      CLOSE csr_get_lookup_info;
      debug('p_level_of_entitlement:' || p_level_of_entitlement);
      debug(l_proc_name, 30);
      l_retval :=
        pqp_utilities.pqp_gb_get_table_value_id(
          p_business_group_id =>          p_business_group_id
         ,p_effective_date =>             p_effective_date
         ,p_table_id =>                   p_entitlement_table_id
         ,p_column_name =>                p_level_of_entitlement
         ,p_row_name =>                   l_row_earn_type
         ,p_value =>                      l_band_avg_rec_ind
         ,p_error_msg =>                  p_error_msg
        );

      IF    l_retval < 0 THEN
        check_error_code(l_retval,p_error_msg);
      END IF;

      IF l_band_avg_rec_ind IS NULL
      THEN
        fnd_message.set_name('PQP', 'PQP_230605_DEF_AVG_REC');
        fnd_message.set_token('BAND', p_level_of_entitlement);
        p_error_msg := fnd_message.get();
        debug(p_error_msg);
        debug_exit(l_proc_name);
        RETURN -1;
      ELSE
        l_band_ent_rows.earnings_type :=
          hr_general.decode_lookup(
            p_lookup_type =>                'PQP_GB_OMP_EARNINGS_TYPE'
           ,p_lookup_code =>                l_band_avg_rec_ind
          );
      END IF; -- IF l_band_avg_rec_ind IS NULL

    END IF; -- IF p_absence_pay_plan_class = 'OMP'

    p_entitlement_parameters := l_band_ent_rows;
    --
    debug_exit(l_proc_name);
    RETURN 0;
  --


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
  END pqp_get_band_ent_parameters;

  --

  --
  FUNCTION get_entitlement_parameters( --pqp_get_entitlement_parameters
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_absence_pay_plan_class    IN       VARCHAR2
   ,p_entitlement_table_id      IN       NUMBER
   ,p_benefits_length_of_service IN      NUMBER
   ,p_entitlement_parameters    OUT NOCOPY t_entitlement_parameters
   ,p_error_msg                 OUT NOCOPY VARCHAR2
   ,p_omp_intend_to_return_to_work IN    VARCHAR2
   ,p_entitlement_bands_list_name IN     VARCHAR2
  )
    RETURN NUMBER
  IS
    l_user_column_id              pay_user_columns.user_column_id%TYPE;
    l_band_ent                    pqp_absval_pkg.t_entitlements;
    l_band_ent_rows               r_entitlement_parameters;
    l_ent_parameters              t_entitlement_parameters;
    l_band_entitlement            NUMBER;
    l_retval                      NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_entitlement_parameters';
    i                             NUMBER;
    l_column_name                 hr_lookups.meaning%TYPE;
    l_lookup_code                 hr_lookups.lookup_code%TYPE;

    l_is_ent_override             BOOLEAN := FALSE ;
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_pl_id:'||p_pl_id);
      debug('p_absence_pay_plan_class:'|| p_absence_pay_plan_class);
      debug('p_entitlement_table_id:'||p_entitlement_table_id);
      debug('p_benefits_length_of_service:'||p_benefits_length_of_service);
      debug('p_omp_intend_to_return_to_work:'||p_omp_intend_to_return_to_work);
      debug('p_entitlement_bands_list_name:'||p_entitlement_bands_list_name);
    END IF;

   IF p_absence_pay_plan_class = 'OSP' THEN
       get_entitlements
           (p_assignment_id              => p_assignment_id
           ,p_business_group_id          => p_business_group_id
           ,p_effective_date             => p_effective_date
           ,p_pl_id                      => p_pl_id
           ,p_entitlement_table_id       => p_entitlement_table_id
           ,p_benefits_length_of_service => p_benefits_length_of_service
           ,p_band_entitlements          => l_band_ent
           ) ;
       l_retval := 0 ;
   ELSE

    -- Get the entitlement information for each bands
    l_retval := --  pqp_
      get_los_based_entitlements(
        p_assignment_id =>                p_assignment_id
       ,p_business_group_id =>            p_business_group_id
       ,p_effective_date =>               p_effective_date
       ,p_pl_id =>                        p_pl_id
       ,p_absence_pay_plan_class =>       p_absence_pay_plan_class
       ,p_entitlement_table_id =>         p_entitlement_table_id
       ,p_benefits_length_of_service =>   p_benefits_length_of_service
       ,p_entitlement_bands_list_name =>  p_entitlement_bands_list_name
       ,p_band_entitlements =>            l_band_ent
       ,p_error_msg =>                    p_error_msg
       ,p_omp_intend_to_return_to_work => p_omp_intend_to_return_to_work
       ,p_is_ent_override              => l_is_ent_override
      );

    END IF ;



    IF l_retval < 0
    THEN
      debug(p_error_msg);
      debug_exit(l_proc_name);
      RETURN l_retval;
    ELSE
      i := l_band_ent.FIRST;

      WHILE i IS NOT NULL
      LOOP
        -- Get the entitlement parameter for each bands

        --IF l_band_ent(i).entitlement IS NOT NULL
        --THEN

       IF p_absence_pay_plan_class = 'OMP' and l_is_ent_override THEN
         l_band_ent(i).meaning := l_band_ent(i).meaning ||
                                  p_omp_intend_to_return_to_work ;
       END IF ;

          l_retval :=
            pqp_get_band_ent_parameters(
              p_business_group_id =>          p_business_group_id
             ,p_effective_date =>             p_effective_date
             ,p_absence_pay_plan_class =>     p_absence_pay_plan_class
             ,p_entitlement_table_id =>       p_entitlement_table_id
             ,p_level_of_entitlement =>       l_band_ent(i).meaning
             ,p_entitlement_parameters =>     l_band_ent_rows
             ,p_error_msg =>                  p_error_msg
            );

          IF l_retval < 0
          THEN
            debug(p_error_msg);
            debug_exit(l_proc_name);
            RETURN -1;
          END IF; -- End if of retval -1 check ...

        --END IF;

        l_ent_parameters(i).band := l_band_ent(i).band;
        l_ent_parameters(i).meaning := l_band_ent(i).meaning;
        l_ent_parameters(i).entitlement := l_band_ent(i).entitlement;
        l_ent_parameters(i).percentage := l_band_ent_rows.percentage;

        IF p_absence_pay_plan_class = 'OMP'
        THEN
          l_ent_parameters(i).earnings_type := l_band_ent_rows.earnings_type;
        END IF; -- End if of absence type = OMP check ....

        i := l_band_ent.NEXT(i);

      END LOOP;

    END IF;         -- End if of retval -1 check
            --

    p_entitlement_parameters := l_ent_parameters;
    debug_exit(l_proc_name);
    RETURN 0;

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
  END get_entitlement_parameters;

  --

-- pqp_get_band_ent_value Returns the values of entitlements and its
-- percentages of Band1 - Band4. Fatal error is raised if not a single
-- BAND entitlement is entered or Band entitlement is captured
-- without percentage. In case of fatal errors -1 is returned. If BAND1
-- is not defined then fatal error is raised. If BAND2 is not defined
-- then the remaining Bands are set to -1

  FUNCTION pqp_get_band_ent_value
    (p_business_group_id           IN            NUMBER
    ,p_effective_date              IN            DATE
    ,p_assignment_id               IN            NUMBER -- Context #3
    ,p_element_type_id             IN            NUMBER -- Context #4
    ,p_entitlement_tab_id          IN            NUMBER
    ,p_benefits_length_of_service  IN            NUMBER
    ,p_band1_entitlement              OUT NOCOPY NUMBER
    ,p_band1_percentage               OUT NOCOPY NUMBER
    ,p_band2_entitlement              OUT NOCOPY NUMBER
    ,p_band2_percentage               OUT NOCOPY NUMBER
    ,p_band3_entitlement              OUT NOCOPY NUMBER
    ,p_band3_percentage               OUT NOCOPY NUMBER
    ,p_band4_entitlement              OUT NOCOPY NUMBER
    ,p_band4_percentage               OUT NOCOPY NUMBER
    ,p_error_msg                      OUT NOCOPY VARCHAR2
    ,p_entitlement_bands_list_name IN            VARCHAR2 DEFAULT
       'PQP_GAP_ENTITLEMENT_BANDS'
    ,p_override_effective_date     IN            DATE DEFAULT NULL
    ) RETURN NUMBER
  IS
    l_user_column_id              pay_user_columns.user_column_id%TYPE;
    l_retval                      NUMBER;
    l_row_val                     NUMBER := -1;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_band_ent_value';
    i                             BINARY_INTEGER;
    l_band_ent                    t_entitlement_parameters;
    l_entitlement_parameters      t_entitlement_parameters;

    l_truncated_yes_no    VARCHAR2(30);
    l_pl_id_txt      pay_element_type_extra_info.eei_information1%TYPE;
    l_pl_id          ben_pl_f.pl_id%TYPE;

    l_effective_date      DATE;

-- Added for CS
    l_scheme_type    pay_element_type_extra_info.eei_information1%TYPE;
    l_default_work_pattern
            pay_element_type_extra_info.eei_information1%TYPE;
    l_entitlement_uom
            pay_element_type_extra_info.eei_information1%TYPE;
    l_absence_schedule_wp
            pay_element_type_extra_info.eei_information1%TYPE;
    l_track_part_timers
            pay_element_type_extra_info.eei_information1%TYPE;
    l_current_factor NUMBER ;
    l_ft_factor      NUMBER ;

    l_working_days_in_week
          pqp_gap_daily_absences.working_days_per_week%TYPE := 7 ;
    l_standard_work_days_in_week
          pqp_gap_daily_absences.working_days_per_week%TYPE ;
    l_entitlements_divisor NUMBER := 7 ;

    l_working_days_per_week pqp_gap_daily_absences.working_days_per_week%TYPE;
    l_fte           pqp_gap_daily_absences.fte%TYPE ;
    l_FT_absence_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_FT_working_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_assignment_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_is_full_timer BOOLEAN ;
    l_is_assignment_wp BOOLEAN;


  BEGIN
    --
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_element_type_id:'||p_element_type_id);
      debug('p_entitlement_tab_id:'||p_entitlement_tab_id);
      debug('p_benefits_length_of_service:'||p_benefits_length_of_service);
    END IF;
    p_band1_entitlement := -1;
    p_band1_percentage := 0;
    p_band2_entitlement := -1;
    p_band2_percentage := 0;
    p_band3_entitlement := -1;
    p_band3_percentage := 0;
    p_band4_entitlement := -1;
    p_band4_percentage := 0;

    l_effective_date := NVL(p_override_effective_date, p_effective_date);


    -- determine plan id for this given element type id

    l_retval :=
      pqp_utilities.pqp_get_extra_element_info(
        p_element_type_id   => p_element_type_id
       ,p_information_type  => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
       ,p_segment_name      => 'Plan Name'
       ,p_value             => l_pl_id_txt
       ,p_truncated_yes_no  => l_truncated_yes_no
       ,p_error_msg         => p_error_msg
      );

    IF l_retval < 0 THEN
      check_error_code(l_retval,p_error_msg);
    END IF;

    l_pl_id := fnd_number.canonical_to_number(l_pl_id_txt);

   --Set the global rounding factor cache if the values are not already set
    IF g_ft_entitl_rounding_type is null OR g_round_cache_plan_id <> l_pl_id THEN
        PQP_GB_OSP_FUNCTIONS.set_osp_omp_rounding_factors
          (p_pl_id                    => l_pl_id
          ,p_pt_entitl_rounding_type  => g_pt_entitl_rounding_type
          ,p_pt_rounding_precision    => g_pt_rounding_precision
          ,p_ft_entitl_rounding_type  => g_ft_entitl_rounding_type
          ,p_ft_rounding_precision    => g_ft_rounding_precision
          );
          g_round_cache_plan_id  := l_pl_id;
    END IF;

    l_retval :=
      get_entitlement_parameters(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             l_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_pl_id =>                      l_pl_id
       ,p_absence_pay_plan_class =>     'OSP'
       ,p_entitlement_table_id =>       p_entitlement_tab_id
       ,p_benefits_length_of_service => p_benefits_length_of_service
       ,p_entitlement_bands_list_name => p_entitlement_bands_list_name
       ,p_entitlement_parameters =>     l_entitlement_parameters
       ,p_error_msg =>                  p_error_msg
      );


    IF l_retval < 0
    THEN
      debug(p_error_msg);
      debug_exit(l_proc_name);
      RETURN -1;
    ELSE

-- Added for CS

    l_retval :=
      pqp_utilities.pqp_get_extra_element_info(
        p_element_type_id   => p_element_type_id
       ,p_information_type  => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
       ,p_segment_name      => 'Scheme Calendar Type'
       ,p_value             => l_scheme_type
       ,p_truncated_yes_no  => l_truncated_yes_no
       ,p_error_msg         => p_error_msg
      );

    IF l_retval < 0 THEN
      check_error_code(l_retval,p_error_msg);
    END IF;

-- In Civil Service Scheme for part timers and Fulltimers only one Entitlement
-- UDT is created. But the entitlements can be derived based on the
-- number of days the part timers work.
-- For example :
-- the standard entitlements for CS Full timer are BAND1-182 and BAND2-182
-- For a part timer working 3 days in week entitlements will be
-- BAND1 = FLOOR(182 * 3 / 7) = 78
-- BAND2 = FLOOR(182 * 3 / 7) = 78


    l_retval :=
      pqp_utilities.pqp_get_extra_element_info(
        p_element_type_id   => p_element_type_id
       ,p_information_type  => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
       ,p_segment_name      => 'Absence Default Work Pattern'
       ,p_value             => l_default_work_pattern
       ,p_truncated_yes_no  => l_truncated_yes_no
       ,p_error_msg         => p_error_msg
      );

    l_retval :=
      pqp_utilities.pqp_get_extra_element_info(
        p_element_type_id   => p_element_type_id
       ,p_information_type  => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
       ,p_segment_name      => 'Enable Entitlement Proration'
       ,p_value             => l_track_part_timers
       ,p_truncated_yes_no  => l_truncated_yes_no
       ,p_error_msg         => p_error_msg
      );
    l_retval :=
      pqp_utilities.pqp_get_extra_element_info(
        p_element_type_id   => p_element_type_id
       ,p_information_type  => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
       ,p_segment_name      => 'Absence Schedule Work Pattern'
       ,p_value             => l_absence_schedule_wp
       ,p_truncated_yes_no  => l_truncated_yes_no
       ,p_error_msg         => p_error_msg
      );

    l_retval :=
      pqp_utilities.pqp_get_extra_element_info(
        p_element_type_id   => p_element_type_id
       ,p_information_type  => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
       ,p_segment_name      => 'Absence Days'
       ,p_value             => l_entitlement_uom
       ,p_truncated_yes_no  => l_truncated_yes_no
       ,p_error_msg         => p_error_msg
      );

        pqp_absval_pkg.get_factors (
            p_business_group_id   => p_business_group_id
           ,p_effective_date      => l_effective_date
           ,p_assignment_id       => p_assignment_id
           ,p_entitlement_uom     => l_entitlement_uom
           ,p_default_wp          => l_default_work_pattern
           ,p_absence_schedule_wp => l_absence_schedule_wp
           ,p_track_part_timers   => NVL(l_track_part_timers,'N')
           ,p_current_factor      => l_current_factor
           ,p_ft_factor           => l_ft_factor
           ,p_working_days_per_week => l_working_days_per_week
           ,p_fte                   => l_fte
           ,p_FT_absence_wp         => l_FT_absence_wp
           ,p_FT_working_wp         => l_FT_working_wp
           ,p_assignment_wp         => l_assignment_wp
           ,p_is_full_timer         => l_is_full_timer
           ,p_is_assignment_wp      => l_is_assignment_wp
           ) ;


-- Change this logic as this will be supported by the above changes

    IF l_scheme_type = 'DUALROLLING' THEN

--    l_retval :=
--      pqp_utilities.pqp_get_extra_element_info(
--        p_element_type_id   => p_element_type_id
--       ,p_information_type  => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
--       ,p_segment_name      => 'Absence Default Work Pattern'
--       ,p_value             => l_default_work_pattern
--       ,p_truncated_yes_no  => l_truncated_yes_no
--       ,p_error_msg         => p_error_msg
--      );
           -- this gets executed when called for CS
           -- get the number of working days per week.
           -- IF the person is a Full timer there may not be any assignment
           -- level work pattern. so pass a default work pattern
           -- the standard work pattern call is required as we have
           -- to compare to know if the person is Full timer or part timer

        l_working_days_in_week :=
               pqp_schedule_calculation_pkg.get_working_days_in_week (
                     p_assignment_id     => p_assignment_id
                    ,p_business_group_id => p_business_group_id
                    ,p_effective_date    => p_effective_date
                    ,p_default_wp        => l_FT_working_wp --l_default_work_pattern
                    ) ;

              -- Default Work Pattern is passed as Over Ride Work Pattern
              -- because we want the days in standard work pattern but not
              -- at assignment level.
              -- if we pass that as p_default_wp the function returns the
              -- number of days at assignment level work pattern if
              -- there is any

        l_standard_work_days_in_week :=
               pqp_schedule_calculation_pkg.get_working_days_in_week (
                     p_assignment_id     => p_assignment_id
                    ,p_business_group_id => p_business_group_id
                    ,p_effective_date    => p_effective_date
                    ,p_override_wp       => l_FT_working_wp --l_default_work_pattern
                    ) ;
        IF NVL(l_working_days_in_week,l_standard_work_days_in_week) >=
                 l_standard_work_days_in_week THEN
                     l_working_days_in_week  := 7 ;
         END IF;

         l_current_factor := l_working_days_in_week ;
         l_ft_factor      := 7 ;
    END IF ;

      i := l_entitlement_parameters.FIRST;

      WHILE i IS NOT NULL
      LOOP
        IF l_entitlement_parameters(i).band = 'BAND1'
        THEN
--          p_band1_entitlement := FLOOR(l_entitlement_parameters(i).entitlement
--                                     * l_working_days_in_week
--                                     /l_entitlements_divisor) ;

--          p_band1_entitlement := FLOOR(l_entitlement_parameters(i).entitlement
--                                     * l_current_factor
--                                     /l_ft_factor) ;

          p_band1_entitlement := l_entitlement_parameters(i).entitlement
                                     * l_current_factor
                                     /l_ft_factor ;
          p_band1_percentage := l_entitlement_parameters(i).percentage;


-- Rounding off entitlements depending on wether a  full timers or part timers
       /*    IF l_is_full_timer THEN
               p_band1_entitlement := pqp_utilities.round_value_up_down
                (p_value_to_round => p_band1_entitlement
                ,p_base_value     => g_ft_rounding_precision
                ,p_rounding_type  => g_ft_entitl_rounding_type
                ) ;
           ELSE
                p_band1_entitlement := pqp_utilities.round_value_up_down
                ( p_value_to_round => p_band1_entitlement
                 ,p_base_value    => g_pt_rounding_precision
                 ,p_rounding_type => g_pt_entitl_rounding_type
                 ) ;
          END IF ;
*/
        ELSIF l_entitlement_parameters(i).band = 'BAND2'
        THEN
--          p_band2_entitlement := FLOOR(l_entitlement_parameters(i).entitlement
--                                     * l_working_days_in_week
--                                     /l_entitlements_divisor) ;
--          p_band2_entitlement := FLOOR(l_entitlement_parameters(i).entitlement
--                                    * l_current_factor
--                                     /l_ft_factor) ;

          p_band2_entitlement := l_entitlement_parameters(i).entitlement
                                     * l_current_factor
                                     /l_ft_factor ;

          p_band2_percentage := l_entitlement_parameters(i).percentage;


-- Rounding off entitlements depending on wether a  full timers or part timers
        /*   IF l_is_full_timer THEN
              p_band2_entitlement := pqp_utilities.round_value_up_down
               ( p_value_to_round => p_band2_entitlement
                ,p_base_value     => g_ft_rounding_precision
                ,p_rounding_type  => g_ft_entitl_rounding_type
                ) ;
           ELSE
                p_band2_entitlement := pqp_utilities.round_value_up_down
                ( p_value_to_round => p_band2_entitlement
                 ,p_base_value    => g_pt_rounding_precision
                 ,p_rounding_type => g_pt_entitl_rounding_type
                 ) ;
          END IF ;
*/


        ELSIF l_entitlement_parameters(i).band = 'BAND3'
        THEN
--          p_band3_entitlement := FLOOR(l_entitlement_parameters(i).entitlement
--                                     * l_working_days_in_week
--                                     /l_entitlements_divisor) ;
--          p_band3_entitlement := FLOOR(l_entitlement_parameters(i).entitlement
--                                     * l_current_factor
--                                     /l_ft_factor) ;

          p_band3_entitlement := l_entitlement_parameters(i).entitlement
                                     * l_current_factor
                                     /l_ft_factor ;

          p_band3_percentage := l_entitlement_parameters(i).percentage;

-- Rounding off entitlements depending on wether a  full timers or part timers
        /*   IF l_is_full_timer THEN
              p_band3_entitlement := pqp_utilities.round_value_up_down
               ( p_value_to_round => p_band3_entitlement
                ,p_base_value     => g_ft_rounding_precision
                ,p_rounding_type  => g_ft_entitl_rounding_type
                ) ;
           ELSE
                p_band3_entitlement := pqp_utilities.round_value_up_down
                ( p_value_to_round => p_band3_entitlement
                 ,p_base_value    => g_pt_rounding_precision
                 ,p_rounding_type => g_pt_entitl_rounding_type
                 ) ;
          END IF ;
*/
        ELSIF l_entitlement_parameters(i).band = 'BAND4'
        THEN
--          p_band4_entitlement := FLOOR(l_entitlement_parameters(i).entitlement
--                                     * l_working_days_in_week
--                                     /l_entitlements_divisor) ;
--          p_band4_entitlement := FLOOR(l_entitlement_parameters(i).entitlement
--                                    * l_current_factor
--                                     /l_ft_factor ) ;

          p_band4_entitlement := l_entitlement_parameters(i).entitlement
                                     * l_current_factor
                                     /l_ft_factor  ;

          p_band4_percentage := l_entitlement_parameters(i).percentage;

-- Rounding off entitlements depending on wether a  full timers or part timers
        /*  IF l_is_full_timer THEN
             p_band4_entitlement := pqp_utilities.round_value_up_down
               ( p_value_to_round => p_band4_entitlement
                ,p_base_value     => g_ft_rounding_precision
                ,p_rounding_type  => g_ft_entitl_rounding_type
                ) ;
           ELSE
                p_band4_entitlement := pqp_utilities.round_value_up_down
                ( p_value_to_round => p_band4_entitlement
                 ,p_base_value     => g_pt_rounding_precision
                 ,p_rounding_type  => g_pt_entitl_rounding_type
                 ) ;
          END IF ;
*/
          EXIT;
        END IF; -- End if of band check ...

        i := l_entitlement_parameters.NEXT(i);
      END LOOP;
    END IF;         -- End if of retval -1 check
            --

    debug_exit(l_proc_name);
    RETURN 0;

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
  END pqp_get_band_ent_value;

  --

-- pqp_get_maternity_id Returns the maternity id value for a given absence id
  FUNCTION pqp_get_maternity_id(
    p_absence_id                IN       NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_maternity_id';
    l_maternity_id                ssp_maternities.maternity_id%TYPE;
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_absence_id:'||p_absence_id);
    END IF;
    OPEN csr_maternity_id(p_absence_id => p_absence_id);
    FETCH csr_maternity_id INTO l_maternity_id;

    --
    IF    csr_maternity_id%NOTFOUND
       OR l_maternity_id IS NULL
    THEN
      p_message :=
                 fnd_message.get_string('PQP', 'PQP_230599_INV_MATERNITY_ID');
    END IF;

    --
    CLOSE csr_maternity_id;
    IF g_debug THEN
      debug('l_maternity_id:'||l_maternity_id);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_maternity_id;

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
  END pqp_get_maternity_id;

-- pqp_get_medical_id Returns the medical id value for a given absence id.
  FUNCTION pqp_get_medical_id(
    p_absence_id                IN       NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_medical_id';
    l_medical_id                  ssp_medicals.medical_id%TYPE;
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_absence_id:'||p_absence_id);
    END IF;
    OPEN csr_medical_id(p_absence_id => p_absence_id);
    FETCH csr_medical_id INTO l_medical_id;

    --
    IF csr_medical_id%NOTFOUND
    THEN
      p_message := fnd_message.get_string('PQP', 'PQP_230600_INV_MEDICAL_ID');
    END IF;

    CLOSE csr_medical_id;
    IF g_debug THEN
      debug('l_medical_id:'||l_medical_id);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_medical_id;

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
  END pqp_get_medical_id;

-- pqp_gb_get_no_holidays Returns the number of holidays declared in UDT
-- as holidays in the absence period which is start date and end date.
  FUNCTION pqp_gb_get_no_of_holidays(
    p_business_group_id         IN       NUMBER
   ,p_abs_start_date            IN       DATE
   ,p_abs_end_date              IN       DATE
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_count                       NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_gb_get_no_holidays';
    l_abs_end_date                DATE; -- Added to handle Open ended absences
    l_column_name                 pay_user_columns.user_column_name%TYPE;
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug(p_abs_start_date);
      debug(p_abs_end_date);
      debug('p_table_id:'||p_table_id);
      debug('p_column_name:'||p_column_name);
      debug('p_value:'||p_value);
    END IF;
    --SELECT DECODE(
    --         p_abs_end_date
    --        ,hr_api.g_eot, p_abs_start_date
    --        ,p_abs_end_date
    --       )
    --INTO   l_abs_end_date
    --FROM   DUAL;

    IF TRUNC(p_abs_end_date) = hr_api.g_eot THEN
      l_abs_end_date := p_abs_start_date;
    ELSE
      l_abs_end_date := p_abs_end_date;
    END IF;

    IF p_column_name IS NULL
    THEN
      -- Get the Column from the Lookup
      l_column_name :=
        hr_general.decode_lookup(
          p_lookup_type =>                'PQP_GB_OMP_CALENDAR_RULES'
         ,p_lookup_code =>                'EXCLUDED'
        );
    ELSE
      l_column_name := p_column_name;
    END IF;

    OPEN csr_get_hol_abs(
          p_business_group_id =>          p_business_group_id
         ,p_abs_start_date =>             p_abs_start_date
         ,p_abs_end_date =>               l_abs_end_date
         ,p_table_id =>                   p_table_id
         ,p_column_name =>                l_column_name
         ,p_value =>                      p_value
                        );
    FETCH csr_get_hol_abs INTO l_count;
    CLOSE csr_get_hol_abs;
    debug_exit(l_proc_name);
    RETURN NVL(l_count, 0);
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
  END pqp_gb_get_no_of_holidays;

-- pqp_gb_get_calendar_days Returns the number of days in a given period
  FUNCTION pqp_gb_get_calendar_days(p_start_date IN DATE, p_end_date IN DATE)
    RETURN NUMBER
  IS
    l_count                       NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_gb_get_calendar_days';

    CURSOR c_no_of_days(c_start_date IN DATE, c_end_date IN DATE)
    IS
      SELECT (c_end_date - c_start_date + 1) cnt
      FROM   DUAL;
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_start_date:'||fnd_date.date_to_canonical(p_start_date));
      debug('p_end_date:'||fnd_date.date_to_canonical(p_end_date));
    END IF;

    OPEN c_no_of_days(c_start_date =>     p_start_date
         ,c_end_date =>                   p_end_date);
    FETCH c_no_of_days INTO l_count;
    CLOSE c_no_of_days;
    IF g_debug THEN
      debug('l_count:'||l_count);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_count;
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
  END pqp_gb_get_calendar_days;

-- pqp_gb_get_cal_abs_hol_days Returns the number of absences in a
-- calendar period which is arrived at after deducting the
-- number of holidays in the period from the number of calendar days.
  FUNCTION pqp_gb_get_cal_abs_hol_days(
    p_business_group_id         IN       NUMBER
   ,p_abs_start_date            IN       DATE
   ,p_abs_end_date              IN       DATE
   ,p_holidays                  OUT NOCOPY NUMBER
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_count                       NUMBER;
    l_cal_days                    NUMBER;
    l_hol_days                    NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_gb_get_cal_abs_hol_days';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_abs_start_date:'||fnd_date.date_to_canonical(p_abs_start_date));
      debug('p_abs_end_date:'||fnd_date.date_to_canonical(p_abs_end_date));
      debug('p_table_id:'||p_table_id);
      debug('p_column_name:'||p_column_name);
      debug('p_value:'||p_value);
    END IF;

    -- Get the Number of Calendar Days.
    debug(l_proc_name, 10);
    l_cal_days :=
      pqp_gb_osp_functions.pqp_gb_get_calendar_days(p_start_date => p_abs_start_date
       ,p_end_date =>                   p_abs_end_date);
    -- Get the Number of Holidays in the absence period.
    debug(l_proc_name, 20);
    l_hol_days :=
      pqp_gb_osp_functions.pqp_gb_get_no_of_holidays(
        p_business_group_id =>          p_business_group_id
       ,p_abs_start_date =>             p_abs_start_date
       ,p_abs_end_date =>               p_abs_end_date
       ,p_table_id =>                   p_table_id
       ,p_column_name =>                p_column_name
       ,p_value =>                      p_value
      );
    -- Deduct Holidays to get the no of absences.
    p_holidays := l_hol_days;
    l_count := l_cal_days - l_hol_days;
    IF g_debug THEN
      debug('l_count:'||l_count);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_count;

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
  END pqp_gb_get_cal_abs_hol_days;

-- pqp_gb_get_cal_abs_days Returns the number of calendar days if no UDT
-- is passed. Returns the no of calendar days minus the holidays in
-- the absence period declared in UDT if UDT is passed.
  FUNCTION pqp_gb_get_cal_abs_days(
    p_business_group_id         IN       NUMBER
   ,p_abs_start_date            IN       DATE
   ,p_abs_end_date              IN       DATE
   ,p_holidays                  OUT NOCOPY NUMBER
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_count                       NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_gb_get_cal_abs_days';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_abs_start_date:'||fnd_date.date_to_canonical(p_abs_start_date));
      debug('p_abs_end_date:'||fnd_date.date_to_canonical(p_abs_end_date));
      debug('p_table_id:'||p_table_id);
      debug('p_column_name:'||p_column_name);
      debug('p_value:'||p_value);
    END IF;

    --
    IF p_table_id IS NULL
    THEN
      -- Get the number of days in the period .
      debug(l_proc_name, 10);
      l_count :=
        pqp_gb_osp_functions.pqp_gb_get_calendar_days(p_start_date => p_abs_start_date
         ,p_end_date =>                   p_abs_end_date);
    ELSE
      -- when UDT is passed Get the Calendar Days minus no of holidays in the
      -- absence period declared in UDT.
      debug(l_proc_name, 20);
      l_count :=
        pqp_gb_osp_functions.pqp_gb_get_cal_abs_hol_days(
          p_business_group_id =>          p_business_group_id
         ,p_abs_start_date =>             p_abs_start_date
         ,p_abs_end_date =>               p_abs_end_date
         ,p_holidays =>                   p_holidays
         ,p_table_id =>                   p_table_id
         ,p_column_name =>                p_column_name
         ,p_value =>                      p_value
        );
    END IF;

    --
    IF g_debug THEN
      debug('l_count:'||l_count);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_count;

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
  END pqp_gb_get_cal_abs_days;

-- pqp_gb_get_no_of_work_holidays Returns the number of Holidays in the list of
-- dates passed as input. Checks for each date is defined in UDT as a
-- holiday and returns the count of holidays.
  FUNCTION pqp_gb_get_no_of_work_holidays(
    p_business_group_id         IN       NUMBER
   ,p_work_dates                IN       pqp_schedule_calculation_pkg.t_working_dates
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_count                       NUMBER := 0;
    l_value                       pay_user_column_instances_f.VALUE%TYPE;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_gb_get_no_of_work_holidays';
    l_column_name                 pay_user_columns.user_column_name%TYPE;
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_table_id:'||p_table_id);
      debug('p_column_name:'||p_column_name);
      debug('p_value:'||p_value);
    END IF;

    IF p_column_name IS NULL
    THEN
      -- Get the Column from the Lookup
      l_column_name :=
        hr_general.decode_lookup(
          p_lookup_type =>                'PQP_GB_OMP_CALENDAR_RULES'
         ,p_lookup_code =>                'EXCLUDED'
        );
    ELSE
      l_column_name := p_column_name;
    END IF;

    FOR i IN 1 .. p_work_dates.COUNT
    LOOP
      OPEN csr_get_work_hol(
            p_business_group_id =>          p_business_group_id
           ,p_abs_date =>                   p_work_dates(i)
           ,p_table_id =>                   p_table_id
           ,p_column_name =>                l_column_name
           ,p_value =>                      p_value
                           );
      FETCH csr_get_work_hol INTO l_value;

      IF csr_get_work_hol%FOUND
      THEN
        l_count := l_count + 1;
      END IF;

      CLOSE csr_get_work_hol;
    END LOOP;

   IF g_debug THEN
      debug('l_count:'||l_count);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_count;
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
  END pqp_gb_get_no_of_work_holidays;

-- pqp_gb_get_work_abs_days_udt Returns the number of absence Days in a
-- given period.get_days_worked first calculates the number of working days
-- in the period for the work pattern and Returns a list of working dates .
-- These working dates are passed to pqp_gb_get_no_of_work_holidays and the
-- number of holidays will be calculated. the difference between total
-- working days and no of holidays gives the number of absences for the period

  FUNCTION pqp_gb_get_work_abs_days_udt(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_start_date                IN       DATE
   ,p_end_date                  IN       DATE
   ,p_default_wp                IN       VARCHAR2
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
   ,p_holidays                  OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_count                       NUMBER := 0;
    l_work_days                   NUMBER;
    l_work_holidays               NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_gb_get_work_abs_days_udt';
    l_working_dates               pqp_schedule_calculation_pkg.t_working_dates;
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_start_date:'||fnd_date.date_to_canonical(p_start_date));
      debug('p_end_date:'||fnd_date.date_to_canonical(p_end_date));
      debug('p_default_wp:'||p_default_wp);
      debug('p_table_id:'||p_table_id);
      debug('p_column_name:'||p_column_name);
      debug('p_value:'||p_value);

                END IF;
    -- Call Work Patterns function to get Collection of Working Dates
    debug(l_proc_name, 10);
    l_work_days :=
      pqp_schedule_calculation_pkg.get_days_worked(
        p_assignment_id =>              p_assignment_id
       ,p_business_group_id =>          p_business_group_id
       ,p_date_start =>                 p_start_date
       ,p_date_end =>                   p_end_date
       ,p_default_wp =>                 p_default_wp
       ,p_working_dates =>              l_working_dates
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
      );
    debug(l_proc_name, 20);
    l_work_holidays :=
      pqp_gb_osp_functions.pqp_gb_get_no_of_work_holidays(
        p_business_group_id =>          p_business_group_id
       ,p_work_dates =>                 l_working_dates
       ,p_table_id =>                   p_table_id
       ,p_column_name =>                p_column_name
       ,p_value =>                      p_value
      );
    -- Number of Holidays in the period are Returned as OUT Parameter.
    p_holidays := l_work_holidays;
    l_count := l_work_days - l_work_holidays;
    IF g_debug THEN
      debug('l_count:'||l_count);
      debug_exit(l_proc_name);
                END IF;
    RETURN l_count;

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
  END pqp_gb_get_work_abs_days_udt;

-- pqp_gb_get_work_abs_days Returns the number of Working Days absences
-- in a given period.
  FUNCTION pqp_gb_get_work_abs_days(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_start_date                IN       DATE
   ,p_end_date                  IN       DATE
   ,p_holidays                  OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_default_wp                IN       VARCHAR2
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_count                       NUMBER := 0;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_gb_get_work_abs_days';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_start_date:'||fnd_date.date_to_canonical(p_start_date));
      debug('p_end_date:'||fnd_date.date_to_canonical(p_end_date));
      debug('p_default_wp:'||p_default_wp);
      debug('p_table_id:'||p_table_id);
      debug('p_column_name:'||p_column_name);
      debug('p_value:'||p_value);
                END IF;
    -- If Table Id is not passed then
    IF p_table_id IS NULL
    THEN
      debug(l_proc_name, 10);
      l_count :=
        pqp_schedule_calculation_pkg.get_days_worked(
          p_assignment_id =>              p_assignment_id
         ,p_business_group_id =>          p_business_group_id
         ,p_date_start =>                 p_start_date
         ,p_date_end =>                   p_end_date
         ,p_default_wp =>                 p_default_wp
         ,p_error_code =>                 p_error_code
         ,p_error_message =>              p_error_message
        );
    ELSE -- If UDT is Passed
      debug(l_proc_name, 20);
      l_count :=
        pqp_gb_osp_functions.pqp_gb_get_work_abs_days_udt(
          p_assignment_id =>              p_assignment_id
         ,p_business_group_id =>          p_business_group_id
         ,p_start_date =>                 p_start_date
         ,p_end_date =>                   p_end_date
         ,p_default_wp =>                 p_default_wp
         ,p_table_id =>                   p_table_id
         ,p_column_name =>                p_column_name
         ,p_value =>                      p_value
         ,p_holidays =>                   p_holidays
         ,p_error_code =>                 p_error_code
         ,p_error_message =>              p_error_message
        );
    END IF;

    IF g_debug THEN
      debug('l_count:'||l_count);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_count;

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
  END pqp_gb_get_work_abs_days;
--
-- pqp_get_omp_band_ent_value Returns the Entitlement Percentage and Recurring
-- or Average Earnings Indicator for Band 1 - Band4. If Intends to Return to
-- Work Flag is 'Y' then Band1Y is called otherwise Band1N for Band1
-- Entitlement. A Fatal error is raised and -1 is returned if Band1 is not
-- defined. For Other Bands if entitlement is defined without percentage or
-- Earnings Type then a Fatal error is raised and -1 is Returned. If Other
-- Band Entitlements are not defined then the value of entitlement is returned
-- as -1 and Function Returns 0.
--
  FUNCTION pqp_get_omp_band_ent_value
    (p_business_group_id           IN            NUMBER
    ,p_effective_date              IN            DATE
    ,p_assignment_id               IN            NUMBER -- Context #3
    ,p_element_type_id             IN            NUMBER -- Context #4
    ,p_entitlement_tab_id          IN            NUMBER
    ,p_benefits_length_of_service  IN            NUMBER
    ,p_return_to_work              IN            VARCHAR2
    ,p_band1_entitlement              OUT NOCOPY NUMBER
    ,p_band1_percentage               OUT NOCOPY NUMBER
    ,p_band1_avg_rec_ind              OUT NOCOPY VARCHAR2
    ,p_band2_entitlement              OUT NOCOPY NUMBER
    ,p_band2_percentage               OUT NOCOPY NUMBER
    ,p_band2_avg_rec_ind              OUT NOCOPY VARCHAR2
    ,p_band3_entitlement              OUT NOCOPY NUMBER
    ,p_band3_percentage               OUT NOCOPY NUMBER
    ,p_band3_avg_rec_ind              OUT NOCOPY VARCHAR2
    ,p_band4_entitlement              OUT NOCOPY NUMBER
    ,p_band4_percentage               OUT NOCOPY NUMBER
    ,p_band4_avg_rec_ind              OUT NOCOPY VARCHAR2
    ,p_error_msg                      OUT NOCOPY VARCHAR2
    ,p_entitlement_bands_list_name IN            VARCHAR2 DEFAULT
       'PQP_GAP_ENTITLEMENT_BANDS'
    ,p_override_effective_date     IN            DATE DEFAULT NULL
    ) RETURN NUMBER
  IS
    l_user_column_id              pay_user_columns.user_column_id%TYPE;
    l_retval                      NUMBER;
    l_row_val                     NUMBER := -1;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_omp_band_ent_value';
    i                             BINARY_INTEGER;
    l_band_ent                    t_entitlement_parameters;
    l_entitlement_parameters      t_entitlement_parameters;
    l_truncated_yes_no            VARCHAR2(30);
    l_pl_id_txt                   pay_element_type_extra_info.eei_information1%TYPE;
    l_pl_id                       ben_pl_f.pl_id%TYPE;
    l_effective_date              DATE;

  BEGIN
    --
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_element_type_id:'||p_element_type_id);
      debug('p_entitlement_tab_id:'||p_entitlement_tab_id);
      debug('p_benefits_length_of_service:'||p_benefits_length_of_service);
      debug('p_return_to_work:'||p_return_to_work);
                END IF;
    p_band1_entitlement := -1;
    p_band1_percentage := 0;
    p_band1_avg_rec_ind := ' ';
    p_band2_entitlement := -1;
    p_band2_percentage := 0;
    p_band2_avg_rec_ind := ' ';
    p_band3_entitlement := -1;
    p_band3_percentage := 0;
    p_band3_avg_rec_ind := ' ';
    p_band4_entitlement := -1;
    p_band4_percentage := 0;
    p_band4_avg_rec_ind := ' ';
    -- Get the entitlement information for all bands

    l_effective_date := NVL(p_override_effective_date, p_effective_date);

    l_retval :=
      pqp_utilities.pqp_get_extra_element_info(
        p_element_type_id   => p_element_type_id
       ,p_information_type  => 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
       ,p_segment_name      => 'Plan Name'
       ,p_value             => l_pl_id_txt
       ,p_truncated_yes_no  => l_truncated_yes_no
       ,p_error_msg         => p_error_msg
      );

    IF l_retval < 0 THEN
      check_error_code(l_retval,p_error_msg);
    END IF;

    l_pl_id := fnd_number.canonical_to_number(l_pl_id_txt);

    l_retval :=
      get_entitlement_parameters(
        p_business_group_id =>            p_business_group_id
       ,p_effective_date =>               l_effective_date
       ,p_assignment_id =>                p_assignment_id
       ,p_pl_id =>                        l_pl_id
       ,p_absence_pay_plan_class =>       'OMP'
       ,p_entitlement_table_id =>         p_entitlement_tab_id
       ,p_benefits_length_of_service =>   p_benefits_length_of_service
       ,p_entitlement_bands_list_name =>  p_entitlement_bands_list_name
       ,p_entitlement_parameters =>       l_entitlement_parameters
       ,p_error_msg =>                    p_error_msg
       ,p_omp_intend_to_return_to_work => p_return_to_work
      );

    IF l_retval = -1
    THEN
      debug(p_error_msg);
      debug_exit(l_proc_name);
      RETURN -1;
    ELSE
      i := l_entitlement_parameters.FIRST;

      WHILE i IS NOT NULL
      LOOP
        IF l_entitlement_parameters(i).band = 'BAND1'
        THEN
          p_band1_entitlement := l_entitlement_parameters(i).entitlement;
          p_band1_percentage := l_entitlement_parameters(i).percentage;
          p_band1_avg_rec_ind := l_entitlement_parameters(i).earnings_type;
        ELSIF l_entitlement_parameters(i).band = 'BAND2'
        THEN
          p_band2_entitlement := l_entitlement_parameters(i).entitlement;
          p_band2_percentage := l_entitlement_parameters(i).percentage;
          p_band2_avg_rec_ind := l_entitlement_parameters(i).earnings_type;
        ELSIF l_entitlement_parameters(i).band = 'BAND3'
        THEN
          p_band3_entitlement := l_entitlement_parameters(i).entitlement;
          p_band3_percentage := l_entitlement_parameters(i).percentage;
          p_band3_avg_rec_ind := l_entitlement_parameters(i).earnings_type;
        ELSIF l_entitlement_parameters(i).band = 'BAND4'
        THEN
          p_band4_entitlement := l_entitlement_parameters(i).entitlement;
          p_band4_percentage := l_entitlement_parameters(i).percentage;
          p_band4_avg_rec_ind := l_entitlement_parameters(i).earnings_type;
          EXIT;
        END IF; -- End if of band check ...

        i := l_entitlement_parameters.NEXT(i);
      END LOOP;
    END IF;         -- End if of retval -1 check
            --

    debug_exit(l_proc_name);
    RETURN 0;

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
  END pqp_get_omp_band_ent_value;
--
--
--
--  PROCEDURE get_day_dets(
--    p_wp_dets                   IN       pqp_schedule_calculation_pkg.c_wp_dets%ROWTYPE
--   ,p_calc_stdt                 IN       DATE
--   ,p_calc_edt                  IN       DATE
--   ,p_day_no                    OUT NOCOPY NUMBER
--   ,p_days_in_wp                OUT NOCOPY NUMBER
--  )
--  IS
--    -- Local Declarations
--
----  cursor c_get_days is
----  select count(pur.row_low_range_or_name)
----  from pay_user_rows_f pur
----  where pur.user_row_id in(
----        select distinct uci.user_row_id
----        from pay_user_tables put,
----             pay_user_columns puc,
----             pay_user_column_instances_f uci
----        where put.user_table_id = puc.user_table_id
----        and uci.user_column_id = puc.user_column_id
----        and put.user_table_name = g_udt_name
----        and puc.user_column_name = p_wp_dets.work_pattern
----        and puc.business_group_id = p_wp_dets.business_group_id
----        and (p_calc_stdt between uci.effective_start_date
----                                           and uci.effective_end_date
----        or  p_calc_edt between uci.effective_start_date
----                                         and uci.effective_end_date));
---- changes by rrazdan
---- the above and below queries are non-performant
---- however it is not possible in this to safely change these
---- with te required performance changes without impacting
---- testing hence only minimal changes are being done
---- in order to make this cursor deal with seeded work patterns
----
--    CURSOR c_get_days
--    IS
--      SELECT COUNT(pur.row_low_range_or_name)
--      FROM   pay_user_rows_f pur
--      WHERE  pur.user_row_id IN(
--               SELECT DISTINCT uci.user_row_id
--               FROM            pay_user_tables put
--                              ,pay_user_columns puc
--                              ,pay_user_column_instances_f uci
--                              ,per_business_groups_perf pbg
--               WHERE           put.user_table_name = g_udt_name
--               AND             pbg.business_group_id =
--                                                   p_wp_dets.business_group_id
--               AND             put.legislation_code = pbg.legislation_code
--               AND             puc.user_table_id = put.user_table_id
--               AND             puc.user_column_name = p_wp_dets.work_pattern
--               AND             (
--                                   puc.business_group_id =
--                                                   p_wp_dets.business_group_id
--                                OR (
--                                        puc.business_group_id IS NULL
--                                    AND puc.legislation_code =
--                                                          pbg.legislation_code
--                                   )
--                               --OR global
--                                 -- CANNOT BE as the table itself is legislatively seeded.
--                               )
--               AND             uci.user_column_id = puc.user_column_id
--               AND             (
--                                   uci.business_group_id =
--                                                   p_wp_dets.business_group_id
--                                OR (
--                                        uci.business_group_id IS NULL
--                                    AND uci.legislation_code =
--                                                          pbg.legislation_code
--                                   )
--                               --OR global
--                                 -- CANNOT BE as the work pattern itself is either
--                                 -- legislative or business group specific
--                               )
--               AND             (
--                                   p_calc_stdt BETWEEN uci.effective_start_date
--                                                   AND uci.effective_end_date
--                                OR p_calc_edt BETWEEN uci.effective_start_date
--                                                  AND uci.effective_end_date
--                               ));
--
--    l_days_in_wp                  NUMBER;
--    l_day_no                      NUMBER;
--    l_diff_days                   NUMBER;
--    l_diff_calcstdt_dtonday1      NUMBER;
--    l_diff_temp                   NUMBER;
--    l_dt_on_day1                  DATE;
--    l_proc_step                   NUMBER(38,10):=0;
--    l_proc_name                   VARCHAR2(61):=
--      g_package_name||'get_day_dets';
--  BEGIN
--    debug_enter(l_proc_name);
---- Get the number of days in the Work Pattern
--    OPEN c_get_days;
--    FETCH c_get_days INTO l_days_in_wp;
--    CLOSE c_get_days;
--    -- Find number of days to be added to effective date
--    --   to get next date on 'Day 01'
--    l_diff_days :=
--                l_days_in_wp - TO_NUMBER(SUBSTR(p_wp_dets.start_day, 5, 2))
--                + 1;
--    -- Find the next date that would be 'Day 01' w.r.t. the p_wp_dets record
--    l_dt_on_day1 := p_wp_dets.effective_start_date + l_diff_days;
--    -- Find difference between calculation start_date and date on 'Day 01'
--    l_diff_temp := p_calc_stdt - l_dt_on_day1;
--    -- If difference is negative, multiply by -1 to make it positive
--    l_diff_calcstdt_dtonday1 := l_diff_temp * SIGN(l_diff_temp);
--
--    -- Calculate Day Number on Calculation Start Date
--    IF l_diff_temp < 0
--    THEN
--      l_day_no := l_days_in_wp - l_diff_calcstdt_dtonday1 + 1;
--    ELSE
--      l_day_no := MOD(l_diff_calcstdt_dtonday1, l_days_in_wp) + 1;
--    END IF;
--
--    -- Assign values to be returned
--    p_day_no := l_day_no;
--    p_days_in_wp := l_days_in_wp;
--    debug_exit(l_proc_name);
--
--  EXCEPTION
--    WHEN OTHERS THEN
--      clear_cache;
--      IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
--        debug_others(l_proc_name,l_proc_step);
--        IF g_debug THEN
--          debug('Leaving: '||l_proc_name,-999);
--        END IF;
--        fnd_message.raise_error;
--      ELSE
--        RAISE;
--      END IF;
--  END get_day_dets;

  PROCEDURE get_next_working_date_wp(
    p_business_group_id         IN       NUMBER
   ,p_wp_dets                   IN       pqp_schedule_calculation_pkg.c_wp_dets%ROWTYPE
   ,p_curr_date                 IN OUT NOCOPY DATE
   ,p_balance_days              IN OUT NOCOPY NUMBER
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
  IS
    l_calc_stdt                   DATE;
    l_calc_endt                   DATE;
    l_day_no                      NUMBER;
    l_days_in_wp                  NUMBER;
    l_curr_day_no                 NUMBER;
    l_day                         VARCHAR2(30);
    l_hours                       NUMBER := 0;
    l_holidays                    NUMBER := 0;
    l_continue                    VARCHAR2(1) := 'Y';
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_next_working_date_wp';
    l_retval                      NUMBER;
    l_error_msg        fnd_new_messages.message_text%TYPE;
-- nocopy changes
    l_curr_date_nc                DATE;
    l_balance_days_nc             NUMBER;
  BEGIN -- get_next_working_date_wp
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_curr_date:'||fnd_date.date_to_canonical(p_curr_date));
      debug('p_balance_days:'||p_balance_days);
      debug('p_table_id:'||p_table_id);
      debug('p_column_name:'||p_column_name);
      debug('p_value:'||p_value);
                END IF;
    -- nocopy changes
    l_curr_date_nc := p_curr_date;
    l_balance_days_nc := p_balance_days;

    -- Determine Calculation Start Date for this Work Pattern
    IF p_curr_date > p_wp_dets.effective_start_date
    THEN
      l_calc_stdt := p_curr_date;
    ELSE
      l_calc_stdt := p_wp_dets.effective_start_date;
    END IF;

    -- Set Calculation End Date for this Work Pattern
    l_calc_endt := p_wp_dets.effective_end_date;
    --Get day number on calculation start date and number of days in Work Pattern
    pqp_schedule_calculation_pkg.get_day_dets
     (p_wp_dets    => p_wp_dets
     ,p_calc_stdt  => l_calc_stdt
     ,p_calc_edt   => l_calc_endt
     ,p_day_no     => l_day_no     -- OUT
     ,p_days_in_wp => l_days_in_wp --OUT
      );

    l_curr_day_no := l_day_no;
    debug('l_curr_day_no :' || to_char(l_curr_day_no));
    debug('p_curr_date :' || to_char(p_curr_date));
    debug('Work Pattern :' || p_wp_dets.work_pattern);

    -- Loop throug the dates starting from p_curr_date
    -- PS : we don't know till when to loop, so p_balance_days
    --          will be used as a balance counter
    LOOP -- Through dates starting with p_curr_date
      l_day := 'Day ' || LPAD(l_curr_day_no, 2, 0);
      debug('p_curr_date:'||fnd_date.date_to_canonical(p_curr_date));

      BEGIN
        l_retval :=
          pqp_utilities.pqp_gb_get_table_value(
            p_business_group_id =>          p_wp_dets.business_group_id
           ,p_effective_date =>             p_curr_date
           ,p_table_name =>                 g_udt_name
           ,p_column_name =>                p_wp_dets.work_pattern
           ,p_row_name =>                   l_day
           ,p_value =>                      l_hours
           ,p_error_msg =>                  l_error_msg
          );

        IF l_retval = -1
        THEN
          /*
           * If any Error then Do not add to total
           * or count the day in the loop.
           */
          debug('l_error_msg:'||l_error_msg);
          l_hours := 0;
        END IF;
      END;

      debug('Hours on ' || l_day || ' = ' || l_hours, 70);

      -- Decrement working days balance if l_curr_day_no
      -- is a working day
      IF l_hours > 0
      THEN
        -- Check for Holidays only if the Calendar UDT Id has been passed
        IF p_table_id IS NOT NULL
        THEN
          -- Check for Holidays
          l_holidays :=
            pqp_gb_get_no_of_holidays(
              p_business_group_id =>          p_business_group_id
             ,p_abs_start_date =>             p_curr_date
             ,p_abs_end_date =>               p_curr_date
             ,p_table_id =>                   p_table_id
             ,p_column_name =>                p_column_name
             ,p_value =>                      p_value
            );

          IF l_holidays = 0
          THEN
            p_balance_days := p_balance_days - 1;
          ELSE
            debug(l_proc_name, 80);
            debug('HOLIDAY');
          END IF;
        --
        ELSE -- DO NOT Check for Holidays
          p_balance_days := p_balance_days - 1;
        END IF;         -- p_table_id IS NOT NULL then
                --
      END IF; -- l_hours > 0 then

              -- If we have counted down all the working days then exit

      IF p_balance_days = 0
      THEN
        l_continue := 'N';
        EXIT;
      END IF;

      -- Calculate next day no
      IF l_curr_day_no = l_days_in_wp
      THEN
        l_curr_day_no := 1;
      ELSE
        l_curr_day_no := l_curr_day_no + 1;
      END IF;

      -- Increment to the next date
      p_curr_date := p_curr_date + 1;

      -- The WP has changed, exit, but continue process using the next
      -- effective work pattern row
      IF p_curr_date > p_wp_dets.effective_end_date
      THEN
        l_continue := 'Y';
        EXIT;
      END IF;
    END LOOP; -- Through dates starting with p_curr_date

    debug_exit(l_proc_name);
    RETURN;

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
  END get_next_working_date_wp;

  FUNCTION get_next_working_date(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_date_start                IN       DATE
   ,p_days                      IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_default_wp                IN       VARCHAR2
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
    RETURN DATE
  IS
    l_balance_days                NUMBER;
    l_curr_date                   DATE;
    l_calc_stdt                   DATE;
    l_calc_endt                   DATE;
    l_day_no                      NUMBER;
    l_days_in_wp                  NUMBER;
    l_curr_day_no                 NUMBER;
    l_day                         VARCHAR2(30);
    l_hours                       NUMBER := 0;
    l_continue                    VARCHAR2(1) := 'Y';
    l_asg_wp_found                BOOLEAN := FALSE;
    l_error_code                  NUMBER := 0;
    l_err_msg_name                fnd_new_messages.message_name%TYPE;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_next_working_date';
    r_wp_dets                     pqp_schedule_calculation_pkg.c_wp_dets%ROWTYPE;
    r_def_wp_dets                 pqp_schedule_calculation_pkg.c_wp_dets%ROWTYPE;
  BEGIN                                               /*get_next_working_date*/
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_date_start:'||fnd_date.date_to_canonical(p_date_start));
      debug('p_days:'||p_days);
      debug('p_default_wp:'||p_default_wp);
      debug('p_table_id:'||p_table_id);
      debug('p_column_name:'||p_column_name);
      debug('p_value:'||p_value);
      debug('g_udt_name:'||g_udt_name);
    END IF;

    -- Add 1 to working days and assign to balance days
    -- We need to this as we want to return the date
    -- prior to the NEXT working day after p_days working days
    -- have been added to start date
    l_balance_days := FLOOR(p_days) + 1;
    l_curr_date := p_date_start;

    FOR r_wp_dets IN pqp_schedule_calculation_pkg.c_wp_dets_up(p_assignment_id, p_date_start)
    LOOP                                        /* Get Work Pattern Details */
      -- Only if this aat record contains a work pattern
      IF r_wp_dets.work_pattern IS NOT NULL
      THEN
        debug(l_proc_name, 30);
        l_asg_wp_found := TRUE;

        IF l_curr_date BETWEEN r_wp_dets.effective_start_date
                           AND r_wp_dets.effective_end_date
        THEN
          get_next_working_date_wp(
            p_business_group_id =>          p_business_group_id
           ,p_wp_dets =>                    r_wp_dets
           ,p_curr_date =>                  l_curr_date -- IN OUT
           ,p_balance_days =>               l_balance_days -- IN OUT
           ,p_table_id =>                   p_table_id
           ,p_column_name =>                p_column_name
           ,p_value =>                      p_value
          );
        --
        ELSIF p_default_wp IS NOT NULL
        THEN
          -- Use the default work pattern for the period where there is no
          -- work pattern on assignment and then use the asg work pattern

          debug(l_proc_name, 40);
          -- Step 1) Add days for the default work pattern
          r_def_wp_dets := NULL;
          r_def_wp_dets.effective_start_date := l_curr_date;
          -- set effective end date as the day before the Asg WP becomes effective
          r_def_wp_dets.effective_end_date :=
                                         (
                                          r_wp_dets.effective_start_date - 1
                                         );
          r_def_wp_dets.business_group_id := p_business_group_id;
          r_def_wp_dets.work_pattern := p_default_wp;
          r_def_wp_dets.start_day :=
                'Day '
             || LPAD(
                  TO_CHAR(
                      8
                    - (
                       NEXT_DAY(l_curr_date, g_default_start_day)
                       - l_curr_date
                      )
                  )
                 ,2
                 ,'0'
                );
          debug('Start Day :' || r_def_wp_dets.start_day);
          get_next_working_date_wp(
            p_business_group_id =>          p_business_group_id
           ,p_wp_dets =>                    r_def_wp_dets
           ,p_curr_date =>                  l_curr_date -- IN OUT
           ,p_balance_days =>               l_balance_days -- IN OUT
           ,p_table_id =>                   p_table_id
           ,p_column_name =>                p_column_name
           ,p_value =>                      p_value
          );

          -- Step 2) Add days for the assignment work pattern
          -- But, only if there are more days to be added
          IF l_balance_days > 0
          THEN
            get_next_working_date_wp(
              p_business_group_id =>          p_business_group_id
             ,p_wp_dets =>                    r_wp_dets
             ,p_curr_date =>                  l_curr_date -- IN OUT
             ,p_balance_days =>               l_balance_days -- IN OUT
             ,p_table_id =>                   p_table_id
             ,p_column_name =>                p_column_name
             ,p_value =>                      p_value
            );
          END IF;
        --
        ELSE -- No default work pattern found, raise error and exit the loop.
          l_error_code := -1;
          l_err_msg_name := 'PQP_230589_NO_WORK_PATTERN';
          EXIT;
        END IF;         -- l_calc_stdt between r_wp_dets.effective_start_date
                --
      END IF;         -- if r_wp_dets.work_pattern is not null then
              -- Exit the loop if there are no more days to add

      IF l_balance_days = 0
      THEN
        EXIT;
      END IF;
    --
    END LOOP;                                    /* Get Work Pattern Details */

    IF     l_error_code = 0 --  No errors have occured
       AND ( -- No WP found on AAT
                NOT l_asg_wp_found
             OR -- not enough WP history on AAT so more days still to be added
                l_balance_days > 0
           )
    THEN
      IF p_default_wp IS NOT NULL
      THEN
        debug(l_proc_name, 60);
        debug('Asg WP NOT Found, default WP available');
        r_def_wp_dets := NULL;
        r_def_wp_dets.effective_start_date := l_curr_date;
        r_def_wp_dets.effective_end_date := hr_api.g_eot; -- End of Time
        r_def_wp_dets.business_group_id := p_business_group_id;
        r_def_wp_dets.work_pattern := p_default_wp;
        r_def_wp_dets.start_day :=
              'Day '
           || LPAD(
                TO_CHAR(8
                  -(NEXT_DAY(l_curr_date, g_default_start_day) - l_curr_date))
               ,2
               ,'0'
              );
        debug('Start Day :' || r_def_wp_dets.start_day, 70);
        get_next_working_date_wp(
          p_business_group_id =>          p_business_group_id
         ,p_wp_dets =>                    r_def_wp_dets
         ,p_curr_date =>                  l_curr_date -- IN OUT
         ,p_balance_days =>               l_balance_days -- IN OUT
         ,p_table_id =>                   p_table_id
         ,p_column_name =>                p_column_name
         ,p_value =>                      p_value
        );
      ELSE
        l_error_code := -1;
        l_err_msg_name := 'PQP_230589_NO_WORK_PATTERN';
      END IF;
    --
    END IF; -- if NOT l_asg_wp_found the

            -- If no errors hv occured and
            -- balance has not been zeroed yet, then raise an error.

    IF l_error_code = 0 AND l_balance_days > 0
    THEN
      l_error_code := -2;
      l_err_msg_name := 'PQP_230590_WP_HIST_INCOMPLETE';
    END IF; -- l_error_code = 0 then

    p_error_code := l_error_code;

    --
    IF l_err_msg_name IS NOT NULL
    THEN
      p_error_message := fnd_message.get_string('PQP', l_err_msg_name);
    END IF;
    IF g_debug THEN
      debug('l_curr_date'|| to_char(l_curr_date));
      debug_exit(l_proc_name);
                END IF;
    RETURN l_curr_date;

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
  END get_next_working_date;

-- pqp_get_omp_pl_extra_info Returns the value of the segment
-- in Plan EIT. The Information Type is PQP_GB_OMP_ABSENCE_PLAN_INFO
  FUNCTION pqp_get_omp_pl_extra_info(
    p_pl_id                     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_retval                      NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_omp_pl_extra_info';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_pl_id:'||p_pl_id);
      debug('p_segment_name:'||p_segment_name);
    END IF;

    l_retval :=
      pqp_gb_osp_functions.pqp_get_plan_extra_info(
        p_pl_id =>                      p_pl_id
       ,p_information_type =>           'PQP_GB_OMP_ABSENCE_PLAN_INFO'
       ,p_segment_name =>               p_segment_name
       ,p_value =>                      p_value
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_msg =>                  p_error_msg
      );
    IF g_debug THEN
      debug('l_retval'|| to_char(l_retval));
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;

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

  END pqp_get_omp_pl_extra_info;

-- pqp_get_omp_pl_extra_info Returns the value of the segment
-- in Plan EIT. Plan Name is the Input.The Information Type is
-- PQP_GB_OMP_ABSENCE_PLAN_INFO
  FUNCTION pqp_get_omp_oth_pl_extra_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_name                   IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_retval                      NUMBER;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'pqp_get_omp_oth_pl_extra_info';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date:'||p_effective_date);
      debug('p_pl_name:'||p_pl_name);
      debug('p_segment_name:'||p_segment_name);
    END IF;
    l_retval :=
      pqp_gb_osp_functions.pqp_get_other_plan_extra_info(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_pl_name =>                    p_pl_name
       ,p_information_type =>           'PQP_GB_OMP_ABSENCE_PLAN_INFO'
       ,p_segment_name =>               p_segment_name
       ,p_value =>                      p_value
       ,p_truncated_yes_no =>           p_truncated_yes_no
       ,p_error_msg =>                  p_error_msg
      );
    IF g_debug THEN
      debug('l_retval:'||l_retval);
      debug_exit(l_proc_name);
                END IF;
    RETURN l_retval;

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
  END pqp_get_omp_oth_pl_extra_info;
--
--
--
-- ben_matrnty_details Returns the value of the column in table
-- ssp_maternities. Input is title of the column in the absence form.
-- The mapping of form title to the DB column is done in Lookup and the
-- same is fetched by calling get_lookup_code function.
-- assignment_id and effective Date are contexts.
--
--
--
  FUNCTION ben_matrnty_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_matrnty_details';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_title:'||p_title);
    END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.get_matrnty_details(
        p_absence_attendance_id =>      l_absence_id
       ,p_title =>                      p_title
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
      debug(l_proc_name, 30);
    ELSE
      p_error_code := 0;
      debug(l_proc_name, 40);
    END IF;

    IF g_debug THEN
      debug('l_val' || l_val);
      debug_exit(l_proc_name);
                END IF;
    RETURN l_val;


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
  END ben_matrnty_details;

-- ben_medical_details Returns the value of the column in table
-- ssp_medicals. Inputs are absence_attendance_id and the title
-- of the column in the absence form.The mapping of form title to the DB
-- column is done in Lookup and the same is fetched by calling
-- get_lookup_code function.
  FUNCTION ben_medical_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'ben_medical_details';
    l_absence_id                  per_absence_attendances.absence_attendance_id%TYPE;
    l_val                         VARCHAR2(2000);
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_title:'||p_title);

                END IF;
    l_absence_id :=
      pqp_gb_osp_functions.ben_get_absence_id(
        p_assignment_id =>              p_assignment_id
       ,p_effective_date =>             p_effective_date
      );
    debug(l_proc_name, 20);
    l_val :=
      pqp_gb_osp_functions.get_medical_details(
        p_absence_attendance_id =>      l_absence_id
       ,p_title =>                      p_title
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_message
      );

    IF p_message IS NOT NULL
    THEN
      p_error_code := -1;
      debug(l_proc_name, 30);
    ELSE
      p_error_code := 0;
      debug(l_proc_name, 40);
    END IF;

    IF g_debug THEN
      debug('l_val:'||l_val);
      debug_exit(l_proc_name);
                END IF;
    RETURN l_val;

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
END ben_medical_details;

-- Function get_abs_plan_ent_days_info Returns the number of days
-- the type of Entitlement is eligible. for example to find out in a absence
-- period, for a attached Plan how many days are BAND1 Entitled days. This
-- function returns that number.BAND1 is a input parameter.
  FUNCTION get_abs_plan_ent_days_info(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_level_of_entitlement      IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_abs_plan_ent_days_info';
    l_no_of_days                  NUMBER;
    l_csr_entitled_days_rec csr_entitled_days%ROWTYPE ;-----Added For Hours

  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_pl_id:'||p_pl_id);
      debug('p_search_start_date:'||fnd_date.date_to_canonical(p_search_start_date));
      debug('p_search_end_date:'||fnd_date.date_to_canonical(p_search_end_date));
      debug('p_level_of_entitlement' || p_level_of_entitlement);
    END IF;
    p_error_code := 0;
      debug('p_level_of_entitlement:'||p_level_of_entitlement);
      debug('p_search_start_date:'||p_search_start_date);
      debug('p_search_end_date:'||p_search_end_date);

    -- Check the Start Date is earlier than or equal to End Date.
    IF NVL(p_search_start_date, SYSDATE) >
                                         NVL(p_search_end_date, hr_api.g_eot)
    THEN
      p_error_code := -1;
      fnd_message.set_name('PQP', 'PQP_230617_END_GE_START');
      --fnd_message.set_token('START'
      -- ,fnd_date.date_to_canonical(p_search_start_date));
      --fnd_message.set_token('END'
      -- ,fnd_date.date_to_canonical(p_search_end_date));
      p_error_message := fnd_message.get();
      RETURN NULL;
    END IF;

    -- Open the Cursor to get total number of Entitled days for the qualifier.
    OPEN csr_entitled_days(
          p_absence_attendance_id =>      p_absence_attendance_id
         ,p_pl_id =>                      p_pl_id
         ,p_search_start_date =>          p_search_start_date
         ,p_search_end_date =>            p_search_end_date
         ,p_level_of_entitlement =>       p_level_of_entitlement
                          );
    FETCH csr_entitled_days INTO l_csr_entitled_days_rec ;
               -----Added For Hours  --l_no_of_days;
    CLOSE csr_entitled_days;

    l_no_of_days := l_csr_entitled_days_rec.days ;
      -----Added when the cursor is shared between days and hours

    debug('l_no_of_days:'||l_no_of_days);

    IF g_debug THEN
      debug('l_no_of_days:'||l_no_of_days);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_no_of_days;

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
 END get_abs_plan_ent_days_info;

-- Function get_abs_plan_paid_days_info Returns the number of days
-- the type of Paid days is eligible. for example to find out in a absence
-- period, for a attached Plan how many days are BAND1 Paid days. This
-- function returns that number.BAND1 is a input parameter.
  FUNCTION get_abs_plan_paid_days_info(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_level_of_pay              IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_abs_plan_paid_days_info';
    l_no_of_days                  NUMBER;
    l_csr_paid_days_rec csr_paid_days%ROWTYPE ; -----Added For Hours
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_pl_id:'||p_pl_id);
      debug('p_search_start_date:'||fnd_date.date_to_canonical(p_search_start_date));
      debug('p_search_end_date:'||fnd_date.date_to_canonical(p_search_end_date));
      debug('p_level_of_pay'|| p_level_of_pay);
    END IF;
    p_error_code := 0;

    -- Check the Start Date is earlier than or equal to End Date.
    IF NVL(p_search_start_date, SYSDATE) >
                                         NVL(p_search_end_date, hr_api.g_eot)
    THEN
      p_error_code := -1;
      fnd_message.set_name('PQP', 'PQP_230617_END_GE_START');
      --fnd_message.set_token('START'
      -- ,fnd_date.date_to_canonical(p_search_start_date));
      --fnd_message.set_token('END'
      -- ,fnd_date.date_to_canonical(p_search_end_date));
      p_error_message := fnd_message.get();
      RETURN NULL;
    END IF;

    -- Open the Cursor to get total number of Paid days for the qualifier type.
    OPEN csr_paid_days(
          p_absence_attendance_id =>      p_absence_attendance_id
         ,p_pl_id =>                      p_pl_id
         ,p_search_start_date =>          p_search_start_date
         ,p_search_end_date =>            p_search_end_date
         ,p_level_of_pay =>               p_level_of_pay
                      );
    FETCH csr_paid_days INTO l_csr_paid_days_rec ;
    CLOSE csr_paid_days;

    l_no_of_days := l_csr_paid_days_rec.days ; -----Added For Hours

    IF g_debug THEN
      debug('l_no_of_days:'||l_no_of_days);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_no_of_days;

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
END get_abs_plan_paid_days_info;

-- Function get_abs_plan_wp_info Returns the number of days
-- the type of Work Pattern is eligible. for example to find out in a absence
-- period, for a attached Plan how many days WORKON Pattern is eligible. This
-- function returns that number.WORKON is a input parameter.
  FUNCTION get_abs_plan_wp_info(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_work_pattern_day_type     IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_abs_plan_wp_info';
    l_no_of_days                  NUMBER;
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_pl_id:'||p_pl_id);
      debug('p_search_start_date:'||fnd_date.date_to_canonical(p_search_start_date));
      debug('p_search_end_date:'||fnd_date.date_to_canonical(p_search_end_date));
      debug('p_work_pattern_day_type'||p_work_pattern_day_type);
    END IF;
    p_error_code := 0;

    -- Check the Start Date is earlier than or equal to End Date.
    IF NVL(p_search_start_date, SYSDATE) >
                                         NVL(p_search_end_date, hr_api.g_eot)
    THEN
      p_error_code := -1;
      fnd_message.set_name('PQP', 'PQP_230617_END_GE_START');
      --fnd_message.set_token('START'
      -- ,fnd_date.date_to_canonical(p_search_start_date));
      --fnd_message.set_token('END'
      -- ,fnd_date.date_to_canonical(p_search_end_date));
      p_error_message := fnd_message.get();
      RETURN NULL;
    END IF;

    -- Open the Cursor to get total number of Paid days for the qualifier type.
    OPEN csr_wp_days(
          p_absence_attendance_id =>      p_absence_attendance_id
         ,p_pl_id =>                      p_pl_id
         ,p_search_start_date =>          p_search_start_date
         ,p_search_end_date =>            p_search_end_date
         ,p_work_pattern_day_type =>      p_work_pattern_day_type
                    );
    FETCH csr_wp_days INTO l_no_of_days;
    CLOSE csr_wp_days;
    IF g_debug THEN
      debug('l_no_of_days:'||l_no_of_days);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_no_of_days;

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
  END get_abs_plan_wp_info;

-- The Function Returns the Entitlement Days and Paid Days for the Bands
-- from BAND1 to BAND4 and NOBAND.
  FUNCTION get_osp_band_paid_entitlements(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_band1_entitled            OUT NOCOPY NUMBER
   ,p_band1_paid                OUT NOCOPY NUMBER
   ,p_band2_entitled            OUT NOCOPY NUMBER
   ,p_band2_paid                OUT NOCOPY NUMBER
   ,p_band3_entitled            OUT NOCOPY NUMBER
   ,p_band3_paid                OUT NOCOPY NUMBER
   ,p_band4_entitled            OUT NOCOPY NUMBER
   ,p_band4_paid                OUT NOCOPY NUMBER
   ,p_noband_entitled           OUT NOCOPY NUMBER
   ,p_noband_paid               OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_osp_band_entitlements';
--    l_udt_column_name pay_user_columns.user_column_name%TYPE ;
    l_error_code                  NUMBER;
  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_pl_id:'||p_pl_id);
      debug('p_search_start_date:'||fnd_date.date_to_canonical(p_search_start_date));
      debug('p_search_end_date:'||fnd_date.date_to_canonical(p_search_end_date));
    END IF;
    -- Do the Search Start Date <= Search End Date Validation Here.

    p_error_code := 0;
    -- With the above column name get entitlement days for BAND1.
    p_band1_entitled :=
      pqp_gb_osp_functions.get_abs_plan_ent_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_entitlement =>       'BAND1'
      );
    -- With the above column name get Paid days for BAND1.
    p_band1_paid :=
      pqp_gb_osp_functions.get_abs_plan_paid_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_pay =>               'BAND1'
      );
-- Ended Calls for BAND1.
-- With the above column name get entitlement days for BAND2.
    p_band2_entitled :=
      pqp_gb_osp_functions.get_abs_plan_ent_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_entitlement =>       'BAND2'
      );
    -- With the above column name get Paid days for BAND2.
    p_band2_paid :=
      pqp_gb_osp_functions.get_abs_plan_paid_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_pay =>               'BAND2'
      );
-- Ended Calls for BAND2.
  -- With the above column name get entitlement days for BAND3.
    p_band3_entitled :=
      pqp_gb_osp_functions.get_abs_plan_ent_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_entitlement =>       'BAND3'
      );
    -- With the above column name get Paid days for BAND2.
    p_band3_paid :=
      pqp_gb_osp_functions.get_abs_plan_paid_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_pay =>               'BAND3'
      );
    -- Ended Calls for BAND3.
    -- With the above column name get entitlement days for BAND4.
    p_band4_entitled :=
      pqp_gb_osp_functions.get_abs_plan_ent_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_entitlement =>       'BAND4'
      );
    -- With the above column name get Paid days for BAND2.
    p_band4_paid :=
      pqp_gb_osp_functions.get_abs_plan_paid_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_pay =>               'BAND4'
      );
    -- Ended Calls for BAND4.
    -- With the above column name get entitlement days for NOBAND.
    p_noband_entitled :=
      pqp_gb_osp_functions.get_abs_plan_ent_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_entitlement =>       'NOBAND'
      );

    --We need to add up the rows with WAITINGDAY to p_noband_entitled for the
    --payroll calculation as WAITINGDAY is treated as NOBAND entitlement in payroll.
    p_noband_entitled := NVL(p_noband_entitled,0) +
      pqp_gb_osp_functions.get_abs_plan_ent_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_entitlement =>       'WAITINGDAY'
      );


    -- With the above column name get Paid days for BAND2.
    p_noband_paid :=
      pqp_gb_osp_functions.get_abs_plan_paid_days_info(
        p_absence_attendance_id =>      p_absence_attendance_id
       ,p_pl_id =>                      p_pl_id
       ,p_error_code =>                 l_error_code
       ,p_error_message =>              p_error_message
       ,p_search_start_date =>          p_search_start_date
       ,p_search_end_date =>            p_search_end_date
       ,p_level_of_pay =>               'NOBAND'
      );
    -- Ended Calls for NOBAND.
    debug_exit(l_proc_name);
    RETURN 0;


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
  END get_osp_band_paid_entitlements;

-- This function returns the column, row and the type declared as in the calendar.
-- For example a date is defined as "Bank Holiday". Then if the date is passed as
-- input this functions returns the column, row and value i.e.'Bank Holiday'.
-- p_cal_value is the Value which effects the search in combination with p_filter parameter.
-- p_filter parameter can have 4 possible values (AllMatch, ExactMatch, Except, AllExcept).
--
  FUNCTION chk_calendar_occurance(
    p_date                      IN       DATE
   ,p_calendar_table_id         IN       NUMBER
   ,p_calendar_rules_list       IN       VARCHAR2
   ,p_cal_rul_name              OUT NOCOPY VARCHAR2
   ,p_cal_day_name              OUT NOCOPY VARCHAR2
   ,p_cal_rule_value            OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_cal_value                 IN       VARCHAR2
   ,p_filter                    IN       VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'chk_calendar_occurance';
    l_retval                      NUMBER := 0;
  BEGIN
    debug_enter(l_proc_name);
    p_error_code := 0;
    debug('p_date:' || fnd_date.date_to_canonical(p_date));
    debug(
         'p_calendar_table_id:'
      || fnd_number.number_to_canonical(p_calendar_table_id)
    );
    debug('p_calendar_rules_list:' || p_calendar_rules_list);
    debug('p_cal_value:' || p_cal_value);
    debug('p_filter:' || p_filter);
    OPEN csr_cal_occur(
          p_date =>                       p_date
         ,p_table_id =>                   p_calendar_table_id
         ,p_calendar_rules_list =>        p_calendar_rules_list
         ,p_filter_value =>               p_cal_value
         ,p_filter =>                     p_filter
                      );
    FETCH csr_cal_occur INTO p_cal_day_name, p_cal_rul_name, p_cal_rule_value;

    IF csr_cal_occur%NOTFOUND
    THEN
      l_retval := -1;
    END IF;

    CLOSE csr_cal_occur;
    debug('l_retval:' || fnd_number.number_to_canonical(l_retval));
    IF g_debug THEN
      debug('l_retval:'||l_retval);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;


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
  END chk_calendar_occurance;


  FUNCTION get_band_entitlement_balance(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_scheme_calendar_type      IN       VARCHAR2
   ,p_scheme_calendar_duration  IN       VARCHAR2
   ,p_scheme_calendar_uom       IN       VARCHAR2
   ,p_scheme_start_date         IN       VARCHAR2
   ,p_scheme_overlap_rule       IN       VARCHAR2
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_days_hours                IN  VARCHAR2 DEFAULT 'DAYS'
  -- Added p_days_hours paramter for Hours solution
  -- It contains default DAYS. This paramter decides
  -- which value to return
--Added for CS
   ,p_default_work_pattern      IN VARCHAR2
   -- LG/PT
   ,p_plan_types_to_extend_period IN VARCHAR2 -- LG/PT
   ,p_entitlement_uom             IN VARCHAR2 -- LG/PT
   ,p_absence_schedule_wp         IN VARCHAR2 -- LG/PT
   ,p_track_part_timers           IN VARCHAR2 -- LG/PT
   ,p_absence_start_date          IN DATE  DEFAULT NULL
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_band_entitlement_balance';
    l_entitlements                pqp_absval_pkg.t_entitlements;
    -- dummy used only to ensure that all mandatory params
    -- to get_absences_taken_to_date are fulfilled
    -- note passing an empty entitlements table to
    -- get_absences_taken_to_date has no impact
    -- if you do pass it then the function ensures that
    -- any bands not used are set to 0.

    l_absences_taken_to_date      pqp_absval_pkg.t_entitlements;
    i                             BINARY_INTEGER;
    l_retval                      NUMBER(11, 5) := 0;
-- Added for CS
    l_dualrolling_4_year BOOLEAN := FALSE ;
    l_working_days_in_week
           pqp_gap_daily_absences.working_days_per_week%TYPE ;
    l_standard_work_days_in_week
           pqp_gap_daily_absences.working_days_per_week%TYPE ;


     l_current_factor        NUMBER ;
     l_ft_factor             NUMBER ;
     l_working_days_per_week NUMBER ;
     l_fte                   NUMBER ;
     l_FT_absence_wp         VARCHAR2(100);
     l_FT_working_wp         VARCHAR2(100);
     l_assignment_wp         VARCHAR2(100);
     l_is_full_timer         BOOLEAN ;
     l_abs_precision         VARCHAR2(10);
     l_absence_start_date DATE;
     l_is_assignmen_wp BOOLEAN;

  BEGIN


    g_debug := hr_utility.debug_enabled;

    IF p_absence_start_date IS NULL
    THEN
       l_absence_start_date := p_effective_date;
    ELSE
       l_absence_start_date := p_absence_start_date;
    END IF;
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_absence_start_date:'||fnd_date.date_to_canonical(l_absence_start_date));
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_pl_typ_id:'||p_pl_typ_id);
      debug('p_scheme_calendar_type'||p_scheme_calendar_type);
      debug('p_scheme_calendar_duration'||p_scheme_calendar_duration);
      debug('p_scheme_calendar_uom'||p_scheme_calendar_uom);
      debug('p_scheme_start_date'||p_scheme_start_date);
      debug('p_scheme_overlap_rule'||p_scheme_overlap_rule);
      debug('p_level_of_entitlement'||p_level_of_entitlement);
      debug('p_days_hours'||p_days_hours);
    END IF;
    p_error_code := 0;
    l_proc_step := 10;
-- check whether this is the first call for this assignment,
-- plan and effective date

    IF g_debug THEN
      debug('g_assignment_id');
      debug(g_assignment_id);
      debug('p_assignment_id');
      debug(p_assignment_id);
      debug('g_balance_date');
      debug(g_balance_date);
      debug('p_effective_date');
      debug(p_effective_date);
      debug('g_pl_typ_id');
      debug(g_pl_typ_id);
    END IF;

    l_proc_step := 20;

    l_abs_precision :=
       PQP_UTILITIES.pqp_get_config_value(
                 p_business_group_id     => p_business_group_id
                ,p_legislation_code     => 'GB'
                ,p_column_name          => 'PCV_INFORMATION7'
                ,p_information_category => 'PQP_GB_OSP_OMP_CONFIG'
                );

    -- assign the rounding precision to global variable.
    -- if null then asssign rounding precision to be 5
    -- so by default absemces taken would be rounded to 5 places.
    g_abs_rounding_precision :=
                    FND_NUMBER.canonical_to_number(NVL(l_abs_precision,5));

    IF g_debug THEN
      debug('g_abs_rounding_precision');
      debug(g_abs_rounding_precision);
    END IF;


    IF    g_assignment_id <> p_assignment_id
       OR g_pl_typ_id <> p_pl_typ_id
       OR g_balance_date <> p_effective_date
 -- Adding the remaining cache criterias as there is probability of
 -- scheme attributes changing for the same assignment, pl_typ and
 -- effective_date . Eg: in Civil Service, assignment_id, pl_typ_id,
 -- balance_date remains the same but scheme duration changes.
       OR g_scheme_calendar_type <> p_scheme_calendar_type
       OR g_scheme_calendar_duration <> p_scheme_calendar_duration
       OR g_scheme_calendar_uom <> p_scheme_calendar_uom
       OR g_scheme_start_date_txt <> p_scheme_start_date
    THEN
-- Added for CS

       l_proc_step := 25;
       IF g_debug THEN
         debug(l_proc_name,l_proc_step);
       END IF;

       IF p_days_hours = 'WEEKS' THEN -- CSDAYS is changed to WEEKS
         l_dualrolling_4_year := TRUE ;
       END IF ;


      -- Idealy get_absences_taken_to_dates should return absences
      -- taken to date in terms of current work pattern.
      -- If the l_entitlement being passed is empty, then the
      -- absences taken to date returned, is the total absences taken to date
      -- irrespective of the work patterns enrolled during the period of
      -- absence.To get the absences in terms of the current work pattern
      -- we need to multiply it with the l_working_days_per_week factor
      -- returned by the get_factors call.

      pqp_absval_pkg.get_absences_taken_to_date(
        p_assignment_id               => p_assignment_id
       ,p_business_group_id           => p_business_group_id
       ,p_effective_date              => p_effective_date
       ,p_pl_typ_id                   => p_pl_typ_id
       ,p_scheme_period_overlap_rule  => p_scheme_overlap_rule
       ,p_scheme_period_type          => p_scheme_calendar_type
       ,p_scheme_period_duration      => p_scheme_calendar_duration
       ,p_scheme_period_uom           => p_scheme_calendar_uom
       ,p_scheme_period_start         => p_scheme_start_date
       ,p_entitlements                => l_entitlements
       ,p_absences_taken_to_date      => l_absences_taken_to_date
       ,p_dualrolling_4_year          => l_dualrolling_4_year
       ,p_plan_types_to_extend_period => p_plan_types_to_extend_period
       ,p_entitlement_uom             => p_entitlement_uom
       ,p_default_wp                  => p_default_work_pattern
       ,p_absence_schedule_wp         => p_absence_schedule_wp
       ,p_track_part_timers           => p_track_part_timers
       ,p_absence_start_date          => l_absence_start_date
      );

       l_proc_step := 30;
       IF g_debug THEN
         debug(l_proc_name,l_proc_step);
       END IF;

      g_assignment_id := p_assignment_id;
      g_pl_typ_id := p_pl_typ_id;
      g_balance_date := p_effective_date;
      g_scheme_calendar_type := p_scheme_calendar_type ;
      g_scheme_calendar_duration := p_scheme_calendar_duration ;
      g_scheme_calendar_uom :=  p_scheme_calendar_uom ;
      g_scheme_start_date_txt := p_scheme_start_date;
      g_absences_taken_to_date := l_absences_taken_to_date;

       l_proc_step := 35;
       IF g_debug THEN
         debug(l_proc_name,l_proc_step);
       END IF;

    END IF;


    l_proc_step := 40;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    i := g_absences_taken_to_date.FIRST;

    WHILE i IS NOT NULL
    LOOP

      l_proc_step := 45+i/10000;
      IF g_debug THEN
        debug(l_proc_name,45+i/10000);
      END IF;


      IF g_absences_taken_to_date(i).band = p_level_of_entitlement
      THEN

        l_proc_step := 47+i/10000;
        IF g_debug THEN
          debug(l_proc_name, 47+i/10000);
        END IF;
       -- l_retval := g_absences_taken_to_date(i).entitlement;
       -- i := NULL;

       --Added to get the current work-pattern and fte
        pqp_absval_pkg.get_factors (
            p_business_group_id     => p_business_group_id
           ,p_effective_date        => p_effective_date
           ,p_assignment_id         => p_assignment_id
           ,p_entitlement_uom       => p_entitlement_uom
           ,p_default_wp            => p_default_work_pattern
           ,p_absence_schedule_wp   => p_absence_schedule_wp
           ,p_track_part_timers     => p_track_part_timers
           ,p_current_factor        => l_current_factor
           ,p_ft_factor             => l_ft_factor
           ,p_working_days_per_week => l_working_days_per_week
           ,p_fte                   => l_fte
           ,p_FT_absence_wp         => l_FT_absence_wp
           ,p_FT_working_wp         => l_FT_working_wp
           ,p_assignment_wp         => l_assignment_wp
           ,p_is_full_timer         => l_is_full_timer
	   ,p_is_assignment_wp      => l_is_assignmen_wp
           ) ;

       -- Added the below IF for Hours solution

    IF p_days_hours = 'DAYS' THEN -- Enters this block for LG

          l_proc_step := 50+i/10000;
          IF g_debug THEN
            debug(l_proc_name, 50+i/10000);
          END IF;

      -- Added for converting the absences taken to date
      -- to absences taken in terms of current work pattern.

         IF NVL(p_track_part_timers,'N') = 'Y' THEN
                l_retval := g_absences_taken_to_date(i).duration_per_week *
                l_working_days_per_week ;
         ELSE
                l_retval := g_absences_taken_to_date(i).duration ;
         END IF;

         l_retval :=pqp_utilities.round_value_up_down
               ( p_value_to_round => l_retval
                ,p_base_value     => g_abs_rounding_precision
                ,p_rounding_type  => g_abs_rounding_type
                ) ;


         ELSIF p_days_hours = 'HOURS' THEN

           l_proc_step := 52+i/10000;
           IF g_debug THEN
             debug(l_proc_name, 52+i/10000);
           END IF;

         IF NVL(p_track_part_timers,'N') = 'Y' THEN
               l_retval := g_absences_taken_to_date(i).duration_in_hours*l_fte ;
         ELSE
               l_retval := g_absences_taken_to_date(i).duration_in_hours;
         END IF;

         l_retval :=pqp_utilities.round_value_up_down
               ( p_value_to_round => l_retval
                ,p_base_value     => g_abs_rounding_precision
                ,p_rounding_type  => g_abs_rounding_type
                ) ;


-- Added for CS
         ELSIF p_days_hours = 'WEEKS' THEN -- CSDAYS is changed to WEEKS

           l_proc_step := 55+i/10000;
           IF g_debug THEN
             debug(l_proc_name, 55+i/10000);
           END IF;

           -- this gets executed when called for CS
           -- get the number of working days per week.
           -- IF the person is a Full timer there may not be any assignment
           -- level work pattern. so pass a default work pattern
           -- the standard work pattern call is required as we have
           -- to compare to know if the person is Full timer or part timer

             l_working_days_in_week :=
                   pqp_schedule_calculation_pkg.get_working_days_in_week
                           (
                            p_assignment_id     => p_assignment_id
                           ,p_business_group_id => p_business_group_id
                           ,p_effective_date    => p_effective_date
                           ,p_default_wp        => p_default_work_pattern
                           ) ;
              -- Default Work Pattern is passed as Over Ride Work Pattern
              -- because we want the days in standard work pattern but not
              -- at assignment level.
              -- if we pass that as p_default_wp the function returns the
              -- number of days at assignment level work pattern if
              -- there is any

           l_proc_step := 57+i/10000;
           IF g_debug THEN
             debug(l_proc_name, 57+i/10000);
           END IF;

              l_standard_work_days_in_week :=
                   pqp_schedule_calculation_pkg.get_working_days_in_week
                           (
                            p_assignment_id     => p_assignment_id
                           ,p_business_group_id => p_business_group_id
                           ,p_effective_date    => p_effective_date
                           ,p_override_wp       => p_default_work_pattern
                           ) ;

           l_proc_step := 59+i/10000;
           IF g_debug THEN
             debug(l_proc_name, 59+i/10000);
           END IF;


              IF NVL(l_working_days_in_week,l_standard_work_days_in_week) >=
                 l_standard_work_days_in_week THEN
                     l_working_days_in_week  := 7 ;
              END IF;

           l_proc_step := 60+i/10000;
           IF g_debug THEN
             debug(l_proc_name, 60+i/10000);
           END IF;

           -- Multiply with working_days_per_week
           l_retval := g_absences_taken_to_date(i).duration_per_week *
                        l_working_days_in_week ;
        -- l_retval := ROUND(l_retval,2) ;
        -- PT Changes cchappid
        -- For Full timers round to lower 0.5
        -- For Part-timers round it to upper 0.5
        -- 4.4 for FT = 4. or 4.6 = 4.5
        -- 4.4 for a PT = 4.5 or 4.6 = 5
        -- NVL is just to ensure that it wont fail if there is no
        -- DEFAULT work Pattern at Scheme level

           l_retval :=pqp_utilities.round_value_up_down
               ( p_value_to_round => l_retval
                ,p_base_value     => g_abs_rounding_precision
                ,p_rounding_type  => g_abs_rounding_type
                ) ;


         END IF;

         i := NULL ;

      ELSE
        l_proc_step := 70+i/10000;
        IF g_debug THEN
          debug(l_proc_name, 70+i/10000);
        END IF;
        i := g_absences_taken_to_date.NEXT(i);
      END IF;
    END LOOP;

    l_proc_step := 75;
    IF g_debug THEN
      debug('l_retval:'||l_retval);
    END IF;

    IF g_debug THEN
      debug('l_retval:'||l_retval);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;

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
  END get_band_entitlement_balance;

-- This Function gets the scheme Details based on element_type_id available as context
  FUNCTION get_band_ent_bal_by_ele_typ_id(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_element_type_id           IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_days_hours                IN  VARCHAR2 DEFAULT 'DAYS'
   ,p_absence_start_date        IN       DATE  DEFAULT NULL
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_band_ent_bal_by_ele_typ_id';
    l_retval                      NUMBER;
-- Added for CS

    l_scheme_duration pay_element_type_extra_info.eei_information20%TYPE ;
    l_scheme_uom pay_element_type_extra_info.eei_information21%TYPE ;
    l_days_hours VARCHAR2(30) := p_days_hours ;
--
    CURSOR csr_osp_scheme_det(
      p_element_type_id           IN       NUMBER
     ,p_effective_date            IN       DATE
    )
    IS
      SELECT pln.pl_typ_id
            ,eei.eei_information3 cal_type
            ,eei.eei_information4 cal_duration
            ,eei.eei_information5 cal_uom
            ,eei.eei_information6 start_date
            ,eei.eei_information26 overlap_rul
-- Added for CS
            ,eei.eei_information20 dualrolling_dur
            ,eei.eei_information21 dualrolling_uom
            ,eei.eei_information17 default_work_pattern
 -- Added for LG/PT
            ,eei.eei_information22 track_part_timers
            ,eei.eei_information8 entitlement_uom
            ,eei.eei_information23 absence_schedule_wp
            ,eei.eei_information24 plan_types_to_extend_period
      FROM   pay_element_type_extra_info eei
            ,ben_pl_f pln
      WHERE  eei.element_type_id = p_element_type_id
        --AND  eei.information_type = 'PQP_GB_OSP_ABSENCE_PLAN_INFO' -- is indexed
        AND  UPPER(eei.eei_information19) = 'ABSENCE INFO'
        AND  pln.pl_id = fnd_number.canonical_to_number(eei.eei_information1)
        AND  p_effective_date BETWEEN pln.effective_start_date
                                  AND pln.effective_end_date;

    l_scheme_det                  csr_osp_scheme_det%ROWTYPE;
    l_absence_start_date DATE;
  BEGIN

    IF p_absence_start_date IS NULL
    THEN
        l_absence_start_date := p_effective_date;
    ELSE
        l_absence_start_date := p_absence_start_date;
    END IF;

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_element_type_id:'||p_element_type_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_absence_start_date:'||fnd_date.date_to_canonical(l_absence_start_date));
      debug('p_level_of_entitlement'||p_level_of_entitlement);
      debug('p_days_hours'||p_days_hours);

                END IF;
    OPEN csr_osp_scheme_det(
          p_element_type_id =>            p_element_type_id
         ,p_effective_date =>             p_effective_date
                           );
    FETCH csr_osp_scheme_det INTO l_scheme_det;
    CLOSE csr_osp_scheme_det;

-- Added for CS
     l_scheme_duration := l_scheme_det.cal_duration ;
     l_scheme_uom := l_scheme_det.cal_uom ;

    -- This control enters into this IF only
    -- when this is called from 4-Years Function
    -- changing the scheme duration and uom to refer to 4-years
    -- segments.
     IF l_scheme_det.cal_type = 'DUALROLLING' AND p_days_hours='WEEKS' THEN
        l_scheme_duration := l_scheme_det.dualrolling_dur ;
        l_scheme_uom := l_scheme_det.dualrolling_uom ;
     END IF;

     -- setting the p_days_hours to WEEKS
     -- for 4-year call p_days_hours is already WEEKS
     -- But the below IF is requried for 1-Year call
     -- the reason being in the function we are returning the
     -- BANd Days based on work pattern when p_days_hours = 'WEEKS'
     -- this is requried whether it is 4-year or 1-year.

     IF l_scheme_det.cal_type = 'DUALROLLING'  THEN
         l_days_hours := 'WEEKS' ;
     END IF ;
--
    -- Call get_band_entitlement_balance to get the entitlements.
    l_retval :=
      pqp_gb_osp_functions.get_band_entitlement_balance(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_pl_typ_id =>                  l_scheme_det.pl_typ_id
       ,p_scheme_calendar_type =>       l_scheme_det.cal_type
       ,p_scheme_calendar_duration =>   l_scheme_duration
       ,p_scheme_calendar_uom =>        l_scheme_uom
       ,p_scheme_start_date =>          l_scheme_det.start_date
       ,p_scheme_overlap_rule =>        l_scheme_det.overlap_rul
       ,p_level_of_entitlement =>       p_level_of_entitlement
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
       ,p_days_hours    =>              l_days_hours
       ,p_default_work_pattern => l_scheme_det.default_work_pattern
       ,p_plan_types_to_extend_period => l_scheme_det.plan_types_to_extend_period
       ,p_entitlement_uom             => l_scheme_det.entitlement_uom
       ,p_absence_schedule_wp         => l_scheme_det.absence_schedule_wp
       ,p_track_part_timers           => l_scheme_det.track_part_timers
       ,p_absence_start_date          => l_absence_start_date
      );

    IF g_debug THEN
      debug('l_retval:'||l_retval);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;

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
  END get_band_ent_bal_by_ele_typ_id;

-- This Function gets the scheme Details based on element_type_id available as context
-- and gets the entitlement balance for all bands at one go
  FUNCTION get_all_band_ent_balance(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_element_type_id           IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_band1_ent_bal             OUT NOCOPY NUMBER
   ,p_band2_ent_bal             OUT NOCOPY NUMBER
   ,p_band3_ent_bal             OUT NOCOPY NUMBER
   ,p_band4_ent_bal             OUT NOCOPY NUMBER
   ,p_noband_ent_bal            OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_absence_start_date        IN       DATE  DEFAULT NULL
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_all_band_ent_balance';
    l_retval                      NUMBER;
    l_absence_start_date DATE;
  BEGIN


   IF p_absence_start_date IS NULL
   THEN
       l_absence_start_date := p_effective_date;
   ELSE
       l_absence_start_date := p_absence_start_date;
   END IF;

   IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_element_type_id:'||p_element_type_id);
      debug('p_effective_date'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_absence_start_date'||fnd_date.date_to_canonical(l_absence_start_date));
    END IF;
    p_band1_ent_bal :=
      get_band_ent_bal_by_ele_typ_id(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'BAND1'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
       ,p_absence_start_date =>         l_absence_start_date
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    p_band2_ent_bal :=
      get_band_ent_bal_by_ele_typ_id(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'BAND2'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
       ,p_absence_start_date =>         l_absence_start_date
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    p_band3_ent_bal :=
      get_band_ent_bal_by_ele_typ_id(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'BAND3'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
       ,p_absence_start_date =>         l_absence_start_date
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    p_band4_ent_bal :=
      get_band_ent_bal_by_ele_typ_id(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'BAND4'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
       ,p_absence_start_date =>         l_absence_start_date
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    p_noband_ent_bal :=
      get_band_ent_bal_by_ele_typ_id(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'NOBAND'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
       ,p_absence_start_date =>         l_absence_start_date
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    debug_exit(l_proc_name);
    RETURN 0;

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
  END get_all_band_ent_balance;

--

  FUNCTION get_band_ent_bal_by_pl_id( -- needs to be extended for omp
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_band_ent_bal_by_pl_id';
    l_retval                      NUMBER;
    l_ele_typ_id                  NUMBER;

    CURSOR csr_get_element_type_id(p_pl_id IN NUMBER)
    IS
      SELECT eei.element_type_id
      FROM   pay_element_type_extra_info eei
      WHERE  eei.information_type = 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
      -- needs to be extended for omp
         AND eei.eei_information1 = fnd_number.number_to_canonical(p_pl_id)
         AND UPPER(eei.eei_information19) = 'ABSENCE INFO';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_pl_id:'||p_pl_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_level_of_entitlement'||p_level_of_entitlement);

                END IF;
    OPEN csr_get_element_type_id(p_pl_id => p_pl_id);
    FETCH csr_get_element_type_id INTO l_ele_typ_id;
    CLOSE csr_get_element_type_id;
    l_retval :=
      get_band_ent_bal_by_ele_typ_id(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            l_ele_typ_id
       ,p_level_of_entitlement =>       p_level_of_entitlement
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
      );
    IF g_debug THEN
      debug('l_retval:'||l_retval);
      debug_exit(l_proc_name);
    END IF;
    RETURN l_retval;

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
  END get_band_ent_bal_by_pl_id;

--Function added by sshetty
--This function returns value for the level of pay passed.

  FUNCTION get_paid_days_duration(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_level_of_pay              IN       VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_error_message               VARCHAR2(100);
    l_error_code                  NUMBER;
    l_balance                     pqp_gap_daily_absences.DURATION%TYPE;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_paid_days_duration';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date'||p_effective_date);
      debug('p_pl_id:'||p_pl_id);
      debug('p_level_of_pay'||p_level_of_pay);
      debug('p_search_start_date:'||fnd_date.date_to_canonical(p_search_start_date));
      debug('p_search_end_date:'||fnd_date.date_to_canonical(p_search_end_date));
    END IF;
    OPEN csr_get_level_pay(
          p_assignment_id
         ,p_business_group_id
         ,p_search_start_date
         ,p_search_end_date
         ,p_level_of_pay
                          );
    FETCH csr_get_level_pay INTO l_balance;
    CLOSE csr_get_level_pay;
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    RETURN(l_balance);

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
  END get_paid_days_duration;

-- Function get_entitled_days_duration Returns the No of Entitlements used up
-- in the given date range.
  FUNCTION get_entitled_days_duration(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_error_message               VARCHAR2(100);
    l_error_code                  NUMBER;
    l_balance                     pqp_gap_daily_absences.DURATION%TYPE;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_entitled_days_duration';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date:'||fnd_date.date_to_canonical(p_effective_date));
      debug('p_pl_id:'||p_pl_id);
      debug('p_level_of_entitlement'||p_level_of_entitlement);
      debug('p_search_start_date:'||fnd_date.date_to_canonical(p_search_start_date));
      debug('p_search_end_date:'||fnd_date.date_to_canonical(p_search_end_date));
                END IF;
    OPEN csr_get_level_ent(
          p_assignment_id
         ,p_business_group_id
         ,p_search_start_date
         ,p_search_end_date
         ,p_level_of_entitlement
                          );
    FETCH csr_get_level_ent INTO l_balance;
    CLOSE csr_get_level_ent;
    IF g_debug THEN
      debug('l_balance:'||l_balance);
      debug_exit(l_proc_name);
    END IF;
    RETURN(l_balance);

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
  END get_entitled_days_duration;

-- Function get_wp_days_duration Returns the No of Work Pattern Days
-- in the given date range.
  FUNCTION get_wp_days_duration(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_wp_day_type               IN       VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_error_message               VARCHAR2(100);
    l_error_code                  NUMBER;
    l_balance                     pqp_gap_daily_absences.DURATION%TYPE;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_wp_days_duration';
  BEGIN
    debug_enter(l_proc_name);
    debug(l_proc_name, 20);
    OPEN csr_get_wp_type_days(
          p_assignment_id
         ,p_business_group_id
         ,p_search_start_date
         ,p_search_end_date
         ,p_wp_day_type
                             );
    FETCH csr_get_wp_type_days INTO l_balance;
    CLOSE csr_get_wp_type_days;
    debug_exit(l_proc_name);
    RETURN(l_balance);
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
  END get_wp_days_duration;

-- Converts the Absence Start Date into julian day and returns the last 4 digits
-- as Sub Priority.This may be changed in futire to (julian_date * 100) + offset
  FUNCTION get_subpriority(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_payroll_action_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_absence_start_date        IN       DATE
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_subproirity';
    l_subpriority                 NUMBER;
  BEGIN
  /*
    l_proc_step := 1;
    hr_utility.set_location(l_proc_name,44333);
    l_proc_step := 2;
    hr_utility.set_location(' Absence Start Date: ' || to_char(p_absence_start_date),44333);
    l_proc_step := 3;
    hr_utility.set_location('p_business_group_id:'||p_business_group_id,44333);
    l_proc_step := 4;
    hr_utility.set_location('p_assignment_id:'||p_assignment_id,44333);
    l_proc_step := 5;
    hr_utility.set_location('p_payroll_action_id:'||p_payroll_action_id,44333);
    l_proc_step := 6;
    hr_utility.set_location('p_pl_id:'||p_pl_id,44333);
    l_proc_step := 7;
    hr_utility.set_location('p_ler_id:'||p_ler_id,44333);
    l_proc_step := 8;

-- In future the sub priority Calculation may be changed to consider element priorities
-- like Primary element or Secondary element. For this element Type Id can be derived from
-- the logic of the existing DBI ( BEN_ABR_ELEMENT_TYPE_ID ). The calculation could change
-- to something like (julian_date * 100) + 2digit offset. For all the elements in a absence
-- (julian_date * 100) is same.So offset value can be derived based on the element.
-- The Contexts are provided for futire use in calculating the offset.

*/
    l_proc_step := 1;
    l_subpriority := TO_NUMBER(SUBSTR(TO_CHAR(p_absence_start_date, 'J'), -4));
    l_proc_step := 2;
    /*
    l_proc_step := 9;
    debug('l_subpriority ' || l_subpriority, 121 );
    l_proc_step := 10;
    debug_exit(l_proc_name, 121 );
    l_proc_step := 11;
    */
    RETURN l_subpriority;

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
  END get_subpriority;

-- This Function Returns the End Date after adding the Number od Days
-- to the Start Date ( both are in parameters ). If Holiday UDT ID is
-- passed then the holidays are excluded otherwise simple addition of
-- days will be used to arrive at End Date.
--
  FUNCTION get_next_cal_date(
    p_business_group_id         IN       NUMBER
   ,p_date_start                IN       DATE
   ,p_days                      IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
    RETURN DATE
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_next_cal_day';
    l_days                        NUMBER;
    l_holidays                    NUMBER;
    l_curr_date                   DATE;
  BEGIN
    debug_enter(l_proc_name);
    debug(' p_date_start ' || to_char(p_date_start));
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_days:'||p_days);
    debug('p_table_id:'||p_table_id);
    debug('p_column_name'||p_days);
    debug('p_value'||p_table_id);

    l_days := p_days;

    IF p_table_id IS NULL
    THEN
      debug(l_proc_name, 10);
      l_curr_date := p_date_start + l_days;
    ELSE
      debug(' Table ID Passed : ' || p_table_id);
      l_curr_date := p_date_start;

      LOOP
        EXIT WHEN l_days <= 0;
        -- Check for Holidays
        l_holidays :=
          pqp_gb_get_no_of_holidays(
            p_business_group_id =>          p_business_group_id
           ,p_abs_start_date =>             l_curr_date
           ,p_abs_end_date =>               l_curr_date
           ,p_table_id =>                   p_table_id
           ,p_column_name =>                p_column_name
           ,p_value =>                      p_value
          );

        IF l_holidays = 0
        THEN
          l_days := l_days - 1;
        ELSE
          debug(l_proc_name, 80);
        END IF;

        l_curr_date := l_curr_date + 1;
      END LOOP;
    END IF;
    debug('l_holidays:'||l_holidays);
    debug_exit(l_proc_name);
    RETURN(l_curr_date);
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
  END get_next_cal_date;

--======================================================================
--                     FUNCTION EXISTS_IN_GAP_LOOKUP
--======================================================================
  FUNCTION exists_in_gap_lookup(
    p_business_group_id         IN       NUMBER
   ,p_lookup_code               IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_lookup_type               IN       VARCHAR2
  )
    RETURN BOOLEAN
  IS
    --
    l_security_group_id           NUMBER;
    l_exists                      VARCHAR2(1);
    l_return                      BOOLEAN := FALSE;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'exists_in_gap_lookup';

    --

    -- Cursor to get security group for a
    -- given business_group_id

    CURSOR csr_get_security_group
    IS
      SELECT fnd_number.canonical_to_number(security_group_id)
                                                            security_group_id
      FROM   per_business_groups
      WHERE  business_group_id = p_business_group_id;

    -- Cursor to check lookup code exists in
    -- user security group

    CURSOR csr_exists_in_gap_lookup(
      c_security_group_id                  NUMBER
     ,c_view_application_id                NUMBER
    )
    IS
      SELECT 'X'
      FROM   fnd_lookup_values_vl
      WHERE  lookup_type = p_lookup_type
      AND    lookup_code = p_lookup_code
      AND    security_group_id = c_security_group_id
      AND    view_application_id = c_view_application_id
      AND    enabled_flag = 'Y'
      AND    p_effective_date BETWEEN NVL(start_date_active, p_effective_date)
                                  AND NVL(end_date_active, p_effective_date);
  --
  BEGIN
    --
    debug_enter(l_proc_name);
    --
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_lookup_code '||p_lookup_code);
    debug('p_effective_date'|| fnd_date.date_to_canonical(p_effective_date));
    debug('p_lookup_type '||p_lookup_type);
    -- Get Security Group Information
    OPEN csr_get_security_group;
    FETCH csr_get_security_group INTO l_security_group_id;
    CLOSE csr_get_security_group;

    IF l_security_group_id IS NULL
    THEN
      hr_utility.set_message(800, 'HR_289296_SEC_PROF_SETUP_ERR');
      hr_utility.raise_error;
    END IF;

    -- Check whether the lookup code exists
    -- for the user security group id
    debug('Lookup Type exists for user security group id check');
    OPEN csr_exists_in_gap_lookup(l_security_group_id, 3);
    FETCH csr_exists_in_gap_lookup INTO l_exists;

    IF csr_exists_in_gap_lookup%NOTFOUND
    THEN
      -- Check whether the lookup code exists
      -- for global security group id
      debug('Call hr_api.not_exists_in_hr_lookups');

      IF hr_api.not_exists_in_hr_lookups(p_effective_date, p_lookup_type
          ,p_lookup_code)
      THEN
        l_return := FALSE;
      ELSE
        l_return := TRUE;
      END IF; -- End if of lookup code in hr_lookups check...
    ELSE -- exists in fnd_lookups
      l_return := TRUE;
    END IF; -- End if of lookup code in fnd_lookups check...

    CLOSE csr_exists_in_gap_lookup;
    --
    debug_exit(l_proc_name);
    RETURN l_return;
  --
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
  END exists_in_gap_lookup;

--



---------------------------------------------------
---- Added for Daily Absences in OMP from here ----
---------------------------------------------------

-- This is a Formula Fucntion called in OMP Pay Processing Fast Formula
-- This Formula get all the Bands consumed as of effective date
-- ( usually this will be period start date or absence start date )
  FUNCTION get_omp_all_band_ent_balance(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_element_type_id           IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_band1_ent_bal             OUT NOCOPY NUMBER
   ,p_band2_ent_bal             OUT NOCOPY NUMBER
   ,p_band3_ent_bal             OUT NOCOPY NUMBER
   ,p_band4_ent_bal             OUT NOCOPY NUMBER
   ,p_noband_ent_bal            OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_omp_all_band_ent_balance';
    l_retval                      NUMBER;
  BEGIN
    debug_enter(l_proc_name);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_element_type_id:'||p_element_type_id);
    p_band1_ent_bal :=
      pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'BAND1'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    p_band2_ent_bal :=
      pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'BAND2'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    p_band3_ent_bal :=
      pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'BAND3'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    p_band4_ent_bal :=
      pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'BAND4'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    p_noband_ent_bal :=
      pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_element_type_id =>            p_element_type_id
       ,p_level_of_entitlement =>       'NOBAND'
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
      );

    IF p_error_code = -1
    THEN
      RETURN -1;
    END IF; -- End if of check for error code ...

    debug_exit(l_proc_name);
    RETURN 0;

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
  END get_omp_all_band_ent_balance;

-- This function is called from function get_omp_all_band_ent_balance. This
-- gets the Plan Type Id from the Element Type Id and Passes in onto
-- get_omp_band_ent_bal_pl_typ to get the Band Entitlements usedup.
  FUNCTION get_omp_band_ent_bal_ele_typ(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_element_type_id           IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_days_hours                IN  VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_omp_band_ent_bal';
    l_retval                      NUMBER;

    CURSOR csr_osp_scheme_det
      (p_element_type_id           IN       NUMBER
      ,p_effective_date            IN       DATE
      ) IS
    SELECT pln.pl_typ_id
    FROM   pay_element_type_extra_info eei
          ,ben_pl_f pln
    WHERE  UPPER(eei.eei_information19) = 'ABSENCE INFO'
      AND  eei.element_type_id = p_element_type_id
      --AND  eei.information_type = 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
      AND  pln.pl_id =
             fnd_number.canonical_to_number(eei.eei_information1)
      AND  p_effective_date BETWEEN pln.effective_start_date
                                AND pln.effective_end_date;

    l_scheme_det                  csr_osp_scheme_det%ROWTYPE;
  BEGIN
    debug_enter(l_proc_name);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_element_type_id:'||p_element_type_id);
    OPEN csr_osp_scheme_det(
          p_element_type_id =>            p_element_type_id
         ,p_effective_date =>             p_effective_date
                           );
    FETCH csr_osp_scheme_det INTO l_scheme_det;
    CLOSE csr_osp_scheme_det;
    -- Call get_band_entitlement_balance to get the entitlements.
    l_retval :=
      pqp_gb_osp_functions.get_omp_band_ent_bal_pl_typ(
        p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_assignment_id =>              p_assignment_id
       ,p_pl_typ_id =>                  l_scheme_det.pl_typ_id
       ,p_level_of_entitlement =>       p_level_of_entitlement
       ,p_error_code =>                 p_error_code
       ,p_error_message =>              p_error_message
       ,p_days_hours               => p_days_hours
      );
    debug_exit(l_proc_name);
    RETURN l_retval;
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
  END get_omp_band_ent_bal_ele_typ;

-- Function calls pqp_gb_omp_daily_absences.get_entitlement_balance
-- and caches the Band entitlements and Returns the requested Band details
  FUNCTION get_omp_band_ent_bal_pl_typ(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_days_hours                IN  VARCHAR2
  )
    RETURN NUMBER
  IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_omp_band_ent_bal_pl_typ';

    l_omp_absences_taken_to_date   pqp_absval_pkg.t_entitlements;
    l_retval NUMBER;
    i        BINARY_INTEGER;
  BEGIN
    debug_enter(l_proc_name);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_pl_typ_id:'||p_pl_typ_id);
    debug('p_level_of_entitlement'||p_level_of_entitlement);
    debug('p_days_hours'||p_days_hours);
    p_error_code := 0;

    -- First Check whether the call is first time
    -- by looking at the Global Variables.
    IF    g_omp_assignment_id <> p_assignment_id
       OR g_omp_pl_typ_id <> p_pl_typ_id
       OR g_omp_balance_date <> p_effective_date
    THEN
      debug('p_assignment_id:' || p_assignment_id);
      -- Call the get_total_entitlements_balance Procedure
      -- and get the values in pl/sql table and set global values.
      pqp_gb_omp_daily_absences.get_entitlement_balance(
        p_assignment_id =>              p_assignment_id
       ,p_business_group_id =>          p_business_group_id
       ,p_effective_date =>             p_effective_date
       ,p_pl_typ_id =>                  p_pl_typ_id
       ,p_absences_taken_to_date =>     l_omp_absences_taken_to_date
       ,p_error_code =>                 p_error_code
       ,p_message =>                    p_error_message
      );
      g_omp_assignment_id := p_assignment_id;
      g_omp_pl_typ_id := p_pl_typ_id;
      g_omp_balance_date := p_effective_date;
      g_omp_absences_taken_to_date := l_omp_absences_taken_to_date;
    END IF;

    debug(l_proc_name, 30);


    i := g_omp_absences_taken_to_date.FIRST;

    WHILE i IS NOT NULL
    LOOP
      IF g_omp_absences_taken_to_date(i).band = p_level_of_entitlement
      THEN
         IF p_days_hours = 'DAYS' THEN
             l_retval := g_omp_absences_taken_to_date(i).entitlement ;
         ELSIF p_days_hours = 'HOURS' THEN
           l_retval := g_omp_absences_taken_to_date(i).duration_in_hours ;
         END IF;
         i := NULL ;
      ELSE
        i := g_omp_absences_taken_to_date.NEXT(i);
      END IF;
    END LOOP;
    debug('l_retval:'||l_retval);
    debug_exit(l_proc_name);
    RETURN NVL(l_retval, 0);

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
  END get_omp_band_ent_bal_pl_typ;
---------------------------------------------------
---- Added for Daily Absences in OMP End here ----
---------------------------------------------------


---------------------------------------------------------------------------
------ Added Required Functions for Hours Solution ----------------
---------------------------------------------------------------------------
FUNCTION get_abs_plan_ent_hours_info
                    ( p_absence_attendance_id IN  NUMBER,
                      p_pl_id                 IN  NUMBER,
                      p_error_code            OUT NOCOPY NUMBER,
                      p_error_message         OUT NOCOPY VARCHAR2,
                      p_search_start_date     IN  DATE DEFAULT NULL,
                      p_search_end_date       IN  DATE DEFAULT NULL,
                      p_level_of_entitlement  IN  VARCHAR2 DEFAULT NULL )
         RETURN NUMBER IS
    l_csr_entitled_days_rec csr_entitled_days%ROWTYPE ;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_abs_plan_ent_hours_info';
    l_no_of_hours NUMBER ;
BEGIN
    debug_enter(l_proc_name) ;
    IF g_debug then
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
       debug('p_pl_id:'||p_pl_id);
      debug(p_search_start_date);
      debug(p_search_end_date);
      debug('p_level_of_entitlement'||p_level_of_entitlement);
    END IF;
     p_error_code := 0 ;
   -- Check the Start Date is earlier than or equal to End Date.
   IF NVL(p_search_start_date,SYSDATE) > NVL(p_search_end_date,hr_api.g_eot) THEN
     p_error_code := -1 ;
       fnd_message.set_name('PQP','PQP_230617_END_GE_START');
       --fnd_message.set_token('START',fnd_date.date_to_canonical(p_search_start_date));
       --fnd_message.set_token('END',fnd_date.date_to_canonical(p_search_end_date));
     p_error_message := fnd_message.get();
     RETURN NULL;
   END IF;

  -- Open the Cursor to get total number of Entitled days for the qualifier.
    OPEN csr_entitled_days( p_absence_attendance_id => p_absence_attendance_id,
                            p_pl_id                 => p_pl_id,
                            p_search_start_date     => p_search_start_date,
                            p_search_end_date       => p_search_end_date,
                            p_level_of_entitlement  => p_level_of_entitlement ) ;
    FETCH csr_entitled_days INTO l_csr_entitled_days_rec ;
    CLOSE csr_entitled_days;

    l_no_of_hours := l_csr_entitled_days_rec.hours ;
    IF g_debug THEN
      debug('l_no_of_hours:'||l_no_of_hours);
    END IF;
    debug_exit(l_proc_name) ;

    RETURN l_no_of_hours ;

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

END get_abs_plan_ent_hours_info ;

FUNCTION  get_abs_plan_paid_hours_info
                    ( p_absence_attendance_id IN  NUMBER,
                      p_pl_id                 IN  NUMBER,
                      p_error_code            OUT NOCOPY NUMBER,
                      p_error_message         OUT NOCOPY VARCHAR2,
                      p_search_start_date     IN  DATE DEFAULT NULL,
                      p_search_end_date       IN  DATE DEFAULT NULL,
                      p_level_of_pay          IN  VARCHAR2 DEFAULT NULL )
         RETURN NUMBER IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_abs_plan_paid_hours_info';
    l_no_of_days NUMBER ;
    l_csr_paid_days_rec csr_paid_days%ROWTYPE ; -----Added For Hours
BEGIN
    debug_enter(l_proc_name) ;
    IF g_debug then
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
       debug('p_pl_id:'||p_pl_id);
      debug(p_search_start_date);
      debug(p_search_end_date);
      debug('p_level_of_pay'||p_level_of_pay);
    END IF;
      p_error_code := 0 ;
   -- Check the Start Date is earlier than or equal to End Date.
   IF NVL(p_search_start_date,SYSDATE) > NVL(p_search_end_date,hr_api.g_eot) THEN
     p_error_code := -1 ;
       fnd_message.set_name('PQP','PQP_230617_END_GE_START');
       --fnd_message.set_token('START',fnd_date.date_to_canonical(p_search_start_date));
       --fnd_message.set_token('END',fnd_date.date_to_canonical(p_search_end_date));
     p_error_message := fnd_message.get();
     RETURN NULL;
   END IF;

  -- Open the Cursor to get total number of Paid days for the qualifier type.
    OPEN csr_paid_days( p_absence_attendance_id => p_absence_attendance_id,
                        p_pl_id                 => p_pl_id,
                        p_search_start_date     => p_search_start_date,
                        p_search_end_date       => p_search_end_date,
                        p_level_of_pay          => p_level_of_pay ) ;
    FETCH csr_paid_days INTO l_csr_paid_days_rec ; -----Added For Hours
    CLOSE csr_paid_days;

    l_no_of_days := l_csr_paid_days_rec.hours ; -----Added For Hours
    IF g_debug THEN
      debug('l_no_of_days:'||l_no_of_days);
    END IF;
    debug_exit(l_proc_name) ;

    RETURN l_no_of_days ;


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

END get_abs_plan_paid_hours_info ;



--Added For Hours

FUNCTION get_osp_hours_band_paid_ent
  (p_absence_attendance_id IN  NUMBER,
   p_pl_id                 IN  NUMBER,
   p_band1_entitled        OUT NOCOPY NUMBER,
   p_band2_entitled        OUT NOCOPY NUMBER,
   p_band3_entitled        OUT NOCOPY NUMBER,
   p_band4_entitled        OUT NOCOPY NUMBER,
   p_noband_entitled       OUT NOCOPY NUMBER,
   p_error_code            OUT NOCOPY NUMBER,
   p_error_message         OUT NOCOPY VARCHAR2,
   p_search_start_date     IN  DATE DEFAULT NULL,
   p_search_end_Date       IN  DATE DEFAULT NULL
  ) RETURN NUMBER
IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_osp_hours_band_paid_ent';

    l_error_code   NUMBER;
BEGIN
  debug_enter(l_proc_name) ;
  IF g_debug then
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
       debug('p_pl_id:'||p_pl_id);
      debug(p_search_start_date);
      debug(p_search_end_date);

   END IF;
  -- Do the Search Start Date <= Search End Date Validation Here.

  p_error_code := 0 ;
  -- With the above column name get entitlement days for BAND1.
  p_band1_entitled := pqp_gb_osp_functions.get_abs_plan_ent_hours_info
                    ( p_absence_attendance_id => p_absence_attendance_id,
                      p_pl_id                 => p_pl_id,
                      p_error_code            => l_error_code,
                      p_error_message         => p_error_message,
                      p_search_start_date     => p_search_start_date,
                      p_search_end_date       => p_search_end_date,
                      p_level_of_entitlement  => 'BAND1') ;

-- Ended Calls for BAND1.
-- With the above column name get entitlement days for BAND2.
    p_band2_entitled := pqp_gb_osp_functions.get_abs_plan_ent_hours_info
                    ( p_absence_attendance_id => p_absence_attendance_id,
                      p_pl_id                 => p_pl_id,
                      p_error_code            => l_error_code,
                      p_error_message         => p_error_message,
                      p_search_start_date     => p_search_start_date,
                      p_search_end_date       => p_search_end_date,
                      p_level_of_entitlement  => 'BAND2') ;

-- Ended Calls for BAND2.
  -- With the above column name get entitlement days for BAND3.
    p_band3_entitled := pqp_gb_osp_functions.get_abs_plan_ent_hours_info
                    ( p_absence_attendance_id => p_absence_attendance_id,
                      p_pl_id                 => p_pl_id,
                      p_error_code            => l_error_code,
                      p_error_message         => p_error_message,
                      p_search_start_date     => p_search_start_date,
                      p_search_end_date       => p_search_end_date,
                      p_level_of_entitlement  => 'BAND3') ;

  -- Ended Calls for BAND3.
  -- With the above column name get entitlement days for BAND4.
    p_band4_entitled := pqp_gb_osp_functions.get_abs_plan_ent_hours_info
                    ( p_absence_attendance_id => p_absence_attendance_id,
                      p_pl_id                 => p_pl_id,
                      p_error_code            => l_error_code,
                      p_error_message         => p_error_message,
                      p_search_start_date     => p_search_start_date,
                      p_search_end_date       => p_search_end_date,
                      p_level_of_entitlement  => 'BAND4') ;

  -- Ended Calls for BAND4.
  -- With the above column name get entitlement days for NOBAND.
    p_noband_entitled := pqp_gb_osp_functions.get_abs_plan_ent_hours_info
                    ( p_absence_attendance_id => p_absence_attendance_id,
                      p_pl_id                 => p_pl_id,
                      p_error_code            => l_error_code,
                      p_error_message         => p_error_message,
                      p_search_start_date     => p_search_start_date,
                      p_search_end_date       => p_search_end_date,
                      p_level_of_entitlement  => 'NOBAND') ;

  --We need to add up the rows with WAITINGDAY to p_noband_entitled for the
  --payroll calculation as WAITINGDAY is treated as NOBAND entitlement in payroll.

    p_noband_entitled := NVL(p_noband_entitled,0) +
       pqp_gb_osp_functions.get_abs_plan_ent_days_info(
                     p_absence_attendance_id =>      p_absence_attendance_id
                    ,p_pl_id =>                      p_pl_id
                    ,p_error_code =>                 l_error_code
                    ,p_error_message =>              p_error_message
                    ,p_search_start_date =>          p_search_start_date
                    ,p_search_end_date =>            p_search_end_date
                    ,p_level_of_entitlement =>       'WAITINGDAY'
                    );

  -- Ended Calls for NOBAND.

   RETURN 0 ;

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
END get_osp_hours_band_paid_ent ;






-- This Function gets the scheme Details based on element_type_id available as context
-- and gets the entitlement balance for all bands at one go
FUNCTION get_all_band_hours_ent_balance( p_business_group_id    IN     NUMBER
                                  ,p_assignment_id        IN     NUMBER
                                  ,p_element_type_id      IN     NUMBER
                                  ,p_effective_date       IN     DATE
                                  ,p_band1_ent_bal           OUT NOCOPY NUMBER
                                  ,p_band2_ent_bal           OUT NOCOPY NUMBER
                                  ,p_band3_ent_bal           OUT NOCOPY NUMBER
                                  ,p_band4_ent_bal           OUT NOCOPY NUMBER
                                  ,p_noband_ent_bal          OUT NOCOPY NUMBER
                                  ,p_error_code              OUT NOCOPY NUMBER
                                  ,p_error_message           OUT NOCOPY VARCHAR2 )
        RETURN NUMBER IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_all_band_hours_ent_balance';
    l_retval number ;

BEGIN

    debug_enter(l_proc_name);
    IF g_debug then
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_element_type_id:'||p_element_type_id);
      debug(p_effective_date);
    END IF;
    p_band1_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND1'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code < 0 THEN
       RETURN p_error_code;
    END IF; -- End if of check for error code ...

    p_band2_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND2'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code  = -1  THEN
       RETURN -1;
    END IF; -- End if of check for error code ...

    p_band3_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND3'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code  = -1  THEN
       RETURN -1;
    END IF; -- End if of check for error code ...

    p_band4_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND4'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code  = -1  THEN
       RETURN -1;
    END IF; -- End if of check for error code ...

    p_noband_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'NOBAND'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code = -1 THEN
       RETURN -1;
    END IF; -- End if of check for error code ...


    debug_exit(l_proc_name);
    RETURN 0;

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

END get_all_band_hours_ent_balance ;



-- This is a Formula Fucntion called in OMP Pay Processing Fast Formula
-- This Formula get all the Bands consumed as of effective date
-- ( usually this will be period start date or absence start date )
FUNCTION get_omp_all_band_hours_ent_bal(
                                       p_business_group_id IN  NUMBER
                                      ,p_assignment_id     IN  NUMBER
                                      ,p_element_type_id   IN  NUMBER
                                      ,p_effective_date    IN  DATE
                                      ,p_band1_ent_bal     OUT NOCOPY NUMBER
                                      ,p_band2_ent_bal     OUT NOCOPY NUMBER
                                      ,p_band3_ent_bal     OUT NOCOPY NUMBER
                                      ,p_band4_ent_bal     OUT NOCOPY NUMBER
                                      ,p_noband_ent_bal    OUT NOCOPY NUMBER
                                      ,p_error_code        OUT NOCOPY NUMBER
                                      ,p_error_message     OUT NOCOPY VARCHAR2 )
        RETURN NUMBER IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_omp_all_band_hours_ent_bal';
    l_retval number ;

BEGIN

    debug_enter(l_proc_name);

    p_band1_ent_bal := pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND1'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code = -1 THEN
       RETURN -1;
    END IF; -- End if of check for error code ...

    p_band2_ent_bal := pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND2'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code  = -1  THEN
       RETURN -1;
    END IF; -- End if of check for error code ...

    p_band3_ent_bal := pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND3'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code  = -1  THEN
       RETURN -1;
    END IF; -- End if of check for error code ...

    p_band4_ent_bal := pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND4'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code  = -1  THEN
       RETURN -1;
    END IF; -- End if of check for error code ...

    p_noband_ent_bal := pqp_gb_osp_functions.get_omp_band_ent_bal_ele_typ
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'NOBAND'
                            ,p_error_code           => p_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'HOURS'
                            );

    IF p_error_code = -1 THEN
       RETURN -1;
    END IF; -- End if of check for error code ...

    debug_exit(l_proc_name);
    RETURN 0;

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
END get_omp_all_band_hours_ent_bal ;
--
--
--
FUNCTION get_boundary_dates
  (p_absence_attendance_id IN            NUMBER
  ,p_pl_id                 IN            NUMBER
  ,p_first_of_last         IN            VARCHAR2
  ,p_level_of_entitlement  IN            VARCHAR2 DEFAULT NULL
  ,p_level_of_pay          IN            VARCHAR2 DEFAULT NULL
  ) RETURN DATE
IS

  g_debug            BOOLEAN;

    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
                       g_package_name||'get_boundary_dates';

  CURSOR csr_gap_absence_plan
    (p_absence_attendance_id IN NUMBER
    ,p_pl_id                 IN NUMBER
    ) IS
  SELECT gap.gap_absence_plan_id id
        ,gap.last_gap_daily_absence_date
  FROM   pqp_gap_absence_plans gap
  WHERE  gap.absence_attendance_id = p_absence_attendance_id
    AND  gap.pl_id = p_pl_id;

  l_gap_absence_plan csr_gap_absence_plan%ROWTYPE;

  CURSOR csr_first_day
    (p_gap_absence_plan_id  IN NUMBER
    ,p_level_of_entitlement IN VARCHAR2 DEFAULT NULL
    ,p_level_of_pay         IN VARCHAR2 DEFAULT NULL
    ) IS
  SELECT MIN(gda.absence_date) abs_date
  FROM   pqp_gap_daily_absences gda
  WHERE  gda.gap_absence_plan_id = p_gap_absence_plan_id
    AND  ( ( p_level_of_entitlement IS NOT NULL
            AND
             gda.level_of_entitlement = p_level_of_entitlement
           )
          OR
           ( p_level_of_pay IS NOT NULL
            AND
             gda.level_of_pay = p_level_of_pay
           )
          OR
           ( p_level_of_entitlement IS NULL
            AND
             p_level_of_pay IS NULL
           )
         );


  CURSOR csr_last_day
    (p_gap_absence_plan_id  IN NUMBER
    ,p_level_of_entitlement IN VARCHAR2 DEFAULT NULL
    ,p_level_of_pay         IN VARCHAR2 DEFAULT NULL
    ) IS
  SELECT MAX(gda.absence_date) abs_date
  FROM   pqp_gap_daily_absences gda
  WHERE  gda.gap_absence_plan_id = p_gap_absence_plan_id
    AND  ( ( p_level_of_entitlement IS NOT NULL
            AND
             gda.level_of_entitlement = p_level_of_entitlement
           )
          OR
           ( p_level_of_pay IS NOT NULL
            AND
             gda.level_of_pay = p_level_of_pay
           )
         );


  l_boundary_date DATE;

BEGIN
  g_debug := hr_utility.debug_enabled;

  IF g_debug then
      debug('p_absence_attendance_id:'||p_absence_attendance_id);
      debug('p_pl_id:'||p_pl_id);
      debug('p_first_of_last'|| p_first_of_last);
      debug('p_level_of_entitlement' ||p_level_of_entitlement);
      debug('p_level_of_pay' ||p_level_of_pay);
   END IF;
  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;

  OPEN csr_gap_absence_plan
    (p_absence_attendance_id
    ,p_pl_id
    );
  FETCH csr_gap_absence_plan INTO l_gap_absence_plan;

  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  IF csr_gap_absence_plan%FOUND
  THEN

    l_proc_step := 15;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug(p_first_of_last);
    END IF;

   IF p_first_of_last = 'LAST'
   THEN

     IF p_level_of_entitlement IS NOT NULL
      OR
       p_level_of_pay IS NOT NULL
     THEN

      OPEN csr_last_day
       (p_gap_absence_plan_id => l_gap_absence_plan.id
       ,p_level_of_entitlement => p_level_of_entitlement
       ,p_level_of_pay => p_level_of_pay
       );
      FETCH csr_last_day INTO l_boundary_date;
      CLOSE csr_last_day;

    ELSE

      l_boundary_date := l_gap_absence_plan.last_gap_daily_absence_date;

    END IF; -- IF p_level_of_entitlement IS NOT NULL


   ELSE -- p_first_of_last = 'FIRST'

    OPEN csr_first_day
     (p_gap_absence_plan_id => l_gap_absence_plan.id
     ,p_level_of_entitlement => p_level_of_entitlement
     ,p_level_of_pay => p_level_of_pay
     );
    FETCH csr_first_day INTO l_boundary_date;
    CLOSE csr_first_day;

   END IF;


  END IF;
  CLOSE csr_gap_absence_plan;

  l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  IF l_boundary_date IS NULL
  THEN
    -- Don't return NULL as fast formulas don't like them
    l_proc_step := 25;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    l_boundary_date := hr_api.g_eot;

  END IF;

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;
  RETURN l_boundary_date;


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
END get_boundary_dates;
--
--
--
FUNCTION get_first_paid_day
  (p_absence_attendance_id IN            NUMBER
  ,p_pl_id                 IN            NUMBER
  ,p_level_of_pay          IN            VARCHAR2 DEFAULT NULL
  ) RETURN DATE
IS

  g_debug     BOOLEAN;

    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
                g_package_name||'get_first_paid_day';

  l_boundary_date DATE;

BEGIN
  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_absence_attendance_id:'||p_absence_attendance_id);
    debug('p_pl_id:'||p_pl_id);
    debug('p_level_of_pay' || p_level_of_pay);
  END IF;


  l_boundary_date :=
    get_boundary_dates
    (p_absence_attendance_id => p_absence_attendance_id
    ,p_pl_id => p_pl_id
    ,p_first_of_last => 'FIRST'
    ,p_level_of_pay => p_level_of_pay
    );

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;
  RETURN l_boundary_date;


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
END get_first_paid_day;
--
--
--
FUNCTION get_last_paid_day
  (p_absence_attendance_id IN            NUMBER
  ,p_pl_id                 IN            NUMBER
  ,p_level_of_pay          IN            VARCHAR2 DEFAULT NULL
  ) RETURN DATE
IS

  g_debug     BOOLEAN;

    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
                g_package_name||'get_last_paid_day';

  l_boundary_date DATE;

BEGIN
  g_debug := hr_utility.debug_enabled;
   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_absence_attendance_id:'||p_absence_attendance_id);
    debug('p_pl_id:'||p_pl_id);
    debug('p_level_of_pay' || p_level_of_pay);
  END IF;

  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;

  l_boundary_date :=
    get_boundary_dates
    (p_absence_attendance_id => p_absence_attendance_id
    ,p_pl_id => p_pl_id
    ,p_first_of_last => 'LAST'
    ,p_level_of_pay => p_level_of_pay
    );

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;
  RETURN l_boundary_date;


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
END get_last_paid_day;
--
--
--
FUNCTION get_first_entitled_day
  (p_absence_attendance_id IN            NUMBER
  ,p_pl_id                 IN            NUMBER
  ,p_level_of_entitlement  IN            VARCHAR2 DEFAULT NULL
  ) RETURN DATE
IS

  g_debug     BOOLEAN;

    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
                g_package_name||'get_first_entitled_day';

  l_boundary_date DATE;

BEGIN
  g_debug := hr_utility.debug_enabled;
   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_absence_attendance_id:'||p_absence_attendance_id);
    debug('p_pl_id:'||p_pl_id);
    debug('p_level_of_entitlement' || p_level_of_entitlement);
  END IF;

  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;


  l_boundary_date :=
    get_boundary_dates
    (p_absence_attendance_id => p_absence_attendance_id
    ,p_pl_id => p_pl_id
    ,p_first_of_last => 'FIRST'
    ,p_level_of_entitlement => p_level_of_entitlement
    );

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;
  RETURN l_boundary_date;


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
END get_first_entitled_day;
--
--
--
FUNCTION get_last_entitled_day
  (p_absence_attendance_id IN            NUMBER
  ,p_pl_id                 IN            NUMBER
  ,p_level_of_entitlement  IN            VARCHAR2 DEFAULT NULL
  ) RETURN DATE
IS

  g_debug     BOOLEAN;

    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
                g_package_name||'get_last_entitled_day';

  l_boundary_date DATE;

BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_absence_attendance_id:'||p_absence_attendance_id);
    debug('p_pl_id:'||p_pl_id);
    debug('p_level_of_entitlement' || p_level_of_entitlement);
  END IF;

  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;


  l_boundary_date :=
    get_boundary_dates
    (p_absence_attendance_id => p_absence_attendance_id
    ,p_pl_id => p_pl_id
    ,p_first_of_last => 'LAST'
    ,p_level_of_entitlement => p_level_of_entitlement
    );

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;
  RETURN l_boundary_date;


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
END get_last_entitled_day;
--
--
--
PROCEDURE chk_override_entitlements -- AI and AU USER HOOK PROC pqpeihcd.sql
  (p_person_extra_info_id          IN      NUMBER
  ,p_person_id                     IN      NUMBER
  ,p_information_type              IN      VARCHAR2
  ,p_pei_information_category      IN      VARCHAR2
  ,p_pei_information1              IN      VARCHAR2 -- override_start_date
  ,p_pei_information2              IN      VARCHAR2 -- override_end_date
  ,p_pei_information3              IN      VARCHAR2 -- plan id
  ,p_pei_information11             IN      VARCHAR2 -- band1
  ,p_pei_information12             IN      VARCHAR2 -- band2
  ,p_pei_information13             IN      VARCHAR2 -- band3
  ,p_pei_information14             IN      VARCHAR2 -- band4
  )
IS

  CURSOR csr_other_override_rows
    (p_person_id            IN     NUMBER
    ,p_information_type     IN     VARCHAR2
    ,p_person_extra_info_id IN     NUMBER
    ,p_pei_information3     IN     VARCHAR2 -- plan id
    ) IS
  SELECT  pei_information1 override_start_date_txt
         ,pei_information2 override_end_date_txt
         ,pei_information3 pl_id_txt
  FROM    per_people_extra_info pei
  WHERE   pei.person_id = p_person_id
    AND   pei.information_type = p_information_type
    AND   pei.pei_information3 = p_pei_information3 -- fetch rows of same plan
    AND   pei.person_extra_info_id <> p_person_extra_info_id;

  --CURSOR csr_plan_type
  --  (p_pl_id IN NUMBER
  --  ) IS
  --SELECT pl_typ_id
  --FROM   ben_pl_f
  --WHERE  pl_id = p_pl_id
  --  AND  ROWNUM < 2; -- any effective one
  -- cannot reason out date track changes in plan types

  --l_other_override_rows          csr_other_override_rows%ROWTYPE:
  l_override_start_date          DATE;
  l_override_end_date            DATE;
  --l_override_pl_id               ben_pl_f.pl_id%TYPE;
  --l_override_pl_typ_id           ben_pl_f.pl_typ_id%TYPE;

  l_other_override_start_date    DATE;
  l_other_override_end_date      DATE;
  --l_other_override_pl_id         ben_pl_f.pl_id%TYPE;
  --l_other_override_pl_typ_id     ben_pl_f.pl_typ_id%TYPE;

  l_loop_counter           BINARY_INTEGER:= 0;

  l_proc_step              NUMBER(38,10);
  l_proc_name              VARCHAR2(61):=
    g_package_name||'chk_override_entitlements';

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
    --
   g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
     debug_enter(l_proc_name);
     debug('p_person_extra_info_id:'||p_person_extra_info_id);
     debug('p_person_id:'||p_person_id);
   END IF;

-- things to validate
-- the following validations are only required for GAP information type
-- 1. start date and end date are valid, ie end date >= start date
-- explicit format validation not required as this info is comingt thru UI
-- 2. the date range does not overlap with any other existing row


IF p_information_type = 'PQP_GB_GAP_ENTITLEMENT_INFO'
THEN

   l_proc_step := 10;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;
  -- if there are format errors it will bomb out in the next
  -- two statements
  l_override_start_date :=
    fnd_date.canonical_to_date(p_pei_information1);

  l_override_end_date :=
    fnd_date.canonical_to_date(p_pei_information2);

  --l_override_pl_id :=
  --  fnd_number.canonical_to_number(p_pei_information3);

  IF g_debug THEN
    debug('p_pei_information1:'||p_pei_information1);
    debug('p_pei_information2:'||p_pei_information2);
    debug('p_pei_information3:'||p_pei_information3);
  END IF;

  IF l_override_end_date < l_override_start_date
  THEN
    l_proc_step := 15;
    IF g_debug THEN
      debug(l_proc_name, l_proc_step);
    END IF;
    fnd_message.set_name('PQP','PQP_230617_END_GE_START');
    --fnd_message.set_token('START',p_pei_information1);
    --fnd_message.set_token('END',p_pei_information2);
    fnd_message.raise_error;
  END IF;

  l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name, l_proc_step);
  END IF;

  FOR r_other_override_row IN
    csr_other_override_rows      -- fetch
      (p_person_id => p_person_id -- person extra info rows
      ,p_information_type => p_information_type -- of osp override type
      ,p_person_extra_info_id => p_person_extra_info_id -- other rows <> match
      ,p_pei_information3 => p_pei_information3 -- of the same plan
      )
  LOOP
    l_loop_counter:= l_loop_counter + 1;

    l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name, l_proc_step+(l_loop_counter/100000));
    END IF;

    l_other_override_start_date :=
      fnd_date.canonical_to_date(r_other_override_row.override_start_date_txt);

    l_other_override_end_date :=
      fnd_date.canonical_to_date(r_other_override_row.override_end_date_txt);

    --l_other_override_pl_id :=
    --  fnd_number.canonical_to_number(r_other_override_row.pl_id_txt);

    IF ( l_override_start_date                    --     |---------|
           BETWEEN l_other_override_start_date    --     |-------------|
               AND l_other_override_end_date      --         |---------|
       )                                          --               |---|
      OR
       ( l_override_end_date                      --     |---------|
           BETWEEN l_other_override_start_date    -- |-------------|
               AND l_other_override_end_date      -- |-------|
       )                                          -- |---|
      OR
       ( l_other_override_start_date              --     |---------|
           BETWEEN l_override_start_date          -- |-----------------|
               AND l_override_end_date            --   |-------------|
       )                                          --     |---------|
      OR
       ( l_other_override_end_date                --     |---------|
           BETWEEN l_override_start_date          -- |-----------------|
               AND l_override_end_date            --   |-------------|
       )                                          --     |---------|
    THEN
    -- the row currently being inserted or updated overlaps with an existing row
    -- and belongs to the same plan , raise erro
    -- same plan type check -- NOT IMPLEMENTED

      l_proc_step := 25;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step+(l_loop_counter/100000));
      END IF;

      -- check if they are of the same plan type -- NOT IMPLEMENTED
      -- unless the plans are of the same plan type
      -- its ok to have an overlap because the absence types of one
      -- do not contribute to the balance of the other
      -- if they are the same then
      --OPEN csr_plan_type(l_override_pl_id);
      --FETCH csr_plan_type INTO l_override_pl_typ_id;
      --CLOSE csr_plan_type;

      --OPEN csr_plan_type(l_other_override_pl_id);
      --FETCH csr_plan_type INTO l_other_override_pl_typ_id;
      --CLOSE csr_plan_type;

      --IF l_other_override_pl_id = l_override_pl_id
      --THEN
        fnd_message.set_name('PQP','PQP_230010_PLAN_OVRRIDE_OVRLAP');

      --fnd_message.set_token('CURRSTART',p_pei_information1);
      --fnd_message.set_token('CURREND',p_pei_information2);
      --fnd_message.set_token('OTHERSTART',r_other_override_row.override_start_date_txt);
      --fnd_message.set_token('OTHEREND',r_other_override_row.override_end_date_txt);

       -- Changed Tokens to refer to Date in Date Format rather
       -- Canonical Format for Bug : 3110889
        fnd_message.set_token('CURRSTART',l_override_start_date);
        fnd_message.set_token('CURREND',l_override_end_date);
        fnd_message.set_token('OTHERSTART',l_other_override_start_date);
        fnd_message.set_token('OTHEREND',l_other_override_end_date);
        fnd_message.raise_error;
      --END IF;

    END IF;

  END LOOP;

  l_proc_step := 30;
  IF g_debug THEN
    debug(l_proc_name, l_proc_step);
  END IF;

END IF;

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
  END IF;
END chk_override_entitlements;
--
--
--
FUNCTION get_num_of_ssp_qualifying_days
  (p_business_group_id    IN        NUMBER
  ,p_person_id            IN        NUMBER
  ,p_schedule_start_date  IN        DATE
  ,p_schedule_end_date    IN        DATE
  ) RETURN NUMBER
IS


  l_calendar_usages              csr_calendar_usages%ROWTYPE;
  l_hr_scheduler_v_count         BINARY_INTEGER;

  l_num_of_ssp_qualifying_days   NUMBER:= 0;

  l_proc_step                    NUMBER(38,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'get_num_of_ssp_qualifying_days';


BEGIN

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_person_id:'||p_person_id);
    debug('p_schedule_start_date'|| p_schedule_start_date);
    debug('p_schedule_end_date'|| p_schedule_end_date);
  END IF;

  OPEN csr_calendar_usages
    ('PERSON' --2 -- Person Type Usage
    ,p_person_id
    ,p_schedule_start_date);
  FETCH csr_calendar_usages INTO l_calendar_usages;
  IF csr_calendar_usages%NOTFOUND THEN -- person level usage does not exist
    l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
    CLOSE csr_calendar_usages;
    OPEN csr_calendar_usages
     ('ORGANIZATION' --1 -- Business Group Type Usage
     ,p_business_group_id
     ,p_schedule_start_date);
     FETCH csr_calendar_usages INTO l_calendar_usages;
  END IF;
  CLOSE csr_calendar_usages;

 --
 -- if you want to hr_scheduler_v and need to know the number
 -- of days between date1 and date2 , invoke the denormalise
 -- procedure for date1 and date2+1, then count sum(end_date-start_date)
 -- where availablity is QUALIFYING
 --


  hr_calendar_pkg.denormalise_calendar
    (p_purpose_usage_id     => l_calendar_usages.purpose_usage_id
    ,p_primary_key_value    => l_calendar_usages.primary_key_value
    ,p_period_from          => p_schedule_start_date
    ,p_period_to            => p_schedule_end_date + 1
    );

  l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

-- This view is non performant as it has cartesian join on fnd_common_lookups
--  SELECT NVL(SUM(TRUNC(sch.end_date) - TRUNC(sch.start_date)),0)
--  INTO   l_num_of_ssp_qualifying_days
--  FROM   hr_scheduler_v sch
--  WHERE  availability = 'QUALIFYING';
--
-- expanding the hr_scheduler_v view
-- SELECT hr_calendar_pkg.start_date(ROWNUM)
      -- ,TO_CHAR(hr_calendar_pkg.start_date(ROWNUM), 'HH24:MI')
      -- ,hr_calendar_pkg.end_date(ROWNUM)
      -- ,TO_CHAR(hr_calendar_pkg.end_date(ROWNUM), 'HH24:MI')
      -- ,SUBSTR(hr_calendar_pkg.availability_value(ROWNUM), 1, 80)
      -- ,hr_calendar_pkg.schedule_level_value(ROWNUM)
-- FROM   fnd_common_lookups, /* -- NB THE CARTESIAN JOIN IS DELIBERATE!!!!! */
       -- fnd_common_lookups
-- WHERE  ROWNUM <= hr_calendar_pkg.schedule_rowcount
--APPS@hrukps:SQL>desc hr_scheduler_v
 --Name                            Null?    Type
 --------------------------------- -------- ----
 --START_DATE                               DATE
 --START_TIME                               VARCHAR2(5)
 --END_DATE                                 DATE
 --END_TIME                                 VARCHAR2(5)
 --AVAILABILITY                             VARCHAR2(80)
 --SCHEDULE_LEVEL                           NUMBER
--
-- replace above logic with a plsql for loop
-- for 1 to hr_calendar_pkg.schedule_rowcount
-- the view had a cartesian join hence performance problems
  l_hr_scheduler_v_count := hr_calendar_pkg.schedule_rowcount;
  FOR i IN 1..l_hr_scheduler_v_count
  LOOP
    IF hr_calendar_pkg.availability_value(i) = 'QUALIFYING' THEN
      l_num_of_ssp_qualifying_days :=
        l_num_of_ssp_qualifying_days +
        NVL(TRUNC(hr_calendar_pkg.end_date(i)) - TRUNC(hr_calendar_pkg.start_date(i)),0);
    END IF;
  END LOOP;
  -- no date range needed, never use this view without doing the
  -- denormalize first for the require date range

  IF g_debug THEN
    debug('l_num_of_ssp_qualifying_days:'||to_char(l_num_of_ssp_qualifying_days));
    debug_exit(l_proc_name);
  END IF;

  RETURN l_num_of_ssp_qualifying_days;

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
END get_num_of_ssp_qualifying_days;
--
--
--
FUNCTION get_number_of_overlap_ssp_days
  (p_business_group_id         IN        NUMBER
  ,p_person_id                 IN        NUMBER
  ,p_piw_id                    IN        NUMBER
  ,p_withheld_days             IN        NUMBER
  ,p_overlap_range_start_date  IN        DATE
  ,p_overlap_range_end_date    IN        DATE
  ) RETURN NUMBER
IS

    -- pickup only those stoppages which are
    --   |stoppages|
    --   wf       wt
    -- |----range----|   -- completely included in the range
    -- rs           re
    -- |-range-|         -- or partially overlap with the range
    -- rs     re
    --         |-range-| -- or partially overlap with the range
    --         rs     re
    --
    --
    -- OR in other words
    --
    -- do not pickup those stoppages which are
    --     |stoppages|
    --     wf       wt
    --     |--range--|     -- are exactly equal ie no overlap days as they are all withheld
    --       rs   re
    --       |range|       -- or the range is completely included in the stoppage range
    --     |range|
    --         |range|
    --                 rsre
    --                 |rg|-- or do not overlap at all with range
    -- |rg|
    -- rsre

  CURSOR csr_ssp_stoppages
    (p_piw_id IN NUMBER
    ) IS
  SELECT withhold_from
        ,NVL(withhold_to,withhold_from) withhold_to
  FROM   ssp_stoppages
  WHERE  absence_attendance_id = p_piw_id --index confirmed -- need not cache
    AND  override_stoppage = 'N';


  l_number_of_overlap_ssp_days   NUMBER:= 0;
  l_num_of_qualifying_stop_days  NUMBER:= 0;
  l_num_of_range_qualifying_days NUMBER:= 0;
  l_all_range_days_are_withheld  BOOLEAN:= FALSE;

  l_proc_step                    NUMBER(38,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'get_number_of_overlap_ssp_days';


BEGIN

IF g_debug THEN
  debug_enter(l_proc_name);
END IF;

/*
  To get the number of qualfying days between any two dates we need to
  1. know the qual pattern to use
  2. know the start "day" of the qual pattern
  3. know any exceptions marked for that period
  4. know any stoppages marked for that period
*/

/*
  the dates we recieve in this function are the overlap range period
  for that week.

  we are in this function because there was a partial overlap

*/


--IF p_withheld_days > 0 -- there are some stoppages in the week
--THEN
-- there are some stoppages in this week
-- 1. do they overlap with requesed period
-- if so determine the number of qual days in the stoppage period
--
--
-- waiting days bug:
-- when the only stoppages in the system are waiting days then
-- withheld_days is 0 hence we need to check for stoppages for
-- every element entry
-- the reason we cannot do a simple count is because
-- a single waiting day stoppage may be applied for several days
-- the only way to count a stoppage is to take the diff between
-- the end date and the start date (if there is an overlap)
-- and then count the number of qualifying days between them
--
-- this check will need to be done for every partially overlapping
-- partially overlapping entries are likely to occur only once or
-- twice within the "expected" range that get...ssp will be invoked
-- for. hence no particular significance of caching
--
-- the index on ssp_stoppages.absence_attendance_id has now been
-- confirmed.
--
  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  FOR r_ssp_stoppage IN csr_ssp_stoppages(p_piw_id)
  LOOP
    -- the only rows that will be selected
    -- will be the ones which have a partial overlap
    -- or where the stoppage is completely included
    -- in the range (but not equal ones)
    -- so we don't need the following IF NOT check

    l_proc_step := 15;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    IF NOT
       (
         ( p_overlap_range_start_date >= r_ssp_stoppage.withhold_from    -- |withhold|
          AND                                                            -- |--rnge--|
           p_overlap_range_end_date <= r_ssp_stoppage.withhold_to        --   |rnge|
         )
         OR
         ( p_overlap_range_start_date > r_ssp_stoppage.withhold_to    --          |withhold|
          OR                                                          --                     |range|
           p_overlap_range_end_date < r_ssp_stoppage.withhold_from      -- |range|
         )
       )
    THEN

      l_proc_step := 20;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      -- its a partial overlap between the stoppage
      -- and the period for which we are trying to find ssp qual days

      -- determines the number of qual days in this period as this will
      -- be deducted from the total number of qual days for the given range

      IF g_debug THEN
        debug('stoppages_overlap_start_date:'||
          GREATEST(r_ssp_stoppage.withhold_from,p_overlap_range_start_date));
        debug('stoppages_overlap_end_date:'||
          LEAST(r_ssp_stoppage.withhold_to,p_overlap_range_end_date));
        debug('l_num_of_qualifying_stop_days:'||l_num_of_qualifying_stop_days);
      END IF;

      l_num_of_qualifying_stop_days := l_num_of_qualifying_stop_days +
        get_num_of_ssp_qualifying_days
         (p_business_group_id
         ,p_person_id
         ,GREATEST(r_ssp_stoppage.withhold_from,p_overlap_range_start_date)
         ,LEAST(r_ssp_stoppage.withhold_to,p_overlap_range_end_date)
         );

      l_proc_step := 25;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
        debug('l_num_of_qualifying_stop_days:'||l_num_of_qualifying_stop_days);
      END IF;

    ELSE
      -- two possiblities
      -- the stoppage does not overlap with the given period
      -- or the stoppage completely covers the period
      -- if the latter then save on performance by not checking
      -- for number_of_ssp_qual_days as all have been Stoppaged !
      l_proc_step := 30;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

      IF ( p_overlap_range_start_date >= r_ssp_stoppage.withhold_from    -- |withhold|
          AND                                                            -- |--rnge--|
           p_overlap_range_end_date <= r_ssp_stoppage.withhold_to        --   |rnge|
         )
      THEN

        l_proc_step := 35;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
        END IF;
      -- withhold completely covers the range overlap
      -- in which case set a flag so that num of ssp days can be returned
      -- as 0 without any further processing

        l_all_range_days_are_withheld := TRUE;
        EXIT; -- this for loop all days are withheld by this stoppage no need
              -- to examine other stoppages

      --ELSE
      -- there is no overlap, continue with the next stoppage if any

      END IF; -- IF ( p_overlap_range_start_date >= r_ssp_stoppage.withhold_from

    END IF; -- IF NOT

  END LOOP; -- FOR r_ssp_stoppage IN csr_ssp_stoppages(p_piw_id)

  IF csr_ssp_stoppages%ISOPEN THEN
    l_proc_step := 37;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;
    CLOSE csr_ssp_stoppages;
  END IF;


--END IF; -- IF p_withheld_days > 0

l_proc_step := 40;
IF g_debug THEN
  debug(l_proc_name,l_proc_step);
END IF;

IF NOT l_all_range_days_are_withheld -- by default false
THEN

  l_proc_step := 45;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_num_of_qualifying_stop_days:'||l_num_of_qualifying_stop_days);
  END IF;

  l_num_of_range_qualifying_days :=
    get_num_of_ssp_qualifying_days
     (p_business_group_id
     ,p_person_id
     ,p_overlap_range_start_date
     ,p_overlap_range_end_date
     );

  IF g_debug THEN
    debug('l_num_of_range_qualifying_days:'||l_num_of_range_qualifying_days);
  END IF;

  l_number_of_overlap_ssp_days :=
    l_num_of_range_qualifying_days - l_num_of_qualifying_stop_days;

-- ELSE
-- l_number_of_overlap_ssp_days := 0;

  l_proc_step := 50;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

END IF; -- IF NOT l_all_range_days_are_withheld


IF g_debug THEN
  debug('l_number_of_overlap_ssp_days:'||l_number_of_overlap_ssp_days);
  debug_exit(l_proc_name);
END IF;

RETURN l_number_of_overlap_ssp_days;

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
END get_number_of_overlap_ssp_days;
--
--
--
FUNCTION get_ssp_entry_overlap_amount
  (p_business_group_id  IN   NUMBER
  ,p_person_id          IN   NUMBER
  ,p_piw_id             IN   NUMBER
  ,p_ssp_week_entry     IN   csr_ssp_entries%ROWTYPE
  ,p_range_start_date   IN   DATE
  ,p_range_end_date     IN   DATE
  ) RETURN NUMBER
IS

  l_overlap_amount               NUMBER:= 0;
  l_ssp_daily_rate               NUMBER:= 0;
  l_number_of_overlap_ssp_days   NUMBER:= 0;

  l_proc_step                    NUMBER(38,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'get_ssp_entry_overlap_amount';

BEGIN
/*
6. For every determine, determine the extent of overlap with the relevant period range
7. For entries which are completely overlapped add the "amount"
8. For entries which overlap partially, pro-rate based on the relevant qualifying pattern.
9. SSP Daily Rate = Amount / SSP Days Due
10. Amount to include = SSP Daily Rate * Number of Qual days in overlap period
11. Number of qual days in overlap period = Loop thru the days in the element entry
*/

IF g_debug THEN
  debug_enter(l_proc_name);
END IF;


IF NOT
  (   -- if not a complete overlap
    ( p_ssp_week_entry.date_from >= p_range_start_date   --      |range|
     AND                                                 --      |sspwk|
      p_ssp_week_entry.date_to   <= p_range_end_date     --       |swk|
    )                                                    --       df dt
   OR -- or not a complete overlap
    ( p_ssp_week_entry.date_from > p_range_end_date      --         |range| df
     OR                                                  --         rs   re |sspwk|
      p_ssp_week_entry.date_to < p_range_start_date      -- |sspwk|
    )                                                    --      dt
  )
THEN
  -- its a partial overlap

  l_proc_step := 15;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  l_ssp_daily_rate :=
    p_ssp_week_entry.amount /
    ABS(p_ssp_week_entry.ssp_days_due - p_ssp_week_entry.withheld_days);



  --
  -- 37.32 :=
  --   62.20 /
  --   ( 5 - 2 ) -- 5 qual days, 3 days of stoppages of which 2 are qual
  --

  /*
    what do we need to do here ..
    roll thru the overlap period on a daily basis
    determine the number of qualifying days
    and set the overlap amount to number_of_qual_days * l_ssp_daily_rate
  */

  IF g_debug THEN
    debug('partial_overlap_start_date:'||GREATEST(p_range_start_date,p_ssp_week_entry.date_from));
    debug('partial_overlap_end_date:'||LEAST(p_range_end_date,p_ssp_week_entry.date_to));
  END IF;

  l_number_of_overlap_ssp_days :=
    get_number_of_overlap_ssp_days
      (p_business_group_id
      ,p_person_id
      ,p_piw_id
      ,p_ssp_week_entry.withheld_days
      ,GREATEST(p_range_start_date,p_ssp_week_entry.date_from)
      ,LEAST(p_range_end_date,p_ssp_week_entry.date_to)
      );

  l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  l_overlap_amount := l_number_of_overlap_ssp_days * l_ssp_daily_rate;

ELSE
  -- either no overap or the week is completely included in the range
  l_proc_step := 25;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

  IF p_ssp_week_entry.date_from >= p_range_start_date   --      |range|
    AND                                                 --      |sspwk|
     p_ssp_week_entry.date_to   <= p_range_end_date     --       |swk|
  THEN
    -- its a complete overlap
    l_proc_step := 30;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    l_overlap_amount := p_ssp_week_entry.amount;

  --ELSE                                             --        |range|
    -- there is no overlap                           --|sspwk|
                                                     --                |sspwk|
    -- this can occur since for linked absences the entries of the parent
    -- will also be picked up which will have no overlap with range period.

    -- l_overlap_amount := 0;

  END IF; -- IF p_ssp_week_entry.date_from >= p_range_start_date

END IF; -- IF ( p_ssp_week_entry.date_from < p_range_start_date

IF g_debug THEN
  debug('l_overlap_amount:'||l_overlap_amount);
  debug_exit(l_proc_name,l_proc_step);
END IF;

RETURN l_overlap_amount;

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
END get_ssp_entry_overlap_amount;
--
--
--
PROCEDURE get_range_and_absence_ssp
  (p_business_group_id         IN            NUMBER
  ,p_assignment_id             IN            NUMBER
  ,p_absence_attendance_id     IN            NUMBER
  ,p_range_start_date          IN            DATE
  ,p_range_end_date            IN            DATE
  ,p_range_amount                 OUT NOCOPY NUMBER
  ,p_absence_amount               OUT NOCOPY NUMBER
  )
IS

  c_ssp_element_name  CONSTANT
    pay_element_types_f.element_name%TYPE:='Statutory Sick Pay';
  l_ssp_element_type_id          g_ssp_element_type_id%TYPE;
  l_ssp_input_values             g_ssp_input_values%TYPE;
  l_ssp_element_links            g_ssp_element_links%TYPE;

  c_ssp_retro_element_name CONSTANT
    pay_element_types_f.element_name%TYPE:='SSP Corrections';
  l_ssp_retro_element_type_id   g_ssp_retro_element_type_id%TYPE;
  l_ssp_retro_input_values      g_ssp_retro_input_values%TYPE;
  l_ssp_retro_element_links     g_ssp_retro_element_links%TYPE;

  l_max_ssp_period               NUMBER;
  l_primary_assignment_id        per_all_assignments_f.assignment_id%TYPE;
  l_absence                      csr_absence_details%ROWTYPE;
  l_piw_id                       per_absence_attendances.absence_attendance_id%TYPE;
  i                              BINARY_INTEGER:= 0;
  j                              BINARY_INTEGER:= 0;
  l_screen_entry_value           pay_element_entry_values.screen_entry_value%TYPE;
  l_range_start_date             DATE;
  l_range_end_date               DATE;

  l_range_amount                 NUMBER;
  l_absence_amount               NUMBER;
  l_ssp_entry_amount             NUMBER;
  l_proc_step                    NUMBER(38,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'get_range_and_absence_ssp';

BEGIN

IF g_debug THEN
  debug_enter(l_proc_name);
  debug('p_absence_attendance_id:'||p_absence_attendance_id);
  debug('p_business_group_id:'||p_business_group_id);
  debug('p_assignment_id:'||p_assignment_id);
  debug('p_range_start_date:'||p_range_start_date);
  debug('p_range_end_date:'||p_range_end_date);
END IF;

/*
1. Determine Primary assignment -- can we assume the context is ?
2. Determine the absence details and the piw id
   -- the piw id is the absence_attendance_id for unliked absences
   -- or it is the linked_absence_id for the linked absences
3. Determine the constants for Statutory Sick Pay and SSP Corrections element types
   and cache for this business group(caching context)...tho it is very unlikely that
   the same session would be used by two diff business groups.
4. Loop for every link in the bg(use context or derive from per_absences??)
   for the two element types derived in step 3
5. Loop thru SSP element entries(p_assignmen_id, p_link_id, p_piw_id)
6. For every determine, determine the extent of overlap with the relevant period range
7. For entries which are completely overlapped add the "amount"
8. For entries which overlap partially, pro-rate based on the relevant qualifying pattern.
9. SSP Daily Rate = Amount / SSP Days Due
10. Amount to include = SSP Daily Rate * Number of Qual days in overlap period
11. Number of qual days in overlap period = Loop thru the days in the element entry
*/


-- 1. Determine Primary Assignment For now assume p_assignment_id is the one
-- 2. Determine the absence details and piw_id


OPEN  csr_absence_details(p_absence_attendance_id);
FETCH csr_absence_details INTO l_absence;
IF g_debug THEN
  debug('l_absence.business_group_id:'||l_absence.business_group_id);
  debug('p_business_group_id:'||p_business_group_id);
END IF;

IF csr_absence_details%FOUND
  AND
   l_absence.business_group_id = p_business_group_id
THEN

  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name, l_proc_step);
  END IF;

  OPEN csr_absence_primary_assignment(p_absence_attendance_id);
  FETCH csr_absence_primary_assignment INTO l_primary_assignment_id;
  CLOSE csr_absence_primary_assignment;

  IF g_debug THEN
    debug('l_primary_assignment_id:'||l_primary_assignment_id);
    debug('p_assignment_id:'||p_assignment_id);
  END IF;

--  IF l_primary_assignment_id = p_assignment_id
--  THEN
-- commenting the Primary Assignment check as this can be called
-- from any assignment in case of multiple assignments
-- check TAR:4178767.995

    l_proc_step := 12;
    IF g_debug THEN
      debug(l_proc_name, l_proc_step);
    END IF;

    IF l_absence.date_start IS NULL
    THEN
      -- there was a time when for SSP one could only enter the sickness
      -- start and end dates, with the date_start and end being optional
      l_absence.date_start :=
        l_absence.sickness_start_date;
    END IF;

    IF l_absence.date_end IS NULL
    THEN
      -- there was a time when for SSP one could only enter the sickness
      -- start and end dates, with the date_start and end being optional
      -- in addition end dates can be open, default to EOT
      l_absence.date_end :=
        NVL(l_absence.sickness_end_date,hr_api.g_eot);
    END IF;


    IF l_absence.business_group_id <> g_ssp_business_group_id
     OR
       g_ssp_business_group_id IS NULL
     OR
       g_ssp_element_type_id IS NULL
     OR
       g_ssp_retro_element_type_id IS NULL
    THEN

      l_proc_step := 15;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- cache the bg for which this information is relevant
      g_ssp_business_group_id := l_absence.business_group_id;

      OPEN csr_seeded_element_type(c_ssp_element_name);
      FETCH csr_seeded_element_type INTO g_ssp_element_type_id;
      CLOSE csr_seeded_element_type;

      l_proc_step := 20;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- avoid using cache variables directly as parameters
      l_ssp_element_type_id := g_ssp_element_type_id;

      IF g_debug THEN
        debug('l_ssp_element_type_id:'||l_ssp_element_type_id);
      END IF;




      FOR r_input_value IN
        csr_inputvalue_ids
         (l_ssp_element_type_id
         ,l_absence.date_start
         )
      LOOP

        g_ssp_input_values(r_input_value.display_sequence):=
          r_input_value;

        IF g_debug THEN
          debug('r_input_value.display_sequence:'||r_input_value.display_sequence);
          debug('r_input_value.id:'||r_input_value.id);
        END IF;

      END LOOP;

      l_proc_step := 25;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;


      -- loop and fetch the element links also for this bg#
      -- we don't fetch element links based on effective date
      -- as we want all possible links
      i := 0;
      FOR r_element_link IN
        csr_element_links
         (l_ssp_element_type_id
         ,l_absence.business_group_id
         )
      LOOP
        i := i + 1;
        g_ssp_element_links(i) := r_element_link;

        IF g_debug THEN
          debug('g_ssp_element_links(i).id:'||g_ssp_element_links(i).id);
        END IF;

      END LOOP;

      l_proc_step := 30;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      OPEN csr_seeded_element_type(c_ssp_retro_element_name);
      FETCH csr_seeded_element_type INTO g_ssp_retro_element_type_id;
      CLOSE csr_seeded_element_type;

      l_proc_step := 35;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- avoid using cache variables directly as parameters
      l_ssp_retro_element_type_id := g_ssp_retro_element_type_id;

      IF g_debug THEN
        debug('l_ssp_retro_element_type_id:'||l_ssp_retro_element_type_id);
      END IF;

       FOR r_input_value IN
         csr_inputvalue_ids
          (l_ssp_retro_element_type_id
          ,l_absence.date_start
         )
      LOOP

        g_ssp_retro_input_values(r_input_value.display_sequence):=
          r_input_value;

        IF g_debug THEN
          debug('retro r_input_value.display_sequence:'||r_input_value.display_sequence);
          debug('retro r_input_value.id:'||r_input_value.id);
        END IF;

      END LOOP;

      l_proc_step := 40;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- loop and fetch the element links also for this bg
      i := 0;
      FOR r_element_link IN
        csr_element_links
          (l_ssp_retro_element_type_id
          ,l_absence.business_group_id
          )
      LOOP
        i := i + 1;
        g_ssp_retro_element_links(i) := r_element_link;

        IF g_debug THEN
          debug('g_ssp_retro_element_links(i).id:'||g_ssp_retro_element_links(i).id);
        END IF;

      END LOOP;

      l_proc_step := 45;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

    END IF; -- IF l_absence.business_group_id <> g_ssp_business_group_id

    l_ssp_element_type_id := g_ssp_element_type_id;
    l_ssp_input_values := g_ssp_input_values;
    l_ssp_element_links:= g_ssp_element_links;
    l_ssp_retro_element_type_id := g_ssp_retro_element_type_id;
    l_ssp_retro_input_values := g_ssp_retro_input_values;
    l_ssp_retro_element_links := g_ssp_retro_element_links;

    l_piw_id := NVL(l_absence.linked_absence_id,p_absence_attendance_id);

--    IF l_absence.date_end IS NULL -- open ended
--    THEN

      -- the reason we donot cache this is because
      -- this a date effective attribute of SSP
      -- we always need to fetch the value as of this absence

--      OPEN csr_max_ssp_period
--        (l_ssp_element_type_id
--        ,l_absence.date_start
--        );
--      FETCH csr_max_ssp_period INTO l_max_ssp_period;
--      CLOSE csr_max_ssp_period;
--
--      l_absence.date_end := l_absence.date_start+l_max_ssp_period;
--      l_absence.sickness_end_date := l_absence.date_start+l_max_ssp_period;

--        l_absence.date_end := NVL(l_absence.sickness_end_date,hr_api.g_eot);
--
--    END IF;


    l_range_end_date := LEAST(p_range_end_date,l_absence.date_end);

    l_range_start_date := GREATEST(p_range_start_date,l_absence.date_start);

    IF g_debug THEN
     debug('l_range_start_date:'||l_range_start_date);
     debug('l_range_end_date:'||l_range_end_date);
    END IF;

    l_range_amount := 0;
    l_absence_amount := 0;

    l_proc_step := 50;
    IF g_debug THEN
      debug(l_proc_name, l_proc_step);
    END IF;

    -- Process any related Statutory Sick Pay element entries
    i:= l_ssp_element_links.FIRST;
    WHILE i IS NOT NULL
    LOOP

      l_proc_step := 50+i/1000;
      IF g_debug THEN
        debug(l_proc_name, 50+i/1000);
      END IF;

      FOR r_ssp_entry IN
        csr_ssp_entries
         (p_primary_assignment_id     => l_primary_assignment_id
         ,p_element_link_id           => l_ssp_element_links(i).id
         ,p_piw_id                    => l_piw_id
--         ,p_amount_iv_id              => l_ssp_input_values(1).id
--         ,p_ssp_days_due_iv_id        => l_ssp_input_values(2).id
--         ,p_date_from_iv_id           => l_ssp_input_values(3).id
--         ,p_date_to_iv_id             => l_ssp_input_values(4).id
--         ,p_rate_iv_id                => l_ssp_input_values(5).id
--         ,p_withheld_days_iv_id       => l_ssp_input_values(6).id
--         ,p_ssp_weeks_iv_id           => l_ssp_input_values(7).id
--         ,p_qualifying_days_iv_id     => l_ssp_input_values(8).id
         )
      LOOP

        l_proc_step := 55+i/1000;
        IF g_debug THEN
          debug(l_proc_name, 55+i/1000);
          debug('r_ssp_entry.element_entry_id:'||r_ssp_entry.element_entry_id);
          debug('r_ssp_entry.effective_start_date:'||r_ssp_entry.effective_start_date);
          debug('r_ssp_entry.effective_end_date:'||r_ssp_entry.effective_end_date);
        END IF;

        j := l_ssp_input_values.FIRST;
        WHILE j IS NOT NULL
        LOOP

          OPEN get_element_entry_value
            (p_element_entry_id => r_ssp_entry.element_entry_id
            ,p_effective_date   => r_ssp_entry.effective_start_date
            ,p_input_value_id   => l_ssp_input_values(j).id
            );
          FETCH get_element_entry_value INTO l_screen_entry_value;
          CLOSE get_element_entry_value;
          IF j = 1 THEN -- its amount
            r_ssp_entry.amount :=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          IF j = 2 THEN -- its ssp_days_due
            r_ssp_entry.ssp_days_due :=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          IF j = 3 THEN -- its date_from
            r_ssp_entry.date_from:=
              fnd_date.canonical_to_date(l_screen_entry_value);
          END IF;
          IF j = 4 THEN -- its date_to
            r_ssp_entry.date_to:=
              fnd_date.canonical_to_date(l_screen_entry_value);
          END IF;
          IF j = 5 THEN -- its rate
            r_ssp_entry.rate:=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          IF j = 6 THEN -- its withheld_days
            r_ssp_entry.withheld_days:=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          --IF j = 7 THEN -- its ssp_weeks
          --  r_ssp_entry.ssp_weeks:=
          --    fnd_number.canonical_to_number(l_screen_entry_value);
          --END IF;
          IF j = 8 THEN -- its qualifying_days
            r_ssp_entry.qualifying_days:=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          j := l_ssp_input_values.NEXT(j);
        END LOOP;

        l_proc_step := 57+i/1000;
        IF g_debug THEN
          debug(l_proc_name, 57+i/1000);
          debug('r_ssp_entry.date_from:'||r_ssp_entry.date_from);
          debug('r_ssp_entry.date_to:'||r_ssp_entry.date_to);
          debug('r_ssp_entry.amount:'||r_ssp_entry.amount);
          debug('r_ssp_entry.rate:'||r_ssp_entry.rate);
          debug('r_ssp_entry.ssp_days_due:'||r_ssp_entry.ssp_days_due);
          debug('r_ssp_entry.withheld_days:'||r_ssp_entry.withheld_days);
          debug('r_ssp_entry.qualifying_days:'||r_ssp_entry.qualifying_days);
          debug('p_piw_id:'||l_piw_id);
        END IF;

        l_ssp_entry_amount :=
          get_ssp_entry_overlap_amount
            (l_absence.business_group_id
            ,l_absence.person_id
            ,l_piw_id
            ,r_ssp_entry
            ,l_range_start_date
            ,l_range_end_date);
        l_range_amount := l_ssp_entry_amount + l_range_amount;


        IF r_ssp_entry.date_from >= l_absence.date_start
          AND
           r_ssp_entry.date_to <= l_absence.date_end
        THEN
          l_absence_amount := l_absence_amount + r_ssp_entry.amount;
        END IF;

        IF g_debug THEN
          debug('SubTotal:l_range_amount:'||l_range_amount);
          debug('SubTotal:l_absence_amount:'||l_absence_amount);
        END IF;

      END LOOP;

      i:= l_ssp_element_links.NEXT(i);
    END LOOP;


    l_proc_step := 60;
    IF g_debug THEN
      debug(l_proc_name, 60);
    END IF;
    -- Process any related SSP Corrections element entries
    i:= l_ssp_retro_element_links.FIRST;
    WHILE i IS NOT NULL
    LOOP

    l_proc_step := 65+i/1000;
    IF g_debug THEN
      debug(l_proc_name, 65+i/1000);
    END IF;

      FOR r_ssp_entry IN
        csr_ssp_entries
         (p_primary_assignment_id     => l_primary_assignment_id
         ,p_element_link_id           => l_ssp_retro_element_links(i).id
         ,p_piw_id                    => l_piw_id
--         ,p_amount_iv_id              => l_ssp_retro_input_values(1).id
--         ,p_ssp_days_due_iv_id        => l_ssp_retro_input_values(2).id
--         ,p_date_from_iv_id           => l_ssp_retro_input_values(3).id
--         ,p_date_to_iv_id             => l_ssp_retro_input_values(4).id
--         ,p_rate_iv_id                => l_ssp_retro_input_values(5).id
--         ,p_withheld_days_iv_id       => l_ssp_retro_input_values(6).id
--         ,p_ssp_weeks_iv_id           => l_ssp_retro_input_values(7).id
--         ,p_qualifying_days_iv_id     => l_ssp_retro_input_values(8).id
         )
      LOOP

        l_proc_step := 70+i/1000;
        IF g_debug THEN
          debug(l_proc_name, 70+i/1000);
          debug('r_ssp_entry.element_entry_id:'||r_ssp_entry.element_entry_id);
          debug('r_ssp_entry.effective_start_date:'||r_ssp_entry.effective_start_date);
          debug('r_ssp_entry.effective_end_date:'||r_ssp_entry.effective_end_date);
        END IF;

        j := l_ssp_retro_input_values.FIRST;
        WHILE j IS NOT NULL
        LOOP

          OPEN get_element_entry_value
            (p_element_entry_id => r_ssp_entry.element_entry_id
            ,p_effective_date   => r_ssp_entry.effective_start_date
            ,p_input_value_id   => l_ssp_retro_input_values(j).id
            );
          FETCH get_element_entry_value INTO l_screen_entry_value;
          CLOSE get_element_entry_value;
          IF j = 1 THEN -- its amount
            r_ssp_entry.amount :=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          IF j = 2 THEN -- its ssp_days_due
            r_ssp_entry.ssp_days_due :=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          IF j = 3 THEN -- its date_from
            r_ssp_entry.date_from:=
              fnd_date.canonical_to_date(l_screen_entry_value);
          END IF;
          IF j = 4 THEN -- its date_to
            r_ssp_entry.date_to:=
              fnd_date.canonical_to_date(l_screen_entry_value);
          END IF;
          IF j = 5 THEN -- its rate
            r_ssp_entry.rate:=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          IF j = 6 THEN -- its withheld_days
            r_ssp_entry.withheld_days:=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          --IF j = 7 THEN -- its ssp_weeks
          --  r_ssp_entry.ssp_weeks:=
          --    fnd_number.canonical_to_number(l_screen_entry_value);
          --END IF;
          IF j = 8 THEN -- its qualifying_days
            r_ssp_entry.qualifying_days:=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          j := l_ssp_retro_input_values.NEXT(j);
        END LOOP;

        l_proc_step := 75+i/1000;
        IF g_debug THEN
          debug(l_proc_name, 75+i/1000);
          debug('r_ssp_entry.date_from:'||r_ssp_entry.date_from);
          debug('r_ssp_entry.date_to:'||r_ssp_entry.date_to);
          debug('r_ssp_entry.amount:'||r_ssp_entry.amount);
          debug('r_ssp_entry.rate:'||r_ssp_entry.rate);
          debug('r_ssp_entry.ssp_days_due:'||r_ssp_entry.ssp_days_due);
          debug('r_ssp_entry.withheld_days:'||r_ssp_entry.withheld_days);
          debug('r_ssp_entry.qualifying_days:'||r_ssp_entry.qualifying_days);
          debug('p_piw_id:'||l_piw_id);
        END IF;

        l_ssp_entry_amount :=
          get_ssp_entry_overlap_amount
            (l_absence.business_group_id
            ,l_absence.person_id
            ,l_piw_id
            ,r_ssp_entry
            ,l_range_start_date
            ,l_range_end_date);

        l_range_amount := l_ssp_entry_amount + l_range_amount;

        -- the reason we need this range overlap check
        -- for absence totals is because not all element
        -- entries by this fetch will relate to the given
        -- absence id. there may be element entries of
        -- linked parent absence

        IF r_ssp_entry.date_from >= l_absence.date_start
          AND
           r_ssp_entry.date_to <= l_absence.date_end
        THEN
          l_absence_amount := l_absence_amount + r_ssp_entry.amount;
        END IF;

        IF g_debug THEN
          debug('SubTotal:l_range_amount:'||l_range_amount);
          debug('SubTotal:l_absence_amount:'||l_absence_amount);
        END IF;

      END LOOP;

      i:= l_ssp_retro_element_links.NEXT(i);
    END LOOP;-- WHILE i IS NOT NULL -- ssp_retro

--  END IF; -- IF l_primary_assignment_id = p_assignment_id

  l_proc_step := 80;
  IF g_debug THEN
    debug(l_proc_name, l_proc_step);
  END IF;

END IF; -- IF csr_absence_details%FOUND
CLOSE csr_absence_details;

p_range_amount := ROUND(l_range_amount,2);
p_absence_amount := ROUND(l_absence_amount,2);

l_proc_step := 90;
IF g_debug THEN
  debug(l_proc_name, l_proc_step);
  debug('l_range_amount:'||l_range_amount);
  debug('l_absence_amount:'||l_absence_amount);
  debug('p_range_amount:'||p_range_amount);
  debug('p_absence_amount:'||p_absence_amount);
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
END get_range_and_absence_ssp;
--
--
--
FUNCTION get_absence_ssp
  (p_business_group_id         IN       NUMBER
  ,p_assignment_id             IN       NUMBER
  ,p_absence_attendance_id     IN       NUMBER
  ,p_range_start_date          IN       DATE
  ,p_range_end_date            IN       DATE
  ) RETURN NUMBER
IS

  l_range_amount                 NUMBER:=0;
  l_absence_amount               NUMBER:=0;

  l_proc_step                    NUMBER(38,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'get_absence_ssp';

BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_absence_attendance_id:'||p_absence_attendance_id);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_range_start_date:'||p_range_start_date);
    debug('p_range_end_date:'||p_range_end_date);
  END IF;

  get_range_and_absence_ssp
    (p_business_group_id     => p_business_group_id
    ,p_assignment_id         => p_assignment_id
    ,p_absence_attendance_id => p_absence_attendance_id
    ,p_range_start_date      => p_range_start_date
    ,p_range_end_date        => p_range_end_date
    ,p_range_amount          => l_range_amount    -- OUT
    ,p_absence_amount        => l_absence_amount  -- OUT
    );

  l_proc_step := 90;
  IF g_debug THEN
    debug(l_proc_name, l_proc_step);
    debug('l_range_amount:'||to_char(l_range_amount));
    debug('l_absence_amount:'||to_char(l_absence_amount));
    debug_exit(l_proc_name);
  END IF;

  RETURN l_range_amount;

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
END get_absence_ssp;
--
--
--
FUNCTION get_smp_entry_overlap_amount
  (p_smp_week_entry   IN    csr_smp_entries%ROWTYPE
  ,p_range_start_date IN   DATE
  ,p_range_end_date   IN   DATE
  ) RETURN NUMBER
IS

  l_smp_entry_overlap_amount        NUMBER:=0;
  l_number_of_overlap_smp_days      NUMBER:=0;
  l_smp_daily_rate                  NUMBER:=0;
  l_smp_week_start_date             DATE;
  l_smp_week_end_date               DATE;

  l_proc_step        NUMBER(38,10);
  l_proc_name        VARCHAR2(61):=
    g_package_name||'get_smp_entry_overlap_amount';
BEGIN

  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;

  l_smp_week_start_date := p_smp_week_entry.week_commencing;
  l_smp_week_end_date := p_smp_week_entry.week_commencing + 6;

  IF g_debug THEN
    debug('l_smp_week_start_date:'||l_smp_week_start_date);
    debug('l_smp_week_end_date:'||l_smp_week_end_date);
  END IF;

  IF NOT
    (
      ( l_smp_week_start_date >= p_range_start_date
       AND
        l_smp_week_end_date <= p_range_end_date
      )
     OR
      ( l_smp_week_start_date > p_range_end_date
       OR
        l_smp_week_end_date < p_range_start_date
      )
    )
  THEN
  -- its a partial overlap
    l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

  -- at the moment pro-ration on the basis of OMP Pattern
  -- isn't yet supported hence use basic pro-ration by 7 days
  -- ie we find the number of calendar days in the overlap period
  -- we find the daily rate as the SMP amount / 7
  -- set the overlap amount = overlap_cal_days * daily_rate

    l_number_of_overlap_smp_days := -- number of calendar days between
      LEAST(l_smp_week_end_date,p_range_end_date) - -- and
      GREATEST(l_smp_week_start_date,p_range_start_date) + 1;

    l_smp_daily_rate := p_smp_week_entry.amount / 7;

    l_smp_entry_overlap_amount :=
      l_smp_daily_rate * l_number_of_overlap_smp_days;

    l_proc_step := 15;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('l_smp_daily_rate:'||l_smp_daily_rate);
      debug('l_number_of_overlap_smp_days:'||l_number_of_overlap_smp_days);
    END IF;

  ELSE
  -- its either a complete overlap or there is no overlap at all
    l_proc_step := 50;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;


      IF l_smp_week_start_date >= p_range_start_date
        AND
         l_smp_week_end_date <= p_range_end_date
      THEN

        l_proc_step := 55;
        IF g_debug THEN
         debug(l_proc_name,l_proc_step);
        END IF;
      -- the week falls completly within the range add the full amount
        l_smp_entry_overlap_amount := p_smp_week_entry.amount;

      --ELSE
      ---- there is no overlap return 0 as overlap amount
      --l_smp_entry_overlap_amount := 0; -- is default
      END IF;

  END IF; -- IF NOT

  IF g_debug THEN
    debug('l_smp_entry_overlap_amount:'||to_char(l_smp_entry_overlap_amount));

    debug_exit(l_proc_name);
  END IF;

  RETURN l_smp_entry_overlap_amount;

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
END get_smp_entry_overlap_amount;
--
--
--
PROCEDURE get_range_and_absence_smp
  (p_business_group_id         IN       NUMBER
  ,p_assignment_id             IN       NUMBER
  ,p_absence_attendance_id     IN       NUMBER
  ,p_range_start_date          IN       DATE
  ,p_range_end_date            IN       DATE
  ,p_absence_category          IN       VARCHAR2
  ,p_range_amount                 OUT NOCOPY NUMBER
  ,p_absence_amount               OUT NOCOPY NUMBER
  )
IS

  l_range_amount     NUMBER:=0;
  l_absence_amount   NUMBER:=0;

  l_absence                    csr_absence_details%ROWTYPE;
  l_primary_assignment_id      per_all_assignments_f.assignment_id%TYPE;

  c_smp_element_name CONSTANT
    pay_element_types_f.element_name%TYPE:='Statutory Maternity Pay';
  c_sap_element_name CONSTANT
    pay_element_types_f.element_name%TYPE:='Statutory Adoption Pay';
  c_spa_element_name CONSTANT
    pay_element_types_f.element_name%TYPE:='Statutory Paternity Pay Adoption';
  c_spb_element_name CONSTANT
    pay_element_types_f.element_name%TYPE:='Statutory Paternity Pay Birth';

  l_statutory_element_name     pay_element_types_f.element_name%TYPE ;
  l_smp_element_type_id        g_smp_element_type_id%TYPE;
  l_smp_input_values           g_smp_input_values%TYPE;
  l_smp_element_links          g_smp_element_links%TYPE;

  c_smp_retro_element_name CONSTANT
    pay_element_types_f.element_name%TYPE:='SMP Corrections';
  c_sap_retro_element_name CONSTANT
    pay_element_types_f.element_name%TYPE:='SAP Corrections';
  c_spa_retro_element_name CONSTANT
    pay_element_types_f.element_name%TYPE:='SPP Adoption Corrections';
  c_spb_retro_element_name CONSTANT
    pay_element_types_f.element_name%TYPE:='SPP Birth Corrections';

  l_statutory_retro_element_name pay_element_types_f.element_name%TYPE ;
  l_smp_retro_element_type_id  g_smp_retro_element_type_id%TYPE;
  l_smp_retro_input_values     g_smp_retro_input_values%TYPE;
  l_smp_retro_element_links    g_smp_retro_element_links%TYPE;

  l_max_smp_period             NUMBER;
  l_range_start_date           DATE;
  l_range_end_date             DATE;
  l_smp_entry_amount NUMBER:=0;
  i                  BINARY_INTEGER:=0;
  j                              BINARY_INTEGER:= 0;
  l_screen_entry_value           pay_element_entry_values.screen_entry_value%TYPE;
  l_proc_step        NUMBER(38,10);
  l_proc_name        VARCHAR2(61):=
    g_package_name||'get_range_and_absence_smp';

  l_absence_category hr_lookups.lookup_code%TYPE ;

BEGIN

IF g_debug THEN
  debug_enter(l_proc_name);
  debug('p_business_group_id:'||p_business_group_id);
  debug('p_assignment_id:'||p_assignment_id);
  debug('p_absence_attendance_id:'||p_absence_attendance_id);
  debug('p_range_start_date:'||p_range_start_date);
  debug('p_range_end_date:'||p_range_end_date);
  debug('p_absence_category:'||p_absence_category);
END IF;

OPEN  csr_absence_details(p_absence_attendance_id);
FETCH csr_absence_details INTO l_absence;
IF g_debug THEN
  debug('l_absence.business_group_id:'||l_absence.business_group_id);
  debug('p_business_group_id:'||p_business_group_id);
END IF;

IF csr_absence_details%FOUND
  AND
   l_absence.business_group_id = p_business_group_id
THEN

  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name, l_proc_step);
  END IF;

  OPEN csr_absence_primary_assignment(p_absence_attendance_id);
  FETCH csr_absence_primary_assignment INTO l_primary_assignment_id;
  CLOSE csr_absence_primary_assignment;

  IF g_debug THEN
    debug('l_primary_assignment_id:'||l_primary_assignment_id);
    debug('p_assignment_id:'||p_assignment_id);
  END IF;

--  IF l_primary_assignment_id = p_assignment_id
--  THEN
-- commenting the Primary Assignment check as this can be called
-- from any assignment in case of multiple assignments
-- check TAR:4178767.995

    l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name, l_proc_step);
    END IF;

    IF l_absence.date_start IS NULL
    THEN
      l_absence.date_start := l_absence.date_projected_start;
    END IF;

    IF l_absence.date_end IS NULL
    THEN
      l_absence.date_end :=
        NVL(l_absence.date_projected_end,hr_api.g_eot);
    END IF;


    IF l_absence.business_group_id <> g_smp_business_group_id
     OR
       p_absence_category <> g_absence_category
     OR
       g_smp_business_group_id IS NULL
     OR
       g_smp_element_type_id IS NULL
     OR
       g_smp_retro_element_type_id IS NULL
    THEN

      IF g_debug THEN
       debug('l_absence_category:'||l_absence_category);
      END IF;

      IF p_absence_category = 'M' THEN
        l_proc_step := 21;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;
        l_statutory_element_name       := c_smp_element_name ;
        l_statutory_retro_element_name := c_smp_retro_element_name ;

      ELSIF p_absence_category = 'GB_ADO' THEN
        l_proc_step := 22;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;
        l_statutory_element_name       := c_sap_element_name;
        l_statutory_retro_element_name := c_sap_retro_element_name;

      ELSIF p_absence_category = 'GB_PAT_ADO' THEN
        l_proc_step := 23;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;
        l_statutory_element_name       := c_spa_element_name ;
        l_statutory_retro_element_name := c_spa_retro_element_name ;

      ELSIF p_absence_category = 'GB_PAT_BIRTH' THEN
        l_proc_step := 24;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;
        l_statutory_element_name       := c_spb_element_name ;
        l_statutory_retro_element_name := c_spb_retro_element_name ;
      END IF ;

      --assigning the global variable for absence_category
      g_absence_category := p_absence_category;

      l_proc_step := 30;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- cache the bg for which this information is relevant
      g_smp_business_group_id := l_absence.business_group_id;

      OPEN csr_seeded_element_type(l_statutory_element_name);
      FETCH csr_seeded_element_type INTO g_smp_element_type_id;
      CLOSE csr_seeded_element_type;

      l_proc_step := 40;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- avoid using cache variables directly as parameters
      l_smp_element_type_id := g_smp_element_type_id;

      IF g_debug THEN
        debug('l_smp_element_type_id:'||l_smp_element_type_id);
      END IF;

      FOR r_input_value IN
        csr_inputvalue_ids
         (l_smp_element_type_id
         ,l_absence.date_start
         )
      LOOP

        g_smp_input_values(r_input_value.display_sequence):=
          r_input_value;

        IF g_debug THEN
          debug('r_input_value.display_sequence:'||r_input_value.display_sequence);
          debug('r_input_value.id:'||r_input_value.id);
        END IF;

      END LOOP;

      l_proc_step := 45;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- loop and fetch the element links also for this bg#
      -- we don't fetch element links based on effective date
      -- as we want all possible links
      i := 0;
      FOR r_element_link IN
        csr_element_links
         (l_smp_element_type_id
         ,l_absence.business_group_id
         )
      LOOP
        i := i + 1;
        g_smp_element_links(i) := r_element_link;

        IF g_debug THEN
          debug('g_smp_element_links(i).id:'||g_smp_element_links(i).id);
        END IF;

      END LOOP;

      l_proc_step := 50;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      OPEN csr_seeded_element_type(l_statutory_retro_element_name);
      FETCH csr_seeded_element_type INTO g_smp_retro_element_type_id;
      CLOSE csr_seeded_element_type;

      l_proc_step := 55;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- avoid using cache variables directly as parameters
      l_smp_retro_element_type_id := g_smp_retro_element_type_id;

      IF g_debug THEN
        debug('l_smp_retro_element_type_id:'||l_smp_retro_element_type_id);
      END IF;

       FOR r_input_value IN
         csr_inputvalue_ids
          (l_smp_retro_element_type_id
          ,l_absence.date_start
         )
      LOOP

        g_smp_retro_input_values(r_input_value.display_sequence):=
          r_input_value;

        IF g_debug THEN
          debug('retro r_input_value.display_sequence:'||r_input_value.display_sequence);
          debug('retro r_input_value.id:'||r_input_value.id);
        END IF;

      END LOOP;

      l_proc_step := 60;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      -- loop and fetch the element links also for this bg
      i := 0;
      FOR r_element_link IN
        csr_element_links
          (l_smp_retro_element_type_id
          ,l_absence.business_group_id
          )
      LOOP
        i := i + 1;
        g_smp_retro_element_links(i) := r_element_link;

        IF g_debug THEN
          debug('g_smp_retro_element_links(i).id:'||g_smp_retro_element_links(i).id);
        END IF;

      END LOOP;

      l_proc_step := 65;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

    END IF; -- IF l_absence.business_group_id <> g_smp_business_group_id

    l_smp_element_type_id := g_smp_element_type_id;
    l_smp_input_values := g_smp_input_values;
    l_smp_element_links:= g_smp_element_links;
    l_smp_retro_element_type_id := g_smp_retro_element_type_id;
    l_smp_retro_input_values := g_smp_retro_input_values;
    l_smp_retro_element_links := g_smp_retro_element_links;


--    IF l_absence.date_end IS NULL -- open ended
--    THEN
--
      -- the reason we donot cache this is because
      -- this a date effective attribute of SMP
      -- we always need to fetch the value as of this absence
--
--      OPEN csr_max_smp_period
--        (l_smp_element_type_id
--        ,l_absence.date_start
--        );
--      FETCH csr_max_smp_period INTO l_max_smp_period;
--      CLOSE csr_max_smp_period;
--
--      l_absence.date_end := l_absence.date_start+l_max_smp_period;
--
--    END IF;

    l_range_end_date := LEAST(p_range_end_date,l_absence.date_end);
    l_range_start_date := GREATEST(p_range_start_date,l_absence.date_start);

    IF g_debug THEN
     debug('l_range_start_date:'||l_range_start_date);
     debug('l_range_end_date:'||l_range_end_date);
    END IF;

    l_range_amount := 0;
    l_absence_amount := 0;

    -- Process any related Statutory Maternity Pay element entries

    i:= l_smp_element_links.FIRST;
    WHILE i IS NOT NULL
    LOOP

      l_proc_step := 70+i/1000;
      IF g_debug THEN
        debug(l_proc_name, 70+i/1000);
        debug('l_absence.maternity_id:'||l_absence.maternity_id);
      END IF;

      FOR r_smp_entry IN
        csr_smp_entries
          (p_maternity_id             => l_absence.maternity_id
          -- Pass Primary Assignment Id as the SMP element entries
          -- will be created for primary assignment
          ,p_primary_assignment_id    => l_primary_assignment_id
                                        --p_assignment_id
          ,p_element_link_id          => l_smp_element_links(i).id
--          ,p_amount_iv_id             => l_smp_input_values(1).id
--          ,p_week_commencing_iv_id    => l_smp_input_values(2).id
--          ,p_rate_iv_id               => l_smp_input_values(3).id
--          ,p_recoverable_amount_iv_id => l_smp_input_values(4).id
          )
      LOOP

        l_proc_step := 75+i/1000;
        IF g_debug THEN
          debug(l_proc_name, 75+i/1000);
          debug('r_smp_entry.element_entry_id:'||r_smp_entry.element_entry_id);
          debug('r_smp_entry.effective_start_date:'||r_smp_entry.effective_start_date);
          debug('r_smp_entry.effective_end_date:'||r_smp_entry.effective_end_date);
          --debug('r_smp_entry.week_commencing:'||r_smp_entry.week_commencing);
          --debug('r_smp_entry.amount:'||r_smp_entry.amount);
          --debug('r_smp_entry.rate:'||r_smp_entry.rate);
          --debug('r_smp_entry.recoverable_amount:'||r_smp_entry.recoverable_amount);
        END IF;


        j := l_smp_input_values.FIRST;
        WHILE j IS NOT NULL
        LOOP

          OPEN get_element_entry_value
            (p_element_entry_id => r_smp_entry.element_entry_id
            ,p_effective_date   => r_smp_entry.effective_start_date
            ,p_input_value_id   => l_smp_input_values(j).id
            );
          FETCH get_element_entry_value INTO l_screen_entry_value;
          CLOSE get_element_entry_value;
          IF j = 1 THEN -- its amount
            r_smp_entry.amount :=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          IF j = 2 THEN -- its week_commencing
            r_smp_entry.week_commencing :=
              fnd_date.canonical_to_date(l_screen_entry_value);
          END IF;
          --IF j = 3 THEN -- its rate (text)
          --  r_smp_entry.rate :=
          --    l_screen_entry_value;
          --END IF;
          --IF j = 4 THEN -- its recoverable_amount
          --  r_smp_entry.l_smp_retro_input_valuesrecoverable_amount:=
          --    fnd_number.canonical_to_number(l_screen_entry_value);
          --END IF;

          j := l_smp_input_values.NEXT(j);
        END LOOP;

        l_proc_step := 77+i/1000;
        IF g_debug THEN
          debug(l_proc_name, 77+i/1000);
          debug('r_smp_entry.week_commencing:'||r_smp_entry.week_commencing);
          debug('r_smp_entry.amount:'||r_smp_entry.amount);
          --debug('r_smp_entry.rate:'||r_smp_entry.rate);
          --debug('r_smp_entry.recoverable_amount:'||r_smp_entry.recoverable_amount);
        END IF;


        l_smp_entry_amount :=
          get_smp_entry_overlap_amount
            (r_smp_entry
            ,l_range_start_date
            ,l_range_end_date);

        l_range_amount := l_smp_entry_amount + l_range_amount;

        l_absence_amount := r_smp_entry.amount + l_absence_amount;

        IF g_debug THEN
          debug('SubTotal:l_range_amount:'||l_range_amount);
          debug('SubTotal:l_absence_amount:'||l_absence_amount);
        END IF;

    END LOOP;

      i:= l_smp_element_links.NEXT(i);
    END LOOP;


    -- Process any related SMP Corrections element entries
    i:= l_smp_retro_element_links.FIRST;
    WHILE i IS NOT NULL
    LOOP

      l_proc_step := 80+i/1000;
      IF g_debug THEN
        debug(l_proc_name, 80+i/1000);
        debug('l_absence.maternity_id:'||l_absence.maternity_id);
      END IF;

      FOR r_smp_entry IN
        csr_smp_entries
          (p_maternity_id             => l_absence.maternity_id
          ,p_primary_assignment_id    => p_assignment_id
          ,p_element_link_id          => l_smp_retro_element_links(i).id
--          ,p_amount_iv_id             => l_smp_retro_input_values(1).id
--          ,p_week_commencing_iv_id    => l_smp_retro_input_values(2).id
--          ,p_rate_iv_id               => l_smp_retro_input_values(3).id
--          ,p_recoverable_amount_iv_id => l_smp_retro_input_values(4).id
          )
      LOOP

        l_proc_step := 85+i/1000;
        IF g_debug THEN
          debug(l_proc_name, 85+i/1000);
          debug('r_smp_entry.element_entry_id:'||r_smp_entry.element_entry_id);
          debug('r_smp_entry.effective_start_date:'||r_smp_entry.effective_start_date);
          debug('r_smp_entry.effective_end_date:'||r_smp_entry.effective_end_date);
          --debug('r_smp_entry.week_commencing:'||r_smp_entry.week_commencing);
          --debug('r_smp_entry.amount:'||r_smp_entry.amount);
          --debug('r_smp_entry.rate:'||r_smp_entry.rate);
          --debug('r_smp_entry.recoverable_amount:'||r_smp_entry.recoverable_amount);
        END IF;


        j := l_smp_retro_input_values.FIRST;
        WHILE j IS NOT NULL
        LOOP

          OPEN get_element_entry_value
            (p_element_entry_id => r_smp_entry.element_entry_id
            ,p_effective_date   => r_smp_entry.effective_start_date
            ,p_input_value_id   => l_smp_retro_input_values(j).id
            );
          FETCH get_element_entry_value INTO l_screen_entry_value;
          CLOSE get_element_entry_value;
          IF j = 1 THEN -- its amount
            r_smp_entry.amount :=
              fnd_number.canonical_to_number(l_screen_entry_value);
          END IF;
          IF j = 2 THEN -- its week_commencing
            r_smp_entry.week_commencing :=
              fnd_date.canonical_to_date(l_screen_entry_value);
          END IF;
          --IF j = 3 THEN -- its rate (text)
          --  r_smp_entry.rate :=
          --    l_screen_entry_value;
          --END IF;
          --IF j = 4 THEN -- its recoverable_amount
          --  r_smp_entry.l_smp_retro_input_valuesrecoverable_amount:=
          --    fnd_number.canonical_to_number(l_screen_entry_value);
          --END IF;

          j := l_smp_retro_input_values.NEXT(j);
        END LOOP;

        l_proc_step := 87+i/1000;
        IF g_debug THEN
          debug(l_proc_name, 87+i/1000);
          debug('r_smp_entry.week_commencing:'||r_smp_entry.week_commencing);
          debug('r_smp_entry.amount:'||r_smp_entry.amount);
          --debug('r_smp_entry.rate:'||r_smp_entry.rate);
          --debug('r_smp_entry.recoverable_amount:'||r_smp_entry.recoverable_amount);
        END IF;


        l_smp_entry_amount :=
          get_smp_entry_overlap_amount
            (r_smp_entry
            ,l_range_start_date
            ,l_range_end_date);

        l_range_amount := l_smp_entry_amount + l_range_amount;

        l_absence_amount := r_smp_entry.amount + l_absence_amount;

        IF g_debug THEN
          debug('SubTotal:l_range_amount:'||l_range_amount);
          debug('SubTotal:l_absence_amount:'||l_absence_amount);
        END IF;

    END LOOP;

      i:= l_smp_retro_element_links.NEXT(i);
    END LOOP;

   l_proc_step := 90;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

--  END IF; -- IF l_primary_assignment_id = p_assignment_id

END IF; --IF csr_absence_details%FOUND and abs.bg = p_bg
CLOSE csr_absence_details;


p_range_amount := ROUND(l_range_amount,2);
p_absence_amount := ROUND(l_absence_amount,2);

l_proc_step := 100;
IF g_debug THEN
  debug(l_proc_name,l_proc_step);
  debug('l_range_amount:'||l_range_amount);
  debug('l_absence_amount:'||l_absence_amount);
  debug('p_range_amount:'||p_range_amount);
  debug('p_absence_amount:'||p_absence_amount);
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
END get_range_and_absence_smp;
--
--
--
FUNCTION get_absence_smp
  (p_business_group_id         IN       NUMBER
  ,p_assignment_id             IN       NUMBER
  ,p_absence_attendance_id     IN       NUMBER
  ,p_range_start_date          IN       DATE
  ,p_range_end_date            IN       DATE
  ) RETURN NUMBER
IS

  l_range_amount                 NUMBER:=0;
  l_absence_amount               NUMBER:=0;

  l_proc_step                    NUMBER(38,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'get_absence_smp';

BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_absence_attendance_id:'||p_absence_attendance_id);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_range_start_date:'||p_range_start_date);
    debug('p_range_end_date:'||p_range_end_date);
  END IF;

  get_range_and_absence_smp
    (p_business_group_id     => p_business_group_id
    ,p_assignment_id         => p_assignment_id
    ,p_absence_attendance_id => p_absence_attendance_id
    ,p_range_start_date      => p_range_start_date
    ,p_range_end_date        => p_range_end_date
    ,p_absence_category      => 'M' -- Maternity
    ,p_range_amount          => l_range_amount    -- OUT
    ,p_absence_amount        => l_absence_amount  -- OUT
    );

  l_proc_step := 90;
  IF g_debug THEN
    debug(l_proc_name, l_proc_step);
    debug('l_range_amount:'||l_range_amount);
    debug('l_absence_amount:'||l_absence_amount);
    debug_exit(l_proc_name);
  END IF;

  RETURN l_range_amount;

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
END get_absence_smp;
--
--
--
FUNCTION get_period_ssp
  (p_business_group_id         IN       NUMBER -- Context
  ,p_assignment_id             IN       NUMBER -- Context
  ,p_range_start_date          IN       DATE
  ,p_range_end_date            IN       DATE
  ) RETURN NUMBER
IS
BEGIN
  NULL;
END get_period_ssp;
--
--
--
FUNCTION pqp_gb_get_absence_ssp
  (p_business_group_id         IN       NUMBER
  ,p_assignment_id             IN       NUMBER
  ,p_absence_id                IN       NUMBER
  ,p_start_date                IN       DATE
  ,p_end_date                  IN       DATE
  ,p_range_total               OUT NOCOPY NUMBER
  ,p_absence_total             OUT NOCOPY NUMBER
  ,p_error_code                OUT NOCOPY NUMBER
  ,p_error_msg                 OUT NOCOPY VARCHAR2
  ) RETURN NUMBER
IS
  l_proc_step        NUMBER(38,10);
  l_proc_name        VARCHAR2(61):=
    g_package_name||'pqp_gb_get_absence_ssp';

  l_range_total      NUMBER;
  l_absence_total    NUMBER;
  l_absence          csr_absence_details%ROWTYPE;
  --l_absence_assignment_details  csr_absence_primary_assignment%ROWTYPE;

  l_error_code       fnd_new_messages.message_number%TYPE:= 0;
  l_error_msg        fnd_new_messages.message_text%TYPE;

BEGIN

  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;

  p_error_code := 0;
  p_error_msg := NULL;

OPEN  csr_absence_details(p_absence_id);
FETCH csr_absence_details INTO l_absence;
IF csr_absence_details%FOUND
THEN
  CLOSE csr_absence_details;

  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

    get_range_and_absence_ssp
      (p_assignment_id             => p_assignment_id
      ,p_business_group_id         => p_business_group_id
      ,p_absence_attendance_id     => p_absence_id
      ,p_range_start_date          => p_start_date
      ,p_range_end_date            => p_end_date
      ,p_range_amount              => p_range_total
      ,p_absence_amount            => p_absence_total
      );

  l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

--  p_absence_total :=
--    get_absence_ssp
--      (p_assignment_id             => p_assignment_id
--      ,p_business_group_id         => p_business_group_id
--      ,p_absence_attendance_id     => p_absence_id
--      ,p_range_start_date          => NVL(l_absence.date_start
--                                         ,l_absence.sickness_start_date)
--      ,p_range_end_date            => NVL(l_absence.date_end
--                                         ,NVL(l_absence.sickness_end_date
--                                             ,hr_api.g_eot))
--      );


END IF; -- IF csr_absence_details%FOUND
IF csr_absence_details%ISOPEN THEN
  CLOSE csr_absence_details;
END IF;

l_proc_step := 40;
IF g_debug THEN
  debug(l_proc_name,l_proc_step);
  debug('p_range_total:'||p_range_total);
  debug('p_absence_total:'||p_absence_total);
  debug('p_error_code:'||p_error_code);
  debug('p_error_msg:'||p_error_msg);
  debug('l_error_code:'||l_error_code);
  debug_exit(l_proc_name);
END IF;

RETURN l_error_code;

EXCEPTION
  WHEN OTHERS THEN
    p_error_msg := SQLERRM;
    p_error_code := SQLCODE;
    l_error_code := -1;
    clear_cache;
    --IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      --fnd_message.raise_error;

      RETURN l_error_code;
    --ELSE
    --  RAISE;
    --END IF;
END pqp_gb_get_absence_ssp;
--
--
--
FUNCTION pqp_gb_get_absence_smp
  (p_business_group_id         IN       NUMBER
  ,p_assignment_id             IN       NUMBER
  ,p_absence_id                IN       NUMBER
  ,p_start_date                IN       DATE
  ,p_end_date                  IN       DATE
  ,p_range_total               OUT NOCOPY NUMBER
  ,p_absence_total             OUT NOCOPY NUMBER
  ,p_error_code                OUT NOCOPY NUMBER
  ,p_error_msg                 OUT NOCOPY VARCHAR2
  ) RETURN NUMBER
IS

  l_absence          csr_absence_details%ROWTYPE;
  l_error_code       fnd_new_messages.message_number%TYPE:= 0;
  --l_error_msg        fnd_new_messages.message_text%TYPE;


  l_proc_step        NUMBER(38,10);
  l_proc_name        VARCHAR2(61):=
    g_package_name||'pqp_gb_get_absence_smp';

BEGIN

IF g_debug THEN
  debug_enter(l_proc_name);
  debug('p_business_group_id:'||p_business_group_id);
  debug('p_assignment_id:'||p_assignment_id);
  debug('p_absence_id:'||p_absence_id);
  debug('p_start_date:'||p_start_date);
  debug('p_end_date:'||p_end_date);
END IF;

p_error_code := 0;
p_error_msg := NULL;

OPEN  csr_absence_details(p_absence_id);
FETCH csr_absence_details INTO l_absence;
IF csr_absence_details%FOUND
THEN
  CLOSE csr_absence_details;

  l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

--  p_range_total :=
    get_range_and_absence_smp
      (p_assignment_id             => p_assignment_id
      ,p_business_group_id         => p_business_group_id
      ,p_absence_attendance_id     => p_absence_id
      ,p_range_start_date          => p_start_date
      ,p_range_end_date            => p_end_date
      ,p_absence_category          => 'M' -- Maternity
      ,p_range_amount              => p_range_total
      ,p_absence_amount            => p_absence_total
      );

  l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

--  p_absence_total :=
--    get_absence_smp
--      (p_assignment_id             => p_assignment_id
--      ,p_business_group_id         => p_business_group_id
--      ,p_absence_attendance_id     => p_absence_id
--      ,p_range_start_date          => NVL(l_absence.date_start
--                                         ,l_absence.date_projected_start)
--      ,p_range_end_date            => NVL(l_absence.date_end
--                                         ,NVL(l_absence.date_projected_end
--                                             ,hr_api.g_eot))
--      );


END IF; -- IF csr_absence_details%FOUND

IF csr_absence_details%ISOPEN THEN
  CLOSE csr_absence_details;
END IF;

l_proc_step := 40;
IF g_debug THEN
  debug(l_proc_name,l_proc_step);
  debug('p_range_total:'||p_range_total);
  debug('p_absence_total:'||p_absence_total);
  debug('p_error_code:'||p_error_code);
  debug('p_error_msg:'||p_error_msg);
  debug_exit(l_proc_name);
END IF;

RETURN l_error_code;

EXCEPTION
  WHEN OTHERS THEN
    p_error_msg := SQLERRM;
    p_error_code := SQLCODE;
    l_error_code := -1;
    clear_cache;
    --IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      --fnd_message.raise_error;

      RETURN l_error_code;
    --ELSE
    --  RAISE;
    --END IF;
END pqp_gb_get_absence_smp;
--
--
--

-- This function is returns the number of days paid for a employee at a
-- certain pay level. pay level is a input parameter.this returns only
-- for absence types of Sickness and Maternity.


FUNCTION get_absence_paid_days_tp
( p_assignment_id IN NUMBER
,p_start_date IN DATE
,p_end_date IN DATE
,p_level_of_pay IN VARCHAR2
) RETURN NUMBER
IS

CURSOR csr_paid_days_for_this_plan
(p_assigment_id IN NUMBER
,p_plan_id IN NUMBER
,p_level_of_payment IN VARCHAR2
,p_range_start_date IN DATE
,p_range_end_date IN DATE
) IS
SELECT NVL(SUM(gda.duration),0) days
FROM pqp_gap_absence_plans gap
,pqp_gap_daily_absences gda
WHERE gap.assignment_id = p_assignment_id
AND gap.pl_id = p_plan_id
AND gda.gap_absence_plan_id = gap.gap_absence_plan_id
-- commented out due to perf changes
-- AND EXISTS ( SELECT 1
-- FROM pay_element_type_extra_info eei
-- WHERE eei.eei_information30 IN ( 'Sickness','Maternity')
-- AND eei.eei_information1 = gap.pl_id
-- )
AND gda.level_of_pay = p_level_of_payment
AND gda.absence_date
BETWEEN p_range_start_date
AND p_range_end_date

;

CURSOR csr_all_osp_omp_plans IS
SELECT DISTINCT eei.eei_information1
FROM pay_element_type_extra_info eei
WHERE eei.information_type IN -- is indexed
('PQP_GB_OMP_ABSENCE_PLAN_INFO'
,'PQP_GB_OSP_ABSENCE_PLAN_INFO'
)
AND UPPER(eei_information30) IN
('SICKNESS'
,'MATERNITY'
);


CURSOR csr_nopay_days_for_this_plan
(p_assigment_id IN NUMBER
,p_plan_id IN NUMBER
,p_level_of_payment IN VARCHAR2
,p_range_start_date IN DATE
,p_range_end_date IN DATE
) IS
SELECT MAX(ABSENCE_DATE) NB_END_DT, MIN(ABSENCE_DATE) NB_START_DT
FROM pqp_gap_absence_plans gap
,pqp_gap_daily_absences gda
WHERE gap.assignment_id = p_assignment_id
AND gap.pl_id = p_plan_id
AND gda.gap_absence_plan_id = gap.gap_absence_plan_id
AND gda.level_of_pay = p_level_of_payment
AND gda.absence_date
BETWEEN p_range_start_date
AND p_range_end_date
group by gda.gap_absence_plan_id;


rec_nopay_days_for_this_plan csr_nopay_days_for_this_plan%ROWTYPE;
i BINARY_INTEGER:= 0;
l_this_plan_id ben_pl_f.pl_id%TYPE;

l_total_paid_days_of_all_plans NUMBER:= 0;
l_paid_days_for_this_plan NUMBER:= 0;

l_proc_step NUMBER(20,10);
l_proc_name VARCHAR2(61):=
g_package_name||'get_absence_paid_days_tp';

BEGIN

IF g_debug THEN
debug_enter(l_proc_name);
debug('p_assignment_id:'||p_assignment_id);
debug('p_start_date:'||p_start_date);
debug('p_end_date:'||p_end_date);
debug('p_level_of_pay:'||p_level_of_pay);
END IF;

FOR l_an_osp_omp_plan IN csr_all_osp_omp_plans
LOOP

i := i + 1;
l_proc_step := 10+i/10000;
IF g_debug THEN
debug(l_proc_name,10+i/10000);
debug('l_an_osp_omp_plan.eei_information1:'||l_an_osp_omp_plan.eei_information1);
END IF;

l_this_plan_id := TO_NUMBER(l_an_osp_omp_plan.eei_information1);

IF p_level_of_pay = 'NOBAND'
THEN
      OPEN csr_nopay_days_for_this_plan
      (p_assigment_id => p_assignment_id
      ,p_plan_id => l_this_plan_id
      ,p_level_of_payment => p_level_of_pay
      ,p_range_start_date => p_start_date
      ,p_range_end_date => p_end_date
      );
LOOP
      FETCH csr_nopay_days_for_this_plan INTO rec_nopay_days_for_this_plan;
IF csr_nopay_days_for_this_plan%NOTFOUND THEN
      EXIT ;
      END IF;
      l_paid_days_for_this_plan := get_ssp_smp_paid_days (rec_nopay_days_for_this_plan.NB_START_DT,
           rec_nopay_days_for_this_plan.NB_END_DT,
                                             p_assignment_id);
           l_proc_step := 20+i/10000;
      IF g_debug THEN
      debug(l_proc_name,20+i/10000);
      debug('l_paid_days_for_this_plan:'||l_paid_days_for_this_plan);
END IF;

      l_total_paid_days_of_all_plans :=
      l_total_paid_days_of_all_plans
      + l_paid_days_for_this_plan;

END LOOP ;
CLOSE csr_nopay_days_for_this_plan;

ELSE
      OPEN csr_paid_days_for_this_plan
      (p_assigment_id => p_assignment_id
      ,p_plan_id => l_this_plan_id
      ,p_level_of_payment => p_level_of_pay
      ,p_range_start_date => p_start_date
      ,p_range_end_date => p_end_date
      );

FETCH csr_paid_days_for_this_plan INTO l_paid_days_for_this_plan;
IF csr_paid_days_for_this_plan%FOUND
THEN

      l_proc_step := 25+i/10000;
      IF g_debug THEN
debug(l_proc_name,25+i/10000);
debug('l_paid_days_for_this_plan:'||l_paid_days_for_this_plan);
END IF;

      l_total_paid_days_of_all_plans :=
l_total_paid_days_of_all_plans
+ l_paid_days_for_this_plan;

END IF; -- IF csr_paid_days_for_this_plan%FOUND
CLOSE csr_paid_days_for_this_plan;

END IF;



l_proc_step := 30+i/10000;
IF g_debug THEN
debug(l_proc_name,30+i/10000);
debug('l_total_paid_days_of_all_plans:'||l_total_paid_days_of_all_plans);
END IF;

END LOOP; -- FOR l_an_osp_omp_plan IN csr_all_osp_omp_plans

IF g_debug THEN
debug('l_total_paid_days_of_all_plans:'||l_total_paid_days_of_all_plans);
debug_exit(l_proc_name);
END IF;

RETURN l_total_paid_days_of_all_plans;

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
END get_absence_paid_days_tp ;


---- For CS Added

-- This Function gets the scheme Details based on element_type_id available as context
-- and gets the entitlement balance for all bands at one go
FUNCTION get_all_band_cs_4_yr_ent_bal(
               p_business_group_id    IN         NUMBER
              ,p_assignment_id        IN         NUMBER
              ,p_element_type_id      IN         NUMBER
              ,p_effective_date       IN         DATE
              ,p_band1_ent_bal        OUT NOCOPY NUMBER
              ,p_band2_ent_bal        OUT NOCOPY NUMBER
              ,p_band3_ent_bal        OUT NOCOPY NUMBER
              ,p_band4_ent_bal        OUT NOCOPY NUMBER
              ,p_noband_ent_bal       OUT NOCOPY NUMBER
              ,p_error_message        OUT NOCOPY VARCHAR2 )
        RETURN NUMBER IS
    l_error_code       fnd_new_messages.message_number%TYPE:= 0;
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_all_band_cs_4_yr_ent_bal';
    l_retval number ;

BEGIN

    IF g_debug THEN
       debug_enter(l_proc_name);
       debug('p_business_group_id:'||p_business_group_id);
       debug('p_assignment_id:'||p_assignment_id);
       debug('p_element_type_id:'||p_element_type_id);
       debug('p_effective_date:'||p_effective_date);
    END IF ;
    l_proc_step := 10 ;
    p_band1_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND1'
                            ,p_error_code           => l_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'WEEKS'
                            );

    IF l_error_code < 0 THEN
       RETURN -1;
    END IF; -- End if of check for error code ...
    IF g_debug THEN
       debug('BAND1:'||p_band1_ent_bal);
    END IF ;
    l_proc_step := 20 ;
    p_band2_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND2'
                            ,p_error_code           => l_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'WEEKS'
                            );

    IF l_error_code  = -1  THEN
       RETURN -1;
    END IF; -- End if of check for error code ...
    IF g_debug THEN
      debug('BAND2:'||p_band2_ent_bal);
    END IF ;
    l_proc_step := 30 ;
    p_band3_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND3'
                            ,p_error_code           => l_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'WEEKS'
                            );

    IF l_error_code  = -1  THEN
       RETURN -1;
    END IF; -- End if of check for error code ...
    IF g_debug THEN
      debug('BAND3:'||p_band3_ent_bal);
    END IF;
    l_proc_step := 40 ;
    p_band4_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'BAND4'
                            ,p_error_code           => l_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'WEEKS'
                            );

    IF l_error_code  = -1  THEN
       RETURN -1;
    END IF; -- End if of check for error code ...
    IF g_debug THEN
      debug('BAND4:'||p_band4_ent_bal);
    END IF;
    l_proc_step := 50 ;
    p_noband_ent_bal := get_band_ent_bal_by_ele_typ_id
                           ( p_business_group_id    => p_business_group_id
                            ,p_effective_date       => p_effective_date
                            ,p_assignment_id        => p_assignment_id
                            ,p_element_type_id      => p_element_type_id
                            ,p_level_of_entitlement => 'NOBAND'
                            ,p_error_code           => l_error_code
                            ,p_error_message        => p_error_message
                            ,p_days_hours           => 'WEEKS'
                            );

    IF l_error_code = -1 THEN
       RETURN -1;
    END IF; -- End if of check for error code ...
    IF g_debug THEN
       debug('NOBAND:'||p_noband_ent_bal);
    END IF;
    l_proc_step := 60 ;
    debug_exit(l_proc_name);
    RETURN 0;

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

END get_all_band_cs_4_yr_ent_bal ;



-- This Procedure returns a pl/sql table with the defined entitlements
-- in the UDT for the length of service.

 PROCEDURE get_entitlements
   (p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_entitlement_table_id      IN       NUMBER
   ,p_benefits_length_of_service IN      NUMBER
   ,p_band_entitlements         OUT NOCOPY pqp_absval_pkg.t_entitlements
   ,p_entitlement_bands_list_name IN     VARCHAR2 DEFAULT
      'PQP_GAP_ENTITLEMENT_BANDS'
   )
  IS
    l_user_column_id              pay_user_columns.user_column_id%TYPE;
    l_band_ent                    pqp_absval_pkg.t_entitlements;
    l_band_entitlement            NUMBER;
    l_retval                      NUMBER;

    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_entitlements';

     i                             BINARY_INTEGER := 1 ;
    l_entitlement_override_is_set  BOOLEAN:= FALSE;
    l_error_message               fnd_new_messages.message_text%TYPE ;



  BEGIN
    --
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_effective_date:'||p_effective_date);
      debug('p_pl_id:'||p_pl_id);
      debug('p_entitlement_table_id:'||p_entitlement_table_id);
      debug('p_benefits_length_of_service:'||p_benefits_length_of_service);
      debug('p_entitlement_bands_list_name:'||p_entitlement_bands_list_name);

    END IF ;
    --

l_entitlement_override_is_set :=
        get_override_entitlements
        (p_assignment_id                => p_assignment_id
        ,p_business_group_id            => p_business_group_id
        ,p_pl_id                        => p_pl_id
        ,p_effective_date               => p_effective_date
        ,p_band_entitlements            => l_band_ent
        ,p_absence_pay_plan_class       => 'OSP'
        ,p_entitlement_bands_list_name  => p_entitlement_bands_list_name
        );


      l_proc_step := 15;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

   IF NOT l_entitlement_override_is_set THEN

      FOR l_get_lookup_info IN csr_get_lookup_info(
                              p_entitlement_bands_list_name
                              , 'BAND%') LOOP
        l_proc_step := 50;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
          debug('l_column_name:'||l_get_lookup_info.meaning);
        END IF ;

       l_retval :=
            pqp_utilities.pqp_gb_get_table_value_id(
                     p_business_group_id => p_business_group_id
                    ,p_effective_date    => p_effective_date
                    ,p_table_id          => p_entitlement_table_id
                    ,p_column_name       => l_get_lookup_info.meaning
                    ,p_row_name          => p_benefits_length_of_service
                    ,p_value             => l_band_entitlement
                    ,p_error_msg         => l_error_message
                    ) ;

          IF l_retval < 0 THEN

             l_proc_step := 60;
             IF g_debug THEN
               debug(l_proc_name, l_proc_step);
             END IF ;

             check_error_code(l_retval,l_error_message);
          END IF;

          IF g_debug THEN
            debug('Entitlements:'||l_band_entitlement);
          END IF ;

           IF l_band_entitlement IS NOT NULL THEN

              l_proc_step := 90;
              debug(l_proc_name, l_proc_step+i/100);
               -- by checking for NOT NULL
               -- we are ensuring we only store the details of only those
               -- bands which have some information setup even its 0
               -- may even check for 0...
              l_band_ent(i).band        := l_get_lookup_info.lookup_code;
              l_band_ent(i).meaning     := l_get_lookup_info.meaning ;
              l_band_ent(i).entitlement := l_band_entitlement ;

           END IF;

           l_proc_step := 70;
           IF g_debug THEN
            debug(l_proc_name, l_proc_step);
           END IF ;

          i := i + 1 ;

      END LOOP ;

   END IF; -- IF NOT l_entitlement_override_is_set

    l_proc_step := 110;
    debug(l_proc_name, l_proc_step);

    p_band_entitlements := l_band_ent;

    --
    debug_exit(l_proc_name);

  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
        debug_others(l_proc_name,l_proc_step);
        IF g_debug THEN
          debug('Leaving: '||l_proc_name,-999);
        END IF;
        fnd_message.raise_error;
      ELSE
        RAISE;
      END IF;
  END get_entitlements;
--
-- akarmaka made changes

FUNCTION get_minimum_pay_info
   (p_assignment_id              IN       NUMBER
   ,p_business_group_id          IN       NUMBER
   ,p_absence_id                 IN       NUMBER
   ,p_minpay_start_date          OUT NOCOPY DATE
   ,p_minpay_end_date            OUT NOCOPY DATE

   ) RETURN NUMBER
IS

    CURSOR csr_get_minpay_info
    IS
     SELECT  atd.abs_information4  start_date_txt --   minimum pay start day
            ,atd.abs_information5  end_date_txt   --  minimum pay end day
            ,atd.abs_information6  min_pay    --  minimum pay value
      FROM   per_absence_attendances atd, per_all_assignments_f asg
      WHERE  atd.abs_information_category = 'GB_PQP_OSP_OMP_PART_DAYS'
      AND    atd.absence_attendance_id = p_absence_id
      AND    atd.person_id = asg.person_id
      AND    asg.assignment_id = p_assignment_id
      AND    atd.business_group_id = p_business_group_id;


    l_minimum_pay_info  csr_get_minpay_info%ROWTYPE;

    l_minpay_rate NUMBER ;

    l_proc_step             NUMBER(38,10);
    l_proc_name             VARCHAR2(61):=
      g_package_name||'get_minimum_pay_info';

BEGIN

  debug_enter(l_proc_name);
  debug('p_assignment_id:'||to_char(p_assignment_id));
  debug('p_business_group_id'||to_char(p_business_group_id));
   debug('p_absence_id'||to_char(p_absence_id));

  l_proc_step := 10;
  debug(l_proc_name, l_proc_step);

  OPEN csr_get_minpay_info;
  FETCH csr_get_minpay_info INTO l_minimum_pay_info;

  IF csr_get_minpay_info%FOUND THEN

    p_minpay_start_date  :=
            fnd_date.canonical_to_date(l_minimum_pay_info.start_date_txt);
    p_minpay_end_date    :=
       fnd_date.canonical_to_date(l_minimum_pay_info.end_date_txt);
    l_minpay_rate       := l_minimum_pay_info.min_pay ;
  END IF;
  CLOSE csr_get_minpay_info;

  IF g_debug THEN
   debug('p_minpay_start_date: '||to_char(p_minpay_start_date));
   debug('p_minpay_end_date: '||to_char(p_minpay_end_date));
   debug('l_minpay_rate :'||to_char(l_minpay_rate));
  END IF;
  IF g_debug THEN
    l_proc_step := 20;
    debug(l_proc_name, l_proc_step);
  END IF;
  debug_exit(l_proc_name);

  RETURN NVL(l_minpay_rate,0) ;
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
END get_minimum_pay_info ;
----------------------------
FUNCTION get_osp_minimum_pay_rate
       (p_assignment_id     IN  NUMBER
        ,p_business_group_id IN  NUMBER
        ,p_pl_id             IN  NUMBER
        ,p_effective_date    IN  DATE
       ) RETURN NUMBER IS

    l_min_pay_rate      NUMBER;

    l_proc_step             NUMBER(38,10);
    l_proc_name             VARCHAR2(61):=
        g_package_name||'get_osp_minimum_pay_rate';
    l_min_pay_defined BOOLEAN ;

BEGIN

  debug_enter(l_proc_name);
  debug(p_assignment_id);
  debug(p_business_group_id);
  debug(p_pl_id);
  debug(p_effective_date);


    l_proc_step := 10;
    debug(l_proc_name, l_proc_step);
    -- commenting out the call as the called func
    -- definition is changed and is a standalone one
    -- which is called from the formula .
    --we supporting this piece of code for previous
    -- version of OSP payroll formula shipped to customers

   /*
    l_min_pay_defined := get_minimum_pay_info
   (p_assignment_id     => p_assignment_id
   ,p_business_group_id => p_business_group_id
   ,p_pl_id             => p_pl_id
   ,p_effective_date    => p_effective_date
   ,p_rate_per_day      => l_min_pay_rate
   ) ;
   */
  l_proc_step := 20;
  debug(l_proc_name, l_proc_step);

  debug_exit(l_proc_name);

  RETURN NVL(l_min_pay_rate,0) ;

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
END get_osp_minimum_pay_rate ;
---------------------------------
PROCEDURE set_osp_omp_rounding_factors
  (p_pl_id                        IN              NUMBER
  ,p_pt_entitl_rounding_type      OUT NOCOPY      VARCHAR2
  ,p_pt_rounding_precision        OUT NOCOPY      NUMBER
  ,p_ft_entitl_rounding_type      OUT NOCOPY      VARCHAR2
  ,p_ft_rounding_precision        OUT NOCOPY      NUMBER
  )
IS
l_proc_name  VARCHAR2(61):=
                         g_package_name||
                             'set_osp_omp_rounding_factors';
l_proc_step  NUMBER(20,10) ;
l_pt_val varchar2(15);
l_ft_val varchar2(15);
l_enb_prorat varchar2(5);
l_trunc varchar2(10);
l_err varchar2(100);
l_ret_num  NUMBER;

BEGIN
--This function sets the rounding configuration values at plan level.
 --1)Gets coded value for the rounding off from Extra Info EIT for
  -- Part-Timers and FullTimers.
 --2)Passes the coded value to the decode procedure to get the
  -- rounding type and precision.
 --3)Passes on the values to the out parameters.
 --4)Added for precaution...get the entitlement proration
  -- if it is Y and No rounding values is provided then
  -- by default round it to max precision..5 decimal places
 g_debug := hr_utility.debug_enabled;
 IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_pl_id:'||p_pl_id);
 END IF;


--Get Part-Timer rounding config value from EIT in coded form.
  l_ret_num:=
     pqp_gb_osp_functions.pqp_get_plan_extra_info(
     p_pl_id              =>  p_pl_id
    ,p_information_type   =>  'PQP_GB_OSP_ABSENCE_PLAN_INFO'
    ,p_segment_name       =>  'Part Timer Rounding Values'
    ,p_value              =>  l_pt_val
    ,p_truncated_yes_no   =>  l_trunc
    ,p_error_msg          =>  l_err
    );


 IF l_ret_num <> 0 THEN
    pqp_utilities.check_error_code(l_ret_num, l_err);
 END IF;

 l_proc_step := 20;

 IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_pt_val:'||l_pt_val);
    debug('l_trunc:'||l_trunc);
 END IF;

--Get Full-Timer rounding config value from EIT in coded form.
  l_ret_num:=
     pqp_gb_osp_functions.pqp_get_plan_extra_info(
     p_pl_id              =>  p_pl_id
    ,p_information_type   =>  'PQP_GB_OSP_ABSENCE_PLAN_INFO'
    ,p_segment_name       =>  'Full Timer Rounding Values'
    ,p_value              =>  l_ft_val
    ,p_truncated_yes_no   =>  l_trunc
    ,p_error_msg          =>  l_err
    );

 IF l_ret_num <> 0 THEN
    pqp_utilities.check_error_code(l_ret_num, l_err);
 END IF;

 l_proc_step := 30;

 IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_ft_val:'||l_ft_val);
    debug('l_trunc:'||l_trunc);
 END IF;



--Get Enable Proration value from EIT
  l_ret_num:=
     pqp_gb_osp_functions.pqp_get_plan_extra_info(
     p_pl_id              =>  p_pl_id
    ,p_information_type   =>  'PQP_GB_OSP_ABSENCE_PLAN_INFO'
    ,p_segment_name       =>  'Enable Entitlement Proration'
    ,p_value              =>  l_enb_prorat
    ,p_truncated_yes_no   =>  l_trunc
    ,p_error_msg          =>  l_err
    );


 IF l_ret_num <> 0 THEN
    pqp_utilities.check_error_code(l_ret_num, l_err);
 END IF;

 l_proc_step := 35;

 IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('l_enb_prorat:'||l_enb_prorat);
    debug('l_trunc:'||l_trunc);
 END IF;


--Pass the coded value to the decode procedure for part-timers and
--get the return values in to the out parameters.
  pqp_gb_osp_functions.decode_round_config(
     p_code                =>    l_pt_val
    ,p_rounding_type       =>    p_pt_entitl_rounding_type
    ,p_rounding_precision  =>    p_pt_rounding_precision
    ,p_enb_prorat          =>    l_enb_prorat
    );

  l_proc_step := 40;

 IF g_debug THEN
    debug(l_proc_name,l_proc_step);
 END IF;

--Pass the coded value to the decode procedure for full-timers and
--get the return values in to the out parameters.
  pqp_gb_osp_functions.decode_round_config(
     p_code                =>    l_ft_val
    ,p_rounding_type       =>    p_ft_entitl_rounding_type
    ,p_rounding_precision  =>    p_ft_rounding_precision
    ,p_enb_prorat          =>    l_enb_prorat
    );

    l_proc_step :=50;

 IF g_debug THEN
    debug(l_proc_name,l_proc_step);
    debug('p_pt_entitl_rounding_type:'||p_pt_entitl_rounding_type);
    debug('p_pt_rounding_precision:'||p_pt_rounding_precision);
    debug('p_ft_entitl_rounding_type:'||p_ft_entitl_rounding_type);
    debug('p_ft_rounding_precision:'||p_ft_rounding_precision);
 END IF;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END set_osp_omp_rounding_factors;

---------------------------------



-- This function returns a TRUE/FALSE, TRUE indicating that the
-- absence reported belongs to the person. it checks if the
-- absence_id passed and the context assignment_id both belongs
-- to the same person.

FUNCTION chk_absence_belongs_to_person
 ( p_assignment_id         IN NUMBER
  ,p_business_group_id     IN NUMBER
  ,p_absence_attendance_id IN NUMBER
 ) RETURN BOOLEAN
IS

  l_proc_step       NUMBER(38,10);
  l_proc_name       VARCHAR2(61):=
    g_package_name||'chk_absence_belongs_to_person';



  CURSOR csr_absence_person IS
  SELECT abs.person_id
  FROM   per_absence_attendances abs
  WHERE  abs.absence_attendance_id = p_absence_attendance_id
  AND    abs.business_group_id     = p_business_group_id ;

  CURSOR csr_assignment_person IS
  SELECT asg.person_id
  FROM   per_all_assignments_f asg
  WHERE  asg.assignment_id = p_assignment_id
  AND    rownum < 2 ;

  l_abs_person_id      per_absence_attendances.person_id%TYPE ;
  l_asg_person_id      per_all_assignments_f.person_id%TYPE ;

BEGIN

   IF g_debug THEN
     debug_enter(l_proc_name);
     debug('p_business_group_id:'||p_business_group_id);
     debug('p_assignment_id:'||p_assignment_id);
     debug('p_absence_attendance_id:'||p_absence_attendance_id);
   END IF;

   OPEN  csr_absence_person ;
   FETCH csr_absence_person INTO l_abs_person_id ;
   CLOSE csr_absence_person ;

   IF l_abs_person_id IS NOT NULL THEN
        l_proc_step := 15 ;
      IF g_debug THEN
       debug(l_proc_name,l_proc_step);
      END IF ;
     OPEN  csr_assignment_person ;
     FETCH csr_assignment_person INTO l_asg_person_id ;
     CLOSE csr_assignment_person ;
   ELSE
        l_proc_step := 20 ;
       IF g_debug THEN
        debug(l_proc_name,l_proc_step);
       END IF ;
     RETURN FALSE ;
   END IF ;

   IF l_abs_person_id = l_asg_person_id THEN
      l_proc_step := 25 ;
      IF g_debug THEN
       debug(l_proc_name,l_proc_step);
      END IF ;
     RETURN TRUE ;
   ELSE
      l_proc_step := 30 ;
      IF g_debug THEN
       debug(l_proc_name,l_proc_step);
      END IF ;
      RETURN FALSE ;
   END IF ;

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
END chk_absence_belongs_to_person ;


-- This function is called through a Formula Fucntion to
-- calculate the Statutory Pay. Based on the absence this
-- function will calculate SSP/SMP/Paternity/Adoption etc.
-- the core logic to calculate values still remains with the
-- lower level functions get_absence_ssp, get_absence_smp
-- for 'S'ickness category get_absence_ssp is called and for
-- other categories we pass absence_category to get_absence_smp
-- and set the element names there based on category. Remaining
-- logic is same for all Paternity, Adoption categories
-- and Maternity.

FUNCTION get_absence_statutory_pay
  (p_business_group_id         IN       NUMBER
  ,p_assignment_id             IN       NUMBER
  ,p_absence_attendance_id     IN       NUMBER
  ,p_start_date          IN       DATE
  ,p_end_date            IN       DATE
  ) RETURN NUMBER
IS
  l_proc_step       NUMBER(38,10);
  l_proc_name       VARCHAR2(61):=
    g_package_name||'get_absence_statutory_pay';

  l_statutory_amount NUMBER ;
  l_absence_amount   NUMBER ;

  CURSOR csr_absence_details IS
    select abs.person_id, type.absence_category
      from per_absence_attendances abs
          ,per_absence_attendance_types type
     where abs.absence_attendance_type_id = type.absence_attendance_type_id
       and abs.absence_attendance_id = p_absence_attendance_id
       and abs.business_group_id     = p_business_group_id ;

   l_absence_details   csr_absence_details%ROWTYPE ;
   l_absence_belongs_to_person BOOLEAN ;

BEGIN
 IF g_debug THEN
   debug_enter(l_proc_name);
   debug('p_business_group_id:'||p_business_group_id);
   debug('p_assignment_id:'||p_assignment_id);
   debug('p_absence_attendance_id:'||p_absence_attendance_id);
   debug('p_start_date:'||p_start_date);
   debug('p_end_date:'||p_end_date);
 END IF;

-- Check if the absence_id passed belongs to the assignment_id passed through context.
-- if its not the same Return 0.
-- Fetch the person_id, absence_type from the absence.
-- fetch the person_id, business_group_id of the p_assignment_id
-- compare the person_id and business_group_id
-- does_absence_belongs_to_person


    l_absence_belongs_to_person :=
               chk_absence_belongs_to_person
                 (
                  p_assignment_id          => p_assignment_id
                 ,p_business_group_id      => p_business_group_id
                 ,p_absence_attendance_id => p_absence_attendance_id
                 ) ;

  IF l_absence_belongs_to_person THEN

    OPEN  csr_absence_details ;
    FETCH csr_absence_details INTO l_absence_details ;
    CLOSE csr_absence_details ;

    IF g_debug THEN
      debug('Absence Category:'||l_absence_details.absence_category);
    END IF ;

   IF l_absence_details.absence_category = 'S' THEN
      l_proc_step := 10 ;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF ;
      -- call SSP
      get_range_and_absence_ssp
       (p_business_group_id     => p_business_group_id
       ,p_assignment_id         => p_assignment_id
       ,p_absence_attendance_id => p_absence_attendance_id
       ,p_range_start_date      => p_start_date
       ,p_range_end_date        => p_end_date
       ,p_range_amount          => l_statutory_amount
       ,p_absence_amount        => l_absence_amount
       ) ;

  ELSIF l_absence_details.absence_category IN
          ('M','GB_ADO','GB_PAT_ADO','GB_PAT_BIRTH') THEN
       l_proc_step := 20 ;
     IF g_debug THEN
       debug(l_proc_name,l_proc_step);
     END IF ;

      get_range_and_absence_smp
       (p_business_group_id     => p_business_group_id
       ,p_assignment_id         => p_assignment_id
       ,p_absence_attendance_id => p_absence_attendance_id
       ,p_range_start_date      => p_start_date
       ,p_range_end_date        => p_end_date
       ,p_absence_category      => l_absence_details.absence_category
       ,p_range_amount          => l_statutory_amount
       ,p_absence_amount        => l_absence_amount
       ) ;

  END IF ;


   IF g_debug THEN
     debug('l_absence_amount:'||l_absence_amount);
     debug('l_statutory_amount'||l_statutory_amount);
     debug_exit(l_proc_name);
   END IF;

 END IF ; --   IF l_absence_belongs_to_person THEN

  RETURN NVL(l_statutory_amount,0) ;

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
END get_absence_statutory_pay ;

--------------
  PROCEDURE decode_round_config
  (p_code               IN              VARCHAR2
  ,p_rounding_type      OUT NOCOPY      VARCHAR2
  ,p_rounding_precision OUT NOCOPY      NUMBER
  ,p_enb_prorat         IN  VARCHAR2  DEFAULT 'Y'
  )
 IS
l_proc_name  VARCHAR2(61):=
                         g_package_name||
                             'decode_round_config';
l_round_to    VARCHAR(10);
l_round_val_1 VARCHAR2(1);
l_round_val_2 VARCHAR2(10);
l_proc_step   NUMBER;

BEGIN

 g_debug := hr_utility.debug_enabled;
 l_proc_step := 10;
 IF g_debug THEN
    debug_enter(l_proc_name);
    debug(l_proc_name,l_proc_step);
    debug('p_code:'||p_code);
    debug('p_enb_prorat:'||p_enb_prorat);
 END IF;

 IF (p_code IS NULL) OR p_code='NOROUND' THEN
    --Check if proration is enabled but no value for
    --Rounding config is provided.Defualt prcision to
    --5 decimal places...Issue majorly only in QA env.
    --as in the previous patch provided to the QA no value
    --for rounding exist but the customer deliverable patch
    --would always have a value for rounding config if proration
    --is enabled.
    IF(p_enb_prorat='Y') THEN
       l_proc_step := 15;
       IF g_debug THEN
           debug(l_proc_name,l_proc_step);
       END IF;
       p_rounding_type:='ROUNDTO';
       p_rounding_precision:=5;

    ELSE
       l_proc_step := 20;
       IF g_debug THEN
           debug(l_proc_name,l_proc_step);
       END IF;
       p_rounding_type:='NOROUND';
       p_rounding_precision:=0;
    END IF;
 ELSE
    l_proc_step := 25;
    IF g_debug THEN
         debug(l_proc_name,l_proc_step);
    END IF;

    l_round_to:=substr(p_code,2,1);
    l_round_val_1:=substr(p_code,3,1);
    l_round_val_2:=l_round_val_1 || '.' || substr(p_code,4);
    p_rounding_precision:=fnd_number.canonical_to_number(l_round_val_2);

    IF l_round_to='N' THEN
       p_rounding_type:='NEAREST';
    ELSIF l_round_to='U' THEN
       p_rounding_type:='UP';
    ELSIF l_round_to ='P' THEN
       p_rounding_type:='ROUNDTO';
    ELSE
       p_rounding_type:='DOWN';
    END IF;
 END IF;

    l_proc_step := 30;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('p_rounding_type:'||p_rounding_type);
      debug('p_rounding_precision:'||p_rounding_precision);
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

END decode_round_config;

-----------------

FUNCTION  get_all_band_ent_used_and_rem(
     p_business_group_id           IN         NUMBER
    ,p_assignment_id               IN         NUMBER
    ,p_element_type_id             IN         NUMBER
    ,p_date_earned                 IN         DATE
    ,p_effective_date              IN         DATE
    ,p_entitlement_tab_id          IN         NUMBER
    ,p_benefits_length_of_service  IN         NUMBER
    ,p_band1_abs_used               IN         NUMBER
    ,p_band2_abs_used               IN         NUMBER
    ,p_band3_abs_used               IN         NUMBER
    ,p_band4_abs_used               IN         NUMBER
    ,p_override_effective_date     IN            DATE DEFAULT NULL
    ,p_scheme_cal_type             IN VARCHAR2 DEFAULT 'FIXED'
    ,p_band1_ent_used              OUT NOCOPY NUMBER
    ,p_band2_ent_used              OUT NOCOPY NUMBER
    ,p_band3_ent_used              OUT NOCOPY NUMBER
    ,p_band4_ent_used              OUT NOCOPY NUMBER
    ,p_noband_ent_used             OUT NOCOPY NUMBER
    ,p_band1_4year_ent_used        OUT NOCOPY NUMBER
    ,p_band2_4year_ent_used        OUT NOCOPY NUMBER
    ,p_band3_4year_ent_used        OUT NOCOPY NUMBER
    ,p_band4_4year_ent_used        OUT NOCOPY NUMBER
    ,p_noband_4year_ent_used       OUT NOCOPY NUMBER
    ,p_band1_remaining             OUT NOCOPY NUMBER
    ,p_band2_remaining             OUT NOCOPY NUMBER
    ,p_band3_remaining             OUT NOCOPY NUMBER
    ,p_band4_remaining             OUT NOCOPY NUMBER
    ,p_band1_percentage            OUT NOCOPY NUMBER
    ,p_band2_percentage            OUT NOCOPY NUMBER
    ,p_band3_percentage            OUT NOCOPY NUMBER
    ,p_band4_percentage            OUT NOCOPY NUMBER
    ,p_error_msg                   OUT NOCOPY VARCHAR2
    )RETURN NUMBER
     IS
    l_proc_step                   NUMBER(38,10):=0;
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_all_band_entit_remaining';
    l_retval                      NUMBER;
    l_error_code                  NUMBER;
    l_band1_entitlement           NUMBER;
    l_band1_percentage            NUMBER;
    l_band2_entitlement           NUMBER;
    l_band2_percentage            NUMBER;
    l_band3_entitlement           NUMBER;
    l_band3_percentage            NUMBER;
    l_band4_entitlement           NUMBER;
    l_band4_percentage            NUMBER;
    l_abs_precision               NUMBER;
    l_error_msg                   VARCHAR2(250);



  BEGIN

  --hr_utility.trace_on(null,'rvishwan');
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_business_group_id:'||p_business_group_id);
      debug('p_assignment_id:'||p_assignment_id);
      debug('p_element_type_id:'||p_element_type_id);
      debug('p_effective_date' || p_effective_date);
      debug('p_entitlement_tab_id:'||p_entitlement_tab_id);
      debug('p_benefits_length_of_service:'||p_benefits_length_of_service);
      debug('p_band1_abs_used:'||p_band1_abs_used);
      debug('p_band2_abs_used:'||p_band2_abs_used);
      debug('p_band3_abs_used:'||p_band3_abs_used);
      debug('p_band4_abs_used:'||p_band4_abs_used);
      debug('p_override_effective_date' || p_override_effective_date);
      debug('p_scheme_cal_type'|| p_scheme_cal_type);
   END IF;


    l_abs_precision :=
       PQP_UTILITIES.pqp_get_config_value(
                 p_business_group_id     => p_business_group_id
                ,p_legislation_code     => 'GB'
                ,p_column_name          => 'PCV_INFORMATION7'
                ,p_information_category => 'PQP_GB_OSP_OMP_CONFIG'
                );

    -- assign the rounding precision to global variable.
    -- if null then asssign rounding precision to be 5
    -- so by default absemces taken would be rounded to 5 places.
    g_abs_rounding_precision :=
                    FND_NUMBER.canonical_to_number(NVL(l_abs_precision,5));

    IF g_debug THEN
      debug('g_abs_rounding_precision');
      debug(g_abs_rounding_precision);
    END IF;

    IF g_debug THEN
      debug(l_proc_name,20);
    END IF;


    IF p_scheme_cal_type = 'DUALROLLING'
    THEN

    IF g_debug THEN
      debug(l_proc_name,25);
    END IF;

    l_retval := get_all_band_cs_4_yr_ent_bal
               (p_business_group_id   =>    p_business_group_id
               ,p_assignment_id       =>    p_assignment_id
               ,p_element_type_id     =>    p_element_type_id
               ,p_effective_date      =>    p_effective_date
               ,p_band1_ent_bal       =>    p_band1_4year_ent_used
               ,p_band2_ent_bal       =>    p_band2_4year_ent_used
               ,p_band3_ent_bal       =>    p_band3_4year_ent_used
               ,p_band4_ent_bal       =>    p_band4_4year_ent_used
               ,p_noband_ent_bal      =>    p_noband_4year_ent_used
               ,p_error_message       =>    p_error_msg
               );

    END IF;

    IF g_debug THEN
      debug(l_proc_name,30);
    END IF;

    l_retval := get_all_band_ent_balance
               (p_business_group_id   =>    p_business_group_id
               ,p_assignment_id       =>    p_assignment_id
               ,p_element_type_id     =>    p_element_type_id
               ,p_effective_date      =>    p_effective_date
               ,p_band1_ent_bal       =>    p_band1_ent_used
               ,p_band2_ent_bal       =>    p_band2_ent_used
               ,p_band3_ent_bal       =>    p_band3_ent_used
               ,p_band4_ent_bal       =>    p_band4_ent_used
               ,p_noband_ent_bal      =>    p_noband_ent_used
               ,p_error_code          =>    l_error_code
               ,p_error_message       =>    p_error_msg
	       ,p_absence_start_date  =>    p_override_effective_date
               );


   IF l_retval  = -1  THEN
       RETURN -1;
   END IF; -- End if of check for error code

    IF g_debug THEN
      debug(l_proc_name,40);
    END IF;

   l_retval := pqp_get_band_ent_value
              (p_business_group_id   =>    p_business_group_id
              ,p_effective_date       =>    p_date_earned
              ,p_assignment_id        =>    p_assignment_id
              ,p_element_type_id      =>    p_element_type_id
              ,p_entitlement_tab_id   =>    p_entitlement_tab_id
              ,p_benefits_length_of_service => p_benefits_length_of_service
              ,p_band1_entitlement    =>    l_band1_entitlement
              ,p_band1_percentage     =>    p_band1_percentage
              ,p_band2_entitlement    =>    l_band2_entitlement
              ,p_band2_percentage     =>    p_band2_percentage
              ,p_band3_entitlement    =>    l_band3_entitlement
              ,p_band3_percentage     =>    p_band3_percentage
              ,p_band4_entitlement    =>    l_band4_entitlement
              ,p_band4_percentage     =>    p_band4_percentage
              ,p_error_msg            =>    p_error_msg
              ,p_override_effective_date   =>  p_override_effective_date
              );


   IF l_retval  = -1  THEN
       RETURN -1;
   END IF; -- End if of check for error code

    IF g_debug THEN
      debug(l_proc_name,50);
    END IF;

    p_band1_remaining   := l_band1_entitlement - p_band1_ent_used;
    p_band2_remaining   := l_band2_entitlement - p_band2_ent_used;
    p_band3_remaining   := l_band3_entitlement - p_band3_ent_used;
    p_band4_remaining   := l_band4_entitlement - p_band4_ent_used;

   IF p_scheme_cal_type <> 'DUALROLLING' THEN

     IF g_debug THEN
      debug(l_proc_name,55);
     END IF;

      p_band1_remaining   :=   p_band1_remaining - p_band1_abs_used ;
      p_band2_remaining   :=   p_band2_remaining - p_band2_abs_used ;
      p_band3_remaining   :=   p_band3_remaining - p_band3_abs_used ;
      p_band4_remaining   :=   p_band4_remaining - p_band4_abs_used ;
      p_band1_ent_used    :=   p_band1_ent_used  + p_band1_abs_used ;
      p_band2_ent_used    :=   p_band2_ent_used  + p_band2_abs_used ;
      p_band3_ent_used    :=   p_band3_ent_used  + p_band3_abs_used ;
      p_band4_ent_used    :=   p_band4_ent_used  + p_band4_abs_used ;


  END IF;


--Round Absence remaining figures

    p_band1_remaining := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band1_remaining
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;

    p_band2_remaining := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band2_remaining
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;


    p_band3_remaining := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band3_remaining
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;

    p_band4_remaining := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band4_remaining
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;

    IF g_debug THEN
      debug(l_proc_name,60);
    END IF;

--Round Absence Used One year figures

    p_band1_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band1_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;

    p_band2_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band2_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;


    p_band3_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band3_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;

    p_band4_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band4_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;

    p_noband_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_noband_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;


--Round Absence Used Four years figures
IF p_scheme_cal_type = 'DUALROLLING'
THEN

    IF g_debug THEN
      debug(l_proc_name,65);
    END IF;

    p_band1_4year_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band1_4year_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;

    p_band2_4year_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band2_4year_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;


    p_band3_4year_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band3_4year_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;

    p_band4_4year_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_band4_4year_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;
    p_noband_4year_ent_used := pqp_utilities.round_value_up_down
                (p_value_to_round  => p_noband_4year_ent_used
                ,p_base_value      => g_abs_rounding_precision
                ,p_rounding_type   => g_abs_rounding_type
                ) ;

END IF;

 IF g_debug THEN
    debug('p_band1_ent_used:'||p_band1_ent_used);
    debug('p_band2_ent_used:'||p_band2_ent_used);
    debug('p_band3_ent_used:'||p_band3_ent_used);
    debug('p_band4_ent_used:'||p_band4_ent_used);
    debug('p_noband_ent_used:'||p_noband_ent_used);
    debug('p_band1_4year_ent_used:'||p_band1_4year_ent_used);
    debug('p_band2_4year_ent_used:'||p_band2_4year_ent_used);
    debug('p_band3_4year_ent_used:'||p_band3_4year_ent_used);
    debug('p_band4_4year_ent_used:'||p_band4_4year_ent_used);
    debug('p_noband_4year_ent_used:'||p_noband_4year_ent_used);
    debug('p_band1_remaining:'||p_band1_remaining);
    debug('p_band2_remaining:'||p_band2_remaining);
    debug('p_band3_remaining:'||p_band3_remaining);
    debug('p_band4_remaining:'||p_band4_remaining);
    debug_exit(l_proc_name);
 END IF;

     RETURN 0;

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
  END get_all_band_ent_used_and_rem;

------------------

---------------
PROCEDURE abs_pension_date_chk( p_date_start             IN DATE
                                 ,p_date_end               IN DATE
				 ,p_absence_attendance_id  IN NUMBER
                                 ,p_abs_information4       IN VARCHAR2
                                 ,p_abs_information5       IN VARCHAR2
                                 ,p_abs_information6       IN VARCHAR2
																 -- bug 5975119
                                 ,p_abs_information_category IN VARCHAR2 default null
                                 )
 IS

 l_proc_step                   NUMBER(38,10):=0;
 l_proc_name                   VARCHAR2(61):=
      g_package_name||'abs_pension_date_check';

 l_is_check_true           VARCHAR2(2):='Y';
 l_is_rate_true            VARCHAR2(2):='Y';
 l_pension_st_dt           DATE DEFAULT NULL;
 l_pension_end_dt          DATE DEFAULT NULL ;
 l_pension_rt              NUMBER DEFAULT NULL;
 l_abs_id                  NUMBER;
 l_date_end                DATE;


 BEGIN


g_debug := hr_utility.debug_enabled;

 IF g_debug THEN
      debug_enter(l_proc_name);
      debug(l_proc_name,10);
      debug('p_date_start'||p_date_start);
      debug('p_date_end'||p_date_end);
      debug('p_abs_information4'||p_abs_information4);
      debug('p_abs_information5'||p_abs_information5);
      debug('p_abs_information6'||p_abs_information6);
      debug('p_absence_attendance_id',p_absence_attendance_id);
      debug('p_abs_information_category ' || p_abs_information_category);
      debug('l_is_check_true'||l_is_check_true);
      debug('l_is_rate_true'||l_is_rate_true);

 END IF;

-- bug 5975119
IF p_abs_information_category = 'GB_PQP_OSP_OMP_PART_DAYS' THEN
 -- absence end date can be null incase of open end date absence
 -- so defaulting it to '31-dec-4712'

 l_date_end := NVL(p_date_end,to_date('4712/12/31','YYYY/MM/DD')) ;


 IF g_debug THEN
      debug('l_date_end'||l_date_end);
      debug(l_proc_name,15);
 END IF;

IF (p_abs_information4 <> hr_api.g_varchar2)
THEN
	l_pension_st_dt := fnd_date.canonical_to_date(p_abs_information4);
END IF;

IF g_debug THEN
   debug(l_proc_name,25);
END IF;


IF (p_abs_information5 <> hr_api.g_varchar2)
THEN
	l_pension_end_dt := fnd_date.canonical_to_date(p_abs_information5);
END IF;

IF g_debug THEN
   debug(l_proc_name,35);
END IF;


IF  (p_abs_information6 <> hr_api.g_varchar2)
THEN
	l_pension_rt := fnd_number.canonical_to_number(p_abs_information6);
END IF;

IF g_debug THEN
   debug(l_proc_name,40);
END IF;


 IF g_debug THEN
   debug('l_pension_st_dt'||l_pension_st_dt);
   debug('l_pension_end_dt'||l_pension_end_dt);
   debug('l_pension_rt',l_pension_rt);
  END IF;



IF (l_pension_end_dt IS NOT NULL OR l_pension_st_dt IS NOT NULL) AND
   (l_pension_end_dt IS NULL OR l_pension_st_dt IS NULL)
THEN
       hr_utility.set_message(8303,'PQP_230462_ABS_PENSION_DATE');
       hr_utility.raise_error;
END IF;

IF g_debug THEN
   debug(l_proc_name,45);
END IF;


 IF l_pension_end_dt IS NOT NULL THEN

   IF g_debug THEN
   debug(l_proc_name,50);
   END IF;

   IF (l_pension_end_dt NOT BETWEEN p_date_start AND l_date_end)
   THEN
       hr_utility.set_message(8303,'PQP_230462_ABS_PENSION_DATE');
       hr_utility.raise_error;

	IF g_debug THEN
	   debug(l_proc_name,60);
	   debug('l_is_check_true'||l_is_check_true);
	END IF;
    END IF;
END IF;


 IF g_debug THEN
      debug(l_proc_name,65);
  END IF;

 IF  l_pension_st_dt IS NOT NULL
 AND(l_pension_st_dt NOT BETWEEN p_date_start AND l_date_end)
 THEN
      hr_utility.set_message(8303,'PQP_230462_ABS_PENSION_DATE');
      hr_utility.raise_error;
      IF g_debug THEN
        debug(l_proc_name,70);
        debug('l_is_check_true'||l_is_check_true);
      END IF;
 END IF;

  IF g_debug THEN
      debug(l_proc_name,75);
  END IF;

 IF l_pension_st_dt IS NOT NULL AND l_pension_end_dt IS NOT NULL THEN
    IF l_pension_st_dt > l_pension_end_dt THEN
        hr_utility.set_message(8303,'PQP_230463_ABS_PENSION_RATE');
        hr_utility.raise_error;
    END IF;
 END IF;

  IF g_debug THEN
      debug(l_proc_name,80);
  END IF;

 IF ( (l_pension_rt IS NOT NULL AND l_pension_rt < 0)
    OR
      ( l_pension_rt IS NULL  AND(( l_pension_st_dt IS NOT NULL OR l_pension_end_dt is NOT NULL ) ) )
      )

 THEN
   hr_utility.set_message(8303,'PQP_230463_ABS_PENSION_RATE');
   hr_utility.raise_error;
 END IF;

  IF g_debug THEN
      debug(l_proc_name,85);
  END IF;

END IF; -- checking abs_information_category
 IF g_debug THEN
     debug_exit(l_proc_name);
 END IF;

 EXCEPTION
    WHEN OTHERS THEN

      IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
         IF g_debug THEN
          debug('Leaving: '||l_proc_name,-999);
         END IF;
         hr_utility.raise_error;
      ELSE
        RAISE;
      END IF;


 END abs_pension_date_chk;

/*
  Overloaded function with the old leg hook call signature to avoid invalid
  user hook package while installation.The procedure has been nulled out
  and exist only for defention purpose.
*/

PROCEDURE abs_pension_date_check( p_date_start          IN DATE
                                 ,p_date_end            IN DATE
	                         ,p_abs_information4    IN VARCHAR2
	   	                 ,p_abs_information5    IN VARCHAR2
			         ,p_abs_information6    IN VARCHAR2
				 )

 IS

  l_proc_name                   VARCHAR2(61):=
      g_package_name||'abs_pension_date_check--2';


 BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
    --
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;
    --
  END IF;

 EXCEPTION
    WHEN OTHERS THEN


      IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
         IF g_debug THEN
          debug('Leaving: '||l_proc_name,-999);
         END IF;
         hr_utility.raise_error;
      ELSE
        RAISE;
      END IF;


 END abs_pension_date_check;


FUNCTION get_ssp_smp_paid_days (
p_range_start_date IN DATE,
p_range_end_date IN DATE,
p_assignment_id IN NUMBER) RETURN NUMBER
IS

c_date date:= p_range_start_date;
i NUMBER ;
SSP_No_Paid_Days NUMBER :=0;
l_person_id number;
l_proc_name VARCHAR2(61):=
g_package_name||'get_ssp_smp_paid_days';


Cursor cur_no_paid_days(p_date date) IS
select 1 from SSP_SMP_ENTRIES_V a1 , per_absence_attendances b1
where a1.person_id = b1.person_id and a1.person_id = l_person_id
and c_date between date_from and least(nvl(date_end, date_to), date_to)
union
(select 1 from SSP_SSP_ENTRIES_V where     person_id = l_person_id
and c_date between date_from and date_to
MINUS
SELECT 1 FROM ssp_stoppages_v x, per_absence_attendances y
WHERE X.absence_attendance_id = y.absence_attendance_id AND y.person_id = l_person_id
AND c_date BETWEEN withhold_from AND withhold_to
-- added for Bug 7304886
-- The Work-Off days falling in between Waiting days should NOT be
-- counted under paid days, even the date fall in SPP Paid Week.
MINUS
select 1 from
   (SELECT min(withhold_from) min_withhold_from
        , max(withhold_to) max_withhold_to
        , X.absence_attendance_id
    FROM ssp_stoppages_v x, per_absence_attendances y
    WHERE X.absence_attendance_id = y.absence_attendance_id
      AND y.person_id = l_person_id
      AND x.reason = 'Waiting day'
    GROUP BY X.absence_attendance_id
    )
  where c_date between min_withhold_from and max_withhold_to
)
-- addition for Bug 7304886 ends
union
select 1 from SSP_SAP_ENTRIES_V a2 , per_absence_attendances b2
where a2.person_id = b2.person_id and a2.person_id = l_person_id
and c_date between date_from and least(nvl(date_end, date_to), date_to )
union
select 1 from SSP_SPPA_ENTRIES_V a3 , per_absence_attendances b3
where a3.person_id = b3.person_id and a3.person_id = l_person_id
and c_date between date_from and least(nvl(date_end, date_to), date_to );

CURSOR cur_person_id is
SELECT person_id FROM per_all_assignments_f WHERE assignment_id = p_assignment_id;

BEGIN
IF g_debug THEN
debug_enter(l_proc_name);
debug('p_assignment_id: '||p_assignment_id);
debug('NOBAND Start Date: '|| p_range_start_date);
debug('NOBAND End Date: '|| p_range_end_date);
END IF;

OPEN cur_person_id;
FETCH cur_person_id INTO l_person_id;
CLOSE cur_person_id;


LOOP
OPEN cur_no_paid_days(c_date);
FETCH cur_no_paid_days into i;
IF cur_no_paid_days%notfound then
SSP_No_Paid_Days := SSP_No_Paid_Days +1;
END IF;
CLOSE cur_no_paid_days;
c_date := c_date+1;

if c_date > p_range_end_date then
EXIT;
END IF;
END LOOP;
IF g_debug THEN
debug('Statutary No paid days : '|| SSP_No_Paid_Days);
END IF;

RETURN SSP_No_Paid_Days;
EXCEPTION
WHEN OTHERS THEN
clear_cache;
/* IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
debug_others(l_proc_name,l_proc_step);*/
IF g_debug THEN
debug('Leaving: '||l_proc_name,-999);
END IF;
/* fnd_message.raise_error;
ELSE*/
RAISE;
-- END IF;
END get_ssp_smp_paid_days;


END pqp_gb_osp_functions;

/
