--------------------------------------------------------
--  DDL for Package Body GHR_PRH_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PRH_DEL" as
/* $Header: ghprhrhi.pkb 120.2.12010000.2 2009/08/11 09:26:23 managarw ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_prh_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To delete the specified row from the schema using the primary key in
--      the predicates.
--   2) To trap any constraint violations that may have occurred.
--   3) To raise any other errors.
--
-- Pre Conditions:
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in ghr_prh_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'delete_dml';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  -- Delete the ghr_pa_routing_history row.
  --
  delete from ghr_pa_routing_history
  where pa_routing_history_id = p_rec.pa_routing_history_id;
  --

  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ghr_prh_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ghr_prh_shd.g_rec_type) is
--
  l_proc  varchar2(72) ;
--
Begin
  l_proc := g_package||'pre_delete';
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
-- Pre Conditions:
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
Procedure post_delete(p_rec in ghr_prh_shd.g_rec_type) is
--
  l_proc  varchar2(72) ;
--
Begin
  l_proc := g_package||'post_delete';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     ghr_prh_rkd.after_delete	(
      p_pa_routing_history_id      => p_rec.pa_routing_history_id,
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
			,p_hook_type   => 'AD'
	        );
  end;
  -- End of API User Hook for post_delete.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in ghr_prh_shd.g_rec_type,
  p_validate  in boolean default false
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'del';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_ghr_prh;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  ghr_prh_shd.lck
	(
	p_rec.pa_routing_history_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ghr_prh_bus.delete_validate(p_rec);
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
    ROLLBACK TO del_ghr_prh;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_pa_routing_history_id              in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  ghr_prh_shd.g_rec_type;
  l_proc  varchar2(72) ;
--
Begin
  l_proc  := g_package||'del';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.pa_routing_history_id:= p_pa_routing_history_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ghr_prh_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ghr_prh_del;

/
