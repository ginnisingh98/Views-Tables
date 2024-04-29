--------------------------------------------------------
--  DDL for Package Body PAY_EGU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EGU_BUS" as
/* $Header: pyegurhi.pkb 120.0 2005/09/26 09:28 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_egu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_event_group_usage_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_event_group_usage_id                 in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_event_group_usages egu
     where egu.event_group_usage_id = p_event_group_usage_id
       and pbg.business_group_id (+) = egu.business_group_id;
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
    ,p_argument           => 'event_group_usage_id'
    ,p_argument_value     => p_event_group_usage_id
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
        => nvl(p_associated_column1,'EVENT_GROUP_USAGE_ID')
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
  (p_event_group_usage_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_event_group_usages egu
     where egu.event_group_usage_id = p_event_group_usage_id
       and pbg.business_group_id (+) = egu.business_group_id;
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
    ,p_argument           => 'event_group_usage_id'
    ,p_argument_value     => p_event_group_usage_id
    );
  --
  if ( nvl(pay_egu_bus.g_event_group_usage_id, hr_api.g_number)
       = p_event_group_usage_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_egu_bus.g_legislation_code;
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
    pay_egu_bus.g_event_group_usage_id        := p_event_group_usage_id;
    pay_egu_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --

  IF (p_insert) THEN

    if p_business_group_id is not null and p_legislation_code is not null then
        fnd_message.set_name('PAY', 'PAY_33179_BGLEG_INVALID');
        fnd_message.raise_error;
    end if;

    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_element_set_id >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the element_set_id exists in pay_element_sets
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_element_set_id
--    p_legislation_code
--    p_business_group_id
--
--  Post Success:
--    Processing continues if the element_set_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the element_set_id is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_element_set_id
(p_element_set_id     in number
,p_legislation_code   in varchar2
,p_business_group_id  in number
) is
--
cursor csr_element_set_id is
select pes.legislation_code , pes.business_group_id, pes.element_set_type
from   pay_element_sets pes
where  pes.element_set_id = p_element_set_id ;
--
l_busgrpid PAY_ELEMENT_SETS.BUSINESS_GROUP_ID%TYPE;
l_legcode  PAY_ELEMENT_SETS.LEGISLATION_CODE%TYPE;
l_ele_set_type PAY_ELEMENT_SETS.ELEMENT_SET_TYPE%TYPE;

l_proc   varchar2(100) := g_package || 'chk_element_set_id';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- ELEMENT_SET_ID is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'ELEMENT_SET_ID'
  ,p_argument_value =>  p_element_set_id
  );
  --
  open csr_element_set_id;
  fetch csr_element_set_id into l_legcode, l_busgrpid, l_ele_set_type ;

  if csr_element_set_id%notfound then
    close csr_element_set_id;
    fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
    fnd_message.set_token('PARENT' , 'Element Set Id' );
    fnd_message.raise_error;
  end if;
  close csr_element_set_id;
  --
  -- Confirm that the parent Element Set's startup mode is compatible
  -- with this child row.
  --
  if not pay_put_shd.chk_startup_mode_compatible
         (p_parent_bgid    => l_busgrpid
         ,p_parent_legcode => l_legcode
         ,p_child_bgid     => p_business_group_id
         ,p_child_legcode  => p_legislation_code
         ) then
      fnd_message.set_name('PAY', 'PAY_33175_BGLEG_MISMATCH');
      fnd_message.set_token('CHILD', 'Event Group Usage');
      fnd_message.set_token('PARENT' , 'Element Set');
      fnd_message.raise_error;
  end if;

  if l_ele_set_type <> 'E' then

    fnd_message.set_name('PAY', 'PAY_294524_INV_ESET_TYPE');
    fnd_message.raise_error;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_EVENT_GROUP_USAGES.ELEMENT_SET_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_element_set_id%isopen then
      close csr_element_set_id;
    end if;
    raise;

end chk_element_set_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_event_group_id >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the event_group_id exists in pay_event_groups
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_event_group_id
--    p_legislation_code
--    p_business_group_id
--
--  Post Success:
--    Processing continues if the event_group_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the event_group_id is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_event_group_id
(p_event_group_id     in number
,p_legislation_code   in varchar2
,p_business_group_id  in number
) is
--
cursor csr_event_group_id is
select peg.legislation_code , peg.business_group_id
from   pay_event_groups peg
where  peg.event_group_id = p_event_group_id ;
--
l_busgrpid PAY_EVENT_GROUPS.BUSINESS_GROUP_ID%TYPE;
l_legcode  PAY_EVENT_GROUPS.LEGISLATION_CODE%TYPE;

l_proc   varchar2(100) := g_package || 'chk_event_group_id';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- EVENT_GROUP_ID is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'EVENT_GROUP_ID'
  ,p_argument_value =>  p_event_group_id
  );
  --
  open csr_event_group_id;
  fetch csr_event_group_id into l_legcode, l_busgrpid ;

  if csr_event_group_id%notfound then
    close csr_event_group_id;
    fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
    fnd_message.set_token('PARENT' , 'Event Group Id' );
    fnd_message.raise_error;
  end if;
  close csr_event_group_id;
  --
  -- Confirm that the parent Event Group's startup mode is compatible
  -- with this child row.
  --
  if not pay_put_shd.chk_startup_mode_compatible
         (p_parent_bgid    => l_busgrpid
         ,p_parent_legcode => l_legcode
         ,p_child_bgid     => p_business_group_id
         ,p_child_legcode  => p_legislation_code
         ) then
      fnd_message.set_name('PAY', 'PAY_33175_BGLEG_MISMATCH');
      fnd_message.set_token('CHILD', 'Event Group Usage');
      fnd_message.set_token('PARENT' , 'Event Group');
      fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_EVENT_GROUP_USAGES.EVENT_GROUP_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_event_group_id%isopen then
      close csr_event_group_id;
    end if;
    raise;

end chk_event_group_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_event_group_ele_set >-----------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that there is only one row in PAY_EVENT_GROUP_USAGES
--    with the combination of EVENT_GROUP_ID and ELEMENT_SET_ID
--    in a particular business group or legislation.
--
--  Pre-Requisites:
--    Event Group Id and Element Set Id are valid
--
--  In Parameters:
--    p_event_group_id
--    p_element_set_id
--    p_legislation_code
--    p_business_group_id
--
--  Post Success:
--    Processing continues if the combination is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the combination is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_event_group_ele_set
( p_event_group_id in number
 ,p_element_set_id  in number
 ,p_business_group_id in number
 ,p_legislation_code in varchar2
) is
--
cursor csr_event_group_ele_set is
select  null
from    pay_event_group_usages egu
where   egu.event_group_id = p_event_group_id
and     egu.element_set_id = p_element_set_id
and ( p_business_group_id is null
        or ( p_business_group_id is not null and p_business_group_id = egu.business_group_id )
        or ( p_business_group_id is not null and
                egu.legislation_code is null and egu.business_group_id is null )
        or ( p_business_group_id is not null and
                egu.legislation_code = hr_api.return_legislation_code(p_business_group_id )))
and ( p_legislation_code is null
        or ( p_legislation_code is not null and p_legislation_code = egu.legislation_code )
        or ( p_legislation_code is not null and
                egu.legislation_code is null and egu.business_group_id is null)
        or ( p_legislation_code is not null and
                p_legislation_code = hr_api.return_legislation_code(egu.business_group_id )));

l_proc   varchar2(100) := g_package || 'chk_event_group_ele_set';
l_exists varchar2(1);
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_EVENT_GROUP_USAGES.EVENT_GROUP_ID'
     ,p_check_column2      => 'PAY_EVENT_GROUP_USAGES.ELEMENT_SET_ID'
     ,p_associated_column1 => 'PAY_EVENT_GROUP_USAGES.EVENT_GROUP_ID'
     ,p_associated_column2 => 'PAY_EVENT_GROUP_USAGES.ELEMENT_SET_ID'
     ) then
    --
            open csr_event_group_ele_set;
            fetch csr_event_group_ele_set into l_exists;

            if csr_event_group_ele_set%found then
                close csr_event_group_ele_set;
                fnd_message.set_name('PAY', 'PAY_294525_ECU_EXISTS');
                fnd_message.raise_error;
            end if;

            close csr_event_group_ele_set;

  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_EVENT_GROUP_USAGES.EVENT_GROUP_ID',
          p_associated_column2 => 'PAY_EVENT_GROUP_USAGES.ELEMENT_SET_ID') then
              raise;
       end if;

    when others then
        if csr_event_group_ele_set%isopen then
                close csr_event_group_ele_set ;
        end if;
        raise;

end chk_event_group_ele_set ;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_legislation_code>-------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the legislation code exists in fnd_territories
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_legislation_code
--
--  Post Success:
--    Processing continues if the legislation_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_code is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_legislation_code
( p_legislation_code  in varchar2 )
is
--
cursor csr_legislation_code is
select null
from fnd_territories
where territory_code = p_legislation_code ;
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'chk_legislation_code';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_legislation_code;
  fetch csr_legislation_code into l_exists ;

  if csr_legislation_code%notfound then
    close csr_legislation_code;
    fnd_message.set_name('PAY', 'PAY_33177_LEG_CODE_INVALID');
    fnd_message.raise_error;
  end if;
  close csr_legislation_code;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_EVENT_GROUP_USAGES.LEGISLATION_CODE'
       ) then
      raise;
    end if;
  when others then
    if csr_legislation_code%isopen then
      close csr_legislation_code;
    end if;
    raise;
end chk_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_egu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );

  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_egu_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  if hr_startup_data_api_support.g_startup_mode not in ('GENERIC','USER') then

     --
     -- Validate Important Attributes
     --
        chk_legislation_code(p_legislation_code => p_rec.legislation_code);
     --
        hr_multi_message.end_validation_set;

  end if;
  --
  --
  -- Validate Dependent Attributes
  --
  chk_element_set_id
  (p_element_set_id     => p_rec.element_set_id
  ,p_legislation_code   => p_rec.legislation_code
  ,p_business_group_id  => p_rec.business_group_id
  );

  chk_event_group_id
  (p_event_group_id     => p_rec.event_group_id
  ,p_legislation_code   => p_rec.legislation_code
  ,p_business_group_id  => p_rec.business_group_id
  );

  chk_event_group_ele_set
  ( p_event_group_id    => p_rec.event_group_id
   ,p_element_set_id    => p_rec.element_set_id
   ,p_business_group_id => p_rec.business_group_id
   ,p_legislation_code  => p_rec.legislation_code
  );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_egu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  chk_startup_action(false
                    ,pay_egu_shd.g_old_rec.business_group_id
                    ,pay_egu_shd.g_old_rec.legislation_code
                    );

  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_egu_bus;

/
