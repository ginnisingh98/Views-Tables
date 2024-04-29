--------------------------------------------------------
--  DDL for Package PAY_PTA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PTA_RKD" AUTHID CURRENT_USER as
/* $Header: pyptarhi.pkh 120.0 2005/05/29 07:56:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_dated_table_id               in number
  ,p_table_name_o                 in varchar2
  ,p_application_id_o             in number
  ,p_surrogate_key_name_o         in varchar2
  ,p_start_date_name_o            in varchar2
  ,p_end_date_name_o              in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  ,p_dyn_trigger_type_o           in varchar2
  ,p_dyn_trigger_package_name_o   in varchar2
  ,p_dyn_trig_pkg_generated_o     in varchar2
  );
--
end pay_pta_rkd;

 

/
