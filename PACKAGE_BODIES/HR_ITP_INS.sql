--------------------------------------------------------
--  DDL for Package Body HR_ITP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITP_INS" as
/* $Header: hritprhi.pkb 115.11 2003/12/03 07:01:45 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_itp_ins.';  -- Global package name
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
  (p_rec in out nocopy hr_itp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Entering:'||to_char(p_rec.previous_navigation_item_id), 5);
  hr_utility.set_location('Entering:'||to_char(p_rec.next_navigation_item_id), 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  --
  -- Insert the row into: hr_item_properties_b
  --
  insert into hr_item_properties_b
      (item_property_id
      ,object_version_number
      ,form_item_id
      ,template_item_id
      ,template_item_context_id
      ,alignment
      ,bevel
      ,case_restriction
      ,enabled
      ,format_mask
      ,height
      ,information_formula_id
      ,information_parameter_item_id1
      ,information_parameter_item_id2
      ,information_parameter_item_id3
      ,information_parameter_item_id4
      ,information_parameter_item_id5
      ,insert_allowed
      ,prompt_alignment_offset
      ,prompt_display_style
      ,prompt_edge
      ,prompt_edge_alignment
      ,prompt_edge_offset
      ,prompt_text_alignment
      ,query_allowed
      ,required
      ,update_allowed
      ,validation_formula_id
      ,validation_parameter_item_id1
      ,validation_parameter_item_id2
      ,validation_parameter_item_id3
      ,validation_parameter_item_id4
      ,validation_parameter_item_id5
      ,visible
      ,width
      ,x_position
      ,y_position
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
      ,next_navigation_item_id
      ,previous_navigation_item_id
      )
  Values
    (p_rec.item_property_id
    ,p_rec.object_version_number
    ,p_rec.form_item_id
    ,p_rec.template_item_id
    ,p_rec.template_item_context_id
    ,p_rec.alignment
    ,p_rec.bevel
    ,p_rec.case_restriction
    ,p_rec.enabled
    ,p_rec.format_mask
    ,p_rec.height
    ,p_rec.information_formula_id
    ,p_rec.information_parameter_item_id1
    ,p_rec.information_parameter_item_id2
    ,p_rec.information_parameter_item_id3
    ,p_rec.information_parameter_item_id4
    ,p_rec.information_parameter_item_id5
    ,p_rec.insert_allowed
    ,p_rec.prompt_alignment_offset
    ,p_rec.prompt_display_style
    ,p_rec.prompt_edge
    ,p_rec.prompt_edge_alignment
    ,p_rec.prompt_edge_offset
    ,p_rec.prompt_text_alignment
    ,p_rec.query_allowed
    ,p_rec.required
    ,p_rec.update_allowed
    ,p_rec.validation_formula_id
    ,p_rec.validation_parameter_item_id1
    ,p_rec.validation_parameter_item_id2
    ,p_rec.validation_parameter_item_id3
    ,p_rec.validation_parameter_item_id4
    ,p_rec.validation_parameter_item_id5
    ,p_rec.visible
    ,p_rec.width
    ,p_rec.x_position
    ,p_rec.y_position
    ,p_rec.information_category
    ,p_rec.information1
    ,p_rec.information2
    ,p_rec.information3
    ,p_rec.information4
    ,p_rec.information5
    ,p_rec.information6
    ,p_rec.information7
    ,p_rec.information8
    ,p_rec.information9
    ,p_rec.information10
    ,p_rec.information11
    ,p_rec.information12
    ,p_rec.information13
    ,p_rec.information14
    ,p_rec.information15
    ,p_rec.information16
    ,p_rec.information17
    ,p_rec.information18
    ,p_rec.information19
    ,p_rec.information20
    ,p_rec.information21
    ,p_rec.information22
    ,p_rec.information23
    ,p_rec.information24
    ,p_rec.information25
    ,p_rec.information26
    ,p_rec.information27
    ,p_rec.information28
    ,p_rec.information29
    ,p_rec.information30
    ,p_rec.next_navigation_item_id
    ,p_rec.previous_navigation_item_id
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_itp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_itp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_itp_shd.constraint_error
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
  (p_rec  in out nocopy hr_itp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select hr_item_properties_b_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.item_property_id;
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
  (p_effective_date               in date
  ,p_rec                          in hr_itp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_itp_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_item_property_id
      => p_rec.item_property_id
      ,p_form_item_id
      => p_rec.form_item_id
      ,p_template_item_id
      => p_rec.template_item_id
      ,p_template_item_context_id
      => p_rec.template_item_context_id
      ,p_alignment
      => p_rec.alignment
      ,p_bevel
      => p_rec.bevel
      ,p_case_restriction
      => p_rec.case_restriction
      ,p_enabled
      => p_rec.enabled
      ,p_format_mask
      => p_rec.format_mask
      ,p_height
      => p_rec.height
      ,p_information_formula_id
      => p_rec.information_formula_id
      ,p_information_param_item_id1
      => p_rec.information_parameter_item_id1
      ,p_information_param_item_id2
      => p_rec.information_parameter_item_id2
      ,p_information_param_item_id3
      => p_rec.information_parameter_item_id3
      ,p_information_param_item_id4
      => p_rec.information_parameter_item_id4
      ,p_information_param_item_id5
      => p_rec.information_parameter_item_id5
      ,p_insert_allowed
      => p_rec.insert_allowed
      ,p_prompt_alignment_offset
      => p_rec.prompt_alignment_offset
      ,p_prompt_display_style
      => p_rec.prompt_display_style
      ,p_prompt_edge
      => p_rec.prompt_edge
      ,p_prompt_edge_alignment
      => p_rec.prompt_edge_alignment
      ,p_prompt_edge_offset
      => p_rec.prompt_edge_offset
      ,p_prompt_text_alignment
      => p_rec.prompt_text_alignment
      ,p_query_allowed
      => p_rec.query_allowed
      ,p_required
      => p_rec.required
      ,p_update_allowed
      => p_rec.update_allowed
      ,p_validation_formula_id
      => p_rec.validation_formula_id
      ,p_validation_param_item_id1
      => p_rec.validation_parameter_item_id1
      ,p_validation_param_item_id2
      => p_rec.validation_parameter_item_id2
      ,p_validation_param_item_id3
      => p_rec.validation_parameter_item_id3
      ,p_validation_param_item_id4
      => p_rec.validation_parameter_item_id4
      ,p_validation_param_item_id5
      => p_rec.validation_parameter_item_id5
      ,p_visible
      => p_rec.visible
      ,p_width
      => p_rec.width
      ,p_x_position
      => p_rec.x_position
      ,p_y_position
      => p_rec.y_position
      ,p_information_category
      => p_rec.information_category
      ,p_information1
      => p_rec.information1
      ,p_information2
      => p_rec.information2
      ,p_information3
      => p_rec.information3
      ,p_information4
      => p_rec.information4
      ,p_information5
      => p_rec.information5
      ,p_information6
      => p_rec.information6
      ,p_information7
      => p_rec.information7
      ,p_information8
      => p_rec.information8
      ,p_information9
      => p_rec.information9
      ,p_information10
      => p_rec.information10
      ,p_information11
      => p_rec.information11
      ,p_information12
      => p_rec.information12
      ,p_information13
      => p_rec.information13
      ,p_information14
      => p_rec.information14
      ,p_information15
      => p_rec.information15
      ,p_information16
      => p_rec.information16
      ,p_information17
      => p_rec.information17
      ,p_information18
      => p_rec.information18
      ,p_information19
      => p_rec.information19
      ,p_information20
      => p_rec.information20
      ,p_information21
      => p_rec.information21
      ,p_information22
      => p_rec.information22
      ,p_information23
      => p_rec.information23
      ,p_information24
      => p_rec.information24
      ,p_information25
      => p_rec.information25
      ,p_information26
      => p_rec.information26
      ,p_information27
      => p_rec.information27
      ,p_information28
      => p_rec.information28
      ,p_information29
      => p_rec.information29
      ,p_information30
      => p_rec.information30
      ,p_next_navigation_item_id
      => p_rec.next_navigation_item_id
      ,p_previous_navigation_item_id
      => p_rec.previous_navigation_item_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_ITEM_PROPERTIES_B'
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy hr_itp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  hr_itp_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  hr_itp_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hr_itp_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hr_itp_ins.post_insert
     (p_effective_date
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
  (p_effective_date               in     date
  ,p_form_item_id                   in     number   default null
  ,p_template_item_id               in     number   default null
  ,p_template_item_context_id       in     number   default null
  ,p_alignment                      in     number   default null
  ,p_bevel                          in     number   default null
  ,p_case_restriction               in     number   default null
  ,p_enabled                        in     number   default null
  ,p_format_mask                    in     varchar2 default null
  ,p_height                         in     number   default null
  ,p_information_formula_id         in     number   default null
  ,p_information_param_item_id1     in     number   default null
  ,p_information_param_item_id2     in     number   default null
  ,p_information_param_item_id3     in     number   default null
  ,p_information_param_item_id4     in     number   default null
  ,p_information_param_item_id5     in     number   default null
  ,p_insert_allowed                 in     number   default null
  ,p_prompt_alignment_offset        in     number   default null
  ,p_prompt_display_style           in     number   default null
  ,p_prompt_edge                    in     number   default null
  ,p_prompt_edge_alignment          in     number   default null
  ,p_prompt_edge_offset             in     number   default null
  ,p_prompt_text_alignment          in     number   default null
  ,p_query_allowed                  in     number   default null
  ,p_required                       in     number   default null
  ,p_update_allowed                 in     number   default null
  ,p_validation_formula_id          in     number   default null
  ,p_validation_param_item_id1      in     number   default null
  ,p_validation_param_item_id2      in     number   default null
  ,p_validation_param_item_id3      in     number   default null
  ,p_validation_param_item_id4      in     number   default null
  ,p_validation_param_item_id5      in     number   default null
  ,p_visible                        in     number   default null
  ,p_width                          in     number   default null
  ,p_x_position                     in     number   default null
  ,p_y_position                     in     number   default null
  ,p_information_category           in     varchar2 default null
  ,p_information1                   in     varchar2 default null
  ,p_information2                   in     varchar2 default null
  ,p_information3                   in     varchar2 default null
  ,p_information4                   in     varchar2 default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     varchar2 default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
  ,p_next_navigation_item_id        in     number   default null
  ,p_previous_navigation_item_id    in     number   default null
  ,p_item_property_id           out nocopy number
  ,p_object_version_number      out nocopy number
  ) is
--
  l_rec   hr_itp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_itp_shd.convert_args
    (null
    ,p_object_version_number
    ,p_form_item_id
    ,p_template_item_id
    ,p_template_item_context_id
    ,p_alignment
    ,p_bevel
    ,p_case_restriction
    ,p_enabled
    ,p_format_mask
    ,p_height
    ,p_information_formula_id
    ,p_information_param_item_id1
    ,p_information_param_item_id2
    ,p_information_param_item_id3
    ,p_information_param_item_id4
    ,p_information_param_item_id5
    ,p_insert_allowed
    ,p_prompt_alignment_offset
    ,p_prompt_display_style
    ,p_prompt_edge
    ,p_prompt_edge_alignment
    ,p_prompt_edge_offset
    ,p_prompt_text_alignment
    ,p_query_allowed
    ,p_required
    ,p_update_allowed
    ,p_validation_formula_id
    ,p_validation_param_item_id1
    ,p_validation_param_item_id2
    ,p_validation_param_item_id3
    ,p_validation_param_item_id4
    ,p_validation_param_item_id5
    ,p_visible
    ,p_width
    ,p_x_position
    ,p_y_position
    ,p_information_category
    ,p_information1
    ,p_information2
    ,p_information3
    ,p_information4
    ,p_information5
    ,p_information6
    ,p_information7
    ,p_information8
    ,p_information9
    ,p_information10
    ,p_information11
    ,p_information12
    ,p_information13
    ,p_information14
    ,p_information15
    ,p_information16
    ,p_information17
    ,p_information18
    ,p_information19
    ,p_information20
    ,p_information21
    ,p_information22
    ,p_information23
    ,p_information24
    ,p_information25
    ,p_information26
    ,p_information27
    ,p_information28
    ,p_information29
    ,p_information30
    ,p_next_navigation_item_id
    ,p_previous_navigation_item_id
    );
  --
  -- Having converted the arguments into the hr_itp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hr_itp_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_item_property_id := l_rec.item_property_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end hr_itp_ins;

/
