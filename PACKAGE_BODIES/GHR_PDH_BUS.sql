--------------------------------------------------------
--  DDL for Package Body GHR_PDH_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDH_BUS" as
/* $Header: ghpdhrhi.pkb 120.1 2006/01/17 06:21:22 sumarimu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pdh_bus.';  -- Global package name


Procedure chk_non_updateable_args(p_rec in  ghr_pdh_shd.g_rec_type) is
   --
     l_proc          varchar2(72) := g_package || 'chk_non_updateable_args';
     l_error         exception;
     l_argument  varchar2(30);
  --
    Begin
       hr_utility.set_location( ' Entering:' ||l_proc, 10);
       --
       -- Only proceed with validation of a row exists for
       -- the current record in the HR schema
       --
       if not ghr_pdh_shd.api_updating
           (p_pd_routing_history_id       => p_rec.pd_routing_history_id
           ,p_object_version_number       => p_rec.object_version_number
           ) then
           hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message('PROCEDURE',l_proc);
           hr_utility.set_message('STEP', '20');
      end if;
      hr_utility.set_location(l_proc,30);
      --
     if  nvl(p_rec.position_description_id,hr_api.g_number)
               <> nvl(ghr_pdh_shd.g_old_rec.position_description_id,hr_api.g_number) then
              l_argument := 'position_description_id';
              raise l_error;
     end if;
     if  nvl(p_rec.groupbox_id,hr_api.g_number)
               <> nvl(ghr_pdh_shd.g_old_rec.groupbox_id,hr_api.g_number) then
              l_argument := 'groupbox_id';
              raise l_error;
     end if;
     if  nvl(p_rec.routing_list_id,hr_api.g_number)
               <> nvl(ghr_pdh_shd.g_old_rec.routing_list_id,hr_api.g_number) then
              l_argument := 'routing_list_id';
              raise l_error;
     end if;

     if  nvl(p_rec.routing_seq_number,hr_api.g_number)
               <> nvl(ghr_pdh_shd.g_old_rec.routing_seq_number,hr_api.g_number) then
              l_argument := 'routing_seq_number';
              raise l_error;
     end if;

--     if  nvl(p_rec.nature_of_action_id,hr_api.g_number)
--               <> nvl(ghr_pdh_shd.g_old_rec.nature_of_action_id,hr_api.g_number) then
--              l_argument := 'nature_of_action_id';
--              raise l_error;
--     end if;
     hr_utility.set_location(l_proc,40);
     --
     exception
          when l_error then
               hr_api.argument_changed_error
                    (p_api_name  => l_proc
                     ,p_argument  => l_argument);
          when others then
              raise;
    end chk_non_updateable_args;
    --

--  ---------------------------------------------------------------------------
--  |--------------------< chk_position_description_id >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the position_description_id exists in the ghr_position_descriptions
--    table
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_position_description_id
--    p_pd_routing_history_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
    Procedure chk_position_description_id
    (p_position_description_id in ghr_pd_routing_history.position_description_id%TYPE
    ,p_pd_routing_history_id in ghr_pd_routing_history.pd_routing_history_id%TYPE
    ,p_object_Version_number in ghr_pd_routing_history.object_version_number%TYPE
    ) is
--
    l_exists         boolean := FALSE;
    l_proc           varchar2(72)  :=  g_package||'chk_position_description_id';
    l_api_updating   boolean;
--
    Cursor  c_pos_desc_id is
      select 1
      from   ghr_position_descriptions  gpd
      where  gpd.position_description_id = p_position_description_id;
--
    begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Check mandatory parameters have been set
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'position_description_id'
    ,p_argument_value => p_position_description_id
    );
    --
    hr_utility.set_location(l_proc, 20);
    --
    --  Only proceed with validation if:
    --  a) The current g_old_rec is current and
    --  b) The routing status value has changed
    --  c) a record is being inserted
    --
    l_api_updating := ghr_pdh_shd.api_updating
    (p_pd_routing_history_id => p_pd_routing_history_id
    ,p_object_version_number => p_object_version_number
    );
    hr_utility.set_location(l_proc, 30);
    --
    if ((l_api_updating
      and nvl(ghr_pdh_shd.g_old_rec.position_description_id, hr_api.g_number)
      <> nvl(p_position_description_id,hr_api.g_number))
    or
      (NOT l_api_updating))
    then
      hr_utility.set_location(l_proc, 40);
      --
      -- Check if position_description_id is valid
      --
      for rec in c_pos_desc_id loop
        l_exists := TRUE;
        exit;
      end loop;
      if  not l_exists then
        ghr_pdh_shd.constraint_error(p_constraint_name => 'GHR_PD_ROUTING_HIST_FK1');
      end if;
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 3);
    end chk_position_description_id;



-- ----------------------------------------------------------------------------
-- |---------------------------<chk_groupbox_id>----------------------------|
-- ----------------------------------------------------------------------------
--  Description:
--    Validates that the group_box_id exists in the table GHR_GROUPBOXES
--    for a specific routing_group
--
--  Pre-conditions:
--
--
--  In Arguments:
--    p_pd_routing_history_id
--    p_position_description_id
--    p_groupbox_id
--    p_object_version_number
--
--  Post Success:
--    If the  group_box_id is valid
--    processing continues
--
--  Post Failure:
--    An application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_groupbox_id
(p_pd_routing_history_id       in   ghr_pd_routing_history.pd_routing_history_id%TYPE
,p_position_description_id     in   ghr_position_descriptions.position_description_id%TYPE
,p_groupbox_id                 in   ghr_pd_routing_history.groupbox_id%TYPE
,p_object_version_number       in   ghr_pd_routing_history.object_version_number%TYPE
)is

--
  l_exists            boolean       := false;
  l_proc              varchar2(72)  :=  g_package||'chk_groupbox_id';
  l_api_updating      boolean;
--
 Cursor  c_gpbox_id is
   select 1
   from   ghr_groupboxes   gbx,
          ghr_position_descriptions  gpd
   where  gpd.position_description_id       = p_position_description_id
   and    gbx.routing_group_id      = gpd.routing_group_id
   and    gbx.groupbox_id           = p_groupbox_id;
--
 begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
     hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'position_description_id'
     ,p_argument_value => p_position_description_id
    );
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) routing_seq_number has changed
  --  c) A record is being inserted
  --
  l_api_updating := ghr_pdh_shd.api_updating
    (p_pd_routing_history_id => p_pd_routing_history_id
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and nvl(ghr_pdh_shd.g_old_rec.groupbox_id,hr_api.g_number)
      <> nvl(p_groupbox_id,hr_api.g_number))
      or (NOT l_api_updating)) then
   --
    hr_utility.set_location(l_proc, 2);
    --
    -- check if the groupbox_id exists for the
    -- routing_group_id
    if p_groupbox_id is not null then
      for rec in c_gpbox_id loop
        l_exists := true;
        exit;
      end loop;
      if  not l_exists then
        hr_utility.set_message(8301,'GHR_38101_INV_GROUPBOX_ID');
        hr_utility.raise_error;
      end if;
    end if;
--
  end if;
 --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_groupbox_id;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_user_name>----------------------------|
-- ----------------------------------------------------------------------------

--  Description:
--    Validates that the user_name exists in the table fnd_user and
--  Pre-conditions:
--
--
--  In Arguments:
--    p_pd_routing_history_id
--    p_user_name
--    p_object_version_number
--
--  Post Success:
--    If the user_person_id is valid
--    processing continues
--
--  Post Failure:
--   An application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--

Procedure chk_user_name
 (p_pd_routing_history_id    in ghr_pd_routing_history.pd_routing_history_id%TYPE
 ,p_user_name                in ghr_pd_routing_history.user_name%TYPE
 ,p_groupbox_id              in ghr_pd_routing_history.groupbox_id%TYPE
 ,P_object_version_number    in ghr_pd_routing_history.object_version_number%TYPE
 ) is
--
 l_proc    varchar2(72)   := g_package ||'chk_user_name';
 l_exists  boolean        := false;
 l_api_updating  boolean;
 l_gpbox_id     number   := p_groupbox_id;
-- cursor to check that the person_id exists.
--
 cursor   c_groupbox_user is
   select 1
   from   ghr_groupbox_users gbu
   where  gbu.groupbox_id = p_groupbox_id
   and    gbu.user_name   = p_user_name;
-- Sundar -  Below cursor commented and modified
-- for 11.5.10 Performance repository changes

/* cursor c_user_name is
   select 1
   from   fnd_user
   where  upper(user_name) = upper(p_user_name);  */
-- Bug 4863608 Perf changes.
 CURSOR  c_user_name is
   SELECT 1
   FROM   fnd_user
   WHERE  user_name = upper(p_user_name);
/* CURSOR c_user_name IS
   SELECT 1
   FROM   fnd_user
   WHERE  UPPER(user_name) = UPPER(p_user_name)
   AND user_name LIKE UPPER(p_user_name); */

 begin
   hr_utility.set_location('Entering:'||l_proc,10);
 --
 --  Only proceed with validation if:
 --  a) The current g_old_rec is current and
 --  b) routing_user_name has changed
 --  c) A record is being inserted
 --
  l_api_updating := ghr_pdh_shd.api_updating
    (p_pd_routing_history_id => p_pd_routing_history_id
    ,p_object_version_number => p_object_version_number
   );

 --
  if ((l_api_updating and nvl(ghr_pdh_shd.g_old_rec.user_name,hr_api.g_varchar2)
       <> nvl(p_user_name,hr_api.g_varchar2))
      or (NOT l_api_updating)) then

 --
    hr_utility.set_location(l_proc, 2);
 --
 -- check if the user_name is valid
    if p_user_name is not null then
      if p_groupbox_id is not null then
        for groupbox_user in c_groupbox_user loop
          l_exists := true;
          exit;
        end loop;
        if not l_exists then
          hr_utility.set_message(8301,'GHR_38103_INV_GROUPBOX_USER');
          hr_utility.raise_error;
        end if;
      end if;
      l_exists := false;
      for c_user_name_rec in c_user_name loop
        l_exists := true;
        exit;
      end loop;
      if  not l_exists then
        hr_utility.set_message(8301,'GHR_38102_INV_USER_NAME');
        hr_utility.raise_error;
      end if;
    end if;
  end if;
 --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_user_name;
--


--  ---------------------------------------------------------------------------
--  |-----------------------< chk_routing_list_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the routing_list_id exists in the table
--    ghr_routing_lists
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_routing_list_id
--    p_pd_routing_history_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
    Procedure chk_routing_list_id
    (p_routing_list_id         in ghr_pd_routing_history.routing_list_id%TYPE
    ,p_pd_routing_history_id   in ghr_pd_routing_history.pd_routing_history_id%TYPE
    ,p_object_version_number   in ghr_pd_routing_history.object_version_number%TYPE
    ) is
--
    l_exists         boolean       := false;
    l_proc           varchar2(72)  :=  g_package||'chk_routing_list_id';
    l_api_updating   boolean;
--
    Cursor  c_rout_list_id is
     select 1
     from ghr_routing_lists  prl
     where prl.routing_list_id = p_routing_list_id;
--
   begin
     hr_utility.set_location('Entering:'|| l_proc, 10);
--
--   Check mandatory parameters have been set
--
     hr_utility.set_location(l_proc, 20);
--   Only proceed with validation if:
--   a) The current g_old_rec is current and
--   b) The routing status value has changed
--   c) a record is being inserted
--
     l_api_updating := ghr_pdh_shd.api_updating
     (p_pd_routing_history_id => p_pd_routing_history_id
     ,p_object_version_number => p_object_version_number
     );
     hr_utility.set_location(l_proc, 30);
--
     if ((l_api_updating
      and nvl(ghr_pdh_shd.g_old_rec.routing_list_id, hr_api.g_number)
      <> nvl(p_routing_list_id,hr_api.g_number))
     or
      (NOT l_api_updating))
     then
       hr_utility.set_location(l_proc, 40);
--
--  Check if p_routing_list_id is valid
--
       if p_routing_list_id is not null then
         for rec in c_rout_list_id loop
           l_exists := true;
         end loop;
         if  not l_exists then
           ghr_pdh_shd.constraint_error(p_constraint_name => 'GHR_PD_ROUTING_HIST_FK2');
         end if;
       end if;
     end if;
--
     hr_utility.set_location(' Leaving:'|| l_proc, 50);
   end chk_routing_list_id;
--


-- ----------------------------------------------------------------------------
-- |---------------------------<chk_rout_user_sequ_numb>----------------------------|
-- ----------------------------------------------------------------------------
--  Description:
--     Validates that the routing_seq_number exists in the table
--     'GHR_ROUTING_LIST_MEMBERS for the specific routing_list
--
--  Pre-conditions:
--
--
--  In Arguments:
--
--    p_pd_routing_history_id
--    p_routing_list_id
--    p_routing_seq_number
--    p_object_version_number
--
--  Post Success:
--    If the  routing_seq_number is valid
--    processing continues
--
--  Post Failure:
--   An application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_rout_user_sequ_numb
(p_pd_routing_history_id        in   ghr_pd_routing_history.pd_routing_history_id%TYPE
,p_routing_list_id              in   ghr_pd_routing_history.routing_list_id%TYPE
,p_routing_seq_number           in   ghr_pd_routing_history.routing_seq_number%TYPE
,p_object_version_number        in   ghr_pd_routing_history.object_version_number%TYPE
)is

--
  l_exists            boolean       := FALSE;
  l_proc              varchar2(72)  :=  g_package||'chk_routing_seq_number';
  l_api_updating      boolean;
--
  Cursor  c_seq_num is
    select 1
    from   ghr_routing_list_members rlm
    where  rlm.routing_list_id = p_routing_list_id
    and    rlm.seq_number      = p_routing_seq_number;

  begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) routing_seq_number has changed
  --  c) A record is being inserted
  --
  l_api_updating := ghr_pdh_shd.api_updating
    (p_pd_routing_history_id => p_pd_routing_history_id
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and nvl(ghr_pdh_shd.g_old_rec.routing_seq_number,hr_api.g_number)
    <> nvl(p_routing_seq_number,hr_api.g_number))
      or (NOT l_api_updating)) then
  --
    hr_utility.set_location(l_proc, 2);
  --
  -- check if the routing_seq_number exists for the
  -- routing_list_id
    if p_routing_seq_number is not null then
      for rec in c_seq_num loop
        l_exists := TRUE;
        exit;
      end loop;
      if  not l_exists  then
        hr_utility.set_message(8301,'GHR_38104_INV_ROUT_SEQ_NUM');
        hr_utility.raise_error;
      end if;
    end if;
  end if;
 --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_rout_user_sequ_numb;
--
--

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
          (p_rec               in ghr_pdh_shd.g_rec_type
          )is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --   hr_utility.set_location(l_proc, 10);
  --
  -- to check valid position_description_id
      ghr_pdh_bus.chk_position_description_id
                            (p_position_description_id =>p_rec.position_description_id
                            ,p_pd_routing_history_id =>p_rec.pd_routing_history_id
                            ,p_object_Version_number =>p_rec.object_version_number
                            );


  -- to check valid user_name
     ghr_pdh_bus.chk_user_name(p_user_name             =>p_rec.user_name
                              ,p_groupbox_id           =>p_rec.groupbox_id
                              ,p_pd_routing_history_id =>p_rec.pd_routing_history_id
                              ,p_object_Version_number =>p_rec.object_version_number
                              );

  -- to check valid group box id
     ghr_pdh_bus.chk_groupbox_id(p_pd_routing_history_id =>p_rec.pd_routing_history_id
                                ,p_position_description_id =>p_rec.position_description_id
                                ,p_groupbox_id           =>p_rec.groupbox_id
                                ,p_object_version_number => p_rec.object_version_number
                                );

   -- to check valid routing_list_id
      ghr_pdh_bus.chk_routing_list_id(p_routing_list_id       =>p_rec.routing_list_id
                                     ,p_pd_routing_history_id =>p_rec.pd_routing_history_id
                                     ,p_object_Version_number =>p_rec.object_version_number
                                     );

  --
  -- to check valid routing user sequence number
     ghr_pdh_bus.chk_rout_user_sequ_numb(p_pd_routing_history_id  =>p_rec.pd_routing_history_id
                                        ,p_routing_list_id        =>p_rec.routing_list_id
                                   	    ,p_routing_seq_number     =>p_rec.routing_seq_number
                                        ,p_object_version_number  => p_rec.object_version_number
                                        );
  --

  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
 --Note : identify all non_updateable args and remove code where necessary

Procedure update_validate
          (p_rec               in ghr_pdh_shd.g_rec_type
          )is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- call chk_non_updateable_args
     chk_non_updateable_args (p_rec => p_rec);

  -- Call all supporting business operations
  --
  --   hr_utility.set_location(l_proc, 10);

 -- to check valid user_name
     ghr_pdh_bus.chk_user_name(p_user_name             =>p_rec.user_name
                              ,p_groupbox_id           =>p_rec.groupbox_id
                              ,p_pd_routing_history_id =>p_rec.pd_routing_history_id
                              ,p_object_Version_number =>p_rec.object_version_number
                              );

 -- to check valid group box id
    /* ghr_pdh_bus.chk_groupbox_id(p_pd_routing_history_id =>p_rec.pd_routing_history_id
                                ,p_position_description_id =>p_rec.position_description_id
                                ,p_groupbox_id           =>p_rec.groupbox_id
                                ,p_object_version_number => p_rec.object_version_number
                                );
     */

     hr_utility.set_location(' Leaving:'||l_proc, 60);
End update_validate;


-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ghr_pdh_shd.g_rec_type) is
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

end ghr_pdh_bus;

/
