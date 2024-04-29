--------------------------------------------------------
--  DDL for Package FF_FGL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FGL_RKI" AUTHID CURRENT_USER as
/* $Header: fffglrhi.pkh 120.0.12000000.1 2007/03/20 11:52:32 ckesanap noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
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
  );
end ff_fgl_rki;

/
