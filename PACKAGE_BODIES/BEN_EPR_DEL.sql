--------------------------------------------------------
--  DDL for Package Body BEN_EPR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPR_DEL" as
/* $Header: beeprrhi.pkb 115.5 2002/12/09 12:52:58 lakrish ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_epr_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_epr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_epr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_enrt_prem row.
  --
  delete from ben_enrt_prem
  where enrt_prem_id = p_rec.enrt_prem_id;
  --
  ben_epr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_epr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_epr_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_epr_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ben_epr_shd.g_rec_type) is
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
    ben_epr_rkd.after_delete
      (
  p_enrt_prem_id                  =>p_rec.enrt_prem_id
 ,p_val_o                         =>ben_epr_shd.g_old_rec.val
 ,p_uom_o                         =>ben_epr_shd.g_old_rec.uom
 ,p_elig_per_elctbl_chc_id_o      =>ben_epr_shd.g_old_rec.elig_per_elctbl_chc_id
 ,p_enrt_bnft_id_o                =>ben_epr_shd.g_old_rec.enrt_bnft_id
 ,p_actl_prem_id_o                =>ben_epr_shd.g_old_rec.actl_prem_id
 ,p_business_group_id_o           =>ben_epr_shd.g_old_rec.business_group_id
 ,p_epr_attribute_category_o      =>ben_epr_shd.g_old_rec.epr_attribute_category
 ,p_epr_attribute1_o              =>ben_epr_shd.g_old_rec.epr_attribute1
 ,p_epr_attribute2_o              =>ben_epr_shd.g_old_rec.epr_attribute2
 ,p_epr_attribute3_o              =>ben_epr_shd.g_old_rec.epr_attribute3
 ,p_epr_attribute4_o              =>ben_epr_shd.g_old_rec.epr_attribute4
 ,p_epr_attribute5_o              =>ben_epr_shd.g_old_rec.epr_attribute5
 ,p_epr_attribute6_o              =>ben_epr_shd.g_old_rec.epr_attribute6
 ,p_epr_attribute7_o              =>ben_epr_shd.g_old_rec.epr_attribute7
 ,p_epr_attribute8_o              =>ben_epr_shd.g_old_rec.epr_attribute8
 ,p_epr_attribute9_o              =>ben_epr_shd.g_old_rec.epr_attribute9
 ,p_epr_attribute10_o             =>ben_epr_shd.g_old_rec.epr_attribute10
 ,p_epr_attribute11_o             =>ben_epr_shd.g_old_rec.epr_attribute11
 ,p_epr_attribute12_o             =>ben_epr_shd.g_old_rec.epr_attribute12
 ,p_epr_attribute13_o             =>ben_epr_shd.g_old_rec.epr_attribute13
 ,p_epr_attribute14_o             =>ben_epr_shd.g_old_rec.epr_attribute14
 ,p_epr_attribute15_o             =>ben_epr_shd.g_old_rec.epr_attribute15
 ,p_epr_attribute16_o             =>ben_epr_shd.g_old_rec.epr_attribute16
 ,p_epr_attribute17_o             =>ben_epr_shd.g_old_rec.epr_attribute17
 ,p_epr_attribute18_o             =>ben_epr_shd.g_old_rec.epr_attribute18
 ,p_epr_attribute19_o             =>ben_epr_shd.g_old_rec.epr_attribute19
 ,p_epr_attribute20_o             =>ben_epr_shd.g_old_rec.epr_attribute20
 ,p_epr_attribute21_o             =>ben_epr_shd.g_old_rec.epr_attribute21
 ,p_epr_attribute22_o             =>ben_epr_shd.g_old_rec.epr_attribute22
 ,p_epr_attribute23_o             =>ben_epr_shd.g_old_rec.epr_attribute23
 ,p_epr_attribute24_o             =>ben_epr_shd.g_old_rec.epr_attribute24
 ,p_epr_attribute25_o             =>ben_epr_shd.g_old_rec.epr_attribute25
 ,p_epr_attribute26_o             =>ben_epr_shd.g_old_rec.epr_attribute26
 ,p_epr_attribute27_o             =>ben_epr_shd.g_old_rec.epr_attribute27
 ,p_epr_attribute28_o             =>ben_epr_shd.g_old_rec.epr_attribute28
 ,p_epr_attribute29_o             =>ben_epr_shd.g_old_rec.epr_attribute29
 ,p_epr_attribute30_o             =>ben_epr_shd.g_old_rec.epr_attribute30
 ,p_object_version_number_o       =>ben_epr_shd.g_old_rec.object_version_number
 ,p_request_id_o                  =>ben_epr_shd.g_old_rec.request_id
 ,p_program_application_id_o      =>ben_epr_shd.g_old_rec.program_application_id
 ,p_program_id_o                  =>ben_epr_shd.g_old_rec.program_id
 ,p_program_update_date_o         =>ben_epr_shd.g_old_rec.program_update_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_enrt_prem'
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
  p_rec	      in ben_epr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_epr_shd.lck
	(
	p_rec.enrt_prem_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_epr_bus.delete_validate(p_rec);
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
  p_enrt_prem_id                       in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_epr_shd.g_rec_type;
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
  l_rec.enrt_prem_id:= p_enrt_prem_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_epr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_epr_del;

/
