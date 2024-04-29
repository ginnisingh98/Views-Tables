--------------------------------------------------------
--  DDL for Package Body PAY_MGR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MGR_UPD" as
/* $Header: pymgrrhi.pkb 120.2 2005/07/10 23:13:53 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_mgr_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
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
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy pay_mgr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  pay_mgr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_magnetic_records Row
  --
  update pay_magnetic_records
  set
  formula_id                        = p_rec.formula_id,
  magnetic_block_id                 = p_rec.magnetic_block_id,
  next_block_id                     = p_rec.next_block_id,
  last_run_executed_mode            = p_rec.last_run_executed_mode,
  overflow_mode                     = p_rec.overflow_mode,
  sequence                          = p_rec.sequence,
  frequency                         = p_rec.frequency ,
  action_level                      = p_rec.action_level ,
  block_label                       = p_rec.block_label ,
  block_row_label                   = p_rec.block_row_label ,
  xml_proc_name                     = p_rec.xml_proc_name
  where magnetic_block_id = p_rec.magnetic_block_id
  and   sequence = p_rec.sequence;
  --
  pay_mgr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_mgr_shd.g_api_dml := false;   -- Unset the api dml status
    pay_mgr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_mgr_shd.g_api_dml := false;   -- Unset the api dml status
    pay_mgr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_mgr_shd.g_api_dml := false;   -- Unset the api dml status
    pay_mgr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_mgr_shd.g_api_dml := false;   -- Unset the api dml status
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
-- In Arguments:
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in pay_mgr_shd.g_rec_type) is
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
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in pay_mgr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_defs(p_rec in out nocopy pay_mgr_shd.g_rec_type)
         Return pay_mgr_shd.g_rec_type is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.formula_id = hr_api.g_number) then
    p_rec.formula_id :=
    pay_mgr_shd.g_old_rec.formula_id;
  End If;
  If (p_rec.next_block_id = hr_api.g_number) then
    p_rec.next_block_id :=
    pay_mgr_shd.g_old_rec.next_block_id;
  End If;
  If (p_rec.last_run_executed_mode = hr_api.g_varchar2) then
    p_rec.last_run_executed_mode :=
    pay_mgr_shd.g_old_rec.last_run_executed_mode;
  End If;
  If (p_rec.overflow_mode = hr_api.g_varchar2) then
    p_rec.overflow_mode :=
    pay_mgr_shd.g_old_rec.overflow_mode;
  End If;
  If (p_rec.frequency = hr_api.g_number) then
    p_rec.frequency :=
    pay_mgr_shd.g_old_rec.frequency;
  End If;
  If (p_rec.action_level = hr_api.g_varchar2) then
    p_rec.action_level :=
    pay_mgr_shd.g_old_rec.action_level;
  End If;
  If (p_rec.block_label = hr_api.g_varchar2) then
    p_rec.block_label :=
    pay_mgr_shd.g_old_rec.block_label;
  End If;
  If (p_rec.block_row_label = hr_api.g_varchar2) then
    p_rec.block_row_label :=
    pay_mgr_shd.g_old_rec.block_row_label;
  End If;
  If (p_rec.xml_proc_name = hr_api.g_varchar2) then
    p_rec.xml_proc_name :=
    pay_mgr_shd.g_old_rec.xml_proc_name;
  End If;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy pay_mgr_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_pay_mgr;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  pay_mgr_shd.lck
	(
	p_rec.magnetic_block_id,
	p_rec.sequence
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  pay_mgr_bus.update_validate(convert_defs(p_rec));
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
    ROLLBACK TO upd_pay_mgr;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_formula_id                   in number           default hr_api.g_number,
  p_magnetic_block_id            in number,
  p_next_block_id                in number           default hr_api.g_number,
  p_last_run_executed_mode       in varchar2         default hr_api.g_varchar2,
  p_overflow_mode                in varchar2         default hr_api.g_varchar2,
  p_sequence                     in number,
  p_frequency                    in number           default hr_api.g_number,
  p_validate                     in boolean      default false ,
  p_action_level                 in varchar2 default hr_api.g_varchar2,
  p_block_label                  in varchar2 default hr_api.g_varchar2,
  p_block_row_label              in varchar2 default hr_api.g_varchar2,
  p_xml_proc_name                in varchar2 default hr_api.g_varchar2
  ) is
--
  l_rec	  pay_mgr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_mgr_shd.convert_args
  (
  p_formula_id,
  p_magnetic_block_id,
  p_next_block_id,
  p_last_run_executed_mode,
  p_overflow_mode,
  p_sequence,
  p_frequency ,
  p_action_level,p_block_label,p_block_row_label,p_xml_proc_name
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_mgr_upd;

/
