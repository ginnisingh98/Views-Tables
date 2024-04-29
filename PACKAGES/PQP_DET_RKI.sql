--------------------------------------------------------
--  DDL for Package PQP_DET_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_DET_RKI" AUTHID CURRENT_USER as
/* $Header: pqdetrhi.pkh 120.0.12010000.1 2008/07/28 11:08:28 appldev ship $ */

-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------

procedure after_insert
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
 ,p_student_exempt_from_ss       in varchar2
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
  );
end pqp_det_rki;

/
