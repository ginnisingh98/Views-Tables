--------------------------------------------------------
--  DDL for Package Body PQH_TXH_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TXH_UPD" as
/* $Header: pqtxhrhi.pkb 120.2 2005/12/21 11:29:59 hpandya noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_txh_upd.';  -- Global package name
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
  (p_rec in out nocopy pqh_txh_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Update the pqh_ss_transaction_history Row
  --
  update pqh_ss_transaction_history
    set
     transaction_history_id          = p_rec.transaction_history_id
    ,creator_person_id               = p_rec.creator_person_id
    ,assignment_id                   = p_rec.assignment_id
    ,selected_person_id              = p_rec.selected_person_id
    ,item_type                       = p_rec.item_type
    ,item_key                        = p_rec.item_key
    ,process_name                    = p_rec.process_name
    ,approval_item_type              = p_rec.approval_item_type
    ,approval_item_key               = p_rec.approval_item_key
    ,function_id                     = p_rec.function_id
    ,rptg_grp_id                     = p_rec.rptg_grp_id
    ,plan_id                         = p_rec.plan_id
    ,transaction_group               = p_rec.transaction_group
    ,transaction_identifier          = p_rec.transaction_identifier
    where transaction_history_id = p_rec.transaction_history_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_txh_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_txh_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_txh_shd.constraint_error
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
  (p_rec in pqh_txh_shd.g_rec_type
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
  (p_rec                          in pqh_txh_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    null;
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_SS_TRANSACTION_HISTORY'
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
  (p_rec in out nocopy pqh_txh_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.creator_person_id = hr_api.g_number) then
    p_rec.creator_person_id :=
    pqh_txh_shd.g_old_rec.creator_person_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pqh_txh_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.selected_person_id = hr_api.g_number) then
    p_rec.selected_person_id :=
    pqh_txh_shd.g_old_rec.selected_person_id;
  End If;
  If (p_rec.item_type = hr_api.g_varchar2) then
    p_rec.item_type :=
    pqh_txh_shd.g_old_rec.item_type;
  End If;
  If (p_rec.item_key = hr_api.g_varchar2) then
    p_rec.item_key :=
    pqh_txh_shd.g_old_rec.item_key;
  End If;
  If (p_rec.process_name = hr_api.g_varchar2) then
    p_rec.process_name :=
    pqh_txh_shd.g_old_rec.process_name;
  End If;
  If (p_rec.approval_item_type = hr_api.g_varchar2) then
    p_rec.approval_item_type :=
    pqh_txh_shd.g_old_rec.approval_item_type;
  End If;
  If (p_rec.approval_item_key = hr_api.g_varchar2) then
    p_rec.approval_item_key :=
    pqh_txh_shd.g_old_rec.approval_item_key;
  End If;
  If (p_rec.function_id = hr_api.g_number) then
    p_rec.function_id :=
    pqh_txh_shd.g_old_rec.function_id;
  End If;
  If (p_rec.rptg_grp_id = hr_api.g_number) then
    p_rec.rptg_grp_id :=
    pqh_txh_shd.g_old_rec.rptg_grp_id;
  End If;
  If (p_rec.plan_id = hr_api.g_number) then
    p_rec.plan_id :=
    pqh_txh_shd.g_old_rec.plan_id;
  End If;
  If (p_rec.transaction_group = hr_api.g_varchar2) then
    p_rec.transaction_group :=
    pqh_txh_shd.g_old_rec.transaction_group;
  End If;
  If (p_rec.transaction_identifier = hr_api.g_varchar2) then
    p_rec.transaction_identifier :=
    pqh_txh_shd.g_old_rec.transaction_identifier;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pqh_txh_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_txh_shd.lck
    (p_rec.transaction_history_id
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pqh_txh_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqh_txh_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_txh_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_txh_upd.post_update
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_transaction_history_id       in     number
  ,p_creator_person_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_selected_person_id           in     number    default hr_api.g_number
  ,p_item_type                    in     varchar2  default hr_api.g_varchar2
  ,p_item_key                     in     varchar2  default hr_api.g_varchar2
  ,p_process_name                 in     varchar2  default hr_api.g_varchar2
  ,p_approval_item_type           in     varchar2  default hr_api.g_varchar2
  ,p_approval_item_key            in     varchar2  default hr_api.g_varchar2
  ,p_function_id                  in     number    default hr_api.g_number
  ,p_rptg_grp_id                  in     number    default hr_api.g_number
  ,p_plan_id                      in     number    default hr_api.g_number
  ,p_transaction_group            in     varchar2  default hr_api.g_varchar2
  ,p_transaction_identifier       in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   pqh_txh_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_txh_shd.convert_args
  (p_transaction_history_id
  ,p_creator_person_id
  ,p_assignment_id
  ,p_selected_person_id
  ,p_item_type
  ,p_item_key
  ,p_process_name
  ,p_approval_item_type
  ,p_approval_item_key
  ,p_function_id
  ,p_rptg_grp_id
  ,p_plan_id
  ,p_transaction_group
  ,p_transaction_identifier
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_txh_upd.upd
     (l_rec
     );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_txh_upd;

/
