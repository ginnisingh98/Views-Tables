--------------------------------------------------------
--  DDL for Package Body IRC_IPC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPC_INS" as
/* $Header: iripcrhi.pkb 120.0 2005/07/26 15:08:54 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipc_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_posting_content_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_posting_content_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  irc_ipc_ins.g_posting_content_id_i := p_posting_content_id;
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
  (p_rec in out nocopy irc_ipc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  irc_ipc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: irc_posting_contents
  --
  insert into irc_posting_contents
      (posting_content_id
      ,display_manager_info
      ,display_recruiter_info
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,ipc_information_category
      ,ipc_information1
      ,ipc_information2
      ,ipc_information3
      ,ipc_information4
      ,ipc_information5
      ,ipc_information6
      ,ipc_information7
      ,ipc_information8
      ,ipc_information9
      ,ipc_information10
      ,ipc_information11
      ,ipc_information12
      ,ipc_information13
      ,ipc_information14
      ,ipc_information15
      ,ipc_information16
      ,ipc_information17
      ,ipc_information18
      ,ipc_information19
      ,ipc_information20
      ,ipc_information21
      ,ipc_information22
      ,ipc_information23
      ,ipc_information24
      ,ipc_information25
      ,ipc_information26
      ,ipc_information27
      ,ipc_information28
      ,ipc_information29
      ,ipc_information30
      ,object_version_number
      ,date_approved
      ,recruiter_full_name
      ,recruiter_email
      ,recruiter_work_telephone
      ,manager_full_name
      ,manager_email
      ,manager_work_telephone
      )
  Values
    (p_rec.posting_content_id
    ,p_rec.display_manager_info
    ,p_rec.display_recruiter_info
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.attribute21
    ,p_rec.attribute22
    ,p_rec.attribute23
    ,p_rec.attribute24
    ,p_rec.attribute25
    ,p_rec.attribute26
    ,p_rec.attribute27
    ,p_rec.attribute28
    ,p_rec.attribute29
    ,p_rec.attribute30
    ,p_rec.ipc_information_category
    ,p_rec.ipc_information1
    ,p_rec.ipc_information2
    ,p_rec.ipc_information3
    ,p_rec.ipc_information4
    ,p_rec.ipc_information5
    ,p_rec.ipc_information6
    ,p_rec.ipc_information7
    ,p_rec.ipc_information8
    ,p_rec.ipc_information9
    ,p_rec.ipc_information10
    ,p_rec.ipc_information11
    ,p_rec.ipc_information12
    ,p_rec.ipc_information13
    ,p_rec.ipc_information14
    ,p_rec.ipc_information15
    ,p_rec.ipc_information16
    ,p_rec.ipc_information17
    ,p_rec.ipc_information18
    ,p_rec.ipc_information19
    ,p_rec.ipc_information20
    ,p_rec.ipc_information21
    ,p_rec.ipc_information22
    ,p_rec.ipc_information23
    ,p_rec.ipc_information24
    ,p_rec.ipc_information25
    ,p_rec.ipc_information26
    ,p_rec.ipc_information27
    ,p_rec.ipc_information28
    ,p_rec.ipc_information29
    ,p_rec.ipc_information30
    ,p_rec.object_version_number
    ,p_rec.date_approved
    ,p_rec.recruiter_full_name
    ,p_rec.recruiter_email
    ,p_rec.recruiter_work_telephone
    ,p_rec.manager_full_name
    ,p_rec.manager_email
    ,p_rec.manager_work_telephone
    );
  --
  irc_ipc_shd.g_api_dml := false;  -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    irc_ipc_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_ipc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    irc_ipc_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_ipc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    irc_ipc_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_ipc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    irc_ipc_shd.g_api_dml := false;  -- Unset the api dml status
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
  (p_rec  in out nocopy irc_ipc_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select irc_posting_contents_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from irc_posting_contents
     where posting_content_id =
             irc_ipc_ins.g_posting_content_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (irc_ipc_ins.g_posting_content_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','irc_posting_contents');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.posting_content_id :=
      irc_ipc_ins.g_posting_content_id_i;
    irc_ipc_ins.g_posting_content_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.posting_content_id;
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
  (p_rec                          in irc_ipc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_ipc_rki.after_insert
      (p_posting_content_id
      => p_rec.posting_content_id
      ,p_display_manager_info
      => p_rec.display_manager_info
      ,p_display_recruiter_info
      => p_rec.display_recruiter_info
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_ipc_information_category
      => p_rec.ipc_information_category
      ,p_ipc_information1
      => p_rec.ipc_information1
      ,p_ipc_information2
      => p_rec.ipc_information2
      ,p_ipc_information3
      => p_rec.ipc_information3
      ,p_ipc_information4
      => p_rec.ipc_information4
      ,p_ipc_information5
      => p_rec.ipc_information5
      ,p_ipc_information6
      => p_rec.ipc_information6
      ,p_ipc_information7
      => p_rec.ipc_information7
      ,p_ipc_information8
      => p_rec.ipc_information8
      ,p_ipc_information9
      => p_rec.ipc_information9
      ,p_ipc_information10
      => p_rec.ipc_information10
      ,p_ipc_information11
      => p_rec.ipc_information11
      ,p_ipc_information12
      => p_rec.ipc_information12
      ,p_ipc_information13
      => p_rec.ipc_information13
      ,p_ipc_information14
      => p_rec.ipc_information14
      ,p_ipc_information15
      => p_rec.ipc_information15
      ,p_ipc_information16
      => p_rec.ipc_information16
      ,p_ipc_information17
      => p_rec.ipc_information17
      ,p_ipc_information18
      => p_rec.ipc_information18
      ,p_ipc_information19
      => p_rec.ipc_information19
      ,p_ipc_information20
      => p_rec.ipc_information20
      ,p_ipc_information21
      => p_rec.ipc_information21
      ,p_ipc_information22
      => p_rec.ipc_information22
      ,p_ipc_information23
      => p_rec.ipc_information23
      ,p_ipc_information24
      => p_rec.ipc_information24
      ,p_ipc_information25
      => p_rec.ipc_information25
      ,p_ipc_information26
      => p_rec.ipc_information26
      ,p_ipc_information27
      => p_rec.ipc_information27
      ,p_ipc_information28
      => p_rec.ipc_information28
      ,p_ipc_information29
      => p_rec.ipc_information29
      ,p_ipc_information30
      => p_rec.ipc_information30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_date_approved
      => p_rec.date_approved
      ,p_recruiter_full_name
      => p_rec.recruiter_full_name
      ,p_recruiter_email
      => p_rec.recruiter_email
      ,p_recruiter_work_telephone
      => p_rec.recruiter_work_telephone
      ,p_manager_full_name
      => p_rec.manager_full_name
      ,p_manager_email
      => p_rec.manager_email
      ,p_manager_work_telephone
      => p_rec.manager_work_telephone
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_POSTING_CONTENTS'
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
  (p_rec                          in out nocopy irc_ipc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  irc_ipc_bus.insert_validate
     (p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  irc_ipc_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  irc_ipc_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  irc_ipc_ins.post_insert
     (p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_display_manager_info           in     varchar2
  ,p_display_recruiter_info         in     varchar2
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_ipc_information_category       in     varchar2 default null
  ,p_ipc_information1               in     varchar2 default null
  ,p_ipc_information2               in     varchar2 default null
  ,p_ipc_information3               in     varchar2 default null
  ,p_ipc_information4               in     varchar2 default null
  ,p_ipc_information5               in     varchar2 default null
  ,p_ipc_information6               in     varchar2 default null
  ,p_ipc_information7               in     varchar2 default null
  ,p_ipc_information8               in     varchar2 default null
  ,p_ipc_information9               in     varchar2 default null
  ,p_ipc_information10              in     varchar2 default null
  ,p_ipc_information11              in     varchar2 default null
  ,p_ipc_information12              in     varchar2 default null
  ,p_ipc_information13              in     varchar2 default null
  ,p_ipc_information14              in     varchar2 default null
  ,p_ipc_information15              in     varchar2 default null
  ,p_ipc_information16              in     varchar2 default null
  ,p_ipc_information17              in     varchar2 default null
  ,p_ipc_information18              in     varchar2 default null
  ,p_ipc_information19              in     varchar2 default null
  ,p_ipc_information20              in     varchar2 default null
  ,p_ipc_information21              in     varchar2 default null
  ,p_ipc_information22              in     varchar2 default null
  ,p_ipc_information23              in     varchar2 default null
  ,p_ipc_information24              in     varchar2 default null
  ,p_ipc_information25              in     varchar2 default null
  ,p_ipc_information26              in     varchar2 default null
  ,p_ipc_information27              in     varchar2 default null
  ,p_ipc_information28              in     varchar2 default null
  ,p_ipc_information29              in     varchar2 default null
  ,p_ipc_information30              in     varchar2 default null
  ,p_date_approved                  in     date     default null
  ,p_recruiter_full_name            in     varchar2 default null
  ,p_recruiter_email                in     varchar2 default null
  ,p_recruiter_work_telephone       in     varchar2 default null
  ,p_manager_full_name              in     varchar2 default null
  ,p_manager_email                  in     varchar2 default null
  ,p_manager_work_telephone         in     varchar2 default null
  ,p_posting_content_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   irc_ipc_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  irc_ipc_shd.convert_args
    (null
    ,p_display_manager_info
    ,p_display_recruiter_info
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_attribute21
    ,p_attribute22
    ,p_attribute23
    ,p_attribute24
    ,p_attribute25
    ,p_attribute26
    ,p_attribute27
    ,p_attribute28
    ,p_attribute29
    ,p_attribute30
    ,p_ipc_information_category
    ,p_ipc_information1
    ,p_ipc_information2
    ,p_ipc_information3
    ,p_ipc_information4
    ,p_ipc_information5
    ,p_ipc_information6
    ,p_ipc_information7
    ,p_ipc_information8
    ,p_ipc_information9
    ,p_ipc_information10
    ,p_ipc_information11
    ,p_ipc_information12
    ,p_ipc_information13
    ,p_ipc_information14
    ,p_ipc_information15
    ,p_ipc_information16
    ,p_ipc_information17
    ,p_ipc_information18
    ,p_ipc_information19
    ,p_ipc_information20
    ,p_ipc_information21
    ,p_ipc_information22
    ,p_ipc_information23
    ,p_ipc_information24
    ,p_ipc_information25
    ,p_ipc_information26
    ,p_ipc_information27
    ,p_ipc_information28
    ,p_ipc_information29
    ,p_ipc_information30
    ,null
    ,p_date_approved
    ,p_recruiter_full_name
    ,p_recruiter_email
    ,p_recruiter_work_telephone
    ,p_manager_full_name
    ,p_manager_email
    ,p_manager_work_telephone
    );
  --
  -- Having converted the arguments into the irc_ipc_rec
  -- plsql record structure we call the corresponding record business process.
  --
  irc_ipc_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_posting_content_id := l_rec.posting_content_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end irc_ipc_ins;

/
