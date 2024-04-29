--------------------------------------------------------
--  DDL for Package PER_BBT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BBT_RKI" AUTHID CURRENT_USER as
/* $Header: pebbtrhi.pkh 120.0 2005/05/31 06:03:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_balance_type_id              in number
  ,p_input_value_id               in number
  ,p_business_group_id            in number
  ,p_displayed_name               in varchar2
  ,p_internal_name                in varchar2
  ,p_uom                          in varchar2
  ,p_currency                     in varchar2
  ,p_category                     in varchar2
  ,p_date_from                    in date
  ,p_date_to                      in date
  ,p_object_version_number        in number
  );
end per_bbt_rki;

 

/
