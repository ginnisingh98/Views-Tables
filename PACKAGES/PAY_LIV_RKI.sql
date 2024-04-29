--------------------------------------------------------
--  DDL for Package PAY_LIV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_LIV_RKI" AUTHID CURRENT_USER as
/* $Header: pylivrhi.pkh 120.0 2005/05/29 06:43:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_link_input_value_id          in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_element_link_id              in number
  ,p_input_value_id               in number
  ,p_costed_flag                  in varchar2
  ,p_default_value                in varchar2
  ,p_max_value                    in varchar2
  ,p_min_value                    in varchar2
  ,p_warning_or_error             in varchar2
  ,p_object_version_number        in number
  );
end pay_liv_rki;

 

/
