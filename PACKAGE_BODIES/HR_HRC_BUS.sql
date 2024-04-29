--------------------------------------------------------
--  DDL for Package Body HR_HRC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HRC_BUS" as
/* $Header: hrhrcrhi.pkb 115.0 2004/01/09 01:12 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_hrc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_hierarchy_id                number         default null;
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
  (p_rec in hr_hrc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_hrc_shd.api_updating
      (p_hierarchy_id                      => p_rec.hierarchy_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.hierarchy_key, hr_api.g_varchar2) <>
         nvl(hr_hrc_shd.g_old_rec.hierarchy_key,hr_api.g_varchar2
         ) then
          hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'HIERARCHY_KEY'
          ,p_base_table => hr_hrc_shd.g_tab_nam
         );
  end if;

  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- --------------------------< CHK_HIERARCHY_KEY>------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid hierarchy key is entered
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_hierarchy_key
-- Post Success:
--   Processing continues if hierarchy key is not null and unique
--
-- Post Failure:
--   An application error is raised if hierarchy key is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_hierarchy_key
(p_hierarchy_key  in varchar2
)
is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to check if the hierarchy key provided in the insert is already
  -- present
  CURSOR csr_hrc_key is
    select
      distinct 'found'
    From
      hr_ki_hierarchies  hrc
    where
      hrc.hierarchy_key = p_hierarchy_key;

  -- Variables for API Boolean parameters
  l_proc            varchar2(72) := g_package ||'chk_hierarchy_key';
  l_found           varchar2(10);

  Begin
    hr_utility.set_location(' Entering:' || l_proc,10);
  --
    hr_api.mandatory_arg_error
    (p_api_name           => l_proc
     ,p_argument           => 'HIERARCHY_KEY'
     ,p_argument_value     => p_hierarchy_key
    );

    hr_utility.set_location(' Opening the cursor csr_hrc_key:' || l_proc,20);

    OPEN csr_hrc_key;
    FETCH csr_hrc_key into l_found;

    IF csr_hrc_key%FOUND then
       CLOSE csr_hrc_key;
       fnd_message.set_name( 'PER','PER_449913_HRC_HRCHY_KEY_DUP');
       fnd_message.raise_error;
    END IF;

    CLOSE csr_hrc_key;

    hr_utility.set_location(' Closed the cursor csr_hrc_key:' || l_proc,30);

  --
    hr_utility.set_location(' Leaving:' || l_proc,40);
  Exception
    when app_exception.application_exception then
    IF hr_multi_message.exception_add
          (p_associated_column1 => 'HR_KI_HIERARCHIES.HIERARCHY_KEY'
           )
    THEN
          hr_utility.set_location(' Leaving:'|| l_proc,50);
          raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,60);
  --
End chk_hierarchy_key ;

-- ----------------------------------------------------------------------------
-- ---------------------< CHK_PARENT_HIERARCHY_ID>-----------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a valid parent hierarchy id is entered
--
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_parent_hierarchy_id

-- Post Success:
--   Processing continues if the parent hierarchy id is valid.
--
-- Post Failure:
--   An application error is raised if there are any child rows from any of the
--   above mentioned tables.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_parent_hierarchy_id
(p_parent_hierarchy_id  in number
)
is
  --
  -- Declare cursors and local variables
  cursor csr_hrc_parent_id is
    select
     'found'
    From
      hr_ki_hierarchies  hrc
    where
      hrc.hierarchy_id = p_parent_hierarchy_id;

  cursor csr_check_null is
    select
     'found'
    From
      hr_ki_hierarchies hrc
    Where
      hrc.parent_hierarchy_id is null;


  -- Variables for API Boolean parameters
  l_proc              varchar2(72) := g_package ||'chk_parent_hierarchy_id';
  l_found             varchar2(10);

Begin

  hr_utility.set_location(' Entering:'|| l_proc,10);


  -- if the parent hierarchy id is null, then check if there is already a
  -- global functional node

  if p_parent_hierarchy_id is null then

    hr_utility.set_location(' Parent hierarchy id is null:'|| l_proc,20);

    open csr_check_null;
    fetch csr_check_null into l_found;

    If csr_check_null%FOUND then
       hr_utility.set_location(' Global functional node already exists:'
                               || l_proc,30);
       close csr_check_null;
       fnd_message.set_name( 'PER','PER_449915_HRC_GLBL_FUNC_PRES');
       fnd_message.raise_error;
    End If;

    close csr_check_null;

  else

    hr_utility.set_location(' Parent hierarchy is not null:'|| l_proc,40);

    open csr_hrc_parent_id;
    fetch csr_hrc_parent_id into l_found;

    If csr_hrc_parent_id%NOTFOUND then
       hr_utility.set_location(' Parent hierarchy does not exist:'
                                 || l_proc,50);
       close csr_hrc_parent_id;
       fnd_message.set_name( 'PER','PER_449916_HRC_PARNT_ID_ABSNT');
       fnd_message.raise_error;
    End If;

    close csr_hrc_parent_id;

  End If;

    hr_utility.set_location(' Leaving:'|| l_proc,60);

  Exception
   when app_exception.application_exception then
    If hr_multi_message.exception_add
                 (p_associated_column1   =>
                  'HR_KI_HIERARCHIES.PARENT_HIERARCHY_ID'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,70);
       raise;
    End If;

    hr_utility.set_location(' Leaving:'|| l_proc,80);
  --
End chk_parent_hierarchy_id ;
-- ----------------------------------------------------------------------------
-- ---------------------< CHK_PARENT_HIERARCHY_ID_UPDATE>----------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that parent hierarchy id of the global functional
--   node is not updated
--
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_parent_hierarchy_id

-- Post Success:
--   Processing continues if the parent hierarchy id is valid.
--
-- Post Failure:
--   An application error is raised if there are any child rows from any of the
--   above mentioned tables.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_parent_hierarchy_id_update
(p_parent_hierarchy_id  in number
)
is
  -- Variables for API Boolean parameters
  l_proc              varchar2(72) := g_package ||'chk_parent_hierarchy_id_update';
  l_found             varchar2(10);

Begin

  hr_utility.set_location(' Entering:'|| l_proc,10);

  -- check if we are trying to update the parent id of global func node
  if hr_hrc_shd.g_old_rec.parent_hierarchy_id is null and
     (nvl(p_parent_hierarchy_id, hr_api.g_number) <>
      nvl(hr_hrc_shd.g_old_rec.parent_hierarchy_id,hr_api.g_number))
         then
         hr_utility.set_location(' Parent hierarchy id of global node updated:'
                                    || l_proc,20);
         fnd_message.set_name( 'PER','PER_449914_HRC_GLBLND_NONUPD');
         fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Leaving:' || l_proc,30);

 Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1 =>'HR_KI_HIERARCHIES.PARENT_HIERARCHY_ID'
                  )THEN
       hr_utility.set_location(' Leaving:'|| l_proc,40);
       raise;
    END IF;
  hr_utility.set_location(' Leaving:'|| l_proc,50);

End chk_parent_hierarchy_id_update;

-- ----------------------------------------------------------------------------
-- ---------------------< CHK_CYCLIC_HIEARCHY>---------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a cyclic hierarchy does not occur as a result
--   of an update.
--
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_parent_hierarchy_id

-- Post Success:
--   Processing continues if no cycle occurs.
--
-- Post Failure:
--   An application error is raised if there are any child rows from any of the
--   above mentioned tables.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_cyclic_hierarhcy
(p_hierarchy_id  in number,
 p_parent_hierarchy_id  in number
)
is

  cursor csr_cycle_chk
  is
  select
   'found'
  from
   dual
  where
  p_hierarchy_id in
  (
     select
     hrc.hierarchy_id
     from hr_ki_hierarchies hrc
     connect by prior hrc.parent_hierarchy_id = hrc.hierarchy_id
     start with hrc.hierarchy_id = p_parent_hierarchy_id
  );
  -- Variables for API Boolean parameters
  l_proc              varchar2(72) := g_package ||'chk_parent_hierarchy_id_update';
  l_found             varchar2(10);

Begin

  hr_utility.set_location(' Entering:'|| l_proc,10);

  -- check if the parent_hierarchy_id that we are updating to will yield a cycle
  open csr_cycle_chk;
  fetch csr_cycle_chk into l_found;

  If csr_cycle_chk%FOUND then
       hr_utility.set_location(' Update will result in a cyclic hierarchy, aborting'
                                 || l_proc,20);
       close csr_cycle_chk;
       fnd_message.set_name( 'PER','PER_449087_HRC_UPD_CYCLIC');
       fnd_message.raise_error;
  End If;

  close csr_cycle_chk;

  hr_utility.set_location(' Leaving:' || l_proc,30);

 Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1 =>'HR_KI_HIERARCHIES.PARENT_HIERARCHY_ID'
                  )THEN
       hr_utility.set_location(' Leaving:'|| l_proc,40);
       raise;
    END IF;
  hr_utility.set_location(' Leaving:'|| l_proc,50);

End chk_cyclic_hierarhcy;
-- ----------------------------------------------------------------------------
-- -----------------------------< CHK_DELETE>----------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a delete occurs only if there are no child
--   rows for a record in hr_ki_hierarchies. The tables that contain child rows
--   are hr_ki_hierarchies, hr_ki_hierarchy_node_maps,hr_ki_hierarchies_tl.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_hierarchy_id

-- Post Success:
--   Processing continues if there are no child records.
--
-- Post Failure:
--   An application error is raised if there are any child rows from any of the
--   above mentioned tables.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_delete(p_hierarchy_id in varchar2)
is

CURSOR csr_hrc_id is
    select
      distinct 'found'
    From
      hr_ki_hierarchies  hrc
    where
      hrc.parent_hierarchy_id = p_hierarchy_id;

CURSOR csr_hnm_id is
    select
      distinct 'found'
    From
      hr_ki_hierarchy_node_maps  hnm
    where
      hnm.hierarchy_id = p_hierarchy_id;

CURSOR csr_htl_id is
    select
      distinct 'found'
    From
      hr_ki_hierarchies_tl  htl
    where
      htl.hierarchy_id = p_hierarchy_id;

l_found   varchar2(30);
l_proc    varchar2(72) := g_package ||'chk_delete';

Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  open csr_hrc_id;
  fetch csr_hrc_id into l_found;

  if csr_hrc_id%FOUND then
    close csr_hrc_id;
    fnd_message.set_name( 'PER','PER_449917_HRC_HRC_MAIN_EXIST');
    fnd_message.raise_error;
  end if;

  close csr_hrc_id;

  open csr_hnm_id;
  fetch csr_hnm_id into l_found;

  if csr_hnm_id%FOUND then
    close csr_hnm_id;
    fnd_message.set_name( 'PER','PER_449918_HRC_HNM_MAIN_EXIST');
    fnd_message.raise_error;
  end if;

  close csr_hnm_id;

  open csr_htl_id;
  fetch csr_htl_id into l_found;

  if csr_htl_id%FOUND then
    close csr_htl_id;
    fnd_message.set_name( 'PER','PER_449919_HRC_HTL_MAIN_EXIST');
    fnd_message.raise_error;
  end if;

  close csr_htl_id;

 hr_utility.set_location(' Leaving:' || l_proc,20);

 Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'HR_KI_HIERARCHIES.HIERARCHY_ID'
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
  (p_rec                          in hr_hrc_shd.g_rec_type
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
  chk_hierarchy_key(p_hierarchy_key => p_rec.hierarchy_key);
  chk_parent_hierarchy_id(p_parent_hierarchy_id => p_rec.parent_hierarchy_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_hrc_shd.g_rec_type
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
  --
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );

  chk_parent_hierarchy_id_update(p_parent_hierarchy_id => p_rec.parent_hierarchy_id);
  chk_parent_hierarchy_id(p_parent_hierarchy_id => p_rec.parent_hierarchy_id);
  chk_cyclic_hierarhcy(p_hierarchy_id => p_rec.hierarchy_id,
                          p_parent_hierarchy_id => p_rec.parent_hierarchy_id
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
  (p_rec                          in hr_hrc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_hierarchy_id => p_rec.hierarchy_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_hrc_bus;

/
