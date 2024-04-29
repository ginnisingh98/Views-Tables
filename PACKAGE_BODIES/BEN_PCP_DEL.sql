--------------------------------------------------------
--  DDL for Package Body BEN_PCP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCP_DEL" as
/* $Header: bepcprhi.pkb 115.13 2002/12/16 12:00:12 vsethi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pcp_del.';  -- Global package name
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
 Procedure delete_dml
  (p_rec in ben_pcp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_pcp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_pl_pcp row.
 --
  delete from ben_pl_pcp
  where pl_pcp_id = p_rec.pl_pcp_id;
  --
  ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pcp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_pcp_shd.g_rec_type) is
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
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in ben_pcp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    ben_pcp_rkd.after_delete
      (p_pl_pcp_id
      => p_rec.pl_pcp_id
      ,p_pl_id_o
      => ben_pcp_shd.g_old_rec.pl_id
      ,p_business_group_id_o
      => ben_pcp_shd.g_old_rec.business_group_id
      ,p_pcp_strt_dt_cd_o
      => ben_pcp_shd.g_old_rec.pcp_strt_dt_cd
      ,p_pcp_dsgn_cd_o
      => ben_pcp_shd.g_old_rec.pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd_o
      => ben_pcp_shd.g_old_rec.pcp_dpnt_dsgn_cd
      ,p_pcp_rpstry_flag_o
      => ben_pcp_shd.g_old_rec.pcp_rpstry_flag
      ,p_pcp_can_keep_flag_o
      => ben_pcp_shd.g_old_rec.pcp_can_keep_flag
      ,p_pcp_radius_o
      => ben_pcp_shd.g_old_rec.pcp_radius
      ,p_pcp_radius_uom_o
      => ben_pcp_shd.g_old_rec.pcp_radius_uom
      ,p_pcp_radius_warn_flag_o
      => ben_pcp_shd.g_old_rec.pcp_radius_warn_flag
      ,p_pcp_num_chgs_o
      => ben_pcp_shd.g_old_rec.pcp_num_chgs
      ,p_pcp_num_chgs_uom_o
      => ben_pcp_shd.g_old_rec.pcp_num_chgs_uom
      ,p_pcp_attribute_category_o
      => ben_pcp_shd.g_old_rec.pcp_attribute_category
      ,p_pcp_attribute1_o
      => ben_pcp_shd.g_old_rec.pcp_attribute1
      ,p_pcp_attribute2_o
      => ben_pcp_shd.g_old_rec.pcp_attribute2
      ,p_pcp_attribute3_o
      => ben_pcp_shd.g_old_rec.pcp_attribute3
      ,p_pcp_attribute4_o
      => ben_pcp_shd.g_old_rec.pcp_attribute4
      ,p_pcp_attribute5_o
      => ben_pcp_shd.g_old_rec.pcp_attribute5
      ,p_pcp_attribute6_o
      => ben_pcp_shd.g_old_rec.pcp_attribute6
      ,p_pcp_attribute7_o
      => ben_pcp_shd.g_old_rec.pcp_attribute7
      ,p_pcp_attribute8_o
      => ben_pcp_shd.g_old_rec.pcp_attribute8
      ,p_pcp_attribute9_o
      => ben_pcp_shd.g_old_rec.pcp_attribute9
      ,p_pcp_attribute10_o
      => ben_pcp_shd.g_old_rec.pcp_attribute10
      ,p_pcp_attribute11_o
      => ben_pcp_shd.g_old_rec.pcp_attribute11
      ,p_pcp_attribute12_o
      => ben_pcp_shd.g_old_rec.pcp_attribute12
      ,p_pcp_attribute13_o
      => ben_pcp_shd.g_old_rec.pcp_attribute13
      ,p_pcp_attribute14_o
      => ben_pcp_shd.g_old_rec.pcp_attribute14
      ,p_pcp_attribute15_o
      => ben_pcp_shd.g_old_rec.pcp_attribute15
      ,p_pcp_attribute16_o
      => ben_pcp_shd.g_old_rec.pcp_attribute16
      ,p_pcp_attribute17_o
      => ben_pcp_shd.g_old_rec.pcp_attribute17
      ,p_pcp_attribute18_o
      => ben_pcp_shd.g_old_rec.pcp_attribute18
      ,p_pcp_attribute19_o
      => ben_pcp_shd.g_old_rec.pcp_attribute19
      ,p_pcp_attribute20_o
      => ben_pcp_shd.g_old_rec.pcp_attribute20
      ,p_pcp_attribute21_o
      => ben_pcp_shd.g_old_rec.pcp_attribute21
      ,p_pcp_attribute22_o
      => ben_pcp_shd.g_old_rec.pcp_attribute22
      ,p_pcp_attribute23_o
      => ben_pcp_shd.g_old_rec.pcp_attribute23
      ,p_pcp_attribute24_o
      => ben_pcp_shd.g_old_rec.pcp_attribute24
      ,p_pcp_attribute25_o
      => ben_pcp_shd.g_old_rec.pcp_attribute25
      ,p_pcp_attribute26_o
      => ben_pcp_shd.g_old_rec.pcp_attribute26
      ,p_pcp_attribute27_o
      => ben_pcp_shd.g_old_rec.pcp_attribute27
      ,p_pcp_attribute28_o
      => ben_pcp_shd.g_old_rec.pcp_attribute28
      ,p_pcp_attribute29_o
      => ben_pcp_shd.g_old_rec.pcp_attribute29
      ,p_pcp_attribute30_o
      => ben_pcp_shd.g_old_rec.pcp_attribute30
      ,p_object_version_number_o
      => ben_pcp_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_PL_PCP'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec	      in ben_pcp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_pcp_shd.lck
    (p_rec.pl_pcp_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_pcp_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  ben_pcp_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --

  ben_pcp_del.delete_dml(p_rec);
  --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');

  -- Call the supporting post-delete operation
  --
  ben_pcp_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_pl_pcp_id                            in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  ben_pcp_shd.g_rec_type;
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
  l_rec.pl_pcp_id := p_pl_pcp_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_pcp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_pcp_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_pcp_del;

/
