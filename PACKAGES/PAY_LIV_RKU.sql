--------------------------------------------------------
--  DDL for Package PAY_LIV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_LIV_RKU" AUTHID CURRENT_USER as
/* $Header: pylivrhi.pkh 120.0 2005/05/29 06:43:11 appldev noship $ */
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
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_element_link_id_o            in number
  ,p_input_value_id_o             in number
  ,p_costed_flag_o                in varchar2
  ,p_default_value_o              in varchar2
  ,p_max_value_o                  in varchar2
  ,p_min_value_o                  in varchar2
  ,p_warning_or_error_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_liv_rku;

 

/
