--------------------------------------------------------
--  DDL for Package Body BEN_CPY_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPY_DEL" as
/* $Header: becpyrhi.pkb 120.2 2005/12/19 12:34:35 kmahendr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cpy_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_cpy_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_cpy_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_popl_yr_perd row.
  --
  delete from ben_popl_yr_perd
  where popl_yr_perd_id = p_rec.popl_yr_perd_id;
  --
  ben_cpy_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_cpy_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpy_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpy_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_cpy_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ben_cpy_shd.g_rec_type) is
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
    ben_cpy_rkd.after_delete
      (
       p_popl_yr_perd_id               =>p_rec.popl_yr_perd_id
      ,p_yr_perd_id_o                  =>ben_cpy_shd.g_old_rec.yr_perd_id
      ,p_business_group_id_o           =>ben_cpy_shd.g_old_rec.business_group_id
      ,p_pl_id_o                       =>ben_cpy_shd.g_old_rec.pl_id
      ,p_pgm_id_o                      =>ben_cpy_shd.g_old_rec.pgm_id
      ,p_ordr_num_o                    =>ben_cpy_shd.g_old_rec.ordr_num
      ,p_acpt_clm_rqsts_thru_dt_o      =>ben_cpy_shd.g_old_rec.acpt_clm_rqsts_thru_dt
      ,p_py_clms_thru_dt_o             =>ben_cpy_shd.g_old_rec.py_clms_thru_dt
      ,p_cpy_attribute_category_o      =>ben_cpy_shd.g_old_rec.cpy_attribute_category
      ,p_cpy_attribute1_o              =>ben_cpy_shd.g_old_rec.cpy_attribute1
      ,p_cpy_attribute2_o              =>ben_cpy_shd.g_old_rec.cpy_attribute2
      ,p_cpy_attribute3_o              =>ben_cpy_shd.g_old_rec.cpy_attribute3
      ,p_cpy_attribute4_o              =>ben_cpy_shd.g_old_rec.cpy_attribute4
      ,p_cpy_attribute5_o              =>ben_cpy_shd.g_old_rec.cpy_attribute5
      ,p_cpy_attribute6_o              =>ben_cpy_shd.g_old_rec.cpy_attribute6
      ,p_cpy_attribute7_o              =>ben_cpy_shd.g_old_rec.cpy_attribute7
      ,p_cpy_attribute8_o              =>ben_cpy_shd.g_old_rec.cpy_attribute8
      ,p_cpy_attribute9_o              =>ben_cpy_shd.g_old_rec.cpy_attribute9
      ,p_cpy_attribute10_o             =>ben_cpy_shd.g_old_rec.cpy_attribute10
      ,p_cpy_attribute11_o             =>ben_cpy_shd.g_old_rec.cpy_attribute11
      ,p_cpy_attribute12_o             =>ben_cpy_shd.g_old_rec.cpy_attribute12
      ,p_cpy_attribute13_o             =>ben_cpy_shd.g_old_rec.cpy_attribute13
      ,p_cpy_attribute14_o             =>ben_cpy_shd.g_old_rec.cpy_attribute14
      ,p_cpy_attribute15_o             =>ben_cpy_shd.g_old_rec.cpy_attribute15
      ,p_cpy_attribute16_o             =>ben_cpy_shd.g_old_rec.cpy_attribute16
      ,p_cpy_attribute17_o             =>ben_cpy_shd.g_old_rec.cpy_attribute17
      ,p_cpy_attribute18_o             =>ben_cpy_shd.g_old_rec.cpy_attribute18
      ,p_cpy_attribute19_o             =>ben_cpy_shd.g_old_rec.cpy_attribute19
      ,p_cpy_attribute20_o             =>ben_cpy_shd.g_old_rec.cpy_attribute20
      ,p_cpy_attribute21_o             =>ben_cpy_shd.g_old_rec.cpy_attribute21
      ,p_cpy_attribute22_o             =>ben_cpy_shd.g_old_rec.cpy_attribute22
      ,p_cpy_attribute23_o             =>ben_cpy_shd.g_old_rec.cpy_attribute23
      ,p_cpy_attribute24_o             =>ben_cpy_shd.g_old_rec.cpy_attribute24
      ,p_cpy_attribute25_o             =>ben_cpy_shd.g_old_rec.cpy_attribute25
      ,p_cpy_attribute26_o             =>ben_cpy_shd.g_old_rec.cpy_attribute26
      ,p_cpy_attribute27_o             =>ben_cpy_shd.g_old_rec.cpy_attribute27
      ,p_cpy_attribute28_o             =>ben_cpy_shd.g_old_rec.cpy_attribute28
      ,p_cpy_attribute29_o             =>ben_cpy_shd.g_old_rec.cpy_attribute29
      ,p_cpy_attribute30_o             =>ben_cpy_shd.g_old_rec.cpy_attribute30
      ,p_object_version_number_o       =>ben_cpy_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_popl_yr_perd'
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
  p_rec	      in ben_cpy_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_cpy_shd.lck
	(
	p_rec.popl_yr_perd_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_cpy_bus.delete_validate(p_rec);
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
  p_popl_yr_perd_id                    in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_cpy_shd.g_rec_type;
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
  l_rec.popl_yr_perd_id:= p_popl_yr_perd_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_cpy_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_cpy_del;

/
