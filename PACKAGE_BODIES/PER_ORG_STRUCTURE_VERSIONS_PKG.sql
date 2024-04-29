--------------------------------------------------------
--  DDL for Package Body PER_ORG_STRUCTURE_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ORG_STRUCTURE_VERSIONS_PKG" as
/* $Header: peosv01t.pkb 115.6 2002/12/06 16:34:45 pkakar ship $ */
-------------------------------------------------------------------------------
FUNCTION get_next_free_no(p_Org_Structure_Version_Id NUMBER) return NUMBER is
--
-- Gets the next free number in an Organization Hierarchy.
--
   l_next_no number; -- Next free version number in a hierarchy.
--
begin
   --
   -- No exception.
   -- Will always return 1 row irrespective of p_Org_Structure_Version_Id
   -- Existing or not.
   --
  select nvl(max(osv.version_number), 0) + 1
  into   l_next_no
  from   per_org_structure_versions osv
  where  osv.organization_structure_id = p_Org_Structure_Version_Id;
   --
  return l_next_no;
end get_next_free_no;
-------------------------------------------------------------------------------
PROCEDURE check_date_gaps(p_org_structure_id  NUMBER
                         ,p_date_to DATE
                         ,p_date_from DATE
                         ,p_rowid VARCHAR2
                         ,p_gap_warning in out nocopy VARCHAR2) is
--
-- Test for Gaps between hierarchy versions.
-- i.e. 1 10-Feb-94 16-Feb-94
--      2 20-Mar-94
-- would flag a message as gap exists.
--
   l_max_end DATE; -- Maximum end date for the Hierarchy.
   l_min_start DATE; -- Minimum start date for the hierarchy.
--
begin
   p_gap_warning := 'N';
   select max(osv.date_to)
   into   l_max_end
   from   per_org_structure_versions osv
   where  osv.organization_structure_id = p_org_structure_id
   and    osv.date_from < p_date_from
   and   (osv.rowid <> p_rowid
   or    p_rowid is null);
   --
   if (l_max_end is not null and p_date_from = (l_max_end + 1))
   or (l_max_end is null) then
      select min(osv.date_from)
      into   l_min_start
      from   per_org_structure_versions osv
      where  osv.organization_structure_id = p_org_structure_id
      and    osv.date_from > p_date_from
      and   (osv.rowid <> p_rowid
      or    p_rowid is null);
      --
      if l_min_start is null then
         return;
      elsif (p_date_to + 1) = l_min_start then
         return;
      end if;
   end if;
   p_gap_warning := 'Y';
end check_date_gaps;
-------------------------------------------------------------------------------
PROCEDURE check_version_number(p_org_structure_id NUMBER
                              ,p_version_number NUMBER
                              ,p_rowid VARCHAR2) is
--
-- Enusre the version number does not exist.
--
   l_dummy VARCHAR2(1);
--
begin
   select  null
   into l_dummy
   from sys.dual
   where exists (select 1
               from    per_org_structure_versions      osv
               where   osv.organization_structure_id   = p_org_structure_id
               and     osv.version_number              = p_version_number
               and     (osv.rowid                      <> p_rowid
               or      p_rowid is null));
   --
   hr_utility.set_message('801','HR_6077_PO_POS_DUP_VER');
   hr_utility.raise_error;
   --
   exception
      when no_data_found then
         null;
   end check_version_number;
-------------------------------------------------------------------------------
PROCEDURE check_overlap(p_org_structure_id NUMBER
                     ,p_rowid VARCHAR2
                     ,p_date_from DATE
                     ,p_date_to DATE
                     ,p_end_of_time DATE
                     ,p_end_date_closedown in out nocopy  VARCHAR2) is

--
-- Check for overlapping structure versions
--
   l_dummy VARCHAR2(1);
--
begin
   --
   p_end_date_closedown := 'N';
   --
   begin
      select  null
      into l_dummy
      from sys.dual
      where  exists
      (select 1
      from    per_org_structure_versions      osv
      where   osv.organization_structure_id   = p_org_structure_id
      and     p_date_from                 > osv.date_from
      and     osv.date_to                     is null);
      --
      -- If none exist it will exit normally
      --
      begin
         --
         -- Close down the open structures, before doing the test for overlaps
         --
         update  per_org_structure_versions      osv
         set     osv.date_to                     = (p_date_from - 1)
         where   osv.organization_structure_id   = p_org_structure_id
         and     osv.date_to                     is null
         and     (osv.rowid                      <> p_rowid
         or      p_rowid                     is null);
         --
         if sql%rowcount <>0 then
            p_end_date_closedown := 'Y';
         end if;
      end;
      exception
         when no_data_found then
            null;
   end;
   begin
      --
      -- test for overlapping rows.
      --
      select  null
      into l_dummy
      from sys.dual
      where exists
         (select 1
         from    per_org_structure_versions      osv
         where   osv.date_from                   <= nvl(p_date_to,
         p_end_of_time)
         and     nvl(osv.date_to, p_end_of_time)
         >= p_date_from
         and     osv.organization_structure_id   = p_org_structure_id
         and     (osv.rowid                      <> p_rowid
         or      p_rowid                     is null));
      --
      hr_utility.set_message('801','HR_6076_PO_POS_OVERLAP');
      hr_utility.raise_error;
      --
   end;
   exception
      when no_data_found then
         null;
end check_overlap;
-------------------------------------------------------------------------------
PROCEDURE check_position_flag (
                    p_organization_structure_id NUMBER
                   ,p_pos_control_enabled_flag VARCHAR2) is

cursor c1 is
select str.position_control_structure_flg
from per_organization_structures str
where str.organization_structure_id = p_organization_structure_id;

l_result varchar2(10);

begin
--
  if p_pos_control_enabled_flag = 'Y' then
  --
    open c1;
    fetch c1 into l_result;

    if c1%found then
    --
      if l_result <> 'Y' then
      --
        close c1;
        hr_utility.set_message('800','PER_50055_NON_POS_CTRL_STRUCT');
        hr_utility.raise_error;
      --
      end if;
    --
    end if;

    close c1;
  --
  end if;
--
end check_position_flag;
--------------------------------------------------------------------------------
PROCEDURE copy_elements(p_org_structure_version_id NUMBER
							  ,p_copy_structure_version_id NUMBER) IS
--
--
-- Define cursor for inserts
--
cursor struct_element is  select *
from per_org_structure_elements ose
where ose.org_structure_version_id = p_copy_structure_version_id;
--
-- Local Variable
--
ele_record struct_element%ROWTYPE;
l_rowid VARCHAR2(20);
begin
	open struct_element;
	fetch struct_element into ele_record;
	loop
		exit when struct_element%NOTFOUND;
		INSERT INTO PER_ORG_STRUCTURE_ELEMENTS(
			org_structure_element_id,
			business_group_id,
			organization_id_parent,
			org_structure_version_id,
			organization_id_child
		  ) VALUES (
			PER_ORG_STRUCTURE_ELEMENTS_S.NEXTVAL,
			ele_record.Business_Group_Id,
			ele_record.Organization_Id_Parent,
			p_org_structure_version_id,
			ele_record.Organization_Id_Child
			);
--
		fetch struct_element into ele_record;
	end loop;
	close struct_element;
end copy_elements;
------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                        IN OUT NOCOPY VARCHAR2,
                     p_Org_Structure_Version_Id            IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Organization_Structure_Id           NUMBER,
                     p_Date_From                           DATE,
                     p_Version_Number                      NUMBER,
                     p_Copy_Structure_Version_Id           NUMBER,
                     p_Date_To                             DATE,
                     p_Pos_Ctrl_Enabled_Flag               VARCHAR2,
                     p_end_of_time                         DATE,
                     p_Next_no_free                 IN OUT NOCOPY NUMBER,
                     p_closedown_warning            IN OUT NOCOPY VARCHAR2,
                     p_gap_warning                  IN OUT NOCOPY VARCHAR2
 ) IS
 --
   CURSOR C IS SELECT rowid
      FROM PER_ORG_STRUCTURE_VERSIONS
      WHERE org_structure_version_id = p_Org_Structure_Version_Id;
   CURSOR C2 IS SELECT per_org_structure_versions_s.nextval
      FROM sys.dual;
--
BEGIN
   PER_ORG_STRUCTURE_VERSIONS_PKG.check_version_number(
      p_org_structure_id => p_Organization_Structure_Id
      ,p_version_number => p_version_number
      ,p_rowid => p_rowid);
   --
   PER_ORG_STRUCTURE_VERSIONS_PKG.check_overlap(
      p_org_structure_id => p_Organization_Structure_Id
      ,p_rowid => p_rowid
      ,p_date_from => p_date_from
      ,p_date_to => p_date_to
      ,p_end_of_time =>p_end_of_time
      ,p_end_date_closedown => p_closedown_warning);
   --
   PER_ORG_STRUCTURE_VERSIONS_PKG.check_date_gaps(
      p_org_structure_id=> p_Organization_Structure_Id
      ,p_rowid => p_rowid
      ,p_date_from => p_date_from
      ,p_date_to => p_date_to
      ,p_gap_warning =>p_gap_warning);
   --
   check_position_flag(
                    p_organization_structure_id => p_organization_structure_id
                   ,p_pos_control_enabled_flag => p_pos_ctrl_enabled_flag);
   --

   if (p_Org_Structure_Version_Id is NULL) then
      OPEN C2;
      FETCH C2 INTO p_Org_Structure_Version_Id;
      CLOSE C2;
   end if;
   INSERT INTO PER_ORG_STRUCTURE_VERSIONS(
      org_structure_version_id,
      business_group_id,
      organization_structure_id,
      date_from,
      version_number,
      copy_structure_version_id,
      date_to,
      topnode_pos_ctrl_enabled_flag
      ) VALUES (
      p_Org_Structure_Version_Id,
      p_Business_Group_Id,
      p_Organization_Structure_Id,
      p_Date_From,
      p_Version_Number,
      p_Copy_Structure_Version_Id,
      p_Date_To,
      p_Pos_Ctrl_Enabled_Flag
      );
   OPEN C;
   FETCH C INTO p_Rowid;
   if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
   end if;
   CLOSE C;
   if p_copy_structure_version_id is not null then
     copy_elements(p_org_structure_version_id => p_Org_Structure_Version_Id
                   ,p_copy_structure_version_id =>p_Copy_Structure_Version_Id);
   end if;
   p_Next_no_free:=get_next_free_no(p_Organization_Structure_Id);
END Insert_Row;
------------------------------------------------------------------------------
PROCEDURE Lock_Row(p_Rowid                                 VARCHAR2,
                p_Org_Structure_Version_Id              NUMBER,
                   p_Business_Group_Id                     NUMBER,
                   p_Organization_Structure_Id             NUMBER,
                   p_Date_From                             DATE,
                   p_Version_Number                        NUMBER,
                   p_Copy_Structure_Version_Id             NUMBER,
                   p_Date_To                               DATE,
                   p_Pos_Ctrl_Enabled_Flag                 VARCHAR2

) IS
   CURSOR C IS
      SELECT *
      FROM   PER_ORG_STRUCTURE_VERSIONS
      WHERE  rowid = p_Rowid
      FOR UPDATE of Org_Structure_Version_Id NOWAIT;
   Recinfo C%ROWTYPE;
--
BEGIN
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
       (   (Recinfo.org_structure_version_id = p_Org_Structure_Version_Id)
        OR (    (Recinfo.org_structure_version_id IS NULL)
            AND (p_Org_Structure_Version_Id IS NULL)))
   AND (   (Recinfo.business_group_id = p_Business_Group_Id)
        OR (    (Recinfo.business_group_id IS NULL)
            AND (p_Business_Group_Id IS NULL)))
   AND (   (Recinfo.organization_structure_id = p_Organization_Structure_Id)
        OR (    (Recinfo.organization_structure_id IS NULL)
            AND (p_Organization_Structure_Id IS NULL)))
   AND (   (Recinfo.date_from = p_Date_From)
        OR (    (Recinfo.date_from IS NULL)
            AND (p_Date_From IS NULL)))
   AND (   (Recinfo.version_number = p_Version_Number)
        OR (    (Recinfo.version_number IS NULL)
            AND (p_Version_Number IS NULL)))
   AND (   (Recinfo.copy_structure_version_id = p_Copy_Structure_Version_Id)
        OR (    (Recinfo.copy_structure_version_id IS NULL)
            AND (p_Copy_Structure_Version_Id IS NULL)))
   AND (   (Recinfo.topnode_pos_ctrl_enabled_flag = p_pos_ctrl_enabled_flag)
        OR (    (Recinfo.topnode_pos_ctrl_enabled_flag IS NULL)
            AND (p_pos_ctrl_enabled_flag IS NULL)))
   AND (   (Recinfo.date_to = p_Date_To)
        OR (    (Recinfo.date_to IS NULL)
            AND (p_Date_To IS NULL)))
       ) then
      return;
   else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
END Lock_Row;
------------------------------------------------------------------------------
PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Org_Structure_Version_Id            NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Organization_Structure_Id           NUMBER,
                     p_Date_From                           DATE,
                     p_Version_Number                      NUMBER,
                     p_Copy_Structure_Version_Id           NUMBER,
                     p_Date_To                             DATE,
                     p_Pos_Ctrl_Enabled_Flag               VARCHAR2,
                     p_end_of_time                         DATE,
                     p_Next_no_free                 IN OUT NOCOPY NUMBER,
                     p_closedown_warning            IN OUT NOCOPY VARCHAR2,
                     p_gap_warning                  IN OUT NOCOPY VARCHAR2
) IS
BEGIN
   --
   PER_ORG_STRUCTURE_VERSIONS_PKG.check_version_number(
      p_org_structure_id => p_Organization_Structure_Id
      ,p_version_number => p_version_number
      ,p_rowid => p_rowid);
   --
   PER_ORG_STRUCTURE_VERSIONS_PKG.check_overlap(
      p_org_structure_id => p_Organization_Structure_Id
      ,p_rowid => p_rowid
      ,p_date_from => p_date_from
      ,p_date_to => p_date_to
      ,p_end_of_time =>p_end_of_time
      ,p_end_date_closedown => p_closedown_warning);
   --
   check_position_flag(
                    p_organization_structure_id => p_organization_structure_id
                   ,p_pos_control_enabled_flag => p_pos_ctrl_enabled_flag);
   --

   UPDATE PER_ORG_STRUCTURE_VERSIONS
   SET
   org_structure_version_id                  =    p_Org_Structure_Version_Id,
   business_group_id                         =    p_Business_Group_Id,
   organization_structure_id                 =    p_Organization_Structure_Id,
   date_from                                 =    p_Date_From,
   version_number                            =    p_Version_Number,
   copy_structure_version_id                 =    p_Copy_Structure_Version_Id,
   date_to                                   =    p_Date_To,
   topnode_pos_ctrl_enabled_flag             =    p_Pos_Ctrl_Enabled_Flag
   WHERE rowid = p_rowid;
   if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
   end if;
   p_Next_no_free:=get_next_free_no(p_Organization_Structure_Id);
END Update_Row;
------------------------------------------------------------------------------
--
--
PROCEDURE pre_delete_checks(p_org_Structure_Version_Id NUMBER,
                     p_Pa_Installed VARCHAR2) is
--
-- Ensure that there are no child records existing for this
-- version. Oracle 7's constraints will handle this but it is rather
-- unfriendly to the user.
--
   l_dummy VARCHAR2(1);
begin
   begin
   select null
   into l_dummy
   from sys.dual
   where exists ( select 1
               from per_org_structure_elements ose
               where ose.org_structure_version_id = p_org_Structure_Version_Id
               );
   --
   hr_utility.set_message('801','HR_6204_ORG_SUBORD_EXIST');
   hr_utility.raise_error;
   --
   exception
   when no_data_found then
      null;
   end;
   if p_Pa_Installed = 'I' then
      pa_org.pa_osv_predel_validation(p_org_Structure_Version_Id);
   end if;
end pre_delete_checks;
------------------------------------------------------------------------------
PROCEDURe update_copied_versions(p_org_Structure_Version_Id NUMBER) is
--
-- If a version has been deleted and its structure has been copied by
-- another version then null this reference.
--
cursor update_osv is
   select rowid
   from   per_org_structure_versions osv
   where osv.copy_structure_version_id = p_org_Structure_Version_Id
   for update of osv.copy_structure_version_id nowait;
   --
   l_copied_rowid ROWID;
   --
begin
   --
   open update_osv;
   loop
      fetch update_osv into l_copied_rowid;
      exit when update_osv%NOTFOUND;
      --
      update per_org_structure_versions osv
      set    osv.copy_structure_version_id = ''
      where  rowid = l_copied_rowid;
   end loop;
   close update_osv;
end;
------------------------------------------------------------------------------
PROCEDURE Delete_Row(p_Rowid VARCHAR2,
                     p_Organization_Structure_Id NUMBER,
                     p_org_Structure_Version_Id NUMBER,
                     p_Pa_Installed VARCHAR2,
                     p_Date_From DATE,
                     p_Date_To DATE,
                     p_gap_warning IN OUT NOCOPY VARCHAR2,
                     p_Next_no_free IN OUT NOCOPY NUMBER) IS
BEGIN
   pre_delete_checks(p_org_Structure_Version_Id => p_org_Structure_Version_Id,
                     p_Pa_Installed => p_Pa_Installed);
   --
   DELETE FROM PER_ORG_STRUCTURE_VERSIONS
   WHERE  rowid = p_Rowid;
   if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
   end if;
   --
   update_copied_versions(
      p_org_Structure_Version_Id =>p_org_Structure_Version_Id);
   --
   PER_ORG_STRUCTURE_VERSIONS_PKG.check_date_gaps(
      p_org_structure_id=> p_Organization_Structure_Id
      ,p_rowid => p_rowid
      ,p_date_from => p_date_from
      ,p_date_to => p_date_to
      ,p_gap_warning =>p_gap_warning);
   --
   p_Next_no_free:=get_next_free_no(p_Organization_Structure_Id);
END Delete_Row;
------------------------------------------------------------------------------
END PER_ORG_STRUCTURE_VERSIONS_PKG;

/
