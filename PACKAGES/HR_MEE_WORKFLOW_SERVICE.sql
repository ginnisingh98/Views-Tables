--------------------------------------------------------
--  DDL for Package HR_MEE_WORKFLOW_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MEE_WORKFLOW_SERVICE" AUTHID CURRENT_USER as
/* $Header: hrmeewfw.pkh 120.1 2005/09/23 15:02:20 svittal noship $ */
  --
-- ----------------------------------------------------------------------------
-- |------------------------< get_activity_name >-----------------------------|
-- ----------------------------------------------------------------------------
procedure get_activity_name
  (p_item_type         in      wf_items.item_type%type
  ,p_item_key          in      wf_items.item_key%type
  ,p_actid             in      number
  ,p_activity_name         out nocopy varchar2
  ,p_activity_display_name out nocopy varchar2);
--

-- ----------------------------------------------------------------------------
-- |-----------------------------< get_web_page_code >------------------------|
-- ----------------------------------------------------------------------------
function get_web_page_code
  (p_item_type             in wf_items.item_type%type
  ,p_item_key              in wf_items.item_key%type
  ,p_actid                 in wf_activity_attr_values.process_activity_id%type
  ,p_web_page_section_code in wf_activity_attributes.name%type)
  return varchar2;


-- ----------------------------------------------------------------------------
-- |-------------------------< check_web_page_code >--------------------------|
-- ----------------------------------------------------------------------------
function check_web_page_code
  (p_item_type             in wf_items.item_type%type
  ,p_item_key              in wf_items.item_key%type
  ,p_actid                 in wf_activity_attr_values.process_activity_id%type
  ,p_web_page_section_code in wf_activity_attributes.name%type)
  return boolean;
-- ---------------------------------------------------------------------------
-- |----------------------< get_assignment_details >------------------------|
-- --------------------------------------------------------------------------
-- This procedure returns assignment and effective date from the wf attribute
--
PROCEDURE get_assignment_details(
         p_item_type IN wf_items.item_type%type
        ,p_item_key IN wf_items.item_key%type
        ,p_assignment_id OUT NOCOPY NUMBER
        ,p_effective_date OUT NOCOPY DATE) ;

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
  ,p_text_value     out nocopy wf_activity_attr_values.text_value%type);
END hr_mee_workflow_service;


 

/
