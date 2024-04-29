--------------------------------------------------------
--  DDL for Package Body BEN_ABI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABI_DEL" as
/* $Header: beabirhi.pkb 115.0 2003/09/23 10:13:59 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_abi_del.';  -- Global package name
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
--   A abr/Sql record structre.
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
--   Internal Table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in ben_abi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the ben_abr_extra_info row.
  --
  delete from ben_abr_extra_info
  where abr_extra_info_id = p_rec.abr_extra_info_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_abi_shd.constraint_error
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
--   A abr/Sql record structre.
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
--   maintenance should be reviewed before abracing in this procedure.
--
-- Access Status:
--   Internal Table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ben_abi_shd.g_rec_type) is
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
--   A abr/Sql record structre.
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
--   maintenance should be reviewed before abracing in this procedure.
--
-- Access Status:
--   Internal table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in ben_abi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     ben_abi_rkd.after_delete	(
	p_abr_extra_info_id_o		=>	ben_abi_shd.g_old_rec.abr_extra_info_id		,
	p_information_type_o		=>	ben_abi_shd.g_old_rec.information_type		,
	p_acty_base_rt_id_o				=>	ben_abi_shd.g_old_rec.acty_base_rt_id				,
	p_request_id_o			=>	ben_abi_shd.g_old_rec.request_id			,
	p_program_application_id_o	=>	ben_abi_shd.g_old_rec.program_application_id	,
	p_program_id_o			=>	ben_abi_shd.g_old_rec.program_id			,
	p_program_update_date_o		=>	ben_abi_shd.g_old_rec.program_update_date		,
	p_abi_attribute_category_o	=>	ben_abi_shd.g_old_rec.abi_attribute_category	,
	p_abi_attribute1_o		=>	ben_abi_shd.g_old_rec.abi_attribute1			,
	p_abi_attribute2_o		=>	ben_abi_shd.g_old_rec.abi_attribute2			,
	p_abi_attribute3_o		=>	ben_abi_shd.g_old_rec.abi_attribute3			,
	p_abi_attribute4_o		=>	ben_abi_shd.g_old_rec.abi_attribute4			,
	p_abi_attribute5_o		=>	ben_abi_shd.g_old_rec.abi_attribute5			,
	p_abi_attribute6_o		=>	ben_abi_shd.g_old_rec.abi_attribute6			,
	p_abi_attribute7_o		=>	ben_abi_shd.g_old_rec.abi_attribute7			,
	p_abi_attribute8_o		=>	ben_abi_shd.g_old_rec.abi_attribute8			,
	p_abi_attribute9_o		=>	ben_abi_shd.g_old_rec.abi_attribute9			,
	p_abi_attribute10_o		=>	ben_abi_shd.g_old_rec.abi_attribute10		,
	p_abi_attribute11_o		=>	ben_abi_shd.g_old_rec.abi_attribute11		,
	p_abi_attribute12_o		=>	ben_abi_shd.g_old_rec.abi_attribute12		,
	p_abi_attribute13_o		=>	ben_abi_shd.g_old_rec.abi_attribute13		,
	p_abi_attribute14_o		=>	ben_abi_shd.g_old_rec.abi_attribute14		,
	p_abi_attribute15_o		=>	ben_abi_shd.g_old_rec.abi_attribute15		,
	p_abi_attribute16_o		=>	ben_abi_shd.g_old_rec.abi_attribute16		,
	p_abi_attribute17_o		=>	ben_abi_shd.g_old_rec.abi_attribute17		,
	p_abi_attribute18_o		=>	ben_abi_shd.g_old_rec.abi_attribute18		,
	p_abi_attribute19_o		=>	ben_abi_shd.g_old_rec.abi_attribute19		,
	p_abi_attribute20_o		=>	ben_abi_shd.g_old_rec.abi_attribute20		,
	p_abi_information_category_o	=>	ben_abi_shd.g_old_rec.abi_information_category	,
	p_abi_information1_o		=>	ben_abi_shd.g_old_rec.abi_information1		,
	p_abi_information2_o		=>	ben_abi_shd.g_old_rec.abi_information2		,
	p_abi_information3_o		=>	ben_abi_shd.g_old_rec.abi_information3		,
	p_abi_information4_o		=>	ben_abi_shd.g_old_rec.abi_information4		,
	p_abi_information5_o		=>	ben_abi_shd.g_old_rec.abi_information5		,
	p_abi_information6_o		=>	ben_abi_shd.g_old_rec.abi_information6		,
	p_abi_information7_o		=>	ben_abi_shd.g_old_rec.abi_information7		,
	p_abi_information8_o		=>	ben_abi_shd.g_old_rec.abi_information8		,
	p_abi_information9_o		=>	ben_abi_shd.g_old_rec.abi_information9		,
	p_abi_information10_o		=>	ben_abi_shd.g_old_rec.abi_information10		,
	p_abi_information11_o		=>	ben_abi_shd.g_old_rec.abi_information11		,
	p_abi_information12_o		=>	ben_abi_shd.g_old_rec.abi_information12		,
	p_abi_information13_o		=>	ben_abi_shd.g_old_rec.abi_information13		,
	p_abi_information14_o		=>	ben_abi_shd.g_old_rec.abi_information14		,
	p_abi_information15_o		=>	ben_abi_shd.g_old_rec.abi_information15		,
	p_abi_information16_o		=>	ben_abi_shd.g_old_rec.abi_information16		,
	p_abi_information17_o		=>	ben_abi_shd.g_old_rec.abi_information17		,
	p_abi_information18_o		=>	ben_abi_shd.g_old_rec.abi_information18		,
	p_abi_information19_o		=>	ben_abi_shd.g_old_rec.abi_information19		,
	p_abi_information20_o		=>	ben_abi_shd.g_old_rec.abi_information20		,
	p_abi_information21_o		=>	ben_abi_shd.g_old_rec.abi_information21		,
	p_abi_information22_o		=>	ben_abi_shd.g_old_rec.abi_information22		,
	p_abi_information23_o		=>	ben_abi_shd.g_old_rec.abi_information23		,
	p_abi_information24_o		=>	ben_abi_shd.g_old_rec.abi_information24		,
	p_abi_information25_o		=>	ben_abi_shd.g_old_rec.abi_information25		,
	p_abi_information26_o		=>	ben_abi_shd.g_old_rec.abi_information26		,
	p_abi_information27_o		=>	ben_abi_shd.g_old_rec.abi_information27		,
	p_abi_information28_o		=>	ben_abi_shd.g_old_rec.abi_information28		,
	p_abi_information29_o		=>	ben_abi_shd.g_old_rec.abi_information29		,
	p_abi_information30_o		=>	ben_abi_shd.g_old_rec.abi_information30
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
  p_rec	      in ben_abi_shd.g_rec_type,
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
    SAVEPOINT del_ben_abi;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  ben_abi_shd.lck
	(
	p_rec.abr_extra_info_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_abi_bus.delete_validate(p_rec);
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
    ROLLBACK TO del_ben_abi;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_abr_extra_info_id                  in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  ben_abi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a abrsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.abr_extra_info_id:= p_abr_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_abi_rec
  -- abrsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_abi_del;

/
