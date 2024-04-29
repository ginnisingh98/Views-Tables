--------------------------------------------------------
--  DDL for Package Body PAY_BTL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BTL_DEL" as
/* $Header: pybtlrhi.pkb 120.7 2005/11/09 08:16:09 mkataria noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_btl_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec in pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_btl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pay_batch_lines row.
  --
  delete from pay_batch_lines
  where batch_line_id = p_rec.batch_line_id;
  --
  pay_btl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pay_btl_shd.g_api_dml := false;   -- Unset the api dml status
    pay_btl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_btl_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in pay_btl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in pay_btl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    pay_btl_rkd.after_delete
      (p_batch_line_id
      => p_rec.batch_line_id
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec	      in pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_btl_shd.lck
    (p_rec.batch_line_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_btl_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pay_btl_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pay_btl_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pay_btl_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_batch_line_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  pay_btl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.batch_line_id := p_batch_line_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pay_btl_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_btl_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_btl_del;

/
