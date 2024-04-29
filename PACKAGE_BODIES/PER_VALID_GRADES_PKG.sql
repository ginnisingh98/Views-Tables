--------------------------------------------------------
--  DDL for Package Body PER_VALID_GRADES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VALID_GRADES_PKG" as
/* $Header: pevgr01t.pkb 115.2 2004/01/13 05:17:03 bsubrama ship $ */
--
procedure get_grade(p_grade_id in  number,
          p_grade in out nocopy varchar2) is
--
cursor c1 is select name
        from   per_grades
        where p_grade_id = grade_id;
--
begin
  --
  -- Retrieve the grade name
  --
    open c1;
    fetch c1 into p_grade;
    if (C1%NOTFOUND) then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','get_grade');
       hr_utility.set_message_token('STEP','1');
    end if;
    close c1;
    --
    hr_utility.set_location('PER_VALID_GRADES_PKG.get_grade', 1);
    --
end get_grade;
--
procedure get_next_sequence(p_valid_grade_id in out nocopy number) is
--
cursor c1 is select per_valid_grades_s.nextval
        from sys.dual;
--
begin
  --
  -- Retrieve the next sequence number for valid_grade_id
  --
  if (p_valid_grade_id is null) then
    open c1;
    fetch c1 into p_valid_grade_id;
    if (C1%NOTFOUND) then
       CLOSE C1;
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','get_next_sequence');
       hr_utility.set_message_token('STEP','1');
    end if;
    close c1;
  end if;
    --
    hr_utility.set_location('PER_VALID_GRADES_PKG.get_next_sequence', 1);
    --
end get_next_sequence;
--
PROCEDURE check_unique_grade(
   p_business_group_id       in number,
   p_job_id                  in number,
   p_grade_id                in number,
   p_rowid                   in varchar2,
   p_date_from               in date,                  -- Bug 3338072
   p_date_to                 in date default null) is  -- Bug 3338072
--

cursor csr_grade is
   select null
   from   per_valid_grades vg
   where  ((p_rowid is not null and
   rowidtochar(rowid) <> p_rowid)
   or  p_rowid is null)
   and vg.business_group_id + 0 = p_business_group_id
   and vg.job_id = p_job_id
   and vg.grade_id = p_grade_id
-- Bug 3338072 Start
   and (p_date_from between
   vg.date_from and nvl(vg.date_to,hr_api.g_eot) or
   p_date_to between
   vg.date_from and nvl(vg.date_to,hr_api.g_eot));
 -- Bug 3338072 End

--
g_dummy_number number;
v_not_unique   boolean := FALSE;
--
-- Check the grade name is unique
--
begin
  --
  open csr_grade;
  fetch csr_grade into g_dummy_number;
  v_not_unique := csr_grade%FOUND;
  close csr_grade;
  --
  if v_not_unique then
    hr_utility.set_message(801,'PER_7818_DEF_JOB_GRD_EXISTS');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_VALID_GRADES_PKG.check_unique_grade', 1);
  --
end check_unique_grade;
--
PROCEDURE check_date_from(p_grade_id        number,
           p_date_from       date) is
--
cursor csr_grade_date is select g.date_from
         from per_grades g
         where g.grade_id  = p_grade_id
         and   p_date_from < g.date_from;
--
g_dummy_date date;
v_date_greater boolean := FALSE;
--
-- Check that date_from of valid grade must be after the date_from of
-- the job and grade
--
begin
   --
   open csr_grade_date;
   fetch csr_grade_date into g_dummy_date;
   v_date_greater := csr_grade_date%FOUND;
   close csr_grade_date;
   --
   if v_date_greater then
     hr_utility.set_message(801,'PER_7821_DEF_JOB_GRD_START_GRD');
     hr_utility.set_message_token('DATE', g_dummy_date);
     hr_utility.raise_error;
   end if;
   --
   hr_utility.set_location('PER_VALID_GRADES_PKG.check_date_from', 1);
   --
end check_date_from;
--
PROCEDURE check_date_to(p_grade_id        number,
         p_date_to         date,
         p_end_of_time     date) is
--
cursor csr_grade_date is select nvl(g.date_to, p_end_of_time)
         from per_grades g
         where g.grade_id  = p_grade_id
         and   nvl(p_date_to, p_end_of_time) >
          nvl(g.date_to, p_end_of_time);
--
g_dummy_date date;
v_date_greater boolean := FALSE;
--
-- Check that date_to of valid grade is after date_to in per_grades
--
begin
   --
   open csr_grade_date;
   fetch csr_grade_date into g_dummy_date;
   v_date_greater := csr_grade_date%FOUND;
   close csr_grade_date;
   --
   if v_date_greater then
     hr_utility.set_message(801,'PER_7872_DEF_GRD_POS_END_POS');
     hr_utility.set_message_token('DATE', g_dummy_date);
     hr_utility.raise_error;
   end if;
   --
   hr_utility.set_location('PER_VALID_GRADES_PKG.check_date_to', 1);
   --
end check_date_to;
--
END PER_VALID_GRADES_PKG;

/
