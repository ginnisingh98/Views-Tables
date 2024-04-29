--------------------------------------------------------
--  DDL for Package PAY_ECU_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ECU_RKU" AUTHID CURRENT_USER as
/* $Header: pyecurhi.pkh 120.1 2005/12/15 06:40:05 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_element_class_usage_id       in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_run_type_id                  in number
  ,p_classification_id            in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_run_type_id_o                in number
  ,p_classification_id_o          in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_ecu_rku;

 

/
