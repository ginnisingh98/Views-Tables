--------------------------------------------------------
--  DDL for Package Body PER_BIL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BIL_INS" as
/* $Header: pebilrhi.pkb 115.10 2003/04/10 09:19:39 jheer noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bil_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy per_bil_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_bil_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: hr_summary
  --
  insert into hr_summary
  (	type,
	business_group_id,
	object_version_number,
	id_value,
	fk_value1,
	fk_value2,
	fk_value3,
	text_value1,
	text_value2,
	text_value3,
	text_value4,
	text_value5,
	text_value6,
        text_value7,
	num_value1,
	num_value2,
	num_value3,
	date_value1,
	date_value2,
	date_value3
  )
  Values
  (	p_rec.type,
	p_rec.business_group_id,
	p_rec.object_version_number,
	p_rec.id_value,
	p_rec.fk_value1,
	p_rec.fk_value2,
	p_rec.fk_value3,
	p_rec.text_value1,
	p_rec.text_value2,
	p_rec.text_value3,
	p_rec.text_value4,
	p_rec.text_value5,
	p_rec.text_value6,
	p_rec.text_value7,
	p_rec.num_value1,
	p_rec.num_value2,
	p_rec.num_value3,
	p_rec.date_value1,
	p_rec.date_value2,
	p_rec.date_value3
  );
  --
  per_bil_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_bil_shd.g_api_dml := false;   -- Unset the api dml status
    per_bil_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_bil_shd.g_api_dml := false;   -- Unset the api dml status
    per_bil_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_bil_shd.g_api_dml := false;   -- Unset the api dml status
    per_bil_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_bil_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy per_bil_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select hr_summary_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.id_value;
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
Procedure post_insert(p_rec in per_bil_shd.g_rec_type) is
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
/*
 per_bil_rki.after_insert
      (
  p_type                          =>p_rec.type
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_id_value                      =>p_rec.id_value
 ,p_fk_value1                     =>p_rec.fk_value1
 ,p_fk_value2                     =>p_rec.fk_value2
 ,p_fk_value3                     =>p_rec.fk_value3
 ,p_text_value1                   =>p_rec.text_value1
 ,p_text_value2                   =>p_rec.text_value2
 ,p_text_value3                   =>p_rec.text_value3
 ,p_text_value4                   =>p_rec.text_value4
 ,p_text_value5                   =>p_rec.text_value5
 ,p_text_value6                   =>p_rec.text_value6
 ,p_text_value7                   =>p_rec.text_value7
 ,p_num_value1                    =>p_rec.num_value1
 ,p_num_value2                    =>p_rec.num_value2
 ,p_num_value3                    =>p_rec.num_value3
 ,p_date_value1                   =>p_rec.date_value1
 ,p_date_value2                   =>p_rec.date_value2
 ,p_date_value3                   =>p_rec.date_value3
      );
*/
null;
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'hr_summary'
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
  p_rec        in out nocopy per_bil_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_bil_bus.insert_validate(p_rec);
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
  post_insert(p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_type                         in varchar2         default null,
  p_business_group_id            in number           default null,
  p_object_version_number        out nocopy number,
  p_id_value                     out nocopy number,
  p_fk_value1                    in number           default null,
  p_fk_value2                    in number           default null,
  p_fk_value3                    in number           default null,
  p_text_value1                  in varchar2         default null,
  p_text_value2                  in varchar2         default null,
  p_text_value3                  in varchar2         default null,
  p_text_value4                  in varchar2         default null,
  p_text_value5                  in varchar2         default null,
  p_text_value6                  in varchar2         default null,
  p_text_value7                  in varchar2         default null,
  p_num_value1                   in number           default null,
  p_num_value2                   in number           default null,
  p_num_value3                   in number           default null,
  p_date_value1                  in date             default null,
  p_date_value2                  in date             default null,
  p_date_value3                  in date             default null
  ) is
--
  l_rec	  per_bil_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_bil_shd.convert_args
  (
  p_type,
  p_business_group_id,
  null,
  null,
  p_fk_value1,
  p_fk_value2,
  p_fk_value3,
  p_text_value1,
  p_text_value2,
  p_text_value3,
  p_text_value4,
  p_text_value5,
  p_text_value6,
  p_text_value7,
  p_num_value1,
  p_num_value2,
  p_num_value3,
  p_date_value1,
  p_date_value2,
  p_date_value3
  );
  --
  -- Having converted the arguments into the per_bil_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_id_value := l_rec.id_value;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_bil_ins;

/