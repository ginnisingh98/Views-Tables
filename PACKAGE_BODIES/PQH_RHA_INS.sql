--------------------------------------------------------
--  DDL for Package Body PQH_RHA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RHA_INS" as
/* $Header: pqrharhi.pkb 120.1 2005/08/03 13:43:25 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rha_ins.';  -- Global package name
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
  (p_rec in out nocopy pqh_rha_shd.g_rec_type
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
  -- Insert the row into: pqh_routing_hist_attribs
  --
  insert into pqh_routing_hist_attribs
      (routing_hist_attrib_id
      ,routing_history_id
      ,attribute_id
      ,from_char
      ,from_date
      ,from_number
      ,to_char
      ,to_date
      ,to_number
      ,object_version_number
      ,range_type_cd
      ,value_date
      ,value_number
      ,value_char
      )
  Values
    (p_rec.routing_hist_attrib_id
    ,p_rec.routing_history_id
    ,p_rec.attribute_id
    ,p_rec.from_char
    ,p_rec.from_date
    ,p_rec.from_number
    ,p_rec.to_char
    ,p_rec.to_date
    ,p_rec.to_number
    ,p_rec.object_version_number
    ,p_rec.range_type_cd
    ,p_rec.value_date
    ,p_rec.value_number
    ,p_rec.value_char
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_rha_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_rha_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_rha_shd.constraint_error
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
  (p_rec  in out nocopy pqh_rha_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_routing_hist_attribs_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.routing_hist_attrib_id;
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
  ,p_rec                          in pqh_rha_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_rha_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_routing_hist_attrib_id
      => p_rec.routing_hist_attrib_id
      ,p_routing_history_id
      => p_rec.routing_history_id
      ,p_attribute_id
      => p_rec.attribute_id
      ,p_from_char
      => p_rec.from_char
      ,p_from_date
      => p_rec.from_date
      ,p_from_number
      => p_rec.from_number
      ,p_to_char
      => p_rec.to_char
      ,p_to_date
      => p_rec.to_date
      ,p_to_number
      => p_rec.to_number
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_range_type_cd
      => p_rec.range_type_cd
      ,p_value_date
      => p_rec.value_date
      ,p_value_number
      => p_rec.value_number
      ,p_value_char
      => p_rec.value_char
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_ROUTING_HIST_ATTRIBS'
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
  ,p_rec                          in out nocopy pqh_rha_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_rha_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  pqh_rha_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqh_rha_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqh_rha_ins.post_insert
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
  ,p_routing_history_id             in     number
  ,p_attribute_id                   in     number
  ,p_from_char                      in     varchar2 default null
  ,p_from_date                      in     date     default null
  ,p_from_number                    in     number   default null
  ,p_to_char                        in     varchar2 default null
  ,p_to_date                        in     date     default null
  ,p_to_number                      in     number   default null
  ,p_range_type_cd                  in     varchar2 default null
  ,p_value_date                     in     date     default null
  ,p_value_number                   in     number   default null
  ,p_value_char                     in     varchar2 default null
  ,p_routing_hist_attrib_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec	  pqh_rha_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_rha_shd.convert_args
    (null
    ,p_routing_history_id
    ,p_attribute_id
    ,p_from_char
    ,p_from_date
    ,p_from_number
    ,p_to_char
    ,p_to_date
    ,p_to_number
    ,null
    ,p_range_type_cd
    ,p_value_date
    ,p_value_number
    ,p_value_char
    );
  --
  -- Having converted the arguments into the pqh_rha_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqh_rha_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_routing_hist_attrib_id := l_rec.routing_hist_attrib_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_rha_ins;

/
