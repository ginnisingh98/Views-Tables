--------------------------------------------------------
--  DDL for Package Body PQP_GB_OSP_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_OSP_TEMPLATE" AS
/* $Header: pqpgbosd.pkb 120.0 2005/05/29 02:00:18 appldev noship $ */

  g_package_name         VARCHAR2(61) := 'pqp_gb_osp_template.';
  g_debug                BOOLEAN;

--
--
--
  PROCEDURE debug(
    p_trace_message             IN       VARCHAR2
   ,p_trace_location            IN       NUMBER DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug(p_trace_message, p_trace_location);
  END debug;
--
--
--
  PROCEDURE debug(p_trace_number IN NUMBER)
  IS
  BEGIN
    pqp_utilities.debug(p_trace_number);
  END debug;

--
--
--
  PROCEDURE debug(p_trace_date IN DATE)
  IS
  BEGIN
    pqp_utilities.debug(p_trace_date);
  END debug;

--
--
--
  PROCEDURE debug_enter(
    p_proc_name                 IN       VARCHAR2
   ,p_trace_on                  IN       VARCHAR2 DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug_enter(p_proc_name, p_trace_on);
  END debug_enter;

--
--
--
  PROCEDURE debug_exit(
    p_proc_name                 IN       VARCHAR2
   ,p_trace_off                 IN       VARCHAR2 DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug_exit(p_proc_name, p_trace_off);
  END debug_exit;

--
--
--
  PROCEDURE debug_others(
    p_proc_name                 IN       VARCHAR2
   ,p_proc_step                 IN       NUMBER DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug_others(p_proc_name, p_proc_step);
  END debug_others;
--
--
--
  PROCEDURE check_error_code
    (p_error_code               IN       NUMBER
    ,p_error_message            IN       VARCHAR2
    )
  IS
  BEGIN
    pqp_utilities.check_error_code(p_error_code, p_error_message);
  END;
--
--
--
  PROCEDURE clear_cache
  IS
  BEGIN
    NULL;
  END;
--
--
--

PROCEDURE create_udt_entry
    (p_bg_id                         IN NUMBER
    ,p_band				  IN VARCHAR2
    ,p_entit			          IN VARCHAR2
    ,p_lower			  IN VARCHAR2
    ,p_user_tbl_id		  IN NUMBER
      )
  IS

  BEGIN
   INSERT INTO pay_user_column_instances_f
       (user_column_instance_id
       ,effective_start_date
       ,effective_end_date
       ,user_row_id
       ,user_column_id
       ,business_group_id
       ,legislation_code
       ,legislation_subgroup
       ,value
       )
           SELECT
        pay_user_column_instances_s.NEXTVAL
        ,urws.effective_start_date
        ,urws.effective_end_date
        ,urws.user_row_id
        ,ucol.user_column_id
        ,p_bg_id
        ,NULL
        ,NULL
        ,p_entit -- -999999 -999999 Band1
       FROM pay_user_columns  ucol
           ,pay_user_rows_f   urws
       WHERE ucol.user_table_id = p_user_tbl_id --fnd_number.canonical_to_number(l_eei_information9)
         AND ucol.user_column_name = p_band -- bad bad refer 'PQP_GAP_ENTITLEMENT_BANDS'.'BAND1'
         AND urws.user_table_id = ucol.user_table_id
         AND urws.row_low_range_or_name = p_lower -- bad bad refer lookup code 'PQP_GAP_ENTITLEMENT_ROWS'.'GB_GAP_PERCENTAGE_ROW'
         AND SYSDATE BETWEEN urws.effective_start_date
                         AND urws.effective_end_date;

  END;



--
--
--

PROCEDURE del_automated_plan_setup_data
 (p_pl_id                        IN             NUMBER
 ,p_business_group_id            IN             NUMBER
 ,p_effective_date               IN             DATE
 ,p_base_name                    IN             VARCHAR2
 )
IS

  l_acty_base_rt_id ben_acty_base_rt_f.acty_base_rt_id%TYPE;
  l_proc_step                    NUMBER(20,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'del_automated_plan_setup_data';

BEGIN

   l_proc_step := 10;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

-- 3. delete the ben_benfts_grp, unless its linked to a person or elig profile

--   DELETE FROM ben_benfts_grp
--   WHERE  business_group_id = p_business_group_id
--     AND  name = p_base_name||'OSP Scheme Member';
--
-- can't validate easily, impact of delete unknown, hence not deleting
-- instead insert has a check to see that it doesn't try an insert duplicates
-- if the same base is used again
--


-- 2b)  delete the inserted extra inputs

   l_proc_step := 20;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

   SELECT acty_base_rt_id
     INTO l_acty_base_rt_id
   FROM   ben_acty_base_rt_f
   WHERE  pl_id = p_pl_id
     AND  p_effective_date BETWEEN effective_start_date
                               AND effective_end_date;
   -- the above select will fail if there is more than one standard rate
   -- thus if the user has manually setup additional rates then
   -- they must first manually delink them
   -- leaving only the base standard rate created by plan copy in place


   l_proc_step := 25;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;


-- delete all extra inputs for this standard rate
   DELETE FROM ben_extra_input_values
   WHERE  acty_base_rt_id = l_acty_base_rt_id;


-- 2a) remove the link of the base element from the standard rate
   l_proc_step := 30;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

   UPDATE ben_acty_base_rt_f
   SET    element_type_id = NULL
         ,input_value_id  = NULL
         ,ele_rqd_flag    = 'N'
         ,object_version_number = object_version_number + 1
   WHERE  acty_base_rt_id = l_acty_base_rt_id
     AND  p_effective_date BETWEEN effective_start_date
                               AND effective_end_date;


   l_proc_step := 40;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;


-- 1. making plans pending -- unusable untill it is resetup as a scheme

   -- call api here....making do with hard update to get over date track problems
   UPDATE ben_pl_f
   SET    pl_stat_cd = 'P'
         ,object_version_number = object_version_number + 1
   WHERE  pl_id = p_pl_id
     AND  p_effective_date BETWEEN effective_start_date
                               AND effective_end_date;

debug_exit(l_proc_name);

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END del_automated_plan_setup_data;


PROCEDURE automate_plan_setup
 (p_pl_id                        IN             NUMBER
 ,p_business_group_id            IN             NUMBER
 ,p_element_type_id              IN             NUMBER  --
 ,p_effective_date               IN             DATE
 ,p_base_name                    IN             VARCHAR2
 ,p_plan_class                   IN             VARCHAR2 DEFAULT 'OSP'
 )
IS

  l_acty_base_rt_id ben_acty_base_rt_f.acty_base_rt_id%TYPE;
  l_proc_step                    NUMBER(20,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'automate_plan_setup';
  l_input_name                   VARCHAR2(40);

BEGIN

  g_debug := hr_utility.debug_enabled;
  debug_enter(l_proc_name);

-- what to automate ?
-- 1. making plans active
-- 2. setting up standard rates
-- 3. setup a benefits group for quick eligibity setup
-- 4. linking life events to person changes -- once only
-- what is not automated
-- is the delete half of this
--

-- 1. making plans active

   l_proc_step := 10;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

   -- call api here....making do with hard update to get over date track problems
   UPDATE ben_pl_f
   SET    pl_stat_cd = 'A'
         ,object_version_number = object_version_number + 1
   WHERE  pl_id = p_pl_id
     AND  p_effective_date BETWEEN effective_start_date
                               AND effective_end_date;

-- 2. setting up standard rates a) update standard rate

   l_proc_step := 20;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;


   SELECT acty_base_rt_id
     INTO l_acty_base_rt_id
   FROM   ben_acty_base_rt_f
   WHERE  pl_id = p_pl_id
     AND  p_effective_date BETWEEN effective_start_date
                               AND effective_end_date;


   l_proc_step := 25;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

--Set Standard Input Value as Absence Days
--as LOS dosent make any sense for UNP
   IF p_plan_class='UNP' THEN
     l_input_name := 'ABSENCE DAYS' ;
   ELSE
     l_input_name := 'LENGTH OF SERVICE' ;
   END IF;

   UPDATE ben_acty_base_rt_f
   SET    element_type_id = p_element_type_id
         ,input_value_id  = (SELECT input_value_id
                             FROM   pay_input_values_f
                             WHERE  element_type_id = p_element_type_id
                               AND  UPPER(name) = l_input_name
                               AND  p_effective_date BETWEEN effective_start_date
                                                AND effective_end_date)
         ,ele_rqd_flag    = 'Y'
         ,object_version_number = object_version_number + 1
   WHERE  acty_base_rt_id = l_acty_base_rt_id
     AND  p_effective_date BETWEEN effective_start_date
                               AND effective_end_date;


   l_proc_step := 30;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

-- 2. setting up standard rates b) insert extra inputs

IF p_plan_class='OSP' OR p_plan_class='UNP' THEN
 INSERT INTO ben_extra_input_values
  (extra_input_value_id          --  NOT NULL NUMBER(15)
  ,acty_base_rt_id               --  NOT NULL NUMBER(15)
  ,input_value_id                --  NOT NULL NUMBER(15)
  ,input_text                    --           VARCHAR2(240)
  ,upd_when_ele_ended_cd         --           VARCHAR2(30)
  ,return_var_name               --  NOT NULL VARCHAR2(240)
  ,business_group_id             --  NOT NULL NUMBER(15)
  ,object_version_number
  )
  (SELECT
    ben_extra_input_values_s.NEXTVAL
   ,l_acty_base_rt_id
   ,input_value_id
   ,NULL
   ,DECODE(UPPER(name),'ABSENCE END DATE','U','C')
   ,'L_'||TRANSLATE(UPPER(name),' ','_')
   ,business_group_id
   ,1
  FROM   pay_input_values_f
  WHERE  element_type_id = p_element_type_id
    AND  p_effective_date BETWEEN effective_start_date AND effective_end_date
    AND  UPPER(name) in ('ABSENCE TYPE','ABSENCE END DATE','ABSENCE START DATE','PLAN ID','ABSENCE ID')
  );
ELSE
 INSERT INTO ben_extra_input_values
  (extra_input_value_id          --  NOT NULL NUMBER(15)
  ,acty_base_rt_id               --  NOT NULL NUMBER(15)
  ,input_value_id                --  NOT NULL NUMBER(15)
  ,input_text                    --           VARCHAR2(240)
  ,upd_when_ele_ended_cd         --           VARCHAR2(30)
  ,return_var_name               --  NOT NULL VARCHAR2(240)
  ,business_group_id             --  NOT NULL NUMBER(15)
  ,object_version_number
  )
  (SELECT
    ben_extra_input_values_s.NEXTVAL
   ,l_acty_base_rt_id
   ,input_value_id
   ,NULL
   ,DECODE(UPPER(name),'MATERNITY END DATE','U','C')
   ,'L_'||TRANSLATE(UPPER(name),' ','_')
   ,business_group_id
   ,1
  FROM   pay_input_values_f
  WHERE  element_type_id = p_element_type_id
    AND  p_effective_date BETWEEN effective_start_date AND effective_end_date
    AND  UPPER(name) in ('ABSENCE TYPE','MATERNITY END DATE','MATERNITY START DATE','PLAN ID','ABSENCE ID','EWC')
  );

END IF;

   l_proc_step := 40;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

-- 3. setup a benefits group for quick eligibity setup

--INSERT INTO ben_benfts_grp
-- (benfts_grp_id                --   not null number(15)
-- ,name                         --   not null varchar2(240)
-- ,business_group_id            --   not null number(15)
-- ,bng_desc                     --            varchar2(240)
-- ,object_version_number        --            number
-- )
--SELECT
--  ben_benfts_grp_s.NEXTVAL
-- ,p_base_name||'OSP Scheme Member'
-- ,p_business_group_id
-- ,p_base_name||'OSP Scheme Members Group'
-- ,1
--FROM DUAL
--WHERE NOT EXISTS
--        (SELECT 1
--         FROM   ben_benfts_grp
--         WHERE  business_group_id = p_business_group_id
--           AND  name = p_base_name||'OSP Scheme Member'
--        );

-- 4. linking life events to person changes -- once only

   l_proc_step := 50;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

INSERT INTO ben_ler_per_info_cs_ler_f
 (ler_per_info_cs_ler_id      --  NOT NULL NUMBER(15)
 ,effective_start_date        --  NOT NULL DATE
 ,effective_end_date          --  NOT NULL DATE
 ,business_group_id           --  NOT NULL NUMBER(15)
 ,ler_id                      --  NOT NULL NUMBER(15)
 ,per_info_chg_cs_ler_id      --  NOT NULL NUMBER(15)
 ,object_version_number       --           NUMBER(9)
 )
SELECT ben_ler_per_info_cs_ler_f_s.NEXTVAL
      ,p_effective_date
      ,ler.effective_end_date
      ,p_business_group_id
      ,ler.ler_id
      ,pcd.per_info_chg_cs_ler_id
      ,1
FROM   ben_ler_f ler
      ,ben_per_info_chg_cs_ler_f pcd
WHERE  ler.business_group_id = p_business_group_id
  AND  ler.typ_cd = 'ABS'
  AND  pcd.name = ler.name
  AND  pcd.business_group_id = ler.business_group_id
  AND  p_effective_date BETWEEN ler.effective_start_date
                            AND ler.effective_end_date
  AND  p_effective_date BETWEEN pcd.effective_start_date
                            AND pcd.effective_end_date
  AND  NOT EXISTS -- do not insert if there a person change allready for this ler
         (SELECT 1
          FROM   ben_ler_per_info_cs_ler_f pchg
          WHERE  pchg.ler_id = ler.ler_id -- no need to check effectiveness
         );

debug_exit(l_proc_name);

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END automate_plan_setup;


   --======================================================================
   --                     PROCEDURE create_config_data
   --======================================================================
PROCEDURE create_config_data IS

   l_module_id pqp_configuration_modules.module_id%TYPE ;
  l_proc_step                    NUMBER(20,10);
  l_proc_name                    VARCHAR2(61):=
    g_package_name||'create_config_data';

BEGIN

debug_enter(l_proc_name);


INSERT INTO PQP_CONFIGURATION_MODULES
( MODULE_ID                        -- pqp_configuration_modules_s.nextval
 ,MODULE_NAME                      -- 'Absence Schemes'
 ,BUSINESS_GROUP_ID                -- NULL
 ,LEGISLATION_CODE                 -- 'GB'
 ,DESCRIPTION                      -- 'GB Absence Schemes OSP/OMP'
 ,APPLICATION_ID                   -- 8303
 ,OBJECT_VERSION_NUMBER            -- 1
 ,LAST_UPDATE_DATE                 -- hr_api.g_sot -- DO NOT USE SYSDATE
 ,LAST_UPDATED_BY                  -- 2
 ,LAST_UPDATE_LOGIN                -- 2
 ,CREATED_BY                       -- 2
 ,CREATION_DATE                    -- hr_api.g_sot -- DO NOT USE SYSDATE
 )
 SELECT
  pqp_configuration_modules_s.nextval
 ,'Absence Schemes'
 ,NULL
 ,'GB'
 ,'GB Absence Schemes OSP/OMP'
 ,8303
 ,1
 ,hr_api.g_sot
 ,2
 ,2
 ,2
 ,hr_api.g_sot
 FROM DUAL
 WHERE NOT EXISTS
 ( SELECT 1 FROM pqp_configuration_modules
   WHERE module_name = 'Absence Schemes'
   and   legislation_code = 'GB'
 );


SELECT module_id
INTO   l_module_id
FROM   pqp_configuration_modules
where  module_name = 'Absence Schemes'
and   legislation_code = 'GB' ;


INSERT INTO PQP_CONFIGURATION_TYPES
( CONFIGURATION_TYPE            -- 'PQP_GB_OSP_OMP_CONFIG'
 ,MODULE_ID                      -- l_module_id -- sequence of above row
 ,ACTIVE_INACTIVE_FLAG           -- 'Y'
 ,DESCRIPTION                    -- 'OSP/OMP Absence Schemes Configuration'
 ,MULTIPLE_OCCURENCES_FLAG       -- 'N'
 ,LEGISLATION_CODE               -- 'GB'
 ,PROTECTED_FLAG                 -- 'Y'
 ,PROGRAM_APPLICATION_ID         -- NULL
 ,PROGRAM_ID                     -- NULL
 ,REQUEST_ID                     -- NULL
 ,PROGRAM_UPDATE_DATE            -- NULL
 ,OBJECT_VERSION_NUMBER          -- 1
 ,LAST_UPDATE_DATE               -- hr_api.g_sot -- DO NOT USE SYSDATE
 ,LAST_UPDATED_BY                -- 2
 ,LAST_UPDATE_LOGIN              -- 2
 ,CREATED_BY                     -- 2
 ,CREATION_DATE                  -- hr_api.g_sot -- DO NOT USE SYSDATE
 ,TOTAL_UNIQUE_COLUMNS           -- NULL
)
SELECT
 'PQP_GB_OSP_OMP_CONFIG'
 ,l_module_id
 ,'Y'
 ,'OSP/OMP Absence Schemes Configuration'
 ,'N'
 ,'GB'
 ,'Y'
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,1
 ,hr_api.g_sot
 ,2
 ,2
 ,2
 ,hr_api.g_sot
 ,NULL
 FROM DUAL
 WHERE NOT EXISTS
 ( SELECT 1 FROM pqp_configuration_types
   WHERE  configuration_type = 'PQP_GB_OSP_OMP_CONFIG'
   AND    module_id          = l_module_id
   AND    legislation_code = 'GB'
 ) ;

debug_exit(l_proc_name);

END create_config_data ;



/*========================================================================
 *                        CREATE_USER_TEMPLATE
 *=======================================================================*/
FUNCTION create_user_template
           (p_plan_id                       in number
           ,p_plan_description              in varchar2
           ,p_sch_cal_type                  in varchar2
           ,p_sch_cal_duration              in number
           ,p_sch_cal_uom                   in varchar2
           ,p_sch_cal_start_date            in date
           ,p_sch_cal_end_date              in date
           ,p_abs_days                      in varchar2
           ,p_abs_ent_sick_leaves           in number
           ,p_abs_ent_holidays              in number
           ,p_abs_daily_rate_calc_method    in varchar2
           ,p_abs_daily_rate_calc_period    in varchar2
           ,p_abs_daily_rate_calc_divisor   in number
           ,p_abs_working_pattern           in varchar2
           ,p_abs_overlap_rule              in varchar2
           ,p_abs_ele_name                  in varchar2
           ,p_abs_ele_reporting_name        in varchar2
           ,p_abs_ele_description           in varchar2
           ,p_abs_ele_processing_priority   in number
           ,p_abs_primary_yn                in varchar2
           ,p_pay_ele_reporting_name        in varchar2
           ,p_pay_ele_description           in varchar2
           ,p_pay_ele_processing_priority   in number
           ,p_pay_src_pay_component         in varchar2
           ,p_bnd1_ele_sub_name             in varchar2
           ,p_bnd2_ele_sub_name             in varchar2
           ,p_bnd3_ele_sub_name             in varchar2
           ,p_bnd4_ele_sub_name             in varchar2
           ,p_ele_eff_start_date            in date
           ,p_ele_eff_end_date              in date
           ,p_abs_type_lookup_type          in varchar2
           ,p_abs_type_lookup_value         in t_abs_types
           ,p_security_group_id             in number
           ,p_bg_id                         in number
	   ,p_plan_type_lookup_type         in varchar2   default null -- LG
           ,p_plan_type_lookup_value        in t_plan_types -- LG
	   ,p_enable_ent_proration          in varchar2   default null -- LG
           ,p_scheme_type                     in varchar2   default null -- LG
	   ,p_abs_schedule_wp               in varchar2   default null -- LG
-- Added additional segments for CSS
           ,p_dual_rolling_duration      in number     default null
           ,p_dual_rolling_UOM           in varchar2   default null
	   ,p_ft_round_config            in varchar2   default null
	   ,p_pt_round_config            in varchar2   default null

           )
   RETURN NUMBER IS
   --


   /*--------------------------------------------------------------------
    The input values are explained below : V-varchar2, D-Date, N-number
      Input-Name                    Type   Valid Values/Explaination
      ----------                    ----
      --------------------------------------
      p_plan_id                      (N) - LOV based i/p
      p_plan_description             (V) - User i/p Description
      p_sch_cal_type                 (V) - LOV based i/p (Fixed/Rolling)
      p_sch_cal_duration             (N) - LOV based i/p
      p_sch_cal_uom                  (V) - LOV based i/p
      (Days/Weeks/Months/Years)
      p_sch_cal_start_date           (D) - User i/p Date
      p_sch_cal_end_date             (D) - User i/p Date
      p_abs_days                     (V) - Radio Button based i/p
      (Working/Calendar/User Provided)
      p_abs_ent_sick_leaves          (N) - User i/p UDT Id
      p_abs_ent_holidays             (N) - User i/p UDT Id
      p_abs_daily_rate_calc_method   (V) - Radio Button based i/p
      (Working/Calendar)
      p_abs_daily_rate_calc_period   (V) - LOV based i/p (Annual/Pay Period)
      p_abs_daily_rate_calc_divisor  (N) - 365/User Provided Default 365
      p_abs_working_pattern          (V) - User i/p Working Pattern Name
      p_abs_overlap_rule             (V) - User i/p Absence Overlap Rule
      p_abs_ele_name                 (V) - User i/p Element Name
      p_abs_ele_reporting_name       (V) - User i/p Reporting Name
      p_abs_ele_description          (V) - User i/p Description
      p_abs_ele_processing_priority  (N) - User provided
      p_abs_primary_yn               (V) - 'Y'/'N'
      p_pay_ele_reporting_name       (V) - User i/p Reporting Name
      p_pay_ele_description          (V) - User i/p Description
      p_pay_ele_processing_priority  (N) - User provided
      p_pay_src_pay_component        (V) - LOV based i/p
      p_bnd1_ele_sub_name            (V) - User i/p Band1 Sub Name
      p_bnd2_ele_sub_name            (V) - User i/p Band2 Sub Name
      p_bnd3_ele_sub_name            (V) - User i/p Band3 Sub Name
      p_bnd4_ele_sub_name            (V) - User i/p Band4 Sub Name
      p_ele_eff_start_date           (D) - User i/p Effective Start Date
      p_ele_eff_end_date             (D) - User i/p Effective End Date
      p_abs_type_lookup_type         (V) - Absence Type Lookup Name
      p_abs_type_lookup_value        (C) - Collection of Absence Types
      p_bg_id                        (N) - Business group id
      p_plan_type_lookup_type        (V) varchar2   default null -- LG
      p_plan_type_lookup_value       t_plan_types -- LG
      p_enable_ent_proration         (V)    LG
      p_scheme_type                  (V)   default null -- LG
      p_abs_schedule_wp              (V)   default null -- LG
-- Added additional segments for CSS
      p_dual_rolling_duration        (N)
      p_dual_rolling_UOM             (N)
      p_ft_round_config              (V)
      p_pt_round_config              (V)
   ----------------------------------------------------------------------*/
   --


   l_template_id                 pay_shadow_element_types.template_id%TYPE;
   l_base_element_type_id        pay_template_core_objects.core_object_id%TYPE;
   l_source_template_id          pay_element_templates.template_id%TYPE;
   l_object_version_number       pay_element_types_f.object_version_number%TYPE;

   l_proc_step                   NUMBER(20,10);
   l_proc_name                   VARCHAR2(80) :=
                         g_package_name || 'create_user_template';
   l_element_type_id             NUMBER;
   l_balance_type_id             NUMBER;
   l_eei_element_type_id         NUMBER;
   l_ele_obj_ver_number          NUMBER;
   l_bal_obj_ver_number          NUMBER;
   i                             NUMBER;
   l_eei_info_id                 NUMBER;
   l_ovn_eei                     NUMBER;
   l_abs_ele_correction_pp       NUMBER := p_abs_ele_processing_priority - 50;
   l_pay_ele_correction_pp       NUMBER := p_pay_ele_processing_priority - 50;
   l_formula_name                pay_shadow_formulas.formula_name%TYPE;
   l_formula_id                  NUMBER;
   l_lookup_type                 fnd_lookup_types_vl.lookup_type%TYPE;
   l_lookup_meaning              fnd_lookup_types_vl.meaning%TYPE;
   l_exists                      VARCHAR2(1);
   l_display_sequence            NUMBER;
   l_base_name                   pay_element_templates.base_name%TYPE
                              := UPPER(TRANSLATE(TRIM(p_abs_ele_name),' ','_'));

   l_exc_sec_days_bf             VARCHAR2(1);

   l_days_hours                  VARCHAR2(10) ; -- Added For Hours
   l_template_name               pay_element_templates.template_name%TYPE ;
   l_configuration_information2  pay_element_templates.configuration_information2%TYPE;


   TYPE t_ele_name IS TABLE OF pay_element_types_f.element_name%TYPE
   INDEX BY BINARY_INTEGER;

   l_ele_name                    t_ele_name;
   l_ele_new_name                t_ele_name;
   l_main_ele_name               t_ele_name;
   l_retro_ele_name              t_ele_name;

   TYPE t_bal_name IS TABLE OF pay_balance_types.balance_name%TYPE
   INDEX BY BINARY_INTEGER;

   l_bal_name                    t_bal_name;
   l_bal_new_name                t_bal_name;


   TYPE t_ele_reporting_name IS TABLE OF pay_element_types_f.reporting_name%TYPE
   INDEX BY BINARY_INTEGER;

   l_ele_reporting_name          t_ele_reporting_name;

   TYPE t_ele_description IS TABLE OF pay_element_types_f.description%TYPE
   INDEX BY BINARY_INTEGER;

   l_ele_description             t_ele_description;

   TYPE t_ele_pp IS TABLE OF pay_element_types_f.processing_priority%TYPE
   INDEX BY BINARY_INTEGER;

   l_ele_pp                      t_ele_pp;

   TYPE t_eei_info IS TABLE OF pay_element_type_extra_info.eei_information19%
   TYPE
   INDEX BY BINARY_INTEGER;

   l_main_eei_info19             t_eei_info;
   l_retro_eei_info19            t_eei_info;

   TYPE r_udt_type IS RECORD
     (user_table_name   VARCHAR2(80)
     ,range_or_match    VARCHAR2(30)
     ,user_key_units    VARCHAR2(30)
     ,user_row_title    VARCHAR2(80)
     );

   l_udt_type                    r_udt_type;

   TYPE r_udt_cols_type IS RECORD
     (user_column_name   pay_user_columns.user_column_name%TYPE
     ,formula_id         pay_user_columns.formula_id%TYPE
     ,business_group_id  pay_user_columns.business_group_id%TYPE
     ,legislation_code   pay_user_columns.legislation_code%TYPE
     );

   TYPE t_udt_cols IS TABLE OF r_udt_cols_type
   INDEX BY BINARY_INTEGER;

   l_udt_cols                    t_udt_cols;

   TYPE r_udt_rows_type IS RECORD
     (row_low_range_or_name pay_user_rows_f.row_low_range_or_name%TYPE
     ,display_sequence      pay_user_rows_f.display_sequence%TYPE
     ,row_high_range        pay_user_rows_f.row_high_range%TYPE
     ,business_group_id     pay_user_rows.business_group_id%TYPE
     ,legislation_code      pay_user_rows.legislation_code%TYPE
     );

   TYPE t_udt_rows IS TABLE OF r_udt_rows_type
   INDEX BY BINARY_INTEGER;

   l_udt_rows                    t_udt_rows;

   TYPE t_number IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

   l_ele_core_id                 pay_template_core_objects.core_object_id%TYPE:=
                                  -1;

   -- Extra Information variables
   l_eei_information9            pay_element_type_extra_info.eei_information9%
   TYPE;
   l_eei_information10           pay_element_type_extra_info.eei_information10%
   TYPE;
   l_eei_information18           pay_element_type_extra_info.eei_information18%
   TYPE;

   l_eei_information30           pay_element_type_extra_info.eei_information30%
   TYPE :='Sickness'; -- 'S';--ickness'; -- used to be Sickness Previously


   l_eei_information29           pay_element_type_extra_info.eei_information29%
   TYPE := 'OCCUPATIONAL';

   l_eei_information28           pay_element_type_extra_info.eei_information28%
   TYPE := 'PQP_GAP_ENTITLEMENT_BANDS';

   l_eei_information27           pay_element_type_extra_info.eei_information27%
   TYPE := 'PQP_GB_OSP_CALENDAR_RULES';


   l_eei_information20           pay_element_type_extra_info.eei_information29%
   TYPE := p_dual_rolling_duration ; --'4';


   l_eei_information21           pay_element_type_extra_info.eei_information29%
   TYPE := p_dual_rolling_UOM ; --'YEARS';


  l_eei_information22            pay_element_type_extra_info.eei_information22%
   TYPE := p_enable_ent_proration ;  -- LG
  l_eei_information23            pay_element_type_extra_info.eei_information23%
   TYPE := p_abs_schedule_wp ;  -- LG
  l_eei_information24           pay_element_type_extra_info.eei_information24%
   TYPE := p_plan_type_lookup_type ;  -- LG
  l_eei_information14           pay_element_type_extra_info.eei_information14%
   TYPE := p_ft_round_config ;
  l_eei_information25           pay_element_type_extra_info.eei_information25%
   TYPE := p_pt_round_config ;





   l_ctr                         BINARY_INTEGER:=0;
   l_idx                         BINARY_INTEGER:=0;


   --

   CURSOR csr_get_ele_info (c_ele_name varchar2) is
   SELECT element_type_id
         ,object_version_number
   FROM   pay_shadow_element_types
   WHERE  template_id    = l_template_id
     AND  element_name   = c_ele_name;

   CURSOR csr_get_bal_info (c_bal_name varchar2) is
   SELECT balance_type_id
         ,object_version_number
     FROM pay_shadow_balance_types
   WHERE  template_id  = l_template_id
     AND  balance_name = c_bal_name;

   CURSOR csr_chk_primary_exists is
   SELECT 'X'
     FROM pay_element_type_extra_info
   WHERE  eei_information1  =  fnd_number.number_to_canonical(p_plan_id)
     AND  eei_information16 = 'Y'
     AND  information_type  = 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
     AND  rownum = 1;

   --
   --======================================================================
   --                     FUNCTION GET_TEMPLATE_ID
   --======================================================================
   FUNCTION get_template_id ( p_template_name    IN VARCHAR2
                             ,p_legislation_code IN VARCHAR2 )
       RETURN number IS
     --
  --   l_template_id   NUMBER(9);
     l_template_name VARCHAR2(80);
     l_proc_step     NUMBER(20,10);
     l_proc_name     VARCHAR2(72)       := g_package_name || 'get_template_id';
     --
     CURSOR csr_get_temp_id  is
     SELECT template_id
     FROM   pay_element_templates
     WHERE  template_name     = l_template_name
     AND    legislation_code  = p_legislation_code
     AND    template_type     = 'T'
     AND    business_group_id is NULL;
     --
   BEGIN
      --
      debug('Entering: '||l_proc_name, 10);
      --
      l_template_name  := p_template_name ; -- 'PQP OSP';
      --
      l_proc_step := 20;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      --
      for csr_get_temp_id_rec in csr_get_temp_id loop
         l_template_id   := csr_get_temp_id_rec.template_id;
      end loop;
      --
      debug('Leaving: '||l_proc_name, 30);
      --
      RETURN l_template_id;
      --
   END get_template_id;

-----------------------------------------------------------------------------

   --
   --=======================================================================
   --                FUNCTION GET_OBJECT_ID
   --=======================================================================
   FUNCTION get_object_id (p_object_type    in varchar2,
                           p_object_name   in varchar2)
   RETURN NUMBER is
     --
     l_object_id  NUMBER          := NULL;
     l_proc_step  NUMBER(20,10);
     l_proc_name  varchar2(72)    := g_package_name || 'get_object_id';
     --
     CURSOR c2 (c_object_name varchar2) is
           SELECT element_type_id
             FROM   pay_element_types_f
            WHERE  element_name      = c_object_name
              AND  business_group_id = p_bg_id;
     --
     CURSOR c3 (c_object_name in varchar2) is
          SELECT ptco.core_object_id
            FROM   pay_shadow_balance_types psbt,
                   pay_template_core_objects ptco
           WHERE  psbt.template_id      = l_template_id
             AND  psbt.balance_name     = c_object_name
             AND  ptco.template_id      = psbt.template_id
             AND  ptco.shadow_object_id = psbt.balance_type_id;
     --
   BEGIN
      debug('Entering: '||l_proc_name, 10);
      --
      if p_object_type = 'ELE' then
         for c2_rec in c2 (p_object_name) loop
            l_object_id := c2_rec.element_type_id;  -- element id
         end loop;
      elsif p_object_type = 'BAL' then
         for c3_rec in c3 (p_object_name) loop
            l_object_id := c3_rec.core_object_id;   -- balance id
         end loop;
      end if;
      --
      debug('Leaving: '||l_proc_name, 20);
      --
      RETURN l_object_id;
      --
   END get_object_id;
   --

   --
   --========================================================================
   --                     PROCEDURE Update Element Type with Retro Ele Info
   --========================================================================
   PROCEDURE update_ele_retro_info (p_main_ele_name  in    varchar2
                                   ,p_retro_ele_name in    varchar2
                                   ) IS
   --

     l_main_ele_type_id   pay_element_types_f.element_type_id%TYPE;
     l_retro_ele_type_id  pay_element_types_f.element_type_id%TYPE;
     l_proc_step          NUMBER(20,10);
     l_proc_name          VARCHAR2(72) := g_package_name ||
                                'update_ele_retro_info';

   --
   BEGIN

     --
     debug ('Entering '||l_proc_name, 10);
     --

     -- Get element type id for retro element
     l_retro_ele_type_id := get_object_id (p_object_type => 'ELE'
                                          ,p_object_name => p_retro_ele_name
                                          );


     l_proc_step := 20;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;

     -- Get element type id for main element
     l_main_ele_type_id := get_object_id (p_object_type => 'ELE'
                                         ,p_object_name => p_main_ele_name
                                         );

     -- Update main element with retro element info

     l_proc_step := 30;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;


     UPDATE pay_element_types_f
       SET  retro_summ_ele_id = l_retro_ele_type_id
     WHERE  element_type_id   = l_main_ele_type_id;

     --
     debug ('Leaving '||l_proc_name, 40);
     --

   END update_ele_retro_info;
   --


--  -----------------------------------------------------------------------------
--    ---  FUNCTION get_formula_id
--  -----------------------------------------------------------------------------
--   FUNCTION get_formula_id (p_formula_name IN VARCHAR2)
--     RETURN NUMBER
--   IS
--
--     CURSOR csr_get_formula_id
--     IS
--     SELECT formula_id
--       FROM pay_shadow_formulas
--     WHERE  formula_name  = p_formula_name
--       AND  template_type = 'T';
----       AND ((business_group_id is not null AND business_group_id = p_bg_id) OR
----           (legislation_code is not null AND legislation_code = 'GB') OR
----           (business_group_id is null AND legislation_code is null));
--
--     l_proc_step         NUMBER(20,10);
--     l_proc_name         VARCHAR2(72) := g_package_name || 'get_formula_id';
--     l_formula_id        NUMBER;
--
--  --
--  BEGIN
--    --
--    debug ('Entering '||l_proc_name, 10);
--    --
--
--    OPEN csr_get_formula_id;
--    FETCH csr_get_formula_id INTO l_formula_id;
--    CLOSE csr_get_formula_id;
--
--    --
--    debug ('Leaving '||l_proc_name, 20);
--    --
--
--    RETURN l_formula_id;
--
--   --
--  END get_formula_id;
--  --

  -----------------------------------------------------------------------------
    ---  PROCEDURE update input value default value
  -----------------------------------------------------------------------------
   PROCEDURE update_ipval_defval(p_ele_name  IN VARCHAR2
                                ,p_ip_name   IN VARCHAR2
                                ,p_def_value IN VARCHAR2)
   IS

     CURSOR csr_getinput(c_ele_name varchar2
                        ,c_iv_name  varchar2)
     IS
     SELECT input_value_id
           ,piv.name
           ,piv.element_type_id
       FROM pay_input_values_f  piv
           ,pay_element_types_f pet
     WHERE  element_name           = c_ele_name
       AND  piv.element_type_id    = pet.element_type_id
       AND  (piv.business_group_id = p_bg_id OR piv.business_group_id IS NULL)
       AND  piv.name               = c_iv_name
       AND  (piv.legislation_code  = 'GB' OR piv.legislation_code IS NULL);

     CURSOR csr_updinput(c_ip_id           number
                        ,c_element_type_id number)
     IS
     SELECT rowid
       FROM pay_input_values_f
     WHERE  input_value_id  = c_ip_id
       AND  element_type_id = c_element_type_id
     FOR UPDATE NOWAIT;

     csr_getinput_rec          csr_getinput%rowtype;
     csr_updinput_rec          csr_updinput%rowtype;


     l_proc_step               NUMBER(20,10);
     l_proc_name               VARCHAR2(72) := g_package_name ||
                                'update_ipval_defval';
   --
   BEGIN
   --

     --
     debug ('Entering '||l_proc_name, 10);
     --
     OPEN csr_getinput(p_ele_name
                      ,p_ip_name);
     LOOP

       FETCH csr_getinput INTO csr_getinput_rec;
       EXIT WHEN csr_getinput%NOTFOUND;

        --
        l_proc_step := 20;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;

        --

        OPEN csr_updinput(csr_getinput_rec.input_value_id
                        ,csr_getinput_rec.element_type_id);
        LOOP

          FETCH csr_updinput INTO csr_updinput_rec;
          EXIT WHEN csr_updinput%NOTFOUND;

            --
            l_proc_step := 30;
            IF g_debug THEN
              debug(l_proc_name, l_proc_step);
            END IF;

            --

            UPDATE pay_input_values_f
              SET default_value = p_def_value
            WHERE rowid = csr_updinput_rec.rowid;

        END LOOP;
        CLOSE csr_updinput;

     END LOOP;
     CLOSE csr_getinput;

     --
     debug ('Leaving '||l_proc_name, 40);
     --

   END update_ipval_defval;
   --
   --
   --======================================================================
   --                     FUNCTION get_user_table_id
   --======================================================================
   FUNCTION get_user_table_id (p_udt_name in   varchar2)
     RETURN NUMBER IS
   --

     CURSOR csr_get_udt_id
     IS
     SELECT user_table_id
       FROM pay_user_tables
     WHERE  user_table_name = p_udt_name
       AND (business_group_id = p_bg_id OR
            business_group_id IS NULL);

     l_proc_step       NUMBER(20,10);
     l_proc_name       VARCHAR2(72) := g_package_name || 'get_user_table_id';
     l_user_table_id   pay_user_tables.user_table_id%TYPE;

   --
   BEGIN
     --
     debug('Entering '||l_proc_name, 10);
     --
     OPEN csr_get_udt_id;
     FETCH csr_get_udt_id INTO l_user_table_id;
     CLOSE csr_get_udt_id;

     debug('Leaving '||l_proc_name, 20);

     RETURN l_user_table_id;

   END get_user_table_id;
   --

   --
   --======================================================================
   --                     FUNCTION get_udt_col_info
   --======================================================================
   PROCEDURE get_udt_col_info (p_lookup_type       in     varchar2
                              ,p_lookup_code       in     varchar2
                              ,p_formula_id        in     number
                              ,p_business_group_id in     number
                              ,p_legislation_code  in     varchar2
                              ,p_udt_cols             out nocopy t_udt_cols
                              )
   IS
   --

      CURSOR csr_get_lookup_info is
      SELECT meaning
        FROM hr_lookups
      WHERE  lookup_type = p_lookup_type
        AND  lookup_code like p_lookup_code
        AND  enabled_flag = 'Y'
      ORDER BY lookup_code;

      l_proc_step      NUMBER(20,10);
      l_proc_name      VARCHAR2(72) := g_package_name || 'get_udt_col_info';
      l_udt_col_name   pay_user_columns.user_column_name%TYPE;
      l_udt_cols       t_udt_cols;
      i                number;

   --
   BEGIN

     --
     debug ('Entering ' || l_proc_name, 10);
     --

     -- Get information from Lookup

     i := 0;
     OPEN csr_get_lookup_info;
     LOOP

        FETCH csr_get_lookup_info INTO l_udt_col_name;
        EXIT WHEN csr_get_lookup_info%NOTFOUND;

        i := i + 1;
        l_udt_cols(i).user_column_name  := l_udt_col_name;
        l_udt_cols(i).formula_id        := p_formula_id;
        l_udt_cols(i).business_group_id := p_business_group_id;
        l_udt_cols(i).legislation_code  := p_legislation_code;

     END LOOP;

     p_udt_cols := l_udt_cols;

     --
     debug ('Leaving '||l_proc_name, 20);
-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       debug('Entering excep:'||l_proc_name, 35);
       p_udt_cols.delete;
       raise;
     --

END get_udt_col_info;
   --

   --
   --======================================================================
   --                     FUNCTION get_udt_row_info
   --======================================================================
PROCEDURE get_udt_row_info (p_lookup_type       in     varchar2
                              ,p_lookup_code       in     varchar2
                              ,p_udt_type          in     varchar2
                              ,p_display_sequence  in out nocopy number
                              ,p_business_group_id in     number
                              ,p_legislation_code  in     varchar2
                              ,p_udt_rows          in out nocopy t_udt_rows
                              )
IS
   --

      CURSOR csr_get_lookup_info is
      SELECT meaning
        FROM hr_lookups
      WHERE  lookup_type = p_lookup_type
        AND  lookup_code like p_lookup_code
        AND  enabled_flag = 'Y'
      ORDER BY lookup_code;

      l_proc_name        VARCHAR2(72) := g_package_name || 'get_udt_row_info';
      l_udt_row_name     pay_user_rows_f.row_low_range_or_name%TYPE;
      l_udt_rows         t_udt_rows;
      -- Nocopy changes
      l_udt_rows_nc      t_udt_rows;
      l_display_seq_nc   NUMBER;

      i                  number;
      l_display_sequence number := p_display_sequence;

   --
   BEGIN

     --
     debug ('Entering ' || l_proc_name, 10);
     --

     -- Nocopy changes
     l_udt_rows_nc := p_udt_rows;
     l_display_seq_nc := p_display_sequence;

     -- Get information from Lookup

     IF p_udt_rows.count > 0 THEN
        i          := p_udt_rows.LAST;
        l_udt_rows := p_udt_rows;

     ELSE
        i := 0;

     END IF; -- End if of count check ...

     OPEN csr_get_lookup_info;
     LOOP

        FETCH csr_get_lookup_info INTO l_udt_row_name;
        EXIT WHEN csr_get_lookup_info%NOTFOUND;

        i := i + 1;

        l_udt_rows(i).row_low_range_or_name  := l_udt_row_name;

        IF p_udt_type = 'R' THEN
          l_udt_rows(i).row_high_range         := l_udt_row_name;
        END IF;

        l_udt_rows(i).business_group_id      := p_business_group_id;
        l_udt_rows(i).legislation_code       := p_legislation_code;
        l_udt_rows(i).display_sequence       := l_display_sequence;

        l_display_sequence := l_display_sequence + 1;

     END LOOP;

     p_display_sequence := l_display_sequence;

     p_udt_rows := l_udt_rows;

     --
     debug ('Leaving '||l_proc_name, 20);
     --

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       debug('Entering excep:'||l_proc_name, 35);
       p_udt_rows := l_udt_rows_nc;
       p_display_sequence := l_display_seq_nc;
       raise;

END get_udt_row_info;
   --

   --
   --======================================================================
   --                     FUNCTION create_udt
   --======================================================================
   FUNCTION create_udt (p_udt_type r_udt_type
                       ,p_udt_cols t_udt_cols
                       ,p_udt_rows t_udt_rows
                       )
     RETURN NUMBER IS
   --

     CURSOR csr_get_next_udt_row_seq
     IS
     SELECT pay_user_rows_s.NEXTVAL
       FROM dual;

     l_proc_name      VARCHAR2(72) := g_package_name || 'create_udt';
     l_user_table_id  pay_user_tables.user_table_id%TYPE;
     l_user_column_id pay_user_columns.user_column_id%TYPE;
     l_user_row_id    pay_user_rows_f.user_row_id%TYPE;
     l_udt_rowid      rowid ;
     l_udt_cols_rowid rowid;
     l_udt_rows_rowid rowid;

   --
   BEGIN

     --
     debug ('Entering '||l_proc_name, 10);
     --

     -- Create the UDT

     l_proc_step := 20;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;


     pay_user_tables_pkg.insert_row
        (p_rowid                 => l_udt_rowid
        ,p_user_table_id         => l_user_table_id
        ,p_business_group_id     => p_bg_id
        ,p_legislation_code      => NULL
        ,p_legislation_subgroup  => NULL
        ,p_range_or_match        => p_udt_type.range_or_match
        ,p_user_key_units        => p_udt_type.user_key_units
        ,p_user_table_name       => p_udt_type.user_table_name
        ,p_user_row_title        => p_udt_type.user_row_title
        );

     IF p_udt_cols.count > 0 THEN

        -- Create the columns
        l_proc_step := 30;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        i := p_udt_cols.FIRST;

        WHILE i IS NOT NULL
        LOOP

                pay_user_columns_pkg.insert_row
                  (p_rowid                => l_udt_cols_rowid
                  ,p_user_column_id       => l_user_column_id
                  ,p_user_table_id        => l_user_table_id
                  ,p_business_group_id    => p_udt_cols(i).business_group_id
                  ,p_legislation_code     => p_udt_cols(i).legislation_code
                  ,p_legislation_subgroup => NULL
                  ,p_user_column_name     => p_udt_cols(i).user_column_name
                  ,p_formula_id           => p_udt_cols(i).formula_id
                  );

                i := p_udt_cols.NEXT(i);
        END LOOP;

     END IF; -- End if of user cols > 1 check ...

     IF p_udt_rows.count > 0 THEN

        l_proc_step := 40;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;

        -- Create the rows

        i := p_udt_rows.FIRST;

        WHILE i IS NOT NULL
        LOOP

                OPEN csr_get_next_udt_row_seq;
                FETCH csr_get_next_udt_row_seq INTO l_user_row_id;
                CLOSE csr_get_next_udt_row_seq;

                pay_user_rows_pkg.pre_insert
                 (p_rowid                 => l_udt_rows_rowid
                 ,p_user_table_id         => l_user_table_id
                 ,p_row_low_range_or_name => p_udt_rows(i).row_low_range_or_name
                 ,p_user_row_id           => l_user_row_id
                 ,p_business_group_id     => p_bg_id
                 );

                INSERT INTO pay_user_rows_f
                  (user_row_id
                  ,effective_start_date
                  ,effective_end_date
                  ,business_group_id
                  ,legislation_code
                  ,user_table_id
                  ,row_low_range_or_name
                  ,display_sequence
                  ,legislation_subgroup
                  ,row_high_range
                  )
                VALUES
                  (l_user_row_id
                  ,p_ele_eff_start_date
                  ,nvl(p_ele_eff_end_date, hr_api.g_eot)
                  ,p_udt_rows(i).business_group_id
                  ,p_udt_rows(i).legislation_code
                  ,l_user_table_id
                  ,p_udt_rows(i).row_low_range_or_name
                  ,p_udt_rows(i).display_sequence
                  ,NULL
                  ,p_udt_rows(i).row_high_range
                  );

                i := p_udt_rows.NEXT(i);

        END LOOP; -- End Loop for user rows...
     END IF; -- End if of user rows if present check...

    debug ('Leaving '||l_proc_name, 50);

    RETURN l_user_table_id;

  --
  END create_udt;
  --

   --
   --======================================================================
   --                     PROCEDURE create_lookup
   --======================================================================
   PROCEDURE create_lookup (p_lookup_type    varchar2
                           ,p_lookup_meaning varchar2
                           ,p_lookup_values  t_abs_types
                           ) IS
   --

     CURSOR csr_chk_uniq_type
     IS
     SELECT 'X'
       FROM fnd_lookup_types_vl
     WHERE  lookup_type         = p_lookup_type
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     CURSOR csr_chk_uniq_meaning
     IS
     SELECT 'X'
       FROM fnd_lookup_types_vl
     WHERE  meaning             = p_lookup_meaning
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     l_proc_step      NUMBER(20,10);
     l_proc_name      VARCHAR2(72) := g_package_name || 'create_lookup';
     l_exists         VARCHAR2(1);
     l_rowid          fnd_lookup_types_vl.row_id%type;
     l_user_id        number := fnd_global.user_id;
     l_login_id       number := fnd_global.login_id;

   --
   BEGIN
     --
     debug('Entering '||l_proc_name, 10);
     --

     -- Check unique lookup type
     OPEN csr_chk_uniq_type;
     FETCH csr_chk_uniq_type INTO l_exists;

     IF csr_chk_uniq_type%FOUND THEN

        -- Raise error
        CLOSE csr_chk_uniq_type;
        hr_utility.set_message(0, 'QC-DUPLICATE TYPE');
        hr_utility.raise_error;

     END IF; -- End if of unique lookup type check ...
     CLOSE csr_chk_uniq_type;

     l_proc_step := 20;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;


     -- Check unique lookup type meaning
     OPEN csr_chk_uniq_meaning;
     FETCH csr_chk_uniq_meaning INTO l_exists;

     IF csr_chk_uniq_meaning%FOUND THEN

        -- Raise error
        CLOSE csr_chk_uniq_meaning;
        hr_utility.set_message(0, 'QC-DUPLICATE TYPE MEANING');
        hr_utility.raise_error;

     END IF; -- End if of unique lookup type meaning check ...
     CLOSE csr_chk_uniq_meaning;

     -- Create Lookup type
     l_proc_step := 30;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;


     fnd_lookup_types_pkg.insert_row
        (
         x_rowid               => l_rowid
        ,x_lookup_type         => p_lookup_type
        ,x_security_group_id   => p_security_group_id
        ,x_view_application_id => 3
        ,x_application_id      => 800
        ,x_customization_level => 'U'
        ,x_meaning             => p_lookup_meaning
        ,x_description         => NULL
        ,x_creation_date       => SYSDATE
        ,x_created_by          => l_user_id
        ,x_last_update_date    => SYSDATE
        ,x_last_updated_by     => l_user_id
        ,x_last_update_login   => l_login_id
        );

     -- Create Lookup Values
     -- The validation for lookup values should've been taken care in the
     -- form
     l_proc_step := 40;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;

     IF p_lookup_values.count > 0 THEN

        i := p_lookup_values.FIRST;
        WHILE i IS NOT NULL
          LOOP
            fnd_lookup_values_pkg.insert_row
              (
               x_rowid               => l_rowid
              ,x_lookup_type         => p_lookup_type
              ,x_security_group_id   => p_security_group_id
              ,x_view_application_id => 3
              ,x_lookup_code         => fnd_number.number_to_canonical(
                                          p_lookup_values(i).abs_type_id)
              ,x_tag                 => NULL
              ,x_attribute_category  => NULL
              ,x_attribute1          => NULL
              ,x_attribute2          => NULL
              ,x_attribute3          => NULL
              ,x_attribute4          => NULL
              ,x_attribute5          => NULL
              ,x_attribute6          => NULL
              ,x_attribute7          => NULL
              ,x_attribute8          => NULL
              ,x_attribute9          => NULL
              ,x_attribute10         => NULL
              ,x_attribute11         => NULL
              ,x_attribute12         => NULL
              ,x_attribute13         => NULL
              ,x_attribute14         => NULL
              ,x_attribute15         => NULL
              ,x_enabled_flag        => 'Y'
              ,x_start_date_active   => p_ele_eff_start_date
              ,x_end_date_active     => NULL
              ,x_territory_code      => NULL
              ,x_meaning             => p_lookup_values(i).abs_type_name
              ,x_description         => NULL
              ,x_creation_date       => SYSDATE
              ,x_created_by          => l_user_id
              ,x_last_update_date    => SYSDATE
              ,x_last_updated_by     => l_user_id
              ,x_last_update_login   => l_login_id
              );

            i := p_lookup_values.NEXT(i);

        END LOOP;

     END IF; -- End if of p_lookup_values check ...

    --
    debug('Leaving '||l_proc_name, 60);
    --
   END create_lookup;
   --

   --
   --======================================================================
   --                     PROCEDURE create_plan_lookup
   --======================================================================
   PROCEDURE create_plan_lookup (p_lookup_type    varchar2
                           ,p_lookup_meaning varchar2
                           ,p_lookup_values  t_plan_types
                           ) IS
   --

     CURSOR csr_chk_uniq_type
     IS
     SELECT 'X'
       FROM fnd_lookup_types_vl
     WHERE  lookup_type         = p_lookup_type
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     CURSOR csr_chk_uniq_meaning
     IS
     SELECT 'X'
       FROM fnd_lookup_types_vl
     WHERE  meaning             = p_lookup_meaning
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     l_proc_step      NUMBER(20,10);
     l_proc_name      VARCHAR2(72) := g_package_name || 'create_plan_lookup';
     l_exists         VARCHAR2(1);
     l_rowid          fnd_lookup_types_vl.row_id%type;
     l_user_id        number := fnd_global.user_id;
     l_login_id       number := fnd_global.login_id;

   --
   BEGIN
     --
     debug('Entering '||l_proc_name, 10);
     --

     -- Check unique lookup type
     OPEN csr_chk_uniq_type;
     FETCH csr_chk_uniq_type INTO l_exists;

     IF csr_chk_uniq_type%FOUND THEN

        -- Raise error
        CLOSE csr_chk_uniq_type;
        hr_utility.set_message(0, 'QC-DUPLICATE TYPE');
        hr_utility.raise_error;

     END IF; -- End if of unique lookup type check ...
     CLOSE csr_chk_uniq_type;

     l_proc_step := 20;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;


     -- Check unique lookup type meaning
     OPEN csr_chk_uniq_meaning;
     FETCH csr_chk_uniq_meaning INTO l_exists;

     IF csr_chk_uniq_meaning%FOUND THEN

        -- Raise error
        CLOSE csr_chk_uniq_meaning;
        hr_utility.set_message(0, 'QC-DUPLICATE TYPE MEANING');
        hr_utility.raise_error;

     END IF; -- End if of unique lookup type meaning check ...
     CLOSE csr_chk_uniq_meaning;

     -- Create Lookup type
     l_proc_step := 30;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;


     fnd_lookup_types_pkg.insert_row
        (
         x_rowid               => l_rowid
        ,x_lookup_type         => p_lookup_type
        ,x_security_group_id   => p_security_group_id
        ,x_view_application_id => 3
        ,x_application_id      => 800
        ,x_customization_level => 'U'
        ,x_meaning             => p_lookup_meaning
        ,x_description         => NULL
        ,x_creation_date       => SYSDATE
        ,x_created_by          => l_user_id
        ,x_last_update_date    => SYSDATE
        ,x_last_updated_by     => l_user_id
        ,x_last_update_login   => l_login_id
        );

     -- Create Lookup Values
     -- The validation for lookup values should've been taken care in the
     -- form
     l_proc_step := 40;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;

     IF p_lookup_values.count > 0 THEN

        i := p_lookup_values.FIRST;
        WHILE i IS NOT NULL
          LOOP
            fnd_lookup_values_pkg.insert_row
              (
               x_rowid               => l_rowid
              ,x_lookup_type         => p_lookup_type
              ,x_security_group_id   => p_security_group_id
              ,x_view_application_id => 3
              ,x_lookup_code         => fnd_number.number_to_canonical(
                                          p_lookup_values(i).plan_type_id)
              ,x_tag                 => NULL
              ,x_attribute_category  => NULL
              ,x_attribute1          => NULL
              ,x_attribute2          => NULL
              ,x_attribute3          => NULL
              ,x_attribute4          => NULL
              ,x_attribute5          => NULL
              ,x_attribute6          => NULL
              ,x_attribute7          => NULL
              ,x_attribute8          => NULL
              ,x_attribute9          => NULL
              ,x_attribute10         => NULL
              ,x_attribute11         => NULL
              ,x_attribute12         => NULL
              ,x_attribute13         => NULL
              ,x_attribute14         => NULL
              ,x_attribute15         => NULL
              ,x_enabled_flag        => 'Y'
              ,x_start_date_active   => p_ele_eff_start_date
              ,x_end_date_active     => NULL
              ,x_territory_code      => NULL
              ,x_meaning             => p_lookup_values(i).name
              ,x_description         => NULL
              ,x_creation_date       => SYSDATE
              ,x_created_by          => l_user_id
              ,x_last_update_date    => SYSDATE
              ,x_last_updated_by     => l_user_id
              ,x_last_update_login   => l_login_id
              );

            i := p_lookup_values.NEXT(i);

        END LOOP;

     END IF; -- End if of p_lookup_values check ...

    --
    debug('Leaving '||l_proc_name, 60);
    --
   END create_plan_lookup;
   --
   ---------------
--==============================================================================
--                         MAIN FUNCTION
--==============================================================================

  BEGIN


     g_debug := hr_utility.debug_enabled;

     debug_enter(l_proc_name);

   ---------------------
   -- Set session date
   ---------------------

   pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
   --


   l_proc_step := 20;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;

   --

  IF (hr_utility.chk_product_install('Oracle Payroll',g_template_leg_code))
  THEN

   l_exc_sec_days_bf := NULL;

   OPEN csr_chk_primary_exists;
   FETCH csr_chk_primary_exists INTO l_exists;

   -- Check whether Primary Plan Exists when creating Secondary Plans
   IF p_abs_primary_yn = 'N' THEN

      l_proc_step := 25;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;



      IF csr_chk_primary_exists%NOTFOUND THEN

         -- Raise Error
         CLOSE csr_chk_primary_exists;
         hr_utility.set_message(8303, 'PQP_230608_OSP_PRIM_NOT_FOUND');
         hr_utility.raise_error;

      END IF; -- End if of primary element check...

      -- Exclude balance feeds to generic days balance for secondary elements
      l_exc_sec_days_bf := 'N';

   -- Check whether Primary Elements exists for this plan
   -- when creating Primary Scheme

   ELSIF p_abs_primary_yn = 'Y' THEN

      IF csr_chk_primary_exists%FOUND THEN

         -- Raise Error
         CLOSE csr_chk_primary_exists;
         hr_utility.set_message(8303, 'PQP_230666_OSP_PRIMARY_EXISTS');
         hr_utility.raise_error;

      END IF; -- End if of primary element check...

   END IF; -- End if of abs primary yes or no check...
   CLOSE csr_chk_primary_exists;


   ---------------------------
   -- Get Source Template ID
   ---------------------------


-- Added for Hours

-- Check which Template to call
   -- If p_abs_days = 'H' or p_abs_daily_rate_calc_method = 'H'
   -- then Call 'OSP Hours Template' else 'OSP Template'

    IF p_abs_days = 'H' OR p_abs_daily_rate_calc_method = 'H' THEN
        l_template_name := 'PQP OSP HOURS' ;
        l_days_hours    := 'Hours ' ;
    ELSE
        l_template_name := 'PQP OSP' ;
        l_days_hours    := NULL ;
    END IF ;

-- Added for Hours


   l_source_template_id := get_template_id
                             (p_template_name     => l_template_name
                             ,p_legislation_code  => g_template_leg_code
                             );



   /*--------------------------------------------------------------------------
      Create the user Structure
      The Configuration Flex segments for the Exclusion Rules are as follows:
    ---------------------------------------------------------------------------
    Config1  --
    Config2  --
   ---------------------------------------------------------------------------*/

   l_proc_step := 40;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;


   --
   -- create user structure from the template
   --

   IF p_sch_cal_type = 'DUALROLLING' THEN
     l_configuration_information2 := 'CIVILSERVICE_OSP';
   ELSE
     l_configuration_information2 := 'REGULAR_OSP';
   END IF;

   pay_element_template_api.create_user_structure
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_business_group_id             =>     p_bg_id
    ,p_source_template_id            =>     l_source_template_id
    ,p_base_name                     =>     p_abs_ele_name
    ,p_configuration_information1    =>     l_exc_sec_days_bf
    ,p_configuration_information2    =>     l_configuration_information2
    ,p_template_id                   =>     l_template_id
    ,p_allow_base_name_reuse         =>     true
    ,p_object_version_number         =>     l_object_version_number
    );
   --

   l_proc_step := 50;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;

   ---------------------------------------------------------------------------
   ---------------------------- Update Shadow Structure ----------------------
   --


   l_ctr := l_ctr + 1;


   l_ele_name(l_ctr)           := p_abs_ele_name || ' OSP '||l_days_hours||'Absence';
   l_ele_reporting_name(l_ctr) := p_abs_ele_reporting_name;
   l_ele_description(l_ctr)    := p_abs_ele_description;
   l_ele_pp(l_ctr)             := p_abs_ele_processing_priority;

   l_ctr := l_ctr + 1;

   l_ele_name(l_ctr)           := p_abs_ele_name || ' OSP '||l_days_hours||'Pay';
   l_ele_reporting_name(l_ctr) := p_pay_ele_reporting_name;
   l_ele_description(l_ctr)    := p_pay_ele_description;
   l_ele_pp(l_ctr)             := p_pay_ele_processing_priority;


   l_idx := l_ele_name.FIRST;
   WHILE l_idx IS NOT NULL
   LOOP

     OPEN csr_get_ele_info(l_ele_name(l_idx));
     LOOP
       FETCH csr_get_ele_info INTO l_element_type_id,l_ele_obj_ver_number;
       EXIT WHEN csr_get_ele_info%NOTFOUND;
       if i = 1 then
          l_base_element_type_id := l_element_type_id;
       end if;

       pay_shadow_element_api.update_shadow_element
         (p_validate                     => false
         ,p_effective_date               => p_ele_eff_start_date
         ,p_element_type_id              => l_element_type_id
         ,p_element_name                 => l_ele_name(l_idx)
         ,p_reporting_name               => l_ele_reporting_name(l_idx)
         ,p_description                  => l_ele_description(l_idx)
         ,p_relative_processing_priority => l_ele_pp(l_idx)
         ,p_object_version_number        => l_ele_obj_ver_number
         );

     END LOOP;
     CLOSE csr_get_ele_info;

   l_idx := l_ele_name.NEXT(l_idx);

   END LOOP; -- WHILE l_idx IS NOT NULL


   l_ctr := 0;
   l_ctr := l_ctr + 1; --1

   l_ele_name(l_ctr)      := p_abs_ele_name || ' OSP '||l_days_hours||'Absence Retro';
   l_ele_new_name(l_ctr)  := l_ele_name(l_ctr);
   l_ele_pp(l_ctr)        := l_abs_ele_correction_pp;

   l_ctr := l_ctr + 1; --2

   l_ele_name(l_ctr)      := p_abs_ele_name || ' OSP '||l_days_hours||'Pay Retro';
   l_ele_new_name(l_ctr)  := l_ele_name(l_ctr);
   l_ele_pp(l_ctr)        := l_pay_ele_correction_pp;

   l_ctr := l_ctr + 1; --3

   l_ele_name(l_ctr)      := p_abs_ele_name || ' OSP '||l_days_hours||'Band1 Pay';
   l_ele_new_name(l_ctr)  := l_ele_name(l_ctr);
   IF p_bnd1_ele_sub_name IS NOT NULL THEN
     l_ele_new_name(l_ctr)  := p_abs_ele_name || ' ' || p_bnd1_ele_sub_name ||
                         ' OSP '||l_days_hours||'Band1 Pay';
   END IF; -- End if of bnd1 sub name not null check...
   l_ele_pp(l_ctr)        := p_pay_ele_processing_priority;

   l_ctr := l_ctr + 1; --4

   l_ele_name(l_ctr)      := p_abs_ele_name || ' OSP '||l_days_hours||'Band1 Pay Retro';
   l_ele_new_name(l_ctr)  := l_ele_name(l_ctr);
   IF p_bnd1_ele_sub_name IS NOT NULL THEN
     l_ele_new_name(l_ctr)  := p_abs_ele_name || ' ' || p_bnd1_ele_sub_name ||
                         ' OSP '||l_days_hours||'Band1 Pay Retro';
   END IF; -- End if of bnd1 sub name not null check...
   l_ele_pp(l_ctr)        := l_pay_ele_correction_pp;

   l_ctr := l_ctr + 1; --5

   l_ele_name(l_ctr)      := p_abs_ele_name || ' OSP '||l_days_hours||'Band2 Pay';
   l_ele_new_name(l_ctr)  := l_ele_name(l_ctr);
   IF p_bnd2_ele_sub_name IS NOT NULL THEN
     l_ele_new_name(l_ctr)  := p_abs_ele_name || ' ' || p_bnd2_ele_sub_name ||
                         ' OSP '||l_days_hours||'Band2 Pay';
   END IF; -- End if of bnd2 sub name not null check ...
   l_ele_pp(l_ctr)        := p_pay_ele_processing_priority;

   l_ctr := l_ctr + 1; --6

   l_ele_name(l_ctr)      := p_abs_ele_name || ' OSP '||l_days_hours||'Band2 Pay Retro';
   l_ele_new_name(l_ctr)  := l_ele_name(l_ctr);
   IF p_bnd2_ele_sub_name IS NOT NULL THEN
     l_ele_new_name(l_ctr)  := p_abs_ele_name || ' ' || p_bnd2_ele_sub_name ||
                         ' OSP '||l_days_hours||'Band2 Pay Retro';
   END IF; -- End if of bnd2 sub name not null check ...
   l_ele_pp(l_ctr)        := l_pay_ele_correction_pp;


IF p_sch_cal_type <> 'DUALROLLING' -- In Dual Rolling Schemes we do not support band3 and 4
THEN

   l_ctr := l_ctr + 1; --7

   l_ele_name(l_ctr)      := p_abs_ele_name || ' OSP '||l_days_hours||'Band3 Pay';
   l_ele_new_name(l_ctr)  := l_ele_name(l_ctr);
   IF p_bnd3_ele_sub_name IS NOT NULL THEN
     l_ele_new_name(l_ctr)  := p_abs_ele_name || ' ' || p_bnd3_ele_sub_name ||
                         ' OSP '||l_days_hours||'Band3 Pay';
   END IF; -- End if of bnd3 sub name not null check...
   l_ele_pp(l_ctr)        := p_pay_ele_processing_priority;

   l_ctr := l_ctr + 1; --8

   l_ele_name(l_ctr)      := p_abs_ele_name || ' OSP '||l_days_hours||'Band3 Pay Retro';
   l_ele_new_name(l_ctr)  := l_ele_name(l_ctr);
   IF p_bnd3_ele_sub_name IS NOT NULL THEN
     l_ele_new_name(l_ctr)  := p_abs_ele_name || ' ' || p_bnd3_ele_sub_name ||
                         ' OSP '||l_days_hours||'Band3 Pay Retro';
   END IF; -- End if of bnd3 sub name not null check...
   l_ele_pp(l_ctr)        := l_pay_ele_correction_pp;

   l_ctr := l_ctr + 1; --9

   l_ele_name(l_ctr)      := p_abs_ele_name || ' OSP '||l_days_hours||'Band4 Pay';
   l_ele_new_name(l_ctr)  := l_ele_name(l_ctr);
   IF p_bnd4_ele_sub_name IS NOT NULL THEN
     l_ele_new_name(l_ctr)  := p_abs_ele_name || ' ' || p_bnd4_ele_sub_name ||
                         ' OSP '||l_days_hours||'Band4 Pay';
   END IF; -- End if of bnd4 sub name not null check...
   l_ele_pp(l_ctr)        := p_pay_ele_processing_priority;

   l_ctr := l_ctr + 1; --10

   l_ele_name(l_ctr)     := p_abs_ele_name || ' OSP '||l_days_hours||'Band4 Pay Retro';
   l_ele_new_name(l_ctr) := l_ele_name(l_ctr);
   IF p_bnd4_ele_sub_name IS NOT NULL THEN
     l_ele_new_name(l_ctr) := p_abs_ele_name || ' ' || p_bnd4_ele_sub_name ||
                         ' OSP '||l_days_hours||'Band4 Pay Retro';
   END IF; -- End if of bnd4 sub name not null check...
   l_ele_pp(l_ctr)       := l_pay_ele_correction_pp;


END IF; -- IF p_sch_cal_type <> 'DUALROLLING'

   l_ctr := l_ctr + 1; --11 or 7

   IF l_days_hours IS NULL
   THEN
     l_ele_name(l_ctr)     := p_abs_ele_name || ' OSP Minimum Pay';
     -- once we support this in hours
     --l_ele_name(l_ctr)     := p_abs_ele_name || ' OSP '||l_days_hours||'OSP Minimum Pay';
     l_ele_new_name(l_ctr) := l_ele_name(l_ctr);
     l_ele_pp(l_ctr)       := p_pay_ele_processing_priority;


     --once I add the twin retro element
     l_ctr := l_ctr + 1; --12 or 8
     l_ele_name(l_ctr)     := p_abs_ele_name || ' OSP Minimum Pay Retro';
     -- once we support this in hours
     --l_ele_name(l_ctr)     := p_abs_ele_name || ' OSP '||l_days_hours||'OSP Minimum Pay';
     l_ele_new_name(l_ctr) := l_ele_name(l_ctr);
     l_ele_pp(l_ctr)       := l_pay_ele_correction_pp;

   END IF;


   l_proc_step := 60;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;


   l_idx := l_ele_name.FIRST;
   WHILE l_idx IS NOT NULL
   LOOP

     OPEN csr_get_ele_info(l_ele_name(l_idx));
     LOOP
       FETCH csr_get_ele_info INTO l_element_type_id,l_ele_obj_ver_number;
       EXIT WHEN csr_get_ele_info%NOTFOUND;

       pay_shadow_element_api.update_shadow_element
         (p_validate                     => false
         ,p_effective_date               => p_ele_eff_start_date
         ,p_element_type_id              => l_element_type_id
         ,p_element_name                 => l_ele_new_name(l_idx)
         ,p_relative_processing_priority => l_ele_pp(l_idx)
         ,p_object_version_number        => l_ele_obj_ver_number
         );

     END LOOP;
     CLOSE csr_get_ele_info;

     l_idx := l_ele_name.NEXT(l_idx);

   END LOOP; --

   -- Update shadow structure for Balances

   l_proc_step := 70;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;


   l_ctr := 0;
   IF p_bnd1_ele_sub_name IS NOT NULL THEN

     l_ctr := l_ctr + 1;
     l_bal_name(l_ctr)      := p_abs_ele_name||' Band1 Pay Paid';
     l_bal_new_name(l_ctr)  := p_abs_ele_name||' '||p_bnd1_ele_sub_name||' Band1 Pay Paid';

     l_ctr := l_ctr + 1;
     l_bal_name(l_ctr)      := p_abs_ele_name||' Band1 Hours Pay Entitlement';
     l_bal_new_name(l_ctr)  := p_abs_ele_name||' '||p_bnd1_ele_sub_name||' Band1 Hours Pay Entitlement';

     IF p_bnd2_ele_sub_name IS NOT NULL THEN

       l_ctr := l_ctr + 1;
       l_bal_name(l_ctr)      := p_abs_ele_name||' Band2 Pay Paid';
       l_bal_new_name(l_ctr)  := p_abs_ele_name||' '||p_bnd2_ele_sub_name||' Band2 Pay Paid';

       l_ctr := l_ctr + 1;
       l_bal_name(l_ctr)      := p_abs_ele_name||' Band2 Hours Pay Entitlement';
       l_bal_new_name(l_ctr)  := p_abs_ele_name||' '||p_bnd2_ele_sub_name||' Band2 Hours Pay Entitlement';

       IF p_bnd3_ele_sub_name IS NOT NULL AND p_sch_cal_type <> 'DUALROLLING' THEN


         l_ctr := l_ctr + 1;
         l_bal_name(l_ctr)      := p_abs_ele_name||' Band3 Pay Paid';
         l_bal_new_name(l_ctr)  := p_abs_ele_name||' '||p_bnd3_ele_sub_name||' Band3 Pay Paid';

         l_ctr := l_ctr + 1;
         l_bal_name(l_ctr)      := p_abs_ele_name||' Band3 Hours Pay Entitlement';
         l_bal_new_name(l_ctr)  := p_abs_ele_name||' '||p_bnd3_ele_sub_name||' Band3 Hours Pay Entitlement';

         IF p_bnd4_ele_sub_name IS NOT NULL THEN

           l_ctr := l_ctr + 1;
           l_bal_name(l_ctr)     := p_abs_ele_name||' Band4 Pay Paid';
           l_bal_new_name(l_ctr) := p_abs_ele_name||' '||p_bnd4_ele_sub_name||' Band4 Pay Paid';

           l_ctr := l_ctr + 1;
           l_bal_name(l_ctr)     := p_abs_ele_name||' Band4 Hours Pay Entitlement';
           l_bal_new_name(l_ctr) := p_abs_ele_name||' '||p_bnd4_ele_sub_name||' Band4 Hours Pay Entitlement';

         END IF; --  END IF of bnd4 sub name check ...

       END IF; -- END IF of bnd3 sub name check ...

     END IF; -- END IF of bnd2 sub name check ...

   END IF; -- END IF of bnd1 sub name check ...

   l_proc_step := 80;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;


   l_idx := l_bal_name.FIRST;
   WHILE l_idx IS NOT NULL
   LOOP

     OPEN csr_get_bal_info(l_bal_name(i));
     LOOP
       FETCH csr_get_bal_info INTO l_balance_type_id,l_bal_obj_ver_number;
       EXIT WHEN csr_get_bal_info%NOTFOUND;

       pay_sbt_upd.upd
         (p_effective_date               => p_ele_eff_start_date
         ,p_balance_type_id              => l_balance_type_id
         ,p_balance_name                 => l_bal_new_name(i)
         ,p_object_version_number        => l_bal_obj_ver_number
         );

     END LOOP;
     CLOSE csr_get_bal_info;

     l_idx := l_bal_name.NEXT(l_idx);

   END LOOP; -- l_idx := l_bal_name.FIRST;


   -------------------------------------------------------------------------
   --
   --
   l_proc_step := 90;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;

   ---------------------------------------------------------------------------
   ---------------------------- Generate Core Objects ------------------------
   ---------------------------------------------------------------------------

   pay_element_template_api.generate_part1
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_hr_only                       =>     false
    ,p_hr_to_payroll                 =>     false
    ,p_template_id                   =>     l_template_id);
   --
   l_proc_step := 100;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;

   --
   pay_element_template_api.generate_part2
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_template_id                   =>     l_template_id);
   --

   -- Update Main Elements with the Correction Element Information

   l_proc_step := 110;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;


-- Absence (Create)--lctr
-- Pay (Create)
-- Absence Retro   --l_idx.FIRST
-- Pay Retro Retro
-- Band1 Pay
-- Band1 Pay Retro
-- Band2 Pay
-- Band2 Pay Retro
-- Band3 Pay
-- Band3 Pay Retro
-- Band4 Pay
-- Band4 Pay Retro
-- Minimum Pay
-- Minimum Pay Retro

   l_ctr := 0;

   --1
   l_ctr := l_ctr + 1; --1 -- create manual entry as it does not exist in source array
   l_main_ele_name(l_ctr)    := p_abs_ele_name || ' OSP '||l_days_hours||'Absence';
   l_main_eei_info19(l_ctr)  := 'Absence Info';

   --create main and retro entries at the same index

   l_idx := l_ele_new_name.FIRST;
   l_retro_ele_name(l_ctr)   := l_ele_new_name(l_idx); -- create from source array
   l_retro_eei_info19(l_ctr) := 'Absence Correction Info';


   --2
   l_ctr := l_ctr + 1;   -- increment l_ctr after each pair

   --create manual entry as it does not exist in source array
   l_main_ele_name(l_ctr)    := p_abs_ele_name || ' OSP '||l_days_hours||'Pay';
   l_main_eei_info19(l_ctr)  := 'Pay Info';

   l_idx := l_ele_new_name.NEXT(l_idx); -- next in source
   l_retro_ele_name(l_ctr)   := l_ele_new_name(l_idx); -- copy from source
   l_retro_eei_info19(l_ctr) := 'Pay Correction Info';


   --3
   l_ctr := l_ctr + 1;

   l_idx := l_ele_new_name.NEXT(l_idx);
   l_main_ele_name(l_ctr)    := l_ele_new_name(l_idx);
   l_main_eei_info19(l_ctr)  := 'Band1 Info';

   l_idx := l_ele_new_name.NEXT(l_idx);
   l_retro_ele_name(l_ctr)   := l_ele_new_name(l_idx);
   l_retro_eei_info19(l_ctr) := 'Band1 Correction Info';


   --4
   l_ctr := l_ctr + 1;

   l_idx := l_ele_new_name.NEXT(l_idx);
   l_main_ele_name(l_ctr)    := l_ele_new_name(l_idx);
   l_main_eei_info19(l_ctr)  := 'Band2 Info';

   l_idx := l_ele_new_name.NEXT(l_idx);
   l_retro_ele_name(l_ctr)   := l_ele_new_name(l_idx);
   l_retro_eei_info19(l_ctr) := 'Band2 Correction Info';


IF p_sch_cal_type <> 'DUALROLLING'
THEN

   --5
   l_ctr := l_ctr + 1;

   l_idx := l_ele_new_name.NEXT(l_idx);
   l_main_ele_name(l_ctr)    := l_ele_new_name(l_idx);
   l_main_eei_info19(l_ctr)  := 'Band3 Info';

   l_idx := l_ele_new_name.NEXT(l_idx);
   l_retro_ele_name(l_ctr)   := l_ele_new_name(l_idx);
   l_retro_eei_info19(l_ctr) := 'Band3 Correction Info';

   --6
   l_ctr := l_ctr + 1;

   l_idx := l_ele_new_name.NEXT(l_idx);
   l_main_ele_name(l_ctr)    := l_ele_new_name(l_idx);
   l_main_eei_info19(l_ctr)  := 'Band4 Info';

   l_idx := l_ele_new_name.NEXT(l_idx);
   l_retro_ele_name(l_ctr)   := l_ele_new_name(l_idx);
   l_retro_eei_info19(l_ctr) := 'Band4 Correction Info';

END IF; -- IF p_sch_cal_type <> 'DUALROLLING'

  -- Added the IF check, as this is created only for DAYS
   IF l_days_hours IS NULL
   THEN
     --7 or 5
     l_ctr := l_ctr + 1;

     l_idx := l_ele_new_name.NEXT(l_idx);
     l_main_ele_name(l_ctr)    := l_ele_new_name(l_idx);
     l_main_eei_info19(l_ctr)  := 'Minimum Pay Info';


     l_idx := l_ele_new_name.NEXT(l_idx);
     l_retro_ele_name(l_ctr)   := l_ele_new_name(l_idx);
     l_retro_eei_info19(l_ctr) := 'Minimum Pay Correction Info';
  END IF ;

   l_idx := l_main_ele_name.FIRST;
   WHILE l_idx IS NOT NULL
   LOOP

     update_ele_retro_info
      (p_main_ele_name  => l_main_ele_name(l_idx)
      ,p_retro_ele_name => l_retro_ele_name(l_idx)
      );

     l_idx := l_main_ele_name.NEXT(l_idx);

   END LOOP; -- l_idx := l_main_ele_name.FIRST;


-- 5 because I'm testing only for dual rolling so 3 and 4 won't exist
--   l_ctr := l_ctr + 1;
-- temporarily after loop as min pay does't have a retro twin yet
--   l_main_ele_name(l_ctr)    := l_ele_new_name(l_ele_new_name.LAST); --it is the last to be added
--   l_main_eei_info19(l_ctr)  := 'Minimum Pay Info';
-- temporarily after loop as min pay does't have a retro twin yet

   -- Update the pay component rate type input value for base element

   IF p_pay_src_pay_component IS NOT NULL THEN

      --
      l_proc_step := 120;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      --
      update_ipval_defval (p_ele_name  => l_main_ele_name(l_main_ele_name.FIRST)
                          ,p_ip_name   => 'Pay Component Rate Type'
                          ,p_def_value => p_pay_src_pay_component
                          );

   END IF; -- End of of pay src comp not null check ...

   l_proc_step := 130;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;


   l_base_element_type_id := get_object_id ('ELE', l_main_ele_name(l_main_ele_name.FIRST));

   l_proc_step := 140;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;

   IF p_abs_ent_sick_leaves IS NULL THEN

     -- Create UDT for Sickness Absence Entitlements

     l_udt_type.user_table_name := l_base_name ||
                                   '_SICKNESS_ABSENCE_ENTITLEMENTS';
     l_udt_type.range_or_match  := 'R'; -- Range
     l_udt_type.user_key_units  := 'N';
     l_udt_type.user_row_title  := NULL;

     -- columns

     l_udt_cols.DELETE;

     -- Get the column names from the Lookup Type 'PQP_GAP_ENTITLED_BANDS'

     l_proc_step := 145;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;


     get_udt_col_info (p_lookup_type       => 'PQP_GAP_ENTITLEMENT_BANDS'
                      ,p_lookup_code       => 'BAND%'
                      ,p_formula_id        => NULL
                      ,p_business_group_id => p_bg_id
                      ,p_legislation_code  => NULL
                      ,p_udt_cols          => l_udt_cols
                      );


     -- rows

     l_udt_rows.DELETE;

     -- Get the row names from the Lookup Type 'PQP_GAP_ENTITLEMENT_ROWS'
     -- and GB_GAP_PERCENTAGE_ROW lookup code

     l_proc_step := 146;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;



     l_display_sequence := 1;
     get_udt_row_info (p_lookup_type       => 'PQP_GAP_ENTITLEMENT_ROWS'
                      ,p_lookup_code       => 'GB_GAP_PERCENTAGE_ROW'
                      ,p_udt_type          => 'R'
                      ,p_display_sequence  => l_display_sequence
                      ,p_business_group_id => NULL
                      ,p_legislation_code  => 'GB'
                      ,p_udt_rows          => l_udt_rows
                      );

     -- Get the row names from the Lookup Type 'PQP_GAP_ENTITLEMENT_ROWS'
     -- and GB_OSP% lookup code

     l_proc_step := 147;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;

     get_udt_row_info
       (p_lookup_type       => 'PQP_GAP_ENTITLEMENT_ROWS'
       ,p_lookup_code       => 'GB_OSP%'
       ,p_udt_type          => 'R'
       ,p_display_sequence  => l_display_sequence
       ,p_business_group_id => NULL
       ,p_legislation_code  => 'GB'
       ,p_udt_rows          => l_udt_rows
       );

    IF p_sch_cal_type = 'DUALROLLING' THEN
    -- insert a LOS range of 0 to 999999
       l_idx := l_udt_rows.LAST;
       l_udt_rows(l_idx+1).row_low_range_or_name  := '0';
       l_udt_rows(l_idx+1).row_high_range         := '999999';
       l_udt_rows(l_idx+1).business_group_id      := p_bg_id;
       l_udt_rows(l_idx+1).legislation_code       := NULL;
       l_udt_rows(l_idx+1).display_sequence       := l_udt_rows(l_idx).display_sequence+1;
    END IF; -- IF p_sch_cal_type = 'DUALROLLING' THEN

    IF p_scheme_type = 'LOCALGOVT' THEN
    -- insert a LOS range of 0 to 999999
       l_idx := l_udt_rows.LAST;
       l_udt_rows(l_idx+1).row_low_range_or_name  := '0';
       l_udt_rows(l_idx+1).row_high_range         := '3';
       l_udt_rows(l_idx+1).business_group_id      := p_bg_id;
       l_udt_rows(l_idx+1).legislation_code       := NULL;
       l_udt_rows(l_idx+1).display_sequence       := l_udt_rows(l_idx).display_sequence+1;

       l_idx := l_udt_rows.LAST;
       l_udt_rows(l_idx+1).row_low_range_or_name  := '4';
       l_udt_rows(l_idx+1).row_high_range         := '11';
       l_udt_rows(l_idx+1).business_group_id      := p_bg_id;
       l_udt_rows(l_idx+1).legislation_code       := NULL;
       l_udt_rows(l_idx+1).display_sequence       := l_udt_rows(l_idx).display_sequence+1;

       l_idx := l_udt_rows.LAST;
       l_udt_rows(l_idx+1).row_low_range_or_name  := '12';
       l_udt_rows(l_idx+1).row_high_range         := '23';
       l_udt_rows(l_idx+1).business_group_id      := p_bg_id;
       l_udt_rows(l_idx+1).legislation_code       := NULL;
       l_udt_rows(l_idx+1).display_sequence       := l_udt_rows(l_idx).display_sequence+1;

       l_idx := l_udt_rows.LAST;
       l_udt_rows(l_idx+1).row_low_range_or_name  := '24';
       l_udt_rows(l_idx+1).row_high_range         := '35';
       l_udt_rows(l_idx+1).business_group_id      := p_bg_id;
       l_udt_rows(l_idx+1).legislation_code       := NULL;
       l_udt_rows(l_idx+1).display_sequence       := l_udt_rows(l_idx).display_sequence+1;

       l_idx := l_udt_rows.LAST;
       l_udt_rows(l_idx+1).row_low_range_or_name  := '36';
       l_udt_rows(l_idx+1).row_high_range         := '59';
       l_udt_rows(l_idx+1).business_group_id      := p_bg_id;
       l_udt_rows(l_idx+1).legislation_code       := NULL;
       l_udt_rows(l_idx+1).display_sequence       := l_udt_rows(l_idx).display_sequence+1;

       l_idx := l_udt_rows.LAST;
       l_udt_rows(l_idx+1).row_low_range_or_name  := '60';
       l_udt_rows(l_idx+1).row_high_range         := '999999';
       l_udt_rows(l_idx+1).business_group_id      := p_bg_id;
       l_udt_rows(l_idx+1).legislation_code       := NULL;
       l_udt_rows(l_idx+1).display_sequence       := l_udt_rows(l_idx).display_sequence+1;

    END IF; -- IF p_scheme_type = ' 'LOCALGOVT' THEN




/*
-- CS Table
--                    Band1     Band2
-- -999999 -999999      100        50
-- 0        999999      182       183

*/

--      l_udt_rows(1).row_low_range_or_name := '-1';
--      l_udt_rows(1).display_sequence      := 1;
--      l_udt_rows(1).row_high_range        := '-1';
--      l_udt_rows(1).business_group_id     := NULL;
--      l_udt_rows(1).legislation_code      := 'GB';

     l_eei_information9 := fnd_number.number_to_canonical
                                  (create_udt (p_udt_type => l_udt_type
                                              ,p_udt_cols => l_udt_cols
                                              ,p_udt_rows => l_udt_rows
                                              )
                                  );


    IF p_sch_cal_type = 'DUALROLLING' THEN

      --Insert four column instances
      --Two for row -99999 -99999 and columns Band1 and Band2 values 100 and 50 respectively
      --Two for row 0 99999 and columsn Band1 and Band2 values 182 and 183 respectively
/*
APPS@hrukps:SQL>desc pay_user_column_instances_pkg
PROCEDURE DELETE_ROW
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 P_ROWID                        VARCHAR2                IN
PROCEDURE INSERT_ROW
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 P_ROWID                        VARCHAR2                IN/OUT
 P_USER_COLUMN_INSTANCE_ID      NUMBER                  IN/OUT
 P_EFFECTIVE_START_DATE         DATE                    IN
 P_EFFECTIVE_END_DATE           DATE                    IN
 P_USER_ROW_ID                  NUMBER                  IN
 P_USER_COLUMN_ID               NUMBER                  IN
 P_BUSINESS_GROUP_ID            NUMBER                  IN
 P_LEGISLATION_CODE             VARCHAR2                IN
 P_LEGISLATION_SUBGROUP         VARCHAR2                IN
 P_VALUE                        VARCHAR2                IN
*/

      INSERT INTO pay_user_column_instances_f
       (user_column_instance_id
       ,effective_start_date
       ,effective_end_date
       ,user_row_id
       ,user_column_id
       ,business_group_id
       ,legislation_code
       ,legislation_subgroup
       ,value
       )
      SELECT
        pay_user_column_instances_s.NEXTVAL
        ,urws.effective_start_date
        ,urws.effective_end_date
        ,urws.user_row_id
        ,ucol.user_column_id
        ,p_bg_id
        ,NULL
        ,NULL
        ,'100' -- -999999 -999999 Band1
       FROM pay_user_columns  ucol
           ,pay_user_rows_f   urws
       WHERE ucol.user_table_id = fnd_number.canonical_to_number(l_eei_information9)
         AND ucol.user_column_name = 'Band1' -- bad bad refer 'PQP_GAP_ENTITLEMENT_BANDS'.'BAND1'
         AND urws.user_table_id = ucol.user_table_id
         AND urws.row_low_range_or_name = '-999999' -- bad bad refer lookup code 'PQP_GAP_ENTITLEMENT_ROWS'.'GB_GAP_PERCENTAGE_ROW'
         AND SYSDATE BETWEEN urws.effective_start_date
                         AND urws.effective_end_date;


      INSERT INTO pay_user_column_instances_f
       (user_column_instance_id
       ,effective_start_date
       ,effective_end_date
       ,user_row_id
       ,user_column_id
       ,business_group_id
       ,legislation_code
       ,legislation_subgroup
       ,value
       )
      SELECT
        pay_user_column_instances_s.NEXTVAL
        ,urws.effective_start_date
        ,urws.effective_end_date
        ,urws.user_row_id
        ,ucol.user_column_id
        ,p_bg_id
        ,NULL
        ,NULL
        ,'50' -- -999999 -999999 Band2
       FROM pay_user_columns  ucol
           ,pay_user_rows_f   urws
       WHERE ucol.user_table_id = fnd_number.canonical_to_number(l_eei_information9)
         AND ucol.user_column_name = 'Band2' -- bad bad refer 'PQP_GAP_ENTITLEMENT_BANDS'.'BAND1'
         AND urws.user_table_id = ucol.user_table_id
         AND urws.row_low_range_or_name = '-999999' -- bad bad refer lookup code 'PQP_GAP_ENTITLEMENT_ROWS'.'GB_GAP_PERCENTAGE_ROW'
         AND SYSDATE BETWEEN urws.effective_start_date
                         AND urws.effective_end_date;



      INSERT INTO pay_user_column_instances_f
       (user_column_instance_id
       ,effective_start_date
       ,effective_end_date
       ,user_row_id
       ,user_column_id
       ,business_group_id
       ,legislation_code
       ,legislation_subgroup
       ,value
       )
      SELECT
        pay_user_column_instances_s.NEXTVAL
        ,urws.effective_start_date
        ,urws.effective_end_date
        ,urws.user_row_id
        ,ucol.user_column_id
        ,p_bg_id
        ,NULL
        ,NULL
        ,'182' -- 0 999999 Band1
       FROM pay_user_columns  ucol
           ,pay_user_rows_f   urws
       WHERE ucol.user_table_id = fnd_number.canonical_to_number(l_eei_information9)
         AND ucol.user_column_name = 'Band1' -- bad bad refer 'PQP_GAP_ENTITLEMENT_BANDS'.'BAND1'
         AND urws.user_table_id = ucol.user_table_id
         AND urws.row_low_range_or_name = '0' -- bad bad refer lookup code 'PQP_GAP_ENTITLEMENT_ROWS'.'GB_GAP_PERCENTAGE_ROW'
         AND SYSDATE BETWEEN urws.effective_start_date
                         AND urws.effective_end_date;



      INSERT INTO pay_user_column_instances_f
       (user_column_instance_id
       ,effective_start_date
       ,effective_end_date
       ,user_row_id
       ,user_column_id
       ,business_group_id
       ,legislation_code
       ,legislation_subgroup
       ,value
       )
      SELECT
        pay_user_column_instances_s.NEXTVAL
        ,urws.effective_start_date
        ,urws.effective_end_date
        ,urws.user_row_id
        ,ucol.user_column_id
        ,p_bg_id
        ,NULL
        ,NULL
        ,'183' -- 0 999999 Band2
       FROM pay_user_columns  ucol
           ,pay_user_rows_f   urws
       WHERE ucol.user_table_id = fnd_number.canonical_to_number(l_eei_information9)
         AND ucol.user_column_name = 'Band2' -- bad bad refer 'PQP_GAP_ENTITLEMENT_BANDS'.'BAND1'
         AND urws.user_table_id = ucol.user_table_id
         AND urws.row_low_range_or_name = '0' -- bad bad refer a variable set in prev section when creating this row
         AND SYSDATE BETWEEN urws.effective_start_date
                         AND urws.effective_end_date;


    END IF; --IF p_sch_cal_type = 'DUALROLLING' THEN create the entitlement values also


    IF p_scheme_type = 'LOCALGOVT' THEN

      --Insert four column instances
      --Two for row -99999 -99999 and columns Band1 and Band2 values 100 and 50 respectively
      --Two for row 0 99999 and columsn Band1 and Band2 values 182 and 183 respectively
/*
APPS@hrukps:SQL>desc pay_user_column_instances_pkg
PROCEDURE DELETE_ROW
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 P_ROWID                        VARCHAR2                IN
PROCEDURE INSERT_ROW
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 P_ROWID                        VARCHAR2                IN/OUT
 P_USER_COLUMN_INSTANCE_ID      NUMBER                  IN/OUT
 P_EFFECTIVE_START_DATE         DATE                    IN
 P_EFFECTIVE_END_DATE           DATE                    IN
 P_USER_ROW_ID                  NUMBER                  IN
 P_USER_COLUMN_ID               NUMBER                  IN
 P_BUSINESS_GROUP_ID            NUMBER                  IN
 P_LEGISLATION_CODE             VARCHAR2                IN
 P_LEGISLATION_SUBGROUP         VARCHAR2                IN
 P_VALUE                        VARCHAR2                IN
*/
create_udt_entry(
	 p_bg_id				=>p_bg_id
	,p_band				=>'Band1'
	,p_entit				=>'100'
	,p_lower		                =>'-999999'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
 	p_bg_id	                        =>p_bg_id
	,p_band				=>'Band2'
	,p_entit				=>'50'
	,p_lower		                =>'-999999'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	 p_bg_id	                        =>p_bg_id
	,p_band				=>'Band1'
	,p_entit				=>'26'
	,p_lower		                =>'0'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );


         create_udt_entry(
	 p_bg_id				=>p_bg_id
	,p_band				=>'Band1'
	,p_entit				=>'26'
	,p_lower		                =>'4'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	  p_bg_id                    	=>p_bg_id
	,p_band				=>'Band2'
	,p_entit				=>'52'
	,p_lower		                =>'4'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	p_bg_id				=>p_bg_id
	,p_band				=>'Band1'
	,p_entit				=>'52'
	,p_lower		                =>'12'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	p_bg_id				=>p_bg_id
	,p_band				=>'Band2'
	,p_entit				=>'52'
	,p_lower		                =>'12'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	p_bg_id				=>p_bg_id
	,p_band				=>'Band1'
	,p_entit				=>'104'
	,p_lower		                =>'24'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	p_bg_id				=>p_bg_id
	,p_band				=>'Band2'
	,p_entit				=>'104'
	,p_lower		                =>'24'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	p_bg_id				=>p_bg_id
	,p_band				=>'Band1'
	,p_entit				=>'130'
	,p_lower		                =>'36'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	p_bg_id				=>p_bg_id
	,p_band				=>'Band2'
	,p_entit				=>'130'
	,p_lower		                =>'36'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	p_bg_id				=>p_bg_id
	,p_band				=>'Band1'
	,p_entit				=>'156'
	,p_lower		                =>'60'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );

    	create_udt_entry(
	p_bg_id				=>p_bg_id
	,p_band				=>'Band2'
	,p_entit				=>'156'
	,p_lower		                =>'60'
	,p_user_tbl_id                    => fnd_number.canonical_to_number(l_eei_information9)
	    );




    END IF; --    IF p_scheme_type = 'LOCALGOVT' THEN



   ELSE

     -- Store the user_table_id for this udt name
     l_eei_information9 := fnd_number.number_to_canonical
                             (p_abs_ent_sick_leaves);

   END IF; -- End if of p_abs_ent_sick_leaves null check ...

   l_proc_step := 150;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;


   l_eei_information10 := NULL;
   IF NVL(p_abs_ent_holidays, 0) <> -1 THEN

     IF p_abs_ent_holidays IS NOT NULL THEN

        -- Store the user_table_id for this udt name
        l_eei_information10 := fnd_number.number_to_canonical
                                 (p_abs_ent_holidays);

     ELSE -- create the udt

       -- Create UDT for Calendar

       l_udt_type.user_table_name := l_base_name ||'_CALENDAR';
       l_udt_type.range_or_match  := 'M'; -- Match
       l_udt_type.user_key_units  := 'T';
       l_udt_type.user_row_title  := NULL;

       -- columns

       l_udt_cols.DELETE;

       -- Get the column names from the Lookup Type 'PQP_GB_OSP_CALENDAR_RULES'

       l_proc_step := 155;
       IF g_debug THEN
         debug(l_proc_name, l_proc_step);
       END IF;


       get_udt_col_info (p_lookup_type       => 'PQP_GB_OSP_CALENDAR_RULES'
                        ,p_lookup_code       => '%'
                        ,p_formula_id        => NULL
                        ,p_business_group_id => NULL
                        ,p_legislation_code  => 'GB'
                        ,p_udt_cols          => l_udt_cols
                        );

       l_udt_rows.DELETE;


       l_eei_information10 := fnd_number.number_to_canonical(
                                create_udt (p_udt_type => l_udt_type
                                           ,p_udt_cols => l_udt_cols
                                           ,p_udt_rows => l_udt_rows
                                           )              );


     END IF; -- End if of p_abs_ent_holidays null check ...

   END IF; -- End if of ent holidays <> -1 check...

   --
   l_proc_step := 160;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;

   --
   l_eei_information18 := p_abs_type_lookup_type;

   IF p_abs_type_lookup_type IS NULL THEN

      -- Create Lookup dynamically
      l_lookup_type    := l_base_name || '_LIST';
      l_lookup_meaning := l_base_name || '_ABSENCE_ATTENDANCE_TYPES';
      create_lookup (p_lookup_type    => l_lookup_type
                    ,p_lookup_meaning => l_lookup_meaning
                    ,p_lookup_values  => p_abs_type_lookup_value
                    );
      l_eei_information18 := l_lookup_type;

      -- Create GAP lookup dynamically
      l_lookup_type    := 'PQP_GAP_ABSENCE_TYPES_LIST';
      l_lookup_meaning := l_lookup_type;
      create_gap_lookup (p_security_group_id  => p_security_group_id
                        ,p_ele_eff_start_date => p_ele_eff_start_date
                        ,p_lookup_type        => l_lookup_type
                        ,p_lookup_meaning     => l_lookup_meaning
                        ,p_lookup_values      => p_abs_type_lookup_value
                        );

   END IF; -- End if of abs type lookup type not null ...


-- LG Create a Lookup with Plan Types
-- that are used to extend the Rolling Period.

  IF p_plan_type_lookup_type IS NULL THEN

      -- Create Lookup dynamically
      l_lookup_type    := l_base_name || '_PLTP';
      l_lookup_meaning := l_lookup_type ;
      create_plan_lookup (p_lookup_type    => l_lookup_type
                         ,p_lookup_meaning => l_lookup_meaning
                         ,p_lookup_values  => p_plan_type_lookup_value
                         ) ;
      l_eei_information24 := l_lookup_type;

  END IF; -- End if of abs type lookup type not null ...




   l_idx := l_main_ele_name.FIRST;
   WHILE l_idx IS NOT NULL
   LOOP

     l_proc_step := 170;

     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
       debug('ELE:'||l_main_ele_name(l_idx));
       debug('l_eei_information22:'||l_eei_information22);
       debug('l_eei_information23:'||l_eei_information23);
     END IF;

     l_eei_element_type_id    := get_object_id ('ELE', l_main_ele_name(l_idx));

  -- Create a row in pay_element_extra_info with all the element information
      pay_element_extra_info_api.create_element_extra_info
        (p_element_type_id            => l_eei_element_type_id
        ,p_information_type           => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
        ,P_EEI_INFORMATION_CATEGORY   => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
        ,p_eei_information1           => fnd_number.number_to_canonical(p_plan_id)
        ,p_eei_information2           => p_plan_description
        ,p_eei_information3           => p_sch_cal_type
        ,p_eei_information4           => p_sch_cal_duration
        ,p_eei_information5           => p_sch_cal_uom
        ,p_eei_information6           => fnd_date.date_to_canonical(p_sch_cal_start_date)
        ,p_eei_information7           => fnd_date.date_to_canonical(p_sch_cal_end_date)
        ,p_eei_information8           => p_abs_days
        ,p_eei_information9           => l_eei_information9
        ,p_eei_information10          => l_eei_information10
        ,p_eei_information11          => p_abs_daily_rate_calc_method
        ,p_eei_information12          => p_abs_daily_rate_calc_period
        ,p_eei_information13          => p_abs_daily_rate_calc_divisor
        ,p_eei_information14          => p_ft_round_config
        ,p_eei_information15          => p_pay_src_pay_component
        ,p_eei_information16          => p_abs_primary_yn
        ,p_eei_information17          => p_abs_working_pattern
        ,p_eei_information18          => l_eei_information18
        ,p_eei_information19          => l_main_eei_info19(l_idx)
        ,p_eei_information20          => l_eei_information20
        ,p_eei_information21          => l_eei_information21
        ,p_eei_information22          => l_eei_information22 -- LG
        ,p_eei_information23          => l_eei_information23 -- LG
        ,p_eei_information24          => l_eei_information24 -- LG
        ,p_eei_information25          => p_pt_round_config
        ,p_eei_information26          => p_abs_overlap_rule
        ,p_eei_information27          => l_eei_information27
        ,p_eei_information28          => l_eei_information28
        ,p_eei_information29          => l_eei_information29
        ,p_eei_information30          => l_eei_information30
        ,p_element_type_extra_info_id => l_eei_info_id
        ,p_object_version_number      => l_ovn_eei
        );


   IF l_retro_ele_name.EXISTS(l_idx) THEN
     l_eei_element_type_id    := get_object_id ('ELE', l_retro_ele_name(l_idx));

     l_proc_step := 180;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;


  -- Create a row in pay_element_extra_info with all the element information
      pay_element_extra_info_api.create_element_extra_info
        (p_element_type_id            => l_eei_element_type_id
        ,p_information_type           => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
        ,P_EEI_INFORMATION_CATEGORY   => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
        ,p_eei_information1           => fnd_number.number_to_canonical(p_plan_id)
        ,p_eei_information2           => p_plan_description
        ,p_eei_information3           => p_sch_cal_type
        ,p_eei_information4           => p_sch_cal_duration
        ,p_eei_information5           => p_sch_cal_uom
        ,p_eei_information6           => fnd_date.date_to_canonical(p_sch_cal_start_date)
        ,p_eei_information7           => fnd_date.date_to_canonical(p_sch_cal_end_date)
        ,p_eei_information8           => p_abs_days
        ,p_eei_information9           => l_eei_information9
        ,p_eei_information10          => l_eei_information10
        ,p_eei_information11          => p_abs_daily_rate_calc_method
        ,p_eei_information12          => p_abs_daily_rate_calc_period
        ,p_eei_information13          => p_abs_daily_rate_calc_divisor
        ,p_eei_information14          => p_ft_round_config
        ,p_eei_information15          => p_pay_src_pay_component
        ,p_eei_information16          => p_abs_primary_yn
        ,p_eei_information17          => p_abs_working_pattern
        ,p_eei_information18          => l_eei_information18
        ,p_eei_information19          => l_retro_eei_info19(l_idx)
        ,p_eei_information20          => l_eei_information20
        ,p_eei_information21          => l_eei_information21
        ,p_eei_information22          => l_eei_information22 -- LG
        ,p_eei_information23          => l_eei_information23 -- LG
        ,p_eei_information24          => l_eei_information24 -- LG
        ,p_eei_information25          => p_pt_round_config
        ,p_eei_information26          => p_abs_overlap_rule
        ,p_eei_information27          => l_eei_information27
        ,p_eei_information28          => l_eei_information28
        ,p_eei_information29          => l_eei_information29
        ,p_eei_information30          => l_eei_information30
        ,p_element_type_extra_info_id => l_eei_info_id
        ,p_object_version_number      => l_ovn_eei
        );

     END IF; -- if retro exists -- min pay testing only

     l_idx := l_main_ele_name.NEXT(l_idx);


   END LOOP; --l_idx := l_main_ele_name.FIRST;


   -- Elements Links are created Here
--   pqp_gb_omp_template.create_element_links (
--                              p_business_group_id    => p_bg_id
--                            , p_effective_start_date => p_ele_eff_start_date
--                            , p_effective_end_date   => p_ele_eff_end_date
--                            , p_legislation_code     => 'GB'
--                            , p_base_name            => p_abs_ele_name
--                            , p_abs_type             => ' OSP '||l_days_hours
--                            ) ;

      pqp_gb_omp_template.create_element_links
        (p_business_group_id    => p_bg_id
        ,p_effective_start_date => p_ele_eff_start_date
        ,p_effective_end_date   => p_ele_eff_end_date
        ,p_template_id => l_template_id
        ) ;

   --  Elements Links are created Here
   -- creates values in pqp_configuration_modules
   -- ,pqp_configuration_types table.
   -- once the lct, ldt are finalized to ship these values this code
   -- will be replaced by a proper ldt.

     create_config_data ;


   IF p_abs_primary_yn = 'Y' THEN
      automate_plan_setup
       (p_pl_id             => p_plan_id
       ,p_business_group_id => p_bg_id
       ,p_element_type_id   => l_base_element_type_id
       ,p_effective_date    => p_ele_eff_start_date
       ,p_base_name         => l_base_name
       );
   END IF;


 ELSE

   hr_utility.set_message(8303, 'PQP_230535_GBORAPAY_NOT_FOUND');
   hr_utility.raise_error;


 END IF; -- IF chk_product_install('Oracle Payroll',g_template_leg_code))

 debug_exit(l_proc_name);

 RETURN l_base_element_type_id;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END create_user_template;
--
--
--==========================================================================
--                             Deletion procedure
--==========================================================================
--
PROCEDURE delete_user_template
           (p_plan_id                      in number
           ,p_business_group_id            in number
           ,p_abs_ele_name                 in varchar2
           ,p_abs_ele_type_id              in number
           ,p_abs_primary_yn               in varchar2
           ,p_security_group_id            in number
           ,p_effective_date               in date
           ) IS
  --
  l_template_id     NUMBER(9);
  l_proc_step       NUMBER(20,10);
  l_proc_name       varchar2(72)      := g_package_name || 'delete_user_template';
  l_eei_info_id     number;
  l_ovn_eei         number;
  l_entudt_id       pay_user_tables.user_table_id%TYPE;
  l_caludt_id       pay_user_tables.user_table_id%TYPE;
  l_lookup_type     fnd_lookup_types_vl.lookup_type%TYPE;
   -- to delete plan types lookup
  l_plan_type_lookup fnd_lookup_types_vl.lookup_type%TYPE;

  l_lookup_code     fnd_lookup_values_vl.lookup_code%TYPE;
  l_exists          VARCHAR2(1);
  l_element_type_id pay_element_types_f.element_type_id%TYPE;

  TYPE t_number IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

  l_lookup_collection t_number;
  l_plan_type_lookup_collection t_number;


  -- Added For Hours

    l_entitlements_uom VARCHAR2(1) ;
    l_daily_rate_uom   pay_element_type_extra_info.eei_information13%TYPE ;
    l_days_hours       VARCHAR2(10) ;
    l_template_name    pay_element_templates.template_name%TYPE ;


   CURSOR csr_get_scheme_type(p_ele_type_id IN NUMBER) IS
   SELECT  pee.eei_information8 entitlements_uom
          ,pee.eei_information11 daily_rate_uom
     FROM pay_element_type_extra_info pee
    WHERE  element_type_id = p_ele_type_id
      AND  information_type = 'PQP_GB_OSP_ABSENCE_PLAN_INFO' ;

  -- Added For Hours


  CURSOR csr_get_ele_type_id (c_template_id number)
  IS
  SELECT element_type_id
    FROM pay_template_core_objects pet
        ,pay_element_types_f       petf
  WHERE  pet.template_id = c_template_id
    AND  petf.element_type_id = pet.core_object_id
    AND  pet.core_object_type = 'ET';

  CURSOR csr_get_eei_info (c_element_type_id number)
  IS
  SELECT element_type_extra_info_id
        ,fnd_number.canonical_to_number(eei_information9) entitlement_udt
        ,fnd_number.canonical_to_number(eei_information10) calendar_udt
        ,eei_information18 lookup_type
	,eei_information24 plan_type_lookup
   FROM pay_element_type_extra_info petei
   WHERE element_type_id = c_element_type_id ;

  CURSOR csr_chk_eei_for_entudt (c_udt_id number)
  IS
  SELECT 'X'
    FROM pay_element_type_extra_info
  WHERE  eei_information1 <> fnd_number.number_to_canonical(p_plan_id)
    AND  eei_information9 = fnd_number.number_to_canonical(c_udt_id)
    AND  information_type = 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
    AND  rownum = 1;

  CURSOR csr_chk_eei_for_caludt (c_udt_id number)
  IS
  SELECT 'X'
    FROM pay_element_type_extra_info
  WHERE  eei_information1 <> fnd_number.number_to_canonical(p_plan_id)
    AND  eei_information10 = fnd_number.number_to_canonical(c_udt_id)
    AND  information_type = 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
    AND  rownum = 1;

  CURSOR csr_chk_eei_for_lkt (c_lookup_type varchar2)
  IS
  SELECT 'X'
    FROM pay_element_type_extra_info
  WHERE  eei_information1 <> fnd_number.number_to_canonical(p_plan_id)
    AND  eei_information18 = c_lookup_type
    AND  information_type = 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
    AND  rownum = 1;


  CURSOR csr_chk_sec_ele (c_te_usrstr_id NUMBER
                         ,p_template_name VARCHAR2
                         ,p_days_hours VARCHAR2
                         ) IS
  SELECT 'X'
  FROM   pay_element_templates       pets
        ,pay_shadow_element_types    pset
        ,pay_template_core_objects   ptco
        ,pay_element_type_extra_info peei
  WHERE  pets.template_id       <> c_te_usrstr_id
    -- For the given user structure
    AND  pets.template_name     = p_template_name -- 'PQP OSP'
    AND  pets.template_type     = 'U'
    AND  pets.business_group_id = p_business_group_id
    AND  pset.template_id       = pets.template_id  -- find the base element
    AND  pset.element_name      = pets.base_name || ' OSP '||p_days_hours||'Absence'
    AND  ptco.template_id       = pset.template_id  -- For the base element
    AND  ptco.shadow_object_id  = pset.element_type_id -- find the core element
    AND  ptco.core_object_type  = 'ET'
    AND  ptco.core_object_id    = peei.element_type_id -- For the core element
    AND  peei.eei_information1  = fnd_number.number_to_canonical(p_plan_id)
    AND  peei.information_type  = 'PQP_GB_OSP_ABSENCE_PLAN_INFO';
    -- find the eei info

  CURSOR csr_get_template_id (p_template_name IN VARCHAR2) is
  SELECT template_id
  FROM   pay_element_templates
  WHERE  base_name         = p_abs_ele_name
    AND  template_name     = p_template_name --'PQP OSP'
    AND  business_group_id = p_business_group_id
    AND  template_type     = 'U';

  -- Cursor to check whether elements are attached to
  -- benefit standard rates

  CURSOR csr_chk_ele_in_ben (c_element_type_id number)
  IS
  SELECT 'X'
    FROM ben_acty_base_rt_f
  WHERE  pl_id             = p_plan_id
    AND  element_type_id   = c_element_type_id
    AND  business_group_id = p_business_group_id;


  -- Cursor to retrieve lookup code for a given
  -- lookup type

  CURSOR csr_get_lookup_code (c_lookup_type varchar2)
  IS
  SELECT lookup_code
    FROM fnd_lookup_values_vl
  WHERE  lookup_type         = c_lookup_type
    AND  security_group_id   = p_security_group_id
    AND  view_application_id = 3;

   --
   --========================================================================
   --                PROCEDURE get_other_lookups
   --========================================================================

   PROCEDURE get_other_lookups (p_business_group_id     in number
                               ,p_lookup_collection    out nocopy t_number
                               ,p_template_name         IN VARCHAR2
                               ,p_days_hours            IN VARCHAR2
                               )
   IS

   -- The original query is split into 2 queries
   -- to avoid Merge joins and make use of Indexes.
   -- There is no effective date check on table pay_element_types_f
   -- as we are interested in data irrespective of date.
   -- Cursor to retrieve lookup type information

     CURSOR csr_get_lookup_type(c_base_name in varchar2)
     IS
     SELECT DISTINCT(pete.eei_information18) lookup_type
       FROM pay_element_type_extra_info pete
           ,pay_element_types_f         petf
        --   ,pay_element_templates       pet
     WHERE  pete.element_type_id   = petf.element_type_id
       AND  pete.information_type  = 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
       AND  pete.eei_information16 = 'Y'
       AND  petf.element_name      = c_base_name || ' OSP '||p_days_hours||'Absence'
                          -- pet.base_name || ' OSP '||p_days_hours||'Absence'
       AND  petf.business_group_id = p_business_group_id
       --AND  pet.template_name      = p_template_name -- 'PQP OSP'
       --AND  pet.template_type      = 'U'
       --AND  pet.business_group_id  = p_business_group_id;
       ;

      CURSOR csr_template_names IS
       SELECT pet.base_name
         FROM pay_element_templates pet
        WHERE pet.template_name      = p_template_name
          AND pet.template_type      = 'U'
          AND pet.business_group_id  = p_business_group_id ;

     l_lookup_collection t_number;
     l_number            NUMBER;
     l_lookup_code       fnd_lookup_values_vl.lookup_code%TYPE;
     l_lookup_type       fnd_lookup_types_vl.lookup_type%TYPE;
     l_proc_step         NUMBER(20,10);
     l_proc_name         VARCHAR2(72) := g_package_name || 'get_other_lookups';
     l_base_name         pay_element_templates.base_name%TYPE ;

   --
   BEGIN

   --
     debug('Entering '||l_proc_name, 10);

    -- get the template base names
     OPEN csr_template_names ;
     LOOP
       FETCH csr_template_names INTO l_base_name ;
       EXIT WHEN csr_template_names%NOTFOUND ;

     -- Get the lookup type information

       OPEN csr_get_lookup_type(c_base_name => l_base_name);
       LOOP

         FETCH csr_get_lookup_type INTO l_lookup_type;
         EXIT WHEN csr_get_lookup_type%NOTFOUND;

         -- Get the lookup code for this lookup type

         l_proc_step := 20;
         IF g_debug THEN
           debug(l_proc_name, l_proc_step);
         END IF;


         OPEN csr_get_lookup_code(l_lookup_type);
         LOOP

           FETCH csr_get_lookup_code INTO l_lookup_code;
           EXIT WHEN csr_get_lookup_code%NOTFOUND;

           -- Check whether this lookup code is already added to
           -- the collection

           l_number := fnd_number.canonical_to_number(l_lookup_code);

           IF NOT l_lookup_collection.EXISTS(l_number) THEN

              l_lookup_collection(l_number) := l_number;

           END IF; -- End if of lookup collection exists check ...

         END LOOP;
         CLOSE csr_get_lookup_code;

       END LOOP;
       CLOSE csr_get_lookup_type;
     END LOOP ;
     CLOSE csr_template_names;

     p_lookup_collection := l_lookup_collection;

     debug('Leaving '||l_proc_name, 30);

     -- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       debug('Entering excep:'||l_proc_name, 35);
       p_lookup_collection.delete;
       raise;

   --
   END get_other_lookups;
   --


   --
   --========================================================================
   --                PROCEDURE delete_lookup
   --========================================================================

   PROCEDURE delete_lookup (p_lookup_type         in   varchar2
                           ,p_security_group_id   in   number
                           ,p_view_application_id in   number
                           ,p_lookup_collection   in   t_number
			   ,p_delete_gap_entry    in boolean default true )
   IS

   --

     CURSOR csr_get_lkt_info
     IS
     SELECT 'X'
       FROM fnd_lookup_types_vl
     WHERE  lookup_type         = p_lookup_type
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = p_view_application_id;

     CURSOR csr_get_lkv_info
     IS
     SELECT lookup_code
       FROM fnd_lookup_values_vl
     WHERE  lookup_type = p_lookup_type
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = p_view_application_id;

     l_proc_step     NUMBER(20,10);
     l_proc_name     VARCHAR2(72) := g_package_name || 'delete_lookup';
     l_exists        VARCHAR2(1);
     l_lookup_code   fnd_lookup_values_vl.lookup_code%TYPE;

   BEGIN
     --
     debug ('Entering '||l_proc_name, 10);
     --

     debug('Security Group' || to_char(p_security_group_id),
     15);
     debug('Lookup Type' || p_lookup_type, 16);

     OPEN csr_get_lkt_info;
     FETCH csr_get_lkt_info into l_exists;

     IF csr_get_lkt_info%FOUND THEN

        -- Get Lookup Value Info
        l_proc_step := 20;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        OPEN csr_get_lkv_info;
        LOOP
          FETCH csr_get_lkv_info INTO l_lookup_code;
          EXIT WHEN csr_get_lkv_info%NOTFOUND;

          -- Check whether this lookup code has to be deleted
          -- from PQP_GAP_ABSENCE_TYPES_LIST lookup type

          l_proc_step := 25;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;

-- Added p_delete_gap_entry cehck, to use the same function to delete
-- any lookup.
       IF p_delete_gap_entry THEN

          IF NOT p_lookup_collection.EXISTS(fnd_number.canonical_to_number(
                                               l_lookup_code)) THEN
             fnd_lookup_values_pkg.delete_row
               (x_lookup_type         => 'PQP_GAP_ABSENCE_TYPES_LIST'
               ,x_security_group_id   => p_security_group_id
               ,x_view_application_id => p_view_application_id
               ,x_lookup_code         => l_lookup_code
               );

          END IF; -- End if of absence type exists in this collection check...

        END IF ; -- IF p_delete_gap_entry THEN

          -- Delete the lookup code

          l_proc_step := 30;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;



          fnd_lookup_values_pkg.delete_row
            (x_lookup_type         => p_lookup_type
            ,x_security_group_id   => p_security_group_id
            ,x_view_application_id => p_view_application_id
            ,x_lookup_code         => l_lookup_code
            );
        END LOOP;
        CLOSE csr_get_lkv_info;

        -- Delete the lookup type
        l_proc_step := 40;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        fnd_lookup_types_pkg.delete_row
          (x_lookup_type         => p_lookup_type
          ,x_security_group_id   => p_security_group_id
          ,x_view_application_id => p_view_application_id
          );

     END IF; -- End if of row found check ...
     CLOSE csr_get_lkt_info;

     --
     debug('Leaving '||l_proc_name, 50);
     --

   END delete_lookup;
   --

   --
   --========================================================================
   --                PROCEDURE delete_udt
   --========================================================================

   PROCEDURE delete_udt (p_udt_id in    number)
   IS

   --

     CURSOR csr_get_usr_table_id
     IS
     SELECT rowid
       FROM pay_user_tables
     WHERE  user_table_id     = p_udt_id
       AND  business_group_id = p_business_group_id;

     CURSOR csr_get_usr_col_id
     IS
     SELECT user_column_id
       FROM pay_user_columns
     WHERE  user_table_id = p_udt_id;

     CURSOR csr_get_usr_row_id
     IS
     SELECT user_row_id
       FROM pay_user_rows_f
     WHERE  user_table_id = p_udt_id;

     --
     l_proc_step          NUMBER(20,10);
     l_proc_name          VARCHAR(72) := g_package_name || 'delete_udt';
     l_rowid              rowid;
     l_usr_row_id         pay_user_rows.user_row_id%TYPE;
     l_usr_col_id         pay_user_columns.user_column_id%TYPE;
     --
   --
   BEGIN

     --
     debug ('Entering '||l_proc_name, 10);
     --

     -- Get user_table_id from pay_user_tables
     OPEN csr_get_usr_table_id;
     FETCH csr_get_usr_table_id INTO l_rowid;

     IF csr_get_usr_table_id%FOUND THEN

        -- Get user_column_id from pay_user_columns
        l_proc_step := 20;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        OPEN csr_get_usr_col_id;
        LOOP
          FETCH csr_get_usr_col_id INTO l_usr_col_id;
          EXIT WHEN csr_get_usr_col_id%NOTFOUND;

            -- Delete pay_user_column_instances_f for this column_id
            l_proc_step := 30;
            IF g_debug THEN
              debug(l_proc_name, l_proc_step);
            END IF;


            DELETE pay_user_column_instances_f
            WHERE  user_column_id = l_usr_col_id;

        END LOOP;
        CLOSE csr_get_usr_col_id;

        -- Delete pay_user_columns for this table_id
        l_proc_step := 40;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        DELETE pay_user_columns
        WHERE  user_table_id = p_udt_id;

        OPEN csr_get_usr_row_id;
        LOOP
          FETCH csr_get_usr_row_id INTO l_usr_row_id;
          EXIT WHEN csr_get_usr_row_id%NOTFOUND;

            -- Delete pay_user_rows_f for this table id
            l_proc_step := 50;
            IF g_debug THEN
              debug(l_proc_name, l_proc_step);
            END IF;


            pay_user_rows_pkg.check_delete_row
              (p_user_row_id           => l_usr_row_id
              ,p_validation_start_date => NULL
              ,p_dt_delete_mode        => 'ZAP'
              );

            DELETE pay_user_rows_f
            WHERE  user_row_id = l_usr_row_id;

        END LOOP;
        CLOSE csr_get_usr_row_id;


        -- Delete pay_user_tables for this table id
        l_proc_step := 60;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;

        pay_user_tables_pkg.delete_row
          (p_rowid         => l_rowid
          ,p_user_table_id => p_udt_id
          );


     END IF; -- End of of user_table found check ...
     CLOSE csr_get_usr_table_id;

     --
     debug ('Leaving '||l_proc_name, 70);
     --
   --
   END delete_udt;
   --

--
BEGIN -- delete_user_template

      -- for Multi Messages
   hr_multi_message.enable_message_list;

   --
   g_debug := hr_utility.debug_enabled;
   IF g_debug THEN
     debug_enter(l_proc_name);
   END IF;
   --

--- Added for Hours


   FOR csr_get_scheme_type_rec IN csr_get_scheme_type
                                (
                                p_ele_type_id => p_abs_ele_type_id
                                )
   LOOP
       l_entitlements_uom := csr_get_scheme_type_rec.entitlements_uom ;
       l_daily_rate_uom   := csr_get_scheme_type_rec.daily_rate_uom ;
   END LOOP ;

   IF l_entitlements_uom = 'H' or l_daily_rate_uom = 'H' THEN
       l_template_name := 'PQP OSP HOURS' ;
       l_days_hours    := 'Hours ';
   ELSE
       l_template_name := 'PQP OSP' ;
       l_days_hours    := NULL ;
   END IF ;


--- Added for Hours




   FOR csr_get_template_id_rec IN csr_get_template_id
                                   (
                                    p_template_name => l_template_name
                                   )
   LOOP
       l_template_id := csr_get_template_id_rec.template_id;
   END LOOP;

   l_proc_step := 20;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;


   -- Check whether this is primary element

   IF p_abs_primary_yn = 'Y' THEN

      -- Check whether there are any secondary elements
      l_proc_step := 40;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;


      OPEN csr_chk_sec_ele (l_template_id
                           ,l_template_name
                           ,l_days_hours);
      FETCH csr_chk_sec_ele INTO l_exists;

      IF csr_chk_sec_ele%FOUND THEN

         -- Raise error
         CLOSE csr_chk_sec_ele;
         hr_utility.set_message (8303,'PQP_230607_OSP_SEC_ELE_EXISTS');
         hr_utility.raise_error;

      END IF; -- End if of sec element check ...
      CLOSE csr_chk_sec_ele;

   END IF; -- End if of abs primary yn check ...


--

  IF p_abs_primary_yn = 'Y'
  THEN
    del_automated_plan_setup_data
      (p_pl_id                        => p_plan_id
      ,p_business_group_id            => p_business_group_id
      ,p_effective_date               => p_effective_date
      ,p_base_name                    => p_abs_ele_name
      );
  END IF;

--


   -- Get Element type Id's from template core object

   OPEN csr_get_ele_type_id (l_template_id);
   LOOP

      FETCH csr_get_ele_type_id INTO l_element_type_id;
      EXIT WHEN csr_get_ele_type_id%NOTFOUND;

        -- Check whether elements are attached to benefits
        -- standard rate formula before deleting them

        l_proc_step := 25;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        OPEN csr_chk_ele_in_ben (l_element_type_id);
        FETCH csr_chk_ele_in_ben INTO l_exists;

        IF csr_chk_ele_in_ben%FOUND THEN

            -- Raise Error
           Close csr_chk_ele_in_ben;
           hr_utility.set_message (800,'PER_74880_CHILD_RECORD');
           hr_utility.set_message_token('TYPE','Standard Rates, Table: BEN_ACTY_BASE_RT_F');
           hr_utility.raise_error;

        END IF; -- End if of element in ben check ...
        CLOSE csr_chk_ele_in_ben;

        -- Get Element extra info id for this element type id

        OPEN csr_get_eei_info (l_element_type_id);
        FETCH csr_get_eei_info INTO l_eei_info_id
                                   ,l_entudt_id
                                   ,l_caludt_id
                                   ,l_lookup_type
				   ,l_plan_type_lookup ;
        IF csr_get_eei_info%FOUND -- if an EIT exists only then delete else ignore
        THEN

          -- Delete the EEI row
          l_proc_step := 50;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
            debug('l_element_type_id:'||l_element_type_id);
            debug('l_eei_info_id:'||l_eei_info_id);
          END IF;



          pay_element_extra_info_api.delete_element_extra_info
                                  (p_validate                    => FALSE
                                  ,p_element_type_extra_info_id  => l_eei_info_id
                                  ,p_object_version_number       => l_ovn_eei);
        END IF;
        CLOSE csr_get_eei_info;

    END LOOP;
    CLOSE csr_get_ele_type_id;

    -- Delete Ent UDT

    IF l_entudt_id IS NOT NULL AND
       p_abs_primary_yn = 'Y'
    THEN

       OPEN csr_chk_eei_for_entudt (l_entudt_id);
       FETCH csr_chk_eei_for_entudt INTO l_exists;

       IF csr_chk_eei_for_entudt%NOTFOUND THEN

          -- Delete UDT

          l_proc_step := 60;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;


          delete_udt (p_udt_id  => l_entudt_id);

       END IF; -- End if of eei row found check...
       CLOSE csr_chk_eei_for_entudt;

   END IF; -- End if of ent udt name not null check ...

   -- Delete Cal UDT

   IF l_caludt_id IS NOT NULL AND
      p_abs_primary_yn = 'Y'
   THEN

       OPEN csr_chk_eei_for_caludt (l_caludt_id);
       FETCH csr_chk_eei_for_caludt INTO l_exists;

       IF csr_chk_eei_for_caludt%NOTFOUND THEN

          -- Delete UDT

          l_proc_step := 70;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;


          delete_udt (p_udt_id  => l_caludt_id);

       END IF; -- End if of eei row found check...
       CLOSE csr_chk_eei_for_caludt;

   END IF; -- End if of cal udt name not null check ...


    -- Delete Lookup Type

    IF l_lookup_type IS NOT NULL AND
       p_abs_primary_yn = 'Y'
    THEN

       OPEN csr_chk_eei_for_lkt (l_lookup_type);
       FETCH csr_chk_eei_for_lkt INTO l_exists;

       IF csr_chk_eei_for_lkt%NOTFOUND THEN

          -- Get Other Lookup Information

          l_proc_step := 75;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;


          get_other_lookups (p_business_group_id => p_business_group_id
                            ,p_lookup_collection => l_lookup_collection
                            ,p_template_name     => l_template_name
                            ,p_days_hours        => l_days_hours
                            );

          -- Delete Lookup Type

          l_proc_step := 80;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;


          delete_lookup (p_lookup_type         => l_lookup_type
                        ,p_security_group_id   => p_security_group_id
                        ,p_view_application_id => 3
                        ,p_lookup_collection   => l_lookup_collection
                        );
-- Delete the lookup that contains the plan types to be extended
       IF l_plan_type_lookup IS NOT NULL THEN
          l_proc_step := 81;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;
          delete_lookup (p_lookup_type         => l_plan_type_lookup
                        ,p_security_group_id   => p_security_group_id
                        ,p_view_application_id => 3
                        ,p_lookup_collection   => l_plan_type_lookup_collection
			,p_delete_gap_entry    => FALSE
                        );
       END IF;


          -- Check whether PQP_GAP_ABSENCE_TYPES_LIST lookup type
          -- has atleast one lookup code
           -- Check whether PQP_GAP_ABSENCE_TYPES_LIST lookup type
          -- has atleast one lookup code
          -- Commented as a workaround.
          --Need to add the logic to check if the absence type is attached
          -- with other plans.If not dlete it else leave it as it is.

         /* OPEN csr_get_lookup_code('PQP_GAP_ABSENCE_TYPES_LIST');
          FETCH csr_get_lookup_code INTO l_lookup_code;

          IF csr_get_lookup_code%FOUND THEN

             -- Delete this lookup type
             l_proc_step := 85;
             IF g_debug THEN
               debug(l_proc_name, l_proc_step);
             END IF;


             fnd_lookup_types_pkg.delete_row
                       (x_lookup_type         => 'PQP_GAP_ABSENCE_TYPES_LIST'
                       ,x_security_group_id   => p_security_group_id
                       ,x_view_application_id => 3
                       );

          END IF; -- End if of lookup code check ...
          CLOSE csr_get_lookup_code;
         */
       END IF; -- End if of eei row found check...
       CLOSE csr_chk_eei_for_lkt;

   END IF; -- End of of udt name not null check ...

   l_proc_step := 90;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;



   ---- Delete Element Links Before Deleting the Template
--         pqp_gb_omp_template.delete_element_links
--                     ( p_business_group_id    => p_business_group_id
--                      ,p_effective_start_date => p_effective_date
--                      ,p_effective_end_date   => p_effective_date
--                      ,p_base_name            => p_abs_ele_name
--                      ,p_abs_type             => ' OSP '||l_days_hours );

      pqp_gb_omp_template.delete_element_links
        (p_business_group_id    => p_business_group_id
        ,p_effective_start_date => p_effective_date
        ,p_effective_end_date   => p_effective_date
        ,p_template_id          => l_template_id
        ) ;

   ---- Delete Links


   pay_element_template_api.delete_user_structure
     (p_validate                =>   false
     ,p_drop_formula_packages   =>   true
     ,p_template_id             =>   l_template_id);
   --

   IF g_debug THEN
     debug_exit(l_proc_name);
   END IF;

   --
   EXCEPTION
      WHEN hr_multi_message.error_message_exist THEN

         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
        debug (   ' Leaving:'
                                  || l_proc_name, 40);
      WHEN OTHERS
      THEN

         --
         -- When Multiple Message Detection is enabled catch
         -- any Application specific or other unexpected
         -- exceptions.  Adding appropriate details to the
         -- Multiple Message List.  Otherwise re-raise the
         -- error.
         --
         IF hr_multi_message.unexpected_error_add (l_proc_name)
         THEN
            debug (   ' Leaving:'
                                     || l_proc_name, 50);
            RAISE;
         END IF;

END delete_user_template;
--

   --======================================================================
   --                     PROCEDURE create_gap_lookup
   --======================================================================
   PROCEDURE create_gap_lookup (p_security_group_id  IN NUMBER
                               ,p_ele_eff_start_date IN DATE
                               ,p_lookup_type        IN VARCHAR2
                               ,p_lookup_meaning     IN VARCHAR2
                               ,p_lookup_values      IN t_abs_types
                               ) IS
   --

     CURSOR csr_chk_uniq_type
     IS
     SELECT 'X'
       FROM fnd_lookup_types_vl
     WHERE  lookup_type         = p_lookup_type
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     CURSOR csr_chk_uniq_meaning
     IS
     SELECT 'X'
       FROM fnd_lookup_types_vl
     WHERE  meaning             = p_lookup_meaning
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     CURSOR csr_chk_uniq_value (c_lookup_code varchar2)
     IS
     SELECT 'X'
       FROM fnd_lookup_values_vl
     WHERE  lookup_type         = p_lookup_type
       AND  lookup_code         = c_lookup_code
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     CURSOR csr_chk_uniq_value_meaning (c_lookup_meaning varchar2)
     IS
     SELECT 'X'
       FROM fnd_lookup_values_vl
     WHERE  lookup_type         = p_lookup_type
       AND  meaning             = c_lookup_meaning
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     l_proc_step      NUMBER(20,10);
     l_proc_name      VARCHAR2(72) := g_package_name || 'create_gap_lookup';
     l_exists         VARCHAR2(1);
     l_rowid          fnd_lookup_types_vl.row_id%type;
     l_user_id        number := fnd_global.user_id;
     l_login_id       number := fnd_global.login_id;
     i                number ;
   --
   BEGIN
     --
     debug('Entering '||l_proc_name, 10);
     --

     -- Check lookup type exists
     OPEN csr_chk_uniq_type;
     FETCH csr_chk_uniq_type INTO l_exists;

     IF csr_chk_uniq_type%NOTFOUND THEN

        l_proc_step := 20;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        -- Check unique lookup type meaning
        OPEN csr_chk_uniq_meaning;
        FETCH csr_chk_uniq_meaning INTO l_exists;

        IF csr_chk_uniq_meaning%FOUND THEN

           -- Raise error
           CLOSE csr_chk_uniq_meaning;
           hr_utility.set_message(0, 'QC-DUPLICATE TYPE MEANING');
           hr_utility.raise_error;

        END IF; -- End if of unique lookup type meaning check ...
        CLOSE csr_chk_uniq_meaning;

        -- Create Lookup type
        l_proc_step := 30;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        fnd_lookup_types_pkg.insert_row
           (
            x_rowid               => l_rowid
           ,x_lookup_type         => p_lookup_type
           ,x_security_group_id   => p_security_group_id
           ,x_view_application_id => 3
           ,x_application_id      => 800
           ,x_customization_level => 'U'
           ,x_meaning             => p_lookup_meaning
           ,x_description         => NULL
           ,x_creation_date       => SYSDATE
           ,x_created_by          => l_user_id
           ,x_last_update_date    => SYSDATE
           ,x_last_updated_by     => l_user_id
           ,x_last_update_login   => l_login_id
          );

     END IF; -- End if of lookup type exists check ...
     CLOSE csr_chk_uniq_type;

     l_proc_step := 40;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;

     IF p_lookup_values.count > 0 THEN

        i := p_lookup_values.FIRST;
        WHILE i IS NOT NULL
          LOOP

            l_proc_step := 50;
            IF g_debug THEN
              debug(l_proc_name, l_proc_step);
            END IF;

            -- Check whether this lookup code already exists

            OPEN csr_chk_uniq_value (fnd_number.number_to_canonical(
                                          p_lookup_values(i).abs_type_id));
            FETCH csr_chk_uniq_value INTO l_exists;

            IF csr_chk_uniq_value%NOTFOUND THEN

               l_proc_step := 60;
               IF g_debug THEN
                 debug(l_proc_name, l_proc_step);
               END IF;

               -- Check whether the lookup code meaning is unique
               OPEN csr_chk_uniq_value_meaning (p_lookup_values(i).abs_type_name);
               FETCH csr_chk_uniq_value_meaning INTO l_exists;

               IF csr_chk_uniq_value_meaning%FOUND THEN

                  -- Raise error
                  CLOSE csr_chk_uniq_value_meaning;
                  hr_utility.set_message(0, 'QC-DUPLICATE MEANING');
                  hr_utility.raise_error;

               END IF; -- End if of lookup code meaning check ...
               CLOSE csr_chk_uniq_value_meaning;

               l_proc_step := 70;
               IF g_debug THEN
                 debug(l_proc_name, l_proc_step);
               END IF;


               fnd_lookup_values_pkg.insert_row
                (
                 x_rowid               => l_rowid
                ,x_lookup_type         => p_lookup_type
                ,x_security_group_id   => p_security_group_id
                ,x_view_application_id => 3
                ,x_lookup_code         => fnd_number.number_to_canonical(
                                            p_lookup_values(i).abs_type_id)
                ,x_tag                 => NULL
                ,x_attribute_category  => NULL
                ,x_attribute1          => NULL
                ,x_attribute2          => NULL
                ,x_attribute3          => NULL
                ,x_attribute4          => NULL
                ,x_attribute5          => NULL
                ,x_attribute6          => NULL
                ,x_attribute7          => NULL
                ,x_attribute8          => NULL
                ,x_attribute9          => NULL
                ,x_attribute10         => NULL
                ,x_attribute11         => NULL
                ,x_attribute12         => NULL
                ,x_attribute13         => NULL
                ,x_attribute14         => NULL
                ,x_attribute15         => NULL
                ,x_enabled_flag        => 'Y'
                ,x_start_date_active   => p_ele_eff_start_date
                ,x_end_date_active     => NULL
                ,x_territory_code      => NULL
                ,x_meaning             => p_lookup_values(i).abs_type_name
                ,x_description         => NULL
                ,x_creation_date       => SYSDATE
                ,x_created_by          => l_user_id
                ,x_last_update_date    => SYSDATE
                ,x_last_updated_by     => l_user_id
                ,x_last_update_login   => l_login_id
                );

            END IF; -- End if of lookup code check ...
            CLOSE csr_chk_uniq_value;

            i := p_lookup_values.NEXT(i);

        END LOOP;

     END IF; -- End if of p_lookup_values check ...

    --
    debug_exit(l_proc_name);
   END create_gap_lookup;


END pqp_gb_osp_template;

/
