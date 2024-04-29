--------------------------------------------------------
--  DDL for Package Body PER_SEU_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SEU_DEL" as
/* $Header: peseurhi.pkb 120.4 2005/11/09 13:59:48 vbanner noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'per_seu_del.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
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
  (p_rec in per_seu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_security_users row.
  --
  delete from per_security_users
  where security_user_id = p_rec.security_user_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_seu_shd.constraint_error
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
Procedure pre_delete(p_rec in per_seu_shd.g_rec_type) is
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
Procedure post_delete
  (p_rec in per_seu_shd.g_rec_type
  ,p_del_static_lists_warning out nocopy boolean) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin

  IF g_debug THEN
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;

  --
  -- Set the warning flag to true if the user has static lists
  -- and they will be deleted.
  --
  p_del_static_lists_warning :=
    hr_security_internal.user_in_static_lists
      (p_user_id             => per_seu_shd.g_old_rec.user_id
      ,p_security_profile_id => per_seu_shd.g_old_rec.security_profile_id);

  IF p_del_static_lists_warning THEN
    --
    -- Delete the static lists for this user.
    --
    IF g_debug THEN
      hr_utility.set_location(l_proc, 10);
    END IF;

    hr_security_internal.delete_static_lists_for_user
      (p_user_id             => per_seu_shd.g_old_rec.user_id
      ,p_security_profile_id => per_seu_shd.g_old_rec.security_profile_id);

  END IF;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 15);
  END IF;

  begin
    --
    per_seu_rkd.after_delete
      (p_security_user_id
      => p_rec.security_user_id
      ,p_user_id_o
      => per_seu_shd.g_old_rec.user_id
      ,p_security_profile_id_o
      => per_seu_shd.g_old_rec.security_profile_id
      ,p_object_version_number_o
      => per_seu_shd.g_old_rec.object_version_number
      ,p_del_static_lists_warning
      => p_del_static_lists_warning
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_SECURITY_USERS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  IF g_debug THEN
    hr_utility.set_location('Leaving:'||l_proc, 999);
  END IF;

End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec                      in  per_seu_shd.g_rec_type
  ,p_del_static_lists_warning out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
  l_del_static_lists_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_seu_shd.lck
    (p_rec.security_user_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_seu_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  per_seu_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_seu_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_seu_del.post_delete(p_rec, l_del_static_lists_warning);

  --
  -- Set the out parameters.
  --
  p_del_static_lists_warning := l_del_static_lists_warning;

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
  (p_security_user_id                     in         number
  ,p_object_version_number                in         number
  ,p_del_static_lists_warning             out nocopy boolean
  ) is
--
  l_rec   per_seu_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
  l_del_static_lists_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.security_user_id := p_security_user_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_seu_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_seu_del.del(l_rec, l_del_static_lists_warning);

  --
  -- Set the out parameters.
  --
  p_del_static_lists_warning := l_del_static_lists_warning;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End del;
--
end per_seu_del;

/
