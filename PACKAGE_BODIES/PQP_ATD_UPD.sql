--------------------------------------------------------
--  DDL for Package Body PQP_ATD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ATD_UPD" as
/* $Header: pqatdrhi.pkb 115.10 2003/02/17 22:13:56 tmehra ship $ */

----------------------------------------------------------------------------
--|                     Private Global Definitions                           |
----------------------------------------------------------------------------

g_package  varchar2(33)        := '  pqp_atd_upd.';  -- Global package name

----------------------------------------------------------------------------
--|------------------------------< update_dml >------------------------------|
----------------------------------------------------------------------------
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
----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy pqp_atd_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'update_dml';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  pqp_atd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pqp_alien_transaction_data Row
  --
  update pqp_alien_transaction_data
  set
  alien_transaction_id              = p_rec.alien_transaction_id,
  person_id                         = p_rec.person_id,
  data_source_type                  = p_rec.data_source_type,
  tax_year                          = p_rec.tax_year,
  income_code                       = p_rec.income_code,
  withholding_rate                  = p_rec.withholding_rate,
  income_code_sub_type              = p_rec.income_code_sub_type,
  exemption_code                    = p_rec.exemption_code,
  maximum_benefit_amount            = p_rec.maximum_benefit_amount,
  retro_lose_ben_amt_flag           = p_rec.retro_lose_ben_amt_flag,
  date_benefit_ends                 = p_rec.date_benefit_ends,
  retro_lose_ben_date_flag          = p_rec.retro_lose_ben_date_flag,
  current_residency_status          = p_rec.current_residency_status,
  nra_to_ra_date                    = p_rec.nra_to_ra_date,
  target_departure_date             = p_rec.target_departure_date,
  tax_residence_country_code        = p_rec.tax_residence_country_code,
  treaty_info_update_date           = p_rec.treaty_info_update_date,
  nra_exempt_from_fica              = p_rec.nra_exempt_from_fica,
  student_exempt_from_fica          = p_rec.student_exempt_from_fica,
  addl_withholding_flag             = p_rec.addl_withholding_flag,
  addl_withholding_amt              = p_rec.addl_withholding_amt,
  addl_wthldng_amt_period_type      = p_rec.addl_wthldng_amt_period_type,
  personal_exemption                = p_rec.personal_exemption,
  addl_exemption_allowed            = p_rec.addl_exemption_allowed,
  number_of_days_in_usa             = p_rec.number_of_days_in_usa,
  wthldg_allow_eligible_flag        = p_rec.wthldg_allow_eligible_flag,
  treaty_ben_allowed_flag           = p_rec.treaty_ben_allowed_flag,
  treaty_benefits_start_date        = p_rec.treaty_benefits_start_date,
  ra_effective_date                 = p_rec.ra_effective_date,
  state_code                        = p_rec.state_code,
  state_honors_treaty_flag          = p_rec.state_honors_treaty_flag,
  ytd_payments                      = p_rec.ytd_payments,
  ytd_w2_payments                   = p_rec.ytd_w2_payments,
  ytd_w2_withholding                = p_rec.ytd_w2_withholding,
  ytd_withholding_allowance         = p_rec.ytd_withholding_allowance,
  ytd_treaty_payments               = p_rec.ytd_treaty_payments,
  ytd_treaty_withheld_amt           = p_rec.ytd_treaty_withheld_amt,
  record_source                     = p_rec.record_source,
  visa_type                         = p_rec.visa_type,
  j_sub_type                        = p_rec.j_sub_type,
  primary_activity                  = p_rec.primary_activity,
  non_us_country_code               = p_rec.non_us_country_code,
  citizenship_country_code          = p_rec.citizenship_country_code,
  constant_addl_tax                 = p_rec.constant_addl_tax,
  date_8233_signed                  = p_rec.date_8233_signed,
  date_w4_signed                    = p_rec.date_w4_signed,
  error_indicator                   = p_rec.error_indicator,
  prev_er_treaty_benefit_amt        = p_rec.prev_er_treaty_benefit_amt,
  error_text                        = p_rec.error_text,
  object_version_number             = p_rec.object_version_number,
  current_analysis                  = p_rec.current_analysis,
  forecast_income_code              = p_rec.forecast_income_code
  where alien_transaction_id = p_rec.alien_transaction_id;
  --
  pqp_atd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_atd_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_atd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_atd_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_atd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_atd_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_atd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_atd_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;

----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
----------------------------------------------------------------------------
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
----------------------------------------------------------------------------
Procedure pre_update(p_rec in pqp_atd_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'pre_update';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;

----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
----------------------------------------------------------------------------
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
----------------------------------------------------------------------------
Procedure post_update(
p_effective_date in date,p_rec in pqp_atd_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'post_update';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pqp_atd_rku.after_update
      (
  p_alien_transaction_id          =>p_rec.alien_transaction_id
 ,p_person_id                     =>p_rec.person_id
 ,p_data_source_type              =>p_rec.data_source_type
 ,p_tax_year                      =>p_rec.tax_year
 ,p_income_code                   =>p_rec.income_code
 ,p_withholding_rate              =>p_rec.withholding_rate
 ,p_income_code_sub_type          =>p_rec.income_code_sub_type
 ,p_exemption_code                =>p_rec.exemption_code
 ,p_maximum_benefit_amount        =>p_rec.maximum_benefit_amount
 ,p_retro_lose_ben_amt_flag       =>p_rec.retro_lose_ben_amt_flag
 ,p_date_benefit_ends             =>p_rec.date_benefit_ends
 ,p_retro_lose_ben_date_flag      =>p_rec.retro_lose_ben_date_flag
 ,p_current_residency_status      =>p_rec.current_residency_status
 ,p_nra_to_ra_date                =>p_rec.nra_to_ra_date
 ,p_target_departure_date         =>p_rec.target_departure_date
 ,p_tax_residence_country_code    =>p_rec.tax_residence_country_code
 ,p_treaty_info_update_date       =>p_rec.treaty_info_update_date
 ,p_nra_exempt_from_fica          =>p_rec.nra_exempt_from_fica
 ,p_student_exempt_from_fica      =>p_rec.student_exempt_from_fica
 ,p_addl_withholding_flag         =>p_rec.addl_withholding_flag
 ,p_addl_withholding_amt          =>p_rec.addl_withholding_amt
 ,p_addl_wthldng_amt_period_type  =>p_rec.addl_wthldng_amt_period_type
 ,p_personal_exemption            =>p_rec.personal_exemption
 ,p_addl_exemption_allowed        =>p_rec.addl_exemption_allowed
 ,p_number_of_days_in_usa         =>p_rec.number_of_days_in_usa
 ,p_wthldg_allow_eligible_flag    =>p_rec.wthldg_allow_eligible_flag
 ,p_treaty_ben_allowed_flag       =>p_rec.treaty_ben_allowed_flag
 ,p_treaty_benefits_start_date    =>p_rec.treaty_benefits_start_date
 ,p_ra_effective_date             =>p_rec.ra_effective_date
 ,p_state_code                    =>p_rec.state_code
 ,p_state_honors_treaty_flag      =>p_rec.state_honors_treaty_flag
 ,p_ytd_payments                  =>p_rec.ytd_payments
 ,p_ytd_w2_payments               =>p_rec.ytd_w2_payments
 ,p_ytd_w2_withholding            =>p_rec.ytd_w2_withholding
 ,p_ytd_withholding_allowance     =>p_rec.ytd_withholding_allowance
 ,p_ytd_treaty_payments           =>p_rec.ytd_treaty_payments
 ,p_ytd_treaty_withheld_amt       =>p_rec.ytd_treaty_withheld_amt
 ,p_record_source                 =>p_rec.record_source
 ,p_visa_type                     =>p_rec.visa_type
 ,p_j_sub_type                    =>p_rec.j_sub_type
 ,p_primary_activity              =>p_rec.primary_activity
 ,p_non_us_country_code           =>p_rec.non_us_country_code
 ,p_citizenship_country_code      =>p_rec.citizenship_country_code
 ,p_constant_addl_tax             =>p_rec.constant_addl_tax
 ,p_date_8233_signed              =>p_rec.date_8233_signed
 ,p_date_w4_signed                =>p_rec.date_w4_signed
 ,p_error_indicator               =>p_rec.error_indicator
 ,p_prev_er_treaty_benefit_amt    =>p_rec.prev_er_treaty_benefit_amt
 ,p_error_text                    =>p_rec.error_text
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_current_analysis              =>p_rec.current_analysis
 ,p_forecast_income_code          =>p_rec.forecast_income_code
 ,p_person_id_o                   =>pqp_atd_shd.g_old_rec.person_id
 ,p_data_source_type_o            =>pqp_atd_shd.g_old_rec.data_source_type
 ,p_tax_year_o                    =>pqp_atd_shd.g_old_rec.tax_year
 ,p_income_code_o                 =>pqp_atd_shd.g_old_rec.income_code
 ,p_withholding_rate_o            =>pqp_atd_shd.g_old_rec.withholding_rate
 ,p_income_code_sub_type_o        =>pqp_atd_shd.g_old_rec.income_code_sub_type
 ,p_exemption_code_o              =>pqp_atd_shd.g_old_rec.exemption_code
 ,p_maximum_benefit_amount_o      =>pqp_atd_shd.g_old_rec.maximum_benefit_amount
 ,p_retro_lose_ben_amt_flag_o     =>pqp_atd_shd.g_old_rec.retro_lose_ben_amt_flag
 ,p_date_benefit_ends_o           =>pqp_atd_shd.g_old_rec.date_benefit_ends
 ,p_retro_lose_ben_date_flag_o    =>pqp_atd_shd.g_old_rec.retro_lose_ben_date_flag
 ,p_current_residency_status_o    =>pqp_atd_shd.g_old_rec.current_residency_status
 ,p_nra_to_ra_date_o              =>pqp_atd_shd.g_old_rec.nra_to_ra_date
 ,p_target_departure_date_o       =>pqp_atd_shd.g_old_rec.target_departure_date
 ,p_tax_residence_country_code_o  =>pqp_atd_shd.g_old_rec.tax_residence_country_code
 ,p_treaty_info_update_date_o     =>pqp_atd_shd.g_old_rec.treaty_info_update_date
 ,p_nra_exempt_from_fica_o        =>pqp_atd_shd.g_old_rec.nra_exempt_from_fica
 ,p_student_exempt_from_fica_o    =>pqp_atd_shd.g_old_rec.student_exempt_from_fica
 ,p_addl_withholding_flag_o       =>pqp_atd_shd.g_old_rec.addl_withholding_flag
 ,p_addl_withholding_amt_o        =>pqp_atd_shd.g_old_rec.addl_withholding_amt
 ,p_addl_wthldng_amt_period_ty_o=>pqp_atd_shd.g_old_rec.addl_wthldng_amt_period_type
 ,p_personal_exemption_o          =>pqp_atd_shd.g_old_rec.personal_exemption
 ,p_addl_exemption_allowed_o      =>pqp_atd_shd.g_old_rec.addl_exemption_allowed
 ,p_number_of_days_in_usa_o       =>pqp_atd_shd.g_old_rec.number_of_days_in_usa
 ,p_wthldg_allow_eligible_flag_o  =>pqp_atd_shd.g_old_rec.wthldg_allow_eligible_flag
 ,p_treaty_ben_allowed_flag_o     =>pqp_atd_shd.g_old_rec.treaty_ben_allowed_flag
 ,p_treaty_benefits_start_date_o  =>pqp_atd_shd.g_old_rec.treaty_benefits_start_date
 ,p_ra_effective_date_o           =>pqp_atd_shd.g_old_rec.ra_effective_date
 ,p_state_code_o                  =>pqp_atd_shd.g_old_rec.state_code
 ,p_state_honors_treaty_flag_o    =>pqp_atd_shd.g_old_rec.state_honors_treaty_flag
 ,p_ytd_payments_o                =>pqp_atd_shd.g_old_rec.ytd_payments
 ,p_ytd_w2_payments_o             =>pqp_atd_shd.g_old_rec.ytd_w2_payments
 ,p_ytd_w2_withholding_o          =>pqp_atd_shd.g_old_rec.ytd_w2_withholding
 ,p_ytd_withholding_allowance_o   =>pqp_atd_shd.g_old_rec.ytd_withholding_allowance
 ,p_ytd_treaty_payments_o         =>pqp_atd_shd.g_old_rec.ytd_treaty_payments
 ,p_ytd_treaty_withheld_amt_o     =>pqp_atd_shd.g_old_rec.ytd_treaty_withheld_amt
 ,p_record_source_o               =>pqp_atd_shd.g_old_rec.record_source
 ,p_visa_type_o                   =>pqp_atd_shd.g_old_rec.visa_type
 ,p_j_sub_type_o                  =>pqp_atd_shd.g_old_rec.j_sub_type
 ,p_primary_activity_o            =>pqp_atd_shd.g_old_rec.primary_activity
 ,p_non_us_country_code_o         =>pqp_atd_shd.g_old_rec.non_us_country_code
 ,p_citizenship_country_code_o    =>pqp_atd_shd.g_old_rec.citizenship_country_code
 ,p_constant_addl_tax_o           =>pqp_atd_shd.g_old_rec.constant_addl_tax
 ,p_date_8233_signed_o            =>pqp_atd_shd.g_old_rec.date_8233_signed
 ,p_date_w4_signed_o              =>pqp_atd_shd.g_old_rec.date_w4_signed
 ,p_error_indicator_o             =>pqp_atd_shd.g_old_rec.error_indicator
 ,p_prev_er_treaty_benefit_amt_o  =>pqp_atd_shd.g_old_rec.prev_er_treaty_benefit_amt
 ,p_error_text_o                  =>pqp_atd_shd.g_old_rec.error_text
 ,p_object_version_number_o       =>pqp_atd_shd.g_old_rec.object_version_number
 ,p_current_analysis_o            =>pqp_atd_shd.g_old_rec.current_analysis
 ,p_forecast_income_code_o        =>pqp_atd_shd.g_old_rec.forecast_income_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_ALIEN_TRANS_DATA'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;

----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
----------------------------------------------------------------------------
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
----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy pqp_atd_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'convert_defs';

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    pqp_atd_shd.g_old_rec.person_id;
  End If;
  If (p_rec.data_source_type = hr_api.g_varchar2) then
    p_rec.data_source_type :=
    pqp_atd_shd.g_old_rec.data_source_type;
  End If;
  If (p_rec.tax_year = hr_api.g_number) then
    p_rec.tax_year :=
    pqp_atd_shd.g_old_rec.tax_year;
  End If;
  If (p_rec.income_code = hr_api.g_varchar2) then
    p_rec.income_code :=
    pqp_atd_shd.g_old_rec.income_code;
  End If;
  If (p_rec.withholding_rate = hr_api.g_number) then
    p_rec.withholding_rate :=
    pqp_atd_shd.g_old_rec.withholding_rate;
  End If;
  If (p_rec.income_code_sub_type = hr_api.g_varchar2) then
    p_rec.income_code_sub_type :=
    pqp_atd_shd.g_old_rec.income_code_sub_type;
  End If;
  If (p_rec.exemption_code = hr_api.g_varchar2) then
    p_rec.exemption_code :=
    pqp_atd_shd.g_old_rec.exemption_code;
  End If;
  If (p_rec.maximum_benefit_amount = hr_api.g_number) then
    p_rec.maximum_benefit_amount :=
    pqp_atd_shd.g_old_rec.maximum_benefit_amount;
  End If;
  If (p_rec.retro_lose_ben_amt_flag = hr_api.g_varchar2) then
    p_rec.retro_lose_ben_amt_flag :=
    pqp_atd_shd.g_old_rec.retro_lose_ben_amt_flag;
  End If;
  If (p_rec.date_benefit_ends = hr_api.g_date) then
    p_rec.date_benefit_ends :=
    pqp_atd_shd.g_old_rec.date_benefit_ends;
  End If;
  If (p_rec.retro_lose_ben_date_flag = hr_api.g_varchar2) then
    p_rec.retro_lose_ben_date_flag :=
    pqp_atd_shd.g_old_rec.retro_lose_ben_date_flag;
  End If;
  If (p_rec.current_residency_status = hr_api.g_varchar2) then
    p_rec.current_residency_status :=
    pqp_atd_shd.g_old_rec.current_residency_status;
  End If;
  If (p_rec.nra_to_ra_date = hr_api.g_date) then
    p_rec.nra_to_ra_date :=
    pqp_atd_shd.g_old_rec.nra_to_ra_date;
  End If;
  If (p_rec.target_departure_date = hr_api.g_date) then
    p_rec.target_departure_date :=
    pqp_atd_shd.g_old_rec.target_departure_date;
  End If;
  If (p_rec.tax_residence_country_code = hr_api.g_varchar2) then
    p_rec.tax_residence_country_code :=
    pqp_atd_shd.g_old_rec.tax_residence_country_code;
  End If;
  If (p_rec.treaty_info_update_date = hr_api.g_date) then
    p_rec.treaty_info_update_date :=
    pqp_atd_shd.g_old_rec.treaty_info_update_date;
  End If;
  If (p_rec.nra_exempt_from_fica = hr_api.g_varchar2) then
    p_rec.nra_exempt_from_fica :=
    pqp_atd_shd.g_old_rec.nra_exempt_from_fica;
  End If;
  If (p_rec.student_exempt_from_fica = hr_api.g_varchar2) then
    p_rec.student_exempt_from_fica :=
    pqp_atd_shd.g_old_rec.student_exempt_from_fica;
  End If;
  If (p_rec.addl_withholding_flag = hr_api.g_varchar2) then
    p_rec.addl_withholding_flag :=
    pqp_atd_shd.g_old_rec.addl_withholding_flag;
  End If;
  If (p_rec.addl_withholding_amt = hr_api.g_number) then
    p_rec.addl_withholding_amt :=
    pqp_atd_shd.g_old_rec.addl_withholding_amt;
  End If;
  If (p_rec.addl_wthldng_amt_period_type = hr_api.g_varchar2) then
    p_rec.addl_wthldng_amt_period_type :=
    pqp_atd_shd.g_old_rec.addl_wthldng_amt_period_type;
  End If;
  If (p_rec.personal_exemption = hr_api.g_number) then
    p_rec.personal_exemption :=
    pqp_atd_shd.g_old_rec.personal_exemption;
  End If;
  If (p_rec.addl_exemption_allowed = hr_api.g_number) then
    p_rec.addl_exemption_allowed :=
    pqp_atd_shd.g_old_rec.addl_exemption_allowed;
  End If;
  If (p_rec.number_of_days_in_usa = hr_api.g_number) then
    p_rec.number_of_days_in_usa :=
    pqp_atd_shd.g_old_rec.number_of_days_in_usa;
  End If;
  If (p_rec.wthldg_allow_eligible_flag = hr_api.g_varchar2) then
    p_rec.wthldg_allow_eligible_flag :=
    pqp_atd_shd.g_old_rec.wthldg_allow_eligible_flag;
  End If;
  If (p_rec.treaty_ben_allowed_flag = hr_api.g_varchar2) then
    p_rec.treaty_ben_allowed_flag :=
    pqp_atd_shd.g_old_rec.treaty_ben_allowed_flag;
  End If;
  If (p_rec.treaty_benefits_start_date = hr_api.g_date) then
    p_rec.treaty_benefits_start_date :=
    pqp_atd_shd.g_old_rec.treaty_benefits_start_date;
  End If;
  If (p_rec.ra_effective_date = hr_api.g_date) then
    p_rec.ra_effective_date :=
    pqp_atd_shd.g_old_rec.ra_effective_date;
  End If;
  If (p_rec.state_code = hr_api.g_varchar2) then
    p_rec.state_code :=
    pqp_atd_shd.g_old_rec.state_code;
  End If;
  If (p_rec.state_honors_treaty_flag = hr_api.g_varchar2) then
    p_rec.state_honors_treaty_flag :=
    pqp_atd_shd.g_old_rec.state_honors_treaty_flag;
  End If;
  If (p_rec.ytd_payments = hr_api.g_number) then
    p_rec.ytd_payments :=
    pqp_atd_shd.g_old_rec.ytd_payments;
  End If;
  If (p_rec.ytd_w2_payments = hr_api.g_number) then
    p_rec.ytd_w2_payments :=
    pqp_atd_shd.g_old_rec.ytd_w2_payments;
  End If;
  If (p_rec.ytd_w2_withholding = hr_api.g_number) then
    p_rec.ytd_w2_withholding :=
    pqp_atd_shd.g_old_rec.ytd_w2_withholding;
  End If;
  If (p_rec.ytd_withholding_allowance = hr_api.g_number) then
    p_rec.ytd_withholding_allowance :=
    pqp_atd_shd.g_old_rec.ytd_withholding_allowance;
  End If;
  If (p_rec.ytd_treaty_payments = hr_api.g_number) then
    p_rec.ytd_treaty_payments :=
    pqp_atd_shd.g_old_rec.ytd_treaty_payments;
  End If;
  If (p_rec.ytd_treaty_withheld_amt = hr_api.g_number) then
    p_rec.ytd_treaty_withheld_amt :=
    pqp_atd_shd.g_old_rec.ytd_treaty_withheld_amt;
  End If;
  If (p_rec.record_source = hr_api.g_varchar2) then
    p_rec.record_source :=
    pqp_atd_shd.g_old_rec.record_source;
  End If;
  If (p_rec.visa_type = hr_api.g_varchar2) then
    p_rec.visa_type :=
    pqp_atd_shd.g_old_rec.visa_type;
  End If;
  If (p_rec.j_sub_type = hr_api.g_varchar2) then
    p_rec.j_sub_type :=
    pqp_atd_shd.g_old_rec.j_sub_type;
  End If;
  If (p_rec.primary_activity = hr_api.g_varchar2) then
    p_rec.primary_activity :=
    pqp_atd_shd.g_old_rec.primary_activity;
  End If;
  If (p_rec.non_us_country_code = hr_api.g_varchar2) then
    p_rec.non_us_country_code :=
    pqp_atd_shd.g_old_rec.non_us_country_code;
  End If;
  If (p_rec.citizenship_country_code = hr_api.g_varchar2) then
    p_rec.citizenship_country_code :=
    pqp_atd_shd.g_old_rec.citizenship_country_code;
  End If;
  If (p_rec.constant_addl_tax = hr_api.g_number) then
    p_rec.constant_addl_tax :=
    pqp_atd_shd.g_old_rec.constant_addl_tax;
  End If;
  If (p_rec.date_8233_signed = hr_api.g_date) then
    p_rec.date_8233_signed :=
    pqp_atd_shd.g_old_rec.date_8233_signed;
  End If;
  If (p_rec.date_w4_signed = hr_api.g_date) then
    p_rec.date_w4_signed :=
    pqp_atd_shd.g_old_rec.date_w4_signed;
  End If;
  If (p_rec.error_indicator = hr_api.g_varchar2) then
    p_rec.error_indicator :=
    pqp_atd_shd.g_old_rec.error_indicator;
  End If;
  If (p_rec.prev_er_treaty_benefit_amt = hr_api.g_number) then
    p_rec.prev_er_treaty_benefit_amt :=
    pqp_atd_shd.g_old_rec.prev_er_treaty_benefit_amt;
  End If;
  If (p_rec.error_text = hr_api.g_varchar2) then
    p_rec.error_text :=
    pqp_atd_shd.g_old_rec.error_text;
  End If;
  If (p_rec.current_analysis= hr_api.g_varchar2) then
    p_rec.current_analysis :=
    pqp_atd_shd.g_old_rec.current_analysis;
  End If;
  If (p_rec.forecast_income_code = hr_api.g_varchar2) then
    p_rec.forecast_income_code :=
    pqp_atd_shd.g_old_rec.forecast_income_code;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

End convert_defs;

----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_rec        in out nocopy pqp_atd_shd.g_rec_type
  ) is

  l_proc  varchar2(72) := g_package||'upd';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqp_atd_shd.lck
        (
        p_rec.alien_transaction_id,
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
  pqp_atd_bus.update_validate(p_rec
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

----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_alien_transaction_id         in number,
  p_person_id                    in number           default hr_api.g_number ,
  p_data_source_type             in varchar2         default hr_api.g_varchar2,
  p_tax_year                     in number           default hr_api.g_number,
  p_income_code                  in varchar2         default hr_api.g_varchar2,
  p_withholding_rate             in number           default hr_api.g_number,
  p_income_code_sub_type         in varchar2         default hr_api.g_varchar2,
  p_exemption_code               in varchar2         default hr_api.g_varchar2,
  p_maximum_benefit_amount       in number           default hr_api.g_number,
  p_retro_lose_ben_amt_flag      in varchar2         default hr_api.g_varchar2,
  p_date_benefit_ends            in date             default hr_api.g_date,
  p_retro_lose_ben_date_flag     in varchar2         default hr_api.g_varchar2,
  p_current_residency_status     in varchar2         default hr_api.g_varchar2,
  p_nra_to_ra_date               in date             default hr_api.g_date,
  p_target_departure_date        in date             default hr_api.g_date,
  p_tax_residence_country_code   in varchar2         default hr_api.g_varchar2,
  p_treaty_info_update_date      in date             default hr_api.g_date,
  p_nra_exempt_from_fica         in varchar2         default hr_api.g_varchar2,
  p_student_exempt_from_fica     in varchar2         default hr_api.g_varchar2,
  p_addl_withholding_flag        in varchar2         default hr_api.g_varchar2,
  p_addl_withholding_amt         in number           default hr_api.g_number,
  p_addl_wthldng_amt_period_type in varchar2         default hr_api.g_varchar2,
  p_personal_exemption           in number           default hr_api.g_number,
  p_addl_exemption_allowed       in number           default hr_api.g_number,
  p_number_of_days_in_usa        in number           default hr_api.g_number,
  p_wthldg_allow_eligible_flag   in varchar2         default hr_api.g_varchar2,
  p_treaty_ben_allowed_flag      in varchar2         default hr_api.g_varchar2,
  p_treaty_benefits_start_date   in date             default hr_api.g_date,
  p_ra_effective_date            in date             default hr_api.g_date,
  p_state_code                   in varchar2         default hr_api.g_varchar2,
  p_state_honors_treaty_flag     in varchar2         default hr_api.g_varchar2,
  p_ytd_payments                 in number           default hr_api.g_number,
  p_ytd_w2_payments              in number           default hr_api.g_number,
  p_ytd_w2_withholding           in number           default hr_api.g_number,
  p_ytd_withholding_allowance    in number           default hr_api.g_number,
  p_ytd_treaty_payments          in number           default hr_api.g_number,
  p_ytd_treaty_withheld_amt      in number           default hr_api.g_number,
  p_record_source                in varchar2         default hr_api.g_varchar2,
  p_visa_type                    in varchar2         default hr_api.g_varchar2,
  p_j_sub_type                   in varchar2         default hr_api.g_varchar2,
  p_primary_activity             in varchar2         default hr_api.g_varchar2,
  p_non_us_country_code          in varchar2         default hr_api.g_varchar2,
  p_citizenship_country_code     in varchar2         default hr_api.g_varchar2,
  p_constant_addl_tax            in number           default hr_api.g_number,
  p_date_8233_signed             in date             default hr_api.g_date,
  p_date_w4_signed               in date             default hr_api.g_date,
  p_error_indicator              in varchar2         default hr_api.g_varchar2,
  p_prev_er_treaty_benefit_amt   in number           default hr_api.g_number,
  p_error_text                   in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_current_analysis             in varchar2         default hr_api.g_varchar2,
  p_forecast_income_code         in varchar2         default hr_api.g_varchar2
  ) is

  l_rec          pqp_atd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_atd_shd.convert_args
  (
  p_alien_transaction_id,
  p_person_id,
  p_data_source_type,
  p_tax_year,
  p_income_code,
  p_withholding_rate,
  p_income_code_sub_type,
  p_exemption_code,
  p_maximum_benefit_amount,
  p_retro_lose_ben_amt_flag,
  p_date_benefit_ends,
  p_retro_lose_ben_date_flag,
  p_current_residency_status,
  p_nra_to_ra_date,
  p_target_departure_date,
  p_tax_residence_country_code,
  p_treaty_info_update_date,
  p_nra_exempt_from_fica,
  p_student_exempt_from_fica,
  p_addl_withholding_flag,
  p_addl_withholding_amt,
  p_addl_wthldng_amt_period_type,
  p_personal_exemption,
  p_addl_exemption_allowed,
  p_number_of_days_in_usa,
  p_wthldg_allow_eligible_flag,
  p_treaty_ben_allowed_flag,
  p_treaty_benefits_start_date,
  p_ra_effective_date,
  p_state_code,
  p_state_honors_treaty_flag,
  p_ytd_payments,
  p_ytd_w2_payments,
  p_ytd_w2_withholding,
  p_ytd_withholding_allowance,
  p_ytd_treaty_payments,
  p_ytd_treaty_withheld_amt,
  p_record_source,
  p_visa_type,
  p_j_sub_type,
  p_primary_activity,
  p_non_us_country_code,
  p_citizenship_country_code,
  p_constant_addl_tax,
  p_date_8233_signed,
  p_date_w4_signed,
  p_error_indicator,
  p_prev_er_treaty_benefit_amt,
  p_error_text,
  p_object_version_number,
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

end pqp_atd_upd;

/
