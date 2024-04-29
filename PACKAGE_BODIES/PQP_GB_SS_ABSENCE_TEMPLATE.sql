--------------------------------------------------------
--  DDL for Package Body PQP_GB_SS_ABSENCE_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_SS_ABSENCE_TEMPLATE" AS
--  $Header: pqpgbabd.pkb 120.1 2005/09/30 05:38:23 rrazdan noship $
--
-- Define global Variables / Cursors
-- **********************************
--
  g_proc_name varchar2(31) := 'pqp_gb_ss_absence_template.' ;
-- Cursor to fill the absence type table from lookup
--
cursor g_c_get_lookupdata
(P_LOOKUP_TYPE fnd_lookup_values_vl.lookup_type%TYPE
,P_EFFECTIVE_START_DATE fnd_lookup_values_vl.start_date_active%TYPE
)
IS
select lookup_code abs_type_id,meaning abs_type_name
from fnd_lookup_values_vl
where lookup_type = P_LOOKUP_TYPE
  and enabled_flag = 'Y'
  and P_EFFECTIVE_START_DATE BETWEEN
      nvl(start_date_active,P_EFFECTIVE_START_DATE)
  AND nvl(end_date_active,P_EFFECTIVE_START_DATE);

--
-- Procedure to compile the formulas including the
-- BEN formulas created and compiled only once for
-- the primary base name
--
procedure compile_formulas
(P_ELEMENT_TYPE_ID   IN NUMBER
,P_ABS_PRIMARY_YN    IN VARCHAR2
,P_EFF_START_DATE    IN DATE
,P_BASE_NAME         IN VARCHAR2
,P_ABSENCE_TYPE      IN VARCHAR2
,P_BG_ID             IN NUMBER
,P_REQUEST_ID       OUT NOCOPY NUMBER
)
IS
--
-- Cursor to get the formula details necessary to compile
--
CURSOR c_get_formula_info(p_element_type_id NUMBER)
IS
SELECT
fra.formula_id,
fra.formula_name,
fty.formula_type_id,
fty.formula_type_name
FROM
ff_formulas_f fra,
ff_formula_types fty,
pay_status_processing_rules_f spr
WHERE fty.formula_type_id = fra.formula_type_id
  AND fra.formula_id = spr.formula_id
  AND spr.assignment_status_type_id IS NULL
  AND spr.element_type_id = p_element_type_id;

--
-- Cursor to get the BEN formula details necessary to compile
--
CURSOR c_get_ben_formula_info(p_formula_id NUMBER)
IS
SELECT
fra.formula_id,
fra.formula_name,
fty.formula_type_id,
fty.formula_type_name
FROM
ff_formulas_f fra,
ff_formula_types fty
WHERE fty.formula_type_id = fra.formula_type_id
  AND fra.formula_id = p_formula_id;

l_ff_id         ff_formulas_f.formula_id%TYPE;
l_ftype_id      ff_formula_types.formula_type_id%TYPE;
l_ff_name       ff_formulas_f.formula_name%TYPE;
l_ftype_name    ff_formula_types.formula_type_name%TYPE;
l_request_id  number;
l_ben_formulas pqp_gb_gap_ben_formulas.t_formulas;
l_error_code number;
l_err_msg VARCHAR2(100);
BEGIN
  -- Query formula info (ie. the formula attached to this
  -- element's Standard status proc rule.
  --
  OPEN c_get_formula_info(p_element_type_id);
  FETCH c_get_formula_info INTO l_ff_id
                               ,l_ff_name
                               ,l_ftype_id
                               ,l_ftype_name;
  CLOSE c_get_formula_info;
  hr_utility.trace('FF Name :'||l_ff_name);

  --
  -- Submitt the request to compile the formula
  --
  l_request_id := fnd_request.submit_request
                   (application => 'FF'
                   ,program     => 'SINGLECOMPILE'
                   ,argument1   => l_ftype_name --'Oracle Payroll' -- formula type
                   ,argument2   => l_ff_name);   -- formula name

  p_request_id := l_request_id;
  hr_utility.trace('Request Id :'||p_request_id);

  --hr_utility.trace('P_ABS_PRIMARY_YN :'||P_ABS_PRIMARY_YN);
  --
  -- Compile the additional Ben Formulas here only for the Primary Base Name
  --
  --IF upper(P_ABS_PRIMARY_YN) = 'Y' THEN
    --hr_utility.trace('Entered the If Stmt');
    ----
    ---- Create the BEN formulas
    ----
   --pqp_gb_gap_ben_formulas.create_ben_formulas
    --(p_business_group_id            => p_bg_id
    --,p_effective_date               => P_EFF_START_DATE
    --,p_absence_pay_plan_category    => P_ABSENCE_TYPE
    --,p_base_name                    => UPPER(P_BASE_NAME)
    --,p_formulas                     => l_ben_formulas
    --,p_error_code                   => l_error_code
    --,p_error_message                => l_err_msg
    --);
--
    --hr_utility.trace('BEN FF Count :'||l_ben_formulas.count);
    ----
    ---- Loop to compile all the BEN formulas
    ----
    --IF l_ben_formulas.COUNT > 0
    --THEN
      --FOR i IN l_ben_formulas.FIRST..l_ben_formulas.LAST
      --LOOP
        --hr_utility.trace('l_ben_formulas(i): '||l_ben_formulas(i));
        --OPEN c_get_ben_formula_info(l_ben_formulas(i));
        --FETCH c_get_ben_formula_info INTO l_ff_id
                               --,l_ff_name
                               --,l_ftype_id
                               --,l_ftype_name;
        --CLOSE c_get_ben_formula_info;
        --hr_utility.trace('FF Name :'||l_ff_name);
        --hr_utility.trace('FT Name :'||l_ftype_name);
        ----
        ---- Submitt request to compile the formula
        ----
        --l_request_id := fnd_request.submit_request
                        --(application => 'FF'
                        --,program     => 'SINGLECOMPILE'
                        --,argument1   => l_ftype_name --'Oracle Payroll' -- formula type
                        --,argument2   => l_ff_name);   -- formula name
        --hr_utility.trace('Request Id :'||l_request_id);
      --END LOOP;
    --END IF;
  --END IF;
-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.trace('Entering exception when others ');
       p_request_id      := NULL;
       raise;


end compile_formulas;

--
-- Function to get the Security Group Id
--
Function get_security_grp_id
(P_BUSINESS_GROUP_ID IN per_business_groups.business_group_id%TYPE
)
RETURN per_business_groups.security_group_id%TYPE
IS

--
-- Cursor to get the Security Group Id
--
CURSOR c_get_security_grp_id
IS
select
security_group_id
from per_business_groups
where business_group_id = P_BUSINESS_GROUP_ID;

l_security_grp_id per_business_groups.security_group_id%TYPE;
BEGIN

  OPEN c_get_security_grp_id;
  FETCH c_get_security_grp_id INTO l_security_grp_id;
  CLOSE c_get_security_grp_id;
  RETURN l_security_grp_id;
END get_security_grp_id;

--
-- Procedure called from SS forms to create/ update an OMP template
--
Procedure Create_omp_template
(P_PLAN_ID                      IN NUMBER
,P_PLAN_DESCRIPTION             IN VARCHAR2
,P_ABSE_DAYS_DEF                IN VARCHAR2
,P_MATERNITY_ABSE_ENT_UDT       IN NUMBER
,P_HOLIDAYS_UDT                 IN NUMBER
,P_DAILY_RATE_CALC_METHOD       IN VARCHAR2
,P_DAILY_RATE_CALC_PERIOD       IN VARCHAR2
,P_DAILY_RATE_CALC_DIVISOR      IN NUMBER
,P_WORKING_PATTERN              IN VARCHAR2
,P_LOS_CALC                     IN VARCHAR2
,P_LOS_CALC_UOM                 IN VARCHAR2
,P_LOS_CALC_DURATION            IN VARCHAR2
,P_AVG_EARNINGS_DURATION        IN VARCHAR2
,P_AVG_EARNINGS_UOM             IN VARCHAR2
,P_AVG_EARNINGS_BALANCE         IN VARCHAR2
,P_PRI_ELE_NAME                 IN VARCHAR2
,P_PRI_ELE_REPORTING_NAME       IN VARCHAR2
,P_PRI_ELE_DESCRIPTION          IN VARCHAR2
,P_PRI_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_ABSE_PRIMARY_YN              IN VARCHAR2
,P_PAY_ELE_REPORTING_NAME       IN VARCHAR2
,P_PAY_ELE_DESCRIPTION          IN VARCHAR2
,P_PAY_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_PAY_SRC_PAY_COMPONENT        IN VARCHAR2
,P_BAND1_ELE_BASE_NAME          IN VARCHAR2
,P_BAND2_ELE_BASE_NAME          IN VARCHAR2
,P_BAND3_ELE_BASE_NAME          IN VARCHAR2
,P_BAND4_ELE_BASE_NAME          IN VARCHAR2
,P_EFFECTIVE_START_DATE         IN DATE
,P_EFFECTIVE_END_DATE           IN DATE
,P_ABSE_TYPE_LOOKUP_TYPE        IN VARCHAR2
,P_ABSE_TYPE_LOOKUP_VALUE       IN pqp_gb_osp_template.t_abs_types
,P_ELEMENT_TYPE_ID              OUT NOCOPY NUMBER
,P_REQUEST_ID                   OUT NOCOPY NUMBER
,P_SECURITY_GROUP_ID            IN NUMBER
,P_BG_ID                        IN NUMBER
)
IS

-- Table to pass as param to the create_osp_template proc.
l_lookup_table pqp_gb_osp_template.t_abs_types;

l_element_type_id pay_element_types_f.element_type_id%TYPE;
l_sec_grp_id per_business_groups.security_group_id%TYPE;
i number;
l_proc_name                VARCHAR2 (80)
                                    :=    g_proc_name
                                       || 'create_omp_template';
BEGIN

   -- for Multi Messages
   hr_multi_message.enable_message_list;

  hr_utility.trace('Entering my proc........');
  hr_utility.trace('P_ABSE_TYPE_LOOKUP_TYPE :' || P_ABSE_TYPE_LOOKUP_TYPE);

  --
  -- If the Absence type is null
  -- then we create a new absence scheme
  --
  IF P_ABSE_TYPE_LOOKUP_TYPE IS NULL THEN
    --
    -- Fill the Absence types table.
    --
    l_lookup_table := P_ABSE_TYPE_LOOKUP_VALUE;
  ELSE
   i := 0;
   FOR r_lookup IN g_c_get_lookupdata
   (P_LOOKUP_TYPE          => P_ABSE_TYPE_LOOKUP_TYPE
   -- Changed canonical_to_date to displaydate_to_date as the format passed
   -- not in canonical format.
--   ,P_EFFECTIVE_START_DATE => fnd_date.displaydate_to_date(P_EFFECTIVE_START_DATE)
   ,P_EFFECTIVE_START_DATE => P_EFFECTIVE_START_DATE
   )
   LOOP
     l_lookup_table(i).abs_type_id:=r_lookup.abs_type_id;
     l_lookup_table(i).abs_type_name:=r_lookup.abs_type_name;
     hr_utility.trace('Abs Type Name :'||l_lookup_table(i).abs_type_name);
     i := i + 1;
   END LOOP;
  END IF;
  l_sec_grp_id := get_security_grp_id(p_bg_id);
--  l_sec_grp_id := FND_PROFILE.VALUE('SECURITY_GROUP_ID');
  hr_utility.trace('l_sec_grp_id :' || l_sec_grp_id);
  hr_utility.trace('Calling the create_user_template from my proc...');

  l_element_type_id := pqp_gb_omp_template.create_user_template
           (p_plan_id                       => P_PLAN_ID
           ,p_plan_description              => P_PLAN_DESCRIPTION
           ,p_abse_days_def                 => P_ABSE_DAYS_DEF
           ,p_maternity_abse_ent_udt        => P_MATERNITY_ABSE_ENT_UDT
           ,p_holidays_udt                  => P_HOLIDAYS_UDT
           ,p_daily_rate_calc_method        => P_DAILY_RATE_CALC_METHOD
           ,p_daily_rate_calc_period        => P_DAILY_RATE_CALC_PERIOD
           ,p_daily_rate_calc_divisor       => P_DAILY_RATE_CALC_DIVISOR
           ,p_working_pattern               => P_WORKING_PATTERN
           ,p_los_calc                      => P_LOS_CALC
           ,p_los_calc_uom                  => P_LOS_CALC_UOM
           ,p_los_calc_duration             => P_LOS_CALC_DURATION
           ,p_avg_earnings_duration         => P_AVG_EARNINGS_DURATION
           ,p_avg_earnings_uom              => P_AVG_EARNINGS_UOM
           ,p_avg_earnings_balance          => P_AVG_EARNINGS_BALANCE
           ,p_pri_ele_name                  => P_PRI_ELE_NAME
           ,p_pri_ele_reporting_name        => P_PRI_ELE_REPORTING_NAME
           ,p_pri_ele_description           => P_PRI_ELE_DESCRIPTION
           ,p_pri_ele_processing_priority   => P_PRI_ELE_PROCESSING_PRIORITY
           ,p_abse_primary_yn               => P_ABSE_PRIMARY_YN
           ,p_pay_ele_reporting_name        => P_PRI_ELE_REPORTING_NAME
           ,p_pay_ele_description           => P_PRI_ELE_DESCRIPTION
  -- Pay Element Reporting Name and Description are changed to pass same as
  -- Absence Element Reporting Name and Description.
           ,p_pay_ele_processing_priority   => P_PAY_ELE_PROCESSING_PRIORITY
           ,p_pay_src_pay_component         => P_PAY_SRC_PAY_COMPONENT
           ,p_band1_ele_base_name           => P_BAND1_ELE_BASE_NAME
           ,p_band2_ele_base_name           => P_BAND2_ELE_BASE_NAME
           ,p_band3_ele_base_name           => P_BAND3_ELE_BASE_NAME
           ,p_band4_ele_base_name           => P_BAND4_ELE_BASE_NAME
           ,p_effective_start_date          => P_EFFECTIVE_START_DATE
           ,p_effective_end_date            => P_EFFECTIVE_END_DATE
           ,p_abse_type_lookup_type         => P_ABSE_TYPE_LOOKUP_TYPE
           ,p_abse_type_lookup_value        => l_lookup_table
           ,p_security_group_id             => l_sec_grp_id --FND_PROFILE.VALUE('SECURITY_GROUP_ID')
           ,p_bg_id                         => P_BG_ID
           );

  p_element_type_id := l_element_type_id;
  hr_utility.trace('Ele Type Id :'||p_element_type_id);

  --
  -- Compile and create(BEN) all the Formulas
  --
  compile_formulas
   (P_ELEMENT_TYPE_ID => L_ELEMENT_TYPE_ID
   ,P_ABS_PRIMARY_YN  => P_ABSE_PRIMARY_YN
   ,P_EFF_START_DATE  => P_EFFECTIVE_START_DATE
   ,P_BASE_NAME       => P_PRI_ELE_NAME
   ,P_ABSENCE_TYPE    => 'MATERNITY'
   ,P_BG_ID           => P_BG_ID
   ,P_REQUEST_ID      => P_REQUEST_ID
   );

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
   /* WHEN OTHERS THEN
       hr_utility.trace('Entering exception when others ');
       p_element_type_id := NULL;
       p_request_id      := NULL;
       raise;*/
       WHEN hr_multi_message.error_message_exist
      THEN
         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
         p_element_type_id := NULL;
         p_request_id      := NULL;
        hr_utility.set_location (   ' Leaving:'
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
	    p_element_type_id := NULL;
            p_request_id      := NULL;
            hr_utility.set_location (   ' Leaving:'
                                     || l_proc_name, 50);
            RAISE;
         END IF;

END Create_omp_template;


--
-- Procedure to create/update an OSP template
--
Procedure Create_osp_template
(P_PLAN_ID                      IN NUMBER
,P_PLAN_DESCRIPTION             IN VARCHAR2
,P_SCH_CAL_TYPE                 IN VARCHAR2
,P_SCH_CAL_DURATION             IN NUMBER
,P_SCH_CAL_UOM                  IN VARCHAR2
--,P_SCH_CAL_START_DATE           IN VARCHAR2
,P_SCH_CAL_START_DATE           IN DATE
--,P_SCH_CAL_END_DATE             IN VARCHAR2
,P_SCH_CAL_END_DATE             IN DATE
,P_ABS_DAYS                     IN VARCHAR2
,P_ABS_ENT_SICK_LEAVES          IN NUMBER
,P_ABS_ENT_HOLIDAYS             IN NUMBER
,P_ABS_DAILY_RATE_CALC_METHOD   IN VARCHAR2
,P_ABS_DAILY_RATE_CALC_PERIOD   IN VARCHAR2
,P_ABS_DAILY_RATE_CALC_DIVISOR  IN NUMBER
,P_ABS_WORKING_PATTERN          IN VARCHAR2
,P_ABS_OVERLAP_RULE             IN VARCHAR2
,P_ABS_ELE_NAME                 IN VARCHAR2
,P_ABS_ELE_REPORTING_NAME       IN VARCHAR2
,P_ABS_ELE_DESCRIPTION          IN VARCHAR2
,P_ABS_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_ABS_PRIMARY_YN               IN VARCHAR2
,P_PAY_ELE_REPORTING_NAME       IN VARCHAR2
,P_PAY_ELE_DESCRIPTION          IN VARCHAR2
,P_PAY_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_PAY_SRC_PAY_COMPONENT        IN VARCHAR2
,P_BND1_ELE_SUB_NAME            IN VARCHAR2
,P_BND2_ELE_SUB_NAME            IN VARCHAR2
,P_BND3_ELE_SUB_NAME            IN VARCHAR2
,P_BND4_ELE_SUB_NAME            IN VARCHAR2
--,P_ELE_EFF_START_DATE           IN VARCHAR2
,P_ELE_EFF_START_DATE           IN DATE
--,P_ELE_EFF_END_DATE             IN VARCHAR2
,P_ELE_EFF_END_DATE             IN DATE
,P_ABS_TYPE_LOOKUP_TYPE         IN VARCHAR2
,P_ABS_TYPE_LOOKUP_VALUE        IN pqp_gb_osp_template.t_abs_types
,P_ELEMENT_TYPE_ID              OUT NOCOPY NUMBER
,P_REQUEST_ID                   OUT NOCOPY NUMBER
,P_SECURITY_GROUP_ID            IN NUMBER
,P_BG_ID                        IN NUMBER
,P_PLAN_TYPE_LOOKUP_TYPE        IN VARCHAR2 --LG
,P_PLAN_TYPE_LOOKUP_VALUE       IN pqp_gb_osp_template.t_plan_types --LG
,P_ENABLE_ENT_PRORATION         IN VARCHAR2 DEFAULT NULL --LG
,P_SCHEME_TYPE                       IN VARCHAR2   DEFAULT NULL -- LG
,P_ABS_SCHEDULE_WP              IN VARCHAR2   DEFAULT NULL -- LG
,P_DUAL_ROLLING_DURATION     IN NUMBER   DEFAULT NULL -- LG
,P_DUAL_ROLLING_UOM              IN VARCHAR2   DEFAULT NULL -- LG
,P_FT_ROUND_CONFIG              IN VARCHAR2 DEFAULT NULL
,P_PT_ROUND_CONFIG              IN VARCHAR2 DEFAULT NULL
)
IS


-- Table to pass as param to the create_osp_template proc.
l_lookup_table pqp_gb_osp_template.t_abs_types;
l_lookup_table_plan_typ pqp_gb_osp_template.t_plan_types;

--
-- Ref cursor to execute the statement that comes as param
--
TYPE ref_csr_type IS REF CURSOR;
c_cursor ref_csr_type;

l_element_type_id      pay_element_types_f.element_type_id%TYPE;
l_abs_type_lookup_type varchar2(100);
l_sch_cal_start_date   VARCHAR2(11);
l_sch_cal_end_date     VARCHAR2(11);
l_select               VARCHAR2(100);
l_sec_grp_id           per_business_groups.security_group_id%TYPE;
l_proc_name            VARCHAR2(61) := g_proc_name ||
                                       'Create_osp_template' ;
i number;
BEGIN

   -- for Multi Messages
   hr_multi_message.enable_message_list;


  hr_utility.trace('Entering :'||l_proc_name);
  hr_utility.trace('P_ABS_TYPE_LOOKUP_TYPE :' || P_ABS_TYPE_LOOKUP_TYPE);
  hr_utility.trace('P_SCH_CAL_START_DATE : '||P_SCH_CAL_START_DATE);
  hr_utility.trace('Enable Proration : '||P_ENABLE_ENT_PRORATION);
  hr_utility.trace('ABS_SHEDWP : '||P_ABS_SCHEDULE_WP);
  hr_utility.trace('P_FT_ROUND_CONFIG : '||P_FT_ROUND_CONFIG);
  hr_utility.trace('P_PT_ROUND_CONFIG : '||P_PT_ROUND_CONFIG);



  --
  -- If the Absence type is null
  -- then we create a new absence scheme
  --
   IF P_SCH_CAL_START_DATE IS NOT NULL THEN

      l_sch_cal_start_date := p_sch_cal_start_date ;
      l_sch_cal_end_date := p_sch_cal_end_date ;

--    l_select := 'select '|| P_SCH_CAL_START_DATE
--                    || ' from dual';
    --hr_utility.trace(l_select);
    --
    -- Prepare the Calendar start date string
    --
--    open c_cursor for l_select;
--    fetch c_cursor into l_sch_cal_start_date;
--    close c_cursor;

    hr_utility.trace('1_SCH_CAL_START_DATE : '||l_SCH_CAL_START_DATE);

    hr_utility.trace('P_SCH_CAL_END_DATE : '||P_SCH_CAL_END_DATE);
--    l_select := 'select '|| P_SCH_CAL_END_DATE
--                    || ' from dual';
    --hr_utility.trace(l_select);
    --
    -- Prepare the Calendar end date string
    --
--    open c_cursor for l_select;
--    fetch c_cursor into l_sch_cal_end_date;
--    close c_cursor;

    hr_utility.trace('1_SCH_CAL_END_DATE : '||l_SCH_CAL_END_DATE);
   ELSE
     l_sch_cal_start_date := NULL ;
     l_sch_cal_end_date   := NULL ;
   END IF;

  IF P_ABS_TYPE_LOOKUP_TYPE IS NULL THEN
   IF P_SCH_CAL_START_DATE IS NULL THEN
    l_sch_cal_start_date := NULL;
    l_sch_cal_end_date := NULL;
   END IF;
    --
    -- Fill the Absence types table.
    --
    l_lookup_table := P_ABS_TYPE_LOOKUP_VALUE;
  ELSE
    i := 0;
    FOR r_lookup IN g_c_get_lookupdata
    (P_LOOKUP_TYPE          => P_ABS_TYPE_LOOKUP_TYPE
   -- Changed canonical_to_date to displaydate_to_date as the format passed
   -- not in canonical format.
--    ,P_EFFECTIVE_START_DATE => fnd_date.displaydate_to_date(P_ELE_EFF_START_DATE)
    ,P_EFFECTIVE_START_DATE => P_ELE_EFF_START_DATE

    )
    LOOP
      l_lookup_table(i).abs_type_id:=r_lookup.abs_type_id;
      l_lookup_table(i).abs_type_name:=r_lookup.abs_type_name;
      hr_utility.trace('Abs Type Name :'||l_lookup_table(i).abs_type_name);
      i := i + 1;
    END LOOP;
  END IF;
  l_sec_grp_id := get_security_grp_id(p_bg_id);


-- Populating lookup for plan type l_lookup_table_plan_typ ---LG

  IF P_PLAN_TYPE_LOOKUP_TYPE IS NOT NULL THEN
    i := 0;
    FOR r_lookup IN g_c_get_lookupdata
    (P_LOOKUP_TYPE          => P_PLAN_TYPE_LOOKUP_TYPE
    ,P_EFFECTIVE_START_DATE => P_ELE_EFF_START_DATE
    )
    LOOP
      l_lookup_table_plan_typ(i).plan_type_id:=r_lookup.abs_type_id;
      l_lookup_table_plan_typ(i).name:=r_lookup.abs_type_name;
      hr_utility.trace('Abs Type Name :'||l_lookup_table_plan_typ(i).name);
      i := i + 1;
    END LOOP;
  ELSE
      l_lookup_table_plan_typ := P_PLAN_TYPE_LOOKUP_VALUE;
       hr_utility.trace('In Else: assigning l_lookup_table_plan_typ value');

  END IF;

--End of Populating lookup for plan type l_lookup_table_plan_typ ---LG


--  l_sec_grp_id := FND_PROFILE.VALUE('SECURITY_GROUP_ID');
  hr_utility.trace('l_sec_grp_id :' || l_sec_grp_id);
  hr_utility.trace('Calling the create_user_template from my proc...');


  l_element_type_id := pqp_gb_osp_template.create_user_template
           (p_plan_id                           => P_PLAN_ID
           ,p_plan_description                  => P_PLAN_DESCRIPTION
           ,p_sch_cal_type                      => P_SCH_CAL_TYPE
           ,p_sch_cal_duration                  => P_SCH_CAL_DURATION
           ,p_sch_cal_uom                       => P_SCH_CAL_UOM
           ,p_sch_cal_start_date                => l_SCH_CAL_START_DATE
           ,p_sch_cal_end_date                  => l_SCH_CAL_END_DATE
           ,p_abs_days                          => P_ABS_DAYS
           ,p_abs_ent_sick_leaves               => P_ABS_ENT_SICK_LEAVES
           ,p_abs_ent_holidays                  => P_ABS_ENT_HOLIDAYS
           ,p_abs_daily_rate_calc_method        => P_ABS_DAILY_RATE_CALC_METHOD
           ,p_abs_daily_rate_calc_period        => P_ABS_DAILY_RATE_CALC_PERIOD
           ,p_abs_daily_rate_calc_divisor       => P_ABS_DAILY_RATE_CALC_DIVISOR
           ,p_abs_working_pattern               => P_ABS_WORKING_PATTERN
           ,p_abs_overlap_rule                  => P_ABS_OVERLAP_RULE
           ,p_abs_ele_name                      => P_ABS_ELE_NAME
           ,p_abs_ele_reporting_name            => P_ABS_ELE_REPORTING_NAME
           ,p_abs_ele_description               => P_ABS_ELE_DESCRIPTION
           ,p_abs_ele_processing_priority       => P_ABS_ELE_PROCESSING_PRIORITY
           ,p_abs_primary_yn                    => P_ABS_PRIMARY_YN
           ,p_pay_ele_reporting_name            => P_ABS_ELE_REPORTING_NAME
           ,p_pay_ele_description               => P_ABS_ELE_DESCRIPTION
  -- Pay Element Reporting Name and Description are changed to pass same as
  -- Absence Element Reporting Name and Description.
           ,p_pay_ele_processing_priority       => P_PAY_ELE_PROCESSING_PRIORITY
           ,p_pay_src_pay_component             => P_PAY_SRC_PAY_COMPONENT
           ,p_bnd1_ele_sub_name                 => P_BND1_ELE_SUB_NAME
           ,p_bnd2_ele_sub_name                 => P_BND2_ELE_SUB_NAME
           ,p_bnd3_ele_sub_name                 => P_BND3_ELE_SUB_NAME
           ,p_bnd4_ele_sub_name                 => P_BND4_ELE_SUB_NAME
           ,p_ele_eff_start_date                => P_ELE_EFF_START_DATE
           ,p_ele_eff_end_date                  => P_ELE_EFF_END_DATE
           ,p_abs_type_lookup_type              => P_ABS_TYPE_LOOKUP_TYPE
           ,p_abs_type_lookup_value             => l_lookup_table
           ,p_security_group_id                 => l_sec_grp_id
           ,p_bg_id                             => p_bg_id
           ,p_plan_type_lookup_type             => P_PLAN_TYPE_LOOKUP_TYPE-- LG
           ,p_plan_type_lookup_value            => l_lookup_table_plan_typ   -- LG
    	   ,p_enable_ent_proration              => P_ENABLE_ENT_PRORATION -- LG
	   ,p_scheme_type                        => P_SCHEME_TYPE -- LG
    	   ,p_abs_schedule_wp                   => P_ABS_SCHEDULE_WP -- LG
    	   ,p_dual_rolling_duration                   => P_DUAL_ROLLING_DURATION -- LG
    	   ,p_dual_rolling_UOM                  => P_DUAL_ROLLING_UOM -- LG
	   ,p_ft_round_config                   => P_FT_ROUND_CONFIG
	   ,p_pt_round_config                   => P_PT_ROUND_CONFIG
           );

  p_element_type_id := l_element_type_id;
  hr_utility.trace('Ele Type Id :'||p_element_type_id);

  --
  -- Compile and create(BEN) all the Formulas
  --
  compile_formulas
  (P_ELEMENT_TYPE_ID => L_ELEMENT_TYPE_ID
  ,P_ABS_PRIMARY_YN  => P_ABS_PRIMARY_YN
  ,P_EFF_START_DATE  => P_ELE_EFF_START_DATE
  ,P_BASE_NAME       => P_ABS_ELE_NAME
  ,P_ABSENCE_TYPE    => 'SICKNESS'
  ,P_BG_ID           => P_BG_ID
  ,P_REQUEST_ID      => P_REQUEST_ID
  );

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
/*    WHEN OTHERS THEN
       hr_utility.trace('Entering exception when others ');
       p_element_type_id := NULL;
       p_request_id      := NULL;
       raise; */
    WHEN hr_multi_message.error_message_exist THEN
         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
         p_element_type_id := NULL;
         p_request_id      := NULL;
        hr_utility.set_location (   ' Leaving:'
                                  || l_proc_name, 40);
    WHEN OTHERS THEN
         --
         -- When Multiple Message Detection is enabled catch
         -- any Application specific or other unexpected
         -- exceptions.  Adding appropriate details to the
         -- Multiple Message List.  Otherwise re-raise the
         -- error.
         --
         IF hr_multi_message.unexpected_error_add (l_proc_name)
         THEN
	    p_element_type_id := NULL;
            p_request_id      := NULL;
            hr_utility.set_location (   ' Leaving:'
                                     || l_proc_name, 50);
            RAISE;
         END IF;

  END Create_osp_template;


Procedure Create_unp_template
(P_PLAN_ID                      IN NUMBER
,P_PLAN_DESCRIPTION             IN VARCHAR2
,P_ABS_DAYS                     IN VARCHAR2
,P_ABS_ENT_SICK_LEAVES          IN NUMBER
,P_ABS_ENT_HOLIDAYS             IN NUMBER
,P_ABS_DAILY_RATE_CALC_METHOD   IN VARCHAR2
,P_ABS_DAILY_RATE_CALC_PERIOD   IN VARCHAR2
,P_ABS_DAILY_RATE_CALC_DIVISOR  IN NUMBER
,P_ABS_WORKING_PATTERN          IN VARCHAR2
,P_ABS_ELE_NAME                 IN VARCHAR2
,P_ABS_ELE_REPORTING_NAME       IN VARCHAR2
,P_ABS_ELE_DESCRIPTION          IN VARCHAR2
,P_ABS_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_ABS_PRIMARY_YN               IN VARCHAR2
,P_PAY_ELE_REPORTING_NAME       IN VARCHAR2
,P_PAY_ELE_DESCRIPTION          IN VARCHAR2
,P_PAY_ELE_PROCESSING_PRIORITY  IN NUMBER
,P_PAY_SRC_PAY_COMPONENT        IN VARCHAR2
,P_ELE_EFF_START_DATE           IN DATE
,P_ELE_EFF_END_DATE             IN DATE
,P_ABS_TYPE_LOOKUP_TYPE         IN VARCHAR2
,P_ABS_TYPE_LOOKUP_VALUE        IN pqp_gb_osp_template.t_abs_types
,P_ELEMENT_TYPE_ID              OUT NOCOPY NUMBER
,P_REQUEST_ID                   OUT NOCOPY NUMBER
,P_SECURITY_GROUP_ID            IN NUMBER
,P_BG_ID                        IN NUMBER
,P_ABS_SCHEDULE_WP              IN VARCHAR2   DEFAULT NULL -- LG
)
IS


-- Table to pass as param to the create_osp_template proc.
l_lookup_table pqp_gb_osp_template.t_abs_types;

--
-- Ref cursor to execute the statement that comes as param
--
TYPE ref_csr_type IS REF CURSOR;
c_cursor ref_csr_type;

l_element_type_id      pay_element_types_f.element_type_id%TYPE;
l_abs_type_lookup_type varchar2(100);
l_select               VARCHAR2(100);
l_sec_grp_id           per_business_groups.security_group_id%TYPE;
l_proc_name            VARCHAR2(61) := g_proc_name ||
                                       'Create_unp_template' ;
i number;
BEGIN

   -- for Multi Messages
   hr_multi_message.enable_message_list;


  hr_utility.trace('Entering :'||l_proc_name);
  hr_utility.trace('P_ABS_TYPE_LOOKUP_TYPE :' || P_ABS_TYPE_LOOKUP_TYPE);
 hr_utility.trace('ABS_SHEDWP : '||P_ABS_SCHEDULE_WP);

 IF P_ABS_TYPE_LOOKUP_TYPE IS NULL THEN

    -- Fill the Absence types table.
    --
    l_lookup_table := P_ABS_TYPE_LOOKUP_VALUE;

  ELSE
    i := 0;
    FOR r_lookup IN g_c_get_lookupdata
    (P_LOOKUP_TYPE          => P_ABS_TYPE_LOOKUP_TYPE
    ,P_EFFECTIVE_START_DATE => P_ELE_EFF_START_DATE
    )
    LOOP
      l_lookup_table(i).abs_type_id:=r_lookup.abs_type_id;
      l_lookup_table(i).abs_type_name:=r_lookup.abs_type_name;
      hr_utility.trace('Abs Type Name :'||l_lookup_table(i).abs_type_name);
      i := i + 1;
    END LOOP;
  END IF;
  l_sec_grp_id := get_security_grp_id(p_bg_id);


--  l_sec_grp_id := FND_PROFILE.VALUE('SECURITY_GROUP_ID');
  hr_utility.trace('l_sec_grp_id :' || l_sec_grp_id);
  hr_utility.trace('Calling the create_user_template from my proc...');


  l_element_type_id := pqp_gb_unpaid_template.create_user_template
           (p_plan_id                           => P_PLAN_ID
           ,p_plan_description                  => P_PLAN_DESCRIPTION
           ,p_abs_days                          => P_ABS_DAYS
           ,p_abs_ent_sick_leaves               => P_ABS_ENT_SICK_LEAVES
           ,p_abs_ent_holidays                  => P_ABS_ENT_HOLIDAYS
           ,p_abs_daily_rate_calc_method        => P_ABS_DAILY_RATE_CALC_METHOD
           ,p_abs_daily_rate_calc_period        => P_ABS_DAILY_RATE_CALC_PERIOD
           ,p_abs_daily_rate_calc_divisor       => P_ABS_DAILY_RATE_CALC_DIVISOR
           ,p_abs_working_pattern               => P_ABS_WORKING_PATTERN
           ,p_abs_ele_name                      => P_ABS_ELE_NAME
           ,p_abs_ele_reporting_name            => P_ABS_ELE_REPORTING_NAME
           ,p_abs_ele_description               => P_ABS_ELE_DESCRIPTION
           ,p_abs_ele_processing_priority       => P_ABS_ELE_PROCESSING_PRIORITY
           ,p_abs_primary_yn                    => P_ABS_PRIMARY_YN
           ,p_pay_ele_reporting_name            => P_ABS_ELE_REPORTING_NAME
           ,p_pay_ele_description               => P_ABS_ELE_DESCRIPTION
           ,p_pay_ele_processing_priority       => P_PAY_ELE_PROCESSING_PRIORITY
           ,p_pay_src_pay_component             => P_PAY_SRC_PAY_COMPONENT
           ,p_ele_eff_start_date                => P_ELE_EFF_START_DATE
           ,p_ele_eff_end_date                  => P_ELE_EFF_END_DATE
           ,p_abs_type_lookup_type              => P_ABS_TYPE_LOOKUP_TYPE
           ,p_abs_type_lookup_value             => l_lookup_table
           ,p_security_group_id                 => l_sec_grp_id
           ,p_bg_id                             => p_bg_id
           );

  p_element_type_id := l_element_type_id;
  hr_utility.trace('Ele Type Id :'||p_element_type_id);

  --
  -- Compile and create(BEN) all the Formulas
  --
  compile_formulas
  (P_ELEMENT_TYPE_ID => L_ELEMENT_TYPE_ID
  ,P_ABS_PRIMARY_YN  => P_ABS_PRIMARY_YN
  ,P_EFF_START_DATE  => P_ELE_EFF_START_DATE
  ,P_BASE_NAME       => P_ABS_ELE_NAME
  ,P_ABSENCE_TYPE    => 'SICKNESS'
  ,P_BG_ID           => P_BG_ID
  ,P_REQUEST_ID      => P_REQUEST_ID
  );

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN hr_multi_message.error_message_exist THEN
         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
         p_element_type_id := NULL;
         p_request_id      := NULL;
        hr_utility.set_location (   ' Leaving:'
                                  || l_proc_name, 40);
    WHEN OTHERS THEN
         --
         -- When Multiple Message Detection is enabled catch
         -- any Application specific or other unexpected
         -- exceptions.  Adding appropriate details to the
         -- Multiple Message List.  Otherwise re-raise the
         -- error.
         --
         IF hr_multi_message.unexpected_error_add (l_proc_name)
         THEN
	    p_element_type_id := NULL;
            p_request_id      := NULL;
            hr_utility.set_location (   ' Leaving:'
                                     || l_proc_name, 50);
            RAISE;
         END IF;

  END create_unp_template;



End pqp_gb_ss_absence_template;

/
