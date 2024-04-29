--------------------------------------------------------
--  DDL for Package PAY_UCI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_UCI_RKI" AUTHID CURRENT_USER as
/* $Header: pyucirhi.pkh 120.0 2005/05/29 09:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_user_column_instance_id      in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_user_row_id                  in number
  ,p_user_column_id               in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_value                        in varchar2
  ,p_object_version_number        in number
  );
end pay_uci_rki;

 

/
