--------------------------------------------------------
--  DDL for Package Body GHR_PDC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDC_INS" as
/* $Header: ghpdcrhi.pkb 120.0.12010000.3 2009/05/27 05:40:10 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= 'ghr_pdc_ins';  -- Global package name
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
--   A Pl/Sql record structure.
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
Procedure insert_dml(p_rec in out NOCOPY ghr_pdc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --ghr_pdc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ghr_pd_classifications
  --
  insert into ghr_pd_classifications
  (	pd_classification_id,
	position_description_id,
	class_grade_by,
	official_title,
	pay_plan,
	occupational_code,
	grade_level,
	object_version_number
  )
  Values
  (	p_rec.pd_classification_id,
	p_rec.position_description_id,
	p_rec.class_grade_by,
	p_rec.official_title,
	p_rec.pay_plan,
	p_rec.occupational_code,
	p_rec.grade_level,
	p_rec.object_version_number
  );
  --
  --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out NOCOPY ghr_pdc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ghr_pd_classifications_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pd_classification_id;
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ghr_pdc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ghr_pdc_rki.after_insert	(
      p_pd_classification_id     =>     p_rec.pd_classification_id,
      p_position_description_id  =>     p_rec.position_description_id,
      p_class_grade_by           =>     p_rec.class_grade_by,
      p_official_title           =>     p_rec.official_title,
      p_pay_plan                 =>     p_rec.pay_plan,
      p_occupational_code        =>     p_rec.occupational_code,
      p_grade_level              =>     p_rec.grade_level,
      p_object_version_number    =>     p_rec.object_version_number
      );
  exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	 p_module_name => 'GHR_PD_CLASSIFICATIONS'
			,p_hook_type   => 'AI'
	        );
  end;
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out NOCOPY ghr_pdc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ghr_pdc_bus.insert_validate(p_rec);
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
  p_pd_classification_id         out NOCOPY number,
  p_position_description_id      in number,
  p_class_grade_by               in varchar2,
  p_official_title               in varchar2         default null,
  p_pay_plan                     in varchar2         default null,
  p_occupational_code            in varchar2         default null,
  p_grade_level                  in varchar2         default null,
  p_object_version_number        out NOCOPY number
  ) is
--
  l_rec	  ghr_pdc_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
-- Class Grade by
	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'Class Grade By',
         	p_argument_value => p_class_grade_by
		);
-- Official Title
	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'Position Title',
         	p_argument_value => p_official_title
		);
-- Pay plan
	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'Pay Plan',
         	p_argument_value => p_pay_plan
		);
-- Occ Code
	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'Occupational Series',
         	p_argument_value => p_occupational_code
		);
-- Grade or Level
	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'Grade',
         	p_argument_value => p_grade_level
		);
  l_rec :=
  ghr_pdc_shd.convert_args
  (
  null,
  p_position_description_id,
  p_class_grade_by,
  p_official_title,
  p_pay_plan,
  p_occupational_code,
  p_grade_level,
  null
  );
  --
  -- Having converted the arguments into the ghr_pdc_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pd_classification_id := l_rec.pd_classification_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ghr_pdc_ins;

/