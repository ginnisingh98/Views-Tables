--------------------------------------------------------
--  DDL for Package Body PAY_TDU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TDU_BUS" as
/* $Header: pytdurhi.pkb 120.2 2005/10/14 07:07 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_tdu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_time_definition_id          number         default null;
g_usage_type                  varchar2(30)   default null;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean,
   p_time_definition_id   IN number
  ) IS
--
  cursor csr_parent_bus_leg is
  select business_group_id,
         legislation_code
  from   pay_time_definitions
  where  time_definition_id = p_time_definition_id;
--
  l_business_group_id number;
  l_legislation_code  varchar2(30);
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode

  open csr_parent_bus_leg;
  fetch csr_parent_bus_leg into l_business_group_id, l_legislation_code;

  if csr_parent_bus_leg%notfound then
         close csr_parent_bus_leg;
         return;
  end if;

  close csr_parent_bus_leg;

  IF (p_insert) THEN

    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => l_business_group_id
      ,p_legislation_code  => l_legislation_code
      ,p_legislation_subgroup => null
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => l_business_group_id
      ,p_legislation_code  => l_legislation_code
      ,p_legislation_subgroup => null
      );
  END IF;
  --
Exception
  when others then
    if csr_parent_bus_leg%isopen then
       close csr_parent_bus_leg;
    end if;
    raise;

END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_time_definition_id >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the time definition id column
--
--  Prerequisites:
--     None
--
--  In Arguments:
--    p_time_definition_id
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_time_definition_id
  (p_time_definition_id     in  number
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_time_definition_id';
  l_api_updating  boolean;
  l_exists varchar2(1);
--
  cursor csr_time_definition_id is
  select null
  from   pay_time_definitions
  where  time_definition_id = p_time_definition_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

     hr_api.mandatory_arg_error
     (p_api_name       =>  l_proc
     ,p_argument       =>  'TIME_DEFINITION_ID'
     ,p_argument_value =>  p_time_definition_id
     );

     open csr_time_definition_id;
     fetch csr_time_definition_id into l_exists;

     if csr_time_definition_id%notfound then

       close csr_time_definition_id;
       fnd_message.set_name('PAY','PAY_34056_FLSA_INV_TIME_DEF_ID');
       fnd_message.raise_error;

     end if;

     close csr_time_definition_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEF_USAGES.TIME_DEFINITION_ID') then
              raise;
       end if;

    when others then
       if csr_time_definition_id%isopen then
          close csr_time_definition_id;
       end if;
       raise;

End chk_time_definition_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_usage_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the usage type column
--
--  Prerequisites:
--     Time definition referred by p_time_definition_id must already exists.
--
--  In Arguments:
--    p_time_definition_id
--    p_usage_type
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_usage_type
  (p_time_definition_id        in  number,
   p_usage_type                in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_usage_type';
  l_api_updating  boolean;
  l_exists varchar2(1);
  l_definition_type varchar2(30);
  l_meaning varchar2(80);

  cursor csr_usage_type is
  select hrl.meaning
  from   hr_standard_lookups hrl
  where  hrl.lookup_type = 'PAY_TIME_DEFINITION_USAGE'
  and    hrl.lookup_code = p_usage_type
  and    hrl.enabled_flag = 'Y';

  cursor csr_definition_type is
  select nvl(definition_type,'P')
  from   pay_time_definitions
  where  time_definition_id = p_time_definition_id;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_TIME_DEF_USAGES.TIME_DEFINITION_ID'
     ,p_associated_column1 => 'PAY_TIME_DEF_USAGES.USAGE_TYPE'
     ) then

     hr_api.mandatory_arg_error
     (p_api_name       =>  l_proc
     ,p_argument       =>  'USAGE_TYPE'
     ,p_argument_value =>  p_usage_type
     );

     open  csr_usage_type;
     fetch csr_usage_type into l_meaning;

     if csr_usage_type%notfound then

        close csr_usage_type;

        fnd_message.set_name('PAY','PAY_34059_FLSA_ARG_INVALID');
        fnd_message.set_token('ARGUMENT', 'Usage Type');
        fnd_message.raise_error;

     end if;

     close csr_usage_type;

     open csr_definition_type;
     fetch csr_definition_type into l_definition_type;
     close csr_definition_type;

     if l_definition_type = 'P' and p_usage_type = 'EA' then

        fnd_message.set_name('PAY','PAY_34063_FLSA_INV_USAGE_TYPE');
        fnd_message.set_token('USAGE', l_meaning);
        fnd_message.raise_error;

     end if;

     if l_definition_type in ('S','E','C') and p_usage_type in ('PP','RS','P') then

        fnd_message.set_name('PAY','PAY_34063_FLSA_INV_USAGE_TYPE');
        fnd_message.set_token('USAGE', l_meaning);
        fnd_message.raise_error;

     end if;

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEF_USAGES.USAGE_TYPE') then
              raise;
       end if;

    when others then
      if csr_usage_type%isopen then
         close csr_usage_type;
      end if;
      raise;

End chk_usage_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_tdu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(true
                    ,p_rec.time_definition_id
                    );

  -- "HR_STANDARD_LOOKUPS used for validation."
  --
  -- Validate Dependent Attributes
  --
  --

  chk_time_definition_id
  (p_time_definition_id     => p_rec.time_definition_id);

  chk_usage_type
  (p_time_definition_id     => p_rec.time_definition_id,
   p_usage_type             => p_rec.usage_type
  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_tdu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(false
                    ,p_rec.time_definition_id
                    );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_tdu_bus;

/
