--------------------------------------------------------
--  DDL for Package Body PER_PAR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PAR_BUS" as
/* $Header: peparrhi.pkb 120.1 2007/06/20 07:48:26 rapandi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
 l_status    varchar2(50);
 l_industry  varchar2(50);
 l_per_owner     varchar2(30);
 l_ret       boolean := FND_INSTALLATION.GET_APP_INFO ('PER', l_status,
                                                      l_industry, l_per_owner);
g_package  varchar2(33)	:= '  per_par_bus.';  -- Global package name
--
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code         varchar2(150) default null;
g_participant_id           number        default null;
--

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args(p_rec in per_par_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_par_shd.api_updating
                (p_participant_id    	    => p_rec.participant_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if p_rec.business_group_id <> per_par_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
--  elsif p_rec.questionnaire_template_id <> per_par_shd.g_old_rec.questionnaire_template_id then
--     l_argument := 'questionnaire_template_id';
--     raise l_error;
  elsif p_rec.participation_in_table <> per_par_shd.g_old_rec.participation_in_table then
     hr_utility.set_location(l_proc, 7);
     l_argument := 'participation_in_table';
     raise l_error;
  elsif p_rec.participation_in_column <> per_par_shd.g_old_rec.participation_in_column then
     hr_utility.set_location(l_proc, 8);
     l_argument := 'participation_in_column';
     raise l_error;
  elsif p_rec.participation_in_id <> per_par_shd.g_old_rec.participation_in_id then
     hr_utility.set_location(l_proc, 9);
     l_argument := 'participation_in_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 11);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         ,p_base_table => per_par_shd.g_tab_nam);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_update_allowed >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Validates that a row can be updated by checking the status of the
--  participation_status column.  A value of OPEN means the record can be
--  updated.  Other values: "Pending Approval", "Closed" or "Rejected" mean
--  the record cannot be updated.
--  Participation status can be updated at any time.
--
-- Pre-requisites:
--  Participation_status is valid.
--
-- IN Parameters:
--  p_rec
--
-- Post Success:
--  Processing continues if the update is allowed.
--
-- Post Failure:
--  An application error is raised and processing is terminated if the
--  update is not allowed.
--
-- Developer/Implementation Notes:
--  None.
--
-- Access Status:
--  Internal Row Handler Development Only.
-- ----------------------------------------------------------------------------
procedure chk_update_allowed
  (p_rec in per_par_shd.g_rec_type
  )
  is
  --
  l_proc  varchar2(72) := g_package || 'chk_update_allowed';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Check that the participation status is not closed.
  --
--  if (p_rec.participation_status = 'CLOSED' or
-- Changes for V4 appraisals built.
 if ( p_rec.participation_status = 'REJECTED') then
    -- Check that the columns arent being updated
    --
    if p_rec.date_completed
         <> per_par_shd.g_old_rec.date_completed then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.participation_type
         <> per_par_shd.g_old_rec.participation_type then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.last_notified_date
         <> per_par_shd.g_old_rec.last_notified_date then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.comments
         <> per_par_shd.g_old_rec.comments then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.person_id
         <> per_par_shd.g_old_rec.person_id then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute_category
         <> per_par_shd.g_old_rec.attribute_category then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute1
         <> per_par_shd.g_old_rec.attribute1 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute2
         <> per_par_shd.g_old_rec.attribute2 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute3
         <> per_par_shd.g_old_rec.attribute3 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute4
         <> per_par_shd.g_old_rec.attribute4 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute5
         <> per_par_shd.g_old_rec.attribute5 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute6
         <> per_par_shd.g_old_rec.attribute6 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute7
         <> per_par_shd.g_old_rec.attribute7 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute8
         <> per_par_shd.g_old_rec.attribute8 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute9
         <> per_par_shd.g_old_rec.attribute9 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute10
         <> per_par_shd.g_old_rec.attribute10 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute11
         <> per_par_shd.g_old_rec.attribute11 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute12
         <> per_par_shd.g_old_rec.attribute12 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute13
         <> per_par_shd.g_old_rec.attribute13 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute14
         <> per_par_shd.g_old_rec.attribute14 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute15
         <> per_par_shd.g_old_rec.attribute15 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute16
         <> per_par_shd.g_old_rec.attribute16 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute17
         <> per_par_shd.g_old_rec.attribute17 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute18
         <> per_par_shd.g_old_rec.attribute18 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute19
         <> per_par_shd.g_old_rec.attribute19 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    elsif p_rec.attribute20
         <> per_par_shd.g_old_rec.attribute20 then
       fnd_message.set_name('PER','PER_52465_PAR_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
end chk_update_allowed;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_participation_type >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates the participation_type exists in HR_LOOKUPS, where the
--   LOOKUP_TYPE is 'PARTICIPATION_TYPE'.
--   Also validates that updates are only allowed to a the participation_type
--   when it was previously null.
--
-- Pre-requisites:
--  None.
--
-- IN Parameters:
--  p_participant_id
--  p_object_version_number
--  p_participation_type
--  p_effective_date
--
-- Post Success:
--  Processing continues if the participation type is valid.
--
-- Post Failure:
--  An application error is raised, and the processing continues if the
--  participation_type is invalid.
--
-- Developer/Implementation Notes:
--  None.
--
-- Access Status:
--  Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_participation_type
  (p_participant_id in per_participants.participant_id%TYPE
  ,p_object_version_number in per_participants.object_version_number%TYPE
  ,p_participation_type in per_participants.participation_type%TYPE
  ,p_effective_date in date
  )
  is
  --
  l_proc  varchar2(72) := g_package || 'chk_participation_type';
  l_api_updating  boolean;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  l_api_updating := per_par_shd.api_updating
     (p_participant_id => p_participant_id
     ,p_object_version_number => p_object_version_number
     );
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Check that update is allowed
  --
  if l_api_updating and (per_par_shd.g_old_rec.participation_type <> null) then
     hr_utility.set_message(801,'PER_52466_PAR_TYPE_VAL_EXISTS');
     hr_utility.raise_error;
  else
     if (p_participation_type <> null) and
        (hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_effective_date
           ,p_lookup_type    => 'PARTICIPATION_TYPE'
           ,p_lookup_code    => p_participation_type
           )) then
        -- p_participation_type does not exist in lookup, thus error.
        hr_utility.set_message(800,'PER_52463_PAR_INVAL_PART_TYPE');
        hr_utility.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_PARTICIPANTS.PARTICIPATION_TYPE'
             ) then
          raise;
        end if;
end chk_participation_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_participation_status >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Validates that the participation_status is either NULL or exists within
--  HR_LOOKUPS where the lookup_type is 'PARTICIPANT_ACCESS'.
--
-- Pre-Requisites:
--  None.
--
-- IN Parameters:
--  p_participation_status
--  p_effective_date
--
-- Post Success:
--  Processing continues if the participation status is valid.
--
-- Post Failure:
--  An application error is raised, and processing is terminated if the
--  participation_status is invalid.
--
-- Developer/Implementation Notes:
--  None.
--
-- Access Status:
--  Internal Row Handler Use Only.
-- ----------------------------------------------------------------------------
procedure chk_participation_status
  (p_participation_status in per_participants.participation_status%TYPE
  ,p_effective_date in date
  )
  is
  --
  l_proc  varchar2(72) := g_package || 'chk_participation_status';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if (p_participation_status <> null) and
     (hr_api.not_exists_in_hr_lookups
        (p_effective_date => p_effective_date
        ,p_lookup_type    => 'PARTICIPANT_ACCESS'
        ,p_lookup_code    => p_participation_status
        )) then
     -- p_participation_status does not exist in lookup, thus error
     hr_utility.set_message(800,'PER_52464_PAR_INVAL_PAR_STATUS');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_PARTICIPANTS.PARTICIPATION_STATUS'
             ) then
          raise;
        end if;

end chk_participation_status;
--
-------------------------------------------------------------------------------
--------------------------<chk_participation_in_table>-------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a valid participation_in_table is inserted
--
--  Pre_conditions:
--
--  In Arguments:
--    p_participation_in_table
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - table name passed in is invalid
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_participation_in_table
(p_participation_in_table    in      per_participants.participation_in_table%TYPE
)
is
--
        l_api_updating       boolean;
	l_exists	     varchar2(1);
        l_proc               varchar2(72)  :=  g_package||'chk_participation_in_table';
        --
	Cursor chk_table_exists
	 is
	select 	'Y'
	from	all_tables
	where	table_name = upper(p_participation_in_table)
        and owner = l_per_owner;

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if (p_participation_in_table is NULL) then
      hr_utility.set_message(801, 'HR_52064_PAR_TABLE_NULL');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  open chk_table_exists;
  fetch chk_table_exists into l_exists;
	if chk_table_exists%notfound then
            close chk_table_exists;
            hr_utility.set_message(801,'HR_52065_PAR_INVALID_TABLE');
            hr_utility.raise_error;
	end if;
  close chk_table_exists;
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
 EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_PARTICIPANTS.PARTICIPATION_IN_TABLE'
             ) then
          raise;
        end if;
end chk_participation_in_table;
--
--
-------------------------------------------------------------------------------
--------------------------<chk_participation_in_column>------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a valid participation_in_column is inserted
--
--  Pre_conditions:
--    Valid participation_in_table
--
--  In Arguments:
--    p_participation_in_table
--    p_participation_in_column
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - column name passed in is invalid
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_participation_in_column
(p_participation_in_table    in      per_participants.participation_in_table%TYPE
,p_participation_in_column   in      per_participants.participation_in_column%TYPE
)
is
--
        l_api_updating       boolean;
	l_exists	     varchar2(1);
        l_proc               varchar2(72)  :=  g_package||'chk_participation_in_column';
        --
	Cursor chk_column_exists
	 is
	select 	'Y'
	from	all_tab_columns
	where	table_name  = upper(p_participation_in_table)
	and	column_name = upper(p_participation_in_column)
        and     owner       = l_per_owner;

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if (p_participation_in_column is NULL) then
      hr_utility.set_message(801, 'HR_52066_PAR_COLUMN_NULL');
      hr_utility.raise_error;
  end if;
  --
  open chk_column_exists;
  fetch chk_column_exists into l_exists;
	if chk_column_exists%notfound then
            close chk_column_exists;
            hr_utility.set_message(801,'HR_52067_PAR_INVALID_COLUMN');
            hr_utility.raise_error;
	end if;
  close chk_column_exists;
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location('Leaving: '|| l_proc, 10);

 EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_PARTICIPANTS.PARTICIPATION_IN_COLUMN'
             ) then
          raise;
        end if;
end chk_participation_in_column;
--
--
-------------------------------------------------------------------------------
-----------------------------<chk_participation_in_id>-------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a valid participation_in_id is inserted
--
--  Pre_conditions:
--    Valid participation_in_table
--    Valid participation_in_column
--    Valid business_group_id
--
--  In Arguments:
--    p_participation_in_table
--    p_participation_in_column
--    p_participation_in_id
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - participation_in_id does not exist in the table
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_participation_in_id
(p_participation_in_table    in      per_participants.participation_in_table%TYPE
,p_participation_in_column   in      per_participants.participation_in_column%TYPE
,p_participation_in_id	     in      per_participants.participation_in_id%TYPE
,p_business_group_id	     in      per_participants.business_group_id%TYPE
)
is
--
        l_business_group_id  per_participants.business_group_id%TYPE;
	l_exists	     varchar2(1);
        l_proc               varchar2(72)  :=  g_package||'chk_participation_in_id';
        l_sql_cursor  	     integer;            -- Dynamic sql cursor
  	l_dynamic_sql 	     varchar2(2000);     -- Dynamic sql text
  	l_rows    	     integer;            -- No of rows returned
    lv_cross_business_group VARCHAR2(10); -- bug 1980440 fix

        --
	-- Check if participation_in_id exists and is
	-- in the same business group as participant
	--

        --
begin
/*
  l_dynamic_sql := 'select  par.business_group_id '  ||
                         'from    {p_participation_in_table} par ' ||
                   	 'where   par.{participation_in_column} = :p_participation_in_id ' ;
*/
  --
  hr_utility.set_location('Entering:'|| l_proc, 1);
  -- check if the participant_in_id is set as it is a mandatory
  -- column, if not then error
  if (p_participation_in_id is NULL) then
      hr_utility.set_message(801, 'HR_52068_PAR_COLUMN_ID_NULL');
      hr_utility.raise_error;
  end if;
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'participation_in_table'
    ,p_argument_value => p_participation_in_table
    );
  --
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'participation_in_column'
    ,p_argument_value => p_participation_in_column
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  -- Dynamic literal string replacement
  --
  l_dynamic_sql := 'select  par.business_group_id '  ||
                         'from ' ||p_participation_in_table ||' par ' ||
                   	 'where   par.'|| p_participation_in_column || '= :p_participation_in_id ' ;
/*
  l_dynamic_sql := Replace(l_dynamic_sql, '{p_participation_in_table}',
                                            p_participation_in_table);
  l_dynamic_sql := Replace(l_dynamic_sql, '{p_participation_in_column}',
                                            p_participation_in_column);
*/
  --
  hr_Utility.Set_Location(substr(L_DYNAMIC_SQL, 1,50), 4);
  hr_Utility.Set_Location(substr(L_DYNAMIC_SQL, 51), 4);

  -- Dynamic sql steps:
  -- ==================
  -- 1. Open dynamic sql cursor
  -- 2. Parse dynamic sql
  -- 3. Bind dynamic sql variables
  -- 4. Define dynamic sql columns
  -- 5. Execute and fetch dynamic sql
  --
  hr_Utility.Set_Location(l_proc, 6);
  l_sql_cursor := dbms_sql.open_cursor;                            -- Step 1
  --
  hr_Utility.Set_Location(l_proc, 10);
  dbms_sql.parse(l_sql_cursor, l_dynamic_sql, dbms_sql.v7);        -- Step 2
  --
  hr_Utility.Set_Location(l_proc, 15);
  dbms_sql.bind_variable(l_sql_cursor,                             -- Step 3
                         ':p_participation_in_id', p_participation_in_id);
  --
  hr_Utility.Set_Location(l_proc, 20);
  dbms_sql.define_column(l_sql_cursor, 1, p_business_group_id);    -- Step 4
  --
  hr_Utility.Set_Location(l_proc, 30);
  l_rows := dbms_sql.execute_and_fetch(l_sql_cursor, false);       -- Step 5
  If (l_rows = 0 ) then
       -- if no rows are returned that means the id does not exist
       -- hence error
       dbms_sql.close_cursor(l_sql_cursor);
       hr_Utility.set_Location(l_proc, 35);
       hr_utility.set_message(801,'HR_52069_PAR_INVALID_COLUMN_ID');
       hr_utility.raise_error;
  Else
      -- check if the business groups match
      --
      -- Get the column values and close the cursor
      --
      hr_Utility.set_Location(l_proc, 40);
      dbms_sql.column_value(l_sql_cursor, 1, l_business_group_id);
	  dbms_sql.close_cursor(l_sql_cursor);

      -- bug 1980440 fix starts
      -- do the validation if Cross Business Group profile is not enabled
      lv_cross_business_group := fnd_profile.value('HR_CROSS_BUSINESS_GROUP');

      if lv_cross_business_group <> 'Y' THEN

	    if p_business_group_id <> l_business_group_id then
     	  hr_utility.set_message(801,'HR_52070_PAR_COL_ID_DIFF_BG');
    	  hr_utility.raise_error;
        end if;

      end if;

  End if;
  --
--
-- If any other Oracle Error is trapped (e.g. during parse, execute,
-- fetch etc), then we must check to see if the cursor is still open
-- and close down if necessary.
--
Exception

when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_PARTICIPANTS.PARTICIPATION_IN_ID'
             ) then
          raise;
        end if;

  When Others Then
    Hr_Utility.Set_Location(l_proc, 50);
    If (dbms_sql.is_open(l_sql_cursor)) then
      hr_utility.Set_Location(l_proc, 55);
      dbms_sql.close_cursor(l_sql_cursor);
    End If;
    Raise;
--
  hr_utility.set_location(l_proc, 55);
  --
  hr_utility.set_location('Leaving: '|| l_proc, 60);


end chk_participation_in_id;
--
--
-----------------------------------------------------------------------------
--------------------------------<chk_person_id>------------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the person_id has been entered as it is a mandatory
--     column
--   - Validates that the person is in the same business group
--     as participant
--   - Validates that the person is valid as of effective date
--
--  Pre_conditions:
--    Valid business group id
--    Valid participation_in_table
--    Valid participation_in_column
--    Valid participation_in_id
--
--  In Arguments:
--    p_participant_id
--    p_object_version_number
--    p_person_id
--    p_effective_date
--    p_business_group_id
--    participation_in_table
--    participation_in_column
--    participation_in_id
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- effective_date is not set
--	-- person does not exist as of effective date
--      -- person is not in the same business group as participants
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_person_id
(p_participant_id	     in      per_participants.participant_id%TYPE
,p_object_version_number     in	     per_participants.object_version_number%TYPE
,p_person_id    	     in      per_participants.person_id%TYPE
,p_business_group_id	     in	     per_participants.business_group_id%TYPE
,p_participation_in_table    in	     per_participants.participation_in_table%TYPE
,p_participation_in_column   in      per_participants.participation_in_column%TYPE
,p_participation_in_id	     in      per_participants.participation_in_id%TYPE
,p_effective_date	     in	     date
)
is
--
	l_exists	     varchar2(1);
        l_api_updating	     boolean;
	l_business_group_id  per_participants.business_group_id%TYPE;
        l_proc               varchar2(72)  :=  g_package||'chk_chk_person_id';
    lv_cross_business_group VARCHAR2(10); -- bug 1980440 fix

 	--
	--
	-- Cursor to check if the person_exists
	--
	Cursor csr_person_bg
          is
	select  business_group_id
	from	per_all_people_f
	where   person_id = p_person_id;
    -- Bug 1980440 fix
    -- Cursor to check if person is valid as of effective date
	-- this cursor uses per_all_people_f to support Cross Business Group
    --
	Cursor csr_cbg_person_bg
          is
	select  business_group_id
	from	per_all_people_f
	where   person_id = p_person_id;
	--
	--
	-- Cursor to check if person is valid
	-- as of effective date
	--
	Cursor csr_person_valid_date
          is
	select  'Y'
	from	per_all_people_f
	where   person_id = p_person_id
	and	p_effective_date between
		effective_start_date and nvl(effective_end_date,hr_api.g_eot);

    -- Bug 1980440 fix
    -- Cursor to check if person is valid as of effective date
	-- this cursor uses per_all_people_f to support Cross Business Group
    --
	Cursor csr_cbg_person_valid_date
          is
	select  'Y'
	from	per_all_people_f
	where   person_id = p_person_id
	and	p_effective_date between
		effective_start_date and nvl(effective_end_date,hr_api.g_eot);

    --
	-- Cursor to check if person id is unique for the
        -- combination of participation_in_table, participation_in_column
	-- and participation_in_id. Basically the same person cannot be the
        -- appraisor and the appraisee etc...
	--
	Cursor csr_person_id_unique
          is
	select  'Y'
	from	per_participants par
	where   (   (p_participant_id is null)
		  or(p_participant_id <> par.participant_id)
		)
	and	par.participation_in_table 	= p_participation_in_table
	and     par.participation_in_column 	= p_participation_in_column
	and     par.participation_in_id 	= p_participation_in_id
	and 	par.person_id			= p_person_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
   if (p_person_id is NULL) then
       	hr_utility.set_message(801, 'HR_52075_PAR_PERSON_NULL');
       	hr_utility.raise_error;
   end if;
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'participation_in_table'
    ,p_argument_value => p_participation_in_table
    );
  --
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'participation_in_column'
    ,p_argument_value => p_participation_in_column
    );
  --
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'participation_in_id'
    ,p_argument_value => p_participation_in_id
    );
  --
  --
  hr_utility.set_location('Entering:'|| l_proc, 2);
  --
  --
  -- bug 1980440 fix starts
  lv_cross_business_group := fnd_profile.value('HR_CROSS_BUSINESS_GROUP');

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for participant role has changed
  --
  l_api_updating := per_par_shd.api_updating
         (p_participant_id         => p_participant_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (  (l_api_updating and nvl(per_par_shd.g_old_rec.person_id,
                                hr_api.g_number)
                        <> nvl(p_person_id,hr_api.g_number)
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     if p_person_id is not null then
        -- Bug 1980440 fix
        -- if Cross Business Group is not enabled use csr_person_bg cursor
        -- to fetch the Business Group Id
        if lv_cross_business_group <> 'Y' THEN
            open csr_person_bg;
            fetch csr_person_bg into l_business_group_id;
	        if csr_person_bg%notfound then
                close csr_person_bg;
                hr_utility.set_message(801,'HR_52071_PAR_PERSON_NOT_EXIST');
                hr_utility.raise_error;
	        end if;
            close csr_person_bg;
        else -- use the csr_cbg_person_bg cursor to get the Business Group Id
            open csr_cbg_person_bg;
            fetch csr_cbg_person_bg into l_business_group_id;
	        if csr_cbg_person_bg%notfound then
                close csr_cbg_person_bg;
                hr_utility.set_message(801,'HR_52071_PAR_PERSON_NOT_EXIST');
                hr_utility.raise_error;
	        end if;
            close csr_cbg_person_bg;
        end if;
	    hr_utility.set_location(l_proc, 3);

        -- bug 1980440 fix starts
        -- do the validation if Cross Business Group profile is not enabled
        if lv_cross_business_group <> 'Y' THEN
	       -- check if business group match
	       if p_business_group_id <> l_business_group_id then
	           hr_utility.set_message(801,'HR_52072_PAR_PERSON_DIFF_BG');
               hr_utility.raise_error;
	       end if;
        end if;
        -- bug 1980440 fix ends

	   hr_utility.set_location(l_proc, 4);
	   -- check if person is valid as of effective date
       -- bug 1980440 fix starts
       if lv_cross_business_group <> 'Y' THEN
	       open csr_person_valid_date;
           fetch csr_person_valid_date into l_exists;
	       if csr_person_valid_date%notfound then
                close csr_person_valid_date;
                hr_utility.set_message(801,'HR_52073_PAR_PERSON_DATE_RANGE');
                hr_utility.raise_error;
	       end if;
           close csr_person_valid_date;
       else
           open csr_cbg_person_valid_date;
           fetch csr_cbg_person_valid_date into l_exists;
	       if csr_cbg_person_valid_date%notfound then
                close csr_cbg_person_valid_date;
                hr_utility.set_message(801,'HR_52073_PAR_PERSON_DATE_RANGE');
                hr_utility.raise_error;
	       end if;
           close csr_cbg_person_valid_date;
       end if;
       -- bug 1980440 fix ends
       -- check that the person id is unique
       hr_utility.set_location(l_proc, 5);
       open csr_person_id_unique;
       fetch csr_person_id_unique into l_exists;
	   if csr_person_id_unique%found then
            close csr_person_id_unique;
            hr_utility.set_message(801,'HR_52074_PAR_PERSON_NOT_UNIQUE');
            hr_utility.raise_error;
	   end if;
       close csr_person_id_unique;
    end if;
     --
  end if;
  --
   hr_utility.set_location(l_proc, 6);
  --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_PARTICIPANTS.PERSON_ID'
             ) then
          raise;
        end if;
end chk_person_id;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_df
  (p_rec in per_par_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.participant_id is not null) and (
    nvl(per_par_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_par_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.participant_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_PARTICIPANTS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      ,p_attribute21_name   => 'PARTICIPANT_USAGE_STATUS'
      ,p_attribute21_value  => p_rec.participant_usage_status
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_participant_usage_status >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the oparticipant_usage_status value
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the participant_usage_status value is valid.
--
-- Post Failure:
--   An application error is raised if the participant_usage_status value is
--   invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_participant_usage_status
  (p_participant_id            IN number
  ,p_object_version_number     IN number
  ,p_participant_usage_status  IN varchar2
  ,p_effective_date IN date
  ) IS


  --
  l_proc           varchar2(72) := g_package || 'chk_participant_usage_status';
  l_api_updating   boolean;
  l_participant_usage_status varchar2(30);
  --
--
BEGIN


  hr_utility.set_location('Entering:'|| l_proc, 10);


  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The participant_usage_status value has changed
  --
  l_api_updating := per_par_shd.api_updating
         (p_participant_id           => p_participant_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_par_shd.g_old_rec.participant_usage_status, hr_api.g_varchar2)
    = nvl(p_participant_usage_status, hr_api.g_varchar2))
  THEN
     RETURN;
  END IF;

  IF p_participant_usage_status IS NOT null THEN
    --
    -- Check that oparticipant_usage_status is valid.
    --
    hr_utility.set_location(l_proc, 20);
    IF hr_api.not_exists_in_hr_lookups
        (p_effective_date => p_effective_date
        ,p_lookup_type => 'APPRAISAL_OFFLINE_STATUS'
        ,p_lookup_code => upper(p_participant_usage_status)
        ) THEN
     fnd_message.set_name('PER', 'HR_34569_INV_PART_USAGE_STATUS');
      fnd_message.raise_error;
    END IF;

  /*  IF upper(p_participant_usage_status)
        not in ('EXPORTED','IMPORTED','IMPORT IGNORED') THEN
      fnd_message.set_name('PER', 'HR_50264_INV_PART_USAGE_STATUS');
      fnd_message.raise_error;
    END IF;*/

  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 970);
EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_PARTICIPANTS.PARTICIPANT_USAGE_STATUS')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_participant_usage_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_par_shd.g_rec_type
			 ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
  ,p_associated_column1 => per_par_shd.g_tab_nam ||
                             '.BUSINESS_GROUP_ID');  -- Validate Bus Grp
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(l_proc, 1);
  --
  per_par_bus.chk_participation_in_table
  (p_participation_in_table	=>	p_rec.participation_in_table
  );
  --
  hr_utility.set_location(l_proc, 2);
  --
  per_par_bus.chk_participation_in_column
  (p_participation_in_table	=>	p_rec.participation_in_table
  ,p_participation_in_column    =>	p_rec.participation_in_column
  );
  --
  hr_utility.set_location(l_proc, 3);
  --
  per_par_bus.chk_participation_in_id
  (p_participation_in_table    	=>	p_rec.participation_in_table
  ,p_participation_in_column   	=>	p_rec.participation_in_column
  ,p_participation_in_id       	=>	p_rec.participation_in_id
  ,p_business_group_id	     	=>	p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc, 4);
  --
  per_par_bus.chk_person_id
  (p_participant_id	     	=>	p_rec.participant_id
  ,p_object_version_number     	=>	p_rec.object_version_number
  ,p_person_id    	     	=>	p_rec.person_id
  ,p_business_group_id	     	=>	p_rec.business_group_id
  ,p_participation_in_table    	=>	p_rec.participation_in_table
  ,p_participation_in_column   	=>	p_rec.participation_in_column
  ,p_participation_in_id	=>	p_rec.participation_in_id
  ,p_effective_date	     	=>	p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 5);
  --
  per_par_bus.chk_participation_status
  (p_participation_status   => p_rec.participation_status
  ,p_effective_date         => p_effective_date
  );
  --
  hr_utility.set_location(l_proc,6);
  --
  per_par_bus.chk_participation_type
  (p_participant_id => p_rec.participant_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_participation_type => p_rec.participation_type
  ,p_effective_date => p_effective_date
  );
  --
 hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  per_par_bus.chk_participant_usage_status
  (p_participant_id => p_rec.participant_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_participant_usage_status => p_rec.participant_usage_status
  ,p_effective_date => p_effective_date
  );
  --
  -- Call Descriptive Flexfield Validation routines
  --
  per_par_bus.chk_df(p_rec => p_rec);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_par_shd.g_rec_type
			  ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
  ,p_associated_column1 => per_par_shd.g_tab_nam ||
                             '.BUSINESS_GROUP_ID');  -- Validate Bus Grp

  hr_multi_message.end_validation_set;
  --
  --
  -- Rule Check non-updateable fields cannot be updated
  --
  chk_non_updateable_args(p_rec	=> p_rec);
  --
  hr_utility.set_location(l_proc, 2);
  --
  per_par_bus.chk_participation_status
  (p_participation_status   => p_rec.participation_status
  ,p_effective_date         => p_effective_date
  );
  --
  per_par_bus.chk_update_allowed
  (p_rec   => p_rec
  );
  --
  per_par_bus.chk_participation_type
  (p_participant_id => p_rec.participant_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_participation_type => p_rec.participation_type
  ,p_effective_date => p_effective_date
  );
  --
  hr_utility.set_location(l_proc,3);
  --
  per_par_bus.chk_person_id
  (p_participant_id	     	=>	p_rec.participant_id
  ,p_object_version_number     	=>	p_rec.object_version_number
  ,p_person_id    	     	=>	p_rec.person_id
  ,p_business_group_id	     	=>	p_rec.business_group_id
  ,p_participation_in_table    	=>	p_rec.participation_in_table
  ,p_participation_in_column   	=>	p_rec.participation_in_column
  ,p_participation_in_id	=>	p_rec.participation_in_id
  ,p_effective_date	     	=>	p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 5);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
  ,p_associated_column1 => per_par_shd.g_tab_nam ||
                             '.BUSINESS_GROUP_ID');  -- Validate Bus Grp

  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  per_par_bus.chk_participant_usage_status
  (p_participant_id => p_rec.participant_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_participant_usage_status => p_rec.participant_usage_status
  ,p_effective_date => p_effective_date
  );
  --
  -- Call Descriptive Flexfield Validation routines
  --
  per_par_bus.chk_df(p_rec => p_rec);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_par_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
         (  p_participant_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups   pbg,
                 per_participants      par
          where  par.participant_id    = p_participant_id
            and  pbg.business_group_id = par.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'participant_id',
                              p_argument_value => p_participant_id );
   --
  if nvl(g_participant_id, hr_api.g_number) = p_participant_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 10);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
    g_participant_id := p_participant_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
End return_legislation_code;
--
end per_par_bus;

/
