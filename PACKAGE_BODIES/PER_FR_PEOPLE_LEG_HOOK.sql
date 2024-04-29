--------------------------------------------------------
--  DDL for Package Body PER_FR_PEOPLE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_PEOPLE_LEG_HOOK" AS
/* $Header: pefrlhre.pkb 120.0.12000000.2 2007/02/28 10:20:14 spendhar ship $ */
--
  g_package  VARCHAR2(33) := 'per_fr_people_leg_hook.';
--
  --
  -- Service functions to return TRUE if the value passed has been changed.
  --
  FUNCTION val_changed(p_value IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_value IS NULL OR p_value <> hr_api.g_number);
  END val_changed;
  --
  FUNCTION val_changed(p_value IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_value IS NULL OR p_value <> hr_api.g_varchar2);
  END val_changed;
  --
  FUNCTION val_changed(p_value IN DATE) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_value IS NULL OR p_value <> hr_api.g_date);
  END val_changed;
--
  PROCEDURE check_regn_entry_ins(p_region_of_birth          VARCHAR2
                                ,p_country_of_birth	    VARCHAR2
                                ,p_per_information10        VARCHAR2
                                ,p_hire_date           DATE
                                ) IS

   l_proc               VARCHAR2(200) := g_package||'check_regn_entry_ins';
   l_dept		hr_lookups.meaning%TYPE;
   l_dept_code		hr_lookups.lookup_code%TYPE;

   CURSOR cur_dept IS
   select hl.meaning, hl.lookup_code
   from hr_lookups hl
   where hl.lookup_type = 'FR_DEPARTMENT'
   and p_hire_date
       between nvl(hl.start_date_active,p_hire_date)
       and nvl(hl.end_date_active,p_hire_date)
   and hl.lookup_code = p_region_of_birth
   and hl.enabled_flag = 'Y' order by hl.meaning;


  BEGIN

    --
    /* Added for GSI Bug 5472781 */
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
       hr_utility.set_location('Leaving:'||l_proc , 10);
       return;
    END IF;
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);

    IF p_region_of_birth IS NOT NULL THEN
    	IF (p_country_of_birth <> 'FR') THEN
             hr_utility.set_message(800,'PER_FR_REGION_NULL_INFO');
             hr_utility.raise_error;
        ELSE

             OPEN  cur_dept;
             FETCH cur_dept INTO l_dept, l_dept_code;
              IF cur_dept%NOTFOUND THEN
                CLOSE cur_dept;
                hr_utility.set_message(800,'PER_FR_REGION_INVALID_INFO');
                hr_utility.raise_error;
              END IF;
             CLOSE cur_dept;
        END IF;
    END IF;

    IF p_country_of_birth = 'FR'
       AND p_per_information10 IS NOT NULL THEN
         hr_utility.set_message(800,'PER_FR_DATE_ENTERED_INFO');
         hr_utility.raise_error;

    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc, 20);
  END check_regn_entry_ins;



  PROCEDURE check_regn_entry_upd(p_region_of_birth          VARCHAR2
                                ,p_country_of_birth	    VARCHAR2
                                ,p_per_information10        VARCHAR2
                                ,p_effective_date           DATE
                                ,p_person_id                NUMBER
                                ) IS

   l_proc                 VARCHAR2(200) := g_package||'check_regn_entry_upd';
   l_dept                 hr_lookups.meaning%TYPE;
   l_dept_code	          hr_lookups.lookup_code%TYPE;
   l_old_region_of_birth  per_all_people_f.region_of_birth%TYPE;
   l_old_country_of_birth per_all_people_f.country_of_birth%TYPE;
   l_old_information10    per_all_people_f.per_information10%TYPE;
   l_use_region_of_birth  per_all_people_f.region_of_birth%TYPE;
   l_use_country_of_birth per_all_people_f.country_of_birth%TYPE;
   l_use_information10    per_all_people_f.per_information10%TYPE;

   CURSOR cur_dept IS
   select hl.meaning, hl.lookup_code
   from hr_lookups hl
   where hl.lookup_type = 'FR_DEPARTMENT'
   and p_effective_date
       between nvl(hl.start_date_active,p_effective_date)
       and nvl(hl.end_date_active,p_effective_date)
   and hl.lookup_code = l_use_region_of_birth
   and hl.enabled_flag = 'Y' order by hl.meaning;


  BEGIN

    --
    /* Added for GSI Bug 5472781 */
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
       hr_utility.set_location('Leaving:'|| l_proc , 10);
       return;
    END IF;
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('region:'|| p_region_of_birth);
    hr_utility.trace('country:'|| p_country_of_birth);
    hr_utility.trace('entered:'|| p_per_information10);
    hr_utility.trace('date:'|| to_char(p_effective_date));
        -- get the old values, or the updated new values - remove the default placeholders
        select region_of_birth, country_of_birth, per_information10
        into   l_old_region_of_birth, l_old_country_of_birth, l_old_information10
        from   per_all_people_f
        where  person_id = p_person_id
        and    p_effective_Date between effective_start_date and effective_end_Date;
        -- only use the old values if the new are not changing
        IF val_changed(p_region_of_birth) THEN
          l_use_region_of_birth := p_region_of_birth;
        ELSE
          l_use_region_of_birth := l_old_region_of_birth;
        END IF;
        --
        IF val_changed(p_country_of_birth) THEN
          l_use_country_of_birth := p_country_of_birth;
        ELSE
          l_use_country_of_birth := l_old_country_of_birth;
        END IF;
        --
        IF val_changed(p_per_information10) THEN
          l_use_information10 := p_per_information10;
        ELSE
          l_use_information10 := l_old_information10;
        END IF;
        -- validation of these fields is only necessary if one of them has changed
        --
        IF l_use_region_of_birth IS NOT NULL THEN
           IF (nvl(l_use_country_of_birth, '  ' ) <> 'FR') THEN
    	   --Error if region is set country must be France
             hr_utility.set_message(800,'PER_FR_REGION_NULL_INFO');
             hr_utility.raise_error;
           ELSE
             -- Validate the department of birth
             OPEN  cur_dept;
             FETCH cur_dept INTO l_dept, l_dept_code;
             IF cur_dept%NOTFOUND THEN
                CLOSE cur_dept;
                hr_utility.set_message(800,'PER_FR_REGION_INVALID_INFO');
                hr_utility.raise_error;
             END IF;
             CLOSE cur_dept;
           END IF;
        END IF;

        IF nvl(l_use_country_of_birth,'  ')  = 'FR' AND l_use_information10 IS NOT NULL THEN
           --Error must not set both FR as country, and date first entered France
           hr_utility.set_message(800,'PER_FR_DATE_ENTERED_INFO');
           hr_utility.raise_error;
       END IF;

    hr_utility.set_location(' Leaving:'||l_proc, 20);
  END check_regn_entry_upd;
--
END per_fr_people_leg_hook;

/
