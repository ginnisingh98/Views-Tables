--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK8" as
/* $Header: ghcpdf08.pkb 120.7.12010000.7 2010/01/08 06:51:36 utokachi ship $ */

   min_basic_pay	number(10,2);
   max_basic_pay	number(10,2);

FUNCTION get_pay_table_value (
    p_effective_date  IN     DATE
  , p_pay_plan        IN     VARCHAR2
  , p_grade_or_level  IN     VARCHAR2
  , p_step_or_rate    IN     VARCHAR2
)
RETURN NUMBER
IS
   CURSOR pay_table IS
 	SELECT
             b.value
        FROM pay_user_rows_f a
           , pay_user_column_instances_f b
           , pay_user_columns c
           , pay_user_tables d
         WHERE TRUNC(p_effective_date) BETWEEN b.effective_start_date AND b.effective_end_date
           AND TRUNC(p_effective_date) BETWEEN a.effective_start_date AND a.effective_end_date
           AND a.row_low_range_or_name = p_pay_plan  ||'-'|| p_grade_or_level
           AND c.user_column_name      = p_step_or_rate
           AND d.user_table_id         = c.user_table_id
           AND c.user_column_id        = b.user_column_id
           AND d.user_table_id         = a.user_table_id
           AND a.user_row_id           = b.user_row_id
           AND d.user_table_name       = '0000 Oracle Federal Standard Pay Table (AL, ES, EX, GS, GG) No. 0000';
   l_value  NUMBER;
BEGIN
   OPEN pay_table;
   FETCH pay_table into l_value;
   CLOSE pay_table;
   RETURN l_value;
END get_pay_table_value;

procedure basic_pay
(p_to_pay_plan				in	varchar2
  ,p_rate_determinant_code	      in	varchar2
  ,p_to_basic_pay				in	varchar2
  ,p_retained_pay_plan			in 	varchar2	/* Non-SF52 Data Item */
  ,p_retained_grade			in 	varchar2	/* Non-SF52 Data Item */
  ,p_retained_step			in	varchar2	/* Non-SF52 Data Item */
  ,p_agency_subelement			in	varchar2	/* Non-SF52 Data Item */
  ,p_to_grade_or_level			in	varchar2
  ,p_to_step_or_rate			in 	varchar2
  ,p_to_pay_basis				in 	varchar2
  ,p_first_action_noa_la_code1 	in	varchar2
  ,p_first_action_noa_la_code2	in	varchar2
  ,p_first_noac_lookup_code		in	varchar2
  ,p_effective_date			in    date
  ,p_occupation_code                         in varchar2
  ) is
l_table_pay	pay_user_column_instances_f.value%type;
l_effective_date date;
l_pay_plan      ghr_pay_plans.pay_plan%type;
begin
-- 650.02.3
-- update date     By		  Comments
-- 20-Feb-2003    Madhuri	 Renumbered edit as 650.02.3, previously 650.04.1 and 650.02.2

IF p_first_noac_lookup_code = '866' THEN
  l_effective_date := p_effective_date + 1;
END IF;

 if      p_to_grade_or_level is not null
     and p_to_step_or_rate is not null
     and p_to_pay_plan in ('GS' ,'VP')
     and p_rate_determinant_code in ('0', '7')
     and p_to_grade_or_level between '01' and '15'
     and p_to_step_or_rate between '01' and '10'
     then
       l_pay_plan := p_to_pay_plan;
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     l_effective_date
          , p_pay_plan        =>     l_pay_plan  -- 'GS'
          , p_grade_or_level  =>     p_to_grade_or_level
          , p_step_or_rate    =>     p_to_step_or_rate
        ) ;
     if not (l_table_pay = to_number(p_to_basic_pay) or
        p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
     then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	 hr_utility.set_message(8301,'GHR_37801_ALL_PROCEDURE_FAIL');
	 hr_utility.raise_error;
     end if;
  end if;

-- 650.07.1
  if ((p_retained_grade is not null and p_retained_step is not null) and
	(
	 (p_to_pay_plan = 'GG' or p_to_pay_plan = 'GS') and
       (p_rate_determinant_code = 'A' or
        p_rate_determinant_code = 'B') and
       (p_retained_pay_plan = 'GG' or p_retained_pay_plan = 'GS') and
        p_retained_grade >= p_to_grade_or_level and
	  (p_retained_grade between '01' and '15') and
	  (p_retained_step between '01' and '10')
	)
     ) then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     p_retained_pay_plan
          , p_grade_or_level  =>     p_retained_grade
          , p_step_or_rate    =>     p_retained_step
        ) ;
	  if (l_table_pay <> to_number(p_to_basic_pay) and
            p_to_basic_pay is not null and
            to_number(p_to_basic_pay) <> 0) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
     hr_utility.set_message(8301,'GHR_37804_ALL_PROCEDURE_FAIL');
     hr_utility.raise_error;
	  end if;
  end if;

--650.11.1
-- Update Date        By        Effective Date            Comment
--   8   05/14/99    vravikan   10/01/98                  New Edit
-- 13-Jun-06			Raju		01-Jan-03			Terminate the edit
/* If Pay plan is JA
then basic pay must be within the range on Table 43 */
if  p_effective_date >= fnd_date.canonical_to_date('1998/10/01') and
    p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
    if ( p_to_pay_plan = 'JA' ) then
        min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 43',
								p_to_pay_plan,'Minimum Basic Pay', p_effective_date);
        max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 43',
								p_to_pay_plan,'Maximum Basic Pay',p_effective_date);
        if not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
        then
            GHR_GHRWS52L.CPDF_Parameter_Check;
            hr_utility.set_message(8301,'GHR_37057_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    end if;
end if;
-- 650.26.3
-- 2/1/01 -- vravikan -- Passing 'GS' to get_pay_table_value instead of 'FG' as
-- 0000 pay table does not have any value for 'FG'

   /*  If pay plan is FG,
       And pay rate determinant is 0 or 7,
       Then basic pay must match the entry for grade and step
       or rate on Table 1 or be asterisks.
       Default:  Insert asterisks in pay basis and basic pay. */
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
  if (
	p_to_pay_plan = 'FG'  and
      (p_rate_determinant_code = '0' or
        p_rate_determinant_code = '7')
     ) then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     'GS'
          , p_grade_or_level  =>     p_to_grade_or_level
          , p_step_or_rate    =>     p_to_step_or_rate
        ) ;
	  if not (nvl(l_table_pay,0) = to_number(p_to_basic_pay) or
               (p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
     hr_utility.set_message(8301,'GHR_37811_ALL_PROCEDURE_FAIL');
     hr_utility.raise_error;
	  end if;
  end if;
end if;
/* previous code was incorrect
  if ((p_retained_grade is not null and p_retained_step is not null) and
	p_to_pay_plan = 'FG'  and
      (p_rate_determinant_code = '0' or
        p_rate_determinant_code = '7') and
	 (p_retained_grade between '01' and '15') and (p_retained_step between '01' and '10')
     ) then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     'GS'
          , p_grade_or_level  =>     p_retained_grade
          , p_step_or_rate    =>     p_retained_step
        ) ;
	  if not (l_table_pay = to_number(p_to_basic_pay) or
               (p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
     hr_utility.set_message(8301,'GHR_37811_ALL_PROCEDURE_FAIL');
     hr_utility.raise_error;
	  end if;
  end if;
*/

-- 650.31.1
  /*    If pay plan is EX,
        And pay rate determinant is 0,
        Then basic pay must equal the entry for the grade on
        Table 5 or be asterisks.

        Default:  Insert asterisks in pay basis and basic pay. */

   IF  p_to_pay_plan = 'EX'  and
       p_rate_determinant_code = '0' THEN
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 5',
                                                      p_to_grade_or_level ,
                                                      'Maximum Basic Pay',
                                                      p_effective_date);
      IF  NVL(to_number(p_to_basic_pay), 0) <> max_basic_pay THEN
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37816_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
      END IF;
   END IF;

--650.32.3
-- Update Date        By        Effective Date            Comment
--       18-Aug-00   vravikan   01-May-2000               New Edit
-- 13-Jun-06			Raju		01-Jan-03			Terminate the edit
/* If Pay plan is VE
And pay rate determinant is 0,
then basic pay must be within the range for the grade on Table 52 */
if p_effective_date >= to_date('2000/05/01','yyyy/mm/dd') and
p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
    if ( p_to_pay_plan = 'VE'  and p_rate_determinant_code = '0' ) THEN
        min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 52',
                            p_to_grade_or_level,'Minimum Basic Pay',p_effective_date);
        max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 52',
                            p_to_grade_or_level,'Maximum Basic Pay',p_effective_date);
        if not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
        then
            GHR_GHRWS52L.CPDF_Parameter_Check;
            hr_utility.set_message(8301,'GHR_37425_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    end if;
end if;
--  commented by Raju as it is duplicate
--650.32.3
   -- Update Date        By        Effective Date            Comment
   --       18-Aug-00   vravikan   01-May-2000               New Edit
/* If Pay plan is VE
   And pay rate determinant is 0,
   then basic pay must be within the range for the grade on Table 52 */
 /* if p_effective_date >= to_date('2000/05/01','yyyy/mm/dd') then
    if ( p_to_pay_plan = 'VE'  and p_rate_determinant_code = '0' ) THEN
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 52',
                        p_to_grade_or_level,
                        'Minimum Basic Pay',
                        p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 52',
                        p_to_grade_or_level,
                        'Maximum Basic Pay',
                        p_effective_date);
      if not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
      then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37425_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
      end if;
    end if;
  end if;
*/
-- 650.37.1
-- Madhuri        21-JAN-2004    End Dating this edit as on 10-JAN-04
--				 For SES Pay Calculations
-- Madhuri        19-MAY-2004    Renumbering this edit from 650.37.1 to 650.37.3.
--                               Need to change the if then condition as under
-- end dating the edit as on 10-JAN-2004
--  FROM:	Then basic pay must equal the entry for the step or rate on Table 6 or be asterisks
--  TO:		Then basic pay must be within the range on Table 55.

  IF ( p_effective_date < to_date('2004/01/11', 'yyyy/mm/dd') and
       p_to_pay_plan IN ('ES', 'FE') and p_rate_determinant_code = '0' )
  THEN
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     p_to_pay_plan
          , p_grade_or_level  =>     '00'
          , p_step_or_rate    =>     p_to_step_or_rate
        ) ;
       IF nvl(to_number(p_to_basic_pay), 0) <> l_table_pay THEN
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37817_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
      end if;
  ELSIF ( p_effective_date >= to_date('2004/01/11', 'yyyy/mm/dd') and
       p_to_pay_plan IN ('ES', 'FE') and p_rate_determinant_code = '0' )
       THEN
  -- 650.37.3
	min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 55',
                        p_to_pay_plan,
                        'Minimum Basic Pay',
                        p_effective_date);
	max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 55',
                        p_to_pay_plan,
                        'Maximum Basic Pay',
                        p_effective_date);
      if not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
      then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_38884_ALL_PROCEDURE_FAIL');
-- NEED TO ADD A NEW MESSAGE HERE
        hr_utility.raise_error;
      end if;
END IF;



-- 650.38.1
-- Bug#5089732 Commented the edit as per Norma's Suggession,
-- until OPM modifies this edit.
/*  if ((p_to_grade_or_level is not null and p_to_step_or_rate is not null) and
	p_to_pay_plan = 'GG' and
	(
	 p_to_grade_or_level between '01' and '15' and
	 p_to_step_or_rate between '01' and '10' and
	 p_rate_determinant_code in ('0','7')
        )
     ) then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     'GG'
          , p_grade_or_level  =>     p_to_grade_or_level
          , p_step_or_rate    =>     p_to_step_or_rate
        ) ;
	  if not (to_number(p_to_basic_pay) = l_table_pay or
               (p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)) then
      GHR_GHRWS52L.CPDF_Parameter_Check;
     hr_utility.set_message(8301,'GHR_37818_ALL_PROCEDURE_FAIL');
     hr_utility.raise_error;
	  end if;
  end if;
*/
-- 650.39.1
-- Update Date        By        Effective Date            Comment
-- 10-Oct-05       Utokachi		01-MAY-2005				Bug#4444609 added equal or exceed condition
--  09-Nov-2005    Raju         01-May-2005             UPD 43(Bug 4567571)Delete PRD M
  IF p_effective_date < to_date('2005/05/01','YYYY/MM/DD') THEN
	if ((p_to_grade_or_level is not null and p_to_step_or_rate is not null) and
		p_to_pay_plan = 'GG' and
		(
		 p_to_grade_or_level between '01' and '15' and
		 p_to_step_or_rate between '01' and '10'
		) and
		 p_rate_determinant_code in ('5','6','M')
		 ) then
		   l_table_pay := get_pay_table_value (
				p_effective_date  =>     p_effective_date
			  , p_pay_plan        =>     'GG'
			  , p_grade_or_level  =>     p_to_grade_or_level
			  , p_step_or_rate    =>     p_to_step_or_rate
			) ;
		  if not (to_number(p_to_basic_pay) > l_table_pay or
			(p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)) then
			GHR_GHRWS52L.CPDF_Parameter_Check;
			hr_utility.set_message(8301,'GHR_37819_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('COND','exceed');
			hr_utility.set_message_token('PRD_LIST','5,6 or M');
			hr_utility.raise_error;
		  end if;
	end if;
-- FWFA Changes Bug#4444609
ELSIF p_effective_date >= to_date('2005/05/01','YYYY/MM/DD') THEN
	if ((p_to_grade_or_level is not null and p_to_step_or_rate is not null) and
		p_to_pay_plan = 'GG' and
		(
		 p_to_grade_or_level between '01' and '15' and
		 p_to_step_or_rate between '01' and '10'
		) and
		 p_rate_determinant_code in ('5','6')
		 ) then
		l_table_pay := get_pay_table_value (
			p_effective_date  =>     p_effective_date
		  , p_pay_plan        =>     'GG'
		  , p_grade_or_level  =>     p_to_grade_or_level
		  , p_step_or_rate    =>     p_to_step_or_rate
		) ;
		if not (to_number(p_to_basic_pay) >= l_table_pay or
			 (p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)) then
			 GHR_GHRWS52L.CPDF_Parameter_Check;
			 hr_utility.set_message(8301,'GHR_37819_ALL_PROCEDURE_FAIL');
			 hr_utility.set_message_token('COND','equal or exceed');
			hr_utility.set_message_token('PRD_LIST','5 or 6');
			 hr_utility.raise_error;
		end if;
	end if;
END IF;
-- FWFA Changes Bug#4444609

-- 650.39.2
-- When pay plan is GG, and grade is 01 through 15, and step is 01 through 10,
-- and pay rate determinant is 5 or 6, then basic pay must equal or exceed
-- the entry for the grade and step on Table 1 or be asterisks.
--     28-May-2005   utokachi  New Edit FWFA Changes Bug# 4658890
IF p_effective_date >= to_date('2005/05/01','yyyy/mm/dd') THEN
  if p_to_pay_plan = 'GG' and
     p_to_grade_or_level between '01' and '15' and
	 p_to_step_or_rate between '01' and '10' and
	 p_rate_determinant_code in ('5','6')
	 then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     'GG'
          , p_grade_or_level  =>     p_to_grade_or_level
          , p_step_or_rate    =>     p_to_step_or_rate
        ) ;
	  if  (
	          (l_table_pay > to_number(p_to_basic_pay)) and
                (p_to_basic_pay is not null or to_number(p_to_basic_pay) <> '0')
		   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_38983_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
	 end if;
  end if;
 END IF;

--650.66.3
   -- Update Date        By        Effective Date            Comment
   --       17-Aug-00   vravikan   01-Jan-2000               New Edit
/* If Pay plan is VN
   And pay rate determinant is 0,
   And occupation is 0601 or 0603
   then basic pay must be within the range for the grade on Table 14 */
  if p_effective_date >= to_date('2000/01/01','yyyy/mm/dd') then
    if ( p_to_pay_plan = 'VN' and p_rate_determinant_code = '0'
          and p_occupation_code in ('0601','0603') ) then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 14',
                        p_to_pay_plan,
                        'Minimum Basic Pay',
                        p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 14',
                        p_to_pay_plan,
                        'Maximum Basic Pay',
                        p_effective_date);
      if not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
      then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37427_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
      end if;
    end if;
  end if;

--650.67.3
   -- Update Date        By        Effective Date            Comment
   --       17-Aug-00   vravikan   01-Jan-2000               New Edit
/* If Pay plan is VN
   And pay rate determinant is 0,
   And occupation is 0605 or 0610
   then basic pay must be within the range on Table 15 */
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
  if p_effective_date >= to_date('2000/01/01','yyyy/mm/dd') then
    if ( p_to_pay_plan = 'VN' and p_rate_determinant_code = '0'
          and p_occupation_code in ('0605','0610') ) then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 15',
                        p_to_pay_plan,
                        'Minimum Basic Pay',
                        p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 15',
                        p_to_pay_plan,
                        'Maximum Basic Pay',
                        p_effective_date);
      if not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
      then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37428_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
      end if;
    end if;
  end if;
end if;

-- 650.69.2
   -- Update/Change Date        By        Effective Date    Bug        Comment
   --   10/2        08/13/99    vravikan                  992944        Change step 1 to step 10
   -- upd52  13-Feb-07	  Raju         From 01-Sep-2004	    Bug#5745356 terminate

if  p_effective_date < fnd_date.canonical_to_date('2004/09/01') THEN
  if (( p_first_action_noa_la_code1 = 'J8M'  or
	 p_first_action_noa_la_code2 = 'J8M') and
	 (p_first_noac_lookup_code in ('170','570') and
	  substr(p_to_pay_plan,1,1) in ('W','X'))) then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     'GS'
          , p_grade_or_level  =>     '11'
          , p_step_or_rate    =>     '10') ;
        if l_table_pay < to_number(p_to_basic_pay) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37852_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
        end if;
  end if;
end if;
-- 650.89.1
     /*   If pay plan is GG or GS,
          And pay rate determinant is E, F, or M,
          And retained pay plan is GG or GS,
          And retained step is 01 through 10,
          And retained grade is equal to or higher than grade,
          Then basic pay must exceed the entry for retained grade
          and retained step on Table 1 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay. */
--  Bug#4444609           Raju	   28-May-2005	      Added equal or exceed condition effective from 01-May-2005
--  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete PRD M effective date from 01-May-2005

 IF p_effective_date < to_date('2005/05/01','YYYY/MM/DD') THEN
	if ((p_to_grade_or_level is not null and p_to_step_or_rate is not null) and
		(p_to_pay_plan = 'GG' or p_to_pay_plan = 'GS') and
		(p_retained_pay_plan = 'GG' or p_retained_pay_plan = 'GS') and
		p_rate_determinant_code in ('E','F','M') and
		p_retained_grade >= p_to_grade_or_level
		) then
		l_table_pay := get_pay_table_value (
			p_effective_date  =>     p_effective_date
		  , p_pay_plan        =>     p_retained_pay_plan
		  , p_grade_or_level  =>     p_retained_grade
		  , p_step_or_rate    =>     p_retained_step
		) ;
		if not (
			(nvl(l_table_pay,0) < to_number(p_to_basic_pay)) or
			(p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
			) then
			GHR_GHRWS52L.CPDF_Parameter_Check;
			hr_utility.set_message(8301,'GHR_37844_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('COND','exceed');
			hr_utility.set_message_token('PRD_LIST','E, F or M');
			hr_utility.raise_error;
		end if;
	end if;
-- FWFA Changes
ELSIF p_effective_date >= to_date('2005/05/01','YYYY/MM/DD') THEN
	if ((p_to_grade_or_level is not null and p_to_step_or_rate is not null) and
		(p_to_pay_plan = 'GG' or p_to_pay_plan = 'GS') and
		(p_retained_pay_plan = 'GG' or p_retained_pay_plan = 'GS') and
		p_rate_determinant_code in ('E','F') and
		p_retained_grade >= p_to_grade_or_level
		) then
		l_table_pay := get_pay_table_value (
			p_effective_date  =>     p_effective_date
		  , p_pay_plan        =>     p_retained_pay_plan
		  , p_grade_or_level  =>     p_retained_grade
		  , p_step_or_rate    =>     p_retained_step
		) ;
		if not (
		    (nvl(l_table_pay,0) <= to_number(p_to_basic_pay)) or
                (p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
		   ) then
		   GHR_GHRWS52L.CPDF_Parameter_Check;
			hr_utility.set_message(8301,'GHR_37844_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('COND','equal or exceed');
			hr_utility.set_message_token('PRD_LIST','E or F');
			hr_utility.raise_error;
		end if;
	end if;
END IF;
-- FWFA Changes

-- 650.81.1
/*
  --
  --   Commented the edit for bug 557188 on 7-aug-98
  --
  if ((p_retained_grade is not null and p_retained_step is not null) and
	(p_to_pay_plan <> 'GG' and p_to_pay_plan <> 'GS') and
	(p_retained_pay_plan = 'GG' or p_retained_pay_plan = 'GS') and
	(p_retained_grade between '01' and '15') and (p_retained_step between '01' and '10') and
	(p_rate_determinant_code = 'A' or p_rate_determinant_code = 'B')
     ) then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     p_retained_pay_plan
          , p_grade_or_level  =>     p_retained_grade
          , p_step_or_rate    =>     p_retained_step
        ) ;
	  if not (
	    (l_table_pay = to_number(p_to_basic_pay)) or (p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
		   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37837_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
	  end if;
  end if;
*/

-- 650.82.1
/*
  --
  --   Commented the edit for bug 557188 on 7-aug-98
  --
  if ((p_retained_grade is not null and p_retained_step is not null) and
	(p_to_pay_plan <> 'GG' and p_to_pay_plan <> 'GS') and
	(p_retained_pay_plan = 'GG' or p_retained_pay_plan = 'GS') and
	(p_rate_determinant_code = 'E' or p_rate_determinant_code = 'F')
     ) then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     p_retained_pay_plan
          , p_grade_or_level  =>     p_retained_grade
          , p_step_or_rate    =>     p_retained_step
        ) ;
	  if not (
	          (nvl(l_table_pay,0) < to_number(p_to_basic_pay)) or
                (p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
		   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37838_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
	  end if;
  end if;
*/
-- Added on 10-Oct-05 by Utokachi for Validate actions after 01-MAY-2005
--FWFA Changes
IF p_effective_date >= to_date('2005/05/01','YYYY/MM/DD') THEN
	if ((p_retained_grade is not null and p_retained_step is not null) and
	(p_to_pay_plan <> 'GG' and p_to_pay_plan <> 'GS') and
	(p_retained_pay_plan = 'GG' or p_retained_pay_plan = 'GS') and
	(p_rate_determinant_code = 'E' or p_rate_determinant_code = 'F')
     ) then
		   l_table_pay := get_pay_table_value (
				p_effective_date  =>     p_effective_date
			  , p_pay_plan        =>     p_retained_pay_plan
			  , p_grade_or_level  =>     p_retained_grade
			  , p_step_or_rate    =>     p_retained_step
			) ;
		  if not (
				  (nvl(l_table_pay,0) <= to_number(p_to_basic_pay)) or
					(p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
			   ) then
				GHR_GHRWS52L.CPDF_Parameter_Check;
				hr_utility.set_message(8301,'GHR_37838_ALL_PROCEDURE_FAIL');
				hr_utility.raise_error;
		  end if;
	end if;
END IF;
--FWFA Changes

--650.83.1
-- Modified as a part of FWFA Changes. Restricted the edit to actions processed
-- before 01-MAY-2005. For actions processed on or after 01-MAY-2005, this edit
-- will be skipped.
-- FWFA Changes Bug#4444609
--  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete PRD M effective date from 01-May-2005
IF p_effective_date < to_date('2005/05/01','yyyy/mm/dd') THEN
  if p_to_step_or_rate between '01' and '10' and
	p_to_pay_plan = 'GS' and p_rate_determinant_code in ('5','6','M')
	 then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     'GS'
          , p_grade_or_level  =>     p_to_grade_or_level
          , p_step_or_rate    =>     p_to_step_or_rate
        ) ;
	  if not (
	          (l_table_pay < to_number(p_to_basic_pay)) or
                (p_to_basic_pay is null or to_number(p_to_basic_pay) = '0')
		   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37839_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('COND','exceed');
		hr_utility.set_message_token('PRD_LIST','5,6 or M');
	    hr_utility.raise_error;
	 end if;
  end if;
ELSE
	if p_to_step_or_rate between '01' and '10' and
	p_to_pay_plan = 'GS' and p_rate_determinant_code in ('5','6')
	 then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     'GS'
          , p_grade_or_level  =>     p_to_grade_or_level
          , p_step_or_rate    =>     p_to_step_or_rate
        ) ;
	  if not (
	          (l_table_pay <= to_number(p_to_basic_pay)) or
                (p_to_basic_pay is null or to_number(p_to_basic_pay) = '0')
		   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_37839_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('COND','equal or exceed');
		hr_utility.set_message_token('PRD_LIST','5 or 6');
	    hr_utility.raise_error;
	 end if;
  end if;
END IF;
-- FWFA Changes
/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc

-- 650.83.2
-- When pay plan is GS, and pay rate determinant is 5 or 6,
-- then basic pay must equal or exceed the entry for grade
-- and step or rate on Table 1 or be asterisks

--     28-May-2005   utokachi  New Edit FWFA Changes Bug# 4658890

IF p_effective_date >= to_date('2005/05/01','yyyy/mm/dd') THEN
  if p_to_pay_plan = 'GS' and p_rate_determinant_code in ('5','6') then
       l_table_pay := get_pay_table_value (
            p_effective_date  =>     p_effective_date
          , p_pay_plan        =>     'GS'
          , p_grade_or_level  =>     p_to_grade_or_level
          , p_step_or_rate    =>     p_to_step_or_rate
        ) ;
	  if  (
	          (l_table_pay > to_number(p_to_basic_pay)) or
                (p_to_basic_pay is not null or to_number(p_to_basic_pay) <> '0')
		   ) then
       GHR_GHRWS52L.CPDF_Parameter_Check;
	    hr_utility.set_message(8301,'GHR_38984_ALL_PROCEDURE_FAIL');
	    hr_utility.raise_error;
	 end if;
  end if;
END If;


650.03.3  If pay plan is NH,and pay rate determinant is 0,5,6 or 7
          Then basic pay must be within the range for the grade on
          Table 37 or Table 38(depending on pay rate determinant) or
          be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.

  if p_effective_date > fnd_date.canonical_to_date('1998/03/01') and
     p_to_pay_plan = 'NH'  and
     p_rate_determinant_code in ('0','5','6','7') then -- added for bug 726125
     if p_rate_determinant_code in ('0','7')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 37',
                          p_to_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 37',
                          p_to_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     elsif p_rate_determinant_code in ('5','6')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 38',
                          p_to_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 38',
                          p_to_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     end if;
     if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
        (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
        or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
     then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37886_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
     end if;
  end if;
*/

/*650.05.3  If pay plan is NY,
          Then basic pay must be within the range on Table 26 or
          be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_to_pay_plan = 'NY' then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 26',
                        p_to_grade_or_level ,
                        'Minimum Basic Pay',p_effective_date);

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 26',
                        p_to_grade_or_level ,
                        'Maximum Basic Pay',p_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
          (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
          or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37802_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

/*650.06.3  If pay plan is NX,
          Then basic pay must be within the range for the grade
          on Table 27 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_to_pay_plan = 'NX' then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 27',
                        p_to_grade_or_level ,
                        'Minimum Basic Pay',p_effective_date);

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 27',
                        p_to_grade_or_level ,
                        'Maximum Basic Pay',p_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
          (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
          or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37803_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
650.08.3  If pay plan is NJ,and pay rate determinant is 0,5,6 or 7
          Then basic pay must be within the range for the grade on
          Table 39 or Table 40(depending on pay rate determinant) or
          be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.

  if p_effective_date > fnd_date.canonical_to_date('1998/03/01') and
     p_to_pay_plan = 'NJ'  and
     p_rate_determinant_code in ('0','5','6','7') then -- added for bug 726125
     if p_rate_determinant_code in ('0','7')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 39',
                          p_to_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 39',
                          p_to_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     elsif p_rate_determinant_code in ('5','6')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 40',
                          p_to_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 40',
                          p_to_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     end if;
     if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
        (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
        or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
     then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37863_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
     end if;
  end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
650.09.3  If pay plan is NK,and pay rate determinant is 0,5,6 or 7
          Then basic pay must be within the range for the grade on
          Table 41 or Table 42(depending on pay rate determinant) or
          be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.

  if p_effective_date > fnd_date.canonical_to_date('1998/03/01') and
     p_to_pay_plan = 'NK' and
     p_rate_determinant_code in ('0','5','6','7') then
     if p_rate_determinant_code in ('0','7')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 41',
                          p_to_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 41',
                          p_to_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     elsif p_rate_determinant_code in ('5','6')  then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 42',
                          p_to_grade_or_level ,
                          'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 42',
                          p_to_grade_or_level ,
                          'Maximum Basic Pay',p_effective_date);
     end if;
     if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
        (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
        or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
     then
        GHR_GHRWS52L.CPDF_Parameter_Check;
        hr_utility.set_message(8301,'GHR_37864_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
     end if;
  end if;
*/

/*650.13.1  If pay plan is GS,
          And pay rate determinant is 2, 3, 4, J, K, or R,
          Then basic pay must equal or exceed the minimum basic
          pay for the appropriate grade on Table 2 or be
          asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/

-- Modified EDIT for Student Loan Repayment
-- The to Basic Pay will be NULL for 817 action, so this edit will be fired
-- Checking for NOAC 817 before firing edit
-- Bug# 9255822 added PRD Y

if p_to_pay_plan = 'GS'  and
   p_rate_determinant_code in ('2','3','4','J','K','R','Y') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 2',
                    p_to_grade_or_level || '-' || p_to_step_or_rate,
                    'Minimum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) >= min_basic_pay)
      or (p_to_basic_pay is null and p_first_noac_lookup_code <> '817' ))
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37805_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/*650.16.1  If pay rate determinant is U or V,
          And retained pay plan is GG, GH, GS, or GM,
          Then basic pay must equal or exceed the minimum basic
          pay for the retained grade on Table 2 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
/*
  --
  --   Commented the edit for bug 557188 on 7-aug-98
  --
if p_rate_determinant_code in ('U','V') and
   p_to_pay_plan in ('GG','GH','GS','GM')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 2',
                    p_retained_grade || '-' || p_retained_step,
                    'Minimum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) >= min_basic_pay)
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37806_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
650.19.1  If pay plan is GM,
          And pay rate determinant is 0 or 7,
          Then basic pay must fall within the range for grade and
          step or rate on Table 3 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.
if p_to_pay_plan = 'GM'
   and p_rate_determinant_code in ('0', '7') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                    p_to_grade_or_level || '-' || p_to_step_or_rate,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                    p_to_grade_or_level || '-' || p_to_step_or_rate,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37807_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

--   18-Aug-00 - vravikan --- 01-Jan-2000          New Edit
/*
650.19.3  If pay plan is GM,
          And pay rate determinant is 0 or 7,
          Then basic pay must fall within the range for grade on Table 3
*/
if p_to_pay_plan = 'GM'
   and p_rate_determinant_code in ('0', '7') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                    p_to_grade_or_level ,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                    p_to_grade_or_level ,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37429_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
--Commented as per EOY 2003 cpdf changes by Ashley
/*650.20.1  If pay plan is GM,
          And pay rate determinant is 5, 6, or M,
          Then basic pay must fall within the range for the grade
          on Table 20 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
/*if p_to_pay_plan = 'GM'
   and p_rate_determinant_code in ('5', '6', 'M') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                    p_to_grade_or_level,
                    'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                    p_to_grade_or_level,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37808_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;*/

/*
CPDF Edit #650.21.2 and 650.21.1 : If pay plan is GL and pay rate determinant is 0 or 7.
				 Then basic pay must match the entry for the grade and
				 step on Table 57 or be asterisks.
Table 57 is '0491'
*/
-- 650.21.1 and 650.21.2
IF  p_effective_date >= fnd_date.canonical_to_date('2007/08/13') THEN
  if (
      p_to_pay_plan = 'GL'  and
      (p_rate_determinant_code = '0' or p_rate_determinant_code = '7')
     ) then
       l_table_pay := GHR_CPDF_CHECK.get_basic_pay(
                                 '0491 Oracle Federal Special Rate Pay Table (GS) No. 0491',
                                 'GL' || '-' || p_to_grade_or_level,
                                  p_to_step_or_rate,
                                  p_effective_date);

	  if not (nvl(l_table_pay,0) = to_number(p_to_basic_pay) or
             (p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)) THEN
	        GHR_GHRWS52L.CPDF_Parameter_Check;
	        hr_utility.set_message(8301,'GHR_37751_ALL_PROCEDURE_FAIL');
	        hr_utility.raise_error;
	  end if;
  end if;

END IF;

/* Commented as per December 2000 cpdf changes -- vravikan
650.22.1  If pay plan is GH or GM,
          And pay rate determinant is A or B,
          And retained grade is equal to or higher than grade,
          And retained pay plan is GH or GM,
          Then basic pay must fall within the range for retained
          grade and retained step on Table 3 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.
  --            17-Aug-00   vravikan   01-jan-2000   Delete retained step
if p_effective_date >= to_date('2000/01/01','yyyy/mm/dd') then
if p_to_pay_plan in ('GH','GM')
   and p_rate_determinant_code in ('A','B')
   and p_retained_grade >= p_to_grade_or_level
   and p_retained_pay_plan in ('GH','GM')   then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                  p_retained_grade,
                                                 'Minimum Basic Pay',
                                                  p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                  p_retained_grade,
                                                 'Maximum Basic Pay',
                                                  p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null
      or to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37433_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
else
if p_to_pay_plan in ('GH','GM')
   and p_rate_determinant_code in ('A','B')
   and p_retained_grade >= p_to_grade_or_level
   and p_retained_pay_plan in ('GH','GM')   then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                  p_retained_grade|| '-' || p_retained_step,
                                                 'Minimum Basic Pay',
                                                  p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                  p_retained_grade|| '-' || p_retained_step ,
                                                 'Maximum Basic Pay',
                                                  p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null
      or to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37809_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
end if;
*/

 --            12/8/00   vravikan    From Start     Change Edit
 --                                                 Table 4 to Table 2

/*650.25.1  If pay plan is GH or GM,
          And pay rate determinant is 2, 3, 4, J, K, or R,
          Then basic pay must equal or exceed the minimum basic
          pay for the grade on Table 4 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
-- Bug# 9255822 added PRD Y
if p_to_pay_plan in ('GH', 'GM')
   and p_rate_determinant_code in ('2','3','4','J','K','R','Y')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 2',
                    p_to_grade_or_level || '-' || p_to_step_or_rate,
                    'Minimum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) >= min_basic_pay)
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37810_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

--Begin Bug# 9255822
/*650.25.2  If pay plan is GH ,GM or GS,
          And pay rate determinant is 2, 3, 4, J, K, or R,
          Then basic pay must equal or exceed the minimum basic
          pay for the grade on Table 4 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
if p_to_pay_plan in ('GH','GM','GS')
   and p_rate_determinant_code in ('2','3','4','J','K','R','Y')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 2',
                    p_to_grade_or_level || '-' || p_to_step_or_rate,
                    'Minimum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) >= min_basic_pay)
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_38381_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
-- End Bug# 9255822

/*650.27.3  If pay plan is FB, FJ, or FX,
          Then basic pay must be no less than step 1 on Table 6
          and no more than step 6 on Table 6, or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
--
-- Madhuri   19-MAY-2004    End dated the Edit as of 10-JAN-04
--
IF p_effective_date < to_date('2004/01/11', 'yyyy/mm/dd') then
 if p_to_pay_plan in ('FB', 'FJ', 'FX') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 6',
                                                 '01',
                                                 'Maximum Basic Pay',
                                                 p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 6',
                                                 '06',
                                                 'Maximum Basic Pay',
                                                 p_effective_date);
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
         or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
      then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37812_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
 end if;
END IF;

/*650.28.3  If pay plan is FT,
          Then basic pay must be within the range on Table 21 or
          be asterisks.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_to_pay_plan = 'FT' then
       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                                                      p_to_pay_plan ,
                                                     'Minimum Basic Pay',
                                                      p_effective_date);

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                                                      p_to_pay_plan ,
                                                     'Maximum Basic Pay',
                                                      p_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
          if (not (to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
             or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
          then
             GHR_GHRWS52L.CPDF_Parameter_Check;
             hr_utility.set_message(8301,'GHR_37813_ALL_PROCEDURE_FAIL');
             hr_utility.raise_error;
          end if;
       end if;
    end if;
end if;
/*650.29.3  If pay plan is FL, FS, or FW,
          Then basic pay must be no less than the minimum for pay
          plan WG on Table 11 and no more than the maximum for
          pay plan WS on Table 11, or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/

 -- Update Date   Updated By	Effective Date			Comments
 -----------------------------------------------------------------------------------------------------------
 -- 18/10/2004    Madhuri	From the start of the edit	Deleting the edit
 -----------------------------------------------------------------------------------------------------------

/*if p_to_pay_plan in ('FL', 'FS', 'FW') then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                    'WG' || '-' || p_to_grade_or_level,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                    'WS' || '-' || p_to_grade_or_level,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if (not (to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
         or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
      then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37814_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if; */
 -----------------------------------------------------------------------------------------------------------

/*650.30.3  If pay plan is FM,
          And pay rate determinant is 0 or 7,
          Then basic pay must match the entry for grade and step
          or rate on Table 3 or be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.*/

  --            17-Aug-00   vravikan   01-jan-2000   Delete step or rate
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_effective_date >= to_date('2000/01/01','yyyy/mm/dd') then
    if p_to_pay_plan = 'FM' then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                        p_to_grade_or_level,
                        'Minimum Basic Pay',p_effective_date);

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                        p_to_grade_or_level,
                        'Maximum Basic Pay',p_effective_date);
       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
          if p_rate_determinant_code in ('0','7')
             and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
             or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
          then
             GHR_GHRWS52L.CPDF_Parameter_Check;
             hr_utility.set_message(8301,'GHR_37435_ALL_PROCEDURE_FAIL');
             hr_utility.raise_error;
          end if;
       end if;
    end if;
    else
    if p_to_pay_plan = 'FM' then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                        p_to_grade_or_level || '-' || p_to_step_or_rate,
                        'Minimum Basic Pay',p_effective_date);

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                        p_to_grade_or_level || '-' || p_to_step_or_rate,
                        'Maximum Basic Pay',p_effective_date);
       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
          if p_rate_determinant_code in ('0','7')
             and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
             or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
          then
             GHR_GHRWS52L.CPDF_Parameter_Check;
             hr_utility.set_message(8301,'GHR_37815_ALL_PROCEDURE_FAIL');
             hr_utility.raise_error;
          end if;
       end if;
    end if;
    end if;
end if;

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
650.35.1  If pay plan is DR,
          And pay rate determinant is 0 or 7,
          Then basic pay must be within the range for the grade
          and pay rate determinant on Table 28 or be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.

if p_to_pay_plan = 'DR' and
   p_rate_determinant_code in ('0','7') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 28',
                    p_to_grade_or_level ,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 28',
                    p_to_grade_or_level ,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
      or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37854_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
650.36.1  If pay plan is DR,
          And pay rate determinant is 5 or 6,
          Then basic pay must be within the range for the grade
          and pay rate determinant on Table 29 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.

if p_to_pay_plan = 'DR'  and
   p_rate_determinant_code in ('5','6') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 29',
                    p_to_grade_or_level ,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 29',
                    p_to_grade_or_level ,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
      or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37855_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/*650.41.3  If pay plan is GG,
          And grade is 01 through 15,
          And step is 01 through 10,
          And pay rate determinant is 5, 6, or M,
          Then basic pay must be equal to or less than the entry
          for the grade on Table 19 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
/* Commenting the edit for the bug 3147737
if p_to_pay_plan = 'GG'  and
   p_rate_determinant_code in ('5','6','M')  then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 19',p_to_grade_or_level,
                    'Maximum Basic Pay',p_effective_date);

   if max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) < max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37820_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/
/*650.42.1  If pay plan is GG,
          And grade is 01 through 15,
          And pay rate determinant is 2, 3, 4, J, K, or R,
          Then basic pay must equal or exceed the entry for the
          grade on Table 2 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
-- Bug# 9255822 added PRD Y
if p_to_pay_plan = 'GG' and
   p_to_grade_or_level between '01' and '15' and
   p_rate_determinant_code in ('2','3','4','J','K','R','Y') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 2',
                                                 p_to_grade_or_level || '-' || p_to_step_or_rate ,
                                                 'Minimum Basic Pay',
                                                 p_effective_date);
   if min_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) >= min_basic_pay)
      or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37821_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 650.43.2  If pay plan is FA,
--           And agency/subelement is ST,
--           And pay rate determinant is 0,
--           And step  is 13 or 14,
--           Then basic pay must equal entry for the step on Table 7 or be asterisks.
--   19-MAR-2003    vnarasim         First version of the edit
-- upd52  13-Feb-07	  Raju         From 01-Sep-2004	    Bug#5745356 terminate
if  p_effective_date < fnd_date.canonical_to_date('2004/09/01') THEN
    if p_to_pay_plan = 'FA'
       and p_agency_subelement = 'ST'
       and p_rate_determinant_code = '0'
       and p_to_step_or_rate in ('13','14')   then

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 7',
                                                     p_to_step_or_rate ,
                                                     'Maximum Basic Pay',p_effective_date);

       if max_basic_pay IS NOT NULL
          and (to_number(p_to_basic_pay) <> max_basic_pay
          or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37928_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

-- 650.43.3 If pay plan is FA,
--          And agency/subelement is ST,
--          And pay rate determinant is 0,
--          And grade is 13 or 14,
--          Then basic pay must equal entry for the grade on Table 7 or be asterisks.
--          Default:  Insert asterisks in pay basis and basic pay.
-- Update  Date    By	              Comments
-- ============   =============       ===========================================
-- 20-Feb-2003    Madhuri             Renumbered Edit from 650.43.1 to 650.43.3
-- 27-Feb-2003    Madhuri	      Modified the requirement
--				from  And grade is 01 thru 04 or 13 or 14
--				 to   And grade is 13 or 14
-- 19-MAR-2003    NarasimhaRao        Changed the parameter from p_to_grade_or_level to
--                                    p_to_step_or _rate
-- upd52  13-Feb-07	  Raju         From 01-Sep-2004	    Bug#5745356 terminate
if  p_effective_date < fnd_date.canonical_to_date('2004/09/01') THEN
    if p_to_pay_plan = 'FA'
       and p_agency_subelement = 'ST'
       and p_rate_determinant_code = '0'
       and p_to_grade_or_level in ('13','14')   then

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 7',
                                                     p_to_step_or_rate ,
                                                     'Maximum Basic Pay',p_effective_date);

       if max_basic_pay IS NOT NULL
          and (to_number(p_to_basic_pay) <> max_basic_pay
          or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37822_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

/*650.45.1  If pay plan is GH,
          And pay rate determinant is 0 or 7,
          Then basic pay must be within the range for the grade
          on Table 3 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
if p_to_pay_plan = 'GH'
   and p_rate_determinant_code in ('0','7') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                 p_to_grade_or_level || '-' || p_to_step_or_rate,
                                                 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                 p_to_grade_or_level || '-' || p_to_step_or_rate,
                                                 'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null
      or to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37823_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

--Commented as per EOY 2003 cpdf changes by Ashley
/*650.46.1  If pay plan is GH,
          And pay rate determinant is 5, 6, or M,
          Then basic pay must be within the range for the grade
          on Table 20 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/

/*if p_to_pay_plan = 'GH'
   and p_rate_determinant_code in ('5', '6', 'M') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                    p_to_grade_or_level,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                    p_to_grade_or_level,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37824_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;*/

/*650.47.1  If pay plan is FC,
          And pay rate determinant is 0,
          Then basic pay must be within the range for the grade on
          Table 8 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
-- Update  Date  	By 			Comments
-- 20/2   27-Feb-2003  Madhuri         	Modified the requirement
--				from	Then Basic Pay must equal the entry for the grade on Table 8 or be asterisks.
--				to	Then Basic Pay must be within the range for the grade on Table 8 or be asterisks.

if p_to_pay_plan = 'FC' and p_rate_determinant_code = '0' then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 8',
                    p_to_grade_or_level || '-' || p_to_step_or_rate,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 8',
                    p_to_grade_or_level || '-' || p_to_step_or_rate,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37825_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/*650.47.2  If pay plan is FC,
          And pay rate determinant is not C,
          Then basic pay must be within the range for the grade on
          Table 8 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
-- Update  Date  	By 			Comments
-- 20/2   27-Feb-2003  Madhuri         	Modified the requirement
--				from	Then Basic Pay must equal the entry for the grade on Table 8 or be asterisks.
--				to	Then Basic Pay must be within the range for the grade on Table 8 or be asterisks.
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_to_pay_plan = 'FC' and p_rate_determinant_code <> 'C' then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 8',
                        p_to_grade_or_level || '-' || p_to_step_or_rate,
                        'Minimum Basic Pay',p_effective_date);

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 8',
                        p_to_grade_or_level || '-' || p_to_step_or_rate,
                        'Maximum Basic Pay',p_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
         (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
          or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37826_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

/*650.48.1  If pay plan is GG,
          And grade is SL,
          And pay rate determinant is 0,
          Then basic pay must be within the range on Table 21 or
          be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/

if p_to_pay_plan = 'GG' and
   p_to_grade_or_level = 'SL'  and
   p_rate_determinant_code = '0'  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                     p_to_pay_plan ,'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                     p_to_pay_plan ,'Maximum Basic Pay',p_effective_date);

   if max_basic_pay IS NOT NULL and min_basic_pay is not null and
      (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37827_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
650.49.1  If pay plan is ND,
          And pay rate determinant is 0, 5, 6, or 7,
          Then basic pay must be within the range for the grade
          on Table 30 or Table 31 (depending on pay rate
          determinant) or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.
if p_to_pay_plan = 'ND' and
   p_rate_determinant_code in ('0','5','6','7') then
   if p_rate_determinant_code in ('0','7') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 30',
                       p_to_grade_or_level ,'Minimum Basic Pay',p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 30',
                       p_to_grade_or_level ,'Maximum Basic Pay',p_effective_date);
   elsif p_rate_determinant_code in ('5','6') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 31',
                        p_to_grade_or_level ,'Minimum Basic Pay',p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 31',
                        p_to_grade_or_level ,'Maximum Basic Pay',p_effective_date);
   end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37856_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
650.50.1  If pay plan is NG,
          And pay rate determinant is 0, 5, 6, or 7,
          Then basic pay must be within the range for the grade
          on Table 32 or Table 33 (depending on pay rate
          determinant) or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.
if p_to_pay_plan = 'NG' and
   p_rate_determinant_code in ('0','5','6','7') then -- added for bug 726125
   if p_rate_determinant_code in ('0','7') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 32',
                       p_to_grade_or_level ,'Minimum Basic Pay',p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 32',
                       p_to_grade_or_level ,'Maximum Basic Pay',p_effective_date);
   elsif p_rate_determinant_code in ('5','6') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 33',
                        p_to_grade_or_level ,'Minimum Basic Pay',p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 33',
                        p_to_grade_or_level ,'Maximum Basic Pay',p_effective_date);
   end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37858_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
650.51.1  If pay plan is NT,
          And pay rate determinant is 0, 5, 6, or 7,
          Then basic pay must be within the range for the grade
          on Table 34 or Table 35 (depending on pay rate
          determinant) or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.
if p_to_pay_plan = 'NT' and
   p_rate_determinant_code in ('0','5','6','7') then -- added for bug 726125
   if p_rate_determinant_code in ('0','7') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 34',
                       p_to_grade_or_level ,'Minimum Basic Pay',p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 34',
                       p_to_grade_or_level ,'Maximum Basic Pay',p_effective_date);
   elsif p_rate_determinant_code in ('5','6') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 35',
                       p_to_grade_or_level ,'Minimum Basic Pay',p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 35',
                       p_to_grade_or_level ,'Maximum Basic Pay',p_effective_date);
   end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37860_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/*650.53.1  If pay plan is AF, FO, or FP,
          And pay rate determinant is 0,
          Then basic pay must fall within the range for the grade
          on Table 10 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
if p_to_pay_plan in ('AF','FO','FP') and
   p_rate_determinant_code = '0' then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 10',
                    p_to_grade_or_level || '-' || p_to_step_or_rate,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 10',
                    p_to_grade_or_level || '-' || p_to_step_or_rate,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37828_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- Dec 2001 Patch -- Renamed Edit 650.57.1 to 650.57.3
/*650.57.3  If pay plan begins with W, or is XE, XF, XG, or XH,
          And pay rate determinant is not A, B, E, F, U, or V,
          Then basic pay must fall within the range for the pay
          plan on Table 11 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/

 -- Update Date   Updated By	Effective Date			Comments
 -----------------------------------------------------------------------------------------------------------
 -- 18/10/2004    Madhuri	From the start of the edit	Deleting the edit
 -----------------------------------------------------------------------------------------------------------
/*if (substr(p_to_pay_plan,1,1) = 'W' or
   p_to_pay_plan in ('XE','XF','XG','XH')) and
   p_rate_determinant_code not in ('A','B','E','F','U','V') then
   max_basic_pay := NULL;
   min_basic_pay := NULL;
   if substr(p_to_pay_plan,1,1) = 'W' and
      p_to_pay_plan not in ('WG','WL','WM','WS') then
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                    substr(p_to_pay_plan,1,1),
                                                   'Maximum Basic Pay',
                                                    p_effective_date);
   elsif p_to_pay_plan = 'XE' then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                     p_to_pay_plan,
                                                     'Minimum Basic Pay',
                                                     p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                     p_to_pay_plan,
                                                     'Maximum Basic Pay',
                                                     p_effective_date);
   else
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                     p_to_pay_plan ||'-'|| p_to_grade_or_level,
                                                     'Minimum Basic Pay',
                                                     p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                     p_to_pay_plan||'-'|| p_to_grade_or_level,
                                                     'Maximum Basic Pay',
                                                     p_effective_date);
   end if;
   if max_basic_pay is not null and
      (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37829_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if; */
 -----------------------------------------------------------------------------------------------------------

/*650.59.1  If retained pay plan begins with W, or is XF, XG, or  XH,
          Then basic pay must fall within the range for the
          retained pay plan on Table 11 or be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.

          Adds retained pay plan XE effective 1st of march 1998   */
/*
  --
  --   Commented the edit for bug 557188 on 7-aug-98
  --
if p_effective_date < fnd_date.canonical_to_date('1998/03/01') then
   if substr(p_retained_pay_plan,1,1) = 'W' or p_retained_pay_plan in ('XF','XG','XH') then
      if substr(p_retained_pay_plan,1,1) = 'W' and
         p_retained_pay_plan not in ('WG','WL','WM','WS') then
         min_basic_pay := 0; -- no check in table
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       substr(p_retained_pay_plan,1,1),
                                                       'Maximum Basic Pay',p_effective_date);
      else
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                        p_retained_pay_plan ||'-'|| p_retained_grade,
                                                       'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       p_retained_pay_plan||'-'|| p_retained_grade,
                                                       'Maximum Basic Pay',p_effective_date);
      end if;
      if max_basic_pay IS NOT NULL then
         if (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
             or p_to_basic_pay is null)
         then
            GHR_GHRWS52L.CPDF_Parameter_Check;
            hr_utility.set_message(8301,'GHR_37830_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
         end if;
      end if;
   end if;
else  -- greater than 01-mar-1998
   if substr(p_retained_pay_plan,1,1) = 'W' or p_retained_pay_plan in ('XF','XG','XH','XE') then
      if substr(p_retained_pay_plan,1,1) = 'W' and
         p_retained_pay_plan not in ('WG','WL','WM','WS') then
         min_basic_pay := 0; -- no check in table
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                       substr(p_retained_pay_plan,1,1),
                                                       'Maximum Basic Pay',p_effective_date);
      elsif p_retained_pay_plan = 'XE' then
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                        p_retained_pay_plan,
                                                       'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                        p_retained_pay_plan,
                                                        'Maximum Basic Pay',p_effective_date);
      else
         min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                        p_retained_pay_plan ||'-'|| p_retained_grade,
                                                       'Minimum Basic Pay',p_effective_date);
         max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                        p_retained_pay_plan||'-'|| p_retained_grade,
                                                        'Maximum Basic Pay',p_effective_date);
      end if;
      if max_basic_pay IS NOT NULL then
         if (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
             or p_to_basic_pay is null)
         then
            GHR_GHRWS52L.CPDF_Parameter_Check;
            hr_utility.set_message(8301,'GHR_37861_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
         end if;
      end if;
   end if;
end if;
*/

-- Update/Change Date	By			Effective Date		Comment
-- 13-Jun-06			Raju		01-Jan-03			Terminate the edit
/*650.60.1  If pay plan is VM,
          And pay rate determinant is 0,
          Then basic pay must fall within the range for the grade
          on Table 12 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
IF p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
	if p_to_pay_plan = 'VM'
	   and p_rate_determinant_code = '0'  then

	   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 12',
						p_to_grade_or_level, 'Minimum Basic Pay',p_effective_date);
	   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 12',
						p_to_grade_or_level, 'Maximum Basic Pay',p_effective_date);

	   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
		  and (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
		  or p_to_basic_pay is null)
	   then
		  GHR_GHRWS52L.CPDF_Parameter_Check;
		  hr_utility.set_message(8301,'GHR_37831_ALL_PROCEDURE_FAIL');
		  hr_utility.raise_error;
	   end if;
	end if;
END IF;

/*650.63.1  If pay plan is VP,
          And pay rate determinant is 0,
          Then basic pay must be within the range for the grade
          on Table 13 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
-- NAME		EFF DATE       COMMENTS
-- Madhuri      19-MAY-2004    Deleting the edit by commenting
--

/*if p_to_pay_plan = 'VP'
      and p_rate_determinant_code = '0'  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 13',
                    p_to_grade_or_level, 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 13',
                    p_to_grade_or_level, 'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37832_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if; */

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
650.66.1  If pay plan is VN,
          And pay rate determinant is 0,
          Then basic pay must be within the range for the grade
          on Table 14 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.
if p_to_pay_plan = 'VN'
   and p_rate_determinant_code = '0'  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 14',
                     p_to_grade_or_level, 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 14',
                    p_to_grade_or_level, 'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37833_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/*650.72.1  If pay plan is SR,
          And agency/subelement is VA,
          And pay rate determinant is 0,
          Then basic pay must be within the range on Table 16 or
          be asterisks.

          Default:  Insert asterisks in pay plan, grade, step or
                    rate, pay basis, and basic pay.

          Basis for Edit:  E.O.12496*/

-- UPD 56 (Bug# 8309414) Terminating the edit eff date 06-Jun-2007
if p_effective_date < fnd_date.canonical_to_date('2007/06/07') then
    if p_to_pay_plan = 'SR' and
       substr(p_agency_subelement,1,2) = 'VA'   and
       p_rate_determinant_code = '0'  then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 16',
                        p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 16',
                         p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
          and (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
          or p_to_basic_pay is null)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37834_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;
/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
--650.73.3
-- Update     Date        By        Effective Date   Comment
 --   9/5      08/12/99   vravikan   01-Apr-99       New Edit
If pay plan is NC, And pay rate determinant is 0, 5, 6, or 7, Then basic pay must
be within the range for the grade on Table 44 or Table 45
 (depending on pay rate determinant) or be asterisks.
  If pay rate determinant is 0 or 7 then compare to table 44.
  If pay rate determinant is 5 or 6 then compare to table 45.

if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
  if p_to_pay_plan = 'NC'  then
    if p_rate_determinant_code in ('0','7')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 44',
                    p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 44',
                     p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);

   elsif p_rate_determinant_code in ('5','6')  then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 45',
                    p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 45',
                     p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);
   end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37081_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
end if;
*/
/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
--650.74.3
-- Update     Date        By        Effective Date   Comment
 --   9/5      08/12/99   vravikan   01-Apr-99       New Edit
If pay plan is NO, And pay rate determinant is 0, 5, 6, or 7,
Then basic pay must be within the range for the grade on Table 46 or Table 47
(depending on pay rate determinant) or be asterisks.
If pay rate determinant is 0 or 7 then compare to table 46.
  If pay rate determinant is 5 or 6 then compare to table 47.

if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
  if p_to_pay_plan = 'NO'  then
    if p_rate_determinant_code in ('0','7')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 46',
                    p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 46',
                     p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);

   elsif p_rate_determinant_code in ('5','6')  then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 47',
                    p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 47',
                     p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);
   end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37078_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
--650.75.3
-- Update     Date        By        Effective Date   Comment
 --   9/5      08/12/99   vravikan   01-Apr-99       New Edit
If pay plan is NP, And pay rate determinant is 0, 5, 6, or 7,
Then basic pay must be within the range for the grade on Table 48 or Table 49
 (depending on pay rate determinant) or be asterisks.
 If pay rate determinant is 0 or 7 then compare to table 48.
  If pay rate determinant is 5 or 6 then compare to table 49.

if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
  if p_to_pay_plan = 'NP'  then
    if p_rate_determinant_code in ('0','7')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 48',
                    p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 48',
                     p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);

   elsif p_rate_determinant_code in ('5','6')  then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 49',
                    p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 49',
                     p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);
   end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37079_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
end if;
*/

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
--650.76.3
-- Update     Date        By        Effective Date   Comment
 --   9/5      08/12/99   vravikan   01-Apr-99       New Edit
If pay plan is NR, And pay rate determinant is 0, 5, 6, or 7,
 Then basic pay must be within the range for the grade on Table 50 or Table 51
 (depending on pay rate determinant) or be asterisks.
  If pay rate determinant is 0 or 7 then compare to table 50.
  If pay rate determinant is 5 or 6 then compare to table 51.
if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
  if p_to_pay_plan = 'NR'  then
    if p_rate_determinant_code in ('0','7')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 50',
                    p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 50',
                     p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);

   elsif p_rate_determinant_code in ('5','6')  then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 51',
                    p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 51',
                     p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);
   end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
      or p_to_basic_pay is null)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37080_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
end if;
*/
/*650.78.1  If pay plan is KA,
          Then basic pay must be within the range on Table 17 or
          be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
-------------------------------------------------------------------------------
-- Modified by       Date             Comments
-------------------------------------------------------------------------------
-- Madhuri          01-MAR-05         Retroactively end dating as of 31-JAN-2002
-------------------------------------------------------------------------------
IF p_effective_date <= fnd_date.canonical_to_date('20'||'02/01/31') THEN
 if p_to_pay_plan = 'KA' then
   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 17',
                    p_to_pay_plan ,
                   'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 17',
                    p_to_pay_plan ,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
         or p_to_basic_pay is null or to_number(p_to_basic_pay) = 0)
      then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37835_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
 end if;
END IF;
-------------------------------------------------------------------------------

--650.80.1  If agency/sub element is DD16,
--          And pay plan is AD or TP,
--          And pay basis is PD or SY,
--          Then basic pay must be within the range on Table 24 or
--          be asterisks.
-- Update Date        By        Effective Date            Comment
-- 16-Oct-2002      vnarasim    01-JUN-2002               New Edit
-- 28-Nov-2002      Madhuri                               If effective Date<=31stJul2002 looks
--							  into CPDF Edit Table 24 else into CPDF Table 54
/* Commented the edit for bug#2956013 on 13-Oct-2003.
if p_effective_date <= fnd_date.canonical_to_date('20'||'02/08/31') then
   if  p_agency_subelement  = 'DD16' and
       p_to_pay_plan in ('AD', 'TP') and
       p_to_pay_basis in ('PD','SY')  then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 24',
                                                     p_to_pay_plan ,
                                                     'Minimum Basic Pay',
                                                     p_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 24',
                                                     p_to_pay_plan ,
                                                     'Maximum Basic Pay',
                                                     p_effective_date);
       if max_basic_pay IS NOT NULL and
          (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
          or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37836_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('TABLE_NUMBER','24');
          hr_utility.raise_error;
       end if;
    end if;
elsif p_effective_date >= to_date('2002/09/01','yyyy/mm/dd') then
  if  p_agency_subelement  = 'DD16' and
       p_to_pay_plan in ('AD', 'TP') and
       p_to_pay_basis in ('PD','SY')  then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 54',
                                                     p_to_pay_plan ,
                                                     'Minimum Basic Pay',
                                                     p_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 54',
                                                     p_to_pay_plan ,
                                                     'Maximum Basic Pay',
                                                     p_effective_date);
       if max_basic_pay IS NOT NULL and
          (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
          or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37836_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('TABLE_NUMBER','54');
          hr_utility.raise_error;
       end if;
     end if;
 end if;
*/

/*650.84.1  If pay plan is other than GG or GS,
          And retained pay plan is GG or GS,
          And retained step is 01 through 10,
          And pay rate determinant is E, F, or M,
          Then basic pay must be equal to or less than the entry
          for the retained grade on Table 19 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
/*
  --
  --   Commented the edit for bug 557188 on 7-aug-98
  --
if not(p_to_pay_plan in ('GS','GG'))
   and p_retained_pay_plan in ('GS','GG')
   and p_retained_step between '01' and '10'
   and p_rate_determinant_code in ('E','F','M')  then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 19',
                                                 p_retained_grade,
                                                 'Maximum Basic Pay',p_effective_date);

   if max_basic_pay IS NOT NULL and
     (not(to_number(p_to_basic_pay) < max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37840_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/*650.85.1  If pay plan is other than GH or GM,
          And retained pay plan is GH or GM,
          And pay rate determinant is A or B,
          Then basic pay must fall within the range for the
          retained grade and retained step on Table 3 or be
          asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
/*
  --
  --   Commented the edit for bug 557188 on 7-aug-98
  --
if not(p_to_pay_plan in ('GH','GM'))
   and p_retained_pay_plan in ('GH','GM')
   and p_rate_determinant_code in ('A','B')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                 p_retained_grade ||'-'|| p_retained_step,
                                                 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 3',
                                                 p_retained_grade ||'-'|| p_retained_step,
                                                 'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL and
      (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null
      or to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37841_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/*650.86.3  If pay plan is GS,
          And pay rate determinant is 5, 6, or M,
          Then basic pay must be equal to or less than the entry
          for grade on Table 19 or be asterisks.
          Default:  Insert asterisks in pay basis and basic pay.*/
-- Update Date        By        Effective Date            Comment
-- 06-Feb-2003      Madhuri			    Modified condition as
--						    p_to_basic_pay <= Max_basic_pay
--
/* Commenting the edit as per the bug 3147737

if p_to_pay_plan = 'GS'
   and p_rate_determinant_code in ('5','6','M')  then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 19',
                                                 p_to_grade_or_level,
                                                 'Maximum Basic Pay',p_effective_date);

   if max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) <= max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37842_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/
/*650.87.1  If pay plan is other than GH or GM,
          And retained pay plan is GH or GM,
          And pay rate determinant is E, F, or M,
          Then basic pay must fall within the range for the
          retained grade on Table 20 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
/*
  --
  --   Commented the edit for bug 557188 on 7-aug-98
  --
if not(p_to_pay_plan in ('GM','GH'))
   and p_retained_pay_plan in ('GM','GH')
   and p_rate_determinant_code in ('E','F','M') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                    p_retained_grade,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                    p_retained_grade,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37843_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/*650.92.1  If pay plan is GG or GS,
          And pay rate determinant is E, F, or M,
          And retained pay plan is GG or GS,
          And retained step is 01 through 10,
          And retained grade is equal to or higher than grade,
          Then basic pay must be equal to or less than the entry
          for the retained grade on Table 19 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/

/* Commenting the edit as per the bug 3147737
if p_to_pay_plan in ('GS','GG')
   and p_retained_pay_plan in ('GS','GG')
   and p_rate_determinant_code in ('E','F','M')
   and p_retained_step between '01' and '10'  then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 19',
                                                 p_retained_grade,
                                                 'Maximum Basic Pay',p_effective_date);

   if max_basic_pay IS NOT NULL
      and p_retained_grade >= p_to_grade_or_level
      and (not(to_number(p_to_basic_pay) < max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37845_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/
/* Commented as per December 2000 cpdf changes -- vravikan
650.95.1  If pay plan is GH or GM,
          And pay rate determinant is E, F, or M,
          And retained grade is equal to or higher than grade,
          And retained pay plan is GH or GM,
          Then basic pay must fall within the range for the
          retained grade on Table 20 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.

if p_to_pay_plan in ('GM','GH')
   and p_retained_pay_plan in ('GM','GH')
   and p_rate_determinant_code in ('E','F','M') then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                                                 p_retained_grade,
                                                 'Minimum Basic Pay',p_effective_date);
   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 20',
                                                 p_retained_grade,
                                                 'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and p_retained_grade >= p_to_grade_or_level
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37846_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;
*/

/*650.96.1  If pay plan is AL,
          And pay rate determinant is not C,
          Then basic pay must match the entry for the grade and
          step or rate  on Table 22 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.

          Basis for Edit:  5 U.S.C. 5372*/

if p_to_pay_plan = 'AL'
   and p_rate_determinant_code <> 'C'  then
   if p_to_grade_or_level in ('01', '02') then
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 22',
                       p_to_grade_or_level,
                       'Maximum Basic Pay',
                       p_effective_date);
   else
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 22',
                       p_to_grade_or_level || '-' ||p_to_step_or_rate,
                       'Maximum Basic Pay',
                       p_effective_date);
   end if;
   if max_basic_pay IS NOT NULL
      and (to_number(p_to_basic_pay) <> max_basic_pay
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37847_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/*650.97.1  If pay plan is CA,
          And pay rate determinant is not C,
          Then basic pay must match the entry on Table 23 for the
          grade or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.

          Basis for Edit:  5 U.S.C. 5372a*/
if p_to_pay_plan = 'CA'
   and p_rate_determinant_code <> 'C'  then

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 23',
                    p_to_grade_or_level,
                    'Minimum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (to_number(p_to_basic_pay) <> max_basic_pay
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37848_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

/*650.98.1  If pay plan is ST or SL,
          And pay rate determinant is not C,
          Then basic pay must fall within the range on Table 21
          or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.

          Basis for Edit:  5 U.S.C. 5376*/
-- Upd57  30-Jul-09       Mani       Bug # 8653515  14-OCT-2008 Added PRD D in the condition

if p_effective_date < fnd_date.canonical_to_date('2008/10/14') then
  if p_to_pay_plan in ('ST', 'SL')
   and p_rate_determinant_code NOT IN ('C')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                    p_to_pay_plan ,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                    p_to_pay_plan ,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37849_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PRD','not C');
      hr_utility.raise_error;
   end if;
 end if;
else
  if p_to_pay_plan in ('ST', 'SL')
   and p_rate_determinant_code NOT IN ('C','D')  then

   min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                    p_to_pay_plan ,
                    'Minimum Basic Pay',p_effective_date);

   max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 21',
                    p_to_pay_plan ,
                    'Maximum Basic Pay',p_effective_date);

   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
      and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay)
      or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
   then
      GHR_GHRWS52L.CPDF_Parameter_Check;
      hr_utility.set_message(8301,'GHR_37849_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PRD','not C or D');
      hr_utility.raise_error;
   end if;
 end if;
end if;


/* 650.99.3  If pay plan is IJ,
          And pay rate determinant is 0 or 7,
          Then basic pay must match the entry for the step or
          rate on Table 36 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay. */
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_to_pay_plan = 'IJ' and
       p_rate_determinant_code in ('0','7') then

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 36',
                                                     p_to_step_or_rate ,
                                                     'Maximum Basic Pay',
                                                     p_effective_date);
       if max_basic_pay IS NOT NULL and
          (not(to_number(p_to_basic_pay) <> max_basic_pay)
          or p_to_basic_pay is null)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_38551_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;
/*650.53.2  If pay plan is AF, FO, or FP,
          And pay rate determinant is not C,
          Then basic pay must fall within the range for the grade
          on Table 10 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_to_pay_plan in ('AF','FO','FP')
       and p_rate_determinant_code <> 'C'  then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 10',
                        p_to_grade_or_level || '-' || p_to_step_or_rate,
                        'Minimum Basic Pay',p_effective_date);

       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 10',
                        p_to_grade_or_level || '-' || p_to_step_or_rate,
                        'Maximum Basic Pay',p_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
          and (not(to_number(p_to_basic_pay) between min_basic_pay and max_basic_pay )
          or p_to_basic_pay is null and to_number(p_to_basic_pay) = 0)
       then
          GHR_GHRWS52L.CPDF_Parameter_Check;
          hr_utility.set_message(8301,'GHR_37850_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

-- Dec 2001 Patch -- Rename Edit 650.57.2 to 650.57.3
-- Commenting this one as there are two 650.57.3 edits
/*650.57.3  If pay plan is W-, XE, XF, XG, or XH,
          And pay rate determinant is not A, B, E, F, U, or V,
          Then basic pay must fall within the range for the pay
          plan on Table 11 or be asterisks.

          Default:  Insert asterisks in pay basis and basic pay.

if (substr(p_to_pay_plan,1,1) = 'W' or
    p_to_pay_plan in ('XE','XF','XG','XH')) and
   p_rate_determinant_code not in ('A','B','E','F','U','V') then
   max_basic_pay := NULL;
   min_basic_pay := NULL;
   if substr(p_to_pay_plan,1,1) = 'W' and p_to_pay_plan not in ('WG','WL','WM','WS') then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                    substr(p_to_pay_plan,1,1),
                                                    'Minimum Basic Pay',p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                     substr(p_to_pay_plan,1,1),
                                                    'Maximum Basic Pay',p_effective_date);
   elsif p_to_pay_plan = 'XE' then
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                    p_to_pay_plan,
                                                    'Minimum Basic Pay',p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                    p_to_pay_plan,
                                                    'Maximum Basic Pay',p_effective_date);
   else
      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                    p_to_pay_plan ||'-'|| p_to_grade_or_level,
                                                    'Minimum Basic Pay',p_effective_date);
      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 11',
                                                    p_to_pay_plan ||'-'|| p_to_grade_or_level,
                                                    'Maximum Basic Pay',p_effective_date);
   end if;
   if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL then
      if (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
         or p_to_basic_pay is null)
      then
         GHR_GHRWS52L.CPDF_Parameter_Check;
         hr_utility.set_message(8301,'GHR_37851_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if;
*/
/*650.72.2  If pay plan is SR,
          And pay rate determinant is not C,
          And agency/subelement is VA,
          Then basic pay must be within the range shown on
          Table 16 or be asterisks.

          Default:  Insert asterisks in pay plan, grade, step or
                    rate, pay basis, and basic pay.

          Basis for Edit:  E.O. 12496*/
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_to_pay_plan = 'SR' and
       substr(p_agency_subelement,1,2) = 'VA'  and
       p_rate_determinant_code <> 'C'  then

       min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 16',
                        p_to_pay_plan , 'Minimum Basic Pay',p_effective_date);
       max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 16',
                        p_to_pay_plan , 'Maximum Basic Pay',p_effective_date);

       if min_basic_pay IS NOT NULL and max_basic_pay IS NOT NULL
          and (not(to_number(p_to_basic_pay) between nvl(min_basic_pay,0) and nvl(max_basic_pay,0))
          or p_to_basic_pay is null)
       then
           GHR_GHRWS52L.CPDF_Parameter_Check;
              hr_utility.set_message(8301,'GHR_37853_ALL_PROCEDURE_FAIL');
              hr_utility.raise_error;
      end if;
    end if;
end if;
hr_utility.set_location('Leaving CPDF 8 ',1);
end basic_pay;
end ghr_cpdf_check8;

/
