--------------------------------------------------------
--  DDL for Package Body PAY_KR_WG_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_WG_REPORT_PKG" AS
/* $Header: pykrwgrp.pkb 120.1 2005/12/15 05:51:17 pdesu noship $ */
--
-- Defining Global Variables
--
g_element_entry_id   NUMBER;
g_attachment_seq_no  VARCHAR2(100);
g_effective_date     DATE;

-- global var introduced for bug 3223825

g_int_asgitd 	     NUMBER;
g_int_asgrun 	     NUMBER;
g_int_asgwgitd 	     NUMBER;
g_ded_asgitd 	     NUMBER;
g_ded_asgrun 	     NUMBER;
g_ded_asgwgitd 	     NUMBER;
g_debug              constant BOOLEAN :=hr_utility.debug_enabled;

  ---------------------------------------------------------------------------------
  /*                    FUNCTION processing_type                                 */
  ---------------------------------------------------------------------------------
  FUNCTION processing_type (p_element_entry_id   IN   NUMBER) RETURN VARCHAR2
  IS
    CURSOR csr_processing_type
    IS
     select peev.screen_entry_value     processing_type
     from   pay_element_entries_f       pee
           ,pay_element_entry_values_f  peev
           ,pay_input_values_f          piv
      where pee.element_entry_id     =  p_element_entry_id
        and peev.element_entry_id    =  pee.element_entry_id
        and piv.name                 = 'Processing Type'
        and piv.input_value_id       =  peev.input_value_id
        and g_effective_date between piv.effective_start_date and piv.effective_end_date
        and pee.effective_start_date = peev.effective_start_date
        and pee.effective_end_date   = peev.effective_end_date
        order by pee.effective_start_date desc;
    l_processing_type    VARCHAR2(10);
  BEGIN
    OPEN  csr_processing_type;
    FETCH csr_processing_type INTO l_processing_type;
    CLOSE csr_processing_type;
    return l_processing_type;
  END processing_type;
  --===============================================================================
  -------------------------------------------------------------------------------
  /*                        FUNCTION Obligation_exists                         */
  -------------------------------------------------------------------------------
  FUNCTION Obligation_exists (p_element_entry_id   IN   pay_element_entries_f.element_entry_id%TYPE
                             ,p_effective_date     IN   DATE  DEFAULT   NULL) RETURN BOOLEAN
  IS
    CURSOR csr_obligation
    IS
     select peev.screen_entry_value    obligation_release
           ,peev.effective_end_date
     from   pay_element_entries_f      pee
           ,pay_element_entry_values_f peev
           ,pay_input_values_f         piv
      where pee.element_entry_id     = p_element_entry_id
        and peev.element_entry_id    = pee.element_entry_id
        and piv.name                 ='Obligation Release'
        and piv.input_value_id       = peev.input_value_id
        and g_effective_date between piv.effective_start_date and piv.effective_end_date
        and pee.effective_start_date = peev.effective_start_date
        and pee.effective_end_date   = peev.effective_end_date
        order by peev.effective_start_date desc;
    l_obligation         VARCHAR2(10);
    l_effective_date     DATE;
  BEGIN
    OPEN  csr_obligation;
    FETCH csr_obligation INTO l_obligation, l_effective_date;
    CLOSE csr_obligation;
    if g_debug then
	    hr_utility.trace('l_obligation : '||l_obligation);
    end if;
    -- Bug : 4866417
    -- Removed the equal condition
    IF l_obligation ='Y' AND nvl(p_effective_date, g_effective_date) > l_effective_date THEN
      RETURN true;
    END IF;
    RETURN false;
  EXCEPTION
    WHEN OTHERS THEN
     if g_debug then
	      hr_utility.trace('Error Occured Obligation_exists');
     end if;
     raise;
  END Obligation_exists;
  --==================================================================================
  ------------------------------------------------------------------------------------
  /*                       FUNCTION get_element_entry_id                            */
  ------------------------------------------------------------------------------------
  /* Bug 2856663 : condition for assignment_id added to the where clause            */
  ------------------------------------------------------------------------------------
  FUNCTION get_element_entry_id (p_assignment_id       IN   per_assignments_f.assignment_id%type
				,p_attachment_seq_no   IN   VARCHAR2) RETURN NUMBER
  IS
    CURSOR csr_element_entry
    IS
      Select pee.element_entry_id
        from pay_element_types_f        pet
            ,pay_input_values_f         piv
            ,pay_element_entries_f      pee
            ,pay_element_entry_values_f peev
	    ,pay_element_links_f        pel
       where piv.input_value_id       = peev.input_value_id
        and pet.element_type_id       = piv.element_type_id
        and piv.name                  = 'Attachment Seq No'
        and pet.element_name          = 'Wage Garnishments'
        and pet.legislation_code      = 'KR'
        and pee.entry_type            = 'E'
	and pel.element_type_id       = pet.element_type_id
        and pee.assignment_id         = p_assignment_id
	and pel.element_link_id       = pee.element_link_id
        and peev.screen_entry_value   = p_attachment_seq_no
        and pee.element_entry_id      = peev.element_entry_id
        and peev.effective_start_date = pee.effective_start_date
        and peev.effective_end_date   = pee.effective_end_date
        order by pee.element_entry_id, pee.effective_start_date ;
   l_element_entry_id      NUMBER;
  BEGIN
    OPEN  csr_element_entry ;
    FETCH csr_element_entry   INTO l_element_entry_id;
    CLOSE csr_element_entry ;
    if g_debug then
	    hr_utility.trace('Element Entry Id : '||to_char(l_element_entry_id));
    end if ;
    return l_element_entry_id;
  EXCEPTION
    WHEN OTHERS THEN
    if g_debug then
      hr_utility.trace('Error Occured get_element_entry_id');
    end if;
      raise;
  END get_element_entry_id;
  --======================================================================================
  ------------------------------------------------------------------------------------
  /*                       FUNCTION get_attach_seq_no                               */
  ------------------------------------------------------------------------------------
  FUNCTION get_attach_seq_no (p_element_entry_id    IN   pay_element_entries_f.element_entry_id%TYPE) RETURN VARCHAR2
  IS
    CURSOR csr_attach_seq
    IS
      select peev.screen_entry_value
        from pay_element_entries_f      pee
            ,pay_element_entry_values_f peev
            ,pay_input_values_f         piv
            ,pay_element_types_f        pet
            ,pay_element_links_f        pel
       where pee.element_entry_id     = p_element_entry_id
         and peev.element_entry_id    = pee.element_entry_id
         and peev.input_value_id      = piv.input_value_id
         and piv.name                 ='Attachment Seq No'
         and pet.element_type_id      = piv.element_type_id
         and pet.element_name         ='Wage Garnishments'
         and pet.legislation_code     ='KR'
         and pel.element_link_id      = pee.element_link_id
         and pel.element_type_id      = pet.element_type_id
         and g_effective_date between pet.effective_start_date and pet.effective_end_date
         and g_effective_date between pel.effective_start_date and pel.effective_end_date
	 and pee.effective_start_date = peev.effective_start_date
	 and pee.effective_end_date   = peev.effective_end_date
	 order by peev.effective_start_date desc;
    l_attach_seq_no     VARCHAR2(100);
  BEGIN
    OPEN  csr_attach_seq;
    FETCH csr_attach_seq INTO l_attach_seq_no;
    CLOSE csr_attach_seq;
    return l_attach_seq_no;
  EXCEPTION
    WHEN OTHERS THEN
    if g_debug then
      hr_utility.trace('Error Occured get_attach_seq_no');
    end if;
      raise;
  END get_attach_seq_no;
  --======================================================================================
  ---------------------------------------------------------------------------------
  /*                    FUNCTION prev_case_attachment_seq_no                     */
  ---------------------------------------------------------------------------------
  FUNCTION prev_case_attachment_seq_no (p_element_entry_id   IN   NUMBER) RETURN VARCHAR2
  IS
    CURSOR csr_attachment_seq_no
    IS
     Select peev1.screen_entry_value     attachment_seq_no
     from   pay_element_entries_f        pee
           ,pay_element_entry_values_f   peev
           ,pay_element_entries_f        pee1
           ,pay_input_values_f           piv
           ,pay_element_types_f          pet
           ,pay_element_entry_values_f   peev1
           ,pay_input_values_f           piv1
      where pee.element_entry_id      =  p_element_entry_id
        and peev.screen_entry_value   =  pee.entry_information21
        and piv.input_value_id        =  peev.input_value_id
        and piv.name                  =  'Case Number'
        and piv.legislation_code      =  'KR'
        and pet.element_type_id       =  piv.element_type_id
        and pet.element_name          =  'Wage Garnishments'
        and pet.legislation_code      =  'KR'
        and pee1.element_entry_id     =  peev.element_entry_id
        and pee1.entry_type           =  'E'
        and peev1.element_entry_id    =  pee1.element_entry_id
        and piv1.input_value_id       =  peev1.input_value_id
        and piv1.name                 =  'Attachment Seq No'
        and piv1.legislation_code     =  'KR'
        and pee.assignment_id         =  pee1.assignment_id
        and piv.element_type_id       =  piv1.element_type_id
        and pee1.effective_start_date = peev.effective_start_date
        and pee1.effective_end_date   = peev.effective_end_date
        and pee1.effective_start_date = peev1.effective_start_date
        and pee1.effective_end_date   = peev1.effective_end_date
        and g_effective_date between pet.effective_start_date and pet.effective_end_date
        and g_effective_date between piv.effective_start_date and piv.effective_end_date
        and g_effective_date between piv1.effective_start_date and piv1.effective_end_date
        order by peev1.effective_start_date desc ;
    l_attachment_seq_no    VARCHAR2(100);
  BEGIN
    OPEN  csr_attachment_seq_no;
    FETCH csr_attachment_seq_no INTO l_attachment_seq_no;
    CLOSE csr_attachment_seq_no;
    return l_attachment_seq_no;
  END prev_case_attachment_seq_no;
  --==================================================================================
  ---------------------------------------------------------------------------------------------
  /*                        FUNCTION wage_garnishment_exists                                 */
  ---------------------------------------------------------------------------------------------
  FUNCTION wage_garnishment_exists (p_assignment_id    IN   per_assignments_f.assignment_id%TYPE
                                   ,p_effective_date   IN   DATE  DEFAULT NULL  ) RETURN boolean
  IS
    CURSOR csr_wg_exists (p_date     date)
    IS
      select distinct pee.element_entry_id
       from  pay_element_entries_f      pee
            ,pay_element_types_f        pet
	    ,pay_element_links_f        pel
     where pee.assignment_id       = p_assignment_id
       and pet.element_name        = 'Wage Garnishments'
       and pet.legislation_code    = 'KR'
       and pee.entry_type          = 'E'
       and pel.element_link_id     = pee.element_link_id
       and pel.element_type_id     = pet.element_type_id
       and p_date between pee.effective_start_date and pee.effective_end_date
       and p_date between pet.effective_start_date and pet.effective_end_date
       and p_date between pel.effective_start_date and pel.effective_end_date;
    l_exists             BOOLEAN;
    l_element_entry_id   NUMBER;
    l_effective_date     DATE;
  BEGIN
    IF p_effective_date IS NULL THEN
       l_effective_date := g_effective_date;
    ELSE
       l_effective_date := p_effective_date;
    END IF;
    OPEN  csr_wg_exists (l_effective_date);
    FETCH csr_wg_exists INTO l_element_entry_id;
      IF csr_wg_exists%FOUND  THEN
         l_exists := true;
      ELSE
         l_exists := false;
      END IF;
    CLOSE csr_wg_exists;
    RETURN l_exists;
  EXCEPTION
     WHEN OTHERS THEN
	if g_debug then
       		hr_utility.trace('Error Occured wage_garnishment_exists');
        end if;
        raise;
  END wage_garnishment_exists;
  --============================================================================================
  ---------------------------------------------------------------------------
  /*                    FUNCTION get_wg_paid_amount                        */
  ---------------------------------------------------------------------------
  FUNCTION get_wg_paid_amount (p_assignment_action_id   IN   NUMBER
                              ,p_source_text            IN   VARCHAR2
                              ,p_dim_name               IN   VARCHAR2) RETURN NUMBER
  IS
    CURSOR csr_defined_bal_id
    IS
	SELECT pdb.defined_balance_id
        from pay_balance_types          pbt
            ,pay_balance_dimensions     pbd
            ,pay_defined_balances       pdb
         where pbt.balance_name         ='WG Deductions'
         and pbt.legislation_code     ='KR'
         and pbd.database_item_suffix = p_dim_name
         and pbd.legislation_code     ='KR'
         and pdb.balance_type_id      = pbt.balance_type_id
         and pdb.balance_dimension_id = pbd.balance_dimension_id
         and pdb.legislation_code     ='KR';

    l_amount     NUMBER  ;
    l_defined_balance_id NUMBER;

  BEGIN
    l_amount := 0;
    l_defined_balance_id :=0;
    -- Bug No 3550515
    IF p_assignment_action_id is not NULL then

	    pay_balance_pkg.set_context('SOURCE_TEXT', p_source_text);

	    If (p_dim_name='_ASG_ITD') and  (g_ded_asgitd is not null) then
		   l_defined_balance_id:=g_ded_asgitd;
	    ELSIF p_dim_name='_ASG_RUN'and g_ded_asgrun is not null then
		   l_defined_balance_id:= g_ded_asgrun;
	    ELSIF p_dim_name='_ASG_WG_ITD'and  g_ded_asgwgitd is not null then
		   l_defined_balance_id:= g_ded_asgwgitd;
	    ELSE

		   OPEN csr_defined_bal_id;
		   FETCH csr_defined_bal_id INTO l_defined_balance_id;
		   CLOSE csr_defined_bal_id;

		   IF p_dim_name='_ASG_ITD'  THEN
			g_ded_asgitd:=l_defined_balance_id;
		   ELSIF p_dim_name='_ASG_RUN' THEN
			g_ded_asgrun :=l_defined_balance_id;
		   ELSIF p_dim_name='_ASG_WG_ITD' THEN
			g_ded_asgwgitd:=l_defined_balance_id;
		   END IF;
	    END IF;

	    l_amount:=pay_balance_pkg.get_value (l_defined_balance_id, p_assignment_action_id);
    END IF;
    IF g_debug then
	    hr_utility.trace('l_amount : '||to_char(l_amount));
    END IF;

    return  nvl(l_amount,0);

  EXCEPTION
    WHEN OTHERS THEN
    if g_debug then
 	   hr_utility.trace('Error Occured get_wg_paid_amount');
    end if;
    raise;
  END get_wg_paid_amount;
  --==================================================================================
  ---------------------------------------------------------------------------
  /*                    FUNCTION get_wg_interest_paid                      */
  ---------------------------------------------------------------------------
  FUNCTION get_wg_interest_paid (p_assignment_action_id   IN   NUMBER
                                ,p_source_text            IN   VARCHAR2
                                ,p_dim_name               IN   VARCHAR2) RETURN NUMBER
  IS
   CURSOR csr_wg_interest_paid
    IS

	SELECT pdb.defined_balance_id
        from pay_balance_types          pbt
            ,pay_balance_dimensions     pbd
            ,pay_defined_balances       pdb
        where pbt.balance_name         ='WG Paid Interest'
         and pbt.legislation_code     ='KR'
         and pbd.database_item_suffix = p_dim_name
         and pbd.legislation_code     ='KR'
         and pdb.balance_type_id      = pbt.balance_type_id
         and pdb.balance_dimension_id = pbd.balance_dimension_id
         and pdb.legislation_code     ='KR';
    l_amount     NUMBER;
    l_defined_balance_id NUMBER;

  BEGIN
    l_amount :=0;
    l_defined_balance_id :=0;
    -- Bug No 3550515
    IF p_assignment_action_id is not NULL then

	    pay_balance_pkg.set_context('SOURCE_TEXT', p_source_text);

	    IF p_dim_name='_ASG_ITD' and  g_int_asgitd is not  null then
		  l_defined_balance_id:=g_int_asgitd;

	    ELSIF p_dim_name='_ASG_RUN'and g_int_asgrun is not null then
		  l_defined_balance_id:=g_int_asgrun;

	    ELSIF p_dim_name='_ASG_WG_ITD'and  g_int_asgwgitd is not null then
		  l_defined_balance_id:=g_int_asgwgitd;

	    ELSE
		  OPEN csr_wg_interest_paid;
		  FETCH csr_wg_interest_paid INTO l_defined_balance_id;
		  CLOSE csr_wg_interest_paid;
		  IF p_dim_name='_ASG_ITD' then
			g_int_asgitd:=l_defined_balance_id;
		  ELSIF p_dim_name='_ASG_RUN' then
			g_int_asgrun:=l_defined_balance_id;
		  ELSIF p_dim_name='_ASG_WG_ITD'then
			g_int_asgwgitd:=l_defined_balance_id;
		  END IF;
	    END IF;
	    l_amount:=pay_balance_pkg.get_value (l_defined_balance_id, p_assignment_action_id);
    END IF;
    if g_debug then
	    hr_utility.trace('l_amount : '||to_char(l_amount));
    end if;
    return  nvl(l_amount,0);
  EXCEPTION
    WHEN OTHERS THEN
    if g_debug then
	    hr_utility.trace('Error Occured get_wg_interest_paid');
    end if;
    raise;
  END get_wg_interest_paid;
  --==================================================================================
  ----------------------------------------------------------------------------------------
  /*                         FUNCTION get_max_asg_action_id                             */
  ----------------------------------------------------------------------------------------
  FUNCTION get_max_asg_action_id (p_assignment_id     IN   NUMBER
                                 ,p_effective_date    IN   DATE   DEFAULT NULL)
           RETURN pay_assignment_actions.assignment_action_id%type
  IS
     --
     -- Modified cursor for bug 3899565
     --
    CURSOR csr_max_action_seq (p_assignment_id number,
                               p_date          date)
    IS
     select max(pac.action_sequence)
      from pay_payroll_actions     ppa
          ,pay_assignment_actions  pac
     where ppa.payroll_action_id = pac.payroll_action_id
       and pac.assignment_id     = p_assignment_id
       and ppa.effective_date   <= p_date
       and ppa.action_type      in ('B','R','Q')
       and pac.action_status     = 'C'
       and ppa.action_status     = 'C'
       and decode(ppa.action_type,'B',0, decode(pac.source_action_id,null,-1,0)) = 0;
     --
    CURSOR csr_asg_action (p_assignment_id    number,
                           p_action_sequence  number)
    IS
        select
	    pac.assignment_action_id
	from
	    pay_assignment_actions pac
	where
	    pac.assignment_id         =  p_assignment_id
	    and pac.action_sequence   =  p_action_sequence
            and pac.action_status     = 'C';
     --
     l_asg_action_id     NUMBER;
     l_effective_date    DATE;
     l_action_sequence   pay_assignment_actions.action_sequence%type;
     --
  BEGIN
    --
    IF p_effective_date IS NULL THEN
       l_effective_date := g_effective_date;
    ELSE
       l_effective_date := p_effective_date;
    END IF;

    OPEN csr_max_action_seq (p_assignment_id, l_effective_date);
    FETCH csr_max_action_seq INTO l_action_sequence;
    CLOSE csr_max_action_seq;

    if l_action_sequence is not null then
       OPEN csr_asg_action (p_assignment_id, l_action_sequence);
       FETCH csr_asg_action INTO l_asg_action_id;
       CLOSE csr_asg_action;
    end if;

    if g_debug then
	    hr_utility.trace('l_action_sequence : '||to_char(l_action_sequence));
	    hr_utility.trace('l_asg_action_id : '||to_char(l_asg_action_id));
     end if;
     --
    return l_asg_action_id;
     --
 EXCEPTION
    WHEN OTHERS THEN
      if g_debug then
	      hr_utility.trace('Error Occured get_max_asg_action_id');
      end if;
      raise;
  END get_max_asg_action_id;
  --===========================================================================================
  ---------------------------------------------------------------------------------------------
  /*                FUNCTION paid_amount_this_run  (for single creditor)                     */
  ---------------------------------------------------------------------------------------------
  FUNCTION paid_amount_this_run (p_assignment_action_id   IN   pay_assignment_actions.assignment_action_id%TYPE
                                ,p_element_entry_id       IN   pay_element_entries_f.element_entry_id%TYPE ) RETURN NUMBER
  IS
    Cursor csr_paid_amount
    IS
      Select  sum(prrv.result_value)
        from  pay_run_result_values prrv
             ,pay_input_values_f    piv
             ,pay_run_results       prr
       where  prr.source_id            = p_element_entry_id
         and  prr.assignment_action_id = p_assignment_action_id
         and  prr.run_result_id        = prrv.run_result_id
         and  prrv.input_value_id      = piv.input_value_id
         and  piv.name                 = 'Pay Value'
         and  piv.legislation_code     = 'KR'
         and  g_effective_date between piv.effective_start_date and piv.effective_end_date
	 and  prr.element_type_id in   (Select element_type_id
	                                  from pay_element_types_f pet
	                                 where element_name in ('Wage Garnishments', 'WG Redistributed Amount')
					   and legislation_code = 'KR'
					   and g_effective_date between pet.effective_start_date and pet.effective_end_date
                                       );
    l_paid_amount_this_run NUMBER;
  BEGIN
    l_paid_amount_this_run:= 0;
    OPEN  csr_paid_amount;
    FETCH csr_paid_amount INTO l_paid_amount_this_run;
    CLOSE csr_paid_amount;
    if g_debug then
	    hr_utility.trace('Paid amount this run : '||to_char(l_paid_amount_this_run));
    end if;
    return l_paid_amount_this_run;
  EXCEPTION
    WHEN OTHERS THEN
      if g_debug then
      	hr_utility.trace('Error Ocured in paid_amount_this_run');
      end if;
      raise;
  END paid_amount_this_run;
  --===========================================================================================
  ---------------------------------------------------------------------------------------------
  /*                FUNCTION paid_amount_this_run  (for all creditors)                       */
  ---------------------------------------------------------------------------------------------
  FUNCTION paid_amount_this_run (p_assignment_action_id  IN   pay_assignment_actions.assignment_action_id%TYPE) RETURN NUMBER
  IS
    l_paid_amount_this_run    NUMBER;
  BEGIN
    l_paid_amount_this_run := 0;
    l_paid_amount_this_run := get_wg_paid_amount(p_assignment_action_id, NULL, '_ASG_RUN' );
    if g_debug then
	    hr_utility.trace('total_paid_amount_this_run : '||to_char(l_paid_amount_this_run));
    end if;
    return l_paid_amount_this_run;
  EXCEPTION
    WHEN OTHERS THEN
       if g_debug then
      	 hr_utility.trace('Error Occured total_paid_amount_this_run');
       end if;
       raise;
  END paid_amount_this_run;
  --===========================================================================================
  ---------------------------------------------------------------------------------------------
  /*                        FUNCTION attachment_total_base                                   */
  ---------------------------------------------------------------------------------------------
  FUNCTION attachment_total_base (p_element_entry_id   IN   pay_element_entries_f.element_entry_id%TYPE
                                 ,p_effective_date     IN   DATE  DEFAULT NULL) RETURN NUMBER
  IS
    CURSOR csr_attachment_base (p_date    DATE)
    IS
       select sum(nvl(peev.screen_entry_value, 0)) attachment_base
         from pay_element_entries_f       pee
             ,pay_element_entry_values_f  peev
             ,pay_input_values_f          piv
             ,pay_element_types_f         pet
             ,pay_element_links_f         pel
        where pee.element_entry_id    = p_element_entry_id
          and pee.entry_type          = 'E'
          and peev.element_entry_id   = pee.element_entry_id
          and piv.input_value_id      = peev.input_value_id
          and pet.element_type_id     = piv.element_type_id
          and piv.name               in ('Principal Base', 'Court Fee Base', 'Interest Base')
          and pet.element_name        ='Wage Garnishments'
          and pet.legislation_code    = 'KR'
          and pel.element_link_id     = pee.element_link_id
          and pel.element_type_id     = pet.element_type_id
          and p_date between pee.effective_start_date and pee.effective_end_date
          and p_date between peev.effective_start_date and peev.effective_end_date
          and p_date between piv.effective_start_date and piv.effective_end_date
          and p_date between pel.effective_start_date and pel.effective_end_date;
    l_attachment_total_base  NUMBER ;
    l_effective_date         DATE;
  BEGIN
    l_attachment_total_base  :=  0;
    IF p_effective_date IS NULL THEN
       l_effective_date := g_effective_date;
    ELSE
       l_effective_date := p_effective_date;
    END IF;
    OPEN csr_attachment_base (l_effective_date);
    FETCH csr_attachment_base INTO l_attachment_total_base;
    CLOSE csr_attachment_base;
    if g_debug then
	    hr_utility.trace('attachment_total_base : '||to_char(l_attachment_total_base));
    end if;
    return nvl(l_attachment_total_base, 0);
  EXCEPTION
    WHEN OTHERS THEN
      if g_debug then
   	   hr_utility.trace('Error Occured in attachment_total_base');
      end if;
       raise;
  END attachment_total_base;
  --===========================================================================================
  ---------------------------------------------------------------------------------------------
  /*                        FUNCTION real_attachment_total                                   */
  ---------------------------------------------------------------------------------------------
  FUNCTION real_attachment_total (p_assignment_id      IN   per_assignments_f.assignment_id%TYPE
                                 ,p_element_entry_id   IN   pay_element_entries_f.element_entry_id%TYPE
                                 ,p_effective_date     IN   DATE   DEFAULT NULL) RETURN NUMBER
  IS
    l_attachment_base        NUMBER ;
    l_total_interest_paid    NUMBER ;
    l_real_attachment_total  NUMBER ;
  BEGIN
    l_attachment_base := 0;
    l_total_interest_paid := 0;
    l_real_attachment_total := 0;
    l_attachment_base       := attachment_total_base (p_element_entry_id, p_effective_date);
    l_total_interest_paid   := paid_interest (p_assignment_id, p_element_entry_id, p_effective_date);
    l_real_attachment_total := l_attachment_base + l_total_interest_paid;
    if g_debug then
	    hr_utility.trace('Real Attachment Total : '||to_char(l_real_attachment_total));
    end if;
    return l_real_attachment_total;
  EXCEPTION
    WHEN OTHERS THEN
      if g_debug then
      	hr_utility.trace('Error Ocured in real_attachment_total');
      end if;
      raise;
  END real_attachment_total;
  --===========================================================================================
  ---------------------------------------------------------------------------------------------
  /*                                FUNCTION unpaid_debt                                     */
  ---------------------------------------------------------------------------------------------
  FUNCTION unpaid_debt (p_assignment_id      IN   per_assignments_f.assignment_id%TYPE
                       ,p_element_entry_id   IN   pay_element_entries_f.element_entry_id%TYPE
                       ,p_effective_date     IN   DATE   DEFAULT NULL ) RETURN NUMBER
  IS
    l_unpaid_debt             NUMBER;
    l_assignment_action_id    pay_assignment_actions.assignment_action_id%TYPE;
  BEGIN
    l_unpaid_debt := 0;
    IF processing_type   (p_element_entry_id) = 'P' AND Obligation_exists (p_element_entry_id, p_effective_date)
    THEN
       RETURN 0;
    END IF;
    l_assignment_action_id := get_max_asg_action_id (p_assignment_id, p_effective_date);
    l_unpaid_debt:= real_attachment_total(p_assignment_id      =>    p_assignment_id
                                         ,p_element_entry_id   =>    p_element_entry_id
                                         ,p_effective_date     =>    p_effective_date)
                 -
                    paid_amount(p_assignment_id, p_element_entry_id, p_effective_date);
    if g_debug then
   	 hr_utility.trace('Unpaid Debt : '||to_char(l_unpaid_debt));
    end if;
    return l_unpaid_debt;
  EXCEPTION
    WHEN OTHERS THEN
      if g_debug then
      	hr_utility.trace('End Of unpaid_debt');
      end if;
      raise;
  END unpaid_debt;
  --===============================================================================================
  -------------------------------------------------------------------------------------------------
  /*                   FUNCTION paid_amount (for single creditor)                                */
  -------------------------------------------------------------------------------------------------
  FUNCTION paid_amount (p_assignment_id       IN   per_assignments_f.assignment_id%TYPE
                       ,p_element_entry_id    IN   pay_element_entries_f.element_entry_id%TYPE
                       ,p_effective_date      IN   DATE  DEFAULT NULL ) RETURN NUMBER
  IS
    l_paid_amount              NUMBER ;
    l_processing_type          VARCHAR2(10);
    l_prev_case_att_seq_no     VARCHAR2(100);
    l_assignment_action_id     NUMBER;
    l_attachment_seq_no        VARCHAR2(100);
  BEGIN
    l_paid_amount := 0;
    l_assignment_action_id := get_max_asg_action_id (p_assignment_id, p_effective_date);
    l_processing_type      := processing_type (p_element_entry_id);
    l_attachment_seq_no    := get_attach_seq_no (p_element_entry_id);
    IF l_processing_type = 'P' AND Obligation_exists (p_element_entry_id, p_effective_date) THEN
       l_paid_amount := 0;
    ELSIF l_processing_type IN ('AS', 'AA') THEN
       l_prev_case_att_seq_no := prev_case_attachment_seq_no (p_element_entry_id);
       l_paid_amount := get_wg_paid_amount (l_assignment_action_id, l_prev_case_att_seq_no, '_ASG_WG_ITD');
       l_paid_amount := l_paid_amount
		     +  get_wg_paid_amount (l_assignment_action_id, l_attachment_seq_no, '_ASG_WG_ITD' );
    ELSE
       l_paid_amount := get_wg_paid_amount (l_assignment_action_id, l_attachment_seq_no, '_ASG_WG_ITD');
    END IF;
    if g_debug then
   	 hr_utility.trace('l_paid_amount : '||to_char(l_paid_amount));
    end if;
    return l_paid_amount;
  EXCEPTION
     WHEN OTHERS THEN
       if g_debug then
  	     hr_utility.trace('Error occured in paid_amount to single Creditor');
       end if;
       raise;
  END paid_amount;
  --===============================================================================================
  -------------------------------------------------------------------------------------------------
  /*                FUNCTION paid_interest_this_run (for single creditor)                        */
  -------------------------------------------------------------------------------------------------
  FUNCTION paid_interest_this_run (p_assignment_action_id    IN   pay_assignment_actions.assignment_action_id%TYPE
                                  ,p_element_entry_id        IN   pay_element_entries_f.element_entry_id%TYPE) RETURN NUMBER
  IS
    Cursor csr_interest
    IS
      Select  prrv.result_value
        from  pay_run_result_values prrv
             ,pay_input_values_f    piv
             ,pay_run_results       prr
	     ,pay_element_types_f pet
       where  prr.source_id            = p_element_entry_id
         and  prr.assignment_action_id = p_assignment_action_id
         and  prr.run_result_id        = prrv.run_result_id
         and  prrv.input_value_id      = piv.input_value_id
         and  piv.name                 = 'Interest This Period'
         and  piv.legislation_code     = 'KR'
	 and  prr.element_type_id      =  pet.element_type_id
	 and  pet.element_name         = 'WG Results'
	 and  pet.legislation_code     = 'KR'
         and  g_effective_date between piv.effective_start_date and piv.effective_end_date
	 and  g_effective_date between pet.effective_start_date and pet.effective_end_date;
    l_interest_paid_this_run   NUMBER ;
  BEGIN
    l_interest_paid_this_run   := 0;
    OPEN  csr_interest;
    FETCH csr_interest INTO l_interest_paid_this_run;
    CLOSE csr_interest;
    if g_debug then
	    hr_utility.trace('paid_interest_this_run to a creditor '||to_char(p_element_entry_id)||' is  :'||to_char(l_interest_paid_this_run));
    end if;
    return l_interest_paid_this_run;
  EXCEPTION
    WHEN OTHERS THEN
      if g_debug then
  	    hr_utility.trace('Error Ocured in paid_interest_this_run to a creditor');
      end if;
      raise;
  END paid_interest_this_run;
  --================================================================================================
  -------------------------------------------------------------------------------------------------
  /*                FUNCTION paid_interest_this_run (for all creditors)                          */
  -------------------------------------------------------------------------------------------------
  FUNCTION paid_interest_this_run (p_assignment_action_id   IN   pay_assignment_actions.assignment_action_id%TYPE) RETURN NUMBER
  IS
    l_paid_interest_to_all   NUMBER;
  BEGIN
    l_paid_interest_to_all := 0;
    l_paid_interest_to_all := get_wg_interest_paid (p_assignment_action_id, NULL, '_ASG_RUN' );
    if g_debug then
	    hr_utility.trace('l_paid_interest_to_all : '||to_char(l_paid_interest_to_all));
    end if;
    return l_paid_interest_to_all;
  EXCEPTION
    WHEN OTHERS THEN
     if g_debug then
  	    hr_utility.trace('Error Ocured in paid_interest_this_run to all creditors');
      end if;
       raise;
  END paid_interest_this_run;
  --====================================================================================================
  -------------------------------------------------------------------------------------------------
  /*                   FUNCTION paid_interest (for single creditor)                              */
  -------------------------------------------------------------------------------------------------
  FUNCTION paid_interest (p_assignment_id     IN   per_assignments_f.assignment_id%TYPE
                         ,p_element_entry_id  IN   pay_element_entries_f.element_entry_id%TYPE
                         ,p_effective_date    IN   DATE   DEFAULT   NULL) RETURN NUMBER
  IS
    l_paid_interest          NUMBER;
    l_assignment_action_id   NUMBER;
    l_attachment_seq_no      VARCHAR2(100);
  BEGIN
    l_paid_interest := 0;
    l_assignment_action_id := get_max_asg_action_id (p_assignment_id, p_effective_date);
    l_attachment_seq_no    := get_attach_seq_no (p_element_entry_id);
    l_paid_interest        := get_wg_interest_paid (l_assignment_action_id, l_attachment_seq_no, '_ASG_WG_ITD');
    --
    if g_debug then
	    hr_utility.trace('Total Interest paid to the creditor '||to_char(p_element_entry_id)||' is : '||to_char(l_paid_interest));
    end if;
    return l_paid_interest;
  EXCEPTION
    WHEN OTHERS THEN
      if g_debug then
    	  hr_utility.trace('Error Occured in paid_interest to a creditors');
      end if;
       raise;
  END paid_interest;
  --====================================================================================================
BEGIN
  DECLARE
    CURSOR csr_eff_date
    IS
      Select ses.effective_date
      from   fnd_sessions ses
      Where  ses.session_id = userenv('sessionid');
    CURSOR csr_sysdate
    IS
      Select sysdate
      from   dual;
  BEGIN
    OPEN  csr_eff_date;
    FETCH csr_eff_date INTO g_effective_date;
    IF csr_eff_date%NOTFOUND THEN
       OPEN  csr_sysdate;
       FETCH csr_sysdate INTO g_effective_date;
       CLOSE csr_sysdate;
    END IF;
    CLOSE csr_eff_date;
  END;
END pay_kr_wg_report_pkg;

/
