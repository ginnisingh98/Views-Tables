--------------------------------------------------------
--  DDL for Package CN_PLAN_ELEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PLAN_ELEMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: cnppes.pls 120.7.12000000.2 2007/10/08 18:59:41 rnagired ship $ */
/*#
 * The procedure in this package can be used to create, update, delete and duplicate a plan element.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Plan Element
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

--
-- Record Type for Plan Elements ( CN_QUOTAS )
--
   TYPE plan_element_rec_type IS RECORD (
      NAME                          cn_quotas.NAME%TYPE := cn_api.g_miss_char,
      description                   cn_quotas.description%TYPE := cn_api.g_miss_char,
      period_type                   cn_lookups.meaning%TYPE := cn_api.g_miss_char,
      element_type                  cn_lookups.meaning%TYPE := cn_api.g_miss_char,
      target                        cn_quotas.target%TYPE := 0,
      incentive_type                cn_lookups.meaning%TYPE := cn_api.g_miss_char,
      credit_type                   cn_credit_types.NAME%TYPE := cn_api.g_miss_char,
      calc_formula_name             cn_calc_formulas.NAME%TYPE := cn_api.g_miss_char,
      rt_sched_custom_flag          cn_quotas.rt_sched_custom_flag%TYPE := cn_api.g_miss_char,
      package_name                  cn_quotas.package_name%TYPE := cn_api.g_miss_char,
      performance_goal              cn_quotas.performance_goal%TYPE := 0,
      payment_amount                cn_quotas.payment_amount%TYPE := 0,
      start_date                    cn_quotas.start_date%TYPE := cn_api.g_miss_date,
      end_date                      cn_quotas.end_date%TYPE := cn_api.g_miss_date,
      status                        cn_quotas.quota_status%TYPE := cn_api.g_miss_char,
      interval_name                 cn_interval_types.NAME%TYPE := cn_api.g_miss_char,
      payee_assign_flag             cn_quotas.payee_assign_flag%TYPE := cn_api.g_miss_char,
      vesting_flag                  cn_quotas.vesting_flag%TYPE := cn_api.g_miss_char,
      addup_from_rev_class_flag     cn_quotas.addup_from_rev_class_flag%TYPE := cn_api.g_miss_char,
      expense_account_id            cn_quotas_all.expense_account_id%TYPE := 0,
      liability_account_id          cn_quotas_all.liability_account_id%TYPE := 0,
      quota_group_code              cn_quotas.quota_group_code%TYPE := cn_api.g_miss_char,
      -- clku, PAYMENT ENHANCEMENT
      payment_group_code            cn_quotas.payment_group_code%TYPE := cn_api.g_miss_char,
      attribute_category            cn_quotas.attribute_category%TYPE := cn_api.g_miss_char,
      attribute1                    cn_quotas.attribute1%TYPE := cn_api.g_miss_char,
      attribute2                    cn_quotas.attribute2%TYPE := cn_api.g_miss_char,
      attribute3                    cn_quotas.attribute3%TYPE := cn_api.g_miss_char,
      attribute4                    cn_quotas.attribute4%TYPE := cn_api.g_miss_char,
      attribute5                    cn_quotas.attribute5%TYPE := cn_api.g_miss_char,
      attribute6                    cn_quotas.attribute6%TYPE := cn_api.g_miss_char,
      attribute7                    cn_quotas.attribute7%TYPE := cn_api.g_miss_char,
      attribute8                    cn_quotas.attribute8%TYPE := cn_api.g_miss_char,
      attribute9                    cn_quotas.attribute9%TYPE := cn_api.g_miss_char,
      attribute10                   cn_quotas.attribute10%TYPE := cn_api.g_miss_char,
      attribute11                   cn_quotas.attribute11%TYPE := cn_api.g_miss_char,
      attribute12                   cn_quotas.attribute12%TYPE := cn_api.g_miss_char,
      attribute13                   cn_quotas.attribute13%TYPE := cn_api.g_miss_char,
      attribute14                   cn_quotas.attribute14%TYPE := cn_api.g_miss_char,
      attribute15                   cn_quotas.attribute15%TYPE := cn_api.g_miss_char,
      org_id                        cn_quotas.org_id%TYPE := 0, -- Will be necessary when User has multiple OU access and will be validated
      quota_id                      cn_quotas.quota_id%TYPE := 0, -- Will be ignored even it is set
      indirect_credit               cn_quotas.indirect_credit%TYPE := cn_api.g_miss_char,
      sreps_enddated_flag          cn_quotas.salesreps_enddated_flag%TYPE := NULL
   );

--
-- Global variable that represent missing values.
-- User Defined Record Type for Plan Element
--
   g_miss_plan_element_rec       plan_element_rec_type;

--
-- User defined Table Record Type
--
   TYPE plan_element_rec_tbl_type IS TABLE OF plan_element_rec_type
      INDEX BY BINARY_INTEGER;

--
-- Global variable for Plan Element table
--
   g_miss_plan_element_rec_tbl   plan_element_rec_tbl_type;

--
-- Period quotas rec ( CN_PERIOD_QUOTAS )
--
   TYPE period_quotas_rec_type IS RECORD (
      period_name                   cn_periods.period_name%TYPE := cn_api.g_miss_char,
      period_target                 cn_period_quotas.period_target%TYPE := 0,
      period_payment                cn_period_quotas.period_payment%TYPE := 0,
      performance_goal              cn_period_quotas.performance_goal%TYPE := 0,
      attribute1                    cn_period_quotas.attribute1%TYPE := cn_api.g_miss_char,
      attribute2                    cn_period_quotas.attribute2%TYPE := cn_api.g_miss_char,
      attribute3                    cn_period_quotas.attribute3%TYPE := cn_api.g_miss_char,
      attribute4                    cn_period_quotas.attribute4%TYPE := cn_api.g_miss_char,
      attribute5                    cn_period_quotas.attribute5%TYPE := cn_api.g_miss_char,
      attribute6                    cn_period_quotas.attribute6%TYPE := cn_api.g_miss_char,
      attribute7                    cn_period_quotas.attribute7%TYPE := cn_api.g_miss_char,
      attribute8                    cn_period_quotas.attribute8%TYPE := cn_api.g_miss_char,
      attribute9                    cn_period_quotas.attribute9%TYPE := cn_api.g_miss_char,
      attribute10                   cn_period_quotas.attribute10%TYPE := cn_api.g_miss_char,
      attribute11                   cn_period_quotas.attribute11%TYPE := cn_api.g_miss_char,
      attribute12                   cn_period_quotas.attribute12%TYPE := cn_api.g_miss_char,
      attribute13                   cn_period_quotas.attribute13%TYPE := cn_api.g_miss_char,
      attribute14                   cn_period_quotas.attribute14%TYPE := cn_api.g_miss_char,
      attribute15                   cn_period_quotas.attribute15%TYPE := cn_api.g_miss_char,
      period_name_old               cn_periods.period_name%TYPE := cn_api.g_miss_char,
      org_id                        cn_period_quotas.org_id%TYPE := 0
   );

--
-- Period Quotas table Type
--
   TYPE period_quotas_rec_tbl_type IS TABLE OF period_quotas_rec_type
      INDEX BY BINARY_INTEGER;

--
-- Period Quotas G Miss
--
   g_miss_period_quotas_rec_tbl  period_quotas_rec_tbl_type;

--
-- Record Type for Revenue Classes ( CN_Quota_Rules )
--
   TYPE revenue_class_rec_type IS RECORD (
      rev_class_name                cn_quota_rules.NAME%TYPE := cn_api.g_miss_char,
      rev_class_target              cn_quota_rules.target%TYPE := 0,
      rev_class_payment_amount      cn_quota_rules.payment_amount%TYPE := 0,
      rev_class_performance_goal    cn_quota_rules.performance_goal%TYPE := 0,
      description                   cn_quota_rules.description%TYPE := cn_api.g_miss_char,
      attribute_category            cn_quotas.attribute_category%TYPE := cn_api.g_miss_char,
      attribute1                    cn_quotas.attribute1%TYPE := cn_api.g_miss_char,
      attribute2                    cn_quotas.attribute2%TYPE := cn_api.g_miss_char,
      attribute3                    cn_quotas.attribute3%TYPE := cn_api.g_miss_char,
      attribute4                    cn_quotas.attribute4%TYPE := cn_api.g_miss_char,
      attribute5                    cn_quotas.attribute5%TYPE := cn_api.g_miss_char,
      attribute6                    cn_quotas.attribute6%TYPE := cn_api.g_miss_char,
      attribute7                    cn_quotas.attribute7%TYPE := cn_api.g_miss_char,
      attribute8                    cn_quotas.attribute8%TYPE := cn_api.g_miss_char,
      attribute9                    cn_quotas.attribute9%TYPE := cn_api.g_miss_char,
      attribute10                   cn_quotas.attribute10%TYPE := cn_api.g_miss_char,
      attribute11                   cn_quotas.attribute11%TYPE := cn_api.g_miss_char,
      attribute12                   cn_quotas.attribute12%TYPE := cn_api.g_miss_char,
      attribute13                   cn_quotas.attribute13%TYPE := cn_api.g_miss_char,
      attribute14                   cn_quotas.attribute14%TYPE := cn_api.g_miss_char,
      attribute15                   cn_quotas.attribute15%TYPE := cn_api.g_miss_char,
      rev_class_name_old            cn_quota_rules.NAME%TYPE := cn_api.g_miss_char,
      org_id                        cn_quota_rules.org_id%TYPE := 0

   );

--
-- User Defined Quota Rules Record Table Type
--
   TYPE revenue_class_rec_tbl_type IS TABLE OF revenue_class_rec_type
      INDEX BY BINARY_INTEGER;

   g_miss_revenue_class_rec_tbl  revenue_class_rec_tbl_type;

--
-- User Defined Record For Uplift Factors ( CN_QUOTA_RULE_UPLIFTS )
--
   TYPE rev_uplift_rec_type IS RECORD (
      rev_class_name                cn_quota_rules.NAME%TYPE := cn_api.g_miss_char,
      start_date                    cn_quota_rule_uplifts.start_date%TYPE := cn_api.g_miss_date,
      end_date                      cn_quota_rule_uplifts.end_date%TYPE := cn_api.g_miss_date,
      rev_class_payment_uplift      NUMBER := 0,
      rev_class_quota_uplift        NUMBER := 0,
      attribute_category            cn_quota_rule_uplifts.attribute_category%TYPE := cn_api.g_miss_char,
      attribute1                    cn_quota_rule_uplifts.attribute1%TYPE := cn_api.g_miss_char,
      attribute2                    cn_quota_rule_uplifts.attribute2%TYPE := cn_api.g_miss_char,
      attribute3                    cn_quota_rule_uplifts.attribute3%TYPE := cn_api.g_miss_char,
      attribute4                    cn_quota_rule_uplifts.attribute4%TYPE := cn_api.g_miss_char,
      attribute5                    cn_quota_rule_uplifts.attribute5%TYPE := cn_api.g_miss_char,
      attribute6                    cn_quota_rule_uplifts.attribute6%TYPE := cn_api.g_miss_char,
      attribute7                    cn_quota_rule_uplifts.attribute7%TYPE := cn_api.g_miss_char,
      attribute8                    cn_quota_rule_uplifts.attribute8%TYPE := cn_api.g_miss_char,
      attribute9                    cn_quota_rule_uplifts.attribute9%TYPE := cn_api.g_miss_char,
      attribute10                   cn_quota_rule_uplifts.attribute10%TYPE := cn_api.g_miss_char,
      attribute11                   cn_quota_rule_uplifts.attribute11%TYPE := cn_api.g_miss_char,
      attribute12                   cn_quota_rule_uplifts.attribute12%TYPE := cn_api.g_miss_char,
      attribute13                   cn_quota_rule_uplifts.attribute13%TYPE := cn_api.g_miss_char,
      attribute14                   cn_quota_rule_uplifts.attribute14%TYPE := cn_api.g_miss_char,
      attribute15                   cn_quota_rule_uplifts.attribute15%TYPE := cn_api.g_miss_char,
      rev_class_name_old            cn_quota_rules.NAME%TYPE := cn_api.g_miss_char,
      start_date_old                cn_quota_rule_uplifts.start_date%TYPE := cn_api.g_miss_date,
      end_date_old                  cn_quota_rule_uplifts.end_date%TYPE := cn_api.g_miss_date,
      org_id                        cn_quota_rule_uplifts.org_id%TYPE := 0,
      object_version_number         cn_quota_rule_uplifts.object_version_number%type
   );

--
-- User defined Quota Rule Uplift Record Table Type.
--
   TYPE rev_uplift_rec_tbl_type IS TABLE OF rev_uplift_rec_type
      INDEX BY BINARY_INTEGER;

   g_miss_rev_uplift_rec_tbl     rev_uplift_rec_tbl_type;

--
-- User Defined Trx Factors Record Type ( CN_TRX_TYPES )
--
   TYPE trx_factor_rec_type IS RECORD (
      trx_type                      cn_trx_factors.trx_type%TYPE := cn_api.g_miss_char,
      event_factor                  cn_trx_factors.event_factor%TYPE := 0,
      rev_class_name                cn_quota_rules.NAME%TYPE := cn_api.g_miss_char,
      org_id                        cn_trx_factors.org_id%TYPE := 0
   );

--
-- User Defined Trx Factors Record Table Type.
--
   TYPE trx_factor_rec_tbl_type IS TABLE OF trx_factor_rec_type
      INDEX BY BINARY_INTEGER;

   g_miss_trx_factor_rec_tbl     trx_factor_rec_tbl_type;

--
-- user defined Rt_quota_asgns Record Type.( CN_RT_QUOTA_ASGNS )
--
   TYPE rt_quota_asgns_rec_type IS RECORD (
      rate_schedule_name            cn_rate_schedules.NAME%TYPE := cn_api.g_miss_char,
      calc_formula_name             cn_calc_formulas.NAME%TYPE := cn_api.g_miss_char,
      start_date                    cn_rt_quota_asgns.start_date%TYPE := cn_api.g_miss_date,
      end_date                      cn_rt_quota_asgns.end_date%TYPE := cn_api.g_miss_date,
      attribute_category            cn_quotas.attribute_category%TYPE := cn_api.g_miss_char,
      attribute1                    cn_quotas.attribute1%TYPE := cn_api.g_miss_char,
      attribute2                    cn_quotas.attribute2%TYPE := cn_api.g_miss_char,
      attribute3                    cn_quotas.attribute3%TYPE := cn_api.g_miss_char,
      attribute4                    cn_quotas.attribute4%TYPE := cn_api.g_miss_char,
      attribute5                    cn_quotas.attribute5%TYPE := cn_api.g_miss_char,
      attribute6                    cn_quotas.attribute6%TYPE := cn_api.g_miss_char,
      attribute7                    cn_quotas.attribute7%TYPE := cn_api.g_miss_char,
      attribute8                    cn_quotas.attribute8%TYPE := cn_api.g_miss_char,
      attribute9                    cn_quotas.attribute9%TYPE := cn_api.g_miss_char,
      attribute10                   cn_quotas.attribute10%TYPE := cn_api.g_miss_char,
      attribute11                   cn_quotas.attribute11%TYPE := cn_api.g_miss_char,
      attribute12                   cn_quotas.attribute12%TYPE := cn_api.g_miss_char,
      attribute13                   cn_quotas.attribute13%TYPE := cn_api.g_miss_char,
      attribute14                   cn_quotas.attribute14%TYPE := cn_api.g_miss_char,
      attribute15                   cn_quotas.attribute15%TYPE := cn_api.g_miss_char,
      rate_schedule_name_old        cn_rate_schedules.NAME%TYPE := cn_api.g_miss_char,
      start_date_old                cn_rt_quota_asgns.start_date%TYPE := cn_api.g_miss_date,
      end_date_old                  cn_rt_quota_asgns.end_date%TYPE := cn_api.g_miss_date,
      org_id                        cn_rt_quota_asgns.org_id%TYPE := 0
   );

   g_miss_rt_quota_asgns_rec     rt_quota_asgns_rec_type;

   TYPE rt_quota_asgns_rec_tbl_type IS TABLE OF rt_quota_asgns_rec_type
      INDEX BY BINARY_INTEGER;

   g_miss_rt_quota_asgns_rec_tbl rt_quota_asgns_rec_tbl_type;

-- Start of Comments
-- API name    : Create_Plan_Element
-- Type     : Public.
-- Pre-reqs : None.
-- Usage : Procedure to create a plan element
-- Parameters  :
-- IN    :  p_api_version            IN NUMBER      Require
--          p_init_msg_list          IN VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit             IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--          p_validation_level       IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
--          p_plan_element_rec       IN             PLAN_ELEMENT_REC_TYPE
--          p_revenue_class_rec_tbl  IN             REVENUE_CLASS_REC_TBL_TYPE
--                                                         Optional
--          p_rev_uplift_rec_tbl     IN             REV_CLASS_REC_TBL_TYPE
--                                                         Optional
--          p_trx_factors_rec_tbl    IN             TRX_FACTORS_REC_TBL
--                                                         Optional
--                 p_rt_quota_asgns_rec_tbl IN             Optional
--                 p_period_quotas_rec_tbl  IN             Optional
-- OUT      :  x_return_status          OUT             VARCHAR2(1)
--       :   x_msg_count               OUT              NUMBER
--       :   x_msg_data             OUT              VARCHAR2(2000)
--    :   x_status               OUT            VARCHAR2
--
--
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- Notes : This Package Procedure is Use to Create the Plan Element.
--           Which Allows the User to create the Plan Element in a
--      various form.
--
-- Descrption   :
----------------+
-- Create Plan Element is a Public API which helps  the user to create plan
-- element and other related plan element information.
-- 1. Quotas ( Plan Element Parent Record )
-- 1. quota rules ( Child for Plan Element )
-- 2. rule uplifts ( Child for Quota Rules )
-- 3. rate quota assigns ( Child for Plan Element )
-- 4. trx factors ( Child for Quota Rules )
-- 5. period quotas.( Child for Plan Element )

   -- There are various Steps to create the plan element using the Create plan
-- element Public API . It has its own record structure and the table structu
-- res.
--
-- Detail description about each parameters.
------------------------------------------+
-- p_plan_element_rec has its own structure. It is an Input Parameter for the
-- Plan Element ( CN_QUOTAS ), for detail see the declaration above .
-- This structure mainly expects the quota informations. If you pass the plan
-- element information in the p_plan_element_rec it will validate and commits
-- into the database.
-- If you pass any Child it will validate and insert into the record into the
-- Database
-- like quota rules, uplifts, trx factors, period quotas, rt_quota_assgns
-- if so it will call the respective modules to validate and
-- commits the record.
--
-- If you Pass the Quota Rules it will call the *Create_quota_rules* package
-- Procedure which is private/Group Package procedure to validate and ins
-- rt the record
--
-- Note: Assume that the  plan Element record you passed is exists in the
-- database and not passing any child record it will through the error message
-- saying that record already exists in the database. if not it will call the
-- corresponding modules.
--
-- Method of calling the API to create the plan Element
------------------------------------------------------+
-- case 1: You can just create the plan Element.
--
-- Case 2: You can create the plan Element with one or many child records.
--
-- Case 3: You can just add one of the child record, if the plan element exists
--
-- Child record table parameters ( you can pass one or many records in each )
-- --------------------------------------------------------------------------
-- Note: For Any child record you create you need to pass the plan Element
-- p_plan_element_rec, at least Name .
--
-- P_REVENUE_CLASS_REC_TBL. This is an input parmameter for Quota rules.
-- it will allow you to add one or more quota rules for a given plan element.
-- For detail quota rule structure see the Deaclaration above
--
-- for each revenue class rec it will call the create_quota_rules package
-- procedure as i said before. it will validate and commits the record
-- For information: Each revenue class record you create will automatically
-- creates the trx factors bydefault and then you can also customised by
-- passing the custom value in the p_trx_factors_rec_tbl
--
-- P_TRX_FACTORS_REC_TBL. This is an input parameter which will allow you to
-- customize the existing trx factors. Trx factors types are  standard,
-- comes as seed data and you can customise the trx factors.
-- you probablly thinking to create the trx factors but internally it
-- updates the existing record as i mention you before each revenue class
-- or quota rules you create by default
-- it creates  the trx factors. Trx factors should not exits 100% for
-- ( INV, ORD, PMT)
--
-- P_REV_UPLIFT_REC_TBL. This is an input parameter to create the uplifts
-- factors for each plan element, quota rules. you cannot create the
-- uplift without plan element and revenue class. here also you need to pass
-- plan element rec but no need to pass the revenue class.
----------------------------------------------------------------------------+
-- **** Important *****  It is very hard to make the link between tables.
----------------------------------------------------------------------------+
-- if you are creating new quota rules and uplifts you can pass the
-- p_plan_element_rec, p_revenue_class_rec_tbl and p_rev_uplift_rec_tbl
-- ***
-- if you are creating only uplifts you cannot pass the revenue class table
-- it will error out.this is an important.
--
-- P_RT_QUOTA_ASGNS_REC_TBL This is an input parameter to create the rt_quota
-- Assigns. If you pass multiple records with different start date you have
-- sequence it before you pass it into the API. otherwise it will error out.
-- Make sure you pass the p_plan_element_rec.name parameter it is mandatory
-- in all the cases.
--
-- P_PERIOD_QUOTAS_REC_TBL. This is an input parameter to create the customised
-- period quotas.
-- To create the Period quotas you must the pass plan_element and you need to
-- pass the period informations
--
-- Let Us go more detail about each parameters and possible cases.
----------------------------------------+
-- Case 1: Simply create the Plan Element
----------------------------------------+
-- To create a simple plan Element you need to pass just the
-- p_plan_element_rec with other manadatory parameters.
--
-- Calling Method
--                Create_plan_element
--                  (   p_api_version    -- Version No
--                    p_init_msg_list  -- default F ( initilize message list )
--                 p_commit    -- Default F ( Commit )
--                 p_validation_level -- Validation Level Default FULL
--                 x_return_status     -- Return Status S - Success
--                 x_msg_count      -- Return Message Count
--                 x_msg_data    -- Return Message Data
--       p_plan_element_rec --  Plan Element Structure
--                      x_loading_status   -- Detail return loading status );
--
-- p_plan_element_rec
--   name       Plan Element Name ( Must be unique )
--   description    Description about the plan Element ( optional )
--   period_type    No longer used
--   element_type   Element Type Possible Values are FORMULA, EXTERNAL, NONE,
--                  Manadatory
--   target         Amount columns, no validations Default to 0 ( optional )
--   incentive_type  Incentive_name ( cn_incentive_types.name, Seeded Data )
--   credit_type     Credit type    ) cn_credit_types, Seeded Data )
--   calc_formula_name  Calc formula Name is is mandatory if quota type is FORMULA
--   rt_sched_custom_flag  Rate schedule Custom Flag Default to N
--   package_name       Package name is manadatory if quota type = 'EXTERNAL'
--   performance_goal         Amount no validations default to 0
--   payment_amount           Amount no validations default to 0
--   quota_unspecified        No longer used
--   start_date            Start date Mandatory
--   end_date           end must be greater than start date
--   status          no longer used
--   interval_name         Interval Name is mandatory ( cn_interval_types.name )
--   payee_assign_flag        Default to N ( Y/N)
--   vesting_flag       Default to N ( Y/N )
--   quota_group_code         No longer Used
--   addup_from_rev_class_flag Default to N ( Y/N )
--   attribute_category
--   All other attributes 1 to 15
---------------------------------------------------------------------+
-- Case 2: Create the Plan Element with one or multiple child records
---------------------------------------------------------------------+
-- To create the Plan Element  and one or many child records.
-- Let us assume that you want to create two different child records like
-- Quota rules and uplifts
-- other manadatory parameters.
--
-- Calling Method
--                Create_plan_element
--                  (   p_api_version    -- Version No
--                    p_init_msg_list  -- default F ( initilize message list )
--                 p_commit    -- Default F ( Commit )
--                 p_validation_level -- Validation Level Default FULL
--                 x_return_status     -- Return Status S - Success
--                 x_msg_count      -- Return Message Count
--                 x_msg_data    -- Return Message Data
--       p_plan_element_rec --  Plan Element Structure
--                      p_revenue_class_rec_tbl -- quota rules
--                      p_rev_uplift_rec_tbl    -- quota rule uplifts
--                      x_loading_status   -- Detail return loading status );
--
-- p_plan_element_rec
--   name       Plan Element Name ( Must be unique )
--   description    Description about the plan Element ( optional )
--   period_type    No longer used
--   element_type   Element Type Possible Values are FORMULA, EXTERNAL, NONE, Manadatory
--   target         Amount columns, no validations Default to 0 ( optional )
--   incentive_type  Incentive_name ( cn_incentive_types.name, Seeded Data )
--   credit_type     Credit type    ) cn_credit_types, Seeded Data )
--   calc_formula_name  Calc formula Name is is mandatory if quota type is FORMULA
--   rt_sched_custom_flag  Rate schedule Custom Flag Default to N
--   package_name       Package name is manadatory if quota type = 'EXTERNAL'
--   performance_goal         Amount no validations default to 0
--   payment_amount           Amount no validations default to 0
--   quota_unspecified        No longer used
--   start_date            Start date Mandatory
--   end_date           end must be greater than start date
--   status          no longer used
--   interval_name         Interval Name is mandatory ( cn_interval_types.name )
--   payee_assign_flag        Default to N ( Y/N)
--   vesting_flag       Default to N ( Y/N )
--   quota_group_code         No longer Used
--   addup_from_rev_class_flag Default to N ( Y/N )
--   attribute_category
--   All other attributes 1 to 15
------------------------+
-- P_REVENUE_CLASS_REC_TBL This is an input parameter which carries the revenue class
------------------------+
-- data
-- Detail description about the p_revenue_class_rec_tbl structure
-- p_revenue_class_rec
--   rev_class_name    -- Revenue class name Mandatory( must be unique with in the Quota )
--   rev_class_target  -- Number, default to 0 Optional
--   rev_class_payment_amount -- Number default to 0 Optional
--   rev_class_performance_goal  -- Number default to 0 Optional
--   description      -- Description         Optional
--   attribute_category          -- Attribute Category Optional
--   other attribute 1 to 15     -- Optional columns
--   rev_class_name_old  *** Pass Null, it will be used only UPDATE,
--
----------------------+
-- P_REV_UPLIFT_REC_TBL This is an input Parameter which holds the uplift data
----------------------+
-- Detail Description about the p_rev_uplift_rec_tbl structure
--   rev_class_name  Uplift belongs to which revenue classes, Mandatory
--   start_date      Uplift Start, Mandatory, must be greater quota start date
--   end_date       Uplift End Date Optional if not null Must be less than quota
--                   end date
--   rev_class_payment_uplift  Number, Default to 0
--   rev_class_quota_uplift    Number, Default to 0
--   attribute_category        Optional
--   rev_class_name_old        Don't pass anything, only used for update
--   start_date_old            Don't pass anything, only used for update
--   end_date_old              Don't pass anything, only used for update
--  *** Same for the Child records
-------------------------------------------------------+
-- CASE 3 CREATE only child records. *** important ****
-------------------------------------------------------+
--FOR creating the child RECORD plan element must exists IN the DATABASE and you
-- should pass only the plan element name using the p_plan_element_rec
-- Pass the child record tables.
-------------------------+
-- P_REVENUE_CLASS_REC_TBL This is an input parameter which carries the revenue class
-------------------------+
-- data
-- Detail description about the p_revenue_class_rec_tbl structure
-- p_revenue_class_rec
--   rev_class_name    -- Revenue class name Mandatory( must be unique with in the Quota )
--   rev_class_target  -- Number, default to 0 Optional
--   rev_class_payment_amount -- Number default to 0 Optional
--   rev_class_performance_goal  -- Number default to 0 Optional
--   description      -- Description         Optional
--   attribute_category          -- Attribute Category Optional
--   other attribute 1 to 15     -- Optional columns
--   rev_class_name_old  *** Pass Null, it will be used only UPDATE,
--
----------------------+
-- P_REV_UPLIFT_REC_TBL This is an input Parameter which holds the uplift data
----------------------+
-- Detail Description about the p_rev_uplift_rec_tbl structure
--   rev_class_name  Uplift belongs to which revenue classes, Mandatory
--   start_date      Uplift Start, Mandatory, must be greater quota start date
--   end_date       Uplift End Date Optional if not null Must be less than quota
--                   end date
--   rev_class_payment_uplift  Number, Default to 0
--   rev_class_quota_uplift    Number, Default to 0
--   attribute_category        Optional
--   rev_class_name_old        Don't pass anything, only used for update
--   start_date_old            Don't pass anything, only used for update
--   end_date_old              Don't pass anything, only used for update
--  *** Same for the Child records
------------------------------------------------------------------------------+
-- NOTE: If the one child record exists or failed in a single group of record it
--       will not post any records in the database.
-- Example : You are passing multiple quota rules 1. All Hardware
--                                                2. All Services
--                                                3. All Hardware
-- In this example the third record is getting duplicated for one plan element, so
-- it will never post the first two records because the commit will takes place only
-- after all the records successfully processed.if one fails every thing will be
-- rollback. and never continue further.
--
-- End of comments
--
------------------------------------------------------------------------------+
--                       Create_Plan_Element
------------------------------------------------------------------------------+

   /*#
   * This procedure creates a plan element and create entries in the child tables.
   * The possible child table entries are for:
   * <li>Quota Rules</li>
   * <li>Rule Uplifts</li>
   * <li>Transaction Factors</li>
   * <li>Rollover Quotas</li>
   * <li>Period quotas </li>
   * @param p_api_version API version
   * @param p_init_msg_list Initialize message list (default F)
   * @param p_commit Commit flag (default F).
   * @param p_validation_level Validation level (default 100).
   * @param x_return_status Return Status
   * @param x_msg_count Number of messages returned
   * @param x_msg_data Contents of message if x_msg_count = 1
   * @param x_loading_status Loading Status
   * @param p_plan_element_rec       Plan element details
   * @param p_revenue_class_rec_tbl  Revenue class details
   * @param p_rev_uplift_rec_tbl     Revenue class uplift factor details
   * @param p_trx_factor_rec_tbl     Transaction factors details
   * @param p_period_quotas_rec_tbl  Period Quotas details
   * @param p_rt_quota_asgns_rec_tbl Rate quota assigns details
   * @param p_is_duplicate           Duplicate/Create flag
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Create Plan Element
   */
   PROCEDURE create_plan_element (
      p_api_version              IN       NUMBER := 0,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_plan_element_rec         IN       plan_element_rec_type := g_miss_plan_element_rec,
      p_revenue_class_rec_tbl    IN       revenue_class_rec_tbl_type := g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       rev_uplift_rec_tbl_type := g_miss_rev_uplift_rec_tbl,
      p_trx_factor_rec_tbl       IN       trx_factor_rec_tbl_type := g_miss_trx_factor_rec_tbl,
      p_period_quotas_rec_tbl    IN       period_quotas_rec_tbl_type := g_miss_period_quotas_rec_tbl,
      p_rt_quota_asgns_rec_tbl   IN       rt_quota_asgns_rec_tbl_type := g_miss_rt_quota_asgns_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2,
      p_is_duplicate             IN VARCHAR2 DEFAULT 'N'
   );

-- Start of Comments
-- API name    : Update_Plan_Element
-- Type     : Public.
-- Pre-reqs : None.
-- Usage : Procedure to Update a plan element
-- Parameters  :
-- IN    :  p_api_version            IN NUMBER      Require
--          p_init_msg_list          IN VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit             IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--          p_validation_level       IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
--                 p_quota_name_old          IN            VARCHAR2
--                                                         (Depends upon the case)
--          p_new_plan_element_rec   IN             PLAN_ELEMENT_REC_TYPE
--          p_revenue_class_rec_tbl  IN             REVENUE_CLASS_REC_TBL_TYPE
--                                                         Optional
--          p_rev_uplift_rec_tbl     IN             REV_CLASS_REC_TBL_TYPE
--                                                         Optional
--          p_trx_factors_rec_tbl    IN             TRX_FACTORS_REC_TBL
--                                                         Optional
--                 p_period_quotas_rec_tbl  IN             Optional
-- OUT      :  x_return_status          OUT             VARCHAR2
--       :   x_msg_count               OUT              NUMBER
--       :   x_msg_data             OUT              VARCHAR2
--    :   x_status               OUT            VARCHAR2
--
--
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- Notes : This Package is Use to Create the Plan Element which
--           Allows the User to create the the Plan Element in a
--      various form.

   -- Update Plan Element is also same like the Create but excepts that
-- old value to be  passed for each record you update
-- For updating the Plan Element you have to pass the old_quota_name
-- it is an element with in the p_plan_element_rec.
-- ************* Important Note: *****************
-- For modifying records you have pass the modified column value and the not modified
-- column values which is already in the table also
-- For example you want to modify only one column in the table then you have to pass
-- all the old columns value and new columns value and the modified value based on
-- the parameters.
-- This way you can validate the record again, because there will be lots of cross
-- validations with in a record.
-- End of comments
--
------------------------------------------------------------------------------+
--                       Update_Plan_Element
------------------------------------------------------------------------------+
/*#
  * This procedure updates a plan element and updates respective entries in the child tables. The possible child table entries are for:
  * <li>Quota Rules</li>
  * <li>Rule Uplifts</li>
  * <li>Transaction Factors </li>
  * <li>Rollover quotas</li>
  * If the plan element belongs to a compensation plan, the status is set to Incomplete.
  * If the plan element has been assigned to the salesreps, then the records are also updated in
  * srp quota assigns, srp rate assigns, srp period quotas, srp quota rules and srp rollover
  * quotas only if the plan element to salesrep assignment is not customizable.
  * @param p_api_version API version
  * @param p_init_msg_list Initialize message list (default F)
  * @param p_commit Commit flag (default F).
  * @param p_validation_level Validation level (default 100).
  * @param x_return_status Return Status
  * @param x_msg_count Number of messages returned
  * @param x_msg_data Contents of message if x_msg_count = 1
  * @param x_loading_status Loading Status
  * @param p_new_plan_element_rec       Plan element details
  * @param p_quota_name_old  Old plan element name that needs to be updated.
  * @param p_revenue_class_rec_tbl  Revenue class details
  * @param p_rev_uplift_rec_tbl     Revenue class uplift factor details
  * @param p_trx_factor_rec_tbl     Transaction factors details
  * @param p_period_quotas_rec_tbl  Period Quotas details
  * @param p_rt_quota_asgns_rec_tbl Rate quota assigns details
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Update Plan Element
  */
   PROCEDURE update_plan_element (
      p_api_version              IN       NUMBER := 0,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_new_plan_element_rec     IN       plan_element_rec_type := g_miss_plan_element_rec,
      p_quota_name_old           IN       VARCHAR2 := cn_api.g_miss_char,
      p_revenue_class_rec_tbl    IN       revenue_class_rec_tbl_type := g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       rev_uplift_rec_tbl_type := g_miss_rev_uplift_rec_tbl,
      p_trx_factor_rec_tbl       IN       trx_factor_rec_tbl_type := g_miss_trx_factor_rec_tbl,
      p_period_quotas_rec_tbl    IN       period_quotas_rec_tbl_type := g_miss_period_quotas_rec_tbl,
      p_rt_quota_asgns_rec_tbl   IN       rt_quota_asgns_rec_tbl_type := g_miss_rt_quota_asgns_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start of Comments
-- API name    : Delete_Plan_Element
-- Type     : Public.
-- Pre-reqs : None.
-- Usage : Procedure to Delete a plan element
-- Parameters  :
-- IN    :  p_api_version            IN NUMBER      Require
--          p_init_msg_list          IN VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit             IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--          p_validation_level       IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
--          p_quota_name             IN             VARCHAR2
--                              Required
--                                                         Optional
--                 p_revenue_class_rec_tbl  IN  revenue_class_rec_tbl_type
--                                  := g_miss_revenue_class_rec_tbl
--               p_rev_uplift_rec_tbl     IN  rev_uplift_rec_tbl_type
--                                     := g_miss_rev_uplift_rec_tbl
--            p_rt_quota_asgns_rec_tbl IN  rt_quota_asgns_rec_tbl_type
--                                     := g_miss_rt_quota_asgns_rec_tbl
-- OUT      :  x_return_status          OUT             VARCHAR2(1)
--       :   x_msg_count               OUT              NUMBER
--       :   x_msg_data             OUT              VARCHAR2(2000)
--
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- Notes : This Package is Use to Delete the Plan ELement
--  Currently this program supports to delete the complete quotas
--  You need to pass only the P_quota_name it deletes all the related
--  Child records as well.
--  Note: You cannot delete the plan Element, if it already assigns to the
--  Comp Plans.
-- End of comments
--
------------------------------------------------------------------------------+
--                       Delete_Plan_Element
------------------------------------------------------------------------------+
/*#
  * This procedure deletes a plan element and deletes respective
  * entries in the child tables. The possible child table entries are for:
  * <li>Quota Rules</li>
  * <li>Rule Uplifts</li>
  * <li>Transaction Factors </li>
  * <li>Rollover quotas</li>
  * If the plan element belongs to a compensation plan, the status is set to Incomplete.
  * If the plan element has been assigned to the salesreps, then the records are also
  * deleted from srp quota assigns, srp rate assigns, srp period quotas, srp quota rules
  * and srp rollover quotas.
  * @param p_api_version API version
  * @param p_init_msg_list Initialize message list (default F)
  * @param p_commit Commit flag (default F).
  * @param p_validation_level Validation level (default 100).
  * @param x_return_status Return Status
  * @param x_msg_count Number of messages returned
  * @param x_msg_data Contents of message if x_msg_count = 1
  * @param x_loading_status Loading Status
  * @param p_quota_rec Plan Element Details
  * @param p_revenue_class_rec_tbl  Revenue class details
  * @param p_rev_uplift_rec_tbl     Revenue class uplift factor details
  * @param p_rt_quota_asgns_rec_tbl Rate quota assigns details
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Delete Plan Element
  */
   PROCEDURE delete_plan_element (
      p_api_version              IN       NUMBER := 0,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_rec               IN       plan_element_rec_type := g_miss_plan_element_rec,
      p_revenue_class_rec_tbl    IN       revenue_class_rec_tbl_type := g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       rev_uplift_rec_tbl_type := g_miss_rev_uplift_rec_tbl,
      p_rt_quota_asgns_rec_tbl   IN       rt_quota_asgns_rec_tbl_type := g_miss_rt_quota_asgns_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start Comments
-- API name    : Duplicate_Plan_Element
-- Type        : Public.
-- Pre-reqs    : None.
-- Usage  : Procedure to copy a PE. the new PE will be named as
--          <original pe name>_2. May get truncate if the PE name is
--          long.
--
-- Parameters  :
-- IN          :  p_api_version       IN NUMBER      Require
--                p_init_msg_list     IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--                p_commit            IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--                p_validation_level  IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     OUT            VARCHAR2(1)
--                x_msg_count         OUT            NUMBER
--                x_msg_data          OUT            VARCHAR2(2000)
-- IN          :  p_plan_element_name IN          cn_quotas.name%TYPE
-- OUT         :  x_plan_element_name OUT            cn_quotas.name%TYPE
--
-- Version     : Current version   1.0
--               Initial version   1.0
--
-- Notes  : Duplicate Plan Element is a public API will help the user to duplicate
--          the existing plan Element to new plan element just _02 with the existing
--          plan Element name. It is kind of template we used to copy the
--          existing plan Element
--          Remember it creates all the related table data as well.
--          p_plan_element_name is Mandatory and the x_plan_element_name is the new
--          plan Element name
-- End of comments
------------------------------------------------------------------------------+
--                       Duplicate_Plan_Element
------------------------------------------------------------------------------+
/*#
  * Duplicate_Plan_Element in cn_plan_element_pub copies the information of an existing plan element.
  * The child table entries are also copied from the source.
  * @param p_api_version API version
  * @param p_init_msg_list Initialize message list (default F)
  * @param p_commit Commit flag (default F).
  * @param p_validation_level Validation level (default 100).
  * @param x_return_status Return Status
  * @param x_msg_count Number of messages returned
  * @param x_msg_data Contents of message if x_msg_count = 1
  * @param x_loading_status Loading Status
  * @param p_plan_element_name  Source Plan element name
  * @param p_org_id Organization Id
  * @param x_plan_element_name  New Plan element name
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Duplicate Plan Element
  */
   PROCEDURE duplicate_plan_element (
      p_api_version              IN       NUMBER := 0,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_plan_element_name        IN       cn_quotas.NAME%TYPE := cn_api.g_miss_char,
      p_org_id                   IN NUMBER,
      x_plan_element_name        OUT NOCOPY cn_quotas.NAME%TYPE,
      x_loading_status           OUT NOCOPY VARCHAR2
   );
END cn_plan_element_pub;
 

/
