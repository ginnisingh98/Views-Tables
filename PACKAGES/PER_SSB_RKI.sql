--------------------------------------------------------
--  DDL for Package PER_SSB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSB_RKI" AUTHID CURRENT_USER as
/* $Header: pessbrhi.pkh 120.0 2005/05/31 21:42:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end per_ssb_rki;

 

/
