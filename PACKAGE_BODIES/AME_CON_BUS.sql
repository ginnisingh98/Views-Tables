--------------------------------------------------------
--  DDL for Package Body AME_CON_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CON_BUS" as
/* $Header: amconrhi.pkb 120.6 2006/01/12 22:43 pvelugul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_con_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_CONDITION_ID >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the mandatory column condition_id  has been
--   populated or not.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_condition_id
--
-- Post Success:
--   Processing continues if a valid condition_id has been entered.
--
-- Post Failure:
--   An application error is raised if the condition_id is undefined.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_condition_id(p_condition_id                     in   number) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_CONDITION_ID';
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'CONDITION_ID'
                              ,p_argument_value     => p_condition_id
                              );
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONDITIONS.CONDITION_ID'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_condition_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_CONDITION_TYPE >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates whether the mandatory column condition_type
--   contains a lookup value.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_condition_type
--
-- Post Success:
--   Processing continues if a valid condition_type has been entered.
--
-- Post Failure:
--   An application error is raised if the condition_type is not from the
--   specified lookup.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_condition_type(p_condition_type                in   varchar2) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_CONDITION_TYPE';
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'CONDITION_TYPE'
                              ,p_argument_value     => p_condition_type
                              );
    -- Check if the value exist in the lookup list
    if p_condition_type not in(ame_util.ordinaryConditionType
                              ,ame_util.exceptionConditionType
                              ,ame_util.listModConditionType
                              ) then
      fnd_message.set_name('PER','AME_400496_INV_CON_TYPE');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_CONDITIONS.CONDITION_TYPE'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_condition_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_ATTRIBUTE_ID >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensure that one of the following combinations are entered
--
--   If condition_type is ListModificationType then attribute_id must be 0
--   Else attribute_id must be already defined in ame_attributes table and
--   must be valid over the given date ranges
--
-- Pre-Requisites:
--   chk_condition_type must have been validated.
--
-- In Parameters:
--   p_attribute_id
--   p_condition_type
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid attribute_id has been entered.
--
-- Post Failure:
--   An application error is raised if the attribute_id is not equal to zero
--   (for a ListModificationType condition) or when the attribute_id is not
--   defined in ame_attributes table
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_attribute_id(p_attribute_id                      in   number
                          ,p_condition_type                    in   varchar2
                          ,p_effective_date                    in   date
                          ) IS
--
  cursor csr_name is
         select attribute_id
           from ame_attributes
          where attribute_id=p_attribute_id
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_ATTRIBUTE_ID';
  l_key      number;
--
  Begin
    hr_utility.set_location(' Entering:'||l_proc,10);
    -- Check whether any dependencies on CONDITION_KEY have failed
    if hr_multi_message.no_all_inclusive_error
                   (p_check_column1 => 'AME_CONDITIONS.CONDITION_TYPE') then
      hr_api.mandatory_arg_error(p_api_name           => l_proc
                                ,p_argument           => 'ATTRIBUTE_ID'
                                ,p_argument_value     => p_attribute_id
                                );
      -- Check if the condition_type is ListModification type. Else check if
      -- the value exists in the parent table
      if(p_condition_type <> ame_util.listModConditionType) then
        open csr_name;
        fetch csr_name into l_key;
        if(csr_name%notfound) then
          close csr_name;
          fnd_message.set_name('PER','AME_400473_INV_ATTRIBUTE_ID');
          fnd_message.raise_error;
        end if;
        close csr_name;
      else
        if(p_attribute_id <> 0) then
          fnd_message.set_name('PER','AME_400497_ATTR_ID_NOT_ZERO');
          fnd_message.raise_error;
        end if;
      end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_CONDITIONS.ATTRIBUTE_ID'
                     ) then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
    End chk_attribute_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_PARAMETER_ONE >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensure that one of the following combinations are entered
--
--   If attribute_type is boolean then parameter_one must not be null. For
--   other types of attributes(excluding string types) either parameter_one or
--   parameter_two must not be null. The string attribute type is a special
--   case wherein both the parameters must be null.
--
-- Pre-Requisites:
--   chk_attribute_id must have been validated.
--
-- In Parameters:
--   p_parameter_one
--   p_parameter_two
--   p_attribute_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if valid parameters(parameter_one and parameter_two)
--   have been entered.
--
-- Post Failure:
--   An application error is raised if the parameters entered are not following
--   the aforementioned rule
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_parameter_one(p_parameter_one                    in   varchar2
                           ,p_parameter_two                    in   varchar2
                           ,p_attribute_id                     in   number
                           ,p_effective_date                   in   date
                           ) IS
--
  cursor csr_atr_type is
         select attribute_type
           from ame_attributes
          where attribute_id = p_attribute_id
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_PARAMETER_ONE';
  l_key      varchar2(30);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    -- Check for dependency issues with ATTRIBUTE_ID
    if hr_multi_message.no_all_inclusive_error
                (p_check_column1   => 'AME_CONDITIONS.ATTRIBUTE_ID') then
      -- Check if the attribute_type is not ame_util.stringType
      open csr_atr_type;
      fetch csr_atr_type into l_key;
      close csr_atr_type;
      if(l_key = ame_util.booleanAttributeType) then
        hr_api.mandatory_arg_error(p_api_name           => l_proc
                                  ,p_argument           => 'PARAMETER_ONE'
                                  ,p_argument_value     => p_parameter_one
                                  );
      elsif(l_key <> ame_util.stringAttributeType) then
        if(p_parameter_one is null and p_parameter_two is null) then
          fnd_message.set_name('PER','AME_400330_CND_NULL_LUB');
          fnd_message.raise_error;
        end if;
      end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                  (p_associated_column1 => 'AME_CONDITIONS.PARAMETER_ONE'
                  ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_parameter_one;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_PARAMETERS >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensure that one of the following combinations are entered
--
--   For Ordinary and Exception type conditions, if the attribute is of type
--   Date,Number(with no approver_type)and Currency, either parameter1 or
--   parameter2 can exist with the other being null.If both exist, then
--   parameter1 must be less than parameter2 or they must be equal.For Number
--   attributes associated to an approver, both parameters must be equal.A
--   string attribute must have both parameters set to null, while a boolean
--   attribute must have parameter1 set to either 'true' or 'false'
--
--   Conditions of type ListModConditionTypes must have their parameter_one
--   set to either ame_util.anyApprover or ame_util.finalApprover,while
--   parameter2 must reference a valid WF_Role.
--
-- Pre-Requisites:
--   chk_condition_type,chk_attribute_id and chk_parameter_one must have been
--   validated.
--
-- In Parameters:
--   p_condition_type
--   p_attribute_id
--   p_parameter_one
--   p_parameter_two
--   p_effective_date
--
-- Post Success:
--   Processing continues if valid parameters(parameter_one and parameter_two)
--   have been entered.
--
-- Post Failure:
--   An application error is raised if the parameters entered are not following
--   the aforementioned rule
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_parameters(p_condition_type                      in   varchar2
                        ,p_attribute_id                        in   number
                        ,p_parameter_one                       in   varchar2
                        ,p_parameter_two                       in   varchar2
                        ,p_effective_date                      in   date
                        ) IS
--
  cursor csr_atr_type is
         select attribute_type,approver_type_id
           from ame_attributes
          where attribute_id = p_attribute_id
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  cursor csr_wf_role(p_name varchar2,p_date date) is
         select 'Y'
           from wf_roles
          where name = p_name
            and status='ACTIVE';
  l_proc          varchar2(72) := g_package || 'CHK_PARAMETERS';
  l_key           varchar2(30);
  l_key_approver  number;
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    -- Check for dependency over CONDITION_TYPE.ATTRIBUTE_ID and PARAMETER_ONE
    if hr_multi_message.no_all_inclusive_error
                     (p_check_column1  => 'AME_CONDITIONS.CONDITION_TYPE'
                     ,p_check_column2  => 'AME_CONDITIONS.ATTRIBUTE_ID'
                     ,p_check_column3  => 'AME_CONDITIONS.PARAMETER_ONE'
                     ) then
      if(p_condition_type = ame_util.ordinaryConditionType)
        or (p_condition_type = ame_util.exceptionConditionType) then
        open csr_atr_type;
        fetch csr_atr_type into l_key,l_key_approver;
        close csr_atr_type;
        -- Determine the attribute type
        if(l_key = ame_util.dateAttributeType) then
          -- Either one parameter ( of parameter1 or parametr2) can exist with
          -- the other being null.If both exist, then parameter1 must be less
          -- than parameter2 or they must be equal.
          if(to_date(nvl(p_parameter_one,p_parameter_two),'yyyy:mm:dd:hh24:mi:ss')
              >to_date(nvl(p_parameter_two,p_parameter_one),'yyyy:mm:dd:hh24:mi:ss'))
          then
            fnd_message.set_name('PER','AME_400186_CON_START_LESS_END');
            fnd_message.raise_error;
          end if;
        elsif(l_key = ame_util.currencyAttributeType) then
          -- Either one parameter ( of parameter1 or parametr2) can exist with
          -- the other being null.If both exist, then parameter1 must be less
          -- than parameter2 or they must be equal.
          if(to_number(nvl(p_parameter_one, p_parameter_two))> to_number(nvl(p_parameter_two, p_parameter_one)))
          then
            fnd_message.set_name('PER','AME_400187_CON_LWR_LESS_UPP');
            fnd_message.raise_error;
          end if;
        elsif(l_key = ame_util.numberAttributeType) then
          -- When there is no approver, Either one parameter ( of parameter1 or
          -- parameter2) can exist with the other being null.If both exist, then
          -- parameter1 must be less than parameter2 or they must be equal.
          if(l_key_approver is null) then
            if(to_number(nvl(p_parameter_one, p_parameter_two))> to_number(nvl(p_parameter_two, p_parameter_one)))
            then
              fnd_message.set_name('PER','AME_400187_CON_LWR_LESS_UPP');
              fnd_message.raise_error;
            end if;
          else
            if(p_parameter_one <> p_parameter_two) then
              fnd_message.set_name('PER','AME_400498_INV_APPROVER_PARAMS');
              fnd_message.raise_error;
            end if;
          end if;
        elsif(l_key = ame_util.stringAttributeType) and
              not (p_parameter_one is null and p_parameter_two is null) then
          fnd_message.set_name('PER','AME_400499_INV_STR_PARAMS');
          fnd_message.raise_error;
        elsif(l_key = ame_util.booleanAttributeType) and
              not (p_parameter_one in (ame_util.booleanAttributeTrue,ame_util.booleanAttributeFalse)
                    and p_parameter_two is null) then
          fnd_message.set_name('PER','AME_400500_INV_BOOL_PARAMS');
          fnd_message.raise_error;
        end if;
      elsif(p_condition_type = ame_util.listModConditionType) then
        open csr_wf_role(p_parameter_two,p_effective_date);
        fetch csr_wf_role into l_key;
        if(csr_wf_role%notfound) or
           not (p_parameter_one in (ame_util.anyApprover
                                   ,ame_util.finalApprover)) then
          close csr_wf_role;
          fnd_message.set_name('PER','AME_400501_INV_LMCOND_PARAM');
          fnd_message.raise_error;
        end if;
        close csr_wf_role;
      end if;
    end if;
  ----
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                      (p_associated_column1 => 'AME_CONDITIONS.PARAMETERS'
                      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_parameters;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_PARAMETER_THREE >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensure that one of the following combinations are entered
--
--   For conditions of type ordinaryConditionType or exceptionConditionType, if
--   attribute_id represents an Currency attribute, parameter_three must store
--   the currency code.Otherwise, parameter_three must be null.
--
-- Pre-Requisites:
--   chk_condition_type and chk_attribute_id must have been validated.
--
-- In Parameters:
--   p_parameter_three
--   p_condition_type
--   p_attribute_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if valid parameter_three has been entered.
--
-- Post Failure:
--   An application error is raised if the parameter_three entered does not
--   follow the aforementioned rule
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_parameter_three(p_parameter_three                in   varchar2
                             ,p_condition_type                 in   varchar2
                             ,p_attribute_id                   in   number
                             ,p_effective_date                 in   date
                             ) IS
--
  cursor csr_atr_type is
         select attribute_type
           from ame_attributes
          where attribute_id = p_attribute_id
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  cursor csr_cur_code(p_currency_code varchar2) is
         select currency_code
           from fnd_currencies
          where currency_code = p_currency_code;
  l_proc     varchar2(72) := g_package || 'CHK_PARAMETER_THREE';
  l_key      varchar2(30);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    -- Check for dependency over CONDITION_TYPE, ATTRIBUTE_ID
    if hr_multi_message.no_all_inclusive_error
                     (p_check_column1  => 'AME_CONDITIONS.CONDITION_TYPE'
                     ,p_check_column2  => 'AME_CONDITIONS.ATTRIBUTE_ID'
                     ) then
      -- Check condition_type and attribute_type.
      if(p_condition_type = ame_util.ordinaryConditionType or
          p_condition_type = ame_util.exceptionConditionType)
      then
        open csr_atr_type;
        fetch csr_atr_type into l_key;
        close csr_atr_type;
        if(l_key = ame_util.currencyAttributeType) then
          open csr_cur_code(p_parameter_three);
          fetch csr_cur_code into l_key;
          if(csr_cur_code%notfound) then
            close csr_cur_code;
            fnd_message.set_name('PER','AME_400502_INV_CURR_CODE');
            fnd_message.raise_error;
          end if;
          close csr_cur_code;
        elsif(p_parameter_three is not null) then
          fnd_message.set_name('PER','AME_400503_COND_PAR3_NOT_NULL');
          fnd_message.raise_error;
        end if;
      end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
               (p_associated_column1 => 'AME_CONDITIONS.PARAMETER_THREE'
               ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_parameter_three;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< CHK_UNIQUE >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a duplicate condition with the same set of
--   values for condition_type, attribute_id, parameter_one, parameter_two,
--   parameter_three, include_lower_limit, include_upper_limit does not exist.
--
-- Pre-Requisites:
--   chk_condition_type, chk_attribute_id, chk_limits, chk_parameter_one and
--   chk_parameter_three must have been validated.
--
-- In Parameters:
--   p_rec
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid record has been entered.
--
-- Post Failure:
--   An application error is raised if the record entered does not
--   follow the aforementioned rule
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_unique(p_rec                        in   ame_con_shd.g_rec_type
                    ,p_effective_date             in   date
                    ) IS
--
  cursor csr_name is
         select condition_id
           from ame_conditions
          where condition_type    = p_rec.condition_type
            and nvl(parameter_one, hr_api.g_varchar2)
                  = nvl(p_rec.parameter_one, hr_api.g_varchar2)
            and nvl(parameter_two, hr_api.g_varchar2)
                  = nvl(p_rec.parameter_two, hr_api.g_varchar2)
            and nvl(parameter_three, hr_api.g_varchar2)
                  = nvl(p_rec.parameter_three, hr_api.g_varchar2)
            and nvl(include_lower_limit, hr_api.g_varchar2)
                  = nvl(p_rec.include_lower_limit, hr_api.g_varchar2)
            and nvl(include_upper_limit, hr_api.g_varchar2)
                  = nvl(p_rec.include_upper_limit, hr_api.g_varchar2)
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date)
            and attribute_id = p_rec.attribute_id
            and attribute_id not in ( select attribute_id
                                        from ame_attributes
                                       where attribute_type = ame_util.stringAttributeType
                                         and p_effective_date between
                                               start_date and
                                               nvl(end_date - ame_util.oneSecond, p_effective_date)
                                    );
  l_proc     varchar2(72) := g_package || 'CHK_UNIQUE';
  l_key      number;
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    -- check for dependency over CONDITION_TYPE, ATTRIBUTE_ID
    -- PARAMETER_ONE,PARAMETER_THREE and LIMITS
    if hr_multi_message.no_all_inclusive_error
                     (p_check_column1  => 'AME_CONDITIONS.CONDITION_TYPE'
                     ,p_check_column2  => 'AME_CONDITIONS.ATTRIBUTE_ID'
                     ,p_check_column3  => 'AME_CONDITIONS.PARAMETER_ONE'
                     ,p_check_column4  => 'AME_CONDITIONS.PARAMETER_THREE'
                     ,p_check_column5  => 'AME_CONDITIONS.LIMITS'
                     ) then
      open csr_name;
      fetch csr_name into l_key;
      -- and l_key <> p_rec.condition_id
      if(csr_name%found) then
        if l_key = p_rec.condition_id then
          null;
        else
          close csr_name;
          fnd_message.set_name('PER','AME_400183_CON_ALRDY_EXISTS');
          fnd_message.raise_error;
        end if;
      end if;
      close csr_name;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                           (p_associated_column1 => 'AME_CONDITIONS.UNIQUE'
                           ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_unique;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< CHK_LIMITS >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that for a boolean attribute, limits are not
--   defined. For other attributes with either parameter_one or parameter_two
--   or both defined, the limits must exist only when the associated parameter
--   (lower limit for parameter_one and upper limit for parameter_two) exist.
--   For equal parameters both limits must be set to 'Y'
--
-- Pre-Requisites:
--   chk_condition_type, chk_attribute_id and chk_parameters must have been
--   validated.
--
-- In Parameters:
--   p_condition_type
--   p_attribute_id
--   p_parameter_one
--   p_parameter_two
--   p_include_lower_limit
--   p_include_upper_limit
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid parameters have been entered.
--
-- Post Failure:
--   An application error is raised if the parameters entered do not follow the
--   aforementioned rule
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_limits(p_condition_type                           in   varchar2
                    ,p_attribute_id                             in   number
                    ,p_parameter_one                            in   varchar2
                    ,p_parameter_two                            in   varchar2
                    ,p_include_lower_limit                      in   varchar2
                    ,p_include_upper_limit                      in   varchar2
                    ,p_effective_date                           in   date
                    ) IS
--
  cursor csr_atr_type is
         select attribute_type
           from ame_attributes
          where attribute_id = p_attribute_id
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_LIMITS';
  l_key      varchar2(30);
--
  Begin
    hr_utility.set_location( 'Entering:'||l_proc,10 );
    if hr_multi_message.no_all_inclusive_error
                     (p_check_column1  => 'AME_CONDITIONS.CONDITION_TYPE'
                     ,p_check_column2  => 'AME_CONDITIONS.ATTRIBUTE_ID'
                     ,p_check_column3  => 'AME_CONDITIONS.PARAMETERS'
                     ) then
      if(p_condition_type <> ame_util.listModConditionType) then
        open csr_atr_type;
        fetch csr_atr_type into l_key;
        close csr_atr_type;
        if (l_key = ame_util.booleanAttributeType) then
          if not(p_include_lower_limit is null and p_include_upper_limit is null)
          then
            fnd_message.set_name('PER','AME_400504_INV_BOOL_LIMITS');
            fnd_message.raise_error;
          end if;
        else
          -- The parameters 1 and 2 decide the existence of the appopriate limits
          if(p_parameter_one is null and p_include_lower_limit is not null)
              or(p_parameter_one is not null and (p_include_lower_limit is null
                or p_include_lower_limit not in
                  (ame_util.booleanTrue,ame_util.booleanFalse))) then
            fnd_message.set_name('PER','AME_400506_INV_LOWER_LIMIT');
            fnd_message.raise_error;
          end if;
          if(p_parameter_two is null and p_include_upper_limit is not null)
              or (p_parameter_two is not null and (p_include_upper_limit is null
                or p_include_upper_limit not in
                  (ame_util.booleanTrue,ame_util.booleanFalse))) then
            fnd_message.set_name('PER','AME_400505_INV_UPPER_LIMIT');
            fnd_message.raise_error;
          end if;
          if((p_parameter_one = p_parameter_two) and
             (p_include_lower_limit <> ame_util.booleanTrue or
               p_include_upper_limit <> ame_util.booleanTrue)
            ) then
            fnd_message.set_name('PER','AME_400678_CON_LMT_VAL_YES');
            fnd_message.raise_error;
          end if;
        end if;
      else
        if not(p_include_lower_limit is null and p_include_upper_limit is null)
        then
          fnd_message.set_name('PER','AME_400507_INV_LMCOND_LIMITS');
          fnd_message.raise_error;
        end if;
      end if;
    end if;
--
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONDITIONS.LIMITS'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_limits;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_CONDITION_KEY >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a non-null and a unique condition_key is
--   entered. Also check is done to ensure that condition_key does not start
--   with '@' character.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_condition_key
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid condition_key has been entered.
--
-- Post Failure:
--   An application error is raised if the condition_key is either null or
--   non-unique. Error is also thrown when the condition_key starts with '@'.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_condition_key(p_condition_key                      in   varchar2
                           ,p_effective_date                     in   date
                           ) IS
--
  cursor csr_name is
         select 'Y'
           from ame_conditions
          where condition_key = p_condition_key
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_CONDITION_KEY';
  l_key      varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'CONDITION_KEY'
                              ,p_argument_value     => p_condition_key
                              );
  -- Check if the value already exists
    open csr_name;
    fetch csr_name into l_key;
    if(csr_name%found) then
      close csr_name;
      fnd_message.set_name('PER','AME_400360_CND_KEY_EXIST');
      fnd_message.raise_error;
    elsif(substr(p_condition_key,1,1) = '@') then
      close csr_name;
      fnd_message.set_name('PER','AME_400364_COND_KEY_SYMBOL');
      fnd_message.raise_error;
    end if;
    close csr_name;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                  (p_associated_column1 => 'AME_CONDITIONS.CONDITION_KEY'
                  ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_condition_key;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_delete >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check whether any valid child records exist for
--   the given condition(condition_id). This is essential to prevent records
--   from being orphaned
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_condition_id
--   p_effective_date
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
procedure chk_delete(p_condition_id                              in   number
                    ,p_effective_date                            in   date
                    ) IS
--
  cursor csr_name is
         select 'Y'
           from ame_condition_usages
          where condition_id = p_condition_id
            and ((p_effective_date between start_date
                    and nvl(end_date - ame_util.oneSecond, p_effective_date))
                  or(p_effective_date < start_date and
                      p_effective_date <= nvl(end_date - ame_util.oneSecond, p_effective_date))
                );
--  cursor c_sel2 is
--    select null
--      from ame_conditions
--      where ame_utility_pkg.check_seeddb = 'N'
--        and ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById
--       and condition_id = p_condition_id
--        and p_effective_date between start_date and
--             nvl(end_date - (1/86400), p_effective_date);

  l_proc     varchar2(72) := g_package || 'CHK_DELETE';
  l_key      varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    -- Check if the value already exists
    open csr_name;
    fetch csr_name into l_key;
    if(csr_name%found) then
      close csr_name;
      fnd_message.set_name('PER','AME_400193_CON_IN_USE');
      fnd_message.raise_error;
    end if;
    close csr_name;

--    open c_sel2;
--    fetch c_sel2 into l_key;
--    if c_sel2%found then
--      close c_sel2;
--      fnd_message.set_name('PER', 'AME_400477_CANNOT_DEL_SEEDED');
--      fnd_message.set_token('OBJECT', 'CONDITION');
--      fnd_message.raise_error;
--    end if;
--    close c_sel2;

    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                       (p_associated_column1 => 'AME_CONDITIONS.DELETE'
                       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_delete;
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
  ,p_rec             in ame_con_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_con_shd.api_updating
      (p_condition_id =>  p_rec.condition_id
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
  -- CONDITION_TYPE is non-updateable
   if nvl(p_rec.condition_type, hr_api.g_varchar2) <>
       nvl(ame_con_shd.g_old_rec.condition_type,hr_api.g_varchar2) then
     hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'CONDITION_TYPE'
          ,p_base_table => ame_con_shd.g_tab_nam
          );
  end if;
--
-- ATTRIBUTE_ID is non-updateable
   if nvl(p_rec.attribute_id, hr_api.g_number) <>
       nvl(ame_con_shd.g_old_rec.attribute_id,hr_api.g_number ) then
     hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'ATTRIBUTE_ID'
          ,p_base_table => ame_con_shd.g_tab_nam
          );
  end if;
--
-- CONDITION_KEY is non-updateable
  if nvl(p_rec.condition_key, hr_api.g_varchar2) <>
       nvl(ame_con_shd.g_old_rec.condition_key,hr_api.g_varchar2 ) then
     hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'CONDITION_KEY'
          ,p_base_table => ame_con_shd.g_tab_nam
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
  (p_condition_id                     in number
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
      ,p_argument       => 'condition_id'
      ,p_argument_value => p_condition_id
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
  (p_rec                   in ame_con_shd.g_rec_type
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
  -- User Entered calls to validate procedures
  -- chk_condition_id(p_rec.condition_id);

  chk_condition_type(p_rec.condition_type);

  chk_attribute_id(p_rec.attribute_id
                  ,p_rec.condition_type
                  ,p_effective_date
                  );

  chk_condition_key(p_rec.condition_key
                   ,p_effective_date
                   );

  chk_parameter_one(p_rec.parameter_one
                   ,p_rec.parameter_two
                   ,p_rec.attribute_id
                   ,p_effective_date
                   );

  chk_parameters(p_rec.condition_type
                ,p_rec.attribute_id
                ,p_rec.parameter_one
                ,p_rec.parameter_two
                ,p_effective_date
                );

  chk_parameter_three(p_rec.parameter_three
                     ,p_rec.condition_type
                     ,p_rec.attribute_id
                     ,p_effective_date
                     );

  chk_limits(p_rec.condition_type
            ,p_rec.attribute_id
            ,p_rec.parameter_one
            ,p_rec.parameter_two
            ,p_rec.include_lower_limit
            ,p_rec.include_upper_limit
            ,p_effective_date
            );

  chk_unique(p_rec
            ,p_effective_date
            );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_con_shd.g_rec_type
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
  -- User Entered calls to validate procedures
  --
  chk_condition_id(p_rec.condition_id);

  chk_unique(p_rec
            ,p_effective_date
            );

  chk_parameter_one(p_rec.parameter_one
                   ,p_rec.parameter_two
                   ,p_rec.attribute_id
                   ,p_effective_date
                   );

  chk_parameters(p_rec.condition_type
                ,p_rec.attribute_id
                ,p_rec.parameter_one
                ,p_rec.parameter_two
                ,p_effective_date
                );

  chk_parameter_three(p_rec.parameter_three
                     ,p_rec.condition_type
                     ,p_rec.attribute_id
                     ,p_effective_date
                     );

  chk_limits(p_rec.condition_type
            ,p_rec.attribute_id
            ,p_rec.parameter_one
            ,p_rec.parameter_two
            ,p_rec.include_lower_limit
            ,p_rec.include_upper_limit
            ,p_effective_date
            );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_con_shd.g_rec_type
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
    ,p_condition_id =>  p_rec.condition_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_con_bus;

/
