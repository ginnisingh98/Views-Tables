--------------------------------------------------------
--  DDL for Package Body PQP_US_SRS_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_US_SRS_EXTRACTS" AS
--  /* $Header: pqpussrs.pkb 120.1 2005/06/09 15:12:38 rpinjala noship $ */
--
Cursor csr_rslt_dtl(c_person_id      In Number
                   ,c_ext_rslt_id    In Number
                   ,c_ext_dtl_rcd_id in Number ) Is
Select *
  From ben_ext_rslt_dtl dtl
 Where dtl.ext_rslt_id = c_ext_rslt_id
   And dtl.person_id   = c_person_id
   And dtl.ext_rcd_id  = c_ext_dtl_rcd_id;

-- =============================================================================
-- Get the Legislation Code and Curreny Code
-- =============================================================================
   CURSOR csr_leg_code (c_business_group_id IN Number) IS
      SELECT pbg.legislation_code
        FROM per_business_groups_perf   pbg
       WHERE pbg.business_group_id = c_business_group_id;

-- =============================================================================
-- ~ Get_Balance_Value : Get the Balance Total for the given dimension as of
-- ~ an effective date for an assignment_id
-- =============================================================================
Function Get_Balance_Value
           (p_business_group_id In per_all_assignments_f.business_group_id%TYPE -- Context
           ,p_assignment_id     In per_all_assignments_f.assignment_id%TYPE     -- Context
           ,p_effective_date    In date                                         -- Context
           ,p_balance_name      In varchar2
           ,p_dimension_name    In varchar2) Return Number As

l_balance_amount      Number;
l_defined_balance_id  pay_defined_balances.defined_balance_id%TYPE;
l_proc_name           varchar2(150) := g_proc_name ||'Get_Balance_Value';
l_error               varchar2(500);
Begin
     hr_utility.set_location('Entering: '||l_proc_name, 5);
     Open csr_defined_bal ( c_balance_name      =>  p_balance_name
                           ,c_dimension_name    =>  p_dimension_name
                           ,c_business_group_id => p_business_group_id);
     Fetch csr_defined_bal Into l_defined_balance_id;

     If csr_defined_bal%NOTFOUND Then
        hr_utility.set_location('.......Could not find the defined balance for :'||p_balance_name, 10);
        Close csr_defined_bal;
        l_balance_amount := 0;
     Else
        hr_utility.set_location('.......Balance :'||p_balance_name||' and dimension :'||
                                p_dimension_name||' valid..',15);
        Close csr_defined_bal;
        hr_utility.set_location('.......Before Calling pay_balance_pkg.get_value function..',20);
        pay_balance_pkg.set_context('tax_unit_id', p_business_group_id);
        pay_balance_pkg.set_context('date_earned', p_effective_date);
        l_balance_amount := pay_balance_pkg.get_value(l_defined_balance_id,
                                                      p_assignment_id,
                                                      p_effective_date);
     End If;
     hr_utility.set_location('.......Leaving: '||l_proc_name, 25);
     Return nvl(l_balance_amount,0);
Exception
   When Others Then
   l_error := SQLERRM;
   hr_utility.set_location('.......When Others error raised at Get_Balance_Value', 25);
   hr_utility.set_location('.......SQL-ERRM :'||l_error, 27);
   hr_utility.set_location('Leaving: '||l_proc_name, 30);
   Raise;
End Get_Balance_Value;

-- =============================================================================
-- ~ Get_Header_Information : Common function for Header and Footer data-elements
-- =============================================================================
Function Get_Header_Information(p_header_type In varchar2
                               ,p_header_name In out nocopy Varchar2) Return Number Is

l_proc_name     varchar2(150) := g_proc_name ||'.Get_Header_Information';
l_header_name   varchar2(1000);
l_error         varchar2(500);
-- nocopy changes
l_header_name_nc varchar2(1000);
Begin
   hr_utility.set_location('Entering: '||l_proc_name, 5);

   -- nocopy changes tmehra

   l_header_name_nc := p_header_name;

   If p_header_type = 'EXTRACT_NAME' Then
      l_header_name := 'Plan Name(s) : ';
      For i In 1..g_extract_plan_names.COUNT
      Loop
         l_header_name := l_header_name ||g_extract_plan_names(i).plan_name||' ';
      End Loop;
   Elsif p_header_type = 'PAYROLL_NAME' Then
      l_header_name := 'Payroll Name(s) :';
      For i In 1..g_extract_payroll_names.COUNT
      Loop
         l_header_name := l_header_name||g_extract_payroll_names(i).payroll_name ||' ';
      End Loop;
   ElsIf p_header_type = 'PERIOD_STARTDT' Then
      l_header_name := To_Char(g_extract_start_date,'MM/DD/YYYY');
   ElsIf p_header_type = 'PERIOD_ENDDT' Then
      l_header_name := To_Char(g_extract_end_date,'MM/DD/YYYY');
   Elsif p_header_type = 'PERIOD_PAYDT' Then
      l_header_name := To_Char(g_extract_pay_date,'MM/DD/YYYY');
   Elsif p_header_type = 'PAYROLL_FREQ' Then
      l_header_name := g_payroll_frequency;
   End If;

   p_header_name := l_header_name;
   hr_utility.set_location('Leaving: '||l_proc_name, 45);
 Return 0;
Exception
  When Others Then
   l_error := SQLERRM;
   hr_utility.set_location('.......Exception Others Raised at Get_Header_Information',40);
   hr_utility.set_location('.......SQL-ERRM :'||l_error, 42);
   hr_utility.set_location('Leaving: '||l_proc_name, 45);
   -- nocopy changes tmehra
   p_header_name := l_header_name_nc;
   Return -1;
End Get_Header_Information;

-- ===============================================================================
-- ~ Get_Payroll_Name : Get the Payroll Name for an Assignment                   ~
-- ===============================================================================
Function Get_Payroll_Name (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
                          ,p_payroll_name  In out nocopy varchar2) Return Number Is

Cursor csr_payroll_name (c_payroll_id     In per_all_assignments_f.payroll_id%TYPE
                        ,c_effective_date In date ) Is
  Select payroll_name, period_type
    from pay_payrolls_f
   Where c_effective_date Between effective_start_date
                              and effective_end_date
     and payroll_id = c_payroll_id;

l_payroll_id    per_all_assignments_f.payroll_id%TYPE;
l_start_date    date;
l_end_date      date;
l_payroll_name  pay_payrolls_f.payroll_name%TYPE;
l_period_type   pay_payrolls_f.period_type%TYPE;
l_proc_name     varchar2(150) := g_proc_name ||'.Get_Payroll_Name';
l_error         varchar2(500);
-- nocopy changes tmehra
l_payroll_name_nc pay_payrolls_f.payroll_name%TYPE;
Begin
    hr_utility.set_location('Entering: '||l_proc_name, 5);

    -- nocopy changes tmehra

    l_payroll_name_nc := p_payroll_name;

    If g_primary_asg.EXISTS(p_assignment_id) Then

       hr_utility.set_location('.......Found the pri. assign in g_primary_asg PL/SQL table..',10);
       l_payroll_id := g_primary_asg(p_assignment_id).payroll_id;

    Elsif g_all_sec_asgs.EXISTS(p_assignment_id) Then

       hr_utility.set_location('.......Found the secondary assign in g_all_sec_asgs PL/SQL table..',15);
       l_payroll_id := g_all_sec_asgs(p_assignment_id).payroll_id;

    End If;

    Open csr_time_period (c_payroll_id     => l_payroll_id
                         ,c_effective_date => g_effective_date);
    Fetch csr_time_period Into l_start_date, l_end_date;
    Close csr_time_period;

    Open csr_payroll_name (c_payroll_id     => l_payroll_id
                          ,c_effective_date => g_effective_date);
    Fetch csr_payroll_name Into l_payroll_name,l_period_type;
    close csr_payroll_name;

    hr_utility.set_location('.......Payroll Name :'||l_payroll_name,20);
    hr_utility.set_location('.......Payroll Frequency :'||l_period_type,25);

    g_payroll_names(p_assignment_id).payroll_name       := l_payroll_name;
    g_payroll_names(p_assignment_id).period_type        := l_period_type;
    g_payroll_names(p_assignment_id).payroll_start_date := l_start_date;
    g_payroll_names(p_assignment_id).payroll_end_date   := l_end_date;
    g_payroll_names(p_assignment_id).actual_pay_date    := Null;
    p_payroll_name := l_period_type;
    g_payroll_frequency := l_period_type;

    hr_utility.set_location('Leaving: '||l_proc_name, 35);
    Return 0;

Exception
  When Others Then
    l_error := SQLERRM;
    hr_utility.set_location('.......Exception when others raised at Get_Payroll_Name', 30);
    hr_utility.set_location('.......SQL-ERRM :'||l_error, 33);
    hr_utility.set_location('Leaving: '||l_proc_name, 35);
    -- nocopy changes tmehra
    p_payroll_name := l_payroll_name_nc;
    Return -1;
End Get_Payroll_Name;

-- ===============================================================================
-- ~ Get_Payroll_Start_Date :
-- ===============================================================================
Function Get_Payroll_Start_Date( p_assignment_id In per_all_assignments_f.assignment_id%TYPE
                                ,p_start_date    In out nocopy Varchar2) Return Number Is
l_proc_name     varchar2(150) := g_proc_name ||'.Get_Payroll_Start_Date';
l_date_nc       varchar2(20);
Begin
   hr_utility.set_location('Entering: '||l_proc_name, 5);
   -- nocopy changes tmehra
   l_date_nc := p_start_date;
   If g_extract_start_date Is not Null Then
      p_start_date := fnd_date.date_to_canonical(g_extract_start_date);
      hr_utility.set_location('.......Period Start Date :'||p_start_date,10);
   End If;
   hr_utility.set_location('Leaving: '||l_proc_name, 15);
Return 0;
-- nocopy changes tmehra
EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION  :'||l_proc_name,20);
   p_start_date := l_date_nc;
   RETURN -1;

End Get_Payroll_Start_Date;

-- ===============================================================================
-- ~ Get_Payroll_End_Date :
-- ===============================================================================
Function Get_Payroll_End_Date (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
                              ,p_end_date      In out nocopy Varchar2) Return Number Is
l_proc_name     varchar2(150) := g_proc_name ||'.Get_Payroll_End_Date';
-- nocopy changes tmehra
l_date_nc       varchar2(20);
Begin
   hr_utility.set_location('Entering: '||l_proc_name, 5);
-- nocopy changes tmehra
   l_date_nc := p_end_date;
   If g_extract_end_date Is not Null Then
      p_end_date := fnd_date.date_to_canonical(g_extract_end_date);
      hr_utility.set_location('.......Period End Date :'||p_end_date,10);
   End If;
   hr_utility.set_location('Leaving: '||l_proc_name, 15);
 Return 0;
-- nocopy changes tmehra
EXCEPTION
WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION  :'||l_proc_name,20);
   p_end_date := l_date_nc;
   RETURN -1;

End Get_Payroll_End_Date;

-- ===============================================================================
-- ~ Get_Actual_Pay_Date :
-- ===============================================================================
Function Get_Actual_Pay_Date ( p_assignment_id In per_all_assignments_f.assignment_id%TYPE
                              ,p_pay_date      In out nocopy Varchar2) Return Number Is
l_proc_name     varchar2(150) := g_proc_name ||'.Get_Actual_Pay_Date';
-- nocopy changes tmehra
l_date_nc       varchar2(20);

Cursor csr_pay_date ( c_assignment_id In per_all_assignments_f.assignment_id%TYPE
                     ,c_effective_date In date) Is
Select max(ppa.effective_date)
  from pay_payroll_actions     ppa,
       per_time_periods        ptp
 where c_effective_date between ptp.start_date
                            and ptp.end_date
   and ptp.time_period_id= ppa.time_period_id
   and ppa.action_type in ('Q','R')
   and ppa.payroll_action_id In ( Select payroll_action_id
                                    from pay_assignment_actions
                                   where assignment_id= c_assignment_id
                                     and action_status = 'C');

l_pay_date       date;
l_effective_date date;
Begin

   hr_utility.set_location('Entering: '||l_proc_name, 5);
   -- nocopy changes tmehra
   l_date_nc := p_pay_date;

   l_effective_date := g_effective_date;
   If g_ext_dfn_type = 'SRS_PTD' Then
     If g_primary_asg.EXISTS(p_assignment_id) Then
        l_effective_date := Least(g_primary_asg(p_assignment_id).effective_end_date,g_effective_date);
     ElsIf g_all_sec_asgs.EXISTS(p_assignment_id) Then
        l_effective_date := Least(g_all_sec_asgs(p_assignment_id).effective_end_date,g_effective_date);
     End If;

     Open csr_pay_date ( c_assignment_id  => p_assignment_id
                        ,c_effective_date => l_effective_date);
     Fetch csr_pay_date Into l_pay_date;
     If csr_pay_date%FOUND Then
      close csr_pay_date;
      g_extract_pay_date := l_pay_date;
      p_pay_date := l_pay_date;
      hr_utility.set_location('.......Period Actual Pay Date :'||p_pay_date,10);
     Else
      close csr_pay_date;
     End If;
   End If;

   hr_utility.set_location('Leaving: '||l_proc_name, 15);

Return 0;
Exception
   When Others Then
   hr_utility.set_location('.....Exception When Others raised at Get_Actual_Pay_Date',10);
   hr_utility.set_location('Leaving: '||l_proc_name, 15);
   p_pay_date := l_date_nc;
   Return -1;
End Get_Actual_Pay_Date;

-- ===============================================================================
-- ~ Get_SRS_Plan_Name :
-- ===============================================================================
Function Get_SRS_Plan_Name (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
                           ,p_SRS_Plan_Name In out nocopy Varchar2) Return Number Is
l_proc_name     varchar2(150) := g_proc_name ||'.Get_SRS_Plan_Name';
--Nocopy changes
l_srs_plan_name_nc varchar2(200);

Begin
  hr_utility.set_location('Entering: '||l_proc_name, 5);

  -- nocopy changes
  l_srs_plan_name_nc := p_srs_plan_name;

  If g_extract_plan_name Is Not Null Then
     p_SRS_Plan_Name := g_extract_plan_name;
     hr_utility.set_location('.......Extract Plan Name :'||p_SRS_Plan_Name,10);
  End If;
  hr_utility.set_location('Leaving: '||l_proc_name, 15);
  Return 0;
Exception
  When Others Then
  -- nocopy changes,
  p_srs_plan_name := l_srs_plan_name_nc;
  Return -1;
End Get_SRS_Plan_Name;
-- ===============================================================================
-- ~ Get_Separation_Date :  which occurs first Plan end date in Assig Extra Info ~
-- ~ or the assignment end date i.e. terminated or retired etc.
-- ===============================================================================
Function Get_Separation_Date (p_assignment_id  In per_all_assignments_f.assignment_id%TYPE
                             ,p_Separation_Date In out nocopy Varchar2) Return Number Is

l_proc_name       varchar2(150) := g_proc_name ||'.Get_Separation_Date';
l_assig_end_date  date;
l_separation_date date;
-- nocopy changes
l_separation_date_nc varchar2(20);
Begin

  hr_utility.set_location('Entering: '||l_proc_name, 5);

  -- nocopy changes
  l_separation_date_nc := p_Separation_Date;

  If g_primary_asg.EXISTS(p_assignment_id) Then
       l_assig_end_date := g_primary_asg(p_assignment_id).effective_end_date;
  Elsif  g_all_sec_asgs.EXISTS(p_assignment_id) Then
       l_assig_end_date := g_all_sec_asgs(p_assignment_id).effective_end_date;
  End If;

  l_separation_date := Least(l_assig_end_date,g_plan_end_date);

   If l_separation_date < to_date('31/12/4712','DD/MM/YYYY') Then
      p_Separation_Date := l_separation_date;
      hr_utility.set_location('.......Separation date :'||p_Separation_date,10);
  End If;

  hr_utility.set_location('Leaving: '||l_proc_name, 15);

Return 0;
Exception
  When Others Then
  -- nocopy changes
  p_separation_date := l_separation_date_nc;
  Return -1;

End Get_Separation_Date;

-- ===============================================================================
-- ~ Get_Assig_Status : Fetchs the Assignment status for a given assignment id   ~
-- ===============================================================================
Function Get_Assig_Status (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
                          ,p_status_code   In out nocopy Varchar2) Return Number Is
Cursor cur_status_name
     (c_assignment_status_type_id In per_all_assignments_f.assignment_status_type_id%TYPE) Is
select user_status
  from per_assignment_status_types
 where assignment_status_type_id  = c_assignment_status_type_id;

l_assig_status   per_assignment_status_types.user_status%TYPE;
l_assig_type_id  per_all_assignments_f.assignment_status_type_id%TYPE;
l_proc_name      varchar2(150) := g_proc_name ||'.Get_Assig_Status';
l_error          varchar2(500);
-- nocopy changes
l_status_code_nc varchar2(100);

Begin
    hr_utility.set_location('Entering: '||l_proc_name, 5);
    -- nocopy changes
    l_status_code_nc := p_status_code;

    If g_primary_asg.EXISTS(p_assignment_id) Then
       l_assig_type_id := g_primary_asg(p_assignment_id).assignment_status_type_id;
       Open cur_status_name(c_assignment_status_type_id => l_assig_type_id);
       Fetch cur_status_name Into l_assig_status;
       Close cur_status_name;
       p_status_code := l_assig_status;
    Elsif  g_all_sec_asgs.EXISTS(p_assignment_id) Then
       l_assig_type_id := g_all_sec_asgs(p_assignment_id).assignment_status_type_id;
       Open cur_status_name(c_assignment_status_type_id => l_assig_type_id);
       Fetch cur_status_name Into l_assig_status;
       Close cur_status_name;
       p_status_code := l_assig_status;
    End If;
    hr_utility.set_location('.......Assign Status :'|| p_status_code, 10);
    hr_utility.set_location('Leaving: '||l_proc_name, 15);
Return 0;
Exception
 When Others Then
 l_error := SQLERRM;
 hr_utility.set_location('.......Exception When Others Raised In Get_Assig_Status',13);
 hr_utility.set_location('.......SQL-ERRM :'||l_error, 14);
 hr_utility.set_location('Leaving: '||l_proc_name, 15);
 p_status_code := l_status_code_nc;
 Return -1;

End Get_Assig_Status;

-- ===============================================================================
-- ~ Get_Person_Indentifier : Return the Plan Id for the current plan being      ~
-- ~ processed. This is used for both primary and secondary assignments          ~
-- ===============================================================================
Function Get_Person_Indentifier( p_assignment_id     In per_all_assignments_f.assignment_id%TYPE -- context
                                ,p_person_identifier In out nocopy Varchar2 ) Return Number Is
l_proc_name     varchar2(150) := g_proc_name ||'.Get_Person_Indentifier';
-- nocopy changes
l_person_identifier_nc varchar2(100);
Begin
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  l_person_identifier_nc := p_person_identifier;
  p_person_identifier := g_plan_person_identifier;
  hr_utility.set_location('.......Person Plan Id :'||p_person_identifier,10);
  hr_utility.set_location('Leaving: '||l_proc_name, 15);
  Return 0;
Exception
  When Others Then
  p_person_identifier := l_person_identifier_nc;
  Return -1;
End Get_Person_Indentifier;

-- =================================================================================
-- ~ Get_SRS_Deduction_Balances : Returns the balance amount for an assignment for ~
-- ~ any given balance and the dimension is based the extract running i.e. YTD,QTD ~
-- ~ or MTD and is set in the main criteria function Pay_US_SRS_Main_Criteria      ~
-- =================================================================================
Function Get_SRS_Deduction_Balances (p_assignment_id  In per_all_assignments_f.assignment_id%TYPE -- context
                                    ,p_balance_name   In pay_balance_types.balance_name%TYPE
                                    ,p_balance_amount In out nocopy Number
                                     ) Return Number Is

Cursor c_tax_id ( c_assignment_id  In per_all_assignments_f.assignment_id%Type
                 ,c_effective_date In Date) Is
 Select to_number(sft.segment1),
        asg.business_group_id
   From hr_soft_coding_keyflex sft,
        per_assignments_f      asg
  Where sft.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    And asg.assignment_id          = c_assignment_id
    And c_effective_date between asg.effective_start_date
                             and asg.effective_end_date;

l_dimension_name     pay_balance_dimensions.dimension_name%TYPE;
l_defined_balance_id pay_defined_balances.defined_balance_id%TYPE;
l_balance_name       pay_balance_types.balance_name%TYPE;
l_effective_date     date;
l_balance_amount     Number := 0;
l_return_value       Number := 0;
l_proc_name          varchar2(150) := g_proc_name ||'.Get_SRS_Deduction_Balances';
l_error              varchar2(500);
l_tax_id             per_all_assignments_f.organization_id%TYPE;
l_business_group_id  per_all_assignments_f.business_group_id%TYPE;

Begin
     hr_utility.set_location('Entering: '||l_proc_name, 5);

     l_dimension_name := g_dimension_name;
     hr_utility.set_location('.....Dimension Name:' ||l_dimension_name,10);

     If g_primary_asg.EXISTS(p_assignment_id) Then
        l_effective_date := Least(g_primary_asg(p_assignment_id).effective_end_date,g_effective_date);
     ElsIf g_all_sec_asgs.EXISTS(p_assignment_id) Then
        l_effective_date := Least(g_all_sec_asgs(p_assignment_id).effective_end_date,g_effective_date);
     End If;

     Open  c_tax_id ( c_assignment_id   => p_assignment_id
                     ,c_effective_date  => l_effective_date);
     Fetch c_tax_id Into l_tax_id, l_business_group_id;
     If c_tax_id%NOTFOUND Then
       hr_utility.set_location('.....Gre Tax Unit Id Notfound',6);
     End If;
     Close c_tax_id;

     hr_utility.set_location('.....Effective date :'||l_effective_date,15);
     hr_utility.set_location('.....GRE l_tax_id   :'||l_tax_id,20);

     If Trim(Upper(p_balance_name)) = Trim(Upper(g_eligible_comp_balance_C)) Then
           -- Eligible Comp Balance
           l_balance_name := g_eligible_comp_balance;
     Elsif Trim(Upper(p_balance_name)) = Trim(Upper(g_ER_balance_C)) Then
           -- ER Balance
           l_balance_name := g_ER_balance;
     Elsif Trim(Upper(p_balance_name)) = Trim(Upper(g_AT_Contribution_C)) Then
           -- AT Contribution
           l_balance_name := g_AT_Contribution;
     Elsif Trim(Upper(p_balance_name)) = Trim(Upper(g_BuyBack_Balance_C)) Then
           -- Buy Back Balance
           l_balance_name := g_BuyBack_Balance;
     Elsif Trim(Upper(p_balance_name)) = Trim(Upper(g_Additional_Balance_C)) Then
           -- Additional Balance
           l_balance_name := g_Additional_Balance;
     Elsif Trim(Upper(p_balance_name)) = Trim(Upper(g_ER_Additional_C)) Then
           -- ER Additional Balance
           l_balance_name := g_ER_Additional;
     Elsif Trim(Upper(p_balance_name)) = Trim(Upper(g_SRS_balance_C)) Then
           l_balance_name := g_extract_plan_name;
     Else
           -- Balance Name other than the SRS Balances
           l_balance_name := Trim(p_balance_name);
     End If;

     hr_utility.set_location('.....Balance Name :'|| l_balance_name,15);

     Open csr_defined_bal ( c_balance_name   =>  l_balance_name
                           ,c_dimension_name =>  l_dimension_name
                           ,c_business_group_id => l_business_group_id);
     Fetch csr_defined_bal Into l_defined_balance_id;
     If csr_defined_bal%NOTFOUND Then
        hr_utility.set_location('.....Defined Balance Id NOT found for :'||l_balance_name,20);
        Close csr_defined_bal;
        l_return_value := 0;
        --l_return_value := -1;
     Else
        Close csr_defined_bal;
        l_return_value := 0;
        pay_balance_pkg.set_context('tax_unit_id', l_tax_id);
        pay_balance_pkg.set_context('date_earned', l_effective_date);
        l_balance_amount := pay_balance_pkg.get_value(l_defined_balance_id,
                                                      p_assignment_id,
                                                      l_effective_date);
     End If;
     p_balance_amount := nvl(l_balance_amount,0);
     hr_utility.set_location('Leaving: '||l_proc_name, 45);
     Return l_return_value;
Exception
  When Others Then
  p_balance_amount := nvl(l_balance_amount,0);
  l_error := sqlerrm;
  hr_utility.set_location('.....Exception Occured at Get_SRS_Deduction_Balances',30);
  hr_utility.set_location('.....SQL-ERRM :'||l_error, 35);
  hr_utility.set_location('Leaving: '||l_proc_name, 45);
  Return nvl(l_return_value,0);
End Get_SRS_Deduction_Balances;

-- ===============================================================================
-- ~ Get_PTD_Start_End_Date :
-- ===============================================================================
Function  Get_PTD_Start_End_Date(p_assignment_id  In per_all_assignments_f.assignment_id%TYPE
                                ,p_effective_date In Date
                                 ) Return Varchar2 Is

l_assig_rec          csr_get_payroll_id%ROWTYPE;
l_time_period_rec    csr_time_period%ROWTYPE;
l_assig_time_period  csr_time_period%ROWTYPE;
l_return_value       varchar2(5) :='T';
e_ptd_dates_notfound Exception;
l_proc_name          varchar2(150) := g_proc_name ||'.Get_PTD_Start_End_Date';
l_error              varchar2(500);
Begin
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  --
  -- Get the current payroll id for the assignment
  --
  Open csr_get_payroll_id ( c_assignment_id  => p_assignment_id
                           ,c_effective_date => p_effective_date);
  Fetch csr_get_payroll_id Into l_assig_rec;
  If csr_get_payroll_id%NOTFOUND Then
     hr_utility.set_location('.......Payroll Id not found for assignment id :'||p_assignment_id,10);
     Close csr_get_payroll_id;
     l_return_value := 'S0'; -- Failed to get the payroll id for the assignment
     Raise e_ptd_dates_notfound;
  Else
     hr_utility.set_location('.......Payroll Id found in assignment id :'||p_assignment_id,10);
     Close csr_get_payroll_id;
  End If;
  --
  -- Get the time-period start and end date based on the effective date
  --
  Open csr_time_period ( c_payroll_id     => l_assig_rec.payroll_id
                        ,c_effective_date => p_effective_date
                        );
  Fetch  csr_time_period Into l_time_period_rec;
  If csr_time_period%NOTFOUND Then
     hr_utility.set_location('.......Time period not found for payroll id :'||l_assig_rec.payroll_id,15);
     Close csr_time_period;
     l_return_value := 'S1'; -- Failed to get time-period as of the effective date;
     Raise e_ptd_dates_notfound;
  Else
     hr_utility.set_location('.......Time period found for payroll id :'||l_assig_rec.payroll_id,15);
     Close csr_time_period;
  End If;

  g_extract_start_date := l_time_period_rec.start_date;
  g_extract_end_date   := l_time_period_rec.end_date;
  hr_utility.set_location('.......PTD Start date :'|| g_extract_start_date,20);
  hr_utility.set_location('.......PTD End date :'|| g_extract_start_date,25);
  hr_utility.set_location('Leaving: '||l_proc_name, 45);
  Return l_return_value;
Exception
   When e_ptd_dates_notfound Then
    hr_utility.set_location('.......Exception e_ptd_dates_notfound raised in Get_PTD_Start_End_Date',20);
    hr_utility.set_location('Leaving: '||l_proc_name, 45);
    Return l_return_value;
   When Others Then
    l_error := SQLERRM;
    hr_utility.set_location('.......Exception Others raised in Get_PTD_Start_End_Date',20);
    hr_utility.set_location('.......SQL-ERRM :'||l_error, 35);
    hr_utility.set_location('Leaving: '||l_proc_name, 45);
    l_return_value :='S2';
    Return l_return_value;

End Get_PTD_Start_End_Date;
-- ======================================================================================
-- ~ Get_Plan_Names : Gets the Plan Names from Global Values table into global variable ~
-- ======================================================================================
Function Get_Plan_Names ( p_effective_date In Date
                         ,p_extract_name   in Varchar2 ) Return Varchar2 Is

l_extract_names    varchar2(240) := null;
l_count            number        :=1;
l_position         number;
l_plan_name        varchar2(150);
l_return_value     varchar2(5)   :='T';
l_proc_name        varchar2(150) := g_proc_name ||'Get_Plan_Names';
l_error            varchar2(500);
Begin
   hr_utility.set_location('Entering: '||l_proc_name, 5);
   If p_extract_name is Not Null Then
      l_extract_names := p_extract_name;
   Else
      l_return_value := 'P0'; --Global Value For Extract not defined for: SRS_PLAN_NAME
   End If;

   If Trim(l_extract_names)   Is null or
      Trim(l_extract_names) = '' Then
     l_return_value := 'P1'; -- Global Value For Extract is Null/Blank in
   End If;
   If l_return_value ='T' Then
      For i in 1..length(l_extract_names )
      Loop
         l_position := instr(l_extract_names,',');
         If l_position = 0 Then
            g_extract_plan_names(l_count).plan_name := Trim(l_extract_names);
            hr_utility.set_location('......Extract Name Found in Global Value :'||g_extract_plan_names(l_count).plan_name,20);
            l_return_value := 'T';
            Exit;
         Else
            l_plan_name := Trim(substr(l_extract_names,1,l_position-1));
            g_extract_plan_names(l_count).plan_name := l_plan_name;
            hr_utility.set_location('.......Extract Name Found in Global Value :'||g_extract_plan_names(l_count).plan_name,20);
            l_extract_names := substr(l_extract_names,l_position+1);
            l_count := l_count + 1;
         End If;
      End loop;
   End If;
  hr_utility.set_location('Leaving: '||l_proc_name, 45);
   Return l_return_value;
Exception
   When Others Then
   hr_utility.set_location('.......When Others error in Get_Plan_Names',25);
   l_error := sqlerrm;
   hr_utility.set_location('.......SQL-ERRM :'||l_error,40);
   hr_utility.set_location('Leaving: '||l_proc_name, 45);
   l_return_value := 'P2';
   Return l_return_value;
End Get_Plan_Names;

-- ============================================================================================
-- ~ Get_Payroll_Names : Gets the Payroll Names from Global Values table into global variable ~
-- ============================================================================================
Function Get_Payroll_Names ( p_effective_date In Date
                            ,p_payroll_name   In varchar2) Return Varchar2 Is

l_return_value       varchar2(5)    := 'T';
l_position           number(5);
l_count              number(5)      := 1;
l_payroll_names      varchar2(140);
l_payroll_name       varchar2(140);
l_proc_name          varchar2(150)  := g_proc_name||'Get_Payroll_Name';
l_error              varchar2(500);
Begin
   hr_utility.set_location('Entering: '||l_proc_name, 5);
   If p_payroll_name is Not Null Then
      l_payroll_names := p_payroll_name;
   Else
      l_return_value := 'P0'; --Variable l_extract_plan_name in the FF is not set
   End If;
   hr_utility.set_location('Payroll Name(s) :'||l_payroll_names,15);

   If Trim(l_payroll_names)   Is null or
      Trim(l_payroll_names) = '' Then
      l_payroll_names := Null;
      l_return_value := 'N'; -- Variable Is set to blank
   End If;

   If l_return_value ='T' Then
     For i in 1..length(l_payroll_names)
     Loop
       l_position := instr(l_payroll_names,',');
       If l_position = 0 Then
          g_extract_payroll_names(l_count).payroll_name := Trim(l_payroll_names);
          hr_utility.set_location('.......Payroll Name Found :'||g_extract_payroll_names(l_count).payroll_name,20);
          l_return_value := 'T';
          Exit;
       Else
          l_payroll_name := Trim(substr(l_payroll_names,1,l_position-1));
          g_extract_payroll_names(l_count).payroll_name := l_payroll_name;
          hr_utility.set_location('.......Payroll Name Found :'||g_extract_payroll_names(l_count).payroll_name,20);
          l_payroll_names := substr(l_payroll_names,l_position+1);
          l_count := l_count + 1;
       End If;
     End loop;
    End If;

  hr_utility.set_location('Leaving: '||l_proc_name, 45);
  Return l_return_value;
Exception
   When Others Then
   hr_utility.set_location('.......When Others error in Get_Payroll_Name..',25);
   l_error := sqlerrm;
   hr_utility.set_location('.......SQL-ERRM :'||l_error,40);
   hr_utility.set_location('Leaving: '||l_proc_name, 45);
   l_return_value := 'P2';
   Return l_return_value;

End Get_Payroll_Names;

-- ===============================================================================
-- ~ Check_Valid_Payroll : For the given assignment return the payroll name      ~
-- ===============================================================================
Function Check_Valid_Payroll ( p_assignment_id  In per_all_assignments_f.assignment_id%TYPE
                              ,p_effective_date In Date) Return Varchar2 Is

l_payroll_id    pay_payrolls_f.payroll_id%TYPE;
l_payroll_name  pay_payrolls_f.payroll_name%TYPE;
l_period_type   pay_payrolls_f.period_type%TYPE;
l_return_value  pay_payrolls_f.payroll_name%TYPE;
l_proc_name     varchar2(150) := g_proc_name||'Check_Valid_Payroll';
l_error         varchar2(500);

Begin
    hr_utility.set_location('Entering :'|| l_proc_name,5);
    If g_primary_asg.EXISTS(p_assignment_id) Then

       hr_utility.set_location('.......Found the pri. assign in g_primary_asg PL/SQL table..',10);
       l_payroll_id := g_primary_asg(p_assignment_id).payroll_id;

    Elsif g_all_sec_asgs.EXISTS(p_assignment_id) Then

       hr_utility.set_location('.......Found the secondary assign in g_all_sec_asgs PL/SQL table..',15);
       l_payroll_id := g_all_sec_asgs(p_assignment_id).payroll_id;

    End If;
    Open csr_payroll_name (c_payroll_id     => l_payroll_id
                          ,c_effective_date => p_effective_date);
    Fetch csr_payroll_name Into l_payroll_name,l_period_type;
    close csr_payroll_name;
    l_return_value := l_payroll_name;

    hr_utility.set_location('Leaving :'|| l_proc_name,30);
    Return l_return_value;
Exception
    When Others Then
     hr_utility.set_location('.......Exception When Others Raised In Check_Valid_Payroll..',25);
     l_error := sqlerrm;
     hr_utility.set_location('.......SQL-ERRM :'||l_error,30);
     hr_utility.set_location('Leaving :'|| l_proc_name,40);
End Check_Valid_Payroll;

-- ===============================================================================
-- ~ Check_Assig_Extra_Info : Check the SRS Plan details in the Assig Extra Info ~
-- ===============================================================================
Function Check_Assig_Extra_Info ( p_assignment_id      In per_all_assignments_f.assignment_id%TYPE
                                 ,p_extract_plan_name  In varchar2
                                 ,p_extract_start_date In date
                                 ,p_extract_end_date   In date
                                 ) Return Varchar2 Is

l_assig_extra_info csr_assig_extra_info%ROWTYPE;
l_return_value Varchar2(5) :='N';
l_start_date   Date;
l_end_date     Date;
l_proc_name    varchar2(150) := g_proc_name ||'.Check_Assig_Extra_Info';
l_error        varchar2(500);
Begin
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  For l_assig_extra_info In csr_assig_extra_info( c_assignment_id => p_assignment_id)
  Loop
      l_start_date := fnd_date.canonical_to_date(l_assig_extra_info.aei_information1);
      If l_assig_extra_info.aei_information2 Is Null Then
         l_end_date := to_date('31/12/4712','DD/MM/YYYY');
      Else
         l_end_date   := fnd_date.canonical_to_date(l_assig_extra_info.aei_information2);
      End If;
      -- If the SRS Plan present in
      If l_assig_extra_info.aei_information4 Is Not Null           and
         l_assig_extra_info.aei_information4 = p_extract_plan_name and
         ( (g_effective_date between l_start_date
                                 and l_end_date)
            Or
            (l_start_date between g_extract_start_date
                             and  g_extract_end_date)
            Or
            (l_end_date between g_extract_start_date
                            and g_extract_end_date )
          )Then
         g_plan_start_date        := l_start_date;
         g_plan_end_date          := l_end_date;
         g_plan_person_identifier := l_assig_extra_info.aei_information3;
         g_extract_plan_name      := l_assig_extra_info.aei_information4;
         g_qualifies_10yr_rule    := l_assig_extra_info.aei_information5;
         g_qualifies_GrdFathering := l_assig_extra_info.aei_information6;
         hr_utility.set_location('.......Plan Name :'|| g_extract_plan_name, 20);
         hr_utility.set_location('.......Person Plan Id :'|| g_plan_person_identifier, 25);
         hr_utility.set_location('.......Plan Start Date :'|| g_plan_start_date, 30);
         hr_utility.set_location('.......Plan End Date :'|| g_plan_end_date, 35);

         l_return_value := 'Y'; Exit;

       End If;
  End Loop; -- l_assig_extra_info
  hr_utility.set_location('Leaving: '||l_proc_name, 45);
  Return l_return_value;
Exception
  When Others Then
   l_error := sqlerrm;
   hr_utility.set_location('.......Exception Others Raised at Check_Assig_Extra_Info',30);
   hr_utility.set_location('.......SQL-ERRM :'||l_error,40);
   hr_utility.set_location('Leaving: '||l_proc_name, 45);
   l_return_value := 'A0';
   Return l_return_value;
End Check_Assig_Extra_Info;

-- ===============================================================================
-- ~ Pay_US_SRS_Main_Criteria : The Main Extract Criteria for the SRS Extracts   ~
-- ===============================================================================
Function Pay_US_SRS_Main_Criteria ( p_assignment_id        In per_all_assignments_f.assignment_id%TYPE
                                   ,p_effective_date       In date
                                   ,p_business_group_id    In per_all_assignments_f.business_group_id%TYPE
                                   ,p_extract_plan_name    In varchar2
                                   ,p_extract_payroll_name In varchar2
                                   ) Return Varchar2 Is

Cursor csr_extract_attributes Is
 Select  eat.ext_dfn_type
        ,eat.ext_dfn_id
   From  pqp_extract_attributes eat
  Where  eat.ext_dfn_id = ben_ext_thread.g_ext_dfn_id;

Cursor csr_chk_person ( c_person_id In per_all_people_f.person_id%TYPE
                       ,c_effective_date In Date ) Is
 select *
   from per_all_people_f
  where person_id = c_person_id
    and c_effective_date between effective_start_date
                             and effective_end_date;

l_error_value   Number;
l_return_value  Varchar2(5) :='N';
l_primary_asg   csr_assig_rec%ROWTYPE;
e_ext_criteria  Exception;
l_proc_name     varchar2(150) := g_proc_name ||'Pay_US_SRS_Main_Criteria';
l_error         varchar2(500);
Begin
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Select the extract period type i.e Month, Year Quarter etc.
  -- ~ only required the first time the criteria is called
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  If g_business_group_id Is Null Then
     g_effective_date        := p_effective_date;
     g_business_group_id     := p_business_group_id;

     open  csr_leg_code(p_business_group_id);
     Fetch csr_leg_code Into g_legislation_code;
     Close csr_leg_code;

     Open csr_extract_attributes;
     Fetch csr_extract_attributes Into g_ext_dfn_type, g_ext_dfn_id;
     hr_utility.set_location('.......Extract Type :'||g_ext_dfn_type, 10);
     If csr_extract_attributes%NOTFOUND Then
       Close csr_extract_attributes;
       l_return_value := 'E0';
       Raise e_ext_criteria;
     Else
      Close csr_extract_attributes;
     End If;

     -- Get the Extract Plan Names from ff_globals_f for SRS_PLAN_NAME
     -- into g_extract_plan_names table
     hr_utility.set_location('.......Get Extract Plan Names ', 15);
     l_return_value := Get_Plan_Names( p_effective_date => p_effective_date
                                      ,p_extract_name   => p_extract_plan_name);
     If l_return_value Like 'P%' Then
        Raise e_ext_criteria;
     End If;
     -- Get the Extract Payroll Names from ff_globals_f for SRS_PAYROLL_NAME
     -- into g_extract_plan_names table
     hr_utility.set_location('.......Get Extract Payroll Names ', 15);
     l_return_value := Get_Payroll_Names( p_effective_date => p_effective_date
                                         ,p_payroll_name   => p_extract_payroll_name);

     If g_ext_dfn_type = 'SRS_MTD' Then
        g_extract_start_date := trunc(p_effective_date,'MONTH');
        g_extract_end_date   := p_effective_date;
        g_dimension_name :='Assignment within Government Reporting Entity Month';
     Elsif g_ext_dfn_type = 'SRS_QTD' Then
        g_extract_start_date := trunc(p_effective_date,'Q');
        g_extract_end_date   := p_effective_date;
        g_dimension_name := 'Assignment within Government Reporting Entity Quarter to Date';
     Elsif g_ext_dfn_type = 'SRS_YTD' Then
        g_extract_start_date := trunc(p_effective_date,'YEAR');
        g_extract_end_date   := p_effective_date;
        g_dimension_name := 'Assignment within Government Reporting Entity Year to Date';
     End If;
  End If; --If g_business_group_id Is Null

  If g_ext_dfn_type = 'SRS_PTD' Then
     g_dimension_name := 'Assignment within Government Reporting Entity Period to Date';
     -- The procedure sets the g_extract_start_date, g_extract_end_date globals
     -- based on the per_time_periods of the assig. payroll_id
     l_return_value := Get_PTD_Start_End_Date(p_assignment_id  => p_assignment_id
                                             ,p_effective_date => p_effective_date
                                              );
     If l_return_value Like 'S%' Then
        hr_utility.set_location('.......Error In Function Get_PTD_Start_End_Date',15);
	l_return_value := 'N';
        Raise e_ext_criteria;
     End If;

  End If;

  hr_utility.set_location('.......Extracts Dimension :'||g_dimension_name, 20);
  hr_utility.set_location('.......Extract Start Date :'||g_extract_start_date,25);
  hr_utility.set_location('.......Extract End Date :'||g_extract_end_date,30);
  hr_utility.set_location('.......Checking if assignment_id :'||p_assignment_id||' valid for date range..',35);

  Open csr_assig_rec ( c_assignment_id      => p_assignment_id
                      ,c_business_group_id  => p_business_group_id
                      ,c_effective_date     => p_effective_date
                      ,c_extract_start_date => g_extract_start_date
                      ,c_extract_end_date   => g_extract_end_date);
  Fetch csr_assig_rec Into l_primary_asg;

  If csr_assig_rec%FOUND Then
     If l_primary_asg.assignment_type ='E' Then
        l_return_value := 'N';
        g_primary_asg(l_primary_asg.assignment_id) := l_primary_asg;
        hr_utility.set_location('......Assignment Id :'||p_assignment_id||' found..',40);
        If g_extract_payroll_names.COUNT > 0 Then
           For j In 1..g_extract_payroll_names.COUNT
           Loop
             If g_extract_payroll_names(j).payroll_name =
                Check_Valid_Payroll ( p_assignment_id  => p_assignment_id
                                     ,p_effective_date => g_effective_date) Then
                l_return_value := 'Y'; Exit;
             End If;
           End Loop;
        Else
           l_return_value := 'Y';
        End If; -- g_extract_payroll_names.COUNT > 0
     Elsif l_primary_asg.assignment_type ='B' Then
           g_primary_asg(l_primary_asg.assignment_id) := l_primary_asg;
           l_return_value := 'B';
           hr_utility.set_location('......Assignment Type :'||l_return_value,41);
     End If;

     If l_return_value = 'Y' Then
        For i In 1..g_extract_plan_names.COUNT
        Loop
          hr_utility.set_location('.......Checking for Extract Plan Name :'||g_extract_plan_names(i).plan_name,45);
          l_return_value:=  Check_Assig_Extra_Info
                                 ( p_assignment_id      => p_assignment_id
                                  ,p_extract_plan_name  => g_extract_plan_names(i).plan_name
                                  ,p_extract_start_date => g_extract_start_date
                                  ,p_extract_end_date   => g_extract_end_date
                                  );
          If l_return_value = 'Y' Then
             -- SRS Plan found, set the global balances names and exit loop
             hr_utility.set_location('.......Found Assig Extra Info for :'||g_extract_plan_names(i).plan_name,50);
             g_extract_plan_name  := g_extract_plan_names(i).plan_name;
             g_extract_plan_names(i).assignment_id := p_assignment_id;
             g_eligible_comp_balance := g_extract_plan_name||g_eligible_comp_balance_C;
             g_srs_balance           := g_extract_plan_name;
             g_ER_balance            := g_extract_plan_name||g_ER_balance_C;
             g_AT_Contribution       := g_extract_plan_name||g_AT_Contribution_C;
             g_BuyBack_Balance       := g_extract_plan_name||g_BuyBack_Balance_C;
             g_Additional_Balance    := g_extract_plan_name||g_Additional_Balance_C;
             g_ER_Additional         := g_extract_plan_name||g_ER_Additional_C;
             Exit;
          Elsif l_return_value Like 'A%' Then
             hr_utility.set_location('.......Error in function Check_Assig_Extra_Info',50);
             Raise e_ext_criteria;
          Else
             hr_utility.set_location('.......Extract Plan :'|| g_extract_plan_name||' not found..',50);
             l_return_value :='N';
          End If;
        End Loop; -- i In 1..g_extract_plan_names.COUNT
     Elsif l_return_value ='B' Then
           -- This means that the assignment is a Benefits Assignment (OAB) which is created
           -- when a person is terminated.
           g_plan_start_date        := Null;
           g_plan_end_date          := Null;
           g_plan_person_identifier := Null;
           g_extract_plan_name      := Null;
           g_qualifies_10yr_rule    := Null;
           g_qualifies_GrdFathering := Null;
           g_extract_plan_name      := 'BEN_ASSIGN';
           hr_utility.set_location('......Before Assignment Type :'||l_return_value,51);
           l_return_value :='Y';
           hr_utility.set_location('......After Assignment Type :'||l_return_value,52);
     End If; -- l_return_value = 'Y'
  Else
     hr_utility.set_location('.......Assignment_id : '||p_assignment_id||' not valid for date range..',40);
     l_return_value :='N';
  End If;
  Close csr_assig_rec;
  hr_utility.set_location('......Return Value :'||l_return_value,89);
  hr_utility.set_location('Leaving: '||l_proc_name, 90);
  Return l_return_value;
Exception
  When e_ext_criteria Then
   hr_utility.set_location('.......Exception e_ext_criteria raised in Pay_US_SRS_Main_Criteria..',55);
   hr_utility.set_location('Leaving: '||l_proc_name, 90);
   Return l_return_value;
  When Others Then
   hr_utility.set_location('.......When Others Error Raise in Pay_US_SRS_Main_Criteria..',55);
   l_error := sqlerrm;
   hr_utility.set_location('.......SQL-ERRM :'||l_error,85);
   hr_utility.set_location('Leaving: '||l_proc_name, 90);
   l_return_value :='M0';
   Return l_return_value;
End Pay_US_SRS_Main_Criteria;

-- ===============================================================================
-- ~ Get_Secondary_Assignments : Fetchs all the Secondary Assignments            ~
-- ===============================================================================
Function Get_Secondary_Assignments
          ( p_primary_assignment_id in per_all_assignments_f.assignment_id%TYPE
           ,p_person_id             in per_all_people_f.person_id%TYPE
           ,p_effective_date        in date
           ,p_extract_start_date    in date
           ,p_extract_end_date      in date ) Return Varchar2 Is


l_sec_asgs		csr_sec_assignments%ROWTYPE;
l_curr_asg_id   per_all_assignments_f.assignment_id%TYPE;
l_prev_asg_id   per_all_assignments_f.assignment_id%TYPE;
l_return_value  varchar2(1);
l_proc_name     varchar2(150) := g_proc_name ||'.Get_Secondary_Assignments';
l_error         varchar2(1000);
Begin
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  FOR l_sec_asgs IN csr_sec_assignments(c_primary_assignment_id => p_primary_assignment_id
                                       ,c_person_id		        => p_person_id
                                       ,c_effective_date    	=> p_effective_date
                                       ,c_extract_start_date    => p_extract_start_date
                                       ,c_extract_end_date      => p_extract_end_date )
  Loop
     g_all_sec_asgs(l_sec_asgs.assignment_id) := l_sec_asgs;
  End Loop; -- l_sec_asgs IN csr_sec_assignments

  If g_all_sec_asgs.COUNT > 0 Then
     l_return_value := 'Y';
  Else
    l_return_value := 'N';
  End If; --l_all_sec_asgs.COUNT > 0
  hr_utility.set_location('Leaving: '||l_proc_name, 5);
  Return l_return_value;

Exception
   When Others Then
    l_error := substr(SQLERRM,1,999);
    hr_utility.set_location('....SQLERRM :'||l_error, 50);
    hr_utility.set_location('Leaving: '||l_proc_name, 55);
    Raise;
End Get_Secondary_Assignments;

-- ===============================================================================
-- ~ Create_Secondary_Lines : This function is called by the hidden record to    ~
-- ~ check if any secondary assignments exits for the employee. If found then    ~
-- ~ check the assignment extra info for the plan details.                       ~
-- ===============================================================================
Function Create_Secondary_Assig_Lines ( p_assignment_id in per_all_assignments_f.assignment_id%TYPE
                                       ) Return Varchar2 Is
l_primary_assig_id   per_all_assignments_f.assignment_id%TYPE;
l_curr_sec_asg_id    per_all_assignments_f.assignment_id%TYPE;
l_prev_sec_asg_id    per_all_assignments_f.assignment_id%TYPE;

l_return_value       varchar2(40);
l_valid_payroll      varchar2(40);
l_error_value        varchar2(5);
l_secondary_no       number(5) :=1;
l_primary_no         number(5) :=1;
l_assign_type        varchar2(150);
e_ext_criteria       Exception;
l_proc_name     varchar2(150) := g_proc_name ||'.Create_Secondary_Assig_Lines';
l_error         varchar2(1000);
l_main_rec            csr_rslt_dtl%ROWTYPE;
Begin
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Section(A): Create a new record for each pri. assignment which have more
  -- ~ than one Plan Name in the Assign Extra Info.
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- We don't want the benefits primary assignment, hence we will delete this after
  -- checking for the secondary and terminated active assignment within a given
  -- date-range.
  If g_primary_asg(p_assignment_id).assignment_type <> 'E' Then
     Open csr_ext_rcd_id(c_hide_flag	=> 'N'    -- N=No record is not hidden one
                        ,c_rcd_type_cd	=> 'D' ); -- D=Detail, T=Total, H-Header Record types
     Fetch csr_ext_rcd_id INTO g_ext_dtl_rcd_id;
     Close csr_ext_rcd_id;
     hr_utility.set_location('.....Get the results record for person id :'||g_primary_asg(p_assignment_id).person_id,15);
     Open csr_rslt_dtl
                (c_person_id      => g_primary_asg(p_assignment_id).person_id
                ,c_ext_rslt_id    => ben_ext_thread.g_ext_rslt_id
                ,c_ext_dtl_rcd_id => g_ext_dtl_rcd_id
                );
     Fetch csr_rslt_dtl INTO l_main_rec;
     Close csr_rslt_dtl;

  End If; -- g_primary_asg(p_assignment_id).assignment_type <> 'E'

  hr_utility.set_location('.....Checking if more SRS Plans exists for pri. assign',10);
  If g_extract_plan_names.COUNT > 1 Then
     For i In 1..g_extract_plan_names.COUNT
     Loop
       hr_utility.set_location('.....Previous SRS Plan :'||g_extract_plan_name||'..',15);
       hr_utility.set_location('.....Current SRS Plan :'||g_extract_plan_names(i).plan_name||'..',20);

       If (g_extract_plan_names(i).assignment_id Is Null
          Or g_extract_plan_names(i).assignment_id <> p_assignment_id) and
          Check_Assig_Extra_Info( p_assignment_id      => p_assignment_id
                                 ,p_extract_plan_name  => g_extract_plan_names(i).plan_name
                                 ,p_extract_start_date => g_extract_start_date
                                 ,p_extract_end_date   => g_extract_end_date
                                   ) ='Y' Then
           g_extract_plan_name  := g_extract_plan_names(i).plan_name;
           g_extract_plan_names(i).assignment_id := p_assignment_id;
           hr_utility.set_location('.....Found Plan :'|| g_extract_plan_names(i).plan_name||'..',25);
           hr_utility.set_location('.....Person Identifier :'|| g_plan_person_identifier||'..',30);

           g_eligible_comp_balance := g_extract_plan_name||g_eligible_comp_balance_C;
           g_srs_balance           := g_extract_plan_name;
           g_ER_balance            := g_extract_plan_name||g_ER_balance_C;
           g_AT_Contribution       := g_extract_plan_name||g_AT_Contribution_C;
           g_BuyBack_Balance       := g_extract_plan_name||g_BuyBack_Balance_C;
           g_Additional_Balance    := g_extract_plan_name||g_Additional_Balance_C;
           g_ER_Additional         := g_extract_plan_name||g_ER_Additional_C;

           hr_utility.set_location('.....Call Create_New_Lines procedure',35);
           Create_New_Lines( p_pri_assignment_id  => p_assignment_id
                            ,p_sec_assignment_id  => p_assignment_id
                            ,p_person_id          => g_primary_asg(p_assignment_id).person_id
                            ,p_record_name        => 'Primary['||l_secondary_no||'] :'||g_extract_plan_name );
           l_secondary_no := l_secondary_no +1;

       End If; --g_extract_plan_names(i).plan_name <> g_extract_plan_name
     End Loop; -- For i In 1..g_extract_plan_names
  End If; --g_extract_plan_name.COUNT > 1


  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Section(B): Create a new record for each sec. assignment which have the
  -- ~ Plan Name in the Assign Extra Info.
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  hr_utility.set_location('.....Checking if secondary assignments present for id :'||p_assignment_id,40);
  hr_utility.set_location('.....g_extract_start_date :'||g_extract_start_date,41);
  hr_utility.set_location('.....g_extract_end_date :'||g_extract_end_date,41);
  hr_utility.set_location('.....p_assignment_id   :'||p_assignment_id,41);
  If Get_Secondary_Assignments
          ( p_primary_assignment_id => p_assignment_id
           ,p_person_id             => g_primary_asg(p_assignment_id).person_id
           ,p_effective_date        => g_effective_date
           ,p_extract_start_date    => g_extract_start_date
           ,p_extract_end_date      => g_extract_end_date ) = 'Y' Then
      l_return_value :='SEC_ASSIGN_FOUND';
      hr_utility.set_location('.....Secondary assignment found for id :'|| p_assignment_id,45);
  Else
      l_return_value :='SEC_ASSIGN_NOTFOUND';
      hr_utility.set_location('.....Secondary assignment NOT found for id :'|| p_assignment_id,45);
  End If;

  If l_return_value = 'SEC_ASSIGN_FOUND' and
     g_all_sec_asgs.COUNT > 0 Then
     l_secondary_no := 1;
     l_primary_no   := 1;
     l_curr_sec_asg_id := g_all_sec_asgs.FIRST;
     While l_curr_sec_asg_id Is Not Null
     Loop
        If g_extract_payroll_names.COUNT > 0 Then
         l_valid_payroll := 'N';
         For j In 1..g_extract_payroll_names.COUNT
           Loop
             If g_extract_payroll_names(j).payroll_name =
                Check_Valid_Payroll ( p_assignment_id  => l_curr_sec_asg_id
                                     ,p_effective_date => g_effective_date) Then
                l_valid_payroll := 'Y'; Exit;
             End If;
         End Loop;
        Else
         l_valid_payroll := 'N';
        End If; -- g_extract_payroll_names.COUNT > 0

        If l_valid_payroll = 'Y' Then
           hr_utility.set_location('.....Processing for Secondary assignment id :'|| l_curr_sec_asg_id,50);
           If g_ext_dfn_type = 'SRS_PTD' Then
              hr_utility.set_location('Extract type Is PTD, so get the PTD start end dates based on payroll id..',55);
              g_dimension_name := 'Assignment within Government Reporting Entity Period to Date';
              -- The procedure sets the g_extract_start_date, g_extract_end_date globals
              -- based on the per_time_periods of the assig. payroll_id
              hr_utility.set_location('.....Calling Get_PTD_Start_End_Date in Create_Secondary_Assig_Lines..',60);
              l_error_value := Get_PTD_Start_End_Date(p_assignment_id  => l_curr_sec_asg_id
                                                     ,p_effective_date => g_effective_date
                                                      );
              If l_error_value Like 'S%' Then
                 hr_utility.set_location('.....Error In Get_PTD_Start_End_Date',65);
                 Raise e_ext_criteria;
              End If;
           End If; --If g_ext_dfn_type = 'SRS_PTD'

           hr_utility.set_location('.....Checking sec. assign for each plan',65);

           For i In 1..g_extract_plan_names.COUNT
           Loop
           -- The sec. assign may be on a different payroll and the PTD start and end
           -- dates should be calcualted based on the payroll period of the assignment
           -- Check first if the person has the Plan details in Assig Extra Info
             hr_utility.set_location('Checking for Plan :'||g_extract_plan_names(i).plan_name,70);
             If Check_Assig_Extra_Info( p_assignment_id      => l_curr_sec_asg_id
                                       ,p_extract_plan_name  => g_extract_plan_names(i).plan_name
                                       ,p_extract_start_date => g_extract_start_date
                                       ,p_extract_end_date   => g_extract_end_date
                                       ) ='Y'
                and ( g_extract_plan_names(i).assignment_id Is Null
                      Or g_extract_plan_names(i).assignment_id <> l_curr_sec_asg_id) Then
                g_extract_plan_name  := g_extract_plan_names(i).plan_name;
                g_extract_plan_names(i).assignment_id := l_curr_sec_asg_id;
                hr_utility.set_location('.....Found Plan :'||g_extract_plan_name,75);
                hr_utility.set_location('.....Person Identifier :'||g_plan_person_identifier,80);

                g_eligible_comp_balance := g_extract_plan_name||g_eligible_comp_balance_C;
                g_srs_balance           := g_extract_plan_name;
                g_ER_balance            := g_extract_plan_name||g_ER_balance_C;
                g_AT_Contribution       := g_extract_plan_name||g_AT_Contribution_C;
                g_BuyBack_Balance       := g_extract_plan_name||g_BuyBack_Balance_C;
                g_Additional_Balance    := g_extract_plan_name||g_Additional_Balance_C;
                g_ER_Additional         := g_extract_plan_name||g_ER_Additional_C;
                hr_utility.set_location('.....Before Create_New_Lines for sec. assignment id: '||l_curr_sec_asg_id,85);

                If g_all_sec_asgs(l_curr_sec_asg_id).primary_flag = 'Y' Then
                   l_assign_type := 'Primary['||l_primary_no||'] :'|| g_extract_plan_name;
                   l_primary_no := l_primary_no +1;
                Else
                   l_assign_type := 'Secondary['||l_secondary_no||'] :'||g_extract_plan_name;
                   l_secondary_no := l_secondary_no +1;
                End If;

                 Create_New_Lines( p_pri_assignment_id  => g_primary_asg(p_assignment_id).assignment_id
                                 ,p_sec_assignment_id  => l_curr_sec_asg_id
                                 ,p_person_id          => g_primary_asg(p_assignment_id).person_id
                                 ,p_record_name        => l_assign_type);

                hr_utility.set_location('.....After Create_New_Lines for sec. assignment id: '||l_curr_sec_asg_id,90);
             End If;
           End Loop; --For i In 1..g_extract_plan_names.COUNT
         End If; --If l_valid_payroll := 'Y'
         l_prev_sec_asg_id := l_curr_sec_asg_id;
         l_curr_sec_asg_id := g_all_sec_asgs.NEXT(l_prev_sec_asg_id);

        End Loop; -- While l_curr_sec_asg_id Is Not Null
     g_all_sec_asgs.DELETE;
  End If;
  If g_primary_asg(p_assignment_id).assignment_type <> 'E' Then
     Delete from ben_ext_rslt_dtl where ext_rslt_dtl_id = l_main_rec.ext_rslt_dtl_id;
  End If;
  g_primary_asg.DELETE;
  g_payroll_names.DELETE;
  hr_utility.set_location('Leaving: '||l_proc_name, 130);
 Return l_return_value;
Exception
  When e_ext_criteria Then
    hr_utility.set_location('.....Error e_ext_criteria raised ...',70);
    hr_utility.set_location('Leaving: '||l_proc_name, 130);
    Return l_return_value;
  When Others Then
    l_error := substr(SQLERRM,1,999);
    hr_utility.set_location('.....When Others Error Raised...',120);
    hr_utility.set_location('.....SQLERRM :'||l_error,121);
    hr_utility.set_location('Leaving: '||l_proc_name, 130);

    Raise;
End Create_Secondary_Assig_Lines;


--=========================================================
---Added new function to get EE DCP contribution Limit
--This function is for Over limit report.
--============================================================
FUNCTION get_dcp_limit (p_effective_date DATE)
RETURN NUMBER IS

CURSOR c_dcp_limit (cp_effective_date DATE)
IS
SELECT     fed_information5 dcp_limit   -- DCP EE Contribution Limit
          ,effective_start_date
          ,effective_end_date
   FROM   pay_us_federal_tax_info_f
   WHERE  fed_information_category = 'SRS LIMITS'
     AND  cp_effective_date  BETWEEN effective_start_date
                                AND effective_end_date;
l_dcp_limit c_dcp_limit%ROWTYPE;
BEGIN
 OPEN  c_dcp_limit (p_effective_date);
  FETCH c_dcp_limit INTO l_dcp_limit;
 CLOSE c_dcp_limit;
 RETURN (l_dcp_limit.dcp_limit);

END;


--------------End Function get_dcp_limit-----------------------------------+

-- ================================================================================
-- ~ Create_New_Lines : This procedure creates a new line in the results detail   ~
-- ~ table for each Retirement Plan of an assignment. It re-computes all the rule ~
-- ~ based person level fast-formulas for the secondary assignment.               ~
-- ================================================================================
Procedure Create_New_Lines
            (p_pri_assignment_id  In per_all_assignments_f.assignment_id%TYPE
            ,p_sec_assignment_id  In per_all_assignments_f.assignment_id%TYPE
            ,p_person_id          In per_all_people_f.person_id%TYPE
            ,p_record_name        In Varchar2
             )  Is

--
-- Cursor to get all the rule based data-elements for the detail record
--
Cursor csr_rule_ele
       (c_ext_rcd_id  In ben_ext_data_elmt_in_rcd.ext_rcd_id%TYPE) Is
Select  a.ext_data_elmt_in_rcd_id
       ,a.seq_num
       ,a.sprs_cd
       ,a.strt_pos
       ,a.dlmtr_val
       ,a.rqd_flag
       ,b.ext_data_elmt_id
       ,b.data_elmt_typ_cd
       ,b.data_elmt_rl
       ,b.name
       ,hr_general.decode_lookup('BEN_EXT_FRMT_MASK', b.frmt_mask_cd) frmt_mask_cd
      , b.frmt_mask_cd frmt_mask_lookup_cd
       ,b.string_val
       ,b.dflt_val
       ,b.max_length_num
       ,b.just_cd
  from  ben_ext_data_elmt           b,
        ben_ext_data_elmt_in_rcd    a
 where  a.ext_data_elmt_id = b.ext_data_elmt_id
   and  b.data_elmt_typ_cd = 'R'
   and  a.ext_rcd_id = c_ext_rcd_id
  order by a.seq_num;

Cursor csr_ff_type ( c_formula_type_id in ff_formulas_f.formula_id%TYPE
                    ,c_effective_date     in date) Is
 Select formula_type_id
   from   ff_formulas_f
  where  formula_id = c_formula_type_id
    and  c_effective_date between effective_start_date
                              and effective_end_date;

  -- Variable Declaration
  l_rec_serial_num      NUMBER(3);
  l_itr                 NUMBER(3);
  l_next_itr            NUMBER(3);
  l_foumula_type_id     ff_formulas_f.formula_id%TYPE;
  l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
  l_organization_id     per_all_assignments_f.organization_id%TYPE;
  l_business_group_id   per_all_assignments_f.business_group_id%TYPE;
  l_ff_value            ben_ext_rslt_dtl.val_01%TYPE;
  l_ff_value_fmt        ben_ext_rslt_dtl.val_01%TYPE;
  l_effective_date      date;
  l_outputs             ff_exec.outputs_t;
  -- Rowtype Variable Declaration
  l_main_rec            csr_rslt_dtl%ROWTYPE;
  l_new_rec             csr_rslt_dtl%ROWTYPE;
  l_prev_new_rec        csr_rslt_dtl%ROWTYPE;
  l_balance_amount     Number;

  l_proc_name           Varchar2(150):= g_proc_name||'Create_New_Lines';
  l_return_value        Number;
  l_ret_value_char      varchar2(150);
  l_error_value         varchar2(500);
Begin -- Create_New_Lines
  -- Get the main detail record
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  hr_utility.set_location('.....Get the no-hidden record id for the extract..',10);
  Open csr_ext_rcd_id(c_hide_flag	=> 'N'    -- N=No record is not hidden one
  		             ,c_rcd_type_cd	=> 'D' ); -- D=Detail, T=Total, H-Header Record types

  Fetch csr_ext_rcd_id INTO g_ext_dtl_rcd_id;
  Close csr_ext_rcd_id;
  --
  hr_utility.set_location('.....Get the results record for person id :'||p_person_id,15);
  Open csr_rslt_dtl
              (c_person_id      => p_person_id
              ,c_ext_rslt_id    => ben_ext_thread.g_ext_rslt_id
              ,c_ext_dtl_rcd_id => g_ext_dtl_rcd_id
              );
  Fetch csr_rslt_dtl INTO l_main_rec;
  Close csr_rslt_dtl;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Increment the object version number of the record   ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  hr_utility.set_location('.....Increment the object version of the main record...',20);
  l_main_rec.object_version_number := nvl(l_main_rec.object_version_number,0) + 1;
  l_new_rec := l_main_rec;
  If g_all_sec_asgs.EXISTS(p_sec_assignment_id) Or
     g_primary_asg.EXISTS(p_sec_assignment_id) Then
     If g_primary_asg.EXISTS(p_sec_assignment_id) Then
       l_assignment_id     := p_sec_assignment_id;
       l_organization_id   := g_primary_asg(l_assignment_id).organization_id;
       l_business_group_id := g_primary_asg(l_assignment_id).business_group_id;
       l_effective_date := Least(g_effective_date, g_primary_asg(l_assignment_id).effective_end_date);
     ElsIf g_all_sec_asgs.EXISTS(p_sec_assignment_id) Then
       l_assignment_id     := p_sec_assignment_id;
       l_organization_id   := g_all_sec_asgs(l_assignment_id).organization_id;
       l_business_group_id := g_all_sec_asgs(l_assignment_id).business_group_id;
       l_effective_date := Least(g_effective_date, g_all_sec_asgs(l_assignment_id).effective_end_date);
     End If;

     hr_utility.set_location('.....l_assignment_id     :'||l_assignment_id,25);
     hr_utility.set_location('.....l_organization_id   :'||l_organization_id,30);
     hr_utility.set_location('.....l_business_group_id :'||l_business_group_id,35);
     hr_utility.set_location('.....l_effective_date    :'||l_effective_date,40);

     For i in  csr_rule_ele( c_ext_rcd_id => g_ext_dtl_rcd_id)
     Loop
           Open  csr_ff_type(c_formula_type_id => i.data_elmt_rl
                            ,c_effective_date  => l_effective_date);
          Fetch csr_ff_type  Into l_foumula_type_id;
          Close csr_ff_type;
          If l_foumula_type_id = -413 Then -- person level rule
             l_outputs := benutils.formula
                         (p_formula_id         => i.data_elmt_rl
                         ,p_effective_date     => l_effective_date
                         ,p_assignment_id      => l_assignment_id
                         ,p_organization_id    => l_organization_id
                         ,p_business_group_id  => l_business_group_id
                         ,p_jurisdiction_code  => Null
                         ,p_param1             => 'EXT_DFN_ID'
                         ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                         ,p_param2             => 'EXT_RSLT_ID'
                         ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                         );
              l_ff_value := l_outputs(l_outputs.first).value;
              Begin
                hr_utility.set_location('.....Applying the format mask',45);
                If i.frmt_mask_lookup_cd Is Not Null And
                   l_ff_value Is Not Null Then
                   If substr(i.frmt_mask_lookup_cd,1,1) = 'N' then
                     hr_utility.set_location('.....Applying number format mask :ben_ext_fmt.apply_format_mask',50);
                     l_ff_value_fmt := ben_ext_fmt.apply_format_mask(to_number(l_ff_value), i.frmt_mask_cd);
                     l_ff_value     := l_ff_value_fmt;
                  Elsif substr(i.frmt_mask_lookup_cd,1,1) = 'D' then
                     hr_utility.set_location('.....Applying Date format mask :ben_ext_fmt.apply_format_mask',55);
                     l_ff_value_fmt := ben_ext_fmt.apply_format_mask(FND_DATE.canonical_to_date(l_ff_value), i.frmt_mask_cd);
                     l_ff_value     := l_ff_value_fmt;
                  End If;
                End  If;
              Exception  -- incase l_ff_value is not valid for formatting, just don't format it.
                  when others then
                  l_error_value := sqlerrm;
              End;
              hr_utility.set_location('.....Before Calling procedure Update_Record_Values',60);
              Update_Record_Values ( p_ext_rcd_id            => g_ext_dtl_rcd_id
                                    ,p_ext_data_element_name => Null
                                    ,p_data_element_value    => l_ff_value
                                    ,p_data_ele_seqnum       => i.seq_num
                                    ,p_ext_dtl_rec           => l_new_rec);
           End If;
       End Loop; --For i in  csr_rule_ele
  End If;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Assignment Type Primary, Secondary etc. ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  hr_utility.set_location('.....Set the Assignment Type :'||p_sec_assignment_id, 95);
  Update_Record_Values ( p_ext_rcd_id            => g_ext_dtl_rcd_id
                        ,p_ext_data_element_name => 'Pay US SRS - Detail Assignment Type'
                        ,p_data_element_value    => p_record_name
                        ,p_ext_dtl_rec           => l_new_rec);

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Insert another record into the results detail table
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  hr_utility.set_location('.....Calling Ins_Rslt_Dtl to create a record...',100);
  Ins_Rslt_Dtl(p_dtl_rec => l_new_rec  );
  hr_utility.set_location('Leaving :'||l_proc_name,150);
Exception
 When Others Then
  l_error_value := sqlerrm;
  hr_utility.set_location('......Exception Others raised',145);
  hr_utility.set_location('......SQL-ERRM :'||l_error_value,146);
  hr_utility.set_location('Leaving :'||l_proc_name,150);

  Raise;
End Create_New_Lines;

-- ================================================================================
-- ~ Update_Record_Values :
-- ================================================================================
Procedure Update_Record_Values ( p_ext_rcd_id            In ben_ext_rcd.ext_rcd_id%TYPE
                                ,p_ext_data_element_name In ben_ext_data_elmt.name%TYPE
                                ,p_data_element_value    In ben_ext_rslt_dtl.val_01%TYPE
                                ,p_data_ele_seqnum       In Number
                                ,p_ext_dtl_rec           In out nocopy ben_ext_rslt_dtl%ROWTYPE
                                ) Is
Cursor csr_seqnum ( c_ext_rcd_id            In ben_ext_rcd.ext_rcd_id%TYPE
                   ,c_ext_data_element_name In ben_ext_data_elmt.name%TYPE
                   ) Is
select  der.ext_data_elmt_id,
        der.seq_num,
        ede.name
  from  ben_ext_data_elmt_in_rcd der
       ,ben_ext_data_elmt        ede
 where der.ext_rcd_id = c_ext_rcd_id
   and ede.ext_data_elmt_id = der.ext_data_elmt_id
   and ede.name             like '%'|| c_ext_data_element_name
 order by seq_num;

l_seqnum_rec csr_seqnum%ROWTYPE;
l_proc_name          varchar2(150):= g_proc_name||'Update_Record_Values';
-- nocopy changes
l_ext_dtl_rec_nc     ben_ext_rslt_dtl%ROWTYPE;
Begin

 hr_utility.set_location('Entering :'||l_proc_name, 5);
 -- nocopy changes
 l_ext_dtl_rec_nc := p_ext_dtl_rec;

 If p_data_ele_seqnum Is Null Then
    Open csr_seqnum ( c_ext_rcd_id            => p_ext_rcd_id
                     ,c_ext_data_element_name => p_ext_data_element_name);
    Fetch csr_seqnum Into l_seqnum_rec;
    If csr_seqnum%NOTFOUND Then
       hr_utility.set_location('.....Data element :'||p_ext_data_element_name||' not found..',10);
       Close csr_seqnum;
    Else
       hr_utility.set_location('.....Data element :'||p_ext_data_element_name||' found..',10);
       Close csr_seqnum;
    End If;
 Else
    l_seqnum_rec.seq_num := p_data_ele_seqnum;
 End If;

 hr_utility.set_location('.....Seq. Num :'||l_seqnum_rec.seq_num,15);

 If l_seqnum_rec.seq_num = 1 Then
    p_ext_dtl_rec.val_01 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 2 Then
    p_ext_dtl_rec.val_02 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 3 Then
    p_ext_dtl_rec.val_03 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 4 Then
    p_ext_dtl_rec.val_04 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 5 Then
    p_ext_dtl_rec.val_05 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 6 Then
    p_ext_dtl_rec.val_06 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 7 Then
    p_ext_dtl_rec.val_07 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 8 Then
    p_ext_dtl_rec.val_08 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 9 Then
    p_ext_dtl_rec.val_09 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 10 Then
    p_ext_dtl_rec.val_10 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 11 Then
    p_ext_dtl_rec.val_11 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 12 Then
    p_ext_dtl_rec.val_12 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 13 Then
    p_ext_dtl_rec.val_13 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 14 Then
    p_ext_dtl_rec.val_14 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 15 Then
    p_ext_dtl_rec.val_15 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 16 Then
    p_ext_dtl_rec.val_16 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 17 Then
    p_ext_dtl_rec.val_17 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 18 Then
    p_ext_dtl_rec.val_18 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 19 Then
    p_ext_dtl_rec.val_19 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 20 Then
    p_ext_dtl_rec.val_20 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 21 Then
    p_ext_dtl_rec.val_21 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 22 Then
    p_ext_dtl_rec.val_22 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 23Then
    p_ext_dtl_rec.val_23 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 24 Then
    p_ext_dtl_rec.val_24 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 25 Then
    p_ext_dtl_rec.val_25 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 26 Then
    p_ext_dtl_rec.val_26 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 27 Then
    p_ext_dtl_rec.val_27 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 28 Then
    p_ext_dtl_rec.val_28 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 29 Then
    p_ext_dtl_rec.val_29 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 30 Then
    p_ext_dtl_rec.val_30 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 31 Then
    p_ext_dtl_rec.val_31 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 32 Then
    p_ext_dtl_rec.val_32 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 33 Then
    p_ext_dtl_rec.val_33 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 34 Then
    p_ext_dtl_rec.val_34 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 35 Then
    p_ext_dtl_rec.val_35 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 36 Then
    p_ext_dtl_rec.val_36 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 37 Then
    p_ext_dtl_rec.val_37 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 38 Then
    p_ext_dtl_rec.val_38 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 39 Then
    p_ext_dtl_rec.val_39 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 40 Then
    p_ext_dtl_rec.val_40 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 41 Then
    p_ext_dtl_rec.val_41 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 42 Then
    p_ext_dtl_rec.val_42 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 43 Then
    p_ext_dtl_rec.val_43 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 44 Then
    p_ext_dtl_rec.val_44 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 45 Then
    p_ext_dtl_rec.val_45 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 46 Then
    p_ext_dtl_rec.val_46 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 47 Then
    p_ext_dtl_rec.val_47 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 48 Then
    p_ext_dtl_rec.val_48 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 49 Then
    p_ext_dtl_rec.val_49 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 50 Then
    p_ext_dtl_rec.val_50 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 51 Then
    p_ext_dtl_rec.val_51 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 52 Then
    p_ext_dtl_rec.val_52 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 53 Then
    p_ext_dtl_rec.val_53 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 54 Then
    p_ext_dtl_rec.val_54 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 55 Then
    p_ext_dtl_rec.val_55 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 56 Then
    p_ext_dtl_rec.val_56 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 57 Then
    p_ext_dtl_rec.val_57 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 58 Then
    p_ext_dtl_rec.val_58 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 58 Then
    p_ext_dtl_rec.val_58 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 59 Then
    p_ext_dtl_rec.val_59 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 60 Then
    p_ext_dtl_rec.val_60 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 61 Then
    p_ext_dtl_rec.val_61 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 62 Then
    p_ext_dtl_rec.val_62 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 63 Then
    p_ext_dtl_rec.val_63 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 64 Then
    p_ext_dtl_rec.val_64 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 65 Then
    p_ext_dtl_rec.val_65 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 66 Then
    p_ext_dtl_rec.val_66 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 67 Then
    p_ext_dtl_rec.val_67 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 68 Then
    p_ext_dtl_rec.val_68 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 69 Then
    p_ext_dtl_rec.val_69 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 70 Then
    p_ext_dtl_rec.val_70 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 71 Then
    p_ext_dtl_rec.val_71 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 72 Then
    p_ext_dtl_rec.val_72 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 73 Then
    p_ext_dtl_rec.val_73 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 74 Then
    p_ext_dtl_rec.val_74 := p_data_element_value;
 Elsif l_seqnum_rec.seq_num = 75 Then
    p_ext_dtl_rec.val_75 := p_data_element_value;
 End If;
 hr_utility.set_location('Leaving :'||l_proc_name, 25);
 Return;
Exception
  When Others Then
    hr_utility.set_location('.....Exception when others '||l_proc_name,30);
 -- nocopy changes
    p_ext_dtl_rec := l_ext_dtl_rec_nc;
    raise;

End Update_Record_Values;

-- ================================================================================
-- ~ Ins_Rslt_Dtl : Inserts a record into the results detail record.
-- ================================================================================
Procedure Ins_Rslt_Dtl(p_dtl_rec IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE) Is

l_proc_name   Varchar2(150) := g_proc_name||'Ins_Rslt_Dtl';
l_dtl_rec_nc  ben_ext_rslt_dtl%ROWTYPE;

BEGIN -- ins_rslt_dtl
  hr_utility.set_location('Entering :'||l_proc_name, 5);

  -- nocopy changes
  l_dtl_rec_nc := p_dtl_rec;

  hr_utility.set_location('.....Fetching seq. ben_ext_rslt_dtl_s.NEXTVAL' , 10);

  -- Get the next sequence number to insert a record into the table
  SELECT ben_ext_rslt_dtl_s.NEXTVAL INTO p_dtl_rec.ext_rslt_dtl_id FROM dual;

  hr_utility.set_location('.....Inserting into ben_ext_rslt_dtl table...' , 15);

  INSERT INTO ben_ext_rslt_dtl
  (EXT_RSLT_DTL_ID
  ,EXT_RSLT_ID
  ,BUSINESS_GROUP_ID
  ,EXT_RCD_ID
  ,PERSON_ID
  ,VAL_01
  ,VAL_02
  ,VAL_03
  ,VAL_04
  ,VAL_05
  ,VAL_06
  ,VAL_07
  ,VAL_08
  ,VAL_09
  ,VAL_10
  ,VAL_11
  ,VAL_12
  ,VAL_13
  ,VAL_14
  ,VAL_15
  ,VAL_16
  ,VAL_17
  ,VAL_19
  ,VAL_18
  ,VAL_20
  ,VAL_21
  ,VAL_22
  ,VAL_23
  ,VAL_24
  ,VAL_25
  ,VAL_26
  ,VAL_27
  ,VAL_28
  ,VAL_29
  ,VAL_30
  ,VAL_31
  ,VAL_32
  ,VAL_33
  ,VAL_34
  ,VAL_35
  ,VAL_36
  ,VAL_37
  ,VAL_38
  ,VAL_39
  ,VAL_40
  ,VAL_41
  ,VAL_42
  ,VAL_43
  ,VAL_44
  ,VAL_45
  ,VAL_46
  ,VAL_47
  ,VAL_48
  ,VAL_49
  ,VAL_50
  ,VAL_51
  ,VAL_52
  ,VAL_53
  ,VAL_54
  ,VAL_55
  ,VAL_56
  ,VAL_57
  ,VAL_58
  ,VAL_59
  ,VAL_60
  ,VAL_61
  ,VAL_62
  ,VAL_63
  ,VAL_64
  ,VAL_65
  ,VAL_66
  ,VAL_67
  ,VAL_68
  ,VAL_69
  ,VAL_70
  ,VAL_71
  ,VAL_72
  ,VAL_73
  ,VAL_74
  ,VAL_75
  ,CREATED_BY
  ,CREATION_DATE
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,PROGRAM_APPLICATION_ID
  ,PROGRAM_ID
  ,PROGRAM_UPDATE_DATE
  ,REQUEST_ID
  ,OBJECT_VERSION_NUMBER
  ,PRMY_SORT_VAL
  ,SCND_SORT_VAL
  ,THRD_SORT_VAL
  ,TRANS_SEQ_NUM
  ,RCRD_SEQ_NUM
  )
  VALUES
  (p_dtl_rec.EXT_RSLT_DTL_ID
  ,p_dtl_rec.EXT_RSLT_ID
  ,p_dtl_rec.BUSINESS_GROUP_ID
  ,p_dtl_rec.EXT_RCD_ID
  ,p_dtl_rec.PERSON_ID
  ,p_dtl_rec.VAL_01
  ,p_dtl_rec.VAL_02
  ,p_dtl_rec.VAL_03
  ,p_dtl_rec.VAL_04
  ,p_dtl_rec.VAL_05
  ,p_dtl_rec.VAL_06
  ,p_dtl_rec.VAL_07
  ,p_dtl_rec.VAL_08
  ,p_dtl_rec.VAL_09
  ,p_dtl_rec.VAL_10
  ,p_dtl_rec.VAL_11
  ,p_dtl_rec.VAL_12
  ,p_dtl_rec.VAL_13
  ,p_dtl_rec.VAL_14
  ,p_dtl_rec.VAL_15
  ,p_dtl_rec.VAL_16
  ,p_dtl_rec.VAL_17
  ,p_dtl_rec.VAL_19
  ,p_dtl_rec.VAL_18
  ,p_dtl_rec.VAL_20
  ,p_dtl_rec.VAL_21
  ,p_dtl_rec.VAL_22
  ,p_dtl_rec.VAL_23
  ,p_dtl_rec.VAL_24
  ,p_dtl_rec.VAL_25
  ,p_dtl_rec.VAL_26
  ,p_dtl_rec.VAL_27
  ,p_dtl_rec.VAL_28
  ,p_dtl_rec.VAL_29
  ,p_dtl_rec.VAL_30
  ,p_dtl_rec.VAL_31
  ,p_dtl_rec.VAL_32
  ,p_dtl_rec.VAL_33
  ,p_dtl_rec.VAL_34
  ,p_dtl_rec.VAL_35
  ,p_dtl_rec.VAL_36
  ,p_dtl_rec.VAL_37
  ,p_dtl_rec.VAL_38
  ,p_dtl_rec.VAL_39
  ,p_dtl_rec.VAL_40
  ,p_dtl_rec.VAL_41
  ,p_dtl_rec.VAL_42
  ,p_dtl_rec.VAL_43
  ,p_dtl_rec.VAL_44
  ,p_dtl_rec.VAL_45
  ,p_dtl_rec.VAL_46
  ,p_dtl_rec.VAL_47
  ,p_dtl_rec.VAL_48
  ,p_dtl_rec.VAL_49
  ,p_dtl_rec.VAL_50
  ,p_dtl_rec.VAL_51
  ,p_dtl_rec.VAL_52
  ,p_dtl_rec.VAL_53
  ,p_dtl_rec.VAL_54
  ,p_dtl_rec.VAL_55
  ,p_dtl_rec.VAL_56
  ,p_dtl_rec.VAL_57
  ,p_dtl_rec.VAL_58
  ,p_dtl_rec.VAL_59
  ,p_dtl_rec.VAL_60
  ,p_dtl_rec.VAL_61
  ,p_dtl_rec.VAL_62
  ,p_dtl_rec.VAL_63
  ,p_dtl_rec.VAL_64
  ,p_dtl_rec.VAL_65
  ,p_dtl_rec.VAL_66
  ,p_dtl_rec.VAL_67
  ,p_dtl_rec.VAL_68
  ,p_dtl_rec.VAL_69
  ,p_dtl_rec.VAL_70
  ,p_dtl_rec.VAL_71
  ,p_dtl_rec.VAL_72
  ,p_dtl_rec.VAL_73
  ,p_dtl_rec.VAL_74
  ,p_dtl_rec.VAL_75
  ,p_dtl_rec.CREATED_BY
  ,p_dtl_rec.CREATION_DATE
  ,p_dtl_rec.LAST_UPDATE_DATE
  ,p_dtl_rec.LAST_UPDATED_BY
  ,p_dtl_rec.LAST_UPDATE_LOGIN
  ,p_dtl_rec.PROGRAM_APPLICATION_ID
  ,p_dtl_rec.PROGRAM_ID
  ,p_dtl_rec.PROGRAM_UPDATE_DATE
  ,p_dtl_rec.REQUEST_ID
  ,p_dtl_rec.OBJECT_VERSION_NUMBER
  ,p_dtl_rec.PRMY_SORT_VAL
  ,p_dtl_rec.SCND_SORT_VAL
  ,p_dtl_rec.THRD_SORT_VAL
  ,p_dtl_rec.TRANS_SEQ_NUM
  ,p_dtl_rec.RCRD_SEQ_NUM
  );
  hr_utility.set_location('Leaving :'||l_proc_name, 25);
  Return;

Exception
  When Others Then
    hr_utility.set_location('.....Exception when others raised',20);
    hr_utility.set_location('Leaving :'||l_proc_name, 25);
    p_dtl_rec := l_dtl_rec_nc;
    Raise;
End Ins_Rslt_Dtl;

-- ================================================================================
-- ~ Upd_Rslt_Dtl : Updates the primary assignment record in results detail table
-- ================================================================================
Procedure Upd_Rslt_Dtl(p_dtl_rec IN ben_ext_rslt_dtl%ROWTYPE ) Is

l_proc_name varchar2(150):= g_proc_name||'upd_rslt_dtl';

Begin -- Upd_Rslt_Dtl
  UPDATE ben_ext_rslt_dtl
  SET VAL_01                 = p_dtl_rec.VAL_01
     ,VAL_02                 = p_dtl_rec.VAL_02
     ,VAL_03                 = p_dtl_rec.VAL_03
     ,VAL_04                 = p_dtl_rec.VAL_04
     ,VAL_05                 = p_dtl_rec.VAL_05
     ,VAL_06                 = p_dtl_rec.VAL_06
     ,VAL_07                 = p_dtl_rec.VAL_07
     ,VAL_08                 = p_dtl_rec.VAL_08
     ,VAL_09                 = p_dtl_rec.VAL_09
     ,VAL_10                 = p_dtl_rec.VAL_10
     ,VAL_11                 = p_dtl_rec.VAL_11
     ,VAL_12                 = p_dtl_rec.VAL_12
     ,VAL_13                 = p_dtl_rec.VAL_13
     ,VAL_14                 = p_dtl_rec.VAL_14
     ,VAL_15                 = p_dtl_rec.VAL_15
     ,VAL_16                 = p_dtl_rec.VAL_16
     ,VAL_17                 = p_dtl_rec.VAL_17
     ,VAL_19                 = p_dtl_rec.VAL_19
     ,VAL_18                 = p_dtl_rec.VAL_18
     ,VAL_20                 = p_dtl_rec.VAL_20
     ,VAL_21                 = p_dtl_rec.VAL_21
     ,VAL_22                 = p_dtl_rec.VAL_22
     ,VAL_23                 = p_dtl_rec.VAL_23
     ,VAL_24                 = p_dtl_rec.VAL_24
     ,VAL_25                 = p_dtl_rec.VAL_25
     ,VAL_26                 = p_dtl_rec.VAL_26
     ,VAL_27                 = p_dtl_rec.VAL_27
     ,VAL_28                 = p_dtl_rec.VAL_28
     ,VAL_29                 = p_dtl_rec.VAL_29
     ,VAL_30                 = p_dtl_rec.VAL_30
     ,VAL_31                 = p_dtl_rec.VAL_31
     ,VAL_32                 = p_dtl_rec.VAL_32
     ,VAL_33                 = p_dtl_rec.VAL_33
     ,VAL_34                 = p_dtl_rec.VAL_34
     ,VAL_35                 = p_dtl_rec.VAL_35
     ,VAL_36                 = p_dtl_rec.VAL_36
     ,VAL_37                 = p_dtl_rec.VAL_37
     ,VAL_38                 = p_dtl_rec.VAL_38
     ,VAL_39                 = p_dtl_rec.VAL_39
     ,VAL_40                 = p_dtl_rec.VAL_40
     ,VAL_41                 = p_dtl_rec.VAL_41
     ,VAL_42                 = p_dtl_rec.VAL_42
     ,VAL_43                 = p_dtl_rec.VAL_43
     ,VAL_44                 = p_dtl_rec.VAL_44
     ,VAL_45                 = p_dtl_rec.VAL_45
     ,VAL_46                 = p_dtl_rec.VAL_46
     ,VAL_47                 = p_dtl_rec.VAL_47
     ,VAL_48                 = p_dtl_rec.VAL_48
     ,VAL_49                 = p_dtl_rec.VAL_49
     ,VAL_50                 = p_dtl_rec.VAL_50
     ,VAL_51                 = p_dtl_rec.VAL_51
     ,VAL_52                 = p_dtl_rec.VAL_52
     ,VAL_53                 = p_dtl_rec.VAL_53
     ,VAL_54                 = p_dtl_rec.VAL_54
     ,VAL_55                 = p_dtl_rec.VAL_55
     ,VAL_56                 = p_dtl_rec.VAL_56
     ,VAL_57                 = p_dtl_rec.VAL_57
     ,VAL_58                 = p_dtl_rec.VAL_58
     ,VAL_59                 = p_dtl_rec.VAL_59
     ,VAL_60                 = p_dtl_rec.VAL_60
     ,VAL_61                 = p_dtl_rec.VAL_61
     ,VAL_62                 = p_dtl_rec.VAL_62
     ,VAL_63                 = p_dtl_rec.VAL_63
     ,VAL_64                 = p_dtl_rec.VAL_64
     ,VAL_65                 = p_dtl_rec.VAL_65
     ,VAL_66                 = p_dtl_rec.VAL_66
     ,VAL_67                 = p_dtl_rec.VAL_67
     ,VAL_68                 = p_dtl_rec.VAL_68
     ,VAL_69                 = p_dtl_rec.VAL_69
     ,VAL_70                 = p_dtl_rec.VAL_70
     ,VAL_71                 = p_dtl_rec.VAL_71
     ,VAL_72                 = p_dtl_rec.VAL_72
     ,VAL_73                 = p_dtl_rec.VAL_73
     ,VAL_74                 = p_dtl_rec.VAL_74
     ,VAL_75                 = p_dtl_rec.VAL_75
     ,OBJECT_VERSION_NUMBER  = p_dtl_rec.OBJECT_VERSION_NUMBER
     ,THRD_SORT_VAL          = p_dtl_rec.THRD_SORT_VAL
  WHERE ext_rslt_dtl_id = p_dtl_rec.ext_rslt_dtl_id;

  Return;

Exception
  When Others Then
     Raise;
END Upd_Rslt_Dtl;

-- ====================================================================
-- ~ Del_Service_Detail_Recs : Delete all the records created as part
-- ~ of hidden record as they are not required.
-- ====================================================================
Function Del_Service_Detail_Recs (p_business_group_id  ben_ext_rslt_dtl.business_group_id%TYPE
                                 )Return Number Is

l_ext_dtl_rcd_id	ben_ext_rcd.ext_rcd_id%TYPE;
l_ext_main_rcd_id	ben_ext_rcd.ext_rcd_id%TYPE;
l_proc_name         Varchar2(150):=  g_proc_name||'Del_Service_Detail_Recs';
l_return_value      Number := 0; --0= Sucess, -1=Error

Begin
  hr_utility.set_location('Entering :'||l_proc_name, 5);
  -- Get the record id for the Hidden Detail record
  hr_utility.set_location('.....Get the hidden record for extract running..',10);
  Open csr_ext_rcd_id(c_hide_flag	=> 'Y'    -- Y=Record is hidden one
  		             ,c_rcd_type_cd	=> 'D' ); -- D=Detail, T=Total, H-Header Record types

  Fetch csr_ext_rcd_id INTO l_ext_dtl_rcd_id;
  Close csr_ext_rcd_id;

  hr_utility.set_location('.....Deleting temp records from ben_ext_rslt_dtl...',15);

  Delete
    From ben_ext_rslt_dtl dtl
   Where dtl.ext_rslt_id  = ben_ext_thread.g_ext_rslt_id
    And dtl.ext_rcd_id    = l_ext_dtl_rcd_id
    And business_group_id = p_business_group_id
    And dtl.val_01 In ( 'SEC_ASSIGN_FOUND','SEC_ASSIGN_NOTFOUND' );
  hr_utility.set_location('Leaving :'||l_proc_name, 25);
  Return l_return_value;

Exception
   When Others Then
    hr_utility.set_location('.....Exception when others raised..', 20);
    hr_utility.set_location('Leaving :'||l_proc_name, 25);
    Return -1;
End Del_Service_Detail_Recs;


End PQP_US_SRS_Extracts; -- End Of Package Body

/
