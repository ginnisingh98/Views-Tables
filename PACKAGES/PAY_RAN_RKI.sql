--------------------------------------------------------
--  DDL for Package PAY_RAN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RAN_RKI" AUTHID CURRENT_USER as
/* $Header: pyranrhi.pkh 120.1 2007/02/10 09:21:22 vetsrini noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_range_id                     in number
  ,p_range_table_id               in number
  ,p_low_band                     in number
  ,p_high_band                    in number
  ,p_amount1                      in number
  ,p_amount2                      in number
  ,p_amount3                        in number
  ,p_amount4                        in number
  ,p_amount5                        in number
  ,p_amount6                        in number
  ,p_amount7                        in number
  ,p_amount8                        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_object_version_number        in number
  );
end pay_ran_rki;

/
