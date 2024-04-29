--------------------------------------------------------
--  DDL for Package Body BEN_BNR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNR_DEL" as
/* $Header: bebnrrhi.pkb 120.0 2005/05/28 00:46:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bnr_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_bnr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_bnr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_rptg_grp row.
  --
  delete from ben_rptg_grp
  where rptg_grp_id = p_rec.rptg_grp_id;
  --
  delete from ben_rptg_grp_tl
  where rptg_grp_id = p_rec.rptg_grp_id;
  ben_bnr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_bnr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bnr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_bnr_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_bnr_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_bnr_shd.g_rec_type) is
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
    ben_bnr_rkd.after_delete
      (
  p_rptg_grp_id                   =>p_rec.rptg_grp_id
 ,p_name_o                        =>ben_bnr_shd.g_old_rec.name
 ,p_business_group_id_o           =>ben_bnr_shd.g_old_rec.business_group_id
 ,p_rptg_prps_cd_o                =>ben_bnr_shd.g_old_rec.rptg_prps_cd
 ,p_rpg_desc_o                    =>ben_bnr_shd.g_old_rec.rpg_desc
 ,p_bnr_attribute_category_o      =>ben_bnr_shd.g_old_rec.bnr_attribute_category
 ,p_bnr_attribute1_o              =>ben_bnr_shd.g_old_rec.bnr_attribute1
 ,p_bnr_attribute2_o              =>ben_bnr_shd.g_old_rec.bnr_attribute2
 ,p_bnr_attribute3_o              =>ben_bnr_shd.g_old_rec.bnr_attribute3
 ,p_bnr_attribute4_o              =>ben_bnr_shd.g_old_rec.bnr_attribute4
 ,p_bnr_attribute5_o              =>ben_bnr_shd.g_old_rec.bnr_attribute5
 ,p_bnr_attribute6_o              =>ben_bnr_shd.g_old_rec.bnr_attribute6
 ,p_bnr_attribute7_o              =>ben_bnr_shd.g_old_rec.bnr_attribute7
 ,p_bnr_attribute8_o              =>ben_bnr_shd.g_old_rec.bnr_attribute8
 ,p_bnr_attribute9_o              =>ben_bnr_shd.g_old_rec.bnr_attribute9
 ,p_bnr_attribute10_o             =>ben_bnr_shd.g_old_rec.bnr_attribute10
 ,p_bnr_attribute11_o             =>ben_bnr_shd.g_old_rec.bnr_attribute11
 ,p_bnr_attribute12_o             =>ben_bnr_shd.g_old_rec.bnr_attribute12
 ,p_bnr_attribute13_o             =>ben_bnr_shd.g_old_rec.bnr_attribute13
 ,p_bnr_attribute14_o             =>ben_bnr_shd.g_old_rec.bnr_attribute14
 ,p_bnr_attribute15_o             =>ben_bnr_shd.g_old_rec.bnr_attribute15
 ,p_bnr_attribute16_o             =>ben_bnr_shd.g_old_rec.bnr_attribute16
 ,p_bnr_attribute17_o             =>ben_bnr_shd.g_old_rec.bnr_attribute17
 ,p_bnr_attribute18_o             =>ben_bnr_shd.g_old_rec.bnr_attribute18
 ,p_bnr_attribute19_o             =>ben_bnr_shd.g_old_rec.bnr_attribute19
 ,p_bnr_attribute20_o             =>ben_bnr_shd.g_old_rec.bnr_attribute20
 ,p_bnr_attribute21_o             =>ben_bnr_shd.g_old_rec.bnr_attribute21
 ,p_bnr_attribute22_o             =>ben_bnr_shd.g_old_rec.bnr_attribute22
 ,p_bnr_attribute23_o             =>ben_bnr_shd.g_old_rec.bnr_attribute23
 ,p_bnr_attribute24_o             =>ben_bnr_shd.g_old_rec.bnr_attribute24
 ,p_bnr_attribute25_o             =>ben_bnr_shd.g_old_rec.bnr_attribute25
 ,p_bnr_attribute26_o             =>ben_bnr_shd.g_old_rec.bnr_attribute26
 ,p_bnr_attribute27_o             =>ben_bnr_shd.g_old_rec.bnr_attribute27
 ,p_bnr_attribute28_o             =>ben_bnr_shd.g_old_rec.bnr_attribute28
 ,p_bnr_attribute29_o             =>ben_bnr_shd.g_old_rec.bnr_attribute29
 ,p_bnr_attribute30_o             =>ben_bnr_shd.g_old_rec.bnr_attribute30
 ,p_function_code_o               =>ben_bnr_shd.g_old_rec.function_code
 ,p_legislation_code_o            =>ben_bnr_shd.g_old_rec.legislation_code
 ,p_object_version_number_o       =>ben_bnr_shd.g_old_rec.object_version_number
 ,p_ordr_num_o                    =>ben_bnr_shd.g_old_rec.ordr_num                      --iRec
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_rptg_grp'
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
  p_rec	      in ben_bnr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_bnr_shd.lck
	(
	p_rec.rptg_grp_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_bnr_bus.delete_validate(p_rec
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
  p_rptg_grp_id                        in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_bnr_shd.g_rec_type;
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
  l_rec.rptg_grp_id:= p_rptg_grp_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_bnr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_bnr_del;

/
