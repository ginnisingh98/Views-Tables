--------------------------------------------------------
--  DDL for Package FF_FFN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FFN_RKI" AUTHID CURRENT_USER as
/* $Header: ffffnrhi.pkh 120.0 2005/05/27 23:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_function_id                  in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_class                        in varchar2
  ,p_name                         in varchar2
  ,p_alias_name                   in varchar2
  ,p_data_type                    in varchar2
  ,p_definition                   in varchar2
  ,p_description                  in varchar2
  ,p_object_version_number        in number
  );
end ff_ffn_rki;

 

/
