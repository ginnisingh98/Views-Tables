--------------------------------------------------------
--  DDL for Package Body PQH_RNG_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RNG_INS" as
/* $Header: pqrngrhi.pkb 115.18 2004/06/24 16:51:43 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rng_ins.';  -- Global package name
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
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy pqh_rng_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_attribute_ranges
  --
  insert into pqh_attribute_ranges
  (	attribute_range_id,
	approver_flag,
	enable_flag,
	delete_flag,
	assignment_id,
	attribute_id,
	from_char,
	from_date,
	from_number,
	position_id,
	range_name,
	routing_category_id,
	routing_list_member_id,
	to_char,
	to_date,
	to_number,
	object_version_number
  )
  Values
  (	p_rec.attribute_range_id,
	p_rec.approver_flag,
	p_rec.enable_flag,
	p_rec.delete_flag,
	p_rec.assignment_id,
	p_rec.attribute_id,
	p_rec.from_char,
	p_rec.from_date,
	p_rec.from_number,
	p_rec.position_id,
	p_rec.range_name,
	p_rec.routing_category_id,
	p_rec.routing_list_member_id,
	p_rec.to_char,
	p_rec.to_date,
	p_rec.to_number,
	p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_rng_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_rng_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_rng_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_insert(p_rec  in out nocopy pqh_rng_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_attribute_ranges_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.attribute_range_id;
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
Procedure post_insert(
p_effective_date in date,p_rec in pqh_rng_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pqh_rng_rki.after_insert
      (
  p_attribute_range_id            =>p_rec.attribute_range_id
 ,p_approver_flag                 =>p_rec.approver_flag
 ,p_enable_flag                 =>p_rec.enable_flag
 ,p_delete_flag                 =>p_rec.delete_flag
 ,p_assignment_id                 =>p_rec.assignment_id
 ,p_attribute_id                  =>p_rec.attribute_id
 ,p_from_char                     =>p_rec.from_char
 ,p_from_date                     =>p_rec.from_date
 ,p_from_number                   =>p_rec.from_number
 ,p_position_id                   =>p_rec.position_id
 ,p_range_name                    =>p_rec.range_name
 ,p_routing_category_id           =>p_rec.routing_category_id
 ,p_routing_list_member_id        =>p_rec.routing_list_member_id
 ,p_to_char                       =>p_rec.to_char
 ,p_to_date                       =>p_rec.to_date
 ,p_to_number                     =>p_rec.to_number
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_attribute_ranges'
        ,p_hook_type   => 'AI');
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
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_rec        in out nocopy pqh_rng_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_rng_bus.insert_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(
p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_attribute_range_id           out nocopy number,
  p_approver_flag                in varchar2         default null,
  p_enable_flag                  in varchar2         default 'Y',
  p_delete_flag                  in varchar2         default null,
  p_assignment_id                in number           default null,
  p_attribute_id                 in number           default null,
  p_from_char                    in varchar2         default null,
  p_from_date                    in date             default null,
  p_from_number                  in number           default null,
  p_position_id                  in number           default null,
  p_range_name                   in varchar2,
  p_routing_category_id          in number,
  p_routing_list_member_id       in number           default null,
  p_to_char                      in varchar2         default null,
  p_to_date                      in date             default null,
  p_to_number                    in number           default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  pqh_rng_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_rng_shd.convert_args
  (
  null,
  p_approver_flag,
  p_enable_flag,
  p_delete_flag,
  p_assignment_id,
  p_attribute_id,
  p_from_char,
  p_from_date,
  p_from_number,
  p_position_id,
  p_range_name,
  p_routing_category_id,
  p_routing_list_member_id,
  p_to_char,
  p_to_date,
  p_to_number,
  null
  );
  --
  -- Having converted the arguments into the pqh_rng_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_attribute_range_id := l_rec.attribute_range_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_rng_ins;

/
