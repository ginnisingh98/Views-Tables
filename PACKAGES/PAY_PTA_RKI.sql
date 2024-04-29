--------------------------------------------------------
--  DDL for Package PAY_PTA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PTA_RKI" AUTHID CURRENT_USER as
/* $Header: pyptarhi.pkh 120.0 2005/05/29 07:56:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_dated_table_id               in number
  ,p_table_name                   in varchar2
  ,p_application_id               in number
  ,p_surrogate_key_name           in varchar2
  ,p_start_date_name              in varchar2
  ,p_end_date_name                in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  ,p_dyn_trigger_type             in varchar2
  ,p_dyn_trigger_package_name     in varchar2
  ,p_dyn_trig_pkg_generated       in varchar2
  );
end pay_pta_rki;

 

/
