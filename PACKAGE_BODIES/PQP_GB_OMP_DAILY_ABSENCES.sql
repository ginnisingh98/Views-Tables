--------------------------------------------------------
--  DDL for Package Body PQP_GB_OMP_DAILY_ABSENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_OMP_DAILY_ABSENCES" AS
/* $Header: pqgbdomp.pkb 120.3.12010000.2 2009/01/05 10:57:57 vaibgupt ship $ */
-----------------

        e_novalue        EXCEPTION;
-----------------

    g_nested_level     NUMBER:= 0;
    g_package_name     VARCHAR2(31) := 'pqp_gb_omp_daily_absences.' ;
    g_pl_id            ben_pl_f.pl_typ_id%TYPE;
    g_plan_information rec_plan_information ;
    g_debug            BOOLEAN ;
    g_log_duration_summary   VARCHAR2(20) := NULL;

  PROCEDURE debug
    (p_trace_message  IN     VARCHAR2
    ,p_trace_location IN     NUMBER
    )
  IS
  BEGIN
    pqp_utilities.debug(p_trace_message,p_trace_location);
  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_number   IN     NUMBER )
  IS
  BEGIN
      debug(fnd_number.number_to_canonical(p_trace_number));
  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_date     IN     DATE )
  IS
  BEGIN
      debug(fnd_date.date_to_canonical(p_trace_date));
  END debug;
--
--
--
  PROCEDURE debug_enter
    (p_proc_name IN VARCHAR2
    ,p_trace_on  IN VARCHAR2
    )
  IS
--     l_trace_options    VARCHAR2(200);
  BEGIN
    pqp_utilities.debug_enter(p_proc_name,p_trace_on);
  END debug_enter;
--
--
--
  PROCEDURE debug_exit
    (p_proc_name IN VARCHAR2
    ,p_trace_off IN VARCHAR2
    )
  IS
  BEGIN
    pqp_utilities.debug_exit(p_proc_name,p_trace_off);
  END debug_exit;

--
  PROCEDURE debug_others
    (p_proc_name        IN VARCHAR2
    ,p_last_step_number IN NUMBER   DEFAULT NULL
    )
  IS
    l_message  fnd_new_messages.message_text%TYPE;
  BEGIN
      IF g_debug THEN
        debug(p_proc_name,SQLCODE);
        debug(SQLERRM);
      END IF;
      l_message := p_proc_name||'{'||
                   fnd_number.number_to_canonical(p_last_step_number)||'}: '||
                   SUBSTRB(SQLERRM,1,2000);
      IF g_debug THEN
        debug(l_message);
      END IF;
      fnd_message.set_name( 'PQP', 'PQP_230661_OSP_DUMMY_MSG' );
      fnd_message.set_token( 'TOKEN',l_message);
  END debug_others;
--







---Gets value from the pl/sql table ff_exec

PROCEDURE get_param_value (
        p_output_type       IN ff_exec.outputs_t
       ,p_name              IN VARCHAR2
       ,p_datatype          OUT NOCOPY VARCHAR2
       ,p_value             OUT NOCOPY VARCHAR2
       ,p_error_code        OUT NOCOPY NUMBER
       ,p_message           OUT NOCOPY VARCHAR2
        )
IS
l_proc_step NUMBER(20,10) ;
l_proc_name VARCHAR2(61) := g_package_name||'get_param_value';
BEGIN
IF g_debug THEN
    l_proc_step := 10;
    debug(l_proc_name, 10);END IF;
 FOR i in 1..p_output_type.count
  LOOP

   IF p_output_type(i).name=p_name  THEN
     p_datatype := p_output_type(i).datatype;
     p_value    := p_output_type(i).value;
   END IF;

 END LOOP;

 IF g_debug THEN
  debug_exit(l_proc_name) ;
 END IF ;

EXCEPTION
--------
WHEN OTHERS THEN
  debug('No Value',20);
  p_error_code:=-1;
  p_message:=SUBSTR(SQLERRM,0,2000);
  fnd_message.set_name('PQP', 'PQP_230661_OSP_DUMMY_MSG');
  fnd_message.set_token('TOKEN', p_message);
  RAISE;
debug_exit(l_proc_name) ;
END get_param_value ;


-- This Procedure is Called from Legislation Specific Layer. i.e. from
-- package pqp_gb_absence_plan_process for a Start Life Event and can be
-- Called from update_absence_plan_details.
-- The Process in the Procedure can be summarized as
-- First check whether the Absence is already processed for the
-- Period. If not processed then check the length of service from the
-- Element Input Values. Based on Length of service get the eligible
-- entitlements. Then calculate the Absences already taken ( entitlements
-- used up ). the difference gives the remaining entitlements.
-- Then generate_daily_absences process caches the day and its
-- work pattern, Pay band and Absence Band in a pl/sql table
-- write_daily_absences will insert the data into pqp_gap_daily_absences
-- table using the bulk insert method.

PROCEDURE create_absence_plan_details --create_daily_absences
       (p_assignment_id     IN  NUMBER
       ,p_person_id         IN  NUMBER
       ,p_business_group_id IN  NUMBER
       ,p_absence_id        IN  NUMBER
       ,p_absence_date_start IN DATE
       ,p_absence_date_end   IN DATE
       ,p_pl_id             IN  NUMBER
       ,p_pl_typ_id         IN  NUMBER
       ,p_element_type_id   IN  NUMBER
       ,p_create_start_date        IN  DATE
       ,p_create_end_date          IN  DATE
       ,p_output_type       IN  ff_exec.outputs_t
       ,p_error_code        OUT NOCOPY NUMBER
       ,p_message           OUT NOCOPY VARCHAR2
        )  IS

    invalid_length_of_service EXCEPTION;

    l_entitlements                pqp_absval_pkg.t_entitlements;
    l_absences_taken_to_date      pqp_absval_pkg.t_entitlements;
    l_entitlements_remaining      pqp_absval_pkg.t_entitlements;
    l_daily_absences              pqp_absval_pkg.t_daily_absences;
    l_object_version_number       pqp_gap_absence_plans.
                                   object_version_number%TYPE;
    l_gap_absence_plan            pqp_absval_pkg.csr_gap_absence_plan%ROWTYPE;

    l_plan_information      rec_plan_information ;

    l_generate_start_date    DATE;
    l_generate_end_date      DATE;

    l_error_code             fnd_new_messages.message_number%TYPE := 0 ;
    l_message                VARCHAR2(2500) ;
    l_length_of_service      NUMBER ;
    l_value                  VARCHAR2(240) ;
    l_datatype               VARCHAR2(6);
    l_maternity_ent_table_id NUMBER ;
    l_abs_ent_uom            VARCHAR2(1) ;
    l_proc_name  VARCHAR2(61) := g_package_name||'create_absence_plan_details';
    l_proc_step                   NUMBER(20,10);
    l_update_summary BOOLEAN;


BEGIN

    g_debug := hr_utility.debug_enabled ;

    IF g_debug THEN
     debug_enter(l_proc_name) ;
     debug('p_assignment_id:'||p_assignment_id);
     debug('p_person_id:'||p_person_id);
     debug('p_business_group_id:'||p_business_group_id);
     debug('p_absence_id:'||p_absence_id);
     debug('p_pl_id:'||p_pl_id);
     debug('p_pl_typ_id:'||p_pl_typ_id);
     debug('p_element_type_id:'||p_element_type_id);
     debug('p_start_date:'||p_create_start_date);
     debug('p_end_date:'||p_create_end_date);
     debug('p_absence_date_start:'||p_absence_date_start);
     debug('p_absence_date_end:'||p_absence_date_end);
    END IF ;


     l_generate_start_date := GREATEST(p_create_start_date,p_absence_date_start);
     l_generate_end_date := LEAST(NVL(p_create_end_date,hr_api.g_eot),p_absence_date_end);


    -- If daily absences exist for the given range for this plan then
    -- don't continue with the create process. Exit without error.
    -- This would happen in almost every absence, ie when the end
    -- life event is encountered and assuming that the end hasn't changed
    -- the batch was run

    IF l_generate_start_date IS NOT NULL
        AND l_generate_end_date IS NOT NULL -- both are not needed but
     THEN                                -- just makes it more robust

         IF g_debug THEN
           l_proc_step := 10 ;
           debug(l_proc_name,10);
         END IF;

-- Set global switch to toggle the summary table logging

   IF  g_log_duration_summary is NULL
   THEN

       IF g_debug THEN
         debug(l_proc_name, 12);
       END IF;

       g_log_duration_summary :=
       PQP_UTILITIES.pqp_get_config_value
               ( p_business_group_id    => p_business_group_id
                ,p_legislation_code     => 'GB'
                ,p_column_name          => 'PCV_INFORMATION10'
                ,p_information_category => 'PQP_GB_OSP_OMP_CONFIG'
                );

       g_log_duration_summary := NVL(g_log_duration_summary,'DISABLE');

       IF g_debug THEN
         debug('g_log_duration_summary' || g_log_duration_summary);
       END IF;

   END IF;


     -- get the Scheme Details into Record g_plan_information
        pqp_gb_omp_daily_absences.get_plan_extra_info_n_cache_it(
                                   p_pl_id            => p_pl_id
                                  ,p_plan_information => l_plan_information
                                  ,p_pl_typ_id        => p_pl_typ_id
                                  ,p_error_code       => l_error_code
                                  ,p_message          => l_message ) ;
         IF g_debug THEN
            l_proc_step := 15 ;
            debug(l_proc_name,15);
         END IF ;

      BEGIN

        get_param_value
         (p_output_type     => p_output_type
         ,p_name            => 'LENGTH_OF_SERVICE'
         ,p_datatype        => l_datatype
         ,p_value           => l_value
         ,p_error_code      => l_error_code
         ,p_message         => l_message
         );

        l_length_of_service    := TO_NUMBER(l_value);

        IF l_length_of_service IS NULL
        THEN
          RAISE invalid_length_of_service;
        END IF;

      EXCEPTION
       WHEN   VALUE_ERROR
           OR invalid_length_of_service
       THEN
         fnd_message.set_name( 'PQP', 'PQP_230012_OSPOMP_INALID_LOS' );
	 -- The message name PQP_230012_OSPOMP_INALID_LOS has missing "V" in INVALID
	 -- this is not corrected as the related OSP code was already arcsed in
         -- The value of "length of service", TOKEN, passed from the standard rate is invalid.
         -- Please check that the standard rate has been setup correctly and that atleast
         -- one formula output is named exactly LENGTH_OF_SERVICE.
         fnd_message.set_token( 'LOSVALUE', NVL(l_value,'<Null>'));
         fnd_message.raise_error;

      END;


        l_maternity_ent_table_id := l_plan_information.Absence_Entitlement_Parameters;

         IF l_plan_information.absence_entitlement_days_type
                    in ('CD','CW','CM') THEN
            l_abs_ent_uom  := 'C' ;
         ELSIF l_plan_information.absence_entitlement_days_type = 'WD' THEN
            l_abs_ent_uom  := 'W' ;
         ELSIF l_plan_information.absence_entitlement_days_type = 'WH' THEN
            l_abs_ent_uom  := 'H' ;
         END IF ;

--  l_abs_ent_uom  := substr(l_plan_information.absence_entitlement_days_type,1,1);


         -- Below procedure returns the Bands and the entitlements stored in
         -- Entitlement Table ( UDT ) and stores in g_band_info collection.

         IF g_debug THEN
             l_proc_step := 30 ;
             debug(l_proc_name,30);
         END IF ;

         pqp_gb_omp_daily_absences.get_entitlement_info (
                     p_business_group_id          => p_business_group_id
                    ,p_effective_date             => p_absence_date_start
                    ,p_assignment_id              => p_assignment_id
                    ,p_pl_id                      => p_pl_id
                    ,p_entitlement_tab_id         => l_maternity_ent_table_id
                    ,p_absence_id                 => p_absence_id
                    ,p_absence_ent_uom            =>
                       substr(l_plan_information.absence_entitlement_days_type,2,1)
                    ,p_start_date                 => p_absence_date_start
                    ,p_benefits_length_of_service => l_length_of_service
                    ,p_entitlements               => l_entitlements
                    ,p_error_code                 => l_error_code
                    ,p_message                    => l_message );
       IF g_debug THEN
           l_proc_step := 35 ;
           debug(l_proc_name,35);
       END IF ;

      -- gets the Band entitlements used already. In OMP as we consider only
      -- the current absence, this will return rows only in case of update.
      -- otherwise there should not be any record existing. All the used
      -- Bands will be stored in g_band_bal_info collection.

         pqp_gb_omp_daily_absences.get_entitlements_consumed(
                       p_assignment_id          => p_assignment_id
                      ,p_business_group_id      => p_business_group_id
                      ,p_effective_date         => l_generate_start_date -- l_absence_start_date
                      ,p_absence_id             => p_absence_id
                      ,p_pl_typ_id              => p_pl_typ_id
                      ,p_entitlements           => l_entitlements
                      ,p_absences_taken_to_date => l_absences_taken_to_date
                      ,p_lookup_type            => 'PQP_GB_OMP_CALENDAR_RULES'
                      ,p_error_code             => l_error_code
                      ,p_message                => l_message ) ;

       IF g_debug THEN
           l_proc_step := 40 ;
           debug(l_proc_name,40);
       END IF ;

     -- get final balance
        pqp_gb_omp_daily_absences.get_entitlements_remaining
                  ( p_entitlements           => l_entitlements
                   ,p_absences_taken_to_date => l_absences_taken_to_date
                   ,p_entitlement_uom        => l_abs_ent_uom
                   ,p_entitlements_remaining => l_entitlements_remaining
                   ,p_error_code             => l_error_code
                   ,p_message                => l_message );

       IF g_debug THEN
           l_proc_step := 45 ;
           debug(l_proc_name,45);
       END IF ;
      -- check the available entitlements and process the days and populate
      -- the pl/sql with the records to be inserted into daily absences table.

        pqp_absval_pkg.generate_daily_absences(
          p_assignment_id             => p_assignment_id
         ,p_business_group_id         => p_business_group_id
         ,p_absence_attendance_id     => p_absence_id
         ,p_default_work_pattern_name => l_plan_information.default_work_pattern
         ,p_calendar_user_table_id    => l_plan_information.absence_entitlement_holidays
         ,p_calendar_rules_list       => l_plan_information.calendar_rules_list
         ,p_generate_start_date      => l_generate_start_date
         ,p_generate_end_date        => l_generate_end_date
         ,p_absence_start_date        => p_absence_date_start
         ,p_absence_end_date          => p_absence_date_end
         ,p_entitlement_UOM           => l_abs_ent_uom
         ,p_payment_UOM               => l_plan_information.Daily_Rate_Divisor_Type
         ,p_output_type               => p_output_type
         ,p_entitlements_remaining    => l_entitlements_remaining
         ,p_daily_absences            => l_daily_absences
         ,p_error_code                => l_error_code
         ,p_message                   => l_message
	 ,p_is_assignment_wp          => TRUE
         ) ;
       IF g_debug THEN
           l_proc_step := 50 ;
           debug(l_proc_name,50);
       END IF ;


    OPEN pqp_absval_pkg.csr_gap_absence_plan(p_absence_id, p_pl_id);
    FETCH pqp_absval_pkg.csr_gap_absence_plan INTO l_gap_absence_plan;
    CLOSE pqp_absval_pkg.csr_gap_absence_plan;

       IF g_debug THEN
           l_proc_step := 50 ;
           debug(l_proc_name,50);
       END IF ;


    IF l_gap_absence_plan.gap_absence_plan_id IS NULL
    THEN

       IF g_debug THEN
         l_proc_step := 55 ;
         debug(l_proc_name, 55) ;
       END IF;

      pqp_gap_ins.ins
        (
         p_effective_date              => p_absence_date_start
        ,p_assignment_id               => p_assignment_id
        ,p_absence_attendance_id       => p_absence_id
        ,p_pl_id                       => p_pl_id
        ,p_last_gap_daily_absence_date => l_daily_absences(l_daily_absences.LAST).absence_date
        ,p_gap_absence_plan_id         => l_gap_absence_plan.gap_absence_plan_id
        ,p_object_version_number       => l_gap_absence_plan.object_version_number
        );
       l_update_summary := FALSE ;

       IF g_debug THEN
         l_proc_step := 60 ;
         debug(l_proc_name, 60) ;
       END IF;

     ELSE

       IF g_debug THEN
         l_proc_step := 65 ;
         debug(l_proc_name, 65) ;
       END IF;

      pqp_gap_upd.upd
        (p_effective_date              => p_absence_date_start
        ,p_gap_absence_plan_id         => l_gap_absence_plan.gap_absence_plan_id
        ,p_object_version_number       => l_gap_absence_plan.object_version_number
        ,p_assignment_id               => p_assignment_id
        ,p_absence_attendance_id       => p_absence_id
        ,p_pl_id                       => p_pl_id
        ,p_last_gap_daily_absence_date => l_daily_absences(l_daily_absences.LAST).absence_date
        );

       l_update_summary := TRUE ;

       IF g_debug THEN
         l_proc_step := 70 ;
         debug(l_proc_name, 70) ;
       END IF;

     END IF; -- IF l_gap_absence_plan.gap_absence_plan_id IS NULL



       IF g_debug THEN
         l_proc_step := 75 ;
         debug(l_proc_name, 75) ;
       END IF;

      pqp_absval_pkg.write_daily_absences
        (p_daily_absences      => l_daily_absences
        ,p_gap_absence_plan_id => l_gap_absence_plan.gap_absence_plan_id );

       IF g_debug THEN
         l_proc_step := 80 ;
         debug(l_proc_name, 80) ;
       END IF;
--    We feed the summary data for reporting purposes to fill in the
--    summary and balance tables

--Summary Table Changes Feed in to balance table
IF g_log_duration_summary = 'ENABLE' THEN

      IF g_debug THEN
         debug(l_proc_name, 85);
      END IF;
      pqp_absval_pkg.write_absence_summary
       (P_GAP_ABSENCE_PLAN_ID           => l_gap_absence_plan.gap_absence_plan_id
       ,P_ASSIGNMENT_ID                 => p_assignment_id
       ,P_ENTITLEMENT_GRANTED           => l_entitlements
       ,P_ENTITLEMENT_USED_TO_DATE      => l_absences_taken_to_date
       ,P_ENTITLEMENT_REMAINING         => l_entitlements_remaining
       ,P_ENTITLEMENT_UOM               => l_abs_ent_uom
       ,p_update                        => l_update_summary
       );
 END IF;
--Summary Table Changes
       IF g_debug THEN
         l_proc_step := 85 ;
         debug(l_proc_name, 85) ;
       END IF;


    END IF ; -- l_generate_start_date IS NOT NULL

       IF g_debug THEN
         debug_exit(l_proc_name) ;
       END IF;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END create_absence_plan_details ; --create_daily_absences ;





-- This procedure gets entitlements  based on LOS
-- from the entitlement Table ( UDT )
-- In OMP User can choose how the entitlements will be defined while
-- creation of template when the entitlement type is Calendar. It can be
-- Days, Weeks or Months.
-- If it is either Weeks or Months then in this procedure it will be
-- converted into Days and stored in the PL/SQL table
PROCEDURE get_entitlement_info
       (p_business_group_id          IN  NUMBER
       ,p_effective_date             IN  DATE
       ,p_assignment_id              IN  NUMBER
       ,p_pl_id                      IN  NUMBER -- added RR
       ,p_entitlement_tab_id         IN  NUMBER
       ,p_absence_id                 IN  NUMBER
       ,p_absence_ent_uom            IN  VARCHAR2
       ,p_start_date                 IN  DATE
       ,p_benefits_length_of_service IN  NUMBER
       ,p_entitlements               IN  OUT NOCOPY pqp_absval_pkg.t_entitlements
       ,p_error_code                 OUT NOCOPY NUMBER
       ,p_message                    OUT NOCOPY VARCHAR2
        ) IS
    l_intend_to_return VARCHAR2(1) ;
    l_start_date       DATE := p_start_date ;
    l_end_date         DATE ;
    l_entitlements_nc pqp_absval_pkg.t_entitlements := p_entitlements ;
    l_proc_name  VARCHAR2(61) := g_package_name||'get_entitlement_info';
    l_proc_step   NUMBER(20,10);
    l_is_ent_override   BOOLEAN ;

BEGIN
     IF g_debug THEN
       debug_enter(l_proc_name) ;
       debug('p_business_group_id:'||p_business_group_id);
       debug('p_effective_date:'||p_effective_date);
       debug('p_entitlement_tab_id:'||p_entitlement_tab_id);
       debug('p_absence_id:'||p_absence_id);
       debug('p_absence_ent_uom:'||p_absence_ent_uom);
       debug('p_start_date:'||p_start_date);
       debug('p_benefits_length_of_service:'||p_benefits_length_of_service);
     END IF ;

      -- Get the Intend to Return Flag from SSP_MATERNITIES Table.
      -- The Entitlements are based on the above Flag in OMP.

     l_intend_to_return := pqp_gb_osp_functions.pqp_get_ssp_matrnty_details
                           ( p_absence_attendance_id => p_absence_id
                            ,p_col_name              => 'INTEND_TO_RETURN_FLAG'
                            ,p_error_code            => p_error_code
                            ,p_message               => p_message );

        IF g_debug THEN
            l_proc_step := 10 ;
            debug(l_proc_name,10);
            debug('INTEND_TO_RETURN_FLAG:'||l_intend_to_return) ;
        END IF ;

        IF p_message IS NOT NULL THEN
           fnd_message.set_name('PQP', 'PQP_230661_OSP_DUMMY_MSG');
           fnd_message.set_token('TOKEN', p_message);
           fnd_message.raise_error;
        END IF;


      -- This function gets all the avialable Bands and the
      -- respective Entitlements

     p_error_code := pqp_gb_osp_functions.get_los_based_entitlements
                 ( p_business_group_id          => p_business_group_id
                  ,p_effective_date             => p_effective_date
                  ,p_assignment_id              => p_assignment_id
                  ,p_pl_id                      => p_pl_id
                  ,p_absence_pay_plan_class     => 'OMP'
                  ,p_entitlement_table_id       => p_entitlement_tab_id
                  ,p_benefits_length_of_service => p_benefits_length_of_service
                  ,p_band_entitlements          => p_entitlements
                  ,p_error_msg                  => p_message
                  ,p_omp_intend_to_return_to_work => l_intend_to_return
		  ,p_is_ent_override              => l_is_ent_override ) ;
		  -- Added p_is_ent_override added for OMP ent overrides

      IF g_debug THEN
          l_proc_step := 20 ;
          debug(l_proc_name,20);
      END IF ;

     IF p_message IS NOT NULL THEN
       fnd_message.set_name('PQP', 'PQP_230603_DEF_BAND1');
       fnd_message.raise_error;
     END IF;

     FOR i in 1..p_entitlements.COUNT
     LOOP
         p_entitlements(i).duration := p_entitlements(i).entitlement ;
     END LOOP;

       IF g_debug THEN
          l_proc_step := 30 ;
          debug(l_proc_name,30);
      END IF ;

        IF p_absence_ent_uom = 'W' THEN

       IF g_debug THEN
          l_proc_step := 35 ;
          debug(l_proc_name,35);
       END IF ;

        -- If the Entitlements are defined in Weeks then multiply by 7
           FOR i in 1..p_entitlements.count LOOP
             p_entitlements(i).entitlement := p_entitlements(i).entitlement * 7 ;
             p_entitlements(i).duration := p_entitlements(i).duration * 7 ;
           END LOOP ;

        ELSIF p_absence_ent_uom = 'M' THEN

       IF g_debug THEN
          l_proc_step := 40 ;
          debug(l_proc_name,40);
      END IF ;

        -- If the Entitlements are Defined in Months

           FOR i in 1..p_entitlements.count LOOP
               -- logic to convert months into days.
            IF p_entitlements(i).entitlement > 0 THEN

             l_end_date := ADD_MONTHS(l_start_date,p_entitlements(i).entitlement);
             p_entitlements(i).entitlement :=
                          pqp_gb_osp_functions.pqp_gb_get_calendar_days (
                -- Returns the No of Days between the Given Dates.
                              p_start_date => l_start_date
                             ,p_end_date   => l_end_date ) -1 ;

              l_start_date := l_end_date ;

            END IF ;
           END LOOP ;

        END IF ;
       IF g_debug THEN
          l_proc_step := 50 ;
          debug(l_proc_name,50);
          debug_exit(l_proc_name) ;
      END IF ;


 EXCEPTION
   ---------
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END get_entitlement_info;



PROCEDURE get_entitlements_consumed
              ( p_assignment_id          IN  NUMBER
               ,p_business_group_id      IN  NUMBER
               ,p_effective_date         IN  DATE
               ,p_absence_id             IN  NUMBER
               ,p_pl_typ_id              IN  NUMBER
               ,p_entitlements           IN  OUT NOCOPY pqp_absval_pkg.t_entitlements
               ,p_absences_taken_to_date IN  OUT NOCOPY pqp_absval_pkg.t_entitlements
               ,p_lookup_type            IN  VARCHAR2
               ,p_error_code             OUT NOCOPY NUMBER
               ,p_message                OUT NOCOPY VARCHAR2 ) IS

      l_get_band_bal csr_get_band_bal%ROWTYPE;
      l_flag         VARCHAR2(1):='N';
      l_count        NUMBER := 0 ;
      l_absences_taken_to_date_nc pqp_absval_pkg.t_entitlements ;
      l_proc_name VARCHAR2(61) := g_package_name||'get_entitlements_consumed';
      l_proc_step NUMBER(20,10) ;

BEGIN
     IF g_debug THEN
       debug_enter(l_proc_name) ;
       debug('p_assignment_id:'||p_assignment_id);
       debug('p_business_group_id:'||p_business_group_id);
       debug('p_effective_date:'||p_effective_date);
       debug('p_absence_id:'||p_absence_id);
       debug('p_pl_typ_id:'||p_pl_typ_id);
       debug('p_lookup_type:'||p_lookup_type );
     END IF ;

      l_absences_taken_to_date_nc := p_absences_taken_to_date ;

      If p_absences_taken_to_date.count>0 THEN
        p_absences_taken_to_date.delete;
      END IF;
      IF g_debug THEN
          l_proc_Step := 10 ;
          debug(l_proc_name,10);
      END IF;

      -- Cursor Returns Entitlements Band Wise.
      OPEN csr_get_band_bal(
                p_assignment_id     => p_assignment_id
               ,p_business_group_id => p_business_group_id
               ,p_absence_id        => p_absence_id
               ,p_pl_typ_id         => p_pl_typ_id
               ,p_lookup_type       => p_lookup_type ) ;
      LOOP
      FETCH csr_get_band_bal INTO l_get_band_bal;
      EXIT WHEN csr_get_band_bal%NOTFOUND;
      IF g_debug THEN
       debug('Band :'||l_get_band_bal.level_of_entitlement, 20 );
       debug('Balance :'||l_get_band_bal.consumed, 30 );
      END IF ;

       p_absences_taken_to_date(l_count+1).band := l_get_band_bal.level_of_entitlement;
       p_absences_taken_to_date(l_count+1).entitlement := l_get_band_bal.consumed;
       p_absences_taken_to_date(l_count+1).duration := l_get_band_bal.consumed;
       p_absences_taken_to_date(l_count+1).duration_in_hours :=
                                       l_get_band_bal.consumed_in_hours ;
       l_count :=l_count+1;

      END LOOP;

      CLOSE csr_get_band_bal;
      IF g_debug THEN
         l_proc_step := 20 ;
         debug(l_proc_name,20);
      END IF ;

      IF p_entitlements.count > p_absences_taken_to_date.count and l_count>0
      THEN
  -- i.e. When there are few used entitlements.
        FOR i in 1..p_entitlements.count LOOP
           IF g_debug THEN
             debug('Band in Entitlements :'||p_entitlements(i).band);
           END IF ;

          l_flag :='N';

          FOR j in 1..p_absences_taken_to_date.count
          LOOP
           debug('Band in Band Bal is :'||p_absences_taken_to_date(j).band);

           IF p_entitlements(i).band = p_absences_taken_to_date(j).band THEN
             l_flag :='Y';
           END IF;

          END LOOP;


          IF l_flag='N' THEN
            p_absences_taken_to_date(p_absences_taken_to_date.count+1).band
                     := p_entitlements(i).band;
            p_absences_taken_to_date(p_absences_taken_to_date.count+1).entitlement
                     := 0;
            p_absences_taken_to_date(p_absences_taken_to_date.count+1).duration
                     := 0;
            p_absences_taken_to_date(
                  p_absences_taken_to_date.COUNT + 1).duration_in_hours:=0;


          END IF;
        END LOOP;
      END IF;
        IF g_debug THEN
          l_proc_step := 30 ;
          debug(l_proc_name,30);
        END IF ;
 -- The below loop is when there are no used entitlements.

      IF l_count= 0 THEN
        FOR i in 1..p_entitlements.count
        LOOP
          p_absences_taken_to_date(i).band := p_entitlements(i).band ;
          p_absences_taken_to_date(i).entitlement := 0 ;
          p_absences_taken_to_date(i).duration := 0 ;
          p_absences_taken_to_date(i).duration_in_hours := 0 ;

        END LOOP;
      END IF;
        IF g_debug THEN
          debug_exit(l_proc_name) ;
        END IF ;



EXCEPTION
---------
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      p_absences_taken_to_Date := l_absences_taken_to_date_nc ;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END get_entitlements_consumed ;


--This Procedure calculates remaining entitlements
PROCEDURE get_entitlements_remaining
       (p_entitlements           IN pqp_absval_pkg.t_entitlements
       ,p_absences_taken_to_date IN pqp_absval_pkg.t_entitlements
       ,p_entitlement_UOM        IN VARCHAR2
       ,p_entitlements_remaining IN OUT NOCOPY pqp_absval_pkg.t_entitlements
       ,p_error_code             OUT NOCOPY NUMBER
       ,p_message                OUT NOCOPY VARCHAR2
       )
IS
  l_band_count NUMBER:=0;
  l_proc_name  VARCHAR2(61) := g_package_name||'get_entitlements_remaining';
  l_proc_step  NUMBER(20,10) ;

BEGIN
  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF ;

  FOR i in 1..p_entitlements.count
   LOOP
    if p_entitlements(i).entitlement = -1 THEN
       -- p_entitlements(i).duration=-1 then
     EXIT;
    ELSE
     l_band_count:=i;
    END IF;
   END LOOP;

   IF g_debug THEN
     l_proc_step := 10 ;
     debug(l_proc_name,10);
   END IF ;
  ----------
  FOR i in 1..l_band_count   ----p_band_info.count
   LOOP

      IF g_debug THEN
        l_proc_step := 20 ;
        debug(l_proc_name,20);
      END IF ;
      --------
      FOR j in 1..p_absences_taken_to_date.count
      LOOP
       --------
       IF p_absences_taken_to_date(j).band = p_entitlements(i).band THEN

        p_entitlements_remaining(i).band      := p_entitlements(i).band;



        IF p_entitlement_UOM = 'H' THEN
             IF g_debug THEN
               l_proc_step := 30 ;
               debug(l_proc_name,30);
             END IF ;
           p_entitlements_remaining(i).entitlement := p_entitlements(i).entitlement
                      -nvl(p_absences_taken_to_date(j).duration_in_hours,0);
           p_entitlements_remaining(i).duration := p_entitlements(i).duration
                      -nvl(p_absences_taken_to_date(j).duration_in_hours,0);
        ELSE

             IF g_debug THEN
               l_proc_step := 40 ;
               debug(l_proc_name,40);
               debug('p_entitlements_remaining(i):'||p_entitlements(i).band);
               debug('p_entitlements_remaining(i):'||p_entitlements(i).entitlement);
               debug(':');
               debug('p_absences_taken_to_date(j):'||p_absences_taken_to_date(j).entitlement) ;
             END IF ;

           p_entitlements_remaining(i).entitlement := p_entitlements(i).entitlement
                                -nvl(p_absences_taken_to_date(j).entitlement,0);
           p_entitlements_remaining(i).duration := p_entitlements(i).duration
                                -nvl(p_absences_taken_to_date(j).duration,0);
        END IF ;

             IF g_debug THEN
               l_proc_step := 50 ;
               debug(l_proc_name,50);
               debug('BAND:'||p_entitlements_remaining(i).band);
               debug('Entitlement:'||p_entitlements_remaining(i).entitlement);
             END IF ;
        IF p_entitlements_remaining(i).entitlement < 0 THEN

           p_entitlements_remaining(i).entitlement := 0 ;
           p_entitlements_remaining(i).duration := 0 ;

        END IF ;


       END IF;
       ---------
      END LOOP;
      --------------

   END LOOP;
   ---------------------

             IF g_debug THEN
               l_proc_step := 60 ;
               debug(l_proc_name,60);
             END IF ;


 IF p_entitlements.count=0 THEN
  RAISE e_novalue;
 END IF;

EXCEPTION
---------
WHEN e_novalue THEN
  debug('No Value in the Table' ,30);
  fnd_message.set_name('PQP', 'PQP_230661_OSP_DUMMY_MSG');
  fnd_message.set_token('TOKEN', 'No Value in Entitlement Balance Cache');
  RAISE;
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END get_entitlements_remaining ;


--Get Extra info
--This procedure gets all the plan extra information
-- in one go and caches the same by plan id. Given that
-- we need to call this once for every life event and
-- every absence has two life events, it is quite likely
-- that the same information will needed repeatedly.
-- note the cache stores information of one plan at a time
-- it is not a pl/sql table.
PROCEDURE get_plan_extra_info_n_cache_it (
        p_pl_id      IN  NUMBER
       ,p_plan_information  IN OUT NOCOPY rec_plan_information
       ,p_pl_typ_id  IN  NUMBER
       ,p_error_code OUT NOCOPY NUMBER
       ,p_message    OUT NOCOPY VARCHAR2
       ) IS

   l_trunc_yn  VARCHAR2(10) ;
   l_ret_val   NUMBER ;
   l_proc_name VARCHAR2(61) := g_package_name||'get_plan_extra_info_n_cache_it' ;
   l_proc_step NUMBER(20,10);

BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name) ;
      debug('Caching check:g_pl_id:'||fnd_number.number_to_canonical(g_pl_id));
      debug('Caching check:p_pl_id:'||fnd_number.number_to_canonical(g_pl_id));
    END IF ;

 IF g_pl_id IS NULL OR p_pl_id<>g_pl_id THEN

     IF g_debug THEN
      l_proc_step := 10 ;
      debug(l_proc_name,10);
      debug('Before :' || p_plan_information.Absence_Entitlement_Days_Type);
     END IF ;

     l_ret_val := pqp_gb_osp_functions.pqp_get_plan_extra_info
              ( p_pl_id            => p_pl_id,
                p_information_type => 'PQP_GB_OMP_ABSENCE_PLAN_INFO',
                p_segment_name     => 'Absence Entitlement Days Type',
                p_value            => p_plan_information.Absence_Entitlement_Days_Type,
                p_truncated_yes_no => l_trunc_yn,
                p_error_msg        => p_message
               );

     IF g_debug THEN
      l_proc_step := 15 ;
      debug(l_proc_name,15);
      debug('After :'||p_plan_information.Absence_Entitlement_Days_Type);
     END IF ;

     IF g_debug THEN
      l_proc_step := 20 ;
      debug(l_proc_name,20);
      debug('Before :'||p_plan_information.Absence_Entitlement_Parameters);
     END IF ;

     l_ret_val := pqp_gb_osp_functions.pqp_get_plan_extra_info
              ( p_pl_id            => p_pl_id,
                p_information_type => 'PQP_GB_OMP_ABSENCE_PLAN_INFO',
                p_segment_name     => 'Absence Entitlement Parameters',
                p_value            => p_plan_information.Absence_Entitlement_Parameters,
                p_truncated_yes_no => l_trunc_yn,
                p_error_msg        => p_message
               );
    IF g_debug THEN
      l_proc_step := 25 ;
      debug(l_proc_name,25);
      debug('After :'||p_plan_information.Absence_Entitlement_Parameters);
     END IF ;

    IF g_debug THEN
      l_proc_step := 30 ;
      debug(l_proc_name,30);
      debug('Before :'||p_plan_information.Absence_Entitlement_Holidays);

     END IF ;

     l_ret_val := pqp_gb_osp_functions.pqp_get_plan_extra_info
              ( p_pl_id            => p_pl_id,
                p_information_type => 'PQP_GB_OMP_ABSENCE_PLAN_INFO',
                p_segment_name     => 'Absence Entitlement Holidays',
                p_value            => p_plan_information.Absence_Entitlement_Holidays,
                p_truncated_yes_no => l_trunc_yn,
                p_error_msg        => p_message
              );
    IF g_debug THEN
      l_proc_step := 35 ;
      debug(l_proc_name,35);
      debug('After :'||p_plan_information.Absence_Entitlement_Holidays);
     END IF ;


    IF g_debug THEN
      l_proc_step := 40 ;
      debug(l_proc_name,40);
      debug('Before Daily Rate Divisor Type:'||p_plan_information.Daily_Rate_Divisor_Type);
     END IF ;

     l_ret_val := pqp_gb_osp_functions.pqp_get_plan_extra_info
              ( p_pl_id            => p_pl_id,
                p_information_type => 'PQP_GB_OMP_ABSENCE_PLAN_INFO',
                p_segment_name     => 'Daily Rate Divisor Type',
                p_value            => p_plan_information.Daily_Rate_Divisor_Type,
                p_truncated_yes_no => l_trunc_yn,
                p_error_msg        => p_message
              );
    IF g_debug THEN
      l_proc_step := 45 ;
      debug(l_proc_name,45);
      debug('After Daily Rate Divisor Type:'||p_plan_information.Daily_Rate_Divisor_Type);
     END IF ;

     IF g_debug THEN
      l_proc_step := 50 ;
      debug(l_proc_name,50);
      debug('Before Plan Name:'||p_plan_information.plan_name);
     END IF ;

     l_ret_val := pqp_gb_osp_functions.pqp_get_plan_extra_info
              ( p_pl_id            => p_pl_id,
                p_information_type => 'PQP_GB_OMP_ABSENCE_PLAN_INFO',
                p_segment_name     => 'Plan Name',
                p_value            => p_plan_information.plan_name,
                p_truncated_yes_no => l_trunc_yn,
                p_error_msg        => p_message
              );
     IF g_debug THEN
      l_proc_step := 55 ;
      debug(l_proc_name,55);
      debug('After Plan Name:'||p_plan_information.plan_name);
     END IF ;


     IF g_debug THEN
      l_proc_step := 60 ;
      debug(l_proc_name,60);
      debug('Before Daily Rate Divisor Duration:'||
                   p_plan_information.Daily_Rate_Divisor_Duration);
     END IF ;

     l_ret_val := pqp_gb_osp_functions.pqp_get_plan_extra_info
              ( p_pl_id            => p_pl_id,
                p_information_type => 'PQP_GB_OMP_ABSENCE_PLAN_INFO',
                p_segment_name     => 'Daily Rate Divisor Duration',
                p_value            => p_plan_information.Daily_Rate_Divisor_Duration,
                p_truncated_yes_no => l_trunc_yn,
                p_error_msg        => p_message
              );
     IF g_debug THEN
      l_proc_step := 65 ;
      debug(l_proc_name,65);
      debug('After Daily Rate Divisor Duration:'||
                   p_plan_information.Daily_Rate_Divisor_Duration);
     END IF ;


     IF g_debug THEN
      l_proc_step := 70 ;
      debug(l_proc_name,70);
      debug('Before Default Work Pattern :'||
                   p_plan_information.Default_Work_Pattern );
     END IF ;

     l_ret_val := pqp_gb_osp_functions.pqp_get_plan_extra_info
              ( p_pl_id            => p_pl_id,
                p_information_type => 'PQP_GB_OMP_ABSENCE_PLAN_INFO',
                p_segment_name     => 'Default Work Pattern',
                p_value            => p_plan_information.Default_Work_Pattern,
                p_truncated_yes_no => l_trunc_yn,
                p_error_msg        => p_message
              );
     IF g_debug THEN
      l_proc_step := 75 ;
      debug(l_proc_name,75);
      debug('After Default Work Pattern :'||
                   p_plan_information.Default_Work_Pattern );
     END IF ;

     IF g_debug THEN
      l_proc_step := 80 ;
      debug(l_proc_name,80);
      debug('Before Absence Entitlement Cal Rules :'||
                   p_plan_information.calendar_rules_list );
     END IF ;

     l_ret_val := pqp_gb_osp_functions.pqp_get_plan_extra_info
              ( p_pl_id            => p_pl_id,
                p_information_type => 'PQP_GB_OMP_ABSENCE_PLAN_INFO',
                p_segment_name     => 'Absence Entitlement Cal Rules',
                p_value            => p_plan_information.calendar_rules_list,
                p_truncated_yes_no => l_trunc_yn,
                p_error_msg        => p_message
              );

        g_pl_id:=p_pl_id;
        g_plan_information := p_plan_information;

  ELSE
    IF g_debug THEN
     l_proc_step := 85 ;
     debug(l_proc_name,85 );
    END IF ;
      p_plan_information := g_plan_information ;
  END IF;

  IF p_message IS NOT NULL THEN
     RAISE e_novalue;
  END IF;
      debug_exit(l_proc_name) ;
EXCEPTION
--------
  WHEN e_novalue THEN
    p_error_code:=-1;
    fnd_message.set_name('PQP', 'PQP_230661_OSP_DUMMY_MSG');
    fnd_message.set_token('TOKEN', 'No Value in Plan Extra Info');
    debug_exit(l_proc_name) ;
    RAISE;
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_plan_extra_info_n_cache_it ;



PROCEDURE update_absence_plan_details
  (p_assignment_id             IN  NUMBER
  ,p_person_id                 IN  NUMBER
  ,p_business_group_id         IN  NUMBER
  ,p_absence_id                IN  NUMBER
  ,p_absence_date_start        IN  DATE
  ,p_absence_date_end          IN  DATE
  ,p_pl_id                     IN  NUMBER
  ,p_pl_typ_id                 IN  NUMBER
  ,p_element_type_id           IN  NUMBER --
  ,p_update_start_date         IN  DATE   --
  ,p_update_end_date           IN  DATE   --
  ,p_output_type               IN  ff_exec.outputs_t
  ,p_error_code                OUT NOCOPY NUMBER
  ,p_message                   OUT NOCOPY VARCHAR2
  )
IS

  l_absence_end_date              DATE;
  l_gap_absence_plan              pqp_absval_pkg.csr_gap_absence_plan%ROWTYPE;
  l_first_entitled_day_of_noband  pqp_absval_pkg.csr_first_entitled_day_of_band%ROWTYPE;
  l_error_code                    fnd_new_messages.message_number%TYPE:=0;
  l_error_message                 fnd_new_messages.message_text%TYPE;

  l_proc_name                   VARCHAR2(61):=
                                    g_package_name||
                                    'update_absence_plan_details';
  l_proc_step  NUMBER(20,10) ;

BEGIN

    g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
    debug(l_proc_name,10);
    debug(p_assignment_id );
    debug(p_person_id );
    debug(p_business_group_id );
    debug(p_absence_id );
    debug( p_absence_date_start);
    debug(p_absence_date_end );
    debug(p_pl_id );
    debug(p_pl_typ_id );
    debug(p_element_type_id );
    debug( p_update_start_date);
    debug(p_update_end_date );
   END IF ;

  OPEN pqp_absval_pkg.csr_gap_absence_plan(p_absence_id, p_pl_id);
  FETCH pqp_absval_pkg.csr_gap_absence_plan INTO l_gap_absence_plan;
  CLOSE pqp_absval_pkg.csr_gap_absence_plan;

  IF g_debug THEN
    l_proc_step := 10 ;
    debug(l_proc_name,10);
  END IF ;

  IF p_absence_date_end = hr_api.g_eot -- if its an open ended absence
  THEN
  IF g_debug THEN
    l_proc_step := 15 ;
    debug(l_proc_name,15);
  END IF ;

    OPEN pqp_absval_pkg.csr_first_entitled_day_of_band
      (l_gap_absence_plan.gap_absence_plan_id
      ,'NOBAND'
      );

    FETCH pqp_absval_pkg.csr_first_entitled_day_of_band INTO l_first_entitled_day_of_noband;

    IF pqp_absval_pkg.csr_first_entitled_day_of_band%FOUND
    THEN
       IF g_debug THEN
         l_proc_step := 20 ;
         debug(l_proc_name,20);
       END IF ;

      IF l_first_entitled_day_of_noband.absence_date + 365 --(or 366 bug)
          = l_gap_absence_plan.last_gap_daily_absence_date
      THEN
        -- its an update call for an open ended absence.
        -- and needs no action as it has allready been generated to the
        -- maximum extent possible for an open ended absence.
        -- hence set the absence end date = last gap daily abs date
        l_absence_end_date := l_gap_absence_plan.last_gap_daily_absence_date;

      END IF; -- IF l_first_entitled_day_of_noband.absence_date + 365

    END IF; -- IF csr_first_entitled_day_of_band%FOUND THEN

    CLOSE pqp_absval_pkg.csr_first_entitled_day_of_band;

    IF g_debug THEN
      l_proc_step := 25 ;
      debug(l_proc_name,25);
    END IF ;

  ELSE

   l_absence_end_date := p_absence_date_end;

  END IF; -- IF l_absence_end_date = hr_api.g_eot

    IF g_debug THEN
      l_proc_step := 30 ;
      debug(l_proc_name,30);
      debug(l_absence_end_date);
      debug(l_gap_absence_plan.last_gap_daily_absence_date);
    END IF ;

  IF l_absence_end_date > l_gap_absence_plan.last_gap_daily_absence_date
  THEN

   IF g_debug THEN
      l_proc_step := 35 ;
      debug(l_proc_name,35);
    END IF ;


    create_absence_plan_details --create_daily_absences
     (p_assignment_id       => p_assignment_id
     ,p_person_id           => p_person_id
     ,p_business_group_id   => p_business_group_id
     ,p_absence_id          => p_absence_id
     ,p_absence_date_start  => p_absence_date_start
     ,p_absence_date_end    => p_absence_date_end
     ,p_pl_id               => p_pl_id
     ,p_pl_typ_id           => p_pl_typ_id
     ,p_element_type_id     => p_element_type_id
     ,p_create_start_date   => l_gap_absence_plan.last_gap_daily_absence_date+1
     ,p_create_end_date     => l_absence_end_date
     ,p_output_type         => p_output_type
     ,p_error_code          => l_error_code
     ,p_message             => l_error_message
    );

    IF g_debug THEN
      l_proc_step := 40 ;
      debug(l_proc_name,40);
    END IF ;



  ELSIF l_absence_end_date < l_gap_absence_plan.last_gap_daily_absence_date
  THEN

    IF g_debug THEN
      l_proc_step := 45 ;
      debug(l_proc_name,45);
    END IF ;


    pqp_absval_pkg.delete_absence_plan_details
      (p_assignment_id             => p_assignment_id
      ,p_business_group_id         => p_business_group_id
      ,p_plan_id                   => p_pl_id
      ,p_absence_id                => p_absence_id
      ,p_delete_start_date        => l_absence_end_date+1
      ,p_delete_end_date          => l_gap_absence_plan.last_gap_daily_absence_date
      ,p_error_code                => l_error_code
      ,p_message                   => l_error_message
      );

    IF g_debug THEN
      l_proc_step := 50 ;
      debug(l_proc_name,50);
    END IF ;



  ELSE -- l_absence_end_date = l_gap_absence_plan.last_gap_daily_absence_date
 -- no action required -- information only step.
--    IF g_debug THEN
--      debug(l_proc_name, 55);
      NULL; -- no action required
--    END IF;

  END IF; -- IF l_absence_end_date > last_gap_daily_absence_date


EXCEPTION
 WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
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

END update_absence_plan_details ;


-- This Procedure returns the Bands and the respective entitlements
-- The Bands and the entitlements are stored in pl/sql table
-- Called from Fast Formula

PROCEDURE get_entitlement_balance (
        p_assignment_id          IN NUMBER
       ,p_business_group_id      IN NUMBER
       ,p_pl_typ_id              IN NUMBER
       ,p_effective_date         IN DATE
       ,p_absences_taken_to_date IN OUT NOCOPY pqp_absval_pkg.t_entitlements
       ,p_error_code             OUT NOCOPY NUMBER
       ,p_message                OUT NOCOPY VARCHAR2
        )
IS

-- Cursor to get the Used up Bands and the number of Days
CURSOR c_get_band_bal( p_assignment_id     NUMBER
                      ,p_effective_date    DATE
                      ,p_business_group_id NUMBER
                      ,p_pl_typ_id         NUMBER ) IS
SELECT pgda.level_of_entitlement
       ,SUM(pgda.duration) days
       ,SUM(pgda.duration_in_hours) hours
 FROM   pqp_gap_daily_absences  pgda
       ,pqp_gap_absence_plans   pgap
       ,per_absence_attendances paa
       ,ben_pl_f                bpf
WHERE pgda.gap_absence_plan_id   = pgap.gap_absence_plan_id
  AND pgap.absence_attendance_id = paa.absence_attendance_id
  AND pgda.absence_date         <= p_effective_date
  AND pgap.assignment_id         = p_assignment_id
  AND paa.business_group_id      = p_business_group_id
  AND paa.business_group_id      = bpf.business_group_id
  AND bpf.pl_id                  = pgap.pl_id
  AND bpf.pl_typ_id              = p_pl_typ_id
  AND  p_effective_date                               --Bug7627227...Begin Change by VAIBGUPT
	BETWEEN bpf.effective_start_date AND
		bpf.effective_end_date		      --Bug7627227...end Change by VAIBGUPT
GROUP BY level_of_entitlement
ORDER BY level_of_entitlement;


l_flag varchar2(1):='N';
l_get_band_bal c_get_band_bal%ROWTYPE;
l_count number;
l_prev_date DATE;
l_proc_name VARCHAR2(61) := g_package_name||'get_entitlement_balance';
l_proc_step NUMBER(20,10);

BEGIN

  IF g_debug THEN
     debug_enter(l_proc_name);
     debug('p_assignment_id:'||p_assignment_id,1);
     debug('p_business_group_id:'||p_business_group_id,2);
     debug('p_pl_typ_id:'||p_pl_typ_id,3);
     debug('p_effective_date:'||p_effective_date,4);
   END IF ;

  l_count:=0;

  IF g_debug THEN
    l_proc_step := 10 ;
    debug(l_proc_name,10) ;
  END IF ;

  OPEN c_get_band_bal( p_assignment_id     => p_assignment_id
                      ,p_effective_date    => p_effective_date
                      ,p_business_group_id => p_business_group_id
                      ,p_pl_typ_id         => p_pl_typ_id);
   LOOP
    FETCH c_get_band_bal INTO l_get_band_bal;
    EXIT WHEN c_get_band_bal%NOTFOUND;
    p_absences_taken_to_date(l_count+1).band  := l_get_band_bal.level_of_entitlement;
    p_absences_taken_to_date(l_count+1).entitlement := l_get_band_bal.days;
    p_absences_taken_to_date(l_count+1).duration := l_get_band_bal.days;
    p_absences_taken_to_date(l_count+1).duration_in_hours := l_get_band_bal.hours;

     IF g_debug THEN
       l_proc_step := 20 ;
       debug(l_proc_name,20);
       debug(' Band:'||l_get_band_bal.level_of_entitlement);
       debug(' Days Duration:'||l_get_band_bal.days);
      debug(' Hours Duration:'||l_get_band_bal.hours);
     END IF ;

    l_count :=l_count+1;
   END LOOP;
  CLOSE c_get_band_bal;

   IF g_debug THEN
     debug_exit(l_proc_name);
   END IF ;


EXCEPTION
---------
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
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

END get_entitlement_balance;


END pqp_gb_omp_daily_absences ;

/
