--------------------------------------------------------
--  DDL for Package Body BEN_CSO_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CSO_DEL" as
/* $Header: becsorhi.pkb 115.0 2003/03/17 13:37:07 csundar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cso_del.';  -- Global package name
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
  (p_rec in ben_cso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the ben_cwb_stock_optn_dtls row.
  --
  delete from ben_cwb_stock_optn_dtls
  where cwb_stock_optn_dtls_id = p_rec.cwb_stock_optn_dtls_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    ben_cso_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
Procedure pre_delete(p_rec in ben_cso_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after
--   the delete dml.
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
Procedure post_delete(p_rec in ben_cso_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cso_rkd.after_delete
      (p_cwb_stock_optn_dtls_id
      => p_rec.cwb_stock_optn_dtls_id
      ,p_grant_id_o
      => ben_cso_shd.g_old_rec.grant_id
      ,p_grant_number_o
      => ben_cso_shd.g_old_rec.grant_number
      ,p_grant_name_o
      => ben_cso_shd.g_old_rec.grant_name
      ,p_grant_type_o
      => ben_cso_shd.g_old_rec.grant_type
      ,p_grant_date_o
      => ben_cso_shd.g_old_rec.grant_date
      ,p_grant_shares_o
      => ben_cso_shd.g_old_rec.grant_shares
      ,p_grant_price_o
      => ben_cso_shd.g_old_rec.grant_price
      ,p_value_at_grant_o
      => ben_cso_shd.g_old_rec.value_at_grant
      ,p_current_share_price_o
      => ben_cso_shd.g_old_rec.current_share_price
      ,p_current_shares_outstanding_o
      => ben_cso_shd.g_old_rec.current_shares_outstanding
      ,p_vested_shares_o
      => ben_cso_shd.g_old_rec.vested_shares
      ,p_unvested_shares_o
      => ben_cso_shd.g_old_rec.unvested_shares
      ,p_exercisable_shares_o
      => ben_cso_shd.g_old_rec.exercisable_shares
      ,p_exercised_shares_o
      => ben_cso_shd.g_old_rec.exercised_shares
      ,p_cancelled_shares_o
      => ben_cso_shd.g_old_rec.cancelled_shares
      ,p_trading_symbol_o
      => ben_cso_shd.g_old_rec.trading_symbol
      ,p_expiration_date_o
      => ben_cso_shd.g_old_rec.expiration_date
      ,p_reason_code_o
      => ben_cso_shd.g_old_rec.reason_code
      ,p_class_o
      => ben_cso_shd.g_old_rec.class
      ,p_misc_o
      => ben_cso_shd.g_old_rec.misc
      ,p_employee_number_o
      => ben_cso_shd.g_old_rec.employee_number
      ,p_person_id_o
      => ben_cso_shd.g_old_rec.person_id
      ,p_business_group_id_o
      => ben_cso_shd.g_old_rec.business_group_id
      ,p_prtt_rt_val_id_o
      => ben_cso_shd.g_old_rec.prtt_rt_val_id
      ,p_object_version_number_o
      => ben_cso_shd.g_old_rec.object_version_number
      ,p_cso_attribute_category_o
      => ben_cso_shd.g_old_rec.cso_attribute_category
      ,p_cso_attribute1_o
      => ben_cso_shd.g_old_rec.cso_attribute1
      ,p_cso_attribute2_o
      => ben_cso_shd.g_old_rec.cso_attribute2
      ,p_cso_attribute3_o
      => ben_cso_shd.g_old_rec.cso_attribute3
      ,p_cso_attribute4_o
      => ben_cso_shd.g_old_rec.cso_attribute4
      ,p_cso_attribute5_o
      => ben_cso_shd.g_old_rec.cso_attribute5
      ,p_cso_attribute6_o
      => ben_cso_shd.g_old_rec.cso_attribute6
      ,p_cso_attribute7_o
      => ben_cso_shd.g_old_rec.cso_attribute7
      ,p_cso_attribute8_o
      => ben_cso_shd.g_old_rec.cso_attribute8
      ,p_cso_attribute9_o
      => ben_cso_shd.g_old_rec.cso_attribute9
      ,p_cso_attribute10_o
      => ben_cso_shd.g_old_rec.cso_attribute10
      ,p_cso_attribute11_o
      => ben_cso_shd.g_old_rec.cso_attribute11
      ,p_cso_attribute12_o
      => ben_cso_shd.g_old_rec.cso_attribute12
      ,p_cso_attribute13_o
      => ben_cso_shd.g_old_rec.cso_attribute13
      ,p_cso_attribute14_o
      => ben_cso_shd.g_old_rec.cso_attribute14
      ,p_cso_attribute15_o
      => ben_cso_shd.g_old_rec.cso_attribute15
      ,p_cso_attribute16_o
      => ben_cso_shd.g_old_rec.cso_attribute16
      ,p_cso_attribute17_o
      => ben_cso_shd.g_old_rec.cso_attribute17
      ,p_cso_attribute18_o
      => ben_cso_shd.g_old_rec.cso_attribute18
      ,p_cso_attribute19_o
      => ben_cso_shd.g_old_rec.cso_attribute19
      ,p_cso_attribute20_o
      => ben_cso_shd.g_old_rec.cso_attribute20
      ,p_cso_attribute21_o
      => ben_cso_shd.g_old_rec.cso_attribute21
      ,p_cso_attribute22_o
      => ben_cso_shd.g_old_rec.cso_attribute22
      ,p_cso_attribute23_o
      => ben_cso_shd.g_old_rec.cso_attribute23
      ,p_cso_attribute24_o
      => ben_cso_shd.g_old_rec.cso_attribute24
      ,p_cso_attribute25_o
      => ben_cso_shd.g_old_rec.cso_attribute25
      ,p_cso_attribute26_o
      => ben_cso_shd.g_old_rec.cso_attribute26
      ,p_cso_attribute27_o
      => ben_cso_shd.g_old_rec.cso_attribute27
      ,p_cso_attribute28_o
      => ben_cso_shd.g_old_rec.cso_attribute28
      ,p_cso_attribute29_o
      => ben_cso_shd.g_old_rec.cso_attribute29
      ,p_cso_attribute30_o
      => ben_cso_shd.g_old_rec.cso_attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_STOCK_OPTN_DTLS'
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
  (p_rec              in ben_cso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_cso_shd.lck
    (p_rec.cwb_stock_optn_dtls_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_cso_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ben_cso_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ben_cso_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ben_cso_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_cwb_stock_optn_dtls_id               in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ben_cso_shd.g_rec_type;
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
  l_rec.cwb_stock_optn_dtls_id := p_cwb_stock_optn_dtls_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_cso_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_cso_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_cso_del;

/
