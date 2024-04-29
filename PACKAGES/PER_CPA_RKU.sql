--------------------------------------------------------
--  DDL for Package PER_CPA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CPA_RKU" AUTHID CURRENT_USER as
/* $Header: pecparhi.pkh 115.3 2002/12/04 15:03:43 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_cagr_api_param_id            in number
  ,p_cagr_api_id                  in number
  ,p_display_name                 in varchar2
  ,p_parameter_name               in varchar2
  ,p_column_type                  in varchar2
  ,p_column_size                  in number
  ,p_uom_parameter                in varchar2
  ,p_uom_lookup                   in varchar2
  ,p_default_uom                  in varchar2
  ,p_hidden                       in varchar2
  ,p_object_version_number        in number
  ,p_cagr_api_id_o                in number
  ,p_display_name_o               in varchar2
  ,p_parameter_name_o             in varchar2
  ,p_column_type_o                in varchar2
  ,p_column_size_o                in number
  ,p_uom_parameter_o              in varchar2
  ,p_uom_lookup_o                 in varchar2
  ,p_default_uom_o                in varchar2
  ,p_hidden_o                     in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_cpa_rku;

 

/
