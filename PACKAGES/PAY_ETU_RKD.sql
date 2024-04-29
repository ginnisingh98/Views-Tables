--------------------------------------------------------
--  DDL for Package PAY_ETU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ETU_RKD" AUTHID CURRENT_USER as
/* $Header: pyeturhi.pkh 120.0 2005/05/29 04:45:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_element_type_usage_id        in number
  ,p_run_type_id_o                in number
  ,p_element_type_id_o            in number
  ,p_inclusion_flag_o             in varchar2
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_object_version_number_o      in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_usage_type_o		  in varchar2
  );
--
end pay_etu_rkd;

 

/
