--------------------------------------------------------
--  DDL for Package Body PAY_APP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_APP_INS" as
/* $Header: pyapprhi.pkb 120.0.12000000.1 2007/01/17 15:36:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33);  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_process_parameter_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_process_parameter_id  in  number) is
--
  l_proc       varchar2(72);
--
Begin
  l_proc   := g_package||'set_base_key_value';
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_app_ins.g_process_parameter_id_i := p_process_parameter_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
  (p_rec in out nocopy pay_app_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'insert_dml';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pay_app_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_au_process_parameters
  --
  insert into pay_au_process_parameters
      (process_parameter_id
      ,process_id
      ,internal_name
      ,data_type
      ,enabled_flag
      ,object_version_number
      )
  Values
    (p_rec.process_parameter_id
    ,p_rec.process_id
    ,p_rec.internal_name
    ,p_rec.data_type
    ,p_rec.enabled_flag
    ,p_rec.object_version_number
    );
  --
  pay_app_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_app_shd.g_api_dml := false;   -- Unset the api dml status
    pay_app_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_app_shd.g_api_dml := false;   -- Unset the api dml status
    pay_app_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_app_shd.g_api_dml := false;   -- Unset the api dml status
    pay_app_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_app_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy pay_app_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select pay_au_process_parameters_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pay_au_process_parameters
     where process_parameter_id =
             pay_app_ins.g_process_parameter_id_i;
--
  l_proc   varchar2(72);
  l_exists varchar2(1);
--
Begin
  l_proc := g_package||'pre_insert';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pay_app_ins.g_process_parameter_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pay_au_process_parameters');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.process_parameter_id :=
      pay_app_ins.g_process_parameter_id_i;
    pay_app_ins.g_process_parameter_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.process_parameter_id;
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
  (p_rec                          in pay_app_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'post_insert';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                          in out nocopy pay_app_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'ins';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_app_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_app_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_app_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_app_ins.post_insert
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
  (p_process_id                     in     number
  ,p_internal_name                  in     varchar2
  ,p_data_type                      in     varchar2
  ,p_enabled_flag                   in     varchar2
  ,p_process_parameter_id              out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   pay_app_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'ins';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_app_shd.convert_args
    (null
    ,p_process_id
    ,p_internal_name
    ,p_data_type
    ,p_enabled_flag
    ,null
    );
  --
  -- Having converted the arguments into the pay_app_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_app_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_process_parameter_id := l_rec.process_parameter_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
begin
  g_package  := '  pay_app_ins.';  -- Global package name
end pay_app_ins;

/
