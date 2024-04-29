--------------------------------------------------------
--  DDL for Package Body PER_PSE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSE_INS" as
/* $Header: pepserhi.pkb 120.0.12010000.2 2008/08/06 09:29:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pse_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_pos_structure_element_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_pos_structure_element_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_pse_ins.g_pos_structure_element_id_i := p_pos_structure_element_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
  (p_rec in out nocopy per_pse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_pse_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_pos_structure_elements
  --
  insert into per_pos_structure_elements
      (pos_structure_element_id
      ,business_group_id
      ,pos_structure_version_id
      ,subordinate_position_id
      ,parent_position_id
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,object_version_number
      )
  Values
    (p_rec.pos_structure_element_id
    ,p_rec.business_group_id
    ,p_rec.pos_structure_version_id
    ,p_rec.subordinate_position_id
    ,p_rec.parent_position_id
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,p_rec.object_version_number
    );
  --
  per_pse_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_pse_shd.g_api_dml := false;   -- Unset the api dml status
    per_pse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_pse_shd.g_api_dml := false;   -- Unset the api dml status
    per_pse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_pse_shd.g_api_dml := false;   -- Unset the api dml status
    per_pse_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_pse_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy per_pse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_pos_structure_elements_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pos_structure_element_id;
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
  (p_rec                          in per_pse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pse_rki.after_insert
      (p_pos_structure_element_id
      => p_rec.pos_structure_element_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_pos_structure_version_id
      => p_rec.pos_structure_version_id
      ,p_subordinate_position_id
      => p_rec.subordinate_position_id
      ,p_parent_position_id
      => p_rec.parent_position_id
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_POS_STRUCTURE_ELEMENTS'
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
  (p_rec                          in out nocopy per_pse_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_pse_bus.insert_validate
     (p_rec
     ,p_effective_date
     );
  --
  -- Call the supporting pre-insert operation
  --
  per_pse_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_pse_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_pse_ins.post_insert
     (p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_pos_structure_version_id       in     number
  ,p_subordinate_position_id        in     number
  ,p_parent_position_id             in     number
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_pos_structure_element_id          out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  per_pse_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_pse_shd.convert_args
    (null
    ,p_business_group_id
    ,p_pos_structure_version_id
    ,p_subordinate_position_id
    ,p_parent_position_id
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,null
    );
  --
  -- Having converted the arguments into the per_pse_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_pse_ins.ins
     (l_rec
     ,p_effective_date
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pos_structure_element_id := l_rec.pos_structure_element_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_pse_ins;

/
