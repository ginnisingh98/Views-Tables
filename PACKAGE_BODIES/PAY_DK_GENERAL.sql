--------------------------------------------------------
--  DDL for Package Body PAY_DK_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_GENERAL" AS
/* $Header: pydkgenr.pkb 120.4.12010000.3 2009/11/18 11:16:05 knadhan ship $ */
 --
g_formula_name    ff_formulas_f.formula_name%TYPE;
--
 FUNCTION get_tax_card_details
 (p_assignment_id               IN      NUMBER
 ,p_effective_date              IN      DATE
 ,p_tax_card_type               OUT NOCOPY VARCHAR2
 ,p_tax_percentage              OUT NOCOPY NUMBER
 ,p_tax_free_threshold          OUT NOCOPY NUMBER
 ,p_monthly_tax_deduction       OUT NOCOPY NUMBER
 ,p_bi_weekly_tax_deduction     OUT NOCOPY NUMBER
 ,p_weekly_tax_deduction        OUT NOCOPY NUMBER
 ,p_daily_tax_deduction         OUT NOCOPY NUMBER) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE , p_input_value VARCHAR2 ) IS
   SELECT eev1.screen_entry_value  screen_entry_value
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  asg2.primary_flag     = 'Y'
     AND  et.element_name       = 'Tax Card'
     AND  et.legislation_code   = 'DK'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date;
  --
  l_rec get_details%ROWTYPE;
  --
 BEGIN
  --


  OPEN  get_details(p_assignment_id , p_effective_date ,'Tax Card Type' );
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_tax_card_type             := l_rec.screen_entry_value ;

  OPEN  get_details(p_assignment_id , p_effective_date ,'Tax Percentage' );
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_tax_percentage       := nvl(l_rec.screen_entry_value,0);

  OPEN  get_details(p_assignment_id , p_effective_date ,'Tax Free Threshold' );
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_tax_free_threshold   := nvl(l_rec.screen_entry_value,0) ;

  OPEN  get_details(p_assignment_id , p_effective_date ,'Monthly Tax Deduction');
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_monthly_tax_deduction       := nvl(l_rec.screen_entry_value,0) ;

  OPEN  get_details(p_assignment_id , p_effective_date ,'Bi Weekly Tax Deduction' );
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  --p_julian_effective_date := l_rec.julian_effective_date;
  p_bi_weekly_tax_deduction         := nvl(l_rec.screen_entry_value,0) ;

  OPEN  get_details(p_assignment_id , p_effective_date ,'Weekly Tax Deduction');
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_weekly_tax_deduction       := nvl(l_rec.screen_entry_value,0) ;

  OPEN  get_details(p_assignment_id , p_effective_date ,'Daily Tax Deduction');
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_daily_tax_deduction       := nvl(l_rec.screen_entry_value,0) ;

    --
  RETURN 1;
  --
 END get_tax_card_details;
 --
 FUNCTION get_tax_details
 (p_assignment_id               IN      NUMBER
 ,p_effective_date              IN      DATE
 ,p_effective_start_date        OUT NOCOPY DATE
 ,p_effective_end_date          OUT NOCOPY DATE
 ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE ) IS
   SELECT ee.effective_start_date effective_start_date, ee.effective_end_date effective_end_date
   FROM   per_all_assignments_f      asg
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_element_entries_f      ee
   WHERE  asg.assignment_id    = p_assignment_id
     AND  p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND  et.element_name       = 'Tax'
     AND  et.legislation_code   = 'DK'
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date;
  --
  l_rec get_details%ROWTYPE;
  --
 BEGIN
  --

  OPEN  get_details(p_assignment_id , p_effective_date);
  FETCH get_details INTO l_rec.effective_start_date , l_rec.effective_end_date;
  CLOSE get_details;

  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;

  --
  RETURN 1;
  --
 END get_tax_details;
 --

  FUNCTION get_le_employment_details
  (p_org_id                     IN      VARCHAR2
  ,p_le_work_hours              OUT NOCOPY NUMBER
  ,p_freq                       OUT NOCOPY VARCHAR2
  )RETURN NUMBER IS
  --
  CURSOR get_details(p_org_id VARCHAR2) IS
  SELECT   hoi.org_information3 WORKING_HOURS
         , hoi.org_information4 FREQ
  FROM     hr_organization_information  hoi
  WHERE    hoi.org_information_context='DK_EMPLOYMENT_DEFAULTS'
  AND      hoi.organization_id =  p_org_id ;

  l_rec get_details%ROWTYPE;
  --
 BEGIN
  --
  OPEN  get_details(p_org_id);
  FETCH get_details INTO l_rec;
  CLOSE get_details;

  p_le_work_hours := l_rec.working_hours;
  p_freq          := l_rec.freq;

  RETURN 1;
  --
 END get_le_employment_details;
 --
 --
 FUNCTION get_atp_details
 (p_assignment_id               IN      NUMBER
 ,p_effective_date              IN      DATE
 ,p_effective_start_date        OUT NOCOPY DATE
 ,p_effective_end_date          OUT NOCOPY DATE
 ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE ) IS
   SELECT ee.effective_start_date effective_start_date, ee.effective_end_date effective_end_date
   FROM   per_all_assignments_f      asg
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_element_entries_f      ee
   WHERE  asg.assignment_id    = p_assignment_id
     AND  p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND  et.element_name       = 'Employee ATP'
     AND  et.legislation_code   = 'DK'
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date;
  --
  l_rec get_details%ROWTYPE;
  --
 BEGIN
  --

  OPEN  get_details(p_assignment_id , p_effective_date);
  FETCH get_details INTO l_rec.effective_start_date , l_rec.effective_end_date;
  CLOSE get_details;

  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;

  --
  RETURN 1;
  --
 END get_atp_details;


 --
 FUNCTION get_sp_details
 (p_payroll_action_id           IN      NUMBER
 ,p_cvr_number                  OUT NOCOPY VARCHAR2
  ) RETURN NUMBER IS

 CURSOR get_sp_details( p_payroll_action_id NUMBER) IS
        SELECT hoi2.org_information1 cvr_number
        FROM   HR_ORGANIZATION_INFORMATION hoi1
              ,HR_ORGANIZATION_INFORMATION hoi2
              ,HR_ORGANIZATION_UNITS hou
	      ,PAY_PAYROLL_ACTIONS ppa
        WHERE ppa.payroll_action_id = p_payroll_action_id
        and hoi1.org_information_context ='CLASS'
        and hoi1.org_information1 ='DK_SERVICE_PROVIDER'
        and hoi1.ORG_INFORMATION2 ='Y'
        and hoi2.ORG_INFORMATION_CONTEXT= 'DK_SERVICE_PROVIDER_DETAILS'
        and hoi2.organization_id =  hoi1.organization_id
        and hou.organization_id = hoi1.organization_id
        and hou.business_group_id = ppa.BUSINESS_GROUP_ID
        and ppa.EFFECTIVE_DATE BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, ppa.EFFECTIVE_DATE);

 --
 l_rec get_sp_details%ROWTYPE;
 --
 BEGIN
  --

  OPEN  get_sp_details(p_payroll_action_id);
  FETCH get_sp_details INTO l_rec.cvr_number;
  CLOSE get_sp_details;

  p_cvr_number  := l_rec.cvr_number;

  --
  RETURN 1;
  --
   END get_sp_details;




FUNCTION get_atp_override_hours
 (p_assignment_id 		NUMBER
 , p_effective_date             DATE
) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER,p_effective_date             DATE  ) IS
   SELECT eev1.screen_entry_value atp_override_hours
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  asg2.primary_flag     = 'Y'
     AND  et.element_name       = 'ATP Override Hours'
     AND  et.legislation_code   = 'DK'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = 'ATP Override Hours'
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date;
  --
  l_rec get_details%ROWTYPE;
  --
 BEGIN
  --
  OPEN  get_details(p_assignment_id ,p_effective_date);
  FETCH get_details INTO l_rec;
  CLOSE get_details;
  --
  RETURN NVL(l_rec.atp_override_hours, -1);
  --
 END get_atp_override_hours;

FUNCTION get_holiday_details
 (p_assignment_id               IN      NUMBER
 ,p_effective_date              IN      DATE
 ,p_abs_start_date              IN      DATE
 ,p_abs_end_date                IN      DATE
 ,p_start_date                  OUT NOCOPY DATE
 ,p_end_date                    OUT NOCOPY DATE
 ,p_over_days                   OUT NOCOPY NUMBER
 ,p_over_hours                  OUT NOCOPY NUMBER ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE ) IS
   SELECT ee.element_entry_id element_entry_id
          , eev1.screen_entry_value  screen_entry_value
          , iv1.name
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  et.element_name       = 'Override Holiday Duration'
     AND  et.legislation_code   = 'DK'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              in ('Start Date', 'End Date', 'Override Hours', 'Override Days')
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     ORDER BY ee.element_entry_id;
  --
  TYPE l_record is record (eeid    pay_element_entries_f.element_entry_id%TYPE,
                           eevalue pay_element_entry_values_f.screen_entry_value%TYPE,
                           eename  pay_input_values_f.name%TYPE );
  l_rec l_record;
  TYPE l_table  is table of l_record index by BINARY_INTEGER;
  l_tab l_table;

  l_start_date date;
  l_end_date date;
  l_over_hours number;
  l_over_days number;
  l_counter number ;
  l_bool_match boolean;
  l_num_match number;
  --
 BEGIN
  --
  l_counter := 1;
  l_bool_match := FALSE;

  -- Open cursor to fetch all screen entry values of Override Holiday Duration element.
  OPEN  get_details(p_assignment_id , p_effective_date );
  -- Assign the values to a table type
  FETCH get_details BULK COLLECT INTO l_tab;
  CLOSE get_details;

  -- Loop through each values for processing.
  FOR l_cur in 1..l_tab.count LOOP
        -- Assign values to local variables.
        IF l_tab(l_cur).eename = 'Start Date' THEN
           l_start_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss') ;
        elsif l_tab(l_cur).eename = 'End Date' THEN
           l_end_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
        elsif l_tab(l_cur).eename = 'Override Days' THEN
           l_over_days := l_tab(l_cur).eevalue;
        elsif l_tab(l_cur).eename = 'Override Hours' THEN
           l_over_hours := l_tab(l_cur).eevalue;
        end if;
        -- Check no. of input values of override element is 4
        IF l_counter < 4 then
           l_counter := l_counter + 1;
        else
           -- Check override element's start and end date matches with Absent element.
           if l_start_date = p_abs_start_date and l_end_date = p_abs_end_date then
              -- Multiple entry exists with same start and end date
              IF l_bool_match THEN
                 p_start_date := null;
                 p_end_date := null;
                 p_over_days := null;
                 p_over_hours := null;
                 return -1;
              -- Exact match found
              ELSE
                 l_bool_match := True;
              END IF;
              -- Assign input values to output variables.
              p_start_date := l_start_date;
              p_end_date := l_end_date;
              p_over_days := l_over_days;
              p_over_hours := l_over_hours;
           end if;
           l_counter := 1;
        end if;
  END LOOP;

  -- Match found successfully
  IF p_start_date is not null then
     RETURN 1;
  -- Override element exists but date doesnt match.
  elsif p_start_date is null and l_tab.count > 0 then
     RETURN 2;
  -- No override element attached
  else
     RETURN 0;
  end if;
  --
 END get_holiday_details;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_IANA_charset                                    --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to IANA charset equivalent of              --
--                  NLS_CHARACTERSET                                    --
-- Parameters     :                                                     --
--             IN : N/A                                                 --
--            OUT : N/A                                                 --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_IANA_charset RETURN VARCHAR2 IS
    CURSOR csr_get_iana_charset IS
        SELECT tag
          FROM fnd_lookup_values
          WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
          AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
          AND language = 'US';

    lv_iana_charset fnd_lookup_values.tag%type;
BEGIN
    OPEN csr_get_iana_charset;
        FETCH csr_get_iana_charset INTO lv_iana_charset;
    CLOSE csr_get_iana_charset;

    hr_utility.trace('IANA Charset = '||lv_iana_charset);
    RETURN (lv_iana_charset);
END get_IANA_charset;
--------------------------------------------------------------------------
FUNCTION get_hour_sal_flag
(p_assignment_id		IN      NUMBER
,p_effective_date		IN      DATE
) RETURN VARCHAR2 IS

CURSOR csr_get_asg_hs_flag( p_assignment_id		IN      NUMBER
                           ,p_effective_date		IN      DATE
			   ) IS
SELECT 	paaf.hourly_salaried_code
FROM per_all_assignments_f  paaf
WHERE paaf.assignment_id = p_assignment_id
AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date;

rec_get_asg_hs_flag csr_get_asg_hs_flag%ROWTYPE;

BEGIN
OPEN csr_get_asg_hs_flag( p_assignment_id,p_effective_date);
FETCH csr_get_asg_hs_flag INTO rec_get_asg_hs_flag;
CLOSE csr_get_asg_hs_flag;
RETURN 	rec_get_asg_hs_flag.hourly_salaried_code;

END get_hour_sal_flag;

FUNCTION GET_UTF8TOANSI
(p_utf8_str		IN      VARCHAR2
) RETURN VARCHAR2 IS

l_charset nls_database_parameters.value%type := 'UTF8';
l_ansi_str VARCHAR2(2000);
cursor CUR_DB_CHARSET
IS
SELECT value
FROM
nls_database_parameters
WHERE parameter='NLS_CHARACTERSET';

BEGIN

OPEN CUR_DB_CHARSET;
FETCH CUR_DB_CHARSET INTO l_charset;
CLOSE CUR_DB_CHARSET;

l_ansi_str := CONVERT(p_utf8_str,'WE8MSWIN1252', l_charset);

RETURN l_ansi_str;

END GET_UTF8TOANSI;

/* 9127044 */
--
FUNCTION get_asg_start_date(p_business_group_id           IN       NUMBER
                           ,p_assignment_id               IN       NUMBER)  RETURN DATE IS

   CURSOR csr_asg IS
      SELECT MIN(paaf.effective_start_date) effective_start_date
        FROM per_all_assignments_f paaf
       WHERE paaf.business_group_id = p_business_group_id
         AND paaf.assignment_id = p_assignment_id
         ;

      l_asg_start_date DATE;
      l_asg_status csr_asg % rowtype;

      BEGIN

        OPEN csr_asg;
        FETCH csr_asg INTO l_asg_status;
        CLOSE csr_asg;
        l_asg_start_date := l_asg_status.effective_start_date;
        RETURN l_asg_start_date;

END get_asg_start_date;
--

--
END PAY_DK_GENERAL;

/
