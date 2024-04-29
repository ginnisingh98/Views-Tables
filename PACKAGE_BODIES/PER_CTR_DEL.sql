--------------------------------------------------------
--  DDL for Package Body PER_CTR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTR_DEL" as
/* $Header: pectrrhi.pkb 120.2.12010000.3 2009/04/09 13:42:18 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ctr_del.';  -- Global package name
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in per_ctr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_ctr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the per_contact_relationships row.
  --
  delete from per_contact_relationships
  where contact_relationship_id = p_rec.contact_relationship_id;
  --
  per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
    per_ctr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_ctr_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in per_ctr_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Pre Conditions:
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
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in per_ctr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  begin
    per_ctr_rkd.after_delete
      (p_contact_relationship_id        => p_rec.contact_relationship_id
      ,p_business_group_id_o
          => per_ctr_shd.g_old_rec.business_group_id
      ,p_person_id_o
          => per_ctr_shd.g_old_rec.person_id
      ,p_contact_person_id_o
          => per_ctr_shd.g_old_rec.contact_person_id
      ,p_contact_type_o
          => per_ctr_shd.g_old_rec.contact_type
      ,p_comments_o
          => per_ctr_shd.g_old_rec.comments
      ,p_primary_contact_flag_o
          => per_ctr_shd.g_old_rec.primary_contact_flag
      ,p_request_id_o
          => per_ctr_shd.g_old_rec.request_id
      ,p_program_application_id_o
          => per_ctr_shd.g_old_rec.program_application_id
      ,p_program_id_o
          => per_ctr_shd.g_old_rec.program_id
      ,p_program_update_date_o
          => per_ctr_shd.g_old_rec.program_update_date
      ,p_date_start_o
          => per_ctr_shd.g_old_rec.date_start
      ,p_start_life_id_o
          => per_ctr_shd.g_old_rec.start_life_reason_id
      ,p_date_end_o
          => per_ctr_shd.g_old_rec.date_end
      ,p_end_life_id_o
          => per_ctr_shd.g_old_rec.end_life_reason_id
      ,p_rltd_per_dsgntr_flag_o
         => per_ctr_shd.g_old_rec.rltd_per_rsds_w_dsgntr_flag
      ,p_personal_flag_o
         => per_ctr_shd.g_old_rec.personal_flag
      ,p_sequence_number_o
    => per_ctr_shd.g_old_rec.sequence_number
      ,p_cont_attribute_category_o
          => per_ctr_shd.g_old_rec.cont_attribute_category
      ,p_cont_attribute1_o
          => per_ctr_shd.g_old_rec.cont_attribute1
      ,p_cont_attribute2_o
          => per_ctr_shd.g_old_rec.cont_attribute2
      ,p_cont_attribute3_o
          => per_ctr_shd.g_old_rec.cont_attribute3
      ,p_cont_attribute4_o
          => per_ctr_shd.g_old_rec.cont_attribute4
      ,p_cont_attribute5_o
          => per_ctr_shd.g_old_rec.cont_attribute5
      ,p_cont_attribute6_o
          => per_ctr_shd.g_old_rec.cont_attribute6
      ,p_cont_attribute7_o
          => per_ctr_shd.g_old_rec.cont_attribute7
      ,p_cont_attribute8_o
          => per_ctr_shd.g_old_rec.cont_attribute8
      ,p_cont_attribute9_o
          => per_ctr_shd.g_old_rec.cont_attribute9
      ,p_cont_attribute10_o
          => per_ctr_shd.g_old_rec.cont_attribute10
      ,p_cont_attribute11_o
          => per_ctr_shd.g_old_rec.cont_attribute11
      ,p_cont_attribute12_o
          => per_ctr_shd.g_old_rec.cont_attribute12
      ,p_cont_attribute13_o
          => per_ctr_shd.g_old_rec.cont_attribute13
      ,p_cont_attribute14_o
          => per_ctr_shd.g_old_rec.cont_attribute14
      ,p_cont_attribute15_o
          => per_ctr_shd.g_old_rec.cont_attribute15
      ,p_cont_attribute16_o
          => per_ctr_shd.g_old_rec.cont_attribute16
      ,p_cont_attribute17_o
          => per_ctr_shd.g_old_rec.cont_attribute17
      ,p_cont_attribute18_o
          => per_ctr_shd.g_old_rec.cont_attribute18
      ,p_cont_attribute19_o
          => per_ctr_shd.g_old_rec.cont_attribute19
      ,p_cont_attribute20_o
          => per_ctr_shd.g_old_rec.cont_attribute20
      ,p_cont_information_category_o
          => per_ctr_shd.g_old_rec.cont_information_category
      ,p_cont_information1_o
          => per_ctr_shd.g_old_rec.cont_information1
      ,p_cont_information2_o
          => per_ctr_shd.g_old_rec.cont_information2
      ,p_cont_information3_o
          => per_ctr_shd.g_old_rec.cont_information3
      ,p_cont_information4_o
          => per_ctr_shd.g_old_rec.cont_information4
      ,p_cont_information5_o
          => per_ctr_shd.g_old_rec.cont_information5
      ,p_cont_information6_o
          => per_ctr_shd.g_old_rec.cont_information6
      ,p_cont_information7_o
          => per_ctr_shd.g_old_rec.cont_information7
      ,p_cont_information8_o
          => per_ctr_shd.g_old_rec.cont_information8
      ,p_cont_information9_o
          => per_ctr_shd.g_old_rec.cont_information9
      ,p_cont_information10_o
          => per_ctr_shd.g_old_rec.cont_information10
      ,p_cont_information11_o
          => per_ctr_shd.g_old_rec.cont_information11
      ,p_cont_information12_o
          => per_ctr_shd.g_old_rec.cont_information12
      ,p_cont_information13_o
          => per_ctr_shd.g_old_rec.cont_information13
      ,p_cont_information14_o
          => per_ctr_shd.g_old_rec.cont_information14
      ,p_cont_information15_o
          => per_ctr_shd.g_old_rec.cont_information15
      ,p_cont_information16_o
          => per_ctr_shd.g_old_rec.cont_information16
      ,p_cont_information17_o
          => per_ctr_shd.g_old_rec.cont_information17
      ,p_cont_information18_o
          => per_ctr_shd.g_old_rec.cont_information18
      ,p_cont_information19_o
          => per_ctr_shd.g_old_rec.cont_information19
      ,p_cont_information20_o
          => per_ctr_shd.g_old_rec.cont_information20
      ,p_third_party_pay_flag_o
          => per_ctr_shd.g_old_rec.third_party_pay_flag
      ,p_bondholder_flag_o
          => per_ctr_shd.g_old_rec.bondholder_flag
      ,p_dependent_flag_o
          => per_ctr_shd.g_old_rec.dependent_flag
      ,p_beneficiary_flag_o
          => per_ctr_shd.g_old_rec.beneficiary_flag
      ,p_object_version_number_o
          => per_ctr_shd.g_old_rec.object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CONTACT_RELATIONSHIPS'
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
  p_rec        in per_ctr_shd.g_rec_type,
  p_validate  in boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
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
    SAVEPOINT del_per_ctr;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  per_ctr_shd.lck
   (
   p_rec.contact_relationship_id,
   p_rec.object_version_number
   );
  --
  -- Call the supporting delete validate operation
  --
  per_ctr_bus.delete_validate(p_rec);
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
    ROLLBACK TO del_per_ctr;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_contact_relationship_id            in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec    per_ctr_shd.g_rec_type;
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
  l_rec.contact_relationship_id:= p_contact_relationship_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_ctr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_ctr_del;

/
