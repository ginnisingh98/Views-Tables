--------------------------------------------------------
--  DDL for Package Body PER_GRADES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GRADES_PKG" as
/* $Header: pegrd01t.pkb 120.0 2005/05/31 09:29:18 appldev noship $ */

-- Standard insert procedure

procedure insert_row(
      p_row_id                      in out nocopy varchar2,
      p_grade_id                    in out nocopy number,
      p_business_group_id           number,
      p_grade_definition_id         number,
      p_date_from                   date,
      p_sequence                    number,
      p_comments                    varchar2,
      p_date_to                     date,
      p_name                        varchar2,
      p_request_id                  number,
      p_program_application_id      number,
      p_program_id                  number,
      p_program_update_date         date,
      p_attribute_category          varchar2,
      p_attribute1                  varchar2,
      p_attribute2                  varchar2,
      p_attribute3                  varchar2,
      p_attribute4                  varchar2,
      p_attribute5                  varchar2,
      p_attribute6                  varchar2,
      p_attribute7                  varchar2,
      p_attribute8                  varchar2,
      p_attribute9                  varchar2,
      p_attribute10                 varchar2,
      p_attribute11                 varchar2,
      p_attribute12                 varchar2,
      p_attribute13                 varchar2,
      p_attribute14                 varchar2,
      p_attribute15                 varchar2,
      p_attribute16                 varchar2,
      p_attribute17                 varchar2,
      p_attribute18                 varchar2,
      p_attribute19                 varchar2,
      p_attribute20                 varchar2,
      p_language_code               varchar2 default hr_api.userenv_lang) IS
cursor c1 is
      select per_grades_s.nextval
      from sys.dual;
cursor c2 is
      select rowid
      from per_grades
      where grade_id = p_grade_id;
begin
      open c1;
      fetch c1 into p_grade_id;
      close c1;


  BEGIn
    insert into per_grades (
      grade_id,
      business_group_id,
      grade_definition_id,
      date_from,
      sequence,
      comments,
      date_to,
      name,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
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
      attribute20)
  values (
      p_grade_id,
      p_business_group_id,
      p_grade_definition_id,
      p_date_from,
      p_sequence,
      p_comments,
      p_date_to,
      p_name,
      p_request_id,
      p_program_application_id,
      p_program_id,
      p_program_update_date,
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
      p_attribute20);

  end;

  open c2;
  fetch c2 into P_ROW_ID;
  close c2;

  --
  -- MLS Processing
  --
  per_gdt_ins.ins_tl
  (p_language_code         => p_language_code
  ,p_grade_id              => p_grade_id
  ,p_name                  => p_name
  );

end insert_row;


--standard delete procedure

procedure delete_row(p_row_id varchar2,
                     p_grd_id in number) is
begin
stbdelvl(p_grd_id);
  begin
    delete from per_grades g
    where g.rowid = chartorowid(P_ROW_ID);
  end;

  --
  -- MLS Processing
  --
  per_gdt_del.del_tl(p_grade_id  => p_grd_id);
  --

end delete_row;


--standard lock procedure

procedure lock_row (
      p_row_id                      varchar2,
      p_grade_id                    number,
      p_business_group_id           number,
      p_grade_definition_id         number,
      p_date_from                   date,
      p_sequence                    number,
      p_comments                    varchar2,
      p_date_to                     date,
      p_name                        varchar2,
      p_request_id                  number,
      p_program_application_id      number,
      p_program_id                  number,
      p_program_update_date         date,
      p_attribute_category          varchar2,
      p_attribute1                  varchar2,
      p_attribute2                  varchar2,
      p_attribute3                  varchar2,
      p_attribute4                  varchar2,
      p_attribute5                  varchar2,
      p_attribute6                  varchar2,
      p_attribute7                  varchar2,
      p_attribute8                  varchar2,
      p_attribute9                  varchar2,
      p_attribute10                 varchar2,
      p_attribute11                 varchar2,
      p_attribute12                 varchar2,
      p_attribute13                 varchar2,
      p_attribute14                 varchar2,
      p_attribute15                 varchar2,
      p_attribute16                 varchar2,
      p_attribute17                 varchar2,
      p_attribute18                 varchar2,
      p_attribute19                 varchar2,
      p_attribute20                 varchar2,
      p_language_code               varchar2 default hr_api.userenv_lang) IS

cursor OPM_CUR is
      select *
      from per_grades_vl g
      where g.row_id = chartorowid(P_ROW_ID)
      for update of grade_id nowait;

OPM_REC OPM_CUR%rowtype;

begin
  open OPM_CUR;
  fetch OPM_CUR into OPM_REC;
  close OPM_CUR;

opm_rec.attribute13 := rtrim(opm_rec.attribute13);
opm_rec.attribute14 := rtrim(opm_rec.attribute14);
opm_rec.attribute15 := rtrim(opm_rec.attribute15);
opm_rec.attribute16 := rtrim(opm_rec.attribute16);
opm_rec.attribute17 := rtrim(opm_rec.attribute17);
opm_rec.attribute18 := rtrim(opm_rec.attribute18);
opm_rec.attribute19 := rtrim(opm_rec.attribute19);
opm_rec.attribute20 := rtrim(opm_rec.attribute20);
opm_rec.comments := rtrim(opm_rec.comments);
opm_rec.name := rtrim(opm_rec.name);
opm_rec.attribute_category := rtrim(opm_rec.attribute_category);
opm_rec.attribute1 := rtrim(opm_rec.attribute1);
opm_rec.attribute2 := rtrim(opm_rec.attribute2);
opm_rec.attribute3 := rtrim(opm_rec.attribute3);
opm_rec.attribute4 := rtrim(opm_rec.attribute4);
opm_rec.attribute5 := rtrim(opm_rec.attribute5);
opm_rec.attribute6 := rtrim(opm_rec.attribute6);
opm_rec.attribute7 := rtrim(opm_rec.attribute7);
opm_rec.attribute8 := rtrim(opm_rec.attribute8);
opm_rec.attribute9 := rtrim(opm_rec.attribute9);
opm_rec.attribute10 := rtrim(opm_rec.attribute10);
opm_rec.attribute11 := rtrim(opm_rec.attribute11);
opm_rec.attribute12 := rtrim(opm_rec.attribute12);

IF (((opm_rec.grade_id = p_grade_id)
or   (opm_rec.grade_id is null
and  (p_grade_id is null)))
and ((opm_rec.business_group_id = p_business_group_id)
or   (opm_rec.business_group_id is null
and  (p_business_group_id is null)))
and ((opm_rec.grade_definition_id = p_grade_definition_id)
or   (opm_rec.grade_definition_id is null
and  (p_grade_definition_id is null)))
and ((opm_rec.date_from = p_date_from)
or   (opm_rec.date_from is null
and  (p_date_from is null)))
and ((opm_rec.sequence = p_sequence)
or   (opm_rec.sequence is null
and  (p_sequence is null)))
and ((opm_rec.comments = p_comments)
or   (opm_rec.comments is null
and  (p_comments is null)))
and ((opm_rec.date_to = p_date_to)
or   (opm_rec.date_to is null
and  (p_date_to is null)))
and ((opm_rec.name = p_name)
or   (opm_rec.name is null
and  (p_name is null)))
and ((opm_rec.request_id = p_request_id)
or   (opm_rec.request_id is null
and  (p_request_id is null)))
and ((opm_rec.program_application_id = p_program_application_id)
or   (opm_rec.program_application_id is null
and  (p_program_application_id is null)))
and ((opm_rec.program_id = p_program_id)
or   (opm_rec.program_id is null
and  (p_program_id is null)))
and ((opm_rec.program_update_date = p_program_update_date)
or   (opm_rec.program_update_date is null
and  (p_program_update_date is null)))
and ((opm_rec.attribute_category = p_attribute_category)
or   (opm_rec.attribute_category is null
and  (p_attribute_category is null)))
and ((opm_rec.attribute1 = p_attribute1)
or   (opm_rec.attribute1 is null
and  (p_attribute1 is null)))
and ((opm_rec.attribute2 = p_attribute2)
or   (opm_rec.attribute2 is null
and  (p_attribute2 is null)))
and ((opm_rec.attribute3 = p_attribute3)
or   (opm_rec.attribute3 is null
and  (p_attribute3 is null)))
and ((opm_rec.attribute4 = p_attribute4)
or   (opm_rec.attribute4 is null
and  (p_attribute4 is null)))
and ((opm_rec.attribute5 = p_attribute5)
or   (opm_rec.attribute5 is null
and  (p_attribute5 is null)))
and ((opm_rec.attribute6 = p_attribute6)
or   (opm_rec.attribute6 is null
and  (p_attribute6 is null)))
and ((opm_rec.attribute7 = p_attribute7)
or   (opm_rec.attribute7 is null
and  (p_attribute7 is null)))
and ((opm_rec.attribute8 = p_attribute8)
or   (opm_rec.attribute8 is null
and  (p_attribute8 is null)))
and ((opm_rec.attribute9 = p_attribute9)
or   (opm_rec.attribute9 is null
and  (p_attribute9 is null)))
and ((opm_rec.attribute10 = p_attribute10)
or   (opm_rec.attribute10 is null
and  (p_attribute10 is null)))
and ((opm_rec.attribute11 = p_attribute11)
or   (opm_rec.attribute11 is null
and  (p_attribute11 is null)))
and ((opm_rec.attribute12 = p_attribute12)
or   (opm_rec.attribute12 is null
and  (p_attribute12 is null)))
and ((opm_rec.attribute13 = p_attribute13)
or   (opm_rec.attribute13 is null
and  (p_attribute13 is null)))
and ((opm_rec.attribute14 = p_attribute14)
or   (opm_rec.attribute14 is null
and  (p_attribute14 is null)))
and ((opm_rec.attribute15 = p_attribute15)
or   (opm_rec.attribute15 is null
and  (p_attribute15 is null)))
and ((opm_rec.attribute16 = p_attribute16)
or   (opm_rec.attribute16 is null
and  (p_attribute16 is null)))
and ((opm_rec.attribute17 = p_attribute17)
or   (opm_rec.attribute17 is null
and  (p_attribute17 is null)))
and ((opm_rec.attribute18 = p_attribute18)
or   (opm_rec.attribute18 is null
and  (p_attribute18 is null)))
and ((opm_rec.attribute19 = p_attribute19)
or   (opm_rec.attribute19 is null
and  (p_attribute19 is null)))
and ((opm_rec.attribute20 = p_attribute20)
or   (opm_rec.attribute20 is null
and  (p_attribute20 is null))) )
THEN
  --
  -- MLS Processing
  --
  per_gdt_shd.lck (p_grade_id => p_grade_id
                  ,p_language => p_language_code);

     return;
END IF;

   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;

end lock_row;


--standard update procedure

procedure update_row(
      p_row_id                      varchar2,
      p_grade_id                    number,
      p_business_group_id           number,
      p_grade_definition_id         number,
      p_date_from                   date,
      p_sequence                    number,
      p_comments                    varchar2,
      p_date_to                     date,
      p_name                        varchar2,
      p_request_id                  number,
      p_program_application_id      number,
      p_program_id                  number,
      p_program_update_date         date,
      p_attribute_category          varchar2,
      p_attribute1                  varchar2,
      p_attribute2                  varchar2,
      p_attribute3                  varchar2,
      p_attribute4                  varchar2,
      p_attribute5                  varchar2,
      p_attribute6                  varchar2,
      p_attribute7                  varchar2,
      p_attribute8                  varchar2,
      p_attribute9                  varchar2,
      p_attribute10                 varchar2,
      p_attribute11                 varchar2,
      p_attribute12                 varchar2,
      p_attribute13                 varchar2,
      p_attribute14                 varchar2,
      p_attribute15                 varchar2,
      p_attribute16                 varchar2,
      p_attribute17                 varchar2,
      p_attribute18                 varchar2,
      p_attribute19                 varchar2,
      p_attribute20                 varchar2,
      p_language_code               varchar2 default hr_api.userenv_lang) is

begin
  update per_grades g
  set
      g.grade_id = p_grade_id,
      g.business_group_id = p_business_group_id,
      g.grade_definition_id = p_grade_definition_id,
      g.date_from = p_date_from,
      g.sequence = p_sequence,
      g.comments = p_comments,
      g.date_to = p_date_to,
      g.name = p_name,
      g.request_id = p_request_id,
      g.program_application_id = p_program_application_id,
      g.program_id = p_program_id,
      g.program_update_date = p_program_update_date,
      g.attribute_category = p_attribute_category,
      g.attribute1 = p_attribute1,
      g.attribute2 = p_attribute2,
      g.attribute3 = p_attribute3,
      g.attribute4 = p_attribute4,
      g.attribute5 = p_attribute5,
      g.attribute6 = p_attribute6,
      g.attribute7 = p_attribute7,
      g.attribute8 = p_attribute8,
      g.attribute9 = p_attribute9,
      g.attribute10 = p_attribute10,
      g.attribute11 = p_attribute11,
      g.attribute12 = p_attribute12,
      g.attribute13 = p_attribute13,
      g.attribute14 = p_attribute14,
      g.attribute15 = p_attribute15,
      g.attribute16 = p_attribute16,
      g.attribute17 = p_attribute17,
      g.attribute18 = p_attribute18,
      g.attribute19 = p_attribute19,
      g.attribute20 = p_attribute20
  where g.rowid = chartorowid(P_ROW_ID);

  --
  -- MLS Processing
  --
  per_gdt_upd.upd_tl
   (p_language_code                => p_language_code
   ,p_grade_id                     => p_grade_id
   ,p_name                         => p_name
   );

end update_row;


--deletion validation coding for block level trigger (STB_DEL_VALIDATION)
--block GRD1
--KLS 4/11/93

PROCEDURE stbdelvl (p_grd_id IN NUMBER) IS
          l_exists VARCHAR2(1);

cursor c1 is
select 'x'
FROM per_all_assignments_f
WHERE grade_id = p_grd_id;
--
cursor c2 is
select 'x'
FROM per_valid_grades
WHERE grade_id = p_grd_id;
--
cursor c3 is
select 'x'
FROM per_vacancies
WHERE grade_id = p_grd_id;
--
cursor c4 is
select 'x'
FROM pay_element_links
WHERE grade_id = p_grd_id;
--
cursor c5 is
select 'x'
FROM per_budget_elements
WHERE grade_id = p_grd_id;
--
cursor c6 is
select 'x'
FROM per_grade_spines
WHERE grade_id = p_grd_id;
--
cursor c7 is
select 'x'
FROM pay_grade_rules
WHERE grade_or_spinal_point_id = p_grd_id
AND rate_type = 'G';
--
begin
--
hr_utility.set_location('per_grades_pkg.stbdelvl',1);
--
open c1;
--
  fetch c1 into l_exists;
  IF c1%found THEN
  hr_utility.set_message(801, 'PER_7834_DEF_GRADE_DEL_ASSIGN');
  close c1;
  hr_utility.raise_error;
  END IF;
--
close c1;
--
hr_utility.set_location('per_grades_pkg.stbdelvl',2);
--
open c2;
--
  fetch c2 into l_exists;
  IF c2%found THEN
  hr_utility.set_message(801, 'HR_6443_GRADE_DEL_VALID_GRADES');
  close c2;
  hr_utility.raise_error;
  END IF;
--
close c2;
--
hr_utility.set_location('per_grades_pkg.stbdelvl',3);
--
open c3;
--
  fetch c3 into l_exists;
  IF c3%found THEN
  hr_utility.set_message(801, 'HR_6444_GRADE_DEL_VACANCIES');
  close c3;
  hr_utility.raise_error;
  END IF;
--
close c3;
--
hr_utility.set_location('per_grades_pkg.stbdelvl',4);
--
open c4;
--
  fetch c4 into l_exists;
  IF c4%found THEN
  hr_utility.set_message(801, 'HR_6446_DEL_ELE_LINKS');
  close c4;
  hr_utility.raise_error;
  END IF;
--
close c4;
--
hr_utility.set_location('per_grades_pkg.stbdelvl',5);
--
open c5;
--
  fetch c5 into l_exists;
  IF c5%found THEN
  hr_utility.set_message(801, 'HR_6447_GRADE_DEL_BUDGET_ELE');
  close c5;
  hr_utility.raise_error;
  END IF;
--
close c5;
--
hr_utility.set_location('per_grades_pkg.stbdelvl',6);
--
open c6;
--
  fetch c6 into l_exists;
  IF c6%found THEN
  hr_utility.set_message(801, 'HR_6448_GRADE_DEL_GRADE_SPINES');
  close c6;
  hr_utility.raise_error;
  END IF;
--
close c6;
--
hr_utility.set_location('per_grades_pkg.stbdelvl',7);
--
open c7;
--
  fetch c7 into l_exists;
  IF c7%found THEN
  hr_utility.set_message(801, 'HR_6684_GRADE_RULES');
  close c7;
  hr_utility.raise_error;
  END IF;
--
close c7;
--
END stbdelvl;



--procedure to deal with all post update activities on block grd1
PROCEDURE postup1 (p_seq IN NUMBER,
                  p_s_seq IN OUT NOCOPY NUMBER,
                  p_lastup IN NUMBER,
                  p_login IN NUMBER,
                  p_grd_id IN NUMBER,
                  p_bgroup IN NUMBER,
                  l_exists OUT NOCOPY VARCHAR2) IS

BEGIN
l_exists := 'N';
IF  p_seq <> p_s_seq THEN
   BEGIN
      UPDATE pay_grade_rules_f
      SET sequence = p_seq,
          last_update_date = SYSDATE,
          last_updated_by = p_lastup,
          last_update_login = p_login
      WHERE grade_or_spinal_point_id = p_grd_id
      AND rate_type = 'G';
   END;
END IF;
p_s_seq := p_seq;
 BEGIN
   SELECT 'Y'
   INTO l_exists
   FROM sys.dual
   WHERE EXISTS
     (select 'x'
      FROM per_valid_grades vg
      WHERE vg.business_group_id = p_bgroup
      AND vg.grade_id = p_grd_id);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN null;
 END;
END postup1;


PROCEDURE postup2(p_grd_id IN NUMBER,
                  p_bgroup IN NUMBER,
                  p_date_from IN DATE,
                  p_date_to IN DATE,
                  p_eot IN DATE,
                  p_date_to_old IN DATE) IS

BEGIN

   DELETE FROM per_valid_grades vg
   WHERE vg.business_group_id + 0 = p_bgroup
   AND vg.grade_id = p_grd_id
   AND vg.date_from > p_date_to;
   --
   -- Changed 12-Oct-99 SCNair (per_positions to hr_positions) Date tracked position req.
   --
   UPDATE per_valid_grades vg
   SET vg.date_to = (select least(
                            nvl(p.date_end,p_eot),
                            nvl(j.date_to,p_eot),
                            nvl(p_date_to,p_eot))
                     from hr_positions p,
                          per_jobs_v j,
                          per_valid_grades v
                     where v.valid_grade_id = vg.valid_grade_id
                     and v.position_id = p.position_id(+)
                     and v.job_id = j.job_id(+)
                    )
   WHERE vg.business_group_id + 0 = p_bgroup
   AND vg.grade_id = p_grd_id
   AND (NVL(vg.date_to,p_eot) > p_date_to
   OR vg.date_to = p_date_to_old);

   UPDATE per_valid_grades vg
   SET vg.date_to = null
   WHERE vg.date_to = p_eot
   AND vg.grade_id = p_grd_id;


END postup2;



--This procedure contains locates the grade structure that is in use by the
--current business group
--KLS 3/11/93
PROCEDURE gstruct (p_b_group IN NUMBER,
                   p_s_def_col IN OUT NOCOPY VARCHAR2) IS
l_g_str VARCHAR2(150);

cursor c10 is
SELECT a.grade_structure
FROM per_business_groups a,
     fnd_compiled_id_flexs fcf,
     fnd_id_flex_structures fif
WHERE a.business_group_id + 0 = p_b_group
AND   fcf.id_flex_code = 'GRD'
AND   fcf.application_id = fif.application_id
/* FIX for WWBUG 1523904 */
AND   to_char(fif.id_flex_num) = a.grade_structure
/* End of fix for 1523904 */
AND   UPPER(fif.dynamic_inserts_allowed_flag) = 'Y'
AND   rownum = 1;
--
begin
--
hr_utility.set_location('per_grades_pkg.gstruct',1);
--
open c10;
--
  fetch c10 into l_g_str;
  IF c10%notfound THEN
    hr_utility.set_message(801,'HR_6788_GR_NO_DYN_INS');
    close c10;
    hr_utility.raise_error;
  END IF;
--
close c10;
--
p_s_def_col := l_g_str;
--
END gstruct;



--called from post_change,pre_insert,pre_update on GRD1.DATE_FROM
--makes sure date_from of grade is not after date_from on any existing
--valid grades
PROCEDURE b_check_grade_date_from (p_grd_id IN NUMBER,p_date_from IN DATE) IS
  l_exists VARCHAR2(1);

cursor c11 is
SELECT 'x'
FROM per_valid_grades
WHERE grade_id = p_grd_id
AND p_date_from > date_from;
--
begin
--
hr_utility.set_location('per_grades_pkg.b_check_grade_date_from',1);
--
open c11;
--
  fetch c11 into l_exists;
  IF c11%found THEN
   hr_utility.set_message(801, 'PER_7808_DEF_GRADE_FIRST_VALID');
   close c11;
   hr_utility.raise_error;
   END IF;
--
close c11;
--
END b_check_grade_date_from;



PROCEDURE chk_flex_def (p_rwid IN VARCHAR2,
                        p_grd_id IN NUMBER,
                        p_bgroup_id IN NUMBER,
                        p_grdef_id IN NUMBER) IS
  l_exists VARCHAR2(1);

cursor c12 is
select 'x'
FROM per_grades p
WHERE (p.ROWID <> p_rwid OR p_rwid IS NULL)
AND (p.grade_id <> p_grd_id OR p_grd_id IS NULL)
AND p.business_group_id + 0 = p_bgroup_id
AND p.grade_definition_id = p_grdef_id;
--
begin
--
hr_utility.set_location('per_grades_pkg.chk_flex_def',1);
--
open c12;
--
  fetch c12 into l_exists;
  IF c12%found THEN
  hr_utility.set_message(801, 'PER_7830_DEF_GRADE_EXISTS');
  close c12;
  hr_utility.raise_error;
  END IF;
--
close c12;
--
END chk_flex_def;



--uniqueness check on grade name, within the business group.

PROCEDURE chk_grade (p_rwid IN VARCHAR2,
                     p_bgroup_id IN NUMBER,
                     p_seg IN VARCHAR2,
                     p_popid OUT NOCOPY VARCHAR2,
                     p_fail OUT NOCOPY BOOLEAN) IS

cursor c14 is
SELECT 'Y'
FROM per_grades p
WHERE (p_rwid IS NULL OR p_rwid <> p.ROWID)
AND p_bgroup_id = p.business_group_id + 0
AND p_seg = p.name;
--
begin
--
hr_utility.set_location('per_grades_pkg.chk_grade',1);
--
open c14;
--
  fetch c14 into p_popid;
  IF c14%found THEN
  p_fail := TRUE;
  END IF;
--
close c14;
--
END chk_grade;


procedure old_date_to(p_grd_id IN NUMBER,
		      p_old_date IN OUT NOCOPY DATE) is

cursor c15 is
select date_to
from per_grades
where grade_id = p_grd_id;
--
begin
--
hr_utility.set_location('per_grades_pkg.old_date_to',1);
--
open c15;
--
  fetch c15 into p_old_date;
--
close c15;
--
end old_date_to;



procedure chk_seq(p_rwid in varchar2,
                  p_bgroup in number,
                  p_seq in number) is
l_exists varchar2(1);

cursor c16 is
select 'x'
from per_grades g
where g.sequence = p_seq
and g.business_group_id + 0 = p_bgroup
and (p_rwid is null or chartorowid(p_rwid) <> g.rowid);
--
begin
--
hr_utility.set_location('per_grades_pkg.chk_seq',1);
--
open c16;
--
  fetch c16 into l_exists;
  IF c16%found THEN
  hr_utility.set_message(801,'HR_7127_GRADE_DUP_SEQ');
  close c16;
  hr_utility.raise_error;
  END IF;
--
close c16;
--
end chk_seq;

procedure chk_date_from(p_grade_id in number,
                        p_date_from in date) is
l_exists varchar2(1);

-- bug 4024588.
-- cursor modified to fetch only grade rate records from
-- pay_grade_rules_f table.

cursor chk_grd_dt_from is
select 'x' from pay_grade_rules_f p
where p.grade_or_spinal_point_id = p_grade_id
and p.rate_type='G'  -- Bug fix 4024588
and p.effective_start_date < nvl(p_date_from, hr_api.g_sot);
--
begin
--
hr_utility.set_location('per_grades_pkg.chk_date_from', 1);
--
open chk_grd_dt_from;
fetch chk_grd_dt_from into l_exists;
IF chk_grd_dt_from%found THEN
  hr_utility.set_message(800, 'PER_289567_GRADE_DATE_FROM');
  close chk_grd_dt_from;
  hr_utility.raise_error;
END IF;
--
close chk_grd_dt_from;
--
end chk_date_from;


procedure chk_end_date(p_grade_id in number,
                       p_date_to in date) is
l_exists varchar2(1);

cursor chk_grd_dt_to is
select 'x' from pay_grade_rules_f p
where p.grade_or_spinal_point_id = p_grade_id
and p.rate_type='G'  -- Bug fix 3360504. Type check added.
and p.effective_end_date > nvl(p_date_to, hr_api.g_eot);

-- Bug fix 3360504 starts here
-- cursor to check whether any grade steps exist after the
-- end date.
cursor chk_grade_scale is
 select 'x' from per_grade_spines_f pgs
 where pgs.grade_id = p_grade_id
 and pgs.effective_end_date > nvl(p_date_to, hr_api.g_eot);


--
begin
--
hr_utility.set_location('per_grades_pkg.chk_end_date', 1);
--
open chk_grd_dt_to;
fetch chk_grd_dt_to into l_exists;
IF chk_grd_dt_to%found THEN
  hr_utility.set_message(800, 'PER_289568_GRADE_DATE_TO');
  close chk_grd_dt_to;
  hr_utility.raise_error;
END IF;
--
close chk_grd_dt_to;
--
-- Bug fix 3360504 starts here.
-- code to check whether grade scale exist.
open chk_grade_scale;
fetch chk_grade_scale into l_exists;
if chk_grade_scale%found then
    hr_utility.set_message(800, 'PER_449143_GRADE_SCALE_DATE_TO');
    close chk_grade_scale;
    hr_utility.raise_error;
end if;
close  chk_grade_scale;
--
-- bug fix 3360504 ends here

end chk_end_date;

end PER_GRADES_PKG;

/
