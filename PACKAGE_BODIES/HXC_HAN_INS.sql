--------------------------------------------------------
--  DDL for Package Body HXC_HAN_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAN_INS" as
/* $Header: hxchanrhi.pkb 120.2 2006/07/10 10:09:56 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_han_ins.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_comp_notification_id_i  number   default null;
g_object_version_number_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_comp_notification_id  in  number
  ,p_object_version_number  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  hxc_han_ins.g_comp_notification_id_i := p_comp_notification_id;
  hxc_han_ins.g_object_version_number_i := p_object_version_number;
  --
  if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;
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
  (p_rec in out nocopy hxc_han_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: hxc_app_comp_notifications
  --
  insert into hxc_app_comp_notifications
      (comp_notification_id
      ,object_version_number
      ,notification_number_retries
      ,notification_timeout_value
      ,notification_action_code
      ,notification_recipient_code
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      )
  Values
    (p_rec.comp_notification_id
    ,p_rec.object_version_number
    ,p_rec.notification_number_retries
    ,p_rec.notification_timeout_value
    ,p_rec.notification_action_code
    ,p_rec.notification_recipient_code
    ,fnd_global.user_id
    ,sysdate
    ,fnd_global.user_id
    ,sysdate
    ,fnd_global.login_id
    );
  --
  --
  --
  if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hxc_han_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hxc_han_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hxc_han_shd.constraint_error
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
  (p_rec  in out nocopy hxc_han_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select hxc_app_comp_notifications_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from hxc_app_comp_notifications
     where comp_notification_id =
             hxc_han_ins.g_comp_notification_id_i
        or object_version_number =
             hxc_han_ins.g_object_version_number_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  If (hxc_han_ins.g_comp_notification_id_i is not null or
      hxc_han_ins.g_object_version_number_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','hxc_app_comp_notifications');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.comp_notification_id :=
      hxc_han_ins.g_comp_notification_id_i;
    hxc_han_ins.g_comp_notification_id_i := null;
    p_rec.object_version_number :=
      hxc_han_ins.g_object_version_number_i;
    hxc_han_ins.g_object_version_number_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.comp_notification_id;
    Close C_Sel1;
  End If;
  --
  if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
  (p_rec                          in hxc_han_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    hxc_han_rki.after_insert
      (p_comp_notification_id
      => p_rec.comp_notification_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_notification_number_retries
      => p_rec.notification_number_retries
      ,p_notification_timeout_value
      => p_rec.notification_timeout_value
      ,p_notification_action_code
      => p_rec.notification_action_code
      ,p_notification_recipient_code
      => p_rec.notification_recipient_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HXC_APP_COMP_NOTIFICATIONS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                          in out nocopy hxc_han_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call the supporting insert validate operations
  --
  hxc_han_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  hxc_han_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hxc_han_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hxc_han_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_notification_number_retries    in     number
  ,p_notification_timeout_value     in     number
  ,p_notification_action_code       in     varchar2
  ,p_notification_recipient_code    in     varchar2
  ,p_comp_notification_id              out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   hxc_han_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hxc_han_shd.convert_args
    (null
    ,null
    ,p_notification_number_retries
    ,p_notification_timeout_value
    ,p_notification_action_code
    ,p_notification_recipient_code
    );
  --
  -- Having converted the arguments into the hxc_han_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hxc_han_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_comp_notification_id := l_rec.comp_notification_id;
  p_object_version_number := l_rec.object_version_number;

  --
  if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End ins;
--
end hxc_han_ins;

/
