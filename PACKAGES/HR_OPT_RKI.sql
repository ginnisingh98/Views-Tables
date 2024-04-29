--------------------------------------------------------
--  DDL for Package HR_OPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OPT_RKI" AUTHID CURRENT_USER as
/* $Header: hroptrhi.pkh 120.0 2005/05/31 01:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_option_id                    in number
  ,p_option_type_id               in number
  ,p_option_level                 in number
  ,p_option_level_id              in varchar2
  ,p_value                        in varchar2
  ,p_encrypted                    in varchar2
  ,p_integration_id               in number
  ,p_object_version_number        in number
  );
end hr_opt_rki;

 

/
