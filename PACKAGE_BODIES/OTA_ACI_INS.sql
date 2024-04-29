--------------------------------------------------------
--  DDL for Package Body OTA_ACI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ACI_INS" as
/* $Header: otacirhi.pkb 120.0 2005/05/29 06:51:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_aci_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_activity_version_id_i  number   default null;
g_category_usage_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_activity_version_id  in  number
  ,p_category_usage_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_aci_ins.g_activity_version_id_i := p_activity_version_id;
  ota_aci_ins.g_category_usage_id_i := p_category_usage_id;
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
  (p_rec in out nocopy ota_aci_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_aci_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_act_cat_inclusions
  --
  insert into ota_act_cat_inclusions
      (activity_version_id
      ,activity_category
      ,object_version_number
      ,event_id
      ,comments
      ,aci_information_category
      ,aci_information1
      ,aci_information2
      ,aci_information3
      ,aci_information4
      ,aci_information5
      ,aci_information6
      ,aci_information7
      ,aci_information8
      ,aci_information9
      ,aci_information10
      ,aci_information11
      ,aci_information12
      ,aci_information13
      ,aci_information14
      ,aci_information15
      ,aci_information16
      ,aci_information17
      ,aci_information18
      ,aci_information19
      ,aci_information20
      ,start_date_active
      ,end_date_active
      ,primary_flag
      ,category_usage_id
      )
  Values
    (p_rec.activity_version_id
    ,p_rec.activity_category
    ,p_rec.object_version_number
    ,p_rec.event_id
    ,p_rec.comments
    ,p_rec.aci_information_category
    ,p_rec.aci_information1
    ,p_rec.aci_information2
    ,p_rec.aci_information3
    ,p_rec.aci_information4
    ,p_rec.aci_information5
    ,p_rec.aci_information6
    ,p_rec.aci_information7
    ,p_rec.aci_information8
    ,p_rec.aci_information9
    ,p_rec.aci_information10
    ,p_rec.aci_information11
    ,p_rec.aci_information12
    ,p_rec.aci_information13
    ,p_rec.aci_information14
    ,p_rec.aci_information15
    ,p_rec.aci_information16
    ,p_rec.aci_information17
    ,p_rec.aci_information18
    ,p_rec.aci_information19
    ,p_rec.aci_information20
    ,p_rec.start_date_active
    ,p_rec.end_date_active
    ,p_rec.primary_flag
    ,p_rec.category_usage_id
    );
  --
  ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
    ota_aci_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
    ota_aci_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
    ota_aci_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_aci_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy ota_aci_shd.g_rec_type
  ) is

/*
--
 Cursor C_Sel1 is select ota_act_cat_inclusions_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ota_act_cat_inclusions
     where activity_version_id =
             ota_aci_ins.g_activity_version_id_i
        or category_usage_id =
             ota_aci_ins.g_category_usage_id_i;
--
*/
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  /*
  --
  If (ota_aci_ins.g_activity_version_id_i is not null or
      ota_aci_ins.g_category_usage_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ota_act_cat_inclusions');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.activity_version_id :=
      ota_aci_ins.g_activity_version_id_i;
    ota_aci_ins.g_activity_version_id_i := null;
    p_rec.category_usage_id :=
      ota_aci_ins.g_category_usage_id_i;
    ota_aci_ins.g_category_usage_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.category_usage_id;
    Close C_Sel1;
  End If;
  --
 */
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
  ,p_rec                          in ota_aci_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_aci_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_activity_category
      => p_rec.activity_category
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_event_id
      => p_rec.event_id
      ,p_comments
      => p_rec.comments
      ,p_aci_information_category
      => p_rec.aci_information_category
      ,p_aci_information1
      => p_rec.aci_information1
      ,p_aci_information2
      => p_rec.aci_information2
      ,p_aci_information3
      => p_rec.aci_information3
      ,p_aci_information4
      => p_rec.aci_information4
      ,p_aci_information5
      => p_rec.aci_information5
      ,p_aci_information6
      => p_rec.aci_information6
      ,p_aci_information7
      => p_rec.aci_information7
      ,p_aci_information8
      => p_rec.aci_information8
      ,p_aci_information9
      => p_rec.aci_information9
      ,p_aci_information10
      => p_rec.aci_information10
      ,p_aci_information11
      => p_rec.aci_information11
      ,p_aci_information12
      => p_rec.aci_information12
      ,p_aci_information13
      => p_rec.aci_information13
      ,p_aci_information14
      => p_rec.aci_information14
      ,p_aci_information15
      => p_rec.aci_information15
      ,p_aci_information16
      => p_rec.aci_information16
      ,p_aci_information17
      => p_rec.aci_information17
      ,p_aci_information18
      => p_rec.aci_information18
      ,p_aci_information19
      => p_rec.aci_information19
      ,p_aci_information20
      => p_rec.aci_information20
      ,p_start_date_active
      => p_rec.start_date_active
      ,p_end_date_active
      => p_rec.end_date_active
      ,p_primary_flag
      => p_rec.primary_flag
      ,p_category_usage_id
      => p_rec.category_usage_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_ACT_CAT_INCLUSIONS'
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
  ,p_rec                          in out nocopy ota_aci_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
  l_activity_version_id ota_act_cat_inclusions.activity_version_id%TYPE;
  l_category_usage_id ota_act_cat_inclusions.category_usage_id%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  l_activity_version_id := p_rec.activity_version_id;
  l_category_usage_id := p_rec.category_usage_id;

  /*p_rec.activity_version_id := null;
  p_rec.category_usage_id := null;*/

  ota_aci_ins.set_base_key_value(  p_activity_version_id  => l_activity_version_id
                                                                ,p_category_usage_id => l_category_usage_id
                                                                );
  --
  -- Call the supporting insert validate operations
  --
  ota_aci_bus.insert_validate
     (p_effective_date
     ,p_rec
     ,l_activity_version_id
     ,l_category_usage_id
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ota_aci_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ota_aci_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ota_aci_ins.post_insert
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
  ,p_activity_category              in     varchar2
  ,p_activity_version_id               in number
  ,p_category_usage_id                in number
  ,p_event_id                       in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_aci_information_category       in     varchar2 default null
  ,p_aci_information1               in     varchar2 default null
  ,p_aci_information2               in     varchar2 default null
  ,p_aci_information3               in     varchar2 default null
  ,p_aci_information4               in     varchar2 default null
  ,p_aci_information5               in     varchar2 default null
  ,p_aci_information6               in     varchar2 default null
  ,p_aci_information7               in     varchar2 default null
  ,p_aci_information8               in     varchar2 default null
  ,p_aci_information9               in     varchar2 default null
  ,p_aci_information10              in     varchar2 default null
  ,p_aci_information11              in     varchar2 default null
  ,p_aci_information12              in     varchar2 default null
  ,p_aci_information13              in     varchar2 default null
  ,p_aci_information14              in     varchar2 default null
  ,p_aci_information15              in     varchar2 default null
  ,p_aci_information16              in     varchar2 default null
  ,p_aci_information17              in     varchar2 default null
  ,p_aci_information18              in     varchar2 default null
  ,p_aci_information19              in     varchar2 default null
  ,p_aci_information20              in     varchar2 default null
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
  ,p_primary_flag                   in     varchar2 default null
--  ,p_activity_version_id               out nocopy number
--  ,p_category_usage_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ota_aci_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_aci_shd.convert_args
    (--null
    p_activity_version_id
    ,p_activity_category
    ,null
    ,p_event_id
    ,p_comments
    ,p_aci_information_category
    ,p_aci_information1
    ,p_aci_information2
    ,p_aci_information3
    ,p_aci_information4
    ,p_aci_information5
    ,p_aci_information6
    ,p_aci_information7
    ,p_aci_information8
    ,p_aci_information9
    ,p_aci_information10
    ,p_aci_information11
    ,p_aci_information12
    ,p_aci_information13
    ,p_aci_information14
    ,p_aci_information15
    ,p_aci_information16
    ,p_aci_information17
    ,p_aci_information18
    ,p_aci_information19
    ,p_aci_information20
    ,p_start_date_active
    ,p_end_date_active
    ,p_primary_flag
   -- ,null
    ,p_category_usage_id
    );
  --
  -- Having converted the arguments into the ota_aci_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ota_aci_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
--  p_activity_version_id := l_rec.activity_version_id;
--  p_category_usage_id := l_rec.category_usage_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_aci_ins;

/
