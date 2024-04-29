--------------------------------------------------------
--  DDL for Package Body PER_RET_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RET_INS" as
/* $Header: peretrhi.pkb 115.1 2002/12/06 11:29:20 eumenyio noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ret_ins.';  -- Global package name
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
  (p_rec in out nocopy per_ret_shd.g_rec_type
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
  -- Insert the row into: per_cagr_retained_rights
  --
  insert into per_cagr_retained_rights
      (cagr_retained_right_id
      ,assignment_id
      ,cagr_entitlement_item_id
      ,collective_agreement_id
      ,cagr_entitlement_id
      ,category_name
      ,element_type_id
      ,input_value_id
      ,cagr_api_id
      ,cagr_api_param_id
      ,cagr_entitlement_line_id
      ,freeze_flag
      ,value
      ,units_of_measure
      ,start_date
      ,end_date
      ,parent_spine_id
      ,formula_id
      ,oipl_id
      ,step_id
      ,grade_spine_id
      ,column_type
      ,column_size
      ,eligy_prfl_id
      ,object_version_number
      ,cagr_entitlement_result_id
      ,business_group_id
      ,flex_value_set_id
      )
  Values
    (p_rec.cagr_retained_right_id
    ,p_rec.assignment_id
    ,p_rec.cagr_entitlement_item_id
    ,p_rec.collective_agreement_id
    ,p_rec.cagr_entitlement_id
    ,p_rec.category_name
    ,p_rec.element_type_id
    ,p_rec.input_value_id
    ,p_rec.cagr_api_id
    ,p_rec.cagr_api_param_id
    ,p_rec.cagr_entitlement_line_id
    ,p_rec.freeze_flag
    ,p_rec.value
    ,p_rec.units_of_measure
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.parent_spine_id
    ,p_rec.formula_id
    ,p_rec.oipl_id
    ,p_rec.step_id
    ,p_rec.grade_spine_id
    ,p_rec.column_type
    ,p_rec.column_size
    ,p_rec.eligy_prfl_id
    ,p_rec.object_version_number
    ,p_rec.cagr_entitlement_result_id
    ,p_rec.business_group_id
    ,p_rec.flex_value_set_id
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_ret_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_ret_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_ret_shd.constraint_error
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
  (p_rec  in out nocopy per_ret_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_cagr_retained_rights_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.cagr_retained_right_id;
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
--   This private procedure contains any processing which is required after
--   the insert dml.
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
  ,p_rec                          in per_ret_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
/*
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_ret_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_cagr_retained_right_id
      => p_rec.cagr_retained_right_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_cagr_entitlement_item_id
      => p_rec.cagr_entitlement_item_id
      ,p_collective_agreement_id
      => p_rec.collective_agreement_id
      ,p_cagr_entitlement_id
      => p_rec.cagr_entitlement_id
      ,p_category_name
      => p_rec.category_name
      ,p_element_type_id
      => p_rec.element_type_id
      ,p_input_value_id
      => p_rec.input_value_id
      ,p_cagr_api_id
      => p_rec.cagr_api_id
      ,p_cagr_api_param_id
      => p_rec.cagr_api_param_id
      ,p_cagr_entitlement_line_id
      => p_rec.cagr_entitlement_line_id
      ,p_freeze_flag
      => p_rec.freeze_flag
      ,p_value
      => p_rec.value
      ,p_units_of_measure
      => p_rec.units_of_measure
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_parent_spine_id
      => p_rec.parent_spine_id
      ,p_formula_id
      => p_rec.formula_id
      ,p_oipl_id
      => p_rec.oipl_id
      ,p_step_id
      => p_rec.step_id
      ,p_grade_spine_id
      => p_rec.grade_spine_id
      ,p_column_type
      => p_rec.column_type
      ,p_column_size
      => p_rec.column_size
      ,p_eligy_prfl_id
      => p_rec.eligy_prfl_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_cagr_entitlement_result_id
      => p_rec.cagr_entitlement_result_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_flex_value_set_id
      => p_rec.flex_value_set_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CAGR_RETAINED_RIGHTS'
        ,p_hook_type   => 'AI');
      --
  end;
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_ret_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_ret_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  per_ret_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_ret_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_ret_ins.post_insert
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
  ,p_assignment_id                  in     number
  ,p_cagr_entitlement_item_id       in     number
  ,p_collective_agreement_id        in     number
  ,p_cagr_entitlement_id            in     number
  ,p_category_name                  in     varchar2
  ,p_element_type_id                in     number   default null
  ,p_input_value_id                 in     number   default null
  ,p_cagr_api_id                    in     number   default null
  ,p_cagr_api_param_id              in     number   default null
  ,p_cagr_entitlement_line_id       in     number   default null
  ,p_freeze_flag                    in     varchar2 default null
  ,p_value                          in     varchar2 default null
  ,p_units_of_measure               in     varchar2 default null
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_parent_spine_id                in     number   default null
  ,p_formula_id                     in     number   default null
  ,p_oipl_id                        in     number   default null
  ,p_step_id                        in     number   default null
  ,p_grade_spine_id                 in     number   default null
  ,p_column_type                    in     varchar2 default null
  ,p_column_size                    in     number   default null
  ,p_eligy_prfl_id                  in     number   default null
  ,p_cagr_entitlement_result_id     in     number   default null
  ,p_business_group_id              in     number   default null
  ,p_flex_value_set_id              in     number   default null
  ,p_cagr_retained_right_id           out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   per_ret_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_ret_shd.convert_args
    (null
    ,p_assignment_id
    ,p_cagr_entitlement_item_id
    ,p_collective_agreement_id
    ,p_cagr_entitlement_id
    ,p_category_name
    ,p_element_type_id
    ,p_input_value_id
    ,p_cagr_api_id
    ,p_cagr_api_param_id
    ,p_cagr_entitlement_line_id
    ,p_freeze_flag
    ,p_value
    ,p_units_of_measure
    ,p_start_date
    ,p_end_date
    ,p_parent_spine_id
    ,p_formula_id
    ,p_oipl_id
    ,p_step_id
    ,p_grade_spine_id
    ,p_column_type
    ,p_column_size
    ,p_eligy_prfl_id
    ,null
    ,p_cagr_entitlement_result_id
    ,p_business_group_id
    ,p_flex_value_set_id
    );
  --
  -- Having converted the arguments into the per_ret_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_ret_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_cagr_retained_right_id := l_rec.cagr_retained_right_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_ret_ins;

/
