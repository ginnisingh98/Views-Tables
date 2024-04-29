--------------------------------------------------------
--  DDL for Package Body PER_MASS_MOVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MASS_MOVES_PKG" as
/* $Header: pemmv01t.pkb 115.0 99/07/18 14:02:06 porting ship $ */
--
--
procedure insert_row
                  (p_business_group_id in number,
                   p_effective_date in date,
                   p_new_organization_id in number,
                   p_source_organization_id in number,
                   p_reason in varchar2,
                   p_status in varchar2,
                   p_mass_move_id out number,
                   p_row_id out varchar2)
  is

  l_mass_move_id number(15);
  l_row_id varchar2(18) ;

  cursor c1 is
    select per_mass_moves_s.nextval
       from sys.dual;

  cursor c is
     select rowid
     from per_mass_moves
     where mass_move_id = l_mass_move_id;

  begin
    open c1;
    fetch c1 into l_mass_move_id;
    if (C1%NOTFOUND) then
       CLOSE C1;
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','per_mass_moves_pkg.insert_rows');
       hr_utility.set_message_token('STEP','1');
    end if;
      close c1;


    insert into per_mass_moves
      (mass_move_id,
       business_group_id,
       effective_date,
       new_organization_id,
       old_organization_id,
       reason,
       status)
     values
       (l_mass_move_id,
        p_business_group_id,
        p_effective_date,
        p_new_organization_id,
        p_source_organization_id,
        p_reason,
        p_status);
    open c;
    fetch c into l_row_id;
    if (c%notfound) then
       close c;
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','per_mass_moves_pkg.insert_rows');
       hr_utility.set_message_token('STEP','2');
    end if;
    close c;
    p_mass_move_id := l_mass_move_id;
    p_row_id := l_row_id;

  exception
    when others then
        null;
  end insert_row;
--
--
  procedure update_row
                  (p_mass_move_id in number,
                   p_effective_date in date,
                   p_new_organization_id in number,
                   p_source_organization_id in number,
                   p_reason in varchar2,
                   p_row_id in varchar2)
   is

  begin
      update per_mass_moves
       set effective_date = p_effective_date,
       new_organization_id = p_new_organization_id,
       old_organization_id = p_source_organization_id,
       reason = p_reason
       where rowid = p_row_id;
         if (sql%notfound) then
           raise no_data_found;
         end if;
     end update_row;
--
--
 procedure delete_row
             (p_mass_move_id in number,
              p_row_id in varchar2)
  is

   begin
     delete from per_mass_moves
      where rowid = p_row_id;
     if sql%notfound then
       raise no_data_found;
     end if;
  end delete_row;
--
--
 procedure lock_row
                  (p_mass_move_id in number,
                   p_business_group_id in number,
                   p_effective_date in date,
                   p_new_organization_id in number,
                   p_source_organization_id in number,
                   p_reason in varchar2,
                   p_status in varchar2,
                   p_row_id in varchar2)
   is

    counter number;
    cursor c is
      select *
        from per_mass_moves
       where mass_move_id = p_mass_move_id
         for update of status nowait;
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
          hr_utility.set_message_token('PROCEDURE','per_mass_moves_pkg.lock_rows');
          hr_utility.set_message_token('STEP','1');
          hr_utility.raise_error;
        end if;
        close c;
        if  (
             (recinfo.mass_move_id = p_mass_move_id)
            AND
              (recinfo.effective_date = p_effective_date)
            AND
              (recinfo.new_organization_id = p_new_organization_id)
            AND
              (recinfo.old_organization_id = p_source_organization_id)
            AND
              (recinfo.business_group_id = p_business_group_id)
            AND(
                (recinfo.reason = p_reason)
                 OR (    (recinfo.reason is null)
                   AND (p_reason is null)))
            AND(
                (recinfo.status = p_status)
                 OR (    (recinfo.status is null)
                   AND (p_status is null)))
            ) then
            return;
        else
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','per_mass_moves_pkg.lock_rows');
          hr_utility.set_message_token('STEP','2');
          hr_utility.raise_error;
        end if;
      exception
        when app_exceptions.record_lock_exception then
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','per_mass_moves_pkg.lock_rows');
          hr_utility.set_message_token('STEP','3');
          hr_utility.raise_error;
      end;
    end loop;
  end lock_row ;

end per_mass_moves_pkg ;


/
