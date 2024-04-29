--------------------------------------------------------
--  DDL for Package Body PER_ORG_STRUCTURE_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ORG_STRUCTURE_ELEMENTS_PKG" as
/* $Header: peose01t.pkb 120.1.12010000.2 2009/02/25 08:33:18 sidsaxen ship $ */
------------------------------------------------------------------------------
FUNCTION get_subordinates(p_view_all_orgs VARCHAR2
                         ,p_org_id_parent NUMBER
                         ,p_org_structure_version_id NUMBER
                         ,p_security_profile_id NUMBER) return NUMBER is
--
l_count NUMBER;
--
begin
   --
   -- Return the number of subordinates of a given organization
   -- in a given hierarchy
   --
   -- If security exists then return  only those in
   -- the current security profile
   --
   --fix for bug 4389340 starts here
   select  nvl( count(ose.org_structure_element_id), 0)
   into l_count
   from    per_org_structure_elements      ose
   where   ((nvl(p_view_all_orgs,'Y') <> 'Y'
      and EXISTS
         (select '1'
         from    hr_organization_units hru
         where   hru.organization_id = ose.organization_id_child
         ))
      or nvl(p_view_all_orgs,'Y') = 'Y')
   connect by
      prior ose.organization_id_child = ose.organization_id_parent
      and     ose.org_structure_version_id    = p_org_structure_version_id
   start with
      ose.organization_id_parent      = p_org_id_parent
      and     ose.org_structure_version_id    = p_org_structure_version_id;
   -- fix for bug 4389340 ends here.
   -- no exception necessary as a single row group FUNCTION
   -- hence no no_data_found or Too_many_rows errors;
   return l_count;
end;
-------------------------------------------------------------------------------
PROCEDURE maintain_org_lists(p_business_group_id  NUMBER
                            ,p_security_profile_id  NUMBER
                            ,p_organization_id  NUMBER
                            ) is
--
-- Local variables
--
   l_sec_view_all_orgs_flag VARCHAR2(1);
   l_sec_org_structure_id NUMBER;
   l_sec_org_id NUMBER;
   l_sec_include_top_org_flag VARCHAR2(1);
-- Local Functions and Procedures
PROCEDURE insert_rows(p_security_profile_id NUMBER
                     ,p_organization_id  NUMBER
                     ) is
--
begin
    hr_security.add_organization(p_organization_id,
                                 p_security_profile_id);
   -- No rows inserted - raise error to the effect.
   if SQL%ROWCOUNT <>1 then
      hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','maintain_org_lists');
      hr_utility.set_message_token('STEP','2');
      hr_utility.raise_error;
   end if;
   --
end insert_rows;
--
FUNCTION tree_walk(p_sec_org_structure_id NUMBER
                  ,p_business_group_id NUMBER
                  ,p_organization_id NUMBER
                  ,p_sec_org_id NUMBER) return BOOLEAN is
--
   l_temp VARCHAR2(1);
--
begin
   --
   -- 'Walk' down the hierarchy.
   -- If organization exists in tree,
   -- Then return true else return false
   --
   select  null
   into l_temp
   from    sys.dual
   where exists (select null
                  from sys.dual
                  where   p_organization_id in
                     (select a.organization_id_child
                     from   per_org_structure_elements a
                     where  (  a.business_group_id + 0 = p_business_group_id
                            or (   a.business_group_id is null
                               and p_business_group_id is null))
                     and    a.org_structure_version_id in
                        ( select x.org_structure_version_id
                        from   per_org_structure_versions x
                        where x.organization_structure_id =
                           p_sec_org_structure_id)
                  connect by prior
                     a.organization_id_child = a.organization_id_parent
                     and    a.org_structure_version_id in
                        ( select x.org_structure_version_id
                        from   per_org_structure_versions x
                        where x.organization_structure_id =
                           p_sec_org_structure_id)
                     and    (  a.business_group_id + 0 = p_business_group_id
                            or (   a.business_group_id is null
                               and p_business_group_id is null))
                  start with
                     a.organization_id_parent = p_sec_org_id
                     and    a.org_structure_version_id in
                           ( select x.org_structure_version_id
                           from   per_org_structure_versions x
                           where x.organization_structure_id =
                              p_sec_org_structure_id)
                           and    (  a.business_group_id + 0 = p_business_group_id
                                  or (   a.business_group_id is null
                                     and p_business_group_id is null)))
                  );
   --
   return true;
   --
   exception
      when no_data_found then
         return false;
      when others then
         raise;
end tree_walk;
--
begin
   --
   -- Maintain the security profile
   -- Organization list
   --
   begin
      -- Get the security profile information.
      select  x.view_all_organizations_flag
      ,       x.organization_structure_id
      ,       x.organization_id
      ,       x.include_top_organization_flag
      into    l_sec_view_all_orgs_flag
      ,       l_sec_org_structure_id
      ,       l_sec_org_id
      ,       l_sec_include_top_org_flag
      from    per_security_profiles x
      where   (  x.business_group_id + 0     = p_business_group_id
              or x.business_group_id is null)
      and     x.security_profile_id   = p_security_profile_id;
      --
      exception
         when no_data_found then
            hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','maintain_org_lists');
            hr_utility.set_message_token('STEP','1');
            hr_utility.raise_error;
         when others then raise;
   end;
   --
   if l_sec_view_all_orgs_flag = 'N' then
      return;
   elsif l_sec_view_all_orgs_flag = 'Y' then
      insert_rows(p_security_profile_id
         ,p_organization_id
         );
   elsif l_sec_include_top_org_flag = 'N' then
      if tree_walk(l_sec_org_structure_id
               ,p_business_group_id
               ,p_organization_id
               ,l_sec_org_id ) then
            insert_rows(p_security_profile_id
               ,p_organization_id
               );
      end if;
   elsif l_sec_org_id = p_organization_id then
      insert_rows(p_security_profile_id
         ,p_organization_id
         );
   elsif tree_walk(l_sec_org_structure_id
            ,p_business_group_id
            ,p_organization_id
            ,l_sec_org_id) then
      insert_rows(p_security_profile_id
         ,p_organization_id
         );
   end if;
end maintain_org_lists;
------------------------------------------------------------------------------
PROCEDURE delete_validation(p_org_structure_version_id NUMBER
                           ,p_org_structure_element_id NUMBER
                           ,p_org_id_child NUMBER
                           ,p_org_id_parent NUMBER
                           ,p_hr_installed VARCHAR2
                           ,p_pa_installed VARCHAR2) is
--
l_temp VARCHAR2(1);
--
begin
   --
   -- Pre-delete checks for subordinate
   -- organizations in the hierarchy.
   --
   begin
      select  null
      into l_temp
      from sys.dual
      where exists (select null
                     from per_org_structure_elements      ose
                     where   ose.org_structure_version_id    =
                                          p_org_structure_version_id
                     and     ose.organization_id_parent      =
                                          p_org_id_child);
      --
      hr_utility.set_message('801','HR_6190_ORG_CHILDREN_EXIST');
      hr_utility.raise_error;
      --
      exception
         when no_data_found then
            null;
         when others then
            raise;
   end;
   --
   --
   -- If the child org in the element = top org in an
   -- security_profile and hierarchies are the same
   -- then cannot delete it.
   -- similarly if the parent_org in the element = top org in a
   --security_profile and hierarchies are the same
   -- then you cannot delete it if it is the parent of no other
   -- org_structure_element for this version.
   --
   if p_hr_installed = 'I' then
      begin
         select null
         into l_temp
         from sys.dual
         where exists( select null
                     from per_security_profiles psp
                     where   psp.include_top_organization_flag = 'Y'
                     and     psp.organization_structure_id     =
                           (select osv.organization_structure_id
                           from    per_org_structure_versions osv
                           where   osv.org_structure_version_id =
                                 p_org_structure_version_id)
                     and   ((psp.organization_id = p_org_id_child)
                        or(psp.organization_id = p_org_id_parent
                           and not exists (
                              select  null
                              from    per_org_structure_elements ose
                              where   ose.org_structure_version_id  =
                                       p_org_structure_version_id
                              and     ose.organization_id_child     =
                                       p_org_id_parent
                              )
                           and     not exists (
                              select  null
                              from    per_org_structure_elements ose
                              where   ose.org_structure_version_id  =
                                       p_org_structure_version_id
                              and     ose.org_structure_element_id  <>
                                       p_org_structure_element_id
                              and     ose.organization_id_parent    =
                                       p_org_id_parent
                              )
                           )
                        ) );
      --
      hr_utility.set_message('801','HR_6753_ORG_HIER_SP_DEL');
      hr_utility.raise_error;
      --
      exception
         when no_data_found then
            null;
         when others then
            raise;
      end;
   end if;
   --
   -- Run the validation PROCEDURE writtrn by PA development group.
   --
   -- Bug 516069: Changed 'Y' to 'I' to pick up correct value.
   --
   if p_pa_installed = 'I' then
      pa_org.pa_ose_predel_validation(p_org_structure_element_id);
   end if;
end;
-------------------------------------------------------------------------------
PROCEDURE perwsdor_delete_check(p_org_structure_version_id NUMBER
                               ,p_org_structure_element_id NUMBER
                               ,p_org_id_child NUMBER
                               ,p_org_id_parent NUMBER
                               ,p_business_group_id NUMBER
                               ,p_hr_installed VARCHAR2
                               ,p_pa_installed VARCHAR2) is
cursor c1 is select 'Y'
 from   per_org_structure_elements pos
 where  pos.org_structure_version_id = p_org_structure_version_id
 and   (not exists
           (select null
            from   per_org_structure_elements pos2
            where  pos2.org_structure_version_id
                   = p_org_structure_version_id
            and    pos2.organization_id_child =
                    p_org_id_parent
           )
and     1 =(select count(pos3.ORG_STRUCTURE_VERSION_ID)
            from   per_org_structure_elements pos3
            where  pos3.org_structure_version_id
                   = p_org_structure_version_id
            and    pos3.organization_id_parent =
                 p_org_id_parent
           )
OR     (not exists
        (select null
         from   per_org_structure_elements pos3
         where  pos3.org_structure_version_id =
                p_org_structure_version_id
         and    pos3.organization_id_parent = p_org_id_child)
      )
     );
--
cursor c2 is
select 'Y'
from   per_security_profiles psp
,      per_org_structure_versions posv
where  (  psp.business_group_id         =p_business_group_id
       or (   psp.business_group_id is null
          and p_business_group_id is null))
and    psp.organization_id           = p_org_id_child
and    (  psp.business_group_id         = posv.business_group_id
       or (   psp.business_group_id is null
          and posv.business_group_id is null))
and    psp.organization_structure_id = posv.organization_structure_id
and    posv.org_structure_version_id = p_org_structure_version_id;
--
l_dummy varchar2(1);
begin
  open c1;
  fetch c1 into l_dummy;
  if c1%FOUND then
   close c1;
   hr_utility.set_message('801','HR_6740_ORG_HIER_CANT_DELETE');
   hr_utility.raise_error;
  end if;
  close c1;
  if p_hr_installed IN ('I','S') then
    open c2;
     fetch c2 into l_dummy;
     if c2%FOUND then
       close c2;
       hr_utility.set_message('801','PAY_7694_PER_NO_DEL_STRUCTURE');
       hr_utility.raise_error;
    end if;
  end if;
  --
  -- Bug 516069: Changed <> 'Y' to = 'I' to pick up correct value.
  --
  if p_pa_installed = 'I' then
    pa_org.pa_ose_predel_validation(p_org_structure_element_id);
  end if;
end;
-------------------------------------------------------------------------------
PROCEDURE check_duplicate_entry (p_org_structure_version_id NUMBER
                   ,p_org_structure_element_id NUMBER) is
--
l_temp VARCHAR2(1);
--
begin
   --
   -- Duplicate subordinate name? (Child can only have one parent)
   --
   select null
   into l_temp
   from sys.dual
   where exists( select  null
               from    per_org_structure_elements      ose
               where   ose.org_structure_version_id    =
                        p_org_structure_version_id
               and     ose.organization_id_child       =
                        p_org_structure_element_id);
   --
   hr_utility.set_message('801','HR_6186_ORG_DUP_CHILD');
   hr_utility.raise_error;
   --
   exception
      when no_data_found then
         null;
      when others then
         raise;
end check_duplicate_entry;
--
PROCEDURE check_org_active(p_org_id_parent NUMBER
                   ,p_date_from DATE
                   ,p_end_of_time DATE
                   ,p_warning_raised IN OUT NOCOPY VARCHAR2) is
--
l_temp VARCHAR2(1);
--
begin
   --
   -- Is the Organization structure element effective as of start date
   --
   select null
   into l_temp
   from sys.dual
   where exists(select  null
               from    hr_all_organization_units org
               where   org.organization_id     = p_org_id_parent
               and     p_date_from between
                     org.date_from and nvl(org.date_to, p_end_of_time)
               );
   --
   --
   p_warning_raised :='N';
   exception
      when no_data_found then
         hr_utility.set_message('801','HR_ORG_INACT_ORG');
         p_warning_raised:='Y';
      when others then
         raise;
end check_org_active;
-------------------------------------------------------------------------------
PROCEDURE check_position_flag (
                    p_org_structure_version_id NUMBER
                   ,p_pos_control_enabled_flag VARCHAR2) is

cursor c1 is
select str.position_control_structure_flg
from per_organization_structures str,
     per_org_structure_versions osv
where osv.org_structure_version_id = p_org_structure_version_id
and osv.organization_structure_id = str.organization_structure_id;

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
------------------------------------------------------------------------------
FUNCTION post_delete_check(p_org_structure_version_id NUMBER
                           ,p_organization_id NUMBER) return BOOLEAN is
--
l_temp VARCHAR2(1);
--
begin
   --
   -- Is the currently displayed organization
   -- Still in the hierarchy?
   --
   select null
   into l_temp
   from sys.dual
   where exists( select null
               from    per_org_structure_elements      ose
               where   ose.org_structure_version_id    =
                     p_org_structure_version_id
               and     (ose.organization_id_parent     = p_organization_id
                  or       ose.organization_id_child      = p_organization_id)
               );
   --
   return true;
   --
   exception
      when no_data_found then
         return false;
      when others then
         null;
end post_delete_check;
-------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                        IN OUT NOCOPY VARCHAR2,
                     p_Org_Structure_Element_Id            IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Organization_Id_Parent              NUMBER,
                     p_Org_Structure_Version_Id            NUMBER,
                     p_Organization_Id_Child               NUMBER,
                     p_date_from                           DATE,
                     p_security_profile_id                 NUMBER,
                     p_view_all_orgs                       VARCHAR2,
                     p_end_of_time                         DATE,
                     p_pos_control_enabled_flag            VARCHAR2
 ) IS
--
l_warning_raised VARCHAR2(1);
begin
  Insert_Row(p_Rowid          => p_Rowid,
  p_Org_Structure_Element_Id  => p_Org_Structure_Element_Id,
  p_Business_Group_Id         => p_Business_Group_Id,
  p_Organization_Id_Parent    => p_Organization_Id_Parent,
  p_Org_Structure_Version_Id  => p_Org_Structure_Version_Id,
  p_Organization_Id_Child     => p_Organization_Id_Child,
  p_date_from                 => p_date_from,
  p_security_profile_id       => p_security_profile_id,
  p_view_all_orgs             => p_view_all_orgs,
  p_end_of_time               => p_end_of_time,
  p_pos_control_enabled_flag  => p_pos_control_enabled_flag,
  p_warning_raised            => l_warning_raised);
end;
------------------------------------------------------------------------------

-- start changes for bug 8200692
PROCEDURE Insert_Row(p_Rowid                         IN OUT NOCOPY VARCHAR2,
                     p_Org_Structure_Element_Id             IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                    NUMBER,
                     p_Organization_Id_Parent               NUMBER,
                     p_Org_Structure_Version_Id             NUMBER,
                     p_Organization_Id_Child                NUMBER,
                     p_date_from                            DATE,
                     p_security_profile_id                  NUMBER,
                     p_view_all_orgs                        VARCHAR2,
                     p_end_of_time                          DATE,
                     p_pos_control_enabled_flag             VARCHAR2,
                     p_warning_raised                IN OUT NOCOPY VARCHAR2
                     ) IS
BEGIN
  Insert_Row(p_Rowid          => p_Rowid,
  p_Org_Structure_Element_Id  => p_Org_Structure_Element_Id,
  p_Business_Group_Id         => p_Business_Group_Id,
  p_Organization_Id_Parent    => p_Organization_Id_Parent,
  p_Org_Structure_Version_Id  => p_Org_Structure_Version_Id,
  p_Organization_Id_Child     => p_Organization_Id_Child,
  p_date_from                 => p_date_from,
  p_security_profile_id       => p_security_profile_id,
  p_view_all_orgs             => p_view_all_orgs,
  p_end_of_time               => p_end_of_time,
  p_pos_control_enabled_flag  => p_pos_control_enabled_flag,
  p_warning_raised            => p_warning_raised,
  p_pa_installed              => 'N');
END;
-- end changes for bug 8200692

------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                         IN OUT NOCOPY VARCHAR2,
                     p_Org_Structure_Element_Id             IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                    NUMBER,
                     p_Organization_Id_Parent               NUMBER,
                     p_Org_Structure_Version_Id             NUMBER,
                     p_Organization_Id_Child                NUMBER,
                     p_date_from                            DATE,
                     p_security_profile_id                  NUMBER,
                     p_view_all_orgs                        VARCHAR2,
                     p_end_of_time                          DATE,
                     p_pos_control_enabled_flag             VARCHAR2,
                     p_warning_raised                IN OUT NOCOPY VARCHAR2,
                     p_pa_installed                         VARCHAR2 --added for bug 8200692
                     ) IS
--
   CURSOR C IS SELECT rowid FROM PER_ORG_STRUCTURE_ELEMENTS
       WHERE org_structure_element_id = p_Org_Structure_Element_Id;
   CURSOR C2 IS SELECT per_org_structure_elements_s.nextval FROM sys.dual;
--
cursor get_details is select rowid,org_structure_element_id,
business_group_id,organization_id_parent,org_structure_version_id,
organization_id_child, position_control_enabled_flag
from per_org_structure_elements
where organization_id_child = p_Organization_Id_Child
and   org_structure_version_id = p_org_structure_version_id;
--
Recinfo get_details%ROWTYPE;
--
BEGIN
   --
   -- Pre -insert validation
   --
   --
   check_position_flag (
                    p_org_structure_version_id => p_org_structure_version_id
                   ,p_pos_control_enabled_flag => p_pos_control_enabled_flag);

   check_org_active(p_Organization_Id_Parent,
                  p_date_from
                  ,p_end_of_time
                  ,p_warning_raised => p_warning_raised);
  if ((hr_organization_units_pkg.exists_in_hierarchy(p_org_structure_version_id
                            ,p_organization_id_child) = 'Y')) then
--
--    Yes , then merely update the old structure element
--
      open get_details;
      fetch get_details into Recinfo;
      if get_details%found then
--
--       Lock the row
--
PER_ORG_STRUCTURE_ELEMENTS_PKG.Lock_Row(p_Rowid => Recinfo.ROWID,
                 p_Org_Structure_Element_Id =>Recinfo.Org_Structure_Element_Id,
                 p_Business_Group_Id =>Recinfo.Business_Group_Id,
                 p_Organization_Id_Parent =>Recinfo.Organization_Id_Parent,
                 p_Org_Structure_Version_Id=>Recinfo.Org_Structure_Version_Id,
                 p_Organization_Id_Child =>Recinfo.Organization_Id_Child,
                 p_pos_control_enabled_flag => Recinfo.position_control_enabled_flag);
--
--       Update the row
--
PER_ORG_STRUCTURE_ELEMENTS_PKG.Update_Row(p_Rowid=> Recinfo.ROWID,
                p_Org_Structure_Element_Id  =>Recinfo.Org_Structure_Element_Id,
                p_Business_Group_Id  => Recinfo.Business_Group_Id,
                p_Organization_Id_Parent =>p_Organization_Id_Parent,
                p_Org_Structure_Version_Id =>Recinfo.Org_Structure_Version_Id,
                p_Organization_Id_Child    =>Recinfo.Organization_Id_Child,
                p_pos_control_enabled_flag => Recinfo.position_control_enabled_flag,
                p_pa_installed => p_pa_installed); --added for bug 8200692

       p_Rowid := Recinfo.ROWID;
       p_Org_Structure_Element_Id := Recinfo.Org_Structure_Element_Id;
      close get_details;
      return;
    end if;
  end if;
--
   check_duplicate_entry(p_org_structure_version_id
                        ,p_Organization_Id_Child);
--
   if (p_Org_Structure_Element_Id is NULL) then
      OPEN C2;
      FETCH C2 INTO p_Org_Structure_Element_Id;
      CLOSE C2;
   end if;
   --
   INSERT INTO PER_ORG_STRUCTURE_ELEMENTS(
      org_structure_element_id,
      business_group_id,
      organization_id_parent,
      org_structure_version_id,
      organization_id_child,
      position_control_enabled_flag
   ) VALUES (
      p_Org_Structure_Element_Id,
      p_Business_Group_Id,
      p_Organization_Id_Parent,
      p_Org_Structure_Version_Id,
      p_Organization_Id_Child,
      p_pos_control_enabled_flag
   );
   --
   OPEN C;
   FETCH C INTO p_Rowid;
   if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
   end if;
   CLOSE C;
   --
   -- Post-insert code
   -- Maintains org_list security profiles
   --
   if p_view_all_orgs = 'N' then
      per_org_structure_elements_pkg.maintain_org_lists(p_Business_Group_Id
      ,p_security_profile_id
      ,p_Organization_Id_Parent
      );
   end if;
   --
END Insert_Row;
-------------------------------------------------------------------------------
PROCEDURE Lock_Row(p_Rowid                                 VARCHAR2,
                   p_Org_Structure_Element_Id              NUMBER,
                   p_Business_Group_Id                     NUMBER,
                   p_Organization_Id_Parent                NUMBER,
                   p_Org_Structure_Version_Id              NUMBER,
                   p_Organization_Id_Child                 NUMBER,
                   p_pos_control_enabled_flag              VARCHAR2
) IS
  --
  CURSOR C IS
      SELECT *
      FROM   PER_ORG_STRUCTURE_ELEMENTS
      WHERE  rowid = p_Rowid
      FOR UPDATE of Org_Structure_Element_Id NOWAIT;
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
      (   (Recinfo.org_structure_element_id = p_Org_Structure_Element_Id)
         OR (    (Recinfo.org_structure_element_id IS NULL)
            AND (p_Org_Structure_Element_Id IS NULL)))
      AND (   (Recinfo.business_group_id = p_Business_Group_Id)
         OR (    (Recinfo.business_group_id IS NULL)
            AND (p_Business_Group_Id IS NULL)))
      AND (   (Recinfo.organization_id_parent = p_Organization_Id_Parent)
         OR (    (Recinfo.organization_id_parent IS NULL)
            AND (p_Organization_Id_Parent IS NULL)))
      AND (   (Recinfo.org_structure_version_id = p_Org_Structure_Version_Id)
         OR (    (Recinfo.org_structure_version_id IS NULL)
            AND (p_Org_Structure_Version_Id IS NULL)))
      AND (   (Recinfo.organization_id_child = p_Organization_Id_Child)
         OR (    (Recinfo.organization_id_child IS NULL)
            AND (p_Organization_Id_Child IS NULL)))
    --  AND (   (Recinfo.position_control_enabled_flag = p_pos_control_enabled_flag)
    --     OR (    (Recinfo.position_control_enabled_flag IS NULL)
    --        AND (p_pos_control_enabled_flag IS NULL)))
      ) then
         return;
   else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
END Lock_Row;
-------------------------------------------------------------------------------
--bug no 5912009 starts here
PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Org_Structure_Element_Id            NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Organization_Id_Parent              NUMBER,
                     p_Org_Structure_Version_Id            NUMBER,
                     p_Organization_Id_Child               NUMBER,
                     p_pos_control_enabled_flag            VARCHAR2
) IS
BEGIN
                Update_Row(p_Rowid=>p_Rowid,
                     p_Org_Structure_Element_Id=>p_Org_Structure_Element_Id,
                     p_Business_Group_Id=>p_Business_Group_Id,
                     p_Organization_Id_Parent=>p_Organization_Id_Parent,
                     p_Org_Structure_Version_Id=>p_Org_Structure_Version_Id,
                     p_Organization_Id_Child  =>p_Organization_Id_Child,
                     p_pos_control_enabled_flag=>p_pos_control_enabled_flag,
                     p_pa_installed=>'N');
END Update_Row;
PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Org_Structure_Element_Id            NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Organization_Id_Parent              NUMBER,
                     p_Org_Structure_Version_Id            NUMBER,
                     p_Organization_Id_Child               NUMBER,
                     p_pos_control_enabled_flag            VARCHAR2,
                     p_pa_installed                       VARCHAR2
) IS
--bug no 5912009 ends here
BEGIN
   check_position_flag (
                    p_org_structure_version_id => p_org_structure_version_id
                   ,p_pos_control_enabled_flag => p_pos_control_enabled_flag);

--changes for bug 5912009 starts here
   if p_pa_installed = 'I' then
      pa_org.pa_ose_predel_validation(p_org_structure_element_id);
   end if;
--changes for bug 5912009 ends here

   UPDATE PER_ORG_STRUCTURE_ELEMENTS
   SET
      org_structure_element_id                  =    p_Org_Structure_Element_Id,
      business_group_id                         =    p_Business_Group_Id,
      organization_id_parent                    =    p_Organization_Id_Parent,
      org_structure_version_id                  =    p_Org_Structure_Version_Id,
      organization_id_child                     =    p_Organization_Id_Child,
      position_control_enabled_flag             =    p_pos_control_enabled_flag
   WHERE rowid = p_rowid;
   --
   if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
   end if;
END Update_Row;
-------------------------------------------------------------------------------
PROCEDURE Delete_Row(p_Rowid VARCHAR2
                     ,p_org_structure_version_id NUMBER
                     ,p_org_structure_element_id NUMBER
                     ,p_organization_id_child NUMBER
                     ,p_organization_id_parent NUMBER
                     ,p_hr_installed VARCHAR2
                     ,p_exists_in_hierarchy IN OUT NOCOPY VARCHAR2
                     ,p_pa_installed VARCHAR2) IS
--
BEGIN
   --
   -- Do pre-delete validation
   --
   per_org_structure_elements_pkg.delete_validation(
                     p_org_structure_version_id =>p_org_structure_version_id
                     ,p_org_structure_element_id => p_org_structure_element_id
                     ,p_org_id_child => p_organization_id_child
                     ,p_org_id_parent => p_organization_id_parent
                     ,p_hr_installed => p_hr_installed
                     ,p_pa_installed => p_pa_installed);
   -- Perform the delete
   --
   DELETE FROM PER_ORG_STRUCTURE_ELEMENTS
   WHERE  rowid = p_Rowid;
   --
   if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
   end if;
   --
   -- Post-delete checking
   --
   if per_org_structure_elements_pkg.post_delete_check(
                        p_org_structure_version_id => p_org_structure_version_id
                        ,p_organization_id => p_organization_id_parent) then
      p_exists_in_hierarchy :='Y';
   else
      p_exists_in_hierarchy :='N';
   end if;
END Delete_Row;
-------------------------------------------------------------------------------
END PER_ORG_STRUCTURE_ELEMENTS_PKG;

/
