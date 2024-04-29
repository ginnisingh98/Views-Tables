--------------------------------------------------------
--  DDL for Package Body GHR_PRH_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PRH_UPD" as
/* $Header: ghprhrhi.pkb 120.2.12010000.2 2009/08/11 09:26:23 managarw ship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_prh_upd.';  -- Global package name
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
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Pre Conditions:
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out NOCOPY ghr_prh_shd.g_rec_type) is
--
  l_proc varchar2(72) ;
  l_rec ghr_prh_shd.g_rec_type;
--
Begin
  l_proc := g_package||'update_dml';
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_rec := p_rec;
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;

  --
  -- Update the ghr_pa_routing_history Row
  --


  update ghr_pa_routing_history
  set
  pa_routing_history_id             = p_rec.pa_routing_history_id,
  attachment_modified_flag          = p_rec.attachment_modified_flag,
  initiator_flag                    = p_rec.initiator_flag,
  approver_flag                     = p_rec.approver_flag,
  reviewer_flag                     = p_rec.reviewer_flag,
  requester_flag                    = p_rec.requester_flag,
  authorizer_flag                   = p_rec.authorizer_flag,
  personnelist_flag                 = p_rec.personnelist_flag,
  approved_flag                     = p_rec.approved_flag,
  user_name                         = p_rec.user_name,
  user_name_employee_id             = p_rec.user_name_employee_id,
  user_name_emp_first_name          = p_rec.user_name_emp_first_name,
  user_name_emp_last_name           = p_rec.user_name_emp_last_name,
  user_name_emp_middle_names        = p_rec.user_name_emp_middle_names,
  notepad          			= p_rec.notepad,
  action_taken                      = p_rec.action_taken,
  groupbox_id                       = p_rec.groupbox_id,
  noa_family_code                   = p_rec.noa_family_code,
  nature_of_action_id               = p_rec.nature_of_action_id,
  second_nature_of_action_id        = p_rec.second_nature_of_action_id,
  approval_status                   = p_rec.approval_status,
  date_notification_sent            = p_rec.date_notification_sent,
  object_version_number             = p_rec.object_version_number
  where pa_routing_history_id = p_rec.pa_routing_history_id;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    p_rec := l_rec;
    ghr_prh_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    p_rec := l_rec;
     ghr_prh_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    p_rec := l_rec;
     ghr_prh_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
     p_rec := l_rec;
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
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ghr_prh_shd.g_rec_type) is
--
  l_proc  varchar2(72) ;
--
Begin
  l_proc  := g_package||'pre_update';
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
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in ghr_prh_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'post_update';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     ghr_prh_rku.after_update	(
      p_pa_routing_history_id      => p_rec.pa_routing_history_id,
      p_pa_request_id              => p_rec.pa_request_id,
      p_action_taken               => p_rec.action_taken,
      p_approved_flag              => p_rec.approved_flag,
      p_approver_flag              => p_rec.approver_flag,
      p_approval_status            => p_rec.approval_status,
      p_attachment_modified_flag   => p_rec.attachment_modified_flag,
      p_authorizer_flag            => p_rec.authorizer_flag,
      p_date_notification_sent     => p_rec.date_notification_sent,
      p_groupbox_id                => p_rec.groupbox_id,
      p_initiator_flag             => p_rec.initiator_flag,
      p_nature_of_action_id        => p_rec.nature_of_action_id,
      p_noa_family_code            => p_rec.noa_family_code,
      p_notepad                    => p_rec.notepad,
      p_personnelist_flag          => p_rec.personnelist_flag,
      p_requester_flag             => p_rec.requester_flag,
      p_reviewer_flag              => p_rec.reviewer_flag,
      p_routing_list_id            => p_rec.routing_list_id,
      p_routing_seq_number         => p_rec.routing_seq_number,
      p_second_nature_of_action_id => p_rec.second_nature_of_action_id,
      p_user_name                  => p_rec.user_name,
      p_user_name_employee_id      => p_rec.user_name_employee_id,
      p_user_name_emp_first_name   => p_rec.user_name_emp_first_name,
      p_user_name_emp_last_name    => p_rec.user_name_emp_last_name,
      p_user_name_emp_middle_names => p_rec.user_name_emp_middle_names,
      p_object_version_number      => p_rec.object_version_number,
      p_pa_request_id_o            => ghr_prh_shd.g_old_rec.pa_request_id,
      p_action_taken_o             => ghr_prh_shd.g_old_rec.action_taken,
      p_approved_flag_o            => ghr_prh_shd.g_old_rec.approved_flag,
      p_approver_flag_o            => ghr_prh_shd.g_old_rec.approver_flag,
      p_approval_status_o          => ghr_prh_shd.g_old_rec.approval_status,
      p_attachment_modified_flag_o => ghr_prh_shd.g_old_rec.attachment_modified_flag,
      p_authorizer_flag_o          => ghr_prh_shd.g_old_rec.authorizer_flag,
      p_date_notification_sent_o   => ghr_prh_shd.g_old_rec.date_notification_sent,
      p_groupbox_id_o              => ghr_prh_shd.g_old_rec.groupbox_id,
      p_initiator_flag_o           => ghr_prh_shd.g_old_rec.initiator_flag,
      p_nature_of_action_id_o      => ghr_prh_shd.g_old_rec.nature_of_action_id,
      p_noa_family_code_o          => ghr_prh_shd.g_old_rec.noa_family_code,
      p_notepad_o                  => ghr_prh_shd.g_old_rec.notepad,
      p_personnelist_flag_o        => ghr_prh_shd.g_old_rec.personnelist_flag,
      p_requester_flag_o           => ghr_prh_shd.g_old_rec.requester_flag,
      p_reviewer_flag_o            => ghr_prh_shd.g_old_rec.reviewer_flag,
      p_routing_list_id_o          => ghr_prh_shd.g_old_rec.routing_list_id,
      p_routing_seq_number_o       => ghr_prh_shd.g_old_rec.routing_seq_number,
      p_second_nature_of_action_id_o =>
                                   ghr_prh_shd.g_old_rec.second_nature_of_action_id,
      p_user_name_o                => ghr_prh_shd.g_old_rec.user_name,
      p_user_name_employee_id_o    => ghr_prh_shd.g_old_rec.user_name_employee_id,
      p_user_name_emp_first_name_o => ghr_prh_shd.g_old_rec.user_name_emp_first_name,
      p_user_name_emp_last_name_o  => ghr_prh_shd.g_old_rec.user_name_emp_last_name,
      p_user_name_emp_middle_names_o =>
                                   ghr_prh_shd.g_old_rec.user_name_emp_middle_names,
      p_object_version_number_o    => ghr_prh_shd.g_old_rec.object_version_number
      );

  exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	 p_module_name => 'GHR_PA_ROUTING_HISTORY'
			,p_hook_type   => 'AU'
	        );
  end;
  -- End of API User Hook for post_update.
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
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out NOCOPY ghr_prh_shd.g_rec_type) is
--
  l_proc  varchar2(72);
  l_rec ghr_prh_shd.g_rec_type;
--
Begin
  --
  l_proc := g_package||'convert_defs';
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_rec := p_rec;
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.pa_request_id = hr_api.g_number) then
    p_rec.pa_request_id :=
    ghr_prh_shd.g_old_rec.pa_request_id;
  End If;
  If (p_rec.attachment_modified_flag = hr_api.g_varchar2) then
    p_rec.attachment_modified_flag :=
    ghr_prh_shd.g_old_rec.attachment_modified_flag;
  End If;
  If (p_rec.initiator_flag = hr_api.g_varchar2) then
    p_rec.initiator_flag :=
    ghr_prh_shd.g_old_rec.initiator_flag;
  End If;
  If (p_rec.approver_flag = hr_api.g_varchar2) then
    p_rec.approver_flag :=
    ghr_prh_shd.g_old_rec.approver_flag;
  End If;
  If (p_rec.reviewer_flag = hr_api.g_varchar2) then
    p_rec.reviewer_flag :=
    ghr_prh_shd.g_old_rec.reviewer_flag;
  End If;
  If (p_rec.requester_flag = hr_api.g_varchar2) then
    p_rec.requester_flag :=
    ghr_prh_shd.g_old_rec.requester_flag;
  End If;
  If (p_rec.authorizer_flag = hr_api.g_varchar2) then
    p_rec.authorizer_flag :=
    ghr_prh_shd.g_old_rec.authorizer_flag;
  End If;
  If (p_rec.personnelist_flag = hr_api.g_varchar2) then
    p_rec.personnelist_flag :=
    ghr_prh_shd.g_old_rec.authorizer_flag;
  End If;
  If (p_rec.approved_flag = hr_api.g_varchar2) then
    p_rec.approved_flag :=
    ghr_prh_shd.g_old_rec.approved_flag;
  End If;
  If (p_rec.user_name_employee_id = hr_api.g_number) then
    p_rec.user_name_employee_id :=
    ghr_prh_shd.g_old_rec.user_name_employee_id;
  End If;
  If (p_rec.notepad = hr_api.g_varchar2) then
    p_rec.notepad :=
    ghr_prh_shd.g_old_rec.notepad;
  End If;
  If (p_rec.action_taken = hr_api.g_varchar2) then
    p_rec.action_taken :=
    ghr_prh_shd.g_old_rec.action_taken;
  End If;
  If (p_rec.user_name = hr_api.g_varchar2) then
    p_rec.user_name :=
    ghr_prh_shd.g_old_rec.user_name;
  End If;
  If (p_rec.groupbox_id = hr_api.g_number) then
    p_rec.groupbox_id :=
    ghr_prh_shd.g_old_rec.groupbox_id;
  End If;
  If (p_rec.routing_list_id = hr_api.g_number) then
    p_rec.routing_list_id :=
    ghr_prh_shd.g_old_rec.routing_list_id;
  End If;
  If (p_rec.routing_seq_number = hr_api.g_number) then
    p_rec.routing_seq_number :=
    ghr_prh_shd.g_old_rec.routing_seq_number;
  End If;
  If (p_rec.noa_family_code = hr_api.g_varchar2) then
    p_rec.noa_family_code :=
    ghr_prh_shd.g_old_rec.noa_family_code;
  End If;
  If (p_rec.nature_of_action_id = hr_api.g_number) then
    p_rec.nature_of_action_id :=
    ghr_prh_shd.g_old_rec.nature_of_action_id;
  End If;
  If (p_rec.second_nature_of_action_id = hr_api.g_number) then
    p_rec.second_nature_of_action_id :=
    ghr_prh_shd.g_old_rec.second_nature_of_action_id;
  End If;
  If (p_rec.approval_status = hr_api.g_varchar2) then
    p_rec.approval_Status :=
    ghr_prh_shd.g_old_rec.approval_status;
  End If;
  If (p_rec.user_name_emp_first_name = hr_api.g_varchar2) then
    p_rec.user_name_emp_first_name :=
    ghr_prh_shd.g_old_rec.user_name_emp_first_name;
  End If;
  If (p_rec.user_name_emp_last_name = hr_api.g_varchar2) then
    p_rec.user_name_emp_last_name :=
    ghr_prh_shd.g_old_rec.user_name_emp_last_name;
  End If;
  If (p_rec.user_name_emp_middle_names = hr_api.g_varchar2) then
    p_rec.user_name_emp_middle_names :=
    ghr_prh_shd.g_old_rec.user_name_emp_middle_names;
  End If;
  If (p_rec.date_notification_sent = hr_api.g_date) then
    p_rec.date_notification_sent :=
    ghr_prh_shd.g_old_rec.date_notification_sent;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
exception
   when others then
      p_rec := l_rec;
      raise;
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out NOCOPY ghr_prh_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc varchar2(72) ;
  l_rec ghr_prh_shd.g_rec_type;
--
Begin
  l_proc := g_package||'upd';
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_rec := p_rec;
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_ghr_prh;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ghr_prh_shd.lck
	(
	p_rec.pa_routing_history_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ghr_prh_bus.update_validate(p_rec);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_ghr_prh;
    p_rec := l_rec;
  when others then
    p_rec := l_rec;
    raise;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pa_routing_history_id        in number,
  p_attachment_modified_flag     in varchar2         default hr_api.g_varchar2,
  p_initiator_flag               in varchar2         default hr_api.g_varchar2,
  p_approver_flag                in varchar2         default hr_api.g_varchar2,
  p_reviewer_flag                in varchar2         default hr_api.g_varchar2,
  p_requester_flag               in varchar2         default hr_api.g_varchar2,
  p_authorizer_flag              in varchar2         default hr_api.g_varchar2,
  p_personnelist_flag            in varchar2         default hr_api.g_varchar2,
  p_approved_flag                in varchar2         default hr_api.g_varchar2,
  p_user_name                    in varchar2         default hr_api.g_varchar2,
  p_user_name_employee_id        in number           default hr_api.g_number,
  p_user_name_emp_first_name     in varchar2         default hr_api.g_varchar2,
  p_user_name_emp_last_name      in varchar2         default hr_api.g_varchar2,
  p_user_name_emp_middle_names   in varchar2         default hr_api.g_varchar2,
  p_notepad		         in varchar2         default hr_api.g_varchar2,
  p_action_taken                 in varchar2         default hr_api.g_varchar2,
  p_groupbox_id                  in number           default hr_api.g_number,
  p_noa_family_code              in varchar2         default hr_api.g_varchar2,
  p_nature_of_action_id          in number           default hr_api.g_number,
  p_second_nature_of_action_id   in number           default hr_api.g_number,
  p_approval_status              in varchar2         default hr_api.g_varchar2,
  p_date_notification_sent       in date             default hr_api.g_date,
  p_object_version_number        in out  NOCOPY  number,
  p_validate                     in        boolean      default false
  ) is
--
  l_rec	  ghr_prh_shd.g_rec_type;
  l_proc  varchar2(72) ;
  l_object_version_number NUMBER;
--
Begin
  l_proc  := g_package||'upd';
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_object_version_number := p_object_version_number;
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_prh_shd.convert_args
  (
  p_pa_routing_history_id,
  hr_api.g_number,
  p_attachment_modified_flag,
  p_initiator_flag,
  p_approver_flag,
  p_reviewer_flag,
  p_requester_flag,
  p_authorizer_flag,
  p_personnelist_flag,
  p_approved_flag,
  p_user_name,
  p_user_name_employee_id,
  p_user_name_emp_first_name,
  p_user_name_emp_last_name,
  p_user_name_emp_middle_names,
  p_notepad,
  p_action_taken,
  p_groupbox_id,
  hr_api.g_number,
  hr_api.g_number,
  p_noa_family_code,
  p_nature_of_action_id,
  p_second_nature_of_action_id,
  p_approval_status,
  p_date_notification_sent,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec,p_validate);

  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
   when others then
      p_object_version_number := l_object_version_number;
      raise;
End upd;
--
end ghr_prh_upd;

/
