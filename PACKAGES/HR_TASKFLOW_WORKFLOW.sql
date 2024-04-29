--------------------------------------------------------
--  DDL for Package HR_TASKFLOW_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TASKFLOW_WORKFLOW" AUTHID CURRENT_USER as
/* $Header: hrtskwkf.pkh 115.3 2002/12/10 11:34:42 raranjan ship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< transfer_workflow >-------------------------|
-- ----------------------------------------------------------------------------
procedure transfer_workflow
 (p_process_item_type    in varchar2
 ,p_root_process_name    in varchar2 default null
 ,p_business_group_id    in number   default null
 ,p_legislation_code     in varchar2 default null
 ,p_legislation_subgroup in varchar2 default null);
-- ----------------------------------------------------------------------------
-- |-----------------------< call_taskflow_form >-----------------------------|
-- ----------------------------------------------------------------------------
procedure call_taskflow_form
 (itemtype in     varchar2
 ,itemkey  in     varchar2
 ,actid    in     number
 ,funmode  in     varchar2
 ,result      out nocopy varchar2);
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_process_name >--------------------------|
-- ----------------------------------------------------------------------------
function chk_process_name
 (p_item_type    in varchar2
 ,p_process_name in varchar2)
 return boolean;
-- ----------------------------------------------------------------------------
-- |---------------------< get_converted_processes >--------------------------|
-- ----------------------------------------------------------------------------
function get_converted_processes return number;
--
end hr_taskflow_workflow;

 

/
