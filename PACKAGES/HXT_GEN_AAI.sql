--------------------------------------------------------
--  DDL for Package HXT_GEN_AAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_GEN_AAI" AUTHID CURRENT_USER AS
/* $Header: hxtgenai.pkh 115.3 2003/09/09 09:55:53 mhanda ship $ */

------------------------------------------------------------------------------

PROCEDURE AAI_VALIDATIONS
     (p_assignment_id              NUMBER
     ,p_earning_policy             NUMBER
     ,p_rotation_plan              NUMBER
     ,p_shift_differential_policy  NUMBER
     ,p_hour_deduction_policy      NUMBER
     ,p_autogen_hours_yn           VARCHAR2
     ,p_effective_start_date       DATE
     );

------------------------------------------------------------------------------

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

PROCEDURE Create_Otlr_Add_Assign_Info
     (p_id                         NUMBER
     ,p_effective_start_date       DATE
  -- ,p_effective_end_date         DATE
     ,p_assignment_id              NUMBER
     ,p_autogen_hours_yn           VARCHAR2
     ,p_rotation_plan              NUMBER      DEFAULT NULL
     ,p_earning_policy             NUMBER
     ,p_shift_differential_policy  NUMBER      DEFAULT NULL
     ,p_hour_deduction_policy      NUMBER      DEFAULT NULL
     ,p_created_by                 NUMBER
     ,p_creation_date              DATE
     ,p_last_updated_by            NUMBER
     ,p_last_update_date           DATE
     ,p_last_update_login          NUMBER
     ,p_attribute_category         VARCHAR2    DEFAULT NULL
     ,p_attribute1                 VARCHAR2    DEFAULT NULL
     ,p_attribute2                 VARCHAR2    DEFAULT NULL
     ,p_attribute3                 VARCHAR2    DEFAULT NULL
     ,p_attribute4                 VARCHAR2    DEFAULT NULL
     ,p_attribute5                 VARCHAR2    DEFAULT NULL
     ,p_attribute6                 VARCHAR2    DEFAULT NULL
     ,p_attribute7                 VARCHAR2    DEFAULT NULL
     ,p_attribute8                 VARCHAR2    DEFAULT NULL
     ,p_attribute9                 VARCHAR2    DEFAULT NULL
     ,p_attribute10                VARCHAR2    DEFAULT NULL
     ,p_attribute11                VARCHAR2    DEFAULT NULL
     ,p_attribute12                VARCHAR2    DEFAULT NULL
     ,p_attribute13                VARCHAR2    DEFAULT NULL
     ,p_attribute14                VARCHAR2    DEFAULT NULL
     ,p_attribute15                VARCHAR2    DEFAULT NULL
     ,p_attribute16                VARCHAR2    DEFAULT NULL
     ,p_attribute17                VARCHAR2    DEFAULT NULL
     ,p_attribute18                VARCHAR2    DEFAULT NULL
     ,p_attribute19                VARCHAR2    DEFAULT NULL
     ,p_attribute20                VARCHAR2    DEFAULT NULL
     ,p_attribute21                VARCHAR2    DEFAULT NULL
     ,p_attribute22                VARCHAR2    DEFAULT NULL
     ,p_attribute23                VARCHAR2    DEFAULT NULL
     ,p_attribute24                VARCHAR2    DEFAULT NULL
     ,p_attribute25                VARCHAR2    DEFAULT NULL
     ,p_attribute26                VARCHAR2    DEFAULT NULL
     ,p_attribute27                VARCHAR2    DEFAULT NULL
     ,p_attribute28                VARCHAR2    DEFAULT NULL
     ,p_attribute29                VARCHAR2    DEFAULT NULL
     ,p_attribute30                VARCHAR2    DEFAULT NULL
     );

------------------------------------------------------------------------------

-- The purpose of this procedure is to perform 'CORRECTION' and
-- 'UPDATE_OVERRIDE' for the additional assignment information.This procedure
-- when run in an 'UPDATE_OVERRIDE' mode would override the future changes

-- Arguments
-- p_id                         - ID of the record.
-- p_datetrack_mode             -The mode in which the api has to be run.
--                              -It can be run in 'CORRECTION' or
--                              -'UPDATE_OVERRIDE' mode.
-- p_effective_date             -The record will be updated as of this date.
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

PROCEDURE Update_Otlr_Add_Assign_Info
    (p_id                         NUMBER
    ,p_datetrack_mode             VARCHAR2
    ,p_effective_date             DATE
    ,p_effective_start_date       DATE
  --,p_effective_end_date         DATE
    ,p_assignment_id              NUMBER
    ,p_autogen_hours_yn           VARCHAR2
    ,p_rotation_plan              NUMBER         DEFAULT NULL
    ,p_earning_policy             NUMBER
    ,p_shift_differential_policy  NUMBER         DEFAULT NULL
    ,p_hour_deduction_policy      NUMBER         DEFAULT NULL
    ,p_created_by                 NUMBER
    ,p_creation_date              DATE
    ,p_last_updated_by            NUMBER
    ,p_last_update_date           DATE
    ,p_last_update_login          NUMBER
    ,p_attribute_category         VARCHAR2       DEFAULT NULL
    ,p_attribute1                 VARCHAR2       DEFAULT NULL
    ,p_attribute2                 VARCHAR2       DEFAULT NULL
    ,p_attribute3                 VARCHAR2       DEFAULT NULL
    ,p_attribute4                 VARCHAR2       DEFAULT NULL
    ,p_attribute5                 VARCHAR2       DEFAULT NULL
    ,p_attribute6                 VARCHAR2       DEFAULT NULL
    ,p_attribute7                 VARCHAR2       DEFAULT NULL
    ,p_attribute8                 VARCHAR2       DEFAULT NULL
    ,p_attribute9                 VARCHAR2       DEFAULT NULL
    ,p_attribute10                VARCHAR2       DEFAULT NULL
    ,p_attribute11                VARCHAR2       DEFAULT NULL
    ,p_attribute12                VARCHAR2       DEFAULT NULL
    ,p_attribute13                VARCHAR2       DEFAULT NULL
    ,p_attribute14                VARCHAR2       DEFAULT NULL
    ,p_attribute15                VARCHAR2       DEFAULT NULL
    ,p_attribute16                VARCHAR2       DEFAULT NULL
    ,p_attribute17                VARCHAR2       DEFAULT NULL
    ,p_attribute18                VARCHAR2       DEFAULT NULL
    ,p_attribute19                VARCHAR2       DEFAULT NULL
    ,p_attribute20                VARCHAR2       DEFAULT NULL
    ,p_attribute21                VARCHAR2       DEFAULT NULL
    ,p_attribute22                VARCHAR2       DEFAULT NULL
    ,p_attribute23                VARCHAR2       DEFAULT NULL
    ,p_attribute24                VARCHAR2       DEFAULT NULL
    ,p_attribute25                VARCHAR2       DEFAULT NULL
    ,p_attribute26                VARCHAR2       DEFAULT NULL
    ,p_attribute27                VARCHAR2       DEFAULT NULL
    ,p_attribute28                VARCHAR2       DEFAULT NULL
    ,p_attribute29                VARCHAR2       DEFAULT NULL
    ,p_attribute30                VARCHAR2       DEFAULT NULL
    );

------------------------------------------------------------------------------

END HXT_GEN_AAI;

 

/
