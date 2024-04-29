--------------------------------------------------------
--  DDL for Package PAY_RAN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RAN_RKD" AUTHID CURRENT_USER as
/* $Header: pyranrhi.pkh 120.1 2007/02/10 09:21:22 vetsrini noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_range_id                     in number
  ,p_range_table_id_o             in number
  ,p_low_band_o                   in number
  ,p_high_band_o                  in number
  ,p_amount1_o                    in number
  ,p_amount2_o                    in number
  ,p_amount3_o                        in number
  ,p_amount4_o                        in number
  ,p_amount5_o                        in number
  ,p_amount6_o                        in number
  ,p_amount7_o                        in number
  ,p_amount8_o                        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_object_version_number_o      in number
  );
--
end pay_ran_rkd;

/
