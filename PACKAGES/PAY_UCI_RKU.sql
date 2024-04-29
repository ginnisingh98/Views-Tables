--------------------------------------------------------
--  DDL for Package PAY_UCI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_UCI_RKU" AUTHID CURRENT_USER as
/* $Header: pyucirhi.pkh 120.0 2005/05/29 09:10 appldev noship $ */
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
  ,p_user_column_instance_id      in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_value                        in varchar2
  ,p_object_version_number        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_user_row_id_o                in number
  ,p_user_column_id_o             in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_value_o                      in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_uci_rku;

 

/
