--------------------------------------------------------
--  DDL for Package PER_SSB_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSB_RKU" AUTHID CURRENT_USER as
/* $Header: pessbrhi.pkh 120.0 2005/05/31 21:42:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_setup_sub_task_code          in varchar2
  ,p_setup_task_code              in varchar2
  ,p_setup_sub_task_sequence      in number
  ,p_setup_sub_task_status        in varchar2
  ,p_setup_sub_task_type          in varchar2
  ,p_setup_sub_task_data_pump_lin in varchar2
  ,p_setup_sub_task_action        in varchar2
  ,p_setup_sub_task_creation_date in date
  ,p_setup_sub_task_last_mod_date in date
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  ,p_setup_task_code_o            in varchar2
  ,p_setup_sub_task_sequence_o    in number
  ,p_setup_sub_task_status_o      in varchar2
  ,p_setup_sub_task_type_o        in varchar2
  ,p_setup_sub_task_data_pump_l_o in varchar2
  ,p_setup_sub_task_action_o      in varchar2
  ,p_setup_sub_task_creation_da_o in date
  ,p_setup_sub_task_last_mod_da_o in date
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_ssb_rku;

 

/