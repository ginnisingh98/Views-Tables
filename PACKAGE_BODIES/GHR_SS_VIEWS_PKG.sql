--------------------------------------------------------
--  DDL for Package Body GHR_SS_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SS_VIEWS_PKG" AS
/* $Header: ghssview.pkb 120.4.12010000.6 2009/10/29 09:12:56 managarw ship $ */
--
-- This is global variable to store flex number for performance SIT .
-- This variable is used as cache.
g_perf_flex_num fnd_id_flex_structures_tl.id_flex_num%type;

--
-- This function returns best fit history id for person Extra Info type record on a given a day.

function get_people_ei_id_ason_date(
                p_person_id in number,
                p_information_type in varchar2,
		p_effective_date	 in	date
               ) return number is
   l_proc                     varchar2(72) ;
   l_history_id  ghr_pa_history.pa_history_id%type;


-- This cursor gets the latest date on which the given Extra information Type record
-- is inserted or updated on or before the given date
-- and then gets the the record with highest history id on that date.

-- In c_history_id join on PER_PEOPLE_EXTRA_INFO is required to skip the history records
-- on the extra information records that are deleted.
   cursor c_history_id is
               select max(gph1.pa_history_id) pa_history_id
               from   ghr_pa_history  gph1,
	              PER_PEOPLE_EXTRA_INFO pei1
               where  gph1.table_name         = 'PER_PEOPLE_EXTRA_INFO'
	       and    pei1.person_id          = p_person_id
               and    pei1.information_type   = p_information_type
	       and    gph1.information1       = to_char(pei1.person_extra_info_id)
               and    gph1.effective_date     = ( select max(gph2.effective_date)maxdate
                                                  from   ghr_pa_history gph2
                                                  where  gph2.table_name =  'PER_PEOPLE_EXTRA_INFO'
				                  and    gph2.effective_date <= p_effective_date
				                  and    gph2.information1 = to_char(pei1.person_extra_info_id)) ;



begin

l_proc :=  g_package||'.get_people_ei_id_ason_date';

if ( hr_utility.debug_enabled()) then
      hr_utility.set_location('Entering... ' ||l_proc,1000);
      hr_utility.set_location('Person_id : ' || p_person_id, 1000);
      hr_utility.set_location('Information_type : ' || p_information_type, 1000);
      hr_utility.set_location('Effective_date : ' || p_effective_date, 1000);
End if;

                for history_id_rec in c_history_id
                  loop
                     l_history_id := history_id_rec.pa_history_id;
		     exit;
                  end loop;

      hr_utility.set_location('history_id : ' || l_history_id, 1000);

      return (l_history_id);

end get_people_ei_id_ason_date;


-- This function is a wrapper functions which returns the input value of an element on the given date.
-- This function calls ghr_per_sum.get_element_details procedure.

function get_ele_value_ason_date (p_ele_name    in varchar2
			   ,p_input_name  in varchar2
			   ,p_asg_id      in number
			   ,p_eff_date    in date,
			   P_BUSINESS_GROUP_ID in Number
			  ) return varchar2 is

    l_screen_entry_value varchar2 (150);
    l_effective_start_date date;
    l_proc               varchar2(50);
Begin
    l_proc  := g_package||'.get_ele_value_ason_date';
    hr_utility.set_location('Entering... ' ||l_proc,1000);

    ghr_per_sum.get_element_details(p_ele_name,
                                         p_input_name,
                                         p_asg_id,
                                         p_eff_date,
                                         l_screen_entry_value,
                                         l_effective_start_date,
					 P_BUSINESS_GROUP_ID
					 );

    hr_utility.set_location('Element input value : ' || l_screen_entry_value, 1000);
    return (l_screen_entry_value);

End get_ele_value_ason_date;

-- This function is a wrapper functions which returns the input value of an element on the given date.
-- This function calls ghr_per_sum.get_element_entry_values procedure.


function get_ele_entry_value_ason_date (p_element_entry_id     IN     NUMBER
                                           ,p_input_value_name     IN     VARCHAR2
                                           ,p_effective_date       IN     DATE
			                    ) return varchar2 is

    l_value varchar2 (150);
    l_effective_start_date date;
    l_proc               varchar2(100);
Begin

    l_proc  := g_package||'.get_ele_entry_value_ason_date';
    hr_utility.set_location('Entering... ' ||l_proc,1000);
    ghr_per_sum.get_element_entry_values (p_element_entry_id
                                         ,p_input_value_name
                                         ,p_effective_date
				         ,l_value
                                         ,l_effective_start_date );

    hr_utility.set_location('Element input value : ' || l_value, 1000);
    return (l_value);

End get_ele_entry_value_ason_date;

-- This function returns the latest pa request id on or before a given date.
-- Latest Personnel Action is Latest Effective Date, if multiple on same Effective Date,
-- use greatest NPA ID; display the Second NOAC if available, otherwise First NOAC;
-- if First NOAC is either 001 or 002, then go with next Personnel Action

function get_latest_pa_req_id (
                           p_person_id in number,
        		   p_effective_date in date
			  ) return number  is


    cursor c_notification_id  is
            select max(par1.pa_notification_id) notification_id
            from ghr_pa_requests par1
            where par1.person_id =  p_person_id
              and par1.pa_notification_id is NOT Null
	      and par1.noa_family_code NOT in ('CORRECT', 'CANCEL')
              and nvl(par1.first_noa_cancel_or_correct, 'normal') <> 'CANCEL'
              and par1.effective_date = ( select max(par2.effective_date) maxdate
				       from ghr_pa_requests par2
				       where par2.person_id =  p_person_id
			                 and par2.pa_notification_id is NOT Null
			                 and par2.effective_date <= p_effective_date
				         and par2.noa_family_code NOT in ('CORRECT', 'CANCEL')
				         and nvl(par2.first_noa_cancel_or_correct, 'normal') <> 'CANCEL' ) ;


    cursor c_request_id (c_notification_id number) is
             select pa_request_id
	     from ghr_pa_requests g
	     where g.pa_notification_id = c_notification_id ;

    l_notification_id  ghr_pa_requests.pa_notification_id%type;
    l_pa_request_id ghr_pa_requests.pa_request_id%type;
    l_proc           varchar2(72);


BEGIN

l_proc  := g_package||'.get_latest_pa_req_id';

if ( hr_utility.debug_enabled()) then
      hr_utility.set_location('Entering... ' ||l_proc,1000);
      hr_utility.set_location('Person_id : ' || p_person_id, 1000);
      hr_utility.set_location('Effective_date : ' || p_effective_date, 1000);
end if;

      for notification_id_rec in c_notification_id
      loop
           l_notification_id := notification_id_rec.notification_id;
	   exit;
      end loop;

      hr_utility.set_location('notification_id : ' || l_notification_id, 1000);

      for pa_request_id_rec in c_request_id (l_notification_id)
      loop
	      l_pa_request_id := pa_request_id_rec.pa_request_id;
	      exit;
      end loop;

      hr_utility.set_location('pa_request_id : ' || l_pa_request_id, 1000);

      return (l_pa_request_id);

     END get_latest_pa_req_id;

-- This function returns the latest performance rating for the person on or before a given date.

Function get_latest_perf_rating(p_person_id in number,
                                p_effective_date in Date) return varchar2 is

-- cursor get_flex_num gives the flex number id for performance appraisal SIT.
-- This cursor will be used only for the first time this function is called in a session.
-- From the second time it uses the flex number stored in cache.

cursor get_flex_num is
   select    flx.id_flex_num id_flex_num
   from      fnd_id_flex_structures_tl flx
   where     flx.id_flex_code           = 'PEA'  and
             flx.application_id         =  800   and
             flx.id_flex_structure_name =  'US Fed Perf Appraisal' and
             flx.language	        =  'US'  ;

-- cursor get_latest_perf_rating gets the latest performance rating.
-- Latest Performance Rating:  use Appraisal Start Date and Rating of Record;
-- if duplicate Start Dates, go with the greatest ID

 cursor get_latest_perf_rating  is
   select pan.person_analysis_id, pea.segment2 rating_of_record
   from per_analysis_criteria pea,
        per_person_analyses pan
   where pan.person_id              = p_person_id and
         pan.id_flex_num            = g_perf_flex_num  and
	  pea.id_flex_num            = pan.id_flex_num   and
         nvl(pan.date_from,sysdate)  between nvl(pea.start_date_active,nvl(pan.date_from,sysdate) )
                                      and   nvl(pea.end_date_active,nvl(pan.date_from,sysdate) )  and
         pan.analysis_criteria_id     =  pea.analysis_criteria_id  and
         trunc(nvl(pan.date_from,sysdate)) = (select max(trunc(nvl(pan.date_from,sysdate))) max_date_from
					      from per_person_analyses pan
				    	      where pan.person_id      = p_person_id and
					      pan.id_flex_num          = g_perf_flex_num and
					      trunc(nvl(pan.date_from,sysdate)) <= p_effective_date )

    order by person_analysis_id  desc    ;

  l_max_date_from date;
  l_perf_rating varchar2(10);
  l_proc     varchar2(72);
Begin

l_proc  := g_package||'.get_latest_perf_rating';

if ( hr_utility.debug_enabled()) then
	hr_utility.set_location('Entering... ' ||l_proc,1000);
	hr_utility.set_location('Person_id : ' || p_person_id, 1000);
	hr_utility.set_location('Effective_date : ' || p_effective_date, 1000);
	hr_utility.set_location('perf Flex Num : ' || g_perf_flex_num, 1000);
end if;

If g_perf_flex_num is null THEN
   for get_flex_num_rec in get_flex_num
   loop
       g_perf_flex_num := get_flex_num_rec.id_flex_num;
       exit;
   End loop;
END IF;

hr_utility.set_location('perf Flex Num : ' || g_perf_flex_num, 10);

   for get_latest_perf_rating_rec in get_latest_perf_rating
   loop
       l_perf_rating  := get_latest_perf_rating_rec.rating_of_record;
       exit;
    End loop;

hr_utility.set_location('Performance rating : ' || l_perf_rating, 1000);

return( l_perf_rating);

End get_latest_perf_rating;
--
-- This function returns the currency code of an element on an effective date.

Function retrieve_element_curr_code (p_element_name      in     pay_element_types_f.element_name%type,
                                     p_assignment_id     in     pay_element_entries_f.assignment_id%type,
				     p_business_group_id in     per_all_assignments_f.business_group_id%type,
                                     p_effective_date    in     date ) return varchar2 is

--
l_proc                     varchar2(72);
l_new_element_name         VARCHAR2(80);
l_input_curr_code          varchar2(10);

--

Cursor c_ele_input_curr_code is

       select elt.input_currency_code input_curr_code
       from pay_element_types_f elt,
            pay_element_entries_f ele
       where
            trunc(p_effective_date) between elt.effective_start_date
			            	   and elt.effective_end_date
         and trunc(p_effective_date) between ele.effective_start_date
			            	   and ele.effective_end_date
         and ele.assignment_id = p_assignment_id
         and elt.element_type_id = ele.element_type_id
	 and upper(elt.element_name) = upper(l_new_element_name)
         and (elt.business_group_id is null or elt.business_group_id = p_business_group_id) ;



Begin

-- Initialization
l_proc := g_package||'retrieve_element_curr_code';

---- pqp_fedhr_uspay_int_utils.return_new_element_name is called to get the new element name

---- For all elements in HR User old function will fetch the same name.
----     because of is_script will be FALSE
----
---- For all elements (except BSR) in Payroll user old function.
----     for BSR a new function which will fetch from assignmnet id.
----
l_new_element_name  := p_element_name;

IF (p_element_name = 'Basic Salary Rate'
    and (fnd_profile.value('HR_USER_TYPE') = 'INT')) THEN
  hr_utility.set_location('PAYROLL User -- BSR -- from asgid-- '||l_proc, 1);
           l_new_element_name :=
                   pqp_fedhr_uspay_int_utils.return_new_element_name(
                                           p_assignment_id      => p_assignment_id,
                                           p_business_group_id  => p_business_group_id,
                                           p_effective_date     => p_effective_date);

ELSE
  hr_utility.set_location('HR USER or PAYROLL User without BSR element -- from elt name -- '||l_proc, 1);
           l_new_element_name :=
                            pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => p_business_group_id,
                                           p_effective_date     => p_effective_date,
                                           p_pay_basis          => NULL);

END IF;

if ( hr_utility.debug_enabled()) then
	hr_utility.set_location('Element Name ' ||p_element_name,1000);
	hr_utility.set_location('BG ID '|| p_business_group_id,2000);
	hr_utility.set_location('Eff date'|| p_effective_date ,3000);
	hr_utility.set_location('New element Name ' ||l_new_element_name,100000);
end if;

for c_ele_input_curr_code_rec in c_ele_input_curr_code
Loop
   l_input_curr_code := c_ele_input_curr_code_rec.input_curr_code;
   exit;
End Loop;

hr_utility.set_location('Input currency code ' ||l_input_curr_code,100000);

return (l_input_curr_code);

End retrieve_element_curr_code;

-- This is a wrapper function to get the locality pay area percentage.
-- This function calls ghr_per_sum.get_duty_station_details procedure.

function get_loc_pay_area_percentage (p_location_id  in number,
                                      p_effective_date    in     date )  return varchar2 is
--

l_locality_pay_area_percentage    number;
l_locality_pay_area  varchar2(80);
l_duty_station_desc  varchar2(80);
l_duty_sation_code   varchar2(80);
l_proc               varchar2(72);

Begin

l_proc  := g_package||'.get_loc_pay_area_percentage';

if ( hr_utility.debug_enabled()) then
	hr_utility.set_location('Entering... ' ||l_proc,1000);
	hr_utility.set_location('Location id : ' || p_location_id, 1000);
	hr_utility.set_location('Effective_date : ' || p_effective_date, 1000);
end if;

ghr_per_sum.get_duty_station_details (p_location_id
                         ,p_effective_date
                         ,l_duty_sation_code
                         ,l_duty_station_desc
                         ,l_locality_pay_area
                         ,l_locality_pay_area_percentage  ) ;

hr_utility.set_location('locality pay area percentage : ' || l_locality_pay_area_percentage, 1000);
return (l_locality_pay_area_percentage);

End get_loc_pay_area_percentage;


--This function checks out whether a person has got an Award
--for a given assignment

function check_if_awards_exists ( p_assignment_id  in number,
                                 p_effective_date    in     date )  return varchar2 is
--

l_award_bonus        VARCHAR2(5);
l_proc               VARCHAR2(100);


 CURSOR award_check (l_assignment_id NUMBER,
                     l_effective_date DATE ) IS
    SELECT eef.element_entry_id
    FROM pay_element_entries_f eef,
   	 pay_element_types_f elt
    WHERE eef.assignment_id = l_assignment_id
    AND  eef.effective_start_date <= l_effective_date
    AND  elt.element_type_id = eef.element_type_id
    AND  eef.effective_start_date BETWEEN elt.effective_start_date
 				    AND elt.effective_end_date
    AND  UPPER(pqp_fedhr_uspay_int_utils.return_old_element_name
                   (elt.element_name,
		    elt.business_group_id,
		    eef.effective_start_date)) =  'FEDERAL AWARDS' ;



BEGIN

l_proc  := g_package||'.check_if_awards_exists';
l_award_bonus  := 'No'  ;

if ( hr_utility.debug_enabled()) then
	 hr_utility.set_location('Entering... ' ||l_proc,1000);
	 hr_utility.set_location('assignement_id : ' || p_assignment_id, 1001);
	 hr_utility.set_location('Effective_date : ' || p_effective_date, 1002);
end if;

    FOR award_check_rec IN award_check (p_assignment_id , p_effective_date)LOOP
         l_award_bonus := 'Yes';
     EXIT;
    END LOOP;

 hr_utility.set_location('Check for Award : ' || l_award_bonus, 1004);

 RETURN(l_award_bonus);

END check_if_awards_exists;

--This function checks out whether a person has got an Award
--for a given assignment

FUNCTION check_if_bonus_exists  (p_assignment_id  IN NUMBER,
                                 p_effective_date    IN   DATE )  RETURN VARCHAR2 IS
--

l_award_bonus        VARCHAR2(5);
l_proc               VARCHAR2(100);



  CURSOR bonus_check (l_assignment_id NUMBER,
                      l_effective_date DATE ) IS
    SELECT eef.element_entry_id
    FROM pay_element_entries_f eef,
         pay_element_types_f elt
    WHERE eef.assignment_id = l_assignment_id
    AND  eef.effective_start_date <= l_effective_date
    AND  elt.element_type_id = eef.element_type_id
    AND eef.effective_start_date BETWEEN elt.effective_start_date
 				    AND elt.effective_end_date
    AND  UPPER(pqp_fedhr_uspay_int_utils.return_old_element_name
                   (elt.element_name,
		    elt.business_group_id,
		    eef.effective_start_date)) IN ('RELOCATION BONUS',
                                                  'RECRUITMENT BONUS' );

BEGIN

l_proc  := g_package||'.check_if_bonus_exists';
l_award_bonus  := 'No'  ;
if ( hr_utility.debug_enabled()) then
	 hr_utility.set_location('Entering... ' ||l_proc,1000);
	 hr_utility.set_location('assignement_id : ' || p_assignment_id, 1001);
	 hr_utility.set_location('Effective_date : ' || p_effective_date, 1002);
end if;

   FOR bonus_check_rec IN bonus_check (p_assignment_id , p_effective_date)LOOP
         l_award_bonus := 'Yes';
      EXIT;
   END LOOP;


 hr_utility.set_location('Check for Bonus : ' || l_award_bonus, 1004);

 RETURN(l_award_bonus);

END check_if_bonus_exists;

-- This function returns the history id for a particular information type of a person
-- depending on the effective date and the person type.

function get_history_id(p_assignment_type      in varchar2,
                        p_person_id        in number,
                        p_information_type in varchar2,
                        p_effective_date   in date
                       ) return number is
   l_proc        varchar2(72) ;
   l_history_id  ghr_pa_history.pa_history_id%type;

begin
  l_proc := g_package||'get_history_id';
  if (p_assignment_type = 'E' or p_assignment_type = 'C') then
    select nvl(substr((select ghr_ss_views_pkg.get_people_ei_id_ason_date(p_person_id,p_information_type,p_effective_date) from dual), 0, 10),-1)
    into l_history_id
    from dual;
  end if;
  return (l_history_id);
end get_history_id;

     Function get_assignment_ei_id_ason_date( p_asg_id in number,
                                              p_information_type in varchar2,
                                              p_effective_date in date) return number is

     l_proc        varchar2(72) ;
     l_history_id  ghr_pa_history.pa_history_id%type;


      -- This cursor gets the latest date on which the given Extra information Type record
      -- is inserted or updated on or before the given date
      -- and then gets the the record with highest history id on that date.

      -- In c_history_id join on PER_ASSIGNMENT_EXTRA_INFO is required to skip the history records
      -- on the extra information records that are deleted.
       cursor c_history_id is
          select nvl(max(gph1.pa_history_id),hr_api.g_number) pa_history_id
          from   ghr_pa_history  gph1,
	         PER_ASSIGNMENT_EXTRA_INFO pei1
          where  gph1.table_name         = 'PER_ASSIGNMENT_EXTRA_INFO'
	  and    pei1.assignment_id      = p_asg_id
          and    pei1.information_type   = p_information_type
	  and    gph1.information1       = to_char(pei1.assignment_extra_info_id)
          and    gph1.effective_date     = ( select max(gph2.effective_date)maxdate
                                             from   ghr_pa_history gph2
                                             where  gph2.table_name =  'PER_ASSIGNMENT_EXTRA_INFO'
				             and    gph2.effective_date <= p_effective_date
				             and    gph2.information1 = to_char(pei1.assignment_extra_info_id)) ;



   Begin

        l_proc :=  g_package||'.get_asg_ei_id_ason_date';

        if ( hr_utility.debug_enabled()) then
              hr_utility.set_location('Entering... ' ||l_proc,1000);
              hr_utility.set_location('Assignment_id : ' || p_asg_id, 1000);
              hr_utility.set_location('Information_type : ' || p_information_type, 1000);
              hr_utility.set_location('Effective_date : ' || p_effective_date, 1000);
        End if;

        for history_id_rec in c_history_id loop
            l_history_id := history_id_rec.pa_history_id;
	    exit;
        end loop;

        hr_utility.set_location('history_id : ' || l_history_id, 1000);
        return (l_history_id);

    End get_assignment_ei_id_ason_date;

--

    Function get_position_ei_id_ason_date( p_position_id in number,
                                           p_information_type in varchar2,
                                           p_effective_date in date
                                          ) return number is

   l_proc        varchar2(72) ;
   l_history_id  ghr_pa_history.pa_history_id%type;


   -- This cursor gets the latest date on which the given Extra information Type record
   -- is inserted or updated on or before the given date
   -- and then gets the the record with highest history id on that date.

   -- In c_history_id join on PER_POSITION_EXTRA_INFO is required to skip the history records
   -- on the extra information records that are deleted.
   cursor c_history_id is
      select nvl(max(gph1.pa_history_id),hr_api.g_number) pa_history_id
      from   ghr_pa_history  gph1,
	              PER_POSITION_EXTRA_INFO pei1
      where  gph1.table_name         = 'PER_POSITION_EXTRA_INFO'
      and    pei1.position_id          = p_position_id
      and    pei1.information_type   = p_information_type
      and    gph1.information1       = to_char(pei1.position_extra_info_id)
      and    gph1.effective_date     = ( select max(gph2.effective_date)maxdate
                                         from   ghr_pa_history gph2
                                         where  gph2.table_name =  'PER_POSITION_EXTRA_INFO'
                                         and    gph2.effective_date <= p_effective_date
		                         and    gph2.information1 = to_char(pei1.position_extra_info_id)) ;

    Begin

       l_proc :=  g_package||'.get_position_ei_id_ason_date';

       if ( hr_utility.debug_enabled()) then
             hr_utility.set_location('Entering... ' ||l_proc,1000);
             hr_utility.set_location('position_id : ' || p_position_id, 1000);
             hr_utility.set_location('Information_type : ' || p_information_type, 1000);
             hr_utility.set_location('Effective_date : ' || p_effective_date, 1000);
       End if;

       for history_id_rec in c_history_id loop
           l_history_id := history_id_rec.pa_history_id;
	   exit;
       end loop;

      hr_utility.set_location('history_id : ' || l_history_id, 1000);

      return (l_history_id);

end get_position_ei_id_ason_date;

--Start of fix for Bug#6085591
  -- This function returns the Rating of Record for the person .

  Function get_rating_of_record(p_person_id      in number) return varchar2 is

    -- cursor get_flex_num gives the flex number id for performance appraisal SIT.
    -- This cursor will be used only for the first time this function is called in a session.
    -- From the second time it uses the flex number stored in cache.

    cursor get_flex_num is
      select flx.id_flex_num id_flex_num
        from fnd_id_flex_structures_tl flx
       where flx.id_flex_code = 'PEA' and flx.application_id = 800 and
             flx.id_flex_structure_name = 'US Fed Perf Appraisal' and
             flx.language = 'US';

    -- cursor get_rating_of_record gets the rating of record.

    CURSOR get_rating_of_record IS
      SELECT pan.person_analysis_id, pea.segment5 rating_of_record
        FROM per_analysis_criteria pea, per_person_analyses pan
       WHERE pan.person_id = p_person_id and
             pan.id_flex_num = g_perf_flex_num AND
             pea.id_flex_num = pan.id_flex_num AND
             nvl(pan.date_from, sysdate) BETWEEN
             nvl(pea.start_date_active, nvl(pan.date_from, sysdate)) AND
             nvl(pea.end_date_active, nvl(pan.date_from, sysdate)) AND
             pan.analysis_criteria_id = pea.analysis_criteria_id AND
             trunc(nvl(to_date(pea.segment3,'yyyy/mm/dd hh24:mi:ss'),sysdate))
		=  (SELECT max(trunc(nvl( to_date(pea.segment3,'yyyy/mm/dd hh24:mi:ss'),sysdate))) max_eff_date
				FROM per_analysis_criteria pea,
					 per_person_analyses pan
				WHERE pan.person_id   = p_person_id AND
				      pan.id_flex_num = g_perf_flex_num AND
					pea.id_flex_num = pan.id_flex_num AND
					pan.analysis_criteria_id = pea.analysis_criteria_id AND
					trunc(nvl(to_date(pea.segment3,'yyyy/mm/dd hh24:mi:ss'),sysdate)) <= sysdate)

       ORDER BY person_analysis_id DESC;

    l_max_date_from date;
    l_perf_rating   varchar2(10);
    l_proc          varchar2(72);
  Begin

    l_proc := g_package || '.get_rating_of_record';

    if (hr_utility.debug_enabled()) then
      hr_utility.set_location('Entering... ' || l_proc, 1001);
      hr_utility.set_location('Person_id : ' || p_person_id, 1001);
      hr_utility.set_location('perf Flex Num : ' || g_perf_flex_num, 1001);
    end if;

    If g_perf_flex_num is null THEN
      for get_flex_num_rec in get_flex_num loop
        g_perf_flex_num := get_flex_num_rec.id_flex_num;
        exit;
      End loop;
    END IF;

    hr_utility.set_location('perf Flex Num : ' || g_perf_flex_num, 101);

    for get_rating_of_record_rec in get_rating_of_record loop
      l_perf_rating := get_rating_of_record_rec.rating_of_record;
      exit;
    End loop;

    hr_utility.set_location('Performance rating : ' || l_perf_rating, 1001);

    return(l_perf_rating);

  End get_rating_of_record;

--End of fix for Bug#6085591

--Beginning of bug fix 6781928
FUNCTION get_assignment_start_date(p_person_id IN NUMBER) RETURN DATE IS

  CURSOR assignement_start_date(p_person_id NUMBER) IS
    SELECT MIN(effective_start_date) effective_start_date
      FROM per_all_assignments_f
     WHERE person_id = p_person_id AND
           assignment_id =
           (SELECT MAX(assignment_id)
              FROM per_all_assignments_f
             WHERE person_id = p_person_id AND assignment_type in ('E','C')) AND
           assignment_type in ('E','C');
  l_ass_st_date DATE;
BEGIN

  FOR l_assignement_start_date IN assignement_start_date(p_person_id) LOOP
    l_ass_st_date := l_assignement_start_date.effective_start_date;
    exit;
  END LOOP;

  RETURN l_ass_st_date;

END get_assignment_start_date;

Function get_assignment_end_date(p_person_id in number) return date is

	cursor assignement_end_date (p_person_id number) is
		select max(effective_end_date) effective_end_date
			from per_all_assignments_f
			where person_id = p_person_id and
			      assignment_type in ('E','C')  ;
l_ass_end_date date;
Begin

	for l_assignement_end_date in assignement_end_date(p_person_id) loop
		l_ass_end_date := l_assignement_end_date.effective_end_date;
		exit;
	end loop;

return l_ass_end_date ;

End 	get_assignment_end_date;
--End of bug fix 6781928

END ghr_ss_views_pkg;

/
