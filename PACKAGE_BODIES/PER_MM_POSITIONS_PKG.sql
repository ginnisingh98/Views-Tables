--------------------------------------------------------
--  DDL for Package Body PER_MM_POSITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MM_POSITIONS_PKG" as
/* $Header: pemmv02t.pkb 115.4 99/10/18 20:38:09 porting shi $ */
--
--
procedure update_row
             (p_select_position in varchar2,
              p_default_from in varchar2,
              p_deactivate_old_position in varchar2,
              p_new_position_definition_id in number,
              p_new_position_id in number,
              p_target_job_id in number,
              p_segment1 in varchar2,
              p_segment2 in varchar2,
              p_segment3 in varchar2,
              p_segment4 in varchar2,
              p_segment5 in varchar2,
              p_segment6 in varchar2,
              p_segment7 in varchar2,
              p_segment8 in varchar2,
              p_segment9 in varchar2,
              p_segment10 in varchar2,
              p_segment11 in varchar2,
              p_segment12 in varchar2,
              p_segment13 in varchar2,
              p_segment14 in varchar2,
              p_segment15 in varchar2,
              p_segment16 in varchar2,
              p_segment17 in varchar2,
              p_segment18 in varchar2,
              p_segment19 in varchar2,
              p_segment20 in varchar2,
              p_segment21 in varchar2,
              p_segment22 in varchar2,
              p_segment23 in varchar2,
              p_segment24 in varchar2,
              p_segment25 in varchar2,
              p_segment26 in varchar2,
              p_segment27 in varchar2,
              p_segment28 in varchar2,
              p_segment29 in varchar2,
              p_segment30 in varchar2,
              p_row_id in varchar2)

is
    begin
      update per_mm_positions
         set select_position         = p_select_position,
             default_from            = p_default_from,
             deactivate_old_position = p_deactivate_old_position,
            new_position_definition_id = p_new_position_definition_id,
             new_position_id         = p_new_position_id,
             target_job_id           = p_target_job_id,
             segment1                = p_segment1,
             segment2                = p_segment2,
             segment3                = p_segment3,
             segment4                = p_segment4,
             segment5                = p_segment5,
             segment6                = p_segment6,
             segment7                = p_segment7,
             segment8                = p_segment8,
             segment9                = p_segment9,
             segment10               = p_segment10,
             segment11               = p_segment11,
             segment12               = p_segment12,
             segment13               = p_segment13,
             segment14               = p_segment14,
             segment15               = p_segment15,
             segment16               = p_segment16,
             segment17               = p_segment17,
             segment18               = p_segment18,
             segment19               = p_segment19,
             segment20               = p_segment20,
             segment21               = p_segment21,
             segment22               = p_segment22,
             segment23               = p_segment23,
             segment24               = p_segment24,
             segment25               = p_segment25,
             segment26               = p_segment26,
             segment27               = p_segment27,
             segment28               = p_segment28,
             segment29               = p_segment29,
             segment30               = p_segment30
       where rowid = p_row_id;
    if (sql%notfound) then
      raise no_data_found;
    end if;

  exception
       when others then
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','per_mm_positions_pkg.update_rows');
          hr_utility.set_message_token('STEP','1');
          hr_utility.raise_error;
end update_row;
--
--
procedure load_rows
                 (p_mass_move_id in number,
                   p_business_group_id in number,
                   p_source_organization in varchar2,
                   p_session_date in date,
                   p_end_of_time in date,
                   p_position_name in varchar2,
                   p_job_name in varchar2,
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

  l_dummy varchar2(1);

  cursor c is
    select 'x'
      from
       per_mm_positions mmpos
     where mmpos.mass_move_id = p_mass_move_id;

  begin
    insert into per_mm_positions
        (MASS_MOVE_ID,
         POSITION_ID,
         OBJECT_VERSION_NUMBER,
         DEFAULT_FROM,
         DEACTIVATE_OLD_POSITION,
         SELECT_POSITION,
         POSITION_MOVED)
    select
         p_mass_move_id,
         pos.position_id,
         pos.object_version_number,
         'P',
         'N',
         'N',
         'N'
      from hr_positions pos,
           per_organization_units org,
           per_jobs job
     where pos.job_id = job.job_id
       and pos.organization_id = org.organization_id
       and p_session_date between
           pos.date_effective and
           nvl(pos.date_end,p_end_of_time)
       and pos.business_group_id = p_business_group_id
       and org.name = p_source_organization
       and job.name like nvl(p_job_name, job.name)
       and pos.name like nvl(p_position_name, pos.name)
       and ((p_attribute_category is not null and p_attribute_category = pos.attribute_category)
            or
            (p_attribute_category is null))
       and ((p_attribute1 is not null and p_attribute1 = pos.attribute1)
            or
            (p_attribute1 is null))
       and ((p_attribute2 is not null and p_attribute2 = pos.attribute2)
            or
            (p_attribute2 is null))
       and ((p_attribute3 is not null and p_attribute3 = pos.attribute3)
            or
            (p_attribute3 is null))
       and ((p_attribute4 is not null and p_attribute4 = pos.attribute4)
            or
            (p_attribute4 is null))
       and ((p_attribute5 is not null and p_attribute5 = pos.attribute5)
            or
            (p_attribute5 is null))
       and ((p_attribute6 is not null and p_attribute6 = pos.attribute6)
            or
            (p_attribute6 is null))
       and ((p_attribute7 is not null and p_attribute7 = pos.attribute7)
            or
            (p_attribute7 is null))
       and ((p_attribute8 is not null and p_attribute8 = pos.attribute8)
            or
            (p_attribute8 is null))
       and ((p_attribute9 is not null and p_attribute9 = pos.attribute9)
            or
            (p_attribute9 is null))
       and ((p_attribute10 is not null and p_attribute10 = pos.attribute10)
            or
            (p_attribute10 is null))
       and ((p_attribute11 is not null and p_attribute11 = pos.attribute11)
            or
            (p_attribute11 is null))
       and ((p_attribute12 is not null and p_attribute12 = pos.attribute12)
            or
            (p_attribute12 is null))
       and ((p_attribute13 is not null and p_attribute13 = pos.attribute13)
            or
            (p_attribute13 is null))
       and ((p_attribute14 is not null and p_attribute14 = pos.attribute14)
            or
            (p_attribute14 is null))
       and ((p_attribute15 is not null and p_attribute15 = pos.attribute15)
            or
            (p_attribute15 is null))
       and ((p_attribute16 is not null and p_attribute16 = pos.attribute16)
            or
            (p_attribute16 is null))
       and ((p_attribute17 is not null and p_attribute17 = pos.attribute17)
            or
            (p_attribute17 is null))
       and ((p_attribute18 is not null and p_attribute18 = pos.attribute18)
            or
            (p_attribute18 is null))
       and ((p_attribute19 is not null and p_attribute19 = pos.attribute19)
            or
            (p_attribute19 is null))
       and ((p_attribute20 is not null and p_attribute20 = pos.attribute20)
            or
            (p_attribute20 is null))
              ;
       -- Bug#885806. DBMS_OUTPUT.PUT_LINE calls were replaced with HR_UTILITY.TRACE calls
         -- dbms_output.put_line(sqlcode);
         -- dbms_output.put_line(sqlerrm);
         hr_utility.trace(sqlcode);
         hr_utility.trace(sqlerrm);
       open c;
    fetch c into l_dummy;
    if (c%notfound) then
      close c;
      raise no_data_found;
    end if;
    close c;
       -- Bug#885806. DBMS_OUTPUT.PUT_LINE calls were replaced with HR_UTILITY.TRACE calls
         -- dbms_output.put_line(sqlcode);
         -- dbms_output.put_line(sqlerrm);
         hr_utility.trace(sqlcode);
         hr_utility.trace(sqlerrm);
    exception
       when no_data_found then
          hr_utility.set_message(801,'HR_51384_MMV_NO_POS_FOR_ORG');
          hr_utility.raise_error;
       when others then
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','per_mm_positions_pkg.load_rows');
         hr_utility.set_message_token('STEP','1');
         -- Bug#885806.
         -- hr_utility.raise_error;
         -- dbms_output.put_line(sqlcode);
         -- dbms_output.put_line(sqlerrm);
         raise_application_error(sqlcode,sqlerrm);
   end load_rows;
--
--
procedure lock_row
             (p_mass_move_id in number,
              p_position_id in number,
              p_select_position in varchar2,
              p_default_from in varchar2,
              p_deactivate_old_position in varchar2,
              p_new_position_definition_id in number,
              p_new_position_id in number,
              p_target_job_id in number,
              p_segment1 in varchar2,
              p_segment2 in varchar2,
              p_segment3 in varchar2,
              p_segment4 in varchar2,
              p_segment5 in varchar2,
              p_segment6 in varchar2,
              p_segment7 in varchar2,
              p_segment8 in varchar2,
              p_segment9 in varchar2,
              p_segment10 in varchar2,
              p_segment11 in varchar2,
              p_segment12 in varchar2,
              p_segment13 in varchar2,
              p_segment14 in varchar2,
              p_segment15 in varchar2,
              p_segment16 in varchar2,
              p_segment17 in varchar2,
              p_segment18 in varchar2,
              p_segment19 in varchar2,
              p_segment20 in varchar2,
              p_segment21 in varchar2,
              p_segment22 in varchar2,
              p_segment23 in varchar2,
              p_segment24 in varchar2,
              p_segment25 in varchar2,
              p_segment26 in varchar2,
              p_segment27 in varchar2,
              p_segment28 in varchar2,
              p_segment29 in varchar2,
              p_segment30 in varchar2,
              p_row_id in varchar2)

 is
    counter number;
    cursor c is
      select *
        from per_mm_positions
       where rowid = p_row_id
         for update of select_position nowait;
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
          hr_utility.set_message_token('PROCEDURE','per_mm_positions_pkg.lock_rows');
          hr_utility.set_message_token('STEP','1');
          hr_utility.raise_error;
        end if;
        close c;
        if  (
              (recinfo.mass_move_id = p_mass_move_id)
            AND
              (recinfo.position_id = p_position_id)
            AND
              (recinfo.default_from = p_default_from)
            AND(
                (recinfo.deactivate_old_position = p_deactivate_old_position)
                 OR (    (recinfo.deactivate_old_position is null)
                   AND (p_deactivate_old_position is null)))
            AND(
                (recinfo.select_position = p_select_position)
                 OR (    (recinfo.select_position is null)
                   AND (p_select_position is null)))
            AND(
                (recinfo.new_position_id = p_new_position_id)
                 OR (    (recinfo.new_position_id is null)
                   AND (p_new_position_id is null)))
            AND(
                (recinfo.new_position_definition_id = p_new_position_definition_id)
                 OR (    (recinfo.new_position_definition_id is null)
                   AND (p_new_position_definition_id is null)))
            AND(
                (recinfo.segment1 = p_segment1)
                 OR (    (recinfo.segment1 is null)
                   AND (p_segment1 is null)))
            AND(
              (recinfo.segment2 = p_segment2)
                 OR (    (recinfo.segment2 is null)
                   AND (p_segment2 is null)))
            AND(
              (recinfo.segment3 = p_segment3)
                 OR (    (recinfo.segment3 is null)
                   AND (p_segment3 is null)))
            AND(
              (recinfo.segment4 = p_segment4)
                 OR (    (recinfo.segment4 is null)
                   AND (p_segment4 is null)))
            AND(
              (recinfo.segment5 = p_segment5)
                 OR (    (recinfo.segment5 is null)
                   AND (p_segment5 is null)))
            AND(
              (recinfo.segment6 = p_segment6)
                 OR (    (recinfo.segment6 is null)
                   AND (p_segment6 is null)))
            AND(
              (recinfo.segment7 = p_segment7)
                 OR (    (recinfo.segment7 is null)
                   AND (p_segment7 is null)))
            AND(
              (recinfo.segment8 = p_segment8)
                 OR (    (recinfo.segment8 is null)
                   AND (p_segment8 is null)))
            AND(
              (recinfo.segment9 = p_segment9)
                 OR (    (recinfo.segment9 is null)
                   AND (p_segment9 is null)))
            AND(
              (recinfo.segment10 = p_segment10)
                 OR (    (recinfo.segment10 is null)
                   AND (p_segment10 is null)))
            AND(
              (recinfo.segment11 = p_segment11)
                 OR (    (recinfo.segment11 is null)
                   AND (p_segment11 is null)))
            AND(
              (recinfo.segment12 = p_segment12)
                 OR (    (recinfo.segment12 is null)
                   AND (p_segment12 is null)))
            AND(
              (recinfo.segment13 = p_segment13)
                 OR (    (recinfo.segment13 is null)
                   AND (p_segment13 is null)))
            AND(
              (recinfo.segment14 = p_segment14)
                 OR (    (recinfo.segment14 is null)
                   AND (p_segment14 is null)))
            AND(
              (recinfo.segment15 = p_segment15)
                 OR (    (recinfo.segment15 is null)
                   AND (p_segment15 is null)))
            AND(
              (recinfo.segment16 = p_segment16)
                 OR (    (recinfo.segment16 is null)
                   AND (p_segment16 is null)))
            AND(
              (recinfo.segment17 = p_segment17)
                 OR (    (recinfo.segment17 is null)
                   AND (p_segment17 is null)))
            AND(
              (recinfo.segment18 = p_segment18)
                 OR (    (recinfo.segment18 is null)
                   AND (p_segment18 is null)))
            AND(
              (recinfo.segment19 = p_segment19)
                 OR (    (recinfo.segment19 is null)
                   AND (p_segment19 is null)))
            AND(
              (recinfo.segment20 = p_segment20)
                 OR (    (recinfo.segment20 is null)
                   AND (p_segment20 is null)))
            AND(
              (recinfo.segment21 = p_segment21)
                 OR (    (recinfo.segment21 is null)
                   AND (p_segment21 is null)))
            AND(
              (recinfo.segment22 = p_segment22)
                 OR (    (recinfo.segment22 is null)
                   AND (p_segment22 is null)))
            AND(
              (recinfo.segment23 = p_segment23)
                 OR (    (recinfo.segment23 is null)
                   AND (p_segment23 is null)))
            AND(
              (recinfo.segment24 = p_segment24)
                 OR (    (recinfo.segment24 is null)
                   AND (p_segment24 is null)))
            AND(
              (recinfo.segment25 = p_segment25)
                 OR (    (recinfo.segment25 is null)
                   AND (p_segment25 is null)))
            AND(
              (recinfo.segment26 = p_segment26)
                 OR (    (recinfo.segment26 is null)
                   AND (p_segment26 is null)))
            AND(
              (recinfo.segment27 = p_segment27)
                 OR (    (recinfo.segment27 is null)
                   AND (p_segment27 is null)))
            AND(
              (recinfo.segment28 = p_segment28)
                 OR (    (recinfo.segment28 is null)
                   AND (p_segment28 is null)))
            AND(
              (recinfo.segment29 = p_segment29)
                 OR (    (recinfo.segment29 is null)
                   AND (p_segment29 is null)))
            AND(
              (recinfo.segment30 = p_segment30)
                 OR (    (recinfo.segment30 is null)
                   AND (p_segment30 is null)))
            ) then
            return;
        else
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','per_mm_positions_pkg.lock_rows');
          hr_utility.set_message_token('STEP','2');
          hr_utility.raise_error;
        end if;
      exception
         when app_exceptions.record_lock_exception then
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','per_mm_positions_pkg.lock_rows');
          hr_utility.set_message_token('STEP','3');
          hr_utility.raise_error;
      end;
    end loop;
  end lock_row ;
--
--
procedure chk_org
         (p_new_organization_id in number,
          p_new_position_definition_id in number)

  is

   l_dummy number(15);

   cursor c is
      select pos.organization_id
        from hr_positions pos
        where p_new_position_definition_id = pos.position_definition_id
        and pos.organization_id <> p_new_organization_id;

  begin
    open c;
    fetch c into l_dummy;
    if (c%found) then
        close c;
        hr_utility.set_message(801,'HR_51330_MMV_POS_EXISTS');
        hr_utility.raise_error;
    end if;
    close c;

end chk_org;
--
--
procedure get_job
         (p_new_position_definition_id in number,
          p_organization_id out number,
          p_new_position_id out number,
          p_target_job_name out varchar2,
          p_target_job_id out number,
          p_target_job_definition_id out number)

  is

   cursor c is
       select pos.organization_id,
              pos.position_id,
              job.name,
              job.job_id,
              job.job_definition_id
       from   hr_positions pos,
              per_jobs job
       where  p_new_position_definition_id = pos.position_definition_id
       and    pos.job_id = job.job_id;

   l_organization_id number(15);
   l_new_position_id number(15);
   l_target_job_name varchar2(240);
   l_target_job_id number(15);
   l_target_job_definition_id number(15);

  begin
    open c;
    fetch c into l_organization_id,
                 l_new_position_id ,
                 l_target_job_name,
                 l_target_job_id,
                 l_target_job_definition_id;
    if (c%found) then
        close c;
        p_organization_id := l_organization_id;
        p_new_position_id := l_new_position_id;
        p_target_job_name := l_target_job_name;
        p_target_job_id   := l_target_job_id;
        p_target_job_definition_id := l_target_job_definition_id;
    else
        close c;
        p_organization_id := null;
        p_new_position_id := null;
        p_target_job_name := null;
        p_target_job_id   := null;
        p_target_job_definition_id := null;
    end if;

end get_job;
--
procedure get_target_job
         (p_new_job_id      in number,
          p_effective_date  in date,
          p_target_job_name out varchar2,
          p_target_job_definition_id out number)

  is

   cursor csr_job is
       select job.name,
              job.job_definition_id
       from   per_jobs job
       where  p_new_job_id = job.job_id
       and    p_effective_date between job.date_from
                               and     nvl(job.date_to, p_effective_date);


   l_target_job_name varchar2(240);
   l_target_job_definition_id number(15);

  begin
    open csr_job;
    fetch csr_job into l_target_job_name,
                       l_target_job_definition_id;

    if (csr_job%found) then
        close csr_job;
        p_target_job_name := l_target_job_name;
        p_target_job_definition_id := l_target_job_definition_id;
    else
        close csr_job;
        p_target_job_name := null;
        p_target_job_definition_id := null;
        raise no_data_found;
    end if;

Exception
  When NO_DATA_FOUND then
       hr_utility.set_message(801,'HR_51358_POS_JOB_INVALID_DATE');
       hr_utility.raise_error;

end get_target_job;
--
--
end  PER_MM_POSITIONS_PKG;



/
