--------------------------------------------------------
--  DDL for Package PJI_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: PJIUT04S.pls 120.2 2005/12/06 18:03:03 appldev noship $ */


 PROCEDURE pji_sys_settings_update_row (p_organization_structure         IN VARCHAR2,
                                        p_org_structure_version          IN VARCHAR2,
                                        p_dflt_prjpip_period_type        IN VARCHAR2,
                                        p_dflt_prjpip_as_of_date         IN VARCHAR2,
                                        p_dflt_prjpip_cycle              IN VARCHAR2,
                                        p_dflt_prjbab_period_type        IN VARCHAR2,
                                        p_dflt_prjbab_as_of_date         IN VARCHAR2,
                                        p_dflt_prjbab_cycle              IN VARCHAR2,
                                        p_dflt_resutl_period_type        IN VARCHAR2,
                                        p_dflt_resutl_as_of_date         IN VARCHAR2,
                                        p_dflt_resutl_cycle              IN VARCHAR2,
                                        p_dflt_resavl_period_type        IN VARCHAR2,
                                        p_dflt_resavl_as_of_date         IN VARCHAR2,
                                        p_dflt_resavl_cycle              IN VARCHAR2,
                                        p_dflt_respln_period_type        IN VARCHAR2,
                                        p_dflt_respln_as_of_date         IN VARCHAR2,
                                        p_dflt_respln_cycle              IN VARCHAR2,
                                        p_dflt_prjhlt_period_type        IN VARCHAR2,
                                        p_dflt_prjhlt_as_of_date         IN VARCHAR2,
                                        p_dflt_prjhlt_cycle              IN VARCHAR2,
                                        p_dflt_prjact_period_type        IN VARCHAR2,
                                        p_dflt_prjact_as_of_date         IN VARCHAR2,
                                        p_dflt_prjact_cycle              IN VARCHAR2,
                                        p_dflt_prjprf_period_type        IN VARCHAR2,
                                        p_dflt_prjprf_as_of_date         IN VARCHAR2,
                                        p_dflt_prjprf_cycle              IN VARCHAR2,
                                        p_dflt_prjcst_period_type        IN VARCHAR2,
                                        p_dflt_prjcst_as_of_date         IN VARCHAR2,
                                        p_dflt_prjcst_cycle              IN VARCHAR2,
                                        p_pa_period_flag                 IN VARCHAR2,
                                        p_gl_period_flag                 IN VARCHAR2,
                                        p_conversion_ratio_days          IN NUMBER,
                                        p_book_to_bill_days              IN NUMBER,
                                        p_dso_days                       IN NUMBER,
                                        p_dormant_backlog_days           IN NUMBER,
                                        p_cost_budget_type               IN VARCHAR2,
                                        p_cost_budget_conv_rule          IN VARCHAR2,
                                        p_revenue_budget_type            IN VARCHAR2,
                                        p_revenue_budget_conv_rule       IN VARCHAR2,
                                        p_cost_forecast_type             IN VARCHAR2,
                                        p_cost_forecast_conv_rule        IN VARCHAR2,
                                        p_revenue_forecast_type          IN VARCHAR2,
                                        p_revenue_forecast_conv_rule     IN VARCHAR2,
                                        p_report_cost_type               IN VARCHAR2,
                                        p_report_labor_units             IN VARCHAR2,
                                        p_rolling_weeks	                 IN NUMBER,
                                        p_config_proj_perf_flag          IN VARCHAR2,
					p_config_cost_flag               IN VARCHAR2,
					p_config_profit_flag             IN VARCHAR2,
                                        p_config_util_flag               IN VARCHAR2,
                                        p_cost_fp_type_id           	 IN NUMBER,
					p_revenue_fp_type_id           	 IN NUMBER,
					p_cost_forecast_fp_type_id    	 IN NUMBER,
                                        p_revenue_forecast_fp_type_id  	 IN NUMBER,
										p_global_curr2_flag				 IN VARCHAR2,
                                        x_return_status                 OUT NOCOPY  VARCHAR2,
                                        x_error_message_code            OUT NOCOPY  VARCHAR2
                 			) ;


/*
 procedure pji_mt_bsr_insert_row (p_name                  in VARCHAR2,
                                  p_seq                   in NUMBER,
                                  p_bucket_set_code       in VARCHAR2,
                                  p_default_flag          in VARCHAR2,
                                  p_from_value            in NUMBER,
                                  p_to_value              in NUMBER,
                                  x_return_status        OUT NOCOPY  varchar2,
                                  x_error_message_code   OUT NOCOPY  varchar2
			) ;
*/

 PROCEDURE pji_mt_pip_update_row (p_name                   IN VARCHAR2,
                                  p_seq                    IN NUMBER,
                                  p_bucket_set_code        IN VARCHAR2,
                                  p_default_flag               IN VARCHAR2,
                                  p_from_value             IN NUMBER,
                                  p_to_value               IN NUMBER,
                                  x_return_status          OUT NOCOPY  VARCHAR2,
                                  x_error_message_code     OUT NOCOPY  VARCHAR2
                 			) ;

 PROCEDURE pji_mt_dls_update_row (p_name                   IN VARCHAR2,
                                  p_seq                    IN NUMBER,
                                  p_bucket_set_code        IN VARCHAR2,
                                  p_default_flag               IN VARCHAR2,
                                  p_from_value             IN NUMBER,
                                  p_to_value               IN NUMBER,
                                  x_return_status          OUT NOCOPY  VARCHAR2,
                                  x_error_message_code     OUT NOCOPY  VARCHAR2
                 			) ;

 PROCEDURE pji_mt_res_avl_dur_update_row(p_name                   IN VARCHAR2,
                                   p_seq                    IN NUMBER,
                                   p_bucket_set_code        IN VARCHAR2,
                                   p_default_flag               IN VARCHAR2,
                                   p_from_value             IN NUMBER,
                                   p_to_value               IN NUMBER,
                                   x_return_status          OUT NOCOPY  VARCHAR2,
                                   x_error_message_code     OUT NOCOPY  VARCHAR2
                 			) ;

 PROCEDURE pji_mt_avl_update_row (p_name                   IN VARCHAR2,
                                  p_seq                    IN NUMBER,
                                  p_bucket_set_code        IN VARCHAR2,
                                  p_default_flag           IN VARCHAR2,
                                  p_from_value             IN NUMBER,
                                  p_to_value               IN NUMBER,
                                  x_return_status          OUT NOCOPY  VARCHAR2,
                                  x_error_message_code     OUT NOCOPY  VARCHAR2
                 			) ;

  --
  -- Procedure to validate Bucket range
  --
 PROCEDURE pji_validate_bucket_ranges (x_return_status              OUT NOCOPY  VARCHAR2,
                                       x_error_message_code         OUT NOCOPY  VARCHAR2
                 			) ;


  --
  -- Procedure to create the audit records.
  --
PROCEDURE      pji_insert_events_log (
      p_organization_structure_id       IN NUMBER,
      p_org_structure_version_id        IN NUMBER,
      p_dflt_prjpip_period_type         IN VARCHAR2,
      p_dflt_prjpip_as_of_date          IN VARCHAR2,
      p_dflt_prjbab_period_type         IN VARCHAR2,
      p_dflt_prjbab_as_of_date          IN VARCHAR2,
      p_dflt_resutl_period_type         IN VARCHAR2,
      p_dflt_resutl_as_of_date          IN VARCHAR2,
      p_dflt_resavl_period_type         IN VARCHAR2,
      p_dflt_resavl_as_of_date          IN VARCHAR2,
      p_dflt_respln_period_type         IN VARCHAR2,
      p_dflt_respln_as_of_date          IN VARCHAR2,
      p_dflt_prjhlt_period_type         IN VARCHAR2,
      p_dflt_prjhlt_as_of_date          IN VARCHAR2,
      p_dflt_prjact_period_type         IN VARCHAR2,
      p_dflt_prjact_as_of_date          IN VARCHAR2,
      p_dflt_prjprf_period_type         IN VARCHAR2,
      p_dflt_prjprf_as_of_date          IN VARCHAR2,
      p_dflt_prjcst_period_type         IN VARCHAR2,
      p_dflt_prjcst_as_of_date          IN VARCHAR2,
      p_pa_period_flag                  IN VARCHAR2,
      p_gl_period_flag                  IN VARCHAR2,
      p_conversion_ratio_days           IN VARCHAR2,
      p_book_to_bill_days               IN NUMBER,
      p_dso_days                        IN NUMBER,
      p_dormant_backlog_days            IN NUMBER,
      p_cost_budget_type_code           IN VARCHAR2,
      p_cost_budget_conv_rule           IN VARCHAR2,
      p_revenue_budget_type_code        IN VARCHAR2,
      p_revenue_budget_conv_rule        IN VARCHAR2,
      p_cost_forecast_type_code         IN VARCHAR2,
      p_cost_forecast_conv_rule         IN VARCHAR2,
      p_revenue_forecast_type_code      IN VARCHAR2,
      p_revenue_forecast_conv_rule      IN VARCHAR2,
      p_report_cost_type                IN VARCHAR2,
      p_report_labor_units              IN VARCHAR2,
      p_rolling_weeks			IN NUMBER,
      p_config_proj_perf_flag          IN VARCHAR2,
      p_config_cost_flag               IN VARCHAR2,
      p_config_profit_flag             IN VARCHAR2,
      p_config_util_flag               IN VARCHAR2,
      p_cost_fp_type_id           	 IN NUMBER,
      p_revenue_fp_type_id           	 IN NUMBER,
      p_cost_forecast_fp_type_id    	 IN NUMBER,
      p_revenue_forecast_fp_type_id  	 IN NUMBER,
	  p_global_curr2_flag				 IN VARCHAR2,
      x_return_status                  OUT NOCOPY  VARCHAR2,
      x_error_message_code             OUT NOCOPY  VARCHAR2);

  --
  -- Procedure to validate Organization Structure
  --
PROCEDURE Check_Org_structure
                ( p_Org_structure              IN  VARCHAR2
                 ,x_Org_structure_id           OUT NOCOPY  VARCHAR2
                 ,x_return_status      OUT NOCOPY  VARCHAR2
                 ,x_error_message_code OUT NOCOPY  VARCHAR2) ;

  --
  -- Procedure to validate Organization Structure Version
  --
PROCEDURE Check_Org_structure_Version
                ( p_Org_structure_version      IN  VARCHAR2
                 ,p_Org_structure_id           IN  NUMBER
                 ,x_Org_structure_version_id   OUT NOCOPY  VARCHAR2
                 ,x_return_status              OUT NOCOPY  VARCHAR2
                 ,x_error_message_code         OUT NOCOPY  VARCHAR2) ;

  --
  --  Procedure to validate Cost Budget Type
  --
PROCEDURE Check_Budget_Type
                ( p_budget_type                 IN  VARCHAR2
                 ,p_amount_type_code            IN  VARCHAR2
                 ,x_budget_type_code           OUT NOCOPY  VARCHAR2
                 ,x_return_status              OUT NOCOPY  VARCHAR2
                 ,x_error_message_code         OUT NOCOPY  VARCHAR2) ;

PROCEDURE Derive_Summarization_Flags
                ( x_base_summary_flag           OUT NOCOPY  VARCHAR2
                 ,x_intelligence_flag              OUT NOCOPY  VARCHAR2
                 ,x_performance_flag         OUT NOCOPY  VARCHAR2) ;

END Pji_Setup_Pkg;

 

/
