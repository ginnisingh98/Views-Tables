--------------------------------------------------------
--  DDL for Package Body HR_MEE_VIEWS_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MEE_VIEWS_GEN" AS
/* $Header: hrmegviw.pkb 120.16.12010000.3 2009/07/17 08:30:45 gpurohit ship $ */

TYPE cur_typ IS REF CURSOR;

g_hours_per_week  NUMBER:= g_hours_per_day * 5;
g_hours_per_month NUMBER:= g_hours_per_week * 4.225;
g_hours_per_year  NUMBER:= g_hours_per_month * 12;


--bug 5890210
function getCostCenter(
      p_assignment_id NUMBER
    ) return varchar2
  is
  cursor getCC is  --this cursor will read the cc for the assignment
  SELECT
    pcak.cost_allocation_keyflex_id,
    pcak.concatenated_segments,
    pcaf.proportion
  FROM
    per_all_assignments_f assg,
    pay_cost_allocations_f pcaf,
    pay_cost_allocation_keyflex pcak
  WHERE assg.assignment_id = p_assignment_id
  AND assg.assignment_id = pcaf.assignment_id
  AND assg.Primary_flag = 'Y'
  AND pcaf.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
  AND pcak.enabled_flag = 'Y'
  AND sysdate between nvl(pcaf.effective_start_date,sysdate)
  and nvl(pcaf.effective_end_date,sysdate+1)
  AND sysdate between nvl(assg.effective_start_date,sysdate)
  and nvl(assg.effective_end_date,sysdate+1);

    cursor getCC_org is --this cursor will read the cc for the organizarion
  SELECT
     pcak.concatenated_segments
   FROM
     per_all_assignments_f assg,
    hr_all_organization_units horg,
     pay_cost_allocation_keyflex pcak
   WHERE assg.assignment_id = p_assignment_id
   AND assg.organization_id = horg.organization_id
   AND assg.Primary_flag = 'Y'
   AND horg.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
   AND pcak.enabled_flag = 'Y'
   AND sysdate between nvl(assg.effective_start_date,sysdate)
   and nvl(assg.effective_end_date,sysdate+1);


  result varchar2(1000) := null ;
begin

  For a in getCC loop
   if result is null then
     result := a.concatenated_segments ||' : '|| a.proportion*100 || '% ';
   else
     result := result ||', ' || a.concatenated_segments ||' : '|| a.proportion*100 ||'% ';
   end if;
 end loop;

 For a in getCC_org loop
   if result is null then
     result := a.concatenated_segments ;
   end if;
 end loop;

 return result;
end;
--bug 5890210

FUNCTION getYearStart RETURN DATE IS
BEGIN
    return hr_util_misc_ss.g_year_start;
END getYearStart;

FUNCTION getRateType RETURN VARCHAR2 IS
BEGIN
    return hr_util_misc_ss.g_rate_type;
END getRateType;

FUNCTION convertDuration(
         p_from_duration_units IN VARCHAR2
        ,p_to_duration_units IN VARCHAR2
        ,p_from_duration IN NUMBER) RETURN NUMBER
IS
l_to_duration NUMBER:=0;
l_hours NUMBER:= 0;
BEGIN
    IF (p_from_duration_units = 'Y') THEN
        l_hours := p_from_duration * g_hours_per_year;
    ELSIF (p_from_duration_units = 'M') THEN
        l_hours := p_from_duration * g_hours_per_month;
    ELSIF (p_from_duration_units = 'W') THEN
        l_hours := p_from_duration * g_hours_per_week;
    ELSIF (p_from_duration_units = 'D') THEN
        l_hours := p_from_duration * g_hours_per_day;
    ELSIF (p_from_duration_units = 'H') THEN
        l_hours := p_from_duration;
    ELSE
        l_hours := 0;
    END IF;

    IF (p_to_duration_units = 'H') THEN
        l_to_duration := l_hours;
    ELSIF (p_to_duration_units = 'D') THEN
        l_to_duration := l_hours / g_hours_per_day;
    ELSIF (p_to_duration_units = 'W') THEN
        l_to_duration := l_hours / g_hours_per_week;
    ELSIF (p_to_duration_units = 'M') THEN
        l_to_duration := l_hours / g_hours_per_month;
    ELSIF (p_to_duration_units = 'Y') THEN
        l_to_duration := l_hours / g_hours_per_year;
    ELSE
        l_to_duration := 0;
    END IF;

    RETURN l_to_duration;

END convertDuration;

PROCEDURE openClassesCsr(
    p_cursor IN OUT NOCOPY cur_typ
   ,p_mode IN NUMBER
   ,p_person_id IN NUMBER
   ,p_eff_date IN DATE) IS
query_str VARCHAR2(4000);
BEGIN
    query_str := 'SELECT '||
                 'sum(hr_mee_views_gen.convertDuration(evt.duration_units, ''H'',evt.duration)) '||
                 'FROM ota_booking_status_types bst, '||
                 '     ota_events evt, ota_delegate_bookings db '||
                 'WHERE db.booking_status_type_id = bst.booking_status_type_id '||
                 'AND db.event_id = evt.event_id '||
                 'AND db.delegate_person_id = :1 ';

    IF (p_mode = 0) THEN -- Classes Taken
     query_str := query_str ||
        'AND bst.type = ''A'' '||
        'AND evt.course_start_date <= :2 ';
     OPEN p_cursor FOR query_str USING p_person_id, p_eff_date;
    ELSIF (p_mode = 1) THEN -- Classes Taken YTD
     query_str := query_str ||
        'AND bst.type = ''A'' '||
        'AND evt.course_start_date between :2 and :3';
     OPEN p_cursor FOR query_str USING p_person_id, getYearStart, p_eff_date;
    END IF;
END openClassesCsr;

PROCEDURE openTrngCostCsr(
    p_cursor IN OUT NOCOPY cur_typ
   ,p_mode IN NUMBER
   ,p_person_id IN NUMBER
   ,p_eff_date IN DATE) IS
query_str VARCHAR2(4000);
BEGIN
    query_str := 'SELECT SUM(hr_mee_views_gen.amtInLoginPrsnCurrency(evt.currency_code, fl.money_amount, evt.course_start_date)) '||
                 'FROM ota_delegate_bookings db, '||
                 '     ota_events evt, ota_finance_lines fl '||
                 'WHERE db.booking_id = fl.booking_id(+) '||
                 'AND nvl(fl.cancelled_flag(+),''N'') = ''N'' '||
                 'AND db.event_id = evt.event_id '||
                 'AND db.delegate_person_id = :1 ';

    IF (p_mode = 0) THEN -- Total Cost
     query_str := query_str ||
        'AND evt.course_start_date <= :2 ';
     OPEN p_cursor FOR query_str USING p_person_id, p_eff_date;
    ELSIF (p_mode = 1) THEN -- Total Cost YTD
     query_str := query_str ||
        'AND evt.course_start_date between :2 and :3';
     OPEN p_cursor FOR query_str USING p_person_id, getYearStart, p_eff_date;
    END IF;
END openTrngCostCsr;

PROCEDURE openReqClassesCsr(
    p_cursor IN OUT NOCOPY cur_typ
   ,p_mode IN NUMBER
   ,p_person_id IN NUMBER
   ,p_eff_date IN DATE) IS
query_str VARCHAR2(4000);
BEGIN
    query_str :=  'SELECT count(db.booking_id) '||
                  'FROM ota_booking_status_types bst, '||
                  '     ota_events evt, ota_delegate_bookings db '||
                  'WHERE db.booking_status_type_id = bst.booking_status_type_id '||
                  'AND db.event_id = evt.event_id '||
                  'AND EXISTS (SELECT ''e'' '||
                              'FROM ota_training_plans tp, ota_training_plan_members tpm '||
                              'WHERE tp.person_id = db.delegate_person_id '||
                              'AND tp.person_id <> tp.creator_person_id '||
                              'AND tp.training_plan_id = tpm.training_plan_id '||
                              'AND tpm.activity_version_id = evt.activity_version_id) '||
                   'AND db.delegate_person_id = :1 ';


     IF (p_mode = 0) THEN -- Classes Req By Mgr
      query_str := query_str ||
        'AND evt.course_start_date <= :2 ';
      OPEN p_cursor FOR query_str USING p_person_id, p_eff_date;
     ELSIF (p_mode = 1) THEN -- Classes Req By Mgr YTD
      query_str := query_str ||
        'AND evt.course_start_date between :2 and :3';
        OPEN p_cursor FOR query_str USING p_person_id, getYearStart, p_eff_date;
     ELSIF (p_mode = 2) THEN -- Classes Req By Mgr Completed
      query_str := query_str ||
        'AND bst.type = ''A'' '||
        'AND evt.course_start_date <= :2 ';
      OPEN p_cursor FOR query_str USING p_person_id, p_eff_date;
     ELSIF (p_mode = 3) THEN -- Classes Req By Mgr Completed YTD
      query_str := query_str ||
        'AND bst.type = ''A'' '||
        'AND evt.course_start_date between :2 and :3';
        OPEN p_cursor FOR query_str USING p_person_id, getYearStart, p_eff_date;
     ELSIF (p_mode = 4) THEN -- Classes Req By Mgr Enrolled
      query_str := query_str ||
        'AND bst.type not in (''C'') '||
        'AND evt.course_start_date <= :2 ';
        OPEN p_cursor FOR query_str USING p_person_id, p_eff_date;
     END IF;
END openReqClassesCsr;

FUNCTION getAnnualSalary(p_person_id IN NUMBER) RETURN NUMBER IS
  CURSOR c_salary IS
  SELECT decode(ppb.pay_annualization_factor,
          null, 1,
          0, 1,
          ppb.pay_annualization_factor) * ppp.proposed_salary_n
        ,petf.input_currency_code
  FROM per_pay_bases ppb, per_assignments_f paf
      ,per_pay_proposals ppp, pay_input_values_f ivf, pay_element_types_f petf
  WHERE paf.person_id = p_person_id
  AND paf.primary_flag = 'Y'
  AND paf.assignment_type = 'E'
  AND ppb.input_value_id = ivf.input_value_id
  AND ivf.element_type_id = petf.element_type_id
  AND ppp.change_date BETWEEN ivf.effective_start_date AND ivf.effective_end_date
  AND ppp.change_date BETWEEN petf.effective_start_date AND petf.effective_end_date
  AND ppp.change_date BETWEEN paf.effective_start_date AND paf.effective_end_date
  AND ppp.assignment_id = paf.assignment_id
  AND ppp.change_date = (SELECT max(change_date) FROM per_pay_proposals ippp
                         WHERE ippp.assignment_id = paf.assignment_id
                         AND ippp.approved = 'Y'
                         AND ippp.change_date <= getEffDate)
  AND ppb.pay_basis_id  = paf.pay_basis_id;

  l_salary NUMBER:= 0;
  l_currency VARCHAR2(10);

BEGIN
   OPEN c_salary;
    FETCH c_salary INTO l_salary, l_currency ;
   CLOSE c_salary;
   If (l_salary > 0) THEN
    l_salary := amtInLoginPrsnCurrency(l_currency, l_salary, getEffDate);
   End If;
   return l_salary;
   Exception When Others then
    return 0;
END getAnnualSalary;

FUNCTION getAvgClassesPerYear(p_person_id IN NUMBER) RETURN NUMBER
IS
BEGIN
    RETURN round(getClassesTaken(p_person_id)/getYOSDenominator(p_person_id),2);
END getAvgClassesPerYear;

FUNCTION getTrngDays(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    RETURN nvl(convertDuration('H','D',getTrngHrs(p_person_id)),0);
    Exception When Others then
        return 0;
END getTrngDays;

FUNCTION getTrngDaysYTD(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    openClassesCsr(
        l_cursor
       ,1
       ,p_person_id
       ,getEffDate);
    FETCH l_cursor INTO l_cnt;
    CLOSE l_cursor;
    RETURN nvl(convertDuration('H','D',l_cnt),0);
    Exception When Others then
        return 0;
END getTrngDaysYTD;

FUNCTION getTrngHrs(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    openClassesCsr(
        l_cursor
       ,0
       ,p_person_id
       ,getEffDate);
    FETCH l_cursor INTO l_cnt;
    CLOSE l_cursor;
    RETURN (nvl(l_cnt,0));
    Exception When Others then
        return 0;
END getTrngHrs;

FUNCTION getTrngCost(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    openTrngCostCsr(
        l_cursor
       ,0
       ,p_person_id
       ,getEffDate);
    FETCH l_cursor INTO l_cnt;
    CLOSE l_cursor;
    RETURN (nvl(l_cnt,0));
    Exception When Others then
        return 0;
END getTrngCost;

FUNCTION getTrngCostYTD(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    openTrngCostCsr(
        l_cursor
       ,0
       ,p_person_id
       ,getEffDate);
    FETCH l_cursor INTO l_cnt;
    CLOSE l_cursor;
    RETURN (nvl(l_cnt,0));
    Exception When Others then
        return 0;
END getTrngCostYTD;

FUNCTION get_training_center (p_training_center_id in number)
return varchar2
IS
l_training_center hr_all_organization_units.name%TYPE;

CURSOR c_get_training_center
IS
SELECT  org.name
FROM  hr_all_organization_units org, hr_organization_information ori
WHERE org.organization_id = p_training_center_id
      AND org.organization_id = ori.organization_id
      AND ori.org_information_context = 'CLASS'
      AND ori.org_information1 ='OTA_TC';

BEGIN
  For a in c_get_training_center
 loop
   l_training_center := a.name;
 end loop;
 return(l_training_center);

END get_training_center ;

FUNCTION getTrngPrctOnPayroll(p_person_id IN NUMBER) RETURN NUMBER
IS
l_percent NUMBER:=0;
BEGIN
    l_percent := getAnnualSalary(p_person_id);
    If (l_percent > 0) Then
        l_percent := round((getTrngCostYTD(p_person_id)/l_percent)*100,2);
    End IF;
    return l_percent;
END getTrngPrctOnPayroll;

FUNCTION getLoginPrsnCurrencyCode RETURN VARCHAR2
IS
BEGIN
  if(fnd_profile.value('ICX_PREFERRED_CURRENCY') is not null and fnd_profile.value('ICX_PREFERRED_CURRENCY') <> 'ANY') then
    return fnd_profile.value('ICX_PREFERRED_CURRENCY');
  else
    return hr_util_misc_ss.g_loginPrsnCurrencyCode;
  end if;
END;

FUNCTION getCompRatio(
    p_from_currency IN VARCHAR2
   ,p_to_currency IN VARCHAR2
   ,p_annual_salary IN NUMBER
   ,p_annual_grade_mid_value IN NUMBER
   ,p_eff_date IN DATE
   ) RETURN NUMBER IS
BEGIN
  IF (p_annual_salary IS NOT NULL AND
      p_annual_grade_mid_value > 0 AND
      p_to_currency IS NOT NULL) THEN
    return round((p_annual_salary * 100) / convertAmount(
                                        nvl(p_from_currency,p_to_currency)
                                       ,p_to_currency
                                       ,p_annual_grade_mid_value
                                       ,p_eff_date),3);
  END IF;
  return NULL;
END getCompRatio;

Function getCompRatio(
    p_from_currency IN VARCHAR2
   ,p_to_currency IN VARCHAR2
   ,p_assignment_id in number
   ,P_Effective_Date  in date
   ,p_proposed_salary IN NUMBER
   ,p_pay_annual_factor IN number
   ,p_pay_basis in varchar2
   ,p_grade_annual_factor  in number
   ,p_grade_basis  in varchar2
   ,p_grade_mid_value  in number
   ) return number is
    l_fte_profile_value VARCHAR2(30) := fnd_profile.VALUE('PER_ANNUAL_SALARY_ON_FTE');
    l_pay_factor number;
    l_fte_factor  NUMBER;
    ln_annual_salary NUMBER;
    ln_grade_mid_point number;
    l_compratio	number;
begin
   l_pay_factor := p_pay_annual_factor;
   if (p_pay_annual_factor is null OR p_pay_annual_factor = 0) then
      l_pay_factor := 1;
   end if;
   if (p_pay_basis = 'HOURLY' and p_grade_basis = 'HOURLY') then
      ln_annual_salary := p_proposed_salary;
      ln_grade_mid_point := p_grade_mid_value;
    elsif ((l_fte_profile_value is null OR l_fte_profile_value = 'Y') AND p_pay_basis <> 'HOURLY') then
       l_fte_factor := per_saladmin_utility.get_fte_factor(p_assignment_id,P_Effective_Date);
       ln_annual_salary := (p_proposed_salary * l_pay_factor)/l_fte_factor;
       ln_grade_mid_point := p_grade_mid_value*p_grade_annual_factor;
    else
       ln_annual_salary := p_proposed_salary * l_pay_factor;
       ln_grade_mid_point := p_grade_mid_value*p_grade_annual_factor;
    end if;
     l_compratio := getCompRatio(
               p_from_currency	=> p_from_currency,
               p_to_currency	=> p_to_currency,
               p_annual_salary	=> ln_annual_salary,
               p_annual_grade_mid_value => ln_grade_mid_point,
               p_eff_date	=> P_Effective_Date);
     return l_compratio;
END;

/*
    Modded to use hr_util_misc_ss.get_in_preferred_currency_num
    Check its description for the functionality
*/
FUNCTION convertAmount(
    p_from_currency IN VARCHAR2
   ,p_to_currency IN VARCHAR2
   ,p_amount IN NUMBER
   ,p_eff_Date IN DATE DEFAULT NULL
   ) RETURN NUMBER IS
   l_eff_date DATE;
BEGIN
    return hr_util_misc_ss.get_in_preferred_currency_num(
            p_amount
           ,p_from_currency
           ,p_eff_Date
           ,p_to_currency);
END convertAmount;

/*
     This function returns grade min,mid,max and comparatio as of sysdate
*/
FUNCTION get_grade_details(
    p_assignment_id IN number,
    p_mode in varchar2
   ) RETURN NUMBER IS

cursor c_grade_details is

select gr.currency_code, gr.minimum, gr.mid_value, gr.maximum, petf.input_currency_code,
           pb.grade_annualization_factor, ppp.proposed_salary_n, pb.pay_annualization_factor
from pay_input_values_f ivf, pay_element_types_f petf, pay_grade_rules_f gr,
        per_pay_bases pb, per_assignments_f paf, per_pay_proposals ppp
where paf.assignment_id = p_assignment_id
          AND paf.pay_basis_id = pb.pay_basis_id
          and paf.assignment_id = ppp.assignment_id(+)
          and pb.input_value_id = ivf.input_value_id
          and ivf.element_type_id = petf.element_type_id
         AND pb.rate_id = gr.rate_id
         AND paf.grade_id = gr.grade_or_spinal_point_id
         and ppp.approved(+) = 'Y'
         and sysdate between paf.effective_start_date and paf.effective_end_date
         and sysdate between ppp.change_date(+) and ppp.date_to(+)
         and sysdate between ivf.effective_start_date and ivf.effective_end_date
         and sysdate between petf.effective_start_date and petf.effective_end_date
        AND sysdate between gr.effective_start_date and gr.effective_end_date;

l_gr_currency varchar2(20);
l_gr_min      varchar2(20);
l_gr_mid      varchar2(20);
l_gr_max      varchar2(20);
l_currency    varchar2(20);
l_gr_factor   number;
l_salary      number;
l_pay_factor  number;
l_comp_ratio  number;

BEGIN

open c_grade_details;
fetch c_grade_details into l_gr_currency, l_gr_min, l_gr_mid, l_gr_max, l_currency,
                        l_gr_factor, l_salary, l_pay_factor;
close c_grade_details;

if (l_pay_factor is null OR l_pay_factor = 0) then
    l_pay_factor := 1;
end if;

if (p_mode = 'MIN' and l_gr_min > 0) then
    l_gr_min := convertAmount(nvl(l_gr_currency,l_currency),l_currency,
        l_gr_factor * l_gr_min,sysdate);
    return l_gr_min;
end if;

if (p_mode = 'MID' and l_gr_mid > 0) then
    l_gr_mid := convertAmount(nvl(l_gr_currency,l_currency),l_currency,
        l_gr_factor * l_gr_mid,sysdate);
    return l_gr_mid;
end if;

if (p_mode = 'MAX' and l_gr_max > 0) then
    l_gr_max := convertAmount(nvl(l_gr_currency,l_currency),l_currency,
        l_gr_factor * l_gr_max,sysdate);
    return l_gr_max;
end if;

if (p_mode = 'COMPARATIO') then
    l_comp_ratio := getCompRatio(nvl(l_gr_currency,l_currency),l_currency,
        l_salary * l_pay_factor, l_gr_factor * l_gr_mid, sysdate);
    return l_comp_ratio;
end if;

return null;

exception
    when others then
        return 0;
END get_grade_details;

function get_step_details(
    p_step_id in number,
    p_eff_date in date,
    p_mode in varchar2
    ) return varchar2 is

cursor c_step_details is
select pgr.value , psp.spinal_point
from pay_grade_rules_f pgr, per_spinal_points psp, per_spinal_point_steps_f psps
where psps.step_id = p_step_id and psps.spinal_point_id=psp.spinal_point_id
and pgr.grade_or_spinal_point_id=psps.spinal_point_id  and pgr.rate_type='SP'
and p_eff_date between pgr.effective_start_date and pgr.effective_end_date
and p_eff_date between  psps.effective_start_date and psps.effective_end_date;

l_step_value    varchar2(20);
l_point         varchar2(20);

begin

open c_step_details;
fetch c_step_details into l_step_value, l_point;
close c_step_details;

if (p_mode = 'STEP_VALUE') then
    return l_step_value;
end if;
if (p_mode = 'POINT') then
    return l_point;
end if;
return null;

exception
    when others then
        return 0;
end get_step_details;

function get_step_num(
    p_step_id in number,
    p_eff_date in date
    ) return number is

cursor c_step_num is
select (nvl(gs.starting_step,1) + count(*))-1 step
from per_spinal_point_steps_f psps, per_spinal_point_steps_f psps2, per_grade_spines_f gs
where psps.step_id = p_step_id
and p_eff_date between psps.effective_start_date and psps.effective_end_date
and p_eff_date between psps2.effective_start_date and psps2.effective_end_date
and p_eff_date between gs.effective_start_date and gs.effective_end_date
and    psps.grade_spine_id = psps2.grade_spine_id
and    psps.grade_spine_id = gs.grade_spine_id
and    psps.sequence >= psps2.sequence
group by gs.starting_step;

l_step    number;

begin

open c_step_num;
fetch c_step_num into l_step;
close c_step_num;

if (l_step = 0) then
    return null;
end if;
return l_step;

exception
    when others then
        return 0;
end get_step_num;

/*
    Note: This function actually converts into the preferred currency and in case one is not set, it uses the login person bg currency
*/
FUNCTION amtInLoginPrsnCurrency(
    p_from_currency IN VARCHAR2
   ,p_amount IN NUMBER
   ,p_eff_date IN DATE
) RETURN NUMBER IS
BEGIN
    return convertAmount(
            p_from_currency
           ,getLoginPrsnCurrencyCode
           ,p_amount
           ,p_eff_date);
END amtInLoginPrsnCurrency;

FUNCTION getReqClasses(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    openReqClassesCsr(
        l_cursor
       ,0
       ,p_person_id
       ,getEffDate);
    FETCH l_cursor INTO l_cnt;
    CLOSE l_cursor;
    RETURN (l_cnt);
    Exception When Others then
        return 0;
END getReqClasses;

FUNCTION getReqClassesYTD(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    openReqClassesCsr(
        l_cursor
       ,1
       ,p_person_id
       ,getEffDate);
    FETCH l_cursor INTO l_cnt;
    CLOSE l_cursor;
    RETURN (l_cnt);
    Exception When Others then
        return 0;
END getReqClassesYTD;

FUNCTION getReqClassesCompleted(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    openReqClassesCsr(
        l_cursor
       ,2
       ,p_person_id
       ,getEffDate);
    FETCH l_cursor INTO l_cnt;
    CLOSE l_cursor;
    RETURN (l_cnt);
    Exception When Others then
        return 0;
END getReqClassesCompleted;

FUNCTION getReqClassesCompletedYTD(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    openReqClassesCsr(
        l_cursor
       ,3
       ,p_person_id
       ,getEffDate);
    FETCH l_cursor INTO l_cnt;
    CLOSE l_cursor;
    RETURN (l_cnt);
    Exception When Others then
        return 0;
END getReqClassesCompletedYTD;

FUNCTION getReqClassesEnrolled(p_person_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN
    openReqClassesCsr(
        l_cursor
       ,3
       ,p_person_id
       ,getEffDate);
    FETCH l_cursor INTO l_cnt;
    CLOSE l_cursor;
    RETURN (l_cnt);
    Exception When Others then
        return 0;
END getReqClassesEnrolled;

FUNCTION getLoginPrsnBusGrpId RETURN NUMBER IS
BEGIN
 return hr_util_misc_ss.g_loginPrsnBGId;
END;

FUNCTION getEffDate
RETURN DATE
IS
BEGIN
 RETURN nvl(hr_util_misc_ss.g_eff_date,sysdate);
END getEffDate;

FUNCTION getAsgGradeRule(p_pay_proposal_id IN NUMBER) RETURN ROWID IS
l_rowid ROWID:=NULL;
CURSOR c_graderule IS
  SELECT gr.rowid
  FROM  per_pay_proposals ppp, per_assignments_f paf
       ,per_pay_bases pb, pay_grade_rules_f gr
  WHERE ppp.pay_proposal_id = p_pay_proposal_id
  AND ppp.assignment_id = paf.assignment_id
  AND ppp.change_date between paf.effective_start_date and paf.effective_end_date
  AND paf.pay_basis_id = pb.pay_basis_id
  AND pb.rate_id = gr.rate_id
  AND paf.grade_id = gr.grade_or_spinal_point_id
  AND ppp.change_date between gr.effective_start_date and gr.effective_end_date;
BEGIN
  OPEN c_graderule;
      FETCH c_graderule INTO l_rowid;
  CLOSE c_graderule;
  RETURN l_rowid;
  Exception When Others then
    RETURN NULL;
END getAsgGradeRule;

FUNCTION getAsgProposalId(p_assignment_id IN NUMBER) RETURN NUMBER IS
l_proposal_id Number := -1;
CURSOR c_proposal IS
  SELECT nvl(max(pay_proposal_id),-1)
  FROM  per_pay_proposals ppp, fnd_sessions fs
  WHERE fs.session_id = userenv('sessionid')
  AND ppp.assignment_id = p_assignment_id
  AND ppp.approved = 'Y'
  AND fs.effective_date between ppp.change_date and ppp.date_to;
BEGIN
  OPEN c_proposal;
      FETCH c_proposal INTO l_proposal_id;
  CLOSE c_proposal;
  Return l_proposal_id;
  Exception When Others then
    Return -1;
END getAsgProposalId;

FUNCTION getPrsnApplicationId(p_person_id IN NUMBER) RETURN NUMBER IS
l_application_id Number := -1;
CURSOR c_applications IS
  SELECT nvl(max(application_id),-1)
  FROM  per_applications, fnd_sessions fs
  WHERE fs.session_id = userenv('sessionid')
  AND person_id = p_person_id
  AND fs.effective_date between date_received and nvl(date_end,fs.effective_date);

BEGIN
  OPEN c_applications;
      FETCH c_applications INTO l_application_id;
  CLOSE c_applications;
  Return l_application_id;
  Exception When Others then
    Return -1;
END getPrsnApplicationId;

FUNCTION getPrsnPerformanceId(p_person_id IN NUMBER) RETURN NUMBER IS
l_perf_id Number := -1;

CURSOR c_performance_reviews IS
 SELECT nvl(max(performance_review_id),-1)
  FROM per_performance_reviews pr
  WHERE pr.person_id = p_person_id
  AND pr.review_date = (SELECT max(review_date)
                        FROM per_performance_reviews ipr, fnd_sessions fs
                        WHERE fs.session_id = userenv('sessionid')
                        AND ipr.person_id = pr.person_id
                        AND ipr.review_date <= fs.effective_date);

BEGIN
  OPEN c_performance_reviews;
      FETCH c_performance_reviews INTO l_perf_id;
  CLOSE c_performance_reviews;
  Return l_perf_id;
  Exception When Others then
    Return -1;
END getPrsnPerformanceId;

  /*
  ||===========================================================================
  || FUNCTION: get_display_job_name
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Calls get_job_info and returns the job name
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_display_job_name(p_job_id IN per_assignments_f.job_id%TYPE)
RETURN VARCHAR2
IS

  l_name            varchar2(100) ;
  l_org_name        varchar2(50) ;
  l_location_code   varchar2(50) ;

BEGIN

  hr_suit_match_utility_web.get_job_info
    (p_search_type      => hr_suit_match_utility_web.g_job_type
    ,p_id               => to_char(p_job_id)
    ,p_name             => l_name
    ,p_org_name         => l_org_name
    ,p_location_code    => l_location_code    ) ;

  return l_name ;

END get_display_job_name;

  /*
  ||===========================================================================
  || FUNCTION: get_total_absences
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns the total absences for a given person_id.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_total_absences(p_person_id IN NUMBER)
RETURN NUMBER
IS

  ln_result NUMBER;

 CURSOR lc_get_absences (p_person_id IN per_people_f.person_id%TYPE)
  IS
  SELECT count(att.absence_attendance_id) total_number_of_absences
  FROM per_absence_attendances att
  WHERE  att.person_id = p_person_id;

BEGIN

  OPEN lc_get_absences(p_person_id => p_person_id);
  FETCH lc_get_absences
  INTO ln_result;

  IF lc_get_absences%NOTFOUND OR lc_get_absences%NOTFOUND IS NULL
  THEN
    ln_result := 0;
  END IF;
  CLOSE lc_get_absences;
  RETURN (ln_result);

END get_total_absences;

  /*
  ||===========================================================================
  || FUNCTION: get_total_absence_days
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns the total absence days for a given person_id.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_total_absence_days(p_person_id IN NUMBER)
RETURN NUMBER
IS

  ln_result NUMBER;

  CURSOR lc_get_absences (p_person_id IN per_people_f.person_id%TYPE)
  IS
  SELECT sum(NVL(att.absence_days,0)) total_absence_days
  FROM per_absence_attendances att
  WHERE att.person_id = p_person_id;

BEGIN
  OPEN lc_get_absences(p_person_id => p_person_id);
  FETCH lc_get_absences
  INTO ln_result;

  IF lc_get_absences%NOTFOUND OR lc_get_absences%NOTFOUND IS NULL
  THEN
    ln_result := 0;
  END IF;
  CLOSE lc_get_absences;
  RETURN NVL(ln_result,0);

END get_total_absence_days;

  /*
  ||===========================================================================
  || FUNCTION: get_total_absence_days
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns the total absence days for a given person_id.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_total_absence_hours(p_person_id IN NUMBER)
RETURN NUMBER
IS

  ln_result NUMBER;

  CURSOR lc_get_absences (p_person_id IN per_people_f.person_id%TYPE)
  IS
  SELECT sum(NVL(att.absence_hours,0)) total_absence_hours
  FROM per_absence_attendances att
  WHERE  att.person_id = p_person_id;

BEGIN
  OPEN lc_get_absences(p_person_id => p_person_id);
  FETCH lc_get_absences
  INTO ln_result;

  IF lc_get_absences%NOTFOUND OR lc_get_absences%NOTFOUND IS NULL
  THEN
    ln_result := 0;
  END IF;
  CLOSE lc_get_absences;
  RETURN NVL(ln_result,0);

END get_total_absence_hours;

FUNCTION getYOSDenominator(p_person_id IN NUMBER) RETURN NUMBER IS
l_yos NUMBER:=0;
BEGIN
    l_yos := getYOS(p_person_id);
    IF (l_yos > 0) THEN
        return l_yos;
    END IF;
    RETURN 1;
END getYOSDenominator;

FUNCTION getYOS(
    p_person_id IN NUMBER
   ,p_eff_date IN DATE Default getEffDate)
RETURN NUMBER
IS
  ln_result NUMBER:=0;

  CURSOR c_yos (p_person_id IN per_people_f.person_id%TYPE)
  IS
  SELECT ROUND(SUM(MONTHS_BETWEEN(
		decode(sign(p_eff_date-nvl(actual_termination_date, p_eff_date)),
                           -1, trunc(p_eff_date), nvl(actual_termination_date, trunc(p_eff_date))),
                trunc(ser.date_start))/12), 2) yos
  FROM per_periods_of_service ser
  WHERE ser.person_id = p_person_id
  AND ser.date_start <= p_eff_date;

BEGIN
  OPEN c_yos(p_person_id => p_person_id);
  FETCH c_yos INTO ln_result;
  CLOSE c_yos;

  IF ln_result < 1/365
  THEN ln_result := ROUND(1/365,2);
  END IF;

  RETURN ln_result;
  Exception When Others then
    return 0;
END getYOS;

  /*
  ||===========================================================================
  || FUNCTION: get_years_of_service
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns the total years of service for a given person_id.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_years_of_service(p_person_id IN NUMBER)
RETURN NUMBER
IS
BEGIN
  return getYOS(p_person_id, sysdate);
END get_years_of_service;

/*Enhancement for bug 5259269*/
/*
  ||===========================================================================
  || FUNCTION: getAYOS
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns the Adjusted Years of Service based on Adjusted Service Date.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION getAYOS(
    p_person_id IN NUMBER
   ,p_eff_date IN DATE Default getEffDate)
RETURN NUMBER
IS
  ln_result NUMBER;

  CURSOR c_ayos (p_person_id IN per_people_f.person_id%TYPE)
  IS
  SELECT ROUND(MONTHS_BETWEEN(
		decode(sign(p_eff_date-nvl(actual_termination_date, p_eff_date)),
                           -1, trunc(p_eff_date), nvl(actual_termination_date, trunc(p_eff_date))),
                trunc(ser.adjusted_svc_date))/12, 2) ayos
  FROM per_periods_of_service ser
  WHERE ser.person_id = p_person_id
  AND p_eff_date between ser.date_start and nvl(ser.actual_termination_date, p_eff_date);

BEGIN
  OPEN c_ayos(p_person_id => p_person_id);
  FETCH c_ayos INTO ln_result;
  CLOSE c_ayos;

  IF ln_result < 1/365
  THEN ln_result := ROUND(1/365,2);
  END IF;

  RETURN ln_result;
  Exception When Others then
    return 0;
END getAYOS;


  /*
  ||===========================================================================
  || FUNCTION: get_last_application_date
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns the last application date for a given person_id.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_last_application_date(p_person_id IN NUMBER)
RETURN DATE
IS

  ln_result DATE;

  CURSOR lc_get_lad (p_person_id IN per_people_f.person_id%TYPE)
  IS
    SELECT MAX(pa.date_received)
    FROM per_applications pa,
         per_assignments_f ass
    WHERE ass.application_id = pa.application_id
    AND   ass.assignment_type = 'A'
    AND   ass.person_id = p_person_id;

BEGIN
  OPEN lc_get_lad(p_person_id => p_person_id);
  FETCH lc_get_lad
  INTO ln_result;

  IF lc_get_lad%NOTFOUND OR lc_get_lad%NOTFOUND IS NULL
  THEN
    ln_result := '';
  END IF;
  CLOSE lc_get_lad;
  RETURN (ln_result);

END get_last_application_date;

FUNCTION getClassesTaken(
    p_person_id IN NUMBER
   ,p_eff_date IN DATE Default getEffDate
   )
RETURN NUMBER
IS
  ln_result NUMBER:= 0;

 CURSOR c_classes (p_person_id IN per_people_f.person_id%TYPE)
  IS
  SELECT count(db.booking_id)
  FROM   ota_booking_status_types bst,
         ota_events evt, ota_delegate_bookings db
  WHERE  db.booking_status_type_id = bst.booking_status_type_id
  AND db.event_id = evt.event_id
  AND evt.course_start_date <= p_eff_date
  AND bst.type = 'A'
  AND db.delegate_person_id = p_person_id;

BEGIN
  OPEN c_classes(p_person_id => p_person_id);
  FETCH c_classes INTO ln_result;
  CLOSE c_classes;
  RETURN (ln_result);
  Exception When Others then
    return 0;
END getClassesTaken;

FUNCTION getFutureClasses(
    p_person_id IN NUMBER
   ,p_eff_date IN DATE Default getEffDate
   )
RETURN NUMBER
IS
  ln_result NUMBER:= 0;

 CURSOR c_classes (p_person_id IN NUMBER) IS
  SELECT count(tdb.booking_id)
  FROM   ota_booking_status_types bst,
         ota_events evt, ota_delegate_bookings tdb
  WHERE  tdb.booking_status_type_id = bst.booking_status_type_id
  AND tdb.event_id = evt.event_id
  AND evt.course_start_date > p_eff_date
  AND bst.type NOT IN ('C')
  AND tdb.delegate_person_id = p_person_id;

BEGIN
  OPEN c_classes(p_person_id => p_person_id);
  FETCH c_classes INTO ln_result;
  CLOSE c_classes;
  RETURN (ln_result);
  Exception When Others then
    return 0;
END getFutureClasses;

FUNCTION get_past_classes(p_person_id IN NUMBER)
RETURN NUMBER
IS
BEGIN
  return getClassesTaken(p_person_id, trunc(sysdate));
END get_past_classes;


FUNCTION get_future_classes(p_person_id IN NUMBER)
RETURN NUMBER IS
BEGIN
    return getFutureClasses(p_person_id, trunc(sysdate));
END get_future_classes;

  /*
  ||===========================================================================
  || FUNCTION: get_other_classes
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns the total other classes for a given person_id.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_other_classes(p_person_id IN NUMBER)
RETURN NUMBER
IS

  ln_result NUMBER;

 CURSOR lc_get_other_classes (p_person_id IN per_people_f.person_id%TYPE)
  IS
  SELECT count(tdb.booking_id)
  FROM   ota_booking_status_types bst,
         ota_delegate_bookings tdb
  WHERE  tdb.booking_status_type_id = bst.booking_status_type_id
  AND    bst.type IN ('R','C')
  AND    tdb.delegate_person_id = p_person_id;

BEGIN

  OPEN lc_get_other_classes(p_person_id => p_person_id);
  FETCH lc_get_other_classes
  INTO ln_result;

  IF lc_get_other_classes%NOTFOUND OR lc_get_other_classes%NOTFOUND IS NULL
  THEN
    ln_result := 0;
  END IF;
  CLOSE lc_get_other_classes;
  RETURN (ln_result);

END get_other_classes;

  /*
  ||===========================================================================
  || FUNCTION: get_currency
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns the currency for a given assignment id at a required date.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_currency(p_assignment_id IN per_assignments_f.assignment_id%TYPE
                     ,p_change_date   IN DATE)
RETURN pay_element_types_f.input_currency_code%TYPE
IS

  lv_result pay_element_types_f.input_currency_code%TYPE;

  CURSOR lc_get_currency(p_assign_id   IN per_assignments_f.assignment_id%TYPE
                        ,p_change_date IN DATE)
  IS
  SELECT pet.input_currency_code
  FROM   pay_element_types_f   pet
  ,      pay_input_values_f    piv
  ,      per_pay_bases         ppb
  ,      per_assignments_f     paf
  WHERE paf.assignment_id   =       p_assign_id
  AND   p_change_date       BETWEEN paf.effective_start_date
                            AND     paf.effective_end_date
  AND   ppb.pay_basis_id    =       paf.pay_basis_id
  AND   ppb.input_value_id  =       piv.input_value_id
  AND   p_change_date       BETWEEN piv.effective_start_date
                            AND     piv.effective_end_date
  AND   piv.element_type_id =       pet.element_type_id
  AND   p_change_date       BETWEEN pet.effective_start_date
                            AND     pet.effective_end_date;

BEGIN

  OPEN  lc_get_currency(p_assign_id   => p_assignment_id
                       ,p_change_date => p_change_date);
  FETCH lc_get_currency
  INTO  lv_result;

  IF lc_get_currency%NOTFOUND OR lc_get_currency%NOTFOUND IS NULL
  THEN
    lv_result := '&nbsp';
  END IF;
  CLOSE lc_get_currency;

  RETURN lv_result;

END get_currency;

  /*
  ||===========================================================================
  || FUNCTION: get_annual_salary
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns the annual salary for a given assignment id at a
  ||     required date.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_annual_salary(
           p_assignment_id IN per_assignments_f.assignment_id%TYPE,
           p_change_date   IN DATE
         )
RETURN VARCHAR2
IS

  ln_result          NUMBER;
  ln_annual_factor   NUMBER;
  ln_proposed_salary NUMBER;
  lv_format_string   VARCHAR2(30);

  CURSOR lc_get_salary(p_assign_id   IN per_assignments_f.assignment_id%TYPE
                      ,p_change_date IN DATE)
  IS
  SELECT ppb.pay_annualization_factor
  ,      ppp.proposed_salary_n
  FROM   per_pay_bases      ppb
  ,      per_assignments_f  paf
  ,      per_pay_proposals  ppp
  WHERE paf.assignment_id = p_assign_id
  AND   p_change_date  BETWEEN paf.effective_start_date
                       AND     NVL(paf.effective_end_date, p_change_date)
  AND   ppp.change_date   = p_change_date
  AND   ppp.assignment_id = paf.assignment_id
  AND   ppb.pay_basis_id  = paf.pay_basis_id;

BEGIN

  OPEN  lc_get_salary(p_assign_id   => p_assignment_id
                     ,p_change_date => p_change_date);
  FETCH lc_get_salary
  INTO  ln_annual_factor, ln_proposed_salary;

  IF lc_get_salary%NOTFOUND OR lc_get_salary%NOTFOUND IS NULL
  THEN
    ln_result := 0;
  END IF;
  CLOSE lc_get_salary;

  IF (ln_annual_factor IS NULL OR ln_annual_factor = 0 ) THEN
    ln_annual_factor := 1;
  END IF;
  ln_result := ln_annual_factor * ln_proposed_salary;

  RETURN NVL(
            TO_CHAR(
               ln_result,
               get_currency_format(
                 p_curcode        => get_currency(
                                       p_assignment_id => p_assignment_id,
                                       p_change_date   => p_change_date
                                     ),
                 p_effective_date => p_change_date
               )
             )
           ,''
         );

END get_annual_salary;

  /*
  ||===========================================================================
  || FUNCTION: get_job
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     If the HR Views responsibilty profiles HR_JOB_KEYFLEX_SEGMENT1 and
  ||     HR_JOB_KEYFLEX_SEGMENT2 are set and enabled then these values will
  ||     be returned.  Otherwise the per_jobs.name value will be returned.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_job(p_job_id IN per_assignments_f.job_id%TYPE)
RETURN VARCHAR2
IS

  -- Job Keyflex Id is stored in org_information6 in
  -- hr_organization_information
  CURSOR lc_get_job_flex_id(p_business_group_id IN  NUMBER)
  IS
  SELECT org_information6
    FROM hr_organization_information
   WHERE organization_id = p_business_group_id
     AND org_information_context = 'Business Group Information';

  CURSOR lc_get_job_details(p_job_id IN per_assignments_f.job_id%TYPE)
  IS
  SELECT pj.name,
         pjd.segment1,
         pjd.segment2,
         pjd.segment3,
         pjd.segment4,
         pjd.segment5,
         pjd.segment6,
         pjd.segment7,
         pjd.segment8,
         pjd.segment9,
         pjd.segment10,
         pjd.segment11,
         pjd.segment12,
         pjd.segment13,
         pjd.segment14,
         pjd.segment15,
         pjd.segment16,
         pjd.segment17,
         pjd.segment18,
         pjd.segment19,
         pjd.segment20,
         pjd.segment21,
         pjd.segment22,
         pjd.segment23,
         pjd.segment24,
         pjd.segment25,
         pjd.segment26,
         pjd.segment27,
         pjd.segment28,
         pjd.segment29,
         pjd.segment30
    FROM per_jobs_vl pj,
         per_job_definitions pjd
   WHERE pj.job_definition_id = pjd.job_definition_id
     AND pj.job_id = p_job_id;

  lv_segment_name1      VARCHAR2(30) DEFAULT NULL;
  lv_segment_name2      VARCHAR2(30) DEFAULT NULL;
  ln_flex_num           NUMBER;
  lv_flex_code          VARCHAR2(3) := 'JOB';
  lv_result             VARCHAR2(240) DEFAULT NULL;
  ltt_segment           hr_mee_views_gen.segmentsTable;
  ln_business_group_id  per_people_f.business_group_id%TYPE;

BEGIN

  --First Get the name from per_jobs and all the segments
  --from per_job_definitions.
  --The name will be returned if no profiles are used.
  FOR segment_rec IN lc_get_job_details(p_job_id => p_job_id)
  LOOP
    ltt_segment(0).value  := segment_rec.name;
    ltt_segment(1).value  := segment_rec.segment1;
    ltt_segment(2).value  := segment_rec.segment2;
    ltt_segment(3).value  := segment_rec.segment3;
    ltt_segment(4).value  := segment_rec.segment4;
    ltt_segment(5).value  := segment_rec.segment5;
    ltt_segment(6).value  := segment_rec.segment6;
    ltt_segment(7).value  := segment_rec.segment7;
    ltt_segment(8).value  := segment_rec.segment8;
    ltt_segment(9).value  := segment_rec.segment9;
    ltt_segment(10).value := segment_rec.segment10;
    ltt_segment(11).value := segment_rec.segment11;
    ltt_segment(12).value := segment_rec.segment12;
    ltt_segment(13).value := segment_rec.segment13;
    ltt_segment(14).value := segment_rec.segment14;
    ltt_segment(15).value := segment_rec.segment15;
    ltt_segment(16).value := segment_rec.segment16;
    ltt_segment(17).value := segment_rec.segment17;
    ltt_segment(18).value := segment_rec.segment18;
    ltt_segment(19).value := segment_rec.segment19;
    ltt_segment(20).value := segment_rec.segment20;
    ltt_segment(21).value := segment_rec.segment21;
    ltt_segment(22).value := segment_rec.segment22;
    ltt_segment(23).value := segment_rec.segment23;
    ltt_segment(24).value := segment_rec.segment24;
    ltt_segment(25).value := segment_rec.segment25;
    ltt_segment(26).value := segment_rec.segment26;
    ltt_segment(27).value := segment_rec.segment27;
    ltt_segment(28).value := segment_rec.segment28;
    ltt_segment(29).value := segment_rec.segment29;
    ltt_segment(30).value := segment_rec.segment30;
  END LOOP;

  lv_segment_name1 := fnd_profile.value('HR_JOB_KEYFLEX_SEGMENT1');
  lv_segment_name2 := fnd_profile.value('HR_JOB_KEYFLEX_SEGMENT2');

  IF lv_segment_name1 IS NULL
  THEN
    RETURN ltt_segment(0).value;--job_name
  END IF;

  ln_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');

  OPEN lc_get_job_flex_id(p_business_group_id => ln_business_group_id);
  FETCH lc_get_job_flex_id INTO ln_flex_num;
  IF lc_get_job_flex_id%NOTFOUND
  THEN
    RETURN ltt_segment(0).value;--job_name
  END IF;
  CLOSE lc_get_job_flex_id;

  hr_mee_views_gen.get_segment_value(
                     p_flex_code       =>  lv_flex_code
                    ,p_flex_num        =>  ln_flex_num
                    ,p_segment_name1   =>  lv_segment_name1
                    ,p_segment_name2   =>  lv_segment_name2
                    ,p_segment         =>  ltt_segment
                    ,p_result          =>  lv_result);

  IF lv_result IS NULL
  THEN
    RETURN ltt_segment(0).value;--job_name
  ELSE
    RETURN lv_result;
  END IF;

END get_job;

  /*
  ||===========================================================================
  || FUNCTION: get_grade
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     If the HR Views responsibilty profiles HR_GRADE_KEYFLEX_SEGMENT1 and
  ||     HR_GRADE_KEYFLEX_SEGMENT2 are set and enabled then these values will
  ||     be returned.  Otherwise the per_grades.name value will be returned.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_grade(p_grade_id IN per_assignments_f.grade_id%TYPE)
RETURN VARCHAR2
IS

  -- Grade Keyflex Id is stored in org_information4 in
  -- hr_organization_information
  CURSOR lc_get_grade_flex_id(p_business_group_id IN  NUMBER)
  IS
  SELECT org_information4
    FROM hr_organization_information
   WHERE organization_id = p_business_group_id
     AND org_information_context = 'Business Group Information';

  CURSOR lc_get_grade_details(p_grade_id IN per_assignments_f.grade_id%TYPE)
  IS
  SELECT pg.name,
         pgd.segment1,
         pgd.segment2,
         pgd.segment3,
         pgd.segment4,
         pgd.segment5,
         pgd.segment6,
         pgd.segment7,
         pgd.segment8,
         pgd.segment9,
         pgd.segment10,
         pgd.segment11,
         pgd.segment12,
         pgd.segment13,
         pgd.segment14,
         pgd.segment15,
         pgd.segment16,
         pgd.segment17,
         pgd.segment18,
         pgd.segment19,
         pgd.segment20,
         pgd.segment21,
         pgd.segment22,
         pgd.segment23,
         pgd.segment24,
         pgd.segment25,
         pgd.segment26,
         pgd.segment27,
         pgd.segment28,
         pgd.segment29,
         pgd.segment30
    FROM per_grades_vl pg,
         per_grade_definitions pgd
   WHERE pg.grade_definition_id = pgd.grade_definition_id
     AND pg.grade_id = p_grade_id;

  lv_segment_name1      VARCHAR2(30) DEFAULT NULL;
  lv_segment_name2      VARCHAR2(30) DEFAULT NULL;
  ln_flex_num           NUMBER;
  lv_flex_code          VARCHAR2(3) := 'GRD';
  lv_result             VARCHAR2(240) DEFAULT NULL;
  ltt_segment           hr_mee_views_gen.segmentsTable;
  ln_business_group_id  per_people_f.business_group_id%TYPE;

BEGIN

  --First Get the name from per_grades and all the segments
  --from per_grade_definitions.
  --The name will be returned if no profiles are used.
  FOR segment_rec IN lc_get_grade_details(p_grade_id => p_grade_id)
  LOOP
    ltt_segment(0).value  := segment_rec.name;
    ltt_segment(1).value  := segment_rec.segment1;
    ltt_segment(2).value  := segment_rec.segment2;
    ltt_segment(3).value  := segment_rec.segment3;
    ltt_segment(4).value  := segment_rec.segment4;
    ltt_segment(5).value  := segment_rec.segment5;
    ltt_segment(6).value  := segment_rec.segment6;
    ltt_segment(7).value  := segment_rec.segment7;
    ltt_segment(8).value  := segment_rec.segment8;
    ltt_segment(9).value  := segment_rec.segment9;
    ltt_segment(10).value := segment_rec.segment10;
    ltt_segment(11).value := segment_rec.segment11;
    ltt_segment(12).value := segment_rec.segment12;
    ltt_segment(13).value := segment_rec.segment13;
    ltt_segment(14).value := segment_rec.segment14;
    ltt_segment(15).value := segment_rec.segment15;
    ltt_segment(16).value := segment_rec.segment16;
    ltt_segment(17).value := segment_rec.segment17;
    ltt_segment(18).value := segment_rec.segment18;
    ltt_segment(19).value := segment_rec.segment19;
    ltt_segment(20).value := segment_rec.segment20;
    ltt_segment(21).value := segment_rec.segment21;
    ltt_segment(22).value := segment_rec.segment22;
    ltt_segment(23).value := segment_rec.segment23;
    ltt_segment(24).value := segment_rec.segment24;
    ltt_segment(25).value := segment_rec.segment25;
    ltt_segment(26).value := segment_rec.segment26;
    ltt_segment(27).value := segment_rec.segment27;
    ltt_segment(28).value := segment_rec.segment28;
    ltt_segment(29).value := segment_rec.segment29;
    ltt_segment(30).value := segment_rec.segment30;
  END LOOP;

  lv_segment_name1 := fnd_profile.value('HR_GRADE_KEYFLEX_SEGMENT1');
  lv_segment_name2 := fnd_profile.value('HR_GRADE_KEYFLEX_SEGMENT2');

  IF lv_segment_name1 IS NULL
  THEN
    RETURN ltt_segment(0).value;--grade_name
  END IF;

  ln_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');

  OPEN lc_get_grade_flex_id(p_business_group_id => ln_business_group_id);
  FETCH lc_get_grade_flex_id INTO ln_flex_num;
  IF lc_get_grade_flex_id%NOTFOUND
  THEN
    RETURN ltt_segment(0).value;--grade_name
  END IF;
  CLOSE lc_get_grade_flex_id;

  hr_mee_views_gen.get_segment_value(
                     p_flex_code       =>  lv_flex_code
                    ,p_flex_num        =>  ln_flex_num
                    ,p_segment_name1   =>  lv_segment_name1
                    ,p_segment_name2   =>  lv_segment_name2
                    ,p_segment         =>  ltt_segment
                    ,p_result          =>  lv_result);

  IF lv_result IS NULL
  THEN
    RETURN ltt_segment(0).value;--grade_name
  ELSE
    RETURN lv_result;
  END IF;

END get_grade;

  /*
  ||===========================================================================
  || FUNCTION: get_position
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     If the HR Views responsibilty profiles HR_POSITION_KEYFLEX_SEGMENT1
  ||     and HR_POSITION_KEYFLEX_SEGMENT2 are set and enabled then these
  ||     values will be returned.
  ||     Otherwise the per_positions.name value will be returned.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_position(p_position_id IN per_assignments_f.position_id%TYPE
				 ,p_effective_date IN DATE DEFAULT TRUNC(SYSDATE))
RETURN VARCHAR2
IS

  -- Position Keyflex Id is stored in org_information8 in
  -- hr_organization_information
  CURSOR lc_get_position_flex_id(p_business_group_id IN  NUMBER)
  IS
  SELECT org_information8
    FROM hr_organization_information
   WHERE organization_id = p_business_group_id
     AND org_information_context = 'Business Group Information';

  CURSOR lc_get_position_details(
           p_position_id IN per_assignments_f.position_id%TYPE
         )
  IS
  SELECT pp.name,
         ppd.segment1,
         ppd.segment2,
         ppd.segment3,
         ppd.segment4,
         ppd.segment5,
         ppd.segment6,
         ppd.segment7,
         ppd.segment8,
         ppd.segment9,
         ppd.segment10,
         ppd.segment11,
         ppd.segment12,
         ppd.segment13,
         ppd.segment14,
         ppd.segment15,
         ppd.segment16,
         ppd.segment17,
         ppd.segment18,
         ppd.segment19,
         ppd.segment20,
         ppd.segment21,
         ppd.segment22,
         ppd.segment23,
         ppd.segment24,
         ppd.segment25,
         ppd.segment26,
         ppd.segment27,
         ppd.segment28,
         ppd.segment29,
         ppd.segment30
    FROM hr_all_positions_f_vl pp,
         per_position_definitions ppd
   WHERE pp.position_definition_id = ppd.position_definition_id
     AND pp.position_id = p_position_id
	AND p_effective_date BETWEEN pp.effective_start_date
	    AND pp.effective_end_date;

  lv_segment_name1      VARCHAR2(30) DEFAULT NULL;
  lv_segment_name2      VARCHAR2(30) DEFAULT NULL;
  ln_flex_num           NUMBER;
  lv_flex_code          VARCHAR2(3) := 'POS';
  lv_result             VARCHAR2(240) DEFAULT NULL;
  ltt_segment           hr_mee_views_gen.segmentsTable;
  ln_business_group_id  per_people_f.business_group_id%TYPE;

BEGIN

  --First Get the name from per_positions and all the segments
  --from per_position_definitions.
  --The name will be returned if no profiles are used.
  FOR segment_rec IN lc_get_position_details(p_position_id => p_position_id)
  LOOP
    ltt_segment(0).value  := segment_rec.name;
    ltt_segment(1).value  := segment_rec.segment1;
    ltt_segment(2).value  := segment_rec.segment2;
    ltt_segment(3).value  := segment_rec.segment3;
    ltt_segment(4).value  := segment_rec.segment4;
    ltt_segment(5).value  := segment_rec.segment5;
    ltt_segment(6).value  := segment_rec.segment6;
    ltt_segment(7).value  := segment_rec.segment7;
    ltt_segment(8).value  := segment_rec.segment8;
    ltt_segment(9).value  := segment_rec.segment9;
    ltt_segment(10).value := segment_rec.segment10;
    ltt_segment(11).value := segment_rec.segment11;
    ltt_segment(12).value := segment_rec.segment12;
    ltt_segment(13).value := segment_rec.segment13;
    ltt_segment(14).value := segment_rec.segment14;
    ltt_segment(15).value := segment_rec.segment15;
    ltt_segment(16).value := segment_rec.segment16;
    ltt_segment(17).value := segment_rec.segment17;
    ltt_segment(18).value := segment_rec.segment18;
    ltt_segment(19).value := segment_rec.segment19;
    ltt_segment(20).value := segment_rec.segment20;
    ltt_segment(21).value := segment_rec.segment21;
    ltt_segment(22).value := segment_rec.segment22;
    ltt_segment(23).value := segment_rec.segment23;
    ltt_segment(24).value := segment_rec.segment24;
    ltt_segment(25).value := segment_rec.segment25;
    ltt_segment(26).value := segment_rec.segment26;
    ltt_segment(27).value := segment_rec.segment27;
    ltt_segment(28).value := segment_rec.segment28;
    ltt_segment(29).value := segment_rec.segment29;
    ltt_segment(30).value := segment_rec.segment30;
  END LOOP;

  lv_segment_name1 := fnd_profile.value('HR_POS_KEYFLEX_SEGMENT1');
  lv_segment_name2 := fnd_profile.value('HR_POS_KEYFLEX_SEGMENT2');

  IF lv_segment_name1 IS NULL
  THEN
    RETURN ltt_segment(0).value;--position_name
  END IF;

  ln_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');

  OPEN lc_get_position_flex_id(p_business_group_id => ln_business_group_id);
  FETCH lc_get_position_flex_id INTO ln_flex_num;
  IF lc_get_position_flex_id%NOTFOUND
  THEN
    RETURN ltt_segment(0).value;--position_name
  END IF;
  CLOSE lc_get_position_flex_id;

  hr_mee_views_gen.get_segment_value(
                     p_flex_code       =>  lv_flex_code
                    ,p_flex_num        =>  ln_flex_num
                    ,p_segment_name1   =>  lv_segment_name1
                    ,p_segment_name2   =>  lv_segment_name2
                    ,p_segment         =>  ltt_segment
                    ,p_result          =>  lv_result);

  IF lv_result IS NULL
  THEN
    RETURN ltt_segment(0).value;--position_name
  ELSE
    RETURN lv_result;
  END IF;

END get_position;


  /*
  ||===========================================================================
  || PROCEDURES: get_segment_result
  ||---------------------------------------------------------------------------
  ||
  || Description: Returns combined segment values if profiles are used.
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */
PROCEDURE get_segment_value( p_flex_code         IN VARCHAR2
                            ,p_flex_num          IN VARCHAR2
                            ,p_segment_name1     IN VARCHAR2 DEFAULT NULL
                            ,p_segment_name2     IN VARCHAR2 DEFAULT NULL
                            ,p_segment           hr_mee_views_gen.segmentsTable
                            ,p_result           OUT nocopy VARCHAR2)
IS

  CURSOR lc_get_segment(p_application_id IN NUMBER,
                        p_flex_code      IN VARCHAR2,
                        p_flex_num       IN NUMBER,
                        p_segment_name   IN VARCHAR2)
  IS
  SELECT application_column_name
    FROM fnd_id_flex_segments_vl
   WHERE application_id = p_application_id
     AND id_flex_code   = p_flex_code
     AND id_flex_num    = p_flex_num
     AND segment_name   = p_segment_name
     AND enabled_flag = 'Y';

  ln_application_id     NUMBER := '800'; --value for PER
  lv_appl_col_name1     VARCHAR2(30) DEFAULT NULL;
  lv_appl_col_name2     VARCHAR2(30) DEFAULT NULL;
  ln_row_counter        NUMBER := 1;
  lv_seg_delimiter      VARCHAR2(10); --2424031

BEGIN

  OPEN lc_get_segment(p_application_id => ln_application_id,
                      p_flex_code      => p_flex_code,
                      p_flex_num       => p_flex_num,
                      p_segment_name   => p_segment_name1);
  FETCH lc_get_segment INTO lv_appl_col_name1;
  CLOSE lc_get_segment;

  IF p_segment_name2 IS NOT NULL
  THEN
    OPEN lc_get_segment(p_application_id => ln_application_id,
                        p_flex_code      => p_flex_code,
                        p_flex_num       => p_flex_num,
                        p_segment_name   => p_segment_name2);
    FETCH lc_get_segment INTO lv_appl_col_name2;
    CLOSE lc_get_segment;
  END IF;

  IF lv_appl_col_name1 IS NOT NULL
  THEN
    LOOP
      IF UPPER(lv_appl_col_name1) = ('SEGMENT'||ln_row_counter)
      THEN
        p_result := p_segment(ln_row_counter).value;
        EXIT;
      ELSE
        ln_row_counter := ln_row_counter + 1;
        IF ln_row_counter > 30
        THEN
          EXIT;
        END IF;
      END IF;
    END LOOP;
  ELSE
    p_result := NULL;
  END IF;

  IF lv_appl_col_name2 IS NOT NULL
  THEN
    --2424031 fix starts
    lv_seg_delimiter := FND_FLEX_APIS.gbl_get_segment_delimiter
      			(x_application_id => ln_application_id,
       			 x_id_flex_code   => p_flex_code,
       			 x_id_flex_num    => p_flex_num) ;
    p_result := p_result || lv_seg_delimiter ;
    --2424031 fix ends
    ln_row_counter := 1;
    LOOP
      IF UPPER(lv_appl_col_name2) = ('SEGMENT'||ln_row_counter)
      THEN
        p_result := p_result||p_segment(ln_row_counter).value;
        EXIT;
      ELSE
        ln_row_counter := ln_row_counter + 1;
        IF ln_row_counter > 30
        THEN
          EXIT;
        END IF;
      END IF;
    END LOOP;
  END IF;

EXCEPTION

  WHEN OTHERS
  THEN
      p_result := null;

      raise;

END get_segment_value;

FUNCTION get_currency_format(
           p_curcode        pay_element_types_f.input_currency_code%TYPE,
           p_effective_date DATE
         )
RETURN VARCHAR2
IS
  ln_dp      NUMBER(1);
  lv_fstring VARCHAR2(30);

  CURSOR currency_details IS
    SELECT cur.precision
    FROM  fnd_currencies_vl cur
    WHERE cur.currency_code = p_curcode
    AND   p_effective_date BETWEEN NVL(cur.start_date_active,p_effective_date)
                               AND NVL(cur.end_date_active,p_effective_date);

BEGIN

  OPEN currency_details;
  FETCH currency_details INTO ln_dp;
  CLOSE currency_details;
  lv_fstring:='FM9999999999999D';

  IF(ln_dp>0) THEN
    WHILE ln_dp > 0
    LOOP
      lv_fstring:=lv_fstring||'0';
      ln_dp:=ln_dp-1;
    END LOOP;
  ELSE
    lv_fstring:='FM99999999999999';
  END IF;

  RETURN lv_fstring;

END get_currency_format;


  /*
  ||===========================================================================
  || FUNCTION: get_contacts_type_list
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     For a given person and their contact, create and return a string of
  ||     their rlationship types.  Eg "Emergency, Brother"
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION get_contacts_type_list(
                     p_person_id      IN per_contact_relationships.person_id%TYPE
                    ,p_contact_id     IN per_contact_relationships.contact_person_id%TYPE
				    ,p_effective_date IN DATE DEFAULT TRUNC(SYSDATE))
RETURN VARCHAR2
IS

  -- Get rowset of contact relationships, often just one
  CURSOR lc_get_contact(pp_person_id IN  NUMBER, pp_contact_id IN  NUMBER, pp_effective_date IN DATE)
  IS
    select pcr.contact_type     Contact_Type,
           decode(pcr.contact_type,'EMRG','Y','N') Emergency_Contact,
           HR_GENERAL.DECODE_LOOKUP('CONTACT',pcr.contact_type) Full_Contact_Type
    from   per_contact_relationships pcr,
           per_all_people_f          per
    where  pcr.person_id         = pp_person_id
    and    pcr.contact_person_id = pp_contact_id
    and    pcr.contact_person_id = per.person_id
    and    pp_effective_date between
                decode(pcr.date_start,null,trunc(sysdate),trunc(pcr.date_start))
              and decode(pcr.date_end,null,trunc(sysdate),trunc(pcr.date_end))
    and    pp_effective_date between per.effective_start_date and per.effective_end_date
    order by Emergency_Contact desc;

  lv_delim   VARCHAR2(2)   DEFAULT ', ';
  lv_result  VARCHAR2(240) DEFAULT NULL;

BEGIN

  --If emergency type then this will appear first due to order by, then remaining appear in reverse alphabetical
  --Return coma delimited list
  FOR contact_rec IN lc_get_contact(pp_person_id => p_person_id, pp_contact_id => p_contact_id, pp_effective_date => p_effective_date)
  LOOP
    if lv_result is null then
      lv_result := contact_rec.Full_Contact_Type;
    else
      lv_result := lv_result||lv_delim||contact_rec.Full_Contact_Type;
    end if;
  END LOOP;
    RETURN lv_result;

END get_contacts_type_list;

  /*
  ||===========================================================================
  || FUNCTION: is_emergency_contact
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     For a given person, return whether a contact is an emergency contact.
  ||     Returns 2 for Primary Emergency, 1 for Emergency, else 0
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */

FUNCTION is_emergency_contact(
                     p_person_id      IN per_contact_relationships.person_id%TYPE
                    ,p_contact_id     IN per_contact_relationships.contact_person_id%TYPE
				    ,p_effective_date IN DATE DEFAULT TRUNC(SYSDATE))
RETURN NUMBER
IS

  lv_primary VARCHAR2(1) DEFAULT null;

BEGIN
    select pcr.primary_contact_flag into lv_primary
    from   per_contact_relationships pcr,
           per_all_people_f          per
    where  pcr.person_id         = p_person_id
    and    pcr.contact_person_id = p_contact_id
    and    pcr.contact_person_id = per.person_id
    and    p_effective_date between
                decode(pcr.date_start,null,trunc(sysdate),trunc(pcr.date_start))
              and decode(pcr.date_end,null,trunc(sysdate),trunc(pcr.date_end))
    and contact_type = 'EMRG'
    and rownum < 2;

  if lv_primary = 'Y' then
    RETURN 2;
  else RETURN 1;
  end if;
EXCEPTION
  when NO_DATA_FOUND then
    RETURN 0;
END is_emergency_contact;


-- bug fix 4059724 begins

PROCEDURE openTrngScoreCsr(
    p_cursor IN OUT NOCOPY cur_typ
   ,p_mode IN NUMBER
   ,p_person_id IN NUMBER
   ,p_event_id IN NUMBER) IS

query_str VARCHAR2(4000);
BEGIN
    if( p_mode = 0) then

 query_str :=  'Select db.score FROM ota_delegate_bookings db, ota_events evt '||
 ',ota_activity_versions av '||
 ',ota_booking_status_types bs , ota_booking_status_histories bsh '||
 'WHERE db.booking_status_type_id = bs.booking_status_type_id  '||
 'and db.delegate_person_id = :1  '||
 'AND db.booking_id = bsh.booking_id(+) '||
 'AND db.booking_status_type_id = bsh.booking_status_type_id (+) '||
 'AND db.event_id = evt.event_id  '||
 'AND evt.activity_version_id = av.activity_version_id (+) ' ;


    OPEN p_cursor FOR query_str USING p_person_id ;


ELSE
 query_str :=  'select opr.score  from ota_performances opr , ota_offerings ofr '||
 ', ota_learning_objects olo , ota_events evt '||
'where ofr.learning_object_id = olo.learning_object_id(+) '||
'and olo.learning_object_id = opr.learning_object_id(+) '||
'and opr.user_id(+) = :1 '||
'and evt.event_id = :2 '||
'and ofr.OFFERING_ID = evt.parent_offering_id '||
'and evt.parent_offering_id is not null ';


OPEN p_cursor FOR query_str USING p_person_id , p_event_id ;

end if ;
end  openTrngScoreCsr ;



FUNCTION getTrngScore(p_person_id IN NUMBER, p_event_id IN NUMBER) RETURN NUMBER
IS
 l_cnt NUMBER:=0;
 l_cursor cur_typ;
BEGIN

    openTrngScoreCsr(
        l_cursor
       ,0
       ,p_person_id
       ,p_event_id);

    FETCH l_cursor INTO l_cnt;

     CLOSE l_cursor;
     if (l_cnt is not null) then
        RETURN l_cnt;


    else
        openTrngScoreCsr(
        l_cursor
       ,1
       ,p_person_id
       ,p_event_id);
          FETCH l_cursor INTO l_cnt;
           CLOSE l_cursor;

          if (l_cnt = -1000)then
            return null;

          else
            return l_cnt;

          end if;
    end if ;

    Exception When Others then
       CLOSE l_cursor;
       return null;
  END getTrngScore;

-- bug fix 4059724 end
-- Bug 4513393 Begins
Function getTrngEndDate (p_person_id IN NUMBER, p_event_id IN NUMBER) RETURN DATE
IS
l_cursor cur_typ;
cur_str VARCHAR2(4000);
EndDate DATE;
BEGIN
cur_str := 'Select opf.completed_date EndDate '||
 'From OTA_EVENTS oev, OTA_OFFERINGS ofr, OTA_PERFORMANCES opf, ota_category_usages ocu '||
'Where oev.parent_offering_id = ofr.offering_id '||
               'And ofr.learning_object_id = opf.learning_object_id(+) '||
               'And ocu.Category_Usage_Id = ofr.Delivery_Mode_Id '||
               'and ocu.Online_Flag = ''Y'' '||
               'And opf.User_id(+) = :1 '||
               'And oev.event_id = :2 ';
open l_cursor for cur_str USING p_person_id , p_event_id  ;
   fetch l_cursor into EndDate;
   close l_cursor;
   return EndDate;


Exception When Others then
       CLOSE l_cursor;
       return null;
END getTrngEndDate;
-- Bug 4513393 Ends
END hr_mee_views_gen ;

/
