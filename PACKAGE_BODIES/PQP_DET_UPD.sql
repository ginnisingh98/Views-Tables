--------------------------------------------------------
--  DDL for Package Body PQP_DET_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_DET_UPD" as
/* $Header: pqdetrhi.pkb 115.8 2003/02/17 22:14:03 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_det_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pqp_det_shd.g_rec_type) is
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
  pqp_det_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pqp_analyzed_alien_details Row
  --
  update pqp_analyzed_alien_details
  set
  analyzed_data_details_id          = p_rec.analyzed_data_details_id,
  analyzed_data_id                  = p_rec.analyzed_data_id,
  income_code                       = p_rec.income_code,
  withholding_rate                  = p_rec.withholding_rate,
  income_code_sub_type              = p_rec.income_code_sub_type,
  exemption_code                    = p_rec.exemption_code,
  maximum_benefit_amount            = p_rec.maximum_benefit_amount,
  retro_lose_ben_amt_flag           = p_rec.retro_lose_ben_amt_flag,
  date_benefit_ends                 = p_rec.date_benefit_ends,
  retro_lose_ben_date_flag          = p_rec.retro_lose_ben_date_flag,
  nra_exempt_from_ss                = p_rec.nra_exempt_from_ss,
  nra_exempt_from_medicare          = p_rec.nra_exempt_from_medicare,
  student_exempt_from_ss            = p_rec.student_exempt_from_ss,
  student_exempt_from_medicare      = p_rec.student_exempt_from_medicare,
  addl_withholding_flag             = p_rec.addl_withholding_flag,
  constant_addl_tax                 = p_rec.constant_addl_tax,
  addl_withholding_amt              = p_rec.addl_withholding_amt,
  addl_wthldng_amt_period_type      = p_rec.addl_wthldng_amt_period_type,
  personal_exemption                = p_rec.personal_exemption,
  addl_exemption_allowed            = p_rec.addl_exemption_allowed,
  treaty_ben_allowed_flag           = p_rec.treaty_ben_allowed_flag,
  treaty_benefits_start_date        = p_rec.treaty_benefits_start_date,
  object_version_number             = p_rec.object_version_number,
  retro_loss_notification_sent      = p_rec.retro_loss_notification_sent,
  current_analysis                  = p_rec.current_analysis,
  forecast_income_code              = p_rec.forecast_income_code
  where analyzed_data_details_id    = p_rec.analyzed_data_details_id;
  --
  pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_det_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_det_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_det_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in pqp_det_shd.g_rec_type) is
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
p_effective_date in date,p_rec in pqp_det_shd.g_rec_type) is
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
    pqp_det_rku.after_update
      (
  p_analyzed_data_details_id      =>p_rec.analyzed_data_details_id
 ,p_analyzed_data_id              =>p_rec.analyzed_data_id
 ,p_income_code                   =>p_rec.income_code
 ,p_withholding_rate              =>p_rec.withholding_rate
 ,p_income_code_sub_type          =>p_rec.income_code_sub_type
 ,p_exemption_code                =>p_rec.exemption_code
 ,p_maximum_benefit_amount        =>p_rec.maximum_benefit_amount
 ,p_retro_lose_ben_amt_flag       =>p_rec.retro_lose_ben_amt_flag
 ,p_date_benefit_ends             =>p_rec.date_benefit_ends
 ,p_retro_lose_ben_date_flag      =>p_rec.retro_lose_ben_date_flag
 ,p_nra_exempt_from_ss            =>p_rec.nra_exempt_from_ss
 ,p_nra_exempt_from_medicare      =>p_rec.nra_exempt_from_medicare
 ,p_student_exempt_from_ss        =>p_rec.student_exempt_from_ss
 ,p_student_exempt_from_medi      =>p_rec.student_exempt_from_medicare
 ,p_addl_withholding_flag         =>p_rec.addl_withholding_flag
 ,p_constant_addl_tax             =>p_rec.constant_addl_tax
 ,p_addl_withholding_amt          =>p_rec.addl_withholding_amt
 ,p_addl_wthldng_amt_period_type  =>p_rec.addl_wthldng_amt_period_type
 ,p_personal_exemption            =>p_rec.personal_exemption
 ,p_addl_exemption_allowed        =>p_rec.addl_exemption_allowed
 ,p_treaty_ben_allowed_flag       =>p_rec.treaty_ben_allowed_flag
 ,p_treaty_benefits_start_date    =>p_rec.treaty_benefits_start_date
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_retro_loss_notification_sent  =>p_rec.retro_loss_notification_sent
 ,p_current_analysis              =>p_rec.current_analysis
 ,p_forecast_income_code          =>p_rec.forecast_income_code
 ,p_analyzed_data_id_o            =>pqp_det_shd.g_old_rec.analyzed_data_id
 ,p_income_code_o                 =>pqp_det_shd.g_old_rec.income_code
 ,p_withholding_rate_o            =>pqp_det_shd.g_old_rec.withholding_rate
 ,p_income_code_sub_type_o        =>pqp_det_shd.g_old_rec.income_code_sub_type
 ,p_exemption_code_o              =>pqp_det_shd.g_old_rec.exemption_code
 ,p_maximum_benefit_amount_o      =>pqp_det_shd.g_old_rec.maximum_benefit_amount
 ,p_retro_lose_ben_amt_flag_o     =>pqp_det_shd.g_old_rec.retro_lose_ben_amt_flag
 ,p_date_benefit_ends_o           =>pqp_det_shd.g_old_rec.date_benefit_ends
 ,p_retro_lose_ben_date_flag_o    =>pqp_det_shd.g_old_rec.retro_lose_ben_date_flag
 ,p_nra_exempt_from_ss_o          =>pqp_det_shd.g_old_rec.nra_exempt_from_ss
 ,p_nra_exempt_from_medicare_o    =>pqp_det_shd.g_old_rec.nra_exempt_from_medicare
 ,p_student_exempt_from_ss_o      =>pqp_det_shd.g_old_rec.student_exempt_from_ss
 ,p_student_exempt_from_medi_o    =>pqp_det_shd.g_old_rec.student_exempt_from_medicare
 ,p_addl_withholding_flag_o       =>pqp_det_shd.g_old_rec.addl_withholding_flag
 ,p_constant_addl_tax_o           =>pqp_det_shd.g_old_rec.constant_addl_tax
 ,p_addl_withholding_amt_o        =>pqp_det_shd.g_old_rec.addl_withholding_amt
 ,p_addl_wthldng_amt_period_ty_o  =>pqp_det_shd.g_old_rec.addl_wthldng_amt_period_type
 ,p_personal_exemption_o          =>pqp_det_shd.g_old_rec.personal_exemption
 ,p_addl_exemption_allowed_o      =>pqp_det_shd.g_old_rec.addl_exemption_allowed
 ,p_treaty_ben_allowed_flag_o     =>pqp_det_shd.g_old_rec.treaty_ben_allowed_flag
 ,p_treaty_benefits_start_date_o  =>pqp_det_shd.g_old_rec.treaty_benefits_start_date
 ,p_object_version_number_o       =>pqp_det_shd.g_old_rec.object_version_number
 ,p_retro_loss_notif_sent_o       =>pqp_det_shd.g_old_rec.retro_loss_notification_sent
 ,p_current_analysis_o            =>pqp_det_shd.g_old_rec.current_analysis
 ,p_forecast_income_code_o        =>pqp_det_shd.g_old_rec.forecast_income_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_ANALYZED_ALIEN_DET'
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
Procedure convert_defs(p_rec in out nocopy pqp_det_shd.g_rec_type) is
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
  If (p_rec.analyzed_data_id = hr_api.g_number) then
    p_rec.analyzed_data_id :=
    pqp_det_shd.g_old_rec.analyzed_data_id;
  End If;
  If (p_rec.income_code = hr_api.g_varchar2) then
    p_rec.income_code :=
    pqp_det_shd.g_old_rec.income_code;
  End If;
  If (p_rec.withholding_rate = hr_api.g_number) then
    p_rec.withholding_rate :=
    pqp_det_shd.g_old_rec.withholding_rate;
  End If;
  If (p_rec.income_code_sub_type = hr_api.g_varchar2) then
    p_rec.income_code_sub_type :=
    pqp_det_shd.g_old_rec.income_code_sub_type;
  End If;
  If (p_rec.exemption_code = hr_api.g_varchar2) then
    p_rec.exemption_code :=
    pqp_det_shd.g_old_rec.exemption_code;
  End If;
  If (p_rec.maximum_benefit_amount = hr_api.g_number) then
    p_rec.maximum_benefit_amount :=
    pqp_det_shd.g_old_rec.maximum_benefit_amount;
  End If;
  If (p_rec.retro_lose_ben_amt_flag = hr_api.g_varchar2) then
    p_rec.retro_lose_ben_amt_flag :=
    pqp_det_shd.g_old_rec.retro_lose_ben_amt_flag;
  End If;
  If (p_rec.date_benefit_ends = hr_api.g_date) then
    p_rec.date_benefit_ends :=
    pqp_det_shd.g_old_rec.date_benefit_ends;
  End If;
  If (p_rec.retro_lose_ben_date_flag = hr_api.g_varchar2) then
    p_rec.retro_lose_ben_date_flag :=
    pqp_det_shd.g_old_rec.retro_lose_ben_date_flag;
  End If;
  If (p_rec.nra_exempt_from_ss = hr_api.g_varchar2) then
    p_rec.nra_exempt_from_ss :=
    pqp_det_shd.g_old_rec.nra_exempt_from_ss;
  End If;
  If (p_rec.nra_exempt_from_medicare = hr_api.g_varchar2) then
    p_rec.nra_exempt_from_medicare :=
    pqp_det_shd.g_old_rec.nra_exempt_from_medicare;
  End If;
  If (p_rec.student_exempt_from_ss = hr_api.g_varchar2) then
    p_rec.student_exempt_from_ss :=
    pqp_det_shd.g_old_rec.student_exempt_from_ss;
  End If;
  If (p_rec.student_exempt_from_medicare = hr_api.g_varchar2) then
    p_rec.student_exempt_from_medicare :=
    pqp_det_shd.g_old_rec.student_exempt_from_medicare;
  End If;
  If (p_rec.addl_withholding_flag = hr_api.g_varchar2) then
    p_rec.addl_withholding_flag :=
    pqp_det_shd.g_old_rec.addl_withholding_flag;
  End If;
  If (p_rec.constant_addl_tax = hr_api.g_number) then
    p_rec.constant_addl_tax :=
    pqp_det_shd.g_old_rec.constant_addl_tax;
  End If;
  If (p_rec.addl_withholding_amt = hr_api.g_number) then
    p_rec.addl_withholding_amt :=
    pqp_det_shd.g_old_rec.addl_withholding_amt;
  End If;
  If (p_rec.addl_wthldng_amt_period_type = hr_api.g_varchar2) then
    p_rec.addl_wthldng_amt_period_type :=
    pqp_det_shd.g_old_rec.addl_wthldng_amt_period_type;
  End If;
  If (p_rec.personal_exemption = hr_api.g_number) then
    p_rec.personal_exemption :=
    pqp_det_shd.g_old_rec.personal_exemption;
  End If;
  If (p_rec.addl_exemption_allowed = hr_api.g_number) then
    p_rec.addl_exemption_allowed :=
    pqp_det_shd.g_old_rec.addl_exemption_allowed;
  End If;
  If (p_rec.treaty_ben_allowed_flag = hr_api.g_varchar2) then
    p_rec.treaty_ben_allowed_flag :=
    pqp_det_shd.g_old_rec.treaty_ben_allowed_flag;
  End If;
  If (p_rec.treaty_benefits_start_date = hr_api.g_date) then
    p_rec.treaty_benefits_start_date :=
    pqp_det_shd.g_old_rec.treaty_benefits_start_date;
  End If;
  If (p_rec.retro_loss_notification_sent = hr_api.g_varchar2) then
    p_rec.retro_loss_notification_sent :=
    pqp_det_shd.g_old_rec.retro_loss_notification_sent;
  End If;
  If (p_rec.current_analysis = hr_api.g_varchar2) then
    p_rec.current_analysis :=
    pqp_det_shd.g_old_rec.current_analysis;
  End If;
  If (p_rec.forecast_income_code = hr_api.g_varchar2) then
    p_rec.forecast_income_code :=
    pqp_det_shd.g_old_rec.forecast_income_code;
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
  p_rec        in out nocopy pqp_det_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqp_det_shd.lck
	(
	p_rec.analyzed_data_details_id,
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
  pqp_det_bus.update_validate(p_rec
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
  p_analyzed_data_details_id     in number,
  p_analyzed_data_id             in number           default hr_api.g_number,
  p_income_code                  in varchar2         default hr_api.g_varchar2,
  p_withholding_rate             in number           default hr_api.g_number,
  p_income_code_sub_type         in varchar2         default hr_api.g_varchar2,
  p_exemption_code               in varchar2         default hr_api.g_varchar2,
  p_maximum_benefit_amount       in number           default hr_api.g_number,
  p_retro_lose_ben_amt_flag      in varchar2         default hr_api.g_varchar2,
  p_date_benefit_ends            in date             default hr_api.g_date,
  p_retro_lose_ben_date_flag     in varchar2         default hr_api.g_varchar2,
  p_nra_exempt_from_ss           in varchar2         default hr_api.g_varchar2,
  p_nra_exempt_from_medicare     in varchar2         default hr_api.g_varchar2,
  p_student_exempt_from_ss       in varchar2         default hr_api.g_varchar2,
  p_student_exempt_from_medi     in varchar2         default hr_api.g_varchar2,
  p_addl_withholding_flag        in varchar2         default hr_api.g_varchar2,
  p_constant_addl_tax            in number           default hr_api.g_number,
  p_addl_withholding_amt         in number           default hr_api.g_number,
  p_addl_wthldng_amt_period_type in varchar2         default hr_api.g_varchar2,
  p_personal_exemption           in number           default hr_api.g_number,
  p_addl_exemption_allowed       in number           default hr_api.g_number,
  p_treaty_ben_allowed_flag      in varchar2         default hr_api.g_varchar2,
  p_treaty_benefits_start_date   in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number ,
  p_retro_loss_notification_sent in varchar2         default hr_api.g_varchar2,
  p_current_analysis             in varchar2         default hr_api.g_varchar2,
  p_forecast_income_code         in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec	  pqp_det_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_det_shd.convert_args
  (
  p_analyzed_data_details_id,
  p_analyzed_data_id,
  p_income_code,
  p_withholding_rate,
  p_income_code_sub_type,
  p_exemption_code,
  p_maximum_benefit_amount,
  p_retro_lose_ben_amt_flag,
  p_date_benefit_ends,
  p_retro_lose_ben_date_flag,
  p_nra_exempt_from_ss,
  p_nra_exempt_from_medicare,
  p_student_exempt_from_ss,
  p_student_exempt_from_medi,
  p_addl_withholding_flag,
  p_constant_addl_tax,
  p_addl_withholding_amt,
  p_addl_wthldng_amt_period_type,
  p_personal_exemption,
  p_addl_exemption_allowed,
  p_treaty_ben_allowed_flag,
  p_treaty_benefits_start_date,
  p_object_version_number ,
  p_retro_loss_notification_sent,
  p_current_analysis,
  p_forecast_income_code
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
end pqp_det_upd;

/
