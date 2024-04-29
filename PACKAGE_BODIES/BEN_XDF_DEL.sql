--------------------------------------------------------
--  DDL for Package Body BEN_XDF_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XDF_DEL" as
/* $Header: bexdfrhi.pkb 120.6 2006/07/10 21:53:55 tjesumic ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xdf_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_xdf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_xdf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_ext_dfn row.
  --
  delete from ben_ext_dfn
  where ext_dfn_id = p_rec.ext_dfn_id;
  --
  ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_xdf_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_xdf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  delete_app_ownerships('EXT_DFN_ID', p_rec.ext_dfn_id);
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    ben_xdf_rkd.after_delete
      (
  p_ext_dfn_id                    =>p_rec.ext_dfn_id
 ,p_name_o                        =>ben_xdf_shd.g_old_rec.name
 ,p_xml_tag_name_o                =>ben_xdf_shd.g_old_rec.xml_tag_name
 ,p_xdo_template_id_o               =>ben_xdf_shd.g_old_rec.xdo_template_id
 ,p_data_typ_cd_o                 =>ben_xdf_shd.g_old_rec.data_typ_cd
 ,p_ext_typ_cd_o                  =>ben_xdf_shd.g_old_rec.ext_typ_cd
 ,p_output_name_o                 =>ben_xdf_shd.g_old_rec.output_name
 ,p_output_type_o                 =>ben_xdf_shd.g_old_rec.output_type
 ,p_apnd_rqst_id_flag_o           =>ben_xdf_shd.g_old_rec.apnd_rqst_id_flag
 ,p_prmy_sort_cd_o                =>ben_xdf_shd.g_old_rec.prmy_sort_cd
 ,p_scnd_sort_cd_o                =>ben_xdf_shd.g_old_rec.scnd_sort_cd
 ,p_strt_dt_o                     =>ben_xdf_shd.g_old_rec.strt_dt
 ,p_end_dt_o                      =>ben_xdf_shd.g_old_rec.end_dt
 ,p_ext_crit_prfl_id_o            =>ben_xdf_shd.g_old_rec.ext_crit_prfl_id
 ,p_ext_file_id_o                 =>ben_xdf_shd.g_old_rec.ext_file_id
 ,p_business_group_id_o           =>ben_xdf_shd.g_old_rec.business_group_id
 ,p_legislation_code_o            =>ben_xdf_shd.g_old_rec.legislation_code
 ,p_xdf_attribute_category_o      =>ben_xdf_shd.g_old_rec.xdf_attribute_category
 ,p_xdf_attribute1_o              =>ben_xdf_shd.g_old_rec.xdf_attribute1
 ,p_xdf_attribute2_o              =>ben_xdf_shd.g_old_rec.xdf_attribute2
 ,p_xdf_attribute3_o              =>ben_xdf_shd.g_old_rec.xdf_attribute3
 ,p_xdf_attribute4_o              =>ben_xdf_shd.g_old_rec.xdf_attribute4
 ,p_xdf_attribute5_o              =>ben_xdf_shd.g_old_rec.xdf_attribute5
 ,p_xdf_attribute6_o              =>ben_xdf_shd.g_old_rec.xdf_attribute6
 ,p_xdf_attribute7_o              =>ben_xdf_shd.g_old_rec.xdf_attribute7
 ,p_xdf_attribute8_o              =>ben_xdf_shd.g_old_rec.xdf_attribute8
 ,p_xdf_attribute9_o              =>ben_xdf_shd.g_old_rec.xdf_attribute9
 ,p_xdf_attribute10_o             =>ben_xdf_shd.g_old_rec.xdf_attribute10
 ,p_xdf_attribute11_o             =>ben_xdf_shd.g_old_rec.xdf_attribute11
 ,p_xdf_attribute12_o             =>ben_xdf_shd.g_old_rec.xdf_attribute12
 ,p_xdf_attribute13_o             =>ben_xdf_shd.g_old_rec.xdf_attribute13
 ,p_xdf_attribute14_o             =>ben_xdf_shd.g_old_rec.xdf_attribute14
 ,p_xdf_attribute15_o             =>ben_xdf_shd.g_old_rec.xdf_attribute15
 ,p_xdf_attribute16_o             =>ben_xdf_shd.g_old_rec.xdf_attribute16
 ,p_xdf_attribute17_o             =>ben_xdf_shd.g_old_rec.xdf_attribute17
 ,p_xdf_attribute18_o             =>ben_xdf_shd.g_old_rec.xdf_attribute18
 ,p_xdf_attribute19_o             =>ben_xdf_shd.g_old_rec.xdf_attribute19
 ,p_xdf_attribute20_o             =>ben_xdf_shd.g_old_rec.xdf_attribute20
 ,p_xdf_attribute21_o             =>ben_xdf_shd.g_old_rec.xdf_attribute21
 ,p_xdf_attribute22_o             =>ben_xdf_shd.g_old_rec.xdf_attribute22
 ,p_xdf_attribute23_o             =>ben_xdf_shd.g_old_rec.xdf_attribute23
 ,p_xdf_attribute24_o             =>ben_xdf_shd.g_old_rec.xdf_attribute24
 ,p_xdf_attribute25_o             =>ben_xdf_shd.g_old_rec.xdf_attribute25
 ,p_xdf_attribute26_o             =>ben_xdf_shd.g_old_rec.xdf_attribute26
 ,p_xdf_attribute27_o             =>ben_xdf_shd.g_old_rec.xdf_attribute27
 ,p_xdf_attribute28_o             =>ben_xdf_shd.g_old_rec.xdf_attribute28
 ,p_xdf_attribute29_o             =>ben_xdf_shd.g_old_rec.xdf_attribute29
 ,p_xdf_attribute30_o             =>ben_xdf_shd.g_old_rec.xdf_attribute30
 ,p_object_version_number_o       =>ben_xdf_shd.g_old_rec.object_version_number
 ,p_drctry_name_o                 =>ben_xdf_shd.g_old_rec.drctry_name
 ,p_kickoff_wrt_prc_flag_o        =>ben_xdf_shd.g_old_rec.kickoff_wrt_prc_flag
 ,p_upd_cm_sent_dt_flag_o         =>ben_xdf_shd.g_old_rec.upd_cm_sent_dt_flag
 ,p_spcl_hndl_flag_o              =>ben_xdf_shd.g_old_rec.spcl_hndl_flag
 ,p_ext_global_flag_o             =>ben_xdf_shd.g_old_rec.ext_global_flag
 ,p_cm_display_flag_o             =>ben_xdf_shd.g_old_rec.cm_display_flag
 ,p_use_eff_dt_for_chgs_flag_o    =>ben_xdf_shd.g_old_rec.use_eff_dt_for_chgs_flag
 ,p_ext_post_prcs_rl_o            =>ben_xdf_shd.g_old_rec.ext_post_prcs_rl
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ext_dfn'
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
  p_rec	      in ben_xdf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_xdf_shd.lck
	(
	p_rec.ext_dfn_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_xdf_bus.delete_validate(p_rec
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
  p_ext_dfn_id                         in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_xdf_shd.g_rec_type;
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
  l_rec.ext_dfn_id:= p_ext_dfn_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_xdf_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_xdf_del;

/
