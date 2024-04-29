--------------------------------------------------------
--  DDL for Package Body PAY_PPM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPM_UPD" as
/* $Header: pyppmrhi.pkb 120.3.12010000.5 2010/03/30 06:46:19 priupadh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ppm_upd.';  -- Global package name
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
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
	(p_rec 			 in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc varchar2(72) := g_package||'dt_update_dml';
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
	  (p_base_table_name	=> 'pay_personal_payment_methods_f',
	   p_base_key_column	=> 'personal_payment_method_id',
	   p_base_key_value	=> p_rec.personal_payment_method_id);
    --
    pay_ppm_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the pay_personal_payment_methods_f Row
    --
    update  pay_personal_payment_methods_f
    set
    external_account_id             = p_rec.external_account_id,
    assignment_id                   = p_rec.assignment_id,
    run_type_id                     = p_rec.run_type_id,
    amount                          = p_rec.amount,
    comment_id                      = p_rec.comment_id,
    percentage                      = p_rec.percentage,
    priority                        = p_rec.priority,
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
    object_version_number           = p_rec.object_version_number,
    payee_type                      = p_rec.payee_type,
    payee_id                        = p_rec.payee_id,
    ppm_information_category        = p_rec.ppm_information_category,
    ppm_information1                = p_rec.ppm_information1,
    ppm_information2                = p_rec.ppm_information2,
    ppm_information3                = p_rec.ppm_information3,
    ppm_information4                = p_rec.ppm_information4,
    ppm_information5                = p_rec.ppm_information5,
    ppm_information6                = p_rec.ppm_information6,
    ppm_information7                = p_rec.ppm_information7,
    ppm_information8                = p_rec.ppm_information8,
    ppm_information9                = p_rec.ppm_information9,
    ppm_information10               = p_rec.ppm_information10,
    ppm_information11               = p_rec.ppm_information11,
    ppm_information12               = p_rec.ppm_information12,
    ppm_information13               = p_rec.ppm_information13,
    ppm_information14               = p_rec.ppm_information14,
    ppm_information15               = p_rec.ppm_information15,
    ppm_information16               = p_rec.ppm_information16,
    ppm_information17               = p_rec.ppm_information17,
    ppm_information18               = p_rec.ppm_information18,
    ppm_information19               = p_rec.ppm_information19,
    ppm_information20               = p_rec.ppm_information20,
    ppm_information21               = p_rec.ppm_information21,
    ppm_information22               = p_rec.ppm_information22,
    ppm_information23               = p_rec.ppm_information23,
    ppm_information24               = p_rec.ppm_information24,
    ppm_information25               = p_rec.ppm_information25,
    ppm_information26               = p_rec.ppm_information26,
    ppm_information27               = p_rec.ppm_information27,
    ppm_information28               = p_rec.ppm_information28,
    ppm_information29               = p_rec.ppm_information29,
    ppm_information30               = p_rec.ppm_information30
    where   personal_payment_method_id = p_rec.personal_payment_method_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
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
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
    pay_ppm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
    pay_ppm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_ppm_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
	(p_rec 			 in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date 	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
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
--the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Pre Conditions:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
	(p_rec 			 in out	nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc                 varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    pay_ppm_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.personal_payment_method_id,
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
      pay_ppm_del.delete_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => p_validation_start_date,
	 p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    pay_ppm_ins.insert_dml
      (p_rec			=> p_rec,
       p_effective_date		=> p_effective_date,
       p_datetrack_mode		=> p_datetrack_mode,
       p_validation_start_date	=> p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date);
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
	(p_rec 			 in out	nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comments is not null and p_rec.comment_id is null) then
    hr_comm_api.ins(p_comment_id        => p_rec.comment_id,
                    p_source_table_name => 'PAY_PERSONAL_PAYMENT_METHODS_F',
                    p_comment_text      => p_rec.comments);
  -- Update the comments if they have changed
  ElsIf (p_rec.comment_id is not null and p_rec.comments <>
         pay_ppm_shd.g_old_rec.comments) then
    hr_comm_api.upd(p_comment_id        => p_rec.comment_id,
                    p_source_table_name => 'PAY_PERSONAL_PAYMENT_METHODS_F',
                    p_comment_text      => p_rec.comments);
  End If;
  --
  dt_pre_update
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
	(p_rec 			 in pay_ppm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  begin
    pay_ppm_rku.after_update
      (p_effective_date                 => p_effective_date
      ,p_datetrack_mode                 => p_datetrack_mode
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      ,p_personal_payment_method_id     => p_rec.personal_payment_method_id
      ,p_effective_start_date           => p_rec.effective_start_date
      ,p_effective_end_date             => p_rec.effective_end_date
      ,p_external_account_id            => p_rec.external_account_id
      ,p_amount                         => p_rec.amount
      ,p_comment_id                     => p_rec.comment_id
      ,p_comments                       => p_rec.comments
      ,p_percentage                     => p_rec.percentage
      ,p_priority                       => p_rec.priority
      ,p_attribute_category             => p_rec.attribute_category
      ,p_attribute1                     => p_rec.attribute1
      ,p_attribute2                     => p_rec.attribute2
      ,p_attribute3                     => p_rec.attribute3
      ,p_attribute4                     => p_rec.attribute4
      ,p_attribute5                     => p_rec.attribute5
      ,p_attribute6                     => p_rec.attribute6
      ,p_attribute7                     => p_rec.attribute7
      ,p_attribute8                     => p_rec.attribute8
      ,p_attribute9                     => p_rec.attribute9
      ,p_attribute10                    => p_rec.attribute10
      ,p_attribute11                    => p_rec.attribute11
      ,p_attribute12                    => p_rec.attribute12
      ,p_attribute13                    => p_rec.attribute13
      ,p_attribute14                    => p_rec.attribute14
      ,p_attribute15                    => p_rec.attribute15
      ,p_attribute16                    => p_rec.attribute16
      ,p_attribute17                    => p_rec.attribute17
      ,p_attribute18                    => p_rec.attribute18
      ,p_attribute19                    => p_rec.attribute19
      ,p_attribute20                    => p_rec.attribute20
      ,p_object_version_number          => p_rec.object_version_number
      ,p_payee_type                     => p_rec.payee_type
      ,p_payee_id                       => p_rec.payee_id
      ,p_ppm_information_category       => p_rec.ppm_information_category
      ,p_ppm_information1               => p_rec.ppm_information1
      ,p_ppm_information2               => p_rec.ppm_information2
      ,p_ppm_information3               => p_rec.ppm_information3
      ,p_ppm_information4               => p_rec.ppm_information4
      ,p_ppm_information5               => p_rec.ppm_information5
      ,p_ppm_information6               => p_rec.ppm_information6
      ,p_ppm_information7               => p_rec.ppm_information7
      ,p_ppm_information8               => p_rec.ppm_information8
      ,p_ppm_information9               => p_rec.ppm_information9
      ,p_ppm_information10              => p_rec.ppm_information10
      ,p_ppm_information11              => p_rec.ppm_information11
      ,p_ppm_information12              => p_rec.ppm_information12
      ,p_ppm_information13              => p_rec.ppm_information13
      ,p_ppm_information14              => p_rec.ppm_information14
      ,p_ppm_information15              => p_rec.ppm_information15
      ,p_ppm_information16              => p_rec.ppm_information16
      ,p_ppm_information17              => p_rec.ppm_information17
      ,p_ppm_information18              => p_rec.ppm_information18
      ,p_ppm_information19              => p_rec.ppm_information19
      ,p_ppm_information20              => p_rec.ppm_information20
      ,p_ppm_information21              => p_rec.ppm_information21
      ,p_ppm_information22              => p_rec.ppm_information22
      ,p_ppm_information23              => p_rec.ppm_information23
      ,p_ppm_information24              => p_rec.ppm_information24
      ,p_ppm_information25              => p_rec.ppm_information25
      ,p_ppm_information26              => p_rec.ppm_information26
      ,p_ppm_information27              => p_rec.ppm_information27
      ,p_ppm_information28              => p_rec.ppm_information28
      ,p_ppm_information29              => p_rec.ppm_information29
      ,p_ppm_information30              => p_rec.ppm_information30
      ,p_effective_start_date_o
          => pay_ppm_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
          => pay_ppm_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
          => pay_ppm_shd.g_old_rec.business_group_id
      ,p_external_account_id_o
          => pay_ppm_shd.g_old_rec.external_account_id
      ,p_assignment_id_o
          => pay_ppm_shd.g_old_rec.assignment_id
      ,p_org_payment_method_id_o
          => pay_ppm_shd.g_old_rec.org_payment_method_id
      ,p_amount_o
          => pay_ppm_shd.g_old_rec.amount
      ,p_comment_id_o
          => pay_ppm_shd.g_old_rec.comment_id
      ,p_percentage_o
          => pay_ppm_shd.g_old_rec.percentage
      ,p_priority_o
          => pay_ppm_shd.g_old_rec.priority
      ,p_attribute_category_o
          => pay_ppm_shd.g_old_rec.attribute_category
      ,p_attribute1_o
          => pay_ppm_shd.g_old_rec.attribute1
      ,p_attribute2_o
          => pay_ppm_shd.g_old_rec.attribute2
      ,p_attribute3_o
          => pay_ppm_shd.g_old_rec.attribute3
      ,p_attribute4_o
          => pay_ppm_shd.g_old_rec.attribute4
      ,p_attribute5_o
          => pay_ppm_shd.g_old_rec.attribute5
      ,p_attribute6_o
          => pay_ppm_shd.g_old_rec.attribute6
      ,p_attribute7_o
          => pay_ppm_shd.g_old_rec.attribute7
      ,p_attribute8_o
          => pay_ppm_shd.g_old_rec.attribute8
      ,p_attribute9_o
          => pay_ppm_shd.g_old_rec.attribute9
      ,p_attribute10_o
          => pay_ppm_shd.g_old_rec.attribute10
      ,p_attribute11_o
          => pay_ppm_shd.g_old_rec.attribute11
      ,p_attribute12_o
          => pay_ppm_shd.g_old_rec.attribute12
      ,p_attribute13_o
          => pay_ppm_shd.g_old_rec.attribute13
      ,p_attribute14_o
          => pay_ppm_shd.g_old_rec.attribute14
      ,p_attribute15_o
          => pay_ppm_shd.g_old_rec.attribute15
      ,p_attribute16_o
          => pay_ppm_shd.g_old_rec.attribute16
      ,p_attribute17_o
          => pay_ppm_shd.g_old_rec.attribute17
      ,p_attribute18_o
          => pay_ppm_shd.g_old_rec.attribute18
      ,p_attribute19_o
          => pay_ppm_shd.g_old_rec.attribute19
      ,p_attribute20_o
          => pay_ppm_shd.g_old_rec.attribute20
      ,p_object_version_number_o
          => pay_ppm_shd.g_old_rec.object_version_number
      ,p_payee_type_o
          => pay_ppm_shd.g_old_rec.payee_type
      ,p_payee_id_o
          => pay_ppm_shd.g_old_rec.payee_id
      ,p_ppm_information_category_o
          => pay_ppm_shd.g_old_rec.ppm_information_category
      ,p_ppm_information1_o
          => pay_ppm_shd.g_old_rec.ppm_information1
      ,p_ppm_information2_o
          => pay_ppm_shd.g_old_rec.ppm_information2
      ,p_ppm_information3_o
          => pay_ppm_shd.g_old_rec.ppm_information3
      ,p_ppm_information4_o
          => pay_ppm_shd.g_old_rec.ppm_information4
      ,p_ppm_information5_o
          => pay_ppm_shd.g_old_rec.ppm_information5
      ,p_ppm_information6_o
          => pay_ppm_shd.g_old_rec.ppm_information6
      ,p_ppm_information7_o
          => pay_ppm_shd.g_old_rec.ppm_information7
      ,p_ppm_information8_o
          => pay_ppm_shd.g_old_rec.ppm_information8
      ,p_ppm_information9_o
          => pay_ppm_shd.g_old_rec.ppm_information9
      ,p_ppm_information10_o
          => pay_ppm_shd.g_old_rec.ppm_information10
      ,p_ppm_information11_o
          => pay_ppm_shd.g_old_rec.ppm_information11
      ,p_ppm_information12_o
          => pay_ppm_shd.g_old_rec.ppm_information12
      ,p_ppm_information13_o
          => pay_ppm_shd.g_old_rec.ppm_information13
      ,p_ppm_information14_o
          => pay_ppm_shd.g_old_rec.ppm_information14
      ,p_ppm_information15_o
          => pay_ppm_shd.g_old_rec.ppm_information15
      ,p_ppm_information16_o
          => pay_ppm_shd.g_old_rec.ppm_information16
      ,p_ppm_information17_o
          => pay_ppm_shd.g_old_rec.ppm_information17
      ,p_ppm_information18_o
          => pay_ppm_shd.g_old_rec.ppm_information18
      ,p_ppm_information19_o
          => pay_ppm_shd.g_old_rec.ppm_information19
      ,p_ppm_information20_o
          => pay_ppm_shd.g_old_rec.ppm_information20
      ,p_ppm_information21_o
          => pay_ppm_shd.g_old_rec.ppm_information21
      ,p_ppm_information22_o
          => pay_ppm_shd.g_old_rec.ppm_information22
      ,p_ppm_information23_o
          => pay_ppm_shd.g_old_rec.ppm_information23
      ,p_ppm_information24_o
          => pay_ppm_shd.g_old_rec.ppm_information24
      ,p_ppm_information25_o
          => pay_ppm_shd.g_old_rec.ppm_information25
      ,p_ppm_information26_o
          => pay_ppm_shd.g_old_rec.ppm_information26
      ,p_ppm_information27_o
          => pay_ppm_shd.g_old_rec.ppm_information27
      ,p_ppm_information28_o
          => pay_ppm_shd.g_old_rec.ppm_information28
      ,p_ppm_information29_o
          => pay_ppm_shd.g_old_rec.ppm_information29
      ,p_ppm_information30_o
          => pay_ppm_shd.g_old_rec.ppm_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_PERSONAL_PAYMENT_METHODS_F'
        ,p_hook_type   => 'AU'
        );
  end;
  -- End of API User Hook for post_update.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure convert_defs(p_rec in out nocopy pay_ppm_shd.g_rec_type) is
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
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_ppm_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.external_account_id = hr_api.g_number) then
    p_rec.external_account_id :=
    pay_ppm_shd.g_old_rec.external_account_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pay_ppm_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.run_Type_id = hr_api.g_number) then
    p_rec.run_Type_id :=
    pay_ppm_shd.g_old_rec.run_Type_id;
  End If;
  If (p_rec.org_payment_method_id = hr_api.g_number) then
    p_rec.org_payment_method_id :=
    pay_ppm_shd.g_old_rec.org_payment_method_id;
  End If;
  If (p_rec.amount = hr_api.g_number) then
    p_rec.amount :=
    pay_ppm_shd.g_old_rec.amount;
  End If;
  If (p_rec.comment_id = hr_api.g_number) then
    p_rec.comment_id :=
    pay_ppm_shd.g_old_rec.comment_id;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    pay_ppm_shd.g_old_rec.comments;
  End If;
  If (p_rec.percentage = hr_api.g_number) then
    p_rec.percentage :=
    pay_ppm_shd.g_old_rec.percentage;
  End If;
  If (p_rec.priority = hr_api.g_number) then
    p_rec.priority :=
    pay_ppm_shd.g_old_rec.priority;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pay_ppm_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pay_ppm_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pay_ppm_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pay_ppm_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pay_ppm_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pay_ppm_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pay_ppm_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pay_ppm_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pay_ppm_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pay_ppm_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pay_ppm_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pay_ppm_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pay_ppm_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pay_ppm_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pay_ppm_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pay_ppm_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pay_ppm_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pay_ppm_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pay_ppm_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pay_ppm_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pay_ppm_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.payee_type = hr_api.g_varchar2) then
    p_rec.payee_type :=
    pay_ppm_shd.g_old_rec.payee_type;
  End If;
  If (p_rec.payee_id = hr_api.g_number) then
    p_rec.payee_id :=
    pay_ppm_shd.g_old_rec.payee_id;
  End If;
  If (p_rec.ppm_information_category = hr_api.g_varchar2) then
    p_rec.ppm_information_category :=
    pay_ppm_shd.g_old_rec.ppm_information_category;
  End If;
  If (p_rec.ppm_information1 = hr_api.g_varchar2) then
    p_rec.ppm_information1 :=
    pay_ppm_shd.g_old_rec.ppm_information1;
  End If;
  If (p_rec.ppm_information2 = hr_api.g_varchar2) then
    p_rec.ppm_information2 :=
    pay_ppm_shd.g_old_rec.ppm_information2;
  End If;
  If (p_rec.ppm_information3 = hr_api.g_varchar2) then
    p_rec.ppm_information3 :=
    pay_ppm_shd.g_old_rec.ppm_information3;
  End If;
  If (p_rec.ppm_information4 = hr_api.g_varchar2) then
    p_rec.ppm_information4 :=
    pay_ppm_shd.g_old_rec.ppm_information4;
  End If;
  If (p_rec.ppm_information5 = hr_api.g_varchar2) then
    p_rec.ppm_information5 :=
    pay_ppm_shd.g_old_rec.ppm_information5;
  End If;
  If (p_rec.ppm_information6 = hr_api.g_varchar2) then
    p_rec.ppm_information6 :=
    pay_ppm_shd.g_old_rec.ppm_information6;
  End If;
  If (p_rec.ppm_information7 = hr_api.g_varchar2) then
    p_rec.ppm_information7 :=
    pay_ppm_shd.g_old_rec.ppm_information7;
  End If;
  If (p_rec.ppm_information8 = hr_api.g_varchar2) then
    p_rec.ppm_information8 :=
    pay_ppm_shd.g_old_rec.ppm_information8;
  End If;
  If (p_rec.ppm_information9 = hr_api.g_varchar2) then
    p_rec.ppm_information9 :=
    pay_ppm_shd.g_old_rec.ppm_information9;
  End If;
  If (p_rec.ppm_information10 = hr_api.g_varchar2) then
    p_rec.ppm_information10 :=
    pay_ppm_shd.g_old_rec.ppm_information10;
  End If;
  If (p_rec.ppm_information11 = hr_api.g_varchar2) then
    p_rec.ppm_information11 :=
    pay_ppm_shd.g_old_rec.ppm_information11;
  End If;
  If (p_rec.ppm_information12 = hr_api.g_varchar2) then
    p_rec.ppm_information12 :=
    pay_ppm_shd.g_old_rec.ppm_information12;
  End If;
  If (p_rec.ppm_information13 = hr_api.g_varchar2) then
    p_rec.ppm_information13 :=
    pay_ppm_shd.g_old_rec.ppm_information13;
  End If;
  If (p_rec.ppm_information14 = hr_api.g_varchar2) then
    p_rec.ppm_information14 :=
    pay_ppm_shd.g_old_rec.ppm_information14;
  End If;
  If (p_rec.ppm_information15 = hr_api.g_varchar2) then
    p_rec.ppm_information15 :=
    pay_ppm_shd.g_old_rec.ppm_information15;
  End If;
  If (p_rec.ppm_information16 = hr_api.g_varchar2) then
    p_rec.ppm_information16 :=
    pay_ppm_shd.g_old_rec.ppm_information16;
  End If;
  If (p_rec.ppm_information17 = hr_api.g_varchar2) then
    p_rec.ppm_information17 :=
    pay_ppm_shd.g_old_rec.ppm_information17;
  End If;
  If (p_rec.ppm_information18 = hr_api.g_varchar2) then
    p_rec.ppm_information18 :=
    pay_ppm_shd.g_old_rec.ppm_information18;
  End If;
  If (p_rec.ppm_information19 = hr_api.g_varchar2) then
    p_rec.ppm_information19 :=
    pay_ppm_shd.g_old_rec.ppm_information19;
  End If;
  If (p_rec.ppm_information20 = hr_api.g_varchar2) then
    p_rec.ppm_information20 :=
    pay_ppm_shd.g_old_rec.ppm_information20;
  End If;
  If (p_rec.ppm_information21 = hr_api.g_varchar2) then
    p_rec.ppm_information21 :=
    pay_ppm_shd.g_old_rec.ppm_information21;
  End If;
  If (p_rec.ppm_information22 = hr_api.g_varchar2) then
    p_rec.ppm_information22 :=
    pay_ppm_shd.g_old_rec.ppm_information22;
  End If;
  If (p_rec.ppm_information23 = hr_api.g_varchar2) then
    p_rec.ppm_information23 :=
    pay_ppm_shd.g_old_rec.ppm_information23;
  End If;
  If (p_rec.ppm_information24 = hr_api.g_varchar2) then
    p_rec.ppm_information24 :=
    pay_ppm_shd.g_old_rec.ppm_information24;
  End If;
  If (p_rec.ppm_information25 = hr_api.g_varchar2) then
    p_rec.ppm_information25 :=
    pay_ppm_shd.g_old_rec.ppm_information25;
  End If;
  If (p_rec.ppm_information26 = hr_api.g_varchar2) then
    p_rec.ppm_information26 :=
    pay_ppm_shd.g_old_rec.ppm_information26;
  End If;
  If (p_rec.ppm_information27 = hr_api.g_varchar2) then
    p_rec.ppm_information27 :=
    pay_ppm_shd.g_old_rec.ppm_information27;
  End If;
  If (p_rec.ppm_information28 = hr_api.g_varchar2) then
    p_rec.ppm_information28 :=
    pay_ppm_shd.g_old_rec.ppm_information28;
  End If;
  If (p_rec.ppm_information29 = hr_api.g_varchar2) then
    p_rec.ppm_information29 :=
    pay_ppm_shd.g_old_rec.ppm_information29;
  End If;
  If (p_rec.ppm_information30 = hr_api.g_varchar2) then
    p_rec.ppm_information30 :=
    pay_ppm_shd.g_old_rec.ppm_information30;
  End If;
  --
  -- Return the plsql record structure.
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
  p_rec			in out 	nocopy pay_ppm_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2,
  p_validate		in 	boolean default false
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
-- In Out parameter
--
  l_object_version_number        number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Assign out and in-out parameters to local variables
    -- and issue the savepoint.
    --
    l_object_version_number := p_rec.object_version_number;
    --
    SAVEPOINT upd_pay_ppm;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  pay_ppm_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_personal_payment_method_id	 => p_rec.personal_payment_method_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pay_ppm_bus.update_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode  	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
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
    p_rec.object_version_number := l_object_version_number;
    p_rec.effective_start_date  := null;
    p_rec.effective_end_date    := null;
    p_rec.comment_id            := null;
    --
    ROLLBACK TO upd_pay_ppm;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_personal_payment_method_id   in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_external_account_id          in number           default hr_api.g_number,
  p_amount                       in number           default hr_api.g_number,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_percentage                   in number           default hr_api.g_number,
  p_priority                     in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_payee_type                   in varchar2         default hr_api.g_varchar2,
  p_payee_id                     in number           default hr_api.g_number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2,
  p_validate			 in boolean          default false,
  p_ppm_information_category     in varchar2         default hr_api.g_varchar2,
  p_ppm_information1             in varchar2         default hr_api.g_varchar2,
  p_ppm_information2             in varchar2         default hr_api.g_varchar2,
  p_ppm_information3             in varchar2         default hr_api.g_varchar2,
  p_ppm_information4             in varchar2         default hr_api.g_varchar2,
  p_ppm_information5             in varchar2         default hr_api.g_varchar2,
  p_ppm_information6             in varchar2         default hr_api.g_varchar2,
  p_ppm_information7             in varchar2         default hr_api.g_varchar2,
  p_ppm_information8             in varchar2         default hr_api.g_varchar2,
  p_ppm_information9             in varchar2         default hr_api.g_varchar2,
  p_ppm_information10            in varchar2         default hr_api.g_varchar2,
  p_ppm_information11            in varchar2         default hr_api.g_varchar2,
  p_ppm_information12            in varchar2         default hr_api.g_varchar2,
  p_ppm_information13            in varchar2         default hr_api.g_varchar2,
  p_ppm_information14            in varchar2         default hr_api.g_varchar2,
  p_ppm_information15            in varchar2         default hr_api.g_varchar2,
  p_ppm_information16            in varchar2         default hr_api.g_varchar2,
  p_ppm_information17            in varchar2         default hr_api.g_varchar2,
  p_ppm_information18            in varchar2         default hr_api.g_varchar2,
  p_ppm_information19            in varchar2         default hr_api.g_varchar2,
  p_ppm_information20            in varchar2         default hr_api.g_varchar2,
  p_ppm_information21            in varchar2         default hr_api.g_varchar2,
  p_ppm_information22            in varchar2         default hr_api.g_varchar2,
  p_ppm_information23            in varchar2         default hr_api.g_varchar2,
  p_ppm_information24            in varchar2         default hr_api.g_varchar2,
  p_ppm_information25            in varchar2         default hr_api.g_varchar2,
  p_ppm_information26            in varchar2         default hr_api.g_varchar2,
  p_ppm_information27            in varchar2         default hr_api.g_varchar2,
  p_ppm_information28            in varchar2         default hr_api.g_varchar2,
  p_ppm_information29            in varchar2         default hr_api.g_varchar2,
  p_ppm_information30            in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec		pay_ppm_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_ppm_shd.convert_args
  (
  p_personal_payment_method_id,
  null,
  null,
  hr_api.g_number,
  p_external_account_id,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  p_amount,
  hr_api.g_number,
  p_comments,
  p_percentage,
  p_priority,
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
  p_object_version_number,
  p_payee_type,
  p_payee_id,
  p_ppm_information_category,
  p_ppm_information1,
  p_ppm_information2,
  p_ppm_information3,
  p_ppm_information4,
  p_ppm_information5,
  p_ppm_information6,
  p_ppm_information7,
  p_ppm_information8,
  p_ppm_information9,
  p_ppm_information10,
  p_ppm_information11,
  p_ppm_information12,
  p_ppm_information13,
  p_ppm_information14,
  p_ppm_information15,
  p_ppm_information16,
  p_ppm_information17,
  p_ppm_information18,
  p_ppm_information19,
  p_ppm_information20,
  p_ppm_information21,
  p_ppm_information22,
  p_ppm_information23,
  p_ppm_information24,
  p_ppm_information25,
  p_ppm_information26,
  p_ppm_information27,
  p_ppm_information28,
  p_ppm_information29,
  p_ppm_information30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode, p_validate);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  p_comment_id                  := l_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_ppm_upd;

/
