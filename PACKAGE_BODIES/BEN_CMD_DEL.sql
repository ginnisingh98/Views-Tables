--------------------------------------------------------
--  DDL for Package Body BEN_CMD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CMD_DEL" as
/* $Header: becmdrhi.pkb 115.7 2002/12/31 23:57:12 mmudigon ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cmd_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_cmd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_cmd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_cm_dlvry_med_typ row.
  --
  delete from ben_cm_dlvry_med_typ
  where cm_dlvry_med_typ_id = p_rec.cm_dlvry_med_typ_id;
  --
  ben_cmd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_cmd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cmd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cmd_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_cmd_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_cmd_shd.g_rec_type) is
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
    ben_cmd_rkd.after_delete
      (
  p_cm_dlvry_med_typ_id           =>p_rec.cm_dlvry_med_typ_id
 ,p_cm_dlvry_med_typ_cd_o         =>ben_cmd_shd.g_old_rec.cm_dlvry_med_typ_cd
 ,p_cm_dlvry_mthd_typ_id_o        =>ben_cmd_shd.g_old_rec.cm_dlvry_mthd_typ_id
 ,p_rqd_flag_o                    =>ben_cmd_shd.g_old_rec.rqd_flag
 ,p_dflt_flag_o                   =>ben_cmd_shd.g_old_rec.dflt_flag
 ,p_business_group_id_o           =>ben_cmd_shd.g_old_rec.business_group_id
 ,p_cmd_attribute_category_o      =>ben_cmd_shd.g_old_rec.cmd_attribute_category
 ,p_cmd_attribute1_o              =>ben_cmd_shd.g_old_rec.cmd_attribute1
 ,p_cmd_attribute2_o              =>ben_cmd_shd.g_old_rec.cmd_attribute2
 ,p_cmd_attribute3_o              =>ben_cmd_shd.g_old_rec.cmd_attribute3
 ,p_cmd_attribute4_o              =>ben_cmd_shd.g_old_rec.cmd_attribute4
 ,p_cmd_attribute5_o              =>ben_cmd_shd.g_old_rec.cmd_attribute5
 ,p_cmd_attribute6_o              =>ben_cmd_shd.g_old_rec.cmd_attribute6
 ,p_cmd_attribute7_o              =>ben_cmd_shd.g_old_rec.cmd_attribute7
 ,p_cmd_attribute8_o              =>ben_cmd_shd.g_old_rec.cmd_attribute8
 ,p_cmd_attribute9_o              =>ben_cmd_shd.g_old_rec.cmd_attribute9
 ,p_cmd_attribute10_o             =>ben_cmd_shd.g_old_rec.cmd_attribute10
 ,p_cmd_attribute11_o             =>ben_cmd_shd.g_old_rec.cmd_attribute11
 ,p_cmd_attribute12_o             =>ben_cmd_shd.g_old_rec.cmd_attribute12
 ,p_cmd_attribute13_o             =>ben_cmd_shd.g_old_rec.cmd_attribute13
 ,p_cmd_attribute14_o             =>ben_cmd_shd.g_old_rec.cmd_attribute14
 ,p_cmd_attribute15_o             =>ben_cmd_shd.g_old_rec.cmd_attribute15
 ,p_cmd_attribute16_o             =>ben_cmd_shd.g_old_rec.cmd_attribute16
 ,p_cmd_attribute17_o             =>ben_cmd_shd.g_old_rec.cmd_attribute17
 ,p_cmd_attribute18_o             =>ben_cmd_shd.g_old_rec.cmd_attribute18
 ,p_cmd_attribute19_o             =>ben_cmd_shd.g_old_rec.cmd_attribute19
 ,p_cmd_attribute20_o             =>ben_cmd_shd.g_old_rec.cmd_attribute20
 ,p_cmd_attribute21_o             =>ben_cmd_shd.g_old_rec.cmd_attribute21
 ,p_cmd_attribute22_o             =>ben_cmd_shd.g_old_rec.cmd_attribute22
 ,p_cmd_attribute23_o             =>ben_cmd_shd.g_old_rec.cmd_attribute23
 ,p_cmd_attribute24_o             =>ben_cmd_shd.g_old_rec.cmd_attribute24
 ,p_cmd_attribute25_o             =>ben_cmd_shd.g_old_rec.cmd_attribute25
 ,p_cmd_attribute26_o             =>ben_cmd_shd.g_old_rec.cmd_attribute26
 ,p_cmd_attribute27_o             =>ben_cmd_shd.g_old_rec.cmd_attribute27
 ,p_cmd_attribute28_o             =>ben_cmd_shd.g_old_rec.cmd_attribute28
 ,p_cmd_attribute29_o             =>ben_cmd_shd.g_old_rec.cmd_attribute29
 ,p_cmd_attribute30_o             =>ben_cmd_shd.g_old_rec.cmd_attribute30
 ,p_object_version_number_o       =>ben_cmd_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_cm_dlvry_med_typ'
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
  p_rec	      in ben_cmd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_cmd_shd.lck
	(
	p_rec.cm_dlvry_med_typ_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_cmd_bus.delete_validate(p_rec
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
  p_cm_dlvry_med_typ_id                in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_cmd_shd.g_rec_type;
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
  l_rec.cm_dlvry_med_typ_id:= p_cm_dlvry_med_typ_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_cmd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_cmd_del;

/
