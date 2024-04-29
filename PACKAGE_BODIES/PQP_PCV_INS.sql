--------------------------------------------------------
--  DDL for Package Body PQP_PCV_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PCV_INS" as
/* $Header: pqpcvrhi.pkb 120.0 2005/05/29 01:55:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pcv_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_configuration_value_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_configuration_value_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pqp_pcv_ins.g_configuration_value_id_i := p_configuration_value_id;
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
  (p_rec in out nocopy pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: pqp_configuration_values
  --
  insert into pqp_configuration_values
      (configuration_value_id
      ,business_group_id
      ,legislation_code
      ,pcv_attribute_category
      ,pcv_attribute1
      ,pcv_attribute2
      ,pcv_attribute3
      ,pcv_attribute4
      ,pcv_attribute5
      ,pcv_attribute6
      ,pcv_attribute7
      ,pcv_attribute8
      ,pcv_attribute9
      ,pcv_attribute10
      ,pcv_attribute11
      ,pcv_attribute12
      ,pcv_attribute13
      ,pcv_attribute14
      ,pcv_attribute15
      ,pcv_attribute16
      ,pcv_attribute17
      ,pcv_attribute18
      ,pcv_attribute19
      ,pcv_attribute20
      ,pcv_information_category
      ,pcv_information1
      ,pcv_information2
      ,pcv_information3
      ,pcv_information4
      ,pcv_information5
      ,pcv_information6
      ,pcv_information7
      ,pcv_information8
      ,pcv_information9
      ,pcv_information10
      ,pcv_information11
      ,pcv_information12
      ,pcv_information13
      ,pcv_information14
      ,pcv_information15
      ,pcv_information16
      ,pcv_information17
      ,pcv_information18
      ,pcv_information19
      ,pcv_information20
      ,object_version_number
      ,configuration_name
      )
  Values
    (p_rec.configuration_value_id
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    ,p_rec.pcv_attribute_category
    ,p_rec.pcv_attribute1
    ,p_rec.pcv_attribute2
    ,p_rec.pcv_attribute3
    ,p_rec.pcv_attribute4
    ,p_rec.pcv_attribute5
    ,p_rec.pcv_attribute6
    ,p_rec.pcv_attribute7
    ,p_rec.pcv_attribute8
    ,p_rec.pcv_attribute9
    ,p_rec.pcv_attribute10
    ,p_rec.pcv_attribute11
    ,p_rec.pcv_attribute12
    ,p_rec.pcv_attribute13
    ,p_rec.pcv_attribute14
    ,p_rec.pcv_attribute15
    ,p_rec.pcv_attribute16
    ,p_rec.pcv_attribute17
    ,p_rec.pcv_attribute18
    ,p_rec.pcv_attribute19
    ,p_rec.pcv_attribute20
    ,p_rec.pcv_information_category
    ,p_rec.pcv_information1
    ,p_rec.pcv_information2
    ,p_rec.pcv_information3
    ,p_rec.pcv_information4
    ,p_rec.pcv_information5
    ,p_rec.pcv_information6
    ,p_rec.pcv_information7
    ,p_rec.pcv_information8
    ,p_rec.pcv_information9
    ,p_rec.pcv_information10
    ,p_rec.pcv_information11
    ,p_rec.pcv_information12
    ,p_rec.pcv_information13
    ,p_rec.pcv_information14
    ,p_rec.pcv_information15
    ,p_rec.pcv_information16
    ,p_rec.pcv_information17
    ,p_rec.pcv_information18
    ,p_rec.pcv_information19
    ,p_rec.pcv_information20
    ,p_rec.object_version_number
    ,p_rec.configuration_name
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqp_pcv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqp_pcv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqp_pcv_shd.constraint_error
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
  (p_rec  in out nocopy pqp_pcv_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select pqp_configuration_values_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pqp_configuration_values
     where configuration_value_id =
             pqp_pcv_ins.g_configuration_value_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pqp_pcv_ins.g_configuration_value_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pqp_configuration_values');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.configuration_value_id :=
      pqp_pcv_ins.g_configuration_value_id_i;
    pqp_pcv_ins.g_configuration_value_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.configuration_value_id;
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
  (p_effective_date               in date
  ,p_rec                          in pqp_pcv_shd.g_rec_type
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
      ('CONFIGURATION_VALUE_ID', p_rec.configuration_value_id
      );
    --
    --
    pqp_pcv_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_configuration_value_id
      => p_rec.configuration_value_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_pcv_attribute_category
      => p_rec.pcv_attribute_category
      ,p_pcv_attribute1
      => p_rec.pcv_attribute1
      ,p_pcv_attribute2
      => p_rec.pcv_attribute2
      ,p_pcv_attribute3
      => p_rec.pcv_attribute3
      ,p_pcv_attribute4
      => p_rec.pcv_attribute4
      ,p_pcv_attribute5
      => p_rec.pcv_attribute5
      ,p_pcv_attribute6
      => p_rec.pcv_attribute6
      ,p_pcv_attribute7
      => p_rec.pcv_attribute7
      ,p_pcv_attribute8
      => p_rec.pcv_attribute8
      ,p_pcv_attribute9
      => p_rec.pcv_attribute9
      ,p_pcv_attribute10
      => p_rec.pcv_attribute10
      ,p_pcv_attribute11
      => p_rec.pcv_attribute11
      ,p_pcv_attribute12
      => p_rec.pcv_attribute12
      ,p_pcv_attribute13
      => p_rec.pcv_attribute13
      ,p_pcv_attribute14
      => p_rec.pcv_attribute14
      ,p_pcv_attribute15
      => p_rec.pcv_attribute15
      ,p_pcv_attribute16
      => p_rec.pcv_attribute16
      ,p_pcv_attribute17
      => p_rec.pcv_attribute17
      ,p_pcv_attribute18
      => p_rec.pcv_attribute18
      ,p_pcv_attribute19
      => p_rec.pcv_attribute19
      ,p_pcv_attribute20
      => p_rec.pcv_attribute20
      ,p_pcv_information_category
      => p_rec.pcv_information_category
      ,p_pcv_information1
      => p_rec.pcv_information1
      ,p_pcv_information2
      => p_rec.pcv_information2
      ,p_pcv_information3
      => p_rec.pcv_information3
      ,p_pcv_information4
      => p_rec.pcv_information4
      ,p_pcv_information5
      => p_rec.pcv_information5
      ,p_pcv_information6
      => p_rec.pcv_information6
      ,p_pcv_information7
      => p_rec.pcv_information7
      ,p_pcv_information8
      => p_rec.pcv_information8
      ,p_pcv_information9
      => p_rec.pcv_information9
      ,p_pcv_information10
      => p_rec.pcv_information10
      ,p_pcv_information11
      => p_rec.pcv_information11
      ,p_pcv_information12
      => p_rec.pcv_information12
      ,p_pcv_information13
      => p_rec.pcv_information13
      ,p_pcv_information14
      => p_rec.pcv_information14
      ,p_pcv_information15
      => p_rec.pcv_information15
      ,p_pcv_information16
      => p_rec.pcv_information16
      ,p_pcv_information17
      => p_rec.pcv_information17
      ,p_pcv_information18
      => p_rec.pcv_information18
      ,p_pcv_information19
      => p_rec.pcv_information19
      ,p_pcv_information20
      => p_rec.pcv_information20
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_configuration_name
      => p_rec.configuration_name
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_CONFIGURATION_VALUES'
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqp_pcv_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pqp_pcv_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqp_pcv_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqp_pcv_ins.post_insert
     (p_effective_date
     ,p_rec
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
  (p_effective_date               in     date
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_pcv_attribute_category         in     varchar2
  ,p_pcv_attribute1                 in     varchar2
  ,p_pcv_attribute2                 in     varchar2
  ,p_pcv_attribute3                 in     varchar2
  ,p_pcv_attribute4                 in     varchar2
  ,p_pcv_attribute5                 in     varchar2
  ,p_pcv_attribute6                 in     varchar2
  ,p_pcv_attribute7                 in     varchar2
  ,p_pcv_attribute8                 in     varchar2
  ,p_pcv_attribute9                 in     varchar2
  ,p_pcv_attribute10                in     varchar2
  ,p_pcv_attribute11                in     varchar2
  ,p_pcv_attribute12                in     varchar2
  ,p_pcv_attribute13                in     varchar2
  ,p_pcv_attribute14                in     varchar2
  ,p_pcv_attribute15                in     varchar2
  ,p_pcv_attribute16                in     varchar2
  ,p_pcv_attribute17                in     varchar2
  ,p_pcv_attribute18                in     varchar2
  ,p_pcv_attribute19                in     varchar2
  ,p_pcv_attribute20                in     varchar2
  ,p_pcv_information_category       in     varchar2
  ,p_pcv_information1               in     varchar2
  ,p_pcv_information2               in     varchar2
  ,p_pcv_information3               in     varchar2
  ,p_pcv_information4               in     varchar2
  ,p_pcv_information5               in     varchar2
  ,p_pcv_information6               in     varchar2
  ,p_pcv_information7               in     varchar2
  ,p_pcv_information8               in     varchar2
  ,p_pcv_information9               in     varchar2
  ,p_pcv_information10              in     varchar2
  ,p_pcv_information11              in     varchar2
  ,p_pcv_information12              in     varchar2
  ,p_pcv_information13              in     varchar2
  ,p_pcv_information14              in     varchar2
  ,p_pcv_information15              in     varchar2
  ,p_pcv_information16              in     varchar2
  ,p_pcv_information17              in     varchar2
  ,p_pcv_information18              in     varchar2
  ,p_pcv_information19              in     varchar2
  ,p_pcv_information20              in     varchar2
  ,p_configuration_value_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_configuration_name               in     varchar2
  ) is
--
  l_rec   pqp_pcv_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqp_pcv_shd.convert_args
    (null
    ,p_business_group_id
    ,p_legislation_code
    ,p_pcv_attribute_category
    ,p_pcv_attribute1
    ,p_pcv_attribute2
    ,p_pcv_attribute3
    ,p_pcv_attribute4
    ,p_pcv_attribute5
    ,p_pcv_attribute6
    ,p_pcv_attribute7
    ,p_pcv_attribute8
    ,p_pcv_attribute9
    ,p_pcv_attribute10
    ,p_pcv_attribute11
    ,p_pcv_attribute12
    ,p_pcv_attribute13
    ,p_pcv_attribute14
    ,p_pcv_attribute15
    ,p_pcv_attribute16
    ,p_pcv_attribute17
    ,p_pcv_attribute18
    ,p_pcv_attribute19
    ,p_pcv_attribute20
    ,p_pcv_information_category
    ,p_pcv_information1
    ,p_pcv_information2
    ,p_pcv_information3
    ,p_pcv_information4
    ,p_pcv_information5
    ,p_pcv_information6
    ,p_pcv_information7
    ,p_pcv_information8
    ,p_pcv_information9
    ,p_pcv_information10
    ,p_pcv_information11
    ,p_pcv_information12
    ,p_pcv_information13
    ,p_pcv_information14
    ,p_pcv_information15
    ,p_pcv_information16
    ,p_pcv_information17
    ,p_pcv_information18
    ,p_pcv_information19
    ,p_pcv_information20
    ,null
    ,p_configuration_name
    );
  --
  -- Having converted the arguments into the pqp_pcv_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqp_pcv_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_configuration_value_id := l_rec.configuration_value_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqp_pcv_ins;

/
