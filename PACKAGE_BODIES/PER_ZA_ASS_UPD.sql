--------------------------------------------------------
--  DDL for Package Body PER_ZA_ASS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_ASS_UPD" as
/* $Header: pezaasup.pkb 115.1 2002/12/05 06:49:48 nsugavan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_ass_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy per_za_ass_shd.g_za_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  --
  per_za_ass_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_za_assessments Row
  --
  update per_za_assessments
  set
	assessment_id 		      = p_rec.assessment_id,
  	person_id 				  = p_rec.person_id,
  	level_id				  = p_rec.level_id,
  	name_of_assessor		  = p_rec.name_of_assessor,
  	institution				  = p_rec.institution,
  	credit					  = p_rec.credit,
  	date_of_assessment		  = p_rec.date_of_assessment,
  	final_result			  = p_rec.final_result,
  	assessment_number		  = p_rec.assessment_number,
  	location_where_assessed	  = p_rec.location_where_assessed,
  	field_of_learning		  = p_rec.field_of_learning,
	sub_field				  = p_rec.sub_field,
	assessment_start_date 	  = p_rec.assessment_start_date,
	assessment_end_date 	  = p_rec.assessment_end_date,
	competence_acquired 	  = p_rec.competence_acquired,
	ETQA_name 				  = p_rec.ETQA_name,
	certification_date 		  = p_rec.certification_date,
	certificate_number		  = p_rec.certificate_number,
	accredited_by 			  = p_rec.accredited_by,
	date_of_accreditation     = p_rec.date_of_accreditation,
	certification_expiry_date = p_rec.certification_expiry_date
  where assessment_id 		  = p_rec.assessment_id;
  --
  per_za_ass_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_za_ass_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_ass_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_za_ass_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_ass_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_za_ass_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_ass_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_za_ass_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in per_za_ass_shd.g_za_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in per_za_ass_shd.g_za_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec            in out nocopy per_za_ass_shd.g_za_rec_type,
  p_validate       in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_ass;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_za_ass_shd.lck
	(
	p_rec.assessment_id,
	p_rec.person_id
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
--  convert_defs(p_rec);
--  per_za_ass_bus.update_validate(p_rec,p_effective_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_ass;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  	p_assessment_id             in number,
  	p_person_id             	in number,
  	p_level_id             		in number   default null,
  	p_name_of_assessor 			in varchar2,
  	p_institution 				in varchar2 default null,
  	p_credit             		in number   default null,
  	p_date_of_assessment 		in date 	default null,
  	p_final_result 				in varchar2 default null,
  	p_assessment_number			in varchar2 default null,
  	p_location_where_assessed	in varchar2 default null,
  	p_field_of_learning 		in varchar2 default null,
	p_sub_field					in varchar2 default null,
	p_assessment_start_date 	in date 	default null,
	p_assessment_end_date 		in date 	default null,
	p_competence_acquired 		in varchar2 default null,
	p_ETQA_name 				in varchar2 default null,
	p_certification_date 		in date 	default null,
	p_certificate_number		in varchar2 default null,
	p_accredited_by 			in varchar2 default null,
	p_date_of_accreditation 	in date 	default null,
	p_certification_expiry_date in date 	default null,
	p_validate					in	boolean	default false
  ) is
--
  l_rec	  per_za_ass_shd.g_za_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_za_ass_shd.convert_args
  (
  	p_assessment_id,
  	p_person_id ,
  	p_level_id,
  	p_name_of_assessor ,
  	p_institution,
  	p_credit ,
  	p_date_of_assessment ,
  	p_final_result,
  	p_assessment_number,
  	p_location_where_assessed,
  	p_field_of_learning,
	p_sub_field,
	p_assessment_start_date,
	p_assessment_end_date,
	p_competence_acquired,
	p_ETQA_name,
	p_certification_date,
	p_certificate_number,
	p_accredited_by,
	p_date_of_accreditation,
	p_certification_expiry_date
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_za_ass_upd;

/
