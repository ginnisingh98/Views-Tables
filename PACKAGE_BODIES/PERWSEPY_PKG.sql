--------------------------------------------------------
--  DDL for Package Body PERWSEPY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PERWSEPY_PKG" AS
/* $Header: pepyppkg.pkb 120.5 2008/03/17 09:24:28 schowdhu noship $ */
--------------------------------------------------------------------------

--------------------------------------------------------------------------
g_package  varchar2(33)        := '  PERWSEPY_PKG.';  -- Global package name
---------------------------------------------------------------------------


/* Procedure to check the format of amounts */
  PROCEDURE CHECK_LENGTH(p_amount        IN OUT NOCOPY NUMBER
                        ,p_uom           IN     VARCHAR2
                        ,p_currcode      IN     VARCHAR2) IS

  L_PRECISION NUMBER;
  L_EXT_PRECISION NUMBER;
  L_MIN_ACCT_UNIT NUMBER;

  l_proc VARCHAR2(100):='PERWSEPY.PKG.CHECK_FORMAT';
  BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  if(p_uom='M') then
    hr_utility.set_location(l_proc, 10);
    fnd_currency.get_info(currency_code => p_currcode
                         ,precision     => L_PRECISION
                         ,EXT_PRECISION => L_EXT_PRECISION
                         ,MIN_ACCT_UNIT => L_MIN_ACCT_UNIT);
    hr_utility.set_location(l_proc, 20);
    p_amount:=round(p_amount,l_precision);
  else
    hr_utility.set_location(l_proc, 30);
    p_amount:=round(p_amount,5);
  end if;
  END CHECK_LENGTH;
--------------------------------------------------------------------------
/* Procedure for calculating the change in percents and amounts and
   new totals depending on which inputs it gets. Also calculates the
   multi components flag. */

  PROCEDURE CALCULATE_PERCENTS_P (p_change_amount IN OUT NOCOPY NUMBER,
                                  p_change_percent IN OUT NOCOPY NUMBER,
                                  p_old_amount IN NUMBER,
                                  p_new_amount IN OUT NOCOPY NUMBER,
                                  p_multi_components IN OUT NOCOPY VARCHAR2,
                                  p_components VARCHAR2) IS


  BEGIN
--
-- if all amounts are null then set the multi components flag to null
--
    IF (p_change_percent IS NULL)
       AND (p_change_amount IS NULL)
       AND (p_new_amount IS NULL) THEN
      p_multi_components:=null;
    ELSE
-- /* Moved to here from below for bug 4424532*/
-- if the components are null or open then set them to the desired value
--
    IF (nvl(p_multi_components,'O') = 'O') THEN
        p_multi_components:=p_components;
    END IF;

--
-- if change amount and new amount are null then calculate them based on
-- the change percent and old amount
--
    IF (p_change_amount IS NULL) and (p_new_amount IS NULL) THEN
      p_change_percent:=round(p_change_percent,3);  			 -- 5554418
      p_change_amount:=nvl(p_old_amount,0)*p_change_percent/100;
      p_new_amount:=nvl(p_old_amount,0)+p_change_amount;
--
-- if the change percent and new amount are null then calculate them based on
-- the change amount and old amount
--
    ELSIF (p_change_percent IS NULL) AND
          (p_new_amount IS NULL) THEN
      p_new_amount:=nvl(p_old_amount,0)+p_change_amount;
      p_change_percent:=round(100*p_change_amount/nvl(p_old_amount,0),3);  -- 5554418
--
-- if the change amount and change percent are null then calculate them based on
-- the old amount and the new amount
--
    ELSIF (p_change_amount IS NULL) AND
          (p_change_percent IS NULL) THEN
       p_change_amount:=p_new_amount-nvl(p_old_amount,0);
       p_change_percent:=round(100*p_change_amount/nvl(p_old_amount,0),3);  -- 5554418
--
-- in any other circumstances we have inputed wrong values
--
    ELSE
      null; -- ADD SOME ERROR
    END IF;

   END IF;

  EXCEPTION
    WHEN ZERO_DIVIDE THEN NULL;
  END CALCULATE_PERCENTS_P;
------------------------------------------------------------------------------
/* component_amount_p will calculate the new percentage change of a
  component for a given new amount. The new total will be calculated
   elsewhere to stop a loop from WHEN-VALIDTAE-ITEM triggers from
   change amount and change percent.
   Multiple components is not set by this, but by MEANING. */


  PROCEDURE COMPONENT_AMOUNT_P (p_change_amount  IN OUT NOCOPY NUMBER
                               ,p_old_amount     IN     NUMBER
                               ,p_uom            IN     VARCHAR2
                               ,p_currcode       IN     VARCHAR2
                               ,p_change_percent    OUT NOCOPY NUMBER) IS


  l_percent NUMBER;
  l_new     NUMBER;
  l_change  NUMBER;
  l_dummy   VARCHAR2(255);

  BEGIN

    l_percent := NULL;
    l_new := NULL;
    l_change:=p_change_amount;

    CALCULATE_PERCENTS_P(l_change,
                       l_percent,
                       p_old_amount,
                       l_new,
                       l_dummy,
                       'Y');

    CHECK_LENGTH(l_change
                ,p_uom
                ,p_currcode);

    p_change_amount:=l_change;
    p_change_percent:=l_percent;

  END COMPONENT_AMOUNT_P;

----------------------------------------------------------
/* component_percent_p will calculate the new change amount of a
   component for a given percentage change if the form status is CHANGED.
   The new total will be calculated elsewhere to stop a loop from
   WHEN-VALIDTAE-ITEM triggers from change amount and change percent
   Multiple components is not set by this, but by MEANING */

  PROCEDURE COMPONENT_PERCENT_P  (p_change_percent IN OUT NOCOPY number
                                 ,p_old_amount     IN     NUMBER
                                 ,p_change_amount     OUT NOCOPY number
                                 ,p_status         IN     VARCHAR2
                                 ,p_uom            IN     VARCHAR2
                                 ,p_currcode       IN     VARCHAR2) IS

  l_change  NUMBER;
  l_new     NUMBER;
  l_percent NUMBER;
  l_dummy   VARCHAR2(255);

  BEGIN

    IF (p_status<>'NEW') THEN
    l_new := NULL;
    l_change:=NULL;
    l_percent:=p_change_percent;

    CALCULATE_PERCENTS_P (      l_change,
                                l_percent,
                                p_old_amount,
                                l_new,
                                l_dummy,
                                'Y');
    CHECK_LENGTH(l_change
                ,p_uom
                ,p_currcode);

/*    l_percent:=null;
    l_new:=null;
    CALCULATE_PERCENTS_P (      l_change,
                                l_percent,
                                p_old_amount,
                                l_new,
                                l_dummy,
                                'Y');*/
    p_change_amount:=l_change;
    p_change_percent:=l_percent;
  END IF;

  END COMPONENT_PERCENT_P;
----------------------------------------------------------
/* verifies that the new salary lies withing the range allowed by the
   grade if it exists. The formatted output of the proposed salary
   is ignored. Should be taken care of by the forms formatting.
   calculates the change amount and change percent given a new amount */

  PROCEDURE PROPOSED_SALARY_P (p_pay_proposal_id       IN     NUMBER
                              ,p_business_group_id     IN     NUMBER
                              ,p_assignment_id         IN     NUMBER
                              ,p_change_date           IN     DATE
                              ,p_proposed_salary       IN OUT NOCOPY NUMBER
                              ,p_object_version_number IN     NUMBER
                              ,p_old_amount            IN     NUMBER
                              ,p_uom                   IN     VARCHAR2
                              ,p_currcode              IN     VARCHAR2
                              ,p_components            IN OUT NOCOPY VARCHAR2
                              ,p_change_amount            OUT NOCOPY NUMBER
                              ,p_change_percent           OUT NOCOPY NUMBER) IS


  l_change NUMBER;
  l_percent NUMBER;
  l_new NUMBER;
  l_proposed_salary NUMBER;
  l_comps VARCHAR2(1);
  l_proposed_salary_warning BOOLEAN;
  p_multiple_components VARCHAR2(1);

  BEGIN

    l_change:=null;
    l_percent:=null;
    l_comps:=p_components;
    l_proposed_salary:=p_proposed_salary;

    per_pyp_bus.chk_proposed_salary
        (p_pay_proposal_id         => p_pay_proposal_id
        ,p_business_group_id       => p_business_group_id
        ,p_assignment_id           => p_assignment_id
        ,p_change_date             => p_change_date
        ,p_proposed_salary_n       => l_proposed_salary
        ,p_object_version_number   => p_object_version_number
        ,p_proposed_salary_warning => l_proposed_salary_warning
 -- schowdhu 17-mar-2008 p_proposed_salary_n changed to include
 -- p_multiple_components
        ,p_multiple_components => p_multiple_components);


    CALCULATE_PERCENTS_P (l_change,
                          l_percent,
                          p_old_amount,
                          l_proposed_salary,
                          l_comps,
                          'N');
    CHECK_LENGTH(l_change
                ,p_uom
                ,p_currcode);

    p_change_amount:=l_change;
    p_change_percent:=l_percent;
    p_components:=l_comps;
    p_proposed_salary:=l_proposed_salary;

  END PROPOSED_SALARY_P;
----------------------------------------------------------
/* calculates change percent and new amount from a given change amount */

  PROCEDURE CHANGE_AMOUNT_P (p_change_amount IN OUT NOCOPY number
                            ,p_old_amount    IN     NUMBER
                            ,p_components    IN OUT NOCOPY VARCHAR2
                            ,p_uom           IN     VARCHAR2
                            ,p_currcode      IN     VARCHAR2
                            ,p_new_amount       OUT NOCOPY number
                            ,p_change_percent   OUT NOCOPY number) IS

  l_change NUMBER;
  l_percent NUMBER;
  l_new NUMBER;
  l_comps VARCHAR2(1);
  BEGIN

    l_change:=p_change_amount;
    l_percent:=null;
    l_new:=null;
    l_comps:=p_components;
    CALCULATE_PERCENTS_P (l_change,
                          l_percent,
                          p_old_amount,
                          l_new,
                          l_comps,
                          'N');
    CHECK_LENGTH(l_change
                ,p_uom
                ,p_currcode);
    p_change_amount:=l_change;

    CHECK_LENGTH(l_new
                ,p_uom
                ,p_currcode);
    p_new_amount:=l_new;

    p_change_percent:=l_percent;
    p_components:=l_comps;

  END CHANGE_AMOUNT_P;
----------------------------------------------------------
/* calculates the change amount and new total from a given change percent */

  PROCEDURE CHANGE_PERCENT_P (p_change_percent IN OUT NOCOPY number
                             ,p_old_amount     IN     NUMBER
                             ,p_components     IN OUT NOCOPY VARCHAR2
                             ,p_uom            IN     VARCHAR2
                             ,p_currcode       IN     VARCHAR2
                             ,p_new_amount        OUT NOCOPY number
                             ,p_change_amount     OUT NOCOPY number) IS

  l_change NUMBER;
  l_percent NUMBER;
  l_new NUMBER;
  l_comps VARCHAR2(1);

  BEGIN

  if (p_old_amount is not null) THEN
    l_change:=null;
    l_percent:=p_change_percent;
    l_new:=null;
    l_comps:=p_components;

    CALCULATE_PERCENTS_P (l_change,
                          l_percent,
                          p_old_amount,
                          l_new,
                          l_comps,
                          'N');

    CHECK_LENGTH(l_change
                ,p_uom
                ,p_currcode);
    p_change_amount:=l_change;

    CHECK_LENGTH(l_new
                ,p_uom
                ,p_currcode);
    p_new_amount:=l_new;
   /* l_percent:=null;
    l_change:=null;

    CALCULATE_PERCENTS_P (l_change,
                          l_percent,
                          p_old_amount,
                          l_new,
                          l_comps,
                          'N');*/
    p_change_percent:=l_percent;
    p_components:=l_comps;
  end if;
  END CHANGE_PERCENT_P;
---------------------------------------------------------------------
--------------------------------------------------------------------------------------
/* Following procedure has been copied from per_pyp_bus.
   Some of the restrictions has been commented in per_pyp_bus as enhancement in FPKRUP.
   This need to be restriced for the old Salary Form.
   Change made by abhshriv
*/

procedure chk_assignment_id_change_date
  (p_pay_proposal_id            in      per_pay_proposals.pay_proposal_id%TYPE
  ,p_business_group_id          in      per_pay_proposals.business_group_id%TYPE
  ,p_assignment_id		in 	per_pay_proposals.assignment_id%TYPE
  ,p_change_date		in	per_pay_proposals.change_date%TYPE
  ,p_payroll_warning	 out nocopy     boolean
  ,p_object_version_number	in	per_pay_proposals.object_version_number%TYPE
  )
  is
--
   l_exists		varchar2(1);
   l_proc               varchar2(72)  :=  g_package||'chk_assignment_id_change_date';
   l_change_date                  per_pay_proposals.change_date%TYPE;

   --
   -- Cursor to check the latest proposal change_date for the assignment.
   --
     cursor csr_last_change_date is
     select max(change_date)
     from   per_pay_proposals
     where  assignment_id = p_assignment_id
     and    business_group_id + 0 = p_business_group_id
     and    pay_proposal_id<>nvl(p_pay_proposal_id,-1);
   --
   -- Cursor to check whether other proposals exist.
   --
    Cursor csr_other_proposals_exist is
    select null
    from   per_pay_proposals
    where  assignment_id        = p_assignment_id
    and    approved = 'N'
    and    pay_proposal_id<>nvl(p_pay_proposal_id,-1);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

    -- The following is commented out in PER_PPC_BUS api as enhancement in FPKRUP.
	-- New Salary proposals can be added even if future proposals exist.
	-- This need to be restriced for the old Salary Form.
	-- Change made by abhshriv

         open csr_last_change_date;
         fetch csr_last_change_date into l_change_date;
         if csr_last_change_date%notfound then
            hr_utility.set_location(l_proc, 35);
            --
         elsif
            l_change_date > p_change_date then
            hr_utility.set_location(l_proc, 40);
            close csr_last_change_date;
            hr_utility.set_message(801,'HR_7293_SAL_FUTURE_APPS_EXIST');
            hr_utility.raise_error;
            --
         end if;
         close csr_last_change_date;

    -- The following is commented out in PER_PPC_BUS api as relaxation in FPKRUP.
    -- There can be more than one Unapproved Proposal now
	-- This need to be restriced for the old Salary Form.
	-- Change made by abhshriv

         open csr_other_proposals_exist;
         fetch csr_other_proposals_exist into l_exists;
         if csr_other_proposals_exist%notfound then
            hr_utility.set_location(l_proc, 45);
            close  csr_other_proposals_exist;
            --
         else
            close  csr_other_proposals_exist;
            hr_utility.set_location(l_proc, 50);
            hr_utility.set_message(801, 'HR_7294_SAL_ONLY_ONE_PROPOSAL');
            hr_utility.raise_error;
         end if;

    -- The following is commented out in PER_PPC_BUS api as relaxation in FPKRUP.
    -- The new salary proposal need not have the change_date equals to the
    -- Salary Basis change date.
    -- This need to be restriced for the old Salary Form.
	-- Change made by abhshriv.

       chk_pay_basis_change_date (p_assignment_id,p_change_date);
       hr_utility.set_location(l_proc, 61);

  hr_utility.set_location('Leaving: ' || l_proc, 65);
end chk_assignment_id_change_date;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
/* Following procedure has been copied from per_pyp_bus.
   Some of the restrictions has been commented in per_pyp_bus as enhancement in FPKRUP.
   This need to be restriced for the old Salary Form.
   Change made by abhshriv
*/

procedure  chk_pay_basis_change_date
              (p_assignment_id  in  per_pay_proposals.assignment_id%TYPE
              ,p_change_date    in  per_pay_proposals.change_date%TYPE
) is
--
-- Cursor to check that whether there are any pay_basis changes after
-- the change_date
--
cursor csr_asg_pay_bases is
select null
from   per_all_assignments_f asg1
where  assignment_id    = p_assignment_id
and    exists (select null
       from   per_all_assignments_f asg2
       where  asg2.assignment_id  = p_assignment_id
       and    asg1.pay_basis_id +0  <> asg2.pay_basis_id
       and    asg2.effective_start_date > p_change_date
       and    asg1.effective_end_date  >= p_change_date);
--
--
l_exists		varchar2(1);
l_proc     varchar2(72) := g_package||'chk_pay_basis_change_date';
--
begin
  --
  hr_utility.set_location('Entering: ' || l_proc,1);
  --
  --

  -- The validation for future pay basis changes has been commented in
  -- PER_PYP_BUS.chk_pay_basis_change_date().
  -- To enable it from the form that part of the code is copied here.
  -- Rest of the validation is done in PER_PYP_BUS.
  -- Change made by abhshriv

  PER_PYP_BUS.chk_pay_basis_change_date(p_assignment_id,p_change_date);

  open csr_asg_pay_bases;
  fetch csr_asg_pay_bases into l_exists;
  if csr_asg_pay_bases%found then
     --
     -- raise an error if there future pay_basis change in the assignment.
     --
     close csr_asg_pay_bases;
     hr_utility.set_location(l_proc,30);
     hr_utility.set_message(801,'HR_51718_PYP_FUTU_PAY_BAS_CHG');
     hr_utility.raise_error;
  else
     close csr_asg_pay_bases;
     hr_utility.set_location(l_proc,31);
  end if;


  hr_utility.set_location('Leaving: ' ||l_proc,35);
--
end chk_pay_basis_change_date;
--------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
/* Following procedure has been copied from per_pyp_bus.
   Some of the restrictions has been commented in per_pyp_bus as enhancement in FPKRUP.
   This need to be restriced for the old Salary Form.
   Change made by abhshriv
*/
procedure chk_del_pay_proposal
  (p_pay_proposal_id       in  per_pay_proposals.pay_proposal_id%TYPE
  ,p_object_version_number in  per_pay_proposals.object_version_number%TYPE
  ,p_salary_warning        out nocopy boolean
  ) is
--
   l_proc                     varchar2(72):= g_package||'chk_del_pay_proposal';
   l_exists                   varchar2(1);
   l_proposed_salary          per_pay_proposals.proposed_salary_n%TYPE;
   l_last_change_date         per_pay_proposals.change_date%TYPE;
   l_assignment_id            per_pay_proposals.assignment_id%TYPE;
   l_business_group_id  per_pay_proposals.business_group_id%TYPE;
   l_change_date	per_pay_proposals.change_date%TYPE;
   l_approved           per_pay_proposals.approved%TYPE;
   l_multiple_components  per_pay_proposals.multiple_components%TYPE;
--
   --
   -- Define a cursor to get the proposals change date
   --
   cursor csr_get_pro_detail is
   select assignment_id,business_group_id,change_date,
	  multiple_components,approved
   from   per_pay_proposals
   where  pay_proposal_id = p_pay_proposal_id
   and    object_version_number = p_object_version_number;
   --
   -- Define a cursor which gets the latest approved salary_proposal.
   --
   Cursor csr_is_latest_proposal is
   select max(change_date)
   from   per_pay_proposals
   where  assignment_id = l_assignment_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- get the proposal details first.
  --
  open csr_get_pro_detail;
  fetch csr_get_pro_detail into l_assignment_id,l_business_group_id,
        l_change_date,l_multiple_components, l_approved;
  if    csr_get_pro_detail%notfound then
        close csr_get_pro_detail;
	hr_utility.set_location(l_proc, 2);
	per_pyp_shd.constraint_error('PER_PAY_PROPOSALS_PK');
  end if;
  close csr_get_pro_detail;

  -- Check that, this is the latest salary proposal
  -- i.e. Only the latest salary proposal can be deleted.
  --
  open  csr_is_latest_proposal;
  fetch csr_is_latest_proposal into l_last_change_date;
  if  csr_is_latest_proposal%notfound then
      hr_utility.set_location(l_proc,5);
      close csr_is_latest_proposal;
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
  elsif (l_change_date < l_last_change_date) then
      --
      -- raise an error. You can only delete the latest proposal
      --
      hr_utility.set_location(l_proc,10);
      close csr_is_latest_proposal;
      hr_utility.set_message(801, 'HR_7292_SAL_NOT_LATEST_SAL_REC');
      hr_utility.raise_error;
  end if;
  close csr_is_latest_proposal;

  hr_utility.set_location('Leaving: ' ||l_proc, 55);

end chk_del_pay_proposal;
-------------------------------------------------------------------------------
/* Following procedure has been copied from per_ppc_bus.
   Some of the restrictions has been commented in per_ppc_bus as enhancement in FPKRUP.
   This need to be restricted for the old Salary Form.
   Change made by abhshriv
*/

procedure chk_delete_component
   (p_component_id
   in	  per_pay_proposal_components.component_id%TYPE
   ) is
--
  l_exists	varchar2(1);
  l_proc	varchar2(72):= g_package || 'chk_delete_component';
  l_pay_proposal_id 	per_pay_proposals.pay_proposal_id%TYPE;
  --
  -- Cursor to check the status of the per_pay-proposal apprved flag.
  --
  cursor csr_proposal_status is
  select null
  from   per_pay_proposals pro
  where  pro.pay_proposal_id = l_pay_proposal_id
  and    pro.approved	     = 'Y';
  --
  -- Cursor to check that this component exists for this proposal
  --
  Cursor csr_comp_exists is
  select pay_proposal_id
  from   per_pay_proposal_components  comp
  where  comp.component_id = p_component_id;
  --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check that the component exists and get the proposal
  --
  open csr_comp_exists;
  fetch csr_comp_exists into l_pay_proposal_id;
  if csr_comp_exists%notfound then
     close csr_comp_exists;
     hr_utility.set_location(l_proc, 2);
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  close csr_comp_exists;
  --
  -- Check that the proposal is not already approved.
  --
  open csr_proposal_status;
  fetch csr_proposal_status into l_exists;
  if csr_proposal_status%notfound then
     hr_utility.set_location(l_proc, 2);
     close csr_proposal_status;
  else
     hr_utility.set_location(l_proc, 3);
     close csr_proposal_status;
    hr_utility.set_message(801,'HR_51315_PPC_CANT_DEL_RECORD');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location ('Leaving: ' || l_proc, 4);
  --
end chk_delete_component;

-------------------------------------------------------------------------------



/* validates the new review date and populates the grade
   and next review date */

  PROCEDURE CHANGE_DATE_P    (p_pay_proposal_id IN NUMBER
                             ,p_business_group_id IN NUMBER
                             ,p_assignment_id IN NUMBER
                             ,p_change_date IN DATE
                             ,p_next_sal_review_date IN OUT NOCOPY DATE
                             ,p_object_version_number IN NUMBER
                             ,p_payroll_warning OUT NOCOPY BOOLEAN
                             ,p_inv_next_sal_date_warning OUT NOCOPY BOOLEAN) IS

l_next_sal_review_date DATE default NULL;

  BEGIN

/*
The following procedure has been copied from per_pyp_bus to PERWSEPY_PKG.
The per_pyp_bus has relaxations for retro pay delivered in FPKRUP.
This need to be restriced for the old Salary Form.
Rest of the validations are done from per_pyp_bus.
Change made by abhshriv
*/
      chk_assignment_id_change_date
      (p_pay_proposal_id        => p_pay_proposal_id
      ,p_business_group_id      => p_business_group_id
      ,p_assignment_id          => p_assignment_id
      ,p_change_date            => p_change_date
      ,p_payroll_warning        => p_payroll_warning
      ,p_object_version_number  => p_object_version_number);



    per_pyp_bus.chk_assignment_id_change_date
      (p_pay_proposal_id        => p_pay_proposal_id
      ,p_business_group_id      => p_business_group_id
      ,p_assignment_id          => p_assignment_id
      ,p_change_date            => p_change_date
      ,p_payroll_warning        => p_payroll_warning
      ,p_object_version_number  => p_object_version_number);

    per_pyp_bus.chk_chg_next_sal_review_date
      (p_pay_proposal_id            => p_pay_proposal_id
      ,p_business_group_id          => p_business_group_id
      ,p_assignment_id              => p_assignment_id
      ,p_change_date                => p_change_date
      ,p_next_sal_review_date       => l_next_sal_review_date
      ,p_object_version_number      => p_object_version_number
      ,p_inv_next_sal_date_warning  => p_inv_next_sal_date_warning);

      p_next_sal_review_date:=l_next_sal_review_date;

  END CHANGE_DATE_P;
---------------------------------------------------------------------
/* validates the next performance review date. If none then derives it is appropriate */

  PROCEDURE NEXT_SAL_REVIEW_DATE_P(p_pay_proposal_id NUMBER
                                  ,p_business_group_id NUMBER
                                  ,p_assignment_id NUMBER
                                  ,p_change_date DATE
                                  ,p_next_sal_review_date IN OUT NOCOPY DATE
                                  ,p_object_version_number NUMBER
                                  ,p_inv_next_sal_date_warning OUT NOCOPY BOOLEAN) IS

    l_inv_next_sal_date_warning BOOLEAN;
    BEGIN


  per_pyp_bus.chk_chg_next_sal_review_date
      (p_pay_proposal_id            => p_pay_proposal_id
      ,p_business_group_id          => p_business_group_id
      ,p_assignment_id              => p_assignment_id
      ,p_change_date                => p_change_date
      ,p_next_sal_review_date       => p_next_sal_review_date
      ,p_object_version_number      => p_object_version_number
      ,p_inv_next_sal_date_warning  => p_inv_next_sal_date_warning);

  per_pyp_bus.chk_next_sal_review_date
      (p_pay_proposal_id            => p_pay_proposal_id
      ,p_business_group_id          => p_business_group_id
      ,p_assignment_id              => p_assignment_id
      ,p_change_date                => p_change_date
      ,p_next_sal_review_date       => p_next_sal_review_date
      ,p_object_version_number      => p_object_version_number
      ,p_inv_next_sal_date_warning  => p_inv_next_sal_date_warning);

  END NEXT_SAL_REVIEW_DATE_P;
---------------------------------------------------------
  PROCEDURE APPROVED_P(p_pay_proposal_id       IN     NUMBER
                      ,p_business_group_id     IN     NUMBER
                      ,p_assignment_id         IN     NUMBER
                      ,p_change_date           IN     DATE
                      ,p_proposed_salary       IN     NUMBER
                      ,p_object_version_number IN     NUMBER
                      ,p_approved              IN     VARCHAR2) IS

  l_approved_warning BOOLEAN;

  BEGIN

    per_pyp_bus.chk_approved
               (p_pay_proposal_id       => p_pay_proposal_id
               ,p_business_group_id     => p_business_group_id
               ,p_assignment_id         => p_assignment_id
               ,p_change_date           => p_change_date
               ,p_proposed_salary_n     => p_proposed_salary
               ,p_object_version_number => p_object_version_number
               ,p_approved              => p_approved
               ,p_approved_warning      => l_approved_warning);

/* don't do this approval because it only applies to commited items
    APPROVED_WARNING_P(l_approved_warning,p_accepted);*/

  END APPROVED_P;
---------------------------------------------------------
  PROCEDURE COMPONENT_APPROVED_P(p_component_id IN     NUMBER
                      ,p_approved              IN     VARCHAR2
                      ,p_component_reason      IN     VARCHAR2
                      ,p_change_amount         IN     NUMBER
                      ,p_change_percentage     IN     NUMBER
                      ,p_object_version_number IN     NUMBER) IS
  BEGIN

    per_ppc_bus.chk_approved
      (p_component_id          => p_component_id
      ,p_approved              => p_approved
      ,p_component_reason      => p_component_reason
      ,p_change_amount_n       => p_change_amount
      ,p_change_percentage     => p_change_percentage
      ,p_object_version_number => p_object_version_number);

  END COMPONENT_APPROVED_P;
--------------------------------------------------------------------
  PROCEDURE check_for_unaproved(p_assignment_id NUMBER
                               ,l_error         OUT NOCOPY BOOLEAN) IS

  cursor unaproved IS
  select null
  from per_pay_proposals_v2
  where assignment_id=p_assignment_id
  and approved='N';

  l_dummy NUMBER;

  BEGIN

  open unaproved;
  fetch unaproved into l_dummy;
  if unaproved%FOUND THEN
    l_error:=TRUE;
  else
    l_error:=FALSE;
  end if;
  close unaproved;
  END check_for_unaproved;
-----------------------------------------------------------------------------------------
  PROCEDURE CHECK_START_END_ASS_DATES(p_date          IN     DATE
                                     ,p_assignment_id IN     NUMBER
                                     ,p_start_ass_date_err OUT NOCOPY BOOLEAN
                                     ,p_end_ass_date_err   OUT NOCOPY BOOLEAN) IS

  cursor start_ass_date is
  select 1
  from   per_all_assignments_f paf
  where  paf.assignment_id=p_assignment_id
  and    p_date < (select min(paf2.effective_start_date)
                   from   per_all_assignments_f paf2
                   where  paf2.assignment_id=p_assignment_id);

  cursor end_ass_date is
  select 1
  from   per_all_assignments_f paf
  where  paf.assignment_id=p_assignment_id
  and    p_date > (select max(paf2.effective_end_date)
                   from   per_all_assignments_f paf2
                   where  paf2.assignment_id=p_assignment_id);
  l_dummy NUMBER;

  begin

  open start_ass_date;
  fetch start_ass_date into l_dummy;
  if (start_ass_date%FOUND) THEN
    close start_ass_date;
    p_start_ass_date_err:=TRUE;
  else
    close start_ass_date;
  end if;

  open end_ass_date;
  fetch end_ass_date into l_dummy;
  if (end_ass_date%FOUND) THEN
    close end_ass_date;
    p_end_ass_date_err:=TRUE;
  else
    close end_ass_date;
  end if;

  END CHECK_START_END_ASS_DATES;
---------------------------------------------------------

END PERWSEPY_PKG;

/
