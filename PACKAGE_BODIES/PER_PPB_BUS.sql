--------------------------------------------------------
--  DDL for Package Body PER_PPB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PPB_BUS" as
/* $Header: peppbrhi.pkb 120.0 2005/05/31 14:56:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ppb_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pay_basis_id                number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pay_basis_id                         in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_pay_bases ppb
     where ppb.pay_basis_id = p_pay_basis_id
       and pbg.business_group_id = ppb.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pay_basis_id'
    ,p_argument_value     => p_pay_basis_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'PAY_BASIS_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_pay_basis_id                         in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_pay_bases ppb
     where ppb.pay_basis_id = p_pay_basis_id
       and pbg.business_group_id = ppb.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pay_basis_id'
    ,p_argument_value     => p_pay_basis_id
    );
  --
  if ( nvl(per_ppb_bus.g_pay_basis_id, hr_api.g_number)
       = p_pay_basis_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_ppb_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    per_ppb_bus.g_pay_basis_id                := p_pay_basis_id;
    per_ppb_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_pay_basis_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pay_basis_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_pay_basis_id(p_pay_basis_id                     in number,
                           p_object_version_number            in number
                           ) is
  --
  l_proc         varchar2(72) := g_package||'chk_pay_basis_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_ppb_shd.api_updating
    (p_pay_basis_id                     => p_pay_basis_id,
     p_object_version_number            => p_object_version_number
   );
  --
  if (l_api_updating
     and nvl(p_pay_basis_id,hr_api.g_number)
     <>  per_ppb_shd.g_old_rec.pay_basis_id) then
    --
    -- raise error as PK has changed
    --
    per_ppb_shd.constraint_error('PER_PAY_BASES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pay_basis_id is not null then
      --
      -- raise error as PK is not null
      --
      per_ppb_shd.constraint_error('PER_PAY_BASES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  --
End chk_pay_basis_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------------<  chk_rate_id  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that RATE_ID in the PER_PAY_BASES table
--    exists for the record specified by RATE_ID.
--
--  Pre-conditions:
--    None.
--
--  In Arguments :
--    p_rate_id
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
procedure chk_rate_id
  (p_rate_id                      in      number,
   p_pay_basis_id		  in      number default null,
   p_object_version_number        in      number default null
  )     is
--
   l_proc          varchar2(72)    := g_package||'chk_rate_id';
   l_exists        varchar2(1);
   l_api_updating  boolean;
--
cursor csr_salary_basis is
  select 'x'
  from pay_rates
  where rate_id = p_rate_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
    --
    hr_utility.set_location(l_proc, 3);
    --
    open csr_salary_basis;
    	fetch csr_salary_basis into l_exists;
    if p_rate_id is not null then
 	  if csr_salary_basis%notfound then
 	    close csr_salary_basis;
 	 per_ppb_shd.constraint_error(p_constraint_name => 'PER_PAY_BASES_FK2');
    	  end if;

    close csr_salary_basis;
end if;
    --
  --
  hr_utility.set_location('Leaving '||l_proc, 4);
  --
end chk_rate_id;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------------<  chk_name  >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that NAME in the PER_PAY_BASES table
--    exists for the record specified by NAME.
--
--  Pre-conditions:
--    None.
--
--  In Arguments :
--    p_name
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
procedure chk_name
 (p_name                         in      varchar2,
  p_pay_basis_id                  in      number default null,
   p_business_group_id            in      number default null
  )     is
--
   l_proc          varchar2(72)    := g_package||'chk_name';
   l_exists        varchar2(2);
   l_api_updating  boolean;
--
cursor csr_name is
         select 'Y'
         from  per_pay_bases ppb
         where upper(ppb.name)     = upper(p_name)
         and ppb.business_group_id = p_business_group_id
--4154786
         and  ppb.pay_basis_id <> p_pay_basis_id
         ;
--
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
 hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'name',
      p_argument_value => p_name);
   --
   hr_utility.set_location(l_proc,10);
    OPEN csr_name;
      --
      FETCH csr_name INTO l_exists;
       hr_utility.set_location(l_proc,15);
      IF csr_name%FOUND THEN
         fnd_message.set_name('PAY' ,'HR_13017_SAL_BASIS_DUP_NAME');
         CLOSE csr_name;
         fnd_message.raise_error;
      END IF;
      CLOSE csr_name;
      --
      --
      hr_utility.set_location('Leaving:'||l_proc, 20);
      --
   end chk_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_pay_basis >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the manadatory key for the table
--   is setup properly.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pay_basis  pay_basis, which is in the hr_lookups.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_pay_basis(p_pay_basis                           in varchar2,
                        p_object_version_number               in number
                           ) is
  --
  l_proc         varchar2(72) := g_package||'chk_pay_basis';
  l_api_updating boolean;
  --
Begin
  --
   --
    hr_utility.set_location('Entering:'||l_proc, 10);

     hr_api.mandatory_arg_error
         (p_api_name       => l_proc,
          p_argument       => 'pay_basis',
          p_argument_value => p_pay_basis);

    --
    -- Only proceed with validation if :
    -- there is a pay basis being passed
    --
    IF  (p_pay_basis is not null) then
      --
      hr_utility.set_location(l_proc, 20);
      --
      -- Check that the reason type exists in HR_LOOKUPS
      --
      IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => sysdate
        ,p_lookup_type           => 'PAY_BASIS'
        ,p_lookup_code           => p_pay_basis) THEN
        --
        hr_utility.set_location(l_proc, 30);
        --
        fnd_message.set_name('PER', 'HR_PSF_INVALID_PAY_BASIS');
        hr_utility.raise_error;
        --
      END IF;
      --
    END IF;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);

End chk_pay_basis;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_pay_annualization_factor  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that pay_annualization_factor in the PER_PAY_BASES table
--    has a meanigful value
--
--  Pre-conditions:
--    None.
--
--  In Arguments :
--    p_pay_annualization_factor
--    p_pay_basis
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
procedure chk_pay_annualization_factor
  (p_pay_annualization_factor     in      number,
   p_pay_basis                    in      varchar2
   )     is
--
   l_proc          varchar2(72)    := g_package||'chk_pay_annualization_factor';
   l_exists        varchar2(1);
   l_api_updating  boolean;
--

--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  hr_utility.set_location(l_proc, 2);
  --
--4154786
--if p_pay_basis = 'PERIOD' then
   	if p_pay_annualization_factor is not null then
   	-- check to make sure the hours entered are valid
   	  if p_pay_annualization_factor > 8766 	or
   	     p_pay_annualization_factor < 0 then

   	      fnd_message.set_name('PAY','HR_51782_PPB_INVL_ANU_HOURS');
		fnd_message.raise_error;
          end if;
--        end if;
    else
    if p_pay_basis <> 'PERIOD' then
-- if p_pay_annualization_factor is not null then

--if p_pay_annualization_factor > 8766 or
--             p_pay_annualization_factor < 0 then
--
--             fnd_message.set_name('PAY','HR_51782_PPB_INVL_ANU_HOURS');
--              fnd_message.raise_error;
-- end if;
--  else

     hr_api.mandatory_arg_error
         (p_api_name       => l_proc,
          p_argument       => 'pay_annualization_factor',
          p_argument_value => p_pay_annualization_factor);
   end if;
end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 3);
  --
end chk_pay_annualization_factor;
--
--
--  ---------------------------------------------------------------------------
--  |------------------< chk_grade_annualization_factor  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that grade_annualization_factor in the PER_PAY_BASES table
--    has a meanigful value, if p_rate_basis is entered
--
--  Pre-conditions:
--    None.
--
--  In Arguments :
--    p_grade_annualization_factor
--    p_pay_basis
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
procedure chk_grade_annualization_factor
  (p_grade_annualization_factor     in      number,
   p_rate_basis                     in      varchar2
   )     is
--
   l_proc   varchar2(72)    := g_package||'chk_grade_annualization_factor';

--

--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  hr_utility.set_location(l_proc, 2);

if p_rate_basis is not null then
  --
  if p_rate_basis = 'PERIOD' then
    if p_grade_annualization_factor is not  null then
   	-- check to make sure the hours entered are valid
   	  if p_grade_annualization_factor > 8766 or
   	     p_grade_annualization_factor < 0 then
   	     fnd_message.set_name('PAY','HR_51782_PPB_INVL_ANU_HOURS');
	     fnd_message.raise_error;
          end if;
     end if;
  else
if p_grade_annualization_factor is not null then

  	if p_grade_annualization_factor > 8766 or
	                     p_grade_annualization_factor < 0 then

	                      fnd_message.set_name('PAY','HR_51782_PPB_INVL_ANU_HOURS');
	                        fnd_message.raise_error;
        end if;
     else
             hr_api.mandatory_arg_error
                 (p_api_name       => l_proc,
                  p_argument       => 'grade_annualization_factor',
                  p_argument_value => p_grade_annualization_factor);
  --
     --
     end if;
     --
   end if;
--
end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 3);
  --
end chk_grade_annualization_factor;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_input_value_id >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that one of the foreign keys for the table
--   is created properly.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   input_value_id FK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_input_value_id(p_input_value_id                in number,
			     p_business_group_id             in number,
                             p_object_version_number         in number,
                             p_legislation_code     in       varchar2
                           ) is

cursor csr_input_value is
select 'x'
from  pay_input_values_f piv,
      pay_element_types_f pet,
      pay_element_classifications pec
where piv.input_value_id = p_input_value_id
  and piv.element_type_id = pet.element_type_id
  and sysdate between pet.effective_start_date
  	          and pet.effective_end_date
  and (pet.business_group_id = p_business_group_id
      or  pet.business_group_id is null
      and pet.legislation_code = p_legislation_code)
  and pet.processing_type = 'R'
  and pet.closed_for_entry_flag = 'N'
  and pec.classification_id = pet.classification_id
  and pec.costing_debit_or_credit = 'D';
  --
  l_proc         varchar2(72) := g_package||'chk_input_value_id';
  l_exists       varchar2(1);
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

   hr_api.mandatory_arg_error
       (p_api_name       => l_proc,
        p_argument       => 'input_value_id',
        p_argument_value => p_input_value_id);

  hr_utility.set_location(l_proc, 10);
      --
      open csr_input_value;
          fetch csr_input_value into l_exists;

            if csr_input_value%notfound then
             fnd_message.set_name('PER','HR_52939_INVALID_INPUT_ID');
	      close csr_input_value;
	          fnd_message.raise_error;

           end if;

      close csr_input_value;
      --
    --
    hr_utility.set_location('Leaving '||l_proc, 15);

  --

End chk_input_value_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_rate_basis >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the manadatory key for the table
--   is setup properly.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pay_basis  pay_basis, which is in the hr_lookups.
--   rate_basis the value must exist in pay_basis lookup table
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_rate_basis(p_rate_basis				in varchar2,
                         p_pay_basis				in varchar2
                         ) is
  --
  l_proc         varchar2(72) := g_package||'chk_rate_basis';
  l_api_updating boolean;
  --
Begin
  --
   --
    hr_utility.set_location('Entering:'||l_proc, 10);

     hr_api.mandatory_arg_error
         (p_api_name       => l_proc,
          p_argument       => 'pay_basis',
          p_argument_value => p_pay_basis);

    -- Only proceed with validation if :
    -- there is a pay basis being passed
    --
    IF  (p_pay_basis is not null) then
      --
      hr_utility.set_location(l_proc, 20);
      --
      -- Check that the reason type exists in HR_LOOKUPS
      --
      IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => sysdate
        ,p_lookup_type           => 'PAY_BASIS'
        ,p_lookup_code           => p_pay_basis) THEN
        --
        hr_utility.set_location(l_proc, 30);
        --
        fnd_message.set_name('PER', 'HR_PSF_INVALID_PAY_BASIS');
        hr_utility.raise_error;
        --
      END IF;
      --
      ELSIF p_rate_basis is not null then
      IF hr_api.not_exists_in_hr_lookups
              (p_effective_date        => sysdate
              ,p_lookup_type           => 'PAY_BASIS'
              ,p_lookup_code           => p_rate_basis) then

          hr_utility.set_location(l_proc, 40);
          fnd_message.set_name('PER', 'PER_289917_INVALID_RATE_BASIS');
          hr_utility.raise_error;
       end if;
    END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 50);

End chk_rate_basis;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_delete  >------------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_delete(p_pay_basis_id            number
                    ,p_object_version_number   number
                     ) is

l_exists  varchar2(1);
--
cursor csr_assignment is
           select 'x'
           FROM per_all_assignments_f
           WHERE pay_basis_id = p_pay_basis_id;
--
cursor csr_positions is
           select 'x'
           FROM hr_all_positions_f
           WHERE  pay_basis_id = p_pay_basis_id;

cursor csr_elements is
           select 'x'
           FROM pay_element_links_f
           WHERE  pay_basis_id = p_pay_basis_id;
--
 --
  l_proc         varchar2(72) := g_package||'chk_delete';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --  Check there are no values in per_all_assignments_f,hr_all_positions_f
  --  pay_elements_links_f
  --
Open csr_assignment;
  --
 fetch csr_assignment into l_exists;
  --
          If csr_assignment%found Then
            --
            close csr_assignment;
            --
              fnd_message.set_name('PAY','HR_13020_SAL_ASG_EXISTS');
            --
            fnd_message.raise_error;
            --
          End If;
  --
Close csr_assignment;

Open csr_positions;
  --
 fetch csr_positions into l_exists;
  --
          If csr_positions%found Then
            --
            close csr_positions;
            --
              fnd_message.set_name('PER','PER_289918_SAL_POS_EXISTS');
            --
            fnd_message.raise_error;
            --
          End If;
  --
Close csr_positions;

Open csr_elements;
  --
 fetch csr_elements into l_exists;
  --
          If csr_elements%found Then
            --
            close csr_elements;
            --
              fnd_message.set_name('PER','PER_289919_SAL_ELEMENT_EXISTS');
            --
            fnd_message.raise_error;
            --
          End If;
  --
Close csr_elements;
  --
hr_utility.set_location('Leaving:'||l_proc, 20);
        --
  --
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_sal_basis_asg_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check to see if a pay basis has been assigned to
--   an assignment. If this is the case, then they can only update the name of
--   the salary basis.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pasy_basis_id PK of record being updated.
--   object_version_number Object version number of record being
--                         updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_sal_basis_asg_exists(
				p_rec in per_ppb_shd.g_rec_type
                                   ) is

--
l_proc         varchar2(72) := g_package||'chk_sal_basis_asg_exists';
--
l_api_updating boolean;
l_exists        varchar2(1);

--
--
cursor csr_sal_pay_in_asg is
          select 'Y'
          from  PER_ALL_ASSIGNMENTS_F paa
         where paa.pay_basis_id  = p_rec.pay_basis_id;
--
begin
--
hr_utility.set_location('Entering:'||l_proc, 10);

	l_api_updating := per_ppb_shd.api_updating
	    (p_rec.pay_basis_id
	    ,p_rec.object_version_number
	   );

if l_api_updating then

--
hr_utility.set_location('Entering:'||l_proc, 15);
--
	   OPEN csr_sal_pay_in_asg;
	           --
	           FETCH csr_sal_pay_in_asg INTO l_exists;
	            hr_utility.set_location(l_proc,15);
	           IF csr_sal_pay_in_asg%FOUND THEN
	               -- it belongs to an assignment
	               -- only name can be changed
	             if (p_rec.name
		            =  per_ppb_shd.g_old_rec.name) then
 		      hr_utility.set_location('Entering:'||l_proc, 20);
       	              fnd_message.set_name('PER','HR_51268_PYP_CANT_UPD_RECORD');
	              fnd_message.raise_error;
		      else
		      hr_utility.set_location('Entering:'||l_proc, 25);
		       IF (p_rec.input_value_id
		            <>  per_ppb_shd.g_old_rec.input_value_id)
		      or  (p_rec.rate_id
		            <>  per_ppb_shd.g_old_rec.rate_id)
		      or  (p_rec.pay_basis
		            <>  per_ppb_shd.g_old_rec.pay_basis)
		      or  (p_rec.rate_basis
		            <>  per_ppb_shd.g_old_rec.rate_basis)
		      or  (p_rec.pay_annualization_factor
		            <>  per_ppb_shd.g_old_rec.pay_annualization_factor)
		      or  (p_rec.grade_annualization_factor
		            <>  per_ppb_shd.g_old_rec.grade_annualization_factor)
		      or  (p_rec.attribute_category
		            <>  per_ppb_shd.g_old_rec.attribute_category)
		      or  (p_rec.attribute1
		            <>  per_ppb_shd.g_old_rec.attribute1)
		      or  (p_rec.attribute2
		            <>  per_ppb_shd.g_old_rec.attribute2)
		      or  (p_rec.attribute3
		            <>  per_ppb_shd.g_old_rec.attribute3)
		      or  (p_rec.attribute4
		            = per_ppb_shd.g_old_rec.attribute4)
		      or  (p_rec.attribute5
		            <>  per_ppb_shd.g_old_rec.attribute5)
		      or  (p_rec.attribute6
		            <>  per_ppb_shd.g_old_rec.attribute6)
		      or  (p_rec.attribute7
		            <>  per_ppb_shd.g_old_rec.attribute7)
		      or  (p_rec.attribute8
		            <>  per_ppb_shd.g_old_rec.attribute8)
		      or  (p_rec.attribute9
		            <>  per_ppb_shd.g_old_rec.attribute9)
		      or  (p_rec.attribute10
		            <>  per_ppb_shd.g_old_rec.attribute10)
		      or  (p_rec.attribute11
		            <>  per_ppb_shd.g_old_rec.attribute11)
		      or  (p_rec.attribute12
		            <>  per_ppb_shd.g_old_rec.attribute12)
		      or  (p_rec.attribute13
		            <>  per_ppb_shd.g_old_rec.attribute13)
		      or  (p_rec.attribute14
		            <>  per_ppb_shd.g_old_rec.attribute14)
		      or  (p_rec.attribute15
		            <>  per_ppb_shd.g_old_rec.attribute15)
		      or  (p_rec.attribute16
		            <>  per_ppb_shd.g_old_rec.attribute16)
		      or  (p_rec.attribute17
		            <>  per_ppb_shd.g_old_rec.attribute17)
		      or  (p_rec.attribute18
		            <>  per_ppb_shd.g_old_rec.attribute18)
		      or  (p_rec.attribute19
		            <>  per_ppb_shd.g_old_rec.attribute19)
		      or  (p_rec.attribute20
		            <>  per_ppb_shd.g_old_rec.attribute20)
		      or  (p_rec.information_category
		            <>  per_ppb_shd.g_old_rec.information_category)
		      or  (p_rec.information1
		            <>  per_ppb_shd.g_old_rec.information1)
		      or  (p_rec.information2
		            <>  per_ppb_shd.g_old_rec.information2)
		      or  (p_rec.information3
		            <>  per_ppb_shd.g_old_rec.information3)
		      or  (p_rec.information4
		            <>  per_ppb_shd.g_old_rec.information4)
		      or  (p_rec.information5
		            =  per_ppb_shd.g_old_rec.information5)
		      or  (p_rec.information6
		            <>  per_ppb_shd.g_old_rec.information6)
		      or  (p_rec.information7
		            =  per_ppb_shd.g_old_rec.information7)
		      or  (p_rec.information8
		            <>  per_ppb_shd.g_old_rec.information8)
		      or  (p_rec.information9
		            <>  per_ppb_shd.g_old_rec.information9)
		      or  (p_rec.information10
		            <>  per_ppb_shd.g_old_rec.information10)
		      or  (p_rec.information11
		            <>  per_ppb_shd.g_old_rec.information11)
		      or  (p_rec.information12
		            <>  per_ppb_shd.g_old_rec.information12)
		      or  (p_rec.information13
		            <>  per_ppb_shd.g_old_rec.information13)
		      or  (p_rec.information14
		            <>  per_ppb_shd.g_old_rec.information14)
		      or  (p_rec.information15
		            <>  per_ppb_shd.g_old_rec.information15)
		      or  (p_rec.information16
		            <>  per_ppb_shd.g_old_rec.information16)
		      or  (p_rec.information17
		            <>  per_ppb_shd.g_old_rec.information17)
		      or  (p_rec.information18
		            <>  per_ppb_shd.g_old_rec.information18)
		      or  (p_rec.information19
		            <>  per_ppb_shd.g_old_rec.information19)
		      or  (p_rec.information20
		            <>  per_ppb_shd.g_old_rec.information20) THEN
		            hr_utility.set_location('Entering:'||l_proc, 30);
                             fnd_message.set_name('PER','HR_51268_PYP_CANT_UPD_RECORD');
                             fnd_message.raise_error;
		     end if;
			--
	           end if;
	    CLOSE csr_sal_pay_in_asg;
--
end if;
end if;

--
-- hr_utility.set_location('Leaving:'||l_proc, 35);
--
End chk_sal_basis_asg_exists;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in per_ppb_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.pay_basis_id is not null)  and (
    nvl(per_ppb_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) ))
    or (p_rec.pay_basis_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Salary Basis Developer DF'
      ,p_attribute_category              => p_rec.INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in per_ppb_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.pay_basis_id is not null)  and (
    nvl(per_ppb_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_ppb_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.pay_basis_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PAY_BASES'
      ,p_attribute_category              => p_rec.ATTRIBUTE_CATEGORY
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec in per_ppb_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_ppb_shd.api_updating
      (p_pay_basis_id                      => p_rec.pay_basis_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_ppb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_leg_code  varchar2(30);
--
Begin


    select pbg.legislation_code
      into l_leg_code
      from per_business_groups_perf pbg
       where pbg.business_group_id = p_rec.business_group_id;

--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_ppb_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
 chk_pay_basis_id(p_pay_basis_id            => p_rec.pay_basis_id,
                  p_object_version_number   => p_rec.object_version_number
                           );
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
chk_rate_id
  (p_rate_id                      => p_rec.rate_id,
   p_pay_basis_id                 => p_rec.pay_basis_id,
   p_object_version_number        => p_rec.object_version_number
  ) ;
  --
 chk_name
 (p_name                          => p_rec.name,
  p_business_group_id            => p_rec.business_group_id
  )    ;
  --
 chk_pay_basis(p_pay_basis             => p_rec.pay_basis,
               p_object_version_number => p_rec.object_version_number
               );
  --

chk_pay_annualization_factor
 (p_pay_annualization_factor     => p_rec.pay_annualization_factor,
  p_pay_basis                    => p_rec.pay_basis
  );
--
chk_grade_annualization_factor
  (p_grade_annualization_factor     => p_rec.grade_annualization_factor,
   p_rate_basis                     => p_rec.rate_basis
  );
  --
chk_input_value_id(p_input_value_id        => p_rec.input_value_id,
                   p_business_group_id     => p_rec.business_group_id,
                   p_object_version_number => p_rec.object_version_number,
                   p_legislation_code      => l_leg_code
                   );
  --
chk_rate_basis(p_rate_basis            => p_rec.rate_basis,
               p_pay_basis             => p_rec.pay_basis
                         );
  --
--  per_ppb_bus.chk_ddf(p_rec);
  --
  per_ppb_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_ppb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_leg_code  varchar2(30);
--
Begin
 select pbg.legislation_code
      into l_leg_code
      from per_business_groups_perf pbg
         , per_pay_bases ppb
     where ppb.pay_basis_id = p_rec.pay_basis_id
       and pbg.business_group_id = ppb.business_group_id;
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_ppb_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
 chk_pay_basis_id(p_pay_basis_id            => p_rec.pay_basis_id,
                  p_object_version_number   => p_rec.object_version_number
                           );
--
chk_sal_basis_asg_exists(p_rec);
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
chk_rate_id
  (p_rate_id                      => p_rec.rate_id,
   p_pay_basis_id                 => p_rec.pay_basis_id,
   p_object_version_number        => p_rec.object_version_number
  ) ;
  --
chk_name
 (p_name                          => p_rec.name,
  p_pay_basis_id                 => p_rec.pay_basis_id,
  p_business_group_id            => p_rec.business_group_id
  )    ;
--
chk_pay_basis(p_pay_basis             => p_rec.pay_basis,
              p_object_version_number => p_rec.object_version_number
              );

--
hr_utility.set_location('pay annual'||p_rec.pay_annualization_factor||l_proc, 666);
chk_pay_annualization_factor
  (p_pay_annualization_factor     => p_rec.pay_annualization_factor,
   p_pay_basis                    => p_rec.pay_basis
   );
--
chk_grade_annualization_factor
  (p_grade_annualization_factor     => p_rec.grade_annualization_factor,
   p_rate_basis                     => p_rec.rate_basis
  );
  --
chk_input_value_id(p_input_value_id        => p_rec.input_value_id,
                   p_business_group_id     => p_rec.business_group_id,
                   p_object_version_number => p_rec.object_version_number,
                   p_legislation_code      => l_leg_code
                   );
  --
chk_rate_basis(p_rate_basis            => p_rec.rate_basis,
               p_pay_basis             => p_rec.pay_basis
               );
  --
--  per_ppb_bus.chk_ddf(p_rec);
  --
  per_ppb_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_ppb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
chk_delete(p_pay_basis_id           => p_rec.Pay_basis_id
          ,p_object_version_number  => p_rec.object_version_number
           );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_ppb_bus;

/
