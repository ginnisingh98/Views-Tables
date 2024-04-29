--------------------------------------------------------
--  DDL for Package Body IRC_IAD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IAD_BUS" as
/* $Header: iriadrhi.pkb 120.5.12010000.2 2010/01/11 10:41:25 uuddavol ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iad_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_assignment_details_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_assignment_details_id                in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
     where pbg.business_group_id =
           (select distinct asg.business_group_id
              from irc_assignment_details_f iad
                 , per_all_assignments_f    asg
             where iad.assignment_details_id = p_assignment_details_id
               and iad.assignment_id = asg.assignment_id);
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'assignment_details_id'
    ,p_argument_value     => p_assignment_details_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
         => nvl(p_associated_column1,'ASSIGNMENT_DETAILS_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_assignment_details_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
     where pbg.business_group_id =
           (select distinct asg.business_group_id
              from irc_assignment_details_f iad
                 , per_all_assignments_f    asg
             where iad.assignment_details_id = p_assignment_details_id
               and iad.assignment_id = asg.assignment_id);
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
    ,p_argument           => 'assignment_details_id'
    ,p_argument_value     => p_assignment_details_id
    );
  --
  if ( nvl(irc_iad_bus.g_assignment_details_id, hr_api.g_number)
       = p_assignment_details_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_iad_bus.g_legislation_code;
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
    irc_iad_bus.g_assignment_details_id       := p_assignment_details_id;
    irc_iad_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date  in date
  ,p_rec             in irc_iad_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_iad_shd.api_updating
      (p_assignment_details_id            => p_rec.assignment_details_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Ensure non-updateable args have not been updated.
  --
  if p_rec.assignment_id <> irc_iad_shd.g_old_rec.assignment_id
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'assignment_id'
     ,p_base_table => irc_iad_shd.g_tab_nam
     );
  end if;
  --
  if p_rec.details_version<> irc_iad_shd.g_old_rec.details_version
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'details_version'
     ,p_base_table => irc_iad_shd.g_tab_nam
     );
  end if;
  --
  if p_rec.latest_details <> irc_iad_shd.g_old_rec.latest_details
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'latest_details'
     ,p_base_table => irc_iad_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_assignment_id                 in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  If ((nvl(p_assignment_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_all_assignments_f'
            ,p_base_key_column => 'ASSIGNMENT_ID'
            ,p_base_key_value  => p_assignment_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','all assignments');
     hr_multi_message.add
       (p_associated_column1 => irc_iad_shd.g_tab_nam || '.ASSIGNMENT_ID');
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_assignment_details_id            in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'assignment_details_id'
      ,p_argument_value => p_assignment_details_id
      );
    --
  --
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_attempt_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Verifies that the attempt id exists in OTA_ATTEMPTS and is being provided
--   for applicant assignment type only.
--
-- Prerequisites:
--   Must be called as the first step in insert_validate.
--
-- In Arguments:
--   p_attempt_id
--
-- Post Success:
--   If attempt_id exists in OTA_ATTEMPTS and the assignment is of type
--   application assignment, then continue.
--
-- Post Failure:
--   If the attempt_id does not exists in OTA_ATTEMPTS or if the assignment
--   type is not application assignment, then throw an error indicating
--   the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_attempt_id
  (p_attempt_id             in  number
  ,p_assignment_details_id  in
                    irc_assignment_details_f.assignment_details_id%TYPE
  ,p_assignment_id          in  irc_assignment_details_f.assignment_id%TYPE
  ,p_effective_date         in  date
  ,p_object_version_number  in
                    irc_assignment_details_f.object_version_number%TYPE
  )
IS
--
  l_proc              varchar2(72)  :=  g_package||'chk_attempt_id';
  l_api_updating      boolean;
  l_dummy             varchar2(1);
  l_assignment_type   per_all_assignments_f.assignment_type%TYPE;
  --
  cursor csr_assignment_type(p_assignment_id number, p_effective_date date) is
    select assignment_type
    from per_all_assignments_f
    where assignment_id = p_assignment_id and
          p_effective_date between effective_start_date and effective_end_date;
  --
  cursor attempt_exists(p_attempt_id number) is
    select null
    from ota_attempts
    where attempt_id = p_attempt_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_api_updating := irc_iad_shd.api_updating
  (p_assignment_details_id => p_assignment_details_id
  ,p_effective_date         => p_effective_date
  ,p_object_version_number  => p_object_version_number
  );
  --
  if ((l_api_updating and
       nvl(irc_iad_shd.g_old_rec.attempt_id, hr_api.g_number) <>
          nvl(p_attempt_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 20);
    --
    -- Check if attempt_id is not null
    --
    if p_attempt_id IS NOT NULL then
      --
      -- attempt_id must exist in ota_attempts
      --
      open attempt_exists(p_attempt_id);
      fetch attempt_exists into l_dummy;
      --
      if attempt_exists%notfound then
        close attempt_exists;
        hr_utility.set_location(l_proc, 30);
        fnd_message.set_name('PER', 'IRC_412233_INV_OTA_ATTEMPT');
        fnd_message.raise_error;
      else
        close attempt_exists;
      end if;
      --
      -- Check that when inserting, the assignment is an applicant assignment
      --
      open csr_assignment_type(p_assignment_id, p_effective_date);
      fetch csr_assignment_type into l_assignment_type;
      close csr_assignment_type;
      --
      if l_assignment_type in ('E','C','B','O') then
        hr_utility.set_location(l_proc, 40);
        --
        -- Check if the assignment is being updated
        --
        if l_api_updating then
          --
          -- non applicant, attempt_id can only be updated to null
          --
          fnd_message.set_name('PER', 'IRC_412235_OTA_ATTEMPT_INV_UPD');
          fnd_message.raise_error;
        else -- inserting a non applicant
          fnd_message.set_name('PER', 'IRC_412234_OTA_ATTEMPT_ASG');
          fnd_message.raise_error;
        end if;
      end if;
    end if;
  end if;
  hr_utility.set_location('Leaving: '||l_proc, 50);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1      => 'IRC_ASSIGNMENT_DETAILS_F.ATTEMPT_ID'
        ) then
        raise;
      end if;
end chk_attempt_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in irc_iad_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS
  --
  -- Validate Dependent Attributes
  --
  chk_attempt_id
  (p_attempt_id             => p_rec.attempt_id
  ,p_assignment_details_id  => p_rec.assignment_details_id
  ,p_assignment_id          => p_rec.assignment_id
  ,p_effective_date         => p_effective_date
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in irc_iad_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_assignment_id                  => p_rec.assignment_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
  chk_attempt_id
  (p_attempt_id             => p_rec.attempt_id
  ,p_assignment_details_id  => p_rec.assignment_details_id
  ,p_assignment_id          => p_rec.assignment_id
  ,p_effective_date         => p_effective_date
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in irc_iad_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_assignment_details_id            => p_rec.assignment_details_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end irc_iad_bus;

/
