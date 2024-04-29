--------------------------------------------------------
--  DDL for Package Body OTA_FR_2483_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FR_2483_DATA" as
/* $Header: otfr248d.pkb 120.1.12010000.3 2008/10/14 06:49:55 parusia ship $ */
--
g_package varchar2(30) := 'ota_fr_2483_data';
/* ---------------------------------------------------------------------------
   Description
   This inserts measurement type data into the business group, that
   is needed for the 2483 report. Where the data already exists for
   business group, it is updated.
   -------------------------------------------------------------------------*/
--
procedure load_bg_measure_item(p_business_group_id    number
                              ,p_tp_measurement_code  varchar2
                              ,p_unit                 varchar2
                              ,p_cost_level           varchar2
                              ,p_budget_level         varchar2 default 'PLAN')  is
/* --------------------------------------------------------------------------
   Description
   This procedure inserts or updates 1 measure into the table
   for the OTA 2483 Report
   ------------------------------------------------------------------------- */
--
l_mt_id                number;
l_ovn                  number;
l_exists               number := 1;
l_proc varchar2(72) := g_package||'.load_bg_measure_item';
--
cursor csr_existing_measure_code (l_bg_id number
                                 ,l_measure_code varchar2) is
select tp_measurement_type_id
      ,object_version_number
  from ota_tp_measurement_types
where business_group_id   = l_bg_id
  and tp_measurement_code = l_measure_code;
--
begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 hr_utility.trace(p_tp_measurement_code);
 --
 open csr_existing_measure_code (p_business_group_id
                                ,p_tp_measurement_code);
 fetch csr_existing_measure_code into l_mt_id
                                     ,l_ovn;
 if csr_existing_measure_code%NOTFOUND then
   l_exists := 0;
 end if;

 close csr_existing_measure_code;

 if l_exists = 0 then
   hr_utility.set_location(l_proc,10);
   ota_tmt_api.create_measure
   (p_effective_date             =>     sysdate
   ,p_business_group_id          =>     p_business_group_id
   ,p_tp_measurement_code        =>     p_tp_measurement_code
   ,p_unit                       =>     p_unit
   ,p_budget_level               =>     p_budget_level -- modified for 5239200
   ,p_cost_level                 =>     p_cost_level
   ,p_many_budget_values_flag    =>     'N'
   ,p_tp_measurement_type_id     =>     l_mt_id
   ,p_object_version_number      =>     l_ovn);
 else
   /* user may change data, as they own it.
      thus we shall not subsequently update it */
   hr_utility.set_location(l_proc,20);
   --ota_tmt_api.update_measure
   --(p_effective_date             =>     sysdate
   --,p_tp_measurement_type_id     =>     l_mt_id
   --,p_object_version_number      =>     l_ovn
   --,p_unit                       =>     p_unit
   --,p_cost_level                 =>     p_cost_level);
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 5);
end load_bg_measure_item;

procedure load_bg_measurement_types(p_business_group_id number) is
/* -----------------------------------------------------------------
   Description
   This procedure loads each measurement type in turn
   ----------------------------------------------------------------- */
l_proc varchar2(72) := g_package||'.load_bg_measurement_types';
Begin
  hr_utility.set_location(l_proc,10);
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_EXT_TRN_PLAN',     'M','PLAN');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_EXT_TRN_PLAN_SA',  'M','PLAN');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_EXT_TRN_PLAN_VAE', 'M','PLAN');
  load_bg_measure_item(
       p_business_group_id, 'FR_OTHER_PLAN_DEDUCT_COSTS', 'M','PLAN');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_TRAINER_SALARY',   'M','EVENT');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_ADMIN_SALARY',     'M','EVENT');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_RUNNING_COSTS',    'M','EVENT');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_TRAINER_TRANSPRT', 'M','EVENT');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_TRAINER_ACCOM',    'M','EVENT');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_EXT_TRN_CLASS',    'M','EVENT');
  load_bg_measure_item(
       p_business_group_id, 'FR_OTHER_CLASS_DEDUCT_COST', 'M','EVENT');
  load_bg_measure_item(
       p_business_group_id, 'FR_ACTUAL_HOURS',            'N','DELEGATE');
  load_bg_measure_item(
       p_business_group_id, 'FR_SKILLS_ASSESSMENT'	, 'M','DELEGATE');
  load_bg_measure_item(
       p_business_group_id, 'FR_VAE',                     'M','DELEGATE');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_LEARNER_SALARY'	, 'M','DELEGATE');
  load_bg_measure_item(
       p_business_group_id, 'FR_DEDUCT_TRN_ALLOWANCE'   , 'M','DELEGATE');
  load_bg_measure_item(
       p_business_group_id, 'FR_OTHER_LEARN_DEDUCT_INT'	, 'M','DELEGATE');
  load_bg_measure_item(
       p_business_group_id, 'FR_OTHER_LEARN_DEDUCT_EXT',  'M','DELEGATE');
  -- added for 5230200 (french training plan report)
  load_bg_measure_item(
       p_business_group_id, 'FR_DURATION_HOURS',  'N', 'NONE', 'ACTIVITY');
  load_bg_measure_item(
       p_business_group_id, 'FR_NUMBER_EVENTS',  'I', 'NONE', 'ACTIVITY');
  load_bg_measure_item(
       p_business_group_id, 'FR_DELEGATES_PER_CATEGORY',  'I', 'NONE', 'ACTIVITY');
--
  hr_utility.set_location(l_proc,100);
End Load_BG_Measurement_types;
--
END ota_fr_2483_data;

/
