--------------------------------------------------------
--  DDL for Package Body HR_TASKFLOW_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TASKFLOW_WORKFLOW" as
/* $Header: hrtskwkf.pkb 120.1.12000000.2 2007/04/09 14:13:57 agolechh ship $ */
--
-- WF Used Private Globals
--
  g_process_activity_rec     wf_process_activities%rowtype;
  type g_usage_rec is record
    (nav_node_usage_id hr_navigation_node_usages.nav_node_usage_id%type
    ,instance_id       wf_process_activities.instance_id%type
    ,sqlform           hr_navigation_units.form_name%type
    ,override_label    hr_navigation_paths.override_label%type);
  type g_wf_transition_rec is record
    (to_process_activity wf_activity_transitions.to_process_activity%type
    ,result_code         wf_activity_transitions.result_code%type);
  type g_usage_tab is table of g_usage_rec index by binary_integer;
  type g_trans_tab is table of g_wf_transition_rec index by binary_integer;
  g_node_usage_tab            g_usage_tab;
  g_stack_tab                 g_trans_tab;
  g_hr_app                    varchar2(30) := 'PER';
  g_root_activity_name        varchar2(30) := 'ROOT';
  g_activity_type_function    varchar2(30) := 'FUNCTION';
  g_activity_type_process     varchar2(30) := 'PROCESS';
  g_activity_type_start       varchar2(30) := 'START';
  g_activity_type_end         varchar2(30) := 'END';
  g_default_transition_value  varchar2(30) := '*';
  g_parent_transition         varchar2(18) := 'BUTTON_PARENT_FORM';
  g_taskflow_activity_type    varchar2(22) := 'TASKFLOW_ACTIVITY_TYPE';
  g_hrms_sqlform              varchar2(12) := 'HRMS_SQLFORM';
  g_root_taskflow_form_sel    varchar2(27) := 'ROOT_TASKFLOW_FORM_SELECTOR';
  g_process_name              varchar2(12) := 'PROCESS_NAME';
  g_item_type                 varchar2(9)  := 'ITEM_TYPE';
  g_from_form_activity        varchar2(18) := 'FROM_FORM_ACTIVITY';
  g_to_form_activity          varchar2(16) := 'TO_FORM_ACTIVITY';
  g_max_number_of_buttons     number := 5;
  g_max_button_sequence_value number := 99999;
  g_root_form_activity_id     number;
  g_root_process_id           wf_process_activities.instance_id%type;
  g_business_group_id         pay_customized_restrictions.business_group_id%type;
  g_legislation_code          pay_customized_restrictions.legislation_code%type;
  g_legislation_subgroup      pay_customized_restrictions.legislation_subgroup%type;
  g_activity_display_name     wf_activities_tl.display_name%type;
  g_process_display_name      wf_activities_tl.display_name%type;
  g_item_type_display_name    wf_item_types_tl.display_name%type;
  g_language                  varchar2(30);
  g_converted_processes       number;
--
-- Private Package Cursors
--
--
  cursor g_get_process_activity(c_instance_id number) is
    select *
    from   wf_process_activities wpa
    where  wpa.instance_id = c_instance_id;
--
  cursor g_csr_root_runnable_process
           (c_item_type varchar2, c_process_name varchar2) is
    select wpa.activity_name
    from   wf_process_activities wpa
    where  wpa.process_version =
          (select max(wpa1.process_version)
           from   wf_process_activities wpa1
           where  wpa1.process_name      = wpa.process_name
           and    wpa1.process_item_type = wpa.process_item_type)
    and    wpa.process_item_type  = c_item_type
    and    wpa.activity_name      = nvl(c_process_name, wpa.activity_name)
    and    wpa.process_name       = g_root_activity_name
    order by 1;
--
-- Package Variables
--
  g_package  varchar2(33) := 'hr_taskflow_workflow.';
-- global internal workflow item attribute names
  g_root_form_name_attr    varchar2(14) := 'ROOT_FORM_NAME';
  g_workflow_duration_attr varchar2(17) := 'WORKFLOW_DURATION';
  g_oracle_session_id_attr varchar2(17) := 'ORACLE_SESSION_ID';
  g_workflow_id            hr_workflows.workflow_id%type;
  g_workflow_process_mode  varchar2(10);
-- --------------------------------------------------------------------------
-- |--------------------< get_item_act_display_names >----------------------|
-- --------------------------------------------------------------------------
procedure get_item_act_display_names
  (p_instance_id            in number
  ,p_item_type_display_name    out nocopy varchar2
  ,p_activity_display_name     out nocopy varchar2
  ,p_process_display_name      out nocopy varchar2) is
--
  l_proc varchar2(72) := g_package||'get_item_act_display_names';
--
  cursor csr_sel_names is
    select wat1.display_name     activity_display_name
          ,witt.display_name     item_display_name
          ,wat2.display_name     process_display_name
    from   wf_activities_tl      wat1
          ,wf_activities_tl      wat2
          ,wf_activities         wa1
          ,wf_activities         wa2
          ,wf_item_types_tl      witt
          ,wf_process_activities wpa
    where  wpa.instance_id = p_instance_id
    and    witt.name       = wpa.activity_item_type
    and    witt.language   = g_language
    and    wa1.name        = wpa.activity_name
    and    wa1.item_type   = wpa.activity_item_type
    and    wa1.end_date is null
    and    wat1.item_type   = wa1.item_type
    and    wat1.name        = wa1.name
    and    wat1.version     = wa1.version
    and    wat1.language    = g_language
    and    wa2.name        = wpa.process_name
    and    wa2.item_type   = wpa.process_item_type
    and    wa2.end_date is null
    and    wat2.item_type   = wa2.item_type
    and    wat2.name        = wa2.name
    and    wat2.version     = wa2.version
    and    wat2.language    = g_language;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  open csr_sel_names;
  fetch csr_sel_names
  into  p_activity_display_name, p_item_type_display_name, p_process_display_name;
  if csr_sel_names%notfound then
    p_item_type_display_name := null;
    p_activity_display_name  := null;
    p_process_display_name   := null;
  end if;
  close csr_sel_names;
  hr_utility.set_location('Leaving:'||l_proc, 20);
end get_item_act_display_names;
-- --------------------------------------------------------------------------
-- |-------------------------< get_nav_node_usage_id >----------------------|
-- --------------------------------------------------------------------------
function get_nav_node_usage_id(p_instance_id in number) return number is
  l_nav_node_usage_id number;
  l_proc varchar2(72) := g_package||'get_nav_node_usage_id';
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  for i in g_node_usage_tab.first..g_node_usage_tab.last loop
    if g_node_usage_tab(i).instance_id = p_instance_id then
      hr_utility.set_location(l_proc, 15);
      l_nav_node_usage_id := g_node_usage_tab(i).nav_node_usage_id;
      exit;
    end if;
  end loop;
  hr_utility.set_location('Leaving:'||l_proc, 20);
  return (l_nav_node_usage_id);
end get_nav_node_usage_id;
-- --------------------------------------------------------------------------
-- |-------------------------< get_override_label >-------------------------|
-- --------------------------------------------------------------------------
function get_override_label(p_instance_id in number) return varchar2 is
  l_override_label hr_navigation_paths.override_label%type := null;
  l_proc varchar2(72) := g_package||'get_override_label';
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  for i in g_node_usage_tab.first..g_node_usage_tab.last loop
    if g_node_usage_tab(i).instance_id = p_instance_id then
      hr_utility.set_location(l_proc, 15);
      l_override_label := g_node_usage_tab(i).override_label;
      exit;
    end if;
  end loop;
  hr_utility.set_location('Leaving:'||l_proc, 20);
  return (l_override_label);
end get_override_label;
-- --------------------------------------------------------------------------
-- |-------------------------------< get_sqlform >-------------------------|
-- --------------------------------------------------------------------------
function get_sqlform(p_instance_id in number) return varchar2 is
  l_sqlform hr_navigation_units.form_name%type := null;
  l_proc    varchar2(72) := g_package||'get_sqlform';
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  for i in g_node_usage_tab.first..g_node_usage_tab.last loop
    if g_node_usage_tab(i).instance_id = p_instance_id then
      hr_utility.set_location(l_proc, 15);
      l_sqlform := g_node_usage_tab(i).sqlform;
      exit;
    end if;
  end loop;
  hr_utility.set_location('Leaving:'||l_proc, 20);
  return (l_sqlform);
end get_sqlform;
-- ----------------------------------------------------------------------------
-- |-----------------< set_root_process_activity_id >-------------------------|
-- ----------------------------------------------------------------------------
procedure set_root_process_activity_id
  (p_process_item_type in varchar2
  ,p_root_process_name in varchar2) is
  -- cursor select the Process Activity ID of the root process
  cursor l_get_instance_id is
    select wpa.instance_id
    from   wf_process_activities wpa
    where  wpa.process_version =
         (select max(wpa1.process_version)
          from   wf_process_activities wpa1
          where  wpa1.process_name      = wpa.process_name
          and    wpa1.process_item_type = wpa.process_item_type)
    and    wpa.process_item_type  = p_process_item_type
    and    wpa.activity_name      = p_root_process_name
    and    wpa.process_name       = g_root_activity_name;
  --
  l_proc varchar2(72) := g_package||'set_root_process_activity_id';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  open l_get_instance_id;
  fetch l_get_instance_id into g_root_process_id;
  if l_get_instance_id%notfound then
    -- error the root process specified does not exist
    close l_get_instance_id;
    fnd_message.set_name(g_hr_app, 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', 'internal error');
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  end if;
  close l_get_instance_id;
  hr_utility.set_location('Leaving:'||l_proc, 20);
end set_root_process_activity_id;
-- ----------------------------------------------------------------------------
-- |--------------------< set_root_form_activity_id >-------------------------|
-- ----------------------------------------------------------------------------
procedure set_root_form_activity_id
  (p_process_item_type in varchar2
  ,p_root_process_name in varchar2) is
  -- cursor select the Process Activity ID of the activity
  -- ROOT_TASKFLOW_FORM_SELECTOR
  cursor l_get_instance_id is
    select wpa.instance_id
    from   wf_process_activities wpa
    where  wpa.process_version =
         (select max(wpa1.process_version)
          from   wf_process_activities wpa1
          where  wpa1.process_name      = wpa.process_name
          and    wpa1.process_item_type = wpa.process_item_type)
    and    wpa.process_item_type = p_process_item_type
    and    wpa.process_name      = p_root_process_name
    and    wpa.activity_name     = g_root_taskflow_form_sel;
  -- retrieve the transitions for the given instance id and where the
  -- transition is not a default value
  cursor l_get_root_instance_id(c_instance_id number) is
    select wat.to_process_activity
          ,wat.result_code
    from   wf_activity_transitions wat
    where  wat.result_code <> g_default_transition_value
    and    wat.from_process_activity = c_instance_id;
  --
  l_proc varchar2(72) := g_package||'set_root_form_activity_id';
  l_instance_id number;
  l_index       number := 0;
  l_result_code wf_activity_transitions.result_code%type;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  -- get the instance_id of the ROOT_TASKFLOW_FORM_SELECTOR
  -- the reason a for loop is used is to check that one and only
  -- only ROOT_TASKFLOW_FORM_SELECTOR exists
  for l_csr in l_get_instance_id loop
    -- incrment the counter
    l_index := l_index + 1;
    if l_index > 1 then
      hr_utility.set_location(l_proc, 15);
      -- exit out of the loop if more than one row is returned
      exit;
    else
      -- set the instance id
      l_instance_id := l_csr.instance_id;
    end if;
  end loop;
  hr_utility.set_location(l_proc, 20);
  --
  if l_index = 0 then
    -- a root selector does not exist for the process
    -- select the root process details that is in error
    get_item_act_display_names
      (p_instance_id            => g_root_process_id
      ,p_item_type_display_name => g_item_type_display_name
      ,p_activity_display_name  => g_activity_display_name
      ,p_process_display_name   => g_process_display_name);
    --
    fnd_message.set_name(g_hr_app, 'HR_52950_WKF2TSK_NO_ROOT_SEL');
    fnd_message.set_token(g_process_name, g_activity_display_name);
    fnd_message.set_token(g_item_type, g_item_type_display_name);
    fnd_message.raise_error;
  elsif l_index > 1 then
    -- more than one root selector exists error
    -- select the root process details that is in error
    get_item_act_display_names
      (p_instance_id            => g_root_process_id
      ,p_item_type_display_name => g_item_type_display_name
      ,p_activity_display_name  => g_activity_display_name
      ,p_process_display_name   => g_process_display_name);
    --
    fnd_message.set_name(g_hr_app, 'HR_52951_WKF2TSK_ROOT_SELS');
    fnd_message.set_token(g_process_name, g_activity_display_name);
    fnd_message.set_token(g_item_type, g_item_type_display_name);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc, 25);
  -- now that we have found the selector activity we must determine the
  -- root form
  l_index := 0;
  for l_csr in l_get_root_instance_id(l_instance_id) loop
    -- incrment the counter
    l_index := l_index + 1;
    if l_index > 1 then
      hr_utility.set_location(l_proc, 30);
      exit;
    else
      -- ensure that the activity selected is a form
      g_root_form_activity_id := l_csr.to_process_activity;
      l_result_code := l_csr.result_code;
    end if;
  end loop;
  hr_utility.set_location(l_proc, 35);
  --
  if l_index = 0 then
    -- the root form does not actually transition to a form so error
    -- select the root process details that is in error
    get_item_act_display_names
      (p_instance_id            => g_root_process_id
      ,p_item_type_display_name => g_item_type_display_name
      ,p_activity_display_name  => g_activity_display_name
      ,p_process_display_name   => g_process_display_name);
    --
    fnd_message.set_name(g_hr_app, 'HR_52952_WKF2TSK_ROOT_SEL_TRAN');
    fnd_message.set_token(g_process_name, g_activity_display_name);
    fnd_message.set_token(g_item_type, g_item_type_display_name);
    fnd_message.raise_error;
  elsif l_index > 1 then
    -- the root selector transitions to more than one form so error
    -- select the root process details that is in error
    get_item_act_display_names
      (p_instance_id            => g_root_process_id
      ,p_item_type_display_name => g_item_type_display_name
      ,p_activity_display_name  => g_activity_display_name
      ,p_process_display_name   => g_process_display_name);
    --
    fnd_message.set_name(g_hr_app, 'HR_52953_WKF2TSK_ROOT_SEL_TRAS');
    fnd_message.set_token(g_process_name, g_activity_display_name);
    fnd_message.set_token(g_item_type, g_item_type_display_name);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc, 40);
  -- ensure that the activity selected is a form and the transition matches the activity name
  open g_get_process_activity(g_root_form_activity_id);
  fetch g_get_process_activity into g_process_activity_rec;
  if g_get_process_activity%notfound then
    close g_get_process_activity;
    -- the instance_id does not exist this is a serious internal error
    fnd_message.set_name(g_hr_app, 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', 'internal error');
    fnd_message.set_token('STEP','40');
    fnd_message.raise_error;
  end if;
  close g_get_process_activity;
  hr_utility.set_location(l_proc, 45);
  if g_process_activity_rec.activity_name <> l_result_code then
    -- the root transition does not match a sql form activity
    -- select the root process details that is in error
    get_item_act_display_names
      (p_instance_id            => g_root_process_id
      ,p_item_type_display_name => g_item_type_display_name
      ,p_activity_display_name  => g_activity_display_name
      ,p_process_display_name   => g_process_display_name);
    --
    fnd_message.set_name(g_hr_app, 'HR_52954_WKF2TSK_ROOT_WRN_SEL');
    fnd_message.set_token(g_process_name, g_activity_display_name);
    fnd_message.set_token(g_item_type, g_item_type_display_name);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 50);
end set_root_form_activity_id;
-- ----------------------------------------------------------------------------
-- |---------------------< set_business_legislation >-------------------------|
-- ----------------------------------------------------------------------------
procedure set_business_legislation
  (p_business_group_id    in pay_customized_restrictions.business_group_id%type
  ,p_legislation_code     in pay_customized_restrictions.legislation_code%type
  ,p_legislation_subgroup in pay_customized_restrictions.legislation_subgroup%type) is
  --
  l_proc varchar2(72) := g_package||'set_business_legislation';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  g_business_group_id    := p_business_group_id;
  g_legislation_code     := p_legislation_code;
  g_legislation_subgroup := p_legislation_subgroup;
  hr_utility.set_location('Leaving:'||l_proc, 20);
end set_business_legislation;
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_workflow >-------------------------|
-- ----------------------------------------------------------------------------
procedure insert_workflow
  (p_process_name in varchar2) is
--
  cursor l_csr_workflow_id is
    select hw.workflow_id
    from   hr_workflows hw
    where  hw.workflow_name = p_process_name;
--
  cursor l_csr_nav_usages(c_workflow_id number) is
    select hnnu.nav_node_usage_id
    from   hr_navigation_node_usages hnnu
    where  hnnu.workflow_id = c_workflow_id;
--
  l_proc varchar2(72) := g_package||'insert_workflow';
  l_nav_path_id number;

  --  start of Bug 4506198

    l_nav_node_usage_id hr_navigation_node_usages.nav_node_usage_id%type;
     cursor l_csr_nav_paths(p_nav_id hr_navigation_node_usages.nav_node_usage_id%type) is
          select nav_path_id
          from hr_navigation_paths hnp
          where hnp.from_nav_node_usage_id = p_nav_id
          or hnp.to_nav_node_usage_id = p_nav_id;

-- end of bug 4506198
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  -- check to see if the workflow exists for the process name
  open l_csr_workflow_id;
  fetch l_csr_workflow_id into g_workflow_id;
  if l_csr_workflow_id%notfound then
    hr_utility.set_location(l_proc, 15);
    -- select the sequence
    begin
      select hr_workflows_s.nextval
      into   g_workflow_id
      from   sys.dual;
    exception
      when others then
        fnd_message.set_name(g_hr_app, 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
    end;
    hr_utility.set_location(l_proc, 20);
    -- the workflow does not exist so create it
    insert into hr_workflows (workflow_id, workflow_name) values (g_workflow_id, p_process_name);
    g_workflow_process_mode := 'INSERT';
  else
    hr_utility.set_location(l_proc, 25);
    -- set the workflow process mode to UPDATE
    g_workflow_process_mode := 'UPDATE';
    -- as we are updating the workflow we must delete the navigation paths
    -- and current workflow node usages
    for csr_csr in l_csr_nav_usages(g_workflow_id) loop
      -- delete the paths

    -- start of bug 4506198
       /*select nav_path_id
      into   l_nav_path_id
      from hr_navigation_paths hnp
      where hnp.from_nav_node_usage_id = csr_csr.nav_node_usage_id
      or    hnp.to_nav_node_usage_id = csr_csr.nav_node_usage_id; */

      l_nav_node_usage_id:=csr_csr.nav_node_usage_id;
      for csr_paths in l_csr_nav_paths(l_nav_node_usage_id) loop

      delete from hr_navigation_paths_tl hnp
      where       nav_path_id = csr_paths.nav_path_id;

      delete from hr_navigation_paths hnp
      where hnp.from_nav_node_usage_id = csr_csr.nav_node_usage_id
      or    hnp.to_nav_node_usage_id = csr_csr.nav_node_usage_id;

      end loop;

      delete from hr_navigation_paths_tl hnp
      where  nav_path_id = l_nav_path_id;

      delete from hr_navigation_paths hnp
      where hnp.from_nav_node_usage_id = csr_csr.nav_node_usage_id
      or    hnp.to_nav_node_usage_id = csr_csr.nav_node_usage_id;
      -- delete the usage
      delete from hr_navigation_node_usages hnnu
      where hnnu.nav_node_usage_id = csr_csr.nav_node_usage_id;
    end loop;
  end if;
  hr_utility.set_location(l_proc, 30);
  close l_csr_workflow_id;
  hr_utility.set_location('Leaving:'||l_proc, 35);
end insert_workflow;
-- ----------------------------------------------------------------------------
-- |----------------------< insert_navigation_paths >-------------------------|
-- ----------------------------------------------------------------------------
procedure insert_navigation_paths is
  -- --------------------------------------------------------------------------
  -- |-------------------------< private cursors >----------------------------|
  -- --------------------------------------------------------------------------
  cursor csr_process_start_transitions
    (c_instance_id wf_process_activities.instance_id%type) is
    -- select the START result codes
    select wat.from_process_activity
          ,wat.to_process_activity
          ,wat.result_code
    from   wf_process_activities   wpa1
          ,wf_process_activities   wpa2
          ,wf_activity_transitions wat
    where  wpa1.instance_id       = c_instance_id
    and    wpa2.process_name      = wpa1.activity_name
    and    wpa2.process_item_type = wpa1.activity_item_type
    and    wpa2.start_end         = g_activity_type_start
    and    wpa2.process_version =
           (select max(wpa3.process_version)
            from   wf_process_activities wpa3
            where  wpa3.process_name      = wpa2.process_name
            and    wpa3.process_item_type = wpa2.process_item_type)
    and    wat.from_process_activity = wpa2.instance_id;
  --
  cursor csr_process_end_transitions
    (c_instance_id wf_process_activities.instance_id%type
    ,c_result_code wf_activity_transitions.result_code%type) is
    -- select the END result codes
    select wat.from_process_activity
          ,wat.to_process_activity
          ,wat.result_code
    from   wf_process_activities   wpa1
          ,wf_process_activities   wpa2
          ,wf_activity_transitions wat
    where  wpa1.instance_id        = c_instance_id
    and    wpa1.start_end          = g_activity_type_end
    and    wpa2.activity_name      = wpa1.process_name
    and    wpa2.activity_item_type = wpa1.process_item_type
    and    wpa2.process_version =
           (select max(wpa3.process_version)
            from   wf_process_activities wpa3
            where  wpa3.process_name      = wpa2.process_name
            and    wpa3.process_item_type = wpa2.process_item_type)
    and    wat.from_process_activity = wpa2.instance_id
    and    wat.result_code           = c_result_code;
  --
  cursor csr_transitions(c_instance_id number) is
    -- selects the transition information for the specified activity
    -- instance
    select wat.from_process_activity
          ,wat.to_process_activity
          ,wat.result_code
    from   wf_activity_transitions wat
    where  wat.from_process_activity = c_instance_id;
  --
  cursor csr_transitions1(c_instance_id number) is
      -- selects the transition information for the specified activity
      -- instance
      select wat.from_process_activity
            ,wat.to_process_activity
            ,wat.result_code
      from   wf_activity_transitions wat
    where  wat.from_process_activity = c_instance_id;
  -- selects an activity type and start_end value for a specified
  -- activity instance
  cursor csr_attivity_type(c_instance_id number) is
    select wa.type
          ,wpa.start_end
    from   wf_activities wa
          ,wf_process_activities wpa
    where  wpa.instance_id = c_instance_id
    and    wa.item_type = wpa.activity_item_type
    and    wa.name      = wpa.activity_name
    and    wa.end_date is null;

/*--  Chages start for the bug 5702720  ---*/
  Cursor csr_language_code(T_NAV_PATH_ID number) is
    select L.language_code l_language_code
      from   FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
    (select NULL
    from HR_NAVIGATION_PATHS_TL T
    where T.NAV_PATH_ID = T_NAV_PATH_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
/*--  Chages End for the bug 5702720  ---*/
  --
  -- --------------------------------------------------------------------------
  -- |-----------------------< private variables >----------------------------|
  -- --------------------------------------------------------------------------
  l_proc varchar2(72) := g_package||'insert_navigation_paths';
  l_expected_sqlform          varchar2(30);
  l_activity_type             varchar2(30);
  l_found_form                boolean;
  l_return_to_root            boolean;
  l_dummy                     boolean;
  l_current_language          varchar2(3);
  l_nav_path_id               number;
  l_pop_from_process_activity wf_activity_transitions.from_process_activity%type;
  l_pop_to_process_activity   wf_activity_transitions.to_process_activity%type;
  l_pop_result_code           wf_activity_transitions.result_code%type;
  -- define structure types
  type l_result_stack_rec  is record
    (from_process_activity wf_activity_transitions.from_process_activity%type
    ,to_process_activity   wf_activity_transitions.to_process_activity%type
    ,result_code           wf_activity_transitions.result_code%type);
  type l_insert_path_rec   is record
    (from_nav_node_usage_id hr_navigation_paths.from_nav_node_usage_id%type
    ,to_nav_node_usage_id   hr_navigation_paths.to_nav_node_usage_id%type
    ,nav_button_required    hr_navigation_paths.nav_button_required%type
    ,sequence               hr_navigation_paths.sequence%type
    ,override_label         hr_navigation_paths.override_label%type
    ,result_code            wf_activity_transitions.result_code%type
    ,insert_path            boolean
    );
  type l_parent_rec        is record
   (from_nav_node_usage_id hr_navigation_paths.from_nav_node_usage_id%type
   ,to_nav_node_usage_id   hr_navigation_paths.to_nav_node_usage_id%type
   ,sequence               hr_navigation_paths.sequence%type
   ,parent_index           number);
  type l_visit_list_tab    is table of
                           wf_activity_transitions.from_process_activity%type
                           index by binary_integer;
  type l_result_stack_tab  is table of l_result_stack_rec
                           index by binary_integer;
  type l_insert_path_tab   is table of l_insert_path_rec
                           index by binary_integer;
  type l_parent_tab        is table of l_parent_rec
                           index by binary_integer;
  -- define the structures
  l_result_stack_struct    l_result_stack_tab;
  l_visit_list_struct      l_visit_list_tab;
  l_insert_path_struct     l_insert_path_tab;
  l_parent_struct          l_parent_tab;

  -- --------------------------------------------------------------------------
  --                      PRIVATE PROCEDURES AND FUNCTIONS                   --
  -- --------------------------------------------------------------------------
  -- |-----------------------< push_result_stack >----------------------------|
  -- --------------------------------------------------------------------------
  procedure push_result_stack
    (p_from_process_activity in wf_activity_transitions.from_process_activity%type
    ,p_to_process_activity   in wf_activity_transitions.to_process_activity%type
    ,p_result_code           in wf_activity_transitions.result_code%type) is
  --
    l_index binary_integer := l_result_stack_struct.count + 1;
    l_proc varchar2(72) := g_package||'push_result_stack';
  --
  begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    l_result_stack_struct(l_index).from_process_activity := p_from_process_activity;
    l_result_stack_struct(l_index).to_process_activity := p_to_process_activity;
    l_result_stack_struct(l_index).result_code := p_result_code;
    hr_utility.set_location('Leaving:'||l_proc, 20);
  end push_result_stack;
  -- --------------------------------------------------------------------------
  -- |--------------------------< pop_result_stack >--------------------------|
  -- --------------------------------------------------------------------------
  procedure pop_result_stack
    (p_from_process_activity out nocopy wf_activity_transitions.from_process_activity%type
    ,p_to_process_activity   out nocopy wf_activity_transitions.to_process_activity%type
    ,p_result_code           out nocopy wf_activity_transitions.result_code%type) is
  --
    l_proc varchar2(72) := g_package||'pop_result_stack';
  --
begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    if l_result_stack_struct.count < 1 then
      hr_utility.set_location(l_proc, 15);
      -- the stack is empty so return nulls
      p_from_process_activity := null;
      p_to_process_activity := null;
      p_result_code := null;
    else
      hr_utility.set_location(l_proc, 20);
      -- pop the last entry
      p_from_process_activity :=
        l_result_stack_struct(l_result_stack_struct.last).from_process_activity;
      p_to_process_activity :=
        l_result_stack_struct(l_result_stack_struct.last).to_process_activity;
      p_result_code :=
        l_result_stack_struct(l_result_stack_struct.last).result_code;
      -- delete the last stack entry
      l_result_stack_struct.delete(l_result_stack_struct.last);
    end if;
    hr_utility.set_location('Leaving:'||l_proc, 25);
  end pop_result_stack;
  -- --------------------------------------------------------------------------
  -- |---------------------------< zap_result_stack >-------------------------|
  -- --------------------------------------------------------------------------
  procedure zap_result_stack is
    l_proc varchar2(72) := g_package||'zap_result_stack';
  begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    l_result_stack_struct.delete;
    hr_utility.set_location('Leaving:'||l_proc, 20);
  end zap_result_stack;
  -- --------------------------------------------------------------------------
  -- |---------------------------< exist_in_visit_list >----------------------|
  -- --------------------------------------------------------------------------
  function exist_in_visit_list
    (p_from_process_activity in wf_activity_transitions.from_process_activity%type)
  return boolean is
    l_proc varchar2(72) := g_package||'exist_in_visit_list';
    l_return boolean := false;
  begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    if l_visit_list_struct.count > 0 then
      hr_utility.set_location('Entering:'||l_proc, 15);
      for i in l_visit_list_struct.first..l_visit_list_struct.last loop
        if l_visit_list_struct(i) = p_from_process_activity then
          hr_utility.set_location(l_proc, 20);
          l_return := true;
          exit;
        end if;
      end loop;
    end if;
    hr_utility.set_location('Leaving:'||l_proc, 25);
    return(l_return);
  end exist_in_visit_list;
  -- --------------------------------------------------------------------------
  -- |---------------------------< set_visit_activity  >----------------------|
  -- --------------------------------------------------------------------------
  function set_visit_activity
    (p_from_process_activity in wf_activity_transitions.from_process_activity%type)
  return boolean is
    l_proc varchar2(72) := g_package||'set_visit_activity';
    l_return boolean := false;
  begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    -- if the activity doesn't already exist in the visit list the
    -- add it
    if not exist_in_visit_list(p_from_process_activity) then
      hr_utility.set_location(l_proc, 15);
      l_visit_list_struct(l_visit_list_struct.count + 1) := p_from_process_activity;
      l_return := true;
    end if;
    hr_utility.set_location('Leaving:'||l_proc, 20);
    return(l_return);
  end set_visit_activity;
  -- --------------------------------------------------------------------------
  -- |--------------------------< zap_visit_list >----------------------------|
  -- --------------------------------------------------------------------------
  procedure zap_visit_list is
    l_proc varchar2(72) := g_package||'zap_visit_list';
  begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    l_visit_list_struct.delete;
    hr_utility.set_location('Leaving:'||l_proc, 20);
  end zap_visit_list;
  -- --------------------------------------------------------------------------
  -- |-------------------------< get_button_details >-------------------------|
  -- --------------------------------------------------------------------------
  procedure get_button_details
    (p_from_process_activity  in     number
    ,p_to_process_activity    in     number
    ,p_from_nav_node_usage_id in     number
    ,p_to_nav_node_usage_id   in     number
    ,p_index                  in     number
    ,p_override_label            out nocopy varchar2
    ,p_sequence                  out nocopy number
    ,p_nav_button_required       out nocopy varchar2) is
  --
    l_proc varchar2(72) := g_package||'get_button_details';
  --
  cursor csr_button_values(c_form_name varchar2) is
    -- selects DISPLAY_BUTTONx name for the specified process activity
    -- and where the form_name is the same or is a form_name does not
    -- exist check to see if a parent has been specified
    select waav.name
          ,waav.text_value
    from   wf_activity_attr_values waav
    where  waav.process_activity_id = p_from_process_activity
    and    waav.name like 'DISPLAY_BUTTON_'
    and   (waav.text_value = c_form_name
    or     waav.text_value = g_parent_transition);
  --
    l_nav_button_required hr_navigation_paths.nav_button_required%type := 'N';
    l_name                wf_activity_attr_values.name%type;
    l_sqlform             hr_navigation_units.form_name%type;
    l_parent              boolean := false;
    l_index               binary_integer;
  --
  begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    -- get the sqlform we are going to
    l_sqlform := get_sqlform(p_to_process_activity);
    -- determine the location of the button in the from process activity
    -- attributes
    for csr_csr in csr_button_values(l_sqlform) loop
      l_name                := csr_csr.name;
      if csr_csr.text_value = l_sqlform then
        -- we have found the button so we must display it
        l_parent              := false;
        l_nav_button_required := 'Y';
        exit;
      else
        -- we have found a parent
        l_parent := true;
      end if;
    end loop;
    -- check to see if only a parent was found
    if l_parent then
       l_index := l_parent_struct.count + 1;
       -- because the button could be a parent we must add to the parent list
       -- for further processing
       l_parent_struct(l_index).from_nav_node_usage_id :=
         p_from_nav_node_usage_id;
       l_parent_struct(l_index).to_nav_node_usage_id :=
         p_to_nav_node_usage_id;
       l_parent_struct(l_index).sequence :=
         to_number(replace(l_name,'DISPLAY_BUTTON',null));
       l_parent_struct(l_index).parent_index := p_index;
    end if;
    -- set the p_nav_button_required out var
    p_nav_button_required := l_nav_button_required;
    -- set the p_sequence var
    if l_nav_button_required = 'Y' then
      p_sequence := to_number(replace(l_name,'DISPLAY_BUTTON',null));
    else
      p_sequence := 5;
    end if;
    -- set the override label
    p_override_label := get_override_label(p_to_process_activity);
    hr_utility.set_location('Leaving:'||l_proc, 20);
  end get_button_details;
  -- --------------------------------------------------------------------------
  -- |---------------------< correct_parent_buttons >-------------------------|
  -- --------------------------------------------------------------------------
  procedure correct_parent_buttons is
    l_proc varchar2(72) := g_package||'correct_parent_buttons';
  begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    if l_parent_struct.count > 0 then
      for i in l_parent_struct.first..l_parent_struct.last loop
        for j in l_insert_path_struct.first..l_insert_path_struct.last loop
          if l_insert_path_struct(j).from_nav_node_usage_id =
            l_parent_struct(i).to_nav_node_usage_id and
            l_insert_path_struct(j).to_nav_node_usage_id =
            l_parent_struct(i).from_nav_node_usage_id then
            -- parent does exist
            l_insert_path_struct(l_parent_struct(i).parent_index).sequence
              := l_parent_struct(i).sequence;
            if l_parent_struct(i).sequence < 5 then
              l_insert_path_struct(l_parent_struct(i).parent_index).nav_button_required
                := 'Y';
              exit;
            else
              l_insert_path_struct(l_parent_struct(i).parent_index).nav_button_required
                := 'N';
            end if;
          end if;
        end loop;
      end loop;
    end if;
    hr_utility.set_location('Leaving:'||l_proc, 20);
  end correct_parent_buttons;
  -- --------------------------------------------------------------------------
  -- |----------------------------< set_insert_path >-------------------------|
  -- --------------------------------------------------------------------------
  procedure set_insert_path
    (p_from_nav_node_usage_id     in number
    ,p_from_process_activity      in number
    ,p_to_process_activity        in number
    ,p_result_code                in varchar2) is
  --
    l_proc varchar2(72) := g_package||'set_insert_path';
    l_button_text           varchar2(40);
    l_button_sequence       number := g_max_button_sequence_value;
    l_max_number_of_buttons number := g_max_number_of_buttons;
    l_nav_button_required   varchar2(1);
    l_number_of_paths       number := 0;
    l_max_display_sequence  number := 0;
    l_max_display_seq_index number := 0;
    l_index                 binary_integer;
    l_insert_path           boolean;
    l_to_nav_node_usage_id  number;
  begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    -- determine if the path is navigating back to the root form
    l_to_nav_node_usage_id := get_nav_node_usage_id(p_to_process_activity);
    if p_to_process_activity = g_root_form_activity_id then
      -- ok navigating back to the root so create the path
      l_insert_path := false;
    else
      l_insert_path := true;
    end if;
    -- the path is not going 2 the root activity so determine the path
    if l_insert_path_struct.count > 0 then
      -- ensure that an entry does not already exist for this form and
      -- result combination. also count the number of navigation paths
      for i in l_insert_path_struct.first..l_insert_path_struct.last loop
        if l_insert_path_struct(i).from_nav_node_usage_id =
          p_from_nav_node_usage_id then
          hr_utility.set_location(l_proc, 15);
          if l_insert_path_struct(i).result_code = p_result_code or
            l_insert_path_struct(i).to_nav_node_usage_id = l_to_nav_node_usage_id then
            -- a serious error has occurred, you cannot have a 'FROM' form activity
            -- have more than one path to the same form.
            -- select the process details that is in error
            get_item_act_display_names
              (p_instance_id            => p_from_process_activity
              ,p_item_type_display_name => g_item_type_display_name
              ,p_activity_display_name  => g_activity_display_name
              ,p_process_display_name   => g_process_display_name);
            -- get the TO_FORM_ACTIVITY details
            fnd_message.set_name(g_hr_app, 'HR_52955_WKF2TSK_SAME_SQLFORM');
            fnd_message.set_token(g_process_name, g_process_display_name);
            fnd_message.set_token(g_item_type, g_item_type_display_name);
            fnd_message.set_token(g_from_form_activity, g_activity_display_name);
            -- get the TO_FORM_ACTIVITY details
            get_item_act_display_names
              (p_instance_id            => p_to_process_activity
              ,p_item_type_display_name => g_item_type_display_name
              ,p_activity_display_name  => g_activity_display_name
              ,p_process_display_name   => g_process_display_name);
            --
            fnd_message.set_token(g_to_form_activity, g_item_type_display_name);
            fnd_message.raise_error;
          end if;
        end if;
      end loop;
    end if;
    l_index := l_insert_path_struct.count + 1;
    -- get the button details
    get_button_details
      (p_from_process_activity  => p_from_process_activity
      ,p_to_process_activity    => p_to_process_activity
      ,p_from_nav_node_usage_id => p_from_nav_node_usage_id
      ,p_to_nav_node_usage_id   => get_nav_node_usage_id(p_to_process_activity)
      ,p_index                  => l_index
      ,p_override_label         => l_button_text
      ,p_sequence               => l_button_sequence
      ,p_nav_button_required    => l_nav_button_required);
    --
    hr_utility.set_location(l_proc, 85);
    -- insert the path
    l_insert_path_struct(l_index).from_nav_node_usage_id := p_from_nav_node_usage_id;
    l_insert_path_struct(l_index).to_nav_node_usage_id := l_to_nav_node_usage_id;
    l_insert_path_struct(l_index).nav_button_required := l_nav_button_required;
    l_insert_path_struct(l_index).sequence := l_button_sequence;
    l_insert_path_struct(l_index).override_label := l_button_text;
    l_insert_path_struct(l_index).result_code := p_result_code;
    l_insert_path_struct(l_index).insert_path := l_insert_path;
    hr_utility.set_location('Leaving:'||l_proc, 90);
  end set_insert_path;
  -- --------------------------------------------------------------------------
  -- |---------------------------< get_activity_type >------------------------|
  -- --------------------------------------------------------------------------
  function get_activity_type
             (p_to_process_activity in number
             ,p_expected_sqlform    in varchar2) return varchar2 is
    -- return code:      description:
    -- CORRECT_SQLFORM
    -- INCORRECT_SQLFORM
    -- PROCESS
    -- END
    -- OTHER
    l_proc varchar2(72) := g_package||'get_activity_type';
    l_activity_type varchar2(30) := null;
    l_start_end     varchar2(30) := null;
  begin
    hr_utility.set_location('Entering:'||l_proc, 10);
    -- determine if the activity is in the corresponding usages table
    for i in g_node_usage_tab.first..g_node_usage_tab.last loop
      if g_node_usage_tab(i).instance_id = p_to_process_activity then
        hr_utility.set_location(l_proc, 15);
        -- the activity instance is a sql*form but is it the one we
        -- are looking for?
        if g_node_usage_tab(i).sqlform = p_expected_sqlform or
          p_expected_sqlform = g_default_transition_value or
          p_expected_sqlform = g_parent_transition then
          hr_utility.set_location(l_proc, 20);
          l_activity_type := 'CORRECT_SQLFORM';
        else
          hr_utility.set_location(l_proc, 25);
          l_activity_type := 'INCORRECT_SQLFORM';
        end if;
        --
        exit;
      end if;
    end loop;
    --
    hr_utility.set_location(l_proc, 30);
    if l_activity_type is null then
      hr_utility.set_location(l_proc, 35);
      -- the activity is not a sqlform so we must determine if it
      -- is a process, end activity or any other type of activity
      open csr_attivity_type(p_to_process_activity);
      fetch csr_attivity_type into l_activity_type, l_start_end;
      if csr_attivity_type%notfound then
        -- the activity does not exist. this is a serious internal
        -- error which we must report
        close csr_attivity_type;
        fnd_message.set_name(g_hr_app, 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      end if;
      close csr_attivity_type;
      hr_utility.set_location(l_proc, 40);
      -- check to see if the activity is not a PROCESS
      if l_activity_type <> g_activity_type_process then
        hr_utility.set_location(l_proc, 45);
        -- determine if the process is a function
        if l_activity_type = g_activity_type_function then
          -- as the activity type is a FUNCTION we must determine if
          -- it is an END function
          hr_utility.set_location(l_proc, 50);
          if l_start_end = g_activity_type_end then
            hr_utility.set_location(l_proc, 55);
            l_activity_type := l_start_end;
          end if;
        else
          hr_utility.set_location(l_proc, 60);
          -- set the activity to 'OTHER'
          l_activity_type := 'OTHER';
        end if;
      end if;
    end if;
    return(l_activity_type);
    hr_utility.set_location('Leaving:'||l_proc, 65);
  end get_activity_type;
-- ----------------------------------------------------------------------------
-- |------------------------------< MAIN BODY >-------------------------------|
-- ----------------------------------------------------------------------------
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  -- delete the parents table
  l_parent_struct.delete;
  -- loop through each inserted navigation node usage
  for l_usage_index in g_node_usage_tab.first..g_node_usage_tab.last loop
    -- determine if we are on the root node
    if g_node_usage_tab(l_usage_index).instance_id = g_root_form_activity_id then
      -- we are on the root node so we don't need to have a transition back
      -- to itself
      l_return_to_root := true;
    else
      -- we are NOT on the root node so we must have a transition back
      -- to the root
      l_return_to_root := false;
    end if;
    -- for each usage get the corresponding transition information
    for l_result_csr in csr_transitions
                            (g_node_usage_tab(l_usage_index).instance_id) loop
      -- set the expect sqlform
      l_expected_sqlform := l_result_csr.result_code;
      -- determine if the transition goes to the expected sql*form
      l_activity_type := get_activity_type
                           (l_result_csr.to_process_activity
                           ,l_expected_sqlform);
      -- branch on the activity type
      if l_activity_type = 'CORRECT_SQLFORM' then
        hr_utility.set_location(l_proc, 15);
        -- determine if the form we are navigation to is the root form
        if l_result_csr.to_process_activity = g_root_form_activity_id then
          -- ok we transition back to the root form so we must
          -- indicate this
          l_return_to_root := true;
        end if;
        -- the correct sql*form was found so we must insert it into the
        -- insert navigation path stack
        set_insert_path
          (p_from_nav_node_usage_id     =>
             g_node_usage_tab(l_usage_index).nav_node_usage_id
          ,p_from_process_activity      =>
             g_node_usage_tab(l_usage_index).instance_id
          ,p_to_process_activity        => l_result_csr.to_process_activity
          ,p_result_code                => l_expected_sqlform);
        --
      elsif l_activity_type = 'INCORRECT_SQLFORM' then
        -- an incorrect sql*form was found so we must error
            -- select the process details that is in error
            get_item_act_display_names
              (p_instance_id            => g_node_usage_tab(l_usage_index).instance_id
              ,p_item_type_display_name => g_item_type_display_name
              ,p_activity_display_name  => g_activity_display_name
              ,p_process_display_name   => g_process_display_name);
            -- get the TO_FORM_ACTIVITY details
            fnd_message.set_name(g_hr_app, 'HR_52956_WKF2TSK_WRONG_SQLFORM');
            fnd_message.set_token(g_process_name, g_process_display_name);
            fnd_message.set_token(g_item_type, g_item_type_display_name);
            fnd_message.set_token(g_from_form_activity, g_activity_display_name);
            -- get the TO_FORM_ACTIVITY details
            get_item_act_display_names
              (p_instance_id            => l_result_csr.to_process_activity
              ,p_item_type_display_name => g_item_type_display_name
              ,p_activity_display_name  => g_activity_display_name
              ,p_process_display_name   => g_process_display_name);
            --
            fnd_message.set_token(g_to_form_activity, g_item_type_display_name);
            fnd_message.raise_error;
      else
        hr_utility.set_location(l_proc, 20);
        -- delete the results stack
        zap_result_stack;
        hr_utility.set_location(l_proc, 25);
        -- delete the visit list
        zap_visit_list;
        -- set found form to false
        l_found_form := false;
        -- add activity to visit list
        l_dummy := set_visit_activity(g_node_usage_tab(l_usage_index).instance_id);
        hr_utility.set_location(l_proc, 30);
        -- push onto results stack
        push_result_stack
          (g_node_usage_tab(l_usage_index).instance_id
          ,l_result_csr.to_process_activity
          ,l_result_csr.result_code);
        hr_utility.set_location(l_proc, 35);
        -- while the stack is not empty loop
        while l_result_stack_struct.count > 0 loop
          -- pop the result stack
          pop_result_stack
            (l_pop_from_process_activity
            ,l_pop_to_process_activity
            ,l_pop_result_code);
          -- does the activty goto the expect form?
          l_activity_type := get_activity_type
                               (l_pop_to_process_activity
                               ,l_expected_sqlform);
          if l_activity_type = 'CORRECT_SQLFORM' then
            hr_utility.set_location(l_proc, 40);
            -- ok we transition back to the root form so we must
            -- indicate this
            if l_pop_to_process_activity = g_root_form_activity_id then
              l_return_to_root := true;
            end if;
            -- the correct sql*form was found so we must insert it into the
            -- insert navigation path stack
            set_insert_path
              (g_node_usage_tab(l_usage_index).nav_node_usage_id
              ,g_node_usage_tab(l_usage_index).instance_id
              ,l_pop_to_process_activity
              ,l_expected_sqlform);
            l_found_form := true;
          elsif l_activity_type = 'INCORRECT_SQLFORM' then
            -- an incorrect sql*form was found so we must error
            -- select the process details that is in error
            get_item_act_display_names
              (p_instance_id            => g_node_usage_tab(l_usage_index).instance_id
              ,p_item_type_display_name => g_item_type_display_name
              ,p_activity_display_name  => g_activity_display_name
              ,p_process_display_name   => g_process_display_name);
            -- get the TO_FORM_ACTIVITY details
            fnd_message.set_name(g_hr_app, 'HR_52956_WKF2TSK_WRONG_SQLFORM');
            fnd_message.set_token(g_process_name, g_process_display_name);
            fnd_message.set_token(g_item_type, g_item_type_display_name);
            fnd_message.set_token(g_from_form_activity, g_activity_display_name);
            -- get the TO_FORM_ACTIVITY details
            get_item_act_display_names
              (p_instance_id            => l_pop_to_process_activity
              ,p_item_type_display_name => g_item_type_display_name
              ,p_activity_display_name  => g_activity_display_name
              ,p_process_display_name   => g_process_display_name);
            --
            fnd_message.set_token(g_to_form_activity, g_item_type_display_name);
            fnd_message.raise_error;
          elsif l_activity_type = 'PROCESS' then
            hr_utility.set_location(l_proc, 45);
            l_dummy := set_visit_activity(l_pop_to_process_activity);
            -- push each start activity results
            for csr_start in csr_process_start_transitions
                               (l_pop_to_process_activity) loop
              if not exist_in_visit_list(csr_start.to_process_activity) then
                hr_utility.set_location(l_proc, 50);
                push_result_stack
                  (csr_start.from_process_activity
                  ,csr_start.to_process_activity
                  ,csr_start.result_code);
              end if;
            end loop;
          elsif l_activity_type = g_activity_type_end then
            hr_utility.set_location(l_proc, 55);
            l_dummy := set_visit_activity(l_pop_to_process_activity);
            for csr_end in csr_process_end_transitions
                             (l_pop_to_process_activity
                             ,l_pop_result_code) loop
              --
              push_result_stack
                (csr_end.from_process_activity
                ,csr_end.to_process_activity
                ,csr_end.result_code);
              --
            end loop;
          else
            hr_utility.set_location(l_proc, 60);
            if set_visit_activity(l_pop_to_process_activity) then
              hr_utility.set_location(l_proc, 65);
              for csr_results in csr_transitions1(l_pop_to_process_activity) loop
                if not exist_in_visit_list(csr_results.to_process_activity) then
                  hr_utility.set_location(l_proc, 70);
                  push_result_stack
                   (csr_results.from_process_activity
                   ,csr_results.to_process_activity
                   ,csr_results.result_code);
                end if;
              end loop;
            end if;
          end if;
        end loop;
      end if;
    end loop;
    -- determine if the form transitions back to the root form
    -- if it doesn't then error
    if not l_return_to_root then
      -- a corresponding transition back to the root form for the usage
      -- does not exist
      -- so we must report this
      get_item_act_display_names
        (p_instance_id            => g_node_usage_tab(l_usage_index).instance_id
        ,p_item_type_display_name => g_item_type_display_name
        ,p_activity_display_name  => g_activity_display_name
        ,p_process_display_name   => g_process_display_name);
      --
      fnd_message.set_name(g_hr_app, 'HR_52959_WKF2TSK_NO_ROOT');
      fnd_message.set_token(g_process_name, g_process_display_name);
      fnd_message.set_token(g_item_type, g_item_type_display_name);
      fnd_message.set_token(g_from_form_activity, g_activity_display_name);
      get_item_act_display_names
        (p_instance_id            => g_root_form_activity_id
        ,p_item_type_display_name => g_item_type_display_name
        ,p_activity_display_name  => g_activity_display_name
        ,p_process_display_name   => g_process_display_name);
      fnd_message.set_token(g_to_form_activity, g_activity_display_name);
      fnd_message.raise_error;
    end if;
  end loop;
  -- correct the parent buttons
  correct_parent_buttons;
  -- check to see if any paths exist
  if l_insert_path_struct.count > 0 then
    -- insert all the paths
    for i in l_insert_path_struct.first..l_insert_path_struct.last loop
      -- only insert paths where the boolean insert_path is true
      if l_insert_path_struct(i).insert_path then
        insert into hr_navigation_paths
        (nav_path_id
        ,from_nav_node_usage_id
        ,to_nav_node_usage_id
        ,nav_button_required
        ,sequence
        ,override_label)
        values
        (hr_navigation_paths_s.nextval
        ,l_insert_path_struct(i).from_nav_node_usage_id
        ,l_insert_path_struct(i).to_nav_node_usage_id
        ,l_insert_path_struct(i).nav_button_required
        ,l_insert_path_struct(i).sequence
        ,l_insert_path_struct(i).override_label
        );

  select nav_path_id
  into   l_nav_path_id
  from   hr_navigation_paths
  where  from_nav_node_usage_id = l_insert_path_struct(i).from_nav_node_usage_id
  and    to_nav_node_usage_id = l_insert_path_struct(i).to_nav_node_usage_id;

/*--  Chages start for the bug 5702720  ---*/
 hr_utility.set_location(l_proc, 6253);

  for I in csr_language_code(l_nav_path_id)
  loop
    hr_utility.set_location('In the Cursor csr_language_code= '||i.l_language_code, 6254);
    insert into hr_navigation_paths_tl (
        nav_path_id
       ,language
       ,source_lang
       ,override_label)
      select b.nav_path_id
            ,i.l_language_code
            ,userenv('LANG')
            ,b.override_label
      from hr_navigation_paths b
      where not exists
        (select '1'
         from hr_navigation_paths_tl t
         where t.nav_path_id = b.nav_path_id
       and t.language = i.l_language_code);
  end loop;
 hr_utility.set_location(l_proc, 6255);
/*--  Chages End for the bug 5702720  ---*/

/*  --- original code before fix 5702720 ---
    select L.language_code
    into   l_current_language
    from   FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
    (select NULL
    from HR_NAVIGATION_PATHS_TL T
    where T.NAV_PATH_ID = L_NAV_PATH_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

        insert into hr_navigation_paths_tl (
        nav_path_id
       ,language
       ,source_lang
       ,override_label)
      select b.nav_path_id
            ,l_current_language
            ,userenv('LANG')
            ,b.override_label
      from hr_navigation_paths b
      where not exists
        (select '1'
         from hr_navigation_paths_tl t
         where t.nav_path_id = b.nav_path_id
       and t.language = l_current_language);
    -- End Original code before fix 5702720 --    */
      end if;
    end loop;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 75);
end insert_navigation_paths;
-- ----------------------------------------------------------------------------
-- |-----------------< insert_navigation_node_usage >-------------------------|
-- ----------------------------------------------------------------------------
procedure insert_navigation_node_usage
  (p_nav_node_id    in number
  ,p_instance_id    in number
  ,p_sqlform        in varchar2
  ,p_override_label in varchar2) is
--
  l_top_node          varchar2(1) := 'N';
  l_nav_node_usage_id hr_navigation_node_usages.nav_node_usage_id%type;
  l_proc varchar2(72) := g_package||'insert_navigation_node_usage';
  l_index binary_integer;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  -- is the instance the root form activity?
  if p_instance_id = g_root_form_activity_id then
    hr_utility.set_location(l_proc, 15);
    l_top_node := 'Y';
  end if;
  -- select the sequence
  begin
    select hr_navigation_node_usages_s.nextval
    into   l_nav_node_usage_id
    from   sys.dual;
  exception
    when others then
      fnd_message.set_name(g_hr_app, 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
  end;
  hr_utility.set_location(l_proc, 20);
  -- insert the node usage
  insert into hr_navigation_node_usages
    (nav_node_usage_id,
     workflow_id,
     nav_node_id,
     top_node)
  values
    (l_nav_node_usage_id
    ,g_workflow_id
    ,p_nav_node_id
    ,l_top_node);
  -- insert the row into the pl/sql table
  l_index := g_node_usage_tab.count + 1;
  g_node_usage_tab(l_index).nav_node_usage_id := l_nav_node_usage_id;
  g_node_usage_tab(l_index).instance_id := p_instance_id;
  g_node_usage_tab(l_index).sqlform := p_sqlform;
  g_node_usage_tab(l_index).override_label := p_override_label;
  hr_utility.set_location('Leaving:'||l_proc, 25);
--
end insert_navigation_node_usage;
-- ----------------------------------------------------------------------------
-- |----------------------< insert_navigation_nodes >-------------------------|
-- ----------------------------------------------------------------------------
procedure insert_navigation_nodes
  (p_process_item_type   in varchar2
  ,p_process_name        in varchar2) is
--
  cursor l_csr_processes(c_instance_id wf_process_activities.instance_id%type) is
    select wpa1.instance_id
    from   wf_activities         wa
          ,wf_process_activities wpa1
          ,wf_process_activities wpa2
    where  wpa2.instance_id       = c_instance_id
    and    wpa1.process_name      = wpa2.activity_name
    and    wpa1.process_item_type = wpa2.activity_item_type
    and    wpa1.process_version   =
          (select max(wpa3.process_version)
           from   wf_process_activities wpa3
           where  wpa3.process_name = wpa1.process_name
           and    wpa3.process_item_type = wpa1.process_item_type)
    and    wa.name                = wpa1.activity_name
    and    wa.item_type           = wpa1.activity_item_type
    and    wa.type                = g_activity_type_process
    and    wa.end_date is null;
  --
  cursor l_csr_tf_form_activity
    (c_instance_id wf_process_activities.instance_id%type) is
    select wpa1.instance_id
    from   wf_activities           wa
          ,wf_process_activities   wpa1
          ,wf_process_activities   wpa2
          ,wf_activity_attr_values waav
          ,wf_activity_attributes  waa
    where  wpa2.instance_id         = c_instance_id
    and    wpa1.process_name        = wpa2.activity_name
    and    wpa1.process_item_type   = wpa2.activity_item_type
    and    wpa1.process_version   =
          (select max(wpa3.process_version)
           from   wf_process_activities wpa3
           where  wpa3.process_name = wpa1.process_name
           and    wpa3.process_item_type = wpa1.process_item_type)
    and    wa.name                  = wpa1.activity_name
    and    wa.item_type             = wpa1.activity_item_type
    and    wa.type                  = g_activity_type_function
    and    wa.end_date is null
    and    waav.process_activity_id = wpa1.instance_id
    and    waav.name                = waa.name
    and    waav.text_value          = g_hrms_sqlform
    and    waa.activity_item_type   = wa.item_type
    and    waa.activity_name        = wa.name
    and    waa.activity_version     = wa.version
    and    waa.name                 = g_taskflow_activity_type;
  --
  cursor l_csr_tf_form_attributes
    (c_instance_id wf_process_activities.instance_id%type) is
    select waa.name
          ,waav.text_value
    from   wf_activities           wa
          ,wf_process_activities   wpa1
          ,wf_activity_attr_values waav
          ,wf_activity_attributes  waa
    where  wpa1.instance_id         = c_instance_id
    and    wa.name                  = wpa1.activity_name
    and    wa.item_type             = wpa1.activity_item_type
    and    wa.type                  = g_activity_type_function
    and    wa.end_date is null
    and    waav.process_activity_id = wpa1.instance_id
    and    waav.name                = waa.name
    and    waav.name in ('TASKFLOW_ACTIVITY_NAME'
                        ,'CUSTOMIZATION_NAME'
                        ,'BUTTON_TEXT'
                        ,'HRMS_FORM_BLOCK_NAME')
    and    waa.activity_item_type   = wa.item_type
    and    waa.activity_name        = wa.name
    and    waa.activity_version     = wa.version
    and    exists
          (select 1
           from   wf_activity_attr_values waav1
           where  waav1.name       = g_taskflow_activity_type
           and    waav1.text_value = g_hrms_sqlform
           and    waav1.process_activity_id = waav.process_activity_id);
--
  cursor l_csr_nav_unit_id(c_form_name varchar2, c_block_name varchar2) is
    select hnu.nav_unit_id
          ,hnul.default_label
    from   hr_navigation_units hnu,
           hr_navigation_units_tl hnul
    where  hnu.form_name = c_form_name
    and    nvl(hnu.block_name, hr_api.g_varchar2) = nvl(c_block_name, hr_api.g_varchar2)
    and    hnu.nav_unit_id = hnul.nav_unit_id
    and    hnul.language=userenv('LANG');
--
  cursor l_csr_cust_restrict_id(c_form_name varchar2, c_customization_name varchar2) is
    select pcr.customized_restriction_id
    from   pay_customized_restrictions pcr
    where  pcr.form_name = c_form_name
    and    pcr.enabled_flag = 'Y'
    and    nvl(pcr.business_group_id, nvl(g_business_group_id, hr_api.g_number)) =
           nvl(g_business_group_id, hr_api.g_number)
    and    nvl(pcr.legislation_code, nvl(g_legislation_code, hr_api.g_varchar2)) =
           nvl(g_legislation_code, hr_api.g_varchar2)
    and    nvl(pcr.legislation_subgroup, nvl(g_legislation_subgroup, hr_api.g_varchar2)) =
           nvl(g_legislation_subgroup, hr_api.g_varchar2)
    and    pcr.application_id between 800 and 899
    and    pcr.name = c_customization_name;
--
  cursor l_csr_nav_node_id(c_nav_unit_id number, c_customized_restriction_id number) is
    select hnn.nav_node_id
          ,hnn.name
    from   hr_navigation_nodes hnn
    where  hnn.nav_unit_id = c_nav_unit_id
    and    nvl(hnn.customized_restriction_id, hr_api.g_number) =
           nvl(c_customized_restriction_id, hr_api.g_number);
--
  l_taskflow_actvity_name wf_activity_attr_values.text_value%type;
  l_customization_name    wf_activity_attr_values.text_value%type;
  l_taskflow_block_name   wf_activity_attr_values.text_value%type;
  l_nav_unit_id           hr_navigation_units.nav_unit_id%type;
  l_customized_restriction_id pay_customized_restrictions.customized_restriction_id%type;
  l_navigation_node_name  hr_navigation_nodes.name%type;
  l_nextval               number;
  l_nav_node_id           hr_navigation_nodes.nav_node_id%type;
  l_root_nav_node_id      hr_navigation_nodes.nav_node_id%type;
  l_proc                  varchar2(72) := g_package||'insert_navigation_nodes';
  l_override_label        hr_navigation_paths.override_label%type;
  l_default_label         hr_navigation_units.default_label%type;
  l_found_nav_node        boolean;
--
  type l_process_stack_tab is table of
                           wf_process_activities.instance_id%type
                           index by binary_integer;
  l_process_stack_struct   l_process_stack_tab;
  l_current_working_process_id wf_process_activities.instance_id%type;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- we need to select all the form activities within a process where the
  -- process is located within the specified root process.
  -- originally this was perceived as being a network/hierachy query but
  -- due to performance this mechasim has been abandoned (ideally this
  -- would the best solution, however, a new index would be required
  -- from workflow on the table wf_process_activities). so due to
  -- time constraints, a work around has been put in place which
  -- describes the processing logic in detail.
  --
  -- a stack is used to maintain a 'working' list of processes. the intial
  -- push value of the stack is the ROOT process itself. as a process
  -- is popped off the stack this process becomes the current working
  -- process. for the current working process a query selects any sub
  -- processes for the current process and pushes them onto the stack.
  -- next, all taskflow form activities are identified for the current
  -- working process and subsequent processing occurs. this process
  -- repeats itself until the stack is empty.
  --
  -- pseudo logic:
  --
  -- clear the stack
  -- push the root process onto the stack
  -- while the stack is not empty loop
  --   pop the stack into the current working process identifier
  --   select all sub processes for the current working process and push
  --   onto the stack
  --   for the current working process select all taskflow form actvities
  --     perform further processing
  --   end loop
  -- end loop
  --
  --
  l_process_stack_struct.delete; -- clear the process stack
  -- push the root process on the stack
  l_process_stack_struct(1) := g_root_process_id;
  while l_process_stack_struct.count > 0 loop
    -- pop the last element of the stack
    l_current_working_process_id :=
      l_process_stack_struct(l_process_stack_struct.last);
    l_process_stack_struct.delete(l_process_stack_struct.last);
    -- get all the subprocesses for the current working process
    for l_csr_sub_processes in
        l_csr_processes(l_current_working_process_id) loop
      -- push the selected sub process onto the stack
      l_process_stack_struct(l_process_stack_struct.count + 1) :=
        l_csr_sub_processes.instance_id;
    end loop;
    -- get all the taskflow form activities for the
    -- current working process and select the process activity attributes
    for l_csr_tf_function_activities in
        l_csr_tf_form_activity(l_current_working_process_id) loop
      -- clear the activity attribute values
      l_taskflow_actvity_name := null;
      l_customization_name := null;
      l_taskflow_block_name := null;
      l_nav_unit_id := null;
      l_customized_restriction_id := null;
      l_navigation_node_name := null;
      l_nav_node_id := null;
      for l_csr_attrs in
        l_csr_tf_form_attributes(l_csr_tf_function_activities.instance_id) loop
        -- we are interested in 4 attributes; TASKFLOW_ACTIVITY_NAME,
        -- CUSTOMIZATION_NAME, HRMS_FORM_BLOCK_NAME and BUTTON_TEXT
        if l_csr_attrs.name = 'TASKFLOW_ACTIVITY_NAME' then
          hr_utility.set_location(l_proc, 20);
          l_taskflow_actvity_name := l_csr_attrs.text_value;
        elsif l_csr_attrs.name = 'HRMS_FORM_BLOCK_NAME' then
          hr_utility.set_location(l_proc, 25);
          l_taskflow_block_name := upper(l_csr_attrs.text_value);
        elsif l_csr_attrs.name = 'BUTTON_TEXT' then
          l_override_label := substr(l_csr_attrs.text_value,1,40);
        else
          hr_utility.set_location(l_proc, 30);
          -- the attribute must be CUSTOMIZATION_NAME
          l_customization_name := l_csr_attrs.text_value;
        end if;
      end loop;
      hr_utility.set_location(l_proc, 40);
      -- ensure that a corresponding row exists within the HR_NAVIGATION_UNITS
      -- table.
      open l_csr_nav_unit_id(l_taskflow_actvity_name, l_taskflow_block_name);
      fetch l_csr_nav_unit_id into l_nav_unit_id, l_default_label;
      if l_csr_nav_unit_id%notfound then
        close l_csr_nav_unit_id;
        -- a corresponding navigation unit does not exist
        -- this is a serious error which we must raise and report
        get_item_act_display_names
          (p_instance_id            => l_csr_tf_function_activities.instance_id
          ,p_item_type_display_name => g_item_type_display_name
          ,p_activity_display_name  => g_activity_display_name
          ,p_process_display_name   => g_process_display_name);
        --
        fnd_message.set_name(g_hr_app, 'HR_52957_WKF2TSK_INC_SQLFORM');
        fnd_message.set_token('ACTIVITY_NAME', g_activity_display_name);
        fnd_message.set_token(g_process_name, g_process_display_name);
        fnd_message.set_token(g_item_type, g_item_type_display_name);
        fnd_message.raise_error;
      end if;
      close l_csr_nav_unit_id;
      -- the activity was a TF function activity so we must now determine
      -- if the customization is valid
      if l_customization_name is not null then
        hr_utility.set_location(l_proc, 45);
        open l_csr_cust_restrict_id(l_taskflow_actvity_name, l_customization_name);
        fetch l_csr_cust_restrict_id into l_customized_restriction_id;
        if l_csr_cust_restrict_id%notfound then
          -- the customized name specified was not found so we must provide a warning
        -- [warning]
        l_customized_restriction_id := null;
        end if;
        close l_csr_cust_restrict_id;
      end if;
      hr_utility.set_location(l_proc, 50);
      -- set the navigation node name
      l_navigation_node_name := l_taskflow_actvity_name;
      --
      l_found_nav_node := false;
      for csr_nodes in l_csr_nav_node_id(l_nav_unit_id, l_customized_restriction_id) loop
        l_found_nav_node := true;
        -- set the local nav node id and navigation node name
        l_nav_node_id := csr_nodes.nav_node_id;
        l_navigation_node_name := csr_nodes.name;
        -- check to see if the root form activity is being processed
        if g_root_form_activity_id = l_csr_tf_function_activities.instance_id then
          -- set the root nav node
          l_root_nav_node_id := csr_nodes.nav_node_id;
        end if;
        -- check to see if we are using the root node but not in the context of
        -- the root activity
        if csr_nodes.nav_node_id = l_root_nav_node_id and
          g_root_form_activity_id <> l_csr_tf_function_activities.instance_id then
          -- we cannot use this navigation node as it is already being used
          -- so loop again
          l_found_nav_node := false;
        end if;
        -- exit the loop if row found
        if l_found_nav_node then
          exit;
        end if;
      end loop;
      -- was a nav node found?
      if not l_found_nav_node then
        hr_utility.set_location(l_proc, 55);
        -- derive a new name
        begin
          select hr_navigation_nodes_s.nextval
          into   l_nextval
          from   sys.dual;
        exception
          when others then
            fnd_message.set_name(g_hr_app, 'HR_6153_ALL_PROCEDURE_FAIL');
            fnd_message.set_token('PROCEDURE', l_proc);
            fnd_message.set_token('STEP','10');
            fnd_message.raise_error;
        end;
        hr_utility.set_location(l_proc, 60);
        l_navigation_node_name := l_taskflow_actvity_name||l_nextval;
        -- the navigation node does not exist so we need to insert it
        insert into hr_navigation_nodes
          (nav_node_id,
           nav_unit_id,
           name,
           customized_restriction_id)
        values
          (l_nextval
          ,l_nav_unit_id
          ,l_navigation_node_name
          ,l_customized_restriction_id);
      end if;
      hr_utility.set_location(l_proc, 65);
      -- insert a node usage
      insert_navigation_node_usage
        (p_nav_node_id    => l_nav_node_id
        ,p_instance_id    => l_csr_tf_function_activities.instance_id
        ,p_sqlform        => l_taskflow_actvity_name
        ,p_override_label => nvl(l_override_label, l_default_label));
    end loop;
  end loop;
  hr_utility.set_location('Leaving:'||l_proc, 70);
end insert_navigation_nodes;
-- ----------------------------------------------------------------------------
-- |----------------------------< transfer_workflow >-------------------------|
-- ----------------------------------------------------------------------------
procedure transfer_workflow
 (p_process_item_type    in varchar2
 ,p_root_process_name    in varchar2 default null
 ,p_business_group_id    in number   default null
 ,p_legislation_code     in varchar2 default null
 ,p_legislation_subgroup in varchar2 default null) is
--
  l_proc         varchar2(72) := g_package||'transfer_workflow';
  l_item_type    wf_items.item_type%type := upper(p_process_item_type);
  l_process_name wf_items.root_activity%type := upper(p_root_process_name);
  l_found        boolean := false;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  -- ensure that the item type has been set
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'process_item_type'
    ,p_argument_value => p_process_item_type);
  -- set the language code
  begin
    select userenv('LANG')
    into   g_language
    from   sys.dual;
  exception
    when others then
    -- error lang does not exist
    fnd_message.set_name(g_hr_app, 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  end;
  -- set the business legislation
  set_business_legislation
    (p_business_group_id    => p_business_group_id
    ,p_legislation_code     => p_legislation_code
    ,p_legislation_subgroup => p_legislation_subgroup);
  -- reset the number of converted processes
  g_converted_processes := 0;
  --
  for l_csr_root in g_csr_root_runnable_process
                      (l_item_type, l_process_name) loop
    l_found := true;
    -- clear the usages table
    g_node_usage_tab.delete;
    hr_utility.set_location(l_proc, 20);
    -- check and set the root process specified is valid
    set_root_process_activity_id
      (p_process_item_type => l_item_type
      ,p_root_process_name => l_csr_root.activity_name);
    -- set the root form activity
    set_root_form_activity_id
      (p_process_item_type => l_item_type
      ,p_root_process_name => l_csr_root.activity_name);
    hr_utility.set_location(l_proc, 25);
    -- insert the workflow
    insert_workflow
      (p_process_name => l_csr_root.activity_name);
    hr_utility.set_location(l_proc, 30);
    -- insert the navigation nodes
    insert_navigation_nodes
      (p_process_item_type => l_item_type
      ,p_process_name      => l_csr_root.activity_name);
    hr_utility.set_location(l_proc, 35);
    -- insert the navigation paths
    insert_navigation_paths;
    -- increment the converted processes counter
    g_converted_processes := g_converted_processes + 1;
  end loop;
  -- check to see if process name was specified and if it was found
  if NOT l_found and p_root_process_name is not null then
    -- error the root process specified does not exist
    fnd_message.set_name(g_hr_app, 'HR_52958_WKF2TSK_INC_PROCESS');
    fnd_message.set_token(g_item_type, g_item_type_display_name);
    fnd_message.set_token(g_process_name, p_root_process_name);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 40);
end transfer_workflow;
-- ----------------------------------------------------------------------------
-- |--------------------------< call_taskflow_form >--------------------------|
-- ----------------------------------------------------------------------------
procedure call_taskflow_form
 (itemtype in     varchar2
 ,itemkey  in     varchar2
 ,actid    in     number
 ,funmode  in     varchar2
 ,result      out nocopy varchar2) is
--
  cursor l_csr_tf_form is
    select 1
    from   wf_process_activities   wpa
          ,wf_activity_attr_values waav
    where  wpa.instance_id          = actid
    and    waav.process_activity_id = wpa.instance_id
    and    waav.name                = g_taskflow_activity_type
    and    waav.text_value          = g_hrms_sqlform;
--
  l_proc   varchar2(72) := g_package||'call_taskflow_form';
  l_dummy number;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  -- check the workflow funmode value
  if funmode = 'RUN' then
    hr_utility.set_location(l_proc, 20);
    -- workflow is RUNing this procedure so ensure that the current
    -- process activity is defined as a taskflow SQL*Form and
    -- return a NOTIFIED value
    open l_csr_tf_form;
    fetch l_csr_tf_form into l_dummy;
    if l_csr_tf_form%notfound then
      hr_utility.set_location(l_proc, 30);
      close l_csr_tf_form;
      -- raise the error and let the outer exception handle the error
      raise no_data_found;
    end if;
    close l_csr_tf_form;
    --
    result := 'NOTIFIED:';
    hr_utility.set_location(l_proc, 40);
  elsif funmode = 'CANCEL' then
    hr_utility.set_location(l_proc, 50);
    -- workflow is calling in cancel mode (performing a loop reset) so ignore
    null;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 60);
exception
  when others then
    -- because we are being directly called from workflow return an ERROR
    -- result
    result := 'ERROR:';
    hr_utility.set_location('Leaving:'||l_proc, 70);
end call_taskflow_form;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_process_name >--------------------------|
-- ----------------------------------------------------------------------------
function chk_process_name
 (p_item_type    in varchar2
 ,p_process_name in varchar2)
 return boolean is
--
  l_proc   varchar2(72) := g_package||'chk_process_name';
  l_dummy  wf_process_activities.activity_name%type;
  l_return boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  -- ensure that the item type and process names are specified
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'item_type'
    ,p_argument_value => p_item_type);
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'process_name'
    ,p_argument_value => p_process_name);
  -- open the cursor
  open g_csr_root_runnable_process(upper(p_item_type), upper(p_process_name));
  fetch g_csr_root_runnable_process into l_dummy;
  if g_csr_root_runnable_process%notfound then
    hr_utility.set_location(l_proc, 20);
    l_return := false;
  else
    hr_utility.set_location(l_proc, 30);
    l_return := true;
  end if;
  close g_csr_root_runnable_process;
  hr_utility.set_location('Leaving:'||l_proc, 40);
  return(l_return);
end chk_process_name;
-- ----------------------------------------------------------------------------
-- |---------------------< get_converted_processes >--------------------------|
-- ----------------------------------------------------------------------------
function get_converted_processes return number is
begin
  return(g_converted_processes);
end get_converted_processes;
--
end hr_taskflow_workflow;

/
