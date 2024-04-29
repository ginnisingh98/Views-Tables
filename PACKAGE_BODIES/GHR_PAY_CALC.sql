--------------------------------------------------------
--  DDL for Package Body GHR_PAY_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAY_CALC" AS
/* $Header: ghpaycal.pkb 120.72.12010000.22 2010/02/22 10:08:13 utokachi ship $ */


FUNCTION get_form_item_name
  RETURN VARCHAR2 IS
BEGIN
  -- Because forms can not directly read this global variable we need
  -- to write just a little function on the server to return the value!!
  RETURN(ghr_pay_calc.form_item_name);
  --
END get_form_item_name;
--
PROCEDURE set_form_item_name(p_value IN VARCHAR2) IS
BEGIN
  ghr_pay_calc.form_item_name := p_value;
  --
END set_form_item_name;

--

FUNCTION get_open_pay_range (p_position_id    IN hr_all_positions_f.position_id%TYPE
                            ,p_person_id      IN per_all_people_f.person_id%type
                            ,p_prd            IN ghr_pa_requests.pay_rate_determinant%type
                            ,p_pa_request_id  IN ghr_pa_requests.pa_request_id%type
                            ,p_effective_date IN date)
RETURN BOOLEAN IS
--
l_pos_ei_data      per_position_extra_info%ROWTYPE;
l_range_or_match   pay_user_tables.range_or_match%type;
l_retained_grade   ghr_pay_calc.retained_grade_rec_type;
l_user_table_id    pay_user_tables.user_table_id%type;
l_proc             varchar2(30) := 'get_open_pay_range';

cursor c_pay_type is
select range_or_match
from   pay_user_tables
where  user_table_id = l_user_table_id;
--
--
BEGIN

 hr_utility.set_location('Entering ...' || l_proc,10);

 IF p_prd IN ('A','B','E','F','U','V') THEN
    begin
         hr_utility.set_location('Retained Grade ...' || l_proc,20);

         l_retained_grade := ghr_pc_basic_pay.get_retained_grade_details (p_person_id
                                                                         ,p_effective_date
                                                                         ,p_pa_request_id);
       IF p_prd IN ('A','B','E','F') AND l_retained_grade.temp_step is not null THEN
              ghr_history_fetch.fetch_positionei(
                p_position_id         => p_position_id
               ,p_information_type    => 'GHR_US_POS_VALID_GRADE'
               ,p_date_effective      => p_effective_date
               ,p_pos_ei_data         => l_pos_ei_data);

               l_user_table_id := l_pos_ei_data.poei_information5;
       ELSE
         l_user_table_id  := l_retained_grade.user_table_id;
         hr_utility.set_location(' Retained user table id ' || to_char(l_user_table_id),22);
       END IF;
    exception
        when others then
          hr_utility.set_location('Retained Exception raised ' || sqlerrm(sqlcode),25);
          hr_utility.set_message(8301,'GHR_38255_MISSING_RETAINED_DET');
          hr_utility.raise_error;
    end;

 ELSE
    hr_utility.set_location('Non Retained Grade ...' || l_proc,30);
    ghr_history_fetch.fetch_positionei(
      p_position_id         => p_position_id
     ,p_information_type    => 'GHR_US_POS_VALID_GRADE'
     ,p_date_effective      => p_effective_date
     ,p_pos_ei_data         => l_pos_ei_data);

     l_user_table_id := l_pos_ei_data.poei_information5;
     hr_utility.set_location('Non  Retained user table id ' || to_char(l_user_table_id),32);

 END IF;
  --
/***
  if l_pos_ei_data.poei_information8 = 'Y' THEN
     RETURN(TRUE);
  else
     RETURN(FALSE);
  end if;
  --
***/

  for c_pay_type_rec in c_pay_type
  loop
  l_range_or_match := c_pay_type_rec.range_or_match;
  exit;
  end loop;

  if l_range_or_match = 'R' THEN
     RETURN(TRUE);
  else
     RETURN(FALSE);
  end if;

END get_open_pay_range;


FUNCTION get_user_table_id (p_position_id    IN hr_all_positions_f.position_id%TYPE
                           ,p_effective_date IN date)
  RETURN NUMBER IS
--
-- Since Position Extra Info now has history use the history packages written to get
-- the user_table_id
l_pos_ei_data   per_position_extra_info%ROWTYPE;
--
--
BEGIN
  ghr_history_fetch.fetch_positionei(
    p_position_id         => p_position_id
   ,p_information_type    => 'GHR_US_POS_VALID_GRADE'
   ,p_date_effective      => p_effective_date
   ,p_pos_ei_data         => l_pos_ei_data);
  --
  RETURN(l_pos_ei_data.poei_information5);
  --
END get_user_table_id;
--
-- Depenending on the user table associated with the position this function will return
-- 0 if it is the 'standard default' table otherwise 6
FUNCTION get_default_prd (p_position_id    IN NUMBER
                         ,p_effective_date IN DATE)
  RETURN VARCHAR2 IS
l_user_table_id      pay_user_tables.user_table_id%TYPE;
l_user_table_name    pay_user_tables.user_table_name%TYPE;
BEGIN
  -- First use the routine already written to go and get the user_table_id for the given position
  l_user_table_id := get_user_table_id (p_position_id
                                       ,NVL(p_effective_date,TRUNC(sysdate)) );
  --
  -- Next get the name of the retrieved user_table_id
  IF l_user_table_id IS NOT NULL THEN
    --
    l_user_table_name := ghr_pay_calc.get_user_table_name(l_user_table_id);
    -- Note: Must have a table name if we have a table_id
    IF l_user_table_name = ghr_pay_calc.l_standard_table_name THEN
      RETURN('0');
    ELSE
      RETURN('6');
    END IF;
  ELSE
    --
    RETURN(null);
    --
  END IF;
  --
END get_default_prd;
--
-- This function returns TRUE if Pay Calc is going to set the step so the form knows to
-- grey it out, this is especially hard to work out after it has been routed!!
FUNCTION pay_calc_sets_step(p_first_noa_code  IN VARCHAR2
                           ,p_second_noa_code IN VARCHAR2
                           ,p_pay_plan        IN VARCHAR2
                           ,p_prd             IN VARCHAR2
                           ,p_pa_request_id   IN NUMBER)
  RETURN BOOLEAN IS
l_first_noa_code     ghr_nature_of_actions.code%TYPE;
l_second_noa_code    ghr_nature_of_actions.code%TYPE;
l_pay_plan           VARCHAR2(30);
l_prd                VARCHAR2(30);
--
l_ghr_pa_request_rec ghr_pa_requests%ROWTYPE;
--
BEGIN
  -- If 'Correction' then use second NOA
  IF p_first_noa_code = '002' THEN
    IF p_pa_request_id IS NULL THEN
      hr_utility.set_message(8301,'GHR_38398_PAY_CALC_NO_PAR_ID');
      raise pay_calc_message;
    END IF;
    ghr_corr_canc_sf52.build_corrected_sf52
                      (p_pa_request_id    => p_pa_request_id
                      ,p_noa_code_correct => p_second_noa_code
                      ,p_sf52_data_result => l_ghr_pa_request_rec);

    l_first_noa_code  := p_second_noa_code;
    l_second_noa_code := null;
    l_pay_plan        := NVL(p_pay_plan ,l_ghr_pa_request_rec.to_pay_plan);
    l_prd             := NVL(p_prd      ,l_ghr_pa_request_rec.pay_rate_determinant);

  ELSE
    l_first_noa_code  := p_first_noa_code;
    l_second_noa_code := p_second_noa_code;
    l_pay_plan        := p_pay_plan;
    l_prd             := p_prd;

  END IF;

  --Pradeep added 850 for Title 38 changes.
  IF     (l_first_noa_code IN  ('891','867','892','893','850')
      AND l_second_noa_code IS NULL)
    OR   (l_first_noa_code IN ('892','893')
      AND l_second_noa_code IN ('892','893') ) THEN
/**** -- don't even bother for 894?
    OR   (l_first_noa_code = '894'
      AND l_pay_plan IN ('GS','GM','GG','GH','ES','FO','FP','FE')
      AND l_prd IN ('J','K','R','3','U','V','S') ) THEN
***/
    --
    RETURN(TRUE);
  ELSE
    RETURN(FALSE);
  END IF;
END;
--

--Bug#5132113 added new parameter p_open_range_out_basic_pay

FUNCTION populate_in_rec_structure
                        (p_person_id                 IN     per_people_f.person_id%TYPE
                        ,p_position_id               IN     hr_all_positions_f.position_id%TYPE
                        ,p_noa_family_code           IN     ghr_families.noa_family_code%TYPE
                        ,p_noa_code                  IN     ghr_nature_of_actions.code%TYPE
                        ,p_second_noa_code           IN     ghr_nature_of_actions.code%TYPE
                        ,p_first_action_la_code1     IN     ghr_pa_requests.first_action_la_code1%TYPE
                        ,p_effective_date            IN     DATE
                        ,p_pay_rate_determinant      IN     VARCHAR2
                        ,p_pay_plan                  IN     VARCHAR2
                        ,p_grade_or_level            IN     VARCHAR2
                        ,p_step_or_rate              IN     VARCHAR2
                        ,p_pay_basis                 IN     VARCHAR2
                        ,p_user_table_id             IN     NUMBER
                        ,p_duty_station_id           IN     NUMBER
                        ,p_auo_premium_pay_indicator IN     VARCHAR2
                        ,p_ap_premium_pay_indicator  IN     VARCHAR2
                        ,p_retention_allowance       IN     NUMBER
                        ,p_to_ret_allow_percentage   IN     NUMBER
                        ,p_supervisory_differential  IN     NUMBER
                        ,p_staffing_differential     IN     NUMBER
                        ,p_current_basic_pay         IN     NUMBER
                        ,p_current_adj_basic_pay     IN     NUMBER
                        ,p_current_step_or_rate      IN     VARCHAR2
                        ,p_pa_request_id             IN     NUMBER
                        ,p_open_range_out_basic_pay  IN     NUMBER
			,p_open_out_locality_adj     IN     NUMBER
			)
  RETURN  ghr_pay_calc.pay_calc_in_rec_type IS

l_populated_rec ghr_pay_calc.pay_calc_in_rec_type;
--
BEGIN
  --
  l_populated_rec.person_id                 := p_person_id;
  l_populated_rec.position_id               := p_position_id;
  l_populated_rec.noa_family_code           := p_noa_family_code;
  l_populated_rec.noa_code                  := p_noa_code;
  l_populated_rec.second_noa_code           := p_second_noa_code;
  l_populated_rec.first_action_la_code1     := p_first_action_la_code1;
  IF p_effective_date IS NULL THEN
    l_populated_rec.effective_date            := TRUNC(sysdate);
  ELSE
    l_populated_rec.effective_date            := p_effective_date;
  END IF;
  l_populated_rec.pay_rate_determinant      := p_pay_rate_determinant;
  l_populated_rec.pay_plan                  := p_pay_plan;
  l_populated_rec.grade_or_level            := p_grade_or_level;
  l_populated_rec.step_or_rate              := p_step_or_rate;
  l_populated_rec.pay_basis                 := p_pay_basis;
  l_populated_rec.user_table_id             := p_user_table_id;
  l_populated_rec.duty_station_id           := p_duty_station_id;
  l_populated_rec.auo_premium_pay_indicator := p_auo_premium_pay_indicator;
  l_populated_rec.ap_premium_pay_indicator  := p_ap_premium_pay_indicator;
  l_populated_rec.retention_allowance       := p_retention_allowance;
  l_populated_rec.to_ret_allow_percentage   := p_to_ret_allow_percentage;
  l_populated_rec.supervisory_differential  := p_supervisory_differential;
  l_populated_rec.staffing_differential     := p_staffing_differential;
  l_populated_rec.current_basic_pay         := p_current_basic_pay;
  l_populated_rec.current_adj_basic_pay     := p_current_adj_basic_pay;
  l_populated_rec.current_step_or_rate      := p_current_step_or_rate;
  l_populated_rec.pa_request_id             := p_pa_request_id;
  l_populated_rec.open_range_out_basic_pay  := p_open_range_out_basic_pay;
  -- Bug#5132113 assigning locality adjustment
  l_populated_rec.open_out_locality_adj     := p_open_out_locality_adj;

  RETURN l_populated_rec;

END;
--
PROCEDURE validate_in_data(p_pay_calc_data IN ghr_pay_calc.pay_calc_in_rec_type) IS
--
CURSOR c_chk_pos IS
  SELECT 1
  FROM   hr_all_positions_f pos
  WHERE  p_pay_calc_data.position_id = pos.position_id
  AND    p_pay_calc_data.effective_date BETWEEN pos.effective_start_date
                                        and     pos.effective_end_date;
l_ret_val BOOLEAN := FALSE;
BEGIN
  -- Must have a person
  IF p_pay_calc_data.person_id IS NULL THEN
    ghr_pay_calc.form_item_name := 'PAR.EMPLOYEE_LAST_NAME';
    hr_utility.set_message(8301,'GHR_38244_PAY_CALC_NO_PER');
    raise pay_calc_message;
  END IF;

  -- Must have a position -- well that is kinda obvious!!!
  IF p_pay_calc_data.position_id IS NULL THEN
    ghr_pay_calc.form_item_name := 'PAR.TO_POSITION_TITLE';
    hr_utility.set_message(8301,'GHR_38016_PAY_CALC_NO_POS');
    raise pay_calc_message;
  END IF;

  -- 774633 Now we have a position id check it is valid at given date
  FOR c_chk_pos_rec IN c_chk_pos LOOP
    l_ret_val := TRUE;
  END LOOP;
  IF NOT l_ret_val THEN
    hr_utility.set_message(8301,'GHR_38640_PAY_CALC_INV_POS');
    raise pay_calc_message;
  END IF;

  -- Must have a family (e.g 'APP', 'SALARY_CHG')
  IF p_pay_calc_data.noa_family_code IS NULL THEN
    hr_utility.set_message(8301,'GHR_38245_PAY_CALC_NO_FAM');
    raise pay_calc_message;
  END IF;

  -- Must have a noa if the family is 'SALARY_CHG'
    IF SUBSTR(p_pay_calc_data.noa_family_code ,1,8) = 'GHR_SAL_'
--  IF p_pay_calc_data.noa_family_code = 'SALARY_CHG'
    AND p_pay_calc_data.noa_code IS NULL THEN
    ghr_pay_calc.form_item_name := 'PAR.FIRST_NOA_CODE';
    hr_utility.set_message(8301,'GHR_38246_PAY_CALC_NO_NOA');
    raise pay_calc_message;
  END IF;

  -- No need to check for effective date since it will already have been
  -- defaulted to sysdate

  -- Must have a pay rate determinant (e.g 0,5,6,7)
  IF p_pay_calc_data.pay_rate_determinant IS NULL THEN
    ghr_pay_calc.form_item_name := 'PAR.PAY_RATE_DETERMINANT';
    hr_utility.set_message(8301,'GHR_38021_PAY_CALC_NO_PRD');
    raise pay_calc_message;
  END IF;

  -- Must have a pay plan (e.g GG,GS) which is associated to the position
  IF p_pay_calc_data.pay_plan IS NULL THEN
    hr_utility.set_message(8301,'GHR_38017_PAY_CALC_NO_PAY_PLAN');
    raise pay_calc_message;
  END IF;

  -- Must have a grade_or_level (e.g 01,02) which is associated to the position
  IF p_pay_calc_data.grade_or_level IS NULL THEN
    hr_utility.set_message(8301,'GHR_38018_PAY_CALC_NO_GRADE');
    raise pay_calc_message;
  END IF;

  -- Must have a step_or_rate (e.g 01,02) which is associated to the position
  IF p_pay_calc_data.step_or_rate IS NULL THEN
    ghr_pay_calc.form_item_name := 'PAR.TO_STEP_OR_RATE';
    hr_utility.set_message(8301,'GHR_38019_PAY_CALC_NO_STEP');
    raise pay_calc_message;
  END IF;

  -- Must have a pay_basis (e.g PA,PH) which is associated to the position
  IF p_pay_calc_data.pay_basis IS NULL THEN
    hr_utility.set_message(8301,'GHR_38020_PAY_CALC_NO_PAY_BAS');
    raise pay_calc_message;
  END IF;

  -- Must have a pay table id (e.g 0000,0013) which is associated to the position
  -- we actually store the unique id of the plan table id which is the user_table_id
  IF p_pay_calc_data.user_table_id IS NULL THEN
    hr_utility.set_message(8301, 'GHR_38175_NO_POS_PLAN_TABLE');
    raise pay_calc_message;
  END IF;

  -- IF NOA CODE = 891
  -- 1) must have a current_basic_pay
  -- 2) must be for a pay plan of GM
  IF p_pay_calc_data.noa_code = '891' THEN
    IF p_pay_calc_data.current_basic_pay IS NULL THEN
      hr_utility.set_message(8301, 'GHR_38247_NO_CUR_BASIC_PAY_891');
      raise pay_calc_message;
    END IF;
  END IF;

  -- For Salary change If NOA CODE = 867, 892, 893
  -- Must have current step or rate for PRD's of 0,6 and M
  -- For PRD of M must also have current_adj_basic_pay
  IF p_pay_calc_data.noa_code IN ('867', '892', '893' ) THEN
    IF p_pay_calc_data.pay_rate_determinant IN ('0','6','M')
      AND p_pay_calc_data.current_step_or_rate IS NULL THEN
      hr_utility.set_message(8301, 'GHR_38249_NO_CUR_STEP');
      raise pay_calc_message;
    END IF;
    IF p_pay_calc_data.pay_rate_determinant = 'M'
      AND p_pay_calc_data.current_adj_basic_pay IS NULL THEN
      hr_utility.set_message(8301, 'GHR_38250_NO_CUR_ADJ_PAY_WGI');
      raise pay_calc_message;
    END IF;
  END IF;

  -- IF NOA CODE = 866 - must have a pa_request_id
  IF p_pay_calc_data.noa_code = '866' THEN
    IF p_pay_calc_data.pa_request_id IS NULL THEN
      hr_utility.set_message(8301, 'GHR_38482_866_NO_PAR_ID');
      raise pay_calc_message;
    END IF;
  END IF;

END validate_in_data;
--
--------------------------- convert_amount> ------------------------------------
--
FUNCTION convert_amount (p_amount        IN NUMBER
                        ,p_in_pay_basis  IN VARCHAR2
                        ,p_out_pay_basis IN VARCHAR2)
  RETURN NUMBER IS
--
-- This function converts a given amount from one pay_basis to another.
-- Currently we only know how to convert the following
--  FROM    TO
--   PA     PH      /2087     - standard rounding to 2dp
--   PA     BW      /2087 *80 - standard rounding to 2dp
--   PH     PA      *2087     - standard rounding to whole number
--   BW     PA      /80 *2087 - standard rounding to whole number
-- Added for TSP
--   PA     PD     /261       - standard rounding to 2dp
--   PA     PM     /12        - standard rounding to 2dp
--   PD     PA     *261       - standard rounding to whole number
--   PM     PA     *12        - standard rounding to whole number
l_conv_amount NUMBER;
BEGIN
  IF p_in_pay_basis = p_out_pay_basis THEN
    RETURN(p_amount);
  --ELSIF p_out_pay_basis = 'PD' THEN
    --RETURN(p_amount);
  --ELSIF p_in_pay_basis = 'PD' THEN
    --RETURN(p_amount);
  ELSIF p_in_pay_basis = 'PA' THEN
    IF p_out_pay_basis = 'PH' THEN
      l_conv_amount := ROUND(p_amount/2087, 2);
      RETURN(l_conv_amount);
    ELSIF p_out_pay_basis = 'BW' THEN
      l_conv_amount := ROUND((p_amount/2087) * 80, 2);
      RETURN(l_conv_amount);
    ELSIF p_out_pay_basis = 'PD' THEN
      l_conv_amount := ROUND(p_amount/261 , 2);
      RETURN(l_conv_amount);
    ELSIF p_out_pay_basis = 'PM' THEN
      l_conv_amount := ROUND(p_amount/12 , 2);
      RETURN(l_conv_amount);
    END IF;
  ELSIF p_in_pay_basis = 'PH' THEN
    IF p_out_pay_basis = 'PA' THEN
      l_conv_amount := ROUND(p_amount*2087, 0);
      RETURN(l_conv_amount);
    END IF;
  ELSIF p_in_pay_basis = 'BW' THEN
    IF p_out_pay_basis = 'PA' THEN
      l_conv_amount := ROUND(p_amount/80 * 2087, 0);
      RETURN(l_conv_amount);
    END IF;
  ELSIF p_in_pay_basis = 'PD' THEN
    IF p_out_pay_basis = 'PA' THEN
      l_conv_amount := ROUND(p_amount * 261, 0);
      RETURN(l_conv_amount);
    END IF;
  ELSIF p_in_pay_basis = 'PM' THEN
    IF p_out_pay_basis = 'PA' THEN
      l_conv_amount := ROUND(p_amount * 12, 0);
      RETURN(l_conv_amount);
    END IF;
  END IF;
  --
  -- If we got here sorry do not know how to convert this amount!!
  --
  hr_utility.set_message(8301, 'GHR_38251_NO_CONVERSION');
  hr_utility.set_message_token('FROM_PAY_BASIS',p_in_pay_basis);
  hr_utility.set_message_token('TO_PAY_BASIS',p_out_pay_basis);
  raise ghr_pay_calc.pay_calc_message;
END;
--
--------------------------- <get_lpa_percentage> ------------------------------------
--
FUNCTION get_lpa_percentage (p_duty_station_id  ghr_duty_stations_f.duty_station_id%TYPE
                            ,p_effective_date   DATE)
  RETURN NUMBER IS

l_ret_val ghr_locality_pay_areas_f.adjustment_percentage%TYPE := NULL;
--
CURSOR cur_lpa IS
  SELECT lpa.adjustment_percentage
  FROM   ghr_locality_pay_areas_f lpa
        ,ghr_duty_stations_f      dst
  WHERE  dst.duty_station_id = p_duty_station_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between dst.effective_start_date and dst.effective_end_date
  AND    dst.locality_pay_area_id = lpa.locality_pay_area_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between lpa.effective_start_date and lpa.effective_end_date;
--
BEGIN
  FOR cur_lpa_rec IN cur_lpa LOOP
    l_ret_val :=  cur_lpa_rec.adjustment_percentage;
  END LOOP;
  --
  RETURN(l_ret_val);
  --
END get_lpa_percentage;
--
--
--------------------------- <get_leo_lpa_percentage> ------------------------------------
--
FUNCTION get_leo_lpa_percentage (p_duty_station_id  ghr_duty_stations_f.duty_station_id%TYPE
                            ,p_effective_date   DATE)
  RETURN NUMBER IS

l_ret_val NUMBER := NULL;
--
CURSOR cur_lpa IS
  SELECT NVL(lpa.leo_adjustment_percentage, lpa.adjustment_percentage) adj_percentage
  FROM   ghr_locality_pay_areas_f lpa
        ,ghr_duty_stations_f      dst
  WHERE  dst.duty_station_id = p_duty_station_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between dst.effective_start_date and dst.effective_end_date
  AND    dst.locality_pay_area_id = lpa.locality_pay_area_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between lpa.effective_start_date and lpa.effective_end_date;
--
CURSOR cur_lpa_geo_null IS
  SELECT lpa.adjustment_percentage adj_percentage
  FROM   ghr_locality_pay_areas_f lpa
        ,ghr_duty_stations_f      dst
  WHERE  dst.duty_station_id = p_duty_station_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between dst.effective_start_date and dst.effective_end_date
  AND    dst.locality_pay_area_id = lpa.locality_pay_area_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between lpa.effective_start_date and lpa.effective_end_date;
--

CURSOR cur_leo_code IS
  SELECT leo_pay_area_code
  FROM   ghr_duty_stations_f
  WHERE  duty_station_id = p_duty_station_id
  AND    NVL(p_effective_date,TRUNC(sysdate))
         between effective_start_date and effective_end_date;

l_leo_pay_area_code ghr_duty_stations_f.leo_pay_area_code%type;

BEGIN
  l_leo_pay_area_code := NULL;
  FOR cur_leo_code_rec IN cur_leo_code LOOP
  l_leo_pay_area_code := cur_leo_code_rec.leo_pay_area_code;
  EXIT;
  END LOOP;

  if l_leo_pay_area_code is not null then
     FOR cur_lpa_rec IN cur_lpa LOOP
     l_ret_val :=  cur_lpa_rec.adj_percentage;
     END LOOP;
  else
     FOR cur_lpa_geo_null_rec IN cur_lpa_geo_null LOOP
       l_ret_val := cur_lpa_geo_null_rec.adj_percentage;
     END LOOP;
  end if;
  --
  RETURN(l_ret_val);
  --
END get_leo_lpa_percentage;
--
--
-- This is just a little function that given a user table_id returns the name.
-- It was originally writen when there was an error on the table it could be used as
-- a token in the error meesage
FUNCTION get_user_table_name (p_user_table_id IN NUMBER)
  RETURN VARCHAR2 IS
--
CURSOR cur_uta IS
  SELECT uta.user_table_name
  FROM   pay_user_tables uta
  WHERE  uta.user_table_id = p_user_table_id;
--
BEGIN
  FOR cur_uta_rec IN cur_uta LOOP
    RETURN(cur_uta_rec.user_table_name );
  END LOOP;

  RETURN('UNKNOWN'); -- Probably need to translate this but we should never
                     -- really be given a user table id that doesn't exist
                     -- Assuming referential integrity has been enforced!!!
END get_user_table_name;
--
PROCEDURE is_retained_ia(
				p_person_id             IN NUMBER,
                p_effective_date        IN DATE,
			    p_retained_pay_plan     IN OUT NOCOPY VARCHAR2,
			    p_retained_grade        IN OUT NOCOPY VARCHAR2,
			    p_retained_step_or_rate IN OUT NOCOPY VARCHAR2,
				p_temp_step IN OUT NOCOPY VARCHAR2,
				p_return_flag OUT NOCOPY BOOLEAN)
IS

CURSOR get_prev_ret_grade(c_person_id NUMBER,c_effective_date DATE) is
SELECT pei_information3 grade,
       pei_information4 step,
       pei_information5 pay_plan,
	   pei_information9 temp_step
FROM per_people_extra_info
where person_id = c_person_id
and   information_type ='GHR_US_RETAINED_GRADE'
and   pei_information_category = 'GHR_US_RETAINED_GRADE'
and   c_effective_date  BETWEEN NVL(fnd_date.canonical_to_date(pei_information1),c_effective_date)
                          AND   NVL(fnd_date.canonical_to_date(pei_information2),c_effective_date);

CURSOR c_get_rpa_details(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
SELECT pa_notification_id, to_step_or_rate
FROM ghr_pa_requests
WHERE pa_request_id = c_pa_request_id;

l_true_or_false BOOLEAN := FALSE;
l_effective_date DATE;

-- Bug 3021003
l_session ghr_history_api.g_session_var_type;
l_pa_notification_id ghr_pa_requests.pa_notification_id%type;
l_to_step_or_rate ghr_pa_requests.to_step_or_rate%type;
l_retro_pa_request_id ghr_pa_requests.pa_request_id%type;
l_ia_effective_date ghr_pa_requests.effective_date%type;
l_ia_retro_first_noa ghr_pa_requests.first_noa_code%type;
l_ia_retro_second_noa ghr_pa_requests.second_noa_code%type;

l_retained_pay_plan VARCHAR2(30);
l_retained_grade    VARCHAR2(30);
l_retained_step_or_rate VARCHAR2(30);
l_retained_grade_rec   ghr_pay_calc.retained_grade_rec_type;
l_temp_step VARCHAR2(30);
BEGIN

l_retained_pay_plan := p_retained_pay_plan;
l_retained_grade  := p_retained_grade;
l_retained_step_or_rate := p_retained_step_or_rate;
l_temp_step := p_temp_step;

 ghr_history_api.get_g_session_var(l_session); -- Bug 3021003
-----------If an Intervening cancellation has been done, Need to take previous Step or rate
 IF l_session.noa_id_correct IS NOT NULL THEN
	-- Get notification id and step from RPA
	hr_utility.set_location('Sun l_session.altered_pa_request_id' || l_session.altered_pa_request_id,10);
	FOR l_get_rpa_details IN c_get_rpa_details(l_session.altered_pa_request_id) LOOP
		l_pa_notification_id := 	l_get_rpa_details.pa_notification_id;
		l_to_step_or_rate := l_get_rpa_details.to_step_or_rate;
	END LOOP;

	IF l_to_step_or_rate = '00' THEN
    --BUG #7216635 added the parameter p_noa_id_correct
		GHR_APPROVED_PA_REQUESTS.determine_ia(
								 p_pa_request_id      => l_session.altered_pa_request_id,
								 p_pa_notification_id => l_pa_notification_id,
								 p_person_id          => p_person_id,
								 p_effective_date     => p_effective_date,
								 p_noa_id_correct => l_session.noa_id_correct,
								 p_retro_pa_request_id => l_retro_pa_request_id,
								 p_retro_eff_date     => l_ia_effective_date,
								 p_retro_first_noa    => l_ia_retro_first_noa,
								 p_retro_second_noa   => l_ia_retro_second_noa);
		hr_utility.set_location('Sun l_ia_retro_first_noa' || l_ia_retro_first_noa,10);
		hr_utility.set_location('Sun l_ia_retro_second_noa' || l_ia_retro_second_noa,10);
		IF l_ia_retro_first_noa = '001' AND l_ia_retro_second_noa IN ('867','892','893','894') THEN
	   		 l_effective_date := p_effective_date - 1;
			 l_retained_grade_rec := ghr_pc_basic_pay.get_retained_grade_details
										 (p_person_id      => p_person_id
										 ,p_effective_date => l_effective_date);
			 IF p_temp_step IS NULL THEN
						 p_retained_pay_plan := l_retained_grade_rec.pay_plan;
						 p_retained_grade := l_retained_grade_rec.grade_or_level;
						 p_retained_step_or_rate := l_retained_grade_rec.step_or_rate;
						 l_true_or_false := TRUE;
			 ELSE
						 p_retained_pay_plan := l_retained_grade_rec.pay_plan;
						 p_retained_grade := l_retained_grade_rec.grade_or_level;
						 p_retained_step_or_rate := l_retained_grade_rec.step_or_rate;
						 p_temp_step := l_retained_grade_rec.temp_step;
						 l_true_or_false := TRUE;
			 END IF;
		END IF; -- IF l_ia_retro_first_noa = '001'
	END IF; -- IF l_to_step_or_rate = '00' THEN
 END IF; -- IF l_session.noa_id_correct IS NOT NULL

 IF l_true_or_false = FALSE THEN
	 l_effective_date := p_effective_date - 1;
	 -- If temp step include temp step also in the condition
	 l_retained_grade_rec := ghr_pc_basic_pay.get_retained_grade_details
										 (p_person_id      => p_person_id
										 ,p_effective_date => l_effective_date);
	 IF p_temp_step IS NULL THEN
			IF p_retained_pay_plan = l_retained_grade_rec.pay_plan AND
			   p_retained_grade = l_retained_grade_rec.grade_or_level AND
			   p_retained_step_or_rate = l_retained_grade_rec.step_or_rate THEN
			   hr_utility.set_location('NAR Inside true',100);
			   l_true_or_false := TRUE;
--				EXIT;
			ELSE
				l_true_or_false := FALSE;
				hr_utility.set_location('NAR Inside false',110);
			END IF;
	 ELSE
			IF p_retained_pay_plan = l_retained_grade_rec.pay_plan AND
			   p_retained_grade = l_retained_grade_rec.grade_or_level AND
			   p_retained_step_or_rate = l_retained_grade_rec.step_or_rate AND
			   p_temp_step = l_retained_grade_rec.temp_step THEN
			   hr_utility.set_location('NAR Inside true',100);
			   l_true_or_false := TRUE;
--				EXIT;
			ELSE
				l_true_or_false := FALSE;
				hr_utility.set_location('NAR Inside false',110);
			END IF;
	END IF;
END IF; -- IF l_true_or_false = FALSE THEN
p_return_flag :=  l_true_or_false;
EXCEPTION
WHEN OTHERS THEN
    hr_utility.set_location('Error '|| sqlerrm,60);
	p_retained_pay_plan := l_retained_pay_plan;
	p_retained_grade := l_retained_grade;
	p_retained_step_or_rate := l_retained_step_or_rate;
	p_temp_step := l_temp_step;
	p_return_flag := FALSE;
END is_retained_ia;
----------------------------- <get_pay_table_value> ------------------------------------------
PROCEDURE get_pay_table_value (p_user_table_id     IN  NUMBER
                             ,p_pay_plan          IN  VARCHAR2
                             ,p_grade_or_level    IN  VARCHAR2
                             ,p_step_or_rate      IN  VARCHAR2
                             ,p_effective_date    IN  DATE
                             ,p_PT_value          OUT NOCOPY NUMBER
                             ,p_PT_eff_start_date OUT NOCOPY DATE
                             ,p_PT_eff_end_date   OUT NOCOPY DATE) IS
--
l_PT_value          NUMBER;
l_PT_eff_start_date DATE;
l_PT_eff_end_date   DATE;
l_record_found      BOOLEAN := FALSE;
--
-- Go and get the basic pay from the given pay table at the given grade or level
-- and step
-- NOTE: column => Step or Rate
--       row    => Pay Plan ||'-'|| Grade or Level
--
CURSOR cur_pay IS
  SELECT cin.value basic_pay
        ,cin.effective_start_date
        ,cin.effective_end_date
  FROM   pay_user_column_instances_f cin
        ,pay_user_rows_f             urw
        ,pay_user_columns            col
  WHERE col.user_table_id = p_user_table_id
  AND   col.user_column_name = p_step_or_rate
  AND   urw.user_table_id = p_user_table_id
  -- Bug# 5132113 getting the value of GS when pay plan is GP
  AND   urw.row_low_range_or_name = decode(p_pay_plan,'GP','GS',p_pay_plan)||'-'||p_grade_or_level
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN urw.effective_start_date AND urw.effective_end_date
  AND   cin.user_row_id = urw.user_row_id
  AND   cin.user_column_id = col.user_column_id
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN cin.effective_start_date AND cin.effective_end_date;
BEGIN
  FOR cur_pay_rec IN cur_pay LOOP
    l_PT_value          := ROUND(cur_pay_rec.basic_pay,2);
    l_PT_eff_start_date := cur_pay_rec.effective_start_date;
    l_PT_eff_end_date   := cur_pay_rec.effective_end_date;
    l_record_found      := TRUE;
    --
    IF l_PT_value IS NULL THEN
    -- Sets to give name of pay table, pay plan, grade, step and date
      hr_utility.set_message(8301,'GHR_38252_NULL_PAY_PLAN_VALUE');
      hr_utility.set_message_token('PAY_TABLE_NAME',get_user_table_name(p_user_table_id) );
      hr_utility.set_message_token('STEP',p_step_or_rate);
      hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
      hr_utility.set_message_token('GRADE',p_grade_or_level);
--    hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
      hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date));
      raise pay_calc_message;
    END IF;
    --
  END LOOP;
  --
  IF NOT l_record_found THEN
    -- Set tokens to give name of pay table, pay plan, grade, step and date
    hr_utility.set_message(8301,'GHR_38253_NO_PAY_PLAN_VALUE');
    hr_utility.set_message_token('PAY_TABLE_NAME',get_user_table_name(p_user_table_id));
    hr_utility.set_message_token('STEP',p_step_or_rate);
    hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
    hr_utility.set_message_token('GRADE',p_grade_or_level);
--  hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
    hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date));
    raise ghr_pay_calc.pay_calc_message;
  ELSE
    p_PT_value          := l_PT_value;
    p_PT_eff_start_date := l_PT_eff_start_date;
    p_PT_eff_end_date   := l_PT_eff_end_date;
  END IF;

 EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
       p_PT_value           := NULL;
       p_PT_eff_start_date  := NULL;
       p_PT_eff_end_date    := NULL;
   RAISE;
  --
END get_pay_table_value;
--
--------------------------- <get_standard_pay_table_value> ----------------------------------
FUNCTION get_standard_pay_table_value (p_pay_plan       IN VARCHAR2
                                ,p_grade_or_level IN VARCHAR2
                                ,p_step_or_rate   IN VARCHAR2
                                ,p_effective_date IN DATE)
  RETURN NUMBER IS
--
l_pay_plan_value NUMBER;
l_record_found   BOOLEAN := FALSE;
--
CURSOR cur_default_pay IS
  SELECT cin.value basic_pay
  FROM   pay_user_column_instances_f cin
        ,pay_user_rows_f             urw
        ,pay_user_columns            col
        ,pay_user_tables             utb
  WHERE utb.user_table_name = ghr_pay_calc.l_standard_table_name
  AND   col.user_table_id = utb.user_table_id
  AND   col.user_column_name = p_step_or_rate
  AND   urw.user_table_id = utb.user_table_id
  AND   urw.row_low_range_or_name = p_pay_plan||'-'||p_grade_or_level
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN urw.effective_start_date AND urw.effective_end_date
  AND   cin.user_row_id = urw.user_row_id
  AND   cin.user_column_id = col.user_column_id
  AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN cin.effective_start_date AND cin.effective_end_date;
BEGIN
  FOR cur_default_pay_rec IN cur_default_pay LOOP
    l_pay_plan_value  := ROUND(cur_default_pay_rec.basic_pay,2);
    l_record_found    := TRUE;
    IF l_pay_plan_value IS NULL THEN
    -- Set tokens to give name of pay table(standard), pay plan, grade, step and date
      hr_utility.set_message(8301, 'GHR_38252_NULL_PAY_PLAN_VALUE');
      hr_utility.set_message_token('PAY_TABLE_NAME',ghr_pay_calc.l_standard_table_name  );
      hr_utility.set_message_token('STEP',p_step_or_rate);
      hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
      hr_utility.set_message_token('GRADE',p_grade_or_level);
--  hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
    hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date));
      raise pay_calc_message;
    END IF;
  END LOOP;
  --
  IF NOT l_record_found THEN
    -- Set tokens to give name of pay table(standard), pay plan, grade, step and date
    hr_utility.set_message(8301, 'GHR_38253_NO_PAY_PLAN_VALUE');
    hr_utility.set_message_token('PAY_TABLE_NAME',ghr_pay_calc.l_standard_table_name);
    hr_utility.set_message_token('STEP',p_step_or_rate);
    hr_utility.set_message_token('PAY_PLAN',p_pay_plan);
    hr_utility.set_message_token('GRADE',p_grade_or_level);
--  hr_utility.set_message_token('EFF_DATE',TO_CHAR(p_effective_date,'DD-MON-YYYY') );
    hr_utility.set_message_token('EFF_DATE',fnd_date.date_to_chardate(p_effective_date));
    raise pay_calc_message;
  ELSE
    RETURN(l_pay_plan_value);
  END IF;
  --
END get_standard_pay_table_value;
--
-- This function is used to determine if the given position is a 'LEO'
-- The definition of a LEO is the 'LEO Position Indicator' on information type 'GHR_US_POS_GRP2'
-- is 1 or 2
-- Returns TRUE if it is a LEO Position
FUNCTION LEO_position (p_prd                    IN VARCHAR2
                      ,p_position_id            IN NUMBER
                      ,p_retained_user_table_id IN NUMBER
                      ,p_duty_station_id        IN ghr_duty_stations_f.duty_station_id%TYPE
                      ,p_effective_date         IN DATE)
  RETURN BOOLEAN IS

l_pay_table         varchar2(4);
l_pos_ei_grp2_data  per_position_extra_info%rowtype;

BEGIN
/***** New LEO Locality Pay calculation.
  -- bug 709492 for retained grade PRD's check the retained user table id
  -- otherwise check the position occupied indicator as before
  IF p_prd IN ('A','B','E','F','U','V') THEN
    -- in the future we should have a leo indicator on the retained grade DDF
    l_pay_table := SUBSTR(get_user_table_name(p_retained_user_table_id),1,4);
    IF l_pay_table = '0491' THEN
      RETURN(TRUE);
    END IF;
  ELSE
******/

    ghr_history_fetch.fetch_positionei(
      p_position_id      => p_position_id,
      p_information_type => 'GHR_US_POS_GRP2',
      p_date_effective   => p_effective_date,
      p_pos_ei_data      => l_pos_ei_grp2_data);

    IF l_pos_ei_grp2_data.position_extra_info_id IS NOT NULL
      AND l_pos_ei_grp2_data.poei_information16 IN ('1','2') THEN
      RETURN(TRUE);
    END IF;

  RETURN (FALSE);

END LEO_position;
--
-- This local procedure gets the default basic pay to do the comparison in the locality pay
FUNCTION get_GM_GH_def_basic_pay(p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type)
  RETURN NUMBER IS

l_std_user_table_id  NUMBER;

l_grade              VARCHAR2(30);
l_PT_eff_start_date  DATE;
l_7dp                NUMBER;

l_std_min            NUMBER;
l_std_max            NUMBER;

l_dummy_step         VARCHAR2(30);
l_dummy_date         DATE;
l_dummy_number       NUMBER;

l_ret_basic_pay      NUMBER;

CURSOR get_std_user_table_id IS
  SELECT utb.user_table_id
  FROM   pay_user_tables  utb
  WHERE utb.user_table_name = ghr_pay_calc.l_standard_table_name;

BEGIN
  -- First get the id of standard pay table for later use
  FOR c_rec IN get_std_user_table_id LOOP
    l_std_user_table_id  := c_rec.user_table_id;
  END LOOP;
  --
  -- Get the 7 dp figure as calculated in the 6 step rule!
  IF p_retained_grade.pay_plan IS NULL THEN
    ghr_pc_basic_pay.get_basic_pay_SAL894_6step(p_pay_calc_data
                                      ,p_retained_grade
                                      ,'POSITION'
                                      ,l_dummy_number
                                      ,l_PT_eff_start_date
                                      ,l_7dp);
    l_grade := p_pay_calc_data.grade_or_level;
  ELSE
    ghr_pc_basic_pay.get_basic_pay_SAL894_6step(p_pay_calc_data
                                      ,p_retained_grade
                                      ,'PERSON'
                                      ,l_dummy_number
                                      ,l_PT_eff_start_date
                                      ,l_7dp);
    l_grade := p_retained_grade.grade_or_level;
  END IF;
  --
  ghr_pc_basic_pay.get_min_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_std_min
                         ,l_dummy_date
                         ,l_dummy_date);

  -- Bug No 711506 for Loaclity Adjustment
  -- l_std_max is being fetched from get_min_pay_table_value. Corrected the same by fetcing
  -- from get_max_pay_table_value
  --
  ghr_pc_basic_pay.get_max_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_std_max
                         ,l_dummy_date
                         ,l_dummy_date);
  --
  l_ret_basic_pay := ROUND ( ((l_std_max - l_std_min) * l_7dp ) + l_std_min     );
  --
  RETURN(l_ret_basic_pay);
END;


--------------------------- <get_locality_adj> ----------------------------------
--------------------------- <get_locality_adj> ----------------------------------
PROCEDURE get_locality_adj (p_pay_calc_data     IN     ghr_pay_calc.pay_calc_in_rec_type
                           ,p_retained_grade    IN     ghr_pay_calc.retained_grade_rec_type
                           ,p_pay_calc_out_data IN OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type) IS
--
l_basic_pay_pa          NUMBER; -- This is the basis_pay based in as a PA format
l_basic_pay_pos         NUMBER;
l_basic_pay_pos_pa      NUMBER;
l_basic_pay_std         NUMBER;
l_dummy_date            DATE;
l_locality_adj          NUMBER;
l_adjustment_percentage ghr_locality_pay_areas_f.adjustment_percentage%TYPE;
l_default_basic_pay     NUMBER;
l_default_adj_basic_pay NUMBER;
l_new_adj_basic_pay     NUMBER;                                                         --AVR
l_grade_or_level        VARCHAR2(60);                                                   --AVR
l_step_or_rate          VARCHAR2(30);                                                   --AVR
l_new_std_relative_rate NUMBER;                                                         --AVR
--
l_pay_plan              VARCHAR2(30);
--
l_proc                  VARCHAR2(30) := 'get_locality_adj';
l_new_step_or_rate      VARCHAR2(30);                                                   --AVR
l_session               ghr_history_api.g_session_var_type;
l_pay_calc_out_data     ghr_pay_calc.pay_calc_out_rec_type;


l_user_table_id         pay_user_tables.user_table_id%type;
l_GM_unadjusted_rate    NUMBER;                                                         --AVR

-- Bug 4740036 Start
l_std_user_table_id		NUMBER;
l_dummy VARCHAR2(1);
l_std_basic_pay NUMBER;
l_std_locality_adj       NUMBER;
l_loc_rate  NUMBER;
CURSOR c_user_table_id(p_user_table_name  VARCHAR2) IS
  SELECT utb.user_table_id
  FROM   pay_user_tables  utb
  WHERE utb.user_table_name = p_user_table_name;
-- Bug 4740036 End

cursor c_pay_tab is
  select 1 from pay_user_tables
  where substr(user_table_name,1,4) in ('999B','999C','999D','999E','999F')
  and user_table_id = l_user_table_id;

l_itpay_table  BOOLEAN := FALSE;

cursor c_pay_tab_essl is
  select 1 from pay_user_tables
  where substr(user_table_name,1,4) = 'ESSL'
  and user_table_id = l_user_table_id;

l_essl_table  BOOLEAN := FALSE;

-- Bug 3021003
l_ret_flag BOOLEAN := FALSE;
l_retained_grade ghr_pay_calc.retained_grade_rec_type;

--Begin Bug# 9156723
l_duty_station_code ghr_duty_stations_f.duty_station_code%TYPE;

CURSOR c_get_wcd_loc IS
  select adjustment_percentage from ghr_locality_pay_areas_f
  where locality_pay_area_code = 'WA'
  AND NVL(p_pay_calc_data.effective_date,TRUNC(sysdate))  between effective_start_date and effective_end_date;

cursor c_fp_fo_duty_stn(p_duty_station_id ghr_duty_stations_f.duty_station_id%TYPE, p_effective_date DATE) is
select duty_station_code from ghr_duty_stations_f
where substr(duty_station_code,1,2) between 'AA' and 'ZZ'
and substr(duty_station_code,2,1)<> 'Q'
and duty_station_id = p_duty_station_id
AND NVL(p_effective_date,TRUNC(sysdate))  between effective_start_date and effective_end_date;
--End Bug# 9156723

BEGIN

 l_pay_calc_out_data := p_pay_calc_out_data ; --NOCOPY Changes
  -- Bug 3021003
  l_retained_grade.pay_plan := p_retained_grade.pay_plan;
  l_retained_grade.grade_or_level := p_retained_grade.grade_or_level;
  l_retained_grade.step_or_rate := p_retained_grade.step_or_rate;
  l_retained_grade.temp_step := p_retained_grade.temp_step;
  -- to cater for PRD 'M' which may or may not have a retained grade record.
  -- if there is a retained grade record use that, otherwise use the position's
  ghr_history_api.get_g_session_var(l_session);

  IF p_retained_grade.pay_plan IS NOT NULL THEN
    l_pay_plan      := p_retained_grade.pay_plan;
    l_user_table_id := p_retained_grade.user_table_id;
    if p_retained_grade.temp_step is not null then
       l_pay_plan := p_pay_calc_data.pay_plan;
       l_user_table_id := p_pay_calc_data.user_table_id;
    end if;
  ELSE
    l_pay_plan := p_pay_calc_data.pay_plan;
    l_user_table_id := p_pay_calc_data.user_table_id;
  END IF;

  for c_pay_tab_rec in c_pay_tab loop
      l_itpay_table := TRUE;
  exit;
  end loop;

  for c_pay_tab_essl_rec in c_pay_tab_essl loop
      l_essl_table := TRUE;
  exit;
  end loop;

                                                                                          --AVR
  IF (l_pay_plan in ('GS','GL','GM') AND p_pay_calc_data.noa_code = '894'
                               AND p_pay_calc_data.pay_rate_determinant = 'M') THEN
     IF p_retained_grade.grade_or_level IS NOT NULL THEN
        l_grade_or_level := p_retained_grade.grade_or_level;
        l_step_or_rate   := p_retained_grade.step_or_rate;
        if p_retained_grade.temp_step is not null then
           l_grade_or_level := p_pay_calc_data.grade_or_level;
           l_step_or_rate   := p_retained_grade.temp_step;
        end if;
     ELSE
        l_grade_or_level := p_pay_calc_data.grade_or_level;
        l_step_or_rate   := p_pay_calc_data.step_or_rate;
     END IF;
  END IF;
                                                                                          --AVR

   -- Pradeep added EE to the if list for the Bug 3604377.
   --Bug# 6342011 added GR
   --Bug# 7557159 added IG
   --Bug# 9156723 added FP,FO
  IF l_pay_plan IN ('AD','AL','ES','EP','GG','GH','GM','GS','GL','IP','IE',
                    'FB','FG','FJ','FM','FX','CA','AA','SL','ST','EE','GR','IG','FP','FO') THEN
    --
                                                                                         --AVR
    IF (l_pay_plan IN ( 'GS','GL','GM')  AND p_pay_calc_data.noa_code = '894'
                          AND p_pay_calc_data.pay_rate_determinant = 'M')  THEN
        IF l_pay_plan = 'GS' THEN

	hr_utility.set_location('In Entering ...'|| l_proc,5);
	hr_utility.set_location('In User_table_id ...'|| to_char(p_pay_calc_data.user_table_id),5);
	hr_utility.set_location('In p_pay_plan ...'|| l_pay_plan,5);
	hr_utility.set_location('In p_grade_or_level ...'|| l_grade_or_level,5);
	hr_utility.set_location('In step_or_rate ...'|| l_step_or_rate,5);
	hr_utility.set_location('In effective_date ...'|| to_char(p_pay_calc_data.effective_date,'DD-MON-YYYY'),5);
	hr_utility.set_location('In new current adj basic pay ...'|| to_char(p_pay_calc_data.current_adj_basic_pay),5);
	hr_utility.set_location('In new basic pay ...'|| to_char(p_pay_calc_out_data.basic_pay),5);
             get_locality_adj_894_PRDM_GS
                             (p_user_table_id  => p_pay_calc_data.user_table_id
                             ,p_pay_plan          => l_pay_plan
                             ,p_grade_or_level    => l_grade_or_level
                             ,p_step_or_rate      => l_step_or_rate
                             ,p_effective_date    => p_pay_calc_data.effective_date
                             ,p_cur_adj_basic_pay => p_pay_calc_data.current_adj_basic_pay
                             ,p_new_basic_pay     => p_pay_calc_out_data.basic_pay
                             ,p_new_adj_basic_pay => l_new_adj_basic_pay
                             ,p_new_locality_adj  => l_locality_adj );

             p_pay_calc_out_data.adj_basic_pay := l_new_adj_basic_pay;
             p_pay_calc_out_data.locality_adj  := l_locality_adj;


        ELSIF l_pay_plan = 'GM' THEN

             get_locality_adj_894_PRDM_GM
                            (p_pay_calc_data         => p_pay_calc_data
                            ,p_retained_grade        => p_retained_grade
                            ,p_new_std_relative_rate => l_new_std_relative_rate
                            ,p_new_adj_basic_pay     => l_new_adj_basic_pay
                            ,p_new_locality_adj      => l_locality_adj);

             p_pay_calc_out_data.adj_basic_pay := l_new_adj_basic_pay;
             p_pay_calc_out_data.locality_adj  := l_locality_adj;

        END IF;

    ELSIF l_pay_plan IN  ('GM','GH') AND l_itpay_table THEN
       IF p_pay_calc_data.noa_code = '894' AND p_pay_calc_data.pay_rate_determinant = '6' THEN
          get_locality_894_itpay
             (p_pay_calc_data      => p_pay_calc_data
             ,p_retained_grade     => p_retained_grade
             ,p_new_basic_pay      => p_pay_calc_out_data.basic_pay
             ,p_GM_unadjusted_rate => l_GM_unadjusted_rate
             ,p_new_adj_basic_pay  => l_new_adj_basic_pay
             ,p_new_locality_adj   => l_locality_adj );

             p_pay_calc_out_data.adj_basic_pay := l_new_adj_basic_pay;
             p_pay_calc_out_data.locality_adj  := l_locality_adj;

       ELSIF p_pay_calc_data.noa_code in ('892','891') AND p_pay_calc_data.pay_rate_determinant = '6' THEN
                get_locality_892_itpay
                    (p_pay_calc_data     => p_pay_calc_data
                    ,p_retained_grade    => p_retained_grade
                    ,p_new_basic_pay     => p_pay_calc_out_data.basic_pay
                    ,p_new_adj_basic_pay => l_new_adj_basic_pay
                    ,p_new_locality_adj  => l_locality_adj );

		--Begin Bug 5661441 AFHR change
		ELSIF p_pay_calc_data.noa_code in ('893') AND p_pay_calc_data.pay_rate_determinant = '6' THEN
			IF p_pay_calc_data.effective_date >= to_date('2007/01/07','YYYY/MM/DD')THEN
				get_locality_892_itpay
					(p_pay_calc_data     => p_pay_calc_data
					,p_retained_grade    => p_retained_grade
					,p_new_basic_pay     => p_pay_calc_out_data.basic_pay
					,p_new_adj_basic_pay => l_new_adj_basic_pay
					,p_new_locality_adj  => l_locality_adj );
			END IF;
		--End Bug 5661441 AFHR change

	   END IF;

    ELSIF l_pay_plan IN  ('ES','EP','FE','IE') AND l_essl_table THEN

          l_locality_adj  := 0;
      --Begin Bug# 9156723
    ELSIF l_pay_plan IN ('FP','FO') THEN
	open c_fp_fo_duty_stn(p_pay_calc_data.duty_station_id,p_pay_calc_data.effective_date);
	fetch c_fp_fo_duty_stn into l_duty_station_code;
	IF c_fp_fo_duty_stn%FOUND THEN
		IF p_pay_calc_data.effective_date BETWEEN TO_DATE('2009/08/16','YYYY/MM/DD')
							AND TO_DATE('2010/01/02','YYYY/MM/DD') THEN
			l_locality_adj  := ROUND( p_pay_calc_out_data.basic_pay * (7.7/100),0);
		ELSIF p_pay_calc_data.effective_date BETWEEN TO_DATE('2010/01/03','YYYY/MM/DD')
							AND TO_DATE('2010/08/14','YYYY/MM/DD') THEN
			l_locality_adj  := ROUND( p_pay_calc_out_data.basic_pay * (8.82/100),0);
		ELSIF p_pay_calc_data.effective_date BETWEEN TO_DATE('2010/08/15','YYYY/MM/DD')
							AND TO_DATE('2011/08/13','YYYY/MM/DD') THEN
			l_locality_adj  := ROUND( p_pay_calc_out_data.basic_pay * (16.52/100),0);
		ELSIF p_pay_calc_data.effective_date BETWEEN TO_DATE('2011/08/14','YYYY/MM/DD')
							AND TO_DATE('2012/01/01','YYYY/MM/DD') THEN
			l_locality_adj  := ROUND( p_pay_calc_out_data.basic_pay * (24.22/100),0);
		ELSIF p_pay_calc_data.effective_date > to_date('2012/01/01','YYYY/MM/DD') THEN
			FOR l_get_wcd_loc IN c_get_wcd_loc LOOP
				l_adjustment_percentage:= l_get_wcd_loc.adjustment_percentage;
			END LOOP;
			l_locality_adj  := ROUND( p_pay_calc_out_data.basic_pay * (nvl(l_adjustment_percentage,0)/100),0);
		ELSE
			l_locality_adj :=  0;
		END IF;
	ELSE
		--Begin Bug# 9380555
		l_adjustment_percentage := NVL(get_leo_lpa_percentage(p_pay_calc_data.duty_station_id
                                                           ,p_pay_calc_data.effective_date),0);
		l_locality_adj  := ROUND( p_pay_calc_out_data.basic_pay * (nvl(l_adjustment_percentage,0)/100),0);
		--End Bug# 9380555
	END IF;
	CLOSE c_fp_fo_duty_stn;
        --End Bug# 9156723
     --Bug# 7557159 added IG
    ELSIF l_pay_plan IN  ('IG') THEN
        l_locality_adj  := 0;
    --Bug 4740036 Start
    --Bug 4740036 Start
    --8320557 From 12 -Apr-2009 locality pay will be 0 for SL ST IP pay plan
    ELSIF l_pay_plan IN ('SL','ST','IP') AND p_pay_calc_data.effective_date >= to_date('2009/04/12','YYYY/MM/DD') THEN
       l_locality_adj  := 0;
    ELSIF ghr_pay_calc.get_user_table_name(l_user_table_id) NOT IN (ghr_pay_calc.l_standard_table_name,ghr_pay_calc.l_spl491_table_name)
                       AND l_pay_plan in ('GG','GS')
                       AND p_pay_calc_data.pay_rate_determinant IN ('6','E','F')
                       AND ghr_pay_calc.LEO_position (l_dummy
                            ,p_pay_calc_data.position_id
                            ,l_dummy
                            ,l_dummy
                            ,p_pay_calc_data.effective_date) THEN
        hr_utility.set_location('AB p_pay_calc_data.pay_rate_determinant ' || p_pay_calc_data.pay_rate_determinant,99);
        FOR c_rec IN c_user_table_id(ghr_pay_calc.l_standard_table_name) LOOP
            l_std_user_table_id  := c_rec.user_table_id;
        END LOOP;
        hr_utility.set_location('AB l_std_user_table_id ' || l_std_user_table_id,99);
        IF p_pay_calc_data.pay_rate_determinant = '6' THEN
            hr_utility.set_location('AB p_pay_calc_data.grade_or_level ' || p_pay_calc_data.grade_or_level,99);
            l_new_step_or_rate := NVL(p_pay_calc_out_data.out_step_or_rate, p_pay_calc_data.step_or_rate);
            hr_utility.set_location('AB l_new_step_or_rate ' || l_new_step_or_rate,99);
            get_pay_table_value(l_std_user_table_id
                                ,l_pay_plan
                                ,p_pay_calc_data.grade_or_level
                                ,l_new_step_or_rate
                                ,p_pay_calc_data.effective_date
                                ,l_std_basic_pay
                                ,l_dummy_date
                                ,l_dummy_date);
        ELSE
            hr_utility.set_location('AB l_retained_grade.grade_or_level ' || l_retained_grade.grade_or_level,99);
            hr_utility.set_location('AB l_retained_grade.step_or_rate ' || l_retained_grade.step_or_rate,99);
            IF p_pay_calc_data.noa_code IN ('867','892','893') THEN
                IF l_session.noa_id_correct is not null then
                    IF l_retained_grade.temp_step is not null then
                        is_retained_ia(p_pay_calc_data.person_id,
                                       p_pay_calc_data.effective_date,
                                       l_retained_grade.pay_plan,
                                       l_retained_grade.grade_or_level,
                                       l_retained_grade.step_or_rate,
                                       l_retained_grade.temp_step,
                                       l_ret_flag);
                        IF l_ret_flag = TRUE THEN
                            l_new_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (p_pay_calc_data.pay_plan
                                                                                     ,l_retained_grade.temp_step);
                        ELSE
                            l_new_step_or_rate := p_retained_grade.temp_step;
                        END IF;
                    ELSE
                        is_retained_ia(p_pay_calc_data.person_id,
                                       p_pay_calc_data.effective_date,
                                       l_retained_grade.pay_plan,
                                       l_retained_grade.grade_or_level,
                                       l_retained_grade.step_or_rate,
                                       l_retained_grade.temp_step,
                                       l_ret_flag);
                        IF l_ret_flag = TRUE THEN
                            l_new_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (p_pay_calc_data.pay_plan
                                                                                     ,l_retained_grade.step_or_rate);
                        ELSE
                            l_new_step_or_rate := l_retained_grade.step_or_rate;
                        END IF;
                    END IF;
                ELSE
                    IF p_retained_grade.temp_step is not null THEN
                        l_new_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (p_pay_calc_data.pay_plan
                                                                          ,p_retained_grade.temp_step);
                    ELSE
                        l_new_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (p_retained_grade.pay_plan
                                                                          ,p_retained_grade.step_or_rate);
                    END IF;
                END IF;
                hr_utility.set_location('AB l_new_step_or_rate ' || l_new_step_or_rate,99);
            ELSE
                IF p_retained_grade.temp_step is not null THEN
                    l_new_step_or_rate := p_retained_grade.temp_step;
                ELSE
                    l_new_step_or_rate := p_retained_grade.step_or_rate;
                END IF;
            END IF;
            get_pay_table_value(l_std_user_table_id
                                ,l_pay_plan
                                ,l_retained_grade.grade_or_level
                                ,l_new_step_or_rate
                                ,p_pay_calc_data.effective_date
                                ,l_std_basic_pay
                                ,l_dummy_date
                                ,l_dummy_date);
        END IF;
        hr_utility.set_location('AB l_std_basic_pay ' || l_std_basic_pay,99);
        l_adjustment_percentage  := ghr_pay_calc.get_leo_lpa_percentage
                                            (p_pay_calc_data.duty_station_id
                                            ,p_pay_calc_data.effective_date);
        hr_utility.set_location('AB l_adjustment_percentage ' || l_adjustment_percentage,99);
        l_std_locality_adj  := ROUND(l_std_basic_pay * (NVL(l_adjustment_percentage,0)/100),0);
        l_loc_rate := l_std_basic_pay + l_std_locality_adj;
        hr_utility.set_location('AB l_std_locality_adj ' || l_std_locality_adj,99);
        hr_utility.set_location('AB l_loc_rate ' || l_loc_rate,99);
        IF p_pay_calc_out_data.basic_pay > l_loc_rate THEN
            l_locality_adj := 0;
            p_pay_calc_out_data.adj_basic_pay := p_pay_calc_out_data.basic_pay;
        ELSE
            p_pay_calc_out_data.adj_basic_pay := l_loc_rate;
            l_locality_adj := l_loc_rate - p_pay_calc_out_data.basic_pay;
        END IF;
        p_pay_calc_out_data.locality_adj := l_locality_adj;
        hr_utility.set_location('AB p_pay_calc_out_data.locality_adj ' || p_pay_calc_out_data.locality_adj,99);
        hr_utility.set_location('AB p_pay_calc_out_data.adj_basic_pay ' || p_pay_calc_out_data.adj_basic_pay,99);

        --Bug 4740036 End

    ELSE

    l_basic_pay_pa := convert_amount(p_pay_calc_out_data.basic_pay
                                    ,p_pay_calc_data.pay_basis
                                    ,'PA');
    --
    IF LEO_position (p_pay_calc_data.pay_rate_determinant
                    ,p_pay_calc_data.position_id
                    ,p_retained_grade.user_table_id
                    ,p_pay_calc_data.duty_station_id
                    ,p_pay_calc_data.effective_date)  OR
             l_pay_plan = 'GL' THEN
      -- as for PRD 0 below except use get_leo_lpa_percentage
      l_adjustment_percentage := NVL(get_leo_lpa_percentage(p_pay_calc_data.duty_station_id
                                                           ,p_pay_calc_data.effective_date),0);
      --
      l_locality_adj  := ROUND(l_basic_pay_pa * (NVL(l_adjustment_percentage,0)/100),0);

    ELSE
      --
       --Bug# 6342011 added GR condition. For GR return copy from locality.
       IF l_pay_plan ='GR' THEN
        l_locality_adj :=p_pay_calc_data.open_out_locality_adj;
      ELSIF p_pay_calc_data.pay_rate_determinant IN ('0','7', 'A','B', '2','4',
                                                  'J','K','R','S','3','U','V','D') THEN --Biug# 7557159
        -- This one is really easy just multiply the basic_pay (converted to pa) by the locality%age
        l_adjustment_percentage := NVL(get_lpa_percentage(p_pay_calc_data.duty_station_id
                                                         ,p_pay_calc_data.effective_date),0);
        --
        l_locality_adj  := ROUND(l_basic_pay_pa * (NVL(l_adjustment_percentage,0)/100),0);
        --
      ELSIF p_pay_calc_data.pay_rate_determinant IN ('5','6','E','F') THEN
        --
        IF p_pay_calc_data.pay_rate_determinant IN ('5','6')  THEN
			IF l_pay_plan NOT IN ('GM','GH') THEN
				--
				-- Sundar 3294560 If Pay plan is 'GG' take from 'GG' else take from GS.
				-- Pay Plan should be either GG or GS, if not in 'GM', 'GH'. If not, then assign
				-- the standard table 'GS'
				IF l_pay_plan NOT IN ('GG','GS') THEN
					l_pay_plan := 'GS';
				END IF; -- IF l_pay_plan NOT IN ('GG','GS')

				l_default_basic_pay     := get_standard_pay_table_value (l_pay_plan
																	   ,p_pay_calc_data.grade_or_level
																	   ,NVL(p_pay_calc_out_data.out_step_or_rate,p_pay_calc_data.step_or_rate)
																	   ,p_pay_calc_data.effective_date);
			-- End Bug 3294560
		  ELSE -- GM,GH
            l_default_basic_pay     := get_GM_GH_def_basic_pay(p_pay_calc_data
                                                              ,p_retained_grade);
            --
          END IF; --  PAY PLAN NOT IN GM,GH
        ELSIF p_pay_calc_data.pay_rate_determinant IN ('E','F')  THEN
          --
          IF l_pay_plan NOT IN ('GM','GH') THEN
            --
            	-- Sundar 3294560 If Pay plan is 'GG' take from 'GG' else take from GS.
				-- Pay Plan should be either GG or GS, if not in 'GM', 'GH'. If not, then 				-- the standard table 'GS'
			   IF l_pay_plan NOT IN ('GG','GS','GL') THEN
					l_pay_plan := 'GS';
			   END IF; -- IF l_pay_plan NOT IN ('GG','GS','GL')

			--- Bug 1953725 Start

            IF p_pay_calc_data.noa_code IN ('867','892','893') THEN
               --Bug 2596425
               if l_session.noa_id_correct is not null then
                  if l_retained_grade.temp_step is not null then
					 -- Bug 3021003 Start
					 is_retained_ia(p_pay_calc_data.person_id,
									p_pay_calc_data.effective_date,
									l_retained_grade.pay_plan,
								   l_retained_grade.grade_or_level,
								   l_retained_grade.step_or_rate,
								   l_retained_grade.temp_step,
								   l_ret_flag);
					 IF l_ret_flag = TRUE then
							 hr_utility.set_location('NAR ret step ' ||l_retained_grade.temp_step,10);
							 hr_utility.set_location('NAR pay plan '||p_pay_calc_data.pay_plan,20);
						 l_new_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (p_pay_calc_data.pay_plan
														  ,l_retained_grade.temp_step);
						 hr_utility.set_location('NAR new step after getting the step ' ||l_new_step_or_rate,10);
						 -- End Bug 3021003
					 ELSE
                     l_new_step_or_rate := p_retained_grade.temp_step;
					 END IF;
                  else
						 -- Bug 3021003
						 is_retained_ia(p_pay_calc_data.person_id,
											   p_pay_calc_data.effective_date,
										   l_retained_grade.pay_plan,
								   l_retained_grade.grade_or_level,
								   l_retained_grade.step_or_rate,
									l_retained_grade.temp_step,
								   l_ret_flag);
						IF l_ret_flag = TRUE then
							 hr_utility.set_location('NAR ret step ' ||l_retained_grade.step_or_rate,10);
							 hr_utility.set_location('NAR pay plan '||p_pay_calc_data.pay_plan,20);
									 l_new_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (p_pay_calc_data.pay_plan
														  ,l_retained_grade.step_or_rate);
							 hr_utility.set_location('NAR new step after getting the step ' ||l_new_step_or_rate,10);
						 ELSE
								 l_new_step_or_rate := l_retained_grade.step_or_rate;
						 END IF; -- IF  is_retained_ia End Bug 3021003
					END IF;  -- if p_retained_grade.temp_step is not null
               else
                  if p_retained_grade.temp_step is not null then

                     l_new_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (p_pay_calc_data.pay_plan
                                                                          ,p_retained_grade.temp_step);
                  else
                     l_new_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (p_retained_grade.pay_plan
                                                                          ,p_retained_grade.step_or_rate);
                  end if;
               end if;


				-- Bug 3294560 Hard coding of 'GS' replaced with l_pay_plan
               IF p_retained_grade.temp_step IS NOT NULL THEN

                  l_default_basic_pay     := get_standard_pay_table_value (l_pay_plan
                                                                       ,p_pay_calc_data.grade_or_level
                                                                       ,l_new_step_or_rate
                                                                       ,p_pay_calc_data.effective_date);
               ELSE
                  l_default_basic_pay     := get_standard_pay_table_value (l_pay_plan
                                                                       ,p_retained_grade.grade_or_level
                                                                       ,l_new_step_or_rate
                                                                       ,p_pay_calc_data.effective_date);
               END IF;
            ELSE
            --- Bug 1953725 End
                if p_retained_grade.temp_step is not null then
                   l_default_basic_pay     := get_standard_pay_table_value (l_pay_plan
                                                                    ,p_pay_calc_data.grade_or_level
                                                                    ,p_retained_grade.temp_step
                                                                    ,p_pay_calc_data.effective_date);
                else
                   l_default_basic_pay     := get_standard_pay_table_value (l_pay_plan
                                                                    ,p_retained_grade.grade_or_level
                                                                    ,p_retained_grade.step_or_rate
                                                                    ,p_pay_calc_data.effective_date);
                end if;
            END IF;
          ELSE
            --
            l_default_basic_pay     := get_GM_GH_def_basic_pay(p_pay_calc_data
                                                              ,p_retained_grade);
            --
          END IF;

        END IF;

        l_adjustment_percentage := get_lpa_percentage(p_pay_calc_data.duty_station_id
                                                     ,p_pay_calc_data.effective_date);
        -- Now do the comparison!
        l_default_adj_basic_pay :=  NVL(l_default_basic_pay,0)
                                    + ROUND(l_default_basic_pay *
                                               (NVL(l_adjustment_percentage,0)/100),0);
        --
        IF l_default_adj_basic_pay > l_basic_pay_pa THEN
          l_locality_adj :=  l_default_adj_basic_pay - l_basic_pay_pa;
        ELSE
          l_locality_adj := 0;
        END IF;
        --
      ELSIF p_pay_calc_data.pay_rate_determinant = 'M' THEN
        IF p_pay_calc_out_data.basic_pay >= p_pay_calc_data.current_adj_basic_pay THEN
          l_locality_adj := 0;
          --
        ELSE
          l_locality_adj := ghr_pay_calc.convert_amount
                           (p_pay_calc_data.current_adj_basic_pay - p_pay_calc_out_data.basic_pay
                           ,p_pay_calc_data.pay_basis
                           ,'PA');
          --
        END IF;

      ELSE
        -- should never have really got here as the basic pay should have stopped us
        -- calculating if we didn't know how to
        hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
        hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
        raise ghr_pay_calc.unable_to_calculate;
      END IF;  -- End of PRD checks
      --
    END IF; -- End of LEO checks
    --
   END IF;  -- End of PRD=M and 894
  ELSE
    -- We do not calculate locality adjustment for other pay plans
    l_locality_adj :=  0;
    --
  END IF;
  --
  -- The above should just set l_locality_adj now set the real out parameter
  --
  p_pay_calc_out_data.locality_adj := l_locality_adj;

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
      p_pay_calc_out_data := l_pay_calc_out_data;
      RAISE;
     --
END get_locality_adj;
--
--------------------------- <get_adj_basic_pay> ----------------------------------
PROCEDURE get_adj_basic_pay (p_pay_calc_data     IN     ghr_pay_calc.pay_calc_in_rec_type
                            ,p_pay_calc_out_data IN OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type) IS

    --
    l_locality_adj_conv NUMBER;
    l_pay_calc_out_data  ghr_pay_calc.pay_calc_out_rec_type;

BEGIN

 l_pay_calc_out_data := p_pay_calc_out_data ; --NOCOPY Changes
  --
  IF p_pay_calc_data.pay_rate_determinant = 'M' THEN
    --
   IF (p_pay_calc_data.pay_plan IN ('GS','GM') AND p_pay_calc_data.noa_code = '894') THEN
     p_pay_calc_out_data.adj_basic_pay := p_pay_calc_out_data.basic_pay +
                                          p_pay_calc_out_data.locality_adj;

    -- Basically M's keep the same adjusted basic pay unless basic pay is higher!
    ELSIF p_pay_calc_out_data.basic_pay >= p_pay_calc_data.current_adj_basic_pay THEN
      p_pay_calc_out_data.locality_adj := 0;
      --
      p_pay_calc_out_data.adj_basic_pay := p_pay_calc_out_data.basic_pay;
      --
    ELSE
      p_pay_calc_out_data.adj_basic_pay := p_pay_calc_data.current_adj_basic_pay;
      --
    END IF;
    --
  ELSE
    -- convert the locality_adj (which is always 'PA')  to the pay_basis of the
    -- basic pay so they can then be added together
    --
    l_locality_adj_conv := ghr_pay_calc.convert_amount(p_pay_calc_out_data.locality_adj
                                                      ,'PA'
                                                      ,p_pay_calc_data.pay_basis);
    --
    p_pay_calc_out_data.adj_basic_pay :=  NVL(p_pay_calc_out_data.basic_pay,0)
                                        + NVL(l_locality_adj_conv,0);
  END IF;

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
      p_pay_calc_out_data := l_pay_calc_out_data;
      RAISE;

END get_adj_basic_pay;

--------------------------- <get_ppi_amount> --------------------------------------
FUNCTION get_ppi_amount (p_ppi_code       IN     VARCHAR2
                        ,p_amount         IN     NUMBER
                        ,p_pay_basis      IN     VARCHAR2)

  RETURN NUMBER IS
-- bug 710122 need to convert amount to PA before doing calc
CURSOR cur_ppi IS
  SELECT ppi.ppi_percentage
  FROM   ghr_premium_pay_indicators ppi
  WHERE  code = p_ppi_code;

l_amount_pa      NUMBER;
l_ppi_percentage NUMBER;
l_ret_val        NUMBER;
BEGIN
  IF p_ppi_code IS NOT NULL THEN
    FOR cur_ppi_rec IN cur_ppi LOOP
      l_ppi_percentage := cur_ppi_rec.ppi_percentage;
    END LOOP;

    -- rounding??
    --
    l_amount_pa := convert_amount(p_amount,p_pay_basis ,'PA');
    l_ret_val := TRUNC(l_amount_pa * NVL(l_ppi_percentage,0) / 100 , 0); --Bug 3067420 changed ROUND -> TRUNC

  ELSE
    l_ret_val := NULL;
  END IF;

  RETURN(l_ret_val);

END get_ppi_amount;

--------------------------- <get_other_pay_amount> --------------------------------
PROCEDURE get_other_pay_amount (p_pay_calc_data     IN ghr_pay_calc.pay_calc_in_rec_type
                               ,p_pay_calc_out_data IN OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type) IS

 l_pay_calc_out_data  ghr_pay_calc.pay_calc_out_rec_type;

BEGIN

    l_pay_calc_out_data := p_pay_calc_out_data ; --NOCOPY Changes

  -- should not need to worry about the pay basis as they are all in the same basis
  -- If ALL the values are null then return null as opposed to 0:
  -- NOTE: these should all be per annum amounts
  IF p_pay_calc_out_data.au_overtime IS NULL
    AND p_pay_calc_out_data.availability_pay IS NULL
    AND p_pay_calc_out_data.retention_allowance IS NULL
    AND p_pay_calc_data.supervisory_differential IS NULL
    AND p_pay_calc_data.staffing_differential IS NULL THEN
    p_pay_calc_out_data.other_pay_amount := NULL;
  ELSE
    p_pay_calc_out_data.other_pay_amount :=  NVL(p_pay_calc_out_data.au_overtime,0)
                                           + NVL(p_pay_calc_out_data.availability_pay,0)
                                           + NVL(p_pay_calc_out_data.retention_allowance,0)
                                           + NVL(p_pay_calc_data.supervisory_differential,0)
                                           + NVL(p_pay_calc_data.staffing_differential,0);
  END IF;
  --

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
      p_pay_calc_out_data := l_pay_calc_out_data ;
      RAISE;
END get_other_pay_amount;

--------------------------- <get_total_salary> ------------------------------------
PROCEDURE get_total_salary (p_pay_calc_out_data IN OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type
                           ,p_pay_basis         IN VARCHAR2) IS

 l_pay_calc_out_data  ghr_pay_calc.pay_calc_out_rec_type;
BEGIN

    l_pay_calc_out_data := p_pay_calc_out_data ; --NOCOPY Changes

	   -- 24-Nov-2003  For Other Pay conversion is not required due to FWS Retention Calc. Changes
       p_pay_calc_out_data.total_salary :=  NVL(p_pay_calc_out_data.adj_basic_pay,0)
                                     + NVL(p_pay_calc_out_data.other_pay_amount,0);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
      p_pay_calc_out_data := l_pay_calc_out_data ;
   RAISE;

END get_total_salary;

PROCEDURE main_pay_calc (p_person_id                 IN     per_people_f.person_id%TYPE
                        ,p_position_id               IN     hr_all_positions_f.position_id%TYPE
                        ,p_noa_family_code           IN     ghr_families.noa_family_code%TYPE
                        ,p_noa_code                  IN     ghr_nature_of_actions.code%TYPE
                        ,p_second_noa_code           IN     ghr_nature_of_actions.code%TYPE
                        ,p_first_action_la_code1     IN     ghr_pa_requests.first_action_la_code1%TYPE
                        ,p_effective_date            IN     DATE
                        ,p_pay_rate_determinant      IN     VARCHAR2
                        ,p_pay_plan                  IN     VARCHAR2
                        ,p_grade_or_level            IN     VARCHAR2
                        ,p_step_or_rate              IN     VARCHAR2
                        ,p_pay_basis                 IN     VARCHAR2
                        ,p_user_table_id             IN     NUMBER
                        ,p_duty_station_id           IN     NUMBER
                        ,p_auo_premium_pay_indicator IN     VARCHAR2
                        ,p_ap_premium_pay_indicator  IN     VARCHAR2
                        ,p_retention_allowance       IN     NUMBER
                        ,p_to_ret_allow_percentage   IN     NUMBER
                        ,p_supervisory_differential  IN     NUMBER
                        ,p_staffing_differential     IN     NUMBER
                        ,p_current_basic_pay         IN     NUMBER
                        ,p_current_adj_basic_pay     IN     NUMBER
                        ,p_current_step_or_rate      IN     VARCHAR2
                        ,p_pa_request_id             IN     NUMBER
                        ,p_open_range_out_basic_pay  IN     NUMBER DEFAULT NULL
			,p_open_out_locality_adj     IN     NUMBER DEFAULT NULL
			,p_basic_pay                    OUT NOCOPY NUMBER
                        ,p_locality_adj                 OUT NOCOPY NUMBER
                        ,p_adj_basic_pay                OUT NOCOPY NUMBER
                        ,p_total_salary                 OUT NOCOPY NUMBER
                        ,p_other_pay_amount             OUT NOCOPY NUMBER
                        ,p_to_retention_allowance       OUT NOCOPY NUMBER
                        ,p_ret_allow_perc_out           OUT NOCOPY NUMBER
                        ,p_au_overtime                  OUT NOCOPY NUMBER
                        ,p_availability_pay             OUT NOCOPY NUMBER
			-- FWFA Changes
		        ,p_calc_pay_table_id		OUT NOCOPY NUMBER
			,p_pay_table_id			OUT NOCOPY NUMBER
			-- FWFA Changes
                        ,p_out_step_or_rate             OUT NOCOPY VARCHAR2
                        ,p_out_pay_rate_determinant     OUT NOCOPY VARCHAR2
                        ,p_out_to_grade_id              OUT NOCOPY NUMBER
                        ,p_out_to_pay_plan              OUT NOCOPY VARCHAR2
                        ,p_out_to_grade_or_level        OUT NOCOPY VARCHAR2
                        ,p_PT_eff_start_date            OUT NOCOPY DATE
                        ,p_open_basicpay_field          OUT NOCOPY BOOLEAN
                        ,p_open_pay_fields              OUT NOCOPY BOOLEAN
                        ,p_message_set                  OUT NOCOPY BOOLEAN
                        ,p_calculated                   OUT NOCOPY BOOLEAN
			,p_open_localityadj_field       OUT NOCOPY BOOLEAN
                        ) IS
--
l_ghr_pa_request_rec             ghr_pa_requests%ROWTYPE;
--
l_effective_date                 DATE;
--
l_position_id                    hr_all_positions_f.position_id%TYPE;
l_noa_family_code                ghr_families.noa_family_code%TYPE;
l_noa_code                       ghr_nature_of_actions.code%TYPE;
l_second_noa_code                ghr_nature_of_actions.code%TYPE;
l_first_action_la_code1          ghr_pa_requests.first_action_la_code1%TYPE;
l_pay_rate_determinant           VARCHAR2(30);
l_pay_plan                       VARCHAR2(30);
l_grade_or_level                 VARCHAR2(60);
l_step_or_rate                   VARCHAR2(30);
l_pay_basis                      VARCHAR2(30);
l_duty_station_id                NUMBER;
l_auo_premium_pay_indicator      VARCHAR2(30);
l_ap_premium_pay_indicator       VARCHAR2(30);
l_retention_allowance            NUMBER;
l_dummy                          NUMBER;
l_to_retention_allowance         NUMBER;
l_to_ret_allow_percentage        NUMBER(15,2);
l_ret_calc_perc                  NUMBER(15,2);
l_supervisory_differential       NUMBER;
l_staffing_differential          NUMBER;
l_current_basic_pay              NUMBER;
l_current_adj_basic_pay          NUMBER;
l_current_step_or_rate           VARCHAR2(30);
-- Bug#5120116
l_capped_other_pay               NUMBER;
l_prd_d_pay_amount               NUMBER; --Bug# 7557159
--
l_second_noa_family_code         ghr_families.noa_family_code%TYPE;
l_run_pay_calc_again             BOOLEAN := FALSE;
--
l_pay_calc_data      ghr_pay_calc.pay_calc_in_rec_type;    -- This is the main IN record structure
l_pay_calc_out_data  ghr_pay_calc.pay_calc_out_rec_type;   -- This is the main OUT record structure
l_retained_grade     ghr_pay_calc.retained_grade_rec_type; -- This contains retained grade info if needed
--
l_message_set  BOOLEAN := FALSE;
l_calculated   BOOLEAN := TRUE;
--
l_user_table_id      pay_user_tables.user_table_id%TYPE;
--

l_proc               VARCHAR2(30) := 'main_pay_calc';

cursor cur_ex_emp is
select 1
from  per_person_types pet1,
      per_people_f     per1
where pet1.person_type_id = per1.person_type_id
and   per1.person_id      = p_person_id
and   nvl(p_effective_date,trunc(sysdate))
      between per1.effective_start_date and per1.effective_end_date
and   pet1.system_person_type = 'EX_EMP';

l_ex_emp              BOOLEAN;
l_session             ghr_history_api.g_session_var_type;
v_session             ghr_history_api.g_session_var_type;

----IA Correction Logic.
   cursor c_pa_req1 is
   select pa_notification_id
   from ghr_pa_requests
   where pa_request_id = l_ghr_pa_request_rec.altered_pa_request_id;

l_ia_flag                           varchar2(30);
l_pa_notification_id                ghr_pa_requests.pa_notification_id%type;
l_retro_first_noa                   ghr_nature_of_actions.code%type;
l_retro_second_noa                  ghr_nature_of_actions.code%type;

l_retro_pa_request_id         ghr_pa_requests.pa_request_id%type;
l_ia_effective_date            ghr_pa_requests.effective_date%type;
l_ia_retro_first_noa           ghr_nature_of_actions.code%type;
l_ia_retro_second_noa          ghr_nature_of_actions.code%type;
l_old_effective_date           date;
l_old_ret_allow                NUMBER;
l_value                        VARCHAR2(60);
l_multi_error_flag             BOOLEAN;
l_from_basic_pay               NUMBER;
l_from_retention_allowance     NUMBER;

-- Bug 3248061
l_altered_pa_req_id ghr_pa_requests.altered_pa_request_id%type;
-- Bug 3245692
l_from_pay_basis ghr_pa_requests.from_pay_basis%type;

CURSOR c_get_from_pay_basis(c_pa_request_id IN ghr_pa_requests.pa_request_id%type)  IS
   SELECT from_pay_basis
   FROM ghr_pa_requests
   WHERE pa_request_id = c_pa_request_id;

CURSOR c_get_alt_pareq_id(c_pa_request_id IN ghr_pa_requests.pa_request_id%type)  IS
   SELECT altered_pa_request_id
   FROM ghr_pa_requests
   WHERE pa_request_id = c_pa_request_id;

CURSOR c_get_notification_id(c_alt_pa_request_id IN ghr_pa_requests.pa_request_id%type)  IS
   SELECT pa_notification_id
   FROM ghr_pa_requests
   WHERE pa_request_id = c_alt_pa_request_id;
-- End Bug 3248061

-- Bug#5120116 created the cursor to get assignment id.
CURSOR c_asg_rec(c_person_id NUMBER, c_effective_date DATE) IS
SELECT assignment_id
FROM   per_all_assignments_f
WHERE  person_id = c_person_id
AND    assignment_type = 'E'
AND    c_effective_date between effective_start_date and effective_end_date;

-- Bug#6154261
cursor espayplan
    is
    select 1
    from   ghr_pay_plans
    where  equivalent_pay_plan = 'ES'
    and    pay_plan            = l_pay_plan;

esplan_flag        varchar2(1);

--Bug # 9156680

cursor c_pay_tab_essl is
  select 1 from pay_user_tables
  where substr(user_table_name,1,4) = 'ESSL'
  and user_table_id = l_user_table_id;

l_essl_table BOOLEAN :=FALSE;

--Bug #6154261
l_assignment_id NUMBER;

l_max_RA	NUMBER;


------ GPPA Update 46 - GM Pay plan will change to GS pay plan for 890 NOAC
    l_business_group_id     per_positions.organization_id%TYPE;

    CURSOR GET_GRADE_ID (v_pay_plan varchar2, v_grade_or_level varchar2) IS
    SELECT grd.grade_id  grade_id
    FROM per_grades grd,
         per_grade_definitions gdf
     WHERE  gdf.segment1 = v_pay_plan
    AND gdf.segment2 = v_grade_or_level
    AND grd.grade_definition_id = gdf.grade_definition_id
    AND grd.business_group_id = l_business_group_id;

    l_grade_id              NUMBER;
    l_pay_plan_changed      BOOLEAN;
    l_default_pay_plan      VARCHAR2(5);
------ GPPA Update 46 end

--Begin Bug# 8453042
sl_eql_pay_plan ghr_pay_plans.equivalent_pay_plan%type;

cursor c_sl_eql_pp is
select equivalent_pay_plan from ghr_pay_plans
where PAY_PLAN = l_pay_plan;
--End Bug# 8453042

BEGIN

------ GPPA Update 46 Start
      l_business_group_id     := FND_PROFILE.value('PER_BUSINESS_GROUP_ID');
      l_pay_plan_changed      := FALSE;
------ GPPA Update 46 End

  l_ex_emp := FALSE;
    for cur_ex_emp_rec in cur_ex_emp
    LOOP
       l_ex_emp := TRUE;
    END LOOP;

  hr_utility.set_location('Entering main pay calc...'|| l_proc,5);
-----Bug 3288419 Initialize the global variables.
   g_gm_unadjd_basic_pay := NULL;
   gm_unadjusted_pay_flg := NULL;
   -- FWFA Changes Bug#4444609
   g_pay_table_upd_flag := FALSE;
   g_fwfa_pay_calc_flag := FALSE;
   g_gl_upd_flag        := FALSE;
   g_fw_equiv_pay_plan  := FALSE; --Bug 5218445
   g_out_to_pay_plan    := NULL;
   -- FWFA Changes
  l_pay_calc_out_data.open_pay_fields := FALSE;
  l_pay_calc_out_data.open_basicpay_field := FALSE;
--  Bug#5132113
  l_pay_calc_out_data.open_localityadj_field := FALSE;

  BEGIN
    -- This is the main starting point of pay calc.
    -- Basically the user gives us the IN parameters needed to calculate
    -- pay and if we can we do it if not
    -- we pass the same parameters on to a custome defined procedure
    --
    -- Bug For 866 use effective date + 1
    --
    -- Bug 705022 Now overrides the previous bug!! :- 866 also uses simply effective_date
      IF NVL(p_noa_code,'@@!!##') = '866' OR NVL(p_second_noa_code,'@@!!##') = '866' THEN
        l_effective_date := p_effective_date + 1;
      ELSE
        l_effective_date := p_effective_date;
      END IF;
    --
      IF ( p_noa_code = '702' OR p_second_noa_code = '702' )
       AND  ( p_pay_rate_determinant in ('A','B','E','F','U','V') )  THEN
          hr_utility.set_message(8301,'GHR_38697_RG_PROMOTE');
          raise pay_calc_message;
     END IF;

    -- For corrections we need to go and get alot of the IN parameters
    -- as the form does not populate them:
    IF p_noa_family_code = 'CORRECT' THEN
      -- Must have a pa_request_id for a CORRECT family
      ghr_pc_basic_pay.g_noa_family_code := 'CORRECT';
      IF p_pa_request_id IS NULL THEN
        hr_utility.set_message(8301,'GHR_38398_PAY_CALC_NO_PAR_ID');
        raise pay_calc_message;
      END IF;
      ghr_corr_canc_sf52.build_corrected_sf52
                      (p_pa_request_id    => p_pa_request_id
                      ,p_noa_code_correct => p_second_noa_code
                      ,p_sf52_data_result => l_ghr_pa_request_rec
                      ,p_called_from      => 'FROM_PAYCAL');

      l_position_id                    := NVL(p_position_id,l_ghr_pa_request_rec.to_position_id);
      l_noa_family_code                := ghr_pa_requests_pkg.get_noa_pm_family(p_second_noa_code);
      l_noa_code                       := p_second_noa_code;
      l_second_noa_code                := NULL;
      l_first_action_la_code1          := NVL(p_first_action_la_code1    ,l_ghr_pa_request_rec.first_action_la_code1);
      l_pay_rate_determinant           := NVL(p_pay_rate_determinant     ,l_ghr_pa_request_rec.pay_rate_determinant);
      l_pay_plan                       := NVL(p_pay_plan                 ,l_ghr_pa_request_rec.to_pay_plan);
      l_grade_or_level                 := NVL(p_grade_or_level           ,l_ghr_pa_request_rec.to_grade_or_level);
      l_step_or_rate                   := NVL(p_step_or_rate             ,l_ghr_pa_request_rec.to_step_or_rate);
      l_pay_basis                      := NVL(p_pay_basis                ,l_ghr_pa_request_rec.to_pay_basis);
      l_duty_station_id                := NVL(p_duty_station_id          ,l_ghr_pa_request_rec.duty_station_id);
      l_auo_premium_pay_indicator      := NVL(p_auo_premium_pay_indicator,l_ghr_pa_request_rec.to_auo_premium_pay_indicator);
      l_ap_premium_pay_indicator       := NVL(p_ap_premium_pay_indicator ,l_ghr_pa_request_rec.to_ap_premium_pay_indicator);
      l_retention_allowance            := NVL(p_retention_allowance      ,l_ghr_pa_request_rec.to_retention_allowance);
      l_to_ret_allow_percentage        := NVL(p_to_ret_allow_percentage  ,l_ghr_pa_request_rec.to_retention_allow_percentage);
      l_supervisory_differential       := NVL(p_supervisory_differential ,l_ghr_pa_request_rec.to_supervisory_differential);
      l_staffing_differential          := NVL(p_staffing_differential    ,l_ghr_pa_request_rec.to_staffing_differential);
      l_current_basic_pay              := NVL(p_current_basic_pay        ,l_ghr_pa_request_rec.from_basic_pay);
      l_current_adj_basic_pay          := NVL(p_current_adj_basic_pay    ,l_ghr_pa_request_rec.from_adj_basic_pay);
      l_current_step_or_rate           := NVL(p_current_step_or_rate     ,l_ghr_pa_request_rec.from_step_or_rate);

	  -- For correction actions take pay basis from ghr_pa_requests table itself.
	  FOR ctr_from_pay_basis IN c_get_from_pay_basis(p_pa_request_id) LOOP
			 l_from_pay_basis := ctr_from_pay_basis.from_pay_basis;
	  END LOOP;

    ELSE
      ghr_pc_basic_pay.g_noa_family_code := NULL;
      l_position_id                    := p_position_id;
      l_noa_family_code                := p_noa_family_code;
      l_noa_code                       := p_noa_code;
      l_second_noa_code                := p_second_noa_code;
      l_first_action_la_code1          := p_first_action_la_code1;
      l_pay_rate_determinant           := p_pay_rate_determinant;
      l_pay_plan                       := p_pay_plan;
      l_grade_or_level                 := p_grade_or_level;
      l_step_or_rate                   := p_step_or_rate;
      l_pay_basis                      := p_pay_basis;
      l_duty_station_id                := p_duty_station_id;
      l_auo_premium_pay_indicator      := p_auo_premium_pay_indicator;
      l_ap_premium_pay_indicator       := p_ap_premium_pay_indicator;
      l_retention_allowance            := p_retention_allowance;
      l_to_ret_allow_percentage        := p_to_ret_allow_percentage;
      l_supervisory_differential       := p_supervisory_differential;
      l_staffing_differential          := p_staffing_differential;
      l_current_basic_pay              := p_current_basic_pay;
      l_current_adj_basic_pay          := p_current_adj_basic_pay;
      l_current_step_or_rate           := p_current_step_or_rate;

	  -- 3245692 Get From pay basis from the function get_pay_basis
	  l_from_pay_basis := get_pay_basis(
										p_effective_date => p_effective_date,
										p_pa_request_id => p_pa_request_id,
										p_person_id => p_person_id);
	  IF (l_from_pay_basis = '-1') THEN
			hr_utility.set_message(8301,'GHR_38020_PAY_CALC_NO_PAY_BAS');
			raise pay_calc_message;
	  END IF;
	  -- End 3245692

    END IF;

    hr_utility.set_location(' Passed Noa Fam Code   = ' || p_noa_family_code,5);
    hr_utility.set_location(' Passed l_retention_allowance  = ' || to_char(l_retention_allowance),5);
    hr_utility.set_location(' Passed l_to_ret_allow_percentage  = ' || to_char(l_to_ret_allow_percentage),5);

      ghr_history_api.get_g_session_var(l_session);
       hr_utility.set_location( 'Get Ses NOAIDCORR  is   ' || to_char(l_session.noa_id_correct), 15);
       hr_utility.set_location( 'Get Ses ASGID is '        || to_char(l_session.assignment_id), 15);
        -- set values of session variables IA fetch sake.
        v_session.pa_request_id             := l_session.pa_request_id;
        v_session.noa_id                    := l_session.noa_id;
        v_session.fire_trigger              := l_session.fire_trigger;
        v_session.date_Effective            := l_session.date_Effective;
        v_session.person_id                 := l_session.person_id;
        v_session.program_name              := l_session.program_name;
        v_session.assignment_id             := l_session.assignment_id;
        v_session.altered_pa_request_id     := l_session.altered_pa_request_id;
        v_session.noa_id_correct            := l_session.noa_id_correct;


  IF l_session.noa_id_correct is not null then
      ghr_pc_basic_pay.g_noa_family_code := 'CORRECT';
--  First determine presence of retro active actions
     l_ia_flag := 'N';
	-- Bug 3248061 Sundar
	-- l_ghr_pa_request_rec.pa_request_id becomes null for correction record. So in that case
	-- Use p_pa_request_id which is passed instead of the value from the record l_ghr_pa_request_rec
	IF (l_ghr_pa_request_rec.pa_request_id IS NULL) THEN
			-- Get the Original Id of this correction action
			FOR ctr_alt_pareq_id IN c_get_alt_pareq_id(p_pa_request_id) LOOP
				l_altered_pa_req_id := 	ctr_alt_pareq_id.altered_pa_request_id;
			END LOOP;
			-- Get Notification ID for this Original pa_request_id
			FOR ctr_get_notify_id IN c_get_notification_id(l_altered_pa_req_id) LOOP
			   l_pa_notification_id := ctr_get_notify_id.pa_notification_id;
			END LOOP;
	ELSE
		    FOR c_pa_rec1 IN c_pa_req1 LOOP
			    l_pa_notification_id := c_pa_rec1.pa_notification_id;
		    END LOOP;
	END IF;
	-- End Bug 3248061
--  Get the pa_notification_id from the original action

    --BUG #7216635 added the parameter p_noa_id_correct
     GHR_APPROVED_PA_REQUESTS.determine_ia(
                             p_pa_request_id      => l_ghr_pa_request_rec.altered_pa_request_id,
                             p_pa_notification_id => l_pa_notification_id,
                             p_person_id          => p_person_id,
                             p_effective_date     => l_effective_date,
    		             p_noa_id_correct => l_session.noa_id_correct,
                             p_retro_pa_request_id => l_retro_pa_request_id,
                             p_retro_eff_date     => l_ia_effective_date,
                             p_retro_first_noa    => l_ia_retro_first_noa,
                             p_retro_second_noa   => l_ia_retro_second_noa);
   if l_ia_effective_date is NOT NULL THEN
      l_ia_flag := 'Y';
      IF l_retro_first_noa = '866' then
         l_ia_effective_date := l_ia_effective_date + 1;
      END IF;
   end if;

       hr_utility.set_location( 'l_ia_effective_date  ' || to_char(l_ia_effective_date,'YYYY/MM/DD'),15);

       hr_utility.set_location( 'Ses NOAIDCORR  is   ' || to_char(v_session.noa_id_correct), 15);
       hr_utility.set_location( 'Ses ASGID is '        || to_char(v_session.assignment_id), 15);

      ghr_history_api.reinit_g_session_var;
        l_session.noa_id_correct            := NULL;
       hr_utility.set_location( 'Set Ses NOAIDCORR  is   ' || to_char(l_session.noa_id_correct), 15);
      ghr_history_api.set_g_session_var(l_session);

   if l_ia_effective_date is not null then
      l_old_effective_date   :=  l_ia_effective_date - 1;
   else
      l_old_effective_date   :=  l_effective_date - 1;
   end if;

       hr_utility.set_location( 'l_old_effective_date  ' || to_char(l_old_effective_date,'YYYY/MM/DD'),15);
       hr_utility.set_location( 'Ses NOAIDCORR  is   ' || to_char(l_session.noa_id_correct), 15);
       hr_utility.set_location( 'Ses ASGID is '        || to_char(l_session.assignment_id), 15);
       hr_utility.set_location( 'Fetch old Retention Allowance' || l_proc,15);

-------Assignment id is different then need to be checked the following logic.

       ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => l_session.assignment_id
                               ,p_effective_date        => l_old_effective_date
                               ,p_value                 => l_value
                               ,p_multiple_error_flag   => l_multi_error_flag);
       l_old_ret_allow := to_number(l_value);
       hr_utility.set_location( 'l_old_ret_allow is   ' || to_char(l_old_ret_allow), 15);

       ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => l_session.assignment_id
                               ,p_effective_date        => nvl(l_ia_effective_date,l_effective_date)
                               ,p_value                 => l_value
                               ,p_multiple_error_flag   => l_multi_error_flag);
       l_from_retention_allowance := to_number(l_value);
       hr_utility.set_location( 'l_from_retention_allowance is   ' || to_char(l_from_retention_allowance), 15);
--
-- Modifying the input values from percent to percentage for Payroll Integration
--
       ghr_api.retrieve_element_entry_value (p_element_name    => 'Basic Salary Rate'
                               ,p_input_value_name      => 'Rate'
                               ,p_assignment_id         => l_session.assignment_id
                               ,p_effective_date        => nvl(l_ia_effective_date,l_effective_date)
                               ,p_value                 => l_value
                               ,p_multiple_error_flag   => l_multi_error_flag);
       l_from_basic_pay := to_number(l_value);
       hr_utility.set_location( 'l_from_basic_pay is   ' || to_char(l_from_basic_pay), 15);

   if l_ia_effective_date is not null then
       ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
                               ,p_input_value_name        => 'Amount'
                               ,p_assignment_id           => l_session.assignment_id
                               ,p_effective_date          => l_ia_effective_date
                               ,p_value                   => l_value
                               ,p_multiple_error_flag     => l_multi_error_flag);

       l_ghr_pa_request_rec.to_retention_allowance := to_number(l_value);
       hr_utility.set_location( 'RA  is   ' || to_char(l_ghr_pa_request_rec.to_retention_allowance), 15);
--
-- Modifying the input values from percent to percentage for Payroll Integration
--
  ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
                               ,p_input_value_name        => 'Percentage'
                               ,p_assignment_id           => l_session.assignment_id
                               ,p_effective_date          => l_ia_effective_date
                               ,p_value                   => l_value
                               ,p_multiple_error_flag     => l_multi_error_flag);

       l_ghr_pa_request_rec.to_retention_allow_percentage := to_number(l_value);
       hr_utility.set_location( 'RA %  is   ' || to_char(l_ghr_pa_request_rec.to_retention_allow_percentage),15);

  ghr_api.retrieve_element_entry_value (p_element_name    => 'Supervisory Differential'
                               ,p_input_value_name        => 'Amount'
                               ,p_assignment_id           => l_session.assignment_id
                               ,p_effective_date          => l_ia_effective_date
                               ,p_value                   => l_value
                               ,p_multiple_error_flag     => l_multi_error_flag);

       l_ghr_pa_request_rec.to_supervisory_differential := to_number(l_value);
       hr_utility.set_location( 'SD   is   ' || to_char(l_ghr_pa_request_rec.to_supervisory_differential), 15);


  ghr_api.retrieve_element_entry_value (p_element_name    => 'AUO'
                               ,p_input_value_name        => 'Premium Pay Ind'
                               ,p_assignment_id           => l_session.assignment_id
                               ,p_effective_date          => l_ia_effective_date
                               ,p_value                   => l_value
                               ,p_multiple_error_flag     => l_multi_error_flag);

       l_ghr_pa_request_rec.to_auo_premium_pay_indicator := l_value;
       hr_utility.set_location( 'AUO   is   ' || (l_ghr_pa_request_rec.to_auo_premium_pay_indicator), 15);


  ghr_api.retrieve_element_entry_value (p_element_name    => 'Availability Pay'
                               ,p_input_value_name        => 'Premium Pay Ind'
                               ,p_assignment_id           => l_session.assignment_id
                               ,p_effective_date          => l_ia_effective_date
                               ,p_value                   => l_value
                               ,p_multiple_error_flag     => l_multi_error_flag);

        l_ghr_pa_request_rec.to_ap_premium_pay_indicator := l_value;
        hr_utility.set_location( 'AP   is   ' || (l_ghr_pa_request_rec.to_ap_premium_pay_indicator), 15);
      l_auo_premium_pay_indicator      := NVL(p_auo_premium_pay_indicator,l_ghr_pa_request_rec.to_auo_premium_pay_indicator);
      l_ap_premium_pay_indicator       := NVL(p_ap_premium_pay_indicator ,l_ghr_pa_request_rec.to_ap_premium_pay_indicator);
      l_retention_allowance            := NVL(p_retention_allowance      ,l_ghr_pa_request_rec.to_retention_allowance);
      l_to_ret_allow_percentage        := NVL(p_to_ret_allow_percentage  ,l_ghr_pa_request_rec.to_retention_allow_percentage);
      l_supervisory_differential       := NVL(p_supervisory_differential ,l_ghr_pa_request_rec.to_supervisory_differential);
     end if;
  ELSE
      ghr_pc_basic_pay.g_noa_family_code := NULL;
  END IF;
      ghr_history_api.reinit_g_session_var;
        -- Reset values of session variables IA fetch sake.
        l_session.pa_request_id             := v_session.pa_request_id;
        l_session.noa_id                    := v_session.noa_id;
        l_session.fire_trigger              := v_session.fire_trigger;
        l_session.date_Effective            := v_session.date_Effective;
        l_session.person_id                 := v_session.person_id;
        l_session.program_name              := v_session.program_name;
        l_session.assignment_id             := v_session.assignment_id;
        l_session.altered_pa_request_id     := v_session.altered_pa_request_id;
        l_session.noa_id_correct            := v_session.noa_id_correct;
      ghr_history_api.set_g_session_var(l_session);

       hr_utility.set_location( 'Ses NOAIDCORR  is   ' || to_char(l_session.noa_id_correct), 15);
       hr_utility.set_location( 'Ses ASGID is '        || to_char(l_session.assignment_id), 15);


    -- If we didn't get the user_table_id passed in then try and get it from the position_id
    -- This is specifically for the Form as I would expect any body else who uses this to get ALL
    -- details associated with position at the same time i.e pay_plan, grade_or_level, step_or_rate,
    -- pay_basis and at the same time get user_table_id. The reason the form doesn't have it is because
    -- it is not displayed on the SF52!
    IF p_user_table_id IS NULL THEN
      l_user_table_id := get_user_table_id (l_position_id
                                           ,NVL(p_effective_date,TRUNC(sysdate)) );
    ELSE
      l_user_table_id := p_user_table_id;
    END IF;
    --
    -- Dual Actions yuk!!!
    -- Only do this when we have a second NOA
    -- We basically have the following situations;
    --  First Noa      Second NOA       Solution
    --   MAIN          No Pay Calc    Use First NOA
    --   MAIN            MAIN         Use First NOA
    --   MAIN           892/893       Use First NOA

    --  No Pay Calc    No Pay Calc    Use First NOA
    --  No Pay Calc      MAIN         Use Second NOA
    --  No Pay Calc     892/893       Not a valid option

    --   892/893       No Pay Calc    Use First NOA
    --   892/893         MAIN         Use Second NOA
    --   892/893        892/893       Run Pac Calc twice!!
    --
    -- Firstly if no second NOA then nothing to worry about!!
    IF l_second_noa_code IS NOT NULL THEN
      l_second_noa_family_code := ghr_pa_requests_pkg.get_noa_pm_family(p_second_noa_code);
      --
      IF l_second_noa_family_code IN ('APP','CHG_DUTY_STATION','CONV_APP','EXT_NTE','POS_CHG'
                                     ,'REALIGNMENT','REASSIGNMENT', 'RETURN_TO_DUTY')
        AND (l_noa_code IN ('892','893')
          OR l_second_noa_family_code NOT IN ('APP','CHG_DUTY_STATION','CONV_APP','EXT_NTE','POS_CHG'
                                             ,'REALIGNMENT','REASSIGNMENT', 'RETURN_TO_DUTY')
             ) THEN
        l_noa_family_code  := l_second_noa_family_code;
        l_noa_code         := l_second_noa_code;
        l_second_noa_code  := NULL;
      ELSE
        IF l_noa_code IN ('892','893') AND l_second_noa_code IN ('892','893') THEN
          l_run_pay_calc_again := TRUE;
        END IF;
        -- keep the first one and blank the second
        l_second_noa_code  := NULL;
        --
      END IF;
      --
    END IF;
    --
    -- populate a general record group that includes all the IN parameters and pass that around
    --
    l_pay_calc_data := populate_in_rec_structure
                        (p_person_id
                        ,l_position_id
                        ,l_noa_family_code
                        ,l_noa_code
                        ,l_second_noa_code
                        ,l_first_action_la_code1
                        ,l_effective_date
                        ,l_pay_rate_determinant
                        ,l_pay_plan
                        ,l_grade_or_level
                        ,l_step_or_rate
                        ,l_pay_basis
                        ,l_user_table_id
                        ,l_duty_station_id
                        ,l_auo_premium_pay_indicator
                        ,l_ap_premium_pay_indicator
                        ,l_retention_allowance
                        ,l_to_ret_allow_percentage
                        ,l_supervisory_differential
                        ,l_staffing_differential
                        ,l_current_basic_pay
                        ,l_current_adj_basic_pay
                        ,l_current_step_or_rate
                        ,p_pa_request_id
                        ,p_open_range_out_basic_pay
			--Bug #5132113 added new parameter
			,p_open_out_locality_adj
			);
    --
    -- Next do any validation
    --
    validate_in_data(l_pay_calc_data);
    --
    -- Bug#5482191 Fetch the PSI Value
    l_pay_calc_data.personnel_system_indicator := ghr_pa_requests_pkg.get_personnel_system_indicator
                                                 (l_pay_calc_data.position_id,l_pay_calc_data.effective_date); -- MSL Percentage Changes Madhuri
    -- Bug#4758111 PRD 2 Processing.
---  if nvl(ghr_msl_pkg.g_ses_msl_process,'N') <> 'Y' then
  if p_open_range_out_basic_pay is null then

     -- Bug # 9156680 Modified for 890 to consider ESSL pay table validation
     for c_pay_tab_essl_rec in c_pay_tab_essl loop
      l_essl_table := TRUE;
      exit;
     end loop;

     IF NOT(l_essl_table and l_noa_code = '890') THEN
        IF l_noa_code = '892' AND
           l_effective_date < to_date('2007/01/07','YYYY/MM/DD') THEN
	     IF  espayplan%isopen THEN
	         CLOSE espayplan;
	     END IF;

	     OPEN espayplan;
	     FETCH espayplan into esplan_flag;
	     IF espayplan%FOUND THEN
	      CLOSE espayplan;
	      hr_utility.set_message(8301, 'GHR_38223_INV_PAY_PLAN_892');
	      hr_utility.raise_error;
            END IF;
           CLOSE espayplan;
        END IF;
    ---Bug 7557159 Start
    IF p_pay_rate_determinant = 'D' THEN
        hr_utility.set_message(8301, 'GHR_38520_PRD_D');
         raise ghr_pay_calc.open_pay_range_mesg;
    END IF;
    ---Bug 7557159 End
    if get_open_pay_range ( l_position_id
                          , p_person_id
                          , l_pay_rate_determinant
                          , p_pa_request_id
                          , NVL(p_effective_date,TRUNC(sysdate)) ) then
  --6489042 during appointment of ESSL employees of PRD 2 enabling basic pay for user entry
      if p_pay_rate_determinant <> '2' then
              hr_utility.set_message(8301, 'GHR_38713_OPEN_PAY_RANGE');
              raise ghr_pay_calc.open_pay_range_mesg;
      elsif p_pay_rate_determinant = '2' and l_noa_family_code IN ('APP') then
              hr_utility.set_message(8301, 'GHR_38713_OPEN_PAY_RANGE');
              raise ghr_pay_calc.open_pay_range_mesg;
      end if;
     end if;
    END IF;
  end if;
---  end if;
    --

    -- FWFA Modification: Moved the get_retained_grade_details call from get_basic_pay procedure
    -- to this position.
    IF l_pay_calc_data.pay_rate_determinant IN ('A','B','E','F','U','V','M') THEN
      BEGIN
       l_retained_grade := ghr_pc_basic_pay.get_retained_grade_details (l_pay_calc_data.person_id
								                                        ,l_pay_calc_data.effective_date
                                                                       ,l_pay_calc_data.pa_request_id);
      EXCEPTION
        WHEN OTHERS THEN
            RAISE;
      END;
    END IF;
    -- FWFA Modification

    -- FWFA Changes.
    --6489042 during appointment of ESSL employees of PRD 2 not to handle the existing functionality of
    -- copying the already existing values
    IF p_pay_rate_determinant = '2' and l_noa_family_code NOT IN ('APP') THEN

           l_pay_calc_out_data.basic_pay := l_pay_calc_data.current_basic_pay;
           l_pay_calc_out_data.adj_basic_pay := l_pay_calc_data.current_adj_basic_pay;
           l_pay_calc_out_data.locality_adj := l_pay_calc_out_data.adj_basic_pay - l_pay_calc_out_data.basic_pay;
           -- Bug#5349609 Added the other pay components values to the out variables
           l_pay_calc_out_data.retention_allowance := l_pay_calc_data.retention_allowance;
           l_pay_calc_out_data.au_overtime := get_ppi_amount (l_pay_calc_data.auo_premium_pay_indicator
                                                      ,l_pay_calc_out_data.adj_basic_pay
                                                      ,l_pay_calc_data.pay_basis);
           l_pay_calc_out_data.availability_pay := get_ppi_amount (l_pay_calc_data.ap_premium_pay_indicator
                                                           ,l_pay_calc_out_data.adj_basic_pay
                                                           ,l_pay_calc_data.pay_basis);
           hr_utility.set_location('test asg id: '||l_session.assignment_id,10);
           hr_utility.set_location(' test eff dt: '||l_pay_calc_data.effective_date,10);
           FOR asg_rec IN c_asg_rec(l_pay_calc_data.person_id, l_pay_calc_data.effective_date)
           LOOP
               l_assignment_id := asg_rec.assignment_id;
               exit;
           END LOOP;
           l_capped_other_pay :=  ghr_pa_requests_pkg2.get_cop(l_assignment_id,
		                                                       l_pay_calc_data.effective_date);

           -- Bug#5349609 If capped other pay is null, get the other pay value.
           IF l_capped_other_pay is NULL THEN
               get_other_pay_amount (l_pay_calc_data, l_pay_calc_out_data);
               get_total_salary (l_pay_calc_out_data,l_pay_calc_data.pay_basis);
           ELSE
              l_pay_calc_out_data.total_salary :=  NVL(l_pay_calc_out_data.adj_basic_pay,0) +
                                                 NVL(l_capped_other_pay,0);

           END IF;
    ELSE
       -- Bug#4758111
       IF fwfa_pay_calc(l_pay_calc_data,l_retained_grade) THEN
            special_rate_pay_calc (p_pay_calc_data     => l_pay_calc_data
                              ,p_pay_calc_out_data => l_pay_calc_out_data
                              ,p_retained_grade    => l_retained_grade
                              );
             --Begin Bug 7046241
            IF l_pay_plan = 'GP' then
                --Setting process methods for GP pay plan
                l_pay_calc_out_data.open_localityadj_field := TRUE;
                If (l_pay_calc_data.noa_code = '894' OR l_pay_calc_data.second_noa_code = '894')
                    and (l_first_action_la_code1 <> 'ZLM') then
                    l_pay_calc_out_data.open_localityadj_field := FALSE;
                End If;
                If (l_pay_calc_data.noa_code = '893' OR l_pay_calc_data.second_noa_code = '893') then
                    l_pay_calc_out_data.open_localityadj_field := FALSE;
                End If;
                --Restoring Market pay since market pay should not change because of special_rate_pay_calc
                if p_open_out_locality_adj is not null then
                    l_pay_calc_out_data.locality_adj := p_open_out_locality_adj;
                    l_pay_calc_out_data.adj_basic_pay := l_pay_calc_out_data.locality_adj +
                                                         l_pay_calc_out_data.basic_pay;
                end if;
            ELSIF l_pay_plan = 'GR' then --IF l_pay_plan = 'GP'
                hr_utility.set_location('Setting process methods for GP pay plan...',555);
                get_locality_adj (l_pay_calc_data, l_retained_grade, l_pay_calc_out_data);
                If (l_pay_calc_data.noa_code = '894' OR l_pay_calc_data.second_noa_code = '894')
                    and (l_first_action_la_code1 = 'ZLM') then
                    l_pay_calc_out_data.open_localityadj_field := TRUE;
                END IF;
                --Restoring Market pay since market pay should not change because of special_rate_pay_calc
                if p_open_out_locality_adj is not null then
                    l_pay_calc_out_data.locality_adj := p_open_out_locality_adj;
                    l_pay_calc_out_data.adj_basic_pay := l_pay_calc_out_data.locality_adj +
                                                         l_pay_calc_out_data.basic_pay;
                end if;
            END IF; --IF l_pay_plan = 'GP'
            --End Bug 7046241
       ELSE

       ------GPPA Update 46 start
             IF (l_pay_calc_data.noa_code = '890' OR l_pay_calc_data.second_noa_code = '890') AND
                l_pay_calc_data.pay_plan = 'GM' then
                l_pay_calc_data.pay_plan := 'GS';
                l_default_pay_plan       := 'GS';
                l_grade_id               := NULL;
                FOR get_grade_id_rec IN get_grade_id(l_default_pay_plan, l_pay_calc_data.grade_or_level)
                   LOOP
                        l_grade_id := get_grade_id_rec.grade_id;
                        l_pay_plan_changed   := TRUE;
                        g_pay_table_upd_flag := TRUE;
                        exit;
                END LOOP;
              END IF;
        ------------------------------ 1) Get basic_pay --------------------------------------------------------
            --
          hr_utility.set_location('Calling main basic pay...'|| l_proc,5);
        -- MSL percentage Changes Madhuri 3843306

        --  if nvl(ghr_msl_pkg.g_ses_msl_process,'N') = 'Y' then
        --     l_pay_calc_out_data.basic_pay := nvl(l_pay_calc_data.current_adj_basic_pay,0);
          --else
            ghr_pc_basic_pay.get_basic_pay (l_pay_calc_data, l_pay_calc_out_data, l_retained_grade);
          --end if;
            -- FWFA Changes. Bug#4444609 Setting the Calculation Pay Table in case of non-fwfa calculations.
            IF l_pay_calc_data.pay_rate_determinant IN ('A','B','E','F','U','V','M') AND
               l_retained_grade.temp_step IS NULL THEN
                l_pay_calc_out_data.calculation_pay_table_id := l_retained_grade.user_table_id;
                l_pay_calc_out_data.pay_table_id             := l_retained_grade.user_table_id;
                l_pay_plan                                   := l_retained_grade.pay_plan;
            ELSE
                l_pay_calc_out_data.calculation_pay_table_id := l_pay_calc_data.user_table_id;
                l_pay_calc_out_data.pay_table_id             := l_pay_calc_data.user_table_id;
                l_pay_plan                                   := l_pay_calc_data.pay_plan;
                 -- Bug#4748583 Added the following IF Condition to set the PRD to '6' for 0491 table.
            	 -- Bug#5089732 GL Pay Plan
                 IF get_user_table_name(l_pay_calc_out_data.pay_table_id) = ghr_pay_calc.l_spl491_table_name  AND
		           (l_pay_calc_data.pay_plan <> 'GL' OR
                     (l_pay_plan = 'GG' and
                      l_pay_calc_data.effective_date < to_date('2006/01/08','YYYY/MM/DD')
                     )
                   ) AND
                     l_pay_calc_data.pay_rate_determinant = '0' THEN
                     l_pay_calc_out_data.out_pay_rate_determinant := '6';
                 END IF;
                 -- Bug#4748583
            END IF;
            --Bug#5089732 Set the Pay Rate Determinant for GL,GG Pay Plans
            IF  get_user_table_name(l_pay_calc_out_data.calculation_pay_table_id) = ghr_pay_calc.l_spl491_table_name  AND
                (l_pay_plan = 'GL' OR
                   (l_pay_plan = 'GG' and
                    l_pay_calc_data.effective_date >= to_date('2006/01/08','YYYY/MM/DD')
                   )
                )AND
                l_pay_calc_data.pay_rate_determinant IN ('6','E','F')  THEN
                IF l_pay_calc_data.pay_rate_determinant = '6' THEN
                    l_pay_calc_out_data.out_pay_rate_determinant := '0';
                ELSIF l_pay_calc_data.pay_rate_determinant = 'E' THEN
                    l_pay_calc_out_data.out_pay_rate_determinant := 'A';
                ELSE
                    l_pay_calc_out_data.out_pay_rate_determinant := 'B';
                END IF;
                --Bug#5435217 Set this flag to true to avoid unnecessary creation of RG record.
                g_gl_upd_flag := TRUE;
            END IF;
            -- FWFA Changes
            ------------------------------ 2) Get locality_adj --------------------------------------------------------
            --
         -- Start of Bug #5132113
         IF l_pay_plan = 'GP' then
	    l_pay_calc_out_data.open_localityadj_field := TRUE;

	    --Bug #6344900 locality adjustment should not be opened for 894 and lac codes other than ZLM
	        -- and 893 actions
	    If (l_pay_calc_data.noa_code = '894' OR l_pay_calc_data.second_noa_code = '894')
	        and (l_first_action_la_code1 <> 'ZLM') then
                l_pay_calc_out_data.open_localityadj_field := FALSE;
            End If;
            If (l_pay_calc_data.noa_code = '893' OR l_pay_calc_data.second_noa_code = '893') then
                l_pay_calc_out_data.open_localityadj_field := FALSE;
            End If;


	    if p_open_out_locality_adj is not null then
	       l_pay_calc_out_data.locality_adj := p_open_out_locality_adj;
	    end if;
         ELSE
          hr_utility.set_location('Calling main locality...'|| l_proc,5);
            get_locality_adj (l_pay_calc_data, l_retained_grade, l_pay_calc_out_data);
            --Bug#5132113 for GR payplan and 894 open locality pay for user modification
              If (l_pay_plan = 'GR') AND
                (l_pay_calc_data.noa_code = '894' OR l_pay_calc_data.second_noa_code = '894')
	            and (l_first_action_la_code1 = 'ZLM') then
                l_pay_calc_out_data.open_localityadj_field := TRUE;
              END IF;
            --Bug#5132113

          hr_utility.set_location('Calling main locality..main locality pay .'||
                                                                 to_char(l_pay_calc_out_data.locality_adj),5);
         END IF;
            --
            ------------------------------ 3) Get adj_basic_pay -----------------------------------------------------
            --
          hr_utility.set_location('Calling main adj basic...'|| l_proc,5);
            get_adj_basic_pay (l_pay_calc_data, l_pay_calc_out_data);
          hr_utility.set_location('Calling main adj basic..adj basic Pay.'||
                                                                to_char(l_pay_calc_out_data.adj_basic_pay),5);
        END IF;

     IF g_pay_table_upd_flag THEN
        hr_utility.set_location('After Basic/loc/adj basic calc. Pay Table UPD Flag TRUE',101);
     ELSE
        hr_utility.set_location('After Basic/loc/adj basic Calc. Pay Table UPD Flag FALSE',102);
     END IF;
    --

    ------------------------------ 4.0) Get retention_allowance----------------------------------------------
    --
    ---- Calcultion of Retention Allowance.
    ---
  if p_noa_family_code = 'CONV_APP' and l_ex_emp THEN
     l_retention_allowance      := null;
     l_to_ret_allow_percentage  := null;
  end if;

   if l_retention_allowance is not null then
      if  nvl(l_pay_calc_data.current_basic_pay,0) <> nvl(l_pay_calc_out_data.basic_pay,0) then

          if l_to_ret_allow_percentage is null then
             if (l_session.noa_id_correct is not null ) or (p_noa_family_code = 'CORRECT') then
					hr_utility.set_location(' perc null Inside correct  ' || l_proc,5);
					hr_utility.set_location(' current_basic pay = ' || to_char(l_pay_calc_data.current_basic_pay),5);
               if nvl(l_old_ret_allow,0) = nvl(l_from_retention_allowance,0) then
                  if nvl(l_from_basic_pay,0) <> nvl(l_pay_calc_data.current_basic_pay,0) then
                     l_from_basic_pay :=   l_pay_calc_data.current_basic_pay;
                  end if;
               end if;
			   hr_utility.set_location('From retention' || l_from_retention_allowance,2000);
			   hr_utility.set_location('From l_from_basic_pay' || l_from_basic_pay,2000);
			   hr_utility.set_location('From l_from_pay_basis' || l_from_pay_basis,2000);

			---- Changed for FWS

				l_ret_calc_perc := (l_from_retention_allowance / l_from_basic_pay )* 100;

				-- Bug 3245692 . Replaced l_pay_basis with l_from_pay_basis in the above statement
				 hr_utility.set_location(' Ret Percentage = ' || to_char(l_ret_calc_perc),5);
             else
				hr_utility.set_location(' perc null else   correct  ' || l_proc,5);
					----
					----  Bug 3218346 --
					----

                l_ret_calc_perc := nvl((l_pay_calc_data.retention_allowance /
                                             l_pay_calc_data.current_basic_pay) * 100,0);
				-- Bug 3245692
				hr_utility.set_location(' else Ret Percentage = ' || to_char(l_ret_calc_perc),5);
             end if;

	      if nvl(l_ret_calc_perc,0)  > 25 then
                l_ret_calc_perc := 25;
              end if;
          else  -- l_to_ret_allow_percentage is not null
             l_ret_calc_perc := l_to_ret_allow_percentage;
			hr_utility.set_location(' Passed Percentage l_ret_calc_perc = ' || to_char(l_ret_calc_perc),5);
		  end if; -- if nvl(l_ret_calc_perc,0)  > 2


	 /*IF  l_pay_basis ='PH' THEN
          l_to_retention_allowance := TRUNC(l_pay_calc_out_data.basic_pay * l_ret_calc_perc / 100 ,2);

	 ELSE
          l_to_retention_allowance := TRUNC(l_pay_calc_out_data.basic_pay * l_ret_calc_perc / 100 ,0);

         END IF;
      --Changed for FWS*/

-- Rounding of RETENTION ALLOWANCE STARTS
---3843316
--
		-- BUG# 4689374 For FWFA if % is not entered, then take only the amount
		IF p_pay_rate_determinant IN ('3','4','J','K','U','V') AND
			p_effective_date >= to_date('01/05/2005','dd/mm/yyyy') AND
			l_to_ret_allow_percentage IS NULL THEN
				l_to_retention_allowance := l_retention_allowance;
		ELSE
			  IF  l_pay_basis ='PH' THEN
				  l_to_retention_allowance := round(l_pay_calc_out_data.basic_pay *(l_ret_calc_perc/100),2);
				  IF ( l_ret_calc_perc between 24 and 25) THEN
						 l_max_RA:= trunc((l_pay_calc_out_data.basic_pay*0.25),2);
						 IF (l_to_retention_allowance  > l_max_ra) THEN
							 l_to_retention_allowance:= l_max_ra;
						 END IF;
				  END IF;
			  ELSIF l_pay_basis ='PA' THEN
					l_max_RA:= trunc((l_pay_calc_out_data.basic_pay*0.25),0);
					l_to_retention_allowance :=  round(l_pay_calc_out_data.basic_pay*(l_ret_calc_perc/100),0);
					if l_to_retention_allowance > l_max_RA then
					   l_to_retention_allowance := l_max_RA;
					end if;
			  ELSE
					l_to_retention_allowance := TRUNC(l_pay_calc_out_data.basic_pay * l_ret_calc_perc / 100 ,0);
			  END IF;
		END IF;

--- 3843316
-- Rounding of RETENTION ALLOWANCE  ENDS

    hr_utility.set_location(' Calc retention_allowance  = ' || to_char(l_to_retention_allowance),5);
    hr_utility.set_location(' Calc-Pass ret_allow_percentage  = ' || to_char(l_ret_calc_perc),5);
    hr_utility.set_location(' Supervisory Differentail     = ' || to_char(l_supervisory_differential),5);
      else
    hr_utility.set_location(' Basic Pays are same ' || l_proc,5);
             if ( l_session.noa_id_correct is not null ) or ( p_noa_family_code = 'CORRECT' ) then
    hr_utility.set_location(' Basic Pays are same - Inside Correct ' || l_proc,5);
                if l_from_basic_pay = nvl(l_pay_calc_data.current_basic_pay,0) then
                   l_to_retention_allowance := l_pay_calc_data.retention_allowance;
                else
                   l_to_retention_allowance := l_old_ret_allow;
                end if;
    hr_utility.set_location(' BPS correct retention_allowance  = ' || to_char(l_to_retention_allowance),5);
             else
                l_to_retention_allowance := l_pay_calc_data.retention_allowance;
    hr_utility.set_location(' BPS else retention_allowance  = ' || to_char(l_to_retention_allowance),5);
             end if;
      end if;
   end if;
     l_pay_calc_out_data.retention_allowance := l_to_retention_allowance;

    ------------------------------ 4.1) Get au_overtime------------------------------------------------------
    --
    l_pay_calc_out_data.au_overtime := get_ppi_amount (l_pay_calc_data.auo_premium_pay_indicator
                                                      ,l_pay_calc_out_data.adj_basic_pay
                                                      ,l_pay_calc_data.pay_basis);
    --
    ------------------------------ 4.2) Get avalabilty_pay ------------------------------------------------------
    --
    l_pay_calc_out_data.availability_pay := get_ppi_amount (l_pay_calc_data.ap_premium_pay_indicator
                                                           ,l_pay_calc_out_data.adj_basic_pay
                                                           ,l_pay_calc_data.pay_basis);
    --
    ------------------------------ 5) Get other_pay_amount ------------------------------------------------------
    --
    get_other_pay_amount (l_pay_calc_data, l_pay_calc_out_data);
    --
    ------------------------------ 6) Get_total_salary ------------------------------------------------------
    --
    get_total_salary (l_pay_calc_out_data,l_pay_calc_data.pay_basis);
    --
    -------------------------------------------------------------------------------------------------------
    --
	 END IF; -- End of PRD 2 Processing IF Condition.
----GPPA Update 46
    IF l_pay_plan_changed THEN
       IF nvl(l_pay_calc_out_data.out_pay_rate_determinant,'X') in ('A','B','E','F','U','V') AND
          l_retained_grade.temp_step IS NULL THEN
            g_out_to_pay_plan   := l_default_pay_plan;
       ELSIF l_grade_id is not null then
          l_pay_calc_out_data.out_to_grade_id        := l_grade_id;
          l_pay_calc_out_data.out_to_pay_plan        := l_default_pay_plan;
          l_pay_calc_out_data.out_to_grade_or_level  := l_pay_calc_data.grade_or_level;
       END IF;
    END IF;
    -- If we got here we haven't set any messages and we think we calculated it!!
    -- Even though we calculated everything pass it on to the cutstom call incase they want to
    -- overwrite it!!
---Bug 7423379 Start  (Fix was revoked - AVR 10/24)
----IF l_pay_plan = 'AD' THEN
----      l_pay_calc_out_data.open_pay_fields := TRUE;
----END IF;
---Bug 7423379 End
    ghr_custom_pay_calc.custom_pay_calc
      (l_pay_calc_data
      ,l_pay_calc_out_data
      ,l_message_set
      ,l_calculated);
  EXCEPTION
    WHEN open_pay_range_mesg THEN
      -- set calculated to false and let the customer attempt to calculate it!
      -- if the user enters the validated basic pay then pay will be calculated.
      l_message_set := TRUE;
      l_calculated  := FALSE;
      l_pay_calc_out_data.open_basicpay_field := TRUE;
      -- Bug#4758111 Removed PRD 2 from the following list.
      if p_pay_rate_determinant
         in ( '3','4','C','J','K','M','P','R','S','U','V') then
         l_pay_calc_out_data.open_pay_fields := TRUE;
        hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
        hr_utility.set_message_token('PRD',p_pay_rate_determinant);
      end if;
---Bug 7423379 Start  (Fix was revoked - AVR 10/24)
----IF l_pay_plan = 'AD' THEN
----      l_pay_calc_out_data.open_pay_fields := TRUE;
----END IF;
---Bug 7423379 End
      ghr_custom_pay_calc.custom_pay_calc
        (l_pay_calc_data
        ,l_pay_calc_out_data
        ,l_message_set
        ,l_calculated);
    WHEN unable_to_calculate THEN
      -- set calculated to false and let the customer attempt to calculate it!
      -- if the user calculates it they need to make sure the pass back out p_calculated = TRUE
      -- otherwise we will assume they didn't do it either!!
      -- FWFA Changes. Bug#4444609 Setting the Calculation Pay Table in case of non-fwfa calculations.
      IF NOT (g_fwfa_pay_calc_flag) THEN
		--Begin Bug# 8453042
		FOR l_sl_eql_pp IN c_sl_eql_pp LOOP
		  sl_eql_pay_plan := l_sl_eql_pp.equivalent_pay_plan;
		END LOOP;
		--End Bug# 8453042
		IF l_pay_calc_data.pay_rate_determinant IN ('U','V') AND
		   l_retained_grade.temp_step IS NULL THEN
		    l_pay_calc_out_data.calculation_pay_table_id := l_retained_grade.user_table_id;
		    l_pay_calc_out_data.pay_table_id             := l_retained_grade.user_table_id;
		ELSIF l_pay_calc_data.pay_rate_determinant IN ('3','4','J','K') OR (NVL(sl_eql_pay_plan,'$$')='SL') THEN--Bug# 8453042
		    l_pay_calc_out_data.calculation_pay_table_id := l_pay_calc_data.user_table_id;
 		    l_pay_calc_out_data.pay_table_id             := l_pay_calc_data.user_table_id;
		END IF;
	END IF;
      l_message_set := TRUE;
      l_calculated  := FALSE;
      l_pay_calc_out_data.open_pay_fields := TRUE;
      ghr_custom_pay_calc.custom_pay_calc
        (l_pay_calc_data
        ,l_pay_calc_out_data
        ,l_message_set
        ,l_calculated);
    WHEN ghr_pay_calc.pay_calc_message THEN
      l_message_set := TRUE;
      l_calculated  := TRUE;
---Bug 7423379 Start  (Fix was revoked - AVR 10/24)
----IF l_pay_plan = 'AD' THEN
----    l_pay_calc_out_data.open_pay_fields := TRUE;
----END IF;
---Bug 7423379 End
      ghr_custom_pay_calc.custom_pay_calc
          (l_pay_calc_data
          ,l_pay_calc_out_data
          ,l_message_set
          ,l_calculated);

    END;
    -- In one circumstance we may need to run pay calc again! i.e. Dual Action: 893 / 892
    IF l_run_pay_calc_again THEN
      main_pay_calc     (p_person_id
                        ,p_position_id
                        ,l_second_noa_family_code
                        ,p_second_noa_code
                        ,p_first_action_la_code1
                        ,null
                        ,p_effective_date
                        ,p_pay_rate_determinant
                        ,p_pay_plan
                        ,p_grade_or_level
                        ,p_step_or_rate
                        ,p_pay_basis
                        ,p_user_table_id
                        ,p_duty_station_id
                        ,p_auo_premium_pay_indicator
                        ,p_ap_premium_pay_indicator
                        ,p_retention_allowance
                        ,p_to_ret_allow_percentage
                        ,p_supervisory_differential
                        ,p_staffing_differential
                        ,p_current_basic_pay
                        ,p_current_adj_basic_pay
                        ,l_pay_calc_out_data.out_step_or_rate
                        ,p_pa_request_id
                        ,p_open_range_out_basic_pay
			,p_open_out_locality_adj
                        ,l_pay_calc_out_data.basic_pay
                        ,l_pay_calc_out_data.locality_adj
                        ,l_pay_calc_out_data.adj_basic_pay
                        ,l_pay_calc_out_data.total_salary
                        ,l_pay_calc_out_data.other_pay_amount
                        ,l_pay_calc_out_data.retention_allowance
                        ,l_pay_calc_out_data.ret_allow_perc_out
                        ,l_pay_calc_out_data.au_overtime
                        ,l_pay_calc_out_data.availability_pay
			-- FWFA Changes
			,l_pay_calc_out_data.calculation_pay_table_id
			,l_pay_calc_out_data.pay_table_id
			-- FWFA Changes
                        ,l_pay_calc_out_data.out_step_or_rate
                        ,l_pay_calc_out_data.out_pay_rate_determinant
                        ,l_pay_calc_out_data.out_to_grade_id
                        ,l_pay_calc_out_data.out_to_pay_plan
                        ,l_pay_calc_out_data.out_to_grade_or_level
                        ,l_pay_calc_out_data.PT_eff_start_date
                        ,l_pay_calc_out_data.open_basicpay_field
                        ,l_pay_calc_out_data.open_pay_fields
                        ,l_message_set
                        ,l_calculated
			,l_pay_calc_out_data.open_localityadj_field);
    END IF;

  if get_open_pay_range ( l_position_id
                        , p_person_id
                        , l_pay_rate_determinant
                        , p_pa_request_id
                        , NVL(p_effective_date,TRUNC(sysdate)) ) then
   --6489042 during appointment of ESSL employees of PRD 2 enabling basic pay for user entry
      if (p_pay_rate_determinant <> '2') or (p_pay_rate_determinant = '2' and l_noa_family_code IN ('APP')) then
         l_pay_calc_out_data.open_basicpay_field := TRUE;
      end if;
  end if;

--bug#5132113
/*  if p_open_out_locality_adj is null then
     l_pay_calc_out_data.open_localityadj_field := TRUE;
  end if;*/
    --Begin Bug# 7557159
    IF l_pay_plan='GS' AND l_pay_rate_determinant='D' THEN
        l_prd_d_pay_amount :=  ghr_pay_calc.get_standard_pay_table_value (p_pay_plan  => l_pay_plan
                                ,p_grade_or_level => l_grade_or_level
                                ,p_step_or_rate   => '10'
                                ,p_effective_date => p_effective_date);

        IF l_prd_d_pay_amount < l_pay_calc_out_data.basic_pay THEN
           l_pay_calc_out_data.out_step_or_rate := '00';
           l_pay_calc_out_data.open_basicpay_field := TRUE;
        END IF;
    END IF;
    --End Bug# 7557159
    -- always set the out parameters
    l_pay_calc_out_data.ret_allow_perc_out  := l_to_ret_allow_percentage;

    p_basic_pay                 := l_pay_calc_out_data.basic_pay;
    p_locality_adj              := l_pay_calc_out_data.locality_adj;
    p_adj_basic_pay             := l_pay_calc_out_data.adj_basic_pay;
    p_total_salary              := l_pay_calc_out_data.total_salary;
    p_other_pay_amount          := l_pay_calc_out_data.other_pay_amount;
    p_to_retention_allowance    := l_pay_calc_out_data.retention_allowance;
    p_ret_allow_perc_out        := l_pay_calc_out_data.ret_allow_perc_out;
    p_au_overtime               := l_pay_calc_out_data.au_overtime;
    p_availability_pay          := l_pay_calc_out_data.availability_pay;
    -- FWFA Changes
    p_calc_pay_table_id		:= l_pay_calc_out_data.calculation_pay_table_id;
    p_pay_table_id		:= l_pay_calc_out_data.pay_table_id;
    p_out_to_grade_id           := l_pay_calc_out_data.out_to_grade_id;
    p_out_to_pay_plan           := l_pay_calc_out_data.out_to_pay_plan;
    p_out_to_grade_or_level     := l_pay_calc_out_data.out_to_grade_or_level;
    -- FWFA Changes
    p_out_step_or_rate          := l_pay_calc_out_data.out_step_or_rate;
    p_out_pay_rate_determinant  := l_pay_calc_out_data.out_pay_rate_determinant;
    p_PT_eff_start_date         := l_pay_calc_out_data.PT_eff_start_date;
    p_open_basicpay_field       := l_pay_calc_out_data.open_basicpay_field;
    p_open_pay_fields           := l_pay_calc_out_data.open_pay_fields;
    p_message_set               := l_message_set;
    p_calculated                := l_calculated;

  --Bug#5132113
    p_open_localityadj_field       := l_pay_calc_out_data.open_localityadj_field;


 EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
       p_basic_pay                := NULL;
       p_locality_adj             := NULL;
       p_adj_basic_pay            := NULL;
       p_total_salary             := NULL;
       p_other_pay_amount         := NULL;
       p_to_retention_allowance   := NULL;
       p_ret_allow_perc_out       := NULL;
       p_au_overtime              := NULL;
       p_availability_pay         := NULL;
       -- FWFA Changes
       p_calc_pay_table_id	  := NULL;
       p_pay_table_id		  := NULL;
       -- FWFA Changes
       p_out_step_or_rate         := NULL;
       p_out_pay_rate_determinant := NULL;
       p_out_to_grade_id          := NULL;
       p_out_to_pay_plan          := NULL;
       p_out_to_grade_or_level    := NULL;
       p_PT_eff_start_date        := NULL;
       p_open_basicpay_field      := NULL;
       p_open_pay_fields          := NULL;
       p_message_set              := NULL;
       p_calculated               := NULL;
       p_open_localityadj_field   := NULL;
       RAISE;
END main_pay_calc;


PROCEDURE sql_main_pay_calc (p_pay_calc_data      IN  ghr_pay_calc.pay_calc_in_rec_type
                            ,p_pay_calc_out_data  OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type
                            ,p_message_set        OUT NOCOPY BOOLEAN
                            ,p_calculated         OUT NOCOPY BOOLEAN
                            ) IS
l_message_set BOOLEAN;
l_calculated  BOOLEAN;
BEGIN

        main_pay_calc   (p_pay_calc_data.person_id
                        ,p_pay_calc_data.position_id
                        ,p_pay_calc_data.noa_family_code
                        ,p_pay_calc_data.noa_code
                        ,p_pay_calc_data.second_noa_code
                        ,p_pay_calc_data.first_action_la_code1
                        ,p_pay_calc_data.effective_date
                        ,p_pay_calc_data.pay_rate_determinant
                        ,p_pay_calc_data.pay_plan
                        ,p_pay_calc_data.grade_or_level
                        ,p_pay_calc_data.step_or_rate
                        ,p_pay_calc_data.pay_basis
                        ,p_pay_calc_data.user_table_id
                        ,p_pay_calc_data.duty_station_id
                        ,p_pay_calc_data.auo_premium_pay_indicator
                        ,p_pay_calc_data.ap_premium_pay_indicator
                        ,p_pay_calc_data.retention_allowance
                        ,p_pay_calc_data.to_ret_allow_percentage
                        ,p_pay_calc_data.supervisory_differential
                        ,p_pay_calc_data.staffing_differential
                        ,p_pay_calc_data.current_basic_pay
                        ,p_pay_calc_data.current_adj_basic_pay
                        ,p_pay_calc_data.current_step_or_rate
                        ,p_pay_calc_data.pa_request_id
                        ,p_pay_calc_data.open_range_out_basic_pay
			--Bug5132113
			,p_pay_calc_data.open_out_locality_adj
                        ,p_pay_calc_out_data.basic_pay
                        ,p_pay_calc_out_data.locality_adj
                        ,p_pay_calc_out_data.adj_basic_pay
                        ,p_pay_calc_out_data.total_salary
                        ,p_pay_calc_out_data.other_pay_amount
                        ,p_pay_calc_out_data.retention_allowance
                        ,p_pay_calc_out_data.ret_allow_perc_out
                        ,p_pay_calc_out_data.au_overtime
                        ,p_pay_calc_out_data.availability_pay
                        -- FWFA Changes
                        ,p_pay_calc_out_data.Calculation_pay_table_id
                        ,p_pay_calc_out_data.pay_table_id
                        -- FWFA Changes
                        ,p_pay_calc_out_data.out_step_or_rate
                        ,p_pay_calc_out_data.out_pay_rate_determinant
                        ,p_pay_calc_out_data.out_to_grade_id
                        ,p_pay_calc_out_data.out_to_pay_plan
                        ,p_pay_calc_out_data.out_to_grade_or_level
                        ,p_pay_calc_out_data.PT_eff_start_date
                        ,p_pay_calc_out_data.open_basicpay_field
                        ,p_pay_calc_out_data.open_pay_fields
                        ,l_message_set
                        ,l_calculated
			,p_pay_calc_out_data.open_localityadj_field);

        p_message_set := l_message_set;
        p_calculated  := l_calculated;


    IF l_message_set and l_calculated THEN
        hr_utility.raise_error;
    END IF;

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
     p_message_set         := NULL;
     p_calculated          := NULL;
     p_pay_calc_out_data   := NULL;
     RAISE;
END sql_main_pay_calc;

--
FUNCTION get_pos_pay_basis (p_position_id    IN per_positions.position_id%TYPE
                           ,p_effective_date IN date)
  RETURN VARCHAR2 IS
--
-- Since Position Extra Info now has history use the history packages written to get
-- the user_table_id
l_pos_ei_data   per_position_extra_info%ROWTYPE;
--
--
BEGIN
  ghr_history_fetch.fetch_positionei(
    p_position_id         => p_position_id
   ,p_information_type    => 'GHR_US_POS_VALID_GRADE'
   ,p_date_effective      => p_effective_date
   ,p_pos_ei_data         => l_pos_ei_data);
  --
  RETURN(l_pos_ei_data.poei_information6);
  --
END get_pos_pay_basis;
--

                                                                                          --AVR
PROCEDURE get_locality_adj_894_PRDM_GS (p_user_table_id     IN  NUMBER
                              ,p_pay_plan          IN  VARCHAR2
                              ,p_grade_or_level    IN  VARCHAR2
                              ,p_step_or_rate      IN  VARCHAR2
                              ,p_effective_date    IN  DATE
                              ,p_cur_adj_basic_pay IN NUMBER
                              ,p_new_basic_pay     IN  NUMBER
                              ,p_new_adj_basic_pay OUT NOCOPY NUMBER
                              ,p_new_locality_adj  OUT NOCOPY NUMBER) IS
--
-- Local variables
--

l_PT_value            NUMBER;
l_PT_eff_start_date   DATE;
l_PT_eff_end_date     DATE;
l_PT_o_value          NUMBER;
l_PT_o_eff_start_date DATE;
l_PT_o_eff_end_date   DATE;
l_SPT_value           NUMBER;
l_SPT_o_value         NUMBER;
l_A                   NUMBER;
l_B                   NUMBER;
lesser_amt            NUMBER;
new_adj_basic_pay     NUMBER;
new_locality_adj      NUMBER;

l_proc                VARCHAR2(30) := '894_PRDM_GS';
begin
hr_utility.set_location('Entering ...'|| l_proc,5);
hr_utility.set_location('User_table_id ...'|| p_user_table_id,5);
hr_utility.set_location('p_pay_plan ...'|| p_pay_plan,5);
hr_utility.set_location('p_grade_or_level ...'|| p_grade_or_level,5);
hr_utility.set_location('step_or_rate ...'|| p_step_or_rate,5);
hr_utility.set_location('effective_date ...'|| to_char(p_effective_date,'DD-MON-YYYY'),5);
hr_utility.set_location('In new current adj basic pay ...'|| to_char(p_cur_adj_basic_pay),5);
hr_utility.set_location('In new basic pay ...'|| to_char(p_new_basic_pay),5);

   ghr_pay_calc.get_pay_table_value (p_user_table_id     => p_user_table_id
                                    ,p_pay_plan          => p_pay_plan
                                    ,p_grade_or_level    => p_grade_or_level
                                    ,p_step_or_rate      => p_step_or_rate
                                    ,p_effective_date    => p_effective_date
                                    ,p_PT_value          => l_PT_value
                                    ,p_PT_eff_start_date => l_PT_eff_start_date
                                    ,p_PT_eff_end_date   => l_PT_eff_end_date);

   hr_utility.set_location('l_PT_value ...'|| to_char(l_PT_value),5);
   ghr_pay_calc.get_pay_table_value (p_user_table_id     => p_user_table_id
                                    ,p_pay_plan          => p_pay_plan
                                    ,p_grade_or_level    => p_grade_or_level
                                    ,p_step_or_rate      => p_step_or_rate
                                    ,p_effective_date    => (l_PT_eff_start_date - 1)
                                    ,p_PT_value          => l_PT_o_value
                                    ,p_PT_eff_start_date => l_PT_o_eff_start_date
                                    ,p_PT_eff_end_date   => l_PT_o_eff_end_date);

   hr_utility.set_location('l_PT_o_value ...'|| to_char(l_PT_o_value),5);
   l_SPT_value   := ghr_pay_calc.get_standard_pay_table_value (p_pay_plan  => p_pay_plan
                                ,p_grade_or_level => p_grade_or_level
                                ,p_step_or_rate   => p_step_or_rate
                                ,p_effective_date => p_effective_date);

   hr_utility.set_location('l_SPT_value ...'|| to_char(l_SPT_value),5);
   l_SPT_o_value  := ghr_pay_calc.get_standard_pay_table_value (p_pay_plan  => p_pay_plan
                                ,p_grade_or_level => p_grade_or_level
                                ,p_step_or_rate   => p_step_or_rate
                                ,p_effective_date => (l_PT_eff_start_date -1) );

   hr_utility.set_location('l_SPT_o_value ...'|| to_char(l_SPT_o_value),5);

   l_A := l_PT_value  - l_PT_o_value;
   hr_utility.set_location('l_A...'|| to_char(l_A),5);
   l_B := l_SPT_value - l_SPT_o_value;
   hr_utility.set_location('l_B...'|| to_char(l_B),5);

   if l_A = l_B then
      lesser_amt := l_A;
   elsif l_A > l_B then
      lesser_amt := l_B;
   else
      lesser_amt := l_A;
   end if;
   hr_utility.set_location('lesser_amt...'|| to_char(lesser_amt),5);

   new_adj_basic_pay := p_cur_adj_basic_pay + lesser_amt;
   new_locality_adj  := new_adj_basic_pay - p_new_basic_pay;

   p_new_adj_basic_pay := new_adj_basic_pay;
   p_new_locality_adj  := new_locality_adj;

   hr_utility.set_location('new_adj_basic_pay...'|| to_char(new_adj_basic_pay),5);
   hr_utility.set_location('new_locality_adj...'|| to_char(new_locality_adj),5);

   hr_utility.set_location('Leaving ...'|| l_proc,5);

 EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
     p_new_adj_basic_pay    := NULL;
     p_new_locality_adj     := NULL;
   RAISE;

end get_locality_adj_894_PRDM_GS;

PROCEDURE get_locality_adj_894_PRDM_GM
             (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
             ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
             ,p_new_std_relative_rate OUT NOCOPY NUMBER
             ,p_new_adj_basic_pay OUT NOCOPY NUMBER
             ,p_new_locality_adj  OUT NOCOPY NUMBER) IS

l_std_user_table_id     NUMBER;
l_user_table_id         NUMBER;
l_user_table_name            pay_user_tables.user_table_name%type;
l_adjustment_percentage      ghr_locality_pay_areas_f.adjustment_percentage%TYPE;
l_new_std_relative_rate NUMBER;


l_grade                 VARCHAR2(30);
l_PT_eff_start_date     DATE;
l_7dp                   NUMBER;

l_std_min               NUMBER;
l_std_max               NUMBER;

l_dummy_step            VARCHAR2(30);
l_dummy_date            DATE;
l_new_basic_pay         NUMBER;

l_new_ret_basic_pay     NUMBER;
l_old_ret_basic_pay     NUMBER;
l_A                     NUMBER;
l_B                     NUMBER;
lesser_amt              NUMBER;
new_adj_basic_pay       NUMBER;
new_locality_adj        NUMBER;

l_proc                  VARCHAR2(30) := '894_PRDM_GM';

CURSOR get_std_user_table_id IS
  SELECT utb.user_table_id
  FROM   pay_user_tables  utb
  WHERE utb.user_table_name = ghr_pay_calc.l_standard_table_name;

BEGIN
   hr_utility.set_location('Entering ...'|| l_proc,5);
  -- First get the id of standard pay table for later use
  FOR c_rec IN get_std_user_table_id LOOP
    l_std_user_table_id  := c_rec.user_table_id;
  END LOOP;

  IF p_retained_grade.grade_or_level IS NULL THEN
     l_grade         := p_pay_calc_data.grade_or_level;
     l_user_table_id := p_pay_calc_data.user_table_id;
  ELSE
     l_grade         := p_retained_grade.grade_or_level;
     l_user_table_id := p_retained_grade.user_table_id;
  END IF;

  l_user_table_name        := get_user_table_name(l_user_table_id);
  l_adjustment_percentage  := get_lpa_percentage
                                           (p_pay_calc_data.duty_station_id
                                           ,p_pay_calc_data.effective_date);


  -- Get the 7 dp figure as calculated in the 6 step rule!
    ghr_pc_basic_pay.get_basic_pay_SAL894_6step(p_pay_calc_data
                                      ,p_retained_grade
                                      ,'POSITION'
                                      ,l_new_basic_pay
                                      ,l_PT_eff_start_date
                                      ,l_7dp);
  --
  l_A  := l_new_basic_pay - p_pay_calc_data.current_basic_pay;

  ghr_pc_basic_pay.get_min_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_std_min
                         ,l_dummy_date
                         ,l_dummy_date);
  --
  ghr_pc_basic_pay.get_max_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,l_PT_eff_start_date
                         ,l_dummy_step
                         ,l_std_max
                         ,l_dummy_date
                         ,l_dummy_date);

  l_new_ret_basic_pay           := l_std_min + ROUND((l_std_max - l_std_min) * l_7dp );
  l_new_std_relative_rate       := l_new_ret_basic_pay;
  p_new_std_relative_rate       := l_new_ret_basic_pay;
  --
  --
  ghr_pc_basic_pay.get_min_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,(l_PT_eff_start_date - 1)
                         ,l_dummy_step
                         ,l_std_min
                         ,l_dummy_date
                         ,l_dummy_date);
  --
  ghr_pc_basic_pay.get_max_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,(l_PT_eff_start_date - 1)
                         ,l_dummy_step
                         ,l_std_max
                         ,l_dummy_date
                         ,l_dummy_date);

  l_old_ret_basic_pay := l_std_min + ROUND((l_std_max - l_std_min) * l_7dp );

  l_B                 := l_new_ret_basic_pay - l_old_ret_basic_pay;

  if l_A = l_B then
     lesser_amt := l_A;
  elsif l_A > l_B then
     lesser_amt := l_B;
  else
     lesser_amt := l_A;
  end if;

   new_adj_basic_pay := p_pay_calc_data.current_adj_basic_pay + lesser_amt;
   new_locality_adj  := new_adj_basic_pay - l_new_basic_pay;

   l_new_std_relative_rate := l_new_std_relative_rate +
                                   ROUND(l_new_std_relative_rate *
                                          (NVL(l_adjustment_percentage,0)/100),0);

   IF l_new_std_relative_rate > new_adj_basic_pay THEN
      new_adj_basic_pay     := l_new_std_relative_rate;
      new_locality_adj      := new_adj_basic_pay - l_new_basic_pay;
   ELSIF  (l_new_basic_pay > new_adj_basic_pay)  AND
      (l_user_table_name <> ghr_pay_calc.l_standard_table_name) THEN
          new_adj_basic_pay := l_new_basic_pay;
          new_locality_adj  := 0;
   END IF;

   p_new_adj_basic_pay := new_adj_basic_pay;
   p_new_locality_adj  := new_locality_adj;
   hr_utility.set_location('Leaving ...'|| l_proc,5);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
     p_new_adj_basic_pay    := NULL;
     p_new_locality_adj     := NULL;
     RAISE;
END;

                                                                                          --AVR
--------------------------- <get_open_pay_table_values> ------------------------------------------
PROCEDURE get_open_pay_table_values (p_user_table_id     IN  NUMBER
                             ,p_pay_plan          IN  VARCHAR2
                             ,p_grade_or_level    IN  VARCHAR2
                             ,p_effective_date    IN  DATE
                             ,p_row_high          OUT NOCOPY NUMBER
                             ,p_row_low           OUT NOCOPY NUMBER) IS
--
l_proc              varchar2(50) := 'get_open_pay_table_values';
l_row_high          NUMBER;
l_row_low           NUMBER;
l_record_found      BOOLEAN := FALSE;
--
-- Go and get the basic pay from the given pay table at the given grade or level
-- and step
-- NOTE:
--       column    => Pay Plan ||'-'|| Grade or Level
--
CURSOR cur_pay IS
  SELECT max(urw.ROW_HIGH_RANGE) ROW_HIGH_RANGE
        ,min(urw.ROW_LOW_RANGE_OR_NAME) ROW_LOW_RANGE_OR_NAME
  FROM   pay_user_column_instances_f cin
        ,pay_user_rows_f             urw
        ,pay_user_columns            col
  WHERE col.user_table_id = p_user_table_id
  AND   col.user_column_name = p_pay_plan||'-'||p_grade_or_level
  AND   urw.user_table_id = p_user_table_id
  AND   cin.user_row_id = urw.user_row_id
  AND   cin.user_column_id = col.user_column_id
  AND   NVL(p_effective_date,TRUNC(SYSDATE))
        BETWEEN urw.effective_start_date AND urw.effective_end_date
  AND   NVL(p_effective_date,TRUNC(SYSDATE))
        BETWEEN cin.effective_start_date AND cin.effective_end_date;
BEGIN
  hr_utility.set_location('Entering ...'|| l_proc,5);
  FOR cur_pay_rec IN cur_pay LOOP
    l_row_high          := ROUND(cur_pay_rec.ROW_HIGH_RANGE,2);
    l_row_low           := ROUND(cur_pay_rec.ROW_LOW_RANGE_OR_NAME,2);
    l_record_found      := TRUE;
    --
  hr_utility.set_location('Record Found ...'|| l_proc,10);
    --
  END LOOP;
  --
  IF NOT l_record_found THEN
    p_row_high          := null;
    p_row_low           := null;
  ELSE
    p_row_high          := l_row_high;
    p_row_low           := l_row_low;
  END IF;
  hr_utility.set_location('Leaving ...'|| l_proc,20);
--

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
      p_row_high          := NULL;
      p_row_low           := NULL;
      RAISE;
END get_open_pay_table_values;

FUNCTION get_pay_basis(
				p_effective_date IN ghr_pa_requests.effective_date%type,
				p_pa_request_id IN ghr_pa_requests.pa_request_id%type,
				p_person_id	IN ghr_pa_requests.person_id%type
				) RETURN ghr_pa_requests.from_pay_basis%type
IS
 l_asg_ei_data         per_assignment_extra_info%rowtype;
 l_prd per_assignment_extra_info.aei_information6%type;
 l_dummy VARCHAR2(30);
 l_assignment_id per_assignments_f.assignment_id%type;
 l_from_position_id ghr_pa_requests.from_position_id%type;
 l_from_pay_basis ghr_pa_requests.from_pay_basis%type;
 l_pos_ei_grade_data   per_position_extra_info%rowtype;

CURSOR get_asgn_pos(c_person_id IN ghr_pa_requests.person_id%type, c_effective_date IN ghr_pa_requests.effective_date%type) IS
   SELECT paf.assignment_id, paf.position_id
   FROM per_assignments_f paf
   WHERE paf.person_id = c_person_id
   AND trunc(nvl(c_effective_date,sysdate))between paf.effective_start_date and paf.effective_end_date
   AND paf.primary_flag = 'Y'
   AND paf.assignment_type <> 'B';

BEGIN
	-- Get From assignment id and position id using person_id and effective date
	FOR ctr_get_asgn_pos IN get_asgn_pos(p_person_id,p_effective_date) LOOP
		l_assignment_id :=  ctr_get_asgn_pos.assignment_id;
		l_from_position_id := ctr_get_asgn_pos.position_id;
	END LOOP;

-- Get Assignment extra info records
	IF l_assignment_id IS NOT NULL THEN
		ghr_pa_requests_pkg.get_SF52_asg_ddf_details
                     (p_assignment_id         => l_assignment_id
                     ,p_date_effective        => p_effective_date
                     ,p_tenure                => l_dummy
                     ,p_annuitant_indicator   => l_dummy
                     ,p_pay_rate_determinant  => l_prd
                     ,p_work_schedule         => l_dummy
                     ,p_part_time_hours       => l_dummy);
	END IF;

	-- If PRD In 'A','B','E','F','U','V'
	IF l_prd IN ('A','B','E','F','U','V') THEN
		-- If PRD in 'A','B','E','F' and having temporary promotion step, get from position extra info
		IF l_prd IN ('A','B','E','F') AND
			   ghr_pa_requests_pkg.temp_step_true(p_pa_request_id) THEN
				   ghr_history_fetch.fetch_positionei(
						p_position_id      => l_from_position_id,
						p_information_type => 'GHR_US_POS_VALID_GRADE',
						p_date_effective   => nvl(p_effective_date,trunc(sysdate)),
						p_pos_ei_data      => l_pos_ei_grade_data);
			   l_from_pay_basis := l_pos_ei_grade_data.poei_information6;
	    ELSE
			   l_from_pay_basis      :=   ghr_pa_requests_pkg.get_upd34_pay_basis
									   (p_person_id      => p_person_id
									   ,p_position_id    => l_from_position_id
									   ,p_prd            => l_prd
									   ,p_noa_code       => null
									   ,p_pa_request_id  => null
									   ,p_effective_date => nvl(p_effective_date,trunc(sysdate)));
		END IF;
	 -- If PRD not in 'A','B','E','F','U','V', get from position extra info
	 ELSE
			ghr_history_fetch.fetch_positionei(
						p_position_id      => l_from_position_id,
						p_information_type => 'GHR_US_POS_VALID_GRADE',
						p_date_effective   => nvl(p_effective_date,trunc(sysdate)),
						p_pos_ei_data      => l_pos_ei_grade_data);
			l_from_pay_basis := l_pos_ei_grade_data.poei_information6;
	END IF;
	return l_from_pay_basis;
EXCEPTION
	WHEN OTHERS THEN
		return '-1';
END get_pay_basis;

--------------------------- <get_locality_894_itpay> ------------------------------------------
PROCEDURE get_locality_894_itpay
             (p_pay_calc_data      IN  ghr_pay_calc.pay_calc_in_rec_type
             ,p_retained_grade     IN  ghr_pay_calc.retained_grade_rec_type
             ,p_new_basic_pay      IN  NUMBER
             ,p_GM_unadjusted_rate OUT NOCOPY NUMBER
             ,p_new_adj_basic_pay  OUT NOCOPY NUMBER
             ,p_new_locality_adj   OUT NOCOPY NUMBER) IS

l_std_user_table_id     NUMBER;
l_adjustment_percentage ghr_locality_pay_areas_f.adjustment_percentage%TYPE;

l_grade                 VARCHAR2(30);

l_std_min               NUMBER;
l_std_max               NUMBER;
l_std_min_old           NUMBER;
l_std_max_old           NUMBER;

l_dummy_step            VARCHAR2(30);
l_dummy_date            DATE;
l_effective_start_date  DATE;
l_effective_end_date    DATE;

new_adj_basic_pay       NUMBER;
new_locality_adj        NUMBER;

l_B1                    NUMBER;
l_B2                    NUMBER;
l_B3                    NUMBER;
l_B4                    NUMBER;
l_B5                    NUMBER;
l_B6                    NUMBER;
l_B7                    NUMBER;
l_B8                    NUMBER;

l_proc                  VARCHAR2(30) := 'GMIT_894';

CURSOR get_std_user_table_id IS
  SELECT utb.user_table_id
  FROM   pay_user_tables  utb
  WHERE utb.user_table_name = ghr_pay_calc.l_standard_table_name;

----
  l_assignment_id        per_assignments_f.assignment_id%type;
  l_value                varchar2(60);
  l_multi_error_flag     BOOLEAN;
  l_gm_unadjd_basic_pay  Number;

   CURSOR get_asgn_pos (c_person_id      IN ghr_pa_requests.person_id%type,
                        c_effective_date IN ghr_pa_requests.effective_date%type)
   IS
   SELECT paf.assignment_id
   FROM per_assignments_f paf
   WHERE paf.person_id = c_person_id
   AND trunc(nvl(c_effective_date,sysdate))between paf.effective_start_date and paf.effective_end_date
   AND paf.primary_flag = 'Y'
   AND paf.assignment_type <> 'B';
----
BEGIN
   hr_utility.set_location('Entering ...'|| l_proc,5);
   g_gm_unadjd_basic_pay := NULL;
   gm_unadjusted_pay_flg := NULL;
  -- First get the id of standard pay table for later use
  FOR c_rec IN get_std_user_table_id LOOP
    l_std_user_table_id  := c_rec.user_table_id;
  END LOOP;

  IF p_retained_grade.grade_or_level IS NULL THEN
     l_grade         := p_pay_calc_data.grade_or_level;
  ELSE
     l_grade         := p_retained_grade.grade_or_level;
  END IF;

  l_adjustment_percentage  := get_lpa_percentage
                                           (p_pay_calc_data.duty_station_id
                                           ,p_pay_calc_data.effective_date);

  -- Get From assignment id and position id using person_id and effective date
  FOR ctr_get_asgn_pos IN get_asgn_pos(p_pay_calc_data.person_id,(p_pay_calc_data.effective_date - 1)) LOOP
      l_assignment_id :=  ctr_get_asgn_pos.assignment_id;
  END LOOP;

  --
  -- Fetch the value Unadjusted Basic pay.  The very first time user will enter it.
  --
    begin

       ghr_api.retrieve_element_entry_value (p_element_name    => 'Unadjusted Basic Pay'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => l_assignment_id
                               ,p_effective_date        => (p_pay_calc_data.effective_date - 1)
                               ,p_value                 => l_value
                               ,p_multiple_error_flag   => l_multi_error_flag);
       l_gm_unadjd_basic_pay := to_number(l_value);
       if l_gm_unadjd_basic_pay is null or l_gm_unadjd_basic_pay = 0 then
          gm_unadjusted_pay_flg := 'Y';
          hr_utility.set_location('Unadjusted Basic Pay is zero or null ' || sqlerrm(sqlcode),25);
          hr_utility.set_message(8301,'GHR_38843_NO_GM_UNADJUST');
          hr_utility.raise_error;
       end if;
    exception
        when others then
          gm_unadjusted_pay_flg := 'Y';
	  hr_utility.set_location('Error in fetching of Unadjusted Basic Pay ' || sqlerrm(sqlcode),25);
          hr_utility.set_message(8301,'GHR_38843_NO_GM_UNADJUST');
          hr_utility.raise_error;
    end;

  --
  -- Present Year values.
  --
  ghr_pc_basic_pay.get_min_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,p_pay_calc_data.effective_date
                         ,l_dummy_step
                         ,l_std_min
                         ,l_effective_start_date
                         ,l_effective_end_date);
  --
  ghr_pc_basic_pay.get_max_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,p_pay_calc_data.effective_date
                         ,l_dummy_step
                         ,l_std_max
                         ,l_effective_start_date
                         ,l_effective_end_date);

  -- Previous Year values.
  --
  ghr_pc_basic_pay.get_min_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,(l_effective_start_date - 1)
                         ,l_dummy_step
                         ,l_std_min_old
                         ,l_dummy_date
                         ,l_dummy_date);
  --
  ghr_pc_basic_pay.get_max_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,(l_effective_start_date - 1)
                         ,l_dummy_step
                         ,l_std_max_old
                         ,l_dummy_date
                         ,l_dummy_date);

  l_B1                := l_gm_unadjd_basic_pay - l_std_min_old;
  l_B2                := l_std_max_old - l_std_min_old;
  l_B3                := TRUNC( (l_B1/l_B2) ,7);
  l_B4                := l_std_max - l_std_min;
  l_B5                := CEIL((l_B3 * l_B4));
  l_B6                := l_B5 + l_std_min;
  l_B7                := ROUND(l_B6 * (NVL(l_adjustment_percentage,0)/100),0);
  l_B8                := l_B6 + l_B7;
  new_locality_adj    := l_B8 - p_new_basic_pay;
  new_adj_basic_pay   := p_new_basic_pay + new_locality_adj;

  p_GM_unadjusted_rate  := l_B6;
  g_gm_unadjd_basic_pay := l_B6;
  p_new_adj_basic_pay   := new_adj_basic_pay;
  p_new_locality_adj    := new_locality_adj;
  hr_utility.set_location('Leaving ...'|| l_proc,5);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
     p_GM_unadjusted_rate :=NULL;
     p_new_adj_basic_pay  :=NULL;
     p_new_locality_adj   :=NULL;
     hr_utility.set_location('Leaving.... ' || l_proc,6);
     RAISE;
END get_locality_894_itpay;

--------------------------- <get_locality_892_itpay> ------------------------------------------
PROCEDURE get_locality_892_itpay
             (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
             ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
             ,p_new_basic_pay     IN  NUMBER
             ,p_new_adj_basic_pay OUT NOCOPY NUMBER
             ,p_new_locality_adj  OUT NOCOPY NUMBER) IS

l_std_user_table_id     NUMBER;
l_user_table_id         NUMBER;
l_adjustment_percentage ghr_locality_pay_areas_f.adjustment_percentage%TYPE;

l_grade                 VARCHAR2(30);

l_std_min               NUMBER;
l_std_max               NUMBER;
l_it_min                NUMBER;
l_it_max                NUMBER;

l_dummy_step            VARCHAR2(30);
l_dummy_date            DATE;
l_effective_start_date  DATE;
l_effective_end_date    DATE;

new_adj_basic_pay       NUMBER;
new_locality_adj        NUMBER;

l_C1                    NUMBER;
l_C2                    NUMBER;
l_C3                    NUMBER;
l_C4                    NUMBER;
l_C5                    NUMBER;
l_C6                    NUMBER;
l_dummy_number          NUMBER;

l_GM_unadjusted_rate    NUMBER;
l_proc                  VARCHAR2(30) := 'GMIT_892';

CURSOR get_std_user_table_id IS
  SELECT utb.user_table_id
  FROM   pay_user_tables  utb
  WHERE utb.user_table_name = ghr_pay_calc.l_standard_table_name;

----
  l_assignment_id        per_assignments_f.assignment_id%type;
  l_value                varchar2(60);
  l_multi_error_flag     BOOLEAN;
  l_gm_unadjd_basic_pay  Number;

   CURSOR get_asgn_pos (c_person_id      IN ghr_pa_requests.person_id%type,
                        c_effective_date IN ghr_pa_requests.effective_date%type)
   IS
   SELECT paf.assignment_id
   FROM per_assignments_f paf
   WHERE paf.person_id = c_person_id
   AND trunc(nvl(c_effective_date,sysdate))between paf.effective_start_date and paf.effective_end_date
   AND paf.primary_flag = 'Y'
   AND paf.assignment_type <> 'B';
----
BEGIN
   hr_utility.set_location('Entering ...'|| l_proc,5);
   g_gm_unadjd_basic_pay := NULL;
   gm_unadjusted_pay_flg := NULL;
  -- First get the id of standard pay table for later use
  FOR c_rec IN get_std_user_table_id LOOP
    l_std_user_table_id  := c_rec.user_table_id;
  END LOOP;

  IF p_retained_grade.grade_or_level IS NULL THEN
     l_grade         := p_pay_calc_data.grade_or_level;
     l_user_table_id := p_pay_calc_data.user_table_id;
  ELSE
     l_grade         := p_retained_grade.grade_or_level;
     l_user_table_id := p_retained_grade.user_table_id;
  END IF;

  l_adjustment_percentage  := get_lpa_percentage
                                           (p_pay_calc_data.duty_station_id
                                           ,p_pay_calc_data.effective_date);

    -- Get From assignment id and position id using person_id and effective date
  FOR ctr_get_asgn_pos IN get_asgn_pos(p_pay_calc_data.person_id,(p_pay_calc_data.effective_date - 1)) LOOP
      l_assignment_id :=  ctr_get_asgn_pos.assignment_id;
  END LOOP;

  --
  -- Fetch the value Unadjusted Basic pay.  The very first time user will enter it.
  --
    begin

       ghr_api.retrieve_element_entry_value (p_element_name    => 'Unadjusted Basic Pay'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => l_assignment_id
                               ,p_effective_date        => (p_pay_calc_data.effective_date - 1)
                               ,p_value                 => l_value
                               ,p_multiple_error_flag   => l_multi_error_flag);
       l_gm_unadjd_basic_pay := to_number(l_value);
       if l_gm_unadjd_basic_pay is null or l_gm_unadjd_basic_pay = 0 then
          gm_unadjusted_pay_flg := 'Y';
          hr_utility.set_location('Unadjusted Basic Pay is zero or null ' || sqlerrm(sqlcode),25);
          hr_utility.set_message(8301,'GHR_38843_NO_GM_UNADJUST');
          hr_utility.raise_error;
       end if;
    exception
        when others then
          gm_unadjusted_pay_flg := 'Y';
          hr_utility.set_location('Error in fetching of Unadjusted Basic Pay ' || sqlerrm(sqlcode),25);
          hr_utility.set_message(8301,'GHR_38843_NO_GM_UNADJUST');
          hr_utility.raise_error;
    end;
  --
  -- Present Year values.
  --
  ghr_pc_basic_pay.get_min_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,p_pay_calc_data.effective_date
                         ,l_dummy_step
                         ,l_std_min
                         ,l_effective_start_date
                         ,l_effective_end_date);
  --
  ghr_pc_basic_pay.get_max_pay_table_value(l_std_user_table_id
                         ,'GS'
                         ,l_grade
                         ,p_pay_calc_data.effective_date
                         ,l_dummy_step
                         ,l_std_max
                         ,l_effective_start_date
                         ,l_effective_end_date);

  -- Present Year values.
  --
  ghr_pc_basic_pay.get_min_pay_table_value(l_user_table_id
                         ,'GS'
                         ,l_grade
                         ,p_pay_calc_data.effective_date
                         ,l_dummy_step
                         ,l_it_min
                         ,l_dummy_date
                         ,l_dummy_date);
  --
  ghr_pc_basic_pay.get_max_pay_table_value(l_user_table_id
                         ,'GS'
                         ,l_grade
                         ,p_pay_calc_data.effective_date
                         ,l_dummy_step
                         ,l_it_max
                         ,l_dummy_date
                         ,l_dummy_date);

  l_C1                := CEIL((l_it_max - l_it_min) / 9);
  l_C2                := p_pay_calc_data.current_basic_pay + l_C1;
  l_C3                := CEIL((l_std_max - l_std_min) / 9);
  l_C4                := l_gm_unadjd_basic_pay + l_C3;
  l_C5                := l_C4 + ROUND(l_C4 * (NVL(l_adjustment_percentage,0)/100),0);
  l_C6                := l_C5 - l_C2;
  new_locality_adj    := l_C6;
  new_adj_basic_pay   := l_C5;

  g_gm_unadjd_basic_pay := l_C4;

  p_new_adj_basic_pay := new_adj_basic_pay;
  p_new_locality_adj  := new_locality_adj;
  hr_utility.set_location('Leaving ...'|| l_proc,5);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
       p_new_adj_basic_pay := NULL;
       p_new_locality_adj  := NULL;
   hr_utility.set_location('Leaving.... ' || l_proc,6);
   RAISE;
END get_locality_892_itpay;

-- FWFA Changes. Created procedures get_special_pay_table_value, special_rate_pay_calc
-- Create function fwfa_pay_calc
FUNCTION fwfa_pay_calc(p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                      ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type)
RETURN BOOLEAN IS
   CURSOR cur_ppl(p_pay_plan VARCHAR2) IS
   SELECT 1
   FROM   ghr_pay_plans ppl
   WHERE  ppl.pay_plan = p_pay_plan
   AND    ppl.equivalent_pay_plan = 'GS';

   CURSOR cur_ppl_fw(p_pay_plan VARCHAR2) IS --5218445
   SELECT 1
   FROM   ghr_pay_plans ppl
   WHERE  ppl.pay_plan = p_pay_plan
   AND    ppl.equivalent_pay_plan = 'FW';

   l_pay_plan          VARCHAR2(30);
   l_user_table_id     pay_user_tables.user_table_id%type;
   l_user_table_name   pay_user_tables.user_table_name%type;
   -- Bug 4695312
   l_gs_equivalent       BOOLEAN;
BEGIN
    l_gs_equivalent := FALSE;
    -- Removed the PRD comparison. Modified it with Pay Table Comparison
    IF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F','U','V') THEN  -- 5218445
        IF p_retained_grade.temp_step is not null AND
            p_pay_calc_data.noa_code <> '740' then
            l_user_table_id := p_pay_calc_data.user_table_id;
            l_pay_plan  := p_pay_calc_data.pay_plan;
        ELSE
            l_user_table_id := p_retained_grade.user_table_id;
            l_pay_plan := p_retained_grade.pay_plan;
        END IF;
    ELSE
        l_user_table_id := p_pay_calc_data.user_table_id;
        l_pay_plan := p_pay_calc_data.pay_plan;
    END IF;

    FOR cur_ppl_fw_rec IN cur_ppl_fw(l_pay_plan)
    LOOP
        IF p_pay_calc_data.pay_rate_determinant IN ('6','E','F') THEN
            g_fwfa_pay_calc_flag := TRUE;
            g_fw_equiv_pay_plan  := TRUE;
            RETURN TRUE;
        END IF;
    END LOOP;


    IF  p_pay_calc_data.effective_date >= to_date('2005/05/01','YYYY/MM/DD') THEN
        l_user_table_name :=  ghr_pay_calc.get_user_table_name(l_user_table_id);
        --
        FOR cur_ppl_rec IN cur_ppl(l_pay_plan)
        LOOP
            l_gs_equivalent := TRUE;
        END LOOP;
        -- Bug#4695312  For Retained Pay PRDs don't verify position pay table.
        -- IF the pay plan is GS Equivalent, Return TRUE.
	--Bug# 9255822 added PRD Y
        IF p_pay_calc_data.pay_rate_determinant IN ('3','4','J','K','U','V','R','Y') THEN --bug#4999237
            IF l_gs_equivalent THEN
                g_fwfa_pay_calc_flag := TRUE;
                RETURN TRUE;
            ELSE
                g_fwfa_pay_calc_flag := FALSE;
                RETURN FALSE;
            END IF;
        ELSE
            IF l_user_table_name NOT IN (ghr_pay_calc.l_standard_table_name,ghr_pay_calc.l_spl491_table_name) AND
               l_gs_equivalent THEN
                g_fwfa_pay_calc_flag := TRUE;
                RETURN TRUE;
            ELSE
                g_fwfa_pay_calc_flag := FALSE;
                RETURN FALSE;
            END IF;
        END IF;
    ELSE
        g_fwfa_pay_calc_flag := FALSE;
        RETURN FALSE;
    END IF;
END fwfa_pay_calc;

PROCEDURE get_special_pay_table_value (p_pay_plan          IN VARCHAR2
                                         ,p_grade_or_level     IN VARCHAR2
                                         ,p_step_or_rate       IN VARCHAR2
                                         ,p_user_table_id      IN NUMBER
                                         ,p_effective_date     IN DATE
                                         ,p_pt_value          OUT NOCOPY NUMBER
                                         ,p_PT_eff_start_date OUT NOCOPY DATE
                                         ,p_PT_eff_end_date   OUT NOCOPY DATE
                                         ,p_pp_grd_exists       OUT NOCOPY BOOLEAN) IS
        --
        l_PT_value          NUMBER;
        l_PT_eff_start_date DATE;
        l_PT_eff_end_date   DATE;
        l_record_found      BOOLEAN := FALSE;

        --
        -- Go and get the basic pay from the given pay table at the given grade or level
        -- and step
        -- NOTE: column => Step or Rate
        --       row    => Pay Plan ||'-'|| Grade or Level
        --
        CURSOR cur_pay IS
          SELECT cin.value basic_pay
                ,cin.effective_start_date
                ,cin.effective_end_date
                ,col.user_column_name step
          FROM   pay_user_column_instances_f cin
                ,pay_user_rows_f             urw
                ,pay_user_columns            col
          WHERE col.user_table_id = p_user_table_id
         -- AND   col.user_column_name = p_step_or_rate
          AND   urw.user_table_id = p_user_table_id
           --Bug# 7046241 added decode for pay plan GP
          AND   urw.row_low_range_or_name = decode(p_pay_plan,'GP','GS',p_pay_plan)||'-'||p_grade_or_level
          AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN urw.effective_start_date AND urw.effective_end_date
          AND   cin.user_row_id = urw.user_row_id
          AND   cin.user_column_id = col.user_column_id
          AND   NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN cin.effective_start_date AND cin.effective_end_date;
        BEGIN
          FOR cur_pay_rec IN cur_pay LOOP
            l_record_found      := TRUE;
            IF cur_pay_rec.step = p_step_or_rate THEN
                l_PT_value          := cur_pay_rec.basic_pay;
                l_PT_eff_start_date := cur_pay_rec.effective_start_date;
                l_PT_eff_end_date   := cur_pay_rec.effective_end_date;
                --
                EXIT;
            END IF;
          END LOOP;
          --
          IF NOT l_record_found THEN
            p_pp_grd_exists := FALSE;
            p_pt_value    := NULL;
            p_pt_eff_start_date := NULL;
            p_pt_eff_end_date   := NULL;
          ELSE
            p_PT_value          := l_PT_value;
            p_PT_eff_start_date := l_PT_eff_start_date;
            p_PT_eff_end_date   := l_PT_eff_end_date;
            p_pp_grd_exists       := TRUE;
          END IF;

    EXCEPTION
        WHEN others THEN
            -- Reset IN OUT parameters and set OUT parameters
            p_PT_value           := NULL;
            p_PT_eff_start_date  := NULL;
            p_PT_eff_end_date    := NULL;
            p_pp_grd_exists        := NULL;
            RAISE;
            --
    END get_special_pay_table_value;

PROCEDURE special_rate_pay_calc(p_pay_calc_data     IN     ghr_pay_calc.pay_calc_in_rec_type
                               ,p_pay_calc_out_data OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type
                               ,p_retained_grade    IN OUT NOCOPY ghr_pay_calc.retained_grade_rec_type) IS

    l_new_prd               VARCHAR2(30);
    l_new_step              VARCHAR2(30);
    l_term_ret_pay_prd      BOOLEAN;
    l_pay_plan              VARCHAR2(5);
    l_default_pay_plan      VARCHAR2(5);
    l_step_or_rate          VARCHAR2(5);
    l_curr_step_or_rate      VARCHAR2(5);
    l_grade_or_level        VARCHAR2(5);
    l_pay_calc_process      VARCHAR2(1);
    l_dummy                 VARCHAR2(1);
    l_pt_value              NUMBER;
    l_locality_adj          NUMBER;
    l_basic_pay             NUMBER;
    l_adj_basic_pay         NUMBER;
    l_new_basic_pay         NUMBER;
    l_new_locality_adj      NUMBER;
    l_new_adj_basic_pay     NUMBER;
    l_increment             NUMBER;
    l_old_basic_pay         NUMBER;
    l_old_locality_adj      NUMBER;
    l_old_adj_basic_pay     NUMBER;
    l_adj_perc_factor       NUMBER(10,6);
    l_old_adj_perc_factor   NUMBER(10,6);
    l_new_special_rate      NUMBER; -- AC for Bug#5114467
    l_dummy_date            DATE;
    l_pt_eff_start_date     DATE;
    l_pt_eff_end_date       DATE;
    l_pp_grd_exists         BOOLEAN;
    l_rg_flag               BOOLEAN;
    l_leo_flag              BOOLEAN;
    l_ret_flag              BOOLEAN ;
    l_loc_rate_less_spl_rate BOOLEAN;
    l_user_table_name       pay_user_tables.user_table_name%type;
    l_default_pay_table     pay_user_tables.user_table_name%type;
    l_new_position_pay_table pay_user_tables.user_table_name%type;
    l_calculation_pay_table pay_user_tables.user_table_name%type;
    l_position_pay_table    pay_user_tables.user_table_name%type;
    l_retained_pay_table    pay_user_tables.user_table_name%type;
    l_user_table_id         pay_user_tables.user_table_id%type;
    l_default_table_id      pay_user_tables.user_table_id%type;
    l_calculation_pay_table_id pay_user_tables.user_table_id%type;
    l_position_pay_table_id pay_user_tables.user_table_id%type;

    l_adjustment_percentage ghr_locality_pay_areas_f.adjustment_percentage%type;

    l_old_special_rate  NUMBER;
    l_special_rate      NUMBER; --for bug 4999237
    l_gm_pay_plan       BOOLEAN;
    --Begin Bug 7046241
    l_gr_pay_plan       BOOLEAN;
    --End Bug 7046241

    CURSOR c_get_table_id(p_user_table_name VARCHAR2) IS
    SELECT utb.user_table_id user_table_id, utb.user_table_name user_table_name
    FROM   pay_user_tables  utb
    WHERE  utb.user_table_name = p_user_table_name;

------ Bug#5741977 start
    l_business_group_id     per_positions.organization_id%TYPE;

    CURSOR GET_GRADE_ID (v_pay_plan varchar2, v_grade_or_level varchar2) IS
    SELECT grd.grade_id  grade_id
    FROM per_grades grd,
         per_grade_definitions gdf
     WHERE  gdf.segment1 = v_pay_plan
    AND gdf.segment2 = v_grade_or_level
    AND grd.grade_definition_id = gdf.grade_definition_id
    AND grd.business_group_id = l_business_group_id;

    l_grade_id              NUMBER;
    l_fwfa_pay_plan_changed BOOLEAN;
------ Bug#5741977 end

   --  7046241
   l_pos_ei_valid_grade  per_position_extra_info%ROWTYPE;
      --  7046241

    --Bug# 9258929
    l_from_position_id ghr_pa_requests.from_position_id%type;
    l_from_pos_ind   VARCHAR2(30);
    l_to_pos_ind   VARCHAR2(30);
    l_equivalent_pay_plan ghr_pay_plans.equivalent_pay_plan%type;
    l_session               ghr_history_api.g_session_var_type;

    cursor pa_req_det(p_pa_request_id in number)
        is
	select from_position_id
	from   ghr_pa_requests
	where  pa_request_id = p_pa_request_id;

     cursor get_equi_pay_plan(p_pay_plan in varchar2)
         is
         select equivalent_pay_plan
         from   ghr_pay_plans
         where  pay_plan = p_pay_plan;

     cursor get_asgn_pos(c_person_id IN ghr_pa_requests.person_id%type,
                         c_effective_date IN ghr_pa_requests.effective_date%type)
         is
         select paf.position_id
         from per_assignments_f paf
         where paf.person_id = c_person_id
         and trunc(nvl(c_effective_date,sysdate))between paf.effective_start_date and paf.effective_end_date
         and paf.primary_flag = 'Y'
         and paf.assignment_type <> 'B';

     cursor get_pa_req_det(p_pa_request_id in number)
         is
         select from_position_id
         from   ghr_pa_requests
         where  pa_request_id = p_pa_request_id;
    -- Bug # 9258929

    PROCEDURE set_cpt_ppt_prd(p_leo_flag	    IN	BOOLEAN
                         ,p_rg_flag		    IN	BOOLEAN
                         ,p_pp_grd_exists	    IN	BOOLEAN
                         ,p_loc_rate_less_spl_rate  IN  BOOLEAN
                         ,p_prd                     IN  VARCHAR2
                         ,p_pt_value		    IN	NUMBER
                         ,p_special_rate_table      IN  VARCHAR2
                         ,p_calculation_pay_table   OUT NOCOPY VARCHAR2
                         ,p_position_pay_table      OUT NOCOPY VARCHAR2
                         ,p_retained_pay_table      OUT NOCOPY VARCHAR2
                         ,p_new_prd                 OUT NOCOPY VARCHAR2
                         ) IS
    BEGIN
        hr_utility.set_location('Inside set_cpt_ppt_prd',0);

        IF p_leo_flag THEN
            --Bug# 5635023 added PRD 7
            IF p_prd IN ('5', '6', '7') THEN
                IF p_pp_grd_exists AND p_pt_value IS NOT NULL THEN
                    IF p_loc_rate_less_spl_rate THEN
                        p_position_pay_table := p_special_rate_table;
                        p_new_prd            := '6';
                        p_calculation_pay_table := p_special_rate_table;
                        g_pay_table_upd_flag := FALSE;
                    ELSE
                        p_position_pay_table := p_special_rate_table;
                        p_new_prd            := '6';
                        p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
                        g_pay_table_upd_flag := FALSE;
                    END IF;
                ELSIF p_pp_grd_exists AND p_pt_value IS NULL THEN
                    p_position_pay_table := p_special_rate_table;
                    p_new_prd            := '6';
                    p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
                    g_pay_table_upd_flag := FALSE;
                ELSE
                    p_position_pay_table := ghr_pay_calc.l_spl491_table_name;
                    p_new_prd            := '6';
                    p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
                    g_pay_table_upd_flag := TRUE;
                END IF;
            ELSIF p_prd IN ('E','F') THEN
                IF p_pp_grd_exists AND p_pt_value IS NOT NULL THEN
                    IF p_loc_rate_less_spl_rate THEN
                        p_retained_pay_table := p_special_rate_table;
                        p_new_prd            := p_prd;
                        p_calculation_pay_table := p_special_rate_table;
      		            g_pay_table_upd_flag := FALSE;
                    ELSE
                        p_retained_pay_table := p_special_rate_table;
                        p_new_prd            := p_prd;
                        p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
      	    	        g_pay_table_upd_flag := FALSE;
                    END IF;
                ELSIF p_pp_grd_exists AND p_pt_value IS NULL THEN
                    p_retained_pay_table := p_special_rate_table;
                    p_new_prd            := p_prd;
                    p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
         		    g_pay_table_upd_flag := FALSE;
                ELSE
                    p_retained_pay_table := ghr_pay_calc.l_spl491_table_name;
                    p_new_prd            := p_prd;
                    p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
         		    g_pay_table_upd_flag := TRUE;
                END IF;
            ELSIF p_prd IN ('3','4','J','K','U','V','R','Y') THEN  --bug 4999237 -- Bug# 9255822 added PRD Y
                IF NOT(p_pp_grd_exists) THEN
                    p_position_pay_table := ghr_pay_calc.l_spl491_table_name;
                    p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
                    g_pay_table_upd_flag := TRUE;
                ELSE
                    p_position_pay_table := p_special_rate_table;
                    g_pay_table_upd_flag := FALSE;
                    p_calculation_pay_table := p_special_rate_table;
                END IF;
                IF p_pay_calc_data.pay_rate_determinant = '4' THEN
                    p_new_prd := 'J';
                ELSE
                   p_new_prd := p_prd;
                END IF;
            ELSIF p_prd IN ('0','A','B') THEN
                IF p_pp_grd_exists AND p_pt_value IS NOT NULL THEN
                    IF p_loc_rate_less_spl_rate THEN
                        p_position_pay_table := p_special_rate_table;
                        p_calculation_pay_table := p_special_rate_table;
             		    g_pay_table_upd_flag := FALSE;
                    ELSE
                        p_position_pay_table := p_special_rate_table;
                        p_new_prd            := p_prd;
                        p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
             		    g_pay_table_upd_flag := FALSE;
                    END IF;
                ELSIF p_pp_grd_exists AND p_pt_value IS NULL THEN
                    p_position_pay_table := p_special_rate_table;
                    p_new_prd            := p_prd;
                    p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
         		    g_pay_table_upd_flag := FALSE;
                ELSE
                    p_position_pay_table := ghr_pay_calc.l_spl491_table_name;
                    p_new_prd            := p_prd;
                    p_calculation_pay_table := ghr_pay_calc.l_spl491_table_name;
         		    g_pay_table_upd_flag := TRUE;
                END IF;
                IF p_prd = '0' THEN
                    p_new_prd := '6';
                ELSIF p_prd = 'A' THEN
                    p_new_prd := 'E';
                ELSIF p_prd = 'B' THEN
                    p_new_prd := 'F';
                END IF;
            END IF;
        ELSE -- NON LEO
            --Bug# 5635023 added PRD 7
            IF p_prd IN ('5', '6', '7') THEN
                IF p_pp_grd_exists AND p_pt_value IS NOT NULL THEN
                    IF p_loc_rate_less_spl_rate THEN
                        p_position_pay_table := p_special_rate_table;
                        p_new_prd            := '6';
                        p_calculation_pay_table := p_special_rate_table;
             		    g_pay_table_upd_flag := FALSE;
                    ELSE
                        p_position_pay_table := p_special_rate_table;
                        p_new_prd            := '0';
                        p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
             		    g_pay_table_upd_flag := FALSE;
                    END IF;
                ELSIF p_pp_grd_exists AND p_pt_value IS NULL THEN
                    p_position_pay_table := p_special_rate_table;
                    p_new_prd            := '0';
                    p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
         		    g_pay_table_upd_flag := FALSE;
                ELSE
                    p_position_pay_table := ghr_pay_calc.l_standard_table_name;
                    p_new_prd            := '0';
                    p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
         		    g_pay_table_upd_flag := TRUE;
                END IF;
            ELSIF p_prd IN ('E','F') THEN
                IF p_pp_grd_exists AND p_pt_value IS NOT NULL THEN
                    IF p_loc_rate_less_spl_rate THEN
                        p_retained_pay_table := p_special_rate_table;
                        p_new_prd            := p_prd;
                        p_calculation_pay_table := p_special_rate_table;
             		    g_pay_table_upd_flag := FALSE;
                    ELSE
                        p_retained_pay_table := p_special_rate_table;
                        IF p_prd = 'E' THEN
                            p_new_prd := 'A';
                        ELSIF p_prd = 'F' THEN
                            p_new_prd := 'B';
                        END IF;
                        p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
              		    g_pay_table_upd_flag := FALSE;
                    END IF;
                ELSIF p_pp_grd_exists AND p_pt_value IS NULL THEN
                    p_retained_pay_table := p_special_rate_table;
                    IF p_prd = 'E' THEN
                        p_new_prd := 'A';
                    ELSIF p_prd = 'F' THEN
                        p_new_prd := 'B';
                    END IF;
                    p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
         		    g_pay_table_upd_flag := FALSE;
                ELSE
                    p_retained_pay_table := ghr_pay_calc.l_standard_table_name;
                    IF p_prd = 'E' THEN
                        p_new_prd := 'A';
                    ELSIF p_prd = 'F' THEN
                        p_new_prd := 'B';
                    END IF;
                    p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
         		    g_pay_table_upd_flag := TRUE;
                END IF;
            ELSIF p_prd IN ('3','4','J','K','U','V','R','Y') THEN -- Bug# 9255822 added PRD Y
                IF NOT(p_pp_grd_exists) THEN
                    p_position_pay_table := ghr_pay_calc.l_standard_table_name;
                    g_pay_table_upd_flag := TRUE;
                    p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
                ELSE
                    p_position_pay_table := p_special_rate_table;
                    g_pay_table_upd_flag := FALSE;
                    p_calculation_pay_table := p_special_rate_table;
                END IF;
                IF p_pay_calc_data.pay_rate_determinant = '4' THEN
                    p_new_prd := 'J';
                ELSE
                   p_new_prd := p_prd;
                END IF;
            -- FWFA new change. Added the following condition to handle PRDs 0,A,B.
            ELSIF p_prd IN ('0','A','B') THEN
                IF p_pp_grd_exists AND p_pt_value IS NOT NULL THEN
                    IF p_loc_rate_less_spl_rate THEN
                        p_position_pay_table := p_special_rate_table;
                        IF p_prd = '0' THEN
                            p_new_prd := '6';
                        ELSIF p_prd = 'A' THEN
                            p_new_prd := 'E';
                        ELSIF p_prd = 'B' THEN
                            p_new_prd := 'F';
                        END IF;
                        p_calculation_pay_table := p_special_rate_table;
             		    g_pay_table_upd_flag := FALSE;
                    ELSE
                        p_position_pay_table := p_special_rate_table;
                        p_new_prd            := p_prd;
                        p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
             		    g_pay_table_upd_flag := FALSE;
                    END IF;
                ELSIF p_pp_grd_exists AND p_pt_value IS NULL THEN
                    p_position_pay_table := p_special_rate_table;
                    p_new_prd            := p_prd;
                    p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
         		    g_pay_table_upd_flag := FALSE;
                ELSE
                    p_position_pay_table := ghr_pay_calc.l_standard_table_name;
                    p_new_prd            := p_prd;
                    p_calculation_pay_table := ghr_pay_calc.l_standard_table_name;
         		    g_pay_table_upd_flag := TRUE;
                END IF;
            END IF;
        END IF;
        hr_utility.set_location('Leaving CPT PRD',10);
    END set_cpt_ppt_prd;

BEGIN

------ Bug#5741977 start
      l_business_group_id          := FND_PROFILE.value('PER_BUSINESS_GROUP_ID');
      l_fwfa_pay_plan_changed      := FALSE;
------ Bug#5741977 end
--



      if p_pay_calc_data.noa_family_code = 'APP'  then
        if p_pay_calc_data.pay_rate_determinant
            in ('2','C','M','P','R','S') then
            p_pay_calc_out_data.open_pay_fields := TRUE;
            hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
            hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
            raise ghr_pay_calc.unable_to_calculate;
        end if;
      end if;
---


    -- 1. Set the Pay related values depending on the Retained/Non-Retained Grade.
    hr_utility.set_location('PRD: '||p_pay_calc_data.pay_rate_determinant,20);
    IF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F','U','V') and
       p_retained_grade.temp_step is NULL THEN
        l_user_table_id := p_retained_grade.user_table_id;
        l_pay_plan      := p_retained_grade.pay_plan;
        l_grade_or_level:= p_retained_grade.grade_or_level;
        l_step_or_rate  := p_retained_grade.step_or_rate;
        l_rg_flag := TRUE;
    ELSE
        l_user_table_id := p_pay_calc_data.user_table_id;
        l_pay_plan      := p_pay_calc_data.pay_plan;
        l_grade_or_level:= p_pay_calc_data.grade_or_level;
	-- Added NOA Code 867 for the Bug#5621814
	IF p_pay_calc_data.noa_code IN ('867', '892','893')  OR
	   p_pay_calc_data.second_noa_code IN ('867', '892','893') THEN
	    l_step_or_rate  := p_pay_calc_data.current_step_or_rate;
	ELSE
	    l_step_or_rate  := p_pay_calc_data.step_or_rate;
	END IF;
    -- Bug#4701896
    IF p_retained_grade.temp_step IS NOT NULL THEN
        l_step_or_rate  := p_retained_grade.temp_step;
    END IF;
        l_rg_flag := FALSE;
    END IF;

    l_gm_pay_plan := FALSE;
    --Begin Bug 7046241
    l_gr_pay_plan := FALSE;
    --End Bug 7046241
    -- 2. Get the user table name into local variable
        l_user_table_name :=  ghr_pay_calc.get_user_table_name(l_user_table_id);
    hr_utility.set_location('user table name:' ||l_user_table_name,30);
    -- 3. Get the Locality Percentage Value
    l_adjustment_percentage := NVL(ghr_pay_calc.get_lpa_percentage(p_pay_calc_data.duty_station_id
                                                                  ,p_pay_calc_data.effective_date),0);
    hr_utility.set_location('l_adjustment_percentage ..' || to_char(l_adjustment_percentage),31);
    l_adj_perc_factor       := l_adjustment_percentage/100;
    hr_utility.set_location('l_adj_perc_factor ..' || to_char(l_adj_perc_factor),32);



    -- Check LEO Posiiton or NOT
    -- Bug#4709111 Modified p_pay_calc_data.grade_or_level to l_grade_or_level.
    -- Bug#5089732 Treat all the positions with pay plan GL as LEO Positions.
    IF (ghr_pay_calc.LEO_position (l_dummy
                    ,p_pay_calc_data.position_id
                    ,l_dummy
                    ,l_dummy
                    ,p_pay_calc_data.effective_date)
             AND l_grade_or_level between 03 and 10) OR
             l_pay_plan = 'GL' THEN
        l_leo_flag := TRUE;
        l_default_pay_table := ghr_pay_calc.l_spl491_table_name;
    ELSE
        l_leo_flag := FALSE;
        l_default_pay_table := ghr_pay_calc.l_standard_table_name;
    END IF;


     --Bug #5919700 For 890 action and GM Pay plan GS should be considered
      IF (p_pay_calc_data.noa_code = '890' OR p_pay_calc_data.second_noa_code = '890') AND
          p_pay_calc_data.pay_plan = 'GM' then
          l_default_pay_plan       := 'GS';
	  l_pay_plan               := 'GS';
          l_grade_id               := NULL;
          FOR get_grade_id_rec IN get_grade_id(l_default_pay_plan, l_grade_or_level)
          LOOP
              l_grade_id := get_grade_id_rec.grade_id;
              l_fwfa_pay_plan_changed   := TRUE;
              g_pay_table_upd_flag := TRUE;
              exit;
          END LOOP;
       END IF;


    -- Bug#5741977 - Set the default Pay Plan as GL as GS, GG are end dated in 0491 table.
    IF l_default_pay_table = ghr_pay_calc.l_spl491_table_name AND
       l_pay_plan IN ('GS','GG') AND
       p_pay_calc_data.effective_date >= to_date('2007/01/07','YYYY/MM/DD') THEN
       l_default_pay_plan := 'GL';
------ Bug#5741977 start
       l_grade_id         := null;
       FOR get_grade_id_rec IN get_grade_id(l_default_pay_plan, l_grade_or_level)
          LOOP
               l_grade_id              := get_grade_id_rec.grade_id;
               l_fwfa_pay_plan_changed := TRUE;
               exit;
       END LOOP;
------ Bug#5741977 End
    ELSE
       l_default_pay_plan := l_pay_plan;
    END IF;





    FOR table_id_rec in c_get_table_id(l_default_pay_table)
    LOOP
        l_default_table_id := table_id_rec.user_table_id;
    END LOOP;

    -- 4. Processing Employees On Retained Pay
    -- Bug# 9255822 added PRD Y
    IF p_pay_calc_data.pay_rate_determinant IN ('3','4','J','K','U','V','R','Y')
       AND NOT(l_pay_plan IN ('GR') AND p_pay_calc_data.pay_rate_determinant IN ('4'))  THEN --bug 4999237
       --Bug# 7518210,to skip this calc and moving to else part(i.e GM calc)added pay plan GR and PRD 4 condition
        -----Bug 4665119 ..Other than appointment and 894 for all other actions pay fields are to be open
        -----              Appointment already checked in the fwfa_pay_cal function.
        -----   Modified by AVR 17-OCT-2005
        -- Bug#5368848 Open the pay fields if the NOA Code is not 894.
	-- GPPA Update46. Added 890 in the NOT IN list.
        IF p_pay_calc_data.noa_code NOT IN ('894','890') then
            p_pay_calc_out_data.open_pay_fields := TRUE;
            hr_utility.set_message(8301, 'GHR_38254_NO_CALC_PRD');
            hr_utility.set_message_token('PRD',p_pay_calc_data.pay_rate_determinant);
            raise ghr_pay_calc.unable_to_calculate;
        END IF;
	--Bug# 9258929
	-- Get From assignment id and position id using person_id and effective date
	 ghr_history_api.get_g_session_var(l_session);
	IF l_session.noa_id_correct is null then
	  FOR ctr_get_asgn_pos IN get_asgn_pos(p_pay_calc_data.person_id,p_pay_calc_data.effective_date) LOOP
		l_from_position_id := ctr_get_asgn_pos.position_id;
	  END LOOP;
        ELSE
	  FOR c_get_pa_req_det IN get_pa_req_det(p_pa_request_id => p_pay_calc_data.pa_request_id)
          LOOP
                l_from_position_id :=c_get_pa_req_det.from_position_id;
          END LOOP;
        END IF;





	for c_equi_pay_plan in get_equi_pay_plan(p_pay_plan => l_pay_plan)
	loop
	   l_equivalent_pay_plan := c_equi_pay_plan.equivalent_pay_plan;
	end loop;

	l_from_pos_ind := ghr_pa_requests_pkg.get_personnel_system_indicator(l_from_position_id,p_pay_calc_data.effective_date);
	l_to_pos_ind   := ghr_pa_requests_pkg.get_personnel_system_indicator(nvl(p_pay_calc_data.position_id,l_from_position_id),p_pay_calc_data.effective_date);
	--Bug # 9258929

	-- Bug# 4866952 Added the new pay calculation method for Pay Adjustment actions
        -- Processed after 01-MAY-2005
        IF p_pay_calc_data.effective_date = TO_DATE('2005/05/01','YYYY/MM/DD') THEN
            l_new_basic_pay := p_pay_calc_data.current_adj_basic_pay;
            l_new_locality_adj := 0;
            l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
            get_special_pay_table_value (p_pay_plan          => l_pay_plan
                                    ,p_grade_or_level    => l_grade_or_level
                                    ,p_step_or_rate      => l_step_or_rate
                                    ,p_user_table_id     => l_user_table_id
                                    ,p_effective_date    => p_pay_calc_data.effective_date
                                    ,p_pt_value          => l_pt_value
                                    ,p_PT_eff_start_date => l_pt_eff_start_date
                                    ,p_PT_eff_end_date   => l_pt_eff_end_date
                                    ,p_pp_grd_exists       => l_pp_grd_exists );
            set_cpt_ppt_prd ( p_leo_flag	        	=> l_leo_flag
                             ,p_rg_flag		        	=> l_rg_flag
                             ,p_pp_grd_exists	        => l_pp_grd_exists
                             ,p_loc_rate_less_spl_rate  => NULL
                             ,p_prd                     => p_pay_calc_data.pay_rate_determinant
                             ,p_pt_value		        => l_pt_value
                             ,p_special_rate_table      => l_user_table_name
                             ,p_calculation_pay_table   => l_calculation_pay_table
                             ,p_position_pay_table      => l_position_pay_table
                             ,p_retained_pay_table      => l_retained_pay_table
                             ,p_new_prd                 => l_new_prd
                             );
        --Bug# 9258929
	ELSIF p_pay_calc_data.noa_code = '890'  and NVL(l_from_pos_ind,'00') <> '00'
	  and NVL(l_to_pos_ind,'00') = '00' and l_equivalent_pay_plan = 'GS' and NVL(l_step_or_rate,'@@') = '00' THEN
	       l_new_basic_pay := p_pay_calc_data.current_adj_basic_pay;
               l_new_locality_adj := 0;
               l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
	       get_special_pay_table_value (p_pay_plan          => l_pay_plan
                                           ,p_grade_or_level    => l_grade_or_level
                                           ,p_step_or_rate      => l_step_or_rate
                                           ,p_user_table_id     => l_user_table_id
                                           ,p_effective_date    => p_pay_calc_data.effective_date
                                           ,p_pt_value          => l_pt_value
                                           ,p_PT_eff_start_date => l_pt_eff_start_date
                                           ,p_PT_eff_end_date   => l_pt_eff_end_date
                                           ,p_pp_grd_exists     => l_pp_grd_exists );
               set_cpt_ppt_prd ( p_leo_flag	        	=> l_leo_flag
                                ,p_rg_flag		   => l_rg_flag
                                ,p_pp_grd_exists	   => l_pp_grd_exists
                                ,p_loc_rate_less_spl_rate  => NULL
                                ,p_prd                     => p_pay_calc_data.pay_rate_determinant
                                ,p_pt_value		   => l_pt_value
                                ,p_special_rate_table      => l_user_table_name
                                ,p_calculation_pay_table   => l_calculation_pay_table
                                ,p_position_pay_table      => l_position_pay_table
                                ,p_retained_pay_table      => l_retained_pay_table
                                ,p_new_prd                 => l_new_prd
                               );
     	--Bug # 9073576 modified as per the requirement
        ELSE--IF p_pay_calc_data.effective_date
          l_term_ret_pay_prd := FALSE;
          hr_utility.set_location('PAY ADJUSTMENT AS ON 08-JAN',7788);
          --CODE CHANGES DONE TO ATLER PAY CALC FOR BUG# 4999237...
          IF l_pay_plan = 'GM' THEN
             l_pay_plan := 'GS';
          --- Bug 5908487 changes...
             l_default_pay_plan := 'GS';
             l_gm_pay_plan := TRUE;
          --Begin Bug 7046241
          ELSIF l_pay_plan = 'GR' THEN
             l_pay_plan := 'GS';
             l_default_pay_plan := 'GS';
             l_gr_pay_plan := TRUE;
          --End Bug 7046241
          END IF;
          -- Get Current Years' Special Pay Table Value at step 10

	  hr_utility.set_location('Get Current Years Special Pay Table Value at step 10',7788);

	  get_special_pay_table_value (p_pay_plan          => l_pay_plan
                                      ,p_grade_or_level    => l_grade_or_level
                                      ,p_step_or_rate      => '10'
                                      ,p_user_table_id     => l_user_table_id
                                      ,p_effective_date    => p_pay_calc_data.effective_date
                                      ,p_pt_value          => l_basic_pay
                                      ,p_PT_eff_start_date => l_pt_eff_start_date
                                      ,p_PT_eff_end_date   => l_pt_eff_end_date
                                      ,p_pp_grd_exists       => l_pp_grd_exists );

	  l_special_rate := l_basic_pay;
          hr_utility.set_location('GOt Current Years Special Pay Table Value at step 10'|| l_special_rate,7788);
	  --Now Get current Years's default pay table value.for max rate....BUG# 4999237.
          hr_utility.set_location('Now Get current Years default pay table value.for max rate.',7788);
          ghr_pay_calc.get_pay_table_value(p_user_table_id      =>l_default_table_id
                                          ,p_pay_plan          =>l_default_pay_plan
                                          ,p_grade_or_level    =>l_grade_or_level
                                          ,p_step_or_rate      =>'10'
                                          ,p_effective_date    =>p_pay_calc_data.effective_date
                                          ,p_PT_value          => l_basic_pay
                                          ,p_PT_eff_start_date => l_PT_eff_start_date
                                          ,p_PT_eff_end_date   => l_dummy_date);
          hr_utility.set_location('Now GOt current Years default pay table value.for max rate.'||l_basic_pay ,7788);

	  --Bug# 7708264 modified to move getting previous years special rate calculation
	  -- before if condition as it is being used in the else condition also

	   --get previous year's special rate value.at step 10 ....BUG# 4999237.
          hr_utility.set_location('get previous years special rate value.at step 10',7788);
	  get_special_pay_table_value(p_pay_plan         => l_pay_plan
                                     ,p_grade_or_level    => l_grade_or_level
                                     ,p_step_or_rate      => '10'
                                     ,p_user_table_id     => l_user_table_id
                                     ,p_effective_date    => p_pay_calc_data.effective_date - 1
                                     ,p_pt_value          => l_old_basic_pay
                                     ,p_PT_eff_start_date => l_pt_eff_start_date
                                     ,p_PT_eff_end_date   => l_pt_eff_end_date
                                     ,p_pp_grd_exists     => l_pp_grd_exists );

	  l_old_special_rate := l_old_basic_pay;  --for bug#4999237...
          hr_utility.set_location('gOt previous years special rate value.at step 10'||l_old_special_rate,7788);

         -----APPLY LOCALITY % TO NEW DEFAULT TABLE VALUE.....l_adj_perc_factor is already calculated
          hr_utility.set_location('APPLY LOCALITY % TO NEW DEFAULT TABLE VALUE' ,7788);
	  l_locality_adj  := ROUND(l_basic_pay * l_adj_perc_factor,0);
          hr_utility.set_location('GETTING LOCALITY ADJUSTMENT'||l_locality_adj ,7788);
          l_adj_basic_pay := l_basic_pay + l_locality_adj;
          hr_utility.set_location('GETTING ADJUSTED BASIC PAY'||l_adj_basic_pay ,7788);

          --Bug # 9073576 Calculation of Old special Rate and Old Locality Rate
	   -- has been moved to before if condition as it is used in both if and else condition
	   --Pick the special rate ......BUG# 4999237.
           --From Now on Calculation is as usual...BUG# 4999237.
           --get previous year's special rate value.at step 10 ....BUG# 4999237.
           l_old_adj_perc_factor       := (NVL(ghr_pay_calc.get_lpa_percentage(p_pay_calc_data.duty_station_id
                                                                                   ,p_pay_calc_data.effective_date - 1
                                                                                   ),0))/100;



            hr_utility.set_location('l_old_adj_perc_factor ..' || to_char(l_old_adj_perc_factor),32);
            hr_utility.set_location('l_default_table_id: '||l_default_table_id,95);
            hr_utility.set_location(' l_pay_plan: '||l_pay_plan,95);
            hr_utility.set_location(' l_default_pay_plan: '||l_default_pay_plan,95);
            hr_utility.set_location(' l_grade_or_level: '||l_grade_or_level,95);
            ghr_pay_calc.get_pay_table_value(p_user_table_id      =>l_default_table_id
                                            ,p_pay_plan          =>l_default_pay_plan
                                            ,p_grade_or_level    =>l_grade_or_level
                                            ,p_step_or_rate      => '10'
                                            ,p_effective_date    =>p_pay_calc_data.effective_date - 1
                                            ,p_PT_value          => l_old_basic_pay
                                            ,p_PT_eff_start_date => l_PT_eff_start_date
                                            ,p_PT_eff_end_date   => l_dummy_date);


            hr_utility.set_location('old default table value '||l_old_basic_pay ,7788);
            hr_utility.set_location('Old basic at step 10: '||to_char(l_old_BASIC_PAY),90);
            l_old_locality_adj  := ROUND(l_old_basic_pay * l_old_adj_perc_factor,0);
            l_old_adj_basic_pay := l_old_basic_pay + l_old_locality_adj;
            hr_utility.set_location('Old adj basic at step 10: '||to_char(l_old_adj_basic_pay),95);
            hr_utility.set_location('Old locality at step 10: '||to_char(l_old_locality_adj),95);


	    ----Now compare special rate with basic pay......BUG# 4999237.
            hr_utility.set_location('COMPARING SPL RATE WITH  ADJ BASIC PAY',7788);

	 IF NVL(l_special_rate,0) > l_adj_basic_pay THEN
	    hr_utility.set_location(' SPL RATE IS > ADJ BASIC PAY',7788);

            hr_utility.set_location('::: 5010491 BP::: '||l_basic_pay,10);
            hr_utility.set_location('::: 5010491 ABP::: '||l_old_basic_pay,20);
            hr_utility.set_location('::: 5010491 UTN::: '||l_user_table_name,30);
            -- If both current and previous year's special rate step 10 values are NOT NULL
            -- Then new basic = current basic + (new special rate step10 value - old special rate step 10 value/2)

	    -- Bug # 9073576 as per the new requirement specified in the bug
	    IF l_old_adj_basic_pay > NVL(l_old_special_rate,0) THEN
	        l_old_special_rate :=  l_old_adj_basic_pay;
	    END IF;

	    IF l_old_special_rate IS NOT NULL AND l_special_rate IS NOT NULL AND
	       l_user_table_name NOT IN (ghr_pay_calc.l_standard_table_name,ghr_pay_calc.l_spl491_table_name) THEN

               l_increment := Round((l_special_rate - l_old_special_rate)/2,0);
               hr_utility.set_location('INCREMENTED HALF VALUE'||l_increment,7788);
               l_new_basic_pay := p_pay_calc_data.current_basic_pay + l_increment;
               hr_utility.set_location('NEW BASIC PAY'||l_new_basic_pay,7788);
	       l_new_locality_adj := 0;
               hr_utility.set_location('LOCALITY ADJUSTMENT SET TO ZERO',7788);
	       l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
               l_new_prd := p_pay_calc_data.pay_rate_determinant;
               hr_utility.set_location('NEW PRD SET'||l_new_prd ,7788);
               l_calculation_pay_table := l_user_table_name;
	       --6814842 modified to update position pay table and pay_table_upd_flag
               l_position_pay_table := l_user_table_name;
	       g_pay_table_upd_flag := FALSE;

               hr_utility.set_location('COMPARING NEW BASIC PAY AND NEW SPECIAL RATE VALUE',7788);

	       IF l_new_basic_pay <= l_special_rate  THEN
                  l_new_adj_basic_pay := l_special_rate;
                  hr_utility.set_location('SPECIAL RATE IS GREATER'||l_special_rate,7788);
                  hr_utility.set_location('get current value for step10 in default table',7788);
		  ghr_pay_calc.get_pay_table_value(p_user_table_id =>l_default_table_id
                                                  ,p_pay_plan          =>l_default_pay_plan
                                                  ,p_grade_or_level    =>l_grade_or_level
                                                  ,p_step_or_rate      => '10'
                                                  ,p_effective_date    =>p_pay_calc_data.effective_date
                                                  ,p_PT_value          => l_new_basic_pay
                                                  ,p_PT_eff_start_date => l_PT_eff_start_date
                                                  ,p_PT_eff_end_date   => l_dummy_date);

                  hr_utility.set_location('gOt current value for step10 in default table'||l_new_basic_pay,7788);
                  hr_utility.set_location('l_new_basic_pay: '|| l_new_basic_pay,95);
                  l_new_locality_adj  := l_new_adj_basic_pay - l_new_basic_pay;
                  hr_utility.set_location('SETTING NEW STEP'||l_new_step,7788);
		  l_new_step          := '10';
                  hr_utility.set_location('terminate PAY RETENTION',7788);
		  l_term_ret_pay_prd  := TRUE;
                  hr_utility.set_location('l_new_locality_adj: '|| l_new_locality_adj,95);
               END IF;
	    END IF;--IF l_old_basic_pay IS NOT

         ELSIF (l_adj_basic_pay >= nvl(l_special_rate,0)) OR (l_old_special_rate IS NULL)  then--IF NVL(l_special_rate,0)

            hr_utility.set_location('special rate is lesser or old special rate is not available',7788);
            hr_utility.set_location('::: 50101491 :::Inside Else Condition',40);

            IF  NVL(l_old_special_rate ,0) > l_old_adj_basic_pay THEN
               l_increment := Round((l_adj_basic_pay - l_old_special_rate)/2,0);
            ELSE
               l_increment := Round((l_adj_basic_pay - l_old_adj_basic_pay)/2,0);
            END IF;

            l_new_basic_pay := p_pay_calc_data.current_basic_pay + l_increment;
            l_new_locality_adj := 0;
            l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
            l_new_prd           := p_pay_calc_data.pay_rate_determinant;
            hr_utility.set_location(' adj basic at step 10: '||to_char(l_adj_basic_pay),95);
            hr_utility.set_location(' locality at step 10: '||to_char(l_locality_adj),95);
            l_calculation_pay_table := l_default_pay_table;
            --6814842 modified to update position pay table and pay_table_upd_flag
            l_position_pay_table := l_default_pay_table;
            g_pay_table_upd_flag := TRUE;

            IF l_new_adj_basic_pay <= l_adj_basic_pay THEN
               hr_utility.set_location('new adjusted basic pay is less than adjusted basic pay',7788);
               l_new_basic_pay     := l_basic_pay;
               hr_utility.set_location('new basic pay '||l_new_basic_pay,7788);
               l_new_locality_adj  := l_locality_adj;
               hr_utility.set_location('l_new_locality_adj'||l_locality_adj,7788);
               l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
               hr_utility.set_location('l_new_adj_basic_pay'||l_new_adj_basic_pay,7788);
               --Bug 7046241 added l_gr_pay_plan condition
               IF l_gm_pay_plan OR l_gr_pay_plan THEN
                  l_new_step          := '00';
               ELSE
                  l_new_step          := '10';
               END IF;
               hr_utility.set_location('l_new_step'||l_new_step,7788);
               l_term_ret_pay_prd  := TRUE;
               hr_utility.set_location('terminate PRD',7788);
           END IF;
         END IF;  --IF NVL(l_special_rate,0)

            -- Set the PRD if Pay Retention is terminated.
	       --  7046241
	    IF	 l_term_ret_pay_prd  and l_gr_pay_plan  and l_calculation_pay_table = ghr_pay_calc.l_standard_table_name then
                  ghr_history_fetch.fetch_positionei(
                      p_position_id      => p_pay_calc_data.position_id,
                      p_information_type => 'GHR_US_POS_VALID_GRADE',
                      p_date_effective   => p_pay_calc_data.effective_date,
                      p_pos_ei_data      => l_pos_ei_valid_grade);
                   IF NOT (ghr_pay_caps.pay_cap_chk_ttl_38( l_pos_ei_valid_grade.poei_information12,
                                               l_pos_ei_valid_grade.poei_information13,
                                               p_pay_calc_data.current_adj_basic_pay,
                                               p_pay_calc_data.effective_date)) THEN
                    l_term_ret_pay_prd := FALSE;

                   END IF;
	    END IF;
	       --  7046241
            IF l_term_ret_pay_prd THEN
                IF p_pay_calc_data.pay_rate_determinant IN ('3','4','J','K','R','Y') THEN -- Bug# 9255822 added PRD Y
                    IF l_calculation_pay_table = ghr_pay_calc.l_standard_table_name  THEN
                        l_new_prd := '0';
                    ELSE
                        l_new_prd := '6';
                    END IF;
                ELSIF p_pay_calc_data.pay_rate_determinant = 'U' THEN
                    IF l_calculation_pay_table = ghr_pay_calc.l_standard_table_name  THEN
                       l_new_prd := 'B';
                    ELSE
                       l_new_prd := 'F';
                    END IF;
                ELSIF p_pay_calc_data.pay_rate_determinant = 'V' THEN
                    IF l_calculation_pay_table = ghr_pay_calc.l_standard_table_name  THEN
                       l_new_prd := 'A';
                    ELSE
                       l_new_prd := 'E';
                    END IF;
                END IF;
            END IF;

        END IF;--IF p_pay_calc_data.effective_date
        -- Get the Calculation Pay Table ID
        FOR table_rec IN c_get_table_id(l_calculation_pay_table)
        LOOP
            l_calculation_pay_table_id := table_rec.user_table_id;
        END LOOP;
        p_pay_calc_out_data.calculation_pay_table_id := l_calculation_pay_table_id;
        hr_utility.set_location(':: 5010491 :: leaving the pay retention',100);
        IF l_gm_pay_plan THEN
            l_pay_plan := 'GM';
        --- Bug 5908487 Changes.
            l_default_pay_plan := 'GM';
            l_gm_pay_plan := FALSE;
         --Begin Bug 7046241
        ELSIF l_gr_pay_plan THEN
            l_pay_plan := 'GR';
            l_default_pay_plan := 'GR';
            l_gr_pay_plan := FALSE;
        --End Bug 7046241
        END IF;

    ELSE  ---- IF p_pay_calc_data.pay_rate_determinant IN ('3','4','J','K','U','V','R','Y')
        -- 5. Processing Employees on GM Pay Plan.
        --Bug# 7518210 added GR
        IF l_pay_plan IN ('GM','GH','GR') THEN
            -- AC added the IF condition for opening teh pay fields in few actions Bug#5114467
            IF p_pay_calc_data.noa_family_code IN ('APP','CHG_DUTY_STATION','CONV_APP','EXT_NTE','POS_CHG'
                                                  ,'REALIGNMENT','REASSIGNMENT', 'RETURN_TO_DUTY') THEN
                hr_utility.set_message(8301, 'GHR_38260_NO_CALC_PAY_PLAN');
                hr_utility.set_message_token('PAY_PLAN',l_pay_plan);
                raise ghr_pay_calc.unable_to_calculate;
            END IF;
           -- Added this IF condition Bug#5114467
           IF l_pay_plan NOT IN ('GM','GR') THEN
               --Bug# 7518210 added GR
               l_new_Position_Pay_Table := ghr_pay_calc.l_standard_table_name;
               l_calculation_pay_table  := ghr_pay_calc.l_standard_table_name;
               g_pay_table_upd_flag := TRUE;
               l_new_prd           := '0';
               l_new_basic_pay     := ROUND(p_pay_calc_data.current_adj_basic_pay / (1 + l_adj_perc_factor),0);
               l_new_locality_adj  := ROUND(l_new_basic_pay * l_adj_perc_factor);
               l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
           ELSE
               IF p_pay_calc_data.noa_code= 894 THEN
               --AC -- Code for 894 Special Emp.
               hr_utility.set_location('AC Grade' || l_grade_or_level,1000);
               hr_utility.set_location('AC User Table id' || l_user_table_id,1000);
               ghr_pc_basic_pay.get_894_GM_sp_basic_pay (p_grade_or_level    => l_grade_or_level
							 ,p_effective_date    => p_pay_calc_data.effective_date
							 ,p_user_table_id     => l_user_table_id
							 ,p_default_table_id  => l_default_table_id
							 ,p_curr_basic_pay    => p_pay_calc_data.current_basic_pay
							 ,p_duty_station_id   => p_pay_calc_data.duty_station_id
							 ,p_new_basic_pay     => l_new_basic_pay
							 ,p_new_adj_basic_pay => l_new_adj_basic_pay
							 ,p_new_locality_adj  => l_new_locality_adj
							 ,p_new_special_rate  => l_new_special_rate
							 );
               ELSE
               --AC -- Code for WGI Special Emp.
               ghr_pc_basic_pay.get_wgi_GM_sp_basic_pay (p_grade_or_level    => l_grade_or_level
							 ,p_effective_date    => p_pay_calc_data.effective_date
							 ,p_user_table_id     => l_user_table_id
							 ,p_default_table_id  => l_default_table_id
							 ,p_curr_basic_pay    => p_pay_calc_data.current_basic_pay
							 ,p_duty_station_id   => p_pay_calc_data.duty_station_id
							 ,p_new_basic_pay     => l_new_basic_pay
							 ,p_new_adj_basic_pay => l_new_adj_basic_pay
							 ,p_new_locality_adj  => l_new_locality_adj
							 );
               END IF;
           END IF;

        /*ELSIF g_fw_equiv_pay_plan AND p_pay_calc_data.pay_rate_determinant IN ('6','E','F') THEN  -- Bug 5218445
           get_special_pay_table_value (p_pay_plan           => l_pay_plan
                                        ,p_grade_or_level    => l_grade_or_level
                                        ,p_step_or_rate      => l_step_or_rate
                                        ,p_user_table_id     => l_user_table_id
                                        ,p_effective_date    => p_pay_calc_data.effective_date
                                        ,p_pt_value          => l_pt_value
                                        ,p_PT_eff_start_date => l_pt_eff_start_date
                                        ,p_PT_eff_end_date   => l_pt_eff_end_date
                                        ,p_pp_grd_exists     => l_pp_grd_exists );
           l_new_basic_pay := l_pt_value;
           l_new_locality_adj := 0;
           l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
           l_calculation_pay_table := get_user_table_name(l_user_table_id);
        */
        ELSE----IF l_pay_plan IN ('GM'
            -- 6. Processing Employees on pay plans other than GM.


            -- Processing for InterimWGI/WGI/QSI.
            -- Bug#5566896Added NOA Code 867.
            IF p_pay_calc_data.noa_code IN ('867','892','893') THEN
                l_ret_flag := FALSE;
                l_curr_step_or_rate := l_step_or_rate;
                -- FWFA Changes NEW
                IF p_pay_calc_data.pay_rate_determinant IN ('A','B','E','F') THEN
                    if ghr_pc_basic_pay.g_noa_family_code ='CORRECT'  then
                          if p_retained_grade.temp_step is not null then
                             -- Bug 3021003 Start
                             is_retained_ia(p_pay_calc_data.person_id,
                                            p_pay_calc_data.effective_date,
                                            l_pay_plan,
                                            l_grade_or_level,
                                            l_step_or_rate,
                                            p_retained_grade.temp_step,
                                           l_ret_flag);
                             IF l_ret_flag = TRUE then
                                     hr_utility.set_location('NAR ret step ' ||p_retained_grade.temp_step,10);
                                     hr_utility.set_location('NAR pay plan '||l_pay_plan,20);
                                 l_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (l_pay_plan
                                                                  ,p_retained_grade.temp_step);
                                 hr_utility.set_location('NAR new step after getting the step ' ||l_step_or_rate,10);
                                 -- End Bug 3021003
                             ELSE
                             l_step_or_rate := p_retained_grade.temp_step;
                             END IF;
                          else
                                 -- Bug 3021003
                                 is_retained_ia(p_pay_calc_data.person_id,
                                                p_pay_calc_data.effective_date,
                                                l_pay_plan,
                                                l_grade_or_level,
                                                l_step_or_rate,
                                                p_retained_grade.temp_step,
                                                l_ret_flag);
                                IF l_ret_flag = TRUE then
                                     hr_utility.set_location('NAR ret step ' ||l_step_or_rate,10);
                                     hr_utility.set_location('NAR pay plan '||l_pay_plan,20);
                                             l_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (l_pay_plan
                                                                  ,l_step_or_rate);
                                     hr_utility.set_location('NAR new step after getting the step ' ||l_step_or_rate,10);
                                 ELSE
                                         l_step_or_rate := l_step_or_rate;
                                 END IF; -- IF  is_retained_ia End Bug 3021003
                            END IF;  -- if p_retained_grade.temp_step is not null
                   else--family_code ='CORRECT'
                      if p_retained_grade.temp_step is not null then

                         l_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (l_pay_plan
                                                                              ,p_retained_grade.temp_step);
                      else
                         l_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (l_pay_plan
                                                                              ,p_retained_grade.step_or_rate);
                      end if;
                   end if;--family_code ='CORRECT'
                ELSE --('A','B','E','F') THEN
                    --if ghr_pc_basic_pay.g_noa_family_code ='CORRECT' then
                      --  l_step_or_rate := l_curr_step_or_rate;
                    --ELSE
                        l_step_or_rate := ghr_pc_basic_pay.get_next_WGI_step (p_pay_plan => l_pay_plan
                                                                     ,p_current_step => l_curr_step_or_rate);
                    --END IF;
                END IF;  --('A','B','E','F') THEN
                -- FWFA Changes NEW
                hr_utility.set_location('l_step_or_rate: '||l_step_or_rate,11111111);
                -- Bug#5444558 Modified the assignment of step value. Assigned the step into local
                -- variable l_new_step here. Assign this value to p_pay_calc_out_data.out_step_or_rate
                -- at the end of the pay calc.
                IF p_pay_calc_data.pay_rate_determinant IN ('E','F','A','B') THEN
                    l_new_step := '00';
                ELSE
                    l_new_step := l_step_or_rate;
                END IF;
            END IF;-- ('867','892','893') THEN


            IF g_fw_equiv_pay_plan THEN  -- Begin Bug 5608741
               get_special_pay_table_value (p_pay_plan           => l_pay_plan
                                            ,p_grade_or_level    => l_grade_or_level
                                            ,p_step_or_rate      => l_step_or_rate
                                            ,p_user_table_id     => l_user_table_id
                                            ,p_effective_date    => p_pay_calc_data.effective_date
                                            ,p_pt_value          => l_pt_value
                                            ,p_PT_eff_start_date => l_pt_eff_start_date
                                            ,p_PT_eff_end_date   => l_pt_eff_end_date
                                            ,p_pp_grd_exists     => l_pp_grd_exists );
               l_new_basic_pay := l_pt_value;
               l_new_locality_adj := 0;
               l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
               l_calculation_pay_table := get_user_table_name(l_user_table_id);
            ELSE --End Bug# 5608741
                -- Processing of NOACs other than WGI/QSI
                IF l_user_table_name IN (ghr_pay_calc.l_standard_table_name,ghr_pay_calc.l_spl491_table_name) THEN
                    l_pay_calc_process := 'L';
                ELSE
                    hr_utility.set_location('user tbale id: '||to_char(l_user_table_id),40);
                    hr_utility.set_location('pay Plan: '||l_pay_plan,50);
                    hr_utility.set_location('grade: '||l_grade_or_level,60);
                    hr_utility.set_location('step : '||l_step_or_rate,70);
                    get_special_pay_table_value (p_pay_plan           => l_pay_plan
                                                 ,p_grade_or_level    => l_grade_or_level
                                                 ,p_step_or_rate      => l_step_or_rate
                                                 ,p_user_table_id     => l_user_table_id
                                                 ,p_effective_date    => p_pay_calc_data.effective_date
                                                 ,p_pt_value          => l_pt_value
                                                 ,p_PT_eff_start_date => l_pt_eff_start_date
                                                 ,p_PT_eff_end_date   => l_pt_eff_end_date
                                                 ,p_pp_grd_exists       => l_pp_grd_exists );
                    hr_utility.set_location('value '||to_char(l_pt_value),80);
                    ghr_pay_calc.get_pay_table_value(p_user_table_id      =>l_default_table_id
                                                     ,p_pay_plan          =>l_default_pay_plan
                                                     ,p_grade_or_level    =>l_grade_or_level
                                                     ,p_step_or_rate      =>l_step_or_rate
                                                     ,p_effective_date    =>p_pay_calc_data.effective_date
                                                     ,p_PT_value          => l_basic_pay
                                                     ,p_PT_eff_start_date => l_PT_eff_start_date
                                                     ,p_PT_eff_end_date   => l_dummy_date);
                    hr_utility.set_location('std basic: '||to_char(l_BASIC_PAY),90);

                    l_locality_adj  := ROUND(l_basic_pay * (NVL(l_adjustment_percentage,0)/100),0);
                    l_adj_basic_pay := l_basic_pay + l_locality_adj;

                    -- IF Pay Plan Grade Exists and Step not exists
                    IF l_pp_grd_exists THEN
                        IF l_pt_value is NULL THEN
                            l_pay_calc_process := 'L';
                            l_loc_rate_less_spl_rate := NULL;
                        ELSE
                            IF l_pt_value > l_adj_basic_pay THEN
                                l_pay_calc_process := 'S';
                                l_calculation_pay_table := l_user_table_name;
                                l_loc_rate_less_spl_rate := TRUE;
                            ELSE
                                l_pay_calc_process := 'L';
                                l_loc_rate_less_spl_rate := FALSE;
                            END IF;
                        END IF;
                    ELSE
                        l_pay_calc_process := 'L';
                        l_loc_rate_less_spl_rate := NULL;
                    END IF;
            END IF;  --l_user_table_name IN
            hr_utility.set_location('process :'||l_pay_calc_process,100);
            IF g_pay_table_upd_flag THEN
                hr_utility.set_location('Before SET_CPT Pay Table UPD Flag TRUE',101);
            ELSE
                hr_utility.set_location('Before SET_CPT Pay Table UPD Flag FALSE',102);
            END IF;
            set_cpt_ppt_prd ( p_leo_flag	        	=> l_leo_flag
                             ,p_rg_flag		        	=> l_rg_flag
                             ,p_pp_grd_exists	        => l_pp_grd_exists
                             ,p_loc_rate_less_spl_rate  => l_loc_rate_less_spl_rate
                             ,p_prd                     => p_pay_calc_data.pay_rate_determinant
                             ,p_pt_value		        => l_pt_value
                             ,p_special_rate_table      => l_user_table_name
                             ,p_calculation_pay_table   => l_calculation_pay_table
                             ,p_position_pay_table      => l_position_pay_table
                             ,p_retained_pay_table      => l_retained_pay_table
                             ,p_new_prd                 => l_new_prd
                             );
            IF g_pay_table_upd_flag THEN
                hr_utility.set_location('After SET_CPT Pay Table UPD Flag TRUE',101);
            ELSE
                hr_utility.set_location('After SET_CPT Pay Table UPD Flag FALSE',102);
            END IF;
            hr_utility.set_location('calc table: '||l_calculation_pay_table,110);
            hr_utility.set_location('posn table: '||L_position_pay_table,120);
            hr_utility.set_location('retd table: '||l_retained_pay_table,130);
            hr_utility.set_location('new prd : '||l_new_prd,140);


            -- get_basic_pay
            hr_utility.set_location('2. l_step_or_rate: '||l_step_or_rate,999999);
            ghr_pay_calc.get_pay_table_value(p_user_table_id      => l_default_table_id
                                             ,p_pay_plan          => l_default_pay_plan
                                             ,p_grade_or_level    => l_grade_or_level
                                             ,p_step_or_rate      => l_step_or_rate
                                             ,p_effective_date    => p_pay_calc_data.effective_date
                                             ,p_PT_value          => l_basic_pay
                                             ,p_PT_eff_start_date => l_PT_eff_start_date
                                             ,p_PT_eff_end_date   => l_dummy_date);
            l_new_basic_pay := l_basic_pay;
            hr_utility.set_location('std basic: '||to_char(l_new_BASIC_PAY),10);
            hr_utility.set_location('ADJ Perc : '||to_char(l_adj_perc_factor),20);
            -- get_locality_or_supplement/ Adj Basic Pay
            IF l_pay_calc_process =  'L' THEN
                hr_utility.set_location('Inside Locality Calculation',30);
                l_new_locality_adj := ROUND(l_new_basic_pay * l_adj_perc_factor);
                l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
            ELSIF l_pay_calc_process = 'S' THEN
                hr_utility.set_location('Inside Special Rate Calculation',40);
                l_new_locality_adj  := l_pt_value - l_new_basic_pay;
                l_new_adj_basic_pay := l_new_basic_pay + l_new_locality_adj;
            END IF;
        END IF;--End of if Bug 5608741
    END IF;----IF l_pay_plan IN ('GM'
    END IF; ---- IF p_pay_calc_data.pay_rate_determinant IN ('3','4','J','K','U','V','R','Y')
    FOR table_rec IN c_get_table_id(l_calculation_pay_table)
    LOOP
        l_calculation_pay_table_id := table_rec.user_table_id;
    END LOOP;

    hr_utility.set_location('new Basic : '||to_char(l_new_basic_pay),10);
    hr_utility.set_location('new LOC : '||to_char(l_new_locality_adj),20);
    hr_utility.set_location('new ADJ BA : '||to_char(l_new_adj_basic_pay),30);
    hr_utility.set_location('new PRD : '||l_new_prd,40);
    hr_utility.set_location('new Step : '||l_new_step,50);
    --Bug#5089732 Set the Pay Rate Determinant for GL,GG Pay Plans
    IF  l_calculation_pay_table = ghr_pay_calc.l_spl491_table_name  AND
        l_pay_plan  IN ('GL','GG') AND
        l_new_prd IN ('6','E','F')  THEN
        IF l_new_prd = '6' THEN
            l_new_prd := '0';
        ELSIF l_new_prd = 'E' THEN
            l_new_prd := 'A';
        ELSE
            l_new_prd := 'B';
        END IF;
        --Bug#5435217 Set this flag to true to avoid unnecessary creation of RG record.
        g_gl_upd_flag := TRUE;
    END IF;

    -- AC : Bug#5114467 Added codition for For Regular Emp. in GM pay table and 894 action
    -- And Code for determining Calculation pay table For Regular Emp. in GM pay table and 894 action
    IF l_pay_plan = 'GM' AND p_pay_calc_data.noa_code= 894 THEN
        -- AC : Bug#5725928 - Added the condition so that the pay adjustment process should be
        -- doing the comparison of locality verses special rate only if the pay table is not 0000
        IF l_calculation_pay_table <> ghr_pay_calc.l_standard_table_name THEN
            IF l_new_locality_adj > l_new_special_rate THEN
                l_new_prd := '0';
            ELSE
                l_new_prd := '6';
            END IF;
        END IF;
        IF l_new_prd IN ('0','A','B') THEN
            l_calculation_pay_table_id := l_default_table_id;
        ELSIF l_new_prd IN ('6','E','F') THEN
            l_calculation_pay_table_id := l_user_table_id;
        END IF;
    END IF;

    -- Bug#4699932 Added the OR clause to IF condition.
    -- Set the out_pay_rate_determinant as NULL if there is no change in PRD.
    IF p_pay_calc_data.pay_rate_determinant = l_new_prd  OR
       (p_pay_calc_data.noa_family_code IN ('APP','CONV_APP') AND
        p_pay_calc_data.pay_rate_determinant IN ('5','7')
       ) THEN
        l_new_prd := NULL;
    END IF;

    -- SET OUT PARAMETERS
           hr_utility.set_location('new PRD : '||l_new_prd,40);
           hr_utility.set_location('new Step : '||l_new_step,50);
           hr_utility.set_location('new l_calculation_pay_table_id : '|| l_calculation_pay_table_id,50);
    p_pay_calc_out_data.basic_pay                := l_new_basic_pay;
    p_pay_calc_out_data.locality_adj             := l_new_locality_adj;
    p_pay_calc_out_data.adj_basic_pay            := l_new_adj_basic_pay;
    p_pay_calc_out_data.out_pay_rate_determinant := l_new_prd;
    p_pay_calc_out_data.calculation_pay_table_id := l_calculation_pay_table_id;
    p_pay_calc_out_data.out_step_or_rate         := l_new_step;
    -- Use the Pay Table ID as the input table for Pay Calculation.
    p_pay_calc_out_data.pay_table_id             := l_user_table_id;

------ Bug#5741977 start
    IF l_fwfa_pay_plan_changed THEN
       IF nvl(l_new_prd,'X') in ('A','B','E','F','U','V') AND
          p_retained_grade.temp_step IS NULL THEN
            g_out_to_pay_plan   := l_default_pay_plan;
       ELSIF l_grade_id is not null then
          p_pay_calc_out_data.out_to_grade_id        := l_grade_id;
          p_pay_calc_out_data.out_to_pay_plan        := l_default_pay_plan;
          p_pay_calc_out_data.out_to_grade_or_level  := l_grade_or_level;
       END IF;
    END IF;
------ Bug#5741977 End
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END special_rate_pay_calc;

-- Bug# 4748927 Begin
PROCEDURE award_amount_calc (
                         p_position_id              IN NUMBER
                        ,p_pay_plan					IN VARCHAR2
						,p_award_percentage			IN NUMBER
                        ,p_user_table_id			IN NUMBER
						,p_grade_or_level			IN  VARCHAR2
						,p_effective_date			IN  DATE
						,p_basic_pay				IN NUMBER
						,p_adj_basic_pay			IN NUMBER
						,p_duty_station_id			IN ghr_duty_stations_f.duty_station_id%TYPE
						,p_prd						IN ghr_pa_requests.pay_rate_determinant%type
						,p_pay_basis                IN VARCHAR2
						,p_person_id                IN per_people_f.person_id%TYPE
						,p_award_amount				OUT NOCOPY NUMBER
						,p_award_salary				OUT NOCOPY NUMBER
                        ) IS
l_pay_table				VARCHAR2(4);
l_PT_value				NUMBER;
l_PT_eff_start_date		DATE;
l_PT_eff_end_date		DATE;
l_equivalent_pay_plan	ghr_pay_plans.equivalent_pay_plan%type;
l_adjustment_percentage ghr_locality_pay_areas_f.adjustment_percentage%type;
l_max_step				ghr_pay_plans.maximum_step%type;
l_locality_adj			NUMBER;
l_leo_flag				BOOLEAN;
l_std_user_table_id		NUMBER;
l_std_user_table_name	varchar2(80);
l_retained_grade_rec	ghr_pay_calc.retained_grade_rec_type;
l_pay_plan				VARCHAR2(10);
l_pay_basis				VARCHAR2(10);
l_grade_or_level		VARCHAR2(60);
l_user_table_id			NUMBER;
l_proc					VARCHAR2(30) := 'award_amount_calc';
l_special_rate                  NUMBER;
 l_pp_grd_exists         BOOLEAN;
--bug #5482191
 l_psi  VARCHAR2(30);
cursor c_gs_eq(pc_pay_plan VARCHAR2)  is
SELECT equivalent_pay_plan,maximum_step
		FROM ghr_pay_plans
		WHERE pay_plan = pc_pay_plan;

CURSOR get_user_table_id(p_user_table_name  VARCHAR2) IS
  SELECT utb.user_table_id
  FROM   pay_user_tables  utb
  WHERE utb.user_table_name = p_user_table_name;

BEGIN
hr_utility.set_location('Entering ...'|| l_proc,100);
l_psi := ghr_pa_requests_pkg.get_personnel_system_indicator(p_position_id,p_effective_date);

hr_utility.set_location('personnel system ...'|| l_psi,101);

IF l_psi <> '00' THEN  --for NSPS

 IF  p_pay_basis = 'PA' THEN
    p_award_salary := ROUND(p_adj_basic_pay);
  ELSIF p_pay_basis = 'PH' THEN
    p_award_salary := ROUND(p_adj_basic_pay * 2087);
 ELSIF p_pay_basis = 'PM' THEN
    p_award_salary := ROUND(p_adj_basic_pay * 12);
END IF;

ELSE  --for non-NSPS

       IF NVL(p_prd,'X') NOT IN ('A','B','E','F','U','V') THEN
			l_pay_plan			:= p_pay_plan;
			l_grade_or_level	:= p_grade_or_level;
			l_user_table_id		:= p_user_table_id;
            -- Bug#5237399 Added Pay basis
            l_pay_basis         := p_pay_basis;
	ELSE
	 BEGIN
	     l_retained_grade_rec := ghr_pc_basic_pay.get_retained_grade_details (p_person_id,p_effective_date,NULL);
	     --Mani Bug #6655566 Award Amount calculated on the Position pay basis if temp step is not null
	     --otherwise on retained grade
	     If NVL(p_prd,'X') IN ('A','B','E','F') AND
 	        l_retained_grade_rec.temp_step is not null then
                   l_pay_basis := p_pay_basis;
                   l_pay_plan  := p_pay_plan;
        	   l_grade_or_level := p_grade_or_level;
                   l_user_table_id  := p_user_table_id;
	     else
	      	l_pay_plan		:= l_retained_grade_rec.pay_plan;
		l_grade_or_level	:= l_retained_grade_rec.grade_or_level;
		l_user_table_id		:= l_retained_grade_rec.user_table_id;
                -- Bug#5237399 Added Pay basis
                l_pay_basis             := l_retained_grade_rec.pay_basis;

              END IF;

				exception
				when others then
					hr_utility.set_location('Retained Exception raised ' || sqlerrm(sqlcode),25);
			END;
	END IF;
	for c1 in c_gs_eq(l_pay_plan) loop
			l_equivalent_pay_plan := c1.equivalent_pay_plan;
			l_max_step  	:= c1.maximum_step;
	end loop;

	IF p_prd not in('3','4','J','K','U','V','R') THEN
        IF (l_equivalent_pay_plan = 'FW' OR
            (l_pay_plan = 'AD' and l_pay_basis = 'PH') ) THEN
        p_award_salary := ROUND(p_adj_basic_pay * 2087);
        ELSE
		p_award_salary := ROUND(p_adj_basic_pay);
        END IF;
	ELSE
		l_pay_table := SUBSTR(ghr_pay_calc.get_user_table_name(l_user_table_id),1,4);


IF (l_equivalent_pay_plan = 'GS') THEN

--bug #5529825
          if l_pay_plan  = 'GM' then
	     l_pay_plan := 'GS';
	     l_max_step := '10';
	  end if;
--end bug#5529825



--code changes for bug 4999237
---CODE FOR GETTING SPECIAL TABLE RATE VALUES..........
     IF l_pay_table  NOT IN('0491','0000') THEN
             get_special_pay_table_value (p_pay_plan          => l_pay_plan
                                        ,p_grade_or_level    => l_grade_or_level
                                        ,p_step_or_rate      => l_max_step
                                        ,p_user_table_id     => l_user_table_id
                                        ,p_effective_date    => p_effective_date
                                        ,p_pt_value          => l_pt_value
                                        ,p_PT_eff_start_date => l_pt_eff_start_date
                                        ,p_PT_eff_end_date   => l_pt_eff_end_date
                                        ,p_pp_grd_exists       => l_pp_grd_exists );



    l_special_rate := l_pt_value;
    hr_utility.set_location('special rate   '||l_special_rate,8877);

   --code for getting default table values......



        IF ghr_pay_calc.LEO_position (p_prd
						,p_position_id
						,l_std_user_table_id
						,p_duty_station_id
						,p_effective_date)
						AND p_grade_or_level between 03 and 10 THEN
   					    l_std_user_table_name := Ghr_pay_calc.l_spl491_table_name;

					ELSE
						l_std_user_table_name := Ghr_pay_calc.l_standard_table_name;

					END IF;
					FOR c_rec IN get_user_table_id(l_std_user_table_name) LOOP
							l_std_user_table_id  := c_rec.user_table_id;
					END LOOP;

        ghr_pay_calc.get_pay_table_value (p_user_table_id      => l_std_user_table_id
						,p_pay_plan          => l_pay_plan
						,p_grade_or_level    => l_grade_or_level
						,p_step_or_rate      => l_max_step
						,p_effective_date    => p_effective_date
						,p_PT_value          => l_PT_value
						,p_PT_eff_start_date => l_PT_eff_start_date
						,p_PT_eff_end_date   => l_PT_eff_end_date
						 );
          hr_utility.set_location('default  rate   '||l_PT_value,8877);
	l_adjustment_percentage := NVL(ghr_pay_calc.get_lpa_percentage(p_duty_station_id,p_effective_date),0);
	hr_utility.set_location('l_adjustment_percentage   '||l_adjustment_percentage,8877);
	l_locality_adj  := l_PT_value * (NVL(l_adjustment_percentage,0)/100);

	l_pt_value := l_pt_value + l_locality_adj;
	hr_utility.set_location('final default rate   '||l_pt_value,8877);
     --compare srt and locality rate..........
     if nvl(l_special_rate,0) < l_pt_value  then

           p_award_salary := ROUND(l_pt_value);

      else

           p_award_salary := ROUND(l_special_rate);

      end if;
ELSIF  l_pay_table  IN('0491','0000')  THEN

	   BEGIN
              ghr_pay_calc.get_pay_table_value (	p_user_table_id      => l_user_table_id
													,p_pay_plan          => l_pay_plan
													,p_grade_or_level    => l_grade_or_level
													,p_step_or_rate      => l_max_step
													,p_effective_date    => p_effective_date
													,p_PT_value          => l_PT_value
													,p_PT_eff_start_date => l_PT_eff_start_date
													,p_PT_eff_end_date   => l_PT_eff_end_date);

                l_adjustment_percentage := NVL(ghr_pay_calc.get_lpa_percentage(p_duty_station_id
												,p_effective_date),0);

                l_locality_adj  := l_PT_value * (NVL(l_adjustment_percentage,0)/100);

                p_award_salary  := ROUND(l_PT_value+l_locality_adj);


       EXCEPTION
              WHEN ghr_pay_calc.pay_calc_message THEN
				BEGIN
					IF ghr_pay_calc.LEO_position (p_prd
						,p_position_id
						,l_std_user_table_id
						,p_duty_station_id
						,p_effective_date)
						AND p_grade_or_level between 03 and 10 THEN
   					    l_std_user_table_name := Ghr_pay_calc.l_spl491_table_name;

					ELSE
						l_std_user_table_name := Ghr_pay_calc.l_standard_table_name;

					END IF;
					FOR c_rec IN get_user_table_id(l_std_user_table_name) LOOP
							l_std_user_table_id  := c_rec.user_table_id;
					END LOOP;
						ghr_pay_calc.get_pay_table_value (	p_user_table_id      => l_std_user_table_id
															,p_pay_plan          => l_pay_plan
															,p_grade_or_level    => l_grade_or_level
															,p_step_or_rate      => l_max_step
															,p_effective_date    => p_effective_date
															,p_PT_value          => l_PT_value
															,p_PT_eff_start_date => l_PT_eff_start_date
															,p_PT_eff_end_date   => l_PT_eff_end_date);

					l_adjustment_percentage := NVL(ghr_pay_calc.get_lpa_percentage(p_duty_station_id
												,p_effective_date),0);
					l_locality_adj  := l_PT_value * (NVL(l_adjustment_percentage,0)/100);
					p_award_salary := ROUND(l_PT_value+l_locality_adj);
				END;
		END;
		--END IF; --l_pay_table IN('0491','0000')

   END IF;


--END IF;
--end code changes for bug 4999237

     -- Bug#5237399 Added the AD Pay Plan Condition.
		ELSIF (l_equivalent_pay_plan = 'FW'  OR
              (l_pay_plan = 'AD' and l_pay_basis = 'PH')) THEN
            hr_utility.set_location('USER TABLE '||to_char(l_user_table_id),10);
            hr_utility.set_location('EFF DT '||to_char(p_effective_date),20);
            hr_utility.set_location('MAX STEP '||l_max_step,30);
            hr_utility.set_location('PAY PLAN '||l_pay_plan,40);
            hr_utility.set_location('GRADE '||l_grade_or_level,50);
			ghr_pay_calc.get_pay_table_value (	p_user_table_id			 => l_user_table_id
													,p_pay_plan          => l_pay_plan
													,p_grade_or_level    => l_grade_or_level
													,p_step_or_rate      => l_max_step
													,p_effective_date    => p_effective_date
													,p_PT_value          => l_PT_value
													,p_PT_eff_start_date => l_PT_eff_start_date
													,p_PT_eff_end_date   => l_PT_eff_end_date);
            hr_utility.set_location('VALUE '||to_char(l_pt_value),60);
            hr_utility.set_location('Pay Basis '||p_pay_basis,70);
			p_award_salary := ROUND(ghr_pay_calc.convert_amount(l_PT_value,p_pay_basis,'PA'));

		END IF; --(p_pay_plan = l_equivalent_pay_plan)
	END IF; --p_prd not in('3','4','J','K','U','V'
	--Begin Bug# 5039156


END IF;

    -- Call the user hook
    ghr_custom_award.custom_award_salary(p_position_id
                                        ,p_person_id
                                        ,p_prd
                                        ,p_pay_basis
                                        ,p_pay_plan
                                        ,p_user_table_id
                                        ,p_grade_or_level
                                        ,p_effective_date
                                        ,p_basic_pay
                                        ,p_adj_basic_pay
                                        ,p_duty_station_id
                                        ,p_award_salary
                                        );



	p_award_amount :=  FLOOR(p_award_salary *( nvl(p_award_percentage,0) / 100));
	--End Bug# 5039156
	hr_utility.set_location('Leaving  Award Amount sal' || p_award_salary,10);
EXCEPTION
	WHEN OTHERS THEN
		p_award_amount := NULL;
		p_award_salary := NULL;
		hr_utility.set_location('Leaving  ' || l_proc,10);
END award_amount_calc;
-- Bug# 4748927 End
END ghr_pay_calc;

/
