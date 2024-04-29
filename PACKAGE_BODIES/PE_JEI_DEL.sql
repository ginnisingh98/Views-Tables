--------------------------------------------------------
--  DDL for Package Body PE_JEI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_JEI_DEL" as
/* $Header: pejeirhi.pkb 115.8 2002/12/06 10:38:05 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_jei_del.';  -- Global package name
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
--   A Pl/Sql record structre.
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
Procedure delete_dml(p_rec in pe_jei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the per_job_extra_info row.
  --
  delete from per_job_extra_info
  where job_extra_info_id = p_rec.job_extra_info_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pe_jei_shd.constraint_error
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
Procedure pre_delete(p_rec in pe_jei_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pe_jei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     pe_jei_rkd.after_delete	(
	p_job_extra_info_id_o		=>	pe_jei_shd.g_old_rec.job_extra_info_id		,
	p_information_type_o		=>	pe_jei_shd.g_old_rec.information_type		,
	p_job_id_o				=>	pe_jei_shd.g_old_rec.job_id				,
	p_request_id_o			=>	pe_jei_shd.g_old_rec.request_id			,
	p_program_application_id_o	=>	pe_jei_shd.g_old_rec.program_application_id	,
	p_program_id_o			=>	pe_jei_shd.g_old_rec.program_id			,
	p_program_update_date_o		=>	pe_jei_shd.g_old_rec.program_update_date		,
	p_jei_attribute_category_o	=>	pe_jei_shd.g_old_rec.jei_attribute_category	,
	p_jei_attribute1_o		=>	pe_jei_shd.g_old_rec.jei_attribute1			,
	p_jei_attribute2_o		=>	pe_jei_shd.g_old_rec.jei_attribute2			,
	p_jei_attribute3_o		=>	pe_jei_shd.g_old_rec.jei_attribute3			,
	p_jei_attribute4_o		=>	pe_jei_shd.g_old_rec.jei_attribute4			,
	p_jei_attribute5_o		=>	pe_jei_shd.g_old_rec.jei_attribute5			,
	p_jei_attribute6_o		=>	pe_jei_shd.g_old_rec.jei_attribute6			,
	p_jei_attribute7_o		=>	pe_jei_shd.g_old_rec.jei_attribute7			,
	p_jei_attribute8_o		=>	pe_jei_shd.g_old_rec.jei_attribute8			,
	p_jei_attribute9_o		=>	pe_jei_shd.g_old_rec.jei_attribute9			,
	p_jei_attribute10_o		=>	pe_jei_shd.g_old_rec.jei_attribute10		,
	p_jei_attribute11_o		=>	pe_jei_shd.g_old_rec.jei_attribute11		,
	p_jei_attribute12_o		=>	pe_jei_shd.g_old_rec.jei_attribute12		,
	p_jei_attribute13_o		=>	pe_jei_shd.g_old_rec.jei_attribute13		,
	p_jei_attribute14_o		=>	pe_jei_shd.g_old_rec.jei_attribute14		,
	p_jei_attribute15_o		=>	pe_jei_shd.g_old_rec.jei_attribute15		,
	p_jei_attribute16_o		=>	pe_jei_shd.g_old_rec.jei_attribute16		,
	p_jei_attribute17_o		=>	pe_jei_shd.g_old_rec.jei_attribute17		,
	p_jei_attribute18_o		=>	pe_jei_shd.g_old_rec.jei_attribute18		,
	p_jei_attribute19_o		=>	pe_jei_shd.g_old_rec.jei_attribute19		,
	p_jei_attribute20_o		=>	pe_jei_shd.g_old_rec.jei_attribute20		,
	p_jei_information_category_o	=>	pe_jei_shd.g_old_rec.jei_information_category	,
	p_jei_information1_o		=>	pe_jei_shd.g_old_rec.jei_information1		,
	p_jei_information2_o		=>	pe_jei_shd.g_old_rec.jei_information2		,
	p_jei_information3_o		=>	pe_jei_shd.g_old_rec.jei_information3		,
	p_jei_information4_o		=>	pe_jei_shd.g_old_rec.jei_information4		,
	p_jei_information5_o		=>	pe_jei_shd.g_old_rec.jei_information5		,
	p_jei_information6_o		=>	pe_jei_shd.g_old_rec.jei_information6		,
	p_jei_information7_o		=>	pe_jei_shd.g_old_rec.jei_information7		,
	p_jei_information8_o		=>	pe_jei_shd.g_old_rec.jei_information8		,
	p_jei_information9_o		=>	pe_jei_shd.g_old_rec.jei_information9		,
	p_jei_information10_o		=>	pe_jei_shd.g_old_rec.jei_information10		,
	p_jei_information11_o		=>	pe_jei_shd.g_old_rec.jei_information11		,
	p_jei_information12_o		=>	pe_jei_shd.g_old_rec.jei_information12		,
	p_jei_information13_o		=>	pe_jei_shd.g_old_rec.jei_information13		,
	p_jei_information14_o		=>	pe_jei_shd.g_old_rec.jei_information14		,
	p_jei_information15_o		=>	pe_jei_shd.g_old_rec.jei_information15		,
	p_jei_information16_o		=>	pe_jei_shd.g_old_rec.jei_information16		,
	p_jei_information17_o		=>	pe_jei_shd.g_old_rec.jei_information17		,
	p_jei_information18_o		=>	pe_jei_shd.g_old_rec.jei_information18		,
	p_jei_information19_o		=>	pe_jei_shd.g_old_rec.jei_information19		,
	p_jei_information20_o		=>	pe_jei_shd.g_old_rec.jei_information20		,
	p_jei_information21_o		=>	pe_jei_shd.g_old_rec.jei_information21		,
	p_jei_information22_o		=>	pe_jei_shd.g_old_rec.jei_information22		,
	p_jei_information23_o		=>	pe_jei_shd.g_old_rec.jei_information23		,
	p_jei_information24_o		=>	pe_jei_shd.g_old_rec.jei_information24		,
	p_jei_information25_o		=>	pe_jei_shd.g_old_rec.jei_information25		,
	p_jei_information26_o		=>	pe_jei_shd.g_old_rec.jei_information26		,
	p_jei_information27_o		=>	pe_jei_shd.g_old_rec.jei_information27		,
	p_jei_information28_o		=>	pe_jei_shd.g_old_rec.jei_information28		,
	p_jei_information29_o		=>	pe_jei_shd.g_old_rec.jei_information29		,
	p_jei_information30_o		=>	pe_jei_shd.g_old_rec.jei_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_JOB_EXTRA_INFO'
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
  p_rec	      in pe_jei_shd.g_rec_type,
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
    SAVEPOINT del_pe_jei;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  pe_jei_shd.lck
	(
	p_rec.job_extra_info_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pe_jei_bus.delete_validate(p_rec);
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
    ROLLBACK TO del_pe_jei;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_job_extra_info_id                  in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  pe_jei_shd.g_rec_type;
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
  l_rec.job_extra_info_id:= p_job_extra_info_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pe_jei_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pe_jei_del;

/
