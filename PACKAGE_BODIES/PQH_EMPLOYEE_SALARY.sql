--------------------------------------------------------
--  DDL for Package Body PQH_EMPLOYEE_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_EMPLOYEE_SALARY" as
/* $Header: pqempsal.pkb 120.2 2005/06/15 04:38 ggnanagu noship $ */
--
/**** Please find below the meaning for the status returned
p_status =  1 :  Success
p_status = -1 :  Invalid Assignment
p_status =  2 :  No Payroll for assignment.
p_status =  3 :  No Salary basis and No Grade Ladder Element.
--
p_pay_basis = 'Y' : Salary determined from salary basis element
p_pay_basis = 'N' : Salary determined from Grade Ladder element
****/

Procedure get_employee_salary
(P_Assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  In Date,
 p_salary         OUT nocopy number,
 p_frequency      OUT nocopy varchar2,
 p_annual_salary  OUT nocopy number,
 p_pay_basis      OUT nocopy varchar2,
 p_reason_cd      OUT nocopy varchar2,
 p_currency       OUT nocopy varchar2,
 p_status         OUT nocopy number,
 p_pay_basis_frequency OUT nocopy varchar2
) IS
--
L_Cur_Sal         Per_pay_Proposals.PROPOSED_SALARY_N%TYPE;
l_input_value_id  pay_input_values_f.Input_Value_id%TYPE;
l_dummy_iv_id     pay_input_values_f.Input_Value_id%TYPE;
l_business_group_id  Per_All_Assignments_f.business_group_id%type;
--
l_pay_basis_id    Per_All_Assignments_f.pay_basis_id%type;
l_pgm_id          Per_All_Assignments_f.GRADE_LADDER_PGM_ID%type;
l_payroll_id      Per_All_Assignments_f.payroll_id%type;
l_basis_Annl_fctr Per_Pay_Bases.Pay_Annualization_Factor%TYPE;
l_precision       Fnd_Currencies.Precision%type;
L_Salary          pay_element_entry_values_f.screen_entry_value%TYPE;
--
--
l_proc 	varchar2(72);
--
  Cursor csr_asg_details is
  Select paf.pay_basis_id, paf.GRADE_LADDER_PGM_ID, paf.payroll_id,paf.business_group_id
    From Per_All_Assignments_f paf
   Where paf.Assignment_Id = p_Assignment_Id
     and p_Effective_Date
 Between Paf.Effective_Start_Date and Paf.Effective_End_Date;
 --
Cursor Sal is
  Select pev.screen_entry_value,pet.INPUT_CURRENCY_CODE
    From pay_element_entries_f pee,
         pay_input_values_f piv,
         pay_element_entry_values_f pev,
         pay_element_types_f pet
   Where pee.Assignment_id = P_Assignment_id
     and P_Effective_Date
 between pee.Effective_Start_Date and pee.Effective_End_Date
     and Piv.Input_Value_id   = l_Input_Value_id
     and P_Effective_Date
 Between Piv.Effective_Start_Date and Piv.Effective_End_Date
     and pev.ELEMENT_ENTRY_ID = Pee.ELEMENT_ENTRY_ID
     and Piv.INPUT_VALUE_ID = Pev.INPUT_VALUE_ID
     and P_Effective_Date
 Between Pev.Effective_Start_Date and Pev.Effective_End_Date
     and pet.element_type_id = piv.element_type_id
     and p_effective_date
 Between pet.effective_start_date and pet.effective_end_date;
 --
  Cursor Pay_Bases_Element is
  Select input_value_id, Pay_Annualization_Factor,pay_basis
    From Per_Pay_Bases paf
   Where paf.pay_basis_id  = l_pay_basis_id;
  --
  Cursor GrdLdr_Element is
  Select DFLT_INPUT_VALUE_ID
    from Ben_Pgm_f             pgm
   Where pgm.pgm_id = l_pgm_id
     and p_Effective_Date
 Between pgm.Effective_Start_date and pgm.Effective_End_Date;
 --
 Cursor csr_ann_sal (p_sal in number, p_payroll_id in number) is
  Select pr.period_type, (p_sal * pt.number_per_fiscal_year) annual_salary
    From per_time_period_types pt, pay_all_payrolls_f pr
  Where pr.payroll_id = p_payroll_id
    and p_Effective_Date
Between pr.Effective_Start_date and pr.Effective_End_Date
    and pr.period_type = pt.period_type;
 --
 Cursor csr_proposal_rsn is
 select proposal_reason
   from per_pay_proposals
  where assignment_id = p_assignment_id
   and change_date = (Select max(change_date)
                        From per_pay_proposals
                       where assignment_id = p_assignment_id
                         and change_date <= p_Effective_Date);
--
 Cursor csr_cur is
 Select Nvl(Cur.Precision,2)
  From  Fnd_Currencies Cur
  Where Cur.Currency_Code = P_currency;

Begin
  --
  l_proc := 'get_employee_salary';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Step 1. Fetch Assignment Details
  --
  Open  csr_asg_details;
  Fetch csr_asg_details into l_pay_basis_id, l_pgm_id, l_payroll_id,l_business_group_id;
  If csr_asg_details%found then
  --
  -- Step 2: If the Assignment is attached to a Salary basis, then find the Salary Basis Element.
  --
  p_pay_basis := 'N';
  p_pay_basis_frequency := null;
  If l_pay_basis_id IS NOT NULL then
     --
     --
     hr_utility.set_location('Assignment has Salary Basis', 110);
     --
     Open  Pay_Bases_Element;
     Fetch Pay_Bases_Element into l_input_Value_id, l_basis_Annl_fctr, p_pay_basis_frequency;
     Close Pay_Bases_Element;
     --
     -- Get pay proposal reason
     --
     Open csr_proposal_rsn;
     Fetch csr_proposal_rsn into p_reason_cd;
     Close csr_proposal_rsn;

     --
     p_pay_basis := 'Y';
     --
     /*

     --
     -- Get currency
     --
     If l_pgm_id is NOT NULL then
        --
        -- Get grade ladder currency
        --
        --
        hr_utility.set_location('Get currency from grade ladder', 120);
        --
        Open  GrdLdr_Element;
        Fetch GrdLdr_Element into l_dummy_iv_id;
        Close GrdLdr_Element;
        --
     Else
       --
       -- Assignment is on salary basis but not on a GL.
       -- Get currency from BG ?
       --
        --
        hr_utility.set_location('Get currency from business group', 130);
        --
       p_currency := hr_general.DEFAULT_CURRENCY_CODE(p_business_group_id => l_business_group_id);
       --
     End if;
     --
     -- Set p_pay_basis OUT paremeter to indicate that the salary is from pay basis element.
     --
     p_pay_basis := 'Y';*/
     --
  Else
  --
  -- Step 3: If Assignment Has no salary basis, then get the grade ladder element,
  --         provided the assignment is on a grade ladder.
  --
     If l_pgm_id is NOT NULL then
        --
        --
        hr_utility.set_location('Fetch Grade Ladder Element', 140);
        --
        Open  GrdLdr_Element;
        Fetch GrdLdr_Element into l_input_Value_id;
        Close GrdLdr_Element;
        --
     Else
       --
       -- p_status = 3 :  No Salary basis and No Grade Ladder Element.
       --
       --
       hr_utility.set_location('No Salary basis and No Grade Ladder', 150);
       --
       p_status := 3;
       p_salary := 0;
       p_annual_salary := 0;
       --
     End if;
     --
 End if;
 --
 -- Step 4: Find the rate for the salary element.
 --
  Open csr_cur;
 Fetch Csr_Cur into l_precision;
 Close Csr_Cur;

 If l_precision is NULL then
    l_precision := 2;
 End If;

 if l_Input_Value_id is Not NULL Then
    Open Sal;
    Fetch Sal into l_salary,p_currency;
    Close Sal;
    p_salary:=fnd_number.canonical_to_number(l_salary);
        --
    -- Step 5: Find the payroll frequency and the annual salary.
    --
    If l_payroll_id IS NOT NULL then
       --
       --
       hr_utility.set_location('Computing annual salary for assignment.', 160);

       --
       Open csr_ann_sal(nvl(p_salary,0),l_payroll_id);
       Fetch csr_ann_sal into p_frequency, p_annual_salary;
       Close csr_ann_sal;

       If p_pay_basis = 'Y' then
             if (l_basis_Annl_fctr is null or l_basis_Annl_fctr = 0 ) then
                l_basis_Annl_fctr := 1;
             end if ;
          p_annual_salary := nvl(p_salary,0) * l_basis_Annl_fctr;
       End If;

       --sqlplus
       -- p_status = 1 :  Success
       --

       p_status := 1;
       --
    Else
       --
       -- p_status = 2 :  No Payroll for assignment.
       --
       --
       hr_utility.set_location('Null Payroll for assignment.', 170);
       --
       p_status := 2;
       p_annual_salary := p_salary;

       --
    End if;
    --
 Else
    --
    -- p_status = 3 :  No Salary basis and No Grade Ladder Element.
    --
    --
    hr_utility.set_location('Null Input Value Id', 180);
    --
    p_status := 3;
    p_salary := 0;
    p_annual_salary := 0;
 End If;
 --
 Else
 --
 -- p_status = -1 :  Invalid Assignment
 --
    p_status := -1;
 --
 --
 hr_utility.set_location('Invalid Assignment id', 190);
 --
 End if;
 p_annual_salary := trunc(p_annual_salary,l_precision);
 Close csr_asg_details;
 --
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
Exception When others then
  --
  hr_utility.set_location('Exception:'||l_proc, 200);
  raise;
  --
End get_employee_salary;
--
---------------------------------------------------------------------------------------------------------------
--
-- Follwing procedure returns true if there is a grade ladder setup in the
-- business group.
--
Procedure check_grade_ladder_exists(p_business_group_id in number,
                                    p_effective_date    in date ,
                                    p_grd_ldr_exists_flag out nocopy boolean)
is
--
Cursor csr_gsp is
Select 'x'
 from ben_pgm_f
 Where business_group_id = p_business_group_id
   and pgm_typ_cd  = 'GSP'
   and p_effective_date between effective_start_date and effective_end_date;
--
l_dummy varchar2(10);
l_proc  varchar2(72);
--
Begin
 --
 l_proc := 'check_grade_ladder_exists';
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 Open csr_gsp;
 Fetch csr_gsp into l_dummy;
 If csr_gsp%notfound then
    p_grd_ldr_exists_flag := false;
    hr_utility.set_location('No grade ladder', 7);
 End if;
 close csr_gsp;
 --
 p_grd_ldr_exists_flag := true;
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 --
Exception When others then
  --
  hr_utility.set_location('Exception:'||l_proc, 200);
  raise;
  --
End check_grade_ladder_exists;
--
--
-- Follwing procedure returns 'Y' if there is a grade ladder setup in the
-- business group.
--
Procedure check_grade_ladder_exists(p_business_group_id in number,
                                    p_effective_date    in date,
                                    p_grd_ldr_exists_flag out nocopy varchar2)
is
--
--
l_status  boolean;
l_proc  varchar2(72);
--
Begin
 --
 l_proc  := 'check_grade_ladder_exists';
 l_status := false;
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 check_grade_ladder_exists
                          (p_business_group_id => p_business_group_id,
                           p_effective_date    => p_effective_date,
                           p_grd_ldr_exists_flag => l_status);
 If l_status then
    p_grd_ldr_exists_flag:= 'Y';
    hr_utility.set_location('Found Grade ladder', 7);
 End if;
 --
 p_grd_ldr_exists_flag:= 'N';
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 --
Exception When others then
  --
  hr_utility.set_location('Exception:'||l_proc, 200);
  raise;
  --
End check_grade_ladder_exists;
--
-------------------------------------------------------------------------------------------------------------------
Function pgm_to_annual (p_ref_perd_cd  in varchar2,
                         p_pgm_currency in varchar2,
                         p_amount       in number)
RETURN NUMBER is
--
Cursor csr_cur is
 Select Nvl(Cur.Precision,2)
  From  Fnd_Currencies Cur
  Where Cur.Currency_Code = p_pgm_currency;
--
l_ret_amount number;
l_precision  Fnd_Currencies.Precision%type;
l_pay_annualization_factor Per_Pay_Bases.Pay_Annualization_Factor%TYPE;
l_proc  varchar2(72);
--
Begin
--
 l_precision  := 2;
 l_proc  := 'pgm_to_annual';
 hr_utility.set_location('Entering:'||l_proc, 10);
--
 Open csr_cur;
 Fetch csr_cur into l_precision;
 Close csr_cur;
--
IF p_ref_perd_cd = 'PWK' THEN
   l_ret_amount := (p_amount*52);
ELSIF p_ref_perd_cd = 'BWK' THEN
   l_ret_amount := (p_amount*26);
ELSIF p_ref_perd_cd = 'SMO' THEN
   l_ret_amount := (p_amount*24);
ELSIF p_ref_perd_cd = 'PQU' THEN
   l_ret_amount := (p_amount*4);
ELSIF p_ref_perd_cd = 'PYR' THEN
   l_ret_amount := (p_amount*1);
ELSIF p_ref_perd_cd = 'SAN' THEN
   l_ret_amount := (p_amount*2);
ELSIF p_ref_perd_cd = 'MO' THEN
   l_ret_amount := (p_amount*12);
ELSIF p_ref_perd_cd = 'NOVAL' THEN
   l_ret_amount := (p_amount*1);
ELSIF p_ref_perd_cd = 'PHR' then
   l_pay_annualization_factor := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
   If l_pay_annualization_factor is null then
      l_pay_annualization_factor := 2080;
   End if;
 --
   l_ret_amount := (p_amount * l_pay_annualization_factor);
 --
ELSE
   l_ret_amount := p_amount;
END IF;
---
RETURN trunc(l_ret_amount,l_precision);
--
 hr_utility.set_location('Leaving:'||l_proc, 10);
--
End pgm_to_annual;
--
-----------------------------------------------------------------------------------------------------------------
--
-- The following procedure returns the salary change caused by a grade or step change on the assignment
--
-- p_status = 1 : Success. Proposed salary value will be returned only for this status.
-- p_status = 2 : No life event
-- p_status = 3 : No default enrt
-- p_status = 4 : GL not using salary update
-- p_status = 5 : Assignment not on GL
--
Procedure get_emp_proposed_salary
(P_Assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  In Date,
 p_proposed_salary OUT nocopy number,
 p_sal_chg_dt     OUT nocopy date,
 p_frequency      OUT nocopy varchar2,
 p_annual_salary  OUT nocopy number,
 p_pay_basis      OUT nocopy varchar2,
 p_reason_cd      OUT nocopy varchar2,
 p_currency       OUT nocopy varchar2,
 p_status         OUT nocopy number
) IS
--
L_Cur_Sal         Ben_Enrt_Rt.val%type;
l_update_sal_cd   ben_pgm_f.update_salary_cd%type;
--
l_pay_basis_id    Per_All_Assignments_f.pay_basis_id%type;
l_pgm_id          Per_All_Assignments_f.GRADE_LADDER_PGM_ID%type;
l_person_id       Per_All_Assignments_f.person_id%type;
l_payroll_id     Per_All_Assignments_f.payroll_id%type;
--
l_pgm_frequency Ben_Pgm_f.ACTY_REF_PERD_CD%type;
l_per_in_ler_id     Ben_Per_in_Ler.per_in_ler_id%type;
--
l_continue boolean;
l_proc varchar2(72);
--
  Cursor csr_asg_details is
  Select paf.pay_basis_id, paf.GRADE_LADDER_PGM_ID, paf.person_id
    From Per_All_Assignments_f paf
   Where paf.Assignment_Id = p_Assignment_Id
     and p_Effective_Date
 Between Paf.Effective_Start_Date and Paf.Effective_End_Date;
 --
 Cursor csr_GrdLdr is
  Select ACTY_REF_PERD_CD,pgm_uom,Update_Salary_Cd
    from Ben_Pgm_f pgm
   Where pgm.pgm_id = l_pgm_id
     and p_Effective_Date
 Between pgm.Effective_Start_date and pgm.Effective_End_Date;
 --
 Cursor csr_le is
 Select max(pil.Per_in_Ler_Id)
   From Ben_Per_in_ler PIL,
        Ben_Ler_F LER
  Where Pil.Ler_Id = LER.Ler_Id
    And Pil.LF_EVT_OCRD_DT = P_Effective_Date
    And ler.typ_Cd = 'GSP'
    And Pil.person_Id = l_person_id
    And Pil.Per_In_Ler_Stat_Cd = 'PROCD';
 --
 Cursor csr_sal is
 Select Rate.Val Proposed_Sal,
        Rate.Rt_Strt_Dt Sal_Chg_Dt
   From Ben_Elig_Per_Elctbl_Chc Elct,
        Ben_Enrt_Rt Rate
  Where Elct.DFLT_FLAG = 'Y'
    and Elct.Elctbl_Flag = 'Y'
    and Elct.Per_in_ler_id = l_per_in_ler_id
    and Elct.Enrt_Cvg_Strt_Dt is Not NULL
    And Rate.ELIG_PER_ELCTBL_CHC_ID(+) = Elct.ELIG_PER_ELCTBL_CHC_ID;
 --
 Cursor csr_payroll_freq (p_payroll_id in number) is
  Select pr.period_type
    From pay_all_payrolls_f pr
  Where pr.payroll_id = p_payroll_id
    and p_Effective_Date
Between pr.Effective_Start_date and pr.Effective_End_Date;
 --
 Cursor csr_proposal_rsn (p_change_dt in date) is
 select proposal_reason
   from per_pay_proposals
  where assignment_id = p_assignment_id
   and change_date = p_change_dt;
--
 CURSOR C_Pay_Basis IS
 select name, pay_basis
   From Per_Pay_Bases ppb
  where Ppb.Pay_Basis_Id = l_pay_basis_id;

Begin
  --
  l_continue := true;
  l_proc := 'get_emp_proposed_salary';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_proposed_salary := null;
  p_sal_chg_dt      := null;
  p_frequency       := null;
  p_annual_salary   := null;
  p_pay_basis       := null;
  p_reason_cd       := null;
  p_currency        := null;
  --
  -- Step 1. Fetch Assignment Details
  --
  Open  csr_asg_details;
  Fetch csr_asg_details into l_pay_basis_id, l_pgm_id, l_person_id;
  If csr_asg_details%found then
  --
  If l_pgm_id is NOT NULL then
        --
        -- Get grade ladder currency
        --
        hr_utility.set_location('Get grade ladder details', 20);
        --
        Open  csr_GrdLdr;
        Fetch csr_GrdLdr into l_pgm_frequency, p_currency, l_update_sal_cd;
        Close csr_GrdLdr;
        --
        -- If the grade ladder does not allow salary update, then return
        --
        If l_update_sal_cd in ('SALARY_BASIS','SALARY_ELEMENT') then
          --
          Open csr_le;
          Fetch csr_le into l_per_in_ler_id;
          If csr_le%notfound then
             l_continue := false;
             p_status := 2;
             hr_utility.set_location('No life event on the assignment change date. Cannot compute proposed salary.', 30);
          End if;
          Close csr_le;
          --
          --
          If l_continue then
            Open csr_sal;
            Fetch csr_sal into L_Cur_Sal,p_sal_chg_dt;
            If csr_sal%notfound then
              l_continue := false;
              p_status := 3;
              hr_utility.set_location('No default enrolment found. Cannot compute proposed salary.', 40);
            End if;
            Close csr_sal;
          End  if;
          --
          If l_continue then
             If l_update_sal_cd = 'SALARY_BASIS' then
              --
              If l_pay_basis_id IS NOT NULL then
                --
                hr_utility.set_location('Assignment has Salary Basis', 50);
                --
                -- Get pay basis frequency
                --
                Open C_Pay_Basis;
                Fetch C_Pay_Basis into p_pay_basis,p_frequency;
                Close C_Pay_Basis;
                --
                -- Get pay proposal reason
                --
                Open csr_proposal_rsn(p_sal_chg_dt);
                Fetch csr_proposal_rsn into p_reason_cd;
                Close csr_proposal_rsn;
                --
                --
              Else
                --
                -- This scenario should never occur.
                --
                l_continue := false;
                hr_utility.set_location('Assignment has no Salary Basis', 60);
                --
              End if;
              --
             Else /** Using salary element **/
               --
               hr_utility.set_location('Using salary element', 70);
               If l_payroll_id is not null then
                 Open csr_payroll_freq(l_payroll_id);
                 Fetch csr_payroll_freq into p_frequency;
                 Close csr_payroll_freq;
               Else
                 p_frequency := l_pgm_frequency;
                 p_proposed_salary :=  L_Cur_Sal;
               End if;
               --
             End if; /** l_update_salary_cd = 'SALARY BASIS' **/
            End if; /** l_continue **/
            --
            -- Convert rate in program frequency to Salary basis/Salary element frequency
            --
            If l_continue then
               If L_Cur_Sal is not null then
                --
                hr_utility.set_location('Calling pqh_gsp_utility.PGM_TO_BASIS_CONVERSION', 80);
                --
                p_proposed_salary := pqh_gsp_utility.PGM_TO_BASIS_CONVERSION
                  (P_Pgm_ID         => l_pgm_id
                  ,P_EFFECTIVE_DATE => P_Effective_Date
                  ,P_AMOUNT         => L_Cur_Sal
                  ,P_ASSIGNMENT_ID  => p_assignment_id);
                --
                --
                hr_utility.set_location('Computing annual salary from program frequency.', 90);
                --
                p_annual_salary := pgm_to_annual(p_ref_perd_cd  => l_pgm_frequency,
                         p_pgm_currency => p_currency,
                         p_amount => L_Cur_Sal);
                --
                p_status := 1;
                --
               End If;
           End if; /** l_continue **/
           --
        Else
           --
           hr_utility.set_location('Grade Ladder setup to not update salary', 120);
           p_status := 4;
           --
        End if;
   Else
     --
     -- Assignment is not on a GL. Cannot compute proposed salary..
     --
     hr_utility.set_location(' Assignment is not on a Grade Ladder. Cannot compute proposed salary', 130);
     p_status := 5;
     --
     --
   End if;
   Close csr_asg_details;
 End if;
 --
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
Exception When others then
  --
  hr_utility.set_location('Exception:'||l_proc, 200);
  raise;
  --
End get_emp_proposed_salary;
--
End;

/
