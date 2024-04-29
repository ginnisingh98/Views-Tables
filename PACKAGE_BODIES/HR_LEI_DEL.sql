--------------------------------------------------------
--  DDL for Package Body HR_LEI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEI_DEL" as
/* $Header: hrleirhi.pkb 120.1.12010000.2 2009/01/28 09:08:21 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_lei_del.';  -- Global package name
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
Procedure delete_dml(p_rec in hr_lei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- hr_lei_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the hr_location_extra_info row.
  --
  delete from hr_location_extra_info
  where location_extra_info_id = p_rec.location_extra_info_id;
  --
  -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
    hr_lei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in hr_lei_shd.g_rec_type) is
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
Procedure post_delete(p_rec in hr_lei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     hr_lei_rkd.after_delete	(
	p_location_extra_info_id_o	=>	hr_lei_shd.g_old_rec.location_extra_info_id,
	p_information_type_o		=>	hr_lei_shd.g_old_rec.information_type,
	p_location_id_o			=>	hr_lei_shd.g_old_rec.location_id,
	p_request_id_o			=>	hr_lei_shd.g_old_rec.request_id	,
	p_program_application_id_o	=>	hr_lei_shd.g_old_rec.program_application_id,
	p_program_id_o			=>	hr_lei_shd.g_old_rec.program_id	,
	p_program_update_date_o		=>	hr_lei_shd.g_old_rec.program_update_date,
	p_lei_attribute_category_o	=>	hr_lei_shd.g_old_rec.lei_attribute_category,
	p_lei_attribute1_o		=>	hr_lei_shd.g_old_rec.lei_attribute1,
	p_lei_attribute2_o		=>	hr_lei_shd.g_old_rec.lei_attribute2,
	p_lei_attribute3_o		=>	hr_lei_shd.g_old_rec.lei_attribute3,
	p_lei_attribute4_o		=>	hr_lei_shd.g_old_rec.lei_attribute4,
	p_lei_attribute5_o		=>	hr_lei_shd.g_old_rec.lei_attribute5,
	p_lei_attribute6_o		=>	hr_lei_shd.g_old_rec.lei_attribute6,
	p_lei_attribute7_o		=>	hr_lei_shd.g_old_rec.lei_attribute7,
	p_lei_attribute8_o		=>	hr_lei_shd.g_old_rec.lei_attribute8,
	p_lei_attribute9_o		=>	hr_lei_shd.g_old_rec.lei_attribute9,
	p_lei_attribute10_o		=>	hr_lei_shd.g_old_rec.lei_attribute10,
	p_lei_attribute11_o		=>	hr_lei_shd.g_old_rec.lei_attribute11,
	p_lei_attribute12_o		=>	hr_lei_shd.g_old_rec.lei_attribute12,
	p_lei_attribute13_o		=>	hr_lei_shd.g_old_rec.lei_attribute13,
	p_lei_attribute14_o		=>	hr_lei_shd.g_old_rec.lei_attribute14,
	p_lei_attribute15_o		=>	hr_lei_shd.g_old_rec.lei_attribute15,
	p_lei_attribute16_o		=>	hr_lei_shd.g_old_rec.lei_attribute16,
	p_lei_attribute17_o		=>	hr_lei_shd.g_old_rec.lei_attribute17,
	p_lei_attribute18_o		=>	hr_lei_shd.g_old_rec.lei_attribute18,
	p_lei_attribute19_o		=>	hr_lei_shd.g_old_rec.lei_attribute19,
	p_lei_attribute20_o		=>	hr_lei_shd.g_old_rec.lei_attribute20,
	p_lei_information_category_o	=>	hr_lei_shd.g_old_rec.lei_information_category,
	p_lei_information1_o		=>	hr_lei_shd.g_old_rec.lei_information1,
	p_lei_information2_o		=>	hr_lei_shd.g_old_rec.lei_information2,
	p_lei_information3_o		=>	hr_lei_shd.g_old_rec.lei_information3,
	p_lei_information4_o		=>	hr_lei_shd.g_old_rec.lei_information4,
	p_lei_information5_o		=>	hr_lei_shd.g_old_rec.lei_information5,
	p_lei_information6_o		=>	hr_lei_shd.g_old_rec.lei_information6,
	p_lei_information7_o		=>	hr_lei_shd.g_old_rec.lei_information7,
	p_lei_information8_o		=>	hr_lei_shd.g_old_rec.lei_information8,
	p_lei_information9_o		=>	hr_lei_shd.g_old_rec.lei_information9,
	p_lei_information10_o		=>	hr_lei_shd.g_old_rec.lei_information10,
	p_lei_information11_o		=>	hr_lei_shd.g_old_rec.lei_information11,
	p_lei_information12_o		=>	hr_lei_shd.g_old_rec.lei_information12,
	p_lei_information13_o		=>	hr_lei_shd.g_old_rec.lei_information13,
	p_lei_information14_o		=>	hr_lei_shd.g_old_rec.lei_information14,
	p_lei_information15_o		=>	hr_lei_shd.g_old_rec.lei_information15,
	p_lei_information16_o		=>	hr_lei_shd.g_old_rec.lei_information16,
	p_lei_information17_o		=>	hr_lei_shd.g_old_rec.lei_information17,
	p_lei_information18_o		=>	hr_lei_shd.g_old_rec.lei_information18,
	p_lei_information19_o		=>	hr_lei_shd.g_old_rec.lei_information19,
	p_lei_information20_o		=>	hr_lei_shd.g_old_rec.lei_information20,
	p_lei_information21_o		=>	hr_lei_shd.g_old_rec.lei_information21,
	p_lei_information22_o		=>	hr_lei_shd.g_old_rec.lei_information22,
	p_lei_information23_o		=>	hr_lei_shd.g_old_rec.lei_information23,
	p_lei_information24_o		=>	hr_lei_shd.g_old_rec.lei_information24,
	p_lei_information25_o		=>	hr_lei_shd.g_old_rec.lei_information25,
	p_lei_information26_o		=>	hr_lei_shd.g_old_rec.lei_information26,
	p_lei_information27_o		=>	hr_lei_shd.g_old_rec.lei_information27,
	p_lei_information28_o		=>	hr_lei_shd.g_old_rec.lei_information28,
	p_lei_information29_o		=>	hr_lei_shd.g_old_rec.lei_information29,
	p_lei_information30_o		=>	hr_lei_shd.g_old_rec.lei_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'HR_LOCATION_EXTRA_INFO'
			,p_hook_type  => 'AD'
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
  p_rec	      in hr_lei_shd.g_rec_type,
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
    SAVEPOINT del_hr_lei;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  hr_lei_shd.lck
	(
	p_rec.location_extra_info_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  hr_lei_bus.delete_validate(p_rec);
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
    ROLLBACK TO del_hr_lei;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_location_extra_info_id             in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  hr_lei_shd.g_rec_type;
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
  l_rec.location_extra_info_id:= p_location_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hr_lei_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_lei_del;

/
