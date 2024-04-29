--------------------------------------------------------
--  DDL for Package PER_STB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STB_RKD" AUTHID CURRENT_USER as
/* $Header: pestbrhi.pkh 120.0 2005/05/31 21:55:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_setup_task_code              in varchar2
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
end per_stb_rkd;

 

/
