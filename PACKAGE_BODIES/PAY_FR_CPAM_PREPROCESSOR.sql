--------------------------------------------------------
--  DDL for Package Body PAY_FR_CPAM_PREPROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_CPAM_PREPROCESSOR" AS
/* $Header: pyfrcpam.pkb 120.0.12000000.2 2007/02/27 13:47:25 spendhar noship $ */
  g_info_element_type_id        pay_element_types_f.element_type_id%type;
  g_info_pymt_frm_dt_iv_id      pay_input_values_f.input_value_id%type;
  g_info_pymt_to_dt_iv_id       pay_input_values_f.input_value_id%type;
  g_info_days_iv_id             pay_input_values_f.input_value_id%type;
  --g_info_subrogated_iv_id       pay_input_values_f.input_value_id%type;
  g_info_gross_amt_iv_id        pay_input_values_f.input_value_id%type;
  g_info_net_amt_iv_id          pay_input_values_f.input_value_id%type;
  g_info_gross_rt_iv_id         pay_input_values_f.input_value_id%type;
  g_info_net_rt_iv_id           pay_input_values_f.input_value_id%type;

  g_proc_element_type_id        pay_element_types_f.element_type_id%type;
  g_proc_pymt_frm_dt_iv_id      pay_input_values_f.input_value_id%type;
  g_proc_pymt_to_dt_iv_id       pay_input_values_f.input_value_id%type;
  g_proc_days_iv_id             pay_input_values_f.input_value_id%type;
  --g_proc_subrogated_iv_id       pay_input_values_f.input_value_id%type;
  g_proc_gross_amt_iv_id        pay_input_values_f.input_value_id%type;
  g_proc_net_amt_iv_id          pay_input_values_f.input_value_id%type;
  g_proc_gross_rt_iv_id         pay_input_values_f.input_value_id%type;
  g_proc_net_rt_iv_id           pay_input_values_f.input_value_id%type;

  CURSOR C_info_entry(p_element_entry_id IN NUMBER) IS
  SELECT 'X' dum
    FROM pay_element_entries_f pee, pay_element_links_f pel, pay_element_types_f pet
    WHERE pee.element_link_id = pel.element_link_id
    AND pet.element_type_id = pel.element_type_id
    AND pet.element_name = 'FR_SICKNESS_CPAM_INFO'
    AND pee.element_entry_id = p_element_entry_id;

  -- Query input value ids
  CURSOR C_iv_ids(p_element_type IN VARCHAR2
                 ,p_effective_start_date IN DATE) IS
  SELECT max(e.element_type_id)
        ,max(decode(i.name,'Payment From Date',i.input_value_id,null))
        ,max(decode(i.name,'Payment To Date',i.input_value_id,null))
        ,max(decode(i.name,'Days',i.input_value_id,null))
        --,max(decode(i.name,'Subrogated',i.input_value_id,null))
        ,max(decode(i.name,'Gross Amount',i.input_value_id,null))
        ,max(decode(i.name,'Net Amount',i.input_value_id,null))
        ,max(decode(i.name,'Gross Daily Rate',i.input_value_id,null))
        ,max(decode(i.name,'Net Daily Rate',i.input_value_id,null))
  FROM pay_element_types_f e,
       pay_input_values_f i
  WHERE e.element_name = p_element_type
       and e.legislation_code = 'FR'
       and e.element_type_id = i.element_type_id
       and p_effective_start_date between e.effective_start_date and e.effective_end_date
       and p_effective_start_date between i.effective_start_date and i.effective_end_date;

  --
  CURSOR C_input_values(p_element_entry_id IN NUMBER) IS
  SELECT max(decode(eev.input_value_id,g_info_pymt_frm_dt_iv_id
                      ,to_date(eev.screen_entry_value,'YYYY/MM/DD HH24:MI:SS')
                      ,NULL)) Frm_dt,
         max(decode(eev.input_value_id,g_info_pymt_to_dt_iv_id
                        ,to_date(eev.screen_entry_value,'YYYY/MM/DD HH24:MI:SS')
                        ,NULL)) To_dt,
         max(decode(eev.input_value_id,g_info_days_iv_id
                 ,to_number(eev.screen_entry_value)
                 ,NULL)) Days,
      -- max(decode(eev.input_value_id,g_info_subrogated_iv_id,eev.screen_entry_value,NULL)) Subrogated,
         max(decode(eev.input_value_id,g_info_gross_amt_iv_id
                        ,to_number(eev.screen_entry_value)
                        ,NULL)) Gross_Amount,
         max(decode(eev.input_value_id,g_info_net_amt_iv_id
                        ,to_number(eev.screen_entry_value)
                        ,NULL)) Net_Amount,
         max(decode(eev.input_value_id,g_info_gross_rt_iv_id
                        ,to_number(eev.screen_entry_value)
                        ,NULL)) Gross_Daily_Rate,
         max(decode(eev.input_value_id,g_info_net_rt_iv_id
                        ,to_number(eev.screen_entry_value)
                        ,NULL)) Net_Daily_Rate
  FROM pay_element_types_f pet, pay_element_entries_f pee,
       pay_input_values_f piv, pay_element_entry_values_f eev
  WHERE pee.element_entry_id = eev.element_entry_id
   and pet.element_type_id = piv.element_type_id
   and piv.input_value_id = eev.input_value_id
   and pet.element_name = 'FR_SICKNESS_CPAM_INFO'
   and pee.element_entry_id = p_element_entry_id;
  --
  CURSOR C_element_link(p_element_type_id IN NUMBER,p_source_element_link_id IN NUMBER, p_effective_start_date IN DATE) IS
  SELECT pel.element_link_id
  FROM pay_element_types_f pet, pay_element_links_f pel, pay_element_links_f pel1
  WHERE pet.element_type_id = pel.element_type_id
  AND pel.business_group_id = pel1.business_group_id
  AND pet.element_type_id = p_element_type_id
  AND p_effective_start_date BETWEEN pel.effective_start_date AND pel.effective_end_date
  AND pel1.element_link_id = p_source_element_link_id;

  --

PROCEDURE CPAM_INFO_CREATE(
               p_effective_start_date           IN DATE
              ,p_effective_end_date             IN DATE
              ,p_element_entry_id               IN NUMBER
              ,p_assignment_id                  IN NUMBER
              ,p_element_link_id                IN NUMBER
              ,p_entry_type                     IN VARCHAR2
              ,p_date_earned                    IN DATE

       ) IS
  rec_input_values c_input_values%ROWTYPE;
  rec_info_entry   c_info_entry%ROWTYPE;
  rec_element_link c_element_link%ROWTYPE;

  CURSOR C_info_entries(p_assignment_id IN Number, p_start_date IN Date, p_end_date IN Date, p_curr_entry_id IN Number) IS
    SELECT pev.effective_start_date
    FROM pay_element_entries_f pee, pay_element_links_f pel, pay_element_types_f pet,
         pay_input_values_f piv, pay_element_entry_values_f pev
    WHERE pee.element_link_id = pel.element_link_id
    AND pet.element_type_id = pel.element_type_id
    AND pee.element_entry_id= pev.element_entry_id
    AND pet.element_type_id = piv.element_type_id
    AND pev.input_value_id = piv.input_value_id
    AND piv.name IN ('Payment From Date', 'Payment To Date')
    AND pee.assignment_id = p_assignment_id
    AND fnd_date.canonical_to_date(pev.screen_entry_value) BETWEEN p_start_date AND p_end_date
    AND pet.element_name = 'FR_SICKNESS_CPAM_INFO'
    AND pee.element_entry_id <> p_curr_entry_id;

   -- Get absences occuring on or within the payment dates (even overlapping)
 CURSOR C_absences(p_assignment_id IN Number, p_start_date IN Date, p_end_date IN Date) IS
   SELECT paa.person_id
   ,      paa.absence_attendance_id
   ,      to_number(paa.abs_information1) parent_absence_id
   ,      paa.date_start date_start
   ,      paa.date_end   date_end
   ,      (paa.date_end - paa.date_start + 1) duration
   ,      nvl(decode(paa.abs_information1,NULL,paa.abs_information8,
                                               paa_p.abs_information8),'N') pay_estimate
   ,      fnd_date.canonical_to_date(decode(paa.abs_information1,NULL,paa.abs_information7,
                                               paa_p.abs_information7)) ijss_ineligible_date
   FROM per_absence_attendances paa,
        per_absence_attendances paa_p,
        per_all_people_f pap,
        per_all_assignments_f pasg
   WHERE pasg.person_id = pap.person_id
   AND pap.person_id = paa.person_id
   AND paa.abs_information1 = paa_p.absence_attendance_id(+)
   AND p_start_date between pasg.effective_start_date and pasg.effective_end_date
   AND p_start_date between pap.effective_start_date and pap.effective_end_date
   AND  ( ( (paa.date_end between p_start_date and p_end_date)
       OR (paa.date_start between p_start_date and p_end_date))
     OR
        ( (p_start_date between paa.date_start and paa.date_end)
       OR (p_end_date between paa.date_start and paa.date_end)))
   AND  pasg.assignment_id = p_assignment_id
   AND   paa.abs_information_category = 'FR_S'
   ORDER BY paa.date_start ;

 CURSOR C_time_periods(p_assignment_id IN Number, p_start_date IN Date, p_end_date IN Date) IS
   SELECT ptp.start_date, ptp.end_date
   FROM per_time_periods ptp, per_all_assignments_f pasg
   WHERE pasg.payroll_id = ptp.payroll_id
    AND p_start_date between pasg.effective_start_date and pasg.effective_end_date
    AND (ptp.start_date BETWEEN p_start_date AND p_end_date
      OR ptp.end_date BETWEEN p_start_date AND p_end_date)
    AND pasg.assignment_id = p_assignment_id;

 CURSOR C_proc_entry(p_element_entry_id IN NUMBER) IS
     SELECT 'X' dum
       FROM pay_element_entries_f pee, pay_element_links_f pel, pay_element_types_f pet
       WHERE pee.element_link_id = pel.element_link_id
       AND pet.element_type_id = pel.element_type_id
       AND pet.element_name = 'FR_SICKNESS_CPAM_PROCESS'
       AND pee.creator_type IN ('F','H')
       AND pee.element_entry_id = p_element_entry_id;


  rec_info_entries C_info_entries%ROWTYPE;
  rec_proc_entry   C_proc_entry%ROWTYPE;

  l_process_element_entry_id number;
  l_effective_start_date     date;
  l_effective_end_date       date;
  l_entry_information_category varchar2(30);

  cnt_absences    number;
  cnt_periods     number;

BEGIN
  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : pay_fr_cpam_preprocessor.cpam_info_create' , 10);
     return;
  END IF;
  --

  hr_utility.trace('Preproc - INS ');

  -- Checking if current entry is of type 'FR_SICKNESS_CPAM_PROCESS'
  --  and is being made by the EE or BEE form
  IF C_proc_entry%ISOPEN THEN
    CLOSE C_proc_entry;
  END IF;
  OPEN C_proc_entry(p_element_entry_id);
  FETCH C_proc_entry INTO rec_proc_entry;
  IF C_proc_entry%FOUND THEN
    fnd_message.set_name ('PAY', 'PAY_75075_CPAM_PROCESS_INS_NA');
    fnd_message.raise_error;
  END IF;

  --
  IF C_info_entry%ISOPEN THEN
    CLOSE C_info_entry;
  END IF;
  OPEN C_info_entry(p_element_entry_id);
  FETCH C_info_entry INTO rec_info_entry;
  IF C_info_entry%FOUND THEN
    hr_utility.trace('Preproc - INS - INFO entry found');
    l_effective_start_date := p_effective_start_date;
    l_effective_end_date := p_effective_end_date;
    l_entry_information_category := 'FR_CPAM PROCESS INFORMATION';

    IF C_iv_ids%ISOPEN THEN
      CLOSE C_iv_ids;
    END IF;
    OPEN C_iv_ids('FR_SICKNESS_CPAM_INFO', p_effective_start_date);
    FETCH C_iv_ids
    INTO g_info_element_type_id,
         g_info_pymt_frm_dt_iv_id,
         g_info_pymt_to_dt_iv_id,
         g_info_days_iv_id,
       --g_info_subrogated_iv_id,
         g_info_gross_amt_iv_id,
         g_info_net_amt_iv_id,
         g_info_gross_rt_iv_id,
         g_info_net_rt_iv_id;
    CLOSE C_iv_ids;

    IF C_input_values%ISOPEN THEN
      CLOSE C_input_values;
    END IF;
    -- Fetch input values for the entry
    OPEN C_input_values(p_element_entry_id);
    FETCH C_input_values INTO rec_input_values;
    CLOSE C_input_values;

    hr_utility.trace(' INS Fetched Input values');
    IF rec_input_values.Days IS NULL THEN
      rec_input_values.Days := (rec_input_values.To_Dt - rec_input_values.Frm_dt + 1);
    /*
    -- Since Days is an non enterable input value, wont enter this condn.
    ELSE
      -- Validate entry values
      -- 1) Days
      IF rec_input_values.Days > (rec_input_values.To_Dt - rec_input_values.Frm_dt + 1) THEN
        fnd_message.set_name ('PAY', 'PAY_75070_CPAM_INFO_INV_DAYS');
        fnd_message.raise_error;
      END IF;
    */
    END IF;
        -- 2) Invalid Gross Amount
    IF rec_input_values.Gross_Amount <> (rec_input_values.Gross_Daily_Rate  * rec_input_values.Days) THEN
       fnd_message.set_name ('PAY', 'PAY_75071_CPAM_INFO_INV_GR_AMT');
       fnd_message.raise_error;
    END IF;
    -- 3) Invalid Net Amount
    IF rec_input_values.Net_Amount <> (rec_input_values.Net_Daily_Rate  * rec_input_values.Days) THEN
       fnd_message.set_name ('PAY', 'PAY_75072_CPAM_INFO_INV_NT_AMT');
       fnd_message.raise_error;
    END IF;
    hr_utility.trace(' INS Fetched and cross validated Input values');
    -- 4) Invalid dates
    IF C_info_entries%ISOPEN THEN
      CLOSE C_info_entries;
    END IF;
    OPEN C_info_entries(p_assignment_id,rec_input_values.frm_dt,rec_input_values.to_dt,p_element_entry_id);
    FETCH C_info_entries INTO rec_info_entries;
      IF C_info_entries%FOUND THEN
      fnd_message.set_name ('PAY','PAY_75074_CPAM_INFO_INV_DATES');
      fnd_message.set_token('PAY_PERIOD',to_char(rec_info_entries.effective_start_date));
      fnd_message.raise_error;
      END IF;
    CLOSE C_info_entries;
    hr_utility.trace(' INS Checked for overlapping INFO entries');
    IF C_iv_ids%ISOPEN THEN
      CLOSE C_iv_ids;
    END IF;

    OPEN C_iv_ids('FR_SICKNESS_CPAM_PROCESS', p_effective_start_date);
    FETCH C_iv_ids
    INTO g_proc_element_type_id,
         g_proc_pymt_frm_dt_iv_id,
         g_proc_pymt_to_dt_iv_id,
         g_proc_days_iv_id,
       --g_proc_subrogated_iv_id,
         g_proc_gross_amt_iv_id,  -- NULL
         g_proc_net_amt_iv_id,     -- NULL
         g_proc_gross_rt_iv_id,
         g_proc_net_rt_iv_id;
    CLOSE C_iv_ids;

    OPEN C_element_link(g_proc_element_type_id, p_element_link_id, p_effective_start_date);
    FETCH C_element_link INTO rec_element_link;
    CLOSE C_element_link;

    hr_utility.trace(' INS Fetched and checked Input values');
    -- Query sickness absences (and Pay IJSS Estimate) between the payments start and end date
    cnt_absences := 0;
    FOR rec_absences IN C_absences(p_assignment_id, rec_input_values.Frm_Dt, rec_input_values.To_Dt)
    LOOP
      cnt_absences := cnt_absences + 1;
      hr_utility.trace(' INS Absences found :'||cnt_absences||' with Estimate set to ='||rec_absences.pay_estimate);
      IF rec_absences.pay_estimate = 'N' THEN
        hr_utility.trace(' Absences to be preprocessed for:'||cnt_absences);
        cnt_periods := 0;

        --Bug #3040003
        IF (rec_absences.ijss_ineligible_date <= rec_input_values.Frm_Dt
         OR rec_absences.ijss_ineligible_date <= rec_input_values.To_Dt) THEN
          fnd_message.set_name ('PAY','PAY_75078_CPAM_INFO_IJSS_IN_DT');
          fnd_message.set_token('INELIG_DT',to_char(rec_absences.ijss_ineligible_date));
          fnd_message.raise_error;
        END IF;

        -- Does the absence cross a period boundary?
        -- Query number of per_time_periods from the payroll on the assignment
        FOR rec_time_periods IN C_time_periods(p_assignment_id, GREATEST(rec_input_values.Frm_Dt,rec_absences.date_start), LEAST(rec_input_values.To_Dt,rec_absences.date_end))
        LOOP
          cnt_periods := cnt_periods + 1;
          hr_utility.trace('  Period boundaries found :'||cnt_periods);
          -- Creating entry with relevant dates
          l_process_element_entry_id := NULL;

          --l_prev_start_date := GREATEST(rec_absences.date_start,rec_input_values.Frm_dt);
          hr_utility.trace(' INS Creating entry for relevant Period :'||cnt_periods);
          hr_utility.trace('     With dates: start='||GREATEST(rec_time_periods.start_date,rec_absences.date_start,rec_input_values.Frm_dt)||
                               ' end='||LEAST(rec_time_periods.end_date,rec_absences.date_end, rec_input_values.To_dt));
          hr_entry_api.insert_element_entry
          (
          p_effective_start_date      => l_effective_start_date,
          p_effective_end_date        => l_effective_end_date,
          --
          -- Element Entry Table
          --
          p_element_entry_id          => l_process_element_entry_id,
          p_assignment_id             => p_assignment_id,
          p_element_link_id           => rec_element_link.element_link_id,
          p_creator_type              => 'S',
          p_entry_type                => p_entry_type,
          p_subpriority               => to_number(substr(to_char(GREATEST(rec_time_periods.start_date,rec_absences.date_start,rec_input_values.Frm_dt),'J'),4,4)),
          p_date_earned               => p_date_earned,
          -- Element Entry Values Table
          --
          p_input_value_id1           => g_proc_pymt_frm_dt_iv_id,
          p_input_value_id2           => g_proc_pymt_to_dt_iv_id,
          --p_input_value_id3           => g_proc_subrogated_iv_id,
          p_input_value_id4           => g_proc_gross_rt_iv_id,
          p_input_value_id5           => g_proc_net_rt_iv_id,
          p_input_value_id6           => g_proc_days_iv_id,
          p_entry_value1              => GREATEST(rec_time_periods.start_date,rec_absences.date_start,rec_input_values.Frm_dt),
          p_entry_value2              => LEAST(rec_time_periods.end_date,rec_absences.date_end, rec_input_values.To_dt),
          --p_entry_value3              => hr_general.decode_lookup('YES_NO', rec_input_values.Subrogated),
          p_entry_value4              => rec_input_values.Gross_daily_rate,
          p_entry_value5              => rec_input_values.Net_daily_rate,
          p_entry_value6              => (LEAST(rec_time_periods.end_date,rec_absences.date_end, rec_input_values.To_dt) -
                                         GREATEST(rec_time_periods.start_date,rec_absences.date_start,rec_input_values.Frm_dt)) +1,
          p_entry_information_category=> l_entry_information_category,
          p_entry_information1        => p_element_entry_id,
          p_entry_information2        => rec_absences.absence_attendance_id

          );
          hr_utility.trace(' INS Created entry for relevant Period :'||cnt_periods||' with id ='||l_process_element_entry_id);
        END LOOP;  -- Time period Loop

        IF cnt_periods = 0 THEN  -- No period break during the absence, create a process entry for whole absence
          --
          hr_utility.trace(' No period boundaries :Creating entry for relevant absence');
          l_process_element_entry_id := NULL;

          --l_prev_start_date := GREATEST(rec_absences.date_start,rec_input_values.Frm_dt);
          hr_utility.trace('  Creating entry for relevant Absence id='||rec_absences.absence_attendance_id);
          hr_entry_api.insert_element_entry
          (
          p_effective_start_date      => l_effective_start_date,
          p_effective_end_date        => l_effective_end_date,
          --
          -- Element Entry Table
          --
          p_element_entry_id          => l_process_element_entry_id,
          p_assignment_id             => p_assignment_id,
          p_element_link_id           => rec_element_link.element_link_id,
          p_creator_type              => 'S',
          p_entry_type                => p_entry_type,
          p_subpriority               => to_number(substr(to_char(GREATEST(rec_absences.date_start,rec_input_values.Frm_dt),'J'),4,4)),
          p_date_earned               => p_date_earned,
          -- Element Entry Values Table
          --
          p_input_value_id1           => g_proc_pymt_frm_dt_iv_id,
          p_input_value_id2           => g_proc_pymt_to_dt_iv_id,
          --p_input_value_id3           => g_proc_subrogated_iv_id,
          p_input_value_id4           => g_proc_gross_rt_iv_id,
          p_input_value_id5           => g_proc_net_rt_iv_id,
          p_input_value_id6           => g_proc_days_iv_id,
          p_entry_value1              => GREATEST(rec_absences.date_start,rec_input_values.Frm_dt),
          p_entry_value2              => LEAST(rec_absences.date_end, rec_input_values.To_dt),
          --p_entry_value3              => hr_general.decode_lookup('YES_NO', rec_input_values.Subrogated),
          p_entry_value4              => rec_input_values.Gross_daily_rate,
          p_entry_value5              => rec_input_values.Net_daily_rate,
          p_entry_value6              => (LEAST(rec_absences.date_end, rec_input_values.To_dt) - GREATEST(rec_absences.date_start,rec_input_values.Frm_dt)) +1,
          p_entry_information_category=> l_entry_information_category,
          p_entry_information1        => p_element_entry_id,
          p_entry_information2        => rec_absences.absence_attendance_id
          );
          hr_utility.trace(' INS Created entry for relevant Absence with id='||l_process_element_entry_id);
          --
        END IF; -- Period breaks = 0 Chk

      END IF; -- Pay IJSS Estimate chk
    END LOOP; -- Absences Loop

    IF cnt_absences = 0  THEN
       fnd_message.set_name ('PAY', 'PAY_75073_CPAM_INFO_DTS_MIS');
       fnd_message.raise_error;
    END IF;
  END IF;       -- Info Entry Chk

  -- #3030587
  -- Setting value for INFO element's input value Days
  UPDATE PAY_ELEMENT_ENTRY_VALUES_F SET screen_entry_value = rec_input_values.Days
    WHERE element_entry_id = p_element_entry_id
      AND input_value_id = g_info_days_iv_id;

  IF C_info_entry%ISOPEN THEN
    CLOSE C_info_entry;
  END IF;
  hr_utility.trace(' Preproc INS Finished');
  --hr_utility.trace_off;
END CPAM_INFO_CREATE;


--
PROCEDURE CPAM_INFO_UPDATE(
          p_effective_start_date      IN DATE
         ,p_effective_end_date        IN DATE
         ,p_element_entry_id          IN NUMBER
         ,p_date_earned               IN DATE
         ,p_entry_type_o              IN VARCHAR2
         ,p_effective_start_date_o    IN DATE
         ,p_assignment_id_o           IN NUMBER
         ,p_element_link_id_o         IN NUMBER
         ,p_date_earned_o             IN DATE
         ) IS
  --
  rec_info_entry   c_info_entry%ROWTYPE;
  --
BEGIN
  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : pay_fr_cpam_preprocessor.cpam_info_update' , 10);
     return;
  END IF;
  --

  hr_utility.trace('Preproc - UPD Started');
  IF C_info_entry%ISOPEN THEN
    CLOSE C_info_entry;
  END IF;
  OPEN C_info_entry(p_element_entry_id);
  FETCH C_info_entry INTO rec_info_entry;
  IF C_info_entry%FOUND THEN
    hr_utility.trace(' Preproc - UPD - INFO entry found');
    hr_utility.trace('  UPD - Deleting related process element entries');
    CPAM_INFO_DELETE(
         p_element_entry_id         => p_element_entry_id,
         p_element_link_id_o        => p_element_link_id_o,
         p_effective_start_date_o   => p_effective_start_date_o,
         p_assignment_id_o          => p_assignment_id_o,
         p_datetrack_mode           => 'ZAP'
         );
    hr_utility.trace('  UPD - Finished deleting related process element entries');

    hr_utility.trace('  UPD - Recreating process element entries');
    hr_utility.trace('  UPD -   With start dt='||p_effective_start_date||' end dt='||p_effective_end_date);
    hr_utility.trace('  UPD -   entry id='||p_element_entry_id||' assgt id='||p_assignment_id_o||' link id='||p_element_link_id_o);
    hr_utility.trace('  UPD -   entry type='||p_entry_type_o||' dt earned'||p_date_earned);

    CPAM_INFO_CREATE(
          p_effective_start_date    => p_effective_start_date
         ,p_effective_end_date      => p_effective_end_date
         ,p_element_entry_id        => p_element_entry_id
         ,p_assignment_id           => p_assignment_id_o
         ,p_element_link_id         => p_element_link_id_o
         ,p_entry_type              => p_entry_type_o
         ,p_date_earned             => p_date_earned
         );
    hr_utility.trace('  UPD - Recreated process element entries');
  END IF;

  IF C_info_entry%ISOPEN THEN
    CLOSE C_info_entry;
  END IF;
  hr_utility.trace('Preproc UPD Finished');

END CPAM_INFO_UPDATE;
--


PROCEDURE CPAM_INFO_DELETE(
        p_element_entry_id      IN NUMBER,
        p_element_link_id_o     IN NUMBER,
        p_effective_start_date_o IN DATE,
        p_assignment_id_o       IN NUMBER ,
        p_datetrack_mode        IN VARCHAR2
        ) IS
  rec_info_entry   c_info_entry%ROWTYPE;
  rec_element_link c_element_link%ROWTYPE;
  l_assignment_id pay_element_entries_f.assignment_id%TYPE;

  CURSOR C_linked_process_entries(p_element_entry_id IN NUMBER, p_assignment_id IN NUMBER) IS
    SELECT pee.element_entry_id
    FROM pay_element_entries_f pee
    WHERE pee.entry_information_category = 'FR_CPAM PROCESS INFORMATION'
      AND pee.assignment_id = p_assignment_id
      AND pee.entry_information1 = to_char(p_element_entry_id);

BEGIN
  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : pay_fr_cpam_preprocessor.cpam_info_delete' , 10);
     return;
  END IF;
  --
  hr_utility.trace(' Preproc DEL Started');

  -- To determine that the entry being deleted is of type 'FR_SICKNESS_CPAM_INFO'
  --   the element link id of the Info type will be compared with the element link id of the entry being deleted
  IF C_iv_ids%ISOPEN THEN
    CLOSE C_iv_ids;
  END IF;
  OPEN C_iv_ids('FR_SICKNESS_CPAM_INFO', p_effective_start_date_o);
  FETCH C_iv_ids
  INTO g_info_element_type_id,
       g_info_pymt_frm_dt_iv_id,
       g_info_pymt_to_dt_iv_id,
       g_info_days_iv_id,
     --g_info_subrogated_iv_id,
       g_info_gross_amt_iv_id,
       g_info_net_amt_iv_id,
       g_info_gross_rt_iv_id,
       g_info_net_rt_iv_id;
  CLOSE C_iv_ids;

  OPEN C_element_link(g_info_element_type_id, p_element_link_id_o, p_effective_start_date_o);
  FETCH C_element_link INTO rec_element_link;
  CLOSE C_element_link;

  hr_utility.trace(' Preproc :: Info element type ='||g_info_element_type_id||' with link='||rec_element_link.element_link_id||' Parameter link='||p_element_link_id_o);
  IF p_element_link_id_o = rec_element_link.element_link_id THEN
    -- The entry being currently deleted is of type 'FR_SICKNESS_CPAM_INFO'
    --  So delete all Process entries linked to the current entry
    hr_utility.trace(' Preproc :: DT DELETE MODE ='||p_datetrack_mode||' for INFO entry'||p_element_entry_id||' eff start date='||p_effective_start_date_o);

    FOR rec_linked_process_entries IN C_linked_process_entries(p_element_entry_id, p_assignment_id_o )
    LOOP
      hr_utility.trace('  Preproc : DELETING entry='||rec_linked_process_entries.element_entry_id);
      hr_entry_api.delete_element_entry(
         p_dt_delete_mode       => p_datetrack_mode,
         p_session_date         => p_effective_start_date_o,
         p_element_entry_id     => rec_linked_process_entries.element_entry_id);
      hr_utility.trace('  Preproc : DELETED entry='||rec_linked_process_entries.element_entry_id);
    END LOOP;
  END IF;

  hr_utility.trace('Preproc DEL Finished');

END CPAM_INFO_DELETE;

END PAY_FR_CPAM_PREPROCESSOR;

/
