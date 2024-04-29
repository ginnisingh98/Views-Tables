--------------------------------------------------------
--  DDL for Package PQP_DET_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_DET_RKU" AUTHID CURRENT_USER as
/* $Header: pqdetrhi.pkh 120.0.12010000.1 2008/07/28 11:08:28 appldev ship $ */

-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------

procedure after_update
  (
  p_analyzed_data_details_id       in number
 ,p_analyzed_data_id               in number
 ,p_income_code                    in varchar2
 ,p_withholding_rate               in number
 ,p_income_code_sub_type           in varchar2
 ,p_exemption_code                 in varchar2
 ,p_maximum_benefit_amount         in number
 ,p_retro_lose_ben_amt_flag        in varchar2
 ,p_date_benefit_ends              in date
 ,p_retro_lose_ben_date_flag       in varchar2
 ,p_nra_exempt_from_ss             in varchar2
 ,p_nra_exempt_from_medicare       in varchar2
 ,p_student_exempt_from_ss         in varchar2
 ,p_student_exempt_from_medi       in varchar2
 ,p_addl_withholding_flag          in varchar2
 ,p_constant_addl_tax              in number
 ,p_addl_withholding_amt           in number
 ,p_addl_wthldng_amt_period_type   in varchar2
 ,p_personal_exemption             in number
 ,p_addl_exemption_allowed         in number
 ,p_treaty_ben_allowed_flag        in varchar2
 ,p_treaty_benefits_start_date     in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_retro_loss_notification_sent   in varchar2
 ,p_current_analysis               in varchar2
 ,p_forecast_income_code           in varchar2
 ,p_analyzed_data_id_o             in number
 ,p_income_code_o                  in varchar2
 ,p_withholding_rate_o             in number
 ,p_income_code_sub_type_o         in varchar2
 ,p_exemption_code_o               in varchar2
 ,p_maximum_benefit_amount_o       in number
 ,p_retro_lose_ben_amt_flag_o      in varchar2
 ,p_date_benefit_ends_o            in date
 ,p_retro_lose_ben_date_flag_o     in varchar2
 ,p_nra_exempt_from_ss_o           in varchar2
 ,p_nra_exempt_from_medicare_o     in varchar2
 ,p_student_exempt_from_ss_o       in varchar2
 ,p_student_exempt_from_medi_o     in varchar2
 ,p_addl_withholding_flag_o        in varchar2
 ,p_constant_addl_tax_o            in number
 ,p_addl_withholding_amt_o         in number
 ,p_addl_wthldng_amt_period_ty_o   in varchar2
 ,p_personal_exemption_o           in number
 ,p_addl_exemption_allowed_o       in number
 ,p_treaty_ben_allowed_flag_o      in varchar2
 ,p_treaty_benefits_start_date_o   in date
 ,p_object_version_number_o        in number
 ,p_retro_loss_notif_sent_o        in varchar2
 ,p_current_analysis_o             in varchar2
 ,p_forecast_income_code_o         in varchar2
  );

end pqp_det_rku;

/
