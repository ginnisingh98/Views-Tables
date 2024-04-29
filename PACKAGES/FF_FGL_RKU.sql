--------------------------------------------------------
--  DDL for Package FF_FGL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FGL_RKU" AUTHID CURRENT_USER as
/* $Header: fffglrhi.pkh 120.0.12000000.1 2007/03/20 11:52:32 ckesanap noship $ */
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
  ,p_global_id                    in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_data_type                    in varchar2
  ,p_global_name                  in varchar2
  ,p_global_description           in varchar2
  ,p_global_value                 in varchar2
  ,p_object_version_number        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_data_type_o                  in varchar2
  ,p_global_name_o                in varchar2
  ,p_global_description_o         in varchar2
  ,p_global_value_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end ff_fgl_rku;

/
