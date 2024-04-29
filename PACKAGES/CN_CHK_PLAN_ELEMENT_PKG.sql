--------------------------------------------------------
--  DDL for Package CN_CHK_PLAN_ELEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CHK_PLAN_ELEMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: cnchkpes.pls 120.4 2005/09/14 02:41:27 rarajara ship $ */
-- Modified on 07/19/99, Added more columns in the pe_rec_type
   TYPE pe_rec_type IS RECORD (
      NAME                          cn_quotas.NAME%TYPE := fnd_api.g_miss_char,
      quota_id                      cn_quotas.quota_id%TYPE := NULL,
      description                   cn_quotas.description%TYPE := NULL,
      start_period_id               NUMBER := NULL,
      start_period_name             cn_periods.period_name%TYPE := fnd_api.g_miss_char,
      end_period_id                 NUMBER := NULL,
      start_date                    cn_quotas.start_date%TYPE := fnd_api.g_miss_date,
      end_date                      cn_quotas.end_date%TYPE := NULL,
      quota_status                        cn_quotas.quota_status%TYPE := NULL,
      interval_name                 cn_interval_types.NAME%TYPE := NULL,
      interval_type_id              cn_interval_types.interval_type_id%TYPE := NULL,
      payee_assign_flag             cn_quotas.payee_assign_flag%TYPE := 'N',
      vesting_flag                  cn_quotas.vesting_flag%TYPE := 'N',
--   quota_group_code  cn_quotas.quota_group_code%TYPE
--        := NULL,
      end_period_name               cn_periods.period_name%TYPE := fnd_api.g_miss_char,
--   period_type_code    cn_quotas.period_type_code%TYPE
--                          := FND_API.G_MISS_CHAR,
      quota_type_code               cn_quotas.quota_type_code%TYPE := fnd_api.g_miss_char,
--   disc_option_code    cn_quotas.discount_option_code%TYPE
--                          := FND_API.G_MISS_CHAR,
      trx_group_code                cn_quotas.trx_group_code%TYPE := fnd_api.g_miss_char,
      target                        cn_quotas.target%TYPE := fnd_api.g_miss_num,
--   payment_type_code   cn_quotas.payment_type_code%TYPE
--                          := FND_API.G_MISS_CHAR,
      payment_amount                cn_quotas.payment_amount%TYPE := fnd_api.g_miss_num,
      calc_formula_id               cn_quotas.calc_formula_id%TYPE := NULL,
      quota_rule_id                 cn_quota_rules.quota_rule_id%TYPE := NULL,
      calc_formula_name             cn_calc_formulas.NAME%TYPE := NULL,
      incentive_type_code           cn_quotas.incentive_type_code%TYPE := fnd_api.g_miss_char,
      credit_type                   cn_credit_types.NAME%TYPE := fnd_api.g_miss_char,
      credit_type_id                cn_credit_types.credit_type_id%TYPE := NULL,
      rt_sched_custom_flag          cn_quotas.rt_sched_custom_flag%TYPE := fnd_api.g_miss_char,
      performance_goal              cn_quotas.performance_goal%TYPE := NULL,
--   quota_unspecified  cn_quotas.quota_unspecified%TYPE
--        := NULL,
      package_name                  cn_quotas.package_name%TYPE := NULL,
      split_flag                    cn_quotas.split_flag%TYPE := fnd_api.g_miss_char,
      itd_flag                      cn_calc_formulas.itd_flag%TYPE := fnd_api.g_miss_char,
      cumulative_flag               cn_quotas.cumulative_flag%TYPE := NULL,
      rate_table_id                 cn_rate_schedules.rate_schedule_id%TYPE := NULL,
      rate_table_name               cn_rate_schedules.NAME%TYPE := fnd_api.g_miss_char,
      disc_rate_table_id            cn_rate_schedules.rate_schedule_id%TYPE := NULL,
      disc_rate_table_name          cn_rate_schedules.NAME%TYPE := fnd_api.g_miss_char,
      rev_class_id                  cn_quota_rules.revenue_class_id%TYPE := NULL,
      rev_class_name                cn_quota_rules.NAME%TYPE := fnd_api.g_miss_char,
      rev_class_target              cn_quota_rules.target%TYPE := fnd_api.g_miss_num,
      rev_class_payment_amount      cn_quota_rules.payment_amount%TYPE := fnd_api.g_miss_num,
      rev_class_performance_goal    cn_quota_rules.performance_goal%TYPE := fnd_api.g_miss_num,
      rev_class_payment_uplift      cn_quota_rule_uplifts.payment_factor%TYPE := NULL,
      rev_class_quota_uplift        cn_quota_rule_uplifts.quota_factor%TYPE := NULL,
      rev_uplift_start_date         cn_quota_rule_uplifts.start_date%TYPE := fnd_api.g_miss_date,
      rev_uplift_end_date           cn_quota_rule_uplifts.end_date%TYPE := fnd_api.g_miss_date,
--   usage_code               cn_quotas.usage_code%TYPE
--                              := 'ABSOLUTE',
      addup_from_rev_class_flag     cn_quotas.addup_from_rev_class_flag%TYPE := NULL,
      attribute_category            cn_quotas.attribute_category%TYPE := NULL,
      attribute1                    cn_quotas.attribute1%TYPE := NULL,
      attribute2                    cn_quotas.attribute2%TYPE := NULL,
      attribute3                    cn_quotas.attribute3%TYPE := NULL,
      attribute4                    cn_quotas.attribute4%TYPE := NULL,
      attribute5                    cn_quotas.attribute5%TYPE := NULL,
      attribute6                    cn_quotas.attribute6%TYPE := NULL,
      attribute7                    cn_quotas.attribute7%TYPE := NULL,
      attribute8                    cn_quotas.attribute8%TYPE := NULL,
      attribute9                    cn_quotas.attribute9%TYPE := NULL,
      attribute10                   cn_quotas.attribute10%TYPE := NULL,
      attribute11                   cn_quotas.attribute11%TYPE := NULL,
      attribute12                   cn_quotas.attribute12%TYPE := NULL,
      attribute13                   cn_quotas.attribute13%TYPE := NULL,
      attribute14                   cn_quotas.attribute14%TYPE := NULL,
      attribute15                   cn_quotas.attribute15%TYPE := NULL,
      org_id                        cn_quotas.org_id%TYPE := NULL,
      object_version_number         cn_quotas.object_version_number%type,
      indirect_credit               cn_quotas.indirect_credit%type
   );

   g_miss_pe_rec                 pe_rec_type;

   TYPE pe_rec_tbl_type IS TABLE OF pe_rec_type
      INDEX BY BINARY_INTEGER;

   g_miss_pe_rec_tbl             pe_rec_tbl_type;
-- Global variablefor  the translatable name for all Plan Element objects.
   g_pe_name            CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('PE_NAME', 'PE_OBJECT_TYPE');
   g_desc               CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('DESC', 'PE_OBJECT_TYPE');
   g_start_period       CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('START_PERIOD', 'PE_OBJECT_TYPE');
   g_start_period_id    CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('START_PERIOD_ID', 'PE_OBJECT_TYPE');
   g_end_period         CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('END_PERIOD', 'PE_OBJECT_TYPE');
   g_end_period_id      CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('END_PERIOD_ID', 'PE_OBJECT_TYPE');
   g_period_type        CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('PERIOD_TYPE', 'PE_OBJECT_TYPE');
   g_element_type       CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('QUOTA_TYPE', 'PE_OBJECT_TYPE');
   g_disc_option        CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('DISC_OPTION', 'PE_OBJECT_TYPE');
   g_trx_group          CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('TRX_GROUP', 'PE_OBJECT_TYPE');
   g_target             CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('TARGET', 'PE_OBJECT_TYPE');
   g_payment_type       CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('PAYMENT_TYPE', 'PE_OBJECT_TYPE');
   g_payment_amout      CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('PAYMENT_AMOUT', 'PE_OBJECT_TYPE');
   g_rate_tb            CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('RATE_TB', 'PE_OBJECT_TYPE');
   g_rate_tb_id         CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('RATE_TB_ID', 'PE_OBJECT_TYPE');
   g_disc_rate_tb       CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('DISC_RATE_TB', 'PE_OBJECT_TYPE');
   g_disc_rate_tb_id    CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('DISC_RATE_TB_ID', 'PE_OBJECT_TYPE');
   g_split              CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('SPLIT_FLAG', 'PE_OBJECT_TYPE');
   g_accmulate          CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('CUM_FLAG', 'PE_OBJECT_TYPE');
   g_itd                CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('ITD_FLAG', 'PE_OBJECT_TYPE');
   g_rev_cls_name       CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('REV_CLS_NAME', 'PE_OBJECT_TYPE');
   g_rev_cls_id         CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('REV_CLS_ID', 'PE_OBJECT_TYPE');
   g_rev_cls_target     CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('REV_CLS_TARGET', 'PE_OBJECT_TYPE');
   g_payment_factor     CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('PAYMENT_FACTOR', 'PE_OBJECT_TYPE');
   g_quota_factor       CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('QUOTA_FACTOR', 'PE_OBJECT_TYPE');
   g_draw_amount        CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('DRAW_AMOUNT', 'PE_OBJECT_TYPE');
   g_uplift_start_date  CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('UPLIFT_START_DATE', 'PE_OBJECT_TYPE');
   g_uplift_end_date    CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('UPLIFT_END_DATE', 'PE_OBJECT_TYPE');
   g_start_date         CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('START_DATE', 'PE_OBJECT_TYPE');
   g_end_date           CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('END_DATE', 'PE_OBJECT_TYPE');
   g_uplift_payment_factor CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('UPLIFT_PAYMENT_FACTOR', 'PE_OBJECT_TYPE');
   g_uplift_quota_factor CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('UPLIFT_QUOTA_FACTOR', 'PE_OBJECT_TYPE');
   g_formula_name       CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('CALC_FORMULA_NAME', 'PE_OBJECT_TYPE');
   g_formula_id         CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('CALC_FORMULA_ID', 'PE_OBJECT_TYPE');
   g_package_name       CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('PACKAGE_NAME', 'PE_OBJECT_TYPE');
   g_credit_type_id     CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('CREDIT_TYPE_ID', 'PE_OBJECT_TYPE');
   g_credit_type_name   CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('CREDIT_TYPE_NAME', 'PE_OBJECT_TYPE');
   g_incentive_type_code CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('INCENTIVE_TYPE_CODE', 'PE_OBJECT_TYPE');
   g_quota_calendar_name CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('QUOTA_CALENDAR_NAME', 'PE_OBJECT_TYPE');
   g_interval_name      CONSTANT VARCHAR2 (80) := cn_api.get_lkup_meaning ('INTERVAL_NAME', 'PE_OBJECT_TYPE');

-- ----------------------------------------------------------------------------+
-- Procedure: valid_rate_table
-- Desc     : Valid input for Rate Table
-- ----------------------------------------------------------------------------+
   PROCEDURE valid_rate_table (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------------+
-- Procedure: validate_org_id
-- Desc     : Valid input for Org ID
-- ----------------------------------------------------------------------------+
   PROCEDURE validate_org_id (
      org_id                     IN       NUMBER
   );

-- ----------------------------------------------------------------------------+
-- Procedure: valid_disc_rate_table
-- Desc     : Valid input for Discount Rate Table
-- ----------------------------------------------------------------------------+
   PROCEDURE valid_disc_rate_table (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------------+
-- Procedure: valid_revenue_class
-- Desc     : Check input for Revenue Class
-- ----------------------------------------------------------------------------+
   PROCEDURE valid_revenue_class (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_revenue_class_id_old     IN       NUMBER := NULL,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------------+
-- Procedure: chk_dr_man_pe
-- Desc     : Check input for DRAW and MANULA type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_dr_man_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------------+
-- Procedure: chk_revenue_quota_pe
-- Desc     : Check input for  REVENUE QUOTA type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_revenue_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------------+
-- Procedure: chk_unit_quota_pe
-- Desc     : Check input for  UNIT QUOTA type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_unit_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------------+
-- Procedure: chk_revenue_non_quota_pe
-- Desc     : Check input for  REVENUE QUOTA type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_revenue_non_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------------+
-- Procedure: chk_unit_non_quota_pe
-- Desc     : Check input for  UNIT NONE QUOTA type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_unit_non_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------------+
-- Procedure: chk_disc_margin_pe
-- Desc     : Check input for  DISCOUNT or MARGIN type plan element
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_discount_margin_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       pe_rec_type := g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------------+
-- Procedure: chk_trx_factor
-- Desc     : Check Trx Factors
--   Error when
--   1. No factors assigned
--   2. key factors don't total to 100% (Warning)
-- ----------------------------------------------------------------------------+
   PROCEDURE chk_trx_factor (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_quota_rule_id            IN       NUMBER,
      p_rev_class_name           IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| -----------------------------------------------------------------------+
--| Name :  get_quota_id
--| Desc : To Get  Quota ID Using Quota Name
--| ---------------------------------------------------------------------+
   FUNCTION get_quota_id (
      p_quota_name                        VARCHAR2,
      p_org_id                            NUMBER
   )
      RETURN cn_quotas.quota_id%TYPE;

   PRAGMA RESTRICT_REFERENCES (get_quota_id, WNDS, WNPS);

--| -----------------------------------------------------------------------+
--| Name :  get_calc_formula_name
--| Desc : To Get the Calc Formula Name using the Calc_formula_ID
--| ---------------------------------------------------------------------+
   FUNCTION get_calc_formula_name (
      p_calc_formula_id                   NUMBER
   )
      RETURN cn_calc_formulas.NAME%TYPE;

   PRAGMA RESTRICT_REFERENCES (get_calc_formula_name, WNDS, WNPS);

--| -----------------------------------------------------------------------+
--| Name :  get_calc_formula_id
--| Desc : To Get the Calc Formula ID using the Calc_formula_Name
--| ---------------------------------------------------------------------+
   FUNCTION get_calc_formula_id (
      p_calc_formula_name                 VARCHAR2,
      p_org_id														NUMBER
   )
      RETURN cn_calc_formulas.calc_formula_id%TYPE;

   PRAGMA RESTRICT_REFERENCES (get_calc_formula_id, WNDS, WNPS);

--| -----------------------------------------------------------------------+
--| Function Name :  get_credit_type
--| Desc : To Get the Credit Type  using the Credit Type ID
--| ---------------------------------------------------------------------+
   FUNCTION get_credit_type (
      p_credit_type_id                    NUMBER
   )
      RETURN cn_credit_types.NAME%TYPE;

   PRAGMA RESTRICT_REFERENCES (get_credit_type, WNDS, WNPS);

--| -----------------------------------------------------------------------+
--| Function Name :  get_interval_type
--| Desc : To Get the Interval Name  using the Interval  Type ID
--| ---------------------------------------------------------------------+
   FUNCTION get_interval_name (
      p_interval_type_id                  NUMBER,
      p_org_id     NUMBER
   )
      RETURN cn_interval_types.NAME%TYPE;

   PRAGMA RESTRICT_REFERENCES (get_interval_name, WNDS, WNPS);

--| -----------------------------------------------------------------------+
--| Function Name :  get_quota_rule_id
--| Desc : Get the Quota Rule ID  using the quota_id, Revenue_class_id
--| ---------------------------------------------------------------------+
   FUNCTION get_quota_rule_id (
      p_quota_id                          NUMBER,
      p_rev_class_id                      NUMBER
   )
      RETURN cn_quota_rules.quota_rule_id%TYPE;

   PRAGMA RESTRICT_REFERENCES (get_quota_rule_id, WNDS, WNPS);

--| -----------------------------------------------------------------------+
--| Function Name :  get_uplift_Start_date
--| Desc : Get the Quplift start Date  ID   quota_id,Quota rule ID
--| --------------------------------------------------------------------+
   FUNCTION get_uplift_start_date (
      p_quota_rule_id                     NUMBER
   )
      RETURN cn_quota_rule_uplifts.start_date%TYPE;

--| -----------------------------------------------------------------------+
--| Function Name :  get_quota_rule_uplift_id
--| Desc : Get the Quota Rule UPLIFT ID  using the quota_rule_id,
-- start Date, end Date
--| ---------------------------------------------------------------------+
   FUNCTION get_quota_rule_uplift_id (
      p_quota_rule_id                     NUMBER,
      p_start_date                        DATE,
      p_end_date                          DATE
   )
      RETURN cn_quota_rule_uplifts.quota_rule_uplift_id%TYPE;

   PRAGMA RESTRICT_REFERENCES (get_quota_rule_uplift_id, WNDS, WNPS);

--| -----------------------------------------------------------------------+
--| Function Name :  get_rt_quota_asgn_id
--| Desc : Get the RT QUOTA ASGN ID  using the quota_id,
-- start Date, end Date
--| ---------------------------------------------------------------------+
   FUNCTION get_rt_quota_asgn_id (
      p_quota_id                          NUMBER,
      p_rate_schedule_id                  NUMBER,
      p_calc_formula_id                   NUMBER,
      p_start_date                        DATE,
      p_end_date                          DATE
   )
      RETURN cn_rt_quota_asgns.rt_quota_asgn_id%TYPE;

   PRAGMA RESTRICT_REFERENCES (get_rt_quota_asgn_id, WNDS, WNPS);

--| -----------------------------------------------------------------------+
--| Procedure  Name :  validate_formula
--| Desc : Check the formula assignment is valid
--| -----------------------------------------------------------------------+
   PROCEDURE validate_formula (
      p_plan_element             IN       cn_chk_plan_element_pkg.pe_rec_type  --cn_plan_element_pvt.plan_element_rec_type
   );

--| -----------------------------------------------------------------------+
--| Procedure  Name :  chk_formula_quota_type
--| Desc : Check the Formula Quota Type
--| -----------------------------------------------------------------------+
   PROCEDURE chk_formula_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type ,--cn_plan_element_pvt.plan_element_rec_type,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| -----------------------------------------------------------------------+
--| Procedure  Name :  chk_external_quota_type
--| Desc : Check the External Quota Type
--| -----------------------------------------------------------------------+
   PROCEDURE chk_external_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type , --cn_plan_element_pvt.plan_element_rec_type,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| -----------------------------------------------------------------------+
--| Procedure  Name :  chk_other_quota_type
--| Desc : Check the Other Quota Type
--| -----------------------------------------------------------------------+
   PROCEDURE chk_other_quota_pe (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type , --cn_plan_element_pvt.plan_element_rec_type,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| -----------------------------------------------------------------------+
--|   Procedure Name :  chk_miss_date_para
--|   Desc : Check for missing parameters -- Date type
--| ---------------------------------------------------------------------+
   FUNCTION chk_miss_date_para (
      p_date_para                IN       DATE,
      p_para_name                IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
      RETURN VARCHAR2;

--| -----------------------------------------------------------------------+
--|   Function Name :  chk_null_date_para
--|   Desc : Check for Null parameters -- Date type
--| ---------------------------------------------------------------------+
   FUNCTION chk_null_date_para (
      p_date_para                IN       DATE,
      p_obj_name                 IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
      RETURN VARCHAR2;

--| --------------------------------------------------------------------------+
--| Procedure  Name :  chk_date_effective
--| Desc : Check the Date Effectivity
--| -------------------------------------------------------------------------+
   PROCEDURE chk_date_effective (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_id                 IN       NUMBER,
      p_object_type              IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| --------------------------------------------------------------------------+
--| Procedure  Name :  chk_rate_quota_delete
--| Desc : Check the rate quota assigs delete
--| -------------------------------------------------------------------------+
   PROCEDURE chk_rate_quota_iud (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_iud_flag                 IN       VARCHAR2,
      p_quota_id                 IN       NUMBER,
      p_calc_formula_id          IN       NUMBER,
      p_rt_quota_asgn_id         IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| --------------------------------------------------------------------------+
--| Procedure  Name :  chk_uplift_delete_update
--| Desc : Check the ruplift delete upldate
--| -------------------------------------------------------------------------+
   PROCEDURE chk_uplift_iud (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_iud_flag                 IN       VARCHAR2,
      p_quota_rule_id            IN       NUMBER,
      p_quota_rule_uplift_id     IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| --------------------------------------------------------------------------+
--| Procedure  Name :  get_quota_type
--| Desc : get_quota_type
--| -------------------------------------------------------------------------+
   FUNCTION get_quota_type (
      p_quota_id                 IN       NUMBER
   )
      RETURN cn_quotas.quota_type_code%TYPE;

--| --------------------------------------------------------------------------+
--| Procedure  Name :  chk_formula_rate_date
--| Desc : get_quota_type
--| -------------------------------------------------------------------------+
   PROCEDURE chk_formula_rate_date (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_name               IN       VARCHAR2,
      p_calc_formula_id          IN       NUMBER,
      p_calc_formula_name        IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| --------------------------------------------------------------------------+
--| Procedure  Name :  chk_cnmp_plan_date
--| Desc :
--| -------------------------------------------------------------------------+
   PROCEDURE chk_comp_plan_date (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_name               IN       VARCHAR2,
      p_quota_id                 IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| --------------------------------------------------------------------------+
--| Procedure  Name :  chk_uplift_date
--| Desc : check uplift start date and end date at the time of
--| update the plan Element .
--| Note: You cannot update the Plan Element start date and end
--| end date if it is not falling with in the quota start date and
--| end date
--| -------------------------------------------------------------------------+
   PROCEDURE chk_uplift_date (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_name               IN       VARCHAR2,
      p_quota_id                 IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

--| --------------------------------------------------------------------------+
--| Procedure  Name :  chk_rate_quota_date
--| Desc : check rate quota  start date and end date at the time of
--| update the plan Element .
--| Note: You cannot update the Plan Element start date and end
--| end date if it is not falling with in the quota start date and
--| end date of rate quota assigns
--| -------------------------------------------------------------------------+
   PROCEDURE chk_rate_quota_date (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE,
      p_quota_name               IN       VARCHAR2,
      p_quota_id                 IN       NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );
END cn_chk_plan_element_pkg;
 

/
