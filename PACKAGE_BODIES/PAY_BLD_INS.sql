--------------------------------------------------------
--  DDL for Package Body PAY_BLD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BLD_INS" as
/* $Header: pybldrhi.pkb 120.0 2005/05/29 03:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_bld_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_balance_dimension_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_balance_dimension_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_bld_ins.g_balance_dimension_id_i := p_balance_dimension_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
  (p_rec in out nocopy pay_bld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Insert the row into: pay_balance_dimensions
  --
  insert into pay_balance_dimensions
      (balance_dimension_id
      ,business_group_id
      ,legislation_code
      ,route_id
      ,database_item_suffix
      ,dimension_name
      ,dimension_type
      ,description
      ,feed_checking_code
      ,legislation_subgroup
      ,payments_flag
      ,expiry_checking_code
      ,expiry_checking_level
      ,feed_checking_type
      ,dimension_level
      ,period_type
      ,asg_action_balance_dim_id
      ,database_item_function
      ,save_run_balance_enabled
      ,start_date_code
      )
  Values
    (p_rec.balance_dimension_id
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    ,p_rec.route_id
    ,p_rec.database_item_suffix
    ,p_rec.dimension_name
    ,p_rec.dimension_type
    ,p_rec.description
    ,p_rec.feed_checking_code
    ,p_rec.legislation_subgroup
    ,p_rec.payments_flag
    ,p_rec.expiry_checking_code
    ,p_rec.expiry_checking_level
    ,p_rec.feed_checking_type
    ,p_rec.dimension_level
    ,p_rec.period_type
    ,p_rec.asg_action_balance_dim_id
    ,p_rec.database_item_function
    ,p_rec.save_run_balance_enabled
    ,p_rec.start_date_code
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_bld_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_bld_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_bld_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
Procedure pre_insert
  (p_rec  in out nocopy pay_bld_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select pay_balance_dimensions_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pay_balance_dimensions
     where balance_dimension_id =
             pay_bld_ins.g_balance_dimension_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pay_bld_ins.g_balance_dimension_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','pay_balance_dimensions');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.balance_dimension_id :=
      pay_bld_ins.g_balance_dimension_id_i;
    pay_bld_ins.g_balance_dimension_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.balance_dimension_id;
    Close C_Sel1;
  End If;
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
  (p_rec                          in pay_bld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    -- insert ownerships if applicable
    create_app_ownerships
      ('BALANCE_DIMENSION_ID', p_rec.balance_dimension_id
      );
    --
    --
    pay_bld_rki.after_insert
      (p_balance_dimension_id
      => p_rec.balance_dimension_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_route_id
      => p_rec.route_id
      ,p_database_item_suffix
      => p_rec.database_item_suffix
      ,p_dimension_name
      => p_rec.dimension_name
      ,p_dimension_type
      => p_rec.dimension_type
      ,p_description
      => p_rec.description
      ,p_feed_checking_code
      => p_rec.feed_checking_code
      ,p_legislation_subgroup
      => p_rec.legislation_subgroup
      ,p_payments_flag
      => p_rec.payments_flag
      ,p_expiry_checking_code
      => p_rec.expiry_checking_code
      ,p_expiry_checking_level
      => p_rec.expiry_checking_level
      ,p_feed_checking_type
      => p_rec.feed_checking_type
      ,p_dimension_level
      => p_rec.dimension_level
      ,p_period_type
      => p_rec.period_type
      ,p_asg_action_balance_dim_id
      => p_rec.asg_action_balance_dim_id
      ,p_database_item_function
      => p_rec.database_item_function
      ,p_save_run_balance_enabled
      => p_rec.save_run_balance_enabled
      ,p_start_date_code
      => p_rec.start_date_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BALANCE_DIMENSIONS'
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
  (p_rec                          in out nocopy pay_bld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_bld_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_bld_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_bld_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_bld_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_route_id                       in     number
  ,p_database_item_suffix           in     varchar2
  ,p_dimension_name                 in     varchar2
  ,p_dimension_type                 in     varchar2
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_feed_checking_code             in     varchar2 default null
  ,p_legislation_subgroup           in     varchar2 default null
  ,p_payments_flag                  in     varchar2 default null
  ,p_expiry_checking_code           in     varchar2 default null
  ,p_expiry_checking_level          in     varchar2 default null
  ,p_feed_checking_type             in     varchar2 default null
  ,p_dimension_level                in     varchar2 default null
  ,p_period_type                    in     varchar2 default null
  ,p_asg_action_balance_dim_id      in     number   default null
  ,p_database_item_function         in     varchar2 default null
  ,p_save_run_balance_enabled       in     varchar2 default null
  ,p_start_date_code                in     varchar2 default null
  ,p_balance_dimension_id              out nocopy number
  ) is
--
  l_rec   pay_bld_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_bld_shd.convert_args
    (null
    ,p_business_group_id
    ,p_legislation_code
    ,p_route_id
    ,p_database_item_suffix
    ,p_dimension_name
    ,p_dimension_type
    ,p_description
    ,p_feed_checking_code
    ,p_legislation_subgroup
    ,p_payments_flag
    ,p_expiry_checking_code
    ,p_expiry_checking_level
    ,p_feed_checking_type
    ,p_dimension_level
    ,p_period_type
    ,p_asg_action_balance_dim_id
    ,p_database_item_function
    ,p_save_run_balance_enabled
    ,p_start_date_code
    );
  --
  -- Having converted the arguments into the pay_bld_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_bld_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_balance_dimension_id := l_rec.balance_dimension_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_bld_ins;

/
