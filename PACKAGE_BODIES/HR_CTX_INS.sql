--------------------------------------------------------
--  DDL for Package Body HR_CTX_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CTX_INS" as
/* $Header: hrctxrhi.pkb 120.0 2005/05/30 23:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ctx_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_context_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_context_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_ctx_ins.g_context_id_i := p_context_id;
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
  (p_rec in out nocopy hr_ctx_shd.g_rec_type
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
  -- Insert the row into: hr_ki_contexts
  --
  insert into hr_ki_contexts
      (context_id
      ,view_name
      ,param_1
      ,param_2
      ,param_3
      ,param_4
      ,param_5
      ,param_6
      ,param_7
      ,param_8
      ,param_9
      ,param_10
      ,param_11
      ,param_12
      ,param_13
      ,param_14
      ,param_15
      ,param_16
      ,param_17
      ,param_18
      ,param_19
      ,param_20
      ,param_21
      ,param_22
      ,param_23
      ,param_24
      ,param_25
      ,param_26
      ,param_27
      ,param_28
      ,param_29
      ,param_30
      ,object_version_number
      )
  Values
    (p_rec.context_id
    ,p_rec.view_name
    ,p_rec.param_1
    ,p_rec.param_2
    ,p_rec.param_3
    ,p_rec.param_4
    ,p_rec.param_5
    ,p_rec.param_6
    ,p_rec.param_7
    ,p_rec.param_8
    ,p_rec.param_9
    ,p_rec.param_10
    ,p_rec.param_11
    ,p_rec.param_12
    ,p_rec.param_13
    ,p_rec.param_14
    ,p_rec.param_15
    ,p_rec.param_16
    ,p_rec.param_17
    ,p_rec.param_18
    ,p_rec.param_19
    ,p_rec.param_20
    ,p_rec.param_21
    ,p_rec.param_22
    ,p_rec.param_23
    ,p_rec.param_24
    ,p_rec.param_25
    ,p_rec.param_26
    ,p_rec.param_27
    ,p_rec.param_28
    ,p_rec.param_29
    ,p_rec.param_30
    ,p_rec.object_version_number
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_ctx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_ctx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_ctx_shd.constraint_error
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
  (p_rec  in out nocopy hr_ctx_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select hr_ki_contexts_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from hr_ki_contexts
     where context_id =
             hr_ctx_ins.g_context_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (hr_ctx_ins.g_context_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','hr_ki_contexts');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.context_id :=
      hr_ctx_ins.g_context_id_i;
    hr_ctx_ins.g_context_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.context_id;
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
  (p_rec                          in hr_ctx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_ctx_rki.after_insert
      (p_context_id
      => p_rec.context_id
      ,p_view_name
      => p_rec.view_name
      ,p_param_1
      => p_rec.param_1
      ,p_param_2
      => p_rec.param_2
      ,p_param_3
      => p_rec.param_3
      ,p_param_4
      => p_rec.param_4
      ,p_param_5
      => p_rec.param_5
      ,p_param_6
      => p_rec.param_6
      ,p_param_7
      => p_rec.param_7
      ,p_param_8
      => p_rec.param_8
      ,p_param_9
      => p_rec.param_9
      ,p_param_10
      => p_rec.param_10
      ,p_param_11
      => p_rec.param_11
      ,p_param_12
      => p_rec.param_12
      ,p_param_13
      => p_rec.param_13
      ,p_param_14
      => p_rec.param_14
      ,p_param_15
      => p_rec.param_15
      ,p_param_16
      => p_rec.param_16
      ,p_param_17
      => p_rec.param_17
      ,p_param_18
      => p_rec.param_18
      ,p_param_19
      => p_rec.param_19
      ,p_param_20
      => p_rec.param_20
      ,p_param_21
      => p_rec.param_21
      ,p_param_22
      => p_rec.param_22
      ,p_param_23
      => p_rec.param_23
      ,p_param_24
      => p_rec.param_24
      ,p_param_25
      => p_rec.param_25
      ,p_param_26
      => p_rec.param_26
      ,p_param_27
      => p_rec.param_27
      ,p_param_28
      => p_rec.param_28
      ,p_param_29
      => p_rec.param_29
      ,p_param_30
      => p_rec.param_30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_KI_CONTEXTS'
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
  (p_rec                          in out nocopy hr_ctx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  hr_ctx_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  hr_ctx_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hr_ctx_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hr_ctx_ins.post_insert
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
  (p_view_name                      in     varchar2
  ,p_param_1                        in     varchar2 default null
  ,p_param_2                        in     varchar2 default null
  ,p_param_3                        in     varchar2 default null
  ,p_param_4                        in     varchar2 default null
  ,p_param_5                        in     varchar2 default null
  ,p_param_6                        in     varchar2 default null
  ,p_param_7                        in     varchar2 default null
  ,p_param_8                        in     varchar2 default null
  ,p_param_9                        in     varchar2 default null
  ,p_param_10                       in     varchar2 default null
  ,p_param_11                       in     varchar2 default null
  ,p_param_12                       in     varchar2 default null
  ,p_param_13                       in     varchar2 default null
  ,p_param_14                       in     varchar2 default null
  ,p_param_15                       in     varchar2 default null
  ,p_param_16                       in     varchar2 default null
  ,p_param_17                       in     varchar2 default null
  ,p_param_18                       in     varchar2 default null
  ,p_param_19                       in     varchar2 default null
  ,p_param_20                       in     varchar2 default null
  ,p_param_21                       in     varchar2 default null
  ,p_param_22                       in     varchar2 default null
  ,p_param_23                       in     varchar2 default null
  ,p_param_24                       in     varchar2 default null
  ,p_param_25                       in     varchar2 default null
  ,p_param_26                       in     varchar2 default null
  ,p_param_27                       in     varchar2 default null
  ,p_param_28                       in     varchar2 default null
  ,p_param_29                       in     varchar2 default null
  ,p_param_30                       in     varchar2 default null
  ,p_context_id                        out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   hr_ctx_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_ctx_shd.convert_args
    (null
    ,p_view_name
    ,p_param_1
    ,p_param_2
    ,p_param_3
    ,p_param_4
    ,p_param_5
    ,p_param_6
    ,p_param_7
    ,p_param_8
    ,p_param_9
    ,p_param_10
    ,p_param_11
    ,p_param_12
    ,p_param_13
    ,p_param_14
    ,p_param_15
    ,p_param_16
    ,p_param_17
    ,p_param_18
    ,p_param_19
    ,p_param_20
    ,p_param_21
    ,p_param_22
    ,p_param_23
    ,p_param_24
    ,p_param_25
    ,p_param_26
    ,p_param_27
    ,p_param_28
    ,p_param_29
    ,p_param_30
    ,null
    );
  --
  -- Having converted the arguments into the hr_ctx_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hr_ctx_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_context_id := l_rec.context_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end hr_ctx_ins;

/
