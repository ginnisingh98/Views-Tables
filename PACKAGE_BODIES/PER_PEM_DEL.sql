--------------------------------------------------------
--  DDL for Package Body PER_PEM_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEM_DEL" as
/* $Header: pepemrhi.pkb 120.1.12010000.3 2009/01/12 08:21:02 skura ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pem_del.';  -- Global package name
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
  (p_rec in per_pem_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_previous_employers row.
  --
  delete from per_previous_employers
  where previous_employer_id = p_rec.previous_employer_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_pem_shd.constraint_error
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
Procedure pre_delete(p_rec in per_pem_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_pem_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pem_rkd.after_delete
      (p_previous_employer_id
      => p_rec.previous_employer_id
      ,p_business_group_id_o
      => per_pem_shd.g_old_rec.business_group_id
      ,p_person_id_o
      => per_pem_shd.g_old_rec.person_id
      ,p_party_id_o
      => per_pem_shd.g_old_rec.party_id
      ,p_start_date_o
      => per_pem_shd.g_old_rec.start_date
      ,p_end_date_o
      => per_pem_shd.g_old_rec.end_date
      ,p_period_years_o
      => per_pem_shd.g_old_rec.period_years
      ,p_period_days_o
      => per_pem_shd.g_old_rec.period_days
      ,p_employer_name_o
      => per_pem_shd.g_old_rec.employer_name
      ,p_employer_country_o
      => per_pem_shd.g_old_rec.employer_country
      ,p_employer_address_o
      => per_pem_shd.g_old_rec.employer_address
      ,p_employer_type_o
      => per_pem_shd.g_old_rec.employer_type
      ,p_employer_subtype_o
      => per_pem_shd.g_old_rec.employer_subtype
      ,p_description_o
      => per_pem_shd.g_old_rec.description
      ,p_pem_attribute_category_o
      => per_pem_shd.g_old_rec.pem_attribute_category
      ,p_pem_attribute1_o
      => per_pem_shd.g_old_rec.pem_attribute1
      ,p_pem_attribute2_o
      => per_pem_shd.g_old_rec.pem_attribute2
      ,p_pem_attribute3_o
      => per_pem_shd.g_old_rec.pem_attribute3
      ,p_pem_attribute4_o
      => per_pem_shd.g_old_rec.pem_attribute4
      ,p_pem_attribute5_o
      => per_pem_shd.g_old_rec.pem_attribute5
      ,p_pem_attribute6_o
      => per_pem_shd.g_old_rec.pem_attribute6
      ,p_pem_attribute7_o
      => per_pem_shd.g_old_rec.pem_attribute7
      ,p_pem_attribute8_o
      => per_pem_shd.g_old_rec.pem_attribute8
      ,p_pem_attribute9_o
      => per_pem_shd.g_old_rec.pem_attribute9
      ,p_pem_attribute10_o
      => per_pem_shd.g_old_rec.pem_attribute10
      ,p_pem_attribute11_o
      => per_pem_shd.g_old_rec.pem_attribute11
      ,p_pem_attribute12_o
      => per_pem_shd.g_old_rec.pem_attribute12
      ,p_pem_attribute13_o
      => per_pem_shd.g_old_rec.pem_attribute13
      ,p_pem_attribute14_o
      => per_pem_shd.g_old_rec.pem_attribute14
      ,p_pem_attribute15_o
      => per_pem_shd.g_old_rec.pem_attribute15
      ,p_pem_attribute16_o
      => per_pem_shd.g_old_rec.pem_attribute16
      ,p_pem_attribute17_o
      => per_pem_shd.g_old_rec.pem_attribute17
      ,p_pem_attribute18_o
      => per_pem_shd.g_old_rec.pem_attribute18
      ,p_pem_attribute19_o
      => per_pem_shd.g_old_rec.pem_attribute19
      ,p_pem_attribute20_o
      => per_pem_shd.g_old_rec.pem_attribute20
      ,p_pem_attribute21_o
      => per_pem_shd.g_old_rec.pem_attribute21
      ,p_pem_attribute22_o
      => per_pem_shd.g_old_rec.pem_attribute22
      ,p_pem_attribute23_o
      => per_pem_shd.g_old_rec.pem_attribute23
      ,p_pem_attribute24_o
      => per_pem_shd.g_old_rec.pem_attribute24
      ,p_pem_attribute25_o
      => per_pem_shd.g_old_rec.pem_attribute25
      ,p_pem_attribute26_o
      => per_pem_shd.g_old_rec.pem_attribute26
      ,p_pem_attribute27_o
      => per_pem_shd.g_old_rec.pem_attribute27
      ,p_pem_attribute28_o
      => per_pem_shd.g_old_rec.pem_attribute28
      ,p_pem_attribute29_o
      => per_pem_shd.g_old_rec.pem_attribute29
      ,p_pem_attribute30_o
      => per_pem_shd.g_old_rec.pem_attribute30
      ,p_pem_information_category_o
      => per_pem_shd.g_old_rec.pem_information_category
      ,p_pem_information1_o
      => per_pem_shd.g_old_rec.pem_information1
      ,p_pem_information2_o
      => per_pem_shd.g_old_rec.pem_information2
      ,p_pem_information3_o
      => per_pem_shd.g_old_rec.pem_information3
      ,p_pem_information4_o
      => per_pem_shd.g_old_rec.pem_information4
      ,p_pem_information5_o
      => per_pem_shd.g_old_rec.pem_information5
      ,p_pem_information6_o
      => per_pem_shd.g_old_rec.pem_information6
      ,p_pem_information7_o
      => per_pem_shd.g_old_rec.pem_information7
      ,p_pem_information8_o
      => per_pem_shd.g_old_rec.pem_information8
      ,p_pem_information9_o
      => per_pem_shd.g_old_rec.pem_information9
      ,p_pem_information10_o
      => per_pem_shd.g_old_rec.pem_information10
      ,p_pem_information11_o
      => per_pem_shd.g_old_rec.pem_information11
      ,p_pem_information12_o
      => per_pem_shd.g_old_rec.pem_information12
      ,p_pem_information13_o
      => per_pem_shd.g_old_rec.pem_information13
      ,p_pem_information14_o
      => per_pem_shd.g_old_rec.pem_information14
      ,p_pem_information15_o
      => per_pem_shd.g_old_rec.pem_information15
      ,p_pem_information16_o
      => per_pem_shd.g_old_rec.pem_information16
      ,p_pem_information17_o
      => per_pem_shd.g_old_rec.pem_information17
      ,p_pem_information18_o
      => per_pem_shd.g_old_rec.pem_information18
      ,p_pem_information19_o
      => per_pem_shd.g_old_rec.pem_information19
      ,p_pem_information20_o
      => per_pem_shd.g_old_rec.pem_information20
      ,p_pem_information21_o
      => per_pem_shd.g_old_rec.pem_information21
      ,p_pem_information22_o
      => per_pem_shd.g_old_rec.pem_information22
      ,p_pem_information23_o
      => per_pem_shd.g_old_rec.pem_information23
      ,p_pem_information24_o
      => per_pem_shd.g_old_rec.pem_information24
      ,p_pem_information25_o
      => per_pem_shd.g_old_rec.pem_information25
      ,p_pem_information26_o
      => per_pem_shd.g_old_rec.pem_information26
      ,p_pem_information27_o
      => per_pem_shd.g_old_rec.pem_information27
      ,p_pem_information28_o
      => per_pem_shd.g_old_rec.pem_information28
      ,p_pem_information29_o
      => per_pem_shd.g_old_rec.pem_information29
      ,p_pem_information30_o
      => per_pem_shd.g_old_rec.pem_information30
      ,p_object_version_number_o
      => per_pem_shd.g_old_rec.object_version_number
      ,p_all_assignments_o
      => per_pem_shd.g_old_rec.all_assignments
      ,p_period_months_o
      => per_pem_shd.g_old_rec.period_months
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PREVIOUS_EMPLOYERS'
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
  (p_rec              in per_pem_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_pem_shd.lck
    (p_rec.previous_employer_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_pem_bus.delete_validate(p_rec);
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  per_pem_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_pem_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_pem_del.post_delete(p_rec);
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_previous_employer_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_pem_shd.g_rec_type;
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
  l_rec.previous_employer_id := p_previous_employer_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_pem_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_pem_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_pem_del;

/
