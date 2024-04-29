--------------------------------------------------------
--  DDL for Package Body OTA_CPR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CPR_INS" as
/* $Header: otcprrhi.pkb 120.2 2006/10/09 11:33:40 sschauha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_cpr_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_activity_version_id_i  number   default null;
g_prerequisite_course_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_activity_version_id  in  number
  ,p_prerequisite_course_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_cpr_ins.g_activity_version_id_i := p_activity_version_id;
  ota_cpr_ins.g_prerequisite_course_id_i := p_prerequisite_course_id;
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
  (p_rec in out nocopy ota_cpr_shd.g_rec_type
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
  -- Insert the row into: ota_course_prerequisites
  --
  insert into ota_course_prerequisites
      (activity_version_id
      ,prerequisite_course_id
      ,business_group_id
      ,prerequisite_type
      ,enforcement_mode
      ,object_version_number
      )
  Values
    (p_rec.activity_version_id
    ,p_rec.prerequisite_course_id
    ,p_rec.business_group_id
    ,p_rec.prerequisite_type
    ,p_rec.enforcement_mode
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
    ota_cpr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_cpr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_cpr_shd.constraint_error
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
  (p_rec  in out nocopy ota_cpr_shd.g_rec_type
  ) is
--
--
/*
  Cursor C_Sel2 is
    Select null
      from ota_course_prerequisites
     where activity_version_id =
             ota_cpr_ins.g_activity_version_id_i
        or prerequisite_course_id =
             ota_cpr_ins.g_prerequisite_course_id_i;*/
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
/*
  --
  If (ota_cpr_ins.g_activity_version_id_i is not null or
      ota_cpr_ins.g_prerequisite_course_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ota_course_prerequisites');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;*/
    --
    -- Use registered key values and clear globals
    --
 /* Bug 5586350: Following lines are assigning values from global location, no need because we are populating global location inside
                            row handler ins from p_rec.activity_version_id, p_rec.prerequisite_course_id and now assigning these record variables again values
			    from global location. No need to set these global location again to null because _api will require activity_version_id and
			    prerequisite_course_id and ins will set global location by these value. In any case global location will not carry any old value.
     p_rec.activity_version_id :=
      ota_cpr_ins.g_activity_version_id_i;
    ota_cpr_ins.g_activity_version_id_i := null;
    p_rec.prerequisite_course_id :=
      ota_cpr_ins.g_prerequisite_course_id_i;
    ota_cpr_ins.g_prerequisite_course_id_i := null;
     End Bug 5586350*/
/*
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --

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
  ,p_rec                          in ota_cpr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ota_cpr_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_prerequisite_course_id
      => p_rec.prerequisite_course_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_prerequisite_type
      => p_rec.prerequisite_type
      ,p_enforcement_mode
      => p_rec.enforcement_mode
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_COURSE_PREREQUISITES'
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
  ,p_rec                          in out nocopy ota_cpr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
  l_activity_version_id OTA_COURSE_PREREQUISITES.activity_version_id%TYPE;
  l_prerequisite_course_id OTA_COURSE_PREREQUISITES.prerequisite_course_id%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --Bug 5586350: Calling set_base_key_value to set global location. Coding standard for elbow tables.
  ota_cpr_ins.set_base_key_value( p_activity_version_id => p_rec.activity_version_id
                                    ,p_prerequisite_course_id => p_rec.prerequisite_course_id
                                );
  -- End Bug 5586350

  --
  -- Call the supporting insert validate operations
  --
  ota_cpr_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ota_cpr_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ota_cpr_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ota_cpr_ins.post_insert
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
  ,p_activity_version_id            in number
  ,p_prerequisite_course_id         in number
  ,p_business_group_id              in     number
  ,p_prerequisite_type              in     varchar2
  ,p_enforcement_mode               in     varchar2
--  ,p_activity_version_id               out nocopy number
--  ,p_prerequisite_course_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ota_cpr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_cpr_shd.convert_args
    (p_activity_version_id
    ,p_prerequisite_course_id
    ,p_business_group_id
    ,p_prerequisite_type
    ,p_enforcement_mode
    ,null
    );
  --
  -- Having converted the arguments into the ota_cpr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ota_cpr_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
--  p_activity_version_id := l_rec.activity_version_id;
--  p_prerequisite_course_id := l_rec.prerequisite_course_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_cpr_ins;

/
