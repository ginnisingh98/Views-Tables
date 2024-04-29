--------------------------------------------------------
--  DDL for Package Body OTA_FOI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FOI_INS" as
/* $Header: otfoirhi.pkb 120.3 2005/08/12 02:45 pchandra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_foi_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_forum_id_i  number   default null;
g_object_id_i  number   default null;
g_object_type_i  varchar2(30)   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_forum_id  in  number
  ,p_object_id  in  number
  ,p_object_type  in  varchar2) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_foi_ins.g_forum_id_i := p_forum_id;
  ota_foi_ins.g_object_id_i := p_object_id;
  ota_foi_ins.g_object_type_i := p_object_type;
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
  (p_rec in out nocopy ota_foi_shd.g_rec_type
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
  -- Insert the row into: ota_frm_obj_inclusions
  --
  insert into ota_frm_obj_inclusions
      (forum_id
      ,object_id
      ,object_type
      ,start_date_active
      ,end_date_active
      ,primary_flag
      ,object_version_number
      )
  Values
    (p_rec.forum_id
    ,p_rec.object_id
    ,p_rec.object_type
    ,p_rec.start_date_active
    ,p_rec.end_date_active
    ,p_rec.primary_flag
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
    ota_foi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_foi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_foi_shd.constraint_error
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
  (p_rec  in out nocopy ota_foi_shd.g_rec_type
  ) is
--
/*
  Cursor C_Sel1 is select ota_frm_obj_inclusions_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ota_frm_obj_inclusions
     where forum_id =
             ota_foi_ins.g_forum_id_i
        or object_id =
             ota_foi_ins.g_object_id_i
        or object_type =
             ota_foi_ins.g_object_type_i;
--
*/
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
/*
  If (ota_foi_ins.g_forum_id_i is not null or
      ota_foi_ins.g_object_id_i is not null or
      ota_foi_ins.g_object_type_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ota_frm_obj_inclusions');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.forum_id :=
      ota_foi_ins.g_forum_id_i;
    ota_foi_ins.g_forum_id_i := null;
    p_rec.object_id :=
      ota_foi_ins.g_object_id_i;
    ota_foi_ins.g_object_id_i := null;
    p_rec.object_type :=
      ota_foi_ins.g_object_type_i;
    ota_foi_ins.g_object_type_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.object_type;
    Close C_Sel1;
  End If;
 */
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
  ,p_rec                          in ota_foi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_foi_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_forum_id
      => p_rec.forum_id
      ,p_object_id
      => p_rec.object_id
      ,p_object_type
      => p_rec.object_type
      ,p_start_date_active
      => p_rec.start_date_active
      ,p_end_date_active
      => p_rec.end_date_active
      ,p_primary_flag
      => p_rec.primary_flag
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_FRM_OBJ_INCLUSIONS'
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
  ,p_rec                          in out nocopy ota_foi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
  l_forum_id ota_frm_obj_inclusions.forum_id%TYPE;
  l_object_id ota_frm_obj_inclusions.object_id%TYPE;
  l_object_type ota_frm_obj_inclusions.object_type%TYPE;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  	l_forum_id := p_rec.forum_id;
    	l_object_id := p_rec.object_id;
    	l_object_type := p_rec.object_type;

  /*p_rec.forum_id := null;
  p_rec.object_id := null;
  p_rec.object_type := null;*/

 ota_foi_ins.set_base_key_value(  p_forum_id  => l_forum_id
                                 ,p_object_id => l_object_id
                                 ,p_object_type       => l_object_type
                                 );

  -- Call the supporting insert validate operations
  --

  ota_foi_bus.insert_validate
     (p_effective_date
     ,p_rec
     ,l_forum_id
     ,l_object_id
     ,l_object_type
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ota_foi_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ota_foi_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ota_foi_ins.post_insert
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
  ,p_forum_id                     in  number
  ,p_object_id                    in  number
  ,p_object_type                  in  varchar2
  ,p_start_date_active            in     date     default null
  ,p_end_date_active              in     date     default null
  ,p_primary_flag                 in     varchar2 default null
--  ,p_forum_id                          out nocopy number
--  ,p_object_id                         out nocopy number
--  ,p_object_type                       out nocopy varchar2
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ota_foi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_foi_shd.convert_args
    (--null
    p_forum_id
    ,p_object_id
    ,p_object_type
    --,null
    --,null
    ,p_start_date_active
    ,p_end_date_active
    ,p_primary_flag
    ,null
    );
  --
  -- Having converted the arguments into the ota_foi_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ota_foi_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --

  --p_forum_id := l_rec.forum_id;
  --p_object_id := l_rec.object_id;
  --p_object_type := l_rec.object_type;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_foi_ins;

/
