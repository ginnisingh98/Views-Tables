--------------------------------------------------------
--  DDL for Package PAY_PGR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PGR_RKI" AUTHID CURRENT_USER as
/* $Header: pypgrrhi.pkh 120.0.12010000.1 2008/07/27 23:23:02 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
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
  );
end pay_pgr_rki;

/
