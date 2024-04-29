--------------------------------------------------------
--  DDL for Package Body HR_UTIL_MISC_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UTIL_MISC_SS" AS
/* $Header: hrutlmss.pkb 120.17.12010000.13 2010/05/13 10:22:35 ckondapi ship $ */

  g_package VARCHAR2(30) := 'HR_UTIL_MISC_SS.';
  g_debug boolean := hr_utility.debug_enabled;

  PROCEDURE initLoginPrsnCtx(p_eff_date IN DATE) IS
  l_proc constant varchar2(100) := g_package || ' initLoginPrsnCtx';
     CURSOR c_bg IS
        SELECT business_group_id, nvl(org_information10,'USD') currency_code
        FROM per_people_f ppf, hr_organization_information oi
        WHERE ppf.person_id = fnd_global.employee_id
        AND ppf.business_group_id = oi.organization_id
        AND oi.org_information_context = 'Business Group Information'
        AND g_eff_date between ppf.effective_start_date and ppf.effective_end_date;
  BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
    OPEN c_bg;
     hr_utility.trace('Going into Fetch after ( OPEN c_bg ): '|| l_proc);
    FETCH c_bg INTO g_loginPrsnBGId, g_loginPrsnCurrencyCode;
    CLOSE c_bg;
    g_rate_type := hr_currency_pkg.get_rate_type (
                    p_business_group_id => g_loginPrsnBGId
                   ,p_conversion_date => p_eff_date
                   ,p_processing_type => 'R');

  hr_utility.set_location('Leaving: '|| l_proc,15);
  END initLoginPrsnCtx;

/*
    Currency conversion function to return converted amount as a number.
    Input params - from amount, from currency code, conversion date,
    override(to) currecny (if override currency is not passed, preferred currency is used).
*/
FUNCTION get_in_preferred_currency_num(
    p_amount IN NUMBER
    ,p_from_currency IN VARCHAR2
    ,p_eff_Date IN DATE DEFAULT trunc(sysdate)
    ,p_override_currency IN VARCHAR2 default fnd_profile.value('ICX_PREFERRED_CURRENCY')
   ) RETURN NUMBER IS
   l_to_currency VARCHAR2(10);
   l_return NUMBER;
BEGIN
    if(p_amount is null) then
        return null;
    end if;
    if(p_from_currency is null) then
        return p_amount;
    end if;
/* Populate local variables, all these functions internally cache values*/
    if(p_override_currency is null or p_override_currency = 'ANY') then
        l_to_currency := p_from_currency;
    else
        l_to_currency := p_override_currency;
    end if;
    l_return := hr_currency_pkg.convert_amount(
            p_from_currency
           ,l_to_currency
           ,p_eff_date
           ,p_amount
           ,g_rate_type);
/* hr_currency_pkg.convert_amount returns negative value in case of invalid currency/date combination.
   Return the original value in such a case*/
    if(l_return>=0) then
        return l_return;
    else
        return p_amount;
    end if;
    Exception When Others then
        return p_amount;
END get_in_preferred_currency_num;

/*
    Currency conversion function to return the currency code into which
    get_in_preferred_currency would convert to.
    Input params - from currency code, conversion date,
    override (to) currecny (if override currency is not passed, preferred currency is used).
*/
FUNCTION get_preferred_currency(
    p_from_currency IN VARCHAR2
    ,p_eff_Date IN DATE DEFAULT trunc(sysdate)
    ,p_override_currency IN VARCHAR2 default fnd_profile.value('ICX_PREFERRED_CURRENCY')
) RETURN VARCHAR2 IS
l_to_currency VARCHAR2(10);
l_return NUMBER;
BEGIN
/* Populate local variables, all these functions internally cache values*/
    if(p_from_currency is null ) then
        return null;
    end if;
    if(p_override_currency is null or p_override_currency = 'ANY') then
        l_to_currency := p_from_currency;
    else
        l_to_currency := p_override_currency;
    end if;
    l_return := hr_currency_pkg.convert_amount(
            p_from_currency
           ,l_to_currency
           ,p_eff_date
           ,10
           ,g_rate_type);
/* hr_currency_pkg.convert_amount returns negative value in case of invalid currency/date combination.
   Return the original value in such a case*/
    if(l_return>=0) then
        return l_to_currency;
    else
        return p_from_currency;
    end if;
    Exception When Others then
        return p_from_currency;
END get_preferred_currency;

/*
    Currency conversion function to return the converted amount concatenated with the currency as a string.
    Input params - from amount, from currency code, conversion date,
    override (to) currecny (if override currency is not passed, preferred currency is used).
*/

FUNCTION get_in_preferred_currency_str(
    p_amount IN NUMBER
    ,p_from_currency IN VARCHAR2
    ,p_eff_Date IN DATE DEFAULT trunc(sysdate)
    ,p_override_currency IN VARCHAR2 default fnd_profile.value('ICX_PREFERRED_CURRENCY')
   ) RETURN VARCHAR2 IS
   l_to_currency VARCHAR2(10);
   l_converted_amount NUMBER;
BEGIN
    if(p_amount is null) then
        return null;
    end if;
    if(p_from_currency is null) then
        return p_amount;
    end if;
/* Populate local variables, all these functions internally cache values*/
    if(p_override_currency is null or p_override_currency = 'ANY') then
        l_to_currency := p_from_currency;
    else
        l_to_currency := p_override_currency;
    end if;
    if(l_to_currency=p_from_currency) then
        return to_char(p_amount,
            fnd_currency.get_format_mask(p_from_currency,25))
                 || ' ' || p_from_currency;
    end if;
    l_converted_amount := hr_currency_pkg.convert_amount(
            p_from_currency
           ,l_to_currency
           ,p_eff_Date
           ,p_amount
           ,g_rate_type);
/* hr_currency_pkg.convert_amount returns negative value in case of invalid currency/date combination.
   Return the original value in such a case*/
    if(l_converted_amount>=0) then
        fnd_message.set_name('PER','HR_MULTI_CURR_FMT');
        fnd_message.set_token('FROM_AMT',to_char(p_amount,
            fnd_currency.get_format_mask(p_from_currency,25)),false);
        fnd_message.set_token('FROM_CURR',p_from_currency,false);
        fnd_message.set_token('TO_AMT',to_char(l_converted_amount,
            fnd_currency.get_format_mask(l_to_currency,25)),false);
        fnd_message.set_token('TO_CURR',l_to_currency,false);
        return (fnd_message.get);
    else
        fnd_message.set_name('PER','HR_MULTI_CURR_FROM_FMT');
        fnd_message.set_token('FROM_AMT',to_char(p_amount,
            fnd_currency.get_format_mask(p_from_currency,25)),false);
        fnd_message.set_token('FROM_CURR',p_from_currency,false);
        return (fnd_message.get);
    end if;
    Exception When Others then
        fnd_message.set_name('PER','HR_MULTI_CURR_FROM_FMT');
        fnd_message.set_token('FROM_AMT',to_char(p_amount,
            fnd_currency.get_format_mask(p_from_currency,25)),false);
        fnd_message.set_token('FROM_CURR',p_from_currency,false);
        return (fnd_message.get);
END get_in_preferred_currency_str;

FUNCTION getCompSourceInfo (
    p_competence_id IN NUMBER
   ,p_person_id IN NUMBER
 ) RETURN VARCHAR2 IS

CURSOR c_srcInfo (p_cid IN NUMBER, p_pid IN NUMBER) IS
    SELECT 4 rank, hr_general.decode_lookup('STRUCTURE_TYPE','POS')||'#'||proficiency_level_id||'#'||high_proficiency_level_id src
    FROM  per_competence_elements ce, per_all_assignments_f paf
    WHERE ce.type = 'REQUIREMENT'
    AND trunc(sysdate) between nvl(ce.effective_date_from, sysdate) and nvl(ce.effective_date_to, sysdate)
    AND ce.position_id = paf.position_id
    AND paf.primary_flag = 'Y'
    AND paf.assignment_type in ('E', 'C')
    AND trunc(sysdate) between paf.effective_start_date and paf.effective_end_date
    AND (ce.proficiency_level_id is not null or ce.high_proficiency_level_id is not null)
    AND ce.competence_id = p_cid
    AND paf.person_id = p_pid
    UNION ALL
    SELECT 3 rank, hr_general.decode_lookup('STRUCTURE_TYPE','JOB')||'#'||proficiency_level_id||'#'||high_proficiency_level_id src
    FROM  per_competence_elements ce, per_all_assignments_f paf
    WHERE ce.type = 'REQUIREMENT'
    AND trunc(sysdate) between nvl(ce.effective_date_from, sysdate) and nvl(ce.effective_date_to, sysdate)
    AND ce.job_id = paf.job_id
    AND paf.primary_flag = 'Y'
    AND paf.assignment_type in ('E', 'C')
    AND trunc(sysdate) between paf.effective_start_date and paf.effective_end_date
    AND (ce.proficiency_level_id is not null or ce.high_proficiency_level_id is not null)
    AND ce.competence_id = p_cid
    AND paf.person_id = p_pid
    UNION ALL
    SELECT 2 rank, hr_general.decode_lookup('STRUCTURE_TYPE','ORG')||'#'||proficiency_level_id||'#'||high_proficiency_level_id src
    FROM  per_competence_elements ce, per_all_assignments_f paf
    WHERE ce.type = 'REQUIREMENT'
    AND trunc(sysdate) between ce.effective_date_from and nvl(ce.effective_date_to, sysdate)
    AND ce.organization_id = paf.organization_id
    AND paf.primary_flag = 'Y'
    AND paf.assignment_type in ('E', 'C')
    AND trunc(sysdate) between paf.effective_start_date and paf.effective_end_date
    AND (ce.proficiency_level_id is not null or ce.high_proficiency_level_id is not null)
    AND ce.competence_id = p_cid
    AND paf.person_id = p_pid
    UNION ALL
    SELECT 1 rank, hr_general.decode_lookup('STRUCTURE_TYPE','BUS')||'#'||proficiency_level_id||'#'||high_proficiency_level_id src
    FROM  per_competence_elements ce, per_all_assignments_f paf
    WHERE ce.type = 'REQUIREMENT'
    AND trunc(sysdate) between ce.effective_date_from and nvl(ce.effective_date_to, sysdate)
    AND ce.enterprise_id = paf.business_group_id
    AND paf.primary_flag = 'Y'
    AND paf.assignment_type in ('E', 'C')
    AND trunc(sysdate) between paf.effective_start_date and paf.effective_end_date
    AND (ce.proficiency_level_id is not null or ce.high_proficiency_level_id is not null)
    AND ce.competence_id = p_cid
    AND paf.person_id = p_pid
    UNION ALL
    SELECT 0 rank, hr_general.decode_lookup('STRUCTURE_TYPE','ADD')||'##' src
    FROM dual
    ORDER BY RANK DESC;

BEGIN
  For I in c_srcInfo(p_competence_id, p_person_id) Loop
       return I.src;
  End Loop;
END getCompSourceInfo;

  /**
   * Wrapper function that calls fnd_data_security.check_function and
   * check_cwk_access
   */
  FUNCTION validate_selected_function (
     p_api_version        IN  NUMBER
    ,p_function           IN  VARCHAR2
    ,p_object_name        IN  VARCHAR2
    ,p_person_id          IN  VARCHAR2 -- p_instance_pk1_value
    ,p_instance_pk2_value IN  VARCHAR2
    ,p_user_name          IN  VARCHAR2
    ,p_eff_date           IN DATE
  )
  RETURN VARCHAR2
  IS
    l_proc    varchar2(72) := g_package||' validate_selected_function';
    l_status  VARCHAR2(10):='F';
    l_asg_security VARCHAR2(10) := hr_general2.supervisor_assignments_in_use;
BEGIN

    IF g_debug then
       hr_utility.set_location('Entering: '|| l_proc, 5);
    END IF;

    IF (l_asg_security = 'TRUE' AND p_person_id <> '-1' ) THEN
      l_status := check_term_access(
                     p_function => p_function,
                     p_person_id => TO_NUMBER(p_person_id),
                     p_eff_date =>  p_eff_date);
    ELSE
      l_status := 'T';
    END IF;


    IF (l_status = 'T' AND p_person_id <> '-1' ) THEN
     hr_utility.trace('In (   IF (l_status = T AND p_person_id <> -1 ) ): '|| l_proc);
      IF g_debug then
        hr_utility.set_location('Entering: '|| 'fnd_data_security.check_function', 10);
      END IF;

      l_status := fnd_data_security.check_function(
                    p_api_version => p_api_version
                   ,p_function => p_function
                   ,p_object_name => p_object_name
                   ,p_instance_pk1_value => p_person_id
                   ,p_instance_pk2_value => p_instance_pk2_value);
      IF l_status = 'E' OR l_status = 'U' THEN
        hr_utility.trace('Error in fnd_data_security.check_function l_status is: '||l_status||'. Error is: '|| replace(fnd_message.get_encoded(), chr(0), ' '));
        l_status := 'F';
      END IF;

      IF g_debug then
        hr_utility.set_location('Leaving: '|| 'fnd_data_security.check_function', 15);
      END IF;
    END IF;

    IF (l_status = 'T' AND p_person_id <> '-1' ) THEN
      l_status := check_cwk_access(
                     p_function => p_function,
                     p_person_id => TO_NUMBER(p_person_id),
                     p_eff_date =>  p_eff_date);
    END IF;

    IF g_debug then
       hr_utility.set_location('Leaving: '||l_proc, 20);
    END IF;

    RETURN l_status;
  END validate_selected_function;

  /**
   * This function is used to return the named user id
   */
  function get_person_id return number is
  --
  cursor get_sec_person_id(p_security_profile_id number) is
  select named_person_id
  from per_security_profiles
  where security_profile_id=p_security_profile_id;
  --
  cursor get_user_person_id(p_user_id number) is
  select employee_id
  from fnd_user
  where user_id=p_user_id;
  --
  l_person_id number;
  --
  begin
  --
  open get_sec_person_id(hr_security.get_security_profile);
  fetch get_sec_person_id into l_person_id;
  close get_sec_person_id;
  if l_person_id is null then
    open get_user_person_id(fnd_global.user_id);
    fetch get_user_person_id into l_person_id;
    close get_user_person_id;
  end if;
  --
  return l_person_id;
  --
  end get_person_id;

  /**
   * This function is used to extract the parameter value from the parameter
   * list. The return values and their meanings are :
   * 1) ERROR - This parameter is not in this list or Exception raised
   * 2) NULL  - Value of this parameter is null
   * 3) The value of the parameter itself
   */
  FUNCTION get_parameter_value (
     p_parameter_list IN VARCHAR2
    ,p_parameter      IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
    l_smarker INTEGER;
    l_emarker INTEGER;
    l_proc constant varchar2(100) := g_package || ' get_parameter_value';
  BEGIN
      hr_utility.set_location('Entering: '|| l_proc,5);
      l_smarker := instr(p_parameter_list, p_parameter);

      if (l_smarker = 0) THEN
	  hr_utility.set_location('Leaving: '|| l_proc,10);
	   RETURN NULL;

	   END IF;

      l_smarker := l_smarker + LENGTH(p_parameter)+1;
      l_emarker := INSTR(p_parameter_list, '&', l_smarker);

      IF (l_emarker <= 0) THEN
	   l_emarker := LENGTH(p_parameter_list)+1;
      END IF;
      hr_utility.set_location('Leaving: '|| l_proc,15);

      RETURN SUBSTR(p_parameter_list, l_smarker, l_emarker - l_smarker);
  EXCEPTION
    WHEN OTHERS THEN
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      RETURN NULL;
  END get_parameter_value;



  /**
   * Checks for the Term access of the function returns a N or T
   */
  FUNCTION check_term_access (
     p_function   IN VARCHAR2
    ,p_person_id  IN NUMBER
    ,p_eff_date   IN DATE
  )
  RETURN VARCHAR2
  IS
    l_proc    varchar2(72) := g_package||' check_term_access';
    l_status VARCHAR2(10):= 'N';
    l_item_type hr_api_transactions.item_type%type;
    l_temp VARCHAR2(100);
    l_function_name fnd_form_functions.function_name%Type;

    -- Local Cursors
    CURSOR csr_fnd_func_details (p_func_name VARCHAR2)IS
      SELECT function_id, parameters, web_html_call
      FROM fnd_form_functions fff
      WHERE fff.function_name = p_func_name;


    CURSOR csr_wf_process (p_wfpname VARCHAR2, p_item_type VARCHAR2) IS
    SELECT 'N' status
     FROM WF_PROCESS_ACTIVITIES pa1, WF_PROCESS_ACTIVITIES pa2,
         WF_ACTIVITIES a1, WF_ACTIVITIES a2, WF_ACTIVITY_ATTR_VALUES  aav
     WHERE pa1.process_item_type = p_item_type
     and pa1.process_name = p_wfpname
     and pa1.activity_name = pa2.process_name
     and a1.name = pa1.process_name
     and pa1.process_version = a1.version
     and a1.item_type = p_item_type
     and sysdate between a1.begin_date and nvl(a1.end_date,sysdate)
     and pa2.process_item_type = p_item_type
     and pa2.process_name = a2.name
     and pa2.process_version = a2.version
     and a2.item_type = p_item_type
     and sysdate between a2.begin_date and nvl(a2.end_date,sysdate)
     and pa2.instance_id = aav.process_activity_id
     and aav.name = 'HR_ACTIVITY_TYPE_VALUE'
     and aav.text_value IN ('HR_TERMINATION_TOP_SS','HR_CWK_TERMINATION_PAGE_SS')
   UNION
    SELECT 'N' status
     FROM WF_ACTIVITIES a, WF_PROCESS_ACTIVITIES pa,
          WF_ACTIVITY_ATTR_VALUES  aav
     where a.item_type = p_item_type
     and a.name = p_wfpname
     and sysdate between a.begin_date and nvl(a.end_date,sysdate)
     and pa.process_item_type = a.item_type
     and pa.process_name = a.name
     and pa.process_version = a.version
     and pa.instance_id = aav.process_activity_id
     and aav.name = 'HR_ACTIVITY_TYPE_VALUE'
     and aav.text_value IN ('HR_TERMINATION_TOP_SS','HR_CWK_TERMINATION_PAGE_SS');

    l_func_details csr_fnd_func_details%ROWTYPE;
  BEGIN
    IF g_debug then
       hr_utility.set_location('Entering: '|| l_proc, 5);
    END IF;

    OPEN csr_fnd_func_details (p_function);
    hr_utility.trace('Going into Fetch after (OPEN csr_fnd_func_details (p_function)): '|| l_proc);
    FETCH csr_fnd_func_details INTO l_func_details;
    CLOSE csr_fnd_func_details;
    -- Overriding p_function value depending on pCalledFrom value
    l_function_name := nvl(get_parameter_value(l_func_details.parameters,
                         'pCalledFrom'),p_function);

    IF l_function_name <> p_function THEN
      OPEN csr_fnd_func_details (l_function_name);
       hr_utility.trace('Going into Fetch after (OPEN csr_fnd_func_details (l_function_name)): '|| l_proc);
      FETCH csr_fnd_func_details INTO l_func_details;
      CLOSE csr_fnd_func_details;
    END IF;

    -- Checks whether this function is workflow based
    IF (INSTR(l_func_details.parameters, 'pProcessName') <> 0) THEN
     hr_utility.trace('In(  IF (INSTR(l_func_details.parameters, pProcessName) <> 0)): '|| l_proc);
      l_temp := get_parameter_value(l_func_details.parameters,
                  'pProcessName');

      IF (l_temp is not null) THEN
         hr_utility.trace('In( IF (l_temp is not null)): '|| l_proc);
        l_item_type := get_parameter_value(l_func_details.parameters,
                         'pItemType');
        OPEN csr_wf_process (l_temp, l_item_type);
    hr_utility.trace('Going into Fetch after( OPEN csr_wf_process (l_temp, l_item_type))): '|| l_proc);
        FETCH csr_wf_process INTO l_status;
        IF csr_wf_process%NOTFOUND THEN
          l_status := 'T';
        ELSE
          l_status := check_primary_access(p_person_id, p_eff_date);
        END IF;
        CLOSE csr_wf_process;

      END IF;
    ELSE
     hr_utility.trace('In else of (IF (INSTR(l_func_details.parameters, pProcessName) <> 0)): '|| l_proc);
      l_status := 'T';
    END IF;

    IF g_debug then
      hr_utility.set_location('Leaving: '||l_proc, 30);
    END IF;

    RETURN l_status; -- if status is N then it is no term access

  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      RETURN 'N';
  END check_term_access;

  /**
   * Checks for the Primary access of the function returns a N or T
   */

  FUNCTION check_primary_access (
  p_selected_person_id NUMBER,
  p_effective_date     DATE)
  RETURN VARCHAR2 IS


    cursor fetch_asg (l_person_id NUMBER, l_effective_date DATE) is
      SELECT 'T'
        FROM per_assignments_f2 paf, per_assignment_status_types past
       WHERE paf.person_id = l_person_id
         AND l_effective_date between paf.effective_start_date and paf.effective_end_date
         AND paf.primary_flag = 'Y'
         AND paf.assignment_type IN ('E', 'C')
         AND paf.assignment_status_type_id = past.assignment_status_type_id
         AND past.per_system_status NOT IN ('TERM_ASSIGN','END');

     l_status VARCHAR2(1) := 'N';

     l_proc    varchar2(72) := g_package||'check_primary_access';
  BEGIN
     IF g_debug then
        hr_utility.set_location('Entering: '|| l_proc, 5);
     END IF;

     OPEN fetch_asg (p_selected_person_id, p_effective_date);
     hr_utility.trace('Going into Fetch after (OPEN fetch_asg (p_selected_person_id, p_effective_date) ): '|| l_proc);
     FETCH fetch_asg INTO l_status;

     IF fetch_asg%NOTFOUND THEN
        l_status := 'N';
     END IF;

     CLOSE fetch_asg;

     IF g_debug then
        hr_utility.set_location('Leaving: '||l_proc, 10);
     END IF;

     RETURN l_status;

  END check_primary_access;


  /**
   * This function checks whether the akregion code is in the
   * CWK exclusion list. If Yes the return 'C' else 'T'
   */
  FUNCTION check_akregion_code (
    p_ak_region  IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
    l_status VARCHAR2(10):='C';
    --local variables
   l_proc constant varchar2(100) := g_package || '  check_akregion_code';
    -- CWK Phase III Changes,
    -- Following functions are being made available for CWK
                            -- 'HR_ASSIGNMENT_TOP_SS',
                            -- 'HR_WORK_SCHED_TOP_SS',
                            -- 'HR_MANAGER_TOP_SS',
                            -- 'HR_P_RATE_TOP_SS',
                            -- 'HR_TERMINATION_TOP_SS',
                            -- 'HR_ASSIGNMENT_TOP_SS',
                            -- 'HR_NEWHIRE_PERSON_TOP_SS',
                            -- 'HR_CAED_TOP_SS'
    CURSOR csr_akregion_list IS
      SELECT 'C' FROM dual
      WHERE UPPER(p_ak_region) IN (
                            'HR_CCMGR_OVERVIEW_TOP_SS',
                            'PQH_ACADEMIC_RANK_TOP',
                            'PQH_ACADEMIC_RANK_OVRVW_TOP',
                            'PQH_TENURE_STATUS_OVRVW_TOP',
                            'PQH_TENURE_STATUS_TOP',
                            'PQH_REVIEW_FIND_TOP',
                            --'OTA_TRAINING_TOP_SS',
                            --'OTA_ADDTRNG_OVERVIEW_TOP_SS',
                            --'PQH_REVIEWS_TOP',
                            --'PQH_EVENTS_MGR_SEARCH_TOP',
                            'HR_LOA_SUMMARY_TOP_SS'
);

  BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
    OPEN csr_akregion_list;
    hr_utility.trace('Going into Fetch after ( OPEN csr_akregion_list ): '|| l_proc);
    FETCH csr_akregion_list INTO l_status;
    IF csr_akregion_list%NOTFOUND
    THEN
      l_status := 'T';
    END IF;
    CLOSE csr_akregion_list;

    RETURN l_status;
    hr_utility.set_location('Leaving: '|| l_proc,15);
  END check_akregion_code;

  /**
   * Checks for the CWK access of the function returns a C or T
   */

  FUNCTION check_cwk_access (
     p_function   IN VARCHAR2
    ,p_person_id  IN NUMBER
    ,p_eff_date   IN DATE
  )
  RETURN VARCHAR2
  IS
    l_proc    varchar2(72) := g_package||'check_cwk_access';
    l_status VARCHAR2(10):= 'C';
    l_npw_status VARCHAR2(30);
    l_item_type hr_api_transactions.item_type%type;
    l_temp VARCHAR2(100);
    l_function_name fnd_form_functions.function_name%Type;

    -- Local Cursors
    CURSOR csr_per_npw_flag IS
      SELECT nvl(current_npw_flag,'N')
      FROM per_all_people_f per
      WHERE per.person_id = p_person_id
      AND p_eff_date BETWEEN per.effective_start_date AND per.effective_end_date;

    CURSOR csr_fnd_func_details (p_func_name VARCHAR2)IS
      SELECT function_id, parameters, web_html_call
      FROM fnd_form_functions fff
      WHERE fff.function_name = p_func_name;

    CURSOR csr_menu_entries (p_menu_name VARCHAR2, p_func_id NUMBER) IS
    select 'T' from fnd_menus m, fnd_menu_entries me
    where menu_name = p_menu_name
    and m.menu_id = me.menu_id
    and me.function_id = p_func_id;

    CURSOR csr_wf_process (p_wfpname VARCHAR2, p_item_type VARCHAR2) IS
     SELECT 'C' status
     FROM WF_ACTIVITIES a, WF_PROCESS_ACTIVITIES pa,
          WF_ACTIVITY_ATTR_VALUES  aav
     where a.item_type = p_item_type
     and a.name = p_wfpname
     and sysdate between a.begin_date and nvl(a.end_date,sysdate)
     and pa.process_item_type = a.item_type
     and pa.process_name = a.name
     and pa.process_version = a.version
     and pa.instance_id = aav.process_activity_id
     and aav.name = 'HR_ACTIVITY_TYPE_VALUE'
     and  'C' = hr_util_misc_ss.check_akregion_code(text_value);

    l_func_details csr_fnd_func_details%ROWTYPE;
  BEGIN
    IF g_debug then
       hr_utility.set_location('Entering: '|| l_proc, 5);
    END IF;

    OPEN csr_per_npw_flag;
    hr_utility.trace('Going into Fetch after (OPEN csr_per_npw_flag ): '|| l_proc);
    FETCH csr_per_npw_flag INTO l_npw_status;
    IF csr_per_npw_flag%NOTFOUND THEN
      hr_utility.set_message(800,'PER_52097_APL_INV_PERSON_ID');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_per_npw_flag;
    IF (l_npw_status <> 'Y') THEN
    hr_utility.set_location('Leaving: '|| l_proc,15);
      RETURN 'T';
    END IF;

    OPEN csr_fnd_func_details (p_function);
      hr_utility.trace('Going into Fetch after (  OPEN csr_fnd_func_details (p_function)): '|| l_proc);
    FETCH csr_fnd_func_details INTO l_func_details;
    CLOSE csr_fnd_func_details;
    -- Overriding p_function value depending on pCalledFrom value
    l_function_name := nvl(get_parameter_value(l_func_details.parameters,
                         'pCalledFrom'),p_function);
    IF l_function_name <> p_function THEN
      OPEN csr_fnd_func_details (l_function_name);
        hr_utility.trace('Going into Fetch after (OPEN csr_fnd_func_details (l_function_name)): '|| l_proc);
      FETCH csr_fnd_func_details INTO l_func_details;
      CLOSE csr_fnd_func_details;
    END IF;

    -- Checks whether this function is workflow based
    IF (INSTR(l_func_details.parameters, 'pProcessName') <> 0) THEN
  hr_utility.trace('In( IF (INSTR(l_func_details.parameters, pProcessName) <> 0) '|| l_proc);
      l_temp := get_parameter_value(l_func_details.parameters,
                  'pProcessName');
      IF (l_temp is not null) THEN
        l_item_type := get_parameter_value(l_func_details.parameters,
                         'pItemType');
        OPEN csr_wf_process (l_temp, l_item_type);
         hr_utility.trace('Going into Fetch after (OPEN csr_wf_process (l_temp, l_item_type)): '|| l_proc);
        FETCH csr_wf_process INTO l_status;
        IF csr_wf_process%NOTFOUND THEN
          l_status := 'T';
        END IF;
        CLOSE csr_wf_process;

      END IF;

    ELSE
      hr_utility.trace('In else of ( IF (INSTR(l_func_details.parameters, pProcessName) <> 0) '|| l_proc);

      l_temp := nvl(get_parameter_value(l_func_details.web_html_call,
                    'akRegionCode'),
                    get_parameter_value(l_func_details.web_html_call,
                    'OAFunc')
                  );
      l_status := check_akregion_code(l_temp);
    END IF;

    IF g_debug then
       hr_utility.set_location('Leaving: '||l_proc, 40);
    END IF;

    RETURN l_status;
  EXCEPTION
    WHEN OTHERS THEN

hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      RETURN 'C';
  END check_cwk_access;

  PROCEDURE clear_cache
  IS
   --local variable
  l_proc constant varchar2(100) := g_package || '  clear_cache';
  BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
    g_entity_list.delete;
    -- g_entitydetail_list.delete;
    hr_utility.set_location('Leaving: '|| l_proc,10);
  END clear_cache;

  FUNCTION entity_exists (
    p_entity_id IN NUMBER
  )
  RETURN VARCHAR2
  IS
   --local variable
   l_proc constant varchar2(100) := g_package || '  entity_exists';
  BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
    IF g_entity_list.exists(p_entity_id) THEN
    hr_utility.set_location('Leaving: '|| l_proc,10);
      RETURN 'T';
    END IF;
    hr_utility.set_location('Leaving: '|| l_proc,15);
    RETURN 'F';
  EXCEPTION
    WHEN others THEN
       hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      RETURN 'F';
  END entity_exists;

  PROCEDURE populate_entity_list (
    p_elist IN HR_MISC_SS_NUMBER_TABLE,
    p_retain_cache IN VARCHAR2
  )
  IS
  --local variable
   l_proc constant varchar2(100) := g_package || ' populate_entity_list';
  BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
    if p_retain_cache = 'N'
    then
      clear_cache();
    end if;
    FOR I IN 1 ..p_elist.count LOOP
      g_entity_list(p_elist(i)) := p_elist(i);
    END LOOP;
    hr_utility.set_location('Leaving: '|| l_proc,10);
  END populate_entity_list;

  PROCEDURE check_ota_installed (appl_id number, status out nocopy varchar2) is
  l_status    VARCHAR2(1);
  l_industry  VARCHAR2(10);
  l_flag   boolean;
  --local variable
   l_proc constant varchar2(100) := g_package || ' check_ota_installed';
  begin
  hr_utility.set_location('Entering: '|| l_proc,5);
    l_flag := fnd_installation.get(appl_id => appl_id,
                         dep_appl_id => appl_id,
                         status => l_status,
                         industry => l_industry );

    if l_status = 'I' then
        status := 'Y';
    else
        status := 'N';
    end if;
	  hr_utility.set_location('Leaving: '|| l_proc,10);
  end check_ota_installed;

 FUNCTION get_employee_salary(
    p_assignment_id IN NUMBER
    ,P_Effective_Date IN date
   ) RETURN NUMBER IS
    ln_proposed_salary  NUMBER;
    lv_frequency VARCHAR2(100);
    ln_annual_salary NUMBER;
    lv_pay_basis_name VARCHAR2(100);
    lv_reason_cd  VARCHAR2(100);
    ln_currency  VARCHAR2(100);
    ln_status NUMBER;
    lv_pay_basis_frequency per_pay_bases.pay_basis%TYPE;
 begin
    pqh_employee_salary.get_employee_salary(
        P_Assignment_id  =>    p_assignment_id,
        P_Effective_Date  =>    p_effective_date,
        p_salary =>    ln_proposed_salary,
        p_frequency =>    lv_frequency,
        p_annual_salary =>    ln_annual_salary,
        p_pay_basis =>    lv_pay_basis_name,
        p_reason_cd =>    lv_reason_cd,
        p_currency =>    ln_currency,
        p_status =>    ln_status,
        p_pay_basis_frequency =>    lv_pay_basis_frequency);

    return ln_annual_salary;
  end get_employee_salary;

  FUNCTION get_employee_salary(
     p_assignment_id in number
    ,p_Effective_Date  in date
    ,p_proposed_salary IN NUMBER
    ,p_pay_annual_factor IN number
    ,p_pay_basis in varchar2
   ) RETURN NUMBER IS
     l_fte_profile_value VARCHAR2(30) := fnd_profile.VALUE('PER_ANNUAL_SALARY_ON_FTE');
     l_pay_factor number;
     l_fte_factor  NUMBER;
     ln_annual_salary NUMBER;
  begin
     l_pay_factor := p_pay_annual_factor;
     if (p_pay_annual_factor is null OR p_pay_annual_factor = 0) then
            l_pay_factor := 1;
    end if;
    ln_annual_salary := p_proposed_salary * l_pay_factor;
    if ((l_fte_profile_value is null OR l_fte_profile_value = 'Y') AND p_pay_basis = 'HOURLY') then
           l_fte_factor := per_saladmin_utility.get_fte_factor(p_assignment_id,p_Effective_Date);
           ln_annual_salary := ln_annual_salary * l_fte_factor;
    end if;
    return ln_annual_salary;
  end get_employee_salary;

  FUNCTION get_apl_asgs_count(
    p_person_id IN number,
    p_effective_date IN date)
  return number
  is
  CURSOR csr_apl_asgs_count is
    select assignment_id from per_all_assignments_f
    where person_id = p_person_id and assignment_type = 'A' and
    p_effective_date between effective_start_date and effective_end_date;
    l_apl_asgs_count          INTEGER := 0;
  begin
    FOR l_apl_asgs_rec IN csr_apl_asgs_count
    LOOP
       l_apl_asgs_count := l_apl_asgs_count + 1;
    END LOOP;
    RETURN(l_apl_asgs_count);
  END get_apl_asgs_count;


  PROCEDURE is_voluntary_termination (
    itemtype in     varchar2,
    itemkey  in     varchar2,
    actid    in     number,
    funcmode in     varchar2,
    resultout   out nocopy varchar2
  )
  IS
  l_number_value  wf_activity_attr_values.number_value%type;
   l_proc constant varchar2(100) := g_package || ' is_voluntary_termination';
  dummy varchar2(2) := 'N';
  l_vol_term varchar2(2) := 'N';

	cursor csr_attr_value(actid in number, name in varchar2) is
					SELECT WAAV.TEXT_VALUE Value
					FROM WF_ACTIVITY_ATTR_VALUES WAAV
					WHERE WAAV.PROCESS_ACTIVITY_ID = actid
					AND WAAV.NAME = name;

  BEGIN

    hr_utility.set_location('Entering: '|| l_proc,5);

  l_number_value := wf_engine.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'CURRENT_PERSON_ID');

	if (l_number_value = fnd_global.employee_id) then
		dummy := 'Y';
	end if;

	if (dummy = 'Y') then
		l_vol_term := wf_engine.getitemattrtext(itemtype, itemkey,
                                                'HR_VOL_TERM_SS',true);
		if (l_vol_term is null OR l_vol_term <> 'Y') then
	  	dummy := 'N';
		end if;
	end if;

	if (dummy = 'Y') then
		open csr_attr_value(actid,'BYPASS_CHG_MGR');
		fetch csr_attr_value into dummy;
		close  csr_attr_value;
	end if;

  if (dummy = 'Y')
  then
    resultout := 'COMPLETE:'|| 'Y';
  else
    resultout := 'COMPLETE:'|| 'N';
  end if;
  --
  	  hr_utility.set_location('Leaving: '|| l_proc,10);

  EXCEPTION
    WHEN OTHERS THEN

    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      WF_CORE.CONTEXT (
        g_package,
        'is_voluntary_termination',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode);
    RAISE;
  END is_voluntary_termination;

  PROCEDURE is_primary_assign (
    itemtype in     varchar2,
    itemkey  in     varchar2,
    actid    in     number,
    funcmode in     varchar2,
    resultout   out nocopy varchar2
  )
  IS
  l_number_value  wf_activity_attr_values.number_value%type;
  l_date_value  wf_activity_attr_values.date_value%type;
   l_proc constant varchar2(100) := g_package || ' is_primary_assign';
  dummy varchar2(2);

  BEGIN

    hr_utility.set_location('Entering: '|| l_proc,5);

hr_approval_ss.create_item_attrib_if_notexist(itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname   => 'HR_TERM_SEC_ASG'
                               ,text_value=>'Y'
                               ,number_value=>null,
                               date_value=>null
                               );

  l_number_value := wf_engine.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'CURRENT_ASSIGNMENT_ID');

  l_date_value := wf_engine.GetItemAttrDate (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'CURRENT_EFFECTIVE_DATE');

select primary_flag into dummy from per_all_assignments_f
where assignment_id=l_number_value and l_date_value between effective_start_date
and effective_end_date;

  if dummy = 'Y'
  then
    resultout := 'COMPLETE:'|| 'Y';
  else
    resultout := 'COMPLETE:'|| 'N';
  end if;
  --
  	  hr_utility.set_location('Leaving: '|| l_proc,10);

  EXCEPTION
    WHEN OTHERS THEN

    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      WF_CORE.CONTEXT (
        g_package,
        'branch_on_approval_flag',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode);
    RAISE;
  END is_primary_assign;

   FUNCTION get_assign_termination_date(
	p_assignment_id IN number)
   return date is
   l_asg_term_date date;
   begin
      select min(asg.EFFECTIVE_start_DATE) into l_asg_term_date
      from per_all_assignments_f asg ,per_assignment_status_types ast
      where asg.assignment_id =  p_assignment_id
      and ast.assignment_status_type_id =  asg.assignment_status_type_id
      and ast.per_system_status         =  'TERM_ASSIGN';

      if l_asg_term_date is null then
         select max(EFFECTIVE_end_DATE) into l_asg_term_date
         from per_all_assignments_f where assignment_id =  p_assignment_id;
         if l_asg_term_date = hr_api.g_eot then
            l_asg_term_date := null;
         end if;
      end if;

   return l_asg_term_date;
   end get_assign_termination_date;

  PROCEDURE is_employee_check (
    itemtype in     varchar2,
    itemkey  in     varchar2,
    actid    in     number,
    funcmode in     varchar2,
    resultout   out nocopy varchar2
  )
  IS
  l_text_value  wf_activity_attr_values.text_value%type;
    --local variable
   l_proc constant varchar2(100) := g_package || ' is_employee_check';
  BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
  --
  l_text_value := wf_engine.GetItemAttrText (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'HR_SELECTED_PERSON_TYPE_ATTR');
  if l_text_value = 'C'
  then
    resultout := 'COMPLETE:'|| 'N';
  else
    resultout := 'COMPLETE:'|| 'Y';
  end if;
  --
  	  hr_utility.set_location('Leaving: '|| l_proc,10);
  EXCEPTION
    WHEN OTHERS THEN

    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      WF_CORE.CONTEXT (
        g_package,
        'branch_on_approval_flag',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode);
    RAISE;
  END is_employee_check;

  PROCEDURE populateInterimPersonList (
    person_data  PER_INTERIM_PERSON_LIST_STRUCT
  )
  IS
   --local variable
   l_proc constant varchar2(100) := g_package || ' populateInterimPersonList';
  BEGIN
      hr_utility.set_location('Entering: '|| l_proc,5);
    -- This commit is issued here to remove the Data from the Temp table.
    -- This can be replaced by truncate.
    --COMMIT;
    DELETE PER_INTERIM_PERSON_LIST;
    FOR i in 1.. person_data.count LOOP
        INSERT INTO PER_INTERIM_PERSON_LIST (person_id, assignment_id, in_my_list)
        values (person_data(i).person_id, person_data(i).assignment_id, person_data(i).in_my_list);
    END LOOP;
  	  hr_utility.set_location('Leaving: '|| l_proc,10);
  EXCEPTION
    WHEN others THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        RAISE;
  END populateInterimPersonList;

  PROCEDURE populateInterimListFromMyList (
    person_id number
  )
  IS
   --local variable
   l_proc constant varchar2(100) := g_package || ' populateInterimListFromMyList';
  BEGIN
   hr_utility.set_location('Entering: '|| l_proc,5);
    --COMMIT;
    DELETE PER_INTERIM_PERSON_LIST;
    INSERT INTO PER_INTERIM_PERSON_LIST (person_id, assignment_id, in_my_list)
    SELECT selected_person_id, selected_assignment_id, 'Y'
    FROM hr_working_person_lists
    WHERE owning_person_id = person_id;
  hr_utility.set_location('Leaving: '|| l_proc,10);
  EXCEPTION
    WHEN others THEN
       hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        RAISE;
  END populateInterimListFromMyList;

  PROCEDURE addToMyListFromInterimList (
    prsn_id number
  )
  IS
   --local variable
   l_proc constant varchar2(100) := g_package || ' addToMyListFromInterimList';
  BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
    INSERT INTO HR_WORKING_PERSON_LISTS(working_person_list_id, owning_person_id,
            selected_person_id, current_selection, multiple_selection, selected_assignment_id)
    SELECT  HR_WORKING_PERSON_LISTS_s.NEXTVAL,
            prsn_id,
            list.person_id,
            NULL,
            NULL,
            list.assignment_id
    FROM   PER_INTERIM_PERSON_LIST list;
    hr_utility.set_location('Leaving: '|| l_proc,10);
  EXCEPTION
    WHEN others THEN
     hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        RAISE;
  END addToMyListFromInterimList;

  PROCEDURE setEffectiveDate
     (p_effective_date    in  date)
  IS
   --
     PRAGMA AUTONOMOUS_TRANSACTION;
   --
      --local variable
   l_proc constant varchar2(100) := g_package || ' setEffectiveDate';
  BEGIN
   hr_utility.set_location('Entering: '|| l_proc,5);
    --
    g_eff_date := trunc(p_effective_date);
    --bug 5765957 start
    begin
      dt_fndate.set_effective_date(g_eff_date);
    exception
    when DUP_VAL_ON_INDEX then
      hr_utility.set_location('change for DUP_VAL_ON_INDEX : ' || l_proc ,999);
    when others then
      hr_utility.set_location('change for others : ' || l_proc ,998);
    end;
    --bug 5765957 end
    initLoginPrsnCtx(g_eff_date);
    g_year_start := to_date('01/01/'||to_char(g_eff_date,'RRRR'),'DD/MM/RRRR');
    --
    commit;
    --
     hr_utility.set_location('Leaving: '|| l_proc,10);
  EXCEPTION
    WHEN others THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      rollback;
      raise;
  END setEffectiveDate;

  FUNCTION getObjectName(
           p_object    IN varchar2,
           p_object_id IN number,
           p_bg_id     IN number,
           p_value     IN varchar2
         )
  return varchar2
  IS
      --local variable
   l_proc constant varchar2(100) := g_package || ' getObjectName';
  BEGIN
     hr_utility.set_location('Entering: '|| l_proc,5);
           IF PER_WORK_STRUCTURE_OVERRIDE_SS.isOverrideEnabled(p_object) THEN
               return nvl(PER_WORK_STRUCTURE_OVERRIDE_SS.getObjectName(p_object
	           , p_object_id, p_bg_id, p_value) ,p_value);
           END IF;
         hr_utility.set_location('Leaving: '|| l_proc,10);
           return p_value;
  END getObjectName;

  PROCEDURE initialize_am IS
  l_proc    varchar2(72) := g_package||'initialize_am';
  BEGIN

     -- If g_debug is only set at package level
     -- logging will not work consistently
     --
     g_debug := hr_utility.debug_enabled;

     IF g_debug then
       hr_utility.set_location('Entering: '|| l_proc, 5);
     END IF;


     -- 3952978
     --
     -- Mark HR Security cache as invalid. The next time a secure view
     -- is accessed - cache will be rebuilt. This is the equivalent of
     -- code calling fnd_global.apps_initialize but where the HR signon
     -- callback is not called - ie user/resp/sc context has not changed.
     --

     if ( nvl(fnd_profile.value('HR_SEC_INIT_AM'),'N') = 'Y')
     then
        hr_signon.session_context := hr_signon.session_context + 1;
     end if;

  END initialize_am ;

  FUNCTION getEnableSecurityGroups RETURN VARCHAR2 IS

   l_enableSecGroups varchar2(10);
   defined_z BOOLEAN;

  BEGIN

    l_enableSecGroups := nvl(fnd_profile.value('ENABLE_SECURITY_GROUPS'),'N');

    IF (nvl(fnd_global.application_short_name,'#') <> 'PER' AND l_enableSecGroups <> 'Y') THEN
     fnd_profile.get_specific('ENABLE_SECURITY_GROUPS',NULL,NULL,'800',l_enableSecGroups,defined_z,NULL,NULL);
     IF (nvl(l_enableSecGroups,'N') <> nvl(fnd_profile.value('ENABLE_SECURITY_GROUPS'),'N')) THEN
      fnd_profile.put('ENABLE_SECURITY_GROUPS', l_enableSecGroups);
     END IF;
    END IF;

    RETURN l_enableSecGroups;

  EXCEPTION When Others then
     RETURN 'N';
  END getEnableSecurityGroups;

  PROCEDURE SET_SYS_CTX (
    p_legCode in varchar2
   ,p_bgId    in varchar2
  ) IS

    l_secGrpId     number;
    l_enableSecGrp varchar2(10);
  BEGIN

    l_secGrpId := 0;
    l_enableSecGrp := getEnableSecurityGroups;

    IF p_legCode IS NOT NULL THEN
      HR_API.SET_LEGISLATION_CONTEXT(p_legCode);
    END IF;


    IF (p_bgId IS NOT NULL AND l_enableSecGrp = 'Y' ) THEN
     BEGIN

       select security_group_id into l_secGrpId
       from fnd_security_groups
       where security_group_key = p_bgId;

       fnd_client_info.set_security_group_context(to_char(l_secGrpId));
      -- Fix for bug 5531282 , this reverts the earlier fix for bug 5084537
       --FND_GLOBAL.set_security_group_id_context(l_secGrpId);

      EXCEPTION When Others then
       fnd_client_info.set_security_group_context(to_char(l_secGrpId));
       -- Fix for bug 5531282 , this reverts the earlier fix for bug 5084537
      -- FND_GLOBAL.set_security_group_id_context(l_secGrpId);
     END;
    END IF;

  EXCEPTION
    WHEN others THEN
     raise;
  END SET_SYS_CTX;

  PROCEDURE populateInterimEntityList (
    entity_data  PER_INTERIM_ENTITY_LIST_STRUCT
   ,p_retain_cache IN VARCHAR2
  )
  IS
   --local variable
   l_proc constant varchar2(100) := g_package || ' populateInterimEntityList';
  BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
     if p_retain_cache = 'N'
    then
        DELETE PER_INTERIM_ENTITY_LIST;
    end if;
    FOR i in 1.. entity_data.count LOOP
        INSERT INTO PER_INTERIM_ENTITY_LIST (entity_name,state,pk1,pk2,pk3,pk4,pk5)
        values (entity_data(i).entity_name, entity_data(i).state,entity_data(i).pk1,entity_data(i).pk2,entity_data(i).pk3,entity_data(i).pk4,entity_data(i).pk5);
    END LOOP;
  	  hr_utility.set_location('Leaving: '|| l_proc,10);
  EXCEPTION
    WHEN others THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        RAISE;
  END populateInterimEntityList;

 PROCEDURE clearInterimEntityList
    IS
    l_proc constant varchar2(100) := g_package || 'clearInterimEntityList';
  BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
    DELETE PER_INTERIM_ENTITY_LIST;
 END  clearInterimEntityList;

procedure isPersonTerminated (
   result out nocopy varchar2,
   p_person_id varchar2,
   p_assignment_id varchar2
  )
 is
   l_proc constant varchar2(100) := g_package || ' isPersonTerminated';
   assi_id varchar2(200) := null ;

  begin
   hr_utility.set_location('Entering: '|| l_proc,5);

      select assignment_id
      into assi_id
      from per_people_f ppf, per_assignments_f paf
      where paf.person_id = ppf.person_id
      and trunc(sysdate) between paf.effective_start_date(+) and paf.effective_end_date(+)
      and trunc(sysdate) between ppf.effective_start_date(+) and ppf.effective_end_date(+)
      and ppf.person_id = p_person_id
      and paf.assignment_id = p_assignment_id
      and nvl(ppf.CURRENT_EMP_OR_APL_FLAG,'N') = 'N' and nvl(ppf.CURRENT_EMPLOYEE_FLAG,'N') = 'N'
      and nvl(ppf.CURRENT_NPW_FLAG,'N') = 'N';

      if assi_id is not null then
        result := 'TRUE';
      else
        result := 'FASE';
        --break;
      end if;
   exception
      when no_data_found then
        result := 'FALSE';
        null;
      WHEN others THEN
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        result := 'TRUE';
  END isPersonTerminated;

 procedure getDeploymentPersonID (person_id in number, result out nocopy number )
 is
  cursor c_per is
  select from_person_id
  from hr_person_deployments dep
  where dep.to_person_id = person_id and permanent='Y';

  l_person_id number;
 begin
  for c in c_per loop
     l_person_id := c.from_person_id;
     result := l_person_id;
  end loop;
  result := person_id;
 exception
  when others then
      result := person_id;
 end;

 FUNCTION getBusinessGroup(
         p_function_id IN number,
         p_bg_id     IN number,
         p_person_id IN number
)
  return per_all_people_f.business_group_id%Type
  IS
      --local variable
   l_proc constant varchar2(100) := g_package || ' getBusinessGroup';
   l_func_name varchar2(100) default null;
   l_param_name varchar2(100) default null;
   l_bg_id number(20);
   l_web_html_call varchar2(250) default null;
   l_appr_index number default 0;
    CURSOR csr_fnd_func_details IS
      SELECT function_name ,parameters, web_html_call
      FROM fnd_form_functions fff
      WHERE fff.function_id = p_function_id;

   l_func_details csr_fnd_func_details%ROWTYPE;

BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
  l_bg_id := p_bg_id;
  OPEN csr_fnd_func_details;
  FETCH csr_fnd_func_details INTO l_func_details;

  if csr_fnd_func_details%found then
    l_func_name := l_func_details.function_name;
    l_param_name := nvl(get_parameter_value(l_func_details.parameters,'pCalledFrom'),l_func_name);
    l_web_html_call := l_func_details.WEB_HTML_CALL;
    begin
      select INSTR(l_web_html_call,'/oracle/apps/per/selfservice/talentmanagement/webui/MgrTalentManagementPG')  as str_index into l_appr_index from dual;
      if(l_appr_index=0)then
        select INSTR(l_web_html_call,'/oracle/apps/per/selfservice/appraisals/webui/MgrMainAppraiserPG&')  as str_index into l_appr_index from dual;
      end if;
    end;
   -- This logic for SSHR Manager Self-Service fucntion and for Appraisal Manager Fucntion
      IF (l_func_name <> l_param_name) OR (l_appr_index > 0 )THEN
          begin
            select decode(fnd_profile.value('ENABLE_SECURITY_GROUPS'), 'Y' , p_bg_id,
                  decode(fnd_global.employee_id,p_person_id,
                        nvl(
                             decode( FND_PROFILE.VALUE_SPECIFIC('PER_BUSINESS_GROUP_ID',null,fnd_global.resp_id)
                             ,null,fnd_profile.value('PER_BUSINESS_GROUP_ID'),
                             FND_PROFILE.VALUE_SPECIFIC('PER_BUSINESS_GROUP_ID',null,fnd_global.resp_id)
                            )
                          ,p_bg_id
                        ),p_bg_id)) into l_bg_id from dual;
          end;
      END IF; -- end of IF (l_func_name <> l_param_name) OR (l_appr_index > 0 )THEN
 end if; -- end of if csr_fnd_func_details%found then
 CLOSE csr_fnd_func_details;
hr_utility.set_location('Leaving getBusinessGroup with result (BusinesGroupID): ' || l_bg_id,5);
return l_bg_id;
END getBusinessGroup;

procedure update_attachment
          (p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_rowid              in varchar2 ) is



  l_proc    varchar2(72) := g_package ||'update_attachment';
  l_rowid                  varchar2(50);
  l_language               varchar2(30) ;
  data_error               exception;

  cursor csr_get_attached_doc  is
    select *
    from   fnd_attached_documents
    where  rowid = p_rowid;
  cursor csr_get_doc(csr_p_document_id in number)  is
    select *
    from   fnd_documents
    where  document_id = csr_p_document_id;
  cursor csr_get_doc_tl  (csr_p_lang in varchar2
                         ,csr_p_document_id in number) is
    select *
    from   fnd_documents_tl
    where  document_id = csr_p_document_id
    and    language = csr_p_lang;
  l_attached_doc_pre_upd   csr_get_attached_doc%rowtype;
  l_doc_pre_upd            csr_get_doc%rowtype;
  l_doc_tl_pre_upd         csr_get_doc_tl%rowtype;
  Begin
    hr_utility.set_location(' Entering:' || l_proc,10);
    select userenv('LANG') into l_language from dual;
     Open csr_get_attached_doc;
     fetch csr_get_attached_doc into l_attached_doc_pre_upd;
     IF csr_get_attached_doc%NOTFOUND THEN
        close csr_get_attached_doc;
        raise data_error;
     END IF;

     Open csr_get_doc(l_attached_doc_pre_upd.document_id);
     fetch csr_get_doc into l_doc_pre_upd;
     IF csr_get_doc%NOTFOUND then
        close csr_get_doc;
        raise data_error;
     END IF;

     Open csr_get_doc_tl (csr_p_lang => l_language
                      ,csr_p_document_id => l_attached_doc_pre_upd.document_id);
     fetch csr_get_doc_tl into l_doc_tl_pre_upd;
     IF csr_get_doc_tl%NOTFOUND then
        close csr_get_doc_tl;
        raise data_error;
     END IF;

     hr_utility.set_location(' before  fnd_attached_documents_pkg.lock_row :' || l_proc,20);
     fnd_attached_documents_pkg.lock_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                      l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => l_attached_doc_pre_upd.entity_name
            ,x_column1                    => l_attached_doc_pre_upd.column1
            ,x_pk1_value                  => l_attached_doc_pre_upd.pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                    l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                    l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15
            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
            ,x_start_date_active          => l_doc_pre_upd.start_date_active
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_doc_tl_pre_upd.language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_pre_upd.file_name
            ,x_media_id                   => l_doc_pre_upd.media_id
            ,x_doc_attribute_category     =>
                          l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15
            ,x_url                        => l_doc_pre_upd.url
            ,x_title                      => l_doc_tl_pre_upd.title
            );


        hr_utility.set_location(' before fnd_attached_documents_pkg.update_row :' || l_proc,30);
            fnd_attached_documents_pkg.update_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                        l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_last_update_date           => trunc(sysdate)
            ,x_last_updated_by            => l_attached_doc_pre_upd.last_updated_by
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => p_entity_name
            ,x_column1                    => l_attached_doc_pre_upd.column1
            ,x_pk1_value                  => p_pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                      l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                      l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15

            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
           ,x_start_date_active          => trunc(sysdate)
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_pre_upd.file_name
            ,x_media_id                   => l_doc_pre_upd.media_id
            ,x_doc_attribute_category     =>
                      l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15
            ,x_url                        => l_doc_pre_upd.url
            ,x_title                      => l_doc_tl_pre_upd.title
            );

  hr_utility.set_location(' after fnd_attached_documents_pkg.update_row :' || l_proc,40);
  hr_utility.set_location(' Leaving:' || l_proc,50);

  EXCEPTION
    when others then
      hr_utility.set_location(' Error in :' || l_proc,60);
         raise;
  End update_attachment;

procedure merge_attachments (
		p_source_entity_name        in varchar2 default 'PQH_SS_ATTACHMENT'
		,p_dest_entity_name        in varchar2
    ,p_source_pk1_value          in varchar2 default null
    ,p_dest_pk1_value          in varchar2
    ,p_return_status           in out nocopy varchar2 )
is

  l_rowid                  varchar2(50);
  l_proc    varchar2(72) := g_package ||'merge_attachments';
  l_source_pk1_value varchar2(100) := null;
  l_item_type hr_api_transactions.item_type%type := null;
  l_item_key hr_api_transactions.item_key%type := null;

  cursor csr_get_attached_doc(source_pk1_value in varchar2) is
    select *
    from   fnd_attached_documents
    where  entity_name=p_source_entity_name
     and   pk1_value=source_pk1_value;

  CURSOR C (X_attached_document_id in number) IS
    SELECT rowid
    FROM fnd_attached_documents
    WHERE attached_document_id = X_attached_document_id;

  cursor csr_get_itemkey(source_pk1_value in varchar2) is
    select item_type, item_key
    from   hr_api_transactions
    where  transaction_id = source_pk1_value;

begin
  savepoint merge_attachments;
  hr_multi_message.enable_message_list;

  if(p_source_pk1_value is null)  then
  l_source_pk1_value := hr_transaction_swi.g_txn_ctx.TRANSACTION_ID;
  else
  l_source_pk1_value := p_source_pk1_value;
  end if;

  if (getAttachToEntity(l_source_pk1_value)) then

  open csr_get_itemkey(l_source_pk1_value);
  fetch csr_get_itemkey into l_item_type, l_item_key;
  CLOSE csr_get_itemkey;

  for attached_documents_rec in csr_get_attached_doc(l_source_pk1_value) loop
     OPEN C (attached_documents_rec.attached_document_id);
      FETCH C INTO l_rowid;
      if (C%NOTFOUND) then
      CLOSE C;
       RAISE NO_DATA_FOUND;
     end if;
    CLOSE C;
        update_attachment
          (p_entity_name=>p_dest_entity_name
          ,p_pk1_value=> p_dest_pk1_value
          ,p_rowid=>l_rowid);
if(l_item_key is not null) then
       wf_engine.setitemattrtext
      (itemtype => l_item_type
      ,itemkey  => l_item_key
      ,aname    => 'HR_NTF_ATTACHMENTS_ATTR'
      ,avalue   =>'FND:entity=' || p_dest_entity_name ||'&pk1name=TransactionId&pk1value=' || p_dest_pk1_value);
end if;


  end loop;

  end if;

 p_return_status := hr_multi_message.get_return_status_disable;
exception
when others then
    rollback to merge_attachments;
    if hr_multi_message.unexpected_error_add(l_proc) then
       raise;
    end if;
    p_return_status := hr_multi_message.get_return_status_disable;

end merge_attachments;

function getAttachToEntity(p_transaction_id in number)
return boolean
 is

   c_proc constant varchar2(30) := 'getAttachToEntity';
   lr_hr_api_transaction_rec hr_api_transactions%rowtype;
   l_save_attachment_old varchar2(30) := null;
   l_save_attachment_new varchar2(30) := null;
   l_save_attach boolean;
   rootNode xmldom.DOMNode;
   l_Attach_Node xmldom.DOMNode;
   l_TransCtx_Node xmldom.DOMNode;
   l_TransCtx_NodeList xmldom.DOMNodeList;
   l_Attach_NodeList xmldom.DOMNodeList;

   cursor csr_trans_rec is
         select *
         from hr_api_transactions
         where transaction_id = p_transaction_id;


    begin

      if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
      end if;

     if(p_transaction_id is not null) then

--Added this cusror to support Delete Absence flow.
--In Delete Absence after process_api is called the transaction will
--be deleted if OTL Integration is on and we cannot find any transaction
--so in such case return false.
--Other products can also have such kind of scenarios.

      open csr_trans_rec;
      fetch csr_trans_rec into lr_hr_api_transaction_rec;
      if (csr_trans_rec%NOTFOUND) then
       CLOSE csr_trans_rec;
	   hr_utility.set_location('Transaction not found',5);
       return false;
      end if;
      close csr_trans_rec;

   l_save_attach := false;

if( lr_hr_api_transaction_rec.transaction_document is not null) then

   rootNode	:= xmldom.makeNode(hr_transaction_swi.convertCLOBtoXMLElement(lr_hr_api_transaction_rec.transaction_document));
   l_TransCtx_NodeList   :=xmldom.getChildrenByTagName(xmldom.makeElement(rootNode),'TransCtx');

   IF (xmldom.getLength(l_TransCtx_NodeList) > 0)  THEN
   l_TransCtx_Node       :=xmldom.item(l_TransCtx_NodeList,0);
   l_Attach_NodeList	     :=xmldom.getChildrenByTagName(xmldom.makeElement(l_TransCtx_Node),'AttachCheck');
   END IF;

      l_Attach_Node         := xmldom.item(l_Attach_NodeList,0);
      l_Attach_Node         := xmldom.getFirstChild(l_Attach_Node);
      l_save_attachment_new     :=xmldom.getNodeValue(l_Attach_Node);
else

   l_save_attachment_old := wf_engine.getitemattrtext(lr_hr_api_transaction_rec.item_type,
                             lr_hr_api_transaction_rec.item_key,
                             'SAVE_ATTACHMENT',true);
end if;

   if( (l_save_attachment_old is not null) AND (l_save_attachment_old = 'Y') )then
   l_save_attach := true;
   end if;

   if( (l_save_attachment_new is not null) AND (l_save_attachment_new = 'Y') ) then
   l_save_attach := true;
   end if;

   return l_save_attach;

      if (g_debug ) then
          hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
      end if;
   end if;

    exception
    when others then
    raise;

end getAttachToEntity;

procedure saveAttachment(p_transaction_id in number
                        ,p_return_status out nocopy varchar2)
 is

   c_proc constant varchar2(30) := 'saveAttachment';
   lr_hr_api_transaction_rec hr_api_transactions%rowtype;
   l_api_name varchar2(100) := null;
   l_entity_name varchar2(30) := null;
   l_dest_pk1_val varchar2(30) := null;
   l_return_status varchar2(30) := null;
   l_pk_value varchar2(30) := null;
   l_period_of_serv_id Number := null;

  cursor csr_hat_steps is
    select *
    from hr_api_transaction_steps
    where transaction_id=p_transaction_id;

    step_row csr_hat_steps%ROWTYPE;

  cursor csr_hat is
     select hat.transaction_id,
     hat.assignment_id,
     hat.selected_person_id,
     hat.transaction_ref_id
     from   hr_api_transactions hat
     where hat.transaction_id =p_transaction_id;

     trans_row csr_hat%rowtype;

    begin
      hr_utility.set_location('In saveAttachment', 1);
      if(p_transaction_id is not null) then

      hr_utility.set_location('p_transaction_id :' || p_transaction_id, 1);

      if (getAttachToEntity(p_transaction_id)) then
      hr_utility.set_location('In getAttachToEntity true', 1);

      OPEN csr_hat;
      FETCH csr_hat INTO trans_row ;
      CLOSE csr_hat;

      OPEN csr_hat_steps;
      FETCH csr_hat_steps INTO step_row ;
      CLOSE csr_hat_steps;

      l_api_name := step_row.api_name;

     hr_utility.set_location('l_api_name :' || l_api_name, 1);

      if(l_api_name = 'HR_LOA_SS.PROCESS_API' OR
         l_api_name = 'HR_PERSON_ABSENCE_SWI.PROCESS_API') then

      l_entity_name := 'PER_ABSENCE_ATTENDANCES';
      l_pk_value := trans_row.transaction_ref_id;

     elsif(l_api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API' OR
           l_api_name = 'HR_SUPERVISOR_SS.PROCESS_API' OR
           l_api_name = 'HR_PAY_RATE_SS.PROCESS_API') then

      l_entity_name := 'PER_ASSIGNMENTS_F';
      l_pk_value := trans_row.assignment_id;

     elsif(l_api_name = 'HR_PROCESS_PERSON_SS.PROCESS_API' OR
           l_api_name = 'HR_PROCESS_SIT_SS.PROCESS_API' OR
           l_api_name = 'HR_PROCESS_EIT_SS.PROCESS_API' OR
           l_api_name = 'HR_CAED_SS.PROCESS_API' OR
           l_api_name = 'HR_PROCESS_PHONE_NUMBERS_SS.PROCESS_API' OR
           l_api_name = 'HR_PROCESS_ADDRESS_SS.PROCESS_API' OR
           l_api_name = 'HR_PROCESS_CONTACT_SS.PROCESS_CREATE_CONTACT_API') then

      l_entity_name := 'PER_PEOPLE_F';
      l_pk_value := trans_row.selected_person_id;


      if( l_pk_value is null) then
      hr_utility.set_location('l_pk_value is null' , 1);

      l_pk_value := hr_process_person_ss.g_person_id;
      end if;

     elsif(l_api_name = 'HR_TERMINATION_SS.PROCESS_API') then

     select number_value into l_period_of_serv_id from
     hr_api_transaction_values
     where TRANSACTION_STEP_ID = step_row.TRANSACTION_STEP_ID
     and NAME = 'P_PERIOD_OF_SERVICE_ID';

     l_entity_name := 'PER_PERIODS_OF_SERVICE';
     l_pk_value := l_period_of_serv_id;
     end if;

hr_utility.set_location('l_pk_value :' || l_pk_value, 1);


    merge_attachments (p_dest_entity_name => l_entity_name
                      ,p_source_pk1_value => trans_row.transaction_id
                      ,p_dest_pk1_value => l_pk_value
                      ,p_return_status => l_return_status);

   p_return_status := l_return_status;

   end if;
   end if;
    exception
    when others then
    raise;

end saveAttachment;

function getUpgradeCheck(p_transaction_id in number) return varchar2

IS
c_proc  constant varchar2(30) := 'getUpgradeCheck';
lv_is_upgrade hr_api_transaction_steps.Information30%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

    if(p_transaction_id is not null) then
      begin
      select Information30
      into lv_is_upgrade
      from hr_api_transaction_steps
      where transaction_id=p_transaction_id;

      exception
      when others then
        null;
        lv_is_upgrade:=null;
      end;
    end if;

  if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
    end if;

return lv_is_upgrade;

exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
--    raise;
   return null;
end getUpgradeCheck;

function getJobName (p_job_id in number, p_bg_id in number)
return varchar2
is
jname varchar2(200) := '';
begin

 select name
 into jname
 from per_jobs_tl
 where p_job_id = job_id
 and language(+) = userenv('LANG');

return hr_util_misc_ss.getObjectName('JOB', p_job_id, p_bg_id, jname);

end getJobName;


function getPositionName (p_position_id in number, p_bg_id in number)
return varchar2
is
pname varchar2(200) := '';
begin

 select name
 into pname
 from hr_all_positions_f_tl
 where p_position_id = position_id
 and language(+) = userenv('LANG');

return hr_util_misc_ss.getObjectName('POSITION', p_position_id, p_bg_id, pname);

end getPositionName;


function getGradeName (p_grade_id in number, p_bg_id in number)
return varchar2
is
gname varchar2(200) := '';
begin

 select name
 into gname
 from per_grades_tl
 where p_grade_id = grade_id
 and language(+) = userenv('LANG');

return hr_util_misc_ss.getObjectName('GRADE', p_grade_id, p_bg_id, gname);

end getGradeName;


function getOrgName (p_org_id in number, p_bg_id in number)
return varchar2
is
oname varchar2(200) := '';
begin

 select name
 into oname
 from hr_all_organization_units_tl
 where p_org_id = organization_id
 and language(+) = userenv('LANG');

return oname;

end getOrgName;

function getLocName (p_loc_id in number, p_bg_id in number)
return varchar2
is
lname varchar2(200) := '';
begin

 select location_code
 into lname
 from hr_locations_all_tl
 where p_loc_id = location_id
 and language(+) = userenv('LANG');

return lname;

end getLocName;


END HR_UTIL_MISC_SS;

/
