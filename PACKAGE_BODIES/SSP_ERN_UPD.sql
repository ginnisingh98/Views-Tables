--------------------------------------------------------
--  DDL for Package Body SSP_ERN_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_ERN_UPD" as
/* $Header: spernrhi.pkb 120.5.12010000.2 2008/08/13 13:25:38 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_ern_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ssp_ern_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ssp_earnings_calculations Row
  --
  update ssp_earnings_calculations
    set	earnings_calculations_id          = p_rec.earnings_calculations_id,
	object_version_number             = p_rec.object_version_number,
	average_earnings_amount           = p_rec.average_earnings_amount,
	user_entered                      = p_rec.user_entered,
	payment_periods                   = p_rec.payment_periods
  where earnings_calculations_id = p_rec.earnings_calculations_id;
  --
  ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_ern_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_ern_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_ern_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 1);
   --
   hr_utility.set_location('Leaving :'||l_proc, 100);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
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
--   errors within this procedure will be a PL/SQL value error due to con 1304683version

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- We must now examine each argument value in the p_rec plsql record structure
  -- to see if a system default is being used. If a system default is being used
  -- then we must set to the 'current' argument value.
  --
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id := ssp_ern_shd.g_old_rec.person_id;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date := ssp_ern_shd.g_old_rec.effective_date;
  End If;
  If (p_rec.average_earnings_amount = hr_api.g_number) then
    p_rec.average_earnings_amount :=
			    ssp_ern_shd.g_old_rec.average_earnings_amount;
  End If;
  If (p_rec.user_entered = hr_api.g_varchar2) then
    p_rec.user_entered := ssp_ern_shd.g_old_rec.user_entered;
  End If;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure upd
  (
  p_rec        in out nocopy ssp_ern_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_ssp_ern;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ssp_ern_shd.lck
	(
	p_rec.earnings_calculations_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ssp_ern_bus.update_validate(p_rec);
  --
  -- Call the supporting pre-update operation if p_rec.average_earnings_amount
  -- is not null
  --
  if p_rec.average_earnings_amount is not null then
     pre_update(p_rec);
     --
     -- Update the row.
     --
     update_dml(p_rec);
     --
     -- Call the supporting post-update operation
     --
     post_update(p_rec);
  end if;
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
     Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_ssp_ern;
End upd;
--
-- ----------------------------------------------------------------------------
-- ----------------------------------< upd >-----------------------------------
-- ----------------------------------------------------------------------------
--
-- Old version used to be called from SSPWSENT, left if called
-- from anywhere else.
--
Procedure upd
  (
  p_earnings_calculations_id	in number,
  p_object_version_number	in out nocopy number,
  p_average_earnings_amount	in out nocopy number ,
  p_validate                    in boolean      default false
  ) is
--
  l_rec	  ssp_ern_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd (old)';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Call conversion function to turn arguments into the l_rec structure.
  --
  l_rec := ssp_ern_shd.convert_args (p_earnings_calculations_id,
                                     p_object_version_number,
                                     hr_api.g_number,
                                     hr_api.g_date,
                                     p_average_earnings_amount,
                                     hr_api.g_varchar2,
				     'S', -- DFoster 1304683 Default to sickness
                                     NULL);
  --
  -- Having converted the arguments into the plsql record structure we call
  -- the corresponding record business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  p_average_earnings_amount  := l_rec.average_earnings_amount;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
End upd;
--
-- ----------------------------------------------------------------------------
-- ----------------------------------< upd >-----------------------------------
-- ----------------------------------------------------------------------------
--
-- New version called from SSPWSENT, with user_entered and payment periods for
-- update.
--
Procedure upd
  (
  p_earnings_calculations_id	in number,
  p_object_version_number	in out nocopy number,
  p_average_earnings_amount	in out nocopy number,
  p_user_entered		in out nocopy varchar2,
  p_absence_category		in out nocopy varchar2, --DFoster 1304683
  p_payment_periods		in out nocopy number,
  p_validate                    in boolean   default false
  ) is
--
  l_rec	  ssp_ern_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Call conversion function to turn arguments into the l_rec structure.
  --
  l_rec := ssp_ern_shd.convert_args (p_earnings_calculations_id,
                                     p_object_version_number,
                                     hr_api.g_number,
                                     hr_api.g_date,
                                     p_average_earnings_amount,
                                     p_user_entered,
				     p_absence_category, --DFoster 1304683
                                     p_payment_periods);
  --
  -- Having converted the arguments into the plsql record structure we call
  -- the corresponding record business process.
  --
  upd(l_rec, p_validate);
  --
  p_object_version_number := l_rec.object_version_number;
  p_average_earnings_amount := l_rec.average_earnings_amount;
  p_payment_periods := l_rec.payment_periods;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
End upd;
--
end ssp_ern_upd;

/
