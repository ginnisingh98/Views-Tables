--------------------------------------------------------
--  DDL for Package Body HR_ITF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITF_BUS" as
/* $Header: hritfrhi.pkb 120.0 2005/05/31 00:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_itf_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_form_const  varchar2(5) := 'PUI';
g_ss_const  varchar2(5) := 'SS';
g_portal_const  varchar2(5) := 'P';
g_user_interface_id           number         default null;

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
  (p_effective_date               in date
  ,p_rec in hr_itf_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_itf_shd.api_updating
      (p_user_interface_id                 => p_rec.user_interface_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- ------------------------------< CHK_TYPE>-----------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid lookup value is selected for the type
--   column. The valid values are :SS,PUI,P.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--  p_effective_date, p_type

-- Post Success:
--   Processing continues if the type value comes from the set of values in
--   the lookup HR_KPI_INTERFACE_TYPE
--
-- Post Failure:
--   An application error is raised if user interface key is null or exists
--   already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_type
(
 p_effective_date in date,
 p_type  in varchar2
)
is

  -- Variables for API Boolean parameters
  l_proc            varchar2(72) := g_package ||'chk_type';
  l_found           varchar2(10);

  Begin

     hr_utility.set_location(' Entering:' || l_proc,10);

     hr_api.mandatory_arg_error
     (p_api_name           => l_proc
     ,p_argument           => 'TYPE'
     ,p_argument_value     => p_type
     );


     hr_utility.set_location('validating:'||l_proc,20);

     --Is it neccessary to validate against not_exists_in_fnd_lookups?

     if hr_api.not_exists_in_hrstanlookups
          (p_effective_date               => p_effective_date
          ,p_lookup_type                  => 'HR_KPI_UI_TYPE'
          ,p_lookup_code                  => p_type
          ) then
          fnd_message.set_name('PER', 'PER_449936_ITF_INT_TYPE_INVAL');
          fnd_message.raise_error;
        end if;

     hr_utility.set_location(' Leaving:' || l_proc,30);

     Exception
      when app_exception.application_exception then
      IF hr_multi_message.exception_add
          (p_associated_column1 => 'HR_KI_USER_INTERFACES.TYPE'
           )
      THEN
          hr_utility.set_location(' Leaving:'|| l_proc,40);
          raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,50);
  --
End chk_type;

-- ----------------------------------------------------------------------------
-- ------------------------------< CHK_FORM_NAME>------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that valid form name is entered when the
--   type is PUI

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--  p_type, p_form_name

-- Post Success:
--   Processing continues if the form_name is valid
--
-- Post Failure:
--   An application error is raised if form_name is invalid
--   already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_form_name
(
 p_type       in varchar2,
 p_form_name  in varchar2,
 p_user_interface_id in number
)
is

  CURSOR csr_form is
    select
      'found'
    From
      fnd_form  frm
    where
      frm.form_name = p_form_name;

    CURSOR csr_form_unique is
     select
      'found'
     From
       hr_ki_user_interfaces itf
     Where
        itf.type = p_type
        and itf.form_name = p_form_name
        and (p_user_interface_id is null or
        itf.user_interface_id <> p_user_interface_id);

  -- Variables for API Boolean parameters
  l_proc            varchar2(72) := g_package ||'chk_form_name';
  l_found           varchar2(10);

  Begin

     hr_utility.set_location(' Entering:' || l_proc,10);


             -- the check for form_name is done independent of any previous errors
             -- further checks which depend on type are done by checking if any errors
             -- already occur in the multi message list.
       if (p_type = g_form_const)
       then
             open csr_form;
              fetch csr_form into l_found;

              if csr_form%NOTFOUND then
               close csr_form;
               fnd_message.set_name('PER','PER_449937_ITF_FORM_INVAL');
               fnd_message.raise_error;
              end if;

             close csr_form;

             if hr_multi_message.no_exclusive_error
                    (p_check_column1      =>
                     'HR_KI_USER_INTERFACES.TYPE'
                    )
             then

        -- checking for a duplicate record
        -- the case of updation is handled in the cursor itself with a null check
             open csr_form_unique;
               fetch csr_form_unique into l_found;

               if csr_form_unique%FOUND then
                close csr_form_unique;
                fnd_message.set_name('PER','PER_449938_ITF_FORM_DUPLI');
                fnd_message.raise_error;
              end if;
              close csr_form_unique;

            end if;
	end if;

     hr_utility.set_location(' Leaving:' || l_proc,20);

     Exception
      when app_exception.application_exception then
      IF hr_multi_message.exception_add
          (p_associated_column1 => 'HR_KI_USER_INTERFACES.FORM_NAME'
           )
      THEN
          hr_utility.set_location(' Leaving:'|| l_proc,30);
          raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);
  --
End chk_form_name;

-- ----------------------------------------------------------------------------
-- --------------------------<CHK_PAGE_REGION_CODE>----------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid page_region_code is entered.
--
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--  p_type, p_page_region_code,p_region_code

-- Post Success:
--   Processing continues if the valid page_region_code is entered.
--
-- Post Failure:
--   An application error is raised if invalid page_region_code is entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_page_region_code
(
 p_type              in varchar2,
 p_page_region_code  in varchar2,
 p_region_code       in varchar2,
 p_user_interface_id in number
)
is

  CURSOR csr_form_functions is
    select
      'found'
    From
      fnd_form_functions  frm
    where
      frm.function_name = p_page_region_code;

  CURSOR csr_reg_unique_check( cur_type              varchar2,
                               cur_page_region_code  varchar2,
                               cur_region_code       varchar2,
                               cur_user_interface_id number) is
    select 'found'
      from hr_ki_user_interfaces itf
      where
          itf.type = cur_type
      and itf.page_region_code = cur_page_region_code
      and (cur_region_code is null or itf.region_code = cur_region_code)
      and (cur_user_interface_id is null or itf.user_interface_id <> cur_user_interface_id);

  -- Variables for API Boolean parameters
  l_proc            varchar2(72) := g_package ||'chk_type';
  l_found           varchar2(10);

  Begin

     hr_utility.set_location(' Entering:' || l_proc,10);

     IF (p_type = g_ss_const or  p_type = g_portal_const )THEN

             -- perform independent validation of page_region_code.
             open csr_form_functions;
               fetch csr_form_functions into l_found;

              if csr_form_functions%NOTFOUND then
               close csr_form_functions;
               fnd_message.set_name('PER','PER_449939_ITF_PGRGNCD_INVLD');
               fnd_message.raise_error;
              end if;

             close csr_form_functions;

            if hr_multi_message.no_exclusive_error
                    (p_check_column1      =>
                     'HR_KI_USER_INTERFACES.TYPE'
                    )
            then
               open csr_reg_unique_check(p_type,
                                         p_page_region_code,
                                         p_region_code,
                                         p_user_interface_id);
               fetch csr_reg_unique_check into l_found;

               if csr_reg_unique_check%FOUND
               then
                 close csr_reg_unique_check;
                 fnd_message.set_name('PER','PER_449940_ITF_RGNCD_DUPLI');
                 fnd_message.raise_error;
               end if;
               close csr_reg_unique_check;
             end if;
           end if;
     hr_utility.set_location(' Leaving:'|| l_proc,20);

     Exception
      when app_exception.application_exception then
      IF hr_multi_message.exception_add
          (p_associated_column1 => 'HR_KI_USER_INTERFACES.PAGE_REGION_CODE',
           p_associated_column2 => 'HR_KI_USER_INTERFACES.REGION_CODE'
           )
      THEN
          hr_utility.set_location(' Leaving:'|| l_proc,30);
          raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);
  --
End chk_page_region_code;

-- ----------------------------------------------------------------------------
-- --------------------------<CHK_VALID_COMBINATION>----------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid combination of values for type,form name
--   ,page region code and region code.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--  p_type, p_form_name, p_page_region_code, p_region_code

-- Post Success:
--   Processing continues if the type value comes from the set of values in
--   the lookup HR_KPI_UI_TYPES
--
-- Post Failure:
--   An application error is raised if user interface key is null or exists
--   already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_valid_combination
(
 p_type              in varchar2,
 p_form_name         in varchar2,
 p_page_region_code  in varchar2,
 p_region_code       in varchar2
)
is

  -- Variables for API Boolean parameters
  l_proc            varchar2(72) := g_package ||'chk_region_code';
  l_found           varchar2(10);

  Begin

     hr_utility.set_location(' Entering:' || l_proc,10);

    if hr_multi_message.no_exclusive_error
            (p_check_column1      =>
             'HR_KI_USER_INTERFACES.TYPE'
            )
    then

     if(p_type = g_form_const and
        (p_form_name is null or
         p_page_region_code is not null or
         p_region_code is not null)
       )
     then
       fnd_message.set_name('PER','PER_449941_ITF_IVLDPUI_COMBN');
       fnd_message.raise_error;
     end if;

     if((p_type = g_ss_const or p_type = g_portal_const) and
        (p_page_region_code is null or
         p_form_name is not null)
       )
     then
       fnd_message.set_name('PER','PER_449942_ITF_IVLDPG_COMBN');
       fnd_message.raise_error;
     end if;

    end if;

     hr_utility.set_location(' Leaving:'|| l_proc,20);

     Exception
      when app_exception.application_exception then
      IF hr_multi_message.exception_add
          (p_associated_column1 => 'HR_KI_USER_INTERFACES.TYPE',
           p_associated_column2 => 'HR_KI_USER_INTERFACES.FORM_NAME',
           p_associated_column3 => 'HR_KI_USER_INTERFACES.PAGE_REGION_CODE'
          )
      THEN
          hr_utility.set_location(' Leaving:'|| l_proc,30);
          raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);
  --
End chk_valid_combination;

-- ----------------------------------------------------------------------------
-- -----------------------------< CHK_DELETE>----------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a delete occurs only if there are no child
--   rows for a record in hr_ki_user_interfaces. The tables that contain child
--   rows are hr_ki_hierarchy_node_maps.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_user_interface_id

-- Post Success:
--   Processing continues if there are no child records.
--
-- Post Failure:
--   An application error is raised if there are any child rows from any of
--   the above mentioned tables.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_delete(p_user_interface_id in varchar2)
is

CURSOR csr_hnm_id is
    select
      distinct 'found'
    From
      hr_ki_hierarchy_node_maps  hnm
    where
      hnm.user_interface_id = p_user_interface_id;

l_found   varchar2(30);
l_proc    varchar2(72) := g_package ||'chk_delete';

Begin

  hr_utility.set_location(' Entering:' || l_proc,10);

  open csr_hnm_id;
  fetch csr_hnm_id into l_found;

  if csr_hnm_id%FOUND then
    close csr_hnm_id;
    fnd_message.set_name( 'PER','PER_449944_ITF_HNM_MAIN_EXIST');
    fnd_message.raise_error;
  end if;

  close csr_hnm_id;

 hr_utility.set_location(' Leaving:' || l_proc,20);

 Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   =>
                  'HR_KI_USER_INTERFACES.USER_INTERFACE_ID'
                 )THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;
  hr_utility.set_location(' Leaving:'|| l_proc,40);

 End chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy hr_itf_shd.g_rec_type
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
  --
  chk_type(p_effective_date => p_effective_date,
           p_type           => p_rec.type);

  chk_valid_combination(p_type => p_rec.type,
                        p_form_name => p_rec.form_name,
                        p_page_region_code => p_rec.page_region_code,
                        p_region_code => p_rec.region_code);

  chk_form_name(p_type => p_rec.type,
                p_form_name => p_rec.form_name,
                p_user_interface_id => ''
              );

  chk_page_region_code(p_type => p_rec.type,
                       p_page_region_code => p_rec.page_region_code,
                       p_region_code => p_rec.region_code,
                       p_user_interface_id => ''
                       );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy hr_itf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );

  chk_type(p_effective_date => p_effective_date,
           p_type           => p_rec.type);

  chk_valid_combination(p_type => p_rec.type,
                        p_form_name => p_rec.form_name,
                        p_page_region_code => p_rec.page_region_code,
                        p_region_code => p_rec.region_code);

  chk_form_name(p_type => p_rec.type,
                p_form_name => p_rec.form_name,
                p_user_interface_id => p_rec.user_interface_id
              );

  chk_page_region_code(p_type => p_rec.type,
                       p_page_region_code => p_rec.page_region_code,
                       p_region_code => p_rec.region_code,
                       p_user_interface_id => p_rec.user_interface_id
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
  (p_rec                          in hr_itf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.user_interface_id);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_itf_bus;

/
