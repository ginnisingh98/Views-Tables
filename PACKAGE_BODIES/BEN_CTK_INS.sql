--------------------------------------------------------
--  DDL for Package Body BEN_CTK_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CTK_INS" as
/* $Header: bectkrhi.pkb 120.0 2005/05/28 01:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_ctk_ins.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_group_per_in_ler_id_i  number   default null;
g_task_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_group_per_in_ler_id  in  number
  ,p_task_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  ben_ctk_ins.g_group_per_in_ler_id_i := p_group_per_in_ler_id;
  ben_ctk_ins.g_task_id_i := p_task_id;
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
  (p_rec in out nocopy ben_ctk_shd.g_rec_type
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
  ben_ctk_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_cwb_person_tasks
  --
  insert into ben_cwb_person_tasks
      (group_per_in_ler_id
      ,task_id
      ,group_pl_id
      ,lf_evt_ocrd_dt
      ,status_cd
      ,access_cd
      ,task_last_update_date
      ,task_last_update_by
      ,object_version_number
      )
  Values
    (p_rec.group_per_in_ler_id
    ,p_rec.task_id
    ,p_rec.group_pl_id
    ,p_rec.lf_evt_ocrd_dt
    ,p_rec.status_cd
    ,p_rec.access_cd
    ,p_rec.task_last_update_date
    ,p_rec.task_last_update_by
    ,p_rec.object_version_number
    );
  --
  ben_ctk_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_ctk_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ctk_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_ctk_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ctk_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ctk_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ctk_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ctk_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy ben_ctk_shd.g_rec_type
  ) is
--
  Cursor C_Sel2 is
    Select null
      from ben_cwb_person_tasks
     where group_per_in_ler_id =
             ben_ctk_ins.g_group_per_in_ler_id_i
        or task_id =
             ben_ctk_ins.g_task_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  If (ben_ctk_ins.g_group_per_in_ler_id_i is not null or
      ben_ctk_ins.g_task_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ben_cwb_person_tasks');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.group_per_in_ler_id :=
      ben_ctk_ins.g_group_per_in_ler_id_i;
    ben_ctk_ins.g_group_per_in_ler_id_i := null;
    p_rec.task_id :=
      ben_ctk_ins.g_task_id_i;
    ben_ctk_ins.g_task_id_i := null;
  Else
     null;
/*    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.task_id;
    Close C_Sel1; */
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
  (p_rec                          in ben_ctk_shd.g_rec_type
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
    ben_ctk_rki.after_insert
      (p_group_per_in_ler_id
      => p_rec.group_per_in_ler_id
      ,p_task_id
      => p_rec.task_id
      ,p_group_pl_id
      => p_rec.group_pl_id
      ,p_lf_evt_ocrd_dt
      => p_rec.lf_evt_ocrd_dt
      ,p_status_cd
      => p_rec.status_cd
      ,p_access_cd
      => p_rec.access_cd
      ,p_task_last_update_date
      => p_rec.task_last_update_date
      ,p_task_last_update_by
      => p_rec.task_last_update_by
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PERSON_TASKS'
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
  (p_rec                          in out nocopy ben_ctk_shd.g_rec_type
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
  ben_ctk_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ben_ctk_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_ctk_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_ctk_ins.post_insert
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
  (p_group_per_in_ler_id            in     number
  ,p_task_id                        in     number
  ,p_group_pl_id                    in     number
  ,p_lf_evt_ocrd_dt                 in     date
  ,p_status_cd                      in     varchar2 default null
  ,p_access_cd                      in     varchar2 default null
  ,p_task_last_update_date          in     date     default null
  ,p_task_last_update_by            in     number   default null
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ben_ctk_shd.g_rec_type;
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
  ben_ctk_shd.convert_args
    (p_group_per_in_ler_id
    ,p_task_id
    ,p_group_pl_id
    ,p_lf_evt_ocrd_dt
    ,p_status_cd
    ,p_access_cd
    ,p_task_last_update_date
    ,p_task_last_update_by
    ,null
    );
  --
  -- Having converted the arguments into the ben_ctk_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_ctk_ins.ins
     (l_rec
     );
  --
  --
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End ins;
--
end ben_ctk_ins;

/
