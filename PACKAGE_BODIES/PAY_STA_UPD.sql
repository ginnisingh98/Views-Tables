--------------------------------------------------------
--  DDL for Package Body PAY_STA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_STA_UPD" as
/* $Header: pystarhi.pkb 120.0.12000000.3 2007/05/23 00:34:32 ppanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_sta_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in      date,
       p_datetrack_mode        in      varchar2,
       p_validation_start_date in      date,
       p_validation_end_date   in      date) is
--
  l_proc      varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
        (p_base_table_name      => 'pay_us_emp_state_tax_rules_f',
         p_base_key_column      => 'emp_state_tax_rule_id',
         p_base_key_value      => p_rec.emp_state_tax_rule_id);
    --
    pay_sta_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the pay_us_emp_state_tax_rules_f Row
    --
    update  pay_us_emp_state_tax_rules_f
    set
        emp_state_tax_rule_id           = p_rec.emp_state_tax_rule_id,
    assignment_id                   = p_rec.assignment_id,
    state_code                      = p_rec.state_code,
    jurisdiction_code               = p_rec.jurisdiction_code,
    business_group_id               = p_rec.business_group_id,
    additional_wa_amount            = p_rec.additional_wa_amount,
    filing_status_code              = p_rec.filing_status_code,
    remainder_percent               = p_rec.remainder_percent,
    secondary_wa                    = p_rec.secondary_wa,
    sit_additional_tax              = p_rec.sit_additional_tax,
    sit_override_amount             = p_rec.sit_override_amount,
    sit_override_rate               = p_rec.sit_override_rate,
    withholding_allowances          = p_rec.withholding_allowances,
    excessive_wa_reject_date        = p_rec.excessive_wa_reject_date,
    sdi_exempt                      = p_rec.sdi_exempt,
    sit_exempt                      = p_rec.sit_exempt,
    sit_optional_calc_ind           = p_rec.sit_optional_calc_ind,
    state_non_resident_cert         = p_rec.state_non_resident_cert,
    sui_exempt                      = p_rec.sui_exempt,
    wc_exempt                       = p_rec.wc_exempt,
    wage_exempt                     = p_rec.wage_exempt,
    sui_wage_base_override_amount   = p_rec.sui_wage_base_override_amount,
    supp_tax_override_rate          = p_rec.supp_tax_override_rate,
    object_version_number           = p_rec.object_version_number,
    attribute_category              = p_rec.attribute_category,
    attribute1                      = p_rec.attribute1,
    attribute2                      = p_rec.attribute2,
    attribute3                      = p_rec.attribute3,
    attribute4                      = p_rec.attribute4,
    attribute5                      = p_rec.attribute5,
    attribute6                      = p_rec.attribute6,
    attribute7                      = p_rec.attribute7,
    attribute8                      = p_rec.attribute8,
    attribute9                      = p_rec.attribute9,
    attribute10                     = p_rec.attribute10,
    attribute11                     = p_rec.attribute11,
    attribute12                     = p_rec.attribute12,
    attribute13                     = p_rec.attribute13,
    attribute14                     = p_rec.attribute14,
    attribute15                     = p_rec.attribute15,
    attribute16                     = p_rec.attribute16,
    attribute17                     = p_rec.attribute17,
    attribute18                     = p_rec.attribute18,
    attribute19                     = p_rec.attribute19,
    attribute20                     = p_rec.attribute20,
    attribute21                     = p_rec.attribute21,
    attribute22                     = p_rec.attribute22,
    attribute23                     = p_rec.attribute23,
    attribute24                     = p_rec.attribute24,
    attribute25                     = p_rec.attribute25,
    attribute26                     = p_rec.attribute26,
    attribute27                     = p_rec.attribute27,
    attribute28                     = p_rec.attribute28,
    attribute29                     = p_rec.attribute29,
    attribute30                     = p_rec.attribute30,
    sta_information_category        = p_rec.sta_information_category,
    sta_information1                      = p_rec.sta_information1,
    sta_information2                      = p_rec.sta_information2,
    sta_information3                      = p_rec.sta_information3,
    sta_information4                      = p_rec.sta_information4,
    sta_information5                      = p_rec.sta_information5,
    sta_information6                      = p_rec.sta_information6,
    sta_information7                      = p_rec.sta_information7,
    sta_information8                      = p_rec.sta_information8,
    sta_information9                      = p_rec.sta_information9,
    sta_information10                     = p_rec.sta_information10,
    sta_information11                     = p_rec.sta_information11,
    sta_information12                     = p_rec.sta_information12,
    sta_information13                     = p_rec.sta_information13,
    sta_information14                     = p_rec.sta_information14,
    sta_information15                     = p_rec.sta_information15,
    sta_information16                     = p_rec.sta_information16,
    sta_information17                     = p_rec.sta_information17,
    sta_information18                     = p_rec.sta_information18,
    sta_information19                     = p_rec.sta_information19,
    sta_information20                     = p_rec.sta_information20,
    sta_information21                     = p_rec.sta_information21,
    sta_information22                     = p_rec.sta_information22,
    sta_information23                     = p_rec.sta_information23,
    sta_information24                     = p_rec.sta_information24,
    sta_information25                     = p_rec.sta_information25,
    sta_information26                     = p_rec.sta_information26,
    sta_information27                     = p_rec.sta_information27,
    sta_information28                     = p_rec.sta_information28,
    sta_information29                     = p_rec.sta_information29,
    sta_information30                     = p_rec.sta_information30
    where   emp_state_tax_rule_id = p_rec.emp_state_tax_rule_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    pay_sta_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_sta_shd.g_api_dml := false;   -- Unset the api dml status
    pay_sta_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_sta_shd.g_api_dml := false;   -- Unset the api dml status
    pay_sta_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_sta_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in      	     date,
       p_datetrack_mode        in      	     varchar2,
       p_validation_start_date in      	     date,
       p_validation_end_date   in      	     date) is
--
  l_proc      varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec                => p_rec,
            p_effective_date         => p_effective_date,
            p_datetrack_mode         => p_datetrack_mode,
            p_validation_start_date  => p_validation_start_date,
            p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--      the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in      date,
       p_datetrack_mode        in      varchar2,
       p_validation_start_date in      date,
       p_validation_end_date   in      date) is
--
  l_proc         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    pay_sta_shd.upd_effective_end_date
     (p_effective_date         => p_effective_date,
      p_base_key_value         => p_rec.emp_state_tax_rule_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      pay_sta_del.delete_dml
        (p_rec                 => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    pay_sta_ins.insert_dml
      (p_rec                  => p_rec,
       p_effective_date       => p_effective_date,
       p_datetrack_mode       => p_datetrack_mode,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date  => p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in      	     date,
       p_datetrack_mode        in      	     varchar2,
       p_validation_start_date in      	     date,
       p_validation_end_date   in      	     date) is
--
  l_proc      varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec                   => p_rec,
     p_effective_date        => p_effective_date,
     p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
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
Procedure post_update
      (p_rec                   in pay_sta_shd.g_rec_type,
       p_effective_date        in date,
       p_datetrack_mode        in varchar2,
       p_validation_start_date in date,
       p_validation_end_date   in date) is
--
  l_proc      varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
 /*    pay_sta_rku.after_update
      (
  p_emp_state_tax_rule_id      =>p_rec.emp_state_tax_rule_id
 ,p_effective_start_date       =>p_rec.effective_start_date
 ,p_effective_end_date         =>p_rec.effective_end_date
 ,p_additional_wa_amount       =>p_rec.additional_wa_amount
 ,p_filing_status_code         =>p_rec.filing_status_code
 ,p_remainder_percent          =>p_rec.remainder_percent
 ,p_secondary_wa               =>p_rec.secondary_wa
 ,p_sit_additional_tax         =>p_rec.sit_additional_tax
 ,p_sit_override_amount        =>p_rec.sit_override_amount
 ,p_sit_override_rate          =>p_rec.sit_override_rate
 ,p_withholding_allowances     =>p_rec.withholding_allowances
 ,p_excessive_wa_reject_date   =>p_rec.excessive_wa_reject_date
 ,p_sdi_exempt                 =>p_rec.sdi_exempt
 ,p_sit_exempt                 =>p_rec.sit_exempt
 ,p_sit_optional_calc_ind      =>p_rec.sit_optional_calc_ind
 ,p_state_non_resident_cert    =>p_rec.state_non_resident_cert
 ,p_sui_exempt                 =>p_rec.sui_exempt
 ,p_wc_exempt                  =>p_rec.wc_exempt
 ,p_wage_exempt                =>p_rec.wage_exempt
 ,p_sui_wage_base_override_amoun =>p_rec.sui_wage_base_override_amount
 ,p_supp_tax_override_rate     =>p_rec.supp_tax_override_rate
 ,p_object_version_number      =>p_rec.object_version_number
 ,p_effective_date             =>p_effective_date
 ,p_datetrack_mode             =>p_datetrack_mode
 ,p_validation_start_date      =>p_validation_start_date
 ,p_validation_end_date        =>p_validation_end_date
 ,p_effective_start_date_o     =>pay_sta_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o       =>pay_sta_shd.g_old_rec.effective_end_date
 ,p_assignment_id_o            =>pay_sta_shd.g_old_rec.assignment_id
 ,p_state_code_o               =>pay_sta_shd.g_old_rec.state_code
 ,p_jurisdiction_code_o        =>pay_sta_shd.g_old_rec.jurisdiction_code
 ,p_business_group_id_o        =>pay_sta_shd.g_old_rec.business_group_id
 ,p_additional_wa_amount_o     =>pay_sta_shd.g_old_rec.additional_wa_amount
 ,p_filing_status_code_o       =>pay_sta_shd.g_old_rec.filing_status_code
 ,p_remainder_percent_o        =>pay_sta_shd.g_old_rec.remainder_percent
 ,p_secondary_wa_o             =>pay_sta_shd.g_old_rec.secondary_wa
 ,p_sit_additional_tax_o       =>pay_sta_shd.g_old_rec.sit_additional_tax
 ,p_sit_override_amount_o      =>pay_sta_shd.g_old_rec.sit_override_amount
 ,p_sit_override_rate_o        =>pay_sta_shd.g_old_rec.sit_override_rate
 ,p_withholding_allowances_o   =>pay_sta_shd.g_old_rec.withholding_allowances
 ,p_excessive_wa_reject_date_o =>pay_sta_shd.g_old_rec.excessive_wa_reject_date
 ,p_sdi_exempt_o               =>pay_sta_shd.g_old_rec.sdi_exempt
 ,p_sit_exempt_o               =>pay_sta_shd.g_old_rec.sit_exempt
 ,p_sit_optional_calc_ind_o    =>pay_sta_shd.g_old_rec.sit_optional_calc_ind
 ,p_state_non_resident_cert_o  =>pay_sta_shd.g_old_rec.state_non_resident_cert
 ,p_sui_exempt_o               =>pay_sta_shd.g_old_rec.sui_exempt
 ,p_wc_exempt_o                =>pay_sta_shd.g_old_rec.wc_exempt
 ,p_wage_exempt_o              =>pay_sta_shd.g_old_rec.wage_exempt
 ,p_sui_wage_base_override_amo_o =>
                           pay_sta_shd.g_old_rec.sui_wage_base_override_amount
 ,p_supp_tax_override_rate_o   =>pay_sta_shd.g_old_rec.supp_tax_override_rate
 ,p_object_version_number_o    =>pay_sta_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_US_EMP_STATE_TAX_RULES_F
        ,p_hook_type   => 'AU');
      --
 */
    null;
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
Procedure convert_defs(p_rec in out nocopy pay_sta_shd.g_rec_type) is
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
    pay_sta_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.state_code = hr_api.g_varchar2) then
    p_rec.state_code :=
    pay_sta_shd.g_old_rec.state_code;
  End If;
  If (p_rec.jurisdiction_code = hr_api.g_varchar2) then
    p_rec.jurisdiction_code :=
    pay_sta_shd.g_old_rec.jurisdiction_code;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_sta_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.additional_wa_amount = hr_api.g_number) then
    p_rec.additional_wa_amount :=
    pay_sta_shd.g_old_rec.additional_wa_amount;
  End If;
  If (p_rec.filing_status_code = hr_api.g_varchar2) then
    p_rec.filing_status_code :=
    pay_sta_shd.g_old_rec.filing_status_code;
  End If;
  If (p_rec.remainder_percent = hr_api.g_number) then
    p_rec.remainder_percent :=
    pay_sta_shd.g_old_rec.remainder_percent;
  End If;
  If (p_rec.secondary_wa = hr_api.g_number) then
    p_rec.secondary_wa :=
    pay_sta_shd.g_old_rec.secondary_wa;
  End If;
  If (p_rec.sit_additional_tax = hr_api.g_number) then
    p_rec.sit_additional_tax :=
    pay_sta_shd.g_old_rec.sit_additional_tax;
  End If;
  If (p_rec.sit_override_amount = hr_api.g_number) then
    p_rec.sit_override_amount :=
    pay_sta_shd.g_old_rec.sit_override_amount;
  End If;
  If (p_rec.sit_override_rate = hr_api.g_number) then
    p_rec.sit_override_rate :=
    pay_sta_shd.g_old_rec.sit_override_rate;
  End If;
  If (p_rec.withholding_allowances = hr_api.g_number) then
    p_rec.withholding_allowances :=
    pay_sta_shd.g_old_rec.withholding_allowances;
  End If;
  If (p_rec.excessive_wa_reject_date = hr_api.g_date) then
    p_rec.excessive_wa_reject_date :=
    pay_sta_shd.g_old_rec.excessive_wa_reject_date;
  End If;
  If (p_rec.sdi_exempt = hr_api.g_varchar2) then
    p_rec.sdi_exempt :=
    pay_sta_shd.g_old_rec.sdi_exempt;
  End If;
  If (p_rec.sit_exempt = hr_api.g_varchar2) then
    p_rec.sit_exempt :=
    pay_sta_shd.g_old_rec.sit_exempt;
  End If;
  If (p_rec.sit_optional_calc_ind = hr_api.g_varchar2) then
    p_rec.sit_optional_calc_ind :=
    pay_sta_shd.g_old_rec.sit_optional_calc_ind;
  End If;
  If (p_rec.state_non_resident_cert = hr_api.g_varchar2) then
    p_rec.state_non_resident_cert :=
    pay_sta_shd.g_old_rec.state_non_resident_cert;
  End If;
  If (p_rec.sui_exempt = hr_api.g_varchar2) then
    p_rec.sui_exempt :=
    pay_sta_shd.g_old_rec.sui_exempt;
  End If;
  If (p_rec.wc_exempt = hr_api.g_varchar2) then
    p_rec.wc_exempt :=
    pay_sta_shd.g_old_rec.wc_exempt;
  End If;
  If (p_rec.wage_exempt = hr_api.g_varchar2) then
    p_rec.wage_exempt :=
    pay_sta_shd.g_old_rec.wage_exempt;
  End If;
  If (p_rec.sui_wage_base_override_amount = hr_api.g_number) then
    p_rec.sui_wage_base_override_amount :=
    pay_sta_shd.g_old_rec.sui_wage_base_override_amount;
  End If;
  If (p_rec.supp_tax_override_rate = hr_api.g_number) then
    p_rec.supp_tax_override_rate :=
    pay_sta_shd.g_old_rec.supp_tax_override_rate;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pay_sta_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pay_sta_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pay_sta_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pay_sta_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pay_sta_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pay_sta_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pay_sta_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pay_sta_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pay_sta_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pay_sta_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pay_sta_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pay_sta_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pay_sta_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pay_sta_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pay_sta_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pay_sta_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pay_sta_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pay_sta_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pay_sta_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pay_sta_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pay_sta_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    pay_sta_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    pay_sta_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    pay_sta_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    pay_sta_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    pay_sta_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    pay_sta_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    pay_sta_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    pay_sta_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    pay_sta_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    pay_sta_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.sta_information_category = hr_api.g_varchar2) then
    p_rec.sta_information_category :=
    pay_sta_shd.g_old_rec.sta_information_category;
  End If;
  If (p_rec.sta_information1 = hr_api.g_varchar2) then
    p_rec.sta_information1 :=
    pay_sta_shd.g_old_rec.sta_information1;
  End If;
  If (p_rec.sta_information2 = hr_api.g_varchar2) then
    p_rec.sta_information2 :=
    pay_sta_shd.g_old_rec.sta_information2;
  End If;
  If (p_rec.sta_information3 = hr_api.g_varchar2) then
    p_rec.sta_information3 :=
    pay_sta_shd.g_old_rec.sta_information3;
  End If;
  If (p_rec.sta_information4 = hr_api.g_varchar2) then
    p_rec.sta_information4 :=
    pay_sta_shd.g_old_rec.sta_information4;
  End If;
  If (p_rec.sta_information5 = hr_api.g_varchar2) then
    p_rec.sta_information5 :=
    pay_sta_shd.g_old_rec.sta_information5;
  End If;
  If (p_rec.sta_information6 = hr_api.g_varchar2) then
    p_rec.sta_information6 :=
    pay_sta_shd.g_old_rec.sta_information6;
  End If;
  If (p_rec.sta_information7 = hr_api.g_varchar2) then
    p_rec.sta_information7 :=
    pay_sta_shd.g_old_rec.sta_information7;
  End If;
  If (p_rec.sta_information8 = hr_api.g_varchar2) then
    p_rec.sta_information8 :=
    pay_sta_shd.g_old_rec.sta_information8;
  End If;
  If (p_rec.sta_information9 = hr_api.g_varchar2) then
    p_rec.sta_information9 :=
    pay_sta_shd.g_old_rec.sta_information9;
  End If;
  If (p_rec.sta_information10 = hr_api.g_varchar2) then
    p_rec.sta_information10 :=
    pay_sta_shd.g_old_rec.sta_information10;
  End If;
  If (p_rec.sta_information11 = hr_api.g_varchar2) then
    p_rec.sta_information11 :=
    pay_sta_shd.g_old_rec.sta_information11;
  End If;
  If (p_rec.sta_information12 = hr_api.g_varchar2) then
    p_rec.sta_information12 :=
    pay_sta_shd.g_old_rec.sta_information12;
  End If;
  If (p_rec.sta_information13 = hr_api.g_varchar2) then
    p_rec.sta_information13 :=
    pay_sta_shd.g_old_rec.sta_information13;
  End If;
  If (p_rec.sta_information14 = hr_api.g_varchar2) then
    p_rec.sta_information14 :=
    pay_sta_shd.g_old_rec.sta_information14;
  End If;
  If (p_rec.sta_information15 = hr_api.g_varchar2) then
    p_rec.sta_information15 :=
    pay_sta_shd.g_old_rec.sta_information15;
  End If;
  If (p_rec.sta_information16 = hr_api.g_varchar2) then
    p_rec.sta_information16 :=
    pay_sta_shd.g_old_rec.sta_information16;
  End If;
  If (p_rec.sta_information17 = hr_api.g_varchar2) then
    p_rec.sta_information17 :=
    pay_sta_shd.g_old_rec.sta_information17;
  End If;
  If (p_rec.sta_information18 = hr_api.g_varchar2) then
    p_rec.sta_information18 :=
    pay_sta_shd.g_old_rec.sta_information18;
  End If;
  If (p_rec.sta_information19 = hr_api.g_varchar2) then
    p_rec.sta_information19 :=
    pay_sta_shd.g_old_rec.sta_information19;
  End If;
  If (p_rec.sta_information20 = hr_api.g_varchar2) then
    p_rec.sta_information20 :=
    pay_sta_shd.g_old_rec.sta_information20;
  End If;
  If (p_rec.sta_information21 = hr_api.g_varchar2) then
    p_rec.sta_information21 :=
    pay_sta_shd.g_old_rec.sta_information21;
  End If;
  If (p_rec.sta_information22 = hr_api.g_varchar2) then
    p_rec.sta_information22 :=
    pay_sta_shd.g_old_rec.sta_information22;
  End If;
  If (p_rec.sta_information23 = hr_api.g_varchar2) then
    p_rec.sta_information23 :=
    pay_sta_shd.g_old_rec.sta_information23;
  End If;
  If (p_rec.sta_information24 = hr_api.g_varchar2) then
    p_rec.sta_information24 :=
    pay_sta_shd.g_old_rec.sta_information24;
  End If;
  If (p_rec.sta_information25 = hr_api.g_varchar2) then
    p_rec.sta_information25 :=
    pay_sta_shd.g_old_rec.sta_information25;
  End If;
  If (p_rec.sta_information26 = hr_api.g_varchar2) then
    p_rec.sta_information26 :=
    pay_sta_shd.g_old_rec.sta_information26;
  End If;
  If (p_rec.sta_information27 = hr_api.g_varchar2) then
    p_rec.sta_information27 :=
    pay_sta_shd.g_old_rec.sta_information27;
  End If;
  If (p_rec.sta_information28 = hr_api.g_varchar2) then
    p_rec.sta_information28 :=
    pay_sta_shd.g_old_rec.sta_information28;
  End If;
  If (p_rec.sta_information29 = hr_api.g_varchar2) then
    p_rec.sta_information29 :=
    pay_sta_shd.g_old_rec.sta_information29;
  End If;
  If (p_rec.sta_information30 = hr_api.g_varchar2) then
    p_rec.sta_information30 :=
    pay_sta_shd.g_old_rec.sta_information30;
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
  p_rec                  in out nocopy	pay_sta_shd.g_rec_type,
  p_effective_date       in       	date,
  p_datetrack_mode       in       	varchar2
  ) is
--
  l_proc                  varchar2(72) := g_package||'upd';
  l_validation_start_date      date;
  l_validation_end_date        date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  pay_sta_shd.lck
      (p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_emp_state_tax_rule_id => p_rec.emp_state_tax_rule_id,
       p_object_version_number => p_rec.object_version_number,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pay_sta_bus.update_validate
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_emp_state_tax_rule_id        in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_additional_wa_amount         in number           default hr_api.g_number,
  p_filing_status_code           in varchar2         default hr_api.g_varchar2,
  p_remainder_percent            in number           default hr_api.g_number,
  p_secondary_wa                 in number           default hr_api.g_number,
  p_sit_additional_tax           in number           default hr_api.g_number,
  p_sit_override_amount          in number           default hr_api.g_number,
  p_sit_override_rate            in number           default hr_api.g_number,
  p_withholding_allowances       in number           default hr_api.g_number,
  p_excessive_wa_reject_date     in date             default hr_api.g_date,
  p_sdi_exempt                   in varchar2         default hr_api.g_varchar2,
  p_sit_exempt                   in varchar2         default hr_api.g_varchar2,
  p_sit_optional_calc_ind        in varchar2         default hr_api.g_varchar2,
  p_state_non_resident_cert      in varchar2         default hr_api.g_varchar2,
  p_sui_exempt                   in varchar2         default hr_api.g_varchar2,
  p_wc_exempt                    in varchar2         default hr_api.g_varchar2,
  p_wage_exempt                  in varchar2         default hr_api.g_varchar2,
  p_sui_wage_base_override_amoun in number           default hr_api.g_number,
  p_supp_tax_override_rate       in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_effective_date             in date,
  p_datetrack_mode             in varchar2,
  p_attribute_category          in varchar2         default hr_api.g_varchar2,
  p_attribute1                  in varchar2         default hr_api.g_varchar2,
  p_attribute2                  in varchar2         default hr_api.g_varchar2,
  p_attribute3                  in varchar2         default hr_api.g_varchar2,
  p_attribute4                  in varchar2         default hr_api.g_varchar2,
  p_attribute5                  in varchar2         default hr_api.g_varchar2,
  p_attribute6                  in varchar2         default hr_api.g_varchar2,
  p_attribute7                  in varchar2         default hr_api.g_varchar2,
  p_attribute8                  in varchar2         default hr_api.g_varchar2,
  p_attribute9                  in varchar2         default hr_api.g_varchar2,
  p_attribute10                 in varchar2         default hr_api.g_varchar2,
  p_attribute11                 in varchar2         default hr_api.g_varchar2,
  p_attribute12                 in varchar2         default hr_api.g_varchar2,
  p_attribute13                 in varchar2         default hr_api.g_varchar2,
  p_attribute14                 in varchar2         default hr_api.g_varchar2,
  p_attribute15                 in varchar2         default hr_api.g_varchar2,
  p_attribute16                 in varchar2         default hr_api.g_varchar2,
  p_attribute17                 in varchar2         default hr_api.g_varchar2,
  p_attribute18                 in varchar2         default hr_api.g_varchar2,
  p_attribute19                 in varchar2         default hr_api.g_varchar2,
  p_attribute20                 in varchar2         default hr_api.g_varchar2,
  p_attribute21                 in varchar2         default hr_api.g_varchar2,
  p_attribute22                 in varchar2         default hr_api.g_varchar2,
  p_attribute23                 in varchar2         default hr_api.g_varchar2,
  p_attribute24                 in varchar2         default hr_api.g_varchar2,
  p_attribute25                 in varchar2         default hr_api.g_varchar2,
  p_attribute26                 in varchar2         default hr_api.g_varchar2,
  p_attribute27                 in varchar2         default hr_api.g_varchar2,
  p_attribute28                 in varchar2         default hr_api.g_varchar2,
  p_attribute29                 in varchar2         default hr_api.g_varchar2,
  p_attribute30                 in varchar2         default hr_api.g_varchar2,
  p_sta_information_category    in varchar2         default hr_api.g_varchar2,
  p_sta_information1            in varchar2         default hr_api.g_varchar2,
  p_sta_information2            in varchar2         default hr_api.g_varchar2,
  p_sta_information3            in varchar2         default hr_api.g_varchar2,
  p_sta_information4            in varchar2         default hr_api.g_varchar2,
  p_sta_information5            in varchar2         default hr_api.g_varchar2,
  p_sta_information6            in varchar2         default hr_api.g_varchar2,
  p_sta_information7            in varchar2         default hr_api.g_varchar2,
  p_sta_information8            in varchar2         default hr_api.g_varchar2,
  p_sta_information9            in varchar2         default hr_api.g_varchar2,
  p_sta_information10           in varchar2         default hr_api.g_varchar2,
  p_sta_information11           in varchar2         default hr_api.g_varchar2,
  p_sta_information12           in varchar2         default hr_api.g_varchar2,
  p_sta_information13           in varchar2         default hr_api.g_varchar2,
  p_sta_information14           in varchar2         default hr_api.g_varchar2,
  p_sta_information15           in varchar2         default hr_api.g_varchar2,
  p_sta_information16           in varchar2         default hr_api.g_varchar2,
  p_sta_information17           in varchar2         default hr_api.g_varchar2,
  p_sta_information18           in varchar2         default hr_api.g_varchar2,
  p_sta_information19           in varchar2         default hr_api.g_varchar2,
  p_sta_information20           in varchar2         default hr_api.g_varchar2,
  p_sta_information21           in varchar2         default hr_api.g_varchar2,
  p_sta_information22           in varchar2         default hr_api.g_varchar2,
  p_sta_information23           in varchar2         default hr_api.g_varchar2,
  p_sta_information24           in varchar2         default hr_api.g_varchar2,
  p_sta_information25           in varchar2         default hr_api.g_varchar2,
  p_sta_information26           in varchar2         default hr_api.g_varchar2,
  p_sta_information27           in varchar2         default hr_api.g_varchar2,
  p_sta_information28           in varchar2         default hr_api.g_varchar2,
  p_sta_information29           in varchar2         default hr_api.g_varchar2,
  p_sta_information30           in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec            pay_sta_shd.g_rec_type;
  l_proc      varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_sta_shd.convert_args
  (
  p_emp_state_tax_rule_id,
  null,
  null,
  hr_api.g_number,
  hr_api.g_varchar2,
  hr_api.g_varchar2,
  hr_api.g_number,
  p_additional_wa_amount,
  p_filing_status_code,
  p_remainder_percent,
  p_secondary_wa,
  p_sit_additional_tax,
  p_sit_override_amount,
  p_sit_override_rate,
  p_withholding_allowances,
  p_excessive_wa_reject_date,
  p_sdi_exempt,
  p_sit_exempt,
  p_sit_optional_calc_ind,
  p_state_non_resident_cert,
  p_sui_exempt,
  p_wc_exempt,
  p_wage_exempt,
  p_sui_wage_base_override_amoun,
  p_supp_tax_override_rate,
  p_object_version_number,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
  p_attribute21,
  p_attribute22,
  p_attribute23,
  p_attribute24,
  p_attribute25,
  p_attribute26,
  p_attribute27,
  p_attribute28,
  p_attribute29,
  p_attribute30,
  p_sta_information_category,
  p_sta_information1,
  p_sta_information2,
  p_sta_information3,
  p_sta_information4,
  p_sta_information5,
  p_sta_information6,
  p_sta_information7,
  p_sta_information8,
  p_sta_information9,
  p_sta_information10,
  p_sta_information11,
  p_sta_information12,
  p_sta_information13,
  p_sta_information14,
  p_sta_information15,
  p_sta_information16,
  p_sta_information17,
  p_sta_information18,
  p_sta_information19,
  p_sta_information20,
  p_sta_information21,
  p_sta_information22,
  p_sta_information23,
  p_sta_information24,
  p_sta_information25,
  p_sta_information26,
  p_sta_information27,
  p_sta_information28,
  p_sta_information29,
  p_sta_information30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_sta_upd;

/
