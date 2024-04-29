--------------------------------------------------------
--  DDL for Package Body PAY_PTA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PTA_INS" as
/* $Header: pyptarhi.pkb 120.0 2005/05/29 07:56:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pta_ins.';  -- Global package name
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
  (p_rec in out nocopy pay_pta_shd.g_rec_type
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
  -- Insert the row into: pay_dated_tables
  --
  insert into pay_dated_tables
      (dated_table_id
      ,table_name
      ,application_id
      ,surrogate_key_name
      ,start_date_name
      ,end_date_name
      ,business_group_id
      ,legislation_code
      ,object_version_number
      ,dyn_trigger_type
      ,dyn_trigger_package_name
      ,dyn_trig_pkg_generated
      )
  Values
    (p_rec.dated_table_id
    ,p_rec.table_name
    ,p_rec.application_id
    ,p_rec.surrogate_key_name
    ,p_rec.start_date_name
    ,p_rec.end_date_name
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    ,p_rec.object_version_number
    ,p_rec.dyn_trigger_type
    ,p_rec.dyn_trigger_package_name
    ,p_rec.dyn_trig_pkg_generated
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_pta_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_pta_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_pta_shd.constraint_error
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
  (p_rec  in out nocopy pay_pta_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_dated_tables_s.nextval from sys.dual;
--
  Cursor C_Sel2 is select application_id
                     from fnd_tables where table_name = p_rec.table_name;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.dated_table_id;
  Close C_Sel1;
  --
  if p_rec.application_id is null then
  Open C_Sel2;
  Fetch C_Sel2 Into p_rec.application_id;
  Close C_Sel2;
  end if;
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
  (p_rec                          in pay_pta_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_pta_rki.after_insert
      (p_dated_table_id
      => p_rec.dated_table_id
      ,p_table_name
      => p_rec.table_name
      ,p_application_id
      => p_rec.application_id
      ,p_surrogate_key_name
      => p_rec.surrogate_key_name
      ,p_start_date_name
      => p_rec.start_date_name
      ,p_end_date_name
      => p_rec.end_date_name
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_dyn_trigger_type
      => p_rec.dyn_trigger_type
      ,p_dyn_trigger_package_name
      => p_rec.dyn_trigger_package_name
      ,p_dyn_trig_pkg_generated
      => p_rec.dyn_trig_pkg_generated
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_DATED_TABLES'
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
  (p_rec                          in out nocopy pay_pta_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_pta_bus.insert_validate
     (p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  pay_pta_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_pta_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_pta_ins.post_insert
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
  (p_table_name                     in     varchar2
  ,p_application_id                 in     number   default null
  ,p_surrogate_key_name             in     varchar2
  ,p_start_date_name                in     varchar2
  ,p_end_date_name                  in     varchar2
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_dated_table_id                    out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_dyn_trigger_type               in     varchar2 default null
  ,p_dyn_trigger_package_name       in     varchar2 default null
  ,p_dyn_trig_pkg_generated         in     varchar2 default null
  ) is
--
  l_rec	  pay_pta_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_pta_shd.convert_args
    (null
    ,p_table_name
    ,p_application_id
    ,p_surrogate_key_name
    ,p_start_date_name
    ,p_end_date_name
    ,p_business_group_id
    ,p_legislation_code
    ,null
    ,p_dyn_trigger_type
    ,p_dyn_trigger_package_name
    ,p_dyn_trig_pkg_generated
    );
  --
  -- Having converted the arguments into the pay_pta_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_pta_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_dated_table_id := l_rec.dated_table_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_pta_ins;

/
