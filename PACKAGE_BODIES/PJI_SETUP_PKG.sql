--------------------------------------------------------
--  DDL for Package Body PJI_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_SETUP_PKG" AS
/* $Header: PJIUT04B.pls 120.2 2005/12/06 18:04:23 appldev noship $ */

----------------------------------------------------------------------------------------------------------------
-- API          : pji_sys_settings_update_row
-- Description  : This procedure validates and updates PJI_SYSTEM_SETTINGS Table.
----------------------------------------------------------------------------------------------------------------
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
                 			) IS


  l_dflt_prjpip_cycle_id              NUMBER ;
  l_dflt_prjbab_cycle_id              NUMBER ;
  l_dflt_resutl_cycle_id              NUMBER ;
  l_dflt_resavl_cycle_id              NUMBER ;
  l_dflt_respln_cycle_id              NUMBER ;
  l_dflt_prjhlt_cycle_id              NUMBER ;
  l_dflt_prjact_cycle_id              NUMBER ;
  l_dflt_prjprf_cycle_id              NUMBER ;
  l_dflt_prjcst_cycle_id              NUMBER ;



  l_cost_budget_type_code             VARCHAR2(30) ;
  l_revenue_budget_type_code          VARCHAR2(30) ;
  l_cost_forecast_type_code           VARCHAR2(30) ;
  l_revenue_forecast_type_code        VARCHAR2(30) ;

  l_organization_structure_id         NUMBER ;
  l_org_structure_version_id          NUMBER ;

  l_return_status                     VARCHAR2(30);
  l_error_message_code                VARCHAR2(30);

  l_created_by          NUMBER;
  l_last_updated_by     NUMBER;
  l_creation_date       DATE;
  l_last_update_date    DATE;
  l_last_update_login   NUMBER;

 BEGIN
  -- need to check status, force user to use adjust if necessary

  IF (p_organization_structure IS NULL) THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_ORG_STRUCT_NULL' ;
     RETURN ;

  ELSIF ( p_org_structure_version IS NULL) THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_ORG_STRUCT_VER_NULL' ;
     RETURN ;

  ELSIF ( p_dflt_prjpip_period_type IS NULL OR
          p_dflt_prjpip_as_of_date  IS NULL OR
          p_dflt_prjbab_period_type IS NULL OR
          p_dflt_prjbab_as_of_date  IS NULL OR
          p_dflt_resutl_period_type IS NULL OR
          p_dflt_resutl_as_of_date  IS NULL OR
          p_dflt_resavl_period_type IS NULL OR
          p_dflt_resavl_as_of_date  IS NULL OR
          p_dflt_respln_period_type IS NULL OR
          p_dflt_respln_as_of_date  IS NULL OR
          p_dflt_prjhlt_period_type IS NULL OR
          p_dflt_prjhlt_as_of_date  IS NULL OR
          p_dflt_prjact_period_type IS NULL OR
          p_dflt_prjact_as_of_date  IS NULL OR
          p_dflt_prjprf_period_type IS NULL OR
          p_dflt_prjprf_as_of_date  IS NULL OR
          p_dflt_prjcst_period_type IS NULL OR
          p_dflt_prjcst_as_of_date  IS NULL ) THEN

        x_return_status := 'E';
        x_error_message_code := 'PJI_REP_DEFAULTS_NULL' ;
        RETURN ;

  ELSIF ( p_conversion_ratio_days IS NULL) OR (p_conversion_ratio_days <= 0 )THEN

        x_return_status := 'E';
        x_error_message_code := 'PJI_CONV_RATIO_DAYS_NULL' ;
        RETURN ;

  ELSIF ( p_book_to_bill_days IS NULL) OR (p_book_to_bill_days <= 0 )THEN

        x_return_status := 'E';
        x_error_message_code := 'PJI_BOOK_TO_BILL_DAYS_NULL' ;
        RETURN ;

  ELSIF ( p_dso_days IS NULL) OR (p_dso_days <= 0 )THEN

        x_return_status := 'E';
        x_error_message_code := 'PJI_DSO_DAYS_NULL' ;
        RETURN ;

  ELSIF ( p_dormant_backlog_days IS NULL) OR (p_dormant_backlog_days <= 0 )THEN

        x_return_status := 'E';
        x_error_message_code := 'PJI_DOR_BACKLOG_NULL' ;
        RETURN ;
  ELSIF ( p_rolling_weeks IS NULL) OR (p_rolling_weeks <= 0 )THEN

          x_return_status := 'E';
          x_error_message_code := 'PJI_ROLL_WEEK_NULL' ;
        RETURN ;

  ELSIF ( p_cost_budget_type               IS NULL OR
          p_cost_budget_conv_rule          IS NULL OR
          p_revenue_budget_type            IS NULL OR
          p_revenue_budget_conv_rule       IS NULL OR
          p_cost_forecast_type             IS NULL OR
          p_cost_forecast_conv_rule        IS NULL OR
          p_revenue_forecast_type          IS NULL OR
          p_revenue_forecast_conv_rule     IS NULL ) THEN

        x_return_status := 'E';
        x_error_message_code := 'PJI_DOR_BACKLOG_NULL' ;
        RETURN ;

  END IF;

  --
  -- Validate organization Structure
  --

  Check_Org_structure
                ( p_Org_structure        => p_organization_structure
                 ,x_Org_structure_id     => l_organization_structure_id
                 ,x_return_status        => l_return_status
                 ,x_error_message_code   => l_error_message_code) ;

  IF (l_return_status <> 'S') THEN

      x_return_status := 'E';
      x_error_message_code := l_error_message_code ;
      RETURN ;

  END IF;

  --
  -- Validate Organization Structure Version
  --

  Check_Org_structure_Version
                ( p_Org_structure_version      => p_org_structure_version
                 ,p_Org_structure_id           => l_organization_structure_id
                 ,x_Org_structure_version_id   => l_org_structure_version_id
                 ,x_return_status              => l_return_status
                 ,x_error_message_code         => l_error_message_code );

  IF (l_return_status <> 'S') THEN

      x_return_status := 'E';
      x_error_message_code := l_error_message_code ;
      RETURN ;

  END IF;

  --
  -- Validate Cost Budget Type
  --
  Check_Budget_Type
                ( p_budget_type                 => p_cost_budget_type
                 ,p_amount_type_code            => 'C'
                 ,x_budget_type_code            => l_cost_budget_type_code
                 ,x_return_status               => l_return_status
                 ,x_error_message_code          => l_error_message_code) ;

  IF (l_return_status <> 'S') THEN

      x_return_status := 'E';
      IF l_error_message_code = 'PA_BUDGET_TYPE_INVALID' THEN
          x_error_message_code := 'PJI_COST_BUDGET_TYPE_INVALID' ;

      ELSIF l_error_message_code = 'PA_BUDGET_TYPE_AMBIGUOUS' THEN
          x_error_message_code := 'PJI_COST_BUDGET_TYPE_AMBIGUOUS' ;

      END IF ;
      RETURN ;

  END IF;


  --
  -- Validate Revenue Budget Type
  --
  Check_Budget_Type
                ( p_budget_type                 => p_revenue_budget_type
                 ,p_amount_type_code            => 'R'
                 ,x_budget_type_code            => l_revenue_budget_type_code
                 ,x_return_status               => l_return_status
                 ,x_error_message_code          => l_error_message_code) ;

  IF (l_return_status <> 'S') THEN

      x_return_status := 'E';
      IF l_error_message_code = 'PA_BUDGET_TYPE_INVALID' THEN
          x_error_message_code := 'PJI_REV_BUDGET_TYPE_INVALID' ;

      ELSIF l_error_message_code = 'PA_BUDGET_TYPE_AMBIGUOUS' THEN
          x_error_message_code := 'PJI_REV_BUDGET_TYPE_AMBIGUOUS' ;

      END IF ;
      RETURN ;

  END IF;


  --
  -- Validate Cost Forecast Type
  --
  Check_Budget_Type
                ( p_budget_type                 => p_cost_forecast_type
                 ,p_amount_type_code            => 'C'
                 ,x_budget_type_code            => l_cost_forecast_type_code
                 ,x_return_status               => l_return_status
                 ,x_error_message_code          => l_error_message_code) ;

  IF (l_return_status <> 'S') THEN

      x_return_status := 'E';
      IF l_error_message_code = 'PA_BUDGET_TYPE_INVALID' THEN
          x_error_message_code := 'PJI_COST_FORECAST_TYPE_INVALID' ;

      ELSIF l_error_message_code = 'PA_BUDGET_TYPE_AMBIGUOUS' THEN
          x_error_message_code := 'PJI_COST_FORECAST_TYPE_AMBIG' ;

      END IF ;
      RETURN ;

  END IF;

  --
  -- Validate Revenue Forecast Type
  --
  Check_Budget_Type
                ( p_budget_type                 => p_revenue_forecast_type
                 ,p_amount_type_code            => 'R'
                 ,x_budget_type_code            => l_revenue_forecast_type_code
                 ,x_return_status               => l_return_status
                 ,x_error_message_code          => l_error_message_code) ;

  IF (l_return_status <> 'S') THEN

      x_return_status := 'E';
      IF l_error_message_code = 'PA_BUDGET_TYPE_INVALID' THEN
          x_error_message_code := 'PJI_REV_FORECAST_TYPE_INVALID' ;

      ELSIF l_error_message_code = 'PA_BUDGET_TYPE_AMBIGUOUS' THEN
          x_error_message_code := 'PJI_REV_FORECAST_TYPE_AMBIG' ;

      END IF ;
      RETURN ;

  END IF;


  l_created_by          := Fnd_Profile.value('USER_ID');
  l_last_updated_by     := Fnd_Profile.value('USER_ID');
  l_creation_date       := SYSDATE;
  l_last_update_date    := SYSDATE;
  l_last_update_login   := Fnd_Profile.value('USER_ID');

  --
  -- Keep track of the changes(Audit).
  --

      pji_insert_events_log (
      p_organization_structure_id       =>  l_organization_structure_id,
      p_org_structure_version_id        =>  l_org_structure_version_id,
      p_dflt_prjpip_period_type         =>  p_dflt_prjpip_period_type,
      p_dflt_prjpip_as_of_date          =>  p_dflt_prjpip_as_of_date,
      p_dflt_prjbab_period_type         =>  p_dflt_prjbab_period_type,
      p_dflt_prjbab_as_of_date          =>  p_dflt_prjbab_as_of_date,
      p_dflt_resutl_period_type         =>  p_dflt_resutl_period_type,
      p_dflt_resutl_as_of_date          =>  p_dflt_resutl_as_of_date,
      p_dflt_resavl_period_type         =>  p_dflt_resavl_period_type,
      p_dflt_resavl_as_of_date          =>  p_dflt_resavl_as_of_date,
      p_dflt_respln_period_type         =>  p_dflt_respln_period_type,
      p_dflt_respln_as_of_date          =>  p_dflt_respln_as_of_date,
      p_dflt_prjhlt_period_type         =>  p_dflt_prjhlt_period_type,
      p_dflt_prjhlt_as_of_date          =>  p_dflt_prjhlt_as_of_date,
      p_dflt_prjact_period_type         =>  p_dflt_prjact_period_type,
      p_dflt_prjact_as_of_date          =>  p_dflt_prjact_as_of_date,
      p_dflt_prjprf_period_type         =>  p_dflt_prjprf_period_type,
      p_dflt_prjprf_as_of_date          =>  p_dflt_prjprf_as_of_date,
      p_dflt_prjcst_period_type         =>  p_dflt_prjcst_period_type,
      p_dflt_prjcst_as_of_date          =>  p_dflt_prjcst_as_of_date,
      p_pa_period_flag                  =>  p_pa_period_flag,
      p_gl_period_flag                  =>  p_gl_period_flag,
      p_conversion_ratio_days           =>  p_conversion_ratio_days,
      p_book_to_bill_days               =>  p_book_to_bill_days,
      p_dso_days                        =>  p_dso_days,
      p_dormant_backlog_days            =>  p_dormant_backlog_days,
      p_cost_budget_type_code           =>  l_cost_budget_type_code,
      p_cost_budget_conv_rule           =>  p_cost_budget_conv_rule,
      p_revenue_budget_type_code        =>  l_revenue_budget_type_code,
      p_revenue_budget_conv_rule        =>  p_revenue_budget_conv_rule,
      p_cost_forecast_type_code         =>  l_cost_forecast_type_code,
      p_cost_forecast_conv_rule         =>  p_cost_forecast_conv_rule,
      p_revenue_forecast_type_code      =>  l_revenue_forecast_type_code,
      p_revenue_forecast_conv_rule      =>  p_revenue_forecast_conv_rule,
      p_report_cost_type                =>  p_report_cost_type,
      p_report_labor_units              =>  p_report_labor_units,
      p_rolling_weeks                   =>  p_rolling_weeks,
      p_config_proj_perf_flag           =>  p_config_proj_perf_flag,
      p_config_cost_flag           	=>  p_config_cost_flag,
      p_config_profit_flag           	=>  p_config_profit_flag,
      p_config_util_flag           	=>  p_config_util_flag,
      p_cost_fp_type_id           	=>  p_cost_fp_type_id,
      p_revenue_fp_type_id           	=>  p_revenue_fp_type_id,
      p_cost_forecast_fp_type_id        =>  p_cost_forecast_fp_type_id,
      p_revenue_forecast_fp_type_id     =>  p_revenue_forecast_fp_type_id,
	  p_global_curr2_flag				=> p_global_curr2_flag,
      x_return_status                   =>  x_return_status,
      x_error_message_code              =>  x_error_message_code);


     IF (x_return_status <> 'S') THEN

         x_return_status := 'E';
         x_error_message_code := 'PJI_ERROR_CREATING_LOG' ;
         RETURN ;

     END IF;


  --
  -- Apply the changes.
  --

  UPDATE pji_system_settings
  SET last_update_date                =  l_last_update_date,
      last_updated_by                 =  l_last_updated_by,
      last_update_login               =  l_last_update_login,
      organization_structure_id       =  l_organization_structure_id,
      org_structure_version_id        =  l_org_structure_version_id,
      dflt_prjpip_period_type         =  p_dflt_prjpip_period_type,
      dflt_prjpip_as_of_date          =  p_dflt_prjpip_as_of_date,
      dflt_prjbab_period_type         =  p_dflt_prjbab_period_type,
      dflt_prjbab_as_of_date          =  p_dflt_prjbab_as_of_date,
      dflt_resutl_period_type         =  p_dflt_resutl_period_type,
      dflt_resutl_as_of_date          =  p_dflt_resutl_as_of_date,
      dflt_resavl_period_type         =  p_dflt_resavl_period_type,
      dflt_resavl_as_of_date          =  p_dflt_resavl_as_of_date,
      dflt_respln_period_type         =  p_dflt_respln_period_type,
      dflt_respln_as_of_date          =  p_dflt_respln_as_of_date,
      dflt_prjhlt_period_type         =  p_dflt_prjhlt_period_type,
      dflt_prjhlt_as_of_date          =  p_dflt_prjhlt_as_of_date,
      dflt_prjact_period_type         =  p_dflt_prjact_period_type,
      dflt_prjact_as_of_date          =  p_dflt_prjact_as_of_date,
      dflt_prjprf_period_type         =  p_dflt_prjprf_period_type,
      dflt_prjprf_as_of_date          =  p_dflt_prjprf_as_of_date,
      dflt_prjcst_period_type         =  p_dflt_prjcst_period_type,
      dflt_prjcst_as_of_date          =  p_dflt_prjcst_as_of_date,
      pa_period_flag                  =  p_pa_period_flag,
      gl_period_flag                  =  p_gl_period_flag,
      conversion_ratio_days           =  p_conversion_ratio_days,
      book_to_bill_days               =  p_book_to_bill_days,
      dso_days                        =  p_dso_days,
      dormant_backlog_days            =  p_dormant_backlog_days,
      cost_budget_type_code           =  l_cost_budget_type_code,
      cost_budget_conv_rule           =  p_cost_budget_conv_rule,
      revenue_budget_type_code        =  l_revenue_budget_type_code,
      revenue_budget_conv_rule        =  p_revenue_budget_conv_rule,
      cost_forecast_type_code         =  l_cost_forecast_type_code,
      cost_forecast_conv_rule         =  p_cost_forecast_conv_rule,
      revenue_forecast_type_code      =  l_revenue_forecast_type_code,
      revenue_forecast_conv_rule      =  p_revenue_forecast_conv_rule,
      report_cost_type                =  p_report_cost_type,
      report_labor_units              =  p_report_labor_units,
      rolling_weeks		      =  p_rolling_weeks,
      config_proj_perf_flag           =  p_config_proj_perf_flag,
      config_cost_flag                =  p_config_cost_flag,
      config_profit_flag              =  p_config_profit_flag,
      config_util_flag                =  p_config_util_flag,
      cost_fp_type_id                 =  p_cost_fp_type_id,
      revenue_fp_type_id              =  p_revenue_fp_type_id,
      cost_forecast_fp_type_id        =  p_cost_forecast_fp_type_id,
      revenue_forecast_fp_type_id     =  p_revenue_forecast_fp_type_id,
	  global_curr2_flag				  =  p_global_curr2_flag;


     x_return_status := 'S';

 EXCEPTION
   WHEN OTHERS THEN
 -- Handle the exception.
     x_return_status := 'U';
     x_error_message_code := SQLERRM ;
 END pji_sys_settings_update_row;

----------------------------------------------------------------------------------------------------------------
-- API          : pji_mt_pip_update_row
-- Description  : This procedure validates and updates Project Probability Buckets.
-- Parameters   :
--           IN :p_name
--               p_seq
--               p_bucket_set_code
--               p_default_flag
--               p_from_value
--               p_to_value
--          OUT NOCOPY  :x_return_status            - Return status.
--               x_error_message_code       - Return Error Code.
----------------------------------------------------------------------------------------------------------------
PROCEDURE pji_mt_pip_update_row (p_name                   IN VARCHAR2,
                                  p_seq                    IN NUMBER,
                                  p_bucket_set_code        IN VARCHAR2,
                                  p_default_flag               IN VARCHAR2,
                                  p_from_value             IN NUMBER,
                                  p_to_value               IN NUMBER,
                                  x_return_status          OUT NOCOPY  VARCHAR2,
                                  x_error_message_code     OUT NOCOPY  VARCHAR2
                 			) IS


  l_created_by          NUMBER;
  l_last_updated_by     NUMBER;
  l_creation_date       DATE;
  l_last_update_date    DATE;
  l_last_update_login   NUMBER;

 BEGIN
  -- need to check status, force user to use adjust if necessary

  IF ( p_from_value < 0 OR p_from_value > 100 ) OR
     ( p_to_value < 0 OR p_to_value > 100 )  THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_PIP_BUCKET_RANGE_INVAL' ;
     RETURN ;

  ELSIF p_from_value > p_to_value THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_PIP_START_END_RANGE_INVAL' ;
     RETURN ;

  ELSIF p_from_value IS NULL OR p_to_value IS NULL THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_PIP_BUCKET_RANGE_NULL' ;
     RETURN ;


  END IF;

  l_created_by          := Fnd_Profile.value('USER_ID');
  l_last_updated_by     := Fnd_Profile.value('USER_ID');
  l_creation_date       := SYSDATE;
  l_last_update_date    := SYSDATE;
  l_last_update_login   := Fnd_Profile.value('USER_ID');

  UPDATE pji_mt_buckets
  SET name                 = p_name,
      last_update_date     = l_last_update_date,
      seq                  = p_seq,
      bucket_set_code      = p_bucket_set_code,
      default_flag         = p_default_flag,
      from_value           = p_from_value,
      to_value             = p_to_value
  WHERE bucket_set_code  = p_bucket_set_code
    AND seq              = p_seq;

  x_return_status := 'S';

 EXCEPTION
   WHEN OTHERS THEN
       x_return_status := 'U';
       x_error_message_code := SQLERRM ;
       RAISE ;

END pji_mt_pip_update_row;

----------------------------------------------------------------------------------------------------------------
-- API          : pji_mt_res_avl_dur_update_row
-- Description  : This procedure validates and updates Resource Availability Buckets.
-- Parameters   :
--           IN :p_name
--               p_seq
--               p_bucket_set_code
--               p_default_flag
--               p_from_value
--               p_to_value
--          OUT NOCOPY  :x_return_status            - Return status.
--               x_error_message_code       - Return Error Code.
----------------------------------------------------------------------------------------------------------------
PROCEDURE pji_mt_res_avl_dur_update_row (p_name                   IN VARCHAR2,
                                  p_seq                    IN NUMBER,
                                  p_bucket_set_code        IN VARCHAR2,
                                  p_default_flag               IN VARCHAR2,
                                  p_from_value             IN NUMBER,
                                  p_to_value               IN NUMBER,
                                  x_return_status          OUT NOCOPY  VARCHAR2,
                                  x_error_message_code     OUT NOCOPY  VARCHAR2
                 			) IS


  l_created_by          NUMBER;
  l_last_updated_by     NUMBER;
  l_creation_date       DATE;
  l_last_update_date    DATE;
  l_last_update_login   NUMBER;

 BEGIN
  -- need to check status, force user to use adjust if necessary

  IF ( p_from_value < 1 ) OR
     ( NVL(p_to_value,1000) < 2 )  THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_AVL_RES_BUCKET_RANGE_INVAL' ;
     RETURN ;

  ELSIF p_from_value > p_to_value THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_AVL_RES_ST_END_RANGE_INVAL' ;
     RETURN ;

  ELSIF (p_from_value IS NULL OR p_from_value = '') THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_AVL_RES_BUCKET_RANGE_NULL' ;
     RETURN ;

  END IF;

  l_created_by          := Fnd_Profile.value('USER_ID');
  l_last_updated_by     := Fnd_Profile.value('USER_ID');
  l_creation_date       := SYSDATE;
  l_last_update_date    := SYSDATE;
  l_last_update_login   := Fnd_Profile.value('USER_ID');

  UPDATE pji_mt_buckets
  SET name                 = p_name,
      last_update_date     = l_last_update_date,
      seq                  = p_seq,
      bucket_set_code      = p_bucket_set_code,
      default_flag         = p_default_flag,
      from_value           = p_from_value,
      to_value             = p_to_value
  WHERE bucket_set_code  = p_bucket_set_code
    AND seq              = p_seq;

  x_return_status := 'S';

 EXCEPTION
   WHEN OTHERS THEN
       x_return_status := 'U';
       x_error_message_code := SQLERRM ;
       RAISE ;

END pji_mt_res_avl_dur_update_row;

----------------------------------------------------------------------------------------------------------------
-- API          : pji_mt_dls_update_row
-- Description  : This procedure validates and updates the Deal Size Buckets.
-- Parameters   :
--           IN :p_name
--               p_seq
--               p_bucket_set_code
--               p_default_flag
--               p_from_value
--               p_to_value
--          OUT NOCOPY  :x_return_status            - Return status.
--               x_error_message_code       - Return Error Code.
----------------------------------------------------------------------------------------------------------------
PROCEDURE pji_mt_dls_update_row (p_name                   IN VARCHAR2,
                                  p_seq                    IN NUMBER,
                                  p_bucket_set_code        IN VARCHAR2,
                                  p_default_flag               IN VARCHAR2,
                                  p_from_value             IN NUMBER,
                                  p_to_value               IN NUMBER,
                                  x_return_status          OUT NOCOPY  VARCHAR2,
                                  x_error_message_code     OUT NOCOPY  VARCHAR2
                 			) IS


  l_created_by          NUMBER;
  l_last_updated_by     NUMBER;
  l_creation_date       DATE;
  l_last_update_date    DATE;
  l_last_update_login   NUMBER;

 BEGIN
  -- need to check status, force user to use adjust if necessary

  IF ( p_from_value < 0 ) OR
     ( p_to_value < 0  )  THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_DLS_RANGE_INVAL' ;
     RETURN ;

  ELSIF p_from_value > p_to_value THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_START_END_RANGE_INVAL' ;
     RETURN ;

  ELSIF p_from_value IS NULL THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_DLS_START_RANGE_NULL' ;
     RETURN ;


  END IF;

  l_created_by          := Fnd_Profile.value('USER_ID');
  l_last_updated_by     := Fnd_Profile.value('USER_ID');
  l_creation_date       := SYSDATE;
  l_last_update_date    := SYSDATE;
  l_last_update_login   := Fnd_Profile.value('USER_ID');

  UPDATE pji_mt_buckets
  SET name                 = p_name,
      last_update_date     = l_last_update_date,
      seq                  = p_seq,
      bucket_set_code      = p_bucket_set_code,
      default_flag         = p_default_flag,
      from_value           = p_from_value,
      to_value             = p_to_value
  WHERE bucket_set_code  = p_bucket_set_code
    AND seq              = p_seq;

  x_return_status := 'S';

 EXCEPTION
   WHEN OTHERS THEN
       x_return_status := 'U';
       x_error_message_code := SQLERRM ;
       RAISE ;

END pji_mt_dls_update_row;

----------------------------------------------------------------------------------------------------------------
-- API          : pji_mt_avl_update_row
-- Description  : This procedure validates and updates the availability Thresholds.
-- Parameters   :
--           IN :p_name
--               p_seq
--               p_bucket_set_code
--               p_default_flag
--               p_from_value
--               p_to_value
--          OUT NOCOPY  :x_return_status            - Return status.
--               x_error_message_code       - Return Error Code.
----------------------------------------------------------------------------------------------------------------
 PROCEDURE pji_mt_avl_update_row (p_name                   IN VARCHAR2,
                                  p_seq                    IN NUMBER,
                                  p_bucket_set_code        IN VARCHAR2,
                                  p_default_flag           IN VARCHAR2,
                                  p_from_value             IN NUMBER,
                                  p_to_value               IN NUMBER,
                                  x_return_status          OUT NOCOPY  VARCHAR2,
                                  x_error_message_code     OUT NOCOPY  VARCHAR2
                 			) IS


  l_created_by          NUMBER;
  l_last_updated_by     NUMBER;
  l_creation_date       DATE;
  l_last_update_date    DATE;
  l_last_update_login   NUMBER;

 BEGIN
  -- need to check status, force user to use adjust if necessary

  IF ( p_to_value < 0  )  THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_AVL_RANGE_INVAL' ;
     RETURN ;

  ELSIF p_to_value IS NULL THEN

     x_return_status := 'E';
     x_error_message_code := 'PJI_AVL_START_RANGE_NULL' ;
     RETURN ;


  END IF;

  l_created_by          := Fnd_Profile.value('USER_ID');
  l_last_updated_by     := Fnd_Profile.value('USER_ID');
  l_creation_date       := SYSDATE;
  l_last_update_date    := SYSDATE;
  l_last_update_login   := Fnd_Profile.value('USER_ID');

  UPDATE pji_mt_buckets
  SET name                 = p_name,
      last_update_date     = l_last_update_date,
      seq                  = p_seq,
      bucket_set_code      = p_bucket_set_code,
      default_flag         = p_default_flag,
      from_value           = p_from_value,
      to_value             = p_to_value
  WHERE bucket_set_code  = p_bucket_set_code
    AND seq              = p_seq;

  x_return_status := 'S';

 EXCEPTION
   WHEN OTHERS THEN
       x_return_status := 'U';
       x_error_message_code := SQLERRM ;
       RAISE ;

 END pji_mt_avl_update_row;

----------------------------------------------------------------------------------------------------------------
-- API          : pji_validate_bucket_ranges
-- Description  : This procedure validates the updated bucket range.
-- Parameters   :
--         OUT NOCOPY   : x_return_status        - Return status.
--                x_error_message_code   - Return Error Code.
----------------------------------------------------------------------------------------------------------------
 PROCEDURE pji_validate_bucket_ranges (x_return_status              OUT NOCOPY  VARCHAR2,
                                       x_error_message_code         OUT NOCOPY  VARCHAR2
                 			) IS



  CURSOR C1 (c_bucket_set_code   IN VARCHAR2) IS
    SELECT 1 FROM DUAL
     WHERE EXISTS (
                   SELECT 'X'
                     FROM pji_mt_buckets a,
                          pji_mt_buckets b
                    WHERE a.bucket_set_code = b.bucket_set_code
                      AND a.bucket_set_code = c_bucket_set_code
                      AND a.from_value <= b.to_value
                      AND b.from_value < b.to_value
                      AND NVL(a.to_value, 99999999999999999999999) > b.to_value );

  CURSOR C2 (c_bucket_set_code   IN VARCHAR2) IS
    SELECT 2 FROM DUAL
     WHERE EXISTS (
                   SELECT 'X'
                     FROM pji_mt_buckets a,
                          pji_mt_buckets b
                    WHERE a.bucket_set_code = b.bucket_set_code
                      AND a.bucket_set_code = c_bucket_set_code
                      AND (b.from_value - a.to_value) > 1
                      AND NVL(b.to_value, 99999999999999999999999) > b.from_value
                      AND a.to_value > a.from_value
                      AND NOT EXISTS ( SELECT 'X'
                                         FROM pji_mt_buckets c
                                        WHERE c.from_value > a.to_value
                                          AND c.to_value < b.from_value ));

  CURSOR C3 IS
    SELECT 3 FROM DUAL
     WHERE EXISTS (SELECT 'X'
                     FROM pji_mt_buckets a,
                          pji_mt_buckets b
                    WHERE a.bucket_set_code = b.bucket_set_code
                      AND a.bucket_set_code = 'PJI_RESOURCE_AVAILABILITY'
                      AND a.seq  > b.seq
                      AND b.to_value > a.to_value) ;



   l_check_overlap           NUMBER ;
   l_check_gaps              NUMBER ;
   l_check_avl_overlap       NUMBER ;
   l_check_min_probability   NUMBER ;
   l_check_max_probability   NUMBER ;

 BEGIN

  --
  -- Validation for Probability buckets
  --

   OPEN C1 ('PJI_PIPELINE_PROBABILITY') ;
   FETCH C1 INTO l_check_overlap ;
      CLOSE C1 ;

   IF l_check_overlap = 1 THEN

      x_return_status := 'E' ;
      x_error_message_code := 'PJI_PIP_BUCKETS_OVERLAP' ;
      RETURN ;

   ELSE

       OPEN C2 ('PJI_PIPELINE_PROBABILITY') ;
       FETCH C2 INTO l_check_gaps ;
          CLOSE C2 ;

       IF l_check_gaps = 2 THEN

          x_return_status := 'E' ;
          x_error_message_code := 'PJI_PIP_BUCKETS_GAPS' ;
          RETURN ;
       END IF;
   END IF ;
   x_return_status := 'S' ;

   SELECT MIN(a.from_value), MAX(a.to_value)
     INTO l_check_min_probability, l_check_max_probability
     FROM pji_mt_buckets a
    WHERE a.bucket_set_code = 'PJI_PIPELINE_PROBABILITY' ;

    IF l_check_min_probability > 0 OR l_check_max_probability < 100 THEN

          x_return_status := 'E' ;
          x_error_message_code := 'PJI_PROBABILITY_GAPS' ;
          RETURN ;
    END IF;

  --
  -- Validation for Deal Size buckets
  --

   OPEN C1 ('PJI_PIPELINE_DEAL_SIZE') ;
   FETCH C1 INTO l_check_overlap ;
      CLOSE C1 ;

   IF l_check_overlap = 1 THEN

      x_return_status := 'E' ;
      x_error_message_code := 'PJI_DLS_BUCKETS_OVERLAP' ;
      RETURN ;

   ELSE

       OPEN C2 ('PJI_PIPELINE_DEAL_SIZE') ;
       FETCH C2 INTO l_check_gaps ;
          CLOSE C2 ;

       IF l_check_gaps = 2 THEN

          x_return_status := 'E' ;
          x_error_message_code := 'PJI_DLS_BUCKETS_GAPS' ;
          RETURN ;
       END IF;
   END IF ;
   x_return_status := 'S' ;

   OPEN C3  ;
   FETCH C3 INTO l_check_avl_overlap ;
      CLOSE C3 ;

   IF l_check_avl_overlap = 3 THEN

      x_return_status := 'E' ;
      x_error_message_code := 'PJI_AVL_BUCKETS_OVERLAP' ;
      RETURN ;

   END IF;

--
-- Validation for Available Resource Duration buckets
--
   OPEN C1 ('PJI_RES_AVL_DAYS') ;
   	FETCH C1 INTO l_check_overlap ;
   CLOSE C1 ;

   IF l_check_overlap = 1 THEN

      x_return_status := 'E' ;
      x_error_message_code := 'PJI_AVL_RES_BUCKET_OVERLAP' ;
      RETURN ;

   ELSE

       OPEN C2 ('PJI_RES_AVL_DAYS') ;
       FETCH C2 INTO l_check_gaps ;
          CLOSE C2 ;

       IF l_check_gaps = 2 THEN

          x_return_status := 'E' ;
          x_error_message_code := 'PJI_AVL_RES_GAP' ;
          RETURN ;
       END IF;
   END IF ;
   x_return_status := 'S' ;

   SELECT MIN(a.from_value), MIN(NVL(a.to_value,1000))
     INTO l_check_min_probability, l_check_max_probability
     FROM pji_mt_buckets a
    WHERE a.bucket_set_code = 'PJI_RES_AVL_DAYS' ;

    IF l_check_min_probability <> 1 OR l_check_max_probability < 2 THEN

          x_return_status := 'E' ;
          x_error_message_code := 'PJI_AVL_RES_INVAL' ;
          RETURN ;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
       x_return_status := 'U';
       RAISE ;

 END pji_validate_bucket_ranges;


----------------------------------------------------------------------------------------------------------------
-- API          : pji_insert_events_log
-- Description  : This procedure creates the audit record.
----------------------------------------------------------------------------------------------------------------
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
      p_rolling_weeks                   IN NUMBER,
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
      x_error_message_code             OUT NOCOPY  VARCHAR2) IS

  CURSOR Cur_PjiSysSettings IS
  SELECT *
  FROM pji_system_settings ;

  Cur_PjiRowtype    Cur_PjiSysSettings%ROWTYPE ;

TYPE EventAttribute IS RECORD (
                               attribute_name                 VARCHAR2(30),
                               attribute_old_value            VARCHAR2(30),
                               attribute_new_value            VARCHAR2(30));

TYPE EventAttribTabTyp_Rec IS TABLE OF EventAttribute INDEX BY BINARY_INTEGER;

EventAttribTabTyp  EventAttribTabTyp_Rec;


        l_pji_rowid     VARCHAR2(1000) := NULL ;
        l_pji_event_id  NUMBER := NULL ;
        i               NUMBER := 1;

 l_pji_sys_char_rec          Pa_Plsql_Datatypes.IdTabTyp;
 l_pji_sys_num_rec           Pa_Plsql_Datatypes.Char30TabTyp;

 BEGIN

    OPEN  Cur_PjiSysSettings ;
    FETCH Cur_PjiSysSettings INTO Cur_PjiRowtype ;
    CLOSE Cur_PjiSysSettings ;



    IF Cur_PjiRowtype.organization_structure_id <> p_organization_structure_id THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'ORGANIZATION_STRUCTURE_ID';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.organization_structure_id;
        EventAttribTabTyp(i).attribute_new_value := p_organization_structure_id;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.org_structure_version_id <> p_org_structure_version_id THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'ORG_STRUCTURE_VERSION_ID';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.org_structure_version_id;
        EventAttribTabTyp(i).attribute_new_value := p_org_structure_version_id;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_prjpip_period_type <> p_dflt_prjpip_period_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJPIP_PERIOD_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjpip_period_type;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjpip_period_type;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_prjpip_as_of_date <> p_dflt_prjpip_as_of_date THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJPIP_AS_OF_DATE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjpip_as_of_date;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjpip_as_of_date;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_prjbab_period_type <> p_dflt_prjbab_period_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJBAB_PERIOD_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjbab_period_type;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjbab_period_type;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_prjbab_as_of_date <> p_dflt_prjbab_as_of_date THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJBAB_AS_OF_DATE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjbab_as_of_date;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjbab_as_of_date;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.dflt_resutl_period_type <> p_dflt_resutl_period_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_RESUTL_PERIOD_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_resutl_period_type;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_resutl_period_type;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.dflt_resutl_as_of_date <> p_dflt_resutl_as_of_date THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_RESUTL_AS_OF_DATE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_resutl_as_of_date;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_resutl_as_of_date;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.dflt_resavl_period_type <> p_dflt_resavl_period_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_RESAVL_PERIOD_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_resavl_period_type;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_resavl_period_type;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_resavl_as_of_date <> p_dflt_resavl_as_of_date THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_RESAVL_AS_OF_DATE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_resavl_as_of_date;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_resavl_as_of_date;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.dflt_respln_period_type <> p_dflt_respln_period_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_RESPLN_PERIOD_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_respln_period_type;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_respln_period_type;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.dflt_respln_as_of_date <> p_dflt_respln_as_of_date THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_RESPLN_AS_OF_DATE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_respln_as_of_date;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_respln_as_of_date;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_prjhlt_period_type <> p_dflt_prjhlt_period_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJHLT_PERIOD_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjhlt_period_type;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjhlt_period_type;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_prjhlt_as_of_date <> p_dflt_prjhlt_as_of_date THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJHLT_AS_OF_DATE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjhlt_as_of_date;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjhlt_as_of_date;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.dflt_prjact_period_type <> p_dflt_prjact_period_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJACT_PERIOD_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjact_period_type;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjact_period_type;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_prjact_as_of_date <> p_dflt_prjact_as_of_date THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJACT_AS_OF_DATE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjact_as_of_date;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjact_as_of_date;
        --Increment the index
             i := i + 1;
    END IF;



    IF Cur_PjiRowtype.dflt_prjprf_period_type <> p_dflt_prjprf_period_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJPRF_PERIOD_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjprf_period_type;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjprf_period_type ;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_prjprf_as_of_date <> p_dflt_prjprf_as_of_date THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJPRF_AS_OF_DATE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjprf_as_of_date;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjprf_as_of_date;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.dflt_prjcst_period_type <> p_dflt_prjcst_period_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJCST_PERIOD_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjcst_period_type;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjcst_period_type;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dflt_prjcst_as_of_date <> p_dflt_prjcst_as_of_date THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DFLT_PRJCST_AS_OF_DATE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dflt_prjcst_as_of_date;
        EventAttribTabTyp(i).attribute_new_value := p_dflt_prjcst_as_of_date;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.pa_period_flag <> p_pa_period_flag THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'PA_PERIOD_FLAG';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.pa_period_flag;
        EventAttribTabTyp(i).attribute_new_value := p_pa_period_flag;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.gl_period_flag <> p_gl_period_flag THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'GL_PERIOD_FLAG';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.gl_period_flag;
        EventAttribTabTyp(i).attribute_new_value := p_gl_period_flag;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.rolling_weeks <> p_rolling_weeks THEN
           -- Assign the attributes
            EventAttribTabTyp(i).attribute_name      := 'ROLLING_WEEKS';
            EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.rolling_weeks;
            EventAttribTabTyp(i).attribute_new_value := p_rolling_weeks;
            --Increment the index
                 i := i + 1;
    END IF;

    IF Cur_PjiRowtype.conversion_ratio_days <> p_conversion_ratio_days THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'CONVERSION_RATIO_DAYS';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.conversion_ratio_days;
        EventAttribTabTyp(i).attribute_new_value := p_conversion_ratio_days;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.book_to_bill_days <> p_book_to_bill_days THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'BOOK_TO_BILL_DAYS';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.book_to_bill_days;
        EventAttribTabTyp(i).attribute_new_value := p_book_to_bill_days;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dso_days <> p_dso_days THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DSO_DAYS';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dso_days;
        EventAttribTabTyp(i).attribute_new_value := p_dso_days;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.dormant_backlog_days <> p_dormant_backlog_days THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'DORMANT_BACKLOG_DAYS';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.dormant_backlog_days;
        EventAttribTabTyp(i).attribute_new_value := p_dormant_backlog_days;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.cost_budget_type_code <> p_cost_budget_type_code THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'COST_BUDGET_TYPE_CODE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.cost_budget_type_code;
        EventAttribTabTyp(i).attribute_new_value := p_cost_budget_type_code;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.cost_budget_conv_rule <> p_cost_budget_conv_rule THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'COST_BUDGET_CONV_RULE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.cost_budget_conv_rule;
        EventAttribTabTyp(i).attribute_new_value := p_cost_budget_conv_rule;
        --Increment the index
             i := i + 1;
    END IF;


    IF Cur_PjiRowtype.revenue_budget_type_code <> p_revenue_budget_type_code THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'REVENUE_BUDGET_TYPE_CODE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.revenue_budget_type_code;
        EventAttribTabTyp(i).attribute_new_value := p_revenue_budget_type_code;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.revenue_budget_conv_rule <> p_revenue_budget_conv_rule THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'REVENUE_BUDGET_CONV_RULE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.revenue_budget_conv_rule;
        EventAttribTabTyp(i).attribute_new_value := p_revenue_budget_conv_rule;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.cost_forecast_type_code <> p_cost_forecast_type_code THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'COST_FORECAST_TYPE_CODE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.cost_forecast_type_code;
        EventAttribTabTyp(i).attribute_new_value := p_cost_forecast_type_code;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.cost_forecast_conv_rule <> p_cost_forecast_conv_rule THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'COST_FORECAST_CONV_RULE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.cost_forecast_conv_rule;
        EventAttribTabTyp(i).attribute_new_value := p_cost_forecast_conv_rule;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.revenue_forecast_type_code <> p_revenue_forecast_type_code THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'REVENUE_FORECAST_TYPE_CODE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.revenue_forecast_type_code;
        EventAttribTabTyp(i).attribute_new_value := p_revenue_forecast_type_code;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.revenue_forecast_conv_rule <> p_revenue_forecast_conv_rule THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'REVENUE_FORECAST_CONV_RULE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.revenue_forecast_conv_rule;
        EventAttribTabTyp(i).attribute_new_value := p_revenue_forecast_conv_rule;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.report_cost_type <> p_report_cost_type THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'REPORT_COST_TYPE';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.report_cost_type;
        EventAttribTabTyp(i).attribute_new_value := p_report_cost_type;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.report_labor_units <> p_report_labor_units THEN
       -- Assign the attributes
        EventAttribTabTyp(i).attribute_name      := 'REPORT_LABOR_UNITS';
        EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.report_labor_units;
        EventAttribTabTyp(i).attribute_new_value := p_report_labor_units;
        --Increment the index
             i := i + 1;
    END IF;

    IF Cur_PjiRowtype.config_proj_perf_flag <> p_config_proj_perf_flag THEN
           -- Assign the attributes
            EventAttribTabTyp(i).attribute_name      := 'CONFIG_PROJ_PERF_FLAG';
            EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.config_proj_perf_flag;
            EventAttribTabTyp(i).attribute_new_value := p_config_proj_perf_flag;
            --Increment the index
                 i := i + 1;
    END IF;

    IF Cur_PjiRowtype.config_cost_flag <> p_config_cost_flag THEN
               -- Assign the attributes
                EventAttribTabTyp(i).attribute_name      := 'CONFIG_COST_FLAG';
                EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.config_cost_flag;
                EventAttribTabTyp(i).attribute_new_value := p_config_cost_flag;
                --Increment the index
                     i := i + 1;
    END IF;

    IF Cur_PjiRowtype.config_profit_flag <> p_config_profit_flag THEN
                   -- Assign the attributes
                    EventAttribTabTyp(i).attribute_name      := 'CONFIG_PROFIT_FLAG';
                    EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.config_profit_flag;
                    EventAttribTabTyp(i).attribute_new_value := p_config_profit_flag;
                    --Increment the index
                         i := i + 1;
    END IF;

    IF Cur_PjiRowtype.config_util_flag <> p_config_util_flag THEN
                   -- Assign the attributes
                    EventAttribTabTyp(i).attribute_name      := 'CONFIG_UTIL_FLAG';
                    EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.config_util_flag;
                    EventAttribTabTyp(i).attribute_new_value := p_config_util_flag;
                    --Increment the index
                         i := i + 1;
    END IF;

    IF Cur_PjiRowtype.cost_fp_type_id <> p_cost_fp_type_id THEN
		       -- Assign the attributes
			EventAttribTabTyp(i).attribute_name      := 'COST_FP_TYPE_ID';
			EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.cost_fp_type_id;
			EventAttribTabTyp(i).attribute_new_value := p_cost_fp_type_id;
			--Increment the index
			     i := i + 1;
    END IF;

    IF Cur_PjiRowtype.revenue_fp_type_id <> p_revenue_fp_type_id THEN
		   -- Assign the attributes
		    EventAttribTabTyp(i).attribute_name      := 'REVENUE_FP_TYPE_ID';
		    EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.revenue_fp_type_id;
		    EventAttribTabTyp(i).attribute_new_value := p_revenue_fp_type_id;
		    --Increment the index
			 i := i + 1;
    END IF;

    IF Cur_PjiRowtype.cost_forecast_fp_type_id <> p_cost_forecast_fp_type_id THEN
	       -- Assign the attributes
		EventAttribTabTyp(i).attribute_name      := 'COST_FORECAST_FP_TYPE_ID';
		EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.cost_forecast_fp_type_id;
		EventAttribTabTyp(i).attribute_new_value := p_cost_forecast_fp_type_id;
		--Increment the index
		     i := i + 1;
    END IF;

    IF Cur_PjiRowtype.revenue_forecast_fp_type_id <> p_revenue_forecast_fp_type_id THEN
    		   -- Assign the attributes
    		    EventAttribTabTyp(i).attribute_name      := 'REVENUE_FORECAST_FP_TYPE_ID';
    		    EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.revenue_forecast_fp_type_id;
    		    EventAttribTabTyp(i).attribute_new_value := p_revenue_forecast_fp_type_id;
    		    --Increment the index
    			 i := i + 1;
    END IF;

    IF Cur_PjiRowtype.global_curr2_flag <> p_global_curr2_flag THEN
    		   -- Assign the attributes
    		    EventAttribTabTyp(i).attribute_name      := 'GLOBAL_CURR2_FLAG';
    		    EventAttribTabTyp(i).attribute_old_value := Cur_PjiRowtype.global_curr2_flag;
    		    EventAttribTabTyp(i).attribute_new_value := p_global_curr2_flag;
    		    --Increment the index
    			 i := i + 1;
    END IF;



    FOR ROWS IN 1..i-1 LOOP

		l_pji_rowid   := NULL;
		l_pji_event_id := NULL;

--Should the call be in I/U mode ?
Pa_Pji_Proj_Events_Log_Pkg.Insert_Row(
                X_ROW_ID                => l_pji_rowid
                ,X_EVENT_ID             => l_pji_event_id
                ,X_EVENT_TYPE           => 'PJI_SETUP_CHANGE'
                ,X_EVENT_OBJECT         =>  EventAttribTabTyp(ROWS).attribute_name
                ,X_OPERATION_TYPE       => 'U' -- update mode
                ,X_STATUS               => 'X' --NULL
                ,X_ATTRIBUTE_CATEGORY   => NULL
                ,X_ATTRIBUTE1           => EventAttribTabTyp(ROWS).attribute_new_value
                ,X_ATTRIBUTE2           => EventAttribTabTyp(ROWS).attribute_old_value
                ,X_ATTRIBUTE3           => NULL
                ,X_ATTRIBUTE4           => NULL
                ,X_ATTRIBUTE5           => NULL
                ,X_ATTRIBUTE6           => NULL
                ,X_ATTRIBUTE7           => NULL
                ,X_ATTRIBUTE8           => NULL
                ,X_ATTRIBUTE9           => NULL
                ,X_ATTRIBUTE10          => NULL
                ,X_ATTRIBUTE11          => NULL
                ,X_ATTRIBUTE12          => NULL
                ,X_ATTRIBUTE13          => NULL
                ,X_ATTRIBUTE14          => NULL
                ,X_ATTRIBUTE15          => NULL
                ,X_ATTRIBUTE16          => NULL
                ,X_ATTRIBUTE17          => NULL
                ,X_ATTRIBUTE18          => NULL
                ,X_ATTRIBUTE19          => NULL
                ,X_ATTRIBUTE20          => NULL
                  );

     END LOOP;

 END pji_insert_events_log ;


----------------------------------------------------------------------------------------------------------------
-- API          : Check_Org_structure
-- Description  : This procedure validates and returns a valid organization structure id.
-- Parameters   :
--           IN :p_Org_structure       - Organization Structure Name.
--          OUT NOCOPY  :x_Org_structure_id    - Organization Structure Id.
--               x_return_status       - Return status.
--               x_error_message_code  - Return Error Code.
----------------------------------------------------------------------------------------------------------------
PROCEDURE Check_Org_structure
                ( p_Org_structure              IN  VARCHAR2
                 ,x_Org_structure_id           OUT NOCOPY  VARCHAR2
                 ,x_return_status      OUT NOCOPY  VARCHAR2
                 ,x_error_message_code OUT NOCOPY  VARCHAR2) IS


        l_current_id    NUMBER ;
        l_num_ids       NUMBER := 0;
        CURSOR c_ids IS
                SELECT s.organization_structure_id
                  FROM per_organization_structures s
                 WHERE s.name = p_Org_structure ;



BEGIN
        IF (p_Org_structure IS NULL) THEN
             -- Return a null ID since the name is null.
             x_Org_structure_id := NULL;

        ELSE
             -- Find the ID which matches the Name passed
             OPEN c_ids;
             LOOP
                 FETCH c_ids INTO l_current_id;
                 EXIT WHEN c_ids%NOTFOUND;
             END LOOP;
             l_num_ids := c_ids%ROWCOUNT;
             CLOSE c_ids;

             IF (l_num_ids = 0) THEN
                 -- No IDs for name
                 RAISE NO_DATA_FOUND;
             ELSIF (l_num_ids = 1) THEN
                 -- Since there is only one ID for the name use it.
                 x_Org_structure_id := l_current_id;
             ELSIF (l_num_ids > 1 ) THEN
                 -- More than one ID for the name and none of the IDs matched
                 -- the ID passed in.
                 RAISE TOO_MANY_ROWS;
             END IF;
        END IF; -- end if for p_Org_structure IS NULL
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_error_message_code := 'PJI_ORG_STRUCTURE_INVALID';
      x_Org_structure_id := NULL;
        WHEN TOO_MANY_ROWS THEN
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_error_message_code := 'PJI_ORG_STRUCTURE_AMBIGUOUS';
      x_Org_structure_id := NULL;
        WHEN OTHERS THEN
         x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
     x_Org_structure_id := NULL;
         RAISE ;

END Check_Org_structure;

----------------------------------------------------------------------------------------------------------------
-- API          : Check_Org_structure_Version
-- Description  : This procedure validates and returns a valid organization structure version id.
-- Parameters   :
--           IN :p_Org_structure_version    - Organization Structure Version Name.
--               p_Org_structure_id         - Organization Structure Id.
--          OUT NOCOPY  :x_Org_structure_version_id - Organization Structure Version Id.
--               x_return_status            - Return status.
--               x_error_message_code       - Return Error Code.
----------------------------------------------------------------------------------------------------------------
PROCEDURE Check_Org_structure_Version
                ( p_Org_structure_version      IN  VARCHAR2
                 ,p_Org_structure_id           IN  NUMBER
                 ,x_Org_structure_version_id   OUT NOCOPY  VARCHAR2
                 ,x_return_status              OUT NOCOPY  VARCHAR2
                 ,x_error_message_code         OUT NOCOPY  VARCHAR2) IS


        l_current_id    NUMBER ;
        l_num_ids       NUMBER := 0;
        CURSOR c_ids IS
                SELECT v.org_structure_version_id
                  FROM per_org_structure_versions v
                 WHERE v.organization_structure_id = p_Org_structure_id
                   AND v.version_number = p_Org_structure_version ;



BEGIN
        IF (p_Org_structure_version IS NULL) THEN
             -- Return a null ID since the name is null.
             x_Org_structure_version_id := NULL;

        ELSE
             -- Find the ID which matches the Name passed
             OPEN c_ids;
             LOOP
                 FETCH c_ids INTO l_current_id;
                 EXIT WHEN c_ids%NOTFOUND;
             END LOOP;
             l_num_ids := c_ids%ROWCOUNT;
             CLOSE c_ids;

             IF (l_num_ids = 0) THEN
                 -- No IDs for name
                 RAISE NO_DATA_FOUND;
             ELSIF (l_num_ids = 1) THEN
                 -- Since there is only one ID for the name use it.
                 x_Org_structure_version_id := l_current_id;
             ELSIF (l_num_ids > 1 ) THEN
                 -- More than one ID for the name and none of the IDs matched
                 -- the ID passed in.
                 RAISE TOO_MANY_ROWS;
             END IF;
        END IF; -- end if for p_Org_structure_version IS NULL
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_error_message_code := 'PJI_ORG_STRUCTURE_VER_INVALID';
      x_Org_structure_version_id := NULL;
        WHEN TOO_MANY_ROWS THEN
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_error_message_code := 'PJI_ORG_STRUCT_VER_AMBIGUOUS';
      x_Org_structure_version_id := NULL;
        WHEN OTHERS THEN
         x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
     x_Org_structure_version_id := NULL;
         RAISE ;

END Check_Org_structure_Version;

----------------------------------------------------------------------------------------------------------------
-- API          : Check_Budget_Type
-- Description  : This procedure checks and returns a valid budget type code.
-- Parameters   :
--           IN :p_budget_type         - Budget Type.
--               p_amount_type_code    - Amount Type Code (Rev or Cost)
--          OUT NOCOPY  :x_budget_type_code
--               x_return_status       - Return status.
--               x_error_message_code  - Return Error Code.
----------------------------------------------------------------------------------------------------------------
PROCEDURE Check_Budget_Type
                ( p_budget_type                 IN  VARCHAR2
                 ,p_amount_type_code            IN  VARCHAR2
                 ,x_budget_type_code           OUT NOCOPY  VARCHAR2
                 ,x_return_status              OUT NOCOPY  VARCHAR2
                 ,x_error_message_code         OUT NOCOPY  VARCHAR2) IS


        l_current_id    VARCHAR2(100);
        l_num_ids       NUMBER := 0;
        CURSOR c_ids IS
                SELECT bt.budget_type_code
                  FROM pa_budget_types bt
                 WHERE bt.budget_type = p_budget_type
                   AND bt.budget_amount_code = p_amount_type_code ;



BEGIN
        IF (p_budget_type IS NULL) THEN
             -- Return a null ID since the name is null.
             x_budget_type_code := NULL;

        ELSE
             -- Find the ID which matches the Name passed
             OPEN c_ids;
             LOOP
                 FETCH c_ids INTO l_current_id;
                 EXIT WHEN c_ids%NOTFOUND;
             END LOOP;
             l_num_ids := c_ids%ROWCOUNT;
             CLOSE c_ids;

             IF (l_num_ids = 0) THEN
                 -- No IDs for name
                 RAISE NO_DATA_FOUND;
             ELSIF (l_num_ids = 1) THEN
                 -- Since there is only one ID for the name use it.
                 x_budget_type_code := l_current_id;
             ELSIF (l_num_ids > 1 ) THEN
                 -- More than one ID for the name and none of the IDs matched
                 -- the ID passed in.
                 RAISE TOO_MANY_ROWS;
             END IF;
        END IF; -- end if for p_budget_type IS NULL
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_error_message_code := 'PA_BUDGET_TYPE_INVALID';
      x_budget_type_code := NULL;
        WHEN TOO_MANY_ROWS THEN
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_error_message_code := 'PA_BUDGET_TYPE_AMBIGUOUS';
      x_budget_type_code := NULL;
        WHEN OTHERS THEN
         x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
     x_budget_type_code := NULL;
         RAISE ;

END Check_Budget_Type;

PROCEDURE Derive_Summarization_Flags
                ( x_base_summary_flag           OUT NOCOPY  VARCHAR2
                 ,x_intelligence_flag              OUT NOCOPY  VARCHAR2
                 ,x_performance_flag         OUT NOCOPY  VARCHAR2) IS
BEGIN
	 IF Pji_Process_Util.SUMMARIZATION_STARTED('STAGE1_EXTR') = 'NOT_STARTED' THEN
	 	x_base_summary_flag := 'N';
	 ELSE
	 	x_base_summary_flag := 'Y';
	 END IF;

	 IF Pji_Process_Util.SUMMARIZATION_STARTED('STAGE2_PJI') = 'NOT_STARTED' THEN
	 	x_intelligence_flag := 'N';
	 ELSE
	 	x_intelligence_flag := 'Y';
	 END IF;

	 IF Pji_Process_Util.SUMMARIZATION_STARTED('STAGE3_PJP') = 'NOT_STARTED' THEN
	 	x_performance_flag := 'N';
	 ELSE
	 	x_performance_flag := 'Y';
	 END IF;
END Derive_Summarization_Flags;

END Pji_Setup_Pkg;

/
