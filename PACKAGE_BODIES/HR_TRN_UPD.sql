--------------------------------------------------------
--  DDL for Package Body HR_TRN_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRN_UPD" as
/* $Header: hrtrnrhi.pkb 120.2 2005/09/21 04:59:16 hpandya noship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_trn_upd.';  -- Global package name
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
--   2) To set and unset the g_api_dml sthr_trn_updatus as required (as we are about to
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy hr_trn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_trn_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the hr_api_transactions Row
  --
  update hr_api_transactions
  set
  transaction_id                  = p_rec.transaction_id,
  creator_person_id               = p_rec.creator_person_id,
  transaction_privilege           = p_rec.transaction_privilege,
  product_code                    = p_rec.product_code,
  url                             = p_rec.url,
  status                          = p_rec.status,
  transaction_state               = p_rec.transaction_state,    --ns
  section_display_name            = p_rec.section_display_name,
  function_id                     = p_rec.function_id,
  transaction_ref_table           = p_rec.transaction_ref_table,
  transaction_ref_id              = p_rec.transaction_ref_id,
  transaction_type                = p_rec.transaction_type,
  assignment_id                   = p_rec.assignment_id,
  api_addtnl_info                 = p_rec.api_addtnl_info,
  selected_person_id              = p_rec.selected_person_id,
  item_type                       = p_rec.item_type,
  item_key                        = p_rec.item_key,
  transaction_effective_date      = p_rec.transaction_effective_date,
  process_name                    = p_rec.process_name,
  plan_id                         = p_rec.plan_id,
  rptg_grp_id                     = p_rec.rptg_grp_id,
  effective_date_option           = p_rec.effective_date_option,
  parent_transaction_id           = p_rec.parent_transaction_id,
  relaunch_function               = p_rec.relaunch_function,
  transaction_group               = p_rec.transaction_group,
  transaction_identifier          = p_rec.transaction_identifier,
  transaction_document            = p_rec.transaction_document

  where transaction_id = p_rec.transaction_id;
  --
  -- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej
  --
  hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
    hr_trn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
    hr_trn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
    hr_trn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in hr_trn_shd.g_rec_type) is
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
Procedure post_update(p_rec in hr_trn_shd.g_rec_type) is
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

/*
Procedure convert_defs(p_rec in out nocopy hr_trn_shd.g_rec_type) is
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
  If (p_rec.creator_person_id = hr_api.g_number) then
    p_rec.creator_person_id :=
    hr_trn_shd.g_old_rec.creator_person_id;
  End If;
  If (p_rec.transaction_privilege = hr_api.g_varchar2) then
    p_rec.transaction_privilege :=
    hr_trn_shd.g_old_rec.transaction_privilege;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
*/

Procedure convert_defs(p_rec in out nocopy hr_trn_shd.g_rec_type) is
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
  If (p_rec.creator_person_id = hr_api.g_number) then
    p_rec.creator_person_id :=
    hr_trn_shd.g_old_rec.creator_person_id;
  End If;
  If (p_rec.transaction_privilege = hr_api.g_varchar2) then
    p_rec.transaction_privilege :=
    hr_trn_shd.g_old_rec.transaction_privilege;
  End If;
  If (p_rec.product_code = hr_api.g_varchar2) then
    p_rec.product_code :=
    hr_trn_shd.g_old_rec.product_code;
  End If;
  If (p_rec.url = hr_api.g_varchar2) then
    p_rec.url :=
    hr_trn_shd.g_old_rec.url;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    hr_trn_shd.g_old_rec.status;
  End If;
  If (p_rec.section_display_name = hr_api.g_varchar2) then
    p_rec.section_display_name :=
    hr_trn_shd.g_old_rec.section_display_name;
  End If;
  If (p_rec.function_id = hr_api.g_number) then
    p_rec.function_id :=
    hr_trn_shd.g_old_rec.function_id;
  End If;
  If (p_rec.transaction_ref_table = hr_api.g_varchar2) then
    p_rec.transaction_ref_table :=
    hr_trn_shd.g_old_rec.transaction_ref_table;
  End If;
  If (p_rec.transaction_ref_id = hr_api.g_number) then
    p_rec.transaction_ref_id :=
    hr_trn_shd.g_old_rec.transaction_ref_id;
  End If;
  If (p_rec.transaction_type = hr_api.g_varchar2) then
    p_rec.transaction_type :=
    hr_trn_shd.g_old_rec.transaction_type;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    hr_trn_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.api_addtnl_info = hr_api.g_varchar2) then
    p_rec.api_addtnl_info :=
    hr_trn_shd.g_old_rec.api_addtnl_info;
  End If;
  If (p_rec.selected_person_id = hr_api.g_number) then
    p_rec.selected_person_id :=
    hr_trn_shd.g_old_rec.selected_person_id;
  End If;
  If (p_rec.item_type = hr_api.g_varchar2) then
    p_rec.item_type :=
    hr_trn_shd.g_old_rec.item_type;
  End If;
  If (p_rec.item_key = hr_api.g_varchar2) then
    p_rec.item_key :=
    hr_trn_shd.g_old_rec.item_key;
  End If;
  If (p_rec.transaction_effective_date = hr_api.g_date) then
    p_rec.transaction_effective_date :=
    hr_trn_shd.g_old_rec.transaction_effective_date;
  End If;
  If (p_rec.process_name = hr_api.g_varchar2) then
    p_rec.process_name :=
    hr_trn_shd.g_old_rec.process_name;
  End If;
  If (p_rec.plan_id = hr_api.g_number) then
    p_rec.plan_id :=
    hr_trn_shd.g_old_rec.plan_id;
  End If;
  If (p_rec.rptg_grp_id = hr_api.g_number) then
    p_rec.rptg_grp_id :=
    hr_trn_shd.g_old_rec.rptg_grp_id;
  End If;
  If (p_rec.effective_date_option = hr_api.g_varchar2) then
    p_rec.effective_date_option :=
    hr_trn_shd.g_old_rec.effective_date_option;
  End If;
  If (p_rec.parent_transaction_id = hr_api.g_number) then
    p_rec.parent_transaction_id :=
    hr_trn_shd.g_old_rec.parent_transaction_id;
  End If;
  If (p_rec.relaunch_function = hr_api.g_varchar2) then
    p_rec.relaunch_function :=
    hr_trn_shd.g_old_rec.relaunch_function;
  End If;
  If (p_rec.transaction_group = hr_api.g_varchar2) then
    p_rec.transaction_group :=
    hr_trn_shd.g_old_rec.transaction_group;
  End If;
  If (p_rec.transaction_identifier = hr_api.g_varchar2) then
    p_rec.transaction_identifier :=
    hr_trn_shd.g_old_rec.transaction_identifier;
  End If;

  -- If the new value is null then set it to its original value.
  If (p_rec.transaction_document is null) then
    p_rec.transaction_document :=
    hr_trn_shd.g_old_rec.transaction_document;
  End If;
  --
  -- plan_id, rptg_grp_id, effective_date_option added by sanej
  --
  --ns start
  -- Set the transaction state to wip if it's not a new transaction
  IF (p_rec.transaction_state = hr_api.g_varchar2 ) THEN
      p_rec.transaction_state := hr_trn_shd.g_old_rec.transaction_state;
  END IF;
  --ns end
  --

  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy hr_trn_shd.g_rec_type,
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
    SAVEPOINT upd_hr_trn;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  hr_trn_shd.lck
    (
    p_rec.transaction_id
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  hr_trn_bus.update_validate(p_rec);
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
    ROLLBACK TO upd_hr_trn;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_transaction_id               in number,
  p_creator_person_id            in number           default hr_api.g_number,
  p_transaction_privilege        in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false
  ) is
--
  l_rec   hr_trn_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_trn_shd.convert_args
  (
  p_transaction_id,
  p_creator_person_id,
  p_transaction_privilege
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
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_transaction_id               in number,
  p_creator_person_id            in number           default hr_api.g_number,
  p_transaction_privilege        in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
  p_product_code                 in varchar2         default hr_api.g_varchar2,
  p_url                          in varchar2             default hr_api.g_varchar2,
  p_status                       in varchar2,
  p_transaction_state            in varchar2         default hr_api.g_varchar2, --ns
  p_section_display_name          in varchar2        default hr_api.g_varchar2,
  p_function_id                  in number           default hr_api.g_number,
  p_transaction_ref_table        in varchar2         default hr_api.g_varchar2,
  p_transaction_ref_id           in number           default hr_api.g_number,
  p_transaction_type             in varchar2         default hr_api.g_varchar2,
  p_assignment_id                in number           default hr_api.g_number,
  p_api_addtnl_info              in varchar2         default hr_api.g_varchar2,
  p_selected_person_id           in number           default hr_api.g_number,
  p_item_type                    in varchar2         default hr_api.g_varchar2,
  p_item_key                     in varchar2         default hr_api.g_varchar2,
  p_transaction_effective_date   in date             default hr_api.g_date,
  p_process_name                 in varchar2         default hr_api.g_varchar2,
  p_plan_id                      in number           default hr_api.g_number,
  p_rptg_grp_id                  in number           default hr_api.g_number,
  p_effective_date_option        in varchar2         default hr_api.g_varchar2,
  p_creator_role                 in varchar2         default hr_api.g_varchar2,
  p_last_update_role             in varchar2         default hr_api.g_varchar2,
  p_parent_transaction_id        in number           default hr_api.g_number,
  p_relaunch_function            in varchar2         default hr_api.g_varchar2,
  p_transaction_group            in varchar2         default hr_api.g_varchar2,
  p_transaction_identifier       in varchar2         default hr_api.g_varchar2,
  p_transaction_document         in clob             default NULL
  ) is
  --
  -- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej
--
  l_rec   hr_trn_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --


  l_rec :=
  hr_trn_shd.convert_args
  (
  p_transaction_id,
  p_creator_person_id,
  p_transaction_privilege,
  p_product_code,
  p_url,
  p_status,
  p_transaction_state, --ns
  p_section_display_name,
  p_function_id,
  p_transaction_ref_table,
  p_transaction_ref_id,
  p_transaction_type,
  p_assignment_id,
  p_api_addtnl_info,
  p_selected_person_id,
  p_item_type,
  p_item_key,
  p_transaction_effective_date,
  p_process_name,
  p_plan_id,
  p_rptg_grp_id,
  p_effective_date_option,
  p_creator_role,
  p_last_update_role,
  p_parent_transaction_id,
  p_relaunch_function,
  p_transaction_group,
  p_transaction_identifier,
  p_transaction_document
  );
  --
  -- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej
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

end hr_trn_upd;

/
