--------------------------------------------------------
--  DDL for Package Body PQP_EXR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EXR_INS" as
/* $Header: pqexrrhi.pkb 120.4 2006/10/20 18:38:32 sshetty noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_exr_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure inserts a row into the HR_APPLICATION_OWNERSHIPS table
--   when the row handler is called in the appropriate mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column  IN varchar2
                               ,p_pk_value   IN varchar2) IS
--
CURSOR csr_definition IS
  SELECT product_short_name
    FROM hr_owner_definitions
   WHERE session_id = hr_startup_data_api_support.g_session_id;
--
BEGIN
  --

  IF (hr_startup_data_api_support.return_startup_mode IN
                               ('STARTUP','GENERIC')) THEN
     --
     FOR c1 IN csr_definition LOOP
       --
       INSERT INTO hr_application_ownerships
         (key_name
         ,key_value
         ,product_name
         )
       VALUES
         (p_pk_column
         ,fnd_number.number_to_canonical(p_pk_value)
         ,c1.product_short_name
         );
     END LOOP;
  END IF;
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  create_app_ownerships(p_pk_column, to_char(p_pk_value));
END create_app_ownerships;
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
  (p_rec in out nocopy pqp_exr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pqp_exr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pqp_exception_reports
  --

  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP')
  THEN

	  insert into pqp_exception_reports
	      (exception_report_id
	      ,exception_report_name
	      ,legislation_code
	      ,business_group_id
	      ,currency_code
	      ,balance_type_id
	      ,balance_dimension_id
	      ,variance_type
	      ,variance_value
	      ,comparison_type
	      ,comparison_value
	      ,object_version_number
	      ,output_format
	      ,variance_operator
		)
	  Values
	    (p_rec.exception_report_id
	    ,p_rec.exception_report_name
	    ,p_rec.legislation_code
	    ,p_rec.business_group_id
	    ,p_rec.currency_code
	    ,p_rec.balance_type_id
	    ,p_rec.balance_dimension_id
	    ,p_rec.variance_type
	    ,p_rec.variance_value
	    ,p_rec.comparison_type
	    ,p_rec.comparison_value
	    ,p_rec.object_version_number
	    ,p_rec.output_format_type
	    ,p_rec.variance_operator
	     );
  ELSE
	  insert into pqp_exception_reports
	      (exception_report_id
	      ,exception_report_name
	      ,legislation_code
	      ,business_group_id
	      ,currency_code
	      ,balance_type_id
	      ,balance_dimension_id
	      ,variance_type
	      ,variance_value
	      ,comparison_type
	      ,comparison_value
	      ,object_version_number
	      ,output_format
	      ,variance_operator
	      ,last_updated_by
              ,last_update_date
              ,created_by
              ,creation_date
		)
	  Values
	    (p_rec.exception_report_id
	    ,p_rec.exception_report_name
	    ,p_rec.legislation_code
	    ,p_rec.business_group_id
	    ,p_rec.currency_code
	    ,p_rec.balance_type_id
	    ,p_rec.balance_dimension_id
	    ,p_rec.variance_type
	    ,p_rec.variance_value
	    ,p_rec.comparison_type
	    ,p_rec.comparison_value
	    ,p_rec.object_version_number
	    ,p_rec.output_format_type
	    ,p_rec.variance_operator
	    ,2
	    ,sysdate
	    ,2
	    ,sysdate
	     );

  END IF;

	  --
  pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_exr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_exr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_exr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy pqp_exr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqp_exception_reports_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.exception_report_id;
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
--   This private procedure contains any processing which is required after
--   the insert dml.
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
  (p_rec                          in pqp_exr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
  -- insert ownerships if applicable
  create_app_ownerships('EXCEPTION_REPORT_ID', p_rec.exception_report_id);
  --
    --
    pqp_exr_rki.after_insert (
      p_exception_report_id
      => p_rec.exception_report_id
      ,p_exception_report_name
      => p_rec.exception_report_name
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_currency_code
      => p_rec.currency_code
      ,p_balance_type_id
      => p_rec.balance_type_id
      ,p_balance_dimension_id
      => p_rec.balance_dimension_id
      ,p_variance_type
      => p_rec.variance_type
      ,p_variance_value
      => p_rec.variance_value
      ,p_comparison_type
      => p_rec.comparison_type
      ,p_comparison_value
      => p_rec.comparison_value
      ,p_object_version_number
      => p_rec.object_version_number
       ,p_output_format_type
      => p_rec.output_format_type
      ,p_variance_operator
      => p_rec.variance_operator
          );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_EXCEPTION_REPORTS'
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
  (p_rec                          in out nocopy pqp_exr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --

  pqp_exr_bus.insert_validate
     (p_rec
     );

  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pqp_exr_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqp_exr_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqp_exr_ins.post_insert
     (p_rec
     );
  --
  hr_multi_message.end_validation_set;
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_exception_report_name          in     varchar2
  ,p_legislation_code               in     varchar2
  ,p_business_group_id              in     number
  ,p_currency_code                  in     varchar2
  ,p_balance_type_id                in     number
  ,p_balance_dimension_id           in     number
  ,p_variance_type                  in     varchar2
  ,p_variance_value                 in     number
  ,p_comparison_type                in     varchar2
  ,p_comparison_value               in     number
  ,p_exception_report_id            out nocopy    number
  ,p_object_version_number          out nocopy    number
  ,p_output_format_type             in     varchar2
  ,p_variance_operator              in     varchar2
  ) is
--
  l_rec   pqp_exr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --


  l_rec :=
  pqp_exr_shd.convert_args
    (null
    ,p_exception_report_name
    ,p_legislation_code
    ,p_business_group_id
    ,p_currency_code
    ,p_balance_type_id
    ,p_balance_dimension_id
    ,p_variance_type
    ,p_variance_value
    ,p_comparison_type
    ,p_comparison_value
    ,null
    ,p_output_format_type
    ,p_variance_operator
     );
  --
  -- Having converted the arguments into the pqp_exr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqp_exr_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_exception_report_id := l_rec.exception_report_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqp_exr_ins;

/
