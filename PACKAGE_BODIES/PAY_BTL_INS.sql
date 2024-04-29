--------------------------------------------------------
--  DDL for Package Body PAY_BTL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BTL_INS" as
/* $Header: pybtlrhi.pkb 120.7 2005/11/09 08:16:09 mkataria noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_btl_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
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
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure insert_dml
  (p_rec in out nocopy pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pay_btl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_batch_lines
  --
  insert into pay_batch_lines
      (batch_line_id
      ,cost_allocation_keyflex_id
      ,element_type_id
      ,assignment_id
      ,batch_id
      ,batch_line_status
      ,assignment_number
      ,batch_sequence
      ,concatenated_segments
      ,effective_date
      ,element_name
      ,entry_type
      ,reason
      ,segment1
      ,segment2
      ,segment3
      ,segment4
      ,segment5
      ,segment6
      ,segment7
      ,segment8
      ,segment9
      ,segment10
      ,segment11
      ,segment12
      ,segment13
      ,segment14
      ,segment15
      ,segment16
      ,segment17
      ,segment18
      ,segment19
      ,segment20
      ,segment21
      ,segment22
      ,segment23
      ,segment24
      ,segment25
      ,segment26
      ,segment27
      ,segment28
      ,segment29
      ,segment30
      ,value_1
      ,value_2
      ,value_3
      ,value_4
      ,value_5
      ,value_6
      ,value_7
      ,value_8
      ,value_9
      ,value_10
      ,value_11
      ,value_12
      ,value_13
      ,value_14
      ,value_15
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,entry_information_category
      ,entry_information1
      ,entry_information2
      ,entry_information3
      ,entry_information4
      ,entry_information5
      ,entry_information6
      ,entry_information7
      ,entry_information8
      ,entry_information9
      ,entry_information10
      ,entry_information11
      ,entry_information12
      ,entry_information13
      ,entry_information14
      ,entry_information15
      ,entry_information16
      ,entry_information17
      ,entry_information18
      ,entry_information19
      ,entry_information20
      ,entry_information21
      ,entry_information22
      ,entry_information23
      ,entry_information24
      ,entry_information25
      ,entry_information26
      ,entry_information27
      ,entry_information28
      ,entry_information29
      ,entry_information30
      ,date_earned
      ,personal_payment_method_id
      ,subpriority
      ,effective_start_date
      ,effective_end_date
      ,object_version_number
      )
  Values
    (p_rec.batch_line_id
    ,p_rec.cost_allocation_keyflex_id
    ,p_rec.element_type_id
    ,p_rec.assignment_id
    ,p_rec.batch_id
    ,p_rec.batch_line_status
    ,p_rec.assignment_number
    ,p_rec.batch_sequence
    ,p_rec.concatenated_segments
    ,p_rec.effective_date
    ,p_rec.element_name
    ,p_rec.entry_type
    ,p_rec.reason
    ,p_rec.segment1
    ,p_rec.segment2
    ,p_rec.segment3
    ,p_rec.segment4
    ,p_rec.segment5
    ,p_rec.segment6
    ,p_rec.segment7
    ,p_rec.segment8
    ,p_rec.segment9
    ,p_rec.segment10
    ,p_rec.segment11
    ,p_rec.segment12
    ,p_rec.segment13
    ,p_rec.segment14
    ,p_rec.segment15
    ,p_rec.segment16
    ,p_rec.segment17
    ,p_rec.segment18
    ,p_rec.segment19
    ,p_rec.segment20
    ,p_rec.segment21
    ,p_rec.segment22
    ,p_rec.segment23
    ,p_rec.segment24
    ,p_rec.segment25
    ,p_rec.segment26
    ,p_rec.segment27
    ,p_rec.segment28
    ,p_rec.segment29
    ,p_rec.segment30
    ,p_rec.value_1
    ,p_rec.value_2
    ,p_rec.value_3
    ,p_rec.value_4
    ,p_rec.value_5
    ,p_rec.value_6
    ,p_rec.value_7
    ,p_rec.value_8
    ,p_rec.value_9
    ,p_rec.value_10
    ,p_rec.value_11
    ,p_rec.value_12
    ,p_rec.value_13
    ,p_rec.value_14
    ,p_rec.value_15
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.entry_information_category
    ,p_rec.entry_information1
    ,p_rec.entry_information2
    ,p_rec.entry_information3
    ,p_rec.entry_information4
    ,p_rec.entry_information5
    ,p_rec.entry_information6
    ,p_rec.entry_information7
    ,p_rec.entry_information8
    ,p_rec.entry_information9
    ,p_rec.entry_information10
    ,p_rec.entry_information11
    ,p_rec.entry_information12
    ,p_rec.entry_information13
    ,p_rec.entry_information14
    ,p_rec.entry_information15
    ,p_rec.entry_information16
    ,p_rec.entry_information17
    ,p_rec.entry_information18
    ,p_rec.entry_information19
    ,p_rec.entry_information20
    ,p_rec.entry_information21
    ,p_rec.entry_information22
    ,p_rec.entry_information23
    ,p_rec.entry_information24
    ,p_rec.entry_information25
    ,p_rec.entry_information26
    ,p_rec.entry_information27
    ,p_rec.entry_information28
    ,p_rec.entry_information29
    ,p_rec.entry_information30
    ,p_rec.date_earned
    ,p_rec.personal_payment_method_id
    ,p_rec.subpriority
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.object_version_number
    );
  --
  pay_btl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
  (p_rec  in out nocopy pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_batch_lines_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.batch_line_id;
  Close C_Sel1;
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
  (p_session_date                 in date
  ,p_rec                          in pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_btl_rki.after_insert
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
      ,p_batch_id
      => p_rec.batch_id
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BATCH_LINES'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_session_date                 in date,
   p_rec                          in out nocopy pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
  l_segment_passed  boolean;
  l_segments pay_btl_shd.segment_value;
  l_cost_allocation_keyflex_id pay_batch_lines.cost_allocation_keyflex_id%type;
  l_concat_segments_out pay_batch_lines.concatenated_segments%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);


  l_segment_passed := false;

  if ( p_rec.cost_allocation_keyflex_id is not null ) then
  l_segments := pay_btl_shd.segment_value( p_rec.segment1, p_rec.segment2, p_rec.segment3, p_rec.segment4,
                             p_rec.segment5, p_rec.segment6, p_rec.segment7, p_rec.segment8,
                             p_rec.segment9, p_rec.segment10,p_rec.segment11,p_rec.segment12,
                             p_rec.segment13,p_rec.segment14,p_rec.segment15,p_rec.segment16,
                             p_rec.segment17,p_rec.segment18,p_rec.segment19,p_rec.segment20,
                             p_rec.segment21,p_rec.segment22,p_rec.segment23,p_rec.segment24,
                             p_rec.segment25,p_rec.segment26,p_rec.segment27,p_rec.segment28,
                             p_rec.segment29,p_rec.segment30);
  for i in 1..30 loop
      if (l_segments(i) is null ) then
         null;
      else
         l_segment_passed := true;
	 exit;
      end if;
  end loop;

  if ( l_segment_passed = false) then
      pay_btl_shd.get_flex_segs(p_rec);
  end if;

  end if;

  pay_btl_bus.insert_validate
     (p_session_date,
      p_rec
     );


--  l_cost_allocation_keyflex_id := p_rec.cost_allocation_keyflex_id;
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

    pay_btl_shd.keyflex_comb(
    p_dml_mode               => 'INSERT',
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
    p_batch_id          => p_rec.batch_id,
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
  -- Call the supporting pre-insert operation
  --
  pay_btl_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_btl_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_btl_ins.post_insert
     (p_session_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_session_date                   in     date
  ,p_batch_id                       in     number
  ,p_batch_line_status              in     varchar2
  ,p_cost_allocation_keyflex_id     in     number   default null
  ,p_element_type_id                in     number   default null
  ,p_assignment_id                  in     number   default null
  ,p_assignment_number              in     varchar2 default null
  ,p_batch_sequence                 in     number   default null
  ,p_concatenated_segments          in     varchar2 default null
  ,p_effective_date                 in     date     default null
  ,p_element_name                   in     varchar2 default null
  ,p_entry_type                     in     varchar2 default null
  ,p_reason                         in     varchar2 default null
  ,p_segment1                       in     varchar2 default null
  ,p_segment2                       in     varchar2 default null
  ,p_segment3                       in     varchar2 default null
  ,p_segment4                       in     varchar2 default null
  ,p_segment5                       in     varchar2 default null
  ,p_segment6                       in     varchar2 default null
  ,p_segment7                       in     varchar2 default null
  ,p_segment8                       in     varchar2 default null
  ,p_segment9                       in     varchar2 default null
  ,p_segment10                      in     varchar2 default null
  ,p_segment11                      in     varchar2 default null
  ,p_segment12                      in     varchar2 default null
  ,p_segment13                      in     varchar2 default null
  ,p_segment14                      in     varchar2 default null
  ,p_segment15                      in     varchar2 default null
  ,p_segment16                      in     varchar2 default null
  ,p_segment17                      in     varchar2 default null
  ,p_segment18                      in     varchar2 default null
  ,p_segment19                      in     varchar2 default null
  ,p_segment20                      in     varchar2 default null
  ,p_segment21                      in     varchar2 default null
  ,p_segment22                      in     varchar2 default null
  ,p_segment23                      in     varchar2 default null
  ,p_segment24                      in     varchar2 default null
  ,p_segment25                      in     varchar2 default null
  ,p_segment26                      in     varchar2 default null
  ,p_segment27                      in     varchar2 default null
  ,p_segment28                      in     varchar2 default null
  ,p_segment29                      in     varchar2 default null
  ,p_segment30                      in     varchar2 default null
  ,p_value_1                        in     varchar2 default null
  ,p_value_2                        in     varchar2 default null
  ,p_value_3                        in     varchar2 default null
  ,p_value_4                        in     varchar2 default null
  ,p_value_5                        in     varchar2 default null
  ,p_value_6                        in     varchar2 default null
  ,p_value_7                        in     varchar2 default null
  ,p_value_8                        in     varchar2 default null
  ,p_value_9                        in     varchar2 default null
  ,p_value_10                       in     varchar2 default null
  ,p_value_11                       in     varchar2 default null
  ,p_value_12                       in     varchar2 default null
  ,p_value_13                       in     varchar2 default null
  ,p_value_14                       in     varchar2 default null
  ,p_value_15                       in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_entry_information_category     in     varchar2 default null
  ,p_entry_information1             in     varchar2 default null
  ,p_entry_information2             in     varchar2 default null
  ,p_entry_information3             in     varchar2 default null
  ,p_entry_information4             in     varchar2 default null
  ,p_entry_information5             in     varchar2 default null
  ,p_entry_information6             in     varchar2 default null
  ,p_entry_information7             in     varchar2 default null
  ,p_entry_information8             in     varchar2 default null
  ,p_entry_information9             in     varchar2 default null
  ,p_entry_information10            in     varchar2 default null
  ,p_entry_information11            in     varchar2 default null
  ,p_entry_information12            in     varchar2 default null
  ,p_entry_information13            in     varchar2 default null
  ,p_entry_information14            in     varchar2 default null
  ,p_entry_information15            in     varchar2 default null
  ,p_entry_information16            in     varchar2 default null
  ,p_entry_information17            in     varchar2 default null
  ,p_entry_information18            in     varchar2 default null
  ,p_entry_information19            in     varchar2 default null
  ,p_entry_information20            in     varchar2 default null
  ,p_entry_information21            in     varchar2 default null
  ,p_entry_information22            in     varchar2 default null
  ,p_entry_information23            in     varchar2 default null
  ,p_entry_information24            in     varchar2 default null
  ,p_entry_information25            in     varchar2 default null
  ,p_entry_information26            in     varchar2 default null
  ,p_entry_information27            in     varchar2 default null
  ,p_entry_information28            in     varchar2 default null
  ,p_entry_information29            in     varchar2 default null
  ,p_entry_information30            in     varchar2 default null
  ,p_date_earned                    in     date     default null
  ,p_personal_payment_method_id     in     number   default null
  ,p_subpriority                    in     number   default null
  ,p_effective_start_date           in     date     default null
  ,p_effective_end_date             in     date     default null
  ,p_batch_line_id                     out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  pay_btl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
  l_concat_segments_out varchar2(2000);
  l_cost_allocation_keyflex_id number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_cost_allocation_keyflex_id := p_cost_allocation_keyflex_id;
  l_rec :=
  pay_btl_shd.convert_args
    (null
    ,p_cost_allocation_keyflex_id
    ,p_element_type_id
    ,p_assignment_id
    ,p_batch_id
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
    ,null
    );

  --
  -- Having converted the arguments into the pay_btl_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_btl_ins.ins
     (p_session_date,
      l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_batch_line_id := l_rec.batch_line_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_btl_ins;


/
