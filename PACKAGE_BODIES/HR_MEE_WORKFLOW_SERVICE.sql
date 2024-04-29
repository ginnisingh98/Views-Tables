--------------------------------------------------------
--  DDL for Package Body HR_MEE_WORKFLOW_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MEE_WORKFLOW_SERVICE" as
/* $Header: hrmeewfw.pkb 120.1 2005/09/23 15:02:35 svittal noship $ */

  g_package     VARCHAR2(31)   := 'hr_mee_workflow_service.';
  gv_package     VARCHAR2(31)   := 'hr_mee_workflow_service';
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
--

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
--
-- --- Function to return Assignment_id and Effective date
PROCEDURE get_assignment_details(
	 p_item_type IN wf_items.item_type%type
   	,p_item_key IN wf_items.item_key%type
 	,p_assignment_id OUT NOCOPY NUMBER
	,p_effective_date OUT NOCOPY DATE)
IS
  l_effective_date date;
  l_effective_char VARCHAR2(200);
BEGIN
  -- get assignment id from Workflow Item Attributes
     p_assignment_id := wf_engine.getItemAttrNumber(
             itemtype  => p_item_type
            ,itemkey   => p_item_key
            ,aname     => 'CURRENT_ASSIGNMENT_ID');

  -- get effective date from Workflow Item Attribute
     l_effective_date := wf_engine.getItemAttrDate(
             itemtype  => p_item_type
            ,itemkey => p_item_key
            ,aname   => 'CURRENT_EFFECTIVE_DATE');
     p_effective_date := l_effective_date;
EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END get_assignment_details;
END hr_mee_workflow_service;

/
