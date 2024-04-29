--------------------------------------------------------
--  DDL for Package Body PER_MM_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MM_ASSIGNMENTS_PKG" as
/* $Header: pemmv03t.pkb 120.1 2005/11/07 02:39:04 pchowdav noship $ */
--
--
procedure update_row
           (p_default_from in varchar2,
            p_select_assignment in varchar2,
            p_grade_id in number,
            p_tax_unit_id in number,
            p_row_id in varchar2)

  is
    begin
      update per_mm_assignments
         set default_from = p_default_from,
             select_assignment = p_select_assignment,
             grade_id = p_grade_id,
             tax_unit_id = p_tax_unit_id
       where rowid = p_row_id;
    if (sql%notfound) then
      raise no_data_found;
    end if;

end update_row;
--
--
procedure load_rows
                  (p_mass_move_id in number,
                   p_session_date in date)
  is
    -- fix for bug 4704865 starts here.
    l_rule_mode  VARCHAR2(30);

    cursor csr_chk_rule_mode is
    select rule_mode
    from pay_legislation_rules plr,
         per_business_groups bg
    where plr.legislation_code = bg.legislation_code
    and bg.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
    and rule_type = 'PERWSMMV_GRE';

     begin

    open csr_chk_rule_mode;
    fetch csr_chk_rule_mode into l_rule_mode;
    close csr_chk_rule_mode;

    if nvl(l_rule_mode,'N') = 'Y'
    then
    -- fix for bug 4704865 ends here.
     insert into per_mm_assignments
         (MASS_MOVE_ID,
          ASSIGNMENT_ID,
          OBJECT_VERSION_NUMBER,
          POSITION_ID,
          DEFAULT_FROM,
          SELECT_ASSIGNMENT,
          ASSIGNMENT_MOVED,
          GRADE_ID,
          TAX_UNIT_ID
          )
     select
         p_mass_move_id,
         asg.assignment_id,
         asg.object_version_number,
         asg.position_id,
         'A',
         'Y',
         'N',
         gra.grade_id,
         to_number(scl.segment1)
       from per_assignments_f asg,
            per_mm_positions mmpos,
            per_assignment_status_types stat,
            hr_soft_coding_keyflex scl,
            per_grades gra
        where asg.position_id = mmpos.position_id
        and mmpos.mass_move_id = p_mass_move_id
        and p_session_date between
            asg.effective_start_date and
            asg.effective_end_date
        and asg.grade_id = gra.grade_id (+)
        and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id (+)
        and stat.assignment_status_type_id =
            asg.assignment_status_type_id
        and stat.per_system_status in ('ACTIVE_ASSIGN'
                                      ,'ACTIVE_APL'
                                      ,'ACCEPTED'
                                      ,'ACTIVE_CWK')
        and asg.assignment_type in ('E','A','C');

       -- fix for bug 4704865 starts here.
       else
         insert into per_mm_assignments
         (MASS_MOVE_ID,
          ASSIGNMENT_ID,
          OBJECT_VERSION_NUMBER,
          POSITION_ID,
          DEFAULT_FROM,
          SELECT_ASSIGNMENT,
          ASSIGNMENT_MOVED,
          GRADE_ID,
          TAX_UNIT_ID
          )
     select
         p_mass_move_id,
         asg.assignment_id,
         asg.object_version_number,
         asg.position_id,
         'A',
         'Y',
         'N',
         gra.grade_id,
         null
       from per_assignments_f asg,
            per_mm_positions mmpos,
            per_assignment_status_types stat,
            per_grades gra
        where asg.position_id = mmpos.position_id
        and mmpos.mass_move_id = p_mass_move_id
        and p_session_date between
            asg.effective_start_date and
            asg.effective_end_date
        and asg.grade_id = gra.grade_id (+)
        and stat.assignment_status_type_id =
            asg.assignment_status_type_id
        and stat.per_system_status in ('ACTIVE_ASSIGN'
                                      ,'ACTIVE_APL'
                                      ,'ACCEPTED'
                                      ,'ACTIVE_CWK')
        and asg.assignment_type in ('E','A','C');
        end if;
        -- fix for bug 4704865 ends here.
    exception
       when no_data_found then
         null;
       when others then
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','per_mm_assignments_pkg.load_rows');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;

    end load_rows;
--
--
procedure lock_row
           (p_mass_move_id in number,
            p_assignment_id in number,
            p_position_id in number,
            p_default_from in varchar2,
            p_select_assignment in varchar2,
            p_grade_id in number,
            p_tax_unit_id in number,
            p_row_id in varchar2)

 is
    counter number;
    cursor c is
      select *
        from per_mm_assignments
       where rowid = p_row_id
         for update of select_assignment nowait;
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
          hr_utility.set_message_token('PROCEDURE','mm_assignment_pkg.lock_rows');
          hr_utility.set_message_token('STEP','1');
          hr_utility.raise_error;
        end if;
        close c;
        if  (
              (recinfo.mass_move_id = p_mass_move_id)
            AND
              (recinfo.assignment_id = p_assignment_id)
            AND
              (recinfo.position_id = p_position_id)
            AND
              (recinfo.default_from = p_default_from)
            AND(
                (recinfo.select_assignment = p_select_assignment)
                 OR (    (recinfo.select_assignment is null)
                   AND (p_select_assignment is null)))
            AND(
                (recinfo.grade_id = p_grade_id)
                 OR (    (recinfo.grade_id is null)
                   AND (p_grade_id is null)))
            AND(
                (recinfo.tax_unit_id = p_tax_unit_id)
                 OR (    (recinfo.tax_unit_id is null)
                   AND (p_tax_unit_id is null)))
            ) then
            return;
             else
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','mm_assignment_pkg.lock_rows');
          hr_utility.set_message_token('STEP','2');
          hr_utility.raise_error;
        end if;
      exception
        when app_exceptions.record_lock_exception then
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','mm_assignment_pkg.lock_rows');
          hr_utility.set_message_token('STEP','3');
          hr_utility.raise_error;
      end;
    end loop;
end lock_row ;
--
--
procedure restore_defaults
          (p_mass_move_id in number,
           p_assignment_id in number,
           p_grade_id out nocopy number,
           p_grade_name out nocopy varchar2,
           p_tax_unit_id out nocopy number,
           p_tax_unit_name out nocopy varchar2)
  is

    l_grade_id number(15);
    l_grade_name varchar(240);
    l_tax_unit_id number(15);

    -- 4385302 starts here
    -- previously defined local var has been commented and newly defined
    --l_tax_unit_name varchar(30);
    l_tax_unit_name  per_mm_assignments_v.tax_unit_name%type;
   -- 4385302 ends here

    cursor c is
        select grade_id,
               grade_name,
               tax_unit_id,
               tax_unit_name
        from per_mm_assignments_v
        where mass_move_id = p_mass_move_id
        and   assignment_id = p_assignment_id;

  begin
    open c;
    fetch c into l_grade_id,
                 l_grade_name,
                 l_tax_unit_id,
                 l_tax_unit_name;
    if c%notfound then
      close c;
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','mm_assignment_pkg.restore_defaults');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    end if;
    close c;

    p_grade_id := l_grade_id;
    p_grade_name := l_grade_name;
    p_tax_unit_id := l_tax_unit_id;
    p_tax_unit_name := l_tax_unit_name;


end restore_defaults;
--
--
end per_mm_assignments_pkg;

/
