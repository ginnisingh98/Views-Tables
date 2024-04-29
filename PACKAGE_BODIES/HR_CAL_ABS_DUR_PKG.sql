--------------------------------------------------------
--  DDL for Package Body HR_CAL_ABS_DUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAL_ABS_DUR_PKG" AS
/* $Header: peabsdur.pkb 120.0 2005/05/31 04:45:35 appldev noship $ */
--
-- --------------- calc_sch_based_dur ----------------------------
--
FUNCTION good_time_format ( p_time IN VARCHAR2 ) RETURN BOOLEAN IS
--
BEGIN
  --
  IF p_time IS NOT NULL THEN
    --
    IF NOT (SUBSTR(p_time,1,2) BETWEEN '00' AND '23' AND
            SUBSTR(p_time,4,2) BETWEEN '00' AND '59' AND
            SUBSTR(p_time,3,1) = ':' AND
            LENGTH(p_time) = 5) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
    --
  ELSE
    RETURN FALSE;
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    RETURN FALSE;
  --
END good_time_format;
--
-- --------------- calc_sch_based_dur ----------------------------
--
PROCEDURE calc_sch_based_dur
( p_days_or_hours IN VARCHAR2,
  p_date_start    IN DATE,
  p_date_end      IN DATE,
  p_time_start    IN VARCHAR2,
  p_time_end      IN VARCHAR2,
  p_assignment_id IN NUMBER,
  p_duration      IN OUT NOCOPY NUMBER
) IS
--
l_idx             NUMBER;
l_ref_date        DATE;
l_first_band      BOOLEAN;
l_day_start_time  VARCHAR2(5);
l_day_end_time    VARCHAR2(5);
l_start_time      VARCHAR2(5);
l_end_time        VARCHAR2(5);
--
l_start_date      DATE;
l_end_date        DATE;
l_schedule        cac_avlblty_time_varray;
l_schedule_source VARCHAR2(10);
l_return_status   VARCHAR2(1);
l_return_message  VARCHAR2(2000);
--
e_bad_time_format EXCEPTION;
--
BEGIN
  hr_utility.set_location('Entering HR_CAL_ABS_DUR_PKG.calc_sch_based_dur',10);
  p_duration := 0;
  --
  IF NOT good_time_format(p_time_start) THEN
    RAISE e_bad_time_format;
  END IF;
  IF NOT good_time_format(p_time_end) THEN
    RAISE e_bad_time_format;
  END IF;
  l_start_date := TO_DATE(TO_CHAR(p_date_start,'DD-MM-YYYY')||' '||p_time_start,'DD-MM-YYYY HH24:MI');
  l_end_date := TO_DATE(TO_CHAR(p_date_end,'DD-MM-YYYY')||' '||p_time_end,'DD-MM-YYYY HH24:MI');
  --
  -- Fetch the work schedule
  --
  hr_wrk_sch_pkg.get_per_asg_schedule
  ( p_person_assignment_id => p_assignment_id
  , p_period_start_date    => l_start_date
  , p_period_end_date      => l_end_date
  , p_schedule_category    => NULL
  , p_include_exceptions   => 'Y'
  , p_busy_tentative_as    => 'FREE'
  , x_schedule_source      => l_schedule_source
  , x_schedule             => l_schedule
  , x_return_status        => l_return_status
  , x_return_message       => l_return_message
  );
  --
  IF l_return_status = '0' THEN
    --
    -- Calculate duration
    --
    l_idx := l_schedule.first;
    --
    IF p_days_or_hours = 'D' THEN
      --
      l_first_band := TRUE;
      l_ref_date := NULL;
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
            IF l_first_band THEN
              l_first_band := FALSE;
              l_ref_date := TRUNC(l_schedule(l_idx).START_DATE_TIME);
              p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
            ELSE -- not first time
              IF TRUNC(l_schedule(l_idx).START_DATE_TIME) = l_ref_date THEN
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
              ELSE
                l_ref_date := TRUNC(l_schedule(l_idx).END_DATE_TIME);
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      --
    ELSE -- p_days_or_hours is 'H'
      --
      l_day_start_time := '00:00';
      l_day_end_time := '23:59';
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
            IF l_schedule(l_idx).END_DATE_TIME < l_schedule(l_idx).START_DATE_TIME THEN
              -- Skip this invalid slot which ends before it starts
              NULL;
            ELSE
              IF TRUNC(l_schedule(l_idx).END_DATE_TIME) > TRUNC(l_schedule(l_idx).START_DATE_TIME) THEN
                -- Start and End on different days
                --
                -- Get first day hours
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_day_end_time,1,2)*60 + SUBSTR(l_day_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
                --
                -- Get last day hours
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_day_start_time,1,2)*60 + SUBSTR(l_day_start_time,4,2)) + 1)/60)
                INTO p_duration
                FROM DUAL;
                --
                -- Get between full day hours
                SELECT p_duration + ((TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) - 1) * 24)
                INTO p_duration
                FROM DUAL;
              ELSE
                -- Start and End on same day
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      p_duration := ROUND(p_duration,2);
      --
    END IF;
  END IF;
  --
  hr_utility.set_location('Leaving HR_CAL_ABS_DUR_PKG.calc_sch_based_dur',20);
EXCEPTION
  --
  WHEN e_bad_time_format THEN
    hr_utility.set_location('Leaving HR_CAL_ABS_DUR_PKG.calc_sch_based_dur',30);
    hr_utility.set_location(SQLERRM,35);
    RAISE;
  --
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving HR_CAL_ABS_DUR_PKG.calc_sch_based_dur',30);
    hr_utility.set_location(SQLERRM,35);
    RAISE;
  --
END calc_sch_based_dur;

-- --------------- calculate_absence_duration ---------------------
--
-- computes the employee's absence duration
--
PROCEDURE calculate_absence_duration
( p_days_or_hours           IN VARCHAR2,
  p_date_start              IN DATE,
  p_date_end                IN DATE,
  p_time_start              IN VARCHAR2,
  p_time_end                IN VARCHAR2,
  p_business_group_id       IN NUMBER,
  p_legislation_code        IN VARCHAR2,
  p_session_date            IN DATE,
  p_assignment_id           IN NUMBER,
  p_element_type_id         IN NUMBER,
  p_invalid_message         IN OUT NOCOPY VARCHAR2,
  p_duration                IN OUT NOCOPY NUMBER,
  p_use_formula             IN OUT NOCOPY VARCHAR2) IS
--
--
--
l_formula_id           ff_formulas_f.formula_id%type;
l_effective_start_date ff_formulas_f.effective_start_date%type;
l_inputs               ff_exec.inputs_t;
l_outputs              ff_exec.outputs_t;
wrong_parameters       exception;
l_user_message         VARCHAR2(1);
l_sch_based_dur        VARCHAR2(1);
--
  lv_invalid_message   VARCHAR2(2000);
  lv_duration          NUMBER;
  lv_use_formula       VARCHAR2(2000);
--
begin
  --
  lv_invalid_message   := p_invalid_message ;
  lv_duration          := p_duration ;
  lv_use_formula       := p_use_formula ;
  --
  l_user_message := 'N';
  --
  l_sch_based_dur := NVL(FND_PROFILE.Value('HR_SCH_BASED_ABS_CALC'),'N');
  --
  IF l_sch_based_dur = 'Y' THEN
    hr_utility.set_location('HR_CAL_ABS_DUR_PKG.cal_abs_dur',05);
    p_use_formula := 'N';
    --
    -- Invoke work schedule based duration calculation
    calc_sch_based_dur (p_days_or_hours => p_days_or_hours,
                        p_date_start    => p_date_start,
                        p_date_end      => p_date_end,
                        p_time_start    => p_time_start,
                        p_time_end      => p_time_end,
                        p_assignment_id => p_assignment_id,
                        p_duration      => p_duration);
    --
  ELSE -- Use FastFormula based calculation
    p_use_formula := 'Y';
    hr_utility.set_location('HR_CAL_ABS_DUR_PKG.cal_abs_dur',10);
    --
    -- There are 3 levels of formula:
    -- 1. business group (if defined)
    -- 2. legislation_code (if defined)
    -- 3. CORE formula (by default for all localisations).
    --
    --
    -- select customer-defined formula (if exists)
    begin
      select formula_id, effective_start_date
      into l_formula_id, l_effective_start_date
      from ff_formulas_f
      where formula_name = 'BG_ABSENCE_DURATION'
      and business_group_id = p_business_group_id
      and p_session_date between effective_start_date and effective_end_date;
    exception
      WHEN NO_DATA_FOUND THEN
      -- If no business group formula then look for
      -- legislation-defined formula
        begin
          select formula_id, effective_start_date
          into l_formula_id, l_effective_start_date
          from ff_formulas_f
          where formula_name = 'LEGISLATION_ABSENCE_DURATION'
          and legislation_code = p_legislation_code
          and business_group_id is null
          and p_session_date between effective_start_date and effective_end_date;
        exception
          WHEN NO_DATA_FOUND THEN
          -- If none of the two above, then
          -- select core formula
            begin
              select formula_id, effective_start_date
              into l_formula_id, l_effective_start_date
              from ff_formulas_f
              where formula_name = 'CORE_ABSENCE_DURATION'
              and legislation_code is null
              and business_group_id is null
              and p_session_date between effective_start_date and effective_end_date;
            end;
          --
        end;
      --
    end;
    --
    hr_utility.set_location('HR_CAL_ABS_DUR_PKG.cal_abs_dur',20);
    --
    -- initialize the formula
    --
    ff_exec.init_formula(l_formula_id,l_effective_start_date,l_inputs,l_outputs);
    --
    -- assign inputs
    --
    for l_in_cnt in l_inputs.first..l_inputs.last
    loop
      if l_inputs(l_in_cnt).name='DAYS_OR_HOURS' then
         l_inputs(l_in_cnt).value:=p_days_or_hours;
      elsif l_inputs(l_in_cnt).name='DATE_START' then
         l_inputs(l_in_cnt).value:=fnd_date.date_to_canonical(p_date_start);
      elsif l_inputs(l_in_cnt).name='DATE_END' then
         l_inputs(l_in_cnt).value:=fnd_date.date_to_canonical(p_date_end);
      elsif l_inputs(l_in_cnt).name='TIME_START' then
         l_inputs(l_in_cnt).value:=p_time_start;
      elsif l_inputs(l_in_cnt).name='TIME_END' then
         l_inputs(l_in_cnt).value:=p_time_end;
      elsif l_inputs(l_in_cnt).name='DATE_EARNED' then
         l_inputs(l_in_cnt).value:=fnd_date.date_to_canonical(p_session_date);
      elsif l_inputs(l_in_cnt).name='BUSINESS_GROUP_ID' then
         l_inputs(l_in_cnt).value:=p_business_group_id;
      elsif l_inputs(l_in_cnt).name='LEGISLATION_CODE' then
         l_inputs(l_in_cnt).value:=p_legislation_code;
      elsif l_inputs(l_in_cnt).name='ASSIGNMENT_ID' then
         l_inputs(l_in_cnt).value:=p_assignment_id;
      elsif l_inputs(l_in_cnt).name='ELEMENT_TYPE_ID' then
         l_inputs(l_in_cnt).value:=p_element_type_id;
      else
         raise wrong_parameters;
      end if;
    end loop;
    --
    hr_utility.set_location('HR_CAL_ABS_DUR_PKG.cal_abs_dur',30);
    --
    -- run the formula
    --
    ff_exec.run_formula(l_inputs,l_outputs);
    --
    -- assign outputs
    --
    for l_out_cnt in l_outputs.first..l_outputs.last
    loop
      if l_outputs(l_out_cnt).name='DURATION' then
         if l_outputs(l_out_cnt).value = 'FAILED' then
           l_user_message := 'Y';
         else
           p_duration := to_number(l_outputs(l_out_cnt).value);
         end if;
      elsif l_outputs(l_out_cnt).name='INVALID_MSG' then
         p_invalid_message := l_outputs(l_out_cnt).value;
      else
        raise wrong_parameters;
      end if;
    end loop;
    --
    if l_user_message = 'Y' then
      hr_utility.set_location('HR_CAL_ABS_DUR_PKG.cal_abs_dur',35);
      hr_utility.set_message(800,p_invalid_message);
      hr_utility.raise_error;
    end if;
    --
  END IF; -- Check calculation mode
  --
exception
  when NO_DATA_FOUND then
    -- no formula found, so send back flag for using existing procedures
    -- do we need the error message now?
    p_invalid_message := lv_invalid_message ;
    p_duration := lv_duration ;
    p_use_formula := 'N';
    hr_utility.set_location('HR_CAL_ABS_DUR_PKG.cal_abs_dur',40);
/*
    hr_utility.set_message(800,'HR_52351_FF_NOT_FOUND');
    hr_utility.raise_error;
*/
  when wrong_parameters then
    hr_utility.set_location('HR_CAL_ABS_DUR_PKG.cal_abs_dur',45);
    hr_utility.set_message(800,'HR_52352_BAD_FF_DEFINITION');

    p_invalid_message := lv_invalid_message ;
    p_duration := lv_duration ;
    p_use_formula := lv_use_formula ;

    hr_utility.raise_error;
  when others then

    p_invalid_message := lv_invalid_message ;
    p_duration := lv_duration ;
    p_use_formula := lv_use_formula ;
    RAISE;
--
end calculate_absence_duration;
--
--
-- --------------------- count_working_days -----------------------
--
-- This function is called from the formula and its used to
-- count the number of working days (Monday to Friday) for the
-- duration of the absence in the CORE formula.
--
function count_working_days(starting_date DATE, total_days NUMBER)
  return NUMBER is
  day_num NUMBER := 0;
  count_days NUMBER := 0;
begin
   -- find day of the week
   day_num := to_char(starting_date,'D');
   -- loop until end of absence
   for i in 1..(total_days+1) loop
     -- if neither Saturday nor Sunday then add to counter
     if ((day_num <> 1) and (day_num <> 7)) then
       count_days := count_days + 1;
     end if;
     -- if Sunday then start again
     if day_num = 7 then
       day_num := 1;
     else
     -- else next day
       day_num := day_num + 1;
     end if;
   end loop;
   return count_days;
end count_working_days;

end hr_cal_abs_dur_pkg;

/
