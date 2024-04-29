--------------------------------------------------------
--  DDL for Package Body PER_PER_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PER_DEL" as
/* $Header: peperrhi.pkb 120.14.12010000.5 2009/08/17 12:07:47 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_per_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
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
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    per_per_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from per_all_people_f
    where       person_id = p_rec.person_id
    and    effective_start_date = p_validation_start_date;
    --
    per_per_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    per_per_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from per_all_people_f
    where        person_id = p_rec.person_id
    and    effective_start_date >= p_validation_start_date;
    --
    per_per_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    per_per_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec         => p_rec,
      p_effective_date  => p_effective_date,
      p_datetrack_mode  => p_datetrack_mode,
            p_validation_start_date => p_validation_start_date,
      p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   If (p_datetrack_mode <> 'ZAP') then
     --
     p_rec.effective_start_date :=
        per_per_shd.g_old_rec.effective_start_date;
     --
     If (p_datetrack_mode = 'DELETE') then
       p_rec.effective_end_date := p_validation_start_date - 1;
     Else
       p_rec.effective_end_date := p_validation_end_date;
   End If;
     --
     -- Update the current effective end date record
     --
     per_per_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date,
       p_base_key_value         => p_rec.person_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date  => p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
   Else
     p_rec.effective_start_date := null;
     p_rec.effective_end_date := null;
   End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) := g_package||'pre_delete';
--
  l_per_rec per_all_people_f%rowtype;
  cursor l_per_cur is
    select *
    from  per_all_people_f
    where person_id            = p_rec.person_id
    and   effective_start_date = p_rec.effective_start_date
    and   effective_end_date   = p_rec.effective_end_date;

/* Cursor l_per_cur1 created as part of fix for bug 4610184.
   Created a new cursor considering the performance issue if we use
   nvl statement in Cussor l_per_cur. */

  cursor l_per_cur1 is
    select *
    from  per_all_people_f
    where person_id            = p_rec.person_id;
  --
  -- Cursor C_Sel1 select comments to be deleted
  --
  Cursor C_Sel1 is
    select t1.comment_id
    from   per_all_people_f t1
    where  t1.comment_id is not null
    and    t1.person_id = p_rec.person_id
    and    t1.effective_start_date <= p_validation_end_date
    and    t1.effective_end_date   >= p_validation_start_date
    and    not exists
           (select 1
            from   per_all_people_f t2
            where  t2.comment_id = t1.comment_id
            and    t2.person_id = t1.person_id
            and   (t2.effective_start_date > p_validation_end_date
             or    t2.effective_end_date   < p_validation_start_date));
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete any possible comments
  --
  For Comm_Del In C_Sel1 Loop
    hr_comm_api.del(p_comment_id        => Comm_Del.comment_id);
  End Loop;
  --
  dt_pre_delete
    (p_rec          => p_rec,
     p_effective_date        => p_effective_date,
     p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  -- Start of HR/WF Synchronization

  --fix for bug 4610184 starts here.

   if (p_rec.effective_start_date is null or p_rec.effective_end_date is null) then

    open l_per_cur1;
    fetch l_per_cur1 into l_per_rec;
    close l_per_cur1;

   else

    open l_per_cur;
    fetch l_per_cur into l_per_rec;
    close l_per_cur;

   end if;

  --fix for bug 4610184 ends here.
    --
    per_hrwf_synch.per_per_wf(
                   p_rec       => l_per_rec,
                   p_action    => 'DELETE');
  -- End of HR/WF Synchronization
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
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
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
   (p_rec          in per_per_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  begin
    per_per_rkd.after_delete
      (p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      ,p_datetrack_mode            => p_datetrack_mode
      ,p_person_id                 => p_rec.person_id
      ,p_effective_start_date      => p_rec.effective_start_date
      ,p_effective_end_date        => p_rec.effective_end_date
      ,p_object_version_number     => p_rec.object_version_number
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
        ,p_hook_type   => 'AD'
        );
  end;
  -- End of API User Hook for post_delete.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec        in out nocopy  per_per_shd.g_rec_type,
  p_effective_date   in    date,
  p_datetrack_mode   in    varchar2,
  p_validate         in    boolean default false
  ) is
--
  l_proc       varchar2(72) := g_package||'del';
  l_validation_start_date  date;
  l_validation_end_date    date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_per_per;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  per_per_shd.lck
   (p_effective_date  => p_effective_date,
          p_datetrack_mode  => p_datetrack_mode,
          p_person_id    => p_rec.person_id,
          p_object_version_number => p_rec.object_version_number,
          p_validation_start_date => l_validation_start_date,
          p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  per_per_bus.delete_validate
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  hr_multi_message.end_validation_set;
  -- Call the supporting pre-delete operation
  --
  pre_delete
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  hr_multi_message.end_validation_set;
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
    ROLLBACK TO del_per_per;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_person_id   in   number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date       out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date     in     date,
  p_datetrack_mode     in     varchar2,
  p_validate        in     boolean default false
  ) is
--
  l_rec     per_per_shd.g_rec_type;
  l_proc varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.person_id    := p_person_id;
  l_rec.object_version_number    := p_object_version_number;
  --
  -- Having converted the arguments into the per_per_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode, p_validate);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_per_del;

/
