--------------------------------------------------------
--  DDL for Package PER_SSL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSL_RKD" AUTHID CURRENT_USER as
/* $Header: pesslrhi.pkh 120.0.12010000.1 2008/07/28 06:01:26 appldev ship $ */
--
-- -----------------------------------------------------------------------
-- |---------------------------< after_delete >--------------------------|
-- -----------------------------------------------------------------------
--
procedure after_delete
 (p_salary_survey_line_id          in number,
  p_object_version_number_o        in number,
  p_salary_survey_id_o             in number,
  p_survey_job_name_code_o         in varchar2,
  p_survey_region_code_o           in varchar2,
  p_survey_seniority_code_o        in varchar2,
  p_company_size_code_o            in varchar2,
  p_industry_code_o                in varchar2,
  p_survey_age_code_o              in varchar2,
  p_start_date_o                   in date,
  p_end_date_o                     in date,
  p_currency_code_o                in varchar2,
  p_differential_o                 in number,
  p_minimum_pay_o                  in number,
  p_mean_pay_o                     in number,
  p_maximum_pay_o                  in number,
  p_graduate_pay_o                 in number,
  p_starting_pay_o                 in number,
  p_percentage_change_o            in number,
  p_job_first_quartile_o           in number,
  p_job_median_quartile_o          in number,
  p_job_third_quartile_o           in number,
  p_job_fourth_quartile_o          in number,
  p_minimum_total_compensation_o   in number,
  p_mean_total_compensation_o      in number,
  p_maximum_total_compensation_o   in number,
  p_compnstn_first_quartile_o      in number,
  p_compnstn_median_quartile_o     in number,
  p_compnstn_third_quartile_o      in number,
  p_compnstn_fourth_quartile_o     in number,
/*Added for Enhancement 4021737 */
  p_tenth_percentile_o             in number,
  p_twenty_fifth_percentile_o      in number,
  p_fiftieth_percentile_o          in number,
  p_seventy_fifth_percentile_o     in number,
  p_ninetieth_percentile_o         in number,
  p_minimum_bonus_o                in number,
  p_mean_bonus_o                   in number,
  p_maximum_bonus_o                in number,
  p_minimum_salary_increase_o      in number,
  p_mean_salary_increase_o         in number,
  p_maximum_salary_increase_o      in number,
  p_min_variable_compensation_o    in number,
  p_mean_variable_compensation_o   in number,
  p_max_variable_compensation_o    in number,
  p_minimum_stock_o                in number,
  p_mean_stock_o                   in number,
  p_maximum_stock_o                in number,
  p_stock_display_type_o           in varchar2,
/*End Enhancement 4021737 */
  p_attribute_category_o           in varchar2,
  p_attribute1_o                   in varchar2,
  p_attribute2_o                   in varchar2,
  p_attribute3_o                   in varchar2,
  p_attribute4_o                   in varchar2,
  p_attribute5_o                   in varchar2,
  p_attribute6_o                   in varchar2,
  p_attribute7_o                   in varchar2,
  p_attribute8_o                   in varchar2,
  p_attribute9_o                   in varchar2,
  p_attribute10_o                  in varchar2,
  p_attribute11_o                  in varchar2,
  p_attribute12_o                  in varchar2,
  p_attribute13_o                  in varchar2,
  p_attribute14_o                  in varchar2,
  p_attribute15_o                  in varchar2,
  p_attribute16_o                  in varchar2,
  p_attribute17_o                  in varchar2,
  p_attribute18_o                  in varchar2,
  p_attribute19_o                  in varchar2,
  p_attribute20_o                  in varchar2,
/*Added for Enhancement 4021737*/
  p_attribute21_o                  in varchar2,
  p_attribute22_o                  in varchar2,
  p_attribute23_o                  in varchar2,
  p_attribute24_o                  in varchar2,
  p_attribute25_o                  in varchar2,
  p_attribute26_o                  in varchar2,
  p_attribute27_o                  in varchar2,
  p_attribute28_o                  in varchar2,
  p_attribute29_o                  in varchar2,
  p_attribute30_o                  in varchar2
/*End Enhancement 4021737 */

);

end per_ssl_rkd;

/
