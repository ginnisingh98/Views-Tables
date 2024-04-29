--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK3" AS
/* $Header: ghcpdf03.pkb 120.21.12010000.3 2009/03/10 13:19:04 utokachi ship $ */

   max_per_diem		number(5)		:=	1000;
   min_basic_pay	number(10,2);
   max_basic_pay	number(10,2);

/* Name:
--     Nature of Action
*/

PROCEDURE chk_Nature_of_Action
  (p_First_NOAC_Lookup_Code       IN VARCHAR2
  ,p_Second_NOAC_Lookup_code      IN VARCHAR2
  ,p_First_Action_NOA_Code1       IN VARCHAR2
  ,p_First_Action_NOA_Code2       IN VARCHAR2
  ,p_Cur_Appt_Auth_1              IN VARCHAr2  --  non SF52 item
  ,p_Cur_Appt_Auth_2              IN VARCHAr2  -- non SF52 item
  ,p_Employee_Date_of_Birth       IN DATE
  ,p_Duty_Station_Lookup_Code     IN VARCHAR2
  ,p_Employee_First_Name          IN VARCHAR2
  ,p_Employee_Last_Name           IN VARCHAR2
  ,p_Handicap                     IN VARCHAR2   -- non SF52 item
  ,p_Organ_Component              IN VARCHAR2   -- non SF52 item
  ,p_Personal_Office_ID           IN VARCHAR2   -- non SF52 item
  ,p_Position_Occ_Code            IN VARCHAR2
  ,p_Race_National_Region         IN VARCHAR2   -- non SF52 item
  ,p_Retirement_Plan_Code         IN VARCHAR2
  ,p_Service_Computation_Date     IN DATE
  ,p_Sex                          IN VARCHAR2   -- non SF52 item
  ,p_Supervisory_Status_Code      IN VARCHAR2
  ,p_Tenure_Group_Code            IN VARCHAR2
  ,p_Veterans_Pref_Code           IN VARCHAR2
  ,p_Veterans_Status_Code         IN VARCHAR2
  ,p_Occupation                   IN VARCHAR2   -- non SF52 item
  ,p_To_Pay_Basis                 IN VARCHAR2
  ,p_To_Grade_Or_Level            IN VARCHAR2
  ,p_To_Pay_Plan                  IN VARCHAR2
  ,p_pay_rate_determinant_code    IN VARCHAR2
  ,p_To_Basic_Pay                 IN VARCHAR2
  ,p_To_Step_Or_Rate              IN VARCHAR2
  ,p_Work_Sche_Code               IN VARCHAR2
  ,p_Prior_Occupation             IN VARCHAR2   -- non SF52 item
  ,p_Prior_To_Pay_Basis           IN VARCHAR2   -- non SF52 item
  ,p_Prior_To_Grade_Or_Level      IN VARCHAR2   -- non SF52 item
  ,p_Prior_To_Pay_Plan            IN VARCHAR2   -- non SF52 item
  ,p_Prior_Pay_Rate_Det_Code      IN VARCHAR2   -- non SF52 item
  ,p_Prior_To_Basic_Pay           IN VARCHAR2   -- non SF52 item
  ,p_Prior_To_Step_Or_Rate        IN VARCHAR2   -- non SF52 item
  ,p_Prior_Work_Sche_Code         IN VARCHAR2   -- non SF52 item
  ,p_prior_duty_station           IN VARCHAR2
  ,p_Retention_Allowance          IN VARCHAR2   -- non SF52 item
  ,p_Staff_Diff                   IN VARCHAR2   -- non SF52 item
  ,p_Supervisory_Diff             IN VARCHAR2   -- non SF52 item
  ,p_To_Locality_Adj              IN VARCHAR2
  ,p_Prior_To_Locality_Adj        IN VARCHAR2   -- non SF52 item
  ,p_noa_family_code              IN VARCHAR2
  ,p_effective_date               IN DATE
  ,p_agency_subelement            IN VARCHAR2
  ,p_ethnic_race_info             IN VARCHAR2   -- 17/11/2005  Raju  4567571(UPD45)  Added this parameter
  ) is

l_session                                 ghr_history_api.g_session_var_type;
l_noa_family_code       ghr_families.noa_family_code%type;
Cursor c_noa_family_code IS
   Select fam.noa_family_code
   from   ghr_noa_families    nfa,
   ghr_families               fam
   where  nfa.nature_of_action_id  in ( select nature_of_action_id from
           ghr_nature_of_actions where code = p_First_NOAC_Lookup_Code )
   and    nfa.noa_family_code      = fam.noa_family_code
   and    fam.update_hr_flag       = 'Y';


begin

--  370.00.2   From Part C, Notes.
  if (p_First_NOAC_Lookup_Code = '001'
      or
      p_First_NOAC_Lookup_Code = '002'
      ) and
     (p_Second_NOAC_Lookup_code = '001'
      or
      p_Second_NOAC_Lookup_code = '002'
      or
      p_Second_NOAC_Lookup_code is null
      ) then
       hr_utility.set_message(8301, 'GHR_37201_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;


  if (p_First_NOAC_Lookup_Code <> '001'
      and
      p_First_NOAC_Lookup_Code <> '002'
      ) and
      p_Second_NOAC_Lookup_code is not null
      then
       hr_utility.set_message(8301, 'GHR_37202_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;

--  370.02.2

   -- Update Date   By        Effective Date   Bug           Comment
   ----------------------------------------------------------------------------------------------------------
   -- 07/11/02      vnarasim                   2456012       Deleted the first name check.
   -- 18/10/2004    Madhuri				                     Instead of just 001 add 817 in the list
   --							                             should this be for only first cond or for all?
   -- 17/03/2005    Madhuri                    4109207       817 to be included for all conditions except those
   --							                             involving Emp DOB and emp last name.
   -- 17/11/2005	Raju					   4567571		 Added the ethinicity and race identification condition UPD45
   ----------------------------------------------------------------------------------------------------------

if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Cur_Appt_Auth_1		  is null  then
       hr_utility.set_message(8301, 'GHR_37272_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code <>'001' and
    p_Employee_Date_of_Birth       is null  then
       hr_utility.set_message(8301, 'GHR_37273_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Duty_Station_Lookup_Code     is null  then
       hr_utility.set_message(8301, 'GHR_37274_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code <>'001' and
    ( p_Employee_Last_Name           is null ) then
       hr_utility.set_message(8301, 'GHR_37288_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Handicap                     is null  then
       hr_utility.set_message(8301, 'GHR_37276_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Organ_Component              is null  then
       hr_utility.set_message(8301, 'GHR_37277_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Personal_Office_ID           is null  then
       hr_utility.set_message(8301, 'GHR_37278_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Position_Occ_Code            is null  then
       hr_utility.set_message(8301, 'GHR_37279_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
-- Begin Bug# 4567571

--IF p_effective_date < fnd_date.canonical_to_date('2005/10/01') then
  IF p_effective_date < fnd_date.canonical_to_date('2006/01/01') then
	IF  p_First_NOAC_Lookup_Code NOT IN ('001','817') and
		p_Race_National_Region         IS NULL  THEN
		   hr_utility.set_message(8301, 'GHR_37280_ALL_PROCEDURE_FAIL');
		   hr_utility.raise_error;
	END IF;
--elsif p_effective_date >= fnd_date.canonical_to_date('2005/10/01') then
	ELSIF p_effective_date >= fnd_date.canonical_to_date('2006/01/01') THEN
	if  p_First_NOAC_Lookup_Code not in ('001','817')
		and p_effective_date < to_date('2006/07/01','yyyy/mm/dd')then
		IF (p_Race_National_Region is null and p_ethnic_race_info is null) then
		   hr_utility.set_message(8301, 'GHR_38990_ALL_PROCEDURE_FAIL');
		   hr_utility.raise_error;
		END IF;
	elsif p_First_NOAC_Lookup_Code not in ('100','001','817') then
		IF (p_Race_National_Region is null and p_ethnic_race_info is null) then
		   hr_utility.set_message(8301, 'GHR_38990_ALL_PROCEDURE_FAIL');
		   hr_utility.raise_error;
		END IF;
	end if;
end if;
-- End Bug# 4567571
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Retirement_Plan_Code         is null  then
       hr_utility.set_message(8301, 'GHR_37281_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Service_Computation_Date     is null  then
       hr_utility.set_message(8301, 'GHR_37282_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Supervisory_Status_Code      is null  then
       hr_utility.set_message(8301, 'GHR_37283_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Tenure_Group_Code            is null  then
       hr_utility.set_message(8301, 'GHR_37284_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Veterans_Pref_Code           is null  then
       hr_utility.set_message(8301, 'GHR_37285_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_Veterans_Status_Code         is null  then
       hr_utility.set_message(8301, 'GHR_37286_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
if  p_First_NOAC_Lookup_Code not in ('001','817') and
    p_sex		  is null  then
       hr_utility.set_message(8301, 'GHR_37287_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;

--  370.04.2
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   01/10/98                  Add nature of action 6__
   --       02/24/00    vravikan                   1186310   Getting noa_family_code rather
   --                                                        than using passed family code
  hr_utility.set_location('passed noa_family_code is ' || p_noa_family_code,1);
  FOR c_noa_family_code_rec in c_noa_family_code LOOP
    l_noa_family_code := c_noa_family_code_rec.noa_family_code;
    hr_utility.set_location('actual noa_family_code is ' || l_noa_family_code,2);
    exit;
  END LOOP;
if p_effective_date >= fnd_date.canonical_to_date('1998/10/01') then
  if substr(p_First_NOAC_Lookup_Code,1,1) in ('1','2','5','6','7','8')
    and
    l_noa_family_code not in ('AWARD','GHR_STUDENT_LOAN','GHR_INCENTIVE')
    and
   ( p_Occupation                   is null  or
    p_To_Pay_Basis                 is null  or
    p_To_Grade_Or_Level            is null  or
    p_To_Pay_Plan                  is null  or
    p_pay_rate_determinant_code    is null  or
    p_To_Basic_Pay                 is null  or
    p_To_Step_Or_Rate              is null  or
    p_Work_Sche_Code               is null  )
  then
     hr_utility.set_message(8301, 'GHR_37203_ALL_PROCEDURE_FAIL');
     hr_utility.raise_error;
  end if;
else
  if substr(p_First_NOAC_Lookup_Code,1,1) in ('1','2','5','7','8')
    and
    l_noa_family_code NOT IN ('AWARD','GHR_INCENTIVE')
    and
  ( p_Occupation                   is null  or
   p_To_Pay_Basis                 is null  or
   p_To_Grade_Or_Level            is null  or
   p_To_Pay_Plan                  is null  or
   p_pay_rate_determinant_code    is null  or
   p_To_Basic_Pay                 is null  or
   p_To_Step_Or_Rate              is null  or
   p_Work_Sche_Code               is null  )
   then
       hr_utility.set_message(8301, 'GHR_37204_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
end if;


--  370.07.2
    --
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   01/10/98                  Add nature of action 6__
   -- Dec 01 Patch 12/10/01    vravikan                      Exclude 815-816,825,
   --                                                          840-847, and 878-879
   -- 03/10/2003        vnarasim                             Exclude 848
   -- 30/10/2003        Ashley                               Exclude 849
    -- Get the session variable to check whether the action is correction
    -- If correction skip this edit as the prior_duty_station value
    -- might be incorrect. Bug #709282
    --
    --upd47  26-Jun-06	Raju	   From 01-May-2006		    Exclude 849
    --upd49 08-Jan-07	Raju       From 01-Jun-2004	    Bug#5619873 Add 826,827
    -- upd51 06-Feb-07	Raju       From 01-Jan-2007	    Bug#5745356 add noa 849,885,886,887,889
 ghr_history_api.get_g_session_var(l_session);
if p_effective_date >= to_date('01/10/1998', 'dd/mm/yyyy') then
    if p_effective_date < fnd_date.canonical_to_date('2006/05/01') then
        if l_session.noa_id_correct is null then
            if p_effective_date < fnd_date.canonical_to_date('2004/06/01') then
                if substr(p_First_NOAC_Lookup_Code,1,1) in ('3','4','5','6','7','8')  and
                    p_First_NOAC_Lookup_Code not in ('815','816','817','825','840','841','842',
                                    '843','844','845','846','847','848','849','878','879')
                    and
                    (p_Prior_Occupation                  is null  or
                    p_Prior_To_Pay_Basis                 is null  or
                    p_Prior_To_Grade_Or_Level            is null  or
                    p_Prior_To_Pay_Plan                  is null  or
                    p_Prior_Pay_Rate_Det_Code            is null  or
                    p_Prior_To_Basic_Pay                 is null  or
                    p_Prior_To_Step_Or_Rate              is null  or
                    p_Prior_Work_Sche_Code               is null  or
                    p_prior_Duty_Station                 is nulL
                    ) then
                    hr_utility.set_message(8301, 'GHR_37205_ALL_PROCEDURE_FAIL');
                    hr_utility.set_message_token('NOA_CODE','3--,4--,5--,6--, 7--, or 8--');
                    hr_utility.raise_error;
                end if;
            else  -- p_effective_date < '2004/06/01'
                if substr(p_First_NOAC_Lookup_Code,1,1) in ('3','4','5','6','7','8')  and
                    p_First_NOAC_Lookup_Code not in ('815','816','817','825','826','827','840','841','842',
                                    '843','844','845','846','847','848','849','878','879')
                    and
                    (p_Prior_Occupation                  is null  or
                    p_Prior_To_Pay_Basis                 is null  or
                    p_Prior_To_Grade_Or_Level            is null  or
                    p_Prior_To_Pay_Plan                  is null  or
                    p_Prior_Pay_Rate_Det_Code            is null  or
                    p_Prior_To_Basic_Pay                 is null  or
                    p_Prior_To_Step_Or_Rate              is null  or
                    p_Prior_Work_Sche_Code               is null  or
                    p_prior_Duty_Station                 is nulL
                    ) then
                    hr_utility.set_message(8301, 'GHR_37851_ALL_PROCEDURE_FAIL');
                    hr_utility.raise_error;
                end if;
            end if; -- p_effective_date < '2004/06/01'
        end if; --l_session.noa_id_correct is null
    elsif p_effective_date < fnd_date.canonical_to_date('2007/01/01') then  --p_effective_date < '2006/05/01'
        if l_session.noa_id_correct is null then
            if substr(p_First_NOAC_Lookup_Code,1,1) in ('3','4','5','6','7','8')  and
                p_First_NOAC_Lookup_Code not in ('815','816','817','825','826','827','840','841','842',
                                '843','844','845','846','847','848','878','879')
                and
                (p_Prior_Occupation                  is null  or
                p_Prior_To_Pay_Basis                 is null  or
                p_Prior_To_Grade_Or_Level            is null  or
                p_Prior_To_Pay_Plan                  is null  or
                p_Prior_Pay_Rate_Det_Code            is null  or
                p_Prior_To_Basic_Pay                 is null  or
                p_Prior_To_Step_Or_Rate              is null  or
                p_Prior_Work_Sche_Code               is null  or
                p_prior_Duty_Station                 is nulL
                ) then
                hr_utility.set_message(8301, 'GHR_37200_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('NOA_CODE','815, 816, 817, 825, 826, 827, 840 through 848, 878, 879');
                hr_utility.raise_error;
            end if;
        end if;
    else  --p_effective_date < '2006/05/01'
        if l_session.noa_id_correct is null then
            if substr(p_First_NOAC_Lookup_Code,1,1) in ('3','4','5','6','7','8')  and
                p_First_NOAC_Lookup_Code not in ('815','816','817','825','826','827','840','841','842',
                                '843','844','845','846','847','848','849','878','879','885','886','887','889')
                and
                (p_Prior_Occupation                  is null  or
                p_Prior_To_Pay_Basis                 is null  or
                p_Prior_To_Grade_Or_Level            is null  or
                p_Prior_To_Pay_Plan                  is null  or
                p_Prior_Pay_Rate_Det_Code            is null  or
                p_Prior_To_Basic_Pay                 is null  or
                p_Prior_To_Step_Or_Rate              is null  or
                p_Prior_Work_Sche_Code               is null  or
                p_prior_Duty_Station                 is nulL
                ) then
                hr_utility.set_message(8301, 'GHR_37200_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('NOA_CODE','815, 816, 817, 825, 826, 827, 840 through 849, 878, 879, 885, 886, 887, 889');
                hr_utility.raise_error;
            end if;
        end if;
    end if; --p_effective_date < '2006/05/01'
else  -- p_effective_date >=01/10/1998'
    if l_session.noa_id_correct is null then
        if substr(p_First_NOAC_Lookup_Code,1,1) in ('3','4','5','7','8')  and
            p_First_NOAC_Lookup_Code not in ('815','816','817','825','840','841','842',
                            '843','844','845','846','847','848','849','878','879')
            and
            (p_Prior_Occupation                  is null  or
            p_Prior_To_Pay_Basis                 is null  or
            p_Prior_To_Grade_Or_Level            is null  or
            p_Prior_To_Pay_Plan                  is null  or
            p_Prior_Pay_Rate_Det_Code            is null  or
            p_Prior_To_Basic_Pay                 is null  or
            p_Prior_To_Step_Or_Rate              is null  or
            p_Prior_Work_Sche_Code               is null  or
            p_prior_Duty_Station                 is nulL
            ) then
            hr_utility.set_message(8301, 'GHR_37205_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('NOA_CODE','3--,4--,5--, 7--, or 8--');
            hr_utility.raise_error;
        end if;
    end if;
end if;

-- 370.20.2
  --           17-Aug-00   vravikan   From the Start            Delete Staffing Differential
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
     if p_First_NOAC_Lookup_Code ='810' and
        p_First_Action_NOA_Code1 is null   and
        p_First_Action_NOA_Code2 is null   and
        (p_Retention_Allowance          is null  and
         p_Supervisory_Diff             is null
        ) then
           hr_utility.set_message(8301, 'GHR_37275_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
    end if;
end if;


--  370.25.2
--            06/25/03  vravikan       By Pass this edit if the employee has
--                                      RG temporary promotion
--            09/29/06  amrchakr       Changed the message as per Bug#5487271
--            03/01/07  vmididho       removed the comment related to pay_rate_determinant_code and
--                                     changed as per bug#5734491
IF GHR_GHRWS52L.g_temp_step IS NULL THEN
    if p_To_Pay_Plan is null and
	    (p_To_Basic_Pay is not null  or
         p_To_Grade_Or_Level is not null  or
         p_To_Locality_Adj is not null   or
         p_To_Pay_Basis is not null  or
         p_pay_rate_determinant_code  is not null  or
         p_To_Step_Or_Rate is not null
        ) then

            hr_utility.set_message(8301, 'GHR_37206_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
   end if;
END IF;


--  370.30.2
--  09/29/06  amrchakr       Changed the message as per Bug#5487271
 if p_Prior_To_Pay_Plan is null and
     (
	     p_Prior_To_Basic_Pay is not null  or
         p_Prior_To_Grade_Or_Level is not null  or
         p_Prior_To_Locality_Adj is not null  or
         p_Prior_To_Pay_Basis is not null  or
         p_Prior_Pay_Rate_Det_Code  is not null or
         p_Prior_To_Step_Or_Rate is not null
        ) then

           hr_utility.set_message(8301, 'GHR_37207_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
 end if;
--370.35.2
--            12/08/00  vravikan    01-oct-2000    New Edit
-- If nature of action is 600 through 610,
-- Then agency/subelement must be TD03

  IF p_effective_date >= fnd_date.canonical_to_date('2000/10/01') then
    IF p_First_NOAC_Lookup_Code between '600' and '610' and
        p_agency_subelement <> 'TD03' then
       hr_utility.set_message(8301, 'GHR_37664_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
    END IF;
  END IF;
--370.36.2
--            12/08/00  vravikan    01-oct-2000    New Edit
-- If nature of action is 871,
-- Then Agency must be AF,AR,DD, or NV.

  IF p_effective_date >= fnd_date.canonical_to_date('2000/10/01') then
    IF p_First_NOAC_Lookup_Code = '871' and
       substr(p_agency_subelement,1,2) not in ('AF','AR','DD','NV') then
       hr_utility.set_message(8301, 'GHR_37665_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
    END IF;
  END IF;

-- 370.37.2
-- Upd 47  23-Jun-06	  Raju		 From 01-Apr-06			New Edit
IF p_effective_date >= fnd_date.canonical_to_date('2006/04/01') THEN
	IF   p_First_NOAC_Lookup_Code IN ('611','612','613') AND
		 substr(p_agency_subelement,1,2) not in ('AF','AR','DD','NV') THEN
		 hr_utility.set_message(8301, 'GHR_37164_ALL_PROCEDURE_FAIL');
		 hr_utility.raise_error;
	 end if;
END IF;


--390.05.2
--	If Nature of Action is 817,
--	then Occupation Series (Job) must not be spaces.
--
--  Madhuri		19-MAY-2004	Adding new edit
--

IF  ( p_First_NOAC_Lookup_Code = '817' and  p_Occupation is null ) THEN
       hr_utility.set_message(8301, 'GHR_38886_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
END IF;

end chk_Nature_of_Action;

/* Name:
--  Occupation
*/

procedure chk_occupation
  (p_to_pay_plan              in varchar2
  ,p_occ_code                 in varchar2
  ,p_agency_sub               in varchar2 	--  non SF52 item
  ,p_duty_station_lookup_code in varchar2
,p_effective_date           in date
) is
begin

--  390.10.1
  -- 12/12/01  Change 2200 to 2500
  if (
       substr(p_to_pay_plan,1,1) = 'G' or p_to_pay_plan = 'LG' or
       p_to_pay_plan = 'ST'
      )
    and
	to_number(p_occ_code) >= 2500
    and
	p_occ_code is not null
   then
       hr_utility.set_message(8301, 'GHR_37208_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

--  390.16.1
  if   substr(p_to_pay_plan,1,1) in ('W','X', 'K')
       and
      (to_number(p_occ_code) < 2499) then
       hr_utility.set_message(8301, 'GHR_37209_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

--  390.31.1
  if (p_occ_code = '0605' and substr(p_agency_sub,1,2) <>'VA') then
       hr_utility.set_message(8301, 'GHR_37210_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

--  390.43.1
  --
  -- removing occ code 2806 and 2808 as per update 7 on 17-jul-98
  --
--            12/8/00   vravikan    From the Start         Add 2806 and 2808
--            11/28/02   Madhuri     			  Commented edit
/*  if   p_occ_code in ('2619','2843','2806','2808')
     and (
	    substr(p_agency_sub,1,2) <> 'DN'
	 )
    then
       hr_utility.set_message(8301, 'GHR_37211_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;*/

/* Commented as per December 2000 cpdf changes -- vravikan
--  390.44.1
  --
  -- Added the edit as per update 7 on 17-jul-98
  --
  if   p_occ_code in ('2806','2808')
     and (
	    substr(p_agency_sub,1,2) not in ('DN', 'IN07')
	 )
    then
       hr_utility.set_message(8301, 'GHR_37881_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

*/
--  390.45.1
--
--            12/8/00   vravikan    01-Oct-2000    New Edit
--  Upd 43    09-NOV-05   Raju      01-Jul-2004    Terminate the Edit Effective 01-Jul-2004
if p_effective_date < fnd_date.canonical_to_date('2004/07/01') then
	if p_effective_date >= fnd_date.canonical_to_date('2000/10/01') then
	  if   p_occ_code in ('4431')
		 and (
				substr(p_agency_sub,1,2) not in ('LP')
			 )
		then
		   hr_utility.set_message(8301, 'GHR_37678_ALL_PROCEDURE_FAIL');
		   hr_utility.raise_error;
	  end if;
	end if;
end if;

--  390.47.1
  --
   --            12/8/00   vravikan    01-Oct-2000    New Edit
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_effective_date >= fnd_date.canonical_to_date('2000/10/01') then
      if   p_occ_code in ('0898','1398','1598')
         and (
                p_agency_sub not in ('CM57')
             )
        then
           hr_utility.set_message(8301, 'GHR_37679_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
      end if;
    end if;
end if;
--  390.07.2
   -- 12/12/01 Change 2200 to 2500
   if  (
	p_to_pay_plan = 'ST' or  p_to_pay_plan ='LG'  or
        substr(p_to_pay_plan,1,1) = 'G'
        )
    and
        to_number(p_occ_code) >= 2500
    and
        p_occ_code is not null
    then
       hr_utility.set_message(8301, 'GHR_37212_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

--  390.13.2
   if substr(p_to_pay_plan,1,1) in ('W', 'X', 'K')
      and
        to_number(p_occ_code) <= 2499
      and
       p_occ_code is not null
     then
       hr_utility.set_message(8301, 'GHR_37213_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

--  390.28.2
   if  p_occ_code = '0605' and
       substr(p_agency_sub, 1, 2) <> 'VA'
     then
       hr_utility.set_message(8301, 'GHR_37214_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

/* Commented as per December 2000 cpdf changes -- vravikan
--  390.34.2
   if p_occ_code = '0805' and
      not (
          substr(p_agency_sub, 1, 2) in ('AF', 'AR', 'DD', 'NV')
	    and
          substr(p_duty_station_lookup_code, 1, 2) in ('04', '06', '15', '32')
           )
      and
         p_duty_station_lookup_code is not null
	then
       hr_utility.set_message(8301, 'GHR_37215_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

*/
--  390.40.2
   --
   -- removing occ code 2806 and 2808 as per update 7 on 17-jul-98
   --
--            12/8/00   vravikan    From the Start         Add 2806 and 2808
--	      11/28/02  Madhuri     		   	   End Dated Edit on 31-Jul-2001
if p_effective_date <= to_date('2001/07/31','yyyy/mm/dd') then
   if  p_occ_code in ('2619','2806','2808','2843')
     and
       substr(p_agency_sub, 1, 2) <> 'DN'
     then
       hr_utility.set_message(8301, 'GHR_37216_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
end if;

/* Commented as per December 2000 cpdf changes -- vravikan
--  390.41.2
   --
   -- new edit as per update 7 on 17-jul-98
   --
   if  p_occ_code in ('2806', '2808')
     and
       substr(p_agency_sub, 1, 2) not in ('DN', 'IN07')
     then
       hr_utility.set_message(8301, 'GHR_37880_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

*/

end chk_occupation;

/* Name:
--  Pay Basis
*/

procedure chk_pay_basis
  (p_to_pay_plan            in    varchar2
  ,p_pay_basis              in    varchar2
  ,p_basic_pay              in    varchar2
  ,p_agency_subelement      in    varchar2   -- non SF52 item
  ,p_occ_code               in    varchar2 --Bug# 5745356
  ,p_effective_date         in    date
  ,p_pay_rate_determinant_code in varchar2
   ) is
    l_basic_pay      number;
    l_exists         varchar2(1);
-- cursor added by vravikan for converting basic pay for pay plans havi
--ng equivalent pay plan as 'FW'
-- Bug# 963123
cursor c_fw_pay_plans is
       SELECT 'X'
         FROM ghr_pay_plans
        WHERE equivalent_pay_plan = 'FW'
        AND   pay_plan = p_to_pay_plan;


begin
--  410.02.3
  --            17-Aug-00   vravikan   From the Start          Add one more condition
  --                                                           PRD is other than A,B,E,F,M,U or V
  --   Dec 2001 Patch       vravikan   01-Jul-01          Delete entry for pay plan 'TP'
  --  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete PRD M effective date from 01-May-2005
 if p_effective_date >= to_date('2005/05/01','yyyy/mm/dd') then
	if p_pay_rate_determinant_code not in ('A','B','E','F','U','V')  then
		  if (p_to_pay_plan = 'AL' and p_pay_basis <> 'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'CA' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'ES' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'EX' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'GG' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'GH' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'GS' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'GM' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'KA' and p_pay_basis not in ('PA','PH') and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'SL' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (substr(p_to_pay_plan,1,1) = 'X' and p_pay_basis <> 'PH' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'ZZ' and p_pay_basis <>'WC' and p_pay_basis is not null )
		  then
			   hr_utility.set_message(8301, 'GHR_37909_ALL_PROCEDURE_FAIL');
			   hr_utility.set_message_token('PRD_LIST','A, B, E, F, U, or V');
			   hr_utility.raise_error;
		   end if;
	end if;
elsif p_effective_date >= to_date('2001/07/01','yyyy/mm/dd') then
	if p_pay_rate_determinant_code not in ('A','B','E','F','M','U','V')  then
		  if (p_to_pay_plan = 'AL' and p_pay_basis <> 'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'CA' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'ES' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'EX' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'GG' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'GH' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'GS' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'GM' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'KA' and p_pay_basis not in ('PA','PH') and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'SL' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
			 (substr(p_to_pay_plan,1,1) = 'X' and p_pay_basis <> 'PH' and p_pay_basis is not null ) or
			 (p_to_pay_plan = 'ZZ' and p_pay_basis <>'WC' and p_pay_basis is not null )
		  then
			   hr_utility.set_message(8301, 'GHR_37909_ALL_PROCEDURE_FAIL');
			   hr_utility.set_message_token('PRD_LIST','A, B, E, F, M, U, or V');
			   hr_utility.raise_error;
		   end if;
	end if;
else
	if p_pay_rate_determinant_code not in ('A','B','E','F','M','U','V')  then
	  if (p_to_pay_plan = 'AL' and p_pay_basis <> 'PA' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'CA' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'ES' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'EX' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'GG' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'GH' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'GS' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'GM' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'KA' and p_pay_basis not in ('PA','PH') and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'SL' and p_pay_basis <>'PA' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'TP' and p_pay_basis not in ('FB','PD','SY') and p_pay_basis is not null ) or
		 (substr(p_to_pay_plan,1,1) = 'X' and p_pay_basis <> 'PH' and p_pay_basis is not null ) or
		 (p_to_pay_plan = 'ZZ' and p_pay_basis <>'WC' and p_pay_basis is not null )
	  then
		   hr_utility.set_message(8301, 'GHR_37217_ALL_PROCEDURE_FAIL');
		   hr_utility.raise_error;
	   end if;
	end if;
end if;


/*410.10.3  If pay basis is PD,
          And agency/subelement is CU, FD, FL, FY, TRAJ, or TR35,
          Then basic pay may not exceed 1000.

          Default:  Insert asterisks in pay basis and basic pay.*/

-- UPDATE_DATE	UPDATED_BY	EFFECTIVE_DATE		COMMENTS
-----------------------------------------------------------------------------
-- 18-oct-04    Madhuri         from start of edit	Terminating the edit.
--
/* if   p_pay_basis ='PD' and
      (
	substr(p_agency_subelement,1,2) in ('CU','FD','FL','FY') or
      p_agency_subelement in ('TRAJ','TR35')
       ) and
      to_number(p_basic_pay) >max_per_diem
	then
       hr_utility.set_message(8301, 'GHR_37219_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;*/

/*410.07.3  If pay basis is PA, PH, PM, BW, or WC,
          Then basic pay must not be greater than the maximum
          shown in Table 18.

          Default:  Insert asterisks in pay basis and basic pay.
          Basis for Edit:  CPDF processing requirement*/

-- UPDATE DATE     UPDATE BY	BUG NO		COMMENTS
-------------------------------------------------------------------------------------------------------------
-- 18-Oct-04	   Madhuri			Modifying the existing edit as under from 11-JAN-2004.
--						If pay basis is BW, PA, PD, PH, or WC,
--						Then basic pay must be within the range for the pay basis shown in Table 56.
--						Splitting the error message for if and else part also.
-- 19-NOV-04       Madhuri                      Not splitting message. new message 38918 is being used now.
--- Modified for bug 4089960
--- 22-Apr-2005    Madhuri                      Modified the edit per Bug # 4307246, as under:
---                                             If Pay Basis is BW, PA, PD, PH, or WC AND Pay Plan is NOT AD,
---                                             then Basic Pay must be within the range for the Pay Basis shown on Table 56.
--  UPD 50(Bug 5745356) Raju		01-Oct-2006	 Occupation code is added
--  05-Aug-07         Raju        5132113        Added pay plans GP, GR to edits
--- ----------------------------------------------------------------------------------------------------------
IF ( p_effective_date < to_date('2004/01/11','yyyy/mm/dd') ) then
if p_pay_basis in ('PA', 'PH', 'PM', 'BW', 'WC') then
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 18',
                                                 p_pay_basis,
                                                 'Maximum Basic Pay',
                                                 p_effective_date);
   if max_basic_pay IS NOT NULL then
      --
      -- this code is added for bug 657206 as the basic pay is multiplied by 2087
      -- in the ghrws52l.pkb file for pay_plan of 'W_'
      -- This is a temporary fix
      --
/* Changed the code to reflect all the pay plans having equivalen
t pay plan 'FW' instead of
      above Bug fix -- Ignore the above Comments -- Venkat 08/12/1999 -
- Refer to Bug# 963123 */
      open c_fw_pay_plans;
      fetch c_fw_pay_plans into l_exists;
      if c_fw_pay_plans%found then
        IF GHR_GHRWS52L.g_fw_annualize = 'Y' and p_pay_basis = 'PH'  THEN
          l_Basic_Pay                   := to_char(to_number(p_Basic_Pay)/2087);
        ELSE
          l_basic_pay := to_number(p_basic_pay);
        END IF;
      else
        l_basic_pay := to_number(p_basic_pay);
      end if;
      close c_fw_pay_plans;

      if  l_basic_pay > max_basic_pay
      then
          hr_utility.set_message(8301, 'GHR_37218_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
      end if;
   end if;
end if;

ELSIF ( p_effective_date < to_date('2006/10/01','yyyy/mm/dd') ) then -- after >= 11th Jan 2004
 -- From:If pay basis is PA, PH, PM, BW, or WC, Then basic pay must not be greater than the maximum shown in Table 18.
 -- To: If pay basis is BW, PA, PD, PH, or WC, Then basic pay must be within the range for the pay basis shown in Table 56
--
If ( p_to_pay_plan not in('GP','GR', 'AD') ) THEN

    if p_pay_basis in ('BW','PA', 'PD', 'PH', 'WC') then
        max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 56',
                       p_pay_basis,
                       'Maximum Basic Pay',
                       p_effective_date);

        min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 56',
                       p_pay_basis,
                       'Minimum Basic Pay',
                       p_effective_date);

        if ( max_basic_pay IS NOT NULL and min_basic_pay IS NOT NULL ) then
            --
            -- this code is added for bug 657206 as the basic pay is multiplied by 2087
            -- in the ghrws52l.pkb file for pay_plan of 'W_'
            -- This is a temporary fix
            --
            /* Changed the code to reflect all the pay plans having equivalent
            pay plan 'FW' instead of above Bug fix
            -- Ignore the above Comments -- Venkat 08/12/1999 -
            -- Refer to Bug# 963123 */

            open c_fw_pay_plans;
            fetch c_fw_pay_plans into l_exists;
            if c_fw_pay_plans%found then
                -- Bug 4089960
                IF GHR_GHRWS52L.g_fw_annualize = 'Y' and p_pay_basis = 'PH'  THEN
                    l_Basic_Pay := to_char(to_number(p_Basic_Pay)/2087);
                ELSE
                    l_basic_pay := to_number(p_basic_pay);
                END IF;
            else
                l_basic_pay := to_number(p_basic_pay);
            end if;
            close c_fw_pay_plans;
            -- Bug 4089960

            if  ( l_basic_pay NOT BETWEEN min_basic_pay and max_basic_pay ) then
                hr_utility.set_message(8301, 'GHR_38917_ALL_PROCEDURE_FAIL');
                hr_utility.raise_error;
            end if;
        end if;
    end if;
End if; -- Check for Pay Plan AD
ELSE
    If  p_to_pay_plan not in('GP','GR', 'AD') THEN
    if p_pay_basis in ('BW','PA', 'PD', 'PH', 'WC') and  p_occ_code not in ('0602','0680') then
        max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 56',
                       p_pay_basis, 'Maximum Basic Pay', p_effective_date);

        min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 56',
                       p_pay_basis,'Minimum Basic Pay', p_effective_date);

        if ( max_basic_pay IS NOT NULL and min_basic_pay IS NOT NULL ) then
            open c_fw_pay_plans;
            fetch c_fw_pay_plans into l_exists;
            if c_fw_pay_plans%found then
               IF GHR_GHRWS52L.g_fw_annualize = 'Y' and p_pay_basis = 'PH'  THEN
                    l_Basic_Pay := to_char(to_number(p_Basic_Pay)/2087);
                ELSE
                    l_basic_pay := to_number(p_basic_pay);
                END IF;
            else
                l_basic_pay := to_number(p_basic_pay);
            end if;
            close c_fw_pay_plans;
             if  ( l_basic_pay NOT BETWEEN min_basic_pay and max_basic_pay ) then
                hr_utility.set_message(8301, 'GHR_38554_ALL_PROCEDURE_FAIL');
                hr_utility.raise_error;
            end if;
        end if;
    end if;
    End if; -- Check for Pay Plan AD

END IF;

/*410.12.3  If pay basis is PD,
          And agency/subelement is not CU, FD, FL, FY, TRAJ,
          or TR35,
          Then basic pay may not exceed the maximum on Table 18.

          Default:  Insert asterisks in pay basis and basic pay.*/

-- UPDATE_DATE	UPDATED_BY	EFFECTIVE_DATE		COMMENTS
-----------------------------------------------------------------------------
-- 18-oct-04    Madhuri         from start of edit	Terminating the edit.
--
/*
if p_pay_basis = 'PD' and
   (substr(p_agency_subelement,1,2) in ('CU','FD','FL','FY') or
    p_agency_subelement in ('TRAJ','TR35')) then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 18',
                                                 p_pay_basis,
                                                 'Maximum Basic Pay',
                                                 p_effective_date);
   if max_basic_pay is NOT NULL then
      --
      -- this code is added for bug 657206 as the basic pay is multiplied by 2087
      -- in the ghrws52l.pkb file for pay_plan of 'W_'
      --
      -- Changed the code to reflect all the pay plans having equivalent pay plan 'FW' instead of
      -- above Bug fix -- Ignore the above Comments -- Venkat 08/12/1999 -
      -- Refer to Bug# 963123

      open c_fw_pay_plans;
      fetch c_fw_pay_plans into l_exists;
      if c_fw_pay_plans%found then
         l_basic_pay := to_number(p_basic_pay) / 2087;
      else
         l_basic_pay := to_number(p_basic_pay);
      end if;
      close c_fw_pay_plans;

      if l_basic_pay > max_basic_pay  then
         hr_utility.set_message(8301, 'GHR_37220_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if; */

end chk_pay_basis;

/* Name:
--  Pay Grade
*/

procedure chk_pay_grade
  (p_to_pay_plan               	in varchar2
  ,p_to_grade_or_level         	in varchar2
  ,p_pay_rate_determinant_code 	in varchar2
  ,p_first_action_noa_la_code1 	in varchar2
  ,p_first_action_noa_la_code2 	in varchar2
  ,p_First_NOAC_Lookup_Code       	in varchar2
  ,p_Second_NOAC_Lookup_code        in varchar2
  ,p_effective_date                 in date
)is
begin

--  420.02.3
   -- Update Date        By        Effective Date            Comment
   --   9   04/29/99    vravikan                        Add Pay Plans CG,MG
   -- UPD 56  8309414       Raju     17-Apr-2008            Remove pay plan MG
   if p_effective_date < fnd_date.canonical_to_date('2008/04/17') then
       if  p_to_pay_plan in ( 'CG','MG','WL','XG' )
          and p_to_grade_or_level not in
             ('01', '02', '03', '04', '05', '06', '07', '08',
              '09', '10', '11', '12', '13', '14', '15')
          and p_to_grade_or_level is not null then
          hr_utility.set_message(8301, 'GHR_37221_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','CG,MG,WL, or XG');
          hr_utility.raise_error;
       end if;
   else
        if  p_to_pay_plan in ( 'CG','WL','XG' )
          and p_to_grade_or_level not in
             ('01', '02', '03', '04', '05', '06', '07', '08',
              '09', '10', '11', '12', '13', '14', '15')
          and p_to_grade_or_level is not null then
          hr_utility.set_message(8301, 'GHR_37221_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','CG,WL, or XG');
          hr_utility.raise_error;
       end if;
   end if;
--  420.04.3
   if   (p_to_pay_plan = 'WS' or p_to_pay_plan ='XH')
         and
         p_to_grade_or_level not in
         ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
          '11', '12', '13', '14', '15', '16', '17', '18', '19')
      and
        p_to_grade_or_level is not null
      then
      hr_utility.set_message(8301, 'GHR_37222_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.07.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if  (p_to_pay_plan = 'FA' and p_pay_rate_determinant_code <> 'S')
        and
        p_to_grade_or_level not in ('CA', 'CM', 'MC', 'NC', 'OC',
                                    '01', '02', '03', '04', '13', '14')
      and
        p_to_grade_or_level is not null
      then
      hr_utility.set_message(8301, 'GHR_37223_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
--  420.10.3
   -- removed pay plan 'CY'
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if  p_to_pay_plan ='CE'  and
        p_to_grade_or_level not in ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
                                    '11', '12', '13', '14', '15', '16', '17')
      and
        p_to_grade_or_level is not null
      then
      hr_utility.set_message(8301, 'GHR_37224_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
--  420.11.3
   -- added for the april release as per update 6 manual
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if  p_to_pay_plan ='CY'  and
        p_to_grade_or_level not in ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12',
                                    '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24')
      and
        p_to_grade_or_level is not null
      then
      hr_utility.set_message(8301, 'GHR_37882_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

--  420.13.3
   if p_to_pay_plan = 'GM' and
      p_to_grade_or_level not in ( '13', '14', '15')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37225_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.16.3
   if p_to_pay_plan = 'GS' and
      p_to_grade_or_level not in ('01', '02', '03', '04', '05', '06', '07', '08',
                                  '09', '10', '11', '12', '13', '14', '15')
      and
        p_to_grade_or_level is not null
   then
      hr_utility.set_message(8301, 'GHR_37226_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.17.3
   --
   -- If pay plan is NH or NJ, then grade must be 01 through 04 or asterisks
   --
   if p_effective_date >= fnd_date.canonical_to_date('1998/03/01') then
      if p_to_pay_plan in ('NH', 'NJ') and
         p_to_grade_or_level not in ('01', '02', '03', '04')  and
         p_to_grade_or_level is not null then
         hr_utility.set_message(8301, 'GHR_37877_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;

--  420.18.3
   --
   -- If pay plan is NK, then grade must be 01 through 03 or asterisks
   --
   if p_effective_date >= fnd_date.canonical_to_date('1998/03/01') then
      if p_to_pay_plan = 'NK' and
         p_to_grade_or_level not in ('01', '02', '03')  and
         p_to_grade_or_level is not null then
         hr_utility.set_message(8301, 'GHR_37878_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;

--  420.19.3
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   01/10/98                   New Edit
   -- If pay plan is FV, then grade must be 'AA' through 'MM' or asterisks
   -- 13-Jun-06			Raju		01-Jan-03				Terminate the edit
   --
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_effective_date >= fnd_date.canonical_to_date('1998/10/01') and
		p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
      if p_to_pay_plan = 'FV' and
         p_to_grade_or_level not in ('AA','BB','CC','DD','EE','FF','GG','HH','II',
                                      'JJ','KK','LL','MM')  and
         p_to_grade_or_level is not null then
         hr_utility.set_message(8301, 'GHR_37030_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if;
--  420.21.1
   --
   -- Update Date        By        Effective Date            Comment
   --   8   04/01/99    vravikan   01/10/98                   New Edit
   -- If pay plan is JA, then grade must be 01 through 04 or asterisks
   --
   --  UPD 41(Bug 4567571) Raju		   08-Nov-2005	  Terminate from 01-Jul-2004
if p_effective_date < to_date('2004/07/01','yyyy/mm/dd') then
   if p_effective_date >= fnd_date.canonical_to_date('1998/10/01') then
      if p_to_pay_plan = 'JA' and
         p_to_grade_or_level not in ('01', '02', '03','04')  and
         p_to_grade_or_level is not null then
         hr_utility.set_message(8301, 'GHR_37056_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if;

--  420.20.3
   --
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   01/10/98                   New Edit
   -- If pay plan is EV, then grade must be 01 through 03 or asterisks
   --
   if p_effective_date >= fnd_date.canonical_to_date('1998/10/01') then
      if p_to_pay_plan = 'EV' and
         p_to_grade_or_level not in ('01', '02', '03')  and
         p_to_grade_or_level is not null then
         hr_utility.set_message(8301, 'GHR_37032_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;

--  420.22.3
-- Update Date        By        Effective Date            Comment
-- 13-Jun-06		  Raju		01-Jan-03				Terminate the edit
 IF p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
	   if p_to_pay_plan = 'VM' and
		  p_to_grade_or_level not in ('11', '12', '13', '14', '15', '96', '97') and
		  p_to_grade_or_level is not null then
		  hr_utility.set_message(8301, 'GHR_37227_ALL_PROCEDURE_FAIL');
		  hr_utility.raise_error;
	   end if;
 END IF;
--  420.23.3
   -- Update/Change Date        By        Effective Date            Comment
   --   9/2        08/09/99    vravikan   01-Mar-1999                New Edit
   -- If pay plan is EZ, then grade must be 01 through 08.
   --
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_effective_date >= fnd_date.canonical_to_date('19'||'99/03/01') then
     if p_to_pay_plan = 'EZ' and
       p_to_grade_or_level not in ('01','02','03','04','05','06','07','08')
       and
         p_to_grade_or_level is not null
     then
       hr_utility.set_message(8301, 'GHR_37059_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   end if;
end if;

--  420.25.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'VN' and
      p_to_grade_or_level not in ('01', '02', '03', '04', '05', '06', '08',
                                  '09', '11', '12', '13', '14', '15')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37228_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
--  420.28.3
   if p_to_pay_plan = 'VP' and
      p_to_grade_or_level not in ('11', '12', '13', '14', '15')
      and
        p_to_grade_or_level is not null
      then
      hr_utility.set_message(8301, 'GHR_37229_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.31.3
   if (p_to_pay_plan = 'WG' or p_to_pay_plan =  'XF') and
       p_to_grade_or_level not in
         ('01', '02', '03', '04', '05', '06', '07', '08',
          '09', '10', '11', '12', '13', '14', '15')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37230_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.34.3
   if p_to_pay_plan = 'EX' and
      p_to_grade_or_level not in ('01', '02', '03', '04', '05')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37231_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
--  420.37.3
   if p_to_pay_plan = 'OC' and
                p_to_grade_or_level  not in
                ('01', '02', '03', '04', '05', '06', '07',
                 '08', '09', '10', '11', '12', '13', '14',
                 '15', '16', '17', '18', '19', '20', '21',
                 '22', '23', '24', '25')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37232_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
*/

--  420.40.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'DR'        and
      p_to_grade_or_level not in ('01', '02', '03', '04') and
      p_to_grade_or_level is not null
      then
      hr_utility.set_message(8301, 'GHR_37271_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

--  420.41.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_to_pay_plan = 'ND' or  p_to_pay_plan = 'NT' )
      and
             p_to_grade_or_level not in ('01', '02', '03', '04',
                                          '05', '06')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37269_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
--  420.42.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'NG'
      and
             p_to_grade_or_level not in ('01', '02', '03', '04',
                                          '05')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37270_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

--  420.44.3
   if p_to_pay_plan = 'FO' and
             p_to_grade_or_level not in ('01', '02', '03', '04',
                                          '05', '06', '07', '08')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37233_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.45.3
   if p_to_pay_plan = 'FP' and
                        p_to_grade_or_level not in ('01', '02', '03', '04', '05',
                                                    '06', '07', '08', '09', 'AA',
                                                    'BB', 'CC', 'DD', 'EE')
      and
        p_to_grade_or_level is not null
      then
      hr_utility.set_message(8301, 'GHR_37234_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.47.3
   if p_to_pay_plan = 'FE' and
             p_to_grade_or_level not in ('CA', 'CM', 'MC', 'OC',
                                               '01', '02', '03')
      and
        p_to_grade_or_level is not null
   then
      hr_utility.set_message(8301, 'GHR_37235_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.50.3
   if p_to_pay_plan = 'AF' and
            p_to_grade_or_level not in ('AA', 'BB', 'CC', 'DD', 'EE')
      and
        p_to_grade_or_level is not null
   then
      hr_utility.set_message(8301, 'GHR_37236_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 420.51.3
  if p_to_pay_plan = 'FM' and
             p_to_grade_or_level not in ('13', '14','15')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37237_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
  end if;

-- 420.52.3
   if p_to_pay_plan = 'FG' and
           p_to_grade_or_level not in ('01', '02', '03', '04', '05', '06',
				'07', '08', '09', '10','11', '12', '13', '14', '15')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37238_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.53.3
   if p_to_pay_plan = 'FC' and
             p_to_grade_or_level not in ('02', '03', '04', '05', '06', '07', '08',
                                         '09', '10', '11', '12', '13', '14')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37239_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.55.3
   if (p_to_pay_plan = 'AL' or p_to_pay_plan =  'CA') and
            p_to_grade_or_level not in ('01', '02', '03')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37240_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.59.2
   if (
	 p_first_action_noa_la_code1 = 'J8M'
	 or
         p_first_action_noa_la_code2 = 'J8M'
       )and
            p_to_pay_plan in ('GG', 'GS') and
        p_First_NOAC_Lookup_Code  in ('170','570')
       and
                p_to_grade_or_level not in ('01', '02', '03', '04', '05', '06', '07',
                                                    '08', '09', '10', '11')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37241_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.60.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_to_pay_plan = 'SL'  or p_to_pay_plan =  'XE') and
       p_to_grade_or_level <>'00'
      and
        p_to_grade_or_level is not null
      then
      hr_utility.set_message(8301, 'GHR_37242_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

--  420.65.3
   if p_to_pay_plan= 'GG' and
             not (p_to_grade_or_level in
                  ('01', '02', '03', '04', '05', '06', '07', '08',
                   '09', '10', '11', '12', '13', '14', '15', 'SL') or
                  p_to_grade_or_level is null)
	then
      hr_utility.set_message(8301, 'GHR_37243_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.70.3
   if p_to_pay_plan = 'GH' and
             not (p_to_grade_or_level in ('13', '14', '15') or
                 p_to_grade_or_level is null)
	then
      hr_utility.set_message(8301, 'GHR_37244_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  420.73.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'NY' and
      p_to_grade_or_level not in ('01', '02', '03', '04')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37245_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

 --420.74.3
 -- Update/Change Date        By        Effective Date            Comment
 --   9/5        08/12/99    vravikan   01-Apr-1999               New Edit
 /*If pay plan is NC,
 Then grade must be 01 through 03.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
If p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
   if p_to_pay_plan = 'NC' and
      p_to_grade_or_level not in ('01', '02', '03')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37067_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
end if;

--420.75.3
 -- Update/Change Date        By        Effective Date            Comment
 --   9/5        08/12/99    vravikan   01-Apr-1999               New Edit
 --  18/6        10/16/02    vnarasim   01-Apr-1999               Added grade 05
 /*If pay plan is NO,
 Then grade must be 01 through 04 or asterisks.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    If p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
       if p_to_pay_plan = 'NO' and
          p_to_grade_or_level not in ('01', '02', '03','04','05')
          and
            p_to_grade_or_level is not null
        then
          hr_utility.set_message(8301, 'GHR_37068_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

--420.76.3
 -- Update/Change Date        By        Effective Date            Comment
 --   9/5        08/12/99    vravikan   01-Apr-1999               New Edit
 /*If pay plan is NP or NR, Then grade must be 01 through 05 or asterisks*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    If p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
       if p_to_pay_plan in ('NP','NR') and
          p_to_grade_or_level not in ('01', '02', '03','04','05')
          and
            p_to_grade_or_level is not null
        then
          hr_utility.set_message(8301, 'GHR_37069_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

--420.77.3
 -- Update/Change Date		By			Effective Date		Comment
 -- 18-Aug-2000				vravikan	01-May-2000			New Edit
 -- 13-Jun-06				Raju		01-Jan-03			Terminate the edit
 /*If pay plan is VE , Then grade must be 01 ,02 or asterisks*/
If p_effective_date >= to_date('2000/05/01', 'yyyy/mm/dd') and
	p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
   if p_to_pay_plan in ('VE') and
      p_to_grade_or_level not in ('01', '02')
      and
        p_to_grade_or_level is not null
	then
      hr_utility.set_message(8301, 'GHR_37416_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

--420.78.3
 -- Update/Change Date        By        Effective Date            Comment
 --              18-Aug-00   vravikan   01-Jun-2000               New Edit
 /*If pay plan is NB, Then grade must be 01 through 09 or asterisks*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    If p_effective_date >= to_date('1999/06/01', 'yyyy/mm/dd') then
       if p_to_pay_plan in ('NB') and
          p_to_grade_or_level not in ('01', '02','03','04','05','06','07','08','09')
          and
            p_to_grade_or_level is not null
        then
          hr_utility.set_message(8301, 'GHR_37417_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;
-- Begin Bug# 5073313
--420.80.3
 -- Update/Change Date        By        Effective Date            Comment
 --  Upd 46  13-Jun-06        Raju      01-Jan-2006               New Edit
If p_effective_date >= to_date('2006/01/01', 'yyyy/mm/dd') then
    if  p_to_pay_plan in ('GL') and
        p_to_grade_or_level not in ('03','04','05','06','07','08','09','10') and
		p_to_grade_or_level is not null
    then
        hr_utility.set_message(8301, 'GHR_37426_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
end if;
-- End Bug# 5073313
--Begin Bug# 5745356
--440.00.3
    If p_effective_date >= to_date('2006/10/01', 'yyyy/mm/dd') then
        if  p_to_pay_plan in ('GL') and
            p_to_grade_or_level > '10' and
            p_to_grade_or_level is not null then
            hr_utility.set_message(8301, 'GHR_37584_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    end if;
--End Bug# 5745356

end chk_pay_grade;


/* Name:
     Pay Plan
*/

procedure chk_pay_plan
  (p_to_pay_plan               in    varchar2
  ,p_agency_subelement         in    varchar2       -- non SF52 item
  ,p_pers_office_identifier    in    varchar2       -- non SF52 item
  ,p_to_grade_or_level         in    varchar2
  ,p_first_action_noa_la_code1 in    varchar2
  ,p_first_action_noa_la_code2 in    varchar2
  ,p_Cur_Appt_Auth_1           in varchar2  -- non SF52 item
  ,p_Cur_Appt_Auth_2           in varchar2  -- non SF52 item
  ,p_first_NOAC_Lookup_Code    in    varchar2
  ,p_Pay_Rate_Determinant_Code in    varchar2
  ,p_Effective_Date            in    date
  ,p_prior_pay_plan            in    varchar2       -- non SF52 item
  ,p_prior_grade               in    varchar2       -- non SF52  item
  ,p_Agency                    in    varchar2       -- non SF52 item
  ,p_Supervisory_status_code   in    varchar2
  ) is
l_Effective_Date Date;
begin

--  440.02.3
  /* Enclosed the edit with effctive dates due to the following changes on 17-jul-1998.
     1)Added : if pay plan is NH,NJ or NK, then agency/subelement must be
       AF,AR,DD or NV
     2)Modified : if pay plan is ZA,ZP,ZS or ZT then agency/subelement must be CM57 to CM
  */
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   01/10/98                  Add the following to edit
   --                                                        If Pay plan is AT,EV, or FV then
   --                                                        Agency/Subelement Code must be TD03
   --   9   05/05/99    vravikan                             If Pay plan is CG or EO,
   --                                                        Then agency/subelement must be FD--
   --                                                        If Pay plan in MG,MS, or MX then
   --                                                        agency/subelement must be HUYY

   --  9/4  08/10/99    vravikan  01-Mar-99                  If Pay plan is EZ, then agency/subelement
   --                                                        must be SE
   --  9/5  08/12/99    vravikan  01-Apr-99                  If pay plan is NP or NR,
  --                                             Then grade must be 01 through 05 or asterisks
  --   10/5 08/13/99    vravikan  01-Apr-99                  If pay plan is TW, Then
  --                                                          Agency/Subelement Code must be TRAI
  --   10/5 08/31/99    vravikan  01-Sep-99                  If pay plan is TW, Then
  --                                                          Agency/Subelement Code must be TRAD
  --   10/5 08/31/99    vravikan  01-Oct-99                  If pay plan is PD, Then
  --                                                          Agency/Subelement Code must be TRAC,TRAF, or TR40
  --  11/6  12/14/99    vravikan  From the start             If pay plan is DA,DG, DP,DS
  --                                                          , or DT then
  --                                                          Agency/Subelement Code must be NV
  --        17-Aug-00   vravikan  From the start             If pay plan is VE,
  --                                                          Then Agency/Subelement Code must be VA
  --                                                         If pay plan is NB
  --                                                          Then Agency/Subelement must be TRAJ
  --                                                         Delete OC vs TRAJ combination
  --                                                         If pay plan is IR then
  --                                                           Agency/Subelement must be TR93
  --                                                         If pay plan is CB,CF,CH,CI,CJ or CL then
  --                                                           Agency/Subelement code must be FD
  --   18/3 16-Oct-02   vnarasim  From the Start             If Pay Plan is RE or RP then
  --						               Agency/Subelement code must be TR93.
  --        28-Nov-02   Madhuri   From the Start	     If Pay Plan is TG then
  --              						Agency/Subelement must be TR35.

  -- 20/2 02/20/03	Madhuri  from the start   	     If pay plan is CE
  -- 	                                        	 	Then agency/subelement must be IN06(Modified from IN -> IN06)
  --						     	     If pay plan is CY
  --   								Then agency/subelement must be IN06(Modified from IN -> IN06)
  -- 						   	     If pay plan is LE
  --								Then agency/subelement must be TRAC(Modified from TR -> TRAC)
  -- 						   	     If pay plan is AF
  --								Then agency/subelement must be AG10, AM, CM55, IB, PU, or ST.
  -- 						   	     If pay plan is AG
  --								Then agency/subelement must be FD.
  -- 						   	     If pay plan is CU
  --								Then agency/subelement must be CU.
  -- 						     	     If pay plan is DL
  --								Then agency/subelement must be VA.
  -- 						      	     If pay plan is DN
  --							 	Then agency/subelement must be BF.
  -- 						   	     If pay plan is EN
  --	 							Then agency/subelement must be DN.
  -- 						   	     If pay plan is FE
  --								Then agency/subelement must be AG10, AM, CM55, IB, PU, or ST.
  -- 						   	     If pay plan is FO
  --								Then agency/subelement must be AG10, AM, CM55, IB, PU, or ST.
  -- 						   	     If pay plan is FP
  --								Then agency/subelement must be AG10, AM, CM55, IB, PU, or ST.
  -- 						   	     If pay plan is IE
  --								Then agency/subelement must be AF, AR, DD, or NV.
  -- 						  	     If pay plan is IP
  --								Then agency/subelement must be AF, AR, DD, or NV.
  -- 						   	     If pay plan is PG
  --								Then agency/subelement must be LP.
  -- 						   	     If pay plan is RS
  --								Then agency/subelement must be HE.
  -- 						    	     If pay plan is SS
  --								Then agency/subelement must be CU.
  -- 							     If pay plan is TM
  --								Then agency/subelement must be FY.
  -- 						   	     If pay plan is VG
  --								Then agency/subelement must be FK or FL.
  -- 						   	     If pay plan is VH
  --								Then agency/subelement must be FK or FL.
  -- 							     If pay plan is XF
  --								Then agency/subelement must be AR.
  -- 						   	     If pay plan is XG
  --								Then agency/subelement must be AR.
  -- 						  	     If pay plan is XH
  --								Then agency/subelement must be AR.
  -- 21/1, 02/20/03 	Madhuri  from the start   	     If pay plan is PD
  -- 21/2							Then agency/subelement must be DJ15,HSAD or HSBD.
  -- 21/2 02/20/03      Madhuri  from the start	   	     If pay plan is EJ
  --								Then agency/subelement must be HS.
  --						   	     If pay plan is FE
  --								Then agency/subelement must be HS.
  --						  	     If pay plan is FP
  --								Then agency/subelement must be HS.
  --						   	     If pay plan is LE
  --								Then agency/subelement must be HSAD.
  -- 20/2 02/27/03	Madhuri				     Deleting the following requirement from the Edit
  --							     If the Pay Plan is TW,
  --							         Then agency/subelement must be TRAI or TRAD.
  --      03/19/03      Narasimha Rao                        If the Pay Plan is SV or SW then
  --                                                         agency/subelement must be in TD19 or HSBC.
  --      05/07/03      Narasimha Rao                        There are more than one edit checks for pay
  --                                                         plans DR,EJ,LE,PD,FP,FE. Combined these edit
  --                                                         checks such that each pay plan will have only
  --                                                         one edit check.
  --      30/10/03      Ashley				     If pay plan is CM,EM
  --								Then agency/subelement must be FDxx.
  --                                                         If pay plan is CT
  --								Then agency/subelement must be CTxx.
  --                                                         If pay plan is RA
  --								Then agency/subelement must be AGxx.
  --                                                         If pay plan is FO
  --								Then agency/subelement must be AG34,HSxx.
  --                                                         Under pay plan PD, delete agency/subelement TRAF,TRAC
  --                                                         If pay plan is FE,FP
  --								Then agency/subelement must be AG34.
  --                                                         If pay plan is KB,KE,KI,KJ,KM,KN,KO,KP,KT,KU,KV,KW,KX,KY,PJ,PQ,PU,or PZ,
  --								Then agency/subelement must be LPxx.
  --                                                         For pay plan LE, deleted agency/subelement TRAC.
  --							     For pay plan SV, deleted agency/subelement TD19.
  --							     For pay plan SW, deleted agency/subelement TD19.
  --     19/05/04      Madhuri				     If Pay Plan is YA, YB, YC, YD, YE, YF, YG, YH, YI, YJ, YK,
  --                                                         YL, YM, YN, YO, YP, YQ, YR, YS, YT, YU, YV, YW, YX, YY, or YZ,
  --							     Then Agency/Sub Element must start with DD. (U.32)
  --							     (That means the first two characters of Agency/Sub-element code must be DD)

  --	14/09/2004     Madhuri				     i) Delete entries for Pay Plan:DL, JA, JB, JC, JD, and JE
  --							     ii) If pay plan is XI, XJ, or XK, Then agency/sub-element must be TRAI.
  -- 	18/10/2004     Madhuri                               i) If pay plan is NZ, Then agency/subelement must be SM03.
  --    08/11/2005(UPD 42)Raju 		                     If pay plan is GE or GI,
  --								Then agency/subelement must be LP.( Bug 4567571)
  --    07/03/2006(upd 39)Narasimha Rao                      IF pay plan is OF, Then agency/sub-element must be HUFH
  ----upd47  26-Jun-06	Raju	   From 01-May-2006		    For pay plan codes AF, FA, FE, FO, and FP,
  --														Removes agency / sub element code ST
  --							If pay plan is HE, HH, HL, HS, HT, or HW, then agency/sub element must be HS
  --    15/11/2006     amrchakr    For the payplan YG, the agency/sub elemnt must be AF, AR, DD, NV(Bug 5662041)
 --  UPD 50(Bug 5745356) Raju		From 01-Oct-2006	 added If pay plan is HA, HB, HC, HD, HF,HG,HI,HJ,HK,
 --                                 HM,HN,HO,HP,HQ,HR,HV,HX,HY, or HZ then agency/sub element must be HS
 --  UPD 55(Bug 6469079) Raju		From 01-May-2007	 added  pay plan 'OE' to subelement HUFH
 -- UPD 56  8309414       Raju       From 1-apr-08           Remove MG
 ----------------------------------------------------------------------------------------------------------------
  if   (p_to_pay_plan = 'AJ' and substr(p_agency_subelement,1,2) <> 'NU' )  then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','AJ');
    hr_utility.set_message_token('AGENCY_CODE','NU');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'CE' and p_agency_subelement <> 'IN06' )  then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','CE');
    hr_utility.set_message_token('AGENCY_CODE','IN06');
    hr_utility.raise_error;
  elsif     (  p_to_pay_plan in ('VE') and
               substr(p_agency_subelement,1,2) <> 'VA'                                  ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in VE');
    hr_utility.set_message_token('AGENCY_CODE','VA');
    hr_utility.raise_error;
  elsif     (  p_to_pay_plan = 'NB' and p_agency_subelement <> 'TRAJ'           ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','NB');
    hr_utility.set_message_token('AGENCY_CODE','TRAJ');
    hr_utility.raise_error;
  elsif     (  p_to_pay_plan = 'IR' and p_agency_subelement <> 'TR93'           ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','IR');
    hr_utility.set_message_token('AGENCY_CODE','TR93');
    hr_utility.raise_error;
  elsif     (  p_to_pay_plan in ('CB','CF','CH','CI','CJ','CL','CM') and
               substr(p_agency_subelement,1,2) <> 'FD'                                  ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in CB,CF,CH,CI,CJ,CL or CM');
    hr_utility.set_message_token('AGENCY_CODE','FD');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'CY' and p_agency_subelement <> 'IN06' )  then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','CY');
    hr_utility.set_message_token('AGENCY_CODE','IN06');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('DB','DE','DJ','DK','DQ') and
                 substr(p_agency_subelement,1,2) not in ('AF','AR','NV','DD')     	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in DB,DE,DJ,DK or DQ');
    hr_utility.set_message_token('AGENCY_CODE','in AF,AR,NV or DD');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'DR' and substr(p_agency_subelement,1,2) <> 'AF'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','DR');
    hr_utility.set_message_token('AGENCY_CODE','AF');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('DV','DZ') and
                 substr(p_agency_subelement,1,2) not in ('AF','AR','NV','DD')	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','DV,DZ');
    hr_utility.set_message_token('AGENCY_CODE','AF,AR,NV or DD');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('EJ') and  substr(p_agency_subelement,1,2) NOT IN('HS','DN') )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','EJ');
    hr_utility.set_message_token('AGENCY_CODE','DN or HS');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('EK') and
                 substr(p_agency_subelement,1,2) <> 'DN'                           ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','EK');
    hr_utility.set_message_token('AGENCY_CODE','DN');
    hr_utility.raise_error;
  elsif  p_effective_date < fnd_date.canonical_to_date('2006/05/01') and
		(	p_to_pay_plan = 'FA' and
                 substr(p_agency_subelement,1,2) not in ('AM','ST')  	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FA');
    hr_utility.set_message_token('AGENCY_CODE','AM,ST');
    hr_utility.raise_error;
  elsif  p_effective_date >= fnd_date.canonical_to_date('2006/05/01') and
		(	p_to_pay_plan = 'FA' and
                 substr(p_agency_subelement,1,2) not in ('AM')  	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FA');
    hr_utility.set_message_token('AGENCY_CODE','AM');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'FB' and p_agency_subelement <> 'TD03'            ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FB');
    hr_utility.set_message_token('AGENCY_CODE','TD03');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'FD' and
                 substr(p_agency_subelement,1,2) not in ('AF','AR','NV','DD')	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FD');
    hr_utility.set_message_token('AGENCY_CODE','AF,AR,NV or DD');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('FF','FG','FJ','FL','FM') and
                 p_agency_subelement <> 'TD03'                                     ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FF,FG,FJ,FL or FM');
    hr_utility.set_message_token('AGENCY_CODE','TD03');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('FN','FS','FT','FW','FX')
                 and p_agency_subelement <> 'TD03'                             	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FN,FS,FT,FW or FX');
    hr_utility.set_message_token('AGENCY_CODE','TD03');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'GN' and p_agency_subelement <> 'HE38'      	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','GN');
    hr_utility.set_message_token('AGENCY_CODE','HE38');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'IJ' and substr(p_agency_subelement,1,2) <> 'DJ'  ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','IJ');
    hr_utility.set_message_token('AGENCY_CODE','DJ');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'KA' and substr(p_agency_subelement,1,2) <> 'LP' 	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','KA');
    hr_utility.set_message_token('AGENCY_CODE','LP');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in ('KG','KL','KS') and p_agency_subelement<>'TRAI' ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','KG,KL or KS');
    hr_utility.set_message_token('AGENCY_CODE','TRAI');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'LE' and p_agency_subelement <>'HSAD'   ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','LE');
    hr_utility.set_message_token('AGENCY_CODE','HSAD');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'LG' and substr(p_agency_subelement,1,2) <> 'FD' 	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','LG');
    hr_utility.set_message_token('AGENCY_CODE','FD');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'MA' and substr(p_agency_subelement,1,2) <> 'AG'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','MA');
    hr_utility.set_message_token('AGENCY_CODE','AG');
    hr_utility.raise_error;
  elsif     ( 	p_to_pay_plan in ('ND','NG','NT') and
                 substr(p_agency_subelement,1,2) <> 'NV'                         	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in ND,NG or NT');
    hr_utility.set_message_token('AGENCY_CODE','NV');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('NX','NY') and
                 substr(p_agency_subelement,1,2) <> 'KS'                           ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','NX,NY');
    hr_utility.set_message_token('AGENCY_CODE','KS');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'SN' and substr(p_agency_subelement,1,2) <> 'NU'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','SN');
    hr_utility.set_message_token('AGENCY_CODE','NU');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'SP' and substr(p_agency_subelement,1,2) <> 'IN'  ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','SP');
    hr_utility.set_message_token('AGENCY_CODE','IN');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'TF' and substr(p_agency_subelement,1,2) <> 'FY'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','TF');
    hr_utility.set_message_token('AGENCY_CODE','FY');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'TP' and p_agency_subelement <> 'DD16'		) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','TP');
    hr_utility.set_message_token('AGENCY_CODE','DD16');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'TR' and p_agency_subelement not in ('TRAI','TRAD')) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','TR');
    hr_utility.set_message_token('AGENCY_CODE','TRAI,TRAD');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'TS' and substr(p_agency_subelement,1,2) <> 'FY'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','TS');
    hr_utility.set_message_token('AGENCY_CODE','FY');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('VC','VM','VN','VP') and
                 substr(p_agency_subelement,1,2) <> 'VA'					) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','VC,VM,VN or VP');
    hr_utility.set_message_token('AGENCY_CODE','VA');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'WA' and substr(p_agency_subelement,1,2) <> 'AR'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','WA');
    hr_utility.set_message_token('AGENCY_CODE','AR');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'WE' and substr(p_agency_subelement,1,2) <> 'TR'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','WE');
    hr_utility.set_message_token('AGENCY_CODE','TR');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('WJ','WK','WO','WY') and
      	substr(p_agency_subelement,1,2) <> 'AR'					) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','WJ,WK,WO or WY');
    hr_utility.set_message_token('AGENCY_CODE','AR');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('XA','XB','XC') and
     		substr(p_agency_subelement,1,2) <> 'IN'					) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','XA,XB or XC');
    hr_utility.set_message_token('AGENCY_CODE','IN');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'XE' and p_agency_subelement <> 'IN07'		) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','XE');
    hr_utility.set_message_token('AGENCY_CODE','IN07');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in ('CG','EO','EM') and substr(p_agency_subelement,1,2)  <> 'FD'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in CG,EO or EM');
    hr_utility.set_message_token('AGENCY_CODE','FD');
    hr_utility.raise_error;
  --Begin Bug# 8309414 remove pay plan MG eff 17-apr-08
  elsif p_effective_date < fnd_date.canonical_to_date('2008/04/17') and
    ( p_to_pay_plan in ('MG','MS','MX') and substr(p_agency_subelement,1,2) <> 'HU'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in MG,MS or MX');
    hr_utility.set_message_token('AGENCY_CODE','HU');
    hr_utility.raise_error;
  elsif (	p_to_pay_plan in ('MS','MX') and substr(p_agency_subelement,1,2) <> 'HU'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in MS or MX');
    hr_utility.set_message_token('AGENCY_CODE','HU');
    hr_utility.raise_error;
  --End Bug# 8309414
  elsif     (	p_to_pay_plan in('ZA','ZP','ZS','ZT') and
     		p_agency_subelement <> 'CM'							) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in ZA,ZP,ZS or ZT');
    hr_utility.set_message_token('AGENCY_CODE','CM');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in('DA','DG','DP','DS','DT') and
     		substr(p_agency_subelement,1,2) <> 'NV'					) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in DA,DG,DP,DS or DT');
    hr_utility.set_message_token('AGENCY_CODE','NV');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in ('NH','NJ','NK') and
                 substr(p_agency_subelement,1,2) not in ('AF','AR','DD','NV') and
                     p_effective_date >= fnd_date.canonical_to_date('1998/03/01')	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in NH,NJ or NK');
    hr_utility.set_message_token('AGENCY_CODE','in AF,AR,DD or NV');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in ('AT','EV','FV') and
                     p_effective_date >= fnd_date.canonical_to_date('1998/10/01') and
     		p_agency_subelement <> 'TD03' ) then
    hr_utility.set_location('In pay plan  AT', 12);
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in AT,EV or FV');
    hr_utility.set_message_token('AGENCY_CODE','TD03');
    hr_utility.raise_error;
--
-- Deleting entries for Pay Plans - JA,JB,JC,JD,JE. DATE: 14-SEP-2004 for EOY - I
--
/*  elsif     (	p_to_pay_plan in ( 'JA','JB','JC','JD','JE') and p_agency_subelement <> 'DJ02' )  then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in JA,JB,JC,JD or JE');
    hr_utility.set_message_token('AGENCY_CODE','DJ02');
    hr_utility.raise_error;*/
  elsif     (	p_to_pay_plan in ( 'EZ') and substr(p_agency_subelement,1,2) <> 'SE'  and
                     p_effective_date >= fnd_date.canonical_to_date('19'||'99/03/01')	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','EZ');
    hr_utility.set_message_token('AGENCY_CODE','SE');
    hr_utility.raise_error;
  elsif      (     p_to_pay_plan in ('NC','NO','NP','NR') and substr(p_agency_subelement,1,2) <> 'NV' and
                p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01')  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in NC,NO,NP or NR');
    hr_utility.set_message_token('AGENCY_CODE','NV');
    hr_utility.raise_error;
  elsif  p_to_pay_plan in ('PD')  then
      IF ( p_effective_date >= to_date('1999/10/01','yyyy/mm/dd')
           and p_agency_subelement not in('TR40','DJ15','HSAD','HSBD')
	  )  then
	    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
	    hr_utility.set_message_token('PAY_PLAN','PD');
	    hr_utility.set_message_token('AGENCY_CODE','in TR40,DJ15,HSAD or HSBD');
	    hr_utility.raise_error;
      Elsif( p_effective_date < to_date('1999/10/01','yyyy/mm/dd')
             and p_agency_subelement not in('DJ15','HSAD','HSBD')
	    )  then
	    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PAY_PLAN','PD');
            hr_utility.set_message_token('AGENCY_CODE','in DJ15, HSAD or HSBD');
            hr_utility.raise_error;
      END IF;
  elsif      (    p_to_pay_plan in ('SK','SO') and substr(p_agency_subelement,1,2) <> 'SE')
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in SK or SO');
    hr_utility.set_message_token('AGENCY_CODE','SE');
    hr_utility.raise_error;
  elsif      (    p_to_pay_plan in ('SV','SW') and p_agency_subelement <>'HSBC')
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in SV or SW');
    hr_utility.set_message_token('AGENCY_CODE','in  HSBC');
    hr_utility.raise_error;
  elsif      (    p_to_pay_plan in ('RE','RP') and p_agency_subelement <> 'TR93')
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','in RE or RP');
    hr_utility.set_message_token('AGENCY_CODE','TR93');
    hr_utility.raise_error;
  elsif      (    p_to_pay_plan in ('TG') and p_agency_subelement <> 'TR35')
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','TG');
    hr_utility.set_message_token('AGENCY_CODE','TR35');
    hr_utility.raise_error;
  elsif  p_effective_date < fnd_date.canonical_to_date('2006/05/01') and
			(  p_to_pay_plan in ('AF') and (p_agency_subelement not in ('AG10','CM55')
  			    and substr(p_agency_subelement,1,2) not in ('AM','IB','PU','ST'))  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','AF');
    hr_utility.set_message_token('AGENCY_CODE','AG10,AM,CM55,IB,PU or ST');
    hr_utility.raise_error;

	elsif  p_effective_date >= fnd_date.canonical_to_date('2006/05/01') and
			(  p_to_pay_plan in ('AF') and (p_agency_subelement not in ('AG10','CM55')
  			    and substr(p_agency_subelement,1,2) not in ('AM','IB','PU'))  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','AF');
    hr_utility.set_message_token('AGENCY_CODE','AG10,AM,CM55,IB or PU ');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('AG') and substr(p_agency_subelement,1,2) <> 'FD'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','AG');
    hr_utility.set_message_token('AGENCY_CODE','FD');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('CU') and substr(p_agency_subelement,1,2) <> 'CU'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','CU');
    hr_utility.set_message_token('AGENCY_CODE','CU');
    hr_utility.raise_error;
--
-- Deleting entries for Pay Plans - DL. DATE: 14-SEP-2004 for EOY - I
--
  /*elsif     (    p_to_pay_plan in ('DL') and substr(p_agency_subelement,1,2) <> 'VA'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','DL');
    hr_utility.set_message_token('AGENCY_CODE','VA');
    hr_utility.raise_error;  */
  elsif     (    p_to_pay_plan in ('DN') and substr(p_agency_subelement,1,2) <> 'BF'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','DN');
    hr_utility.set_message_token('AGENCY_CODE','BF');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('EN') and substr(p_agency_subelement,1,2) <> 'DN'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','EN');
    hr_utility.set_message_token('AGENCY_CODE','DN');
    hr_utility.raise_error;
  elsif p_effective_date < fnd_date.canonical_to_date('2006/05/01') and
	(    p_to_pay_plan in ('FE') and (p_agency_subelement not in ('AG10','CM55','AG34')
  					      and substr(p_agency_subelement,1,2) not in ('AM','HS','IB','PU','ST'))  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FE');
    hr_utility.set_message_token('AGENCY_CODE','AG10,AM,CM55,AG34,HS,IB,PU or ST');
    hr_utility.raise_error;
  elsif p_effective_date >= fnd_date.canonical_to_date('2006/05/01') and
	(    p_to_pay_plan in ('FE') and (p_agency_subelement not in ('AG10','CM55','AG34')
  					      and substr(p_agency_subelement,1,2) not in ('AM','HS','IB','PU'))  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FE');
    hr_utility.set_message_token('AGENCY_CODE','AG10,AM,CM55,AG34,HS,IB or PU');
    hr_utility.raise_error;
  elsif  p_effective_date < fnd_date.canonical_to_date('2006/05/01') and
		(    p_to_pay_plan in ('FO') and (p_agency_subelement not in ('AG10','CM55','AG34')
  					      and substr(p_agency_subelement,1,2) not in ('AM','IB','PU','ST','HS'))  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FO');
    hr_utility.set_message_token('AGENCY_CODE','AG10,AM,CM55,AG34,IB,PU,HS or ST');
    hr_utility.raise_error;
 elsif  p_effective_date >= fnd_date.canonical_to_date('2006/05/01') and
		(    p_to_pay_plan in ('FO') and (p_agency_subelement not in ('AG10','CM55','AG34')
  					      and substr(p_agency_subelement,1,2) not in ('AM','IB','PU','HS'))  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FO');
    hr_utility.set_message_token('AGENCY_CODE','AG10,AM,CM55,AG34,IB,PU or HS');
    hr_utility.raise_error;
  elsif  p_effective_date < fnd_date.canonical_to_date('2006/05/01') and
		(    p_to_pay_plan in ('FP') and (p_agency_subelement not in ('AG10','CM55','AG34')
  					      and substr(p_agency_subelement,1,2) not in ('AM','HS','IB','PU','ST'))  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FP');
    hr_utility.set_message_token('AGENCY_CODE','AG10,AM,CM55,AG34,HS,IB,PU or ST');
    hr_utility.raise_error;
  elsif  p_effective_date >= fnd_date.canonical_to_date('2006/05/01') and
		(    p_to_pay_plan in ('FP') and (p_agency_subelement not in ('AG10','CM55','AG34')
  					      and substr(p_agency_subelement,1,2) not in ('AM','HS','IB','PU'))  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','FP');
    hr_utility.set_message_token('AGENCY_CODE','AG10,AM,CM55,AG34,HS,IB or PU');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('IE') and  substr(p_agency_subelement,1,2) not in ('AF','AR','DD','NV')  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','IE');
    hr_utility.set_message_token('AGENCY_CODE','AF,AR,DD or NV');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('IP') and  substr(p_agency_subelement,1,2) not in ('AF','AR','DD','NV')  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','IP');
    hr_utility.set_message_token('AGENCY_CODE','AF,AR,DD or NV');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('PG') and  substr(p_agency_subelement,1,2) <> 'LP'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','PG');
    hr_utility.set_message_token('AGENCY_CODE','LP');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('RS') and  substr(p_agency_subelement,1,2) <> 'HE'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','RS');
    hr_utility.set_message_token('AGENCY_CODE','HE');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('SS') and  substr(p_agency_subelement,1,2) <> 'CU'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','SS');
    hr_utility.set_message_token('AGENCY_CODE','CU');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('TM') and  substr(p_agency_subelement,1,2) <> 'FY'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','TM');
    hr_utility.set_message_token('AGENCY_CODE','FY');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('VG') and  substr(p_agency_subelement,1,2) not in ('FK','FL')   )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','VG');
    hr_utility.set_message_token('AGENCY_CODE','FK or FL');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('VH') and  substr(p_agency_subelement,1,2) not in ('FK','FL')   )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','VH');
    hr_utility.set_message_token('AGENCY_CODE','FK or FL');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('XF') and  substr(p_agency_subelement,1,2) <> 'AR'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','XF');
    hr_utility.set_message_token('AGENCY_CODE','AR');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('XG') and  substr(p_agency_subelement,1,2) <> 'AR'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','XG');
    hr_utility.set_message_token('AGENCY_CODE','AR');
    hr_utility.raise_error;
  elsif     (    p_to_pay_plan in ('XH') and  substr(p_agency_subelement,1,2) <> 'AR'  )
      then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','XH');
    hr_utility.set_message_token('AGENCY_CODE','AR');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'CT' and substr(p_agency_subelement,1,2) <> 'CT') then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','CT');
    hr_utility.set_message_token('AGENCY_CODE','CT');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan = 'RA' and substr(p_agency_subelement,1,2) <> 'AG'	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','RA');
    hr_utility.set_message_token('AGENCY_CODE','AG');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in ('KB','KE','KI','KJ','KM','KN','KO','KP','KT','KU','KV','KW','KX','KY','PJ','PQ','PU','PZ')
    and substr(p_agency_subelement,1,2) <> 'LP' 	) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','KB,KE,KI,KJ,KM,KN,KO,KP,KT,KU,KV,KW,KX,KY,PJ,PQ,PU,or PZ');
    hr_utility.set_message_token('AGENCY_CODE','LP');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in ('YA', 'YB', 'YC', 'YD', 'YE', 'YF', 'YG', 'YH', 'YI', 'YJ', 'YK', 'YL', 'YM', 'YN', 'YO', 'YP', 'YQ', 'YR', 'YS', 'YT', 'YU', 'YV', 'YW', 'YX', 'YY', 'YZ')
    and substr(p_agency_subelement,1,2) not in ('AF','AR','DD','NV') ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN',' YA, YB, YC, YD, YE, YF, YG, YH, YI, YJ, YK,YL, YM, YN, YO, YP, YQ, YR, YS, YT, YU, YV, YW, YX, YY, or YZ ');
    hr_utility.set_message_token('AGENCY_CODE','AF,AR,DD or NV');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in ('XI','XJ','XK') and p_agency_subelement <> 'TRAI' ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','XI, XJ or XK ');
    hr_utility.set_message_token('AGENCY_CODE','TRAI');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in ('NZ') and p_agency_subelement <> 'SM03' ) then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','NZ');
    hr_utility.set_message_token('AGENCY_CODE','SM03');
    hr_utility.raise_error;
  elsif     (	p_to_pay_plan in ('GE','GI') and substr(p_agency_subelement,1,2) <> 'LP') THEN
	hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','GE or GI');
    hr_utility.set_message_token('AGENCY_CODE','LP');
    hr_utility.raise_error;
  elsif   p_effective_date < to_date('2007/05/01','RRRR/MM/DD') AND -- Bug# 6469079
          (	p_to_pay_plan = 'OF' and  p_agency_subelement <> 'HUFH') THEN
	hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','OF');
    hr_utility.set_message_token('AGENCY_CODE','HUFH');
    hr_utility.raise_error;
    --Begin Bug#6469079
   elsif  (	p_to_pay_plan in('OE','OF') and  p_agency_subelement <> 'HUFH') THEN
	hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN','OE or OF');
    hr_utility.set_message_token('AGENCY_CODE','HUFH');
    hr_utility.raise_error;
    --End Bug#6469079
 --Begin Bug# 5073313
  elsif p_effective_date >= fnd_date.canonical_to_date('2006/05/01') and
		( p_to_pay_plan in ('HE','HH','HL','HS','HT','HW') and  substr(p_agency_subelement,1,2) <> 'HS' )
  then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN',p_to_pay_plan);
    hr_utility.set_message_token('AGENCY_CODE','HS');
    hr_utility.raise_error;
 --End bug# 5073313
 --Begin Bug# 5745356
  elsif p_effective_date >= fnd_date.canonical_to_date('2006/10/01') and
		( p_to_pay_plan in ('HA','HB','HC','HD','HF','HG','HI','HJ','HK','HM','HN','HO',',HP','HQ','HR','HV','HX','HY','HZ') and  substr(p_agency_subelement,1,2) <> 'HS' )
  then
    hr_utility.set_message(8301,'GHR_37879_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PAY_PLAN',p_to_pay_plan);
    hr_utility.set_message_token('AGENCY_CODE','HS');
    hr_utility.raise_error;
 --End bug# 5745356
  else
   hr_utility.set_location('No error',14);
end if;

--  440.04.3
   -- added the following personal office identifiers on 9-oct-98
   -- 2267,2336,2562,2614,3231,3322,4252
   -- Update Date        By        Effective Date            Comment
   --   8   04/01/99    vravikan                             Added POI 4221
   -- 11/7  12/14/99    vravikan   31-Aug-1999               End date the Edit
   if p_effective_date < to_date('19'||'99/08/31','yyyy/mm/dd') then
     if  p_to_pay_plan in ('DA','DS','DG','DP','DT')
       and
         (
  	 substr(p_agency_subelement,1,2) <> 'NV'
         or
         p_pers_office_identifier not in ('2256','2267','2336','2415','2431',
                          '2562','2614','2896','3231','3322','4219','4221','4252')
	  )
     then
       hr_utility.set_message(8301, 'GHR_37247_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   end if;
--  420.05.3
  --   11/5     12/14/99    vravikan   01-Aug-1999           Delete the Pay Plan DG
  -- Renumbered from 440.05.3 for the april release
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if  ( p_effective_date >= to_date('19'||'99/08/01','yyyy/mm/dd')  ) then
      if (
        p_to_pay_plan in ('DA','DS','DT')
           and
           p_to_grade_or_level not in ('00','01','02','03')
        )
        or
         (
        p_to_pay_plan = 'DP'
        and
          p_to_grade_or_level not in ('00','01','02','03','04','05')
        )
        or
         (
        p_to_pay_plan in ('ZA','ZP','ZS','ZT')
        and
          p_to_grade_or_level not in ('01','02','03','04','05')
        )
      then
           hr_utility.set_message(8301, 'GHR_37410_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
        end if;
    else
      if (
        p_to_pay_plan in ('DA','DS','DT')
           and
           p_to_grade_or_level not in ('00','01','02','03')
        )
        or
         (
        p_to_pay_plan = 'DG'
        and
        p_pers_office_identifier in('2256','2896')
        and
          p_to_grade_or_level not in ('00','01','02','03','04','05')
        )
        or
         (
        p_to_pay_plan = 'DG'
        and
        p_pers_office_identifier in('2415','2431','4219')
        and
          p_to_grade_or_level not in ('00','01','02','03','04')
        )
        or
         (
        p_to_pay_plan = 'DP'
        and
          p_to_grade_or_level not in ('00','01','02','03','04','05')
        )
        or
         (
        p_to_pay_plan in ('ZA','ZP','ZS','ZT')
        and
          p_to_grade_or_level not in ('01','02','03','04','05')
        )
      then
           hr_utility.set_message(8301, 'GHR_37248_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
        end if;
    end if;
end if;
-- 440.10.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   If (
	 p_first_NOAC_Lookup_Code = '480' or p_first_NOAC_Lookup_Code='762'
	 )
    and
       p_to_pay_plan <>'ES'
    and
	 p_to_pay_plan <>'FE'
    and
	 p_to_pay_plan is not null
   then
       hr_utility.set_message(8301, 'GHR_37249_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
end if;
-- 440.12.2
   -- Update Date        By        Effective Date            Comment
   --   9   05/03/99    vravikan                             Added Pay Plan MS
   --       10/30/03    Ashley                               Deleted Pay Plan EO
  -- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
       hr_utility.set_location('to pay plan is ' || p_to_pay_plan ,10);
       hr_utility.set_location('from pay plan is ' || p_prior_pay_plan ,10);
   If  p_first_NOAC_Lookup_Code = '879'
    and
       p_to_pay_plan not in ('ES','FE','MS','TF','TX')
    and
	 p_to_pay_plan is not null
    and
       p_Pay_Rate_Determinant_Code <> 'S'
   then
       hr_utility.set_message(8301, 'GHR_37250_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
end if;

-- 440.13.2
   -- Update/Change Date        By        Effective Date            Comment
   --   9/1        08/09/99    vravikan   01-Oct-98                  Add Pay Plans CG,EO,ND,NG,NH,NJ,NK, and NT
   --   9/5        08/12/99    vravikan   01-Apr-99                  Add pay plans NC, NO, NP, and NR
  --   11/9     12/14/99    vravikan   01-Nov-1999                   Add Pay Plan PD
   --           17-Aug-00   vravikan      From the Start             Add NB
   -- Dec 01 Patch 12/10/01 vravikan                                 Delete OC
   --           10/30/03     Ashley                                  Added Pay Plans CM and EM
   --upd47  26-Jun-06	Raju	   From 01-Apr-2003		             Terminate the edit
if p_effective_date < fnd_date.canonical_to_date('2003/04/01') then
   if p_effective_date >= to_date('1999/11/01', 'yyyy/mm/dd') then
     If   p_first_NOAC_Lookup_Code = '891' and
        p_to_pay_plan not in ('CG','CM','EM','EO','FM','GH','GM',
			       'NC','ND','NG','NH','NJ','NK','NO','NP','NR','NT',
                   'NB','PD','TM','VH','ZA','ZP','ZS','ZT') and
        substr(p_to_pay_plan,1,1) <>'D' and
	    p_to_pay_plan is not null
      then
       hr_utility.set_message(8301, 'GHR_37412_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   elsif p_effective_date >= to_date('1999/04/01', 'yyyy/mm/dd') then
     If   p_first_NOAC_Lookup_Code = '891' and
            p_to_pay_plan not in ('CG','CM','EM','EO','FM','GH','GM',
			       'NC','ND','NG','NH','NJ','NK','NO','NP','NR','NT',
                   'NB','TM','VH','ZA','ZP','ZS','ZT') and
            substr(p_to_pay_plan,1,1) <>'D' and
            p_to_pay_plan is not null then
           hr_utility.set_message(8301, 'GHR_37070_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
     end if;
   elsif p_effective_date >= to_date('1998/10/01', 'yyyy/mm/dd') then
     If   p_first_NOAC_Lookup_Code = '891' and
        p_to_pay_plan not in ('CG','CM','EM','EO','FM','GH','GM',
	      'ND','NG','NH','NJ','NK','NT','NB','TM','VH','ZA','ZP','ZS','ZT') and
        substr(p_to_pay_plan,1,1) <>'D' and
        p_to_pay_plan is not null then
       hr_utility.set_message(8301, 'GHR_37058_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   else
     If   p_first_NOAC_Lookup_Code = '891' and
         p_to_pay_plan not in ('CM','EM','FM','GH','GM','NB','TM','VH','ZA','ZP','ZS','ZT') and
         substr(p_to_pay_plan,1,1) <>'D'  and
      	 p_to_pay_plan is not null  then
       hr_utility.set_message(8301, 'GHR_37251_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   end if;
end if;

-- 440.22.2
   If  p_first_NOAC_Lookup_Code in  ('142','143','145','146','147','148',
						 '149','542','543','546','548','549')
    and
       p_to_pay_plan not in ('ES','FB','FE','FJ','FX')
    and
	 p_to_pay_plan is not null
   then
       hr_utility.set_message(8301, 'GHR_37252_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 440.25.2
--upd47  26-Jun-06	Raju	   From 01-Apr-2003		             Terminate the edit
	if p_effective_date < fnd_date.canonical_to_date('2003/04/01') then
	   If  p_first_NOAC_Lookup_Code ='893'  and
		   p_to_pay_plan ='GM' then
		   hr_utility.set_message(8301, 'GHR_37253_ALL_PROCEDURE_FAIL');
		   hr_utility.raise_error;
	   end if;
	end if;

-- 440.30.2
--  Delete the first line of the edit (If effective date is later than october 31, 1993)
        l_Effective_Date :=p_Effective_Date;
   If  substr( p_first_NOAC_Lookup_Code,1,1)='1'
	and
        p_agency not in ('AF','AR','DD','NV')
	and
        p_to_pay_plan = 'GM'
	then
       hr_utility.set_message(8301, 'GHR_37254_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
    end if;

-- 440.35.2
--  Delete the first line of the edit (If effective date is later than october 31, 1993)

    IF
      (
        (substr( p_first_NOAC_Lookup_Code,1,1)='5'
         or
         p_first_NOAC_Lookup_Code ='721')
        and
         p_Supervisory_status_code = '8'
	 )
     and
       p_to_pay_plan = 'GM'
    then
       hr_utility.set_message(8301, 'GHR_37255_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
    end if;


-- 440.40.2
    --            12/8/00   vravikan    From the Start
   -- Rewriting edit to
   -- If nature of action is 702,703, 713, or 740,
   -- Then pay plan may not be GM.
   If p_first_NOAC_Lookup_Code in ('702','703','713','740')
    and p_to_pay_plan is not null
    and p_to_pay_plan = 'GM'
   then
       hr_utility.set_message(8301, 'GHR_37256_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

--  440.45.3

   if ( p_Cur_Appt_Auth_1 = 'UAM'
     or
       p_Cur_Appt_Auth_2 = 'UAM' )
     and
       p_to_pay_plan  = 'GS'
    then
       hr_utility.set_message(8301, 'GHR_37257_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 440.46.2
--            12/8/00   vravikan    01-Oct-2000    New Edit
-- If nature of action is 871, Then pay plan must be GG
if l_effective_date >= fnd_date.canonical_to_date('2000/10/01') then
  if p_first_NOAC_Lookup_Code = '871' and
     p_to_pay_plan <> 'GG' then
       hr_utility.set_message(8301, 'GHR_37677_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
end if;
end chk_pay_plan;

/*
--  Pay Rate Determinant
*/

procedure chk_pay_rate_determinant
  (p_pay_rate_determinant_code       in varchar2
  ,p_prior_pay_rate_det_code in varchar2  -- non SF52
  ,p_to_pay_plan                     in varchar2
  ,p_first_noa_lookup_code           in varchar2
  ,p_duty_station_lookup_code        in varchar2
  ,p_agency                          in varchar2
  ,p_effective_date                  in date
) is
begin

--  450.02.3
   if p_pay_rate_determinant_code = '4' and
     (
      substr(p_to_pay_plan, 1, 1) = 'W' or
      substr(p_to_pay_plan, 1, 1) = 'X'
      )
      then
      hr_utility.set_message(8301, 'GHR_37258_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--  450.03.2
   -- Update Date   By        Effective Date   Bug           Comment
   -- 10/07/02      vnarasim                   2468911       Logic Modified.See bug desc.

   if    p_pay_rate_determinant_code = '4'
 	   and
        (p_to_pay_plan = 'GM' or p_to_pay_plan = 'GS')
	   and
    not(
	  (p_prior_pay_rate_det_code  = '4' or
         p_prior_pay_rate_det_code  is null) or
         ((p_first_noa_lookup_code in ('702','703','740','741') or
         substr(p_first_noa_lookup_code,1,1)= '5'
         ) and
        (p_prior_pay_rate_det_code  in ('5','6','E','F','J','K') or
         p_prior_pay_rate_det_code  is null
  	 ) )
       )
   then
       hr_utility.set_message(8301, 'GHR_37259_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

--  450.04.3
--upd47  26-Jun-06	Raju	   From 01-Apr-2003		             Terminate the edit
	if p_effective_date < fnd_date.canonical_to_date('2003/04/01') then
	   if    (p_to_pay_plan = 'FA' or p_to_pay_plan = 'EX') and
			  p_pay_rate_determinant_code not in ('C','S','0') and
			  p_pay_rate_determinant_code is not null  then
		   hr_utility.set_message(8301, 'GHR_37260_ALL_PROCEDURE_FAIL');
		   hr_utility.raise_error;
	   end if;
	end if;

--  450.05.3
--        12/8/00  vravikan    1-oct-00          New Edit
-- If Pay Plan is GH or GM,
-- Then pay rate determinant may not be A,B,E,F,U, or V
   IF p_effective_date >= fnd_date.canonical_to_date('2000/10/01') then
     IF (p_to_pay_plan = 'GH' or p_to_pay_plan = 'GM')
         and
          p_pay_rate_determinant_code  in ('A','B','E','F','U','V')
         and
          p_pay_rate_determinant_code is not null
         then
       hr_utility.set_message(8301, 'GHR_37859_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     END IF;
   END IF;


--  450.10.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_pay_rate_determinant_code = 'C' and
      (
	    p_to_pay_plan in ('ED','EE','EF','EG','EH','EI','ZZ')
          or
          substr(p_to_pay_plan,1,1) in ('B','W','X')
          ) then
       hr_utility.set_message(8301, 'GHR_37261_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
end if;
--  450.19.3
-- UPDATE_DATE	UPDATED_BY	EFFECTIVE_DATE		COMMENTS
-----------------------------------------------------------------------------
-- 18-Oct-04    Madhuri         from start of edit	Modifying the edit to
--							include the PRD-2.
-- 11-DEC-08    AVR             from start of edit      Modified the edit to
--                                                      include the PRD-D
--
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_to_pay_plan = 'ES' and
      p_pay_rate_determinant_code <> 'C'
      and
      p_pay_rate_determinant_code <> '0'
	and
      p_pay_rate_determinant_code <> '2'
	and
      p_pay_rate_determinant_code <> 'D'--Bug# 7633560
	and
      p_pay_rate_determinant_code is not null
      then
      hr_utility.set_message(8301, 'GHR_37262_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

--  450.22.2
if p_effective_date < to_date('2005/05/01','yyyy/mm/dd') then
   if   ( p_first_noa_lookup_code= '740' or
         p_first_noa_lookup_code= '741')
     and
  	   p_pay_rate_determinant_code not in ('A','B','E','F',
                                            'M','U','V')
     and
	   p_pay_rate_determinant_code is not null
     and
         p_prior_pay_rate_det_code not in ('A','B','E','F',
                                                   'M','U','V')
     and
 	   p_prior_pay_rate_det_code is not null
     then
       hr_utility.set_message(8301, 'GHR_37263_ALL_PROCEDURE_FAIL');
	   hr_utility.set_message_token('PRD_LIST','A, B, E, F, M, U, or V');
       hr_utility.raise_error;
    end if;
elsif p_effective_date >= to_date('2005/05/01','yyyy/mm/dd') then
	if  ( p_first_noa_lookup_code= '740' or
        p_first_noa_lookup_code= '741') and
  	    p_pay_rate_determinant_code not in ('A','B','E','F','U','V') and
	    p_pay_rate_determinant_code is not null  and
        p_prior_pay_rate_det_code not in ('A','B','E','F','U','V')   and
 	    p_prior_pay_rate_det_code is not null then
		hr_utility.set_message(8301, 'GHR_37263_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PRD_LIST','A, B, E, F, U, or V');
		hr_utility.raise_error;
    end if;
end if;

--  450.25.2
   if (p_first_noa_lookup_code ='702' or
       p_first_noa_lookup_code ='721')
	 and
       p_pay_rate_determinant_code in ('A','B','E','F','U','V') then
       hr_utility.set_message(8301, 'GHR_37264_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

--  450.28.2
   -- Update/Change Date        By        Effective Date            Comment
   --   9/4        08/10/99    vravikan   01-Mar-99                 Add PRD T.
   --  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete PRD M effective date from 01-May-2005
   --upd47  26-Jun-06	Raju	   From 01-Apr-2003		             Terminate the edit
    if p_effective_date < fnd_date.canonical_to_date('2003/04/01') then
       If p_effective_date >= fnd_date.canonical_to_date('20'||'05/05/01') then
         if (p_first_noa_lookup_code = '892' or
            p_first_noa_lookup_code = '893') and
            p_pay_rate_determinant_code not in ('0','5','6','7','A','B','E','F','T') and
            p_pay_rate_determinant_code is not null
         then
           hr_utility.set_message(8301, 'GHR_37061_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PRD_LIST','0, 5, 6, 7, A, B, E, F or T');
           hr_utility.raise_error;
         end if;
      elsIf p_effective_date >= fnd_date.canonical_to_date('19'||'99/03/01') then
         if (p_first_noa_lookup_code = '892' or
            p_first_noa_lookup_code = '893') and
            p_pay_rate_determinant_code not in ('0','5','6','7','A','B','E','F','M','T') and
            p_pay_rate_determinant_code is not null
         then
           hr_utility.set_message(8301, 'GHR_37061_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PRD_LIST','0, 5, 6, 7, A, B, E, F, M or T');
           hr_utility.raise_error;
         end if;
      else
         if (p_first_noa_lookup_code = '892' or
            p_first_noa_lookup_code = '893') and
           p_pay_rate_determinant_code not in ('0','5','6','7','A',
                                               'B','E','F','M') and
           p_pay_rate_determinant_code is not null
         then
           hr_utility.set_message(8301, 'GHR_37265_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
         end if;
      end if;
    end if;

--  450.30.3
-------------------------------------------------------------------------------
-- Modified by       Date             Comments
-------------------------------------------------------------------------------
-- Madhuri          01-MAR-05         Retroactively end dating as of 31-JAN-2002
-- UPDATE 38 Changes
-------------------------------------------------------------------------------
 IF p_effective_date <= fnd_date.canonical_to_date('20'||'02/01/31') THEN
   if p_pay_rate_determinant_code = 'M' and
/* This is the code for the cities of Boston, Chicago, Los Angeles, New York, Philadelphia, San Diego,
   San Francisco, and Washington D.C.*/
   		(
		substr(p_duty_station_lookup_code,1,2) not in ('05','08','41','45','56','71','74','80','11') and

/* This selects the counties that make up Boston CMSA */
		(
		substr(p_duty_station_lookup_code,1,2) = '25' and
		substr(p_duty_station_lookup_code,7,3) not in ('009','017','021','023','025')
		) and
/* This selects the parts of other counties that make up Boston CMSA */
/* part of Bristol County */
		 p_duty_station_lookup_code not in ('250007005','250039005','250096005','250188005','250251005',
		'250254005','250281005','250299005','250315005','250385005','250670005','250850005','250911005',
		'250912005','250913005','250924005','251064005','251062005','251135005','251219005','251225005',
 		'251280005')
		and
/* part of Hampden County */
		 p_duty_station_lookup_code <> '250489013'
		and
/* part of Worcester County */
		 p_duty_station_lookup_code not in ('250032027','250055027','250079027','250080027','250098027',
		 '250110027','250902027','250910027','250916027','250918027','250927027','250944027','250117027',
		 '250123027','250150027','250185027','250186027','250189027','250220027','250252027','250263027',
		 '250272027','250280027','250332027','250350027','250390027','250436027','250467027','250480027',
		 '250510027','250555027','250565027','250585027','250610027','250619027','250640027','250664027',
		 '250745027','250780027','250785027','250820027','250834027','250900027','250943027','250980027',
		 '250999027','251450027','251800027','251100027','251172027','251200027','251203027','251204027',
		 '251210027','251228027','251240027','251260027','251273027','251266027','251271027','251278027',
		 '251269027','251283027','251310027','251320027','251376027','251380027','251390027','251395027',
		 '251410027','251439027','251455027','251470027','251500027','251520027')
		and
/* New Hampshire */
/* part of Hillsborough County */
		 p_duty_station_lookup_code not in ('330011011','330018011','330031011','330160011','330180011',
		 '330234011','330240011','330299011','330310011','330324011','330334011','330340011','330344011',
		 '330350011','330357011','330401011','330434011','330509011','330540011')
		and
/* part of Merrimack County */
		 p_duty_station_lookup_code <> '330236013' and
/* part of Rockingham County */
		 p_duty_station_lookup_code not in ('330012015','330013015','330025015','330032015','330045015',
		 '330087015','330085015','330105015','330108015','330112015','330123015','330130015','330153015',
		 '330176015','330195015','330200015','330199015','330201015','330252015','330355015','330354015',
		 '330356015','330370015','330381015','330382015','330391015','330384015','330417015','330430015',
		 '330435015','330445015','330447015','330448015','330462015','330466015','330474015','330475015',
		 '330478015','330255015','330305015','330533015','330527015','330551015')
		and
/* part of Strafford County */
		 p_duty_station_lookup_code not in ('330029017','330090017','330100017','330140017','330281017',
		 '330311017','330342017','330345017','330440017','330443017','330470017')
		and
/* Maine */
/* part of York County */
		 p_duty_station_lookup_code not in ('230450031','231445031','232450031','234250031','234300031',
		 '237450031','239800031','239900031','239950031')
		and
/* Connecticut */
/* part of Windham County */
		 p_duty_station_lookup_code not in ('090231015','090259015','090373015','090500015','090603015',
		 '090749015')
		and
/* Chiacago */
/* Illinois */
		(
		substr(p_duty_station_lookup_code,1,2) = '17' and
		  substr(p_duty_station_lookup_code,7,3) not in ('031','037','043','063','089','091','093','097',
		 '111','197')
		) and
/* Indiana */
		(
		substr(p_duty_station_lookup_code,1,2) = '18' and
		substr(p_duty_station_lookup_code,7,3) not in ('089','027')
		) and
/* Wisconsin */
		(
		 substr(p_duty_station_lookup_code,1,2) = '55' and
		 substr(p_duty_station_lookup_code,7,3) <> '059'
		) and
/* Los Angeles */
		 (
		(substr(p_duty_station_lookup_code,1,2) = '06' and
		  substr(p_duty_station_lookup_code,7,3) not in ('037','059','065','071','083','111')) and
		 p_duty_station_lookup_code <> '061077029'
		) and
/* New York */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '36' and
		  substr(p_duty_station_lookup_code,7,3) not in ('005','027','047','059','061','071','079','081',
		 '085','087','103','119')
		  ) and
/* New Jersey */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '34' and
		  substr(p_duty_station_lookup_code,7,3) not in ('003','013','017','019','021','023','025','027',
		 '029','031','035','037','039','041')
		  ) and
/* Connecticut */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '09' and
		  substr(p_duty_station_lookup_code,7,3) not in ('001','0009')
		  ) and
/* part of Litchfield County */
		 p_duty_station_lookup_code not in ('090051005','090083005','090247005','090629005','090740005',
		 '090802005','090805005','090450005','090454005','090535005','090817005','090857005')
		  and
/* part of Middlesex County */
		 p_duty_station_lookup_code not in ('090130007','090332007')
	       and
/* Pennsylvania */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '42' and
		  substr(p_duty_station_lookup_code,7,3) <> '103'
		  ) and
/* Philadelphia */
/* Pennsylvania */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '42' and
		  substr(p_duty_station_lookup_code,7,3) not in ('017','029','045','091','101')
		  ) and
/* New Jersey */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '34' and
		  substr(p_duty_station_lookup_code,7,3) not in ('001','005','007','009','011','015','033')
              ) and
/* Delaware */
		 (
	        substr(p_duty_station_lookup_code,1,2) = '10' and
		  substr(p_duty_station_lookup_code,7,3) <> '015'
		  ) and
/* San Diego */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '06' and
		  substr(p_duty_station_lookup_code,7,3) <> '073'
	        ) and
/* San Francisco */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '06' and
		  substr(p_duty_station_lookup_code,7,3) not in ('001','013','041','055','075','081','085',
		 '087','095','097')
		  ) and
/* Washington DC */
/* Maryland */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '24' and
		  substr(p_duty_station_lookup_code,7,3) not in ('003','005','009','013','017','021','025',
		 '027','031','033','035','037','043','510')
		  ) and
/* Virginia */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '51' and
		  substr(p_duty_station_lookup_code,7,3) not in ('013','043','047','059','061','099','107',
		 '153','177','179','187','510','600','610','630','683','685')
		  ) and
/* West Virginia */
		 (
		  substr(p_duty_station_lookup_code,1,2) = '54' and
		  substr(p_duty_station_lookup_code,7,3) not in ('003','037')
		  )
		) then
      hr_utility.set_message(8301, 'GHR_37266_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
  END IF;
-------------------------------------------------------------------------------

--  450.40.3
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_pay_rate_determinant_code = 'P' and
         p_agency <>'VA' then
       hr_utility.set_message(8301, 'GHR_37267_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
end if;

--  450.42.3
-------------------------------------------------------------------------------
   -- Update/Change Date        By        Effective Date            Comment
   --   9/4        08/10/99    vravikan   01-Mar-99                 Exclude PRD T.
-------------------------------------------------------------------------------
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   If p_effective_date >= fnd_date.canonical_to_date('19'||'99/03/01') then
     if (p_to_pay_plan= 'GM' or
       p_to_pay_plan= 'GS'
      ) and
       p_pay_rate_determinant_code in ('P','T')  then
       hr_utility.set_message(8301, 'GHR_37062_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   else
     if (p_to_pay_plan= 'GM' or
       p_to_pay_plan= 'GS'
      ) and
       p_pay_rate_determinant_code = 'P' then
       hr_utility.set_message(8301, 'GHR_37268_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   end if;
end if;
--  450.43.3

--   If pay rate determinant is Z,
--   Then pay plan must not be FO or FP,
--   And agency must be AM, GY, or ST,
--   And the first two positions of duty station must be CA or MX.

   -- Update/Change Date        By          Comment
   --   30-Oct-03               Ashley      New Edit


    IF p_pay_rate_determinant_code = 'Z' AND
       p_to_pay_plan  IN ('FO','FP') AND p_agency NOT IN ('AM','GY','ST') AND
       substr(p_duty_station_lookup_code,1,2) NOT IN ('CA','MX') THEN
	   hr_utility.set_message(8301, 'GHR_38841_ALL_PROCEDURE_FAIL');
	   hr_utility.raise_error;
    END IF;

end chk_pay_rate_determinant;

end GHR_CPDF_CHECK3;

/
