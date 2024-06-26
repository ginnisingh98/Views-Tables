--------------------------------------------------------
--  DDL for Package Body OTA_CHA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CHA_INS" as
/* $Header: otcharhi.pkb 120.3 2006/03/06 02:27 rdola noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_cha_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_chat_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_chat_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_cha_ins.g_chat_id_i := p_chat_id;
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
  (p_rec in out nocopy ota_cha_shd.g_rec_type
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
  -- Insert the row into: ota_chats_b
  --
  insert into ota_chats_b
      (chat_id
      ,business_group_id
      ,object_version_number
      ,public_flag
      ,start_date_active
      ,end_date_active
      ,start_time_active
      ,end_time_active
      ,timezone_code
      )
  Values
    (p_rec.chat_id
    ,p_rec.business_group_id
    ,p_rec.object_version_number
    ,p_rec.public_flag
    ,p_rec.start_date_active
    ,p_rec.end_date_active
    ,p_rec.start_time_active
    ,p_rec.end_time_active
    ,p_rec.timezone_code
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ota_cha_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_cha_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_cha_shd.constraint_error
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
  (p_rec  in out nocopy ota_cha_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ota_chats_b_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ota_chats_b
     where chat_id =
             ota_cha_ins.g_chat_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ota_cha_ins.g_chat_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ota_chats_b');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.chat_id :=
      ota_cha_ins.g_chat_id_i;
    ota_cha_ins.g_chat_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.chat_id;
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
  ,p_rec                          in ota_cha_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_cha_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_chat_id
      => p_rec.chat_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_public_flag
      => p_rec.public_flag
      ,p_start_date_active
      => p_rec.start_date_active
      ,p_end_date_active
      => p_rec.end_date_active
      ,p_start_time_active
      => p_rec.start_time_active
      ,p_end_time_active
      => p_rec.end_time_active
      ,p_timezone_code
      => p_rec.timezone_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_CHATS_B'
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
  ,p_rec                          in out nocopy ota_cha_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ota_cha_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ota_cha_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ota_cha_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ota_cha_ins.post_insert
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
  ,p_public_flag                    in     varchar2
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
  ,p_start_time_active              in     varchar2     default null
  ,p_end_time_active                in     varchar2     default NULL
  ,p_timezone_code                  IN     VARCHAR2     DEFAULT NULL
  ,p_chat_id                           out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ota_cha_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_cha_shd.convert_args
    (null
    ,p_business_group_id
    ,null
    ,p_public_flag
    ,p_start_date_active
    ,p_end_date_active
    ,p_start_time_active
    ,p_end_time_active
    ,p_timezone_code
    );
  --
  -- Having converted the arguments into the ota_cha_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ota_cha_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_chat_id := l_rec.chat_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_cha_ins;

/
