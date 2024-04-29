--------------------------------------------------------
--  DDL for Package Body PER_POSITION_STRUCTURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POSITION_STRUCTURES_PKG" as
/* $Header: pepst01t.pkb 120.1 2006/01/11 04:15:38 asahay noship $ */

procedure form_startup(p_business_group_id NUMBER,
                       p_security_profile_id IN OUT NOCOPY NUMBER,
                       p_view_all_poss IN OUT NOCOPY VARCHAR2,
                       p_hr_installed IN OUT NOCOPY VARCHAR2,
                       p_pa_installed IN OUT NOCOPY VARCHAR2) is
l_industry VARCHAR2(1);
l_installed BOOLEAN;
--
function get_hr_status return VARCHAR2 is
--
l_hr_installed varchar2(1);
begin
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
   -- Get PA's installation status
   l_installed :=fnd_installation.get(appl_id => 275
                    ,dep_appl_id => 275
                    ,status => p_pa_installed
                    ,industry => l_industry);
   --
   -- Get HR installation Status
   p_hr_installed := get_hr_status;
   --
   -- Now the security Profile.
   --
   -- Bug 462590. Cursor below was picking up the wrong flag.
   --
	if p_hr_installed = 'I' then
   begin
      select psp.view_all_positions_flag
      ,      psp.security_profile_id
      into   p_view_all_poss
      ,      p_security_profile_id
      from   per_security_profiles psp
--      where  psp.security_profile_id = hr_security.get_security_profile
  where  psp.security_profile_id =  fnd_profile.value('PER_SECURITY_PROFILE_ID')
      and    (psp.business_group_id + 0  = p_Business_group_id
              or psp.business_group_id is null);

      --
      exception
         when NO_DATA_FOUND then
--           fnd_message.set_name('PER', 'HR_289296_SEC_PROF_SETUP_ERR');
            fnd_message.set_name('PER', 'HR_289521_GLOBAL_SEC_PROFILE');
            fnd_message.raise_error;
   end;
	else
	  p_view_all_poss := 'Y';
	  p_security_profile_id := 0;
   end if;
end form_startup;

PROCEDURE check_name_unique(X_Rowid VARCHAR2,
                            X_Name  VARCHAR2,
                            X_Business_group_id NUMBER) IS
-- Local variables
--
l_duplicate_name VARCHAR2(20);
begin
  select 'Duplicate exists'
  into l_duplicate_name
  from   sys.dual
  where  exists (
                select 1
                from   per_position_structures psp
                where  (psp.rowid <> X_Rowid
                     or X_Rowid is null)
                and upper(psp.name) = upper(X_Name)
                and psp.business_group_id + 0 = X_Business_group_id);
  fnd_message.set_name('PAY', 'PER_7901_SYS_DUPLICATE_RECORDS');
  fnd_message.raise_error;
  exception
    when no_data_found then
      null;
    when others then
      raise;
end;

PROCEDURE check_primary_flag(X_Rowid VARCHAR2,
                             X_Primary_flag VARCHAR2,
                             X_Business_group_id NUMBER) IS
--
-- Local Variable
--
l_primary_exists VARCHAR2(20);
begin
  if X_Primary_flag = 'Y' then
     begin
        select 'Primary Exists'
        into   l_primary_exists
        from   sys.dual
        where  exists (
              select 1
              from   per_position_structures psp
              where  (psp.rowid <> X_Rowid
                   or X_Rowid is null)
              and    psp.primary_position_flag = 'Y'
              and    psp.business_group_id + 0 = X_Business_group_id);
        --
        hr_utility.set_message('801', 'HR_6085_PO_POS_ONE_PRIMARY');
        hr_utility.raise_error;
        --
        exception
           when no_data_found then
              null;
           when others then
              raise;
     end;
  end if;
end;

PROCEDURE pre_delete_checks(X_Position_Structure_Id          NUMBER,
                            X_Business_Group_Id              NUMBER,
                            X_Po_Installed                   VARCHAR2,
                            X_Hr_Installed                   VARCHAR2) IS
--
--
-- Local variable
--
l_exists VARCHAR2(20);
l_sql_cursor NUMBER;
l_sql_text VARCHAR2(2000);
l_oci_out VARCHAR2(1);
l_rows_fetched varchar2(1);
Begin
  begin
     select 'Versions Exist'
     into   l_exists
     from   sys.dual
     where  exists(
           select 1
           from   per_pos_structure_versions psv
           where  psv.position_structure_id = X_Position_Structure_Id);
     --
     fnd_message.set_name('PAY','HR_6084_PO_POS_HAS_HIER_VER');
     fnd_message.raise_error;
     --
     exception
        when no_data_found then
           null;
        when others then
           raise;
  end;
  if X_Hr_Installed = 'Y' then
     begin
        select 'Security exists'
        into   l_exists
        from sys.dual
        where exists (
           select null
           from   per_security_profiles sec
           where  sec.business_group_id + 0 = X_Business_Group_Id
           and    sec.position_structure_id = X_Position_Structure_Id);
        --
        fnd_message.set_name('PAY','PAY_7694_PER_NO_DEL_STRUCTURE');
        fnd_message.raise_error;
        --
        exception
           when no_data_found then
              null;
           when others then
              raise;
        end;
  end if;
  --
  if X_Po_Installed = 'I' then
  -- run the PO stuff
  -- Dynamic SQL cursor to get round the problem of Table not existing.
  -- Shouldn't be a problem after 10.6, but better safe than sorry.
  -- This uses a similar method to OCI but Via PL/SQL instead.
  --
    begin
     l_sql_text := 'select null '
     ||'from sys.dual '
     ||'where exists( select null '
     ||'    from   po_system_parameters '
     ||'    where  security_position_structure_id = '
     ||to_char(X_Position_Structure_Id)
     ||' ) '
     ||'or exists( select null '
     ||'    from   po_employee_hierarchies '
     ||'    where  position_structure_id = '||to_char(X_Position_Structure_Id)
     ||' ) '
     ||'or exists( select null '
     ||'    from   po_action_history '
     ||'    where  approval_path_id = '||to_char(X_Position_Structure_Id)
     ||' ) '
     ||'or exists( select null '
     ||'    from   po_document_types '
     ||'    where  default_approval_path_id = '
     ||to_char(X_Position_Structure_Id)
     ||' ) ';
      --
      -- Open Cursor for Processing Sql statment.
      --
      l_sql_cursor := dbms_sql.open_cursor;
      --
      -- Parse SQL statement.
      --
      dbms_sql.parse(l_sql_cursor, l_sql_text, dbms_sql.v7);
      --
      -- Map the local variables to each returned Column
      --
      dbms_sql.define_column(l_sql_cursor, 1,l_oci_out,1);
      --
      -- Execute the SQL statement.
      --
      l_rows_fetched := dbms_sql.execute(l_sql_cursor);
      --
      if (dbms_sql.fetch_rows(l_sql_cursor) > 0)
      then
         fnd_message.set_name('PER','HR_6048_PO_POS_DEL_POS_CONT');
         fnd_message.raise_error;
      end if;
      --
      -- Close cursor used for processing SQL statement.
      --
      dbms_sql.close_cursor(l_sql_cursor);
    end;
  end if;
end;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Position_Structure_Id               IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2 ,
                     X_Primary_Position_Flag               VARCHAR2 ,
                     X_Attribute_Category                  VARCHAR2 ,
                     X_Attribute1                          VARCHAR2 ,
                     X_Attribute2                          VARCHAR2 ,
                     X_Attribute3                          VARCHAR2 ,
                     X_Attribute4                          VARCHAR2 ,
                     X_Attribute5                          VARCHAR2 ,
                     X_Attribute6                          VARCHAR2 ,
                     X_Attribute7                          VARCHAR2 ,
                     X_Attribute8                          VARCHAR2 ,
                     X_Attribute9                          VARCHAR2 ,
                     X_Attribute10                         VARCHAR2 ,
                     X_Attribute11                         VARCHAR2 ,
                     X_Attribute12                         VARCHAR2 ,
                     X_Attribute13                         VARCHAR2 ,
                     X_Attribute14                         VARCHAR2 ,
                     X_Attribute15                         VARCHAR2 ,
                     X_Attribute16                         VARCHAR2 ,
                     X_Attribute17                         VARCHAR2 ,
                     X_Attribute18                         VARCHAR2 ,
                     X_Attribute19                         VARCHAR2 ,
                     X_Attribute20                         VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM PER_POSITION_STRUCTURES

             WHERE position_structure_id = X_Position_Structure_Id;
    CURSOR C2 IS SELECT per_position_structures_s.nextval FROM sys.dual;
BEGIN
   check_name_unique(X_Rowid => X_Rowid,
                     X_Name => X_Name,
                     X_Business_Group_id => X_Business_Group_id);
   --
   check_primary_flag(X_Rowid => X_Rowid,
                      X_Primary_flag => X_Primary_Position_Flag,
                      X_Business_Group_id => X_Business_Group_id);
   --
   if (X_Position_Structure_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Position_Structure_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_POSITION_STRUCTURES(
          position_structure_id,
          business_group_id,
          name,
          comments,
          primary_position_flag,
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
          attribute20
         ) VALUES (
          X_Position_Structure_Id,
          X_Business_Group_Id,
          X_Name,
          X_Comments,
          X_Primary_Position_Flag,
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
          X_Attribute20
  );
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Position_Structure_Id                 NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Name                                  VARCHAR2,
                   X_Comments                              VARCHAR2 ,
                   X_Primary_Position_Flag                 VARCHAR2 ,
                   X_Attribute_Category                    VARCHAR2 ,
                   X_Attribute1                            VARCHAR2 ,
                   X_Attribute2                            VARCHAR2 ,
                   X_Attribute3                            VARCHAR2 ,
                   X_Attribute4                            VARCHAR2 ,
                   X_Attribute5                            VARCHAR2 ,
                   X_Attribute6                            VARCHAR2 ,
                   X_Attribute7                            VARCHAR2 ,
                   X_Attribute8                            VARCHAR2 ,
                   X_Attribute9                            VARCHAR2 ,
                   X_Attribute10                           VARCHAR2 ,
                   X_Attribute11                           VARCHAR2 ,
                   X_Attribute12                           VARCHAR2 ,
                   X_Attribute13                           VARCHAR2 ,
                   X_Attribute14                           VARCHAR2 ,
                   X_Attribute15                           VARCHAR2 ,
                   X_Attribute16                           VARCHAR2 ,
                   X_Attribute17                           VARCHAR2 ,
                   X_Attribute18                           VARCHAR2 ,
                   X_Attribute19                           VARCHAR2 ,
                   X_Attribute20                           VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PER_POSITION_STRUCTURES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Position_Structure_Id NOWAIT;
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
          (   (Recinfo.position_structure_id = X_Position_Structure_Id)
           OR (    (Recinfo.position_structure_id IS NULL)
               AND (X_Position_Structure_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.primary_position_flag = X_Primary_Position_Flag)
           OR (    (Recinfo.primary_position_flag IS NULL)
               AND (X_Primary_Position_Flag IS NULL)))
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
      AND (   (Recinfo.attribute20 = X_Attribute20)
           OR (    (Recinfo.attribute20 IS NULL)
               AND (X_Attribute20 IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Position_Structure_Id               NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2 ,
                     X_Primary_Position_Flag               VARCHAR2 ,
                     X_Attribute_Category                  VARCHAR2 ,
                     X_Attribute1                          VARCHAR2 ,
                     X_Attribute2                          VARCHAR2 ,
                     X_Attribute3                          VARCHAR2 ,
                     X_Attribute4                          VARCHAR2 ,
                     X_Attribute5                          VARCHAR2 ,
                     X_Attribute6                          VARCHAR2 ,
                     X_Attribute7                          VARCHAR2 ,
                     X_Attribute8                          VARCHAR2 ,
                     X_Attribute9                          VARCHAR2 ,
                     X_Attribute10                         VARCHAR2 ,
                     X_Attribute11                         VARCHAR2 ,
                     X_Attribute12                         VARCHAR2 ,
                     X_Attribute13                         VARCHAR2 ,
                     X_Attribute14                         VARCHAR2 ,
                     X_Attribute15                         VARCHAR2 ,
                     X_Attribute16                         VARCHAR2 ,
                     X_Attribute17                         VARCHAR2 ,
                     X_Attribute18                         VARCHAR2 ,
                     X_Attribute19                         VARCHAR2 ,
                     X_Attribute20                         VARCHAR2
) IS
BEGIN
   check_name_unique(X_Rowid => X_Rowid,
                     X_Name => X_Name,
                     X_Business_Group_id => X_Business_Group_id);
   --
   check_primary_flag(X_Rowid => X_Rowid,
                      X_Primary_Flag => X_Primary_Position_Flag,
                      X_Business_Group_id => X_Business_Group_id);
   --
  UPDATE PER_POSITION_STRUCTURES
  SET
    position_structure_id                     =    X_Position_Structure_Id,
    business_group_id                         =    X_Business_Group_Id,
    name                                      =    X_Name,
    comments                                  =    X_Comments,
    primary_position_flag                     =    X_Primary_Position_Flag,
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
    attribute20                               =    X_Attribute20
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Update_Row;

PROCEDURE Delete_Row(X_Rowid                          VARCHAR2,
                     X_Position_Structure_Id          NUMBER,
                     X_Business_Group_Id              NUMBER,
                     X_Po_Installed                   VARCHAR2,
                     X_Hr_Installed                   VARCHAR2) IS
BEGIN
  --
  pre_delete_checks(X_Position_Structure_Id => X_Position_Structure_Id,
                    X_Business_Group_Id => X_Business_Group_Id,
                    X_Po_Installed => X_Po_Installed,
                    X_Hr_Installed => X_Hr_Installed);
  --
  DELETE FROM PER_POSITION_STRUCTURES
  WHERE  rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

function postform(p_business_group_id NUMBER) return boolean is
--
-- local variables
--
l_dummy VARCHAR2(1);
begin
   select  null
   into    l_dummy
   from sys.dual
   where exists( select 1
               from per_security_profiles sp
               where sp.position_id is not null
               and sp.business_group_id + 0 = p_business_group_id
               and exists (select null
                           from per_pos_structure_versions psv
                           where psv.business_group_id = p_business_group_id
                           and not exists
                              ( select null
                                from per_pos_Structure_elements pse
                                where pse.pos_structure_version_id =
                                      psv.pos_Structure_version_id
                                     and ( sp.position_id =
                                          pse.subordinate_position_id)
                                      or (sp.position_id =
                                          pse.parent_position_id)
                              )
                          )
               );
   --
   return TRUE;
   --
   exception
      when no_data_found then
         return false;
end postform;

END PER_POSITION_STRUCTURES_PKG;

/
