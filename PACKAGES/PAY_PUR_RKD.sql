--------------------------------------------------------
--  DDL for Package PAY_PUR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PUR_RKD" AUTHID CURRENT_USER as
/* $Header: pypurrhi.pkh 120.0 2005/05/29 08:01 appldev noship $ */
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
  ,p_user_row_id                  in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_disable_range_overlap_check  in boolean
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_user_table_id_o              in number
  ,p_row_low_range_or_name_o      in varchar2
  ,p_display_sequence_o           in number
  ,p_row_high_range_o             in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_pur_rkd;

 

/
