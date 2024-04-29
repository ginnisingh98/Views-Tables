--------------------------------------------------------
--  DDL for Package Body HXT_DML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_DML" AS
/* $Header: hxtdml.pkb 120.1 2005/07/12 03:01:32 vikgarg noship $ */

PROCEDURE insert_hxt_timecards(
p_rowid  IN OUT NOCOPY  VARCHAR2,
p_id                 NUMBER,
p_for_person_id      NUMBER,
p_time_period_id     NUMBER,
p_auto_gen_flag      VARCHAR2,
p_batch_id           NUMBER,
p_approv_person_id   NUMBER,
p_approved_timestamp DATE,
p_created_by         NUMBER,
p_creation_date      DATE,
p_last_updated_by    NUMBER,
p_last_update_date   DATE,
p_last_update_login  NUMBER,
p_payroll_id         NUMBER,
p_status             VARCHAR2,
p_effective_start_date DATE,
p_effective_end_date   DATE,
p_attribute1         VARCHAR2 DEFAULT NULL,
p_attribute2         VARCHAR2 DEFAULT NULL,
p_attribute3         VARCHAR2 DEFAULT NULL,
p_attribute4         VARCHAR2 DEFAULT NULL,
p_attribute5         VARCHAR2 DEFAULT NULL,
p_attribute6         VARCHAR2 DEFAULT NULL,
p_attribute7         VARCHAR2 DEFAULT NULL,
p_attribute8         VARCHAR2 DEFAULT NULL,
p_attribute9         VARCHAR2 DEFAULT NULL,
p_attribute10        VARCHAR2 DEFAULT NULL,
p_attribute11        VARCHAR2 DEFAULT NULL,
p_attribute12        VARCHAR2 DEFAULT NULL,
p_attribute13        VARCHAR2 DEFAULT NULL,
p_attribute14        VARCHAR2 DEFAULT NULL,
p_attribute15        VARCHAR2 DEFAULT NULL,
p_attribute16        VARCHAR2 DEFAULT NULL,
p_attribute17        VARCHAR2 DEFAULT NULL,
p_attribute18        VARCHAR2 DEFAULT NULL,
p_attribute19        VARCHAR2 DEFAULT NULL,
p_attribute20        VARCHAR2 DEFAULT NULL,
p_attribute21        VARCHAR2 DEFAULT NULL,
p_attribute22        VARCHAR2 DEFAULT NULL,
p_attribute23        VARCHAR2 DEFAULT NULL,
p_attribute24        VARCHAR2 DEFAULT NULL,
p_attribute25        VARCHAR2 DEFAULT NULL,
p_attribute26        VARCHAR2 DEFAULT NULL,
p_attribute27        VARCHAR2 DEFAULT NULL,
p_attribute28        VARCHAR2 DEFAULT NULL,
p_attribute29        VARCHAR2 DEFAULT NULL,
p_attribute30        VARCHAR2 DEFAULT NULL,
p_attribute_category VARCHAR2 DEFAULT NULL,
p_object_version_number        OUT NOCOPY NUMBER
) IS

CURSOR c2 IS SELECT rowid
            FROM   hxt_timecards_f
            WHERE  effective_start_date = p_effective_start_date
            AND    effective_end_date = p_effective_end_date
            AND    id = p_id;
begin
p_object_version_number := 1;

insert into HXT_TIMECARDS_F(
       id,
       for_person_id,
       time_period_id,
       auto_gen_flag,
       batch_id,
       approv_person_id,
       approved_timestamp,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       payroll_id,
       --status,
       effective_start_date,
       effective_end_date,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20,
       attribute21,
       attribute22,
       attribute23,
       attribute24,
       attribute25,
       attribute26,
       attribute27,
       attribute28,
       attribute29,
       attribute30,
       attribute_category,
       object_version_number)
VALUES(p_id,
       p_for_person_id,
       p_time_period_id,
       p_auto_gen_flag,
       p_batch_id,
       p_approv_person_id,
       p_approved_timestamp,
       p_created_by,
       p_creation_date,
       p_last_updated_by,
       p_last_update_date,
       p_last_update_login,
       p_payroll_id,
       --p_status,
       p_effective_start_date,
       p_effective_end_date,
       p_attribute1,
       p_attribute2,
       p_attribute3,
       p_attribute4,
       p_attribute5,
       p_attribute6,
       p_attribute7,
       p_attribute8,
       p_attribute9,
       p_attribute10,
       p_attribute11,
       p_attribute12,
       p_attribute13,
       p_attribute14,
       p_attribute15,
       p_attribute16,
       p_attribute17,
       p_attribute18,
       p_attribute19,
       p_attribute20,
       p_attribute21,
       p_attribute22,
       p_attribute23,
       p_attribute24,
       p_attribute25,
       p_attribute26,
       p_attribute27,
       p_attribute28,
       p_attribute29,
       p_attribute30,
       p_attribute_category,
       p_object_version_number);

open c2;
fetch c2 into p_rowid;
close c2;
null;

end insert_HXT_TIMECARDS;

procedure insert_HXT_SUM_HOURS_WORKED(
p_rowid        IN OUT NOCOPY  VARCHAR2,
p_id                     NUMBER,
-- p_group_id               NUMBER,       --HXT11i1
p_tim_id                 NUMBER,
p_date_worked            DATE,
p_assignment_id          NUMBER,
p_hours                  NUMBER,
p_time_in                DATE,
p_time_out               DATE,
p_element_type_id        NUMBER,
p_fcl_earn_reason_code   VARCHAR2,
p_ffv_cost_center_id     NUMBER,
p_ffv_labor_account_id   NUMBER,
p_tas_id                 NUMBER,
p_location_id            NUMBER,
p_sht_id                 NUMBER,
p_hrw_comment            VARCHAR2,
p_ffv_rate_code_id       NUMBER,
p_rate_multiple          NUMBER,
p_hourly_rate            NUMBER,
p_amount                 NUMBER,
p_fcl_tax_rule_code      VARCHAR2,
p_separate_check_flag    VARCHAR2,
p_seqno                  NUMBER,
p_created_by             NUMBER,
p_creation_date          DATE,
p_last_updated_by        NUMBER,
p_last_update_date       DATE,
p_last_update_login      NUMBER,
p_actual_time_in         DATE,
p_actual_time_out        DATE,
p_effective_start_date   DATE,
p_effective_end_date     DATE,
p_project_id             NUMBER,     /*PROJACCT */
p_prev_wage_code         VARCHAR2,
p_job_id                 NUMBER,     /*TA35 */
p_earn_pol_id		 NUMBER,      /*OVEREARN */
p_attribute1         VARCHAR2 DEFAULT NULL,
p_attribute2         VARCHAR2 DEFAULT NULL,
p_attribute3         VARCHAR2 DEFAULT NULL,
p_attribute4         VARCHAR2 DEFAULT NULL,
p_attribute5         VARCHAR2 DEFAULT NULL,
p_attribute6         VARCHAR2 DEFAULT NULL,
p_attribute7         VARCHAR2 DEFAULT NULL,
p_attribute8         VARCHAR2 DEFAULT NULL,
p_attribute9         VARCHAR2 DEFAULT NULL,
p_attribute10        VARCHAR2 DEFAULT NULL,
p_attribute11        VARCHAR2 DEFAULT NULL,
p_attribute12        VARCHAR2 DEFAULT NULL,
p_attribute13        VARCHAR2 DEFAULT NULL,
p_attribute14        VARCHAR2 DEFAULT NULL,
p_attribute15        VARCHAR2 DEFAULT NULL,
p_attribute16        VARCHAR2 DEFAULT NULL,
p_attribute17        VARCHAR2 DEFAULT NULL,
p_attribute18        VARCHAR2 DEFAULT NULL,
p_attribute19        VARCHAR2 DEFAULT NULL,
p_attribute20        VARCHAR2 DEFAULT NULL,
p_attribute21        VARCHAR2 DEFAULT NULL,
p_attribute22        VARCHAR2 DEFAULT NULL,
p_attribute23        VARCHAR2 DEFAULT NULL,
p_attribute24        VARCHAR2 DEFAULT NULL,
p_attribute25        VARCHAR2 DEFAULT NULL,
p_attribute26        VARCHAR2 DEFAULT NULL,
p_attribute27        VARCHAR2 DEFAULT NULL,
p_attribute28        VARCHAR2 DEFAULT NULL,
p_attribute29        VARCHAR2 DEFAULT NULL,
p_attribute30        VARCHAR2 DEFAULT NULL,
p_attribute_category VARCHAR2 DEFAULT NULL,
p_time_building_block_id  NUMBER DEFAULT NULL,
p_time_building_block_ovn NUMBER DEFAULT NULL,
p_object_version_number        out nocopy number,
p_STATE_NAME              VARCHAR2 DEFAULT NULL,
p_COUNTY_NAME             VARCHAR2 DEFAULT NULL,
p_CITY_NAME               VARCHAR2 DEFAULT NULL,
p_ZIP_CODE                VARCHAR2 DEFAULT NULL
) is

cursor c2 is select rowid
            from   hxt_sum_hours_worked_f
            where  effective_start_date = p_effective_start_date
            and    effective_end_date = p_effective_end_date
            and    id = p_id;

begin

p_object_version_number := 1;

insert into HXT_SUM_HOURS_WORKED_F(
       id,
       -- group_id,            --HXT11i1
       tim_id,
       date_worked,
       assignment_id,
       hours,
       time_in,
       time_out,
       element_type_id,
       fcl_earn_reason_code,
       ffv_cost_center_id,
       /*TA36ffv_labor_account_id,*/
       tas_id,
       location_id,
       sht_id,
       hrw_comment,
       ffv_rate_code_id,
       rate_multiple,
       hourly_rate,
       amount,
       fcl_tax_rule_code,
       separate_check_flag,
       seqno,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       actual_time_in,
       actual_time_out,
       effective_start_date,
       effective_end_date,
       project_id,             /*PROJACCT */
       prev_wage_code,
       job_id,                 /*TA35 */
       earn_pol_id,             /*OVEREARN */
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20,
       attribute21,
       attribute22,
       attribute23,
       attribute24,
       attribute25,
       attribute26,
       attribute27,
       attribute28,
       attribute29,
       attribute30,
       attribute_category,
       time_building_block_id,
       time_building_block_ovn,
       object_version_number,
       STATE_NAME,
       COUNTY_NAME ,
       CITY_NAME,
       ZIP_CODE)
VALUES(p_id,
       -- p_group_id,             --HXT11i1
       p_tim_id,
       p_date_worked,
       p_assignment_id,
       p_hours,
       p_time_in,
       p_time_out,
       p_element_type_id,
       p_fcl_earn_reason_code,
       p_ffv_cost_center_id,
       /*TA36p_ffv_labor_account_id,*/
       p_tas_id,
       p_location_id,
       p_sht_id,
       p_hrw_comment,
       p_ffv_rate_code_id,
       p_rate_multiple,
       p_hourly_rate,
       p_amount,
       p_fcl_tax_rule_code,
       p_separate_check_flag,
       p_seqno,
       p_created_by,
       p_creation_date,
       p_last_updated_by,
       p_last_update_date,
       p_last_update_login,
       p_actual_time_in,
       p_actual_time_out,
       p_effective_start_date,
       p_effective_end_date,
       p_project_id,             /*PROJACCT */
       p_prev_wage_code,
       p_job_id,                 /*TA35 */
       p_earn_pol_id,		  /*OVEREARN */
       p_attribute1,
       p_attribute2,
       p_attribute3,
       p_attribute4,
       p_attribute5,
       p_attribute6,
       p_attribute7,
       p_attribute8,
       p_attribute9,
       p_attribute10,
       p_attribute11,
       p_attribute12,
       p_attribute13,
       p_attribute14,
       p_attribute15,
       p_attribute16,
       p_attribute17,
       p_attribute18,
       p_attribute19,
       p_attribute20,
       p_attribute21,
       p_attribute22,
       p_attribute23,
       p_attribute24,
       p_attribute25,
       p_attribute26,
       p_attribute27,
       p_attribute28,
       p_attribute29,
       p_attribute30,
       p_attribute_category,
       p_time_building_block_id,
       p_time_building_block_ovn,
       p_object_version_number,
       p_STATE_NAME,
       p_COUNTY_NAME ,
       p_CITY_NAME ,
       p_ZIP_CODE);

open c2;
fetch c2 into p_rowid;
close c2;
null;

end insert_HXT_SUM_HOURS_WORKED;

procedure insert_HXT_DET_HOURS_WORKED(
p_rowid        IN OUT NOCOPY  VARCHAR2,
p_id                     NUMBER,
p_parent_id              NUMBER,
p_tim_id                 NUMBER,
p_date_worked            DATE,
p_assignment_id          NUMBER,
p_hours                  NUMBER,
p_time_in                DATE,
p_time_out               DATE,
p_element_type_id        NUMBER,
p_fcl_earn_reason_code   VARCHAR2,
p_ffv_cost_center_id     NUMBER,
p_ffv_labor_account_id   NUMBER,
p_tas_id                 NUMBER,
p_location_id            NUMBER,
p_sht_id                 NUMBER,
p_hrw_comment            VARCHAR2,
p_ffv_rate_code_id       NUMBER,
p_rate_multiple          NUMBER,
p_hourly_rate            NUMBER,
p_amount                 NUMBER,
p_fcl_tax_rule_code      VARCHAR2,
p_separate_check_flag    VARCHAR2,
p_seqno                  NUMBER,
p_created_by             NUMBER,
p_creation_date          DATE,
p_last_updated_by        NUMBER,
p_last_update_date       DATE,
p_last_update_login      NUMBER,
p_actual_time_in         DATE,
p_actual_time_out        DATE,
p_effective_start_date   DATE,
p_effective_end_date     DATE,
p_project_id             NUMBER,     /*PROJACCT */
p_job_id                 NUMBER,     /*TA35 */
p_earn_pol_id		 NUMBER,     /*OVEREARN */
p_retro_batch_id         NUMBER,     /*RETROPAY */
p_pa_status              VARCHAR2,     /*RETROPA */
p_pay_status             VARCHAR2,      /*RETROPAY */
-- p_group_id               NUMBER,
p_object_version_number        out nocopy number,
p_STATE_NAME              VARCHAR2 DEFAULT NULL,
p_COUNTY_NAME             VARCHAR2 DEFAULT NULL,
p_CITY_NAME               VARCHAR2 DEFAULT NULL,
p_ZIP_CODE                VARCHAR2 DEFAULT NULL
) is

cursor c2 is select rowid
            from   hxt_det_hours_worked_f
            where  effective_start_date = p_effective_start_date
            and    effective_end_date = p_effective_end_date
            and    id = p_id;

begin

p_object_version_number := 1;

insert into HXT_DET_HOURS_WORKED_F(
id,
parent_id,
tim_id,
date_worked,
assignment_id,
hours,
time_in,
time_out,
element_type_id,
fcl_earn_reason_code,
ffv_cost_center_id,
/*TA36ffv_labor_account_id,*/
tas_id,
location_id,
sht_id,
hrw_comment,
ffv_rate_code_id,
rate_multiple,
hourly_rate,
amount,
fcl_tax_rule_code,
separate_check_flag,
seqno,
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login,
actual_time_in,
actual_time_out,
effective_start_date,
effective_end_date,
project_id,         /*PROJACCT */
job_id,             /*TA35 */
earn_pol_id,	  /*OVEREARN */
retro_batch_id,     /*RETROPAY */
pa_status,         /*RETROPA */
pay_status,         /*RETROPAY */
-- group_id,
object_version_number,
STATE_NAME ,
COUNTY_NAME ,
CITY_NAME ,
ZIP_CODE
)
VALUES(
p_id,
p_parent_id,
p_tim_id,
p_date_worked,
p_assignment_id,
p_hours,
p_time_in,
p_time_out,
p_element_type_id,
p_fcl_earn_reason_code,
p_ffv_cost_center_id,
/*TA36p_ffv_labor_account_id,*/
p_tas_id,
p_location_id,
p_sht_id,
p_hrw_comment,
p_ffv_rate_code_id,
p_rate_multiple,
p_hourly_rate,
p_amount,
p_fcl_tax_rule_code,
p_separate_check_flag,
p_seqno,
p_created_by,
p_creation_date,
p_last_updated_by,
p_last_update_date,
p_last_update_login,
p_actual_time_in,
p_actual_time_out,
p_effective_start_date,
p_effective_end_date,
p_project_id,            /*PROJACCT */
p_job_id,                /*TA35 */
p_earn_pol_id,		 /*OVEREARN */
p_retro_batch_id,        /*RETROPAY */
p_pa_status,         /*RETROPA */
p_pay_status,         /*RETROPAY */
-- p_group_id,
p_object_version_number,
p_STATE_NAME ,
p_COUNTY_NAME,
p_CITY_NAME ,
p_ZIP_CODE
);

open c2;
fetch c2 into p_rowid;
close c2;
null;

end insert_HXT_DET_HOURS_WORKED;


procedure update_HXT_TIMECARDS(
p_rowid  IN          VARCHAR2,
p_id                 NUMBER,
p_for_person_id      NUMBER,
p_time_period_id     NUMBER,
p_auto_gen_flag      VARCHAR2,
p_batch_id           NUMBER,
p_approv_person_id   NUMBER,
p_approved_timestamp DATE,
p_created_by         NUMBER,
p_creation_date      DATE,
p_last_updated_by    NUMBER,
p_last_update_date   DATE,
p_last_update_login  NUMBER,
p_payroll_id         NUMBER,
p_status             VARCHAR2,
p_effective_start_date DATE,
p_effective_end_date   DATE,
p_attribute1         VARCHAR2 DEFAULT NULL,
p_attribute2         VARCHAR2 DEFAULT NULL,
p_attribute3         VARCHAR2 DEFAULT NULL,
p_attribute4         VARCHAR2 DEFAULT NULL,
p_attribute5         VARCHAR2 DEFAULT NULL,
p_attribute6         VARCHAR2 DEFAULT NULL,
p_attribute7         VARCHAR2 DEFAULT NULL,
p_attribute8         VARCHAR2 DEFAULT NULL,
p_attribute9         VARCHAR2 DEFAULT NULL,
p_attribute10        VARCHAR2 DEFAULT NULL,
p_attribute11        VARCHAR2 DEFAULT NULL,
p_attribute12        VARCHAR2 DEFAULT NULL,
p_attribute13        VARCHAR2 DEFAULT NULL,
p_attribute14        VARCHAR2 DEFAULT NULL,
p_attribute15        VARCHAR2 DEFAULT NULL,
p_attribute16        VARCHAR2 DEFAULT NULL,
p_attribute17        VARCHAR2 DEFAULT NULL,
p_attribute18        VARCHAR2 DEFAULT NULL,
p_attribute19        VARCHAR2 DEFAULT NULL,
p_attribute20        VARCHAR2 DEFAULT NULL,
p_attribute21        VARCHAR2 DEFAULT NULL,
p_attribute22        VARCHAR2 DEFAULT NULL,
p_attribute23        VARCHAR2 DEFAULT NULL,
p_attribute24        VARCHAR2 DEFAULT NULL,
p_attribute25        VARCHAR2 DEFAULT NULL,
p_attribute26        VARCHAR2 DEFAULT NULL,
p_attribute27        VARCHAR2 DEFAULT NULL,
p_attribute28        VARCHAR2 DEFAULT NULL,
p_attribute29        VARCHAR2 DEFAULT NULL,
p_attribute30        VARCHAR2 DEFAULT NULL,
p_attribute_category VARCHAR2 DEFAULT NULL,
p_object_version_number        in out nocopy number
) is

begin

p_object_version_number := p_object_version_number + 1;

update HXT_TIMECARDS_F
set
for_person_id = p_for_person_id,
time_period_id = p_time_period_id,
auto_gen_flag = p_auto_gen_flag,
batch_id = p_batch_id,
approv_person_id = p_approv_person_id,
approved_timestamp = p_approved_timestamp,
created_by = p_created_by,
creation_date = p_creation_date,
last_updated_by = p_last_updated_by,
last_update_date = p_last_update_date,
last_update_login = p_last_update_login,
payroll_id = p_payroll_id,
--status = p_status,
effective_start_date = p_effective_start_date,
effective_end_date = p_effective_end_date,
attribute1 = p_attribute1,
attribute2 = p_attribute2,
attribute3 = p_attribute3,
attribute4 = p_attribute4,
attribute5 = p_attribute5,
attribute6 = p_attribute6,
attribute7 = p_attribute7,
attribute8 = p_attribute8,
attribute9 = p_attribute9,
attribute10 = p_attribute10,
attribute11 = p_attribute11,
attribute12 = p_attribute12,
attribute13 = p_attribute13,
attribute14 = p_attribute14,
attribute15 = p_attribute15,
attribute16 = p_attribute16,
attribute17 = p_attribute17,
attribute18 = p_attribute18,
attribute19 = p_attribute19,
attribute20 = p_attribute20,
attribute21 = p_attribute21,
attribute22 = p_attribute22,
attribute23 = p_attribute23,
attribute24 = p_attribute24,
attribute25 = p_attribute25,
attribute26 = p_attribute26,
attribute27 = p_attribute27,
attribute28 = p_attribute28,
attribute29 = p_attribute29,
attribute30 = p_attribute30,
attribute_category = p_attribute_category,
object_version_number = p_object_version_number
where rowid = p_rowid;

end update_HXT_TIMECARDS;

procedure update_HXT_SUM_HOURS_WORKED(
p_rowid        IN        VARCHAR2,
p_id                     NUMBER,
-- p_group_id               NUMBER,       --HXT11i1
p_tim_id                 NUMBER,
p_date_worked            DATE,
p_assignment_id          NUMBER,
p_hours                  NUMBER,
p_time_in                DATE,
p_time_out               DATE,
p_element_type_id        NUMBER,
p_fcl_earn_reason_code   VARCHAR2,
p_ffv_cost_center_id     NUMBER,
p_ffv_labor_account_id   NUMBER,
p_tas_id                 NUMBER,
p_location_id            NUMBER,
p_sht_id                 NUMBER,
p_hrw_comment            VARCHAR2,
p_ffv_rate_code_id       NUMBER,
p_rate_multiple          NUMBER,
p_hourly_rate            NUMBER,
p_amount                 NUMBER,
p_fcl_tax_rule_code      VARCHAR2,
p_separate_check_flag    VARCHAR2,
p_seqno                  NUMBER,
p_created_by             NUMBER,
p_creation_date          DATE,
p_last_updated_by        NUMBER,
p_last_update_date       DATE,
p_last_update_login      NUMBER,
p_actual_time_in         DATE,
p_actual_time_out        DATE,
p_effective_start_date   DATE,
p_effective_end_date     DATE,
p_project_id             NUMBER,     /*PROJACCT */
p_prev_wage_code         VARCHAR2,
p_job_id                 NUMBER,     /*TA35 */
p_earn_pol_id		 NUMBER,      /*OVEREARN */
p_attribute1         VARCHAR2 DEFAULT NULL,
p_attribute2         VARCHAR2 DEFAULT NULL,
p_attribute3         VARCHAR2 DEFAULT NULL,
p_attribute4         VARCHAR2 DEFAULT NULL,
p_attribute5         VARCHAR2 DEFAULT NULL,
p_attribute6         VARCHAR2 DEFAULT NULL,
p_attribute7         VARCHAR2 DEFAULT NULL,
p_attribute8         VARCHAR2 DEFAULT NULL,
p_attribute9         VARCHAR2 DEFAULT NULL,
p_attribute10        VARCHAR2 DEFAULT NULL,
p_attribute11        VARCHAR2 DEFAULT NULL,
p_attribute12        VARCHAR2 DEFAULT NULL,
p_attribute13        VARCHAR2 DEFAULT NULL,
p_attribute14        VARCHAR2 DEFAULT NULL,
p_attribute15        VARCHAR2 DEFAULT NULL,
p_attribute16        VARCHAR2 DEFAULT NULL,
p_attribute17        VARCHAR2 DEFAULT NULL,
p_attribute18        VARCHAR2 DEFAULT NULL,
p_attribute19        VARCHAR2 DEFAULT NULL,
p_attribute20        VARCHAR2 DEFAULT NULL,
p_attribute21        VARCHAR2 DEFAULT NULL,
p_attribute22        VARCHAR2 DEFAULT NULL,
p_attribute23        VARCHAR2 DEFAULT NULL,
p_attribute24        VARCHAR2 DEFAULT NULL,
p_attribute25        VARCHAR2 DEFAULT NULL,
p_attribute26        VARCHAR2 DEFAULT NULL,
p_attribute27        VARCHAR2 DEFAULT NULL,
p_attribute28        VARCHAR2 DEFAULT NULL,
p_attribute29        VARCHAR2 DEFAULT NULL,
p_attribute30        VARCHAR2 DEFAULT NULL,
p_attribute_category VARCHAR2 DEFAULT NULL,
p_time_building_block_id  NUMBER DEFAULT NULL,
p_time_building_block_ovn NUMBER DEFAULT NULL,
p_object_version_number        in out nocopy number,
p_STATE_NAME                    VARCHAR2 DEFAULT NULL,
p_COUNTY_NAME                   VARCHAR2 DEFAULT NULL,
p_CITY_NAME                     VARCHAR2 DEFAULT NULL,
p_ZIP_CODE                      VARCHAR2 DEFAULT NULL
) is

begin

p_object_version_number := p_object_version_number + 1;

update HXT_SUM_HOURS_WORKED_F
set
-- group_id = p_group_id,           --HXT11i1
date_worked = p_date_worked,
assignment_id = p_assignment_id,
hours = p_hours,
time_in = p_time_in,
time_out = p_time_out,
element_type_id = p_element_type_id,
fcl_earn_reason_code = p_fcl_earn_reason_code,
ffv_cost_center_id = p_ffv_cost_center_id,
tas_id = p_tas_id,
location_id = p_location_id,
sht_id = p_sht_id,
hrw_comment = p_hrw_comment,
ffv_rate_code_id = p_ffv_rate_code_id,
rate_multiple = p_rate_multiple,
hourly_rate = p_hourly_rate,
amount = p_amount,
fcl_tax_rule_code = p_fcl_tax_rule_code,
separate_check_flag = p_separate_check_flag,
seqno = p_seqno,
created_by = p_created_by,
creation_date = p_creation_date,
last_updated_by = p_last_updated_by,
last_update_date = p_last_update_date,
last_update_login = p_last_update_login,
actual_time_in = p_actual_time_in,
actual_time_out = p_actual_time_out,
effective_start_date = p_effective_start_date,
effective_end_date = p_effective_end_date,
project_id = p_project_id,                   /*PROJACCT */
prev_wage_code = p_prev_wage_code,
job_id = p_job_id,                           /*TA35 */
earn_pol_id = p_earn_pol_id,                  /*OVEREARN */
attribute1 = p_attribute1,
attribute2 = p_attribute2,
attribute3 = p_attribute3,
attribute4 = p_attribute4,
attribute5 = p_attribute5,
attribute6 = p_attribute6,
attribute7 = p_attribute7,
attribute8 = p_attribute8,
attribute9 = p_attribute9,
attribute10 = p_attribute10,
attribute11 = p_attribute11,
attribute12 = p_attribute12,
attribute13 = p_attribute13,
attribute14 = p_attribute14,
attribute15 = p_attribute15,
attribute16 = p_attribute16,
attribute17 = p_attribute17,
attribute18 = p_attribute18,
attribute19 = p_attribute19,
attribute20 = p_attribute20,
attribute21 = p_attribute21,
attribute22 = p_attribute22,
attribute23 = p_attribute23,
attribute24 = p_attribute24,
attribute25 = p_attribute25,
attribute26 = p_attribute26,
attribute27 = p_attribute27,
attribute28 = p_attribute28,
attribute29 = p_attribute29,
attribute30 = p_attribute30,
attribute_category = p_attribute_category,
time_building_block_id = nvl(p_time_building_block_id, time_building_block_id),
time_building_block_ovn = nvl(p_time_building_block_ovn, time_building_block_ovn),
object_version_number = p_object_version_number,
STATE_NAME = p_STATE_NAME,
COUNTY_NAME=p_COUNTY_NAME,
CITY_NAME =p_CITY_NAME ,
ZIP_CODE=p_ZIP_CODE
where rowid = p_rowid;

end update_HXT_SUM_HOURS_WORKED;

procedure update_HXT_DET_HOURS_WORKED(
p_rowid        IN      VARCHAR2,
p_id                     NUMBER,
p_parent_id              NUMBER,
p_tim_id                 NUMBER,
p_date_worked            DATE,
p_assignment_id          NUMBER,
p_hours                  NUMBER,
p_time_in                DATE,
p_time_out               DATE,
p_element_type_id        NUMBER,
p_fcl_earn_reason_code   VARCHAR2,
p_ffv_cost_center_id     NUMBER,
p_ffv_labor_account_id   NUMBER,
p_tas_id                 NUMBER,
p_location_id            NUMBER,
p_sht_id                 NUMBER,
p_hrw_comment            VARCHAR2,
p_ffv_rate_code_id       NUMBER,
p_rate_multiple          NUMBER,
p_hourly_rate            NUMBER,
p_amount                 NUMBER,
p_fcl_tax_rule_code      VARCHAR2,
p_separate_check_flag    VARCHAR2,
p_seqno                  NUMBER,
p_created_by             NUMBER,
p_creation_date          DATE,
p_last_updated_by        NUMBER,
p_last_update_date       DATE,
p_last_update_login      NUMBER,
p_actual_time_in         DATE,
p_actual_time_out        DATE,
p_effective_start_date   DATE,
p_effective_end_date     DATE,
p_project_id             NUMBER,     /*PROJACCT */
p_job_id                 NUMBER,
p_earn_pol_id		 NUMBER,     /*OVEREARN */
p_retro_batch_id         NUMBER,     /*RETROPAY */
p_pa_status              VARCHAR2,     /*RETROPA */
p_pay_status             VARCHAR2,      /*RETROPAY */
-- p_group_id               NUMBER,
p_object_version_number        in out nocopy number,
p_STATE_NAME             VARCHAR2 DEFAULT NULL,
p_COUNTY_NAME            VARCHAR2 DEFAULT NULL,
p_CITY_NAME              VARCHAR2 DEFAULT NULL,
p_ZIP_CODE               VARCHAR2 DEFAULT NULL
) is

BEGIN

p_object_version_number := p_object_version_number + 1;

UPDATE hxt_det_hours_worked_f
SET
date_worked           = p_date_worked,
assignment_id         = p_assignment_id,
hours                 = p_hours,
time_in               = p_time_in,
time_out              = p_time_out,
element_type_id       = p_element_type_id,
fcl_earn_reason_code  = p_fcl_earn_reason_code,
ffv_cost_center_id    = p_ffv_cost_center_id,
tas_id                = p_tas_id,
location_id           = p_location_id,
sht_id                = p_sht_id,
hrw_comment           = p_hrw_comment,
ffv_rate_code_id      = p_ffv_rate_code_id,
rate_multiple         = p_rate_multiple,
hourly_rate           = p_hourly_rate,
amount                = p_amount,
fcl_tax_rule_code     = p_fcl_tax_rule_code,
separate_check_flag   = p_separate_check_flag,
seqno                 = p_seqno,
created_by            = p_created_by,
creation_date         = p_creation_date,
last_updated_by       = p_last_updated_by,
last_update_date      = p_last_update_date,
last_update_login     = p_last_update_login,
actual_time_in        = p_actual_time_in,
actual_time_out       = p_actual_time_out,
effective_start_date  = p_effective_start_date,
effective_end_date    = p_effective_end_date,
project_id            = p_project_id,                   /*PROJACCT */
job_id                = p_job_id,
earn_pol_id           = p_earn_pol_id,                 /*OVEREARN */
retro_batch_id        = p_retro_batch_id,           /*RETROPAY */
pa_status             = p_pa_status,     /*RETROPA */
pay_status            = p_pay_status, /*RETROPAY */
-- group_id 	      = p_group_id,
object_version_number = p_object_version_number,
STATE_NAME            =p_STATE_NAME,
COUNTY_NAME           =p_COUNTY_NAME,
CITY_NAME             =p_CITY_NAME,
ZIP_CODE              =p_ZIP_CODE
WHERE rowid           = p_rowid;

END update_HXT_DET_HOURS_WORKED;


procedure delete_HXT_TIMECARDS(p_rowid VARCHAR2) is
begin
   delete from HXT_TIMECARDS_F
   where rowid=chartorowid(p_rowid);
end delete_HXT_TIMECARDS;

procedure delete_HXT_SUM_HOURS_WORKED(p_rowid VARCHAR2) is
begin
   delete from HXT_SUM_HOURS_WORKED_F
   where rowid=chartorowid(p_rowid);
end delete_HXT_SUM_HOURS_WORKED;

procedure delete_HXT_DET_HOURS_WORKED(p_rowid VARCHAR2) is
begin
   delete from HXT_DET_HOURS_WORKED_F
   where rowid=chartorowid(p_rowid);
end delete_HXT_DET_HOURS_WORKED;


procedure lock_HXT_TIMECARDS(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select FOR_PERSON_ID into vnull
   from hxt_timecards_f
   where rowid = p_rowid
   for update of hxt_timecards_f.FOR_PERSON_ID nowait;

end if;
end lock_HXT_TIMECARDS;

procedure lock_HXT_SUM_HOURS_WORKED(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select ASSIGNMENT_ID into vnull
   from hxt_sum_hours_worked_f
   where rowid = p_rowid
   for update of hxt_sum_hours_worked_f.ASSIGNMENT_ID nowait;

end if;
end lock_HXT_SUM_HOURS_WORKED;

procedure lock_HXT_DET_HOURS_WORKED(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select ASSIGNMENT_ID into vnull
   from hxt_det_hours_worked_f
   where rowid = p_rowid
   for update of hxt_det_hours_worked_f.ASSIGNMENT_ID nowait;

end if;
end lock_HXT_DET_HOURS_WORKED;

end HXT_DML;

/
