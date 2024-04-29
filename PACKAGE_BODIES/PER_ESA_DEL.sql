--------------------------------------------------------
--  DDL for Package Body PER_ESA_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ESA_DEL" as
/* $Header: peesarhi.pkb 120.0.12010000.4 2009/07/01 08:09:14 psugumar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_esa_del.';  -- Global package name
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
Procedure delete_dml(p_rec in per_esa_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_esa_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the per_establish_attendances row.
  --
  delete from per_establishment_attendances
  where attendance_id = p_rec.attendance_id;
  --
  per_esa_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_esa_shd.g_api_dml := false;   -- Unset the api dml status
    per_esa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_esa_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in per_esa_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_esa_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Start of API User Hook for post_delete.
  begin
    per_esa_rkd.after_delete
      (p_attendance_id            =>p_rec.attendance_id,
       p_person_id_o              =>per_esa_shd.g_old_rec.person_id,
       p_establishment_id_o       =>per_esa_shd.g_old_rec.establishment_id,
       p_establishment_o          =>per_esa_shd.g_old_rec.establishment,
       p_attended_start_date_o    =>per_esa_shd.g_old_rec.attended_start_date,
       p_attended_end_date_o      =>per_esa_shd.g_old_rec.attended_end_date,
       p_full_time_o              =>per_esa_shd.g_old_rec.full_time,
       p_attribute_category_o     =>per_esa_shd.g_old_rec.attribute_category,
       p_attribute1_o             =>per_esa_shd.g_old_rec.attribute1,
       p_attribute2_o             =>per_esa_shd.g_old_rec.attribute2,
       p_attribute3_o             =>per_esa_shd.g_old_rec.attribute3,
       p_attribute4_o             =>per_esa_shd.g_old_rec.attribute4,
       p_attribute5_o             =>per_esa_shd.g_old_rec.attribute5,
       p_attribute6_o             =>per_esa_shd.g_old_rec.attribute6,
       p_attribute7_o             =>per_esa_shd.g_old_rec.attribute7,
       p_attribute8_o             =>per_esa_shd.g_old_rec.attribute8,
       p_attribute9_o             =>per_esa_shd.g_old_rec.attribute9,
       p_attribute10_o            =>per_esa_shd.g_old_rec.attribute10,
       p_attribute11_o            =>per_esa_shd.g_old_rec.attribute11,
       p_attribute12_o            =>per_esa_shd.g_old_rec.attribute12,
       p_attribute13_o            =>per_esa_shd.g_old_rec.attribute13,
       p_attribute14_o            =>per_esa_shd.g_old_rec.attribute14,
       p_attribute15_o            =>per_esa_shd.g_old_rec.attribute15,
       p_attribute16_o            =>per_esa_shd.g_old_rec.attribute16,
       p_attribute17_o            =>per_esa_shd.g_old_rec.attribute17,
       p_attribute18_o            =>per_esa_shd.g_old_rec.attribute18,
       p_attribute19_o            =>per_esa_shd.g_old_rec.attribute19,
       p_attribute20_o            =>per_esa_shd.g_old_rec.attribute20,
       p_object_version_number_o  =>per_esa_shd.g_old_rec.object_version_number,
       p_business_group_id_o      =>per_esa_shd.g_old_rec.business_group_id,
       p_party_id_o               =>per_esa_shd.g_old_rec.party_id, -- HR/TCA merge
       p_address_o		  =>per_esa_shd.g_old_rec.address
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ESTABLISHMENT_ATTENDANCES'
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
  p_rec	      in per_esa_shd.g_rec_type,
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
    SAVEPOINT del_per_esa;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  per_esa_shd.lck
	(
	p_rec.attendance_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  per_esa_bus.delete_validate(p_rec);
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
    ROLLBACK TO del_per_esa;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_attendance_id                      in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  per_esa_shd.g_rec_type;
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
  l_rec.attendance_id         := p_attendance_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_esa_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_esa_del;

/