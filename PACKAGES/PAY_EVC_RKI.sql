--------------------------------------------------------
--  DDL for Package PAY_EVC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVC_RKI" AUTHID CURRENT_USER as
/* $Header: pyevcrhi.pkh 120.0 2005/05/29 04:46:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_event_value_change_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_event_qualifier_id           in number
  ,p_datetracked_event_id         in number
  ,p_default_event                in varchar2
  ,p_valid_event                  in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_from_value                   in varchar2
  ,p_to_value                     in varchar2
  ,p_proration_style              in varchar2
  ,p_qualifier_value              in varchar2
  ,p_object_version_number        in number
  );
end pay_evc_rki;

 

/
