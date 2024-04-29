--------------------------------------------------------
--  DDL for Package Body BEN_LRI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LRI_DEL" as
/* $Header: belrirhi.pkb 115.0 2003/09/23 10:18:35 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lri_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To delete the specified row from the schema using the primary key in
--      the predicates.
--   2) To trap any constraint violations that may have occurred.
--   3) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A ler/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in ben_lri_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the ben_ler_extra_info row.
  --
  delete from ben_ler_extra_info
  where ler_extra_info_id = p_rec.ler_extra_info_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_lri_shd.constraint_error
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
--   A ler/Sql record structre.
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
--   maintenance should be reviewed before leracing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ben_lri_shd.g_rec_type) is
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
--   A ler/Sql record structre.
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
--   maintenance should be reviewed before leracing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in ben_lri_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     ben_lri_rkd.after_delete	(
	p_ler_extra_info_id_o		=>	ben_lri_shd.g_old_rec.ler_extra_info_id		,
	p_information_type_o		=>	ben_lri_shd.g_old_rec.information_type		,
	p_ler_id_o				=>	ben_lri_shd.g_old_rec.ler_id				,
	p_request_id_o			=>	ben_lri_shd.g_old_rec.request_id			,
	p_program_application_id_o	=>	ben_lri_shd.g_old_rec.program_application_id	,
	p_program_id_o			=>	ben_lri_shd.g_old_rec.program_id			,
	p_program_update_date_o		=>	ben_lri_shd.g_old_rec.program_update_date		,
	p_lri_attribute_category_o	=>	ben_lri_shd.g_old_rec.lri_attribute_category	,
	p_lri_attribute1_o		=>	ben_lri_shd.g_old_rec.lri_attribute1			,
	p_lri_attribute2_o		=>	ben_lri_shd.g_old_rec.lri_attribute2			,
	p_lri_attribute3_o		=>	ben_lri_shd.g_old_rec.lri_attribute3			,
	p_lri_attribute4_o		=>	ben_lri_shd.g_old_rec.lri_attribute4			,
	p_lri_attribute5_o		=>	ben_lri_shd.g_old_rec.lri_attribute5			,
	p_lri_attribute6_o		=>	ben_lri_shd.g_old_rec.lri_attribute6			,
	p_lri_attribute7_o		=>	ben_lri_shd.g_old_rec.lri_attribute7			,
	p_lri_attribute8_o		=>	ben_lri_shd.g_old_rec.lri_attribute8			,
	p_lri_attribute9_o		=>	ben_lri_shd.g_old_rec.lri_attribute9			,
	p_lri_attribute10_o		=>	ben_lri_shd.g_old_rec.lri_attribute10		,
	p_lri_attribute11_o		=>	ben_lri_shd.g_old_rec.lri_attribute11		,
	p_lri_attribute12_o		=>	ben_lri_shd.g_old_rec.lri_attribute12		,
	p_lri_attribute13_o		=>	ben_lri_shd.g_old_rec.lri_attribute13		,
	p_lri_attribute14_o		=>	ben_lri_shd.g_old_rec.lri_attribute14		,
	p_lri_attribute15_o		=>	ben_lri_shd.g_old_rec.lri_attribute15		,
	p_lri_attribute16_o		=>	ben_lri_shd.g_old_rec.lri_attribute16		,
	p_lri_attribute17_o		=>	ben_lri_shd.g_old_rec.lri_attribute17		,
	p_lri_attribute18_o		=>	ben_lri_shd.g_old_rec.lri_attribute18		,
	p_lri_attribute19_o		=>	ben_lri_shd.g_old_rec.lri_attribute19		,
	p_lri_attribute20_o		=>	ben_lri_shd.g_old_rec.lri_attribute20		,
	p_lri_information_category_o	=>	ben_lri_shd.g_old_rec.lri_information_category	,
	p_lri_information1_o		=>	ben_lri_shd.g_old_rec.lri_information1		,
	p_lri_information2_o		=>	ben_lri_shd.g_old_rec.lri_information2		,
	p_lri_information3_o		=>	ben_lri_shd.g_old_rec.lri_information3		,
	p_lri_information4_o		=>	ben_lri_shd.g_old_rec.lri_information4		,
	p_lri_information5_o		=>	ben_lri_shd.g_old_rec.lri_information5		,
	p_lri_information6_o		=>	ben_lri_shd.g_old_rec.lri_information6		,
	p_lri_information7_o		=>	ben_lri_shd.g_old_rec.lri_information7		,
	p_lri_information8_o		=>	ben_lri_shd.g_old_rec.lri_information8		,
	p_lri_information9_o		=>	ben_lri_shd.g_old_rec.lri_information9		,
	p_lri_information10_o		=>	ben_lri_shd.g_old_rec.lri_information10		,
	p_lri_information11_o		=>	ben_lri_shd.g_old_rec.lri_information11		,
	p_lri_information12_o		=>	ben_lri_shd.g_old_rec.lri_information12		,
	p_lri_information13_o		=>	ben_lri_shd.g_old_rec.lri_information13		,
	p_lri_information14_o		=>	ben_lri_shd.g_old_rec.lri_information14		,
	p_lri_information15_o		=>	ben_lri_shd.g_old_rec.lri_information15		,
	p_lri_information16_o		=>	ben_lri_shd.g_old_rec.lri_information16		,
	p_lri_information17_o		=>	ben_lri_shd.g_old_rec.lri_information17		,
	p_lri_information18_o		=>	ben_lri_shd.g_old_rec.lri_information18		,
	p_lri_information19_o		=>	ben_lri_shd.g_old_rec.lri_information19		,
	p_lri_information20_o		=>	ben_lri_shd.g_old_rec.lri_information20		,
	p_lri_information21_o		=>	ben_lri_shd.g_old_rec.lri_information21		,
	p_lri_information22_o		=>	ben_lri_shd.g_old_rec.lri_information22		,
	p_lri_information23_o		=>	ben_lri_shd.g_old_rec.lri_information23		,
	p_lri_information24_o		=>	ben_lri_shd.g_old_rec.lri_information24		,
	p_lri_information25_o		=>	ben_lri_shd.g_old_rec.lri_information25		,
	p_lri_information26_o		=>	ben_lri_shd.g_old_rec.lri_information26		,
	p_lri_information27_o		=>	ben_lri_shd.g_old_rec.lri_information27		,
	p_lri_information28_o		=>	ben_lri_shd.g_old_rec.lri_information28		,
	p_lri_information29_o		=>	ben_lri_shd.g_old_rec.lri_information29		,
	p_lri_information30_o		=>	ben_lri_shd.g_old_rec.lri_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'BEN_LER_EXTRA_INFO'
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
  p_rec	      in ben_lri_shd.g_rec_type,
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
    SAVEPOINT del_ben_lri;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  ben_lri_shd.lck
	(
	p_rec.ler_extra_info_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_lri_bus.delete_validate(p_rec);
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
    ROLLBACK TO del_ben_lri;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_ler_extra_info_id                  in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  ben_lri_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a lersql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.ler_extra_info_id:= p_ler_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_lri_rec
  -- lersql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_lri_del;

/
