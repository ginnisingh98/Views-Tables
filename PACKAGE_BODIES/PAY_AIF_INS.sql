--------------------------------------------------------
--  DDL for Package Body PAY_AIF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AIF_INS" as
/* $Header: pyaifrhi.pkb 120.2.12000000.2 2007/03/30 05:34:36 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_aif_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_action_information_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_action_information_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_aif_ins.g_action_information_id_i := p_action_information_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
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
  (p_rec in out nocopy pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: pay_action_information
  --
  insert into pay_action_information
      (action_information_id
      ,action_context_id
      ,action_context_type
      ,tax_unit_id
      ,jurisdiction_code
      ,source_id
      ,source_text
      ,tax_group
      ,object_version_number
      ,effective_date
      ,assignment_id
      ,action_information_category
      ,action_information1
      ,action_information2
      ,action_information3
      ,action_information4
      ,action_information5
      ,action_information6
      ,action_information7
      ,action_information8
      ,action_information9
      ,action_information10
      ,action_information11
      ,action_information12
      ,action_information13
      ,action_information14
      ,action_information15
      ,action_information16
      ,action_information17
      ,action_information18
      ,action_information19
      ,action_information20
      ,action_information21
      ,action_information22
      ,action_information23
      ,action_information24
      ,action_information25
      ,action_information26
      ,action_information27
      ,action_information28
      ,action_information29
      ,action_information30
      )
  Values
    (p_rec.action_information_id
    ,p_rec.action_context_id
    ,p_rec.action_context_type
    ,p_rec.tax_unit_id
    ,p_rec.jurisdiction_code
    ,p_rec.source_id
    ,p_rec.source_text
    ,p_rec.tax_group
    ,p_rec.object_version_number
    ,p_rec.effective_date
    ,p_rec.assignment_id
    ,p_rec.action_information_category
    ,p_rec.action_information1
    ,p_rec.action_information2
    ,p_rec.action_information3
    ,p_rec.action_information4
    ,p_rec.action_information5
    ,p_rec.action_information6
    ,p_rec.action_information7
    ,p_rec.action_information8
    ,p_rec.action_information9
    ,p_rec.action_information10
    ,p_rec.action_information11
    ,p_rec.action_information12
    ,p_rec.action_information13
    ,p_rec.action_information14
    ,p_rec.action_information15
    ,p_rec.action_information16
    ,p_rec.action_information17
    ,p_rec.action_information18
    ,p_rec.action_information19
    ,p_rec.action_information20
    ,p_rec.action_information21
    ,p_rec.action_information22
    ,p_rec.action_information23
    ,p_rec.action_information24
    ,p_rec.action_information25
    ,p_rec.action_information26
    ,p_rec.action_information27
    ,p_rec.action_information28
    ,p_rec.action_information29
    ,p_rec.action_information30
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_aif_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_aif_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_aif_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec  in out nocopy pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
  Cursor C_Sel1 is select pay_action_information_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pay_action_information
     where action_information_id =
             pay_aif_ins.g_action_information_id_i;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pay_aif_ins.g_action_information_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','pay_action_information');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.action_information_id :=
      pay_aif_ins.g_action_information_id_i;
    pay_aif_ins.g_action_information_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.action_information_id;
    Close C_Sel1;
  End If;
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
  (p_rec                          in pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_aif_rki.after_insert
      (p_action_information_id
      => p_rec.action_information_id
      ,p_action_context_id
      => p_rec.action_context_id
      ,p_action_context_type
      => p_rec.action_context_type
      ,p_tax_unit_id
      => p_rec.tax_unit_id
      ,p_jurisdiction_code
      => p_rec.jurisdiction_code
      ,p_source_id
      => p_rec.source_id
      ,p_source_text
      => p_rec.source_text
      ,p_tax_group
      => p_rec.tax_group
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_effective_date
      => p_rec.effective_date
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_action_information_category
      => p_rec.action_information_category
      ,p_action_information1
      => p_rec.action_information1
      ,p_action_information2
      => p_rec.action_information2
      ,p_action_information3
      => p_rec.action_information3
      ,p_action_information4
      => p_rec.action_information4
      ,p_action_information5
      => p_rec.action_information5
      ,p_action_information6
      => p_rec.action_information6
      ,p_action_information7
      => p_rec.action_information7
      ,p_action_information8
      => p_rec.action_information8
      ,p_action_information9
      => p_rec.action_information9
      ,p_action_information10
      => p_rec.action_information10
      ,p_action_information11
      => p_rec.action_information11
      ,p_action_information12
      => p_rec.action_information12
      ,p_action_information13
      => p_rec.action_information13
      ,p_action_information14
      => p_rec.action_information14
      ,p_action_information15
      => p_rec.action_information15
      ,p_action_information16
      => p_rec.action_information16
      ,p_action_information17
      => p_rec.action_information17
      ,p_action_information18
      => p_rec.action_information18
      ,p_action_information19
      => p_rec.action_information19
      ,p_action_information20
      => p_rec.action_information20
      ,p_action_information21
      => p_rec.action_information21
      ,p_action_information22
      => p_rec.action_information22
      ,p_action_information23
      => p_rec.action_information23
      ,p_action_information24
      => p_rec.action_information24
      ,p_action_information25
      => p_rec.action_information25
      ,p_action_information26
      => p_rec.action_information26
      ,p_action_information27
      => p_rec.action_information27
      ,p_action_information28
      => p_rec.action_information28
      ,p_action_information29
      => p_rec.action_information29
      ,p_action_information30
      => p_rec.action_information30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_ACTION_INFORMATION'
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
  (p_rec                          in out nocopy pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_aif_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_aif_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_aif_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_aif_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_action_context_id              in     number
  ,p_action_context_type            in     varchar2
  ,p_effective_date                 in     date
  ,p_assignment_id                  in     number
  ,p_action_information_category    in     varchar2
  ,p_tax_unit_id                    in     number   default null
  ,p_jurisdiction_code              in     varchar2 default null
  ,p_source_id                      in     number   default null
  ,p_source_text                    in     varchar2 default null
  ,p_tax_group                      in     varchar2 default null
  ,p_action_information1            in     varchar2 default null
  ,p_action_information2            in     varchar2 default null
  ,p_action_information3            in     varchar2 default null
  ,p_action_information4            in     varchar2 default null
  ,p_action_information5            in     varchar2 default null
  ,p_action_information6            in     varchar2 default null
  ,p_action_information7            in     varchar2 default null
  ,p_action_information8            in     varchar2 default null
  ,p_action_information9            in     varchar2 default null
  ,p_action_information10           in     varchar2 default null
  ,p_action_information11           in     varchar2 default null
  ,p_action_information12           in     varchar2 default null
  ,p_action_information13           in     varchar2 default null
  ,p_action_information14           in     varchar2 default null
  ,p_action_information15           in     varchar2 default null
  ,p_action_information16           in     varchar2 default null
  ,p_action_information17           in     varchar2 default null
  ,p_action_information18           in     varchar2 default null
  ,p_action_information19           in     varchar2 default null
  ,p_action_information20           in     varchar2 default null
  ,p_action_information21           in     varchar2 default null
  ,p_action_information22           in     varchar2 default null
  ,p_action_information23           in     varchar2 default null
  ,p_action_information24           in     varchar2 default null
  ,p_action_information25           in     varchar2 default null
  ,p_action_information26           in     varchar2 default null
  ,p_action_information27           in     varchar2 default null
  ,p_action_information28           in     varchar2 default null
  ,p_action_information29           in     varchar2 default null
  ,p_action_information30           in     varchar2 default null
  ,p_action_information_id             out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  pay_aif_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_aif_shd.convert_args
    (null
    ,p_action_context_id
    ,p_action_context_type
    ,p_tax_unit_id
    ,p_jurisdiction_code
    ,p_source_id
    ,p_source_text
    ,p_tax_group
    ,null
    ,p_effective_date
    ,p_assignment_id
    ,p_action_information_category
    ,p_action_information1
    ,p_action_information2
    ,p_action_information3
    ,p_action_information4
    ,p_action_information5
    ,p_action_information6
    ,p_action_information7
    ,p_action_information8
    ,p_action_information9
    ,p_action_information10
    ,p_action_information11
    ,p_action_information12
    ,p_action_information13
    ,p_action_information14
    ,p_action_information15
    ,p_action_information16
    ,p_action_information17
    ,p_action_information18
    ,p_action_information19
    ,p_action_information20
    ,p_action_information21
    ,p_action_information22
    ,p_action_information23
    ,p_action_information24
    ,p_action_information25
    ,p_action_information26
    ,p_action_information27
    ,p_action_information28
    ,p_action_information29
    ,p_action_information30
    );
  --
  -- Having converted the arguments into the pay_aif_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_aif_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_action_information_id := l_rec.action_information_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_aif_ins;

/
