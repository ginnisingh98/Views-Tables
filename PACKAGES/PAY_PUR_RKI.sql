--------------------------------------------------------
--  DDL for Package PAY_PUR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PUR_RKI" AUTHID CURRENT_USER as
/* $Header: pypurrhi.pkh 120.0 2005/05/29 08:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_user_row_id                  in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_user_table_id                in number
  ,p_row_low_range_or_name        in varchar2
  ,p_display_sequence             in number
  ,p_row_high_range               in varchar2
  ,p_object_version_number        in number
  ,p_disable_units_check          in boolean
  ,p_disable_range_overlap_check  in boolean
  );
end pay_pur_rki;

 

/
