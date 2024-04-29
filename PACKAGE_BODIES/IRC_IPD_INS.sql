--------------------------------------------------------
--  DDL for Package Body IRC_IPD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPD_INS" as
/* $Header: iripdrhi.pkb 120.0 2005/07/26 15:09:42 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipd_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_pending_data_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_pending_data_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  irc_ipd_ins.g_pending_data_id_i := p_pending_data_id;
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
  (p_rec in out nocopy irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Insert the row into: irc_pending_data
  --
  insert into irc_pending_data
      (pending_data_id
      ,email_address
      ,vacancy_id
      ,last_name
      ,first_name
      ,user_password
      ,resume_file_name
      ,resume_description
      ,resume_mime_type
      ,resume
      ,source_type
      ,job_post_source_name
      ,posting_content_id
      ,person_id
      ,processed
      ,sex
      ,date_of_birth
      ,per_information_category
      ,per_information1
      ,per_information2
      ,per_information3
      ,per_information4
      ,per_information5
      ,per_information6
      ,per_information7
      ,per_information8
      ,per_information9
      ,per_information10
      ,per_information11
      ,per_information12
      ,per_information13
      ,per_information14
      ,per_information15
      ,per_information16
      ,per_information17
      ,per_information18
      ,per_information19
      ,per_information20
      ,per_information21
      ,per_information22
      ,per_information23
      ,per_information24
      ,per_information25
      ,per_information26
      ,per_information27
      ,per_information28
      ,per_information29
      ,per_information30
      ,error_message
      ,creation_date
      ,last_update_date
      ,allow_access
      ,user_guid
      ,visitor_resp_key
      ,visitor_resp_appl_id
      ,security_group_key
      )
  Values
    (p_rec.pending_data_id
    ,p_rec.email_address
    ,p_rec.vacancy_id
    ,p_rec.last_name
    ,p_rec.first_name
    ,p_rec.user_password
    ,p_rec.resume_file_name
    ,p_rec.resume_description
    ,p_rec.resume_mime_type
    ,empty_blob()
    ,p_rec.source_type
    ,p_rec.job_post_source_name
    ,p_rec.posting_content_id
    ,p_rec.person_id
    ,p_rec.processed
    ,p_rec.sex
    ,p_rec.date_of_birth
    ,p_rec.per_information_category
    ,p_rec.per_information1
    ,p_rec.per_information2
    ,p_rec.per_information3
    ,p_rec.per_information4
    ,p_rec.per_information5
    ,p_rec.per_information6
    ,p_rec.per_information7
    ,p_rec.per_information8
    ,p_rec.per_information9
    ,p_rec.per_information10
    ,p_rec.per_information11
    ,p_rec.per_information12
    ,p_rec.per_information13
    ,p_rec.per_information14
    ,p_rec.per_information15
    ,p_rec.per_information16
    ,p_rec.per_information17
    ,p_rec.per_information18
    ,p_rec.per_information19
    ,p_rec.per_information20
    ,p_rec.per_information21
    ,p_rec.per_information22
    ,p_rec.per_information23
    ,p_rec.per_information24
    ,p_rec.per_information25
    ,p_rec.per_information26
    ,p_rec.per_information27
    ,p_rec.per_information28
    ,p_rec.per_information29
    ,p_rec.per_information30
    ,p_rec.error_message
    ,p_rec.creation_date
    ,p_rec.last_update_date
    ,p_rec.allow_access
    ,p_rec.user_guid
    ,p_rec.visitor_resp_key
    ,p_rec.visitor_resp_appl_id
    ,p_rec.security_group_key
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    irc_ipd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    irc_ipd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    irc_ipd_shd.constraint_error
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
  (p_rec  in out nocopy irc_ipd_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select irc_pending_data_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from irc_pending_data
     where pending_data_id =
             irc_ipd_ins.g_pending_data_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (irc_ipd_ins.g_pending_data_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','irc_pending_data');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.pending_data_id :=
      irc_ipd_ins.g_pending_data_id_i;
    irc_ipd_ins.g_pending_data_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.pending_data_id;
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
  (p_rec                          in irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_ipd_rki.after_insert
      (p_pending_data_id
      => p_rec.pending_data_id
      ,p_email_address
      => p_rec.email_address
      ,p_vacancy_id
      => p_rec.vacancy_id
      ,p_last_name
      => p_rec.last_name
      ,p_first_name
      => p_rec.first_name
      ,p_user_password
      => p_rec.user_password
      ,p_resume_file_name
      => p_rec.resume_file_name
      ,p_resume_description
      => p_rec.resume_description
      ,p_resume_mime_type
      => p_rec.resume_mime_type
      ,p_source_type
      => p_rec.source_type
      ,p_job_post_source_name
      => p_rec.job_post_source_name
      ,p_posting_content_id
      => p_rec.posting_content_id
      ,p_person_id
      => p_rec.person_id
      ,p_processed
      => p_rec.processed
      ,p_sex
      => p_rec.sex
      ,p_date_of_birth
      => p_rec.date_of_birth
      ,p_per_information_category
      => p_rec.per_information_category
      ,p_per_information1
      => p_rec.per_information1
      ,p_per_information2
      => p_rec.per_information2
      ,p_per_information3
      => p_rec.per_information3
      ,p_per_information4
      => p_rec.per_information4
      ,p_per_information5
      => p_rec.per_information5
      ,p_per_information6
      => p_rec.per_information6
      ,p_per_information7
      => p_rec.per_information7
      ,p_per_information8
      => p_rec.per_information8
      ,p_per_information9
      => p_rec.per_information9
      ,p_per_information10
      => p_rec.per_information10
      ,p_per_information11
      => p_rec.per_information11
      ,p_per_information12
      => p_rec.per_information12
      ,p_per_information13
      => p_rec.per_information13
      ,p_per_information14
      => p_rec.per_information14
      ,p_per_information15
      => p_rec.per_information15
      ,p_per_information16
      => p_rec.per_information16
      ,p_per_information17
      => p_rec.per_information17
      ,p_per_information18
      => p_rec.per_information18
      ,p_per_information19
      => p_rec.per_information19
      ,p_per_information20
      => p_rec.per_information20
      ,p_per_information21
      => p_rec.per_information21
      ,p_per_information22
      => p_rec.per_information22
      ,p_per_information23
      => p_rec.per_information23
      ,p_per_information24
      => p_rec.per_information24
      ,p_per_information25
      => p_rec.per_information25
      ,p_per_information26
      => p_rec.per_information26
      ,p_per_information27
      => p_rec.per_information27
      ,p_per_information28
      => p_rec.per_information28
      ,p_per_information29
      => p_rec.per_information29
      ,p_per_information30
      => p_rec.per_information30
      ,p_error_message
      => p_rec.error_message
      ,p_creation_date
      => p_rec.creation_date
      ,p_last_update_date
      => p_rec.last_update_date
      ,p_allow_access
      => p_rec.allow_access
      ,p_visitor_resp_key
      => p_rec.visitor_resp_key
      ,p_visitor_resp_appl_id
      => p_rec.visitor_resp_appl_id
      ,p_security_group_key
      => p_rec.security_group_key
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_PENDING_DATA'
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
  (p_rec                          in out nocopy irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  irc_ipd_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  irc_ipd_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  irc_ipd_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  irc_ipd_ins.post_insert
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
  (p_email_address                  in     varchar2
  ,p_last_name                      in     varchar2
  ,p_vacancy_id                     in     number   default null
  ,p_first_name                     in     varchar2 default null
  ,p_user_password                  in     varchar2 default null
  ,p_resume_file_name               in     varchar2 default null
  ,p_resume_description             in     varchar2 default null
  ,p_resume_mime_type               in     varchar2 default null
  ,p_source_type                    in     varchar2 default null
  ,p_job_post_source_name           in     varchar2 default null
  ,p_posting_content_id             in     number   default null
  ,p_person_id                      in     number   default null
  ,p_processed                      in     varchar2 default null
  ,p_sex                            in     varchar2 default null
  ,p_date_of_birth                  in     date     default null
  ,p_per_information_category       in     varchar2 default null
  ,p_per_information1               in     varchar2 default null
  ,p_per_information2               in     varchar2 default null
  ,p_per_information3               in     varchar2 default null
  ,p_per_information4               in     varchar2 default null
  ,p_per_information5               in     varchar2 default null
  ,p_per_information6               in     varchar2 default null
  ,p_per_information7               in     varchar2 default null
  ,p_per_information8               in     varchar2 default null
  ,p_per_information9               in     varchar2 default null
  ,p_per_information10              in     varchar2 default null
  ,p_per_information11              in     varchar2 default null
  ,p_per_information12              in     varchar2 default null
  ,p_per_information13              in     varchar2 default null
  ,p_per_information14              in     varchar2 default null
  ,p_per_information15              in     varchar2 default null
  ,p_per_information16              in     varchar2 default null
  ,p_per_information17              in     varchar2 default null
  ,p_per_information18              in     varchar2 default null
  ,p_per_information19              in     varchar2 default null
  ,p_per_information20              in     varchar2 default null
  ,p_per_information21              in     varchar2 default null
  ,p_per_information22              in     varchar2 default null
  ,p_per_information23              in     varchar2 default null
  ,p_per_information24              in     varchar2 default null
  ,p_per_information25              in     varchar2 default null
  ,p_per_information26              in     varchar2 default null
  ,p_per_information27              in     varchar2 default null
  ,p_per_information28              in     varchar2 default null
  ,p_per_information29              in     varchar2 default null
  ,p_per_information30              in     varchar2 default null
  ,p_error_message                  in     varchar2 default null
  ,p_creation_date                  in     date
  ,p_last_update_date               in     date
  ,p_allow_access                   in     varchar2 default null
  ,p_user_guid                      in     raw      default null
  ,p_visitor_resp_key               in     varchar2 default null
  ,p_visitor_resp_appl_id           in     number   default null
  ,p_security_group_key             in     varchar2 default null
  ,p_pending_data_id                   out nocopy number
  ) is
--
  l_rec   irc_ipd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  irc_ipd_shd.convert_args
    (null
    ,p_email_address
    ,p_vacancy_id
    ,p_last_name
    ,p_first_name
    ,p_user_password
    ,p_resume_file_name
    ,p_resume_description
    ,p_resume_mime_type
    ,p_source_type
    ,p_job_post_source_name
    ,p_posting_content_id
    ,p_person_id
    ,p_processed
    ,p_sex
    ,p_date_of_birth
    ,p_per_information_category
    ,p_per_information1
    ,p_per_information2
    ,p_per_information3
    ,p_per_information4
    ,p_per_information5
    ,p_per_information6
    ,p_per_information7
    ,p_per_information8
    ,p_per_information9
    ,p_per_information10
    ,p_per_information11
    ,p_per_information12
    ,p_per_information13
    ,p_per_information14
    ,p_per_information15
    ,p_per_information16
    ,p_per_information17
    ,p_per_information18
    ,p_per_information19
    ,p_per_information20
    ,p_per_information21
    ,p_per_information22
    ,p_per_information23
    ,p_per_information24
    ,p_per_information25
    ,p_per_information26
    ,p_per_information27
    ,p_per_information28
    ,p_per_information29
    ,p_per_information30
    ,p_error_message
    ,p_creation_date
    ,p_last_update_date
    ,p_allow_access
    ,p_user_guid
    ,p_visitor_resp_key
    ,p_visitor_resp_appl_id
    ,p_security_group_key
    );
  --
  -- Having converted the arguments into the irc_ipd_rec
  -- plsql record structure we call the corresponding record business process.
  --
  irc_ipd_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pending_data_id := l_rec.pending_data_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end irc_ipd_ins;

/
