--------------------------------------------------------
--  DDL for Package Body PER_CTC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTC_UPD" as
/* $Header: pectcrhi.pkb 115.20 2003/02/11 14:24:18 vramanai ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ctc_upd.';  -- Global package name
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
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
	(p_rec 			 in out nocopy per_ctc_shd.g_rec_type,
	 p_effective_date	 in	date,

	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
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
	  (p_base_table_name	=> 'per_contracts_f',
	   p_base_key_column	=> 'contract_id',
	   p_base_key_value	=> p_rec.contract_id);
    --
    -- Update the per_contracts_f Row
    --
    update  per_contracts_f
    set
        contract_id                     = p_rec.contract_id,
    business_group_id               = p_rec.business_group_id,
    object_version_number           = p_rec.object_version_number,
    person_id                       = p_rec.person_id,
    reference                       = p_rec.reference,
    type                            = p_rec.type,
    status                          = p_rec.status,
    status_reason                   = p_rec.status_reason,
    doc_status                      = p_rec.doc_status,
    doc_status_change_date          = p_rec.doc_status_change_date,
    description                     = p_rec.description,
    duration                        = p_rec.duration,
    duration_units                  = p_rec.duration_units,
    contractual_job_title           = p_rec.contractual_job_title,
    parties                         = p_rec.parties,
    start_reason                    = p_rec.start_reason,
    end_reason                      = p_rec.end_reason,
    number_of_extensions            = p_rec.number_of_extensions,
    extension_reason                = p_rec.extension_reason,
    extension_period                = p_rec.extension_period,
    extension_period_units          = p_rec.extension_period_units,
    ctr_information_category        = p_rec.ctr_information_category,
    ctr_information1                = p_rec.ctr_information1,
    ctr_information2                = p_rec.ctr_information2,
    ctr_information3                = p_rec.ctr_information3,
    ctr_information4                = p_rec.ctr_information4,
    ctr_information5                = p_rec.ctr_information5,
    ctr_information6                = p_rec.ctr_information6,
    ctr_information7                = p_rec.ctr_information7,
    ctr_information8                = p_rec.ctr_information8,
    ctr_information9                = p_rec.ctr_information9,
    ctr_information10               = p_rec.ctr_information10,
    ctr_information11               = p_rec.ctr_information11,
    ctr_information12               = p_rec.ctr_information12,
    ctr_information13               = p_rec.ctr_information13,
    ctr_information14               = p_rec.ctr_information14,
    ctr_information15               = p_rec.ctr_information15,
    ctr_information16               = p_rec.ctr_information16,
    ctr_information17               = p_rec.ctr_information17,
    ctr_information18               = p_rec.ctr_information18,
    ctr_information19               = p_rec.ctr_information19,
    ctr_information20               = p_rec.ctr_information20,
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
    attribute20                     = p_rec.attribute20
    where   contract_id = p_rec.contract_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;

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
    per_ctc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_ctc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--

-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
	(p_rec 			 in out nocopy per_ctc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
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
--	the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
	(p_rec 			 in out nocopy per_ctc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    per_ctc_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.contract_id,
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
      per_ctc_del.delete_dml
        (p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => p_validation_start_date,
	 p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    per_ctc_ins.insert_dml
      (p_rec			=> p_rec,
       p_effective_date		=> p_effective_date,
       p_datetrack_mode		=> p_datetrack_mode,
       p_validation_start_date	=> p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date);
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
	(p_rec 			 in out nocopy per_ctc_shd.g_rec_type,

	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
	(p_rec 			 in per_ctc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    per_ctc_rku.after_update
     (
     p_contract_id                  => p_rec.contract_id,
     p_effective_start_date         => p_rec.effective_start_date,
     p_effective_end_date           => p_rec.effective_end_date,
     p_reference                    => p_rec.reference,
     p_type                         => p_rec.type,
     p_status                       => p_rec.status,
     p_status_reason                => p_rec.status_reason,
     p_doc_status                   => p_rec.doc_status,
     p_doc_status_change_date       => p_rec.doc_status_change_date,
     p_description                  => p_rec.description,
     p_duration                     => p_rec.duration,
     p_duration_units               => p_rec.duration_units,
     p_contractual_job_title        => p_rec.contractual_job_title,
     p_parties                      => p_rec.parties,
     p_start_reason                 => p_rec.start_reason,
     p_end_reason                   => p_rec.end_reason ,
     p_number_of_extensions         => p_rec.number_of_extensions,
     p_extension_reason             => p_rec.extension_reason,
     p_extension_period             => p_rec.extension_period,
     p_extension_period_units       => p_rec.extension_period_units,
     p_ctr_information_category     => p_rec.ctr_information_category,
     p_ctr_information1             => p_rec.ctr_information1,
     p_ctr_information2             => p_rec.ctr_information2,
     p_ctr_information3             => p_rec.ctr_information3,
     p_ctr_information4             => p_rec.ctr_information4,
     p_ctr_information5             => p_rec.ctr_information5,
     p_ctr_information6             => p_rec.ctr_information6,
     p_ctr_information7             => p_rec.ctr_information7,
     p_ctr_information8             => p_rec.ctr_information8,
     p_ctr_information9             => p_rec.ctr_information9,
     p_ctr_information10            => p_rec.ctr_information10,
     p_ctr_information11            => p_rec.ctr_information11,
     p_ctr_information12            => p_rec.ctr_information12,
     p_ctr_information13            => p_rec.ctr_information13,
     p_ctr_information14            => p_rec.ctr_information14,
     p_ctr_information15            => p_rec.ctr_information15,
     p_ctr_information16            => p_rec.ctr_information16,
     p_ctr_information17            => p_rec.ctr_information17,
     p_ctr_information18            => p_rec.ctr_information18,
     p_ctr_information19            => p_rec.ctr_information19,
     p_ctr_information20            => p_rec.ctr_information20,
     p_attribute_category           => p_rec.attribute_category,
     p_attribute1                   => p_rec.attribute1,
     p_attribute2                   => p_rec.attribute2,
     p_attribute3                   => p_rec.attribute3,
     p_attribute4                   => p_rec.attribute4,
     p_attribute5                   => p_rec.attribute5,
     p_attribute6                   => p_rec.attribute6,
     p_attribute7                   => p_rec.attribute7,
     p_attribute8                   => p_rec.attribute8,
     p_attribute9                   => p_rec.attribute9,
     p_attribute10                  => p_rec.attribute10,
     p_attribute11                  => p_rec.attribute11,
     p_attribute12                  => p_rec.attribute12,
     p_attribute13                  => p_rec.attribute13,
     p_attribute14                  => p_rec.attribute14,
     p_attribute15                  => p_rec.attribute15,
     p_attribute16                  => p_rec.attribute16,
     p_attribute17                  => p_rec.attribute17,
     p_attribute18                  => p_rec.attribute18,
     p_attribute19                  => p_rec.attribute19,
     p_attribute20                  => p_rec.attribute20,
     p_effective_date               => p_effective_date,
     p_datetrack_mode               => p_datetrack_mode,
     p_validation_start_date        => p_validation_start_date,
     p_validation_end_date          => p_validation_end_date,
     p_business_group_id_o          => per_ctc_shd.g_old_rec.business_group_id,
     p_person_id_o                  => per_ctc_shd.g_old_rec.person_id,
     p_reference_o                  => per_ctc_shd.g_old_rec.reference,
     p_type_o                       => per_ctc_shd.g_old_rec.type,
     p_status_o                     => per_ctc_shd.g_old_rec.status,
     p_status_reason_o              => per_ctc_shd.g_old_rec.status_reason,
     p_doc_status_o                 => per_ctc_shd.g_old_rec.doc_status,
     p_doc_status_change_date_o     => per_ctc_shd.g_old_rec.doc_status_change_date,
     p_description_o                => per_ctc_shd.g_old_rec.description,
     p_duration_o                   => per_ctc_shd.g_old_rec.duration,
     p_duration_units_o             => per_ctc_shd.g_old_rec.duration_units,
     p_contractual_job_title_o      => per_ctc_shd.g_old_rec.contractual_job_title,
     p_parties_o                    => per_ctc_shd.g_old_rec.parties,
     p_start_reason_o               => per_ctc_shd.g_old_rec.start_reason,
     p_end_reason_o                 => per_ctc_shd.g_old_rec.end_reason ,
     p_number_of_extensions_o       => per_ctc_shd.g_old_rec.number_of_extensions,
     p_extension_reason_o           => per_ctc_shd.g_old_rec.extension_reason,
     p_extension_period_o           => per_ctc_shd.g_old_rec.extension_period,
     p_extension_period_units_o     => per_ctc_shd.g_old_rec.extension_period_units,
     p_ctr_information_category_o   => per_ctc_shd.g_old_rec.ctr_information_category,
     p_ctr_information1_o           => per_ctc_shd.g_old_rec.ctr_information1,
     p_ctr_information2_o           => per_ctc_shd.g_old_rec.ctr_information2,
     p_ctr_information3_o           => per_ctc_shd.g_old_rec.ctr_information3,
     p_ctr_information4_o           => per_ctc_shd.g_old_rec.ctr_information4,
     p_ctr_information5_o           => per_ctc_shd.g_old_rec.ctr_information5,
     p_ctr_information6_o           => per_ctc_shd.g_old_rec.ctr_information6,
     p_ctr_information7_o           => per_ctc_shd.g_old_rec.ctr_information7,
     p_ctr_information8_o           => per_ctc_shd.g_old_rec.ctr_information8,
     p_ctr_information9_o           => per_ctc_shd.g_old_rec.ctr_information9,
     p_ctr_information10_o          => per_ctc_shd.g_old_rec.ctr_information10,
     p_ctr_information11_o          => per_ctc_shd.g_old_rec.ctr_information11,
     p_ctr_information12_o          => per_ctc_shd.g_old_rec.ctr_information12,
     p_ctr_information13_o          => per_ctc_shd.g_old_rec.ctr_information13,
     p_ctr_information14_o          => per_ctc_shd.g_old_rec.ctr_information14,
     p_ctr_information15_o          => per_ctc_shd.g_old_rec.ctr_information15,
     p_ctr_information16_o          => per_ctc_shd.g_old_rec.ctr_information16,
     p_ctr_information17_o          => per_ctc_shd.g_old_rec.ctr_information17,
     p_ctr_information18_o          => per_ctc_shd.g_old_rec.ctr_information18,
     p_ctr_information19_o          => per_ctc_shd.g_old_rec.ctr_information19,
     p_ctr_information20_o          => per_ctc_shd.g_old_rec.ctr_information20,
     p_attribute_category_o         => per_ctc_shd.g_old_rec.attribute_category,
     p_attribute1_o                 => per_ctc_shd.g_old_rec.attribute1,
     p_attribute2_o                 => per_ctc_shd.g_old_rec.attribute2,
     p_attribute3_o                 => per_ctc_shd.g_old_rec.attribute3,
     p_attribute4_o                 => per_ctc_shd.g_old_rec.attribute4,
     p_attribute5_o                 => per_ctc_shd.g_old_rec.attribute5,
     p_attribute6_o                 => per_ctc_shd.g_old_rec.attribute6,
     p_attribute7_o                 => per_ctc_shd.g_old_rec.attribute7,
     p_attribute8_o                 => per_ctc_shd.g_old_rec.attribute8,
     p_attribute9_o                 => per_ctc_shd.g_old_rec.attribute9,
     p_attribute10_o                => per_ctc_shd.g_old_rec.attribute10,
     p_attribute11_o                => per_ctc_shd.g_old_rec.attribute11,
     p_attribute12_o                => per_ctc_shd.g_old_rec.attribute12,
     p_attribute13_o                => per_ctc_shd.g_old_rec.attribute13,
     p_attribute14_o                => per_ctc_shd.g_old_rec.attribute14,
     p_attribute15_o                => per_ctc_shd.g_old_rec.attribute15,
     p_attribute16_o                => per_ctc_shd.g_old_rec.attribute16,
     p_attribute17_o                => per_ctc_shd.g_old_rec.attribute17,
     p_attribute18_o                => per_ctc_shd.g_old_rec.attribute18,
     p_attribute19_o                => per_ctc_shd.g_old_rec.attribute19,
     p_attribute20_o                => per_ctc_shd.g_old_rec.attribute20,
     p_object_version_number_o      => per_ctc_shd.g_old_rec.object_version_number,
     p_effective_start_date_o       => per_ctc_shd.g_old_rec.effective_start_date,
     p_effective_end_date_o         => per_ctc_shd.g_old_rec.effective_end_date
     );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'per_contracts_f'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End  post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--

-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy per_ctc_shd.g_rec_type) is
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
    per_ctc_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_ctc_shd.g_old_rec.person_id;
  End If;
  If (p_rec.reference = hr_api.g_varchar2) then
    p_rec.reference :=
    per_ctc_shd.g_old_rec.reference;
  End If;
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    per_ctc_shd.g_old_rec.type;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    per_ctc_shd.g_old_rec.status;
  End If;
  If (p_rec.status_reason = hr_api.g_varchar2) then
    p_rec.status_reason :=
    per_ctc_shd.g_old_rec.status_reason;
  End if;
  If (p_rec.doc_status = hr_api.g_varchar2) then
    p_rec.doc_status :=
    per_ctc_shd.g_old_rec.doc_status;
  End If;
  If (p_rec.doc_status_change_date = hr_api.g_date) then
    p_rec.doc_status_change_date :=
    per_ctc_shd.g_old_rec.doc_status_change_date;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    per_ctc_shd.g_old_rec.description;
  End If;
  If (p_rec.duration = hr_api.g_number) then
    p_rec.duration :=
    per_ctc_shd.g_old_rec.duration;
  End If;
  If (p_rec.duration_units = hr_api.g_varchar2) then
    p_rec.duration_units :=
    per_ctc_shd.g_old_rec.duration_units;
  End If;
  If (p_rec.contractual_job_title = hr_api.g_varchar2) then
    p_rec.contractual_job_title :=
    per_ctc_shd.g_old_rec.contractual_job_title;
  End If;
  If (p_rec.parties = hr_api.g_varchar2) then
    p_rec.parties :=
    per_ctc_shd.g_old_rec.parties;
  End If;
  If (p_rec.start_reason = hr_api.g_varchar2) then
    p_rec.start_reason :=
    per_ctc_shd.g_old_rec.start_reason;
  End If;
  If (p_rec.end_reason = hr_api.g_varchar2) then
    p_rec.end_reason :=
    per_ctc_shd.g_old_rec.end_reason;
  End If;
  If (p_rec.number_of_extensions = hr_api.g_number) then
    p_rec.number_of_extensions :=
    per_ctc_shd.g_old_rec.number_of_extensions;
  End If;
  If (p_rec.extension_reason = hr_api.g_varchar2) then
    p_rec.extension_reason :=
    per_ctc_shd.g_old_rec.extension_reason;
  End If;
  If (p_rec.extension_period = hr_api.g_number) then
    p_rec.extension_period :=
    per_ctc_shd.g_old_rec.extension_period;
  End If;
  If (p_rec.extension_period_units = hr_api.g_varchar2) then
    p_rec.extension_period_units :=
    per_ctc_shd.g_old_rec.extension_period_units;
  End If;
  If (p_rec.ctr_information_category = hr_api.g_varchar2) then
    p_rec.ctr_information_category :=
    per_ctc_shd.g_old_rec.ctr_information_category;
  End If;
  If (p_rec.ctr_information1 = hr_api.g_varchar2) then
    p_rec.ctr_information1 :=
    per_ctc_shd.g_old_rec.ctr_information1;
  End If;
  If (p_rec.ctr_information2 = hr_api.g_varchar2) then
    p_rec.ctr_information2 :=
    per_ctc_shd.g_old_rec.ctr_information2;
  End If;
  If (p_rec.ctr_information3 = hr_api.g_varchar2) then
    p_rec.ctr_information3 :=
    per_ctc_shd.g_old_rec.ctr_information3;
  End If;
  If (p_rec.ctr_information4 = hr_api.g_varchar2) then
    p_rec.ctr_information4 :=
    per_ctc_shd.g_old_rec.ctr_information4;
  End If;
  If (p_rec.ctr_information5 = hr_api.g_varchar2) then
    p_rec.ctr_information5 :=
    per_ctc_shd.g_old_rec.ctr_information5;
  End If;
  If (p_rec.ctr_information6 = hr_api.g_varchar2) then
    p_rec.ctr_information6 :=
    per_ctc_shd.g_old_rec.ctr_information6;
  End If;
  If (p_rec.ctr_information7 = hr_api.g_varchar2) then
    p_rec.ctr_information7 :=
    per_ctc_shd.g_old_rec.ctr_information7;
  End If;
  If (p_rec.ctr_information8 = hr_api.g_varchar2) then
    p_rec.ctr_information8 :=
    per_ctc_shd.g_old_rec.ctr_information8;
  End If;
  If (p_rec.ctr_information9 = hr_api.g_varchar2) then
    p_rec.ctr_information9 :=
    per_ctc_shd.g_old_rec.ctr_information9;
  End If;
  If (p_rec.ctr_information10 = hr_api.g_varchar2) then
    p_rec.ctr_information10 :=
    per_ctc_shd.g_old_rec.ctr_information10;
  End If;
  If (p_rec.ctr_information11 = hr_api.g_varchar2) then
    p_rec.ctr_information11 :=
    per_ctc_shd.g_old_rec.ctr_information11;
  End If;
  If (p_rec.ctr_information12 = hr_api.g_varchar2) then
    p_rec.ctr_information12 :=
    per_ctc_shd.g_old_rec.ctr_information12;
  End If;
  If (p_rec.ctr_information13 = hr_api.g_varchar2) then
    p_rec.ctr_information13 :=
    per_ctc_shd.g_old_rec.ctr_information13;
  End If;
  If (p_rec.ctr_information14 = hr_api.g_varchar2) then
    p_rec.ctr_information14 :=
    per_ctc_shd.g_old_rec.ctr_information14;
  End If;
  If (p_rec.ctr_information15 = hr_api.g_varchar2) then
    p_rec.ctr_information15 :=
    per_ctc_shd.g_old_rec.ctr_information15;
  End If;
  If (p_rec.ctr_information16 = hr_api.g_varchar2) then
    p_rec.ctr_information16 :=
    per_ctc_shd.g_old_rec.ctr_information16;
  End If;
  If (p_rec.ctr_information17 = hr_api.g_varchar2) then
    p_rec.ctr_information17 :=
    per_ctc_shd.g_old_rec.ctr_information17;
  End If;
  If (p_rec.ctr_information18 = hr_api.g_varchar2) then
    p_rec.ctr_information18 :=
    per_ctc_shd.g_old_rec.ctr_information18;
  End If;
  If (p_rec.ctr_information19 = hr_api.g_varchar2) then
    p_rec.ctr_information19 :=
    per_ctc_shd.g_old_rec.ctr_information19;
  End If;
  If (p_rec.ctr_information20 = hr_api.g_varchar2) then
    p_rec.ctr_information20 :=
    per_ctc_shd.g_old_rec.ctr_information20;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_ctc_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_ctc_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_ctc_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_ctc_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_ctc_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_ctc_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_ctc_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_ctc_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_ctc_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_ctc_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_ctc_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_ctc_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_ctc_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_ctc_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_ctc_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then

    p_rec.attribute15 :=
    per_ctc_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_ctc_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_ctc_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_ctc_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_ctc_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_ctc_shd.g_old_rec.attribute20;
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
  p_rec			in out nocopy 	per_ctc_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  per_ctc_shd.lck

	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_contract_id	 => p_rec.contract_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  per_ctc_bus.update_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode  	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_contract_id                  in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_object_version_number        in out nocopy number,
  p_reference                    in varchar2         default hr_api.g_varchar2,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_status_reason                in varchar2         default hr_api.g_varchar2,
  p_doc_status                   in varchar2         default hr_api.g_varchar2,
  p_doc_status_change_date       in date             default hr_api.g_date,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_duration                     in number           default hr_api.g_number,
  p_duration_units               in varchar2         default hr_api.g_varchar2,
  p_contractual_job_title        in varchar2         default hr_api.g_varchar2,
  p_parties                      in varchar2         default hr_api.g_varchar2,
  p_start_reason                 in varchar2         default hr_api.g_varchar2,
  p_end_reason                   in varchar2         default hr_api.g_varchar2,
  p_number_of_extensions         in number           default hr_api.g_number,
  p_extension_reason             in varchar2         default hr_api.g_varchar2,
  p_extension_period             in number           default hr_api.g_number,
  p_extension_period_units       in varchar2         default hr_api.g_varchar2,
  p_ctr_information_category     in varchar2         default hr_api.g_varchar2,
  p_ctr_information1             in varchar2         default hr_api.g_varchar2,
  p_ctr_information2             in varchar2         default hr_api.g_varchar2,
  p_ctr_information3             in varchar2         default hr_api.g_varchar2,
  p_ctr_information4             in varchar2         default hr_api.g_varchar2,
  p_ctr_information5             in varchar2         default hr_api.g_varchar2,
  p_ctr_information6             in varchar2         default hr_api.g_varchar2,
  p_ctr_information7             in varchar2         default hr_api.g_varchar2,
  p_ctr_information8             in varchar2         default hr_api.g_varchar2,
  p_ctr_information9             in varchar2         default hr_api.g_varchar2,
  p_ctr_information10            in varchar2         default hr_api.g_varchar2,
  p_ctr_information11            in varchar2         default hr_api.g_varchar2,
  p_ctr_information12            in varchar2         default hr_api.g_varchar2,
  p_ctr_information13            in varchar2         default hr_api.g_varchar2,
  p_ctr_information14            in varchar2         default hr_api.g_varchar2,
  p_ctr_information15            in varchar2         default hr_api.g_varchar2,
  p_ctr_information16            in varchar2         default hr_api.g_varchar2,
  p_ctr_information17            in varchar2         default hr_api.g_varchar2,
  p_ctr_information18            in varchar2         default hr_api.g_varchar2,
  p_ctr_information19            in varchar2         default hr_api.g_varchar2,
  p_ctr_information20            in varchar2         default hr_api.g_varchar2,
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
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		per_ctc_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_ctc_shd.convert_args
  (
  p_contract_id,
  null,
  null,
  hr_api.g_number,
  p_object_version_number,
  hr_api.g_number,
  p_reference,
  p_type,
  p_status,
  p_status_reason,
  p_doc_status,
  p_doc_status_change_date,
  p_description,
  p_duration,
  p_duration_units,
  p_contractual_job_title,
  p_parties,
  p_start_reason,
  p_end_reason,
  p_number_of_extensions,
  p_extension_reason,
  p_extension_period,
  p_extension_period_units,
  p_ctr_information_category,
  p_ctr_information1,
  p_ctr_information2,
  p_ctr_information3,
  p_ctr_information4,
  p_ctr_information5,
  p_ctr_information6,
  p_ctr_information7,
  p_ctr_information8,
  p_ctr_information9,
  p_ctr_information10,
  p_ctr_information11,
  p_ctr_information12,
  p_ctr_information13,
  p_ctr_information14,
  p_ctr_information15,
  p_ctr_information16,
  p_ctr_information17,
  p_ctr_information18,
  p_ctr_information19,
  p_ctr_information20,
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
  p_attribute20
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_effective_start_date>---------------------|
-- ----------------------------------------------------------------------------
--
-- This is called from maintain_contracts, used when hire date or application
-- date changes.
--
procedure update_effective_start_date
  (
  p_contract_id		  in  	per_contracts_f.contract_id%TYPE,
  p_effective_date        in    date,
  p_new_start_date        in 	per_contracts_f.effective_start_date%TYPE,
  p_object_version_number in    per_contracts_f.object_version_number%TYPE
  ) is
  --
  l_proc	varchar2(72) := g_package||'update_effective_start_date';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'contract_id',
     p_argument_value => p_contract_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_effective_date',
     p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_new_start_date',
     p_argument_value => p_new_start_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);
  --
  -- We must lock the row which we need to update.
  --
  per_ctc_shd.lock_record
    (p_contract_id,
     p_effective_date,
     p_object_version_number
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- update the row
  --
  update per_contracts_f
    set effective_start_date = p_new_start_date
    where contract_id = p_contract_id and
          p_effective_date between effective_start_date
			       and effective_end_date;
exception when others then
  --
  -- An unhandled or unexpected error has occurred which
  -- we must report
  --
  hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token('PROCEDURE', l_proc);
  hr_utility.set_message_token('STEP','20');
  hr_utility.raise_error;
  --
end update_effective_start_date;
--
end per_ctc_upd;
--

/
