--------------------------------------------------------
--  DDL for Package PAY_EVC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVC_RKD" AUTHID CURRENT_USER as
/* $Header: pyevcrhi.pkh 120.0 2005/05/29 04:46:51 appldev noship $ */
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
  ,p_event_value_change_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_event_qualifier_id_o         in number
  ,p_datetracked_event_id_o       in number
  ,p_default_event_o              in varchar2
  ,p_valid_event_o                in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_from_value_o                 in varchar2
  ,p_to_value_o                   in varchar2
  ,p_proration_style_o            in varchar2
  ,p_qualifier_value_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_evc_rkd;

 

/
