--------------------------------------------------------
--  DDL for Package Body PER_POS_STRUCTURE_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POS_STRUCTURE_ELEMENTS_PKG" as
/* $Header: pepse01t.pkb 120.0 2005/05/31 15:14:31 appldev noship $ */
------------------------------------------------------------------------------
FUNCTION get_subordinates(X_View_All_Positions VARCHAR2
,X_Parent_Position_Id NUMBER
,X_Pos_Structure_Version_id NUMBER
,X_Security_Profile_Id NUMBER) RETURN NUMBER IS
--
-- Local Varaible
--
l_count NUMBER;
Begin
   --
   -- Return the number of subordinates of a given positions
   -- in a given hierarchy
   --
   -- If security exists then return  only those in
   -- the current security profile
   --
   select  nvl( count(pse.pos_structure_element_id), 0)
   into l_count
   from    per_pos_structure_elements      pse
   where   ((X_View_All_Positions <> 'Y'
      and EXISTS
         (select '1'
         from   hr_positions_f  hpf
         where  hpf.position_id = pse.subordinate_position_id
         ))
      or  X_View_All_Positions = 'Y')
   connect by
      prior pse.subordinate_position_id = pse.parent_position_id
      and     pse.pos_structure_version_id    = X_Pos_structure_version_id
   start with
      pse.parent_position_id      = X_Parent_Position_Id
      and     pse.pos_structure_version_id    = X_Pos_structure_version_id;
   -- no exception necessary as a single row group function
   -- hence no no_data_found or Too_many_rows errors;
   return l_count;
	exception
	when no_data_found then
	 return 0;
end;
--
------------------------------------------------------------------------------
PROCEDURE get_holders(X_Business_Group_Id NUMBER
,X_Position_Id NUMBER
,X_Organization_id NUMBER
,X_Holder IN OUT NOCOPY VARCHAR2
,X_No_Holders IN OUT NOCOPY NUMBER
,X_Session_date DATE
,X_Employee_Number IN OUT NOCOPY VARCHAR2
,X_User_Person_Type IN OUT NOCOPY VARCHAR2) IS
--
-- Local Variables
--
l_message VARCHAR2(80);

Begin
	hr_utility.set_message('801','HR_ALL_COUNT_HOLDERS');
	l_message := hr_utility.get_message;
	-- Bug fix 3681825: Distinct added to sql to avoid counting the same holder more
	-- than once.
	select COUNT(DISTINCT P.PERSON_ID), '** ' || COUNT(DISTINCT P.PERSON_ID) ||' '||l_message
	into X_No_Holders , l_message
	from per_all_people_f p
	,       per_all_assignments_f a
	where a.position_id       = X_Position_Id
	and   a.business_group_id + 0 = X_Business_Group_Id
	and   a.organization_id   = X_Organization_id
	and   a.assignment_type  in  ('E', 'C')
	and   a.person_id = p.person_id

        and   exists (select  ppt.system_person_type
                        from  per_person_types ppt, per_person_type_usages_f pptu
                        where pptu.person_id = p.person_id
                        and   ppt.person_type_id = pptu.person_type_id
                        and   ppt.system_person_type in ('EMP','CWK')
                        and   X_session_date between pptu.effective_start_date
                              AND pptu.effective_end_date)
        and   exists (select past.per_system_status
                        from per_assignment_status_types past
                       where past.assignment_status_type_id = a.assignment_status_type_id
                         and past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN','ACTIVE_CWK','SUSP_CWK_ASG'))
	and   X_Session_date between a.effective_start_date
				and a.effective_end_date
	and   X_Session_date between p.effective_start_date
				and p.effective_end_date;
	if X_No_Holders = 0 then
		hr_utility.set_message('801','HR_ALL_NO_HOLDERS');
		X_Holder := hr_utility.get_message;
		X_Employee_Number := NULL;
	elsif X_No_Holders = 1 then
		begin
		-- Bug fix 3681825: Distinct added to sql to avoid fetching multiple rows
                  select DISTINCT p.full_name
                        ,hr_person_type_usage_info.get_worker_number
                            (X_Session_date, p.person_id) worker_number
                        ,hr_person_type_usage_info.get_worker_user_person_type
                            (X_Session_date, p.person_id) user_person_type
                  into   X_Holder
                        ,X_Employee_Number
                        ,X_User_Person_type
                  from   per_all_people_f p
                        ,per_all_assignments_f a
                  where a.position_id       = X_Position_Id
                  and   a.business_group_id = X_Business_Group_Id
                  and   a.organization_id   = X_Organization_id
                  and   a.assignment_type in ('E', 'C')
                  and   a.person_id         = p.person_id
                  and   exists
                          (select  ppt.system_person_type
                           from  per_person_types ppt, per_person_type_usages_f ptu
                           where ptu.person_id = p.person_id
                           and   ppt.person_type_id = ptu.person_type_id
                           and   ppt.system_person_type in ('EMP', 'CWK')
                           and   X_session_date between ptu.effective_start_date                                  and ptu.effective_end_date)
                  and   exists
                          (select past.per_system_status
                           from per_assignment_status_types past
                           where past.assignment_status_type_id
                               = a.assignment_status_type_id
                           and past.per_system_status in
                             ('ACTIVE_ASSIGN','SUSP_ASSIGN'
                             ,'ACTIVE_CWK', 'SUSP_CWK_ASG'))
                  and   X_Session_date between a.effective_start_date
                        and a.effective_end_date
                  and   X_Session_date between p.effective_start_date
                        and p.effective_end_date;
		exception
			when no_data_found then
				null;
			when too_many_rows then
				null;
		end;
	else
		X_Holder := l_message;
		X_Employee_Number := NULL;
	end if;
end get_holders;
--
------------------------------------------------------------------------------
PROCEDURE block_post_query(X_Business_Group_Id NUMBER
,X_Position_Id NUMBER
,X_Organization_id IN OUT NOCOPY NUMBER
,X_Holder IN OUT NOCOPY VARCHAR2
,X_No_Holders IN OUT NOCOPY NUMBER
,X_Employee_Number IN OUT NOCOPY VARCHAR2
,X_Subordinate_position_id NUMBER
,X_View_All_Positions VARCHAR2
,X_Parent_Position_Id NUMBER
,X_Pos_Structure_Version_id NUMBER
,X_Security_Profile_Id NUMBER
,X_Session_date DATE
,X_exists_in_hierarchy IN OUT NOCOPY VARCHAR2
,X_Number_of_Subordinates IN OUT NOCOPY NUMBER
,X_User_Person_Type IN OUT NOCOPY VARCHAR2) IS
--
l_organization_id NUMBER;
Begin

--
-- Does the block requerying to save two extra trips per row.
--
--
-- Get the number of Subordinates this Position has.
	if X_Organization_id is null then
		--
		-- If Organization id is null then
		-- retrieve it.(Only when called from structure_element )
		Begin
                  --
                  -- Changes 01-Oct-99 SCNair (per_all_positions to hr_all_positions) date tracked positions req.
                  --
		  select p.organization_id
		  into   X_Organization_Id
		  from   hr_all_positions p
		  where  p.position_id = X_Position_Id
		  and    p.business_group_id + 0 = X_Business_Group_Id;
		  --
		  exception
			 when no_data_found then
				 null;
		end;
	end if;
	X_Number_of_Subordinates := get_subordinates(
                       X_View_All_Positions => X_View_All_Positions
                       ,X_Parent_Position_Id => X_Parent_Position_Id
                       ,X_Pos_Structure_Version_id => X_Pos_Structure_Version_id
                       ,X_Security_Profile_Id => X_Security_Profile_Id);
--
--
-- Get the Holder,if any, of this position. if >1 then return count of holders.:
	get_holders(X_Business_Group_Id => X_Business_Group_Id
           ,X_Position_Id => X_Position_Id
           ,X_Organization_id => X_Organization_id
           ,X_Holder => X_Holder
           ,X_No_Holders => X_No_Holders
			  ,X_Session_date => X_Session_date
           ,X_Employee_Number => X_Employee_Number
           ,X_User_Person_Type => X_User_Person_Type);
--
X_exists_in_hierarchy:=PER_POSITIONS_PKG.exists_in_hierarchy(
                        X_Pos_Structure_Version_Id => X_Pos_Structure_Version_id
                        ,X_Position_Id => X_Position_Id);
end block_post_query;
------------------------------------------------------------------------------
PROCEDURE maintain_pos_list(X_Business_Group_Id NUMBER
,X_Security_Profile_Id NUMBER
,X_View_All_Positions VARCHAR2
,X_Sec_Pos_Structure_Version_id NUMBER
,X_Position_Id NUMBER) IS
--
--Local Variables
--
l_view_all_positions VARCHAR2(1);
l_include_top_pos_flag VARCHAR2(1);
l_sec_pos_id NUMBER;
--
-- Local Function
--
FUNCTION tree_walk(X_Business_Group_Id NUMBER
                  ,X_Sec_Pos_Structure_Version_id NUMBER
                  ,X_Position_Id NUMBER) RETURN BOOLEAN IS
--
--
l_exists VARCHAR2(1);
begin
	select null
   into l_exists
	from   sys.dual
	where  X_Position_Id in
			 (select a.subordinate_position_id
			  from   per_POS_structure_elements a
			  where  a.business_group_id + 0 = X_Business_Group_Id
			  and    a.POS_structure_VERSION_id =
						 X_Sec_Pos_Structure_Version_id
			  connect by prior
						a.subordinate_position_id = a.parent_position_id
			  and    a.POS_structure_VERSION_id =
						X_Sec_Pos_Structure_Version_id
			  and    a.business_group_id + 0 = X_Business_Group_Id
			  start with
						a.parent_position_id = X_Position_Id
			  and    a.POS_structure_VERSION_id =
						 X_Sec_Pos_Structure_Version_id
			  and    a.business_group_id + 0 = X_Business_Group_Id);
   return true;
   exception
      when no_data_found then
         return false;
      when too_many_rows then
          raise;
end tree_walk;
begin
  if X_view_all_positions = 'N' then
    return;
  end if;
	begin
		select x.view_all_POSITIONs_flag
		,       x.POSITION_id
		,       x.include_top_POSITION_flag
		into    l_view_all_positions
		,       l_sec_pos_id
		,       l_include_top_pos_flag
		from    per_security_profiles x
		where   x.business_group_id + 0 = X_Business_Group_Id
		and     x.security_profile_id = X_Security_Profile_Id;
		--
		exception
			when no_data_found then
				null;
	end;
--
	if l_view_all_positions <>'Y' then
		if l_include_top_pos_flag = 'N' then
			if tree_walk(X_Business_Group_Id =>X_Business_Group_Id
					,X_Sec_Pos_Structure_Version_id => X_Sec_Pos_Structure_Version_id
					,X_Position_id => l_sec_pos_id) then
				null;
			else
				if l_sec_pos_id <> X_Position_Id then
					if tree_walk(X_Business_Group_Id =>X_Business_Group_Id
					,X_Sec_Pos_Structure_Version_id => X_Sec_Pos_Structure_Version_id
					,X_Position_id => l_sec_pos_id) then
					null;
					else
						return;
					end if;
				end if;
			end if;
		end if;
	end if;

        hr_security.add_position(X_Position_Id,
                                 X_Security_Profile_Id);
	--
	if sql%ROWCOUNT <>1 then
		-- raise_error;
		null;
	end if;
end maintain_pos_list;
--
------------------------------------------------------------------------------
PROCEDURE check_unique(X_Parent_position_id NUMBER
                      ,X_Pos_Structure_Version_Id NUMBER
                      ,X_Subordinate_Position_Id NUMBER) IS
--
-- Local Variables
--
l_dummy VARCHAR2(1);
begin
	select null
	into   l_dummy
	FROM   PER_POS_STRUCTURE_ELEMENTS PSE
	WHERE  PSE.POS_STRUCTURE_VERSION_ID = X_Pos_Structure_Version_Id
	AND    PSE.PARENT_POSITION_ID    = X_Parent_position_id
	AND    PSE.SUBORDINATE_POSITION_ID     = X_Subordinate_Position_Id;
	--
	hr_utility.set_message('801','HR_6012_ROW_INSERTED');
	hr_utility.raise_error;
	exception
		when no_data_found then
			null;
end check_unique;
-------------------------------------------------------------------------------
PROCEDURE pre_delete_checks(X_Subordinate_position_Id NUMBER
                           ,X_Position_Structure_Id NUMBER
                           ,X_Business_Group_Id NUMBER
                           ,X_Hr_Installed VARCHAR2
                           ,X_Pos_Structure_version_Id NUMBER) IS
l_dummy VARCHAR2(1);
begin
	begin
		select null
		into l_dummy
                from sys.dual
                where exists(select 1
		from per_pos_structure_elements pse
		where pse.parent_position_id = X_Subordinate_position_Id
		and   pse.pos_structure_version_id = X_Pos_Structure_version_Id);
		--
		hr_utility.set_message('801','HR_6915_POS_DEL_FIRST');
		hr_utility.raise_error;
		--
		exception
			when no_data_found then
				null;
	end;
	if X_Hr_Installed <> 'I' then
		begin
			select null
			into l_dummy
			from sys.dual
			where exists(select 1
			from per_security_profiles psp
			where  psp.business_group_id + 0     = X_Business_Group_Id
			and    psp.position_id = X_Subordinate_position_Id
			and    psp.position_structure_id = X_Position_Structure_Id);
			--
			hr_utility.set_message(801,'PAY_7694_PER_NO_DEL_STRUCTURE');
			hr_utility.raise_error;
			--
			exception
				when no_data_found then
					null;
		end;
	end if;
end pre_delete_checks;
-------------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Pos_Structure_Element_Id            IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Pos_Structure_Version_Id            NUMBER,
                     X_Subordinate_Position_Id             NUMBER,
                     X_Parent_Position_Id                  NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM PER_POS_STRUCTURE_ELEMENTS
             WHERE pos_structure_element_id = X_Pos_Structure_Element_Id;
    CURSOR C2 IS SELECT per_pos_structure_elements_s.nextval FROM sys.dual;
--
   cursor get_details is select rowid, POS_STRUCTURE_ELEMENT_ID
    ,BUSINESS_GROUP_ID, POS_STRUCTURE_VERSION_ID
    ,SUBORDINATE_POSITION_ID,PARENT_POSITION_ID
    FROM PER_POS_STRUCTURE_ELEMENTS
   where Subordinate_Position_Id = X_Subordinate_Position_Id
   and   Pos_Structure_Version_Id = X_Pos_Structure_Version_Id;
  Recinfo get_details%ROWTYPE;
--
BEGIN
/*   PER_POS_STRUCTURE_ELEMENTS_PKG.check_unique(
                        X_Parent_position_id => X_Parent_position_id
                       ,X_Pos_Structure_Version_Id => X_Pos_Structure_Version_Id
                       ,X_Subordinate_Position_Id => X_Subordinate_Position_Id);
*/
--
-- Does the row subordinate already exist in the hierarchy as a subordinate?
--
   if ((PER_POSITIONS_PKG.exists_in_hierarchy(
         X_Pos_Structure_Version_Id =>X_Pos_Structure_Version_Id
        ,X_Position_Id => X_Subordinate_Position_Id)) ='Y') then
--
--    Yes , then merely update the old structure element
--
      open get_details;
      fetch get_details into Recinfo;
      if get_details%found then
--
--       Lock the row
--

      PER_POS_STRUCTURE_ELEMENTS_PKG.lock_row(
         X_Rowid                    => Recinfo.ROWID,
         X_Pos_Structure_Element_Id => Recinfo.POS_STRUCTURE_ELEMENT_ID,
         X_Business_Group_Id        => Recinfo.BUSINESS_GROUP_ID,
         X_Pos_Structure_Version_Id => Recinfo.POS_STRUCTURE_VERSION_ID,
         X_Subordinate_Position_Id  => Recinfo.SUBORDINATE_POSITION_ID,
         X_Parent_Position_Id       => Recinfo.PARENT_POSITION_ID);
--
--       Update the row
--
      PER_POS_STRUCTURE_ELEMENTS_PKG.update_row(
         X_Rowid                    => Recinfo.ROWID,
         X_Pos_Structure_Element_Id => Recinfo.POS_STRUCTURE_ELEMENT_ID,
         X_Business_Group_Id        => Recinfo.BUSINESS_GROUP_ID,
         X_Pos_Structure_Version_Id => Recinfo.POS_STRUCTURE_VERSION_ID,
         X_Subordinate_Position_Id  => Recinfo.SUBORDINATE_POSITION_ID,
         X_Parent_Position_Id       => X_Parent_Position_Id);
--
--     set the values
--
       X_Rowid := Recinfo.ROWID;
       X_Pos_Structure_Element_Id := Recinfo.POS_STRUCTURE_ELEMENT_ID;
      close get_details;
      return;
    end if;
   end if;
   if (X_Pos_Structure_Element_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Pos_Structure_Element_Id;
     CLOSE C2;
   end if;
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
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;
-------------------------------------------------------------------------------
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
------------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Pos_Structure_Element_Id            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Pos_Structure_Version_Id            NUMBER,
                     X_Subordinate_Position_Id             NUMBER,
                     X_Parent_Position_Id                  NUMBER
) IS
BEGIN
  UPDATE PER_POS_STRUCTURE_ELEMENTS
  SET
    pos_structure_element_id                  =    X_Pos_Structure_Element_Id,
    business_group_id                         =    X_Business_Group_Id,
    pos_structure_version_id                  =    X_Pos_Structure_Version_Id,
    subordinate_position_id                   =    X_Subordinate_Position_Id,
    parent_position_id                        =    X_Parent_Position_Id
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Update_Row;
------------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid VARCHAR2
                    ,X_Subordinate_position_Id NUMBER
                    ,X_Position_Structure_Id NUMBER
                    ,X_Business_Group_Id NUMBER
                    ,X_Hr_Installed VARCHAR2
                    ,X_Pos_Structure_version_Id NUMBER) IS
BEGIN
--
-- Do the Pre-delete checks
--
  PER_POS_STRUCTURE_ELEMENTS_PKG.pre_delete_checks(
						X_Subordinate_position_Id => X_Subordinate_position_Id
						,X_Position_Structure_Id => X_Position_Structure_Id
						,X_Business_Group_Id => X_Business_Group_Id
						,X_Hr_Installed => X_Hr_Installed
						,X_Pos_Structure_version_Id => X_Pos_Structure_version_Id);
--
  DELETE FROM PER_POS_STRUCTURE_ELEMENTS
  WHERE  rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END PER_POS_STRUCTURE_ELEMENTS_PKG;

/
