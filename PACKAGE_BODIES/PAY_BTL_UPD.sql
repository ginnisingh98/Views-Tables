--------------------------------------------------------
--  DDL for Package Body PAY_BTL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BTL_UPD" as
/* $Header: pybtlrhi.pkb 120.7 2005/11/09 08:16:09 mkataria noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_btl_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_btl_shd.g_rec_type
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
  pay_btl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_batch_lines Row
  --
  update pay_batch_lines
    set
     batch_line_id                   = p_rec.batch_line_id
    ,cost_allocation_keyflex_id      = p_rec.cost_allocation_keyflex_id
    ,element_type_id                 = p_rec.element_type_id
    ,assignment_id                   = p_rec.assignment_id
    ,batch_line_status               = p_rec.batch_line_status
    ,assignment_number               = p_rec.assignment_number
    ,batch_sequence                  = p_rec.batch_sequence
    ,concatenated_segments           = p_rec.concatenated_segments
    ,effective_date                  = p_rec.effective_date
    ,element_name                    = p_rec.element_name
    ,entry_type                      = p_rec.entry_type
    ,reason                          = p_rec.reason
    ,segment1                        = p_rec.segment1
    ,segment2                        = p_rec.segment2
    ,segment3                        = p_rec.segment3
    ,segment4                        = p_rec.segment4
    ,segment5                        = p_rec.segment5
    ,segment6                        = p_rec.segment6
    ,segment7                        = p_rec.segment7
    ,segment8                        = p_rec.segment8
    ,segment9                        = p_rec.segment9
    ,segment10                       = p_rec.segment10
    ,segment11                       = p_rec.segment11
    ,segment12                       = p_rec.segment12
    ,segment13                       = p_rec.segment13
    ,segment14                       = p_rec.segment14
    ,segment15                       = p_rec.segment15
    ,segment16                       = p_rec.segment16
    ,segment17                       = p_rec.segment17
    ,segment18                       = p_rec.segment18
    ,segment19                       = p_rec.segment19
    ,segment20                       = p_rec.segment20
    ,segment21                       = p_rec.segment21
    ,segment22                       = p_rec.segment22
    ,segment23                       = p_rec.segment23
    ,segment24                       = p_rec.segment24
    ,segment25                       = p_rec.segment25
    ,segment26                       = p_rec.segment26
    ,segment27                       = p_rec.segment27
    ,segment28                       = p_rec.segment28
    ,segment29                       = p_rec.segment29
    ,segment30                       = p_rec.segment30
    ,value_1                         = p_rec.value_1
    ,value_2                         = p_rec.value_2
    ,value_3                         = p_rec.value_3
    ,value_4                         = p_rec.value_4
    ,value_5                         = p_rec.value_5
    ,value_6                         = p_rec.value_6
    ,value_7                         = p_rec.value_7
    ,value_8                         = p_rec.value_8
    ,value_9                         = p_rec.value_9
    ,value_10                        = p_rec.value_10
    ,value_11                        = p_rec.value_11
    ,value_12                        = p_rec.value_12
    ,value_13                        = p_rec.value_13
    ,value_14                        = p_rec.value_14
    ,value_15                        = p_rec.value_15
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,entry_information_category      = p_rec.entry_information_category
    ,entry_information1              = p_rec.entry_information1
    ,entry_information2              = p_rec.entry_information2
    ,entry_information3              = p_rec.entry_information3
    ,entry_information4              = p_rec.entry_information4
    ,entry_information5              = p_rec.entry_information5
    ,entry_information6              = p_rec.entry_information6
    ,entry_information7              = p_rec.entry_information7
    ,entry_information8              = p_rec.entry_information8
    ,entry_information9              = p_rec.entry_information9
    ,entry_information10             = p_rec.entry_information10
    ,entry_information11             = p_rec.entry_information11
    ,entry_information12             = p_rec.entry_information12
    ,entry_information13             = p_rec.entry_information13
    ,entry_information14             = p_rec.entry_information14
    ,entry_information15             = p_rec.entry_information15
    ,entry_information16             = p_rec.entry_information16
    ,entry_information17             = p_rec.entry_information17
    ,entry_information18             = p_rec.entry_information18
    ,entry_information19             = p_rec.entry_information19
    ,entry_information20             = p_rec.entry_information20
    ,entry_information21             = p_rec.entry_information21
    ,entry_information22             = p_rec.entry_information22
    ,entry_information23             = p_rec.entry_information23
    ,entry_information24             = p_rec.entry_information24
    ,entry_information25             = p_rec.entry_information25
    ,entry_information26             = p_rec.entry_information26
    ,entry_information27             = p_rec.entry_information27
    ,entry_information28             = p_rec.entry_information28
    ,entry_information29             = p_rec.entry_information29
    ,entry_information30             = p_rec.entry_information30
    ,date_earned                     = p_rec.date_earned
    ,personal_payment_method_id      = p_rec.personal_payment_method_id
    ,subpriority                     = p_rec.subpriority
    ,effective_start_date            = p_rec.effective_start_date
    ,effective_end_date              = p_rec.effective_end_date
    ,object_version_number           = p_rec.object_version_number
    where batch_line_id = p_rec.batch_line_id;
  --
  pay_btl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_btl_shd.g_api_dml := false;   -- Unset the api dml status
    pay_btl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_btl_shd.g_api_dml := false;   -- Unset the api dml status
    pay_btl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_btl_shd.g_api_dml := false;   -- Unset the api dml status
    pay_btl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_btl_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pay_btl_shd.g_rec_type
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
  (p_session_date                 in date
  ,p_rec                          in pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_btl_rku.after_update
      (p_session_date
      => p_session_date
      ,p_batch_line_id
      => p_rec.batch_line_id
      ,p_cost_allocation_keyflex_id
      => p_rec.cost_allocation_keyflex_id
      ,p_element_type_id
      => p_rec.element_type_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_batch_line_status
      => p_rec.batch_line_status
      ,p_assignment_number
      => p_rec.assignment_number
      ,p_batch_sequence
      => p_rec.batch_sequence
      ,p_concatenated_segments
      => p_rec.concatenated_segments
      ,p_effective_date
      => p_rec.effective_date
      ,p_element_name
      => p_rec.element_name
      ,p_entry_type
      => p_rec.entry_type
      ,p_reason
      => p_rec.reason
      ,p_segment1
      => p_rec.segment1
      ,p_segment2
      => p_rec.segment2
      ,p_segment3
      => p_rec.segment3
      ,p_segment4
      => p_rec.segment4
      ,p_segment5
      => p_rec.segment5
      ,p_segment6
      => p_rec.segment6
      ,p_segment7
      => p_rec.segment7
      ,p_segment8
      => p_rec.segment8
      ,p_segment9
      => p_rec.segment9
      ,p_segment10
      => p_rec.segment10
      ,p_segment11
      => p_rec.segment11
      ,p_segment12
      => p_rec.segment12
      ,p_segment13
      => p_rec.segment13
      ,p_segment14
      => p_rec.segment14
      ,p_segment15
      => p_rec.segment15
      ,p_segment16
      => p_rec.segment16
      ,p_segment17
      => p_rec.segment17
      ,p_segment18
      => p_rec.segment18
      ,p_segment19
      => p_rec.segment19
      ,p_segment20
      => p_rec.segment20
      ,p_segment21
      => p_rec.segment21
      ,p_segment22
      => p_rec.segment22
      ,p_segment23
      => p_rec.segment23
      ,p_segment24
      => p_rec.segment24
      ,p_segment25
      => p_rec.segment25
      ,p_segment26
      => p_rec.segment26
      ,p_segment27
      => p_rec.segment27
      ,p_segment28
      => p_rec.segment28
      ,p_segment29
      => p_rec.segment29
      ,p_segment30
      => p_rec.segment30
      ,p_value_1
      => p_rec.value_1
      ,p_value_2
      => p_rec.value_2
      ,p_value_3
      => p_rec.value_3
      ,p_value_4
      => p_rec.value_4
      ,p_value_5
      => p_rec.value_5
      ,p_value_6
      => p_rec.value_6
      ,p_value_7
      => p_rec.value_7
      ,p_value_8
      => p_rec.value_8
      ,p_value_9
      => p_rec.value_9
      ,p_value_10
      => p_rec.value_10
      ,p_value_11
      => p_rec.value_11
      ,p_value_12
      => p_rec.value_12
      ,p_value_13
      => p_rec.value_13
      ,p_value_14
      => p_rec.value_14
      ,p_value_15
      => p_rec.value_15
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_entry_information_category
      => p_rec.entry_information_category
      ,p_entry_information1
      => p_rec.entry_information1
      ,p_entry_information2
      => p_rec.entry_information2
      ,p_entry_information3
      => p_rec.entry_information3
      ,p_entry_information4
      => p_rec.entry_information4
      ,p_entry_information5
      => p_rec.entry_information5
      ,p_entry_information6
      => p_rec.entry_information6
      ,p_entry_information7
      => p_rec.entry_information7
      ,p_entry_information8
      => p_rec.entry_information8
      ,p_entry_information9
      => p_rec.entry_information9
      ,p_entry_information10
      => p_rec.entry_information10
      ,p_entry_information11
      => p_rec.entry_information11
      ,p_entry_information12
      => p_rec.entry_information12
      ,p_entry_information13
      => p_rec.entry_information13
      ,p_entry_information14
      => p_rec.entry_information14
      ,p_entry_information15
      => p_rec.entry_information15
      ,p_entry_information16
      => p_rec.entry_information16
      ,p_entry_information17
      => p_rec.entry_information17
      ,p_entry_information18
      => p_rec.entry_information18
      ,p_entry_information19
      => p_rec.entry_information19
      ,p_entry_information20
      => p_rec.entry_information20
      ,p_entry_information21
      => p_rec.entry_information21
      ,p_entry_information22
      => p_rec.entry_information22
      ,p_entry_information23
      => p_rec.entry_information23
      ,p_entry_information24
      => p_rec.entry_information24
      ,p_entry_information25
      => p_rec.entry_information25
      ,p_entry_information26
      => p_rec.entry_information26
      ,p_entry_information27
      => p_rec.entry_information27
      ,p_entry_information28
      => p_rec.entry_information28
      ,p_entry_information29
      => p_rec.entry_information29
      ,p_entry_information30
      => p_rec.entry_information30
      ,p_date_earned
      => p_rec.date_earned
      ,p_personal_payment_method_id
      => p_rec.personal_payment_method_id
      ,p_subpriority
      => p_rec.subpriority
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_cost_allocation_keyflex_id_o
      => pay_btl_shd.g_old_rec.cost_allocation_keyflex_id
      ,p_element_type_id_o
      => pay_btl_shd.g_old_rec.element_type_id
      ,p_assignment_id_o
      => pay_btl_shd.g_old_rec.assignment_id
      ,p_batch_id_o
      => pay_btl_shd.g_old_rec.batch_id
      ,p_batch_line_status_o
      => pay_btl_shd.g_old_rec.batch_line_status
      ,p_assignment_number_o
      => pay_btl_shd.g_old_rec.assignment_number
      ,p_batch_sequence_o
      => pay_btl_shd.g_old_rec.batch_sequence
      ,p_concatenated_segments_o
      => pay_btl_shd.g_old_rec.concatenated_segments
      ,p_effective_date_o
      => pay_btl_shd.g_old_rec.effective_date
      ,p_element_name_o
      => pay_btl_shd.g_old_rec.element_name
      ,p_entry_type_o
      => pay_btl_shd.g_old_rec.entry_type
      ,p_reason_o
      => pay_btl_shd.g_old_rec.reason
      ,p_segment1_o
      => pay_btl_shd.g_old_rec.segment1
      ,p_segment2_o
      => pay_btl_shd.g_old_rec.segment2
      ,p_segment3_o
      => pay_btl_shd.g_old_rec.segment3
      ,p_segment4_o
      => pay_btl_shd.g_old_rec.segment4
      ,p_segment5_o
      => pay_btl_shd.g_old_rec.segment5
      ,p_segment6_o
      => pay_btl_shd.g_old_rec.segment6
      ,p_segment7_o
      => pay_btl_shd.g_old_rec.segment7
      ,p_segment8_o
      => pay_btl_shd.g_old_rec.segment8
      ,p_segment9_o
      => pay_btl_shd.g_old_rec.segment9
      ,p_segment10_o
      => pay_btl_shd.g_old_rec.segment10
      ,p_segment11_o
      => pay_btl_shd.g_old_rec.segment11
      ,p_segment12_o
      => pay_btl_shd.g_old_rec.segment12
      ,p_segment13_o
      => pay_btl_shd.g_old_rec.segment13
      ,p_segment14_o
      => pay_btl_shd.g_old_rec.segment14
      ,p_segment15_o
      => pay_btl_shd.g_old_rec.segment15
      ,p_segment16_o
      => pay_btl_shd.g_old_rec.segment16
      ,p_segment17_o
      => pay_btl_shd.g_old_rec.segment17
      ,p_segment18_o
      => pay_btl_shd.g_old_rec.segment18
      ,p_segment19_o
      => pay_btl_shd.g_old_rec.segment19
      ,p_segment20_o
      => pay_btl_shd.g_old_rec.segment20
      ,p_segment21_o
      => pay_btl_shd.g_old_rec.segment21
      ,p_segment22_o
      => pay_btl_shd.g_old_rec.segment22
      ,p_segment23_o
      => pay_btl_shd.g_old_rec.segment23
      ,p_segment24_o
      => pay_btl_shd.g_old_rec.segment24
      ,p_segment25_o
      => pay_btl_shd.g_old_rec.segment25
      ,p_segment26_o
      => pay_btl_shd.g_old_rec.segment26
      ,p_segment27_o
      => pay_btl_shd.g_old_rec.segment27
      ,p_segment28_o
      => pay_btl_shd.g_old_rec.segment28
      ,p_segment29_o
      => pay_btl_shd.g_old_rec.segment29
      ,p_segment30_o
      => pay_btl_shd.g_old_rec.segment30
      ,p_value_1_o
      => pay_btl_shd.g_old_rec.value_1
      ,p_value_2_o
      => pay_btl_shd.g_old_rec.value_2
      ,p_value_3_o
      => pay_btl_shd.g_old_rec.value_3
      ,p_value_4_o
      => pay_btl_shd.g_old_rec.value_4
      ,p_value_5_o
      => pay_btl_shd.g_old_rec.value_5
      ,p_value_6_o
      => pay_btl_shd.g_old_rec.value_6
      ,p_value_7_o
      => pay_btl_shd.g_old_rec.value_7
      ,p_value_8_o
      => pay_btl_shd.g_old_rec.value_8
      ,p_value_9_o
      => pay_btl_shd.g_old_rec.value_9
      ,p_value_10_o
      => pay_btl_shd.g_old_rec.value_10
      ,p_value_11_o
      => pay_btl_shd.g_old_rec.value_11
      ,p_value_12_o
      => pay_btl_shd.g_old_rec.value_12
      ,p_value_13_o
      => pay_btl_shd.g_old_rec.value_13
      ,p_value_14_o
      => pay_btl_shd.g_old_rec.value_14
      ,p_value_15_o
      => pay_btl_shd.g_old_rec.value_15
      ,p_attribute_category_o
      => pay_btl_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_btl_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_btl_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_btl_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_btl_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_btl_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_btl_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_btl_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_btl_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_btl_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_btl_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_btl_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_btl_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_btl_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_btl_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_btl_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_btl_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_btl_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_btl_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_btl_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_btl_shd.g_old_rec.attribute20
      ,p_entry_information_category_o
      => pay_btl_shd.g_old_rec.entry_information_category
      ,p_entry_information1_o
      => pay_btl_shd.g_old_rec.entry_information1
      ,p_entry_information2_o
      => pay_btl_shd.g_old_rec.entry_information2
      ,p_entry_information3_o
      => pay_btl_shd.g_old_rec.entry_information3
      ,p_entry_information4_o
      => pay_btl_shd.g_old_rec.entry_information4
      ,p_entry_information5_o
      => pay_btl_shd.g_old_rec.entry_information5
      ,p_entry_information6_o
      => pay_btl_shd.g_old_rec.entry_information6
      ,p_entry_information7_o
      => pay_btl_shd.g_old_rec.entry_information7
      ,p_entry_information8_o
      => pay_btl_shd.g_old_rec.entry_information8
      ,p_entry_information9_o
      => pay_btl_shd.g_old_rec.entry_information9
      ,p_entry_information10_o
      => pay_btl_shd.g_old_rec.entry_information10
      ,p_entry_information11_o
      => pay_btl_shd.g_old_rec.entry_information11
      ,p_entry_information12_o
      => pay_btl_shd.g_old_rec.entry_information12
      ,p_entry_information13_o
      => pay_btl_shd.g_old_rec.entry_information13
      ,p_entry_information14_o
      => pay_btl_shd.g_old_rec.entry_information14
      ,p_entry_information15_o
      => pay_btl_shd.g_old_rec.entry_information15
      ,p_entry_information16_o
      => pay_btl_shd.g_old_rec.entry_information16
      ,p_entry_information17_o
      => pay_btl_shd.g_old_rec.entry_information17
      ,p_entry_information18_o
      => pay_btl_shd.g_old_rec.entry_information18
      ,p_entry_information19_o
      => pay_btl_shd.g_old_rec.entry_information19
      ,p_entry_information20_o
      => pay_btl_shd.g_old_rec.entry_information20
      ,p_entry_information21_o
      => pay_btl_shd.g_old_rec.entry_information21
      ,p_entry_information22_o
      => pay_btl_shd.g_old_rec.entry_information22
      ,p_entry_information23_o
      => pay_btl_shd.g_old_rec.entry_information23
      ,p_entry_information24_o
      => pay_btl_shd.g_old_rec.entry_information24
      ,p_entry_information25_o
      => pay_btl_shd.g_old_rec.entry_information25
      ,p_entry_information26_o
      => pay_btl_shd.g_old_rec.entry_information26
      ,p_entry_information27_o
      => pay_btl_shd.g_old_rec.entry_information27
      ,p_entry_information28_o
      => pay_btl_shd.g_old_rec.entry_information28
      ,p_entry_information29_o
      => pay_btl_shd.g_old_rec.entry_information29
      ,p_entry_information30_o
      => pay_btl_shd.g_old_rec.entry_information30
      ,p_date_earned_o
      => pay_btl_shd.g_old_rec.date_earned
      ,p_personal_payment_method_id_o
      => pay_btl_shd.g_old_rec.personal_payment_method_id
      ,p_subpriority_o
      => pay_btl_shd.g_old_rec.subpriority
      ,p_effective_start_date_o
      => pay_btl_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_btl_shd.g_old_rec.effective_end_date
      ,p_object_version_number_o
      => pay_btl_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BATCH_LINES'
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
  (p_rec in out nocopy pay_btl_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.cost_allocation_keyflex_id = hr_api.g_number) then
    p_rec.cost_allocation_keyflex_id :=
    pay_btl_shd.g_old_rec.cost_allocation_keyflex_id;
  End If;
  If (p_rec.element_type_id = hr_api.g_number) then
    p_rec.element_type_id :=
    pay_btl_shd.g_old_rec.element_type_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pay_btl_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.batch_id = hr_api.g_number) then
    p_rec.batch_id :=
    pay_btl_shd.g_old_rec.batch_id;
  End If;
  If (p_rec.batch_line_status = hr_api.g_varchar2) then
    p_rec.batch_line_status :=
    pay_btl_shd.g_old_rec.batch_line_status;
  End If;
  If (p_rec.assignment_number = hr_api.g_varchar2) then
    p_rec.assignment_number :=
    pay_btl_shd.g_old_rec.assignment_number;
  End If;
  If (p_rec.batch_sequence = hr_api.g_number) then
    p_rec.batch_sequence :=
    pay_btl_shd.g_old_rec.batch_sequence;
  End If;
  If (p_rec.concatenated_segments = hr_api.g_varchar2) then
    p_rec.concatenated_segments :=
    pay_btl_shd.g_old_rec.concatenated_segments;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date :=
    pay_btl_shd.g_old_rec.effective_date;
  End If;
  If (p_rec.element_name = hr_api.g_varchar2) then
    p_rec.element_name :=
    pay_btl_shd.g_old_rec.element_name;
  End If;
  If (p_rec.entry_type = hr_api.g_varchar2) then
    p_rec.entry_type :=
    pay_btl_shd.g_old_rec.entry_type;
  End If;
  If (p_rec.reason = hr_api.g_varchar2) then
    p_rec.reason :=
    pay_btl_shd.g_old_rec.reason;
  End If;
  If (p_rec.segment1 = hr_api.g_varchar2) then
    p_rec.segment1 :=
    pay_btl_shd.g_old_rec.segment1;
  End If;
  If (p_rec.segment2 = hr_api.g_varchar2) then
    p_rec.segment2 :=
    pay_btl_shd.g_old_rec.segment2;
  End If;
  If (p_rec.segment3 = hr_api.g_varchar2) then
    p_rec.segment3 :=
    pay_btl_shd.g_old_rec.segment3;
  End If;
  If (p_rec.segment4 = hr_api.g_varchar2) then
    p_rec.segment4 :=
    pay_btl_shd.g_old_rec.segment4;
  End If;
  If (p_rec.segment5 = hr_api.g_varchar2) then
    p_rec.segment5 :=
    pay_btl_shd.g_old_rec.segment5;
  End If;
  If (p_rec.segment6 = hr_api.g_varchar2) then
    p_rec.segment6 :=
    pay_btl_shd.g_old_rec.segment6;
  End If;
  If (p_rec.segment7 = hr_api.g_varchar2) then
    p_rec.segment7 :=
    pay_btl_shd.g_old_rec.segment7;
  End If;
  If (p_rec.segment8 = hr_api.g_varchar2) then
    p_rec.segment8 :=
    pay_btl_shd.g_old_rec.segment8;
  End If;
  If (p_rec.segment9 = hr_api.g_varchar2) then
    p_rec.segment9 :=
    pay_btl_shd.g_old_rec.segment9;
  End If;
  If (p_rec.segment10 = hr_api.g_varchar2) then
    p_rec.segment10 :=
    pay_btl_shd.g_old_rec.segment10;
  End If;
  If (p_rec.segment11 = hr_api.g_varchar2) then
    p_rec.segment11 :=
    pay_btl_shd.g_old_rec.segment11;
  End If;
  If (p_rec.segment12 = hr_api.g_varchar2) then
    p_rec.segment12 :=
    pay_btl_shd.g_old_rec.segment12;
  End If;
  If (p_rec.segment13 = hr_api.g_varchar2) then
    p_rec.segment13 :=
    pay_btl_shd.g_old_rec.segment13;
  End If;
  If (p_rec.segment14 = hr_api.g_varchar2) then
    p_rec.segment14 :=
    pay_btl_shd.g_old_rec.segment14;
  End If;
  If (p_rec.segment15 = hr_api.g_varchar2) then
    p_rec.segment15 :=
    pay_btl_shd.g_old_rec.segment15;
  End If;
  If (p_rec.segment16 = hr_api.g_varchar2) then
    p_rec.segment16 :=
    pay_btl_shd.g_old_rec.segment16;
  End If;
  If (p_rec.segment17 = hr_api.g_varchar2) then
    p_rec.segment17 :=
    pay_btl_shd.g_old_rec.segment17;
  End If;
  If (p_rec.segment18 = hr_api.g_varchar2) then
    p_rec.segment18 :=
    pay_btl_shd.g_old_rec.segment18;
  End If;
  If (p_rec.segment19 = hr_api.g_varchar2) then
    p_rec.segment19 :=
    pay_btl_shd.g_old_rec.segment19;
  End If;
  If (p_rec.segment20 = hr_api.g_varchar2) then
    p_rec.segment20 :=
    pay_btl_shd.g_old_rec.segment20;
  End If;
  If (p_rec.segment21 = hr_api.g_varchar2) then
    p_rec.segment21 :=
    pay_btl_shd.g_old_rec.segment21;
  End If;
  If (p_rec.segment22 = hr_api.g_varchar2) then
    p_rec.segment22 :=
    pay_btl_shd.g_old_rec.segment22;
  End If;
  If (p_rec.segment23 = hr_api.g_varchar2) then
    p_rec.segment23 :=
    pay_btl_shd.g_old_rec.segment23;
  End If;
  If (p_rec.segment24 = hr_api.g_varchar2) then
    p_rec.segment24 :=
    pay_btl_shd.g_old_rec.segment24;
  End If;
  If (p_rec.segment25 = hr_api.g_varchar2) then
    p_rec.segment25 :=
    pay_btl_shd.g_old_rec.segment25;
  End If;
  If (p_rec.segment26 = hr_api.g_varchar2) then
    p_rec.segment26 :=
    pay_btl_shd.g_old_rec.segment26;
  End If;
  If (p_rec.segment27 = hr_api.g_varchar2) then
    p_rec.segment27 :=
    pay_btl_shd.g_old_rec.segment27;
  End If;
  If (p_rec.segment28 = hr_api.g_varchar2) then
    p_rec.segment28 :=
    pay_btl_shd.g_old_rec.segment28;
  End If;
  If (p_rec.segment29 = hr_api.g_varchar2) then
    p_rec.segment29 :=
    pay_btl_shd.g_old_rec.segment29;
  End If;
  If (p_rec.segment30 = hr_api.g_varchar2) then
    p_rec.segment30 :=
    pay_btl_shd.g_old_rec.segment30;
  End If;
  If (p_rec.value_1 = hr_api.g_varchar2) then
    p_rec.value_1 :=
    pay_btl_shd.g_old_rec.value_1;
  End If;
  If (p_rec.value_2 = hr_api.g_varchar2) then
    p_rec.value_2 :=
    pay_btl_shd.g_old_rec.value_2;
  End If;
  If (p_rec.value_3 = hr_api.g_varchar2) then
    p_rec.value_3 :=
    pay_btl_shd.g_old_rec.value_3;
  End If;
  If (p_rec.value_4 = hr_api.g_varchar2) then
    p_rec.value_4 :=
    pay_btl_shd.g_old_rec.value_4;
  End If;
  If (p_rec.value_5 = hr_api.g_varchar2) then
    p_rec.value_5 :=
    pay_btl_shd.g_old_rec.value_5;
  End If;
  If (p_rec.value_6 = hr_api.g_varchar2) then
    p_rec.value_6 :=
    pay_btl_shd.g_old_rec.value_6;
  End If;
  If (p_rec.value_7 = hr_api.g_varchar2) then
    p_rec.value_7 :=
    pay_btl_shd.g_old_rec.value_7;
  End If;
  If (p_rec.value_8 = hr_api.g_varchar2) then
    p_rec.value_8 :=
    pay_btl_shd.g_old_rec.value_8;
  End If;
  If (p_rec.value_9 = hr_api.g_varchar2) then
    p_rec.value_9 :=
    pay_btl_shd.g_old_rec.value_9;
  End If;
  If (p_rec.value_10 = hr_api.g_varchar2) then
    p_rec.value_10 :=
    pay_btl_shd.g_old_rec.value_10;
  End If;
  If (p_rec.value_11 = hr_api.g_varchar2) then
    p_rec.value_11 :=
    pay_btl_shd.g_old_rec.value_11;
  End If;
  If (p_rec.value_12 = hr_api.g_varchar2) then
    p_rec.value_12 :=
    pay_btl_shd.g_old_rec.value_12;
  End If;
  If (p_rec.value_13 = hr_api.g_varchar2) then
    p_rec.value_13 :=
    pay_btl_shd.g_old_rec.value_13;
  End If;
  If (p_rec.value_14 = hr_api.g_varchar2) then
    p_rec.value_14 :=
    pay_btl_shd.g_old_rec.value_14;
  End If;
  If (p_rec.value_15 = hr_api.g_varchar2) then
    p_rec.value_15 :=
    pay_btl_shd.g_old_rec.value_15;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pay_btl_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pay_btl_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pay_btl_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pay_btl_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pay_btl_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pay_btl_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pay_btl_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pay_btl_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pay_btl_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pay_btl_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pay_btl_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pay_btl_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pay_btl_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pay_btl_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pay_btl_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pay_btl_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pay_btl_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pay_btl_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pay_btl_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pay_btl_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pay_btl_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.entry_information_category = hr_api.g_varchar2) then
    p_rec.entry_information_category :=
    pay_btl_shd.g_old_rec.entry_information_category;
  End If;
  If (p_rec.entry_information1 = hr_api.g_varchar2) then
    p_rec.entry_information1 :=
    pay_btl_shd.g_old_rec.entry_information1;
  End If;
  If (p_rec.entry_information2 = hr_api.g_varchar2) then
    p_rec.entry_information2 :=
    pay_btl_shd.g_old_rec.entry_information2;
  End If;
  If (p_rec.entry_information3 = hr_api.g_varchar2) then
    p_rec.entry_information3 :=
    pay_btl_shd.g_old_rec.entry_information3;
  End If;
  If (p_rec.entry_information4 = hr_api.g_varchar2) then
    p_rec.entry_information4 :=
    pay_btl_shd.g_old_rec.entry_information4;
  End If;
  If (p_rec.entry_information5 = hr_api.g_varchar2) then
    p_rec.entry_information5 :=
    pay_btl_shd.g_old_rec.entry_information5;
  End If;
  If (p_rec.entry_information6 = hr_api.g_varchar2) then
    p_rec.entry_information6 :=
    pay_btl_shd.g_old_rec.entry_information6;
  End If;
  If (p_rec.entry_information7 = hr_api.g_varchar2) then
    p_rec.entry_information7 :=
    pay_btl_shd.g_old_rec.entry_information7;
  End If;
  If (p_rec.entry_information8 = hr_api.g_varchar2) then
    p_rec.entry_information8 :=
    pay_btl_shd.g_old_rec.entry_information8;
  End If;
  If (p_rec.entry_information9 = hr_api.g_varchar2) then
    p_rec.entry_information9 :=
    pay_btl_shd.g_old_rec.entry_information9;
  End If;
  If (p_rec.entry_information10 = hr_api.g_varchar2) then
    p_rec.entry_information10 :=
    pay_btl_shd.g_old_rec.entry_information10;
  End If;
  If (p_rec.entry_information11 = hr_api.g_varchar2) then
    p_rec.entry_information11 :=
    pay_btl_shd.g_old_rec.entry_information11;
  End If;
  If (p_rec.entry_information12 = hr_api.g_varchar2) then
    p_rec.entry_information12 :=
    pay_btl_shd.g_old_rec.entry_information12;
  End If;
  If (p_rec.entry_information13 = hr_api.g_varchar2) then
    p_rec.entry_information13 :=
    pay_btl_shd.g_old_rec.entry_information13;
  End If;
  If (p_rec.entry_information14 = hr_api.g_varchar2) then
    p_rec.entry_information14 :=
    pay_btl_shd.g_old_rec.entry_information14;
  End If;
  If (p_rec.entry_information15 = hr_api.g_varchar2) then
    p_rec.entry_information15 :=
    pay_btl_shd.g_old_rec.entry_information15;
  End If;
  If (p_rec.entry_information16 = hr_api.g_varchar2) then
    p_rec.entry_information16 :=
    pay_btl_shd.g_old_rec.entry_information16;
  End If;
  If (p_rec.entry_information17 = hr_api.g_varchar2) then
    p_rec.entry_information17 :=
    pay_btl_shd.g_old_rec.entry_information17;
  End If;
  If (p_rec.entry_information18 = hr_api.g_varchar2) then
    p_rec.entry_information18 :=
    pay_btl_shd.g_old_rec.entry_information18;
  End If;
  If (p_rec.entry_information19 = hr_api.g_varchar2) then
    p_rec.entry_information19 :=
    pay_btl_shd.g_old_rec.entry_information19;
  End If;
  If (p_rec.entry_information20 = hr_api.g_varchar2) then
    p_rec.entry_information20 :=
    pay_btl_shd.g_old_rec.entry_information20;
  End If;
  If (p_rec.entry_information21 = hr_api.g_varchar2) then
    p_rec.entry_information21 :=
    pay_btl_shd.g_old_rec.entry_information21;
  End If;
  If (p_rec.entry_information22 = hr_api.g_varchar2) then
    p_rec.entry_information22 :=
    pay_btl_shd.g_old_rec.entry_information22;
  End If;
  If (p_rec.entry_information23 = hr_api.g_varchar2) then
    p_rec.entry_information23 :=
    pay_btl_shd.g_old_rec.entry_information23;
  End If;
  If (p_rec.entry_information24 = hr_api.g_varchar2) then
    p_rec.entry_information24 :=
    pay_btl_shd.g_old_rec.entry_information24;
  End If;
  If (p_rec.entry_information25 = hr_api.g_varchar2) then
    p_rec.entry_information25 :=
    pay_btl_shd.g_old_rec.entry_information25;
  End If;
  If (p_rec.entry_information26 = hr_api.g_varchar2) then
    p_rec.entry_information26 :=
    pay_btl_shd.g_old_rec.entry_information26;
  End If;
  If (p_rec.entry_information27 = hr_api.g_varchar2) then
    p_rec.entry_information27 :=
    pay_btl_shd.g_old_rec.entry_information27;
  End If;
  If (p_rec.entry_information28 = hr_api.g_varchar2) then
    p_rec.entry_information28 :=
    pay_btl_shd.g_old_rec.entry_information28;
  End If;
  If (p_rec.entry_information29 = hr_api.g_varchar2) then
    p_rec.entry_information29 :=
    pay_btl_shd.g_old_rec.entry_information29;
  End If;
  If (p_rec.entry_information30 = hr_api.g_varchar2) then
    p_rec.entry_information30 :=
    pay_btl_shd.g_old_rec.entry_information30;
  End If;
  If (p_rec.date_earned = hr_api.g_date) then
    p_rec.date_earned :=
    pay_btl_shd.g_old_rec.date_earned;
  End If;
  If (p_rec.personal_payment_method_id = hr_api.g_number) then
    p_rec.personal_payment_method_id :=
    pay_btl_shd.g_old_rec.personal_payment_method_id;
  End If;
  If (p_rec.subpriority = hr_api.g_number) then
    p_rec.subpriority :=
    pay_btl_shd.g_old_rec.subpriority;
  End If;
  If (p_rec.effective_start_date = hr_api.g_date) then
    p_rec.effective_start_date :=
    pay_btl_shd.g_old_rec.effective_start_date;
  End If;
  If (p_rec.effective_end_date = hr_api.g_date) then
    p_rec.effective_end_date :=
    pay_btl_shd.g_old_rec.effective_end_date;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_session_date                 in     date
  ,p_rec                          in out nocopy pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
  l_cost_allocation_keyflex_id   pay_batch_lines.cost_allocation_keyflex_id%type;
  l_concat_segments_out   pay_batch_lines.concatenated_segments%type;
  l_segments  pay_btl_shd.segment_value;
  l_segment_passed  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_btl_shd.lck
    (p_rec.batch_line_id
    ,p_rec.object_version_number
    );

--
-- The user might pass either CCID or segment values to update the
-- flexfield information. In case the user passes both, we need to
-- give preference to segment values and ignore the CCID.
-- If only CCID is passed, get the segment values from the Combinations
-- table so that the segments can be validated.
--
  l_segment_passed := false;

  if ( p_rec.cost_allocation_keyflex_id  <> hr_api.g_number ) then
  l_segments := pay_btl_shd.segment_value( p_rec.segment1, p_rec.segment2, p_rec.segment3, p_rec.segment4,
                             p_rec.segment5, p_rec.segment6, p_rec.segment7, p_rec.segment8,
                             p_rec.segment9, p_rec.segment10,p_rec.segment11,p_rec.segment12,
                             p_rec.segment13,p_rec.segment14,p_rec.segment15,p_rec.segment16,
                             p_rec.segment17,p_rec.segment18,p_rec.segment19,p_rec.segment20,
                             p_rec.segment21,p_rec.segment22,p_rec.segment23,p_rec.segment24,
                             p_rec.segment25,p_rec.segment26,p_rec.segment27,p_rec.segment28,
                             p_rec.segment29,p_rec.segment30);
  for i in 1..30 loop
      if l_segments(i) = hr_api.g_varchar2 then
         null;
      else
         l_segment_passed := true;
	 exit;
      end if;
  end loop;

  if ( l_segment_passed = false ) then
      pay_btl_shd.get_flex_segs(p_rec);
  end if;

  end if;

  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --

  convert_defs(p_rec);


  pay_btl_bus.update_validate
     (p_session_date,
      p_rec
     );


  if not (p_rec.segment1 is null and
     p_rec.segment2 is null and
     p_rec.segment3 is null and
     p_rec.segment4 is null and
     p_rec.segment5 is null and
     p_rec.segment6 is null and
     p_rec.segment7 is null and
     p_rec.segment8 is null and
     p_rec.segment9 is null and
     p_rec.segment10 is null and
     p_rec.segment11 is null and
     p_rec.segment12 is null and
     p_rec.segment13 is null and
     p_rec.segment14 is null and
     p_rec.segment15 is null and
     p_rec.segment16 is null and
     p_rec.segment17 is null and
     p_rec.segment18 is null and
     p_rec.segment19 is null and
     p_rec.segment20 is null and
     p_rec.segment21 is null and
     p_rec.segment22 is null and
     p_rec.segment23 is null and
     p_rec.segment24 is null and
     p_rec.segment25 is null and
     p_rec.segment26 is null and
     p_rec.segment27 is null and
     p_rec.segment28 is null and
     p_rec.segment29 is null and
     p_rec.segment30 is null) then

    l_cost_allocation_keyflex_id := p_rec.cost_allocation_keyflex_id;
    pay_btl_shd.keyflex_comb(
    p_dml_mode               => 'UPDATE',
    p_appl_short_name        => 'PAY',
    p_flex_code              => 'COST',
    p_segment1               => p_rec.segment1,
    p_segment2               => p_rec.segment2,
    p_segment3               => p_rec.segment3,
    p_segment4               => p_rec.segment4,
    p_segment5               => p_rec.segment5,
    p_segment6               => p_rec.segment6,
    p_segment7               => p_rec.segment7,
    p_segment8               => p_rec.segment8,
    p_segment9               => p_rec.segment9,
    p_segment10              => p_rec.segment10,
    p_segment11              => p_rec.segment11,
    p_segment12              => p_rec.segment12,
    p_segment13              => p_rec.segment13,
    p_segment14              => p_rec.segment14,
    p_segment15              => p_rec.segment15,
    p_segment16              => p_rec.segment16,
    p_segment17              => p_rec.segment17,
    p_segment18              => p_rec.segment18,
    p_segment19              => p_rec.segment19,
    p_segment20              => p_rec.segment20,
    p_segment21              => p_rec.segment21,
    p_segment22              => p_rec.segment22,
    p_segment23              => p_rec.segment23,
    p_segment24              => p_rec.segment24,
    p_segment25              => p_rec.segment25,
    p_segment26              => p_rec.segment26,
    p_segment27              => p_rec.segment27,
    p_segment28              => p_rec.segment28,
    p_segment29              => p_rec.segment29,
    p_segment30              => p_rec.segment30,
    p_concat_segments_in     => p_rec.concatenated_segments,
    p_batch_line_id          => p_rec.batch_line_id,
    --
    -- OUT parameter,
    -- l_rec.cost_allocation_keyflex_id may have a new value
    --
    p_ccid                   => l_cost_allocation_keyflex_id,
    p_concat_segments_out    => l_concat_segments_out
    );

  end if;

  p_rec.cost_allocation_keyflex_id := l_cost_allocation_keyflex_id;
  p_rec.concatenated_segments := l_concat_segments_out;
  --
  -- Call the supporting pre-update operation
  --
  pay_btl_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_btl_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_btl_upd.post_update
     (p_session_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_session_date                 in     date
  ,p_batch_line_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_batch_line_status            in     varchar2  default hr_api.g_varchar2
  ,p_cost_allocation_keyflex_id   in     number    default hr_api.g_number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_batch_sequence               in     number    default hr_api.g_number
  ,p_concatenated_segments        in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_element_name                 in     varchar2  default hr_api.g_varchar2
  ,p_entry_type                   in     varchar2  default hr_api.g_varchar2
  ,p_reason                       in     varchar2  default hr_api.g_varchar2
  ,p_segment1                     in     varchar2  default hr_api.g_varchar2
  ,p_segment2                     in     varchar2  default hr_api.g_varchar2
  ,p_segment3                     in     varchar2  default hr_api.g_varchar2
  ,p_segment4                     in     varchar2  default hr_api.g_varchar2
  ,p_segment5                     in     varchar2  default hr_api.g_varchar2
  ,p_segment6                     in     varchar2  default hr_api.g_varchar2
  ,p_segment7                     in     varchar2  default hr_api.g_varchar2
  ,p_segment8                     in     varchar2  default hr_api.g_varchar2
  ,p_segment9                     in     varchar2  default hr_api.g_varchar2
  ,p_segment10                    in     varchar2  default hr_api.g_varchar2
  ,p_segment11                    in     varchar2  default hr_api.g_varchar2
  ,p_segment12                    in     varchar2  default hr_api.g_varchar2
  ,p_segment13                    in     varchar2  default hr_api.g_varchar2
  ,p_segment14                    in     varchar2  default hr_api.g_varchar2
  ,p_segment15                    in     varchar2  default hr_api.g_varchar2
  ,p_segment16                    in     varchar2  default hr_api.g_varchar2
  ,p_segment17                    in     varchar2  default hr_api.g_varchar2
  ,p_segment18                    in     varchar2  default hr_api.g_varchar2
  ,p_segment19                    in     varchar2  default hr_api.g_varchar2
  ,p_segment20                    in     varchar2  default hr_api.g_varchar2
  ,p_segment21                    in     varchar2  default hr_api.g_varchar2
  ,p_segment22                    in     varchar2  default hr_api.g_varchar2
  ,p_segment23                    in     varchar2  default hr_api.g_varchar2
  ,p_segment24                    in     varchar2  default hr_api.g_varchar2
  ,p_segment25                    in     varchar2  default hr_api.g_varchar2
  ,p_segment26                    in     varchar2  default hr_api.g_varchar2
  ,p_segment27                    in     varchar2  default hr_api.g_varchar2
  ,p_segment28                    in     varchar2  default hr_api.g_varchar2
  ,p_segment29                    in     varchar2  default hr_api.g_varchar2
  ,p_segment30                    in     varchar2  default hr_api.g_varchar2
  ,p_value_1                      in     varchar2  default hr_api.g_varchar2
  ,p_value_2                      in     varchar2  default hr_api.g_varchar2
  ,p_value_3                      in     varchar2  default hr_api.g_varchar2
  ,p_value_4                      in     varchar2  default hr_api.g_varchar2
  ,p_value_5                      in     varchar2  default hr_api.g_varchar2
  ,p_value_6                      in     varchar2  default hr_api.g_varchar2
  ,p_value_7                      in     varchar2  default hr_api.g_varchar2
  ,p_value_8                      in     varchar2  default hr_api.g_varchar2
  ,p_value_9                      in     varchar2  default hr_api.g_varchar2
  ,p_value_10                     in     varchar2  default hr_api.g_varchar2
  ,p_value_11                     in     varchar2  default hr_api.g_varchar2
  ,p_value_12                     in     varchar2  default hr_api.g_varchar2
  ,p_value_13                     in     varchar2  default hr_api.g_varchar2
  ,p_value_14                     in     varchar2  default hr_api.g_varchar2
  ,p_value_15                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_entry_information_category   in     varchar2  default hr_api.g_varchar2
  ,p_entry_information1           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information2           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information3           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information4           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information5           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information6           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information7           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information8           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information9           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information10          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information11          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information12          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information13          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information14          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information15          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information16          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information17          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information18          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information19          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information20          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information21          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information22          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information23          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information24          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information25          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information26          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information27          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information28          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information29          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information30          in     varchar2  default hr_api.g_varchar2
  ,p_date_earned                  in     date      default hr_api.g_date
  ,p_personal_payment_method_id   in     number    default hr_api.g_number
  ,p_subpriority                  in     number    default hr_api.g_number
  ,p_effective_start_date         in     date      default hr_api.g_date
  ,p_effective_end_date           in     date      default hr_api.g_date
  ) is
--
  l_rec	  pay_btl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--  l_concat_segments_out varchar2(2000);
--  l_cost_allocation_keyflex_id number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
--  l_cost_allocation_keyflex_id := p_cost_allocation_keyflex_id;
  l_rec :=
  pay_btl_shd.convert_args
  (p_batch_line_id
  ,p_cost_allocation_keyflex_id
  ,p_element_type_id
  ,p_assignment_id
  ,hr_api.g_number
  ,p_batch_line_status
  ,p_assignment_number
  ,p_batch_sequence
  ,p_concatenated_segments
  ,p_effective_date
  ,p_element_name
  ,p_entry_type
  ,p_reason
  ,p_segment1
  ,p_segment2
  ,p_segment3
  ,p_segment4
  ,p_segment5
  ,p_segment6
  ,p_segment7
  ,p_segment8
  ,p_segment9
  ,p_segment10
  ,p_segment11
  ,p_segment12
  ,p_segment13
  ,p_segment14
  ,p_segment15
  ,p_segment16
  ,p_segment17
  ,p_segment18
  ,p_segment19
  ,p_segment20
  ,p_segment21
  ,p_segment22
  ,p_segment23
  ,p_segment24
  ,p_segment25
  ,p_segment26
  ,p_segment27
  ,p_segment28
  ,p_segment29
  ,p_segment30
  ,p_value_1
  ,p_value_2
  ,p_value_3
  ,p_value_4
  ,p_value_5
  ,p_value_6
  ,p_value_7
  ,p_value_8
  ,p_value_9
  ,p_value_10
  ,p_value_11
  ,p_value_12
  ,p_value_13
  ,p_value_14
  ,p_value_15
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_entry_information_category
  ,p_entry_information1
  ,p_entry_information2
  ,p_entry_information3
  ,p_entry_information4
  ,p_entry_information5
  ,p_entry_information6
  ,p_entry_information7
  ,p_entry_information8
  ,p_entry_information9
  ,p_entry_information10
  ,p_entry_information11
  ,p_entry_information12
  ,p_entry_information13
  ,p_entry_information14
  ,p_entry_information15
  ,p_entry_information16
  ,p_entry_information17
  ,p_entry_information18
  ,p_entry_information19
  ,p_entry_information20
  ,p_entry_information21
  ,p_entry_information22
  ,p_entry_information23
  ,p_entry_information24
  ,p_entry_information25
  ,p_entry_information26
  ,p_entry_information27
  ,p_entry_information28
  ,p_entry_information29
  ,p_entry_information30
  ,p_date_earned
  ,p_personal_payment_method_id
  ,p_subpriority
  ,p_effective_start_date
  ,p_effective_end_date
  ,p_object_version_number
  );

--  l_cost_allocation_keyflex_id := l_rec.cost_allocation_keyflex_id;


--  l_rec.cost_allocation_keyflex_id:= l_cost_allocation_keyflex_id;

  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_btl_upd.upd
     (p_session_date,
      l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_btl_upd;


/
