--------------------------------------------------------
--  DDL for Package Body BEN_XFI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XFI_DEL" as
/* $Header: bexfirhi.pkb 120.0 2005/05/28 12:33:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xfi_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Deletes row(s) from hr_application_ownerships depending on the mode that
--   the row handler has been called in.
--
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column  IN  varchar2
                               ,p_pk_value   IN  varchar2) IS
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode
                           IN ('STARTUP','GENERIC')) THEN
     --
     DELETE FROM hr_application_ownerships
      WHERE key_name = p_pk_column
        AND key_value = p_pk_value;
     --
  END IF;
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  delete_app_ownerships(p_pk_column, to_char(p_pk_value));
END delete_app_ownerships;
--
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
Procedure delete_dml(p_rec in ben_xfi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_xfi_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_ext_file row.
  --
  delete from ben_ext_file
  where ext_file_id = p_rec.ext_file_id;
  --
  ben_xfi_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_xfi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xfi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xfi_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_xfi_shd.g_rec_type) is
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
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in ben_xfi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    --
    -- Delete ownerships if applicable
    --
    delete_app_ownerships('EXT_FILE_ID', p_rec.ext_file_id);
    --
    ben_xfi_rkd.after_delete
      (
  p_ext_file_id                   =>p_rec.ext_file_id
 ,p_name_o                        =>ben_xfi_shd.g_old_rec.name
 ,p_xml_tag_name_o                =>ben_xfi_shd.g_old_rec.xml_tag_name
 ,p_business_group_id_o           =>ben_xfi_shd.g_old_rec.business_group_id
 ,p_legislation_code_o            =>ben_xfi_shd.g_old_rec.legislation_code
 ,p_xfi_attribute_category_o      =>ben_xfi_shd.g_old_rec.xfi_attribute_category
 ,p_xfi_attribute1_o              =>ben_xfi_shd.g_old_rec.xfi_attribute1
 ,p_xfi_attribute2_o              =>ben_xfi_shd.g_old_rec.xfi_attribute2
 ,p_xfi_attribute3_o              =>ben_xfi_shd.g_old_rec.xfi_attribute3
 ,p_xfi_attribute4_o              =>ben_xfi_shd.g_old_rec.xfi_attribute4
 ,p_xfi_attribute5_o              =>ben_xfi_shd.g_old_rec.xfi_attribute5
 ,p_xfi_attribute6_o              =>ben_xfi_shd.g_old_rec.xfi_attribute6
 ,p_xfi_attribute7_o              =>ben_xfi_shd.g_old_rec.xfi_attribute7
 ,p_xfi_attribute8_o              =>ben_xfi_shd.g_old_rec.xfi_attribute8
 ,p_xfi_attribute9_o              =>ben_xfi_shd.g_old_rec.xfi_attribute9
 ,p_xfi_attribute10_o             =>ben_xfi_shd.g_old_rec.xfi_attribute10
 ,p_xfi_attribute11_o             =>ben_xfi_shd.g_old_rec.xfi_attribute11
 ,p_xfi_attribute12_o             =>ben_xfi_shd.g_old_rec.xfi_attribute12
 ,p_xfi_attribute13_o             =>ben_xfi_shd.g_old_rec.xfi_attribute13
 ,p_xfi_attribute14_o             =>ben_xfi_shd.g_old_rec.xfi_attribute14
 ,p_xfi_attribute15_o             =>ben_xfi_shd.g_old_rec.xfi_attribute15
 ,p_xfi_attribute16_o             =>ben_xfi_shd.g_old_rec.xfi_attribute16
 ,p_xfi_attribute17_o             =>ben_xfi_shd.g_old_rec.xfi_attribute17
 ,p_xfi_attribute18_o             =>ben_xfi_shd.g_old_rec.xfi_attribute18
 ,p_xfi_attribute19_o             =>ben_xfi_shd.g_old_rec.xfi_attribute19
 ,p_xfi_attribute20_o             =>ben_xfi_shd.g_old_rec.xfi_attribute20
 ,p_xfi_attribute21_o             =>ben_xfi_shd.g_old_rec.xfi_attribute21
 ,p_xfi_attribute22_o             =>ben_xfi_shd.g_old_rec.xfi_attribute22
 ,p_xfi_attribute23_o             =>ben_xfi_shd.g_old_rec.xfi_attribute23
 ,p_xfi_attribute24_o             =>ben_xfi_shd.g_old_rec.xfi_attribute24
 ,p_xfi_attribute25_o             =>ben_xfi_shd.g_old_rec.xfi_attribute25
 ,p_xfi_attribute26_o             =>ben_xfi_shd.g_old_rec.xfi_attribute26
 ,p_xfi_attribute27_o             =>ben_xfi_shd.g_old_rec.xfi_attribute27
 ,p_xfi_attribute28_o             =>ben_xfi_shd.g_old_rec.xfi_attribute28
 ,p_xfi_attribute29_o             =>ben_xfi_shd.g_old_rec.xfi_attribute29
 ,p_xfi_attribute30_o             =>ben_xfi_shd.g_old_rec.xfi_attribute30
 ,p_ext_rcd_in_file_id_o          => ben_xfi_shd.g_old_rec.ext_rcd_in_file_id
 ,p_ext_data_elmt_in_rcd_id1_o    => ben_xfi_shd.g_old_rec.ext_data_elmt_in_rcd_id1
 ,p_ext_data_elmt_in_rcd_id2_o    => ben_xfi_shd.g_old_rec.ext_data_elmt_in_rcd_id2
 ,p_object_version_number_o       =>ben_xfi_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ext_file'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in ben_xfi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_xfi_shd.lck
	(
	p_rec.ext_file_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_xfi_bus.delete_validate(p_rec);
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
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_ext_file_id                        in number,
  p_legislation_code                   in varchar2 default null,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_xfi_shd.g_rec_type;
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
  l_rec.ext_file_id:= p_ext_file_id;
  l_rec.legislation_code := p_legislation_code;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_xfi_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_xfi_del;

/
