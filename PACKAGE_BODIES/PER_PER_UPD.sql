--------------------------------------------------------
--  DDL for Package Body PER_PER_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PER_UPD" as
/* $Header: peperrhi.pkb 120.14.12010000.5 2009/08/17 12:07:47 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_per_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
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
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'dt_update_dml';
  cursor c_person is
    select *
    from   per_all_people_f
    where  person_id = p_rec.person_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_person per_all_people_f%rowtype;
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
     (p_base_table_name => 'per_all_people_f',
      p_base_key_column => 'person_id',
      p_base_key_value  => p_rec.person_id);
    --
    per_per_shd.g_api_dml := true;  -- Set the api dml status

/*    --bug#1942531 change starts
    if not FND_FLEX_DESCVAL.validate_desccols
      (appl_short_name  => 'PER'
      ,desc_flex_name   => 'Person Developer DF'
      ,VALUES_OR_IDS => 'I'
      ) then
      p_rec.per_information_category := null;
    End if;
    --bug#1942531 change ends */
    --
    -- Update the per_all_people_f Row
    --
    update  per_all_people_f
    set
        person_id                       = p_rec.person_id,
    person_type_id                  = p_rec.person_type_id,
    last_name                       = p_rec.last_name,
    start_date                      = p_rec.start_date,
    applicant_number                = p_rec.applicant_number,
    comment_id                      = p_rec.comment_id,
    current_applicant_flag          = p_rec.current_applicant_flag,
    current_emp_or_apl_flag         = p_rec.current_emp_or_apl_flag,
    current_employee_flag           = p_rec.current_employee_flag,
    date_employee_data_verified     = p_rec.date_employee_data_verified,
    date_of_birth                   = p_rec.date_of_birth,
    email_address                   = p_rec.email_address,
    employee_number                 = p_rec.employee_number,
    expense_check_send_to_address   = p_rec.expense_check_send_to_address,
    first_name                      = p_rec.first_name,
    full_name                       = p_rec.full_name,
    known_as                        = p_rec.known_as,
    marital_status                  = p_rec.marital_status,
    middle_names                    = p_rec.middle_names,
    nationality                     = p_rec.nationality,
    national_identifier             = p_rec.national_identifier,
    previous_last_name              = p_rec.previous_last_name,
    registered_disabled_flag        = p_rec.registered_disabled_flag,
    sex                             = p_rec.sex,
    title                           = p_rec.title,
    vendor_id                       = p_rec.vendor_id,
--    work_telephone                  = p_rec.work_telephone,
    request_id                      = p_rec.request_id,
    program_application_id          = p_rec.program_application_id,
    program_id                      = p_rec.program_id,
    program_update_date             = p_rec.program_update_date,
    attribute_category              = p_rec.attribute_category,
    attribute1                      = p_rec.attribute1,
    attribute2                      = p_rec.attribute2,
    attribute3                      = p_rec.attribute3,
    attribute4                      = p_rec.attribute4,
    attribute5                      = p_rec.attribute5,
    attribute6                      = p_rec.attribute6,
    attribute7                      = p_rec.attribute7,
    attribute8                      = p_rec.attribute8,
    attribute9                      = p_rec.attribute9,
    attribute10                     = p_rec.attribute10,
    attribute11                     = p_rec.attribute11,
    attribute12                     = p_rec.attribute12,
    attribute13                     = p_rec.attribute13,
    attribute14                     = p_rec.attribute14,
    attribute15                     = p_rec.attribute15,
    attribute16                     = p_rec.attribute16,
    attribute17                     = p_rec.attribute17,
    attribute18                     = p_rec.attribute18,
    attribute19                     = p_rec.attribute19,
    attribute20                     = p_rec.attribute20,
    attribute21                     = p_rec.attribute21,
    attribute22                     = p_rec.attribute22,
    attribute23                     = p_rec.attribute23,
    attribute24                     = p_rec.attribute24,
    attribute25                     = p_rec.attribute25,
    attribute26                     = p_rec.attribute26,
    attribute27                     = p_rec.attribute27,
    attribute28                     = p_rec.attribute28,
    attribute29                     = p_rec.attribute29,
    attribute30                     = p_rec.attribute30,
    per_information_category        = p_rec.per_information_category,
    per_information1                = p_rec.per_information1,
    per_information2                = p_rec.per_information2,
    per_information3                = p_rec.per_information3,
    per_information4                = p_rec.per_information4,
    per_information5                = p_rec.per_information5,
    per_information6                = p_rec.per_information6,
    per_information7                = p_rec.per_information7,
    per_information8                = p_rec.per_information8,
    per_information9                = p_rec.per_information9,
    per_information10               = p_rec.per_information10,
    per_information11               = p_rec.per_information11,
    per_information12               = p_rec.per_information12,
    per_information13               = p_rec.per_information13,
    per_information14               = p_rec.per_information14,
    per_information15               = p_rec.per_information15,
    per_information16               = p_rec.per_information16,
    per_information17               = p_rec.per_information17,
    per_information18               = p_rec.per_information18,
    per_information19               = p_rec.per_information19,
    per_information20               = p_rec.per_information20,
    object_version_number           = p_rec.object_version_number,
    suffix                          = p_rec.suffix,
    DATE_OF_DEATH                   = p_rec.DATE_OF_DEATH,
    BACKGROUND_CHECK_STATUS         = p_rec.BACKGROUND_CHECK_STATUS        ,
    BACKGROUND_DATE_CHECK           = p_rec.BACKGROUND_DATE_CHECK          ,
    BLOOD_TYPE                      = p_rec.BLOOD_TYPE                     ,
    CORRESPONDENCE_LANGUAGE         = p_rec.CORRESPONDENCE_LANGUAGE        ,
    FAST_PATH_EMPLOYEE              = p_rec.FAST_PATH_EMPLOYEE             ,
    FTE_CAPACITY                    = p_rec.FTE_CAPACITY                   ,
    HOLD_APPLICANT_DATE_UNTIL       = p_rec.HOLD_APPLICANT_DATE_UNTIL      ,
    HONORS                          = p_rec.HONORS                         ,
    INTERNAL_LOCATION               = p_rec.INTERNAL_LOCATION              ,
    LAST_MEDICAL_TEST_BY            = p_rec.LAST_MEDICAL_TEST_BY           ,
    LAST_MEDICAL_TEST_DATE          = p_rec.LAST_MEDICAL_TEST_DATE         ,
    MAILSTOP                        = p_rec.MAILSTOP                       ,
    OFFICE_NUMBER                   = p_rec.OFFICE_NUMBER                  ,
    ON_MILITARY_SERVICE             = p_rec.ON_MILITARY_SERVICE            ,
    ORDER_NAME                      = p_rec.ORDER_NAME                     ,
    PRE_NAME_ADJUNCT                = p_rec.PRE_NAME_ADJUNCT               ,
    PROJECTED_START_DATE            = p_rec.PROJECTED_START_DATE           ,
    REHIRE_AUTHORIZOR               = p_rec.REHIRE_AUTHORIZOR              ,
    REHIRE_RECOMMENDATION           = p_rec.REHIRE_RECOMMENDATION          ,
    RESUME_EXISTS                   = p_rec.RESUME_EXISTS                  ,
    RESUME_LAST_UPDATED             = p_rec.RESUME_LAST_UPDATED            ,
    SECOND_PASSPORT_EXISTS          = p_rec.SECOND_PASSPORT_EXISTS         ,
    STUDENT_STATUS                  = p_rec.STUDENT_STATUS                 ,
    WORK_SCHEDULE                   = p_rec.WORK_SCHEDULE                  ,
    PER_INFORMATION21               = p_rec.PER_INFORMATION21              ,
    PER_INFORMATION22               = p_rec.PER_INFORMATION22              ,
    PER_INFORMATION23               = p_rec.PER_INFORMATION23              ,
    PER_INFORMATION24               = p_rec.PER_INFORMATION24              ,
    PER_INFORMATION25               = p_rec.PER_INFORMATION25              ,
    PER_INFORMATION26               = p_rec.PER_INFORMATION26              ,
    PER_INFORMATION27               = p_rec.PER_INFORMATION27              ,
    PER_INFORMATION28               = p_rec.PER_INFORMATION28              ,
    PER_INFORMATION29               = p_rec.PER_INFORMATION29              ,
    PER_INFORMATION30               = p_rec.PER_INFORMATION30              ,
    REHIRE_REASON                   = p_rec.REHIRE_REASON                  ,
    BENEFIT_GROUP_ID                = p_rec.BENEFIT_GROUP_ID               ,
    RECEIPT_OF_DEATH_CERT_DATE      = p_rec.RECEIPT_OF_DEATH_CERT_DATE     ,
    COORD_BEN_MED_PLN_NO            = p_rec.COORD_BEN_MED_PLN_NO           ,
    COORD_BEN_NO_CVG_FLAG           = p_rec.COORD_BEN_NO_CVG_FLAG          ,
    COORD_BEN_MED_EXT_ER            = p_rec.COORD_BEN_MED_ext_er,
    COORD_BEN_MED_PL_NAME           = p_rec.COORD_BEN_MED_pl_name,
    COORD_BEN_MED_INSR_CRR_NAME     = p_rec.COORD_BEN_MED_insr_crr_name,
    COORD_BEN_MED_INSR_CRR_IDENT    = p_rec.COORD_BEN_MED_insr_crr_ident,
    COORD_BEN_MED_CVG_STRT_DT       = p_rec.COORD_BEN_MED_cvg_strt_dt,
    COORD_BEN_MED_CVG_END_DT        = p_rec.COORD_BEN_MED_cvg_end_dt,
    USES_TOBACCO_FLAG               = p_rec.USES_TOBACCO_FLAG              ,
    DPDNT_ADOPTION_DATE             = p_rec.DPDNT_ADOPTION_DATE            ,
    DPDNT_VLNTRY_SVCE_FLAG          = p_rec.DPDNT_VLNTRY_SVCE_FLAG         ,
    ORIGINAL_DATE_OF_HIRE           = p_rec.ORIGINAL_DATE_OF_HIRE          ,
    town_of_birth                   = p_rec.town_of_birth                  ,
    region_of_birth                 = p_rec.region_of_birth                ,
    country_of_birth                = p_rec.country_of_birth               ,
    global_person_id                = p_rec.global_person_id               ,
    party_id                        = p_rec.party_id,
    npw_number                      = p_rec.npw_number,
    current_npw_flag                = p_rec.current_npw_flag,
    global_name                     = p_rec.global_name,    -- #3889584
    local_name                      = p_rec.local_name

    where   person_id = p_rec.person_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    -- For any corrections we need to call the TCA routine to update the
    -- person record TCA.
    --
    open c_person;
      --
      fetch c_person into l_person;
      --
    close c_person;
    --
    per_hrtca_merge.update_tca_person(p_rec => l_person);
    --
    per_per_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
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
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec         => p_rec,
      p_effective_date  => p_effective_date,
      p_datetrack_mode  => p_datetrack_mode,
            p_validation_start_date => p_validation_start_date,
      p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
-- the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Pre Conditions:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc           varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number  number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    per_per_shd.upd_effective_end_date
     (p_effective_date         => p_effective_date,
      p_base_key_value         => p_rec.person_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      per_per_del.delete_dml
        (p_rec        => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    per_per_ins.insert_dml
      (p_rec         => p_rec,
       p_effective_date    => p_effective_date,
       p_datetrack_mode    => p_datetrack_mode,
       p_validation_start_date   => p_validation_start_date,
       p_validation_end_date  => p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'pre_update';
  l_rowid       varchar2(72);
  l_esd         date;
  l_eed         date;
--
  cursor csr_rowid is
     select rowid, effective_start_date, effective_end_date
     from per_all_people_f
     where person_id = p_rec.person_id
     and p_effective_date between
         effective_start_date and effective_end_date;
--
  cursor csr_rowid_u is
     select rowid
     from per_all_people_f
     where person_id = p_rec.person_id
     and p_effective_date -1 between
         effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null and p_rec.comment_id is null) then
    hr_comm_api.ins(p_comment_id        => p_rec.comment_id,
                    p_source_table_name => 'per_all_people_f',
                    p_comment_text      => p_rec.comments);
  -- Update the comments if they have changed
  ElsIf (p_rec.comment_id is not null and p_rec.comments <>
         per_per_shd.g_old_rec.comments) then
    hr_comm_api.upd(p_comment_id        => p_rec.comment_id,
                    p_source_table_name => 'per_all_people_f',
                    p_comment_text      => p_rec.comments);
  End If;
  --
  dt_pre_update
    (p_rec          => p_rec,
     p_effective_date        => p_effective_date,
     p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
-- Bug 3717072 Starts
-- Desc: Call the BEN proc for change log event.
  if p_datetrack_mode <> 'CORRECTION' then
    ben_ext_chlg.log_per_chg
    (p_event => 'UPDATE',
     p_old_rec => per_per_shd.g_old_rec,
     p_new_rec => p_rec
     );
  end if;
-- Bug 3717072 Ends
  --
  -- Check for DT mode, if correction use current values
  -- else use values from currently existing record.
  --
  if p_datetrack_mode <> 'CORRECTION' then
     open csr_rowid_u;
     fetch csr_rowid_u into l_rowid;
     close csr_rowid_u;
     l_esd := p_rec.effective_start_date;
     l_eed := p_rec.effective_end_date;
  else
     open csr_rowid;
     fetch csr_rowid into l_rowid, l_esd, l_eed;
     close csr_rowid;
  end if;
  --
  ben_dt_trgr_handle.person
    (p_rowid                 => l_rowid
    ,p_business_group_id          => p_rec.business_group_id
    ,p_person_id                  => p_rec.person_id
    ,p_effective_start_date       => l_esd
    ,p_effective_end_date         => l_eed
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End pre_update;
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
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
   (p_rec          in per_per_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date,
         p_name_combination_warning  in boolean,
         p_dob_null_warning          in boolean,
         p_orig_hire_warning         in boolean) is
--
  l_proc varchar2(72) := g_package||'post_update';
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
  -- Start of API User Hook for post_update.
  begin
    per_per_rku.after_update
      (p_person_id                    => p_rec.person_id
      ,p_effective_start_date         => p_rec.effective_start_date
      ,p_effective_end_date           => p_rec.effective_end_date
      ,p_person_type_id               => p_rec.person_type_id
      ,p_last_name                    => p_rec.last_name
      ,p_start_date                   => p_rec.start_date
      ,p_applicant_number             => p_rec.applicant_number
      ,p_comment_id                   => p_rec.comment_id
      ,p_comments                     => p_rec.comments
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
      ,p_coord_ben_med_ext_er          => p_rec.coord_ben_med_ext_er
      ,p_coord_ben_med_pl_name         => p_rec.coord_ben_med_pl_name
      ,p_coord_ben_med_insr_crr_name   => p_rec.coord_ben_med_insr_crr_name
      ,p_coord_ben_med_insr_crr_ident  => p_rec.coord_ben_med_insr_crr_ident
      ,p_coord_ben_med_cvg_strt_dt     => p_rec.coord_ben_med_cvg_strt_dt
      ,p_coord_ben_med_cvg_end_dt      => p_rec.coord_ben_med_cvg_end_dt
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
      ,p_effective_date               => p_effective_date
      ,p_datetrack_mode               => p_datetrack_mode
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      ,p_name_combination_warning     => p_name_combination_warning
      ,p_dob_null_warning             => p_dob_null_warning
      ,p_orig_hire_warning            => p_orig_hire_warning
      ,p_effective_start_date_o
          => per_per_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
          => per_per_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
          => per_per_shd.g_old_rec.business_group_id
      ,p_person_type_id_o
          => per_per_shd.g_old_rec.person_type_id
      ,p_last_name_o
          => per_per_shd.g_old_rec.last_name
      ,p_start_date_o
          => per_per_shd.g_old_rec.start_date
      ,p_applicant_number_o
          => per_per_shd.g_old_rec.applicant_number
      ,p_comment_id_o
          => per_per_shd.g_old_rec.comment_id
      ,p_current_applicant_flag_o
          => per_per_shd.g_old_rec.current_applicant_flag
      ,p_current_emp_or_apl_flag_o
          => per_per_shd.g_old_rec.current_emp_or_apl_flag
      ,p_current_employee_flag_o
          => per_per_shd.g_old_rec.current_employee_flag
      ,p_date_employee_data_verifie_o
          => per_per_shd.g_old_rec.date_employee_data_verified
      ,p_date_of_birth_o
          => per_per_shd.g_old_rec.date_of_birth
      ,p_email_address_o
          => per_per_shd.g_old_rec.email_address
      ,p_employee_number_o
          => per_per_shd.g_old_rec.employee_number
      ,p_expense_check_send_to_addr_o
          => per_per_shd.g_old_rec.expense_check_send_to_address
      ,p_first_name_o
          => per_per_shd.g_old_rec.first_name
      ,p_full_name_o
          => per_per_shd.g_old_rec.full_name
      ,p_known_as_o
          => per_per_shd.g_old_rec.known_as
      ,p_marital_status_o
          => per_per_shd.g_old_rec.marital_status
      ,p_middle_names_o
          => per_per_shd.g_old_rec.middle_names
      ,p_nationality_o
          => per_per_shd.g_old_rec.nationality
      ,p_national_identifier_o
          => per_per_shd.g_old_rec.national_identifier
      ,p_previous_last_name_o
          => per_per_shd.g_old_rec.previous_last_name
      ,p_registered_disabled_flag_o
          => per_per_shd.g_old_rec.registered_disabled_flag
      ,p_sex_o
          => per_per_shd.g_old_rec.sex
      ,p_title_o
          => per_per_shd.g_old_rec.title
      ,p_vendor_id_o
          => per_per_shd.g_old_rec.vendor_id
      ,p_work_telephone_o
          => per_per_shd.g_old_rec.work_telephone
      ,p_request_id_o
          => per_per_shd.g_old_rec.request_id
      ,p_program_application_id_o
          => per_per_shd.g_old_rec.program_application_id
      ,p_program_id_o
          => per_per_shd.g_old_rec.program_id
      ,p_program_update_date_o
          => per_per_shd.g_old_rec.program_update_date
      ,p_attribute_category_o
          => per_per_shd.g_old_rec.attribute_category
      ,p_attribute1_o
          => per_per_shd.g_old_rec.attribute1
      ,p_attribute2_o
          => per_per_shd.g_old_rec.attribute2
      ,p_attribute3_o
          => per_per_shd.g_old_rec.attribute3
      ,p_attribute4_o
          => per_per_shd.g_old_rec.attribute4
      ,p_attribute5_o
          => per_per_shd.g_old_rec.attribute5
      ,p_attribute6_o
          => per_per_shd.g_old_rec.attribute6
      ,p_attribute7_o
          => per_per_shd.g_old_rec.attribute7
      ,p_attribute8_o
          => per_per_shd.g_old_rec.attribute8
      ,p_attribute9_o
          => per_per_shd.g_old_rec.attribute9
      ,p_attribute10_o
          => per_per_shd.g_old_rec.attribute10
      ,p_attribute11_o
          => per_per_shd.g_old_rec.attribute11
      ,p_attribute12_o
          => per_per_shd.g_old_rec.attribute12
      ,p_attribute13_o
          => per_per_shd.g_old_rec.attribute13
      ,p_attribute14_o
          => per_per_shd.g_old_rec.attribute14
      ,p_attribute15_o
          => per_per_shd.g_old_rec.attribute15
      ,p_attribute16_o
          => per_per_shd.g_old_rec.attribute16
      ,p_attribute17_o
          => per_per_shd.g_old_rec.attribute17
      ,p_attribute18_o
          => per_per_shd.g_old_rec.attribute18
      ,p_attribute19_o
          => per_per_shd.g_old_rec.attribute19
      ,p_attribute20_o
          => per_per_shd.g_old_rec.attribute20
      ,p_attribute21_o
          => per_per_shd.g_old_rec.attribute21
      ,p_attribute22_o
          => per_per_shd.g_old_rec.attribute22
      ,p_attribute23_o
          => per_per_shd.g_old_rec.attribute23
      ,p_attribute24_o
          => per_per_shd.g_old_rec.attribute24
      ,p_attribute25_o
          => per_per_shd.g_old_rec.attribute25
      ,p_attribute26_o
          => per_per_shd.g_old_rec.attribute26
      ,p_attribute27_o
          => per_per_shd.g_old_rec.attribute27
      ,p_attribute28_o
          => per_per_shd.g_old_rec.attribute28
      ,p_attribute29_o
          => per_per_shd.g_old_rec.attribute29
      ,p_attribute30_o
          => per_per_shd.g_old_rec.attribute30
      ,p_per_information_category_o
          => per_per_shd.g_old_rec.per_information_category
      ,p_per_information1_o
          => per_per_shd.g_old_rec.per_information1
      ,p_per_information2_o
          => per_per_shd.g_old_rec.per_information2
      ,p_per_information3_o
          => per_per_shd.g_old_rec.per_information3
      ,p_per_information4_o
          => per_per_shd.g_old_rec.per_information4
      ,p_per_information5_o
          => per_per_shd.g_old_rec.per_information5
      ,p_per_information6_o
          => per_per_shd.g_old_rec.per_information6
      ,p_per_information7_o
          => per_per_shd.g_old_rec.per_information7
      ,p_per_information8_o
          => per_per_shd.g_old_rec.per_information8
      ,p_per_information9_o
          => per_per_shd.g_old_rec.per_information9
      ,p_per_information10_o
          => per_per_shd.g_old_rec.per_information10
      ,p_per_information11_o
          => per_per_shd.g_old_rec.per_information11
      ,p_per_information12_o
          => per_per_shd.g_old_rec.per_information12
      ,p_per_information13_o
          => per_per_shd.g_old_rec.per_information13
      ,p_per_information14_o
          => per_per_shd.g_old_rec.per_information14
      ,p_per_information15_o
          => per_per_shd.g_old_rec.per_information15
      ,p_per_information16_o
          => per_per_shd.g_old_rec.per_information16
      ,p_per_information17_o
          => per_per_shd.g_old_rec.per_information17
      ,p_per_information18_o
          => per_per_shd.g_old_rec.per_information18
      ,p_per_information19_o
          => per_per_shd.g_old_rec.per_information19
      ,p_per_information20_o
          => per_per_shd.g_old_rec.per_information20
      ,p_suffix_o
          => per_per_shd.g_old_rec.suffix
      ,p_DATE_OF_DEATH_o
          => per_per_shd.g_old_rec.DATE_OF_DEATH
      ,p_BACKGROUND_CHECK_STATUS_o
          => per_per_shd.g_old_rec.BACKGROUND_CHECK_STATUS
      ,p_BACKGROUND_DATE_CHECK_o
          => per_per_shd.g_old_rec.BACKGROUND_DATE_CHECK
      ,p_BLOOD_TYPE_o
          => per_per_shd.g_old_rec.BLOOD_TYPE
      ,p_CORRESPONDENCE_LANGUAGE_o
          => per_per_shd.g_old_rec.CORRESPONDENCE_LANGUAGE
      ,p_FAST_PATH_EMPLOYEE_o
          => per_per_shd.g_old_rec.FAST_PATH_EMPLOYEE
      ,p_FTE_CAPACITY_o
          => per_per_shd.g_old_rec.FTE_CAPACITY
      ,p_HOLD_APPLICANT_DATE_UNTIL_o
          => per_per_shd.g_old_rec.HOLD_APPLICANT_DATE_UNTIL
      ,p_HONORS_o
          => per_per_shd.g_old_rec.HONORS
      ,p_INTERNAL_LOCATION_o
          => per_per_shd.g_old_rec.INTERNAL_LOCATION
      ,p_LAST_MEDICAL_TEST_BY_o
          => per_per_shd.g_old_rec.LAST_MEDICAL_TEST_BY
      ,p_LAST_MEDICAL_TEST_DATE_o
          => per_per_shd.g_old_rec.LAST_MEDICAL_TEST_DATE
      ,p_MAILSTOP_o
          => per_per_shd.g_old_rec.MAILSTOP
      ,p_OFFICE_NUMBER_o
          => per_per_shd.g_old_rec.OFFICE_NUMBER
      ,p_ON_MILITARY_SERVICE_o
          => per_per_shd.g_old_rec.ON_MILITARY_SERVICE
      ,p_ORDER_NAME_o
          => per_per_shd.g_old_rec.ORDER_NAME
      ,p_PRE_NAME_ADJUNCT_o
          => per_per_shd.g_old_rec.PRE_NAME_ADJUNCT
      ,p_PROJECTED_START_DATE_o
          => per_per_shd.g_old_rec.PROJECTED_START_DATE
      ,p_REHIRE_AUTHORIZOR_o
          => per_per_shd.g_old_rec.REHIRE_AUTHORIZOR
      ,p_REHIRE_RECOMMENDATION_o
          => per_per_shd.g_old_rec.REHIRE_RECOMMENDATION
      ,p_RESUME_EXISTS_o
          => per_per_shd.g_old_rec.RESUME_EXISTS
      ,p_RESUME_LAST_UPDATED_o
          => per_per_shd.g_old_rec.RESUME_LAST_UPDATED
      ,p_SECOND_PASSPORT_EXISTS_o
          => per_per_shd.g_old_rec.SECOND_PASSPORT_EXISTS
      ,p_STUDENT_STATUS_o
          => per_per_shd.g_old_rec.STUDENT_STATUS
      ,p_WORK_SCHEDULE_o
          => per_per_shd.g_old_rec.WORK_SCHEDULE
      ,p_PER_INFORMATION21_o
          => per_per_shd.g_old_rec.PER_INFORMATION21
      ,p_PER_INFORMATION22_o
          => per_per_shd.g_old_rec.PER_INFORMATION22
      ,p_PER_INFORMATION23_o
          => per_per_shd.g_old_rec.PER_INFORMATION23
      ,p_PER_INFORMATION24_o
          => per_per_shd.g_old_rec.PER_INFORMATION24
      ,p_PER_INFORMATION25_o
          => per_per_shd.g_old_rec.PER_INFORMATION25
      ,p_PER_INFORMATION26_o
          => per_per_shd.g_old_rec.PER_INFORMATION26
      ,p_PER_INFORMATION27_o
          => per_per_shd.g_old_rec.PER_INFORMATION27
      ,p_PER_INFORMATION28_o
          => per_per_shd.g_old_rec.PER_INFORMATION28
      ,p_PER_INFORMATION29_o
          => per_per_shd.g_old_rec.PER_INFORMATION29
      ,p_PER_INFORMATION30_o
          => per_per_shd.g_old_rec.PER_INFORMATION30
      ,p_REHIRE_REASON_o
          => per_per_shd.g_old_rec.REHIRE_REASON
      ,p_BENEFIT_GROUP_ID_o
         => per_per_shd.g_old_rec.BENEFIT_GROUP_ID
      ,p_RECEIPT_OF_DEATH_CERT_DATE_o
         => per_per_shd.g_old_rec.RECEIPT_OF_DEATH_CERT_DATE
      ,p_COORD_BEN_MED_PLN_NO_o
         => per_per_shd.g_old_rec.COORD_BEN_MED_PLN_NO
      ,p_COORD_BEN_NO_CVG_FLAG_o
         => per_per_shd.g_old_rec.COORD_BEN_NO_CVG_FLAG
      ,p_coord_ben_med_ext_er_o
         => per_per_shd.g_old_rec.coord_ben_med_ext_er
      ,p_coord_ben_med_pl_name_o
         => per_per_shd.g_old_rec.coord_ben_med_pl_name
      ,p_coord_ben_med_insr_crr_nam_o
         => per_per_shd.g_old_rec.coord_ben_med_insr_crr_name
      ,p_coord_ben_med_insr_crr_ide_o
         => per_per_shd.g_old_rec.coord_ben_med_insr_crr_ident
      ,p_coord_ben_med_cvg_strt_dt_o
         => per_per_shd.g_old_rec.coord_ben_med_cvg_strt_dt
      ,p_coord_ben_med_cvg_end_dt_o
         => per_per_shd.g_old_rec.coord_ben_med_cvg_end_dt
      ,p_USES_TOBACCO_FLAG_o
         => per_per_shd.g_old_rec.USES_TOBACCO_FLAG
      ,p_DPDNT_ADOPTION_DATE_o
         => per_per_shd.g_old_rec.DPDNT_ADOPTION_DATE
      ,p_DPDNT_VLNTRY_SVCE_FLAG_o
         => per_per_shd.g_old_rec.DPDNT_VLNTRY_SVCE_FLAG
      ,p_ORIGINAL_DATE_OF_HIRE_o
         => per_per_shd.g_old_rec.ORIGINAL_DATE_OF_HIRE
      ,p_town_of_birth_o
      => per_per_shd.g_old_rec.town_of_birth
      ,p_region_of_birth_o
      => per_per_shd.g_old_rec.region_of_birth
    ,p_country_of_birth_o
      => per_per_shd.g_old_rec.country_of_birth
    ,p_global_person_id_o
      => per_per_shd.g_old_rec.global_person_id
    ,p_party_id_o
      => per_per_shd.g_old_rec.party_id
      ,p_npw_number_o
          => per_per_shd.g_old_rec.npw_number
      ,p_current_npw_flag_o
          => per_per_shd.g_old_rec.current_npw_flag
      ,p_global_name_o
         => per_per_shd.g_old_rec.global_name
      ,p_local_name_o
         => per_per_shd.g_old_rec.local_name
      ,p_object_version_number_o
          => per_per_shd.g_old_rec.object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'per_all_people_f'
        ,p_hook_type   => 'AU'
        );
  end;
  -- End of API User Hook for post_update.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- Start of HR/WF Synchronization
  --
  open l_per_cur;
  fetch l_per_cur into l_per_rec;
  close l_per_cur;
  --
    per_hrwf_synch.per_per_wf(
                   p_rec       => l_per_rec,
                   p_action    => 'UPDATE');
  -- End HR/WF Synchronization
  --
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
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
--   This private procedure can only be called from the upd process.
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
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   Procedure convert_defs(p_rec in out nocopy per_per_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
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
    p_rec.business_group_id :=
    per_per_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.person_type_id = hr_api.g_number) then
    p_rec.person_type_id :=
    per_per_shd.g_old_rec.person_type_id;
  End If;
  If (p_rec.last_name = hr_api.g_varchar2) then
    p_rec.last_name :=
    per_per_shd.g_old_rec.last_name;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_per_shd.g_old_rec.start_date;
  End If;
  If (p_rec.applicant_number = hr_api.g_varchar2) then
    p_rec.applicant_number :=
    per_per_shd.g_old_rec.applicant_number;
  End If;
  If (p_rec.comment_id = hr_api.g_number) then
    p_rec.comment_id :=
    per_per_shd.g_old_rec.comment_id;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments := per_per_shd.g_old_rec.comments;
  End If;
  If (p_rec.current_applicant_flag = hr_api.g_varchar2) then
    p_rec.current_applicant_flag :=
    per_per_shd.g_old_rec.current_applicant_flag;
  End If;
  If (p_rec.current_emp_or_apl_flag = hr_api.g_varchar2) then
    p_rec.current_emp_or_apl_flag :=
    per_per_shd.g_old_rec.current_emp_or_apl_flag;
  End If;
  If (p_rec.current_employee_flag = hr_api.g_varchar2) then
    p_rec.current_employee_flag :=
    per_per_shd.g_old_rec.current_employee_flag;
  End If;
  If (p_rec.date_employee_data_verified = hr_api.g_date) then
    p_rec.date_employee_data_verified :=
    per_per_shd.g_old_rec.date_employee_data_verified;
  End If;
  If (p_rec.date_of_birth = hr_api.g_date) then
    p_rec.date_of_birth :=
    per_per_shd.g_old_rec.date_of_birth;
  End If;
  If (p_rec.email_address = hr_api.g_varchar2) then
    p_rec.email_address :=
    per_per_shd.g_old_rec.email_address;
  End If;
  If (p_rec.employee_number = hr_api.g_varchar2) then
    p_rec.employee_number :=
    per_per_shd.g_old_rec.employee_number;
  End If;
  If (p_rec.expense_check_send_to_address = hr_api.g_varchar2) then
    p_rec.expense_check_send_to_address :=
    per_per_shd.g_old_rec.expense_check_send_to_address;
  End If;
  If (p_rec.first_name = hr_api.g_varchar2) then
    p_rec.first_name :=
    per_per_shd.g_old_rec.first_name;
  End If;
  If (p_rec.full_name = hr_api.g_varchar2) then
    p_rec.full_name :=
    per_per_shd.g_old_rec.full_name;
  End If;
  If (p_rec.known_as = hr_api.g_varchar2) then
    p_rec.known_as :=
    per_per_shd.g_old_rec.known_as;
  End If;
  If (p_rec.marital_status = hr_api.g_varchar2) then
    p_rec.marital_status :=
    per_per_shd.g_old_rec.marital_status;
  End If;
  If (p_rec.middle_names = hr_api.g_varchar2) then
    p_rec.middle_names :=
    per_per_shd.g_old_rec.middle_names;
  End If;
  If (p_rec.nationality = hr_api.g_varchar2) then
    p_rec.nationality :=
    per_per_shd.g_old_rec.nationality;
  End If;
  If (p_rec.national_identifier = hr_api.g_varchar2) then
    p_rec.national_identifier :=
    per_per_shd.g_old_rec.national_identifier;
  End If;
  If (p_rec.previous_last_name = hr_api.g_varchar2) then
    p_rec.previous_last_name :=
    per_per_shd.g_old_rec.previous_last_name;
  End If;
  If (p_rec.registered_disabled_flag = hr_api.g_varchar2) then
    p_rec.registered_disabled_flag :=
    per_per_shd.g_old_rec.registered_disabled_flag;
  End If;
  If (p_rec.sex = hr_api.g_varchar2) then
    p_rec.sex :=
    per_per_shd.g_old_rec.sex;
  End If;
  If (p_rec.title = hr_api.g_varchar2) then
    p_rec.title :=
    per_per_shd.g_old_rec.title;
  End If;
  If (p_rec.vendor_id = hr_api.g_number) then
    p_rec.vendor_id :=
    per_per_shd.g_old_rec.vendor_id;
  End If;
  If (p_rec.work_telephone = hr_api.g_varchar2) then
    p_rec.work_telephone :=
    per_per_shd.g_old_rec.work_telephone;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_per_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_per_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_per_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_per_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_per_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_per_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_per_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_per_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_per_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_per_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_per_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_per_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_per_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_per_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_per_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_per_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_per_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_per_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_per_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_per_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_per_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_per_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_per_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_per_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_per_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    per_per_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    per_per_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    per_per_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    per_per_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    per_per_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    per_per_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    per_per_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    per_per_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    per_per_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    per_per_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.per_information_category = hr_api.g_varchar2) then
    p_rec.per_information_category :=
    per_per_shd.g_old_rec.per_information_category;
  End If;
  If (p_rec.per_information1 = hr_api.g_varchar2) then
    p_rec.per_information1 :=
    per_per_shd.g_old_rec.per_information1;
  End If;
  If (p_rec.per_information2 = hr_api.g_varchar2) then
    p_rec.per_information2 :=
    per_per_shd.g_old_rec.per_information2;
  End If;
  If (p_rec.per_information3 = hr_api.g_varchar2) then
    p_rec.per_information3 :=
    per_per_shd.g_old_rec.per_information3;
  End If;
  If (p_rec.per_information4 = hr_api.g_varchar2) then
    p_rec.per_information4 :=
    per_per_shd.g_old_rec.per_information4;
  End If;
  If (p_rec.per_information5 = hr_api.g_varchar2) then
    p_rec.per_information5 :=
    per_per_shd.g_old_rec.per_information5;
  End If;
  If (p_rec.per_information6 = hr_api.g_varchar2) then
    p_rec.per_information6 :=
    per_per_shd.g_old_rec.per_information6;
  End If;
  If (p_rec.per_information7 = hr_api.g_varchar2) then
    p_rec.per_information7 :=
    per_per_shd.g_old_rec.per_information7;
  End If;
  If (p_rec.per_information8 = hr_api.g_varchar2) then
    p_rec.per_information8 :=
    per_per_shd.g_old_rec.per_information8;
  End If;
  If (p_rec.per_information9 = hr_api.g_varchar2) then
    p_rec.per_information9 :=
    per_per_shd.g_old_rec.per_information9;
  End If;
  If (p_rec.per_information10 = hr_api.g_varchar2) then
    p_rec.per_information10 :=
    per_per_shd.g_old_rec.per_information10;
  End If;
  If (p_rec.per_information11 = hr_api.g_varchar2) then
    p_rec.per_information11 :=
    per_per_shd.g_old_rec.per_information11;
  End If;
  If (p_rec.per_information12 = hr_api.g_varchar2) then
    p_rec.per_information12 :=
    per_per_shd.g_old_rec.per_information12;
  End If;
  If (p_rec.per_information13 = hr_api.g_varchar2) then
    p_rec.per_information13 :=
    per_per_shd.g_old_rec.per_information13;
  End If;
  If (p_rec.per_information14 = hr_api.g_varchar2) then
    p_rec.per_information14 :=
    per_per_shd.g_old_rec.per_information14;
  End If;
  If (p_rec.per_information15 = hr_api.g_varchar2) then
    p_rec.per_information15 :=
    per_per_shd.g_old_rec.per_information15;
  End If;
  If (p_rec.per_information16 = hr_api.g_varchar2) then
    p_rec.per_information16 :=
    per_per_shd.g_old_rec.per_information16;
  End If;
  If (p_rec.per_information17 = hr_api.g_varchar2) then
    p_rec.per_information17 :=
    per_per_shd.g_old_rec.per_information17;
  End If;
  If (p_rec.per_information18 = hr_api.g_varchar2) then
    p_rec.per_information18 :=
    per_per_shd.g_old_rec.per_information18;
  End If;
  If (p_rec.per_information19 = hr_api.g_varchar2) then
    p_rec.per_information19 :=
    per_per_shd.g_old_rec.per_information19;
  End If;
  If (p_rec.per_information20 = hr_api.g_varchar2) then
    p_rec.per_information20 :=
    per_per_shd.g_old_rec.per_information20;
  End If;
  If (p_rec.suffix = hr_api.g_varchar2) then
    p_rec.suffix := per_per_shd.g_old_rec.suffix;
  End If;
  If (p_rec.DATE_OF_DEATH           = hr_api.g_date) then
    p_rec.DATE_OF_DEATH           := per_per_shd.g_old_rec.DATE_OF_DEATH           ;
  End If;
  If (p_rec.BACKGROUND_CHECK_STATUS = hr_api.g_varchar2) then
    p_rec.BACKGROUND_CHECK_STATUS := per_per_shd.g_old_rec.BACKGROUND_CHECK_STATUS ;
  End If;
  If (p_rec.BACKGROUND_DATE_CHECK   = hr_api.g_date) then
    p_rec.BACKGROUND_DATE_CHECK   := per_per_shd.g_old_rec.BACKGROUND_DATE_CHECK   ;
  End If;
  If (p_rec.BLOOD_TYPE              = hr_api.g_varchar2) then
    p_rec.BLOOD_TYPE              := per_per_shd.g_old_rec.BLOOD_TYPE              ;
  End If;
  If (p_rec.CORRESPONDENCE_LANGUAGE = hr_api.g_varchar2) then
    p_rec.CORRESPONDENCE_LANGUAGE := per_per_shd.g_old_rec.CORRESPONDENCE_LANGUAGE ;
  End If;
  If (p_rec.FAST_PATH_EMPLOYEE      = hr_api.g_varchar2) then
    p_rec.FAST_PATH_EMPLOYEE      := per_per_shd.g_old_rec.FAST_PATH_EMPLOYEE      ;
  End If;
  If (p_rec.FTE_CAPACITY            = hr_api.g_number) then
    p_rec.FTE_CAPACITY            := per_per_shd.g_old_rec.FTE_CAPACITY            ;
  End If;
  If (p_rec.HOLD_APPLICANT_DATE_UNTIL = hr_api.g_date) then
    p_rec.HOLD_APPLICANT_DATE_UNTIL := per_per_shd.g_old_rec.HOLD_APPLICANT_DATE_UNTIL;
  End If;
  If (p_rec.HONORS                  = hr_api.g_varchar2) then
    p_rec.HONORS                  := per_per_shd.g_old_rec.HONORS                  ;
  End If;
  If (p_rec.INTERNAL_LOCATION       = hr_api.g_varchar2) then
    p_rec.INTERNAL_LOCATION       := per_per_shd.g_old_rec.INTERNAL_LOCATION       ;
  End If;
  If (p_rec.LAST_MEDICAL_TEST_BY    = hr_api.g_varchar2) then
    p_rec.LAST_MEDICAL_TEST_BY    := per_per_shd.g_old_rec.LAST_MEDICAL_TEST_BY    ;
  End If;
  If (p_rec.LAST_MEDICAL_TEST_DATE  = hr_api.g_date) then
    p_rec.LAST_MEDICAL_TEST_DATE  := per_per_shd.g_old_rec.LAST_MEDICAL_TEST_DATE  ;
  End If;
  If (p_rec.MAILSTOP                = hr_api.g_varchar2) then
    p_rec.MAILSTOP                := per_per_shd.g_old_rec.MAILSTOP                ;
  End If;
  If (p_rec.OFFICE_NUMBER           = hr_api.g_varchar2) then
    p_rec.OFFICE_NUMBER           := per_per_shd.g_old_rec.OFFICE_NUMBER           ;
  End If;
  If (p_rec.ON_MILITARY_SERVICE     = hr_api.g_varchar2) then
    p_rec.ON_MILITARY_SERVICE     := per_per_shd.g_old_rec.ON_MILITARY_SERVICE     ;
  End If;
  If (p_rec.ORDER_NAME              = hr_api.g_varchar2) then
    p_rec.ORDER_NAME              := per_per_shd.g_old_rec.ORDER_NAME              ;
  End If;
  If (p_rec.PRE_NAME_ADJUNCT        = hr_api.g_varchar2) then
    p_rec.PRE_NAME_ADJUNCT        := per_per_shd.g_old_rec.PRE_NAME_ADJUNCT        ;
  End If;
  If (p_rec.PROJECTED_START_DATE    = hr_api.g_date) then
    p_rec.PROJECTED_START_DATE    := per_per_shd.g_old_rec.PROJECTED_START_DATE    ;
  End If;
  If (p_rec.REHIRE_AUTHORIZOR       = hr_api.g_varchar2) then
    p_rec.REHIRE_AUTHORIZOR       := per_per_shd.g_old_rec.REHIRE_AUTHORIZOR       ;
  End If;
  If (p_rec.REHIRE_RECOMMENDATION   = hr_api.g_varchar2) then
    p_rec.REHIRE_RECOMMENDATION   := per_per_shd.g_old_rec.REHIRE_RECOMMENDATION   ;
  End If;
  If (p_rec.RESUME_EXISTS           = hr_api.g_varchar2) then
    p_rec.RESUME_EXISTS           := per_per_shd.g_old_rec.RESUME_EXISTS           ;
  End If;
  If (p_rec.RESUME_LAST_UPDATED     = hr_api.g_date) then
    p_rec.RESUME_LAST_UPDATED     := per_per_shd.g_old_rec.RESUME_LAST_UPDATED     ;
  End If;
  If (p_rec.SECOND_PASSPORT_EXISTS  = hr_api.g_varchar2) then
    p_rec.SECOND_PASSPORT_EXISTS  := per_per_shd.g_old_rec.SECOND_PASSPORT_EXISTS  ;
  End If;
  If (p_rec.STUDENT_STATUS          = hr_api.g_varchar2) then
    p_rec.STUDENT_STATUS          := per_per_shd.g_old_rec.STUDENT_STATUS          ;
  End If;
  If (p_rec.WORK_SCHEDULE           = hr_api.g_varchar2) then
    p_rec.WORK_SCHEDULE           := per_per_shd.g_old_rec.WORK_SCHEDULE           ;
  End If;
  If (p_rec.PER_INFORMATION21       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION21       := per_per_shd.g_old_rec.PER_INFORMATION21       ;
  End If;
  If (p_rec.PER_INFORMATION22       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION22       := per_per_shd.g_old_rec.PER_INFORMATION22       ;
  End If;
  If (p_rec.PER_INFORMATION23       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION23       := per_per_shd.g_old_rec.PER_INFORMATION23       ;
  End If;
  If (p_rec.PER_INFORMATION24       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION24       := per_per_shd.g_old_rec.PER_INFORMATION24       ;
  End If;
  If (p_rec.PER_INFORMATION25       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION25       := per_per_shd.g_old_rec.PER_INFORMATION25       ;
  End If;
  If (p_rec.PER_INFORMATION26       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION26       := per_per_shd.g_old_rec.PER_INFORMATION26       ;
  End If;
  If (p_rec.PER_INFORMATION27       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION27       := per_per_shd.g_old_rec.PER_INFORMATION27       ;
  End If;
  If (p_rec.PER_INFORMATION28       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION28       := per_per_shd.g_old_rec.PER_INFORMATION28       ;
  End If;
  If (p_rec.PER_INFORMATION29       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION29       := per_per_shd.g_old_rec.PER_INFORMATION29       ;
  End If;
  If (p_rec.PER_INFORMATION30       = hr_api.g_varchar2) then
    p_rec.PER_INFORMATION30       := per_per_shd.g_old_rec.PER_INFORMATION30       ;
  End If;
  If (p_rec.REHIRE_REASON           = hr_api.g_varchar2) then
    p_rec.REHIRE_REASON           := per_per_shd.g_old_rec.REHIRE_REASON           ;
  End If;
  If (p_rec.BENEFIT_GROUP_ID       = hr_api.g_number) then
    p_rec.BENEFIT_GROUP_ID        := per_per_shd.g_old_rec.BENEFIT_GROUP_ID        ;
  End If;
  If (p_rec.RECEIPT_OF_DEATH_CERT_DATE = hr_api.g_date) then
    p_rec.RECEIPT_OF_DEATH_CERT_DATE := per_per_shd.g_old_rec.RECEIPT_OF_DEATH_CERT_DATE ;
  End If;
  If (p_rec.COORD_BEN_MED_PLN_NO   = hr_api.g_varchar2) then
    p_rec.COORD_BEN_MED_PLN_NO    := per_per_shd.g_old_rec.COORD_BEN_MED_PLN_NO    ;
  End If;
  If (p_rec.COORD_BEN_NO_CVG_FLAG  = hr_api.g_varchar2) then
    p_rec.COORD_BEN_NO_CVG_FLAG   := per_per_shd.g_old_rec.COORD_BEN_NO_CVG_FLAG   ;
  End If;
  if (p_rec.COORD_BEN_MED_EXT_ER = hr_api.g_varchar2) then
    p_rec.COORD_BEN_MED_EXT_ER:= per_per_shd.g_old_rec.COORD_BEN_MED_EXT_ER;
  end if;
  if (p_rec.COORD_BEN_MED_PL_NAME = hr_api.g_varchar2) then
    p_rec.COORD_BEN_MED_PL_NAME:= per_per_shd.g_old_rec.COORD_BEN_MED_PL_NAME;
  end if;
  if (p_rec.COORD_BEN_MED_INSR_CRR_NAME = hr_api.g_varchar2) then
    p_rec.COORD_BEN_MED_INSR_CRR_NAME:= per_per_shd.g_old_rec.COORD_BEN_MED_INSR_CRR_NAME;
  end if;
  if (p_rec.COORD_BEN_MED_INSR_CRR_IDENT = hr_api.g_varchar2) then
    p_rec.COORD_BEN_MED_INSR_CRR_IDENT:= per_per_shd.g_old_rec.COORD_BEN_MED_INSR_CRR_IDENT;
  end if;
  if (p_rec.COORD_BEN_MED_CVG_STRT_DT = hr_api.g_date) then
    p_rec.COORD_BEN_MED_CVG_STRT_DT:= per_per_shd.g_old_rec.COORD_BEN_MED_CVG_STRT_DT;
  end if;
  if (p_rec.COORD_BEN_MED_CVG_END_DT  = hr_api.g_date) then
    p_rec.COORD_BEN_MED_CVG_END_DT  := per_per_shd.g_old_rec.COORD_BEN_MED_CVG_END_DT;
  end if;
  If (p_rec.USES_TOBACCO_FLAG      = hr_api.g_varchar2) then
    p_rec.USES_TOBACCO_FLAG       := per_per_shd.g_old_rec.USES_TOBACCO_FLAG       ;
  End If;
  If (p_rec.DPDNT_ADOPTION_DATE    = hr_api.g_date) then
    p_rec.DPDNT_ADOPTION_DATE     := per_per_shd.g_old_rec.DPDNT_ADOPTION_DATE     ;
  End If;
  If (p_rec.DPDNT_VLNTRY_SVCE_FLAG = hr_api.g_varchar2) then
    p_rec.DPDNT_VLNTRY_SVCE_FLAG  := per_per_shd.g_old_rec.DPDNT_VLNTRY_SVCE_FLAG  ;
  End If;
  If (p_rec.ORIGINAL_DATE_OF_HIRE = hr_api.g_date) then
    p_rec.ORIGINAL_DATE_OF_HIRE   := per_per_shd.g_old_rec.ORIGINAL_DATE_OF_HIRE   ;
  End If;
  If (p_rec.town_of_birth = hr_api.g_varchar2) then
    p_rec.town_of_birth   := per_per_shd.g_old_rec.town_of_birth   ;
  End If;
  If (p_rec.region_of_birth = hr_api.g_varchar2) then
    p_rec.region_of_birth   := per_per_shd.g_old_rec.region_of_birth   ;
  End If;
  If (p_rec.country_of_birth = hr_api.g_varchar2) then
    p_rec.country_of_birth   := per_per_shd.g_old_rec.country_of_birth   ;
  End If;
  If (p_rec.global_person_id = hr_api.g_varchar2) then
    p_rec.global_person_id   := per_per_shd.g_old_rec.global_person_id   ;
  End If;
  If (p_rec.party_id = hr_api.g_number) then
    p_rec.party_id   := per_per_shd.g_old_rec.party_id   ;
  End If;
  If (p_rec.npw_number = hr_api.g_varchar2) then
    p_rec.npw_number   := per_per_shd.g_old_rec.npw_number   ;
  End If;
  If (p_rec.current_npw_flag = hr_api.g_varchar2) then
    p_rec.current_npw_flag   := per_per_shd.g_old_rec.current_npw_flag   ;
  End If;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy  per_per_shd.g_rec_type,
  p_effective_date   in    date,
  p_datetrack_mode   in    varchar2,
  p_validate      in    boolean default false,
  p_name_combination_warning out nocopy boolean,
  p_dob_null_warning out nocopy boolean,
  p_orig_hire_warning  out nocopy boolean
  ) is
--
  l_proc       varchar2(72) := g_package||'upd';
  l_validation_start_date  date;
  l_validation_end_date    date;
  l_name_combination_warning    boolean;
  l_dob_null_warning            boolean;
  l_orig_hire_warning           boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_per_per;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_per_shd.lck
   (p_effective_date  => p_effective_date,
          p_datetrack_mode  => p_datetrack_mode,
          p_person_id    => p_rec.person_id,
          p_object_version_number => p_rec.object_version_number,
          p_validation_start_date => l_validation_start_date,
          p_validation_end_date   => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  --
  per_per_bus.update_validate
-- (p_rec          => p_rec,
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode     => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,

    p_validation_end_date   => l_validation_end_date,
         p_name_combination_warning => l_name_combination_warning,
         p_dob_null_warning         => l_dob_null_warning,
         p_orig_hire_warning        => l_orig_hire_warning);
  --
  -- Call the supporting pre-update operation
  hr_multi_message.end_validation_set;
  --
  pre_update
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date,
         p_name_combination_warning => l_name_combination_warning,
         p_dob_null_warning         => l_dob_null_warning,
         p_orig_hire_warning        => l_orig_hire_warning);
  --
  hr_multi_message.end_validation_set;
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  -- Set output arguments
  --
  p_name_combination_warning  := l_name_combination_warning;
  p_dob_null_warning          := l_dob_null_warning;
  p_orig_hire_warning         := l_orig_hire_warning;
--
if l_name_combination_warning = FALSE then
  hr_utility.set_location(l_proc,990);
elsif l_name_combination_warning = TRUE then
  hr_utility.set_location(l_proc,991);
else
  hr_utility.set_location(l_proc,992);
end if;
  --
if l_orig_hire_warning = FALSE then
  hr_utility.set_location(l_proc,993);
elsif l_orig_hire_warning = TRUE then
  hr_utility.set_location(l_proc,994);
else hr_utility.set_location(l_proc,995);
end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_per_per;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_person_id                    in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_person_type_id               in number           default hr_api.g_number,
  p_last_name                    in varchar2         default hr_api.g_varchar2,
  p_start_date                   in date             default hr_api.g_date,
  p_applicant_number             in out nocopy varchar2,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_current_applicant_flag       out nocopy varchar2,
  p_current_emp_or_apl_flag      out nocopy varchar2,
  p_current_employee_flag        out nocopy varchar2,
  p_date_employee_data_verified  in date             default hr_api.g_date,
  p_date_of_birth                in date             default hr_api.g_date,
  p_email_address                in varchar2         default hr_api.g_varchar2,
  p_employee_number              in out nocopy varchar2,
  p_expense_check_send_to_addres in varchar2         default hr_api.g_varchar2,
  p_first_name                   in varchar2         default hr_api.g_varchar2,
  p_full_name                    out nocopy varchar2,
  p_known_as                     in varchar2         default hr_api.g_varchar2,
  p_marital_status               in varchar2         default hr_api.g_varchar2,
  p_middle_names                 in varchar2         default hr_api.g_varchar2,
  p_nationality                  in varchar2         default hr_api.g_varchar2,
  p_national_identifier          in varchar2         default hr_api.g_varchar2,
  p_previous_last_name           in varchar2         default hr_api.g_varchar2,
  p_registered_disabled_flag     in varchar2         default hr_api.g_varchar2,
  p_sex                          in varchar2         default hr_api.g_varchar2,
  p_title                        in varchar2         default hr_api.g_varchar2,
  p_vendor_id                    in number           default hr_api.g_number,
  p_work_telephone               in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_per_information_category     in varchar2         default hr_api.g_varchar2,
  p_per_information1             in varchar2         default hr_api.g_varchar2,
  p_per_information2             in varchar2         default hr_api.g_varchar2,
  p_per_information3             in varchar2         default hr_api.g_varchar2,
  p_per_information4             in varchar2         default hr_api.g_varchar2,
  p_per_information5             in varchar2         default hr_api.g_varchar2,
  p_per_information6             in varchar2         default hr_api.g_varchar2,
  p_per_information7             in varchar2         default hr_api.g_varchar2,
  p_per_information8             in varchar2         default hr_api.g_varchar2,
  p_per_information9             in varchar2         default hr_api.g_varchar2,
  p_per_information10            in varchar2         default hr_api.g_varchar2,
  p_per_information11            in varchar2         default hr_api.g_varchar2,
  p_per_information12            in varchar2         default hr_api.g_varchar2,
  p_per_information13            in varchar2         default hr_api.g_varchar2,
  p_per_information14            in varchar2         default hr_api.g_varchar2,
  p_per_information15            in varchar2         default hr_api.g_varchar2,
  p_per_information16            in varchar2         default hr_api.g_varchar2,
  p_per_information17            in varchar2         default hr_api.g_varchar2,
  p_per_information18            in varchar2         default hr_api.g_varchar2,
  p_per_information19            in varchar2         default hr_api.g_varchar2,
  p_per_information20            in varchar2         default hr_api.g_varchar2,
  p_suffix                       in varchar2         default hr_api.g_varchar2,
  p_DATE_OF_DEATH                in date             default hr_api.g_date,
  p_BACKGROUND_CHECK_STATUS      in varchar2         default hr_api.g_varchar2,
  p_BACKGROUND_DATE_CHECK        in date             default hr_api.g_date,
  p_BLOOD_TYPE                   in varchar2         default hr_api.g_varchar2,
  p_CORRESPONDENCE_LANGUAGE      in varchar2         default hr_api.g_varchar2,
  p_FAST_PATH_EMPLOYEE           in varchar2         default hr_api.g_varchar2,
  p_FTE_CAPACITY                 in number           default hr_api.g_number,
  p_HOLD_APPLICANT_DATE_UNTIL    in date             default hr_api.g_date,
  p_HONORS                       in varchar2         default hr_api.g_varchar2,
  p_INTERNAL_LOCATION            in varchar2         default hr_api.g_varchar2,
  p_LAST_MEDICAL_TEST_BY         in varchar2         default hr_api.g_varchar2,
  p_LAST_MEDICAL_TEST_DATE       in date             default hr_api.g_date,
  p_MAILSTOP                     in varchar2         default hr_api.g_varchar2,
  p_OFFICE_NUMBER                in varchar2         default hr_api.g_varchar2,
  p_ON_MILITARY_SERVICE          in varchar2         default hr_api.g_varchar2,
  p_ORDER_NAME                   in varchar2         default hr_api.g_varchar2,
  p_PRE_NAME_ADJUNCT             in varchar2         default hr_api.g_varchar2,
  p_PROJECTED_START_DATE         in date             default hr_api.g_date,
  p_REHIRE_AUTHORIZOR            in varchar2         default hr_api.g_varchar2,
  p_REHIRE_RECOMMENDATION        in varchar2         default hr_api.g_varchar2,
  p_RESUME_EXISTS                in varchar2         default hr_api.g_varchar2,
  p_RESUME_LAST_UPDATED          in date             default hr_api.g_date,
  p_SECOND_PASSPORT_EXISTS       in varchar2         default hr_api.g_varchar2,
  p_STUDENT_STATUS               in varchar2         default hr_api.g_varchar2,
  p_WORK_SCHEDULE                in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION21            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION22            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION23            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION24            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION25            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION26            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION27            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION28            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION29            in varchar2         default hr_api.g_varchar2,
  p_PER_INFORMATION30            in varchar2         default hr_api.g_varchar2,
  p_REHIRE_REASON                in varchar2         default hr_api.g_varchar2,
  p_BENEFIT_GROUP_ID             in number           default hr_api.g_number,
  p_RECEIPT_OF_DEATH_CERT_DATE   in date             default hr_api.g_date,
  p_COORD_BEN_MED_PLN_NO         in varchar2         default hr_api.g_varchar2,
  p_COORD_BEN_NO_CVG_FLAG        in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_ext_er         in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_pl_name        in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_insr_crr_name  in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_insr_crr_ident in varchar2         default hr_api.g_varchar2,
  p_coord_ben_med_cvg_strt_dt    in date             default hr_api.g_date,
  p_coord_ben_med_cvg_end_dt     in date             default hr_api.g_date,
  p_USES_TOBACCO_FLAG            in varchar2         default hr_api.g_varchar2,
  p_DPDNT_ADOPTION_DATE          in date             default hr_api.g_date,
  p_DPDNT_VLNTRY_SVCE_FLAG       in varchar2         default hr_api.g_varchar2,
  p_ORIGINAL_DATE_OF_HIRE        in date             default hr_api.g_date,
  p_town_of_birth                in varchar2         default hr_api.g_varchar2,
  p_region_of_birth              in varchar2         default hr_api.g_varchar2,
  p_country_of_birth             in varchar2         default hr_api.g_varchar2,
  p_global_person_id             in varchar2         default hr_api.g_varchar2,
  p_party_id                     in number           default hr_api.g_number,
  p_npw_number                   in out nocopy varchar2,
  p_current_npw_flag             in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date       in date,
  p_datetrack_mode       in varchar2,
  p_validate          in boolean          default false,
  p_name_combination_warning     out nocopy boolean,
  p_dob_null_warning             out nocopy boolean,
  p_orig_hire_warning            out nocopy boolean
  ) is
--
  l_rec     per_per_shd.g_rec_type;
  l_proc varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_per_shd.convert_args
  (
  p_person_id,
  null,
  null,
  hr_api.g_number,
  p_person_type_id,
  p_last_name,
  p_start_date,
  p_applicant_number,
  hr_api.g_number,
  p_comments,
  hr_api.g_varchar2,
  hr_api.g_varchar2,
  hr_api.g_varchar2,
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
  p_object_version_number,
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
  p_town_of_birth                   ,
  p_region_of_birth                 ,
  p_country_of_birth                ,
  p_global_person_id                ,
  p_party_id                        ,
  p_npw_number                      ,
  p_current_npw_flag                ,
  null                              ,  -- global_name
  null                                 -- local_name
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode, p_validate,
      p_name_combination_warning,p_dob_null_warning, p_orig_hire_warning);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  p_employee_number             := l_rec.employee_number;
  p_applicant_number            := l_rec.applicant_number;
  p_comment_id                  := l_rec.comment_id;
  p_current_applicant_flag      := l_rec.current_applicant_flag;
  p_current_emp_or_apl_flag     := l_rec.current_emp_or_apl_flag;
  p_current_employee_flag       := l_rec.current_employee_flag;
  p_full_name                   := l_rec.full_name;
  p_npw_number                  := l_rec.npw_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_per_upd;

/
