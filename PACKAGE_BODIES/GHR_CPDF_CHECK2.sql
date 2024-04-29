--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK2" as
/* $Header: ghcpdf02.pkb 120.15.12010000.3 2009/07/30 08:28:19 vmididho ship $ */
--
--
/* Name:
     Instructional Program
*/
procedure chk_instructional_pgm
  (p_education_level         in varchar2
  ,p_academic_discipline     in varchar2
  ,p_year_degree_attained    in varchar2
  ,p_first_noac_lookup_code  in varchar2
  ,p_effective_date          in date
  ,p_tenure_group_code       in varchar2
  ,p_to_pay_plan             in varchar2
  ,p_employee_date_of_birth  in Date
  ) is
begin

-- 005.02.3
   if  to_number(p_education_level) > 12
     and
       p_academic_discipline is null
     then
       hr_utility.set_message(8301, 'GHR_37101_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
    end if;
------

-- 780.04.3
--  Update date      By       Start Date          Comment
--  28-Nov-2002   Madhuri     From the begining   added education level cond to edit
-- this edit has been renamed from 005.04.3
   if  p_academic_discipline is not null
     and
       p_year_degree_attained is null
     and
        to_number(p_education_level) not in (14,16,18,20,22)
     then
       hr_utility.set_message(8301, 'GHR_37102_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 005.07.1
-- 28-NOV-02     Madhuri      End dated the edit with 31-July-2002

  if p_effective_date <= to_date('2002/07/31','yyyy/mm/dd') then
   if (
	  p_education_level <>'06' and
        p_education_level <>'10' and
        to_number(p_education_level) < 13
	) and
     (p_academic_discipline is not null or p_year_degree_attained is not null )
     then
       hr_utility.set_message(8301, 'GHR_37103_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
  end if;

--   780.05.1
  -- this edit has been renamed from 005.10.1
  if  p_year_degree_attained is not null
    and
      p_employee_date_of_birth is not null
    and
      (
       to_number(p_year_degree_attained) <
      (to_number(to_char(p_employee_date_of_birth,'YYYY'))+17)
      )
   then
       hr_utility.set_message(8301, 'GHR_37104_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 005.13.2

-- updation Date     By       Comment
-- 28-NOV-2002     Madhuri  End dated the edit as of 31-Jul-2002

if p_effective_date<=to_date('2002/07/31','yyyy/mm/dd') then
   if (
          p_education_level <> '06' and  p_education_level <> '10'
        and
       to_number(p_education_level) < 13
      )
     and
      (
       p_academic_discipline is not null
       or
       p_year_degree_attained is not null
      )
     then
       hr_utility.set_message(8301, 'GHR_37105_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
  end if;

-- 005.13.3
--  28-NOV-2002  Madhuri  Created the edit from 01-Aug-2002
--  30-DEC-2002  VNARASIM Changed condition "to_number(p_education_level) >= 13" to
--                        "to_number(p_education_level) < 13".

 if  p_effective_date >= to_date('2002/08/01','yyyy/mm/dd') then
  if (
       p_education_level <> '06' and  p_education_level <> '10'
        and
       to_number(p_education_level) < 13
      )
     and
      (
       p_academic_discipline is not null
       or
       p_year_degree_attained is not null
      )
      then
       hr_utility.set_message(8301, 'GHR_37927_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
end if;

-- 005.15.2
   if  substr(p_first_noac_lookup_code,1,1)='1'
     and
       p_effective_date > TO_DATE('1993/09/30', 'YYYY/MM/DD')
     and
      (p_tenure_group_code ='1' or p_tenure_group_code= '2' )
     and
      (p_education_level ='06' or p_education_level='10' )
     and
      (p_academic_discipline is null or p_year_degree_attained is null)
     then
       hr_utility.set_message(8301, 'GHR_37106_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 005.20.2
   if  substr(p_first_noac_lookup_code,1,1)='1'
     and
       p_effective_date > TO_DATE('1993/09/30', 'YYYY/MM/DD')
     and
       p_to_pay_plan ='ES'
     and
      (p_education_level ='06' or p_education_level='10' )
     and
      (p_academic_discipline is  null or p_year_degree_attained is null)
     then
       hr_utility.set_message(8301, 'GHR_37107_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

end chk_instructional_pgm;

/* Name:
     chk_Award_Amount
*/

procedure chk_Award_Amount
  (p_First_NOAC_Lookup_Code      in varchar2
   -- Bug#4486823 RRR Changes
  ,p_First_NOAC_Lookup_desc       in varchar2
  ,p_One_Time_Payment_Amount     in number
  ,p_To_Basic_Pay                in number
  ,p_Adj_Base_Pay                in number
  ,p_First_Action_NOA_LA_Code1   in varchar2
  ,p_First_Action_NOA_LA_Code2   in varchar2
  ,p_to_pay_plan                 in varchar2
  ,p_effective_date              in date
) is
begin

-- 050.02.2
   -- Award Req  8/15/00   vravikan    30-sep-2000    End date
   --                      vravikan    01-Oct-2000    Add 840-847
   --                      vnarasim    01-OCT-2000    Add 848
   --                      Ashley      10-OCT-2003    Add 849
   --                      vnarasim    22-MAR-2006    Removed 825
   --  UPD 50(Bug 5745356) Raju		   01-Oct-2006	  Delete 849
   --  UPD 51(Bug 5745356) Raju		   From 01-Jan-2007	  add NOAs 826,849,885,886,887,889
   -- 825 removed from the this edit as 825 is moved to incentive family

 if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
   if  (p_First_NOAC_Lookup_Code in ('817', '849','872','873','874',
                                     '875','876','877','878','879','885','889') OR
        (p_First_NOAC_Lookup_Code = '815' AND p_First_NOAC_Lookup_desc = 'Recruitment Bonus') OR
        (p_First_NOAC_Lookup_Code = '816' AND p_First_NOAC_Lookup_desc = 'Relocation Bonus')
        ) and
      (p_One_Time_Payment_Amount <= 0 or
       p_One_Time_Payment_Amount is null)
     then
       hr_utility.set_message(8301, 'GHR_37108_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
 elsif p_effective_date < to_date('2006/10/01','yyyy/mm/dd') then

   if  (p_First_NOAC_Lookup_Code in ('817', '840','841','842','843',
                                    '844','845','846','847','848','849','878','879') OR
        (p_First_NOAC_Lookup_Code = '815' AND p_First_NOAC_Lookup_desc = 'Recruitment Bonus') OR
        (p_First_NOAC_Lookup_Code = '816' AND p_First_NOAC_Lookup_desc = 'Relocation Bonus')
        ) and
       (p_One_Time_Payment_Amount <= 0 or
       p_One_Time_Payment_Amount is null)
     then
       hr_utility.set_message(8301, 'GHR_37414_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('NOA_CODE','815, 816, 817, 840 through 849, 878, or 879');
       hr_utility.raise_error;
   end if;
  elsif p_effective_date < to_date('2007/01/01','yyyy/mm/dd') then
    if  (p_First_NOAC_Lookup_Code in ('817', '840','841','842','843',
                                        '844','845','846','847','848','878','879') OR
        (p_First_NOAC_Lookup_Code = '815' AND p_First_NOAC_Lookup_desc = 'Recruitment Bonus') OR
        (p_First_NOAC_Lookup_Code = '816' AND p_First_NOAC_Lookup_desc = 'Relocation Bonus')
        ) and
        (p_One_Time_Payment_Amount <= 0 or
        p_One_Time_Payment_Amount is null)
    then
    hr_utility.set_message(8301, 'GHR_37414_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('NOA_CODE','815, 816, 817, 840 through 848, 878, or 879');
    hr_utility.raise_error;
    end if;
  else
    if  (p_First_NOAC_Lookup_Code in ('817', '826', '840','841','842','843',
                                        '844','845','846','847','849','848','878','879','885','886','887','889') OR
        (p_First_NOAC_Lookup_Code = '815' AND p_First_NOAC_Lookup_desc = 'Recruitment Bonus') OR
        (p_First_NOAC_Lookup_Code = '816' AND p_First_NOAC_Lookup_desc = 'Relocation Bonus')
        ) and
        (p_One_Time_Payment_Amount <= 0 or
        p_One_Time_Payment_Amount is null)
    then
    hr_utility.set_message(8301, 'GHR_37414_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('NOA_CODE','815, 816, 817, 826, 840 through 849, 878, 879, 885, 886, 887 or 889');
    hr_utility.raise_error;
    end if;
  end if;

-- 050.04.2
   -------------------------------------------------------------------------
   --                    Modified by     Date        Comments
   -------------------------------------------------------------------------
   -- Award Req  8/15/00   vravikan    30-sep-2000    End date
   --                                  01-Oct-2000    Add 840-847
   --                      vnarasim    01-Oct-2000    Add 848
   --                      Ashley      30-OCT-2003    Add 849
   --	UPD 38		   Madhuri     01-MAR-2005    add 826, 827 to list
   --  UPD 41(Bug 4567571) Raju	       08-Nov-2005    Delete 827 from list
   --                      vnarasim    22-Mar-2006    Delete 825
   --                      vnarasim    12-APR-2006    Added 825.
   --  UPD 50(Bug 5745356) Raju	       01-Oct-2006    Delete 849
   --  UPD 51(Bug 5911585) AVR         03-MAR-2007    Delete the edit as of 01-JAN-2004.
   -------------------------------------------------------------------------
 if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
   if  p_One_Time_Payment_Amount is not null
     and
       p_First_NOAC_Lookup_Code not in  ('815','816','817','825','826','849',
                                         '872','873','874','875',
                                         '876','877','878','879','885','889')
     then
       hr_utility.set_message(8301, 'GHR_37109_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
 -----elsif p_effective_date < to_date('2006/10/01','yyyy/mm/dd') then
 elsif p_effective_date < to_date('2004/01/01','yyyy/mm/dd') then
   if  p_One_Time_Payment_Amount is not null
     and
       p_First_NOAC_Lookup_Code not in  ('815','816','817','825','826','840','841',
                                         '842','843','844','845','846',
                                         '847','848','849','878','879',
					 '885','886','887','889') --bug 5482191
     then
       hr_utility.set_message(8301, 'GHR_37415_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('NOA_CODE','815, 816, 817, 825, 840 through 849, 878, or 879');
       hr_utility.raise_error;
   end if;
  else
       null;
/***** Commented by AVR  for Bug 5911585
   if  p_One_Time_Payment_Amount is not null and
       p_First_NOAC_Lookup_Code not in  ('815','816','817','825','826','840','841',
                                         '842','843','844','845','846',
                                         '847','848','878','879',
					                     '885','886','887','889')
     then
       hr_utility.set_message(8301, 'GHR_37415_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('NOA_CODE','815, 816, 817, 825, 840 through 848, 878, or 879');
       hr_utility.raise_error;
   end if;
************* AVR  - Bug 5911585 end   ******/
 end if;
   -------------------------------------------------------------------------

--           17-Aug-00   vravikan   From the Start           Change from equal to 25% of basic+locality adj.
--                                                            to not more than 25% of basic+locality adj.
-- 050.06.2
   if  p_First_NOAC_Lookup_Code ='819'
     and
        p_One_Time_Payment_Amount <>0
     and
	p_One_Time_Payment_Amount is not null
     and
        round(p_One_Time_Payment_Amount,0) > round(.25*(p_Adj_Base_Pay),0)
     then
       hr_utility.set_message(8301, 'GHR_37110_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

--Commented as per EOY 2003 cpdf changes by Ashley
-- 050.07.2
-- Award Req  8/15/00   vravikan    30-sep-2000    End date
  /* if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
   if  p_First_NOAC_Lookup_Code ='889'
     and
       p_To_Pay_Plan ='GM'
     and
       p_One_Time_Payment_Amount > (p_TO_Basic_Pay * .20)
     then
       hr_utility.set_message(8301, 'GHR_37111_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
end if;*/

-- 050.10.2
   if  p_First_NOAC_Lookup_Code ='818'
     and
     not
      (p_One_Time_Payment_Amount = 0
       or
       p_One_Time_Payment_Amount between 10 and 25)
     and
        p_One_Time_Payment_Amount is not null
     then
       hr_utility.set_message(8301, 'GHR_37112_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 050.15.2
   if  p_First_NOAC_Lookup_Code ='818'
     and
      (substr(p_To_Pay_Plan,1,1) in ('B','W','X')
       or
       p_To_Pay_Plan ='ES')
     then
       hr_utility.set_message(8301, 'GHR_37113_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 050.20.2
--  UPD 41(Bug 4567571) Raju		   08-Nov-2005	  Terminate from 01-May-2002
if p_effective_date < to_date('2002/05/01','yyyy/mm/dd') then
   if  p_First_NOAC_Lookup_Code ='815'
     and
       p_One_Time_Payment_Amount > .25 * p_TO_Basic_Pay
     and
       p_One_Time_Payment_Amount is not null
     then
       hr_utility.set_message(8301, 'GHR_37114_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
 End if;


--Commented as per EOY 2003 cpdf changes by Ashley
-- 050.28.2
-- Award Req  8/15/00   vravikan    30-sep-2000    End date
 /*  if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
   if  p_First_NOAC_Lookup_Code ='873'
     and
       p_One_Time_Payment_Amount >  (.05* p_TO_Basic_Pay)
     then
       hr_utility.set_message(8301, 'GHR_37115_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
  end if;*/

-- 050.30.2

--  UPD 41(Bug 4567571) Raju		   08-Nov-2005	  Terminate from 01-May-2002
if p_effective_date < to_date('2002/05/01','yyyy/mm/dd') then
   if  p_First_NOAC_Lookup_Code ='816'
     and
      (p_First_Action_NOA_LA_Code1 <>'ZTY' or p_First_Action_NOA_LA_Code2 <> 'ZTY' )
     and
       p_One_Time_Payment_Amount > (.25* p_TO_Basic_Pay)
     then
       hr_utility.set_message(8301, 'GHR_37116_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
End if;

-- 050.35.2

--  UPD 41(Bug 4567571) Raju		   08-Nov-2005	  Terminate from 01-May-2002
if p_effective_date < to_date('2002/05/01','yyyy/mm/dd') then
   if  p_First_NOAC_Lookup_Code ='816'
     and
      (p_First_Action_NOA_LA_Code1 ='ZTY' or p_First_Action_NOA_LA_Code2 = 'ZTY' )
     and
       p_One_Time_Payment_Amount > (.25* p_TO_Basic_Pay)
     and
       p_One_Time_Payment_Amount > 15000
     then
       hr_utility.set_message(8301, 'GHR_37117_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
End if;
/*
-- 050.40.2
   if  p_First_NOAC_Lookup_Code ='825'
     and
       p_One_Time_Payment_Amount > 25000
     then
       hr_utility.set_message(8301, 'GHR_37118_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;*/

end chk_Award_Amount;

/* Name:
--  C_Benefit_Amount
*/

procedure chk_Benefit_Amount
  (p_First_NOAC_Lookup_Code      in varchar2
  ,p_Benefit_Amount              in varchar2   -- non SF52
  ,p_effective_date              in date
) is
begin

--Commented as per EOY 2003 cpdf changes by Ashley
-- 070.02.2
-- Award Req  8/15/00   vravikan    30-sep-2000    End date
/*   if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
if    p_Benefit_Amount is not null
   and
      p_First_NOAC_Lookup_Code not in ('872','874','875','876','877')
   then
      hr_utility.set_message(8301, 'GHR_37165_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;

end if;
end if;*/
null;

end chk_Benefit_Amount;


/* Name:
     chk_Cur_Appt_Auth
*/

procedure chk_Cur_Appt_Auth
  (p_First_Action_NOA_LA_Code1         in varchar2
  ,p_First_Action_NOA_LA_Code2         in varchar2
  ,p_Cur_Appt_Auth_1                   in varchar2  -- non SF52 item
  ,p_Cur_Appt_Auth_2                   in varchar2  -- non SF52 item
  ,p_Agency_Subelement                 in varchar2  -- non SF52 item
  ,p_To_OCC_Code                       in varchar2
  ,p_First_NOAC_Lookup_Code            in varchar2
  ,p_Position_Occupied_Code            in varchar2
  ,p_To_Pay_Plan                       in varchar2
  ,p_Handicap                          in varchar2  -- non SF52 item
  ,p_Tenure_Goupe_Code                 in varchar2
  ,p_To_Grade_Or_Level                 in varchar2
  ,p_Vet_Pref_Code                     in varchar2
  ,p_Duty_Station_Lookup_Code          in varchar2
  ,p_Service_Computation_Date          in date
  ,p_effective_date                    in date
  ) is
l_Service_Computation_Date 	Date;
begin

-- 100.02.3
   -- renamed the edit from 100.01.3 for the april release
   if
      (
      p_Cur_Appt_Auth_1= 'ZVB' or p_Cur_Appt_Auth_2='ZVB'
      )
    and
      p_Agency_Subelement <> 'TD03'
    then
       hr_utility.set_message(8301, 'GHR_37119_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

/* Commented as per December 2000 cpdf changes -- vravikan
--
-- 100.03.3   If either current appointment authority is ZTA,
--            And position occupied is 1,
--            Then agency/subelement must be DJ03.
   if p_effective_date >= fnd_date.canonical_to_date('1998/09/01') then
      if ( p_Cur_Appt_Auth_1= 'ZTA' or p_Cur_Appt_Auth_2='ZTA' )  and
         p_Position_Occupied_Code = '1' and
         p_Agency_Subelement <> 'DJ03'  then
         hr_utility.set_message(8301, 'GHR_37892_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;

*/
--  100.04.1
-- Dec. 2001 Patch --- Delete YAM
   if  (
	p_Cur_Appt_Auth_1 in ('YBM','YGM','Y1M','Y2M','Y3M')
        or
        p_Cur_Appt_Auth_2 in ('YBM','YGM','Y1M','Y2M','Y3M')
        )
     and
        p_to_pay_plan = 'GS'
     and
	substr(p_to_occ_code,3,2) <>'99'
     and
        p_to_occ_code is not null
    then
       hr_utility.set_message(8301, 'GHR_37120_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

/*  same as 100.04.1
-- 100.05.2
   if
      (
       p_Cur_Appt_Auth_1 in ('YAM','YBM','YGM','Y1M','Y2M','Y3M')
       or
       p_Cur_Appt_Auth_2 in ('YAM','YBM','YGM','Y1M','Y2M','Y3M')
      )
    and
       p_To_Pay_Plan='GS'
    and
       substr(p_To_OCC_Code,3,2) <> '99'
    and
       p_To_OCC_Code is not null
    then
       hr_utility.set_message(8301, 'GHR_37120_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
*/
--100.06.3
--  Updation Date    Updated By     Remarks
--  ============================================
--  19-MAR-2003      vnarasim       Added agency/subelement HSBC.
--  30-OCT-2003      Ashley         Deleted agency/subelement TD19
--
  if  p_effective_date >= fnd_date.canonical_to_date('20'||'00/10/01') then
     if (p_Cur_Appt_Auth_1 = 'ZVC' OR p_Cur_Appt_Auth_2 = 'ZVC') AND
         (p_agency_subelement NOT IN ('HSBC'))
      then
       hr_utility.set_message(8301, 'GHR_37925_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
      end if;
  end if;
-- 100.07.3
   if
      (p_Cur_Appt_Auth_1 in ('Y1K','Y2K','Y3K','Y4K','Y5K')
       or
       p_Cur_Appt_Auth_2 in ('Y1K','Y2K','Y3K','Y4K','Y5K')
      )
     and
       p_Tenure_Goupe_Code <> '0'
     and
       p_Tenure_Goupe_Code <> '3'
     and
       p_Tenure_Goupe_Code is not null
     then
       hr_utility.set_message(8301, 'GHR_37121_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
-- Update Date        By        Effective Date            Comment
--   11  01/03/00    vravikan   11/01/99                  Add Edit

-- 100.09.3   If either current appointment authority is UDM
--            Then agency must be TR.
   if p_effective_date >= fnd_date.canonical_to_date('19'||'99/11/01') then
      if ( p_Cur_Appt_Auth_1= 'UDM' or p_Cur_Appt_Auth_2='UDM' )  and
         substr(p_Agency_Subelement,1,2) <> 'TR'  then
         hr_utility.set_message(8301, 'GHR_37411_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;


--  100.10.3 --100.10.1 Renumbered this edit to 100.10.3
 -- Dec 01 Patch 12/10/01    vravikan        Delete KDM, KFM, KHM
 --upd49  08-Jan-07	Raju	 From 01-Sep-2006	 Delete JYM
 if p_effective_date < fnd_date.canonical_to_date('2006/09/01') then
  if  (p_Cur_Appt_Auth_1 in ('BPM','H2L','J8M',
          'JYM','UFM','V8K','VEM','VPE','ZVB','ZVC')
       or
         substr(p_Cur_Appt_Auth_1,1,1) in ('W','X','Y')
       or
       p_Cur_Appt_Auth_2 in ('BPM','H2L','J8M',
          'JYM','UFM','V8K','VEM','VPE','ZVB','ZVC')
       or
         substr(p_Cur_Appt_Auth_2,1,1) in ('W','X','Y')
      )
     and
         p_position_occupied_code <>'2'
     and
         p_position_occupied_code is not null
     then
       hr_utility.set_message(8301, 'GHR_37122_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('APP_AUTH',
       'BPM, H2L, J8M, JYM, UFM, V8K, VEM, VPE, W--, X--, Y--, ZVB or ZVC');
       hr_utility.raise_error;
   end if;
 else
    if  (p_Cur_Appt_Auth_1 in ('BPM','H2L','J8M',
         'UFM','V8K','VEM','VPE','ZVB','ZVC') or
        substr(p_Cur_Appt_Auth_1,1,1) in ('W','X','Y') or
        p_Cur_Appt_Auth_2 in ('BPM','H2L','J8M',
            'UFM','V8K','VEM','VPE','ZVB','ZVC') or
        substr(p_Cur_Appt_Auth_2,1,1) in ('W','X','Y')
        ) and
        p_position_occupied_code <>'2' and
        p_position_occupied_code is not null
    then
    hr_utility.set_message(8301, 'GHR_37122_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('APP_AUTH',
       'BPM, H2L, J8M, UFM, V8K, VEM, VPE, W--, X--, Y--, ZVB or ZVC');
    hr_utility.raise_error;
    end if;
 end if;

-- 100.11.2
-- Dec 01 Patch 12/10/01    vravikan        Delete KDM, KFM, KHM, and TXX
--upd47  26-Jun-06	Raju	   From 01-Apr-2003		             Terminate the edit
	if p_effective_date < fnd_date.canonical_to_date('2003/04/01') then
	   if ( p_Cur_Appt_Auth_1  in ('BPM','H2L','J8M','JYM',
								   'UFM','V8K','VEM','VPE','ZVB','ZVC') or
		   substr(p_Cur_Appt_Auth_1,1,1) in ('W','X','Y') or
		   p_Cur_Appt_Auth_2  in ('BPM','H2L','J8M','JYM',
								  'UFM','V8K','VEM','VPE','ZVB','ZVC') or
		   substr(p_Cur_Appt_Auth_2,1,1) in ('W','X','Y')) and
		  (to_number(p_First_NOAC_Lookup_Code) not between 100 and 199  and
		   to_number(p_First_NOAC_Lookup_Code) not between 500 and 599
		  ) and
		   p_Position_Occupied_Code <> '2' and
		   p_Position_Occupied_Code is not null
		then
		   hr_utility.set_message(8301, 'GHR_37123_ALL_PROCEDURE_FAIL');
		   hr_utility.raise_error;
	   end if;
	end if;

--100.12.1
   -- Update Date        By        Effective Date            Comment
   --   8   04/01/99    vravikan   10/01/98                  Add Edit
   --   48  26/09/06    amrchakr   01-jul-2006               Changed edit number from 100.12.1 to 100.12.3
  if p_effective_date >= fnd_date.canonical_to_date('1998/10/01') then
   if
      (
       p_Cur_Appt_Auth_1  in ('ZRL')
       or
       p_Cur_Appt_Auth_2  in ('ZRL') )
     and
       p_agency_subelement <> 'DJ02'
     and
       p_agency_subelement is not null
    then
        if p_effective_date < fnd_date.canonical_to_date('2006/07/01') then
            hr_utility.set_message(8301, 'GHR_37055_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        else
            hr_utility.set_message(8301, 'GHR_37691_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
   end if;
  end if;

-- 100.12.2
   --
   -- 100.12.3 is renumbered as 100.12.2 from 01-mar-1998
   -- Hence effective date was introduced.
   --
   -- Update Date        By        Effective Date            Comment
   --   8   04/19/99    vravikan   09/01/1998                Date Correction
   --                                                   from 1-mar-98 to 1-sep-98
   --                                                       Adding LAC P2M
   if p_effective_date < fnd_date.canonical_to_date('1998/09/01') then
      if  p_To_Pay_Plan = 'ES'  and
          p_Cur_Appt_Auth_1 not in ('NRM','NSM','NTM','NVM','NWM','NXM','P2M','P3M','P5M','P7M',
                                    'V2M','VAG','VBJ','VCJ','V4L','V4M','V6M','V4P')  and
          p_Cur_Appt_Auth_1 is not null  then
          hr_utility.set_message(8301, 'GHR_37124_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
      end if;
   end if;

-- 100.13.3  -- 100.13.1 renumbered as 100.13.3
   --
   -- This is renumbered from  100.12.3 B-9 from 01-mar-1998
   --
   --   8   04/19/99    vravikan   09/01/1998                Date Correction
   --                                                   from 1-mar-98 to 1-sep-98
   --                                                       Adding LAC P2M
   if p_effective_date >= fnd_date.canonical_to_date('1998/09/01') then
      if  p_To_Pay_Plan = 'ES'  and
          p_Cur_Appt_Auth_1 not in ('NRM','NSM','NTM','NVM','NWM','NXM','P2M','P3M','P5M','P7M',
                                    'V2M','VAG','VBJ','VCJ','V4L','V4M','V6M','V4P')  and
          p_Cur_Appt_Auth_1 is not null  then
          hr_utility.set_message(8301, 'GHR_37875_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
      end if;
   end if;

-- 100.14.3
   -- Dec 2001 Patch    1-Nov-01             Add AUM
   if p_effective_date >= to_date('2001/11/01','yyyy/mm/dd') THEN
   if  p_To_Pay_Plan = 'ES'
     and
       p_Cur_Appt_Auth_2 not in ('AUM','AWM','BWM','HAM','ZLM')
     and
       p_Cur_Appt_Auth_2 is not null
     then
       hr_utility.set_message(8301, 'GHR_37125_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
   else
   if  p_To_Pay_Plan = 'ES'
     and
       p_Cur_Appt_Auth_2 not in ('AUM','AWM','BWM','HAM','ZLM')
     and
       p_Cur_Appt_Auth_2 is not null
     then
       hr_utility.set_message(8301, 'GHR_37125_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
   end if;
-- 100.16.3
  -- Dec 01 Patch   vravikan                 Delete YKM
   --upd49  08-Jan-07	Raju Bug#5619873 From 01-Sep-2006	 Delete WTM
 if p_effective_date < fnd_date.canonical_to_date('2006/09/01') then
    if  (p_Cur_Appt_Auth_1 in ('WTM','WUM') or
        p_Cur_Appt_Auth_2 in ('WTM','WUM')) and
        p_Handicap <>'04' and
        to_number(p_Handicap) not between  6 and 94  and
        p_Handicap is not null then
        hr_utility.set_message(8301, 'GHR_37126_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('APP_AUTH','WTM, WUM');
        hr_utility.raise_error;
    end if;
  ELSE
     if  (p_Cur_Appt_Auth_1 in ('WUM') or
        p_Cur_Appt_Auth_2 in ('WUM')) and
        p_Handicap <>'04' and
        to_number(p_Handicap) not between  6 and 94  and
        p_Handicap is not null then
        hr_utility.set_message(8301, 'GHR_37126_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('APP_AUTH','WUM');
        hr_utility.raise_error;
    end if;
  END IF;

--
-- 100.17.3  If either current appointment authority is Z2W,
--           Then agency must be AF, AR, DD, or NV.

   if p_effective_date >= fnd_date.canonical_to_date('1998/09/01') then
      if ( p_Cur_Appt_Auth_1 = 'Z2W' or p_Cur_Appt_Auth_2 = 'Z2W') and
         substr(p_Agency_Subelement,1,2) not in ('AF','AR','DD','NV')
      then
         hr_utility.set_message(8301, 'GHR_37893_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
     end if;
   end if;

--  100.19.1
  -- deleted 'M2M','M4M' and added 'BNK' as per the changes for apr-98 release
  --   added 'Z2W' on 9-oct-98 for update 8
  --   11/11     12/20/99    vravikan   01-Dec-1999              Add ZBA
  --   Sep'00 Patch          vravikan   From Begining            Add ZBA
  --   Dec 01 Patch 12/10/01 vravikan                     Delete CTM,MYM,MZM,M1M, and NEL
  --   14-SEP-2004	     MADHURI				DELETED LEGAL AUTH - MAM, MBM.
  --	23-Jun-06			Raju		From Beginning		Added ZTU, Z5B, Z5C, Z5D, Z5E, and Z5H
  --   26-sep-2006           amrchakr   01-jul-2003              Changed edit number from 100.19.1 to 100.19.3
  --   26-sep-2006           amrchakr   01-jul-2003              Remove Authorities 'JEM','JGM','JJM','JMM','JQM','JVM','J4M' from 100.19.3
  --------------------------------------------------------------------------------------------
  if p_effective_date < fnd_date.canonical_to_date('2003/07/01') then

  if  (p_Cur_Appt_Auth_1 in
	('ABS','ACM','AYM','A2M','A7M','BBM','BEA','BGL','BKM','BLM','BMA','BMC',
	'BNE','BNK','BNW','BRM','BSE','BSS','BSW','BTM','BWA','BWE','HDM',
	'HGM','HJM','HLM','HNM','HRM','H3M','JEM','JGM','JJM','JMM','JQM',
	'JVM','J4M','KLM','KQM','KTM','KVM','KXM','K1M','K4M','K7M','K9M',
	'LBM','LEM','LHM','LJM','LKM','LKP','LLM','LPM','LSM','LWM','LYM',
	'LZM','L1K','L1M','L3M','MCM','MEM','MGM','MJM','MLL',
	'MLM','MMM','MXM','M6M','M8M','NAM',
	'NCM','NEM','NFM','NJM','NMM','NUM','Q3M','VHM','VJM','V8L',
	'V8N','Z2W','ZBA','ZGM','ZGY','ZJK','ZJM','ZMM','ZQM','ZTM','ZTU','Z5B', 'Z5C', 'Z5D', 'Z5E','Z5H'
	)
	or
	p_Cur_Appt_Auth_2 in
	('ABS','ACM','AYM','A2M','A7M','BBM','BEA','BGL','BKM','BLM','BMA','BMC',
	'BNE','BNK','BNW','BRM','BSE','BSS','BSW','BTM','BWA','BWE','HDM',
	'HGM','HJM','HLM','HNM','HRM','H3M','JEM','JGM','JJM','JMM','JQM',
	'JVM','J4M','KLM','KQM','KTM','KVM','KXM','K1M','K4M','K7M','K9M',
	'LBM','LEM','LHM','LJM','LKM','LKP','LLM','LPM','LSM','LWM','LYM',
	'LZM','L1K','L1M','L3M','MCM','MEM','MGM','MJM','MLL',
	'MLM','MMM','MXM','M6M','M8M','NAM',
	'NCM','NEM','NFM','NJM','NMM','NUM','Q3M','VHM','VJM','V8L',
	'V8N','ZBA','Z2W','ZGM','ZGY','ZJK','ZJM','ZMM','ZQM','ZTM','ZTU','Z5B', 'Z5C', 'Z5D', 'Z5E','Z5H'
	)
       )
    AND
      p_position_occupied_code <> '1'
    AND
      p_position_occupied_code is not null
     then

           hr_utility.set_message(8301, 'GHR_37127_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;

    end if;
else
    if  (p_Cur_Appt_Auth_1 in
	('ABS','ACM','AYM','A2M','A7M','BBM','BEA','BGL','BKM','BLM','BMA','BMC',
	'BNE','BNK','BNW','BRM','BSE','BSS','BSW','BTM','BWA','BWE','HDM',
	'HGM','HJM','HLM','HNM','HRM','H3M',
	'KLM','KQM','KTM','KVM','KXM','K1M','K4M','K7M','K9M',
	'LBM','LEM','LHM','LJM','LKM','LKP','LLM','LPM','LSM','LWM','LYM',
	'LZM','L1K','L1M','L3M','MCM','MEM','MGM','MJM','MLL',
	'MLM','MMM','MXM','M6M','M8M','NAM',
	'NCM','NEM','NFM','NJM','NMM','NUM','Q3M','VHM','VJM','V8L',
	'V8N','Z2W','ZBA','ZGM','ZGY','ZJK','ZJM','ZMM','ZQM','ZTM','ZTU','Z5B', 'Z5C', 'Z5D', 'Z5E','Z5H'
	)
	or
	p_Cur_Appt_Auth_2 in
	('ABS','ACM','AYM','A2M','A7M','BBM','BEA','BGL','BKM','BLM','BMA','BMC',
	'BNE','BNK','BNW','BRM','BSE','BSS','BSW','BTM','BWA','BWE','HDM',
	'HGM','HJM','HLM','HNM','HRM','H3M',
	'KLM','KQM','KTM','KVM','KXM','K1M','K4M','K7M','K9M',
	'LBM','LEM','LHM','LJM','LKM','LKP','LLM','LPM','LSM','LWM','LYM',
	'LZM','L1K','L1M','L3M','MCM','MEM','MGM','MJM','MLL',
	'MLM','MMM','MXM','M6M','M8M','NAM',
	'NCM','NEM','NFM','NJM','NMM','NUM','Q3M','VHM','VJM','V8L',
	'V8N','ZBA','Z2W','ZGM','ZGY','ZJK','ZJM','ZMM','ZQM','ZTM','ZTU','Z5B', 'Z5C', 'Z5D', 'Z5E','Z5H'
	)
       )
    AND
      p_position_occupied_code <> '1'
    AND
      p_position_occupied_code is not null
     then

           hr_utility.set_message(8301, 'GHR_37692_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;

    end if;
end if;

  --     DATE		UPDATE_BY	COMMENTS
  -------------------------------------------------------------------------------------------
  --   14-SEP-2004	MADHURI	        DELETED LEGAL AUTH - MAM, MBM.
  --------------------------------------------------------------------------------------------
-- 100.20.2
   -- deleted 'M2M','M4M' and added 'BNK' as per the changes for apr-98 release
   -- added 'Z2W' on 9-oct-98 for update 8
  --   11/11     12/20/99    vravikan   01-Dec-1999              Add ZBA
  --   Sep'00 Patch          vravikan   From Begining            Add ZBA
  --   Dec 01 Patch 12/10/01 vravikan                     Delete CTM,MYM,MZM,M1M, and NEL
  --   23-Jun-06			Raju		From Beginning		Added Z5B, Z5C, Z5D, Z5E, and Z5H
  --   29-sep-2006           amrchakr   01-jul-2003              end dated the edit from 01-jul-2003

IF p_effective_date < fnd_date.canonical_to_date('2003/07/01') THEN
     if (
       p_Cur_Appt_Auth_1 in
      ('ABS','ACM','AYM','A2M','A7M','BBM','BEA','BGL','BKM','BLM','BMA','BMC',
       'BNE','BNK','BNW','BRM','BSE','BSS','BSW','BTM','BWA','BWE','HDM',
       'HGM','HJM','HLM','HNM', 'HRM','H3M','JEM','JGM','JJM','JMM','JQM',
       'JVM','J4M','KLM','KQM','KTM','KVM','KXM','K1M', 'K4M','K7M','K9M',
       'LBM','LEM','LHM','LJM','LKM','LKP','LLM','LPM','LSM','LWM','LYM','LZM',
       'L1K','L1M','L3M','MCM','MEM','MGM','MJM','MLL',
       'MLM','MMM','MXM','M6M','M8M','NAM','NCM','MEL',
       'NEM','NFM','NJM','NMM','NUM','Q4M','VHM', 'VJM','V8L','V8N','Z2W',
       'ZBA','ZGM','ZGY','ZJK','ZJM','ZMM','ZQM','ZTM','ZTU','Z5B', 'Z5C', 'Z5D', 'Z5E','Z5H')
       or
       p_Cur_Appt_Auth_2 in
      ('ABS','ACM','AYM','A2M','A7M','BBM','BEA','BGL','BKM','BLM','BMA','BMC',
       'BNE','BNK','BNW','BRM','BSE','BSS','BSW','BTM','BWA','BWE','HDM',
       'HGM','HJM','HLM','HNM', 'HRM','H3M','JEM','JGM','JJM','JMM','JQM',
       'JVM','J4M','KLM','KQM','KTM','KVM','KXM','K1M', 'K4M','K7M','K9M',
       'LBM','LEM','LHM','LJM','LKM','LKP','LLM','LPM','LSM','LWM','LYM','LZM',
       'L1K','L1M','L3M','MCM','MEM','MGM','MJM','MLL',
       'MLM','MMM','MXM', 'M6M','M8M','NAM','NCM','MEL',
       'NEM','NFM','NJM','NMM','NUM','Q4M','VHM', 'VJM','V8L','V8N','Z2W',
       'ZBA','ZGM','ZGY','ZJK','ZJM','ZMM','ZQM','ZTM','ZTU','Z5B', 'Z5C', 'Z5D', 'Z5E','Z5H')
      )
     and
      (
       to_number(p_First_NOAC_Lookup_Code) not between 100 and 199
       and
       to_number(p_First_NOAC_Lookup_Code) not between 500 and 599
      )
     and
       p_Position_Occupied_Code <> '1'
     and
       p_Position_Occupied_Code is not null
     then
       hr_utility.set_message(8301, 'GHR_37128_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
END IF;
--

-- 100.22.3
   if ((
       (
        substr(p_Cur_Appt_Auth_1,1,1)= 'M'
        or
        substr(p_Cur_Appt_Auth_1,1,1)= 'N'
        )
      and
       p_Cur_Appt_Auth_1 <>'NUM'
       )
     or
      (
       (
        substr(p_Cur_Appt_Auth_2,1,1)= 'M'
        or
        substr(p_Cur_Appt_Auth_2,1,1)= 'N'
        )
      and
        p_Cur_Appt_Auth_2 <>'NUM'
       ))
     and
       p_Tenure_Goupe_Code <> '0'
     and
       p_Tenure_Goupe_Code <> '3'
     and
       p_Tenure_Goupe_Code is not null
     then
       hr_utility.set_message(8301, 'GHR_37129_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 100.25.3
  if   ((
        substr(p_Cur_Appt_Auth_1,1,1)='K'
        and p_Cur_Appt_Auth_1<>'KLM'
        )
    or
       (
        substr(p_Cur_Appt_Auth_2,1,1)='K'
        and p_Cur_Appt_Auth_2<>'KLM'
        ))
    and
       p_Tenure_Goupe_Code <>'2'
    and
       p_Tenure_Goupe_Code <>'1'
     and
       p_Tenure_Goupe_Code is not null
    then
       hr_utility.set_message(8301, 'GHR_37130_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.28.3
    -- Dec 01        Patch 12/10/01    vravikan            Add YCM
    --                                              Delete YAM, Y4M
	-- Upd 47        23-Jun-06	    Raju	 From 01-Apr-06	Added condition pay plan is other than Yx
    -- Bug 5735389   26-dec-2006    amrchakr Removed the condition 'p_Tenure_Goupe_Code <>'1'' from ELSE part.
     --Bug 8653515   29-JUL-2009    Mani   From 01-Mar-09 Removed pay plan condition

	IF p_effective_date < fnd_date.canonical_to_date('2006/04/01') THEN
		if  ( p_Cur_Appt_Auth_1 in ('YBM','YCM','YGM','Y1M','Y2M','Y3M') or
			p_Cur_Appt_Auth_2 in ('YBM','YCM','YGM','Y1M','Y2M','Y3M')) and
		   p_Tenure_Goupe_Code <>'1'  and
		   p_Tenure_Goupe_Code <>'2'  and
		   p_Tenure_Goupe_Code is not null
		then
		   hr_utility.set_message(8301, 'GHR_37131_ALL_PROCEDURE_FAIL');
		   hr_utility.set_message_token('APP_ATRTY','YBM, YCM, YGM, Y1M, Y2M, or Y3M');
		   hr_utility.raise_error;
		end if;
	ELSIF p_effective_date < fnd_date.canonical_to_date('2009/03/01') THEN
		if ( p_Cur_Appt_Auth_1 in ('YBM','YCM','YGM','Y1M','Y2M','Y3M') or
		   p_Cur_Appt_Auth_2 in ('YBM','YCM','YGM','Y1M','Y2M','Y3M')) and
		   substr(p_To_Pay_Plan,1,1)<>'Y' and
		   p_Tenure_Goupe_Code <>'2'  and
		   p_Tenure_Goupe_Code is not null
		then
		   hr_utility.set_message(8301, 'GHR_37131_ALL_PROCEDURE_FAIL');
		   hr_utility.set_message_token('APP_ATRTY','YBM, YCM, YGM, Y1M, Y2M, or Y3M, And pay plan is other than Yx');
		   hr_utility.raise_error;
		end if;
	ELSE
	     if ( p_Cur_Appt_Auth_1 in ('YBM','YCM','YGM','Y1M','Y2M','Y3M') or
		   p_Cur_Appt_Auth_2 in ('YBM','YCM','YGM','Y1M','Y2M','Y3M')) and
		   p_Tenure_Goupe_Code <>'2'  and
		   p_Tenure_Goupe_Code is not null
		then
		   hr_utility.set_message(8301, 'GHR_37131_ALL_PROCEDURE_FAIL');
		   hr_utility.set_message_token('APP_ATRTY','YBM, YCM, YGM, Y1M, Y2M, or Y3M');
		   hr_utility.raise_error;
		end if;
	END IF;


-- 100.31.3
  if (
      p_Cur_Appt_Auth_1 ='WXM'
      or p_Cur_Appt_Auth_2 ='WXM'
      )
   and
      p_Tenure_Goupe_Code <>'0'
   and
      p_Tenure_Goupe_Code <>'3'
     and
       p_Tenure_Goupe_Code is not null
   then
       hr_utility.set_message(8301, 'GHR_37132_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.35.3
  if  (
       p_Cur_Appt_Auth_1 ='V8V' or p_Cur_Appt_Auth_2 ='V8V'
       )
    and
      (
       substr(p_Agency_Subelement,1,2) <>'VA'
       or p_Position_Occupied_Code <>'2'
      )
    then
       hr_utility.set_message(8301, 'GHR_37133_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.36.3
  if   p_To_Pay_Plan='GS'
    and
       p_To_Grade_Or_Level in ('01','02','03','04','05','06','07','08','09','10')
    and
      (
       p_Cur_Appt_Auth_1 = 'ZKM'
       or
       p_Cur_Appt_Auth_1 = 'ZNM'
       or
       p_Cur_Appt_Auth_2 = 'ZKM'
       or
       p_Cur_Appt_Auth_2 = 'ZNM'
      )
    then
       hr_utility.set_message(8301, 'GHR_37134_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.37.3
  if  (
       p_Cur_Appt_Auth_1 in ('NEM','LBM','LZM')
       or p_Cur_Appt_Auth_2 in ('NEM','LBM','LZM')
       )
    and
      (
       p_Vet_Pref_Code = '1'
       or p_Vet_Pref_Code = '5'
       )
    then
       hr_utility.set_message(8301, 'GHR_37135_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.38.3
   --
   --            12/8/00   vravikan    From the Start    Add UAM
   -- If either current appointment authority is Z2U, then agency must be
   -- AF, AR, DD or NV.
   --
   -- BUG # 8653515  Mani added LAC Z6L from 01-Mar-2009
   if p_effective_date >= fnd_date.canonical_to_date('1998/03/01') then
    if p_effective_date < fnd_date.canonical_to_date('2009/03/01') then
      if (p_Cur_Appt_Auth_1  in ( 'Z2U','UAM') or
          p_Cur_Appt_Auth_2  in ('Z2U','UAM') )  and
          substr(p_Agency_Subelement,1,2) not in ('AF','AR','DD','NV') then
          hr_utility.set_message(8301, 'GHR_37876_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('APP_ATRTY','Z2U or UAM');
          hr_utility.raise_error;
      end if;
    else
      if (p_Cur_Appt_Auth_1  in ( 'Z2U','UAM','Z6L') or
          p_Cur_Appt_Auth_2  in ('Z2U','UAM','Z6L') ) and
          substr(p_Agency_Subelement,1,2) not in ('AF','AR','DD','NV') then
          hr_utility.set_message(8301, 'GHR_37876_ALL_PROCEDURE_FAIL');
	  hr_utility.set_message_token('APP_ATRTY','Z2U, UAM or Z6L');
          hr_utility.raise_error;
      end if;
    end if;
   end if;

/* Commented -- Dec 2001 Patch
-- 100.52.3
  if  (
       substr(p_Cur_Appt_Auth_1,1,1)='T'
       or
       substr(p_Cur_Appt_Auth_2,1,1)='T'
       )
    and
       substr(p_Duty_Station_Lookup_Code,1,2) <> 'PM'
    and
       p_Duty_Station_Lookup_Code is not null
    then
       hr_utility.set_message(8301, 'GHR_37136_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
*/

--  100.55.1
  if ( p_Cur_Appt_Auth_1 in
         ('NRM','NSM','NTM','NVM','NWM','NXM','V2M','VCJ','VBJ','VAG','V6M','V4L','V4M','V4P')
       or
       p_Cur_Appt_Auth_2 in
         ('NRM','NSM','NTM','NVM','NWM','NXM','V2M','VCJ','VBJ','VAG','V6M','V4L','V4M','V4P')
     )
    and
      p_to_pay_plan <> 'ES'
    and
      p_to_pay_plan is not null
    then
       hr_utility.set_message(8301, 'GHR_37137_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.56.2
  if  (
       p_Cur_Appt_Auth_1 in ('NRM','NSM','NTM','NVM','NWM','NXM',
                                       'VAG','VBJ','VCJ','V4L','V4M','V6M','V4P')
       or
       p_Cur_Appt_Auth_2 in ('NRM','NSM','NTM','NVM','NWM','NXM','VAG',
                                       'VBJ','VCJ','V4L','V4M','V6M','V4P')
       )
    and
       p_To_Pay_Plan <>'ES'
    and
       p_To_Pay_Plan is not null
    then
       hr_utility.set_message(8301, 'GHR_37138_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.58.3
--  Raju    	  20-Apr-2007	 UPD 53(Bug 5996938) Delete cur_appt_auth2 From Starting
 --  l_Service_Computation_Date := TO_DATE(p_Service_Computation_Date, 'DD-MON-YYYY');
l_Service_Computation_Date := p_Service_Computation_Date;
  if  (p_Cur_Appt_Auth_1='ZZZ'
       --or p_Cur_Appt_Auth_2='ZZZ'
       )
    and (( l_Service_Computation_Date >= TO_DATE('1982/01/01','YYYY/MM/DD')
            and	l_Service_Computation_Date is not null
	     )or(p_Position_Occupied_Code <> '1' and
             p_Position_Occupied_Code is not null )
        )
    then
       hr_utility.set_message(8301, 'GHR_37139_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

/*
-- 100.61.2
  if  (
       (
        substr(p_First_NOAC_Lookup_Code,1,1)='1' and p_First_NOAC_Lookup_Code <>'132'
        )
       or
       substr(p_First_NOAC_Lookup_Code,1,1)='5'
       )
    and
      (
       p_Cur_Appt_Auth_1 <>p_First_Action_NOA_LA_Code1
       or
       p_Cur_Appt_Auth_2 <>p_First_Action_NOA_LA_Code2
      )
    then
       hr_utility.set_message(8301, 'GHR_37140_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
*/

-- 100.64.3
  if  (
       p_Cur_Appt_Auth_1='WEM' or p_Cur_Appt_Auth_2='WEM'
       )
    and
       p_To_OCC_Code <> '0904'
    and
       p_To_OCC_Code is not null
    then
       hr_utility.set_message(8301, 'GHR_37141_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.70.3
 if  (
      p_Cur_Appt_Auth_1='WDM' or p_Cur_Appt_Auth_2='WDM'
      )
   and
   not(
       (
        p_To_OCC_Code = '0905' or p_To_OCC_Code = '1222'
        )
       or
       p_To_OCC_Code is null
       )
   then
       hr_utility.set_message(8301, 'GHR_37142_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.73.3
  if  (
       p_Cur_Appt_Auth_1 in ('ACM','AYM','KQM')
       or
       p_Cur_Appt_Auth_2 in ('ACM','AYM','KQM')
       )
   and
       p_Agency_Subelement<>'RR00'
   and
       (p_To_OCC_Code = '0904' or  p_To_OCC_Code = '0905')

   then
       hr_utility.set_message(8301, 'GHR_37143_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.76.3
  if  (
       p_Cur_Appt_Auth_1='VEM' or p_Cur_Appt_Auth_2='VEM' or
       p_Cur_Appt_Auth_1='H2L' or p_Cur_Appt_Auth_2='H2L'
       )
    and
       p_To_Pay_Plan not in ('ED','EF','EH')
    and
       p_To_Pay_Plan is not null
    then
       hr_utility.set_message(8301, 'GHR_37144_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.98.3
  if   p_Cur_Appt_Auth_1='ZZZ'
    and
       p_Cur_Appt_Auth_2 <>'ZZZ'
    and
       p_Cur_Appt_Auth_2 is not null
    then
       hr_utility.set_message(8301, 'GHR_37145_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 100.99.3
  if   p_Cur_Appt_Auth_2='ZZZ'
    and
       p_Cur_Appt_Auth_1 <> 'ZZZ'
    and
       p_Cur_Appt_Auth_1 is not null
    then
       hr_utility.set_message(8301, 'GHR_37146_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;


end chk_Cur_Appt_Auth;

/* Name:
--  C_Date_of_Birth
*/

procedure chk_Date_of_Birth
  ( p_First_NOAC_Lookup_Code   in varchar2
   ,p_Effective_Date           in date
   ,p_Employee_Date_of_Birth   in date
   ,p_Duty_Station_Lookup_Code in varchar2
   ,p_as_of_date               in date
  ) is
begin

-- 110.02.2
  if   p_First_NOAC_Lookup_Code ='300'
    and
      (to_number(substr(to_char(p_Effective_Date, 'MMDDYYYY'),5,4)) -
      to_number(substr(to_char(p_employee_date_of_birth, 'MMDDYYYY'),5,4)) ) < 50
   then
      hr_utility.set_message(8301, 'GHR_37147_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
  end if;

-- 110.05.2
--        Date of birth must be at least 13 years less than the
--        effective date of personnel action, or be asterisks.

  if (months_between(p_as_of_date, p_employee_date_of_birth) < 156 ) then
       hr_utility.set_message(8301, 'GHR_38412_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 110.07.2
  -- end dated this edit on 27-oct-98 for bug 745246
  if p_effective_date <= fnd_date.canonical_to_date('1998/07/31') then
     if  (
	   (
          substr(p_Duty_Station_Lookup_Code,1,1) in ('0','1','2','3','4','5','6','7','8','9')
          and
          substr(p_Duty_Station_Lookup_Code,2,1) in ('0','1','2','3','4','5','6','7','8','9')
          )
        or
          substr(p_Duty_Station_Lookup_Code,2,1) = 'Q'
          )
        and
         (to_number(substr(to_char(p_Effective_Date, 'MMDDYYYY'),5,4)) -
         to_number(substr(to_char(p_employee_date_of_birth, 'MMDDYYYY'),5,4)) ) < 15
        then
          hr_utility.set_message(8301, 'GHR_37149_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
     end if;
  end if;

end chk_Date_of_Birth;

/* Name:
--  Duty Station
*/

procedure chk_duty_station
  (p_to_play_plan       		in varchar2
  ,p_agency_sub_element 		in varchar2
  ,p_duty_station_lookup  		in varchar2
  ,p_First_Action_NOA_LA_Code1 	in varchar2
  ,p_First_Action_NOA_LA_Code2 	in varchar2
  ,p_effective_date             in date
  ) is
begin

-- 120.00.1   From Part B,C, Notes
  if  (
	substr(p_duty_station_lookup,1,1) not in ('0','1','2','3','4','5','6','7','8','9')
	and
	substr(p_duty_station_lookup,2,1) not in ('0','1','2','3','4','5','6','7','8','9')
	) and
	substr(p_duty_station_lookup,-3,3) <> '000' then
      hr_utility.set_message(8301, 'GHR_37150_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
  end if;

/* Commented -- Dec 2001 Patch
--  120.02.3

  if   substr(p_to_play_plan,1,2) in ('CZ','SZ','WZ')
    and
       p_agency_sub_element <> 'PC00'
    and
       substr( p_duty_station_lookup,1,2) <> 'PM'
    and
      p_duty_station_lookup is not null
   then
       hr_utility.set_message(8301, 'GHR_37151_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
*/

--  120.03.3
--   10/4     08/13/99    vravikan   01-Apr-99                 New Edit
--   20/2     20/02/03	  Madhuri    			Commented Edit for Delete - March 2003 Legislative Patch

/*if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
  if   substr(p_to_play_plan,1,2) in ('TW')
    and
       substr( p_duty_station_lookup,1,2) not in ( '11','24','51' )
    and
      p_duty_station_lookup is not null
   then
       hr_utility.set_message(8301, 'GHR_37166_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
end if; */

--  120.04.3
   -- Update Date        By        Effective Date            Comment
   --   9   04/28/99    vravikan                             Change Edit-May 99 Patch
   --   48  26/09/06    amrchakr   01-jul-2006               Remove condition of agency DJ02
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
  if p_effective_date < to_date('2006/07/01','yyyy/mm/dd')
  then
      if   substr(p_to_play_plan,1,2) in ('WQ','WR','WU')
          and
          p_agency_sub_element <> 'DJ02'
          and
          substr(p_duty_station_lookup,1,2) <> 'RQ'
          and
          p_duty_station_lookup is not null
      then
          hr_utility.set_message(8301, 'GHR_37152_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
     end if;
  else
      if  substr(p_to_play_plan,1,2) in ('WQ','WR','WU')
          and
          substr(p_duty_station_lookup,1,2) <> 'RQ'
          and
          p_duty_station_lookup is not null
      then
          hr_utility.set_message(8301, 'GHR_37600_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
     end if;
  end if;
end if;

--  120.07.2
-- upd50  06-Feb-07	  Raju       From 01-Oct-2006	    Bug#5745356 delete NOA 849
if p_effective_date < to_date('2006/10/01','yyyy/mm/dd') then
      if  (substr(p_First_Action_NOA_LA_Code1,1,1)='T' or
           substr(p_First_Action_NOA_LA_Code2,1,1)='T')  and
           substr(p_duty_station_lookup,1,2) <>'PM'    and
           p_duty_station_lookup is not null
      then
           hr_utility.set_message(8301, 'GHR_37153_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
    end if;
end if;

/*
This has to be deleted according to the update 6 manual for april release
--  120.10.3
  if   substr(p_duty_station_lookup,1,2) = 'US'
    and
       p_agency_sub_element <> 'DJ02'
   then
       hr_utility.set_message(8301, 'GHR_37154_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
*/

end chk_duty_station;


/* Name:
--  C_Education_Level
*/

procedure chk_Education_Level
  ( p_tenure_group_code        in varchar2
   ,p_education_level          in varchar2
   ,p_pay_plan                 in varchar2
  ) is
begin

-- 130.02.3
  if  (
	 p_tenure_group_code = '1' or p_tenure_group_code = '2'
	 )
    and
       p_education_level is null
   then
       hr_utility.set_message(8301, 'GHR_37155_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 130.04.3
  if   p_pay_plan = 'ES'
    and
       p_education_level is null
   then
       hr_utility.set_message(8301, 'GHR_37156_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;

end chk_Education_Level;

/* Name:
--  C_Effective_Date
*/

procedure chk_effective_date
  ( p_First_NOAC_Lookup_Code   in varchar2
   ,p_Effective_Date           in date
   ,p_Production_Date          in date  -- Non SF52 item
  ) is
begin
  null;
/*
commented by skutteti on 7-apr-98. As per the new changes this edit has to be deleted.
-- 140.02.2
  if  (
	 p_First_NOAC_Lookup_Code = '117' or
       p_First_NOAC_Lookup_Code = '517'
	 )
    and
    not (
           to_char(p_Effective_Date,'MMDD')>=  '0513'
         and
           to_char(p_Effective_Date,'MMDD')<= '0930'
	   )
    then
       hr_utility.set_message(8301, 'GHR_37157_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
*/


/* p_Production_Date can not be found.
-- 140.08.2
  if   Months_Between(p_Effective_Date,p_Production_Date)>6
    or
   --     Year_Between (p_Effective_Date,p_Production_Date)<-2


      to_number(substr(to_char(p_Effective_Date, 'MMDDYYYY'),5,4)) -
      to_number(substr(to_char(p_Production_Date, 'MMDDYYYY'),5,4)) ) < -2
   then
       hr_utility.set_message(8301, 'GHR_37158_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;
*/

end chk_effective_date;

/* Name:
     Handicap
*/

procedure chk_Handicap
  (p_First_Action_NOA_Code1 in varchar2
  ,p_First_Action_NOA_Code2 in varchar2
  ,p_First_NOAC_Lookup_Code in varchar2
  ,p_Effective_Date         in date --bug# 5619873
  ,p_Handicap               in varchar2   -- non SF52 item
  ) is
begin

-- 220.02.2
  -- Dec 01 Patch   vravikan                 Delete YKM
  --upd49  08-Jan-07	Raju Bug#5619873 From 01-Sep-2006	 Delete WTM
    if p_effective_date < fnd_date.canonical_to_date('2006/09/01') then
        if  ( p_First_Action_NOA_Code1 in ('WTM','WUM') or
            p_First_Action_NOA_Code2 in ('WTM','WUM')) and
            to_number(p_Handicap) not between 6 and 94 and
            p_Handicap <>'04' and
            p_Handicap is not null then
             hr_utility.set_message(8301, 'GHR_37159_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('APP_AUTH','WTM, WUM');
             hr_utility.raise_error;
        end if;
    else
        if  ( p_First_Action_NOA_Code1 in ('WUM') or
            p_First_Action_NOA_Code2 in ('WUM')) and
            to_number(p_Handicap) not between 6 and 94 and
            p_Handicap <>'04' and
            p_Handicap is not null then
            hr_utility.set_message(8301, 'GHR_37159_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('APP_AUTH','WUM');
           hr_utility.raise_error;
        end if;
    end if;


-- 220.05.2
   if   substr(p_First_NOAC_Lookup_Code,1,1)='1'
     and
        p_Handicap='04'
   then
	 hr_utility.set_message(8301, 'GHR_37160_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
end if;

end chk_Handicap;

/* Name
--    Individual/Group Award
*/

procedure chk_indiv_Award
  (p_First_NOAC_Lookup_Code in varchar2
  ,p_Indiv_Award            in varchar2
  ,p_effective_date         in date
  ) is
begin

--Commented as per EOY 2003 cpdf changes by Ashley
-- 240.02.2
-- Award Req  8/15/00   vravikan    30-sep-2000    End date
/*   if p_effective_date <= to_date('2000/09/30','yyyy/mm/dd') then
    if  p_First_NOAC_Lookup_Code in ('874','875','876','877')
     and
        p_Indiv_Award is null
     then
	 hr_utility.set_message(8301, 'GHR_37161_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
    end if;
  end if;*/
  null;
end chk_indiv_Award;

end GHR_CPDF_CHECK2;

/
