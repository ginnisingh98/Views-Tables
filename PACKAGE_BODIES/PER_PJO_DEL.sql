--------------------------------------------------------
--  DDL for Package Body PER_PJO_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJO_DEL" as
/* $Header: pepjorhi.pkb 120.0.12010000.2 2008/08/06 09:28:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pjo_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec in per_pjo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_previous_jobs row.
  --
  delete from per_previous_jobs
  where previous_job_id = p_rec.previous_job_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_pjo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End delete_dml;
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
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in per_pjo_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
Procedure post_delete(p_rec in per_pjo_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pjo_rkd.after_delete
      (p_previous_job_id
      => p_rec.previous_job_id
      ,p_previous_employer_id_o
      => per_pjo_shd.g_old_rec.previous_employer_id
      ,p_start_date_o
      => per_pjo_shd.g_old_rec.start_date
      ,p_end_date_o
      => per_pjo_shd.g_old_rec.end_date
      ,p_period_years_o
      => per_pjo_shd.g_old_rec.period_years
      ,p_period_days_o
      => per_pjo_shd.g_old_rec.period_days
      ,p_job_name_o
      => per_pjo_shd.g_old_rec.job_name
      ,p_employment_category_o
      => per_pjo_shd.g_old_rec.employment_category
      ,p_description_o
      => per_pjo_shd.g_old_rec.description
      ,p_pjo_attribute_category_o
      => per_pjo_shd.g_old_rec.pjo_attribute_category
      ,p_pjo_attribute1_o
      => per_pjo_shd.g_old_rec.pjo_attribute1
      ,p_pjo_attribute2_o
      => per_pjo_shd.g_old_rec.pjo_attribute2
      ,p_pjo_attribute3_o
      => per_pjo_shd.g_old_rec.pjo_attribute3
      ,p_pjo_attribute4_o
      => per_pjo_shd.g_old_rec.pjo_attribute4
      ,p_pjo_attribute5_o
      => per_pjo_shd.g_old_rec.pjo_attribute5
      ,p_pjo_attribute6_o
      => per_pjo_shd.g_old_rec.pjo_attribute6
      ,p_pjo_attribute7_o
      => per_pjo_shd.g_old_rec.pjo_attribute7
      ,p_pjo_attribute8_o
      => per_pjo_shd.g_old_rec.pjo_attribute8
      ,p_pjo_attribute9_o
      => per_pjo_shd.g_old_rec.pjo_attribute9
      ,p_pjo_attribute10_o
      => per_pjo_shd.g_old_rec.pjo_attribute10
      ,p_pjo_attribute11_o
      => per_pjo_shd.g_old_rec.pjo_attribute11
      ,p_pjo_attribute12_o
      => per_pjo_shd.g_old_rec.pjo_attribute12
      ,p_pjo_attribute13_o
      => per_pjo_shd.g_old_rec.pjo_attribute13
      ,p_pjo_attribute14_o
      => per_pjo_shd.g_old_rec.pjo_attribute14
      ,p_pjo_attribute15_o
      => per_pjo_shd.g_old_rec.pjo_attribute15
      ,p_pjo_attribute16_o
      => per_pjo_shd.g_old_rec.pjo_attribute16
      ,p_pjo_attribute17_o
      => per_pjo_shd.g_old_rec.pjo_attribute17
      ,p_pjo_attribute18_o
      => per_pjo_shd.g_old_rec.pjo_attribute18
      ,p_pjo_attribute19_o
      => per_pjo_shd.g_old_rec.pjo_attribute19
      ,p_pjo_attribute20_o
      => per_pjo_shd.g_old_rec.pjo_attribute20
      ,p_pjo_attribute21_o
      => per_pjo_shd.g_old_rec.pjo_attribute21
      ,p_pjo_attribute22_o
      => per_pjo_shd.g_old_rec.pjo_attribute22
      ,p_pjo_attribute23_o
      => per_pjo_shd.g_old_rec.pjo_attribute23
      ,p_pjo_attribute24_o
      => per_pjo_shd.g_old_rec.pjo_attribute24
      ,p_pjo_attribute25_o
      => per_pjo_shd.g_old_rec.pjo_attribute25
      ,p_pjo_attribute26_o
      => per_pjo_shd.g_old_rec.pjo_attribute26
      ,p_pjo_attribute27_o
      => per_pjo_shd.g_old_rec.pjo_attribute27
      ,p_pjo_attribute28_o
      => per_pjo_shd.g_old_rec.pjo_attribute28
      ,p_pjo_attribute29_o
      => per_pjo_shd.g_old_rec.pjo_attribute29
      ,p_pjo_attribute30_o
      => per_pjo_shd.g_old_rec.pjo_attribute30
      ,p_pjo_information_category_o
      => per_pjo_shd.g_old_rec.pjo_information_category
      ,p_pjo_information1_o
      => per_pjo_shd.g_old_rec.pjo_information1
      ,p_pjo_information2_o
      => per_pjo_shd.g_old_rec.pjo_information2
      ,p_pjo_information3_o
      => per_pjo_shd.g_old_rec.pjo_information3
      ,p_pjo_information4_o
      => per_pjo_shd.g_old_rec.pjo_information4
      ,p_pjo_information5_o
      => per_pjo_shd.g_old_rec.pjo_information5
      ,p_pjo_information6_o
      => per_pjo_shd.g_old_rec.pjo_information6
      ,p_pjo_information7_o
      => per_pjo_shd.g_old_rec.pjo_information7
      ,p_pjo_information8_o
      => per_pjo_shd.g_old_rec.pjo_information8
      ,p_pjo_information9_o
      => per_pjo_shd.g_old_rec.pjo_information9
      ,p_pjo_information10_o
      => per_pjo_shd.g_old_rec.pjo_information10
      ,p_pjo_information11_o
      => per_pjo_shd.g_old_rec.pjo_information11
      ,p_pjo_information12_o
      => per_pjo_shd.g_old_rec.pjo_information12
      ,p_pjo_information13_o
      => per_pjo_shd.g_old_rec.pjo_information13
      ,p_pjo_information14_o
      => per_pjo_shd.g_old_rec.pjo_information14
      ,p_pjo_information15_o
      => per_pjo_shd.g_old_rec.pjo_information15
      ,p_pjo_information16_o
      => per_pjo_shd.g_old_rec.pjo_information16
      ,p_pjo_information17_o
      => per_pjo_shd.g_old_rec.pjo_information17
      ,p_pjo_information18_o
      => per_pjo_shd.g_old_rec.pjo_information18
      ,p_pjo_information19_o
      => per_pjo_shd.g_old_rec.pjo_information19
      ,p_pjo_information20_o
      => per_pjo_shd.g_old_rec.pjo_information20
      ,p_pjo_information21_o
      => per_pjo_shd.g_old_rec.pjo_information21
      ,p_pjo_information22_o
      => per_pjo_shd.g_old_rec.pjo_information22
      ,p_pjo_information23_o
      => per_pjo_shd.g_old_rec.pjo_information23
      ,p_pjo_information24_o
      => per_pjo_shd.g_old_rec.pjo_information24
      ,p_pjo_information25_o
      => per_pjo_shd.g_old_rec.pjo_information25
      ,p_pjo_information26_o
      => per_pjo_shd.g_old_rec.pjo_information26
      ,p_pjo_information27_o
      => per_pjo_shd.g_old_rec.pjo_information27
      ,p_pjo_information28_o
      => per_pjo_shd.g_old_rec.pjo_information28
      ,p_pjo_information29_o
      => per_pjo_shd.g_old_rec.pjo_information29
      ,p_pjo_information30_o
      => per_pjo_shd.g_old_rec.pjo_information30
      ,p_object_version_number_o
      => per_pjo_shd.g_old_rec.object_version_number
      ,p_all_assignments_o
      => per_pjo_shd.g_old_rec.all_assignments
      ,p_period_months_o
      => per_pjo_shd.g_old_rec.period_months
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PREVIOUS_JOBS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in per_pjo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_pjo_shd.lck
    (p_rec.previous_job_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_pjo_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  -- Call the supporting pre-delete operation
  --
  per_pjo_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_pjo_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_pjo_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_previous_job_id                      in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_pjo_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.previous_job_id := p_previous_job_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_pjo_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_pjo_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_pjo_del;

/
