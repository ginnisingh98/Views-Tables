--------------------------------------------------------
--  DDL for Package Body PQH_RHT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RHT_DEL" as
/* $Header: pqrhtrhi.pkb 115.7 2002/12/06 18:08:02 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rht_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in pqh_rht_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the pqh_routing_history row.
  --
  delete from pqh_routing_history
  where routing_history_id = p_rec.routing_history_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqh_rht_shd.constraint_error
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
Procedure pre_delete(p_rec in pqh_rht_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
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
p_effective_date in date,p_rec in pqh_rht_shd.g_rec_type) is
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
    pqh_rht_rkd.after_delete
      (
  p_routing_history_id            =>p_rec.routing_history_id
 ,p_approval_cd_o                 =>pqh_rht_shd.g_old_rec.approval_cd
 ,p_comments_o                    =>pqh_rht_shd.g_old_rec.comments
 ,p_forwarded_by_assignment_id_o  =>pqh_rht_shd.g_old_rec.forwarded_by_assignment_id
 ,p_forwarded_by_member_id_o      =>pqh_rht_shd.g_old_rec.forwarded_by_member_id
 ,p_forwarded_by_position_id_o    =>pqh_rht_shd.g_old_rec.forwarded_by_position_id
 ,p_forwarded_by_user_id_o        =>pqh_rht_shd.g_old_rec.forwarded_by_user_id
 ,p_forwarded_by_role_id_o        =>pqh_rht_shd.g_old_rec.forwarded_by_role_id
 ,p_forwarded_to_assignment_id_o  =>pqh_rht_shd.g_old_rec.forwarded_to_assignment_id
 ,p_forwarded_to_member_id_o      =>pqh_rht_shd.g_old_rec.forwarded_to_member_id
 ,p_forwarded_to_position_id_o    =>pqh_rht_shd.g_old_rec.forwarded_to_position_id
 ,p_forwarded_to_user_id_o        =>pqh_rht_shd.g_old_rec.forwarded_to_user_id
 ,p_forwarded_to_role_id_o        =>pqh_rht_shd.g_old_rec.forwarded_to_role_id
 ,p_notification_date_o           =>pqh_rht_shd.g_old_rec.notification_date
 ,p_pos_structure_version_id_o    =>pqh_rht_shd.g_old_rec.pos_structure_version_id
 ,p_routing_category_id_o         =>pqh_rht_shd.g_old_rec.routing_category_id
 ,p_transaction_category_id_o     =>pqh_rht_shd.g_old_rec.transaction_category_id
 ,p_transaction_id_o              =>pqh_rht_shd.g_old_rec.transaction_id
 ,p_user_action_cd_o              =>pqh_rht_shd.g_old_rec.user_action_cd
 ,p_from_range_name_o             =>pqh_rht_shd.g_old_rec.from_range_name
 ,p_to_range_name_o               =>pqh_rht_shd.g_old_rec.to_range_name
 ,p_list_range_name_o             =>pqh_rht_shd.g_old_rec.list_range_name
 ,p_object_version_number_o       =>pqh_rht_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_routing_history'
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
  p_rec	      in pqh_rht_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqh_rht_shd.lck
	(
	p_rec.routing_history_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pqh_rht_bus.delete_validate(p_rec
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
  p_routing_history_id                 in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pqh_rht_shd.g_rec_type;
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
  l_rec.routing_history_id:= p_routing_history_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_rht_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_rht_del;

/
