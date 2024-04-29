--------------------------------------------------------
--  DDL for Package PAY_PGR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PGR_RKU" AUTHID CURRENT_USER as
/* $Header: pypgrrhi.pkh 120.0.12010000.1 2008/07/27 23:23:02 appldev ship $ */
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
  ,p_grade_rule_id                in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_rate_id                      in number
  ,p_grade_or_spinal_point_id     in number
  ,p_rate_type                    in varchar2
  ,p_maximum                      in varchar2
  ,p_mid_value                    in varchar2
  ,p_minimum                      in varchar2
  ,p_sequence                     in number
  ,p_value                        in varchar2
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  ,p_currency_code                in varchar2
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_rate_id_o                    in number
  ,p_grade_or_spinal_point_id_o   in number
  ,p_rate_type_o                  in varchar2
  ,p_maximum_o                    in varchar2
  ,p_mid_value_o                  in varchar2
  ,p_minimum_o                    in varchar2
  ,p_sequence_o                   in number
  ,p_value_o                      in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  ,p_currency_code_o              in varchar2
  );
--
end pay_pgr_rku;

/
