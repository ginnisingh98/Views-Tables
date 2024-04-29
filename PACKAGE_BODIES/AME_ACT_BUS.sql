--------------------------------------------------------
--  DDL for Package Body AME_ACT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACT_BUS" as
/* $Header: amactrhi.pkb 120.4 2005/11/22 03:12 santosin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_act_bus.';  -- Global package name
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
  ,p_rec             in ame_act_shd.g_rec_type
  ) IS
--
  createdBy  ame_actions.created_by%type;
	l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  actionTypeIds ame_util.idList;
  approvalGroup boolean;
--
Cursor c_sel1 is
  select action_type_id
    from ame_action_types
    where
      name in (ame_util.preApprovalTypeName,
               ame_util.postApprovalTypeName,
               ame_util.groupChainApprovalTypeName) and
      p_effective_date between start_date and
         nvl(end_date - ame_util.oneSecond, p_effective_date);
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_act_shd.api_updating
      (p_action_id =>  p_rec.action_id
 ,p_action_type_id =>  p_rec.action_type_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  /* Seeded actions cannot be deleted. */
	select ame_utility_pkg.is_seed_user(created_by)
    into createdBy
    from ame_actions
    where
      action_id = p_rec.action_id and
      p_effective_date between start_date and
         nvl(end_date - ame_util.oneSecond, p_effective_date);
	OPEN c_sel1;
  FETCH c_sel1 BULK COLLECT INTO actionTypeIds;
  approvalGroup := false;
	FOR i in 1 .. actionTypeIds.count LOOP
    IF(p_rec.action_type_id = actionTypeIds(i)) THEN
      approvalGroup := true;
      EXIT;
    END IF;
  END LOOP;
  IF(approvalGroup) THEN
    /* Action is based on an approval group so it's not updateable. */
    IF
		  nvl(p_rec.parameter,
		      hr_api.g_number) <>
      nvl(ame_act_shd.g_old_rec.parameter,
			    hr_api.g_number) THEN
      l_argument := 'parameter';
      RAISE l_error;
    END IF;
  /* Descriptions for seeded actions cannot be updated. */
  ELSIF(createdBy = ame_util.seededDataCreatedById
        and ame_utility_pkg.check_seeddb = 'N') THEN
    IF
		  nvl(p_rec.description,
		      hr_api.g_number) <>
      nvl(ame_act_shd.g_old_rec.description,
			    hr_api.g_number) then
      l_argument := 'description';
      RAISE l_error;
    end if;
    IF nvl(p_rec.parameter,hr_api.g_number) <> nvl(ame_act_shd.g_old_rec.parameter,hr_api.g_number) THEN
         l_argument := 'parameter';
         RAISE l_error;
    END IF;

  END IF;
	--
	EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<chk_action_type_id      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the action_type_id is a foreign key to ame_action_types.action_type_id.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_action_type_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_action_type_id
  (p_effective_date   in date,
   p_action_type_id   in number) is
  l_proc              varchar2(72)  :=  g_package||'chk_action_type_id';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_action_types
      where
        action_type_id = p_action_type_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%notfound then
    close c_sel1;
    fnd_message.set_name('PER','AME_400575_ACT_TYP_NOT_EXIST');
    --  Need message here
    fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ACTION_TYPE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_action_type_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_positive_integer >----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_positive_integer
  ( p_string varchar2 ) is
	l_proc       varchar2(72)  :=  g_package||'chk_positive_integer';
  l_number       number;
  l_integer      integer;
begin
  l_number := to_number(p_string);
  l_integer := l_number;
  if(l_integer <> l_number
   or l_number <=0 ) then
    fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
    fnd_message.raise_error;
  end if;
exception
  when others then
    fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
    fnd_message.raise_error;
end chk_positive_integer;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_parameter >----------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the parameter does not contain a semicolon.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_action_id
--   p_object_version_number
--   p_effective_date
--   p_parameter
--   p_parameter_two
--
-- Post Success:
--   Processing continues if parameter does not contain a semicolon.
--   Also checks for duplicates.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_parameter
  (p_effective_date   in date,
   p_parameter        in ame_actions.parameter%type,
   p_parameter_two    in ame_actions.parameter_two%type,
	 p_action_type_id   in number,
   p_action_id        in number default null) is
  cursor c_sel1(p_name in varchar2) is
    select null
      from wf_roles
      where
        name = p_name
        and status = 'ACTIVE'
        and (expiration_date is null or
              p_effective_date < expiration_date)
        and  rownum < 2;
  l_proc       varchar2(72)  :=  g_package||'chk_parameter';
  l_exists     varchar2(1);
  l_par_count  number;
  l_action_type_name ame_action_types.name%TYPE;
  l_temp       number;
begin
  --The following call is a fix for bug 4380512
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'parameter'
    ,p_argument_value => p_parameter
    );
  if(p_parameter like '%;%') THEN
     fnd_message.set_name('PER','AME_400775_ACT_PARAM_NO_SC');
     --  Message needed
     fnd_message.raise_error;
  end if;
  select count(action_id)
    into l_par_count
    from ame_actions
    where action_type_id = p_action_type_id and
      parameter = p_parameter and
      ((parameter_two is null and p_parameter_two is null) or parameter_two = p_parameter_two) and
      p_effective_date between start_date and
         nvl(end_date - ame_util.oneSecond, p_effective_date) and
         (p_action_id is null or
          action_id <> p_action_id);
   if(l_par_count <> 0) then
     fnd_message.set_name('PER','AME_400604_DUP_ACTION_PARAM');
     fnd_message.raise_error;
   end if;
   select name
     into l_action_type_name
     from ame_action_types
     where action_type_id = p_action_type_id
       and p_effective_date between start_date and
           nvl(end_date - ame_util.oneSecond, p_effective_date);
  if(l_action_type_name = 'substitution'
     or l_action_type_name = 'hr position') then
    open c_sel1(p_name => p_parameter);
      fetch c_sel1 into l_exists;
      if c_sel1%notfound then
        close c_sel1;
        -- AT MESSAGE
        -- The name is not valid (doesn't exist in wf_roles.name).
        fnd_message.set_name('PER','AME_400605_INV_LM_ACTION_PARAM');
        fnd_message.raise_error;
      end if;
    close c_sel1;
  elsif (l_action_type_name in (
                                 'absolute job level'
                                ,'relative job level'
                                ,'manager then final approver'
                                ,'line-item job-level chains of authority'
                               )
        ) then
    --parameter should be of the form n{+,-}
    if(substr(p_parameter, length(p_parameter), 1) <> '+'
       and substr(p_parameter, length(p_parameter), 1) <> '-') then
       fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
       fnd_message.raise_error;
    end if;
    --check if the other part of parameter excluding +,- is a valid
    --number
    chk_positive_integer(substr(p_parameter, 1, length(p_parameter)-1));
  elsif (l_action_type_name in (
                                  'final approver only'
                                 ,'nonfinal authority'
                               )
        ) then
    --parameter should be in the form {A, R}n{+,-}
    if(substr(p_parameter,1,1) <> 'A'
       and substr(p_parameter,1,1) <> 'R'
       ) then
      fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
      fnd_message.raise_error;
    end if;
    if(substr(p_parameter, length(p_parameter), 1) <> '+'
       and substr(p_parameter, length(p_parameter), 1) <> '-') then
       fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
       fnd_message.raise_error;
    end if;
    --check if the string between {A,R} and {+,-} is a valid number
    chk_positive_integer(substr(p_parameter, 2, length(p_parameter)-2));
  elsif (l_action_type_name = 'dual chains of authority') then
    --parameter should be in the form {1,2}{A, R}n{+,-}
    if(substr(p_parameter,1,1) <> '1'
       and substr(p_parameter,1,1) <> '2') then
      fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
      fnd_message.raise_error;
    end if;
    if(substr(p_parameter,2,1) <> 'A'
       and substr(p_parameter,2,1) <> 'R'
       ) then
      fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
      fnd_message.raise_error;
    end if;
    if(substr(p_parameter, length(p_parameter), 1) <> '+'
       and substr(p_parameter, length(p_parameter), 1) <> '-') then
       fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
       fnd_message.raise_error;
    end if;
    --check if the string between {1,2}{A,R} and {+,-} is a valid number
    chk_positive_integer(substr(p_parameter, 3, length(p_parameter)-3));
  elsif (l_action_type_name = 'supervisory level') then
    --parameter should be in the form n[-]
    if(substr(p_parameter, length(p_parameter), 1) = '-') then
      chk_positive_integer(substr(p_parameter, 1, length(p_parameter)-1));
    else
      chk_positive_integer(p_parameter);
    end if;
  elsif(l_action_type_name = 'hr position level') then
    if(substr(p_parameter, length(p_parameter), 1) <> '+') then
      fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
      fnd_message.raise_error;
    end if;
    chk_positive_integer(substr(p_parameter, 1, length(p_parameter)-1) );
  elsif (l_action_type_name = 'final authority') then
    --cannot create actions for final authority
    fnd_message.set_name('PER','AME_400603_INVALID_ACT_PARAM');
    fnd_message.raise_error;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'PARAMETER') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_parameter;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_at_dyn_desc_act_desc_comb >--|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the ame_actions.description is not null if the
--   ame_action_types.dynamic_descripton is set to ame_util.booleanFalse.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_action_type_id
--   p_object_version_number
--   p_effective_date
--   p_description
--
-- Post Success:
--   Processing continues if parameter does not contain a semicolon.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_at_dyn_desc_act_desc_comb
  (p_effective_date   in date,
   p_action_type_id   in number,
   p_description      in ame_actions.description%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_at_dyn_desc_act_desc_comb';
  dynamicDescription ame_action_types.dynamic_description%type;
begin
  select dynamic_description
    into dynamicDescription
    from ame_action_types
    where
      action_type_id = p_action_type_id and
      p_effective_date between start_date and
         nvl(end_date - ame_util.oneSecond, p_effective_date);
  IF dynamicDescription = ame_util.booleanFalse THEN
	  IF p_description is null THEN
     fnd_message.set_name('PER','AME_400606_DYN_ACT_TYP_ACT_DES');
     --  Message needed
     fnd_message.raise_error;
    END IF;
  ELSif p_description is not null THEN
     fnd_message.set_name('PER','AME_400606_DYN_ACT_TYP_ACT_DES');
     --  Message needed
     fnd_message.raise_error;
	END IF;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'DESCRIPTION') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_at_dyn_desc_act_desc_comb;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<     chk_delete        >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   check that 1) Seeded actions cannot be deleted.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_action_id
--   p_object_version_number
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_delete
  (p_action_id   in number,
   p_object_version_number in number,
   p_effective_date        in date) is
  l_proc              varchar2(72)  :=  g_package||'chk_delete';
  tempCount integer;
  Cursor c_sel1 Is
    select null
      from ame_actions
      where
		    action_id = p_action_id and
        ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById and
        ame_utility_pkg.check_seeddb = 'N';
	l_exists varchar2(1);
begin
  -- Seeded actions cannot be deleted
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%found then
    close c_sel1;
    --
    fnd_message.set_name('PER','AME_400477_CANNOT_DEL_SEEDED');
    --  Message needed
    fnd_message.set_token('OBJECT','AME_ACTIONS.DELETE');
    fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ACTION_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_delete;
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
  (p_action_type_id                in number default hr_api.g_number
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
  (p_action_id                        in number
  ,p_action_type_id                   in number
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
      ,p_argument       => 'action_id'
      ,p_argument_value => p_action_id
      );
    --
    ame_act_shd.child_rows_exist
      (p_action_id => p_action_id
      ,p_start_date => p_validation_start_date
      ,p_end_date   => p_validation_end_date);
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in ame_act_shd.g_rec_type
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
  -- Validate Dependent Attributes
  chk_at_dyn_desc_act_desc_comb(p_effective_date => p_effective_date,
                                p_action_type_id => p_rec.action_type_id,
                                p_description => p_rec.description);
	-- Action Type Id
  chk_action_type_id(p_effective_date => p_effective_date,
                     p_action_type_id => p_rec.action_type_id);
  -- Parameter
  chk_parameter(p_effective_date => p_effective_date,
                p_parameter => p_rec.parameter,
                p_parameter_two => p_rec.parameter_two,
                p_action_type_id => p_rec.action_type_id);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_act_shd.g_rec_type
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
    (p_action_type_id                 => p_rec.action_type_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  -- Parameter
  chk_parameter(p_effective_date => p_effective_date,
                p_parameter => p_rec.parameter,
                p_parameter_two => p_rec.parameter_two,
                p_action_type_id => p_rec.action_type_id,
                p_action_id  => p_rec.action_id);
  -- chk_at_dyn_desc_act_desc_comb
  chk_at_dyn_desc_act_desc_comb(p_action_type_id => p_rec.action_type_id,
                                p_effective_date => p_effective_date,
                                p_description => p_rec.description);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_act_shd.g_rec_type
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
  chk_delete(p_action_id => p_rec.action_id,
             p_object_version_number => p_rec.object_version_number,
             p_effective_date => p_effective_date);
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_action_id =>  p_rec.action_id
 ,p_action_type_id =>  p_rec.action_type_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_act_bus;

/
