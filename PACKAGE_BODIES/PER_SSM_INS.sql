--------------------------------------------------------
--  DDL for Package Body PER_SSM_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSM_INS" as
/* $Header: pessmrhi.pkb 120.0 2005/05/31 21:50:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ssm_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy per_ssm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_ssm_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_salary_survey_mappings
  --
  insert into per_salary_survey_mappings
  (	object_version_number,
	salary_survey_mapping_id,
	parent_id,
	parent_table_name,
	salary_survey_line_id,
	business_group_id,
	location_id,
	grade_id,
	company_organization_id,
	company_age_code,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20
  )
  Values
  (	p_rec.object_version_number,
	p_rec.salary_survey_mapping_id,
	p_rec.parent_id,
	p_rec.parent_table_name,
	p_rec.salary_survey_line_id,
	p_rec.business_group_id,
	p_rec.location_id,
	p_rec.grade_id,
	p_rec.company_organization_id,
	p_rec.company_age_code,
	p_rec.attribute_category,
	p_rec.attribute1,
	p_rec.attribute2,
	p_rec.attribute3,
	p_rec.attribute4,
	p_rec.attribute5,
	p_rec.attribute6,
	p_rec.attribute7,
	p_rec.attribute8,
	p_rec.attribute9,
	p_rec.attribute10,
	p_rec.attribute11,
	p_rec.attribute12,
	p_rec.attribute13,
	p_rec.attribute14,
	p_rec.attribute15,
	p_rec.attribute16,
	p_rec.attribute17,
	p_rec.attribute18,
	p_rec.attribute19,
	p_rec.attribute20
  );
  --
  per_ssm_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hr_utility.set_location(l_proc, 6);
    per_ssm_shd.g_api_dml := false;   -- Unset the api dml status
    per_ssm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
  hr_utility.set_location(l_proc, 7);
    -- Parent integrity has been violated
    per_ssm_shd.g_api_dml := false;   -- Unset the api dml status
    per_ssm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
  hr_utility.set_location(l_proc, 8);
    -- Unique integrity has been violated
    per_ssm_shd.g_api_dml := false;   -- Unset the api dml status
    per_ssm_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
  hr_utility.set_location(l_proc, 9);
    per_ssm_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy per_ssm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_salary_survey_mappings_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.salary_survey_mapping_id;
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
Procedure post_insert(p_rec            in per_ssm_shd.g_rec_type,
                      p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  begin
    per_ssm_rki.after_insert
    (
    p_object_version_number        => p_rec.object_version_number,
    p_salary_survey_mapping_id     => p_rec.salary_survey_mapping_id ,
    p_parent_id                    => p_rec.parent_id,
    p_parent_table_name            => p_rec.parent_table_name,
    p_salary_survey_line_id        => p_rec.salary_survey_line_id,
    p_business_group_id            => p_rec.business_group_id,
    p_location_id                  => p_rec.location_id,
    p_grade_id                     => p_rec.grade_id,
    p_company_organization_id      => p_rec.company_organization_id,
    p_company_age_code             => p_rec.company_age_code,
    p_attribute_category           => p_rec.attribute_category,
    p_attribute1                   => p_rec.attribute1,
    p_attribute2                   => p_rec.attribute2,
    p_attribute3                   => p_rec.attribute3,
    p_attribute4                   => p_rec.attribute4,
    p_attribute5                   => p_rec.attribute5,
    p_attribute6                   => p_rec.attribute6,
    p_attribute7                   => p_rec.attribute7,
    p_attribute8                   => p_rec.attribute8,
    p_attribute9                   => p_rec.attribute9,
    p_attribute10                  => p_rec.attribute10,
    p_attribute11                  => p_rec.attribute11,
    p_attribute12                  => p_rec.attribute12,
    p_attribute13                  => p_rec.attribute13,
    p_attribute14                  => p_rec.attribute14,
    p_attribute15                  => p_rec.attribute15,
    p_attribute16                  => p_rec.attribute16,
    p_attribute17                  => p_rec.attribute17,
    p_attribute18                  => p_rec.attribute18,
    p_attribute19                  => p_rec.attribute19,
    p_attribute20                  => p_rec.attribute20,
    p_effective_date		   => p_effective_date
    );
  --
  exception
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
	(p_module_name => 'PER_SALARY_SURVEY_MAPPINGS'
	,p_hook_type   => 'AI'
	);
  end;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec            in out nocopy per_ssm_shd.g_rec_type,
  p_effective_date in     date
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_ssm_bus.insert_validate(p_rec, p_effective_date);
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
  post_insert(p_rec,p_effective_date);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_object_version_number        out nocopy number,
  p_salary_survey_mapping_id     out nocopy number,
  p_parent_id                    in number,
  p_parent_table_name            in varchar2,
  p_salary_survey_line_id        in number,
  p_business_group_id            in number,
  p_location_id                  in number           default null,
  p_grade_id                     in number           default null,
  p_company_organization_id      in number           default null,
  p_company_age_code             in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_effective_date		 in date
  ) is
--
  l_rec	  per_ssm_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_ssm_shd.convert_args
  (
  null,
  null,
  p_parent_id,
  p_parent_table_name,
  p_salary_survey_line_id,
  p_business_group_id,
  p_location_id,
  p_grade_id,
  p_company_organization_id,
  p_company_age_code,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20
  );
  --
  -- Having converted the arguments into the per_ssm_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_salary_survey_mapping_id := l_rec.salary_survey_mapping_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_ssm_ins;

/