--------------------------------------------------------
--  DDL for Package Body HXT_GEN_AAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_GEN_AAI" AS
/* $Header: hxtgenai.pkb 120.3.12010000.4 2009/09/29 11:26:09 asrajago ship $ */

-------------------------------------------------------------------------------

g_debug boolean := hr_utility.debug_enabled;
PROCEDURE AAI_VALIDATIONS
 (p_assignment_id              NUMBER
 ,p_earning_policy             NUMBER
 ,p_rotation_plan              NUMBER
 ,p_shift_differential_policy  NUMBER
 ,p_hour_deduction_policy      NUMBER
 ,p_autogen_hours_yn           VARCHAR2
 ,p_effective_start_date       DATE
 ) IS

   asg_bus_grp_id NUMBER(15);

/* Cursor to check for the rotation plan */
   CURSOR chk_rot_plan IS
     SELECT 'compatible'
     FROM    hxt_rotation_plans rot
     WHERE   p_effective_start_date between rot.date_from
                                        and nvl(rot.date_to, p_effective_start_date)
     AND NOT EXISTS (SELECT '1'
                     FROM    hxt_rotation_schedules hrs
                            ,hxt_weekly_work_schedules wws
                     WHERE   hrs.rtp_id = rot.id
                     AND     wws.id = hrs.tws_id
                     AND     wws.business_group_id <> nvl(asg_bus_grp_id, -99))
     AND rot.id = p_rotation_plan;

 l_rtp_compatible varchar2(15) := NULL;

/* Cursor to check whether Earning Policy is compatible with the Assignment */
   CURSOR chk_earning_policy IS
     SELECT 'compatible'
     FROM    hxt_earning_policies erp
     WHERE   p_effective_start_date between erp.effective_start_date
                                        and erp.effective_end_date
     AND     erp.business_group_id = nvl(asg_bus_grp_id, -99)
     AND EXISTS
        (select 1
         from hxt_pay_element_types_f_ddf_v v
            , pay_element_types_f t
            , hxt_earning_rules r
         where r.egp_id = erp.id
         and p_effective_start_date between r.effective_start_date
                                        and r.effective_end_date
         and t.element_type_id = r.element_type_id
         and p_effective_start_date between t.effective_start_date
                                        and t.effective_end_date
         and asg_bus_grp_id
                    = nvl(t.business_group_id,asg_bus_grp_id)
         and v.element_type_id = t.element_type_id
         and p_effective_start_date between v.effective_start_date
                                        and v.effective_end_date
         and v.hxt_earning_category in ('ABS', 'OVT', 'REG'))
     AND NOT EXISTS
        (select 1
         from hxt_earning_rules er
         where er.egp_id = erp.id
         and p_effective_start_date between er.effective_start_date
                                        and er.effective_end_date
         and er.element_type_id NOT IN
               (select ern.element_type_id
                from pay_element_links_f ell
                   , per_assignments_f asm
                   , hxt_earning_rules ern
                where ern.egp_id = erp.id
                and p_effective_start_date between ern.effective_start_date
                                               and ern.effective_end_date
                and asm.assignment_id = p_assignment_id
                and p_effective_start_date between asm.effective_start_date
                                               and asm.effective_end_date
                and ell.element_type_id = ern.element_type_id
                and p_effective_start_date between ell.effective_start_date
                                               and ell.effective_end_date
                and nvl(ell.organization_id, nvl(asm.organization_id,-1))
                            = nvl(asm.organization_id,-1)
                and (ell.people_group_id is null
                      or exists
                        (select 1
                         from pay_assignment_link_usages_f usage
                         where usage.assignment_id = asm.assignment_id
                         and usage.element_link_id = ell.element_link_id
                         and p_effective_start_date
                                     between usage.effective_start_date
                                         and usage.effective_end_date))
                         and nvl(ell.job_id,nvl(asm.job_id,-1))
                               = nvl(asm.job_id,-1)
 			 and nvl(ell.position_id,nvl(asm.position_id,-1))
                               = nvl(asm.position_id,-1)
                         and nvl(ell.grade_id,nvl(asm.grade_id,-1))
                               = nvl(asm.grade_id,-1)
                         and nvl(ell.location_id,nvl(asm.location_id,-1))
                               = nvl(asm.location_id,-1)
                         and nvl(ell.payroll_id,nvl(asm.payroll_id,-1))
                               = nvl(asm.payroll_id,-1)
                         and nvl(ell.employment_category,nvl(asm.employment_category,-1)) = nvl(asm.employment_category,-1)
                         and nvl(ell.pay_basis_id,nvl(asm.pay_basis_id,-1)) = nvl(asm.pay_basis_id,-1)
                         and nvl(ell.business_group_id,nvl(asm.business_group_id,-1)) = nvl(asm.business_group_id,-1)))
     AND erp.id = p_earning_policy;

   l_egp_compatible VARCHAR2(15) := NULL;

/* Check whether the Shift Differentail Policy and Assignment are compatible */
   CURSOR chk_shift_diff_policy IS
     SELECT 'compatible'
     FROM    hxt_shift_diff_policies sdp
     WHERE   p_effective_start_date between sdp.date_from
                                        and nvl(sdp.date_to
                                               ,p_effective_start_date)
     AND EXISTS
           (select 1
            from   hxt_pay_element_types_f_ddf_v v
                  ,pay_element_types_f t
                  ,hxt_shift_diff_rules r
            where r.sdp_id = sdp.id
            and p_effective_start_date between r.effective_start_date
                                           and r.effective_end_date
            and t.element_type_id = r.element_type_id
            and p_effective_start_date between t.effective_start_date
                                           and t.effective_end_date
            and asg_bus_grp_id = t.business_group_id
            and v.element_type_id = t.element_type_id
            and p_effective_start_date between v.effective_start_date
                                           and v.effective_end_date
            and v.hxt_earning_category = 'SDF')
     AND NOT EXISTS
           (select 1
            from pay_element_types_f pet
               , hxt_shift_diff_rules hsdr
            where hsdr.sdp_id = sdp.id
            and p_effective_start_date between hsdr.effective_start_date
                                           and hsdr.effective_end_date
            and pet.element_type_id = hsdr.element_type_id
            and p_effective_start_date between pet.effective_start_date
                                           and pet.effective_end_date
            and pet.business_group_id <> nvl(asg_bus_grp_id, -99))
     AND NOT EXISTS
           (select 1
            from   hxt_shift_diff_rules dr
            where  dr.sdp_id = sdp.id
            and    p_effective_start_date between dr.effective_start_date
                                              and dr.effective_end_date
            and    dr.element_type_id not in
                    (select sdr.element_type_id
                     from pay_element_links_f ell
                         ,per_assignments_f asm
                         ,hxt_shift_diff_rules sdr
                     where sdr.sdp_id = sdp.id
                     and p_effective_start_date between sdr.effective_start_date
                                                    and sdr.effective_end_date
                     and asm.assignment_id = p_assignment_id
                     and p_effective_start_date between asm.effective_start_date
                                                    and asm.effective_end_date
                     and ell.element_type_id = sdr.element_type_id
                     and p_effective_start_date between ell.effective_start_date
                                                    and ell.effective_end_date
                     and nvl(ell.organization_id, nvl(asm.organization_id,-1))
                         = nvl(asm.organization_id,-1)
                     and (ell.people_group_id is null
                           or exists
                             (select 1
                              from pay_assignment_link_usages_f usage
                              where usage.assignment_id = asm.assignment_id
                              and usage.element_link_id = ell.element_link_id
                              and p_effective_start_date
                                          between usage.effective_start_date
                                              and usage.effective_end_date))
                                and nvl(ell.job_id,nvl(asm.job_id,-1))
                                  = nvl(asm.job_id,-1)
                                and nvl(ell.position_id,nvl(asm.position_id,-1))
                                  = nvl(asm.position_id,-1)
                                and nvl(ell.grade_id,nvl(asm.grade_id,-1))
                                  = nvl(asm.grade_id,-1)
                                and nvl(ell.location_id,nvl(asm.location_id,-1))
                                  = nvl(asm.location_id,-1)
                                and nvl(ell.payroll_id,nvl(asm.payroll_id,-1))
                                  = nvl(asm.payroll_id,-1)
                                and nvl(ell.employment_category,nvl(asm.employment_category,-1))
                                  = nvl(asm.employment_category,-1)
                                and nvl(ell.pay_basis_id,nvl(asm.pay_basis_id,-1))
                                  = nvl(asm.pay_basis_id,-1)
                                and nvl(ell.business_group_id,nvl(asm.business_group_id,-1))
                                  = nvl(asm.business_group_id,-1)))
and sdp.id = p_shift_differential_policy;

 l_sdp_compatible VARCHAR2(15) := NULL;

/* Cursor to check  that Hour Deduction policy and Assignment are compatible */
 CURSOR chk_hour_deduct_policy IS
   SELECT 'compatible'
   FROM   hxt_hour_deduct_policies hdp
   WHERE  p_effective_start_date between hdp.date_from
                                     and nvl(hdp.date_to,p_effective_start_date)
   AND     nvl(hdp.business_group_id, nvl(asg_bus_grp_id, -99))
             = nvl(asg_bus_grp_id, -98)
   AND     hdp.id = p_hour_deduction_policy;

   l_hdp_compatible VARCHAR2(15) := NULL;

 CURSOR c_asg_bus_grp_id IS
   SELECT business_group_id
   FROM   per_assignments_f
   WHERE  p_effective_start_date between effective_start_date
                                     and effective_end_date
   And    assignment_type   = 'E'
   And    assignment_id     = p_assignment_id;

BEGIN

   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	  hr_utility.set_location('HXT_GEN_AAI.AAI_VALIDATIONS',10);
   end if;

/* Get the assignment business group id */
   OPEN  c_asg_bus_grp_id;
   FETCH c_asg_bus_grp_id into asg_bus_grp_id;
   CLOSE c_asg_bus_grp_id;

   if g_debug then
   	  hr_utility.trace('asg_bus_grp_id :'||asg_bus_grp_id);
   end if;

/* IF AUTOGEN_HOURS_YN is 'Y', then ROTATION_PLAN_NAME is required */
   IF p_autogen_hours_yn = 'Y' and p_rotation_plan IS NULL THEN
   --
      if g_debug then
      	     hr_utility.set_location('HXT_GEN_AAI.AAI_VALIDATIONS',20);
      end if;
   -- FND_MESSAGE.SET_NAME('HXT','HXT_39496_ROT_PLAN_REQD');
   -- FND_MESSAGE.ERROR;
      hr_utility.set_message(809, 'HXT_39496_ROT_PLAN_REQD');
      hr_utility.raise_error;
   --
   END IF;

/* Check for rotation plan */
   IF p_rotation_plan is NOT NULL THEN
      if g_debug then
     	     hr_utility.set_location('HXT_GEN_AAI.AAI_VALIDATIONS',25);
      end if;
      OPEN  chk_rot_plan;
      FETCH chk_rot_plan INTO l_rtp_compatible;
      CLOSE chk_rot_plan;
      IF l_rtp_compatible IS NULL THEN
      --
         if g_debug then
         	hr_utility.set_location('HXT_GEN_AAI.AAI_VALIDATIONS',30);
         end if;
      -- FND_MESSAGE.SET_NAME('HXT','HXT_xxxxx_ROT_PLAN_ERR');
      -- FND_MESSAGE.ERROR;
         hr_utility.set_message(809, 'HXT_xxxxx_ROT_PLAN_ERR');
         hr_utility.raise_error;
      --
      END IF;
   END IF;

/* Check whether Earning policy and Assignment are compatible */
   if g_debug then
   	  hr_utility.trace('p_assignment_id is  :'|| p_assignment_id);
          hr_utility.trace('p_earning_policy is :'|| p_earning_policy);
   end if;
   OPEN  chk_earning_policy;
   FETCH chk_earning_policy into l_egp_compatible;
   CLOSE chk_earning_policy;
   IF l_egp_compatible IS NULL THEN
   --
      if g_debug then
      	     hr_utility.set_location('HXT_GEN_AAI.AAI_VALIDATIONS',40);
      end if;
   -- FND_MESSAGE.SET_NAME('HXT','HXT_xxxxx_EARN_POL_ERR');
   -- FND_MESSAGE.ERROR;
      hr_utility.set_message(809,'HXT_xxxxx_EARN_POL_ERR');
      hr_utility.raise_error;
   --
   END IF;

/* Check whether Shift Differential Policy and Assignment are compatible */
   IF p_shift_differential_policy is NOT NULL THEN
      if g_debug then
      	     hr_utility.set_location('HXT_GEN_AAI.AAI_VALIDATIONS',45);
      end if;
      OPEN  chk_shift_diff_policy;
      FETCH chk_shift_diff_policy into l_sdp_compatible;
      CLOSE chk_shift_diff_policy;
      IF l_sdp_compatible IS NULL THEN
      --
         if g_debug then
                hr_utility.set_location('HXT_GEN_AAI.AAI_VALIDATIONS',50);
         end if;
      -- FND_MESSAGE.SET_NAME('HXT','HXT_xxxxx_SDP_ERR');
      -- FND_MESSAGE.ERROR;
         hr_utility.set_message(809,'HXT_xxxxx_SDP_ERR');
         hr_utility.raise_error;
      --
      END IF;
   END IF;

/* Check whether Hour Deduction Policy and Assignment are compatible */
   IF p_hour_deduction_policy is NOT NULL THEN
      if g_debug then
      	     hr_utility.set_location('HXT_GEN_AAI.AAI_VALIDATIONS',55);
      end if;
      OPEN  chk_hour_deduct_policy;
      FETCH chk_hour_deduct_policy into l_hdp_compatible;
      CLOSE chk_hour_deduct_policy;
      IF l_hdp_compatible IS NULL THEN
      --
         if g_debug then
         	hr_utility.set_location('HXT_GEN_AAI.AAI_VALIDATIONS',60);
         end if;
      -- FND_MESSAGE.SET_NAME('HXT','HXT_xxxxx_HDP_ERR');
      -- FND_MESSAGE.ERROR;
         hr_utility.set_message(809,'HXT_xxxxx_HDP_ERR');
         hr_utility.raise_error;
      --
      END IF;
   END IF;

END AAI_VALIDATIONS;

-------------------------------------------------------------------------------

PROCEDURE Create_Otlr_Add_Assign_Info (
  p_id                                NUMBER
 ,p_effective_start_date              DATE
--,p_effective_end_date                DATE
 ,p_assignment_id                     NUMBER
 ,p_autogen_hours_yn                  VARCHAR2
 ,p_rotation_plan                     NUMBER     DEFAULT NULL
 ,p_earning_policy                    NUMBER
 ,p_shift_differential_policy         NUMBER     DEFAULT NULL
 ,p_hour_deduction_policy             NUMBER     DEFAULT NULL
 ,p_created_by                        NUMBER
 ,p_creation_date                     DATE
 ,p_last_updated_by                   NUMBER
 ,p_last_update_date                  DATE
 ,p_last_update_login                 NUMBER
 ,p_attribute_category                VARCHAR2   DEFAULT NULL
 ,p_attribute1                        VARCHAR2   DEFAULT NULL
 ,p_attribute2                        VARCHAR2   DEFAULT NULL
 ,p_attribute3                        VARCHAR2   DEFAULT NULL
 ,p_attribute4                        VARCHAR2   DEFAULT NULL
 ,p_attribute5                        VARCHAR2   DEFAULT NULL
 ,p_attribute6                        VARCHAR2   DEFAULT NULL
 ,p_attribute7                        VARCHAR2   DEFAULT NULL
 ,p_attribute8                        VARCHAR2   DEFAULT NULL
 ,p_attribute9                        VARCHAR2   DEFAULT NULL
 ,p_attribute10                       VARCHAR2   DEFAULT NULL
 ,p_attribute11                       VARCHAR2   DEFAULT NULL
 ,p_attribute12                       VARCHAR2   DEFAULT NULL
 ,p_attribute13                       VARCHAR2   DEFAULT NULL
 ,p_attribute14                       VARCHAR2   DEFAULT NULL
 ,p_attribute15                       VARCHAR2   DEFAULT NULL
 ,p_attribute16                       VARCHAR2   DEFAULT NULL
 ,p_attribute17                       VARCHAR2   DEFAULT NULL
 ,p_attribute18                       VARCHAR2   DEFAULT NULL
 ,p_attribute19                       VARCHAR2   DEFAULT NULL
 ,p_attribute20                       VARCHAR2   DEFAULT NULL
 ,p_attribute21                       VARCHAR2   DEFAULT NULL
 ,p_attribute22                       VARCHAR2   DEFAULT NULL
 ,p_attribute23                       VARCHAR2   DEFAULT NULL
 ,p_attribute24                       VARCHAR2   DEFAULT NULL
 ,p_attribute25                       VARCHAR2   DEFAULT NULL
 ,p_attribute26                       VARCHAR2   DEFAULT NULL
 ,p_attribute27                       VARCHAR2   DEFAULT NULL
 ,p_attribute28                       VARCHAR2   DEFAULT NULL
 ,p_attribute29                       VARCHAR2   DEFAULT NULL
 ,p_attribute30                       VARCHAR2   DEFAULT NULL
 ) IS

--The purpose of this procedure is  to INSERT a row for the additional
--assignment information

--Arguments
-- Arguments
-- p_id                         -ID of the record.
-- p_effective_start_date       -effective_start_date for the record to be
--                              -inserted.
-- p_assignment_id              -id of the assignment for which the information
--                              -has to be added.
-- p_autogen_hours_yn           -The value for this argument can be either
--                              -'Y' or 'N',to specify whether to autogen
--                              -the hours for this assignment
--p_rotation_plan               -rotation_plan_id for this assignment
--p_earning_policy              -earning_policy_id for this assignment
--p_shift_differential_policy   -shift_differential_policy_id for this
--                              -assignment
--p_hour_deduction_policy       -hour_deduction_policy_id for this assignment
--p_attribute1 .. p_attribute30 -attribute values

   asg_bus_grp_id NUMBER(15);

/* Cursor to Check for the Duplicate row */
   CURSOR dup_aai IS
          SELECT '1'
          FROM   hxt_add_assign_info_f aai
          WHERE  aai.assignment_id = p_assignment_id;
   l_duplicate_row VARCHAR2(1);

/* Cursor to Create unique ID for AAI row */
   CURSOR create_unique_id IS
          SELECT  hxt_seqno.nextval
          FROM    sys.dual;
   l_id NUMBER(15);

BEGIN
   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	  hr_utility.set_location('HXT_GEN_AAI.Create_Otlr_Add_Assign_Info ',10);
   end if;

/* First, make sure AAI row doesn't already exist for this assignment */
   OPEN  dup_aai;
   FETCH dup_aai into l_duplicate_row;
      IF dup_aai%FOUND THEN
       if g_debug then
       	      hr_utility.set_location('HXT_GEN_AAI.Create_Otlr_Add_Assign_Info ',20);
       end if;
    -- FND_MESSAGE.SET_NAME('HXT','HXT_39481_INFO_EXST_FOR_ASSIGN');
    -- FND_MESSAGE.Error;
       hr_utility.set_message(809,'HXT_39481_INFO_EXST_FOR_ASSIGN');
       hr_utility.raise_error;
       CLOSE dup_aai;
      END IF;
   CLOSE dup_aai;

   if g_debug then
   	  hr_utility.set_location('HXT_GEN_AAI.Create_Otlr_Add_Assign_Info ',30);
   end if;
   HXT_GEN_AAI.AAI_VALIDATIONS
      (p_assignment_id              => p_assignment_id
      ,p_earning_policy             => p_earning_policy
      ,p_rotation_plan              => p_rotation_plan
      ,p_shift_differential_policy  => p_shift_differential_policy
      ,p_hour_deduction_policy      => p_hour_deduction_policy
      ,p_autogen_hours_yn           => p_autogen_hours_yn
      ,p_effective_start_date       => p_effective_start_date
      );
   if g_debug then
   	  hr_utility.set_location('HXT_GEN_AAI.Create_Otlr_Add_Assign_Info ',40);
   end if;

/* Create unique ID for AAI row */
   IF (p_id is null) THEN
     if g_debug then
     	    hr_utility.set_location('HXT_GEN_AAI.Create_Otlr_Add_Assign_Info ',50);
     end if;
     OPEN  create_unique_id;
     FETCH create_unique_id into l_id;
       if g_debug then
              hr_utility.trace('l_id is :'|| l_id);
       end if;
       IF create_unique_id%NOTFOUND THEN
          if g_debug then
          	 hr_utility.set_location('HXT_GEN_AAI.Create_Otlr_Add_Assign_Info ',60);
          end if;
       -- fnd_message.set_name('HXT', 'HXT_39124_ROW_IN_DUAL_NF');
       -- fnd_message.error;
          hr_utility.set_message(809,'HXT_39124_ROW_IN_DUAL_NF');
          hr_utility.raise_error;
       END IF;
     CLOSE create_unique_id;
   END IF;

   if g_debug then
   	  hr_utility.set_location('HXT_GEN_AAI.Create_Otlr_Add_Assign_Info ',70);
   end if;

   INSERT into HXT_ADD_ASSIGN_INFO_F
          (id
          ,effective_start_date
          ,effective_end_date
          ,assignment_id
          ,autogen_hours_yn
          ,rotation_plan
          ,earning_policy
          ,shift_differential_policy
          ,hour_deduction_policy
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,attribute16
          ,attribute17
          ,attribute18
          ,attribute19
          ,attribute20
          ,attribute21
          ,attribute22
          ,attribute23
          ,attribute24
          ,attribute25
          ,attribute26
          ,attribute27
          ,attribute28
          ,attribute29
          ,attribute30)
   VALUES( p_id
          ,p_effective_start_date
          ,hr_general.end_of_time --p_effective_end_date
          ,p_assignment_id
          ,p_autogen_hours_yn
          ,p_rotation_plan
          ,p_earning_policy
          ,p_shift_differential_policy
          ,p_hour_deduction_policy
          ,p_created_by
          ,p_creation_date
          ,p_last_updated_by
          ,p_last_update_date
          ,p_last_update_login
          ,p_attribute_category
          ,p_attribute1
          ,p_attribute2
          ,p_attribute3
          ,p_attribute4
          ,p_attribute5
          ,p_attribute6
          ,p_attribute7
          ,p_attribute8
          ,p_attribute9
          ,p_attribute10
          ,p_attribute11
          ,p_attribute12
          ,p_attribute13
          ,p_attribute14
          ,p_attribute15
          ,p_attribute16
          ,p_attribute17
          ,p_attribute18
          ,p_attribute19
          ,p_attribute20
          ,p_attribute21
          ,p_attribute22
          ,p_attribute23
          ,p_attribute24
          ,p_attribute25
          ,p_attribute26
          ,p_attribute27
          ,p_attribute28
          ,p_attribute29
          ,p_attribute30);

   if g_debug then
   	  hr_utility.set_location('HXT_GEN_AAI.Create_Otlr_Add_Assign_Info ',80);
   end if;

END Create_Otlr_Add_Assign_Info ;

-------------------------------------------------------------------------------

PROCEDURE Update_Otlr_Add_Assign_Info (
  p_id                         NUMBER
 ,p_datetrack_mode             VARCHAR2
 ,p_effective_date             DATE
 ,p_effective_start_date       DATE
-- ,p_effective_end_date         DATE
 ,p_assignment_id              NUMBER
 ,p_autogen_hours_yn           VARCHAR2
 ,p_rotation_plan              NUMBER     DEFAULT NULL
 ,p_earning_policy             NUMBER
 ,p_shift_differential_policy  NUMBER     DEFAULT NULL
 ,p_hour_deduction_policy      NUMBER     DEFAULT NULL
 ,p_created_by                 NUMBER
 ,p_creation_date              DATE
 ,p_last_updated_by            NUMBER
 ,p_last_update_date           DATE
 ,p_last_update_login          NUMBER
 ,p_attribute_category         VARCHAR2   DEFAULT NULL
 ,p_attribute1                 VARCHAR2   DEFAULT NULL
 ,p_attribute2                 VARCHAR2   DEFAULT NULL
 ,p_attribute3                 VARCHAR2   DEFAULT NULL
 ,p_attribute4                 VARCHAR2   DEFAULT NULL
 ,p_attribute5                 VARCHAR2   DEFAULT NULL
 ,p_attribute6                 VARCHAR2   DEFAULT NULL
 ,p_attribute7                 VARCHAR2   DEFAULT NULL
 ,p_attribute8                 VARCHAR2   DEFAULT NULL
 ,p_attribute9                 VARCHAR2   DEFAULT NULL
 ,p_attribute10                VARCHAR2   DEFAULT NULL
 ,p_attribute11                VARCHAR2   DEFAULT NULL
 ,p_attribute12                VARCHAR2   DEFAULT NULL
 ,p_attribute13                VARCHAR2   DEFAULT NULL
 ,p_attribute14                VARCHAR2   DEFAULT NULL
 ,p_attribute15                VARCHAR2   DEFAULT NULL
 ,p_attribute16                VARCHAR2   DEFAULT NULL
 ,p_attribute17                VARCHAR2   DEFAULT NULL
 ,p_attribute18                VARCHAR2   DEFAULT NULL
 ,p_attribute19                VARCHAR2   DEFAULT NULL
 ,p_attribute20                VARCHAR2   DEFAULT NULL
 ,p_attribute21                VARCHAR2   DEFAULT NULL
 ,p_attribute22                VARCHAR2   DEFAULT NULL
 ,p_attribute23                VARCHAR2   DEFAULT NULL
 ,p_attribute24                VARCHAR2   DEFAULT NULL
 ,p_attribute25                VARCHAR2   DEFAULT NULL
 ,p_attribute26                VARCHAR2   DEFAULT NULL
 ,p_attribute27                VARCHAR2   DEFAULT NULL
 ,p_attribute28                VARCHAR2   DEFAULT NULL
 ,p_attribute29                VARCHAR2   DEFAULT NULL
 ,p_attribute30                VARCHAR2   DEFAULT NULL
 ) IS

-- The purpose of this procedure is to perform 'CORRECTION' and
-- 'UPDATE_OVERRIDE' for the additional assignment information.This procedure
-- when run in an 'UPDATE_OVERRIDE' mode would override the future changes

-- Arguments
-- p_id                         - ID of the record.
-- p_datetrack_mode             -The mode in which the api has to be run.
--                              -It can be run in 'CORRECTION' or
--                              -'UPDATE_OVERRIDE' mode.
-- p_effective_date             -The record will be update das of this date.
-- p_effective_start_date       -effective_start_date of the record for this
--                              -assignment that has effective_end_date as
--                              -end_of_time.
-- p_assignment_id              -assignment_id for which the update has to be
--                              -done.
-- p_autogen_hours_yn           -The value for this argument can be either
--                              -'Y' or 'N',to specify whether to autogen
--                              -the hours for this assignment.
--p_rotation_plan               -rotation_plan_id for this assignment.
--p_earning_policy              -earning_policy_id for this assignment.
--p_shift_differential_policy   -shift_differential_policy_id for this
--                              -assignment.
--p_hour_deduction_policy       -hour_deduction_policy_id for this assignment.
--p_attribute1 .. p_attribute30 -attribute values.

 CURSOR c2 is
        SELECT rowid,effective_start_date,effective_end_date
        FROM   hxt_add_assign_info_f
        WHERE  id = p_id
        AND    effective_start_date = p_effective_start_date;

 CURSOR c_delete_rec_eot is
        SELECT rowid
        FROM   hxt_add_assign_info_f
        WHERE  id = p_id
        AND    effective_end_date = hr_general.end_of_time;


-- Bug 8327591
-- Added the below cursor to pick up the future records
-- ie. records with start date > p_effective_date

CURSOR get_future_records
    IS SELECT ROWIDTOCHAR(rowid),
              id
         FROM hxt_add_assign_info_f
        WHERE id = p_id
          AND effective_start_date > p_effective_date;



/* Cursor to Create unique ID for AAI row */
/*   CURSOR create_unique_id IS
          SELECT  hxt_seqno.nextval
          FROM    sys.dual;

   l_id      NUMBER(15);
*/
   l_effective_start_date DATE;
   l_effective_end_date   DATE;
   p_rowid                VARCHAR2(30);
   p_rowid_eot            VARCHAR2(30);
   l_count                NUMBER;

   l_datetrack_mode     VARCHAR2(50);
   TYPE VARCHARTABLE    IS TABLE OF VARCHAR2(30);
   TYPE NUMTABLE        IS TABLE OF NUMBER;

   idtab      NUMTABLE;
   rowidtab   VARCHARTABLE;



BEGIN
   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	  hr_utility.set_location('HXT_GEN_AAI.Update_Otlr_Add_Assign_Info ',10);
          hr_utility.set_location('HXT_GEN_AAI.Update_Otlr_Add_Assign_Info ',20);
   end if;

   -- Bug 8938280
   -- Validation call here is wrong, commenting this out.
   /*
   HXT_GEN_AAI.AAI_VALIDATIONS
      (p_assignment_id              => p_assignment_id
      ,p_earning_policy             => p_earning_policy
      ,p_rotation_plan              => p_rotation_plan
      ,p_shift_differential_policy  => p_shift_differential_policy
      ,p_hour_deduction_policy      => p_hour_deduction_policy
      ,p_autogen_hours_yn           => p_autogen_hours_yn
      ,p_effective_start_date       => p_effective_start_date
      );
   */

   if g_debug then
   	  hr_utility.set_location('HXT_GEN_AAI.Update_Otlr_Add_Assign_Info ',30);
   end if;

   OPEN  c2;
   FETCH c2 into p_rowid,l_effective_start_date,l_effective_end_date;
   CLOSE c2;

   -- Bug 8327591
   -- This is just a message for the users.
   IF g_debug
   THEN
      IF    p_effective_date > l_effective_end_date
         OR p_effective_date < l_effective_start_date
      THEN
         hr_utility.trace(' p_effective_date       :'||p_effective_date);
         hr_utility.trace(' l_effective_start_date :'||l_effective_start_date);
         hr_utility.trace(' l_effective_end_date   :'||l_effective_end_date);
         hr_utility.trace(' Effective Date falls outside the range '
                        ||' for the given record. Updates would be '
                        ||' done based on p_effective_date ');
      END IF;
   END IF;

   -- Bug 8327591
   -- If the effecctive_start_date coincides with the effective_date
   -- the mode is switched to CORRECTION
   IF p_effective_date = l_effective_start_date
   THEN
      l_datetrack_mode := 'CORRECTION';
   ELSE
      l_datetrack_mode := 'UPDATE_OVERRIDE';
   END IF;


   -- Bug 8327591
   -- We are no longer using this to delete the reocrds.
   /*
   OPEN  c_delete_rec_eot;
   FETCH c_delete_rec_eot  into p_rowid_eot;
   CLOSE c_delete_rec_eot;
   */

   IF p_rowid is NOT NULL THEN
      if g_debug then
      	     hr_utility.trace('effective_start_date is :'|| l_effective_start_date);
             hr_utility.trace('effective_end_date   is :'|| l_effective_end_date);
             hr_utility.trace('Rowid is :'|| p_rowid);
      end if;
     IF l_datetrack_mode = 'CORRECTION' THEN
      if g_debug then
      	     hr_utility.set_location('HXT_GEN_AAI.Update_Otlr_Add_Assign_Info ',40);
      end if;

      -- Bug 8938280
      -- Added this validation call here. Parameters are same as
      -- the commented one above.
      HXT_GEN_AAI.AAI_VALIDATIONS
         (p_assignment_id              => p_assignment_id
         ,p_earning_policy             => p_earning_policy
         ,p_rotation_plan              => p_rotation_plan
         ,p_shift_differential_policy  => p_shift_differential_policy
         ,p_hour_deduction_policy      => p_hour_deduction_policy
         ,p_autogen_hours_yn           => p_autogen_hours_yn
         ,p_effective_start_date       => p_effective_start_date
         );


       UPDATE HXT_ADD_ASSIGN_INFO_F
       SET--effective_start_date      = p_effective_start_date
          --,effective_end_date        = p_effective_end_date
          --,assignment_id             = p_assignment_id
           autogen_hours_yn          = p_autogen_hours_yn
          ,rotation_plan             = p_rotation_plan
          ,earning_policy            = p_earning_policy
          ,shift_differential_policy = p_shift_differential_policy
          ,hour_deduction_policy     = p_hour_deduction_policy
          ,created_by                = p_created_by
          ,creation_date             = p_creation_date
          ,last_updated_by           = p_last_updated_by
          ,last_update_date          = p_last_update_date
          ,last_update_login         = p_last_update_login
          ,attribute_category        = p_attribute_category
          ,attribute1                = p_attribute1
          ,attribute2                = p_attribute2
          ,attribute3                = p_attribute3
          ,attribute4                = p_attribute4
          ,attribute5                = p_attribute5
          ,attribute6                = p_attribute6
          ,attribute7                = p_attribute7
          ,attribute8                = p_attribute8
          ,attribute9                = p_attribute9
          ,attribute10               = p_attribute10
          ,attribute11               = p_attribute11
          ,attribute12               = p_attribute12
          ,attribute13               = p_attribute13
          ,attribute14               = p_attribute14
          ,attribute15               = p_attribute15
          ,attribute16               = p_attribute16
          ,attribute17               = p_attribute17
          ,attribute18               = p_attribute18
          ,attribute19               = p_attribute19
          ,attribute20               = p_attribute20
          ,attribute21               = p_attribute21
          ,attribute22               = p_attribute22
          ,attribute23               = p_attribute23
          ,attribute24               = p_attribute24
          ,attribute25               = p_attribute25
          ,attribute26               = p_attribute26
          ,attribute27               = p_attribute27
          ,attribute28               = p_attribute28
          ,attribute29               = p_attribute29
          ,attribute30               = p_attribute30
       WHERE rowid = p_rowid;

     ELSIF l_datetrack_mode = 'UPDATE_OVERRIDE' THEN
    /* end date the existing record and then create a new record if an
       existing record found */

       if g_debug then
       	      hr_utility.set_location('HXT_GEN_AAI.Update_Otlr_Add_Assign_Info ',50);
       end if;

       -- Bug 8938280
       -- Added this validation call here. Parameter for effective
       -- start date should be the passed p_effective_date.
       HXT_GEN_AAI.AAI_VALIDATIONS
          (p_assignment_id              => p_assignment_id
          ,p_earning_policy             => p_earning_policy
          ,p_rotation_plan              => p_rotation_plan
          ,p_shift_differential_policy  => p_shift_differential_policy
          ,p_hour_deduction_policy      => p_hour_deduction_policy
          ,p_autogen_hours_yn           => p_autogen_hours_yn
          ,p_effective_start_date       => p_effective_date
          );

       /*UPDATE hxt_add_assign_info_f
       SET    effective_end_date = p_effective_date - 1
       WHERE  rowid = p_rowid;
*/
       SELECT count(*) into l_count
       FROM   hxt_add_assign_info_f
       WHERE  assignment_id = p_assignment_id;


       -- Bug 8327591
       -- No longer using this condition.  Open the cursor below and follow
       -- that cursor.

       -- IF (l_count >1)  AND (p_effective_date <  p_effective_start_date) THEN
       OPEN get_future_records;

       FETCH get_future_records BULK COLLECT INTO rowidtab,
                                                  idtab;

       CLOSE get_future_records;

       IF (idtab.COUNT >0)
       THEN
          if g_debug then
          	 hr_utility.set_location('HXT_GEN_AAI.Update_Otlr_Add_Assign_Info ',60);
          end if;

          -- Bug 8327591
          -- Not required anymore.
          -- We are doing it with the below FORALL statement.
          /*
          DELETE from hxt_add_assign_info_f
          WHERE  rowid = p_rowid_eot;
          */

          FORALL i IN rowidtab.FIRST..rowidtab.LAST
            DELETE FROM hxt_add_assign_info_f
                  WHERE rowid = chartorowid(rowidtab(i));



          if g_debug then
          	 hr_utility.trace('p_effective_date is :'||p_effective_date);
          end if;

          UPDATE hxt_add_assign_info_f aai
          SET    aai.effective_end_date = p_effective_date - 1
          WHERE  aai.assignment_id = p_assignment_id
          AND    p_effective_date between aai.effective_start_date
                                     and  aai.effective_end_date;
       ELSE
          UPDATE hxt_add_assign_info_f
          SET    effective_end_date = p_effective_date - 1
          WHERE  rowid = p_rowid;
       END IF;

       if g_debug then
       	      hr_utility.set_location('HXT_GEN_AAI.Update_Otlr_Add_Assign_Info ',70);
              hr_utility.trace('p_id is :'||p_id);
       end if;

         INSERT into HXT_ADD_ASSIGN_INFO_F
           (id
           ,effective_start_date
           ,effective_end_date
           ,assignment_id
           ,autogen_hours_yn
           ,rotation_plan
           ,earning_policy
           ,shift_differential_policy
           ,hour_deduction_policy
           ,created_by
           ,creation_date
           ,last_updated_by
           ,last_update_date
           ,last_update_login
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute16
           ,attribute17
           ,attribute18
           ,attribute19
           ,attribute20
           ,attribute21
           ,attribute22
           ,attribute23
           ,attribute24
           ,attribute25
           ,attribute26
           ,attribute27
           ,attribute28
           ,attribute29
           ,attribute30)
         VALUES
           (p_id
           ,p_effective_date
           ,hr_general.end_of_time
           ,p_assignment_id
           ,p_autogen_hours_yn
           ,p_rotation_plan
           ,p_earning_policy
           ,p_shift_differential_policy
           ,p_hour_deduction_policy
           ,p_created_by
           ,p_creation_date
           ,p_last_updated_by
           ,p_last_update_date
           ,p_last_update_login
           ,p_attribute_category
           ,p_attribute1
           ,p_attribute2
           ,p_attribute3
           ,p_attribute4
           ,p_attribute5
           ,p_attribute6
           ,p_attribute7
           ,p_attribute8
           ,p_attribute9
           ,p_attribute10
           ,p_attribute11
           ,p_attribute12
           ,p_attribute13
           ,p_attribute14
           ,p_attribute15
           ,p_attribute16
           ,p_attribute17
           ,p_attribute18
           ,p_attribute19
           ,p_attribute20
           ,p_attribute21
           ,p_attribute22
           ,p_attribute23
           ,p_attribute24
           ,p_attribute25
           ,p_attribute26
           ,p_attribute27
           ,p_attribute28
           ,p_attribute29
           ,p_attribute30);

     if g_debug then
     	    hr_utility.set_location('HXT_GEN_AAI.Update_Otlr_Add_Assign_Info ',80);
     end if;

     ELSE
     /* INVALID datetrack_mode */
        hr_utility.set_message(809,'HXT_xxxxx_INVALID_DTMODE');
        hr_utility.raise_error;
     END IF;

   if g_debug then
   	  hr_utility.set_location('HXT_GEN_AAI.Update_Otlr_Add_Assign_Info ',90);
   end if;
   END IF;

END Update_Otlr_Add_Assign_Info ;

-------------------------------------------------------------------------------
--begin
--hr_utility.trace_on(null,'mhanda');

END HXT_GEN_AAI;

/
