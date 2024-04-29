--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_015
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_015" AS
/* $Header: IGSEN81B.pls 120.13 2006/03/14 00:43:32 smaddali ship $ */
  --
  --
  --  This function is used to get the effective census date which will be used
  --  to check the effectiveness of the hold.
  --
  --
  FUNCTION get_effective_census_date
  (
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_teach_cal_type               IN     VARCHAR2,
    p_teach_cal_seq_number         IN     NUMBER
  ) RETURN DATE IS
  --
  --  Parameters Description:
  --
  --  p_load_cal_type              -> Term or Load Calendar Type
  --  p_load_cal_seq_number        -> Term or Load Calendar Type Sequence Number
  --  p_teach_cal_type             -> Teaching Calendar Type
  --  p_teach_cal_seq_number       -> Teaching Calendar Type Sequence Number
  --
  --
  --  Cursor to find Census Date Alias for the Term (Load)
  --
  CURSOR cur_census_date (
           cp_cal_type              IN VARCHAR2,
           cp_cal_seq_number        IN NUMBER
         ) IS
    SELECT   NVL (absolute_val,
                    igs_ca_gen_001.calp_get_alias_val (
                      dai.dt_alias,
                      dai.sequence_number,
                      dai.cal_type,
                      dai.ci_sequence_number
                    )
                 ) AS term_census_date
    FROM     igs_ge_s_gen_cal_con sgcc,
             igs_ca_da_inst dai
    WHERE    sgcc.s_control_num = 1
    AND      dai.dt_alias = sgcc.census_dt_alias
    AND      dai.cal_type = cp_cal_type
    AND      dai.ci_sequence_number = cp_cal_seq_number
    ORDER BY 1 ASC; -- Order by the census_date to use the earliest value.
  CURSOR cur_teach_period_start_date IS
    SELECT   start_dt
    FROM     igs_ca_inst
    WHERE    cal_type = p_teach_cal_type
    AND      sequence_number = p_teach_cal_seq_number;
  --
  --  Local Variables for the function get_effective_census_date:
  --
  lv_census_date DATE;
  --
  BEGIN
    --
    --  The logic for calculating the Census Date is as follows:
    --    1) Get the CENSUS-DATE alias value for the Term or Load Calendar.
    --       If the CENSUS-DATE alias value is null or not defined then,
    --       1.1) Get the CENSUS-DATE alias value for the Teaching Period.
    --            If the the CENSUS-DATE value is null or not defined then,
    --            1.1.1) Get the Start Date of Teaching Period.
    --
    --
    --  Get the Census date of the Load or Term.
    --
    OPEN cur_census_date (p_load_cal_type, p_load_cal_seq_number);
    FETCH cur_census_date INTO lv_census_date;
    --
    --  If the CENSUS-DATE alias value for the Term is null or not defined.
    --
    IF ((lv_census_date IS NULL) OR (cur_census_date%NOTFOUND)) THEN
      CLOSE cur_census_date;
      --
      --  Get the Census date of the Teaching Period.
      --
      OPEN cur_census_date (p_teach_cal_type, p_teach_cal_seq_number);
      FETCH cur_census_date INTO lv_census_date;
      --
      --  If the CENSUS-DATE alias value for the Teaching Period is null or not defined.
      --
      IF ((lv_census_date IS NULL) OR (cur_census_date%NOTFOUND)) THEN
        CLOSE cur_census_date;
        --
        --  Get the Start date of Teaching Period instance as Census Date.
        --
        OPEN cur_teach_period_start_date;
        FETCH cur_teach_period_start_date INTO lv_census_date;
        CLOSE cur_teach_period_start_date;
      END IF;
    END IF;
    --
    IF (cur_census_date%ISOPEN) THEN
      CLOSE cur_census_date;
    END IF;
    --
    RETURN (lv_census_date);
    --
  END get_effective_census_date;
  --
  --
  --  Function validation_step_overridden is used to check if the given
  --  Eligibility Step Type is overridden or not and also returns the
  --  overridden credit point limit if any. (The overridden credit point limit
  --  will not be present for all the steps. It will be applicable only
  --  for "Minimum Credit Point Limit", "Maximum Credit Point Limit" and
  --  "Variable Credit Point Limit" steps.
  --
  --
  FUNCTION val_step_is_ovr_non_stud
  (
    p_eligibility_step_type        IN     VARCHAR2
  ) RETURN BOOLEAN AS

  l_person_type             igs_pe_person_types.person_type_code%TYPE;

  CURSOR cur_person_types (cp_person_type igs_pe_person_types.person_type_code%TYPE)IS
    SELECT system_type
    FROM   igs_pe_person_types
    WHERE  person_type_code = cp_person_type;

  l_cur_person_types        cur_person_types%ROWTYPE;
  l_system_person_type igs_pe_person_types.system_type%TYPE;

  CURSOR c_step_overridden (cp_validation  igs_pe_usr_aval.validation%TYPE,
                            cp_person_type igs_pe_person_types.person_type_code%TYPE) IS
    SELECT override_ind
    FROM   igs_pe_usr_aval
    WHERE  validation = cp_validation
    AND    override_ind = 'Y'
    AND    person_type = cp_person_type;

  l_step_overridden    igs_pe_usr_aval.override_ind%TYPE;

  BEGIN

    l_step_overridden := 'N';
    l_person_type     := Igs_En_Gen_008.enrp_get_person_type(p_course_cd =>NULL);

    OPEN  cur_person_types(l_person_type);
    FETCH cur_person_types INTO l_cur_person_types;
    CLOSE cur_person_types;

    l_system_person_type := l_cur_person_types.system_type;

    IF l_system_person_type <> 'STUDENT' THEN

       -- check whether l_step is overridden or not for non student
       OPEN c_step_overridden (p_eligibility_step_type,l_person_type );
       FETCH c_step_overridden INTO l_step_overridden;
       -- if the step is overridden, return true else continue the rest of validation
       IF c_step_overridden%FOUND THEN
          CLOSE c_step_overridden;
          RETURN TRUE;
       END IF;
       CLOSE c_step_overridden;

    END IF; -- check for person type
    RETURN FALSE;

  END val_step_is_ovr_non_stud;


  FUNCTION validation_step_is_overridden
  (
    p_eligibility_step_type        IN     VARCHAR2,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_step_override_limit          OUT    NOCOPY    NUMBER
  ) RETURN BOOLEAN IS
  --
  -- History :
  -- svenkata   6-Jun-2003      Modified the routine to check for Unit level Overrides at the Unit section level. If overrides do not exist at Unit
  --                            section level , check if one exists at Unit level. Deny / Warn build - Bug : 2829272.
  --  Parameters Description:
  --
  --  p_eligibility_step_type      -> Enrollment Eligibility Step Type
  --  p_load_cal_type              -> Term or Load Calendar Type
  --  p_load_cal_seq_number        -> Term or Load Calendar Type Sequence Number
  --  p_person_id                  -> Person ID of the Student who wants to enroll
  --                                  or administrator is enrolling the Students.
  --  p_uoo_id                     -> Unit Section Identifier to get the Teaching Calendar
  --                                  Instance against which the override will be checked
  --                                  in case it is not overridden at the Load Calendar level.
  --  p_step_override_limit        -> This will return the overridden limit for example
  --                                  Maximum Credit point limit.
  --
  --
  --  Cursor to check if the Step is overridden for a given Load or Teaching Calendar.
  --
  CURSOR cur_check_override (
           cp_cal_type              IN VARCHAR2,
           cp_cal_seq_number        IN NUMBER
         ) IS
    SELECT   step_override_limit,
             step_override_type
    FROM     igs_en_elgb_ovr_step eos,
             igs_en_elgb_ovr eoa
    WHERE    eoa.elgb_override_id = eos.elgb_override_id
    AND      eoa.cal_type = cp_cal_type
    AND      eoa.ci_sequence_number = cp_cal_seq_number
    AND      eoa.person_id = p_person_id
    AND      eos.step_override_type = p_eligibility_step_type;
  --
  --  Cursor to check if the Step is overridden for a given Load or Teaching Calendar
  --  and Unit Section.
  --
  CURSOR cur_check_override_uoo_id (
           cp_cal_type              IN VARCHAR2,
           cp_cal_seq_number        IN NUMBER,
           cp_uoo_id                IN NUMBER
         ) IS
    SELECT   eou.step_override_limit,
             step_override_type
    FROM     igs_en_elgb_ovr_step eos,
             igs_en_elgb_ovr eoa ,
             igs_en_elgb_ovr_uoo eou
    WHERE    eoa.elgb_override_id = eos.elgb_override_id
    AND      eoa.cal_type = cp_cal_type
    AND      eoa.ci_sequence_number = cp_cal_seq_number
    AND      eoa.person_id = p_person_id
    AND      eos.step_override_type = p_eligibility_step_type
    AND      eos.elgb_ovr_step_id = eou.elgb_ovr_step_id
    AND      eou.uoo_id = cp_uoo_id;
  --
  --  Cursor to check if the Step is overridden for a given Load or Teaching Calendar
  --  and Unit Code and Version Number of the Unit Section ID.
  --
  CURSOR cur_check_override_unit (
           cp_cal_type              IN VARCHAR2,
           cp_cal_seq_number        IN NUMBER,
           cp_unit_cd               IN VARCHAR2,
           cp_version_number        IN NUMBER
         ) IS
    SELECT   eou.step_override_limit,
             step_override_type
    FROM     igs_en_elgb_ovr_step eos,
             igs_en_elgb_ovr eoa ,
             igs_en_elgb_ovr_uoo eou
    WHERE    eoa.elgb_override_id = eos.elgb_override_id
    AND      eoa.cal_type = cp_cal_type
    AND      eoa.ci_sequence_number = cp_cal_seq_number
    AND      eoa.person_id = p_person_id
    AND      eos.step_override_type = p_eligibility_step_type
    AND      eos.elgb_ovr_step_id = eou.elgb_ovr_step_id
    AND      eou.unit_cd = cp_unit_cd
    AND      eou.version_number = cp_version_number
    AND      ( eou.uoo_id = -1 OR eou.uoo_id  IS NULL) ;
  --
  --  Cursor to check if the Step is overridden for a given Load or Teaching Calendar
  --  for the Unit Step.
  --
  CURSOR cur_check_override_ustep (
           cp_cal_type              IN VARCHAR2,
           cp_cal_seq_number        IN NUMBER
         ) IS
    SELECT   step_override_limit,
             step_override_type
    FROM     igs_en_elgb_ovr_step eos,
             igs_en_elgb_ovr eoa
    WHERE    eoa.elgb_override_id = eos.elgb_override_id
    AND      eoa.cal_type = cp_cal_type
    AND      eoa.ci_sequence_number = cp_cal_seq_number
    AND      eoa.person_id = p_person_id
    AND      eos.step_override_type = p_eligibility_step_type
    AND  NOT EXISTS (   SELECT 'X'
                        FROM igs_en_elgb_ovr_uoo eou
                        WHERE eos.elgb_ovr_step_id = eou.elgb_ovr_step_id );
  --
  --  Cursor to finds the Teaching Calendar for a Unit Section.
  --
  CURSOR cur_teach_period_of_uoo_id IS
    SELECT   unit_cd,
             version_number,
             cal_type,
             ci_sequence_number
    FROM     igs_ps_unit_ofr_opt
    WHERE    uoo_id = p_uoo_id;
  --
  --  Local Variables for the function validation_step_is_overridden:
  --
  rec_cur_check_override cur_check_override%ROWTYPE;
  rec_cur_check_override_uoo_id cur_check_override_uoo_id%ROWTYPE;
  rec_cur_check_override_unit cur_check_override_unit%ROWTYPE;
  rec_cur_check_override_ustep cur_check_override_ustep%ROWTYPE;
  rec_cur_teach_period_of_uoo_id cur_teach_period_of_uoo_id%ROWTYPE;
  --

  BEGIN

    --
    --  If the Unit Section ID is NULL then process the overridden logic using
    --  the Calendar passed.
    --
    IF (p_uoo_id IS NULL) THEN
      --
      --  Check if the Step is Overridden irrespective of the Unit Section ID
      --  and Unit Code, Unit Version. The step is overridden if the cursor
      --  fetches atleast one record.
      --
      OPEN cur_check_override (p_load_cal_type, p_load_cal_seq_number);
      FETCH cur_check_override INTO rec_cur_check_override;
      IF (cur_check_override%FOUND) THEN --  Step is Overridden
        CLOSE cur_check_override;
        p_step_override_limit := rec_cur_check_override.step_override_limit;

        RETURN TRUE;

      ELSE --  Step is not Overridden
        CLOSE cur_check_override;

        RETURN FALSE;
      END IF;

    ELSE --  If Unit Section is not NULL

      --
      --  Check if the Step is Overridden for the passed Unit Section ID. The step
      --  is overridden if the cursor fetches atleast one record.
      --
      OPEN cur_check_override_uoo_id (
             p_load_cal_type,
             p_load_cal_seq_number,
             p_uoo_id           );
      FETCH cur_check_override_uoo_id INTO rec_cur_check_override_uoo_id;
      IF (cur_check_override_uoo_id%FOUND) THEN
        CLOSE cur_check_override_uoo_id;
        p_step_override_limit := rec_cur_check_override_uoo_id.step_override_limit;

        RETURN TRUE;

      ELSE --  If the Step is not overridden for the Unit Section.
        CLOSE cur_check_override_uoo_id;
        --
        --  Get the Unit Code and Version Number for the passed Unit Section ID.
        --
        OPEN cur_teach_period_of_uoo_id;
        FETCH cur_teach_period_of_uoo_id INTO rec_cur_teach_period_of_uoo_id;
        CLOSE cur_teach_period_of_uoo_id;
        --
        --  If the step is not overridden for the passed Unit Section ID then
        --  check if the step is Overridden for the Unit Code and Version Number
        --  of the passed Unit Section ID. The step is overridden if the cursor
        --  fetches atleast one record.
        --
        OPEN cur_check_override_unit (
               p_load_cal_type,
               p_load_cal_seq_number,
               rec_cur_teach_period_of_uoo_id.unit_cd,
               rec_cur_teach_period_of_uoo_id.version_number
             );
        FETCH cur_check_override_unit INTO rec_cur_check_override_unit;
        IF (cur_check_override_unit%FOUND) THEN --  Step is Overridden for the Unit
          CLOSE cur_check_override_unit;
          p_step_override_limit := rec_cur_check_override_unit.step_override_limit;

          RETURN TRUE;
        ELSE --  If Step is not Overridden for the Unit
          CLOSE cur_check_override_unit;
          --
          --  Check if the Step is Overridden. The step is overridden if the cursor
          --  fetches atleast one record.
          --
          OPEN cur_check_override_ustep (
                 p_load_cal_type,
                 p_load_cal_seq_number
               );
          FETCH cur_check_override_ustep INTO rec_cur_check_override_ustep;
          IF (cur_check_override_ustep%FOUND) THEN --  Step is Overridden
            CLOSE cur_check_override_ustep;
            p_step_override_limit := rec_cur_check_override_ustep.step_override_limit;
            RETURN TRUE;
          ELSE --  If Step is not Overridden
            CLOSE cur_check_override_ustep;
            --
            -- Checking any overrides exists at unit and unit section level in teaching period, added the below code as part of bug 2366438, pmarada
            -- Check any overrides at unit section level in the Teaching calender
               -- Passing teaching cal type, and seq number to the uoo_id cursor, and
               -- checking any override exists at Unit section level in the teach period.
               OPEN cur_check_override_uoo_id (
                    rec_cur_teach_period_of_uoo_id.cal_type,
                    rec_cur_teach_period_of_uoo_id.ci_sequence_number,
                    p_uoo_id  );
               FETCH cur_check_override_uoo_id INTO rec_cur_check_override_uoo_id;
                 IF (cur_check_override_uoo_id%FOUND) THEN
                   CLOSE cur_check_override_uoo_id;
                   p_step_override_limit := rec_cur_check_override_uoo_id.step_override_limit;

                   RETURN TRUE;
                 ELSE
                   CLOSE cur_check_override_uoo_id;
                    -- Check any overrides exists at unit level in Teaching Period.
                    -- Passing teaching cal type,seq number,and unit_cd, version to the unit cursor
                   OPEN cur_check_override_unit (
                        rec_cur_teach_period_of_uoo_id.cal_type,
                        rec_cur_teach_period_of_uoo_id.ci_sequence_number,
                        rec_cur_teach_period_of_uoo_id.unit_cd,
                        rec_cur_teach_period_of_uoo_id.version_number );
                   FETCH cur_check_override_unit INTO rec_cur_check_override_unit;
                   IF (cur_check_override_unit%FOUND) THEN --  Step is Overridden for the Unit
                     CLOSE cur_check_override_unit;
                     p_step_override_limit := rec_cur_check_override_unit.step_override_limit;

                     RETURN TRUE;
                  ELSE --  If Step is not Overridden for the Unit
                    CLOSE cur_check_override_unit;
                    -- end of the code added as part of bug 2366438, pmarada
                    --  Check if the Step is Overridden for the Teaching Calendar Instance.
                    --  The step is overridden if the cursor fetches atleast one record.
                    --
                    OPEN cur_check_override_ustep (
                        rec_cur_teach_period_of_uoo_id.cal_type,
                        rec_cur_teach_period_of_uoo_id.ci_sequence_number
                        );
                    FETCH cur_check_override_ustep INTO rec_cur_check_override_ustep;
                    IF (cur_check_override_ustep%FOUND) THEN --  Step is Overridden
                      CLOSE cur_check_override_ustep;
                      p_step_override_limit := rec_cur_check_override_ustep.step_override_limit;
                      RETURN TRUE;
                    ELSE --  If Step is not Overridden, There is no override at any of level in load and teach periods.
                     CLOSE cur_check_override_ustep;
                    END IF;  -- cur_check_override_ustep teaching cal type
                END IF;   -- cur_check_override_unit for teaching period at unit level
            END IF;      -- cur_check_override_uoo_id for teaching period at unit section level
          END IF;       -- cur_check_override_ustep load cal
        END IF;       -- cur_check_override_unit load at unit
      END IF;       -- cur_check_override_uoo_id for load at unit section level
    END IF;     -- Uoo_id is not null

    -- If the override is not set up and any of the obove level
    -- check for the override at the user activity level
    IF val_step_is_ovr_non_stud(p_eligibility_step_type) THEN
      -- set the limit value as null, since this cannot be setup
      -- in the user activity form
      p_step_override_limit := NULL;
      RETURN TRUE;
    END IF;

    --
    --  If the Step is not overridden at any level then return FALSE.
    --
    RETURN FALSE;
    --
  END validation_step_is_overridden;
  --
  --
  --  Function seats_in_unreserved_category is used to check if there are seats
  --  available in Unreserved Category.
  --
  --
  FUNCTION seats_in_unreserved_category
  (
    p_uoo_id                       IN     NUMBER,
    p_level                        IN     VARCHAR2
  )
  RETURN NUMBER IS
  --
  -- History :
  -- stutta 27-Jul-2004  Removed logic to return(0) if enrollment max is null.
  --                     This return is stopping enrollment into unreserved seats
  --                     when reserve seating is set to <100% and enr max is null.
  --                     Hence, Considered enr max as 999999 if null instead. This
  --                     logic also takes care of stopping enrollment to unreserved
  --                     seats if 100% seats are set for reserve seating.Bug #3452321

  --
  --  Cursor to find Maximum Enrolllment for the Unit Section if available;
  --  otherwise get the Maximum Enrolllment for the Unit.
  --
  CURSOR cur_maximum_enrollment IS
    SELECT   NVL (usec.enrollment_maximum, uv.enrollment_maximum) enrollment_maximum,
             uoo.enrollment_actual enrollment_actual
    FROM     igs_ps_usec_lim_wlst usec,
             igs_ps_unit_ver uv,
             igs_ps_unit_ofr_opt uoo
    WHERE    uoo.unit_cd = uv.unit_cd
    AND      uoo.version_number = uv.version_number
    AND      uoo.uoo_id = usec.uoo_id (+)
    AND      uoo.uoo_id = p_uoo_id;
  --
  --  Cursor to find all the Organization Priorities for the Unit Section Organization.
  --
  CURSOR cur_org_priorities IS
    SELECT   rsv_org_unit_pri_id
    FROM     igs_ps_rsv_ogpri
    WHERE    org_unit_cd = (SELECT   owner_org_unit_cd
                            FROM     igs_ps_unit_ofr_opt
                            WHERE    uoo_id = p_uoo_id);
  --
  --  Cursor to find all the Organization Preferences for the passed Organization Priority.
  --
  CURSOR cur_org_preferences (
           cp_org_unit_priority_id  IN NUMBER
         ) IS
    SELECT   rsv_org_unit_pri_id,
             rsv_org_unit_prf_id,
             percentage_reserved
    FROM     igs_ps_rsv_orgun_prf
    WHERE    rsv_org_unit_pri_id = cp_org_unit_priority_id;
  --
  --  Cursor to find all the Unit Offering Pattern Priorities for the Unit Offering Pattern.
  --
  CURSOR cur_uop_priorities IS
    SELECT   rsv_uop_pri_id
    FROM     igs_ps_rsv_uop_pri
    WHERE    (unit_cd,
              version_number,
              calender_type,
              ci_sequence_number) = (SELECT   unit_cd,
                                              version_number,
                                              cal_type,
                                              ci_sequence_number
                                     FROM     igs_ps_unit_ofr_opt
                                     WHERE    uoo_id = p_uoo_id);
  --
  --  Cursor to find all the Unit Offering Pattern Preferences for the passed Unit Offering
  --  Pattern Priority.
  --
  CURSOR cur_uop_preferences (
           cp_uop_priority_id       IN NUMBER
         ) IS
    SELECT   rsv_uop_pri_id,
             rsv_uop_prf_id,
             percentage_reserved
    FROM     igs_ps_rsv_uop_prf
    WHERE    rsv_uop_pri_id = cp_uop_priority_id;
  --
  --  Cursor to find all the Unit Section Priorities for the Unit Section.
  --
  CURSOR cur_usec_priorities IS
    SELECT   rsv_usec_pri_id
    FROM     igs_ps_rsv_usec_pri
    WHERE    uoo_id = p_uoo_id;
  --
  --  Cursor to find all the Unit Section Preferences for the passed Unit Section Priority.
  --
  CURSOR cur_usec_preferences (
           cp_usec_priority_id       IN NUMBER
         ) IS
    SELECT   rsv_usec_pri_id,
             rsv_usec_prf_id,
             percentage_reserved
    FROM     igs_ps_rsv_usec_prf
    WHERE    rsv_usec_pri_id = cp_usec_priority_id;
  --
  --  Cursor to find Actual seats enrolled for the passed Level, Unit Section, and the
  --  Priorities and Preferences selected for the Level.
  --
  CURSOR cur_actual_seats (
           cp_uoo_id                IN NUMBER,
           cp_priority_id           IN NUMBER,
           cp_preference_id         IN NUMBER,
           cp_level                 IN VARCHAR2
         ) IS
    SELECT   actual_seat_enrolled
    FROM     igs_ps_rsv_ext
    WHERE    uoo_id = cp_uoo_id
    AND      priority_id = cp_priority_id
    AND      preference_id = cp_preference_id
    AND      rsv_level = cp_level;
  --
  --  Local Variables for the function seats_in_unreserved_category:
  --
  rec_cur_maximum_enrollment cur_maximum_enrollment%ROWTYPE;
  lv_total_reserved_seats NUMBER;
  lv_actual_enrolled_seats NUMBER;
  lv_seats_available NUMBER;
  --
  BEGIN
    --
    --  Get the Maximum Enrolllment for the Unit Section if available;
    --  otherwise get the Maximum Enrolllment for the Unit.
    --
    OPEN cur_maximum_enrollment;
    FETCH cur_maximum_enrollment INTO rec_cur_maximum_enrollment;
    IF ((cur_maximum_enrollment%NOTFOUND) OR (rec_cur_maximum_enrollment.enrollment_maximum IS NULL)) THEN
      rec_cur_maximum_enrollment.enrollment_maximum := 999999;
    END IF;
    CLOSE cur_maximum_enrollment;
    --
    --  Check the type of level for which the seats have to be calculated.
    --
    lv_total_reserved_seats := 0;
    lv_actual_enrolled_seats := 0;
    IF (p_level = 'UNIT_SEC') THEN
      FOR rec_cur_usec_priorities IN cur_usec_priorities LOOP
        FOR rec_cur_usec_preferences IN cur_usec_preferences (rec_cur_usec_priorities.rsv_usec_pri_id) LOOP
          lv_total_reserved_seats := NVL (lv_total_reserved_seats, 0) +
                                     ((rec_cur_maximum_enrollment.enrollment_maximum * NVL (rec_cur_usec_preferences.percentage_reserved, 0)) / 100);
          FOR rec_cur_actual_seats IN cur_actual_seats (
                                        p_uoo_id,
                                        rec_cur_usec_preferences.rsv_usec_pri_id,
                                        rec_cur_usec_preferences.rsv_usec_prf_id,
                                        p_level
                                      ) LOOP
            lv_actual_enrolled_seats := NVL (lv_actual_enrolled_seats, 0) + NVL (rec_cur_actual_seats.actual_seat_enrolled, 0);
          END LOOP;
        END LOOP;
      END LOOP;
      lv_seats_available := (rec_cur_maximum_enrollment.enrollment_maximum - FLOOR (NVL (lv_total_reserved_seats, 0)))
                              - (NVL (rec_cur_maximum_enrollment.enrollment_actual, 0) - NVL (lv_actual_enrolled_seats, 0));
      RETURN (lv_seats_available);
    ELSIF (p_level = 'UNIT_PAT') THEN
      FOR rec_cur_uop_priorities IN cur_uop_priorities LOOP
        FOR rec_cur_uop_preferences IN cur_uop_preferences (rec_cur_uop_priorities.rsv_uop_pri_id) LOOP
          lv_total_reserved_seats := NVL (lv_total_reserved_seats, 0) +
                                     ((rec_cur_maximum_enrollment.enrollment_maximum * NVL (rec_cur_uop_preferences.percentage_reserved, 0)) / 100);
          FOR rec_cur_actual_seats IN cur_actual_seats (
                                        p_uoo_id,
                                        rec_cur_uop_preferences.rsv_uop_pri_id,
                                        rec_cur_uop_preferences.rsv_uop_prf_id,
                                        p_level
                                      ) LOOP
            lv_actual_enrolled_seats := NVL (lv_actual_enrolled_seats, 0) + NVL (rec_cur_actual_seats.actual_seat_enrolled, 0);
          END LOOP;
        END LOOP;
      END LOOP;
      lv_seats_available := (rec_cur_maximum_enrollment.enrollment_maximum - FLOOR (NVL (lv_total_reserved_seats, 0)))
                            - (NVL (rec_cur_maximum_enrollment.enrollment_actual, 0) - NVL (lv_actual_enrolled_seats, 0));
      RETURN (lv_seats_available);
    ELSIF (p_level = 'ORG_UNIT') THEN
      FOR rec_cur_org_priorities IN cur_org_priorities LOOP
        FOR rec_cur_org_preferences IN cur_org_preferences (rec_cur_org_priorities.rsv_org_unit_pri_id) LOOP
          lv_total_reserved_seats := NVL (lv_total_reserved_seats, 0) +
                                     ((rec_cur_maximum_enrollment.enrollment_maximum * NVL (rec_cur_org_preferences.percentage_reserved, 0)) / 100);
          FOR rec_cur_actual_seats IN cur_actual_seats (
                                        p_uoo_id,
                                        rec_cur_org_preferences.rsv_org_unit_pri_id,
                                        rec_cur_org_preferences.rsv_org_unit_prf_id,
                                        p_level
                                      ) LOOP
            lv_actual_enrolled_seats := NVL (lv_actual_enrolled_seats, 0) + NVL (rec_cur_actual_seats.actual_seat_enrolled, 0);
          END LOOP;
        END LOOP;
      END LOOP;
      lv_seats_available := (rec_cur_maximum_enrollment.enrollment_maximum - FLOOR (NVL (lv_total_reserved_seats, 0)))
                            - (NVL (rec_cur_maximum_enrollment.enrollment_actual, 0) - NVL (lv_actual_enrolled_seats, 0));
      RETURN (lv_seats_available);
    END IF;
    -- Incase if none of the conditions are satisfied then it is returning 0.
    -- Added as part of bug# 2396138.
    RETURN 0;
  --
  END seats_in_unreserved_category;

  PROCEDURE get_usec_status
  (
    p_uoo_id               IN NUMBER,
    p_person_id            IN NUMBER,
    p_unit_section_status  OUT NOCOPY VARCHAR2,
    p_waitlist_ind         OUT NOCOPY VARCHAR2,
    p_load_cal_type        IN VARCHAR2 ,
    p_load_ci_sequence_number IN NUMBER,
    p_course_cd            IN VARCHAR2
  ) AS
  /*--------------------------------------------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :This procedure is used to get the status of the Unit Section and Waitlist Indicator,
  ||           which determine whether student can Enroll, Waitlist or will be shown error message.
  ||           p_waitlist_ind -> N, means Student can enroll into the unit section
  ||                          -> Y, means Student can waitlist into the unit section
  ||                          -> NULL, means Student can neither Enroll nor waitlist, message will be shown.
  ||           If seats are available and reserved seat is allowed then student enrollment is subject to whether
  ||           student satisfying the reserved seat step.
  ||           If student has got Closed section override, he/she will be Enrolled subject to Override max limit
  ||           , otherwise student will be wiatlisted subject to waitlist setup.
  || HISTORY
  || WHO         WHEN          WHAT
  || smanglm     22-Jan-2003   call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
  || knaraset    17-Jul-2002   modified the entire logic which consider only Actual Enrollment and
  ||                           Max. enrollment limit And other overrides and waitlist setup,
  ||                           as part fo the bug fix:2417240
  || pradhakr    24-Oct-2002   Modified the code to get the enrollment maximum, override max from
  ||                           Cross listed group / Meet with classes. If setup is not done in the
  ||                           above mentioned groups then it picks up from Unit Section / Unit level.
  ||                           Changes as per Cross Listed / Meet With DLD. Bug# 2599929.
  || kkillams    18-12-2002    Checking the student unit attempt table for reserve seating identifier before
  ||                           calling the  Igs_En_Elgbl_Unit.eval_rsv_seat function w.r.t. bug no :2643207
  || ptandon     02-09-2003    Modified the local function check_overrides_waitlist to check whether waitlisting
  ||                           is allowed at Institution/Term Calendar Level also as part of Waitlist
  ||                           Enhancements Build - Bug# 3052426
  ------------------------------------------------------------------------------------------------------------------*/
  --
  --  Cursor to find the Unit Section Status,Actual Enrollment,Actual Waitlist and Reserve seating allowed indicator
  --
  CURSOR c_unit_section_status  (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT unit_section_status,enrollment_actual, waitlist_actual,reserved_seating_allowed
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = cp_uoo_id;

  -- cursor to fetch the override enrollment maximum value defined at unit level
  CURSOR cur_unit_enr_max( p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT override_enrollment_max, enrollment_maximum
  FROM   igs_ps_unit_ver
  WHERE  (unit_cd , version_number ) IN (SELECT unit_cd , version_number
                                         FROM   igs_ps_unit_ofr_opt
                                         WHERE  uoo_id = p_uoo_id);

  -- Cursor to fetch the Override enrollment Maximum value defined at Unit Section level
  CURSOR cur_usec_enr_max( p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT override_enrollment_max, enrollment_maximum
  FROM igs_ps_usec_lim_wlst
  WHERE uoo_id = p_uoo_id;

  CURSOR c_prg_ver IS
  SELECT version_number
  FROM igs_en_stdnt_ps_att
  WHERE person_id= p_person_id AND
        course_cd = p_course_cd;


  -- Cursor to get the enrollment maximum in cross listed group
  CURSOR  c_cross_listed (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, grp.max_ovr_group, grpmem.usec_x_listed_group_id
  FROM    igs_ps_usec_x_grpmem grpmem,
          igs_ps_usec_x_grp grp
  WHERE   grp.usec_x_listed_group_id = grpmem.usec_x_listed_group_id
  AND     grpmem.uoo_id = l_uoo_id;


  -- Cursor to get the enrollment maximum in Meet with class group
  CURSOR  c_meet_with_cls (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, grp.max_ovr_group, ucm.class_meet_group_id
  FROM    igs_ps_uso_clas_meet ucm,
          igs_ps_uso_cm_grp grp
  WHERE   grp.class_meet_group_id = ucm.class_meet_group_id
  AND     ucm.uoo_id = l_uoo_id;


   -- Cursor to get the actual enrollment of all the unit sections that belong
   -- to this class listed group.
  CURSOR c_actual_enr_crs_lst(l_usec_x_listed_group_id igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE) IS
  SELECT SUM(enrollment_actual)
  FROM   igs_ps_unit_ofr_opt uoo,
         igs_ps_usec_x_grpmem ugrp
  WHERE  uoo.uoo_id = ugrp.uoo_id
  AND    ugrp.usec_x_listed_group_id = l_usec_x_listed_group_id;


  -- Cursor to get the actual enrollment of all the unit sections that belong
  -- to this meet with class group.
  CURSOR c_actual_enr_meet_cls(l_class_meet_group_id igs_ps_uso_clas_meet.class_meet_group_id%TYPE) IS
  SELECT SUM(enrollment_actual)
  FROM   igs_ps_unit_ofr_opt uoo,
         igs_ps_uso_clas_meet ucls
  WHERE  uoo.uoo_id = ucls.uoo_id
  AND    ucls.class_meet_group_id = l_class_meet_group_id;

  --Cursor to get the reserve seat id at unit section attempt level
  CURSOR c_sua_rs (p_person_id IGS_EN_SU_ATTEMPT.PERSON_ID%TYPE,
                   p_course_cd IGS_EN_SU_ATTEMPT.COURSE_CD%TYPE,
                   p_uoo_id    IGS_EN_SU_ATTEMPT.UOO_ID%TYPE) IS
  SELECT rsv_seat_ext_id FROM igs_en_su_attempt
                         WHERE person_id = p_person_id
                         AND   course_cd = p_course_cd
                         AND   p_uoo_id  = p_uoo_id
                         AND   rsv_seat_ext_id IS NOT NULL;

  l_rsv_seat_ext_id         igs_en_su_attempt.rsv_seat_ext_id%TYPE;
  l_version_number          igs_ps_ver.version_number%TYPE;
  l_enrollment_maximum      igs_ps_unit_ver.enrollment_maximum%TYPE;
  l_override_enrollment_max igs_ps_unit_ver.override_enrollment_max%TYPE;
  l_enrollment_actual       igs_ps_unit_ofr_opt.enrollment_actual%TYPE;
  l_waitlist_actual         igs_ps_unit_ofr_opt.waitlist_actual%TYPE;
  l_rsv_allowed             VARCHAR2(10);
  l_enr_meth_type           igs_en_method_type.enr_method_type%TYPE;
  l_enr_cal_type            VARCHAR2(20);
  l_enr_ci_seq              NUMBER(20);
  l_enr_cat                 VARCHAR2(20);
  l_enr_comm                VARCHAR2(2000);
  l_return_val              BOOLEAN;
  l_acad_cal_type           igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_acad_start_dt           igs_ca_inst.start_dt%TYPE;
  l_acad_end_dt             igs_ca_inst.end_dt%TYPE;
  l_alternate_code          igs_ca_inst.alternate_code%TYPE;
  l_message                 VARCHAR2(100);
  l_person_type             igs_pe_person_types.person_type_code%TYPE;
  l_notification_flag       VARCHAR2(10);
  l_ret_status              VARCHAR2(10);

  l_cross_listed_row        c_cross_listed%ROWTYPE;
  l_meet_with_cls_row       c_meet_with_cls%ROWTYPE;
  l_unit_section_status     c_unit_section_status%ROWTYPE;
  l_usec_partof_group       BOOLEAN;
  l_dummy                   VARCHAR2(200);
  l_deny_enrollment         VARCHAR2(1);

--
-- Local Function to check Overrides and waitlist then return appropriate value.
--  N - Can Enroll into the unit section
--  Y - Can waitlist into the unit section
--  NULL - Cant Enroll/Waitlist, Error message should be shown to user
--
FUNCTION check_overrides_waitlist RETURN VARCHAR2 IS
 --
 -- Cursor to Check if Waitlisting is allowed at the institution level .
 --
  CURSOR c_wait_allow_inst_level IS
  SELECT waitlist_allowed_flag
  FROM igs_en_inst_wl_stps;
 --
 -- Cursor to Check if Waitlisting is allowed at the term calendar level .
 --
  CURSOR c_wait_allow_term_cal(cp_cal_type igs_en_inst_wlst_opt.cal_type%TYPE) IS
  SELECT waitlist_alwd
  FROM igs_en_inst_wlst_opt
  WHERE cal_type = cp_cal_type;
 --
 -- Cursor to Check if Waitlisting is allowed at the unit section level .
 --
  CURSOR c_wait_allow_unit_section ( cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  waitlist_allowed , max_students_per_waitlist
  FROM igs_ps_usec_lim_wlst
  WHERE uoo_id = cp_uoo_id ;
 --
 -- cursor check if waitlisting is allowed at the unit offering level .
 --
  CURSOR c_wait_allow_unit_offering ( cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  uop.waitlist_allowed, uop.max_students_per_waitlist
  FROM igs_ps_unit_ofr_pat uop,
       igs_ps_unit_ofr_opt uoo
  WHERE uop.unit_cd            = uoo.unit_cd
         AND   uop.version_number     = uoo.version_number
         AND   uop.cal_type           = uoo.cal_type
         AND   uop.ci_sequence_number = uoo.ci_sequence_number
         AND   uoo.uoo_id             = cp_uoo_id
         AND   uop.delete_flag        ='N';


  l_step_override_limit     igs_en_elgb_ovr_step.step_override_limit%TYPE;
  l_wlst_max_ovr            BOOLEAN;
  l_closed_section_ovr      BOOLEAN;
  l_waitlist_allowed        igs_ps_unit_ofr_pat.waitlist_allowed%TYPE ;
  l_waitlist_max            igs_ps_usec_lim_wlst.max_students_per_waitlist%TYPE;

BEGIN

    --
    -- Check whether permission to override enrollment maximum is Y or not
    -- CLOSED_SECTION_OVR

    l_closed_section_ovr := validation_step_is_overridden (
                              p_eligibility_step_type        => 'CLOSED_SECTION_OVR',
                              p_load_cal_type                => p_load_cal_type,
                              p_load_cal_seq_number          => p_load_ci_sequence_number,
                              p_person_id                    => p_person_id,
                              p_uoo_id                       => p_uoo_id,
                              p_step_override_limit          => l_step_override_limit
                            );
    --
    -- Check whether permission to override enrollment maximum is Y or not
    -- WLST_MAX_OVR
    --
    l_wlst_max_ovr := validation_step_is_overridden (
                        p_eligibility_step_type        => 'WLST_MAX_OVR',
                        p_load_cal_type                => p_load_cal_type,
                        p_load_cal_seq_number          => p_load_ci_sequence_number,
                        p_person_id                    => p_person_id,
                        p_uoo_id                       => p_uoo_id,
                        p_step_override_limit          => l_step_override_limit
                      );

    --
    -- At the lowest level , waitlist allowed can be set at the Unit Section level . First check if waitlist has been
    -- allowed at Unit Section Level . If waitlisting is not allowed , then check at the next level - Unit Offering.
    -- If waitlisting is permitted at the Unit Offering level , return p_waitlist_ind = 'Y'
    -- We are not checking the waitlist Allowed Indicator at Organization Unit level because this item is mandatory
    -- at unit offering pattern level so no need to check beyond unit offering pattern level.

    -- As part of Waitlist Enhancements Build first we'll be checking whether waitlist is allowed at Institution
    -- and Term Calender level. Check will be performed at Unit Section/Unit Offering level only if waitlist is
    -- allowed at Institution and Term Calender level.

    l_waitlist_max := NULL;

    IF l_usec_partof_group = FALSE THEN
      -- Check whether waitlisting is allowed at institution level - Bug# 3052426
      OPEN c_wait_allow_inst_level;
      FETCH c_wait_allow_inst_level INTO l_waitlist_allowed;
      IF l_waitlist_allowed = 'Y' THEN
         -- If allowed at institution level, check whether it is allowed at term calendar level - Bug# 3052426
         OPEN c_wait_allow_term_cal(p_load_cal_type);
         FETCH c_wait_allow_term_cal INTO l_waitlist_allowed;
         IF l_waitlist_allowed = 'N' THEN
            l_waitlist_allowed := 'N';
         ELSE
            -- Check at unit secion/unit offering level.
            OPEN c_wait_allow_unit_section(p_uoo_id) ;
            FETCH c_wait_allow_unit_section INTO   l_waitlist_allowed, l_waitlist_max ;
            IF c_wait_allow_unit_section%NOTFOUND THEN
               OPEN c_wait_allow_unit_offering(p_uoo_id) ;
               FETCH c_wait_allow_unit_offering INTO   l_waitlist_allowed, l_waitlist_max ;
               CLOSE c_wait_allow_unit_offering;
            END IF;
            CLOSE c_wait_allow_unit_section;
         END IF;
      ELSE
         l_waitlist_allowed := 'N';
      END IF;
    ELSE
      l_waitlist_allowed := 'N';
    END IF;

    --
    -- If it is determined that waitlist is not allowed at the Unit section and Unit offering level , then
    -- no further validations need to be carried out NOCOPY . Else based on Waitlist limits it determines student can be waitlisted or not
    --
    IF l_waitlist_allowed ='N' THEN

        IF l_closed_section_ovr  THEN
           -- Check actual enrollment value is less than the Enrollment Override Maximum
                   -- If yes, user can Enroll into unit section
          IF l_enrollment_actual < NVL(l_override_enrollment_max,999999)THEN
             -- Student will be able to enroll since he/she has closed
             -- section override and the override seats are still available
            RETURN 'N';
          END IF;
        END IF;
                -- Student cannot Enroll,error message will be shown to the user
        RETURN NULL;
    ELSE -- Waitlist is allowed
        IF l_closed_section_ovr  THEN
            IF l_enrollment_actual < NVL(l_override_enrollment_max,999999)THEN
               -- Student will be able to enroll since he/she has closed
               -- section override and the override seats are still available
               RETURN 'N';
             END IF;
        END IF;

        IF l_waitlist_actual >= NVL(l_waitlist_max,999999) THEN
          IF l_wlst_max_ovr THEN
            RETURN 'Y';
          ELSE
            -- Student cannot Enroll,error message will be shown to the user
            RETURN NULL;
          END IF;
        ELSE
          RETURN 'Y';
        END IF;
    END IF;     -- Waitlist allowed?.
END check_overrides_waitlist;

BEGIN   -- get_usec_status

   l_usec_partof_group := FALSE;
    --
    -- Get the Program version
    --
    OPEN c_prg_ver;
    FETCH c_prg_ver INTO l_version_number;
    CLOSE c_prg_ver;

    -- Check whether the unit section belongs to any cross-listed group or not.
    OPEN c_cross_listed(p_uoo_id);
    FETCH c_cross_listed INTO l_cross_listed_row ;

    IF c_cross_listed%FOUND THEN
         -- Get the maximum enrollment limit from the group level.
        IF l_cross_listed_row.max_enr_group IS NULL THEN
           l_usec_partof_group := FALSE;
        ELSE
          l_usec_partof_group := TRUE;
          l_enrollment_maximum := l_cross_listed_row.max_enr_group;
          l_override_enrollment_max := l_cross_listed_row.max_ovr_group;
          -- Get the actual enrollment count of all the unit sections that belongs to the cross listed group.
          OPEN c_actual_enr_crs_lst(l_cross_listed_row.usec_x_listed_group_id);
          FETCH c_actual_enr_crs_lst INTO l_enrollment_actual;
          CLOSE c_actual_enr_crs_lst;
        END IF;

     ELSE

       OPEN c_meet_with_cls(p_uoo_id);
       FETCH c_meet_with_cls INTO l_meet_with_cls_row ;

       IF c_meet_with_cls%FOUND THEN
         -- Get the maximum enrollment limit from the group level.
         IF l_meet_with_cls_row.max_enr_group IS NULL THEN
           l_usec_partof_group := FALSE;
         ELSE
           l_usec_partof_group := TRUE;
           l_enrollment_maximum := l_meet_with_cls_row.max_enr_group;
           l_override_enrollment_max := l_meet_with_cls_row.max_ovr_group;
           -- Get the actual enrollment count of all the unit sections that belongs to
           -- the meet with class group.
           OPEN c_actual_enr_meet_cls(l_meet_with_cls_row.class_meet_group_id);
           FETCH c_actual_enr_meet_cls INTO l_enrollment_actual;
           CLOSE c_actual_enr_meet_cls;
         END IF;

       ELSE
         l_usec_partof_group := FALSE;
       END IF;
       CLOSE c_meet_with_cls;

     END IF;
     CLOSE c_cross_listed;

     IF l_usec_partof_group = FALSE THEN
        -- If setup is not defined in the group level then get the maximum enrollment limit
        -- from the Unit Section level.

        OPEN c_unit_section_status (p_uoo_id);
        FETCH c_unit_section_status INTO p_unit_section_status,l_enrollment_actual, l_waitlist_actual,l_rsv_allowed;
        CLOSE c_unit_section_status;
        l_override_enrollment_max := NULL;
        l_enrollment_maximum      := NULL;

        -- Find the Override Enrollment Maximum at Unit Section Level.
        OPEN cur_usec_enr_max(p_uoo_id);
        FETCH cur_usec_enr_max INTO l_override_enrollment_max, l_enrollment_maximum;
        CLOSE cur_usec_enr_max;

        -- If not defined at Unit Section, then Fetch at Unit Level
        IF l_enrollment_maximum IS NULL THEN
          OPEN cur_unit_enr_max(p_uoo_id);
          FETCH cur_unit_enr_max INTO l_override_enrollment_max, l_enrollment_maximum;
          CLOSE cur_unit_enr_max;
        END IF;

     ELSE

       -- If setup is done in group level then get the unit section status and set
       -- the reserve allowed indicator to 'N'.

         l_rsv_allowed := 'N';
         OPEN c_unit_section_status (p_uoo_id);
         FETCH c_unit_section_status INTO l_unit_section_status;
         CLOSE c_unit_section_status;
             p_unit_section_status := l_unit_section_status.unit_section_status;

    END IF;

    -- Moved NVL check here as part of Bug# 2674875
    l_enrollment_actual := NVL(l_enrollment_actual,0) ;
    l_waitlist_actual   := NVL(l_waitlist_actual,0) ;

    -- Check whether seats are available in the unit section, if available then student can enroll into it
    -- subject to Reserved seating setup.
    --

       IF l_rsv_allowed = 'Y' THEN
           -- Before calling the Igs_En_Elgbl_Unit.eval_rsv_seat function,
           -- Check reserve seating validation is already done for this student unit attempt or not.
           -- If done then set p_waitlist_ind to 'N' else do the reserve seating validation.
           OPEN c_sua_rs(p_person_id,
                         p_course_cd,
                         p_uoo_id);
           FETCH c_sua_rs INTO l_rsv_seat_ext_id;
           IF c_sua_rs%FOUND THEN
              CLOSE c_sua_rs;
              p_waitlist_ind := 'N';
           ELSE
                   CLOSE c_sua_rs;
                   -- Get the Self service enrollment menthod type
                   -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
                   igs_en_gen_017.enrp_get_enr_method(
                       p_enr_method_type => l_enr_meth_type,
                       p_error_message   => l_message,
                       p_ret_status      => l_ret_status);

                   --
                   -- get the academic calendar of the given Load Calendar
                   --
                   l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                                                                           p_cal_type                => p_load_cal_type,
                                                                           p_ci_sequence_number      => p_load_ci_sequence_number,
                                                                           p_acad_cal_type           => l_acad_cal_type,
                                                                           p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                                                                           p_acad_ci_start_dt        => l_acad_start_dt,
                                                                           p_acad_ci_end_dt          => l_acad_end_dt,
                                                                           p_message_name            => l_message );
                   IF l_message IS NOT NULL THEN
                           -- As cannot show appropriate error message, just stopping to enroll/waitlist
                        p_waitlist_ind := NULL;
                        RETURN;
                   END IF;
                   l_enr_cat := Igs_En_Gen_003.enrp_get_enr_cat(
                                                               p_person_id,
                                                               p_course_cd,
                                                               l_acad_cal_type,
                                                               l_acad_ci_sequence_number,
                                                               NULL,
                                                               l_enr_cal_type,
                                                               l_enr_ci_seq,
                                                               l_enr_comm,
                                                               l_dummy);
                   IF l_enr_comm = 'BOTH' THEN
                      l_enr_comm :='ALL';
                   END IF;
                   -- getting the person type of logged in person
                   l_person_type := Igs_En_Gen_008.enrp_get_person_type(p_course_cd =>NULL);
                   -- getting the notification flag of reserve seat step
                   l_message := NULL;
                   l_notification_flag  := Igs_Ss_Enr_Details.get_notification(
                                                                                p_person_type         => l_person_type,
                                                                                p_enrollment_category => l_enr_cat,
                                                                                p_comm_type           => l_enr_comm,
                                                                                p_enr_method_type     => l_enr_meth_type,
                                                                                p_step_group_type     => 'UNIT',
                                                                                p_step_type           => 'RSV_SEAT',
                                                                                p_person_id           => p_person_id,
                                                                                p_message             => l_message
                                                                               );
                   -- modified the call to get_notification as part of SEVIS build.
                   -- if the get notification returns a message then stop the processing
                   IF l_message IS NOT NULL THEN
                      p_waitlist_ind := NULL;
                      RETURN;
                   END IF;
                   --
                   -- Check whether Reserve seating is allowed and Reserve seat Step is defined as DENY, If defined as WARN
                   -- no validation required, as Student can still enroll into the unit section.
                   --
                   IF NVL(l_notification_flag,'NULL') = 'DENY' THEN

                     -- setting save point to roll back any changes done by reserve seat validation function
                     -- i.e it increments the Actual Enrollment under reserve category if student satisfies any Priority/preference
                     -- this needs to be rolled back, as the same action will be done when reserve seating is validated in
                     -- Unit Step Evaluation.
                     SAVEPOINT rsv_check_start;
                     l_dummy := NULL;
                     l_return_val := Igs_En_Elgbl_Unit.eval_rsv_seat(
                                                                     p_person_id                => p_person_id,
                                                                     p_load_cal_type            => p_load_cal_type,
                                                                     p_load_sequence_number     => p_load_ci_sequence_number,
                                                                     p_uoo_id                   => p_uoo_id,
                                                                     p_course_cd                => p_course_cd,
                                                                     p_course_version           => l_version_number,
                                                                     p_message                  => l_dummy,
                                                                     p_deny_warn                => l_notification_flag,
                                                                     p_calling_obj              => 'JOB',
                                                                     p_deny_enrollment          => l_deny_enrollment
                                                                     );
                           -- Roll back all changes done by reserve seat validation function
                           ROLLBACK TO rsv_check_start;
                           IF l_return_val = FALSE THEN
                              -- check whether student has any Overrides, based on this determine whether
                              -- student can be enrolled,waitlisted or cant do both.
                              p_waitlist_ind := check_overrides_waitlist();
                              --check if seat is 100% reserved and student belongs to unreserved category
                              IF NVL(l_deny_enrollment,'N') = 'Y' THEN
                                     p_waitlist_ind := NULL;
                                     RETURN ;
                              END IF;
                            -- check whether student has any Overrides, based on this determine whether
                            -- student can be enrolled,waitlisted or cant do both.
                            p_waitlist_ind := check_overrides_waitlist();


                           ELSE
                              -- Student Can Enroll into the unit section
                              p_waitlist_ind := 'N';
                           END IF;
                   ELSE
                     -- either Step is not defined or notification flag is not DENY.So Student Can Enroll into the unit section
                     p_waitlist_ind := 'N';
                   END IF; -- l_notification_flag
           END IF; --c_sua_rs%FOUND
       ELSE -- Reserve seat is not allowed
         p_waitlist_ind := 'N';
       END IF; --l_rsv_allowed
    IF l_enrollment_actual >= NVL(l_enrollment_maximum,999999) THEN


                -- check whether student has any Overrides, based on this determine whether
                -- student can be enrolled,waitlisted or cant do both.
                p_waitlist_ind := check_overrides_waitlist();

   END IF; -- l_enrollment_actual >= l_enrollment_maximum


  END get_usec_status;
  --
  --
  --  Procedure to get the Academic Calendar and Academic Calenar Sequence Number.
  --
  --
  PROCEDURE get_academic_cal
  (
    p_person_id                       IN     NUMBER,
    p_course_cd                       IN     VARCHAR2,
    p_acad_cal_type                  OUT NOCOPY     VARCHAR2,
    p_acad_ci_sequence_number        OUT NOCOPY     NUMBER,
    p_message                        OUT NOCOPY     VARCHAR2,
    p_effective_dt                   IN      DATE
  ) AS
    --
    --  Parameters Description:
    --
    --  p_person_id                     -> Person Identifier
    --  p_course_cd                     -> Program code
    --  p_acad_cal_type                 -> Out NOCOPY parameter carrying the academic calendar type
    --  p_acad_ci_sequence_number       -> Out NOCOPY parameter carrying academic calendar sequence number
    --
    --
    --  local variable used in the program unit
    --
    NO_SECC_RECORD_FOUND              EXCEPTION;
    cst_active                        CONSTANT VARCHAR2(10) := 'ACTIVE';
    cst_load                          CONSTANT VARCHAR2(10) := 'LOAD';
    cst_academic                      CONSTANT VARCHAR2(10) := 'ACADEMIC';
    l_daiv_rec_found                  BOOLEAN;
    l_cal_type                        igs_en_stdnt_ps_att.cal_type%TYPE;
    l_load_effect_dt_alias            igs_en_cal_conf.load_effect_dt_alias%TYPE;
    l_current_load_cal_type           igs_ca_inst.cal_type%TYPE;
    l_current_load_sequence_number    igs_ca_inst.sequence_number%TYPE;
    l_current_acad_cal_type           igs_ca_inst.cal_type%TYPE;
    l_current_acad_sequence_number    igs_ca_inst.sequence_number%TYPE;
    l_other_detail                    VARCHAR2(255);
    l_effective_dt                    DATE;
    --
    --  Cursor to fetch student course attempt calendar type
    --
    CURSOR c_stu_crs_atmpt (cp_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                            cp_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE) IS
      SELECT  sca.cal_type
      FROM    igs_en_stdnt_ps_att sca
      WHERE   sca.person_id = cp_person_id
      AND     sca.course_cd = cp_course_cd;
    --
    --  Cursor to fetch load effective date alias.
    --
    CURSOR c_s_enr_cal_conf IS
      SELECT  secc.load_effect_dt_alias
      FROM    igs_en_cal_conf secc
      WHERE   secc.s_control_num = 1;
    --
    --  Cursor to fetch calendar instances
    --
    CURSOR c_cal_instance (cp_cal_type      igs_ca_inst.cal_type%TYPE,
                           cp_effective_dt  igs_ca_inst.start_dt%TYPE) IS
      SELECT   ci.cal_type,
               ci.sequence_number
      FROM     igs_ca_inst ci,
               igs_ca_stat cs
      WHERE    ci.cal_type = cp_cal_type
      AND      ci.start_dt <= cp_effective_dt
      AND      ci.end_dt >= cp_effective_dt
      AND      cs.cal_status = ci.cal_status
      AND      cs.s_cal_status = cst_active
      ORDER BY ci.start_dt DESC;
    --
    --  Cursor to fetch calendar type instances
    --
    CURSOR c_cal_type_instance (cp_cal_type         igs_ca_inst.cal_type%TYPE,
                                cp_sequence_number  igs_ca_inst.sequence_number%TYPE) IS
      SELECT   ci.cal_type,
               ci.sequence_number,
               ci.start_dt,
               ci.end_dt
      FROM     igs_ca_type ct,
               igs_ca_inst ci,
               igs_ca_stat cs,
               igs_ca_inst_rel cir
      WHERE    ct.closed_ind = 'N'
      AND      cs.s_cal_status = cst_active
      AND      ci.cal_status = cs.cal_status
      AND      ct.s_cal_cat = cst_load
      AND      ci.cal_type = ct.cal_type
      AND      cir.sub_cal_type = ci.cal_type
      AND      cir.sub_ci_sequence_number =ci.sequence_number
      AND      cir.sup_cal_type = cp_cal_type
      AND      cir.sup_ci_sequence_number = cp_sequence_number
      AND EXISTS ( SELECT   1     FROM     igs_ca_inst_rel cir,
                                                igs_ca_type ct
                                       WHERE    cir.sup_cal_type = cp_cal_type
                                       AND      cir.sup_ci_sequence_number = cp_sequence_number
                                       AND      cir.sub_cal_type = ci.cal_type
                                       AND      cir.sub_ci_sequence_number = ci.sequence_number
                                       AND      ct.cal_type = cir.sup_cal_type
                                       AND      ct.s_cal_cat = cst_academic)
     ORDER BY ci.start_dt DESC;
    --
    --  Cursor to fetch the date alias
    --
    CURSOR c_dai_v (cp_cal_type             igs_ca_da_inst_v.cal_type%TYPE,
                    cp_ci_sequence_number   igs_ca_da_inst_v.ci_sequence_number%TYPE,
                    cp_load_effect_dt_alias igs_en_cal_conf.load_effect_dt_alias%TYPE) IS
      SELECT   daiv.alias_val
      FROM     igs_ca_da_inst_v daiv
      WHERE    daiv.cal_type = cp_cal_type
      AND      daiv.ci_sequence_number = cp_ci_sequence_number
      AND      daiv.dt_alias = cp_load_effect_dt_alias;
  --
  BEGIN

    -- This statement is added in ENCR015 build ( Bug ID : 2158654)
    -- Initialize the l_effective_date with the Effective Date Value passed to this Procedure as Parameter
    l_effective_dt := p_effective_dt;

    --
    --  The attendance type is derived based on the load calendar instances, using
    --  the load effective date alias as the reference point for determining
    --  which calendar is the current load_calendar.
    --  Load the student IGS_PS_COURSE attempt details.
    --
    OPEN c_stu_crs_atmpt (p_person_id,
                          p_course_cd);
    FETCH c_stu_crs_atmpt INTO l_cal_type;
    IF (c_stu_crs_atmpt%NOTFOUND) THEN
       --
       -- if not data found return from the program unit
       --
       CLOSE c_stu_crs_atmpt;
       p_message := 'IGS_EN_NO_CRS_ATMPT';
       RETURN;
    END IF;
    CLOSE c_stu_crs_atmpt;
    --
    -- Cetermine the 'current' load calendar instance based on the load effective
    -- date alias from the enrolment calendar configuration. If this date alias
    -- can't be located then the latest calendar instance where start_dt/end_dt
    -- encompass the effective dt is deemed current
    --
    OPEN c_s_enr_cal_conf;
    FETCH c_s_enr_cal_conf INTO l_load_effect_dt_alias;
    IF c_s_enr_cal_conf%NOTFOUND THEN
       CLOSE c_s_enr_cal_conf;
       p_message := 'IGS_EN_NO_SECC_REC_FOUND';
       RETURN;
    END IF;
    CLOSE c_s_enr_cal_conf;
    --
    -- initialise the local variables
    --
    l_current_load_cal_type := NULL;
    l_current_load_sequence_number := NULL;
    l_current_acad_cal_type := NULL;
    l_current_acad_sequence_number := NULL;
    --
    -- loop through the records fetched for calendar instances
    --
    FOR rec_cal_instance IN c_cal_instance (l_cal_type, l_effective_dt)
    LOOP
        --
        -- now loop through the cal type instance records
        --
        FOR rec_cal_type_instance IN c_cal_type_instance (rec_cal_instance.cal_type,
                                                          rec_cal_instance.sequence_number)
        LOOP
            --
            -- Attempt to find load effective date alias against the cale
            --
            l_daiv_rec_found := FALSE;
            FOR rec_dai_v IN c_dai_v (rec_cal_type_instance.cal_type,
                                      rec_cal_type_instance.sequence_number,
                                      l_load_effect_dt_alias)
            LOOP
                l_daiv_rec_found := TRUE;
                IF (l_effective_dt >= rec_dai_v.alias_val) THEN
                    l_current_load_cal_type := rec_cal_type_instance.cal_type ;
                    l_current_load_sequence_number := rec_cal_type_instance.sequence_number;
                    l_current_acad_cal_type := rec_cal_instance.cal_type;
                    l_current_acad_sequence_number := rec_cal_instance.sequence_number;
                END IF;
            END LOOP;
            IF NOT l_daiv_rec_found  THEN
               IF (l_effective_dt >= rec_cal_type_instance.start_dt) AND
                   (l_effective_dt <= rec_cal_type_instance.end_dt) THEN
                    l_current_load_cal_type := rec_cal_type_instance.cal_type ;
                    l_current_load_sequence_number := rec_cal_type_instance.sequence_number;
                    l_current_acad_cal_type := rec_cal_instance.cal_type;
                    l_current_acad_sequence_number := rec_cal_instance.sequence_number;
               END IF;
            END IF;
        END LOOP;
        IF l_current_load_cal_type IS NOT NULL THEN
           EXIT;
        END IF;
    END LOOP;
    IF l_current_load_cal_type IS NULL THEN
       p_acad_cal_type := NULL;
    END IF;
    p_acad_cal_type := l_current_acad_cal_type;
    p_acad_ci_sequence_number := l_current_acad_sequence_number;
    p_message := NULL;
  END get_academic_cal;
  --
  --
  -- This Function Validate whether given student completed the specified Program Stage
  -- by calling the function igs_pr_clc_stdnt_comp, which will insert the result rule status
  -- into the table igs_pr_s_scratch_pad.
  -- based on the rule status this function will return TRUE or FALSE
  --
  --
  FUNCTION enrp_val_ps_stage (
    p_person_id IGS_EN_SU_ATTEMPT.person_id%TYPE,
    p_course_cd IGS_EN_SU_ATTEMPT.course_cd%TYPE,
    p_version_number NUMBER,
    p_preference_code VARCHAR2
  ) RETURN BOOLEAN AS
    --
    CURSOR cur_seq_num IS
    SELECT sequence_number
    FROM  igs_ps_stage
    WHERE course_cd = p_course_cd AND
          version_number = p_version_number AND
          course_stage_type = p_preference_code
    ORDER BY sequence_number;
    --
    CURSOR cur_crs_stg_result (cp_creation_dt DATE,cp_key_1 VARCHAR2,cp_key_2 VARCHAR2,cp_key_3 VARCHAR2,
                                        cp_key_4 VARCHAR2,cp_key_5 VARCHAR2,cp_key_6 VARCHAR2) IS
     SELECT     text_1
     FROM       igs_pr_s_scratch_pad_v
     WHERE      creation_dt     = cp_creation_dt AND
            (cp_key_1   IS NULL OR
            key_1               = cp_key_1)     AND
            (cp_key_2   IS NULL OR
            key_2               = cp_key_2)     AND
            (cp_key_3   IS NULL OR
            key_3               = cp_key_3)     AND
           (cp_key_4    IS NULL OR
           key_4                = cp_key_4)     AND
           (cp_key_5    IS NULL OR
           key_5                = cp_key_5)     AND
           (cp_key_6    IS NULL OR
           key_6                = cp_key_6);
    --
    l_cur_seq_num igs_ps_stage.sequence_number%TYPE;
    lv_message_name VARCHAR2(30);
    l_crs_stg_result_rec igs_pr_s_scratch_pad_v.text_1%TYPE;
    lv_log_dt DATE;
    --
  BEGIN
    OPEN cur_seq_num;
    FETCH cur_seq_num INTO l_cur_seq_num;
    IF cur_seq_num%FOUND THEN
           --
           -- validate the completion of given Program stage for the given student.
           -- this function will create a record in igs_pr_s_scratch_pad with the rule status
         IF igs_pr_gen_005.igs_pr_clc_stdnt_comp(p_person_id,
                                               p_course_cd,
                                               p_version_number,
                                               p_course_cd,
                                               p_version_number,
                                               NULL,
                                               NULL,
                                               l_cur_seq_num,
                                               'N',
                                               'STG-COMP',
                                               'PRGF9030'||'|'||p_person_id||'|'||p_course_cd||'|'||l_cur_seq_num,
                                               'Y',
                                               lv_log_dt,
                                               lv_message_name
                                              ) THEN
                        --
                        -- check the rule status created by the above function, whether the given Program stage is completed..
                        OPEN cur_crs_stg_result(lv_log_dt,'PRGF9030',p_person_id,p_course_cd,l_cur_seq_num,'STG-COMP','RULE_STATUS');
                        FETCH cur_crs_stg_result INTO l_crs_stg_result_rec;
                        CLOSE cur_crs_stg_result;
              --
              IF l_crs_stg_result_rec = 'COURSE STAGE COMPLETION RULES SATISFIED' THEN
                          -- Student satisfied/completed the given program stage.
                RETURN TRUE;
              ELSE
                RETURN FALSE;
              END IF;
         END IF;
   END IF;
   CLOSE cur_seq_num;
   RETURN FALSE;
  END enrp_val_ps_stage;
  --
--
-- Added as part of ENCR013
FUNCTION enrp_get_appr_cr_pt(
    p_person_id IN IGS_EN_SU_ATTEMPT.person_id%TYPE,
    p_uoo_id IN IGS_EN_SU_ATTEMPT.uoo_id%TYPE
) RETURN NUMBER AS
 /******************************************************************
  Created By        : knaraset
  Date Created By   : 12-Nov-2001
  Purpose           : This Function returns Approved Credit Points if exists for student in override table
  Known limitations,
  enhancements,
  remarks            : As part of ENCR013
  Change History
  Who         When        What
  knaraset   04-Feb-03   Modified the cursors cur_unit_appr_cp and cur_term_appr_cp to add extra condition
                         of checking NULL for Unit Section , Unit version, so that when the override is
                         created for a particular Unit version it won't consider for other units.bug 2783365
 svenkata    6-Jun-2003  Modified the routine to check for Approved Credit points at the Unit section level. If overrides do not exist at Unit
                         section level , check if one exists at Unit level - First for Teach and then for Load Cal.Deny / Warn build - Bug : 2829272.
  ******************************************************************/
-- cursor to get Unit details for the Uoo_Id passed as parameter
  CURSOR cur_unit_dtl IS
  SELECT unit_cd,
         version_number,
                 cal_type,
                 ci_sequence_number
  FROM IGS_PS_UNIT_OFR_OPT
  WHERE uoo_id = p_uoo_id;

-- Cursor to get the Load Calendar of the given Teach Calendar.
  CURSOR cur_load_dtl_of_uoo_id (p_cal_type IGS_CA_TYPE.cal_type%TYPE , p_ci_sequence_number IGS_CA_INST.sequence_number%TYPE ) IS
    SELECT   load_cal_type,
             load_ci_sequence_number
    FROM     igs_ca_teach_to_load_v
    WHERE    teach_cal_type = p_cal_type
    AND      teach_ci_Sequence_number = p_ci_sequence_number ;


  --
  -- cursor to get the Approved credit points defined at Unit Section level for the given Calendar.
  --
   CURSOR cur_uoo_appr_cp (cp_cal_type VARCHAR2, cp_sequence_number NUMBER) IS
   SELECT eou.step_override_limit
   FROM igs_en_elgb_ovr_step eos,
        igs_en_elgb_ovr eo ,
        igs_en_elgb_ovr_uoo eou
   WHERE eos.step_override_type = 'VAR_CREDIT_APPROVAL' AND
         eos.elgb_override_id = eo.elgb_override_id AND
         eo.person_id = p_person_id AND
         eo.cal_type = cp_cal_type AND
         eo.ci_sequence_number = cp_sequence_number AND
         eos.elgb_ovr_step_id = eou.elgb_ovr_step_id AND
         eou.uoo_id = p_uoo_id ;

  --
  -- cursor to get the Approved credit points defined at Unit level.
  --
   CURSOR cur_unit_appr_cp(cp_unit_cd VARCHAR2, cp_version_number NUMBER, cp_cal_type VARCHAR2, cp_sequence_number NUMBER , cp_uoo_id NUMBER) IS
   SELECT eou.step_override_limit
   FROM igs_en_elgb_ovr_step eos,
        igs_en_elgb_ovr eo ,
        igs_en_elgb_ovr_uoo eou
   WHERE eos.step_override_type = 'VAR_CREDIT_APPROVAL' AND
         eos.ELGB_OVERRIDE_ID = eo.ELGB_OVERRIDE_ID AND
         eo.person_id = p_person_id AND
         eou.unit_cd = cp_unit_cd AND
         eou.version_number = cp_version_number AND
         ( eou.uoo_id IS NULL OR eou.uoo_id = -1 ) AND
         eos.elgb_ovr_step_id = eou.elgb_ovr_step_id AND
         eo.CAL_TYPE = cp_cal_type AND
         eo.CI_SEQUENCE_NUMBER = cp_sequence_number ;

   l_unit_dtl cur_unit_dtl%ROWTYPE;
   l_appr_cp igs_en_elgb_ovr_step.step_override_limit%TYPE := NULL;
   l_load_dtl_of_uoo_id cur_load_dtl_of_uoo_id%ROWTYPE;

BEGIN

  --
  -- Get the Unit Details
  OPEN cur_unit_dtl;
  FETCH cur_unit_dtl INTO l_unit_dtl;
  CLOSE cur_unit_dtl;

  --
  -- Get Approved Credit points defined at Unit Section level for Teach Calendar
  OPEN cur_uoo_appr_cp(l_unit_dtl.cal_type ,l_unit_dtl.ci_sequence_number);
  FETCH cur_uoo_appr_cp INTO l_appr_cp;
  IF cur_uoo_appr_cp%FOUND THEN
        CLOSE cur_uoo_appr_cp;
        RETURN l_appr_cp;
  END IF ;
  CLOSE cur_uoo_appr_cp;

  --
  -- Get Approved Credit points defined at Unit level for Teach Calendar
  OPEN cur_unit_appr_cp(l_unit_dtl.unit_cd, l_unit_dtl.version_number ,l_unit_dtl.cal_type ,l_unit_dtl.ci_sequence_number , p_uoo_id );
  FETCH cur_unit_appr_cp INTO l_appr_cp;
  IF cur_unit_appr_cp%FOUND THEN
        CLOSE cur_unit_appr_cp;
        RETURN l_appr_cp;
  END IF;
  CLOSE cur_unit_appr_cp;

  --Get the Load Calendar Details if the Override is not defined at the Load Calendar level.
    FOR l_load_dtl_of_uoo_id IN cur_load_dtl_of_uoo_id( l_unit_dtl.cal_type ,l_unit_dtl.ci_sequence_number)
  LOOP
  --
  -- Get Approved Credit points defined at Unit Section level for load Calendar
  OPEN cur_uoo_appr_cp(l_load_dtl_of_uoo_id.load_cal_type ,l_load_dtl_of_uoo_id.load_ci_sequence_number);
  FETCH cur_uoo_appr_cp INTO l_appr_cp;
  IF cur_uoo_appr_cp%FOUND THEN
        CLOSE cur_uoo_appr_cp;
        RETURN l_appr_cp;
  END IF ;
  CLOSE cur_uoo_appr_cp;

  END LOOP;

  --
  -- Get Approved Credit points defined at Unit level for Load Calendar
  OPEN cur_unit_appr_cp(l_unit_dtl.unit_cd, l_unit_dtl.version_number ,l_load_dtl_of_uoo_id.load_cal_type ,l_load_dtl_of_uoo_id.load_ci_sequence_number , p_uoo_id);
  FETCH cur_unit_appr_cp INTO l_appr_cp;
  IF cur_unit_appr_cp%FOUND THEN
        CLOSE cur_unit_appr_cp;
        RETURN l_appr_cp;
  END IF ;

  CLOSE cur_unit_appr_cp;
  RETURN l_appr_cp;

  END enrp_get_appr_cr_pt;

  FUNCTION enrf_drv_cmpl_dt (
    p_person_id         IN      NUMBER,
    p_course_cd         IN      VARCHAR2,
    p_achieved_cp       IN      NUMBER      ,
    p_attendance_type   IN      VARCHAR2    ,
    p_load_cal_type     IN      VARCHAR2    ,
    p_load_ci_seq_num   IN      NUMBER      ,
    p_load_ci_alt_code  IN      VARCHAR2    ,
    p_load_ci_start_dt  IN      DATE        ,
    p_load_ci_end_dt    IN      DATE        ,
    p_message_name      OUT NOCOPY     VARCHAR2
    )  RETURN DATE AS
  /*
  ||  Created By : ayedubat(Anji Babu)
  ||  Created On : 20-DEC-2001 ( As part of ENCR015 DLD)
  ||  Purpose : To Caluculate the Derived Completion Date of a Student Program Attempt
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  svanukur         10-MAY-2004    added the check to call igs_en_gen_015.enrp_get_eff_load_ci only if
  ||                                   a history record is found. BUG 3597429
  ||  (reverse chronological order - newest change first)
  */

  -- Local Variables

  l_achieved_cp      NUMBER;
  l_attendance_type      igs_en_stdnt_ps_att_all.attendance_type%TYPE;
  l_load_cal_type          igs_ca_inst.cal_type%TYPE;
  l_load_ci_seq_num      igs_ca_inst.sequence_number%TYPE;
  l_load_ci_alt_code igs_ca_inst.alternate_code%TYPE;
  l_load_ci_start_dt igs_ca_inst.start_dt%TYPE;
  l_load_ci_end_dt   igs_ca_inst.end_dt%TYPE;
  l_acad_cal_type    igs_ca_inst.cal_type%TYPE;
  l_acad_ci_seq_num      igs_ca_inst.sequence_number%TYPE;
  l_cmpl_dt          igs_en_stdnt_ps_att_all.override_cmpl_dt%TYPE;
  l_init_dt          DATE := NULL;
  l_init_load_cal_type     igs_ca_inst.cal_type%TYPE;
  l_init_load_ci_seq_num         igs_ca_inst.sequence_number%TYPE;
  l_init_load_ci_alt_code  igs_ca_inst.alternate_code%TYPE;
  l_init_load_ci_start_dt  igs_ca_inst.start_dt%TYPE;
  l_init_load_ci_end_dt    igs_ca_inst.end_dt%TYPE;
  l_message_name     VARCHAR2(30) := NULL;
  l_cst_enrolled VARCHAR2(10) ;


  -- Cursor to find the Start Date and End Date of a Calendar Instance
  CURSOR cur_ca_inst ( p_load_cal_type   igs_ca_inst.cal_type%TYPE,
                       p_load_ci_seq_num igs_ca_inst.sequence_number%TYPE) IS
    SELECT alternate_code, start_dt, end_dt
    FROM   IGS_CA_INST
    WHERE  cal_type        = p_load_cal_type
    AND    sequence_number = p_load_ci_seq_num ;
  cur_ca_inst_rec cur_ca_inst%ROWTYPE;


  -- Cursor find the Date at which the Student Program Attempt became 'ACTIVE'
  CURSOR cur_sca_active_dt( p_person_id igs_as_sc_attempt_h_all.person_id%TYPE,
                            p_course_cd igs_as_sc_attempt_h_all.course_cd%TYPE ) IS
    SELECT NVL(SCAH1.hist_start_dt,SCA1.last_update_date)  hist_start_dt
    FROM IGS_AS_SC_ATTEMPT_H scah1,  IGS_EN_STDNT_PS_ATT_ALL SCA1
   WHERE SCA1.person_id = SCAH1.person_id(+)
    AND  SCA1.course_cd =  SCAH1.course_cd(+)
    AND  SCA1.person_id = p_person_id
    AND  SCA1.course_cd = p_course_cd
    AND  SUBSTR( NVL(SCAH1.course_attempt_status, NVL(IGS_AU_GEN_003.audp_get_scah_col('COURSE_ATTEMPT_STATUS',SCAH1.person_id,
     SCAH1.course_cd,SCAH1.hist_end_dt), SCA1.course_attempt_status)),1,10) = l_cst_enrolled
    ORDER BY NVL(SCAH1.hist_start_dt,SCA1.last_update_date);


  --  Cursor to fetch student course attempt calendar type
  CURSOR cur_stu_crs_atmpt (cp_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                            cp_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE) IS
    SELECT  sca.cal_type
    FROM    igs_en_stdnt_ps_att sca
    WHERE   sca.person_id = cp_person_id
    AND     sca.course_cd = cp_course_cd;
  l_cal_type igs_ca_inst.cal_type%TYPE;

  BEGIN
    --Assigning due to gscc warnings
    l_cst_enrolled := 'ENROLLED';

    -- Assign the parameter values to local variables

    l_achieved_cp        :=  p_achieved_cp;
    l_attendance_type    :=  p_attendance_type;
    l_load_cal_type      :=  p_load_cal_type;
    l_load_ci_seq_num    :=  p_load_ci_seq_num;
    l_load_ci_alt_code   :=  p_load_ci_alt_code;
    l_load_ci_start_dt   :=  p_load_ci_start_dt;
    l_load_ci_end_dt     :=  p_load_ci_end_dt;

    -- Check , weather the Student Program Attempt exists or not
    OPEN cur_stu_crs_atmpt (p_person_id,
                            p_course_cd);
    FETCH cur_stu_crs_atmpt INTO l_cal_type;
    IF (cur_stu_crs_atmpt%NOTFOUND) THEN
      --
      -- if nt data found return from the program unit
      --
      CLOSE cur_stu_crs_atmpt;
      p_message_name := 'IGS_EN_NO_CRS_ATMPT';
      RETURN NULL;

    END IF;
    CLOSE cur_stu_crs_atmpt;

    --
    -- If the Load Cal Type Passed to the function is Null,
    -- Then Caluculate Load Calendar Instance for the current Acdemic Calendar of the Student Program Attempt
    --

    IF l_load_cal_type IS NULL OR l_load_ci_seq_num IS NULL THEN

      igs_en_gen_015.enrp_get_eff_load_ci (
        p_person_id,
        p_course_cd,
        SYSDATE,
        l_acad_cal_type,        -- value returned by GET_ACADEMIC_CAL
        l_acad_ci_seq_num,      -- value returned by GET_ACADEMIC_CAL
        l_load_cal_type,        -- OUT NOCOPY parameter
        l_load_ci_seq_num,      -- OUT NOCOPY Parameter
        l_load_ci_alt_code,     -- OUT NOCOPY Parameter
        l_load_ci_start_dt,     -- OUT NOCOPY Parameter
        l_load_ci_end_dt,       -- OUT NOCOPY Parameter
        l_message_name          -- OUT NOCOPY Parameter
      );

      -- If the load calendar returned is null then return the function with NULL after assigning
      -- IGS_EN_LOAD_CAL_NOT_FOUND to p_message_name

      IF l_load_cal_type IS NULL OR l_load_ci_seq_num IS NULL THEN

         p_message_name := 'IGS_EN_LOAD_CAL_NOT_FOUND' ;
         RETURN NULL;

      END IF;

    END IF;

    --
    -- If the Achieved Credit Points is passed as NULL
    -- Then call the API IGS_EN_GEN_001.ENRP_CLC_SCA_PASS_CP to get the Credit Points
    --

    IF l_achieved_cp IS NULL THEN

      l_achieved_cp := igs_en_gen_001.enrp_clc_sca_pass_cp (
                         p_person_id,
                         p_course_cd,
                         SYSDATE
                       );
    END IF;

    --
    -- If the Attendance Type is passed as NULL
    -- Then call IGS_EN_GEN_006.ENRP_GET_SCA_LATT as follows
    --

    IF l_attendance_type IS NULL THEN

    -- Changed the call to the procedure from IGS_EN_GEN_006.ENRP_GET_SCA_ATT to
    -- IGS_EN_GEN_006.ENRP_GET_SCA_LATT. Changes as per bug# 2370100

       l_attendance_type  := igs_en_gen_006.enrp_get_sca_latt(
                              p_person_id,
                              p_course_cd,
                              p_load_cal_type ,
                              p_load_ci_seq_num
                             );

    END IF;

    /***   Find the initial term of enrollment, i.e. the Term Calendar during which the program attempt became 'ACTIVE'  ***/

    --  First find out NOCOPY when the program attempt became ACTIVE.
    --  To do this look at the history table, order the records starting with the oldest history and
    --  see when (the last update date column) the status changed to 'ENROLLED' from something else.
    --  Let as call the date found in this step as L_INIT_DT

    OPEN cur_sca_active_dt ( p_person_id, p_course_cd );
    FETCH cur_sca_active_dt INTO l_init_dt;
    CLOSE cur_sca_active_dt;

   --fetch the load calendar details only if a history record is found

     IF l_init_dt IS NOT NULL THEN
       igs_en_gen_015.enrp_get_eff_load_ci (
        p_person_id,
        p_course_cd,
        l_init_dt,
        l_acad_cal_type,        -- value returned by GET_ACADEMIC_CAL
        l_acad_ci_seq_num,      -- value returned by GET_ACADEMIC_CAL
        l_init_load_cal_type,        -- OUT NOCOPY parameter
        l_init_load_ci_seq_num,      -- OUT NOCOPY Parameter
        l_init_load_ci_alt_code,     -- OUT NOCOPY Parameter
        l_init_load_ci_start_dt,     -- OUT NOCOPY Parameter
        l_init_load_ci_end_dt,       -- OUT NOCOPY Parameter
        l_message_name               -- OUT NOCOPY Parameter
      );


    -- If the load calendar returned is null then return the function with NULL after assigning
    -- IGS_EN_LOAD_CAL_NOT_FOUND to p_message_name

     IF l_init_load_cal_type IS NULL OR l_init_load_ci_seq_num IS NULL THEN
       p_message_name := 'IGS_EN_LOAD_CAL_NOT_FOUND' ;
       RETURN NULL;

     END IF;

     -- Find the start date and end date for the INIT load calendar

     OPEN cur_ca_inst( l_init_load_cal_type , l_init_load_ci_seq_num);
     FETCH cur_ca_inst INTO cur_ca_inst_rec;
     CLOSE cur_ca_inst;

     l_init_load_ci_start_dt := cur_ca_inst_rec.start_dt;
     l_init_load_ci_end_dt   := cur_ca_inst_rec.end_dt;

    -- Call the User Hook IGS_EN_RPT_PRC_UHK.ENRF_DRV_CMPL_DT_UHK. The call to the function should be as follows

    l_cmpl_dt := igs_en_rpt_prc_uhk.enrf_drv_cmpl_dt_uhk (
                   p_person_id,
                   p_course_cd,
                   l_achieved_cp,
                   l_attendance_type,
                   l_load_cal_type,
                   l_load_ci_seq_num,
                   l_load_ci_alt_code,
                   l_load_ci_start_dt,
                   l_load_ci_end_dt,
                   l_init_load_cal_type,
                   l_init_load_ci_seq_num,
                   l_init_load_ci_alt_code,
                   l_init_load_ci_start_dt,
                   l_init_load_ci_end_dt
                 );

    RETURN l_cmpl_dt;
  END IF;
   RETURN NULL;

  EXCEPTION
    WHEN OTHERS THEN
        fnd_message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
        fnd_message.Set_Token('NAME','IGS_EN_GEN_015.enrf_drv_cmpl_dt');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

  END enrf_drv_cmpl_dt;

  PROCEDURE enrp_get_eff_load_ci (
    p_person_id           IN    NUMBER,
    p_course_cd           IN    VARCHAR2,
    p_effective_dt        IN    DATE,
    p_acad_cal_type       OUT NOCOPY   VARCHAR2,
    p_acad_ci_seq_num     OUT NOCOPY   NUMBER,
    p_load_cal_type       OUT NOCOPY   VARCHAR2,
    p_load_ci_seq_num     OUT NOCOPY   NUMBER,
    p_load_ci_alt_code    OUT NOCOPY   VARCHAR2,
    p_load_ci_start_dt    OUT NOCOPY   DATE,
    p_load_ci_end_dt      OUT NOCOPY   DATE,
    p_message_name        OUT NOCOPY   VARCHAR2) AS

  /*
  ||  Created By : ayedubat(Anji Babu)
  ||  Created On : 19-DEC-2001 ( As part of ENCR015 DLD)
  ||  Purpose : To find the Effective Load Calendar Instance in a given Academic Calendar Instance
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  stutta	    20-NOV-2003	    Removed code to find the effective load calendar and replaced it
  ||				    with a call to get_curr_acad_term_cal. As part of Term Records Build.
  ||  (reverse chronological order - newest change first)
  */

    --
    --  Cursor to fetch student course attempt calendar type
    --
    CURSOR c_stu_crs_atmpt (cp_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                            cp_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE) IS
      SELECT  sca.cal_type
      FROM    igs_en_stdnt_ps_att sca
      WHERE   sca.person_id = cp_person_id
      AND     sca.course_cd = cp_course_cd;

   -- Local Variables
   l_cal_type                        igs_en_stdnt_ps_att.cal_type%TYPE;
   l_message VARCHAR2(100);

   BEGIN

    --
    --  The attendance type is derived based on the load calendar instances, using
    --  the load effective date alias as the reference point for determining
    --  which calendar is the current load_calendar.
    --  Load the student IGS_PS_COURSE attempt details.
    --

    OPEN c_stu_crs_atmpt (p_person_id,
                          p_course_cd);
    FETCH c_stu_crs_atmpt INTO l_cal_type;
    IF (c_stu_crs_atmpt%NOTFOUND) THEN
       --
       -- if not data found return from the program unit
       --
       CLOSE c_stu_crs_atmpt;
       p_message_name := 'IGS_EN_NO_CRS_ATMPT';
       RETURN;
    END IF;
    CLOSE c_stu_crs_atmpt;

    --
    -- Get the current Academic Calendar
    --
    get_academic_cal
      (
        p_person_id                => p_person_id,
        p_course_cd                => p_course_cd ,
        p_acad_cal_type            => p_acad_cal_type,
        p_acad_ci_sequence_number  => p_acad_ci_seq_num,
        p_message                  => l_message,
        p_effective_dt             => p_effective_dt
      );

    IF l_message IS NOT NULL THEN
      p_message_name := l_message;
      RETURN;
    END IF;

    --
    -- determine the 'current' load calendar instance based on the load effective
    -- date alias from the enrolment calendar configuration. If this date alias
    -- can't be located then the latest calendar instance where start_dt/end_dt
    -- encompass the effective dt is deemed current
    --
    get_curr_acad_term_cal (
            l_cal_type,
            p_effective_dt,
            p_load_cal_type,
            p_load_ci_seq_num,
            p_load_ci_alt_code,
            p_load_ci_start_dt,
            p_load_ci_end_dt,
            p_message_name);

  EXCEPTION
    WHEN OTHERS THEN
        fnd_message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
        fnd_message.Set_Token('NAME','IGS_EN_GEN_015.enrp_get_eff_load_ci');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

  END enrp_get_eff_load_ci;

  PROCEDURE check_spl_perm_exists(
                                 p_cal_type             IN VARCHAR2,
                                 p_ci_sequence_number   IN NUMBER,
                                 p_person_id            IN  NUMBER,
                                 p_uoo_id               IN  NUMBER,
                                 p_person_type          IN VARCHAR2,
                                 p_program_cd           IN VARCHAR2,
                                 p_message_name         OUT NOCOPY VARCHAR2,
                                 p_return_status        OUT NOCOPY VARCHAR2,
                                 p_check_audit      IN VARCHAR2,
                                 p_audit_status     OUT NOCOPY VARCHAR2,
                                 p_audit_msg_name   OUT NOCOPY VARCHAR2
                                ) AS
   ------------------------------------------------------------------------------------
    --Created by  : brajendr ( Oracle IDC)
    --Date created: 08-OCT-2001
    --
    --Purpose:
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --ayedubat   07-JUN-2002    The function call,Igs_En_Gen_015.get_academic_cal is replaced with
    --                         Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd to get the academic calendar of the
    --                         given load calendar rather than current academic calendar for the bug fix:2381603
    -- knaraset 27-Feb-2002 Bug- 2245062. This procedure was not considering whether the step is defined or not
    --                      Modified the procedure to consider Approval status and step defined or not etc.
    --nalkumar  14-May-2002 Modified the query stored in the l_step_def_query variable as per the bug# 2364461.
    --Nishikant    01NOV2002      SEVIS Build. Enh Bug#2641905. notification flag was
    --                            being fetched from cursor, now modified to get it by
    --                            calling the function igs_ss_enr_details.get_notification.
    --svanukur    04-jun-03       changed the declaration of the variable  l_step_override_limit
    --                           to refer to igs_en_elgb_ovr_uoo as part of deny/warn behaviour build #2829272
    -- smaddali  8-mar-06       Modified for bug#5091847
    -------------------------------------------------------------------------------------
    CURSOR cur_chk_sp_allowed( p_uoo_id NUMBER) IS
      SELECT special_permission_ind, cal_type, ci_sequence_number
      FROM igs_ps_unit_ofr_opt
      WHERE uoo_id = p_uoo_id;

    CURSOR cur_sp_exists( p_person_id NUMBER, p_uoo_id NUMBER) IS
      SELECT approval_status, Transaction_type
      FROM igs_en_spl_perm
      WHERE student_person_id = p_person_id
        AND uoo_id =p_uoo_id
        AND REQUEST_TYPE = 'SPL_PERM'
        AND transaction_type <> 'WITHDRAWN';

    CURSOR cur_sys_pers_type IS
    SELECT system_type
    FROM igs_pe_person_types
    WHERE person_type_code = p_person_type;

    TYPE step_rec IS RECORD(
      s_enrolment_step_type  igs_en_cpd_ext.s_enrolment_step_type%TYPE ,
      enrolment_cat       igs_en_cpd_ext.enrolment_cat%TYPE,
      s_student_comm_type igs_en_cpd_ext.s_student_comm_type%TYPE,
      enr_method_type     igs_en_cpd_ext.enr_method_type%TYPE,
      step_group_type     igs_lookups_view.step_group_type%TYPE);

    TYPE cur_step_def IS REF CURSOR;

    cur_step_def_var cur_step_def; -- REF cursor variable
    cur_step_def_var_rec step_rec;
    l_step_def_query VARCHAR2(2000);


    l_step_override_limit       igs_en_elgb_ovr_uoo.step_override_limit%TYPE;
    l_spl_perm_rec              cur_sp_exists%ROWTYPE;
    l_sp_allowed                igs_ps_unit_ofr_opt.special_permission_ind%TYPE;
    l_teach_cal_type            igs_ps_unit_ofr_opt.cal_type%TYPE;
    l_teach_ci_sequence_number  igs_ps_unit_ofr_opt.ci_sequence_number%TYPE;
    l_commencement_type         igs_en_cat_prc_dtl.S_STUDENT_COMM_TYPE%TYPE;
    l_enr_method                IGS_EN_METHOD_TYPE.enr_method_type%TYPE;
    l_enrollment_category       igs_en_cat_prc_dtl.enrolment_cat%TYPE;
    l_enrol_cal_type            igs_ca_type.cal_type%TYPE;
    l_enrol_sequence_number     igs_ca_inst_all.sequence_number%TYPE;
    l_system_type               igs_pe_person_types.system_type%TYPE;
    l_acad_cal_type             igs_ca_inst.cal_type%TYPE;
    l_acad_ci_sequence_number   igs_ca_inst.sequence_number%TYPE;
    lv_message                  fnd_new_messages.message_name%TYPE;
          l_acad_start_dt   IGS_CA_INST.start_dt%TYPE;
    l_acad_end_dt     IGS_CA_INST.end_dt%TYPE;
    l_alternate_code    IGS_CA_INST.alternate_code%TYPE;
    l_notification_flag       igs_en_cpd_ext.notification_flag%TYPE;
    l_message                 VARCHAR2(2000);
    l_return_status           VARCHAR2(10);
    l_dummy                   VARCHAR2(200);
        PROCEDURE l_call_audit_proc AS
        BEGIN
      IF p_check_audit = 'Y' THEN
        igs_en_gen_015.check_audit_perm_exists(p_cal_type           =>  p_cal_type           ,
                                               p_ci_sequence_number =>  p_ci_sequence_number ,
                                               p_person_id          =>  p_person_id          ,
                                               p_program_cd         =>  p_program_cd         ,
                                               p_uoo_id             =>  p_uoo_id             ,
                                               p_person_type        =>  p_person_type        ,
                                               p_enr_cat            =>  l_enrollment_category,
                                               p_enr_method         =>  l_enr_method         ,
                                               p_comm_type          =>  l_commencement_type  ,
                                               p_return_status      =>  p_audit_status       ,
                                               p_message_name       =>  p_audit_msg_name);
      END IF;
        END;

  BEGIN
    p_message_name := NULL;
    p_audit_msg_name := NULL;
    p_audit_status := 'AUDIT_NREQ';

    OPEN cur_chk_sp_allowed(p_uoo_id);
    FETCH cur_chk_sp_allowed INTO l_sp_allowed, l_teach_cal_type, l_teach_ci_sequence_number;
    CLOSE cur_chk_sp_allowed;


    -- check if the unit is being added in the intermission period.
    IF NOT IGS_EN_VAL_SUA.ENRP_VAL_SUA_INTRMT(
             p_person_id => p_person_id,
             p_course_cd => p_program_cd ,
             p_cal_type => l_teach_cal_type,
             p_ci_sequence_number =>  l_teach_ci_sequence_number,
             p_message_name => lv_message) THEN
      p_message_name := lv_message;
      p_return_status := 'SPL_ERR';
      RETURN;
    END IF;

    -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
    igs_en_gen_017.enrp_get_enr_method(
       p_enr_method_type => l_enr_method,
       p_error_message   => l_message,
       p_ret_status      => l_return_status);

   IF l_return_status = 'FALSE' THEN
        p_message_name := 'IGS_SS_EN_NOENR_METHOD' ;
        p_return_status := 'SPL_ERR';
        RETURN;
   ELSE

      l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                            p_cal_type                => p_cal_type,
                            p_ci_sequence_number      => p_ci_sequence_number,
                            p_acad_cal_type           => l_acad_cal_type,
                            p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                            p_acad_ci_start_dt        => l_acad_start_dt,
                            p_acad_ci_end_dt          => l_acad_end_dt,
                            p_message_name            => lv_message );



      IF lv_message IS NOT NULL THEN
        p_message_name := lv_message;
        p_return_status := 'SPL_ERR';
        RETURN;
      END IF;


      /* get the enrollment category and commencement type */
      l_enrollment_category := igs_en_gen_003.enrp_get_enr_cat
                                  ( p_person_id => p_person_id,
                                    p_course_cd => p_program_cd,
                                    p_cal_type => l_acad_cal_type, -- Acad cal type
                                    p_ci_sequence_number => l_acad_ci_sequence_number, --Acad sequence number
                                    p_session_enrolment_cat =>NULL,
                                    p_enrol_cal_type => l_enrol_cal_type        ,
                                    p_enrol_ci_sequence_number => l_enrol_sequence_number,
                                    p_commencement_type => l_commencement_type,
                                    p_enr_categories  => l_dummy );

      IF l_commencement_type = 'BOTH' THEN
     /* if both is returned we have to treat it as all */
          l_commencement_type := 'ALL';
      END IF;
   END IF; -- end if get_enr_method


    -- check whether special permission functionality is allowed for the given unit section
    -- i.e. special permission allowed check box is checked/unchecked..
    IF l_sp_allowed = 'N' THEN
      -- Special Permission is not required
      p_return_status :=  'SPL_NREQ';
          l_call_audit_proc;
          RETURN;
    END IF;




  -- get the System Type for the given Person Type.
   OPEN cur_sys_pers_type;
   FETCH cur_sys_pers_type INTO l_system_type;
   CLOSE cur_sys_pers_type;

   -- if the user log on is a student
   IF l_system_type = 'STUDENT' THEN
      l_step_def_query := 'SELECT eru.s_enrolment_step_type, eru.enrolment_cat, eru.s_student_comm_type, eru.enr_method_type, lkv.step_group_type
                             FROM igs_en_cpd_ext eru, igs_lookups_view lkv
                                                 WHERE eru.s_enrolment_step_type = ''SPL_PERM'' AND
                                                 eru.s_enrolment_step_type =lkv.lookup_code AND
                                                 lkv.lookup_type = ''ENROLMENT_STEP_TYPE_EXT'' AND lkv.step_group_type =
                                                 ''UNIT'' AND eru.enrolment_cat = :1  AND eru.enr_method_type = :2
                                                 AND (eru.s_student_comm_type = :3  OR eru.s_student_comm_type = ''ALL'')
                                                 ORDER BY eru.step_order_num';
   OPEN cur_step_def_var FOR l_step_def_query USING l_enrollment_category, l_enr_method, l_commencement_type;

   ELSE
   --IF l_system_type = 'SS_ENROLL_STAFF' THEN -- if the log on user is self service enrollment staff
   -- removed the check so as to prepare the query for person type other than STUDENT and SS_ENROLL_STAFF also

      l_step_def_query := 'SELECT eru.s_enrolment_step_type, eru.enrolment_cat, eru.s_student_comm_type, eru.enr_method_type, lkv.step_group_type
                             FROM igs_en_cpd_ext eru, igs_pe_usr_aval_all uact, igs_lookups_view lkv
                                                 WHERE eru.s_enrolment_step_type = ''SPL_PERM'' AND
                                                 eru.s_enrolment_step_type =lkv.lookup_code AND
                                                 lkv.lookup_type = ''ENROLMENT_STEP_TYPE_EXT'' AND lkv.step_group_type = ''UNIT'' AND
                                                 eru.s_enrolment_step_type = uact.validation(+) AND
                                                 uact.person_type(+) = :1  AND
                                                 NVL(uact.override_ind,''N'') = ''N'' AND
                                                 eru.enrolment_cat = :2  AND
                                                 eru.enr_method_type = :3
                                                 AND ( eru.s_student_comm_type = :4 OR eru.s_student_comm_type = ''ALL'' )
                                                 ORDER BY eru.step_order_num';
   OPEN cur_step_def_var FOR l_step_def_query USING p_person_type, l_enrollment_category, l_enr_method, l_commencement_type;

   END IF;
   --
   -- open the REF cursor for the sql query defined above.
   FETCH cur_step_def_var INTO cur_step_def_var_rec;
   IF cur_step_def_var%NOTFOUND THEN
     -- If Special Permission Step is not defined,
      p_return_status :=  'SPL_NREQ';
          l_call_audit_proc;
          RETURN;
   END IF;
           lv_message := NULL;
           l_notification_flag := igs_ss_enr_details.get_notification(
                                   p_person_type         => p_person_type,
                                   p_enrollment_category => cur_step_def_var_rec.enrolment_cat,
                                   p_comm_type           => cur_step_def_var_rec.s_student_comm_type,
                                   p_enr_method_type     => cur_step_def_var_rec.enr_method_type,
                                   p_step_group_type     => cur_step_def_var_rec.step_group_type,
                                   p_step_type           => cur_step_def_var_rec.s_enrolment_step_type,
                                   p_person_id           => p_person_id,
                                   p_message             => lv_message);
   IF lv_message IS NOT NULL THEN
      p_return_status :=  'SPL_ERR';
      p_message_name  := lv_message;
      RETURN;
   END IF;
   -- even though the step is defined If the notification is WARN
   -- no need to get the special permission from the instructor
   IF l_notification_flag = 'WARN' THEN
      p_return_status :=  'SPL_NREQ';
          l_call_audit_proc;
          RETURN;
   END IF;
   -- check whether the Step is overriden or not
   -- if step is overriden then no need to get the special permission from the instructor
   IF Igs_En_Gen_015.validation_step_is_overridden ('SPL_PERM',
                                                     p_cal_type,
                                                     p_ci_sequence_number ,
                                                     p_person_id ,
                                                     p_uoo_id ,
                                                     l_step_override_limit) THEN
      -- Step is overridden, no special permission is required
      p_return_status :=  'SPL_NREQ';
          l_call_audit_proc;
          RETURN;
   END IF;

    -- check whether student has entered special permission data already
    OPEN cur_sp_exists( p_person_id, p_uoo_id);
    FETCH cur_sp_exists INTO l_spl_perm_rec;
    IF cur_sp_exists%NOTFOUND THEN
      -- Special permission is required
      p_return_status :=  'SPL_REQ';
      CLOSE cur_sp_exists;
          l_call_audit_proc;
          RETURN;
    ELSE
          CLOSE cur_sp_exists;
      IF l_spl_perm_rec.approval_status = 'A' THEN
        p_return_status :=  'SPL_NREQ';
            l_call_audit_proc;
            RETURN;
      ELSIF ( l_spl_perm_rec.transaction_type = 'INS_MI') THEN
          l_call_audit_proc;
          p_return_status :=  'SPL_ERR';
          p_message_name := 'IGS_SS_EN_INS_MORE_INFO' ;
          RETURN;
      ELSIF (l_spl_perm_rec.approval_status = 'I' OR
           l_spl_perm_rec.transaction_type = 'STD_MI' ) THEN
          l_call_audit_proc;
          p_return_status :=  'SPL_ERR';
          p_message_name := 'IGS_SS_EN_STD_MORE_INFO' ;
          RETURN;
      ELSIF l_spl_perm_rec.approval_status = 'D' THEN
        p_return_status :=  'SPL_ERR';
        p_message_name := 'IGS_SS_EN_INS_DENY' ;
            l_call_audit_proc;
            RETURN;
      ELSE
        p_message_name := 'IGS_SS_DENY_SPL_PERMIT';
        p_return_status :=  'SPL_ERR';
            l_call_audit_proc;
            RETURN;
      END IF;
    END IF;

  END check_spl_perm_exists;

  PROCEDURE check_audit_perm_exists(
                                 p_cal_type             IN VARCHAR2,
                                 p_ci_sequence_number   IN NUMBER,
                                 p_person_id            IN  NUMBER,
                                 p_program_cd           IN VARCHAR2,
                                 p_uoo_id               IN  NUMBER,
                                 p_person_type          IN VARCHAR2,
                                                                 p_enr_cat          IN VARCHAR2,
                                                                 p_enr_method       IN VARCHAR2,
                                                                 p_comm_type        IN VARCHAR2,
                                 p_return_status     OUT NOCOPY VARCHAR2,
                                 p_message_name   OUT NOCOPY VARCHAR2
  ) AS
   ------------------------------------------------------------------------------------
    --Created by  : Annamalai (Oracle, IDC)
    --Date created: 28-OCT-2002
    --
    --Purpose: To check for Audit Permissons
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --Nishikant    01NOV2002      SEVIS Build. Enh Bug#2641905. notification flag was
    --                            being fetched from cursor, now modified to get it by
    --                            calling the function igs_ss_enr_details.get_notification.
    -- smaddali  8-mar-06       Modified for bug#5091847
    -------------------------------------------------------------------------------------
    CURSOR c_chk_audit_allowed( p_uoo_id NUMBER) IS
      SELECT NVL(auditable_ind, 'N'), NVL(audit_permission_ind, 'N')
      FROM igs_ps_unit_ofr_opt
      WHERE uoo_id = p_uoo_id;


    CURSOR c_audit_perm_exists( p_person_id NUMBER, p_uoo_id NUMBER) IS
      SELECT approval_status, transaction_type
      FROM igs_en_spl_perm
      WHERE student_person_id = p_person_id
        AND uoo_id =p_uoo_id
        AND REQUEST_TYPE = 'AUDIT_PERM'
        AND transaction_type <> 'WITHDRAWN';


    CURSOR c_sys_pers_type (cp_person_type igs_pe_person_types.person_type_code%TYPE) IS
    SELECT system_type
    FROM igs_pe_person_types
    WHERE person_type_code = cp_person_type;


        CURSOR c_stud_step_def(cp_step IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE,
                          cp_enrollment_Category IGS_EN_CAT_PRC_DTL.enrolment_cat%TYPE,
                                          cp_enr_method IGS_EN_CAT_PRC_DTL.ENR_METHOD_TYPE%TYPE,
                                          cp_commencement_type  IGS_EN_CAT_PRC_DTL.S_STUDENT_COMM_TYPE%TYPE
                                          ) IS
        SELECT
          eru.s_enrolment_step_type, eru.enrolment_cat, eru.s_student_comm_type, eru.enr_method_type, lkv.step_group_type --modified by nishikant
        FROM
          igs_en_cpd_ext eru,
          igs_lookups_view lkv
        WHERE
          eru.s_enrolment_step_type = cp_step AND
          eru.s_enrolment_step_type =lkv.lookup_code AND
          lkv.lookup_type = 'ENROLMENT_STEP_TYPE_EXT' AND
          lkv.step_group_type ='UNIT' AND
          eru.enrolment_cat = cp_enrollment_category AND
          eru.enr_method_type = cp_enr_method AND
          (eru.s_student_comm_type = cp_commencement_type OR eru.s_student_comm_type = 'ALL')
        ORDER BY eru.step_order_num;

        CURSOR c_staff_step_def(cp_step IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE,
                          cp_person_type igs_pe_person_types.PERSON_TYPE_CODE%TYPE,
                          cp_enrollment_Category IGS_EN_CAT_PRC_DTL.enrolment_cat%TYPE,
                                          cp_enr_method IGS_EN_CAT_PRC_DTL.ENR_METHOD_TYPE%TYPE,
                                          cp_commencement_type  IGS_EN_CAT_PRC_DTL.S_STUDENT_COMM_TYPE%TYPE
                                          ) IS
        SELECT
          eru.s_enrolment_step_type, eru.enrolment_cat, eru.s_student_comm_type, eru.enr_method_type, lkv.step_group_type --modified by nishikant
        FROM
          igs_en_cpd_ext eru,
          igs_pe_usr_aval_all uact,
          igs_lookups_view lkv
        WHERE
          eru.s_enrolment_step_type = cp_step AND
          eru.s_enrolment_step_type =lkv.lookup_code AND
          lkv.lookup_type = 'ENROLMENT_STEP_TYPE_EXT' AND
          lkv.step_group_type = 'UNIT' AND
          eru.s_enrolment_step_type = uact.validation(+) AND
          uact.person_type(+) = cp_person_type AND
          NVL(uact.override_ind,'N') = 'N' AND
          eru.enrolment_cat = cp_enrollment_category AND
          eru.enr_method_type = cp_enr_method                                                    AND
          ( eru.s_student_comm_type = cp_commencement_type OR eru.s_student_comm_type = 'ALL' )
        ORDER BY eru.step_order_num;

        v_ap_allowed  igs_ps_unit_ofr_opt.AUDITABLE_IND%TYPE;
        v_ap_required igs_ps_unit_ofr_opt.AUDIT_PERMISSION_IND%TYPE;
        v_staff_step_def_rec c_staff_step_def%ROWTYPE;
        v_stud_step_def_rec      c_stud_step_def%ROWTYPE;
        v_system_type  igs_pe_person_types.SYSTEM_TYPE%TYPE;
        v_step_override_limit   igs_en_elgb_ovr_step.step_override_limit%TYPE;
        v_audit_perm_rec  c_audit_perm_exists%ROWTYPE;
        l_notification_flag       igs_en_cpd_ext.notification_flag%TYPE;

  BEGIN
    p_message_name := NULL;
    -- check whether Audit special permission functionality is allowed for the given unit section
    -- i.e. Audit allowed check box is checked/unchecked..
    OPEN c_chk_audit_allowed(p_uoo_id);
    FETCH c_chk_audit_allowed INTO v_ap_allowed,v_ap_required;
    CLOSE c_chk_audit_allowed;

        IF v_ap_allowed = 'N' THEN
      -- The unit is not auditable hence show an error message
      p_return_status :=  'AUDIT_ERR';
          p_message_name := 'IGS_EN_CANNOT_AUDIT';
          RETURN;
    END IF;

        IF  v_ap_allowed = 'Y' AND v_ap_required = 'N' THEN
      p_return_status :=  'AUDIT_NREQ';
          RETURN;
        END IF;



  -- get the System Type for the given Person Type.
   OPEN c_sys_pers_type(p_person_type);
   FETCH c_sys_pers_type INTO v_system_type;
   CLOSE c_sys_pers_type;

   -- if the user log on is a student
   IF v_system_type = 'STUDENT' THEN

           OPEN c_stud_step_def('AUDIT_PERM',
                                 p_enr_cat     ,
                                                         p_enr_method,
                                                         p_comm_type );
           FETCH c_stud_step_def INTO v_stud_step_def_rec;
           IF c_stud_step_def%NOTFOUND THEN
             -- If Special Permission Step is not defined,
                p_return_status :=  'AUDIT_NREQ';
                RETURN;
           END IF;
           p_message_name := NULL;
           l_notification_flag := NULL;
           l_notification_flag := igs_ss_enr_details.get_notification(
                                   p_person_type         => p_person_type,
                                   p_enrollment_category => v_stud_step_def_rec.enrolment_cat,
                                   p_comm_type           => v_stud_step_def_rec.s_student_comm_type,
                                   p_enr_method_type     => v_stud_step_def_rec.enr_method_type,
                                   p_step_group_type     => v_stud_step_def_rec.step_group_type,
                                   p_step_type           => v_stud_step_def_rec.s_enrolment_step_type,
                                   p_person_id           => p_person_id ,
                                   p_message             => p_message_name);
           IF p_message_name IS NOT NULL THEN
                 p_return_status := 'AUDIT_ERR';
                 RETURN;
           END IF;
           -- even though the step is defined If the notification is WARN
           -- no need to get the special permission from the instructor
           IF l_notification_flag = 'WARN' THEN
              p_return_status :=  'AUDIT_NREQ';
                  RETURN;
           END IF;

   ELSE

   --IF l_system_type = 'SS_ENROLL_STAFF' THEN -- if the log on user is self service enrollment staff
   -- removed the check so as to prepare the query for person type other than STUDENT and SS_ENROLL_STAFF also
   -- open the cursor for the sql query defined above.

           -- open the REF cursor for the sql query defined above.
           OPEN c_staff_step_def('AUDIT_PERM',
                                 p_person_type,
                                 p_enr_cat     ,
                                                         p_enr_method,
                                                         p_comm_type );
           FETCH c_staff_step_def INTO v_staff_step_def_rec;
           IF c_staff_step_def%NOTFOUND THEN
             -- If Special Permission Step is not defined,
              p_return_status :=  'AUDIT_NREQ';
                  RETURN;
           END IF;

           p_message_name := NULL;
           l_notification_flag := NULL;
           l_notification_flag := igs_ss_enr_details.get_notification(
                                   p_person_type         => p_person_type,
                                   p_enrollment_category => v_staff_step_def_rec.enrolment_cat,
                                   p_comm_type           => v_staff_step_def_rec.s_student_comm_type,
                                   p_enr_method_type     => v_staff_step_def_rec.enr_method_type,
                                   p_step_group_type     => v_staff_step_def_rec.step_group_type,
                                   p_step_type           => v_staff_step_def_rec.s_enrolment_step_type,
                                   p_person_id           => p_person_id ,
                                   p_message             => p_message_name);
           IF p_message_name IS NOT NULL THEN
                 p_return_status := 'AUDIT_ERR';
                 RETURN;
           END IF;
           -- even though the step is defined If the notification is WARN
           -- no need to get the special permission from the instructor
           IF l_notification_flag = 'WARN' THEN
              p_return_status :=  'AUDIT_NREQ';
                  RETURN;
           END IF;

   END IF;
   --

   -- check whether the Step is overriden or not
   -- if step is overriden then no need to get the special permission from the instructor
   IF Igs_En_Gen_015.validation_step_is_overridden ('AUDIT_PERM',
                                                     p_cal_type,
                                                     p_ci_sequence_number ,
                                                     p_person_id ,
                                                     p_uoo_id ,
                                                     v_step_override_limit) THEN
      -- Step is overridden, no special permission is required
      p_return_status :=  'AUDIT_NREQ';
          RETURN;
   END IF;

    -- check whether student has entered special permission data already
    OPEN c_audit_perm_exists( p_person_id, p_uoo_id);
    FETCH c_audit_perm_exists INTO v_audit_perm_rec;
    IF c_audit_perm_exists%NOTFOUND THEN
      -- Special permission is required
      p_return_status :=  'AUDIT_REQ';
      CLOSE c_audit_perm_exists;
          RETURN;
    ELSE
          CLOSE c_audit_perm_exists;
      IF v_audit_perm_rec.approval_status = 'A' THEN
        p_return_status :=  'AUDIT_NREQ';
            RETURN;
      ELSIF ( v_audit_perm_rec.transaction_type = 'INS_MI' ) THEN
        p_return_status :=  'AUDIT_ERR';
        p_message_name := 'IGS_EN_AU_INS_MORE_INFO' ;
            RETURN;
      ELSIF (v_audit_perm_rec.approval_status = 'I' OR
             v_audit_perm_rec.transaction_type = 'STD_MI' ) THEN
        p_return_status :=  'AUDIT_ERR';
        p_message_name := 'IGS_EN_AU_STD_MORE_INFO' ;
            RETURN;
      ELSIF v_audit_perm_rec.approval_status = 'D' THEN
        p_return_status :=  'AUDIT_ERR';
        p_message_name := 'IGS_EN_AU_INS_DENY' ;
            RETURN;
      END IF;
    END IF;

  END check_audit_perm_exists;

  FUNCTION eval_core_unit_drop
  (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_step_type                    IN     VARCHAR2,
    p_term_cal                     IN     VARCHAR2,
    p_term_sequence_number         IN     NUMBER,
    p_deny_warn                    OUT NOCOPY VARCHAR2,
    p_enr_method                 IN VARCHAR2
  )
  ------------------------------------------------------------------
  --Created by  : Parul Tandon, Oracle IDC
  --Date created: 01-OCT-2003
  --
  --Purpose: This function checks whether the core unit attempt can
  --be dropped.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  RETURN VARCHAR2 IS

  --
  --  Cursor to find the Core Indicator associated with a Unit Attempt
  --
  CURSOR cur_get_core_ind(cp_person_id          igs_en_su_attempt.person_id%TYPE,
                          cp_course_cd          igs_en_su_attempt.course_cd%TYPE,
                          cp_uoo_id             igs_en_su_attempt.uoo_id%TYPE)
  IS
    SELECT   core_indicator_code
    FROM     igs_en_su_attempt
    WHERE    person_id = cp_person_id
    AND      course_cd = cp_course_cd
    AND      uoo_id    = cp_uoo_id;

  l_core_indicator_code         igs_en_su_attempt.core_indicator_code%TYPE;
  l_person_type                 igs_pe_person_types.person_type_code%TYPE;
  l_enrollment_category         igs_en_cat_prc_step.enrolment_cat%TYPE;
  l_comm_type                   igs_en_cat_prc_step.s_student_comm_type%TYPE;
  l_enr_method_type             igs_en_cat_prc_step.enr_method_type%TYPE;
  l_acad_cal_type               igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;
  l_step_override_limit         NUMBER;
  l_message                     VARCHAR2(100);
  l_ret_status                  VARCHAR2(10);
  l_en_cal_type                 igs_ca_inst.cal_type%TYPE;
  l_en_ci_seq_num               igs_ca_inst.sequence_number%TYPE;
  l_dummy                       VARCHAR2(200);

  BEGIN

    --  Check whether the profile is set or not
    IF NVL(fnd_profile.value('IGS_EN_CORE_VAL'),'N') = 'N' THEN
       RETURN 'TRUE';
    END IF;

    --  Get the person type
    l_person_type := igs_en_gen_008.enrp_get_person_type(p_course_cd);

    --  Get the superior academic calendar instance
    igs_en_gen_015.get_academic_cal
    (
     p_person_id,
     p_course_cd,
     l_acad_cal_type,
     l_acad_ci_sequence_number,
     l_message,
     SYSDATE
    );

    --  Get the enrollment category and commencement type
    l_enrollment_category:=igs_en_gen_003.enrp_get_enr_cat(
                                                          p_person_id,
                                                          p_course_cd,
                                                          l_acad_cal_type,
                                                          l_acad_ci_sequence_number,
                                                          NULL,
                                                          l_en_cal_type,
                                                          l_en_ci_seq_num,
                                                          l_comm_type,
                                                          l_dummy);

    IF p_enr_method IS NULL THEN
	--- Get the enrollment method
	igs_en_gen_017.enrp_get_enr_method(l_enr_method_type,l_message,l_ret_status);
    ELSE
	l_enr_method_type := p_enr_method;
    END IF;
    -- Get the value of Deny/Warn Flag for unit step 'DROP_CORE'
    p_deny_warn := igs_ss_enr_details.get_notification(
                        p_person_type            => l_person_type,
                        p_enrollment_category    => l_enrollment_category,
                        p_comm_type              => l_comm_type,
                        p_enr_method_type        => l_enr_method_type,
                        p_step_group_type        => 'UNIT',
                        p_step_type              => 'DROP_CORE',
                        p_person_id              => p_person_id,
                        p_message                => l_message
                        ) ;

    -- If the unit step is not defined return TRUE
    IF p_deny_warn IS NULL THEN
          RETURN 'TRUE';
    END IF;

    -- Get the value of core indicator for unit attempt
    OPEN cur_get_core_ind(p_person_id,p_course_cd,p_uoo_id);
    FETCH cur_get_core_ind INTO l_core_indicator_code;
    CLOSE cur_get_core_ind;

    --  If the unit is not a Core Unit, return TRUE. If the unit is a
    --  core unit and the unit step DROP_CORE is overridden for the
    --  student in context, return TRUE else return FALSE.
    IF l_core_indicator_code = 'CORE' THEN
      IF igs_en_gen_015.validation_step_is_overridden
                       (
                        'DROP_CORE',
                        p_term_cal,
                        p_term_sequence_number,
                        p_person_id,
                        p_uoo_id,
                        l_step_override_limit
                        )
      THEN
        RETURN 'TRUE';
      ELSE
        RETURN 'FALSE';
      END IF;
    ELSE
      RETURN 'TRUE';
    END IF;

  END eval_core_unit_drop;

PROCEDURE  get_curr_acad_term_cal (
    p_acad_cal_type       IN VARCHAR,
    p_effective_dt        IN    DATE,
    p_load_cal_type       OUT NOCOPY   VARCHAR2,
    p_load_ci_seq_num     OUT NOCOPY   NUMBER,
    p_load_ci_alt_code    OUT NOCOPY   VARCHAR2,
    p_load_ci_start_dt    OUT NOCOPY   DATE,
    p_load_ci_end_dt      OUT NOCOPY   DATE,
    p_message_name        OUT NOCOPY   VARCHAR2) AS
------------------------------------------------------------------
  --Created by  : Susmitha Tutta, Oracle IDC
  --Date created: 19-NOV-2003
  --
  --Purpose:  To find the Effective Load Calendar Instance given a Academic Calendar Type and effective date
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- LOCAL VARIABLES
  cst_active                        CONSTANT VARCHAR2(10) := 'ACTIVE';
  cst_load                          CONSTANT VARCHAR2(10) := 'LOAD';
  l_daiv_rec_found                  BOOLEAN;
  l_cal_type                        IGS_EN_STDNT_PS_ATT.CAL_TYPE%TYPE;
  l_current_load_ci_alt_code IGS_CA_INST.ALTERNATE_CODE%TYPE;
  l_current_load_ci_start_dt IGS_CA_INST.START_DT%TYPE;
  l_current_load_ci_end_dt   IGS_CA_INST.END_DT%TYPE;
  l_current_load_cal_type           IGS_CA_INST.CAL_TYPE%TYPE;
  l_current_load_sequence_number    IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
  l_other_detail                    VARCHAR2(255);
  l_effective_dt                    DATE;

    --
    --  CURSOR TO FETCH LOAD EFFECTIVE DATE ALIAS.
    --
    CURSOR
    c_s_enr_cal_conf IS
      SELECT  secc.load_effect_dt_alias
      FROM    igs_en_cal_conf secc
      WHERE   secc.s_control_num = 1;

    L_LOAD_EFFECT_DT_ALIAS IGS_EN_CAL_CONF.LOAD_EFFECT_DT_ALIAS%TYPE;

    --
    --  CURSOR TO FETCH CALENDAR TYPE INSTANCES
    --
    CURSOR c_cal_type_instance (cp_cal_type         igs_ca_inst.cal_type%TYPE) is
      SELECT   ci.cal_type,
               ci.sequence_number,
	       ci.alternate_code,
               ci.start_dt,
               ci.end_dt
      FROM     igs_ca_type ct,
               igs_ca_inst ci,
               igs_ca_stat cs,
               igs_ca_inst_rel cir
      WHERE    cs.s_cal_status = cst_active
      AND      ci.cal_status = cs.cal_status
      AND      ct.s_cal_cat = cst_load
      AND      ci.cal_type = ct.cal_type
      AND      CIR.SUB_CAL_TYPE = CI.CAL_TYPE
      AND      cir.sub_ci_sequence_number =ci.sequence_number
      AND      cir.sup_cal_type = cp_cal_type
      ORDER BY ci.start_dt DESC;

    --
    --  CURSOR TO FETCH THE DATE ALIAS
    --
    CURSOR c_dai_v (cp_cal_type             igs_ca_da_inst_v.cal_type%TYPE,
                    cp_ci_sequence_number   igs_ca_da_inst_v.ci_sequence_number%TYPE,
                    cp_load_effect_dt_alias igs_en_cal_conf.load_effect_dt_alias%TYPE) IS
      SELECT   daiv.alias_val
      FROM     igs_ca_da_inst_v daiv
      WHERE    daiv.cal_type = cp_cal_type
      AND      daiv.ci_sequence_number = cp_ci_sequence_number
      AND      daiv.dt_alias = cp_load_effect_dt_alias;

  l_load_alias_value igs_ca_da_inst.absolute_val%TYPE;


  BEGIN

    --
    -- DETERMINE THE 'CURRENT' LOAD CALENDAR INSTANCE BASED ON THE LOAD EFFECTIVE
    -- DATE ALIAS FROM THE ENROLMENT CALENDAR CONFIGURATION. IF THIS DATE ALIAS
    -- CAN'T BE LOCATED THEN THE LATEST CALENDAR INSTANCE WHERE START_DT/END_DT
    -- ENCOMPASS THE EFFECTIVE DT IS DEEMED CURRENT
    --
    OPEN c_s_enr_cal_conf;
    FETCH c_s_enr_cal_conf INTO l_load_effect_dt_alias;
    IF c_s_enr_cal_conf%NOTFOUND THEN
       CLOSE c_s_enr_cal_conf;
       p_message_name := 'IGS_EN_NO_SECC_REC_FOUND';
       RETURN;
    END IF;
    CLOSE c_s_enr_cal_conf;
    --
    -- INITIALISE THE LOCAL VARIABLES
    --
    l_current_load_cal_type := NULL;
    l_current_load_sequence_number := NULL;
    l_current_load_ci_start_dt := NULL;
    l_current_load_ci_end_dt := NULL;
    l_current_load_ci_alt_code := NULL;

    --
    -- NOW LOOP THROUGH THE CAL TYPE INSTANCE RECORDS
    --
    FOR rec_cal_type_instance IN c_cal_type_instance (p_acad_cal_type)
    LOOP
        --
        -- ATTEMPT TO FIND LOAD EFFECTIVE DATE ALIAS AGAINST THE CALE
        --
        l_daiv_rec_found := FALSE;
        FOR rec_dai_v IN c_dai_v (rec_cal_type_instance.cal_type,
                                  rec_cal_type_instance.sequence_number,
                                  l_load_effect_dt_alias)
        LOOP
            l_daiv_rec_found := TRUE;
            IF (p_effective_dt >= rec_dai_v.alias_val) THEN
                l_current_load_cal_type := rec_cal_type_instance.cal_type ;
                l_current_load_sequence_number := rec_cal_type_instance.sequence_number;
                l_current_load_ci_start_dt := rec_cal_type_instance.start_dt;
                l_current_load_ci_end_dt := rec_cal_type_instance.end_dt;
                l_current_load_ci_alt_code := rec_cal_type_instance.alternate_code;
            END IF;
        END LOOP;
        IF NOT l_daiv_rec_found  THEN
           IF (p_effective_dt >= rec_cal_type_instance.start_dt) AND
              (p_effective_dt <= rec_cal_type_instance.end_dt) THEN
                  l_current_load_cal_type := rec_cal_type_instance.cal_type ;
                  l_current_load_sequence_number := rec_cal_type_instance.sequence_number;
                  l_current_load_ci_start_dt := rec_cal_type_instance.start_dt;
                  l_current_load_ci_end_dt := rec_cal_type_instance.end_dt;
                  l_current_load_ci_alt_code := rec_cal_type_instance.alternate_code;
            END IF;
        END IF;
        IF l_current_load_cal_type IS NOT NULL THEN
           EXIT;
        END IF;
    END LOOP;

    IF l_current_load_cal_type IS NULL THEN
       p_load_cal_type    := NULL;
       p_load_ci_seq_num  := NULL;
       p_load_ci_alt_code   := NULL ;
       p_load_ci_start_dt   := NULL;
       p_load_ci_end_dt     := NULL;
       p_message_name := 'IGS_EN_LOAD_CAL_NOT_FOUND';
    ELSE
      p_load_cal_type     := l_current_load_cal_type;
      p_load_ci_seq_num   := l_current_load_sequence_number;
      p_load_ci_alt_code   := l_current_load_ci_alt_code ;
      p_load_ci_start_dt   := l_current_load_ci_start_dt;
      p_load_ci_end_dt     := l_current_load_ci_end_dt  ;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_015.GET_CURR_ACAD_TERM_CAL');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END get_curr_acad_term_cal;

    PROCEDURE  get_curr_term_for_schedule(
    p_acad_cal_type       IN VARCHAR,
    p_effective_dt        IN    DATE,
    p_load_cal_type       OUT NOCOPY   VARCHAR2,
    p_load_ci_seq_num     OUT NOCOPY   NUMBER,
    p_load_ci_alt_code    OUT NOCOPY   VARCHAR2,
    p_load_ci_start_dt    OUT NOCOPY   DATE,
    p_load_ci_end_dt      OUT NOCOPY   DATE,
    p_message_name        OUT NOCOPY   VARCHAR2) AS
------------------------------------------------------------------
  --Created by  : RVANGALA, Oracle IDC
  --Date created: 16-JUL-2004
  --
  --Purpose:  To find the current Term Calendar for display of terms
  -- on the Schedule page
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- LOCAL VARIABLES
  cst_active                        CONSTANT VARCHAR2(10) := 'ACTIVE';
  cst_load                          CONSTANT VARCHAR2(10) := 'LOAD';
  l_cal_type                        IGS_EN_STDNT_PS_ATT.CAL_TYPE%TYPE;
  l_current_load_ci_alt_code IGS_CA_INST.ALTERNATE_CODE%TYPE;
  l_current_load_ci_start_dt IGS_CA_INST.START_DT%TYPE;
  l_current_load_ci_end_dt   IGS_CA_INST.END_DT%TYPE;
  l_current_load_cal_type           IGS_CA_INST.CAL_TYPE%TYPE;
  l_current_load_sequence_number    IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
  l_other_detail                    VARCHAR2(255);
  l_effective_dt                    DATE;

    --
    --  CURSOR TO FETCH LOAD EFFECTIVE DATE ALIAS.
    --
    CURSOR
    c_s_enr_cal_conf IS
      SELECT  secc.load_effect_dt_alias
      FROM    igs_en_cal_conf secc
      WHERE   secc.s_control_num = 1;

    L_LOAD_EFFECT_DT_ALIAS IGS_EN_CAL_CONF.LOAD_EFFECT_DT_ALIAS%TYPE;

	CURSOR c_acad_cal_instances (cp_acad_cal_type         igs_ca_inst.cal_type%TYPE) IS
	SELECT cal_type, sequence_number
	FROM IGS_CA_INST
	WHERE CAL_TYPE = cp_acad_cal_type
	ORDER BY start_dt DESC;

	lb_found_load_rec Boolean;

    --
    --  CURSOR TO FETCH CALENDAR TYPE INSTANCES
    --
    CURSOR c_cal_type_instance (cp_acad_cal_type         igs_ca_inst.cal_type%TYPE,
	                            cp_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE) IS
      SELECT   ci.cal_type,
               ci.sequence_number,
	       ci.alternate_code,
               ci.start_dt,
               ci.end_dt
      FROM     igs_ca_type ct,
               igs_ca_inst ci,
               igs_ca_stat cs,
               igs_ca_inst_rel cir
      WHERE    cs.s_cal_status = cst_active
      AND      ci.cal_status = cs.cal_status
      AND      ct.s_cal_cat = cst_load
      AND      ci.cal_type = ct.cal_type
      AND      CIR.SUB_CAL_TYPE = CI.CAL_TYPE
      AND      cir.sub_ci_sequence_number =ci.sequence_number
      AND      cir.sup_cal_type = cp_acad_cal_type
	  AND      cir.sup_ci_sequence_number = cp_acad_ci_sequence_number
      ORDER BY ci.start_dt DESC;

    --
    --  CURSOR TO FETCH THE DATE ALIAS
    --
    CURSOR c_dai_v (cp_cal_type             igs_ca_da_inst_v.cal_type%TYPE,
                    cp_ci_sequence_number   igs_ca_da_inst_v.ci_sequence_number%TYPE,
                    cp_load_effect_dt_alias igs_en_cal_conf.load_effect_dt_alias%TYPE) IS
      SELECT   daiv.alias_val
      FROM     igs_ca_da_inst_v daiv
      WHERE    daiv.cal_type = cp_cal_type
      AND      daiv.ci_sequence_number = cp_ci_sequence_number
      AND      daiv.dt_alias = cp_load_effect_dt_alias;

   -- Cursor to fetch load calendar with earliest start date
   -- and whose start_date and end_date encompass the SYSDATE
    CURSOR c_first_cal_instance (cp_cal_type         igs_ca_inst.cal_type%TYPE) IS
      SELECT   ci.cal_type,
               ci.sequence_number,
	       ci.alternate_code,
               ci.start_dt,
               ci.end_dt
      FROM     igs_ca_type ct,
               igs_ca_inst ci,
               igs_ca_stat cs,
               igs_ca_inst_rel cir
      WHERE    cs.s_cal_status = cst_active
      AND      ci.cal_status = cs.cal_status
      AND      ct.s_cal_cat = cst_load
      AND      ci.cal_type = ct.cal_type
      AND      CIR.SUB_CAL_TYPE = CI.CAL_TYPE
      AND      cir.sub_ci_sequence_number =ci.sequence_number
      AND      cir.sup_cal_type = cp_cal_type
      AND      ci.start_dt <= SYSDATE
	  AND      ci.end_dt   >= SYSDATE
  	  ORDER BY ci.start_dt;

  l_load_alias_value igs_ca_da_inst.absolute_val%TYPE;

  BEGIN

    --fetch load effective date alias from enrollment calendar configuration
    OPEN c_s_enr_cal_conf;
    FETCH c_s_enr_cal_conf INTO l_load_effect_dt_alias;
    IF c_s_enr_cal_conf%NOTFOUND THEN
       CLOSE c_s_enr_cal_conf;
       p_message_name := 'IGS_EN_NO_SECC_REC_FOUND';
       RETURN;
    END IF;
    CLOSE c_s_enr_cal_conf;
    --
    -- initialise the local variables
    --
    l_current_load_cal_type := NULL;
    l_current_load_sequence_number := NULL;
    l_current_load_ci_start_dt := NULL;
    l_current_load_ci_end_dt := NULL;
    l_current_load_ci_alt_code := NULL;

    lb_found_load_rec := FALSE;


	FOR rec_acad_cal_instances in c_acad_cal_instances( p_acad_cal_type)
	LOOP
             --
             -- now loop through the cal type instance records
             -- starting the load calendar instances with the latest start date
             FOR rec_cal_type_instance IN c_cal_type_instance (rec_acad_cal_instances.cal_type, rec_acad_cal_instances.sequence_number)
             LOOP
                 --
                 -- attempt to find load effective date alias against the load cal isntance
                 --

                 FOR rec_dai_v IN c_dai_v (rec_cal_type_instance.cal_type,
                                           rec_cal_type_instance.sequence_number,
                                           l_load_effect_dt_alias)
                 LOOP

                     IF (p_effective_dt >= rec_dai_v.alias_val) THEN
                         l_current_load_cal_type := rec_cal_type_instance.cal_type ;
                         l_current_load_sequence_number := rec_cal_type_instance.sequence_number;
                         l_current_load_ci_start_dt := rec_cal_type_instance.start_dt;
                         l_current_load_ci_end_dt := rec_cal_type_instance.end_dt;
                         l_current_load_ci_alt_code := rec_cal_type_instance.alternate_code;
                     END IF;
                 END LOOP;

                 --if a load calendar instance with satisfying date alias value is found
                 IF l_current_load_cal_type IS NOT NULL THEN
                      lb_found_load_rec := TRUE;
                      EXIT;
                 END IF;
             END LOOP;

        -- if the term calendar has been determined in the inner loop then
	-- exit out of the this loop as well.
	IF lb_found_load_rec THEN
	     EXIT;
	END IF;

    END LOOP;

    IF l_current_load_cal_type IS NULL THEN
      --new logic goes in here
      --fetch the load calendar instance with the earliest start date and
      --whose start_date<SYSDATE and end_date>SYSDATE
      OPEN c_first_cal_instance(p_acad_cal_type);
      FETCH c_first_cal_instance INTO  p_load_cal_type,p_load_ci_seq_num,
                                       p_load_ci_alt_code,
                                       p_load_ci_start_dt,p_load_ci_end_dt;

       --if no load calendar is found whose start_date<SYSDATE
       --and end_date>SYSDATE
       IF c_first_cal_instance%NOTFOUND THEN
           p_load_cal_type    := NULL;
           p_load_ci_seq_num  := NULL;
           p_load_ci_alt_code   := NULL ;
           p_load_ci_start_dt   := NULL;
           p_load_ci_end_dt     := NULL;
           p_message_name := 'IGS_EN_LOAD_CAL_NOT_FOUND';
       END IF;
       CLOSE c_first_cal_instance;

    ELSE
      p_load_cal_type     := l_current_load_cal_type;
      p_load_ci_seq_num   := l_current_load_sequence_number;
      p_load_ci_alt_code   := l_current_load_ci_alt_code ;
      p_load_ci_start_dt   := l_current_load_ci_start_dt;
      p_load_ci_end_dt     := l_current_load_ci_end_dt  ;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_015.GET_CURR_ACAD_TERM_CAL');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END get_curr_term_for_schedule;

  PROCEDURE get_academic_cal_poo_chg
  (
    p_person_id                       IN     NUMBER,
    p_course_cd                       IN     VARCHAR2,
    p_acad_cal_type                  IN OUT NOCOPY     VARCHAR2,
    p_acad_ci_sequence_number        OUT NOCOPY     NUMBER,
    p_message                        OUT NOCOPY     VARCHAR2,
    p_effective_dt                   IN      DATE
  ) AS
    -- Determine the academic calendar instance based on parameter p_acad_cal_type.
    --
    --  Parameters Description:
    --
    --  p_person_id                     -> Person Identifier
    --  p_course_cd                     -> Program code
    --  p_acad_cal_type                 -> IN Out NOCOPY parameter carrying the academic calendar type
    --  p_acad_ci_sequence_number       -> Out NOCOPY parameter carrying academic calendar sequence number
    --
    --
    --  local variable used in the program unit
    --
    NO_SECC_RECORD_FOUND              EXCEPTION;
    cst_active                        CONSTANT VARCHAR2(10) := 'ACTIVE';
    cst_load                          CONSTANT VARCHAR2(10) := 'LOAD';
    cst_academic                      CONSTANT VARCHAR2(10) := 'ACADEMIC';
    l_daiv_rec_found                  BOOLEAN;
    l_cal_type                        igs_en_stdnt_ps_att.cal_type%TYPE;
    l_load_effect_dt_alias            igs_en_cal_conf.load_effect_dt_alias%TYPE;
    l_current_load_cal_type           igs_ca_inst.cal_type%TYPE;
    l_current_load_sequence_number    igs_ca_inst.sequence_number%TYPE;
    l_current_acad_cal_type           igs_ca_inst.cal_type%TYPE;
    l_current_acad_sequence_number    igs_ca_inst.sequence_number%TYPE;
    l_other_detail                    VARCHAR2(255);
    l_effective_dt                    DATE;
    --
    --  Cursor to fetch student course attempt calendar type
    --
    CURSOR c_stu_crs_atmpt (cp_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                            cp_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE) IS
      SELECT  sca.cal_type
      FROM    igs_en_stdnt_ps_att sca
      WHERE   sca.person_id = cp_person_id
      AND     sca.course_cd = cp_course_cd;
    --
    --  Cursor to fetch load effective date alias.
    --
    CURSOR c_s_enr_cal_conf IS
      SELECT  secc.load_effect_dt_alias
      FROM    igs_en_cal_conf secc
      WHERE   secc.s_control_num = 1;
    --
    --  Cursor to fetch calendar instances
    --
    CURSOR c_cal_instance (cp_cal_type      igs_ca_inst.cal_type%TYPE,
                           cp_effective_dt  igs_ca_inst.start_dt%TYPE) IS
      SELECT   ci.cal_type,
               ci.sequence_number
      FROM     igs_ca_inst ci,
               igs_ca_stat cs
      WHERE    ci.cal_type = cp_cal_type
      AND      ci.start_dt <= cp_effective_dt
      AND      ci.end_dt >= cp_effective_dt
      AND      cs.cal_status = ci.cal_status
      AND      cs.s_cal_status = cst_active
      ORDER BY ci.start_dt DESC;
    --
    --  Cursor to fetch calendar type instances
    --
    CURSOR c_cal_type_instance (cp_cal_type         igs_ca_inst.cal_type%TYPE,
                                cp_sequence_number  igs_ca_inst.sequence_number%TYPE) IS
      SELECT   ci.cal_type,
               ci.sequence_number,
               ci.start_dt,
               ci.end_dt
      FROM     igs_ca_type ct,
               igs_ca_inst ci,
               igs_ca_stat cs,
               igs_ca_inst_rel cir
      WHERE    ct.closed_ind = 'N'
      AND      cs.s_cal_status = cst_active
      AND      ci.cal_status = cs.cal_status
      AND      ct.s_cal_cat = cst_load
      AND      ci.cal_type = ct.cal_type
      AND      cir.sub_cal_type = ci.cal_type
      AND      cir.sub_ci_sequence_number =ci.sequence_number
      AND      cir.sup_cal_type = cp_cal_type
      AND      cir.sup_ci_sequence_number = cp_sequence_number
      AND EXISTS ( SELECT   1     FROM     igs_ca_inst_rel cir,
                                                igs_ca_type ct
                                       WHERE    cir.sup_cal_type = cp_cal_type
                                       AND      cir.sup_ci_sequence_number = cp_sequence_number
                                       AND      cir.sub_cal_type = ci.cal_type
                                       AND      cir.sub_ci_sequence_number = ci.sequence_number
                                       AND      ct.cal_type = cir.sup_cal_type
                                       AND      ct.s_cal_cat = cst_academic)
     ORDER BY ci.start_dt DESC;
    --
    --  Cursor to fetch the date alias
    --
    CURSOR c_dai_v (cp_cal_type             igs_ca_da_inst_v.cal_type%TYPE,
                    cp_ci_sequence_number   igs_ca_da_inst_v.ci_sequence_number%TYPE,
                    cp_load_effect_dt_alias igs_en_cal_conf.load_effect_dt_alias%TYPE) IS
      SELECT   daiv.alias_val
      FROM     igs_ca_da_inst_v daiv
      WHERE    daiv.cal_type = cp_cal_type
      AND      daiv.ci_sequence_number = cp_ci_sequence_number
      AND      daiv.dt_alias = cp_load_effect_dt_alias;
  --
  BEGIN

    -- This statement is added in ENCR015 build ( Bug ID : 2158654)
    -- Initialize the l_effective_date with the Effective Date Value passed to this Procedure as Parameter
    l_effective_dt := p_effective_dt;

	--
    --  The attendance type is derived based on the load calendar instances, using
    --  the load effective date alias as the reference point for determining
    --  which calendar is the current load_calendar.
    --  Load the student IGS_PS_COURSE attempt details.
    --
    OPEN c_stu_crs_atmpt (p_person_id,
                          p_course_cd);
    FETCH c_stu_crs_atmpt INTO l_cal_type;
    IF (c_stu_crs_atmpt%NOTFOUND) THEN
       --
       -- if not data found return from the program unit
       --
       CLOSE c_stu_crs_atmpt;
       p_message := 'IGS_EN_NO_CRS_ATMPT';
       RETURN;
    END IF;
    CLOSE c_stu_crs_atmpt;

	IF (p_acad_cal_type IS NOT NULL) THEN
		l_cal_type := p_acad_cal_type;
	END IF;
    --
    -- Cetermine the 'current' load calendar instance based on the load effective
    -- date alias from the enrolment calendar configuration. If this date alias
    -- can't be located then the latest calendar instance where start_dt/end_dt
    -- encompass the effective dt is deemed current
    --
    OPEN c_s_enr_cal_conf;
    FETCH c_s_enr_cal_conf INTO l_load_effect_dt_alias;
    IF c_s_enr_cal_conf%NOTFOUND THEN
       CLOSE c_s_enr_cal_conf;
       p_message := 'IGS_EN_NO_SECC_REC_FOUND';
       RETURN;
    END IF;
    CLOSE c_s_enr_cal_conf;
    --
    -- initialise the local variables
    --
    l_current_load_cal_type := NULL;
    l_current_load_sequence_number := NULL;
    l_current_acad_cal_type := NULL;
    l_current_acad_sequence_number := NULL;
    --
    -- loop through the records fetched for calendar instances
    --
    FOR rec_cal_instance IN c_cal_instance (l_cal_type, l_effective_dt)
    LOOP
        --
        -- now loop through the cal type instance records
        --
        FOR rec_cal_type_instance IN c_cal_type_instance (rec_cal_instance.cal_type,
                                                          rec_cal_instance.sequence_number)
        LOOP
            --
            -- Attempt to find load effective date alias against the cale
            --
            l_daiv_rec_found := FALSE;
            FOR rec_dai_v IN c_dai_v (rec_cal_type_instance.cal_type,
                                      rec_cal_type_instance.sequence_number,
                                      l_load_effect_dt_alias)
            LOOP
                l_daiv_rec_found := TRUE;
                IF (l_effective_dt >= rec_dai_v.alias_val) THEN
                    l_current_load_cal_type := rec_cal_type_instance.cal_type ;
                    l_current_load_sequence_number := rec_cal_type_instance.sequence_number;
                    l_current_acad_cal_type := rec_cal_instance.cal_type;
                    l_current_acad_sequence_number := rec_cal_instance.sequence_number;
                END IF;
            END LOOP;
            IF NOT l_daiv_rec_found  THEN
               IF (l_effective_dt >= rec_cal_type_instance.start_dt) AND
                   (l_effective_dt <= rec_cal_type_instance.end_dt) THEN
                    l_current_load_cal_type := rec_cal_type_instance.cal_type ;
                    l_current_load_sequence_number := rec_cal_type_instance.sequence_number;
                    l_current_acad_cal_type := rec_cal_instance.cal_type;
                    l_current_acad_sequence_number := rec_cal_instance.sequence_number;
               END IF;
            END IF;
        END LOOP;
        IF l_current_load_cal_type IS NOT NULL THEN
           EXIT;
        END IF;
    END LOOP;
    IF l_current_load_cal_type IS NULL THEN
       p_acad_cal_type := NULL;
    END IF;
    p_acad_cal_type := l_current_acad_cal_type;
    p_acad_ci_sequence_number := l_current_acad_sequence_number;
    p_message := NULL;
  END get_academic_cal_poo_chg;
PROCEDURE enrp_get_eff_load_ci_poo_chg (
    p_person_id           IN    NUMBER,
    p_course_cd           IN    VARCHAR2,
    p_effective_dt        IN    DATE,
    p_acad_cal_type       IN OUT NOCOPY  VARCHAR2,
    p_acad_ci_seq_num     OUT NOCOPY   NUMBER,
    p_load_cal_type       OUT NOCOPY   VARCHAR2,
    p_load_ci_seq_num     OUT NOCOPY   NUMBER,
    p_load_ci_alt_code    OUT NOCOPY   VARCHAR2,
    p_load_ci_start_dt    OUT NOCOPY   DATE,
    p_load_ci_end_dt      OUT NOCOPY   DATE,
    p_message_name        OUT NOCOPY   VARCHAR2) AS

  /*
  ||  Created By : Susmitha Tutta
  ||  Created On : 27-JUL-2005
  ||  Purpose : To find the Effective Load Calendar Instance for a passed in academic calendar type
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    --
    --  Cursor to fetch student course attempt calendar type
    --
    CURSOR c_stu_crs_atmpt (cp_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                            cp_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE) IS
      SELECT  sca.cal_type
      FROM    igs_en_stdnt_ps_att sca
      WHERE   sca.person_id = cp_person_id
      AND     sca.course_cd = cp_course_cd;

   -- Local Variables
   l_cal_type                        igs_en_stdnt_ps_att.cal_type%TYPE;
   l_message VARCHAR2(100);

   BEGIN

    --
    --  The attendance type is derived based on the load calendar instances, using
    --  the load effective date alias as the reference point for determining
    --  which calendar is the current load_calendar.
    --  Load the student IGS_PS_COURSE attempt details.
    --

    OPEN c_stu_crs_atmpt (p_person_id,
                          p_course_cd);
    FETCH c_stu_crs_atmpt INTO l_cal_type;
    IF (c_stu_crs_atmpt%NOTFOUND) THEN
       --
       -- if not data found return from the program unit
       --
       CLOSE c_stu_crs_atmpt;
       p_message_name := 'IGS_EN_NO_CRS_ATMPT';
       RETURN;
    END IF;
    CLOSE c_stu_crs_atmpt;
	IF (p_acad_cal_type IS NOT NULL) THEN
		l_cal_type := p_acad_cal_type;
	END IF;
    --
    -- Get the current Academic Calendar instance for the academic cal type passed in.
    --
    get_academic_cal_poo_chg
      (
        p_person_id                => p_person_id,
        p_course_cd                => p_course_cd ,
        p_acad_cal_type            => p_acad_cal_type,
        p_acad_ci_sequence_number  => p_acad_ci_seq_num,
        p_message                  => l_message,
        p_effective_dt             => p_effective_dt
      );

    IF l_message IS NOT NULL THEN
      p_message_name := l_message;
      RETURN;
    END IF;

    --
    -- determine the 'current' load calendar instance based on the load effective
    -- date alias from the enrolment calendar configuration. If this date alias
    -- can't be located then the latest calendar instance where start_dt/end_dt
    -- encompass the effective dt is deemed current
    --
    get_curr_acad_term_cal (
            l_cal_type,
            p_effective_dt,
            p_load_cal_type,
            p_load_ci_seq_num,
            p_load_ci_alt_code,
            p_load_ci_start_dt,
            p_load_ci_end_dt,
            p_message_name);

  EXCEPTION
    WHEN OTHERS THEN
        fnd_message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
        fnd_message.Set_Token('NAME','IGS_EN_GEN_015.enrp_get_eff_load_ci_poo_chg');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

  END enrp_get_eff_load_ci_poo_chg;



END igs_en_gen_015;

/
