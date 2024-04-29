--------------------------------------------------------
--  DDL for Package Body PER_SIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SIT_PKG" as
/* $Header: pesit01t.pkb 115.3 2004/06/15 01:00:26 vanantha ship $ */
--
  -- Constants to define Special Information Type Categories
  -- used by this package
  --
  G_JOB       varchar2(10) := 'JOB';
  G_POSITION  varchar2(10) := 'POS';
  G_SKILL     varchar2(10) := 'SKILL';
  G_OTHER     varchar2(10) := 'OTHER';
  G_OSHA      varchar2(10) := 'OSHA';
  G_ADA       varchar2(10) := 'ADA';
--
----------------------------------------------------------------------
-- check_unique_sit
--
--    Ensures that the Special Info Type is unique within the Business Group
----------------------------------------------------------------------
--
procedure check_unique_sit(p_special_information_type_id in number
                          ,p_bg_id                       in number
                          ,p_id_flex_num                 in number) is
cursor c is
select 'x'
from per_special_info_types
where  id_flex_num = p_id_flex_num
and   (p_special_information_type_id is null or
      (p_special_information_type_id is not null and
       special_information_type_id <> p_special_information_type_id))
and    business_group_id  = p_bg_id;
--
l_exists varchar2(1);
begin
hr_utility.set_location('per_sit_pkg.check_unique_sit',1);
   open c;
   fetch c into l_exists;
   if c%found then
      close c;
      hr_utility.set_message(801,'PER_7836_DEF_FUR_EXISTS');
      hr_utility.raise_error;
   end if;
   close c;
end check_unique_sit;
--
--
----------------------------------------------------------------------
-- sit_flex_used
--
--    Determines whether the Flex Structure has been used in Personal
--    Analyses
----------------------------------------------------------------------
--
function sit_flex_used(p_bg_id number
                      ,p_id_flex_num number) return boolean is
cursor c is
select 'x'
from    per_person_analyses pa,
        per_special_info_types c
where   pa.id_flex_num       = c.id_flex_num
and     pa.business_group_id  = p_bg_id
and     c.business_group_id   = pa.business_group_id
and     pa.id_flex_num       = p_id_flex_num;  --bug 3648683
--
l_exists varchar2(1);
begin
hr_utility.set_location('per_sit_pkg.sit_flex_used',1);
   open c;
   fetch c into l_exists;
   if c%found then
      close c;
      return(TRUE);
   else
      close c;
      return(FALSE);
   end if;
end sit_flex_used;
--
--
----------------------------------------------------------------------
-- sit_del_validation
--
--      Delete Validation
----------------------------------------------------------------------
--
procedure sit_del_validation(p_bg_id number
                            ,p_id_flex_num number) is
begin
hr_utility.set_location('per_sit_pkg.sit_del_validation',1);
   if sit_flex_used(p_bg_id
                   ,p_id_flex_num) then
      hr_utility.set_message(801,'PER_7837_DEF_FUR_IN_USE');
      hr_utility.raise_error;
   end if;
end sit_del_validation;
--
--
----------------------------------------------------------------------
-- populate_fields
--
--      POST-QUERY population of non-base table fields
----------------------------------------------------------------------
--
procedure populate_fields(p_id_flex_num number
                         ,p_name IN OUT NOCOPY varchar2
                         ,p_flex_enabled IN OUT NOCOPY varchar2) is
cursor c is
select  id_flex_structure_name
,       enabled_flag
from    fnd_id_flex_structures_vl
where   id_flex_code = 'PEA'
and     id_flex_num = p_id_flex_num;
--
begin
hr_utility.set_location('per_sit_pkg.populate_fields',1);
   open c;
   fetch c into p_name, p_flex_enabled;
   close c;
end populate_fields;
--
--
----------------------------------------------------------------------
-- get_special_info_type_id
--
--       Retrives next UNIQUE ID
----------------------------------------------------------------------
--
function get_special_info_type_id return number is
l_id number;
cursor c is
select per_special_info_types_s.nextval
from sys.dual;
--
begin
   open c;
   fetch c into l_id;
   close c;
   return(l_id);
end;
--
----------------------------------------------------------------------
-- ins_sit
--
--       Inserts a record into PER_SPECIAL_INFO_TYPES
----------------------------------------------------------------------
--
procedure ins_sit (p_SPECIAL_INFORMATION_TYPE_ID     in out nocopy NUMBER,
                   p_BUSINESS_GROUP_ID               in NUMBER,
                   p_ID_FLEX_NUM                     in NUMBER,
                   p_COMMENTS                        in VARCHAR2,
                   p_ENABLED_FLAG                    in VARCHAR2,
                   p_REQUEST_ID                      in NUMBER,
                   p_PROGRAM_APPLICATION_ID          in NUMBER,
                   p_PROGRAM_ID                      in NUMBER,
                   p_PROGRAM_UPDATE_DATE             in DATE,
                   p_ATTRIBUTE_CATEGORY              in VARCHAR2,
                   p_ATTRIBUTE1                      in VARCHAR2,
                   p_ATTRIBUTE2                      in VARCHAR2,
                   p_ATTRIBUTE3                      in VARCHAR2,
                   p_ATTRIBUTE4                      in VARCHAR2,
                   p_ATTRIBUTE5                      in VARCHAR2,
                   p_ATTRIBUTE6                      in VARCHAR2,
                   p_ATTRIBUTE7                      in VARCHAR2,
                   p_ATTRIBUTE8                      in VARCHAR2,
                   p_ATTRIBUTE9                      in VARCHAR2,
                   p_ATTRIBUTE10                     in VARCHAR2,
                   p_ATTRIBUTE11                     in VARCHAR2,
                   p_ATTRIBUTE12                     in VARCHAR2,
                   p_ATTRIBUTE13                     in VARCHAR2,
                   p_ATTRIBUTE14                     in VARCHAR2,
                   p_ATTRIBUTE15                     in VARCHAR2,
                   p_ATTRIBUTE16                     in VARCHAR2,
                   p_ATTRIBUTE17                     in VARCHAR2,
                   p_ATTRIBUTE18                     in VARCHAR2,
                   p_ATTRIBUTE19                     in VARCHAR2,
                   p_ATTRIBUTE20                     in VARCHAR2,
                   p_MULTIPLE_OCCURRENCES_FLAG       in VARCHAR2) is
--
begin
--
  check_unique_sit(p_special_information_type_id => null
                  ,p_bg_id => p_business_group_id
                  ,p_id_flex_num => p_id_flex_num);
  --
  p_special_information_type_id := get_special_info_type_id;
  --
  insert into per_special_info_types
   (SPECIAL_INFORMATION_TYPE_ID,
    BUSINESS_GROUP_ID,
    ID_FLEX_NUM,
    COMMENTS,
    ENABLED_FLAG,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    MULTIPLE_OCCURRENCES_FLAG)
  values
   (p_SPECIAL_INFORMATION_TYPE_ID,
    p_BUSINESS_GROUP_ID,
    p_ID_FLEX_NUM,
    p_COMMENTS,
    p_ENABLED_FLAG,
    p_REQUEST_ID,
    p_PROGRAM_APPLICATION_ID,
    p_PROGRAM_ID,
    p_PROGRAM_UPDATE_DATE,
    p_ATTRIBUTE_CATEGORY,
    p_ATTRIBUTE1,
    p_ATTRIBUTE2,
    p_ATTRIBUTE3,
    p_ATTRIBUTE4,
    p_ATTRIBUTE5,
    p_ATTRIBUTE6,
    p_ATTRIBUTE7,
    p_ATTRIBUTE8,
    p_ATTRIBUTE9,
    p_ATTRIBUTE10,
    p_ATTRIBUTE11,
    p_ATTRIBUTE12,
    p_ATTRIBUTE13,
    p_ATTRIBUTE14,
    p_ATTRIBUTE15,
    p_ATTRIBUTE16,
    p_ATTRIBUTE17,
    p_ATTRIBUTE18,
    p_ATTRIBUTE19,
    p_ATTRIBUTE20,
    p_MULTIPLE_OCCURRENCES_FLAG);
--
end;

----------------------------------------------------------------------
-- upd_sit
--
--       Updates a record into PER_SPECIAL_INFO_TYPES
----------------------------------------------------------------------
--
procedure upd_sit (p_SPECIAL_INFORMATION_TYPE_ID     in NUMBER,
                   p_BUSINESS_GROUP_ID               in NUMBER,
                   p_ID_FLEX_NUM                     in NUMBER,
                   p_COMMENTS                        in VARCHAR2,
                   p_ENABLED_FLAG                    in VARCHAR2,
                   p_REQUEST_ID                      in NUMBER,
                   p_PROGRAM_APPLICATION_ID          in NUMBER,
                   p_PROGRAM_ID                      in NUMBER,
                   p_PROGRAM_UPDATE_DATE             in DATE,
                   p_ATTRIBUTE_CATEGORY              in VARCHAR2,
                   p_ATTRIBUTE1                      in VARCHAR2,
                   p_ATTRIBUTE2                      in VARCHAR2,
                   p_ATTRIBUTE3                      in VARCHAR2,
                   p_ATTRIBUTE4                      in VARCHAR2,
                   p_ATTRIBUTE5                      in VARCHAR2,
                   p_ATTRIBUTE6                      in VARCHAR2,
                   p_ATTRIBUTE7                      in VARCHAR2,
                   p_ATTRIBUTE8                      in VARCHAR2,
                   p_ATTRIBUTE9                      in VARCHAR2,
                   p_ATTRIBUTE10                     in VARCHAR2,
                   p_ATTRIBUTE11                     in VARCHAR2,
                   p_ATTRIBUTE12                     in VARCHAR2,
                   p_ATTRIBUTE13                     in VARCHAR2,
                   p_ATTRIBUTE14                     in VARCHAR2,
                   p_ATTRIBUTE15                     in VARCHAR2,
                   p_ATTRIBUTE16                     in VARCHAR2,
                   p_ATTRIBUTE17                     in VARCHAR2,
                   p_ATTRIBUTE18                     in VARCHAR2,
                   p_ATTRIBUTE19                     in VARCHAR2,
                   p_ATTRIBUTE20                     in VARCHAR2,
                   p_MULTIPLE_OCCURRENCES_FLAG       in VARCHAR2) is
--
begin
--
  check_unique_sit
     (p_special_information_type_id => p_special_information_type_id
     ,p_bg_id => p_business_group_id
     ,p_id_flex_num => p_id_flex_num);
  --
  update per_special_info_types
  set BUSINESS_GROUP_ID              = p_BUSINESS_GROUP_ID,
      ID_FLEX_NUM                    = p_ID_FLEX_NUM,
      COMMENTS                       = p_COMMENTS,
      ENABLED_FLAG                   = p_ENABLED_FLAG,
      REQUEST_ID                     = p_REQUEST_ID,
      PROGRAM_APPLICATION_ID         = p_PROGRAM_APPLICATION_ID,
      PROGRAM_ID                     = p_PROGRAM_ID,
      PROGRAM_UPDATE_DATE            = p_PROGRAM_UPDATE_DATE,
      ATTRIBUTE_CATEGORY             = p_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1                     = p_ATTRIBUTE1,
      ATTRIBUTE2                     = p_ATTRIBUTE2,
      ATTRIBUTE3                     = p_ATTRIBUTE3,
      ATTRIBUTE4                     = p_ATTRIBUTE4,
      ATTRIBUTE5                     = p_ATTRIBUTE5,
      ATTRIBUTE6                     = p_ATTRIBUTE6,
      ATTRIBUTE7                     = p_ATTRIBUTE7,
      ATTRIBUTE8                     = p_ATTRIBUTE8,
      ATTRIBUTE9                     = p_ATTRIBUTE9,
      ATTRIBUTE10                    = p_ATTRIBUTE10,
      ATTRIBUTE11                    = p_ATTRIBUTE11,
      ATTRIBUTE12                    = p_ATTRIBUTE12,
      ATTRIBUTE13                    = p_ATTRIBUTE13,
      ATTRIBUTE14                    = p_ATTRIBUTE14,
      ATTRIBUTE15                    = p_ATTRIBUTE15,
      ATTRIBUTE16                    = p_ATTRIBUTE16,
      ATTRIBUTE17                    = p_ATTRIBUTE17,
      ATTRIBUTE18                    = p_ATTRIBUTE18,
      ATTRIBUTE19                    = p_ATTRIBUTE19,
      ATTRIBUTE20                    = p_ATTRIBUTE20,
      MULTIPLE_OCCURRENCES_FLAG      = p_MULTIPLE_OCCURRENCES_FLAG
  where SPECIAL_INFORMATION_TYPE_ID = p_special_information_type_id;
--
end;
--
----------------------------------------------------------------------
-- lck
--
--       Locks a record into PER_SPECIAL_INFO_TYPES
----------------------------------------------------------------------
--
Procedure lck (p_special_information_type_id  in number) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select SPECIAL_INFORMATION_TYPE_ID
    from  per_special_info_types
    where SPECIAL_INFORMATION_TYPE_ID = p_SPECIAL_INFORMATION_TYPE_ID
    for	update nowait;
--
  l_dummy number;
Begin
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into l_dummy;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'per_spcial_info_types');
    hr_utility.raise_error;
End lck;
--
----------------------------------------------------------------------
-- add_usage
--
--       Inserts a record into PER_SPECIAL_INFO_TYPE_USAGES for the
--       given type and category if the associated flag has been set
--       and the record does not already exist
----------------------------------------------------------------------
--
procedure add_usage (p_special_information_type_id in number,
                     p_category_flag               in varchar2,
                     p_special_info_category       in varchar2) is
begin
--
  if p_category_flag = 'Y' then
  --
    insert into per_special_info_type_usages
                  (special_information_type_id,
                   special_info_category)
    select p_special_information_type_id,
           p_special_info_category
    from dual
    where not exists
            (select null
             from per_special_info_type_usages
             where special_information_type_id = p_special_information_type_id
               and special_info_category = p_special_info_category);
  --
  end if;
--
end;

----------------------------------------------------------------------
-- reset_usages
--
--       Removes any records in PER_SPECIAL_INFO_TYPE_USAGES which have
--       had their associated flag reset
--       Calls add_usage to insert any new usages for each category
--
----------------------------------------------------------------------
--
procedure reset_usages (p_special_information_type_id in number,
                        p_job_category                in varchar2,
                        p_position_category           in varchar2,
                        p_skill_category              in varchar2,
                        p_other_category              in varchar2,
                        p_osha_category               in varchar2,
                        p_ada_category                in varchar2) is
--
begin
--
  delete from per_special_info_type_usages
  where special_information_type_id = p_special_information_type_id
  and (
       (special_info_category = G_JOB      and p_job_category = 'N') or
       (special_info_category = G_POSITION and p_position_category = 'N') or
       (special_info_category = G_SKILL    and p_skill_category = 'N') or
       (special_info_category = G_OTHER    and p_other_category = 'N') or
       (special_info_category = G_OSHA     and p_osha_category = 'N') or
       (special_info_category = G_ADA      and p_ada_category = 'N')
      );
  --
  add_usage (p_special_information_type_id => p_special_information_type_id,
             p_category_flag               => p_job_category,
             p_special_info_category       => G_JOB);
  --
  add_usage (p_special_information_type_id => p_special_information_type_id,
             p_category_flag               => p_position_category,
             p_special_info_category       => G_POSITION);
  --
  add_usage (p_special_information_type_id => p_special_information_type_id,
             p_category_flag               => p_skill_category,
             p_special_info_category       => G_SKILL);
  --
  add_usage (p_special_information_type_id => p_special_information_type_id,
             p_category_flag               => p_other_category,
             p_special_info_category       => G_OTHER);
  --
  add_usage (p_special_information_type_id => p_special_information_type_id,
             p_category_flag               => p_osha_category,
             p_special_info_category       => G_OSHA);
  --
  add_usage (p_special_information_type_id => p_special_information_type_id,
             p_category_flag               => p_ada_category,
             p_special_info_category       => G_ADA);
  --
--
end;

----------------------------------------------------------------------
-- delete_usages
--
--       Deletes all records from PER_SPECIAL_INFO_TYPE_USAGES for a type
----------------------------------------------------------------------
--
procedure delete_usages (p_special_information_type_id in number) is
begin
--
  delete from per_special_info_type_usages
  where special_information_type_id = p_special_information_type_id;
--
end;

----------------------------------------------------------------------
-- del_sit
--
--       Deletes a record from PER_SPECIAL_INFO_TYPES
--       Calls delete_usages to also delete associated category usages
----------------------------------------------------------------------
--
procedure del_sit (p_special_information_type_id in number) is
begin
--
  delete_usages (p_special_information_type_id);
  --
  delete from per_special_info_types
  where special_information_type_id = p_special_information_type_id;
--
end;

----------------------------------------------------------------------
-- sit in use
--
-- checks if a special info types in a given category are in use
-- used in the check that a type can be reverted back to not being in a
-- category
--
----------------------------------------------------------------------
--
function sit_in_use (p_business_group_id in number,
                     p_id_flex_num in number,
                     p_category    in varchar2) return boolean is
--
  cursor c_job_requirement is
    select 'X'
    from per_analysis_criteria ac
    ,    per_job_requirements jr
    where ac.id_flex_num = p_id_flex_num
      and jr.analysis_criteria_id = ac.analysis_criteria_id
      and jr.business_group_id  = p_business_group_id   --bug 3648683
      and jr.job_id is not null;
--
  cursor c_position_requirement is
    select 'X'
    from per_analysis_criteria ac
    ,    per_job_requirements jr
    where ac.id_flex_num = p_id_flex_num
      and jr.analysis_criteria_id = ac.analysis_criteria_id
      and jr.business_group_id  = p_business_group_id  --bug 3648683
      and jr.position_id is not null;
--
  cursor c_osha_analyses is
    select 'X'
    from per_person_analyses pa
    where pa.id_flex_num = p_id_flex_num
      and pa.business_group_id = p_business_group_id
      and exists (select null
                  from pay_legislation_rules pl
                  where pl.rule_type = 'OSHA'
                    and pl.rule_mode = to_char(pa.id_flex_num));
--
  cursor c_ada_analyses is
    select 'X'
    from per_person_analyses pa
    where pa.id_flex_num = p_id_flex_num
      and pa.business_group_id = p_business_group_id
      and exists (select null
                  from pay_legislation_rules pl
                  where pl.rule_type in ('ADA_DIS_ACC','ADA_DIS')
                    and pl.rule_mode = to_char(pa.id_flex_num));
--
  cursor c_other_analyses is
    select 'X'
    from per_person_analyses pa
    where pa.id_flex_num = p_id_flex_num
      and pa.business_group_id = p_business_group_id
      and not exists (select null
                      from pay_legislation_rules pl
                      where pl.rule_type in ('OSHA','ADA_DIS_ACC','ADA_DIS')
                        and pl.rule_mode = to_char(pa.id_flex_num));
--
  l_result boolean;
  l_dummy  varchar2(1);
--
begin
--
  if p_category = G_JOB then
  --
    open c_job_requirement;
    fetch c_job_requirement into l_dummy;
    l_result := c_job_requirement%FOUND;
    close c_job_requirement;
  --
  elsif p_category = G_POSITION then
  --
    open c_position_requirement;
    fetch c_position_requirement into l_dummy;
    l_result := c_position_requirement%FOUND;
    close c_position_requirement;
  --
  elsif p_category = G_OSHA then
  --
    open c_osha_analyses;
    fetch c_osha_analyses into l_dummy;
    l_result := c_osha_analyses%FOUND;
    close c_osha_analyses;
  --
  elsif p_category = G_ADA then
  --
    open c_ada_analyses;
    fetch c_ada_analyses into l_dummy;
    l_result := c_ada_analyses%FOUND;
    close c_ada_analyses;
  --
  elsif p_category = G_OTHER then
  --
    open c_other_analyses;
    fetch c_other_analyses into l_dummy;
    l_result := c_other_analyses%FOUND;
    close c_other_analyses;
  --
  else
  --
    l_result := false;
  --
  end if;
  --
  Return l_result;
  --
end;

END PER_SIT_PKG;

/
