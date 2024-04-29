--------------------------------------------------------
--  DDL for Package Body HR_HNM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HNM_BUS" as
/* $Header: hrhnmrhi.pkb 115.0 2004/01/09 01:21 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_hnm_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_hierarchy_node_map_id       number         default null;
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
  (p_rec in hr_hnm_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_hnm_shd.api_updating
      (p_hierarchy_node_map_id             => p_rec.hierarchy_node_map_id
      ,p_object_version_number             => p_rec.object_version_number
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
-- ----------------------------------------------------------------------------
-- --------------------------< CHK_HIERARCHY_ID>------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the hierarchy id entered is present in the
--   master table hr_ki_hierarchies if not null.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_hierarchy_id

-- Post Success:
--   Processing continues if hierarchy id is present in hr_ki_hierarchies
--
-- Post Failure:
--   An application error is raised if hierarchy id does not exist in
--   hr_ki_hierarchies.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_hierarchy_id(p_hierarchy_id in number)
is
l_proc varchar2(72) := g_package || 'chk_hierarchy_id';
l_found varchar2(10);


CURSOR csr_hrc_id is
  select
   'found'
  From
    hr_ki_hierarchies  hrc
  where
    hrc.hierarchy_id = p_hierarchy_id;


begin

  hr_utility.set_location(' Entering:' || l_proc,10);

 -- check if the hierarchy id is not null
 if(p_hierarchy_id is not null)
 then
    -- check if the id exists in the hr_ki_hierarchies
   open csr_hrc_id;

   fetch csr_hrc_id into l_found;

   if(csr_hrc_id%NOTFOUND) then
     close csr_hrc_id;
     fnd_message.set_name('PER','PER_449922_HNM_HRCPRNT_ABSNT');
     fnd_message.raise_error;
   end if;
   close csr_hrc_id;
 end if;

hr_utility.set_location(' Leaving:' || l_proc,20);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   =>
                  'HR_KI_HIERARCHY_NODE_MAPS.HIERARCHY_ID'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);

end chk_hierarchy_id;

-- ----------------------------------------------------------------------------
-- ------------------------------< CHK_TOPIC_ID>-------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the topic id entered is present in the
--   master table hr_ki_topics if not null.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_topic_id

-- Post Success:
--   Processing continues if topic id is present in hr_ki_topics
--
-- Post Failure:
--   An application error is raised if topic id does not exist in
--   hr_ki_topics.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_topic_id(p_topic_id in number)
is
l_proc varchar2(72) := g_package || 'chk_topic_id';
l_found varchar2(10);


CURSOR csr_tpc_id is
  select
   'found'
  From
    hr_ki_topics  tpc
  where
    tpc.topic_id = p_topic_id;


begin

  hr_utility.set_location(' Entering:' || l_proc,10);

-- if the topic id is not null, check whether it exists in hr_ki_topics
 if(p_topic_id is not null)
 then
    -- check if the id, key combination exists in the hr_ki_hierarchies
   open csr_tpc_id;

   fetch csr_tpc_id into l_found;

   if(csr_tpc_id%NOTFOUND) then
     close csr_tpc_id;
     fnd_message.set_name('PER','PER_449923_HNM_TPCPRNT_ABSNT');
     fnd_message.raise_error;
   end if;
   close csr_tpc_id;
 end if;

hr_utility.set_location(' Leaving:' || l_proc,20);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   =>
                  'HR_KI_HIERARCHY_NODE_MAPS.TOPIC_ID'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);

end chk_topic_id;

-- ----------------------------------------------------------------------------
-- ---------------------------< CHK_USER_INTERFACE_ID>-------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the user interface id entered is present in
--   the master table hr_ki_user_interfaces if not null.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_user_interface_id

-- Post Success:
--   Processing continues if user interface id is present in
--   hr_ki_user_interfaces.
--
-- Post Failure:
--   An application error is raised if user interface id does not exist in
--   hr_ki_user_interfaces.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_user_interface_id(p_user_interface_id in number)
is
l_proc varchar2(72) := g_package || 'chk_user_interface_id';
l_found varchar2(10);


CURSOR csr_itf_id is
  select
   'found'
  From
    hr_ki_user_interfaces  itf
  where
    itf.user_interface_id = p_user_interface_id;


begin

  hr_utility.set_location(' Entering:' || l_proc,10);

-- if the topic id is not null, check whether it exists in hr_ki_topics
 if(p_user_interface_id is not null)
 then
    -- check if the id, key combination exists in the hr_ki_hierarchies
   open csr_itf_id;

   fetch csr_itf_id into l_found;

   if(csr_itf_id%NOTFOUND) then
     close csr_itf_id;
     fnd_message.set_name('PER','PER_449924_HNM_INTPRNT_ABSNT');
     fnd_message.raise_error;
   end if;
   close csr_itf_id;
 end if;

hr_utility.set_location(' Leaving:' || l_proc,20);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   =>
                  'HR_KI_HIERARCHY_NODE_MAPS.USER_INTERFACE_ID'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);

end chk_user_interface_id;

-- ----------------------------------------------------------------------------
-- ---------------------------<CHK_VALID_COMBINATION>--------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the correct combination of values for
--   hierarchy_id,topic_id and user_interface_id are passed to the row handler
--
--   The following combinations are valid

--   hierarchy_id + topic_id
--   hierarchy_id + user_interface_id
--   topic_id + user_interface_id

--   In each of the above cases, the third parameter must be null.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_hierarchy_id,p_topic_id,p_user_interface_id

-- Post Success:
--   Processing continues if a valid combination has been entered
--
-- Post Failure:
--   An application error is raised if an incorrect combination is entered
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_valid_combination(p_hierarchy_id in number,
                                p_topic_id in number,
                                p_user_interface_id in number)
is
l_proc varchar2(72) := g_package || 'chk_valid_combination';
l_found varchar2(30);

begin

    hr_utility.set_location(' Entering:' || l_proc,10);

-- check if the combination of values entered for hierarchy_id, topic_id,
-- and user_interface_id are correct.

    if(p_hierarchy_id is not null)
     then
       -- the hierarchy entries are not null, hence either the topic or the
       -- ui entries should be populated,if both are populated then an
       -- invalid combination is reported.

      if( (p_topic_id is null and p_user_interface_id is null) or
          (p_topic_id is not null and p_user_interface_id is not null)
        )
       then
        fnd_message.set_name('PER','PER_449928_HNM_HRCINVLD_COMB');
        fnd_message.raise_error;
      end if;

    else

      if(p_topic_id is null or
             p_user_interface_id is null)
       then
        fnd_message.set_name('PER','PER_449929_HNM_TPINTINVLD_COM');
        fnd_message.raise_error;
      end if;

    end if;

    hr_utility.set_location(' Leaving:' || l_proc,20);

    Exception
     when app_exception.application_exception then
      IF hr_multi_message.exception_add
                 (p_associated_column1   =>
                 'HR_KI_HIERARCHY_NODE_MAPS.HIERARCHY_ID',
                  p_associated_column2   =>
                 'HR_KI_HIERARCHY_NODE_MAPS.TOPIC_ID',
                  p_associated_column3   =>
                 'HR_KI_HIERARCHY_NODE_MAPS.USER_INTERFACE_ID'
                 ) THEN
      hr_utility.set_location(' Leaving:'|| l_proc,30);
      raise;
     END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);

end chk_valid_combination;

-- ----------------------------------------------------------------------------
-- ---------------------------<CHK_UNIQUE_COMBINATION>-------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a unique combination of the below three
--   cases are entered.
--
--   topic_id + hierarchy_id -> a row is entered with this combination only if
--                              topic_id has not already been assigned to
--                              hierarchy_id or any of it's ancestors in the
--                              hierarchy tree.
--
--   user_interface_id + hierarchy_id -> a row is entered with this combination
--                                       only if user_interface_id has not
--                                       already been assigned to hierarchy_id
--
--   topic_id + user_interface_id -> a row is entered with this combinaton only
--                                   if topic_id has not already been assigned
--                                   to user_interface_id either directly or
--                                   indirectly through the hierarchy tree
--                                   accessible through that UI.
--
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_hierarchy_id,p_topic_id,p_user_interface_id
--
-- Post Success:
--   Processing continues if a valid unique combination has been entered
--
-- Post Failure:
--   An application error is raised if an non unique combination is entered
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_unique_combination(p_hierarchy_id in number,
                                p_topic_id in number,
                                p_user_interface_id in number)
is

cursor csr_hnm_hrctp
is
select
 distinct 'found'
From
 hr_ki_hierarchy_node_maps hnm
where
 hnm.topic_id = p_topic_id
 and hnm.hierarchy_id in
 (
   select hrc.hierarchy_id
   from
   hr_ki_hierarchies hrc
   connect by prior hrc.parent_hierarchy_id = hrc.hierarchy_id
   start with hrc.hierarchy_id = p_hierarchy_id
  );

 cursor csr_hnm_hrcui
 is
 select
  distinct 'found'
 From
  hr_ki_hierarchy_node_maps hnm
 where
  hnm.hierarchy_id = p_hierarchy_id and
  hnm.user_interface_id = p_user_interface_id;

 cursor csr_hnm_tpui
 is
 select
 distinct 'found'
 from
  hr_ki_hierarchy_node_maps hnm
 where
 (
   hnm.topic_id = p_topic_id
   and hnm.user_interface_id = p_user_interface_id
 )
 OR
 (
   hnm.topic_id = p_topic_id
   and hnm.hierarchy_id in
   (
    select
     hierarchy_id
    from
     hr_ki_hierarchies hrc
    connect by prior hrc.parent_hierarchy_id = hrc.hierarchy_id
    start with hrc.hierarchy_id in (
                                 select
                                  hierarchy_id
                                 from
                                  hr_ki_hierarchy_node_maps hnm1
                                 where
                                  hnm1.user_interface_id=p_user_interface_id
				  and hnm1.hierarchy_id is not null
                                 )
    )
   );


l_proc varchar2(72) := g_package || 'chk_unique_combination';
l_found varchar2(10);

Begin

    hr_utility.set_location(' Entering:' || l_proc,10);

-- the following validation needs to be done only if no errors have already
-- been detected previously, an inclusive error check needs to be done to
-- accomodate errors occuring from the first chk_valid_combination check.

 if hr_multi_message.no_all_inclusive_error
               (p_check_column1      =>
               'HR_KI_HIERARCHY_NODE_MAPS.HIERARCHY_ID'
               ,p_check_column2      =>
               'HR_KI_HIERARCHY_NODE_MAPS.TOPIC_ID'
               ,p_check_column3 =>
               'HR_KI_HIERARCHY_NODE_MAPS.USER_INTERFACE'
               )
  then
    if p_hierarchy_id is not null and p_topic_id is not null
    then
      -- check if there already exists a row in HNM with this combination
      -- checks to be made:
      -- 1.   check if a row exists with the exact pair
      -- 2.   check if the topic has already been assigned to a hierarchy node
      --      higher up the hierarchy from p_hierarchy_id

       open csr_hnm_hrctp;
       fetch csr_hnm_hrctp into l_found;

       if(csr_hnm_hrctp%FOUND)
       then
         close csr_hnm_hrctp;
         fnd_message.set_name('PER','PER_449925_HNM_HRCTPMAP_DUPLI');
         fnd_message.raise_error;
       end if;

       close csr_hnm_hrctp;

    elsif p_hierarchy_id is not null and p_user_interface_id is not null
    then
      -- check if there already exists a row in HNM with this combination
       open csr_hnm_hrcui;
       fetch csr_hnm_hrcui into l_found;

       if(csr_hnm_hrcui%FOUND)
       then
         close csr_hnm_hrcui;
         fnd_message.set_name('PER','PER_449926_HNM_HRCUIMAP_DUPLI');
         fnd_message.raise_error;
       end if;

       close csr_hnm_hrcui;

    elsif p_hierarchy_id is null
    then
      -- check if the topic,user interface combination exists in HNM.
      -- checks to be made:
      -- 1. check if a row exists with the exact pair
      -- 2. check if the topic has already been assigned to that UI through
      --    a hierarchy node.

       open csr_hnm_tpui;
       fetch csr_hnm_tpui into l_found;

       if(csr_hnm_tpui%FOUND)
       then
         close csr_hnm_tpui;
         fnd_message.set_name('PER','PER_449927_HNM_TPCUIMAP_DUPLI');
         fnd_message.raise_error;
       end if;

       close csr_hnm_tpui;

     end if;

    end if;

    hr_utility.set_location(' Leaving:' || l_proc,20);

    Exception
     when app_exception.application_exception then
      IF hr_multi_message.exception_add
                 (p_associated_column1   =>
                 'HR_KI_HIERARCHY_NODE_MAPS.HIERARCHY_ID',
                  p_associated_column2   =>
                 'HR_KI_HIERARCHY_NODE_MAPS.TOPIC_ID',
                  p_associated_column3   =>
                 'HR_KI_HIERARCHY_NODE_MAPS.USER_INTERFACE_ID'
                 ) THEN
      hr_utility.set_location(' Leaving:'|| l_proc,30);
      raise;
     END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);

End chk_unique_combination;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_hnm_shd.g_rec_type
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
  -- Validate Dependent Attributes
  chk_valid_combination(p_hierarchy_id      => p_rec.hierarchy_id,
                        p_topic_id          => p_rec.topic_id,
                        p_user_interface_id => p_rec.user_interface_id);

  chk_hierarchy_id(p_hierarchy_id => p_rec.hierarchy_id);

  chk_topic_id(p_topic_id => p_rec.topic_id);

  chk_user_interface_id(p_user_interface_id => p_rec.user_interface_id);

  chk_unique_combination(p_hierarchy_id      => p_rec.hierarchy_id,
                         p_topic_id          => p_rec.topic_id,
                         p_user_interface_id => p_rec.user_interface_id);


  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_hnm_shd.g_rec_type
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
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );

  chk_valid_combination(p_hierarchy_id      => p_rec.hierarchy_id,
                        p_topic_id          => p_rec.topic_id,
                        p_user_interface_id => p_rec.user_interface_id);

  chk_hierarchy_id(p_hierarchy_id => p_rec.hierarchy_id);

  chk_topic_id(p_topic_id => p_rec.topic_id);

  chk_user_interface_id(p_user_interface_id => p_rec.user_interface_id);

  chk_unique_combination(p_hierarchy_id      => p_rec.hierarchy_id,
                         p_topic_id          => p_rec.topic_id,
                         p_user_interface_id => p_rec.user_interface_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_hnm_shd.g_rec_type
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
end hr_hnm_bus;

/
