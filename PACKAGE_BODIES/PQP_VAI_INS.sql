--------------------------------------------------------
--  DDL for Package Body PQP_VAI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAI_INS" as
/* $Header: pqvairhi.pkb 120.0.12010000.2 2008/08/08 07:19:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vai_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_veh_alloc_extra_info_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_veh_alloc_extra_info_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pqp_vai_ins.g_veh_alloc_extra_info_id_i := p_veh_alloc_extra_info_id;
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
  (p_rec in out nocopy pqp_vai_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pqp_vai_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pqp_veh_alloc_extra_info
  --
  insert into pqp_veh_alloc_extra_info
      (veh_alloc_extra_info_id
      ,vehicle_allocation_id
      ,information_type
      ,vaei_attribute_category
      ,vaei_attribute1
      ,vaei_attribute2
      ,vaei_attribute3
      ,vaei_attribute4
      ,vaei_attribute5
      ,vaei_attribute6
      ,vaei_attribute7
      ,vaei_attribute8
      ,vaei_attribute9
      ,vaei_attribute10
      ,vaei_attribute11
      ,vaei_attribute12
      ,vaei_attribute13
      ,vaei_attribute14
      ,vaei_attribute15
      ,vaei_attribute16
      ,vaei_attribute17
      ,vaei_attribute18
      ,vaei_attribute19
      ,vaei_attribute20
      ,vaei_information_category
      ,vaei_information1
      ,vaei_information2
      ,vaei_information3
      ,vaei_information4
      ,vaei_information5
      ,vaei_information6
      ,vaei_information7
      ,vaei_information8
      ,vaei_information9
      ,vaei_information10
      ,vaei_information11
      ,vaei_information12
      ,vaei_information13
      ,vaei_information14
      ,vaei_information15
      ,vaei_information16
      ,vaei_information17
      ,vaei_information18
      ,vaei_information19
      ,vaei_information20
      ,vaei_information21
      ,vaei_information22
      ,vaei_information23
      ,vaei_information24
      ,vaei_information25
      ,vaei_information26
      ,vaei_information27
      ,vaei_information28
      ,vaei_information29
      ,vaei_information30
      ,object_version_number
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      )
  Values
    (p_rec.veh_alloc_extra_info_id
    ,p_rec.vehicle_allocation_id
    ,p_rec.information_type
    ,p_rec.vaei_attribute_category
    ,p_rec.vaei_attribute1
    ,p_rec.vaei_attribute2
    ,p_rec.vaei_attribute3
    ,p_rec.vaei_attribute4
    ,p_rec.vaei_attribute5
    ,p_rec.vaei_attribute6
    ,p_rec.vaei_attribute7
    ,p_rec.vaei_attribute8
    ,p_rec.vaei_attribute9
    ,p_rec.vaei_attribute10
    ,p_rec.vaei_attribute11
    ,p_rec.vaei_attribute12
    ,p_rec.vaei_attribute13
    ,p_rec.vaei_attribute14
    ,p_rec.vaei_attribute15
    ,p_rec.vaei_attribute16
    ,p_rec.vaei_attribute17
    ,p_rec.vaei_attribute18
    ,p_rec.vaei_attribute19
    ,p_rec.vaei_attribute20
    ,p_rec.vaei_information_category
    ,p_rec.vaei_information1
    ,p_rec.vaei_information2
    ,p_rec.vaei_information3
    ,p_rec.vaei_information4
    ,p_rec.vaei_information5
    ,p_rec.vaei_information6
    ,p_rec.vaei_information7
    ,p_rec.vaei_information8
    ,p_rec.vaei_information9
    ,p_rec.vaei_information10
    ,p_rec.vaei_information11
    ,p_rec.vaei_information12
    ,p_rec.vaei_information13
    ,p_rec.vaei_information14
    ,p_rec.vaei_information15
    ,p_rec.vaei_information16
    ,p_rec.vaei_information17
    ,p_rec.vaei_information18
    ,p_rec.vaei_information19
    ,p_rec.vaei_information20
    ,p_rec.vaei_information21
    ,p_rec.vaei_information22
    ,p_rec.vaei_information23
    ,p_rec.vaei_information24
    ,p_rec.vaei_information25
    ,p_rec.vaei_information26
    ,p_rec.vaei_information27
    ,p_rec.vaei_information28
    ,p_rec.vaei_information29
    ,p_rec.vaei_information30
    ,p_rec.object_version_number
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    );
  --
  pqp_vai_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_vai_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vai_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_vai_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vai_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_vai_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vai_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_vai_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy pqp_vai_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select pqp_veh_alloc_extra_info_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pqp_veh_alloc_extra_info
     where veh_alloc_extra_info_id =
             pqp_vai_ins.g_veh_alloc_extra_info_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pqp_vai_ins.g_veh_alloc_extra_info_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pqp_veh_alloc_extra_info');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.veh_alloc_extra_info_id :=
      pqp_vai_ins.g_veh_alloc_extra_info_id_i;
    pqp_vai_ins.g_veh_alloc_extra_info_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.veh_alloc_extra_info_id;
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
  (p_rec                          in pqp_vai_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_vai_rki.after_insert
      (p_veh_alloc_extra_info_id
      => p_rec.veh_alloc_extra_info_id
      ,p_vehicle_allocation_id
      => p_rec.vehicle_allocation_id
      ,p_information_type
      => p_rec.information_type
      ,p_vaei_attribute_category
      => p_rec.vaei_attribute_category
      ,p_vaei_attribute1
      => p_rec.vaei_attribute1
      ,p_vaei_attribute2
      => p_rec.vaei_attribute2
      ,p_vaei_attribute3
      => p_rec.vaei_attribute3
      ,p_vaei_attribute4
      => p_rec.vaei_attribute4
      ,p_vaei_attribute5
      => p_rec.vaei_attribute5
      ,p_vaei_attribute6
      => p_rec.vaei_attribute6
      ,p_vaei_attribute7
      => p_rec.vaei_attribute7
      ,p_vaei_attribute8
      => p_rec.vaei_attribute8
      ,p_vaei_attribute9
      => p_rec.vaei_attribute9
      ,p_vaei_attribute10
      => p_rec.vaei_attribute10
      ,p_vaei_attribute11
      => p_rec.vaei_attribute11
      ,p_vaei_attribute12
      => p_rec.vaei_attribute12
      ,p_vaei_attribute13
      => p_rec.vaei_attribute13
      ,p_vaei_attribute14
      => p_rec.vaei_attribute14
      ,p_vaei_attribute15
      => p_rec.vaei_attribute15
      ,p_vaei_attribute16
      => p_rec.vaei_attribute16
      ,p_vaei_attribute17
      => p_rec.vaei_attribute17
      ,p_vaei_attribute18
      => p_rec.vaei_attribute18
      ,p_vaei_attribute19
      => p_rec.vaei_attribute19
      ,p_vaei_attribute20
      => p_rec.vaei_attribute20
      ,p_vaei_information_category
      => p_rec.vaei_information_category
      ,p_vaei_information1
      => p_rec.vaei_information1
      ,p_vaei_information2
      => p_rec.vaei_information2
      ,p_vaei_information3
      => p_rec.vaei_information3
      ,p_vaei_information4
      => p_rec.vaei_information4
      ,p_vaei_information5
      => p_rec.vaei_information5
      ,p_vaei_information6
      => p_rec.vaei_information6
      ,p_vaei_information7
      => p_rec.vaei_information7
      ,p_vaei_information8
      => p_rec.vaei_information8
      ,p_vaei_information9
      => p_rec.vaei_information9
      ,p_vaei_information10
      => p_rec.vaei_information10
      ,p_vaei_information11
      => p_rec.vaei_information11
      ,p_vaei_information12
      => p_rec.vaei_information12
      ,p_vaei_information13
      => p_rec.vaei_information13
      ,p_vaei_information14
      => p_rec.vaei_information14
      ,p_vaei_information15
      => p_rec.vaei_information15
      ,p_vaei_information16
      => p_rec.vaei_information16
      ,p_vaei_information17
      => p_rec.vaei_information17
      ,p_vaei_information18
      => p_rec.vaei_information18
      ,p_vaei_information19
      => p_rec.vaei_information19
      ,p_vaei_information20
      => p_rec.vaei_information20
      ,p_vaei_information21
      => p_rec.vaei_information21
      ,p_vaei_information22
      => p_rec.vaei_information22
      ,p_vaei_information23
      => p_rec.vaei_information23
      ,p_vaei_information24
      => p_rec.vaei_information24
      ,p_vaei_information25
      => p_rec.vaei_information25
      ,p_vaei_information26
      => p_rec.vaei_information26
      ,p_vaei_information27
      => p_rec.vaei_information27
      ,p_vaei_information28
      => p_rec.vaei_information28
      ,p_vaei_information29
      => p_rec.vaei_information29
      ,p_vaei_information30
      => p_rec.vaei_information30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_ALLOC_EXTRA_INFO'
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
  (p_rec                          in out nocopy pqp_vai_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqp_vai_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pqp_vai_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqp_vai_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqp_vai_ins.post_insert
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
  (p_vehicle_allocation_id          in     number
  ,p_information_type               in     varchar2
  ,p_vaei_attribute_category        in     varchar2 default null
  ,p_vaei_attribute1                in     varchar2 default null
  ,p_vaei_attribute2                in     varchar2 default null
  ,p_vaei_attribute3                in     varchar2 default null
  ,p_vaei_attribute4                in     varchar2 default null
  ,p_vaei_attribute5                in     varchar2 default null
  ,p_vaei_attribute6                in     varchar2 default null
  ,p_vaei_attribute7                in     varchar2 default null
  ,p_vaei_attribute8                in     varchar2 default null
  ,p_vaei_attribute9                in     varchar2 default null
  ,p_vaei_attribute10               in     varchar2 default null
  ,p_vaei_attribute11               in     varchar2 default null
  ,p_vaei_attribute12               in     varchar2 default null
  ,p_vaei_attribute13               in     varchar2 default null
  ,p_vaei_attribute14               in     varchar2 default null
  ,p_vaei_attribute15               in     varchar2 default null
  ,p_vaei_attribute16               in     varchar2 default null
  ,p_vaei_attribute17               in     varchar2 default null
  ,p_vaei_attribute18               in     varchar2 default null
  ,p_vaei_attribute19               in     varchar2 default null
  ,p_vaei_attribute20               in     varchar2 default null
  ,p_vaei_information_category      in     varchar2 default null
  ,p_vaei_information1              in     varchar2 default null
  ,p_vaei_information2              in     varchar2 default null
  ,p_vaei_information3              in     varchar2 default null
  ,p_vaei_information4              in     varchar2 default null
  ,p_vaei_information5              in     varchar2 default null
  ,p_vaei_information6              in     varchar2 default null
  ,p_vaei_information7              in     varchar2 default null
  ,p_vaei_information8              in     varchar2 default null
  ,p_vaei_information9              in     varchar2 default null
  ,p_vaei_information10             in     varchar2 default null
  ,p_vaei_information11             in     varchar2 default null
  ,p_vaei_information12             in     varchar2 default null
  ,p_vaei_information13             in     varchar2 default null
  ,p_vaei_information14             in     varchar2 default null
  ,p_vaei_information15             in     varchar2 default null
  ,p_vaei_information16             in     varchar2 default null
  ,p_vaei_information17             in     varchar2 default null
  ,p_vaei_information18             in     varchar2 default null
  ,p_vaei_information19             in     varchar2 default null
  ,p_vaei_information20             in     varchar2 default null
  ,p_vaei_information21             in     varchar2 default null
  ,p_vaei_information22             in     varchar2 default null
  ,p_vaei_information23             in     varchar2 default null
  ,p_vaei_information24             in     varchar2 default null
  ,p_vaei_information25             in     varchar2 default null
  ,p_vaei_information26             in     varchar2 default null
  ,p_vaei_information27             in     varchar2 default null
  ,p_vaei_information28             in     varchar2 default null
  ,p_vaei_information29             in     varchar2 default null
  ,p_vaei_information30             in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_veh_alloc_extra_info_id           out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   pqp_vai_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Entering ins:'||p_vaei_information9, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  hr_utility.set_location(' Entering shd:'||p_vaei_information9, 10);
  l_rec :=
  pqp_vai_shd.convert_args
    (null
    ,p_vehicle_allocation_id
    ,p_information_type
    ,p_vaei_attribute_category
    ,p_vaei_attribute1
    ,p_vaei_attribute2
    ,p_vaei_attribute3
    ,p_vaei_attribute4
    ,p_vaei_attribute5
    ,p_vaei_attribute6
    ,p_vaei_attribute7
    ,p_vaei_attribute8
    ,p_vaei_attribute9
    ,p_vaei_attribute10
    ,p_vaei_attribute11
    ,p_vaei_attribute12
    ,p_vaei_attribute13
    ,p_vaei_attribute14
    ,p_vaei_attribute15
    ,p_vaei_attribute16
    ,p_vaei_attribute17
    ,p_vaei_attribute18
    ,p_vaei_attribute19
    ,p_vaei_attribute20
    ,p_vaei_information_category
    ,p_vaei_information1
    ,p_vaei_information2
    ,p_vaei_information3
    ,p_vaei_information4
    ,p_vaei_information5
    ,p_vaei_information6
    ,p_vaei_information7
    ,p_vaei_information8
    ,p_vaei_information9
    ,p_vaei_information10
    ,p_vaei_information11
    ,p_vaei_information12
    ,p_vaei_information13
    ,p_vaei_information14
    ,p_vaei_information15
    ,p_vaei_information16
    ,p_vaei_information17
    ,p_vaei_information18
    ,p_vaei_information19
    ,p_vaei_information20
    ,p_vaei_information21
    ,p_vaei_information22
    ,p_vaei_information23
    ,p_vaei_information24
    ,p_vaei_information25
    ,p_vaei_information26
    ,p_vaei_information27
    ,p_vaei_information28
    ,p_vaei_information29
    ,p_vaei_information30
    ,null
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    );
  --
  -- Having converted the arguments into the pqp_vai_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqp_vai_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_veh_alloc_extra_info_id := l_rec.veh_alloc_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqp_vai_ins;

/
