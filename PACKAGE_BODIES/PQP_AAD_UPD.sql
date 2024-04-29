--------------------------------------------------------
--  DDL for Package Body PQP_AAD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAD_UPD" as
/* $Header: pqaadrhi.pkb 115.5 2003/02/17 22:13:35 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_aad_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pqp_aad_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  pqp_aad_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pqp_analyzed_alien_data Row
  --
  update pqp_analyzed_alien_data
  set
  analyzed_data_id                  = p_rec.analyzed_data_id,
  assignment_id                     = p_rec.assignment_id,
  data_source                       = p_rec.data_source,
  tax_year                          = p_rec.tax_year,
  current_residency_status          = p_rec.current_residency_status,
  nra_to_ra_date                    = p_rec.nra_to_ra_date,
  target_departure_date             = p_rec.target_departure_date,
  tax_residence_country_code        = p_rec.tax_residence_country_code,
  treaty_info_update_date           = p_rec.treaty_info_update_date,
  number_of_days_in_usa             = p_rec.number_of_days_in_usa,
  withldg_allow_eligible_flag       = p_rec.withldg_allow_eligible_flag,
  ra_effective_date                 = p_rec.ra_effective_date,
  record_source                     = p_rec.record_source,
  visa_type                         = p_rec.visa_type,
  j_sub_type                        = p_rec.j_sub_type,
  primary_activity                  = p_rec.primary_activity,
  non_us_country_code               = p_rec.non_us_country_code,
  citizenship_country_code          = p_rec.citizenship_country_code,
  object_version_number             = p_rec.object_version_number  ,
  date_8233_signed                  = p_rec.date_8233_signed,
  date_w4_signed                    = p_rec.date_w4_signed
  where analyzed_data_id = p_rec.analyzed_data_id;
  --
  pqp_aad_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_aad_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_aad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_aad_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_aad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_aad_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_aad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_aad_shd.g_api_dml := false;   -- Unset the api dml status
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in pqp_aad_shd.g_rec_type) is
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(
p_effective_date in date,p_rec in pqp_aad_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pqp_aad_rku.after_update
      (
  p_analyzed_data_id              =>p_rec.analyzed_data_id
 ,p_assignment_id                 =>p_rec.assignment_id
 ,p_data_source                   =>p_rec.data_source
 ,p_tax_year                      =>p_rec.tax_year
 ,p_current_residency_status      =>p_rec.current_residency_status
 ,p_nra_to_ra_date                =>p_rec.nra_to_ra_date
 ,p_target_departure_date         =>p_rec.target_departure_date
 ,p_tax_residence_country_code    =>p_rec.tax_residence_country_code
 ,p_treaty_info_update_date       =>p_rec.treaty_info_update_date
 ,p_number_of_days_in_usa         =>p_rec.number_of_days_in_usa
 ,p_withldg_allow_eligible_flag   =>p_rec.withldg_allow_eligible_flag
 ,p_ra_effective_date             =>p_rec.ra_effective_date
 ,p_record_source                 =>p_rec.record_source
 ,p_visa_type                     =>p_rec.visa_type
 ,p_j_sub_type                    =>p_rec.j_sub_type
 ,p_primary_activity              =>p_rec.primary_activity
 ,p_non_us_country_code           =>p_rec.non_us_country_code
 ,p_citizenship_country_code      =>p_rec.citizenship_country_code
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_date_8233_signed              =>p_rec.date_8233_signed
 ,p_date_w4_signed                =>p_rec.date_w4_signed
 ,p_assignment_id_o               =>pqp_aad_shd.g_old_rec.assignment_id
 ,p_data_source_o                 =>pqp_aad_shd.g_old_rec.data_source
 ,p_tax_year_o                    =>pqp_aad_shd.g_old_rec.tax_year
 ,p_current_residency_status_o    =>pqp_aad_shd.g_old_rec.current_residency_status
 ,p_nra_to_ra_date_o              =>pqp_aad_shd.g_old_rec.nra_to_ra_date
 ,p_target_departure_date_o       =>pqp_aad_shd.g_old_rec.target_departure_date
 ,p_tax_residence_country_code_o  =>pqp_aad_shd.g_old_rec.tax_residence_country_code
 ,p_treaty_info_update_date_o     =>pqp_aad_shd.g_old_rec.treaty_info_update_date
 ,p_number_of_days_in_usa_o       =>pqp_aad_shd.g_old_rec.number_of_days_in_usa
 ,p_withldg_allow_eligible_fla_o =>pqp_aad_shd.g_old_rec.withldg_allow_eligible_flag
 ,p_ra_effective_date_o           =>pqp_aad_shd.g_old_rec.ra_effective_date
 ,p_record_source_o               =>pqp_aad_shd.g_old_rec.record_source
 ,p_visa_type_o                   =>pqp_aad_shd.g_old_rec.visa_type
 ,p_j_sub_type_o                  =>pqp_aad_shd.g_old_rec.j_sub_type
 ,p_primary_activity_o            =>pqp_aad_shd.g_old_rec.primary_activity
 ,p_non_us_country_code_o         =>pqp_aad_shd.g_old_rec.non_us_country_code
 ,p_citizenship_country_code_o    =>pqp_aad_shd.g_old_rec.citizenship_country_code
 ,p_object_version_number_o       =>pqp_aad_shd.g_old_rec.object_version_number
 ,p_date_8233_signed_o            =>pqp_aad_shd.g_old_rec.date_8233_signed
 ,p_date_w4_signed_o              =>pqp_aad_shd.g_old_rec.date_w4_signed
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_ANALYZED_ALIEN_DATA'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy pqp_aad_shd.g_rec_type) is
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
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pqp_aad_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.data_source = hr_api.g_varchar2) then
    p_rec.data_source :=
    pqp_aad_shd.g_old_rec.data_source;
  End If;
  If (p_rec.tax_year = hr_api.g_number) then
    p_rec.tax_year :=
    pqp_aad_shd.g_old_rec.tax_year;
  End If;
  If (p_rec.current_residency_status = hr_api.g_varchar2) then
    p_rec.current_residency_status :=
    pqp_aad_shd.g_old_rec.current_residency_status;
  End If;
  If (p_rec.nra_to_ra_date = hr_api.g_date) then
    p_rec.nra_to_ra_date :=
    pqp_aad_shd.g_old_rec.nra_to_ra_date;
  End If;
  If (p_rec.target_departure_date = hr_api.g_date) then
    p_rec.target_departure_date :=
    pqp_aad_shd.g_old_rec.target_departure_date;
  End If;
  If (p_rec.tax_residence_country_code = hr_api.g_varchar2) then
    p_rec.tax_residence_country_code :=
    pqp_aad_shd.g_old_rec.tax_residence_country_code;
  End If;
  If (p_rec.treaty_info_update_date = hr_api.g_date) then
    p_rec.treaty_info_update_date :=
    pqp_aad_shd.g_old_rec.treaty_info_update_date;
  End If;
  If (p_rec.number_of_days_in_usa = hr_api.g_number) then
    p_rec.number_of_days_in_usa :=
    pqp_aad_shd.g_old_rec.number_of_days_in_usa;
  End If;
  If (p_rec.withldg_allow_eligible_flag = hr_api.g_varchar2) then
    p_rec.withldg_allow_eligible_flag :=
    pqp_aad_shd.g_old_rec.withldg_allow_eligible_flag;
  End If;
  If (p_rec.ra_effective_date = hr_api.g_date) then
    p_rec.ra_effective_date :=
    pqp_aad_shd.g_old_rec.ra_effective_date;
  End If;
  If (p_rec.record_source = hr_api.g_varchar2) then
    p_rec.record_source :=
    pqp_aad_shd.g_old_rec.record_source;
  End If;
  If (p_rec.visa_type = hr_api.g_varchar2) then
    p_rec.visa_type :=
    pqp_aad_shd.g_old_rec.visa_type;
  End If;
  If (p_rec.j_sub_type = hr_api.g_varchar2) then
    p_rec.j_sub_type :=
    pqp_aad_shd.g_old_rec.j_sub_type;
  End If;
  If (p_rec.primary_activity = hr_api.g_varchar2) then
    p_rec.primary_activity :=
    pqp_aad_shd.g_old_rec.primary_activity;
  End If;
  If (p_rec.non_us_country_code = hr_api.g_varchar2) then
    p_rec.non_us_country_code :=
    pqp_aad_shd.g_old_rec.non_us_country_code;
  End If;
  If (p_rec.citizenship_country_code = hr_api.g_varchar2) then
    p_rec.citizenship_country_code :=
    pqp_aad_shd.g_old_rec.citizenship_country_code;
  End If;
  If (p_rec.date_8233_signed = hr_api.g_date) then
    p_rec.date_8233_signed :=
    pqp_aad_shd.g_old_rec.date_8233_signed;
  End If;
  If (p_rec.date_w4_signed = hr_api.g_date) then
    p_rec.date_w4_signed :=
    pqp_aad_shd.g_old_rec.date_w4_signed;
  End If;

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
  p_effective_date in date,
  p_rec        in out nocopy pqp_aad_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqp_aad_shd.lck
	(
	p_rec.analyzed_data_id,
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
  pqp_aad_bus.update_validate(p_rec
  ,p_effective_date);
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
  post_update(
p_effective_date,p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_analyzed_data_id             in number,
  p_assignment_id                in number           default hr_api.g_number,
  p_data_source                  in varchar2         default hr_api.g_varchar2,
  p_tax_year                     in number           default hr_api.g_number,
  p_current_residency_status     in varchar2         default hr_api.g_varchar2,
  p_nra_to_ra_date               in date             default hr_api.g_date,
  p_target_departure_date        in date             default hr_api.g_date,
  p_tax_residence_country_code   in varchar2         default hr_api.g_varchar2,
  p_treaty_info_update_date      in date             default hr_api.g_date,
  p_number_of_days_in_usa        in number           default hr_api.g_number,
  p_withldg_allow_eligible_flag  in varchar2         default hr_api.g_varchar2,
  p_ra_effective_date            in date             default hr_api.g_date,
  p_record_source                in varchar2         default hr_api.g_varchar2,
  p_visa_type                    in varchar2         default hr_api.g_varchar2,
  p_j_sub_type                   in varchar2         default hr_api.g_varchar2,
  p_primary_activity             in varchar2         default hr_api.g_varchar2,
  p_non_us_country_code          in varchar2         default hr_api.g_varchar2,
  p_citizenship_country_code     in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number                                ,
  p_date_8233_signed             in date             default hr_api.g_date    ,
  p_date_w4_signed               in date             default hr_api.g_date
  ) is
--
  l_rec	  pqp_aad_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_aad_shd.convert_args
  (
  p_analyzed_data_id,
  p_assignment_id,
  p_data_source,
  p_tax_year,
  p_current_residency_status,
  p_nra_to_ra_date,
  p_target_departure_date,
  p_tax_residence_country_code,
  p_treaty_info_update_date,
  p_number_of_days_in_usa,
  p_withldg_allow_eligible_flag,
  p_ra_effective_date,
  p_record_source,
  p_visa_type,
  p_j_sub_type,
  p_primary_activity,
  p_non_us_country_code,
  p_citizenship_country_code,
  p_object_version_number ,
  p_date_8233_signed ,
  p_date_w4_signed
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(
    p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqp_aad_upd;

/
