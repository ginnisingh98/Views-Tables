--------------------------------------------------------
--  DDL for Package PER_CPA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CPA_RKI" AUTHID CURRENT_USER as
/* $Header: pecparhi.pkh 115.3 2002/12/04 15:03:43 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end per_cpa_rki;

 

/
