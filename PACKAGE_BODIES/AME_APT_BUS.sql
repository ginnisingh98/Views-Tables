--------------------------------------------------------
--  DDL for Package Body AME_APT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APT_BUS" as
/* $Header: amaptrhi.pkb 120.1 2006/04/21 08:44 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'ame_apt_bus.';  -- Global package name
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
  ,p_rec             in ame_apt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_apt_shd.api_updating
      (p_approver_type_id         =>  p_rec.approver_type_id
      ,p_effective_date           => p_effective_date
      ,p_object_version_number    => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- NAME is non-updateable
  --
   if nvl(p_rec.orig_system, hr_api.g_varchar2) <>
       nvl(ame_apt_shd.g_old_rec.orig_system, hr_api.g_varchar2) then
     hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'orig_system'
          ,p_base_table => ame_apt_shd.g_tab_nam
          );
  end if;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_orig_system >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the mandatory column orig_system has been
--   populated or not.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_orig_system
--
-- Post Success:
--   Processing continues if a valid orig_system has been entered.
--
-- Post Failure:
--   An application error is raised if the orig_system is undefined.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ------------------------------------------------------------------------
procedure chk_orig_system
  (p_orig_system             in   varchar2) IS

  l_proc              varchar2(72)  :=  g_package||'chk_orig_system';
  origsystem          varchar2(50);
Cursor chk_exist_orig_system(p_orig_system in varchar2) is
        SELECT lookup_code
          from FND_LOOKUPS
          where lookup_type like 'FND_WF_ORIG_SYSTEMS'
            and lookup_code = p_orig_system
            and rownum <2 ;
begin
  hr_api.mandatory_arg_error
    (p_api_name        => l_proc
    ,p_argument        => 'orig_system'
    ,p_argument_value  => p_orig_system
    );
  open chk_exist_orig_system(p_orig_system);
  fetch  chk_exist_orig_system into origsystem;
  if chk_exist_orig_system%notfound then
    close chk_exist_orig_system ;
    fnd_message.set_name('PER','AME_400806_INV_ORIG_SYSTEM');
    -- RAISE_APPLICATION_ERROR( -20201,'INVALID ORIG SYSTEM ');
    fnd_message.raise_error;
  end if;
  close chk_exist_orig_system ;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ame_approver_types.orig_system') then
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_orig_system ;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_unique >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a duplicate approver_type_id and orig_system don't
--   exist
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_orig_system
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid record has been entered.
--
-- Post Failure:
--   An application error is raised if entered approver_type_id and orig_system
--   are not unique
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_unique(p_orig_system                 in   varchar2
                    ,p_effective_date              in   date
                    ) IS
--
  cursor csr_name is
    select null
      from ame_approver_types
    where orig_system = p_orig_system
      and p_effective_date between start_date and
            nvl(end_date - ame_util.oneSecond, p_effective_date);
--
  l_proc     varchar2(72) := g_package || 'CHK_UNIQUE';
  l_dummy    varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    --
    open csr_name;
    fetch csr_name into l_dummy;
    if csr_name%found then
      close csr_name;
      fnd_message.set_name('PER','AME_400805_DUP_APPROVER_TYPE');
      fnd_message.raise_error;
    end if;
    close csr_name;
    --
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'ame_approver_types.UNIQUE'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_unique;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< CHK_DELETE >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   check that 1) Seeded approvertypes types cannot be deleted.
--              2) Approver types cannot have attributes.
--              3) Approver types cannot have approver group menbers.
--              4) Approver types cannot have conditions.
--              5) Approver types cannot have substitution actions
--
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_approver_type_id
--   p_orig_system
--
-- Post Success:
--   Processing continues if no child records for the said condition are found.
--
-- Post Failure:
--   An application error is raised if valid child records exist for the given
--   condition_id.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_delete(p_approver_type_id                     in   number
                    ,p_orig_system                          in   varchar2
                    ,p_effective_date                       in   date
                    ) IS
  l_proc           varchar2(72) := g_package || 'CHK_DELETE';
  l_key            varchar2(1);
--

cursor csr_isSeeded is
     select null
        from ame_approver_types
        where approver_type_id = p_approver_type_id
        and   p_effective_date between start_date
        and   nvl(end_date - ame_util.oneSecond, p_effective_date)
        and  ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById;
--
cursor c_sel1 is
    select null
      from ame_attributes
      where approver_type_id = p_approver_type_id
      and   p_effective_date between start_date
      and  nvl(end_date - ame_util.oneSecond, p_effective_date);
--
cursor c_sel2 is
    select null
      from ame_approver_type_usages
      where approver_type_id = p_approver_type_id
      and   p_effective_date between start_date
      and   nvl(end_date - ame_util.oneSecond, p_effective_date);
--
cursor c_sel3 is
    select null
      from AME_APPROVAL_GROUP_MEMBERS
      where orig_system = p_orig_system;
--
Cursor c_sel4 is
    select null
       from AME_CONDITIONS cond
           ,WF_ROLES wfr
       where cond.parameter_two = wfr.name
         and wfr.orig_system = p_orig_system
         and p_effective_date between cond.start_date
         and nvl(cond.end_date - ame_util.oneSecond, p_effective_date);
--
Cursor c_sel5 is
    select null
        from AME_ACTIONS actions
            ,WF_ROLES wfr
            ,ame_action_types act
        where actions.parameter = wfr.name
          and wfr.orig_system = p_orig_system
          and act.name ='substitution'
          and p_effective_date between actions.start_date
          and nvl(actions.end_date - ame_util.oneSecond, p_effective_date);
l_exists varchar2(1);
begin
 open csr_isSeeded;
    fetch csr_isSeeded into l_key;
    if(csr_isSeeded%found) then
      -- close csr_isSeeded;
      fnd_message.set_name('PER','AME_400807_SEED_APT_DEL');
      -- fnd_message.raise_error;
       hr_multi_message.add;
    end if;
    close csr_isSeeded;
--
-- AME_ATTRIBUTES
--
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%found then
 --   close c_sel1;
    -- AT MESSAGE
    -- An attributee usage(s) still exists.  You must first delete the  attribute usage(s)
    -- before deleting the approver type
    fnd_message.set_name('PER','AME_400809_APT_ATTR_EXISTS');
   -- fnd_message.raise_error;
    hr_multi_message.add;
  end if;
  close c_sel1;
--
-- AME_APPROVER_TYPE_USAGE
--
 /*  open c_sel2;
  fetch  c_sel2 into l_exists;
  if c_sel2%found then
   -- close c_sel2;
    -- AT MESSAGE
    -- An approver type usage(s) still exists.  You must first delete the approver type usage(s)
    -- before deleting the approver type
    fnd_message.set_name('PER','AME_400612_APPR_USG_EXISTS');
   -- fnd_message.raise_error;
    hr_multi_message.add;
  end if;
  close c_sel2; */
--
-- AME_APPROVAL_GROUP_MEMBERS
--
 open c_sel3;
  fetch  c_sel3 into l_exists;
  if c_sel3%found then
   --  close c_sel3;
    -- AT MESSAGE
    -- An apporver group member usage(s) still exists.  You must first delete the approver group member usage(s)
    -- before deleting the approver type
    fnd_message.set_name('PER','AME_400810_APT_APG_EXISTS');
    -- fnd_message.raise_error;
    hr_multi_message.add;
  end if;
  close c_sel3;
--
-- AME_CONDITIONS
--
open c_sel4;
  fetch  c_sel4 into l_exists;
  if c_sel4%found then
  --  close c_sel4;
    -- AT MESSAGE
    -- A condition usage(s) still exists.  You must first delete the condition usage(s)
    -- before deleting the approver type
    fnd_message.set_name('PER','AME_400808_APT_COND_EXISTS');
    -- fnd_message.raise_error;
    hr_multi_message.add;
  end if;
  close c_sel4;
--
-- AME_ACTIONS
--
open c_sel5;
  fetch  c_sel5 into l_exists;
  if c_sel5%found then
   -- close c_sel5;
    -- AT MESSAGE
    -- A condition usage(s) still exists.  You must first delete the condition usage(s)
    -- before deleting the approver type
    fnd_message.set_name('PER','AME_400811_APT_ACT_EXISTS');
    hr_multi_message.add;
    -- fnd_message.raise_error;
  end if;
  close c_sel5;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_APPROVER_TYPE.DELETE'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_delete;
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
  (p_datetrack_mode                in varchar2
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
  /*hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );*/
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
  (p_approver_type_id                 in number
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
    /*hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );*/
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'approver_type_id'
      ,p_argument_value => p_approver_type_id
      );
    --
/*
ame_apt_shd.child_rows_exist
(p_approver_type_id => p_approver_type_id
,p_orig_system      => p_orig_system
,p_start_date       => p_validation_start_date
,p_end_date         => p_validation_end_date);
  --
--
*/
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in  ame_apt_shd.g_rec_type
  ,p_effective_date        in  date
  ,p_datetrack_mode        in  varchar2
  ,p_validation_start_date in  date
  ,p_validation_end_date   in  date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Dependent Attributes
  --
  chk_orig_system(p_orig_system => p_rec.orig_system);

  chk_unique(p_orig_system            => p_rec.orig_system
            ,p_effective_date         => p_effective_date
            );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_apt_shd.g_rec_type
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
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_apt_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc          varchar2(72) := g_package||'delete_validate';
  l_orig_system   varchar2(100);
--
cursor csr_origSystem is
     select orig_system
        from ame_approver_types
        where approver_type_id = p_rec.approver_type_id
        and   p_effective_date between start_date
        and   nvl(end_date - ame_util.oneSecond, p_effective_date);
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   --
  -- Call all supporting business operations
  --
  -- Check for seeded data
  --
     open csr_origSystem;
     fetch csr_origSystem into l_orig_system;
     close csr_origSystem;

  chk_delete(p_approver_type_id  => p_rec.approver_type_id
            ,p_orig_system       => l_orig_system
            ,p_effective_date    => p_effective_date);
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_approver_type_id                 => p_rec.approver_type_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_apt_bus;

/
