--------------------------------------------------------
--  DDL for Package Body HR_WORKFLOW_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WORKFLOW_UTILITY" as
/* $Header: hrewuweb.pkb 120.1 2005/09/23 14:56:46 svittal noship $ */
  g_package     VARCHAR2(31)   := 'hr_workflow_utility_web.';
-- ----------------------------------------------------------------------------
-- |-------------------------< item_attribute_exists >------------------------|
-- ----------------------------------------------------------------------------
function item_attribute_exists
  (p_item_type in varchar2
  ,p_item_key  in varchar2
  ,p_name      in varchar2) return boolean is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_dummy  number(1);
  l_return boolean := true;
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
    l_return := false;
  end if;
  close csr_wiav;
  return(l_return);
end item_attribute_exists;

-- ----------------------------------------------------------------------
-- |----------------< get_activity_details >------------------------|
-- ----------------------------------------------------------------------
-- Private procedure to get the activity details for a given activity
-- instance
-- The details contain
--  p_display_name      Display Name
--  p_name              Activity Name
--  p_description       Description
PROCEDURE get_activity_details
  (p_actid          IN  wf_process_activities.instance_id%TYPE
  ,p_name               OUT NOCOPY wf_activities_tl.name%TYPE
  ,p_display_name   OUT NOCOPY wf_activities_tl.display_name%TYPE
  ,p_description    OUT NOCOPY wf_activities_tl.description%TYPE
  ,p_instance_label OUT NOCOPY wf_process_activities.instance_label%TYPE) is
  -- --------------------------------------------------------------------------
  -- local cursor definitions
  -- --------------------------------------------------------------------------
  -- csr_wf_activity_details    -> selects the activity details used by the
  --                   package for the given activity instance
  --
  CURSOR csr_wf_activity_details IS
    select wav.name
          ,wav.display_name
          ,wav.description
      ,wpa.instance_label
    from   wf_activities_vl      wav
          ,wf_process_activities wpa
    where  wav.item_type   = wpa.activity_item_type
    and    wav.name        = wpa.activity_name
    and    wpa.instance_id = p_actid
    and    wav.version =
          (select max(wav1.version)
           from   wf_activities_vl wav1
           where  wav1.item_type   = wpa.activity_item_type
           and    wav1.name        = wpa.activity_name);
  -- --------------------------------------------------------------------------
  -- local exception declerations
  -- --------------------------------------------------------------------------
  no_activity_details   exception;
  --
BEGIN
  -- Get the details for the given activity
  OPEN csr_wf_activity_details;
  FETCH csr_wf_activity_details INTO
    p_name
   ,p_display_name
   ,p_description
   ,p_instance_label;
  IF csr_wf_activity_details%notfound THEN
    -- if no rows are returned then raise an exception
    CLOSE csr_wf_activity_details;
    RAISE no_activity_details;
  END IF;
  CLOSE csr_wf_activity_details;
EXCEPTION
  when no_activity_details then
    fnd_message.set_name('PER','HR_51761_WEB_NO_ACTIVITY_DETS');
    hr_utility.raise_error;
  --
END get_activity_details;
-- ----------------------------------------------------------------------
-- |----------------< get_activity_instance_label >----------------------|
-- ----------------------------------------------------------------------
FUNCTION get_activity_instance_label
    (p_actid      IN    wf_process_activities.instance_id%TYPE)
    RETURN wf_process_activities.instance_label%type IS
  --
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  -- Used for error messages
  l_proc_name  VARCHAR2(200) :=  g_package||'get_activity_name';
  -- Variables to store the activity details
  l_display_name wf_activities_tl.display_name%TYPE;
  l_description wf_activities_tl.description%TYPE;
  l_name wf_activities_tl.name%TYPE;
  l_instance_label wf_process_activities.instance_label%TYPE;
BEGIN
  -- Get the activity details for the given activity
  get_activity_details
    (p_actid => p_actid
    ,p_name => l_name
    ,p_display_name => l_display_name
    ,p_description  => l_description
    ,p_instance_label   => l_instance_label);
  -- Return the activities label name
  RETURN l_instance_label;
END get_activity_instance_label;
-- ----------------------------------------------------------------
-- |-----------------< workflow_transition >-----------------------|
-- ----------------------------------------------------------------
PROCEDURE workflow_transition
  (p_result     IN varchar2
  ,p_item_type          IN wf_items.item_type%TYPE
  ,p_item_key           IN wf_items.item_key%TYPE
  ,p_actid              IN wf_process_activities.instance_id%TYPE) IS
  --
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  -- Used for error messages
  l_proc_name  VARCHAR2(200) :=  g_package||'workflow_transition';
  -- Instance label of current activity
  l_instance_label wf_process_activities.instance_label%type;
begin
  -- Get the name of the activity
  l_instance_label := get_activity_instance_label(p_actid);
  --
  -- Complete the activity
  wf_engine.completeactivity
   (itemtype => p_item_type
   ,itemkey  => p_item_key
   ,activity => l_instance_label
   ,result   => p_result);
END workflow_transition;
-- ----------------------------------------------------------------------
-- |----------------< get_activity_name >------------------------|
-- ----------------------------------------------------------------------
FUNCTION get_activity_name
    (p_actid      IN    wf_process_activities.instance_id%TYPE)
    RETURN wf_activities_tl.name%type IS
  --
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  -- Used for error messages
  l_proc_name  VARCHAR2(200) :=  g_package||'get_activity_name';
  -- Variables to store the activity details
  l_display_name wf_activities_tl.display_name%TYPE;
  l_description wf_activities_tl.description%TYPE;
  l_name wf_activities_tl.name%TYPE;
  l_instance_label wf_process_activities.instance_label%TYPE;
BEGIN
  -- Get the activity details for the given activity
  get_activity_details
    (p_actid => p_actid
    ,p_name => l_name
    ,p_display_name => l_display_name
    ,p_description  => l_description
    ,p_instance_label   => l_instance_label);
  -- Return the activities name
  RETURN l_name;
END get_activity_name;
END hr_workflow_utility;

/
