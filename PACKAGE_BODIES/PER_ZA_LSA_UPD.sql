--------------------------------------------------------
--  DDL for Package Body PER_ZA_LSA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_LSA_UPD" as
/* $Header: pezalsup.pkb 115.1 2002/12/05 06:51:01 nsugavan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_lsa_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy per_za_lsa_shd.g_za_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  --
  per_za_lsa_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_za_assessments Row
  --
  update per_za_learnership_agreements
  set
    agreement_id           = p_rec.agreement_id,
	name				   = p_rec.name,
	description			   = p_rec.description,
	agreement_number	   = p_rec.agreement_number,
  	person_id 			   = p_rec.person_id,
	agreement_start_date   = p_rec.agreement_start_date,
	agreement_end_date	   = p_rec.agreement_end_date,
	status				   = p_rec.status,
	seta				   = p_rec.seta,
	probationary_end_date  = p_rec.probationary_end_date,
	terminated_by		   = p_rec.terminated_by,
	learner_type		   = p_rec.learner_type,
	reason_for_termination = p_rec.reason_for_termination,
	actual_end_date		   = p_rec.actual_end_date,
	agreement_hard_copy_id = p_rec.agreement_hard_copy_id
  where agreement_id = p_rec.agreement_id;
  --
  per_za_lsa_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_za_lsa_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_lsa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_za_lsa_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_lsa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_za_lsa_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_lsa_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_za_lsa_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in per_za_lsa_shd.g_za_rec_type) is
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
Procedure post_update(p_rec in per_za_lsa_shd.g_za_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec            in out nocopy per_za_lsa_shd.g_za_rec_type,
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
  per_za_lsa_shd.lck
	(
	p_rec.agreement_id,
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
  	p_agreement_id           in number,
	p_validate				 in	boolean	 default false,
	p_name					 in varchar2 default null,
	p_description			 in varchar2 default null,
	p_agreement_number		 in varchar2 default null,
  	p_person_id              in number,
	p_agreement_start_date   in date     default null,
	p_agreement_end_date     in date 	 default null,
	p_status				 in varchar2 default null,
	p_seta					 in varchar2 default null,
	p_probationary_end_date	 in date 	 default null,
	p_terminated_by			 in varchar2 default null,
	p_learner_type			 in varchar2 default null,
	p_reason_for_termination in varchar2 default null,
	p_actual_end_date		 in date	 default null,
	p_agreement_hard_copy_id in number	 default null) IS
--
  l_rec	  per_za_lsa_shd.g_za_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_za_lsa_shd.convert_args
  (
  	p_agreement_id,
  	p_person_id,
	p_name,
	p_description,
	p_agreement_number,
	p_agreement_start_date,
	p_agreement_end_date,
	p_status,
	p_seta,
	p_probationary_end_date,
	p_terminated_by,
	p_learner_type,
	p_reason_for_termination,
	p_actual_end_date,
	p_agreement_hard_copy_id
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
end per_za_lsa_upd;

/
