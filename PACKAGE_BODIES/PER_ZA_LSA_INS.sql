--------------------------------------------------------
--  DDL for Package Body PER_ZA_LSA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_LSA_INS" as
/* $Header: pezalsin.pkb 115.1 2002/12/05 06:50:18 nsugavan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_lsa_ins.';  -- Global package name
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy per_za_lsa_shd.g_za_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  per_za_lsa_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_za_assessments
  --
  insert into per_za_learnership_agreements(
    AGREEMENT_ID,
    NAME,
    DESCRIPTION,
    AGREEMENT_NUMBER,
    PERSON_ID,
    AGREEMENT_START_DATE,
    AGREEMENT_END_DATE,
    STATUS,
    SETA,
    PROBATIONARY_END_DATE,
    TERMINATED_BY,
    LEARNER_TYPE,
    REASON_FOR_TERMINATION,
    ACTUAL_END_DATE,
    AGREEMENT_HARD_COPY_ID
  )
  Values
  (
    p_rec.AGREEMENT_ID,
    p_rec.NAME,
    p_rec.DESCRIPTION,
    p_rec.AGREEMENT_NUMBER,
    p_rec.PERSON_ID,
    p_rec.AGREEMENT_START_DATE,
    p_rec.AGREEMENT_END_DATE,
    p_rec.STATUS,
    p_rec.SETA,
    p_rec.PROBATIONARY_END_DATE,
    p_rec.TERMINATED_BY,
    p_rec.LEARNER_TYPE,
    p_rec.REASON_FOR_TERMINATION,
    p_rec.ACTUAL_END_DATE,
    p_rec.AGREEMENT_HARD_COPY_ID
  );
  --
  per_za_lsa_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
End insert_dml;

-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in per_za_lsa_shd.g_za_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec            in out nocopy per_za_lsa_shd.g_za_rec_type,
  p_validate       in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
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
    SAVEPOINT ins_lsa;
  End If;

  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec);
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
    ROLLBACK TO ins_lsa;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
   (p_agreement_id             	in number,
    p_validate					in boolean  default FALSE,
	p_name						in varchar2 default null,
	p_description				in varchar2 default null,
	p_agreement_number			in varchar2 default null,
  	p_person_id             	in number,
	p_agreement_start_date		in date		default null,
	p_agreement_end_date		in date		default null,
	p_status					in varchar2 default null,
	p_seta						in varchar2 default null,
	p_probationary_end_date		in date		default null,
	p_terminated_by				in varchar2 default null,
	p_learner_type				in varchar2 default null,
	p_reason_for_termination	in varchar2 default null,
	p_actual_end_date			in date		default null,
	p_agreement_hard_copy_id	in number 	default null) IS
--
  l_rec	  	per_za_lsa_shd.g_za_rec_type;
  l_proc  	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
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
  -- Having converted the arguments into the ass_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_za_lsa_ins;

/
