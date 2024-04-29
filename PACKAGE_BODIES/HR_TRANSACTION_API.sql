--------------------------------------------------------
--  DDL for Package Body HR_TRANSACTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRANSACTION_API" as
/* $Header: petrnapi.pkb 120.7 2007/03/30 00:09:44 ashrivas noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_transaction_api.';
g_debug     boolean := hr_utility.debug_enabled;
-- ----------------------------------------------------------------------------
-- |----------------------< get_transaction_step_info >-----------------------|
-- ----------------------------------------------------------------------------
procedure get_transaction_step_info
  (p_item_type             in     varchar2
  ,p_item_key              in     varchar2
  ,p_activity_id           in     number
  ,p_transaction_step_id      out nocopy number
  ,p_object_version_number    out nocopy number) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
 l_proc constant varchar2(100) := g_package || '  get_transaction_step_info';
  --
  cursor csr_hats is
    select hats.transaction_step_id
          ,hats.object_version_number
    from   hr_api_transaction_steps hats
    where  hats.item_type   = p_item_type
    and    hats.item_key    = p_item_key
    and    hats.activity_id = p_activity_id;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  -- open the cursor
  open csr_hats;
  hr_utility.trace('Going into Fetch after (open csr_hats ): '|| l_proc);
  fetch csr_hats into p_transaction_step_id, p_object_version_number;
  if csr_hats%notfound then
    -- transaction step does not exist
    p_transaction_step_id   := null;
    p_object_version_number := null;
  end if;
  close csr_hats;

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 15);
END IF;

end get_transaction_step_info;
-- --------------------------------------------------------------------
-- ------------------<< get_transaction_step_info >>-------------------
-- --------------------------------------------------------------------
procedure get_transaction_step_info
(p_item_type            in varchar2
,p_item_key             in varchar2
,p_activity_id  in number
,p_transaction_step_id  out nocopy  hr_util_web.g_varchar2_tab_type
,p_object_version_number out nocopy hr_util_web.g_varchar2_tab_type
,p_rows out nocopy number) is
--
-- -------------------------------------------------------------------
-- Read transaction step data, sort by the transaction step id and
-- object version number
-- -------------------------------------------------------------------
cursor csr_hats is
        select hats.transaction_step_id
              ,hats.object_version_number
        from    hr_api_transaction_steps   hats
        where   hats.item_type = p_item_type
        and     hats.item_key = p_item_key
        and     hats.activity_id = p_activity_id
        order by hats.transaction_step_id, hats.object_version_number;
--
l_index         number;
l_data          csr_hats%rowtype;
l_proc constant varchar2(100) := g_package || ' get_transaction_step_info';
--
begin
    hr_utility.set_location('Entering: '|| l_proc,5);
    g_debug := hr_utility.debug_enabled;
    l_index := 0;
        open csr_hats;
        loop
        hr_utility.trace('Going into Fetch after (open csr_hats ): '|| l_proc);
        fetch csr_hats into l_data;
        exit when csr_hats%notfound;
        p_transaction_step_id(l_index) := to_char(l_data.transaction_step_id);
        p_object_version_number(l_index) := to_char(l_data.object_version_number
);
        l_index := l_index + 1;
        end loop;
        close csr_hats;
        p_rows := l_index;
       hr_utility.set_location('Leaving: '|| l_proc,15);
end get_transaction_step_info;
-- --------------------------------------------------------------------
-- ------------------<< get_transaction_step_info >>-------------------
-- --------------------------------------------------------------------
procedure get_transaction_step_info
  (p_item_type            in varchar2
  ,p_item_key             in varchar2
  ,p_transaction_step_id  out nocopy  hr_util_web.g_varchar2_tab_type
  ,p_object_version_number out nocopy hr_util_web.g_varchar2_tab_type
  ,p_rows out nocopy number) is
--
-- -------------------------------------------------------------------
-- Read transaction step data, sort by the transaction step id and
-- object version number
-- -------------------------------------------------------------------
cursor csr_hats is
        select hats.transaction_step_id
              ,hats.object_version_number
        from    hr_api_transaction_steps   hats
        where   hats.item_type = p_item_type
        and     hats.item_key = p_item_key
        order by hats.transaction_step_id, hats.object_version_number;
--
l_index         number;
l_data          csr_hats%rowtype;
l_proc constant varchar2(100) := g_package || ' get_transaction_step_info';
--
BEGIN
     hr_utility.set_location('Entering: '|| l_proc,5);
    g_debug := hr_utility.debug_enabled;
    l_index := 0;
        open csr_hats;
        loop
        hr_utility.trace('Going into Fetch after (open csr_hats ): '|| l_proc);
        fetch csr_hats into l_data;
        exit when csr_hats%notfound;
        p_transaction_step_id(l_index) := to_char(l_data.transaction_step_id);
        p_object_version_number(l_index) := to_char(l_data.object_version_number);
        l_index := l_index + 1;
        end loop;
        close csr_hats;
        p_rows := l_index;
  hr_utility.set_location('Leaving: '|| l_proc,15);
end get_transaction_step_info;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_transaction_step_info >-----------------------|
-- ----------------------------------------------------------------------------
procedure get_transaction_step_info
  (p_transaction_step_id   in     number
  ,p_item_type                out nocopy varchar2
  ,p_item_key                 out nocopy varchar2
  ,p_activity_id              out nocopy number) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_transaction_step_info';
  --
  cursor csr_hats is
    select hats.item_type
          ,hats.item_key
          ,hats.activity_id
    from   hr_api_transaction_steps hats
    where  hats.transaction_step_id = p_transaction_step_id;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
 -- l_proc := g_package||'get_transaction_step_info';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  -- open the cursor
  open csr_hats;
  hr_utility.trace('Going into Fetch after (open csr_hats ): '|| l_proc);
  fetch csr_hats into p_item_type, p_item_key, p_activity_id;
  if csr_hats%notfound then
    -- transaction step does not exist
    p_item_type   := null;
    p_item_key    := null;
    p_activity_id := null;
  end if;
  close csr_hats;

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 15);
END IF;

end get_transaction_step_info;
-- ----------------------------------------------------------------------------
-- ------------------<< get_transaction_step_info >>-------------------
-- --------------------------------------------------------------------
procedure get_transaction_step_info
  (p_item_type            in varchar2
  ,p_item_key             in varchar2
  ,p_activity_id          in number default null
  ,p_transaction_step_id  out nocopy  hr_util_web.g_varchar2_tab_type
  ,p_api_name out nocopy hr_util_web.g_varchar2_tab_type
  ,p_rows out nocopy number)IS
--
-- -------------------------------------------------------------------
-- Read transaction step data, sort by the transaction step id and
-- object version number
-- -------------------------------------------------------------------
cursor csr_hapi is
        select hats.transaction_step_id
              ,hats.api_name
        from    hr_api_transaction_steps   hats
        where   hats.item_type = p_item_type
        and     hats.item_key = p_item_key
        and     hats.activity_id = p_activity_id
        order by hats.transaction_step_id, hats.object_version_number;
--
cursor csr_hapi_nAct is
        select hats.transaction_step_id
              ,hats.api_name
        from    hr_api_transaction_steps   hats
        where   hats.item_type = p_item_type
        and     hats.item_key = p_item_key
        order by hats.transaction_step_id, hats.object_version_number;
--

l_index         number;
l_data          csr_hapi%rowtype;
l_cursor        varchar2(20);
l_proc constant varchar2(100) := g_package || ' get_transaction_step_info ';
--
begin

    hr_utility.set_location('Entering: '|| l_proc,5);
    g_debug := hr_utility.debug_enabled;
    l_index := 0;

    if(p_activity_id is null) then
        open csr_hapi_nAct;
        loop
        hr_utility.trace('Going into Fetch after (open csr_hapi_nAct ): '|| l_proc);
        fetch csr_hapi_nAct into l_data;
        exit when csr_hapi_nAct%notfound;
        p_transaction_step_id(l_index) := to_char(l_data.transaction_step_id);
        p_api_name(l_index) := l_data.api_name;
        l_index := l_index + 1;
        end loop;
        close csr_hapi_nAct;
     else
       open csr_hapi;
        loop
        hr_utility.trace('Going into Fetch after (open csr_hapi ): '|| l_proc);
        fetch csr_hapi into l_data;
        exit when csr_hapi%notfound;
        p_transaction_step_id(l_index) := to_char(l_data.transaction_step_id);
        p_api_name(l_index) := l_data.api_name;
        l_index := l_index + 1;
        end loop;
        close csr_hapi;
     end if;

     p_rows := l_index;

hr_utility.set_location('Leaving: '|| l_proc,20);
end get_transaction_step_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< transaction_step_exist >-------------------------|
-- ----------------------------------------------------------------------------
function transaction_step_exist
  (p_item_type   in varchar2
  ,p_item_key    in varchar2
  ,p_activity_id in number) return boolean is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' transaction_step_exist';
  l_object_version_number  hr_api_transaction_steps.object_version_number%type;
  l_transaction_step_id    hr_api_transaction_steps.transaction_step_id%type;
  l_return                 boolean := true;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
 --l_proc := g_package||'transaction_step_exist';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  -- get the transaction step info (if a step exists)
  hr_transaction_api.get_transaction_step_info
    (p_item_type             => p_item_type
    ,p_item_key              => p_item_key
    ,p_activity_id           => p_activity_id
    ,p_transaction_step_id   => l_transaction_step_id
    ,p_object_version_number => l_object_version_number);
  --
  if l_transaction_step_id is null then
    -- transaction step does not exist
    l_return := false;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,10);
  return(l_return);
end transaction_step_exist;
-- ----------------------------------------------------------------------------
-- |------------------------< get_transaction_id >----------------------------|
-- ----------------------------------------------------------------------------
function get_transaction_id
  (p_transaction_step_id in number) return number is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_transaction_id';
  l_transaction_id    hr_api_transactions.transaction_id%type;
  -- cursor to select the transaction_id of the step
  cursor csr_hats is
    select hats.transaction_id
    from   hr_api_transaction_steps  hats
    where  hats.transaction_step_id = p_transaction_step_id;

begin

IF g_debug THEN
--  l_proc := g_package||'get_transaction_id';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  open csr_hats;
  hr_utility.trace('Going into Fetch after (open csr_hats ): '|| l_proc);
  fetch csr_hats into l_transaction_id;
  if csr_hats%notfound then
    -- the transaction step doesn't exist
    close csr_hats;
    hr_utility.set_message(801, 'HR_51751_WEB_TRA_STEP_EXISTS');
    hr_utility.raise_error;
  end if;
  close csr_hats;
   hr_utility.set_location(' Leaving:'||l_proc, 15);
  return(l_transaction_id);

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 20);
END IF;

end get_transaction_id;
-- ----------------------------------------------------------------------------
-- |-------------------< check_transaction_privilege >------------------------|
-- ----------------------------------------------------------------------------
procedure check_transaction_privilege
  (p_transaction_id         in number
  ,p_person_id              in number) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || 'check_transaction_privilege';
  l_creator_person_id     hr_api_transactions.creator_person_id%type;
  l_transaction_privilege hr_api_transactions.transaction_privilege%type;
  -- cursor to select the privilege
  cursor csr_hat is
    select hat.creator_person_id
          ,hat.transaction_privilege
    from   hr_api_transactions hat
    where  hat.transaction_id = p_transaction_id;

begin

IF g_debug THEN
--  l_proc := g_package||'check_transaction_privilege';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  open csr_hat;
  hr_utility.trace('Going into Fetch after (open csr_hats ): '|| l_proc);
  fetch csr_hat into l_creator_person_id, l_transaction_privilege;
  if csr_hat%notfound then
    close csr_hat;
    -- transaction not found
    hr_utility.set_message(801, 'HR_51752_WEB_TRANSAC_EXISTS');
    hr_utility.raise_error;
  end if;
  close csr_hat;
  --
  if (l_transaction_privilege  = 'PRIVATEns' and  --ns
      l_creator_person_id <> p_person_id) then
    -- the transaction is PRIVATE and the person who is attempting to
    -- create the step is not the creator of the transaction
    hr_utility.set_message(801, 'HR_51753_WEB_FAIL_CREATE_STEP');
    hr_utility.raise_error;
  end if;

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 15);
END IF;

end check_transaction_privilege;
-- ----------------------------------------------------------------------------
-- |---------------------------< create_transaction >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_transaction
  (p_validate                     in      boolean   default false
  ,p_creator_person_id            in      number
  ,p_transaction_privilege        in      varchar2
  ,p_transaction_id                  out nocopy  number) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' create_transaction';
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'create_transaction';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_transaction;
  end if;
  -- call the row handler to insert the transaction
  hr_trn_ins.ins
    (p_validate              => false
    ,p_transaction_id        => p_transaction_id
    ,p_creator_person_id     => p_creator_person_id
    ,p_transaction_privilege => p_transaction_privilege);
  --
  -- when in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

exception
  when hr_api.validate_enabled then

     hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_transaction;
    -- set primary key to null
    p_transaction_id := null;
end create_transaction;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_transaction >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_transaction
  (p_validate                     in      boolean   default false
  ,p_creator_person_id            in      number
  ,p_transaction_privilege        in      varchar2
  ,p_product_code                   in varchar2 default null
  ,p_url                          in varchar2 default null
  ,p_status                       in varchar2 default null
  ,p_section_display_name          in varchar2 default null
  ,p_function_id                  in number
  ,p_transaction_ref_table        in varchar2 default null
  ,p_transaction_ref_id           in number default null
  ,p_transaction_type             in varchar2 default null
  ,p_assignment_id                in number default null
  ,p_api_addtnl_info              in varchar2 default null
  ,p_selected_person_id           in number default null
  ,p_item_type                    in varchar2 default null
  ,p_item_key                     in varchar2 default null
  ,p_transaction_effective_date       in date default null
  ,p_process_name                 in varchar2 default null
  ,p_plan_id                      in number default null
  ,p_rptg_grp_id                  in number default null
  ,p_effective_date_option        in varchar2 default null
  ,p_transaction_id               out nocopy  number) is
  --
  -- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || '  create_transaction';
  url_too_long exception;
   --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'create_transaction';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;


  IF p_url is not null and length(p_url) > 4000 THEN
    raise url_too_long;
  END IF;

  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_transaction;
  end if;
  -- call the row handler to insert the transaction


  hr_trn_ins.ins(
    p_transaction_id => p_transaction_id,
    p_creator_person_id  =>  p_creator_person_id,
    p_transaction_privilege => p_transaction_privilege,
    p_product_code => p_product_code,
    p_url => p_url,
    p_status  => p_status,
    p_section_display_name => p_section_display_name,
    p_function_id => p_function_id,
    p_transaction_ref_table => p_transaction_ref_table,
    p_transaction_ref_id => p_transaction_ref_id,
    p_transaction_type => p_transaction_type,
    p_assignment_id => p_assignment_id,
    p_api_addtnl_info => p_api_addtnl_info,
    p_selected_person_id => p_selected_person_id,
    p_item_type => p_item_type,
    p_item_key => p_item_key,
    p_transaction_effective_date => p_transaction_effective_date,
    p_process_name => p_process_name,
    p_plan_id => p_plan_id,
    p_rptg_grp_id => p_rptg_grp_id,
    p_effective_date_option => p_effective_date_option,
    p_validate => false
  );
  --
  -- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej

  --
  -- when in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
 --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

exception


  when url_too_long then
    hr_utility.set_location('EXCEPTION: '|| l_proc,560);
    p_transaction_id := null;
    hr_utility.trace(' exception in  ' || 'Url too long, it supports only 4000 characters' );
  when hr_api.validate_enabled then

    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_transaction;
    -- set primary key to null
    p_transaction_id := null;
    hr_utility.trace(' exception in  ' || sqlerrm);
  when others then

hr_utility.set_location('EXCEPTION: '|| l_proc,560);
    p_transaction_id := null;
        hr_utility.trace(' exception in  ' || sqlerrm);
end create_transaction;

--

--ns start
-- New procedure to accept transaction state and/or date_option as a parameter
procedure update_transaction
  (p_validate                     in      boolean   default false
  ,p_transaction_id               in      number
  ,p_status                       in      varchar2  default hr_api.g_varchar2
  ,p_transaction_state            in      varchar2  default hr_api.g_varchar2
  ,p_transaction_effective_date   in      date      default hr_api.g_date
  ,p_effective_date_option        in      varchar2  default hr_api.g_varchar2
  ,p_item_key                     in      varchar2  default hr_api.g_varchar2
) is
------
l_proc constant varchar2(100) := g_package || ' update_transaction';
begin
   hr_utility.set_location('Entering: '|| l_proc,5);
  hr_trn_upd.upd
  (
     p_transaction_id             => p_transaction_id,
     p_status                     => p_status,
     p_transaction_state          => p_transaction_state,
     p_transaction_effective_date => p_transaction_effective_date,
     p_effective_date_option      => p_effective_date_option,
     p_item_key                   => p_item_key
  );
hr_utility.set_location('Leaving: '|| l_proc,10);
end update_transaction;
--ns end


------------------------------------------------------------------------
----------------------- Get_Last_Process_Order--------------------------
------------------------------------------------------------------------
function Get_Last_Process_Order
               (p_process_order_str in varchar2)
return varchar2 is
--
l_last_process_order varchar2(100);
l_proc constant varchar2(100) := g_package || ' Get_Last_Process_Order';
--
begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  g_debug := hr_utility.debug_enabled;
  if p_process_order_str is not null then
     l_last_process_order := rtrim(substr(p_process_order_str, (instr(p_process_order_str, '%', -1,2)) +1),'%' );
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,10);
  return (l_last_process_order);

exception
  when others then
         hr_utility.set_location('EXCEPTION: '|| l_proc,555);
       return(null);
--
end Get_Last_Process_Order ;
--
/*----------------------------------------------------------------------
Set_Process_Order_String constructs the string to store activity id with
the corresponding processing order concatenated.It's called in Block proc.
----------------------------------------------------------------------*/
------------------------------------------------------------------------
----------------------- Set_Process_Order_String------------------------
------------------------------------------------------------------------
procedure Set_Process_Order_String
  (p_item_type               in wf_items.item_type%type
  ,p_item_key                in wf_items.item_key%type
  ,p_actid                   in wf_activity_attr_values.process_activity_id%type
  )
is
--
l_value varchar2(4000);
l_last_process_order number;
l_process_order_str varchar2(4000);
l_counter number := 2;
l_dummy  number(1);
l_proc constant varchar2(100) := g_package || ' Set_Process_Order_String';
-- cursor determines if an attribute exists
  cursor csr_wiav is
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = 'PROCESS_ORDER_STRING' ;

--
begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  g_debug := hr_utility.debug_enabled;
-- fix for bug#2112623
 -- open the cursor to determine if the attribute exists
  open csr_wiav;
   hr_utility.trace('Going into Fetch after (open csr_wiav ): '|| l_proc);
  fetch csr_wiav into l_dummy;
  if csr_wiav%notfound then
    l_dummy := -1;
  end if;
  close csr_wiav;

if(l_dummy=-1) then
hr_utility.set_location('Leaving: '|| l_proc,10);
return ;
end if;
-- end of bug fix

--
   l_process_order_str := wf_engine.GetItemAttrText
                    (itemtype   => p_item_type,
                     itemkey    => p_item_key,
                     aname      =>'PROCESS_ORDER_STRING');

--
   if l_process_order_str is null then
        hr_utility.trace('In (if l_process_order_str is null then): '|| l_proc);
      l_process_order_str := '%'||to_char(p_actid)||'%1%';
      wf_engine.SetItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'PROCESS_ORDER_STRING',
                           avalue   => l_process_order_str );
   else
        hr_utility.trace('In else of (if l_process_order_str is null then): '|| l_proc);
      -- Following commented code is replaced by if(instr(l_process_order_str,p_actid)=0) code
      /*
	 while instr(l_process_order_str,'%', l_counter) <> 0 loop
      	 l_value := substr(l_process_order_str,
                                instr(l_process_order_str,'%', 1,l_counter-1) +1,
                                (instr(l_process_order_str,'%',1, l_counter) -
                                instr(l_process_order_str,'%',1, l_counter-1)) -1);
         if to_char(p_actid) <> l_value then
            l_counter := l_counter + 2;
      	 else
            exit;
         end if;
         end loop;
      */
      if(instr(l_process_order_str,p_actid) = 0)then
        --
        l_last_process_order := to_number(Get_Last_Process_Order(l_process_order_str))+1;
        l_value := l_process_order_str ||to_char(p_actid)||'%'||to_char(l_last_process_order)||'%';
        wf_engine.SetItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'PROCESS_ORDER_STRING',
                           avalue   => l_value );
        --
      end if;
    end if;
--
exception
  when others then
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     null;
--
end Set_Process_Order_String ;
--
/*----------------------------------------------------------------------
Get_Process_Order get the process order from the string stored in wf
attribute PROCESS_ORDER_STRING for the passed in activity
id.This string is constructed by Set_Process_Order_String.
-----------------------------------------------------------------------*/
------------------------------------------------------------------------
----------------------- Get_Process_Order-------------------------------
------------------------------------------------------------------------
function Get_Process_Order
  (p_item_type               in wf_items.item_type%type
  ,p_item_key                in wf_items.item_key%type
  ,p_actid                   in wf_activity_attr_values.process_activity_id%type)
return varchar2 is
--
l_value varchar2(100);
l_process_order varchar2(100);
l_process_order_str varchar2(4000);
l_counter number := 2;
l_dummy  number(1);
l_proc constant varchar2(100) := g_package || ' Get_Process_Order';
-- cursor determines if an attribute exists
  cursor csr_wiav is
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = 'PROCESS_ORDER_STRING' ;
--
begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  g_debug := hr_utility.debug_enabled;
-- fix for bug#2112623
 -- open the cursor to determine if the a
  open csr_wiav;
   hr_utility.trace('Going into Fetch after (open csr_wiav ): '|| l_proc);
  fetch csr_wiav into l_dummy;
  if csr_wiav%notfound then
    l_dummy := -1;
  end if;
  close csr_wiav;

if(l_dummy=-1) then
hr_utility.set_location('Leaving: '|| l_proc,20);
 return (null);
end if;
-- end of bug fix

    l_process_order_str := wf_engine.GetItemAttrText
                    (itemtype   => p_item_type,
                     itemkey    => p_item_key,
                     aname      =>'PROCESS_ORDER_STRING');
    --hr_utility.trace('Get Process Order--Process Order Str ' || l_process_order_str);
    if l_process_order_str is null then
    hr_utility.set_location('Leaving: '|| l_proc,25);
       return(null);
    else
       while instr(l_process_order_str,'%', l_counter) <> 0 loop
       l_value := substr(l_process_order_str,
                                instr(l_process_order_str,'%',1, l_counter-1) +1,
                                (instr(l_process_order_str,'%',1, l_counter) -
                                instr(l_process_order_str,'%',1, l_counter-1)) -1);
       --hr_utility.trace('Get Process Order--l_value ' || l_value);
       if to_char(p_actid) <> l_value then
         l_counter := l_counter + 2;
       else
         l_process_order := substr(l_process_order_str,
                                instr(l_process_order_str,'%',1, l_counter) +1,
                                (instr(l_process_order_str,'%',1, l_counter+1) -
                                instr(l_process_order_str,'%',1, l_counter)) -1);
         --hr_utility.trace('Get Process Order--Process Order  ' || l_process_order);
         hr_utility.set_location('Leaving: '|| l_proc,30);
         return(l_process_order);
       end if;
       end loop;
       hr_utility.set_location('Leaving: '|| l_proc,35);
       return(null);
     end if;
--
exception
  when others then

    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    hr_utility.set_message(800, 'HR_NO_PROCESS_ORDER');
    hr_utility.set_message_token('ACTID', p_actid);
    hr_utility.raise_error;
--
end Get_Process_Order ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_trans_step >------------------------|
-- ----------------------------------------------------------------------------
procedure create_trans_step
  (p_validate                     in      boolean  default false
  ,p_creator_person_id            in      number
  ,p_transaction_id               in      number
  ,p_api_name                     in      varchar2
  ,p_api_display_name             in      varchar2 default null
  ,p_item_type                    in      varchar2 default null
  ,p_item_key                     in      varchar2 default null
  ,p_activity_id                  in      number   default null
  ,p_processing_order             in      number   default null
  ,p_transaction_step_id             out nocopy  number
  ,p_object_version_number           out nocopy  number) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
l_proc constant varchar2(100) := g_package || ' create_trans_step';
  l_processing_order   number default null;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  --l_proc := g_package||'create_trans_step';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  -- verify that person has transaction privilege
  check_transaction_privilege
    (p_transaction_id => p_transaction_id
    ,p_person_id      => p_creator_person_id);
  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_trans_step;
  end if;
  if p_processing_order is null then
    l_processing_order :=  to_number(get_process_order
                                       (p_item_type => p_item_type
                                       ,p_item_key  => p_item_key
                                       ,p_actid => p_activity_id));
    if l_processing_order is null then
     l_processing_order := 0;
    end if;
  end if;
  -- call the row handler to insert the transaction
  hr_trs_ins.ins
    (p_validate              => false
    ,p_transaction_id        => p_transaction_id
    ,p_api_name              => p_api_name
    ,p_api_display_name      => p_api_display_name
    ,p_processing_order      => nvl(p_processing_order,l_processing_order)
    ,p_item_type             => p_item_type
    ,p_item_key              => p_item_key
    ,p_activity_id           => p_activity_id
    ,p_creator_person_id     => p_creator_person_id
    ,p_transaction_step_id   => p_transaction_step_id
    ,p_object_version_number => p_object_version_number);
  --
  -- when in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

exception
  when hr_api.validate_enabled then

    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_trans_step;
    -- set primary key to null
    p_transaction_step_id   := null;
    p_object_version_number := null;
end create_trans_step;
-- ----------------------------------------------------------------------------
-- |-----------------------< create_transaction_step >------------------------|
-- ----------------------------------------------------------------------------
procedure create_transaction_step
  (p_validate                     in      boolean  default false
  ,p_creator_person_id            in      number
  ,p_transaction_id               in      number
  ,p_api_name                     in      varchar2
  ,p_api_display_name             in      varchar2 default null
  ,p_item_type                    in      varchar2 default null
  ,p_item_key                     in      varchar2 default null
  ,p_activity_id                  in      number   default null
  ,p_transaction_step_id             out nocopy  number
  ,p_object_version_number           out nocopy  number) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
 l_proc constant varchar2(100) := g_package || ' create_transaction_step';
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'create_transaction_step';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  create_trans_step
    (p_validate              => false
    ,p_creator_person_id     => p_creator_person_id
    ,p_transaction_id        => p_transaction_id
    ,p_api_name              => p_api_name
    ,p_api_display_name      => p_api_display_name
    ,p_item_type             => p_item_type
    ,p_item_key              => p_item_key
    ,p_activity_id           => p_activity_id
    ,p_processing_order      => null
    ,p_transaction_step_id   => p_transaction_step_id
    ,p_object_version_number => p_object_version_number);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

end create_transaction_step;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_transaction_step >------------------------|
-- ----------------------------------------------------------------------------
procedure update_transaction_step
  (p_validate                     in      boolean  default false
  ,p_transaction_step_id          in      number
  ,p_update_person_id             in      number
  ,p_object_version_number        in out nocopy  number) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
l_proc constant varchar2(100) := g_package || ' update_transaction_step';
  --
  cursor csr_hatv is
    select hatv.transaction_value_id
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = p_transaction_step_id;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'update_transaction_step';
  hr_utility.set_location('Entering: '|| l_proc, 5);
END IF;

  -- verify that person has transaction privilege
  check_transaction_privilege
    (p_transaction_id => get_transaction_id
                           (p_transaction_step_id => p_transaction_step_id)
    ,p_person_id      => p_update_person_id);
  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint create_transaction_step;
  end if;
  -- call the row handler to update the transaction setp
  hr_trs_upd.upd
    (p_validate              => false
    ,p_transaction_step_id   => p_transaction_step_id
    ,p_update_person_id      => p_update_person_id
    ,p_object_version_number => p_object_version_number);
  --
  -- when in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

exception
  when hr_api.validate_enabled then
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_transaction_step;
    -- set primary key to null
    p_object_version_number := null;
end update_transaction_step;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_transaction_step >------------------------|
-- ----------------------------------------------------------------------------
procedure delete_transaction_step
  (p_validate                     in      boolean default false
  ,p_transaction_step_id          in      number
  ,p_person_id                    in      number
  ,p_object_version_number        in      number) is
  --
  l_proc constant varchar2(100) := g_package || ' delete_transaction_step';
begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  g_debug := hr_utility.debug_enabled;
  -- verify that person has transaction privilege
  check_transaction_privilege
    (p_transaction_id => get_transaction_id
                           (p_transaction_step_id => p_transaction_step_id)
    ,p_person_id      => p_person_id);
  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint delete_transaction_step;
  end if;
  -- lock the current transaction step
  hr_trs_shd.lck
    (p_transaction_step_id   => p_transaction_step_id
    ,p_object_version_number => p_object_version_number);
  --
  -- delete each transaction value
  -- Do this using direct SQL rather than in a loop using the row handler
  -- to improve performance.
  --
  delete from hr_api_transaction_values
   where transaction_step_id = p_transaction_step_id;
  -- delete the transaction step
  hr_trs_del.del
    (p_transaction_step_id   => p_transaction_step_id
    ,p_object_version_number => p_object_version_number);
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,10);
exception
  when hr_api.validate_enabled then
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_transaction_step;
end delete_transaction_step;
-- ----------------------------------------------------------------------------
-- |------------------------------< set_value >-------------------------------|
-- ----------------------------------------------------------------------------
procedure set_value
  (p_validate                   in     boolean  default false
  ,p_transaction_step_id        in     number
  ,p_person_id                  in     number
  ,p_datatype                   in     varchar2 default null
  ,p_name                       in     varchar2
  ,p_varchar2_value             in     varchar2 default null
  ,p_number_value               in     number   default null
  ,p_date_value                 in     date     default null
  ,p_original_varchar2_value    in     varchar2 default null  --ns
  ,p_original_number_value      in     number   default null  --ns
  ,p_original_date_value        in     date     default null  --ns
  ,p_transaction_value_id          out nocopy number) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' set_value';
  l_insert boolean := false;
  l_transaction_value_id hr_api_transaction_values.transaction_value_id%type;
  l_name                 hr_api_transaction_values.name%type;
  --
  l_current_value  varchar2(2000); --ns
  l_original_value varchar2(2000);
  --
  cursor csr_hatv is
    select hatv.transaction_value_id,
           varchar2_value || fnd_date.date_to_canonical(date_value) || number_value current_value, --ns
           original_varchar2_value || fnd_date.date_to_canonical(original_date_value) || original_number_value original_value
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = p_transaction_step_id
    and    hatv.name                = l_name;
  --
begin

IF g_debug THEN
--  l_proc := g_package||'set_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  -- upper the parameter name
  l_name := upper(p_name);
  -- verify that person has transaction privilege
  check_transaction_privilege
    (p_transaction_id  => get_transaction_id
                            (p_transaction_step_id => p_transaction_step_id)
    ,p_person_id       => p_person_id);
  -- determine if we are doing an insert or update
  open csr_hatv;
   hr_utility.trace('Going into Fetch after (open csr_hatv ): '|| l_proc);
  fetch csr_hatv into l_transaction_value_id,l_current_value,l_original_value;
  if csr_hatv%notfound then
    -- a row does exist so we must be trying to create a value
    l_insert := true;
  end if;
  close csr_hatv;
  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint set_value;
  end if;
  --
  if l_insert then
    -- call the row handler to insert the transaction value
    hr_trv_ins.ins
      (p_validate                => false
      ,p_transaction_value_id    => p_transaction_value_id
      ,p_transaction_step_id     => p_transaction_step_id
      ,p_datatype                => p_datatype
      ,p_name                    => l_name
      ,p_varchar2_value          => p_varchar2_value
      ,p_number_value            => p_number_value
      ,p_date_value              => p_date_value
      ,p_original_varchar2_value => p_original_varchar2_value   -- remove from RH API interface  --ns
      ,p_original_number_value   => p_original_number_value     -- remove from RH API interface  --ns
      ,p_original_date_value     => p_original_date_value);     -- remove from RH API interface  --ns
  else
    -- call the row handler to update the transaction value
    if ((NVL(p_varchar2_value||fnd_date.date_to_canonical(p_date_value)||p_number_value,'X') <> NVL(l_current_value,'X'))
    OR (NVL(p_original_varchar2_value||fnd_date.date_to_canonical(p_original_date_value)||p_original_number_value,'X') <> NVL(l_original_value,'X')))
    then
    g_update_flag := 'Y';
    hr_trv_upd.upd
      (p_validate                => false
      ,p_transaction_value_id    => l_transaction_value_id
      ,p_transaction_step_id     => hr_api.g_number    -- remove from RH API interface
      ,p_datatype                => hr_api.g_varchar2  -- remove from RH API interface
      ,p_name                    => hr_api.g_varchar2  -- remove from RH API interface
      ,p_varchar2_value          => p_varchar2_value
      ,p_number_value            => p_number_value
      ,p_date_value              => p_date_value
      ,p_original_varchar2_value => p_original_varchar2_value  -- remove from RH API interface --ns
      ,p_original_number_value   => p_original_number_value    -- remove from RH API interface --ns
      ,p_original_date_value     => p_original_date_value);    -- remove from RH API interface --ns
    end if;
  end if;
  --
  -- when in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

exception
  when hr_api.validate_enabled then

hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to set_transaction_value;
    -- set primary key to null
    p_transaction_value_id   := null;
end set_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< set_varchar2_value >-------------------------|
-- ----------------------------------------------------------------------------
procedure set_varchar2_value
  (p_validate                   in     boolean  default false
  ,p_transaction_step_id        in     number
  ,p_person_id                  in     number
  ,p_name                       in     varchar2
  ,p_value                      in     varchar2 default null
  ,p_original_value             in     varchar2 default null ) is --ns
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' set_varchar2_value';
  l_transaction_value_id hr_api_transaction_values.transaction_value_id%type;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'set_varchar2_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  set_value
    (p_validate                   => p_validate
    ,p_transaction_step_id        => p_transaction_step_id
    ,p_person_id                  => p_person_id
    ,p_datatype                   => 'VARCHAR2'
    ,p_name                       => p_name
    ,p_varchar2_value             => p_value
    ,p_original_varchar2_value    => p_original_value    --ns
    ,p_transaction_value_id       => l_transaction_value_id);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

end set_varchar2_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< set_number_value >---------------------------|
-- ----------------------------------------------------------------------------
procedure set_number_value
  (p_validate                   in     boolean  default false
  ,p_transaction_step_id        in     number
  ,p_person_id                  in     number
  ,p_name                       in     varchar2
  ,p_value                      in     number   default null
  ,p_original_value             in     number   default null ) is  --ns
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' set_number_value';
  l_transaction_value_id hr_api_transaction_values.transaction_value_id%type;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'set_number_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  set_value
    (p_validate                   => p_validate
    ,p_transaction_step_id        => p_transaction_step_id
    ,p_person_id                  => p_person_id
    ,p_datatype                   => 'NUMBER'
    ,p_name                       => p_name
    ,p_number_value               => p_value
    ,p_original_number_value      => p_original_value        --ns
    ,p_transaction_value_id       => l_transaction_value_id);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

end set_number_value;
-- ----------------------------------------------------------------------------
-- |-----------------------------< set_date_value >---------------------------|
-- ----------------------------------------------------------------------------
procedure set_date_value
  (p_validate                   in     boolean  default false
  ,p_transaction_step_id        in     number
  ,p_person_id                  in     number
  ,p_name                       in     varchar2
  ,p_value                      in     date     default null
  ,p_original_value             in     date     default null ) is   --ns
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' set_date_value';
  l_transaction_value_id hr_api_transaction_values.transaction_value_id%type;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'set_date_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  set_value
    (p_validate                   => p_validate
    ,p_transaction_step_id        => p_transaction_step_id
    ,p_person_id                  => p_person_id
    ,p_datatype                   => 'DATE'
    ,p_name                       => p_name
    ,p_date_value                 => trunc(p_value)
    ,p_original_date_value        => p_original_value          --ns
    ,p_transaction_value_id       => l_transaction_value_id);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

end set_date_value;
-- ----------------------------------------------------------------------------
-- |--------------------------< set_boolean_value >---------------------------|
-- ----------------------------------------------------------------------------
procedure set_boolean_value
  (p_validate                   in     boolean  default false
  ,p_transaction_step_id        in     number
  ,p_person_id                  in     number
  ,p_name                       in     varchar2
  ,p_value                      in     boolean  default null
  ,p_original_value             in     boolean  default null ) is    --ns
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' set_boolean_value';
  l_transaction_value_id hr_api_transaction_values.transaction_value_id%type;
  l_value                varchar2(30);
  l_original_value       varchar2(30);  --ns
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'set_boolean_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  -- derive the value
  if p_value then
    l_value := 'TRUE';
  elsif not p_value then
    l_value := 'FALSE';
  else
    l_value := null;
  end if;
  --
  --ns start
  if p_original_value then
    l_original_value := 'TRUE';
  elsif not p_original_value then
    l_original_value := 'FALSE';
  else
    l_original_value := null;
  end if;
  --ns end

  set_value
    (p_validate                   => p_validate
    ,p_transaction_step_id        => p_transaction_step_id
    ,p_person_id                  => p_person_id
    ,p_datatype                   => 'BOOLEAN'
    ,p_name                       => p_name
    ,p_varchar2_value             => l_value
    ,p_original_varchar2_value    => l_original_value  --ns
    ,p_transaction_value_id       => l_transaction_value_id);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

end set_boolean_value;
-- ----------------------------------------------------------------------------
-- |------------------------------< get_value >-------------------------------|
-- ----------------------------------------------------------------------------
procedure get_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2
  ,p_datatype                      out nocopy varchar2
  ,p_varchar2_value                out nocopy varchar2
  ,p_number_value                  out nocopy number
  ,p_date_value                    out nocopy date) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_value';
  l_insert boolean := false;
  l_name           hr_api_transaction_values.name%type;
  --
  cursor csr_hatv is
    select hatv.datatype
          ,hatv.varchar2_value
          ,hatv.number_value
          ,hatv.date_value
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = p_transaction_step_id
    and    hatv.name                = l_name;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  -- upper the parameter name
  l_name := upper(p_name);
  -- select the transaction value details
  open csr_hatv;
   hr_utility.trace('Going into Fetch after (open csr_hatv ): '|| l_proc);
  fetch csr_hatv
  into  p_datatype
       ,p_varchar2_value
       ,p_number_value
       ,p_date_value;
  close csr_hatv;
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 15);
END IF;

end get_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_varchar2_value >-------------------------|
-- ----------------------------------------------------------------------------
function get_varchar2_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return varchar2 is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_varchar2_value';
  l_datatype      hr_api_transaction_values.datatype%type;
  l_varchar2      hr_api_transaction_values.varchar2_value%type;
  l_number        hr_api_transaction_values.number_value%type;
  l_date          hr_api_transaction_values.date_value%type;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_varchar2_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  get_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => p_name
    ,p_datatype            => l_datatype
    ,p_varchar2_value      => l_varchar2
    ,p_number_value        => l_number
    ,p_date_value          => l_date);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

  return(l_varchar2);
end get_varchar2_value;
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_number_value >-------------------------|
-- ----------------------------------------------------------------------------
function get_number_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return number is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_number_value';
  l_datatype      hr_api_transaction_values.datatype%type;
  l_varchar2      hr_api_transaction_values.varchar2_value%type;
  l_number        hr_api_transaction_values.number_value%type;
  l_date          hr_api_transaction_values.date_value%type;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_number_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  get_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => p_name
    ,p_datatype            => l_datatype
    ,p_varchar2_value      => l_varchar2
    ,p_number_value        => l_number
    ,p_date_value          => l_date);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

  hr_utility.set_location(' Leaving:'||l_proc, 15);
  return(l_number);

end get_number_value;
-- ----------------------------------------------------------------------------
-- |-------------------------------< get_date_value >-------------------------|
-- ----------------------------------------------------------------------------
function get_date_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return date is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_date_value';
  l_datatype      hr_api_transaction_values.datatype%type;
  l_varchar2      hr_api_transaction_values.varchar2_value%type;
  l_number        hr_api_transaction_values.number_value%type;
  l_date          hr_api_transaction_values.date_value%type;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_date_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  get_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => p_name
    ,p_datatype            => l_datatype
    ,p_varchar2_value      => l_varchar2
    ,p_number_value        => l_number
    ,p_date_value          => l_date);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

  return(l_date);
end get_date_value;
--
-- 11/12/1997 Change Begins
-- ----------------------------------------------------------------------------
-- |--------------------------< get_date2char_value >-------------------------|
-- ----------------------------------------------------------------------------
function get_date2char_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2
  ,p_date_format               in      varchar2) return varchar2 is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_date2char_value';
  l_datatype      hr_api_transaction_values.datatype%type;
  l_varchar2      hr_api_transaction_values.varchar2_value%type;
  l_number        hr_api_transaction_values.number_value%type;
  l_date          hr_api_transaction_values.date_value%type;
  l_char_date     varchar2(200);
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_date2char_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  get_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => p_name
    ,p_datatype            => l_datatype
    ,p_varchar2_value      => l_varchar2
    ,p_number_value        => l_number
    ,p_date_value          => l_date);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;

  l_char_date := to_char(l_date, p_date_format);
    hr_utility.set_location(' Leaving:'||l_proc, 15);
  return(l_char_date);
  --
end get_date2char_value;
--
-- 11/12/1997 Change Ends
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_boolean_value >-------------------------|
-- ----------------------------------------------------------------------------
function get_boolean_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return boolean is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_boolean_value';
  l_datatype      hr_api_transaction_values.datatype%type;
  l_varchar2      hr_api_transaction_values.varchar2_value%type;
  l_number        hr_api_transaction_values.number_value%type;
  l_date          hr_api_transaction_values.date_value%type;
  l_boolean       boolean;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_boolean_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  get_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => p_name
    ,p_datatype            => l_datatype
    ,p_varchar2_value      => l_varchar2
    ,p_number_value        => l_number
    ,p_date_value          => l_date);
  --
  if l_varchar2 = 'TRUE' then
    l_boolean := true;
  elsif l_varchar2 = 'FALSE' then
    l_boolean := false;
  else
    l_boolean := null;
  end if;

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  return(l_boolean);
end get_boolean_value;
-- ----------------------------------------------------------------------------
-- |---------------------< get_original_value >-------------------------------|
-- ----------------------------------------------------------------------------
procedure get_original_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2
  ,p_datatype                      out nocopy varchar2
  ,p_original_varchar2_value       out nocopy varchar2
  ,p_original_number_value         out nocopy number
  ,p_original_date_value           out nocopy date) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_original_value';
  l_insert boolean := false;
  l_name           hr_api_transaction_values.name%type;
  --
  cursor csr_hatv is
    select hatv.datatype
          ,hatv.original_varchar2_value
          ,hatv.original_number_value
          ,hatv.original_date_value
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = p_transaction_step_id
    and    hatv.name                = l_name;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_original_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  -- upper the parameter name
  l_name := upper(p_name);
  -- select the transaction value details
  open csr_hatv;
   hr_utility.trace('Going into Fetch after (open csr_hatv ): '|| l_proc);
  fetch csr_hatv
  into  p_datatype
       ,p_original_varchar2_value
       ,p_original_number_value
       ,p_original_date_value;
  if csr_hatv%notfound then
    -- parameter does not exist
    close csr_hatv;
    hr_utility.set_message(801, 'HR_51751_WEB_TRA_STEP_EXISTS');
    hr_utility.raise_error;
  end if;
  close csr_hatv;
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 15);
END IF;

end get_original_value;
-- ----------------------------------------------------------------------------
-- |------------------< get_original_varchar2_value >-------------------------|
-- ----------------------------------------------------------------------------
function get_original_varchar2_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return varchar2 is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_original_varchar2_value';
  l_datatype      hr_api_transaction_values.datatype%type;
  l_varchar2      hr_api_transaction_values.varchar2_value%type;
  l_number        hr_api_transaction_values.number_value%type;
  l_date          hr_api_transaction_values.date_value%type;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_original_varchar2_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  get_original_value
    (p_transaction_step_id     => p_transaction_step_id
    ,p_name                    => p_name
    ,p_datatype                => l_datatype
    ,p_original_varchar2_value => l_varchar2
    ,p_original_number_value   => l_number
    ,p_original_date_value     => l_date);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  return(l_varchar2);
end get_original_varchar2_value;
-- ----------------------------------------------------------------------------
-- |--------------------< get_original_number_value >-------------------------|
-- ----------------------------------------------------------------------------
function get_original_number_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return number is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_original_number_value';
  l_datatype      hr_api_transaction_values.datatype%type;
  l_varchar2      hr_api_transaction_values.varchar2_value%type;
  l_number        hr_api_transaction_values.number_value%type;
  l_date          hr_api_transaction_values.date_value%type;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_original_number_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  get_original_value
    (p_transaction_step_id     => p_transaction_step_id
    ,p_name                    => p_name
    ,p_datatype                => l_datatype
    ,p_original_varchar2_value => l_varchar2
    ,p_original_number_value   => l_number
    ,p_original_date_value     => l_date);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  return(l_number);
end get_original_number_value;
-- ----------------------------------------------------------------------------
-- |----------------------< get_original_date_value >-------------------------|
-- ----------------------------------------------------------------------------
function get_original_date_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return date is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_original_date_value';
  l_datatype      hr_api_transaction_values.datatype%type;
  l_varchar2      hr_api_transaction_values.varchar2_value%type;
  l_number        hr_api_transaction_values.number_value%type;
  l_date          hr_api_transaction_values.date_value%type;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_original_date_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  get_original_value
    (p_transaction_step_id     => p_transaction_step_id
    ,p_name                    => p_name
    ,p_datatype                => l_datatype
    ,p_original_varchar2_value => l_varchar2
    ,p_original_number_value   => l_number
    ,p_original_date_value     => l_date);
  --

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  return(l_date);
end get_original_date_value;
-- ----------------------------------------------------------------------------
-- |----------------< get_original_boolean_value >----------------------------|
-- ----------------------------------------------------------------------------
function get_original_boolean_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return boolean is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc constant varchar2(100) := g_package || ' get_original_boolean_value';
  l_datatype      hr_api_transaction_values.datatype%type;
  l_varchar2      hr_api_transaction_values.varchar2_value%type;
  l_number        hr_api_transaction_values.number_value%type;
  l_date          hr_api_transaction_values.date_value%type;
  l_boolean       boolean;
  --
begin
  g_debug := hr_utility.debug_enabled;

IF g_debug THEN
--  l_proc := g_package||'get_original_boolean_value';
  hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;

  --
  get_original_value
    (p_transaction_step_id      => p_transaction_step_id
    ,p_name                     => p_name
    ,p_datatype                 => l_datatype
    ,p_original_varchar2_value  => l_varchar2
    ,p_original_number_value    => l_number
    ,p_original_date_value      => l_date);
  --
  if l_varchar2 = 'TRUE' then
    l_boolean := true;
  elsif l_varchar2 = 'FALSE' then
    l_boolean := false;
  else
    l_boolean := null;
  end if;

IF g_debug THEN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  return(l_boolean);
end get_original_boolean_value;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< finalize_transaction >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure finalize_transaction (
     P_TRANSACTION_ID IN NUMBER
    ,P_EVENT IN VARCHAR2
    ,P_RETURN_STATUS OUT NOCOPY VARCHAR2
  )
is
  l_apiName Varchar2(100);
  l_sqlbuf  Varchar2(1000);
Begin

  l_apiName := hr_xml_util.get_node_value(
          	p_transaction_id => P_TRANSACTION_ID
               ,p_desired_node_value => 'TxnFinalizeApi'
               ,p_xpath  => 'Transaction/TransCtx');

  If l_apiName is not null Then
    l_sqlbuf:= 'BEGIN ' || l_apiName
                 || ' (P_TRANSACTION_ID => :1 '
                 || ' ,P_EVENT => :2 '
                 || ' ,P_RETURN_STATUS =>  :3 ); END; ';
    EXECUTE IMMEDIATE l_sqlbuf using in P_TRANSACTION_ID, in P_EVENT, out P_RETURN_STATUS;
  End If;
End finalize_transaction;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< rollback_transaction >----------------------|
-- ----------------------------------------------------------------------------
procedure rollback_transaction
  (p_transaction_id in number
  ,p_validate       in boolean default false) is
  -- cursor to select all transaction values for a transaction
  cursor csr_trv(c_transaction_step_id number) is
    select trv.transaction_value_id
    from   hr_api_transaction_values trv
    where  trv.transaction_step_id = c_transaction_step_id;
  -- cursor to select all transaction steps for a transaction
  cursor csr_trs is
    select trs.transaction_step_id
          ,trs.object_version_number
    from   hr_api_transaction_steps  trs
    where  trs.transaction_id = p_transaction_id;
  --
   cursor csr_hist is
   select action
   from pqh_ss_approval_history
   where transaction_history_id=p_transaction_id
   order by last_update_date desc;

  --
  l_proc constant varchar2(100) := g_package || ' rollback_transaction';
  l_return_status varchar2(10);
  lv_status pqh_ss_approval_history.action%type;

begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  g_debug := hr_utility.debug_enabled;
  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint rollback_transaction;
  end if;

 -- block for the module call back on transaction deletion
  BEGIN
   lv_status := 'NONE';

   For I in csr_hist Loop
    lv_status := I.action;
    Exit;
   End Loop;

   finalize_transaction (
     P_TRANSACTION_ID => p_transaction_id
    ,P_EVENT => lv_status  -- Add code here to pass the Event.
    ,P_RETURN_STATUS => l_return_status
   );
   exception when others then
	null;
  END;

  -- lock the transaction
  hr_trn_shd.lck
    (p_transaction_id => p_transaction_id);
  -- delete all transaction steps and values
  hr_utility.trace('Going into (for csr1 in csr_trs loop): '|| l_proc);
  for csr1 in csr_trs loop
    -- lock the transaction step
    hr_trs_shd.lck
      (p_transaction_step_id   => csr1.transaction_step_id
      ,p_object_version_number => csr1.object_version_number);
    -- select and delete each transaction value
    for csr2 in csr_trv(csr1.transaction_step_id) loop
      -- delete all transaction values
      hr_trv_del.del
        (p_transaction_value_id => csr2.transaction_value_id);
    end loop;
    -- delete transaction step
    hr_trs_del.del
      (p_transaction_step_id   => csr1.transaction_step_id
      ,p_object_version_number => csr1.object_version_number);
  end loop;
    hr_utility.trace('Out of  (for csr1 in csr_trs loop): '|| l_proc);
  -- delete transaction
  hr_trn_del.del
    (p_transaction_id   => p_transaction_id);
  --
  --delete per_pay_transactions
  delete from per_pay_transactions
  where transaction_id = p_transaction_id;
  -- delete from ben_icd_transaction
  delete from ben_icd_transaction where transaction_id = p_transaction_id and status <> 'SP';
  -- when in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
--
exception
  when hr_api.validate_enabled then
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to rollback_transaction;
end rollback_transaction;
--
end hr_transaction_api;

/
