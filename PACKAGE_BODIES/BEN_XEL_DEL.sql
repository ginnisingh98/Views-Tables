--------------------------------------------------------
--  DDL for Package Body BEN_XEL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XEL_DEL" as
/* $Header: bexelrhi.pkb 120.1 2005/06/08 13:15:34 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xel_del.';  -- Global package name
--
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
Procedure delete_dml(p_rec in ben_xel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_xel_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_ext_data_elmt row.
  --
  delete from ben_ext_data_elmt
  where ext_data_elmt_id = p_rec.ext_data_elmt_id;
  --
  ben_xel_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_xel_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xel_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_xel_shd.g_rec_type) is
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
Procedure post_delete(
p_effective_date in date,p_rec in ben_xel_shd.g_rec_type) is
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
    -- Delete ownerships if applicable
    --
    delete_app_ownerships('EXT_DATA_ELMT_ID', p_rec.ext_data_elmt_id);
    --
    --
    ben_xel_rkd.after_delete
      (
  p_ext_data_elmt_id              =>p_rec.ext_data_elmt_id
 ,p_name_o                        =>ben_xel_shd.g_old_rec.name
 ,p_xml_tag_name_o                =>ben_xel_shd.g_old_rec.name
 ,p_data_elmt_typ_cd_o            =>ben_xel_shd.g_old_rec.data_elmt_typ_cd
 ,p_data_elmt_rl_o                =>ben_xel_shd.g_old_rec.data_elmt_rl
 ,p_frmt_mask_cd_o                =>ben_xel_shd.g_old_rec.frmt_mask_cd
 ,p_string_val_o                  =>ben_xel_shd.g_old_rec.string_val
 ,p_dflt_val_o                    =>ben_xel_shd.g_old_rec.dflt_val
 ,p_max_length_num_o              =>ben_xel_shd.g_old_rec.max_length_num
 ,p_just_cd_o                    =>ben_xel_shd.g_old_rec.just_cd
	,p_ttl_fnctn_cd_o		   =>ben_xel_shd.g_old_rec.ttl_fnctn_cd,
	p_ttl_cond_oper_cd_o	=>ben_xel_shd.g_old_rec.ttl_cond_oper_cd,
	p_ttl_cond_val_o		=>ben_xel_shd.g_old_rec.ttl_cond_val,
	p_ttl_sum_ext_data_elmt_id_o		=>ben_xel_shd.g_old_rec.ttl_sum_ext_data_elmt_id,
       p_ttl_cond_ext_data_elmt_id_o		=>ben_xel_shd.g_old_rec.ttl_cond_ext_data_elmt_id ,
 p_ext_fld_id_o                  =>ben_xel_shd.g_old_rec.ext_fld_id
 ,p_business_group_id_o           =>ben_xel_shd.g_old_rec.business_group_id
 ,p_legislation_code_o            =>ben_xel_shd.g_old_rec.legislation_code
 ,p_xel_attribute_category_o      =>ben_xel_shd.g_old_rec.xel_attribute_category
 ,p_xel_attribute1_o              =>ben_xel_shd.g_old_rec.xel_attribute1
 ,p_xel_attribute2_o              =>ben_xel_shd.g_old_rec.xel_attribute2
 ,p_xel_attribute3_o              =>ben_xel_shd.g_old_rec.xel_attribute3
 ,p_xel_attribute4_o              =>ben_xel_shd.g_old_rec.xel_attribute4
 ,p_xel_attribute5_o              =>ben_xel_shd.g_old_rec.xel_attribute5
 ,p_xel_attribute6_o              =>ben_xel_shd.g_old_rec.xel_attribute6
 ,p_xel_attribute7_o              =>ben_xel_shd.g_old_rec.xel_attribute7
 ,p_xel_attribute8_o              =>ben_xel_shd.g_old_rec.xel_attribute8
 ,p_xel_attribute9_o              =>ben_xel_shd.g_old_rec.xel_attribute9
 ,p_xel_attribute10_o             =>ben_xel_shd.g_old_rec.xel_attribute10
 ,p_xel_attribute11_o             =>ben_xel_shd.g_old_rec.xel_attribute11
 ,p_xel_attribute12_o             =>ben_xel_shd.g_old_rec.xel_attribute12
 ,p_xel_attribute13_o             =>ben_xel_shd.g_old_rec.xel_attribute13
 ,p_xel_attribute14_o             =>ben_xel_shd.g_old_rec.xel_attribute14
 ,p_xel_attribute15_o             =>ben_xel_shd.g_old_rec.xel_attribute15
 ,p_xel_attribute16_o             =>ben_xel_shd.g_old_rec.xel_attribute16
 ,p_xel_attribute17_o             =>ben_xel_shd.g_old_rec.xel_attribute17
 ,p_xel_attribute18_o             =>ben_xel_shd.g_old_rec.xel_attribute18
 ,p_xel_attribute19_o             =>ben_xel_shd.g_old_rec.xel_attribute19
 ,p_xel_attribute20_o             =>ben_xel_shd.g_old_rec.xel_attribute20
 ,p_xel_attribute21_o             =>ben_xel_shd.g_old_rec.xel_attribute21
 ,p_xel_attribute22_o             =>ben_xel_shd.g_old_rec.xel_attribute22
 ,p_xel_attribute23_o             =>ben_xel_shd.g_old_rec.xel_attribute23
 ,p_xel_attribute24_o             =>ben_xel_shd.g_old_rec.xel_attribute24
 ,p_xel_attribute25_o             =>ben_xel_shd.g_old_rec.xel_attribute25
 ,p_xel_attribute26_o             =>ben_xel_shd.g_old_rec.xel_attribute26
 ,p_xel_attribute27_o             =>ben_xel_shd.g_old_rec.xel_attribute27
 ,p_xel_attribute28_o             =>ben_xel_shd.g_old_rec.xel_attribute28
 ,p_xel_attribute29_o             =>ben_xel_shd.g_old_rec.xel_attribute29
 ,p_xel_attribute30_o             =>ben_xel_shd.g_old_rec.xel_attribute30
 ,p_defined_balance_id_o          =>ben_xel_shd.g_old_rec.defined_balance_id
 ,p_object_version_number_o       =>ben_xel_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ext_data_elmt'
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
  p_effective_date in date,
  p_rec	      in ben_xel_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_xel_shd.lck
	(
	p_rec.ext_data_elmt_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_xel_bus.delete_validate(p_rec
  ,p_effective_date);
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
  post_delete(
p_effective_date,p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_ext_data_elmt_id                   in number,
  p_legislation_code                   in varchar2 default null,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_xel_shd.g_rec_type;
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
  l_rec.ext_data_elmt_id:= p_ext_data_elmt_id;
  l_rec.legislation_code := p_legislation_code;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_xel_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_xel_del;

/
