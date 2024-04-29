--------------------------------------------------------
--  DDL for Package Body PQP_ITERATIVE_ARREARAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ITERATIVE_ARREARAGE" As
/* $Header: pqpitarr.pkb 115.4 2003/07/11 15:30:18 rpinjala noship $ */


   Cursor csr_leg_code (c_business_grp_id In Number
                        ) Is
   select pbg.legislation_code
     from per_business_groups_perf pbg
    where pbg.business_group_id = c_business_grp_id;

   Cursor csr_org_info (c_business_grp_id In Number
                       ,c_org_information_context In Varchar2) Is
   select hoi.org_information1
         ,hoi.org_information2
     from hr_organization_information  hoi
    where hoi.organization_id         = c_business_grp_id
      and hoi.org_information_context = c_org_information_context;

-- ================================================================
-- ~Get_Arrearage_Info: fetchs the Arrears allowed and Partial
-- ~allowed from the element extra information table based on the
-- ~legislation code, as this package would be common for all
-- ~legislations which want to enable Pre-Tax Iterative arrearage.
-- ================================================================
Procedure Get_Arrearage_Info
           (p_ele_type_id    In Number
           ,p_assignment_id   In Number
           ,p_business_grp_id In Number
           ,p_effective_date  In Date
           ,p_arrears_allowed Out NoCopy Varchar2
           ,p_partial_allowed Out NoCopy Varchar2
            ) Is
   l_legislation_code      per_business_groups_perf.legislation_code%TYPE;
   Cursor csr_arr_info (c_ele_type_id      In Number
                       ,c_business_grp_id  In Number
                       ,c_effective_date   In Date
                       ,c_information_type In Varchar2) Is
   select pei.eei_information1 -- Arrears Allowed
         ,pei.eei_information2 -- Partial Allowed
     from pay_element_types_f          pet,
          pay_element_type_extra_info  pei
    where pet.element_type_id    = c_ele_type_id
      and (pet.business_group_id = c_business_grp_id or
           pet.legislation_code  = l_legislation_code)
      and pei.element_type_id    = pet.element_type_id
      and pei.information_type   = c_information_type
      and trunc(c_effective_date) between pet.effective_start_date
                                      and pet.effective_end_date;

   l_ele_information_type  pay_element_type_extra_info.information_type%TYPE;
   l_org_information_type  hr_organization_information.org_information_context%TYPE;
   l_arr_info_rec          csr_arr_info%ROWTYPE;
   l_org_info_rec          csr_org_info%ROWTYPE;
   l_calc_method           hr_organization_information.org_information1%TYPE;
   l_to_with_amt           number;
   l_process_name          Varchar2(150) := g_pkg_name||'Get_Arrearage_Info';
Begin
   hr_utility.set_location('Entering: '||l_process_name, 5);
   If g_legislation_code Is Null Then
      Open csr_leg_code (c_business_grp_id => p_business_grp_id);
      Fetch csr_leg_code Into l_legislation_code;
      g_legislation_code := l_legislation_code;
      If csr_leg_code%NOTFOUND Then
         hr_utility.set_location('Could not find the Leg Code :',10);
         Null;
      End If;
      Close csr_leg_code;
   End If;
      hr_utility.set_location('Leg. Code :'||l_legislation_code,10);
   If g_legislation_code = 'GB' Then
      l_ele_information_type := 'PQP_GB_ARREARAGE_INFO';
      l_org_information_type := 'PQP_GB_ITERATIVE_RULES';
   Elsif g_legislation_code = 'NL' Then
      l_ele_information_type := 'PQP_NL_ARREARAGE_INFO';
      l_org_information_type := 'PQP_NL_ITERATIVE_RULES';
   End If;
   hr_utility.set_location('Information Type  :'||l_ele_information_type,15);
   If l_ele_information_type = 'PQP_GB_ARREARAGE_INFO' Then
      Open csr_arr_info (c_ele_type_id      => p_ele_type_id
                        ,c_business_grp_id  => p_business_grp_id
                        ,c_effective_date   => p_effective_date
                        ,c_information_type => l_ele_information_type);
      Fetch csr_arr_info Into l_arr_info_rec;
      If csr_arr_info%FOUND Then
         hr_utility.set_location('Found Arrearage Info  :',20);
         p_arrears_allowed := l_arr_info_rec.eei_information1;
         p_partial_allowed := l_arr_info_rec.eei_information2;
      Else
         hr_utility.set_location('Defaulting Arrearage Info  :',20);
         p_arrears_allowed := 'N';
         p_partial_allowed := 'N';
      End If;
      Close csr_arr_info;
   ElsIf l_ele_information_type = 'PQP_NL_ARREARAGE_INFO' Then
      Null;
   End If;
   If l_org_information_type = 'PQP_GB_ITERATIVE_RULES' Then
      Open csr_org_info (c_business_grp_id        =>  p_business_grp_id
                        ,c_org_information_context => l_org_information_type );
      Fetch csr_org_info Into l_org_info_rec;
      If csr_org_info%FOUND Then
         l_calc_method := nvl(l_org_info_rec.org_information1,'INTERPOLATION');
         l_to_with_amt := nvl(l_org_info_rec.org_information2,1);
      Else
         l_calc_method := 'INTERPOLATION';
         l_to_with_amt := 1;
      End If;
      g_Itr_Method(p_business_grp_id).iterative_method := UPPER(l_calc_method);
      g_Itr_Method(p_business_grp_id).adjust_to_within := l_to_with_amt;
      Close csr_org_info;
   ElsIf l_org_information_type = 'PQP_NL_ITERATIVE_RULES' Then
      Null;
   End If;

   hr_utility.set_location('Leaving :    '||l_process_name,90);
Exception
   When Others Then
    hr_utility.set_location('Error Code: '||SQLCODE,130);
    hr_utility.set_location('Error Msg : '||SQLERRM,140);
    hr_utility.set_location('Leaving   : '||l_process_name,150);
End Get_Arrearage_Info;

-- ============================================================
-- ~Get_Arrearage_Options: Returns the Arrears Allowed and
-- ~ Partial allowed for any element for the EIT context
-- ~ Arrearage Options : PQP_GB_ARREARAGE_OPTIONS
-- ============================================================
Function Get_Arrearage_Options
           (p_ele_type_id     In Number
           ,p_assignment_id   In Number
           ,p_business_grp_id In Number
           ,p_effective_date  In Date
           ,p_arrears_allowed Out NoCopy Varchar2
           ,p_partial_allowed Out NoCopy Varchar2
           ,p_error_message   Out NoCopy Varchar2
           ) Return Number Is
   l_process_name          Varchar2(150) := g_pkg_name||'Get_Arrearage_Options';
   l_return_value          number := 0;
Begin
   hr_utility.set_location('Entering: '||l_process_name, 5);
   Get_Arrearage_Info
           (p_ele_type_id     => p_ele_type_id
           ,p_assignment_id   => p_assignment_id
           ,p_business_grp_id => p_business_grp_id
           ,p_effective_date  => p_effective_date
           ,p_arrears_allowed => p_arrears_allowed
           ,p_partial_allowed => p_partial_allowed
            );
    hr_utility.set_location('Leaving   : '||l_process_name,90);
   Return l_return_value;

Exception
   When Others Then
    hr_utility.set_location('Error Code: '||SQLCODE,130);
    hr_utility.set_location('Error Msg : '||SQLERRM,140);
    p_error_message := 'Exception: When Others at :'||l_process_name;
    hr_utility.set_location('Leaving   : '||l_process_name,150);
    l_return_value := -1;
    Raise;
End Get_Arrearage_Options;
-- ============================================================
-- ~Arrearage: Takes into consideration the arrears amount
-- ~based on the arrears allowed and partial allowed flag.
-- ~This would be called directly for Vol. Deductions.
-- ============================================================
Function Arrearage
         (p_eletype_id	         In Number -- Context Parameter
         ,p_ele_entryid          In Number -- Context Parameter
         ,p_assignment_id        In Number -- Context Parameter
         ,p_business_grp_id      In Number -- Context Parameter
         ,p_assignment_action_Id In Number -- Context Parameter
	     ,p_date_earned	         In Date   -- Context Parameter
	     ,p_net_asg_run	         In Number
	     ,p_maxarrears 	         In Number
	     ,p_dedn_amt	         In Number
	     ,p_to_arrears	         In Out NoCopy Number
	     ,p_not_taken	         In Out NoCopy Number
         ,p_arrears_taken        In Out NoCopy Number
         ,p_remaining_amount     In Number   -- Optional Parameter
         ,p_guaranteed_net       In Number   -- Optional Parameter
	     ,p_partial_allowed      In Varchar2 -- Optional Parameter
         ,p_arrears_allowed      In Varchar2 -- Optional Parameter
         ) Return Number Is

   l_dedn_amt             Number;
   l_total_dedn           Number;
   l_maxarrears_tobetaken Number;
   l_arrears_allowed      Varchar2(2);
   l_partial_allowed      Varchar2(2);
   l_process_name         Varchar2(150) := g_pkg_name||'Arrearage';
Begin
   hr_utility.set_location('Entering: '||l_process_name, 5);
   p_to_arrears := 0;
   p_not_taken  := 0;
   If p_partial_allowed Is Null And
      p_arrears_allowed Is Null Then
      If g_Element_Arr_Values.EXISTS(p_eletype_id) Then
         l_arrears_allowed := g_Element_Arr_Values(p_eletype_id).arrears_allowed;
         l_partial_allowed := g_Element_Arr_Values(p_eletype_id).partial_allowed;
      Else
         Get_Arrearage_Info
           (p_ele_type_id     => p_eletype_id
           ,p_assignment_id   => p_assignment_id
           ,p_business_grp_id => p_business_grp_id
           ,p_effective_date  => p_date_earned
           ,p_arrears_allowed => l_arrears_allowed
           ,p_partial_allowed => l_partial_allowed
           );
         g_Element_Arr_Values(p_eletype_id).arrears_allowed := l_arrears_allowed;
         g_Element_Arr_Values(p_eletype_id).partial_allowed := l_partial_allowed;
      End If;
   Else
     g_Element_Arr_Values(p_eletype_id).arrears_allowed := p_arrears_allowed;
     g_Element_Arr_Values(p_eletype_id).partial_allowed := p_partial_allowed;
     l_arrears_allowed := p_arrears_allowed;
     l_partial_allowed := p_partial_allowed;
   End If;
   hr_utility.set_location('..l_arrears_allowed: '||l_arrears_allowed, 6);
   hr_utility.set_location('..l_partial_allowed: '||l_partial_allowed, 7);
   hr_utility.set_location('..p_dedn_amt: '||p_dedn_amt, 8);
   hr_utility.set_location('..p_guaranteed_net: '||p_guaranteed_net, 9);
   If l_arrears_allowed = 'N' Then
      -- Arrears are not allowed
      hr_utility.set_location('Arrearage not allowed',10);
      If p_net_asg_run - p_dedn_amt >= p_guaranteed_net Then
            -- There are enough earnings to take the entire deduction amount.
            hr_utility.set_location('Enough earnings to take the entire ded. amount', 15);
            p_to_arrears := 0;
            p_not_taken  := 0;
            l_dedn_amt   := p_dedn_amt;

      ElsIf p_net_asg_run <= p_guaranteed_net Then
            -- Not enough earnings to take the deduction and as arrears are not
            -- allowed the entire deduction amount goes as not taken.
            hr_utility.set_location('Not enough earnings, so ded. amt goes as not taken amt',20);
            p_to_arrears := 0;
            p_not_taken  := p_dedn_amt;
            l_dedn_amt   := 0;

      ElsIf p_net_asg_run - p_dedn_amt < p_guaranteed_net and
            l_partial_allowed = 'Y' Then
            -- If partial deduction amount can be taken and partial deductions are
            -- allowed for the element then take partial amount and the rest goes
            -- as not taken amount.
            hr_utility.set_location('Partial allowed and part of the ded. amt can be taken',25);
            p_to_arrears := 0;
            p_not_taken  := p_dedn_amt - (p_net_asg_run - p_guaranteed_net);
            l_dedn_amt   := p_net_asg_run - p_guaranteed_net;

      ElsIf p_net_asg_run - p_dedn_amt < p_guaranteed_net and
            l_partial_allowed = 'N' Then
            -- Even if partial deduction amount can be taken but partial deduction
            -- is NOT allowed then the entire amount is considered as not_taken.
            hr_utility.set_location('Partial NOT allowed so entire ded. amt goes as not taken amt',30);
            p_to_arrears := 0;
            p_not_taken  := p_dedn_amt;
            l_dedn_amt   := 0;
      End If;
   Else -- Arrearage is on, try and clear any balance currently in arrears.
        hr_utility.set_location('Arrearage Allowed',35);
      If p_net_asg_run <= p_guaranteed_net Then
         -- Earnings are not enough to take the deduction amount, hence put the
         -- entire amount into arrears as well as not_taken.
         hr_utility.set_location('Earnings not enough, so ded. amt goes into arrears',40);
            p_to_arrears := p_dedn_amt;
            p_not_taken  := p_dedn_amt;
            l_dedn_amt   := 0;
      Else
         -- take into consideration the arrears amount.
         hr_utility.set_location('Take the arrears amount if present',45);
         If p_remaining_amount = p_maxarrears Then
            p_arrears_taken := p_maxarrears;
            l_total_dedn    := p_dedn_amt + p_arrears_taken;
         Else
            p_arrears_taken := Least(p_remaining_amount, p_maxarrears);
            l_total_dedn    := p_dedn_amt + p_arrears_taken;
         End If;
         If p_net_asg_run - p_guaranteed_net >= l_total_dedn Then
            -- Enough earnings to the arrears along with the deduction amount
            hr_utility.set_location('Earnings enough to take the ded + Arr Amt',50);
            p_to_arrears := -1 * p_arrears_taken;
            l_dedn_amt   := l_total_dedn;
            p_not_taken  := 0;
         ElsIf l_partial_allowed = 'Y' Then
            -- Earnings are not enough to taken the deduction amount so try taking
            -- partial dedn. amount as partial is allowed for the element.
               p_to_arrears := (l_total_dedn - (p_net_asg_run - p_guaranteed_net)) +
                               (-1 * p_arrears_taken);
               p_arrears_taken := abs(p_to_arrears);
               If (p_net_asg_run - p_guaranteed_net) >= p_dedn_amt Then
                   hr_utility.set_location('Enough earnings to take the entire ded amt',55);
                   p_not_taken := 0;
               Else
                   p_not_taken := p_dedn_amt - (p_net_asg_run - p_guaranteed_net);
                   hr_utility.set_location('Earnings NOT enough and taking partial amt',60);
               End If;
               l_dedn_amt := p_net_asg_run - p_guaranteed_net;

         ElsIf l_partial_allowed = 'N' Then
               hr_utility.set_location('Partial NOT allowed',65);
               If (p_net_asg_run - p_guaranteed_net) >= p_dedn_amt Then
                   hr_utility.set_location('Enough earnings to take the entire ded. amt',70);
                   l_dedn_amt   := p_dedn_amt;
                   p_to_arrears := 0;
                   p_not_taken  := 0;
               Else
                   hr_utility.set_location('Earnings NOT enough, ded.amt goes into arrears',75);
                   p_to_arrears := p_dedn_amt;
                   p_not_taken  := p_dedn_amt;
                   l_dedn_amt   := 0;
               End If;
         End If;
      End If;
   End If;
   hr_utility.set_location('To Arrears  ='||p_to_arrears,40);
   hr_utility.set_location('Not Taken   ='||p_not_taken,45);
   hr_utility.set_location('Ded. Amount ='||l_dedn_amt,50);
   hr_utility.set_location('Leaving :    '||l_process_name,150);
   Return l_dedn_amt;

Exception
    When Others Then
    l_dedn_amt := 0;
    hr_utility.set_location('Error Code :'||SQLCODE,150);
    hr_utility.set_location('Error Msg  :'||SQLERRM,160);
    hr_utility.set_location('Leaving    :'||l_process_name, 170);
    Raise;

END Arrearage;

-- ============================================================
-- ~Iterative_Arrearage: This would be called directly for
-- ~Pre-Tax Deductions only.
-- ============================================================
FUNCTION Iterative_Arrearage
          (p_eletype_id           In Number -- Context Parameter
          ,p_ele_entryid          In Number -- Context Parameter
          ,p_assignment_id        In Number -- Context Parameter
          ,p_business_grp_id      In Number -- Context Parameter
          ,p_assignment_action_Id In Number -- Context Parameter
          ,p_date_earned          In Date   -- Context Parameter
          ,p_net_asg_run          In Number
          ,p_maxarrears           In Number
          ,p_dedn_amt             In Number
          ,p_maxdesired_amt       In Number
          ,p_iter_count           In Number
          ,p_inserted_flag        In Varchar2
          ,p_to_arrears           In Out NoCopy Number
          ,p_not_taken            In Out NoCopy Number
          ,p_arrears_taken        In Out NoCopy Number
          ,p_error_message        Out NoCopy Varchar2
          ,p_warning_message      Out NoCopy Varchar2
          ,p_remaining_amount     In Number   -- Optional Parameter
          ,p_guaranteed_net       In Number   -- Optional Parameter
          ,p_partial_allowed      In Varchar2 -- Optional Parameter
          ,p_arrears_allowed      In Varchar2 -- Optional Parameter
          ) Return Number Is

  l_dedn_amt             Number := 0;
  l_actual_usercalc_amt  Number := 0;
  l_arrears_allowed      Varchar2(2);
  l_partial_allowed      Varchar2(2);
  l_process_name         Varchar2(150) := g_pkg_name||'Iterative_Arrearage';

Begin
     hr_utility.set_location('Entering: '||l_process_name, 5);
     If Trim(p_partial_allowed) Is Null And
        Trim(p_arrears_allowed) Is Null Then
      If g_Element_Arr_Values.EXISTS(p_eletype_id) Then
         l_arrears_allowed := g_Element_Arr_Values(p_eletype_id).arrears_allowed;
         l_partial_allowed := g_Element_Arr_Values(p_eletype_id).partial_allowed;
      Else
        Get_Arrearage_Info
          (p_ele_type_id     => p_eletype_id
          ,p_assignment_id   => p_assignment_id
          ,p_business_grp_id => p_business_grp_id
          ,p_effective_date  => p_date_earned
          ,p_arrears_allowed => l_arrears_allowed
          ,p_partial_allowed => l_partial_allowed
          );
          g_Element_Arr_Values(p_eletype_id).arrears_allowed := l_arrears_allowed;
          g_Element_Arr_Values(p_eletype_id).partial_allowed := l_partial_allowed;
      End If;
     Else
        g_Element_Arr_Values(p_eletype_id).arrears_allowed := p_arrears_allowed;
        g_Element_Arr_Values(p_eletype_id).partial_allowed := p_partial_allowed;
        l_arrears_allowed := p_arrears_allowed;
        l_partial_allowed := p_partial_allowed;
     End If;
     hr_utility.set_location('..l_arrears_allowed: '||l_arrears_allowed, 6);
     hr_utility.set_location('..l_partial_allowed: '||l_partial_allowed, 7);

     If p_iter_count <= 1  Then
        If g_Element_Values.EXISTS(p_ele_entryid) Then
           l_actual_usercalc_amt := g_Element_Values(p_ele_entryid).actual_usercalc_amt;
        End If;
        If p_inserted_flag ='N' Then
           l_actual_usercalc_amt := p_dedn_amt;
        Else
           l_actual_usercalc_amt := NVL(l_actual_usercalc_amt,0);
        End If;
        hr_utility.set_location('Deduction formula call the first time', 10);
        hr_utility.set_location('Iteration Count='||p_iter_count,15);
        l_dedn_amt := Arrearage
                      (p_eletype_id           => p_eletype_id
                      ,p_ele_entryid          => p_ele_entryid
                      ,p_assignment_id        => p_assignment_id
                      ,p_business_grp_id      => p_business_grp_id
                      ,p_assignment_action_Id => p_assignment_action_Id
                      ,p_date_earned          => p_date_earned
                      ,p_net_asg_run          => p_net_asg_run
                      ,p_maxarrears           => p_maxarrears
                      ,p_dedn_amt             => l_actual_usercalc_amt
                      ,p_to_arrears           => p_to_arrears
                      ,p_not_taken            => p_not_taken
                      ,p_arrears_taken        => p_arrears_taken
                      ,p_remaining_amount     => p_remaining_amount
                      ,p_guaranteed_net       => p_guaranteed_net
                      ,p_partial_allowed      => l_partial_allowed
                      ,p_arrears_allowed      => l_arrears_allowed
                      );
     Else
       hr_utility.set_location('Iteration Count='||p_iter_count,15);
       p_to_arrears := 0;
       p_not_taken  := 0;

       If l_arrears_allowed = 'N'  And
          l_partial_allowed = 'N'  Then
          hr_utility.set_location('Arrears as well as Partial amount is not allowed',20);
          p_to_arrears := 0;
          If p_dedn_amt <> p_maxdesired_amt Then
             p_not_taken  := p_maxdesired_amt;
             l_dedn_amt   := 0;
          Else
             p_not_taken := 0;
             l_dedn_amt  := p_maxdesired_amt;
          End If;
       ElsIf  l_arrears_allowed = 'N'  And
              l_partial_allowed = 'Y'  Then
              hr_utility.set_location('Arrears not allowed, but Partial deduction is allowed',25);
              p_to_arrears := 0;
              p_not_taken  := p_maxdesired_amt - p_dedn_amt;
              l_dedn_amt   := p_dedn_amt;
       ElsIf  l_arrears_allowed = 'Y'  And
              l_partial_allowed = 'N'  Then
              hr_utility.set_location('Arrears is allowed , but Partial deduction is not allowed',30);
              If p_dedn_amt < p_maxdesired_amt Then
                 p_to_arrears := p_maxdesired_amt;
                 p_not_taken  := p_maxdesired_amt;
                 l_dedn_amt   := 0;
              Else
                 p_to_arrears := 0;
                 p_not_taken  := 0;
                 l_dedn_amt   := p_dedn_amt;
              End If;
       ElsIf l_arrears_allowed = 'Y'  And
             l_partial_allowed = 'Y'  Then
             hr_utility.set_location('Arrears as well as Partial deduction is allowed',35);
             If p_dedn_amt >= p_maxdesired_amt Then
                p_not_taken := 0;
                p_to_arrears := p_maxdesired_amt - p_dedn_amt;
             Else
                p_not_taken  := p_maxdesired_amt - p_dedn_amt;
                p_to_arrears := p_maxdesired_amt - p_dedn_amt;
             End If;
             l_dedn_amt   := p_dedn_amt;
       End If;
     End If; -- p_iter_count = 1
     hr_utility.set_location('To Arrears  ='||p_to_arrears,40);
     hr_utility.set_location('Not Taken   ='||p_not_taken,45);
     hr_utility.set_location('Ded. Amount ='||l_dedn_amt,50);
     hr_utility.set_location('Leaving:     '||l_process_name,150);
     Return l_dedn_amt;
Exception
   When Others Then
    l_dedn_amt := 0;
    p_error_message := 'Exception: When Others at :'||l_process_name;
    hr_utility.set_location('Error Code :'||SQLCODE,150);
    hr_utility.set_location('Error Msg  :'||SQLERRM,160);
    hr_utility.set_location('Leaving    :'||l_process_name, 170);
    Raise;
END Iterative_Arrearage;

-- ============================================================
-- ~Set_Iteration_Values:
-- ============================================================
Function Set_Iteration_Values
         (p_ele_entryid          In Number -- Context Parameter
         ,p_assignment_id        In Number -- Context Parameter
         ,p_business_grp_id      In Number -- Context Parameter
         ,p_assignment_action_Id In Number -- Context Parameter
         ,p_eletype_id	         In Number -- Context Parameter
         ,p_date_earned	         In Date   -- Context Parameter
         ,p_iter_count           In Number
         ,p_max_amount           In Number
         ,p_min_amount           In Number
         ,p_maxdesired_amt       In Number
         ,p_deduction_amount     In Number
         ,p_actual_usercalc_amt  In Number
         ,p_clr_add_amt          In Number
         ,p_clr_rep_amt          In Number
         ,p_stopper_flag         In Varchar2
         ,p_inserted_flag        In Varchar2
         ,p_calc_method          In Varchar2
         ,p_to_within            In Number
         ,p_error_message        Out NoCopy Varchar2
         ,p_warning_message      Out NoCopy Varchar2
         ) Return Number Is

   l_return_value    Number := 0;
   l_arrears_allowed Varchar2(2);
   l_partial_allowed Varchar2(2);
   l_calc_method     hr_organization_information.org_information1%TYPE;
   l_to_with_amt     number;
   l_process_name    Varchar2(250) := g_pkg_name||'Set_Iteration_Values';
Begin

     hr_utility.set_location('Entering: '||l_process_name, 5);
     If g_Element_Values.EXISTS(p_ele_entryid) Then
        hr_utility.set_location('Element Entry exits in PL/SQL table'||p_ele_entryid,10);
     Else
        hr_utility.set_location('Element Entry does NOT exists in PL/SQL table'||p_ele_entryid,10);
     End If;
     hr_utility.set_location('ded amt='||p_deduction_amount,15);
     hr_utility.set_location('max amt='||p_max_amount, 20);
     hr_utility.set_location('min amt='||p_min_amount, 25);
     hr_utility.set_location('max desired amt='||p_maxdesired_amt,30);
     If g_Element_Arr_Values.EXISTS(p_eletype_id) Then
      l_arrears_allowed := g_Element_Arr_Values(p_eletype_id).arrears_allowed;
      l_partial_allowed := g_Element_Arr_Values(p_eletype_id).partial_allowed;
     Else
      l_arrears_allowed := 'N';
      l_partial_allowed := 'N';
     End If;
     If g_Itr_Method.EXISTS(p_business_grp_id) Then
        l_calc_method := g_Itr_Method(p_business_grp_id).iterative_method;
        l_to_with_amt := g_Itr_Method(p_business_grp_id).adjust_to_within;
     Else
      l_calc_method := 'INTERPOLATION';
      l_to_with_amt := 1;
     End If;
     g_Element_Values(p_ele_entryid).ele_entry_id        := p_ele_entryid;
     g_Element_Values(p_ele_entryid).assignment_id       := p_assignment_id;
     g_Element_Values(p_ele_entryid).assignment_action_id:= p_assignment_action_id;
     g_Element_Values(p_ele_entryid).iter_count          := p_iter_count;
     g_Element_Values(p_ele_entryid).max_amount          := p_max_amount;
     g_Element_Values(p_ele_entryid).min_amount          := p_min_amount;
     g_Element_Values(p_ele_entryid).maxdesired_amt      := p_maxdesired_amt;
     g_Element_Values(p_ele_entryid).deduction_amount    := p_deduction_amount;
     g_Element_Values(p_ele_entryid).actual_usercalc_amt := p_actual_usercalc_amt;
     g_Element_Values(p_ele_entryid).stopper_flag        := p_stopper_flag;
     g_Element_Values(p_ele_entryid).inserted_flag       := p_inserted_flag;
     g_Element_Values(p_ele_entryid).arrears_allowed     := l_arrears_allowed;
     g_Element_Values(p_ele_entryid).partial_allowed     := l_partial_allowed;
     g_Element_Values(p_ele_entryid).calc_method         := l_calc_method;
     g_Element_Values(p_ele_entryid).to_within           := l_to_with_amt;
     g_Element_Values(p_ele_entryid).clr_add_amt         := p_clr_add_amt;
     g_Element_Values(p_ele_entryid).clr_rep_amt         := p_clr_rep_amt;
     hr_utility.set_location('Leaving: '||l_process_name, 150);

     Return l_return_value;

Exception
   When Others Then
    l_return_value  := -1;
    p_error_message := 'Exception: When Others at '||l_process_name;
    hr_utility.set_location('Error  : '||p_error_message, 160);
    hr_utility.set_location('Leaving: '||l_process_name, 170);

    Return l_return_value;

End Set_Iteration_Values;
-- ============================================================
-- ~ Set_Formula_Warning_Mesg: Set the formula warn. messgage
-- ============================================================
Function Set_Formula_Warning_Mesg
         (p_ele_entryid         In  Number -- Context Parameter
         ,p_assignment_id       In  Number -- Context Parameter
         ,p_business_grp_id     In  Number -- Context Parameter
         ,p_eletype_id	        In  Number -- Context Parameter
         ,p_date_earned	        In  Date   -- Context Parameter
         ,p_warning_message     In  Varchar2
         ,p_warning_code        In  Varchar2
         ) Return Number Is
 l_process_name    Varchar2(150) := g_pkg_name||'Set_Formula_Warning_Mesg';
 l_return_value    Number := 0;
 l_error_message   varchar2(3000);
Begin
  hr_utility.set_location('Entering: '||l_process_name, 5);
  If g_Element_Values.EXISTS(p_ele_entryid) Then
     g_Element_Values(p_ele_entryid).formula_warning := NVL(p_warning_message,'X');
     g_Element_Values(p_ele_entryid).warning_code    := NVL(p_warning_code,   'X');
  End If;
  hr_utility.set_location('Leaving: '||l_process_name, 150);
  Return l_return_value;
Exception
  When Others Then
   l_return_value  := -1;
   l_error_message := SQLERRM;
   hr_utility.set_location('Error  : '||l_error_message, 160);
   hr_utility.set_location('Leaving: '||l_process_name, 170);
   Return l_return_value;
End Set_Formula_Warning_Mesg;
-- ============================================================
-- ~ Get_Formula_Warning_Mesg: get the formula warn. messgage
-- ============================================================
Function Get_Formula_Warning_Mesg
         (p_ele_entryid         In  Number -- Context Parameter
         ,p_assignment_id       In  Number -- Context Parameter
         ,p_business_grp_id     In  Number -- Context Parameter
         ,p_eletype_id	        In  Number -- Context Parameter
         ,p_date_earned	        In  Date   -- Context Parameter
         ,p_warning_message     Out NoCopy Varchar2
         ,p_warning_code        Out NoCopy Varchar2
         ) Return Number Is
 l_process_name    Varchar2(150) := g_pkg_name||'Get_Formula_Warning_Mesg';
 l_return_value    Number := 0;
 l_error_message   varchar2(3000);
Begin
  hr_utility.set_location('Entering: '||l_process_name, 5);
  If g_Element_Values.EXISTS(p_ele_entryid) Then
     p_warning_message := NVL(g_Element_Values(p_ele_entryid).formula_warning,'X');
     p_warning_message := NVL(g_Element_Values(p_ele_entryid).warning_code,   'X');
  End If;
  hr_utility.set_location('Leaving: '||l_process_name, 150);
  Return l_return_value;
Exception
  When Others Then
   l_return_value  := -1;
   l_error_message := SQLERRM;
   hr_utility.set_location('Error  : '||l_error_message, 160);
   hr_utility.set_location('Leaving: '||l_process_name, 170);
   Return l_return_value;
End Get_Formula_Warning_Mesg;
-- ============================================================
-- ~Get_Iteration_Values:
-- ============================================================
Function Get_Iteration_Values
         (p_ele_entryid         In  Number -- Context Parameter
         ,p_assignment_id       In  Number -- Context Parameter
         ,p_business_grp_id     In  Number -- Context Parameter
         ,p_eletype_id	        In  Number -- Context Parameter
         ,p_date_earned	        In  Date   -- Context Parameter
         ,p_iter_count          Out NoCopy Number
         ,p_max_amount          Out NoCopy Number
         ,p_min_amount          Out NoCopy Number
         ,p_maxdesired_amt      Out NoCopy Number
         ,p_deduction_amount    Out NoCopy Number
         ,p_actual_usercalc_amt Out NoCopy Number
         ,p_clr_add_amt         Out NoCopy Number
         ,p_clr_rep_amt         Out NoCopy Number
         ,p_stopper_flag        Out NoCopy Varchar2
         ,p_inserted_flag       Out NoCopy Varchar2
         ,p_arrears_allowed     Out NoCopy Varchar2
         ,p_partial_allowed     Out NoCopy Varchar2
         ,p_calc_method         Out NoCopy Varchar2
         ,p_to_within           Out NoCopy Number
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2
         ) Return Number Is

 l_return_value Number        := 0;
 l_process_name    Varchar2(150) := g_pkg_name||'Get_Iteration_Values';
 l_arrears_allowed Varchar2(2);
 l_partial_allowed Varchar2(2);

Begin

  hr_utility.set_location('Entering: '||l_process_name, 5);
  If g_Element_Values.EXISTS(p_ele_entryid) Then
     p_iter_count          := g_Element_Values(p_ele_entryid).iter_count;
     p_max_amount          := g_Element_Values(p_ele_entryid).max_amount;
     p_min_amount          := g_Element_Values(p_ele_entryid).min_amount;
     p_maxdesired_amt      := g_Element_Values(p_ele_entryid).maxdesired_amt;
     p_deduction_amount    := g_Element_Values(p_ele_entryid).deduction_amount;
     p_actual_usercalc_amt := g_Element_Values(p_ele_entryid).actual_usercalc_amt;
     p_stopper_flag        := g_Element_Values(p_ele_entryid).stopper_flag;
     p_inserted_flag       := g_Element_Values(p_ele_entryid).inserted_flag;
     p_arrears_allowed     := g_Element_Values(p_ele_entryid).arrears_allowed;
     p_partial_allowed     := g_Element_Values(p_ele_entryid).partial_allowed;
     p_calc_method         := g_Element_Values(p_ele_entryid).calc_method;
     p_to_within           := g_Element_Values(p_ele_entryid).to_within;
     p_clr_add_amt         := g_Element_Values(p_ele_entryid).clr_add_amt;
     p_clr_rep_amt         := g_Element_Values(p_ele_entryid).clr_rep_amt;
     hr_utility.set_location('Iteration Count ='|| p_iter_count,145);
  Else
     If g_Element_Arr_Values.EXISTS(p_eletype_id) Then
      l_arrears_allowed := g_Element_Arr_Values(p_eletype_id).arrears_allowed;
      l_partial_allowed := g_Element_Arr_Values(p_eletype_id).partial_allowed;
     Else
      Get_Arrearage_Info
        (p_ele_type_id     => p_eletype_id
        ,p_assignment_id   => p_assignment_id
        ,p_business_grp_id => p_business_grp_id
        ,p_effective_date  => p_date_earned
        ,p_arrears_allowed => l_arrears_allowed
        ,p_partial_allowed => l_partial_allowed
        );
      g_Element_Arr_Values(p_eletype_id).arrears_allowed := l_arrears_allowed;
      g_Element_Arr_Values(p_eletype_id).partial_allowed := l_partial_allowed;
     End If;
     If g_Itr_Method.EXISTS(p_business_grp_id) Then
      p_calc_method := g_Itr_Method(p_business_grp_id).iterative_method;
      p_to_within   := g_Itr_Method(p_business_grp_id).adjust_to_within;
     Else
      p_calc_method := 'INTERPOLATION';
      p_to_within   := 1;
     End If;

     p_iter_count          := 0;
     p_max_amount          := 0;
     p_min_amount          := 0;
     p_maxdesired_amt      := 0;
     p_deduction_amount    := 0;
     p_actual_usercalc_amt := 0;
     p_stopper_flag        := 'N';
     p_inserted_flag       := 'N';
     p_arrears_allowed     := l_arrears_allowed;
     p_partial_allowed     := l_partial_allowed;
     p_clr_add_amt         := 0;
     p_clr_rep_amt         := 0;
     p_warning_message     := 'Element Values does not exists in PL/SQL table :g_Element_Values';
     hr_utility.set_location('Element Values does not exists in PL/SQL table :g_Element_Values',145);
     hr_utility.set_location('Iteration Count ='|| p_iter_count,145);
  End If;
  hr_utility.set_location('Leaving: '||l_process_name, 150);

  Return l_return_value;

Exception
  When Others Then
   l_return_value := -1;
   p_error_message := 'Exception: When Others at '||l_process_name;
   hr_utility.set_location('Error  : '||p_error_message, 160);
   hr_utility.set_location('Leaving: '||l_process_name, 170);
   Return l_return_value;

End Get_Iteration_Values;

-- ============================================================
-- ~Clear_Iteration_Values: Clears the pl/sql table for all other
-- ~previously processed assignments in order to reduce the
-- ~memory usage.
-- ============================================================
Function Clear_Iteration_Values
         (p_ele_entryid          In Number -- Context Parameter
         ,p_assignment_id        In Number -- Context Parameter
         ,p_assignment_action_id In Number -- Context Parameter
         ,p_error_message        Out NoCopy Varchar2
         ,p_warning_message      Out NoCopy Varchar2
         ) Return Number Is

 l_curr_ele_entry_id  pay_element_entries_f.element_entry_id%TYPE;
 l_prev_ele_entry_id  pay_element_entries_f.element_entry_id%TYPE;
 l_return_value       Number := 0;
 l_recs_deleted       Number := 0;
 l_process_name       Varchar2(150) := g_pkg_name||'Clear_Iteration_Values';

Begin

  hr_utility.set_location('Entering: '||l_process_name, 5);
  l_curr_ele_entry_id := g_Element_Values.FIRST;
  While l_curr_ele_entry_id Is Not Null
  Loop
    If (g_Element_Values(l_curr_ele_entry_id).assignment_id <> p_assignment_id)
        Or
       (g_Element_Values(l_curr_ele_entry_id).assignment_id = p_assignment_id And
        g_Element_Values(l_curr_ele_entry_id).assignment_action_id <> p_assignment_action_id
        ) Then
       g_Element_Values.DELETE(l_curr_ele_entry_id);
       l_recs_deleted      := l_recs_deleted + 1;
    End If;
    l_prev_ele_entry_id := l_curr_ele_entry_id;
    l_curr_ele_entry_id := g_Element_Values.NEXT(l_prev_ele_entry_id);
  End Loop;
  p_warning_message := 'Records deleted from PL/SQL table :'||l_recs_deleted;
  hr_utility.set_location('Warning : '||p_warning_message, 145);
  hr_utility.set_location('Leaving : '||l_process_name,    150);

  Return l_return_value;

Exception
  When Others Then
   l_return_value := -1;
   p_error_message := 'Exception: When Others at '||l_process_name;
   hr_utility.set_location('Error  : '||p_error_message, 160);
   hr_utility.set_location('Leaving: '||l_process_name, 170);
   Return l_return_value;
End Clear_Iteration_Values;

-- ============================================================
-- ~Incr_Iteration_Count: Increment the Iteration count for an
-- ~element currently iterating.
-- ============================================================
Function Incr_Iteration_Count
         (p_ele_entryid         In Number -- Context Parameter
         ,p_assignment_id       In Number -- Context Parameter
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2
         ) Return Number Is
 l_return_value Number := 0;
 l_process_name Varchar2(150) := g_pkg_name||'Incr_Iteration_Count';
Begin

  hr_utility.set_location('Entering: '||l_process_name, 5);
  If g_Element_Values.EXISTS(p_ele_entryid) Then
     g_Element_Values(p_ele_entryid).iter_count := g_Element_Values(p_ele_entryid).iter_count + 1;
  Else
     l_return_value    := 1;
     p_warning_message := 'Could not find record in PL/SQL table :g_Element_Values '||
                          'to Incr. the iteration count';
     hr_utility.set_location('Iteration Count =0',145 );
  End If;
  hr_utility.set_location('Leaving: '||l_process_name, 150);

  Return l_return_value;
Exception
  When Others Then
   l_return_value := -1;
   p_error_message := 'Exception: When Others at '||l_process_name;
   hr_utility.set_location('Error  : '||p_error_message, 160);
   hr_utility.set_location('Leaving: '||l_process_name,  170);

   Return l_return_value;

End Incr_Iteration_Count;

-- ============================================================
-- ~Stop_Iteration: Stops Iterating a Pretax element once the
-- ~stop flag is set to Y.
-- ============================================================
Function Stop_Iteration
         (p_ele_entryid         In Number -- Context Parameter
         ,p_assignment_id       In Number -- Context Parameter
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2

         ) Return Number Is
 l_return_value Number := 0;
 l_process_name Varchar2(150) := g_pkg_name||'Stop_Iteration';
Begin

  hr_utility.set_location('Entering: '||l_process_name, 5);
  If g_Element_Values.EXISTS(p_ele_entryid) Then
     g_Element_Values(p_ele_entryid).stopper_flag := 'Y';
  Else
     l_return_value := -1;
     p_warning_message := 'Could not find record in PL/SQL table :g_Element_Values '||
                          'to set the stopper flag';
  End If;
  hr_utility.set_location('Leaving: '||l_process_name, 150);

  Return l_return_value;

Exception
  When Others Then
   l_return_value  := -1;
   p_error_message := 'Exception: When Others at '||l_process_name;
   hr_utility.set_location('Error  : '||p_error_message, 160);
   hr_utility.set_location('Leaving: '||l_process_name, 170);

   Return l_return_value;

End Stop_Iteration;
-- ============================================================
-- ~Get_Iteration_Count: Gets the Iteration counter value from
-- ~from the PL/SQL table for the element entry id
-- ============================================================
Function Get_Iteration_Count
         (p_ele_entryid         In Number -- Context Parameter
         ,p_assignment_id       In Number -- Context Parameter
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2

         ) Return Number Is
 l_return_value Number := 0;
 l_process_name Varchar2(150) := g_pkg_name||'Get_Iteration_Count';
Begin
  hr_utility.set_location('Entering: '||l_process_name, 5);
  If g_Element_Values.EXISTS(p_ele_entryid) Then
     l_return_value := g_Element_Values(p_ele_entryid).Iter_Count;
  Else
     l_return_value := 0;
     p_warning_message := 'Could not find record in PL/SQL table :g_Element_Values '||
                          'to get the Iteration Count';
  End If;
  hr_utility.set_location('Leaving: '||l_process_name, 150);
  Return l_return_value;

Exception
  When Others Then
   l_return_value  := -1;
   p_error_message := 'Exception: When Others at '||l_process_name;
   hr_utility.set_location('Error  : '||p_error_message, 145);
   hr_utility.set_location('Leaving: '||l_process_name, 150);
   Return l_return_value;

End Get_Iteration_Count;
-- ============================================================
-- ~Get_Stopper_Flag: Gets the Stopper Flag value from
-- ~the PL/SQL table for the element entry id
-- ============================================================
Function Get_Stopper_Flag
         (p_ele_entryid         In Number -- Context Parameter
         ,p_assignment_id       In Number -- Context Parameter
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2

         ) Return Varchar2 Is
 l_return_value Varchar2(2);
 l_process_name Varchar2(150) := g_pkg_name||'Get_Stopper_Count';
Begin
  hr_utility.set_location('Entering: '||l_process_name, 5);
  If g_Element_Values.EXISTS(p_ele_entryid) Then
     l_return_value := g_Element_Values(p_ele_entryid).Stopper_Flag;
  Else
     l_return_value := 'N';
     p_warning_message := 'Could not find record in PL/SQL table :g_Element_Values '||
                          'to get the Stopper Flag';
  End If;
  hr_utility.set_location('Leaving: '||l_process_name, 150);
  Return l_return_value;

Exception
  When Others Then
   l_return_value := -1;
   p_error_message := 'Exception: When Others at '||l_process_name;
   hr_utility.set_location('Error  : '||p_error_message, 145);
   hr_utility.set_location('Leaving: '||l_process_name, 150);
   Return l_return_value;

End Get_Stopper_Flag;

End PQP_Iterative_Arrearage;

/
