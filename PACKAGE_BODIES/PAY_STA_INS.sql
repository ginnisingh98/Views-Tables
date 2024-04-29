--------------------------------------------------------
--  DDL for Package Body PAY_STA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_STA_INS" as
/* $Header: pystarhi.pkb 120.0.12000000.3 2007/05/23 00:34:32 ppanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_sta_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
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
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in            date,
       p_datetrack_mode        in            varchar2,
       p_validation_start_date in      	     date,
       p_validation_end_date   in            date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   pay_us_emp_state_tax_rules_f t
    where  t.emp_state_tax_rule_id       = p_rec.emp_state_tax_rule_id
    and    t.effective_start_date =
             pay_sta_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc            varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pay_us_emp_state_tax_rules_f.created_by%TYPE;
  l_creation_date       pay_us_emp_state_tax_rules_f.creation_date%TYPE;
  l_last_update_date    pay_us_emp_state_tax_rules_f.last_update_date%TYPE;
  l_last_updated_by     pay_us_emp_state_tax_rules_f.last_updated_by%TYPE;
  l_last_update_login   pay_us_emp_state_tax_rules_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pay_us_emp_state_tax_rules_f',
       p_base_key_column => 'emp_state_tax_rule_id',
       p_base_key_value  => p_rec.emp_state_tax_rule_id);
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> 'INSERT') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  pay_sta_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_us_emp_state_tax_rules_f
  --
  insert into pay_us_emp_state_tax_rules_f
  (   emp_state_tax_rule_id,
      effective_start_date,
      effective_end_date,
      assignment_id,
      state_code,
      jurisdiction_code,
      business_group_id,
      additional_wa_amount,
      filing_status_code,
      remainder_percent,
      secondary_wa,
      sit_additional_tax,
      sit_override_amount,
      sit_override_rate,
      withholding_allowances,
      excessive_wa_reject_date,
      sdi_exempt,
      sit_exempt,
      sit_optional_calc_ind,
      state_non_resident_cert,
      sui_exempt,
      wc_exempt,
      wage_exempt,
      sui_wage_base_override_amount,
      supp_tax_override_rate,
      object_version_number
      , created_by,
      creation_date,
      last_update_date,
      last_updated_by,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      attribute21,
      attribute22,
      attribute23,
      attribute24,
      attribute25,
      attribute26,
      attribute27,
      attribute28,
      attribute29,
      attribute30,
      sta_information_category,
      sta_information1,
      sta_information2,
      sta_information3,
      sta_information4,
      sta_information5,
      sta_information6,
      sta_information7,
      sta_information8,
      sta_information9,
      sta_information10,
      sta_information11,
      sta_information12,
      sta_information13,
      sta_information14,
      sta_information15,
      sta_information16,
      sta_information17,
      sta_information18,
      sta_information19,
      sta_information20,
      sta_information21,
      sta_information22,
      sta_information23,
      sta_information24,
      sta_information25,
      sta_information26,
      sta_information27,
      sta_information28,
      sta_information29,
      sta_information30
  )
  Values
  (   p_rec.emp_state_tax_rule_id,
      p_rec.effective_start_date,
      p_rec.effective_end_date,
      p_rec.assignment_id,
      p_rec.state_code,
      p_rec.jurisdiction_code,
      p_rec.business_group_id,
      p_rec.additional_wa_amount,
      p_rec.filing_status_code,
      p_rec.remainder_percent,
      p_rec.secondary_wa,
      p_rec.sit_additional_tax,
      p_rec.sit_override_amount,
      p_rec.sit_override_rate,
      p_rec.withholding_allowances,
      p_rec.excessive_wa_reject_date,
      p_rec.sdi_exempt,
      p_rec.sit_exempt,
      p_rec.sit_optional_calc_ind,
      p_rec.state_non_resident_cert,
      p_rec.sui_exempt,
      p_rec.wc_exempt,
      p_rec.wage_exempt,
      p_rec.sui_wage_base_override_amount,
      p_rec.supp_tax_override_rate,
      p_rec.object_version_number
      , l_created_by,
      l_creation_date,
      l_last_update_date,
      l_last_updated_by,
      l_last_update_login,
      p_rec.attribute_category,
      p_rec.attribute1,
      p_rec.attribute2,
      p_rec.attribute3,
      p_rec.attribute4,
      p_rec.attribute5,
      p_rec.attribute6,
      p_rec.attribute7,
      p_rec.attribute8,
      p_rec.attribute9,
      p_rec.attribute10,
      p_rec.attribute11,
      p_rec.attribute12,
      p_rec.attribute13,
      p_rec.attribute14,
      p_rec.attribute15,
      p_rec.attribute16,
      p_rec.attribute17,
      p_rec.attribute18,
      p_rec.attribute19,
      p_rec.attribute20,
      p_rec.attribute21,
      p_rec.attribute22,
      p_rec.attribute23,
      p_rec.attribute24,
      p_rec.attribute25,
      p_rec.attribute26,
      p_rec.attribute27,
      p_rec.attribute28,
      p_rec.attribute29,
      p_rec.attribute30,
      p_rec.sta_information_category,
      p_rec.sta_information1,
      p_rec.sta_information2,
      p_rec.sta_information3,
      p_rec.sta_information4,
      p_rec.sta_information5,
      p_rec.sta_information6,
      p_rec.sta_information7,
      p_rec.sta_information8,
      p_rec.sta_information9,
      p_rec.sta_information10,
      p_rec.sta_information11,
      p_rec.sta_information12,
      p_rec.sta_information13,
      p_rec.sta_information14,
      p_rec.sta_information15,
      p_rec.sta_information16,
      p_rec.sta_information17,
      p_rec.sta_information18,
      p_rec.sta_information19,
      p_rec.sta_information20,
      p_rec.sta_information21,
      p_rec.sta_information22,
      p_rec.sta_information23,
      p_rec.sta_information24,
      p_rec.sta_information25,
      p_rec.sta_information26,
      p_rec.sta_information27,
      p_rec.sta_information28,
      p_rec.sta_information29,
      p_rec.sta_information30
  );
  --
  pay_sta_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
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
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in      	     date,
       p_datetrack_mode        in      	     varchar2,
       p_validation_start_date in            date,
       p_validation_end_date   in            date) is
--
  l_proc      varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec               => p_rec,
            p_effective_date        => p_effective_date,
            p_datetrack_mode        => p_datetrack_mode,
            p_validation_start_date => p_validation_start_date,
            p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
      (p_rec                    in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date         in 	      date,
       p_datetrack_mode         in            varchar2,
       p_validation_start_date  in            date,
       p_validation_end_date    in            date) is
--
  l_proc      varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_us_emp_state_tax_rules_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.emp_state_tax_rule_id;
  Close C_Sel1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
      (p_rec                   in pay_sta_shd.g_rec_type,
       p_effective_date        in date,
       p_datetrack_mode        in varchar2,
       p_validation_start_date in date,
       p_validation_end_date   in date) is
--
  l_proc      varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
 /*    pay_sta_rki.after_insert
      (
  p_emp_state_tax_rule_id         =>p_rec.emp_state_tax_rule_id
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_assignment_id                 =>p_rec.assignment_id
 ,p_state_code                    =>p_rec.state_code
 ,p_jurisdiction_code             =>p_rec.jurisdiction_code
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_additional_wa_amount          =>p_rec.additional_wa_amount
 ,p_filing_status_code            =>p_rec.filing_status_code
 ,p_remainder_percent             =>p_rec.remainder_percent
 ,p_secondary_wa                  =>p_rec.secondary_wa
 ,p_sit_additional_tax            =>p_rec.sit_additional_tax
 ,p_sit_override_amount           =>p_rec.sit_override_amount
 ,p_sit_override_rate             =>p_rec.sit_override_rate
 ,p_withholding_allowances        =>p_rec.withholding_allowances
 ,p_excessive_wa_reject_date      =>p_rec.excessive_wa_reject_date
 ,p_sdi_exempt                    =>p_rec.sdi_exempt
 ,p_sit_exempt                    =>p_rec.sit_exempt
 ,p_sit_optional_calc_ind         =>p_rec.sit_optional_calc_ind
 ,p_state_non_resident_cert       =>p_rec.state_non_resident_cert
 ,p_sui_exempt                    =>p_rec.sui_exempt
 ,p_wc_exempt                     =>p_rec.wc_exempt
 ,p_wage_exempt                   =>p_rec.wage_exempt
 ,p_sui_wage_base_override_amoun  =>p_rec.sui_wage_base_override_amount
 ,p_supp_tax_override_rate        =>p_rec.supp_tax_override_rate
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_US_EMP_STATE_TAX_RULES_F
        ,p_hook_type   => 'AI');
      --
 */
    null;
    --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--   be manipulated.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
      (p_effective_date        in  date,
       p_datetrack_mode        in  varchar2,
       p_rec                   in  pay_sta_shd.g_rec_type,
       p_validation_start_date out nocopy date,
       p_validation_end_date   out nocopy date) is
--
  l_proc      varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date   date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
      (p_effective_date         => p_effective_date,
       p_datetrack_mode         => p_datetrack_mode,
       p_base_table_name         => 'pay_us_emp_state_tax_rules_f',
       p_base_key_column         => 'emp_state_tax_rule_id',
       p_base_key_value          => p_rec.emp_state_tax_rule_id,
       p_parent_table_name1      => 'per_assignments_f',
       p_parent_key_column1      => 'assignment_id',
       p_parent_key_value1       => p_rec.assignment_id,
       p_enforce_foreign_locking => true,
       p_validation_start_date   => l_validation_start_date,
       p_validation_end_date     => l_validation_end_date);
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec               in out nocopy pay_sta_shd.g_rec_type,
  p_effective_date in     date
  ) is
--
  l_proc                  varchar2(72) := g_package||'ins';
  l_datetrack_mode             varchar2(30) := 'INSERT';
  l_validation_start_date      date;
  l_validation_end_date        date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  ins_lck
      (p_effective_date        => p_effective_date,
       p_datetrack_mode        => l_datetrack_mode,
       p_rec                   => p_rec,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting insert validate operations
  --
  pay_sta_bus.insert_validate
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => l_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => l_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => l_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-insert operation
  --
  post_insert
      (p_rec                   => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => l_datetrack_mode,
       p_validation_start_date => l_validation_start_date,
       p_validation_end_date   => l_validation_end_date);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_emp_state_tax_rule_id        out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_assignment_id                in number,
  p_state_code                   in varchar2,
  p_jurisdiction_code            in varchar2,
  p_business_group_id            in number,
  p_additional_wa_amount         in number,
  p_filing_status_code           in varchar2,
  p_remainder_percent            in number,
  p_secondary_wa                 in number,
  p_sit_additional_tax           in number,
  p_sit_override_amount          in number,
  p_sit_override_rate            in number,
  p_withholding_allowances       in number,
  p_excessive_wa_reject_date     in date             default null,
  p_sdi_exempt                   in varchar2         default null,
  p_sit_exempt                   in varchar2         default null,
  p_sit_optional_calc_ind        in varchar2         default null,
  p_state_non_resident_cert      in varchar2         default null,
  p_sui_exempt                   in varchar2         default null,
  p_wc_exempt                    in varchar2         default null,
  p_wage_exempt                  in varchar2         default null,
  p_sui_wage_base_override_amoun in number           default null,
  p_supp_tax_override_rate       in number           default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date,
  p_attribute_category          in varchar2         default null,
  p_attribute1                  in varchar2         default null,
  p_attribute2                  in varchar2         default null,
  p_attribute3                  in varchar2         default null,
  p_attribute4                  in varchar2         default null,
  p_attribute5                  in varchar2         default null,
  p_attribute6                  in varchar2         default null,
  p_attribute7                  in varchar2         default null,
  p_attribute8                  in varchar2         default null,
  p_attribute9                  in varchar2         default null,
  p_attribute10                 in varchar2         default null,
  p_attribute11                 in varchar2         default null,
  p_attribute12                 in varchar2         default null,
  p_attribute13                 in varchar2         default null,
  p_attribute14                 in varchar2         default null,
  p_attribute15                 in varchar2         default null,
  p_attribute16                 in varchar2         default null,
  p_attribute17                 in varchar2         default null,
  p_attribute18                 in varchar2         default null,
  p_attribute19                 in varchar2         default null,
  p_attribute20                 in varchar2         default null,
  p_attribute21                 in varchar2         default null,
  p_attribute22                 in varchar2         default null,
  p_attribute23                 in varchar2         default null,
  p_attribute24                 in varchar2         default null,
  p_attribute25                 in varchar2         default null,
  p_attribute26                 in varchar2         default null,
  p_attribute27                 in varchar2         default null,
  p_attribute28                 in varchar2         default null,
  p_attribute29                 in varchar2         default null,
  p_attribute30                 in varchar2         default null,
  p_sta_information_category    in varchar2         default null,
  p_sta_information1            in varchar2         default null,
  p_sta_information2            in varchar2         default null,
  p_sta_information3            in varchar2         default null,
  p_sta_information4            in varchar2         default null,
  p_sta_information5            in varchar2         default null,
  p_sta_information6            in varchar2         default null,
  p_sta_information7            in varchar2         default null,
  p_sta_information8            in varchar2         default null,
  p_sta_information9            in varchar2         default null,
  p_sta_information10           in varchar2         default null,
  p_sta_information11           in varchar2         default null,
  p_sta_information12           in varchar2         default null,
  p_sta_information13           in varchar2         default null,
  p_sta_information14           in varchar2         default null,
  p_sta_information15           in varchar2         default null,
  p_sta_information16           in varchar2         default null,
  p_sta_information17           in varchar2         default null,
  p_sta_information18           in varchar2         default null,
  p_sta_information19           in varchar2         default null,
  p_sta_information20           in varchar2         default null,
  p_sta_information21           in varchar2         default null,
  p_sta_information22           in varchar2         default null,
  p_sta_information23           in varchar2         default null,
  p_sta_information24           in varchar2         default null,
  p_sta_information25           in varchar2         default null,
  p_sta_information26           in varchar2         default null,
  p_sta_information27           in varchar2         default null,
  p_sta_information28           in varchar2         default null,
  p_sta_information29           in varchar2         default null,
  p_sta_information30           in varchar2         default null
  ) is
--
  l_rec            pay_sta_shd.g_rec_type;
  l_proc      varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_sta_shd.convert_args
  (
  null,
  null,
  null,
  p_assignment_id,
  p_state_code,
  p_jurisdiction_code,
  p_business_group_id,
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
  null,
  p_attribute_category,
  p_attribute1 ,
  p_attribute2 ,
  p_attribute3 ,
  p_attribute4 ,
  p_attribute5 ,
  p_attribute6 ,
  p_attribute7 ,
  p_attribute8 ,
  p_attribute9 ,
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
  p_sta_information1 ,
  p_sta_information2 ,
  p_sta_information3 ,
  p_sta_information4 ,
  p_sta_information5 ,
  p_sta_information6 ,
  p_sta_information7 ,
  p_sta_information8 ,
  p_sta_information9 ,
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
  -- Having converted the arguments into the pay_sta_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_emp_state_tax_rule_id         := l_rec.emp_state_tax_rule_id;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  p_object_version_number       := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_sta_ins;

/
