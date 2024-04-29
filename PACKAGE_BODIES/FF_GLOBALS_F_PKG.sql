--------------------------------------------------------
--  DDL for Package Body FF_GLOBALS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_GLOBALS_F_PKG" as
/* $Header: ffglb01t.pkb 120.1.12000000.3 2007/03/08 14:48:22 ajeyam noship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    ff_globals_f_pkg
  Purpose
    Supports the GLB block in the form FFWSDGLB (Define Globals).
  Notes

  History
    11-Mar-94  J.S.Hobbs   40.0         Date created.
    19-Apr-94  J.S.Hobbs   40.1         Added rtrim to Lock_Row.
    31-Jan-95  J.S.Hobbs   40.3         Removed aol WHO columns.
    06-Mar-97  J.Alloun    40.5         Changed all occurances of system.dual
                                        to sys.dual for next release requirements.
    12-Apr-05  Shisriva    --          Version 115.1,115.2 for MLS of FF_GLOBALS_F.
    05-May-05  Shisriva    115.3       Fixes for bug 4350976. Removed the Base
                                       Parameters from insert_row procedure.
    05-May-05  Shisriva    115.4       Fixes for bug 4350976. Changed defualting
                                       of parameters in update_row and lock_row.
    19-Aug-05  A.Rashid    115.5       Added validation and database item
                                       generation code.
    22-Jun-06  mseshadr    115.6       Added Load_Row procedure for lct support
    08-Mar-07  ajeyam      115.7       Commented out the if condition to check
                                       for max_updated_date > last_updated_date
                                       on Load_Row procedure for bug 5921008.
 ============================================================================*/
--
--For MLS-----------------------------------------------------------------------
g_dummy_number number (30);
g_business_group_id number(15);   -- For validating translation.
g_legislation_code  varchar2(150);   -- For validating translation.
--------------------------------------------------------------------------------
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a global via the  --
 --   Define Global form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
                      X_Global_Id             IN OUT NOCOPY NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Data_Type                           VARCHAR2,
                      X_Global_Name           IN OUT NOCOPY VARCHAR2,
                      X_Global_Description                  VARCHAR2,
                      X_Global_Value                        VARCHAR2) IS
--
   CURSOR C IS SELECT rowid FROM ff_globals_f
               WHERE  global_id = X_Global_Id;
--
   CURSOR C2 IS SELECT ff_globals_s.nextval FROM sys.dual;
--
 BEGIN
--
   -- Make sure global name is unique.
   ffdict.validate_global(X_Global_Name,
                          X_Business_Group_Id,
                          X_Legislation_Code);
--
   if (X_Global_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Global_Id;
     CLOSE C2;
   end if;
--
g_dml_status := TRUE;
--
   INSERT INTO ff_globals_f
   (global_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    legislation_code,
    data_type,
    global_name,
    global_description,
    global_value)
   VALUES
   (X_Global_Id,
    X_Effective_Start_Date,
    X_Effective_End_Date,
    X_Business_Group_Id,
    X_Legislation_Code,
    X_Data_Type,
    X_Global_Name,
    X_Global_Description,
    X_Global_Value);
--
--  insert into MLS table (TL)
--
--For MLS-----------------------------------------------------------------------
ff_fgt_ins.ins_tl(userenv('LANG'),X_GLOBAL_ID,
                 X_GLOBAL_NAME,X_GLOBAL_DESCRIPTION);
g_dml_status := FALSE;
--------------------------------------------------------------------------------
--
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_globals_f_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
 END Insert_Row;
--
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a global in the Define Global form.--
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Global_Id                             NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Data_Type                             VARCHAR2,
                    X_Global_Name                           VARCHAR2,
                    X_Global_Description                    VARCHAR2,
                    X_Global_Value                          VARCHAR2,
		    X_Base_Global_Name           VARCHAR2 default NULL,
		    X_Base_Global_Description    VARCHAR2 default NULL) IS
--
   CURSOR C IS SELECT * FROM ff_globals_f
               WHERE  rowid = X_Rowid FOR UPDATE of Global_Id  NOWAIT;
--
   Recinfo C%ROWTYPE;
--
 BEGIN
--
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_globals_f_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Remove trailing spaces
   Recinfo.legislation_code := rtrim(Recinfo.legislation_code);
   Recinfo.data_type := rtrim(Recinfo.data_type);
   Recinfo.global_name := rtrim(Recinfo.global_name);
   Recinfo.global_description := rtrim(Recinfo.global_description);
   Recinfo.global_value := rtrim(Recinfo.global_value);
--
   if (    (   (Recinfo.global_id = X_Global_Id)
            OR (    (Recinfo.global_id IS NULL)
                AND (X_Global_Id IS NULL)))
       AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
            OR (    (Recinfo.effective_start_date IS NULL)
                AND (X_Effective_Start_Date IS NULL)))
       AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
            OR (    (Recinfo.effective_end_date IS NULL)
                AND (X_Effective_End_Date IS NULL)))
       AND (   (Recinfo.business_group_id = X_Business_Group_Id)
            OR (    (Recinfo.business_group_id IS NULL)
                AND (X_Business_Group_Id IS NULL)))
       AND (   (Recinfo.legislation_code = X_Legislation_Code)
            OR (    (Recinfo.legislation_code IS NULL)
                AND (X_Legislation_Code IS NULL)))
       AND (   (Recinfo.data_type = X_Data_Type)
            OR (    (Recinfo.data_type IS NULL)
                AND (X_Data_Type IS NULL)))
       AND (   (Recinfo.global_name = X_Base_Global_Name)
            OR (    (Recinfo.global_name IS NULL)
                AND (X_Base_Global_Name IS NULL)))
       AND (   (Recinfo.global_description = X_Base_Global_Description)
            OR (    (Recinfo.global_description IS NULL)
                AND (X_Base_Global_Description IS NULL)))
       AND (   (Recinfo.global_value = X_Global_Value)
            OR (    (Recinfo.global_value IS NULL)
                AND (X_Global_Value IS NULL)))
           ) then
     return;
   else
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
--
 END Lock_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a global via the  --
 --   Define Global form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Global_Id                           NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Data_Type                           VARCHAR2,
                      X_Global_Name                         VARCHAR2,
                      X_Global_Description                  VARCHAR2,
                      X_Global_Value                        VARCHAR2,
	X_Base_Global_Name              VARCHAR2 default  hr_api.g_varchar2,
	X_Base_Global_Description       VARCHAR2 default  hr_api.g_varchar2) IS
--
l_global_name varchar2(80);
l_global_description varchar2(240);
 BEGIN
--
--Fixed for bug 4350976--
/* Checking if the Base values of global_name and global_description are of type hr_api.g_varchar2 i.e.
the procedure is not being called from the form but from outside then copy the translated
values into them.*/

l_global_name := X_Base_Global_Name;
l_global_description := X_Base_Global_Description;

if(l_global_name = hr_api.g_varchar2) then
l_global_name := X_Global_Name;
end if;
if(l_global_description = hr_api.g_varchar2) then
l_global_description := X_Global_Description;
end if;
----
g_dml_status := TRUE;
----
   UPDATE ff_globals_f
   SET global_id             =    X_Global_Id,
       effective_start_date  =    X_Effective_Start_Date,
       effective_end_date    =    X_Effective_End_Date,
       business_group_id     =    X_Business_Group_Id,
       legislation_code      =    X_Legislation_Code,
       data_type             =    X_Data_Type,
       global_name           =    l_global_name,
       global_description    =   l_global_description,
       global_value          =    X_Global_Value
   WHERE rowid = X_rowid;
--
--For MLS-----------------------------------------------------------------------
ff_fgt_upd.upd_tl(userenv('LANG'),X_GLOBAL_ID,
                 X_GLOBAL_NAME,X_GLOBAL_DESCRIPTION);
g_dml_status := FALSE;
--------------------------------------------------------------------------------
---
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_globals_f_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a global via the  --
 --   Define Global form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid              VARCHAR2,
                      --X_Global_Id          NUMBER,-- Extra Columns
                      X_Global_Name        VARCHAR2,
                      X_Business_Group_Id  NUMBER,
                      X_Legislation_Code   VARCHAR2) IS
--
x_global_id NUMBER(9);
 BEGIN
--
   -- Validate the delete NB. only ZAP's are allowed in the form so no other
   -- DT delete validation is required.
   ffdict.delete_dbitem_check
     (X_Global_Name,
      X_Business_Group_Id,
      X_Legislation_Code);

--For MLS-----------------------------------------------------------------------
select Global_Id into x_global_id from ff_globals_f
where rowid = X_Rowid;
g_dml_status := TRUE;
ff_fgt_del.del_tl(x_global_id);
--------------------------------------------------------------------------------

--
   DELETE FROM ff_globals_f
   WHERE  rowid = X_Rowid;
--
g_dml_status := FALSE;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_globals_f_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
 END Delete_Row;

---For MLS----------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from FF_GLOBALS_F_TL T
  where not exists
    (select NULL
    from FF_GLOBALS_F B
    where B.GLOBAL_ID = T.GLOBAL_ID
    );
  update FF_GLOBALS_F_TL T set (
      GLOBAL_NAME,
      GLOBAL_DESCRIPTION
    ) = (select
      B.GLOBAL_NAME,
      B.GLOBAL_DESCRIPTION
    from FF_GLOBALS_F_TL B
    where B.GLOBAL_ID = T.GLOBAL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GLOBAL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GLOBAL_ID,
      SUBT.LANGUAGE
    from FF_GLOBALS_F_TL SUBB, FF_GLOBALS_F_TL SUBT
    where SUBB.GLOBAL_ID = SUBT.GLOBAL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.GLOBAL_NAME <> SUBT.GLOBAL_NAME
      or SUBB.GLOBAL_DESCRIPTION <> SUBT.GLOBAL_DESCRIPTION
      or (SUBB.GLOBAL_DESCRIPTION is null
      and SUBT.GLOBAL_DESCRIPTION is not null)
      or (SUBB.GLOBAL_DESCRIPTION is not null
      and SUBT.GLOBAL_DESCRIPTION is null)
  ));

  insert into FF_GLOBALS_F_TL (
    GLOBAL_ID,
    GLOBAL_NAME,
    GLOBAL_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GLOBAL_ID,
    B.GLOBAL_NAME,
    B.GLOBAL_DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FF_GLOBALS_F_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FF_GLOBALS_F_TL T
    where T.GLOBAL_ID = B.GLOBAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
---
-----
procedure TRANSLATE_ROW (  X_B_GLOBAL_NAME	in VARCHAR2,
			   X_B_LEGISLATION_CODE in VARCHAR2,
			   X_GLOBAL_NAME	in VARCHAR2,
			   X_GLOBAL_DESCRIPTION in VARCHAR2,
			   X_OWNER		in VARCHAR2
) is
l_global_id  number;
l_ue_id      number;
l_dbi_name   varchar2(2000);
--
cursor csr_global_info
(p_b_global_name    in varchar2
,p_legislation_code in varchar2
) is
select glb.global_id
from   ff_globals_f glb
where  glb.global_name = p_b_global_name
and    glb.business_group_id is null
and    (glb.legislation_code = p_legislation_code or
        p_legislation_code is null and glb.legislation_code is null)
;
begin
  --
  -- Verify that there actually is a GLOBAL value to update.
  --
  open csr_global_info
  (p_b_global_name    => upper(x_b_global_name)
  ,p_legislation_code => x_b_legislation_code
  );
  fetch csr_global_info
  into  l_global_id;
  if csr_global_info%notfound then
    close csr_global_info;

    --
    -- Return because the global does not exist.
    --
    return;
  end if;
  close csr_global_info;


  --
  -- Disable triggers.
  --
  g_dml_status := TRUE;

  --
  -- Update the global value.
  --
  UPDATE ff_globals_f_tl
  SET GLOBAL_NAME = nvl(X_GLOBAL_NAME,GLOBAL_NAME),
      GLOBAL_DESCRIPTION = nvl(X_GLOBAL_DESCRIPTION,GLOBAL_DESCRIPTION),
      last_update_date = SYSDATE,
      last_updated_by = decode(x_owner,'SEED',1,0),
      last_update_login = 0,
      source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
  AND GLOBAL_ID = l_global_id
  ;

  --
  -- Update the translated database item rows. Note: translate_row takes
  -- care of any name conversion and validation.
  --
  l_dbi_name := x_global_name;
  ff_database_items_pkg.translate_row
  (x_user_name            => upper(x_b_global_name)
  ,x_legislation_code     => x_b_legislation_code
  ,x_translated_user_name => l_dbi_name
  ,x_description          => x_global_description
  ,x_language             => userenv('LANG')
  ,x_owner                => x_owner
  );

  --
  -- Re-enable triggers.
  --
  g_dml_status := FALSE;
exception
  when others then
    --
    -- Re-enable triggers.
    --
    g_dml_status := FALSE;

    if csr_global_info%isopen then
      close csr_global_info;
    end if;

    raise;
end TRANSLATE_ROW;
--
---
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                                  p_legislation_code  IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code  := p_legislation_code;
END;
--
---
procedure validate_translation(global_id	  IN NUMBER,
			       language		  IN VARCHAR2,
			       global_name	  IN VARCHAR2,
			       global_description IN VARCHAR2) IS
begin
  ffdict.validate_tl_global
  (p_global_id => global_id
  ,p_glob_name => global_name
  ,p_bus_grp   => g_business_group_id
  ,p_leg_code  => g_legislation_code
  );
end validate_translation;
--
function return_dml_status
return boolean
IS
begin
return g_dml_status;
end return_dml_status;
--
--MLS End------------------------------------------------------------------------------


--Load_row procedure to be called by
--ffglbs1.lct
PROCEDURE LOAD_ROW ( P_BASE_GLOBAL_NAME          VARCHAR2
                    ,P_EFFECTIVE_START_DATE      DATE
                    ,P_EFFECTIVE_END_DATE        DATE
                    ,P_GLOBAL_VALUE              VARCHAR2
                    ,P_DATA_TYPE                 VARCHAR2
                    ,P_LEGISLATION_CODE          VARCHAR2
                    ,P_BASE_GLOBAL_DESCRIPTION   VARCHAR2
                    ,P_GLOBAL_NAME_TL            VARCHAR2
                    ,P_GLOBAL_DESCRIPTION_TL     VARCHAR2
                    ,P_MAX_UPDATE_DATE           DATE)is

cursor csr_glb_exists_for_bg(r_global_name varchar2,r_legislation_code varchar2) is
      select null
        from ff_globals_f ffg
       where ffg.global_name = r_global_name
         and ffg.business_group_id is not null
         and exists (select null
                       from per_business_groups pbg
                      where pbg.business_group_id = ffg.business_group_id
                        and pbg.legislation_code =  r_legislation_code);

cursor csr_glb_exists_for_current_leg(r_global_name varchar2,
                                      r_legislation_code varchar2)is
--opened and used once,distinct not required.
--creation_date may vary in seconds
      Select data_type,global_id,creation_date,created_by,
             max(trunc(last_update_date)) over(order by last_update_date) lud
         from   ff_globals_f ffg
        where  ffg.global_name=r_global_name
          and  ffg.legislation_code=r_legislation_code;

l_glb_exists_for_current_leg csr_glb_exists_for_current_leg%rowtype;
l_null                Varchar2(1);
l_new_global_id       number(10);
l_dummy_global_name   varchar2(80);


        PROCEDURE   global_ins ( P_GLOBAL_ID                NUMBER
                                 ,P_EFFECTIVE_START_DATE     DATE
                                 ,P_EFFECTIVE_END_DATE       DATE
                                 ,P_LEGISLATION_CODE         VARCHAR2
                                 ,P_DATA_TYPE                VARCHAR2
                                 ,P_BASE_GLOBAL_NAME         VARCHAR2
                                 ,P_BASE_GLOBAL_DESCRIPTION  VARCHAR2
                                 ,P_GLOBAL_VALUE             VARCHAR2
                                 ,P_LAST_UPDATE_DATE         DATE
                                 ,P_LAST_UPDATED_BY          NUMBER
                                 ,P_LAST_UPDATE_LOGIN        NUMBER
                                 ,P_CREATED_BY               NUMBER
                                 ,P_CREATION_DATE            DATE)


      is
       Begin
          --Assumption Global has been validated
          --Idea is to enter a global row alonwith  the WHO columns
              hr_utility.trace('Inserting global '||P_BASE_GLOBAL_NAME||'Date '||P_EFFECTIVE_START_DATE);
              Insert into FF_GLOBALS_F
               (GLOBAL_ID
                ,EFFECTIVE_START_DATE
                ,EFFECTIVE_END_DATE
                ,BUSINESS_GROUP_ID
                ,LEGISLATION_CODE
                ,DATA_TYPE
                ,GLOBAL_NAME
                ,GLOBAL_DESCRIPTION
                ,GLOBAL_VALUE
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,CREATED_BY
                ,CREATION_DATE)
                values
                (P_GLOBAL_ID
                ,P_EFFECTIVE_START_DATE
                ,P_EFFECTIVE_END_DATE
                ,NULL
                ,P_LEGISLATION_CODE
                ,P_DATA_TYPE
                ,P_BASE_GLOBAL_NAME
                ,P_BASE_GLOBAL_DESCRIPTION
                ,P_GLOBAL_VALUE
                ,P_LAST_UPDATE_DATE
                ,P_LAST_UPDATED_BY
                ,P_LAST_UPDATE_LOGIN
                ,P_CREATED_BY
                ,P_CREATION_DATE);
     End global_ins;

      Procedure Global_Ins_Tl(P_GLOBAL_ID             Number
                             ,P_GLOBAL_NAME_TL        Varchar2
                             ,P_GLOBAL_DESCRIPTION_TL Varchar2
                             ) is

      Begin
          hr_utility.trace('Inserting tl global '||P_GLOBAL_NAME_TL);
          ff_fgt_ins.ins_tl( P_LANGUAGE_CODE      => userenv('LANG')
                            ,P_GLOBAL_ID          => P_GLOBAL_ID
                            ,P_GLOBAL_NAME        => P_GLOBAL_NAME_TL
                            ,P_GLOBAL_DESCRIPTION => P_GLOBAL_DESCRIPTION_TL
                            );


     End Global_Ins_Tl;

     Procedure Delete_glb_and_child_entities(p_global_id number) is
       CURSOR csr_global_bsd(r_global_id number) IS
        select distinct ffu.formula_id
          from ff_fdi_usages_f ffu
         where ffu.item_name in (select fdbi.user_name
                                   from ff_database_items fdbi,
                                        ff_user_entities ffue
                                  where fdbi.user_entity_id = ffue.user_entity_id
                                    and ffue.creator_id = r_global_id
                                    and ffue.creator_type = 'S');


         cursor csr_user_entity_id(r_base_global_name varchar2,
                                   r_legislation_code varchar2,
                                   r_global_id        number ) is
               select user_entity_id
                 from ff_user_entities
                where creator_id = p_global_id
                  and creator_type = 'S'
                  and user_entity_name  = r_base_global_name||'_GLOBAL_UE'
                  and legislation_code  = r_legislation_code;
     Begin

         for i in csr_global_bsd(r_global_id=>p_global_id)
            loop
                 delete ff_fdi_usages_f where formula_id = i.formula_id;
                 delete ff_compiled_info_f where formula_id =i.formula_id;
            end loop;

           for   i in csr_user_entity_id(r_base_global_name=>p_base_global_name,
                                         r_legislation_code=>p_legislation_code,
                                         r_global_id       =>p_global_id)
                 loop
                    -- Refer to bug 3744555 for not relying on
                    -- ref constraint to delete route_parameter_values
                    delete  ff_route_parameter_values
                    where   user_entity_id = i.user_entity_id
                      and   value =to_char(p_global_id) ;

                    delete  ff_database_items_tl
                    where   user_entity_id = i.user_entity_id;

                    delete  ff_user_entities
                    where   user_entity_id=i.user_entity_id;

                end loop;

               delete ff_globals_f_tl
               where  global_id=p_global_id;

               delete ff_globals_f
               where  global_id=p_global_id;
      End Delete_glb_and_child_entities;

BEGIN
hr_utility.set_location('Entering:'||'FF_GLOBALS_F_PKG.Load_row',10);

 if not (       (nvl(g_glb_record.global_name,'~nvl~') = P_BASE_GLOBAL_NAME)
         and   (nvl(g_glb_record.legislation_code,'~nvl~')=P_LEGISLATION_CODE)
       )then

     g_glb_record:=null;
  --Global from ldt encountered first time
  --check if it exists for this legislation in ff_globals_f


    hr_utility.trace(P_BASE_GLOBAL_NAME||'*20');


    open  csr_glb_exists_for_current_leg(r_global_name=>P_BASE_GLOBAL_NAME,
                                         r_legislation_code=>P_LEGISLATION_CODE);
    fetch csr_glb_exists_for_current_leg into l_glb_exists_for_current_leg ;
    close csr_glb_exists_for_current_leg ;

  if l_glb_exists_for_current_leg.data_type is not null then
      --Global for current legislation found
      --check for max(last_update_date)
--** whole if condition removed for bug 5921008
--** if the db is newly created then the last_updated_date will be env.created date,
--** but if the last_updated_date is greater than the seeded(ldt) max_updated_date then
--** this package won't upload the seeded data, to avoid that we remvoed this if condition

--** STARTS bug 5921008
--**   if ( p_max_update_date > l_glb_exists_for_current_leg.lud )then

            --global has been updated since last uploaded
            --delete all globals and user entities
            --that match the global_name for this localization
            --and recreate the globals,user entities etc..

             hr_utility.trace(P_BASE_GLOBAL_NAME||'*30');
             hr_general.g_data_migrator_mode:='Y';

             --deleting child entities
             --manually.Hence g_data_migrator_mode is set
             delete_glb_and_child_entities(p_global_id=>l_glb_exists_for_current_leg.global_id);

              global_ins( P_GLOBAL_ID                => l_glb_exists_for_current_leg.global_id
                         ,P_EFFECTIVE_START_DATE     => P_EFFECTIVE_START_DATE
                         ,P_EFFECTIVE_END_DATE       => P_EFFECTIVE_END_DATE
                         ,P_LEGISLATION_CODE         => P_LEGISLATION_CODE
                         ,P_DATA_TYPE                => P_DATA_TYPE
                         ,P_BASE_GLOBAL_NAME         => P_BASE_GLOBAL_NAME
                         ,P_BASE_GLOBAL_DESCRIPTION  => P_BASE_GLOBAL_DESCRIPTION
                         ,P_GLOBAL_VALUE             => P_GLOBAL_VALUE
                         ,P_LAST_UPDATE_DATE         => P_MAX_UPDATE_DATE
                         ,P_LAST_UPDATED_BY          => fnd_global.user_id
                         ,P_LAST_UPDATE_LOGIN        => fnd_global.login_id
                         ,P_CREATED_BY               => l_glb_exists_for_current_leg.created_by
                         ,P_CREATION_DATE            => l_glb_exists_for_current_leg.creation_date
                          );

              hr_general.g_data_migrator_mode:='N';        --set back to default values

                   Global_Ins_Tl(P_GLOBAL_ID             => l_glb_exists_for_current_leg.global_id
                                ,P_GLOBAL_NAME_TL        => P_GLOBAL_NAME_TL
                                ,P_GLOBAL_DESCRIPTION_TL => P_GLOBAL_DESCRIPTION_TL
                                );

                 ffdict.create_global_dbitem( p_name                 =>P_BASE_GLOBAL_NAME
                                             ,p_data_type            =>P_DATA_TYPE
                                             ,p_global_id            =>l_glb_exists_for_current_leg.global_id
                                             ,p_business_group_id    =>null
                                             ,p_legislation_code     =>P_LEGISLATION_CODE
                                             ,p_created_by           =>l_glb_exists_for_current_leg.created_by
                                             ,p_creation_date        =>l_glb_exists_for_current_leg.creation_date
                                             );
               g_glb_record.global_id            :=l_glb_exists_for_current_leg.global_id;
               g_glb_record.global_name          :=P_BASE_GLOBAL_NAME;
               g_glb_record.legislation_code     :=P_LEGISLATION_CODE;
               g_glb_record.created_by           :=l_glb_exists_for_current_leg.created_by;
               g_glb_record.creation_date        :=l_glb_exists_for_current_leg.creation_date;
               g_glb_record.global_upload_flag   :=true;
/*
       elsif ( p_max_update_date = l_glb_exists_for_current_leg.lud and g_glb_record.global_upload_flag)then

               hr_utility.trace(P_BASE_GLOBAL_NAME||'*40');
               global_ins( P_GLOBAL_ID                => l_glb_exists_for_current_leg.global_id
                          ,P_EFFECTIVE_START_DATE     => P_EFFECTIVE_START_DATE
                          ,P_EFFECTIVE_END_DATE       => P_EFFECTIVE_END_DATE
                          ,P_LEGISLATION_CODE         => P_LEGISLATION_CODE
                          ,P_DATA_TYPE                => P_DATA_TYPE
                          ,P_BASE_GLOBAL_NAME         => P_BASE_GLOBAL_NAME
                          ,P_BASE_GLOBAL_DESCRIPTION  => P_BASE_GLOBAL_DESCRIPTION
                          ,P_GLOBAL_VALUE             => P_GLOBAL_VALUE
                          ,P_LAST_UPDATE_DATE         => P_MAX_UPDATE_DATE
                          ,P_LAST_UPDATED_BY          => fnd_global.user_id
                          ,P_LAST_UPDATE_LOGIN        => fnd_global.login_id
                          ,P_CREATED_BY               => g_glb_record.created_by
                          ,P_CREATION_DATE            => g_glb_record.creation_date
                          );

        else

             --p_max_update_date <l_glb_exists_for_current_leg.lud
             --set the global details in g_glb_record and set flag to ignore
             --rest of rows that match global_name and legislation_code
             hr_utility.trace(P_BASE_GLOBAL_NAME||'*50');
             g_glb_record:=null;
             g_glb_record.global_name         :=P_BASE_GLOBAL_NAME;
             g_glb_record.legislation_code    :=P_LEGISLATION_CODE;
             g_glb_record.global_upload_flag  :=false;



        end if;
*/
--** ENDS bug 5921008


   else    --l_glb_exists_for_current_leg.data_type is  null here

         --global not found in ff_globals_f for current legislation.
         --Global needs to be created with last_update_date=P_MAX_UPDATE_DATE
         --Ensure that there isnt a global with
          --similar name for a BG that belongs to this leg
          --ffdict doesnt perform this check
         Begin
            hr_utility.trace(P_BASE_GLOBAL_NAME||'*60');
           open  csr_glb_exists_for_bg(r_global_name     =>P_BASE_GLOBAL_NAME
                                      ,r_legislation_code =>P_LEGISLATION_CODE  ) ;

            fetch csr_glb_exists_for_bg into l_null;
              if csr_glb_exists_for_bg%FOUND then
                  close csr_glb_exists_for_bg;
                    hr_utility.set_message(801,'FF52_NAME_ALREADY_USED');
                    hr_utility.set_message_token('1',P_BASE_GLOBAL_NAME);
                    hr_utility.set_message_token('2','Global Variable');
                    hr_utility.raise_error;
               end if;
             close csr_glb_exists_for_bg;

            l_dummy_global_name:=P_BASE_GLOBAL_NAME;

            ffdict.validate_global(p_glob_name => l_dummy_global_name,
                                   p_bus_grp   => null,
                                   p_leg_code  => P_LEGISLATION_CODE);
            Exception
            When others then

                   g_glb_record.global_name           :=P_BASE_GLOBAL_NAME;
                   g_glb_record.legislation_code      :=P_LEGISLATION_CODE;
                   g_glb_record.global_upload_flag    :=false;
                   raise;
            End;

           -- to disable triggers from firing dml staments
            hr_utility.trace(P_BASE_GLOBAL_NAME||'*70');
            hr_general.g_data_migrator_mode:='Y';

            select  ff_globals_s.nextval
               into l_new_global_id
               from dual;


                 global_ins( P_GLOBAL_ID               =>  l_new_global_id
                           ,P_EFFECTIVE_START_DATE     => P_EFFECTIVE_START_DATE
                           ,P_EFFECTIVE_END_DATE       => P_EFFECTIVE_END_DATE
                           ,P_LEGISLATION_CODE         => P_LEGISLATION_CODE
                           ,P_DATA_TYPE                => P_DATA_TYPE
                           ,P_BASE_GLOBAL_NAME         => P_BASE_GLOBAL_NAME
                           ,P_BASE_GLOBAL_DESCRIPTION  => P_BASE_GLOBAL_DESCRIPTION
                           ,P_GLOBAL_VALUE             => P_GLOBAL_VALUE
                           ,P_LAST_UPDATE_DATE         => P_MAX_UPDATE_DATE
                           ,P_LAST_UPDATED_BY          => fnd_global.user_id
                           ,P_LAST_UPDATE_LOGIN        => fnd_global.login_id
                           ,P_CREATED_BY               => fnd_global.user_id
                           ,P_CREATION_DATE            => sysdate
                          );

              hr_general.g_data_migrator_mode:='N';


              Global_Ins_Tl(P_GLOBAL_ID              => l_new_global_id
                             ,P_GLOBAL_NAME_TL        => P_GLOBAL_NAME_TL
                             ,P_GLOBAL_DESCRIPTION_TL => P_GLOBAL_DESCRIPTION_TL
                             );
              ffdict.create_global_dbitem(p_name                 =>P_BASE_GLOBAL_NAME
                                         ,p_data_type            =>P_DATA_TYPE
                                         ,p_global_id            =>l_new_global_id
                                         ,p_business_group_id    =>null
                                         ,p_legislation_code     =>P_LEGISLATION_CODE
                                         ,p_created_by           =>fnd_global.user_id
                                         ,p_creation_date        =>sysdate
                                        );
               g_glb_record.global_id            :=l_new_global_id;
               g_glb_record.global_name          :=P_BASE_GLOBAL_NAME;
               g_glb_record.legislation_code     :=P_LEGISLATION_CODE;
               g_glb_record.created_by           :=fnd_global.user_id;
               g_glb_record.creation_date        :=sysdate;
               g_glb_record.global_upload_flag   :=true;

   end if; --l_glb_exists_for_current_leg.data_type is not null then ?

else   --Global has been encountered in ldt before,hence name,id,etc known
       --hence,only need to do a simple insert into table

           if g_glb_record.global_upload_flag then
               hr_utility.trace(P_BASE_GLOBAL_NAME||'*80');
               hr_general.g_data_migrator_mode:='Y';
               global_ins( P_GLOBAL_ID                => g_glb_record.global_id
                          ,P_EFFECTIVE_START_DATE     => P_EFFECTIVE_START_DATE
                          ,P_EFFECTIVE_END_DATE       => P_EFFECTIVE_END_DATE
                          ,P_LEGISLATION_CODE         => P_LEGISLATION_CODE
                          ,P_DATA_TYPE                => P_DATA_TYPE
                          ,P_BASE_GLOBAL_NAME         => P_BASE_GLOBAL_NAME
                          ,P_BASE_GLOBAL_DESCRIPTION  => P_BASE_GLOBAL_DESCRIPTION
                          ,P_GLOBAL_VALUE             => P_GLOBAL_VALUE
                          ,P_LAST_UPDATE_DATE         => P_MAX_UPDATE_DATE
                          ,P_LAST_UPDATED_BY          => fnd_global.user_id
                          ,P_LAST_UPDATE_LOGIN        => fnd_global.login_id
                          ,P_CREATED_BY               => g_glb_record.created_by
                          ,P_CREATION_DATE            => g_glb_record.creation_date
                          );
              hr_general.g_data_migrator_mode:='N';
           end if;
end if;

hr_utility.set_location('Leaving:'||'FF_GLOBALS_F_PKG.Load_row',100);
End Load_row;





END FF_GLOBALS_F_PKG;

/
