--------------------------------------------------------
--  DDL for Package Body PER_SEU_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SEU_UPD" as
/* $Header: peseurhi.pkb 120.4 2005/11/09 13:59:48 vbanner noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'per_seu_upd.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
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
  (p_rec in out nocopy per_seu_shd.g_rec_type
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
  -- Update the per_security_users Row
  --
  update per_security_users
    set
     security_user_id                = p_rec.security_user_id
    ,user_id                         = p_rec.user_id
    ,security_profile_id             = p_rec.security_profile_id
    ,process_in_next_run_flag        = p_rec.process_in_next_run_flag
    ,object_version_number           = p_rec.object_version_number
    where security_user_id = p_rec.security_user_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_seu_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_seu_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_seu_shd.constraint_error
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
  (p_rec in per_seu_shd.g_rec_type
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
  ,p_rec                          in per_seu_shd.g_rec_type
  ,p_del_static_lists_warning     out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin

  IF g_debug THEN
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;

  --
  -- A change to the user or security profile means that
  -- existing permissions stored in the static list are
  -- incorrect and should be removed.
  --
  IF NVL(per_seu_shd.g_old_rec.user_id, hr_api.g_number)
      <> NVL(p_rec.user_id, hr_api.g_number)
  OR NVL(per_seu_shd.g_old_rec.security_profile_id, hr_api.g_number)
      <> NVL(p_rec.security_profile_id, hr_api.g_number)
  THEN
    --
    -- Set the warning flag to true if the user has static lists
    -- and they will be deleted.
    --
    IF g_debug THEN
      hr_utility.set_location(l_proc, 10);
    END IF;

    p_del_static_lists_warning :=
      hr_security_internal.user_in_static_lists
        (p_user_id             => per_seu_shd.g_old_rec.user_id
        ,p_security_profile_id => per_seu_shd.g_old_rec.security_profile_id);

    IF p_del_static_lists_warning THEN
      --
      -- Delete the static lists for this user.
      --
      IF g_debug THEN
        hr_utility.set_location(l_proc, 15);
      END IF;

      hr_security_internal.delete_static_lists_for_user
        (p_user_id             => per_seu_shd.g_old_rec.user_id
        ,p_security_profile_id => per_seu_shd.g_old_rec.security_profile_id);

    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  begin
    per_seu_rku.after_update
      (p_effective_date    => p_effective_date
      ,p_security_user_id  => p_rec.security_user_id
      ,p_user_id           => p_rec.user_id
      ,p_security_profile_id => p_rec.security_profile_id
      ,p_process_in_next_run_flag => p_rec.process_in_next_run_flag
      ,p_object_version_number => p_rec.object_version_number
      ,p_user_id_o => per_seu_shd.g_old_rec.user_id
      ,p_security_profile_id_o => per_seu_shd.g_old_rec.security_profile_id
      ,p_process_in_next_run_flag_o => per_seu_shd.g_old_rec.process_in_next_run_flag
      ,p_object_version_number_o => per_seu_shd.g_old_rec.object_version_number
      ,p_del_static_lists_warning => p_del_static_lists_warning
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_SECURITY_USERS'
        ,p_hook_type   => 'AU');
      --
  end;

  IF g_debug THEN
    hr_utility.set_location(' Leaving:'||l_proc, 999);
  END IF;

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
  (p_rec in out nocopy per_seu_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.user_id = hr_api.g_number) then
    p_rec.user_id :=
    per_seu_shd.g_old_rec.user_id;
  End If;
  If (p_rec.security_profile_id = hr_api.g_number) then
    p_rec.security_profile_id :=
    per_seu_shd.g_old_rec.security_profile_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_seu_shd.g_rec_type
  ,p_del_static_lists_warning     out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
  l_del_static_lists_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_seu_shd.lck
    (p_rec.security_user_id
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
  per_seu_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  per_seu_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_seu_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_seu_upd.post_update
     (p_effective_date
     ,p_rec
     ,l_del_static_lists_warning
     );

  --
  -- Set the out parameters.
  --
  p_del_static_lists_warning := l_del_static_lists_warning;

  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_security_user_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_user_id                      in     number    default hr_api.g_number
  ,p_security_profile_id          in     number    default hr_api.g_number
  ,p_process_in_next_run_flag     in     varchar2  default hr_api.g_varchar2
  ,p_del_static_lists_warning        out nocopy boolean
  ) is
--
  l_rec   per_seu_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
  l_del_static_lists_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_seu_shd.convert_args
  (p_security_user_id
  ,p_user_id
  ,p_security_profile_id
  ,p_process_in_next_run_flag
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_seu_upd.upd
     (p_effective_date
     ,l_rec
     ,l_del_static_lists_warning
     );

  --
  -- Set the out parameters.
  --
  p_object_version_number    := l_rec.object_version_number;
  p_del_static_lists_warning := l_del_static_lists_warning;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

End upd;
--
end per_seu_upd;

/
