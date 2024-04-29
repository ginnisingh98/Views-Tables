--------------------------------------------------------
--  DDL for Package Body AME_CFV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CFV_BUS" as
/* $Header: amcfvrhi.pkb 120.2 2005/11/22 03:15 santosin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_cfv_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_NONUPD_VARIABLE_VALUES >------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether a variable value is updateable or not.Certain variables
--   cannot be reverted back to their previous value, once they have been set to a particular
--   value(Max Value).
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_id
--   p_effective_date
--   p_variable_name
--   p_variable_value
--
-- Post Success:
--   Processing continues if a valid operation is performed on the variable.
--
-- Post Failure:
--   An application error is raised if the operation is not valid for the variable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_nonupd_variable_values(p_application_id                 in   number
				   ,p_effective_date                  in   date
				   ,p_variable_name                   in   varchar2
				   ,p_variable_value		      in   varchar2
		                    ) IS
--
    cursor csr_variable_value(p_csr_application_id in number,p_csr_variable_name in varchar2) is
         select variable_value
           from ame_config_vars
          where application_id=p_csr_application_id
	    and variable_name=p_csr_variable_name
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'chk_nonupdateable_variable_values';
  l_oldVal   ame_config_vars.variable_value%TYPE;
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    --
    if(p_variable_name = 'allowAllApproverTypes' or p_variable_name = 'allowAllItemClassRules' or p_variable_name = 'allowFyiNotifications') then
      open csr_variable_value(p_application_id,p_variable_name);
      fetch csr_variable_value into l_oldVal;
      if(csr_variable_value%notfound) then
	close csr_variable_value;
	open csr_variable_value(0,p_variable_name);
	fetch csr_variable_value into l_oldVal;
      end if;
      close csr_variable_value;
      if(l_oldVal = 'yes' and (p_variable_value is null or p_variable_value <> 'yes')) then
        fnd_message.set_name('PER', 'AME_400653_CFV_NONUPD_VAL_YN');
	fnd_message.set_token('VARNAME',p_variable_name);
        fnd_message.raise_error;
      end if;
    elsif(p_variable_name = 'productionFunctionality') then
      open csr_variable_value(p_application_id,p_variable_name);
      fetch csr_variable_value into l_oldVal;
      if(csr_variable_value%notfound) then
	close csr_variable_value;
	open csr_variable_value(0,p_variable_name);
	fetch csr_variable_value into l_oldVal;
      end if;
      close csr_variable_value;
      if(l_oldVal = 'all'  and (p_variable_value is null or p_variable_value <> 'all')) then
        fnd_message.set_name('PER', 'AME_400654_CFV_NONUPD_VAL_PF');
	fnd_message.set_token('VARNAME',p_variable_name);
        fnd_message.raise_error;
      end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONFIG_VARS.APPLICATION_ID'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_nonupd_variable_values;
  --

--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_APPLICATION_ID >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether a valid default value already exists for the
--   configuration variable being populated.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid default configuration variable is found.
--
-- Post Failure:
--   An application error is raised if a default value has not been defined
--   for the configuration variable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_application_id(p_application_id                  in   number
                            ,p_effective_date                  in   date
                            ) IS
--
    cursor csr_application is
         select 1
           from ame_calling_apps
          where application_id=p_application_id
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_APPLICATION_ID';
  l_key      number;
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    --
    if(p_application_id <> ame_utility_pkg.defaultAmeAppId) then
      open csr_application;
      fetch csr_application into l_key;
      if(csr_application%notfound) then
        fnd_message.set_name('PER', 'AME_400474_INV_APPLICATION_ID');
        fnd_message.raise_error;
      end if;
      close csr_application;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONFIG_VARS.APPLICATION_ID'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_application_id;
  --
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_DEFAULT_CONFIG_VAR >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks if the application_id = 0 (i.e the default value of the
--   configuration variable).This check is performed before the deletion of a
--   configuration variable value.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if the application_id is not equal to zero i.e
--   the value is not the default value of the configuration variable.
--
-- Post Failure:
--   An application error is raised if an attempt is made to delete the
--   default value of the configuration variable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_default_config_var(p_application_id                  in   number
                                ,p_effective_date                  in   date
                                 ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_DEFAULT_CONFIG_VAR';
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    --
    if p_application_id = 0 then
      fnd_message.set_name('PER', 'AME_400773_DEF_CONFIG_DEL');
      fnd_message.raise_error;
    end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONFIG_VARS.APPLICATION_ID'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_default_config_var;
  --

--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_VARIABLE_NAME >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the Variable Name entered is a valid one.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_variable_name
--
-- Post Success:
--   Processing continues if a valid Variable Name has been entered.
--
-- Post Failure:
--   An application error is raised if the Variable Name is undefined.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_variable_name(p_variable_name                  in   varchar2) IS
--
  cursor csr_var_name(p_var_name varchar2) is
       select 'Y'
         from ame_config_vars
        where variable_name = p_var_name
          and application_id = ame_utility_pkg.defaultAmeAppId;
  l_proc     varchar2(72) := g_package || 'CHK_VARIABLE_NAME';
  l_key      varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'VARIABLE_NAME'
                              ,p_argument_value     => p_variable_name
                              );
    --
    -- Check if the varible name is one of the pre-defined name.
    --
    open csr_var_name(p_variable_name);
    fetch csr_var_name into l_key;
    if(csr_var_name%notfound) then
      close csr_var_name;
      fnd_message.set_name('PER', 'AME_400657_CFV_INV_VAR_NAME');
      fnd_message.raise_error;
    else
      close csr_var_name;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONFIG_VARS.VARIABLE_NAME'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_variable_name;
  --
--
-- ----------------------------------------------------------------------------
-- |------------------< ISVALID_FORWARDING_BEHAVIOUR >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the value entered for the configuration
--   variable 'forwardingBehaviors' is valid and in the right format or not.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_value
--
-- Post Success:
--   Processing continues if a valid 'forwardingBehaviors' value has been
--   entered.
--
-- Post Failure:
--   An application error is raised if the value is not in the correct format.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function isValid_Forwarding_Behaviour(p_value                    in   varchar2)
Return Boolean IS
--
  type profile_values is table of varchar2(20) index by binary_integer;
  l_proc                  varchar2(72) := g_package || 'ISVALID_FORWARDING_BEHAVIOUR';
  l_index                 number :=1;
  l_location              number :=1;
  l_count                 number :=0;
  AME_FWD_PRV_SAME_CHAIN     profile_values;
  AME_FWD_SUB_NOT_SAME_CHAIN profile_values;
  AME_ADHOC_FWD              profile_values;
  AME_BEHAVIOUR_VALUES       profile_values;
  function isExist(p_value                     in   varchar2
                  ,value_table                 in   profile_values
                  ) return boolean is
    isFound         boolean := false;
    begin
    for indx in 1..value_table.count
    loop
      if(value_table(indx) = p_value) then
        isFound :=  true;
      end if;
    end loop;
    return isFound;
    end;
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    --
    -- Populate the Profile Value Tables.
    --
    AME_FWD_PRV_SAME_CHAIN(1) := 'REMAND';
    AME_FWD_PRV_SAME_CHAIN(2) := 'FORWARDER_FORWARDEE';
    AME_FWD_PRV_SAME_CHAIN(3) := 'FORWARDEE_ONLY';
    AME_FWD_PRV_SAME_CHAIN(4) := 'IGNORE';
    AME_FWD_SUB_NOT_SAME_CHAIN(1) := 'FORWARDER_FORWARDEE';
    AME_FWD_SUB_NOT_SAME_CHAIN(2) := 'FORWARDEE_ONLY';
    AME_FWD_SUB_NOT_SAME_CHAIN(3) := 'REPEAT_FORWARDER';
    AME_FWD_SUB_NOT_SAME_CHAIN(4) := 'SKIP_FORWARDER';
    AME_FWD_SUB_NOT_SAME_CHAIN(5) := 'IGNORE';
    AME_ADHOC_FWD(1) := 'FORWARDER_FORWARDEE';
    AME_ADHOC_FWD(2) := 'FORWARDEE_ONLY';
    AME_ADHOC_FWD(3) := 'IGNORE';
    --
    -- Split the incoming values into 8 subparts.
    --
    while(l_index <> 0)
    loop
    l_index := instrb(p_value||':',':',l_location);
    l_count := l_count+1;
    AME_BEHAVIOUR_VALUES(l_count) := substr(p_value,l_location,l_index-l_location);
    l_location:=l_index+1;
    end loop;
    AME_BEHAVIOUR_VALUES.delete(l_count);
    l_count := l_count -1;
    --
    -- If total parameter count is not 8, then error has occurred.
    --
    if(l_count <> 8) then
      fnd_message.set_name('PER', 'AME_400658_CFV_INV_NUM_PRM');
      fnd_message.raise_error;
    end if;
    --
    -- Check for the values in respective profile value tables.
    --
    if not isExist(AME_BEHAVIOUR_VALUES(1),AME_FWD_PRV_SAME_CHAIN) then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',1);
      fnd_message.raise_error;
    end if;
    if not isExist(AME_BEHAVIOUR_VALUES(2),AME_FWD_PRV_SAME_CHAIN) then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',2);
      fnd_message.raise_error;
    end if;
    if not isExist(AME_BEHAVIOUR_VALUES(3),AME_FWD_SUB_NOT_SAME_CHAIN) then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',3);
      fnd_message.raise_error;
    end if;
    if not isExist(AME_BEHAVIOUR_VALUES(4),AME_FWD_SUB_NOT_SAME_CHAIN) then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',4);
      fnd_message.raise_error;
    end if;
    if not isExist(AME_BEHAVIOUR_VALUES(5),AME_FWD_PRV_SAME_CHAIN) then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',5);
      fnd_message.raise_error;
    end if;
    if not isExist(AME_BEHAVIOUR_VALUES(6),AME_FWD_PRV_SAME_CHAIN) then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',6);
      fnd_message.raise_error;
    end if;
    if not isExist(AME_BEHAVIOUR_VALUES(7),AME_ADHOC_FWD) then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',7);
      fnd_message.raise_error;
    end if;
    if not isExist(AME_BEHAVIOUR_VALUES(8),AME_ADHOC_FWD) then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',8);
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
    return true;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONFIG_VARS.FORWARDING_BEHAVIOUR'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
      return false;
  End isValid_Forwarding_Behaviour;
  --
--
-- ----------------------------------------------------------------------------
-- |------------------< ISVALID_RULE_PRIORITY_MODE >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the value entered for the configuration
--   variable 'rulePriorityModes' is valid and in the specified format or not.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_value
--
-- Post Success:
--   Processing continues if a valid 'rulePriorityModes' value has been
--   entered.
--
-- Post Failure:
--   An application error is raised if the value is not in the correct format.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function isValid_Rule_Priority_Mode(p_value                     in   varchar2)
Return Boolean IS
--
  l_proc                  varchar2(72) := g_package || 'ISVALID_RULE_PRIORITY_MODE';
  l_index                 number :=1;
  l_location              number :=1;
  l_count                 number :=0;
  l_priority              varchar2(20);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    --
    -- Split the incoming values into 8 subparts.
    --
    loop
    l_index := instrb(p_value||':',':',l_location);
    exit when (l_index = 0);
    l_count := l_count+1;
    l_priority := substr(p_value,l_location,l_index-l_location);
    if (l_priority is null or l_priority = '' or (l_priority <> 'disabled' and
         substr(l_priority,1,instr(l_priority,'_')) not in ('absolute_','relative_'))) then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',l_count);
      fnd_message.raise_error;
    end if;
    if not((l_priority = 'disabled')
    or (
       (substr(l_priority,1,instr(l_priority,'_')) in ('absolute_'
                                                       ,'relative_'
                                                       ))
        and
       (ame_util.isANonNegativeInteger(substr(l_priority,instr(l_priority,'_')+1)))
        and
       (substr(l_priority,instr(l_priority,'_')+1)<>'0')
       ))then
      fnd_message.set_name('PER', 'AME_400659_CFV_INV_PARAM');
      fnd_message.set_token('PARAMNUM',l_count);
      fnd_message.raise_error;
    end if;
    l_location:=l_index+1;
    end loop;
    --
    -- If total parameter count is not 8, then error has occurred.
    --
    if(l_count <> 8) then
      fnd_message.set_name('PER', 'AME_400660_CFV_INV_PRIORITY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
    return true;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONFIG_VARS.PRIORITY_MODE'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
      return false;
  End isValid_Rule_Priority_Mode;
  --
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_VARIABLE_VALUE >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the Value entered for the configuration
--   variable is valid and in the correct format or not.
--
-- Pre-Requisites:
--   chk_variable_name must have been validated.
--
-- In Parameters:
--   p_variable_name
--   p_variable_value
--
-- Post Success:
--   Processing continues if a valid configuration value has been entered.
--
-- Post Failure:
--   An application error is raised if the value entered is not defined or not
--   in the specified format.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_variable_value(p_variable_name                  in   varchar2
                            ,p_variable_value                 in   varchar2
                            ) IS
--
  cursor csr_role is
      select 'Y'
        from wf_roles
       where name = p_variable_value
         and status='ACTIVE';
  l_proc     varchar2(72) := g_package || 'CHK_VARIABLE_VALUE';
  l_key      varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'VARIABLE_VALUE'
                              ,p_argument_value     => p_variable_value
                              );
    --
    -- Check if the varible value is in appropriate format.
    --
    if hr_multi_message.no_all_inclusive_error
                   (p_check_column1 => 'AME_CONFIG_VARS.VARIABLE_NAME') then
      if(p_variable_name = 'adminApprover') then
        open csr_role;
        fetch csr_role into l_key;
        if(csr_role%notfound) then
          close csr_role;
          fnd_message.set_name('PER', 'AME_400661_CFV_INV_VAL');
	  fnd_message.set_token('VARNAME',p_variable_name);
          fnd_message.raise_error;
        else
          close csr_role;
        end if;

      elsif(p_variable_name = 'allowAllApproverTypes'
         or p_variable_name = 'allowAllItemClassRules'
         or p_variable_name = 'allowFyiNotifications'
         or p_variable_name = 'distributedEnvironment'
           ) then
        if(p_variable_value) not in ('yes','no') then
          fnd_message.set_name('PER', 'AME_400661_CFV_INV_VAL');
	  fnd_message.set_token('VARNAME',p_variable_name);
          fnd_message.raise_error;
        end if;

      elsif(p_variable_name = 'currencyConversionWindow'
         or p_variable_name = 'purgeFrequency'
           ) then
        if (trim(p_variable_value)='0')
        or not (ame_util.isANonNegativeInteger(p_variable_value))
           then
          fnd_message.set_name('PER', 'AME_400662_CFV_NEG_VAL');
	  fnd_message.set_token('VARNAME',p_variable_name);
          fnd_message.raise_error;
        end if;

      elsif(p_variable_name = 'forwardingBehaviors') then
        if not isValid_Forwarding_Behaviour(p_variable_value) then
          fnd_message.set_name('PER', 'AME_400661_CFV_INV_VAL');
	  fnd_message.set_token('VARNAME',p_variable_name);
          fnd_message.raise_error;
        end if;

      /*elsif(p_variable_name = 'helpPath'
         or p_variable_name = 'htmlPath'
         or p_variable_name = 'imagePath'
         or p_variable_name = 'portalUrl'
           ) then
      */
      elsif(p_variable_name = 'productionFunctionality') then
        if p_variable_value not in ('none'
                                   ,'approver'
                                   ,'transaction'
                                   ,'all'
                                   ) then
          fnd_message.set_name('PER', 'AME_400661_CFV_INV_VAL');
	  fnd_message.set_token('VARNAME',p_variable_name);
          fnd_message.raise_error;
        end if;

      elsif(p_variable_name = 'repeatedApprovers') then
        if p_variable_value not in ('ONCE_PER_TRANSACTION'
                                   ,'ONCE_PER_ITEM_CLASS'
                                   ,'ONCE_PER_ITEM'
                                   ,'ONCE_PER_SUBLIST'
                                   ,'ONCE_PER_ACTION_TYPE'
                                   ,'ONCE_PER_GROUP_OR_CHAIN'
                                   ,'EACH_OCCURRENCE'
                                   ) then
          fnd_message.set_name('PER', 'AME_400661_CFV_INV_VAL');
	  fnd_message.set_token('VARNAME',p_variable_name);
          fnd_message.raise_error;
        end if;

      elsif(p_variable_name = 'rulePriorityModes') then
        if not isValid_Rule_Priority_Mode(p_variable_value) then
          fnd_message.set_name('PER', 'AME_400661_CFV_INV_VAL');
	  fnd_message.set_token('VARNAME',p_variable_name);
          fnd_message.raise_error;
        end if;
      end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONFIG_VARS.VARIABLE_VALUE'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_variable_value;
  --
--
-- ----------------------------------------------------------------------------
-- |-------------------< CHK_APPLICATION_VARIABLE_NAME >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the configuration variable has already been
--   defined, for the given transaction type.
--
-- Pre-Requisites:
--   chk_application_id and chk_variable_name must have been validated.
--
-- In Parameters:
--   p_variable_name
--   p_application_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if the configuration variable is not being
--   duplicated.
--
-- Post Failure:
--   An application error is raised if the configuration variable has already
--   been defined.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_application_variable_name(p_variable_name       in   varchar2
                                       ,p_application_id      in   number
                                       ,p_effective_date      in   date
                                       ) IS
--
  cursor csr_var_name is
       select 'Y'
         from ame_config_vars
        where variable_name = p_variable_name
          and application_id = p_application_id
          and p_effective_date between start_date
                and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_VARIABLE_NAME';
  l_key      varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    if (hr_multi_message.no_all_inclusive_error
                   (p_check_column1 => 'AME_CONFIG_VARS.VARIABLE_NAME')
    and hr_multi_message.no_all_inclusive_error
                   (p_check_column1 => 'AME_CONFIG_VARS.APPLICATION_ID')) then
      --
      -- Check if the varible name is already defined for the application.
      --
      if(p_application_id <> ame_utility_pkg.defaultAmeAppId) then
        --
        -- Check if a non-overridable config variable has been overridden.
        --
        if p_variable_name in ('distributedEnvironment'
                              ,'helpPath'
                              ,'htmlPath'
                              ,'imagePath'
                              ,' portalUrl'
                              ) then
          fnd_message.set_name('PER', 'AME_400655_INV_NO_TT_VAL');
          fnd_message.raise_error;
        end if;
        open csr_var_name;
        fetch csr_var_name into l_key;
        if(csr_var_name%found) then
          close csr_var_name;
          fnd_message.set_name('PER', 'AME_400656_DUP_VAR_VAL');
	  fnd_message.set_token('VARNAME',p_variable_name);
          fnd_message.raise_error;
        else
          close csr_var_name;
        end if;
      else
        open csr_var_name;
        fetch csr_var_name into l_key;
        if(csr_var_name%found) then
          close csr_var_name;
          fnd_message.set_name('PER', 'AME_400656_DUP_VAR_VAL');
	  fnd_message.set_token('VARNAME',p_variable_name);
          fnd_message.raise_error;
        else
          close csr_var_name;
        end if;
      end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONFIG_VARS.APPLICATION_VARIABLE_NAME'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_application_variable_name;
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
  ,p_rec             in ame_cfv_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_cfv_shd.api_updating
      (p_application_id =>  p_rec.application_id
 ,p_variable_name =>  p_rec.variable_name
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
  (p_application_id                   in number
  ,p_variable_name                    in varchar2
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
      ,p_argument       => 'application_id'
      ,p_argument_value => p_application_id
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in ame_cfv_shd.g_rec_type
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
  --
  chk_application_id(p_application_id  => p_rec.application_id
                    ,p_effective_date  => p_effective_date
                    );
  chk_variable_name(p_variable_name  => p_rec.variable_name);
  chk_variable_value(p_variable_name   => p_rec.variable_name
                    ,p_variable_value  => p_rec.variable_value
                    );
  chk_application_variable_name(p_variable_name  => p_rec.variable_name
                               ,p_application_id => p_rec.application_id
                               ,p_effective_date => p_effective_date
                               );
  chk_nonupd_variable_values(p_application_id => p_rec.application_id
				   ,p_effective_date => p_effective_date
				   ,p_variable_name  => p_rec.variable_name
				   ,p_variable_value => p_rec.variable_value
	                            );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_cfv_shd.g_rec_type
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
  -- Additional checks added
  --
  chk_application_id(p_application_id  => p_rec.application_id
                    ,p_effective_date  => p_effective_date
                    );
  chk_variable_name (p_variable_name   => p_rec.variable_name);
  chk_variable_value(p_variable_name   => p_rec.variable_name
                    ,p_variable_value  => p_rec.variable_value
                    );
  chk_nonupd_variable_values(p_application_id => p_rec.application_id
				   ,p_effective_date => p_effective_date
				   ,p_variable_name  => p_rec.variable_name
				   ,p_variable_value => p_rec.variable_value
	                            );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_cfv_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
  l_call_stack  varchar2(4096);
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
    ,p_application_id =>  p_rec.application_id
    ,p_variable_name =>  p_rec.variable_name
    );

  l_call_stack := dbms_utility.format_call_stack;
  if instrb(l_call_stack,'AME_TRANS_TYPE_API') = 0 then
    chk_nonupd_variable_values
      (p_application_id => p_rec.application_id
      ,p_effective_date => p_effective_date
      ,p_variable_name  => p_rec.variable_name
      ,p_variable_value => p_rec.variable_value);
  end if;
  chk_default_config_var
    (p_application_id => p_rec.application_id
    ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_cfv_bus;

/
