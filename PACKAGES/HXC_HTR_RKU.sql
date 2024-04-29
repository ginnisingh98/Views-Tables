--------------------------------------------------------
--  DDL for Package HXC_HTR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTR_RKU" AUTHID CURRENT_USER as
/* $Header: hxchtrrhi.pkh 120.0.12010000.1 2008/07/28 11:13:32 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date                   in date
  ,p_time_recipient_id                in number
  ,p_name                             in varchar2
  ,p_appl_retrieval_function          in varchar2
  ,p_appl_update_process              in varchar2
  ,p_appl_validation_process          in varchar2
  ,p_appl_period_function             in varchar2
  ,p_appl_dyn_template_process        in varchar2
  ,p_extension_function1              in varchar2
  ,p_extension_function2              in varchar2
  ,p_application_id                   in number
  ,p_object_version_number            in number
  ,p_name_o                           in varchar2
  ,p_appl_retrieval_function_o        in varchar2
  ,p_appl_update_process_o            in varchar2
  ,p_appl_validation_process_o        in varchar2
  ,p_appl_period_function_o           in varchar2
  ,p_appl_dyn_template_process_o      in varchar2
  ,p_extension_function1_o            in varchar2
  ,p_extension_function2_o            in varchar2
  ,p_application_id_o                 in number
  ,p_object_version_number_o          in number
  );
--
end hxc_htr_rku;

/
