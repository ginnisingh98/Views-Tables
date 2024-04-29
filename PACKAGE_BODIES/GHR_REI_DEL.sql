--------------------------------------------------------
--  DDL for Package Body GHR_REI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_REI_DEL" as
/* $Header: ghreirhi.pkb 120.2.12010000.2 2008/09/02 07:19:59 vmididho ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_rei_del.';  -- Global package name
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
--      perform dml). Not required changed by DARORA
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
--   g_api_dml status to false. Not required, changed by DARORA
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset. Not required, changed by DARORA
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in ghr_rei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Delete the ghr_pa_request_extra_info row.
  --
  delete from ghr_pa_request_extra_info
  where pa_request_extra_info_id = p_rec.pa_request_extra_info_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ghr_rei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_delete(p_rec in ghr_rei_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ghr_rei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     ghr_rei_rkd.after_delete	(
		p_pa_request_extra_info_id_o 	=>	ghr_rei_shd.g_old_rec.pa_request_extra_info_id	,
		p_pa_request_id_o		 	=>	ghr_rei_shd.g_old_rec.pa_request_id 		,
		p_information_type_o 		=>	ghr_rei_shd.g_old_rec.information_type		,
		p_rei_attribute_category_o	=>	ghr_rei_shd.g_old_rec.rei_attribute_category	,
		p_rei_attribute1_o	 	=>	ghr_rei_shd.g_old_rec.rei_attribute1		,
		p_rei_attribute2_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute2 		,
		p_rei_attribute3_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute3 		,
		p_rei_attribute4_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute4 		,
		p_rei_attribute5_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute5 		,
		p_rei_attribute6_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute6 		,
		p_rei_attribute7_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute7 		,
		p_rei_attribute8_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute8 		,
		p_rei_attribute9_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute9 		,
		p_rei_attribute10_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute10 		,
		p_rei_attribute11_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute11 		,
		p_rei_attribute12_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute12 		,
		p_rei_attribute13_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute13 		,
		p_rei_attribute14_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute14 		,
		p_rei_attribute15_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute15 		,
		p_rei_attribute16_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute16 		,
		p_rei_attribute17_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute17 		,
		p_rei_attribute18_o 		=>	ghr_rei_shd.g_old_rec.rei_attribute18 		,
		p_rei_attribute19_o		=>	ghr_rei_shd.g_old_rec.rei_attribute19		,
		p_rei_attribute20_o		=>	ghr_rei_shd.g_old_rec.rei_attribute20		,
		p_rei_information_category_o 	=>	ghr_rei_shd.g_old_rec.rei_information_category	,
		p_rei_information1_o		=>	ghr_rei_shd.g_old_rec.rei_information1 		,
		p_rei_information2_o 		=>	ghr_rei_shd.g_old_rec.rei_information2 		,
		p_rei_information3_o 		=>	ghr_rei_shd.g_old_rec.rei_information3 		,
		p_rei_information4_o 		=>	ghr_rei_shd.g_old_rec.rei_information4 		,
		p_rei_information5_o 		=>	ghr_rei_shd.g_old_rec.rei_information5 		,
		p_rei_information6_o 		=>	ghr_rei_shd.g_old_rec.rei_information6 		,
		p_rei_information7_o 		=>	ghr_rei_shd.g_old_rec.rei_information7 		,
		p_rei_information8_o 		=>	ghr_rei_shd.g_old_rec.rei_information8 		,
		p_rei_information9_o 		=>	ghr_rei_shd.g_old_rec.rei_information9 		,
		p_rei_information10_o 		=>	ghr_rei_shd.g_old_rec.rei_information10 		,
		p_rei_information11_o 		=>	ghr_rei_shd.g_old_rec.rei_information11 		,
		p_rei_information12_o 		=>	ghr_rei_shd.g_old_rec.rei_information12 		,
		p_rei_information13_o 		=>	ghr_rei_shd.g_old_rec.rei_information13 		,
		p_rei_information14_o 		=>	ghr_rei_shd.g_old_rec.rei_information14 		,
		p_rei_information15_o		=>	ghr_rei_shd.g_old_rec.rei_information15 		,
		p_rei_information16_o 		=>	ghr_rei_shd.g_old_rec.rei_information16 		,
		p_rei_information17_o		=>	ghr_rei_shd.g_old_rec.rei_information17 		,
		p_rei_information18_o 		=>	ghr_rei_shd.g_old_rec.rei_information18 		,
		p_rei_information19_o 		=>	ghr_rei_shd.g_old_rec.rei_information19 		,
		p_rei_information20_o 		=>	ghr_rei_shd.g_old_rec.rei_information20 		,
		p_rei_information21_o 		=>	ghr_rei_shd.g_old_rec.rei_information21 		,
		p_rei_information22_o 		=>	ghr_rei_shd.g_old_rec.rei_information22 		,
		p_rei_information28_o 		=>	ghr_rei_shd.g_old_rec.rei_information28 		,
		p_rei_information29_o 		=>	ghr_rei_shd.g_old_rec.rei_information29 		,
		p_rei_information23_o 		=>	ghr_rei_shd.g_old_rec.rei_information23 		,
		p_rei_information24_o 		=>	ghr_rei_shd.g_old_rec.rei_information24 		,
		p_rei_information25_o 		=>	ghr_rei_shd.g_old_rec.rei_information25 		,
		p_rei_information26_o 		=>	ghr_rei_shd.g_old_rec.rei_information26 		,
		p_rei_information27_o 		=>	ghr_rei_shd.g_old_rec.rei_information27 		,
		p_rei_information30_o 		=>	ghr_rei_shd.g_old_rec.rei_information30 		,
		p_request_id_o			=>	ghr_rei_shd.g_old_rec.request_id			,
		p_program_application_id_o 	=>	ghr_rei_shd.g_old_rec.program_application_id	,
		p_program_id_o 			=>	ghr_rei_shd.g_old_rec.program_id			,
		p_program_update_date_o 	=>	ghr_rei_shd.g_old_rec.program_update_date
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'GHR_PA_REQUEST_EXTRA_INFO'
			,p_hook_type  => 'AD'
	        );
  end;
  -- End of API User Hook for post_delete.
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	  in ghr_rei_shd.g_rec_type,
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
    SAVEPOINT del_ghr_rei;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  ghr_rei_shd.lck
	(
	p_rec.pa_request_extra_info_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ghr_rei_bus.delete_validate(p_rec);
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
    ROLLBACK TO del_ghr_rei;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_pa_request_extra_info_id           in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  ghr_rei_shd.g_rec_type;
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
  l_rec.pa_request_extra_info_id:= p_pa_request_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ghr_rei_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ghr_rei_del;

/
