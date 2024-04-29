--------------------------------------------------------
--  DDL for Package Body PER_CTC_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTC_DEL" as
/* $Header: pectcrhi.pkb 115.20 2003/02/11 14:24:18 vramanai ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ctc_del.';  -- Global package name
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
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
	(p_rec 			 in out nocopy per_ctc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from per_contracts_f
    where       contract_id = p_rec.contract_id
    and	  effective_start_date = p_validation_start_date;
    --
  Else
    hr_utility.set_location(l_proc, 15);
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from per_contracts_f
    where        contract_id = p_rec.contract_id
    and	  effective_start_date >= p_validation_start_date;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
	(p_rec 			 in out nocopy per_ctc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,

	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
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
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
	(p_rec 			 in out nocopy per_ctc_shd.g_rec_type,
	 p_effective_date	 in	date,

	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := per_ctc_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    per_ctc_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date,
       p_base_key_value	        => p_rec.contract_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,

       p_validation_end_date	=> p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
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
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
	(p_rec 			 in out nocopy per_ctc_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
  --
  l_proc	varchar2(72) := g_package||'pre_delete';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
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
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
	(p_rec 			 in per_ctc_shd.g_rec_type,
	 p_effective_date	       in date,
	 p_datetrack_mode	       in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    per_ctc_rkd.after_delete
     (
     p_effective_date               => p_effective_date,
     p_datetrack_mode               => p_datetrack_mode,
     p_validation_start_date        => p_validation_start_date,
     p_validation_end_date          => p_validation_start_date,
     p_contract_id                  => p_rec.contract_id,
     p_effective_start_date         => p_rec.effective_start_date,
     p_effective_end_date           => p_rec.effective_end_date,
     p_object_version_number        => p_rec.object_version_number,
     p_effective_start_date_o       => per_ctc_shd.g_old_rec.effective_start_date,
     p_effective_end_date_o         => per_ctc_shd.g_old_rec.effective_end_date,
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
     p_object_version_number_o      => per_ctc_shd.g_old_rec.object_version_number
     );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'per_contracts_f'
        ,p_hook_type   => 'AD');
      --
  end;
  --
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
  p_rec			in out nocopy 	per_ctc_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'del';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
  --
  per_ctc_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_contract_id	 => p_rec.contract_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  per_ctc_bus.delete_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,

	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_contract_id	  in 	 number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date	     out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date	  in     date,
  p_datetrack_mode  	  in     varchar2
  ) is
--
  l_rec		per_ctc_shd.g_rec_type;
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
  l_rec.contract_id		:= p_contract_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the per_ctc_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode);
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
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_row >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- This is called from maintain_contracts, used when hire date or application
-- date changes.
--
procedure delete_row
  (
   p_contract_id           in      per_contracts_f.contract_id%TYPE,
   p_effective_date        in      date,
   p_object_version_number in      per_contracts_f.object_version_number%TYPE
  ) is
  --
  l_proc        varchar2(72) := g_package||'delete_row';
  --
  begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- mandatory argument checking
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'contract_id',
     p_argument_value => p_contract_id);

  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);

  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);
  --
  --
  -- We must lock the row which we need to delete.
  --
  per_ctc_shd.lock_record
    (p_contract_id,
     p_effective_date,
     p_object_version_number
    );
  --
  -- delete row
  --
  delete from per_contracts_f
    where contract_id = p_contract_id and
    p_effective_date between effective_start_date
	                 and effective_end_date;
  --
  exception when others then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  --
  end delete_row;
  --
end per_ctc_del;

/
