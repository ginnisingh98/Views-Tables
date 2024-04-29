--------------------------------------------------------
--  DDL for Package Body SSP_ERN_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_ERN_INS" as
/* $Header: spernrhi.pkb 120.5.12010000.2 2008/08/13 13:25:38 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_ern_ins.';  -- Global package name
g_payment_period_func_status varchar2(3);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ssp_ern_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ssp_earnings_calculations
  --
  insert into ssp_earnings_calculations
  (	earnings_calculations_id,
	object_version_number,
	person_id,
	effective_date,
	average_earnings_amount,
	user_entered,
	payment_periods
  )
  Values
  (	p_rec.earnings_calculations_id,
	p_rec.object_version_number,
	p_rec.person_id,
	p_rec.effective_date,
	p_rec.average_earnings_amount,
	p_rec.user_entered,
	p_rec.payment_periods
  );
  --
  ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_ern_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_ern_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_ern_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ssp_ern_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ssp_earnings_calculations_s.nextval from sys.dual;
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 1);
   --
   -- Select the next sequence number
   --
   Open C_Sel1;
   Fetch C_Sel1 Into p_rec.earnings_calculations_id;
   Close C_Sel1;
   --
   hr_utility.set_location('Leaving :'||l_proc, 100);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 1);
   --
   hr_utility.set_location('Leaving :'||l_proc, 100);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ssp_ern_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate
  then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_ssp_ern;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ssp_ern_bus.insert_validate(p_rec);
  --
  if g_payment_period_func_status = 'OLD' and p_rec.payment_periods is null
  then
     p_rec.payment_periods := ssp_ern_bus.number_of_periods;
  end if;
  --
  -- Call the supporting pre-insert operation
  -- if a value has been returned in p_rec.average_earnings_amount
  --
  if p_rec.average_earnings_amount is not null
  then
     pre_insert(p_rec);
     --
     -- Insert the row
     --
     insert_dml(p_rec);
     --
     -- Call the supporting post-insert operation
     --
     post_insert(p_rec);
  end if;
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
     Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_ssp_ern;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- NOTE: this procedure is the old version, before the addition of parameters
--       for user_entered and payment_periods
--
Procedure ins
  (
  p_earnings_calculations_id     out nocopy number,
  p_object_version_number        out nocopy number,
  p_person_id                    in number,
  p_effective_date               in date,
  p_average_earnings_amount      in out nocopy number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  ssp_ern_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins (old)';
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 1);
   --
   g_payment_period_func_status := 'OLD';
   --
   -- Call conversion function to turn arguments into the p_rec structure.
   --
   l_rec := ssp_ern_shd.convert_args (null,
                                      null,
                                      p_person_id,
                                      p_effective_date,
                                      p_average_earnings_amount,
                                      'N',
				      'S', -- DFoster 1304683 Default to Sickness
                                      null);
   --
   -- Having converted the arguments into the ssp_ern_rec
   -- plsql record structure we call the corresponding record business process.
   --
   ins(l_rec, p_validate);
   --
   -- As the primary key argument(s)
   -- are specified as an OUT's we must set these values.
   --
   p_earnings_calculations_id := l_rec.earnings_calculations_id;
   p_object_version_number    := l_rec.object_version_number;
   p_average_earnings_amount  := l_rec.average_earnings_amount;
   --
   hr_utility.set_location('Leaving :'||l_proc, 100);
End ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- NOTE: this procedure is the new version, with parameters for user_entered
--       and payment_periods
--
Procedure ins
  (
  p_earnings_calculations_id     out nocopy number,
  p_object_version_number        out nocopy number,
  p_person_id                    in number,
  p_effective_date               in date,
  p_average_earnings_amount      in out nocopy number,
  p_user_entered		 in out nocopy varchar2,
  p_absence_category		 in out nocopy varchar2, --DFoster 1304683
  p_payment_periods		 in out nocopy number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  ssp_ern_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  g_payment_period_func_status := 'NEW';
  --
  -- Call conversion function to turn arguments into the p_rec structure.
  --
  l_rec := ssp_ern_shd.convert_args (null,
                                     null,
                                     p_person_id,
                                     p_effective_date,
                                     p_average_earnings_amount,
                                     p_user_entered,
				     p_absence_category, --DFoster 1304683
                                     p_payment_periods);
  --
  -- Having converted the arguments into the ssp_ern_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_earnings_calculations_id := l_rec.earnings_calculations_id;
  p_object_version_number    := l_rec.object_version_number;
  p_average_earnings_amount  := l_rec.average_earnings_amount;
  p_user_entered             := l_rec.user_entered;
  p_absence_category	     := l_rec.absence_category; --DFoster 1304683
  p_payment_periods          := l_rec.payment_periods;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
End ins;
--
end ssp_ern_ins;

/
