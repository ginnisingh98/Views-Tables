--------------------------------------------------------
--  DDL for Package Body OTA_OFF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OFF_INS" as
/* $Header: otoffrhi.pkb 120.1.12000000.2 2007/02/06 15:25:23 vkkolla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_off_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_offering_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_offering_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_off_ins.g_offering_id_i := p_offering_id;
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
  (p_rec in out nocopy ota_off_shd.g_rec_type
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
  -- Insert the row into: ota_offerings
  --
  insert into ota_offerings
      (offering_id
      ,activity_version_id
      ,business_group_id
      --,offering_name
      ,start_date
      ,end_date
      ,owner_id
      ,delivery_mode_id
      ,language_id
      ,duration
      ,duration_units
      ,learning_object_id
      ,player_toolbar_flag
      ,player_toolbar_bitset
      ,player_new_window_flag
      ,maximum_attendees
      ,maximum_internal_attendees
      ,minimum_attendees
      ,actual_cost
      ,budget_cost
      ,budget_currency_code
      ,price_basis
      ,currency_code
      ,standard_price
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
      ,data_source
      ,vendor_id
      ,competency_update_level
      ,language_code  -- 2733966
      )
  Values
    (p_rec.offering_id
    ,p_rec.activity_version_id
    ,p_rec.business_group_id
    --,p_rec.offering_name
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.owner_id
    ,p_rec.delivery_mode_id
    ,p_rec.language_id
    ,p_rec.duration
    ,p_rec.duration_units
    ,p_rec.learning_object_id
    ,p_rec.player_toolbar_flag
    ,p_rec.player_toolbar_bitset
    ,p_rec.player_new_window_flag
    ,p_rec.maximum_attendees
    ,p_rec.maximum_internal_attendees
    ,p_rec.minimum_attendees
    ,p_rec.actual_cost
    ,p_rec.budget_cost
    ,p_rec.budget_currency_code
    ,p_rec.price_basis
    ,p_rec.currency_code
    ,p_rec.standard_price
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
    ,p_rec.data_source
    ,p_rec.vendor_id
    ,p_rec.competency_update_level
    ,p_rec.language_code  -- 2733966
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ota_off_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_off_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_off_shd.constraint_error
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
  (p_rec  in out nocopy ota_off_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ota_offerings_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ota_offerings
     where offering_id =
             ota_off_ins.g_offering_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ota_off_ins.g_offering_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ota_offerings');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.offering_id :=
      ota_off_ins.g_offering_id_i;
    ota_off_ins.g_offering_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.offering_id;
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
  ,p_rec                          in ota_off_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_off_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_offering_id
      => p_rec.offering_id
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_business_group_id
      => p_rec.business_group_id

      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_owner_id
      => p_rec.owner_id
      ,p_delivery_mode_id
      => p_rec.delivery_mode_id
      ,p_language_id
      => p_rec.language_id
      ,p_duration
      => p_rec.duration
      ,p_duration_units
      => p_rec.duration_units
      ,p_learning_object_id
      => p_rec.learning_object_id
      ,p_player_toolbar_flag
      => p_rec.player_toolbar_flag
      ,p_player_toolbar_bitset
      => p_rec.player_toolbar_bitset
      ,p_player_new_window_flag
      => p_rec.player_new_window_flag
      ,p_maximum_attendees
      => p_rec.maximum_attendees
      ,p_maximum_internal_attendees
      => p_rec.maximum_internal_attendees
      ,p_minimum_attendees
      => p_rec.minimum_attendees
      ,p_actual_cost
      => p_rec.actual_cost
      ,p_budget_cost
      => p_rec.budget_cost
      ,p_budget_currency_code
      => p_rec.budget_currency_code
      ,p_price_basis
      => p_rec.price_basis
      ,p_currency_code
      => p_rec.currency_code
      ,p_standard_price
      => p_rec.standard_price
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
      ,p_data_source
      => p_rec.data_source
      ,p_vendor_id
      => p_rec.vendor_id
      ,p_competency_update_level      => p_rec.competency_update_level
      ,p_language_code    => p_rec.language_code  -- 2733966
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_OFFERINGS'
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
  ,p_rec                          in out nocopy ota_off_shd.g_rec_type
  ,p_name                         in varchar
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ota_off_bus.insert_validate
     (p_effective_date
     ,p_rec
     ,p_name
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ota_off_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ota_off_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ota_off_ins.post_insert
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
  ,p_name                           in     varchar2
  ,p_start_date                     in     date
  ,p_activity_version_id            in     number   default null
  ,p_end_date                       in     date     default null
  ,p_owner_id                       in     number   default null
  ,p_delivery_mode_id               in     number   default null
  ,p_language_id                    in     number   default null
  ,p_duration                       in     number   default null
  ,p_duration_units                 in     varchar2 default null
  ,p_learning_object_id             in     number   default null
  ,p_player_toolbar_flag            in     varchar2 default null
  ,p_player_toolbar_bitset          in     number   default null
  ,p_player_new_window_flag         in     varchar2 default null
  ,p_maximum_attendees              in     number   default null
  ,p_maximum_internal_attendees     in     number   default null
  ,p_minimum_attendees              in     number   default null
  ,p_actual_cost                    in     number   default null
  ,p_budget_cost                    in     number   default null
  ,p_budget_currency_code           in     varchar2 default null
  ,p_price_basis                    in     varchar2 default null
  ,p_currency_code                  in     varchar2 default null
  ,p_standard_price                 in     number   default null
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
  ,p_offering_id                       out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_data_source                    in     varchar2 default null
  ,p_vendor_id                      in     number   default null
  ,p_competency_update_level      in     varchar2  default null
  ,p_language_code                in     varchar2  default null  -- 2733966

  ) is
--
  l_rec   ota_off_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_off_shd.convert_args
    (null
    ,p_activity_version_id
    ,p_business_group_id
    ,p_name
    ,p_start_date
    ,p_end_date
    ,p_owner_id
    ,p_delivery_mode_id
    ,p_language_id
    ,p_duration
    ,p_duration_units
    ,p_learning_object_id
    ,p_player_toolbar_flag
    ,p_player_toolbar_bitset
    ,p_player_new_window_flag
    ,p_maximum_attendees
    ,p_maximum_internal_attendees
    ,p_minimum_attendees
    ,p_actual_cost
    ,p_budget_cost
    ,p_budget_currency_code
    ,p_price_basis
    ,p_currency_code
    ,p_standard_price
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
    ,p_data_source
    ,p_vendor_id
    ,p_competency_update_level
    ,p_language_code  -- 2733966

    );
  --
  -- Having converted the arguments into the ota_off_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ota_off_ins.ins
     (p_effective_date
     ,l_rec
     ,p_name
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_offering_id := l_rec.offering_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location('  Leaving:'||l_proc, 10);
End ins;
--
end ota_off_ins;

/
