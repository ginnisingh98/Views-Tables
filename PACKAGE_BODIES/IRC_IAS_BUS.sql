--------------------------------------------------------
--  DDL for Package Body IRC_IAS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IAS_BUS" as
/* $Header: iriasrhi.pkb 120.0.12010000.5 2009/09/04 10:42:06 chsharma ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ias_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_assignment_status_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_assignment_id            in number
  ,p_associated_column1       in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_all_assignments_f asg
      where pbg.business_group_id = asg.business_group_id
      and asg.assignment_id = p_assignment_id ;
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
        => nvl(p_associated_column1,'ASSIGNMENT_ID')
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
  (p_assignment_status_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , per_all_assignments_f asg
         , irc_assignment_statuses ias
      where pbg.business_group_id = asg.business_group_id
      and asg.assignment_id = ias.assignment_id
      and ias.assignment_status_id = p_assignment_status_id ;
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
  --
  if ( nvl(irc_ias_bus.g_assignment_status_id, hr_api.g_number)
       = p_assignment_status_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_ias_bus.g_legislation_code;
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
    irc_ias_bus.g_assignment_status_id  := p_assignment_status_id;
    irc_ias_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec                              in irc_ias_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ias_shd.api_updating
      (p_assignment_status_id                 => p_rec.assignment_status_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --

End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_assignment_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that assignment Id exists in table
--   per_all_assignments_f.
--
-- Pre Conditions:
--   assignment Id should exist in the table.
--
-- In Arguments:
--   p_assignment_id is passed by the user.
--
-- Post Success:
--   Processing continues if assignment Id exists.
--
-- Post Failure:
--   An error is raised if assignment Id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assignment_id
  (p_assignment_id                 in
  irc_assignment_statuses.assignment_id%type
  ) is
--
  l_proc     varchar2(72) := g_package || 'chk_assignment_id';
  --
  l_assignment_id irc_assignment_statuses.assignment_id%type ;
  --
  cursor csr_applicant_assignment is
  select 1
  from per_all_assignments_f
  where assignment_id = p_assignment_id
  and assignment_type = 'A';
  --
  cursor csr_emp_applicant_assignment is
  select 1
  from per_all_assignments_f paaf1
  where assignment_id = p_assignment_id
  and exists ( select null
                from per_all_assignments_f paaf2
               where paaf1.person_id = paaf2.person_id
                 and paaf1.vacancy_id = paaf2.vacancy_id
                 and paaf2.assignment_type = 'A');
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'assignment_id'
    ,p_argument_value     => p_assignment_id
    );
  --
  --
  hr_utility.set_location(l_proc,20);
  --
  open csr_applicant_assignment;
  fetch csr_applicant_assignment Into l_assignment_id;
  --
  if csr_applicant_assignment%notfound then
    --
    hr_utility.set_location(l_proc,30);
    --
    open csr_emp_applicant_assignment;
    fetch csr_emp_applicant_assignment Into l_assignment_id;
    --
    if csr_emp_applicant_assignment%notfound then
    	hr_utility.set_location(l_proc,40);
 	close csr_emp_applicant_assignment;
	close csr_applicant_assignment;
	fnd_message.set_name ('PER', 'IRC_412006_ASG_NOT_APPL');
	fnd_message.raise_error;
    end if;
    --
    close csr_emp_applicant_assignment;
  end if;
  --
  close csr_applicant_assignment;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1  => 'IRC_ASSIGNMENT_STATUSES.ASSIGNMENT_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_assignment_id;
--


-- ----------------------------------------------------------------------------
-- |------------------< chk_comments >-----------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that comments do not contain more than
--   500 characters
--
--  In Arguments:
--   p_comments is passed by the user.
--
-- Post Success:
--   Processing continues if comments are less than 200 characters.
--
-- Post Failure:
--   An error is raised if comments are more than 200 characters.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_comments
  (p_comments                in varchar2
  ) is
--
  l_proc     varchar2(72) := g_package || 'chk_comments';
  --
  --

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  --
  hr_utility.set_location(l_proc,20);
  --

  --
  if lengthb(p_comments)>500 then
    --
    hr_utility.set_location(l_proc,30);
    --
    --- this message has to be changed to the new message
 		fnd_message.set_name ('PER', 'IRC_412599_COMMENT_LEN_EROOR');
	fnd_message.raise_error;
    end if;
    --
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1  => 'IRC_ASSIGNMENT_STATUSES.ASSIGNMENT_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_comments;



-- ----------------------------------------------------------------------------
-- |------------------< chk_assignment_status_type_id >-----------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that assignment status type Id exists
--   in table per_assignment_status_types.
--
-- Pre Conditions:
--   assignment status  Id should exist in the table.
--
-- In Arguments:
--   p_asg_status_type_id is passed by the user.
--
-- Post Success:
--   Processing continues if assignment status Id exists.
--
-- Post Failure:
--   An error is raised if assignment status Id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assignment_status_type_id
  (p_asg_status_type_id                 in
  irc_assignment_statuses.assignment_status_type_id%type
  ) is
--
  l_proc     varchar2(72) := g_package || 'chk_assignment_status_type_id';
  --
  l_asg_status_type_id irc_assignment_statuses.assignment_status_type_id%type;
  --
  cursor csr_exists is
  select 1
  from PER_ASSIGNMENT_STATUS_TYPES
  where ASSIGNMENT_STATUS_TYPE_ID = P_ASG_STATUS_TYPE_ID;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ASSIGNMENT_STATUS_TYPE_ID'
    ,p_argument_value     => p_asg_status_type_id
    );
  --
  open csr_exists;
  fetch csr_exists into l_asg_status_type_id;
  hr_utility.set_location(l_proc,20);
  if csr_exists%notfound then
    close csr_exists;
    fnd_message.set_name ('PER','IRC_412007_REC_ASG_BAD');
    fnd_message.raise_error;
  end if;
  close csr_exists;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1=>
        'IRC_ASSIGNMENT_STATUSES.ASSIGNMENT_STATUS_TYPE_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_assignment_status_type_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in irc_ias_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  chk_assignment_id
    (p_assignment_id => p_rec.assignment_id
    );
  hr_utility.set_location(l_proc,10);
  chk_assignment_status_type_id
    (p_asg_status_type_id => p_rec.assignment_status_type_id
    );
  -- As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling the
  -- irc_ias_bus.set_security_group_id procedure
  --
  hr_utility.set_location(l_proc, 20);
  irc_ias_bus.set_security_group_id
  (p_assignment_id => p_rec.assignment_id
  ,p_associated_column1 => irc_ias_shd.g_tab_nam||'.ASSIGNMENT_ID'
  );
  hr_utility.set_location(l_proc, 25);

  chk_comments(p_comments =>   p_rec.status_change_comments);


  hr_utility.set_location(' Leaving:'||l_proc, 30);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in irc_ias_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_utility.set_location('Entering:'||l_proc, 15);
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
    hr_utility.set_location('Entering:'||l_proc, 20);
  --
    chk_assignment_status_type_id
    (p_asg_status_type_id => p_rec.assignment_status_type_id
    );
  --
  --
    chk_comments(p_comments =>   p_rec.status_change_comments);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ias_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end irc_ias_bus;

/
