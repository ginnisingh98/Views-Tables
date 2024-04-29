--------------------------------------------------------
--  DDL for Package Body HR_OPT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OPT_BUS" as
/* $Header: hroptrhi.pkb 120.1 2005/09/29 07:03 santosin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_opt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_option_id                   number         default null;
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
  (
  p_rec in hr_opt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_opt_shd.api_updating
      (p_option_id                         => p_rec.option_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  if nvl(p_rec.option_type_id, hr_api.g_number) <>
     nvl(hr_opt_shd.g_old_rec.option_type_id
        ,hr_api.g_number
        ) then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'OPTION_TYPE_ID'
      ,p_base_table => hr_opt_shd.g_tab_nam
      );
  end if;

  if nvl(p_rec.option_level, hr_api.g_number) <>
     nvl(hr_opt_shd.g_old_rec.option_level
        ,hr_api.g_number
        ) then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'OPTION_LEVEL'
      ,p_base_table => hr_opt_shd.g_tab_nam
      );
  end if;


  if nvl(p_rec.option_level_id, hr_api.g_varchar2) <>
     nvl(hr_opt_shd.g_old_rec.option_level_id
        ,hr_api.g_varchar2
        ) then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'OPTION_LEVEL_ID'
      ,p_base_table => hr_opt_shd.g_tab_nam
      );
  end if;

  if nvl(p_rec.integration_id, hr_api.g_number) <>
     nvl(hr_opt_shd.g_old_rec.integration_id
        ,hr_api.g_number
        ) then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'INTEGRATION_ID'
      ,p_base_table => hr_opt_shd.g_tab_nam
      );
  end if;


End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_OPTION_TYPE_ID>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures option_type_id is present in hr_ki_option_types
--   and it is mandatory.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_option_type_id
-- Post Success:
--   Processing continues if option type id is valid
--
-- Post Failure:
--   An application error is raised if option type id is invalid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_OPTION_TYPE_ID
  (p_option_type_id     in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_OPTION_TYPE_ID';
  l_key     varchar2(30) ;
  cursor csr_name is
         select option_type_id
           from hr_ki_option_types
          where  option_type_id = p_option_type_id;

--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OPTION_TYPE_ID'
    ,p_argument_value     => p_option_type_id
    );

    open csr_name;
    fetch csr_name into l_key;
    hr_utility.set_location('After fetching:'||l_proc,20);
    if (csr_name%notfound) then
      close csr_name;
      fnd_message.set_name('PER','PER_449953_OPT_OP_TY_ID_ABSENT');
      fnd_message.raise_error;
    end if;

    close csr_name;

  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_OPTIONS.OPTION_TYPE_ID'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_OPTION_TYPE_ID;

-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_OPTION_LEVEL>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures if option level value presnt in HR_LOOKUPS
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_option_level,p_effective_date
--
-- Post Success:
--   Processing continues if option level is valid
--
-- Post Failure:
--   An application error is raised if option level is invalid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_OPTION_LEVEL
  (p_option_level     in number
  ,p_effective_date               in date

  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_OPTION_LEVEL';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OPTION_LEVEL'
    ,p_argument_value     => p_option_level
    );


  hr_utility.set_location('validating:'||l_proc,20);

  --Is it neccessary to validate against not_exists_in_fnd_lookups?
  if hr_api.not_exists_in_hrstanlookups
          (p_effective_date               => p_effective_date
          ,p_lookup_type                  => 'HR_KPI_OPTION_LEVEL'
          ,p_lookup_code                  => p_option_level
          ) then
          fnd_message.set_name('PER', 'PER_449956_OPT_OP_LEV_INVALID');
          fnd_message.raise_error;
        end if;

  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_OPTIONS.OPTION_LEVEL'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,40);
End CHK_OPTION_LEVEL;


-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_OPTION_LEVEL_ID>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the option level id value is not null
--   if OPTION_LEVEL is not 100(SITE LEVEL)
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_option_level,p_option_level_id
--
-- Post Success:
--   Processing continues if option level id is valid
--
-- Post Failure:
--   An application error is raised if option level id is invalid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure CHK_OPTION_LEVEL_ID
  (p_option_level     in number
  ,p_option_level_id     in varchar2

  ) IS
--
  l_proc varchar2(72) := g_package || 'CHK_OPTION_LEVEL_ID';
  l_site_value number(15) := 100;
  l_app_value number(15) := 80;
  l_resp_value number(15) := 60;
  l_user_value number(15) := 20;

  l_resp_id         number;
  l_app_id          number;
  l_user_id         number;
  l_application_id  number;
  l_responsibility_id number;
  l_separator varchar2(1):='#';

  l_app_id_val_after varchar2(100):='';
  l_app_id_val_before varchar2(100):='';
  l_temp_option_level_id varchar2(50);


  cursor fnd_resp(l_a_id number,l_r_id number) is
         select responsibility_id
           from fnd_responsibility
          where  responsibility_id =l_r_id
          and application_id=l_a_id;


  cursor fnd_app is
         select application_id
           from fnd_application
          where  application_id =p_option_level_id ;


  cursor fnd_us is
         select user_id
           from fnd_user
          where  user_id=p_option_level_id ;


--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

-- Only proceed with OPTION_LEVEL_ID validation when the
-- Multiple Message List does not already contain an errors
-- associated with the OPTION_LEVEL column.
--
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'HR_KI_OPTIONS.OPTION_LEVEL'
       ,p_associated_column1 => 'HR_KI_OPTIONS.OPTION_LEVEL'
       ) then


        --check if level is NOT SITE
          IF p_option_level <> l_site_value THEN

            --level_id should not be null
            hr_api.mandatory_arg_error
                (p_api_name           => l_proc
                ,p_argument           => 'OPTION_LEVEL_ID'
                ,p_argument_value     => p_option_level_id
            );

            hr_utility.set_location('level id is not null:'||l_proc, 20);

            --if level is application
            --check validity of id against fnd_application table
            IF p_option_level=l_app_value THEN


              open fnd_app;
              fetch fnd_app into l_app_id;
              if (fnd_app%notfound)then
                close fnd_app;
                fnd_message.set_name('PER','PER_449958_OPT_OP_APP_ID_ERR');
                fnd_message.raise_error;
              end if;
            close fnd_app;

            --if level is responsibility
            --check validity of id against fnd_responsibility table
            elsIF p_option_level=l_resp_value THEN

               -- check if the value forms a numerical value
	       --set to temp string for validation

               l_temp_option_level_id := p_option_level_id;
               l_temp_option_level_id:=replace(l_temp_option_level_id,l_separator, '');

            --replace all number occurances with null
            --throw error if final string is not null
            for i in 0 .. 9 loop
               l_temp_option_level_id := replace(l_temp_option_level_id, i, '');
            end loop;
            if(l_temp_option_level_id is not null) then
               fnd_message.set_name('PER','PER_449959_OPT_OP_RESP_ID_ERR');
               fnd_message.raise_error;
            end if;

            --throw error if No occurance of ':'
            if (instr(p_option_level_id,l_separator) = 0) then
               fnd_message.set_name('PER','PER_449959_OPT_OP_RESP_ID_ERR');
               fnd_message.raise_error;
            end if;

            --get the values
            l_responsibility_id:=to_number(substr(p_option_level_id,1,
	    instr(p_option_level_id,l_separator)-1));

            l_application_id:=to_number(substr(p_option_level_id,
            instr(p_option_level_id,l_separator)+1));

	    if l_responsibility_id is null then
               fnd_message.set_name('PER','PER_449959_OPT_OP_RESP_ID_ERR');
               fnd_message.raise_error;
            end if;

	    if l_application_id is null then
               fnd_message.set_name('PER','PER_449959_OPT_OP_RESP_ID_ERR');
               fnd_message.raise_error;
	    end if;

            --open cursor with extracted values
            open fnd_resp(l_application_id,l_responsibility_id);
            fetch fnd_resp into l_resp_id;
            if (fnd_resp%notfound)then
                close fnd_resp;
                fnd_message.set_name('PER','PER_449959_OPT_OP_RESP_ID_ERR');
                    fnd_message.raise_error;
            END IF;
            close fnd_resp;

            --if level is User
            --check validity of id against fnd_user table

            elsIF p_option_level=l_user_value THEN
            open fnd_us;
            fetch fnd_us into l_user_id;
            if (fnd_us%notfound)then
                close fnd_us;
                fnd_message.set_name('PER','PER_449960_OPT_OP_US_ID_ERR');
                    fnd_message.raise_error;
            END IF;
            close fnd_us;

            end if;

        --IF level is SITE then option_level_id must be null
          else
            IF p_option_level_id is not null THEN
                    fnd_message.set_name('PER','PER_449957_OPT_OP_LE_ID_INVAL');
                    fnd_message.raise_error;
            END IF;

          END IF;

  END IF;

  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_same_associated_columns => 'Y'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,40);
End CHK_OPTION_LEVEL_ID;

-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_ENCRYPTED>-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures if encrypted value is either Y or N
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_encrypted,p_value
--
-- Post Success:
--   Processing continues if encrypted column value is valid
--
-- Post Failure:
--   An application error is raised if encrypted column value is invalid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_ENCRYPTED
  (p_encrypted     in varchar2
  ,p_value       in varchar2
  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_ENCRYPTED';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

    --encrypted column should not be null
    hr_api.mandatory_arg_error
        (p_api_name           => l_proc
        ,p_argument           => 'ENCRYPTED'
        ,p_argument_value     => p_encrypted
    );

  hr_utility.set_location('validating:'||l_proc,20);

    if upper(p_encrypted) ='Y' or upper(p_encrypted)='N' then
     null;
    else
     fnd_message.set_name('PER', 'PER_449954_OPT_ENCRYPTED_INVAL');
     fnd_message.raise_error;

    end if;

  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_OPTIONS.ENCRYPTED'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,40);
End CHK_ENCRYPTED;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_integration_id>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures integration_id is present in hr_ki_integrations
--   and it is mandatory.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_integration_id
--
-- Post Success:
--   Processing continues if integration_id is valid
--
-- Post Failure:
--   An application error is raised if integration_id is invalid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_integration_id
  (p_integration_id     in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_integration_id';
  l_key     varchar2(30) ;
  cursor csr_int is
         select INTEGRATION_ID
           from hr_ki_integrations
          where  integration_id = p_integration_id;


--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

--integration_id should not be null

    hr_api.mandatory_arg_error
        (p_api_name           => l_proc
        ,p_argument           => 'INTEGRATION_ID'
        ,p_argument_value     => p_integration_id
    );


  hr_utility.set_location('Validating:'||l_proc,20);


    open csr_int;
    fetch csr_int into l_key;
    hr_utility.set_location('After fetching :'||l_proc,30);
    if (csr_int%notfound) then
      close csr_int;
      fnd_message.set_name('PER','PER_449955_OPT_INT_ID_ABSENT');
      fnd_message.raise_error;
    end if;
    close csr_int;

  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_OPTIONS.INTEGRATION_ID'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,60);
End chk_integration_id;



-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_UNIQUE_RECORD>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures if record is unique for combination of
--   option_type_id,integration_id,option_level,option_level_id
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_option_type_id,p_integration_id,p_option_level_id,p_option_level
--
-- Post Success:
--   Processing continues record is valid
--
-- Post Failure:
--   An application error is raised for invalid record
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_UNIQUE_RECORD
  (
  p_option_type_id in number
  ,p_integration_id     in number
  ,p_option_level in number
  ,p_option_level_id in varchar2

  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_UNIQUE_RECORD';
  l_found   varchar2(1);

    cursor csr_int_options is
           select null
             from hr_ki_options
            where  (option_type_id = p_option_type_id
            and integration_id = p_integration_id
            and option_level=p_option_level)
            and (option_level_id=p_option_level_id
            or option_level_id is null);
--
Begin
    hr_utility.set_location('Entering:'||l_proc,10);

-- Only proceed with unique record validation when the
-- Multiple Message List does not already contain an errors
-- associated with the OPTION_TYPE_ID,INTEGRATION_ID,OPTION_LEVEL
-- OPTION_LEVEL_ID columns.
--
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'HR_KI_OPTIONS.OPTION_TYPE_ID'
       ,p_associated_column1 => 'HR_KI_OPTIONS.OPTION_TYPE_ID'
       ,p_check_column2      => 'HR_KI_OPTIONS.INTEGRATION_ID'
       ,p_associated_column2 => 'HR_KI_OPTIONS.INTEGRATION_ID'
       ,p_check_column3      => 'HR_KI_OPTIONS.OPTION_LEVEL'
       ,p_associated_column3 => 'HR_KI_OPTIONS.OPTION_LEVEL'
       ,p_check_column4      => 'HR_KI_OPTIONS.OPTION_LEVEL_ID'
       ,p_associated_column4 => 'HR_KI_OPTIONS.OPTION_LEVEL_ID'
  ) then

     open  csr_int_options;
        fetch csr_int_options into l_found;

         if (csr_int_options%found) then
          close csr_int_options;
          fnd_message.set_name('PER','PER_449952_OPT_INVALID_COMB');
          fnd_message.raise_error;
         end if;
     close csr_int_options;

 end if;

  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_same_associated_columns => 'Y'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_UNIQUE_RECORD;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hr_opt_shd.g_rec_type
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
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
      CHK_OPTION_TYPE_ID
      (
       p_option_type_id  => p_rec.option_type_id
      );

      CHK_OPTION_LEVEL
      (
       p_option_level  => p_rec.option_level
       ,p_effective_date =>p_effective_date
      );

      CHK_OPTION_LEVEL_ID
      (
       p_option_level  => p_rec.option_level
       ,p_option_level_id =>p_rec.option_level_id
     );

      CHK_ENCRYPTED
      (
       p_encrypted  => p_rec.encrypted
       ,p_value =>p_rec.value
       );

      CHK_INTEGRATION_ID
      (
       p_integration_id  => p_rec.integration_id
       );

      CHK_UNIQUE_RECORD
      (
        p_option_type_id  => p_rec.option_type_id
       ,p_integration_id  => p_rec.integration_id
       ,p_option_level  => p_rec.option_level
       ,p_option_level_id =>p_rec.option_level_id

       );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (
  p_rec                          in hr_opt_shd.g_rec_type
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
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (
      p_rec                       => p_rec
    );

   CHK_ENCRYPTED
      (
       p_encrypted  => p_rec.encrypted
       ,p_value =>p_rec.value
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
  (p_rec                          in hr_opt_shd.g_rec_type
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
end hr_opt_bus;

/
