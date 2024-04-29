--------------------------------------------------------
--  DDL for Package Body BEN_RTS_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RTS_DEL" as
/* $Header: bertsrhi.pkb 120.1 2006/01/09 14:37 maagrawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_rts_del.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  (p_rec in ben_rts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  ben_rts_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_cwb_person_rates row.
  --
  delete from ben_cwb_person_rates
  where group_per_in_ler_id = p_rec.group_per_in_ler_id
    and pl_id = p_rec.pl_id
    and oipl_id = p_rec.oipl_id;
  --
  ben_rts_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_rts_shd.g_api_dml := false;   -- Unset the api dml status
    ben_rts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_rts_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_rts_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
Procedure post_delete(p_rec in ben_rts_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    ben_rts_rkd.after_delete
      (p_person_rate_id
      => p_rec.person_rate_id
      ,p_group_per_in_ler_id_o
      => ben_rts_shd.g_old_rec.group_per_in_ler_id
      ,p_pl_id_o
      => ben_rts_shd.g_old_rec.pl_id
      ,p_oipl_id_o
      => ben_rts_shd.g_old_rec.oipl_id
      ,p_group_pl_id_o
      => ben_rts_shd.g_old_rec.group_pl_id
      ,p_group_oipl_id_o
      => ben_rts_shd.g_old_rec.group_oipl_id
      ,p_lf_evt_ocrd_dt_o
      => ben_rts_shd.g_old_rec.lf_evt_ocrd_dt
      ,p_person_id_o
      => ben_rts_shd.g_old_rec.person_id
      ,p_assignment_id_o
      => ben_rts_shd.g_old_rec.assignment_id
      ,p_elig_flag_o
      => ben_rts_shd.g_old_rec.elig_flag
      ,p_ws_val_o
      => ben_rts_shd.g_old_rec.ws_val
      ,p_ws_mn_val_o
      => ben_rts_shd.g_old_rec.ws_mn_val
      ,p_ws_mx_val_o
      => ben_rts_shd.g_old_rec.ws_mx_val
      ,p_ws_incr_val_o
      => ben_rts_shd.g_old_rec.ws_incr_val
      ,p_elig_sal_val_o
      => ben_rts_shd.g_old_rec.elig_sal_val
      ,p_stat_sal_val_o
      => ben_rts_shd.g_old_rec.stat_sal_val
      ,p_oth_comp_val_o
      => ben_rts_shd.g_old_rec.oth_comp_val
      ,p_tot_comp_val_o
      => ben_rts_shd.g_old_rec.tot_comp_val
      ,p_misc1_val_o
      => ben_rts_shd.g_old_rec.misc1_val
      ,p_misc2_val_o
      => ben_rts_shd.g_old_rec.misc2_val
      ,p_misc3_val_o
      => ben_rts_shd.g_old_rec.misc3_val
      ,p_rec_val_o
      => ben_rts_shd.g_old_rec.rec_val
      ,p_rec_mn_val_o
      => ben_rts_shd.g_old_rec.rec_mn_val
      ,p_rec_mx_val_o
      => ben_rts_shd.g_old_rec.rec_mx_val
      ,p_rec_incr_val_o
      => ben_rts_shd.g_old_rec.rec_incr_val
      ,p_ws_val_last_upd_date_o
      => ben_rts_shd.g_old_rec.ws_val_last_upd_date
      ,p_ws_val_last_upd_by_o
      => ben_rts_shd.g_old_rec.ws_val_last_upd_by
      ,p_pay_proposal_id_o
      => ben_rts_shd.g_old_rec.pay_proposal_id
      ,p_element_entry_value_id_o
      => ben_rts_shd.g_old_rec.element_entry_value_id
      ,p_inelig_rsn_cd_o
      => ben_rts_shd.g_old_rec.inelig_rsn_cd
      ,p_elig_ovrid_dt_o
      => ben_rts_shd.g_old_rec.elig_ovrid_dt
      ,p_elig_ovrid_person_id_o
      => ben_rts_shd.g_old_rec.elig_ovrid_person_id
      ,p_copy_dist_bdgt_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_val
      ,p_copy_ws_bdgt_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_val
      ,p_copy_rsrv_val_o
      => ben_rts_shd.g_old_rec.copy_rsrv_val
      ,p_copy_dist_bdgt_mn_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_mn_val
      ,p_copy_dist_bdgt_mx_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_mx_val
      ,p_copy_dist_bdgt_incr_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_incr_val
      ,p_copy_ws_bdgt_mn_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_mn_val
      ,p_copy_ws_bdgt_mx_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_mx_val
      ,p_copy_ws_bdgt_incr_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_incr_val
      ,p_copy_rsrv_mn_val_o
      => ben_rts_shd.g_old_rec.copy_rsrv_mn_val
      ,p_copy_rsrv_mx_val_o
      => ben_rts_shd.g_old_rec.copy_rsrv_mx_val
      ,p_copy_rsrv_incr_val_o
      => ben_rts_shd.g_old_rec.copy_rsrv_incr_val
      ,p_copy_dist_bdgt_iss_val_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_iss_val
      ,p_copy_ws_bdgt_iss_val_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_iss_val
      ,p_copy_dist_bdgt_iss_date_o
      => ben_rts_shd.g_old_rec.copy_dist_bdgt_iss_date
      ,p_copy_ws_bdgt_iss_date_o
      => ben_rts_shd.g_old_rec.copy_ws_bdgt_iss_date
      ,p_comp_posting_date_o
      => ben_rts_shd.g_old_rec.comp_posting_date
      ,p_ws_rt_start_date_o
      => ben_rts_shd.g_old_rec.ws_rt_start_date
      ,p_currency_o
      => ben_rts_shd.g_old_rec.currency
      ,p_object_version_number_o
      => ben_rts_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PERSON_RATES'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in ben_rts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to delete.
  --
  ben_rts_shd.lck
    (p_rec.group_per_in_ler_id
    ,p_rec.pl_id
    ,p_rec.oipl_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_rts_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ben_rts_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ben_rts_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ben_rts_del.post_delete(p_rec);
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
  (p_group_per_in_ler_id                  in     number
  ,p_pl_id                                in     number
  ,p_oipl_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ben_rts_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.group_per_in_ler_id := p_group_per_in_ler_id;
  l_rec.pl_id := p_pl_id;
  l_rec.oipl_id := p_oipl_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_rts_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_rts_del.del(l_rec);
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End del;
--
end ben_rts_del;

/
