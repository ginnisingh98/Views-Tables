--------------------------------------------------------
--  DDL for Package Body PAY_PRF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRF_INS" as
/* $Header: pyprfrhi.pkb 120.0 2005/05/29 07:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_prf_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_range_table_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_range_table_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_prf_ins.g_range_table_id_i := p_range_table_id;
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
  (p_rec in out nocopy pay_prf_shd.g_rec_type
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
  -- Insert the row into: pay_range_tables_f
  --
  insert into pay_range_tables_f
      (range_table_id
      ,effective_start_date
      ,effective_end_date
      ,range_table_number
      ,row_value_uom
      ,period_frequency
      ,earnings_type
      ,business_group_id
      ,legislation_code
      ,last_updated_login
      ,created_date
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,ran_information_category
      ,ran_information1
      ,ran_information2
      ,ran_information3
      ,ran_information4
      ,ran_information5
      ,ran_information6
      ,ran_information7
      ,ran_information8
      ,ran_information9
      ,ran_information10
      ,ran_information11
      ,ran_information12
      ,ran_information13
      ,ran_information14
      ,ran_information15
      ,ran_information16
      ,ran_information17
      ,ran_information18
      ,ran_information19
      ,ran_information20
      ,ran_information21
      ,ran_information22
      ,ran_information23
      ,ran_information24
      ,ran_information25
      ,ran_information26
      ,ran_information27
      ,ran_information28
      ,ran_information29
      ,ran_information30
      )
  Values
    (p_rec.range_table_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.range_table_number
    ,p_rec.row_value_uom
    ,p_rec.period_frequency
    ,p_rec.earnings_type
    ,p_rec.business_group_id
    ,p_rec.legislation_code
    ,p_rec.last_updated_login
    ,p_rec.created_date
    ,p_rec.object_version_number
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.attribute21
    ,p_rec.attribute22
    ,p_rec.attribute23
    ,p_rec.attribute24
    ,p_rec.attribute25
    ,p_rec.attribute26
    ,p_rec.attribute27
    ,p_rec.attribute28
    ,p_rec.attribute29
    ,p_rec.attribute30
    ,p_rec.ran_information_category
    ,p_rec.ran_information1
    ,p_rec.ran_information2
    ,p_rec.ran_information3
    ,p_rec.ran_information4
    ,p_rec.ran_information5
    ,p_rec.ran_information6
    ,p_rec.ran_information7
    ,p_rec.ran_information8
    ,p_rec.ran_information9
    ,p_rec.ran_information10
    ,p_rec.ran_information11
    ,p_rec.ran_information12
    ,p_rec.ran_information13
    ,p_rec.ran_information14
    ,p_rec.ran_information15
    ,p_rec.ran_information16
    ,p_rec.ran_information17
    ,p_rec.ran_information18
    ,p_rec.ran_information19
    ,p_rec.ran_information20
    ,p_rec.ran_information21
    ,p_rec.ran_information22
    ,p_rec.ran_information23
    ,p_rec.ran_information24
    ,p_rec.ran_information25
    ,p_rec.ran_information26
    ,p_rec.ran_information27
    ,p_rec.ran_information28
    ,p_rec.ran_information29
    ,p_rec.ran_information30
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_prf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_prf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_prf_shd.constraint_error
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
  (p_rec  in out nocopy pay_prf_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select pay_range_tables_f_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pay_range_tables_f
     where range_table_id =
             pay_prf_ins.g_range_table_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pay_prf_ins.g_range_table_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pay_range_tables_f');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.range_table_id :=
      pay_prf_ins.g_range_table_id_i;
    pay_prf_ins.g_range_table_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.range_table_id;
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
  (p_rec                          in pay_prf_shd.g_rec_type
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
      ('RANGE_TABLE_ID', p_rec.range_table_id
      );
    --
    --
      pay_prf_rki.after_insert
      (p_range_table_id
      => p_rec.range_table_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_range_table_number
      => p_rec.range_table_number
      ,p_row_value_uom
      => p_rec.row_value_uom
      ,p_period_frequency
      => p_rec.period_frequency
      ,p_earnings_type
      => p_rec.earnings_type
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_last_updated_login
      => p_rec.last_updated_login
      ,p_created_date
      => p_rec.created_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_ran_information_category
      => p_rec.ran_information_category
      ,p_ran_information1
      => p_rec.ran_information1
      ,p_ran_information2
      => p_rec.ran_information2
      ,p_ran_information3
      => p_rec.ran_information3
      ,p_ran_information4
      => p_rec.ran_information4
      ,p_ran_information5
      => p_rec.ran_information5
      ,p_ran_information6
      => p_rec.ran_information6
      ,p_ran_information7
      => p_rec.ran_information7
      ,p_ran_information8
      => p_rec.ran_information8
      ,p_ran_information9
      => p_rec.ran_information9
      ,p_ran_information10
      => p_rec.ran_information10
      ,p_ran_information11
      => p_rec.ran_information11
      ,p_ran_information12
      => p_rec.ran_information12
      ,p_ran_information13
      => p_rec.ran_information13
      ,p_ran_information14
      => p_rec.ran_information14
      ,p_ran_information15
      => p_rec.ran_information15
      ,p_ran_information16
      => p_rec.ran_information16
      ,p_ran_information17
      => p_rec.ran_information17
      ,p_ran_information18
      => p_rec.ran_information18
      ,p_ran_information19
      => p_rec.ran_information19
      ,p_ran_information20
      => p_rec.ran_information20
      ,p_ran_information21
      => p_rec.ran_information21
      ,p_ran_information22
      => p_rec.ran_information22
      ,p_ran_information23
      => p_rec.ran_information23
      ,p_ran_information24
      => p_rec.ran_information24
      ,p_ran_information25
      => p_rec.ran_information25
      ,p_ran_information26
      => p_rec.ran_information26
      ,p_ran_information27
      => p_rec.ran_information27
      ,p_ran_information28
      => p_rec.ran_information28
      ,p_ran_information29
      => p_rec.ran_information29
      ,p_ran_information30
      => p_rec.ran_information30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_RANGE_TABLES_F'
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
  (p_rec                          in out nocopy pay_prf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_prf_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_prf_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_prf_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --

 -- Commented Because not User Hook support is not provided.
 /*
 pay_prf_ins.post_insert
     (p_rec
     );
 */

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
  (p_range_table_number             in     number
  ,p_period_frequency               in     varchar2
  ,p_effective_start_date           in     date     default null
  ,p_effective_end_date             in     date     default null
  ,p_row_value_uom                  in     varchar2 default null
  ,p_earnings_type                  in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_last_updated_login             in     number   default null
  ,p_created_date                   in     date     default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_ran_information_category       in     varchar2 default null
  ,p_ran_information1               in     varchar2 default null
  ,p_ran_information2               in     varchar2 default null
  ,p_ran_information3               in     varchar2 default null
  ,p_ran_information4               in     varchar2 default null
  ,p_ran_information5               in     varchar2 default null
  ,p_ran_information6               in     varchar2 default null
  ,p_ran_information7               in     varchar2 default null
  ,p_ran_information8               in     varchar2 default null
  ,p_ran_information9               in     varchar2 default null
  ,p_ran_information10              in     varchar2 default null
  ,p_ran_information11              in     varchar2 default null
  ,p_ran_information12              in     varchar2 default null
  ,p_ran_information13              in     varchar2 default null
  ,p_ran_information14              in     varchar2 default null
  ,p_ran_information15              in     varchar2 default null
  ,p_ran_information16              in     varchar2 default null
  ,p_ran_information17              in     varchar2 default null
  ,p_ran_information18              in     varchar2 default null
  ,p_ran_information19              in     varchar2 default null
  ,p_ran_information20              in     varchar2 default null
  ,p_ran_information21              in     varchar2 default null
  ,p_ran_information22              in     varchar2 default null
  ,p_ran_information23              in     varchar2 default null
  ,p_ran_information24              in     varchar2 default null
  ,p_ran_information25              in     varchar2 default null
  ,p_ran_information26              in     varchar2 default null
  ,p_ran_information27              in     varchar2 default null
  ,p_ran_information28              in     varchar2 default null
  ,p_ran_information29              in     varchar2 default null
  ,p_ran_information30              in     varchar2 default null
  ,p_range_table_id                    out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   pay_prf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_prf_shd.convert_args
    (null
    ,p_effective_start_date
    ,p_effective_end_date
    ,p_range_table_number
    ,p_row_value_uom
    ,p_period_frequency
    ,p_earnings_type
    ,p_business_group_id
    ,p_legislation_code
    ,p_last_updated_login
    ,p_created_date
    ,null
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_attribute21
    ,p_attribute22
    ,p_attribute23
    ,p_attribute24
    ,p_attribute25
    ,p_attribute26
    ,p_attribute27
    ,p_attribute28
    ,p_attribute29
    ,p_attribute30
    ,p_ran_information_category
    ,p_ran_information1
    ,p_ran_information2
    ,p_ran_information3
    ,p_ran_information4
    ,p_ran_information5
    ,p_ran_information6
    ,p_ran_information7
    ,p_ran_information8
    ,p_ran_information9
    ,p_ran_information10
    ,p_ran_information11
    ,p_ran_information12
    ,p_ran_information13
    ,p_ran_information14
    ,p_ran_information15
    ,p_ran_information16
    ,p_ran_information17
    ,p_ran_information18
    ,p_ran_information19
    ,p_ran_information20
    ,p_ran_information21
    ,p_ran_information22
    ,p_ran_information23
    ,p_ran_information24
    ,p_ran_information25
    ,p_ran_information26
    ,p_ran_information27
    ,p_ran_information28
    ,p_ran_information29
    ,p_ran_information30
    );
  --
  -- Having converted the arguments into the pay_prf_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_prf_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_range_table_id := l_rec.range_table_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pay_prf_ins;

/
