--------------------------------------------------------
--  DDL for Package Body PER_ZA_TRA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_TRA_INS" as
/* $Header: pezatrin.pkb 115.1 2002/12/05 06:52:33 nsugavan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_za_tra_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy per_za_tra_shd.g_za_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  per_za_tra_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_za_training
  --
  insert into per_za_training  (
	TRAINING_ID,
 	LEVEL_ID,
 	PERSON_ID,
 	FIELD_OF_LEARNING,
 	COURSE,
 	SUB_FIELD,
 	CREDIT,
	NOTIONAL_HOURS,
 	REGISTRATION_DATE,
 	REGISTRATION_NUMBER
  )
  Values
  (
	p_rec.TRAINING_ID,
 	p_rec.LEVEL_ID,
 	p_rec.PERSON_ID,
 	p_rec.FIELD_OF_LEARNING,
 	p_rec.COURSE,
 	p_rec.SUB_FIELD,
 	p_rec.CREDIT,
	p_rec.NOTIONAL_HOURS,
 	p_rec.REGISTRATION_DATE,
 	p_rec.REGISTRATION_NUMBER
  );
  --
  per_za_tra_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_za_tra_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_tra_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_za_tra_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_tra_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_za_tra_shd.g_api_dml := false;   -- Unset the api dml status
    per_za_tra_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_za_tra_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure post_insert(p_rec in per_za_tra_shd.g_za_rec_type) is
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
  p_rec            in out nocopy per_za_tra_shd.g_za_rec_type,
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
    SAVEPOINT ins_tra;
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
    ROLLBACK TO ins_tra;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  	P_TRAINING_ID		  	IN	NUMBER,
 	P_LEVEL_ID               	IN	NUMBER	default null,
 	P_PERSON_ID              	IN	NUMBER,
 	P_FIELD_OF_LEARNING      	IN	VARCHAR2	default null,
 	P_COURSE                 	IN	VARCHAR2	default null,
 	P_SUB_FIELD              	IN	VARCHAR2	default null,
 	P_CREDIT                 	IN	NUMBER	default null,
 	P_REGISTRATION_DATE      	IN	DATE		default null,
 	P_REGISTRATION_NUMBER    	IN	VARCHAR2	default null,
	P_NOTIONAL_HOURS			IN NUMBER default null,
	p_validate				in	boolean	default false
  ) is
--
  l_rec	  	per_za_tra_shd.g_za_rec_type;
  l_proc  		varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_za_tra_shd.convert_args
  (
  	P_TRAINING_ID,
 	P_LEVEL_ID,
 	P_PERSON_ID,
 	P_FIELD_OF_LEARNING,
 	P_COURSE,
 	P_SUB_FIELD,
 	P_CREDIT,
	P_NOTIONAL_HOURS,
 	P_REGISTRATION_DATE,
 	P_REGISTRATION_NUMBER
  );
  --
  -- Having converted the arguments into the tra_rec
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
end per_za_tra_ins;

/
