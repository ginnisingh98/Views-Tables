--------------------------------------------------------
--  DDL for Package Body HR_SCH_ELIG_OBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SCH_ELIG_OBJ_PKG" AS
  -- $Header: peschobj.pkb 120.2 2005/08/24 02:20:35 lsilveir noship $
  --
  g_module CONSTANT VARCHAR2(80) := 'per.plsql.hr_sch_elig_obj_pkg.';
  --
  -----------------------------------------------------------------------------
  ---------------------------< create_sch_elig_obj >---------------------------
  -----------------------------------------------------------------------------
  --
  FUNCTION create_sch_elig_obj(p_subscription_guid IN RAW
                              ,p_event             IN OUT NOCOPY wf_event_t
                              ) RETURN VARCHAR2 IS
    -- In Params
    l_bg_id          NUMBER;
    l_sch_id         NUMBER;
    l_sch_start_date DATE;
    l_obj_start_date DATE;
    -- Out Params
    l_elig_obj_id    NUMBER;
    l_eff_start_dt   DATE;
    l_eff_end_dt     DATE;
    l_ovn            NUMBER;
    l_ret_mode       VARCHAR2(10);
    -- General
    l_routine       VARCHAR2(80);
    --
  BEGIN
    --
    l_routine := 'create_sch_elig_obj';
    hr_utility.trace('Entering '||g_module||l_routine);
    --
    l_bg_id := hr_general.get_business_group_id();
    l_sch_id := wf_event.getvalueforparameter ('SCHEDULE_ID',p_event.parameter_list);
    l_sch_start_date := TO_DATE(wf_event.getvalueforparameter ('SCHEDULE_START_DATE',p_event.parameter_list),'MM/DD/RRRR');
    l_obj_start_date := hr_api.g_sot;
    --
    hr_utility.trace('BGId '||l_bg_id||' SchId '||l_sch_id);
    --
    IF l_bg_id IS NOT NULL AND l_sch_id IS NOT NULL THEN
      -- Create Eligibility Object
      ben_elig_obj_api.create_elig_obj
        (p_business_group_id     => l_bg_id
        ,p_table_name            => 'CAC_SR_SCHEDULES_VL'
        ,p_column_name           => 'SCHEDULE_ID'
        ,p_column_value          => l_sch_id
        ,p_effective_date        => l_obj_start_date
        ,p_elig_obj_id           => l_elig_obj_id
        ,p_effective_start_date  => l_eff_start_dt
        ,p_effective_end_date    => l_eff_end_dt
        ,p_object_version_number => l_ovn
        );
      l_ret_mode :=  'SUCCESS';
      --
      hr_utility.trace('EligObjId '||l_elig_obj_id);
      --
    ELSE
      wf_core.context (g_module,
                       l_routine,
                       p_event.event_name,
                       p_subscription_guid
                      );
      wf_event.seterrorinfo (p_event, 'WARNING');
      l_ret_mode :=  'WARNING';
    END IF;
    --
    hr_utility.trace('Leaving '||g_module||l_routine);
    --
    RETURN l_ret_mode;
    --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace('Leaving in Error '||g_module||l_routine);
      wf_core.context ('hr_sch_elig_obj_pkg',
                       'create_sch_elig_obj',
                       p_event.event_name,
                       p_subscription_guid
                      );
      wf_event.seterrorinfo (p_event, 'ERROR');
      RETURN 'ERROR';
  END create_sch_elig_obj;
  --
  -----------------------------------------------------------------------------
  ---------------------------< delete_sch_elig_obj >---------------------------
  -----------------------------------------------------------------------------
  --
  FUNCTION delete_sch_elig_obj(p_subscription_guid IN RAW
                              ,p_event             IN OUT NOCOPY wf_event_t
                              ) RETURN VARCHAR2 IS
    -- In Params
    l_bg_id          NUMBER;
    l_sch_id         NUMBER;
    l_sch_start_date DATE;
    l_mode           VARCHAR2(10);
    l_elig_obj_id    NUMBER;
    l_ovn            NUMBER;
    -- Out Params
    l_eff_start_dt DATE;
    l_eff_end_dt   DATE;
    l_ret_mode     VARCHAR2(10);
    -- General
    l_routine       VARCHAR2(80);
    --
    CURSOR c_elig_obj (cp_bg_id  IN NUMBER
                      ,cp_sch_id IN NUMBER
                      ,cp_eff_dt IN DATE
                      ) IS
      SELECT elig_obj_id
            ,object_version_number
      FROM ben_elig_obj_f
      WHERE business_group_id = cp_bg_id
      AND table_name = 'CAC_SR_SCHEDULES_VL'
      AND column_name = 'SCHEDULE_ID'
      AND column_value = cp_sch_id
      AND cp_eff_dt BETWEEN effective_start_date AND effective_end_date;
    --
  BEGIN
    --
    l_routine := 'delete_sch_elig_obj';
    hr_utility.trace('Entering '||g_module||l_routine);
    --
    l_bg_id := hr_general.get_business_group_id();
    l_sch_id := wf_event.getvalueforparameter ('SCHEDULE_ID',p_event.parameter_list);
    l_sch_start_date := TO_DATE(wf_event.getvalueforparameter ('SCHEDULE_START_DATE',p_event.parameter_list),'MM/DD/RRRR');
    --
    hr_utility.trace('BGId '||l_bg_id||' SchId '||l_sch_id);
    --
    l_mode := 'DELETE';
    --
    OPEN c_elig_obj (l_bg_id
                    ,l_sch_id
                    ,l_sch_start_date
                    );
    FETCH c_elig_obj INTO l_elig_obj_id
                         ,l_ovn;
    CLOSE c_elig_obj;
    --
    IF l_elig_obj_id IS NOT NULL AND l_ovn IS NOT NULL THEN
      -- Delete Eligibility Object
      ben_elig_obj_api.delete_elig_obj
        (p_elig_obj_id           => l_elig_obj_id
        ,p_effective_date        => l_sch_start_date
        ,p_object_version_number => l_ovn
        ,p_datetrack_mode        => l_mode
        ,p_effective_start_date  => l_eff_start_dt
        ,p_effective_end_date    => l_eff_end_dt
        );
      --
      l_ret_mode :=  'SUCCESS';
      --
      hr_utility.trace('EligObjId '||l_elig_obj_id);
      --
    ELSE
      wf_core.context (g_module,
                       l_routine,
                       p_event.event_name,
                       p_subscription_guid
                      );
      wf_event.seterrorinfo (p_event, 'WARNING');
      l_ret_mode := 'WARNING';
    END IF;
    --
    hr_utility.trace('Leaving '||g_module||l_routine);
    --
    RETURN l_ret_mode;
    --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace('Leaving in Error '||g_module||l_routine);
      wf_core.context (g_module,
                       l_routine,
                       p_event.event_name,
                       p_subscription_guid
                      );
      wf_event.seterrorinfo (p_event, 'ERROR');
      RETURN 'ERROR';
  END delete_sch_elig_obj;
  --
END hr_sch_elig_obj_pkg;

/
