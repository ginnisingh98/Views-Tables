--------------------------------------------------------
--  DDL for Package Body PAY_PEV_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PEV_UPD" as
/* $Header: pypperhi.pkb 120.1.12010000.1 2008/07/27 23:25:17 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pev_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_pev_shd.g_rec_type
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
  pay_pev_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_process_events Row
  --
  update pay_process_events
    set
     process_event_id                = p_rec.process_event_id
    ,assignment_id                   = p_rec.assignment_id
    ,effective_date                  = p_rec.effective_date
    ,change_type                     = p_rec.change_type
    ,status                          = p_rec.status
    ,description                     = p_rec.description
    ,event_update_id                 = p_rec.event_update_id
    ,business_group_id               = p_rec.business_group_id
    ,org_process_event_group_id      = p_rec.org_process_event_group_id
    ,surrogate_key                   = p_rec.surrogate_key
    ,object_version_number           = p_rec.object_version_number
    ,calculation_date                = p_rec.calculation_date
    ,retroactive_status              = p_rec.retroactive_status
    ,noted_value                     = p_rec.noted_value
    where process_event_id = p_rec.process_event_id;
  --
  pay_pev_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_pev_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pev_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_pev_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pev_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_pev_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pev_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_pev_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pay_pev_shd.g_rec_type
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
  (p_rec                          in pay_pev_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_pev_rku.after_update
      (p_process_event_id
      => p_rec.process_event_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_effective_date
      => p_rec.effective_date
      ,p_change_type
      => p_rec.change_type
      ,p_status
      => p_rec.status
      ,p_description
      => p_rec.description
      ,p_event_update_id
      => p_rec.event_update_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_org_process_event_group_id
      => p_rec.org_process_event_group_id
      ,p_surrogate_key
      => p_rec.surrogate_key
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_calculation_date
      => p_rec.calculation_date
      ,p_retroactive_status
      => p_rec.retroactive_status
      ,p_noted_value
      => p_rec.noted_value
      ,p_assignment_id_o
      => pay_pev_shd.g_old_rec.assignment_id
      ,p_effective_date_o
      => pay_pev_shd.g_old_rec.effective_date
      ,p_change_type_o
      => pay_pev_shd.g_old_rec.change_type
      ,p_status_o
      => pay_pev_shd.g_old_rec.status
      ,p_description_o
      => pay_pev_shd.g_old_rec.description
      ,p_event_update_id_o
      => pay_pev_shd.g_old_rec.event_update_id
      ,p_business_group_id_o
      => pay_pev_shd.g_old_rec.business_group_id
      ,p_org_process_event_group_id_o
      => pay_pev_shd.g_old_rec.org_process_event_group_id
      ,p_surrogate_key_o
      => pay_pev_shd.g_old_rec.surrogate_key
      ,p_object_version_number_o
      => pay_pev_shd.g_old_rec.object_version_number
      ,p_calculation_date_o
      => pay_pev_shd.g_old_rec.calculation_date
      ,p_retroactive_status_o
      => pay_pev_shd.g_old_rec.retroactive_status
      ,p_noted_value_o
      => pay_pev_shd.g_old_rec.noted_value
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_PROCESS_EVENTS'
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
  (p_rec in out nocopy pay_pev_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pay_pev_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date :=
    pay_pev_shd.g_old_rec.effective_date;
  End If;
  If (p_rec.change_type = hr_api.g_varchar2) then
    p_rec.change_type :=
    pay_pev_shd.g_old_rec.change_type;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    pay_pev_shd.g_old_rec.status;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    pay_pev_shd.g_old_rec.description;
  End If;
  If (p_rec.event_update_id = hr_api.g_number) then
    p_rec.event_update_id :=
    pay_pev_shd.g_old_rec.event_update_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_pev_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.org_process_event_group_id = hr_api.g_number) then
    p_rec.org_process_event_group_id :=
    pay_pev_shd.g_old_rec.org_process_event_group_id;
  End If;
  If (p_rec.surrogate_key = hr_api.g_varchar2) then
    p_rec.surrogate_key :=
    pay_pev_shd.g_old_rec.surrogate_key;
  End If;
  If (p_rec.calculation_date = hr_api.g_date) then
    p_rec.calculation_date :=
    pay_pev_shd.g_old_rec.calculation_date;
  End If;
  If (p_rec.retroactive_status = hr_api.g_varchar2) then
    p_rec.retroactive_status :=
    pay_pev_shd.g_old_rec.retroactive_status;
  End If;
  If (p_rec.noted_value = hr_api.g_varchar2) then
    p_rec.noted_value :=
    pay_pev_shd.g_old_rec.noted_value;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pay_pev_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_pev_shd.lck
    (p_rec.process_event_id
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
  pay_pev_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  pay_pev_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_pev_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_pev_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_process_event_id             in     number
  ,p_object_version_number        in out nocopy    number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_change_type                  in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_event_update_id              in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_org_process_event_group_id   in     number    default hr_api.g_number
  ,p_surrogate_key                in     varchar2  default hr_api.g_varchar2
  ,p_calculation_date             in     date      default hr_api.g_date
  ,p_retroactive_status           in     varchar2  default hr_api.g_varchar2
  ,p_noted_value                  in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  pay_pev_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_pev_shd.convert_args
  (p_process_event_id
  ,p_assignment_id
  ,p_effective_date
  ,p_change_type
  ,p_status
  ,p_description
  ,p_event_update_id
  ,p_business_group_id
  ,p_org_process_event_group_id
  ,p_surrogate_key
  ,p_object_version_number
  ,p_calculation_date
  ,p_retroactive_status
  ,p_noted_value
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_pev_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_pev_upd;

/
