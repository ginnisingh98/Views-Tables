--------------------------------------------------------
--  DDL for Package Body PER_POS_STRUCT_ELEMENTS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POS_STRUCT_ELEMENTS_PKG2" as
/* $Header: pepse02t.pkb 115.6 2002/12/04 16:15:24 eumenyio ship $ */

procedure p_root_test(p_root out nocopy boolean,
                      X_Business_Group_Id        NUMBER,
                      X_Pos_Structure_Version_Id NUMBER,
                      X_Position_Id              NUMBER) is
          l_dummy varchar2(1);
begin
/*
This step checks if the hierarchy has any POSITIONs entered under it.
If the hierarchy has no POSITIONs, the child pos is treated as though
it is the top of the hierarchy structure.
*/
  l_dummy := NULL;
  p_root := FALSE;

  begin
  select '1'
  into   l_dummy
  from    per_pos_structure_elements a
  where   a.business_group_id + 0 = X_Business_Group_Id
  and     a.POS_structure_version_id = X_Pos_Structure_Version_Id;
  exception when no_data_found then
                 null;
            when too_many_rows then
                 null;
  end;

  if l_dummy <> '1' then
     p_root := TRUE;

  else
     /*
     This step checks if the child POSITION is the top POSITION in
     the hierarchy (ie it is not ever a child in this hierarchy).
     */

     l_dummy := NULL;

     begin
     select '1'
     into l_dummy
     from    per_pos_structure_elements ose
     where   ose.business_group_id + 0 = X_Business_Group_Id
     and     ose.POS_structure_version_id = X_Pos_Structure_Version_Id
     and     exists
            (select null
             from per_pos_structure_elements a
             where a.POS_structure_version_id = X_Pos_Structure_Version_Id
             and a.parent_position_id    = X_Position_Id)
     and     not exists
            (select null
            from per_pos_structure_elements b
            where b.POS_structure_version_id = X_Pos_Structure_Version_Id
            and b.subordinate_position_id     = X_Position_Id);

     exception when no_data_found then
                    null;
               when too_many_rows then
                    null;
     end;

     if l_dummy = '1' then
        p_root := TRUE;
     end if;

  end if;
end;

PROCEDURE parent_insert_update_checks (X_Business_Group_Id        NUMBER,
                                       X_Pos_Structure_Version_Id NUMBER,
                                       X_Position_Id              NUMBER,
                                       X_Parent_Position_Id       NUMBER,
                                       X_Subordinate_Position_Id  NUMBER) is
          l_root boolean;
          l_dummy varchar2(1);
begin
     p_root_test(l_root,
                 X_Business_Group_Id,
                 X_Pos_Structure_Version_Id,
                 X_Position_Id);

     if l_root then
        begin
        /*
         This step checks that the parent POSITION being linked to the
         root POSITION does not already exist in the hierarchy.
         The parent of a root POSITION should not already exist in the hierarchy
        */
        select '1'
        into l_dummy
        from   per_pos_structure_elements ose
        where  (ose.subordinate_position_id = X_Parent_Position_Id
        or      ose.parent_position_id = X_Parent_Position_Id)
        and    ose.POS_structure_version_id = X_Pos_Structure_Version_Id
        and    ose.business_group_id + 0 = X_Business_Group_Id;
        exception when no_data_found then
                       null;
                  when too_many_rows then
                       null;
        end;

        if l_dummy  = '1' then
          hr_utility.set_message(801,'PER_7420_POS_PARENT_EXISTS');
          hr_utility.raise_error;
        end if;
     else
     /* Non root
        This step checks that the parent POSITION exists in the hierarchy.
        The parent of a non-root POSITION must already exist in the hierarchy.
     */
        l_dummy :=NULL;
        begin
        select '1'
        into l_dummy
        from   per_pos_structure_elements ose
        where  (ose.subordinate_position_id = X_Parent_Position_Id
        or      ose.parent_position_id = X_Parent_Position_Id)
        and    ose.POS_structure_version_id = X_Pos_Structure_Version_Id
        and    ose.business_group_id + 0 = X_Business_Group_Id;
        exception when no_data_found then
                       null;
                  when too_many_rows then
                       null;
        end;

        if l_dummy  <> '1' then
          hr_utility.set_message(801,'PER_7419_POS_PARENT_NEEDED');
          hr_utility.raise_error;
        else
        /*
         This step checks that the parent of the non-root POSITION is not
         below the non-root POSITION.  The parent must not be the non-root
         POSITION or any of its children.
        */
          l_dummy :=NULL;
          begin
          select '1'
          into l_dummy
          from   per_pos_structure_elements ose
          where
                 ose.POS_structure_version_id = X_Pos_Structure_Version_Id
          and    ose.business_group_id + 0 = X_Business_Group_Id
          and    X_Parent_Position_Id in
          (
           select ose.subordinate_position_id
           from per_pos_structure_elements ose
           where ose.POS_structure_version_id = X_Pos_Structure_Version_Id
             and ose.business_group_id + 0        = X_Business_Group_Id
           connect by
           prior ose.subordinate_position_id   = ose.parent_position_id
             and ose.POS_structure_version_id  = X_Pos_Structure_Version_Id
             and ose.business_group_id + 0         = X_Business_Group_Id
           start with
             ose.parent_position_id            = X_Subordinate_Position_Id
             and ose.POS_structure_version_id  = X_Pos_Structure_Version_Id
             and ose.business_group_id + 0         = X_Business_Group_Id
          );
          exception when no_data_found then
                       null;
                  when too_many_rows then
                       null;
          end;
          if l_dummy = '1' then
             hr_utility.set_message(801,'PER_7421_POS_PARENT_BELOW');
             hr_utility.raise_error;
          end if;
        end if;
     end if;

end;

PROCEDURE Check_duplicate_hierarchies (X_Rowid  VARCHAR2,
                                       X_Subordinate_Position_Id NUMBER,
                                       X_Business_Group_Id        NUMBER,
                                       X_Pos_Structure_Version_Id NUMBER) is

          l_exists  boolean;
          l_dummy varchar2(1);

          cursor csr_exists is
          select '1'
          from per_pos_structure_elements tab
          where (( X_Rowid is not null
          and tab.rowid <> X_Rowid)
          or  X_Rowid is null)
          and X_Pos_Structure_Version_Id = tab.pos_structure_version_id
          and (X_Subordinate_Position_Id = tab.subordinate_position_id)
          and  X_Business_Group_Id = tab.business_group_id + 0;

begin
    open csr_exists;
    fetch csr_exists into l_dummy;
    l_exists := csr_exists%found;
    close csr_exists;
    if l_exists then
       hr_utility.set_message(801,'PER_7408_POS_HIER_POS');
       hr_utility.raise_error;
    end if;
end Check_duplicate_hierarchies;

PROCEDURE check_sec_profiles (X_Business_Group_Id        NUMBER,
                              X_Pos_Structure_Version_Id NUMBER,
                              X_Parent_Position_Id       NUMBER,
                              X_Subordinate_Position_Id  NUMBER,
                              X_Position_Id              NUMBER) is
          l_dummy varchar2(1);
          l_Position_Structure_Id number;
begin
     begin
     select position_structure_id
     into l_Position_Structure_Id
     from per_pos_structure_versions
     where pos_structure_version_id = X_Pos_Structure_Version_Id;
     exception when too_many_rows then
                    null;
     end;
     l_dummy:= NULL;
     begin
     SELECT '1'
     into l_dummy
     FROM   PER_SECURITY_PROFILES PSP
     WHERE  PSP.business_group_id + 0     = X_Business_Group_Id
     AND    (PSP.POSITION_ID           = X_Subordinate_Position_Id
     OR      PSP.POSITION_ID = X_Parent_Position_Id)
     AND     PSP.POSITION_STRUCTURE_ID = l_Position_Structure_Id;
     exception when no_data_found then
                    null;
               when too_many_rows then
                    null;
     end;
     if l_dummy = '1' then
        hr_utility.set_message(801,'PAY_7694_PER_NO_DEL_STRUCTURE');
        hr_utility.raise_error;
     else
        l_dummy:= NULL;
        begin
        SELECT '1'
        into l_dummy
        FROM PER_SECURITY_PROFILES PSP
        WHERE PSP.business_group_id + 0 = X_Business_Group_Id
        AND PSP.POSITION_ID = X_Position_Id
        AND PSP.POSITION_STRUCTURE_ID = l_position_structure_id;
        exception when no_data_found then
                    null;
               when too_many_rows then
                    null;
        end;

        if l_dummy = '1' then
           hr_utility.set_message(801,'PAY_7694_PER_NO_DEL_STRUCTURE');
           hr_utility.raise_error;
        end if;

     end if;

end;

PROCEDURE check_if_child_is_parent (X_Business_Group_Id        NUMBER,
                                    X_Pos_Structure_Version_Id NUMBER,
                                    X_Parent_Position_Id       NUMBER,
                                    X_Subordinate_Position_Id  NUMBER) is
          l_dummy varchar2(1);
begin
          l_dummy := NULL;
          begin
          select '1'
          into l_dummy
          from    per_pos_structure_elements ose
          where   ose.business_group_id + 0 = X_Business_Group_Id
          and     ose.POS_structure_version_id = X_Pos_Structure_Version_Id
          and     not exists
          (select null
           from per_pos_structure_elements b
           where b.POS_structure_version_id = X_Pos_Structure_Version_Id
           and b.subordinate_position_id     = X_Parent_Position_Id)
          and     not exists
          (select null
           from per_pos_structure_elements c
           where c.pos_structure_version_id = X_Pos_Structure_Version_Id
           and   c.parent_position_id    = X_Parent_Position_Id
           and   c.subordinate_position_id <> X_Subordinate_Position_Id);
          exception when no_data_found then
                       null;
                  when too_many_rows then
                       null;
          end;
          if l_dummy <> '1' then
            l_dummy := NULL;
            begin
            SELECT '1'
            into l_dummy
            FROM   PER_POS_STRUCTURE_ELEMENTS OSE
            WHERE  OSE.POS_STRUCTURE_VERSION_ID = X_Pos_Structure_Version_Id
            AND    OSE.PARENT_POSITION_ID = X_Subordinate_Position_Id;
            exception when no_data_found then
                       null;
                  when too_many_rows then
                       null;
            end;
            if l_dummy = '1' then
               hr_utility.set_message(801,'PER_7418_POS_PARENT');
               hr_utility.raise_error;
            end if;
          end if;
end;



PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Pos_Structure_Element_Id            IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Pos_Structure_Version_Id            NUMBER,
                     X_Subordinate_Position_Id             NUMBER,
                     X_Parent_Position_Id                  NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Security_Profile_Id                 NUMBER,
                     X_View_All_Positions                  VARCHAR2,
                     X_End_of_time                         DATE,
                     X_Session_Date                        DATE,
                     X_hr_ins                              VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM PER_POS_STRUCTURE_ELEMENTS

             WHERE pos_structure_element_id = X_Pos_Structure_Element_Id;





    CURSOR C2 IS SELECT per_pos_structure_elements_s.nextval FROM sys.dual;
BEGIN

   if (X_Pos_Structure_Element_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Pos_Structure_Element_Id;
     CLOSE C2;
   end if;

  Check_duplicate_hierarchies(X_Rowid  ,
                              X_Subordinate_Position_Id ,
                              X_Business_Group_Id        ,
                              X_Pos_Structure_Version_Id );

  Parent_insert_update_checks(X_Business_Group_Id,
                              X_Pos_Structure_Version_Id,
                              X_Position_Id,
                              X_Parent_Position_Id,
                              X_Subordinate_Position_Id);

  INSERT INTO PER_POS_STRUCTURE_ELEMENTS(
          pos_structure_element_id,
          business_group_id,
          pos_structure_version_id,
          subordinate_position_id,
          parent_position_id
         ) VALUES (
          X_Pos_Structure_Element_Id,
          X_Business_Group_Id,
          X_Pos_Structure_Version_Id,
          X_Subordinate_Position_Id,
          X_Parent_Position_Id
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Insert_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;

END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Pos_Structure_Element_Id              NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Pos_Structure_Version_Id              NUMBER,
                   X_Subordinate_Position_Id               NUMBER,
                   X_Parent_Position_Id                    NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   PER_POS_STRUCTURE_ELEMENTS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Pos_Structure_Element_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.pos_structure_element_id = X_Pos_Structure_Element_Id)
           OR (    (Recinfo.pos_structure_element_id IS NULL)
               AND (X_Pos_Structure_Element_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.pos_structure_version_id = X_Pos_Structure_Version_Id)
           OR (    (Recinfo.pos_structure_version_id IS NULL)
               AND (X_Pos_Structure_Version_Id IS NULL)))
      AND (   (Recinfo.subordinate_position_id = X_Subordinate_Position_Id)
           OR (    (Recinfo.subordinate_position_id IS NULL)
               AND (X_Subordinate_Position_Id IS NULL)))
      AND (   (Recinfo.parent_position_id = X_Parent_Position_Id)
           OR (    (Recinfo.parent_position_id IS NULL)
               AND (X_Parent_Position_Id IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Pos_Structure_Element_Id            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Pos_Structure_Version_Id            NUMBER,
                     X_Subordinate_Position_Id             NUMBER,
                     X_Parent_Position_Id                  NUMBER,
                     X_Position_Id                         NUMBER
) IS
BEGIN

 Parent_insert_update_checks(X_Business_Group_Id,
                             X_Pos_Structure_Version_Id,
                             X_Position_Id,
                             X_Parent_Position_Id,
                             X_Subordinate_Position_Id);


  UPDATE PER_POS_STRUCTURE_ELEMENTS
  SET

    pos_structure_element_id                  =    X_Pos_Structure_Element_Id,
    business_group_id                         =    X_Business_Group_Id,
    pos_structure_version_id                  =    X_Pos_Structure_Version_Id,
    subordinate_position_id                   =    X_Subordinate_Position_Id,
    parent_position_id                        =    X_Parent_Position_Id
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','update_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_Business_Group_Id        NUMBER,
                     X_Pos_Structure_Version_Id NUMBER,
                     X_Parent_Position_Id       NUMBER,
                     X_Subordinate_Position_Id  NUMBER,
                     X_hr_ins VARCHAR2,
                     X_Position_Id              NUMBER) IS
BEGIN

check_if_child_is_parent(X_Business_Group_Id,
                         X_Pos_Structure_Version_Id,
                         X_Parent_Position_Id,
                         X_Subordinate_Position_Id);

if x_hr_ins = 'Y' then
   check_sec_profiles(X_Business_Group_Id,
                      X_Pos_Structure_Version_Id,
                      X_Parent_Position_Id,
                      X_Subordinate_Position_Id,
                      X_Position_Id);
end if;

  DELETE FROM PER_POS_STRUCTURE_ELEMENTS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','delete_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
END Delete_Row;

END PER_POS_STRUCT_ELEMENTS_PKG2;

/
