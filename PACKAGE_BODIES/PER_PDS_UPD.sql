--------------------------------------------------------
--  DDL for Package Body PER_PDS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDS_UPD" as
/* $Header: pepdsrhi.pkb 120.7.12010000.2 2009/07/15 10:28:27 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pds_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure update_dml(p_rec in out nocopy per_pds_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  per_pds_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_periods_of_service Row
  --
  update per_periods_of_service
  set
  period_of_service_id              = p_rec.period_of_service_id,
  termination_accepted_person_id    = p_rec.termination_accepted_person_id,
  date_start                        = p_rec.date_start,
  accepted_termination_date         = p_rec.accepted_termination_date,
  actual_termination_date           = p_rec.actual_termination_date,
  comments                          = p_rec.comments,
  final_process_date                = p_rec.final_process_date,
  last_standard_process_date        = p_rec.last_standard_process_date,
  leaving_reason                    = p_rec.leaving_reason,
  notified_termination_date         = p_rec.notified_termination_date,
  projected_termination_date        = p_rec.projected_termination_date,
  adjusted_svc_date                 = p_rec.adjusted_svc_date,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  attribute_category                = p_rec.attribute_category,
  attribute1                        = p_rec.attribute1,
  attribute2                        = p_rec.attribute2,
  attribute3                        = p_rec.attribute3,
  attribute4                        = p_rec.attribute4,
  attribute5                        = p_rec.attribute5,
  attribute6                        = p_rec.attribute6,
  attribute7                        = p_rec.attribute7,
  attribute8                        = p_rec.attribute8,
  attribute9                        = p_rec.attribute9,
  attribute10                       = p_rec.attribute10,
  attribute11                       = p_rec.attribute11,
  attribute12                       = p_rec.attribute12,
  attribute13                       = p_rec.attribute13,
  attribute14                       = p_rec.attribute14,
  attribute15                       = p_rec.attribute15,
  attribute16                       = p_rec.attribute16,
  attribute17                       = p_rec.attribute17,
  attribute18                       = p_rec.attribute18,
  attribute19                       = p_rec.attribute19,
  attribute20                       = p_rec.attribute20,
  object_version_number             = p_rec.object_version_number ,
  prior_employment_ssp_weeks        = p_rec.prior_employment_ssp_weeks,
  prior_employment_ssp_paid_to      = p_rec.prior_employment_ssp_paid_to,
  pds_information_category          = p_rec.pds_information_category,
  pds_information1                  = p_rec.pds_information1,
  pds_information2                  = p_rec.pds_information2,
  pds_information3                  = p_rec.pds_information3,
  pds_information4                  = p_rec.pds_information4,
  pds_information5                  = p_rec.pds_information5,
  pds_information6                  = p_rec.pds_information6,
  pds_information7                  = p_rec.pds_information7,
  pds_information8                  = p_rec.pds_information8,
  pds_information9                  = p_rec.pds_information9,
  pds_information10                 = p_rec.pds_information10,
  pds_information11                 = p_rec.pds_information11,
  pds_information12                 = p_rec.pds_information12,
  pds_information13                 = p_rec.pds_information13,
  pds_information14                 = p_rec.pds_information14,
  pds_information15                 = p_rec.pds_information15,
  pds_information16                 = p_rec.pds_information16,
  pds_information17                 = p_rec.pds_information17,
  pds_information18                 = p_rec.pds_information18,
  pds_information19                 = p_rec.pds_information19,
  pds_information20                 = p_rec.pds_information20,
  pds_information21                 = p_rec.pds_information21,
  pds_information22                 = p_rec.pds_information22,
  pds_information23                 = p_rec.pds_information23,
  pds_information24                 = p_rec.pds_information24,
  pds_information25                 = p_rec.pds_information25,
  pds_information26                 = p_rec.pds_information26,
  pds_information27                 = p_rec.pds_information27,
  pds_information28                 = p_rec.pds_information28,
  pds_information29                 = p_rec.pds_information29,
  pds_information30                 = p_rec.pds_information30
  where period_of_service_id = p_rec.period_of_service_id;
  --
  per_pds_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
    per_pds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
    per_pds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
    per_pds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
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
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in per_pds_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
Procedure post_update(p_rec in per_pds_shd.g_rec_type,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_update';
  l_rowid varchar2(72);
--
--
-- START WWBUG 1390173 fix
--
  l_old   ben_pps_ler.g_pps_ler_rec;
  l_new   ben_pps_ler.g_pps_ler_rec;
  --
--
-- END WWBUG 1390173 fix
--
cursor csr_rowid is
select rowid
from per_periods_of_service
where period_of_service_id = p_rec.period_of_service_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- GP
  --
  -- BEGIN of FIX for WWBUG 1390173
  --
  -- Revise this fix so that when processing from within the
  -- combined terminate_employee BSP the LER processing at the
  -- PDS level is masked and performed once at the end of the terminate.
  -- This is a fix to bug 2344139.
  --
  if hr_ex_employee_internal.g_mask_pds_ler = FALSE then
    l_old.PERSON_ID := per_pds_shd.g_old_rec.person_id;
    l_old.BUSINESS_GROUP_ID := per_pds_shd.g_old_rec.business_group_id;
    l_old.DATE_START := per_pds_shd.g_old_rec.date_start;
    l_old.ACTUAL_TERMINATION_DATE := per_pds_shd.g_old_rec.actual_termination_date;
    l_old.LEAVING_REASON := per_pds_shd.g_old_rec.leaving_reason;
    l_old.ADJUSTED_SVC_DATE := per_pds_shd.g_old_rec.adjusted_svc_date;
    l_old.ATTRIBUTE1 := per_pds_shd.g_old_rec.attribute1;
    l_old.ATTRIBUTE2 := per_pds_shd.g_old_rec.attribute2;
    l_old.ATTRIBUTE3 := per_pds_shd.g_old_rec.attribute3;
    l_old.ATTRIBUTE4 := per_pds_shd.g_old_rec.attribute4;
    l_old.ATTRIBUTE5 := per_pds_shd.g_old_rec.attribute5;
    l_old.FINAL_PROCESS_DATE := per_pds_shd.g_old_rec.FINAL_PROCESS_DATE;
    l_new.PERSON_ID := p_rec.person_id;
    l_new.BUSINESS_GROUP_ID := p_rec.business_group_id;
    l_new.DATE_START := p_rec.date_start;
    l_new.ACTUAL_TERMINATION_DATE := p_rec.actual_termination_date;
    l_new.LEAVING_REASON := p_rec.leaving_reason;
    l_new.ADJUSTED_SVC_DATE := p_rec.adjusted_svc_date;
    l_new.ATTRIBUTE1 := p_rec.attribute1;
    l_new.ATTRIBUTE2 := p_rec.attribute2;
    l_new.ATTRIBUTE3 := p_rec.attribute3;
    l_new.ATTRIBUTE4 := p_rec.attribute4;
    l_new.ATTRIBUTE5 := p_rec.attribute5;
    l_new.FINAL_PROCESS_DATE := p_rec.FINAL_PROCESS_DATE;
    --
    hr_utility.set_location('OLD ATD'||l_old.actual_termination_date,10);
    hr_utility.set_location('NEW ATD'||l_new.actual_termination_date,10);
    hr_utility.set_location('EFFDATE'||p_effective_date,10);
    --
    ben_pps_ler.ler_chk(p_old            => l_old
                       ,p_new            => l_new
                       ,p_event          => 'UPDATING'
                       ,p_effective_date => p_effective_date);
  end if;
  --
  -- END of FIX for 1390173
  --
  open csr_rowid;
  fetch csr_rowid into l_rowid;
  close csr_rowid;
  --
  ben_dt_trgr_handle.periods_of_service
    (p_rowid              => null
    ,p_person_id          => p_rec.person_id
    ,p_pds_atd            => p_rec.actual_termination_date
    ,p_pds_leaving_reason => p_rec.leaving_reason
    ,p_pds_fpd            => p_rec.final_process_date
    ,p_pds_old_atd        => per_pds_shd.g_old_rec.actual_termination_date
    );
  --
  --
  -- Start of API User Hook for post_update.
  begin
    per_pds_rku.after_update
      (
      p_period_of_service_id         =>p_rec.period_of_service_id
     ,p_termination_accepted_person  =>p_rec.termination_accepted_person_id
     ,p_date_start                   =>p_rec.date_start
     ,p_accepted_termination_date    =>p_rec.accepted_termination_date
     ,p_actual_termination_date      =>p_rec.actual_termination_date
     ,p_comments                     =>p_rec.comments
     ,p_adjusted_svc_date            =>p_rec.adjusted_svc_date
     ,p_final_process_date           =>p_rec.final_process_date
     ,p_last_standard_process_date   =>p_rec.last_standard_process_date
     ,p_leaving_reason               =>p_rec.leaving_reason
     ,p_notified_termination_date    =>p_rec.notified_termination_date
     ,p_projected_termination_date   =>p_rec.projected_termination_date
     ,p_request_id                   =>p_rec.request_id
     ,p_program_application_id       =>p_rec.program_application_id
     ,p_program_id                   =>p_rec.program_id
     ,p_program_update_date          =>p_rec.program_update_date
     ,p_attribute_category           =>p_rec.attribute_category
     ,p_attribute1                   =>p_rec.attribute1
     ,p_attribute2                   =>p_rec.attribute2
     ,p_attribute3                   =>p_rec.attribute3
     ,p_attribute4                   =>p_rec.attribute4
     ,p_attribute5                   =>p_rec.attribute5
     ,p_attribute6                   =>p_rec.attribute6
     ,p_attribute7                   =>p_rec.attribute7
     ,p_attribute8                   =>p_rec.attribute8
     ,p_attribute9                   =>p_rec.attribute9
     ,p_attribute10                  =>p_rec.attribute10
     ,p_attribute11                  =>p_rec.attribute11
     ,p_attribute12                  =>p_rec.attribute12
     ,p_attribute13                  =>p_rec.attribute13
     ,p_attribute14                  =>p_rec.attribute14
     ,p_attribute15                  =>p_rec.attribute15
     ,p_attribute16                  =>p_rec.attribute16
     ,p_attribute17                  =>p_rec.attribute17
     ,p_attribute18                  =>p_rec.attribute18
     ,p_attribute19                  =>p_rec.attribute19
     ,p_attribute20                  =>p_rec.attribute20
     ,p_object_version_number        =>p_rec.object_version_number
     ,p_prior_employment_ssp_weeks   =>p_rec.prior_employment_ssp_weeks
     ,p_prior_employment_ssp_paid_to =>p_rec.prior_employment_ssp_paid_to
     ,p_pds_information_category      =>p_rec.pds_information_category
     ,p_pds_information1              =>p_rec.pds_information1
     ,p_pds_information2              =>p_rec.pds_information2
     ,p_pds_information3              =>p_rec.pds_information3
     ,p_pds_information4              =>p_rec.pds_information4
     ,p_pds_information5              =>p_rec.pds_information5
     ,p_pds_information6              =>p_rec.pds_information6
     ,p_pds_information7              =>p_rec.pds_information7
     ,p_pds_information8              =>p_rec.pds_information8
     ,p_pds_information9              =>p_rec.pds_information9
     ,p_pds_information10             =>p_rec.pds_information10
     ,p_pds_information11             =>p_rec.pds_information11
     ,p_pds_information12             =>p_rec.pds_information12
     ,p_pds_information13             =>p_rec.pds_information13
     ,p_pds_information14             =>p_rec.pds_information14
     ,p_pds_information15             =>p_rec.pds_information15
     ,p_pds_information16             =>p_rec.pds_information16
     ,p_pds_information17             =>p_rec.pds_information17
     ,p_pds_information18             =>p_rec.pds_information18
     ,p_pds_information19             =>p_rec.pds_information19
     ,p_pds_information20             =>p_rec.pds_information20
     ,p_pds_information21             =>p_rec.pds_information21
     ,p_pds_information22             =>p_rec.pds_information22
     ,p_pds_information23             =>p_rec.pds_information23
     ,p_pds_information24             =>p_rec.pds_information24
     ,p_pds_information25             =>p_rec.pds_information25
     ,p_pds_information26             =>p_rec.pds_information26
     ,p_pds_information27             =>p_rec.pds_information27
     ,p_pds_information28             =>p_rec.pds_information28
     ,p_pds_information29             =>p_rec.pds_information29
     ,p_pds_information30             =>p_rec.pds_information30
     ,p_effective_date               =>p_effective_date
     ,p_business_group_id_o          =>per_pds_shd.g_old_rec.business_group_id
     ,p_person_id_o                  =>per_pds_shd.g_old_rec.person_id
     ,p_terminat_accepted_person_o   =>per_pds_shd.g_old_rec.termination_accepted_person_id
     ,p_date_start_o                 =>per_pds_shd.g_old_rec.date_start
     ,p_accepted_termination_date_o  =>per_pds_shd.g_old_rec.accepted_termination_date
     ,p_actual_termination_date_o    =>per_pds_shd.g_old_rec.actual_termination_date
     ,p_comments_o                   =>per_pds_shd.g_old_rec.comments
     ,p_adjusted_svc_date_o          =>per_pds_shd.g_old_rec.adjusted_svc_date
     ,p_final_process_date_o         =>per_pds_shd.g_old_rec.final_process_date
     ,p_last_standard_process_date_o =>per_pds_shd.g_old_rec.last_standard_process_date
     ,p_leaving_reason_o             =>per_pds_shd.g_old_rec.leaving_reason
     ,p_notified_termination_date_o  =>per_pds_shd.g_old_rec.notified_termination_date
     ,p_projected_termination_date_o =>per_pds_shd.g_old_rec.projected_termination_date
     ,p_request_id_o                 =>per_pds_shd.g_old_rec.request_id
     ,p_program_application_id_o     =>per_pds_shd.g_old_rec.program_application_id
     ,p_program_id_o                 =>per_pds_shd.g_old_rec.program_id
     ,p_program_update_date_o        =>per_pds_shd.g_old_rec.program_update_date
     ,p_attribute_category_o         =>per_pds_shd.g_old_rec.attribute_category
     ,p_attribute1_o                 =>per_pds_shd.g_old_rec.attribute1
     ,p_attribute2_o                 =>per_pds_shd.g_old_rec.attribute2
     ,p_attribute3_o                 =>per_pds_shd.g_old_rec.attribute3
     ,p_attribute4_o                 =>per_pds_shd.g_old_rec.attribute4
     ,p_attribute5_o                 =>per_pds_shd.g_old_rec.attribute5
     ,p_attribute6_o                 =>per_pds_shd.g_old_rec.attribute6
     ,p_attribute7_o                 =>per_pds_shd.g_old_rec.attribute7
     ,p_attribute8_o                 =>per_pds_shd.g_old_rec.attribute8
     ,p_attribute9_o                 =>per_pds_shd.g_old_rec.attribute9
     ,p_attribute10_o                =>per_pds_shd.g_old_rec.attribute10
     ,p_attribute11_o                =>per_pds_shd.g_old_rec.attribute11
     ,p_attribute12_o                =>per_pds_shd.g_old_rec.attribute12
     ,p_attribute13_o                =>per_pds_shd.g_old_rec.attribute13
     ,p_attribute14_o                =>per_pds_shd.g_old_rec.attribute14
     ,p_attribute15_o                =>per_pds_shd.g_old_rec.attribute15
     ,p_attribute16_o                =>per_pds_shd.g_old_rec.attribute16
     ,p_attribute17_o                =>per_pds_shd.g_old_rec.attribute17
     ,p_attribute18_o                =>per_pds_shd.g_old_rec.attribute18
     ,p_attribute19_o                =>per_pds_shd.g_old_rec.attribute19
     ,p_attribute20_o                =>per_pds_shd.g_old_rec.attribute20
     ,p_object_version_number_o      =>per_pds_shd.g_old_rec.object_version_number
     ,p_prior_employment_ssp_weeks_o =>per_pds_shd.g_old_rec.prior_employment_ssp_weeks
     ,p_prior_employmt_ssp_paid_to_o =>per_pds_shd.g_old_rec.prior_employment_ssp_paid_to
     ,p_pds_information_category_o    =>per_pds_shd.g_old_rec.pds_information_category
     ,p_pds_information1_o            =>per_pds_shd.g_old_rec.pds_information1
     ,p_pds_information2_o            =>per_pds_shd.g_old_rec.pds_information2
     ,p_pds_information3_o            =>per_pds_shd.g_old_rec.pds_information3
     ,p_pds_information4_o            =>per_pds_shd.g_old_rec.pds_information4
     ,p_pds_information5_o            =>per_pds_shd.g_old_rec.pds_information5
     ,p_pds_information6_o            =>per_pds_shd.g_old_rec.pds_information6
     ,p_pds_information7_o            =>per_pds_shd.g_old_rec.pds_information7
     ,p_pds_information8_o            =>per_pds_shd.g_old_rec.pds_information8
     ,p_pds_information9_o            =>per_pds_shd.g_old_rec.pds_information9
     ,p_pds_information10_o           =>per_pds_shd.g_old_rec.pds_information10
     ,p_pds_information11_o           =>per_pds_shd.g_old_rec.pds_information11
     ,p_pds_information12_o           =>per_pds_shd.g_old_rec.pds_information12
     ,p_pds_information13_o           =>per_pds_shd.g_old_rec.pds_information13
     ,p_pds_information14_o           =>per_pds_shd.g_old_rec.pds_information14
     ,p_pds_information15_o           =>per_pds_shd.g_old_rec.pds_information15
     ,p_pds_information16_o           =>per_pds_shd.g_old_rec.pds_information16
     ,p_pds_information17_o           =>per_pds_shd.g_old_rec.pds_information17
     ,p_pds_information18_o           =>per_pds_shd.g_old_rec.pds_information18
     ,p_pds_information19_o           =>per_pds_shd.g_old_rec.pds_information19
     ,p_pds_information20_o           =>per_pds_shd.g_old_rec.pds_information20
     ,p_pds_information21_o           =>per_pds_shd.g_old_rec.pds_information21
     ,p_pds_information22_o           =>per_pds_shd.g_old_rec.pds_information22
     ,p_pds_information23_o           =>per_pds_shd.g_old_rec.pds_information23
     ,p_pds_information24_o           =>per_pds_shd.g_old_rec.pds_information24
     ,p_pds_information25_o           =>per_pds_shd.g_old_rec.pds_information25
     ,p_pds_information26_o           =>per_pds_shd.g_old_rec.pds_information26
     ,p_pds_information27_o           =>per_pds_shd.g_old_rec.pds_information27
     ,p_pds_information28_o           =>per_pds_shd.g_old_rec.pds_information28
     ,p_pds_information29_o           =>per_pds_shd.g_old_rec.pds_information29
     ,p_pds_information30_o           =>per_pds_shd.g_old_rec.pds_information30
      );
--
     exception
     when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
              (
	      p_module_name => 'PER_PERIOD_OF_SERVICE',
              p_hook_type   => 'AU'
              );
  end;
--   End of API User Hook for post_update.
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
--   p_rec.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this procedure. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy per_pds_shd.g_rec_type) is
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
    per_pds_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.termination_accepted_person_id = hr_api.g_number) then
    p_rec.termination_accepted_person_id :=
    per_pds_shd.g_old_rec.termination_accepted_person_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_pds_shd.g_old_rec.person_id;
  End If;
  If (p_rec.date_start = hr_api.g_date) then
    p_rec.date_start :=
    per_pds_shd.g_old_rec.date_start;
  End If;
  If (p_rec.accepted_termination_date = hr_api.g_date) then
    p_rec.accepted_termination_date :=
    per_pds_shd.g_old_rec.accepted_termination_date;
  End If;
  If (p_rec.actual_termination_date = hr_api.g_date) then
    p_rec.actual_termination_date :=
    per_pds_shd.g_old_rec.actual_termination_date;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_pds_shd.g_old_rec.comments;
  End If;
  If (p_rec.final_process_date = hr_api.g_date) then
    p_rec.final_process_date :=
    per_pds_shd.g_old_rec.final_process_date;
  End If;
  If (p_rec.last_standard_process_date = hr_api.g_date) then
    p_rec.last_standard_process_date :=
    per_pds_shd.g_old_rec.last_standard_process_date;
  End If;
  If (p_rec.leaving_reason = hr_api.g_varchar2) then
    p_rec.leaving_reason :=
    per_pds_shd.g_old_rec.leaving_reason;
  End If;
  If (p_rec.notified_termination_date = hr_api.g_date) then
    p_rec.notified_termination_date :=
    per_pds_shd.g_old_rec.notified_termination_date;
  End If;
  If (p_rec.projected_termination_date = hr_api.g_date) then
    p_rec.projected_termination_date :=
    per_pds_shd.g_old_rec.projected_termination_date;
  End If;
  If (p_rec.adjusted_svc_date = hr_api.g_date) then
    p_rec.adjusted_svc_date  :=
    per_pds_shd.g_old_rec.adjusted_svc_date;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_pds_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_pds_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_pds_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_pds_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_pds_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_pds_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_pds_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_pds_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_pds_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_pds_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_pds_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_pds_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_pds_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_pds_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_pds_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_pds_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_pds_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_pds_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_pds_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_pds_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_pds_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_pds_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_pds_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_pds_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_pds_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.prior_employment_ssp_weeks = hr_api.g_number) then
    p_rec.prior_employment_ssp_weeks :=
    per_pds_shd.g_old_rec.prior_employment_ssp_weeks;
  End If;
  If (p_rec.prior_employment_ssp_paid_to = hr_api.g_date) then
    p_rec.prior_employment_ssp_paid_to :=
    per_pds_shd.g_old_rec.prior_employment_ssp_paid_to;
  End If;
  If (p_rec.pds_information_category = hr_api.g_varchar2) then
    p_rec.pds_information_category :=
    per_pds_shd.g_old_rec.pds_information_category;
  End If;
  If (p_rec.pds_information1 = hr_api.g_varchar2) then
    p_rec.pds_information1 :=
    per_pds_shd.g_old_rec.pds_information1;
  End If;
  If (p_rec.pds_information2 = hr_api.g_varchar2) then
    p_rec.pds_information2 :=
    per_pds_shd.g_old_rec.pds_information2;
  End If;
  If (p_rec.pds_information3 = hr_api.g_varchar2) then
    p_rec.pds_information3 :=
    per_pds_shd.g_old_rec.pds_information3;
  End If;
  If (p_rec.pds_information4 = hr_api.g_varchar2) then
    p_rec.pds_information4 :=
    per_pds_shd.g_old_rec.pds_information4;
  End If;
  If (p_rec.pds_information5 = hr_api.g_varchar2) then
    p_rec.pds_information5 :=
    per_pds_shd.g_old_rec.pds_information5;
  End If;
  If (p_rec.pds_information6 = hr_api.g_varchar2) then
    p_rec.pds_information6 :=
    per_pds_shd.g_old_rec.pds_information6;
  End If;
  If (p_rec.pds_information7 = hr_api.g_varchar2) then
    p_rec.pds_information7 :=
    per_pds_shd.g_old_rec.pds_information7;
  End If;
  If (p_rec.pds_information8 = hr_api.g_varchar2) then
    p_rec.pds_information8 :=
    per_pds_shd.g_old_rec.pds_information8;
  End If;
  If (p_rec.pds_information9 = hr_api.g_varchar2) then
    p_rec.pds_information9 :=
    per_pds_shd.g_old_rec.pds_information9;
  End If;
  If (p_rec.pds_information10 = hr_api.g_varchar2) then
    p_rec.pds_information10 :=
    per_pds_shd.g_old_rec.pds_information10;
  End If;
  If (p_rec.pds_information11 = hr_api.g_varchar2) then
    p_rec.pds_information11 :=
    per_pds_shd.g_old_rec.pds_information11;
  End If;
  If (p_rec.pds_information12 = hr_api.g_varchar2) then
    p_rec.pds_information12 :=
    per_pds_shd.g_old_rec.pds_information12;
  End If;
  If (p_rec.pds_information13 = hr_api.g_varchar2) then
    p_rec.pds_information13 :=
    per_pds_shd.g_old_rec.pds_information13;
  End If;
  If (p_rec.pds_information14 = hr_api.g_varchar2) then
    p_rec.pds_information14 :=
    per_pds_shd.g_old_rec.pds_information14;
  End If;
  If (p_rec.pds_information15 = hr_api.g_varchar2) then
    p_rec.pds_information15 :=
    per_pds_shd.g_old_rec.pds_information15;
  End If;
  If (p_rec.pds_information16 = hr_api.g_varchar2) then
    p_rec.pds_information16 :=
    per_pds_shd.g_old_rec.pds_information16;
  End If;
  If (p_rec.pds_information17 = hr_api.g_varchar2) then
    p_rec.pds_information17 :=
    per_pds_shd.g_old_rec.pds_information17;
  End If;
  If (p_rec.pds_information18 = hr_api.g_varchar2) then
    p_rec.pds_information18 :=
    per_pds_shd.g_old_rec.pds_information18;
  End If;
  If (p_rec.pds_information19 = hr_api.g_varchar2) then
    p_rec.pds_information19 :=
    per_pds_shd.g_old_rec.pds_information19;
  End If;
  If (p_rec.pds_information20 = hr_api.g_varchar2) then
    p_rec.pds_information20 :=
    per_pds_shd.g_old_rec.pds_information20;
  End If;
  If (p_rec.pds_information21 = hr_api.g_varchar2) then
    p_rec.pds_information21 :=
    per_pds_shd.g_old_rec.pds_information21;
  End If;
  If (p_rec.pds_information22 = hr_api.g_varchar2) then
    p_rec.pds_information22 :=
    per_pds_shd.g_old_rec.pds_information22;
  End If;
  If (p_rec.pds_information23 = hr_api.g_varchar2) then
    p_rec.pds_information23 :=
    per_pds_shd.g_old_rec.pds_information23;
  End If;
  If (p_rec.pds_information24 = hr_api.g_varchar2) then
    p_rec.pds_information24 :=
    per_pds_shd.g_old_rec.pds_information24;
  End If;
  If (p_rec.pds_information25 = hr_api.g_varchar2) then
    p_rec.pds_information25 :=
    per_pds_shd.g_old_rec.pds_information25;
  End If;
  If (p_rec.pds_information26 = hr_api.g_varchar2) then
    p_rec.pds_information26 :=
    per_pds_shd.g_old_rec.pds_information26;
  End If;
  If (p_rec.pds_information27 = hr_api.g_varchar2) then
    p_rec.pds_information27 :=
    per_pds_shd.g_old_rec.pds_information27;
  End If;
  If (p_rec.pds_information28 = hr_api.g_varchar2) then
    p_rec.pds_information28 :=
    per_pds_shd.g_old_rec.pds_information28;
  End If;
  If (p_rec.pds_information29 = hr_api.g_varchar2) then
    p_rec.pds_information29 :=
    per_pds_shd.g_old_rec.pds_information29;
  End If;
  If (p_rec.pds_information30 = hr_api.g_varchar2) then
    p_rec.pds_information30 :=
    per_pds_shd.g_old_rec.pds_information30;
  End If;
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
  p_rec            in out nocopy per_pds_shd.g_rec_type,
  p_effective_date in date,
  p_validate       in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
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
    SAVEPOINT upd_per_pds;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_pds_shd.lck
	(
	p_rec.period_of_service_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  convert_defs(p_rec);
  --
  -- 2. Call the supporting update validate operations.
  --
  per_pds_bus.update_validate(p_rec
			     ,p_effective_date);
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
 post_update(p_rec, p_effective_date);
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
    ROLLBACK TO upd_per_pds;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_period_of_service_id         in number,
  p_termination_accepted_person  in number           default hr_api.g_number,
  p_date_start                   in date             default hr_api.g_date,
  p_accepted_termination_date    in date             default hr_api.g_date,
  p_actual_termination_date      in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_final_process_date           in date             default hr_api.g_date,
  p_last_standard_process_date   in date             default hr_api.g_date,
  p_leaving_reason               in varchar2         default hr_api.g_varchar2,
  p_notified_termination_date    in date             default hr_api.g_date,
  p_projected_termination_date   in date             default hr_api.g_date,
  p_adjusted_svc_date            in date             default hr_api.g_date,
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
  p_object_version_number        in out nocopy number,
  p_prior_employment_ssp_weeks   in number           default hr_api.g_number,
  p_prior_employment_ssp_paid_to in date             default hr_api.g_date,
  p_pds_information_category     in varchar2         default hr_api.g_varchar2,
  p_pds_information1             in varchar2         default hr_api.g_varchar2,
  p_pds_information2             in varchar2         default hr_api.g_varchar2,
  p_pds_information3             in varchar2         default hr_api.g_varchar2,
  p_pds_information4             in varchar2         default hr_api.g_varchar2,
  p_pds_information5             in varchar2         default hr_api.g_varchar2,
  p_pds_information6             in varchar2         default hr_api.g_varchar2,
  p_pds_information7             in varchar2         default hr_api.g_varchar2,
  p_pds_information8             in varchar2         default hr_api.g_varchar2,
  p_pds_information9             in varchar2         default hr_api.g_varchar2,
  p_pds_information10            in varchar2         default hr_api.g_varchar2,
  p_pds_information11            in varchar2         default hr_api.g_varchar2,
  p_pds_information12            in varchar2         default hr_api.g_varchar2,
  p_pds_information13            in varchar2         default hr_api.g_varchar2,
  p_pds_information14            in varchar2         default hr_api.g_varchar2,
  p_pds_information15            in varchar2         default hr_api.g_varchar2,
  p_pds_information16            in varchar2         default hr_api.g_varchar2,
  p_pds_information17            in varchar2         default hr_api.g_varchar2,
  p_pds_information18            in varchar2         default hr_api.g_varchar2,
  p_pds_information19            in varchar2         default hr_api.g_varchar2,
  p_pds_information20            in varchar2         default hr_api.g_varchar2,
  p_pds_information21            in varchar2         default hr_api.g_varchar2,
  p_pds_information22            in varchar2         default hr_api.g_varchar2,
  p_pds_information23            in varchar2         default hr_api.g_varchar2,
  p_pds_information24            in varchar2         default hr_api.g_varchar2,
  p_pds_information25            in varchar2         default hr_api.g_varchar2,
  p_pds_information26            in varchar2         default hr_api.g_varchar2,
  p_pds_information27            in varchar2         default hr_api.g_varchar2,
  p_pds_information28            in varchar2         default hr_api.g_varchar2,
  p_pds_information29            in varchar2         default hr_api.g_varchar2,
  p_pds_information30            in varchar2         default hr_api.g_varchar2,
  p_effective_date               in date,
  p_validate                     in boolean      default false
  ) is
--
  l_rec	  per_pds_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pds_shd.convert_args
  (
  p_period_of_service_id,
  hr_api.g_number,
  p_termination_accepted_person,
  hr_api.g_number,
  p_date_start,
  p_accepted_termination_date,
  p_actual_termination_date,
  p_comments,
  p_final_process_date,
  p_last_standard_process_date,
  p_leaving_reason,
  p_notified_termination_date,
  p_projected_termination_date,
  p_adjusted_svc_date,
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
  p_object_version_number ,
  p_prior_employment_ssp_weeks,
  p_prior_employment_ssp_paid_to,
  p_pds_information_category,
  p_pds_information1,
  p_pds_information2,
  p_pds_information3,
  p_pds_information4,
  p_pds_information5,
  p_pds_information6,
  p_pds_information7,
  p_pds_information8,
  p_pds_information9,
  p_pds_information10,
  p_pds_information11,
  p_pds_information12,
  p_pds_information13,
  p_pds_information14,
  p_pds_information15,
  p_pds_information16,
  p_pds_information17,
  p_pds_information18,
  p_pds_information19,
  p_pds_information20,
  p_pds_information21,
  p_pds_information22,
  p_pds_information23,
  p_pds_information24,
  p_pds_information25,
  p_pds_information26,
  p_pds_information27,
  p_pds_information28,
  p_pds_information29,
  p_pds_information30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pds_upd;

/
