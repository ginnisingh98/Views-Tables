--------------------------------------------------------
--  DDL for Package Body PQP_VRI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VRI_INS" as
/* $Header: pqvrirhi.pkb 120.0.12010000.2 2008/08/08 07:24:11 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vri_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_veh_repos_extra_info_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_veh_repos_extra_info_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pqp_vri_ins.g_veh_repos_extra_info_id_i := p_veh_repos_extra_info_id;
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
  (p_rec in out nocopy pqp_vri_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pqp_vri_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pqp_veh_repos_extra_info
  --
  insert into pqp_veh_repos_extra_info
      (veh_repos_extra_info_id
      ,vehicle_repository_id
      ,information_type
      ,vrei_attribute_category
      ,vrei_attribute1
      ,vrei_attribute2
      ,vrei_attribute3
      ,vrei_attribute4
      ,vrei_attribute5
      ,vrei_attribute6
      ,vrei_attribute7
      ,vrei_attribute8
      ,vrei_attribute9
      ,vrei_attribute10
      ,vrei_attribute11
      ,vrei_attribute12
      ,vrei_attribute13
      ,vrei_attribute14
      ,vrei_attribute15
      ,vrei_attribute16
      ,vrei_attribute17
      ,vrei_attribute18
      ,vrei_attribute19
      ,vrei_attribute20
      ,vrei_information_category
      ,vrei_information1
      ,vrei_information2
      ,vrei_information3
      ,vrei_information4
      ,vrei_information5
      ,vrei_information6
      ,vrei_information7
      ,vrei_information8
      ,vrei_information9
      ,vrei_information10
      ,vrei_information11
      ,vrei_information12
      ,vrei_information13
      ,vrei_information14
      ,vrei_information15
      ,vrei_information16
      ,vrei_information17
      ,vrei_information18
      ,vrei_information19
      ,vrei_information20
      ,vrei_information21
      ,vrei_information22
      ,vrei_information23
      ,vrei_information24
      ,vrei_information25
      ,vrei_information26
      ,vrei_information27
      ,vrei_information28
      ,vrei_information29
      ,vrei_information30
      ,object_version_number
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      )
  Values
    (p_rec.veh_repos_extra_info_id
    ,p_rec.vehicle_repository_id
    ,p_rec.information_type
    ,p_rec.vrei_attribute_category
    ,p_rec.vrei_attribute1
    ,p_rec.vrei_attribute2
    ,p_rec.vrei_attribute3
    ,p_rec.vrei_attribute4
    ,p_rec.vrei_attribute5
    ,p_rec.vrei_attribute6
    ,p_rec.vrei_attribute7
    ,p_rec.vrei_attribute8
    ,p_rec.vrei_attribute9
    ,p_rec.vrei_attribute10
    ,p_rec.vrei_attribute11
    ,p_rec.vrei_attribute12
    ,p_rec.vrei_attribute13
    ,p_rec.vrei_attribute14
    ,p_rec.vrei_attribute15
    ,p_rec.vrei_attribute16
    ,p_rec.vrei_attribute17
    ,p_rec.vrei_attribute18
    ,p_rec.vrei_attribute19
    ,p_rec.vrei_attribute20
    ,p_rec.vrei_information_category
    ,p_rec.vrei_information1
    ,p_rec.vrei_information2
    ,p_rec.vrei_information3
    ,p_rec.vrei_information4
    ,p_rec.vrei_information5
    ,p_rec.vrei_information6
    ,p_rec.vrei_information7
    ,p_rec.vrei_information8
    ,p_rec.vrei_information9
    ,p_rec.vrei_information10
    ,p_rec.vrei_information11
    ,p_rec.vrei_information12
    ,p_rec.vrei_information13
    ,p_rec.vrei_information14
    ,p_rec.vrei_information15
    ,p_rec.vrei_information16
    ,p_rec.vrei_information17
    ,p_rec.vrei_information18
    ,p_rec.vrei_information19
    ,p_rec.vrei_information20
    ,p_rec.vrei_information21
    ,p_rec.vrei_information22
    ,p_rec.vrei_information23
    ,p_rec.vrei_information24
    ,p_rec.vrei_information25
    ,p_rec.vrei_information26
    ,p_rec.vrei_information27
    ,p_rec.vrei_information28
    ,p_rec.vrei_information29
    ,p_rec.vrei_information30
    ,p_rec.object_version_number
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    );
  --
  pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vri_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vri_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_vri_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_vri_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec  in out nocopy pqp_vri_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select pqp_veh_repos_extra_info_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pqp_veh_repos_extra_info
     where veh_repos_extra_info_id =
             pqp_vri_ins.g_veh_repos_extra_info_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pqp_vri_ins.g_veh_repos_extra_info_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pqp_veh_repos_extra_info');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.veh_repos_extra_info_id :=
      pqp_vri_ins.g_veh_repos_extra_info_id_i;
    pqp_vri_ins.g_veh_repos_extra_info_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.veh_repos_extra_info_id;
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
  (p_rec                          in pqp_vri_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_vri_rki.after_insert
      (p_veh_repos_extra_info_id
      => p_rec.veh_repos_extra_info_id
      ,p_vehicle_repository_id
      => p_rec.vehicle_repository_id
      ,p_information_type
      => p_rec.information_type
      ,p_vrei_attribute_category
      => p_rec.vrei_attribute_category
      ,p_vrei_attribute1
      => p_rec.vrei_attribute1
      ,p_vrei_attribute2
      => p_rec.vrei_attribute2
      ,p_vrei_attribute3
      => p_rec.vrei_attribute3
      ,p_vrei_attribute4
      => p_rec.vrei_attribute4
      ,p_vrei_attribute5
      => p_rec.vrei_attribute5
      ,p_vrei_attribute6
      => p_rec.vrei_attribute6
      ,p_vrei_attribute7
      => p_rec.vrei_attribute7
      ,p_vrei_attribute8
      => p_rec.vrei_attribute8
      ,p_vrei_attribute9
      => p_rec.vrei_attribute9
      ,p_vrei_attribute10
      => p_rec.vrei_attribute10
      ,p_vrei_attribute11
      => p_rec.vrei_attribute11
      ,p_vrei_attribute12
      => p_rec.vrei_attribute12
      ,p_vrei_attribute13
      => p_rec.vrei_attribute13
      ,p_vrei_attribute14
      => p_rec.vrei_attribute14
      ,p_vrei_attribute15
      => p_rec.vrei_attribute15
      ,p_vrei_attribute16
      => p_rec.vrei_attribute16
      ,p_vrei_attribute17
      => p_rec.vrei_attribute17
      ,p_vrei_attribute18
      => p_rec.vrei_attribute18
      ,p_vrei_attribute19
      => p_rec.vrei_attribute19
      ,p_vrei_attribute20
      => p_rec.vrei_attribute20
      ,p_vrei_information_category
      => p_rec.vrei_information_category
      ,p_vrei_information1
      => p_rec.vrei_information1
      ,p_vrei_information2
      => p_rec.vrei_information2
      ,p_vrei_information3
      => p_rec.vrei_information3
      ,p_vrei_information4
      => p_rec.vrei_information4
      ,p_vrei_information5
      => p_rec.vrei_information5
      ,p_vrei_information6
      => p_rec.vrei_information6
      ,p_vrei_information7
      => p_rec.vrei_information7
      ,p_vrei_information8
      => p_rec.vrei_information8
      ,p_vrei_information9
      => p_rec.vrei_information9
      ,p_vrei_information10
      => p_rec.vrei_information10
      ,p_vrei_information11
      => p_rec.vrei_information11
      ,p_vrei_information12
      => p_rec.vrei_information12
      ,p_vrei_information13
      => p_rec.vrei_information13
      ,p_vrei_information14
      => p_rec.vrei_information14
      ,p_vrei_information15
      => p_rec.vrei_information15
      ,p_vrei_information16
      => p_rec.vrei_information16
      ,p_vrei_information17
      => p_rec.vrei_information17
      ,p_vrei_information18
      => p_rec.vrei_information18
      ,p_vrei_information19
      => p_rec.vrei_information19
      ,p_vrei_information20
      => p_rec.vrei_information20
      ,p_vrei_information21
      => p_rec.vrei_information21
      ,p_vrei_information22
      => p_rec.vrei_information22
      ,p_vrei_information23
      => p_rec.vrei_information23
      ,p_vrei_information24
      => p_rec.vrei_information24
      ,p_vrei_information25
      => p_rec.vrei_information25
      ,p_vrei_information26
      => p_rec.vrei_information26
      ,p_vrei_information27
      => p_rec.vrei_information27
      ,p_vrei_information28
      => p_rec.vrei_information28
      ,p_vrei_information29
      => p_rec.vrei_information29
      ,p_vrei_information30
      => p_rec.vrei_information30
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
        (p_module_name => 'PQP_VEH_REPOS_EXTRA_INFO'
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
  (p_rec                          in out nocopy pqp_vri_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqp_vri_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pqp_vri_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqp_vri_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqp_vri_ins.post_insert
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
  (p_vehicle_repository_id          in     number
  ,p_information_type               in     varchar2
  ,p_vrei_attribute_category        in     varchar2 default null
  ,p_vrei_attribute1                in     varchar2 default null
  ,p_vrei_attribute2                in     varchar2 default null
  ,p_vrei_attribute3                in     varchar2 default null
  ,p_vrei_attribute4                in     varchar2 default null
  ,p_vrei_attribute5                in     varchar2 default null
  ,p_vrei_attribute6                in     varchar2 default null
  ,p_vrei_attribute7                in     varchar2 default null
  ,p_vrei_attribute8                in     varchar2 default null
  ,p_vrei_attribute9                in     varchar2 default null
  ,p_vrei_attribute10               in     varchar2 default null
  ,p_vrei_attribute11               in     varchar2 default null
  ,p_vrei_attribute12               in     varchar2 default null
  ,p_vrei_attribute13               in     varchar2 default null
  ,p_vrei_attribute14               in     varchar2 default null
  ,p_vrei_attribute15               in     varchar2 default null
  ,p_vrei_attribute16               in     varchar2 default null
  ,p_vrei_attribute17               in     varchar2 default null
  ,p_vrei_attribute18               in     varchar2 default null
  ,p_vrei_attribute19               in     varchar2 default null
  ,p_vrei_attribute20               in     varchar2 default null
  ,p_vrei_information_category      in     varchar2 default null
  ,p_vrei_information1              in     varchar2 default null
  ,p_vrei_information2              in     varchar2 default null
  ,p_vrei_information3              in     varchar2 default null
  ,p_vrei_information4              in     varchar2 default null
  ,p_vrei_information5              in     varchar2 default null
  ,p_vrei_information6              in     varchar2 default null
  ,p_vrei_information7              in     varchar2 default null
  ,p_vrei_information8              in     varchar2 default null
  ,p_vrei_information9              in     varchar2 default null
  ,p_vrei_information10             in     varchar2 default null
  ,p_vrei_information11             in     varchar2 default null
  ,p_vrei_information12             in     varchar2 default null
  ,p_vrei_information13             in     varchar2 default null
  ,p_vrei_information14             in     varchar2 default null
  ,p_vrei_information15             in     varchar2 default null
  ,p_vrei_information16             in     varchar2 default null
  ,p_vrei_information17             in     varchar2 default null
  ,p_vrei_information18             in     varchar2 default null
  ,p_vrei_information19             in     varchar2 default null
  ,p_vrei_information20             in     varchar2 default null
  ,p_vrei_information21             in     varchar2 default null
  ,p_vrei_information22             in     varchar2 default null
  ,p_vrei_information23             in     varchar2 default null
  ,p_vrei_information24             in     varchar2 default null
  ,p_vrei_information25             in     varchar2 default null
  ,p_vrei_information26             in     varchar2 default null
  ,p_vrei_information27             in     varchar2 default null
  ,p_vrei_information28             in     varchar2 default null
  ,p_vrei_information29             in     varchar2 default null
  ,p_vrei_information30             in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_veh_repos_extra_info_id           out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   pqp_vri_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqp_vri_shd.convert_args
    (null
    ,p_vehicle_repository_id
    ,p_information_type
    ,p_vrei_attribute_category
    ,p_vrei_attribute1
    ,p_vrei_attribute2
    ,p_vrei_attribute3
    ,p_vrei_attribute4
    ,p_vrei_attribute5
    ,p_vrei_attribute6
    ,p_vrei_attribute7
    ,p_vrei_attribute8
    ,p_vrei_attribute9
    ,p_vrei_attribute10
    ,p_vrei_attribute11
    ,p_vrei_attribute12
    ,p_vrei_attribute13
    ,p_vrei_attribute14
    ,p_vrei_attribute15
    ,p_vrei_attribute16
    ,p_vrei_attribute17
    ,p_vrei_attribute18
    ,p_vrei_attribute19
    ,p_vrei_attribute20
    ,p_vrei_information_category
    ,p_vrei_information1
    ,p_vrei_information2
    ,p_vrei_information3
    ,p_vrei_information4
    ,p_vrei_information5
    ,p_vrei_information6
    ,p_vrei_information7
    ,p_vrei_information8
    ,p_vrei_information9
    ,p_vrei_information10
    ,p_vrei_information11
    ,p_vrei_information12
    ,p_vrei_information13
    ,p_vrei_information14
    ,p_vrei_information15
    ,p_vrei_information16
    ,p_vrei_information17
    ,p_vrei_information18
    ,p_vrei_information19
    ,p_vrei_information20
    ,p_vrei_information21
    ,p_vrei_information22
    ,p_vrei_information23
    ,p_vrei_information24
    ,p_vrei_information25
    ,p_vrei_information26
    ,p_vrei_information27
    ,p_vrei_information28
    ,p_vrei_information29
    ,p_vrei_information30
    ,null
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    );
  --
  -- Having converted the arguments into the pqp_vri_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqp_vri_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_veh_repos_extra_info_id := l_rec.veh_repos_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqp_vri_ins;

/
