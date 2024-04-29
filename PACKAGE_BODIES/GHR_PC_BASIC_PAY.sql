--------------------------------------------------------
--  DDL for Package Body GHR_PC_BASIC_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PC_BASIC_PAY" AS
/* $Header: ghbasicp.pkb 120.20.12010000.5 2009/07/02 05:26:31 vmididho ship $ */
--
--

FUNCTION get_retained_grade_details (p_person_id      IN NUMBER
                                    ,p_effective_date IN DATE
                                    ,p_pa_request_id  IN NUMBER DEFAULT NULL)
  RETURN ghr_pay_calc.retained_grade_rec_type IS
--
l_retained_grade_rec        ghr_pay_calc.retained_grade_rec_type;
l_last_retained_grade_rec   ghr_pay_calc.retained_grade_rec_type;
--
l_last_pay_table_value      NUMBER;
l_last_pay_table_value_conv NUMBER;
l_cur_pay_table_value       NUMBER;
--
l_record_found              BOOLEAN :=FALSE;
--
l_dummy_date                DATE;

l_noa_code                  ghr_nature_of_actions.code%type;

CURSOR cur_par IS
SELECT first_noa_code,second_noa_code
FROM ghr_pa_requests
WHERE pa_request_id = p_pa_request_id;

CURSOR cur_temp_step IS
SELECT  rei_information3 temp_step
FROM    ghr_pa_request_extra_info
WHERE   pa_request_id = p_pa_request_id
AND     information_type = 'GHR_US_PAR_RG_TEMP_PROMO';

--
CURSOR cur_pei IS
  SELECT pei.person_extra_info_id
         -- Bug#4423679 Added date_from,date_to columns.
        ,fnd_date.canonical_to_date(pei.pei_information1) date_from
        ,fnd_date.canonical_to_date(pei.pei_information2) date_to
    	-- Bug#4423679
        ,pei.pei_information3     retained_grade
        ,pei.pei_information4     retained_step_or_rate
        ,pei.pei_information5     retained_pay_plan
        ,pei.pei_information6     retained_user_table_id
  ----  ,pei.pei_information7     retained_locality_percent
        ,pei.pei_information8     retained_pay_basis
        ,pei.pei_information9     retained_temp_step
  FROM   per_people_extra_info pei
  WHERE  pei.person_id = p_person_id
  AND    pei.information_type = 'GHR_US_RETAINED_GRADE'
  AND    p_effective_date BETWEEN NVL(fnd_date.canonical_to_date(pei.pei_information1),p_effective_date)
                          AND     NVL(fnd_date.canonical_to_date(pei.pei_information2),p_effective_date)
  AND    fnd_date.canonical_to_date(pei.pei_information1) =
                           (SELECT MIN (NVL(fnd_date.canonical_to_date(pei2.pei_information1),p_effective_date) )
                            FROM   per_people_extra_info pei2
                            WHERE  pei2.person_id = p_person_id
                            AND    pei2.information_type = 'GHR_US_RETAINED_GRADE'
                            AND    p_effective_date
                                   BETWEEN NVL(fnd_date.canonical_to_date(pei2.pei_information1),p_effective_date)
                                       AND NVL(fnd_date.canonical_to_date(pei2.pei_information2),p_effective_date)
                            AND    pei2.person_extra_info_id NOT IN (SELECT rei_information3
                                          FROM   ghr_pa_request_extra_info
                                          WHERE  pa_request_id = p_pa_request_id
                                          AND    (rei_information5 is null OR rei_information5 = 'Y')
                                          AND    information_type in ('GHR_US_PAR_TERM_RET_GRADE',
                                                                      'GHR_US_PAR_TERM_RG_PROMO',
                                                                      'GHR_US_PAR_TERM_RG_POSN_CHG')
                                                                      )
                            )
  AND    pei.person_extra_info_id NOT IN (SELECT rei_information3
                                          FROM   ghr_pa_request_extra_info
                                          WHERE  pa_request_id = p_pa_request_id
                                          AND    information_type in ( 'GHR_US_PAR_TERM_RET_GRADE',
                                                                       'GHR_US_PAR_TERM_RG_PROMO',
                                                                       'GHR_US_PAR_TERM_RG_POSN_CHG')
                                          AND    (rei_information5 is null OR rei_information5 = 'Y'));


BEGIN
  -- Just in case there is more than one retained grade with the same earliest start
  -- date we have to return the one with the highest plan_table_value!!
  -- I'm sure this is very very unlikely to happen!!
  hr_utility.set_location(' get_retained_grade_details',1);
  FOR cur_pei_rec IN cur_pei LOOP
    hr_utility.set_location(' get_retained_grade_details',2);
    IF l_record_found THEN
      -- If we have already been here once store all the last details before we get the new ones
      -- the main record group will always keep the last highest value!
      l_last_retained_grade_rec := l_retained_grade_rec;
    END IF;
      hr_utility.set_location(' get_retained_grade_details person_extra_info_id' ||l_retained_grade_rec.person_extra_info_id ,3);
    l_retained_grade_rec.person_extra_info_id :=  cur_pei_rec.person_extra_info_id;
    -- Bug#4423679 Added date_from, date_to columns in the retained grade record.
    l_retained_grade_rec.date_from            :=  cur_pei_rec.date_from;
    l_retained_grade_rec.date_to              :=  cur_pei_rec.date_to;
    -- Bug#4423679
    l_retained_grade_rec.grade_or_level       :=  cur_pei_rec.retained_grade;
    l_retained_grade_rec.step_or_rate         :=  cur_pei_rec.retained_step_or_rate;
    l_retained_grade_rec.pay_plan             :=  cur_pei_rec.retained_pay_plan;
    l_retained_grade_rec.user_table_id        :=  cur_pei_rec.retained_user_table_id;
    l_retained_grade_rec.pay_basis            :=  cur_pei_rec.retained_pay_basis;
    l_retained_grade_rec.temp_step            :=  cur_pei_rec.retained_temp_step;

    IF l_retained_grade_rec.grade_or_level IS NULL
      OR l_retained_grade_rec.step_or_rate IS NULL
      OR l_retained_grade_rec.pay_plan IS NULL
      OR l_retained_grade_rec.user_table_id IS NULL
      OR l_retained_grade_rec.pay_basis IS NULL THEN
      hr_utility.set_message(8301, 'GHR_38255_MISSING_RETAINED_DET');
      raise ghr_pay_calc.pay_calc_message;
    END IF;
    --
    IF l_record_found THEN
hr_utility.set_location(' get_retained_grade_details ' ,5);
      -- only if we have previously found a retained record with the same start date do we bother
      -- getting the values to compare
      ghr_pay_calc.get_pay_table_value (l_retained_grade_rec.user_table_id
                                       ,l_retained_grade_rec.pay_plan
                                       ,l_retained_grade_rec.grade_or_level
                                       ,l_retained_grade_rec.step_or_rate
                                       ,p_effective_date
                                       ,l_cur_pay_table_value
                                       ,l_dummy_date
                                       ,l_dummy_date);

      ghr_pay_calc.get_pay_table_value (l_last_retained_grade_rec.user_table_id
                                       ,l_last_retained_grade_rec.pay_plan
                                       ,l_last_retained_grade_rec.grade_or_level
                                       ,l_last_retained_grade_rec.step_or_rate
                                       ,p_effective_date
                                       ,l_last_pay_table_value
                                       ,l_dummy_date
                                       ,l_dummy_date);

      -- if they are different pay basis Convert the last retained ggrade to the pay basis
      -- of the current
      IF l_last_retained_grade_rec.pay_basis <> l_retained_grade_rec.pay_basis THEN
       l_last_pay_table_value_conv := ghr_pay_calc.convert_amount
                                         (l_last_pay_table_value
                                         ,l_last_retained_grade_rec.pay_basis
                                         ,l_retained_grade_rec.pay_basis);
      ELSE
        l_last_pay_table_value_conv := l_last_pay_table_value;
      END IF;

      -- now compare the two and set the l_retained_grade_rec to the one with the highest value
      IF NVL(l_last_pay_table_value_conv,-9) > NVL(l_cur_pay_table_value,-9) THEN
         l_retained_grade_rec := l_last_retained_grade_rec;
      END IF;

   END IF;
hr_utility.set_location(' get_retained_grade_details ' ,6);
   l_record_found := TRUE;

  END LOOP;

  ------- Start Temp Promotion Code changes for 703 and 866 NOACs.
  l_noa_code := null;
  IF p_pa_request_id is not null THEN
     FOR cur_par_rec IN cur_par LOOP
         if cur_par_rec.first_noa_code = '002' then
            l_noa_code := cur_par_rec.second_noa_code;
         else
            l_noa_code := cur_par_rec.first_noa_code;
         end if;
     EXIT;
     END LOOP;
     IF l_noa_code in ('703','866') THEN
        l_retained_grade_rec.temp_step  := null;
		-- Bug 3221361 In case if TPS record is deleted, it shd return NULL as the value.
		FOR cur_temp_step_rec IN cur_temp_step LOOP
		    l_retained_grade_rec.temp_step  := cur_temp_step_rec.temp_step;
        END LOOP;
     END IF;
  END IF;
  IF l_noa_code = '740' THEN
     l_retained_grade_rec.temp_step := NULL;
  END IF;
  -------End  Temp Promotion Code changes for 703 and 866 NOACs.
  hr_utility.set_location(' get_retained_grade_details ' ,7);
  IF l_record_found THEN
  hr_utility.set_location(' get_retained_grade_details ' ,7);
    RETURN (l_retained_grade_rec);
  ELSE
    hr_utility.set_message(8301, 'GHR_38256_NO_RETAINED_GRADE');
    raise ghr_pay_calc.pay_calc_message;
  END IF;

END get_retained_grade_details ;
--
-- Bug#4016384 Created the following function to get the RG record available
--             before the MSL effective date.
FUNCTION get_expired_rg_details (p_person_id      IN NUMBER
                            ,p_effective_date IN DATE
                            ,p_pa_request_id  IN NUMBER DEFAULT NULL)
  RETURN ghr_pay_calc.retained_grade_rec_type IS
--
l_retained_grade_rec        ghr_pay_calc.retained_grade_rec_type;
l_last_retained_grade_rec   ghr_pay_calc.retained_grade_rec_type;
--
l_last_pay_table_value      NUMBER;
l_last_pay_table_value_conv NUMBER;
l_cur_pay_table_value       NUMBER;
--
l_record_found              BOOLEAN :=FALSE;
--
l_dummy_date                DATE;

--
CURSOR cur_pei IS
  SELECT pei.person_extra_info_id
         -- Bug#4423679 Added date_from,date_to columns.
        ,fnd_date.canonical_to_date(pei.pei_information1) date_from
        ,fnd_date.canonical_to_date(pei.pei_information2) date_to
    	-- Bug#4423679
        ,pei.pei_information3     retained_grade
        ,pei.pei_information4     retained_step_or_rate
        ,pei.pei_information5     retained_pay_plan
        ,pei.pei_information6     retained_user_table_id
  ----  ,pei.pei_information7     retained_locality_percent
        ,pei.pei_information8     retained_pay_basis
        ,pei.pei_information9     retained_temp_step
  FROM   per_people_extra_info pei
  WHERE  pei.person_id = p_person_id
  AND    pei.information_type = 'GHR_US_RETAINED_GRADE'
  AND    NVL(fnd_date.canonical_to_date(pei.pei_information2),p_effective_date) < p_effective_date
  AND    fnd_date.canonical_to_date(pei.pei_information1) =
                           (SELECT MIN (NVL(fnd_date.canonical_to_date(pei2.pei_information1),p_effective_date) )
                            FROM   per_people_extra_info pei2
                            WHERE  pei2.person_id = p_person_id
                            AND    pei2.information_type = 'GHR_US_RETAINED_GRADE'
                            AND    NVL(fnd_date.canonical_to_date(pei2.pei_information2),p_effective_date) < p_effective_date
                            AND    pei2.person_extra_info_id NOT IN (SELECT rei_information3
                                          FROM   ghr_pa_request_extra_info
                                          WHERE  pa_request_id = p_pa_request_id
                                          AND    (rei_information5 is null OR rei_information5 = 'Y')
                                          AND    information_type in ('GHR_US_PAR_TERM_RET_GRADE',
                                                                      'GHR_US_PAR_TERM_RG_PROMO',
                                                                      'GHR_US_PAR_TERM_RG_POSN_CHG')
                                                                      )
                            )
  AND    pei.person_extra_info_id NOT IN (SELECT rei_information3
                                          FROM   ghr_pa_request_extra_info
                                          WHERE  pa_request_id = p_pa_request_id
                                          AND    information_type in ( 'GHR_US_PAR_TERM_RET_GRADE',
                                                                       'GHR_US_PAR_TERM_RG_PROMO',
                                                                       'GHR_US_PAR_TERM_RG_POSN_CHG')
                                          AND    (rei_information5 is null OR rei_information5 = 'Y'));


BEGIN
  -- Just in case there is more than one retained grade with the same earliest start
  -- date we have to return the one with the highest plan_table_value!!
  -- I'm sure this is very very unlikely to happen!!
  hr_utility.set_location(' get_expired_rg_details',1);
  FOR cur_pei_rec IN cur_pei LOOP
    hr_utility.set_location(' get_expired_rg_details',2);
    IF l_record_found THEN
      -- If we have already been here once store all the last details before we get the new ones
      -- the main record group will always keep the last highest value!
      l_last_retained_grade_rec := l_retained_grade_rec;
    END IF;
      hr_utility.set_location(' get_expired_rg_details person_extra_info_id' ||l_retained_grade_rec.person_extra_info_id ,3);
    l_retained_grade_rec.person_extra_info_id :=  cur_pei_rec.person_extra_info_id;
    -- Bug#4423679 Added date_from, date_to columns in the retained grade record.
    l_retained_grade_rec.date_from            :=  cur_pei_rec.date_from;
    l_retained_grade_rec.date_to              :=  cur_pei_rec.date_to;
    -- Bug#4423679
    l_retained_grade_rec.grade_or_level       :=  cur_pei_rec.retained_grade;
    l_retained_grade_rec.step_or_rate         :=  cur_pei_rec.retained_step_or_rate;
    l_retained_grade_rec.pay_plan             :=  cur_pei_rec.retained_pay_plan;
    l_retained_grade_rec.user_table_id        :=  cur_pei_rec.retained_user_table_id;
    l_retained_grade_rec.pay_basis            :=  cur_pei_rec.retained_pay_basis;
    l_retained_grade_rec.temp_step            :=  cur_pei_rec.retained_temp_step;

    IF l_retained_grade_rec.grade_or_level IS NULL
      OR l_retained_grade_rec.step_or_rate IS NULL
      OR l_retained_grade_rec.pay_plan IS NULL
      OR l_retained_grade_rec.user_table_id IS NULL
      OR l_retained_grade_rec.pay_basis IS NULL THEN
      hr_utility.set_message(8301, 'GHR_38255_MISSING_RETAINED_DET');
      raise ghr_pay_calc.pay_calc_message;
    END IF;
    --
    IF l_record_found THEN
hr_utility.set_location(' get_expired_rg_details ' ,5);
      -- only if we have previously found a retained record with the same start date do we bother
      -- getting the values to compare
      ghr_pay_calc.get_pay_table_value (l_retained_grade_rec.user_table_id
                                       ,l_retained_grade_rec.pay_plan
                                       ,l_retained_grade_rec.grade_or_level
                                       ,l_retained_grade_rec.step_or_rate
                                       ,p_effective_date
                                       ,l_cur_pay_table_value
                                       ,l_dummy_date
                                       ,l_dummy_date);

      ghr_pay_calc.get_pay_table_value (l_last_retained_grade_rec.user_table_id
                                       ,l_last_retained_grade_rec.pay_plan
                                       ,l_last_retained_grade_rec.grade_or_level
                                       ,l_last_retained_grade_rec.step_or_rate
                                       ,p_effective_date
                                       ,l_last_pay_table_value
                                       ,l_dummy_date
                                       ,l_dummy_date);

      -- if they are different pay basis Convert the last retained ggrade to the pay basis
      -- of the current
      IF l_last_retained_grade_rec.pay_basis <> l_retained_grade_rec.pay_basis THEN
       l_last_pay_table_value_conv := ghr_pay_calc.convert_amount
                                         (l_last_pay_table_value
                                         ,l_last_retained_grade_rec.pay_basis
                                         ,l_retained_grade_rec.pay_basis);
      ELSE
        l_last_pay_table_value_conv := l_last_pay_table_value;
      END IF;

      -- now compare the two and set the l_retained_grade_rec to the one with the highest value
      IF NVL(l_last_pay_table_value_conv,-9) > NVL(l_cur_pay_table_value,-9) THEN
         l_retained_grade_rec := l_last_retained_grade_rec;
      END IF;

   END IF;
hr_utility.set_location(' get_expired_rg_details ' ,6);
   l_record_found := TRUE;

  END LOOP;

  IF l_record_found THEN
    hr_utility.set_location(' get_expired_rg_details ' ,7);
    RETURN (l_retained_grade_rec);
  ELSE
    hr_utility.set_message(8301, 'GHR_38256_NO_RETAINED_GRADE');
    raise ghr_pay_calc.pay_calc_message;
  END IF;

END get_expired_rg_details ;
--

PROCEDURE get_basic_pay_MAIN_per (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                 ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
                                 ,p_basic_pay         OUT NOCOPY NUMBER
                                 ,p_PT_eff_start_date OUT NOCOPY DATE) IS
l_basic_pay  NUMBER;
l_dummy_date DATE;
BEGIN
 IF p_retained_grade.temp_step is not null then
      ghr_pay_calc.get_pay_table_value(p_pay_calc_data.user_table_id
                                  ,p_pay_calc_data.pay_plan
                                  ,p_pay_calc_data.grade_or_level
                                  ,p_retained_grade.temp_step
                                  ,p_pay_calc_data.effective_date
                                  ,l_basic_pay
                                  ,p_PT_eff_start_date
                                  ,l_dummy_date);
      p_basic_pay := l_basic_pay;
  ELSE
  ghr_pay_calc.get_pay_table_value(p_retained_grade.user_table_id
                                  ,p_retained_grade.pay_plan
                                  ,p_retained_grade.grade_or_level
                                  ,p_retained_grade.step_or_rate
                                  ,p_pay_calc_data.effective_date
                                  ,l_basic_pay
                                  ,p_PT_eff_start_date
                                  ,l_dummy_date);
  --
  -- need to convert to whatever the displayed value is
  p_basic_pay := ghr_pay_calc.convert_amount(l_basic_pay
                                            ,p_retained_grade.pay_basis
                                            ,p_pay_calc_data.pay_basis);
 END IF;


EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_basic_pay                 := NULL;
       p_PT_eff_start_date         := NULL;

   RAISE;

END get_basic_pay_MAIN_per;
--
PROCEDURE get_min_pay_table_value (p_user_table_id  IN  NUMBER
                             ,p_pay_plan            IN  VARCHAR2
                             ,p_grade_or_level      IN  VARCHAR2
                             ,p_effective_date      IN  DATE
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_PT_value            OUT NOCOPY NUMBER
                             ,p_PT_eff_start_date   OUT NOCOPY DATE
                             ,p_PT_eff_end_date     OUT NOCOPY DATE) IS

-- for a given pay_plan and grade this returns the minimum value and step
l_PT_value       NUMBER;
l_record_found      BOOLEAN := FALSE;
--
CURSOR cur_pay IS
  SELECT cin.value             basic_pay
        ,col.user_column_name  step_or_rate
        ,cin.effective_start_date
        ,cin.effective_end_date
  FROM   pay_user_column_instances_f cin
        ,pay_user_rows_f             urw
        ,pay_user_columns            col
  WHERE col.user_table_id = p_user_table_id
  AND   urw.user_table_id = p_user_table_id
  AND   urw.row_low_range_or_name = p_pay_plan||'-'||p_grade_or_level
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN urw.effective_start_date AND urw.effective_end_date
  AND   cin.user_row_id = urw.user_row_id
  AND   cin.user_column_id = col.user_column_id
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN cin.effective_start_date AND cin.effective_end_date
  ORDER BY TO_NUMBER(cin.value) ASC;
--
-- The order by means we will get the lowest value first
BEGIN
  FOR cur_pay_rec IN cur_pay LOOP
    p_step_or_rate      := cur_pay_rec.step_or_rate;
    l_PT_value          := ROUND(cur_pay_rec.basic_pay,2);
    p_PT_value          := l_PT_value;
    p_PT_eff_start_date := cur_pay_rec.effective_start_date;
    p_PT_eff_end_date   := cur_pay_rec.effective_end_date;
    l_record_found      := TRUE;
    IF l_PT_value IS NULL THEN
    -- Set tokens to give name of pay table, pay plan, grade, step and rate
      hr_utility.set_message(8301,'GHR_38252_NULL_PAY_PLAN_VALUE');
      hr_utility.set_message_token('PAY_TABLE_NAME',ghr_pay_calc.get_user_table_name(p_user_table_id) );
      hr_utility.set_message_token('STEP',cur_pay_rec.step_or_rate);
      hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
      hr_utility.set_message_token('GRADE',p_grade_or_level);
--    hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
      hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date) );
      raise ghr_pay_calc.pay_calc_message;
    END IF;
    EXIT;
  END LOOP;
  --
  IF NOT l_record_found THEN
    -- Set tokens to give name of pay table, pay plan, grade, step and rate
    -- Note: the is no step!
    hr_utility.set_message(8301,'GHR_38257_NO_MIN_PAY_PLAN_VAL');
    hr_utility.set_message_token('PAY_TABLE_NAME',ghr_pay_calc.get_user_table_name(p_user_table_id) );
    hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
    hr_utility.set_message_token('GRADE',p_grade_or_level);
--  hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
    hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date) );
    raise ghr_pay_calc.pay_calc_message;
  END IF;
  --

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_step_or_rate          := NULL;
       p_PT_value              := NULL;
       p_PT_eff_start_date     := NULL;
       p_PT_eff_end_date       := NULL;

   RAISE;

END get_min_pay_table_value;
--
PROCEDURE get_max_pay_table_value (p_user_table_id  IN  NUMBER
                             ,p_pay_plan            IN  VARCHAR2
                             ,p_grade_or_level      IN  VARCHAR2
                             ,p_effective_date      IN  DATE
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_PT_value            OUT NOCOPY NUMBER
                             ,p_PT_eff_start_date   OUT NOCOPY DATE
                             ,p_PT_eff_end_date     OUT NOCOPY DATE) IS
--
-- for a given pay_plan and grade this returns the minimum value and step
l_PT_value       NUMBER;
l_record_found   BOOLEAN := FALSE;
--
CURSOR cur_pay IS
  SELECT cin.value             basic_pay
        ,col.user_column_name  step_or_rate
        ,cin.effective_start_date
        ,cin.effective_end_date
  FROM   pay_user_column_instances_f cin
        ,pay_user_rows_f             urw
        ,pay_user_columns            col
  WHERE col.user_table_id = p_user_table_id
  AND   urw.user_table_id = p_user_table_id
  AND   urw.row_low_range_or_name = p_pay_plan||'-'||p_grade_or_level
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN urw.effective_start_date AND urw.effective_end_date
  AND   cin.user_row_id = urw.user_row_id
  AND   cin.user_column_id = col.user_column_id
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN cin.effective_start_date AND cin.effective_end_date
  ORDER BY TO_NUMBER(cin.value) DESC;
--
-- The order by means we will get the HIGHEST value first
BEGIN
  FOR cur_pay_rec IN cur_pay LOOP
    p_step_or_rate      := cur_pay_rec.step_or_rate;
    l_PT_value          := ROUND(cur_pay_rec.basic_pay,2);
    p_PT_value          := l_PT_value;
    p_PT_eff_start_date := cur_pay_rec.effective_start_date;
    p_PT_eff_end_date   := cur_pay_rec.effective_end_date;
    l_record_found      := TRUE;

    IF l_PT_value IS NULL THEN
    -- Set tokens to give name of pay table, pay plan, grade, step and rate
      hr_utility.set_message(8301,'GHR_38252_NULL_PAY_PLAN_VALUE');
      hr_utility.set_message_token('PAY_TABLE_NAME',ghr_pay_calc.get_user_table_name(p_user_table_id) );
      hr_utility.set_message_token('STEP',cur_pay_rec.step_or_rate);
      hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
      hr_utility.set_message_token('GRADE',p_grade_or_level);
--    hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
      hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date) );
      raise ghr_pay_calc.pay_calc_message;
    END IF;
    EXIT;
  END LOOP;
  --
  IF NOT l_record_found THEN
    -- Set tokens to give name of pay table, pay plan, grade, step and rate
    hr_utility.set_message(8301,'GHR_38258_NO_MAX_PAY_PLAN_VAL');
    hr_utility.set_message_token('PAY_TABLE_NAME',ghr_pay_calc.get_user_table_name(p_user_table_id) );
    hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
    hr_utility.set_message_token('GRADE',p_grade_or_level);
--  hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
    hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date) );
    raise ghr_pay_calc.pay_calc_message;
  END IF;
  --

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_step_or_rate          := NULL;
       p_PT_value              := NULL;
       p_PT_eff_start_date     := NULL;
       p_PT_eff_end_date       := NULL;

   RAISE;

END get_max_pay_table_value;
---
---
--
PROCEDURE get_890_pay_table_value (p_user_table_id  IN  NUMBER
                             ,p_pay_plan            IN  VARCHAR2
                             ,p_grade_or_level      IN  VARCHAR2
                             ,p_effective_date      IN  DATE
                             ,p_current_val         IN  NUMBER
			     ,p_in_step_or_rate     IN  VARCHAR2
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_PT_value            OUT NOCOPY NUMBER
                             ,p_PT_eff_start_date   OUT NOCOPY DATE
                             ,p_PT_eff_end_date     OUT NOCOPY DATE) IS
--
-- for a given pay_plan and grade this returns the minimum value and step
l_PT_value       NUMBER;
l_record_found   BOOLEAN := FALSE;
---BUG 6211029
l_in_PT_value    NUMBER;
l_in_PT_eff_start_date  DATE;
l_in_PT_eff_end_date    DATE;
-- BUG 6211029
--
CURSOR cur_pay IS
  SELECT cin.value             basic_pay
        ,col.user_column_name  step_or_rate
        ,cin.effective_start_date
        ,cin.effective_end_date
  FROM   pay_user_column_instances_f cin
        ,pay_user_rows_f             urw
        ,pay_user_columns            col
  WHERE col.user_table_id = p_user_table_id
  AND   urw.user_table_id = p_user_table_id
  AND   urw.row_low_range_or_name = p_pay_plan||'-'||p_grade_or_level
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN urw.effective_start_date AND urw.effective_end_date
  AND   cin.user_row_id = urw.user_row_id
  AND   cin.user_column_id = col.user_column_id
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN cin.effective_start_date AND cin.effective_end_date
  ORDER BY TO_NUMBER(cin.value) ASC;
--
-- The order by means we will get the LOWEST value first
BEGIN
  --BUG# 6211029 Added p_in_step_or_rate entered by the user initially after changing position
  -- this will be passed as '01' if the value of User entered step or rate is greater than the
  -- basic pay then need to consider the same otherwise need to be autopopulated with
  -- the Minimum step or rate having value greater than the adjusted basic pay
  IF p_in_step_or_rate is not null THEN
     ghr_pay_calc.get_pay_table_value (p_user_table_id     => p_user_table_id
                                    ,p_pay_plan          => p_pay_plan
                                    ,p_grade_or_level    => p_grade_or_level
                                    ,p_step_or_rate      => p_in_step_or_rate
                                    ,p_effective_date    => p_effective_date
                                    ,p_PT_value          => l_in_PT_value
                                    ,p_PT_eff_start_date => l_in_PT_eff_start_date
                                    ,p_PT_eff_end_date   => l_in_PT_eff_end_date);

  END IF;
  IF NVL(l_in_PT_value,0) >= p_current_val AND p_in_step_or_rate is not null then
     p_step_or_rate      := p_in_step_or_rate;
     p_PT_value          := l_in_PT_value;
     p_PT_eff_start_date := l_in_PT_eff_start_date;
     p_PT_eff_end_date   := l_in_PT_eff_end_date;
  ELSE
  --End of BUG 6211029
    FOR cur_pay_rec IN cur_pay LOOP
      IF cur_pay_rec.basic_pay >= p_current_val then
         p_step_or_rate      := cur_pay_rec.step_or_rate;
         l_PT_value          := ROUND(cur_pay_rec.basic_pay,2);
         p_PT_value          := l_PT_value;
         p_PT_eff_start_date := cur_pay_rec.effective_start_date;
         p_PT_eff_end_date   := cur_pay_rec.effective_end_date;
         l_record_found      := TRUE;

        IF l_PT_value IS NULL THEN
         -- Set tokens to give name of pay table, pay plan, grade, step and rate
           hr_utility.set_message(8301,'GHR_38252_NULL_PAY_PLAN_VALUE');
           hr_utility.set_message_token('PAY_TABLE_NAME',ghr_pay_calc.get_user_table_name(p_user_table_id) );
	   hr_utility.set_message_token('STEP',cur_pay_rec.step_or_rate);
   	   hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
	   hr_utility.set_message_token('GRADE',p_grade_or_level);
   --	   hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
  	   hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date) );
	   raise ghr_pay_calc.pay_calc_message;
        END IF;
        EXIT;
      END IF;
    END LOOP;

    --
    IF NOT l_record_found THEN
      -- Set tokens to give name of pay table, pay plan, grade, step and rate
      hr_utility.set_message(8301,'GHR_38258_NO_MAX_PAY_PLAN_VAL');
      hr_utility.set_message_token('PAY_TABLE_NAME',ghr_pay_calc.get_user_table_name(p_user_table_id) );
      hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
      hr_utility.set_message_token('GRADE',p_grade_or_level);
    --  hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
      hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date) );
      raise ghr_pay_calc.pay_calc_message;
    END IF;
  --
 END IF;   -- p_in_step_or_rate Comparison

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_step_or_rate          := NULL;
       p_PT_value              := NULL;
       p_PT_eff_start_date     := NULL;
       p_PT_eff_end_date       := NULL;

   RAISE;

END get_890_pay_table_value;
--
--
--
-- This procedure gets the minimum pay table value that is greater than a given value (X)
-- and returns the step associated with it
-- will return null if there is not one as opposed to error
PROCEDURE get_min_pay_table_value_GT_X (p_user_table_id  IN  NUMBER
                             ,p_pay_plan            IN  VARCHAR2
                             ,p_grade_or_level      IN  VARCHAR2
                             ,p_effective_date      IN  DATE
                             ,p_x                   IN  NUMBER
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_PT_value            OUT NOCOPY NUMBER) IS

-- for a given pay_plan and grade this returns the minimum value and step
l_PT_value       NUMBER;
l_record_found   BOOLEAN := FALSE;
--
CURSOR cur_pay IS
  SELECT cin.value             basic_pay
        ,col.user_column_name  step_or_rate
        ,cin.effective_start_date
        ,cin.effective_end_date
  FROM   pay_user_column_instances_f cin
        ,pay_user_rows_f             urw
        ,pay_user_columns            col
  WHERE col.user_table_id = p_user_table_id
  AND   urw.user_table_id = p_user_table_id
  AND   urw.row_low_range_or_name = p_pay_plan||'-'||p_grade_or_level
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN urw.effective_start_date AND urw.effective_end_date
  AND   cin.user_row_id = urw.user_row_id
  AND   cin.user_column_id = col.user_column_id
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN cin.effective_start_date AND cin.effective_end_date
  AND   cin.value >= p_x
  ORDER BY TO_NUMBER(cin.value) ASC;
--
-- The order by means we will get the lowest value first
BEGIN
  FOR cur_pay_rec IN cur_pay LOOP
    p_step_or_rate      := cur_pay_rec.step_or_rate;
    p_PT_value          := ROUND(cur_pay_rec.basic_pay,2);
    l_record_found      := TRUE;
    EXIT;
  END LOOP;
  --
  IF NOT l_record_found THEN
    p_step_or_rate      := null;
    p_PT_value          := null;
  END IF;
  --

 EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_step_or_rate          := NULL;
       p_PT_value              := NULL;

   RAISE;
END get_min_pay_table_value_GT_X;
--
--
PROCEDURE get_basic_pay_SAL891_pos (p_pay_calc_data IN  ghr_pay_calc.pay_calc_in_rec_type
                                   ,p_basic_pay     OUT NOCOPY NUMBER
                                   ,p_step_or_rate  OUT NOCOPY VARCHAR2) IS
--
l_min_basic_pay  NUMBER;
l_min_step       VARCHAR2(30);
l_max_basic_pay  NUMBER;
l_max_step       VARCHAR2(30);
l_step_diff      INTEGER;
l_basic_pay      NUMBER;
l_dummy_date     DATE;
BEGIN
  --
  get_min_pay_table_value(p_pay_calc_data.user_table_id
                          ,'GS'
                          ,p_pay_calc_data.grade_or_level
                          ,p_pay_calc_data.effective_date
                          ,l_min_step
                          ,l_min_basic_pay
                          ,l_dummy_date
                          ,l_dummy_date);
  --
  get_max_pay_table_value(p_pay_calc_data.user_table_id
                          ,'GS'
                          ,p_pay_calc_data.grade_or_level
                          ,p_pay_calc_data.effective_date
                          ,l_max_step
                          ,l_max_basic_pay
                          ,l_dummy_date
                          ,l_dummy_date);

  --
  -- May have to be careful using to_number since what we call the step is actually stored
  -- as a varchar2 there ful it actually has the possibility of having characters in it
  -- ORA-01722: invalid number will occur in this case
  -- Also be careful if we got 0?
  BEGIN
    l_step_diff := TO_NUMBER(l_max_step) - TO_NUMBER(l_min_step);
  END;
  ----Basic Pay Calc issue in GMIT Pay --- Basically Matching with locality C2 step.
  l_basic_pay := p_pay_calc_data.current_basic_pay + CEIL(( (l_max_basic_pay - l_min_basic_pay)/l_step_diff));
  IF l_basic_pay > l_max_basic_pay THEN
    p_basic_pay    := l_max_basic_pay;
    p_step_or_rate := '00';                 ----------l_max_step;
  ELSE
    p_basic_pay    := l_basic_pay;
    p_step_or_rate := '00';
  END IF;
  --

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_step_or_rate          := NULL;
       p_basic_pay             := NULL;

   RAISE;
END get_basic_pay_SAL891_pos;
--
PROCEDURE get_basic_pay_SAL891_per (p_pay_calc_data  IN  ghr_pay_calc.pay_calc_in_rec_type
                                   ,p_retained_grade IN  ghr_pay_calc.retained_grade_rec_type
                                   ,p_basic_pay      OUT NOCOPY NUMBER
                                   ,p_step_or_rate   OUT NOCOPY VARCHAR2) IS
--
-- This one always uses the retained grade details no matter what
--
l_min_basic_pay  NUMBER;
l_min_step       VARCHAR2(30);
l_max_basic_pay  NUMBER;
l_max_step       VARCHAR2(30);
l_step_diff      INTEGER;
l_basic_pay      NUMBER;
l_dummy_date     DATE;
--
BEGIN
  --
  get_min_pay_table_value(p_retained_grade.user_table_id
                          ,'GS'
                          ,p_retained_grade.grade_or_level
                          ,p_pay_calc_data.effective_date
                          ,l_min_step
                          ,l_min_basic_pay
                          ,l_dummy_date
                          ,l_dummy_date);
   --
   get_max_pay_table_value(p_retained_grade.user_table_id
                          ,'GS'
                          ,p_retained_grade.grade_or_level
                          ,p_pay_calc_data.effective_date
                          ,l_max_step
                          ,l_max_basic_pay
                          ,l_dummy_date
                          ,l_dummy_date);

  --
  -- May have to be careful using to_number since what we call the step is actually stored
  -- as a varchar2 there ful it actually has the possibility of having characters in it
  -- ORA-01722: invalid number will occur in this case
  -- Also be careful if we got 0?
  BEGIN
    l_step_diff := TO_NUMBER(l_max_step) - TO_NUMBER(l_min_step);
  END;
  -----l_basic_pay := ROUND(p_pay_calc_data.current_basic_pay + ( (l_max_basic_pay - l_min_basic_pay)/l_step_diff) ,0);
  l_basic_pay := p_pay_calc_data.current_basic_pay + CEIL(( (l_max_basic_pay - l_min_basic_pay)/l_step_diff));
  IF l_basic_pay > l_max_basic_pay THEN
    p_basic_pay    := l_max_basic_pay;
    p_step_or_rate := '00';                 ----------l_max_step;
  ELSE
    p_basic_pay    := l_basic_pay;
    p_step_or_rate := '00';
  END IF;
  --

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_step_or_rate          := NULL;
       p_basic_pay             := NULL;

   RAISE;

END get_basic_pay_SAL891_per;
--
PROCEDURE check_current_PT (p_PT_date        IN DATE
                           ,p_eff_start_date IN DATE) IS
BEGIN
  IF p_PT_date <> p_eff_start_date THEN
    hr_utility.set_message(8301,'GHR_38395_NOT_CURRENT_PT');
    -- hr_utility.set_message_token('PAY_TABLE_NAME',get_user_table_name(p_user_table_id) );
    raise ghr_pay_calc.pay_calc_message;
  END IF;
END check_current_PT;
--
PROCEDURE check_old_PT (p_PT_date      IN DATE
                       ,p_eff_end_date IN DATE) IS
BEGIN
/* This procedure is no more required as per Bug 3837402 .
  IF p_PT_date -1 <> p_eff_end_date THEN
    hr_utility.set_message(8301,'GHR_38396_NOT_OLD_PT');
    -- hr_utility.set_message_token('PAY_TABLE_NAME',get_user_table_name(p_user_table_id) );
    raise ghr_pay_calc.pay_calc_message;
  END IF;
*/
 null;

END check_old_PT;
--
PROCEDURE get_basic_pay_SAL894_6step(p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                    ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
                                    ,p_pay_table_data    IN  VARCHAR2
                                    ,p_basic_pay         OUT NOCOPY NUMBER
                                    ,p_PT_eff_start_date OUT NOCOPY DATE
                                    ,p_7dp               OUT NOCOPY NUMBER) IS
--
l_user_table_id      NUMBER;
l_pay_plan           VARCHAR2(30);
l_grade_or_level     VARCHAR2(60);
l_step_or_rate       VARCHAR2(30);
l_pay_basis          VARCHAR2(30);
--
l_PT_eff_start_date  DATE;
l_eff_start_date     DATE;
l_eff_end_date       DATE;
--
l_dummy_step         VARCHAR2(30);
--
l_old_basic_pay      NUMBER;
l_min_old_basic_pay  NUMBER;
l_max_old_basic_pay  NUMBER;
--
l_cur_basic_pay      NUMBER;
l_min_cur_basic_pay  NUMBER;
l_max_cur_basic_pay  NUMBER;
--
l_A NUMBER;
l_B NUMBER;
l_C NUMBER;
l_D NUMBER;
l_E NUMBER;
l_basic_pay NUMBER;
--
BEGIN
  -- First work out what pay table data to use
  --
  -- bug 710171 Always use GS as the Pay plan
  l_pay_plan := 'GS';
  IF p_pay_table_data  = 'POSITION' THEN
    l_user_table_id  := p_pay_calc_data.user_table_id;
    l_grade_or_level := p_pay_calc_data.grade_or_level;
    l_pay_basis      := p_pay_calc_data.pay_basis;
    --
  ELSE
    l_user_table_id  := p_retained_grade.user_table_id;
    l_grade_or_level := p_retained_grade.grade_or_level;
    l_pay_basis      := p_retained_grade.pay_basis;
    --
  END IF;
                                                                                          --AVR
  IF p_pay_calc_data.noa_code = '894' AND p_pay_calc_data.pay_rate_determinant = 'M' THEN
     IF p_retained_grade.grade_or_level IS NOT NULL THEN
        l_grade_or_level := p_retained_grade.grade_or_level;
        l_step_or_rate   := p_retained_grade.step_or_rate;
     ELSE
        l_grade_or_level := p_pay_calc_data.grade_or_level;
        l_step_or_rate   := p_pay_calc_data.step_or_rate;
     END IF;
  END IF;
                                                                                          --AVR
  -- Get current value just to get the Pay Table effective date
  ghr_pay_calc.get_pay_table_value(l_user_table_id
                                  ,l_pay_plan
                                  ,l_grade_or_level
                                  ,'01'
                                  ,p_pay_calc_data.effective_date
                                  ,l_cur_basic_pay
                                  ,l_eff_start_date
                                  ,l_eff_end_date);
  --
  l_PT_eff_start_date := l_eff_start_date;
  --
  -- Step 1
  ---------
  get_min_pay_table_value(l_user_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date - 1
                         ,l_dummy_step
                         ,l_min_old_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);
  --
  -- Check we used an old Pay Table
  -- This vaidation is no more required as per bug 3837402.
--  check_old_PT (l_PT_eff_start_date, l_eff_end_date);
  --
  -- bug 710171 Use Current basic Pay as the starting point
  l_A := p_pay_calc_data.current_basic_pay - l_min_old_basic_pay;
  --
  -- Step 2
  ---------
  get_max_pay_table_value(l_user_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date - 1
                         ,l_dummy_step
                         ,l_max_old_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);
  --
  -- Check we used an old Pay Table
 -- This vaidation is no more required as per bug 3837402.
-- check_old_PT (l_PT_eff_start_date, l_eff_end_date);
  --
  l_B := l_max_old_basic_pay - l_min_old_basic_pay;
  --
  -- Step 3 -- Otherwise refered to as the 7d.p. which is also used in the
  --           locality adj calc
  ---------
  l_C := TRUNC( (l_A/l_B) ,7);
  --
  -- Step 4
  ---------
  --
  get_min_pay_table_value(l_user_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_min_cur_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);
  --
  -- Check we used a current Pay Table
  check_current_PT (l_PT_eff_start_date, l_eff_start_date);
  --
  get_max_pay_table_value(l_user_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_max_cur_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);
  --
  -- Check we used a current Pay Table
  check_current_PT (l_PT_eff_start_date, l_eff_start_date);
  --
  l_D := l_max_cur_basic_pay - l_min_cur_basic_pay;
  --
  -- Step 5
  ---------
  l_E := l_C * l_D;
  --
  -- Step 6
  ---------
  ---l_basic_pay := ROUND(l_E + l_min_cur_basic_pay); --Bug#6603789 added round

   --BUG# 6680463 5 USC 531.205  --Basic rate should be rounded to the next whole dollar amount

  l_basic_pay := CEIL(l_E + l_min_cur_basic_pay);

  --
  p_basic_pay :=   ghr_pay_calc.convert_amount(l_basic_pay
                                              ,l_pay_basis
                                              ,p_pay_calc_data.pay_basis);
  --
  p_PT_eff_start_date := l_PT_eff_start_date;
  p_7dp := l_C;
  --

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_7dp                   := NULL;
       p_basic_pay             := NULL;
       p_PT_eff_start_date      := NULL;

   RAISE;
END get_basic_pay_SAL894_6step;
--
--
PROCEDURE get_basic_pay_SAL894_50 (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                  ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
                                  ,p_pay_table_data    IN  VARCHAR2
                                  ,p_basic_pay         OUT NOCOPY NUMBER
                                  ,p_step              OUT NOCOPY VARCHAR2
                                  ,p_prd               OUT NOCOPY VARCHAR2
                                  ,p_PT_eff_start_date OUT NOCOPY DATE) IS
--
l_user_table_id      NUMBER;
l_pay_plan           VARCHAR2(30);
l_pc_pay_plan        VARCHAR2(30);
l_grade_or_level     VARCHAR2(60);
l_step_or_rate       VARCHAR2(30);
l_pay_basis          VARCHAR2(30);

l_dummy_step         VARCHAR2(30);
l_max_cur_basic_pay  NUMBER;
l_max_old_basic_pay  NUMBER;
l_ret_basic_pay      NUMBER;
l_pos_basic_pay      NUMBER;
l_pos_step           VARCHAR2(30);
--
l_PT_eff_start_date  DATE;
l_eff_start_date     DATE;
l_eff_end_date       DATE;
--
l_cur_pos_basic_pay  NUMBER;
--
l_converted_increase NUMBER;
--
l_user_table_name    pay_user_tables.user_table_name%type;

--Bug 3180991
l_old_user_table_id  NUMBER;
l_asg_ei_data        per_assignment_extra_info%rowtype;
l_prd_effective_date date;
l_retained_grade_rec ghr_pay_calc.retained_grade_rec_type;
l_position_id        per_assignments_f.position_id%type;
l_assignment_id      per_assignments_f.assignment_id%type;
l_temp_step	     per_people_extra_info.pei_information6%type;
l_effective_date     date;

--Cursor to get the position id.
CURSOR      cur_per_pos(p_effective_date date) is
  SELECT    asg.position_id, asg.assignment_id
  FROM      per_assignments_f asg
  WHERE     asg.person_id   =  p_pay_calc_data.person_id
  AND       trunc(nvl(p_effective_date,sysdate))
            between asg.effective_start_date and asg.effective_end_date
  AND       asg.assignment_type <> 'B'
  AND       asg.primary_flag = 'Y';

CURSOR      cur_per_pos_2 is
  SELECT    asg.effective_start_date,asg.position_id, asg.assignment_id
  FROM      per_assignments_f asg
  WHERE     asg.person_id   =  p_pay_calc_data.person_id
  AND       asg.position_id is not null
  AND       asg.assignment_type <> 'B'
  AND       asg.primary_flag = 'Y'
  ORDER BY  asg.effective_start_date;


CURSOR cur_pei (p_effective_date date) IS
  SELECT pei.person_extra_info_id
        ,pei.pei_information6     retained_user_table_id
        ,pei.pei_information9     retained_temp_step
  FROM   per_people_extra_info pei
  WHERE  pei.person_id = p_pay_calc_data.person_id
  AND    pei.information_type = 'GHR_US_RETAINED_GRADE'
  AND    p_effective_date BETWEEN NVL(fnd_date.canonical_to_date(pei.pei_information1),p_effective_date)
                          AND     NVL(fnd_date.canonical_to_date(pei.pei_information2),p_effective_date);
--Bug 3180991

BEGIN

  -- First work out what pay table data to use

  IF p_pay_table_data  = 'POSITION' THEN
    l_user_table_id  := p_pay_calc_data.user_table_id;
    l_pay_plan       := p_pay_calc_data.pay_plan;
    l_grade_or_level := p_pay_calc_data.grade_or_level;
    l_step_or_rate   := p_pay_calc_data.step_or_rate;
    l_pay_basis      := p_pay_calc_data.pay_basis;
    --
  ELSE
    l_user_table_id  := p_retained_grade.user_table_id;
    l_pay_plan       := p_retained_grade.pay_plan;
    l_grade_or_level := p_retained_grade.grade_or_level;
    l_step_or_rate   := p_retained_grade.step_or_rate;
    l_pay_basis      := p_retained_grade.pay_basis;
    --
  END IF;
  IF l_pay_plan IN ('GM','GH') THEN
    l_pay_plan := 'GS';
  END IF;
  --

  get_max_pay_table_value(l_user_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,p_pay_calc_data.effective_date
                         ,l_dummy_step
                         ,l_max_cur_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);

  hr_utility.set_location(' get_basic_pay_SAL894_50 After first max pay' ||l_eff_start_date,12);

  -- set the Pay Table efective date as this is the first lookup we have done
  l_PT_eff_start_date  := l_eff_start_date;

  --Bug# 3180991
  l_effective_date     := p_pay_calc_data.effective_date ;
  l_prd_effective_date := l_effective_date - 1;

  -- get the positin id and assignment id as on l_PT_eff_start_date-1 using the cursor.
    FOR per_pos_id in cur_per_pos(l_PT_eff_start_date-1)
    LOOP
      l_position_id  :=  per_pos_id.position_id;
      l_assignment_id := per_pos_id.assignment_id;
      hr_utility.set_location(' get_basic_pay_SAL894_50 Position id ' ||l_position_id,12);
    END LOOP;

    IF l_assignment_id is null THEN
       FOR per_pos_id_2 in cur_per_pos_2
       LOOP
           l_prd_effective_date := per_pos_id_2.effective_start_date;
           l_position_id  :=  per_pos_id_2.position_id;
           l_assignment_id := per_pos_id_2.assignment_id;
           hr_utility.set_location(' get_basic_pay_SAL894_50 Position id ' ||l_position_id,12);
           exit;
       END LOOP;
    END IF;

  IF l_assignment_id is not null THEN
  -- This is used to get the prd.
  hr_utility.set_location(' get_basic_pay_SAL894_50 l_assignment_id' ||l_assignment_id,10);
  hr_utility.set_location(' get_basic_pay_SAL894_50 l_prd_effective_date' ||l_prd_effective_date,10);

  ghr_history_fetch.fetch_asgei( p_assignment_id      =>  l_assignment_id
                                 ,p_information_type  =>  'GHR_US_ASG_SF52'
                                 ,p_date_effective    =>  l_prd_effective_date
                                 ,p_asg_ei_data       =>  l_asg_ei_data
                               );

  hr_utility.set_location(' get_basic_pay_SAL894_50 l_asg_ei_data.aei_information6 ' ||l_asg_ei_data.aei_information6 ,11);

  IF l_asg_ei_data.aei_information6 NOT IN ('A','B','E','F','U','V') THEN

    l_old_user_table_id := ghr_pay_calc.get_user_table_id(  l_position_id , l_prd_effective_date );
    hr_utility.set_location(' get_basic_pay_SAL894_50 l_old_user_table_id ' ||l_old_user_table_id ,13);

  ELSE

    --Get the retain grade info as on l_PT_eff_start_date-1
    hr_utility.set_location(' get_basic_pay_SAL894_50 p_pay_calc_data.person_id' ||p_pay_calc_data.person_id,14);
    hr_utility.set_location(' get_basic_pay_SAL894_50 l_PT_eff_start_date-1' ||l_PT_eff_start_date,14);
    hr_utility.set_location(' get_basic_pay_SAL894_50 p_pay_calc_data.pa_request_id' ||p_pay_calc_data.pa_request_id,14);

    hr_utility.set_location(' get_basic_pay_SAL894_50 l_old_user_table_id ' ||l_old_user_table_id ,14);

/*  We cannot use this procedure as pa_request_id is not available as of now.
l_retained_grade_rec := ghr_pc_basic_pay.get_retained_grade_details
                                             (p_person_id      => p_pay_calc_data.person_id
                                             ,p_effective_date => l_prd_effective_date
					     ,p_pa_request_id  => p_pay_calc_data.pa_request_id);

 */
    FOR cur_pei_rec IN cur_pei(l_prd_effective_date)
    LOOP
      l_old_user_table_id := cur_pei_rec.retained_user_table_id;
      l_temp_step         := cur_pei_rec.retained_temp_step;
    END LOOP;

    hr_utility.set_location(' get_basic_pay_SAL894_50 temp step after loop' ||l_temp_step ,14);
    hr_utility.set_location(' get_basic_pay_SAL894_50 l_old_user_table_id after loop' ||l_old_user_table_id ,14);

    --check for temp promotion and temp step is not null then use ghr_pay_calc.get_user_table_id.
    IF l_temp_step IS NOT NULL THEN
      l_old_user_table_id := ghr_pay_calc.get_user_table_id(  l_position_id , l_prd_effective_date );
      hr_utility.set_location(' get_basic_pay_SAL894_50 if l_old_user_table_id ' ||l_old_user_table_id ,15);
    END IF;

  END IF;

 ELSE
    l_old_user_table_id := l_user_table_id;
 END IF;

  --Bug# 3180991

    get_max_pay_table_value(l_old_user_table_id -- changed for 3180991
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_effective_date - 1
                         ,l_dummy_step
                         ,l_max_old_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);


  --Bug# 3180991 Added If Statement
  -- This vaidation is no more required as per bug 3837402.
/*  IF l_old_user_table_id = l_user_table_id THEN
  --
    -- Check we used an old Pay Table

    check_old_PT (l_PT_eff_start_date, l_eff_end_date);
    --
  END IF;
*/
  l_converted_increase :=   ghr_pay_calc.convert_amount( (l_max_cur_basic_pay - l_max_old_basic_pay)/2
                                                       ,l_pay_basis
                                                       ,p_pay_calc_data.pay_basis);
  --

--- Bug 1579674
  if l_pay_basis = 'PH' then
     l_ret_basic_pay := ROUND(p_pay_calc_data.current_basic_pay + l_converted_increase,2);
  else
     l_ret_basic_pay := ROUND(p_pay_calc_data.current_basic_pay + l_converted_increase,0);
  end if;
--- Bug 1579674


  p_PT_eff_start_date := l_PT_eff_start_date;
  --
  IF p_pay_calc_data.pay_plan IN ('GM','GH') THEN
    l_pc_pay_plan := 'GS';
  ELSE
    l_pc_pay_plan := p_pay_calc_data.pay_plan;
  END IF;


  get_min_pay_table_value_GT_X (l_user_table_id
                               ,l_pay_plan
                               ,l_grade_or_level
                               ,p_pay_calc_data.effective_date
                               ,l_ret_basic_pay
                               ,l_pos_step
                               ,l_pos_basic_pay);


  IF l_pos_basic_pay IS NULL THEN
    -- For pay plan CA need to check it hasn't exceeded EX-04 (table 0000 step 00)
    IF l_pay_plan = 'CA' THEN
      IF l_ret_basic_pay > ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'04'
                                                                   ,'00'
                                                                   ,p_pay_calc_data.effective_date) THEN
        hr_utility.set_message(8301, 'GHR_38587_NO_CALC_EXCEED_EX_IV');
        hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
        raise ghr_pay_calc.unable_to_calculate;
      ELSE
        p_basic_pay := l_ret_basic_pay;
        p_step      := '00';
        p_prd       := NULL;
      END IF;
    ELSE
      p_basic_pay := l_ret_basic_pay;
      p_step      := '00';
      p_prd       := NULL;
    END IF;
  ELSE -- (pay retention is being terminated)
    -- Do not know what to do if pay plan is ES or IE and pay retention is terminated!
    IF l_pay_plan = 'CA' THEN
      hr_utility.set_message(8301, 'GHR_38588_NO_CALC_PAY_RET_END');
      hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
      raise ghr_pay_calc.unable_to_calculate;
    ELSE
      p_basic_pay := l_pos_basic_pay;
      p_step      := l_pos_step;
      l_user_table_name := ghr_pay_calc.get_user_table_name(l_user_table_id);
      IF p_pay_calc_data.pay_rate_determinant IN ('J','K','R','S','3') THEN
        IF l_pay_basis = 'PH' THEN
           p_prd := 0;
        ELSIF l_user_table_name = ghr_pay_calc.l_standard_table_name  THEN
          p_prd := '0';
        ELSE
          p_prd := '6';
        END IF;
      ELSIF p_pay_calc_data.pay_rate_determinant = 'U' THEN
            IF l_pay_basis = 'PH' THEN
               p_prd := 'B';
            ELSIF l_user_table_name = ghr_pay_calc.l_standard_table_name  THEN
               p_prd := 'B';
            ELSE
               p_prd := 'F';
            END IF;
      ELSIF p_pay_calc_data.pay_rate_determinant = 'V' THEN
            IF l_pay_basis = 'PH' THEN
               p_prd := 'A';
            ELSIF l_user_table_name = ghr_pay_calc.l_standard_table_name  THEN
               p_prd := 'A';
            ELSE
               p_prd := 'E';
            END IF;
      END IF; -- end of PRD check inside Pay rentention terminated
      --
    END IF;
  END IF;

--
EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_step                  := NULL;
       p_prd                   := NULL;
       p_basic_pay             := NULL;
       p_PT_eff_start_date      := NULL;

   RAISE;

END get_basic_pay_SAL894_50;
--
--
PROCEDURE get_basic_pay_SAL894_100 (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                   ,p_basic_pay         OUT NOCOPY NUMBER
                                   ,p_PT_eff_start_date OUT NOCOPY DATE) IS
--
l_dummy_step         VARCHAR2(30);
l_pay_plan           VARCHAR2(30);
l_max_cur_basic_pay  NUMBER;
--
l_max_old_basic_pay  NUMBER;
--
l_PT_eff_start_date  DATE;
l_eff_start_date     DATE;
l_eff_end_date       DATE;
--For Bug 3180991
l_old_user_table_id  NUMBER;
l_effective_date     DATE;
--
BEGIN
  IF l_pay_plan IN ('GM','GH') THEN
    l_pay_plan := 'GS';
  ELSE
    l_pay_plan := p_pay_calc_data.pay_plan;
  END IF;
  --
  get_max_pay_table_value(p_pay_calc_data.user_table_id
                         ,l_pay_plan
                         ,p_pay_calc_data.grade_or_level
                         ,p_pay_calc_data.effective_date
                         ,l_dummy_step
                         ,l_max_cur_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);
  --
  -- Set eff_start date of the Pay Table
  l_PT_eff_start_date  := l_eff_start_date;

  l_effective_date     := p_pay_calc_data.effective_date;
  --
  --Bug# 3180991
  l_old_user_table_id := ghr_pay_calc.get_user_table_id(  p_pay_calc_data.position_id, l_PT_eff_start_date-1 );
  --Bug# 3180991

  get_max_pay_table_value(l_old_user_table_id
                         ,l_pay_plan
                         ,p_pay_calc_data.grade_or_level
                         ,l_effective_date   - 1
                         ,l_dummy_step
                         ,l_max_old_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);

  --Bug# 3180991 Added If Statement
  -- This vaidation is no more required as per bug 3837402.
/*  IF l_old_user_table_id = p_pay_calc_data.user_table_id THEN
    --
    -- Check we used an old Pay Table
      -- This vaidation is no more required.
    check_old_PT (l_PT_eff_start_date, l_eff_end_date);
    --
  END IF;
*/
  p_basic_pay := ROUND(p_pay_calc_data.current_basic_pay + (l_max_cur_basic_pay - l_max_old_basic_pay) ,0);
  --
  p_PT_eff_start_date := l_PT_eff_start_date;
  --

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_basic_pay             := NULL;
       p_PT_eff_start_date     := NULL;

   RAISE;
END get_basic_pay_SAL894_100;
--
--
FUNCTION get_next_WGI_step (p_pay_plan      IN VARCHAR2
                           ,p_current_step  IN VARCHAR2)
 RETURN VARCHAR2 IS
--
-- I assume there can only be one record for a given pay_plan and user table_id
CURSOR cur_ppw IS
  SELECT ppw.to_step
        ,ppl.maximum_step
  FROM   ghr_pay_plan_waiting_periods ppw
        ,ghr_pay_plans                ppl
  WHERE  ppl.pay_plan            = p_pay_plan
  AND    ppl.equivalent_pay_plan = ppw.pay_plan
  AND    ppw.from_step           = p_current_step;
--
l_new_step     VARCHAR2(30);
BEGIN
  FOR cur_ppw_rec IN cur_ppw LOOP
    l_new_step := cur_ppw_rec.to_step;
    --
    -- If the new step or rate is greater then the max then use the max
    IF l_new_step > cur_ppw_rec.maximum_step THEN
      l_new_step := cur_ppw_rec.maximum_step;
    END IF;
    --
    RETURN(l_new_step);
  END LOOP;
  --
  -- If we got here no record was returned
  -- set tokens to say the user table name and pay_plan that was used
  hr_utility.set_message(8301, 'GHR_38259_NO_WGI_STEP');
  hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
  raise ghr_pay_calc.pay_calc_message;
  --
END get_next_WGI_step;
--
PROCEDURE get_basic_pay_SALWGI_pos (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                 ,p_basic_pay         OUT NOCOPY NUMBER
                                 ,p_new_step_or_rate  OUT NOCOPY VARCHAR2) IS
--
l_new_step_or_rate VARCHAR2(30);
l_dummy_date       DATE;
BEGIN
  -- This is the calcualation of a salary Change (SALARY_CHG) noac codes 867 - Interim Within Grade Increase,
  -- 892 - Quality Increase, 893 - Within-Grade Increase, PRD of 0 or 6:
  -- Basically you just get the next step by adding the wgi_step_or_rate on to the current step to get
  -- a new one you then use that to look up on the pay tables
  --
  --
  l_new_step_or_rate := get_next_WGI_step (p_pay_calc_data.pay_plan
                                          ,p_pay_calc_data.current_step_or_rate);

  ghr_pay_calc.get_pay_table_value(p_pay_calc_data.user_table_id
                                  ,p_pay_calc_data.pay_plan
                                  ,p_pay_calc_data.grade_or_level
                                  ,l_new_step_or_rate
                                  ,p_pay_calc_data.effective_date
                                  ,p_basic_pay
                                  ,l_dummy_date
                                  ,l_dummy_date);
  --
  p_new_step_or_rate := l_new_step_or_rate;
  --

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_basic_pay             := NULL;
       p_new_step_or_rate      := NULL;

   RAISE;
END get_basic_pay_SALWGI_pos;
--
PROCEDURE get_basic_pay_SALWGI_per (p_pay_calc_data   IN  ghr_pay_calc.pay_calc_in_rec_type
                                 ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
                                 ,p_basic_pay         OUT NOCOPY NUMBER
                                 ,p_new_step_or_rate  OUT NOCOPY VARCHAR2) IS
--
-- This one always uses the retained grade details no matter what
--
l_basic_pay        NUMBER;
l_new_step_or_rate VARCHAR2(30);
--
l_dummy_date       DATE;
l_step_or_rate     VARCHAR2(30);
l_pay_plan         VARCHAR2(30);
l_grade_or_level   VARCHAR2(60);
l_user_table_id    NUMBER;
l_pay_basis        VARCHAR2(30);
--Bug 3021003
l_ret_flag BOOLEAN;
l_retained_grade ghr_pay_calc.retained_grade_rec_type;
l_temp_step VARCHAR2(30);

BEGIN
  -- This is the calcualation of a salary Change (SALARY_CHG) noac codes 867 - Interim Within Grade Increase,
  -- 892 - Quality Increase, 893 - Within-Grade Increase, PRD of A , B, E  or F:
  -- As for SAL1_WGI above except you use the retained grade details to do the look up and return 00 as the
  -- step
  -- Basically you just get the next step by adding the wgi_step_or_rate on to the current step to get
  -- a new one you then use that to look up on the pay tables
  --
  -- Bug 3021003
  l_retained_grade.pay_plan := p_retained_grade.pay_plan;
  l_retained_grade.grade_or_level := p_retained_grade.grade_or_level;
  l_retained_grade.step_or_rate := p_retained_grade.step_or_rate;
  l_retained_grade.temp_step := p_retained_grade.temp_step;

  hr_utility.set_location('NAR inside wgi_per',0);
 if p_retained_grade.temp_step is not null then
    l_step_or_rate      := p_retained_grade.temp_step;
    l_user_table_id     := p_pay_calc_data.user_table_id;
    l_pay_plan          := p_pay_calc_data.pay_plan;
    l_grade_or_level    := p_pay_calc_data.grade_or_level;
    l_pay_basis         := p_pay_calc_data.pay_basis;
 else
    l_step_or_rate      := p_retained_grade.step_or_rate;
    l_user_table_id     := p_retained_grade.user_table_id;
    l_pay_plan          := p_retained_grade.pay_plan;
    l_grade_or_level    := p_retained_grade.grade_or_level;
    l_pay_basis         := p_retained_grade.pay_basis;
 end if;

 IF nvl(g_noa_family_code,'XXX') = 'CORRECT' then
	-- Bug 3021003
    hr_utility.set_location('NAR inside noa_fam code = CORRECT ',5);
	ghr_pay_calc.is_retained_ia(p_pay_calc_data.person_id,
	                            p_pay_calc_data.effective_date,
						       l_retained_grade.pay_plan,
						       l_retained_grade.grade_or_level,
						       l_retained_grade.step_or_rate,
							   l_retained_grade.temp_step,
							   l_ret_flag);
			 IF l_ret_flag = TRUE THEN
			     hr_utility.set_location('NAR ret step ' ||l_retained_grade.step_or_rate,10);
			     hr_utility.set_location('NAR pay plan '||p_pay_calc_data.pay_plan,20);
				-- Check for Temp step
				 IF p_retained_grade.temp_step is not null then
	                 l_new_step_or_rate := get_next_WGI_step (l_retained_grade.pay_plan,l_step_or_rate);
				 ELSE
					 l_new_step_or_rate := get_next_WGI_step (l_retained_grade.pay_plan,l_retained_grade.step_or_rate);
				 END IF;
			     hr_utility.set_location('NAR new step after getting the step ' ||l_new_step_or_rate,30);
		     ELSE
    l_new_step_or_rate := l_step_or_rate;
		     END IF;
		      hr_utility.set_location('NAR new step after getting the step ' ||l_new_step_or_rate,40);
 ELSE
  l_new_step_or_rate := get_next_WGI_step (l_pay_plan
                                          ,l_step_or_rate);
 END IF;

  ghr_pay_calc.get_pay_table_value(l_user_table_id
                                  ,l_pay_plan
                                  ,l_grade_or_level
                                  ,l_new_step_or_rate
                                  ,p_pay_calc_data.effective_date
                                  ,l_basic_pay
                                  ,l_dummy_date
                                  ,l_dummy_date );
  --
  p_basic_pay := ghr_pay_calc.convert_amount(l_basic_pay
                                            ,l_pay_basis
                                            ,p_pay_calc_data.pay_basis);
  --
  p_new_step_or_rate := '00';
  --
EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_basic_pay             := NULL;
       p_new_step_or_rate      := NULL;

   RAISE;
END get_basic_pay_SALWGI_per;


PROCEDURE get_basic_pay_SAL894_PRDM (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                    ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
                                    ,p_basic_pay         OUT NOCOPY NUMBER
                                    ,p_prd               OUT NOCOPY VARCHAR2
                                    ,p_PT_eff_start_date OUT NOCOPY DATE) IS
--
l_user_table_id      NUMBER;
l_pay_plan           VARCHAR2(30);
l_pc_pay_plan        VARCHAR2(30);
l_grade_or_level     VARCHAR2(60);
l_step_or_rate       VARCHAR2(30);
l_pay_basis          VARCHAR2(30);

l_dummy_step         VARCHAR2(30);
l_dummy_date         DATE;
l_dummy_number       NUMBER;
l_max_cur_basic_pay  NUMBER;
l_max_old_basic_pay  NUMBER;
l_ret_basic_pay      NUMBER;
l_pos_basic_pay      NUMBER;
l_pos_step           VARCHAR2(30);
--
l_PT_eff_start_date  DATE;
l_eff_start_date     DATE;
l_eff_end_date       DATE;

l_basic_pay          NUMBER;
l_new_adj_basic_pay  NUMBER;
l_locality_adj       NUMBER;
--
----l_cur_pos_basic_pay  NUMBER;
--
----l_converted_increase NUMBER;
--
l_user_table_name            pay_user_tables.user_table_name%type;
l_adjustment_percentage      ghr_locality_pay_areas_f.adjustment_percentage%TYPE;
l_spl_basic_pay      NUMBER;
l_spl_adj_basic_pay  NUMBER;
l_spl_locality_adj   NUMBER;
l_A                  NUMBER;
l_B                  NUMBER;

l_proc               varchar2(30) := 'SAL894_PRDM';

l_new_std_relative_rate NUMBER;

BEGIN
  hr_utility.set_location('Entering ' || l_proc,5);
  -- First work out what pay table data to use
  --
  IF p_retained_grade.grade_or_level is NULL THEN
  hr_utility.set_location('Entering  ..No Retained Grade Info.. ' || l_proc,10);
    l_user_table_id  := p_pay_calc_data.user_table_id;
    l_pay_plan       := p_pay_calc_data.pay_plan;
    l_grade_or_level := p_pay_calc_data.grade_or_level;
    l_step_or_rate   := p_pay_calc_data.step_or_rate;
    l_pay_basis      := p_pay_calc_data.pay_basis;
    --
  ELSE
  hr_utility.set_location('Entering  ..Retained Grade Info.. ' || l_proc,10);
    l_user_table_id  := p_retained_grade.user_table_id;
    l_pay_plan       := p_retained_grade.pay_plan;
    l_grade_or_level := p_retained_grade.grade_or_level;
    l_step_or_rate   := p_retained_grade.step_or_rate;
    l_pay_basis      := p_retained_grade.pay_basis;
    --
  END IF;
  ---------Pay Plan should be always 'GS'
  ---------l_pay_plan               := 'GS';
  l_user_table_name        := ghr_pay_calc.get_user_table_name(l_user_table_id);
  l_adjustment_percentage  := ghr_pay_calc.get_lpa_percentage
                                           (p_pay_calc_data.duty_station_id
                                           ,p_pay_calc_data.effective_date);
  --
  IF l_pay_plan = 'GS' THEN

            hr_utility.set_location('Calculating for GS Plan ..Basic Pay ' || l_proc,15);
            hr_utility.set_location('user_table_id..' || to_char(l_user_table_id) ,15);

            ghr_pay_calc.get_pay_table_value(l_user_table_id
                                            ,l_pay_plan
                                            ,l_grade_or_level
                                            ,l_step_or_rate
                                            ,p_pay_calc_data.effective_date
                                            ,l_basic_pay
                                            ,l_PT_eff_start_date
                                            ,l_dummy_date);

            hr_utility.set_location('Calculating for GS Plan ..Locality Pay ' || l_proc,20);

            ghr_pay_calc.get_locality_adj_894_PRDM_GS
                             (p_user_table_id     => l_user_table_id
                             ,p_pay_plan          => l_pay_plan
                             ,p_grade_or_level    => l_grade_or_level
                             ,p_step_or_rate      => l_step_or_rate
                             ,p_effective_date    => p_pay_calc_data.effective_date
                             ,p_cur_adj_basic_pay => p_pay_calc_data.current_adj_basic_pay
                             ,p_new_basic_pay     => l_basic_pay
                             ,p_new_adj_basic_pay => l_new_adj_basic_pay
                             ,p_new_locality_adj  => l_locality_adj );

        p_basic_pay             := nvl(l_basic_pay,0);
        p_PT_eff_start_date     := l_PT_eff_start_date;

        IF l_user_table_name = ghr_pay_calc.l_standard_table_name  THEN
           l_spl_basic_pay     := ghr_pay_calc.get_standard_pay_table_value
                                          (l_pay_plan
                                          ,l_grade_or_level
                                          ,l_step_or_rate
                                          ,p_pay_calc_data.effective_date);
           l_spl_locality_adj  := ROUND(l_spl_basic_pay * (NVL(l_adjustment_percentage,0)/100),0);
           l_spl_adj_basic_pay := (l_spl_basic_pay + l_spl_locality_adj);
        ELSE
           l_spl_basic_pay     := nvl(l_basic_pay,0);
           l_A                 := ghr_pay_calc.get_standard_pay_table_value
                                          ('GS'
                                          ,l_grade_or_level
                                          ,l_step_or_rate
                                          ,p_pay_calc_data.effective_date);
           l_B                 := NVL(l_A,0) + ROUND(l_A * (NVL(l_adjustment_percentage,0)/100),0);
           IF (l_spl_basic_pay > l_B ) OR (l_spl_basic_pay = l_B ) THEN
              l_spl_adj_basic_pay := l_spl_basic_pay;
           ELSE
              l_spl_adj_basic_pay := l_spl_basic_pay + (l_B - l_spl_basic_pay);
           END IF;
         END IF;

        -- Now do the comparison!

         IF (l_basic_pay > l_new_adj_basic_pay)  OR
            (l_spl_adj_basic_pay > l_new_adj_basic_pay) THEN
             IF l_user_table_name = ghr_pay_calc.l_standard_table_name THEN
                p_prd := 0;
             ELSE
                p_prd := 6;
             END IF;
         END IF;

  ELSIF l_pay_plan = 'GM' THEN

            hr_utility.set_location('Calculating for GM Plan ..Basic Pay ' || l_proc,25);

            get_basic_pay_SAL894_6step(p_pay_calc_data
                                      ,p_retained_grade
                                      ,'POSITION'
                                      ,l_basic_pay
                                      ,l_PT_eff_start_date
                                      ,l_dummy_number);

            hr_utility.set_location('Calculating for GM Plan ..Locality Pay ' || l_proc,20);

            ghr_pay_calc.get_locality_adj_894_PRDM_GM
                            (p_pay_calc_data     => p_pay_calc_data
                            ,p_retained_grade    => p_retained_grade
                            ,p_new_std_relative_rate => l_new_std_relative_rate
                            ,p_new_adj_basic_pay => l_new_adj_basic_pay
                            ,p_new_locality_adj  => l_locality_adj);


        l_new_std_relative_rate := l_new_std_relative_rate +
                                   ROUND(l_new_std_relative_rate *
                                          (NVL(l_adjustment_percentage,0)/100),0);

        IF l_new_std_relative_rate > l_new_adj_basic_pay THEN
           p_prd := 0;
           l_new_adj_basic_pay := l_new_std_relative_rate;
---------  l_locality_adj      := l_new_adj_basic_pay - l_basic_pay;
        ELSIF  (l_basic_pay > l_new_adj_basic_pay)  AND
           (l_user_table_name <> ghr_pay_calc.l_standard_table_name) THEN
               p_prd := 6;
               l_new_adj_basic_pay := l_basic_pay;
-------------  l_locality_adj      := 0;
        END IF;
        p_basic_pay             := nvl(l_basic_pay,0);
        p_PT_eff_start_date     := l_PT_eff_start_date;

  END IF;
  hr_utility.set_location('Leaving .. ' || l_proc,5);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_basic_pay             := NULL;
       p_prd                   := NULL;
       p_PT_eff_start_date     := NULL;

       hr_utility.set_location('Leaving .. ' || l_proc,6);
   RAISE;
END get_basic_pay_SAL894_PRDM;

----------------------------------------------------------------------------------------
--                                                                                    --
--------------------------- <get_basic_pay> --------------------------------------------
--                                                                                    --
----------------------------------------------------------------------------------------
PROCEDURE get_basic_pay (p_pay_calc_data     IN     ghr_pay_calc.pay_calc_in_rec_type
                        ,p_pay_calc_out_data    OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type
                        ,p_retained_grade    IN OUT NOCOPY ghr_pay_calc.retained_grade_rec_type) IS
--
-- This is the main bit of all the pay calc -- how we get the basic pay , everything else kinda
-- falls out from that.
-- Basically if we can calulate it we will otherwise raise ...
-- Please note the return value will be in the given pay basis
l_dummy_date       DATE;
l_dummy_number     NUMBER;
l_pay_plan         VARCHAR2(30);
l_pay_basis        VARCHAR2(30);
l_proc             VARCHAR2(20) := 'get_basic_pay';

--1360547 Fix start
cursor cfws is
select 1 from ghr_pay_plans
where EQUIVALENT_PAY_PLAN = 'FW'
and   PAY_PLAN = l_pay_plan;

--5470182
cursor ces is
select 1 from ghr_pay_plans
where EQUIVALENT_PAY_PLAN = 'ES'
and   PAY_PLAN = l_pay_plan;

l_fws_flag         VARCHAR2(5);
l_es_flag         VARCHAR2(5);
l_retained_grade   ghr_pay_calc.retained_grade_rec_type;
--1360547 Fix
l_open_range_basic_pay NUMBER;

l_890_current_adj_basic_pay NUMBER;
BEGIN

  l_retained_grade := p_retained_grade ;
  l_fws_flag := 'FALSE';    ---Bug 1360547
  hr_utility.set_location('Entering ' || l_proc,5);
 -- get retained grade record if there is one, there MUST be one for 'A','B','E','F','U','V'
 -- and maybe one for 'M'
   IF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F','U','V','M') THEN
       p_retained_grade := get_retained_grade_details (p_pay_calc_data.person_id
                                                      ,p_pay_calc_data.effective_date
                                                      ,p_pay_calc_data.pa_request_id);
       l_pay_plan  := p_retained_grade.pay_plan;
       l_pay_basis := p_retained_grade.pay_basis;
       if p_pay_calc_data.noa_code = '740' then
          p_retained_grade.temp_step := NULL;
       end if;
       if p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') AND
          p_retained_grade.temp_step is not null AND
          p_pay_calc_data.noa_code <> '740' then
          l_pay_plan  := p_pay_calc_data.pay_plan;
          l_pay_basis := p_pay_calc_data.pay_basis;
       end if;
   ELSE
       l_pay_plan  := p_pay_calc_data.pay_plan;
       l_pay_basis := p_pay_calc_data.pay_basis;
   END IF;

---Open Pay Range Basic pay assignment from the in to out record.
   if p_pay_calc_data.open_range_out_basic_pay is not null then
      l_open_range_basic_pay := p_pay_calc_data.open_range_out_basic_pay;
      p_pay_calc_out_data.basic_pay := l_open_range_basic_pay;
   end if;
---Open Pay Range Code changes.
--
--1360547 Fix start
--
 for cfws_rec in cfws
 loop
      l_fws_flag := 'TRUE';
 exit;
 end loop;
--1360547 Fix

--5470182 Fix start
--
l_es_flag := 'FALSE';
 for ces_rec in ces
 loop
      l_es_flag := 'TRUE';
 exit;
 end loop;
--5470182 Fix



 -- Can not do pay calcs for dual actions -- 17/DEC/97 Can now the main pay calc
 -- routine should have set the the second noa to null to pass through this!
 --

IF p_pay_calc_data.open_range_out_basic_pay IS NULL THEN
 IF p_pay_calc_data.second_noa_code IS NULL THEN
  -- Must have all the data to be here as the validation has checked it
  IF p_pay_calc_data.pay_basis IN ('PA','PH','BW')
    AND l_pay_basis IN ('PA','PH','BW') THEN
    --
    IF l_pay_plan NOT IN ('SL','ST', 'SR')
      AND SUBSTR(l_pay_plan,1,1) <> 'D' THEN
      --
      IF p_pay_calc_data.noa_family_code IN ('APP','CHG_DUTY_STATION','CONV_APP','EXT_NTE','POS_CHG'
                                          ,'REALIGNMENT','REASSIGNMENT', 'RETURN_TO_DUTY') THEN
        --
        --Bug# 5132113 added pay plan GR
        IF l_pay_plan NOT IN ('GM','GH','FM','GR') THEN
          --
          IF p_pay_calc_data.pay_rate_determinant IN ('0','5','6','7') THEN
            -- This is the easy one! refered to as MAIN_pos in the design doc
            -- all you have to do is a striaght look up on the user table given, using step,pay_plan,and
            -- grade given at the effective date also given
            -- Note: need for any conversion since it must already be in the given pay basis
            ghr_pay_calc.get_pay_table_value(p_pay_calc_data.user_table_id
                                            ,p_pay_calc_data.pay_plan
                                            ,p_pay_calc_data.grade_or_level
                                            ,p_pay_calc_data.step_or_rate
                                            ,p_pay_calc_data.effective_date
                                            ,p_pay_calc_out_data.basic_pay
                                            ,l_dummy_date
                                            ,l_dummy_date);
          ELSIF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') THEN
            get_basic_pay_MAIN_per(p_pay_calc_data
                                  ,p_retained_grade
                                  ,p_pay_calc_out_data.basic_pay
                                  ,l_dummy_date);
          ELSE
            hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
            hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
            raise ghr_pay_calc.unable_to_calculate;
          END IF;
        --
        ELSE
          hr_utility.set_message(8301, 'GHR_38260_NO_CALC_PAY_PLAN');
          hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
          raise ghr_pay_calc.unable_to_calculate;
        END IF;
      ELSIF SUBSTR(p_pay_calc_data.noa_family_code ,1,8) = 'GHR_SAL_' THEN
        -- For salary change family we need to further investigate the noac to determine
        -- how to do pay
        IF p_pay_calc_data.noa_code = '894' THEN
          IF (p_pay_calc_data.effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND
              nvl(p_pay_calc_data.first_action_la_code1,'XXX') <> 'VGR') OR
              p_pay_calc_data.effective_date <  to_date('2007/01/07','YYYY/MM/DD')  THEN
          -- Bug! 658164 Since we were not able to calculate pay for PRD's 2,3,4,J,K,M,R,3,U,V
          -- in Appointment, don't attempt to do it in 894!!
          -- How to calculate for this NOAC basically depends on Pay Plan AND PRD:
          --Bug# 5132113 added pay plan GP
            IF    (    l_pay_plan IN ('GS','GL','GG','IE','GP')
                 AND p_pay_calc_data.pay_rate_determinant IN ('0','6') )
             OR (    (l_pay_plan IN ('EX') or l_fws_flag = 'TRUE')
                 AND p_pay_calc_data.pay_rate_determinant IN ('0') )
             OR (    l_pay_plan IN ('ES','EP','CA','FO','FP','FE','AL','AA')
                 AND p_pay_calc_data.pay_rate_determinant IN ('0','6') )
             OR  l_pay_plan IN ('IG') THEN --Bug# 7557159
            --
            -- This is what we refer to as MAIN_pos
            --
            ghr_pay_calc.get_pay_table_value(p_pay_calc_data.user_table_id
                                            ,p_pay_calc_data.pay_plan
                                            ,p_pay_calc_data.grade_or_level
                                            ,p_pay_calc_data.step_or_rate
                                            ,p_pay_calc_data.effective_date
                                            ,p_pay_calc_out_data.basic_pay
                                            ,p_pay_calc_out_data.PT_eff_start_date
                                            ,l_dummy_date);
            --
          ELSIF  (    (l_pay_plan IN ('GS','GL','GG','ES','EP','CA','FO','FP','FE','AL','AA','IE')
                     or l_fws_flag = 'TRUE')
                 AND p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') )  THEN
            --
            get_basic_pay_MAIN_per(p_pay_calc_data
                                  ,p_retained_grade
                                  ,p_pay_calc_out_data.basic_pay
                                  ,p_pay_calc_out_data.PT_eff_start_date);
            --
          ELSIF (    l_pay_plan IN ('GM','GH','GR')
                 AND p_pay_calc_data.pay_rate_determinant IN ('0','6') ) THEN
            --
            get_basic_pay_SAL894_6step(p_pay_calc_data
                                      ,p_retained_grade
                                      ,'POSITION'
                                      ,p_pay_calc_out_data.basic_pay
                                      ,p_pay_calc_out_data.PT_eff_start_date
                                      ,l_dummy_number);
            --
          ELSIF (    l_pay_plan IN ('GM','GH')
                 AND p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') ) THEN
            get_basic_pay_SAL894_6step(p_pay_calc_data
                                      ,p_retained_grade
                                      ,'PERSON'
                                      ,p_pay_calc_out_data.basic_pay
                                      ,p_pay_calc_out_data.PT_eff_start_date
                                      ,l_dummy_number);
            --
          ELSIF (    (l_pay_plan IN ('GS','GL','GM','GG','GH','ES','EP','FO','FP','FE','IE','AL','AA','CA')
                      or l_fws_flag = 'TRUE')
                 AND p_pay_calc_data.pay_rate_determinant IN ('J','K','R','3','S') ) THEN
            get_basic_pay_SAL894_50(p_pay_calc_data
                                   ,p_retained_grade
                                   ,'POSITION'
                                   ,p_pay_calc_out_data.basic_pay
                                   ,p_pay_calc_out_data.out_step_or_rate
                                   ,p_pay_calc_out_data.out_pay_rate_determinant
                                   ,p_pay_calc_out_data.PT_eff_start_date);
            --
          ELSIF (    (l_pay_plan IN ('GS','GL','GM','GG','GH','ES','EP','FO','FP','FE','IE','AL','AA','CA')
                      or l_fws_flag = 'TRUE')
                 AND p_pay_calc_data.pay_rate_determinant IN ('U','V') ) THEN
            get_basic_pay_SAL894_50(p_pay_calc_data
                                   ,p_retained_grade
                                   ,'PERSON'
                                   ,p_pay_calc_out_data.basic_pay
                                   ,p_pay_calc_out_data.out_step_or_rate
                                   ,p_pay_calc_out_data.out_pay_rate_determinant
                                   ,p_pay_calc_out_data.PT_eff_start_date);

          ELSIF (    l_pay_plan IN ('GS','GL','GM','GG','GH')
                 AND p_pay_calc_data.pay_rate_determinant IN ('2','4') ) THEN
            get_basic_pay_SAL894_100(p_pay_calc_data
                                    ,p_pay_calc_out_data.basic_pay
                                    ,p_pay_calc_out_data.PT_eff_start_date);
                                                                                          --AVR
          ELSIF (    l_pay_plan IN ('GS','GL','GM')
                 AND p_pay_calc_data.pay_rate_determinant = 'M' )  THEN

                  hr_utility.set_location('Calling ..SAL894_PRDM..  ' || l_proc,15);
                 get_basic_pay_SAL894_PRDM (p_pay_calc_data
                                           ,p_retained_grade
                                           ,p_pay_calc_out_data.basic_pay
                                           ,p_pay_calc_out_data.out_pay_rate_determinant
                                           ,p_pay_calc_out_data.PT_eff_start_date );
                  hr_utility.set_location('Called  ..SAL894_PRDM..  ' || l_proc,25);

                                                                                          --AVR


          --Begin Bug# 7557159
          ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
            hr_utility.set_message(8301, 'GHR_38520_PRD_D');
            raise ghr_pay_calc.open_pay_range_mesg;
          --End Bug# 7557159
          ELSE
            hr_utility.set_message(8301, 'GHR_38391_NO_CALC_PAY_PLAN_PRD');
            hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
            hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
            raise ghr_pay_calc.unable_to_calculate;
          END IF;
          --
          ELSIF (p_pay_calc_data.effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND
                 p_pay_calc_data.first_action_la_code1 = 'VGR' ) THEN
              ---GPPA Update 46 894 NOAC will behave like 895 with VGR after 7-JAN-2007 onwards.
                p_pay_calc_out_data.basic_pay := p_pay_calc_data.current_basic_pay;
         END IF;
        ELSIF p_pay_calc_data.noa_code = '895' THEN
          -- Easy this one I like this, no change in basic pay!!
          p_pay_calc_out_data.basic_pay := p_pay_calc_data.current_basic_pay;
          --

          --Bug# 5132113 added pay plan GR
        ELSIF l_pay_plan NOT IN ('GM','GH','GR') THEN
          IF p_pay_calc_data.noa_code = '891' AND
			 p_pay_calc_data.effective_date < to_date('2007/01/07','YYYY/MM/DD')THEN --Bug# 5482191
            hr_utility.set_message(8301, 'GHR_38248_INV_PAY_PLAN_891');
            hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
            raise ghr_pay_calc.pay_calc_message;
          --
          ELSIF p_pay_calc_data.noa_code IN ('867','892','893') THEN
            --
            IF p_pay_calc_data.pay_rate_determinant IN ('0','6','M') THEN
              get_basic_pay_SALWGI_pos(p_pay_calc_data
                                      ,p_pay_calc_out_data.basic_pay
                                      ,p_pay_calc_out_data.out_step_or_rate);
            ELSIF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') THEN
              get_basic_pay_SALWGI_per(p_pay_calc_data
                                      ,p_retained_grade
                                      ,p_pay_calc_out_data.basic_pay
                                      ,p_pay_calc_out_data.out_step_or_rate);
                --Begin Bug# 7557159
            ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
                hr_utility.set_message(8301, 'GHR_38520_PRD_D');
                raise ghr_pay_calc.open_pay_range_mesg;
                --End Bug# 7557159
            ELSE
              hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
              hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
              raise ghr_pay_calc.unable_to_calculate;
            END IF;

          ELSIF (p_pay_calc_data.noa_code IN ('890') AND (l_fws_flag = 'TRUE' or l_es_flag = 'TRUE')) THEN
            --
            IF p_pay_calc_data.pay_rate_determinant IN ('0','6') THEN
         	--5470182 added NOA code '890' mass salary actions for 6step calculation
              IF l_es_flag = 'TRUE' THEN

           	 get_basic_pay_SAL890_6step(p_pay_calc_data     =>p_pay_calc_data
                                           ,p_retained_grade    =>p_retained_grade
                                           ,p_pay_table_data    =>'POSITION'
                                           ,p_basic_pay         =>p_pay_calc_out_data.basic_pay
				           );

             ELSE
---- Bug 5913318
---- At this stage when a mixed pay  basis condition araises no variable for from pay basis to convert the
---- current_basic_pay. So evolving a hard coded logic below - Not correct but due to time constraint...

     --BUG 6211029 Modified the basic pay to Adjusted Basic Pay and added  p_pay_calc_data.step_or_rate to the
     -- call of  get_890_pay_table_value

     --BUG 6211029 removed the below call to get_890_pay_table_value as no need of defaulting the step or rate
     -- need to be calculated based on the entered step or rate

          /*     IF p_pay_calc_data.pay_basis = 'PH' AND p_pay_calc_data.current_adj_basic_pay > 100 THEN
                    l_890_current_adj_basic_pay   := ghr_pay_calc.convert_amount(p_pay_calc_data.current_adj_basic_pay ,'PA','PH');
                 ELSE
                    l_890_current_adj_basic_pay   := p_pay_calc_data.current_adj_basic_pay;
                 END IF;


                 get_890_pay_table_value(p_pay_calc_data.user_table_id
                          ,p_pay_calc_data.pay_plan
                          ,p_pay_calc_data.grade_or_level
                          ,p_pay_calc_data.effective_date
                          ,nvl(l_890_current_adj_basic_pay, p_pay_calc_data.current_adj_basic_pay)
			  ,p_pay_calc_data.step_or_rate
                          ,p_pay_calc_out_data.out_step_or_rate
                          ,p_pay_calc_out_data.basic_pay
                          ,l_dummy_date
                          ,l_dummy_date);    */

              ghr_pay_calc.get_pay_table_value(p_pay_calc_data.user_table_id
                                              ,p_pay_calc_data.pay_plan
                                              ,p_pay_calc_data.grade_or_level
                                              ,p_pay_calc_data.step_or_rate
                                              ,p_pay_calc_data.effective_date
                                              ,p_pay_calc_out_data.basic_pay
                                              ,l_dummy_date
                                              ,l_dummy_date);


	     END IF;
            ELSIF p_pay_calc_data.pay_rate_determinant IN ('J','K','R','3','S')  THEN
                  ghr_pay_calc.get_pay_table_value (p_user_table_id     => p_pay_calc_data.user_table_id
                                                   ,p_pay_plan          => p_pay_calc_data.pay_plan
                                                   ,p_grade_or_level    => p_pay_calc_data.grade_or_level
                                                   ,p_step_or_rate      => '05'
                                                   ,p_effective_date    => p_pay_calc_data.effective_date
                                                   ,p_PT_value          => p_pay_calc_out_data.basic_pay
                                                   ,p_PT_eff_start_date => l_dummy_date
                                                   ,p_PT_eff_end_date   => l_dummy_date);
                   p_pay_calc_out_data.out_step_or_rate := '05';
                   p_pay_calc_out_data.out_pay_rate_determinant := '0';
            ELSIF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') THEN
              get_basic_pay_MAIN_per(p_pay_calc_data
                                    ,p_retained_grade
                                    ,p_pay_calc_out_data.basic_pay
                                    ,l_dummy_date);
              --
            --Begin Bug# 7557159
            ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
                hr_utility.set_message(8301, 'GHR_38520_PRD_D');
                raise ghr_pay_calc.open_pay_range_mesg;
              --End Bug# 7557159
            ELSE
              hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
              hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
              raise ghr_pay_calc.unable_to_calculate;
            END IF;

          ELSE -- All other NoaC's for the salary change family (not GM,GH)

		    IF p_pay_calc_data.pay_rate_determinant IN ('0','6') THEN
              -- This is the easy one! refered to as MAIN_pos in the design doc
              -- all you have to do is a striaght look up on the user table given, using step,pay_plan,and
              -- grade given at the effective date also given
              -- Note: need for any conversion since it must already be in the given pay basis
              ghr_pay_calc.get_pay_table_value(p_pay_calc_data.user_table_id
                                              ,p_pay_calc_data.pay_plan
                                              ,p_pay_calc_data.grade_or_level
                                              ,p_pay_calc_data.step_or_rate
                                              ,p_pay_calc_data.effective_date
                                              ,p_pay_calc_out_data.basic_pay
                                              ,l_dummy_date
                                              ,l_dummy_date);
            ELSIF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') THEN
              get_basic_pay_MAIN_per(p_pay_calc_data
                                    ,p_retained_grade
                                    ,p_pay_calc_out_data.basic_pay
                                    ,l_dummy_date);
              --
            --Begin Bug# 7557159
            ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
                hr_utility.set_message(8301, 'GHR_38520_PRD_D');
                raise ghr_pay_calc.open_pay_range_mesg;
                --End Bug# 7557159
            ELSE
              hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
              hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
              raise ghr_pay_calc.unable_to_calculate;
            END IF;

	    --Pradeep commented for Title 38 Changes
	    -- IF NOAC = 850 or 855 open up pay fields as well as doing the calc:
            /*
            IF p_pay_calc_data.noa_code IN ('850','855') THEN
              p_pay_calc_out_data.open_pay_fields := TRUE;
            END IF;
            */
            --
          --
          END IF; -- end of noac check inside salary change family
          --
        ELSE -- Not 894, not 895 and must be GM, GH pay plans
          --
        --Bug# 5132113 added pay plan GR condition
       /*IF l_pay_plan in('GR') THEN
                hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
                      hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
                      raise ghr_pay_calc.unable_to_calculate;
	  ELS*/ --Bug# 6342011 Commented
        IF p_pay_calc_data.noa_code IN ('891','892') THEN
            IF p_pay_calc_data.pay_rate_determinant IN ('0','6') THEN
              get_basic_pay_SAL891_pos(p_pay_calc_data
                                      ,p_pay_calc_out_data.basic_pay
                                      ,p_pay_calc_out_data.out_step_or_rate);
            ELSIF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') THEN
              get_basic_pay_SAL891_per(p_pay_calc_data
                                      ,p_retained_grade
                                      ,p_pay_calc_out_data.basic_pay
                                      ,p_pay_calc_out_data.out_step_or_rate);
            --Begin Bug# 7557159
            ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
                hr_utility.set_message(8301, 'GHR_38520_PRD_D');
                raise ghr_pay_calc.open_pay_range_mesg;
                --End Bug# 7557159
            ELSE
              hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
              hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
              raise ghr_pay_calc.unable_to_calculate;
            END IF;
		  --Begin Bug 5661441 AFHR change

		  ELSIF  p_pay_calc_data.noa_code IN ('893') THEN
			IF p_pay_calc_data.effective_date < to_date('2007/01/07','YYYY/MM/DD')THEN
				hr_utility.set_message(8301, 'GHR_INV_PAY_PLAN_893');
				hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
				hr_utility.set_message_token('NOAC',p_pay_calc_data.noa_code);
				raise ghr_pay_calc.pay_calc_message;
			ELSE
				IF p_pay_calc_data.pay_rate_determinant IN ('0','6') THEN
				  get_basic_pay_SAL891_pos(p_pay_calc_data
										  ,p_pay_calc_out_data.basic_pay
										  ,p_pay_calc_out_data.out_step_or_rate);
				ELSIF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') THEN
				  get_basic_pay_SAL891_per(p_pay_calc_data
										  ,p_retained_grade
										  ,p_pay_calc_out_data.basic_pay
										  ,p_pay_calc_out_data.out_step_or_rate);
				--Begin Bug# 7557159
                ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
                    hr_utility.set_message(8301, 'GHR_38520_PRD_D');
                    raise ghr_pay_calc.open_pay_range_mesg;
                    --End Bug# 7557159
                ELSE
				  hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
				  hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
				  raise ghr_pay_calc.unable_to_calculate;
				END IF;
			END IF;

		  --end Bug 5661441 AFHR change
          ELSIF p_pay_calc_data.noa_code IN ('867') THEN --AFHR change 893 removed
            hr_utility.set_message(8301, 'GHR_INV_PAY_PLAN_893');
            hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
            hr_utility.set_message_token('NOAC',p_pay_calc_data.noa_code);
            raise ghr_pay_calc.pay_calc_message;
          --
            --Begin Bug# 7557159
          ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
            hr_utility.set_message(8301, 'GHR_38520_PRD_D');
            raise ghr_pay_calc.open_pay_range_mesg;
            --End Bug# 7557159
          ELSE
            hr_utility.set_message(8301, 'GHR_38260_NO_CALC_PAY_PLAN');
            hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
            raise ghr_pay_calc.unable_to_calculate;
          END IF;
          --
        END IF;
      --Begin Bug# 7557159
      ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
        hr_utility.set_message(8301, 'GHR_38520_PRD_D');
        raise ghr_pay_calc.open_pay_range_mesg;
        --End Bug# 7557159
      ELSE
        hr_utility.set_message(8301, 'GHR_38261_NO_CALC_FAMILY');
        hr_utility.set_message_token('FAMILY',p_pay_calc_data.noa_family_code);
        raise ghr_pay_calc.unable_to_calculate;
      END IF;
      --
    --Begin Bug# 7557159
    ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
        hr_utility.set_message(8301, 'GHR_38520_PRD_D');
        raise ghr_pay_calc.open_pay_range_mesg;
        --End Bug# 7557159
    ELSE
      hr_utility.set_message(8301, 'GHR_38260_NO_CALC_PAY_PLAN');
      hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
      raise ghr_pay_calc.unable_to_calculate;
    END IF;
  --Begin Bug# 7557159
  ELSIF p_pay_calc_data.pay_rate_determinant = 'D' THEN
    hr_utility.set_message(8301, 'GHR_38520_PRD_D');
    raise ghr_pay_calc.open_pay_range_mesg;
    --End Bug# 7557159
  ELSE
    hr_utility.set_message(8301, 'GHR_38262_NO_CALC_PAY_BASIS');
    -- It could be either the position pay basis or the retained pay basis as to why we couldn't
    -- calculate
    IF p_pay_calc_data.pay_basis NOT IN ('PA','PH','BW') THEN
      hr_utility.set_message_token('PAY_BASIS',
                                    ghr_pa_requests_pkg.get_lookup_meaning(800,'GHR_US_PAY_BASIS'
                                                                          ,p_pay_calc_data.pay_basis));
    ELSE
      hr_utility.set_message_token('PAY_BASIS',
                                    ghr_pa_requests_pkg.get_lookup_meaning(800,'GHR_US_PAY_BASIS'
                                                                          ,l_pay_basis));
    END IF;
    raise ghr_pay_calc.unable_to_calculate;
  END IF;
 ELSE
   hr_utility.set_message(8301, 'GHR_38263_NO_CALC_DUAL_ACTION');
   raise ghr_pay_calc.unable_to_calculate;
 END IF;
END IF;

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_pay_calc_out_data  := NULL;
       p_retained_grade     := l_retained_grade;

   RAISE;
  hr_utility.set_location('Leaving ' || l_proc,8);
END get_basic_pay;

-- Bug#5114467 Calling proc for Calculating basic pay, locality rate and
-- adjusted basic pay for employee in 'GM' pay plan and NOA 894 AC

PROCEDURE get_894_GM_sp_basic_pay(p_grade_or_level          IN  VARCHAR2
                                 ,p_effective_date          IN  DATE
                                 ,p_user_table_id           IN  pay_user_tables.user_table_id%TYPE
                                 ,p_default_table_id        IN  NUMBER
                                 ,p_curr_basic_pay          IN  NUMBER
                                 ,p_duty_station_id         IN  ghr_duty_stations_f.duty_station_id%TYPE
                                 ,p_new_basic_pay           OUT NOCOPY NUMBER
				                 ,p_new_adj_basic_pay       OUT NOCOPY NUMBER
                                 ,p_new_locality_adj        OUT NOCOPY NUMBER
                                 ,p_new_special_rate        OUT NOCOPY NUMBER
				                 ) IS

l_pay_plan                VARCHAR2(30);
l_grade_or_level          VARCHAR2(60);
l_PT_eff_start_date       DATE;
l_eff_start_date          DATE;
l_eff_end_date            DATE;
--
l_old_basic_pay           NUMBER;
l_min_old_basic_pay       NUMBER;
l_max_old_basic_pay       NUMBER;
--
l_new_basic_pay           NUMBER;
l_cur_basic_pay           NUMBER;
l_min_cur_basic_pay       NUMBER;
l_max_cur_basic_pay       NUMBER;
l_min_sr_basic_pay        NUMBER;
l_max_sr_basic_pay        NUMBER;

l_new_locality_adj        NUMBER;
l_new_adj_basic_pay       NUMBER;

l_temp_basic_pay          NUMBER;
l_temp2_basic_pay         NUMBER;
l_new_special_rate        NUMBER;

l_new_locality_rate       NUMBER;
l_loc_amnt_or_supp_rate   NUMBER;

l_new_loc_perc_factor     NUMBER;
l_user_table_id           NUMBER;
l_dummy_step              NUMBER;
l_grade                   NUMBER;

l_default_table_id        NUMBER;
l_duty_station_id         ghr_duty_stations_f.duty_station_id%TYPE;

BEGIN
    l_grade_or_level := p_grade_or_level;
    l_PT_eff_start_date := p_effective_date;
    l_pay_plan := 'GS';
    l_default_table_id := p_default_table_id;
    l_user_table_id := p_user_table_id;
    l_old_basic_pay := p_curr_basic_pay;
    l_duty_station_id := p_duty_station_id;

    -- Start ->> Calculation Of New Basic Pay
	get_min_pay_table_value(l_default_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date - 1
                         ,l_dummy_step
                         ,l_min_old_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);

	 get_max_pay_table_value(l_default_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date - 1
                         ,l_dummy_step
                         ,l_max_old_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);

	l_temp_basic_pay := l_old_basic_pay - l_min_old_basic_pay ;
    l_temp2_basic_pay := TRUNC( (l_temp_basic_pay/(l_max_old_basic_pay - l_min_old_basic_pay)),7);

    get_min_pay_table_value(l_default_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_min_cur_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);

	get_max_pay_table_value(l_default_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_max_cur_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);

    l_new_basic_pay := l_min_cur_basic_pay + ROUND((l_temp2_basic_pay * (l_max_cur_basic_pay - l_min_cur_basic_pay)),0);
	-- End ->> Calculation Of New Basic Pay

	-- Start ->> Calculation of Adjusted Basic Pay
    l_new_loc_perc_factor       := (NVL(ghr_pay_calc.get_lpa_percentage(l_duty_station_id
									                                   ,l_PT_eff_start_date
 	            						                               )
                                                                       ,0
                                       )
                                   )/100;
    l_new_locality_adj  := ROUND((l_new_basic_pay * l_new_loc_perc_factor),0);
	l_new_locality_rate := l_new_basic_pay + l_new_locality_adj;
    -- End ->> Calculation of Adjusted Basic Pay

    -- Start ->> Calculation of special Rate amount

    get_min_pay_table_value(l_user_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_min_sr_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);

	get_max_pay_table_value(l_user_table_id
                         ,l_pay_plan
                         ,l_grade_or_level
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_max_sr_basic_pay
                         ,l_eff_start_date
                         ,l_eff_end_date);
	l_new_special_rate := l_min_sr_basic_pay + ROUND((l_temp2_basic_pay*(l_max_sr_basic_pay - l_min_sr_basic_pay)),0);
	-- End ->> Calculation of special Rate amount

    -- Start ->> Determining greater of  locality rate and Special rate
    IF l_new_locality_rate > l_new_special_rate THEN
        l_new_adj_basic_pay := l_new_locality_rate;
    ELSE
        l_new_adj_basic_pay := l_new_special_rate;
    END IF;

    l_loc_amnt_or_supp_rate := l_new_adj_basic_pay - l_new_basic_pay;
    -- End ->> Determining greater of  locality rate and Special rate

	-- Assigning the OUT parameters
	p_new_basic_pay     := l_new_basic_pay;
    p_new_adj_basic_pay := l_new_adj_basic_pay;
	p_new_locality_adj  := l_loc_amnt_or_supp_rate;
    p_new_special_rate  := l_new_special_rate;


END get_894_GM_sp_basic_pay;


-- Bug#5114467 Calling proc for Calculating basic pay, locality rate and
-- adjusted basic pay for WGI employee in 'GM' pay plan AC

PROCEDURE get_wgi_GM_sp_basic_pay(p_grade_or_level          IN  VARCHAR2
                                 ,p_effective_date          IN  DATE
                                 ,p_user_table_id           IN  pay_user_tables.user_table_id%TYPE
                                 ,p_default_table_id        IN  NUMBER
                                 ,p_curr_basic_pay          IN  NUMBER
                                 ,p_duty_station_id         IN  ghr_duty_stations_f.duty_station_id%TYPE
                                 ,p_new_basic_pay           OUT NOCOPY NUMBER
				                 ,p_new_adj_basic_pay       OUT NOCOPY NUMBER
				                 ,p_new_locality_adj        OUT NOCOPY NUMBER
				                 ) IS

l_pay_plan                VARCHAR2(30);
l_grade_or_level          VARCHAR2(60);
l_PT_eff_start_date       DATE;
l_eff_start_date          DATE;
l_eff_end_date            DATE;
--
l_new_basic_pay           NUMBER;
l_old_basic_pay           NUMBER;
l_min_old_basic_pay       NUMBER;
l_max_old_basic_pay       NUMBER;
--
l_cur_basic_pay           NUMBER;
l_min_sp_basic_pay        NUMBER;
l_max_sp_basic_pay        NUMBER;

l_new_locality_adj        NUMBER;
l_new_adj_basic_pay       NUMBER;

l_temp_basic_pay          NUMBER;
l_temp2_basic_pay         NUMBER;

l_new_locality_rate       NUMBER;
l_loc_amnt_or_supp_rate   NUMBER;
l_new_special_rate        NUMBER;

l_new_loc_perc_factor     NUMBER;
l_user_table_id           NUMBER;
l_dummy_step              NUMBER;
l_grade                   NUMBER;

l_default_table_id        NUMBER;
l_duty_station_id         ghr_duty_stations_f.duty_station_id%TYPE;

BEGIN
--5919700 assigning p_grade_or_level to l_grade_or_level
    l_grade_or_level := p_grade_or_level;
    l_PT_eff_start_date := p_effective_date;
    l_pay_plan := 'GS';
    l_default_table_id := p_default_table_id;
    l_user_table_id := p_user_table_id;
    l_old_basic_pay := p_curr_basic_pay;
    l_duty_station_id := p_duty_station_id;

     -- Start ->> Calculation Of New Basic Pay
	 get_min_pay_table_value(l_default_table_id
                             ,'GS'
                             ,l_grade_or_level
                             ,l_PT_eff_start_date
                             ,l_dummy_step
                             ,l_min_old_basic_pay
                             ,l_eff_start_date
                             ,l_eff_end_date);

     get_max_pay_table_value(l_default_table_id
                             ,'GS'
                             ,l_grade_or_level
                             ,l_PT_eff_start_date
                             ,l_dummy_step
                             ,l_max_old_basic_pay
                             ,l_eff_start_date
                             ,l_eff_end_date);

	 l_new_basic_pay := l_old_basic_pay + (l_max_old_basic_pay - l_min_old_basic_pay)/9;
     -- End ->> Calculation Of New Basic Pay

	 -- Start ->> Calculation of special Rate amount
	 l_new_special_rate := TRUNC(((l_new_basic_pay - l_min_old_basic_pay)/
                                    (l_max_old_basic_pay - l_min_old_basic_pay)
				                   )
				                    , 7
				                  );
	 -- End ->> Calculation of special Rate amount

     -- Start -->> Calculate relative rate in range for the special rate
     get_min_pay_table_value( l_user_table_id
                             ,'GS'
                             ,l_grade_or_level
                             ,l_PT_eff_start_date
                             ,l_dummy_step
                             ,l_min_sp_basic_pay
                             ,l_eff_start_date
                             ,l_eff_end_date);

     get_max_pay_table_value(l_user_table_id
                             ,'GS'
                             ,l_grade_or_level
                             ,l_PT_eff_start_date
                             ,l_dummy_step
                             ,l_max_sp_basic_pay
                             ,l_eff_start_date
                             ,l_eff_end_date);

     l_new_special_rate := l_min_sp_basic_pay + ROUND (((l_max_sp_basic_pay - l_min_sp_basic_pay) * l_new_special_rate),0);
     -- End -->> Calculate relative rate in range for the special rate

     -- Start ->> Calculation of Locality Rate
     l_new_loc_perc_factor       := (NVL(ghr_pay_calc.get_lpa_percentage(l_duty_station_id
									                                   ,l_PT_eff_start_date
 	            						                               )
                                                                       ,0
                                       )
                                   )/100;
     l_new_locality_adj  := ROUND((l_new_basic_pay * l_new_loc_perc_factor),0);
     l_new_locality_rate := l_new_basic_pay + l_new_locality_adj;
     -- End ->> Calculation of Locality Rate

     -- Start ->> Calculation of Adjusted Basic Pay
     IF l_new_special_rate > l_new_locality_rate THEN
         l_new_adj_basic_pay := l_new_special_rate;
     ELSE
         l_new_adj_basic_pay := l_new_locality_rate;
     END IF;
     l_loc_amnt_or_supp_rate := l_new_adj_basic_pay - l_new_basic_pay;
     -- End ->> Calculation of Adjusted Basic Pay

	 -- Assigning the OUT parameters
	 p_new_basic_pay     := l_new_basic_pay;
     p_new_adj_basic_pay := l_new_adj_basic_pay;
	 p_new_locality_adj  := l_loc_amnt_or_supp_rate;

END get_wgi_GM_sp_basic_pay;
--

PROCEDURE get_basic_pay_SAL890_6step(p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                    ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
                                    ,p_pay_table_data    IN  VARCHAR2
                                    ,p_basic_pay         OUT NOCOPY NUMBER
				    ) IS
l_user_table_id      NUMBER;
l_pay_plan           VARCHAR2(30);
l_grade_or_level     VARCHAR2(60);
l_step_or_rate       VARCHAR2(30);
l_pay_basis          VARCHAR2(30);
l_effective_date     DATE;

l_curr_basic_pay      NUMBER;
l_old_rangeval_min    NUMBER;
l_old_rangeval_max    NUMBER;
l_calc_basic_pay      NUMBER;
l_new_rangeval_min    NUMBER;
l_new_rangeval_max    NUMBER;

-- perf cert
l_business_group_id	per_positions.organization_id%TYPE;
l_agency_subele_code	per_position_definitions.segment4%TYPE;
l_org_id		per_positions.organization_id%TYPE;
l_old_non_perfagn_max   NUMBER;
l_new_non_perfagn_max   NUMBER;


stp_1 NUMBER;
stp_2 NUMBER;
stp_3 NUMBER;
stp_4 NUMBER;
stp_5 NUMBER;
l_basic_pay NUMBER;

CURSOR cur_get_pos_org(p_pos_id		per_positions.position_id%TYPE,
		      p_eff_Date ghr_pa_requests.effective_date%TYPE)
IS
SELECT ORGANIZATION_ID FROM HR_POSITIONS_F
WHERE  position_id=p_pos_id
AND    p_eff_date between effective_start_Date and effective_end_date;

BEGIN
  -- First work out what pay table data to use
  --

  IF p_pay_table_data  = 'POSITION' THEN
    l_pay_plan       := p_pay_calc_data.pay_plan;
    l_user_table_id  := p_pay_calc_data.user_table_id;
    l_grade_or_level := p_pay_calc_data.grade_or_level;
    l_pay_basis      := p_pay_calc_data.pay_basis;
  ELSE
    l_pay_plan       := p_retained_grade.pay_plan;
    l_user_table_id  := p_retained_grade.user_table_id;
    l_grade_or_level := p_retained_grade.grade_or_level;
    l_pay_basis      := p_retained_grade.pay_basis;
  END IF;

  l_curr_basic_pay := p_pay_calc_data.current_basic_pay;
  l_effective_date := NVL(p_pay_calc_data.effective_date,TRUNC(sysdate));

  -- Added for Perf certification
  l_business_group_id	 := FND_PROFILE.value('PER_BUSINESS_GROUP_ID');
  FOR cur_get_pos_org_rec IN cur_get_pos_org (p_pay_calc_data.position_id, l_effective_date)
  LOOP
     l_org_id	:=	cur_get_pos_org_rec.organization_id;
  END LOOP;

  --fetching min and max range values on the preceding day of pay adjustment
  ghr_pay_calc.get_open_pay_table_values(p_user_table_id     => l_user_table_id
                                        ,p_pay_plan          => l_pay_plan
                                        ,p_grade_or_level    => l_grade_or_level
                                        ,p_effective_date    => l_effective_date-1
                                        ,p_row_high          => l_old_rangeval_max
                                        ,p_row_low           => l_old_rangeval_min);

  --fetching current min and max range values
  ghr_pay_calc.get_open_pay_table_values(p_user_table_id     => l_user_table_id
                                        ,p_pay_plan          => l_pay_plan
                                        ,p_grade_or_level    => l_grade_or_level
                                        ,p_effective_date    => l_effective_date
                                        ,p_row_high          => l_new_rangeval_max
                                        ,p_row_low           => l_new_rangeval_min);

  -- checking for perf certification of the agency if the agency non certified need to
  -- consider EX03 pay table value as a max value

 -- Bug # 8374810 added to fetch EX-03 value of current and previous years for
 -- non certified agencies

  l_agency_subele_code := ghr_api.get_position_agency_code_pos(
				p_position_id		=> p_pay_calc_data.position_id,
				p_business_group_id	=> l_business_group_id,
				p_effective_date	=> l_effective_date);

  IF NOT(ghr_pay_caps.perf_certified(l_agency_subele_code,l_org_id, l_pay_plan, l_effective_date))  THEN
        l_new_non_perfagn_max := ghr_pay_calc.get_standard_pay_table_value('EX'
  			                                                  ,'03'
					     			          ,'00'
                                                                          ,l_effective_date);
        l_old_non_perfagn_max := ghr_pay_calc.get_standard_pay_table_value('EX'
              	                                                          ,'03'
								          ,'00'
                                                                          ,l_effective_date-1);
        l_new_rangeval_max  :=  l_new_non_perfagn_max;
	l_old_rangeval_max  :=  l_old_non_perfagn_max;
  END IF;

  --Step 1
  stp_1 := l_curr_basic_pay - l_old_rangeval_min;

  --Step 2
  stp_2 := l_old_rangeval_max - l_old_rangeval_min;

  --Step 3
  stp_3 := TRUNC(stp_1/stp_2,7);

  -- Step 4
  stp_4 := l_new_rangeval_max - l_new_rangeval_min;

  --Step 5
  --stp_5 := CEIL(stp_3 * stp_4);
    stp_5 := ROUND(stp_3 * stp_4);

  --Step 6
  l_calc_basic_pay := stp_5 + l_new_rangeval_min;

p_basic_pay := l_calc_basic_pay;

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
       p_basic_pay             := NULL;

   RAISE;

END get_basic_pay_SAL890_6step;

END ghr_pc_basic_pay;

/
