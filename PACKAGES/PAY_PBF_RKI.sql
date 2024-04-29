--------------------------------------------------------
--  DDL for Package PAY_PBF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PBF_RKI" AUTHID CURRENT_USER as
/* $Header: pypbfrhi.pkh 120.0 2005/05/29 07:23:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_balance_feed_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_balance_type_id              in number
  ,p_input_value_id               in number
  ,p_scale                        in number
  ,p_legislation_subgroup         in varchar2
  ,p_object_version_number        in number
  );
end pay_pbf_rki;

 

/
