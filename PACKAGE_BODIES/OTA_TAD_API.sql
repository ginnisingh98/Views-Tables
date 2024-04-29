--------------------------------------------------------
--  DDL for Package Body OTA_TAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TAD_API" as
/* $Header: ottad01t.pkb 115.10 2004/02/10 07:10:30 hwinsor ship $ */
--
-- Private package current record structure definition
--
g_old_rec		g_rec_type;
--
-- Global package name
--
g_package		varchar2(33)	:= '  ota_tad_api.';
--
-- Global api dml status
--
g_api_dml		boolean;
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated or hr_api.child_integrity_violated has
--   been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--
-- Pre Conditions:
--   Either hr_api.check_integrity_violated, hr_api.parent_integrity_violated
--   or hr_api.child_integrity_violated has been raised with the subsequent
--   stripping of the constraint name from the generated error message text.
--
-- In Arguments:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in varchar2) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'OTA_ACTIVITY_DEFINITIONS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TAD_MULTIPLE_CON_VERSI_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< call_error_message >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Passes the error information to the procedure set_message of package
--   hr_utility.
--
Procedure call_error_message
  (
   p_error_appl             varchar2
  ,p_error_txt              varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'call_error_message';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- ** TEMP ** Add error message with the following text.
  --
  fnd_message.set_name         ( p_error_appl   ,p_error_txt);
  fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End call_error_message;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_unique_name >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The activity name is mandantory and must be unique within business group.
--
Procedure check_unique_name
  (
   p_name               in  varchar2
  ,p_business_group_id  in  number
  ,p_activity_id        in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_unique_name';
  --
  cursor sel_unique_name is
    select 'Y'
      from ota_activity_definitions_vl      tad
     where tad.name                 =    p_name
       and tad.business_group_id    =    p_business_group_id
       and (p_activity_id is null or tad.activity_id <> p_activity_id);
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_unique_name;
  fetch sel_unique_name into v_exists;
  --
  if sel_unique_name%found then
    --
    close sel_unique_name;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl         =>   'OTA'
                      , p_error_txt          =>  'OTA_13331_TAD_DUPLICATE'
                      );
    --
  end if;
  --
  close sel_unique_name;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_unique_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_activity_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Return the surrogate key from a passed parameter of name or code.
--
Function get_activity_id
  (
   p_name               in     varchar2
  ,p_business_group_id  in  number
  )
   Return number is
  --
  v_activity_id           ota_activity_definitions.activity_id%TYPE ;
  v_proc                  varchar2(72) := g_package||'get_activity_id';
  --
  cursor   sel_activity_id is
    select activity_id
      from ota_activity_definitions_vl      tad
     where tad.name                 =    p_name
       and tad.business_group_id    =    p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_name is not null  Then
    --
    Open  sel_activity_id;
    fetch sel_activity_id into v_activity_id;
    --
    if sel_activity_id%notfound then
      --
      close sel_activity_id;
      --
      -- ** TEMP ** Add error message with the following text.
      --
      call_error_message( p_error_appl         =>   'OTA'
                        , p_error_txt          =>  'OTA_13332_TAD_NOT_EXISTS'
                        );
      --
    end if;
    --
    close sel_activity_id;
    --
    return( v_activity_id);
    --
  Else
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl         =>   'OTA'
                      , p_error_txt          =>  'OTA_13332_TAD_NOT_EXISTS'
                      );
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End get_activity_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_tav_exist >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete validation
--   Check whether any child rows in ota_activity_versions exist for
--   this activity. If they do exist then this activity may not be deleted.
--
Procedure check_tav_exist
  (
   p_activity_id      in     number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_tav_exist';
  --
  cursor sel_tav_exist is
    select 'Y'
      from ota_activity_versions   tav
     where tav.activity_id    =    p_activity_id;
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_tav_exist;
  fetch sel_tav_exist into v_exists;
  --
  if sel_tav_exist%found then
    --
    close sel_tav_exist;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl         =>   'OTA'
                      , p_error_txt          =>  'OTA_13333_TAD_DEL_TAV_EXISTS'
                      );
    --
  end if;
  --
  close sel_tav_exist;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_tav_exist;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tpm_exist >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete validation
--   Check whether any child rows in training_plan_members exist for
--   this activity. If they do exist then this activity may not be deleted.
--
Procedure check_if_tpm_exist
  (
   p_activity_id      in     number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_tpm_exist';
  --
  -- cursor to check if the activity version is referenced in training plan members
  --
  Cursor  c_get_tpm_rows is
    select 'Y'
    from OTA_TRAINING_PLAN_MEMBERS
    where activity_definition_id = p_activity_id;
  --
  l_dyn_curs   integer;
  l_dyn_rows   integer;
  l_dummy      varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check if the activity definition is referenced in training plan members table
  open c_get_tpm_rows;
  fetch c_get_tpm_rows into l_dummy;
  if c_get_tpm_rows%found then
    close c_get_tpm_rows;
    call_error_message( p_error_appl         =>  'OTA'
                      , p_error_txt          =>  'OTA_13821_TAD_NO_DEL_TPM_EXIST');
  else
    close c_get_tpm_rows;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_tpm_exist;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_overlapping_dates >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description:
--   Validate whether two datepairs are overlapping.
--
Function check_overlapping_dates
  (
   p_first_start_date    in  date
  ,p_first_end_date      in  date
  ,p_second_start_date   in  date
  ,p_second_end_date     in  date
  ) Return boolean Is
--
  v_proc 	varchar2(72) := g_package||'check_overlapping_dates';
--
Begin
  --
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  -- Check whether the first startdate is between the second startdate and
  -- the second enddate => Overlapping dates
  --
  If ( nvl( p_first_start_date ,hr_api.g_sot)
       Between  nvl( p_second_start_date ,hr_api.g_sot)
       And      nvl( p_second_end_date   ,hr_api.g_eot)  )       OR
  --
  -- Check whether the first enddate is between the second startdate and
  -- the second enddate => Overlapping dates
  --
     ( nvl( p_first_end_date ,hr_api.g_eot)
       Between  nvl( p_second_start_date ,hr_api.g_sot)
       And      nvl( p_second_end_date   ,hr_api.g_eot)  )       OR
  --
  -- Check whether the first datepair includes the second datepair
  -- => Overlapping dates
  --
    ((  nvl( p_second_start_date ,hr_api.g_sot)
        Between  nvl( p_first_start_date ,hr_api.g_sot)
        And      nvl( p_first_end_date   ,hr_api.g_eot)  ) AND
     (  nvl( p_second_end_date ,hr_api.g_eot)
        Between  nvl( p_first_start_date ,hr_api.g_sot)
        And      nvl( p_first_end_date   ,hr_api.g_eot)  )    )  OR
  --
  -- Check whether the second datepair includes the first datepair
  -- => Overlapping dates
  --
    ((  nvl( p_first_start_date ,hr_api.g_sot)
        Between  nvl( p_second_start_date ,hr_api.g_sot)
        And      nvl( p_second_end_date   ,hr_api.g_eot) ) AND
     (  nvl( p_first_end_date ,hr_api.g_eot)
        Between  nvl( p_second_start_date ,hr_api.g_sot)
        And      nvl( p_second_end_date   ,hr_api.g_eot) )    )  THEN
    --
    -- The pair of dates (first,second) are overlapped
    --
    Return( true);
    --
  Else
    --
    -- The pair of dates (first,second) are NOT overlapped
    --
    Return( false);
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
  --
End check_overlapping_dates;
--
-- ----------------------------------------------------------------------------
-- |----------------------< exist_multiple_versions >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Checks whether multiple activity versions exist.
--
Function exist_multiple_versions
  (
   p_activity_id  in  number
  ) Return boolean is
  --
  v_proc                 varchar2(72) := g_package||'exist_multiple_versions';
  --
  v_version_id           ota_activity_versions.activity_version_id%TYPE;
  v_start_date           date;
  v_end_date             date;
  --
  v_compared_version_id  ota_activity_versions.activity_version_id%TYPE;
  v_compared_start_date  date;
  v_compared_end_date    date;
  --
  cursor sel_versions is
    select tav.activity_version_id
         , tav.start_date
         , tav.end_date
      from ota_activity_versions    tav
     where tav.activity_id        = p_activity_id
  order by activity_version_id;
  --
  cursor sel_compared_versions( pcurs_version_id IN NUMBER) is
    select tav.activity_version_id
         , tav.start_date
         , tav.end_date
      from ota_activity_versions      tav
     where tav.activity_id          = p_activity_id
       and tav.activity_version_id  > pcurs_version_id
  order by activity_version_id;
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_versions;
  fetch sel_versions into v_version_id
                        , v_start_date
                        , v_end_date ;
  --
  -- Each row of the SET 1 is compared with every row of the SET 2.
  -- SET 2 is equal to SET 1. Both are sorted.
  -- Startrow of SET 2 is the next row of the selected row of SET 1.
  --
  -- first row  --> --------                    --------
  --               |        |                  |        |<-- second row
  --               |        |                  |        |  .
  --               | SET 1  | == COMPARE ==>   | SET 2  |  .
  --               |        |                  |        |  .
  --               |        |                  |        |  .
  --                --------                    -------- <-- last row
  --
  Loop
    --
    Exit When sel_versions%notfound;
    --
    Open  sel_compared_versions( v_version_id);
    fetch sel_compared_versions into v_compared_version_id
                                   , v_compared_start_date
                                   , v_compared_end_date ;
    --
    Loop
      --
      Exit When sel_compared_versions%notfound;
      --
      If check_overlapping_dates( v_start_date
                                , v_end_date
                                , v_compared_start_date
                                , v_compared_end_date )  Then
        --
        -- Multiple activity versions exist
        --
        Return( True);
        --
      End if;
      --
      fetch sel_compared_versions into v_compared_version_id
                                     , v_compared_start_date
                                     , v_compared_end_date ;
      --
    End Loop;
    --
    close sel_compared_versions;
    --
    fetch sel_versions into v_version_id
                          , v_start_date
                          , v_end_date ;
    --
  End Loop;
  --
  close sel_versions;
  --
  -- Multiple activity versions do not exist
  --
  Return( false);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End exist_multiple_versions;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_concurrent_versions >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The MULTIPLE_CON_VERSIONS_FLAG must be set to 'Y' if any concurrent
--   Activity Versions exist.
--
Procedure check_concurrent_versions
  (
   p_activity_id  in  number
  ,p_flag         in  varchar2
  ) is
  --
  v_proc                 varchar2(72) := g_package||'check_concurrent_versions';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_flag <> 'Y'  AND  exist_multiple_versions( p_activity_id)  THEN
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl         =>   'OTA'
                      , p_error_txt          =>  'OTA_13335_TAD_CON_VERSIONS'
                      );
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_concurrent_versions;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The functions of this
--   procedure are as follows:
--   1. Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2. To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3. To insert the row into the schema.
--   4. To trap any constraint violations that may have occurred.
--   5. To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_activity_definitions
  --
  insert into ota_activity_definitions
  (	activity_id,
	business_group_id,
	name,
	comments,
	description,
	multiple_con_versions_flag,
	object_version_number,
	tad_information_category,
	tad_information1,
	tad_information2,
	tad_information3,
	tad_information4,
	tad_information5,
	tad_information6,
	tad_information7,
	tad_information8,
	tad_information9,
	tad_information10,
	tad_information11,
	tad_information12,
	tad_information13,
	tad_information14,
	tad_information15,
	tad_information16,
	tad_information17,
	tad_information18,
	tad_information19,
	tad_information20,
      category_usage_id
  )
  Values
  (	p_rec.activity_id,
	p_rec.business_group_id,
	p_rec.name,
	p_rec.comments,
	p_rec.description,
	p_rec.multiple_con_versions_flag,
	p_rec.object_version_number,
	p_rec.tad_information_category,
	p_rec.tad_information1,
	p_rec.tad_information2,
	p_rec.tad_information3,
	p_rec.tad_information4,
	p_rec.tad_information5,
	p_rec.tad_information6,
	p_rec.tad_information7,
	p_rec.tad_information8,
	p_rec.tad_information9,
	p_rec.tad_information10,
	p_rec.tad_information11,
	p_rec.tad_information12,
	p_rec.tad_information13,
	p_rec.tad_information14,
	p_rec.tad_information15,
	p_rec.tad_information16,
	p_rec.tad_information17,
	p_rec.tad_information18,
	p_rec.tad_information19,
	p_rec.tad_information20,
      p_rec.category_usage_id
  );
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated then
    -- Parent integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1. Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2. To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3. To update the specified row in the schema using the primary key in
--      the predicates.
--   4. To trap any constraint violations that may have occurred.
--   5. To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_activity_definitions Row
  --
  update ota_activity_definitions
  set
  activity_id                       = p_rec.activity_id,
  business_group_id                 = p_rec.business_group_id,
  name                              = p_rec.name,
  comments                          = p_rec.comments,
  description                       = p_rec.description,
  multiple_con_versions_flag        = p_rec.multiple_con_versions_flag,
  object_version_number             = p_rec.object_version_number,
  tad_information_category          = p_rec.tad_information_category,
  tad_information1                  = p_rec.tad_information1,
  tad_information2                  = p_rec.tad_information2,
  tad_information3                  = p_rec.tad_information3,
  tad_information4                  = p_rec.tad_information4,
  tad_information5                  = p_rec.tad_information5,
  tad_information6                  = p_rec.tad_information6,
  tad_information7                  = p_rec.tad_information7,
  tad_information8                  = p_rec.tad_information8,
  tad_information9                  = p_rec.tad_information9,
  tad_information10                 = p_rec.tad_information10,
  tad_information11                 = p_rec.tad_information11,
  tad_information12                 = p_rec.tad_information12,
  tad_information13                 = p_rec.tad_information13,
  tad_information14                 = p_rec.tad_information14,
  tad_information15                 = p_rec.tad_information15,
  tad_information16                 = p_rec.tad_information16,
  tad_information17                 = p_rec.tad_information17,
  tad_information18                 = p_rec.tad_information18,
  tad_information19                 = p_rec.tad_information19,
  tad_information20                 = p_rec.tad_information20,
  category_usage_id                 = p_rec.category_usage_id
  where activity_id = p_rec.activity_id;
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated then
    -- Parent integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of this
--   procedure are as follows:
--   1. To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2. To delete the specified row from the schema using the primary key in
--      the predicates.
--   3. To ensure that the row was deleted.
--   4. To trap any constraint violations that may have occurred.
--   5. To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ota_activity_definitions row.
  --
  delete from ota_activity_definitions
  where activity_id = p_rec.activity_id;
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  If sql%NOTFOUND then
    --
    -- The row to be deleted was NOT found therefore a serious
    -- error has occurred which MUST be reported.
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_activity_definitions_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.activity_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user and the
--   specified object version number match. Secondly, during the locking of
--   the row, the row is selected into the g_old_rec data structure which
--   enables the current row values from the server to be available to the api.
--
-- Pre Conditions:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Arguments:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version number of row.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   For each primary key and the object version number arguments add a
--   call to hr_api.mandatory_arg_error procedure to ensure that these
--   argument values are not null.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_activity_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	activity_id,
	business_group_id,
	name,
	comments,
	description,
	multiple_con_versions_flag,
	object_version_number,
	tad_information_category,
	tad_information1,
	tad_information2,
	tad_information3,
	tad_information4,
	tad_information5,
	tad_information6,
	tad_information7,
	tad_information8,
	tad_information9,
	tad_information10,
	tad_information11,
	tad_information12,
	tad_information13,
	tad_information14,
	tad_information15,
	tad_information16,
	tad_information17,
	tad_information18,
	tad_information19,
	tad_information20,
      category_usage_id
    from	ota_activity_definitions
    where	activity_id = p_activity_id
    and    object_version_number + 0 = p_object_version_number
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.check_mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    --
    -- If the row wasn't returned then either:
    -- a) The row does NOT exist.
    -- b) The row is NOT current (i.e. failure on the object version).
    --
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'ota_activity_definitions');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ota_activity_definitions');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_activity_id                   in number,
	p_business_group_id             in number,
	p_name                          in varchar2,
	p_comments                      in varchar2,
	p_description                   in varchar2,
	p_multiple_con_versions_flag    in varchar2,
	p_object_version_number         in number,
	p_tad_information_category      in varchar2,
	p_tad_information1              in varchar2,
	p_tad_information2              in varchar2,
	p_tad_information3              in varchar2,
	p_tad_information4              in varchar2,
	p_tad_information5              in varchar2,
	p_tad_information6              in varchar2,
	p_tad_information7              in varchar2,
	p_tad_information8              in varchar2,
	p_tad_information9              in varchar2,
	p_tad_information10             in varchar2,
	p_tad_information11             in varchar2,
	p_tad_information12             in varchar2,
	p_tad_information13             in varchar2,
	p_tad_information14             in varchar2,
	p_tad_information15             in varchar2,
	p_tad_information16             in varchar2,
	p_tad_information17             in varchar2,
	p_tad_information18             in varchar2,
	p_tad_information19             in varchar2,
	p_tad_information20             in varchar2,
	p_category_usage_id             in number
	)
	Return g_rec_type is
--
  l_rec	g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.activity_id                      := p_activity_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.name                             := p_name;
  l_rec.comments                         := p_comments;
  l_rec.description                      := p_description;
  l_rec.multiple_con_versions_flag       := p_multiple_con_versions_flag;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.tad_information_category         := p_tad_information_category;
  l_rec.tad_information1                 := p_tad_information1;
  l_rec.tad_information2                 := p_tad_information2;
  l_rec.tad_information3                 := p_tad_information3;
  l_rec.tad_information4                 := p_tad_information4;
  l_rec.tad_information5                 := p_tad_information5;
  l_rec.tad_information6                 := p_tad_information6;
  l_rec.tad_information7                 := p_tad_information7;
  l_rec.tad_information8                 := p_tad_information8;
  l_rec.tad_information9                 := p_tad_information9;
  l_rec.tad_information10                := p_tad_information10;
  l_rec.tad_information11                := p_tad_information11;
  l_rec.tad_information12                := p_tad_information12;
  l_rec.tad_information13                := p_tad_information13;
  l_rec.tad_information14                := p_tad_information14;
  l_rec.tad_information15                := p_tad_information15;
  l_rec.tad_information16                := p_tad_information16;
  l_rec.tad_information17                := p_tad_information17;
  l_rec.tad_information18                := p_tad_information18;
  l_rec.tad_information19                := p_tad_information19;
  l_rec.tad_information20                := p_tad_information20;
  l_rec.category_usage_id                := p_category_usage_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_defs(p_rec in out nocopy g_rec_type)
         Return g_rec_type is
--
  l_proc	  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id := g_old_rec.business_group_id;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name := g_old_rec.name;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments := g_old_rec.comments;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description := g_old_rec.description;
  End If;
  If (p_rec.multiple_con_versions_flag = hr_api.g_varchar2) then
    p_rec.multiple_con_versions_flag :=
    g_old_rec.multiple_con_versions_flag;
  End If;
  If (p_rec.tad_information_category = hr_api.g_varchar2) then
    p_rec.tad_information_category := g_old_rec.tad_information_category;
  End If;
  If (p_rec.tad_information1 = hr_api.g_varchar2) then
    p_rec.tad_information1 := g_old_rec.tad_information1;
  End If;
  If (p_rec.tad_information2 = hr_api.g_varchar2) then
    p_rec.tad_information2 := g_old_rec.tad_information2;
  End If;
  If (p_rec.tad_information3 = hr_api.g_varchar2) then
    p_rec.tad_information3 := g_old_rec.tad_information3;
  End If;
  If (p_rec.tad_information4 = hr_api.g_varchar2) then
    p_rec.tad_information4 := g_old_rec.tad_information4;
  End If;
  If (p_rec.tad_information5 = hr_api.g_varchar2) then
    p_rec.tad_information5 := g_old_rec.tad_information5;
  End If;
  If (p_rec.tad_information6 = hr_api.g_varchar2) then
    p_rec.tad_information6 := g_old_rec.tad_information6;
  End If;
  If (p_rec.tad_information7 = hr_api.g_varchar2) then
    p_rec.tad_information7 := g_old_rec.tad_information7;
  End If;
  If (p_rec.tad_information8 = hr_api.g_varchar2) then
    p_rec.tad_information8 := g_old_rec.tad_information8;
  End If;
  If (p_rec.tad_information9 = hr_api.g_varchar2) then
    p_rec.tad_information9 := g_old_rec.tad_information9;
  End If;
  If (p_rec.tad_information10 = hr_api.g_varchar2) then
    p_rec.tad_information10 := g_old_rec.tad_information10;
  End If;
  If (p_rec.tad_information11 = hr_api.g_varchar2) then
    p_rec.tad_information11 := g_old_rec.tad_information11;
  End If;
  If (p_rec.tad_information12 = hr_api.g_varchar2) then
    p_rec.tad_information12 := g_old_rec.tad_information12;
  End If;
  If (p_rec.tad_information13 = hr_api.g_varchar2) then
    p_rec.tad_information13 := g_old_rec.tad_information13;
  End If;
  If (p_rec.tad_information14 = hr_api.g_varchar2) then
    p_rec.tad_information14 := g_old_rec.tad_information14;
  End If;
  If (p_rec.tad_information15 = hr_api.g_varchar2) then
    p_rec.tad_information15 := g_old_rec.tad_information15;
  End If;
  If (p_rec.tad_information16 = hr_api.g_varchar2) then
    p_rec.tad_information16 := g_old_rec.tad_information16;
  End If;
  If (p_rec.tad_information17 = hr_api.g_varchar2) then
    p_rec.tad_information17 := g_old_rec.tad_information17;
  End If;
  If (p_rec.tad_information18 = hr_api.g_varchar2) then
    p_rec.tad_information18 := g_old_rec.tad_information18;
  End If;
  If (p_rec.tad_information19 = hr_api.g_varchar2) then
    p_rec.tad_information19 := g_old_rec.tad_information19;
  End If;
  If (p_rec.tad_information20 = hr_api.g_varchar2) then
    p_rec.tad_information20 := g_old_rec.tad_information20;
  End If;
  If (p_rec.category_usage_id = hr_api.g_number) then
    p_rec.category_usage_id := g_old_rec.category_usage_id;
  End If;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  check_unique_name( p_rec.name
                   , p_rec.business_group_id
                   , p_rec.activity_id );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in g_rec_type) is
  --
  l_proc	varchar2(72) := g_package||'update_validate';
  --
  l_name_changed   boolean
    := ota_general.value_changed( g_old_rec.name
                                , p_rec.name );
  --
  l_multiple_con_flag_changed   boolean
    := ota_general.value_changed( g_old_rec.multiple_con_versions_flag
                                , p_rec.multiple_con_versions_flag );
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  If l_name_changed  Then
    --
    check_unique_name( p_rec.name
                     , p_rec.business_group_id
                     , p_rec.activity_id );
    --
  End if;
  --
  If l_multiple_con_flag_changed  Then
    --
    check_concurrent_versions( p_rec.activity_id
                             , p_rec.multiple_con_versions_flag );
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

  check_if_tpm_exist  (p_rec.activity_id);
  check_tav_exist   ( p_rec.activity_id );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   6) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  ) is
--
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_ota_tad;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  insert_validate(p_rec);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_ota_tad;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_activity_id                  out nocopy number,
  p_business_group_id            in number,
  p_name                         in varchar2,
  p_comments                     in varchar2         default null,
  p_description                  in varchar2         default null,
  p_multiple_con_versions_flag   in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_tad_information_category     in varchar2         default null,
  p_tad_information1             in varchar2         default null,
  p_tad_information2             in varchar2         default null,
  p_tad_information3             in varchar2         default null,
  p_tad_information4             in varchar2         default null,
  p_tad_information5             in varchar2         default null,
  p_tad_information6             in varchar2         default null,
  p_tad_information7             in varchar2         default null,
  p_tad_information8             in varchar2         default null,
  p_tad_information9             in varchar2         default null,
  p_tad_information10            in varchar2         default null,
  p_tad_information11            in varchar2         default null,
  p_tad_information12            in varchar2         default null,
  p_tad_information13            in varchar2         default null,
  p_tad_information14            in varchar2         default null,
  p_tad_information15            in varchar2         default null,
  p_tad_information16            in varchar2         default null,
  p_tad_information17            in varchar2         default null,
  p_tad_information18            in varchar2         default null,
  p_tad_information19            in varchar2         default null,
  p_tad_information20            in varchar2         default null,
  p_category_usage_id            in number           default null,
  p_validate                     in boolean          default false
  ) is
--
  l_rec		g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  convert_args
  (
  null,
  p_business_group_id,
  p_name,
  p_comments,
  p_description,
  p_multiple_con_versions_flag,
  null,
  p_tad_information_category,
  p_tad_information1,
  p_tad_information2,
  p_tad_information3,
  p_tad_information4,
  p_tad_information5,
  p_tad_information6,
  p_tad_information7,
  p_tad_information8,
  p_tad_information9,
  p_tad_information10,
  p_tad_information11,
  p_tad_information12,
  p_tad_information13,
  p_tad_information14,
  p_tad_information15,
  p_tad_information16,
  p_tad_information17,
  p_tad_information18,
  p_tad_information19,
  p_tad_information20,
  p_category_usage_id
  );
  --
  -- Having converted the arguments into the ota_tad_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_activity_id := l_rec.activity_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update business process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update business process is then executed which enables any
--      logic to be processed after the update dml process.
--   8) If the p_validate argument has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  ) is
--
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_ota_tad;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  lck
	(
	p_rec.activity_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  update_validate(convert_defs(p_rec));
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_ota_tad;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_activity_id                  in number,
  p_business_group_id            in number           default hr_api.g_number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_multiple_con_versions_flag   in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_tad_information_category     in varchar2         default hr_api.g_varchar2,
  p_tad_information1             in varchar2         default hr_api.g_varchar2,
  p_tad_information2             in varchar2         default hr_api.g_varchar2,
  p_tad_information3             in varchar2         default hr_api.g_varchar2,
  p_tad_information4             in varchar2         default hr_api.g_varchar2,
  p_tad_information5             in varchar2         default hr_api.g_varchar2,
  p_tad_information6             in varchar2         default hr_api.g_varchar2,
  p_tad_information7             in varchar2         default hr_api.g_varchar2,
  p_tad_information8             in varchar2         default hr_api.g_varchar2,
  p_tad_information9             in varchar2         default hr_api.g_varchar2,
  p_tad_information10            in varchar2         default hr_api.g_varchar2,
  p_tad_information11            in varchar2         default hr_api.g_varchar2,
  p_tad_information12            in varchar2         default hr_api.g_varchar2,
  p_tad_information13            in varchar2         default hr_api.g_varchar2,
  p_tad_information14            in varchar2         default hr_api.g_varchar2,
  p_tad_information15            in varchar2         default hr_api.g_varchar2,
  p_tad_information16            in varchar2         default hr_api.g_varchar2,
  p_tad_information17            in varchar2         default hr_api.g_varchar2,
  p_tad_information18            in varchar2         default hr_api.g_varchar2,
  p_tad_information19            in varchar2         default hr_api.g_varchar2,
  p_tad_information20            in varchar2         default hr_api.g_varchar2,
  p_category_usage_id            in number           default hr_api.g_number,
  p_validate                     in boolean          default false
  ) is
--
  l_rec		g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  convert_args
  (
  p_activity_id,
  p_business_group_id,
  p_name,
  p_comments,
  p_description,
  p_multiple_con_versions_flag,
  p_object_version_number,
  p_tad_information_category,
  p_tad_information1,
  p_tad_information2,
  p_tad_information3,
  p_tad_information4,
  p_tad_information5,
  p_tad_information6,
  p_tad_information7,
  p_tad_information8,
  p_tad_information9,
  p_tad_information10,
  p_tad_information11,
  p_tad_information12,
  p_tad_information13,
  p_tad_information14,
  p_tad_information15,
  p_tad_information16,
  p_tad_information17,
  p_tad_information18,
  p_tad_information19,
  p_tad_information20,
  p_category_usage_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the delete business process
--   for the specified entity. The role of this process is to delete the
--   row from the HR schema. This process is the main backbone of the del
--   business process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process delete_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_delete business process is then executed which enables any
--      logic to be processed before the delete dml process is executed.
--   4) The delete_dml process will physical perform the delete dml for the
--      specified row.
--   5) The post_delete business process is then executed which enables any
--      logic to be processed after the delete dml process.
--   6) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the del process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	in g_rec_type,
  p_validate   in boolean default false
  ) is
--
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_ota_tad;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  lck
	(
	p_rec.activity_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_ota_tad;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the delete business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to validate and delete the specified row from the
--   HR schema. The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      explicitly coding the attribute arguments into the g_rec_type
--      datatype.
--   2) After the conversion has taken place, the corresponding record del
--      interface business process is executed.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed (or rollbacked depending on the
--   p_validate status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   The attrbute in arguments should be modified as to the business process
--   requirements.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_activity_id                        in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec		g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.activity_id:= p_activity_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ota_tad_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ota_tad_api;

/
