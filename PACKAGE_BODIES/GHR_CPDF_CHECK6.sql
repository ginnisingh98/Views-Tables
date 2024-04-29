--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK6" as
/* $Header: ghcpdf06.pkb 120.12.12010000.9 2009/07/30 12:15:46 vmididho ship $ */

/* Name:
-- Prior Work Schedule
*/

procedure chk_prior_work_schedule
  (p_prior_work_schedule      in varchar2   --non SF52
  ,p_work_schedule_code       in varchar2
  ,p_first_noac_lookup_code   in varchar2
  ) is

   l_prior_work_schedule ghr_pa_requests.work_schedule%type;
begin
-- 8267598 added code for global variable comparison for dual actions.
l_prior_work_schedule  := p_prior_work_schedule;
if ghr_process_sf52.g_dual_prior_ws is not null then
   l_prior_work_schedule := ghr_process_sf52.g_dual_prior_ws;
end if;

-- 590.02.2
   if p_first_noac_lookup_code = '781' and
	l_prior_work_schedule is not null and
	p_work_schedule_code  is not null and
      l_prior_work_schedule = p_work_schedule_code then
      hr_utility.set_message(8301, 'GHR_37601_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 590.04.2
   if p_first_noac_lookup_code = '430' and
	p_prior_work_schedule not in ('G','J','Q','T') and
	p_prior_work_schedule is not null then
      hr_utility.set_message(8301, 'GHR_37602_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

end chk_prior_work_schedule;


/* Name:
-- Race or National Origin
*/


procedure chk_race_or_natnl_origin
  (p_race_or_natnl_origin       in varchar2   --non SF52
  ,p_duty_station_lookup_code   in varchar2
  ,p_ethnic_race_info           in varchar2
  ,p_first_action_noa_la_code1  in varchar2
  ,p_first_action_noa_la_code2  in varchar2
  ,p_effective_date             in date
  ) is
begin

-- Begin Bug# 4567571
-- 165.00.3
-- 17-Nov-2005   Raju   Bug# 4567571	Added this Edit for UPD44.

IF p_effective_date >= to_date('01/01/2006','MM/DD/RRRR') THEN
--IF p_effective_date >= to_date('10/01/2005','MM/DD/RRRR') THEN
	IF p_ethnic_race_info is not null THEN
	   IF INSTR(p_ethnic_race_info,'1')<1 THEN
		   hr_utility.set_message(8301, 'GHR_38988_ALL_PROCEDURE_FAIL');
  		   hr_utility.raise_error;
		END IF;

		IF INSTR(p_ethnic_race_info,' ')> 0 THEN
		   hr_utility.set_message(8301, 'GHR_38988_ALL_PROCEDURE_FAIL');
  		   hr_utility.raise_error;
		END IF;
   END IF;
END IF;



-- 165.09.2
-- 17-Nov-2005   Raju   Bug# 4567571	Added this Edit for UPD44.

IF p_effective_date >= to_date('07/01/2006','MM/DD/RRRR') THEN
--IF p_effective_date >= to_date('11/01/2005','MM/DD/RRRR') THEN
	hr_utility.set_location('p_first_action_noa_la_code1 ' || p_first_action_noa_la_code1,111);
	hr_utility.set_location('p_ethnic_race_info ' || p_ethnic_race_info,111);

	IF (substr(p_first_action_noa_la_code1, 1, 1) = '1' or substr(p_first_action_noa_la_code2, 1, 1) = '1') and
	   p_ethnic_race_info is null THEN
	   hr_utility.set_message(8301, 'GHR_38991_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
END IF;

-- 165.11.2
-- 17-Nov-2005   Raju   Bug# 4567571	Added this Edit for UPD44.

IF p_effective_date >= to_date('07/01/2006','MM/DD/RRRR') THEN
--IF p_effective_date >= to_date('11/01/2005','MM/DD/RRRR') THEN
	hr_utility.set_location('p_first_action_noa_la_code1 ' || p_first_action_noa_la_code1,111);
	hr_utility.set_location('p_race_or_natnl_origin ' || p_race_or_natnl_origin,111);

	IF (substr(p_first_action_noa_la_code1, 1, 1) = '1' or substr(p_first_action_noa_la_code2, 1, 1) = '1') and
	   p_race_or_natnl_origin is not null THEN
	   hr_utility.set_message(8301, 'GHR_38992_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
END IF;
-- End Bug# 4567571

-- 165.05.3, 165.05.1
-- 17-Nov-2005   Raju   Bug# 4567571	Added this Edit for UPD44.
-- This code handles Edit 165.07.3 also
--  UPD 50(Bug 5745356) Raju		from 01-Oct-2006	  Rename 165.05.3 to 165.05.1
IF p_effective_date >= to_date('01/01/2006','MM/DD/RRRR') THEN
--IF p_effective_date >= to_date('10/01/2005','MM/DD/RRRR') THEN
	IF p_effective_date >= to_date('10/01/2006','MM/DD/RRRR') THEN
        IF  (p_first_action_noa_la_code1 <> '817' or p_first_action_noa_la_code2 <> '817') and
            p_ethnic_race_info is null and
            p_race_or_natnl_origin IS NULL THEN
            --Bug# 6959477 message number 38822 is duplicated, so created new message with #38160
            hr_utility.set_message(8301, 'GHR_38160_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    ELSE
         IF p_ethnic_race_info is null and
            p_race_or_natnl_origin IS NULL THEN
            hr_utility.set_message(8301, 'GHR_38989_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    END IF;
END IF;

-- Uncommented this procedure on 7/13/98 by skutteti
-- 600.02.3
   if p_race_or_natnl_origin = 'Y'
	and
      substr(p_duty_station_lookup_code, 1, 2) <> 'RQ'
	and
      p_duty_station_lookup_code is not null
	then
      hr_utility.set_message(8301, 'GHR_37603_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 600.04.3
   if p_race_or_natnl_origin in ('F','G','H','J','K','L','M','N','P','Q') and
         substr(p_duty_station_lookup_code, 1, 2) <> '15'
	and
      p_duty_station_lookup_code is not null
	then
      hr_utility.set_message(8301, 'GHR_37604_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 600.07.3
   if substr(p_duty_station_lookup_code, 1, 2) = 'RQ' and
        (p_race_or_natnl_origin <> 'D'
	   and
	   p_race_or_natnl_origin <>	'Y')
	and
      p_race_or_natnl_origin is not null
	 then
      hr_utility.set_message(8301, 'GHR_37605_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 600.10.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 24-Oct-2007
if p_effective_date < fnd_date.canonical_to_date('2007/10/25') then
   if substr(p_duty_station_lookup_code, 1, 2) = '15' and
         p_race_or_natnl_origin not in ('A','C','D','E','F','G','H','I','J',
                                        'K','L','M','N','O','P','Q')
	and
      p_race_or_natnl_origin is not null
	then
      hr_utility.set_message(8301, 'GHR_37606_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

end chk_race_or_natnl_origin;


/* Name:
Prior Duty Station
*/
procedure chk_prior_duty_station
  (p_prior_duty_station    	in varchar2
  ,p_agency_subelement 		in varchar2
  ) is
begin

-- 654.03.2
   null;
   /* This is not required according to the update6 summary of the edit manual.
   if substr(p_prior_duty_station, 1, 2) = 'US' and
      p_agency_subelement <> 'DJ02' then
      hr_utility.set_message(8301, 'GHR_37607_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
   */

end chk_prior_duty_station;

/* Name:
-- Retention Allowance
*/


 procedure chk_retention_allowance
  (p_retention_allowance             in varchar2   --non SF52
  ,p_to_pay_plan                     in varchar2
  ,p_to_basic_pay                    in varchar2
  ,p_first_noac_lookup_code          in varchar2
  ,p_first_action_noa_la_code1       in varchar2
  ,p_first_action_noa_la_code2       in varchar2
  ,p_effective_date                  in date --Bug# 8309414
  ) is
begin

/* Commented -- August 2001 10.7 Patch
-- 655.02.1
   if p_retention_allowance is not null and
      to_number(p_retention_allowance) <= 0 then
      hr_utility.set_message(8301, 'GHR_37666_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
*/

-- 655.10.3
-- 18/2  16-Oct-2002  vnarasim  From the begining  Added Pay plans SK,SO
-- UPDATE        UPDATE DATE    UPDATED BY   COMMENTS
-------------------------------------------------------------------------------
-- Update 37     09-NOV-2004     MADHURI     Delete pay plans AA, AL,
--					     CA, SK, and SO.
-------------------------------------------------------------------------------
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 17-May-2007
if p_effective_date < fnd_date.canonical_to_date('2007/05/17') then
   if p_to_pay_plan in ('ES','EX','GM','SL','ST')
      and
	p_retention_allowance is not null
	and
      to_number(p_retention_allowance) > (to_number(p_to_basic_pay) * .25) then
      hr_utility.set_message(8301, 'GHR_37667_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
--
-- 655.15.2
/* The following edits were commented out to allow null values to be used to
   end other pay elements: Staffing Differential, Retention Allowance and Supervisory Differential.
   if p_first_noac_lookup_code = '810' and
     (p_first_action_noa_la_code1 = 'VPG' or p_first_action_noa_la_code2 = 'VPG')
      and
	p_retention_allowance is null
     then
      hr_utility.set_message(8301, 'GHR_37668_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
*/
/* Commented -- August 2001 10.7 Patch
-- 655.20.2
   if     p_first_noac_lookup_code <> 810 and
          p_retention_allowance is not null and
          to_number(p_retention_allowance) <= 0 then
      hr_utility.set_message(8301, 'GHR_37669_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
*/

end chk_retention_allowance;



/* Name:
-- Staffing Differential
*/

procedure chk_staffing_differential
  (p_staffing_differential        in varchar2
  ,p_first_noac_lookup_code       in varchar2
  ,p_first_action_noa_la_code1    in varchar2
  ,p_first_action_noa_la_code2    in varchar2
  ) is
begin

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
-- 656.10.1
   if p_staffing_differential is not null and
      to_number(p_staffing_differential) <= 0 then
      hr_utility.set_message(8301, 'GHR_37670_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
*/

-- 656.15.2
/* The following edits were commented out to allow null values to be used to
   end other pay elements: Staffing Differential, Retention Allowance and Supervisory Differential.
   if p_first_noac_lookup_code = '810' and
     (p_first_action_noa_la_code1 = 'ZTS' or p_first_action_noa_la_code2= 'ZTS') and
      p_staffing_differential is null then
      hr_utility.set_message(8301, 'GHR_37671_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
*/
/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
-- 656.20.2
   if p_first_noac_lookup_code <> '810' and
      p_staffing_differential is not null and
      to_number(p_staffing_differential) <= 0 then
      hr_utility.set_message(8301, 'GHR_37672_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
*/
null;
end chk_staffing_differential;


/* Name:
-- Supervisor Differential
*/

procedure chk_supervisory_differential
  (p_supervisory_differential             in varchar2  --non SF52
  ,p_first_noac_lookup_code               in varchar2
  ,p_first_action_noa_la_code1            in varchar2
  ,p_first_action_noa_la_code2            in varchar2
  ,p_effective_date                       in date
  ) is
begin

-- 657.15.1
-- Commented by Ashley for bug 3251402 (EOY 03)
/*   if p_supervisory_differential is not null and
      to_number(p_supervisory_differential) <= 0 then
      hr_utility.set_message(8301, 'GHR_37673_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
   */

-- 657.20.2
/* The following edits were commented out to allow null values to be used to
   end other pay elements: Staffing Differential, Retention Allowance and Supervisory Differential.
   if p_first_noac_lookup_code = '810' and
      (p_first_action_noa_la_code1 = 'VPH' or p_first_action_noa_la_code2 = 'VPH') and
      p_supervisory_differential is null then
      hr_utility.set_message(8301, 'GHR_37674_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
*/
-- 657.25.2
-- EOY'02 Patch   13-NOV-02  vnarasim  End dated the Edit as of 31-MAY-2001

if p_effective_date <= to_date('31/05/2001','dd/mm/yyyy') then
   if p_first_noac_lookup_code <> '810' and
         p_supervisory_differential is not null and
         to_number(p_supervisory_differential) <= 0 then
      hr_utility.set_message(8301, 'GHR_37675_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
end chk_supervisory_differential;



/* Name:
-- Service Computation Date
*/

procedure chk_service_comp_date
  (p_service_computation_date  in date
  ,p_effective_date            in date
  ,p_employee_date_of_birth    in date
  ,p_duty_station_lookup_code  in varchar2
  ,p_first_noac_lookup_code    in varchar2
  ,p_credit_mil_svc            in varchar2  --non SF52
  ,p_submission_date           in date      --non SF52
  ) is

begin

-- 660.03.1
   -- Renumbered from 660.01.1
   if p_service_computation_date > p_submission_date
      and
      p_service_computation_date is not null
      then
      hr_utility.set_message(8301, 'GHR_37608_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 660.02.3
   if
--	year_between(p_service_computation_date - p_employee_date_of_birth) <= 13
      (to_number(substr(to_char(p_service_computation_date, 'MMDDYYYY'),5,4)) -
      to_number(substr(to_char(p_employee_date_of_birth, 'MMDDYYYY'),5,4)) ) <=13

      and
      p_service_computation_date is not null
      then
      hr_utility.set_message(8301, 'GHR_37609_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 660.04.3
   -- end dated this edit on 27-oct-98 for bug 745246
   if p_effective_date <= to_date('31/07/1998','dd/mm/yyyy') then
      if ((
	    substr(p_duty_station_lookup_code, 1, 1) in ( '0','1','2','3','4','5','6','7','8','9')
          and
          substr(p_duty_station_lookup_code, 2, 1) in ( '0','1','2','3','4','5','6','7','8','9')
         ) or
          substr(p_duty_station_lookup_code,2,1) = 'Q'
            or
          p_duty_station_lookup_code  is null
         )
	    and
           --  Year_Between(p_service_computation_date - p_employee_date_of_birth) < 15
          (to_number(substr(to_char(p_service_computation_date, 'MMDDYYYY'),5,4)) -
           to_number(substr(to_char(p_employee_date_of_birth, 'MMDDYYYY'),5,4)) ) < 15
          and
          p_service_computation_date is not null
      then
          hr_utility.set_message(8301, 'GHR_37610_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
      end if;
   end if;

-- 660.07.2
   if p_service_computation_date > p_effective_date
      and
	p_service_computation_date is not null
	then
      hr_utility.set_message(8301, 'GHR_37611_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 660.10.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 17-Jul-2007
if p_effective_date < fnd_date.canonical_to_date('2007/07/18') then
   if substr(p_first_noac_lookup_code, 1, 1) = '1'
--	and
--      hr_utility.is_numeric(p_credit_mil_svc)
	and
      to_number(p_credit_mil_svc) > 0 and
      p_service_computation_date >= p_effective_date then
      hr_utility.set_message(8301, 'GHR_37612_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
    end if;
end if;

end chk_service_comp_date;

/* Name:
-- Social Security
*/


procedure chk_Social_Security
  ( p_agency_sub                 in varchar2   --non SF52
   ,p_employee_National_ID       in varchar2
   ,p_personnel_officer_ID       in varchar2   --non SF52
   ,p_effective_date             in date       --Bug 5487271
  ) is
l_dummy varchar2(1);
cursor c_found_poi is
  select '1' from ghr_pois
  where personnel_office_id =
    substr(p_employee_National_ID,2,2)||substr(p_employee_National_ID,5,2);
begin

-- Bug 1854488 -- 3/22/02
-- 680.00.1  Part B, Note
--   Update Date      By        Effective Date     Bug          Comment
 --  30-OCT-2003      ajose     From the Begining  3237673      Added HSDA.
 --  14-Nov-2005      Raju	From the Begining  4567571	Rename the Edit 690.00.1 to 680.00.1
 --  26-sep-2006      amrchakr  01-jul-2006        5487271      Changes edit from 680.00.1 to 680.00.3
 --                                                             and modified 680.00.3 to remove agency comparision of DJ02 or HSDA

if p_effective_date < to_date('01/07/2006','dd/mm/yyyy') then
  if p_agency_sub NOT IN ('HSDA','DJ02') and
     (
     substr(p_employee_National_ID,1,1) = '8' or
     substr(p_employee_National_ID,1,1) = '9'
     ) then
      Begin
        open c_found_poi;
        fetch c_found_poi into l_dummy;
        if c_found_poi%notfound  then

              hr_utility.set_message(8301, 'GHR_37613_ALL_PROCEDURE_FAIL');
              hr_utility.raise_error;
        end if;
        close c_found_poi;
      end;
  end if;
else
  if
     substr(p_employee_National_ID,1,1) = '8' or
     substr(p_employee_National_ID,1,1) = '9'
     then
      Begin
        open c_found_poi;
        fetch c_found_poi into l_dummy;
        if c_found_poi%notfound  then
              hr_utility.set_message(8301, 'GHR_37698_ALL_PROCEDURE_FAIL');
              hr_utility.raise_error;
        end if;
        close c_found_poi;
      end;
  end if;
end if;

-- 680.00.2  Part C, Note
 --   Update Date      By        Effective Date     Bug          Comment
 --   18-OCT-2002     vnarasim   From the Begining  2631140      Modified first 3 positions
 --                                                              of SSN from less than 738 to
 --						  		 less than 800.
 --  14-Nov-2005	  Raju		From the Begining  4567571		Rename the Edit 690.00.2 to 680.00.2
 --  26-sep-2006      amrchakr  01-jul-2006        5487271      Changes edit from 680.00.2 to 680.00.3
  if (
     substr(p_employee_National_ID,1,1) = '8' or
     substr(p_employee_National_ID,1,1) = '9'
     ) then
      Begin
        open c_found_poi;
        fetch c_found_poi into l_dummy;
        if c_found_poi%notfound  then
            if p_effective_date < to_date('01/07/2006','dd/mm/yyyy') then
                hr_utility.set_message(8301, 'GHR_37614_ALL_PROCEDURE_FAIL');
                hr_utility.raise_error;
            else
                hr_utility.set_message(8301, 'GHR_37699_ALL_PROCEDURE_FAIL');
                hr_utility.raise_error;
            end if;
        end if;
        close c_found_poi;
      end;
  end if;

  if (
     substr(p_employee_National_ID,1,1) <> '8' and
     substr(p_employee_National_ID,1,1) <> '9'
     ) and
     substr(p_employee_National_ID,1,3) not between '000' and '800'
    then
        if p_effective_date < to_date('01/07/2006','dd/mm/yyyy') then
            hr_utility.set_message(8301, 'GHR_37615_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        else
            hr_utility.set_message(8301, 'GHR_38478_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
  end if;

end chk_Social_Security;


/* Name:
-- Step or Rate
*/


procedure chk_step_or_rate
  (p_step_or_rate              in varchar2
  ,p_pay_rate_determinant      in varchar2
  ,p_to_pay_plan               in varchar2
  ,p_to_grade_or_level         in varchar2
  ,p_first_action_noa_la_code1 in varchar2
  ,p_first_action_noa_la_code2 in varchar2
  ,p_Cur_Appt_Auth_1           in varchar2  --non SF52 item
  ,p_Cur_Appt_Auth_2           in varchar2  --non SF52 item
  ,p_effective_date            in date
  ,p_rpa_step_or_rate       in varchar2
  ) is

begin

-- 700.02.3
 -- Update Date        By        Effective Date  Bug           Comment
 --   9   09/14/99    vravikan   01-Mar-1999     992944         Exclude T
 --       06/25/03    vravikan                 Trigger this edit if the g_temp_step is not null
 --                                            and prd is '0' or '6'
 --       06/26/03    vravikan                 Use p_rpa_step_or_rate if g_temp_step is not null
 --                                            becuase p_step_or_rate contains TPS value
 --       12/11/08    Raju       Start date     7633560         Exclude D
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    IF GHR_GHRWS52L.g_temp_step is not null THEN
    if p_effective_date >= fnd_date.canonical_to_date('1999/03/01') then
       if (
             p_pay_rate_determinant in ('0','6','2','3','4','A','B','C','E','F','G','H',
                                        'I','J','K','L','N','O',
                                      'Q','R','S','U','V','W','X','Y','Z')
             ) and
          p_to_pay_plan not in ('WT','FA','EX')
          and
          p_rpa_step_or_rate <> '00'
          and
          p_rpa_step_or_rate is not null
          then
          hr_utility.set_message(8301, 'GHR_37186_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    else
       if (
         p_pay_rate_determinant in ('0','6','2','3','4','A','B','C','E','F','G','H','I','J','K','L','N','O',
                                      'Q','R','S','T','U','V','W','X','Y','Z')
         ) and
          p_to_pay_plan not in ('WT','FA','EX')
          and
          p_rpa_step_or_rate <> '00'
          and
          p_rpa_step_or_rate is not null
          then
          hr_utility.set_message(8301, 'GHR_37616_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
    ELSE
    if p_effective_date >= fnd_date.canonical_to_date('1999/03/01') then
       if (
             p_pay_rate_determinant in ('2','3','4','A','B','C','E','F','G','H',
                                        'I','J','K','L','N','O',
                                      'Q','R','S','U','V','W','X','Y','Z')
             ) and
          p_to_pay_plan not in ('WT','FA','EX')
          and
          p_step_or_rate <> '00'
          and
          p_step_or_rate is not null
          then
          hr_utility.set_message(8301, 'GHR_37186_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    else
       if (
         p_pay_rate_determinant in ('2','3','4','A','B','C','E','F','G','H','I','J','K','L','N','O',
                                      'Q','R','S','T','U','V','W','X','Y','Z')
         ) and
          p_to_pay_plan not in ('WT','FA','EX')
          and
          p_step_or_rate <> '00'
          and
          p_step_or_rate is not null
          then
          hr_utility.set_message(8301, 'GHR_37616_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
    END IF;
end if;
-- 700.04.3
-- -- Madhuri        19-MAY-2004    Included VP in the list
--
   if (p_to_pay_plan in ('GG','GS','VP'))
       and
       p_Cur_Appt_Auth_1 <> 'UAM'
	and
       p_Cur_Appt_Auth_2 <> 'UAM'
	and
      (p_to_grade_or_level between '01' and '15')
	and
       p_pay_rate_determinant in ('0','5','6','7')
	and
       p_step_or_rate not in ('01','02','03','04','05','06','07','08',
                              '09','10','11','12','13','14','15')
      and
      p_step_or_rate is not null
then
      hr_utility.set_message(8301, 'GHR_37617_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 700.07.3
-- Madhuri        19-MAY-2004    Removed VP from the list
-- 13-Jun-06			Raju	 Terminate the edit eff from 01-Jan-03
--
IF p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
   if	(p_to_pay_plan ='VM' ) and /*or p_to_pay_plan ='VP') */
		p_to_grade_or_level <> 97 and
		p_step_or_rate not in ('01','02','03','04','05','06',
                             '07','08','09','10') and
		p_step_or_rate is not null
	then
      hr_utility.set_message(8301, 'GHR_37618_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
END IF;

-- 700.10.3
-- Update/Change Date	By			Effective Date		Comment
-- 13-Jun-06			Raju		01-Jan-03			Terminate the edit
IF p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
	if	p_to_pay_plan = 'VM' and p_to_grade_or_level = '97' and
        p_step_or_rate not in ('01','02','03','04','05','06',
                                '07','08','09') and
		p_step_or_rate is not null
	then
	  hr_utility.set_message(8301, 'GHR_37619_ALL_PROCEDURE_FAIL');
	  hr_utility.raise_error;
	end if;
END IF;

-- 700.12.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'VN' and
         p_step_or_rate not in ('00','01','02','03','04','05','06','07',
                                '08','09','10','11','12','13','14','15',
                                '16','17','18','19','20','21','22','23',
                                '24','25','26','27','28')
      and
      p_step_or_rate is not null
then
      hr_utility.set_message(8301, 'GHR_37620_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.14.3
   -- Update 7 on 16 jun 98. Added 00 to step or rate
   --upd47  26-Jun-06	Raju	   From 01-Apr-2006		    Added 611,613
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_effective_date < fnd_date.canonical_to_date('2006/04/01') then
       if p_to_pay_plan = 'XE' and
          p_step_or_rate not in ('00','01','02','03') and
          p_step_or_rate is not null then
          hr_utility.set_message(8301, 'GHR_37621_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('STEP_RATE','00 through 03');
          hr_utility.raise_error;
       end if;
    else
        if p_to_pay_plan = 'XE' and
          p_step_or_rate not in ('01','02','03') and
          p_step_or_rate is not null then
          hr_utility.set_message(8301, 'GHR_37621_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('STEP_RATE','01 through 03');
          hr_utility.raise_error;
       end if;
    end if;
end if;

-- 700.16.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_to_pay_plan ='CE' or p_to_pay_plan ='CY') and
       p_step_or_rate not in ('00','01','02','03','04','05','06','07',
                                '08','09','10','11','12','13','14','15',
                                '16','17','18','19','20','21')
      and
      p_step_or_rate is not null
then
      hr_utility.set_message(8301, 'GHR_37622_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.19.3
   --       17-Aug-00   vravikan   01-jan-2000        Delete 99
   --       06-Aug-07   Raju       5132113 Added GR Phy and Dentist change
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_effective_date >= to_date('1999/01/01','yyyy/mm/dd') then
       if p_to_pay_plan in ('GR','GM') and p_step_or_rate <> '00' and
          p_step_or_rate is not null
       then
          hr_utility.set_message(8301, 'GHR_37436_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN',p_to_pay_plan);--Bug# 6341069
          hr_utility.raise_error;
       end if;
    else
       if p_to_pay_plan = 'GM' and
          (p_step_or_rate <> '00' and p_step_or_rate <> '99')
          and
          p_step_or_rate is not null
       then
          hr_utility.set_message(8301, 'GHR_37623_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

-- 700.22.2
-- EOY'02 Patch   13-NOV-02  vnarasim  End dated the Edit as of 31-MAY-2001

if p_effective_date <= to_date('31/05/2001','dd/mm/yyyy') then
   if (p_to_pay_plan ='ES' or p_to_pay_plan ='FE') and
       p_step_or_rate not in ('01','02','03','04','05','06') and
	p_step_or_rate is not null then
      hr_utility.set_message(8301, 'GHR_37624_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.31.3
   if p_to_pay_plan = 'FO' and
         p_step_or_rate not in ('01','02','03','04','05','06','07','08',
                                '09','10','11','12','13','14')
      and
      p_step_or_rate is not null
then
      hr_utility.set_message(8301, 'GHR_376_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 700.34.3
   if p_to_pay_plan = 'FP' and
         p_to_grade_or_level in ('01','02','03','04','05','06','07','08','09') and
         p_step_or_rate not in ('01','02','03','04','05','06','07','08',
                                '09','10','11','12','13','14')
      and
      p_step_or_rate is not null
then
      hr_utility.set_message(8301, 'GHR_37626_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 700.35.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'FP' and
         p_to_grade_or_level in ('AA','BB','CC','DD','EE') and
         p_step_or_rate not in ('01','02','03','04','05')
      and
      p_step_or_rate is not null
   then
      hr_utility.set_message(8301, 'GHR_37627_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.37.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'AF' and
         p_step_or_rate not in ('01','02','03','04','05')
      and
      p_step_or_rate is not null
   then
      hr_utility.set_message(8301, 'GHR_37628_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.40.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'FC' and
         p_to_grade_or_level in ('02','03','04','05','06','07',
                     '08','09','10','11','12') and
         p_step_or_rate not in ('01','02','03','04','05','06',
                                '07','08','09','10')
      and
      p_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37629_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.43.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'FC' and p_to_grade_or_level = '13' and
         p_step_or_rate not in ('01','02','03','04','05',
                                '06','07','08','09')
      and
      p_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37630_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.47.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'FC' and p_to_grade_or_level = '14' and
         p_step_or_rate not in ('01','02','03','04','05')
      and
      p_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37631_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.50.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan in ('CA','SL','ST') and
         p_step_or_rate <> '00'
      and
      p_step_or_rate is not null
    then

      hr_utility.set_message(8301, 'GHR_37632_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.55.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'AL' and
     (p_to_grade_or_level = '01' or p_to_grade_or_level = '02') and
         (p_step_or_rate <> '00'
      and
      p_step_or_rate is not null)
    then
      hr_utility.set_message(8301, 'GHR_37633_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.60.3
   if p_to_pay_plan = 'AL' and p_to_grade_or_level = '03' and
      --   p_step_or_rate not in ('A','B','C','D','E','F') -- bug 611870
         p_step_or_rate not in ('01','02','03','04','05','06')
      and
      p_step_or_rate is not null
then
      hr_utility.set_message(8301, 'GHR_37634_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 700.62.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'GG' and p_to_grade_or_level = 'SL' and
         p_step_or_rate <>'00'
      and
      p_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37635_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.65.3
   if p_to_pay_plan = 'GG' and
         p_to_grade_or_level in ('01','02','03','04','05',
                     '06','07','08','09','10',
                     '11','12','13','14','15') and
         p_pay_rate_determinant in ('0','5','6','7') and
         (p_Cur_Appt_Auth_1 = 'UAM' or p_Cur_Appt_Auth_2 = 'UAM') and
         p_step_or_rate not in ('01','02','03','04','05','06',
                                '07','08','09','10','11','12')
      and
      p_step_or_rate is not null
then
      hr_utility.set_message(8301, 'GHR_37636_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 700.67.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'FG'
      and
	p_step_or_rate not in ('01','02','03','04','05','06',
                                '07','08','09','10', '00')
      and
      p_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37637_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 700.69.3
   /*   If pay plan is IJ,
        And pay rate determinant is 0 or 7,
        Then step or rate must be 01 through 04 or asterisks.
        Default:  Insert asterisks in step or rate. */
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'IJ' and
      p_pay_rate_determinant in ('0','7') and
      p_step_or_rate not in ('01','02','03','04') and
      p_step_or_rate is not null then
      hr_utility.set_message(8301, 'GHR_38552_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

end chk_step_or_rate;

/* Name:
-- Supervisory Status
*/


procedure chk_supervisory_status
  (p_supervisory_status_code in varchar2
  ,p_to_pay_plan             in varchar2
  ,p_effective_date          in date
  ) is
begin

-- 710.07.3
   if p_to_pay_plan in ('BS','JR','JT','KS','NS','WA',
                        'WN','WQ','WS','XC','XN','XS')
and
      p_supervisory_status_code <>'2'
and
      p_supervisory_status_code is not null
then
      hr_utility.set_message(8301, 'GHR_37638_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 710.10.3
   if p_to_pay_plan = 'FA' and
         p_supervisory_status_code <>'2'
and
      p_supervisory_status_code is not null
then
      hr_utility.set_message(8301, 'GHR_37639_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 710.13.3
   if p_to_pay_plan in ('ES','EX','FE') and
     (p_supervisory_status_code <>'2' and p_supervisory_status_code <>'8')
and
      p_supervisory_status_code is not null
then
      hr_utility.set_message(8301, 'GHR_37640_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 710.16.3
   if p_to_pay_plan = 'GM' and
         p_supervisory_status_code not in ('2','4','5','7')
and
      p_supervisory_status_code is not null
then
      hr_utility.set_message(8301, 'GHR_37641_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 710.19.3
   if p_to_pay_plan in ('BL','JL','JQ','KL','NL',
                        'WL','WO','WR','XB','XL') and
     (p_supervisory_status_code <>'6')
and
      p_supervisory_status_code is not null
then
      hr_utility.set_message(8301, 'GHR_37642_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 710.22.3
   if p_to_pay_plan in ('BB','ED','EE','EF','EG',
                        'EH','EI','JG','JP','KG',
                        'NA','WD','WG','WK','WT',
                        'WU','WY','XA','XD','XP') and
     (p_supervisory_status_code <> '4' and p_supervisory_status_code <> '8')
and
      p_supervisory_status_code is not null
then
      hr_utility.set_message(8301, 'GHR_37643_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
-- 710.25.3
  -- Dec 2001 Patch      1-Sep-2001       Delete WZ
   if p_effective_date <= to_date('2000/08/31','yyyy/mm/dd') THEN
     if p_to_pay_plan in ('BP','WB','WE','WM','WZ') and
         p_supervisory_status_code not in ('2','6','8') and
      p_supervisory_status_code is not null then
      hr_utility.set_message(8301, 'GHR_37644_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
     end if;
   else
     if p_to_pay_plan in ('BP','WB','WE','WM') and
         p_supervisory_status_code not in ('2','6','8') and
      p_supervisory_status_code is not null then
      hr_utility.set_message(8301, 'GHR_37923_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
     end if;
   end if;

end chk_supervisory_status;


/* Name:
-- Tenure
*/

procedure chk_tenure
  (p_tenure_group_code         in varchar2
  ,p_to_pay_plan               in varchar2
  ,p_first_action_noa_la_code1 in varchar2
  ,p_first_action_noa_la_code2 in varchar2
  ,p_first_noac_lookup_code    in varchar2
  ,p_Cur_Appt_Auth_1           in varchar2  --non SF52 item
  ,p_Cur_Appt_Auth_2           in varchar2  --non SF52 item
  ,p_effective_date            in date
  ) is
begin

-- 720.02.3
   if p_to_pay_plan ='ES' and p_tenure_group_code <> 0 then
      hr_utility.set_message(8301, 'GHR_37645_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 720.04.3
   if p_to_pay_plan in ('VM','VN','VP')
and
         p_tenure_group_code <>'1'
and
         p_tenure_group_code is not null
then
      hr_utility.set_message(8301, 'GHR_37646_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 720.08.3
   if (p_Cur_Appt_Auth_1 in ('Y7M', 'Y8M', 'Y9K', 'Y9M')  or
	 p_Cur_Appt_Auth_2 in ('Y7M', 'Y8M', 'Y9K', 'Y9M')) and
       p_tenure_group_code not in ('0', '3' ) and
       p_tenure_group_code is not null
   then
      hr_utility.set_message(8301, 'GHR_37647_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 720.13.2
-- Updated_by       Updated_on        Effective_Date        Description
-- amrchakr         28-sep-2006       01-jul-2003           Delete NOA's 151,155,157,551,555

   if p_effective_date < to_date('2003/07/01','yyyy/mm/dd') THEN
       if p_first_noac_lookup_code in ('100','130','140','151','155',
                                      '157','500','540','551','555') and
           p_tenure_group_code <> '1' and
	   p_tenure_group_code <> '2' and
	   p_tenure_group_code is not null
       then
          hr_utility.set_message(8301, 'GHR_37648_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    else
       if p_first_noac_lookup_code in ('100','130','140','500','540') and
           p_tenure_group_code <> '1' and
           p_tenure_group_code <> '2' and
           p_tenure_group_code is not null
       then
           hr_utility.set_message(8301, 'GHR_37700_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       end if;
    end if;

-- 720.16.2
-- Updated_by       Updated_on        Effective_Date        Description
-- amrchakr         28-sep-2006       01-jul-2003           Delete NOA's 150, 550

   if p_effective_date < to_date('2003/07/01','yyyy/mm/dd') THEN
       if p_first_noac_lookup_code in ('101','141','150','501','541','550') and
           p_tenure_group_code <>'2'  and
	   p_tenure_group_code is not null then
           hr_utility.set_message(8301, 'GHR_37649_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       end if;
   else
       if p_first_noac_lookup_code in ('101','141','501','541') and
           p_tenure_group_code <>'2'  and
	   p_tenure_group_code is not null then
           hr_utility.set_message(8301, 'GHR_37587_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       end if;
   end if;

--UPDATED_BY	DATE		COMMENTS
------------------------------------------------------------
-- Madhuri     14-SEP-2004     Removed the NOACS- 112, 512
--amrchakr     28-sep-2006     Delete NOA's 153,154,553,554
--Raju         11-Oct-2007     Delete NOA's 171,571 Bug#6469079
-------------------------------------------------------------

-- 720.19.2
   if p_effective_date < to_date('01/03/1998', 'dd/mm/yyyy') then
      if p_first_noac_lookup_code in ('107','108','115','117','120',
                                      '122','124','153','154','171','190',
                                      '507','508','515','517','520',
                                      '522','524','553','554','571','590') and
         p_tenure_group_code <> '0' and
         p_tenure_group_code <> '3' and
         p_tenure_group_code is not null   then
         hr_utility.set_message(8301, 'GHR_37650_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   elsif p_effective_date < to_date('2003/07/01','yyyy/mm/dd') THEN
      -- removed noac 117 and 517 as per update 7
      -- removed noacs 112, 512 for EOY I
      if p_first_noac_lookup_code in ('107','108','115','120',
                                      '122','124','153','154','171','190',
                                      '507','508','515','520',
                                      '522','524','553','554','571','590') and
         p_tenure_group_code <> '0' and
         p_tenure_group_code <> '3' and
         p_tenure_group_code is not null   then
         hr_utility.set_message(8301, 'GHR_37870_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   elsif p_effective_date < to_date('2007/05/01','RRRR/MM/DD') THEN -- Bug#6469079
      if p_first_noac_lookup_code in ('107','108','115','120',
                                      '122','124','171','190',
                                      '507','508','515','520',
                                      '522','524','571','590') and
         p_tenure_group_code <> '0' and
         p_tenure_group_code <> '3' and
         p_tenure_group_code is not null   then
         hr_utility.set_message(8301, 'GHR_37588_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('NOAC','107, 108, 115, 120, 122, 124, 171, 190, 507, 508, 515, 520, 522, 524, 571, or 590');
         hr_utility.raise_error;
      end if;
   ELSE--Begin Bug#6469079
        if p_first_noac_lookup_code in ('107','108','115','120',
                                      '122','124','190',
                                      '507','508','515','520',
                                      '522','524','590') and
         p_tenure_group_code <> '0' and
         p_tenure_group_code <> '3' and
         p_tenure_group_code is not null   then
         hr_utility.set_message(8301, 'GHR_37588_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('NOAC','107, 108, 115, 120, 122, 124, 190, 507, 508, 515, 520, 522, 524, or 590');
         hr_utility.raise_error;
      end if;--End Bug#6469079
   end if;


-- 720.22.2
   -- Dec 01 Patch 12/10/01    vravikan  From the Begining  -- Add YCM
   --                                    01-Oct-01          --  Delete YAM and Y4M
   --upd47  26-Jun-06	Raju	   From 01-Apr-2006		    Added pay plan condition
   --Upd57  01-Mar-09   Mani       From 01-Mar-2009         ---Removed Pay Plan Condition

if p_effective_date < fnd_date.canonical_to_date('2006/04/01') then
    if p_effective_date >= to_date('2001/10/01','yyyy/mm/dd')  then
     if p_first_action_noa_la_code1 in ('YBM','YCM','YGM',
                                     'Y1M','Y2M','Y3M') and
          p_tenure_group_code <>'2'  and
       p_tenure_group_code is not null then
      hr_utility.set_message(8301, 'GHR_37919_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
     end if;
    else
     if p_first_action_noa_la_code1 in ('YAM','YBM','YCM','YGM',
                                   'Y1M','Y2M','Y3M','Y4M') and
          p_tenure_group_code <>'2'  and
       p_tenure_group_code is not null then
      hr_utility.set_message(8301, 'GHR_37651_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
     end if;
    end if;
elsif p_effective_date < fnd_date.canonical_to_date('2009/03/01') then
    if p_first_action_noa_la_code1 in ('YAM','YBM','YCM','YGM',
                                   'Y1M','Y2M','Y3M','Y4M') and
        substr(p_to_pay_plan,1,1) in ('Y') and
        p_tenure_group_code <>'2'  and
        p_tenure_group_code is not null then
      hr_utility.set_message(8301, 'GHR_37187_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
     end if;
else
   if p_first_action_noa_la_code1 in ('YAM','YBM','YCM','YGM',
                                   'Y1M','Y2M','Y3M','Y4M') and
        p_tenure_group_code <>'2'  and
        p_tenure_group_code is not null then
      hr_utility.set_message(8301, 'GHR_37651_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
     end if;
end if;


-- 720.25.2
   if  p_first_noac_lookup_code in ('170', '570') and
       p_first_action_noa_la_code1 not in ('ZKM','ZNM') and
       p_first_action_noa_la_code2 not in ('ZKM','ZNM') and
       p_tenure_group_code = '0' then
      hr_utility.set_message(8301, 'GHR_37652_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 720.28.2
   -- added effective dates on 16-jul-1998
   if p_effective_date < to_date('01/03/1998', 'dd/mm/yyyy') then
      if (p_first_noac_lookup_code in ('760','761')) and
          p_tenure_group_code <> '0' and
          p_tenure_group_code <> '3' and
	    p_tenure_group_code is not null   then
         hr_utility.set_message(8301, 'GHR_37653_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   else
      if (p_first_noac_lookup_code = '760') and
          p_tenure_group_code <> '0' and
          p_tenure_group_code <> '3' and
	    p_tenure_group_code is not null   then
         hr_utility.set_message(8301, 'GHR_37869_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;

-- 720.31.2
   if p_first_noac_lookup_code = '765' and
         p_tenure_group_code <>'3'  and
	   p_tenure_group_code is not null then
      hr_utility.set_message(8301, 'GHR_37654_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 720.34.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_first_noac_lookup_code = '892' or p_first_noac_lookup_code = '893')
	 and
	 p_to_pay_plan = 'GS' and
       p_tenure_group_code = '0' then
      hr_utility.set_message(8301, 'GHR_37655_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 720.35.3
--UPDATED_BY	DATE		COMMENTS
------------------------------------------------------------
--amrchakr     28-sep-2006     Remove the tenure 3 from 01/07/2006
-------------------------------------------------------------

  if p_effective_date < to_date('01/07/2006', 'dd/mm/yyyy') then
      if (p_Cur_Appt_Auth_1  = 'ZKM' or p_Cur_Appt_Auth_2 = 'ZKM') and
         (p_to_pay_plan ='AD' or p_to_pay_plan ='EX') and
         ( p_tenure_group_code <> '0' and p_tenure_group_code <> '3')
      then
         hr_utility.set_message(8301, 'GHR_37656_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
  else
     if (p_Cur_Appt_Auth_1  = 'ZKM' or p_Cur_Appt_Auth_2 = 'ZKM') and
         (p_to_pay_plan ='AD' or p_to_pay_plan ='EX') and
         p_tenure_group_code <> '0'
      then
         hr_utility.set_message(8301, 'GHR_37589_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
  end if;

-- 720.40.3
   if (p_Cur_Appt_Auth_1  = 'ZNM' or p_Cur_Appt_Auth_2 = 'ZNM') and
         (p_to_pay_plan ='AD' or p_to_pay_plan ='EX') and
         p_tenure_group_code <> '0' then
      hr_utility.set_message(8301, 'GHR_37657_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

end chk_tenure;

/* Name:
-- Veterans Preference
*/

procedure chk_veterans_pref
  (p_veterans_preference_code 	in varchar2
  ,p_first_action_noa_la_code1 	in varchar2
  ,p_first_action_noa_la_code2 	in varchar2
  ) is
begin

-- 750.02.2
   if (p_first_action_noa_la_code1 in ('LBM','LZM','NEM','MMM') or
       p_first_action_noa_la_code2 in ('LBM','LZM','NEM','MMM')) and
      p_veterans_preference_code not in ('2','3','4','6') and
	p_veterans_preference_code is not null then
      hr_utility.set_message(8301, 'GHR_37658_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

end chk_veterans_pref;

/* Name:
-- Veterans Status
*/


procedure chk_veterans_status
  (p_veterans_status_code     		in varchar2
  ,p_veterans_preference_code 		in varchar2
  ,p_first_noac_lookup_code     	in varchar2
  ,p_agency_sub                         in varchar2   --non SF52
  ,p_first_action_noa_la_code1          in varchar2
  ) is
begin

--760.00.1  From Part B, notes
    if p_veterans_status_code is null and
       (
        p_agency_sub not in ('AFNG','AFZG','ARNG')
	or
	(p_agency_sub = 'CM63' and p_first_action_noa_la_code1 = 'XZM')
	)
      then
      hr_utility.set_message(8301, 'GHR_37659_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 760.05.3
   if p_veterans_status_code = 'X' and
      p_veterans_preference_code in ('2','3','4','6') then
      hr_utility.set_message(8301, 'GHR_37660_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 760.10.2
--  Updation Date    Updated By     Remarks
--  ============================================
--  19-MAR-2003      vnarasim       Added Other than 132 condition.

   if substr(p_first_noac_lookup_code,1,1) = '1' and
      p_first_noac_lookup_code <> '132' and
      p_veterans_status_code = 'N' then
      hr_utility.set_message(8301, 'GHR_37661_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

end chk_veterans_status;

/* Name:
-- Work Schedule
*/

procedure chk_work_schedule
  (p_work_schedule_code     in varchar2
  ,p_first_noac_lookup_code in varchar2
  ) is
begin

-- 770.02.2
--  28-Nov-2002   Madhuri    removed NOA Code 430
-- Modified for dual actions

  if NVL(ghr_process_sf52.g_dual_action_yn,'N') = 'N' then
   if (p_first_noac_lookup_code ='280') and
   --  or p_first_noac_lookup_code ='430')
      (NVL(p_work_schedule_code,'G') not in ('G','Q','J','T'))  then
      hr_utility.set_message(8301, 'GHR_37662_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
  --8294224 Modified to consider the prior work schedule also for dual correction
  elsif NVL(ghr_process_sf52.g_dual_action_yn,'N') = 'Y' then
     if (p_first_noac_lookup_code ='280') and
   --  or p_first_noac_lookup_code ='430')
      (NVL(p_work_schedule_code,'G') not in ('G','Q','J','T')) and
      (NVL(ghr_process_sf52.g_dual_prior_ws,'G') not in ('G','Q','J','T')) then
      hr_utility.set_message(8301, 'GHR_37662_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
 end if;

end chk_work_schedule;
--
--
--
procedure chk_degree_attained
   ( p_effective_date       in date
    ,p_year_degree_attained in varchar2
    ,p_as_of_date           in date
   ) is
begin
-- 780.03.1
/*  as_of_date is the same as effective date.
   if p_year_degree_attained is not null then
      if NOT (p_year_degree_attained <= p_as_of_date) then
         hr_utility.set_message(8301, 'GHR_99997_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
 */
-- 780.03.2
   if p_year_degree_attained is not null then
      if NOT (to_number(p_year_degree_attained) <=
                       to_number(to_char(p_effective_date,'YYYY'))) then
         hr_utility.set_message(8301, 'GHR_38411_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;


end chk_degree_attained;


end GHR_CPDF_CHECK6;

/
