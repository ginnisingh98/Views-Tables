--------------------------------------------------------
--  DDL for Package Body PQH_BRE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BRE_UPD" as
/* $Header: pqbrerhi.pkb 115.6 2003/06/04 08:19:51 ggnanagu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_bre_upd.';  -- Global package name
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
  (p_rec in out nocopy  pqh_bre_shd.g_rec_type
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
  pqh_bre_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pqh_bdgt_pool_realloctions Row
  --
  update pqh_bdgt_pool_realloctions
    set
     reallocation_id                 = p_rec.reallocation_id
    ,position_id                     = p_rec.position_id
    ,pool_id                         = p_rec.pool_id
    ,reallocation_amt                = p_rec.reallocation_amt
    ,reserved_amt                    = p_rec.reserved_amt
    ,object_version_number           = p_rec.object_version_number
    ,txn_detail_id                  = p_rec.txn_detail_id
    ,transaction_type                = p_rec.transaction_type
    ,budget_detail_id                = p_rec.budget_detail_id
    ,budget_period_id                = p_rec.budget_period_id
    ,entity_id                       = p_rec.entity_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    where reallocation_id = p_rec.reallocation_id;
  --
  pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_bre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_bre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_bre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqh_bre_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pqh_bre_shd.g_rec_type
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
  ,p_rec                          in pqh_bre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_bre_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_reallocation_id
      => p_rec.reallocation_id
      ,p_position_id
      => p_rec.position_id
      ,p_pool_id
      => p_rec.pool_id
      ,p_reallocation_amt
      => p_rec.reallocation_amt
      ,p_reserved_amt
      => p_rec.reserved_amt
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_txn_detail_id
      => p_rec.txn_detail_id
      ,p_transaction_type
      => p_rec.transaction_type
      ,p_budget_detail_id
      => p_rec.budget_detail_id
      ,p_budget_period_id
      => p_rec.budget_period_id
      ,p_entity_id
      => p_rec.entity_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_position_id_o
      => pqh_bre_shd.g_old_rec.position_id
      ,p_pool_id_o
      => pqh_bre_shd.g_old_rec.pool_id
      ,p_reallocation_amt_o
      => pqh_bre_shd.g_old_rec.reallocation_amt
      ,p_reserved_amt_o
      => pqh_bre_shd.g_old_rec.reserved_amt
      ,p_object_version_number_o
      => pqh_bre_shd.g_old_rec.object_version_number
      ,p_txn_detail_id_o
      => pqh_bre_shd.g_old_rec.txn_detail_id
      ,p_transaction_type_o
      => pqh_bre_shd.g_old_rec.transaction_type
      ,p_budget_detail_id_o
      => pqh_bre_shd.g_old_rec.budget_detail_id
      ,p_budget_period_id_o
      => pqh_bre_shd.g_old_rec.budget_period_id
      ,p_entity_id_o
      => pqh_bre_shd.g_old_rec.entity_id
      ,p_start_date_o
      => pqh_bre_shd.g_old_rec.start_date
      ,p_end_date_o
      => pqh_bre_shd.g_old_rec.end_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_BDGT_POOL_REALLOCTIONS'
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
  (p_rec in out nocopy pqh_bre_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    pqh_bre_shd.g_old_rec.position_id;
  End If;
  If (p_rec.pool_id = hr_api.g_number) then
    p_rec.pool_id :=
    pqh_bre_shd.g_old_rec.pool_id;
  End If;
  If (p_rec.reallocation_amt = hr_api.g_number) then
    p_rec.reallocation_amt :=
    pqh_bre_shd.g_old_rec.reallocation_amt;
  End If;
  If (p_rec.reserved_amt = hr_api.g_number) then
    p_rec.reserved_amt :=
    pqh_bre_shd.g_old_rec.reserved_amt;
  End If;
  If (p_rec.txn_detail_id = hr_api.g_number) then
    p_rec.txn_detail_id :=
    pqh_bre_shd.g_old_rec.txn_detail_id;
  End If;
  If (p_rec.transaction_type = hr_api.g_varchar2) then
    p_rec.transaction_type :=
    pqh_bre_shd.g_old_rec.transaction_type;
  End If;
  If (p_rec.budget_detail_id = hr_api.g_number) then
    p_rec.budget_detail_id :=
    pqh_bre_shd.g_old_rec.budget_detail_id;
  End If;
  If (p_rec.budget_period_id = hr_api.g_number) then
    p_rec.budget_period_id :=
    pqh_bre_shd.g_old_rec.budget_period_id;
  End If;
  If (p_rec.entity_id = hr_api.g_number) then
    p_rec.entity_id :=
    pqh_bre_shd.g_old_rec.entity_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    pqh_bre_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    pqh_bre_shd.g_old_rec.end_date;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_bre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_bre_shd.lck
    (p_rec.reallocation_id
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
  pqh_bre_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqh_bre_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_bre_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_bre_upd.post_update
     (p_effective_date
     ,p_rec
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
  (p_effective_date               in     date
  ,p_reallocation_id              in     number
  ,p_object_version_number        in out nocopy    number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_pool_id                      in     number    default hr_api.g_number
  ,p_reallocation_amt             in     number    default hr_api.g_number
  ,p_reserved_amt                 in     number    default hr_api.g_number
  ,p_txn_detail_id               in     number    default hr_api.g_number
  ,p_transaction_type             in     varchar2  default hr_api.g_varchar2
  ,p_budget_detail_id             in     number    default hr_api.g_number
  ,p_budget_period_id             in     number    default hr_api.g_number
  ,p_entity_id                    in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ) is
--
  l_rec   pqh_bre_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_bre_shd.convert_args
  (p_reallocation_id
  ,p_position_id
  ,p_pool_id
  ,p_reallocation_amt
  ,p_reserved_amt
  ,p_object_version_number
  ,p_txn_detail_id
  ,p_transaction_type
  ,p_budget_detail_id
  ,p_budget_period_id
  ,p_entity_id
  ,p_start_date
  ,p_end_date
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_bre_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_bre_upd;

/
