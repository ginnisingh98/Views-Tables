--------------------------------------------------------
--  DDL for Package Body PQP_DET_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_DET_INS" as
/* $Header: pqdetrhi.pkb 115.8 2003/02/17 22:14:03 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_det_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy pqp_det_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pqp_det_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pqp_analyzed_alien_details
  --
  insert into pqp_analyzed_alien_details
  (	analyzed_data_details_id,
	analyzed_data_id,
	income_code,
	withholding_rate,
	income_code_sub_type,
	exemption_code,
	maximum_benefit_amount,
	retro_lose_ben_amt_flag,
	date_benefit_ends,
	retro_lose_ben_date_flag,
	nra_exempt_from_ss,
	nra_exempt_from_medicare,
	student_exempt_from_ss,
	student_exempt_from_medicare,
	addl_withholding_flag,
	constant_addl_tax,
	addl_withholding_amt,
	addl_wthldng_amt_period_type,
	personal_exemption,
	addl_exemption_allowed,
	treaty_ben_allowed_flag,
	treaty_benefits_start_date,
	object_version_number,
        retro_loss_notification_sent,
        current_analysis,
        forecast_income_code
  )
  Values
  (	p_rec.analyzed_data_details_id,
	p_rec.analyzed_data_id,
	p_rec.income_code,
	p_rec.withholding_rate,
	p_rec.income_code_sub_type,
	p_rec.exemption_code,
	p_rec.maximum_benefit_amount,
	p_rec.retro_lose_ben_amt_flag,
	p_rec.date_benefit_ends,
	p_rec.retro_lose_ben_date_flag,
	p_rec.nra_exempt_from_ss,
	p_rec.nra_exempt_from_medicare,
	p_rec.student_exempt_from_ss,
	p_rec.student_exempt_from_medicare,
	p_rec.addl_withholding_flag,
	p_rec.constant_addl_tax,
	p_rec.addl_withholding_amt,
	p_rec.addl_wthldng_amt_period_type,
	p_rec.personal_exemption,
	p_rec.addl_exemption_allowed,
	p_rec.treaty_ben_allowed_flag,
	p_rec.treaty_benefits_start_date,
	p_rec.object_version_number,
        p_rec.retro_loss_notification_sent,
        p_rec.current_analysis,
        p_rec.forecast_income_code
  );
  --
  pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_det_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_det_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_det_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_det_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy pqp_det_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqp_analyzed_alien_details_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.analyzed_data_details_id;
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
Procedure post_insert(
p_effective_date in date,p_rec in pqp_det_shd.g_rec_type) is
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
    pqp_det_rki.after_insert
      (
  p_analyzed_data_details_id      =>p_rec.analyzed_data_details_id
 ,p_analyzed_data_id              =>p_rec.analyzed_data_id
 ,p_income_code                   =>p_rec.income_code
 ,p_withholding_rate              =>p_rec.withholding_rate
 ,p_income_code_sub_type          =>p_rec.income_code_sub_type
 ,p_exemption_code                =>p_rec.exemption_code
 ,p_maximum_benefit_amount        =>p_rec.maximum_benefit_amount
 ,p_retro_lose_ben_amt_flag       =>p_rec.retro_lose_ben_amt_flag
 ,p_date_benefit_ends             =>p_rec.date_benefit_ends
 ,p_retro_lose_ben_date_flag      =>p_rec.retro_lose_ben_date_flag
 ,p_nra_exempt_from_ss            =>p_rec.nra_exempt_from_ss
 ,p_nra_exempt_from_medicare      =>p_rec.nra_exempt_from_medicare
 ,p_student_exempt_from_ss        =>p_rec.student_exempt_from_ss
 ,p_student_exempt_from_medi      =>p_rec.student_exempt_from_medicare
 ,p_addl_withholding_flag         =>p_rec.addl_withholding_flag
 ,p_constant_addl_tax             =>p_rec.constant_addl_tax
 ,p_addl_withholding_amt          =>p_rec.addl_withholding_amt
 ,p_addl_wthldng_amt_period_type  =>p_rec.addl_wthldng_amt_period_type
 ,p_personal_exemption            =>p_rec.personal_exemption
 ,p_addl_exemption_allowed        =>p_rec.addl_exemption_allowed
 ,p_treaty_ben_allowed_flag       =>p_rec.treaty_ben_allowed_flag
 ,p_treaty_benefits_start_date    =>p_rec.treaty_benefits_start_date
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_retro_loss_notification_sent  =>p_rec.retro_loss_notification_sent
 ,p_current_analysis              =>p_rec.current_analysis
 ,p_forecast_income_code          =>p_rec.forecast_income_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_ANALYZED_ALIEN_DET'
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
  p_effective_date in date,
  p_rec        in out nocopy pqp_det_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqp_det_bus.insert_validate(p_rec
  ,p_effective_date);
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
  post_insert(
p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_analyzed_data_details_id     out nocopy number,
  p_analyzed_data_id             in number,
  p_income_code                  in varchar2         default null,
  p_withholding_rate             in number           default null,
  p_income_code_sub_type         in varchar2         default null,
  p_exemption_code               in varchar2         default null,
  p_maximum_benefit_amount       in number           default null,
  p_retro_lose_ben_amt_flag      in varchar2         default null,
  p_date_benefit_ends            in date             default null,
  p_retro_lose_ben_date_flag     in varchar2         default null,
  p_nra_exempt_from_ss           in varchar2         default null,
  p_nra_exempt_from_medicare     in varchar2         default null,
  p_student_exempt_from_ss       in varchar2         default null,
  p_student_exempt_from_medi     in varchar2         default null,
  p_addl_withholding_flag        in varchar2         default null,
  p_constant_addl_tax            in number           default null,
  p_addl_withholding_amt         in number           default null,
  p_addl_wthldng_amt_period_type in varchar2         default null,
  p_personal_exemption           in number           default null,
  p_addl_exemption_allowed       in number           default null,
  p_treaty_ben_allowed_flag      in varchar2         default null,
  p_treaty_benefits_start_date   in date             default null,
  p_object_version_number        out nocopy number,
  p_retro_loss_notification_sent in varchar2         default null,
  p_current_analysis             in varchar2         default null,
  p_forecast_income_code         in varchar2         default null
  ) is
--
  l_rec	  pqp_det_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqp_det_shd.convert_args
  (
  null,
  p_analyzed_data_id,
  p_income_code,
  p_withholding_rate,
  p_income_code_sub_type,
  p_exemption_code,
  p_maximum_benefit_amount,
  p_retro_lose_ben_amt_flag,
  p_date_benefit_ends,
  p_retro_lose_ben_date_flag,
  p_nra_exempt_from_ss,
  p_nra_exempt_from_medicare,
  p_student_exempt_from_ss,
  p_student_exempt_from_medi,
  p_addl_withholding_flag,
  p_constant_addl_tax,
  p_addl_withholding_amt,
  p_addl_wthldng_amt_period_type,
  p_personal_exemption,
  p_addl_exemption_allowed,
  p_treaty_ben_allowed_flag,
  p_treaty_benefits_start_date,
  null,
  p_retro_loss_notification_sent,
  p_current_analysis,
  p_forecast_income_code
  );
  --
  -- Having converted the arguments into the det_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_analyzed_data_details_id := l_rec.analyzed_data_details_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqp_det_ins;

/
