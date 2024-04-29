--------------------------------------------------------
--  DDL for Package Body PER_MM_VALID_GRADES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MM_VALID_GRADES_PKG" as
/* $Header: pemmv04t.pkb 120.0.12010000.2 2008/08/06 09:16:03 ubhat ship $ */
--
--
procedure insert_row
         (p_mass_move_id in number,
          p_position_id in number,
          p_target_grade_id in number,
          p_attribute_category in varchar2,
          p_attribute1 in varchar2,
          p_attribute2 in varchar2,
          p_attribute3 in varchar2,
          p_attribute4 in varchar2,
          p_attribute5 in varchar2,
          p_attribute6 in varchar2,
          p_attribute7 in varchar2,
          p_attribute8 in varchar2,
          p_attribute9 in varchar2,
          p_attribute10 in varchar2,
          p_attribute11 in varchar2,
          p_attribute12 in varchar2,
          p_attribute13 in varchar2,
          p_attribute14 in varchar2,
          p_attribute15 in varchar2,
          p_attribute16 in varchar2,
          p_attribute17 in varchar2,
          p_attribute18 in varchar2,
          p_attribute19 in varchar2,
          p_attribute20 in varchar2)

 is
  cursor c is
    select 'x'
      from
       per_mm_valid_grades
     where mass_move_id = p_mass_move_id;
  l_dummy varchar(1);

  begin
    insert into per_mm_valid_grades
         (mass_move_id,
          position_id,
          target_grade_id,
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
     values
         (p_mass_move_id,
          p_position_id,
          p_target_grade_id,
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
    open c;
    fetch c into l_dummy;
    if (c%notfound) then
      close c;
      raise no_data_found;
    end if;
    close c;
end insert_row;
--
--
procedure update_row
          (p_target_grade_id in number,
          p_attribute1 in varchar2,
          p_attribute2 in varchar2,
          p_attribute3 in varchar2,
          p_attribute4 in varchar2,
          p_attribute5 in varchar2,
          p_attribute6 in varchar2,
          p_attribute7 in varchar2,
          p_attribute8 in varchar2,
          p_attribute9 in varchar2,
          p_attribute10 in varchar2,
          p_attribute11 in varchar2,
          p_attribute12 in varchar2,
          p_attribute13 in varchar2,
          p_attribute14 in varchar2,
          p_attribute15 in varchar2,
          p_attribute16 in varchar2,
          p_attribute17 in varchar2,
          p_attribute18 in varchar2,
          p_attribute19 in varchar2,
          p_attribute20 in varchar2,
          p_row_id in varchar2)
is
    begin
      update per_mm_valid_grades
       set
         target_grade_id = p_target_grade_id,
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
          attribute20 = p_attribute20
       where rowid = p_row_id;
    if (sql%notfound) then
      raise no_data_found;
    end if;
end update_row;
--
--
procedure delete_row
            (p_row_id in varchar2)

is
    begin
      delete from per_mm_valid_grades
         where rowid = p_row_id;
    if (sql%notfound) then
      raise no_data_found;
    end if;
end delete_row;
--
--
procedure load_rows
                 (p_mass_move_id in number)
is
l_effective_date per_mass_moves.effective_date%type;

BEGIN
hr_utility.set_location('Inside Load_rows. before insert ',10);
-- added for 7214283
select effective_date into l_effective_date
 from per_mass_moves where mass_move_id = p_mass_move_id;
-- added for 7214283

     insert into per_mm_valid_grades
         (MASS_MOVE_ID,
          position_id,
          TARGET_GRADE_ID,
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
         ATTRIBUTE20
          )
     select
         p_mass_move_id,
         mmpos.position_id,
         vgr.GRADE_ID,
         vgr.ATTRIBUTE_CATEGORY,
         vgr.ATTRIBUTE1,
         vgr.ATTRIBUTE2,
         vgr.ATTRIBUTE3,
         vgr.ATTRIBUTE4,
         vgr.ATTRIBUTE5,
         vgr.ATTRIBUTE6,
         vgr.ATTRIBUTE7,
         vgr.ATTRIBUTE8,
         vgr.ATTRIBUTE9,
         vgr.ATTRIBUTE10,
         vgr.ATTRIBUTE11,
         vgr.ATTRIBUTE12,
         vgr.ATTRIBUTE13,
         vgr.ATTRIBUTE14,
         vgr.ATTRIBUTE15,
         vgr.ATTRIBUTE16,
         vgr.ATTRIBUTE17,
         vgr.ATTRIBUTE18,
         vgr.ATTRIBUTE19,
         vgr.ATTRIBUTE20
      from per_valid_grades vgr,
            per_mm_positions mmpos
      where vgr.position_id = mmpos.position_id
        and mmpos.mass_move_id = p_mass_move_id
	and l_effective_date between vgr.date_from and vgr.date_to; -- This condition added for 7214283

	hr_utility.set_location('Load_rows. After insert',20);

    exception
       when no_data_found THEN
         hr_utility.set_location(' Inside No data found ',30);
         null;
       when others THEN
         hr_utility.set_location('Inside Others ',40);
         hr_utility.set_location(sqlerrm,50);
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','per_mm_valid_grades_pkg.load_rows');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;
    end load_rows;
--
--
procedure lock_row
         (p_mass_move_id in number,
          p_position_id in number,
          p_target_grade_id in number,
          p_attribute_category in varchar2,
          p_attribute1 in varchar2,
          p_attribute2 in varchar2,
          p_attribute3 in varchar2,
          p_attribute4 in varchar2,
          p_attribute5 in varchar2,
          p_attribute6 in varchar2,
          p_attribute7 in varchar2,
          p_attribute8 in varchar2,
          p_attribute9 in varchar2,
          p_attribute10 in varchar2,
          p_attribute11 in varchar2,
          p_attribute12 in varchar2,
          p_attribute13 in varchar2,
          p_attribute14 in varchar2,
          p_attribute15 in varchar2,
          p_attribute16 in varchar2,
          p_attribute17 in varchar2,
          p_attribute18 in varchar2,
          p_attribute19 in varchar2,
          p_attribute20 in varchar2,
          p_row_id in varchar2)

 is
    counter number;
    cursor c is
      select *
        from per_mm_valid_grades
       where rowid = p_row_id
         for update of target_grade_id nowait;
    recinfo c%rowtype;
  begin
    counter := 0;
    loop
      begin
        counter := counter + 1;
        open c;
        fetch c into recinfo;
        if (c%notfound) then
          close c;
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','per_mm_valid_grades_pkg.lock_rows');
          hr_utility.set_message_token('STEP','1');
          hr_utility.raise_error;
        end if;
        close c;
        if  (
              (recinfo.mass_move_id = p_mass_move_id)
            AND
              (recinfo.position_id = p_position_id)
            AND
              (recinfo.target_grade_id = p_target_grade_id)
            AND(
                (recinfo.attribute1 = p_attribute1)
                 OR (    (recinfo.attribute1 is null)
                   AND (p_attribute1 is null)))
            AND(
              (recinfo.attribute2 = p_attribute2)
                 OR (    (recinfo.attribute2 is null)
                   AND (p_attribute2 is null)))
            AND(
              (recinfo.attribute3 = p_attribute3)
                 OR (    (recinfo.attribute3 is null)
                   AND (p_attribute3 is null)))
            AND(
              (recinfo.attribute4 = p_attribute4)
                 OR (    (recinfo.attribute4 is null)
                   AND (p_attribute4 is null)))
            AND(
              (recinfo.attribute5 = p_attribute5)
                 OR (    (recinfo.attribute5 is null)
                   AND (p_attribute5 is null)))
            AND(
              (recinfo.attribute6 = p_attribute6)
                 OR (    (recinfo.attribute6 is null)
                   AND (p_attribute6 is null)))
            AND(
              (recinfo.attribute7 = p_attribute7)
                 OR (    (recinfo.attribute7 is null)
                   AND (p_attribute7 is null)))
            AND(
              (recinfo.attribute8 = p_attribute8)
                 OR (    (recinfo.attribute8 is null)
                   AND (p_attribute8 is null)))
            AND(
              (recinfo.attribute9 = p_attribute9)
                 OR (    (recinfo.attribute9 is null)
                   AND (p_attribute9 is null)))
            AND(
              (recinfo.attribute10 = p_attribute10)
                 OR (    (recinfo.attribute10 is null)
                   AND (p_attribute10 is null)))
            AND(
              (recinfo.attribute11 = p_attribute11)
                 OR (    (recinfo.attribute11 is null)
                   AND (p_attribute11 is null)))
            AND(
              (recinfo.attribute12 = p_attribute12)
                 OR (    (recinfo.attribute12 is null)
                   AND (p_attribute12 is null)))
            AND(
              (recinfo.attribute13 = p_attribute13)
                 OR (    (recinfo.attribute13 is null)
                   AND (p_attribute13 is null)))
            AND(
              (recinfo.attribute14 = p_attribute14)
                 OR (    (recinfo.attribute14 is null)
                   AND (p_attribute14 is null)))
            AND(
              (recinfo.attribute15 = p_attribute15)
                 OR (    (recinfo.attribute15 is null)
                   AND (p_attribute15 is null)))
            AND(
              (recinfo.attribute16 = p_attribute16)
                 OR (    (recinfo.attribute16 is null)
                   AND (p_attribute16 is null)))
            AND(
              (recinfo.attribute17 = p_attribute17)
                 OR (    (recinfo.attribute17 is null)
                   AND (p_attribute17 is null)))
            AND(
              (recinfo.attribute18 = p_attribute18)
                 OR (    (recinfo.attribute18 is null)
                   AND (p_attribute18 is null)))
            AND(
              (recinfo.attribute19 = p_attribute19)
                 OR (    (recinfo.attribute19 is null)
                   AND (p_attribute19 is null)))
            AND(
              (recinfo.attribute20 = p_attribute20)
                 OR (    (recinfo.attribute20 is null)
                   AND (p_attribute20 is null)))
            ) then
            return;
        else
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','per_mm_valid_grades_pkg.lock_rows');
          hr_utility.set_message_token('STEP','2');
          hr_utility.raise_error;
        end if;
      exception
        when app_exceptions.record_lock_exception then
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','per_mm_valid_grades_pkg.lock_rows');
          hr_utility.set_message_token('STEP','3');
          hr_utility.raise_error;
      end;
    end loop;
end lock_row ;
--
--
end per_mm_valid_grades_pkg;


/
