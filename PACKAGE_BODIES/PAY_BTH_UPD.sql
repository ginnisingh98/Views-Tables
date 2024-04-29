--------------------------------------------------------
--  DDL for Package Body PAY_BTH_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BTH_UPD" as
/* $Header: pybthrhi.pkb 120.2 2005/06/12 16:19:52 susivasu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_bth_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_bth_shd.g_rec_type
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
  pay_bth_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_batch_headers Row
  --
  update pay_batch_headers
    set
     batch_id                        = p_rec.batch_id
    ,batch_name                      = p_rec.batch_name
    ,batch_status                    = p_rec.batch_status
    ,action_if_exists                = p_rec.action_if_exists
    ,batch_reference                 = p_rec.batch_reference
    ,batch_source                    = p_rec.batch_source
    ,batch_type                      = p_rec.batch_type
    ,comments                        = p_rec.comments
    ,date_effective_changes          = p_rec.date_effective_changes
    ,purge_after_transfer            = p_rec.purge_after_transfer
    ,reject_if_future_changes        = p_rec.reject_if_future_changes
    ,object_version_number           = p_rec.object_version_number
    ,reject_if_results_exists        = p_rec.reject_if_results_exists
    ,purge_after_rollback            = p_rec.purge_after_rollback
    ,REJECT_ENTRY_NOT_REMOVED        = p_rec.REJECT_ENTRY_NOT_REMOVED
    ,ROLLBACK_ENTRY_UPDATES          = p_rec.ROLLBACK_ENTRY_UPDATES
    where batch_id = p_rec.batch_id;
  --
  pay_bth_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_bth_shd.g_api_dml := false;   -- Unset the api dml status
    pay_bth_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_bth_shd.g_api_dml := false;   -- Unset the api dml status
    pay_bth_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_bth_shd.g_api_dml := false;   -- Unset the api dml status
    pay_bth_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_bth_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pay_bth_shd.g_rec_type
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
--   This private procedure contains any processing which is required after the
--   update dml.
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
  (p_session_date                 in date
  ,p_rec                          in pay_bth_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_bth_rku.after_update
      (p_session_date
      => p_session_date
      ,p_batch_id
      => p_rec.batch_id
      ,p_batch_name
      => p_rec.batch_name
      ,p_batch_status
      => p_rec.batch_status
      ,p_action_if_exists
      => p_rec.action_if_exists
      ,p_batch_reference
      => p_rec.batch_reference
      ,p_batch_source
      => p_rec.batch_source
      ,p_batch_type
      => p_rec.batch_type
      ,p_comments
      => p_rec.comments
      ,p_date_effective_changes
      => p_rec.date_effective_changes
      ,p_purge_after_transfer
      => p_rec.purge_after_transfer
      ,p_reject_if_future_changes
      => p_rec.reject_if_future_changes
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_reject_if_results_exists
      => p_rec.reject_if_results_exists
      ,p_purge_after_rollback
      => p_rec.purge_after_rollback
      ,p_REJECT_ENTRY_NOT_REMOVED
      => p_rec.REJECT_ENTRY_NOT_REMOVED
      ,p_ROLLBACK_ENTRY_UPDATES
      => p_rec.ROLLBACK_ENTRY_UPDATES
      ,p_business_group_id_o
      => pay_bth_shd.g_old_rec.business_group_id
      ,p_batch_name_o
      => pay_bth_shd.g_old_rec.batch_name
      ,p_batch_status_o
      => pay_bth_shd.g_old_rec.batch_status
      ,p_action_if_exists_o
      => pay_bth_shd.g_old_rec.action_if_exists
      ,p_batch_reference_o
      => pay_bth_shd.g_old_rec.batch_reference
      ,p_batch_source_o
      => pay_bth_shd.g_old_rec.batch_source
      ,p_batch_type_o
      => pay_bth_shd.g_old_rec.batch_type
      ,p_comments_o
      => pay_bth_shd.g_old_rec.comments
      ,p_date_effective_changes_o
      => pay_bth_shd.g_old_rec.date_effective_changes
      ,p_purge_after_transfer_o
      => pay_bth_shd.g_old_rec.purge_after_transfer
      ,p_reject_if_future_changes_o
      => pay_bth_shd.g_old_rec.reject_if_future_changes
      ,p_object_version_number_o
      => pay_bth_shd.g_old_rec.object_version_number
      ,p_reject_if_results_exists_o
      => pay_bth_shd.g_old_rec.reject_if_results_exists
      ,p_purge_after_rollback_o
      => pay_bth_shd.g_old_rec.purge_after_rollback
      ,p_REJECT_ENTRY_NOT_REMOVED_o
      => pay_bth_shd.g_old_rec.REJECT_ENTRY_NOT_REMOVED
      ,p_ROLLBACK_ENTRY_UPDATES_o
      => pay_bth_shd.g_old_rec.ROLLBACK_ENTRY_UPDATES
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BATCH_HEADERS'
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
  (p_rec in out nocopy pay_bth_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_bth_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.batch_name = hr_api.g_varchar2) then
    p_rec.batch_name :=
    pay_bth_shd.g_old_rec.batch_name;
  End If;
  If (p_rec.batch_status = hr_api.g_varchar2) then
    p_rec.batch_status :=
    pay_bth_shd.g_old_rec.batch_status;
  End If;
  If (p_rec.action_if_exists = hr_api.g_varchar2) then
    p_rec.action_if_exists :=
    pay_bth_shd.g_old_rec.action_if_exists;
  End If;
  If (p_rec.batch_reference = hr_api.g_varchar2) then
    p_rec.batch_reference :=
    pay_bth_shd.g_old_rec.batch_reference;
  End If;
  If (p_rec.batch_source = hr_api.g_varchar2) then
    p_rec.batch_source :=
    pay_bth_shd.g_old_rec.batch_source;
  End If;
  If (p_rec.batch_type = hr_api.g_varchar2) then
    p_rec.batch_type :=
    pay_bth_shd.g_old_rec.batch_type;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    pay_bth_shd.g_old_rec.comments;
  End If;
  If (p_rec.date_effective_changes = hr_api.g_varchar2) then
    p_rec.date_effective_changes :=
    pay_bth_shd.g_old_rec.date_effective_changes;
  End If;
  If (p_rec.purge_after_transfer = hr_api.g_varchar2) then
    p_rec.purge_after_transfer :=
    pay_bth_shd.g_old_rec.purge_after_transfer;
  End If;
  If (p_rec.reject_if_future_changes = hr_api.g_varchar2) then
    p_rec.reject_if_future_changes :=
    pay_bth_shd.g_old_rec.reject_if_future_changes;
  End If;
  If (p_rec.reject_if_results_exists = hr_api.g_varchar2) then
    p_rec.reject_if_results_exists :=
    pay_bth_shd.g_old_rec.reject_if_results_exists;
  End If;
  If (p_rec.purge_after_rollback = hr_api.g_varchar2) then
    p_rec.purge_after_rollback :=
    pay_bth_shd.g_old_rec.purge_after_rollback;
  End If;
  If (p_rec.REJECT_ENTRY_NOT_REMOVED = hr_api.g_varchar2) then
    p_rec.REJECT_ENTRY_NOT_REMOVED :=
    pay_bth_shd.g_old_rec.REJECT_ENTRY_NOT_REMOVED;
  End If;
  If (p_rec.ROLLBACK_ENTRY_UPDATES = hr_api.g_varchar2) then
    p_rec.ROLLBACK_ENTRY_UPDATES :=
    pay_bth_shd.g_old_rec.ROLLBACK_ENTRY_UPDATES;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_session_date                 in     date
  ,p_rec                          in out nocopy pay_bth_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_bth_shd.lck
    (p_rec.batch_id
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
  pay_bth_bus.update_validate
     (p_session_date,
      p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  pay_bth_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_bth_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_bth_upd.post_update
     (p_session_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_session_date                 in     date
  ,p_batch_id                     in     number
  ,p_object_version_number        in out nocopy number
  ,p_batch_name                   in     varchar2  default hr_api.g_varchar2
  ,p_batch_status                 in     varchar2  default hr_api.g_varchar2
  ,p_action_if_exists             in     varchar2  default hr_api.g_varchar2
  ,p_batch_reference              in     varchar2  default hr_api.g_varchar2
  ,p_batch_source                 in     varchar2  default hr_api.g_varchar2
  ,p_batch_type                   in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_effective_changes       in     varchar2  default hr_api.g_varchar2
  ,p_purge_after_transfer         in     varchar2  default hr_api.g_varchar2
  ,p_reject_if_future_changes     in     varchar2  default hr_api.g_varchar2
  ,p_reject_if_results_exists     in     varchar2  default hr_api.g_varchar2
  ,p_purge_after_rollback         in     varchar2  default hr_api.g_varchar2
  ,p_REJECT_ENTRY_NOT_REMOVED     in     varchar2  default hr_api.g_varchar2
  ,p_ROLLBACK_ENTRY_UPDATES       in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  pay_bth_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_bth_shd.convert_args
  (p_batch_id
  ,hr_api.g_number
  ,p_batch_name
  ,p_batch_status
  ,p_action_if_exists
  ,p_batch_reference
  ,p_batch_source
  ,p_batch_type
  ,p_comments
  ,p_date_effective_changes
  ,p_purge_after_transfer
  ,p_reject_if_future_changes
  ,p_reject_if_results_exists
  ,p_purge_after_rollback
  ,p_REJECT_ENTRY_NOT_REMOVED
  ,p_ROLLBACK_ENTRY_UPDATES
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_bth_upd.upd
     (p_session_date,
      l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_bth_upd;

/
