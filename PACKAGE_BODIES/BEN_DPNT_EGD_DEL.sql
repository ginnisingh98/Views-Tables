--------------------------------------------------------
--  DDL for Package Body BEN_DPNT_EGD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DPNT_EGD_DEL" as

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_dpnt_egd_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_dpnt_egd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_dpnt_egd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_eligy_criteria row.
  --
  delete from ben_eligy_criteria_dpnt
  where eligy_criteria_dpnt_id = p_rec.eligy_criteria_dpnt_id;
  --
  ben_dpnt_egd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_dpnt_egd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_dpnt_egd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_dpnt_egd_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_dpnt_egd_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ben_dpnt_egd_shd.g_rec_type
			,p_effective_date in date) is
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

    ben_dpnt_egd_rkd.after_delete
      (
    p_eligy_criteria_dpnt_id                =>p_rec.eligy_criteria_dpnt_id
   ,p_name_o                           =>ben_dpnt_egd_shd.g_old_rec.name
   ,p_short_code_o                     =>ben_dpnt_egd_shd.g_old_rec.short_code
   ,p_description_o                    =>ben_dpnt_egd_shd.g_old_rec.description
   ,p_criteria_type_o		       =>ben_dpnt_egd_shd.g_old_rec.criteria_type
   ,p_crit_col1_val_type_cd_o	       =>ben_dpnt_egd_shd.g_old_rec.crit_col1_val_type_cd
   ,p_crit_col1_datatype_o	       =>ben_dpnt_egd_shd.g_old_rec.crit_col1_datatype
   ,p_col1_lookup_type_o	       =>ben_dpnt_egd_shd.g_old_rec.col1_lookup_type
   ,p_col1_value_set_id_o              =>ben_dpnt_egd_shd.g_old_rec.col1_value_set_id
   ,p_access_table_name1_o             =>ben_dpnt_egd_shd.g_old_rec.access_table_name1
   ,p_access_column_name1_o	       =>ben_dpnt_egd_shd.g_old_rec.access_column_name1
   ,p_time_entry_access_tab_nam1_o     =>ben_dpnt_egd_shd.g_old_rec.time_entry_access_tab_nam1
   ,p_time_entry_access_col_nam1_o     =>ben_dpnt_egd_shd.g_old_rec.time_entry_access_col_nam1
   ,p_crit_col2_val_type_cd_o	       =>ben_dpnt_egd_shd.g_old_rec.crit_col2_val_type_cd
   ,p_crit_col2_datatype_o	       =>ben_dpnt_egd_shd.g_old_rec.crit_col2_datatype
   ,p_col2_lookup_type_o	       =>ben_dpnt_egd_shd.g_old_rec.col2_lookup_type
   ,p_col2_value_set_id_o              =>ben_dpnt_egd_shd.g_old_rec.col2_value_set_id
   ,p_access_table_name2_o	       =>ben_dpnt_egd_shd.g_old_rec.access_table_name2
   ,p_access_column_name2_o	       =>ben_dpnt_egd_shd.g_old_rec.access_column_name2
   ,p_time_entry_access_tab_nam2_o     =>ben_dpnt_egd_shd.g_old_rec.time_entry_access_tab_nam2
   ,p_time_entry_access_col_nam2_o     =>ben_dpnt_egd_shd.g_old_rec.time_entry_access_col_nam2
   ,p_allow_range_validation_flg_o     =>ben_dpnt_egd_shd.g_old_rec.allow_range_validation_flg
   ,p_user_defined_flag_o              =>ben_dpnt_egd_shd.g_old_rec.user_defined_flag
   ,p_business_group_id_o 	       =>ben_dpnt_egd_shd.g_old_rec.business_group_id
   ,p_egd_attribute_category_o         =>ben_dpnt_egd_shd.g_old_rec.egd_attribute_category
   ,p_egd_attribute1_o                 =>ben_dpnt_egd_shd.g_old_rec.egd_attribute1
   ,p_egd_attribute2_o                 =>ben_dpnt_egd_shd.g_old_rec.egd_attribute2
   ,p_egd_attribute3_o                 =>ben_dpnt_egd_shd.g_old_rec.egd_attribute3
   ,p_egd_attribute4_o                 =>ben_dpnt_egd_shd.g_old_rec.egd_attribute4
   ,p_egd_attribute5_o                 =>ben_dpnt_egd_shd.g_old_rec.egd_attribute5
   ,p_egd_attribute6_o                 =>ben_dpnt_egd_shd.g_old_rec.egd_attribute6
   ,p_egd_attribute7_o                 =>ben_dpnt_egd_shd.g_old_rec.egd_attribute7
   ,p_egd_attribute8_o                 =>ben_dpnt_egd_shd.g_old_rec.egd_attribute8
   ,p_egd_attribute9_o                 =>ben_dpnt_egd_shd.g_old_rec.egd_attribute9
   ,p_egd_attribute10_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute10
   ,p_egd_attribute11_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute11
   ,p_egd_attribute12_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute12
   ,p_egd_attribute13_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute13
   ,p_egd_attribute14_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute14
   ,p_egd_attribute15_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute15
   ,p_egd_attribute16_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute16
   ,p_egd_attribute17_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute17
   ,p_egd_attribute18_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute18
   ,p_egd_attribute19_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute19
   ,p_egd_attribute20_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute20
   ,p_egd_attribute21_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute21
   ,p_egd_attribute22_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute22
   ,p_egd_attribute23_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute23
   ,p_egd_attribute24_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute24
   ,p_egd_attribute25_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute25
   ,p_egd_attribute26_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute26
   ,p_egd_attribute27_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute27
   ,p_egd_attribute28_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute28
   ,p_egd_attribute29_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute29
   ,p_egd_attribute30_o                =>ben_dpnt_egd_shd.g_old_rec.egd_attribute30
   ,p_object_version_number_o          =>ben_dpnt_egd_shd.g_old_rec.object_version_number
   ,p_allw_range_validation_flg2_o     =>ben_dpnt_egd_shd.g_old_rec.allow_range_validation_flag2
   ,p_time_access_calc_rule1_o         =>ben_dpnt_egd_shd.g_old_rec.time_access_calc_rule1
   ,p_time_access_calc_rule2_o         =>ben_dpnt_egd_shd.g_old_rec.time_access_calc_rule2
      );
      null;
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_eligy_criteria_dpnt'
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
  p_rec	      in ben_dpnt_egd_shd.g_rec_type
  ,p_effective_date in date
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_dpnt_egd_shd.lck
	(
	p_rec.eligy_criteria_dpnt_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_dpnt_egd_bus.delete_validate(p_rec,p_effective_date);
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
  post_delete(p_rec,p_effective_date);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_eligy_criteria_dpnt_id                  in number,
  p_object_version_number              in number,
  p_effective_date		       in date
  ) is
--
  l_rec	  ben_dpnt_egd_shd.g_rec_type;
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
  l_rec.eligy_criteria_dpnt_id:= p_eligy_criteria_dpnt_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_egd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec,p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_dpnt_egd_del;

/
