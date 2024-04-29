--------------------------------------------------------
--  DDL for Package Body GHR_CCA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CCA_UPD" as
/* $Header: ghccarhi.pkb 115.1 2003/01/30 19:25:04 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cca_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy ghr_cca_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the ghr_compl_appeals Row
  --
  update ghr_compl_appeals
    set
     compl_appeal_id                 = p_rec.compl_appeal_id
    ,complaint_id                    = p_rec.complaint_id
    ,appeal_date                     = p_rec.appeal_date
    ,appealed_to                     = p_rec.appealed_to
    ,reason_for_appeal               = p_rec.reason_for_appeal
    ,source_decision_date            = p_rec.source_decision_date
    ,docket_num                      = p_rec.docket_num
    ,org_notified_of_appeal          = p_rec.org_notified_of_appeal
    ,agency_recvd_req_for_files      = p_rec.agency_recvd_req_for_files
    ,files_due                       = p_rec.files_due
    ,files_forwd                     = p_rec.files_forwd
    ,agcy_recvd_appellant_brief      = p_rec.agcy_recvd_appellant_brief
    ,agency_brief_due                = p_rec.agency_brief_due
    ,appellant_brief_forwd_org       = p_rec.appellant_brief_forwd_org
    ,org_forwd_brief_to_agency       = p_rec.org_forwd_brief_to_agency
    ,agency_brief_forwd              = p_rec.agency_brief_forwd
    ,decision_date                   = p_rec.decision_date
    ,dec_recvd_by_agency             = p_rec.dec_recvd_by_agency
    ,decision                        = p_rec.decision
    ,dec_forwd_to_org                = p_rec.dec_forwd_to_org
    ,agency_rfr_suspense             = p_rec.agency_rfr_suspense
    ,request_for_rfr                 = p_rec.request_for_rfr
    ,rfr_docket_num                  = p_rec.rfr_docket_num
    ,rfr_requested_by                = p_rec.rfr_requested_by
    ,agency_rfr_due                  = p_rec.agency_rfr_due
    ,rfr_forwd_to_org                = p_rec.rfr_forwd_to_org
    ,org_forwd_rfr_to_agency         = p_rec.org_forwd_rfr_to_agency
    ,agency_forwd_rfr_ofo            = p_rec.agency_forwd_rfr_ofo
    ,rfr_decision                    = p_rec.rfr_decision
    ,rfr_decision_date               = p_rec.rfr_decision_date
    ,agency_recvd_rfr_dec            = p_rec.agency_recvd_rfr_dec
    ,rfr_decision_forwd_to_org       = p_rec.rfr_decision_forwd_to_org
    ,object_version_number           = p_rec.object_version_number
    where compl_appeal_id = p_rec.compl_appeal_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ghr_cca_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ghr_cca_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ghr_cca_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in ghr_cca_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_effective_date               in date
  ,p_rec                          in ghr_cca_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ghr_cca_rku.after_update
      (p_effective_date               => p_effective_date
      ,p_compl_appeal_id              => p_rec.compl_appeal_id
      ,p_complaint_id                 => p_rec.complaint_id
      ,p_appeal_date                  => p_rec.appeal_date
      ,p_appealed_to                  => p_rec.appealed_to
      ,p_reason_for_appeal            => p_rec.reason_for_appeal
      ,p_source_decision_date         => p_rec.source_decision_date
      ,p_docket_num                   => p_rec.docket_num
      ,p_org_notified_of_appeal       => p_rec.org_notified_of_appeal
      ,p_agency_recvd_req_for_files   => p_rec.agency_recvd_req_for_files
      ,p_files_due                    => p_rec.files_due
      ,p_files_forwd                  => p_rec.files_forwd
      ,p_agcy_recvd_appellant_brief   => p_rec.agcy_recvd_appellant_brief
      ,p_agency_brief_due             => p_rec.agency_brief_due
      ,p_appellant_brief_forwd_org    => p_rec.appellant_brief_forwd_org
      ,p_org_forwd_brief_to_agency    => p_rec.org_forwd_brief_to_agency
      ,p_agency_brief_forwd           => p_rec.agency_brief_forwd
      ,p_decision_date                => p_rec.decision_date
      ,p_dec_recvd_by_agency          => p_rec.dec_recvd_by_agency
      ,p_decision                     => p_rec.decision
      ,p_dec_forwd_to_org             => p_rec.dec_forwd_to_org
      ,p_agency_rfr_suspense          => p_rec.agency_rfr_suspense
      ,p_request_for_rfr              => p_rec.request_for_rfr
      ,p_rfr_docket_num               => p_rec.rfr_docket_num
      ,p_rfr_requested_by             => p_rec.rfr_requested_by
      ,p_agency_rfr_due               => p_rec.agency_rfr_due
      ,p_rfr_forwd_to_org             => p_rec.rfr_forwd_to_org
      ,p_org_forwd_rfr_to_agency      => p_rec.org_forwd_rfr_to_agency
      ,p_agency_forwd_rfr_ofo         => p_rec.agency_forwd_rfr_ofo
      ,p_rfr_decision                 => p_rec.rfr_decision
      ,p_rfr_decision_date            => p_rec.rfr_decision_date
      ,p_agency_recvd_rfr_dec         => p_rec.agency_recvd_rfr_dec
      ,p_rfr_decision_forwd_to_org    => p_rec.rfr_decision_forwd_to_org
      ,p_object_version_number        => p_rec.object_version_number
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
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy ghr_cca_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.complaint_id = hr_api.g_number) then
    p_rec.complaint_id :=
    ghr_cca_shd.g_old_rec.complaint_id;
  End If;
  If (p_rec.appeal_date = hr_api.g_date) then
    p_rec.appeal_date :=
    ghr_cca_shd.g_old_rec.appeal_date;
  End If;
  If (p_rec.appealed_to = hr_api.g_varchar2) then
    p_rec.appealed_to :=
    ghr_cca_shd.g_old_rec.appealed_to;
  End If;
  If (p_rec.reason_for_appeal = hr_api.g_varchar2) then
    p_rec.reason_for_appeal :=
    ghr_cca_shd.g_old_rec.reason_for_appeal;
  End If;
  If (p_rec.source_decision_date = hr_api.g_date) then
    p_rec.source_decision_date :=
    ghr_cca_shd.g_old_rec.source_decision_date;
  End If;
  If (p_rec.docket_num = hr_api.g_varchar2) then
    p_rec.docket_num :=
    ghr_cca_shd.g_old_rec.docket_num;
  End If;
  If (p_rec.org_notified_of_appeal = hr_api.g_date) then
    p_rec.org_notified_of_appeal :=
    ghr_cca_shd.g_old_rec.org_notified_of_appeal;
  End If;
  If (p_rec.agency_recvd_req_for_files = hr_api.g_date) then
    p_rec.agency_recvd_req_for_files :=
    ghr_cca_shd.g_old_rec.agency_recvd_req_for_files;
  End If;
  If (p_rec.files_due = hr_api.g_date) then
    p_rec.files_due :=
    ghr_cca_shd.g_old_rec.files_due;
  End If;
  If (p_rec.files_forwd = hr_api.g_date) then
    p_rec.files_forwd :=
    ghr_cca_shd.g_old_rec.files_forwd;
  End If;
  If (p_rec.agcy_recvd_appellant_brief = hr_api.g_date) then
    p_rec.agcy_recvd_appellant_brief :=
    ghr_cca_shd.g_old_rec.agcy_recvd_appellant_brief;
  End If;
  If (p_rec.agency_brief_due = hr_api.g_date) then
    p_rec.agency_brief_due :=
    ghr_cca_shd.g_old_rec.agency_brief_due;
  End If;
  If (p_rec.appellant_brief_forwd_org = hr_api.g_date) then
    p_rec.appellant_brief_forwd_org :=
    ghr_cca_shd.g_old_rec.appellant_brief_forwd_org;
  End If;
  If (p_rec.org_forwd_brief_to_agency = hr_api.g_date) then
    p_rec.org_forwd_brief_to_agency :=
    ghr_cca_shd.g_old_rec.org_forwd_brief_to_agency;
  End If;
  If (p_rec.agency_brief_forwd = hr_api.g_date) then
    p_rec.agency_brief_forwd :=
    ghr_cca_shd.g_old_rec.agency_brief_forwd;
  End If;
  If (p_rec.decision_date = hr_api.g_date) then
    p_rec.decision_date :=
    ghr_cca_shd.g_old_rec.decision_date;
  End If;
  If (p_rec.dec_recvd_by_agency = hr_api.g_date) then
    p_rec.dec_recvd_by_agency :=
    ghr_cca_shd.g_old_rec.dec_recvd_by_agency;
  End If;
  If (p_rec.decision = hr_api.g_varchar2) then
    p_rec.decision :=
    ghr_cca_shd.g_old_rec.decision;
  End If;
  If (p_rec.dec_forwd_to_org = hr_api.g_date) then
    p_rec.dec_forwd_to_org :=
    ghr_cca_shd.g_old_rec.dec_forwd_to_org;
  End If;
  If (p_rec.agency_rfr_suspense = hr_api.g_date) then
    p_rec.agency_rfr_suspense :=
    ghr_cca_shd.g_old_rec.agency_rfr_suspense;
  End If;
  If (p_rec.request_for_rfr = hr_api.g_date) then
    p_rec.request_for_rfr :=
    ghr_cca_shd.g_old_rec.request_for_rfr;
  End If;
  If (p_rec.rfr_docket_num = hr_api.g_varchar2) then
    p_rec.rfr_docket_num :=
    ghr_cca_shd.g_old_rec.rfr_docket_num;
  End If;
  If (p_rec.rfr_requested_by = hr_api.g_varchar2) then
    p_rec.rfr_requested_by :=
    ghr_cca_shd.g_old_rec.rfr_requested_by;
  End If;
  If (p_rec.agency_rfr_due = hr_api.g_date) then
    p_rec.agency_rfr_due :=
    ghr_cca_shd.g_old_rec.agency_rfr_due;
  End If;
  If (p_rec.rfr_forwd_to_org = hr_api.g_date) then
    p_rec.rfr_forwd_to_org :=
    ghr_cca_shd.g_old_rec.rfr_forwd_to_org;
  End If;
  If (p_rec.org_forwd_rfr_to_agency = hr_api.g_date) then
    p_rec.org_forwd_rfr_to_agency :=
    ghr_cca_shd.g_old_rec.org_forwd_rfr_to_agency;
  End If;
  If (p_rec.agency_forwd_rfr_ofo = hr_api.g_date) then
    p_rec.agency_forwd_rfr_ofo :=
    ghr_cca_shd.g_old_rec.agency_forwd_rfr_ofo;
  End If;
  If (p_rec.rfr_decision = hr_api.g_varchar2) then
    p_rec.rfr_decision :=
    ghr_cca_shd.g_old_rec.rfr_decision;
  End If;
  If (p_rec.rfr_decision_date = hr_api.g_date) then
    p_rec.rfr_decision_date :=
    ghr_cca_shd.g_old_rec.rfr_decision_date;
  End If;
  If (p_rec.agency_recvd_rfr_dec = hr_api.g_date) then
    p_rec.agency_recvd_rfr_dec :=
    ghr_cca_shd.g_old_rec.agency_recvd_rfr_dec;
  End If;
  If (p_rec.rfr_decision_forwd_to_org = hr_api.g_date) then
    p_rec.rfr_decision_forwd_to_org :=
    ghr_cca_shd.g_old_rec.rfr_decision_forwd_to_org;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ghr_cca_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ghr_cca_shd.lck
    (p_rec.compl_appeal_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ghr_cca_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  ghr_cca_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ghr_cca_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ghr_cca_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_compl_appeal_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_appeal_date                  in     date      default hr_api.g_date
  ,p_appealed_to                  in     varchar2  default hr_api.g_varchar2
  ,p_reason_for_appeal            in     varchar2  default hr_api.g_varchar2
  ,p_source_decision_date         in     date      default hr_api.g_date
  ,p_docket_num                   in     varchar2  default hr_api.g_varchar2
  ,p_org_notified_of_appeal       in     date      default hr_api.g_date
  ,p_agency_recvd_req_for_files   in     date      default hr_api.g_date
  ,p_files_due                    in     date      default hr_api.g_date
  ,p_files_forwd                  in     date      default hr_api.g_date
  ,p_agcy_recvd_appellant_brief   in     date      default hr_api.g_date
  ,p_agency_brief_due             in     date      default hr_api.g_date
  ,p_appellant_brief_forwd_org    in     date      default hr_api.g_date
  ,p_org_forwd_brief_to_agency    in     date      default hr_api.g_date
  ,p_agency_brief_forwd           in     date      default hr_api.g_date
  ,p_decision_date                in     date      default hr_api.g_date
  ,p_dec_recvd_by_agency          in     date      default hr_api.g_date
  ,p_decision                     in     varchar2  default hr_api.g_varchar2
  ,p_dec_forwd_to_org             in     date      default hr_api.g_date
  ,p_agency_rfr_suspense          in     date      default hr_api.g_date
  ,p_request_for_rfr              in     date      default hr_api.g_date
  ,p_rfr_docket_num               in     varchar2  default hr_api.g_varchar2
  ,p_rfr_requested_by             in     varchar2  default hr_api.g_varchar2
  ,p_agency_rfr_due               in     date      default hr_api.g_date
  ,p_rfr_forwd_to_org             in     date      default hr_api.g_date
  ,p_org_forwd_rfr_to_agency      in     date      default hr_api.g_date
  ,p_agency_forwd_rfr_ofo         in     date      default hr_api.g_date
  ,p_rfr_decision                 in     varchar2  default hr_api.g_varchar2
  ,p_rfr_decision_date            in     date      default hr_api.g_date
  ,p_agency_recvd_rfr_dec         in     date      default hr_api.g_date
  ,p_rfr_decision_forwd_to_org    in     date      default hr_api.g_date
  ) is
--
  l_rec   ghr_cca_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_cca_shd.convert_args
  (p_compl_appeal_id
  ,p_complaint_id
  ,p_appeal_date
  ,p_appealed_to
  ,p_reason_for_appeal
  ,p_source_decision_date
  ,p_docket_num
  ,p_org_notified_of_appeal
  ,p_agency_recvd_req_for_files
  ,p_files_due
  ,p_files_forwd
  ,p_agcy_recvd_appellant_brief
  ,p_agency_brief_due
  ,p_appellant_brief_forwd_org
  ,p_org_forwd_brief_to_agency
  ,p_agency_brief_forwd
  ,p_decision_date
  ,p_dec_recvd_by_agency
  ,p_decision
  ,p_dec_forwd_to_org
  ,p_agency_rfr_suspense
  ,p_request_for_rfr
  ,p_rfr_docket_num
  ,p_rfr_requested_by
  ,p_agency_rfr_due
  ,p_rfr_forwd_to_org
  ,p_org_forwd_rfr_to_agency
  ,p_agency_forwd_rfr_ofo
  ,p_rfr_decision
  ,p_rfr_decision_date
  ,p_agency_recvd_rfr_dec
  ,p_rfr_decision_forwd_to_org
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ghr_cca_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ghr_cca_upd;

/
