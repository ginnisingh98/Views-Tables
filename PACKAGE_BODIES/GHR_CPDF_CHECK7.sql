--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK7" as
/* $Header: ghcpdf07.pkb 120.16.12010000.12 2010/01/29 04:51:50 utokachi ship $ */

   max_basic_pay		number(10,2);
   min_basic_pay		number(10,2);

-- PRIOR BASIC PAY

procedure chk_prior_basic_pay
  (p_prior_pay_plan			 	in	varchar2	/* Non-SF52 Data Item */
  ,p_pay_determinant_code                 in    varchar2
  ,p_prior_pay_rate_det_code		      in	varchar2	/* Non-SF52 Data Item */
  ,p_prior_basic_pay				in	varchar2	/* Non-SF52 Data Item */
  ,p_retained_pay_plan				in 	varchar2	/* Non-SF52 Data Item */
  ,p_retained_grade				in 	varchar2	/* Non-SF52 Data Item */
  ,p_retained_step				in	varchar2	/* Non-SF52 Data Item */
  ,p_agency_subelement				in	varchar2	/* Non-SF52 Data Item */
  ,p_prior_grade_or_level			in	varchar2	/* Non-SF52 Data Item */
  ,p_prior_step_or_rate				in 	varchar2	/* Non-SF52 Data Item */
  ,p_prior_pay_basis				in 	varchar2	/* Non-SF52 Data Item */
  ,p_first_noac_lookup_code			in  	varchar2
  ,p_to_basic_pay	                        in    varchar2
  ,p_to_pay_basis	                        in    varchar2
  ,P_effective_date				in 	date
  ,p_prior_effective_date                 in    date
  ) is

l_table_pay				   pay_user_column_instances_f.value%type;
begin
 hr_utility.set_location('before call to get basic pay',1);
   hr_utility.set_location('eff date '|| p_prior_effective_date,1);
   hr_utility.set_location('grade '|| p_prior_grade_or_level,1);
   hr_utility.set_location('Step '|| p_prior_step_or_rate,1);
   l_table_pay := GHR_CPDF_CHECK.get_basic_pay(
                                 '0000 Oracle Federal Standard Pay Table (AL, ES, EX, GS, GG) No. 0000',
                                 'GS' || '-' || p_prior_grade_or_level,
                                 p_prior_step_or_rate,
                                 p_prior_effective_date);
 hr_utility.set_location('after call to get basic pay',1);

-- 570.02.2
-- Venkat 06/08/03
-- This edit bypassed when the 866 action and Temporary Promotion Step is not null
--
-- Madhuri    19-MAY-04   From the Start      Including the Pay Plan VP in Prior Pay Plan list
--
IF GHR_GHRWS52L.g_temp_step is NULL
OR (GHR_GHRWS52L.g_temp_step is NOT NULL
    AND p_first_noac_lookup_code <> '866' ) THEN
  if (
	p_prior_pay_plan in ('GS','VP') and (p_prior_pay_rate_det_code = '0' or
       p_prior_pay_rate_det_code= '7') and
	(p_prior_grade_or_level between '01' and '15') and
	(p_prior_step_or_rate between '01' and '10')
     ) then
	  if not (
		    (l_table_pay = to_number(p_prior_basic_pay)) or
                (p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
	 	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37746_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
	  end if;
  end if;
END IF;

-- 570.23.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
  if  (p_prior_pay_plan = 'FG'  and
       (
	  p_prior_pay_rate_det_code = '0' or
        p_prior_pay_rate_det_code = '7'
       ) and
	  (p_prior_grade_or_level between '01' and '15') and
	  (p_prior_step_or_rate between '01' and '10')

       ) then
	  if not (l_table_pay = to_number(p_prior_basic_pay) or
               (p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)) then
           GHR_GHRWS52L.CPDF_Parameter_Check;
           hr_utility.set_message(8301,'GHR_37708_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
	  end if;
  end if;
end if;

-- 570.28.2
--            12/8/00   vravikan    From the Start         Add 871 to 'other than' (not equal to ) list
--            08/19/02  vravikan    From the Start         Added one more and condition
--                                                          prior_pay_basis = to_pay_basis
--            30/10/03  Ashley      From the Start         Added nature of action 849 to the list
--            01/30/04  Venkat      From the Start         Excluded SES Pay Plans
-- upd50      06-Feb-07	 Raju       From 01-Oct-2006	   Bug#5745356 delete NOA 849
-- upd51     06-Feb-07  Raju        From 01-Jan-2007	   Bug#5745356 delete 815-817, 825
 --                                                        840-848,878-879. Add 890
 -- upd53  20-Apr-07  Raju          From 01-Jan-2007	   Bug#5996938 added 815-817, 825
 --                                                        827,840-849,878-879.

   if p_effective_date < fnd_date.canonical_to_date('2006/10/01') then
       if (
        (substr(p_first_noac_lookup_code,1,1) in ('7','8') and
         p_first_noac_lookup_code not in
         (	  '702','703','713','721','740','741','815','816','817','825','840','841',
              '842','843','844','845','846','847','848','849','855','866','867','868',
              '871','878','879','891','892','893','894','897' )
          ) and
            p_prior_pay_plan not in  ('ES','EP','IE','FE') and
        (
         ((p_prior_basic_pay is not null and to_number(p_prior_basic_pay) <> 0) and
          (p_to_basic_pay is not null and to_number(p_to_basic_pay) <> 0) and
              (p_prior_pay_basis = p_to_pay_basis) ) and
           to_number(p_prior_basic_pay) <> to_number(p_to_basic_pay))
         ) then
           GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37713_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('NOA_CODE','702, 703, 713, 721, 740, 741, 815-817, 825, 840-849, 855, 866-868, 871,878-879, 891-894');
         hr_utility.raise_error;
      end if;
    ELSif p_effective_date < fnd_date.canonical_to_date('2007/01/01') then
      if (
        (substr(p_first_noac_lookup_code,1,1) in ('7','8') and
         p_first_noac_lookup_code not in
         (	  '702','703','713','721','740','741','815','816','817','825','840','841',
              '842','843','844','845','846','847','848','855','866','867','868',
              '871','878','879','891','892','893','894' )
          ) and
            p_prior_pay_plan not in  ('ES','EP','IE','FE') and
        (
         ((p_prior_basic_pay is not null and to_number(p_prior_basic_pay) <> 0) and
          (p_to_basic_pay is not null and to_number(p_to_basic_pay) <> 0) and
              (p_prior_pay_basis = p_to_pay_basis) ) and
           to_number(p_prior_basic_pay) <> to_number(p_to_basic_pay))
         ) then
           GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37713_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('NOA_CODE','702, 703, 713, 721, 740, 741, 815-817, 825, 840-848, 855, 866-868, 871,878-879, 891-894');
         hr_utility.raise_error;
      end if;
     ELSE
      if (
        (substr(p_first_noac_lookup_code,1,1) in ('7','8') and
         p_first_noac_lookup_code not in
         (	  '702','703','713','721','740','741','815','816','817','825','827','840','841',
              '842','843','844','845','846','847','848','849','855','866','867','868',
              '871','878','879','890','891','892','893','894','896','897' )
          ) and
            p_prior_pay_plan not in  ('ES','EP','IE','FE') and
        (
         ((p_prior_basic_pay is not null and to_number(p_prior_basic_pay) <> 0) and
          (p_to_basic_pay is not null and to_number(p_to_basic_pay) <> 0) and
              (p_prior_pay_basis = p_to_pay_basis) ) and
           to_number(p_prior_basic_pay) <> to_number(p_to_basic_pay))
         ) then
           GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37625_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
    END IF;

-- 570.50.2
-- Commented the edit in Dec'00 Patch.
-- Uncommented and modified the edit
-- Utokachi Modified on 24-oct-2005 Validate for actions after 01-MAY-2005

  IF p_effective_date >= to_date('2005/05/01','YYYY/MM/DD') THEN
     if ( p_prior_pay_plan = 'GS' and
          p_prior_pay_rate_det_code in ('5','6')
        ) then
          if ((to_number(p_prior_basic_pay) < to_number(l_table_pay)) and
            (p_prior_basic_pay is not null and to_number(p_prior_basic_pay) <> 0)
              ) then
               GHR_GHRWS52L.CPDF_Parameter_Check;
               hr_utility.set_message(8301,'GHR_37719_ALL_PROCEDURE_FAIL');
               hr_utility.raise_error;
          end if;
      end if;
  END IF;

-- 570.80.2
  if (
	p_prior_pay_plan = 'GG' and
	(
	 p_prior_grade_or_level between '01' and '15' and
	 p_prior_step_or_rate between '01' and '10' and
	 p_prior_pay_rate_det_code in ('0','7')
	)
     ) then
          l_table_pay := GHR_CPDF_CHECK.get_basic_pay(
                                 '0000 Oracle Federal Standard Pay Table (AL, ES, EX, GS, GG) No. 0000',
                                 'GG' || '-' || p_prior_grade_or_level,
                                  p_prior_step_or_rate,
                                  p_prior_effective_date);
	  if not (
	          p_prior_basic_pay = l_table_pay or (p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
	     	   ) then
           GHR_GHRWS52L.CPDF_Parameter_Check;
           hr_utility.set_message(8301,'GHR_37726_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
	  end if;
  end if;

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
570.03.2  If prior pay plan is NH,and prior pay rate determinant is
          0,5,6 or 7, Then prior basic pay must be within the range
          for the prior grade on Table 37 or Table 38
          (depending on prior pay rate determinant) or be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.

  if p_effective_date > fnd_date.canonical_to_date('1998/03/01') and
     p_prior_pay_plan = 'NH' and
     p_prior_pay_rate_det_code in ('0','5','6','7') then -- added for bug 726125
     if p_prior_pay_rate_det_code in ('0','7')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 37',
                          p_prior_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 37',
                          p_prior_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     elsif p_prior_pay_rate_det_code in ('5','6')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 38',
                          p_prior_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 38',
                          p_prior_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     end if;
     if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
        (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
        or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
     then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37865_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
     end if;
  end if;
*/

/* 570.04.2  If prior pay plan is GS,
          And prior pay rate determinant is 2, 3, 4, J, K, or R,
          Then prior basic pay must be equal to or exceed the
          minimum basic pay for prior grade on Table 2 or be
          asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
--upd47  26-Jun-06	Raju	   From 01-Apr-2003		             Terminate the edit
if p_effective_date < fnd_date.canonical_to_date('2003/04/01') then
	if p_prior_pay_plan = 'GS'  and
	   p_prior_pay_rate_det_code in ('2','3','4','J','K','R') then

	   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 2',
						p_prior_grade_or_level || '-' || p_prior_step_or_rate,
						'Minimum Basic Pay',
						p_prior_effective_date);
	   if min_basic_pay IS NOT NULL and
		  (not(to_number(p_prior_basic_pay) >= min_basic_pay)
		  or p_prior_basic_pay is null)
	   then
		  GHR_GHRWS52L.CPDF_Parameter_Check;
		  hr_utility.set_message(8301,'GHR_37701_ALL_PROCEDURE_FAIL');
		  hr_utility.raise_error;
	   end if;
	end if;
end if;

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
570.05.2  If prior pay plan is NJ,and prior pay rate determinant is
          0,5,6 or 7, Then prior basic pay must be within the range
          for the prior grade on Table 39 or Table 40
          (depending on prior pay rate determinant) or be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.

  if p_effective_date > fnd_date.canonical_to_date('1998/03/01') and
     p_prior_pay_plan = 'NJ' and
     p_prior_pay_rate_det_code in ('0','5','6','7') then -- added for bug 726125
     if p_prior_pay_rate_det_code in ('0','7')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 39',
                          p_prior_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 39',
                          p_prior_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     elsif p_prior_pay_rate_det_code in ('5','6')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 40',
                          p_prior_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 40',
                          p_prior_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     end if;
     if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
        (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
        or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
     then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37866_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
     end if;
  end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
570.06.2  If prior pay plan is NK,and prior pay rate determinant is
          0,5,6 or 7, Then prior basic pay must be within the range
          for the prior grade on Table 41 or Table 42
          (depending on pay rate determinant) or be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.

  if p_effective_date > fnd_date.canonical_to_date('1998/03/01') and
     p_prior_pay_plan = 'NK' and
     p_prior_pay_rate_det_code in ('0','5','6','7') then -- added for bug 726125
     if p_prior_pay_rate_det_code in ('0','7')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 41',
                          p_prior_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 41',
                          p_prior_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     elsif p_prior_pay_rate_det_code in ('5','6')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 42',
                          p_prior_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 42',
                          p_prior_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     end if;
     if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
        (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
        or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
     then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37867_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
     end if;
  end if;
*/

/*570.07.2  If prior pay plan is GM,
          And prior pay rate determinant is 0 or 7,
          Then prior basic pay must fall within the appropriate
          range for prior grade and step or rate on Table 3 or be
          asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay. */
--           17-Aug-00   vravikan   1-Jan-2000        Modify Edit to remove step or rate
if p_effective_date >= to_date('2000/01/01','yyyy/mm/dd') then
if p_prior_pay_plan = 'GM'  and
   p_prior_pay_rate_det_code in ('0','7') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                    p_prior_grade_or_level ,
                    'Minimum Basic Pay',
                    p_prior_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                    p_prior_grade_or_level ,
                    'Maximum Basic Pay',
                    p_prior_effective_date);
   if min_basic_pay IS NOT NULL and
      max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
        or p_prior_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37702_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
else
if p_prior_pay_plan = 'GM'  and
   p_prior_pay_rate_det_code in ('0','7') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                    p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                    'Minimum Basic Pay',
                    p_prior_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                    p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                    'Maximum Basic Pay',
                    p_prior_effective_date);
   if min_basic_pay IS NOT NULL and
      max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
        or p_prior_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37702_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
end if;

 --            12/8/00   vravikan    From Start     Change Edit
 --                                                 Table 4 to Table 2

 /*570.10.2  If prior pay plan is GM or GH,
          And prior pay rate determinant is 2, 3, 4, J, K, or R,
          Then prior basic pay must equal or exceed the minimum
          basic pay for prior grade on Table 4 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
--upd47  26-Jun-06	Raju	   From 01-Apr-2006		Added pay plan GS

if p_effective_date < fnd_date.canonical_to_date('2006/04/01') then
    if p_prior_pay_plan in ('GH', 'GM') and
       p_prior_pay_rate_det_code in ('2','3','4','J','K','R')  then
       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 2',
                        p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                        'Minimum Basic Pay',
                        p_prior_effective_date);
       if min_basic_pay IS NOT NULL and
          (not(to_number(p_prior_basic_pay) >= min_basic_pay)
           or p_prior_basic_pay is null)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37703_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','GM or GH');
          hr_utility.raise_error;
       end if;
    end if;
else
    if p_prior_pay_plan in ('GH', 'GM','GS') and
       p_prior_pay_rate_det_code in ('2','3','4','J','K','R')  then
       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 2',
                        p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                        'Minimum Basic Pay',
                        p_prior_effective_date);
       if min_basic_pay IS NOT NULL and
          (not(to_number(p_prior_basic_pay) >= min_basic_pay)
           or p_prior_basic_pay is null)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37703_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','GH, GM, or GS');
          hr_utility.raise_error;
       end if;
    end if;
end if;

/*570.13.2  If prior pay plan is EX,
          And prior pay rate determinant is 0,
          Then prior basic pay must match the entry for prior
          grade on Table 5 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
if p_prior_pay_plan = 'EX'  and
   p_prior_pay_rate_det_code = '0' then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 5',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',
                    p_prior_effective_date);
   if max_basic_pay IS NOT NULL and
      (to_number(p_prior_basic_pay) <> max_basic_pay
      or p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37704_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/*570.16.2  If prior pay plan is ES or FE,
          And prior pay rate determinant is not C,
          Then prior basic pay must match the entry for prior
          step or rate on Table 6 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
-- NAME           EFFECTIVE      COMMENTS
-- Madhuri        21-JAN-2004    End Dating this edit as on 10-JAN-04
--				 For SES Pay Calculations
--
 -- end dating the edit as on 10-JAN-2004
IF p_effective_date < to_date('2004/01/11', 'yyyy/mm/dd') then

 if (p_prior_pay_plan in ('ES', 'FE') and
   p_prior_pay_rate_det_code <> 'C' ) then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 6',
                    p_prior_step_or_rate,
                    'Maximum Basic Pay',
                    p_prior_effective_date);
   if max_basic_pay IS NOT NULL and
      (p_prior_basic_pay <> max_basic_pay
      or p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37705_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
 end if;
END IF; -- end dating the edit as on 10-JAN-2004

-- NEW EDIT as on 19-MAY-2004
/* 570.17.2:	If prior pay plan is ES or FE,
		and prior pay rate determinant is not C,
		Then prior basic pay must be within the range on Table 55 */

-- Name			Effective Date		Comments
-- Madhuri               19-MAY-2004		Added this Edit
--
IF ( p_effective_date >= to_date('2004/01/11', 'yyyy/mm/dd') )
  and
  ( p_prior_pay_plan in ('ES', 'FE') and  p_prior_pay_rate_det_code <> 'C' )
  THEN
	min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 55',
                        p_prior_pay_plan,
                        'Minimum Basic Pay',
                        p_effective_date);
	max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 55',
                        p_prior_pay_plan,
                        'Maximum Basic Pay',
                        p_effective_date);

      if not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
      then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_38885_ALL_PROCEDURE_FAIL');
-- NEED TO ADD A NEW MESSAGE HERE
        hr_utility.raise_error;
      end if;
END IF;

/*570.19.2  If prior pay plan is W-, XE, XF, XG, or XH,
          And prior pay rate determinant is 0,
          Then prior basic pay must fall within the range for
          prior pay plan on Table 11 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/

 -- Update Date   Updated By	Effective Date			Comments
 -----------------------------------------------------------------------------------------------------------
 -- 18/10/2004    Madhuri	From the start of the edit	Deleting the edit
 -----------------------------------------------------------------------------------------------------------
/*
if substr(p_prior_pay_plan,1,1) = 'W' or p_prior_pay_plan in ('XE', 'XF', 'XG', 'XH') then
   min_basic_pay := NULL;
   max_basic_pay := NULL;
   if substr(p_prior_pay_plan,1,1) = 'W' then
      if p_prior_pay_plan not in ('WG','WL','WM','WS') then
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       p_prior_pay_plan,
                                                       'Maximum Basic Pay', p_prior_effective_date);
      else
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       p_prior_pay_plan||'-'||p_prior_grade_or_level,
                                                      'Minimum Basic Pay', p_prior_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       p_prior_pay_plan||'-'||p_prior_grade_or_level,
                                                       'Maximum Basic Pay', p_prior_effective_date);
      end if;
   else
      if p_prior_pay_plan = 'XE' then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       p_prior_pay_plan,
                                                       'Minimum Basic Pay', p_prior_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       p_prior_pay_plan,
                                                       'Maximum Basic Pay', p_prior_effective_date);
      elsif p_prior_pay_plan in ('XF', 'XG', 'XH') then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       p_prior_pay_plan||'-'||p_prior_grade_or_level,
                                                       'Minimum Basic Pay', p_prior_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       p_prior_pay_plan||'-'||p_prior_grade_or_level,
                                                       'Maximum Basic Pay', p_prior_effective_date);
      end if;
   end if;
   if max_basic_pay IS NOT NULL then
      if p_prior_pay_rate_det_code = '0'
         and (not(to_number(p_prior_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
         or p_prior_basic_pay is null)
      then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37706_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
    end if;
end if; */
-------------------------------------------------------------------------------------------------------

/*
Edit #570.21.2:If prior pay plan is GL
	    and prior pay rate determinant is 0 or 7.
	    Then prior basic pay must match the entry for
	    the prior grade and prior step on Table 57 or be asterisks.
*/
-- 570.21.2
IF  p_effective_date >= fnd_date.canonical_to_date('2007/08/13') THEN
  IF (
	p_prior_pay_plan = 'GL' and p_prior_pay_rate_det_code in ('0','7')
     ) THEN
          l_table_pay := GHR_CPDF_CHECK.get_basic_pay(
                                 '0491 Oracle Federal Special Rate Pay Table (GS) No. 0491',
                                 'GL' || '-' || p_prior_grade_or_level,
                                  p_prior_step_or_rate,
                                  p_prior_effective_date);
	  if not (
	          p_prior_basic_pay = l_table_pay or (p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
	     	   ) then
           GHR_GHRWS52L.CPDF_Parameter_Check;
           hr_utility.set_message(8301,'GHR_37750_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
	  end if;
  END IF;

END IF;

/*570.22.2  If prior pay plan is KA,
          Then prior basic pay must fall within the range on
          Table 17 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay. */
-------------------------------------------------------------------------------
-- Modified by       Date             Comments
-------------------------------------------------------------------------------
-- Madhuri          01-MAR-05         Retroactively end dating as of 31-JAN-2002
-------------------------------------------------------------------------------
IF p_prior_effective_date <= fnd_date.canonical_to_date('20'||'02/01/31') THEN
 if p_prior_pay_plan = 'KA' then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 17',
                    p_prior_pay_plan ,
                    'Minimum Basic Pay',
                    p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 17',
                    p_prior_pay_plan ,
                    'Maximum Basic Pay',
                    p_prior_effective_date);
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay) or
         p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0) then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37707_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
 end if;
END IF;
-------------------------------------------------------------------------------

/*570.24.2  If prior pay plan is FB, FJ, or FX,
          Then prior basic pay must be no less than step 1 on
          Table 6 and no more than step 6 on Table 6, or be
          asterisks.
          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
--
-- Madhuri   19-MAY-2004    End dated the Edit as of 10-JAN-04
--
IF p_effective_date < to_date('2004/01/11', 'yyyy/mm/dd') then
 if p_prior_pay_plan in ('FB', 'FJ', 'FX') then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 6',
                                                 '01',
                                                 'Maximum Basic Pay',
                                                  p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 6',
                                                 '06',
                                                 'Maximum Basic Pay',
                                                  p_prior_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay) or
         p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
      then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37709_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
 end if;
END IF;

/*570.25.2  If prior pay plan is FT,
          Then prior basic pay must be within the range on Table
          21 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_prior_pay_plan = 'FT' then
       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                                                     p_prior_pay_plan ,
                                                     'Minimum Basic Pay',
                                                     p_prior_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                                                     p_prior_pay_plan ,
                                                     'Maximum Basic Pay',
                                                     p_prior_effective_date);
       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
          if (not (to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
              or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
          then
             GHR_GHRWS52L.CPDF_Parameter_Check;
             hr_utility.set_message(8301,'GHR_37710_ALL_PROCEDURE_FAIL');
             hr_utility.raise_error;
          end if;
       end if;
    end if;
end if;

/*570.26.2  If prior pay plan is FL, FS, or FW,
          Then prior basic pay must be no less than the minimum
          for pay plan WG on Table 11 and no more than the
          maximum for pay plan WS on Table 11, or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                   basic pay.*/
 -- Update Date   Updated By	Effective Date			Comments
 -----------------------------------------------------------------------------------------------------------
 -- 18/10/2004    Madhuri	From the start of the edit	Deleting the edit
 -----------------------------------------------------------------------------------------------------------

/*if p_prior_pay_plan in ('FL', 'FS', 'FW') then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                    'WG'||'-'||p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                    'WS'||'-'||p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if (not (to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
          or p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
      then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37711_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
      end if;
   end if;
end if; */
 -----------------------------------------------------------------------------------------------------------

/*570.27.2  If prior pay plan is FM,
          And prior pay rate determinant is 0 or 7,
          Then prior basic pay must match the entry for prior
          grade and prior step or rate on Table 3 or be
          asterisks.
          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
--           17-Aug-00    vravikan   1-Jan-2000       Modify Edit to remove prior step or rate
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_effective_date >= to_date('2000/01/01','yyyy/mm/dd') then
    if p_prior_pay_plan = 'FM' and
       p_prior_pay_rate_det_code in ('0','7') then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                        p_prior_grade_or_level ,
                        'Minimum Basic Pay',p_prior_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                        p_prior_grade_or_level ,
                        'Maximum Basic Pay',p_prior_effective_date);
       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
          (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
             or p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37712_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
    else
    if p_prior_pay_plan = 'FM' and
       p_prior_pay_rate_det_code in ('0','7') then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                        p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                        'Minimum Basic Pay',p_prior_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                        p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                        'Maximum Basic Pay',p_prior_effective_date);
       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
          (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
             or p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37712_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
    end if;
end if;
/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
570.29.2  If prior pay plan is DR,
          And prior pay rate determinant is 0 or 7,
          Then prior basic pay must be within the range for the
          prior grade and prior pay rate determinant on Table 28
          or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.
if p_prior_pay_plan = 'DR' and
   p_prior_pay_rate_det_code in ('0','7') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 28',
                    p_prior_grade_or_level ,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 28',
                    p_prior_grade_or_level ,
                    'Maximum Basic Pay',p_prior_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
      or p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_38405_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
570.30.2  If prior pay plan is DR,
          And prior pay rate determinant is 5 or 6,
          Then prior basic pay must be within the range for the
          prior grade and prior pay rate determinant on Table 29
          or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.
if p_prior_pay_plan = 'DR' and
   p_prior_pay_rate_det_code in ('5','6') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 29',
                    p_prior_grade_or_level ,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 29',
                    p_prior_grade_or_level ,
                    'Maximum Basic Pay',p_prior_effective_date);
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
      or p_prior_basic_pay is null or  to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_38406_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/*570.31.2  If prior pay plan is NY,
          Then prior basic pay must be within the range on
          Table 26 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_prior_pay_plan = 'NY' then
       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 26',
                        p_prior_grade_or_level ,
                       'Minimum Basic Pay',p_prior_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 26',
                        p_prior_grade_or_level ,
                        'Maximum Basic Pay',p_prior_effective_date);
       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
          (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
          or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37714_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;
/*570.32.2  If prior pay plan is NX,
          Then prior basic pay must be within the range for the
          prior grade on Table 27 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_prior_pay_plan = 'NX' then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 27',
                        p_prior_grade_or_level ,
                        'Minimum Basic Pay',p_prior_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 27',
                        p_prior_grade_or_level ,
                        'Maximum Basic Pay',p_prior_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
          (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
          or p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37715_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

/*570.37.2  If prior pay plan is FC,
          And prior pay rate determinant is not C,
          Then Prior Basic Pay must be within the range for prior
          grade on Table 8 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay. */
-- Update    Date         By       		Comments
-- 20/2    27-Feb-2003   Madhuri   	Modified the Requirement
--            			From	Then Prior Basic Pay must match the entry for the grade on Table 8 or be asterisks.
--           			to	Then Prior Basic Pay must be within the range for prior grade on Table 8 or be asterisks.
--
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_prior_pay_plan = 'FC' and
       p_prior_pay_rate_det_code <> 'C' then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 8',
                        p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                        'Minimum Basic Pay',p_prior_effective_date);

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 8',
                        p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                        'Maximum Basic Pay',p_prior_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
          (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
          or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37716_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;
/*570.43.2  If prior pay plan is AF, FO, or FP,
          And prior pay rate determinant is not C,
          Then prior basic pay must fall within the range for
          prior grade on Table 10 or be asterisks.
          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
if p_prior_pay_plan in ('AF','FO','FP') and
   p_prior_pay_rate_det_code <> 'C' then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 10',
                    p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 10',
                    p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                    'Maximum Basic Pay',p_prior_effective_date);
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay )
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37717_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 570.45.2  If prior pay plan is FA,
--           And agency/subelement is ST,
--           And prior pay rate determinant is 0,
--           And prior grade is 13 or 14,
--           Then prior basic pay must equal entry for the grade on
--           Table 7 or be asterisks.
--
--           Default:  Insert asterisks in prior pay basis and prior basic pay.

-- Update     Date        By  		Comments
-- 20/2    27-Feb-2003   Madhuri   	Modified the Requirement
--				from	And prior grade is 01 thru 04 or 13 or 14.
--				to	And prior grade is 13 or 14.
--         19-MAR-2003  NarasimhaRao    Changed the parameter from p_prior_grade_or_level
--                                      to p_prior_step_or_rate
 -- upd50  06-Feb-07	  Raju       From 01-Sep-2004	    Bug#5745356 delete Edit

if p_effective_date < to_date('2004/09/01','yyyy/mm/dd') then
    if p_prior_pay_plan = 'FA'  and
       p_agency_subelement = 'ST'  and
       p_prior_pay_rate_det_code = '0'  and
       p_prior_grade_or_level in ('13','14') then

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 7',
                                                      p_prior_step_or_rate,
                                                     'Maximum Basic Pay',
                                                      p_prior_effective_date);

       if max_basic_pay IS NOT NULL and
          (to_number(p_prior_basic_pay) <> max_basic_pay
          or p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37718_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

/*570.53.2  If prior pay plan is GS,
          And prior pay rate determinant is 5, 6, or M,
          Then prior basic pay must be equal to or less than the
          entry for prior grade on Table 19 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
/*   Commenting the edit as per the Bug 3147737.
if p_prior_pay_plan = 'GS'  and
   p_prior_pay_rate_det_code in ('5','6','M')  then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 19',
                                                 p_prior_grade_or_level,
                                                 'Maximum Basic Pay',
                                                 p_prior_effective_date);

   if max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) <= max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37720_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
--570.38.2
-- Update     Date        By        Effective Date   Comment
 --   9/5      08/12/99   vravikan   01-Apr-99       New Edit
If prior pay plan is NC, And prior pay rate determinant is 0, 5, 6, or 7,
 Then prior basic pay must be within the range for the prior grade on Table 44
or Table 45 (depending on prior pay rate determinant).  If prior pay rate determinant
 is 0 or 7 then compare to table 44.  If prior pay rate determinant is 5 or 6
then compare to table 45.


if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
  if p_prior_pay_plan = 'NC' then
    if p_prior_pay_rate_det_code in ('0','7')
then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 44',
                    p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 44',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);
   elsif p_prior_pay_rate_det_code in ('5','6')  then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 45',
                    p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 45',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);

end if;
end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37074_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
--570.39.2
-- Update     Date        By        Effective Date   Comment
 --   9/5      08/12/99   vravikan   01-Apr-99       New Edit

If prior pay plan is NO, And prior pay rate determinant is 0, 5, 6, or 7,
 Then prior basic pay must be within the range for the prior grade on
Table 46 or Table 47 (depending on prior pay rate determinant).
If prior pay rate determinant is 0 or 7 then compare to table 46.
  If prior pay rate determinant is 5 or 6 then compare to table 47.

if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
  if p_prior_pay_plan = 'NO' then
    if p_prior_pay_rate_det_code in ('0','7')
then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 46',
                    p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 46',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);
   elsif p_prior_pay_rate_det_code in ('5','6')  then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 47',
                    p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 47',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);

end if;
end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37075_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/
/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
--570.40.2
-- Update     Date        By        Effective Date   Comment
 --   9/5      08/12/99   vravikan   01-Apr-99       New Edit

If prior pay plan is NP, And prior pay rate determinant is 0, 5, 6, or 7,
Then prior basic pay must be within the range for the prior grade on Table 48
 or Table 49 (depending on prior pay rate determinant).
 If prior pay rate determinant is 0 or 7 then compare to table 48.
If prior pay rate determinant is 5 or 6 then compare to table 49.

if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
  if p_prior_pay_plan = 'NP' then
    if p_prior_pay_rate_det_code in ('0','7')
then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 48',
                    p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 48',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);
   elsif p_prior_pay_rate_det_code in ('5','6')  then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 49',
                    p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 49',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);

end if;
end if;

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37076_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/
/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
--570.41.2
-- Update     Date        By        Effective Date   Comment
 --   9/5      08/12/99   vravikan   01-Apr-99       New Edit

If prior pay plan is NR, And prior pay rate determinant is 0, 5, 6, or 7,
 Then prior basic pay must be within the range for the prior grade on
 Table 50 or Table 51 (depending on prior pay rate determinant).
 If prior pay rate determinant is 0 or 7 then compare to table 50.
 If prior pay rate determinant is 5 or 6 then compare to table 51.


if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
  if p_prior_pay_plan = 'NR' then
    if p_prior_pay_rate_det_code in ('0','7')
then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 50',
                    p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 50',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);
   elsif p_prior_pay_rate_det_code in ('5','6')  then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 51',
                    p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 51',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);

end if;
end if;

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37077_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/
/*570.56.2  If prior pay plan is GM,
          And prior pay rate determinant is 5, 6, or M,
          Then prior basic pay must fall within the range for the
          prior grade on Table 20 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
/* Commented as per the bug 3147737

if p_prior_pay_plan = 'GM' and
   p_prior_pay_rate_det_code in ('5', '6', 'M') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                    p_prior_grade_or_level,
                    'Minimum Basic Pay',p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                    p_prior_grade_or_level,
                    'Maximum Basic Pay',p_prior_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37721_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/
/*570.60.2  If prior pay plan is AL,
          And prior pay rate determinant is not C,
          Then prior basic pay must match the entry for the prior
          grade and prior step or rate on Table 22 or be
          asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.
          Basis for Edit:  5 U.S.C. 5372 */

if p_prior_pay_plan = 'AL' and
   p_prior_pay_rate_det_code <> 'C'  then

  if p_prior_grade_or_level in ('01', '02') then
     max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 22',
                      p_prior_grade_or_level,
                      'Minimum Basic Pay',
                      p_prior_effective_date);
  else
     max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 22',
                      p_prior_grade_or_level || '-' || p_prior_step_or_rate,
                      'Minimum Basic Pay',
                      p_prior_effective_date);
  end if;

   if max_basic_pay IS NOT NULL and
      (to_number(p_prior_basic_pay) <> max_basic_pay
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37722_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/*570.65.2  If prior pay plan is CA,
          And prior pay rate determinant is not C,
          Then prior basic pay must match the entry on Table 23
          for the prior grade or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.

          Basis for Edit:  5 U.S.C. 5372a*/
if p_prior_pay_plan = 'CA' and
   p_prior_pay_rate_det_code <> 'C' then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 23',
                    p_prior_grade_or_level,
                   'Minimum Basic Pay',p_prior_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (to_number(p_prior_basic_pay) <> max_basic_pay
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37723_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/*570.70.2  If prior pay plan is SL or ST,
          And prior pay rate determinant is not C,
          Then prior basic pay must be within the range in
          Table 21 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.
          Basis for Edit:  5 U.S.C. 5376*/

-- Upd57  30-Jul-09       Mani       Bug # 8653515 Added PRD D in the condition

IF p_effective_date >=  to_date('2008/10/14','RRRR/MM/DD') then --Bug#8653515
  if p_prior_pay_plan in ('ST', 'SL') and
   p_prior_pay_rate_det_code NOT IN ('C','D') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                    p_prior_pay_plan ,
                    'Minimum Basic Pay',p_prior_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                    p_prior_pay_plan ,
                    'Maximum Basic Pay',p_prior_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37724_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PRD','not C or D');
      hr_utility.raise_error;
   end if;
  end if;
ELSE
  if p_prior_pay_plan in ('ST', 'SL') and
   p_prior_pay_rate_det_code <> 'C' then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                    p_prior_pay_plan ,
                    'Minimum Basic Pay',p_prior_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                    p_prior_pay_plan ,
                    'Maximum Basic Pay',p_prior_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37724_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PRD','not C');
      hr_utility.raise_error;
   end if;
  end if;
end if;

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
570.71.2  If prior pay plan is ND,
          And prior pay rate determinant is 0, 5, 6, or 7,
          Then prior basic pay must be within the range for the
          prior grade on Table 30 or Table 31 (depending on prior
          pay rate determinant) or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.

-- added extra if for bug 726125
if p_prior_pay_plan = 'ND' and
   p_prior_pay_rate_det_code in ('0','5','6','7') then
   if p_prior_pay_rate_det_code in ('0','7') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 30',
                                                    p_prior_grade_or_level ,
                                                   'Minimum Basic Pay',
                                                    p_prior_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 30',
                                                    p_prior_grade_or_level ,
                                                    'Maximum Basic Pay',
                                                    p_prior_effective_date);
   elsif p_prior_pay_rate_det_code in ('5','6') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 31',
                                                    p_prior_grade_or_level ,
                                                    'Minimum Basic Pay',
                                                    p_prior_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 31',
                                                    p_prior_grade_or_level ,
                                                    'Maximum Basic Pay',
                                                    p_prior_effective_date);
   end if;

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
         or p_prior_basic_pay is null
      then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_38407_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
     end if;
   end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
570.72.2  If prior pay plan is NG,
          And prior pay rate determinant is 0, 5, 6, or 7,
          Then prior basic pay must be within the range for the
          prior grade on Table 32 or Table 33 (depending on prior
          pay rate determinant) or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.

-- added extra if for bug 726125
if p_prior_pay_plan = 'NG' and
   p_prior_pay_rate_det_code in ('0','5','6','7') then
   if p_prior_pay_rate_det_code in ('0','7') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 32',
                                                     p_prior_grade_or_level ,
                                                    'Minimum Basic Pay',
                                                     p_prior_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 32',
                                                    p_prior_grade_or_level ,
                                                    'Maximum Basic Pay',
                                                    p_prior_effective_date);
   elsif p_prior_pay_rate_det_code in ('5','6') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 33',
                                                     p_prior_grade_or_level ,
                                                     'Minimum Basic Pay',
                                                     p_prior_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 33',
                                                     p_prior_grade_or_level,
                                                     'Maximum Basic Pay',
                                                     p_prior_effective_date);
   end if;

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
         or p_prior_basic_pay is null)
      then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_38408_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
570.73.2  If prior pay plan is NT,
          And prior pay rate determinant is 0, 5, 6, or 7,
          Then prior basic pay must be within the range for the
          prior grade on Table 34 or Table 35 (depending on prior
          pay rate determinant) or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.

if p_prior_pay_plan = 'NT' and
   p_prior_pay_rate_det_code in ('0','5','6','7') then -- added for bug 726125
   if p_prior_pay_rate_det_code in ('0','7') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 34',
                       p_prior_grade_or_level ,'Minimum Basic Pay',p_prior_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 34',
                       p_prior_grade_or_level ,'Maximum Basic Pay',p_prior_effective_date);
   elsif p_prior_pay_rate_det_code in ('5','6') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 35',
                       p_prior_grade_or_level ,'Minimum Basic Pay',p_prior_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 35',
                       p_prior_grade_or_level ,'Maximum Basic Pay',p_prior_effective_date);
   end if;

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
         or p_prior_basic_pay is null)
      then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_38409_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if;
*/

/* Commented -- Dec 2001 Patch
570.75.2  If prior pay plan is TP,
          And prior pay basis is SY,
          Then prior basic pay must be within the range on
          Table 24 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.
if p_prior_pay_plan = 'TP' and
   p_prior_pay_basis = 'SY'  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 24',
                                                 p_prior_pay_plan ,
                                                 'Minimum Basic Pay',
                                                 p_prior_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 24',
                                                 p_prior_pay_plan ,
                                                 'Maximum Basic Pay',
                                                 p_prior_effective_date);
   if max_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37725_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/*570.82.2  If prior pay plan is GG,
          And prior grade is SL,
          And prior pay rate determinant is 0,
          Then prior basic pay must be within the range on
          Table 21 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
if p_prior_pay_plan = 'CG' and
   p_prior_pay_rate_det_code = '0' and
   p_prior_grade_or_level = 'SL'  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                                                 p_prior_pay_plan ,
                                                 'Minimum Basic Pay',
                                                 p_prior_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                                                 p_prior_pay_plan ,
                                                 'Maximum Basic Pay',
                                                 p_prior_effective_date);
   if max_basic_pay IS NOT NULL and min_basic_pay is not null and
      (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
      or p_prior_basic_pay is null and to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37727_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/*570.83.2  If prior pay plan is IJ,
          And prior pay rate determinant is 0 or 7,
          Then prior basic pay must match the entry for the prior
          step or rate on Table 36 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_prior_pay_plan = 'IJ' and
       p_prior_pay_rate_det_code in ('0','7') then

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 36',
                                                     p_prior_step_or_rate ,
                                                     'Maximum Basic Pay',
                                                     p_prior_effective_date);
       if max_basic_pay IS NOT NULL and
          (not(to_number(p_prior_basic_pay) <> max_basic_pay)
          or p_prior_basic_pay is null)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_38410_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

/*570.84.2  If prior pay plan is GG,
          And prior grade is 01 through 15,
          And prior pay rate determinant is 2, 3, 4, J, K, or R,
          Then prior basic pay must be equal to or exceed the
          minimum for prior grade on Table 2 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
-- Bug# 9255822 added PRD Y

if p_prior_pay_plan = 'CG'  and
   p_prior_grade_or_level between '01' and '15'  and
   p_prior_pay_rate_det_code in ('2','3','4','J','K','R','Y') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 2',
                                                  p_prior_grade_or_level||'-'||p_prior_step_or_rate ,
                                                  'Minimum Basic Pay',
                                                  p_prior_effective_date);
   if min_basic_pay IS NOT NULL and
      (not(to_number(p_prior_basic_pay) >= min_basic_pay)
      or p_prior_basic_pay is null or to_number(p_prior_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37728_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/*570.86.2  If prior pay plan is GH,
          And prior pay rate determinant is 0 or 7,
          Then prior basic pay must be within the range for the
          appropriate prior grade on Table 3 or be asterisks.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_prior_pay_plan = 'GH' and
       p_prior_pay_rate_det_code in ('0','7')  then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                     p_prior_grade_or_level||'-'||p_prior_step_or_rate ,
                                                     'Minimum Basic Pay',
                                                     p_prior_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                     p_prior_grade_or_level||'-'||p_prior_step_or_rate ,
                                                     'Maximum Basic Pay',
                                                     p_prior_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
          (not(to_number(p_prior_basic_pay) between min_basic_pay and max_basic_pay)
          or p_prior_basic_pay is null
          or to_number(p_prior_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37729_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;
end chk_prior_basic_pay;
--
--
-- Name: Locality Adjustment
/* Table 25 contains up to a maximum of 3 percentages.
   The locality adjustment amount will pass the lookup if, as a percentage of basic pay,
   it represents any percentage shown for the locality area, with the "as of date" of the
   file falling within the date range, on Table 25.  (If a more percise check is needed,
   as is the case of area 41, a subsequent relationship edit will catch the error.)
   Locality pay is generated within CPDF according to the duty station.  For definitions,
   see the Guide to Personnel Data Standards. */
--
--
procedure chk_locality_adj
  (p_to_pay_plan			            in    varchar2
  ,p_to_basic_pay                         in    varchar2
  ,p_pay_rate_determinant_code		in	varchar2
  ,p_retained_pay_plan				in	varchar2
  ,p_prior_pay_plan                       in    varchar2
  ,p_prior_pay_rate_det_code		      in	varchar2	/* Non-SF52 Data Item */
  ,p_locality_pay_area				in	varchar2	/* Non-SF52 Data Item */
  ,p_to_locality_adj				in	varchar2
  ,p_effective_date				in	date
  ,p_as_of_date                           in    date            /* Non-SF52 */
  ,p_first_noac_lookup_code               in    varchar2
  ,p_agency_subelement                    in    varchar2
  ,p_duty_station_Code                    in    varchar2
  ,p_special_pay_table_id                 in    varchar2 --Bug# 5745356(upd50)
  ) is
  l_lpa_area	       	     ghr_locality_pay_areas_f.locality_pay_area_code%type;
  l_lpa_pct		                 ghr_locality_pay_areas_f.adjustment_percentage%type;
  l_leo_pct                        ghr_locality_pay_areas_f.leo_adjustment_percentage%type;
  l_lpa_effective_start_date       ghr_locality_pay_areas_f.effective_start_date%type;
  l_lpa_effective_end_date         ghr_locality_pay_areas_f.effective_end_date%type;
  l_lpa_pct_max 	     		     ghr_locality_pay_areas_f.adjustment_percentage%type;
  l_lpa_pct_min		           ghr_locality_pay_areas_f.adjustment_percentage%type;
  l_effective_date                 date;
  l_pay_table				VARCHAR2(4); --Bug# 5745356(upd50)
  l_table5_value		number(10,2); --Bug# 8309414

  CURSOR c1 is
         SELECT effective_start_date, effective_end_date,
                NVL(adjustment_percentage,0),
                NVL(leo_adjustment_percentage,0)
	   FROM   ghr_locality_pay_areas_f
	   WHERE  locality_pay_area_code = p_locality_pay_area
           AND  trunc(l_effective_date) between effective_start_date
                                            and nvl(effective_end_date, l_effective_date);

begin
 IF p_first_noac_lookup_code = '866' THEN
    l_effective_date := p_effective_date + 1;
 ELSE
    l_effective_date := p_effective_date;
  END IF;

  open c1;
  fetch c1 into l_lpa_effective_start_date, l_lpa_effective_end_date,
                l_lpa_pct, l_leo_pct;
  close c1;
  l_table5_value:= GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 5',
                          '04' ,
                          'Maximum Basic Pay',p_effective_date);
--
-- 27-jul-98
-- all the edits where the locality adj as a percentage of basic pay was being compared
-- to the lpa_pct has been modified to include leo_pct.
-- bug #703978
--

/*
-- This edit is DELETED as per update 8 of the edit manual.
-- commented out for delete by skutteti on 12-oct-1998
--
-- 652.05.2
  if ( p_locality_pay_area in ('02','05','08','11','14','15','17','20','23','26','29','32','35',
       '38','41','42','43','45','47','55','56','57','58','59','62','71','74','77','80','88','98')) then
     if ((trunc(p_effective_date) not between l_lpa_effective_start_date and
            				          nvl(l_lpa_effective_end_date, p_effective_date)) and
        (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0)) then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37730_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
     end if;
  end if;
*/


-- 652.10.1
--  'p_as_of_date' has been determined to be effective date.
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition 'And locality pay area is 02 through 88'
---			  	To:'And locality pay area is other than ZY or ZZ' as of 09-JAN-2005
--  Raju    	  08-Nov-2005	 UPD 42(Bug 4567571) Delete PRD 3,J and K as of 01-May-2005
-- amrchakr       28-Sep-2006    Remove locality pay area 'ZY' effective 01-jul-2006
-- Raju           28-Jan-2010    Commenting the below edit since 652.10.1 and 652.10.2 are same bug# 9309565
-------------------------------------------------------------------------------
/*
IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy')) THEN
	if (
	p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
	p_pay_rate_determinant_code in ('0','3','7','J','K') and
	p_locality_pay_area between '02' and '88' and
	(p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null and to_number(p_to_basic_pay) <> 0)
     ) then
	if (
	    l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
	    l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37731_ALL_PROCEDURE_FAIL');
	    --hr_utility.set_message_token('LOC_PAY','02 through 88');
	    hr_utility.raise_error;
     end if;
  end if;
ELSIF ( p_effective_date < to_date('01/05/2005', 'dd/mm/yyyy')) THEN
 if (
	p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
	p_pay_rate_determinant_code in ('0','3','7','J','K') and
	p_locality_pay_area NOT IN ('ZY','ZZ') and
	(p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null and to_number(p_to_basic_pay) <> 0)
     ) then
	if (
	    l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
	    l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_38928_ALL_PROCEDURE_FAIL ');
		hr_utility.set_message_token('PRD_LIST','0, 3, 7, J, or K');
		hr_utility.raise_error;
    end if;
 end if;

 ELSIF (( p_effective_date >= to_date('01/05/2005', 'dd/mm/yyyy'))
       AND
	( p_effective_date < to_date('01/07/2006', 'dd/mm/yyyy'))
       )
       THEN
 if (
	p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
	p_pay_rate_determinant_code in ('0','7') and
	p_locality_pay_area NOT IN ('ZY','ZZ') and
	(p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null and to_number(p_to_basic_pay) <> 0)
     ) then
	if (
	    l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
	    l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	   hr_utility.set_message(8301,'GHR_38928_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PRD_LIST','0, or 7');
		hr_utility.raise_error;
    end if;
 end if;

 ELSIF ( p_effective_date >= to_date('01/07/2005', 'dd/mm/yyyy'))
 AND   ( p_effective_date < to_date('13/08/2007', 'dd/mm/yyyy'))  THEN

     if (
        p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
        p_pay_rate_determinant_code in ('0','7') and
        p_locality_pay_area NOT IN ('ZZ') and
        (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
        (p_to_basic_pay is not null and to_number(p_to_basic_pay) <> 0)
         )
           then
           if (
            l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
            l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
           ) then
           GHR_GHRWS52L.CPDF_Parameter_Check;
           hr_utility.set_message(8301,'GHR_37694_ALL_PROCEDURE_FAIL');
               hr_utility.raise_error;
           end if;
     end if;
 ELSE
    if (
        p_to_pay_plan in ('GS','GM','GG','GH','GL','FO','FP') and
        p_pay_rate_determinant_code in ('0','7') and
        p_locality_pay_area NOT IN ('ZZ') and
        (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
        (p_to_basic_pay is not null and to_number(p_to_basic_pay) <> 0)
         )
           then
           if (
              (l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
               l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) ) OR
              (round(to_number(p_to_locality_adj)+to_number(p_to_basic_pay)) > l_table5_value)
              ) then
           GHR_GHRWS52L.CPDF_Parameter_Check;
           hr_utility.set_message(8301,'GHR_37456_ALL_PROCEDURE_FAIL');
               hr_utility.raise_error;
           end if;
     end if;

END IF;
*/
-------------------------------------------------------------------------------

-- 652.10.2
/*  'p_as_of_date' has been determined to be effective date' */
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition 'And locality pay area is 02 through 88'
---			  	To:'And locality pay area is other than ZY or ZZ' as of 09-JAN-2005
--  Raju    	  08-Nov-2005	 UPD 42(Bug 4567571) Delete PRD 3,J and K as of 01-May-2005
--  amrchakr      28-sep-2006    Remove locality pay area 'ZY' effective 01-jul-2006
-- UPD 56  8309414       Raju       From 13-Aug-07
-------------------------------------------------------------------------------
IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy')) THEN
	if (
	p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
	p_pay_rate_determinant_code in ('0','3','7','J','K') and
        p_locality_pay_area between '02' and '88' and
      (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
     ) then
	if (l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
          l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37747_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
     end if;
  end if;
ELSIF ( p_effective_date < to_date('01/05/2005', 'dd/mm/yyyy')) THEN
	if (
	p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
	p_pay_rate_determinant_code in ('0','3','7','J','K') and
	p_locality_pay_area NOT IN ('ZY','ZZ') and
      (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
     ) then
	if (l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
          l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_38929_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PRD_LIST','0, 3, 7, J, or K');
	    hr_utility.raise_error;
     end if;
  end if;

  ELSIF (( p_effective_date >= to_date('01/05/2005', 'dd/mm/yyyy'))
        AND
	 ( p_effective_date < to_date('01/07/2006', 'dd/mm/yyyy'))
	)
	THEN
	if (
	p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
	p_pay_rate_determinant_code in ('0','7') and
	p_locality_pay_area NOT IN ('ZY','ZZ') and
      (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
     ) then
	if (l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
          l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_38929_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PRD_LIST','0, or 7');
	    hr_utility.raise_error;
     end if;
  end if;

  ELSIF ( p_effective_date >= to_date('01/07/2006', 'dd/mm/yyyy'))
    AND   ( p_effective_date < to_date('13/08/2007', 'dd/mm/yyyy'))  THEN
	if (
	p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
	p_pay_rate_determinant_code in ('0','7') and
	p_locality_pay_area NOT IN ('ZZ') and
      (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
     ) then
	if (l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
          l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37695_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
     end if;
  end if;
ELSE
    if (p_to_pay_plan in ('GS','GM','GG','GL','GH','FO','FP') and
	p_pay_rate_determinant_code in ('0','7') and
	p_locality_pay_area NOT IN ('ZZ') and
      (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
     ) then
	if ((l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
             l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) ) OR
            (round(to_number(p_to_locality_adj)+to_number(p_to_basic_pay)) > l_table5_value)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37457_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
     end if;
  end if;
END IF;
-------------------------------------------------------------------------------
-- 652.15.1
       /* If pay plan is GS, GM, GG, or GH,
          And pay rate determinant is 5, 6, E, F, or M,
          And locality pay area is 02 through 88,
          Then the locality adjustment amount may not be spaces
          or an amount greater than the highest percentage
          present and currently valid for the locality pay area
          on Table 25.

          Default:  Insert asterisks in locality adjustment. */

   --  'p_as_of_date' has been determined to be effective_date.
   --  Adds pay rate determinants E and F effective 01-mar-1998
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition 'And locality pay area is 02 through 88'
---			  	To:'And locality pay area is other than ZY or ZZ' as of 09-JAN-2005
--  Raju		  31/1/06		 Commented the code effective from 01-May-2005
-- upd50  06-Feb-07	  Raju       From 01-Oct-2006	    Bug#5745356
-------------------------------------------------------------------------------
IF  p_effective_date < fnd_date.canonical_to_date('1998/03/01')  then
      if (
	   p_to_pay_plan in ('GS','GM','GG','GH') and
         p_pay_rate_determinant_code in ('6','5','M') and
         p_locality_pay_area between '02' and '88' and
         (p_to_locality_adj is not null or to_number(p_to_locality_adj) <> 0) and
         (p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
          ) then
         if (
              l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
              l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
            ) then
            GHR_GHRWS52L.CPDF_Parameter_Check;
            hr_utility.set_message(8301,'GHR_37732_ALL_PROCEDURE_FAIL');
	      hr_utility.raise_error;
         end if;
      end if;
ELSE --- meaning effective_date is greater than '1998/03/01'
     -- this check is for dates from 01-MAR-1998 to 08-JAN-2005

   IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy') ) THEN
	 if (p_to_pay_plan in ('GS','GM','GG','GH') and
		 p_pay_rate_determinant_code in ('6','5','M','E','F') and
		 p_locality_pay_area between '02' and '88' and
		 (p_to_locality_adj is not null or to_number(p_to_locality_adj) <> 0) and
		 (p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
		 ) then
		 if (
				 l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
			 l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
				) then
			GHR_GHRWS52L.CPDF_Parameter_Check;
				hr_utility.set_message(8301,'GHR_37868_ALL_PROCEDURE_FAIL');
			hr_utility.raise_error;
			 end if;
	 end if;
	 -- FWFA Changes
   ELSIF ( p_effective_date < to_date('01/05/2005', 'dd/mm/yyyy') ) THEN
		if (
		   p_to_pay_plan in ('GS','GM','GG','GH') and
			   p_pay_rate_determinant_code in ('6','5','M','E','F') and
		   p_locality_pay_area NOT IN ('ZY','ZZ') and
			  (p_to_locality_adj is not null or to_number(p_to_locality_adj) <> 0) and
			  (p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
				) then

			  if (
					l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
					l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
					 ) then
					 GHR_GHRWS52L.CPDF_Parameter_Check;
				 hr_utility.set_message(8301,'GHR_38930_ALL_PROCEDURE_FAIL');
			 hr_utility.raise_error;
			  end if;
		end if;
	-- Begin Bug# 4999292 and 4917098
	/*ELSE
		if	(p_to_pay_plan in ('GS','GM','GG','GH') and
			 p_pay_rate_determinant_code in ('6','5','E','F')
			) then

			  if to_number(p_to_locality_adj) <= 0 then
				GHR_GHRWS52L.CPDF_Parameter_Check;
				hr_utility.set_message(8301,'GHR_38981_ALL_PROCEDURE_FAIL');
				hr_utility.raise_error;
			  end if;
		end if;*/
	-- End Bug# 4999292 and 4917098
		-- FWFA Changes
   ELSIF ( p_effective_date < to_date('01/10/2006', 'dd/mm/yyyy') ) THEN
        l_pay_table := SUBSTR(ghr_pay_calc.get_user_table_name(p_special_pay_table_id),1,4);
        if	(p_to_pay_plan in ('GS','GM','GG','GH') and
             p_pay_rate_determinant_code in ('6','5','E','F') and
             l_pay_table <> '0491'
            ) then

              if to_number(p_to_locality_adj) <= 0 then
                GHR_GHRWS52L.CPDF_Parameter_Check;
                hr_utility.set_message(8301,'GHR_38981_ALL_PROCEDURE_FAIL');
                hr_utility.raise_error;
              end if;
        end if;

   END IF; -- less or greater then 09-JAN-05 check
END IF;
-------------------------------------------------------------------------------

-- 652.15.2
       /* If pay plan = GS, GM, GG, GH, FO, or FP,
          And PRD = 6, 5, or M,
          And locality pay area is not 99,
          Then the locality adjustment amount may not be greater
          than the highest percentage on Table 25 for the area,
          valid as of the effective date.

          Default:  Insert asterisks in locality adjustment.

          Basis for Edit:  5 U.S.C. 5304
         'p_as_of_date' has been determined to be effective date. */
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition 'And locality pay area is 02 through 88'
---			  	To:'And locality pay area is other than ZY or ZZ' as of 09-JAN-05
--  utokachi      10/21/05       Validate for actions after 01-MAY-2005
--  Raju		  31/1/06		 Commented the code effective from 01-May-2005
-------------------------------------------------------------------------------
IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy') ) THEN
	if (
	p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
	p_pay_rate_determinant_code in ('6','5','M') and
        p_locality_pay_area between '02' and '88' and
      (p_to_locality_adj is not null or to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
     ) then
	if (
          l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
          l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37748_ALL_PROCEDURE_FAIL');
	   hr_utility.raise_error;
     end if;
  end if;
 -- FWFA Changes
ELSIF ( p_effective_date < to_date('01/05/2005', 'dd/mm/yyyy') ) THEN
if (
	p_to_pay_plan in ('GS','GM','GG','GH','FO','FP') and
	p_pay_rate_determinant_code in ('6','5','M') and
	p_locality_pay_area NOT IN ('ZY','ZZ') and
      (p_to_locality_adj is not null or to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
     ) then
	if (
          l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
          l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_38931_ALL_PROCEDURE_FAIL');
	   hr_utility.raise_error;
     end if;
  end if;
  -- Begin Bug# 4999292
  /*ELSIF ( p_effective_date >= to_date('01/05/2005', 'dd/mm/yyyy') ) THEN
  if (
	p_to_pay_plan in ('GS','GM','GG','GH') and
	p_pay_rate_determinant_code in ('6','5') ) then
	if (to_number(p_to_locality_adj) <= 0 ) then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_38982_ALL_PROCEDURE_FAIL');
	   hr_utility.raise_error;
     end if;
  end if;*/
  -- End Bug# 4999292
  -- FWFA Changes
END IF;
-------------------------------------------------------------------------------
-- 652.20.3
-- Update   Date   	    By                    Comments
-- 21/2    20-Feb-2003     Madhuri  		Adding HS to other than list
--         30-OCT-2003     Ashley               Commented second condition
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition "If Locality Pay Area is 99"
---				 To: If locality pay area is ZZ as of 09-JAN-05
--  utokachi      10/24/05       Validate for actions after 01-MAY-2005
--  Raju		  26-Jun-06      Validate for actions after 01-Jan-2006
--                                and added pay plan condition affective frm 01-Apr-06
--  arbasu        26-Oct-06      Added PRD condition for GHR_38932_ALL_PROCEDURE_FAIL
-------------------------------------------------------------------------------
IF p_effective_date < fnd_date.canonical_to_date('1998/09/01') then
      if (p_locality_pay_area = '99' and
         (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0)) then
         GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37733_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
      end if;
ELSE -- meaning bet 01-SEP-1998 to 01-JAN-2005
   IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy') ) THEN
     --  If locality pay area is 99, And agency is other than AM, GY, HS, IB, or ST
     --  Then locality adjustment must be spaces or asterisks.
       if  p_locality_pay_area = '99' and
           p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0
       then
	    hr_utility.set_message(8301,'GHR_37896_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
       end if;
  --FWFA Changes
   ELSIF  p_effective_date < to_date('2005/05/01','YYYY/MM/DD') THEN
	--  If locality pay area is 99, And agency is other than AM, GY, HS, IB, or ST
	--  Then locality adjustment must be spaces or asterisks.
	  if  p_locality_pay_area = 'ZZ' and
	      p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0 and
          p_pay_rate_determinant_code  NOT IN ('6','E','F')
 	  then
	      hr_utility.set_message(8301,'GHR_38932_ALL_PROCEDURE_FAIL');
	      hr_utility.raise_error;
	  end if;
   ELSIF p_effective_date < to_date('2006/01/01','YYYY/MM/DD') THEN --Modified for Bug# 5073313
	  if  p_locality_pay_area = 'ZZ' and p_pay_rate_determinant_code  NOT in ('6','5','E','F')
	      AND p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0
 	  then
	      hr_utility.set_message(8301,'GHR_38978_ALL_PROCEDURE_FAIL');
	      hr_utility.raise_error;
	  end if;
   -- Begin Bug# 5073313
   elsif p_effective_date < fnd_date.canonical_to_date('2006/04/01') then
	  if substr(p_agency_subelement,1,2) not in ('HS') and p_locality_pay_area = 'ZZ' and
            p_pay_rate_determinant_code  NOT in ('6','5','E','F')
	      AND p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0
 	  then
	      hr_utility.set_message(8301,'GHR_37065_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','5, 6, E, or F');
	      hr_utility.raise_error;
	  end if;
   else
       if substr(p_agency_subelement,1,2) not in ('HS') and p_locality_pay_area = 'ZZ' and
            p_pay_rate_determinant_code  NOT in ('6','5','E','F')and
            p_to_pay_plan in ('GM','GS')
	      AND p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0
 	  then
	      hr_utility.set_message(8301,'GHR_37065_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','5, 6, E, or F, and pay plan is GM or GS');
	      hr_utility.raise_error;
	  end if;
   -- End Bug# 5073313
   END IF;
   -- FWFA Changes
END IF;
-------------------------------------------------------------------------------

--Commented as per EOY 2003 cpdf changes by Ashley
-- 652.21.3
-- Update   Date   	    By                    Comments
-- 21/2    20-Feb-2003     Madhuri  		Adding HS to the list
   --     If locality pay area is 99,
   --       And agency is AM, GY, HS, IB, or ST
   --       And either:
   --            The first two positions of duty station are other
   --            than CA or MX,
   --            Or pay plan is FO or FP,
   --       Then locality adjustment must be spaces or asterisks.

  /* if p_effective_date >= fnd_date.canonical_to_date('1998/09/01') then
      if  p_locality_pay_area = '99' and
          substr(p_agency_subelement,1,2) in ('AM','GY','HS','IB','ST') and
          (
           substr(p_duty_station_code,1,2) not in ('CA','MX') or
           p_to_pay_plan in ('FO','FP')
          ) and
          (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0) then
	    hr_utility.set_message(8301,'GHR_37897_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
      end if;
   end if;*/


-- 652.30.3
   -- Update     Date        By        Effective Date   Comment
   --   9        04/05/99    vravikan                   All pay plans starting with W but not 'WM'
   -- 20/2      20-Feb-2003  Madhuri    		Deleting pay plans EH and EI.
   --  UPD 41(Bug 4567571)   Raju	   08-Nov-2005		Adds pay plan ES and FE
   --  Raju    	  08-Nov-2005	 UPD 42(Bug 4567571) Delete PRD U and V as of 01-May-2005
   --  Upd57    30-Jul-09       Mani       Bug # 8653515 Added SL, ST in the condition from 12-Apr-2009

IF ( p_effective_date < to_date('01/05/2005', 'dd/mm/yyyy') ) THEN
  if (
	(
	 p_to_pay_plan in ('EX','ZZ','ES','FE') or
	 substr(p_to_pay_plan,1,1) in ('B','X') or
	 (substr(p_to_pay_plan,1,1) in ('W') and p_to_pay_plan not in ('WM') )
	) and
	 p_pay_rate_determinant_code not in ('A','B','E','F','S','U','V') and
	 (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0)
     ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37734_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PRD_LIST','A, B, E, F, S, U, or V');
		hr_utility.set_message_token('PP_LIST','EX, ES, FE or ZZ');
	    hr_utility.raise_error;
   end if;
ELSIF ( p_effective_date < to_date('12/04/2009', 'dd/mm/yyyy') ) THEN
	if (
	     ( p_to_pay_plan in ('EX','ZZ','ES','FE') or
	      substr(p_to_pay_plan,1,1) in ('B','X') or
	      (substr(p_to_pay_plan,1,1) in ('W') and p_to_pay_plan not in ('WM') )
	     ) and
	     p_pay_rate_determinant_code not in ('A','B','E','F','S') and
	     (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0)
       ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37734_ALL_PROCEDURE_FAIL');
	    hr_utility.set_message_token('PRD_LIST','A, B, E, F, or S');
 	    hr_utility.set_message_token('PP_LIST','EX, ES, FE or ZZ');
	    hr_utility.raise_error;
   end if;
ELSE
	if (
	     ( p_to_pay_plan in ('EX','ZZ','ES','FE','SL','ST') or
	      substr(p_to_pay_plan,1,1) in ('B','X') or
	      (substr(p_to_pay_plan,1,1) in ('W') and p_to_pay_plan not in ('WM') )
	     ) and
	     p_pay_rate_determinant_code not in ('A','B','E','F','S') and
	     (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0)
       ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37734_ALL_PROCEDURE_FAIL');
  	    hr_utility.set_message_token('PRD_LIST','A, B, E, F, or S');
 	    hr_utility.set_message_token('PP_LIST','EX, ES, FE, SL, ST or ZZ');
	    hr_utility.raise_error;
   end if;
END IF;

-- 652.35.3
-- upd49  19-Jan-07	  Raju       From 01-Apr-2004	    Bug#5619873 Terminate the Edit
 IF p_effective_date < to_date('01/04/2004', 'dd/mm/yyyy') THEN
    if (
    p_pay_rate_determinant_code = 'C' and
    (p_to_locality_adj is not null and to_number(p_to_locality_adj) <> 0)
     ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37735_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    end if;
 END IF;
-- 652.45.1
--            12/8/00   vravikan    From the Start        Remove GH and GM
--            19/03/04  Madhuri     Raise edit error only if the NOAC is not 817
--
-- Modified EDIT for Student Loan Repayment
-- The to Basic Pay will be NULL for 817 action, so this edit will be fired
-- Checking for NOAC 817 before firing edit
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition 'And locality pay area is 02 through 88'
---			  	To:'And locality pay area is other than ZY or ZZ' as of 09-JAN-05
--  Raju    	  08-Nov-2005	 UPD 42(Bug 4567571) Delete PRD U and V as of 01-May-2005
--  amrchakr      28-sep-2006   Change the edit no. from 652.45.1 to 652.45.3
--                              And remove the lacality pay area 'ZY' effective 01-jul-2006
--  Raju          24-Jan-2007   Change the edit no. from 652.45.3 to 652.45.1 eff from 01-Sep-2006
-- UPD 56  8309414       Raju       From start            Remove PRD E and F
-------------------------------------------------------------------------------
IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy') ) THEN
   if (	p_retained_pay_plan in ('GS','GG') and
	    p_pay_rate_determinant_code in ('A','B','U','V') and
	    p_locality_pay_area between '02' and '88' and
        (p_to_locality_adj is null) ) and
        ( p_first_noac_lookup_code <> '817' )
     then
        GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37736_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
   end if;

ELSIF ( p_effective_date < to_date('01/05/2005', 'dd/mm/yyyy') ) THEN
    if (p_retained_pay_plan in ('GS','GG') and
        p_pay_rate_determinant_code in ('A','B','U','V') and
        p_locality_pay_area NOT IN ('ZY','ZZ') and
        (p_to_locality_adj is null)) and
        ( p_first_noac_lookup_code <> '817' )
     then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_38933_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PRD_LIST','A, B, U, or V');
        hr_utility.raise_error;
    end if;

ELSIF ( p_effective_date >= to_date('01/05/2005', 'dd/mm/yyyy') ) AND
      ( p_effective_date < to_date('01/07/2006', 'dd/mm/yyyy') )  THEN
   if (	p_retained_pay_plan in ('GS','GG') and
		p_pay_rate_determinant_code in ('A','B') and
		p_locality_pay_area NOT IN ('ZY','ZZ') and
       (p_to_locality_adj is null))
      and ( p_first_noac_lookup_code <> '817' ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
       hr_utility.set_message(8301,'GHR_38933_ALL_PROCEDURE_FAIL');
	   hr_utility.set_message_token('PRD_LIST','A or B');
       hr_utility.raise_error;
   end if;

ELSIF ( p_effective_date >= to_date('01/07/2006', 'dd/mm/yyyy') ) THEN
   if (	p_retained_pay_plan in ('GS','GG') and
		p_pay_rate_determinant_code in ('A','B') and
		p_locality_pay_area NOT IN ('ZZ') and
       (p_to_locality_adj is null)) and
      ( p_first_noac_lookup_code <> '817' )
     then
       GHR_GHRWS52L.CPDF_Parameter_Check;
       if ( p_effective_date < to_date('01/09/2006', 'dd/mm/yyyy') ) THEN
           hr_utility.set_message(8301,'GHR_37696_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
       else
            hr_utility.set_message(8301,'GHR_37434_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
       end if;
   end if;

END IF;
-------------------------------------------------------------------------------

-- 652.60.1
/*  'p_as_of_date' has been determined to be effective date. */
-- NAME           EFFECTIVE      COMMENTS
-- Madhuri        21-JAN-2004    End Dating this edit as on 10-JAN-04
--				 For SES Pay Calculations
-- Madhuri        19-MAY-2004    Removing the pay plans ES, FE from the list
--
-- end dating the edit as on 10-JAN-2004
--
--- Bug # 8320557 Removed SL and ST pay plans
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition 'And locality pay area is 02 through 88'
---			  	To:'And locality pay area is other than ZY or ZZ' as of 09-JAN-05
--- NOT MODIFYING THIS EDIT as THE EDIT IS END DATED AS OF 11 JAN 04

-------------------------------------------------------------------------------
  if ( p_effective_date < to_date('2004/01/11', 'yyyy/mm/dd') and
	p_to_pay_plan in ('AL','CA') and
	p_locality_pay_area between '02' and '88' and
      (p_to_locality_adj is not null or to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
     ) then
	if (
	    l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
	    l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37737_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
     end if;
   end if;
-------------------------------------------------------------------------------

-- 652.60.2
/*  'p_as_of_date' has been detemined to be effective date.  */
-- Madhuri        21-JAN-2004    End Dating this edit as on 10-JAN-04
--				 For SES Pay Calculations
-- Madhuri        19-MAY-2004    Removing the pay plans ES, FE from the list
--
-- end dating the edit as on 10-JAN-2004
--- Bug # 8320557 Removed SL and ST pay plans
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition 'And locality pay area is 02 through 88'
---			  	To:'And locality pay area is other than ZY or ZZ' as of 09-JAN-05
--- NOT MODIFYING THIS EDIT as THE EDIT IS END DATED AS OF 11 JAN 04
-------------------------------------------------------------------------------
  if (p_effective_date < to_date('2004/01/11', 'yyyy/mm/dd') and
	p_to_pay_plan in ('AL','CA') and
        p_locality_pay_area between '02' and '88' and
      (p_to_locality_adj is not null or to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
      )
      then
	if (
	     l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
	     l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37749_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
     end if;
  end if;
-------------------------------------------------------------------------------
-- 652.75.1
  --  'p_as_of_date' has been determined to be effective date.
/*
  --
  --   Commented the edit for bug 557188 on 7-aug-98
  --
	if (
	p_to_pay_plan not in ('GS','GM') and
	p_pay_rate_determinant_code in ('A','B','E','F','U','V') and
	p_retained_pay_plan not in ('GS', 'GM') and
	p_locality_pay_area between '02' and '88' and
      (p_to_locality_adj is not null or to_number(p_to_locality_adj) <> 0) and
	(p_to_basic_pay is not null or to_number(p_to_basic_pay) <> 0)
       )
       then
	if (
           l_lpa_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2) and
           l_leo_pct < round((to_number(p_to_locality_adj)/to_number(p_to_basic_pay)*100),2)
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37738_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
     end if;
  end if;
*/

-- 652.80.1
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05     FROM: If the Locality pay area is 98,And pay rate determinant is 0, 3, 7, J, or K,
---			              Then the amount of the locality adjustment, as a percentage of basic pay, must fall within the range of the highest and lowest percentages on Table 25 for locality pay area 98, or be spaces or asterisks.
---				TO: If the locality pay area is ZY, And pay rate determinant is 0, 3, 7, J, or K,
---				    Then the amount of the locality adjustment, as a percentage of basic pay, must fall within the range of the highest and lowest percentages on Table 25 for locality pay area ZY, or be spaces or asterisks.
--  Raju    	  08-Nov-2005	 UPD 42(Bug 4567571) Delete PRD 3,J and K as of 01-May-2005
--  amrchakr      29-sep-2006    End dated the edit fron 01-jul-2006
-------------------------------------------------------------------------------
IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy') ) THEN
  if (
	p_locality_pay_area = '98' and
	p_pay_rate_determinant_code in ('0','3','7','J','K') and
        p_to_basic_pay is not null
     ) then
	if (
	   round(((nvl(to_number(p_to_locality_adj),0)/to_number(p_to_basic_pay))*100),2)
           not between l_lpa_pct and l_leo_pct
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    	hr_utility.set_message(8301,'GHR_37759_ALL_PROCEDURE_FAIL');
	    	hr_utility.raise_error;
	end if;
  end if;
ELSIF ( p_effective_date < to_date('01/05/2005', 'dd/mm/yyyy') ) THEN
  if (
	p_locality_pay_area = 'ZY' and
	p_pay_rate_determinant_code in ('0','3','7','J','K') and
        p_to_basic_pay is not null
     ) then
	if (
	   round(((nvl(to_number(p_to_locality_adj),0)/to_number(p_to_basic_pay))*100),2)
           not between l_lpa_pct and l_leo_pct
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    	hr_utility.set_message(8301,'GHR_38934_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('PRD_LIST','0, 3, 7, J, or K');
	    	hr_utility.raise_error;
	end if;
  end if;

ELSIF ( p_effective_date >= to_date('01/05/2005', 'dd/mm/yyyy') )
      AND
      ( p_effective_date < to_date('01/07/2006', 'dd/mm/yyyy') )
      THEN
  if (
	p_locality_pay_area = 'ZY' and
	p_pay_rate_determinant_code in ('0','7') and
        p_to_basic_pay is not null
     ) then
	if (
	   round(((nvl(to_number(p_to_locality_adj),0)/to_number(p_to_basic_pay))*100),2)
           not between l_lpa_pct and l_leo_pct
	   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    	hr_utility.set_message(8301,'GHR_38934_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('PRD_LIST','0, or 7');
	    	hr_utility.raise_error;
	end if;
  end if;
END IF;
-------------------------------------------------------------------------------
/*
-- 652.95.2
  if  ((p_to_pay_plan in ('GS','GM','GG','GH','FO','FP','FE','ES','ST','AL','CA','SL') and
	p_locality_pay_area <> '99' and
	p_pay_rate_determinant_code not in ('A','B','C','E','F','U','V') and
      p_effective_date >= fnd_date.canonical_to_date('1994/01/01')) and
      (
       substr(p_first_noac_lookup_code,1,1) <> '3' and
       substr(p_first_noac_lookup_code,1,1) <> '4'
       )
      and
	(p_to_locality_adj is null)
	) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    	hr_utility.set_message(8301,'GHR_37739_ALL_PROCEDURE_FAIL');
	    	hr_utility.raise_error;
  end if;
*/
end chk_locality_adj;
/* Name:
-- PRIOR LOCALITY ADJUSTMENT
*/
procedure chk_prior_locality_adj
  (p_to_pay_plan					in	varchar2
  ,p_to_basic_pay                         in    varchar2
  ,p_prior_pay_plan                       in    varchar2
  ,p_pay_rate_determinant_code		in	varchar2
  ,p_retained_pay_plan				in	varchar2
  ,p_prior_pay_rate_det_code			in	varchar2
  ,p_locality_pay_area				in	varchar2
  ,p_prior_locality_pay_area			in	varchar2
  ,p_prior_basic_pay                      in    varchar2
  ,p_to_locality_adj				in	varchar2
  ,p_prior_locality_adj				in	varchar2
  ,p_prior_loc_adj_effective_date         in    date
  ,p_first_noac_lookup_code			in	varchar2
  ,p_as_of_date                         	in    date
  ,p_agency_subelement                    in    varchar2
  ,p_prior_duty_station                   in    varchar2
  ,p_effective_date                       in    date
  ) is

  l_lpa_pct		                 ghr_locality_pay_areas_f.adjustment_percentage%type;
  l_leo_pct		                 ghr_locality_pay_areas_f.leo_adjustment_percentage%type;
  l_lpa_effective_start_date       pay_user_rows_f.effective_start_date%type;
  l_lpa_effective_end_date         pay_user_rows_f.effective_end_date%type;
  l_table5_value		number(10,2); --Bug# 8309414

  CURSOR c1 is
         SELECT effective_start_date,         effective_end_date,
                NVL(adjustment_percentage,0), NVL(leo_adjustment_percentage,0)
	   FROM   ghr_locality_pay_areas_f
	   WHERE  locality_pay_area_code = p_prior_locality_pay_area
           AND  p_prior_loc_adj_effective_date BETWEEN effective_start_date and effective_end_date;

begin
  open c1;
  fetch c1 into l_lpa_effective_start_date, l_lpa_effective_end_date,
                l_lpa_pct, l_leo_pct;
  close c1;
  l_table5_value:= GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 5',
                          '04' ,
                          'Maximum Basic Pay',p_effective_date);
--
-- 27-jul-98
-- The edits where the locality adj as a percentage of prior basic pay was being compared
-- to the lpa_pct has been modified to include leo_pct.
-- bug #703978
--

/*653.08.2  If prior pay plan is GS, GM, GG, GH, FO, FP, FE,
          ES, ST, AL, CA, or SL,
          Then prior locality adjustment, as a percentage of
          prior basic pay, must not be greater than the highest
          percentage on Table 25 for the prior locality pay area.

          Default:  Insert asterisks in prior locality
                    adjustment.

          Basis for Edit:  5 U.S.C. 5304 */
/*
  --
  --   Commented the edit for bug 557188 on 7-aug-98
  --
  if (
	nvl(p_prior_pay_plan,hr_api.g_varchar2) in ('GS','GM','GG','GH','FO','FP','FE','ES','ST','AL','CA','SL')
     ) then

	if (p_prior_basic_pay is not null or to_number(p_prior_basic_pay) <> 0) then
         if (
             l_lpa_pct  < round((nvl(to_number(p_prior_locality_adj),0)/to_number(p_prior_basic_pay))*100,2) and
             l_leo_pct  < round((nvl(to_number(p_prior_locality_adj),0)/to_number(p_prior_basic_pay))*100,2)
		) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37741_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
		end if;
	end if;
  end if;
*/

-- Dec. 2001 Patch Removed the NOAC check
/*653.15.2  If prior pay plan = GS, GM, GG, GH, FO, or FP,
          And prior PRD = 0, 3, 7, J, or K,
          And prior locality pay area is not 99,
          Then the amount of the prior locality adjustment, as a
          percentage of prior basic pay, must match any
          percentage for the locality pay area on Table 25, valid
          as of the effective date or be spaces or asterisks.

          Default:  Insert asterisks in prior locality
                    adjustment.

          Basis for Edit:  5 U.S.C. 5304 */
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05     FROM:'And prior locality pay area is 02 through 88'
---				To: 'And prior locality pay area is other than ZY or ZZ' as of 09-Jan-05
--  Raju    	  08-Nov-2005	 UPD 42(Bug 4567571) Delete prior PRD 3,J and K as of 01-May-2005
--  amrchakr      05-Oct-2006   Removed prior locality pay area 'ZY' effective from 01-jul-2006
-- UPD 56  8309414       Raju       From 13-Aug-07
-------------------------------------------------------------------------------
IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy') ) THEN
    if (
	nvl(p_prior_pay_plan,hr_api.g_varchar2) in ('GS','GM','GG','GH','FO','FP') and
	nvl(p_prior_pay_rate_det_code,hr_api.g_varchar2) in ('0','3','7','J','K') and
        nvl(p_locality_pay_area,hr_api.g_varchar2)  between '02' and '88' and
        (p_prior_locality_adj is not null or to_number(p_prior_locality_adj) <> 0) and
        (p_prior_basic_pay is not null or p_prior_basic_pay <> 0)
       ) then
     	 if (
	    l_lpa_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2) and
 	    l_leo_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2)
	    ) then
            GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37742_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
     end if;
  end if;
ELSIF ( p_effective_date < to_date('01/05/2005', 'dd/mm/yyyy') ) THEN
	if (
	nvl(p_prior_pay_plan,hr_api.g_varchar2) in ('GS','GM','GG','GH','FO','FP') and
	nvl(p_prior_pay_rate_det_code,hr_api.g_varchar2) in ('0','3','7','J','K') and
        nvl(p_locality_pay_area,hr_api.g_varchar2)  NOT IN ('ZY','ZZ') and
        (p_prior_locality_adj is not null or to_number(p_prior_locality_adj) <> 0) and
        (p_prior_basic_pay is not null or p_prior_basic_pay <> 0)
     ) then
     	 if (
		 l_lpa_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2) and
 		 l_leo_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2)
	   	) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_38935_ALL_PROCEDURE_FAIL'); -- NEW MESG TOKEN REQD
		hr_utility.set_message_token('PRD_LIST','0, 3, 7, J, or K');
	    hr_utility.raise_error;
     end if;
  end if;

ELSIF ( p_effective_date >= to_date('01/05/2005', 'dd/mm/yyyy')
        AND
	p_effective_date < to_date('01/07/2006', 'dd/mm/yyyy')
      ) THEN
	if (
	nvl(p_prior_pay_plan,hr_api.g_varchar2) in ('GS','GM','GG','GH','FO','FP') and
	nvl(p_prior_pay_rate_det_code,hr_api.g_varchar2) in ('0','7') and
        nvl(p_locality_pay_area,hr_api.g_varchar2)  NOT IN ('ZY','ZZ') and
        (p_prior_locality_adj is not null or to_number(p_prior_locality_adj) <> 0) and
        (p_prior_basic_pay is not null or p_prior_basic_pay <> 0)
     ) then
     	 if (
		 l_lpa_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2) and
 		 l_leo_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2)
	   	) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_38935_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PRD_LIST','0, or 7');
	    hr_utility.raise_error;
     end if;
  end if;

ELSIF ( p_effective_date >= to_date('01/07/2006', 'dd/mm/yyyy') )
    AND(	p_effective_date < to_date('13/08/2007', 'dd/mm/yyyy')) THEN
	if (
	nvl(p_prior_pay_plan,hr_api.g_varchar2) in ('GS','GM','GG','GH','FO','FP') and
	nvl(p_prior_pay_rate_det_code,hr_api.g_varchar2) in ('0','7') and
        nvl(p_locality_pay_area,hr_api.g_varchar2)  NOT IN ('ZZ') and
        (p_prior_locality_adj is not null or to_number(p_prior_locality_adj) <> 0) and
        (p_prior_basic_pay is not null or p_prior_basic_pay <> 0)
     ) then
     	 if (
		 l_lpa_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2) and
 		 l_leo_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2)
	   	) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37697_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
     end if;
  end if;
ELSE
    if (nvl(p_prior_pay_plan,hr_api.g_varchar2) in ('GS','GM','GG','GH','GL','FO','FP') and
	nvl(p_prior_pay_rate_det_code,hr_api.g_varchar2) in ('0','7') and
        nvl(p_locality_pay_area,hr_api.g_varchar2)  NOT IN ('ZZ') and
        (p_prior_locality_adj is not null or to_number(p_prior_locality_adj) <> 0) and
        (p_prior_basic_pay is not null or p_prior_basic_pay <> 0)
     ) then

     if ((l_lpa_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2) and
 	      l_leo_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2)) OR
            -- (round(to_number(p_to_locality_adj)+to_number(p_to_basic_pay)) > l_table5_value)
	   --Bug 8490941 need to consider the prior locality and basic for comparison with EX04 rate of Table5
               (round(to_number(p_prior_locality_adj)+to_number(p_prior_basic_pay)) > l_table5_value)
	    ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37458_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
     end if;
  end if;
END IF;
-------------------------------------------------------------------------------

/*653.16.2  If prior pay plan is FO, FP, GG, GH, GM, or GS,
          And prior pay rate determinant is 5, 6, or M,
          And prior locality pay area is 02 through 88,
          Then the prior locality adjustment may not be spaces or
          an amount greater than the highest percentage for the
          locality pay area on Table 25
*/
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition 'And locality pay area is 02 through 88'
---			  	To:'And locality pay area is other than ZY or ZZ' as of 09-JAN-05
--- Narasimha Rao 21-SEP-05      Modified as a part of FWFA Changes. Restricted
---                              the edit to actions processed before 01-MAY-2005.
---                              For actions processed on or after 01-MAY-2005,
---                               this edit will be skipped.
--  utokachi      10/21/05       Validate for actions after 01-MAY-2005
--  Raju		  10/26/05		 Commented for Bug# 4699444
-------------------------------------------------------------------------------
/*
    IF  p_effective_date >= to_date('2000/10/01', 'yyyy/mm/dd')  THEN

        -- check for 09-JAN-05 starts here
        IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy') ) THEN

			if ( nvl(p_prior_pay_plan,hr_api.g_varchar2) in ('GS','GM','GG','GH','FO','FP') and
				nvl(p_prior_pay_rate_det_code,hr_api.g_varchar2) in ('5','6','M') and
				 nvl(p_locality_pay_area,hr_api.g_varchar2) between '02' and '88' and
				(p_prior_locality_adj is not null or to_number(p_prior_locality_adj) <> 0) and
				(p_prior_basic_pay is not null or p_prior_basic_pay <> 0)
				) then

				if (
					l_lpa_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2) and
					l_leo_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2)
					) then
						 GHR_GHRWS52L.CPDF_Parameter_Check;
					 hr_utility.set_message(8301,'GHR_37680_ALL_PROCEDURE_FAIL');
					 hr_utility.raise_error;
				end if;
			end if;
		-- FWFA Changes Bug#4444609
        ELSIF p_effective_date < to_date('2005/05/01','yyyy/mm/dd') THEN

			if ( nvl(p_prior_pay_plan,hr_api.g_varchar2) in ('GS','GM','GG','GH','FO','FP') and
				nvl(p_prior_pay_rate_det_code,hr_api.g_varchar2) in ('5','6','M') and
				nvl(p_locality_pay_area,hr_api.g_varchar2) NOT IN ('ZY','ZZ') and
				(p_prior_locality_adj is not null or to_number(p_prior_locality_adj) <> 0) and
				(p_prior_basic_pay is not null or p_prior_basic_pay <> 0)
				) then
				if (
					l_lpa_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2) and
					l_leo_pct < round((to_number(p_prior_locality_adj)/to_number(p_prior_basic_pay)*100),2)
					) then
					GHR_GHRWS52L.CPDF_Parameter_Check;
					hr_utility.set_message(8301,'GHR_38936_ALL_PROCEDURE_FAIL');
					hr_utility.raise_error;
				end if;
			end if;
		ELSE
			if ( nvl(p_prior_pay_plan,hr_api.g_varchar2) in ('GS','GM','GG','GH') and
				nvl(p_prior_pay_rate_det_code,hr_api.g_varchar2) in ('5','6')
				) then
				if to_number(p_prior_locality_adj) <= 0 then
					GHR_GHRWS52L.CPDF_Parameter_Check;
					hr_utility.set_message(8301,'GHR_38979_ALL_PROCEDURE_FAIL');
					hr_utility.raise_error;
				end if;
			end if;
        END IF; -- check for 09-JAN-05 ends here

    END IF; -- only if eff date is greater than 01-OCT-2000
	-- FWFA Changes
	*/
-------------------------------------------------------------------------------
/* p_prior_locality_pay_area has been activated. */

-- 653.30.2
-- Update   Date   	    By                    Comments
-- 21/2    20-Feb-2003     Madhuri  		Adding HS to other than list
--         30-OCT-2003     Ashley               Commented the second condition(Agency subelement cond.)
-------------------------------------------------------------------------------
--- Modified by    Date          Comments
-------------------------------------------------------------------------------
--- Madhuri       01-MAR-05      Change the condition 'If prior locality pay area is 99'
---			  	To:'If prior locality pay area is ZZ' as of 09-JAN-05
--upd47  26-Jun-06	Raju	   From 01-Apr-2006		    Added prior pay plan condition
-------------------------------------------------------------------------------
IF p_effective_date < fnd_date.canonical_to_date('1998/09/01') THEN
     if (p_prior_locality_pay_area = '99' and
        (p_prior_locality_adj is not null and to_number(p_prior_locality_adj) <> 0)) then
         GHR_GHRWS52L.CPDF_Parameter_Check;
	   hr_utility.set_message(8301,'GHR_37743_ALL_PROCEDURE_FAIL');
	   hr_utility.raise_error;
      end if;
ELSE
  -- between 01-SEP-98 to 09-JAN-05
  IF ( p_effective_date < to_date('09/01/2005', 'dd/mm/yyyy') ) THEN
	   --  If prior locality pay area is 99,
	   --  And agency is other than AM, GY, HS, IB, or ST
	   --  Then prior locality adjustment must be spaces or asterisks.
	   if  p_prior_locality_pay_area = '99' and
	       p_prior_locality_adj is not null and
	       to_number(p_prior_locality_adj) <> 0
	   then
	        GHR_GHRWS52L.CPDF_Parameter_Check;
	        hr_utility.set_message(8301,'GHR_37898_ALL_PROCEDURE_FAIL');
		hr_utility.raise_error;
	   end if;
  -- FWFA Changes
  ELSIF p_effective_date < to_date('2005/05/01','YYYY/MM/DD') THEN
	   --  If prior locality pay area is 99,
	   --  And agency is other than AM, GY, HS, IB, or ST
	   --  Then prior locality adjustment must be spaces or asterisks.
	   if  p_prior_locality_pay_area = 'ZZ' and
	       p_prior_locality_adj is not null and
	       to_number(p_prior_locality_adj) <> 0
	   then
	        GHR_GHRWS52L.CPDF_Parameter_Check;
	        hr_utility.set_message(8301,'GHR_38937_ALL_PROCEDURE_FAIL');
		hr_utility.raise_error;
	   end if;
  ELSif p_effective_date < fnd_date.canonical_to_date('2006/04/01') then
	   if  p_prior_locality_pay_area = 'ZZ' and
	       p_prior_pay_rate_det_code not in ('5','6','E','F') and
	       p_prior_locality_adj is not null and
	       to_number(p_prior_locality_adj) <> 0
		then
	        GHR_GHRWS52L.CPDF_Parameter_Check;
	        hr_utility.set_message(8301,'GHR_38980_ALL_PROCEDURE_FAIL');
			hr_utility.raise_error;
	   end if;
  ELSE
        if substr(p_agency_subelement,1,2) <> 'HS' and
		   p_prior_locality_pay_area = 'ZZ' and
	       p_prior_pay_rate_det_code not in ('5','6','E','F') and
           p_prior_pay_plan in ('GM','GS') and
	       p_prior_locality_adj is not null and
	       to_number(p_prior_locality_adj) <> 0
		then
	        GHR_GHRWS52L.CPDF_Parameter_Check;
	        hr_utility.set_message(8301,'GHR_37162_ALL_PROCEDURE_FAIL');
			hr_utility.raise_error;
	   end if;
  END IF;
  -- FWFA Changes
END IF;
-------------------------------------------------------------------------------
--Commented as per EOY 2003 cpdf changes by Ashley
-- 653.31.2
-- Update   Date   	    By                    Comments
-- 21/2    20-Feb-2003     Madhuri  		Adding HS to the list

   -- If prior locality pay area is 99,
   --       And agency is AM, GY, HS, IB, or ST,
   --       And either:
   --            The first two positions of prior duty station are other
   --            than CA or MX,
   --            Or prior pay plan is FO or FP,
   --       Then prior locality adjustment must be spaces or asterisks.

/*   if p_effective_date >= fnd_date.canonical_to_date('1998/09/01') then
      if  p_prior_locality_pay_area = '99' and
          substr(p_agency_subelement,1,2) in ('AM','GY','HS','IB','ST') and
          (
           substr(p_prior_duty_station,1,2) not in ('CA','MX') or
           p_prior_pay_plan in ('FO','FP')
          ) and
          (p_prior_locality_adj is not null and to_number(p_prior_locality_adj) <> 0) then
	    hr_utility.set_message(8301,'GHR_37899_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
      end if;
   end if;
   */

-- 653.40.2
   -- Update     Date        By        Effective Date   Comment
   --   9        04/05/99    vravikan                   All pay plans starting with W but not 'WM'
   --            10/21/05    utokachi   Validate for actions before to 01-MAY-2005
   --      	     08-Nov-05	 Raju       UPD 42(Bug 4567571) Delete Prior PRD U and V as of 01-May-2005
   --      	     14-Nov-05	 Raju       UPD 45(Bug 4567571) Terminate the Edit effective 01-Sep-2005
   --      	     20-Dec-05	 Raju       Bug# 4879781 Terminate the Edit effective 01-May-2005
-- Begin Fix for Bug#4879781
--IF p_effective_date < to_date('2005/09/01','YYYY/MM/DD') THEN
-- End Fix for Bug#4879781
   --FWFA Changes
   IF p_effective_date < to_date('2005/05/01','YYYY/MM/DD') THEN
	  if (
		(substr(p_prior_pay_plan,1,1) in ('B','X') or
		 (substr(p_prior_pay_plan,1,1) in ('W') and p_prior_pay_plan not in ('WM') ) or
		 p_prior_pay_plan in ('EH','EI','EX','ZZ')) and
		 p_prior_pay_rate_det_code not in ('A','B','E','F','S','U','V') and
		(p_prior_locality_adj is not null and to_number(p_prior_locality_adj) <> 0)
		 ) then
		   GHR_GHRWS52L.CPDF_Parameter_Check;
			hr_utility.set_message(8301,'GHR_37744_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('PRD_LIST','A, B, E, F, S, U, or V');
			hr_utility.raise_error;
	  end if;
-- Begin Fix for Bug#4879781
  /*ELSIF p_effective_date >= to_date('2005/05/01','YYYY/MM/DD') THEN
	  if (
		(substr(p_prior_pay_plan,1,1) in ('B','X') or
		 (substr(p_prior_pay_plan,1,1) in ('W') and p_prior_pay_plan not in ('WM') ) or
		 p_prior_pay_plan in ('EH','EI','EX','ZZ')) and
		 p_prior_pay_rate_det_code not in ('A','B','E','F','S') and
		(p_prior_locality_adj is not null and to_number(p_prior_locality_adj) <> 0)
		 ) then
		   GHR_GHRWS52L.CPDF_Parameter_Check;
			hr_utility.set_message(8301,'GHR_37744_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('PRD_LIST','A, B, E, F, or S');
			hr_utility.raise_error;
	  end if;
  END IF;*/
   --FWFA Changes
 -- End Fix for Bug#4879781
end if;


-- 653.45.2
  if (
	p_prior_pay_rate_det_code = 'C' and
	(p_prior_locality_adj is not null and to_number(p_prior_locality_adj) <> 0)

     ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37745_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
  end if;

hr_utility.set_location('Leaving CPDF 7 ',1);
end chk_prior_locality_adj;
end GHR_CPDF_CHECK7;

/
