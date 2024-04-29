--------------------------------------------------------
--  DDL for Package Body PER_POSITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POSITIONS_PKG" as
/* $Header: pepos01t.pkb 120.0 2005/05/31 14:51:24 appldev noship $ */

function exists_in_hierarchy(X_Pos_Structure_Version_Id NUMBER,
			     X_Position_Id NUMBER) return VARCHAR2 IS
-- Local Variable.
l_exists VARCHAR2(1) := 'N';
--
-- return Y if a particular position exists in a hierarchy version
-- or if any elements exist in a hierarchy version
-- else return N.
--
begin
	select 'Y'
	into l_exists
   from sys.dual
   where exists (select null
		from    per_pos_structure_elements pse
		where  pse.pos_structure_VERSION_id = X_Pos_Structure_Version_Id
		and  ((pse.subordinate_position_id = X_Position_Id
			or       pse.parent_position_id = X_Position_Id)
		or   X_Position_Id is null)
   );
	--
	return l_exists;
	--
	exception
		when no_data_found then
			return l_exists;
end exists_in_hierarchy;

PROCEDURE Check_Unique_Row(p_Rowid varchar2,
                           p_Position_Id number) is
          l_dummy varchar2(1);
          l_bool  boolean;
    cursor csr_p is
    SELECT   '1'
    FROM     PER_ALL_POSITIONS PST
    WHERE    (PST.ROWID <> p_Rowid
    OR       p_Rowid IS NULL)
    AND      PST.POSITION_ID = p_Position_Id;
begin
    open csr_p;
    fetch csr_p into l_dummy;
    l_bool := csr_p%found;
    close csr_p;
    if l_bool then
       hr_utility.set_message(801,'HR_6012_ROW_INSERTED');
       hr_utility.raise_error;
    end if;

end Check_Unique_Row;

PROCEDURE Check_Descriptor(p_Rowid varchar2,
                           p_Position_Definition_Id number,
                           p_Business_Group_Id      number) is
          l_dummy varchar2(1);
          l_bool  boolean;
    cursor csr_pd is
    SELECT   '1'
    FROM     PER_ALL_POSITIONS PST
    WHERE    (PST.ROWID <> p_Rowid
    OR       p_Rowid IS NULL)
    AND      PST.POSITION_DEFINITION_ID = p_Position_Definition_Id
    AND      PST.business_group_id + 0 = p_Business_Group_Id;
begin
    open csr_pd;
    fetch csr_pd into l_dummy;
    l_bool := csr_pd%found;
    close csr_pd;
    if l_bool then
       hr_utility.set_message(801,'PER_7415_POS_EXISTS');
       hr_utility.raise_error;
    end if;

end Check_Descriptor;

PROCEDURE pre_delete_checks(p_rowid                      varchar2,
                            p_position_id                number,
                            p_business_group_id          number,
                            p_hr_ins                     varchar2,
                            p_po_ins                     varchar2,
                            p_delete_row             out nocopy boolean
) is
          l_exists varchar2(1);
          l_pos_structure_element_id number;
          l_sql_text VARCHAR2(2000);
          l_oci_out VARCHAR2(1);
          l_sql_cursor NUMBER;
          l_rows_fetched NUMBER;
begin
     p_delete_row := false;
     begin
     select '1'
     into l_exists
     from sys.dual
     where exists (select null
                   from per_ALL_assignments_f a
                   where   a.position_id = p_position_id);
     exception when no_data_found then
                    null;
     end;
     if l_exists = '1' then
        hr_utility.set_message(801,'PER_7417_POS_ASSIGNMENT');
        hr_utility.raise_error;
     end if;

     l_exists := NULL;

     if p_hr_ins = 'Y' then
        begin
        select '1'
        into l_exists
        from sys.dual
        where exists (SELECT NULL
                      FROM    PAY_ELEMENT_LINKS_F EL
                      WHERE   EL.POSITION_ID = p_position_id);
        exception when no_data_found then
                       null;
        end;

        if l_exists = '1' then
           hr_utility.set_message(801,'PER_7863_DEL_POS_LINK');
           hr_utility.set_message_token('FORM','PERWSDPO');
           hr_utility.set_message_token('BLOCK','PST1');
           hr_utility.set_message_token('TRIGGER','on-delete');
           hr_utility.set_message_token('STEP','4');
           hr_utility.raise_error;
         end if;

         l_exists := NULL;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(SELECT  NULL
                      from    PER_BUDGET_ELEMENTS BE
                      where   BE.POSITION_ID = p_position_id);
         exception when no_data_found then
                       null;
         end;
         if l_exists = '1' then
           hr_utility.set_message(801,'PER_7862_DEL_POS_BUD');
           hr_utility.set_message_token('FORM','PERWSDPO');
           hr_utility.set_message_token('BLOCK','PST1');
           hr_utility.set_message_token('TRIGGER','on-delete');
           hr_utility.set_message_token('STEP','6');
           hr_utility.raise_error;
         end if;
         l_exists := NULL;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(SELECT  NULL
                      from    PER_VACANCIES VAC
                      where   VAC.POSITION_ID = p_position_id);
         exception when no_data_found then
                       null;
         end;
         if l_exists = '1' then
           hr_utility.set_message(801,'PER_7861_DEL_POS_REC_ACT');
           hr_utility.set_message_token('FORM','PERWSDPO');
           hr_utility.set_message_token('BLOCK','PST1');
           hr_utility.set_message_token('STEP','8');
           hr_utility.raise_error;
         end if;

         begin
         select  e.pos_structure_element_id
         into    l_pos_structure_element_id
         from    per_pos_structure_elements e
         where   e.parent_position_id = p_position_id
         and     not exists (
                             select  null
         from    per_pos_structure_elements e2
         where   e2.subordinate_position_id = p_position_id)
         and     1 = (
                      select  count(e3.pos_structure_element_id)
                      from    per_pos_structure_elements e3
                      where   e3.parent_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         l_exists := NULL;

         if l_pos_structure_element_id is null then
            begin
            select '1'
            into l_exists
            from sys.dual
            where exists(SELECT  NULL
                      FROM   PER_POS_STRUCTURE_ELEMENTS PSE
                      WHERE  PSE.PARENT_POSITION_ID      = p_position_id
                      OR     PSE.SUBORDINATE_POSITION_ID = p_position_id) ;
            exception when no_data_found then
                        null;
            end;

            if l_exists = '1' then
               hr_utility.set_message(801,'PER_7416_POS_IN_POS_HIER');
               hr_utility.raise_error;
            end if;
         end if;

         l_exists := NULL;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(SELECT  NULL
                      FROM PER_VALID_GRADES VG1
                      WHERE business_group_id + 0 = p_business_group_id
                      AND VG1.POSITION_ID = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
               hr_utility.set_message(801,'PER_7865_DEF_POS_DEL_GRADE');
               hr_utility.raise_error;
         end if;

         l_exists := NULL;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_job_requirements jre1
                      where jre1.position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7866_DEF_POS_DEL_REQ');
             hr_utility.raise_error;
         end if;


         l_exists := NULL;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_job_evaluations jev1
                      where jev1.position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7867_DEF_POS_DEL_EVAL');
             hr_utility.raise_error;
         end if;

         l_exists := NULL;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_positions
                      where successor_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7996_POS_SUCCESSOR_REF');
             hr_utility.raise_error;
         end if;

         l_exists := NULL;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_positions
                      where relief_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7997_POS_RELIEF_REF');
             hr_utility.raise_error;
         end if;

         l_exists := NULL;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_mm_positions
                      where new_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
             hr_utility.set_message(800,'HR_52776_NOT_DEL_MM_POSITIONS');
             hr_utility.raise_error;
	 end if;

     end if;

    --
    -- is po installed?
    --
    if p_po_ins = 'Y' then
      begin
        l_sql_text := 'select null '
           ||'from sys.dual '
           ||'where exists( select null '
           ||'    from   po_system_parameters '
           ||'    where  security_position_structure_id = '
           ||to_char(p_position_id)
           ||' ) '
           ||'or exists( select null '
           ||'    from   po_employee_hierarchies '
           ||'    where  employee_position_id = '
           ||to_char(p_position_id)
           ||'or    superior_position_id = '
           ||to_char(p_position_id)
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
    --
    --  Ref Int check for OTA.
    --
    per_ota_predel_validation.ota_predel_pos_validation(p_position_id);
    --
    p_delete_row := true;
end pre_delete_checks;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Position_Id                         IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Successor_Position_Id               NUMBER,
                     X_Relief_Position_Id                  NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Position_Definition_Id              NUMBER,
                     X_Date_Effective                      DATE,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            DATE,
                     X_Frequency                           VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Probation_Period                    NUMBER,
                     X_Probation_Period_Units              VARCHAR2,
                     X_Replacement_Required_Flag           VARCHAR2,
                     X_Time_Normal_Finish                  VARCHAR2,
                     X_Time_Normal_Start                   VARCHAR2,
                     X_Working_Hours                       NUMBER,
                     X_Status                              VARCHAR2,
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
                     X_View_All_Psts                       VARCHAR2,
                     X_Security_Profile_id                 NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM PER_ALL_POSITIONS

             WHERE position_id = X_Position_Id;





    CURSOR C2 IS SELECT per_positions_s.nextval FROM sys.dual;
BEGIN
   null;
/*
   if (X_Position_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Position_Id;
     CLOSE C2;
   end if;

  Check_Unique_Row(X_Rowid,X_position_id);
  Check_Descriptor(X_Rowid,X_position_definition_id,x_business_group_id);

  INSERT INTO PER_POSITIONS(
          position_id,
          business_group_id,
          job_id,
          organization_id,
          successor_position_id,
          relief_position_id,
          location_id,
          position_definition_id,
          date_effective,
          comments,
          date_end,
          frequency,
          name,
          probation_period,
          probation_period_units,
          replacement_required_flag,
          time_normal_finish,
          time_normal_start,
          working_hours,
          status,
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
          X_Position_Id,
          X_Business_Group_Id,
          X_Job_Id,
          X_Organization_Id,
          X_Successor_Position_Id,
          X_Relief_Position_Id,
          X_Location_Id,
          X_Position_Definition_Id,
          X_Date_Effective,
          X_Comments,
          X_Date_End,
          X_Frequency,
          X_Name,
          X_Probation_Period,
          X_Probation_Period_Units,
          X_Replacement_Required_Flag,
          X_Time_Normal_Finish,
          X_Time_Normal_Start,
          X_Working_Hours,
          X_Status,
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
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Insert_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;

  if X_View_All_Psts <> 'Y' then

    hr_security.add_position(X_Position_Id,
                                 X_Security_Profile_id);
  end if;
*/
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Position_Id                           NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Job_Id                                NUMBER,
                   X_Organization_Id                       NUMBER,
                   X_Successor_Position_Id                 NUMBER,
                   X_Relief_Position_Id                    NUMBER,
                   X_Location_Id                           NUMBER,
                   X_Position_Definition_Id                NUMBER,
                   X_Date_Effective                        DATE,
                   X_Comments                              VARCHAR2,
                   X_Date_End                              DATE,
                   X_Frequency                             VARCHAR2,
                   X_Name                                  VARCHAR2,
                   X_Probation_Period                      NUMBER,
                   X_Probation_Period_Units                VARCHAR2,
                   X_Replacement_Required_Flag             VARCHAR2,
                   X_Time_Normal_Finish                    VARCHAR2,
                   X_Time_Normal_Start                     VARCHAR2,
                   X_Working_Hours                         NUMBER,
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
                   X_Status                                VARCHAR2
) IS
  -- 21st May 1997 Sue Grant bug no 474585: This used to do a select * from per_positions but it kept
  -- giving value error or saying something had changed when the comments field was null, it worked fine
  -- when the comments field had something in it! This seems to be another long problem so I have commented
  -- out the retrival of the comments (which is a long) for the moment !!
  -- This means that if somebody changes just the coments and then we use this procedure to try and lock the record
  -- we will not notice a change has been made and will overwrite the changes - This is the best solution we could
  -- come up with at the moment!
  CURSOR C IS
      SELECT Position_id
            ,Business_Group_Id
            ,Job_Id
            ,Organization_Id
            ,Successor_Position_Id
            ,Relief_Position_Id
            ,Location_Id
            ,Position_Definition_Id
            ,Date_Effective
--            ,Comments
            ,Date_End
            ,Frequency
            ,Name
            ,Probation_Period
            ,Probation_Period_Units
            ,Replacement_Required_Flag
            ,Time_Normal_Finish
            ,Time_Normal_Start
            ,Working_Hours
            ,Attribute_Category
            ,Attribute1
            ,Attribute2
            ,Attribute3
            ,Attribute4
            ,Attribute5
            ,Attribute6
            ,Attribute7
            ,Attribute8
            ,Attribute9
            ,Attribute10
            ,Attribute11
            ,Attribute12
            ,Attribute13
            ,Attribute14
            ,Attribute15
            ,Attribute16
            ,Attribute17
            ,Attribute18
            ,Attribute19
            ,Attribute20
            ,Status
      FROM   PER_POSITIONS
      WHERE  rowid = chartorowid(X_Rowid)
      FOR UPDATE of Position_Id NOWAIT;
  Recinfo C%ROWTYPE;

BEGIN
  null;
/*
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Lock_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
--
Recinfo.attribute15 := rtrim(Recinfo.attribute15);
Recinfo.attribute16 := rtrim(Recinfo.attribute16);
Recinfo.attribute17 := rtrim(Recinfo.attribute17);
Recinfo.attribute18 := rtrim(Recinfo.attribute18);
Recinfo.attribute19 := rtrim(Recinfo.attribute19);
Recinfo.attribute20 := rtrim(Recinfo.attribute20);
--Recinfo.comments := rtrim(Recinfo.comments);
Recinfo.frequency := rtrim(Recinfo.frequency);
Recinfo.name := rtrim(Recinfo.name);
Recinfo.probation_period_units := rtrim(Recinfo.probation_period_units);
Recinfo.replacement_required_flag := rtrim(Recinfo.replacement_required_flag);
Recinfo.time_normal_finish := rtrim(Recinfo.time_normal_finish);
Recinfo.time_normal_start := rtrim(Recinfo.time_normal_start);
Recinfo.status := rtrim(Recinfo.status);
Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
Recinfo.attribute1 := rtrim(Recinfo.attribute1);
Recinfo.attribute2 := rtrim(Recinfo.attribute2);
Recinfo.attribute3 := rtrim(Recinfo.attribute3);
Recinfo.attribute4 := rtrim(Recinfo.attribute4);
Recinfo.attribute5 := rtrim(Recinfo.attribute5);
Recinfo.attribute6 := rtrim(Recinfo.attribute6);
Recinfo.attribute7 := rtrim(Recinfo.attribute7);
Recinfo.attribute8 := rtrim(Recinfo.attribute8);
Recinfo.attribute9 := rtrim(Recinfo.attribute9);
Recinfo.attribute10 := rtrim(Recinfo.attribute10);
Recinfo.attribute11 := rtrim(Recinfo.attribute11);
Recinfo.attribute12 := rtrim(Recinfo.attribute12);
Recinfo.attribute13 := rtrim(Recinfo.attribute13);
Recinfo.attribute14 := rtrim(Recinfo.attribute14);

--
  if (
          (   (Recinfo.position_id = X_Position_Id)
           OR (    (Recinfo.position_id IS NULL)
               AND (X_Position_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.job_id = X_Job_Id)
           OR (    (Recinfo.job_id IS NULL)
               AND (X_Job_Id IS NULL)))
      AND (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.successor_position_id = X_Successor_Position_Id)
           OR (    (Recinfo.successor_position_id IS NULL)
               AND (X_Successor_Position_Id IS NULL)))
      AND (   (Recinfo.relief_position_id = X_Relief_Position_Id)
           OR (    (Recinfo.relief_position_id IS NULL)
               AND (X_Relief_Position_Id IS NULL)))
      AND (   (Recinfo.location_id = X_Location_Id)
           OR (    (Recinfo.location_id IS NULL)
               AND (X_Location_Id IS NULL)))
      AND (   (Recinfo.position_definition_id = X_Position_Definition_Id)
           OR (    (Recinfo.position_definition_id IS NULL)
               AND (X_Position_Definition_Id IS NULL)))
      AND (   (Recinfo.date_effective = X_Date_Effective)
           OR (    (Recinfo.date_effective IS NULL)
               AND (X_Date_Effective IS NULL)))
--      AND (   (Recinfo.comments = X_Comments)
--           OR (    (Recinfo.comments IS NULL)
--               AND (X_Comments IS NULL)))
      AND (   (Recinfo.date_end = X_Date_End)
           OR (    (Recinfo.date_end IS NULL)
               AND (X_Date_End IS NULL)))
      AND (   (Recinfo.frequency = X_Frequency)
           OR (    (Recinfo.frequency IS NULL)
               AND (X_Frequency IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.probation_period = X_Probation_Period)
           OR (    (Recinfo.probation_period IS NULL)
               AND (X_Probation_Period IS NULL)))
      AND (   (Recinfo.probation_period_units = X_Probation_Period_Units)
           OR (    (Recinfo.probation_period_units IS NULL)
               AND (X_Probation_Period_Units IS NULL)))
      AND (   (Recinfo.replacement_required_flag = X_Replacement_Required_Flag)
           OR (    (Recinfo.replacement_required_flag IS NULL)
               AND (X_Replacement_Required_Flag IS NULL)))
      AND (   (Recinfo.time_normal_finish = X_Time_Normal_Finish)
           OR (    (Recinfo.time_normal_finish IS NULL)
               AND (X_Time_Normal_Finish IS NULL)))
      AND (   (Recinfo.time_normal_start = X_Time_Normal_Start)
           OR (    (Recinfo.time_normal_start IS NULL)
               AND (X_Time_Normal_Start IS NULL)))
      AND (   (Recinfo.working_hours = X_Working_Hours)
           OR (    (Recinfo.working_hours IS NULL)
               AND (X_Working_Hours IS NULL)))
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
      AND (   (Recinfo.status = X_Status)
           OR (    (Recinfo.Status IS NULL)
               AND (X_Status IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
*/
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Position_Id                         NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Successor_Position_Id               NUMBER,
                     X_Relief_Position_Id                  NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Position_Definition_Id              NUMBER,
                     X_Date_Effective                      DATE,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            DATE,
                     X_Frequency                           VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Probation_Period                    NUMBER,
                     X_Probation_Period_Units              VARCHAR2,
                     X_Replacement_Required_Flag           VARCHAR2,
                     X_Time_Normal_Finish                  VARCHAR2,
                     X_Time_Normal_Start                   VARCHAR2,
                     X_Working_Hours                       NUMBER,
                     X_Status                              VARCHAR2,
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
                     X_Attribute20                         VARCHAR2
) IS
BEGIN
  null;
/*
  Check_Unique_Row(X_Rowid,X_position_id);
  Check_Descriptor(X_Rowid,X_position_definition_id,x_business_group_id);

  UPDATE PER_POSITIONS
  SET
    position_id                               =    X_Position_Id,
    business_group_id                         =    X_Business_Group_Id,
    job_id                                    =    X_Job_Id,
    organization_id                           =    X_Organization_Id,
    successor_position_id                     =    X_Successor_Position_Id,
    relief_position_id                        =    X_Relief_Position_Id,
    location_id                               =    X_Location_Id,
    position_definition_id                    =    X_Position_Definition_Id,
    date_effective                            =    X_Date_Effective,
    comments                                  =    X_Comments,
    date_end                                  =    X_Date_End,
    frequency                                 =    X_Frequency,
    name                                      =    X_Name,
    probation_period                          =    X_Probation_Period,
    probation_period_units                    =    X_Probation_Period_Units,
    replacement_required_flag                 =    X_Replacement_Required_Flag,
    time_normal_finish                        =    X_Time_Normal_Finish,
    time_normal_start                         =    X_Time_Normal_Start,
    working_hours                             =    X_Working_Hours,
    status                                    =    X_Status,
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
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','Update_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
*/
END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_Position_id number,
                     X_business_group_id number,
                     X_Hr_Ins varchar2,
                     X_Po_Ins varchar2,
		     X_View_All_Psts varchar2) IS
l_delete_row boolean;
BEGIN
  null;
/*
  pre_delete_checks(X_Rowid,
                    X_Position_id,
                    X_business_group_id,
                    X_Hr_Ins ,
                    X_Po_Ins,
                    l_delete_row );

  if X_View_All_Psts <> 'Y' then
    hr_security.delete_pos_from_list(X_Position_Id);
  end if;

  DELETE FROM PER_POSITIONS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','Delete_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
*/
END Delete_Row;
--
-- return false if compiled flex struct does NOT exist
--
FUNCTION check_id_flex_struct ( p_id_flex_code VARCHAR2,
                                p_id_flex_num  NUMBER ) RETURN BOOLEAN IS
--
-- declare cursor
--
CURSOR get_flex_struct IS
SELECT
	'Y'
FROM
	FND_COMPILED_ID_FLEX_STRUCTS FCF,
        FND_ID_FLEX_STRUCTURES FS
WHERE
        FCF.ID_FLEX_CODE	= p_id_flex_code	AND
	FCF.ID_FLEX_NUM		= p_id_flex_num
AND
	FS.ID_FLEX_CODE		= FCF.ID_FLEX_CODE	AND
	FS.ID_FLEX_NUM		= FCF.ID_FLEX_NUM	AND
	FS.DYNAMIC_INSERTS_ALLOWED_FLAG = 'Y';
--
l_struct_exists VARCHAR2(1) := 'N';
--
BEGIN
--
-- get flex struct
--
  OPEN  get_flex_struct;
  FETCH get_flex_struct INTO l_struct_exists;
  CLOSE get_flex_struct;
--
-- check flex struct
--
  IF (l_struct_exists = 'Y')
  THEN
      RETURN TRUE;
  ELSE
      RETURN FALSE;
  END IF;
--
END check_id_flex_struct;
--
PROCEDURE check_date_effective ( p_position_id    NUMBER,
			         p_date_effective DATE) IS
--
-- declare cursor
--
CURSOR	get_grades IS
SELECT	'Y'
FROM	per_valid_grades
WHERE	position_id	= p_position_id
AND	date_from	< p_date_effective;
--
--declare local variables
--
  l_grades_exist VARCHAR2(1) := 'N';
--
BEGIN
--
-- check that no valid grades exist before the start
-- date of the position
--
OPEN  get_grades;
FETCH get_grades INTO l_grades_exist;
CLOSE get_grades;
--
IF ( l_grades_exist = 'Y')
THEN
--
-- error and abort
--
  hr_utility.set_message(801,'PER_7995_POS_GRADE_BEFORE_POS');
  hr_utility.raise_error;
--
END IF;
--
END check_date_effective;
--
PROCEDURE check_valid_grades ( p_position_id NUMBER,
                               p_end_of_time DATE,
                               p_date_end    DATE,
                               p_before_date_to IN OUT NOCOPY BOOLEAN,
                               p_before_date_from IN OUT NOCOPY BOOLEAN,
                               p_end_date_blank IN OUT NOCOPY BOOLEAN,
                               p_after_date_to  IN OUT NOCOPY BOOLEAN) IS
--
cursor csr_date_to is select null
                    from   per_valid_grades
                    where  position_id  = p_position_id
                    and    nvl(date_to, p_end_of_time) > p_date_end;
--
cursor csr_date_from is select null
                     from per_valid_grades vg
                     where  vg.position_id = p_position_id
                     and    vg.date_from > p_date_end;
--
--
-- BUG : 622996. Added csr_end_date_blank to return null if new
-- position end date is null and old position end date matches
-- currently valid grade end date. PASHUN. 24-FEB-1998.
--
--
cursor csr_end_date_blank is select null
                             from per_valid_grades vg , per_positions p
                             where vg.position_id                 = p_position_id
                             and   p.position_id                  = p_position_id
                             and   nvl(vg.date_to, p_end_of_time) =
                                   nvl(p.date_end, p_end_of_time)
                             and   p_date_end is null;
--
--
-- BUG : 622996. Added csr_after_date_to to return null if new
-- position end date is later than valid grade end date
-- and old position end date matches currently valid grade end
-- date. PASHUN. 24-FEB-1998.
--
--
cursor csr_after_date_to is select null
                         from   per_valid_grades vg , per_positions p
                         where  vg.position_id  = p_position_id
                         and    p.position_id   = p_position_id
                         and    nvl(vg.date_to,p_end_of_time) <
                                nvl(p_date_end,p_end_of_time)
                         and    nvl(vg.date_to,p_end_of_time) =
                                nvl(p.date_end,p_end_of_time);
--
g_dummy_number number;
--
begin
   --
   open csr_date_to;
   fetch csr_date_to into g_dummy_number;
   p_before_date_to := csr_date_to%FOUND;
   close csr_date_to;
   --
   hr_utility.set_location('per_positions_pkg.check_valid_grades', 1);
   --
   open csr_date_from;
   fetch csr_date_from into g_dummy_number;
   p_before_date_from := csr_date_from%FOUND;
   close csr_date_from;
   --
   hr_utility.set_location('per_positions_pkg.check_valid_grades', 2);
   --
   open csr_end_date_blank;
   fetch csr_end_date_blank into g_dummy_number;
   p_end_date_blank := csr_end_date_blank%FOUND;
   close csr_end_date_blank;
   --
   hr_utility.set_location('per_positions_pkg.check_valid_grades', 3);
   --
   open csr_after_date_to;
   fetch csr_after_date_to into g_dummy_number;
   p_after_date_to := csr_after_date_to%FOUND;
   close csr_after_date_to;
   --
   hr_utility.set_location('per_positions_pkg.check_valid_grades', 4);
   --
end check_valid_grades;
--
PROCEDURE maintain_valid_grades(p_position_id NUMBER,
                                p_date_end    DATE,
                                p_end_of_time DATE,
                                p_before_date_to   BOOLEAN,
                                p_before_date_from BOOLEAN,
                                p_end_date_blank   BOOLEAN,
                                p_after_date_to    BOOLEAN) IS
begin
--
IF ( p_before_date_to )
THEN
   --
   -- Update valid grade end dates to match the end date of the
   -- position where the end date of the position is earlier than the end
   -- date of the valid grade or the previous end dates matched.
   --
   update per_valid_grades vg
   set vg.date_to =
        (select least(nvl(p_date_end, p_end_of_time),
                      nvl(g.date_to, p_end_of_time))
         from   per_grades g
         where  g.grade_id          = vg.grade_id)
   where
         vg.position_id            = p_position_id
   and   nvl(vg.date_to, p_end_of_time) > p_date_end;
   --
   if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','maintain_valid_grades');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
   end if;
   --
END IF;
   --
IF ( p_before_date_from )
THEN
   --
   -- Valid grades are deleted if the end date of the position
   -- has been made earlier than the start date of the
   -- valid grade.
   --
   delete from per_valid_grades
   where  position_id = p_position_id
   and    date_from   > p_date_end;
   --
   if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','maintain_valid_grades');
      hr_utility.set_message_token('STEP','2');
      hr_utility.raise_error;
   end if;
   --
END IF;
--
IF ( p_end_date_blank or p_after_date_to )
  THEN
     --
     -- BUG : 622996. Update valid grade end dates to match, the least of the
     -- new end date of the position and the end date for the grade, where the old
     -- end date  of the position  matches the end date of the valid grade.
     -- PASHUN. 24-FEB-1998.
     --
    update per_valid_grades vg
    set vg.date_to =
          (select decode(least(nvl(p_date_end, p_end_of_time),
                               nvl(g.date_to,p_end_of_time)),
                         p_date_end,
                         p_date_end,
                         g.date_to,
                         g.date_to,
                         p_end_of_time,
                         null,
                         p_date_end)
           from   per_grades g
           where  g.grade_id              = vg.grade_id)
    where
           vg.position_id                 = p_position_id
    and    nvl(vg.date_to, p_end_of_time) = (select nvl(p.date_end,p_end_of_time)
                                            from per_positions p
                                            where p.position_id = p_position_id);
    --
    if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','maintain_valid_grades');
      hr_utility.set_message_token('STEP','3');
      hr_utility.raise_error;
    end if;
  END IF;
  --
end maintain_valid_grades;
--
--
FUNCTION GET_SHARED_POS_WARN_FLAG(p_user_id number) RETURN varchar2 is
--
l_show_again_flag varchar2(10) := 'Y';
--
cursor c_show_again(p_user_id number) is
select information12
from ben_copy_entity_results
where copy_entity_txn_id = 0
and table_alias = 'NONE'
and INFORMATION11 = 'PERWSDPO'
and information1 = p_user_id;
--
BEGIN
   --
   OPEN c_show_again(p_user_id);
   FETCH c_show_again INTO l_show_again_flag;
   CLOSE c_show_again;
   --
   RETURN nvl(l_show_again_flag,'Y');
   --
EXCEPTION
    WHEN OTHERS THEN
       RETURN 'Y';
END;
--
PROCEDURE SET_SHARED_POS_WARN_FLAG(p_user_id number, p_show_again_flag varchar2) is
--
PRAGMA AUTONOMOUS_TRANSACTION;
--
l_old_show_again_flag varchar2(10);
--
cursor c_show_again(p_user_id number) is
select information12
from ben_copy_entity_results
where copy_entity_txn_id = 0
and table_alias = 'NONE'
and INFORMATION11 = 'PERWSDPO'
and information1 = p_user_id;
--
BEGIN
   --
   OPEN c_show_again(p_user_id);
   FETCH c_show_again INTO l_old_show_again_flag;
   --
   IF (c_show_again%found) then
     --
     CLOSE c_show_again;
     --
     UPDATE ben_copy_entity_results
     SET information12 = 'Y',
     object_version_number = object_version_number + 1
     WHERE copy_entity_txn_id = 0
     and table_alias = 'NONE'
     and INFORMATION11 = 'PERWSDPO'
     and information1 = p_user_id;
     --
   ELSE
     --
     CLOSE c_show_again;
     --
     INSERT INTO ben_copy_entity_results
     (COPY_ENTITY_RESULT_ID, COPY_ENTITY_TXN_ID, RESULT_TYPE_CD,
      NUMBER_OF_COPIES, TABLE_ALIAS, STATUS,
      DML_OPERATION, DATETRACK_MODE,
      INFORMATION1, INFORMATION11, INFORMATION12,
      OBJECT_VERSION_NUMBER
     )
     values
     (
      ben_copy_entity_results_s.nextval, 0, 'DISPLAY',
      0, 'NONE', 'VALID',
      'INSERT', 'INSERT',
      p_user_id, 'PERWSDPO', p_show_again_flag,
      1
     );
     --
   END IF;
   COMMIT;
EXCEPTION
    WHEN OTHERS THEN
       rollback;
END;
--
--
END PER_POSITIONS_PKG;

/
