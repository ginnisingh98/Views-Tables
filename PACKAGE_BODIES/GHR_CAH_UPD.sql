--------------------------------------------------------
--  DDL for Package Body GHR_CAH_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CAH_UPD" as
/* $Header: ghcahrhi.pkb 115.1 2003/01/30 19:24:56 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cah_upd.';  -- Global package name
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
  (p_rec in out nocopy ghr_cah_shd.g_rec_type
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
  -- Update the ghr_compl_ca_headers Row
  --
  update ghr_compl_ca_headers
    set
     compl_ca_header_id              = p_rec.compl_ca_header_id
    ,complaint_id                    = p_rec.complaint_id
    ,ca_source                       = p_rec.ca_source
    ,last_compliance_report          = p_rec.last_compliance_report
    ,compliance_closed               = p_rec.compliance_closed
    ,compl_docket_number             = p_rec.compl_docket_number
    ,appeal_docket_number            = p_rec.appeal_docket_number
    ,pfe_docket_number               = p_rec.pfe_docket_number
    ,pfe_received                    = p_rec.pfe_received
    ,agency_brief_pfe_due            = p_rec.agency_brief_pfe_due
    ,agency_brief_pfe_date           = p_rec.agency_brief_pfe_date
    ,decision_pfe_date               = p_rec.decision_pfe_date
    ,decision_pfe                    = p_rec.decision_pfe
    ,agency_recvd_pfe_decision       = p_rec.agency_recvd_pfe_decision
    ,agency_pfe_brief_forwd          = p_rec.agency_pfe_brief_forwd
    ,agency_notified_noncom          = p_rec.agency_notified_noncom
    ,comrep_noncom_req               = p_rec.comrep_noncom_req
    ,eeo_off_req_data_from_org       = p_rec.eeo_off_req_data_from_org
    ,org_forwd_data_to_eeo_off       = p_rec.org_forwd_data_to_eeo_off
    ,dec_implemented                 = p_rec.dec_implemented
    ,complaint_reinstated            = p_rec.complaint_reinstated
    ,stage_complaint_reinstated      = p_rec.stage_complaint_reinstated
    ,object_version_number           = p_rec.object_version_number
    where compl_ca_header_id = p_rec.compl_ca_header_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ghr_cah_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ghr_cah_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ghr_cah_shd.constraint_error
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
  (p_rec in ghr_cah_shd.g_rec_type
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
  ,p_rec                          in ghr_cah_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ghr_cah_rku.after_update
      (p_effective_date               => p_effective_date
      ,p_compl_ca_header_id           => p_rec.compl_ca_header_id
      ,p_complaint_id                 => p_rec.complaint_id
      ,p_ca_source                    => p_rec.ca_source
      ,p_last_compliance_report       => p_rec.last_compliance_report
      ,p_compliance_closed            => p_rec.compliance_closed
      ,p_compl_docket_number          => p_rec.compl_docket_number
      ,p_appeal_docket_number         => p_rec.appeal_docket_number
      ,p_pfe_docket_number            => p_rec.pfe_docket_number
      ,p_pfe_received                 => p_rec.pfe_received
      ,p_agency_brief_pfe_due         => p_rec.agency_brief_pfe_due
      ,p_agency_brief_pfe_date        => p_rec.agency_brief_pfe_date
      ,p_decision_pfe_date            => p_rec.decision_pfe_date
      ,p_decision_pfe                 => p_rec.decision_pfe
      ,p_agency_recvd_pfe_decision    => p_rec.agency_recvd_pfe_decision
      ,p_agency_pfe_brief_forwd       => p_rec.agency_pfe_brief_forwd
      ,p_agency_notified_noncom       => p_rec.agency_notified_noncom
      ,p_comrep_noncom_req            => p_rec.comrep_noncom_req
      ,p_eeo_off_req_data_from_org    => p_rec.eeo_off_req_data_from_org
      ,p_org_forwd_data_to_eeo_off    => p_rec.org_forwd_data_to_eeo_off
      ,p_dec_implemented              => p_rec.dec_implemented
      ,p_complaint_reinstated         => p_rec.complaint_reinstated
      ,p_stage_complaint_reinstated   => p_rec.stage_complaint_reinstated
      ,p_object_version_number        => p_rec.object_version_number
      ,p_complaint_id_o               => ghr_cah_shd.g_old_rec.complaint_id
      ,p_ca_source_o                  => ghr_cah_shd.g_old_rec.ca_source
      ,p_last_compliance_report_o     => ghr_cah_shd.g_old_rec.last_compliance_report
      ,p_compliance_closed_o          => ghr_cah_shd.g_old_rec.compliance_closed
      ,p_compl_docket_number_o        => ghr_cah_shd.g_old_rec.compl_docket_number
      ,p_appeal_docket_number_o       => ghr_cah_shd.g_old_rec.appeal_docket_number
      ,p_pfe_docket_number_o          => ghr_cah_shd.g_old_rec.pfe_docket_number
      ,p_pfe_received_o               => ghr_cah_shd.g_old_rec.pfe_received
      ,p_agency_brief_pfe_due_o       => ghr_cah_shd.g_old_rec.agency_brief_pfe_due
      ,p_agency_brief_pfe_date_o      => ghr_cah_shd.g_old_rec.agency_brief_pfe_date
      ,p_decision_pfe_date_o          => ghr_cah_shd.g_old_rec.decision_pfe_date
      ,p_decision_pfe_o               => ghr_cah_shd.g_old_rec.decision_pfe
      ,p_agency_recvd_pfe_decision_o  => ghr_cah_shd.g_old_rec.agency_recvd_pfe_decision
      ,p_agency_pfe_brief_forwd_o     => ghr_cah_shd.g_old_rec.agency_pfe_brief_forwd
      ,p_agency_notified_noncom_o     => ghr_cah_shd.g_old_rec.agency_notified_noncom
      ,p_comrep_noncom_req_o          => ghr_cah_shd.g_old_rec.comrep_noncom_req
      ,p_eeo_off_req_data_from_org_o  => ghr_cah_shd.g_old_rec.eeo_off_req_data_from_org
      ,p_org_forwd_data_to_eeo_off_o  => ghr_cah_shd.g_old_rec.org_forwd_data_to_eeo_off
      ,p_dec_implemented_o            => ghr_cah_shd.g_old_rec.dec_implemented
      ,p_complaint_reinstated_o       => ghr_cah_shd.g_old_rec.complaint_reinstated
      ,p_stage_complaint_reinstated_o => ghr_cah_shd.g_old_rec.stage_complaint_reinstated
      ,p_object_version_number_o      => ghr_cah_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'GHR_COMPL_CA_HEADERS'
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
  (p_rec in out nocopy ghr_cah_shd.g_rec_type
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
    ghr_cah_shd.g_old_rec.complaint_id;
  End If;
  If (p_rec.ca_source = hr_api.g_varchar2) then
    p_rec.ca_source :=
    ghr_cah_shd.g_old_rec.ca_source;
  End If;
  If (p_rec.last_compliance_report = hr_api.g_date) then
    p_rec.last_compliance_report :=
    ghr_cah_shd.g_old_rec.last_compliance_report;
  End If;
  If (p_rec.compliance_closed = hr_api.g_date) then
    p_rec.compliance_closed :=
    ghr_cah_shd.g_old_rec.compliance_closed;
  End If;
  If (p_rec.compl_docket_number = hr_api.g_varchar2) then
    p_rec.compl_docket_number :=
    ghr_cah_shd.g_old_rec.compl_docket_number;
  End If;
  If (p_rec.appeal_docket_number = hr_api.g_varchar2) then
    p_rec.appeal_docket_number :=
    ghr_cah_shd.g_old_rec.appeal_docket_number;
  End If;
  If (p_rec.pfe_docket_number = hr_api.g_varchar2) then
    p_rec.pfe_docket_number :=
    ghr_cah_shd.g_old_rec.pfe_docket_number;
  End If;
  If (p_rec.pfe_received = hr_api.g_date) then
    p_rec.pfe_received :=
    ghr_cah_shd.g_old_rec.pfe_received;
  End If;
  If (p_rec.agency_brief_pfe_due = hr_api.g_date) then
    p_rec.agency_brief_pfe_due :=
    ghr_cah_shd.g_old_rec.agency_brief_pfe_due;
  End If;
  If (p_rec.agency_brief_pfe_date = hr_api.g_date) then
    p_rec.agency_brief_pfe_date :=
    ghr_cah_shd.g_old_rec.agency_brief_pfe_date;
  End If;
  If (p_rec.decision_pfe_date = hr_api.g_date) then
    p_rec.decision_pfe_date :=
    ghr_cah_shd.g_old_rec.decision_pfe_date;
  End If;
  If (p_rec.decision_pfe = hr_api.g_varchar2) then
    p_rec.decision_pfe :=
    ghr_cah_shd.g_old_rec.decision_pfe;
  End If;
  If (p_rec.agency_recvd_pfe_decision = hr_api.g_date) then
    p_rec.agency_recvd_pfe_decision :=
    ghr_cah_shd.g_old_rec.agency_recvd_pfe_decision;
  End If;
  If (p_rec.agency_pfe_brief_forwd = hr_api.g_date) then
    p_rec.agency_pfe_brief_forwd :=
    ghr_cah_shd.g_old_rec.agency_pfe_brief_forwd;
  End If;
  If (p_rec.agency_notified_noncom = hr_api.g_date) then
    p_rec.agency_notified_noncom :=
    ghr_cah_shd.g_old_rec.agency_notified_noncom;
  End If;
  If (p_rec.comrep_noncom_req = hr_api.g_varchar2) then
    p_rec.comrep_noncom_req :=
    ghr_cah_shd.g_old_rec.comrep_noncom_req;
  End If;
  If (p_rec.eeo_off_req_data_from_org = hr_api.g_date) then
    p_rec.eeo_off_req_data_from_org :=
    ghr_cah_shd.g_old_rec.eeo_off_req_data_from_org;
  End If;
  If (p_rec.org_forwd_data_to_eeo_off = hr_api.g_date) then
    p_rec.org_forwd_data_to_eeo_off :=
    ghr_cah_shd.g_old_rec.org_forwd_data_to_eeo_off;
  End If;
  If (p_rec.dec_implemented = hr_api.g_date) then
    p_rec.dec_implemented :=
    ghr_cah_shd.g_old_rec.dec_implemented;
  End If;
  If (p_rec.complaint_reinstated = hr_api.g_date) then
    p_rec.complaint_reinstated :=
    ghr_cah_shd.g_old_rec.complaint_reinstated;
  End If;
  If (p_rec.stage_complaint_reinstated = hr_api.g_varchar2) then
    p_rec.stage_complaint_reinstated :=
    ghr_cah_shd.g_old_rec.stage_complaint_reinstated;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ghr_cah_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ghr_cah_shd.lck
    (p_rec.compl_ca_header_id
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
  ghr_cah_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  ghr_cah_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ghr_cah_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ghr_cah_upd.post_update
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
  ,p_compl_ca_header_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_ca_source                    in     varchar2  default hr_api.g_varchar2
  ,p_last_compliance_report       in     date      default hr_api.g_date
  ,p_compliance_closed            in     date      default hr_api.g_date
  ,p_compl_docket_number          in     varchar2  default hr_api.g_varchar2
  ,p_appeal_docket_number         in     varchar2  default hr_api.g_varchar2
  ,p_pfe_docket_number            in     varchar2  default hr_api.g_varchar2
  ,p_pfe_received                 in     date      default hr_api.g_date
  ,p_agency_brief_pfe_due         in     date      default hr_api.g_date
  ,p_agency_brief_pfe_date        in     date      default hr_api.g_date
  ,p_decision_pfe_date            in     date      default hr_api.g_date
  ,p_decision_pfe                 in     varchar2  default hr_api.g_varchar2
  ,p_agency_recvd_pfe_decision    in     date      default hr_api.g_date
  ,p_agency_pfe_brief_forwd       in     date      default hr_api.g_date
  ,p_agency_notified_noncom       in     date      default hr_api.g_date
  ,p_comrep_noncom_req            in     varchar2  default hr_api.g_varchar2
  ,p_eeo_off_req_data_from_org    in     date      default hr_api.g_date
  ,p_org_forwd_data_to_eeo_off    in     date      default hr_api.g_date
  ,p_dec_implemented              in     date      default hr_api.g_date
  ,p_complaint_reinstated         in     date      default hr_api.g_date
  ,p_stage_complaint_reinstated   in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   ghr_cah_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_cah_shd.convert_args
  (p_compl_ca_header_id
  ,p_complaint_id
  ,p_ca_source
  ,p_last_compliance_report
  ,p_compliance_closed
  ,p_compl_docket_number
  ,p_appeal_docket_number
  ,p_pfe_docket_number
  ,p_pfe_received
  ,p_agency_brief_pfe_due
  ,p_agency_brief_pfe_date
  ,p_decision_pfe_date
  ,p_decision_pfe
  ,p_agency_recvd_pfe_decision
  ,p_agency_pfe_brief_forwd
  ,p_agency_notified_noncom
  ,p_comrep_noncom_req
  ,p_eeo_off_req_data_from_org
  ,p_org_forwd_data_to_eeo_off
  ,p_dec_implemented
  ,p_complaint_reinstated
  ,p_stage_complaint_reinstated
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ghr_cah_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ghr_cah_upd;

/
