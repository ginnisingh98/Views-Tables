--------------------------------------------------------
--  DDL for Package Body PER_ORG_STRUCTURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ORG_STRUCTURES_PKG" as
/* $Header: peors01t.pkb 120.1 2006/01/04 14:54:24 vbanner noship $ */
------------------------------------------------------------------------------
PROCEDURE form_startup(p_business_group_id NUMBER
                      ,p_security_profile_id IN OUT NOCOPY NUMBER
                      ,p_view_all_orgs IN OUT NOCOPY VARCHAR2
                      ,p_hr_installed IN OUT NOCOPY VARCHAR2
                      ,p_pa_installed IN OUT NOCOPY VARCHAR2)is
--
-- local variables
--
l_pa_installed BOOLEAN;
l_industry VARCHAR2(1);
function get_hr_status return VARCHAR2 is
--
l_hr_installed varchar2(1);
begin
   --
   -- Get status of Any of HR's Product set.
   --
   select 'I'
   into   l_hr_installed
   from sys.dual
   where  exists (select 'I'
                  from fnd_product_installations
                  where application_id between 800 and 899
                  and status = 'I');
   return l_hr_installed;
   exception
      when no_data_found then
        return 'S';
end;
--
begin
   l_pa_installed := fnd_installation.get(appl_id => 275
                    ,dep_appl_id => 275
                    ,status => p_pa_installed
                    ,industry => l_industry);
  --
  -- Get HR INstallation status.
  --
  p_hr_installed := get_hr_status;
-- Now the security Profile.
-- Bug 4911254 ammended where clause.
--
  begin
    select psp.view_all_organizations_flag,
          psp.security_profile_id
    into  p_view_all_orgs,
          p_security_profile_id
    from  per_security_profiles psp
    where psp.security_profile_id = fnd_profile.value('PER_SECURITY_PROFILE_ID')
    and   (  psp.business_group_id + 0	= p_business_group_id
             or psp.business_group_id is null);
    exception
        when no_data_found then
           hr_utility.set_message('801', 'HR_289521_GLOBAL_SEC_PROFILE');
           hr_utility.set_message_token('PROCEDURE', 'form_startup');
           hr_utility.set_message_token('STEP', '1');
           hr_utility.raise_error;
  end;
end form_startup;
------------------------------------------------------------------------------
PROCEDURE check_name_unique(p_name VARCHAR2
         ,p_business_group_id NUMBER
         ,p_rowid VARCHAR2) is
l_exists VARCHAR2(1);
begin
   select 'Y'
   into  l_exists
   from sys.dual
   where exists(
               select 'Name exists'
               from   per_organization_structures os
               where  (  os.business_group_id + 0 = p_business_group_id
                      or (   os.business_group_id is null
                         and p_business_group_id is null))
               and    upper(os.name) = upper(p_name)
               and    (os.rowid <> p_rowid
               or     p_rowid is null));
   --
   hr_utility.set_message('801','PER_7901_SYS_DUPLICATE_RECORDS');
   hr_utility.raise_error;
   --
   exception
      when no_data_found then null;
      when others then raise;
end;
------------------------------------------------------------------------------
Procedure check_primary_flag(p_primary_flag VARCHAR2
         ,p_business_group_id NUMBER
         ,p_rowid VARCHAR2
         ) is
--
l_exists VARCHAR2(1);
--
begin
   select 'Y'
   into  l_exists
   from sys.dual
      where exists(
                  select 'Primary exists'
                  from   per_organization_structures os
                  where  (  os.business_group_id + 0 = p_business_group_id
                         or (   os.business_group_id is null
                            and p_business_group_id is null))
                  and    os.primary_structure_flag = p_primary_flag
                  and    (os.rowid <> p_rowid
                     or     p_rowid is null));
   --
   hr_utility.set_message('801','HR_6085_PO_POS_ONE_PRIMARY');
   hr_utility.raise_error;
   --
   exception
      when no_data_found then null;
      when others then raise;
end;
------------------------------------------------------------------------------
PROCEDURE check_position_control_flag(
          p_organization_structure_id  NUMBER
         ,p_pos_control_structure_flag VARCHAR2
         ,p_business_group_id          NUMBER
         ) is

CURSOR C1 is
select position_control_structure_flg
from per_organization_structures
where position_control_structure_flg = 'Y'
and   organization_structure_id <> nvl(p_organization_structure_id, -1)
-- BUG 1694549
-- add predicate to check for other pos control structures
-- within current business_group only, to allow 1 pos control org hierarchy
-- per business_group.
and business_group_id = p_business_group_id;


cursor C2 is
select 1 from dual
where exists (
select 1
from per_org_structure_elements ose,
     per_org_structure_versions osv
where osv.org_structure_version_id = ose.org_structure_version_id(+)
and (ose.position_control_enabled_flag = 'Y' or
     osv.topnode_pos_ctrl_enabled_flag = 'Y'));

CURSOR C3 is
select *
from per_organization_structures
where organization_structure_id = nvl(p_organization_structure_id, -1);

Recinfo C3%ROWTYPE;

l_duplicate varchar2(10);
l_residual  number;

begin
--
  open c3;
  fetch c3 into Recinfo;
  close c3;

  if p_pos_control_structure_flag = 'Y' then
  --
    open c1;
    fetch c1 into l_duplicate;

    if c1%found then
    --
      close c1;
      hr_utility.set_message('800','PER_50053_POS_CTRL_DUPLICATED');
      hr_utility.raise_error;
    --
    end if;

    close c1;
  --
  elsif ((p_pos_control_structure_flag = 'N') and
         (Recinfo.position_control_structure_flg = 'Y')) then
  --
    open c2;
    fetch c2 into l_residual;

    if c2%found then
    --
      close c2;
      hr_utility.set_message('800', 'PER_50054_POS_CTRL_CHILD');
      hr_utility.raise_error;
    --
    end if;

    close c2;
  --
  end if;
--
end check_position_control_flag;
------------------------------------------------------------------------------
PROCEDURE delete_check(p_organization_structure_id NUMBER
    ,p_business_group_id NUMBER
    ,p_pa_installed VARCHAR2
    ) is
--
l_temp VARCHAR2(1);
--
begin
   begin
   --
   -- Is there an osv row below the current Hierarchy.
   --
   select 1
   into l_temp
   from sys.dual
   where exists( select 1
               from per_org_structure_versions osv
               where (  osv.business_group_id + 0 = p_business_group_id
                     or (   osv.business_group_id is null
                        and p_business_group_id is null))
               and   osv.organization_structure_id =
               p_organization_structure_id
               );
   -- Id I get to here then there's exists a row
   -- so error
   hr_utility.set_message('801','HR_6084_PO_POS_HAS_HIER_VER');
   hr_utility.raise_error;
   exception
      when no_data_found then
         null;
   end;
   --
   if P_pa_installed = 'I' then
      pa_org.pa_os_predel_validation(p_organization_structure_id);
   end if;
end delete_check;
------------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
   X_Organization_Structure_Id           IN OUT NOCOPY NUMBER,
   X_Business_Group_Id                   NUMBER,
   X_Name                                VARCHAR2,
   X_Comments                            VARCHAR2,
   X_Primary_Structure_Flag              VARCHAR2,
   X_Attribute_Category                  VARCHAR2,
   X_Attribute1                          VARCHAR2,
   X_Attribute2                          VARCHAR2,
   X_Attribute3                          VARCHAR2,
   X_Attribute4                          VARCHAR2,
   X_Attribute5                          VARCHAR2,
   X_Attribute6                          VARCHAR2,
   X_Attribute7                          VARCHAR2,
   X_Attribute8                          VARCHAR2,
   X_Attribute9                          VARCHAR2,
   X_Attribute10                         VARCHAR2,
   X_Attribute11                         VARCHAR2,
   X_Attribute12                         VARCHAR2,
   X_Attribute13                         VARCHAR2,
   X_Attribute14                         VARCHAR2,
   X_Attribute15                         VARCHAR2,
   X_Attribute16                         VARCHAR2,
   X_Attribute17                         VARCHAR2,
   X_Attribute18                         VARCHAR2,
   X_Attribute19                         VARCHAR2,
   X_Attribute20                         VARCHAR2,
   X_Pos_Control_Structure_Flag          VARCHAR2
) IS
--
CURSOR C IS SELECT rowid FROM PER_ORGANIZATION_STRUCTURES
WHERE organization_structure_id = X_Organization_Structure_Id;
CURSOR C2 IS SELECT PER_ORGANIZATION_STRUCTURES_S.nextval FROM sys.dual;
--
BEGIN
--
   if (X_Organization_Structure_Id is NULL) then
      OPEN C2;
      FETCH C2 INTO X_Organization_Structure_Id;
      CLOSE C2;
   end if;

   check_position_control_flag(X_Organization_Structure_Id,
                               X_Pos_Control_Structure_Flag,
                               X_Business_Group_Id);

   INSERT INTO PER_ORGANIZATION_STRUCTURES(
      organization_structure_id,
      business_group_id,
      name,
      comments,
      primary_structure_flag,
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
      attribute20,
      position_control_structure_flg
      ) VALUES (
      X_Organization_Structure_Id,
      X_Business_Group_Id,
      X_Name,
      X_Comments,
      X_Primary_Structure_Flag,
      X_Attribute_Category,
      X_Attribute1,
      X_Attribute2,
      X_Attribute3,
      X_Attribute4,
      X_Attribute5,
      X_Attribute6,
      X_Attribute7,
      X_Attribute8,
      X_Attribute9,
      X_Attribute10,
      X_Attribute11,
      X_Attribute12,
      X_Attribute13,
      X_Attribute14,
      X_Attribute15,
      X_Attribute16,
      X_Attribute17,
      X_Attribute18,
      X_Attribute19,
      X_Attribute20,
      X_Pos_Control_Structure_Flag
      );
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
   end if;
   CLOSE C;
END Insert_Row;
------------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
 X_Organization_Structure_Id             NUMBER,
 X_Business_Group_Id                     NUMBER,
 X_Name                                  VARCHAR2,
 X_Comments                              VARCHAR2,
 X_Primary_Structure_Flag                VARCHAR2,
 X_Attribute_Category                    VARCHAR2,
 X_Attribute1                            VARCHAR2,
 X_Attribute2                            VARCHAR2,
 X_Attribute3                            VARCHAR2,
 X_Attribute4                            VARCHAR2,
 X_Attribute5                            VARCHAR2,
 X_Attribute6                            VARCHAR2,
 X_Attribute7                            VARCHAR2,
 X_Attribute8                            VARCHAR2,
 X_Attribute9                            VARCHAR2,
 X_Attribute10                           VARCHAR2,
 X_Attribute11                           VARCHAR2,
 X_Attribute12                           VARCHAR2,
 X_Attribute13                           VARCHAR2,
 X_Attribute14                           VARCHAR2,
 X_Attribute15                           VARCHAR2,
 X_Attribute16                           VARCHAR2,
 X_Attribute17                           VARCHAR2,
 X_Attribute18                           VARCHAR2,
 X_Attribute19                           VARCHAR2,
 X_Attribute20                           VARCHAR2,
 X_Pos_Control_Structure_Flag            VARCHAR2
) IS
--
CURSOR C IS
SELECT *
FROM   PER_ORGANIZATION_STRUCTURES
WHERE  rowid = X_Rowid
FOR UPDATE of Organization_Structure_Id NOWAIT;
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
	--
   -- Kludge required as forms automatically strips off
   -- trailing spaces
   --
	recinfo.name := rtrim(recinfo.name);
	recinfo.comments := rtrim(recinfo.comments);
	recinfo.primary_structure_flag := rtrim(recinfo.primary_structure_flag);
	recinfo.attribute_category := rtrim(recinfo.attribute_category);
	recinfo.attribute1 := rtrim(recinfo.attribute1);
	recinfo.attribute2 := rtrim(recinfo.attribute2);
	recinfo.attribute3 := rtrim(recinfo.attribute3);
	recinfo.attribute4 := rtrim(recinfo.attribute4);
	recinfo.attribute5 := rtrim(recinfo.attribute5);
	recinfo.attribute6 := rtrim(recinfo.attribute6);
	recinfo.attribute7 := rtrim(recinfo.attribute7);
	recinfo.attribute8 := rtrim(recinfo.attribute8);
	recinfo.attribute9 := rtrim(recinfo.attribute9);
	recinfo.attribute10 := rtrim(recinfo.attribute10);
	recinfo.attribute11 := rtrim(recinfo.attribute11);
	recinfo.attribute12 := rtrim(recinfo.attribute12);
	recinfo.attribute13 := rtrim(recinfo.attribute13);
	recinfo.attribute14 := rtrim(recinfo.attribute14);
	recinfo.attribute15 := rtrim(recinfo.attribute15);
	recinfo.attribute16 := rtrim(recinfo.attribute16);
	recinfo.attribute17 := rtrim(recinfo.attribute17);
	recinfo.attribute18 := rtrim(recinfo.attribute18);
	recinfo.attribute19 := rtrim(recinfo.attribute19);
	recinfo.attribute20 := rtrim(recinfo.attribute20);
   --
   if (
   (   (Recinfo.organization_structure_id = X_Organization_Structure_Id)
      OR (    (Recinfo.organization_structure_id IS NULL)
      AND (X_Organization_Structure_Id IS NULL)))
   AND (   (Recinfo.business_group_id = X_Business_Group_Id)
      OR (    (Recinfo.business_group_id IS NULL)
      AND (X_Business_Group_Id IS NULL)))
   AND (   (Recinfo.name = X_Name)
      OR (    (Recinfo.name IS NULL)
      AND (X_Name IS NULL)))
   AND (   (Recinfo.comments = X_Comments)
      OR (    (Recinfo.comments IS NULL)
      AND (X_Comments IS NULL)))
   AND (   (Recinfo.primary_structure_flag = X_Primary_Structure_Flag)
      OR (    (Recinfo.primary_structure_flag IS NULL)
      AND (X_Primary_Structure_Flag IS NULL)))
   AND (   (Recinfo.attribute_category = X_Attribute_Category)
      OR (    (Recinfo.attribute_category IS NULL)
      AND (X_Attribute_Category IS NULL)))
   AND (   (Recinfo.attribute1 = X_Attribute1)
      OR (    (Recinfo.attribute1 IS NULL)
      AND (X_Attribute1 IS NULL)))
   AND (   (Recinfo.attribute2 = X_Attribute2)
      OR (    (Recinfo.attribute2 IS NULL)
      AND (X_Attribute2 IS NULL)))
   AND (   (Recinfo.attribute3 = X_Attribute3)
      OR (    (Recinfo.attribute3 IS NULL)
      AND (X_Attribute3 IS NULL)))
   AND (   (Recinfo.attribute4 = X_Attribute4)
      OR (    (Recinfo.attribute4 IS NULL)
      AND (X_Attribute4 IS NULL)))
   AND (   (Recinfo.attribute5 = X_Attribute5)
      OR (    (Recinfo.attribute5 IS NULL)
      AND (X_Attribute5 IS NULL)))
   AND (   (Recinfo.attribute6 = X_Attribute6)
      OR (    (Recinfo.attribute6 IS NULL)
      AND (X_Attribute6 IS NULL)))
   AND (   (Recinfo.attribute7 = X_Attribute7)
      OR (    (Recinfo.attribute7 IS NULL)
      AND (X_Attribute7 IS NULL)))
   AND (   (Recinfo.attribute8 = X_Attribute8)
      OR (    (Recinfo.attribute8 IS NULL)
      AND (X_Attribute8 IS NULL)))
   AND (   (Recinfo.attribute9 = X_Attribute9)
      OR (    (Recinfo.attribute9 IS NULL)
      AND (X_Attribute9 IS NULL)))
   AND (   (Recinfo.attribute10 = X_Attribute10)
      OR (    (Recinfo.attribute10 IS NULL)
      AND (X_Attribute10 IS NULL)))
   AND (   (Recinfo.attribute11 = X_Attribute11)
      OR (    (Recinfo.attribute11 IS NULL)
      AND (X_Attribute11 IS NULL)))
   AND (   (Recinfo.attribute12 = X_Attribute12)
      OR (    (Recinfo.attribute12 IS NULL)
      AND (X_Attribute12 IS NULL)))
   AND (   (Recinfo.attribute13 = X_Attribute13)
      OR (    (Recinfo.attribute13 IS NULL)
      AND (X_Attribute13 IS NULL)))
   AND (   (Recinfo.attribute14 = X_Attribute14)
      OR (    (Recinfo.attribute14 IS NULL)
      AND (X_Attribute14 IS NULL)))
   AND (   (Recinfo.attribute15 = X_Attribute15)
      OR (    (Recinfo.attribute15 IS NULL)
      AND (X_Attribute15 IS NULL)))
   AND (   (Recinfo.attribute16 = X_Attribute16)
      OR (    (Recinfo.attribute16 IS NULL)
      AND (X_Attribute16 IS NULL)))
   AND (   (Recinfo.attribute17 = X_Attribute17)
      OR (    (Recinfo.attribute17 IS NULL)
      AND (X_Attribute17 IS NULL)))
   AND (   (Recinfo.attribute18 = X_Attribute18)
      OR (    (Recinfo.attribute18 IS NULL)
      AND (X_Attribute18 IS NULL)))
   AND (   (Recinfo.attribute19 = X_Attribute19)
      OR (    (Recinfo.attribute19 IS NULL)
      AND (X_Attribute19 IS NULL)))
   AND (   (Recinfo.attribute20 = X_Attribute19)
      OR (    (Recinfo.attribute20 IS NULL)
      AND (X_Attribute20 IS NULL)))
   AND (   (Recinfo.position_control_structure_flg = X_Pos_Control_Structure_Flag)
      OR (    (Recinfo.position_control_structure_flg IS NULL)
      AND (X_Pos_Control_Structure_Flag IS NULL)))
   ) then
      return;
   else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
END Lock_Row;
------------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
   X_Organization_Structure_Id           NUMBER,
   X_Business_Group_Id                   NUMBER,
   X_Name                                VARCHAR2,
   X_Comments                            VARCHAR2,
   X_Primary_Structure_Flag              VARCHAR2,
   X_Attribute_Category                  VARCHAR2,
   X_Attribute1                          VARCHAR2,
   X_Attribute2                          VARCHAR2,
   X_Attribute3                          VARCHAR2,
   X_Attribute4                          VARCHAR2,
   X_Attribute5                          VARCHAR2,
   X_Attribute6                          VARCHAR2,
   X_Attribute7                          VARCHAR2,
   X_Attribute8                          VARCHAR2,
   X_Attribute9                          VARCHAR2,
   X_Attribute10                         VARCHAR2,
   X_Attribute11                         VARCHAR2,
   X_Attribute12                         VARCHAR2,
   X_Attribute13                         VARCHAR2,
   X_Attribute14                         VARCHAR2,
   X_Attribute15                         VARCHAR2,
   X_Attribute16                         VARCHAR2,
   X_Attribute17                         VARCHAR2,
   X_Attribute18                         VARCHAR2,
   X_Attribute19                         VARCHAR2,
   X_Attribute20                         VARCHAR2,
   X_Pos_Control_Structure_Flag          VARCHAR2
) IS
--
BEGIN

   check_position_control_flag(X_Organization_Structure_Id,
                               X_Pos_Control_Structure_Flag,
                               X_Business_Group_Id);

   UPDATE PER_ORGANIZATION_STRUCTURES
   SET
   organization_structure_id                 =    X_Organization_Structure_Id,
   business_group_id                         =    X_Business_Group_Id,
   name                                      =    X_Name,
   comments                                  =    X_Comments,
   primary_structure_flag                    =    X_Primary_Structure_Flag,
   attribute_category                        =    X_Attribute_Category,
   attribute1                                =    X_Attribute1,
   attribute2                                =    X_Attribute2,
   attribute3                                =    X_Attribute3,
   attribute4                                =    X_Attribute4,
   attribute5                                =    X_Attribute5,
   attribute6                                =    X_Attribute6,
   attribute7                                =    X_Attribute7,
   attribute8                                =    X_Attribute8,
   attribute9                                =    X_Attribute9,
   attribute10                               =    X_Attribute10,
   attribute11                               =    X_Attribute11,
   attribute12                               =    X_Attribute12,
   attribute13                               =    X_Attribute13,
   attribute14                               =    X_Attribute14,
   attribute15                               =    X_Attribute15,
   attribute16                               =    X_Attribute16,
   attribute17                               =    X_Attribute17,
   attribute18                               =    X_Attribute18,
   attribute19                               =    X_Attribute19,
   attribute20                               =    X_Attribute20,
   position_control_structure_flg            =    X_Pos_Control_Structure_Flag
   WHERE rowid = X_rowid;
   --
   if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
   end if;
   --
END Update_Row;
------------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid VARCHAR2
                    ,p_organization_structure_id NUMBER
                    ,p_business_group_id NUMBER
                    ,p_pa_installed VARCHAR2) IS
BEGIN
   -- do pre-delete checks
   per_org_structures_pkg.delete_check(
                p_organization_structure_id =>p_organization_structure_id
                ,p_business_group_id =>p_business_group_id
                ,p_pa_installed => p_pa_installed
                );
   --
   DELETE FROM PER_ORGANIZATION_STRUCTURES
   WHERE  rowid = X_Rowid;
   --
   if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
   end if;
END Delete_Row;
------------------------------------------------------------------------------
function postform(p_business_group_id NUMBER
                 ,p_org_structure_version_id IN NUMBER) return boolean is
--
-- local variables
--
l_dummy VARCHAR2(1);
begin
   --
   -- Bug 557463. Added extra clause to restrict the search to versions of
   -- the hierarchy which is referenced on the security profile. Clause is
   --
   --   sp.organization_structure_id = osv.organization_structure_id
   --
   -- RMF 29-Sep-97.
   --
   -- CBS bug #1301741
   -- Restrict the query further to the specific org_structure_version that has
   -- been displayed by the calling form - to prevent the message showing
   -- everytime DOH form is used in a business group that has a SP
   -- where the top org has been removed and instead show message only where
   -- the affected org_structure_version has actually been edited/queried back.
   --
   select  null
   into    l_dummy
   from sys.dual
   where exists( select 1
                from    per_security_profiles sp
                where   sp.organization_id      is not null
                and     (  sp.business_group_id + 0    = p_business_group_id
                        or (   sp.business_group_id is null
                           and p_business_group_id is null))
                and     exists  (select null
                                 from   per_org_structure_versions osv
                                 where  (  osv.business_group_id   = p_business_group_id
                                        or (   osv.business_group_id is null
                                           and p_business_group_id is null))
                                 and    sp.organization_structure_id =
                                        osv.organization_structure_id
                                 and    osv.org_structure_version_id = p_org_structure_version_id /* 1301741 */
                                 and    not exists
                                        (
                                        select  null
                                        from    per_org_structure_elements ose
                                        where   ose.org_structure_version_id =
                                        osv.org_structure_version_id
                                        and     (sp.organization_id =
                                                ose.organization_id_child
                                          or sp.organization_id =
                                                ose.organization_id_parent)
                                        )
                                )
               );
   --
   return TRUE;
   --
   exception
      when no_data_found then
         return false;
end;
------------------------------------------------------------------------------
END PER_ORG_STRUCTURES_PKG;

/
