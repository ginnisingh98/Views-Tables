--------------------------------------------------------
--  DDL for Package Body PER_POS_STRUCTURE_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POS_STRUCTURE_VERSIONS_PKG" as
/* $Header: pepsv01t.pkb 120.1 2006/06/29 12:06:48 hmehta ship $ */
-----------------------------------------------------------------------------
FUNCTION get_next_free_no(X_Position_Structure_Id NUMBER) return NUMBER IS
--
--
l_next_free_no NUMBER; --Next Free Number in a hierarchy.
begin
  select nvl(max(psv.version_number),0) + 1
   into   l_next_free_no
   from per_pos_structure_versions psv
   where psv.Position_Structure_Id = X_Position_Structure_Id;
   --
   return l_next_free_no;
end get_next_free_no;
-----------------------------------------------------------------------------
PROCEDURE check_version_number(X_Position_Structure_Id NUMBER
                              ,X_Version_Number NUMBEr
                              ,X_Rowid VARCHAR2) IS
--
-- Local Variable.
--
l_dummy VARCHAR2(1);
begin
   select null
   into l_dummy
   from sys.dual
   where exists (select 1
                  from    per_pos_structure_versions      psv
                  where   psv.position_structure_id  = X_Position_Structure_Id
                  and     psv.version_number         = X_Version_Number
                  and     (psv.rowid                <> X_Rowid
                  or      X_Rowid is null));
   --
   hr_utility.set_message('801','HR_6077_PO_POS_DUP_VER');
   hr_utility.raise_error;
   --
   exception
      when no_data_found then
         null;
end check_version_number;
--
-----------------------------------------------------------------------------
PROCEDURE check_date_gap(X_Date_From                        DATE,
                         X_Date_To                          DATE ,
                         X_Position_Structure_Id            NUMBER,
                         X_gap_warning                      IN OUT NOCOPY VARCHAR2,
                         X_Rowid                            VARCHAR2) IS
--
-- Test for Gaps between hierarchy versions.
-- i.e. 1 10-Feb-94 16-Feb-94
--      2 20-Mar-94
-- would flag a message as gap exists.
--
-- Local Variable
--
l_max_end_date DATE;
l_min_start_date DATE;
--
begin
  X_gap_warning := 'N';
  select max(psv.date_to)
  into   l_max_end_date
  from   per_pos_structure_versions psv
  where  psv.date_from < X_Date_From
  --
  -- Bug 608815: add missing clause to restrict the hierarchy, or the code
  -- looks for the max date across all hierarchies. RMF 09-Jan-98.
  --
  and	psv.position_structure_id = X_Position_Structure_Id
  and   (psv.rowid <> X_Rowid
     or  X_Rowid is null);
  --
  if (l_max_end_date is not null and X_Date_from = (l_max_end_date +1)
   or (l_max_end_date is null)) then
        select min(psv.date_from)
		  into   l_min_start_date
        from   per_pos_structure_versions psv
        where  psv.position_structure_id = X_Position_Structure_Id
        and    psv.date_from > X_Date_To
        and   (psv.rowid <> X_Rowid
        or    psv.rowid is null);
        --
        --
      if l_min_start_date is null then
        return;
     elsif (X_Date_To +1) = l_min_start_date then
        return;
     end if;
  end if;
  X_gap_warning := 'Y';
end;
-----------------------------------------------------------------------------
PROCEDURE check_overlap(X_Position_Structure_Id NUMBER
                       ,X_Rowid VARCHAR2
                       ,X_Date_From DATE
                       ,X_Date_To DATE
                       ,X_End_Of_Time DATE
                       ,X_End_Date_Closedown IN OUT NOCOPY VARCHAR2) IS
--
-- Check for Overlapping structures
--
--
-- Local Variables
--
l_dummy VARCHAR2(1);
Begin
   --
   X_End_Date_Closedown := 'N';
   --
   begin
      select null
      into l_dummy
      from sys.dual
      where exists
         (select 1
         from per_pos_structure_versions psv
         where psv.position_structure_id = X_Position_Structure_Id
         and   X_Date_From > psv.date_from
         and   psv.date_to is null);
      --
      -- If None exist it will exit normally
      --
      begin
         --
         -- Close down the open structures, before testing for overlaps
         --
         update per_pos_structure_versions psv
         set psv.date_to = (X_date_from - 1)
         where psv.position_structure_id = X_Position_Structure_Id
         and   psv.date_to is null
         and   (psv.rowid <> X_Rowid
         or    X_Rowid is null);
         --
         if sql%rowcount <>0 then
            X_End_Date_Closedown := 'Y';
         end if;
      end;
      exception
         when no_data_found then
            null;
   end;
   begin
      --
      -- Test for overlapping rows
      --
      select null
      into   l_dummy
      from sys.dual
      where exists
         (select 1
         from per_pos_structure_versions psv
         where psv.date_from <= nvl(X_Date_To, X_End_Of_Time)
         and   nvl(psv.date_to,X_End_Of_Time) >= X_Date_From
         and   psv.position_structure_id = X_Position_Structure_Id
         and   (psv.rowid <> X_Rowid
         or    X_Rowid is null));
      --
      hr_utility.set_message('801','HR_6076_PO_POS_OVERLAP');
      hr_utility.raise_error;
      --
   end;
   exception
      when no_data_found then
         null;
end check_overlap;
-----------------------------------------------------------------------------
PROCEDURE copy_elements(X_Pos_Structure_Version_Id NUMBER
                        ,X_Copy_Structure_Version_Id NUMBER) IS
--
-- Define Cursor for the Inserts
--
Cursor Struct_element is
select *
from per_pos_structure_elements pse
where pse.pos_structure_version_id = X_Copy_Structure_Version_Id;
--
-- Local Variable
--
ele_record Struct_element%ROWTYPE;
l_Rowid VARCHAR2(20);
l_Structure_element_id NUMBER;
begin

INSERT INTO PER_POS_STRUCTURE_ELEMENTS(
          pos_structure_element_id,
          business_group_id,
          pos_structure_version_id,
          subordinate_position_id,
          parent_position_id
         )
select per_pos_structure_elements_s.nextval,
          business_group_id,
          x_pos_structure_version_id,
          subordinate_position_id,
          parent_position_id
from per_pos_structure_elements pse
where pse.pos_structure_version_id = X_Copy_Structure_Version_Id;
/*
   open Struct_element;
   fetch Struct_element into ele_record;
   loop
      exit when Struct_element%NOTFOUND;
      PER_POS_STRUCTURE_ELEMENTS_PKG.Insert_Row(
      X_Rowid => l_Rowid
      ,X_Pos_Structure_Element_Id =>l_Structure_element_id
      ,X_Business_Group_Id => ele_record.Business_Group_Id
      ,X_Pos_Structure_Version_Id => X_Pos_Structure_Version_Id
      ,X_Subordinate_Position_Id => ele_record.Subordinate_Position_Id
      ,X_Parent_Position_Id => ele_record.Parent_Position_Id);
		 --
		 -- Reset value of element_id else we will get a 0001 oracle error
		 -- duplicate key etc.
		 --
		 l_Structure_element_id := NULL;
      fetch Struct_element into ele_record;
   end loop;
   close Struct_element;
*/
end copy_elements;
-----------------------------------------------------------------------------
PROCEDURE pre_delete_checks(X_Pos_Structure_Version_Id      NUMBER,
                            X_Business_Group_Id             NUMBER,
                            X_Position_Structure_Id         NUMBER,
                            X_Hr_Installed                  VARCHAR2) IS
--
-- Local Variable
--
l_dummy VARCHAR2(1);
begin
  begin
     select null
     into   l_dummy
     from sys.dual
     where exists( select null
     from PER_POS_STRUCTURE_ELEMENTS PSE
     where PSE.POS_STRUCTURE_VERSION_ID = X_Pos_Structure_Version_Id);
     --
     hr_utility.set_message('801','HR_6205_PO_POS_POS_NO_DEL');
     hr_utility.raise_error;
     exception
       when no_data_found then
          null;
 end;
 if X_Hr_Installed <> 'N' then
    begin
       select null
       into l_dummy
       from sys.dual
       where exists(select null
       from per_security_profiles
       where business_group_id + 0 = X_Business_Group_Id
       and   position_structure_id = X_Position_Structure_Id);
       --
       hr_utility.set_message('801','PAY_7694_PER_NO_DEL_STRUCTURE');
       hr_utility.raise_error;
       exception
         when no_data_found then
            null;
    end;
 end if;
end pre_delete_checks;
-----------------------------------------------------------------------------
PROCEDURE update_copies(X_Pos_Structure_Version_Id NUMBER) IS
--
--
--
cursor ele_update is
select rowid
from per_pos_structure_versions psv
where psv.copy_structure_version_id = X_Pos_Structure_Version_Id
for update of psv.copy_structure_version_id nowait;
--
-- Local Variables
--
l_Rowid VARCHAR2(20);
begin
   open ele_update;
   fetch ele_update into l_Rowid;
   loop
      exit when ele_update%NOTFOUND;
		update per_pos_structure_versions psv
		set psv.copy_structure_version_id = NULL
		where psv.rowid = l_Rowid;
      --
      fetch ele_update into l_Rowid;
   end loop;
	close ele_update;
end;
-----------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Pos_Structure_Version_Id            IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Position_Structure_Id               NUMBER,
                     X_Date_From                           DATE,
                     X_Version_Number                      NUMBER,
                     X_Copy_Structure_Version_Id           NUMBER ,
                     X_Date_To                             DATE ,
							X_end_of_time                         DATE,
							X_Next_no_free                 IN OUT NOCOPY NUMBER,
							X_closedown_warning            IN OUT NOCOPY VARCHAR2,
							X_gap_warning                  IN OUT NOCOPY VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM PER_POS_STRUCTURE_VERSIONS
             WHERE pos_structure_version_id = X_Pos_Structure_Version_Id;
    CURSOR C2 IS SELECT per_pos_structure_versions_s.nextval FROM sys.dual;
BEGIN
   --
   PER_POS_STRUCTURE_VERSIONS_PKG.check_version_number(
                        X_Position_Structure_Id=> X_Position_Structure_Id
                        ,X_Version_Number => X_Version_Number
                        ,X_Rowid => X_Rowid);
   --
   PER_POS_STRUCTURE_VERSIONS_PKG.check_overlap(
   X_Position_Structure_Id=> X_Position_Structure_Id
   ,X_Rowid => X_Rowid
   ,X_Date_From => X_Date_From
   ,X_Date_To => X_Date_To
   ,X_End_Of_Time => X_End_Of_Time
   ,X_End_Date_Closedown => X_closedown_warning);
   --
   PER_POS_STRUCTURE_VERSIONS_PKG.check_date_gap(X_Date_From => X_Date_From
                            ,X_Date_To => X_Date_To
                            ,X_gap_warning => X_gap_warning
                            ,X_Position_Structure_Id =>X_Position_Structure_Id
                            ,X_Rowid => X_Rowid);
   --
   if (X_Pos_Structure_Version_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Pos_Structure_Version_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_POS_STRUCTURE_VERSIONS(
          pos_structure_version_id,
          business_group_id,
          position_structure_id,
          date_from,
          version_number,
          copy_structure_version_id,
          date_to
         ) VALUES (
          X_Pos_Structure_Version_Id,
          X_Business_Group_Id,
          X_Position_Structure_Id,
          X_Date_From,
          X_Version_Number,
          X_Copy_Structure_Version_Id,
          X_Date_To
  );
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if X_Copy_Structure_Version_Id is not null then
     PER_POS_STRUCTURE_VERSIONS_PKG.copy_elements(
                 X_Copy_Structure_Version_Id => X_Copy_Structure_Version_Id
                 ,X_Pos_Structure_Version_Id => X_Pos_Structure_Version_Id);
  end if;
  X_Next_no_free :=PER_POS_STRUCTURE_VERSIONS_PKG.get_next_free_no(
                  X_Position_Structure_Id =>X_Position_Structure_Id);
end Insert_Row;
-----------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Pos_Structure_Version_Id              NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Position_Structure_Id                 NUMBER,
                   X_Date_From                             DATE,
                   X_Version_Number                        NUMBER,
                   X_Copy_Structure_Version_Id             NUMBER ,
                   X_Date_To                               DATE
) IS
  CURSOR C IS
      SELECT *
      FROM   PER_POS_STRUCTURE_VERSIONS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Pos_Structure_Version_Id NOWAIT;
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
          (   (Recinfo.pos_structure_version_id = X_Pos_Structure_Version_Id)
           OR (    (Recinfo.pos_structure_version_id IS NULL)
               AND (X_Pos_Structure_Version_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.position_structure_id = X_Position_Structure_Id)
           OR (    (Recinfo.position_structure_id IS NULL)
               AND (X_Position_Structure_Id IS NULL)))
      AND (   (Recinfo.date_from = X_Date_From)
           OR (    (Recinfo.date_from IS NULL)
               AND (X_Date_From IS NULL)))
      AND (   (Recinfo.version_number = X_Version_Number)
           OR (    (Recinfo.version_number IS NULL)
               AND (X_Version_Number IS NULL)))
      AND (   (Recinfo.copy_structure_version_id = X_Copy_Structure_Version_Id)
           OR (    (Recinfo.copy_structure_version_id IS NULL)
               AND (X_Copy_Structure_Version_Id IS NULL)))
      AND (   (Recinfo.date_to = X_Date_To)
           OR (    (Recinfo.date_to IS NULL)
               AND (X_Date_To IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;
-----------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Pos_Structure_Version_Id            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Position_Structure_Id               NUMBER,
                     X_Date_From                           DATE,
                     X_Version_Number                      NUMBER,
                     X_Copy_Structure_Version_Id           NUMBER ,
                     X_Date_To                             DATE ,
                     X_end_of_time                         DATE,
                     X_Next_no_free                 IN OUT NOCOPY NUMBER,
                     X_closedown_warning            IN OUT NOCOPY VARCHAR2,
                     X_gap_warning                  IN OUT NOCOPY VARCHAR2
) IS
BEGIN
   PER_POS_STRUCTURE_VERSIONS_PKG.check_version_number(
                        X_Position_Structure_Id=> X_Position_Structure_Id
                        ,X_Version_Number => X_Version_Number
                        ,X_Rowid => X_Rowid);
   --
   PER_POS_STRUCTURE_VERSIONS_PKG.check_overlap(
   X_Position_Structure_Id=> X_Position_Structure_Id
   ,X_Rowid => X_Rowid
   ,X_Date_From => X_Date_From
   ,X_Date_To => X_Date_To
   ,X_End_Of_Time => X_End_Of_Time
   ,X_End_Date_Closedown => X_closedown_warning);
   --
   PER_POS_STRUCTURE_VERSIONS_PKG.check_date_gap(X_Date_From => X_Date_From
                            ,X_Date_To => X_Date_To
                            ,X_gap_warning => X_gap_warning
                            ,X_Position_Structure_Id =>X_Position_Structure_Id
                            ,X_Rowid => X_Rowid);
   --
  UPDATE PER_POS_STRUCTURE_VERSIONS
  SET
    pos_structure_version_id                  =    X_Pos_Structure_Version_Id,
    business_group_id                         =    X_Business_Group_Id,
    position_structure_id                     =    X_Position_Structure_Id,
    date_from                                 =    X_Date_From,
    version_number                            =    X_Version_Number,
    copy_structure_version_id                 =    X_Copy_Structure_Version_Id,
    date_to                                   =    X_Date_To
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
  X_Next_no_free :=PER_POS_STRUCTURE_VERSIONS_PKG.get_next_free_no(
                  X_Position_Structure_Id =>X_Position_Structure_Id);
END Update_Row;
-----------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_Pos_Structure_Version_Id NUMBER,
                     X_Business_Group_Id NUMBER,
                     X_Position_Structure_Id NUMBER,
                     X_Hr_Installed VARCHAR2,
                     X_Next_no_free                 IN OUT NOCOPY NUMBER,
                     X_closedown_warning            IN OUT NOCOPY VARCHAR2) IS
BEGIN
  pre_delete_checks(X_Pos_Structure_Version_Id => X_Pos_Structure_Version_Id,
                    X_Business_Group_Id        => X_Business_Group_Id,
                    X_Position_Structure_Id => X_Position_Structure_Id,
                    X_Hr_Installed             => X_Hr_Installed);
--
  DELETE FROM PER_POS_STRUCTURE_VERSIONS
  WHERE  rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
  X_Next_no_free :=PER_POS_STRUCTURE_VERSIONS_PKG.get_next_free_no(
                  X_Position_Structure_Id =>X_Position_Structure_Id);
END Delete_Row;
-----------------------------------------------------------------------------
END PER_POS_STRUCTURE_VERSIONS_PKG;

/
