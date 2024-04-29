--------------------------------------------------------
--  DDL for Package Body OTA_RUD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RUD_INS" as
/* $Header: otrudrhi.pkb 120.2 2005/09/08 06:34:32 pgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_rud_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_resource_usage_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_resource_usage_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_rud_ins.g_resource_usage_id_i := p_resource_usage_id;
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
  (p_rec in out nocopy ota_rud_shd.g_rec_type
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
  -- Insert the row into: ota_resource_usages
  --
  insert into ota_resource_usages
      (resource_usage_id
      ,supplied_resource_id
      ,activity_version_id
      ,object_version_number
      ,required_flag
      ,start_date
      ,comments
      ,end_date
      ,quantity
      ,resource_type
      ,role_to_play
      ,usage_reason
      ,rud_information_category
      ,rud_information1
      ,rud_information2
      ,rud_information3
      ,rud_information4
      ,rud_information5
      ,rud_information6
      ,rud_information7
      ,rud_information8
      ,rud_information9
      ,rud_information10
      ,rud_information11
      ,rud_information12
      ,rud_information13
      ,rud_information14
      ,rud_information15
      ,rud_information16
      ,rud_information17
      ,rud_information18
      ,rud_information19
      ,rud_information20
      ,offering_id
      )
  Values
    (p_rec.resource_usage_id
    ,p_rec.supplied_resource_id
    ,p_rec.activity_version_id
    ,p_rec.object_version_number
    ,p_rec.required_flag
    ,p_rec.start_date
    ,p_rec.comments
    ,p_rec.end_date
    ,p_rec.quantity
    ,p_rec.resource_type
    ,p_rec.role_to_play
    ,p_rec.usage_reason
    ,p_rec.rud_information_category
    ,p_rec.rud_information1
    ,p_rec.rud_information2
    ,p_rec.rud_information3
    ,p_rec.rud_information4
    ,p_rec.rud_information5
    ,p_rec.rud_information6
    ,p_rec.rud_information7
    ,p_rec.rud_information8
    ,p_rec.rud_information9
    ,p_rec.rud_information10
    ,p_rec.rud_information11
    ,p_rec.rud_information12
    ,p_rec.rud_information13
    ,p_rec.rud_information14
    ,p_rec.rud_information15
    ,p_rec.rud_information16
    ,p_rec.rud_information17
    ,p_rec.rud_information18
    ,p_rec.rud_information19
    ,p_rec.rud_information20
    ,p_rec.offering_id
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ota_rud_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_rud_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_rud_shd.constraint_error
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
  (p_rec  in out nocopy ota_rud_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ota_resource_usages_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ota_resource_usages
     where resource_usage_id =
             ota_rud_ins.g_resource_usage_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ota_rud_ins.g_resource_usage_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ota_resource_usages');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.resource_usage_id :=
      ota_rud_ins.g_resource_usage_id_i;
    ota_rud_ins.g_resource_usage_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.resource_usage_id;
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
  ,p_rec                          in ota_rud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_rud_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_resource_usage_id
      => p_rec.resource_usage_id
      ,p_supplied_resource_id
      => p_rec.supplied_resource_id
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_required_flag
      => p_rec.required_flag
      ,p_start_date
      => p_rec.start_date
      ,p_comments
      => p_rec.comments
      ,p_end_date
      => p_rec.end_date
      ,p_quantity
      => p_rec.quantity
      ,p_resource_type
      => p_rec.resource_type
      ,p_role_to_play
      => p_rec.role_to_play
      ,p_usage_reason
      => p_rec.usage_reason
      ,p_rud_information_category
      => p_rec.rud_information_category
      ,p_rud_information1
      => p_rec.rud_information1
      ,p_rud_information2
      => p_rec.rud_information2
      ,p_rud_information3
      => p_rec.rud_information3
      ,p_rud_information4
      => p_rec.rud_information4
      ,p_rud_information5
      => p_rec.rud_information5
      ,p_rud_information6
      => p_rec.rud_information6
      ,p_rud_information7
      => p_rec.rud_information7
      ,p_rud_information8
      => p_rec.rud_information8
      ,p_rud_information9
      => p_rec.rud_information9
      ,p_rud_information10
      => p_rec.rud_information10
      ,p_rud_information11
      => p_rec.rud_information11
      ,p_rud_information12
      => p_rec.rud_information12
      ,p_rud_information13
      => p_rec.rud_information13
      ,p_rud_information14
      => p_rec.rud_information14
      ,p_rud_information15
      => p_rec.rud_information15
      ,p_rud_information16
      => p_rec.rud_information16
      ,p_rud_information17
      => p_rec.rud_information17
      ,p_rud_information18
      => p_rec.rud_information18
      ,p_rud_information19
      => p_rec.rud_information19
      ,p_rud_information20
      => p_rec.rud_information20
      ,p_offering_id
      => p_rec.offering_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_RESOURCE_USAGES'
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
  ,p_rec                          in out nocopy ota_rud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ota_rud_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ota_rud_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ota_rud_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ota_rud_ins.post_insert
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
  ,p_activity_version_id            in     number   default null
  ,p_required_flag                  in     varchar2
  ,p_start_date                     in     date
  ,p_supplied_resource_id           in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_end_date                       in     date     default null
  ,p_quantity                       in     number   default null
  ,p_resource_type                  in     varchar2 default null
  ,p_role_to_play                   in     varchar2 default null
  ,p_usage_reason                   in     varchar2 default null
  ,p_rud_information_category       in     varchar2 default null
  ,p_rud_information1               in     varchar2 default null
  ,p_rud_information2               in     varchar2 default null
  ,p_rud_information3               in     varchar2 default null
  ,p_rud_information4               in     varchar2 default null
  ,p_rud_information5               in     varchar2 default null
  ,p_rud_information6               in     varchar2 default null
  ,p_rud_information7               in     varchar2 default null
  ,p_rud_information8               in     varchar2 default null
  ,p_rud_information9               in     varchar2 default null
  ,p_rud_information10              in     varchar2 default null
  ,p_rud_information11              in     varchar2 default null
  ,p_rud_information12              in     varchar2 default null
  ,p_rud_information13              in     varchar2 default null
  ,p_rud_information14              in     varchar2 default null
  ,p_rud_information15              in     varchar2 default null
  ,p_rud_information16              in     varchar2 default null
  ,p_rud_information17              in     varchar2 default null
  ,p_rud_information18              in     varchar2 default null
  ,p_rud_information19              in     varchar2 default null
  ,p_rud_information20              in     varchar2 default null
  ,p_resource_usage_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_offering_id                    in     number   default null
  ) is
--
  l_rec   ota_rud_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_rud_shd.convert_args
    (null
    ,p_supplied_resource_id
    ,p_activity_version_id
    ,null
    ,p_required_flag
    ,p_start_date
    ,p_comments
    ,p_end_date
    ,p_quantity
    ,p_resource_type
    ,p_role_to_play
    ,p_usage_reason
    ,p_rud_information_category
    ,p_rud_information1
    ,p_rud_information2
    ,p_rud_information3
    ,p_rud_information4
    ,p_rud_information5
    ,p_rud_information6
    ,p_rud_information7
    ,p_rud_information8
    ,p_rud_information9
    ,p_rud_information10
    ,p_rud_information11
    ,p_rud_information12
    ,p_rud_information13
    ,p_rud_information14
    ,p_rud_information15
    ,p_rud_information16
    ,p_rud_information17
    ,p_rud_information18
    ,p_rud_information19
    ,p_rud_information20
    ,p_offering_id
    );
  --
  -- Having converted the arguments into the ota_rud_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ota_rud_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_resource_usage_id := l_rec.resource_usage_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_rud_ins;

/
