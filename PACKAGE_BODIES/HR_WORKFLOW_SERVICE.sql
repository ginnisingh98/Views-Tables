--------------------------------------------------------
--  DDL for Package Body HR_WORKFLOW_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WORKFLOW_SERVICE" as
/* $Header: hrwfserv.pkb 120.7.12010000.4 2009/03/30 06:35:44 pthoonig ship $ */
--
-- Package Variables
--
-- ---------------------------------------------------------------------------
-- private package global declarations
-- ---------------------------------------------------------------------------
  g_package     VARCHAR2(31)   := 'hr_workflow_service.';
--
-- Private Package Procedures/Functions
--
-- ---------------------------------------------------------------------------
-- Private Package Procedures/Functions Declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |-------------------------< item_attribute_exists >------------------------|
-- ----------------------------------------------------------------------------
function item_attribute_exists
  (p_item_type in wf_items.item_type%type
  ,p_item_key  in wf_items.item_key%type
  ,p_name      in wf_item_attribute_values.name%type)
  return boolean is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_dummy  number(1);
  l_return boolean := TRUE;
  -- cursor determines if an attribute exists
  cursor csr_wiav is
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = p_name;
  --
begin
  -- open the cursor
  open csr_wiav;
  fetch csr_wiav into l_dummy;
  if csr_wiav%notfound then
    -- item attribute does not exist so return false
    l_return := FALSE;
  end if;
  close csr_wiav;
  return(l_return);
end item_attribute_exists;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_usernm_exists_subj_aprv >---------------------|
-- ----------------------------------------------------------------------------
-- Bug #788954 Fix: This procedure is used in workflow Approved Process.  This
--                  function is invoked to check that if the subject-of-approval
--                  person has an apps login username.  If not, then workflow
--                  will not send out a notification to the subject person.
-- ----------------------------------------------------------------------------
PROCEDURE check_usernm_exists_subj_aprv
  (itemtype     IN VARCHAR2
  ,itemkey      IN VARCHAR2
  ,actid        IN NUMBER
  ,funcmode     IN VARCHAR2
  ,resultout    OUT NOCOPY VARCHAR2)
IS
  --
  l_current_person_username        VARCHAR2(2000) default null;
  --
BEGIN
  IF funcmode = 'RUN' THEN
     l_current_person_username :=  wf_engine.GetItemAttrText
                        (itemtype => itemtype
                        ,itemkey  => itemkey
                        ,aname    => 'CURRENT_PERSON_USERNAME');
     --
  ELSIF  funcmode = 'CANCEL' THEN
    null;
  END IF;
  --
  IF l_current_person_username is null THEN
     resultout := 'COMPLETE:'|| 'N'; --no display name found for current person
  ELSE
     resultout := 'COMPLETE:'|| 'Y'; -- display name found for current person
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('HR_UTILITY_WORKFLOW'
                   ,'CHECK_USERNM_EXISTS_SUBJ_APRV'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);
    RAISE;
END check_usernm_exists_subj_aprv;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_activity_name >-----------------------------|
-- ----------------------------------------------------------------------------
procedure get_activity_name
  (p_item_type         in      wf_items.item_type%type
  ,p_item_key          in      wf_items.item_key%type
  ,p_actid             in      number
  ,p_activity_name         out nocopy varchar2
  ,p_activity_display_name out nocopy varchar2) is
--
  cursor l_csr is
--BUG 3636429
    SELECT distinct activity_name,activity_display_name
    FROM
     (
     SELECT a.name activity_name,
            a.display_name activity_display_name
     FROM  wf_activities_vl a
          ,wf_item_activity_statuses ias
          ,wf_process_activities pa
     WHERE ias.item_type = p_item_type
       AND ias.item_key = p_item_key
       AND ias.process_activity = p_actid
       AND ias.process_activity = pa.instance_id
       AND pa.activity_name = a.name
       AND pa.activity_item_type = a.item_type
     UNION ALL
     SELECT a.name activity_name,
            a.display_name activity_display_name
     FROM  wf_activities_vl a
          ,wf_item_activity_statuses_h iash
          ,wf_process_activities pa
     WHERE iash.item_type = p_item_type
       AND iash.item_key = p_item_key
       AND iash.process_activity = p_actid
       AND iash.process_activity = pa.instance_id
       AND pa.activity_name = a.name
       AND pa.activity_item_type = a.item_type
     );
--
begin
  open l_csr;
  fetch l_csr into p_activity_name, p_activity_display_name;
  if l_csr%notfound then
    p_activity_name := null;
    p_activity_display_name := null;
  end if;
  close l_csr;
end get_activity_name;
-- ----------------------------------------------------------------------------
-- |------------------------< create_hr_directory_services >------------------|
-- ----------------------------------------------------------------------------
procedure create_hr_directory_services
  (p_item_type         in wf_items.item_type%type
  ,p_item_key          in wf_items.item_key%type
  ,p_service_name      in varchar2
  ,p_service_person_id in per_all_people_f.person_id%type) is
--
  l_item_type_attribute_name varchar2(30);
  type l_suffix_tab is table of varchar2(30) index by binary_integer;
  l_suffix       l_suffix_tab;
  l_username     wf_users.name%type;
  l_display_name wf_users.display_name%type;
--
begin
  if p_service_person_id is not null then
    l_suffix(1) := 'ID';
    l_suffix(2) := 'USERNAME';
    l_suffix(3) := 'DISPLAY_NAME';
    -- get the USERNAME and DISPLAY_NAME from workflow
    begin
      wf_directory.getusername
        (p_orig_system      => 'PER'
        ,p_orig_system_id   => p_service_person_id
        ,p_name             => l_username
        ,p_display_name     => l_display_name);
    exception
      when others then
        null;
    end;
    for i in 1..3 loop
      l_item_type_attribute_name := p_service_name||'_'||l_suffix(i);
       -- check to see if the item attribute has been created
      if not item_attribute_exists
        (p_item_type => p_item_type
        ,p_item_key  => p_item_key
        ,p_name      => l_item_type_attribute_name) then
        -- the item attribute does not exist so create it
        wf_engine.additemattr
          (itemtype => p_item_type
          ,itemkey  => p_item_key
          ,aname    => l_item_type_attribute_name);
      end if;
      -- set the item attribue value
      if i = 1 then
        -- set the ID value
        wf_engine.setitemattrnumber
         (itemtype => p_item_type
         ,itemkey  => p_item_key
         ,aname    => l_item_type_attribute_name
         ,avalue   => p_service_person_id);
      elsif i = 2 then
        -- set the USERNAME value
        wf_engine.setitemattrtext
          (itemtype => p_item_type
          ,itemkey  => p_item_key
          ,aname    => l_item_type_attribute_name
          ,avalue   => l_username);
      else
        -- set the DISPLAY_NAME value
        wf_engine.setitemattrtext
          (itemtype => p_item_type
          ,itemkey  => p_item_key
          ,aname    => l_item_type_attribute_name
          ,avalue   => l_display_name);
      end if;
    end loop;
  end if;
end create_hr_directory_services;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_item_attr_expanded_info >------------------|
-- ----------------------------------------------------------------------------
procedure get_item_attr_expanded_info
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_name      in       wf_item_attributes.name%type
  ,p_exists         out nocopy boolean
  ,p_subtype        out nocopy wf_item_attributes.subtype%type
  ,p_type           out nocopy wf_item_attributes.type%type
  ,p_format         out nocopy wf_item_attributes.format%type
  ,p_date_value     out nocopy wf_item_attribute_values.date_value%type
  ,p_number_value   out nocopy wf_item_attribute_values.number_value%type
  ,p_text_value     out nocopy wf_item_attribute_values.text_value%type) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_type           wf_item_attributes.type%type;
  l_name           wf_item_attributes.name%type := upper(p_name);
  --
begin
  -- initialise the OUT parameters
  p_exists       := true;
  p_subtype      := null;
  p_type         := null;
  p_format       := null;
  p_date_value   := null;
  p_number_value := null;
  p_text_value   := null;
  -- get the item attribute information
  wf_engine.GetItemAttrInfo
    (itemtype  => p_item_type
    ,aname     => l_name
    ,atype     => l_type
    ,subtype   => p_subtype
    ,format    => p_format);
  --
  p_type := l_type;
  -- branch on the type
  if l_type = 'NUMBER' then
    p_number_value :=
      wf_engine.GetItemAttrNumber
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => l_name);
  elsif l_type = 'DATE' then
    p_date_value :=
      wf_engine.GetItemAttrDate
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => l_name);
  else
    p_text_value :=
      wf_engine.GetItemAttrText
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => l_name);
  end if;
exception
  -- an error has occurred because the item attribute does not exists
  -- reset all of the OUT parameters ensuring
  when others then
    p_exists := false;
    p_subtype      := null;
    p_type         := null;
    p_format       := null;
    p_date_value   := null;
    p_number_value := null;
    p_text_value   := null;
end get_item_attr_expanded_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_act_attr_expanded_info >------------------|
-- ----------------------------------------------------------------------------
procedure get_act_attr_expanded_info
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_actid     in       wf_activity_attr_values.process_activity_id%type
  ,p_name      in       wf_activity_attributes.name%type
  ,p_exists         out nocopy boolean
  ,p_subtype        out nocopy wf_activity_attributes.subtype%type
  ,p_type           out nocopy wf_activity_attributes.type%type
  ,p_format         out nocopy wf_activity_attributes.format%type
  ,p_date_value     out nocopy wf_activity_attr_values.date_value%type
  ,p_number_value   out nocopy wf_activity_attr_values.number_value%type
  ,p_text_value     out nocopy wf_activity_attr_values.text_value%type) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_type           wf_activity_attributes.type%type;
  l_name           wf_activity_attributes.name%type := upper(p_name);
  --
begin
  -- initialise the OUT parameters
  p_exists       := true;
  p_subtype      := null;
  p_type         := null;
  p_format       := null;
  p_date_value   := null;
  p_number_value := null;
  p_text_value   := null;
  -- get the item attribute information
  wf_engine.GetActivityAttrInfo
    (itemtype  => p_item_type
    ,itemkey   => p_item_key
    ,actid     => p_actid
    ,aname     => l_name
    ,atype     => l_type
    ,subtype   => p_subtype
    ,format    => p_format);
  --
  p_type := l_type;
  -- branch on the type
  if l_type = 'NUMBER' then
    p_number_value :=
      wf_engine.GetActivityAttrNumber
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,actid    => p_actid
        ,aname    => l_name);
  elsif l_type = 'DATE' then
    p_date_value :=
      wf_engine.GetActivityAttrDate
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,actid    => p_actid
        ,aname    => l_name);
  else
    p_text_value :=
      wf_engine.GetActivityAttrText
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,actid    => p_actid
        ,aname    => l_name);
  end if;
exception
  -- an error has occurred because the item attribute does not exists
  -- reset all of the OUT parameters ensuring
  when others then
    p_exists := false;
    p_subtype      := null;
    p_type         := null;
    p_format       := null;
    p_date_value   := null;
    p_number_value := null;
    p_text_value   := null;
end get_act_attr_expanded_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_activity_type_attrs >--------------------|
-- ----------------------------------------------------------------------------
procedure check_activity_type_attrs
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_actid     in wf_activity_attr_values.process_activity_id%type) is
  --
  l_exists                boolean;
  l_subtype               wf_activity_attributes.subtype%type;
  l_type                  wf_activity_attributes.type%type;
  l_format                wf_activity_attributes.format%type;
  l_date_value            wf_activity_attr_values.date_value%type;
  l_number_value          wf_activity_attr_values.number_value%type;
  l_text_value            wf_activity_attr_values.text_value%type;
  l_activity_name         wf_item_activity_statuses_v.activity_name%type;
  l_activity_display_name wf_item_activity_statuses_v.activity_display_name%type;
  --
begin
  -- check to see if the HR_ACTIVITY_TYPE activity attribute exists
  get_act_attr_expanded_info
    (p_item_type     => p_item_type
    ,p_item_key      => p_item_key
    ,p_actid         => p_actid
    ,p_name          => g_hr_activity_type
    ,p_exists        => l_exists
    ,p_subtype       => l_subtype
    ,p_type          => l_type
    ,p_format        => l_format
    ,p_date_value    => l_date_value
    ,p_number_value  => l_number_value
    ,p_text_value    => l_text_value);
  --
  if NOT l_exists then
    -- supply HR error message, HR_ACTIVITY_TYPE does not exist
    hr_utility.set_message(800,'HR_52468_NO_ACTIVITY_ATTR');
    hr_utility.set_message_token('ACTIVITY_ATTRIBUTE', g_hr_activity_type);
    -- get the activity name
    get_activity_name
      (p_item_type             => p_item_type
      ,p_item_key              => p_item_key
      ,p_actid                 => p_actid
      ,p_activity_name         => l_activity_name
      ,p_activity_display_name => l_activity_display_name);
    hr_utility.set_message_token('ACTIVITY_NAME', l_activity_display_name);
    hr_utility.set_message_token('ITEM_TYPE', p_item_type);
    hr_utility.raise_error;
  end if;
  -- check to see if the HR_ACTIVITY_TYPE is NULL
  -- note: we are assuming that the value must be of text type
  if l_text_value is NULL then
    -- supply HR error message, HR_ACTIVITY_TYPE cannot be NULL
    hr_utility.set_message(800,'HR_52469_ACTIVITY_ATTR_NULL');
    hr_utility.set_message_token('ACTIVITY_ATTRIBUTE', g_hr_activity_type);
    -- get the activity name
    get_activity_name
      (p_item_type             => p_item_type
      ,p_item_key              => p_item_key
      ,p_actid                 => p_actid
      ,p_activity_name         => l_activity_name
      ,p_activity_display_name => l_activity_display_name);
    hr_utility.set_message_token('ACTIVITY_NAME', l_activity_display_name);
    hr_utility.set_message_token('ITEM_TYPE', p_item_type);
    hr_utility.raise_error;
  end if;
  -- check to see if the HR_ACTIVITY_TYPE_VALUE activity attribute exists
  get_act_attr_expanded_info
    (p_item_type     => p_item_type
    ,p_item_key      => p_item_key
    ,p_actid         => p_actid
    ,p_name          => g_hr_activity_type_value
    ,p_exists        => l_exists
    ,p_subtype       => l_subtype
    ,p_type          => l_type
    ,p_format        => l_format
    ,p_date_value    => l_date_value
    ,p_number_value  => l_number_value
    ,p_text_value    => l_text_value);
  --
  if NOT l_exists then
    -- supply HR error message
    -- supply HR error message, HR_ACTIVITY_TYPE does not exist
    hr_utility.set_message(800,'HR_52468_NO_ACTIVITY_ATTR');
    hr_utility.set_message_token('ACTIVITY_ATTRIBUTE', g_hr_activity_type_value);
    -- get the activity name
    get_activity_name
      (p_item_type             => p_item_type
      ,p_item_key              => p_item_key
      ,p_actid                 => p_actid
      ,p_activity_name         => l_activity_name
      ,p_activity_display_name => l_activity_display_name);
    hr_utility.set_message_token('ACTIVITY_NAME', l_activity_display_name);
    hr_utility.set_message_token('ITEM_TYPE', p_item_type);
    hr_utility.raise_error;
  end if;
  -- check to see if the HR_ACTIVITY_TYPE_VALUE is NULL
  -- note: we are assuming that the value must be of text type
  if l_text_value is NULL then
    -- supply HR error message, HR_ACTIVITY_TYPE_VALUE cannot be NULL
    hr_utility.set_message(800,'HR_52469_ACTIVITY_ATTR_NULL');
    hr_utility.set_message_token('ACTIVITY_ATTRIBUTE', g_hr_activity_type_value);
    -- get the activity name
    get_activity_name
      (p_item_type             => p_item_type
      ,p_item_key              => p_item_key
      ,p_actid                 => p_actid
      ,p_activity_name         => l_activity_name
      ,p_activity_display_name => l_activity_display_name);
    hr_utility.set_message_token('ACTIVITY_NAME', l_activity_display_name);
    hr_utility.set_message_token('ITEM_TYPE', p_item_type);
    hr_utility.raise_error;
  end if;
end check_activity_type_attrs;
-- ----------------------------------------------------------------------------
-- |-----------------------------< hr_web_page >------------------------------|
-- ----------------------------------------------------------------------------
procedure hr_web_page
  (itemtype   in     varchar2
  ,itemkey    in     varchar2
  ,actid      in     number
  ,funcmode   in     varchar2
  ,resultout     out nocopy varchar2) is
--
begin
  if funcmode = 'RUN' then
    -- check to ensure the HR_ACTIVITY_TYPE/VALUE activity attributes exist
    check_activity_type_attrs
      (p_item_type => itemtype
      ,p_item_key  => itemkey
      ,p_actid     => actid);
    -- set the result to NOTIFIED: to stall the workflow engine
    resultout := 'NOTIFIED:';
    return;
  end if;
  if funcmode = 'CANCEL' then
    resultout := 'COMPLETE:';
    return;
  end if;
exception
  when others then
    wf_core.Context
      (g_package, 'hr_web_page', itemtype, itemkey, to_char(actid), funcmode);
    raise;
end hr_web_page;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_hr_window_title >------------------------|
-- ----------------------------------------------------------------------------
function check_hr_window_title
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_actid     in       wf_activity_attr_values.process_activity_id%type)
  return boolean is
  --
  l_exists        boolean;
  l_subtype       wf_activity_attributes.subtype%type;
  l_type          wf_activity_attributes.type%type;
  l_format        wf_activity_attributes.format%type;
  l_date_value    wf_activity_attr_values.date_value%type;
  l_number_value  wf_activity_attr_values.number_value%type;
  l_text_value    wf_activity_attr_values.text_value%type;
  --
begin
  -- check to see if the WINDOW_TITLE activity attribute exists
  get_act_attr_expanded_info
    (p_item_type     => p_item_type
    ,p_item_key      => p_item_key
    ,p_actid         => p_actid
    ,p_name          => g_window_title
    ,p_exists        => l_exists
    ,p_subtype       => l_subtype
    ,p_type          => l_type
    ,p_format        => l_format
    ,p_date_value    => l_date_value
    ,p_number_value  => l_number_value
    ,p_text_value    => l_text_value);
  --
  return(l_exists);
end check_hr_window_title;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_hr_window_title >------------------------|
-- ----------------------------------------------------------------------------
function get_hr_window_title
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_actid     in wf_activity_attr_values.process_activity_id%type)
  return varchar2 is
  --
  l_exists        boolean;
  l_subtype       wf_activity_attributes.subtype%type;
  l_type          wf_activity_attributes.type%type;
  l_format        wf_activity_attributes.format%type;
  l_date_value    wf_activity_attr_values.date_value%type;
  l_number_value  wf_activity_attr_values.number_value%type;
  l_text_value    wf_activity_attr_values.text_value%type;
  --
begin
  -- check to see if the WINDOW_TITLE activity attribute exists
  get_act_attr_expanded_info
    (p_item_type     => p_item_type
    ,p_item_key      => p_item_key
    ,p_actid         => p_actid
    ,p_name          => g_window_title
    ,p_exists        => l_exists
    ,p_subtype       => l_subtype
    ,p_type          => l_type
    ,p_format        => l_format
    ,p_date_value    => l_date_value
    ,p_number_value  => l_number_value
    ,p_text_value    => l_text_value);
  --
  if l_exists then
    return(l_text_value);
  else
    return(NULL);
  end if;
end get_hr_window_title;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_web_page_code >--------------------------|
-- ----------------------------------------------------------------------------
function check_web_page_code
  (p_item_type             in       wf_items.item_type%type
  ,p_item_key              in       wf_items.item_key%type
  ,p_actid                 in wf_activity_attr_values.process_activity_id%type
  ,p_web_page_section_code in wf_activity_attributes.name%type)
  return boolean is
  --
  l_exists        boolean;
  l_subtype       wf_activity_attributes.subtype%type;
  l_type          wf_activity_attributes.type%type;
  l_format        wf_activity_attributes.format%type;
  l_date_value    wf_activity_attr_values.date_value%type;
  l_number_value  wf_activity_attr_values.number_value%type;
  l_text_value    wf_activity_attr_values.text_value%type;
  --
begin
  -- check to see if the specified p_web_page_section_code activity
  -- attribute exists
  get_act_attr_expanded_info
    (p_item_type     => p_item_type
    ,p_item_key      => p_item_key
    ,p_actid         => p_actid
    ,p_name          => p_web_page_section_code
    ,p_exists        => l_exists
    ,p_subtype       => l_subtype
    ,p_type          => l_type
    ,p_format        => l_format
    ,p_date_value    => l_date_value
    ,p_number_value  => l_number_value
    ,p_text_value    => l_text_value);
  --
  if l_exists and l_text_value is not null then
    return(TRUE);
  else
    return(FALSE);
  end if;
end check_web_page_code;
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_web_page_code >------------------------|
-- ----------------------------------------------------------------------------
function get_web_page_code
  (p_item_type             in wf_items.item_type%type
  ,p_item_key              in wf_items.item_key%type
  ,p_actid                 in wf_activity_attr_values.process_activity_id%type
  ,p_web_page_section_code in wf_activity_attributes.name%type)
  return varchar2 is
  --
  l_exists        boolean;
  l_subtype       wf_activity_attributes.subtype%type;
  l_type          wf_activity_attributes.type%type;
  l_format        wf_activity_attributes.format%type;
  l_date_value    wf_activity_attr_values.date_value%type;
  l_number_value  wf_activity_attr_values.number_value%type;
  l_text_value    wf_activity_attr_values.text_value%type;
  --
begin
  -- get the p_web_page_section_code activity attribute details
  get_act_attr_expanded_info
    (p_item_type     => p_item_type
    ,p_item_key      => p_item_key
    ,p_actid         => p_actid
    ,p_name          => p_web_page_section_code
    ,p_exists        => l_exists
    ,p_subtype       => l_subtype
    ,p_type          => l_type
    ,p_format        => l_format
    ,p_date_value    => l_date_value
    ,p_number_value  => l_number_value
    ,p_text_value    => l_text_value);
  --
  if l_exists then
    return(l_text_value);
  else
    return(NULL);
  end if;
end get_web_page_code;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_act_reentry_value_info >-------------------|
-- ----------------------------------------------------------------------------
procedure get_act_reentry_value_info
  (p_item_type   in     wf_items.item_type%type
  ,p_item_key    in     wf_items.item_key%type
  ,p_actid       in     wf_activity_attr_values.process_activity_id%type
  ,p_exists         out nocopy boolean
  ,p_result_code    out nocopy wf_item_activity_statuses_v.activity_result_code%type) is
  --
  cursor l_csr_wiasv is
    select wiasv.activity_result_code
    from   wf_item_activity_statuses wiasv
    where  wiasv.process_activity = p_actid
    and    wiasv.item_type   = p_item_type
    and    wiasv.item_key    = p_item_key
    order by wiasv.end_date desc;

    /*select wiasv.activity_result_code
    from   wf_item_activity_statuses_v wiasv
    where  wiasv.activity_id = p_actid
    and    wiasv.item_type   = p_item_type
    and    wiasv.item_key    = p_item_key
    order by wiasv.activity_end_date desc;*/
  --
  l_counter integer := 0;
  --
begin
  for I in l_csr_wiasv loop
    -- increment the counter
    l_counter := l_counter + 1;
    -- get the current activity result code
    p_result_code := I.activity_result_code;
    if l_counter = 2 then
      -- exit the loop on the second iteration
      exit;
    end if;
  end loop;
  --
-- Changed July 08, 1998 vtakru
--  if l_counter <= 1 then
  if l_counter < 1 then
    --
    p_exists      := FALSE;
    p_result_code := NULL;
  else
    p_exists := TRUE;
  end if;
end get_act_reentry_value_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_activity_reentry >-----------------------|
-- ----------------------------------------------------------------------------
function check_activity_reentry
  (p_item_type   in     wf_items.item_type%type
  ,p_item_key    in     wf_items.item_key%type
  ,p_actid       in wf_activity_attr_values.process_activity_id%type)
  return boolean is
  --
  l_exists               boolean;
  l_activity_result_code wf_item_activity_statuses_v.activity_result_code%type;
  --
begin
  get_act_reentry_value_info
    (p_item_type   => p_item_type
    ,p_item_key    => p_item_key
    ,p_actid       => p_actid
    ,p_exists      => l_exists
    ,p_result_code => l_activity_result_code);
  return(l_exists);
end check_activity_reentry;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_activity_reentry_value >-------------------|
-- ----------------------------------------------------------------------------
function get_activity_reentry_value
  (p_item_type   in     wf_items.item_type%type
  ,p_item_key    in     wf_items.item_key%type
  ,p_actid       in     wf_activity_attr_values.process_activity_id%type)
  return wf_item_activity_statuses_v.activity_result_code%type is
  --
  l_exists               boolean;
  l_activity_result_code wf_item_activity_statuses_v.activity_result_code%type;
  --
begin
  get_act_reentry_value_info
    (p_item_type   => p_item_type
    ,p_item_key    => p_item_key
    ,p_actid       => p_actid
    ,p_exists      => l_exists
    ,p_result_code => l_activity_result_code);
  return(l_activity_result_code);
end get_activity_reentry_value;
-- ----------------------------------------------------------------------------
-- |--------------------< wf_get_runnable_process_name >----------------------|
-- ----------------------------------------------------------------------------
function wf_get_runnable_process_name
  (p_item_type    in wf_items.item_type%type
  ,p_process_name in wf_process_activities.process_name%type)
  return wf_runnable_processes_v.display_name%type is
  -- cursor determines is the specified process is runnable
  cursor csr_wrpv is
    select wrpv.display_name
    from   wf_runnable_processes_v wrpv
    where  wrpv.item_type    = p_item_type
    and    wrpv.process_name = p_process_name;
  --
  l_display_name wf_runnable_processes_v.display_name%type;
  --
begin
  -- Determine if the specified process is runnable
  open csr_wrpv;
  fetch csr_wrpv into l_display_name;
  if csr_wrpv%notfound then
    close csr_wrpv;
    return(NULL);
  end if;
  close csr_wrpv;
  return(l_display_name);
end wf_get_runnable_process_name;
-- ----------------------------------------------------------------------------
-- |-------------------------< wf_process_runnable >--------------------------|
-- ----------------------------------------------------------------------------
function wf_process_runnable
  (p_item_type    in wf_items.item_type%type
  ,p_process_name in wf_process_activities.process_name%type)
  return boolean is
  --
begin
  if wf_get_runnable_process_name
       (p_item_type    => p_item_type
       ,p_process_name => p_process_name) is NULL then
    return(FALSE);
  else
    return(TRUE);
  end if;
end wf_process_runnable;
-- ----------------------------------------------------------------------------
-- |------------------------------< create_process >--------------------------|
-- ----------------------------------------------------------------------------
procedure create_process
  (p_process_name            in wf_process_activities.process_name%type
  ,p_item_type               in wf_items.item_type%type
  ,p_person_id               in varchar2 default null
  ,p_called_from             in varchar2 default null
  ,p_item_attribute          in g_varchar2_tab_type
                                default g_varchar2_tab_default
  ,p_item_attribute_value    in g_varchar2_tab_type
                                default g_varchar2_tab_default
  ,p_number_of_attributes_in in number default 0) is
  --
  l_process_name wf_process_activities.process_name%type :=
          upper(p_process_name);

  l_item_type    wf_items.item_type%type := upper(p_item_type);
  l_item_key     wf_items.item_key%type;
  --
  l_creator_person_id    per_people_f.person_id%type;
  l_index                binary_integer;
  l_temp_item_attribute       varchar2(2000);
  l_temp_item_attribute_value varchar2(2000);
  --
  l_role_name varchar2(320);
  l_role_displayname varchar2(360);

  l_item_attribute       g_varchar2_tab_type := p_item_attribute;
  l_item_attribute_value g_varchar2_tab_type := p_item_attribute_value;
  l_number_of_attributes_in  number := p_number_of_attributes_in;

begin
  -- --------------------------------------------------------------------------
  -- Validate the session and get the person id
  -- --------------------------------------------------------------------------
  if p_person_id is not null then
    l_number_of_attributes_in := l_number_of_attributes_in + 1;
    l_item_attribute(l_number_of_attributes_in)       := 'P_PERSON_ID';
    l_item_attribute_value(l_number_of_attributes_in) := p_person_id;
    l_number_of_attributes_in := l_number_of_attributes_in + 1;
    l_item_attribute(l_number_of_attributes_in) := 'CURRENT_PERSON_ID';
    l_item_attribute_value(l_number_of_attributes_in) := p_person_id;
  end if;
  if p_called_from is not null then
    l_number_of_attributes_in := l_number_of_attributes_in + 1;
    l_item_attribute(l_number_of_attributes_in)       := 'P_CALLED_FROM';
    l_item_attribute_value(l_number_of_attributes_in) := p_called_from;
  end if;

  hr_util_misc_web.validate_session(p_person_id => l_creator_person_id);
  -- Determine if the specified process is runnable
  if NOT wf_process_runnable
           (p_item_type    => l_item_type
           ,p_process_name => l_process_name) then
    -- supply HR error message, p_process_name either does not exist or
    -- is NOT a runnable process
    hr_utility.set_message(800,'HR_52958_WKF2TSK_INC_PROCESS');
    hr_utility.set_message_token('ITEM_TYPE', l_item_type);
    hr_utility.set_message_token('PROCESS_NAME', l_process_name);
    hr_utility.raise_error;
  end if;
  -- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;
  -- Create the Workflow Process
  wf_engine.CreateProcess
    (itemtype => l_item_type
    ,itemkey  => l_item_key
    ,process  => l_process_name);
  --
  -- Create the standard set of item attributes
  -- CURRENT_PERSON_ID and CREATOR_PERSON_ID
  --
  create_hr_directory_services
    (p_item_type         => l_item_type
    ,p_item_key          => l_item_key
    ,p_service_name      => 'CREATOR_PERSON'
    ,p_service_person_id => l_creator_person_id);
  create_hr_directory_services
    (p_item_type         => l_item_type
    ,p_item_key          => l_item_key
    ,p_service_name      => 'CURRENT_PERSON'
    ,p_service_person_id => l_creator_person_id);
  -- check to see if the SESSION_ID attribute has been created
  if not item_attribute_exists
    (p_item_type => l_item_type
    ,p_item_key  => l_item_key
    ,p_name      => 'SESSION_ID') then
    -- the SESSION_ID does not exist so create it
    wf_engine.additemattr
      (itemtype => l_item_type
      ,itemkey  => l_item_key
      ,aname    => 'SESSION_ID');
  end if;
  -- set the SESSION_ID to the person who is creating the process
  wf_engine.setitemattrnumber
    (itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'SESSION_ID'
    ,avalue   => to_number(icx_sec.getID(icx_sec.PV_SESSION_ID)));
  -- check to see if the PROCESS_NAME attribute has been created
  if not item_attribute_exists
    (p_item_type => l_item_type
    ,p_item_key  => l_item_key
    ,p_name      => 'PROCESS_NAME') then
    -- the PROCESS_NAME does not exist so create it
    wf_engine.additemattr
      (itemtype => l_item_type
      ,itemkey  => l_item_key
      ,aname    => 'PROCESS_NAME');
  end if;
  -- set the PROCESS_NAME
  wf_engine.setitemattrtext
    (itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'PROCESS_NAME'
    ,avalue   => l_process_name);
  -- check to see if the PROCESS_DISPLAY_NAME attribute has been created
  if not item_attribute_exists
    (p_item_type => l_item_type
    ,p_item_key  => l_item_key
    ,p_name      => 'PROCESS_DISPLAY_NAME') then
    -- the PROCESS_DISPLAY_NAME does not exist so create it
    wf_engine.additemattr
      (itemtype => l_item_type
      ,itemkey  => l_item_key
      ,aname    => 'PROCESS_DISPLAY_NAME');
  end if;
  -- set the PROCESS_DISPLAY_NAME to the person who is creating the process
  wf_engine.setitemattrtext
    (itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'PROCESS_DISPLAY_NAME'
    ,avalue   => wf_get_runnable_process_name
                   (p_item_type    => l_item_type
                   ,p_process_name => l_process_name));
-- Fix for bug 2619178 begins
  if not item_attribute_exists
    (p_item_type => l_item_type
    ,p_item_key  => l_item_key
    ,p_name      => 'HR_EDA_MODE') then
    wf_engine.additemattr
    (itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'HR_EDA_MODE');
  end if;
  if p_person_id is null then
  -- comming from Employee SS
    wf_engine.setitemattrtext
    (itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'HR_EDA_MODE'
    ,avalue   => 'Y');
  else
  -- comming from Manager SS
    wf_engine.setitemattrtext
    (itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'HR_EDA_MODE'
    ,avalue   => 'N');
  end if;
  -- Fix for bug 2619178 ends.
  --
  -- Create Item Attributes for those passed in
  --
  l_index := 1;
  --
  WHILE l_index <= l_number_of_attributes_in LOOP
    begin
      -- upper the item attribute name
      -- if a NO_DATA_FOUND exception occurs, the exception is
      -- handled and the item is skipped
      l_temp_item_attribute       := upper(l_item_attribute(l_index));
      begin
        l_temp_item_attribute_value := l_item_attribute_value(l_index);
      exception
        when NO_DATA_FOUND then
          -- The array element at the index position has not been set
          -- handle the exception and set the value to NULL
          l_temp_item_attribute_value := NULL;
      end;
      if not item_attribute_exists
        (p_item_type => l_item_type
        ,p_item_key  => l_item_key
        ,p_name      => l_temp_item_attribute) then
        wf_engine.additemattr
          (itemtype  => l_item_type
          ,itemkey   => l_item_key
          ,aname     => l_temp_item_attribute);
      end if;
      --
      if (l_temp_item_attribute = 'CREATOR_PERSON_ID' or
          l_temp_item_attribute = 'CURRENT_PERSON_ID') then
        --
        create_hr_directory_services
         (p_item_type         => l_item_type
         ,p_item_key          => l_item_key
         ,p_service_name      => substr(l_temp_item_attribute,
                                        1, length(l_temp_item_attribute) - 3)
         ,p_service_person_id => nvl(l_temp_item_attribute_value,
                                     l_creator_person_id));
      else
        wf_engine.setitemattrtext
          (itemtype  => l_item_type
          ,itemkey   => l_item_key
          ,aname     => l_temp_item_attribute
          ,avalue    => l_temp_item_attribute_value);
      end if;
      l_index := l_index + 1;
    exception
      when NO_DATA_FOUND then
        -- The array element at the index position has not been set
        -- Ignore, but increment the counter and continue with the LOOP
        l_index := l_index + 1;
    end;
  END LOOP;

  -- ---------------------------------
  -- Get the Role for the Owner
  -- ---------------------------------
  wf_directory.getRoleName
  (p_orig_system => 'PER'
  ,p_orig_system_id => l_creator_person_id
  ,p_name => l_role_name
  ,p_display_name => l_role_displayname);

  IF l_role_name = '' OR l_role_name IS NULL THEN
    RAISE g_invalid_responsibility;
  END IF;
  -- ---------------------------------------------------
  -- Set the Item Owner (Fix for Bug # 758351)
  -- ---------------------------------------------------
  wf_engine.setItemOwner
  (itemtype => l_item_type
  ,itemkey => l_item_key
  ,owner => l_role_name);

-- check if the attribute exists if not create

 if not item_attribute_exists
        (p_item_type => l_item_type
        ,p_item_key  => l_item_key
        ,p_name      => 'CURRENT_EFFECTIVE_DATE') then
        wf_engine.additemattr
          (itemtype  => l_item_type
          ,itemkey   => l_item_key
          ,aname     => 'CURRENT_EFFECTIVE_DATE');
      end if;

 -- set the item attribute for effective date
  --CURRENT_EFFECTIVE_DATE
  wf_engine.setitemattrdate
          (itemtype  => l_item_type
          ,itemkey   => l_item_key
          ,aname     => 'CURRENT_EFFECTIVE_DATE'
          ,avalue    => trunc(sysdate));


  -- Start the WF runtime process
   wf_engine.startprocess
    (itemtype => l_item_type
    ,itemkey  => l_item_key);
  -- Continue the process
    continue_process
    (p_item_type => l_item_type
    ,p_item_key  => l_item_key);
  --
  EXCEPTION
  WHEN g_invalid_responsibility THEN
	fnd_message.set_name('PER','HR_SSA_INVALID_RESPONSIBILITY');
	icx_util.add_error(fnd_message.get);
	icx_admin_sig.error_screen('HRSSA');
end create_process;
-- ----------------------------------------------------------------------------
-- |------------------------------< display_html >----------------------------|
-- ----------------------------------------------------------------------------
procedure display_html
  (p_procedure_name  in varchar2
  ,p_item_type       in wf_items.item_type%type
  ,p_item_key        in wf_items.item_key%type
  ,p_actid           in wf_activity_attr_values.process_activity_id%type) is
  --
  l_cursor_name    integer;
  l_sqlbuf         varchar2(2000);
  l_row_processed  integer;
  --
begin
  l_sqlbuf := 'begin ' || p_procedure_name || ' (:v1,:v2,:v3); end;';
  l_cursor_name := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor_name, l_sqlbuf, dbms_sql.v7);
  dbms_sql.bind_variable(l_cursor_name, ':v1', p_item_type);
  dbms_sql.bind_variable(l_cursor_name, ':v2', p_item_key);
  dbms_sql.bind_variable(l_cursor_name, ':v3', p_actid);
  l_row_processed := dbms_sql.execute(l_cursor_name);
  dbms_sql.close_cursor(l_cursor_name);
exception
  when OTHERS then
    -- supply HR error message
    -- an error has occurred when attempting to call the stored procedure
    -- to generate the web page.
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', 'hr_workflow_service.display_html');
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
end display_html;
-- ----------------------------------------------------------------------------
-- |---------------------------< continue_process >---------------------------|
-- ----------------------------------------------------------------------------
procedure continue_process
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type) is
  --
  l_activity_type       wf_activity_attr_values.text_value%type;
  l_activity_type_value wf_activity_attr_values.text_value%type;
  l_dummy               number(1);
  --
  cursor csr_prc_active is
    select 1
    from   wf_item_activity_statuses wias
          ,wf_process_activities     wpa1
    where  wpa1.process_item_type     = p_item_type
    and    wpa1.process_name          = g_wf_root_process
    and    wpa1.process_version =
          (select max(wpa2.process_version)
           from   wf_process_activities     wpa2
           where  wpa2.process_item_type     = p_item_type
           and    wpa2.process_name          = g_wf_root_process)
    and    wias.process_activity = wpa1.instance_id
    and    wias.item_type        = p_item_type
    and    wias.item_key         = p_item_key
    and    wias.activity_status  = g_wf_root_process_active;
  -- select all ACTIVITIES for the item type/key which are FUNCTION's and
  -- have a status of NOTIFIED and have either the HR_ACTIVITY_TYPE or
  -- HR_ACTIVITY_TYPE_VALUE activity attributes defined
  cursor csr_wiasv is
    /*select wiasv.activity_id
    from   wf_item_activity_statuses_v  wiasv
    where  wiasv.item_type            = p_item_type
    and    wiasv.item_key             = p_item_key
    and    wiasv.activity_type_code   = g_wf_function
    and    wiasv.activity_status_code = g_wf_activity_notified
    and    exists
          (select 1
           from   wf_activity_attr_values      waav
           where  waav.process_activity_id   = wiasv.activity_id
           and    waav.name in (g_hr_activity_type, g_hr_activity_type_value));*/
   SELECT process_activity activity_id
   FROM   WF_ITEM_ACTIVITY_STATUSES IAS
   WHERE  ias.item_type          = p_item_type
   and    ias.item_key           = p_item_key
   and    ias.activity_status    = g_wf_activity_notified
   and    exists
          (select 1
           from   wf_activity_attr_values      waav
           where  waav.process_activity_id   = ias.process_activity
           and    waav.name in (g_hr_activity_type, g_hr_activity_type_value));

  -- select the activity attribute NAME and TEXT_VALUE for the specified
  -- ACTIVITY where the activity attribute name is either; HR_ACTIVITY_TYPE
  -- and HR_ACTIVITY_TYPE_VALUE
  cursor csr_waav
    (c_process_activity_id wf_activity_attr_values.process_activity_id%type) is
    select waav.name
          ,waav.text_value
    from   wf_activity_attr_values     waav
    where  waav.process_activity_id   = c_process_activity_id
    and    waav.name in (g_hr_activity_type, g_hr_activity_type_value);
begin
  -- check to see if the process is still ACTIVE
  open csr_prc_active;
  fetch csr_prc_active into l_dummy;
  if csr_prc_active%notfound then
    -- the process is not ACTIVE anymore there no further processing
    -- is required
    close csr_prc_active;
  else
    close csr_prc_active;
    -- select each ACTIVITY which is a FUNCTION in a NOTIFIED state
    for l_csr1 in csr_wiasv loop
      -- select the HR_ACTIVITY_TYPE and HR_ACTIVITY_TYPE_VALUE attribute values
      for l_csr2 in csr_waav(l_csr1.activity_id) loop
        if l_csr2.name = 'HR_ACTIVITY_TYPE' then
          l_activity_type := l_csr2.text_value;
        else
          l_activity_type_value := l_csr2.text_value;
        end if;
      end loop;
      -- check to see if we have a web page
      if l_activity_type = g_hr_web_page_code then
        -- display the web/HTML page
        display_html
          (p_procedure_name => l_activity_type_value
          ,p_item_type      => p_item_type
          ,p_item_key       => p_item_key
          ,p_actid          => l_csr1.activity_id);
        -- only display one web page so exit loop
        exit;
      end if;
    end loop;
    --
  end if;
end continue_process;
-- ----------------------------------------------------------------------------
-- |------------------------< transition_activity >---------------------------|
-- ----------------------------------------------------------------------------
procedure transition_activity
  (p_item_type   in wf_items.item_type%type
  ,p_item_key    in wf_items.item_key%type
  ,p_actid       in wf_activity_attr_values.process_activity_id%type
  ,p_result_code in wf_item_activity_statuses_v.activity_result_code%type) is
  --
begin
  -- transition the wf engine
  wf_engine.CompleteActivity
    (itemtype    => p_item_type
    ,itemkey     => p_item_key
    ,activity    => wf_engine.GetActivityLabel(actid => p_actid)
    ,result      => p_result_code);
  -- continue the process after it has been transitioned
  continue_process
    (p_item_type => p_item_type
    ,p_item_key  => p_item_key);
  --
end transition_activity;
--
-- ----------------------------------------------------------------------------
-- |-------------------------<  check_active_wf_items >-- ---------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This function is overloaded.  It will only return the pending
--          approval workflow items for a section of a page, ie. by
--          activity_result_code to a table.
-- ----------------------------------------------------------------------------
function check_active_wf_items
  (p_item_type             in wf_items.item_type%type
  ,p_process_name          in wf_process_activities.process_name%type
  ,p_current_person_id     in per_people_f.person_id%type
  ,p_activity_name         in wf_item_activity_statuses_v.activity_name%type
  ,p_activity_result_code  in varchar2
  )
  return active_wf_items_list is
  --
  l_process_name         wf_process_activities.process_name%type;
  l_active_item_key      wf_items.item_key%type;
  l_dummy  number(1);
  l_count  integer;
  l_active_wf_items_list  hr_workflow_service.active_wf_items_list;
  l_activity_id      wf_item_activity_statuses_v.activity_id%type;
  --
  -- Local cursor definations
  -- csr_wf_active_item Returns the item key of any process which
  -- is currently active with the name of p_process and belonging to
  -- the given person id
 cursor csr_wfactitms  (p_current_person_id   in per_people_f.person_id%type
                       ,p_process_name in wf_process_activities.process_name%type
                       ,p_item_type    in wf_items.item_type%type
                       ) is

-- fix for the bug1835437
    SELECT   /*+ ordered */
             process.item_key
    FROM     wf_process_activities activity,
             wf_item_activity_statuses process,
             wf_item_activity_statuses result,
             wf_item_attribute_values attribute
    WHERE    activity.activity_name      = p_process_name
    AND      activity.activity_item_type = p_item_type
    AND      activity.process_item_type  = p_item_type
    AND      activity.instance_id        = process.process_activity
    AND      process.activity_status     = 'ACTIVE'
    AND      process.item_type           = p_item_type
    AND      process.item_key            = attribute.item_key
    AND      attribute.item_type         = p_item_type
    AND      attribute.name              = 'CURRENT_PERSON_ID'
    AND      attribute.number_value      = p_current_person_id
    and      result.item_type            = p_item_type
    and      result.item_key             = process.item_key
    and      result.activity_result_code = p_activity_result_code;

/*

-- fix for bug # 1632855 also refer bug # 1577987
-- removed the view wf_item_activity_statuses_v
 -- using activity_item_type||'' to disable non unique index

    select process.item_key
    from   wf_item_activity_statuses    process
          ,wf_item_attribute_values     attribute
          ,wf_process_activities        activity
    where  activity.activity_name      = p_process_name
    and    activity.process_item_type  = p_item_type
    and    activity.activity_item_type||'' = p_item_type
    and    activity.instance_id        = process.process_activity
    and    process.activity_status||''     = 'ACTIVE'
    and    process.item_type           = p_item_type
    and    process.item_key            = attribute.item_key
    and    attribute.item_type         = p_item_type
    and    attribute.name              = 'CURRENT_PERSON_ID'
    and    attribute.number_value      = p_current_person_id;

*/

/*
    select process.item_key
    from   wf_item_activity_statuses    process
          ,wf_item_attribute_values     attribute
          ,wf_process_activities        activity
          ,wf_item_activity_statuses    result
    where  activity.activity_name      = p_process_name
    and    activity.process_item_type  = p_item_type
    and    activity.activity_item_type = p_item_type
    and    activity.instance_id        = process.process_activity
    and    process.activity_status     = 'ACTIVE'
    and    process.item_type           = p_item_type
    and    process.item_key            = attribute.item_key
    and    attribute.item_type         = process.item_type
    and    attribute.name              = 'CURRENT_PERSON_ID'
    and    attribute.number_value      = p_current_person_id
    and    result.item_type            = p_item_type
    and    result.item_key             = process.item_key
    and    result.activity_result_code = p_activity_result_code;
*/

    /*select process.item_key
    from   wf_item_activity_statuses_v process
    where  process.activity_name  = p_process_name
    and    process.activity_status_code = 'ACTIVE'
    and    process.item_type      = p_item_type
    and    process.item_key in (select attribute.item_key
           from wf_item_attribute_values attribute
           where attribute.item_type    = p_item_type
           and    attribute.name         = 'CURRENT_PERSON_ID'
           and    attribute.number_value = p_current_person_id);*/

 cursor csr_hats  is
    select 1
    from   hr_api_transaction_steps
    where  item_type      = p_item_type
    and    item_key       = l_active_item_key;

 cursor csr_wfactname  is
  select activity.instance_id activity_id
    from wf_process_activities        activity,
         wf_item_activity_statuses    process
    where activity.activity_name      = p_activity_name
    and    activity.process_item_type  = p_item_type
    and    activity.activity_item_type = p_item_type
    and    activity.instance_id        = process.process_activity
    and    process.item_type           = p_item_type
    and    process.item_key = l_active_item_key
    and    process.activity_status = 'COMPLETE';

  /*  select distinct process.activity_id
    from   wf_item_activity_statuses_v process
    where  process.item_type      = p_item_type
    and    process.item_key       = l_active_item_key
    and    process.activity_name  = p_activity_name; */

  --
  l_activity_result_code  wf_item_activity_statuses.activity_result_code%type;
  --
begin
  -- There can be mulitiple Itemkeys each corresponding to a
  -- section of a worksheet. Loop through all of them and validate
  -- that the records exist in the transaction table.
  l_count := 0;
  -- get each active process for the person in the given itemtype
 <<main_loop>>
  for I in csr_wfactitms  (p_current_person_id  => p_current_person_id
                            ,p_process_name => p_process_name
                            ,p_item_type    => p_item_type
                            ) loop
         l_active_item_key := I.item_key;
         if l_active_item_key Is Not Null then
             -- open the cursor
             open  csr_hats;
             fetch csr_hats into l_dummy;
             if csr_hats%notfound then
                l_active_item_key := null;
             else
                 -- Open cursor and get the activity name
                 open csr_wfactname;
                 fetch csr_wfactname into l_activity_id;
                 if csr_wfactname%notfound then
                    l_activity_id := null;
                 else
                    l_activity_result_code := p_activity_result_code;
                    --   hr_workflow_service.get_activity_reentry_value
                    --            (p_item_type => p_item_type
                    --            ,p_item_key  => l_active_item_key
                    --            ,p_actid     => l_activity_id);
                    --IF upper(p_activity_result_code) =
                    --   upper(l_activity_result_code) THEN
                       -------------------------------------------------------
                       -- NOTE: The count increment statement must be at
                       --       the place where a row is to be written
                       --       to the l_active_wf_items_list table. Otherwise,
                       --       we'll get index mismatched problem with the
                       --       NO_DATA_FOUND error when accessing the table.
                       -------------------------------------------------------
                       l_count := l_count + 1;
                       l_active_wf_items_list(l_count).active_item_key
                                 := l_active_item_key;
                       l_active_wf_items_list(l_count).activity_id
                                 := l_activity_id;
                       l_active_wf_items_list(l_count).activity_result_code
                          := l_activity_result_code;
                    --END IF;
                 end if;
                 close csr_wfactname;
             end if;
             close csr_hats;
         end if;
  end loop;
  return l_active_wf_items_list;
--
end check_active_wf_items;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_active_wf_items >-------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This function will return all the pending approval workflow items
--          for a page.  If a page has many sections, the caller need to filter
--          the pending approval workflow items to find out if a particular
--          section has active pending approval items by comparing the
--          activity result code.
-- ----------------------------------------------------------------------------
function check_active_wf_items
  (p_item_type             in wf_items.item_type%type
  ,p_process_name          in wf_process_activities.process_name%type
  ,p_current_person_id     in per_people_f.person_id%type
  ,p_activity_name         in wf_item_activity_statuses_v.activity_name%type
  )
  return active_wf_items_list is
  --
  l_process_name         wf_process_activities.process_name%type;
  l_active_item_key      wf_items.item_key%type;
  l_dummy  number(1);
  l_count  integer;
  l_active_wf_items_list  hr_workflow_service.active_wf_items_list;
  l_activity_id      wf_item_activity_statuses_v.activity_id%type;
  --
  -- Local cursor definations
  -- csr_wf_active_item Returns the item key of any process which
  -- is currently active with the name of p_process and belonging to
  -- the given person id
 cursor csr_wfactitms  (p_current_person_id   in per_people_f.person_id%type
                       ,p_process_name in wf_process_activities.process_name%type
                       ,p_item_type    in wf_items.item_type%type
                       ) is


-- fix for the bug1835437
    SELECT   /*+ ordered */
             process.item_key
    FROM     wf_process_activities activity,
             wf_item_activity_statuses process,
             wf_item_attribute_values attribute
    WHERE    activity.activity_name      = p_process_name
    AND      activity.activity_item_type = p_item_type
    AND      activity.instance_id        = process.process_activity
    AND      process.activity_status     = 'ACTIVE'
    AND      process.item_type           = p_item_type
    AND      process.item_key            = attribute.item_key
    AND      attribute.item_type         = p_item_type
    AND      attribute.name              = 'CURRENT_PERSON_ID'
    AND      attribute.number_value      = p_current_person_id;

/*
-- fix for bug # 1632855 and also refer bug # 1577987
-- removed the view wf_item_activity_statuses_v
 -- using activity_item_type||'' to disable non unique index
 -- removed the redundant AND conditions

    select process.item_key
    from   wf_item_attribute_values     attribute,
           wf_process_activities        activity,
           wf_item_activity_statuses    process
    where  activity.activity_name      = p_process_name
--    and    activity.process_item_type  = p_item_type
--    and    activity.activity_item_type||'' = p_item_type
    and    activity.instance_id        = process.process_activity
    and    process.activity_status     = 'ACTIVE'
    and    process.item_type           = p_item_type
    and    process.item_key            = attribute.item_key
    and    attribute.item_type         = p_item_type
    and    attribute.name              = 'CURRENT_PERSON_ID'
    and    attribute.number_value      = p_current_person_id;

*/

/*
    select process.item_key
    from   wf_item_activity_statuses    process
          ,wf_item_attribute_values     attribute
          ,wf_process_activities        activity
    where  activity.activity_name      = p_process_name
    and    activity.process_item_type  = p_item_type
    and    activity.activity_item_type = p_item_type
    and    activity.instance_id        = process.process_activity
    and    process.activity_status     = 'ACTIVE'
    and    process.item_type           = p_item_type
    and    process.item_key            = attribute.item_key
    and    attribute.item_type         = p_item_type
    and    attribute.name              = 'CURRENT_PERSON_ID'
    and    attribute.number_value      = p_current_person_id;
*/

    /*select process.item_key
    from   wf_item_activity_statuses_v process
    where  process.activity_name  = p_process_name
    and    process.activity_status_code = 'ACTIVE'
    and    process.item_type      = p_item_type
    and    process.item_key in (select attribute.item_key
           from wf_item_attribute_values attribute
           where attribute.item_type    = p_item_type
           and    attribute.name         = 'CURRENT_PERSON_ID'
           and    attribute.number_value = p_current_person_id);*/

 cursor csr_hats  is
    select 1
    from   hr_api_transaction_steps
    where  item_type      = p_item_type
    and    item_key       = l_active_item_key;

 cursor csr_wfactname  is
   select activity.instance_id activity_id
    from wf_process_activities        activity,
         wf_item_activity_statuses    process
    where activity.activity_name      = p_activity_name
    and    activity.process_item_type  = p_item_type
    and    activity.activity_item_type = p_item_type
    and    activity.instance_id        = process.process_activity
    and    process.item_type           = p_item_type
    and    process.item_key = l_active_item_key
    and    process.activity_status = 'COMPLETE';

    /*select distinct process.activity_id
    from   wf_item_activity_statuses_v process
    where  process.item_type      = p_item_type
    and    process.item_key       = l_active_item_key
    and    process.activity_name  = p_activity_name; */

begin
  -- There can be mulitiple Itemkeys each corresponding to a
  -- section of a worksheet. Loop through all of them and validate
  -- that the records exist in the transaction table.
  l_count := 0;
  -- get each active process for the person in the given itemtype
 <<main_loop>>
  for I in csr_wfactitms  (p_current_person_id  => p_current_person_id
                            ,p_process_name => p_process_name
                            ,p_item_type    => p_item_type
                            ) loop
         l_active_item_key := I.item_key;
         if l_active_item_key Is Not Null then
             -- open the cursor
             open  csr_hats;
             fetch csr_hats into l_dummy;
             if csr_hats%notfound then
                l_active_item_key := null;
             else
                 l_count := l_count + 1;
                 l_active_wf_items_list(l_count).active_item_key
                                 := l_active_item_key;
                 -- Open cursor and get the activity name
                 open csr_wfactname;
                 fetch csr_wfactname into l_activity_id;
                 if csr_wfactname%notfound then
                        l_activity_id := null;
                 else
                        l_active_wf_items_list(l_count).activity_id
                                 := l_activity_id;
                        l_active_wf_items_list(l_count).activity_result_code
                          := hr_workflow_service.get_activity_reentry_value
                                (p_item_type => p_item_type
                                ,p_item_key  => l_active_item_key
                                ,p_actid     => l_activity_id);
                 end if;
                 close csr_wfactname;
             end if;
             close csr_hats;
         end if;
  end loop;
  return l_active_wf_items_list;
--
end check_active_wf_items;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_active_wf_items >-------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This function will return all the pending approval workflow items
--          for a page.  If a page has many sections, the caller can pass
--          the result code to find out if a particular section has active
--          pending approval items by comparing the activity result code.
--          This function is designed specifically for use in Personal
--          Information to look for pending approval items which contain an
--          acitivity with a specific result code equals to the input parameter.
--          For Address Section in Personal Information, it needs to pass
--          a value of either "PRIMARY" or "SECONDARY" in the parameter
--          p_address_context because Primary Address and Secondary Address
--          share the same api name, which is hr_process_address_ss.
-- ----------------------------------------------------------------------------
FUNCTION get_active_wf_items
  (p_item_type             in wf_items.item_type%type
  ,p_process_name          in wf_process_activities.process_name%type
  ,p_current_person_id     in per_people_f.person_id%type
  ,p_api_name              in hr_api_transaction_steps.api_name%type
  ,p_activity_result_code  in varchar2  default null
  ,p_address_context       in varchar2  default null
  )
  return active_wf_trans_items_list is
  --
  l_process_name         wf_process_activities.process_name%type;
  l_active_item_key      wf_items.item_key%type;
  l_count  integer;
  l_active_wf_items_list  hr_workflow_service.active_wf_trans_items_list;
  l_activity_id      wf_item_activity_statuses_v.activity_id%type;
  --
  -- Local cursor definitions
  -----------------------------------------------------------------------------
  -- csr_wf_active_item Returns the item key of any process which
  -- is currently active with the name of p_process and belonging to
  -- the given person id
  --
  -- For a given item_type and item_key, we want to find out if that item_key
  -- contains a wf activity with a specific result code.  This way, we can
  -- determine if the item_key has gone through a specific path, such as
  -- submit for approval.
  -----------------------------------------------------------------------------
 cursor csr_wfactitms (p_current_person_id   in per_people_f.person_id%type
                      ,p_process_name in wf_process_activities.process_name%type
                      ,p_item_type    in wf_items.item_type%type
                      ,p_result_code  in varchar2
                       ) is

    select process.item_key
    from   wf_item_activity_statuses    process
          ,wf_item_attribute_values     attribute
          ,wf_process_activities        activity
          ,wf_item_activity_statuses    result
    where  activity.activity_name      = p_process_name
    and    activity.process_item_type  = p_item_type
    and    activity.activity_item_type = p_item_type
    and    activity.instance_id        = process.process_activity
    and    process.activity_status     = 'ACTIVE'
    and    process.item_type           = p_item_type
    and    process.item_key            = attribute.item_key
    and    attribute.item_type         = process.item_type
    and    attribute.name              = 'CURRENT_PERSON_ID'
    and    attribute.number_value      = p_current_person_id
    and    result.item_type            = process.item_type
    and    result.item_key             = process.item_key
    and    result.activity_result_code = p_result_code;

  -----------------------------------------------------------------------------
  -- csr_wf_active_item Returns the item key of any process which
  -- is currently active with the name of p_process and belonging to
  -- the given person id
  --
  -- The following cursor is for no result code passed in.
  -----------------------------------------------------------------------------
 cursor csr_wfactitms2 (p_current_person_id   in per_people_f.person_id%type
                      ,p_process_name in wf_process_activities.process_name%type
                      ,p_item_type    in wf_items.item_type%type
                       ) is

    select process.item_key
    from   wf_item_activity_statuses    process
          ,wf_item_attribute_values     attribute
          ,wf_process_activities        activity
    where  activity.activity_name      = p_process_name
    and    activity.process_item_type  = p_item_type
    and    activity.activity_item_type = p_item_type
    and    activity.instance_id        = process.process_activity
    and    process.activity_status     = 'ACTIVE'
    and    process.item_type           = p_item_type
    and    process.item_key            = attribute.item_key
    and    attribute.item_type         = process.item_type
    and    attribute.name              = 'CURRENT_PERSON_ID'
    and    attribute.number_value      = p_current_person_id;


 ------------------------------------------------------------------------------
 -- We use api_name to filter the transaction records to improve performance so
 -- that we don't need to loop through the wf_item_activity_statuses_v to
 -- derive the activity_id for a given activity_name.  The view
 -- wf_item_activity_statuses_v has a lot of records to process.
 ------------------------------------------------------------------------------
 cursor csr_hats (csr_p_api_name  in varchar2
                 ,csr_p_item_key  in varchar2)  is
    select transaction_step_id, activity_id
    from   hr_api_transaction_steps
    where  item_type        = p_item_type
    and    item_key         = csr_p_item_key
    and    upper(api_name)  = csr_p_api_name;

 ------------------------------------------------------------------------------
 -- The following cursor is similar to csr_hats except that it further filters
 -- by a transaction value with a content of "P_PRIMARY_FLAG" equals to "Y" or
 -- "N".  This cursor is used by addresses because both primary and
 -- secondary address use the same api name, which is hr_process_address_ss.
 -- Hence, we cannot differentiate a transaction step is either for primary
 -- or secondary address if we don't look at the transaction value.
 ------------------------------------------------------------------------------
------------------------------------------------------------------------------
 -- These changes are made to accomodate a second secondary address. since there
 -- is no way to identify between the two secondary addresses, we will call this
 -- a tertiary address and IN TRANSACTION TABLES the  "P_PRIMARY_FLAG" will be
 -- set to "T" IMPORTANT -- only in transaction table
 ------------------------------------------------------------------------------
 cursor csr_addr_hats (csr_p_api_name        in varchar2
                      ,csr_p_item_key        in varchar2
                      ,csr_p_primary_flag    in varchar2
                      )  is
    select step.transaction_step_id, step.activity_id
    from   hr_api_transaction_steps       step
          ,hr_api_transaction_values      value
    where  item_type        = p_item_type
    and    item_key         = csr_p_item_key
    and    upper(api_name)  = csr_p_api_name
    and    step.transaction_step_id = value.transaction_step_id
    and    value.name = 'P_PRIMARY_FLAG'
    and    value.varchar2_value = csr_p_primary_flag;


 l_activity_result_code    wf_item_activity_statuses.activity_result_code%type;
 l_activity_result_code_in   wf_item_activity_statuses.activity_result_code%type
                           default null;
 api_name_in               hr_api_transaction_steps.api_name%type default null;
 l_trans_step_id           hr_api_transaction_steps.transaction_step_id%type
                           default null;
 l_address_primary_flag    per_addresses.primary_flag%type default null;
 l_use_csr_addr_hats       varchar2(1) default null;

BEGIN
  -- There can be mulitiple Itemkeys each corresponding to a
  -- section of a page. Loop through all of them and validate
  -- that the records exist in the transaction table because there be
  -- defunct wf processes but no transaction records exist.

  l_activity_result_code_in := upper(p_activity_result_code);
  api_name_in := upper(p_api_name);

  ----------------------------------------------------------------------------
  -- Check if we are getting pending approval items for primary or secondary
  -- address. If yes, we need to use a different cursor in retrieving trans
  -- data because primary and secondary address use the same api name, which
  -- is hr_process_address_ss.
  ----------------------------------------------------------------------------
  IF p_address_context IS NOT NULL
  THEN
     IF upper(p_address_context) = 'PRIMARY'
     THEN
        l_use_csr_addr_hats := 'Y';
        l_address_primary_flag := 'Y';
     ELSIF upper(p_address_context) = 'SECONDARY'
     THEN
        l_use_csr_addr_hats := 'Y';
        l_address_primary_flag := 'N';
       -- startregistration
     ELSIF upper(p_address_context) = 'TERTIARY'
     THEN
        l_use_csr_addr_hats := 'Y';
        l_address_primary_flag := 'T';
      -- endregistration
     END IF;
  ELSE
     l_use_csr_addr_hats := 'N';
  END IF;

  l_count := 0;
  -- get each active process for the person in the given itemtype
 IF l_activity_result_code_in IS NOT NULL
 THEN
    -- filter by result code
    -- main loop
    FOR I in csr_wfactitms  (p_current_person_id  => p_current_person_id
                              ,p_process_name       => p_process_name
                              ,p_item_type          => p_item_type
                              ,p_result_code        => l_activity_result_code_in
                              )
    LOOP
       l_active_item_key := I.item_key;

       -- inner loop
       IF l_use_csr_addr_hats = 'Y'
       THEN
          FOR csr_trans in csr_addr_hats
                 (csr_p_api_name     => api_name_in
                 ,csr_p_item_key     => l_active_item_key
                 ,csr_p_primary_flag => l_address_primary_flag
                 )
          LOOP
             -------------------------------------------------------
             -- NOTE: The count increment statement must be at
             --       the place where a row is to be written
             --       to the l_active_wf_items_list table. Otherwise,
             --       we'll get index mismatched problem with the
             --       NO_DATA_FOUND error when accessing the table.
             -------------------------------------------------------
             l_count := l_count + 1;
             l_active_wf_items_list(l_count).active_item_key
                          := l_active_item_key;
             l_active_wf_items_list(l_count).activity_id :=
                                             csr_trans.activity_id;
             l_active_wf_items_list(l_count).trans_step_id :=
                                             csr_trans.transaction_step_id;
             l_active_wf_items_list(l_count).activity_result_code
                          := l_activity_result_code;
          END LOOP;  -- end inner loop for address
      -- ELSE  Please remove comment if registration removed
      -- startregistration
         ELSIF l_use_csr_addr_hats = 'N'
         THEN
      -- endregistration
          FOR csr_trans in csr_hats (csr_p_api_name => api_name_in
                                 ,csr_p_item_key => l_active_item_key)
          LOOP
             -------------------------------------------------------
             -- NOTE: The count increment statement must be at
             --       the place where a row is to be written
             --       to the l_active_wf_items_list table. Otherwise,
             --       we'll get index mismatched problem with the
             --       NO_DATA_FOUND error when accessing the table.
             -------------------------------------------------------
             l_count := l_count + 1;
             l_active_wf_items_list(l_count).active_item_key
                          := l_active_item_key;
             l_active_wf_items_list(l_count).activity_id :=
                                             csr_trans.activity_id;
             l_active_wf_items_list(l_count).trans_step_id :=
                                             csr_trans.transaction_step_id;
             l_active_wf_items_list(l_count).activity_result_code
                          := l_activity_result_code;
          END LOOP;  -- end inner loop
       -- startregistration
         ELSIF l_use_csr_addr_hats = 'T'
         THEN
          FOR csr_trans in csr_hats (csr_p_api_name => api_name_in
                                 ,csr_p_item_key => l_active_item_key)
          LOOP
             -------------------------------------------------------
             -- NOTE: The count increment statement must be at
             --       the place where a row is to be written
             --       to the l_active_wf_items_list table. Otherwise,
             --       we'll get index mismatched problem with the
             --       NO_DATA_FOUND error when accessing the table.
             -------------------------------------------------------
             l_count := l_count + 1;
             l_active_wf_items_list(l_count).active_item_key
                          := l_active_item_key;
             l_active_wf_items_list(l_count).activity_id :=
                                             csr_trans.activity_id;
             l_active_wf_items_list(l_count).trans_step_id :=
                                             csr_trans.transaction_step_id;
             l_active_wf_items_list(l_count).activity_result_code
                          := l_activity_result_code;
          END LOOP;  -- end inner loop
        -- endregistration
       END IF;
    END LOOP;     -- end main loop
 ELSE
    -- no result code filter
    -- main loop
    FOR I in csr_wfactitms2 (p_current_person_id  => p_current_person_id
                              ,p_process_name       => p_process_name
                              ,p_item_type          => p_item_type
                              )
    LOOP
       l_active_item_key := I.item_key;

       -- inner loop
       IF l_use_csr_addr_hats = 'Y'
       THEN
          FOR csr_trans in csr_addr_hats
                 (csr_p_api_name     => api_name_in
                 ,csr_p_item_key     => l_active_item_key
                 ,csr_p_primary_flag => l_address_primary_flag
                 )
          LOOP
             -------------------------------------------------------
             -- NOTE: The count increment statement must be at
             --       the place where a row is to be written
             --       to the l_active_wf_items_list table. Otherwise,
             --       we'll get index mismatched problem with the
             --       NO_DATA_FOUND error when accessing the table.
             -------------------------------------------------------
             l_count := l_count + 1;
             l_active_wf_items_list(l_count).active_item_key
                          := l_active_item_key;
             l_active_wf_items_list(l_count).activity_id :=
                                             csr_trans.activity_id;
             l_active_wf_items_list(l_count).trans_step_id :=
                                             csr_trans.transaction_step_id;
             l_active_wf_items_list(l_count).activity_result_code
                          := l_activity_result_code;
          END LOOP;  -- end inner loop for address
       -- ELSE  Please remove comment if registration removed
      --startregistration
      ELSIF  l_use_csr_addr_hats = 'N'
      THEN
      --endregistration
          FOR csr_trans in csr_hats (csr_p_api_name => api_name_in
                                 ,csr_p_item_key => l_active_item_key)
          LOOP
             -------------------------------------------------------
             -- NOTE: The count increment statement must be at
             --       the place where a row is to be written
             --       to the l_active_wf_items_list table. Otherwise,
             --       we'll get index mismatched problem with the
             --       NO_DATA_FOUND error when accessing the table.
             -------------------------------------------------------
             -- no result code passed in for filtering
             l_count := l_count + 1;
             l_active_wf_items_list(l_count).active_item_key
                          := l_active_item_key;
             l_active_wf_items_list(l_count).activity_id :=
                                           csr_trans.activity_id;
             l_active_wf_items_list(l_count).trans_step_id :=
                                              csr_trans.transaction_step_id;
             l_active_wf_items_list(l_count).activity_result_code
                          := l_activity_result_code;
          END LOOP; -- inner loop
       --startregistration
      ELSIF  l_use_csr_addr_hats = 'T'
      THEN
          FOR csr_trans in csr_hats (csr_p_api_name => api_name_in
                                 ,csr_p_item_key => l_active_item_key)
          LOOP
             -------------------------------------------------------
             -- NOTE: The count increment statement must be at
             --       the place where a row is to be written
             --       to the l_active_wf_items_list table. Otherwise,
             --       we'll get index mismatched problem with the
             --       NO_DATA_FOUND error when accessing the table.
             -------------------------------------------------------
             -- no result code passed in for filtering
             l_count := l_count + 1;
             l_active_wf_items_list(l_count).active_item_key
                          := l_active_item_key;
             l_active_wf_items_list(l_count).activity_id :=
                                           csr_trans.activity_id;
             l_active_wf_items_list(l_count).trans_step_id :=
                                              csr_trans.transaction_step_id;
             l_active_wf_items_list(l_count).activity_result_code
                          := l_activity_result_code;
          END LOOP; -- inner loop
       -- endregistration
       END IF;
    END LOOP;    -- main loop
 END IF;

  return l_active_wf_items_list;
--
END get_active_wf_items;
-- ----------------------------------------------------------------------------
-- |-------------------------< remove_defunct_process >--------------------------|
-- ----------------------------------------------------------------------------
procedure remove_defunct_process
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2) is
  --
  l_item_key       wf_items.item_key%type;
  l_dummy  INTEGER;
  l_transaction_id    hr_api_transactions.transaction_id%type;
  l_transaction_age number default 30;
  l_transaction_status varchar2(5) ;
  l_transaction_status_to_delete varchar2(10);
  c_status varchar2(10);
  l_delete_transaction boolean default false;
  errbuf  varchar2(4000) default '';

  --
  -- Local cursor definations
  -- csr_wfdfctitms Returns the item keys of any process activites which
  -- are in NOTFIED state and whose session ID are either disabled or
  -- which do exists.
  -- This cursor is now defunt as we are using the transaction age as the criteria instead of
  -- ICX session id. Please check the LLD for details.
  -- The changes to the program are tracked through bug # 2380121
 /*cursor csr_wfdfctitms is
 select wias.item_key
   from wf_item_activity_statuses wias,
        wf_activity_attr_values waav,
        wf_process_activities wpa,
        wf_item_attribute_values wiav
 where wias.item_type = itemtype
   and wias.activity_status = 'NOTIFIED'
   and wpa.instance_id = wias.process_activity
   and wpa.instance_id = waav.process_activity_id
   and waav.name = 'HR_ACTIVITY_TYPE'
   and wiav.item_key = wias.item_key
   and wiav.item_type = wias.item_type
   and wiav.name = 'SESSION_ID'
   and not exists
        (select 1
           from icx_sessions s
          where s.session_id = wiav.number_value
            and s.disabled_flag = 'N');
*/

  cursor csr_wfdfctitms (c_transaction_age in number, c_status in varchar2) is
  select * from (select a.transaction_id transaction_id,
                           s.text_value status,
                 	   a.item_type item_type,
                           a.item_key  item_key
                    from (select transaction_id,
 		                         status,
                                 nvl(item_type,hr_workflow_service.getItemType(t.transaction_id)) item_type,
                                 nvl(item_key,hr_workflow_service.getItemKey(t.transaction_id)) item_key
                            from hr_api_transactions t
                           where t.last_update_date <= sysdate - c_transaction_age
                           and t.status not in ('Y', 'YS')
                           and t.transaction_ref_table <> 'PER_APPRAISALS'
                              ) a, -- bug 3635925 , bug 5357274, bug 5990955
                         wf_item_attribute_values s
                     where a.item_type = itemtype
                     and a.item_type = s.item_type
                     and a.item_key = s.item_key
                     and s.name = 'TRAN_SUBMIT')
     where status = nvl(c_status,status) ;


--Bug fix 8358911
--For new architecture
  cursor csr_wfdfctitms_newarch (c_transaction_age in number, c_status in varchar2) is
		select * from (select a.transaction_id transaction_id,
                            status
                    from (select transaction_id,
 		                         status,
                                 nvl(item_type,hr_workflow_service.getItemType(t.transaction_id)) item_type,
                                 nvl(item_key,hr_workflow_service.getItemKey(t.transaction_id)) item_key
                            from hr_api_transactions t
                           where t.last_update_date <= sysdate - c_transaction_age
                           and t.status not in ('Y', 'YS')
                           and t.transaction_ref_table <> 'PER_APPRAISALS'
													 and t.item_key is null
                              ) a
                     where a.item_type = itemtype)
     where status = nvl(null,status);

--Bug fix 8358911 ends


-- start bug 5990955

--Only the appraisals with a System status (appraisal_system_status in
-- PER_APPRAISALS)  as "COMPLETED" or "DELETED", irrespective of status in
-- HR_API_TRANSACTIONS table will be deleted. So looking for the
-- APPRAISAL_SYSTEM_STATUS  in the cursor

CURSOR csr_wfdfctitmsapprs (c_transaction_age in number) is
SELECT t.item_type, t.item_key, t.transaction_id
FROM hr_api_transactions t, per_appraisals a
WHERE  t.transaction_ref_table = 'PER_APPRAISALS'
AND t.last_update_date <= sysdate - c_transaction_age
AND t.transaction_ref_id = a.appraisal_id
AND a.appraisal_system_status IN ('DELETED','COMPLETED');

-- end bug 5990955

  -- csr_wfdfctrans check if the Itemkey is present in the
  -- hr_api_transaction_steps table
 cursor csr_wfdfctrans  is
    select hats.transaction_id
      from hr_api_transaction_steps hats
     where hats.item_type = itemtype
       and hats.item_key  = l_item_key;

--
-- to fetch orphan records caused by wf tables getting purged before
-- executing this defunct process
--
 CURSOR defunct_tx_ids IS
 /*  SELECT distinct hats.transaction_id
     FROM hr_api_transaction_steps hats
    WHERE NOT EXISTS (SELECT 'Y'
                        FROM wf_items wi
                       WHERE wi.item_type = hats.item_type
                         AND wi.item_key = hats.item_key);
*/
-- Fix for bug#3322644
SELECT  hat.transaction_id
   FROM hr_api_transactions  hat
   WHERE NOT EXISTS (SELECT 'Y'
                        FROM wf_items wi
                       WHERE wi.item_type = nvl(hat.item_type,hr_workflow_service.getItemType(hat.transaction_id))
                         AND wi.item_key = nvl(hat.item_key,hr_workflow_service.getItemKey(hat.transaction_id))
                             )
AND Not Exists( select 'Y' from wf_items w   --fix for bug 6121860
                where w.item_type = 'HRSFL'
                and w.user_key = hat.transaction_id)
and hat.item_key is not null;
--
-- to fetch orphan records from wf tables which do not have an entry
-- in the hr_api_transactions. This could cause from SSHR transaction
-- not using hr_api_transactions and for WF process started without
-- an entry to the hr_api_transactions. Possible causes, user started
-- new transaction and closed the web browser.

-- fix for bug#2838117
-- fetch all the records from wf_items for given item type which
-- not in hr_api_transactions and icx session is disabled or does
-- not exist.

-- 4287117
--5076290
   CURSOR  defunct_wf_ids (c_transaction_age in number) IS
	     select wi.item_key
                from  wf_items wi , wf_item_attribute_values av, icx_sessions s
                where wi.item_type= itemtype
                and trunc(wi.begin_date) <= trunc(sysdate)  --fix for bug 6642996
                and wi.end_date is null
                and av.item_type = wi.item_type
                and av.item_key = wi.item_key
                and av.name = 'SESSION_ID'
                and av.number_value =  s.session_id(+)
                and s.disabled_flag(+) = 'Y'
                and (
                      (wi.item_key) not in (
                              select t1.item_key
                               from hr_api_transactions t1
                               where wi.item_type = t1.item_type
                               and wi.item_key = t1.item_key
                               and t1.item_type = itemtype
                              )
                       and (wi.item_key) not in (
                               select ts.item_key
                            from hr_api_transaction_steps ts
                               where ts.item_type = wi.item_type
                               and ts.item_key = wi.item_key
                               and ts.item_type = itemtype
                              )
          );
--5076290
/*   CURSOR  defunct_wf_ids IS
    select wi.item_key
    from  wf_items wi
    where wi.item_type = itemtype
    and   wi.begin_date <= trunc(sysdate)
    and   wi.end_date is null
    and not exists (select 'e' from hr_api_transactions t
                      where
                            t.item_type is not null
                        and t.item_key is not null
                        and wi.item_type = t.item_type
                        and wi.item_key = t.item_key
                    )
    and not exists (select 'e' from hr_api_transactions t, hr_api_transaction_steps ts
                      where
                          t.item_type is null
                      and t.item_key is null
                      and t.transaction_id = ts.transaction_id
                      and wi.item_type =  ts.item_type
                      and wi.item_key = ts.item_key
                      and ts.item_type is not null
                      and ts.item_key is not null
                    )
    and exists (select 'e' from wf_item_attribute_values av, icx_sessions s
                   where av.item_type = wi.item_type
                   and av.item_key = wi.item_key
                   and av.name = 'SESSION_ID'
                   and av.number_value =  s.session_id(+)
                   and s.disabled_flag(+) = 'Y');
*/

   /* Cursor to identify if there is an offer to be closed*/
   cursor csrOfferDetails(c_transaction_id in number) is
     select hat.transaction_ref_id,
            hat.assignment_id,
            iof.offer_status
     from hr_api_transactions hat,
          irc_offers iof
     where hat.transaction_ref_table='IRC_OFFERS' and
           hat.transaction_ref_id = iof.offer_id and
           hat.transaction_id = c_transaction_id and
           iof.offer_status in ('PENDING','CORRECTION');

-- Fix for bug 6501341
CURSOR  defunct_wfsfl_ids IS
select wi.item_key
from wf_items wi
where wi.item_type = 'HRSFL'
and not exists (select transaction_id from hr_api_transactions
                where transaction_id  = wi.user_key);
--

   l_offer_id number;
   l_applicant_assignment_id number;
   l_offer_status varchar2(100);
-- 4287117

--
begin
  --
  -- Get the transaction status value of items to be deleted
  -- This is normally passed through the Concurrent program
  -- and populated into item attribute HR_TRANS_STATUS_FOR_DEL_ATTR
  l_transaction_status_to_delete := wf_engine.getitemattrText
          (itemtype  => itemtype
          ,itemkey   => itemkey
          ,aname     => 'HR_TRAN_STAT_FOR_DEL_ATTR');
  -- Get the transaction age value of items to be deleted
  -- This is normally passed through the Concurrent program
  -- and populated into item attribute 'HR_TRANS_AGE_FOR_DEL_ATTR'
  l_transaction_age:= wf_engine.getitemattrNumber
          (itemtype  => itemtype
          ,itemkey   => itemkey
          ,aname     => 'HR_TRANS_AGE_FOR_DEL_ATTR');

 -- c_status
    if(l_transaction_status_to_delete='ALL') then
       c_status := null;
    else
        c_status  := l_transaction_status_to_delete;
    end if;

 if funcmode = 'RUN' then
   -- first purge all the orphan transaction records if any
   BEGIN
     for rec in defunct_tx_ids loop
      begin
        hr_utility.set_location('START : Processing defunct transaction ID : '||rec.transaction_id,400);

        l_offer_id := null;
        l_applicant_assignment_id := null;
        l_offer_status := null;

	      open csrOfferDetails(rec.transaction_id);
        fetch csrOfferDetails into l_offer_id, l_applicant_assignment_id,l_offer_status;
        close csrOfferDetails;

        hr_transaction_api.rollback_transaction(p_transaction_id => rec.transaction_id);

      	begin
          /*  To check if it is the approval process for an offer. If yes, close the offer*/
          if l_offer_id is not null then

	           hr_utility.set_location ('Closing Offer...',415);
             hr_utility.set_location ('Offer ID : '||l_offer_id,430);
             hr_utility.set_location ('Applicant Assignment ID : '||l_applicant_assignment_id,445);
             hr_utility.set_location ('Offer Status : '||l_offer_status,460);

	           irc_offers_api.close_offer(p_effective_date => sysdate
                                   , p_applicant_assignment_id => l_applicant_assignment_id
                                   , p_offer_id => l_offer_id
                                   , p_change_reason => 'MANUAL_CLOSURE'
                                   , p_note_text => 'Closed from Complete Defunct Workflow Process');
          end if;
          --
          hr_utility.set_location ('Offer successfully closed  ',480);
        exception
          when others then
            hr_utility.set_location ('Error occurred while closing offer : '||substr(SQLERRM,1,2000),500);
        end;
      exception
      when others then
         wf_core.Context(g_package, 'remove_defunct_process : Error Running defunct_tx_ids' );
      end;
      hr_utility.set_location('END : Processing defunct transaction ID : '||rec.transaction_id,400);
     end loop;
   exception
   when others then
     wf_core.Context(g_package, 'remove_defunct_process : Error Running defunct_tx_ids loop' );
   end;


   -- fix for bug#2838117
   BEGIN
    for rec in defunct_wf_ids (l_transaction_age) loop
      BEGIN
         begin
              select TEXT_VALUE
               into l_transaction_status
               from WF_ITEM_ATTRIBUTE_VALUES
               where ITEM_TYPE = itemtype
               and ITEM_KEY = rec.item_key
               and NAME = 'TRAN_SUBMIT';
               exception
               when no_data_found then
                 l_transaction_status := null;
           end;
         -- reset the l_delete_transaction status false by default
        l_delete_transaction:= false;
        -- check if the current transaction can deleted
        if(l_transaction_status='Y' or l_transaction_status='YS') then -- bug 3635925
          l_delete_transaction := false;
        else
          l_delete_transaction := true;
        end if;

        if(l_delete_transaction) then -- delete transaction which explicitly
          -- identified for delete.
          -- First abort the WF process for this transaction record.
          BEGIN -- Block to 'abort' the WF process
            wf_engine.abortprocess(itemtype => itemtype
                                  ,itemkey  => rec.item_key
                                  ,result   => 'eng_force');
          EXCEPTION
          when others then
            wf_core.Context(g_package, 'remove_defunct_process',
                            itemtype, itemkey, to_char(actid),
                        funcmode,'Record item key being processed was :'||nvl(rec.item_key,'') );
           END;-- end of Block to 'abort' the WF process
         end if;
      EXCEPTION
      when others then
         wf_core.Context(g_package, 'remove_defunct_process : Error Running defunct_wf_ids' );
      END; -- end of block for loop
     end loop;
   EXCEPTION
   when others then
     wf_core.Context(g_package, 'remove_defunct_process : Error Running defunct_wf_ids loop' );
   END; -- end block for defunct_wf_ids



  for rec in csr_wfdfctitms(l_transaction_age,c_status) loop
        BEGIN -- inner block to catch exception for the transaction being processed.
      -- check the transaction status.
      -- we will delete the transaction data related to status
      -- l_transaction_status_to_delete
      -- All transactions with status 'Y' will not be touched by this program

      if rec.item_key IS NOT NULL then
        -- Get the transaction status from the WF item attribute TRAN_SUBMIT
        -- need to remove this call once the SSHR V4.1 functionality is implemented.
        l_transaction_status :=wf_engine.GetItemAttrText(itemtype => itemtype
                                                        ,itemkey  => rec.item_key
                                                        ,aname    => 'TRAN_SUBMIT');

        -- reset the l_delete_transaction status false by default
        l_delete_transaction:= false;
        -- check if the current transaction can deleted
        if(l_transaction_status='Y' or l_transaction_status='YS') then -- bug 3635925
          l_delete_transaction := false;
        elsif(l_transaction_status_to_delete='ALL') then
          l_delete_transaction := true;
        elsif (l_transaction_status_to_delete=l_transaction_status) then
          l_delete_transaction := true;
        end if;



        if(l_delete_transaction) then -- delete transaction which explicitly
          -- identified for delete.
          -- First abort the WF process for this transaction record.
          BEGIN -- Block to 'abort' the WF process
            wf_engine.abortprocess(itemtype => itemtype
                                  ,itemkey  => rec.item_key
                                  ,result   => 'eng_force');
          exception
          when others then
            wf_core.Context(g_package, 'remove_defunct_process',
                            itemtype, itemkey, to_char(actid),
                        funcmode,'Record item key being processed was :'||nvl(rec.item_key,'') );
           END;

           BEGIN -- Block to 'purge' the data in the SSHR transaction tables.
             -- get the transaction for this transaction from workflow
             -- TRANSACTION_ID
              hr_transaction_api.rollback_transaction(p_transaction_id => rec.transaction_id );
           exception
           when others then
             wf_core.Context(g_package, 'remove_defunct_process',
                       itemtype, itemkey, to_char(actid),
                       funcmode,'Record item key being processed was :'||nvl(rec.item_key,''));
           END;


         end if; -- end of status check
      end if; -- end of check for item key.
     exception
     when others then
        wf_core.Context(g_package, 'remove_defunct_process',
                 itemtype, itemkey, to_char(actid), funcmode,'Record item key being processed was :'||rec.item_key );
     END ;

    end loop;


--Bug fix 8358911
for rec in csr_wfdfctitms_newarch(l_transaction_age,c_status) loop
		begin
               hr_transaction_api.rollback_transaction(p_transaction_id => rec.transaction_id );
           exception
           when others then
             wf_core.Context(g_package, 'remove_defunct_process',
                       itemtype, itemkey, to_char(actid),
                       funcmode,'Record transaction id being processed was :'||nvl(rec.transaction_id,''));
 		end;
end loop;
--Bug fix 8358911 Ends


-- start bug 5990955

for rec in csr_wfdfctitmsapprs(l_transaction_age) loop
	BEGIN
		wf_engine.abortprocess(itemtype => rec.item_type
                                  ,itemkey  => rec.item_key
                                  ,result   => 'eng_force');

		hr_transaction_api.rollback_transaction(p_transaction_id => rec.transaction_id );

	exception
           when others then
             wf_core.Context(g_package, 'remove_defunct_process',
                       itemtype, itemkey, to_char(actid),
                       funcmode,'Record item key being processed was :'||nvl(rec.item_key,''));
	END;
end loop;

-- end bug 5990955

  -- Fix for bug 6501341
  BEGIN
    for rec in defunct_wfsfl_ids loop
     BEGIN -- Block to 'abort' the WF process
            wf_engine.abortprocess(itemtype => 'HRSFL'
                                  ,itemkey  => rec.item_key
                                  ,result   => 'eng_force');
          EXCEPTION
          when others then
            wf_core.Context(g_package, 'remove_defunct_process',
                            'HRSFL', itemkey, to_char(actid),
                        funcmode,'Record item key being processed was :'||nvl(rec.item_key,'') );
           END;-- end of Block to 'abort' the WF process
   end loop;
   END;

  --
    resultout := 'COMPLETE:';
    return;
   end if;
 --
   if funcmode = 'CANCEL' then
     resultout := 'COMPLETE:';
     return;
   end if;

  exception
  when others then
   errbuf := sqlerrm;
    wf_core.Context
      (g_package, 'remove_defunct_process',
      itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
--
end remove_defunct_process;

--
-- ----------------------------------------------------------------------------
-- |------------------------------<start_cleanup_process>--------------------------|
-- ----------------------------------------------------------------------------
procedure start_cleanup_process
  (p_item_type               in wf_items.item_type%type
  ,p_transaction_age         in wf_item_attribute_values.number_value%type
  ,p_process_name            in wf_process_activities.process_name%type default 'HR_BACKGROUND_CLEANUP_PRC',
  p_transaction_status in varchar2 default 'ALL'
  ) is
  --
  l_process_name wf_process_activities.process_name%type := upper(p_process_name);
  l_item_type    wf_items.item_type%type := upper(p_item_type);
  l_item_key     wf_items.item_key%type;
  --
  --
begin
  -- --------------------------------------------------------------------------
  -- check if the p_transaction_age  has value
  --
    if (p_transaction_age  is NULL) then
    hr_utility.set_message(800,'HR_NULL_TRANSACTION_AGE');
    hr_utility.raise_error;
    return;
    end if;



  -- Determine if the specified process is runnable
  if NOT wf_process_runnable
           (p_item_type    => l_item_type
           ,p_process_name => l_process_name) then
    -- supply HR error message, p_process_name either does not exist or
    -- is NOT a runnable process
    hr_utility.set_message(800,'HR_52958_WKF2TSK_INC_PROCESS');
    hr_utility.set_message_token('ITEM_TYPE', l_item_type);
    hr_utility.set_message_token('PROCESS_NAME', p_process_name);
    hr_utility.raise_error;
  end if;
  -- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;



  -- Create the Workflow Process
  wf_engine.CreateProcess
    (itemtype => l_item_type
    ,itemkey  => l_item_key
    ,process  => l_process_name);
  -- set the user key
   wf_engine.SetItemUserKey(itemtype=> l_item_type,
                              itemkey => l_item_key,
                              userkey => l_item_type);

  -- add run time attribute for storing the transaction age.
  -- check if the attribute exists.
     if not item_attribute_exists
        (p_item_type => l_item_type
        ,p_item_key  => l_item_key
        ,p_name      => 'HR_TRANS_AGE_FOR_DEL_ATTR') then
        wf_engine.additemattr
          (itemtype  => l_item_type
          ,itemkey   => l_item_key
          ,aname     => 'HR_TRANS_AGE_FOR_DEL_ATTR');
      end if;

     wf_engine.setitemattrnumber
          (itemtype  => l_item_type
          ,itemkey   => l_item_key
          ,aname     => 'HR_TRANS_AGE_FOR_DEL_ATTR'
          ,avalue    => p_transaction_age);

  -- add run time attribute for storing the transaction status.
  -- check if the attribute exists.
     if not item_attribute_exists
        (p_item_type => l_item_type
        ,p_item_key  => l_item_key
        ,p_name      => 'HR_TRAN_STAT_FOR_DEL_ATTR') then
        wf_engine.additemattr
          (itemtype  => l_item_type
          ,itemkey   => l_item_key
          ,aname     => 'HR_TRAN_STAT_FOR_DEL_ATTR');
      end if;

     wf_engine.setitemattrText
          (itemtype  => l_item_type
          ,itemkey   => l_item_key
          ,aname     => 'HR_TRAN_STAT_FOR_DEL_ATTR'
          ,avalue    => p_transaction_status);


  -- Start the WF runtime process
   wf_engine.startprocess
    (itemtype => l_item_type
    ,itemkey  => l_item_key);



 exception
  when others then
    Wf_Core.Context('hr_workflow_service', 'start_cleanup_process', l_item_type, l_item_key, p_transaction_age);
    raise;
  --
end start_cleanup_process;

--

-- Block
--   Stop and wait for external completion
-- OUT
--   result    - NOTIFIED
procedure Block(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2)
is
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  hr_transaction_api.Set_Process_Order_String(p_item_type => itemtype
                      ,p_item_key  => itemkey
                      ,p_actid => actid);

  resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
exception
  when others then
    Wf_Core.Context('hr_workflow_service', 'Block', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Block;

--
-- TotalConcurrent
--   Concurrent Program version
-- IN:
--   errbuf - CPM error message
--   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
--   itemtype - Item type to delete, or null for all itemtypes
--   age - Minimum age of data to purge (in days)
--   p_process_name default cleanup process name.
--   transaction_status , the status of all the Transactions to be cleaned.

procedure TotalConcurrent(
  errbuf out nocopy varchar2,
  retcode out nocopy varchar2,
  itemtype in varchar2 default null,
  age in varchar2 default '0',
  p_process_name in varchar2 default 'HR_BACKGROUND_CLEANUP_PRC',
  transaction_status in varchar2 default 'ALL')

  is
    errname varchar2(30);
    errmsg varchar2(2000);
    errstack varchar2(2000);

  begin
    start_cleanup_process(p_item_type         =>itemtype
                         ,p_transaction_age   =>age
                         ,p_process_name      => p_process_name
                         ,p_transaction_status=>transaction_status);

    errbuf := '';
    retcode := '0';
  exception
  when others then
    -- Retrieve error message into errbuf
    wf_core.get_error(errname, errmsg, errstack);
    if (errmsg is not null) then
      errbuf := errmsg;
    else
      errbuf := sqlerrm;
    end if;
    -- Return 2 for error.
    retcode := '2';
end TotalConcurrent;


function getItemType(p_transaction_id in hr_api_transactions.transaction_id%type)
  return wf_items.item_type%type is
  l_item_type wf_items.item_type%type;
begin
        select ts.item_type
        into getItemType.l_item_type
        from hr_api_transaction_steps ts
        where ts.transaction_id=getItemType.p_transaction_id
        and ts.item_type is not null and rownum <=1;
   return   getItemType.l_item_type;
end getItemType;

function getItemKey(p_transaction_id in hr_api_transactions.transaction_id%type)
  return wf_items.item_key%type is
  l_item_key wf_items.item_key%type;
begin
        select ts.item_key
        into getItemkey.l_item_key
        from hr_api_transaction_steps ts
        where getItemkey.p_transaction_id = ts.transaction_id
        and ts.item_key is not null and rownum <=1;
 return getItemkey.l_item_key;
end getItemKey;

--
END hr_workflow_service;

/
