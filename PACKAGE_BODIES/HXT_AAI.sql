--------------------------------------------------------
--  DDL for Package Body HXT_AAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_AAI" AS
/* $Header: hxtaai.pkb 115.0 99/07/16 13:38:23 porting ship $ */

procedure insert_HXT_ADD_ASSIGN_INFO(
p_rowid                      IN OUT VARCHAR2,
p_id                         NUMBER,
p_effective_start_date       DATE,
p_effective_end_date         DATE,
p_assignment_id              NUMBER,
p_autogen_hours_yn           VARCHAR2,
p_rotation_plan              NUMBER,
p_earning_policy             NUMBER,
p_shift_differential_policy  NUMBER,
p_hour_deduction_policy      NUMBER,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_attribute_category         VARCHAR2,
p_attribute1                 VARCHAR2,
p_attribute2                 VARCHAR2,
p_attribute3                 VARCHAR2,
p_attribute4                 VARCHAR2,
p_attribute5                 VARCHAR2,
p_attribute6                 VARCHAR2,
p_attribute7                 VARCHAR2,
p_attribute8                 VARCHAR2,
p_attribute9                 VARCHAR2,
p_attribute10                VARCHAR2,
p_attribute11                VARCHAR2,
p_attribute12                VARCHAR2,
p_attribute13                VARCHAR2,
p_attribute14                VARCHAR2,
p_attribute15                VARCHAR2,
p_attribute16                VARCHAR2,
p_attribute17                VARCHAR2,
p_attribute18                VARCHAR2,
p_attribute19                VARCHAR2,
p_attribute20                VARCHAR2,
p_attribute21                VARCHAR2,
p_attribute22                VARCHAR2,
p_attribute23                VARCHAR2,
p_attribute24                VARCHAR2,
p_attribute25                VARCHAR2,
p_attribute26                VARCHAR2,
p_attribute27                VARCHAR2,
p_attribute28                VARCHAR2,
p_attribute29                VARCHAR2,
p_attribute30                VARCHAR2
) is

cursor c2 is select rowid
            from   hxt_add_assign_info_f
            where  effective_start_date = p_effective_start_date
            and    effective_end_date = p_effective_end_date
            and    id = p_id;

begin

insert into HXT_ADD_ASSIGN_INFO_F(
id,
effective_start_date,
effective_end_date,
assignment_id,
autogen_hours_yn,
rotation_plan,
earning_policy,
shift_differential_policy,
hour_deduction_policy,
created_by,
creation_date,
last_updated_by,
last_update_date,
last_update_login,
attribute_category,
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
attribute30)
VALUES(
p_id,
p_effective_start_date,
p_effective_end_date,
p_assignment_id,
p_autogen_hours_yn,
p_rotation_plan,
p_earning_policy,
p_shift_differential_policy,
p_hour_deduction_policy,
p_created_by,
p_creation_date,
p_last_updated_by,
p_last_update_date,
p_last_update_login,
p_attribute_category,
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
p_attribute30);

open c2;
fetch c2 into p_rowid;
close c2;
null;

end insert_HXT_ADD_ASSIGN_INFO;


procedure update_HXT_ADD_ASSIGN_INFO(
p_rowid                      IN VARCHAR2,
p_id                         NUMBER,
p_effective_start_date       DATE,
p_effective_end_date         DATE,
p_assignment_id              NUMBER,
p_autogen_hours_yn           VARCHAR2,
p_rotation_plan              NUMBER,
p_earning_policy             NUMBER,
p_shift_differential_policy  NUMBER,
p_hour_deduction_policy      NUMBER,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_attribute_category         VARCHAR2,
p_attribute1                 VARCHAR2,
p_attribute2                 VARCHAR2,
p_attribute3                 VARCHAR2,
p_attribute4                 VARCHAR2,
p_attribute5                 VARCHAR2,
p_attribute6                 VARCHAR2,
p_attribute7                 VARCHAR2,
p_attribute8                 VARCHAR2,
p_attribute9                 VARCHAR2,
p_attribute10                VARCHAR2,
p_attribute11                VARCHAR2,
p_attribute12                VARCHAR2,
p_attribute13                VARCHAR2,
p_attribute14                VARCHAR2,
p_attribute15                VARCHAR2,
p_attribute16                VARCHAR2,
p_attribute17                VARCHAR2,
p_attribute18                VARCHAR2,
p_attribute19                VARCHAR2,
p_attribute20                VARCHAR2,
p_attribute21                VARCHAR2,
p_attribute22                VARCHAR2,
p_attribute23                VARCHAR2,
p_attribute24                VARCHAR2,
p_attribute25                VARCHAR2,
p_attribute26                VARCHAR2,
p_attribute27                VARCHAR2,
p_attribute28                VARCHAR2,
p_attribute29                VARCHAR2,
p_attribute30                VARCHAR2
) is

begin

update HXT_ADD_ASSIGN_INFO_F
set
effective_start_date = p_effective_start_date,
effective_end_date = p_effective_end_date,
assignment_id = p_assignment_id,
autogen_hours_yn = p_autogen_hours_yn,
rotation_plan = p_rotation_plan,
earning_policy = p_earning_policy,
shift_differential_policy = p_shift_differential_policy,
hour_deduction_policy = p_hour_deduction_policy,
created_by = p_created_by,
creation_date = p_creation_date,
last_updated_by = p_last_updated_by,
last_update_date = p_last_update_date,
last_update_login = p_last_update_login,
attribute_category = p_attribute_category,
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
attribute30 = p_attribute30
where rowid = p_rowid;

end update_HXT_ADD_ASSIGN_INFO;


procedure delete_HXT_ADD_ASSIGN_INFO(p_rowid VARCHAR2) is
begin
   delete from HXT_ADD_ASSIGN_INFO_F
   where rowid = chartorowid(p_rowid);
end delete_HXT_ADD_ASSIGN_INFO;

procedure lock_HXT_ADD_ASSIGN_INFO(p_rowid VARCHAR2) is
vnull number;
begin
if p_rowid is not null then
   select ASSIGNMENT_ID into vnull
   from hxt_add_assign_info_f
   where rowid = p_rowid
   for update of hxt_add_assign_info_f.ASSIGNMENT_ID nowait;

end if;
end lock_HXT_ADD_ASSIGN_INFO;

end HXT_AAI;

/
