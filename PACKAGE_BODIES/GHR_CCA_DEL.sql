--------------------------------------------------------
--  DDL for Package Body GHR_CCA_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CCA_DEL" as
/* $Header: ghccarhi.pkb 115.1 2003/01/30 19:25:04 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cca_del.';  -- Global package name
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
  (p_rec in ghr_cca_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the ghr_compl_appeals row.
  --
  delete from ghr_compl_appeals
  where compl_appeal_id = p_rec.compl_appeal_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    ghr_cca_shd.constraint_error
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
Procedure pre_delete(p_rec in ghr_cca_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ghr_cca_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ghr_cca_rkd.after_delete
      (p_compl_appeal_id              => p_rec.compl_appeal_id
      ,p_complaint_id_o               => ghr_cca_shd.g_old_rec.complaint_id
      ,p_appeal_date_o                => ghr_cca_shd.g_old_rec.appeal_date
      ,p_appealed_to_o                => ghr_cca_shd.g_old_rec.appealed_to
      ,p_reason_for_appeal_o          => ghr_cca_shd.g_old_rec.reason_for_appeal
      ,p_source_decision_date_o       => ghr_cca_shd.g_old_rec.source_decision_date
      ,p_docket_num_o                 => ghr_cca_shd.g_old_rec.docket_num
      ,p_org_notified_of_appeal_o     => ghr_cca_shd.g_old_rec.org_notified_of_appeal
      ,p_agency_recvd_req_for_files_o => ghr_cca_shd.g_old_rec.agency_recvd_req_for_files
      ,p_files_due_o                  => ghr_cca_shd.g_old_rec.files_due
      ,p_files_forwd_o                => ghr_cca_shd.g_old_rec.files_forwd
      ,p_agcy_recvd_appellant_brief_o => ghr_cca_shd.g_old_rec.agcy_recvd_appellant_brief
      ,p_agency_brief_due_o           => ghr_cca_shd.g_old_rec.agency_brief_due
      ,p_appellant_brief_forwd_org_o  => ghr_cca_shd.g_old_rec.appellant_brief_forwd_org
      ,p_org_forwd_brief_to_agency_o  => ghr_cca_shd.g_old_rec.org_forwd_brief_to_agency
      ,p_agency_brief_forwd_o         => ghr_cca_shd.g_old_rec.agency_brief_forwd
      ,p_decision_date_o              => ghr_cca_shd.g_old_rec.decision_date
      ,p_dec_recvd_by_agency_o        => ghr_cca_shd.g_old_rec.dec_recvd_by_agency
      ,p_decision_o                   => ghr_cca_shd.g_old_rec.decision
      ,p_dec_forwd_to_org_o           => ghr_cca_shd.g_old_rec.dec_forwd_to_org
      ,p_agency_rfr_suspense_o        => ghr_cca_shd.g_old_rec.agency_rfr_suspense
      ,p_request_for_rfr_o            => ghr_cca_shd.g_old_rec.request_for_rfr
      ,p_rfr_docket_num_o             => ghr_cca_shd.g_old_rec.rfr_docket_num
      ,p_rfr_requested_by_o           => ghr_cca_shd.g_old_rec.rfr_requested_by
      ,p_agency_rfr_due_o             => ghr_cca_shd.g_old_rec.agency_rfr_due
      ,p_rfr_forwd_to_org_o           => ghr_cca_shd.g_old_rec.rfr_forwd_to_org
      ,p_org_forwd_rfr_to_agency_o    => ghr_cca_shd.g_old_rec.org_forwd_rfr_to_agency
      ,p_agency_forwd_rfr_ofo_o       => ghr_cca_shd.g_old_rec.agency_forwd_rfr_ofo
      ,p_rfr_decision_o               => ghr_cca_shd.g_old_rec.rfr_decision
      ,p_rfr_decision_date_o          => ghr_cca_shd.g_old_rec.rfr_decision_date
      ,p_agency_recvd_rfr_dec_o       => ghr_cca_shd.g_old_rec.agency_recvd_rfr_dec
      ,p_rfr_decision_forwd_to_org_o  => ghr_cca_shd.g_old_rec.rfr_decision_forwd_to_org
      ,p_object_version_number_o      => ghr_cca_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'GHR_COMPL_APPEALS'
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
  (p_rec              in ghr_cca_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ghr_cca_shd.lck
    (p_rec.compl_appeal_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ghr_cca_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  ghr_cca_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ghr_cca_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ghr_cca_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_compl_appeal_id                      in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ghr_cca_shd.g_rec_type;
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
  l_rec.compl_appeal_id := p_compl_appeal_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ghr_cca_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ghr_cca_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ghr_cca_del;

/
