--------------------------------------------------------
--  DDL for Package Body PER_PER_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PER_INS" as
/* $Header: peperrhi.pkb 120.14.12010000.5 2009/08/17 12:07:47 ktithy ship $ */
-- -- ------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_per_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_person_id_i number default null;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_person_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_per_ins.g_person_id_i := p_person_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
--

-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
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
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   per_all_people_f t
    where  t.person_id       = p_rec.person_id
    and    t.effective_start_date =
             per_per_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc    varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          per_all_people_f.created_by%TYPE;
  l_creation_date       per_all_people_f.creation_date%TYPE;
  l_last_update_date    per_all_people_f.last_update_date%TYPE;
  l_last_updated_by     per_all_people_f.last_updated_by%TYPE;
  l_last_update_login   per_all_people_f.last_update_login%TYPE;
--
  cursor c1 is
    select *
    from   per_all_people_f
    where  person_id = p_rec.person_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_person per_all_people_f%rowtype;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
   (p_base_table_name => 'per_all_people_f',
    p_base_key_column => 'person_id',
    p_base_key_value  => p_rec.person_id);
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> 'INSERT') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  per_per_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_all_people_f
  --
  insert into per_all_people_f
  (   person_id,
   effective_start_date,
   effective_end_date,
   business_group_id,
   person_type_id,
   last_name,
   start_date,
   applicant_number,
   comment_id,
   current_applicant_flag,
   current_emp_or_apl_flag,
   current_employee_flag,
   date_employee_data_verified,
   date_of_birth,
   email_address,
   employee_number,
   expense_check_send_to_address,
   first_name,
   full_name,
   known_as,
   marital_status,
   middle_names,
   nationality,
   national_identifier,
   previous_last_name,
   registered_disabled_flag,
   sex,
   title,
   vendor_id,
-- work_telephone,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
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
   attribute21,
   attribute22,
   attribute23,
   attribute24,
   attribute25,
   attribute26,
   attribute27,
   attribute28,
   attribute29,
   attribute30,
   per_information_category,
   per_information1,
   per_information2,
   per_information3,
   per_information4,
   per_information5,
   per_information6,
   per_information7,
   per_information8,
   per_information9,
   per_information10,
   per_information11,
   per_information12,
   per_information13,
   per_information14,
   per_information15,
   per_information16,
   per_information17,
   per_information18,
   per_information19,
   per_information20,
   object_version_number,
        suffix,
        DATE_OF_DEATH,
        BACKGROUND_CHECK_STATUS         ,
        BACKGROUND_DATE_CHECK           ,
        BLOOD_TYPE                      ,
        CORRESPONDENCE_LANGUAGE         ,
        FAST_PATH_EMPLOYEE              ,
        FTE_CAPACITY                    ,
        HOLD_APPLICANT_DATE_UNTIL       ,
        HONORS                          ,
        INTERNAL_LOCATION               ,
        LAST_MEDICAL_TEST_BY            ,
        LAST_MEDICAL_TEST_DATE          ,
        MAILSTOP                        ,
        OFFICE_NUMBER                   ,
        ON_MILITARY_SERVICE             ,
        ORDER_NAME                      ,
        PRE_NAME_ADJUNCT                ,
        PROJECTED_START_DATE            ,
        REHIRE_AUTHORIZOR               ,
        REHIRE_RECOMMENDATION           ,
        RESUME_EXISTS                   ,
        RESUME_LAST_UPDATED             ,
        SECOND_PASSPORT_EXISTS          ,
        STUDENT_STATUS                  ,
        WORK_SCHEDULE                   ,
        PER_INFORMATION21               ,
        PER_INFORMATION22               ,
        PER_INFORMATION23               ,
        PER_INFORMATION24               ,
        PER_INFORMATION25               ,
        PER_INFORMATION26               ,
        PER_INFORMATION27               ,
        PER_INFORMATION28               ,
        PER_INFORMATION29               ,
        PER_INFORMATION30               ,
        REHIRE_REASON                   ,
        benefit_group_id                ,
        receipt_of_death_cert_date      ,
        coord_ben_med_pln_no            ,
        coord_ben_no_cvg_flag           ,
        COORD_BEN_MED_EXT_ER,
        COORD_BEN_MED_PL_NAME,
        COORD_BEN_MED_INSR_CRR_NAME,
        COORD_BEN_MED_INSR_CRR_IDENT,
        COORD_BEN_MED_CVG_STRT_DT,
        COORD_BEN_MED_CVG_END_DT,
        uses_tobacco_flag               ,
        dpdnt_adoption_date             ,
        dpdnt_vlntry_svce_flag          ,
        original_date_of_hire           ,
      town_of_birth                ,
        region_of_birth              ,
      country_of_birth             ,
        global_person_id             ,
        party_id             ,
        npw_number,
        current_npw_flag,
        global_name,
        local_name,
        created_by,
      creation_date,
      last_update_date,
      last_updated_by,
      last_update_login
  )
  Values
  (   p_rec.person_id,
   p_rec.effective_start_date,
   p_rec.effective_end_date,
   p_rec.business_group_id,
   p_rec.person_type_id,
   p_rec.last_name,
   p_rec.start_date,
   p_rec.applicant_number,
   p_rec.comment_id,
   p_rec.current_applicant_flag,
   p_rec.current_emp_or_apl_flag,
   p_rec.current_employee_flag,
   p_rec.date_employee_data_verified,
   p_rec.date_of_birth,
   p_rec.email_address,
   p_rec.employee_number,
   p_rec.expense_check_send_to_address,
   p_rec.first_name,
   p_rec.full_name,
   p_rec.known_as,
   p_rec.marital_status,
   p_rec.middle_names,
   p_rec.nationality,
   p_rec.national_identifier,
   p_rec.previous_last_name,
   p_rec.registered_disabled_flag,
   p_rec.sex,
   p_rec.title,
   p_rec.vendor_id,
-- p_rec.work_telephone,
   p_rec.request_id,
   p_rec.program_application_id,
   p_rec.program_id,
   p_rec.program_update_date,
   p_rec.attribute_category,
   p_rec.attribute1,
   p_rec.attribute2,
   p_rec.attribute3,
   p_rec.attribute4,
   p_rec.attribute5,
   p_rec.attribute6,
   p_rec.attribute7,
   p_rec.attribute8,
   p_rec.attribute9,
   p_rec.attribute10,
   p_rec.attribute11,
   p_rec.attribute12,
   p_rec.attribute13,
   p_rec.attribute14,
   p_rec.attribute15,
   p_rec.attribute16,
   p_rec.attribute17,
   p_rec.attribute18,
   p_rec.attribute19,
   p_rec.attribute20,
   p_rec.attribute21,
   p_rec.attribute22,
   p_rec.attribute23,
   p_rec.attribute24,
   p_rec.attribute25,
   p_rec.attribute26,
   p_rec.attribute27,
   p_rec.attribute28,
   p_rec.attribute29,
   p_rec.attribute30,
   p_rec.per_information_category,
   p_rec.per_information1,
   p_rec.per_information2,
   p_rec.per_information3,
   p_rec.per_information4,
   p_rec.per_information5,
   p_rec.per_information6,
   p_rec.per_information7,
   p_rec.per_information8,
   p_rec.per_information9,
   p_rec.per_information10,
   p_rec.per_information11,
   p_rec.per_information12,
   p_rec.per_information13,
   p_rec.per_information14,
   p_rec.per_information15,
   p_rec.per_information16,
   p_rec.per_information17,
   p_rec.per_information18,
   p_rec.per_information19,
   p_rec.per_information20,
   p_rec.object_version_number,
        p_rec.suffix,
        p_rec.DATE_OF_DEATH                     ,
        p_rec.BACKGROUND_CHECK_STATUS           ,
        p_rec.BACKGROUND_DATE_CHECK             ,
        p_rec.BLOOD_TYPE                        ,
        p_rec.CORRESPONDENCE_LANGUAGE           ,
        p_rec.FAST_PATH_EMPLOYEE                ,
        p_rec.FTE_CAPACITY                      ,
        p_rec.HOLD_APPLICANT_DATE_UNTIL         ,
        p_rec.HONORS                            ,
        p_rec.INTERNAL_LOCATION                 ,
        p_rec.LAST_MEDICAL_TEST_BY              ,
        p_rec.LAST_MEDICAL_TEST_DATE            ,
        p_rec.MAILSTOP                          ,
        p_rec.OFFICE_NUMBER                     ,
        p_rec.ON_MILITARY_SERVICE               ,
        p_rec.ORDER_NAME                        ,
        p_rec.PRE_NAME_ADJUNCT                  ,
        p_rec.PROJECTED_START_DATE              ,
        p_rec.REHIRE_AUTHORIZOR                 ,
        p_rec.REHIRE_RECOMMENDATION             ,
        p_rec.RESUME_EXISTS                     ,
        p_rec.RESUME_LAST_UPDATED               ,
        p_rec.SECOND_PASSPORT_EXISTS            ,
        p_rec.STUDENT_STATUS                    ,
        p_rec.WORK_SCHEDULE                     ,
        p_rec.PER_INFORMATION21                 ,
        p_rec.PER_INFORMATION22                 ,
        p_rec.PER_INFORMATION23                 ,
        p_rec.PER_INFORMATION24                 ,
        p_rec.PER_INFORMATION25                 ,
        p_rec.PER_INFORMATION26                 ,
        p_rec.PER_INFORMATION27                 ,
        p_rec.PER_INFORMATION28                 ,
        p_rec.PER_INFORMATION29                 ,
        p_rec.PER_INFORMATION30                 ,
        p_rec.REHIRE_REASON                     ,
        p_rec.BENEFIT_GROUP_ID                  ,
        p_rec.RECEIPT_OF_DEATH_CERT_DATE        ,
        p_rec.COORD_BEN_MED_PLN_NO              ,
        p_rec.COORD_BEN_NO_CVG_FLAG             ,
        p_rec.COORD_BEN_MED_EXT_ER,
        p_rec.COORD_BEN_MED_PL_NAME,
        p_rec.COORD_BEN_MED_INSR_CRR_NAME,
        p_rec.COORD_BEN_MED_INSR_CRR_IDENT,
        p_rec.COORD_BEN_MED_CVG_STRT_DT,
        p_rec.COORD_BEN_MED_CVG_END_DT ,
        p_rec.USES_TOBACCO_FLAG                 ,
        p_rec.DPDNT_ADOPTION_DATE               ,
        p_rec.DPDNT_VLNTRY_SVCE_FLAG            ,
        p_rec.ORIGINAL_DATE_OF_HIRE             ,
      p_rec.town_of_birth                           ,
      p_rec.region_of_birth                         ,
        p_rec.country_of_birth                        ,
        p_rec.global_person_id                        ,
        p_rec.party_id                        ,
        p_rec.npw_number,
        p_rec.current_npw_flag,
        p_rec.global_name,
        p_rec.local_name,
      l_created_by,
      l_creation_date,
      l_last_update_date,
      l_last_updated_by,
      l_last_update_login
  );
  --
  hr_utility.set_location('Select last created record',10);
  --
  -- Now we need to get the personwho was created or updated and pass that
  -- info to TCA for synchronization across business groups or possible
  -- creation through TCA.
  --
  open c1;
    --
    fetch c1 into l_person;
    --
  close c1;
  --
  if p_datetrack_mode = 'INSERT' then
    --
    null;
/* commented out as part of the TCA unmerge enhancement
   this is handled in  per_person_type_usage_internal.maintain_person_type_usag
   --
    per_hrtca_merge.create_tca_person(p_rec => l_person);
    --
    hr_utility.set_location('Updating party id',10);
    --
    -- Now assign the resulting party id back to the record.
    --
    -- WWBUG 2450297.
    --
    update per_all_people_f
      set party_id = l_person.party_id
      where person_id = p_rec.person_id;
    --
  End of comment for tca unmerge
*/
  else
    --
    per_hrtca_merge.update_tca_person(p_rec => l_person);
    --
    hr_utility.set_location('Updating party id',10);
    --
  end if;
  --
  per_per_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_per_shd.g_api_dml := false;   -- Unset the api dml status
    per_per_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_per_shd.g_api_dml := false;   -- Unset the api dml status
    per_per_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_per_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec         => p_rec,
      p_effective_date  => p_effective_date,
      p_datetrack_mode  => p_datetrack_mode,
            p_validation_start_date => p_validation_start_date,
      p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
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
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
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
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
   (p_rec         in out nocopy per_per_shd.g_rec_type,
    p_effective_date    in date,
    p_datetrack_mode    in varchar2,
    p_validation_start_date   in date,
    p_validation_end_date     in date) is
--
  l_proc varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
  Cursor C_Sel1 is select per_people_s.nextval from sys.dual;
--
 Cursor C_Sel2 is
    Select null
      from per_all_people_f
     where person_id =
             per_per_ins.g_person_id_i;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  If (per_per_ins.g_person_id_i is not null)
  then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
      Close C_Sel2;
      --
      -- The primary key values are already in use.
      --
      fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
      fnd_message.set_token('TABLE_NAME','PER_ALL_PEOPLE_F');
      fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
      p_rec.person_id :=
      per_per_ins.g_person_id_i;
      per_per_ins.g_person_id_i := null;
  Else
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.person_id;
    Close C_Sel1;
  End If;
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null) then
    hr_utility.set_location(l_proc,7);
    hr_comm_api.ins(p_comment_id        => p_rec.comment_id,
                    p_source_table_name => 'per_all_people_f',
                    p_comment_text      => p_rec.comments);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
    --
End pre_insert;
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
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
   (p_rec          in per_per_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date,
         p_name_combination_warning in  boolean,
         p_dob_null_warning         in  boolean,
         p_orig_hire_warning        in  boolean) is
--
  l_proc varchar2(72) := g_package||'post_insert';
  --
  cursor l_per_cur is
    select *
    from  per_all_people_f
    where person_id            = p_rec.person_id
    and   effective_start_date = p_rec.effective_start_date
    and   effective_end_date   = p_rec.effective_end_date;
  l_per_rec per_all_people_f%rowtype;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_dt_trgr_handle.person
    (p_rowid                      => null
    ,p_business_group_id          => p_rec.business_group_id
    ,p_person_id                  => p_rec.person_id
    ,p_effective_start_date       => p_rec.effective_start_date
    ,p_effective_end_date         => p_rec.effective_end_date
    ,p_date_of_birth              => p_rec.date_of_birth
    ,p_date_of_death              => p_rec.date_of_death
    ,p_marital_status             => p_rec.marital_status
    ,p_on_military_service        => p_rec.on_military_service
    ,p_registered_disabled_flag   => p_rec.registered_disabled_flag
    ,p_sex                        => p_rec.sex
    ,p_student_status             => p_rec.student_status
    ,p_coord_ben_med_pln_no       => p_rec.coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag      => p_rec.coord_ben_no_cvg_flag
    ,p_uses_tobacco_flag          => p_rec.uses_tobacco_flag
    ,p_benefit_group_id           => p_rec.benefit_group_id
    ,p_per_information10          => p_rec.per_information10
    ,p_original_date_of_hire      => p_rec.original_date_of_hire
    ,p_dpdnt_vlntry_svce_flag     => p_rec.dpdnt_vlntry_svce_flag
    ,p_receipt_of_death_cert_date => p_rec.receipt_of_death_cert_date
    ,p_attribute1                 => p_rec.attribute1
    ,p_attribute2                 => p_rec.attribute2
    ,p_attribute3                 => p_rec.attribute3
    ,p_attribute4                 => p_rec.attribute4
    ,p_attribute5                 => p_rec.attribute5
    ,p_attribute6                 => p_rec.attribute6
    ,p_attribute7                 => p_rec.attribute7
    ,p_attribute8                 => p_rec.attribute8
    ,p_attribute9                 => p_rec.attribute9
    ,p_attribute10                => p_rec.attribute10
    ,p_attribute11                => p_rec.attribute11
    ,p_attribute12                => p_rec.attribute12
    ,p_attribute13                => p_rec.attribute13
    ,p_attribute14                => p_rec.attribute14
    ,p_attribute15                => p_rec.attribute15
    ,p_attribute16                => p_rec.attribute16
    ,p_attribute17                => p_rec.attribute17
    ,p_attribute18                => p_rec.attribute18
    ,p_attribute19                => p_rec.attribute19
    ,p_attribute20                => p_rec.attribute20
    ,p_attribute21                => p_rec.attribute21
    ,p_attribute22                => p_rec.attribute22
    ,p_attribute23                => p_rec.attribute23
    ,p_attribute24                => p_rec.attribute24
    ,p_attribute25                => p_rec.attribute25
    ,p_attribute26                => p_rec.attribute26
    ,p_attribute27                => p_rec.attribute27
    ,p_attribute28                => p_rec.attribute28
    ,p_attribute29                => p_rec.attribute29
    ,p_attribute30                => p_rec.attribute30
);
  -- Start of API User Hook for post_insert.
  begin
    per_per_rki.after_insert
      (p_effective_date               => p_effective_date
      ,p_name_combination_warning     => p_name_combination_warning
      ,p_dob_null_warning             => p_dob_null_warning
      ,p_orig_hire_warning            => p_orig_hire_warning
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      ,p_person_id                    => p_rec.person_id
      ,p_effective_start_date         => p_rec.effective_start_date
      ,p_effective_end_date           => p_rec.effective_end_date
      ,p_business_group_id            => p_rec.business_group_id
      ,p_person_type_id               => p_rec.person_type_id
      ,p_last_name                    => p_rec.last_name
      ,p_start_date                   => p_rec.start_date
      ,p_applicant_number             => p_rec.applicant_number
      ,p_comment_id                   => p_rec.comment_id
      ,p_current_applicant_flag       => p_rec.current_applicant_flag
      ,p_current_emp_or_apl_flag      => p_rec.current_emp_or_apl_flag
      ,p_current_employee_flag        => p_rec.current_employee_flag
      ,p_date_employee_data_verified  => p_rec.date_employee_data_verified
      ,p_date_of_birth                => p_rec.date_of_birth
      ,p_email_address                => p_rec.email_address
      ,p_employee_number              => p_rec.employee_number
      ,p_expense_check_send_to_addres => p_rec.expense_check_send_to_address
      ,p_first_name                   => p_rec.first_name
      ,p_full_name                    => p_rec.full_name
      ,p_known_as                     => p_rec.known_as
      ,p_marital_status               => p_rec.marital_status
      ,p_middle_names                 => p_rec.middle_names
      ,p_nationality                  => p_rec.nationality
      ,p_national_identifier          => p_rec.national_identifier
      ,p_previous_last_name           => p_rec.previous_last_name
      ,p_registered_disabled_flag     => p_rec.registered_disabled_flag
      ,p_sex                          => p_rec.sex
      ,p_title                        => p_rec.title
      ,p_vendor_id                    => p_rec.vendor_id
      ,p_work_telephone               => p_rec.work_telephone
      ,p_request_id                   => p_rec.request_id
      ,p_program_application_id       => p_rec.program_application_id
      ,p_program_id                   => p_rec.program_id
      ,p_program_update_date          => p_rec.program_update_date
      ,p_attribute_category           => p_rec.attribute_category
      ,p_attribute1                   => p_rec.attribute1
      ,p_attribute2                   => p_rec.attribute2
      ,p_attribute3                   => p_rec.attribute3
      ,p_attribute4                   => p_rec.attribute4
      ,p_attribute5                   => p_rec.attribute5
      ,p_attribute6                   => p_rec.attribute6
      ,p_attribute7                   => p_rec.attribute7
      ,p_attribute8                   => p_rec.attribute8
      ,p_attribute9                   => p_rec.attribute9
      ,p_attribute10                  => p_rec.attribute10
      ,p_attribute11                  => p_rec.attribute11
      ,p_attribute12                  => p_rec.attribute12
      ,p_attribute13                  => p_rec.attribute13
      ,p_attribute14                  => p_rec.attribute14
      ,p_attribute15                  => p_rec.attribute15
      ,p_attribute16                  => p_rec.attribute16
      ,p_attribute17                  => p_rec.attribute17
      ,p_attribute18                  => p_rec.attribute18
      ,p_attribute19                  => p_rec.attribute19
      ,p_attribute20                  => p_rec.attribute20
      ,p_attribute21                  => p_rec.attribute21
      ,p_attribute22                  => p_rec.attribute22
      ,p_attribute23                  => p_rec.attribute23
      ,p_attribute24                  => p_rec.attribute24
      ,p_attribute25                  => p_rec.attribute25
      ,p_attribute26                  => p_rec.attribute26
      ,p_attribute27                  => p_rec.attribute27
      ,p_attribute28                  => p_rec.attribute28
      ,p_attribute29                  => p_rec.attribute29
      ,p_attribute30                  => p_rec.attribute30
      ,p_per_information_category     => p_rec.per_information_category
      ,p_per_information1             => p_rec.per_information1
      ,p_per_information2             => p_rec.per_information2
      ,p_per_information3             => p_rec.per_information3
      ,p_per_information4             => p_rec.per_information4
      ,p_per_information5             => p_rec.per_information5
      ,p_per_information6             => p_rec.per_information6
      ,p_per_information7             => p_rec.per_information7
      ,p_per_information8             => p_rec.per_information8
      ,p_per_information9             => p_rec.per_information9
      ,p_per_information10            => p_rec.per_information10
      ,p_per_information11            => p_rec.per_information11
      ,p_per_information12            => p_rec.per_information12
      ,p_per_information13            => p_rec.per_information13
      ,p_per_information14            => p_rec.per_information14
      ,p_per_information15            => p_rec.per_information15
      ,p_per_information16            => p_rec.per_information16
      ,p_per_information17            => p_rec.per_information17
      ,p_per_information18            => p_rec.per_information18
      ,p_per_information19            => p_rec.per_information19
      ,p_per_information20            => p_rec.per_information20
      ,p_suffix                       => p_rec.suffix
      ,p_DATE_OF_DEATH                => p_rec.DATE_OF_DEATH
      ,p_BACKGROUND_CHECK_STATUS      => p_rec.BACKGROUND_CHECK_STATUS
      ,p_BACKGROUND_DATE_CHECK        => p_rec.BACKGROUND_DATE_CHECK
      ,p_BLOOD_TYPE                   => p_rec.BLOOD_TYPE
      ,p_CORRESPONDENCE_LANGUAGE      => p_rec.CORRESPONDENCE_LANGUAGE
      ,p_FAST_PATH_EMPLOYEE           => p_rec.FAST_PATH_EMPLOYEE
      ,p_FTE_CAPACITY                 => p_rec.FTE_CAPACITY
      ,p_HOLD_APPLICANT_DATE_UNTIL    => p_rec.HOLD_APPLICANT_DATE_UNTIL
      ,p_HONORS                       => p_rec.HONORS
      ,p_INTERNAL_LOCATION            => p_rec.INTERNAL_LOCATION
      ,p_LAST_MEDICAL_TEST_BY         => p_rec.LAST_MEDICAL_TEST_BY
      ,p_LAST_MEDICAL_TEST_DATE       => p_rec.LAST_MEDICAL_TEST_DATE
      ,p_MAILSTOP                     => p_rec.MAILSTOP
      ,p_OFFICE_NUMBER                => p_rec.OFFICE_NUMBER
      ,p_ON_MILITARY_SERVICE          => p_rec.ON_MILITARY_SERVICE
      ,p_ORDER_NAME                   => p_rec.ORDER_NAME
      ,p_PRE_NAME_ADJUNCT             => p_rec.PRE_NAME_ADJUNCT
      ,p_PROJECTED_START_DATE         => p_rec.PROJECTED_START_DATE
      ,p_REHIRE_AUTHORIZOR            => p_rec.REHIRE_AUTHORIZOR
      ,p_REHIRE_RECOMMENDATION        => p_rec.REHIRE_RECOMMENDATION
      ,p_RESUME_EXISTS                => p_rec.RESUME_EXISTS
      ,p_RESUME_LAST_UPDATED          => p_rec.RESUME_LAST_UPDATED
      ,p_SECOND_PASSPORT_EXISTS       => p_rec.SECOND_PASSPORT_EXISTS
      ,p_STUDENT_STATUS               => p_rec.STUDENT_STATUS
      ,p_WORK_SCHEDULE                => p_rec.WORK_SCHEDULE
      ,p_PER_INFORMATION21            => p_rec.PER_INFORMATION21
      ,p_PER_INFORMATION22            => p_rec.PER_INFORMATION22
      ,p_PER_INFORMATION23            => p_rec.PER_INFORMATION23
      ,p_PER_INFORMATION24            => p_rec.PER_INFORMATION24
      ,p_PER_INFORMATION25            => p_rec.PER_INFORMATION25
      ,p_PER_INFORMATION26            => p_rec.PER_INFORMATION26
      ,p_PER_INFORMATION27            => p_rec.PER_INFORMATION27
      ,p_PER_INFORMATION28            => p_rec.PER_INFORMATION28
      ,p_PER_INFORMATION29            => p_rec.PER_INFORMATION29
      ,p_PER_INFORMATION30            => p_rec.PER_INFORMATION30
      ,p_REHIRE_REASON                => p_rec.REHIRE_REASON
      ,p_BENEFIT_GROUP_ID               => p_rec.BENEFIT_GROUP_ID
      ,p_RECEIPT_OF_DEATH_CERT_DATE     => p_rec.RECEIPT_OF_DEATH_CERT_DATE
      ,p_COORD_BEN_MED_PLN_NO           => p_rec.COORD_BEN_MED_PLN_NO
      ,p_COORD_BEN_NO_CVG_FLAG          => p_rec.COORD_BEN_NO_CVG_FLAG
      ,p_coord_ben_med_ext_er         => p_rec.coord_ben_med_ext_er
      ,p_coord_ben_med_pl_name        => p_rec.coord_ben_med_pl_name
      ,p_coord_ben_med_insr_crr_name  => p_rec.coord_ben_med_insr_crr_name
      ,p_coord_ben_med_insr_crr_ident => p_rec.coord_ben_med_insr_crr_ident
      ,p_coord_ben_med_cvg_strt_dt    => p_rec.coord_ben_med_cvg_strt_dt
      ,p_coord_ben_med_cvg_end_dt     => p_rec.coord_ben_med_cvg_end_dt
      ,p_USES_TOBACCO_FLAG              => p_rec.USES_TOBACCO_FLAG
      ,p_DPDNT_ADOPTION_DATE            => p_rec.DPDNT_ADOPTION_DATE
      ,p_DPDNT_VLNTRY_SVCE_FLAG         => p_rec.DPDNT_VLNTRY_SVCE_FLAG
      ,p_ORIGINAL_DATE_OF_HIRE          => p_rec.ORIGINAL_DATE_OF_HIRE
    ,p_town_of_birth                => p_rec.town_of_birth
    ,p_region_of_birth              => p_rec.region_of_birth
    ,p_country_of_birth             => p_rec.country_of_birth
    ,p_global_person_id             => p_rec.global_person_id
    ,p_party_id                     => p_rec.party_id
      ,p_npw_number                   => p_rec.npw_number
      ,p_current_npw_flag             => p_rec.current_npw_flag
      ,p_global_name                  => p_rec.global_name
      ,p_local_name                   => p_rec.local_name
      ,p_object_version_number        => p_rec.object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'per_all_people_f'
        ,p_hook_type   => 'AI'
        );
  end;
  -- End of API User Hook for post_insert.
  --
  --
  --Start HR/WF Synchronization
  --
    open l_per_cur;
    fetch l_per_cur into l_per_rec;
    close l_per_cur;
    --
    per_hrwf_synch.per_per_wf(
                   p_rec       => l_per_rec,
                   p_action    => 'INSERT');
  --
  -- End HR/WF Synchronization
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--   be manipulated.
--
-- Pre Conditions:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Arguments:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
   (p_effective_date  in  date,
    p_datetrack_mode  in  varchar2,
    p_rec          in  per_per_shd.g_rec_type,
    p_validation_start_date out nocopy date,
    p_validation_end_date   out nocopy date) is
--
  l_proc      varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date   date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
   (p_effective_date    => p_effective_date,
    p_datetrack_mode    => p_datetrack_mode,
    p_base_table_name      => 'per_people_f',
    p_base_key_column      => 'person_id',
    p_base_key_value       => p_rec.person_id,
         p_enforce_foreign_locking => true,
    p_validation_start_date   => l_validation_start_date,
    p_validation_end_date     => l_validation_end_date);
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec                       in out nocopy per_per_shd.g_rec_type,
  p_effective_date         in     date,
  p_validate              in     boolean default false,
  p_name_combination_warning  out nocopy boolean,
  p_dob_null_warning          out nocopy boolean,
  p_orig_hire_warning         out nocopy boolean
  ) is
--
  l_proc       varchar2(72) := g_package||'ins';
  l_datetrack_mode      varchar2(30) := 'INSERT';
  l_validation_start_date  date;
  l_validation_end_date    date;
  l_name_combination_warning    boolean;
  l_dob_null_warning            boolean;
  l_orig_hire_warning           boolean;
  --
  cursor c1 is
    select *
    from   per_all_people_f
    where  party_id = p_rec.party_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_c1 c1%rowtype;
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  -- For HR/TCA Merge we have to deafult certain parameters for cases where
  -- a duplicate party exists.
  --
  -- WWBUG 2059244.
  --
  if fnd_profile.value('HR_PROPAGATE_DATA_CHANGES') = 'Y' then
    --
    open c1;
      --
      fetch c1 into l_c1;
      if c1%found then
        --
        if p_rec.date_of_birth is null then
          p_rec.date_of_birth := to_date(l_c1.date_of_birth,'DD/MM/RRRR');
        end if;
        if p_rec.first_name is null then
          p_rec.first_name := l_c1.first_name;
        end if;
        if p_rec.known_as is null then
          p_rec.known_as := l_c1.known_as;
        end if;
        if p_rec.marital_status is null then
          p_rec.marital_status := l_c1.marital_status;
        end if;
        if p_rec.middle_names is null then
          p_rec.middle_names := l_c1.middle_names;
        end if;
        if p_rec.nationality is null then
          p_rec.nationality := l_c1.nationality;
        end if;
        if p_rec.sex is null then
          p_rec.sex := l_c1.sex;
        end if;
        if p_rec.title is null then
          p_rec.title := l_c1.title;
        end if;
        if p_rec.blood_type is null then
          p_rec.blood_type := l_c1.blood_type;
        end if;
        if p_rec.correspondence_language is null then
          p_rec.correspondence_language := l_c1.correspondence_language;
        end if;
        if p_rec.honors is null then
          p_rec.honors := l_c1.honors;
        end if;
        if p_rec.pre_name_adjunct is null then
          p_rec.pre_name_adjunct := l_c1.pre_name_adjunct;
        end if;
        if p_rec.rehire_authorizor is null then
          p_rec.rehire_authorizor := l_c1.rehire_authorizor;
        end if;
        if p_rec.rehire_recommendation is null then
          p_rec.rehire_recommendation := l_c1.rehire_recommendation;
        end if;
        if p_rec.resume_exists is null then
          p_rec.resume_exists := l_c1.resume_exists;
        end if;
        if p_rec.resume_last_updated is null then
          p_rec.resume_last_updated := to_date(l_c1.resume_last_updated,'DD/MM/RRRR');
        end if;
        if p_rec.second_passport_exists is null then
          p_rec.second_passport_exists := l_c1.second_passport_exists;
        end if;
        if p_rec.student_status is null then
          p_rec.student_status := l_c1.student_status;
        end if;
        if p_rec.suffix is null then
          p_rec.suffix := l_c1.suffix;
        end if;
        if p_rec.date_of_death is null then
          p_rec.date_of_death :=to_date(l_c1.date_of_death,'DD/MM/RRRR');
        end if;
        if p_rec.uses_tobacco_flag is null then
          p_rec.uses_tobacco_flag := l_c1.uses_tobacco_flag;
        end if;
        if p_rec.town_of_birth is null then
          p_rec.town_of_birth := l_c1.town_of_birth;
        end if;
        if p_rec.region_of_birth is null then
          p_rec.region_of_birth := l_c1.region_of_birth;
        end if;
        if p_rec.country_of_birth is null then
          p_rec.country_of_birth := l_c1.country_of_birth;
        end if;
        if p_rec.fast_path_employee is null then
          p_rec.fast_path_employee := l_c1.fast_path_employee;
        end if;
        if p_rec.email_address is null then
          p_rec.email_address := l_c1.email_address;
        end if;
        if p_rec.fte_capacity is null then
          p_rec.fte_capacity := l_c1.fte_capacity;
        end if;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  -- End of WWBUG 2059244.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_per_per;
  End If;
  --
  -- Call the lock operation
  --
  ins_lck
   (p_effective_date  => p_effective_date,
    p_datetrack_mode  => l_datetrack_mode,
    p_rec          => p_rec,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting insert validate operations
  --
  per_per_bus.insert_validate
   (p_rec             => p_rec,
    p_effective_date     => p_effective_date,
    p_datetrack_mode     => l_datetrack_mode,
    p_validation_start_date    => l_validation_start_date,
    p_validation_end_date      => l_validation_end_date,
         p_name_combination_warning => l_name_combination_warning,
         p_dob_null_warning         => l_dob_null_warning,
         p_orig_hire_warning        => l_orig_hire_warning);
  --
  hr_multi_message.end_validation_set;
  -- Call the supporting pre-insert operation
  --
  pre_insert
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => l_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => l_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-insert operation
  --
  post_insert
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => l_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date,
         p_name_combination_warning
                                 => l_name_combination_warning,
         p_dob_null_warning      => l_dob_null_warning,
         p_orig_hire_warning     => l_orig_hire_warning);
  --
  -- If we are validating then raise the Validate_Enabled exception
  hr_multi_message.end_validation_set;
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  -- Set the out arguments
  --
  p_name_combination_warning := l_name_combination_warning;
          p_dob_null_warning := l_dob_null_warning;
         p_orig_hire_warning := l_orig_hire_warning;
  --
if l_orig_hire_warning = FALSE then
  hr_utility.set_location(l_proc,997);
elsif l_orig_hire_warning = TRUE then
  hr_utility.set_location(l_proc,998);
else
  hr_utility.set_location(l_proc,999);
end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_per_per;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_person_id                    out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_person_type_id               in number,
  p_last_name                    in varchar2,
  p_start_date                   in date,
  p_applicant_number             in out nocopy varchar2,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default null,
  p_current_applicant_flag       out nocopy varchar2,
  p_current_emp_or_apl_flag      out nocopy varchar2,
  p_current_employee_flag        out nocopy varchar2,
  p_date_employee_data_verified  in date             default null,
  p_date_of_birth                in date             default null,
  p_email_address                in varchar2         default null,
  p_employee_number              in out nocopy varchar2,
  p_expense_check_send_to_addres in varchar2         default null,
  p_first_name                   in varchar2         default null,
  p_full_name                    out nocopy varchar2,
  p_known_as                     in varchar2         default null,
  p_marital_status               in varchar2         default null,
  p_middle_names                 in varchar2         default null,
  p_nationality                  in varchar2         default null,
  p_national_identifier          in varchar2         default null,
  p_previous_last_name           in varchar2         default null,
  p_registered_disabled_flag     in varchar2         default null,
  p_sex                          in varchar2         default null,
  p_title                        in varchar2         default null,
  p_vendor_id                    in number           default null,
  p_work_telephone               in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_attribute21                  in varchar2         default null,
  p_attribute22                  in varchar2         default null,
  p_attribute23                  in varchar2         default null,
  p_attribute24                  in varchar2         default null,
  p_attribute25                  in varchar2         default null,
  p_attribute26                  in varchar2         default null,
  p_attribute27                  in varchar2         default null,
  p_attribute28                  in varchar2         default null,
  p_attribute29                  in varchar2         default null,
  p_attribute30                  in varchar2         default null,
  p_per_information_category     in varchar2         default null,
  p_per_information1             in varchar2         default null,
  p_per_information2             in varchar2         default null,
  p_per_information3             in varchar2         default null,
  p_per_information4             in varchar2         default null,
  p_per_information5             in varchar2         default null,
  p_per_information6             in varchar2         default null,
  p_per_information7             in varchar2         default null,
  p_per_information8             in varchar2         default null,
  p_per_information9             in varchar2         default null,
  p_per_information10            in varchar2         default null,
  p_per_information11            in varchar2         default null,
  p_per_information12            in varchar2         default null,
  p_per_information13            in varchar2         default null,
  p_per_information14            in varchar2         default null,
  p_per_information15            in varchar2         default null,
  p_per_information16            in varchar2         default null,
  p_per_information17            in varchar2         default null,
  p_per_information18            in varchar2         default null,
  p_per_information19            in varchar2         default null,
  p_per_information20            in varchar2         default null,
  p_suffix                       in varchar2         default null,
  p_DATE_OF_DEATH                in date             default null,
  p_BACKGROUND_CHECK_STATUS      in varchar2         default null,
  p_BACKGROUND_DATE_CHECK        in date             default null,
  p_BLOOD_TYPE                   in varchar2         default null,
  p_CORRESPONDENCE_LANGUAGE      in varchar2         default null,
  p_FAST_PATH_EMPLOYEE           in varchar2         default null,
  p_FTE_CAPACITY                 in number           default null,
  p_HOLD_APPLICANT_DATE_UNTIL    in date             default null,
  p_HONORS                       in varchar2         default null,
  p_INTERNAL_LOCATION            in varchar2         default null,
  p_LAST_MEDICAL_TEST_BY         in varchar2         default null,
  p_LAST_MEDICAL_TEST_DATE       in date             default null,
  p_MAILSTOP                     in varchar2         default null,
  p_OFFICE_NUMBER                in varchar2         default null,
  p_ON_MILITARY_SERVICE          in varchar2         default null,
  p_ORDER_NAME                   in varchar2         default null,
  p_PRE_NAME_ADJUNCT             in varchar2         default null,
  p_PROJECTED_START_DATE         in date             default null,
  p_REHIRE_AUTHORIZOR            in varchar2         default null,
  p_REHIRE_RECOMMENDATION        in varchar2         default null,
  p_RESUME_EXISTS                in varchar2         default null,
  p_RESUME_LAST_UPDATED          in date             default null,
  p_SECOND_PASSPORT_EXISTS       in varchar2         default null,
  p_STUDENT_STATUS               in varchar2         default null,
  p_WORK_SCHEDULE                in varchar2         default null,
  p_PER_INFORMATION21            in varchar2         default null,
  p_PER_INFORMATION22            in varchar2         default null,
  p_PER_INFORMATION23            in varchar2         default null,
  p_PER_INFORMATION24            in varchar2         default null,
  p_PER_INFORMATION25            in varchar2         default null,
  p_PER_INFORMATION26            in varchar2         default null,
  p_PER_INFORMATION27            in varchar2         default null,
  p_PER_INFORMATION28            in varchar2         default null,
  p_PER_INFORMATION29            in varchar2         default null,
  p_PER_INFORMATION30            in varchar2         default null,
  p_REHIRE_REASON                in varchar2         default null,
  p_benefit_group_id             in number           default null,
  p_receipt_of_death_cert_date   in date             default null,
  p_coord_ben_med_pln_no         in varchar2         default null,
  p_coord_ben_no_cvg_flag        in varchar2         default 'N',
  p_coord_ben_med_ext_er         in varchar2         default null,
  p_coord_ben_med_pl_name        in varchar2         default null,
  p_coord_ben_med_insr_crr_name  in varchar2         default null,
  p_coord_ben_med_insr_crr_ident in varchar2         default null,
  p_coord_ben_med_cvg_strt_dt    in date             default null,
  p_coord_ben_med_cvg_end_dt     in date             default null,
  p_uses_tobacco_flag            in varchar2         default null,
  p_dpdnt_adoption_date          in date             default null,
  p_dpdnt_vlntry_svce_flag       in varchar2         default 'N',
  p_original_date_of_hire        in date             default null,
  p_town_of_birth                in varchar2         default null,
  p_region_of_birth              in varchar2         default null,
  p_country_of_birth             in varchar2         default null,
  p_global_person_id             in varchar2         default null,
  p_party_id                     in number           default null,
  p_npw_number                   in out nocopy varchar2,
  p_current_npw_flag             in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date,
  p_validate                     in boolean  default false,
  p_name_combination_warning     out nocopy boolean,
  p_dob_null_warning             out nocopy boolean,
  p_orig_hire_warning            out nocopy boolean
  )
is
--
  l_rec     per_per_shd.g_rec_type;
  l_proc varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_per_shd.convert_args
  (
  null,
  null,
  null,
  p_business_group_id,
  p_person_type_id,
  p_last_name,
  p_start_date,
  p_applicant_number,
  null,
  p_comments,
  null,
  null,
  null,
  p_date_employee_data_verified,
  p_date_of_birth,
  p_email_address,
  p_employee_number,
  p_expense_check_send_to_addres,
  p_first_name,
  null,
  p_known_as,
  p_marital_status,
  p_middle_names,
  p_nationality,
  p_national_identifier,
  p_previous_last_name,
  p_registered_disabled_flag,
  p_sex,
  p_title,
  p_vendor_id,
  p_work_telephone,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
  p_attribute21,
  p_attribute22,
  p_attribute23,
  p_attribute24,
  p_attribute25,
  p_attribute26,
  p_attribute27,
  p_attribute28,
  p_attribute29,
  p_attribute30,
  p_per_information_category,
  p_per_information1,
  p_per_information2,
  p_per_information3,
  p_per_information4,
  p_per_information5,
  p_per_information6,
  p_per_information7,
  p_per_information8,
  p_per_information9,
  p_per_information10,
  p_per_information11,
  p_per_information12,
  p_per_information13,
  p_per_information14,
  p_per_information15,
  p_per_information16,
  p_per_information17,
  p_per_information18,
  p_per_information19,
  p_per_information20,
  null,
  p_suffix,
  p_DATE_OF_DEATH                   ,
  p_BACKGROUND_CHECK_STATUS         ,
  p_BACKGROUND_DATE_CHECK           ,
  p_BLOOD_TYPE                      ,
  p_CORRESPONDENCE_LANGUAGE         ,
  p_FAST_PATH_EMPLOYEE              ,
  p_FTE_CAPACITY                    ,
  p_HOLD_APPLICANT_DATE_UNTIL       ,
  p_HONORS                          ,
  p_INTERNAL_LOCATION               ,
  p_LAST_MEDICAL_TEST_BY            ,
  p_LAST_MEDICAL_TEST_DATE          ,
  p_MAILSTOP                        ,
  p_OFFICE_NUMBER                   ,
  p_ON_MILITARY_SERVICE             ,
  p_ORDER_NAME                      ,
  p_PRE_NAME_ADJUNCT                ,
  p_PROJECTED_START_DATE            ,
  p_REHIRE_AUTHORIZOR               ,
  p_REHIRE_RECOMMENDATION           ,
  p_RESUME_EXISTS                   ,
  p_RESUME_LAST_UPDATED             ,
  p_SECOND_PASSPORT_EXISTS          ,
  p_STUDENT_STATUS                  ,
  p_WORK_SCHEDULE                   ,
  p_PER_INFORMATION21               ,
  p_PER_INFORMATION22               ,
  p_PER_INFORMATION23               ,
  p_PER_INFORMATION24               ,
  p_PER_INFORMATION25               ,
  p_PER_INFORMATION26               ,
  p_PER_INFORMATION27               ,
  p_PER_INFORMATION28               ,
  p_PER_INFORMATION29               ,
  p_PER_INFORMATION30               ,
  p_REHIRE_REASON                   ,
  p_BENEFIT_GROUP_ID                ,
  p_RECEIPT_OF_DEATH_CERT_DATE      ,
  p_COORD_BEN_MED_PLN_NO            ,
  p_COORD_BEN_NO_CVG_FLAG           ,
  p_coord_ben_med_ext_er            ,
  p_coord_ben_med_pl_name           ,
  p_coord_ben_med_insr_crr_name     ,
  p_coord_ben_med_insr_crr_ident    ,
  p_coord_ben_med_cvg_strt_dt       ,
  p_coord_ben_med_cvg_end_dt        ,
  p_USES_TOBACCO_FLAG               ,
  p_DPDNT_ADOPTION_DATE             ,
  p_DPDNT_VLNTRY_SVCE_FLAG          ,
  p_ORIGINAL_DATE_OF_HIRE           ,
  p_town_of_birth,
  p_region_of_birth,
  p_country_of_birth,
  p_global_person_id,
  p_party_id,
  p_npw_number,
  p_current_npw_flag,
  null,                        -- global_name
  null                         -- local_name
  );
  --
  -- Having converted the arguments into the per_per_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date, p_validate, p_name_combination_warning,
      p_dob_null_warning, p_orig_hire_warning
      );
  --
  -- Set the OUT arguments.
  --
  p_person_id                   := l_rec.person_id;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  p_employee_number             := l_rec.employee_number;
  p_applicant_number            := l_rec.applicant_number;
  p_object_version_number       := l_rec.object_version_number;
  p_comment_id                  := l_rec.comment_id;
  p_current_applicant_flag      := l_rec.current_applicant_flag;
  p_current_emp_or_apl_flag     := l_rec.current_emp_or_apl_flag;
  p_current_employee_flag       := l_rec.current_employee_flag;
  p_full_name                   := l_rec.full_name;
  p_npw_number                  := l_rec.npw_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_per_ins;

/
