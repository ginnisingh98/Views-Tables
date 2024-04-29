--------------------------------------------------------
--  DDL for Package PER_STB_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STB_RKU" AUTHID CURRENT_USER as
/* $Header: pestbrhi.pkh 120.0 2005/05/31 21:55:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_setup_task_code              in varchar2
  ,p_workbench_item_code          in varchar2
  ,p_setup_task_sequence          in number
  ,p_setup_task_status            in varchar2
  ,p_setup_task_creation_date     in date
  ,p_setup_task_last_modified_dat in date
  ,p_setup_task_type              in varchar2
  ,p_setup_task_action            in varchar2
  ,p_object_version_number        in number
  ,p_workbench_item_code_o        in varchar2
  ,p_setup_task_sequence_o        in number
  ,p_setup_task_status_o          in varchar2
  ,p_setup_task_creation_date_o   in date
  ,p_setup_task_last_modified_d_o in date
  ,p_setup_task_type_o            in varchar2
  ,p_setup_task_action_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_stb_rku;

 

/
